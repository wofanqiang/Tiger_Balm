/*--------------------------------------------------
Input: terms包含n个数
Output: S = terms中所有数的和

NUM_ELEMENTS 是terms中所有元素的个数。
BIT_LEN 是所有数的和的长度。

**注意需要提前将terms中元素的长度补成BIT_LEN。

S = a3 + a2 + a1 + a0


示例：
localparam EXTRA_BIT = $clog2(NUM_ELEMENTS);
localparam BIT_LEN = EXTRA_BIT + WORD_LEN;

logic [WORD_LEN-1:0] terms_raw[NUM_ELEMENTS];
logic [BIT_LEN-1:0] terms[NUM_ELEMENTS];
logic [BIT_LEN-1:0] S;

always_comb begin
   	for(int i=0; i <NUM_ELEMENTS; i++)begin
       terms[i] = { {(EXTRA_BIT){1'b0}} , terms_raw[i] };
   	end
end

accumulator #(.NUM_ELEMENTS(NUM_ELEMENTS), .BIT_LEN(BIT_LEN))
	u_accumulator(.terms(terms), S(S));

--------------------------------------------------*/


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