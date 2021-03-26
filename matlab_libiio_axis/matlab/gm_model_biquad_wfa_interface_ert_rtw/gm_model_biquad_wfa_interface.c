/*
 * Trial License - for use to evaluate programs for possible purchase as
 * an end-user only.
 *
 * File: gm_model_biquad_wfa_interface.c
 *
 * Code generated for Simulink model 'gm_model_biquad_wfa_interface'.
 *
 * Model version                  : 1.24
 * Simulink Coder version         : 9.4 (R2020b) 29-Jul-2020
 * C/C++ source code generated on : Sat Mar 20 21:53:46 2021
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: ARM Compatible->ARM Cortex
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "gm_model_biquad_wfa_interface.h"
#include "gm_model_biquad_wfa_interface_private.h"
#include "gm_model_biquad_wfa_interface_dt.h"

/* user code (top of source file) */
/* System '<S1>/model_biquad_wfa' */
#include "axi_lct.h"

/* Block signals (default storage) */
B_gm_model_biquad_wfa_interfa_T gm_model_biquad_wfa_interface_B;

/* Block states (default storage) */
DW_gm_model_biquad_wfa_interf_T gm_model_biquad_wfa_interfac_DW;

/* Real-time model */
static RT_MODEL_gm_model_biquad_wfa__T gm_model_biquad_wfa_interfac_M_;
RT_MODEL_gm_model_biquad_wfa__T *const gm_model_biquad_wfa_interfac_M =
  &gm_model_biquad_wfa_interfac_M_;

/* Forward declaration for local functions */
static struct iio_channel* gm_model_biquad_wf_base_getChan(struct iio_device*
  iioDev, boolean_T output);
static void gm_model_biquad_base_doTeardown(matlabshared_libiio_axistream_T *obj);
static struct iio_channel* gm_model_biquad__base_getChan_n(struct iio_device*
  iioDev, boolean_T output);
static void gm_model_biqu_base_doTeardown_n(matlabshared_libiio_axistre_n_T *obj);
static void gm_model_biqua_SystemCore_setup(matlabshared_libiio_axistream_T *obj);
static void gm_model_biq_SystemCore_setup_n(matlabshared_libiio_axistre_n_T *obj);
static struct iio_channel* gm_model_biquad_wf_base_getChan(struct iio_device*
  iioDev, boolean_T output)
{
  static const int8_T tmp_0[5] = { 100, 97, 116, 97, 48 };

  static const uint8_T tmp_2[22] = { 67U, 104U, 97U, 110U, 110U, 101U, 108U, 58U,
    32U, 37U, 115U, 32U, 110U, 111U, 116U, 32U, 102U, 111U, 117U, 110U, 100U,
    46U };

  static const uint8_T tmp_1[11] = { 69U, 82U, 82U, 79U, 82U, 91U, 37U, 100U,
    93U, 58U, 32U };

  static const uint8_T tmp[6] = { 100U, 97U, 116U, 97U, 48U, 0U };

  struct iio_channel* chanPtr;
  int32_T i;
  int32_T status;
  uint8_T b[3];
  for (i = 0; i < 6; i++) {
    gm_model_biquad_wfa_interface_B.b_o[i] = tmp[i];
  }

  chanPtr = iio_device_find_channel(iioDev,
    &gm_model_biquad_wfa_interface_B.b_o[0], (uint8_T)output);
  status = check_pointer(chanPtr);
  b[0] = 37U;
  b[1] = 100U;
  b[2] = 0U;
  for (i = 0; i < 5; i++) {
    gm_model_biquad_wfa_interface_B.c[i] = tmp_0[i];
  }

  sprintf(&gm_model_biquad_wfa_interface_B.strout_o[0], &b[0],
          &gm_model_biquad_wfa_interface_B.c[0]);
  if (status != 0) {
    for (i = 0; i < 11; i++) {
      gm_model_biquad_wfa_interface_B.b_j[i] = tmp_1[i];
    }

    for (i = 0; i < 22; i++) {
      gm_model_biquad_wfa_interface_B.b_j[i + 11] = tmp_2[i];
    }

    gm_model_biquad_wfa_interface_B.b_j[33] = 10U;
    gm_model_biquad_wfa_interface_B.b_j[34] = 0U;
    printf(&gm_model_biquad_wfa_interface_B.b_j[0], status,
           &gm_model_biquad_wfa_interface_B.strout_o[0]);
    exit(status);
  }

  return chanPtr;
}

static void gm_model_biquad_base_doTeardown(matlabshared_libiio_axistream_T *obj)
{
  int32_T status;
  if (obj->needsTeardown) {
    if (obj->bufExists) {
      iio_buffer_cancel(obj->iioBuf);
      iio_buffer_destroy(obj->iioBuf);
    }

    obj->bufExists = false;
    gm_model_biquad_wfa_interface_B.chanPtr_f = gm_model_biquad_wf_base_getChan
      (obj->iioDev, false);
    status = check_pointer(gm_model_biquad_wfa_interface_B.chanPtr_f);
    if (status == 0) {
      iio_channel_disable(gm_model_biquad_wfa_interface_B.chanPtr_f);
    }

    if (obj->bufExists) {
      iio_buffer_cancel(obj->iioBuf);
      iio_buffer_destroy(obj->iioBuf);
    }

    obj->bufExists = false;
    iio_context_destroy(obj->iioCtx);
    obj->needsTeardown = false;
  }
}

static struct iio_channel* gm_model_biquad__base_getChan_n(struct iio_device*
  iioDev, boolean_T output)
{
  static const int8_T tmp_0[5] = { 100, 97, 116, 97, 48 };

  static const uint8_T tmp_2[22] = { 67U, 104U, 97U, 110U, 110U, 101U, 108U, 58U,
    32U, 37U, 115U, 32U, 110U, 111U, 116U, 32U, 102U, 111U, 117U, 110U, 100U,
    46U };

  static const uint8_T tmp_1[11] = { 69U, 82U, 82U, 79U, 82U, 91U, 37U, 100U,
    93U, 58U, 32U };

  static const uint8_T tmp[6] = { 100U, 97U, 116U, 97U, 48U, 0U };

  struct iio_channel* chanPtr;
  int32_T i;
  int32_T status;
  uint8_T b[6];
  uint8_T b_0[3];
  for (i = 0; i < 6; i++) {
    b[i] = tmp[i];
  }

  chanPtr = iio_device_find_channel(iioDev, &b[0], (uint8_T)output);
  status = check_pointer(chanPtr);
  b_0[0] = 37U;
  b_0[1] = 100U;
  b_0[2] = 0U;
  for (i = 0; i < 5; i++) {
    gm_model_biquad_wfa_interface_B.c_b[i] = tmp_0[i];
  }

  sprintf(&gm_model_biquad_wfa_interface_B.strout_n[0], &b_0[0],
          &gm_model_biquad_wfa_interface_B.c_b[0]);
  if (status != 0) {
    for (i = 0; i < 11; i++) {
      gm_model_biquad_wfa_interface_B.b_gu[i] = tmp_1[i];
    }

    for (i = 0; i < 22; i++) {
      gm_model_biquad_wfa_interface_B.b_gu[i + 11] = tmp_2[i];
    }

    gm_model_biquad_wfa_interface_B.b_gu[33] = 10U;
    gm_model_biquad_wfa_interface_B.b_gu[34] = 0U;
    printf(&gm_model_biquad_wfa_interface_B.b_gu[0], status,
           &gm_model_biquad_wfa_interface_B.strout_n[0]);
    exit(status);
  }

  return chanPtr;
}

