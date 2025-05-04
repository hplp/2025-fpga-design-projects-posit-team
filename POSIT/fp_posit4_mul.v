
module fp_posit4_mul #(
    parameter ACT_WIDTH = 16,
    parameter EXP_WIDTH = 5,
    parameter MAN_WIDTH = 10
)(
    input                   clk,
    input                   rst,
    input  [ACT_WIDTH-1:0]  act,
    input  [3:0]            w,          // posit(4,0), es=0
    input                   valid,
    input                   set,
    input  [3:0]            precision,
    output reg              sign_out,
    output reg [4:0]        exp_out,
    output      [13:0]      mantissa_out,
    output reg              done,
    output                  zero_out,
    output                  NaR_out
);

// -----------------------------------------------------------------------------
//  Internal signals (unchanged)
// -----------------------------------------------------------------------------
reg                       zero, NaR;
wire                      act_sign;
wire [4:0]                act_exponent;
wire [9:0]                act_mantissa;
wire [10:0]               fixed_mantissa;
reg  [13:0]               mantissa_reg, mantissa_temp, shifted_fp;
reg  [3:0]                _precision;
reg  [3:0]                count;
reg                       regime_done, _regime, regime_sign;
reg  [1:0]                state;

assign {act_sign, act_exponent, act_mantissa} = act;
assign fixed_mantissa = {1'b1, act_mantissa};

// Pick one bit per cycle ------------------------------------------------------
wire w_bit = w[_precision - 1 - count];   // MSB-first

// -----------------------------------------------------------------------------
//  Precision latch
// -----------------------------------------------------------------------------
always @(posedge clk or negedge rst)
    if (!rst) _precision <= 0;
    else if (set) _precision <= precision;

// -----------------------------------------------------------------------------
//  Counter and done pulse
// -----------------------------------------------------------------------------
localparam SIGN=2'b00, REGIME=2'b01, MANTISSA=2'b10;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        count <= 0; regime_done <= 0; done <= 0;
    end else if (valid) begin
        if (count < _precision-1) begin
            count <= count + 1;
            done  <= 0;
        end else begin
            count <= 0;
            done  <= 1;
        end
    end else begin
        count <= 0;
        done  <= 0;
    end
end

// -----------------------------------------------------------------------------
//  FSM state derivation (pure combinational)
// -----------------------------------------------------------------------------
always @(*) begin
    case (count)
        4'd0:  state = SIGN;
        4'd1:  state = REGIME;
        default: state = regime_done ? MANTISSA : REGIME;
    endcase
end

// -----------------------------------------------------------------------------
//  Mantissa pipeline stage
// -----------------------------------------------------------------------------
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        mantissa_reg <= 0; mantissa_temp <= 0;
    end else if (state == REGIME) begin
        mantissa_reg <= fixed_mantissa;
    end else if (state == MANTISSA && count < _precision-1) begin
        mantissa_reg <= mantissa_out;
    end else begin
        mantissa_reg <= 0;
        mantissa_temp <= mantissa_reg;
    end
end

// -----------------------------------------------------------------------------
//  Core output / control logic 
// -----------------------------------------------------------------------------
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        sign_out <= 0; exp_out <= 0; shifted_fp <= 0;
        zero <= 0; NaR <= 0; regime_done <= 0; _regime <= 0; 
        regime_sign <= 1;
    end else if (valid) begin
        case (state)
        SIGN: begin
            sign_out <= act[ACT_WIDTH-1] ^ w_bit;
            zero     <= ~w_bit;
            NaR      <=  w_bit;
            exp_out  <= act_exponent;
            regime_done <= 0;
        end
        REGIME: begin
            _regime   <= w_bit;
            zero      <= zero & ~w_bit;
            NaR       <= NaR  & ~w_bit;
            if (count == 1) regime_sign <= w_bit;
            else if (_regime ^ w_bit) regime_done <= 1;
            if (count == _precision-1)
                exp_out <= regime_sign ? (exp_out + count) : exp_out;
        end
        MANTISSA: begin
            zero <= 0; NaR <= 0;
            if (regime_done) begin
                regime_done <= 0;
                exp_out <= w_bit ? (regime_sign ? exp_out + count - 4 : exp_out + 1 - count)
                                   : (regime_sign ? exp_out + count - 3 : exp_out + 2 - count);
                shifted_fp <= w_bit ? fixed_mantissa << 1 : 0;
            end else begin
                exp_out    <= w_bit ? exp_out - 1 : exp_out;
                shifted_fp <= w_bit ? fixed_mantissa << 1 : 0;
            end
        end
        endcase
    end
end

// -----------------------------------------------------------------------------
//  Fixed-point adder
// -----------------------------------------------------------------------------
fixed_point_adder fixed_add (
    .A(done ? mantissa_temp : mantissa_reg),
    .B(shifted_fp),
    .C(mantissa_out)
);

assign zero_out = done & zero;
assign NaR_out  = done & NaR;

endmodule

// -----------------------------------------------------------------------------
module fixed_point_adder (
    input  [13:0] A,
    input  [13:0] B,
    output [13:0] C
);
    assign C = A + B;
endmodule



