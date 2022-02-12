`timescale 1 ns / 1 ns

module downsampler_tb ();

  reg clk;
  reg reset;
  reg clk_enable;
  reg [11:0] In1;
  wire ce_out_0;
  wire ce_out_1;
  wire [11:0] Out1;
  wire [11:0] Out2;

  /* clock generation */
  initial begin
    clk <= 1'b0;
    #10; 
    forever begin
      clk <= ~clk;
      #10;
    end
  end

  /* reset generation */
  initial begin
    reset <= 1'b1;
    #100
    reset <= 1'b0;
  end

  /* clock enable generation */
  initial begin
    clk_enable <= 1'b1;
    #10; 
    forever begin
      clk_enable <= 1'b1;
      #20;
      clk_enable <= 1'b0;
      #200;
    end
  end

  /* module instantiation */
  two_stage_downsampler dut (
  .*
  );

  initial begin
    $dumpfile ("downsampler.vcd"); // Change filename as appropriate. 
    $dumpvars(3, downsampler_tb); 

    #100000
    $finish;
  end

endmodule