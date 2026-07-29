`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////


// control_PUF.v
// Drives: LFSR seed/step, RO enable, ro_counter start, shiftReg enable.
// Waits for: all ro_counters done (finished_all), then pulses srEN in clk_out domain.
// After OUTPUT_WIDTH bits, asserts puf_done and waits for next start.

`default_nettype none

module control_PUF #(
  parameter integer OUTPUT_WIDTH  = 64,
  parameter integer N_COUNTERS    = 10,   // number of ro_counters you start per bit (set = 2*K_XOR)
  parameter integer SR_PULSE_CYC  = 1     // srEN pulse width in clk_out cycles
)(
  input  wire clk,         // logic clock (counters domain)
  input  wire rst,         // sync reset (active-high)
  input  wire start,       // start a full 128-bit evaluation

  // from SCRO_XOR_PUF
  input  wire finished_all,  // AND of all ro_counter.done[i] (clk domain)
  input  wire shift_done,    // shiftReg done (clk_out domain, for final full-response detect)

  // to SCRO_XOR_PUF (clk domain unless noted)
  output reg  lfsrDV,      // seed LFSR (clk_out domain pulse will be derived inside)
  output reg  lfsrEN,      // one step per bit (clk_out domain pulse will be derived inside)
  output reg  roEN,        // enable ring oscillators during measurement window
  output reg  [N_COUNTERS-1:0] cnt_start, // start pulse for ro_counters
  output reg  cnt_rst,
  // to shiftReg (clk_out domain)
  output reg srEN, // 1-cycle (or SR_PULSE_CYC) pulse in clk_out domain
  output reg  shift_clr,   // synchronous clear for shiftReg counter/contents (clk_out domain via CDC)

  // overall status (clk domain)
  output reg  puf_done,
  output wire led0,
  output wire led1,
  output wire led2,
  output wire led3,
  output wire busy          // high when evaluation in progress
);

  // ============================================================
  // FSM in clk domain
  // ============================================================
  // FSM states
  localparam [3:0]
    S_IDLE   = 0,
    S_SEED   = 1,
    S_PREP   = 2,
    S_START  = 3,
    S_WAIT   = 4,
    S_SHIFT  = 5,
    S_STEP   = 6,
    S_CHECK  = 7,
    S_FINISH = 8,
    S_WAITREL= 9;

  reg [3:0] state, next_state;
  reg [15:0] bit_cnt, next_bit_cnt;
  
    // "next" version of the outputs
  reg next_lfsrDV, next_lfsrEN, next_roEN, next_srEN, next_shift_clr, next_puf_done, next_cnt_rst;
  reg [N_COUNTERS-1:0] next_cnt_start;

  // Sequential
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state    <= S_IDLE;
      bit_cnt  <= 0;
      lfsrDV   <= 0;
      lfsrEN   <= 0;
      roEN     <= 0;
      cnt_start<= 0;
      cnt_rst  <= 0;
      srEN     <= 0;
      shift_clr<= 0;
      puf_done <= 0;
    end else begin
      state    <= next_state;
      bit_cnt  <= next_bit_cnt;

      // outputs are registered
      lfsrDV   <= next_lfsrDV;
      lfsrEN   <= next_lfsrEN;
      roEN     <= next_roEN;
      cnt_start<= next_cnt_start;
      cnt_rst  <= next_cnt_rst;
      srEN     <= next_srEN;
      shift_clr<= next_shift_clr;
      puf_done <= next_puf_done;
    end
  end



  // Combinational
  always @* begin
    next_state      = state;
    next_bit_cnt    = bit_cnt;

    // default outputs
    next_lfsrDV     = 0;
    next_lfsrEN     = 0;
    next_roEN       = 0;
    next_cnt_start  = 0;
    next_cnt_rst    = 0;
    next_srEN       = 0;
    next_shift_clr  = 0;
    next_puf_done   = 0;

    case (state)
      // ------------------------------------
      S_IDLE: begin
        if (start) begin
          next_bit_cnt  = 0;
          next_shift_clr= 1;  // clear shift register
          next_lfsrDV   = 1;  // load challenge into LFSR
          next_cnt_rst  = 1;
          next_state    = S_SEED;
        end
      end

      // ------------------------------------
      S_SEED: begin
        next_lfsrEN   = 1;       // first step
        next_lfsrDV   = 1;
        next_state    = S_PREP;
      end

      // ------------------------------------
