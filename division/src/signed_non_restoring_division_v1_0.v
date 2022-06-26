/**
  Module name:  signed_non_restoring_division_v1_0
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jun 2022
  Description: Division algorithm using non restoring division method with signed numbers
  Revision: 1.0 Module created
**/

module signed_non_restoring_division_v1_0 #(
  parameter inout_width = 12
)(
  input aclk, 
  input resetn, 

  input signed [inout_width-1:0] numerator, /* numerator */
  input signed [inout_width-1:0] denominator, /* denominator */
  input data_valid, /* start division */

  output reg signed [inout_width-1:0] quotient, /* quotient result */
  output reg signed [inout_width-1:0] remainder, /* remainder result */
  output reg data_ready, /* end division algorithm. Data ready in output port */
  output reg error_div0 /* error: division by zero */
);

  localparam index_width = $clog2(inout_width)+1;
  
  reg [2:0] div_status; /* division fsm status */
  reg [index_width-1:0] index; /* input bit index */
  reg signed [inout_width-1:0] quotient_temp; /* temporal quotient */
  reg signed [(inout_width*2)-1:0] remainder_temp; /* temporal remainder */
  reg signed [(inout_width*2)-1:0] denominator_reg; /* denominator registered */
  reg sign; /* signed stored */

  always @(posedge aclk)
    if (!resetn) begin
      index <= inout_width-1;
      quotient <= 0;
      quotient_temp <= 0;
      remainder <= 0;
      remainder_temp <= 0;
      denominator_reg <= 0;
      data_ready <= 1'b0;
      error_div0 <= 1'b0;
      div_status <= 2'd0;
      sign <= 1'b0;
    end
    else
      case (div_status)
        2'd0: begin
          if (data_valid && (denominator != 0)) div_status <= 2'd1;
          else div_status <= 2'd0;
          
          denominator_reg <=  denominator[inout_width-1]? {-denominator, {inout_width{1'b0}}}: {denominator, {inout_width{1'b0}}}; 
          index <= inout_width-1;
          data_ready <= 1'b0;
          error_div0 <= (data_valid && (denominator == 0))? 1'b1: 1'b0;
          quotient_temp <= 0;
          remainder_temp <= numerator[inout_width-1]? -numerator: numerator;
          sign = denominator[inout_width-1] ^ numerator[inout_width-1];
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
            quotient <= sign? -(quotient_temp - (~quotient_temp))+1: (quotient_temp - (~quotient_temp))-1;
            remainder <= (remainder_temp + denominator_reg) >>> inout_width;
          end
          else begin
            quotient <= sign? -(quotient_temp - (~quotient_temp)): (quotient_temp - (~quotient_temp));
            remainder <= remainder_temp >> inout_width;
          end
          
          data_ready <= 1'b1;
        end

      endcase

endmodule
