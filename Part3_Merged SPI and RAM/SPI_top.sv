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

	RAM_if  R_if       (clk);
	RAM_if  RAM_REF_if (clk);
	SPI_if  S_if 	   (clk);
	SPI_if  SPI_REF_if (clk);
	SPI_WRAPPER  DUT   (S_if.MOSI, S_if.MISO, S_if.SS_n, S_if.clk, S_if.rst_n);
	SPI_WRAPPER_ref  SPI_REF (SPI_REF_if.MOSI, SPI_REF_if.MISO, SPI_REF_if.SS_n, SPI_REF_if.clk, SPI_REF_if.rst_n);
	RAM_SPI    RAM_REF  (RAM_REF_if.din, RAM_REF_if.clk, RAM_REF_if.rst_n, RAM_REF_if.rx_valid, RAM_REF_if.tx_valid, RAM_REF_if.dout);

	bind SPI_WRAPPER SPI_sva SPI_sva_inst(S_if.DUT);
	bind Dual_port_RAM RAM_sva RAM_sva_inst(R_if.DUT);
	
	// ref SPI interface
	assign SPI_REF_if.rst_n = S_if.rst_n;
	assign SPI_REF_if.SS_n  = S_if.SS_n;
	assign SPI_REF_if.MOSI  = S_if.MOSI;
	
	// ref RAM interface
	assign RAM_REF_if.din 	   = R_if.din;
	assign RAM_REF_if.rst_n    = R_if.rst_n;
	assign RAM_REF_if.rx_valid = R_if.rx_valid;

	//assign SPI inputs to RAM inputs.
	assign R_if.rst_n 	 = S_if.rst_n;
	assign R_if.rx_valid = DUT.rx_valid;
	assign R_if.din      = DUT.rx_data_din;
	assign R_if.tx_valid = DUT.tx_valid;
	assign R_if.dout     = DUT.tx_data_dout;

	initial begin
		uvm_config_db #(virtual SPI_if)::set(null, "uvm_test_top", "SPI_IF", S_if);
		uvm_config_db #(virtual SPI_if)::set(null, "uvm_test_top", "SPI_REF_IF", SPI_REF_if);
		uvm_config_db #(virtual RAM_if)::set(null, "uvm_test_top", "RAM_IF", R_if);
		uvm_config_db #(virtual RAM_if)::set(null, "uvm_test_top", "RAM_REF_IF", RAM_REF_if);
		run_test("SPI_test");
	end

endmodule