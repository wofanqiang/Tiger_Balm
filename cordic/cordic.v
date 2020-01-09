`define K 32'h26dd3b6a  

`define BETA_0  32'h3243f6a9       
`define BETA_1  32'h1dac6705  
`define BETA_2  32'h0fadbafd  
`define BETA_3  32'h07f56ea7  
`define BETA_4  32'h03feab77  
`define BETA_5  32'h01ffd55c  
`define BETA_6  32'h00fffaab  
`define BETA_7  32'h007fff55  
`define BETA_8  32'h003fffeb  
`define BETA_9  32'h001ffffd  
`define BETA_10 32'h00100000  
`define BETA_11 32'h00080000  
`define BETA_12 32'h00040000  
`define BETA_13 32'h00020000  
`define BETA_14 32'h00010000  
`define BETA_15 32'h00008000  
`define BETA_16 32'h00004000  
`define BETA_17 32'h00002000  
`define BETA_18 32'h00001000  
`define BETA_19 32'h00000800  
`define BETA_20 32'h00000400  
`define BETA_21 32'h00000200  
`define BETA_22 32'h00000100  
`define BETA_23 32'h00000080  
`define BETA_24 32'h00000040  
`define BETA_25 32'h00000020  
`define BETA_26 32'h00000010  
`define BETA_27 32'h00000008  
`define BETA_28 32'h00000004  
`define BETA_29 32'h00000002  
`define BETA_30 32'h00000001  
`define BETA_31 32'h00000000
  
module cordic(
    clock,    
    reset,    
    start,        
    angle_in, 
    cos_out,  
    sin_out   
);

input clock;
input reset;
input start;
input [31:0] angle_in;
output [31:0] cos_out;
output [31:0] sin_out;

wire [31:0] cos_out;
wire [31:0] sin_out;

reg [31:0] cos;
reg [31:0] sin;
reg [31:0] angle;
reg [4:0] count;
reg state;

reg [31:0] cos_next;
reg [31:0] sin_next;
reg [31:0] angle_next;
reg [4:0] count_next;
reg state_next;

wire direction_negative;
wire [31:0] cos_signbits;
wire [31:0] sin_signbits;
wire [31:0] cos_shr;
wire [31:0] sin_shr;

assign direction_negative = angle[31];
assign cos_signbits = {32{cos[31]}};
assign sin_signbits = {32{sin[31]}};
assign cos_shr = {cos_signbits, cos} >> count;
assign sin_shr = {sin_signbits, sin} >> count;

wire [31:0] beta_lut [0:31];
assign beta_lut[0] = `BETA_0;
assign beta_lut[1] = `BETA_1;
assign beta_lut[2] = `BETA_2;
assign beta_lut[3] = `BETA_3;
assign beta_lut[4] = `BETA_4;
assign beta_lut[5] = `BETA_5;
assign beta_lut[6] = `BETA_6;
assign beta_lut[7] = `BETA_7;
assign beta_lut[8] = `BETA_8;
assign beta_lut[9] = `BETA_9;
assign beta_lut[10] = `BETA_10;
assign beta_lut[11] = `BETA_11;
assign beta_lut[12] = `BETA_12;
assign beta_lut[13] = `BETA_13;
assign beta_lut[14] = `BETA_14;
assign beta_lut[15] = `BETA_15;
assign beta_lut[16] = `BETA_16;
assign beta_lut[17] = `BETA_17;
assign beta_lut[18] = `BETA_18;
assign beta_lut[19] = `BETA_19;
assign beta_lut[20] = `BETA_20;
assign beta_lut[21] = `BETA_21;
assign beta_lut[22] = `BETA_22;
assign beta_lut[23] = `BETA_23;
assign beta_lut[24] = `BETA_24;
assign beta_lut[25] = `BETA_25;
assign beta_lut[26] = `BETA_26;
assign beta_lut[27] = `BETA_27;
assign beta_lut[28] = `BETA_28;
assign beta_lut[29] = `BETA_29;
assign beta_lut[30] = `BETA_30;
assign beta_lut[31] = `BETA_31;

wire [31:0] beta;
assign beta = beta_lut[count];


always @(posedge clock or posedge reset) begin
    if (reset) begin
        cos <= 0;
        sin <= 0;
        angle <= 0;
        count <= 0;
        state <= 0;
    end else begin
        cos <= cos_next;
        sin <= sin_next;
        angle <= angle_next;
        count <= count_next;
        state <= state_next;
    end
end

always @* begin
    cos_next = cos;
    sin_next = sin;
    angle_next = angle;
    count_next = count;
    state_next = state;
    
    if (state) begin
        cos_next = cos + (direction_negative ? sin_shr : -sin_shr);
        sin_next = sin + (direction_negative ? -cos_shr : cos_shr);
        angle_next = angle + (direction_negative ? beta : -beta);
        count_next = count + 1;
        
        if (count == 31) begin
                state_next = 0;
        end
    end
    
    else begin
        
        if (start) begin
            cos_next = `K;         
            sin_next = 0;          
            angle_next = angle_in; 
            count_next = 0;        
            state_next = 1;        
        end
    end
end

assign cos_out = cos;
assign sin_out = sin;

endmodule
