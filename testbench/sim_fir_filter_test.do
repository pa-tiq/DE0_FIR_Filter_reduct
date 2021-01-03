vcom -reportprogress 300 -work work C:/Users/patiq/Documents/Projects/DE0_FIR_Filter_reduct/testbench/tb_fir_filter_test.vhd
vcom -reportprogress 300 -work work C:/Users/patiq/Documents/Projects/DE0_FIR_Filter_reduct/fir_filter_test.vhd
vcom -reportprogress 300 -work work C:/Users/patiq/Documents/Projects/DE0_FIR_Filter_reduct/fir_filter.vhd

vcom  -work work ../fir_filter.vhd
vcom  -work work ../fir_filter_test.vhd

vcom -work work -O0 ./tb_fir_filter_test.vhd

vsim work.tb_fir_filter_test -novopt -t ns

do wave_fir_filter_test.do
