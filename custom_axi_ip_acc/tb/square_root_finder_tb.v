
module square_root_finder_tb ();

  reg clk100mhz;
  reg rst;

  initial begin
    clk100mhz <= 1'b0;
    forever
    #5 clk100mhz <= ~clk100mhz;
  end

  initial begin
    rst <= 1'b0;
    #100
    rst <= 1'b1;
  end

  square_root_finder_v1_0 uut (
  .clk(clk100mhz),
  .rstn(rst),
  .i32_control_register(32'd1),
  .i32_data(),
  .o32_status_register(),
  .or32_data()
  );

endmodule
