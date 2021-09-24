

`timescale 1ns / 1ns


module elastic_buffer
(
    input         	reset_b,
    input         	clk,
    input 			data_ready,
	input			sysref,
    input  	[31:0] 	data_in,
    output	[31:0] 	data_out,
	output  [9:0]   usedw
);

    localparam DELAY_EBUF = 210;
	
	////////// WR ///////////////////////////////
    reg start_wr_fifo;
    reg data_ready_reg;
	always @ (posedge clk, negedge reset_b)
		if(~reset_b) begin
			data_ready_reg <= 1'b0;
			start_wr_fifo <= 1'b0;
		end else begin
			data_ready_reg <= data_ready;
			start_wr_fifo <= (~data_ready_reg) & data_ready;
		end

    reg wrreq;
	always @ (posedge clk, negedge reset_b)
		if(~reset_b) begin
			wrreq <= 1'b0;
		end else begin
		    if (start_wr_fifo)
			    wrreq <= 1'b1;
			else
			    wrreq <= wrreq;
		end

    reg [31:0] data0, data;
	always @ (posedge clk, negedge reset_b)
		if(~reset_b) begin
			data0 <= 32'd0;
			data <= 32'd0;
		end else begin
			data0 <= data_in;
			data <= data0;
		end

		
	/////////// RD ////////////////////////////////
    reg start_rd_fifo;
    reg sysref_reg;
	always @ (posedge clk, negedge reset_b)
		if(~reset_b) begin
			sysref_reg <= 1'b0;
			start_rd_fifo <= 1'b0;
		end else begin
			sysref_reg <= sysref;
			start_rd_fifo <= (~sysref_reg) & sysref;
		end

    reg rdreq;
	always @ (posedge clk, negedge reset_b)
		if(~reset_b) begin
			rdreq <= 1'b0;
		end else begin
		    if (start_rd_fifo)
			    rdreq <= 1'b1;
			else
			    rdreq <= rdreq;
		end

	wire rdreq_delay;	
	delay_rg  #(.W(1), .D(DELAY_EBUF)) delay_rg_inst0          
	   (.reset_b	(reset_b),
		.clk		(clk),
		.data_in	(rdreq),    
		.data_out	(rdreq_delay));	
		
/* 	wire [5:0] usedw0;	
	fifo_elastic fifo_elastic_inst(
	    .aclr   (~reset_b   ),
		.clock	(clk		),
		.data	(data		),
		.rdreq	(rdreq_delay),
		.wrreq	(wrreq		),
		.q		(data_out	),
		.usedw	(usedw0		)); */
		
		
	wire [5:0] usedw0;	
	fifo_elastic_xilinx fifo_elastic_inst(
	    .rst   (~reset_b   ),
		.clk	(clk		),
		.din	(data		),
		.rd_en	(rdreq_delay),
		.wr_en	(wrreq		),
		.dout	(data_out	),
		.data_count	(usedw0		));
		
		
	assign usedw = {4'd0, usedw0}; 


endmodule


