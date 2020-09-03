transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/1153814/Desktop/Raytheon/assignments/AB_Switch_PWB_redesign_plan_(FoS-2_program)/de10_signal_generator/signal_generator.vhd}

