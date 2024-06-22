package SPI_sequence_pkg;

import SPI_seq_item_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class SPI_reset_sequence extends uvm_sequence #(SPI_seq_item);
`uvm_object_utils(SPI_reset_sequence);

SPI_seq_item seq_item;

function new(string name = "SPI_reset_sequence");
	super.new(name);	
endfunction

task body;
seq_item = SPI_seq_item::type_id::create("seq_item");
start_item(seq_item);
seq_item.rst_n = 0;
seq_item.SS_n  = 0;
seq_item.MOSI  = 0;
finish_item(seq_item);
endtask : body	

endclass : SPI_reset_sequence

class SPI_main_sequence extends uvm_sequence #(SPI_seq_item);
`uvm_object_utils(SPI_main_sequence);

SPI_seq_item seq_item;

function new(string name = "SPI_main_sequence");
	super.new(name);	
endfunction

task body;

seq_item = SPI_seq_item::type_id::create("seq_item");
repeat(60000) begin 
	start_item(seq_item);
	a_write_only_seq : assert(seq_item.randomize());
	finish_item(seq_item);
end

endtask : body

endclass : SPI_main_sequence

endpackage : SPI_sequence_pkg