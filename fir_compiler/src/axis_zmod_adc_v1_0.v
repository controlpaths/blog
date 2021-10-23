/**
  Module name:  axis_zmod_adc_v1_0
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Feb 2020
  Description: Driver for ad9648. ZMOD ADC from Digilent. Module uses 2 different clock, so it's neccesary use synchronizers
  Revision: 1. Module created.
**/

module axis_zmod_adc_v1_0 #(
  parameter prescaler_clk_spi = 5, /* sclk = aclk / precaler_clk_spi */
  parameter prescaler_clk_spi_width = 3 /* precaler_clk_spi width  */
  )(
  input aclk, /* Clock input */
  input resetn, /* Reset input */

  output reg adc_configured, /* Adc configuration complete signal */

  /* master axis interface */
  output [31:0] m_axis_tdata,
  output reg m_axis_tvalid,
  input m_axis_tready,

  input signed [13:0] ddr_data, /* Parallel input data from ADC */
  input ddr_clk, /* Input clock select*/

  output adc_sync, /* ADC SPI sync */
  output reg spi_sck, /* ADC SPI aclk out */
  output reg spi_cs, /* ADC SPI data IO  */
  output spi_sdio /* ADC SPI cs out */
  );

  localparam p_spi_pwrmode_add = 13'h08;
  localparam p_spi_pwrmode_value_reset = 8'h3c;
  localparam p_spi_pwrmode_value_release = 8'h00;
  localparam p_spi_chipid_add = 13'h01;
  localparam p_spi_chselect_add = 13'h05;
  localparam p_spi_chselect_value_cha = 8'h01; /* cha select */
  localparam p_spi_chselect_value_chb = 8'h02; /* chb select */
  localparam p_spi_chselect_value_both = 8'h03; /* BOTH SELECT */
  localparam p_spi_omode_add = 13'h14;
  localparam p_spi_omode_value_cha = 8'h31; /* CMOS | INTERLEAVED | DISABLED OPORT | 2s COMPLEMENT*/
  localparam p_spi_omode_value_chb = 8'h21; /* CMOS | INTERLEAVED | ENABLED OPORT | 2s COMPLEMENT*/
  localparam p_spi_testmode_add = 13'h0D;
  localparam p_spi_testmode_value_ramp = 8'h4f; /* REPEAT PATTERN | PATTERN RAMP */
  localparam p_spi_testmode_value_disabled = 8'h40; /* REPEAT PATTERN | TEST DISABLED*/

  /* ADC controller */
  reg [23:0] r24_spi_data_out;    /* Synchronizer 0 spi_data_out. RW | W[1:0] | A[12:0] | DATA[7:0]*/
  reg r_spi_start; /* Sychronyzer 0 spi_start */
  reg [26:0] r27_delay_1ms_counter; /* Initial 1ms delay counter*/
  reg [4:0] r5_adc_config_state; /* ADC controller state */
  reg r_cmd_read; /* Read command signal */
  wire w_spi_busy; /* SPI busy signal */
  reg [prescaler_clk_spi_width-1:0] spi_tick_prescaler_counter; /* prescaler counter for spi tick */
  reg spi_tick; /* spi clock enable*/
  reg [1:0] r2_spi_state; /* SPI controller state */
  reg [4:0] r5_data_counter; /* SPI data to write signal */

  /* ddr data read */
  wire [13:0] w14_data_i; /* data channel I*/
  wire [13:0] w14_data_q; /* data channel Q*/

  assign adc_sync = 1'b0;

  assign m_axis_tdata = { {2{w14_data_i[13]}}, w14_data_i, {2{w14_data_q[13]}}, w14_data_q};
  
  always @(posedge aclk) 
    m_axis_tvalid <= m_axis_tready;

  /* ADC configuration  */

  /* spi tick generator */
  always @(posedge aclk)
    if (!resetn) begin
      spi_tick <= 1'b0;
      spi_tick_prescaler_counter <= 0;
    end
    else
      if (spi_tick_prescaler_counter >= prescaler_clk_spi) begin
        spi_tick <= 1'b1;
        spi_tick_prescaler_counter <= 0;
      end
      else begin
        spi_tick <= 1'b0;
        spi_tick_prescaler_counter <= spi_tick_prescaler_counter + 1;
      end

  always @(posedge aclk)
    if (!resetn) begin
      r5_adc_config_state <= 5'd0;
      r24_spi_data_out <= 24'd0;
      r_spi_start <= 1'b0;
      r27_delay_1ms_counter <= 27'd0;
      adc_configured <= 1'b0;
      r_cmd_read <= 1'b0;
    end
    else
      if (spi_tick)
        case (r5_adc_config_state)
          0: begin
            if (r27_delay_1ms_counter == 27'd100000) r5_adc_config_state <= 5'd1;
            else r5_adc_config_state <= 5'd0;

            r27_delay_1ms_counter <= r27_delay_1ms_counter+27'd1;
          end
          1: begin
            r5_adc_config_state <= 5'd2;

            r24_spi_data_out <= {1'b0, 2'b00, p_spi_chselect_add, p_spi_chselect_value_both};
            r_spi_start <= 1'b1;
            r_cmd_read <= 1'b0;
          end
          2: begin
            if (!w_spi_busy) r5_adc_config_state <= 5'd3;
            else r5_adc_config_state <= 5'd2;

            r_spi_start <= 1'b0;
          end
          3: begin
            r5_adc_config_state <= 5'd4;

            r24_spi_data_out <= {1'b0, 2'b00, p_spi_pwrmode_add, p_spi_pwrmode_value_reset};
            r_spi_start <= 1'b1;
            r_cmd_read <= 1'b0;
          end
          4: begin
            if (!w_spi_busy) r5_adc_config_state <= 5'd5;
            else r5_adc_config_state <= 5'd4;

            r_spi_start <= 1'b0;
          end
          5: begin /* Select chA */
            r5_adc_config_state <= 5'd6;

            r24_spi_data_out <= {1'b0, 2'b00, p_spi_chselect_add, p_spi_chselect_value_cha};
            r_spi_start <= 1'b1;
            r_cmd_read <= 1'b0;
          end
          6: begin
            if (!w_spi_busy) r5_adc_config_state <= 5'd7;
            else r5_adc_config_state <= 5'd6;

            r_spi_start <= 1'b0;
          end
          7: begin /* Output mode*/
            r5_adc_config_state <= 5'd8;

            r24_spi_data_out <= {1'b0, 2'b00, p_spi_omode_add, p_spi_omode_value_cha};
            r_spi_start <= 1'b1;
          end
          8: begin
            if (!w_spi_busy) r5_adc_config_state <= 5'd9;
            else r5_adc_config_state <= 5'd8;

            r_spi_start <= 1'b0;
          end
          9: begin /* Select chB */
            r5_adc_config_state <= 5'd10;

            r24_spi_data_out <= {1'b0, 2'b00, p_spi_chselect_add, p_spi_chselect_value_chb};
            r_spi_start <= 1'b1;
          end
          10: begin
            if (!w_spi_busy) r5_adc_config_state <= 5'd11;
            else r5_adc_config_state <= 5'd10;

            r_spi_start <= 1'b0;
          end
          11: begin /* Output mode */
            r5_adc_config_state <= 5'd12;

            r24_spi_data_out <= {1'b0, 2'b00, p_spi_omode_add, p_spi_omode_value_chb};
            r_spi_start <= 1'b1;
          end
          12: begin
            if (!w_spi_busy) r5_adc_config_state <= 5'd13;
            else r5_adc_config_state <= 5'd12;

            r_spi_start <= 1'b0;
          end
          18: begin /* Select chA*/
            r5_adc_config_state <= 5'd19;

            r24_spi_data_out <= {1'b0, 2'b00, p_spi_chselect_add, p_spi_chselect_value_cha};
            r_spi_start <= 1'b1;
            r_cmd_read <= 1'b0;
          end
          19: begin
            if (!w_spi_busy) r5_adc_config_state <= 5'd20;
            else r5_adc_config_state <= 5'd19;

            r_spi_start <= 1'b0;
          end
          20: begin /* Test mode enabled Ramp*/
            r5_adc_config_state <= 5'd21;

            // r24_spi_data_out <= {1'b0, 2'b00, p_spi_testmode_add, p_spi_testmode_value_disabled};
            r24_spi_data_out <= {1'b0, 2'b00, p_spi_testmode_add, p_spi_testmode_value_ramp};
            r_spi_start <= 1'b1;
            r_cmd_read <= 1'b0;
          end
          21: begin
            if (!w_spi_busy) r5_adc_config_state <= 5'd13;
            else r5_adc_config_state <= 5'd21;

            r_spi_start <= 1'b0;
          end
          13: begin /* Select both channels */
            r5_adc_config_state <= 5'd14;

            r24_spi_data_out <= {1'b0, 2'b00, p_spi_chselect_add, p_spi_chselect_value_both};
            r_spi_start <= 1'b1;
            r_cmd_read <= 1'b0;
          end
          14: begin
            if (!w_spi_busy) r5_adc_config_state <= 5'd15;
            else r5_adc_config_state <= 5'd14;

            r_spi_start <= 1'b0;
          end
          15: begin /* Release reset */
            r5_adc_config_state <= 5'd16;

            r24_spi_data_out <= {1'b0, 2'b00, p_spi_pwrmode_add, p_spi_pwrmode_value_release};
            r_spi_start <= 1'b1;
            r_cmd_read <= 1'b0;
          end
          16: begin
            if (!w_spi_busy) r5_adc_config_state <= 5'd17;
            else r5_adc_config_state <= 5'd16;

            r_spi_start <= 1'b0;
          end
          17: begin
            r5_adc_config_state <= 5'd17;
            /* Configuration completed */
            adc_configured <= 1'b1;
          end
          default:
            r5_adc_config_state <= 5'd0;
        endcase

  /* Output data */
  generate for(genvar i=0; i<=13; i=i+1)
    IDDR #(
    .DDR_CLK_EDGE("OPPOSITE_EDGE"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .SRTYPE("SYNC")
    ) IDDR_ADCDATA (
    .Q1(w14_data_i[i]),
    .Q2(w14_data_q[i]),
    .C(ddr_clk),
    .CE(1'b1),
    .D(ddr_data[i]),
    .R(!adc_configured),
    .S(1'b0)
    );
  endgenerate

  /* SPI controller */
  assign w_spi_busy = (r_spi_start || (r2_spi_state != 4'd0))? 1'b1:1'b0;

  always @(posedge aclk)
    if (!resetn) begin
      r2_spi_state <= 2'd0;
      spi_sck <= 1'b1;
      spi_cs <= 1'b1;
      r5_data_counter <= 5'd23;
    end
    else
      if (spi_tick)
        case (r2_spi_state)
          2'd0: begin
            if (r_spi_start) r2_spi_state <= 2'd1;
            else r2_spi_state <= 2'd0;

            spi_sck <= 1'b0;
            spi_cs <= 1'b1;
            r5_data_counter <= 5'd23;
          end
          2'd1: begin
            r2_spi_state <= 2'd2;

            spi_sck <= 1'b0;
            spi_cs <= 1'b0;
          end
          2'd2: begin
            r2_spi_state <= 2'd3;

            spi_sck <= 1'b1;
            spi_cs <= 1'b0;
          end
          2'd3: begin
            if (r5_data_counter == 0) r2_spi_state <= 2'd0;
            else r2_spi_state <= 2'd2;

            spi_sck <= 1'b0;
            spi_cs <= 1'b0;
            r5_data_counter <= (r5_data_counter>0)? r5_data_counter-5'd1: 0;
          end
        endcase

  assign spi_sdio = r24_spi_data_out[r5_data_counter];

endmodule