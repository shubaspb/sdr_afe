
module complex_mult
 #(parameter W = 20)                      // width
 (
    input                       reset_b,  // clock
    input                       clk,      // reset
    input   signed      [W-1:0] a_in_i,   // input signal 1, real part
    input   signed      [W-1:0] a_in_q,   // input signal 1, imag part
    input   signed      [W-1:0] b_in_i,   // input signal 2, real part
    input   signed      [W-1:0] b_in_q,   // input signal 2, imag part
    output reg signed   [W-1:0] out_i,    // output signal, real part
    output reg signed   [W-1:0] out_q     // output signal, imag part
 );

    reg signed  [2*W-1:0]   w_i_i;
    reg signed  [2*W-1:0]   w_q_q;
    reg signed  [2*W-1:0]   w_i_q;
    reg signed  [2*W-1:0]   w_q_i;

    always@(posedge clk, negedge reset_b)
    if(~reset_b) begin
        w_i_i <= {(2*W){1'b0}};
        w_q_q <= {(2*W){1'b0}};
        w_i_q <= {(2*W){1'b0}};
        w_q_i <= {(2*W){1'b0}};
    end else begin
        w_i_i <= a_in_i * b_in_i;
        w_q_q <= a_in_q * b_in_q;
        w_i_q <= a_in_i * b_in_q;
        w_q_i <= a_in_q * b_in_i;
    end
    
    wire    signed  [2*W:0]   w_new_i = w_i_i - w_q_q;
    wire    signed  [2*W:0]   w_new_q = w_q_i + w_i_q;
    
    always@(posedge clk, negedge reset_b)
    if(~reset_b) begin
        out_i <= {(W){1'b0}};
        out_q <= {(W){1'b0}};
    end else begin
        out_i <= w_new_i[2*W-2:W-1];
        out_q <= w_new_q[2*W-2:W-1];
    end

endmodule