static void gm_model_biqu_base_doTeardown_n(matlabshared_libiio_axistre_n_T *obj)
{
  int32_T status;
  if (obj->needsTeardown) {
    if (obj->bufExists) {
      iio_buffer_cancel(obj->iioBuf);
      iio_buffer_destroy(obj->iioBuf);
    }

    obj->bufExists = false;
    gm_model_biquad_wfa_interface_B.chanPtr_o = gm_model_biquad__base_getChan_n
      (obj->iioDev, true);
    status = check_pointer(gm_model_biquad_wfa_interface_B.chanPtr_o);
    if (status == 0) {
      iio_channel_disable(gm_model_biquad_wfa_interface_B.chanPtr_o);
    }

    if (obj->bufExists) {
      iio_buffer_cancel(obj->iioBuf);
      iio_buffer_destroy(obj->iioBuf);
    }

    obj->bufExists = false;
    iio_context_destroy(obj->iioCtx);
    obj->needsTeardown = false;
  }
}

static void gm_model_biqua_SystemCore_setup(matlabshared_libiio_axistream_T *obj)
{
  static const uint8_T tmp[116] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 99U, 114U, 101U, 97U, 116U, 101U, 32U, 99U, 111U, 110U, 116U,
    101U, 120U, 116U, 32U, 102U, 111U, 114U, 32U, 117U, 114U, 105U, 58U, 32U,
    37U, 115U, 32U, 10U, 84U, 104U, 101U, 32U, 97U, 100U, 100U, 114U, 101U, 115U,
    115U, 32U, 105U, 115U, 32U, 110U, 111U, 116U, 32U, 97U, 118U, 97U, 105U,
    108U, 97U, 98U, 108U, 101U, 46U, 32U, 77U, 97U, 107U, 101U, 32U, 115U, 117U,
    114U, 101U, 32U, 116U, 104U, 101U, 32U, 100U, 101U, 118U, 105U, 99U, 101U,
    32U, 105U, 115U, 32U, 99U, 111U, 110U, 110U, 101U, 99U, 116U, 101U, 100U,
    32U, 97U, 110U, 100U, 32U, 116U, 114U, 121U, 32U, 97U, 103U, 97U, 105U, 110U,
    46U };

  static const uint8_T tmp_0[64] = { 69U, 82U, 82U, 79U, 82U, 91U, 37U, 100U,
    93U, 58U, 32U, 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U, 111U, 32U, 105U,
    110U, 105U, 116U, 105U, 97U, 108U, 105U, 122U, 101U, 32U, 115U, 116U, 114U,
    101U, 97U, 109U, 32U, 100U, 101U, 118U, 105U, 99U, 101U, 58U, 32U, 109U,
    119U, 105U, 112U, 99U, 111U, 114U, 101U, 48U, 58U, 115U, 50U, 109U, 109U,
    48U, 10U, 0U };

  static const uint8_T tmp_c[57] = { 69U, 82U, 82U, 79U, 82U, 91U, 37U, 100U,
    93U, 58U, 32U, 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U, 111U, 32U, 99U,
    114U, 101U, 97U, 116U, 101U, 32U, 98U, 117U, 102U, 102U, 101U, 114U, 32U,
    102U, 111U, 114U, 58U, 32U, 109U, 119U, 105U, 112U, 99U, 111U, 114U, 101U,
    48U, 58U, 115U, 50U, 109U, 109U, 48U, 10U, 0U };

  static const uint8_T tmp_d[39] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 99U, 111U, 110U, 102U, 105U, 103U, 117U, 114U, 101U, 32U, 100U,
    101U, 118U, 105U, 99U, 101U, 32U, 97U, 110U, 100U, 32U, 98U, 117U, 102U,
    102U, 101U, 114U, 115U, 46U };

  static const uint8_T tmp_6[31] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 115U, 101U, 116U, 117U, 112U, 32U, 107U, 101U, 114U, 110U, 101U,
    108U, 32U, 98U, 117U, 102U, 102U, 101U, 114U, 115U, 46U };

  static const uint8_T tmp_f[31] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 115U, 101U, 116U, 117U, 112U, 32U, 98U, 117U, 102U, 102U, 101U,
    114U, 32U, 112U, 111U, 108U, 108U, 105U, 110U, 103U, 46U };

  static const uint8_T tmp_4[30] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 115U, 101U, 116U, 32U, 99U, 111U, 110U, 116U, 101U, 120U, 116U,
    32U, 116U, 105U, 109U, 101U, 111U, 117U, 116U, 46U };

  static const uint8_T tmp_5[26] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 102U, 105U, 110U, 100U, 32U, 100U, 101U, 118U, 105U, 99U, 101U,
    58U, 32U, 37U, 115U, 46U };

  static const uint8_T tmp_9[22] = { 67U, 104U, 97U, 110U, 110U, 101U, 108U, 58U,
    32U, 37U, 115U, 32U, 110U, 111U, 116U, 32U, 102U, 111U, 117U, 110U, 100U,
    46U };

  static const uint8_T tmp_e[19] = { 68U, 97U, 116U, 97U, 32U, 115U, 105U, 122U,
    101U, 32U, 109U, 105U, 115U, 109U, 97U, 116U, 99U, 104U, 46U };

  static const uint8_T tmp_7[17] = { 114U, 101U, 115U, 101U, 116U, 95U, 116U,
    108U, 97U, 115U, 116U, 95U, 109U, 111U, 100U, 101U, 0U };

  static const uint8_T tmp_3[16] = { 109U, 119U, 105U, 112U, 99U, 111U, 114U,
    101U, 48U, 58U, 115U, 50U, 109U, 109U, 48U, 0U };

  static const uint8_T tmp_2[11] = { 69U, 82U, 82U, 79U, 82U, 91U, 37U, 100U,
    93U, 58U, 32U };

  static const uint8_T tmp_a[11] = { 116U, 108U, 97U, 115U, 116U, 95U, 109U,
    111U, 100U, 101U, 0U };

  static const uint8_T tmp_8[10] = { 112U, 114U, 101U, 98U, 117U, 102U, 102U,
    101U, 114U, 0U };

  static const uint8_T tmp_1[7] = { 108U, 111U, 99U, 97U, 108U, 58U, 0U };

  static const uint8_T tmp_b[5] = { 97U, 117U, 116U, 111U, 0U };

  int32_T status;
  int32_T status_0;
  uint32_T count;
  uint32_T qY;
  uint32_T qY_0;
  uint32_T total;
  uint8_T c[5];
  uint8_T b[3];
  boolean_T isScan;
  obj->isSetupComplete = false;
  obj->isInitialized = 1;
  obj->iioCtx = NULL;
  obj->iioDev = NULL;
  obj->iioBuf = NULL;
  for (status_0 = 0; status_0 < 7; status_0++) {
    gm_model_biquad_wfa_interface_B.b_ny[status_0] = tmp_1[status_0];
  }

  obj->iioCtx = iio_create_context_from_uri
    (&gm_model_biquad_wfa_interface_B.b_ny[0]);
  status = check_pointer(obj->iioCtx);
  if (status != 0) {
    for (status_0 = 0; status_0 < 11; status_0++) {
      gm_model_biquad_wfa_interface_B.b[status_0] = tmp_2[status_0];
    }

    memcpy(&gm_model_biquad_wfa_interface_B.b[11], &tmp[0], 116U * sizeof
           (uint8_T));
    gm_model_biquad_wfa_interface_B.b[127] = 10U;
    gm_model_biquad_wfa_interface_B.b[128] = 0U;
    for (status_0 = 0; status_0 < 7; status_0++) {
      gm_model_biquad_wfa_interface_B.b_ny[status_0] = tmp_1[status_0];
    }

    printf(&gm_model_biquad_wfa_interface_B.b[0], status,
           &gm_model_biquad_wfa_interface_B.b_ny[0]);
    exit(status);
  }

  status = iio_context_set_timeout(obj->iioCtx, 0U);
  if (status != 0) {
    for (status_0 = 0; status_0 < 11; status_0++) {
      gm_model_biquad_wfa_interface_B.b_g[status_0] = tmp_2[status_0];
    }

    for (status_0 = 0; status_0 < 30; status_0++) {
      gm_model_biquad_wfa_interface_B.b_g[status_0 + 11] = tmp_4[status_0];
    }

    gm_model_biquad_wfa_interface_B.b_g[41] = 10U;
    gm_model_biquad_wfa_interface_B.b_g[42] = 0U;
    printf(&gm_model_biquad_wfa_interface_B.b_g[0], status);
    exit(status);
  }

  for (status_0 = 0; status_0 < 16; status_0++) {
    gm_model_biquad_wfa_interface_B.b_h[status_0] = tmp_3[status_0];
  }

  gm_model_biquad_wfa_interface_B.devPtr = iio_context_find_device(obj->iioCtx,
    &gm_model_biquad_wfa_interface_B.b_h[0]);
  status = check_pointer(gm_model_biquad_wfa_interface_B.devPtr);
  if (status != 0) {
    for (status_0 = 0; status_0 < 11; status_0++) {
      gm_model_biquad_wfa_interface_B.b_me[status_0] = tmp_2[status_0];
    }

    for (status_0 = 0; status_0 < 26; status_0++) {
      gm_model_biquad_wfa_interface_B.b_me[status_0 + 11] = tmp_5[status_0];
    }

    gm_model_biquad_wfa_interface_B.b_me[37] = 10U;
    gm_model_biquad_wfa_interface_B.b_me[38] = 0U;
    for (status_0 = 0; status_0 < 16; status_0++) {
      gm_model_biquad_wfa_interface_B.b_h[status_0] = tmp_3[status_0];
    }

    printf(&gm_model_biquad_wfa_interface_B.b_me[0], status,
           &gm_model_biquad_wfa_interface_B.b_h[0]);
    exit(status);
  }

  obj->iioDev = gm_model_biquad_wfa_interface_B.devPtr;
  obj->needsTeardown = true;
  total = iio_device_get_channels_count(obj->iioDev);
  count = 0U;
  qY = total - /*MW:OvSatOk*/ 1U;
  if (total - 1U > total) {
    qY = 0U;
  }

  for (total = 0U; total <= qY; total++) {
    gm_model_biquad_wfa_interface_B.chanPtr = iio_device_get_channel(obj->iioDev,
      total);
    status = check_pointer(gm_model_biquad_wfa_interface_B.chanPtr);
    b[0] = 37U;
    b[1] = 100U;
    b[2] = 0U;
    qY_0 = total;
    if (total > 2147483647U) {
      qY_0 = 2147483647U;
    }

    sprintf(&gm_model_biquad_wfa_interface_B.strout[0], &b[0], (int32_T)qY_0);
    if (status != 0) {
      for (status_0 = 0; status_0 < 11; status_0++) {
        gm_model_biquad_wfa_interface_B.b_l[status_0] = tmp_2[status_0];
      }

      for (status_0 = 0; status_0 < 22; status_0++) {
        gm_model_biquad_wfa_interface_B.b_l[status_0 + 11] = tmp_9[status_0];
      }

      gm_model_biquad_wfa_interface_B.b_l[33] = 10U;
      gm_model_biquad_wfa_interface_B.b_l[34] = 0U;
      printf(&gm_model_biquad_wfa_interface_B.b_l[0], status,
             &gm_model_biquad_wfa_interface_B.strout[0]);
      exit(status);
    }

    status = check_pointer(gm_model_biquad_wfa_interface_B.chanPtr);
    if (status == 0) {
      isScan = iio_channel_is_scan_element
        (gm_model_biquad_wfa_interface_B.chanPtr);
      if (isScan) {
        qY_0 = count + /*MW:OvSatOk*/ 1U;
        if (count + 1U < count) {
          qY_0 = MAX_uint32_T;
        }

        count = qY_0;
      }
    }
  }

  if (count > 0U) {
    obj->buffersAvailable = true;
  }

  if (obj->buffersAvailable) {
    status = iio_device_set_kernel_buffers_count(obj->iioDev, 4U);
    if (status != 0) {
      for (status_0 = 0; status_0 < 11; status_0++) {
        gm_model_biquad_wfa_interface_B.b_cv[status_0] = tmp_2[status_0];
      }

      for (status_0 = 0; status_0 < 31; status_0++) {
        gm_model_biquad_wfa_interface_B.b_cv[status_0 + 11] = tmp_6[status_0];
      }

      gm_model_biquad_wfa_interface_B.b_cv[42] = 10U;
      gm_model_biquad_wfa_interface_B.b_cv[43] = 0U;
      printf(&gm_model_biquad_wfa_interface_B.b_cv[0], status);
      exit(status);
    }
  }

  gm_model_biquad_wfa_interface_B.chanPtr = gm_model_biquad_wf_base_getChan
    (obj->iioDev, false);
  status = check_pointer(gm_model_biquad_wfa_interface_B.chanPtr);
  if (status == 0) {
    iio_channel_enable(gm_model_biquad_wfa_interface_B.chanPtr);
  }

  status = 0;
  for (status_0 = 0; status_0 < 17; status_0++) {
    gm_model_biquad_wfa_interface_B.b_ln[status_0] = tmp_7[status_0];
  }

  for (status_0 = 0; status_0 < 10; status_0++) {
    gm_model_biquad_wfa_interface_B.c_bj[status_0] = tmp_8[status_0];
  }

  gm_model_biquad_wfa_interface_B.ssizeT = iio_device_attr_write(obj->iioDev,
    &gm_model_biquad_wfa_interface_B.b_ln[0],
    &gm_model_biquad_wfa_interface_B.c_bj[0]);
  for (status_0 = 0; status_0 < 11; status_0++) {
    gm_model_biquad_wfa_interface_B.b_e[status_0] = tmp_a[status_0];
  }

  for (status_0 = 0; status_0 < 5; status_0++) {
    c[status_0] = tmp_b[status_0];
  }

  gm_model_biquad_wfa_interface_B.ssizeT_j = iio_device_attr_write(obj->iioDev,
    &gm_model_biquad_wfa_interface_B.b_e[0], &c[0]);
  if (((int32_T)gm_model_biquad_wfa_interface_B.ssizeT <= 0) || ((int32_T)
       gm_model_biquad_wfa_interface_B.ssizeT_j <= 0)) {
    status = -19;
  }

  if (status != 0) {
    gm_model_biquad_wfa_interface_B.chanPtr = gm_model_biquad_wf_base_getChan
      (obj->iioDev, false);
    status_0 = check_pointer(gm_model_biquad_wfa_interface_B.chanPtr);
    if (status_0 == 0) {
      iio_channel_disable(gm_model_biquad_wfa_interface_B.chanPtr);
    }

    memcpy(&gm_model_biquad_wfa_interface_B.b_c[0], &tmp_0[0], sizeof(uint8_T) <<
           6U);
    printf(&gm_model_biquad_wfa_interface_B.b_c[0], status);
  } else {
    obj->iioBuf = iio_device_create_buffer(obj->iioDev, 32U, 0);
    status = check_pointer(obj->iioBuf);
    if (status == 0) {
      obj->bufExists = true;
    }

    if (status != 0) {
      gm_model_biquad_wfa_interface_B.chanPtr = gm_model_biquad_wf_base_getChan
        (obj->iioDev, false);
      status_0 = check_pointer(gm_model_biquad_wfa_interface_B.chanPtr);
      if (status_0 == 0) {
        iio_channel_disable(gm_model_biquad_wfa_interface_B.chanPtr);
      }

      for (status_0 = 0; status_0 < 57; status_0++) {
        gm_model_biquad_wfa_interface_B.b_k[status_0] = tmp_c[status_0];
      }

      printf(&gm_model_biquad_wfa_interface_B.b_k[0], status);
    }
  }

  if (status != 0) {
    for (status_0 = 0; status_0 < 11; status_0++) {
      gm_model_biquad_wfa_interface_B.b_b[status_0] = tmp_2[status_0];
    }

    for (status_0 = 0; status_0 < 39; status_0++) {
      gm_model_biquad_wfa_interface_B.b_b[status_0 + 11] = tmp_d[status_0];
    }

    gm_model_biquad_wfa_interface_B.b_b[50] = 10U;
    gm_model_biquad_wfa_interface_B.b_b[51] = 0U;
    printf(&gm_model_biquad_wfa_interface_B.b_b[0], status);
    exit(status);
  }

  if (obj->buffersAvailable) {
    gm_model_biquad_wfa_interface_B.ptrDiff = iio_buffer_step(obj->iioBuf);
    isScan = false;
    if ((uint32_T)gm_model_biquad_wfa_interface_B.ptrDiff == 4U) {
      isScan = true;
    }

    if (!isScan) {
      gm_model_biquad_base_doTeardown(obj);
      for (status_0 = 0; status_0 < 11; status_0++) {
        gm_model_biquad_wfa_interface_B.b_dh[status_0] = tmp_2[status_0];
      }

      for (status_0 = 0; status_0 < 19; status_0++) {
        gm_model_biquad_wfa_interface_B.b_dh[status_0 + 11] = tmp_e[status_0];
      }

      gm_model_biquad_wfa_interface_B.b_dh[30] = 10U;
      gm_model_biquad_wfa_interface_B.b_dh[31] = 0U;
      printf(&gm_model_biquad_wfa_interface_B.b_dh[0], -22);
      exit(-22);
    }
  }

  if (obj->buffersAvailable) {
    obj->pollConfig = EmptyPollConfig;
    status = mw_iio_setup_poll(&obj->pollConfig, obj->iioBuf, 10.0, false);
    if (status != 0) {
      gm_model_biquad_base_doTeardown(obj);
      if (status != 0) {
        for (status_0 = 0; status_0 < 11; status_0++) {
          gm_model_biquad_wfa_interface_B.b_cv[status_0] = tmp_2[status_0];
        }

        for (status_0 = 0; status_0 < 31; status_0++) {
          gm_model_biquad_wfa_interface_B.b_cv[status_0 + 11] = tmp_f[status_0];
        }

        gm_model_biquad_wfa_interface_B.b_cv[42] = 10U;
        gm_model_biquad_wfa_interface_B.b_cv[43] = 0U;
        printf(&gm_model_biquad_wfa_interface_B.b_cv[0], status);
        exit(status);
      }
    }
  } else {
    obj->pollConfig = EmptyPollConfig;
  }

  obj->pNumBufferBytes = 128.0;
  obj->isSetupComplete = true;
}

