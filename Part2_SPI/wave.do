onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group DUT_if /top/S_if/clk
add wave -noupdate -expand -group DUT_if /top/S_if/MOSI
add wave -noupdate -expand -group DUT_if /top/S_if/SS_n
add wave -noupdate -expand -group DUT_if /top/S_if/rst_n
add wave -noupdate -expand -group DUT_if /top/S_if/MISO
add wave -noupdate -expand -group REF_if /top/SPI_REF_if/clk
add wave -noupdate -expand -group REF_if /top/SPI_REF_if/MOSI
add wave -noupdate -expand -group REF_if /top/SPI_REF_if/SS_n
add wave -noupdate -expand -group REF_if /top/SPI_REF_if/rst_n
add wave -noupdate -expand -group REF_if /top/SPI_REF_if/MISO
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {119687 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 209
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {119606 ns} {120023 ns}
