package SPI_test_pkg;

import SPI_sequence_pkg::*;
import SPI_config_obj_pkg::*;
import SPI_env_pkg::*;
import RAM_env_pkg::*;
import RAM_config_obj_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"

class SPI_test extends uvm_test;
`uvm_component_utils(SPI_test);

SPI_env spi_env;
RAM_env ram_env;

SPI_config_obj SPI_config_obj_test;
RAM_config_obj RAM_config_obj_test;

SPI_main_sequence main_seq;
SPI_reset_sequence reset_seq;

function new(string name = "SPI_test",uvm_component parent = null);
	super.new(name,parent);	
endfunction


function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	spi_env = SPI_env::type_id::create("spi_env",this);
	ram_env = RAM_env::type_id::create("ram_env",this);

	SPI_config_obj_test = SPI_config_obj::type_id::create("SPI_config_obj_test",this);
	RAM_config_obj_test = RAM_config_obj::type_id::create("RAM_config_obj_test",this);
	
	main_seq = SPI_main_sequence::type_id::create("main_seq",this);
	reset_seq = SPI_reset_sequence::type_id::create("reset_seq",this);

	if(!uvm_config_db #(virtual SPI_if)::get(this, "", "SPI_IF", SPI_config_obj_test.SPI_config_vif))
		`uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the SPI from the uvm_config_db");

	if(!uvm_config_db #(virtual SPI_if)::get(this, "", "SPI_REF_IF", SPI_config_obj_test.SPI_REF_vif))
		`uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the SPI_REF_MODEL from the uvm_config_db");

	if(!uvm_config_db #(virtual RAM_if)::get(this, "", "RAM_IF", RAM_config_obj_test.RAM_config_vif))
		`uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the SPI from the uvm_config_db");

	if(!uvm_config_db #(virtual RAM_if)::get(this, "", "RAM_REF_IF", RAM_config_obj_test.RAM_REF_vif))
		`uvm_fatal("build_phase", "Test - Unable to get the virtual interface of the SPI_REF_MODEL from the uvm_config_db");

	SPI_config_obj_test.active = UVM_ACTIVE;
	RAM_config_obj_test.active = UVM_PASSIVE;

	uvm_config_db #(SPI_config_obj)::set(this, "spi_env*", "SPI_CFG", SPI_config_obj_test);
	uvm_config_db #(RAM_config_obj)::set(this, "ram_env*", "RAM_CFG", RAM_config_obj_test);

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
	reset_seq.start(spi_env.agt.sqr);
	`uvm_info("run_phase", "Reset Deasserted", UVM_LOW)

	//main sequence
	`uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW)
	main_seq.start(spi_env.agt.sqr);
	`uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW)

	phase.drop_objection(this);
	
endtask : run_phase
	
endclass : SPI_test	
endpackage : SPI_test_pkg