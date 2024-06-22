module slave(MISO,MOSI,SS_n,clk,rst_n,rx_data,rx_valid,tx_data,tx_valid);

parameter IDLE     =3'b000;
parameter CHK_CMD  =3'b001;
parameter WRITE    =3'b010;
parameter READ_ADD =3'b011;
parameter READ_DATA=3'b100;

input MOSI,SS_n,clk,rst_n,tx_valid;
input [7:0]tx_data;

output  reg MISO ,rx_valid;
output  reg [9:0]  rx_data;


reg read_ad_flag = 0;//if 1 the check command will go to the read adress if Zero the heya aret l adress yeb2a hya hatkteb now
reg [3:0] counter_tx;
reg [3:0] counter_rx;
reg [9:0] bus_rx;


bit sending_flag;

reg [2:0] cs,ns;
//next state logic
always @(SS_n,cs,MOSI) begin //ask sensityvityy listttttt?????????
	case(cs)
	IDLE: if (SS_n==0)  begin 
	        ns=CHK_CMD;
		  end 
		  else begin
		     ns=IDLE;
		  end

	CHK_CMD: if(SS_n==1) begin
				ns=IDLE;
			end
			else if (MOSI==0) begin//mosi her the first bit to checkk
			         ns =WRITE;
		    end
		    else  begin
				if(read_ad_flag == 0) begin 
					 ns=READ_ADD;
				end
				else begin
					 ns=READ_DATA;
				end	   
		    end

	WRITE:  if (SS_n==0) //askkkkkkk
	           ns = WRITE;
		      else 
		         ns = IDLE;

	READ_ADD:  
			if(SS_n==1)
				ns=IDLE;
			else begin //kont hatet tx w shiltha fl condition
				ns=READ_ADD;
				//read_ad_flag = 1; 	       	   	
			end

    READ_DATA: 
			if (SS_n==1) //kont hatet tx fl condotion
				ns=IDLE;
			else begin
				ns=READ_DATA;
 				//read_ad_flag = 0;
 			end	
    
    default: ns=IDLE;

      endcase
 end

 //state memory
 always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		cs<=IDLE;
	end

	else begin
		cs<=ns;
	end
end 


//output logic
always @(posedge clk or negedge rst_n) begin

	if(!rst_n) begin
		MISO <= 0;
		read_ad_flag <= 0;
		sending_flag <= 0;
		counter_tx   <=4'b1000;
		counter_rx   <=4'b1010;
		rx_valid 		 <=0;
		bus_rx			 <=0;
		rx_data 		 <=0;

	end 

	else begin 
		case (cs)
			IDLE: begin
			 MISO 				<= 0;
			 counter_tx   <=4'b1000;
			 counter_rx   <=4'b1010;
			 rx_valid     <=0;
			 sending_flag <=0;
			 bus_rx				<=0;
			 rx_data 			<=0;
			 end
			
	        WRITE:
			if (counter_rx==0) begin//from serial to parralel
	     		rx_valid    <=1;
	     		rx_data     <=bus_rx;
	     		counter_rx  <=4'b1010;
	        end

	        else begin
		   		bus_rx[counter_rx-1] <= MOSI;
		    	counter_rx <= counter_rx-1;
		 	end
			
		    READ_ADD:

			if (counter_rx==0) begin//from serial to parralel
	     		rx_valid   <=1;
	     		rx_data    <=bus_rx;
	     		counter_rx <=4'b1010;
				
				read_ad_flag <= 1'b1;
	        end

	        else begin
		   		bus_rx[counter_rx-1] <= MOSI;
		    	counter_rx           <= counter_rx-1;
		 	end

			READ_DATA: begin

				if (tx_valid==1) begin
					sending_flag = 1'b1;
					rx_valid     = 1'b0;
				end


				if (sending_flag) begin
						if (counter_tx==0) begin   //from parralel to serial	
							counter_tx <= 4'b1000;
							MISO <=0;
							
							read_ad_flag <= 1'b0;
						end
						else begin
							MISO       <= tx_data[counter_tx-1];
							counter_tx <= counter_tx-1;
						end
				end
				else begin
				
						MISO <= 0;
					
						if (counter_rx==0) begin  //from serial to parralel
			     		rx_valid 	 <=1;
			     		rx_data  	 <=bus_rx;
							counter_rx <= 4'b1010;
			      end

		        else if (~rx_valid) begin
				   		bus_rx[counter_rx-1] <= MOSI;
				    	counter_rx           <= counter_rx-1;
			 	end
				else 
					rx_valid <= 0;
					
				end
			end

			default: 
				MISO <= 0;

	    endcase    
	end //else