static void gm_model_biq_SystemCore_setup_n(matlabshared_libiio_axistre_n_T *obj)
{
  static const uint8_T tmp[116] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 99U, 114U, 101U, 97U, 116U, 101U, 32U, 99U, 111U, 110U, 116U,
    101U, 120U, 116U, 32U, 102U, 111U, 114U, 32U, 117U, 114U, 105U, 58U, 32U,
    37U, 115U, 32U, 10U, 84U, 104U, 101U, 32U, 97U, 100U, 100U, 114U, 101U, 115U,
    115U, 32U, 105U, 115U, 32U, 110U, 111U, 116U, 32U, 97U, 118U, 97U, 105U,
    108U, 97U, 98U, 108U, 101U, 46U, 32U, 77U, 97U, 107U, 101U, 32U, 115U, 117U,
    114U, 101U, 32U, 116U, 104U, 101U, 32U, 100U, 101U, 118U, 105U, 99U, 101U,
    32U, 105U, 115U, 32U, 99U, 111U, 110U, 110U, 101U, 99U, 116U, 101U, 100U,
    32U, 97U, 110U, 100U, 32U, 116U, 114U, 121U, 32U, 97U, 103U, 97U, 105U, 110U,
    46U };

  static const uint8_T tmp_7[57] = { 69U, 82U, 82U, 79U, 82U, 91U, 37U, 100U,
    93U, 58U, 32U, 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U, 111U, 32U, 99U,
    114U, 101U, 97U, 116U, 101U, 32U, 98U, 117U, 102U, 102U, 101U, 114U, 32U,
    102U, 111U, 114U, 58U, 32U, 109U, 119U, 105U, 112U, 99U, 111U, 114U, 101U,
    48U, 58U, 109U, 109U, 50U, 115U, 48U, 10U, 0U };

  static const uint8_T tmp_a[39] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 99U, 111U, 110U, 102U, 105U, 103U, 117U, 114U, 101U, 32U, 100U,
    101U, 118U, 105U, 99U, 101U, 32U, 97U, 110U, 100U, 32U, 98U, 117U, 102U,
    102U, 101U, 114U, 115U, 46U };

  static const uint8_T tmp_5[31] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 115U, 101U, 116U, 117U, 112U, 32U, 107U, 101U, 114U, 110U, 101U,
    108U, 32U, 98U, 117U, 102U, 102U, 101U, 114U, 115U, 46U };

  static const uint8_T tmp_9[31] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 115U, 101U, 116U, 117U, 112U, 32U, 98U, 117U, 102U, 102U, 101U,
    114U, 32U, 112U, 111U, 108U, 108U, 105U, 110U, 103U, 46U };

  static const uint8_T tmp_3[30] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 115U, 101U, 116U, 32U, 99U, 111U, 110U, 116U, 101U, 120U, 116U,
    32U, 116U, 105U, 109U, 101U, 111U, 117U, 116U, 46U };

  static const uint8_T tmp_4[26] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 102U, 105U, 110U, 100U, 32U, 100U, 101U, 118U, 105U, 99U, 101U,
    58U, 32U, 37U, 115U, 46U };

  static const uint8_T tmp_6[22] = { 67U, 104U, 97U, 110U, 110U, 101U, 108U, 58U,
    32U, 37U, 115U, 32U, 110U, 111U, 116U, 32U, 102U, 111U, 117U, 110U, 100U,
    46U };

  static const uint8_T tmp_8[19] = { 68U, 97U, 116U, 97U, 32U, 115U, 105U, 122U,
    101U, 32U, 109U, 105U, 115U, 109U, 97U, 116U, 99U, 104U, 46U };

  static const uint8_T tmp_2[16] = { 109U, 119U, 105U, 112U, 99U, 111U, 114U,
    101U, 48U, 58U, 109U, 109U, 50U, 115U, 48U, 0U };

  static const uint8_T tmp_1[11] = { 69U, 82U, 82U, 79U, 82U, 91U, 37U, 100U,
    93U, 58U, 32U };

  static const uint8_T tmp_0[7] = { 108U, 111U, 99U, 97U, 108U, 58U, 0U };

  int32_T status;
  int32_T status_0;
  uint32_T count;
  uint32_T qY;
  uint32_T qY_0;
  uint32_T total;
  uint8_T b[3];
  boolean_T isScan;
  obj->isSetupComplete = false;
  obj->isInitialized = 1;
  obj->iioCtx = NULL;
  obj->iioDev = NULL;
  obj->iioBuf = NULL;
  for (status_0 = 0; status_0 < 7; status_0++) {
    gm_model_biquad_wfa_interface_B.b_i[status_0] = tmp_0[status_0];
  }

  obj->iioCtx = iio_create_context_from_uri
    (&gm_model_biquad_wfa_interface_B.b_i[0]);
  status = check_pointer(obj->iioCtx);
  if (status != 0) {
    for (status_0 = 0; status_0 < 11; status_0++) {
      gm_model_biquad_wfa_interface_B.b_m[status_0] = tmp_1[status_0];
    }

    memcpy(&gm_model_biquad_wfa_interface_B.b_m[11], &tmp[0], 116U * sizeof
           (uint8_T));
    gm_model_biquad_wfa_interface_B.b_m[127] = 10U;
    gm_model_biquad_wfa_interface_B.b_m[128] = 0U;
    for (status_0 = 0; status_0 < 7; status_0++) {
      gm_model_biquad_wfa_interface_B.b_i[status_0] = tmp_0[status_0];
    }

    printf(&gm_model_biquad_wfa_interface_B.b_m[0], status,
           &gm_model_biquad_wfa_interface_B.b_i[0]);
    exit(status);
  }

  status = iio_context_set_timeout(obj->iioCtx, 0U);
  if (status != 0) {
    for (status_0 = 0; status_0 < 11; status_0++) {
      gm_model_biquad_wfa_interface_B.b_g1[status_0] = tmp_1[status_0];
    }

    for (status_0 = 0; status_0 < 30; status_0++) {
      gm_model_biquad_wfa_interface_B.b_g1[status_0 + 11] = tmp_3[status_0];
    }

    gm_model_biquad_wfa_interface_B.b_g1[41] = 10U;
    gm_model_biquad_wfa_interface_B.b_g1[42] = 0U;
    printf(&gm_model_biquad_wfa_interface_B.b_g1[0], status);
    exit(status);
  }

  for (status_0 = 0; status_0 < 16; status_0++) {
    gm_model_biquad_wfa_interface_B.b_bn[status_0] = tmp_2[status_0];
  }

  gm_model_biquad_wfa_interface_B.devPtr_a = iio_context_find_device(obj->iioCtx,
    &gm_model_biquad_wfa_interface_B.b_bn[0]);
  status = check_pointer(gm_model_biquad_wfa_interface_B.devPtr_a);
  if (status != 0) {
    for (status_0 = 0; status_0 < 11; status_0++) {
      gm_model_biquad_wfa_interface_B.b_n[status_0] = tmp_1[status_0];
    }

    for (status_0 = 0; status_0 < 26; status_0++) {
      gm_model_biquad_wfa_interface_B.b_n[status_0 + 11] = tmp_4[status_0];
    }

    gm_model_biquad_wfa_interface_B.b_n[37] = 10U;
    gm_model_biquad_wfa_interface_B.b_n[38] = 0U;
    for (status_0 = 0; status_0 < 16; status_0++) {
      gm_model_biquad_wfa_interface_B.b_bn[status_0] = tmp_2[status_0];
    }

    printf(&gm_model_biquad_wfa_interface_B.b_n[0], status,
           &gm_model_biquad_wfa_interface_B.b_bn[0]);
    exit(status);
  }

  obj->iioDev = gm_model_biquad_wfa_interface_B.devPtr_a;
  obj->needsTeardown = true;
  total = iio_device_get_channels_count(obj->iioDev);
  count = 0U;
  qY = total - /*MW:OvSatOk*/ 1U;
  if (total - 1U > total) {
    qY = 0U;
  }

  for (total = 0U; total <= qY; total++) {
    gm_model_biquad_wfa_interface_B.chanPtr_j = iio_device_get_channel
      (obj->iioDev, total);
    status = check_pointer(gm_model_biquad_wfa_interface_B.chanPtr_j);
    b[0] = 37U;
    b[1] = 100U;
    b[2] = 0U;
    qY_0 = total;
    if (total > 2147483647U) {
      qY_0 = 2147483647U;
    }

    sprintf(&gm_model_biquad_wfa_interface_B.strout_b[0], &b[0], (int32_T)qY_0);
    if (status != 0) {
      for (status_0 = 0; status_0 < 11; status_0++) {
        gm_model_biquad_wfa_interface_B.b_d[status_0] = tmp_1[status_0];
      }

      for (status_0 = 0; status_0 < 22; status_0++) {
        gm_model_biquad_wfa_interface_B.b_d[status_0 + 11] = tmp_6[status_0];
      }

      gm_model_biquad_wfa_interface_B.b_d[33] = 10U;
      gm_model_biquad_wfa_interface_B.b_d[34] = 0U;
      printf(&gm_model_biquad_wfa_interface_B.b_d[0], status,
             &gm_model_biquad_wfa_interface_B.strout_b[0]);
      exit(status);
    }

    status = check_pointer(gm_model_biquad_wfa_interface_B.chanPtr_j);
    if (status == 0) {
      isScan = iio_channel_is_scan_element
        (gm_model_biquad_wfa_interface_B.chanPtr_j);
      if (isScan) {
        qY_0 = count + /*MW:OvSatOk*/ 1U;
        if (count + 1U < count) {
          qY_0 = MAX_uint32_T;
        }

        count = qY_0;
      }
    }
  }

  if (count > 0U) {
    obj->buffersAvailable = true;
  }

  if (obj->buffersAvailable) {
    status = iio_device_set_kernel_buffers_count(obj->iioDev, 4U);
    if (status != 0) {
      for (status_0 = 0; status_0 < 11; status_0++) {
        gm_model_biquad_wfa_interface_B.b_f[status_0] = tmp_1[status_0];
      }

      for (status_0 = 0; status_0 < 31; status_0++) {
        gm_model_biquad_wfa_interface_B.b_f[status_0 + 11] = tmp_5[status_0];
      }

      gm_model_biquad_wfa_interface_B.b_f[42] = 10U;
      gm_model_biquad_wfa_interface_B.b_f[43] = 0U;
      printf(&gm_model_biquad_wfa_interface_B.b_f[0], status);
      exit(status);
    }
  }

  gm_model_biquad_wfa_interface_B.chanPtr_j = gm_model_biquad__base_getChan_n
    (obj->iioDev, true);
  status = check_pointer(gm_model_biquad_wfa_interface_B.chanPtr_j);
  if (status == 0) {
    iio_channel_enable(gm_model_biquad_wfa_interface_B.chanPtr_j);
  }

  obj->iioBuf = iio_device_create_buffer(obj->iioDev, 32U, 0);
  status = check_pointer(obj->iioBuf);
  if (status == 0) {
    obj->bufExists = true;
  }

  if (status != 0) {
    gm_model_biquad_wfa_interface_B.chanPtr_j = gm_model_biquad__base_getChan_n
      (obj->iioDev, true);
    status_0 = check_pointer(gm_model_biquad_wfa_interface_B.chanPtr_j);
    if (status_0 == 0) {
      iio_channel_disable(gm_model_biquad_wfa_interface_B.chanPtr_j);
    }

    for (status_0 = 0; status_0 < 57; status_0++) {
      gm_model_biquad_wfa_interface_B.b_cx[status_0] = tmp_7[status_0];
    }

    printf(&gm_model_biquad_wfa_interface_B.b_cx[0], status);
    if (status != 0) {
      for (status_0 = 0; status_0 < 11; status_0++) {
        gm_model_biquad_wfa_interface_B.b_p[status_0] = tmp_1[status_0];
      }

      for (status_0 = 0; status_0 < 39; status_0++) {
        gm_model_biquad_wfa_interface_B.b_p[status_0 + 11] = tmp_a[status_0];
      }

      gm_model_biquad_wfa_interface_B.b_p[50] = 10U;
      gm_model_biquad_wfa_interface_B.b_p[51] = 0U;
      printf(&gm_model_biquad_wfa_interface_B.b_p[0], status);
      exit(status);
    }
  }

  if (obj->buffersAvailable) {
    gm_model_biquad_wfa_interface_B.ptrDiff_j = iio_buffer_step(obj->iioBuf);
    isScan = false;
    if ((uint32_T)gm_model_biquad_wfa_interface_B.ptrDiff_j == 4U) {
      isScan = true;
    }

    if (!isScan) {
      gm_model_biqu_base_doTeardown_n(obj);
      for (status_0 = 0; status_0 < 11; status_0++) {
        gm_model_biquad_wfa_interface_B.b_dy[status_0] = tmp_1[status_0];
      }

      for (status_0 = 0; status_0 < 19; status_0++) {
        gm_model_biquad_wfa_interface_B.b_dy[status_0 + 11] = tmp_8[status_0];
      }

      gm_model_biquad_wfa_interface_B.b_dy[30] = 10U;
      gm_model_biquad_wfa_interface_B.b_dy[31] = 0U;
      printf(&gm_model_biquad_wfa_interface_B.b_dy[0], -22);
      exit(-22);
    }
  }

  if (obj->buffersAvailable) {
    obj->pollConfig = EmptyPollConfig;
    status = mw_iio_setup_poll(&obj->pollConfig, obj->iioBuf, 0.0, true);
    if (status != 0) {
      gm_model_biqu_base_doTeardown_n(obj);
      if (status != 0) {
        for (status_0 = 0; status_0 < 11; status_0++) {
          gm_model_biquad_wfa_interface_B.b_f[status_0] = tmp_1[status_0];
        }

        for (status_0 = 0; status_0 < 31; status_0++) {
          gm_model_biquad_wfa_interface_B.b_f[status_0 + 11] = tmp_9[status_0];
        }

        gm_model_biquad_wfa_interface_B.b_f[42] = 10U;
        gm_model_biquad_wfa_interface_B.b_f[43] = 0U;
        printf(&gm_model_biquad_wfa_interface_B.b_f[0], status);
        exit(status);
      }
    }
  } else {
    obj->pollConfig = EmptyPollConfig;
  }

  obj->pNumBufferBytes = 128.0;
  obj->isSetupComplete = true;
}

