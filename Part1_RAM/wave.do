onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group DUT_if /top/R_if/clk
add wave -noupdate -expand -group DUT_if /top/R_if/din
add wave -noupdate -expand -group DUT_if /top/R_if/rst_n
add wave -noupdate -expand -group DUT_if /top/R_if/rx_valid
add wave -noupdate -expand -group DUT_if /top/R_if/tx_valid
add wave -noupdate -expand -group DUT_if /top/R_if/dout
add wave -noupdate -expand -group REF_if /top/RAM_REF_if/clk
add wave -noupdate -expand -group REF_if /top/RAM_REF_if/din
add wave -noupdate -expand -group REF_if /top/RAM_REF_if/rst_n
add wave -noupdate -expand -group REF_if /top/RAM_REF_if/rx_valid
add wave -noupdate -expand -group REF_if /top/RAM_REF_if/tx_valid
add wave -noupdate -expand -group REF_if /top/RAM_REF_if/dout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9719 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 225
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
WaveRestoreZoom {9521 ns} {10475 ns}
