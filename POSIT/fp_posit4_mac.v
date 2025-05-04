`timescale 1ns / 1ps

module fp_posit4_mac #(
    parameter ACT_WIDTH = 16,
    parameter ACC_WIDTH = 32          // keep 32 unless you also edit fp_posit4_acc
)(
    input                       clk,
    input                       rst,
    input                       valid,
    input  [3:0]                precision,
    input                       set,
    input  [ACT_WIDTH-1:0]      act,
    input  [3:0]                w,            // <-- width fixed
    input  [4:0]                exp_min,
    input  [ACC_WIDTH-1:0]      fixed_point_acc,
    output [4:0]                exp_out,
    output [ACC_WIDTH-1:0]      fixed_point_out,
    output                      done,
    output                      NaR_out
);



        // -----------------------------------------------------------------------------
    // Internal inter-module wiring
    // -----------------------------------------------------------------------------
    wire         start_acc;        // 'done' pulse from multiplier ? 'start' of accumulator
    wire         sign_out;         // multiplier product sign  (1 = negative)
    wire [4:0]   exp_out_mul;      // unbiased exponent from multiplier
    wire [13:0]  mantissa_out;     // 1.13 fixed-point product mantissa
    wire         zero;             // multiplier flags +0
    wire         NaR;              // multiplier flags NaR

    /*------------------------------------------------------------------
     * Multiplier
     *----------------------------------------------------------------*/
    mine #(
        .ACT_WIDTH (ACT_WIDTH)
    ) mul_unit (
        .clk           (clk),
        .rst           (rst),
        .act           (act),
        .w             (w),
        .valid         (valid),
        .set           (set),
        .precision     (precision),
        .sign_out      (sign_out),
        .exp_out       (exp_out_mul),
        .mantissa_out  (mantissa_out),
        .done          (start_acc),         // pulse -> accumulator.start
        .zero_out      (zero),
        .NaR_out       (NaR)
    );

    /*------------------------------------------------------------------
     * Accumulator
     *----------------------------------------------------------------*/
    fp_posit4_acc acc_unit (
        .clk              (clk),
        .rst              (rst),
        .start            (start_acc),
        .sign_in          (sign_out),
        .exp_set          (exp_min),
        .fixed_point_acc  (fixed_point_acc),
        .exp_in           (exp_out_mul),
        .fixed_point_in   (mantissa_out),
        .zero             (zero),
        .NaR              (NaR),
        .exp_out          (exp_out),
        .fixed_point_out  (fixed_point_out),
        .done             (done),
        .NaR_out          (NaR_out)
    );

endmodule