/* Model step function */
void gm_model_biquad_wfa_interface_step(void)
{
  static const uint8_T tmp_2[24] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 114U, 101U, 102U, 105U, 108U, 108U, 32U, 98U, 117U, 102U, 102U,
    101U, 114U, 46U };

  static const uint8_T tmp_3[22] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 112U, 117U, 115U, 104U, 32U, 98U, 117U, 102U, 102U, 101U, 114U,
    46U };

  static const uint8_T tmp_1[19] = { 70U, 97U, 105U, 108U, 101U, 100U, 32U, 116U,
    111U, 32U, 103U, 101U, 116U, 32U, 100U, 97U, 116U, 97U, 46U };

  static const uint8_T tmp_0[11] = { 69U, 82U, 82U, 79U, 82U, 91U, 37U, 100U,
    93U, 58U, 32U };

  ssize_t ssizeT;
  void* BufferStartPtr;
  real_T tmp;
  int32_T i;
  int32_T status;
  uint32_T rtb_DataTypeConversion;

  /* MATLABSystem: '<S1>/AXI4-Stream IIO Read' */
  status = mw_iio_poll(&gm_model_biquad_wfa_interfac_DW.obj.pollConfig);
  if (status != -110) {
    if (status != 0) {
      for (i = 0; i < 11; i++) {
        gm_model_biquad_wfa_interface_B.b_lx[i] = tmp_0[i];
      }

      for (i = 0; i < 19; i++) {
        gm_model_biquad_wfa_interface_B.b_lx[i + 11] = tmp_1[i];
      }

      gm_model_biquad_wfa_interface_B.b_lx[30] = 10U;
      gm_model_biquad_wfa_interface_B.b_lx[31] = 0U;
      printf(&gm_model_biquad_wfa_interface_B.b_lx[0], status);
      exit(status);
    }

    ssizeT = iio_buffer_refill(gm_model_biquad_wfa_interfac_DW.obj.iioBuf);
    status = (int32_T)ssizeT;
    if (((int32_T)ssizeT >= 0) && ((int32_T)ssizeT !=
         gm_model_biquad_wfa_interfac_DW.obj.pNumBufferBytes)) {
      status = -5;
    }

    if (status < 0) {
      for (i = 0; i < 11; i++) {
        gm_model_biquad_wfa_interface_B.b_pp[i] = tmp_0[i];
      }

      for (i = 0; i < 24; i++) {
        gm_model_biquad_wfa_interface_B.b_pp[i + 11] = tmp_2[i];
      }

      gm_model_biquad_wfa_interface_B.b_pp[35] = 10U;
      gm_model_biquad_wfa_interface_B.b_pp[36] = 0U;
      printf(&gm_model_biquad_wfa_interface_B.b_pp[0], status);
      exit(status);
    }

    BufferStartPtr = iio_buffer_start(gm_model_biquad_wfa_interfac_DW.obj.iioBuf);
    memcpy(&gm_model_biquad_wfa_interface_B.AXI4StreamIIORead_o1[0],
           BufferStartPtr, 128U);
  }

  /* End of MATLABSystem: '<S1>/AXI4-Stream IIO Read' */
  for (i = 0; i < 32; i++) {
    /* DataTypeConversion: '<S1>/AXI_Read_y_out_DTC' incorporates:
     *  MATLABSystem: '<S1>/AXI4-Stream IIO Read'
     */
    gm_model_biquad_wfa_interface_B.AXI_Read_y_out_DTC[i] = (int32_T)
      gm_model_biquad_wfa_interface_B.AXI4StreamIIORead_o1[i];

    /* DataTypeConversion: '<Root>/Data Type Conversion3' incorporates:
     *  DataTypeConversion: '<S1>/AXI_Read_y_out_DTC'
     */
    gm_model_biquad_wfa_interface_B.DataTypeConversion3[i] = (real_T)
      gm_model_biquad_wfa_interface_B.AXI_Read_y_out_DTC[i] * 1.52587890625E-5;
  }

  /* FromWorkspace: '<Root>/From Workspace' */
  {
    int_T currIndex =
      gm_model_biquad_wfa_interfac_DW.FromWorkspace_IWORK.PrevIndex+1;
    real_T *pDataValues = (real_T *)
      gm_model_biquad_wfa_interfac_DW.FromWorkspace_PWORK.DataPtr;
    if (currIndex >= 1) {
      currIndex = 0;
    }

    if (currIndex < 1) {
      pDataValues += currIndex;

      {
        int_T elIdx;
        for (elIdx = 0; elIdx < 32; ++elIdx) {
          (&gm_model_biquad_wfa_interface_B.FromWorkspace[0])[elIdx] =
            *pDataValues;
          pDataValues += 1;
        }
      }
    } else {
      pDataValues += (0);

      {
        int_T elIdx;
        for (elIdx = 0; elIdx < 32; ++elIdx) {
          (&gm_model_biquad_wfa_interface_B.FromWorkspace[0])[elIdx] =
            *pDataValues;
          pDataValues += 1;
        }
      }
    }

    gm_model_biquad_wfa_interfac_DW.FromWorkspace_IWORK.PrevIndex = currIndex;
  }

  for (i = 0; i < 32; i++) {
    /* DataTypeConversion: '<Root>/Data Type Conversion2' */
    tmp = floor(gm_model_biquad_wfa_interface_B.FromWorkspace[i] * 65536.0);
    if (rtIsNaN(tmp) || rtIsInf(tmp)) {
      tmp = 0.0;
    } else {
      tmp = fmod(tmp, 4.294967296E+9);
    }

    status = tmp < 0.0 ? -(int32_T)(uint32_T)-tmp : (int32_T)(uint32_T)tmp;

    /* DataTypeConversion: '<Root>/Data Type Conversion4' */
    gm_model_biquad_wfa_interface_B.DataTypeConversion4[i] = (real_T)status *
      1.52587890625E-5;

    /* DataTypeConversion: '<Root>/Data Type Conversion2' */
    gm_model_biquad_wfa_interface_B.DataTypeConversion2[i] = status;
  }

  /* DataTypeConversion: '<S1>/AXI_Write_x_in_DTC' incorporates:
   *  DataTypeConversion: '<Root>/Data Type Conversion2'
   */
  for (i = 0; i < 32; i++) {
    gm_model_biquad_wfa_interface_B.AXI_Write_x_in_DTC[i] = (uint32_T)
      gm_model_biquad_wfa_interface_B.DataTypeConversion2[i];
  }

  /* End of DataTypeConversion: '<S1>/AXI_Write_x_in_DTC' */
  /* MATLABSystem: '<S1>/AXI4-Stream IIO Write' */
  status = mw_iio_poll(&gm_model_biquad_wfa_interfac_DW.obj_o.pollConfig);
  if (status != -110) {
    if (status != 0) {
      for (i = 0; i < 11; i++) {
        gm_model_biquad_wfa_interface_B.b_lx[i] = tmp_0[i];
      }

      for (i = 0; i < 19; i++) {
        gm_model_biquad_wfa_interface_B.b_lx[i + 11] = tmp_1[i];
      }

      gm_model_biquad_wfa_interface_B.b_lx[30] = 10U;
      gm_model_biquad_wfa_interface_B.b_lx[31] = 0U;
      printf(&gm_model_biquad_wfa_interface_B.b_lx[0], status);
      exit(status);
    }

    BufferStartPtr = iio_buffer_start
      (gm_model_biquad_wfa_interfac_DW.obj_o.iioBuf);
    memcpy(BufferStartPtr, &gm_model_biquad_wfa_interface_B.AXI_Write_x_in_DTC[0],
           128U);
    ssizeT = iio_buffer_push(gm_model_biquad_wfa_interfac_DW.obj_o.iioBuf);
    status = (int32_T)ssizeT;
    if (((int32_T)ssizeT >= 0) && ((int32_T)ssizeT !=
         gm_model_biquad_wfa_interfac_DW.obj_o.pNumBufferBytes)) {
      status = -5;
    }

    if (status < 0) {
      for (i = 0; i < 11; i++) {
        gm_model_biquad_wfa_interface_B.b_ld[i] = tmp_0[i];
      }

      for (i = 0; i < 22; i++) {
        gm_model_biquad_wfa_interface_B.b_ld[i + 11] = tmp_3[i];
      }

      gm_model_biquad_wfa_interface_B.b_ld[33] = 10U;
      gm_model_biquad_wfa_interface_B.b_ld[34] = 0U;
      printf(&gm_model_biquad_wfa_interface_B.b_ld[0], status);
      exit(status);
    }
  }

  /* End of MATLABSystem: '<S1>/AXI4-Stream IIO Write' */

  /* Outputs for Atomic SubSystem: '<S1>/model_biquad_wfa' */

  /* DataTypeConversion: '<S3>/DataTypeConversion' incorporates:
   *  Constant: '<Root>/Constant'
   */
  rtb_DataTypeConversion = (uint32_T)
    gm_model_biquad_wfa_interface_P.Constant_Value;

  /* MATLABSystem: '<S5>/AXI4-Interface Write' */
  AXI4LITE_WRITE(gm_model_biquad_wfa_interfac_DW.obj_n.DeviceState,
                 &rtb_DataTypeConversion, 260U, 4U);

  /* DataTypeConversion: '<S3>/DataTypeConversion1' incorporates:
   *  Constant: '<Root>/Constant1'
   */
  rtb_DataTypeConversion = (uint32_T)gm_model_biquad_wfa_interface_P.in_cos;

  /* MATLABSystem: '<S4>/AXI4-Interface Write' */
  AXI4LITE_WRITE(gm_model_biquad_wfa_interfac_DW.obj_a.DeviceState,
                 &rtb_DataTypeConversion, 256U, 4U);

  /* End of Outputs for SubSystem: '<S1>/model_biquad_wfa' */

  /* External mode */
  rtExtModeUploadCheckTrigger(1);

  {                                    /* Sample time: [0.001s, 0.0s] */
    rtExtModeUpload(0, (real_T)gm_model_biquad_wfa_interfac_M->Timing.taskTime0);
  }

  /* signal main to stop simulation */
  {                                    /* Sample time: [0.001s, 0.0s] */
    if ((rtmGetTFinal(gm_model_biquad_wfa_interfac_M)!=-1) &&
        !((rtmGetTFinal(gm_model_biquad_wfa_interfac_M)-
           gm_model_biquad_wfa_interfac_M->Timing.taskTime0) >
          gm_model_biquad_wfa_interfac_M->Timing.taskTime0 * (DBL_EPSILON))) {
      rtmSetErrorStatus(gm_model_biquad_wfa_interfac_M, "Simulation finished");
    }

    if (rtmGetStopRequested(gm_model_biquad_wfa_interfac_M)) {
      rtmSetErrorStatus(gm_model_biquad_wfa_interfac_M, "Simulation finished");
    }
  }

  /* Update absolute time for base rate */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The absolute time is the multiplication of "clockTick0"
   * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
   * overflow during the application lifespan selected.
   */
  gm_model_biquad_wfa_interfac_M->Timing.taskTime0 =
    ((time_T)(++gm_model_biquad_wfa_interfac_M->Timing.clockTick0)) *
    gm_model_biquad_wfa_interfac_M->Timing.stepSize0;
}

