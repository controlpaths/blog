/**
  Module name:  non_restoring_sqrt_v1_0
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jul 2022
  Description: Square root algorithm using non restoring method
  Revision: 1.0 Module created
**/

module non_restoring_sqrt_v1_0 #(
  parameter inout_width = 16
)(
  input aclk, 
  input resetn, 

  input [(inout_width*2)-1:0] radicand, /* radicand */
  input i_data_valid, /* start division */
  output i_data_ready, /* algorithm ready to accept new data */

  output reg [inout_width-1:0] root, /* quotient result */
  output reg o_data_valid, /* end division algorithm. Data ready in output port */
  output reg error_value0 /* error: division by zero */
);

  localparam index_width = $clog2(inout_width)+1;
  
  reg [2:0] sqrt_status; /* division fsm status */
  reg [index_width-1:0] index; /* input bit index */
  reg [(inout_width*2)-1:0] radicand_reg; /* radicand registered */
  reg [inout_width-1:0] root_temp; /* quotient result */
  wire [(inout_width*2)-1:0] root_temp_square; /* quotient result */
  wire signed [inout_width:0] remainder; /* remainder of check */

  /* square temporal root */
  assign root_temp_square = root_temp * root_temp; 

  assign i_data_ready = ((sqrt_status == 0) && !i_data_valid)? 1'b1: 1'b0;
  
  always @(posedge aclk)
    if (!resetn) begin
      sqrt_status <= 2'd0;
      index <= inout_width-1;
      root_temp <= {1'b1, {(inout_width-2){1'b0}}};
      radicand_reg <= 0;
      o_data_valid <= 1'b0;
      root <= 0;
    end
    else
      case (sqrt_status)
        2'd0: begin
          if (i_data_valid && (radicand != 0)) sqrt_status <= 2'd1;
          else sqrt_status <= 2'd0;

          radicand_reg <= $unsigned(radicand);
          index = inout_width-1;
          error_value0 <= (radicand == 0)? 1'b1: 1'b0;
          o_data_valid <= 1'b0;
          root_temp <= 0;
        end
        2'd1: begin
          sqrt_status <= 2'd2;

          root_temp[index] <= 1'b1;
        end
        2'd2: begin
          if (index == 1) sqrt_status <= 2'd3;
          else sqrt_status <= 2'd1;
          
          root_temp[index] <= (root_temp_square > {{inout_width{1'b0}},radicand_reg})? 1'b0: 1'b1;
          index <= index - 1;
        end
        2'd3: begin
          sqrt_status <= 2'd0;

          root <= root_temp | {{(inout_width-2){1'b0}}, 1'b1}; /* the lsb is always 1 */          
          
          o_data_valid <= 1'b1;
        end

      endcase

endmodule
