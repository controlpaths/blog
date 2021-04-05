/*
 * File Name:         hdl_prj/ipcore/axis_goertzel_ip_v1_0/include/axis_goertzel_ip_addr.h
 * Description:       C Header File
 * Created:           2021-03-26 18:29:38
*/

#ifndef AXIS_GOERTZEL_IP_H_
#define AXIS_GOERTZEL_IP_H_

#define  IPCore_Reset_axis_goertzel_ip                           0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_axis_goertzel_ip                          0x4  //enabled (by default) when bit 0 is 0x1
#define  IPCore_PacketSize_AXI4_Stream_Master_axis_goertzel_ip   0x8  //Packet size for AXI4-Stream Master interface, the default value is 1024. The TLAST output signal of the AXI4-Stream Master interface is generated based on the packet size.
#define  IPCore_Timestamp_axis_goertzel_ip                       0xC  //contains unique IP timestamp (yymmddHHMM): 2103261814: 2103261815: 2103261829
#define  axi4_incos_Data_axis_goertzel_ip                        0x100  //data register for Inport axi4_incos
#define  axi4_wkn_Data_axis_goertzel_ip                          0x104  //data register for Inport axi4_wkn

#endif /* AXIS_GOERTZEL_IP_H_ */