/* Model initialize function */
void gm_model_biquad_wfa_interface_initialize(void)
{
  /* Registration code */

  /* initialize non-finites */
  rt_InitInfAndNaN(sizeof(real_T));
  rtmSetTFinal(gm_model_biquad_wfa_interfac_M, 0.002);
  gm_model_biquad_wfa_interfac_M->Timing.stepSize0 = 0.001;

  /* External mode info */
  gm_model_biquad_wfa_interfac_M->Sizes.checksums[0] = (2392346682U);
  gm_model_biquad_wfa_interfac_M->Sizes.checksums[1] = (2379431917U);
  gm_model_biquad_wfa_interfac_M->Sizes.checksums[2] = (1661481191U);
  gm_model_biquad_wfa_interfac_M->Sizes.checksums[3] = (2993305877U);

  {
    static const sysRanDType rtAlwaysEnabled = SUBSYS_RAN_BC_ENABLE;
    static RTWExtModeInfo rt_ExtModeInfo;
    static const sysRanDType *systemRan[6];
    gm_model_biquad_wfa_interfac_M->extModeInfo = (&rt_ExtModeInfo);
    rteiSetSubSystemActiveVectorAddresses(&rt_ExtModeInfo, systemRan);
    systemRan[0] = &rtAlwaysEnabled;
    systemRan[1] = &rtAlwaysEnabled;
    systemRan[2] = &rtAlwaysEnabled;
    systemRan[3] = &rtAlwaysEnabled;
    systemRan[4] = &rtAlwaysEnabled;
    systemRan[5] = &rtAlwaysEnabled;
    rteiSetModelMappingInfoPtr(gm_model_biquad_wfa_interfac_M->extModeInfo,
      &gm_model_biquad_wfa_interfac_M->SpecialInfo.mappingInfo);
    rteiSetChecksumsPtr(gm_model_biquad_wfa_interfac_M->extModeInfo,
                        gm_model_biquad_wfa_interfac_M->Sizes.checksums);
    rteiSetTPtr(gm_model_biquad_wfa_interfac_M->extModeInfo, rtmGetTPtr
                (gm_model_biquad_wfa_interfac_M));
  }

  /* data type transition information */
  {
    static DataTypeTransInfo dtInfo;
    (void) memset((char_T *) &dtInfo, 0,
                  sizeof(dtInfo));
    gm_model_biquad_wfa_interfac_M->SpecialInfo.mappingInfo = (&dtInfo);
    dtInfo.numDataTypes = 18;
    dtInfo.dataTypeSizes = &rtDataTypeSizes[0];
    dtInfo.dataTypeNames = &rtDataTypeNames[0];

    /* Block I/O transition table */
    dtInfo.BTransTable = &rtBTransTable;

    /* Parameters transition table */
    dtInfo.PTransTable = &rtPTransTable;
  }

  {
    static const char_T tmp[14] = "/dev/mwipcore";
    zynq_AXIWrite_gm_model_biquad_T *obj;
    int32_T i;

    {
      /* user code (Start function Header) */

      /* System '<S1>/model_biquad_wfa' */
      AXI4LITE_RESET_IPCORE("/dev/mwipcore");

      /* Start for FromWorkspace: '<Root>/From Workspace' */
      {
        static real_T pDataValues0[] = { 1.0, 0.92387953251128674,
          0.70710678118654757, 0.38268343236508984, 6.123233995736766E-17,
          -0.38268343236508973, -0.70710678118654746, -0.92387953251128674, -1.0,
          -0.92387953251128685, -0.70710678118654768, -0.38268343236509034,
          -1.8369701987210297E-16, 0.38268343236509, 0.70710678118654735,
          0.92387953251128652, 1.0, 0.92387953251128707, 0.70710678118654835,
          0.38268343236509045, 3.0616169978683831E-16, -0.38268343236508989,
          -0.70710678118654668, -0.92387953251128641, -1.0, -0.9238795325112874,
          -0.70710678118654846, -0.38268343236509056, -4.2862637970157361E-16,
          0.38268343236508978, 0.70710678118654657, 0.92387953251128641 } ;

        gm_model_biquad_wfa_interfac_DW.FromWorkspace_PWORK.TimePtr = (void *) 0;
        gm_model_biquad_wfa_interfac_DW.FromWorkspace_PWORK.DataPtr = (void *)
          pDataValues0;
        gm_model_biquad_wfa_interfac_DW.FromWorkspace_IWORK.PrevIndex = -1;
      }
    }

    /* SystemInitialize for Atomic SubSystem: '<S1>/model_biquad_wfa' */

    /* Start for MATLABSystem: '<S5>/AXI4-Interface Write' */
    gm_model_biquad_wfa_interfac_DW.obj_n.matlabCodegenIsDeleted = true;
    gm_model_biquad_wfa_interfac_DW.obj_n.isInitialized = 0;
    gm_model_biquad_wfa_interfac_DW.obj_n.matlabCodegenIsDeleted = false;
    obj = &gm_model_biquad_wfa_interfac_DW.obj_n;
    gm_model_biquad_wfa_interfac_DW.obj_n.isSetupComplete = false;
    gm_model_biquad_wfa_interfac_DW.obj_n.isInitialized = 1;
    gm_model_biquad_wfa_interfac_DW.obj_n.DeviceState = NULL;
    for (i = 0; i < 14; i++) {
      gm_model_biquad_wfa_interface_B.b_da[i] = tmp[i];
    }

    obj->DeviceState = AXI4LITE_INIT(&gm_model_biquad_wfa_interface_B.b_da[0]);
    gm_model_biquad_wfa_interfac_DW.obj_n.isSetupComplete = true;

    /* End of Start for MATLABSystem: '<S5>/AXI4-Interface Write' */

    /* Start for MATLABSystem: '<S4>/AXI4-Interface Write' */
    gm_model_biquad_wfa_interfac_DW.obj_a.matlabCodegenIsDeleted = true;
    gm_model_biquad_wfa_interfac_DW.obj_a.isInitialized = 0;
    gm_model_biquad_wfa_interfac_DW.obj_a.matlabCodegenIsDeleted = false;
    obj = &gm_model_biquad_wfa_interfac_DW.obj_a;
    gm_model_biquad_wfa_interfac_DW.obj_a.isSetupComplete = false;
    gm_model_biquad_wfa_interfac_DW.obj_a.isInitialized = 1;
    gm_model_biquad_wfa_interfac_DW.obj_a.DeviceState = NULL;
    for (i = 0; i < 14; i++) {
      gm_model_biquad_wfa_interface_B.b_da[i] = tmp[i];
    }

    obj->DeviceState = AXI4LITE_INIT(&gm_model_biquad_wfa_interface_B.b_da[0]);
    gm_model_biquad_wfa_interfac_DW.obj_a.isSetupComplete = true;

    /* End of Start for MATLABSystem: '<S4>/AXI4-Interface Write' */

    /* End of SystemInitialize for SubSystem: '<S1>/model_biquad_wfa' */

    /* Start for MATLABSystem: '<S1>/AXI4-Stream IIO Read' */
    gm_model_biquad_wfa_interfac_DW.obj.buffersAvailable = false;
    gm_model_biquad_wfa_interfac_DW.obj.bufExists = false;
    gm_model_biquad_wfa_interfac_DW.obj.isInitialized = 0;
    gm_model_biquad_wfa_interfac_DW.obj.matlabCodegenIsDeleted = false;
    gm_model_biqua_SystemCore_setup(&gm_model_biquad_wfa_interfac_DW.obj);

    /* Start for MATLABSystem: '<S1>/AXI4-Stream IIO Write' */
    gm_model_biquad_wfa_interfac_DW.obj_o.buffersAvailable = false;
    gm_model_biquad_wfa_interfac_DW.obj_o.bufExists = false;
    gm_model_biquad_wfa_interfac_DW.obj_o.isInitialized = 0;
    gm_model_biquad_wfa_interfac_DW.obj_o.matlabCodegenIsDeleted = false;
    gm_model_biq_SystemCore_setup_n(&gm_model_biquad_wfa_interfac_DW.obj_o);
  }
}

