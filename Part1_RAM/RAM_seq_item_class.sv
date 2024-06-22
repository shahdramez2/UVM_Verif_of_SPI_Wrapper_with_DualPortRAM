package RAM_seq_item_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum bit [1:0] {WRITE_ADDR = 2'b00, WRITE_DATA = 2'b01, READ_ADDR = 2'b10, READ_DATA = 2'b11} ram_e;

class RAM_seq_item extends uvm_sequence_item;
`uvm_object_utils(RAM_seq_item);

rand bit [9:0]din;
rand bit rst_n,rx_valid;
rand ram_e din_not_writedata, din_not_readdata;
logic tx_valid;
logic [7:0]dout;

bit [1:0] old_din;
bit writeAddress_done_flag;
ram_e Not_write_data []  = '{WRITE_ADDR, READ_ADDR, READ_DATA};
ram_e Not_read_data  []  = '{WRITE_ADDR, WRITE_DATA, READ_ADDR};

integer RX_VALID_ON_DIST = 90;
	
	////////////////////// constraints /////////////////
	//RAM_1
	constraint rst_n_c {
		rst_n dist {1:= 98, 0:=2};
	}
	
	//RAM_2, RAM_3, RAM_4, RAM_5

	//write operation only 
	constraint din_write_op_c {
		
		if (old_din == WRITE_ADDR && writeAddress_done_flag)	
		    din[9:8] == WRITE_DATA;
		else  
			din[9:8] == WRITE_ADDR;
	}

	//read operation only 
	constraint din_read_op_c {
		
		if (old_din == READ_ADDR && writeAddress_done_flag)	
		    din[9:8] == READ_DATA;
		else  
			din[9:8] == READ_ADDR;
	}

	//write and read operations  
	constraint din_write_read_op_c {
		din_not_writedata inside  {Not_write_data};
		din_not_readdata  inside  {Not_read_data};
		
		if (old_din == WRITE_ADDR) 
			din[9:8] dist {WRITE_DATA:= 80,  din_not_writedata := 20};
		else if (old_din == READ_ADDR) 
			din[9:8] dist {READ_DATA := 80,  din_not_readdata := 20};
		else 
			din[9:8] dist {WRITE_ADDR := 40, READ_ADDR := 40, READ_DATA := 10, WRITE_DATA := 10};
	}
	//RAM_6
	constraint rx_valid_c {
		rx_valid dist {1:= RX_VALID_ON_DIST, 0:= 100 - RX_VALID_ON_DIST};
	}

///////////////////////// Functions ////////////////////////////
function void post_randomize ();
	old_din = din [9:8];
	
	if(old_din == WRITE_ADDR || old_din == READ_ADDR)
	    writeAddress_done_flag = 1;
	else
		writeAddress_done_flag = 0;
endfunction 

function new(string name = "RAM_seq_item");
	super.new(name);	
endfunction

function string convert2string();
	return $sformatf("%s rst_n = 0b%0b, rx_valid = 0b%0b, din = 0b%0b, tx_valid = 0b%0b, dout = 0b%0b",
					  super.convert2string(), rst_n, rx_valid, din, tx_valid, dout);
endfunction

function string convert2string_stimulus();
	return $sformatf("rst_n = 0b%0b, rx_valid = 0b%0b, din = 0b%0b",rst_n, rx_valid, din);
endfunction

endclass : RAM_seq_item

endpackage : RAM_seq_item_pkg