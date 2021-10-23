/**
  Module name:  axis_decimator_v1_0
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Ago 2021
  Description: Axis stream decimator
  Revision: 1.0
**/

module axis_decimator_v1_0 #(
  parameter axis_data_width = 32, 
  parameter decimator_factor = 10,
  parameter decimator_factor_width = 4
)(
  input aclk, 
  input resetn, 

  /* master axis interface */
  output [axis_data_width-1:0] m_axis_tdata,
  output reg m_axis_tvalid,
  input m_axis_tready,

  /* slave axis interface */
  input [axis_data_width-1:0] s_axis_tdata, /* {2'bx, w13_data_i, 2'bx, w13_data_q} */
  input s_axis_tvalid,
  output s_axis_tready
);

  reg [decimator_factor_width-1:0] rp_decimator_counter; /* decimator samples counter */

  assign m_axis_tdata = s_axis_tdata;

  assign s_axis_tready = m_axis_tready;

  always @(posedge aclk)
    if (!resetn) begin
      m_axis_tvalid <= 1'b0;
      rp_decimator_counter <= 0;
    end
    else 
      if (s_axis_tvalid && m_axis_tready && (rp_decimator_counter == (decimator_factor-1))) begin
        rp_decimator_counter <= 0;
        m_axis_tvalid <= 1'b1;
      end
      else if (s_axis_tvalid && (rp_decimator_counter < decimator_factor)) begin
        rp_decimator_counter <= rp_decimator_counter + 1;
        m_axis_tvalid <= 1'b0;
      end 
      

endmodule