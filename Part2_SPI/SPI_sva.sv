module SPI_sva(SPI_if.DUT S_if);
//SPI_1
always_comb begin
	if (~S_if.rst_n)
		assert final (~S_if.MISO);
end

endmodule 	