/**
  Module name:  restoring_division_v1_0
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jun 2022
  Description: Division algorithm using restoring division method
  Revision: 1.0 Module created
**/

module restoring_division_v1_0 #(
  parameter inout_width = 12
)(
  input aclk, 
  input resetn, 

  input signed [inout_width-1:0] numerator, /* numerator */
  input signed [inout_width-1:0] denominator, /* denominator */
  input data_valid, /* start division */

  output reg [inout_width-1:0] quotient, /* quotient result */
  output reg [inout_width-1:0] remainder, /* remainder result */
  output reg data_ready, /* end division algorithm. Data ready in output port */
  output reg error_div0 /* error: division by zero */
);

  localparam index_width = $clog2(inout_width)+1;
  
  reg [2:0] div_status; /* division fsm status */
  reg [index_width-1:0] index; /* input bit index */
  reg signed [inout_width-1:0] quotient_temp; /* temporal quotient */
  reg signed [(inout_width*2)-1:0] remainder_temp; /* temporal remainder */
  reg signed [(inout_width*2)-1:0] denominator_reg; /* denominator registered */

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
    end
    else
      case (div_status)
        2'd0: begin
          if (data_valid && (denominator != 0)) div_status <= 2'd1;
          else div_status <= 2'd0;
          
          denominator_reg <=  {denominator, {inout_width{1'b0}}}; 
          index <= inout_width-1;
          data_ready <= 1'b0;
          error_div0 <= (data_valid && (denominator == 0))? 1'b1: 1'b0;
          quotient_temp <= 0;
          remainder_temp <= numerator;
        end
        2'd1: begin
          div_status <= 2'd2;

          remainder_temp <= {remainder_temp[((inout_width*2)-2):0], 1'b0} - denominator_reg;
        end
        2'd2: begin
          if (index == 0) div_status <= 2'd3;
          else div_status <= 2'd1;

          if (remainder_temp >= 0)
            quotient_temp[index] <= 1'b1;
          else
            remainder_temp <= remainder_temp + denominator_reg;

          index <= index - 1;
        end
        2'd3: begin
          div_status <= 2'd0;

          quotient <= quotient_temp;
          remainder <= remainder_temp >> inout_width;

          data_ready <= 1'b1;
        end

      endcase

endmodule
