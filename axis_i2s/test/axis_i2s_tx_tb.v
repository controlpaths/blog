`timescale 1ns/100ps

module axis_i2s_tx_tb;

  reg aclk;
  wire data_loop;
  
  initial begin
    aclk <= 1'b0;
    #5;
    forever begin
      aclk <= ~aclk;
      #5;
    end
  end

  top_i2s uut (
  .clk100mhz(aclk), 
  .freq_sw(4'b1000),
  /* i2s tx interface */
  .tx_mclk(),
  .tx_lrck(),
  .tx_sclk(),
  .tx_data(data_loop),
  .rx_mclk(),
  .rx_lrck(),
  .rx_sclk(),
  .rx_data(data_loop)
  );

  initial begin
    $dumpfile("i2s_log.vcd");
    $dumpvars;
  end

endmodule