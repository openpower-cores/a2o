// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.





module lq_agen_csmux(
   sum_0,
   sum_1,
   ci_b,
   sum
);

input [0:7]     sum_0;		
input [0:7]     sum_1;
input           ci_b;

output [0:7]    sum;
               
wire [0:7]      sum0_b;

wire [0:7]      sum1_b;

wire            int_ci;

wire            int_ci_t;

wire            int_ci_b;

tri_inv int_ci_0 (.y(int_ci), .a(ci_b));

tri_inv int_ci_t_0 (.y(int_ci_t), .a(ci_b));

tri_inv int_ci_b_0 (.y(int_ci_b), .a(int_ci_t));

tri_nand2 #(.WIDTH(8)) sum0_b_0 (.y(sum0_b[0:7]), .a(sum_0[0:7]), .b({8{int_ci_b}}));








tri_nand2 #(.WIDTH(8)) sum1_b_0 (.y(sum1_b[0:7]), .a(sum_1[0:7]), .b({8{int_ci}}));








tri_nand2 #(.WIDTH(8)) sum0 (.y(sum[0:7]), .a(sum0_b[0:7]), .b(sum1_b[0:7]));







   
endmodule