end        						//end of always block



`ifdef SIM
	//SPI_6
	property op_done_pr;
			@(posedge clk) disable iff (~rst_n) ((counter_rx == 0 && cs != IDLE) |=> (rx_valid && (rx_data === bus_rx)) );
	endproperty

	a_op_done_pr : assert property (op_done_pr);
	c_op_done_pr : cover  property (op_done_pr);


	//SPI_6
	property reading_MOSI_pr;
			@(posedge clk) disable iff (~rst_n || SS_n || sending_flag || rx_valid) ((counter_rx != 0)&&(cs != CHK_CMD) && (cs != IDLE) ) |=> 
																 (bus_rx[$past(counter_rx) - 1] == $past(MOSI) );
	endproperty

	a_reading_MOSI_pr : assert property (reading_MOSI_pr);
	c_reading_MOSI_pr : cover  property (reading_MOSI_pr);

	//SPI_7
	property inactive_MISO_pr;
			@(posedge clk) disable iff (~rst_n) (counter_tx == 0) |=> ~MISO;
	endproperty

	a_inactive_MISO_pr : assert property (inactive_MISO_pr);
	c_inactive_MISO_pr : cover  property (inactive_MISO_pr);


	//SPI_7
	property active_MISO_pr;
			@(posedge clk) disable iff (~rst_n) (counter_tx != 0 && cs == READ_DATA && sending_flag) |=> (MISO === tx_data [$past(counter_tx) -1]);
	endproperty

	a_active_MISO_pr : assert property (active_MISO_pr);
	c_active_MISO_pr : cover  property (active_MISO_pr);

	//SPI_4
	property read_ad_flag_on_pr;
			@(posedge clk) disable iff (~rst_n) (counter_rx == 0 && (cs == READ_ADD)) |=> read_ad_flag; 
	endproperty

	a_read_ad_flag_on_pr : assert property (read_ad_flag_on_pr);
	c_read_ad_flag_on_pr : cover  property (read_ad_flag_on_pr);

	//SPI_4
	property read_ad_flag_off_pr;
			@(posedge clk) disable iff (~rst_n) (counter_tx == 0 && (cs == READ_DATA)) |=> ~read_ad_flag; 
	endproperty

	a_read_ad_flag_off_pr : assert property (read_ad_flag_off_pr);
	c_read_ad_flag_off_pr : cover  property (read_ad_flag_off_pr);

	//receiving correct data
	//SPI_3
	property rxdata_read_addr_pr;
		@(posedge clk) disable iff (~rst_n) (counter_rx == 0 && cs == READ_ADD) |=> (rx_data[9:8] == 2'b10);
	endproperty
	
	a_rxdata_read_addr_pr : assert property (rxdata_read_addr_pr);
	c_rxdata_read_addr_pr : cover  property (rxdata_read_addr_pr);

	//SPI_3
	property rxdata_read_data_pr;
		@(posedge clk) disable iff (~rst_n) (counter_rx == 0 && cs == READ_DATA) |=> (rx_data[9:8] == 2'b11);
	endproperty
	
	a_rxdata_read_data_pr : assert property (rxdata_read_data_pr);
	c_rxdata_read_data_pr : cover  property (rxdata_read_data_pr);
	
	//SPI_3
	property rxdata_write_pr;
		@(posedge clk) disable iff (~rst_n) (counter_rx == 0 && cs == WRITE) |=> (rx_data[9:8] == 2'b00 || rx_data[9:8] == 2'b01);
	endproperty
	
	a_rxdata_write_pr : assert property (rxdata_write_pr);
	c_rxdata_write_pr : cover  property (rxdata_write_pr);
	
	//SPI_2
	property SS_n_pr;
			@(posedge clk) disable iff (~rst_n) (SS_n |=> cs == IDLE);
	endproperty

	//SPI_1
	always_comb begin
		if (~rst_n) begin
			a_rst_MISO:		  assert final (~MISO);
			a_rst_rxvalid:  assert final (~rx_valid);
		end		
	end

`endif


endmodule