/* Model terminate function */
void gm_model_biquad_wfa_interface_terminate(void)
{
  /* Terminate for MATLABSystem: '<S1>/AXI4-Stream IIO Read' */
  if (!gm_model_biquad_wfa_interfac_DW.obj.matlabCodegenIsDeleted) {
    gm_model_biquad_wfa_interfac_DW.obj.matlabCodegenIsDeleted = true;
    if ((gm_model_biquad_wfa_interfac_DW.obj.isInitialized == 1) &&
        gm_model_biquad_wfa_interfac_DW.obj.isSetupComplete) {
      usleep(1000U);
      gm_model_biquad_base_doTeardown(&gm_model_biquad_wfa_interfac_DW.obj);
    }
  }

  /* End of Terminate for MATLABSystem: '<S1>/AXI4-Stream IIO Read' */
  /* Terminate for MATLABSystem: '<S1>/AXI4-Stream IIO Write' */
  if (!gm_model_biquad_wfa_interfac_DW.obj_o.matlabCodegenIsDeleted) {
    gm_model_biquad_wfa_interfac_DW.obj_o.matlabCodegenIsDeleted = true;
    if ((gm_model_biquad_wfa_interfac_DW.obj_o.isInitialized == 1) &&
        gm_model_biquad_wfa_interfac_DW.obj_o.isSetupComplete) {
      usleep(1000U);
      gm_model_biqu_base_doTeardown_n(&gm_model_biquad_wfa_interfac_DW.obj_o);
    }
  }

  /* End of Terminate for MATLABSystem: '<S1>/AXI4-Stream IIO Write' */

  /* Terminate for Atomic SubSystem: '<S1>/model_biquad_wfa' */

  /* Terminate for MATLABSystem: '<S5>/AXI4-Interface Write' */
  if (!gm_model_biquad_wfa_interfac_DW.obj_n.matlabCodegenIsDeleted) {
    gm_model_biquad_wfa_interfac_DW.obj_n.matlabCodegenIsDeleted = true;
    if ((gm_model_biquad_wfa_interfac_DW.obj_n.isInitialized == 1) &&
        gm_model_biquad_wfa_interfac_DW.obj_n.isSetupComplete) {
      AXI4LITE_TERMINATE(gm_model_biquad_wfa_interfac_DW.obj_n.DeviceState);
    }
  }

  /* End of Terminate for MATLABSystem: '<S5>/AXI4-Interface Write' */

  /* Terminate for MATLABSystem: '<S4>/AXI4-Interface Write' */
  if (!gm_model_biquad_wfa_interfac_DW.obj_a.matlabCodegenIsDeleted) {
    gm_model_biquad_wfa_interfac_DW.obj_a.matlabCodegenIsDeleted = true;
    if ((gm_model_biquad_wfa_interfac_DW.obj_a.isInitialized == 1) &&
        gm_model_biquad_wfa_interfac_DW.obj_a.isSetupComplete) {
      AXI4LITE_TERMINATE(gm_model_biquad_wfa_interfac_DW.obj_a.DeviceState);
    }
  }

  /* End of Terminate for MATLABSystem: '<S4>/AXI4-Interface Write' */

  /* End of Terminate for SubSystem: '<S1>/model_biquad_wfa' */
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
