package RAM_monitor_pkg;

import RAM_seq_item_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

class RAM_monitor extends uvm_monitor;
`uvm_component_utils(RAM_monitor);

virtual RAM_if RAM_mon_vif; 
RAM_seq_item rsp_seq_item;

uvm_analysis_port #(RAM_seq_item) mon_ap;

function new(string name = "RAM_monitor",uvm_component parent = null);
	super.new(name,parent);	
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	mon_ap = new("mon_ap", this);
endfunction : build_phase


task run_phase(uvm_phase phase);
	super.run_phase(phase);
	forever begin
		rsp_seq_item = RAM_seq_item::type_id::create("rsp_seq_item");
		@(negedge RAM_mon_vif.clk);

		// Sending the RAM sequence
	     rsp_seq_item.rst_n    = RAM_mon_vif.rst_n;
		 rsp_seq_item.rx_valid = RAM_mon_vif.rx_valid;
		 rsp_seq_item.din	   = RAM_mon_vif.din;
		 rsp_seq_item.tx_valid = RAM_mon_vif.tx_valid;
		 rsp_seq_item.dout     = RAM_mon_vif.dout;
		
		 mon_ap.write(rsp_seq_item);

		`uvm_info("run_phase", rsp_seq_item.convert2string(), UVM_HIGH)
	end
	
endtask : run_phase

endclass : RAM_monitor

endpackage : RAM_monitor_pkg