/**
  Module name:  square_root_finder
  Author: P Trujillo (pablo@controlpaths.com)
  Date: May 2020
  Description: Module to found the square root by iteration. Example of Custom IP.
  Revision: 1.0 Module created
**/

module square_root_finder_v1_0 (
  input clk,
  input rstn,

  input [31:0] i32_control_register,
  input [31:0] i32_data,
  output [31:0] o32_status_register,
  output reg [31:0] or32_data
);

  wire [63:0] w64_data_square;
  reg [31:0] r32_data_index;
  reg [31:0] r32_data_hold;
  wire w_control_start;
  reg r_end;
  reg r_run;
  reg r_err;
  reg [1:0] r2_state;

  assign w_control_start = i32_control_register[0];
  assign o32_status_register = {29'd0, r_err, r_run, r_end};

  assign w64_data_square = r32_data_index*r32_data_index;

  always @(posedge clk)
    if (!rstn) begin
      r32_data_hold <= 32'd0;
      r32_data_index <= 32'd0;
      or32_data <= 32'd0;
      r_run <= 1'd0;
      r_end <= 1'd0;
      r_err <= 1'd0;
      r2_state <= 2'b00;
    end
    else
      case (r2_state)
        2'b00: begin
          if (w_control_start) r2_state <= 2'b01;
          else r2_state <= 2'b00;

          r32_data_hold <= i32_data;
          r32_data_index <= 32'd1;
          r_run <= 1'd0;
          r_end <= 1'd0;
          r_err <= 1'd0;
        end
      2'b01: begin
        if ((w64_data_square > r32_data_hold) || &r32_data_index) r2_state <= 2'b10;
        else r2_state <= 2'b01;

        r32_data_index <= r32_data_index + 32'd1;

        r_run <= 1'd1;
        r_end <= 1'd0;
        r_err <= 1'd0;
      end
      2'b10: begin
        if (!w_control_start) r2_state <= 2'b00;
        else r2_state <= 2'b10;

        r_run <= 1'd0;
        r_end <= 1'd1;
        r_err <= &r32_data_index? 1'b1:1'b0;
        or32_data <= r32_data_index-2;
      end
      2'b11:
        r2_state <= 2'b00;

      endcase

endmodule
