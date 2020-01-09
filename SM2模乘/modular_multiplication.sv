/*
基于ozturk乘法器和Barrett模约减算法的模乘器。
*/

module modular_multiplication
#(
    parameter NUM_ELEMENTS          = 17,
    parameter BIT_LEN               = 17,
    parameter WORD_LEN              = 16
)
(
    input logic [BIT_LEN-1:0] A[NUM_ELEMENTS],
    input logic [BIT_LEN-1:0] B[NUM_ELEMENTS],
    output logic [BIT_LEN-1:0] MM[NUM_ELEMENTS]
);

    logic [BIT_LEN-1:0] M[NUM_ELEMENTS*2+1];

    multiplier #(.NUM_ELEMENTS(NUM_ELEMENTS), .WORD_LEN(WORD_LEN))
        u_multiplier (.A(A), .B(B), .M(M));

    reduction #(.NUM_ELEMENTS(NUM_ELEMENTS), .WORD_LEN(WORD_LEN))
        u_reduction(.m(M), .mm(MM));


endmodule


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




module reduction
#(
    parameter NUM_ELEMENTS          = 17,
    parameter BIT_LEN               = 17,
    parameter WORD_LEN              = 16,
    parameter XPB_SEG               = 16,
    parameter NUM_FLAG              = NUM_ELEMENTS*2+1-XPB_SEG

)
(
    input logic [BIT_LEN-1:0] m[NUM_ELEMENTS*2+1],
    output logic [BIT_LEN-1:0] mm[NUM_ELEMENTS]
);

    localparam PB = 256'd26959946667150639794667015087019630673716372585036390074623444647937;

    logic [NUM_ELEMENTS-2:0][WORD_LEN-1:0] xpb_terms[NUM_FLAG*3];
    logic [5:0] xpb_flag[NUM_FLAG*3];

    logic [XPB_SEG-1:0][WORD_LEN-1:0] m_l_temp0;
    logic [XPB_SEG-1:0][WORD_LEN-1:0] m_l_temp1;
    logic [XPB_SEG-1:0][WORD_LEN-1:0] m_l_temp2;
    logic [XPB_SEG-1:0][WORD_LEN-1:0] m_l_temp3;
    


    always_comb begin
        for(int i=0; i<XPB_SEG; i++)begin
            m_l_temp0[i] = m[i][WORD_LEN-1:0];
            m_l_temp3[i] = { {(WORD_LEN-1){1'b0}} ,m[i][BIT_LEN-1:WORD_LEN]};
        end
        m_l_temp2 = (m[XPB_SEG-1][BIT_LEN-1]) ? PB : 256'd0;
    end

    always_comb begin
        m_l_temp1 = m_l_temp3 << WORD_LEN;
    end

    always_comb begin
        for(int i=0; i<NUM_FLAG; i++)begin
            xpb_flag[i*3] = m[i+XPB_SEG][5:0];
            xpb_flag[i*3+1] = m[i+XPB_SEG][11:6];
            xpb_flag[i*3+2] = { 1'b0,m[i+XPB_SEG][BIT_LEN-1:12]};
        end
    end
    

    
    
    xpb_lut u_xpb_lut(.flag(xpb_flag), .xpb(xpb_terms));


    localparam EXTRA_BIT_XPB = $clog2((NUM_FLAG)*3+3);

    logic [EXTRA_BIT_XPB+WORD_LEN-1:0] grid_xpb[NUM_ELEMENTS][(NUM_FLAG)*3+3];


    always_comb begin
        for(int c=0; c<NUM_ELEMENTS; c++)begin
            for(int r=0; r<NUM_FLAG*2+3; r++)begin
                grid_xpb[c][r] = 0;
            end
        end
        for(int i=0; i<XPB_SEG; i++)begin
            grid_xpb[i][0] = m_l_temp0[i];
            grid_xpb[i][1] = m_l_temp1[i];
            grid_xpb[i][2] = m_l_temp2[i];
            for(int j=0; j< NUM_FLAG *3; j++)begin
                grid_xpb[i][j+3] = xpb_terms[j][i];
            end
        end
    end

    logic [EXTRA_BIT_XPB + WORD_LEN-1:0] xpb_sum[NUM_ELEMENTS-1];

    genvar i;
    generate
        for(i=0; i<NUM_ELEMENTS-1; i++)begin
            accumulator #(.NUM_ELEMENTS((NUM_FLAG)*3+3), .BIT_LEN(EXTRA_BIT_XPB + WORD_LEN))
	           u_accumulator(.terms(grid_xpb[i]), .S(xpb_sum[i]));
        end
    endgenerate

    always_comb begin
        mm[0] = { 1'b0, xpb_sum[0][WORD_LEN-1:0]};
        mm[NUM_ELEMENTS-1] = { {(BIT_LEN-EXTRA_BIT_XPB){1'b0}}, xpb_sum[NUM_ELEMENTS-2][EXTRA_BIT_XPB + WORD_LEN-1:WORD_LEN]};
        for(int i=1; i<NUM_ELEMENTS-1; i++)begin
            mm[i] = xpb_sum[i][WORD_LEN-1:0] + xpb_sum[i-1][EXTRA_BIT_XPB+WORD_LEN-1:WORD_LEN];
        end
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