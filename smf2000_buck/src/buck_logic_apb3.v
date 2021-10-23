/**
  Module name:  buck_logic_apb3
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Sept 2021
  Description: Module that contains the main logic to control the Buck stage with APB3 interface.
  Revision: 1. Module created.
**/

module buck_logic_apb3 (
  input pclk, 
  input presetn,

  /* apb3 interface */
  input [7:0] paddr, /* register address */
  input penable, /* enable peripheral bit */
  input psel, /* selected peripheral bit */
  input pwrite, /* write enable */
  input [7:0] pwdata, /* data register to write */
  output reg [7:0] prdata, /* data register to read */

  /* measures */
  input [15:0] input_current, /* power stage measures */
  input [15:0] input_voltage, /* power stage measures */
  input [15:0] output_current, /* power stage measures */
  input [15:0] output_voltage /* power stage measures */
);

  /* register addreses */
  localparam input_current_add = 8'd1; /* measure register. read only */
  localparam input_voltage_add = 8'd2; /* measure register. read only */
  localparam output_current_add = 8'd3; /* measure register. read only */
  localparam output_voltage_add = 8'd4; /* measure register. read only */

  wire wr_enable; /* write enable logic */
  wire rd_enable; /* read enable logic */

  assign wr_enable = penable & psel & pwrite;
  assign rd_enable = psel & !pwrite;

  /* read logic */
  always @(*)
    if (!presetn)
      prdata <= 8'd0;
    else 
      if (rd_enable)
        case (paddr)
          input_current_add: begin
            prdata <= input_current[15-:8];
          end
          input_voltage_add: begin
            prdata <= input_voltage[15-:8];
          end
          output_current_add: begin
            prdata <= output_current[15-:8];
          end
          output_voltage_add: begin
            prdata <= output_voltage[15-:8];
          end
          default: begin
            prdata <= 8'd0;
          end
        endcase

endmodule