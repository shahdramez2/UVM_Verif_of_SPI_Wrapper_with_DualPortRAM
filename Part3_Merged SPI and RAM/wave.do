onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {SPI_warpper signals} /top/S_if/clk
add wave -noupdate -expand -group {SPI_warpper signals} /top/S_if/MISO
add wave -noupdate -expand -group {SPI_warpper signals} /top/S_if/MOSI
add wave -noupdate -expand -group {SPI_warpper signals} /top/S_if/rst_n
add wave -noupdate -expand -group {SPI_warpper signals} /top/S_if/SS_n
add wave -noupdate -expand -group {RAM signals} /top/R_if/clk
add wave -noupdate -expand -group {RAM signals} /top/R_if/din
add wave -noupdate -expand -group {RAM signals} /top/R_if/dout
add wave -noupdate -expand -group {RAM signals} /top/R_if/rst_n
add wave -noupdate -expand -group {RAM signals} /top/R_if/rx_valid
add wave -noupdate -expand -group {RAM signals} /top/R_if/tx_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2363 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 235
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {3945 ns} {4005 ns}
