vlib work
vlog +define+SIM -f src_files.list +cover
vsim -voptargs=+acc work.top -classdebug -uvmcontrol=all +UVM_NO_RELNOTES -cover +UVM_VERBOSITY=UVM_MEDIUM
run 0
do wave.do
coverage save top.ucdb -onexit -du SPI_WRAPPER
run -all
##quit -sim
##vcover report top.ucdb -details -annotate -all -output CODE_coverageFile.txt