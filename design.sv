`timescale 1ns/1ps

//----------------- Module traffic_ctrl--------------------------------

module traffic_ctrl(clk,rst,VS,PB,light_main,light_side,walk);  

//port declerations  
  
  input clk;
  input rst;                
  input VS;
  input PB;
  output reg[2:0] light_main;
  output reg[2:0] light_side;
  output reg walk;
  
// Traffic Light Encodings
  
  localparam[2:0] RED = 3'b100;
  localparam[2:0] YELLOW = 3'b010;
  localparam[2:0] GREEN = 3'b001;
  
// Timing Parameters (Scalable)
  
  parameter integer T_SCALE = 1;
  parameter integer MAIN_GREEN_T = 60/ T_SCALE;  
  parameter integer SIDE_GREEN_T = 40/ T_SCALE;
  parameter integer PED_GREEN_T = 40/ T_SCALE;  
  parameter integer YELLOW_T = 5/ T_SCALE;
  parameter integer ALL_RED_T = 1/ T_SCALE;
  
//FSM State Encoding
  
  localparam [2:0]S_MG_MIN = 3'b000; // Main green (minimum guaranteed time)
  localparam [2:0]S_MG_EXT = 3'b001; // Main green (extended while no requests)
  localparam [2:0]S_MY = 3'b010; // Main yellow
  localparam [2:0]S_AR1 = 3'b011; // All red before side green
  localparam [2:0]S_SG = 3'b100; // Side green
  localparam [2:0]S_SY = 3'b101; // Side yellow
  localparam [2:0]S_AR2 = 3'b110;// All red before pedestrian or main green
  localparam [2:0]S_PG = 3'b111; // Pedestrian green (walk)
  reg [2:0]state, next_state;
  reg [31:0]timer;
  reg veh_pending;
  reg ped_pending;
  
// ---------------- Sequential logic -------------------
  
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      
// Asynchronous reset, initialize FSM
      
      state <= S_MG_MIN;
      timer<= (MAIN_GREEN_T < 1) ? 1: MAIN_GREEN_T;
      veh_pending <= 1'b0;
      ped_pending <= 1'b0;
    end 
    else begin
      
// Latch incoming requests until serviced 
      
      if (VS)veh_pending <= 1'b1;
      if (PB)ped_pending <= 1'b1;
      
// Extended main green has no fixed timeout
      
      if (state==S_MG_EXT)
        timer <= 0;
      else if(timer != 0)
        timer <= timer - 1;
      
// State transition when timer expires
      
      if (timer == 0) begin
        state <= next_state;
        case (next_state)
          S_MG_MIN: timer <= ((MAIN_GREEN_T < 1) ? 1: MAIN_GREEN_T)-1;
          S_MG_EXT: timer<= 0;
          S_MY: begin
            timer <= ((YELLOW_T < 1) ? 1: YELLOW_T) - 1;
            veh_pending <= 1'b0;
          end
          S_AR1:timer <= ((ALL_RED_T < 1) ? 1: ALL_RED_T) - 1;
          S_SG:timer <= ((SIDE_GREEN_T < 1) ? 1: SIDE_GREEN_T);
          S_SY:timer <= ((YELLOW_T < 1) ? 1: YELLOW_T) - 1;
          S_AR2:timer <= ((ALL_RED_T < 1) ? 1: ALL_RED_T) - 1;
          S_PG: begin
            timer <= ((PED_GREEN_T < 1) ? 1: PED_GREEN_T) - 1;
            ped_pending <= 1'b0;
          end
          default: timer <= 0;
        endcase
      end
    end
  end
  
// ---------------- Next state logic -------------------
  
  always @(*) begin
    next_state = state;
    if (timer == 0) begin
      case (state)
        S_MG_MIN: next_state = (veh_pending || ped_pending) ? S_MY: S_MG_EXT;
        S_MG_EXT: next_state = (veh_pending || ped_pending) ? S_MY: S_MG_EXT;
        S_MY: next_state = S_AR1;
        S_AR1:next_state = S_SG;
        S_SG: next_state = S_SY;
        S_SY: next_state = S_AR2;
        S_AR2:next_state = ped_pending ? S_PG: S_MG_MIN;
        S_PG: next_state = S_MG_MIN;
        default: next_state = S_MG_MIN;
      endcase
    end
  end
  
// ---------------- Output (Moore FSM) ----------------
  
  always @(*) begin
    light_main = RED;
    light_side = RED;
    walk = 1'b0;
    case (state)
      S_MG_MIN,
      S_MG_EXT: light_main = GREEN;
      S_MY:light_main = YELLOW;
      S_SG: light_side = GREEN;
      S_SY:light_side = YELLOW;
      S_PG: walk = 1'b1;
      default: ;
    endcase
  end
endmodule

//---------------reference module-------------------------

module traffic_ctrl_ref #( parameter integer T_SCALE = 1, parameter integer MAIN_GREEN_T = 60/ T_SCALE, parameter integer SIDE_GREEN_T = 40/ T_SCALE, parameter integer PED_GREEN_T = 40/ T_SCALE, parameter integer YELLOW_T = 5 / T_SCALE,parameter integer ALL_RED_T = 1/ T_SCALE)
(
  input clk,
  input rst,
  input VS,
  input PB,
  output reg[2:0] light_main,
  output reg[2:0] light_side,
  output reg walk
);

  localparam[2:0] RED = 3'b100;
  localparam[2:0] YELLOW = 3'b010;
  localparam[2:0] GREEN = 3'b001;
  localparam[2:0] S_MG_MIN = 3'b000;
  localparam[2:0]S_MG_EXT = 3'b001;
  localparam[2:0]S_MY = 3'b010;
  localparam[2:0]S_AR1 = 3'b011;
  localparam[2:0]S_SG = 3'b100;
  localparam[2:0]S_SY = 3'b101;
  localparam[2:0] S_AR2 = 3'b110;
  localparam[2:0]S_PG = 3'b111;
  reg[2:0] state, next_state;
  integer timer;
  reg veh_pending, ped_pending;

// ---------------- Sequential FSM and timer logic -------------------
  
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      state <= S_MG_MIN;
      timer <= (MAIN_GREEN_T < 1) ? 1: MAIN_GREEN_T;
      veh_pending <= 1'b0;
      ped_pending <= 1'b0;
    end else begin
      if (VS) veh_pending <= 1'b1;
      if (PB) ped_pending <= 1'b1;
      if (state == S_MG_EXT)
        timer <= 0;
      else if (timer != 0)
        timer <= timer - 1;
      if (timer == 0) begin
        state <= next_state;
        case (next_state)
          S_MG_MIN:
            timer <= ((MAIN_GREEN_T < 1) ? 1: MAIN_GREEN_T) - 1;
          S_MG_EXT:
            timer <= 0;
          S_MY: begin
            timer <= ((YELLOW_T < 1) ? 1: YELLOW_T) - 1;
            veh_pending <= 1'b0;
          end
          S_AR1:
            timer <= ((ALL_RED_T < 1) ? 1: ALL_RED_T) - 1;
          S_SG:
            timer <= ((SIDE_GREEN_T < 1) ? 1: SIDE_GREEN_T);
          S_SY:
            timer <= ((YELLOW_T < 1) ? 1: YELLOW_T) - 1;
          S_AR2:
            timer <= ((ALL_RED_T < 1) ? 1: ALL_RED_T) - 1;
          S_PG: begin
            timer <= ((PED_GREEN_T < 1) ? 1: PED_GREEN_T) - 1;
            ped_pending <= 1'b0;
          end
          default:
            timer <= 0;
        endcase
      end
    end
  end

  // ---------------- Next state logic -------------------
  
  always @(*) begin
    next_state = state;
    if (timer == 0) begin
      case (state)
        S_MG_MIN: next_state = (veh_pending || ped_pending) ? S_MY: S_MG_EXT;
        S_MG_EXT: next_state = (veh_pending || ped_pending) ? S_MY: S_MG_EXT;
        S_MY:next_state = S_AR1;
        S_AR1:next_state = S_SG;
        S_SG: next_state = S_SY;
        S_SY: next_state = S_AR2;
        S_AR2:next_state = ped_pending ? S_PG: S_MG_MIN;
        S_PG: next_state = S_MG_MIN;
        default: next_state = S_MG_MIN;
      endcase
    end
  end

  // ---------------- Output logic (moore fsm) -----------------------
  
  always @(*) begin
    light_main = RED;
    light_side = RED;
    walk = 1'b0;
    case (state)
      S_MG_MIN,
      S_MG_EXT:light_main = GREEN;
      S_MY:light_main = YELLOW;
      S_SG:light_side = GREEN;
      S_SY:light_side = YELLOW;
      S_PG:walk = 1'b1;
      default: ;
    endcase
  end
endmodule
