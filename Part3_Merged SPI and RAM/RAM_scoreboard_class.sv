package RAM_scoreboard_pkg;

import RAM_seq_item_pkg::*;
import RAM_config_obj_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

class RAM_scoreboard extends uvm_scoreboard;
`uvm_component_utils(RAM_scoreboard);

uvm_analysis_export   #(RAM_seq_item) sb_export;
uvm_tlm_analysis_fifo #(RAM_seq_item) sb_fifo; 

RAM_config_obj RAM_config_obj_sb;
RAM_seq_item sb_seq_item;
virtual RAM_if sb_REF_vif; 

int error_count,correct_count;

function new(string name = "RAM_scoreboard",uvm_component parent = null);
	super.new(name,parent);	
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	sb_export = new("sb_export", this);
	sb_fifo = new("sb_fifo", this);
  RAM_config_obj_sb = RAM_config_obj::type_id::create("RAM_config_obj_sb",this);

  if(!uvm_config_db #(RAM_config_obj)::get(this, "", "RAM_CFG", RAM_config_obj_sb))
    `uvm_fatal("build_phase", "RAM_Scoreboard - Unable to get the RAM_CFG from the uvm_config_db.");


endfunction : build_phase

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	sb_export.connect(sb_fifo.analysis_export);
  sb_REF_vif = RAM_config_obj_sb.RAM_REF_vif;
endfunction : connect_phase


task run_phase(uvm_phase phase);
	super.run_phase(phase);
	forever begin
		sb_fifo.get(sb_seq_item);

		if (sb_seq_item.dout !== sb_REF_vif.dout || sb_seq_item.tx_valid !== sb_REF_vif.tx_valid) begin
			`uvm_error("run_phase", $sformatf("Comparison failed, Transiction recieved by the DUT:%s  while the reference dout:0b%b .. tx_valid:0b%b",
								 sb_seq_item.convert2string(), sb_REF_vif.dout, sb_REF_vif.tx_valid));
			error_count++;
		end
		else begin
			`uvm_info("run_phase",$sformatf("Correct RAM out: %s ", sb_seq_item.convert2string()), UVM_HIGH);
			correct_count++;
		end	
	end
	
endtask : run_phase


function void report_phase(uvm_phase phase);
	super.report_phase(phase);
	`uvm_info("report_phase",$sformatf("Total successful transictions: %0d", correct_count), UVM_MEDIUM);
	`uvm_info("report_phase",$sformatf("Total failed transictions: %0d", error_count), UVM_MEDIUM);
endfunction : report_phase

endclass : RAM_scoreboard

endpackage : RAM_scoreboard_pkg