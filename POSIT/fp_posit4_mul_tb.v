`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Testbench for neww_4bit.v
//   • Drives a single 4-bit posit word 0101 (MSB first) with precision = 4.
//   • Drives act = 16'h1234 (IEEE-FP16).
//   • Checks the outputs when done = 1.  Expected:
//        sign_out      = 0
//        exp_out       = 5'h03
//        mantissa_out  = 14'h0C68
//        zero_out      = 0
//        NaR_out       = 0
// -----------------------------------------------------------------------------

module fp_posit4_mul_tb;
    // DUT generics
    parameter ACT_WIDTH = 16;
    parameter EXP_WIDTH = 5;
    parameter MAN_WIDTH = 10;

    // ------------------------------------------------------------------------
    //  Signals
    // ------------------------------------------------------------------------
    reg                    clk = 0;
    reg                    rst = 0;
    reg  [ACT_WIDTH-1:0]   act;
    reg  [3:0]             w;
    reg                    valid;
    reg                    set;
    reg  [3:0]             precision;


// Expected values for verification (Modify these based on expected behavior)
    reg [4:0] expected_exp [0:4];
    reg [13:0] expected_man [0:4];
    reg expected_zero [0:4];
    reg expected_nar [0:4];
    
    wire                   sign_out;
    wire [4:0]             exp_out;
    wire [13:0]            mantissa_out;
    wire                   done;
    wire                   zero_out;
    wire                   NaR_out;

    // ------------------------------------------------------------------------
    //  Device under test
    // ------------------------------------------------------------------------
    fp_posit4_mul #(
        .ACT_WIDTH(ACT_WIDTH),
        .EXP_WIDTH(EXP_WIDTH),
        .MAN_WIDTH(MAN_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .act(act),
        .w(w),
        .valid(valid),
        .set(set),
        .precision(precision),
        .sign_out(sign_out),
        .exp_out(exp_out),
        .mantissa_out(mantissa_out),
        .done(done),
        .zero_out(zero_out),
        .NaR_out(NaR_out)
    );

    // ------------------------------------------------------------------------
    //  Clock generator  (100?MHz)
    // ------------------------------------------------------------------------
    always #5 clk = ~clk;

    // ------------------------------------------------------------------------
    //  Test stimulus
    // ------------------------------------------------------------------------
    initial begin
    
    expected_exp[0] = 5'b00011; expected_man[0] = 14'b01001010011100; expected_zero[0] = 0; expected_nar[0] = 0;
    expected_exp[1] = 5'b11011; expected_man[1] = 14'b01001010011100; expected_zero[1] = 0; expected_nar[1] = 0;
    expected_exp[2] = 5'b11011; expected_man[2] = 14'b01001010011100; expected_zero[2] = 0; expected_nar[2] = 0;
    expected_exp[3] = 5'b11100; expected_man[3] = 14'b00110001101000; expected_zero[3] = 1; expected_nar[3] = 0;// man and exp doesn't matter as long as zero = 1
    expected_exp[4] = 5'b11100; expected_man[4] = 14'b01001010011100; expected_zero[4] = 0; expected_nar[4] = 1;// man and exp doesn't matter as long as NaR = act
    
        $dumpfile("fp_posit4_mul.vcd");
        $dumpvars(0, fp_posit4_mul_tb);

//        // Initialise
        act       = 16'h1234;
        w         = 4'b0101;  // MSB-first word

        valid     = 0;
        set       = 0;
        precision = 4;

        // Apply reset
        #12 rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        rst = 1;

        // Latch precision while idle
        set = 1; @(posedge clk); set = 0;

        // Drive the posit word over four cycles
        valid = 1;
        repeat (4) @(posedge clk);
        valid = 0;

        act       = 16'hf234;
        valid = 1;
        repeat (4) @(posedge clk);
        valid = 0;
        
        act       = 16'hf234;
        valid = 1;
        repeat (4) @(posedge clk);
        valid = 0;
        
        act       = 16'hf234;
        w=4'b1010;
        valid = 1;
        repeat (4) @(posedge clk);
        valid = 0;
        
        act       = 16'hf234;
        w=4'b0000;
        valid = 1;
        repeat (4) @(posedge clk);
        valid = 0;
        
        act       = 16'hf234;
        w=4'b1000;
        valid = 1;
        repeat (4) @(posedge clk);
        valid = 0;
        // Wait a little and finish
        #40 $finish;
    end

    // ------------------------------------------------------------------------
    //  Simple checker
    // ------------------------------------------------------------------------
    
endmodule

// -----------------------------------------------------------------------------
//                                  End
// -----------------------------------------------------------------------------
