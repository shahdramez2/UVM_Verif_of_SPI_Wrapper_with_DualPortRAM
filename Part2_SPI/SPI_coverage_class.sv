package SPI_coverage_pkg;

import SPI_seq_item_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class SPI_coverage extends uvm_component;
`uvm_component_utils(SPI_coverage);

SPI_seq_item cov_seq_item;

uvm_analysis_export   #(SPI_seq_item) cov_export;
uvm_tlm_analysis_fifo #(SPI_seq_item) cov_fifo; 

bit [7:0] write_address, read_address;
	
	//////////////////////// Cover group ////////////////////////////////
	covergroup SPI_cvg_gp;
		counter_cp: coverpoint cov_seq_item.counter iff (cov_seq_item.rst_n && ~cov_seq_item.SS_n) {
			bins counter_trans_bin = (2 => 3 => 4);
			option.weight = 0;
		}
		
		MOSI_cp: coverpoint cov_seq_item.MOSI iff (cov_seq_item.rst_n && ~cov_seq_item.SS_n) {
			bins MOSI_write_addr_trans_bin = (0 => 0 => 0);
			bins MOSI_write_data_trans_bin = (0 => 0 => 1);
			bins MOSI_read_addr_trans_bin  = (1 => 1 => 0);
			bins MOSI_read_data_trans_bin  = (1 => 1 => 1);
			option.weight = 0;
		}
		//SPI_3
		operations_cross: cross counter_cp, MOSI_cp;
		/////////////////////////////////////////////
		//SPI_3
		no_op_cp: coverpoint cov_seq_item.counter iff (~cov_seq_item.rst_n || cov_seq_item.SS_n) {
			bins counter_idle_bin = {0};
		}
		
		counter23_cp: coverpoint cov_seq_item.counter iff (cov_seq_item.rst_n && ~cov_seq_item.SS_n) {
			bins counter_trans_bin = (2 => 3);
			option.weight = 0;
		}
		
		MOSI_cp_2: coverpoint cov_seq_item.MOSI iff (~cov_seq_item.rst_n && ~cov_seq_item.SS_n) {
			bins write_trans_illegal = (0 => 1);
			bins read_trans_illegal  = (1 => 0);
			option.weight = 0;
		}
		//SPI_3
		illegal_trans_cross: cross counter23_cp, MOSI_cp_2 {
			illegal_bins write_op_ign = binsof (MOSI_cp_2.write_trans_illegal) && binsof (counter23_cp);
			illegal_bins read_op_ign  = binsof (MOSI_cp_2.read_trans_illegal)  && binsof (counter23_cp);
		}
		//SPI_4
		//////////////////////////////////////////////
		rd_flag_cp: coverpoint cov_seq_item.rd_addr_done iff(cov_seq_item.rst_n) {
			bins rd_addr_done_trans_HtoL = (1 => 0);
			bins rd_addr_done_trans_LtoH = (0 => 1);
		}
		//SPI_4
		wr_flag_cp: coverpoint cov_seq_item.wr_addr_done iff(cov_seq_item.rst_n) {
			bins wr_addr_done_trans_HtoL = (1 => 0);
			bins wr_addr_done_trans_LtoH = (0 => 1);
		}
		
		/////////////////////////////////////////////
		//SPI_1
		MISO_rst_cp: coverpoint cov_seq_item.MISO iff (~cov_seq_item.rst_n) {
			bins low_MISO_rst          = {0};
			illegal_bins high_MISO_rst = {1};
		}
	endgroup


function new(string name = "SPI_coverage",uvm_component parent = null);
	super.new(name,parent);
	SPI_cvg_gp = new();
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	cov_export = new("cov_export", this);
	cov_fifo = new("cov_fifo", this);
endfunction : build_phase

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	cov_export.connect(cov_fifo.analysis_export);
endfunction : connect_phase


task run_phase(uvm_phase phase);
	super.run_phase(phase);
	forever begin
	
	cov_fifo.get(cov_seq_item);
		SPI_cvg_gp.sample();
	end
	
endtask : run_phase

endclass : SPI_coverage

endpackage : SPI_coverage_pkg