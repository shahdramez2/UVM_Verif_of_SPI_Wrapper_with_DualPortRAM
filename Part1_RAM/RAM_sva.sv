module RAM_sva(RAM_if.DUT R_if);

typedef enum bit [1:0] {WRITE_ADDR = 2'b00, WRITE_DATA = 2'b01, READ_ADDR = 2'b10, READ_DATA = 2'b11} ram_e;

always_comb begin

	if(!R_if.rst_n) begin
		a_rst_dout:     assert final (R_if.dout     == 0);
		a_rst_tx_valid: assert final (R_if.tx_valid == 0);
	end
end

property tx_valid_pr;
	@(posedge R_if.clk) disable iff(!R_if.rst_n) (R_if.din[9:8] == READ_DATA && R_if.rx_valid) |=> R_if.tx_valid; 
endproperty


a_tx_valid_pr: assert property (tx_valid_pr);
c_tx_valid_pr: cover  property (tx_valid_pr);

endmodule : RAM_sva	