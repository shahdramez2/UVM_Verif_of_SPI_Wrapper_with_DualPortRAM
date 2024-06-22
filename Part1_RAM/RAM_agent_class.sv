package RAM_agent_pkg;

import RAM_sequencer_pkg::*;
import RAM_driver_pkg::*;
import RAM_monitor_pkg::*;
import RAM_config_obj_pkg::*;
import RAM_seq_item_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

class RAM_agent extends uvm_agent;
`uvm_component_utils(RAM_agent);

uvm_analysis_port #(RAM_seq_item) agt_ap;

RAM_sequencer sqr;
RAM_driver driver;
RAM_monitor mon;
RAM_config_obj RAM_cfg;

function new(string name = "RAM_agent",uvm_component parent = null);
	super.new(name,parent);	
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(RAM_config_obj)::get(this, "", "RAM_CFG", RAM_cfg))
		`uvm_fatal("build_phase", "agent - Unable to get the virtual interface of the RAM from the uvm_config_db");
	sqr = RAM_sequencer::type_id::create("sqr",this);
	driver  = RAM_driver::type_id::create("driver",this);
	mon = RAM_monitor::type_id::create("mon",this);
	agt_ap = new("agt_ap", this);
endfunction : build_phase

function void connect_phase(uvm_phase phase);
	driver.RAM_driver_vif = RAM_cfg.RAM_config_vif;
	mon.RAM_mon_vif       = RAM_cfg.RAM_config_vif;
	driver.seq_item_port.connect(sqr.seq_item_export);
	mon.mon_ap.connect(agt_ap);
endfunction : connect_phase

endclass : RAM_agent
endpackage : RAM_agent_pkg