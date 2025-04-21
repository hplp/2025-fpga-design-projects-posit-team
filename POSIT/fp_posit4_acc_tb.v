module fp_posit4_acc_tb;

    // Testbench signals
    reg clk;
    reg rst;
    reg start;
    reg sign_in;
    reg zero;
    reg NaR;
    reg [4:0] exp_min;
    reg [31:0] fixed_point_acc;
    reg [4:0] exp_in;
    reg [13:0] fixed_point_in;
    wire [4:0] exp_out;
    wire [31:0] fixed_point_out;
    // Expected outputs for verification
    reg expected_sign_out;
    reg [4:0] expected_exp_out;
    reg [31:0] expected_fixed_point_out;

    // Instantiate the fp_int_acc module
    fp_posit4_acc uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .sign_in(sign_in),
        .exp_set(exp_min),
        .fixed_point_acc(fixed_point_acc),
        .exp_in(exp_in),
        .fixed_point_in(fixed_point_in),
        .zero(zero),
        .NaR(NaR),
        .exp_out(exp_out),
        .fixed_point_out(fixed_point_out)
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Test stimulus
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;
        zero = 0;
        NaR = 0;
        sign_in = 0;  // Add to the test if it's add or subtract
        exp_min = 5'b10000;  // Exponent Min = 16
        fixed_point_acc = 32'b00000000000000000000000000000001;  // Initialize accumulator to 0
        exp_in = 5'b01111;  // Exponent input = 16
        fixed_point_in = 14'b10000111110110;  // Fixed-point input as 14-bit value
        // Expected results for verification
        expected_sign_out = 0;
        expected_exp_out = 5'b10000;  // Expected exponent output
        expected_fixed_point_out = 32'b00000000000000000001000011111100; // Expected fixed-point output

        // Create VCD file for GTKWave
        $dumpfile("build/fp_posit4_acc.vcd");
        $dumpvars(0, fp_posit4_acc_tb);  // Dump all signals of the testbench

        // Apply reset
        #10 rst = 0;  // Apply reset
        #10 rst = 1;  // Release reset

        // Start the operation (start the accumulation)
        #15 start = 1;  // Start operation
        #10 start = 0;  // End start pulse

        // Wait for the operation to complete
        #40; // Wait a few cycles for computation to finish

        // Check the outputs
        $display("sign_out: %b", sign_in);
        $display("exp_out: %b", exp_out);
        $display("mantissa_out: %b", fixed_point_out);

        // **Verification**
        if (exp_out !== expected_exp_out) 
            $display("ERROR: exp_out is incorrect. Expected %b, got %b", expected_exp_out, exp_out);
        else 
            $display("exp_out is correct.");

        if (fixed_point_out !== expected_fixed_point_out) 
            $display("ERROR: fixed_point_out is incorrect. Expected %b, got %b", expected_fixed_point_out, fixed_point_out);
        else 
            $display("fixed_point_out is correct.");

        if (sign_in !== expected_sign_out) 
            $display("ERROR: sign_out is incorrect. Expected %b, got %b", expected_sign_out, sign_in);
        else 
            $display("sign_out is correct.");

        // zero = 1;
        NaR = 1;
        #15 start = 1;  // Start operation
        #10 start = 0;  // End start pulse
        // Wait for the operation to complete
        #40; // Wait a few cycles for computation to finish

        // Finish the simulation
        $finish;
    end

endmodule