package RAM_config_obj_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

class RAM_config_obj extends uvm_object;
`uvm_object_utils(RAM_config_obj);

virtual RAM_if RAM_config_vif;
virtual RAM_if RAM_REF_vif;

function new(string name = "RAM_config_obj");
	super.new (name);	
endfunction


endclass : RAM_config_obj

endpackage : RAM_config_obj_pkg