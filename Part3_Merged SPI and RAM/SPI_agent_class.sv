package SPI_agent_pkg;

import SPI_sequencer_pkg::*;
import SPI_driver_pkg::*;
import SPI_monitor_pkg::*;
import SPI_config_obj_pkg::*;
import SPI_seq_item_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

class SPI_agent extends uvm_agent;
`uvm_component_utils(SPI_agent);

uvm_analysis_port #(SPI_seq_item) agt_ap;

SPI_sequencer sqr;
SPI_driver driver;
SPI_monitor mon;
SPI_config_obj SPI_cfg;

function new(string name = "SPI_agent",uvm_component parent = null);
	super.new(name,parent);	
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(SPI_config_obj)::get(this, "", "SPI_CFG", SPI_cfg))
		`uvm_fatal("build_phase", "agent - Unable to get the virtual interface of the SPI from the uvm_config_db");
	
	if(SPI_cfg.active == UVM_ACTIVE) begin
		sqr = SPI_sequencer::type_id::create("sqr",this);
		driver  = SPI_driver::type_id::create("driver",this);
	end
	mon = SPI_monitor::type_id::create("mon",this);
	agt_ap = new("agt_ap", this);
endfunction : build_phase

function void connect_phase(uvm_phase phase);
	if(SPI_cfg.active == UVM_ACTIVE) begin
		driver.SPI_driver_vif = SPI_cfg.SPI_config_vif;
		driver.seq_item_port.connect(sqr.seq_item_export);
	end

	mon.SPI_mon_vif = SPI_cfg.SPI_config_vif;
	mon.mon_ap.connect(agt_ap);
endfunction : connect_phase

endclass : SPI_agent
endpackage : SPI_agent_pkg