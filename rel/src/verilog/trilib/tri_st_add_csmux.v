// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

//  Description:  Adder Component
//
//*****************************************************************************

// input phase is important
// (change X (B) by switching xor/xnor )

module tri_st_add_csmux(
   sum_0,
   sum_1,
   ci_b,
   sum
);
   input [0:7]  sum_0;		// after xor
   input [0:7]  sum_1;
   input        ci_b;
   output [0:7] sum;

   wire [0:7]   sum0_b;
   wire [0:7]   sum1_b;
   wire         int_ci;
   wire         int_ci_t;
   wire         int_ci_b;

   assign int_ci = (~ci_b);
   assign int_ci_t = (~ci_b);
   assign int_ci_b = (~int_ci_t);

   assign sum0_b[0] = (~(sum_0[0] & int_ci_b));
   assign sum0_b[1] = (~(sum_0[1] & int_ci_b));
   assign sum0_b[2] = (~(sum_0[2] & int_ci_b));
   assign sum0_b[3] = (~(sum_0[3] & int_ci_b));
   assign sum0_b[4] = (~(sum_0[4] & int_ci_b));
   assign sum0_b[5] = (~(sum_0[5] & int_ci_b));
   assign sum0_b[6] = (~(sum_0[6] & int_ci_b));
   assign sum0_b[7] = (~(sum_0[7] & int_ci_b));

   assign sum1_b[0] = (~(sum_1[0] & int_ci));
   assign sum1_b[1] = (~(sum_1[1] & int_ci));
   assign sum1_b[2] = (~(sum_1[2] & int_ci));
   assign sum1_b[3] = (~(sum_1[3] & int_ci));
   assign sum1_b[4] = (~(sum_1[4] & int_ci));
   assign sum1_b[5] = (~(sum_1[5] & int_ci));
   assign sum1_b[6] = (~(sum_1[6] & int_ci));
   assign sum1_b[7] = (~(sum_1[7] & int_ci));

   assign sum[0] = (~(sum0_b[0] & sum1_b[0]));
   assign sum[1] = (~(sum0_b[1] & sum1_b[1]));
   assign sum[2] = (~(sum0_b[2] & sum1_b[2]));
   assign sum[3] = (~(sum0_b[3] & sum1_b[3]));
   assign sum[4] = (~(sum0_b[4] & sum1_b[4]));
   assign sum[5] = (~(sum0_b[5] & sum1_b[5]));
   assign sum[6] = (~(sum0_b[6] & sum1_b[6]));
   assign sum[7] = (~(sum0_b[7] & sum1_b[7]));

endmodule
