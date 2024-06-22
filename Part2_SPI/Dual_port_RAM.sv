module Dual_port_RAM(clk, rst_n, rx_valid, din, dout, tx_valid);

parameter MEM_DEPTH=256;
parameter ADDR_SIZE=8;

input [9:0] din;
input clk,rst_n,rx_valid;
output reg tx_valid;
output reg [7:0] dout;

reg [ADDR_SIZE-1:0] mem [MEM_DEPTH-1:0];
reg [ADDR_SIZE-1:0] write_adr,read_adr;

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		dout<=8'b0000_0000;
		tx_valid <= 0;
		write_adr <= 0;
		read_adr  <= 0;
		
		for (int i = 0; i< MEM_DEPTH; i=i+1) begin
			mem [i] <= 0;
		end
	end
	else if(rx_valid==1)begin
			if(din[9]==0)begin
				if(din[8]==0)begin
					write_adr<=din[7:0];           
					tx_valid<=0;
				end
				else begin
					mem[write_adr]<=din[7:0];          
					tx_valid<=0;
				end
			end

			if(din[9]==1)begin
				if (din[8]==0) begin
					read_adr<= din[7:0];
					tx_valid<=0;
				end
				else begin
					dout[7:0]<= mem[read_adr];
					tx_valid<=1;
				end
			end
	end	
    else begin
		tx_valid <= 1'b0;
	end
end

endmodule