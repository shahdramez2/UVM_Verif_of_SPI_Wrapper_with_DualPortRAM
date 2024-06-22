module Dual_port_RAM(din, clk ,rst_n, rx_valid , tx_valid, dout);

parameter MEM_DEPTH=256;
parameter ADDR_SIZE=8;
input clk, rst_n, rx_valid;
input [9:0] din;
output  reg tx_valid;
output reg [ADDR_SIZE-1:0] dout; 

reg [ADDR_SIZE-1:0] mem [MEM_DEPTH-1:0];
reg [ADDR_SIZE-1:0] write_addr,read_addr;
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		dout<=8'b0000_0000;
		tx_valid=0;
		write_addr <= 0;
		read_addr  <= 0;
		
		for (int i = 0; i< MEM_DEPTH; i=i+1) begin
			mem [i] <= 0;
		end
	end
	else begin			
		if(rx_valid==1)begin
			if(din[9]==0)begin
				if(din[8]==0)begin
					write_addr<=din[7:0];           
					tx_valid<=0;
				end
				else begin
					mem[write_addr]<=din[7:0];          
					tx_valid<=0;
				end
			end

			if(din[9]==1)begin
				if (din[8]==0) begin
					read_addr<= din[7:0];
					tx_valid<=0;
				end
				else begin
					dout[7:0]<= mem[read_addr];
					tx_valid<=1;
				end
			end
		end
		else begin
			tx_valid <= 0;
		end
	end		 	
end



`ifdef SIM
	//RAM_1
	always_comb begin
		if (!rst_n) begin
		a_rst_dout:		assert final (dout     === 0);
		a_rst_txvalid:	assert final (tx_valid === 0);
		end
	end

	//RAM_2
	property write_adr_pr;
		@(posedge clk) disable iff (~rst_n) (rx_valid && din[9:8] == 2'b00) |=> (write_addr == $past(din[7:0]) );
	endproperty
	a_write_adr_pr: assert property (write_adr_pr);
	c_write_adr_pr: cover  property (write_adr_pr);
	
	//RAM_3
	property write_data_pr;
		@(posedge clk) disable iff (~rst_n) (rx_valid && din[9:8] == 2'b01) |=> (mem[write_addr] === $past(din[7:0]) );
	endproperty
	a_write_data_pr: assert property (write_data_pr);
	c_write_data_pr: cover  property (write_data_pr);
	
	//RAM_4
	property read_adr_pr;
		@(posedge clk) disable iff (~rst_n) (rx_valid && din[9:8] == 2'b10) |=> (read_addr === $past(din[7:0]) );
	endproperty
	a_read_adr_pr: assert property (read_adr_pr);
	c_read_adr_pr: cover  property (read_adr_pr);
	
	//RAM_5
	property read_data_pr;
		@(posedge clk) disable iff (~rst_n) (rx_valid && din[9:8] == 2'b11) |=> (dout === mem[read_addr]);
	endproperty
	a_read_data_pr: assert property (read_data_pr);
	c_read_data_pr: cover  property (read_data_pr);
	
	//RAM_5
	property high_tx_valid_pr;
		@(posedge clk) disable iff (~rst_n) (rx_valid && din[9:8] == 2'b11) |=> (tx_valid);
	endproperty
	a_high_tx_valid_pr: assert property (high_tx_valid_pr);
	c_high_tx_valid_pr: cover  property (high_tx_valid_pr);
	
	//RAM_2, RAM_3, RAM_4
	property low_tx_valid_pr;
		@(posedge clk) disable iff (~rst_n) (rx_valid && din[9:8] != 2'b11) |=> (~tx_valid);
	endproperty
	a_low_tx_valid_pr: assert property (low_tx_valid_pr);
	c_low_tx_valid_pr: cover  property (low_tx_valid_pr);
	
	//RAM_6
	property low_rxvalid_stable_writeaddr_pr;
		@(posedge clk) disable iff (~rst_n) (~rx_valid) |=> (write_addr === $past(write_addr));
	endproperty
	a_low_rxvalid_stable_writeaddr_pr: assert property (low_rxvalid_stable_writeaddr_pr);
	c_low_rxvalid_stable_writeaddr_pr: cover  property (low_rxvalid_stable_writeaddr_pr);

	//RAM_6
	property low_rxvalid_stable_readaddr_pr;
		@(posedge clk) disable iff (~rst_n) (~rx_valid) |=> (read_addr === $past(read_addr));
	endproperty
	a_low_rxvalid_stable_readaddr_pr: assert property (low_rxvalid_stable_readaddr_pr);
	c_low_rxvalid_stable_readaddr_pr: cover  property (low_rxvalid_stable_readaddr_pr);

	//RAM_6
	property low_rxvalid_stable_dout_pr;
		@(posedge clk) disable iff (~rst_n) (~rx_valid) |=> (dout === $past(dout));
	endproperty
	a_low_rxvalid_stable_dout_pr: assert property (low_rxvalid_stable_dout_pr);
	c_low_rxvalid_stable_dout_pr: cover  property (low_rxvalid_stable_dout_pr);

	//RAM_6
	property low_rxvalid_low_txvalid_pr;
		@(posedge clk) disable iff (~rst_n) (~rx_valid) |=> (tx_valid === 0);
	endproperty
	a_low_rxvalid_low_txvalid_pr: assert property (low_rxvalid_low_txvalid_pr);
	c_low_rxvalid_low_txvalid_pr: cover  property (low_rxvalid_low_txvalid_pr);
`endif

endmodule