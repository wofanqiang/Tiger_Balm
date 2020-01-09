/*-------------------------------------------------------------------------
Input:      a , b
Output:     c = a * b

NUM_ELEMENTS 是a，b，c 分段的数量。
WORD_LEN 是a，b，c 分段的有效长度。
BIT_LEN 是保留分段进位后数据的长度。

ozturk乘法器打断了加法进位链，适合需要进行连续乘法运算的应用。

示意：
                                        a3      a2      a1      a0
                                      * b3      b2      b1      b0
                            ---------------------------------------
                                      a3b0    a2b0    a1b0    a0b0
                              a3b1    a2b1    a1b1    a0b1
                      a3b2    a2b2    a1b2    a0b2
              a3b3    a2b3    a1b3    a0b3
        -----------------------------------------------------------
               t6      t5      t4      t3      t2      t1      t0   
        -----------------------------------------------------------
   c8    c7    c6      c5      c4      c3      c2      c1      c0   

-------------------------------------------------------------------------*/

module multiplier
#(
    parameter NUM_ELEMENTS          = 17,
    parameter BIT_LEN               = 17,
    parameter WORD_LEN              = 16
)
(
    input logic [BIT_LEN-1:0] A[NUM_ELEMENTS],
    input logic [BIT_LEN-1:0] B[NUM_ELEMENTS],

    output logic [BIT_LEN-1:0] M[NUM_ELEMENTS*2+1]
);

    localparam EXTRA_BIT = $clog2(NUM_ELEMENTS);

    logic [NUM_ELEMENTS-1:0][BIT_LEN*2-1:0]  pp[NUM_ELEMENTS];

    genvar i,j;
	generate
	    for(i = 0; i < NUM_ELEMENTS; i = i + 1)begin:dsp_array_row
	        for(j = 0; j < NUM_ELEMENTS; j = j + 1)begin:dsp_array_col
	                dsp_multiplier #(.A_BIT_LEN(BIT_LEN), 
                                     .B_BIT_LEN(BIT_LEN)) 
                    u_dsp_multiplier(
                                .A(A[i][BIT_LEN-1:0]),
                                .B(B[j][BIT_LEN-1:0]),
                                .P(pp[i][j])
                                );
	        end
	    end
	endgenerate


    // format pp
    logic [NUM_ELEMENTS*2-2:0][BIT_LEN*2-1:0]  grid_pp[NUM_ELEMENTS];

    always_comb begin
        for(int i = 0; i < NUM_ELEMENTS; i++) begin
            grid_pp[i] = 0;
        end

        for(int j = 0; j < NUM_ELEMENTS; j++)begin
            grid_pp[j] = pp[j] << (j*(BIT_LEN*2));
        end
    end


    logic [EXTRA_BIT+WORD_LEN-1:0]  grid_pp0[NUM_ELEMENTS*2-1][NUM_ELEMENTS];
    logic [EXTRA_BIT+WORD_LEN-1:0]  grid_pp1[NUM_ELEMENTS*2-1][NUM_ELEMENTS];
    logic [EXTRA_BIT+WORD_LEN-1:0]  grid_pp2[NUM_ELEMENTS*2-1][NUM_ELEMENTS];

    always_comb begin
        for(int i = 0; i < NUM_ELEMENTS; i++) begin
            for(int j = 0; j < NUM_ELEMENTS*2-1; j++) begin
                grid_pp0[i][j] = 0;
                grid_pp1[i][j] = 0;
                grid_pp2[i][j] = 0;
            end
        end

        for(int i = 0; i < NUM_ELEMENTS*2-1; i++) begin
            for(int j = 0; j < NUM_ELEMENTS; j++) begin
                grid_pp0[i][j] = grid_pp[j][i][WORD_LEN-1:0];
                grid_pp1[i][j] = grid_pp[j][i][WORD_LEN*2-1:WORD_LEN];
                grid_pp2[i][j] = grid_pp[j][i][BIT_LEN*2-1:WORD_LEN*2];
            end
        end
    end

    logic [WORD_LEN+EXTRA_BIT-1:0]  sum_pp0[NUM_ELEMENTS*2-1];
    logic [WORD_LEN+EXTRA_BIT-1:0]  sum_pp1[NUM_ELEMENTS*2-1];
    logic [WORD_LEN+EXTRA_BIT-1:0]  sum_pp2[NUM_ELEMENTS*2-1];


    genvar k;
    generate
        for(k=0; k<NUM_ELEMENTS*2-1; k++)begin
            accumulator #(.NUM_ELEMENTS(NUM_ELEMENTS), .BIT_LEN(EXTRA_BIT + WORD_LEN))
	           u_accumulator0(.terms(grid_pp0[k]), .S(sum_pp0[k]));
            accumulator #(.NUM_ELEMENTS(NUM_ELEMENTS), .BIT_LEN(EXTRA_BIT + WORD_LEN))
	           u_accumulator1(.terms(grid_pp1[k]), .S(sum_pp1[k]));
            accumulator #(.NUM_ELEMENTS(NUM_ELEMENTS), .BIT_LEN(EXTRA_BIT + WORD_LEN))
	           u_accumulator2(.terms(grid_pp2[k]), .S(sum_pp2[k]));
        end
    endgenerate

    logic [WORD_LEN*2-1:0]  mid_sum[NUM_ELEMENTS*2+1];

    always_comb begin
        for(int i=1; i<NUM_ELEMENTS*2+1; i++)begin
            mid_sum[i] = 0;
        end

        mid_sum[0] = sum_pp0[0];
        mid_sum[1] = sum_pp0[1] + sum_pp1[0];
        mid_sum[NUM_ELEMENTS*2] = sum_pp2[NUM_ELEMENTS*2-2];
        mid_sum[NUM_ELEMENTS*2-1] = sum_pp1[NUM_ELEMENTS*2-2] + sum_pp2[NUM_ELEMENTS*2-3];
        for(int i=2; i<NUM_ELEMENTS*2-1; i++)begin
            mid_sum[i] = sum_pp0[i] + sum_pp1[i-1] + sum_pp2[i-2];
        end
    end


    always_comb begin
        M[0] = mid_sum[0][WORD_LEN-1:0];
        for(int i=1; i<NUM_ELEMENTS*2+1; i++)begin
            M[i] = mid_sum[i][WORD_LEN-1:0] + mid_sum[i-1][WORD_LEN*2-1:WORD_LEN];
        end
    end

endmodule



module dsp_multiplier
   #(
    parameter int A_BIT_LEN       = 17,
    parameter int B_BIT_LEN       = 17,
    parameter int MUL_OUT_BIT_LEN = A_BIT_LEN + B_BIT_LEN
    )
   (
    input  logic [A_BIT_LEN-1:0]       A,
    input  logic [B_BIT_LEN-1:0]       B,
    output logic [MUL_OUT_BIT_LEN-1:0] P
   );

    always_comb begin
        P[MUL_OUT_BIT_LEN-1:0] = A[A_BIT_LEN-1:0] * B[B_BIT_LEN-1:0];
    end
endmodule


module accumulator
   #(
        parameter int NUM_ELEMENTS      = 9,
        parameter int BIT_LEN           = 16
    )
   (
        input  logic [BIT_LEN-1:0] terms[NUM_ELEMENTS],
        output logic [BIT_LEN-1:0] S
   );

	always_comb begin
        S = 0;
        for(int k = 0; k < NUM_ELEMENTS; k++) begin
             S += terms[k];
        end
    end
endmodule


