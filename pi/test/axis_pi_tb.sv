/**
  Module name:  axis_pi
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Mar 2022
  Description: testbench for the PI regulator
  Revision: 1.0 Module created
**/

`timescale 1ns/1ns

`define _clkcycle 10
`define _1us 1000
`define _10us 10000

`define error_allowed 10

module axis_pi_tb();

  parameter inout_width = 16;
  parameter inout_decimal_width = 14;
  parameter gain_width = 16;
  parameter gain_decimal_width = 14;
  parameter internal_width = 16;
  parameter internal_decimal_width = 14;

  real kp_real;
  real ki_real;
  real ki_gain;
  real input_real;
  real model_input_real;
  real reference_real;
  real model_reference_real;
  real model_output_nsat;
  real module_output;
  real output_max_real;
  real output_min_real;
  real model_error;
  real model_output_real;
  real error_model_module;
  integer model_output = 0;
  real model_proportional = 0;
  real model_integral = 0;

  reg aclk;
  reg resetn;

  initial begin
    aclk <= 1'b0;
    #(`_clkcycle / 2);
    forever begin
      aclk <= ~aclk;
      #(`_clkcycle / 2);
    end
  end

  /* regulator constants */
  reg [gain_width-1:0] kp;
  reg [gain_width-1:0] ki;

  reg signed [inout_width-1:0] output_max; 
  reg signed [inout_width-1:0] output_min; 

  /* slave axis input */
  reg signed [inout_width-1:0] s_axis_input_tdata;
  reg s_axis_input_tlast;
  reg s_axis_input_tvalid;
  wire s_axis_input_tready;

  /* slave axis reference */
  reg signed [inout_width-1:0] s_axis_reference_tdata;
  reg s_axis_reference_tlast;
  reg s_axis_reference_tvalid;
  wire s_axis_reference_tready;

  /* master axis output */
  wire signed [inout_width-1:0] m_axis_output_tdata;
  wire m_axis_output_tlast;
  wire m_axis_output_tvalid;
  reg m_axis_output_tready;

  /* Auxiliar functions */
  function real2fp();
    begin
      kp = kp_real * 2**(gain_decimal_width);
      ki = ki_real * 2**(gain_decimal_width);
      output_max = output_max_real * 2**(gain_decimal_width);
      output_min = output_min_real * 2**(gain_decimal_width);
      s_axis_input_tdata = input_real * 2**(inout_decimal_width);
      s_axis_reference_tdata = reference_real * 2**(inout_decimal_width);
    end
  endfunction

  function compute_model();
    begin
      model_error = (reference_real - input_real);

      model_proportional = model_error * kp_real;
      model_integral = model_integral + (model_error * ki_real);
      model_output_real = (model_proportional + model_integral) ;
      model_output = model_output_real * 2**(inout_decimal_width);
    end
  endfunction

  function compute_model_sat();
    begin
      model_error = (reference_real - input_real);

      model_proportional = model_error * kp_real;

      ki_gain = ((reference_real - input_real) * ki_real);

      if (((model_output_nsat < output_max_real) && (model_output_nsat > output_min_real))
           || ((model_output_nsat > output_max_real) && (ki_gain < 0))
           || ((model_output_nsat < output_min_real) && (ki_gain > 0)))
        model_integral = model_integral + (model_error * ki_real);
      else 
        model_integral = model_integral;

      model_output_nsat = (model_proportional + model_integral);

      if (model_output_nsat > output_max_real)
        model_output_real = output_max_real;
      else if (model_output_nsat < output_min_real)
        model_output_real = output_min_real;
      else 
        model_output_real = model_output_nsat;
      
      model_output = model_output_real * 2**(inout_decimal_width);
    end
  endfunction

  function compute_model_loopback();
    begin
      model_error = (model_reference_real - model_input_real);

      model_proportional = model_error * kp_real;

      ki_gain = ((reference_real - input_real) * ki_real);

      if (((model_output_nsat < output_max_real) && (model_output_nsat > output_min_real))
           || ((model_output_nsat > output_max_real) && (ki_gain < 0))
           || ((model_output_nsat < output_min_real) && (ki_gain > 0)))
        model_integral = model_integral + (model_error * ki_real);
      else 
        model_integral = model_integral;

      model_output_nsat = (model_proportional + model_integral);

      if (model_output_nsat > output_max_real)
        model_output_real = output_max_real;
      else if (model_output_nsat < output_min_real)
        model_output_real = output_min_real;
      else 
        model_output_real = model_output_nsat;
      
      model_output = model_output_real * 2**(inout_decimal_width);
    end
  endfunction

  function loopback();
    begin
      model_input_real = model_output_real;
      s_axis_input_tdata = m_axis_output_tdata;
    end
  endfunction

  function check_model();
    begin
      if ((m_axis_output_tdata <= (model_output + `error_allowed)) && (m_axis_output_tdata >= (model_output - `error_allowed))) begin
        $info("TEST OK: Module output is %0d and expected output is %0d", m_axis_output_tdata, model_output);
      end
      else begin
        $error("TEST FAILED: Module output is %0d and model output is %0d", m_axis_output_tdata, model_output);
        // $finish();
      end
    end
  endfunction 

  function check_error();
    begin
      error_model_module = (model_output - m_axis_output_tdata) / 2**(inout_decimal_width);
    end
  endfunction 

  function reset_model();
    begin
      $info("Resetting model.");
      model_proportional = 0;
      model_integral = 0;
      model_output = 0;
      model_output_nsat = 0;
      model_output_real = 0;
    end
  endfunction

  axis_pi_v1_0 #(
  .inout_width(inout_width), 
  .inout_decimal_width(inout_decimal_width), 
  .internal_width(internal_width),
  .internal_decimal_width(internal_decimal_width),
  .gain_width(gain_width),
  .gain_decimal_width(gain_decimal_width)
  ) uut (
    .*
  );

  /* TEST flow */
  initial begin
    
    $dumpfile ("sim_data.vcd"); // Change filename as appropriate. 
    $dumpvars(); 
    
    /* initial conditions */
    $info("Setting initial conditions.");
    
    resetn <= 1'b0; /* Module reset */

    output_max_real = 1.9;
    output_min_real = -1.9;

    kp_real = 0.01;
    ki_real = 0.001;
    input_real = 0;
    reference_real = 0;
    real2fp();

    s_axis_input_tlast <= 1'b0;
    s_axis_input_tvalid <= 1'b0;

    s_axis_reference_tlast <= 1'b0;
    s_axis_reference_tvalid <= 1'b0;

    m_axis_output_tready <= 1'b1;
    reset_model();

    /* test kp gain */
    $display("####################################");
    $info("Testing proportional gain.");
    
    $info("Wait 1us.");
    #(`_1us);
    $info("Release module reset");
    resetn <= 1'b1;
    $info("Wait 1us.");
    #(`_1us);
    
    kp_real = 0.01;
    ki_real = 0;
    $info("Set kp = %0.5f and ki = %0.5f", kp_real, ki_real);

    input_real = 0.1;
    reference_real = 0;
    $info("Set input = %0.5f and reference = %0.5f", input_real, reference_real);
    
    real2fp();
    $info("Wait 1 clk cycle.");
    #(`_clkcycle);

    $info("Set data valid signal.");
    s_axis_input_tvalid <= 1'b1;
    #(`_clkcycle);
    s_axis_input_tvalid <= 1'b0;
    
    /* compute output from PI model */
    compute_model();

    /* Compare model and module responses */
    check_model();

    /* test ki gain */
    $display("####################################");
    $info("Testing integral gain.");
    
    reset_model();

    $info("Wait 1us.");
    #(`_1us);
    $info("Release module reset");
    resetn <= 1'b1;
    $info("Wait 1us.");
    #(`_1us);
    
    kp_real = 0;
    ki_real = 0.001;
    $info("Set kp = %0.5f and ki = %0.5f", kp_real, ki_real);

    input_real = 0.15;
    reference_real = 0;
    $info("Set input = %0.5f and reference = %0.5f", input_real, reference_real);
    
    real2fp();
    $info("Wait 1 clk cycle.");
    #(`_clkcycle);

    $info("Set data valid signal.");
    s_axis_input_tvalid <= 1'b1;
    #(`_clkcycle);
    s_axis_input_tvalid <= 1'b0;
    #(`_clkcycle);
    
    /* compute output from PI model */
    compute_model();

    /* Compare model and module responses */
    check_model();

    $info("Repeat 50 times with same conditions.");
    
    repeat(50) begin
      s_axis_input_tvalid <= 1'b1;
      #(`_clkcycle);
      s_axis_input_tvalid <= 1'b0;
    
      /* compute output from PI model */
      compute_model();
    end

    /* Compare model and module responses */
    check_model();

    $info("Repeat 500 times with same conditions.");
    
    repeat(500) begin
      s_axis_input_tvalid <= 1'b1;
      #(`_clkcycle);
      s_axis_input_tvalid <= 1'b0;

      /* compute output from PI model */
      compute_model();
    end

    /* Compare model and module responses */
    check_model();

    // $info("Repeat 5000 times with same conditions.");
    
    // repeat(5000) begin
    //   s_axis_input_tvalid <= 1'b1;
    //   #(`_clkcycle);
    //   s_axis_input_tvalid <= 1'b0;

    //   compute_model();
    // end

    // if ((m_axis_output_tdata <= (model_output + 1)) && (m_axis_output_tdata >= (model_output - 1))) begin
    //   $info("TEST OK: Module output is %0d and expected output is %0d", m_axis_output_tdata, model_output);
    // end
    // else begin
    //   $error("TEST FAILED: Module output is %0d and expected output is %0d", m_axis_output_tdata, model_output);
    //   $finish();
    // end

    /* test kp + ki gain */
    $display("####################################");
    $info("Testing proportional + integral gain.");

    reset_model();

    $info("Reset module.");
    resetn <= 1'b0;
    $info("Wait 1us.");
    #(`_1us);
    $info("Release module reset");
    resetn <= 1'b1;
    $info("Wait 1us.");
    #(`_1us);
    
    kp_real = 0.1;
    ki_real = 0.001;
    $info("Set kp = %0.5f and ki = %0.5f", kp_real, ki_real);

    input_real = 0.0;
    reference_real = 0.1;
    $info("Set input = %0.5f and reference = %0.5f", input_real, reference_real);
    
    real2fp();
    $info("Wait 1 clk cycle.");
    #(`_clkcycle);

    $info("Set data valid signal.");
    s_axis_input_tvalid <= 1'b1;
    #(`_clkcycle);
    s_axis_input_tvalid <= 1'b0;
    #(`_clkcycle);

    /* compute output from PI model */
    compute_model();

    /* Compare model and module responses */
    check_model();

    $info("Repeat 50 times with same conditions.");
    
    repeat(50) begin
      s_axis_input_tvalid <= 1'b1;
      #(`_clkcycle);
      s_axis_input_tvalid <= 1'b0;

      /* compute output from PI model */
      compute_model();
    end

    /* Compare model and module responses */
    check_model();

    /* test saturation */
    $display("####################################");
    $info("Testing saturation.");

    reset_model();

    $info("Reset module.");
    resetn <= 1'b0;
    $info("Wait 1us.");
    #(`_1us);
    $info("Release module reset");
    resetn <= 1'b1;
    $info("Wait 1us.");
    #(`_1us);
    
    kp_real = 0.8;
    ki_real = 0.01;
    $info("Set kp = %0.5f and ki = %0.5f", kp_real, ki_real);

    $info("Test positive saturation");
    input_real = 0.0;
    reference_real = 1.0;
    $info("Set input = %0.5f and reference = %0.5f", input_real, reference_real);
    
    output_max_real = 1.9;
    output_min_real = -1.9;
    $info("Set positive saturation = %0.5f and negative saturation = %0.5f", output_max_real, output_min_real);

    real2fp();

    $info("Repeat 300 times with same conditions.");
    
    repeat(300) begin
      s_axis_input_tvalid <= 1'b1;
      #(`_clkcycle);
      s_axis_input_tvalid <= 1'b0;

      /* compute output from PI model */
      compute_model_sat();
    end

    /* Compare model and module responses */
    check_model();    

    $info("Test negative saturation");
    input_real = 0.0;
    reference_real = -1.0;
    $info("Set input = %0.5f and reference = %0.5f", input_real, reference_real);

    real2fp();

    $info("Repeat 300 times with same conditions.");
    
    repeat(300) begin
      s_axis_input_tvalid <= 1'b1;
      #(`_clkcycle);
      s_axis_input_tvalid <= 1'b0;

      /* compute output from PI model */
      compute_model_sat();
    end

    /* Compare model and module responses */
    check_model();   

    /* test loopback */
    $display("####################################");
    $info("Loopback test.");

    reset_model();

    $info("Reset module.");
    resetn <= 1'b0;
    $info("Wait 1us.");
    #(`_1us);
    $info("Release module reset");
    resetn <= 1'b1;
    $info("Wait 1us.");
    #(`_1us);
    
    kp_real = 0.8;
    ki_real = 0.01;
    $info("Set kp = %0.5f and ki = %0.5f", kp_real, ki_real);

    input_real = 0.0;
    reference_real = -1.0;
    model_reference_real = reference_real;
    $info("Set reference = %0.5f", reference_real);

    real2fp();

    $info("Repeat 1000 times with same conditions.");
    
    $info("Wait 1us.");
    #(`_1us);

    repeat(1000) begin

      s_axis_input_tvalid <= 1'b1;
      #(`_clkcycle);
      s_axis_input_tvalid <= 1'b0;

      /* compute output from PI model */
      compute_model_loopback();

      /* perform loopback */
      loopback();

      /* compute error between model and module */
      check_error();
    end

    /* Compare model and module responses */
    check_model();   

    reference_real = 1.1;
    model_reference_real = reference_real;
    $info("Set reference = %0.5f", reference_real);

    real2fp();

    $info("Repeat 1000 times with same conditions.");
    
    $info("Wait 1us.");
    #(`_1us);

    repeat(1000) begin

      s_axis_input_tvalid <= 1'b1;
      #(`_clkcycle);
      s_axis_input_tvalid <= 1'b0;

      /* compute output from PI model */
      compute_model_loopback();

      /* perform loopback */
      loopback();

      /* compute error between model and module */
      check_error();
    end

    /* Compare model and module responses */
    check_model();   

  $finish;

  end

endmodule
