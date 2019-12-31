module tb_adder_tree_2_to_1;

    parameter int NUM_ELEMENTS      = 10;
    parameter int BIT_LEN           = 16;

    logic [BIT_LEN-1:0] terms[NUM_ELEMENTS];
    logic [BIT_LEN-1:0] S;


    initial begin
        for(int i = 0; i< NUM_ELEMENTS; i++)begin
            terms[i] = 12'hfff;
        end
    end
    

    adder_tree_2_to_1 #(.NUM_ELEMENTS(NUM_ELEMENTS),
                                    .BIT_LEN(BIT_LEN)
                                   )
              adder_tree_2_to_1_3 (
                 .terms(terms),
                 .S(S)
              );


endmodule