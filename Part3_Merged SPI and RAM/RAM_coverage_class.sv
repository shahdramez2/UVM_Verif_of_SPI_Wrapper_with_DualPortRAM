package RAM_coverage_pkg;

import RAM_seq_item_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class RAM_coverage extends uvm_component;
`uvm_component_utils(RAM_coverage);

RAM_seq_item cov_seq_item;

uvm_analysis_export   #(RAM_seq_item) cov_export;
uvm_tlm_analysis_fifo #(RAM_seq_item) cov_fifo; 

bit [7:0] write_address, read_address;
	
	//////////////////////// Cover group ////////////////
	covergroup RAM_cvg_gp;
		tx_valid_cp: coverpoint cov_seq_item.tx_valid {
			//option.weight = 0;
		}
		
		//RAM_1
		rst_n_cp: coverpoint cov_seq_item.rst_n {
			bins activated_rst_n = {0};
		}
		
		//RAM_2, RAM_3
		addr_write_cp: coverpoint write_address iff(cov_seq_item.rst_n && cov_seq_item.rx_valid && cov_seq_item.din[9:8] == WRITE_DATA) {
			option.auto_bin_max = 256;
		}


		//RAM_4, RAM_5
		addr_read_cp:  coverpoint read_address  iff(cov_seq_item.rst_n && cov_seq_item.rx_valid && cov_seq_item.din[9:8] == READ_DATA){
			option.auto_bin_max = 256;
		}
		
		//RAM_3, RAM_5
		din_2MSB_transitions_cp:  coverpoint cov_seq_item.din[9:8] iff (cov_seq_item.rst_n && cov_seq_item.rx_valid) {
			bins read_trans  = (READ_ADDR  => READ_DATA);
			bins write_trans = (WRITE_ADDR => WRITE_DATA);
		}    
		
		//RAM_2, RAM_3, RAM_4, RAM_5
		din_2MSB_cpp:  coverpoint cov_seq_item.din[9:8] iff (cov_seq_item.rst_n && cov_seq_item.rx_valid);  
		
		
		din_2MSB_cp:  coverpoint cov_seq_item.din[9:8] iff (cov_seq_item.rst_n) {
			option.weight = 0;
		}
		
		//RAM_5
		tx_valid_cross:	cross tx_valid_cp, din_2MSB_cp iff (cov_seq_item.rst_n) {
				ignore_bins low_tx_valid_ign =  binsof (tx_valid_cp)  intersect {0};
				ignore_bins not_read_ign     =  binsof (tx_valid_cp)  intersect {1}  && !binsof(din_2MSB_cp)  intersect {READ_DATA}; 
				bins tx_valid_readdata 		 =  binsof (tx_valid_cp)  intersect {1} &&  binsof (din_2MSB_cp) intersect {READ_DATA};
			}	
	endgroup


	function new(string name = "RAM_coverage",uvm_component parent = null);
		super.new(name,parent);
		RAM_cvg_gp = new();
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		cov_export = new("cov_export", this);
		cov_fifo = new("cov_fifo", this);
	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		cov_export.connect(cov_fifo.analysis_export);
	endfunction : connect_phase


	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
		
		cov_fifo.get(cov_seq_item);
		
		if (cov_seq_item.rx_valid && cov_seq_item.rst_n) begin
			if (cov_seq_item.din[9:8] == WRITE_ADDR)
				write_address = cov_seq_item.din[7:0];
			else if (cov_seq_item.din[9:8] == READ_ADDR)
				read_address = cov_seq_item.din[7:0];
		end

			RAM_cvg_gp.sample();
		end
	endtask : run_phase

endclass : RAM_coverage

endpackage : RAM_coverage_pkg