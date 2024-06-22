module SPI_WRAPPER (MOSI,MISO,SS_n,clk,rst_n);

input MOSI,SS_n,clk,rst_n;
output MISO;

wire [9:0] rx_data_din;
wire rx_valid, tx_valid;
wire [7:0] tx_data_dout;

slave         s1 (MISO, MOSI, SS_n, clk, rst_n, rx_data_din, rx_valid, tx_data_dout, tx_valid);
Dual_port_RAM R1 (clk, rst_n, rx_valid, rx_data_din, tx_data_dout, tx_valid);

endmodule