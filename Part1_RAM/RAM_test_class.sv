package RAM_test_pkg;

import RAM_sequence_pkg::*;
import RAM_config_obj_pkg::*;
import RAM_env_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class RAM_test extends uvm_test;
`uvm_component_utils(RAM_test);

RAM_env env;
RAM_config_obj RAM_config_obj_test;
RAM_main_sequence main_seq;
RAM_reset_sequence reset_seq;

function new(string name = "RAM_test",uvm_component parent = null);
	super.new(name,parent);	
endfunction


function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	env = RAM_env::type_id::create("env",this);
	RAM_config_obj_test = RAM_config_obj::type_id::create("RAM_config_obj_test",this);
	main_seq = RAM_main_sequence::type_id::create("main_seq",this);
	reset_seq = RAM_reset_sequence::type_id::create("reset_seq",this);

	if(!uvm_config_db #(virtual RAM_if)::get(this, "", "RAM_IF", RAM_config_obj_test.RAM_config_vif))
		`uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the RAM from the uvm_config_db");

	if(!uvm_config_db #(virtual RAM_if)::get(this, "", "RAM_REF_IF", RAM_config_obj_test.RAM_REF_vif))
		`uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the RAM_REF_MODEL from the uvm_config_db");

	uvm_config_db #(RAM_config_obj)::set(this, "*", "RAM_CFG", RAM_config_obj_test);
endfunction : build_phase


function void start_of_simulation_phase (uvm_phase phase);
	super.start_of_simulation_phase (phase);
	uvm_root::get().print_topology();
endfunction

task run_phase(uvm_phase phase);
	
	super.run_phase(phase);
	phase.raise_objection(this);
	
	//reset sequence
	`uvm_info("run_phase", "Reset Asserted", UVM_LOW)
	reset_seq.start(env.agt.sqr);
	`uvm_info("run_phase", "Reset Deasserted", UVM_LOW)

	//main sequence
	`uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW)
	main_seq.start(env.agt.sqr);
	`uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW)

	phase.drop_objection(this);
	
endtask : run_phase
	
endclass : RAM_test	
endpackage : RAM_test_pkg