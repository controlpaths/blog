
################################################################
# This is a generated script based on design: fir_eclypse_bd
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source fir_eclypse_bd_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# axis_decimator_v1_0, axis_zmod_adc_v1_0, axis_zmod_dac_v1_0

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg484-1
   set_property BOARD_PART digilentinc.com:eclypse-z7:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name fir_eclypse_bd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:fir_compiler:7.2\
xilinx.com:ip:util_ds_buf:2.1\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlslice:1.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
axis_decimator_v1_0\
axis_zmod_adc_v1_0\
axis_zmod_dac_v1_0\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: tdata_management
proc create_hier_cell_tdata_management { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_tdata_management() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -from 63 -to 0 Din
  create_bd_pin -dir O -from 31 -to 0 dout

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {63} \
   CONFIG.DIN_TO {48} \
   CONFIG.DIN_WIDTH {64} \
   CONFIG.DOUT_WIDTH {16} \
 ] $xlslice_0

  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {31} \
   CONFIG.DIN_TO {16} \
   CONFIG.DIN_WIDTH {64} \
   CONFIG.DOUT_WIDTH {16} \
 ] $xlslice_1

  # Create port connections
  connect_bd_net -net fir_compiler_0_m_axis_data_tdata [get_bd_pins Din] [get_bd_pins xlslice_0/Din] [get_bd_pins xlslice_1/Din]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins dout] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins xlconcat_0/In0] [get_bd_pins xlslice_0/Dout]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins xlconcat_0/In1] [get_bd_pins xlslice_1/Dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set adc_clkout_n [ create_bd_port -dir O -from 0 -to 0 -type clk adc_clkout_n ]
  set adc_clkout_p [ create_bd_port -dir O -from 0 -to 0 -type clk adc_clkout_p ]
  set adc_cs [ create_bd_port -dir O adc_cs ]
  set adc_data [ create_bd_port -dir I -from 13 -to 0 adc_data ]
  set adc_dclkio [ create_bd_port -dir I -type clk -freq_hz 100000000 adc_dclkio ]
  set adc_sck [ create_bd_port -dir O adc_sck ]
  set adc_sdio [ create_bd_port -dir O adc_sdio ]
  set adc_sync [ create_bd_port -dir O adc_sync ]
  set dac_clkout [ create_bd_port -dir O -from 0 -to 0 -type clk dac_clkout ]
  set dac_cs [ create_bd_port -dir O dac_cs ]
  set dac_data [ create_bd_port -dir O -from 13 -to 0 dac_data ]
  set dac_dclkio [ create_bd_port -dir O -type clk dac_dclkio ]
  set dac_fsadji [ create_bd_port -dir O -from 0 -to 0 dac_fsadji ]
  set dac_fsadjq [ create_bd_port -dir O -from 0 -to 0 dac_fsadjq ]
  set dac_oenable [ create_bd_port -dir O -from 0 -to 0 dac_oenable ]
  set dac_rst [ create_bd_port -dir O dac_rst ]
  set dac_sck [ create_bd_port -dir O dac_sck ]
  set dac_sdio [ create_bd_port -dir O dac_sdio ]
  set sys_clock [ create_bd_port -dir I -type clk -freq_hz 125000000 sys_clock ]
  set_property -dict [ list \
   CONFIG.PHASE {0.000} \
 ] $sys_clock
  set zmod_adc_com_h [ create_bd_port -dir O -from 0 -to 0 zmod_adc_com_h ]
  set zmod_adc_com_l [ create_bd_port -dir O -from 0 -to 0 zmod_adc_com_l ]
  set zmod_adc_coupling_h_a [ create_bd_port -dir O -from 0 -to 0 zmod_adc_coupling_h_a ]
  set zmod_adc_coupling_h_b [ create_bd_port -dir O -from 0 -to 0 zmod_adc_coupling_h_b ]
  set zmod_adc_coupling_l_a [ create_bd_port -dir O -from 0 -to 0 zmod_adc_coupling_l_a ]
  set zmod_adc_coupling_l_b [ create_bd_port -dir O -from 0 -to 0 zmod_adc_coupling_l_b ]
  set zmod_adc_gain_h_a [ create_bd_port -dir O -from 0 -to 0 zmod_adc_gain_h_a ]
  set zmod_adc_gain_h_b [ create_bd_port -dir O -from 0 -to 0 zmod_adc_gain_h_b ]
  set zmod_adc_gain_l_a [ create_bd_port -dir O -from 0 -to 0 zmod_adc_gain_l_a ]
  set zmod_adc_gain_l_b [ create_bd_port -dir O -from 0 -to 0 zmod_adc_gain_l_b ]

  # Create instance: axis_decimator_v1_0_0, and set properties
  set block_name axis_decimator_v1_0
  set block_cell_name axis_decimator_v1_0_0
  if { [catch {set axis_decimator_v1_0_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_decimator_v1_0_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axis_zmod_adc_v1_0_0, and set properties
  set block_name axis_zmod_adc_v1_0
  set block_cell_name axis_zmod_adc_v1_0_0
  if { [catch {set axis_zmod_adc_v1_0_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_zmod_adc_v1_0_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axis_zmod_dac_v1_0_0, and set properties
  set block_name axis_zmod_dac_v1_0
  set block_cell_name axis_zmod_dac_v1_0_0
  if { [catch {set axis_zmod_dac_v1_0_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_zmod_dac_v1_0_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKOUT2_JITTER {109.241} \
   CONFIG.CLKOUT2_PHASE_ERROR {96.948} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200.000} \
   CONFIG.CLKOUT2_USED {false} \
   CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
   CONFIG.CLK_OUT1_PORT {clk100mhz} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {1} \
   CONFIG.USE_BOARD_FLOW {true} \
   CONFIG.USE_RESET {false} \
 ] $clk_wiz_0

  # Create instance: fir_compiler_0, and set properties
  set fir_compiler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_compiler_0 ]
  set_property -dict [ list \
   CONFIG.BestPrecision {false} \
   CONFIG.Channel_Sequence {Basic} \
   CONFIG.Clock_Frequency {100} \
   CONFIG.CoefficientSource {COE_File} \
   CONFIG.Coefficient_File {../../../../../../../../git/blog/fir_compiler/coe/fir47_fs10M.coe} \
   CONFIG.Coefficient_Fractional_Bits {0} \
   CONFIG.Coefficient_Sets {1} \
   CONFIG.Coefficient_Sign {Signed} \
   CONFIG.Coefficient_Structure {Symmetric} \
   CONFIG.Coefficient_Width {16} \
   CONFIG.ColumnConfig {3} \
   CONFIG.DATA_Has_TLAST {Not_Required} \
   CONFIG.Data_Fractional_Bits {0} \
   CONFIG.Data_Width {16} \
   CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
   CONFIG.M_DATA_Has_TUSER {Not_Required} \
   CONFIG.Number_Channels {1} \
   CONFIG.Number_Paths {2} \
   CONFIG.Output_Rounding_Mode {Full_Precision} \
   CONFIG.Output_Width {32} \
   CONFIG.Quantization {Integer_Coefficients} \
   CONFIG.S_DATA_Has_TUSER {Not_Required} \
   CONFIG.Sample_Frequency {10} \
   CONFIG.Select_Pattern {All} \
 ] $fir_compiler_0

  # Create instance: tdata_management
  create_hier_cell_tdata_management [current_bd_instance .] tdata_management

  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_0 ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {OBUFDS} \
 ] $util_ds_buf_0

  # Create instance: util_ds_buf_1, and set properties
  set util_ds_buf_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_1 ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {BUFG} \
 ] $util_ds_buf_1

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axis_decimator_v1_0_0_m_axis [get_bd_intf_pins axis_decimator_v1_0_0/m_axis] [get_bd_intf_pins fir_compiler_0/S_AXIS_DATA]
  connect_bd_intf_net -intf_net axis_zmod_adc_v1_0_0_m_axis [get_bd_intf_pins axis_decimator_v1_0_0/s_axis] [get_bd_intf_pins axis_zmod_adc_v1_0_0/m_axis]

  # Create port connections
  connect_bd_net -net adc_data_1 [get_bd_ports adc_data] [get_bd_pins axis_zmod_adc_v1_0_0/ddr_data]
  connect_bd_net -net adc_dclkio_1 [get_bd_ports adc_dclkio] [get_bd_pins util_ds_buf_1/BUFG_I]
  connect_bd_net -net axis_zmod_adc_v1_0_0_adc_sync [get_bd_ports adc_sync] [get_bd_pins axis_zmod_adc_v1_0_0/adc_sync]
  connect_bd_net -net axis_zmod_adc_v1_0_0_spi_cs [get_bd_ports adc_cs] [get_bd_pins axis_zmod_adc_v1_0_0/spi_cs]
  connect_bd_net -net axis_zmod_adc_v1_0_0_spi_sck [get_bd_ports adc_sck] [get_bd_pins axis_zmod_adc_v1_0_0/spi_sck]
  connect_bd_net -net axis_zmod_adc_v1_0_0_spi_sdio [get_bd_ports adc_sdio] [get_bd_pins axis_zmod_adc_v1_0_0/spi_sdio]
  connect_bd_net -net axis_zmod_dac_v1_0_0_ddr_clk [get_bd_ports dac_dclkio] [get_bd_pins axis_zmod_dac_v1_0_0/ddr_clk]
  connect_bd_net -net axis_zmod_dac_v1_0_0_ddr_data [get_bd_ports dac_data] [get_bd_pins axis_zmod_dac_v1_0_0/ddr_data]
  connect_bd_net -net axis_zmod_dac_v1_0_0_rst_spi [get_bd_ports dac_rst] [get_bd_pins axis_zmod_dac_v1_0_0/rst_spi]
  connect_bd_net -net axis_zmod_dac_v1_0_0_spi_cs [get_bd_ports dac_cs] [get_bd_pins axis_zmod_dac_v1_0_0/spi_cs]
  connect_bd_net -net axis_zmod_dac_v1_0_0_spi_sck [get_bd_ports dac_sck] [get_bd_pins axis_zmod_dac_v1_0_0/spi_sck]
  connect_bd_net -net axis_zmod_dac_v1_0_0_spi_sdo [get_bd_ports dac_sdio] [get_bd_pins axis_zmod_dac_v1_0_0/spi_sdo]
  connect_bd_net -net clk_wiz_0_clk100mhz [get_bd_ports dac_clkout] [get_bd_pins axis_decimator_v1_0_0/aclk] [get_bd_pins axis_zmod_adc_v1_0_0/aclk] [get_bd_pins axis_zmod_dac_v1_0_0/aclk] [get_bd_pins clk_wiz_0/clk100mhz] [get_bd_pins fir_compiler_0/aclk] [get_bd_pins util_ds_buf_0/OBUF_IN]
  connect_bd_net -net clk_wiz_0_locked [get_bd_pins axis_decimator_v1_0_0/resetn] [get_bd_pins axis_zmod_adc_v1_0_0/resetn] [get_bd_pins axis_zmod_dac_v1_0_0/resetn] [get_bd_pins clk_wiz_0/locked]
  connect_bd_net -net fir_compiler_0_m_axis_data_tdata [get_bd_pins fir_compiler_0/m_axis_data_tdata] [get_bd_pins tdata_management/Din]
  connect_bd_net -net fir_compiler_0_m_axis_data_tvalid [get_bd_pins axis_zmod_dac_v1_0_0/s_axis_tvalid] [get_bd_pins fir_compiler_0/m_axis_data_tvalid]
  connect_bd_net -net sys_clock_1 [get_bd_ports sys_clock] [get_bd_pins clk_wiz_0/clk_in1]
  connect_bd_net -net util_ds_buf_0_OBUF_DS_N [get_bd_ports adc_clkout_n] [get_bd_pins util_ds_buf_0/OBUF_DS_N]
  connect_bd_net -net util_ds_buf_0_OBUF_DS_P [get_bd_ports adc_clkout_p] [get_bd_pins util_ds_buf_0/OBUF_DS_P]
  connect_bd_net -net util_ds_buf_1_BUFG_O [get_bd_pins axis_zmod_adc_v1_0_0/ddr_clk] [get_bd_pins util_ds_buf_1/BUFG_O]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins axis_zmod_dac_v1_0_0/s_axis_tdata] [get_bd_pins tdata_management/dout]
  connect_bd_net -net xlconstant_0_dout [get_bd_ports zmod_adc_com_h] [get_bd_ports zmod_adc_coupling_h_a] [get_bd_ports zmod_adc_coupling_h_b] [get_bd_ports zmod_adc_gain_l_a] [get_bd_ports zmod_adc_gain_l_b] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_ports dac_fsadji] [get_bd_ports dac_fsadjq] [get_bd_ports dac_oenable] [get_bd_ports zmod_adc_com_l] [get_bd_ports zmod_adc_coupling_l_a] [get_bd_ports zmod_adc_coupling_l_b] [get_bd_ports zmod_adc_gain_h_a] [get_bd_ports zmod_adc_gain_h_b] [get_bd_pins xlconstant_1/dout]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


