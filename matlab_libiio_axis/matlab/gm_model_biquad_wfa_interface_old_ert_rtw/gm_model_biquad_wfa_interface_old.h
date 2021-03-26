/*
 * Trial License - for use to evaluate programs for possible purchase as
 * an end-user only.
 *
 * File: gm_model_biquad_wfa_interface_old.h
 *
 * Code generated for Simulink model 'gm_model_biquad_wfa_interface_old'.
 *
 * Model version                  : 1.27
 * Simulink Coder version         : 9.4 (R2020b) 29-Jul-2020
 * C/C++ source code generated on : Sun Mar 21 00:25:24 2021
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: ARM Compatible->ARM Cortex
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef RTW_HEADER_gm_model_biquad_wfa_interface_old_h_
#define RTW_HEADER_gm_model_biquad_wfa_interface_old_h_
#include <math.h>
#include <string.h>
#include <float.h>
#include <stddef.h>
#ifndef gm_model_biquad_wfa_interface_old_COMMON_INCLUDES_
#define gm_model_biquad_wfa_interface_old_COMMON_INCLUDES_
#include <stdio.h>
#include "rtwtypes.h"
#include "rtw_extmode.h"
#include "sysran_types.h"
#include "dt_info.h"
#include "ext_work.h"
#include "iio.h"
#include "iio_helper.h"
#include "unistd.h"
#include "axi_lct.h"
#endif                  /* gm_model_biquad_wfa_interface_old_COMMON_INCLUDES_ */

#include "gm_model_biquad_wfa_interface_old_types.h"

/* Shared type includes */
#include "multiword_types.h"
#include "rt_nonfinite.h"
#include "rtGetInf.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetFinalTime
#define rtmGetFinalTime(rtm)           ((rtm)->Timing.tFinal)
#endif

#ifndef rtmGetRTWExtModeInfo
#define rtmGetRTWExtModeInfo(rtm)      ((rtm)->extModeInfo)
#endif

#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

#ifndef rtmGetStopRequested
#define rtmGetStopRequested(rtm)       ((rtm)->Timing.stopRequestedFlag)
#endif

#ifndef rtmSetStopRequested
#define rtmSetStopRequested(rtm, val)  ((rtm)->Timing.stopRequestedFlag = (val))
#endif

#ifndef rtmGetStopRequestedPtr
#define rtmGetStopRequestedPtr(rtm)    (&((rtm)->Timing.stopRequestedFlag))
#endif

#ifndef rtmGetT
#define rtmGetT(rtm)                   ((rtm)->Timing.taskTime0)
#endif

#ifndef rtmGetTFinal
#define rtmGetTFinal(rtm)              ((rtm)->Timing.tFinal)
#endif

#ifndef rtmGetTPtr
#define rtmGetTPtr(rtm)                (&(rtm)->Timing.taskTime0)
#endif

#define gm_model_biquad_wfa_interface_old_M (gm_model_biquad_wfa_interfac_M)

/* Block signals (default storage) */
typedef struct {
  real_T DataTypeConversion3[32];      /* '<Root>/Data Type Conversion3' */
  real_T FromWorkspace[32];            /* '<Root>/From Workspace' */
  real_T DataTypeConversion4[32];      /* '<Root>/Data Type Conversion4' */
  uint8_T b[129];
  uint8_T b_m[129];
  uint32_T AXI4StreamIIORead_o1[32];   /* '<S1>/AXI4-Stream IIO Read' */
  uint32_T AXI_Write_x_in_DTC[32];     /* '<S1>/AXI_Write_x_in_DTC' */
  int32_T AXI_Read_y_out_DTC[32];      /* '<S1>/AXI_Read_y_out_DTC' */
  int32_T DataTypeConversion2[32];     /* '<Root>/Data Type Conversion2' */
  uint8_T b_c[64];
  uint8_T b_k[57];
  uint8_T b_cx[57];
  uint8_T b_b[52];
  uint8_T b_p[52];
  uint8_T b_cv[44];
  uint8_T b_f[44];
  uint8_T b_g[43];
  uint8_T b_g1[43];
  uint8_T b_me[39];
  uint8_T b_n[39];
  uint8_T b_pp[37];
  uint8_T b_l[35];
  uint8_T b_j[35];
  uint8_T b_d[35];
  uint8_T b_gu[35];
  uint8_T b_ld[35];
  uint8_T b_dh[32];
  uint8_T b_dy[32];
  uint8_T b_lx[32];
  uint8_T strout[20];
  uint8_T strout_o[20];
  int32_T c[5];
  uint8_T strout_b[20];
  uint8_T strout_n[20];
  int32_T c_b[5];
  uint8_T b_ln[17];
  uint8_T b_h[16];
  uint8_T b_bn[16];
  char_T b_da[14];
  uint8_T b_e[11];
  uint8_T c_bj[10];
  struct iio_device* devPtr;
  struct iio_channel* chanPtr;
  ptrdiff_t ptrDiff;
  ssize_t ssizeT;
  ssize_t ssizeT_j;
  struct iio_channel* chanPtr_f;
  struct iio_device* devPtr_a;
  struct iio_channel* chanPtr_j;
  ptrdiff_t ptrDiff_j;
  struct iio_channel* chanPtr_o;
  uint8_T b_ny[7];
  uint8_T b_i[7];
  uint8_T b_o[6];
} B_gm_model_biquad_wfa_interfa_T;