//      S_PREP: begin
////        next_cnt_rst  = 1;       // pulse reset counters
//        next_state    = S_COUNT;
//      end

      // ------------------------------------
      S_PREP: begin
        next_roEN      = 1; 
        next_cnt_start = {N_COUNTERS{1'b1}};  // one-cycle start
        next_state     = S_START;
      end
      
      S_START: begin
        next_roEN    = 1'b1;  // keep ROs enabled
        next_state   = S_WAIT;
      end
      

      // ------------------------------------
      S_WAIT: begin
        next_roEN = 1;           // keep ROs running during measure
        if (finished_all) begin
          next_state = S_SHIFT;
        end
      end

      // ------------------------------------
      S_SHIFT: begin
        next_srEN   = 1;         // capture comparator output into shiftReg
        next_state  = S_STEP;
      end

      // ------------------------------------
      S_STEP: begin
        next_lfsrEN = 1;         // advance challenge
        next_state  = S_CHECK;
      end

      // ------------------------------------
      S_CHECK: begin
        next_bit_cnt = bit_cnt + 1;
//        next_cnt_rst = 1'b1;   // reset counters
        if (bit_cnt == (OUTPUT_WIDTH-1)) begin
          next_state = S_FINISH;
        end else begin
          next_state = S_PREP;   // next measurement round
        end
      end

      // ------------------------------------
      S_FINISH: begin
        if (shift_done) begin
          next_puf_done = 1;
          if (!start)
            next_state = S_IDLE;
          else
            next_state = S_WAITREL;
        end
      end

      // ------------------------------------
      S_WAITREL: begin
        if (!start) next_state = S_IDLE;
      end
    endcase
  end

  assign busy = (state != S_IDLE);
  assign led0 = (state == S_IDLE);
  assign led1 = (state == S_CHECK);
  assign led2 = (state == S_FINISH);
  assign led3 = (state == S_WAITREL);
endmodule
  ///commented on Oct 3rd
//  localparam [3:0]
//    S_IDLE     = 4'd0,
//    S_SEED     = 4'd1,
//    S_PREP     = 4'd2,
//    S_START    = 4'd3,
//    S_WAIT     = 4'd4,
//    S_SHIFT    = 4'd5,
//    S_STEP     = 4'd6,
//    S_CHECK    = 4'd7,
//    S_FINISH   = 4'd8,
//    S_WAIT_REL = 4'd9;

//  reg [3:0]  state, next_state;
//  reg [15:0]  bit_cnt, next_bit_cnt;              // up to 128
////  pulse stretcher for srEN if SR_PULSE_CYC>1 (usually 1)
////  reg [7:0]  sr_cnt;
////  wire       sr_busy = (sr_cnt != 0);

//  // ============================================================
//  // FSM
  
//    //----------------------------------------------------------------
//  // Sequential: state and counters
//  //----------------------------------------------------------------
//  always @(posedge clk or posedge rst) begin
//    if (rst) begin
//      state   <= S_IDLE;
//      bit_cnt <= 16'd0;
//    end else begin
//      state   <= next_state;
//      bit_cnt <= next_bit_cnt;
//    end
//  end
  
////----------------------------------------------------------------
//// Combinational: next state and outputs
////----------------------------------------------------------------
// always @* begin
//    next_state  = state;
//    next_bit_cnt= bit_cnt;

//    lfsrDV      = 1'b0;
//    lfsrEN      = 1'b0;
//    roEN        = 1'b0;
//    cnt_start   = {N_COUNTERS{1'b0}};
//    cnt_rst     = 1'b0;
//    srEN        = 1'b0;
//    shift_clr   = 1'b0;
//    puf_done    = 1'b0;

//      case (state)
//        S_IDLE: begin
//          if (start) begin
//          next_bit_cnt = 16'd0;
//          shift_clr    = 1'b1;
//          lfsrDV      <= 1'b1;
//          cnt_rst     = 1'b1;
//          next_state   = S_SEED;
//        end
////        cnt_rst     = 1'b1;
//      end

//        S_SEED: begin
//          // Pulse LFSR seed (clk_out domain logic will see i_Seed_DV=1 for one clk_out)
//          lfsrDV   <= 1'b1;
//          lfsrEN   <= 1'b1;
//          next_state    <= S_PREP;
//        end

//        S_PREP: begin
//          // Start a new measurement window for all counters
//          roEN      <= 1'b1;
//          cnt_start <= {N_COUNTERS{1'b1}}; // one-cycle start
//          next_state     <= S_START;
//        end

//        S_START: begin
//          // Keep RO enabled, counters are running now
//          roEN   <= 1'b1;
//          next_state  <= S_WAIT;
//        end

//        S_WAIT: begin
//          // Wait until all counters finished their window
//          roEN <= 1'b1;
//          if (finished_all) begin
//            roEN   <= 1'b0;     // stop RO drive for safety
//            next_state  <= S_SHIFT;
//          end
//        end

//        S_SHIFT: begin
//          // Ask for srEN pulse in clk_out domain
//          srEN    <= 1'b1;
//          next_state <= S_STEP;
//        end

//        S_STEP: begin
//          // Advance LFSR one step (prepare next derived challenge)
//          srEN   <= 1'b0;
//          lfsrEN <= 1'b1;
//          next_state  <= S_CHECK;
//        end

//        S_CHECK: begin
//          // Count how many bits collected
//          next_bit_cnt <= bit_cnt + 16'd1;
//          cnt_rst    <= 1'b1;
//          if (bit_cnt == (OUTPUT_WIDTH-1)) begin
//            next_state <= S_FINISH;
//          end else begin           
//            next_state <= S_PREP;
//          end
//        end

//        S_FINISH: begin
//          // Full response has been shifted (shiftReg asserts shift_done in clk_out domain).
//          // We can assert puf_done in clk domain immediately after the last srEN pulse,
//          // or wait and sync shift_done back if you prefer. Here we assert puf_done.
//          if (shift_done) begin
//              puf_done <= 1'b1;
//              if (!start) 
//                next_state <= S_IDLE; // wait for start to go low before re-arming
//              else 
//                next_state <= S_WAIT_REL;              
//          end 
//          cnt_rst    <= 1'b1;
//        end

//        S_WAIT_REL: begin
//          cnt_rst    <= 1'b1;
//          // Wait for start deassertion before allowing another run
//          if (!start) next_state <= S_IDLE;
//        end

//        default: next_state <= S_IDLE;
//      endcase  
//  end
//assign busy = (state != S_IDLE);

//endmodule

`default_nettype wire


/////// Oldest version:

//// Company: 
//// Engineer: 
//// 
//// Create Date: 04/29/2025 05:10:27 PM
//// Design Name: 
//// Module Name: control_PUF
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//module control_PUF(
//    input clk,
//    input start,
//    input [7:0] refcount,
//    output reg  lfsrDV, countEN, refEN, lfsrEN, srEN, roEN, countReset, done
//    );
    
//    reg [2:0] state;
//    reg [7:0] bitscount;
    
//    parameter IDLE=3'b000, DVALID=3'b001, INNER=3'b010, PRE=3'b011, OUTER=3'b100, TEMP=3'b101;
    
//    always@(posedge clk) begin  
//        case(state)
//            IDLE: begin
//                done <= 1'b0;
//                bitscount <= 8'b0;
//                if (!start)
//                    state <= IDLE;
//                else
//                    state <= DVALID;
//            end
//            DVALID: state <= INNER;
//            INNER: begin
//                if (refcount == 8'hFF)
//                    state <= PRE;
//                else 
//                    state <= INNER;
//            end
//            PRE: begin
//                state <= OUTER;
//            end
//            OUTER: begin
//                bitscount <= bitscount + 1;
//                if (bitscount == 8'h7F) begin
//                    state <= TEMP;
//                    done <= 1'b1;
//                end else begin 
//                    state <= INNER;
//                    done <= 1'b0;
//                end            
//            end
//            TEMP: begin
//                done <= 1'b0;
//                if (start)
//                    state <= TEMP;
//                else
//                    state <= IDLE;
//            end
//            default: begin
//                state <= IDLE;
//                bitscount <= 8'b0;
//                done <= 1'b0;
//            end
//        endcase
//    end

//    always@(*) begin 
//        case(state)
//            IDLE: begin
//                lfsrDV <= 1'b0;
//                countEN <= 1'b0;
//                refEN <= 1'b0;
//                lfsrEN <= 1'b0;
//                srEN <= 1'b0;
//                roEN <= 1'b0;
//                countReset <= 1'b1;
//            end
//            DVALID: begin
//                lfsrDV <= 1'b1;
//                countEN <= 1'b0;
//                refEN <= 1'b0;
//                lfsrEN <= 1'b1;
//                srEN <= 1'b0;
//                roEN <= 1'b0;
//                countReset <= 1'b1;
//            end
//            INNER: begin
//                lfsrDV <= 1'b0;
//                countEN <= 1'b1;
//                refEN <= 1'b1;
//                lfsrEN <= 1'b0;
//                srEN <= 1'b0;
//                roEN <= 1'b1;
//                countReset <= 1'b0;
//            end 
//            PRE: begin
//                lfsrDV <= 1'b0;
//                countEN <= 1'b1;
//                refEN <= 1'b0;
//                lfsrEN <= 1'b1;
//                srEN <= 1'b1;
//                roEN <= 1'b0;
//                countReset <= 1'b0;
//            end
//            OUTER: begin
//                lfsrDV <= 1'b0;
//                countEN <= 1'b1;
//                refEN <= 1'b0;
//                lfsrEN <= 1'b0;
//                srEN <= 1'b0;
//                roEN <= 1'b0;
//                countReset <= 1'b1;
//            end
//            default: begin
//                lfsrDV <= 1'b0;
//                countEN <= 1'b0;
//                refEN <= 1'b0;
//                lfsrEN <= 1'b0;
//                srEN <= 1'b0;
//                roEN <= 1'b0;
//                countReset <= 1'b1;
//            end
//        endcase
//    end
//endmodule
