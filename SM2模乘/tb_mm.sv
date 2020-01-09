

//~ `New testbench

module tb_mm;

// square Parameters
parameter PERIOD        = 10;
parameter NUM_ELEMENTS  = 17;
parameter BIT_LEN       = 17;
parameter WORD_LEN      = 16;
parameter NUM_ELEMENTS_OUT = 256+256+18+18;

parameter P =  256'hFFFFFFFE_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_00000000_FFFFFFFF_FFFFFFFF;

// square Inputs
logic [BIT_LEN-1:0] A[NUM_ELEMENTS];
logic [BIT_LEN-1:0] B[NUM_ELEMENTS];

logic [17:0][WORD_LEN-1:0] A_p=0;
logic [17:0][WORD_LEN-1:0] B_p=0;
logic [17:0][WORD_LEN-1:0] A_p0=0;
logic [17:0][WORD_LEN-1:0] B_p0=0;
logic [17:0][WORD_LEN-1:0] A_p1=0;
logic [17:0][WORD_LEN-1:0] B_p1=0;

// square Outputs
logic [BIT_LEN-1:0] S[NUM_ELEMENTS];
logic [255:0] actual_result       ;
logic [255:0] expect_result       ;
logic [NUM_ELEMENTS_OUT:0] expect_result_temp       ;
logic [NUM_ELEMENTS_OUT:0] actual_result_temp       ;

logic [NUM_ELEMENTS-1:0][WORD_LEN-1:0] S_t;
logic [NUM_ELEMENTS-1:0][WORD_LEN-1:0] C_t;

logic start = 0;


logic clk = 0;

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end




assign actual_result_temp = S_t + {C_t<<WORD_LEN};
assign expect_result_temp = A_p * B_p;

assign actual_result = actual_result_temp % P;
assign expect_result = expect_result_temp % P;


always@(posedge clk) begin
    for(int i=0; i< NUM_ELEMENTS; i++)begin
        A[i] <= $random;
        B[i] <= $random;
        //A[i] <= 17'hffff;
        //B[i] <= 17'hffff;
    end
    if(start)begin
        if(actual_result == expect_result)
            $display("Correct!\nactual_result = %h\nexpect_result = %h\n", actual_result, expect_result);
        else begin
            $display("Error!\nactual_result = %h\nexpect_result = %h\n", actual_result, expect_result);
            $stop;
        end
    end
        
end





initial
begin
    #(PERIOD*5)
    start = 1;
    //$display("actual_result = %h\nexpect_result = %h\n", actual_result, expect_result);
    #(PERIOD*300)
    $display("Finish test. No errors.\n");
    $stop;
end

genvar j;
generate
    for (j = 0; j < NUM_ELEMENTS*2; j++)begin
		assign S_t[j] = S[j][WORD_LEN-1:0];
		assign C_t[j] = {16'b0, S[j][WORD_LEN]};
    end
endgenerate


always_comb begin
    for(int i=0; i< 17; i++)begin
        A_p0[i] = A[i][WORD_LEN-1:0];
        A_p1[i] = A[i][BIT_LEN-1:WORD_LEN];
        B_p0[i] = B[i][WORD_LEN-1:0];
        B_p1[i] = B[i][BIT_LEN-1:WORD_LEN];
    end
end

always_comb begin
    A_p = A_p0 + (A_p1<<WORD_LEN);
    B_p = B_p0 + (B_p1<<WORD_LEN);
end


modular_multiplication
#(
    .NUM_ELEMENTS ( NUM_ELEMENTS ),
    .BIT_LEN      ( BIT_LEN      ),
    .WORD_LEN     ( WORD_LEN     ))
 u_modular_multiplication (
    .A(A),
    .B(B),
    .MM(S)
);

endmodule
