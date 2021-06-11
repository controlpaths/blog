/**
  Module name:  axis_xfft_config
  Author: P Trujillo (pablo@controlpaths.com)
  Date: May 2021
  Description: Module to manage the axis config channel of xfft.
  Revision: 1.0 Module created
**/

module axis_xfft_config_v1_0 (
  input aclk, 
  input resetn, 

  /* master axis interface */
  output reg [15:0] m_axis_tdata, /* fixed width for up to 16 bit xfft */
  output reg m_axis_tlast,
  output reg m_axis_tvalid,
  input m_axis_tready
  );

  reg configuration_done;

  always @(posedge aclk)
    if (!resetn) begin
      m_axis_tdata <= 16'd0;
      configuration_done <= 1'b0;
      m_axis_tvalid <= 1'b1;
    end 
    else 
      if (m_axis_tready && !configuration_done) begin
        m_axis_tdata <= 16'd0;
        m_axis_tvalid <= 1'b1;
        configuration_done <= 1'b1;
      end
      else begin
        m_axis_tdata <= 16'd0;
        m_axis_tvalid <= 1'b0;
        configuration_done <= 1'b1;
      end


endmodule