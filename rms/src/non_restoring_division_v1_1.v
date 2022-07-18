/**
  Module name:  non_restoring_division_v1_0
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jun 2022
  Description: Division algorithm using non restoring division method
  Revision: 1.0 Module created
              1.1 Added data ready signal to inform when the module is ready to accept new data. Changed output data ready signal to data valid,
**/

module non_restoring_division_v1_1 #(
  parameter inout_width = 12
)(
  input aclk, 
  input resetn, 

  input [inout_width-1:0] numerator, /* numerator */
  input [inout_width-1:0] denominator, /* denominator */
  input i_data_valid, /* start division */

  output reg signed [inout_width-1:0] quotient, /* quotient result */
  output reg signed [inout_width-1:0] remainder, /* remainder result */
  output o_data_ready, /* division algorithm ready to process new data */
  output reg o_data_valid, /* end division algorithm. Data ready in output port */
  output reg error_div0 /* error: division by zero */
);

  localparam index_width = $clog2(inout_width)+1;
  
  reg [2:0] div_status; /* division fsm status */
  reg [index_width-1:0] index; /* input bit index */
  reg signed [inout_width-1:0] quotient_temp; /* temporal quotient */
  reg signed [(inout_width*2)-1:0] remainder_temp; /* temporal remainder */
  
  reg signed [(inout_width*2)-1:0] denominator_reg; /* denominator registered */  assign o_o_data_valid = (div_status == 2'd0)? 1'b1: 1'b0;

  always @(posedge aclk)
    if (!resetn) begin
      index <= inout_width-1;
      quotient <= 0;
      quotient_temp <= 0;
      remainder <= 0;
      remainder_temp <= 0;
      denominator_reg <= 0;
      o_data_valid <= 1'b0;
      error_div0 <= 1'b0;
      div_status <= 2'd0;
    end
    else
      case (div_status)
        2'd0: begin
          if (i_data_valid && (denominator != 0)) div_status <= 2'd1;
          else div_status <= 2'd0;
          
          denominator_reg <=  {denominator, {inout_width{1'b0}}}; 
          index <= inout_width-1;
          o_data_valid <= 1'b0;
          error_div0 <= (i_data_valid && (denominator == 0))? 1'b1: 1'b0;
          quotient_temp <= 0;
          remainder_temp <= numerator;
        end
        2'd1: begin
          if (index == 0) div_status <= 2'd2;
          else div_status <= 2'd1;

          if (remainder_temp >= 0) begin
            quotient_temp[index] <= 1'b1;
            remainder_temp <= {remainder_temp[((inout_width*2)-2):0], 1'b0} - denominator_reg;
          end
          else begin
            quotient_temp[index] <= 1'b0;
            remainder_temp <= {remainder_temp[((inout_width*2)-2):0], 1'b0} + denominator_reg;
          end

          index <= index - 1;
        end
        2'd2: begin
          div_status <= 2'd0;
          
          if (remainder_temp < 0) begin
            quotient <= (quotient_temp - (~quotient_temp))-1;
            remainder <= (remainder_temp + denominator_reg) >>> inout_width;
          end
          else begin
            quotient <= (quotient_temp - (~quotient_temp));
            remainder <= remainder_temp >> inout_width;
          end
          
          o_data_valid <= 1'b1;
        end

      endcase

endmodule
