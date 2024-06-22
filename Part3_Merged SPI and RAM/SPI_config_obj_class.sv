package SPI_config_obj_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

class SPI_config_obj extends uvm_object;
`uvm_object_utils(SPI_config_obj);

uvm_active_passive_enum active;

virtual SPI_if SPI_config_vif;
virtual SPI_if SPI_REF_vif;

function new(string name = "SPI_config_obj");
	super.new (name);	
endfunction


endclass : SPI_config_obj

endpackage : SPI_config_obj_pkg