/* Block states (default storage) for system '<Root>' */
typedef struct {
  matlabshared_libiio_axistream_T obj; /* '<S1>/AXI4-Stream IIO Read' */
  matlabshared_libiio_axistre_m_T obj_o;/* '<S1>/AXI4-Stream IIO Write' */
  zynq_AXIWrite_gm_model_biquad_T obj_b;/* '<S5>/AXI4-Interface Write' */
  zynq_AXIWrite_gm_model_biquad_T obj_l;/* '<S4>/AXI4-Interface Write' */
  struct {
    void *LoggedData;
  } ToWorkspace_PWORK;                 /* '<Root>/To Workspace' */

  struct {
    void *TimePtr;
    void *DataPtr;
    void *RSimInfoPtr;
  } FromWorkspace_PWORK;               /* '<Root>/From Workspace' */

  struct {
    void *LoggedData[2];
  } y_out_PWORK;                       /* '<Root>/y_out' */

  struct {
    void *LoggedData;
  } ToWorkspace1_PWORK;                /* '<Root>/To Workspace1' */

  struct {
    void *LoggedData;
  } Scope_PWORK;                       /* '<S1>/Scope' */

  struct {
    int_T PrevIndex;
  } FromWorkspace_IWORK;               /* '<Root>/From Workspace' */
} DW_gm_model_biquad_wfa_interf_T;

/* Parameters (default storage) */
struct P_gm_model_biquad_wfa_interfa_T_ {
  int32_T in_cos;                      /* Variable: in_cos
                                        * Referenced by: '<Root>/Constant1'
                                        */
  int32_T Constant_Value;              /* Computed Parameter: Constant_Value
                                        * Referenced by: '<Root>/Constant'
                                        */
};

/* Real-time Model Data Structure */
struct tag_RTM_gm_model_biquad_wfa_i_T {
  const char_T *errorStatus;
  RTWExtModeInfo *extModeInfo;

  /*
   * Sizes:
   * The following substructure contains sizes information
   * for many of the model attributes such as inputs, outputs,
   * dwork, sample times, etc.
   */
  struct {
    uint32_T checksums[4];
  } Sizes;

  /*
   * SpecialInfo:
   * The following substructure contains special information
   * related to other components that are dependent on RTW.
   */
  struct {
    const void *mappingInfo;
  } SpecialInfo;

  /*
   * Timing:
   * The following substructure contains information regarding
   * the timing information for the model.
   */
  struct {
    time_T taskTime0;
    uint32_T clockTick0;
    time_T stepSize0;
    time_T tFinal;
    boolean_T stopRequestedFlag;
  } Timing;
};

/* Block parameters (default storage) */
extern P_gm_model_biquad_wfa_interfa_T gm_model_biquad_wfa_interface_P;

/* Block signals (default storage) */
extern B_gm_model_biquad_wfa_interfa_T gm_model_biquad_wfa_interface_B;

/* Block states (default storage) */
extern DW_gm_model_biquad_wfa_interf_T gm_model_biquad_wfa_interfac_DW;

/* Model entry point functions */
extern void gm_model_biquad_wfa_interface_old_initialize(void);
extern void gm_model_biquad_wfa_interface_old_step(void);
extern void gm_model_biquad_wfa_interface_old_terminate(void);

/* Real-time Model object */
extern RT_MODEL_gm_model_biquad_wfa__T *const gm_model_biquad_wfa_interfac_M;

/*-
 * These blocks were eliminated from the model due to optimizations:
 *
 * Block '<S2>/DataTypeConversion' : Unused code path elimination
 * Block '<S2>/DataTypeConversion1' : Unused code path elimination
 */

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'gm_model_biquad_wfa_interface_old'
 * '<S1>'   : 'gm_model_biquad_wfa_interface_old/Subsystem'
 * '<S2>'   : 'gm_model_biquad_wfa_interface_old/Subsystem/model_biquad_wfa'
 * '<S3>'   : 'gm_model_biquad_wfa_interface_old/Subsystem/model_biquad_wfa/AXI4SlaveWrite'
 * '<S4>'   : 'gm_model_biquad_wfa_interface_old/Subsystem/model_biquad_wfa/AXI4SlaveWrite/AXI4SlaveWrite_axi4_incos'
 * '<S5>'   : 'gm_model_biquad_wfa_interface_old/Subsystem/model_biquad_wfa/AXI4SlaveWrite/AXI4SlaveWrite_axi4_wkn'
 */
#endif                     /* RTW_HEADER_gm_model_biquad_wfa_interface_old_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
