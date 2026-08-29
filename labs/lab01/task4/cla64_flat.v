module cla64_flat (
    input  [63:0] a,
    input  [63:0] b,
    input         cin,
    output [63:0] sum,
    output        cout
);
    wire [63:0] p, g;
    wire [64:0] c;
    
    assign c[0] = cin;
    
    // P, G, and Sum generation
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : pg_gen
            assign p[i] = a[i] ^ b[i];
            assign g[i] = a[i] & b[i];
            assign sum[i] = p[i] ^ c[i];
        end
    endgenerate

    // Flat carry generation using bitwise masks to bypass dynamic bit-slicing errors
    genvar k, j;
    generate
        for (k = 1; k <= 64; k = k + 1) begin : flat_carry
            wire [64:0] terms;
            
            // First term is always just the generate of the previous bit
            assign terms[0] = g[k-1];
            
            // Middle terms
            for (j = 1; j < k; j = j + 1) begin : mid_terms
                // Create a 64-bit mask with 1s in the range we want to AND together
                wire [63:0] mask = ((65'b1 << j) - 1) << (k - j);
                
                // Force unneeded bits of p to 1, then do a reduction AND
                wire [63:0] p_masked = p | ~mask;
                assign terms[j] = g[k - 1 - j] & (&p_masked);
            end
            
            // Set unused terms for this bit position to 0
            for (j = k; j < 64; j = j + 1) begin : zero_terms
                assign terms[j] = 1'b0;
            end
            
            // Final term: Cin ANDed with all previous propagates
            wire [63:0] mask_cin = (65'b1 << k) - 1;
            wire [63:0] p_masked_cin = p | ~mask_cin;
            assign terms[64] = cin & (&p_masked_cin);
            
            // The flat carry is simply the OR of all calculated terms
            assign c[k] = |terms;
        end
    endgenerate
    
    assign cout = c[64];

endmodule