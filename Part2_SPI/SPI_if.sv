interface  SPI_if (input bit clk);
	
	bit MOSI;
	bit SS_n,rst_n;

	logic MISO;
		 
	modport DUT  (input MOSI,SS_n,clk,rst_n,
				  output  MISO );
endinterface