
module jesd204b_rx_sync
(
    input  reset_b,
    input  clk,

    input [3:0] sync_b_i,
    output reg [3:0] sync_b_o,

    input  sysref_i,
    output reg sysref_o
);


reg sysref_ff0, sysref_ff1;
reg [3:0] sync_b_ff0, sync_b_ff1;

always @(negedge clk, negedge reset_b)
    if (!reset_b) begin
        {sysref_ff1, sysref_ff0} <= 2'h0;
        {sync_b_ff1, sync_b_ff0} <= 8'd0;
    end else begin
        {sysref_ff1, sysref_ff0} <= {sysref_ff0, sysref_i};
        {sync_b_ff1, sync_b_ff0} <= {sync_b_ff0, sync_b_i};
    end
    
always @(posedge clk, negedge reset_b)
    if (!reset_b) begin
        sync_b_o <= 4'b0;
        sysref_o <= 1'b0;
    end else begin
        sync_b_o <= sync_b_ff1;
        sysref_o <= sysref_ff1;
    end

endmodule
