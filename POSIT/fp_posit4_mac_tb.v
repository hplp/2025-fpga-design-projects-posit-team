`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Testbench for fp_posit4_mac
//   • Drives a single FP16 × Posit-4 MAC operation.
//   • Accumulator input fixed at 0.
//   • Expected result after 'done':
//        exp_out         = 5'h03
//        fixed_point_out = 32'h0000_0C68
//        NaR_out         = 0
// -----------------------------------------------------------------------------
module fp_posit4_mac_tb;

    // DUT generics
    localparam ACT_WIDTH = 16;
    localparam ACC_WIDTH = 32;

    // -------------------------------------------------------------------------
    //  Signals
    // -------------------------------------------------------------------------
    reg                     clk = 0;
    reg                     rst = 0;

    //  Inputs
    reg                     valid;
    reg                     set;
    reg  [3:0]              precision;
    reg  [ACT_WIDTH-1:0]    act;
    reg  [3:0]              w;
    reg  [4:0]              exp_min;
    reg  [ACC_WIDTH-1:0]    fixed_point_acc;

    //  Outputs
    wire [4:0]              exp_out;
    wire [ACC_WIDTH-1:0]    fixed_point_out;
    wire                    done;
    wire                    NaR_out;

    // -------------------------------------------------------------------------
    //  Device Under Test
    // -------------------------------------------------------------------------
    mineMAC #(
        .ACT_WIDTH (ACT_WIDTH),
        .ACC_WIDTH (ACC_WIDTH)
    ) dut (
        .clk              (clk),
        .rst              (rst),
        .valid            (valid),
        .precision        (precision),
        .set              (set),
        .act              (act),
        .w                (w),
        .exp_min          (exp_min),
        .fixed_point_acc  (fixed_point_acc),
        .exp_out          (exp_out),
        .fixed_point_out  (fixed_point_out),
        .done             (done),
        .NaR_out          (NaR_out)
    );

    // -------------------------------------------------------------------------
    //  Clock generator  (100 MHz ? 10 ns period)
    // -------------------------------------------------------------------------
    always #5 clk = ~clk;

    // -------------------------------------------------------------------------
    //  Test stimulus
    // -------------------------------------------------------------------------
    initial begin
        $dumpfile("fp_posit4_mac.vcd");
        $dumpvars(0, fp_posit4_mac_tb);

        // Initialise static inputs
        precision        = 4;                // 4-bit posit
        w                = 4'b0101;          // +1.5
        act              = 16'h1234;         // arbitrary FP16
        exp_min          = 5'h03;            // align to multiplier result
        fixed_point_acc = 32'b00000000000000000000000000011110; // Start accumulator at 0

        valid            = 0;
        set              = 0;

        // ---------------------------------------------------------------------
        //  Reset sequence
        // ---------------------------------------------------------------------
        #12  rst = 1'b1;
        @(posedge clk);
        rst = 1'b0;
        @(posedge clk);
        rst = 1'b1;

        // ---------------------------------------------------------------------
        //  Latch precision while idle
        // ---------------------------------------------------------------------
        set   = 1'b1;        // pulse 'set' for one clock
        @(posedge clk);
        set   = 1'b0;

        // ---------------------------------------------------------------------
        //  Drive one FP16 × Posit-4 word  (four cycles @ valid = 1)
        // ---------------------------------------------------------------------
        valid = 1'b1;
        repeat (4) @(posedge clk);
        valid = 1'b0;

        
//        w                = 4'b0101;          // +1.5
//        act              = 16'h1234;         // arbitrary FP16
//        exp_min          = 5'h03;            // align to multiplier result
//        fixed_point_acc = 32'b00000000000000000000000000011110; // Start accumulator at 0

//        valid = 1'b1;
//        repeat (4) @(posedge clk);
//        valid = 1'b0;
        
        #40 $finish;
    end

endmodule
