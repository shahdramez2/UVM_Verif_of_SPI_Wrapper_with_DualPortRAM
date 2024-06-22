import SPI_test_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module top();

	localparam Tclk = 2;

	bit clk;

	////////////////////// clock generation /////////////////
	initial begin
		clk = 1'b0;
		forever #(Tclk/2) clk = ~clk;
	end

	SPI_if           S_if 	    (clk);
	SPI_if           SPI_REF_if (clk);
	SPI_WRAPPER      DUT     (S_if.MOSI, S_if.MISO, S_if.SS_n, clk, S_if.rst_n);
	SPI_WRAPPER_ref  SPI_REF (SPI_REF_if.MOSI, SPI_REF_if.MISO, SPI_REF_if.SS_n, clk, SPI_REF_if.rst_n);
	
	bind SPI_WRAPPER SPI_sva SPI_sva_inst(S_if.DUT);

	assign SPI_REF_if.rst_n = S_if.rst_n;
	assign SPI_REF_if.SS_n  = S_if.SS_n;
	assign SPI_REF_if.MOSI  = S_if.MOSI;
	
	initial begin
		uvm_config_db #(virtual SPI_if)::set(null, "uvm_test_top", "SPI_IF", S_if);
		uvm_config_db #(virtual SPI_if)::set(null, "uvm_test_top", "SPI_REF_IF", SPI_REF_if);
		run_test("SPI_test");
	end

endmodule