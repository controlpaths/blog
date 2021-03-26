# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NUM_AXIS_CHANNELS" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "MACADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IPADDR1" -parent ${Page_0} -show_range false
  ipgui::add_param $IPINST -name "IPADDR2" -parent ${Page_0} -show_range false
  ipgui::add_param $IPINST -name "IPADDR3" -parent ${Page_0} -show_range false
  ipgui::add_param $IPINST -name "IPADDR4" -parent ${Page_0} -show_range false
  ipgui::add_param $IPINST -name "UDP_DSTPORT_FORCH1" -parent ${Page_0} -show_range false
  ipgui::add_param $IPINST -name "UDP_DSTPORT_FORCH2" -parent ${Page_0} -show_range false
  ipgui::add_param $IPINST -name "UDP_DSTPORT_FORCH3" -parent ${Page_0} -show_range false
  ipgui::add_param $IPINST -name "UDP_DSTPORT_FORCH4" -parent ${Page_0} -show_range false
  ipgui::add_param $IPINST -name "UDP_DSTPORT_FORCH5" -parent ${Page_0} -show_range false
  ipgui::add_param $IPINST -name "UDP_DSTPORT_FORCH6" -parent ${Page_0} -show_range false
  ipgui::add_param $IPINST -name "UDP_DSTPORT_FORCH7" -parent ${Page_0} -show_range false
  ipgui::add_param $IPINST -name "UDP_DSTPORT_FORCH8" -parent ${Page_0} -show_range false


}

proc update_PARAM_VALUE.IPADDR1 { PARAM_VALUE.IPADDR1 } {
	# Procedure called to update IPADDR1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IPADDR1 { PARAM_VALUE.IPADDR1 } {
	# Procedure called to validate IPADDR1
	return true
}

proc update_PARAM_VALUE.IPADDR2 { PARAM_VALUE.IPADDR2 } {
	# Procedure called to update IPADDR2 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IPADDR2 { PARAM_VALUE.IPADDR2 } {
	# Procedure called to validate IPADDR2
	return true
}

proc update_PARAM_VALUE.IPADDR3 { PARAM_VALUE.IPADDR3 } {
	# Procedure called to update IPADDR3 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IPADDR3 { PARAM_VALUE.IPADDR3 } {
	# Procedure called to validate IPADDR3
	return true
}

proc update_PARAM_VALUE.IPADDR4 { PARAM_VALUE.IPADDR4 } {
	# Procedure called to update IPADDR4 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IPADDR4 { PARAM_VALUE.IPADDR4 } {
	# Procedure called to validate IPADDR4
	return true
}

proc update_PARAM_VALUE.MACADDR { PARAM_VALUE.MACADDR } {
	# Procedure called to update MACADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MACADDR { PARAM_VALUE.MACADDR } {
	# Procedure called to validate MACADDR
	return true
}

proc update_PARAM_VALUE.NUM_AXIS_CHANNELS { PARAM_VALUE.NUM_AXIS_CHANNELS } {
	# Procedure called to update NUM_AXIS_CHANNELS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_AXIS_CHANNELS { PARAM_VALUE.NUM_AXIS_CHANNELS } {
	# Procedure called to validate NUM_AXIS_CHANNELS
	return true
}

proc update_PARAM_VALUE.UDP_DSTPORT_FORCH1 { PARAM_VALUE.UDP_DSTPORT_FORCH1 } {
	# Procedure called to update UDP_DSTPORT_FORCH1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UDP_DSTPORT_FORCH1 { PARAM_VALUE.UDP_DSTPORT_FORCH1 } {
	# Procedure called to validate UDP_DSTPORT_FORCH1
	return true
}

proc update_PARAM_VALUE.UDP_DSTPORT_FORCH2 { PARAM_VALUE.UDP_DSTPORT_FORCH2 } {
	# Procedure called to update UDP_DSTPORT_FORCH2 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UDP_DSTPORT_FORCH2 { PARAM_VALUE.UDP_DSTPORT_FORCH2 } {
	# Procedure called to validate UDP_DSTPORT_FORCH2
	return true
}

proc update_PARAM_VALUE.UDP_DSTPORT_FORCH3 { PARAM_VALUE.UDP_DSTPORT_FORCH3 } {
	# Procedure called to update UDP_DSTPORT_FORCH3 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UDP_DSTPORT_FORCH3 { PARAM_VALUE.UDP_DSTPORT_FORCH3 } {
	# Procedure called to validate UDP_DSTPORT_FORCH3
	return true
}

proc update_PARAM_VALUE.UDP_DSTPORT_FORCH4 { PARAM_VALUE.UDP_DSTPORT_FORCH4 } {
	# Procedure called to update UDP_DSTPORT_FORCH4 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UDP_DSTPORT_FORCH4 { PARAM_VALUE.UDP_DSTPORT_FORCH4 } {
	# Procedure called to validate UDP_DSTPORT_FORCH4
	return true
}

proc update_PARAM_VALUE.UDP_DSTPORT_FORCH5 { PARAM_VALUE.UDP_DSTPORT_FORCH5 } {
	# Procedure called to update UDP_DSTPORT_FORCH5 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UDP_DSTPORT_FORCH5 { PARAM_VALUE.UDP_DSTPORT_FORCH5 } {
	# Procedure called to validate UDP_DSTPORT_FORCH5
	return true
}

