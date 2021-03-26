/*
 * Trial License - for use to evaluate programs for possible purchase as
 * an end-user only.
 *
 * File: gm_model_biquad_wfa_interface_old_types.h
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

#ifndef RTW_HEADER_gm_model_biquad_wfa_interface_old_types_h_
#define RTW_HEADER_gm_model_biquad_wfa_interface_old_types_h_
#include "rtwtypes.h"
#include "multiword_types.h"

/* Model Code Variants */

/* Custom Type definition for MATLABSystem: '<S1>/AXI4-Stream IIO Write' */
#include "iio.h"
#include "iio.h"
#include "iio.h"
#include "iio_helper.h"
#ifndef struct_tag_T1gze9WPCMQfq07FO2cSND
#define struct_tag_T1gze9WPCMQfq07FO2cSND

struct tag_T1gze9WPCMQfq07FO2cSND
{
  boolean_T matlabCodegenIsDeleted;
  int32_T isInitialized;
  boolean_T isSetupComplete;
  boolean_T buffersAvailable;
  struct iio_context* iioCtx;
  struct iio_device* iioDev;
  struct iio_buffer* iioBuf;
  boolean_T bufExists;
  boolean_T needsTeardown;
  struct mw_iio_poll_config pollConfig;
  real_T pNumBufferBytes;
};

#endif                                 /*struct_tag_T1gze9WPCMQfq07FO2cSND*/

#ifndef typedef_matlabshared_libiio_axistream_T
#define typedef_matlabshared_libiio_axistream_T

typedef struct tag_T1gze9WPCMQfq07FO2cSND matlabshared_libiio_axistream_T;

#endif                               /*typedef_matlabshared_libiio_axistream_T*/

#ifndef struct_tag_gqEJlrWHT1Js3TlC4TmFM
#define struct_tag_gqEJlrWHT1Js3TlC4TmFM

struct tag_gqEJlrWHT1Js3TlC4TmFM
{
  boolean_T matlabCodegenIsDeleted;
  int32_T isInitialized;
  boolean_T isSetupComplete;
  boolean_T buffersAvailable;
  struct iio_context* iioCtx;
  struct iio_device* iioDev;
  struct iio_buffer* iioBuf;
  boolean_T bufExists;
  boolean_T needsTeardown;
  struct mw_iio_poll_config pollConfig;
  real_T pNumBufferBytes;
};

#endif                                 /*struct_tag_gqEJlrWHT1Js3TlC4TmFM*/

#ifndef typedef_matlabshared_libiio_axistre_m_T
#define typedef_matlabshared_libiio_axistre_m_T

typedef struct tag_gqEJlrWHT1Js3TlC4TmFM matlabshared_libiio_axistre_m_T;

#endif                               /*typedef_matlabshared_libiio_axistre_m_T*/

#ifndef struct_tag_hl7GuUJbiHFhvqUhWTqKjB
#define struct_tag_hl7GuUJbiHFhvqUhWTqKjB

struct tag_hl7GuUJbiHFhvqUhWTqKjB
{
  boolean_T matlabCodegenIsDeleted;
  int32_T isInitialized;
  boolean_T isSetupComplete;
  AXI4_struct * DeviceState;
};

#endif                                 /*struct_tag_hl7GuUJbiHFhvqUhWTqKjB*/

#ifndef typedef_zynq_AXIWrite_gm_model_biquad_T
#define typedef_zynq_AXIWrite_gm_model_biquad_T

typedef struct tag_hl7GuUJbiHFhvqUhWTqKjB zynq_AXIWrite_gm_model_biquad_T;

#endif                               /*typedef_zynq_AXIWrite_gm_model_biquad_T*/

/* Parameters (default storage) */
typedef struct P_gm_model_biquad_wfa_interfa_T_ P_gm_model_biquad_wfa_interfa_T;

/* Forward declaration for rtModel */
typedef struct tag_RTM_gm_model_biquad_wfa_i_T RT_MODEL_gm_model_biquad_wfa__T;

#endif               /* RTW_HEADER_gm_model_biquad_wfa_interface_old_types_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
