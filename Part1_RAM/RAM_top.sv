import RAM_test_pkg::*;
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

	RAM_if  R_if 	    (clk);
	RAM_if  RAM_REF_if  (clk);
	Dual_port_RAM  DUT  (R_if.din, R_if.clk, R_if.rst_n, R_if.rx_valid, R_if.tx_valid, R_if.dout);
	SPI_RAM    RAM_REF  (RAM_REF_if.din, RAM_REF_if.clk, RAM_REF_if.rst_n, RAM_REF_if.rx_valid, RAM_REF_if.tx_valid, RAM_REF_if.dout);
	bind Dual_port_RAM RAM_sva RAM_sva_inst(R_if.DUT);

	assign RAM_REF_if.din 	   = R_if.din;
	assign RAM_REF_if.rst_n    = R_if.rst_n;
	assign RAM_REF_if.rx_valid = R_if.rx_valid;
	
	initial begin
		uvm_config_db #(virtual RAM_if)::set(null, "uvm_test_top", "RAM_IF", R_if);
		uvm_config_db #(virtual RAM_if)::set(null, "uvm_test_top", "RAM_REF_IF", RAM_REF_if);
		run_test("RAM_test");
	end

endmodule