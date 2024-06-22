package SPI_seq_item_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum bit [1:0] {WRITE_ADDR = 2'b00, WRITE_DATA = 2'b01, READ_ADDR = 2'b10, READ_DATA = 2'b11} ram_e;

class SPI_seq_item extends uvm_sequence_item;
	`uvm_object_utils(SPI_seq_item);

	rand bit SS_n,rst_n,MOSI;
	logic MISO;
	
	/* the counter variable is used to determine exactly this randomization corresponds to what position on the state diagram
	   counter = 1 correspods to randomization on moving from IDLE state to CHCK_CMD state, counter = 2 corresponds to transition from 
	   CHK_CMD state to any other state of reading or writing, and then counter increments every loop the read and write state loops and
	   becomens zero again when returning back to IDLE state */
	static bit [4:0] counter;

	/* rd_addr_done is set high when read_address operation is completed to the end successfully, so that next operation is read data if MOSI bit 
	   at CHK_CMD is 1
	   wr_addr_done is set high when write_address operation is completed to the end successfully, so that next operation has higher probability
	   of being write data if MOSI bit at CHK_CMD is 0 */
	static bit rd_addr_done, wr_addr_done;

	/* this two variables determine the last two randomized MOSI values */
	bit old_MOSI;
	bit past_old_MOSI; 

	/* op variable contains the current operation at hand */
	bit [1:0] op;

	/* counter final value is 12 is the currrent operation is not a read data opearation, otherwise it is 22 to wait until
	   data is sent from SPI slave to SPI master*/
	int COUNTER_FINAL_VALUE = 12;

	/* if current operation is write address, then store the randomized address bit by bit in this register*/
	bit [7:0] write_address;

	/* this associative array is used to store randomized write addresses, so that when a read address operation comes
	   constrianing gives higher priority that the randomized read address is a previous sent write address (written place) */
	bit [7:0] write_addr_assoc_arr [bit [7:0]]; 
	
	rand bit [7:0] read_index;       
	
	/* this flag is set high when the operation at hand is write address*/
	bit write_addr_flag; 

	/* this flag is set high when the operation at hand is read address*/
	bit read_addr_flag;

	////////////////////// constraints /////////////////
	//SPI_1
	constraint rst_n_c {
		rst_n dist {1:= 99, 0:=1};
	}

	//SPI_2
	constraint SS_n_c {
		if (counter < COUNTER_FINAL_VALUE) 
			SS_n dist {0:= 99, 1:= 1};     // Master can send SS_n = 1 at the middle of operation (non destructive invalid case).
		else 
			SS_n == 1'b1;	
	}

	//SPI_3,SPI_4
	constraint MOSI_c {
		if (counter == 2) 
			MOSI == old_MOSI;
		else if (counter == 3)
			if (old_MOSI) {
				//handling read operation
				if (rd_addr_done) 
					MOSI == 1'b1;             //go to read data		
				else 
					MOSI == 1'b0;	    
				}	    
			else {
				//handling write operation
				if (wr_addr_done) 
					MOSI dist {1'b1 := 98, 1'b0 := 2};
				else 
					MOSI == 1'b0;	
				}

		else if (counter >= 4 && counter <= 11 && read_addr_flag) {
				if(write_addr_assoc_arr.num())
				MOSI == write_addr_assoc_arr [read_index][11-counter];
			}
			
	}
	
	//SPI_5
	constraint read_index_c {
		if(write_addr_assoc_arr.num()) {
			if (counter == 4 && read_addr_flag)
				read_index inside {write_addr_assoc_arr};
		}
	}
	
	///////////////////////// Functions ////////////////////////////
	function void post_randomize ();
		
		past_old_MOSI = old_MOSI;	
		old_MOSI      = MOSI;
		counter ++;

		if (~rst_n) begin
		    wr_addr_done = 0;
			rd_addr_done = 0;
		end

		/* when counter is 4 that means first two MSB are randomized, so check them to 
		   determine value of write_addr_flag, rd_addr_falg and counter */
		else if (counter == 4) begin
			op = {past_old_MOSI, old_MOSI};
			COUNTER_FINAL_VALUE = 12;

			if (op == WRITE_ADDR) begin
				write_addr_flag = 1'b1;
				read_addr_flag  = 1'b0;
			end
			else if (op == READ_ADDR) begin
				write_addr_flag = 1'b0;
				read_addr_flag  = 1'b1;
			end
			else begin
				write_addr_flag = 1'b0;
				read_addr_flag  = 1'b0;
				
				if (op == READ_DATA) 
					COUNTER_FINAL_VALUE = 22;
				
			end
		end
		/* after operation at hand is completed successfully with no rst or ss_n interrupting the operation,
		   determine the values of rd_addr_done and wr_addr_done flags*/
		else if (counter == COUNTER_FINAL_VALUE + 1) begin
			if (op == READ_ADDR)  
				rd_addr_done = 1'b1;
			else if (op == READ_DATA)
				rd_addr_done = 1'b0;
						
			else if (op == WRITE_ADDR )
				wr_addr_done = 1'b1;
			else 
				wr_addr_done = 1'b0;
		end

		/* if the current operation is write_address then save the randomized address into write_addr_assoc_arr */
		if (counter >= 5 && counter<= 12) begin
			if (write_addr_flag) begin
				write_address[12-counter] = old_MOSI;

				if (counter == 12) 
					write_addr_assoc_arr[write_address] = write_address;
					
			end
		end	

		/* set counter to zero when moving back to IDLE state*/
		if (counter == (COUNTER_FINAL_VALUE+1) || ~rst_n || SS_n)
			counter = 0;

	endfunction 

	function new(string name = "SPI_seq_item");
		super.new(name);	
	endfunction

	function string convert2string();
		return $sformatf("%s rst_n = 0b%0b, SS_n = 0b%0b, MOSI = 0b%0b, MISO = 0b%0b",
						  super.convert2string(), rst_n, SS_n, MOSI, MISO);
	endfunction

	function string convert2string_stimulus();
		return $sformatf("rst_n = 0b%0b, SS_n = 0b%0b, MOSI = 0b%0b",rst_n, SS_n, MOSI);
	endfunction

endclass : SPI_seq_item

endpackage : SPI_seq_item_pkg