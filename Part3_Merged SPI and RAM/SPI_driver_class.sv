package SPI_driver_pkg;

import SPI_seq_item_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class SPI_driver extends uvm_driver #(SPI_seq_item);
`uvm_component_utils(SPI_driver);

virtual SPI_if SPI_driver_vif; 
SPI_seq_item stim_seq_item;

function new(string name = "SPI_driver",uvm_component parent = null);
	super.new(name,parent);	
endfunction

task run_phase(uvm_phase phase);
	super.run_phase(phase);
	forever begin
		stim_seq_item = SPI_seq_item::type_id::create("stim_seq_item");
		seq_item_port.get_next_item(stim_seq_item);
		
		SPI_driver_vif.rst_n = stim_seq_item.rst_n;
		SPI_driver_vif.SS_n  = stim_seq_item.SS_n;
		SPI_driver_vif.MOSI  = stim_seq_item.MOSI;
		
		@(negedge SPI_driver_vif.clk);
		seq_item_port.item_done();
		`uvm_info("run_phase", stim_seq_item.convert2string_stimulus(), UVM_HIGH)
	end	
endtask : run_phase	
endclass : SPI_driver	
endpackage : SPI_driver_pkg