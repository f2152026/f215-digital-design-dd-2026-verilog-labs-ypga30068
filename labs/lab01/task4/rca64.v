// rca64.v
// 64-bit Ripple-Carry Adder
// Uses a generate loop to instantiate and chain 64 FA_Gate modules.

module rca64(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  // We need 65 carry signals in total: 
  // c[0] is the initial cin, c[1] to c[63] are the intermediate carries, 
  // and c[64] is the final cout.
  wire [64:0] c;
  
  // Connect the initial carry-in to the first index of our wire array
  assign c[0] = cin;

  // Use a generate block to instantiate 64 Full Adders
  genvar i;
  generate
    for (i = 0; i < 64; i = i + 1) begin : fa_chain
      FA_Gate fa_inst (
        .a(a[i]),
        .b(b[i]),
        .cin(c[i]),
        .sum(sum[i]),
        .cout(c[i+1])
      );
    end
  endgenerate

  // Connect the final carry-out from the last index of our wire array
  assign cout = c[64];

endmodule