vlib work

vlog ../../rtl/dsp_library/dds_signal_generator.v
vlog ../../rtl/tcas_dmsp/rounding.v
vlog ../../rtl/tcas_dmsp/ddc_dmsp_125.v
vlog ../../rtl/tcas_dmsp/cic_filter_5st.v
vlog ../../rtl/tcas_dmsp/cic_filter_stage.v
vlog ../../rtl/tcas_dmsp/complex_mult.v
vlog ../../rtl/tcas_dmsp/fir_filter_23.v
vlog ../../rtl/tcas_dmsp/mag_complex.v
vlog ../../rtl/tcas_dmsp/mag_complex_stage.v


vlog tcas_dmsp_tb.v


vsim -voptargs=+acc work.tcas_dmsp_tb

add wave sim:/tcas_dmsp_tb/*
add wave sim:/tcas_dmsp_tb/mag_complex_inst/*

run 100 us



