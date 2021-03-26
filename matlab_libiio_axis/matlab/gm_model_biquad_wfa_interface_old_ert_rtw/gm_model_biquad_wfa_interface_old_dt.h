/*
 * gm_model_biquad_wfa_interface_old_dt.h
 *
 * Trial License - for use to evaluate programs for possible purchase as
 * an end-user only.
 *
 * Code generation for model "gm_model_biquad_wfa_interface_old".
 *
 * Model version              : 1.27
 * Simulink Coder version : 9.4 (R2020b) 29-Jul-2020
 * C source code generated on : Sun Mar 21 00:25:24 2021
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: ARM Compatible->ARM Cortex
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "ext_types.h"

/* data type size table */
static uint_T rtDataTypeSizes[] = {
  sizeof(real_T),
  sizeof(real32_T),
  sizeof(int8_T),
  sizeof(uint8_T),
  sizeof(int16_T),
  sizeof(uint16_T),
  sizeof(int32_T),
  sizeof(uint32_T),
  sizeof(boolean_T),
  sizeof(fcn_call_T),
  sizeof(int_T),
  sizeof(pointer_T),
  sizeof(action_T),
  2*sizeof(uint32_T),
  sizeof(int32_T),
  sizeof(matlabshared_libiio_axistream_T),
  sizeof(matlabshared_libiio_axistre_m_T),
  sizeof(zynq_AXIWrite_gm_model_biquad_T)
};

/* data type name table */
static const char_T * rtDataTypeNames[] = {
  "real_T",
  "real32_T",
  "int8_T",
  "uint8_T",
  "int16_T",
  "uint16_T",
  "int32_T",
  "uint32_T",
  "boolean_T",
  "fcn_call_T",
  "int_T",
  "pointer_T",
  "action_T",
  "timer_uint32_pair_T",
  "int32_T",
  "matlabshared_libiio_axistream_T",
  "matlabshared_libiio_axistre_m_T",
  "zynq_AXIWrite_gm_model_biquad_T"
};

/* data type transitions for block I/O structure */
static DataTypeTransition rtBTransitions[] = {
  { (char_T *)(&gm_model_biquad_wfa_interface_B.DataTypeConversion3[0]), 0, 0,
    96 },

  { (char_T *)(&gm_model_biquad_wfa_interface_B.AXI4StreamIIORead_o1[0]), 7, 0,
    32 },

  { (char_T *)(&gm_model_biquad_wfa_interface_B.AXI_Read_y_out_DTC[0]), 14, 0,
    32 }
  ,

  { (char_T *)(&gm_model_biquad_wfa_interfac_DW.obj), 15, 0, 1 },

  { (char_T *)(&gm_model_biquad_wfa_interfac_DW.obj_o), 16, 0, 1 },

  { (char_T *)(&gm_model_biquad_wfa_interfac_DW.obj_b), 17, 0, 2 },

  { (char_T *)(&gm_model_biquad_wfa_interfac_DW.ToWorkspace_PWORK.LoggedData),
    11, 0, 6 },

  { (char_T *)(&gm_model_biquad_wfa_interfac_DW.FromWorkspace_IWORK.PrevIndex),
    10, 0, 1 }
};

/* data type transition table for block I/O structure */
static DataTypeTransitionTable rtBTransTable = {
  8U,
  rtBTransitions
};

/* data type transitions for Parameters structure */
static DataTypeTransition rtPTransitions[] = {
  { (char_T *)(&gm_model_biquad_wfa_interface_P.in_cos), 14, 0, 2 }
};

/* data type transition table for Parameters structure */
static DataTypeTransitionTable rtPTransTable = {
  1U,
  rtPTransitions
};

/* [EOF] gm_model_biquad_wfa_interface_old_dt.h */
