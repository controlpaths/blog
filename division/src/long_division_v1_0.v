/**
  Module name:  long_division_v1_0
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jun 2022
  Description: Division algorithm using long division method
  Revision: 1.0 Module created
**/

module long_division_v1_0 #(
  parameter inout_width = 12
)(
  input aclk, 
  input resetn, 

  input [inout_width-1:0] numerator, /* numerator */
  input [inout_width-1:0] denominator, /* denominator */
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
  reg signed [inout_width-1:0] remainder_temp; /* temporal remainder */
  reg signed [inout_width-1:0] numerator_reg; /* numerator registered*/
  reg signed [inout_width-1:0] denominator_reg; /* denominator_registered */
  reg sign; /* store input sign */

  always @(posedge aclk)
    if (!resetn) begin
      index <= inout_width-1;
      quotient <= 0;
      quotient_temp <= 0;
      remainder <= 0;
      remainder_temp <= 0;
      numerator_reg <= 0;
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
          
          numerator_reg <= numerator; 
          denominator_reg <=  denominator; 
          index <= inout_width-1;
          data_ready <= 1'b0;
          error_div0 <= (data_valid && (denominator == 0))? 1'b1: 1'b0;
          quotient_temp <= 0;
          remainder_temp <= 0;
        end
        2'd1: begin
          div_status <= 2'd2;

          remainder_temp <= {remainder_temp[(inout_width-2):0], numerator_reg[index]};
        end
        2'd2: begin
          if (index == 0) div_status <= 2'd3;
          else div_status <= 2'd1;

          if (remainder_temp >= denominator_reg) begin
            remainder_temp <= remainder_temp - denominator_reg;
            quotient_temp[index] <= 1'b1;            
          end

          index <= index - 1;
        end
        2'd3: begin
          div_status <= 2'd0;

          quotient <= quotient_temp;
          remainder <= remainder_temp;

          data_ready <= 1'b1;
        end

      endcase

endmodule
