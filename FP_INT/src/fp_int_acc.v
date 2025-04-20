module fp_int_acc (
    input          clk,
    input          rst,
    input          start,
    input          sign_in,
    input  [4:0]   exp_set,
    input  [31:0]  fixed_point_acc,
    input  [4:0]   exp_in,
    input  [13:0]  fixed_point_in,
    output [4:0]   exp_out,
    output [31:0]  fixed_point_out,
    output reg     done
);

wire [4:0] diff;
reg _sign_in;
assign diff = exp_in - exp_set;

reg [31:0] fixed_point_reg;
reg [4:0] exp_reg;
reg [31:0] fixed_point_in_shifted;
reg shifted;

always @(posedge clk or negedge rst)
    if (!rst) begin
        fixed_point_reg <= 0;
        done <= 0;
        _sign_in <= 0;
    end
    else if (shifted&&!done) begin
        _sign_in <= sign_in;
        fixed_point_reg <= _sign_in? fixed_point_acc - fixed_point_in_shifted: fixed_point_acc + fixed_point_in_shifted;
        shifted <= 0;
        done <= 1;
    end
    else _sign_in <= sign_in;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        fixed_point_in_shifted <= 0;
        exp_reg <= 0;
        shifted <= 0;
    end
    else if (start && !shifted) begin
        done <= 0;
        if (~|diff) begin // If diff == 0
            fixed_point_in_shifted <= fixed_point_in;
        end
        else if (!diff[4]) begin // If exp_set < exp_in, diff[4] would be 0
            fixed_point_in_shifted <= fixed_point_in<<diff; //shift by the two's complement of diff since diff would be negative values here
        end
        else begin // If exp_set > exp_in, diff[4] would be 1
            fixed_point_in_shifted <= fixed_point_in>>-diff;
        end
        shifted <= 1;
        exp_reg <= exp_set;
    end
    else begin
        fixed_point_in_shifted <= fixed_point_in;
    end
end



assign fixed_point_out = fixed_point_reg;
assign exp_out = exp_reg;

endmodule