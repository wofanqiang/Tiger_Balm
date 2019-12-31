/*--------------------------------------------------
Input: terms包含n个数
Output: S = terms中所有数的和

NUM_ELEMENTS 是terms中所有元素的个数。
BIT_LEN 是所有数的和的长度。

*综合的时候，可能会出warning，可忽略。
**注意需要提前将terms中元素的长度补成BIT_LEN。

a3	+	a2		a1	+	a0
    b1      +       b0
	        S			


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

adder_tree_2_to_1 #(.NUM_ELEMENTS(NUM_ELEMENTS), .BIT_LEN(BIT_LEN))
	u_adder_tree_2_to_1(.terms(terms), S(S));

--------------------------------------------------*/


module adder_tree_2_to_1
   #(
     parameter int NUM_ELEMENTS      = 9,
     parameter int BIT_LEN           = 16
    )
   (
    input  logic [BIT_LEN-1:0] terms[NUM_ELEMENTS],
    output logic [BIT_LEN-1:0] S
   );


   generate
      if (NUM_ELEMENTS == 1) begin // Return value
         always_comb begin
            S[BIT_LEN-1:0] = terms[0];
         end
      end else if (NUM_ELEMENTS == 2) begin // Return value
         always_comb begin
            S[BIT_LEN-1:0] = terms[0] + terms[1];
         end
      end else begin
         localparam integer NUM_RESULTS = integer'(NUM_ELEMENTS/2) + (NUM_ELEMENTS%2);
         logic [BIT_LEN-1:0] next_level_terms[NUM_RESULTS];

         adder_tree_level #(.NUM_ELEMENTS(NUM_ELEMENTS),
                            .BIT_LEN(BIT_LEN)
         ) adder_tree_level (
                            .terms(terms),
                            .results(next_level_terms)
         );

         adder_tree_2_to_1 #(.NUM_ELEMENTS(NUM_RESULTS),
                                  .BIT_LEN(BIT_LEN)
         ) adder_tree_2_to_1 (
                                  .terms(next_level_terms),
                                  .S(S)
         );
      end
   endgenerate
endmodule


module adder_tree_level
   #(
     parameter int NUM_ELEMENTS = 3,
     parameter int BIT_LEN      = 19,

     parameter int NUM_RESULTS  = integer'(NUM_ELEMENTS/2) + (NUM_ELEMENTS%2)
    )
   (
    input  logic [BIT_LEN-1:0] terms[NUM_ELEMENTS],
    output logic [BIT_LEN-1:0] results[NUM_RESULTS]
   );

   always_comb begin
      for (int i=0; i<(NUM_ELEMENTS / 2); i++) begin
         results[i] = terms[i*2] + terms[i*2+1];
      end

      if( NUM_ELEMENTS % 2 == 1 ) begin
         results[NUM_RESULTS-1] = terms[NUM_ELEMENTS-1];
      end
   end
endmodule