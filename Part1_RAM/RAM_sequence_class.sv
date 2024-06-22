package RAM_sequence_pkg;

import RAM_seq_item_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class RAM_reset_sequence extends uvm_sequence #(RAM_seq_item);
`uvm_object_utils(RAM_reset_sequence);

RAM_seq_item seq_item;

function new(string name = "RAM_reset_sequence");
	super.new(name);	
endfunction

task body;
seq_item = RAM_seq_item::type_id::create("seq_item");
start_item(seq_item);
seq_item.rst_n    = 0;
seq_item.din   	  = 0;
seq_item.rx_valid = 0;
finish_item(seq_item);
endtask : body	

endclass : RAM_reset_sequence

class RAM_main_sequence extends uvm_sequence #(RAM_seq_item);
`uvm_object_utils(RAM_main_sequence);

RAM_seq_item seq_item;

function new(string name = "RAM_main_sequence");
	super.new(name);	
endfunction

task body;
//write only sequence
seq_item = RAM_seq_item::type_id::create("seq_item"); 
seq_item.rst_n.rand_mode(0); //to avoid resetting memory content (clear_locations) throughout writing data.
seq_item.rst_n = 1'b1;
seq_item.din_read_op_c.constraint_mode(0);
seq_item.din_write_read_op_c.constraint_mode(0);

repeat(2500) begin
	start_item(seq_item);
	a_write_only_seq : assert(seq_item.randomize());
	finish_item(seq_item);
end

//read only sequence
seq_item = RAM_seq_item::type_id::create("seq_item");
seq_item.rst_n.rand_mode(0); //to avoid resetting memory content (clear_locations) throughout reading data.
seq_item.rst_n = 1'b1;
seq_item.din_write_op_c.constraint_mode(0);
seq_item.din_write_read_op_c.constraint_mode(0);
repeat(2500) begin
	start_item(seq_item);
	a_read_only_seq : assert(seq_item.randomize());
	finish_item(seq_item);
end

//write and read sequence
seq_item = RAM_seq_item::type_id::create("seq_item");
seq_item.din_read_op_c.constraint_mode(0);
seq_item.din_write_op_c.constraint_mode(0);
repeat(4000) begin
	start_item(seq_item);
	a_write_read_seq : assert(seq_item.randomize());
	finish_item(seq_item);
end

endtask : body	
endclass : RAM_main_sequence
endpackage : RAM_sequence_pkg