proc update_PARAM_VALUE.UDP_DSTPORT_FORCH6 { PARAM_VALUE.UDP_DSTPORT_FORCH6 } {
	# Procedure called to update UDP_DSTPORT_FORCH6 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UDP_DSTPORT_FORCH6 { PARAM_VALUE.UDP_DSTPORT_FORCH6 } {
	# Procedure called to validate UDP_DSTPORT_FORCH6
	return true
}

proc update_PARAM_VALUE.UDP_DSTPORT_FORCH7 { PARAM_VALUE.UDP_DSTPORT_FORCH7 } {
	# Procedure called to update UDP_DSTPORT_FORCH7 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UDP_DSTPORT_FORCH7 { PARAM_VALUE.UDP_DSTPORT_FORCH7 } {
	# Procedure called to validate UDP_DSTPORT_FORCH7
	return true
}

proc update_PARAM_VALUE.UDP_DSTPORT_FORCH8 { PARAM_VALUE.UDP_DSTPORT_FORCH8 } {
	# Procedure called to update UDP_DSTPORT_FORCH8 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UDP_DSTPORT_FORCH8 { PARAM_VALUE.UDP_DSTPORT_FORCH8 } {
	# Procedure called to validate UDP_DSTPORT_FORCH8
	return true
}


proc update_MODELPARAM_VALUE.UDP_DSTPORT_FORCH1 { MODELPARAM_VALUE.UDP_DSTPORT_FORCH1 PARAM_VALUE.UDP_DSTPORT_FORCH1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UDP_DSTPORT_FORCH1}] ${MODELPARAM_VALUE.UDP_DSTPORT_FORCH1}
}

proc update_MODELPARAM_VALUE.UDP_DSTPORT_FORCH2 { MODELPARAM_VALUE.UDP_DSTPORT_FORCH2 PARAM_VALUE.UDP_DSTPORT_FORCH2 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UDP_DSTPORT_FORCH2}] ${MODELPARAM_VALUE.UDP_DSTPORT_FORCH2}
}

proc update_MODELPARAM_VALUE.UDP_DSTPORT_FORCH3 { MODELPARAM_VALUE.UDP_DSTPORT_FORCH3 PARAM_VALUE.UDP_DSTPORT_FORCH3 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UDP_DSTPORT_FORCH3}] ${MODELPARAM_VALUE.UDP_DSTPORT_FORCH3}
}

proc update_MODELPARAM_VALUE.UDP_DSTPORT_FORCH4 { MODELPARAM_VALUE.UDP_DSTPORT_FORCH4 PARAM_VALUE.UDP_DSTPORT_FORCH4 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UDP_DSTPORT_FORCH4}] ${MODELPARAM_VALUE.UDP_DSTPORT_FORCH4}
}

proc update_MODELPARAM_VALUE.UDP_DSTPORT_FORCH5 { MODELPARAM_VALUE.UDP_DSTPORT_FORCH5 PARAM_VALUE.UDP_DSTPORT_FORCH5 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UDP_DSTPORT_FORCH5}] ${MODELPARAM_VALUE.UDP_DSTPORT_FORCH5}
}

proc update_MODELPARAM_VALUE.UDP_DSTPORT_FORCH6 { MODELPARAM_VALUE.UDP_DSTPORT_FORCH6 PARAM_VALUE.UDP_DSTPORT_FORCH6 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UDP_DSTPORT_FORCH6}] ${MODELPARAM_VALUE.UDP_DSTPORT_FORCH6}
}

proc update_MODELPARAM_VALUE.UDP_DSTPORT_FORCH7 { MODELPARAM_VALUE.UDP_DSTPORT_FORCH7 PARAM_VALUE.UDP_DSTPORT_FORCH7 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UDP_DSTPORT_FORCH7}] ${MODELPARAM_VALUE.UDP_DSTPORT_FORCH7}
}

proc update_MODELPARAM_VALUE.MACADDR { MODELPARAM_VALUE.MACADDR PARAM_VALUE.MACADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MACADDR}] ${MODELPARAM_VALUE.MACADDR}
}

proc update_MODELPARAM_VALUE.NUM_AXIS_CHANNELS { MODELPARAM_VALUE.NUM_AXIS_CHANNELS PARAM_VALUE.NUM_AXIS_CHANNELS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_AXIS_CHANNELS}] ${MODELPARAM_VALUE.NUM_AXIS_CHANNELS}
}

proc update_MODELPARAM_VALUE.IPADDR1 { MODELPARAM_VALUE.IPADDR1 PARAM_VALUE.IPADDR1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IPADDR1}] ${MODELPARAM_VALUE.IPADDR1}
}

proc update_MODELPARAM_VALUE.IPADDR2 { MODELPARAM_VALUE.IPADDR2 PARAM_VALUE.IPADDR2 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IPADDR2}] ${MODELPARAM_VALUE.IPADDR2}
}

proc update_MODELPARAM_VALUE.IPADDR3 { MODELPARAM_VALUE.IPADDR3 PARAM_VALUE.IPADDR3 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IPADDR3}] ${MODELPARAM_VALUE.IPADDR3}
}

proc update_MODELPARAM_VALUE.IPADDR4 { MODELPARAM_VALUE.IPADDR4 PARAM_VALUE.IPADDR4 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IPADDR4}] ${MODELPARAM_VALUE.IPADDR4}
}

proc update_MODELPARAM_VALUE.UDP_DSTPORT_FORCH8 { MODELPARAM_VALUE.UDP_DSTPORT_FORCH8 PARAM_VALUE.UDP_DSTPORT_FORCH8 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UDP_DSTPORT_FORCH8}] ${MODELPARAM_VALUE.UDP_DSTPORT_FORCH8}
}

