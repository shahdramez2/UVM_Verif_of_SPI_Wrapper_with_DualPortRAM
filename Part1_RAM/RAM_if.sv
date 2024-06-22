interface  RAM_if (input bit clk);

	parameter MEM_DEPTH=256;
	parameter ADDR_SIZE=8;
	
	bit [9:0]din;
	bit rst_n,rx_valid;
	logic tx_valid;
	logic [7:0]dout;
	 
	modport DUT (input din, clk, rst_n, rx_valid,
				  output  tx_valid, dout);
endinterface