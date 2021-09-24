
restore xilinx-project:
	cd D:/WORK/afe7700_xilinx
	source D:/WORK/afe7700_xilinx/restore_project.tcl
	import


AFE7700 programming:
	- program fpga by jtag - https://git.npp-crts.ru/fpga/afe7700_xilinx/tree/master/firmware
	- reset AFE7700
	- LATTE:
		- setup.py
		- devinit.py
	        - ti_functions.py
		- shubin_tcas.py
		- program fpga или сброс jesd phy fpga
		- forceSync(1),forceSync(0)
	- TX QMC correction
	        - connect LPF to the cable, create loop from TX to FB1  
		- doTxIqmc.py , where type particular TX channel
	        - check result by the spectrum analiser
	- hardware configuration:
		- сброс питания
		- setup.py
		- devInit.py
		- sequencer_custom.py
		- shubin_conf_script.py
	        - сброс fpga phy jesd  (SW14 on the  ZCU102)
		- forceSync(1),forceSync(0)