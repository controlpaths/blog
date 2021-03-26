/*
 * File Name:         hdl_prj/ipcore/axis_goertzel_v1_0/include/axis_goertzel_addr.h
 * Description:       C Header File
 * Created:           2021-03-13 19:16:38
*/

#ifndef AXIS_GOERTZEL_H_
#define AXIS_GOERTZEL_H_

#define  IPCore_Reset_axis_goertzel                           0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axis_goertzel                          0x4  //enabled (by default) when bit 0 is 0x1
#define  IPCore_PacketSize_AXI4_Stream_Master_axis_goertzel   0x8  //Packet size for AXI4-Stream Master interface, the default value is 1024. The TLAST output signal of the AXI4-Stream Master interface is generated based on the packet size.
#define  IPCore_Timestamp_axis_goertzel                       0xC  //contains unique IP timestamp (yymmddHHMM): 2103131856: 2103131916
#define  cos_input_Data_axis_goertzel                         0x100  //data register for Inport cos_input
#define  wkn_re_Data_axis_goertzel                            0x104  //data register for Inport wkn_re
#define  wkn_im_Data_axis_goertzel                            0x108  //data register for Inport wkn_im

#endif /* AXIS_GOERTZEL_H_ */
