`timescale 1ns/1ps
module traffic_ctrl_tb;
  
//--------------- Signal Declarations ------------------------------
  
  reg clk,rst,VS,PB;
  
//------------------DUT outputs-----------------------  
  
  wire[2:0] dut_m, dut_s;
  wire dut_w;
  
//--------------------reference model outputs-------------  
  
  wire[2:0] ref_m, ref_s;
  wire ref_w;

  integer errors, cycle; 
  
// ---------------- Traffic Light State Encodings ----------------
  
  localparam[2:0] RED = 3'b100;
  localparam[2:0] YELLOW = 3'b010;
  localparam[2:0] GREEN = 3'b001;
  
// ---------------- Timing parameters (scaled) ----------------
  
  localparam integer T_SCALE = 1;
  localparam integer MAIN_GREEN_T = 60/ T_SCALE;
  localparam integer SIDE_GREEN_T = 40/ T_SCALE;
  localparam integer PED_GREEN_T = 40/ T_SCALE;
  localparam integer YELLOW_T = 5/ T_SCALE;
  localparam integer ALL_RED_T = 1/ T_SCALE;
  
//------------DUT instantiation-------------------
  
  traffic_ctrl #(.T_SCALE(T_SCALE),.MAIN_GREEN_T(MAIN_GREEN_T),.SIDE_GREEN_T(SIDE_GREEN_T),.PED_GREEN_T(PED_GREEN_T),.YELLOW_T(YELLOW_T),.ALL_RED_T(ALL_RED_T))
  DUT(.clk(clk),.rst(rst),.VS(VS),.PB(PB),.light_main(dut_m), .light_side(dut_s),.walk(dut_w));
  
//--------------- Reference Model instatiation-----------------
  
  traffic_ctrl_ref #(.T_SCALE(T_SCALE),.MAIN_GREEN_T(MAIN_GREEN_T), .SIDE_GREEN_T(SIDE_GREEN_T),.PED_GREEN_T(PED_GREEN_T),.YELLOW_T(YELLOW_T),.ALL_RED_T(ALL_RED_T))
  REF (.clk(clk),.rst(rst),.VS(VS),.PB(PB),.light_main(ref_m),.light_side(ref_s),.walk(ref_w));
  // ---------------Clock generation (10 ns period)--------------------
  
   always #5 clk = ~clk;
  
//---------------- Cycle by cycle comparison---------------------
  
  always @(negedge clk) begin
    if (rst) begin
      cycle = cycle + 1;
      if (dut_m === ref_m && dut_s === ref_s && dut_w === ref_w) begin
      end 
      else begin
        $display("MISMATCH at cycle %0d", cycle);
        $display("DUT:M=%b S=%b W=%b",dut_m,dut_s,dut_w);
        $display("REF:M=%b S=%b W=%b",ref_m,ref_s,ref_w);
        if (dut_m!==ref_m) $display("light_main mismatch");
        if (dut_s!==ref_s) $display("light_side mismatch");
        if (dut_w!==ref_w) $display("walk mismatch");
        errors = errors + 1;
      end
    end
  end
//-------------------------test sequence ---------------------------
  initial begin
  $dumpfile("traffic_ctrl.vcd");
  $dumpvars(0, clk, rst, VS, PB);
  $dumpvars(0, dut_m, dut_s, dut_w);
  $dumpvars(0, ref_m, ref_s, ref_w);
 //initial conditions
    clk = 1'b0;
    rst = 1'b0;   
    VS = 1'b0;
    PB = 1'b0;
    errors = 0;
    cycle = 0;
    #20;
    rst = 1'b1;
    repeat (3) begin
      #100 VS = 1'b1;  
      #10 VS = 1'b0;
      #200 PB = 1'b1;  
      #10 PB = 1'b0;
    end
    #500000;
//final report
    $display("======================================");
    if (errors==0) begin
      $display("RESULT: DUT MATCHES REFERENCE MODEL");
    end else begin
      $display("RESULT: DUT DOES NOT MATCH REFERENCE");
      $display("Total mismatches = %0d", errors);
    end
    $display("======================================");

    $finish;
  end
endmodule
