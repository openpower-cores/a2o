// © IBM Corp. 2020
// Licensed under the Apache License, Version 2.0 (the "License"), as modified by
// the terms below; you may not use the files in this repository except in
// compliance with the License as modified.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Modified Terms:
//
//    1) For the purpose of the patent license granted to you in Section 3 of the
//    License, the "Work" hereby includes implementations of the work of authorship
//    in physical form.
//
//    2) Notwithstanding any terms to the contrary in the License, any licenses
//    necessary for implementation of the Work that are available from OpenPOWER
//    via the Power ISA End User License Agreement (EULA) are explicitly excluded
//    hereunder, and may be obtained from OpenPOWER under the terms and conditions
//    of the EULA.  
//
// Unless required by applicable law or agreed to in writing, the reference design
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
// for the specific language governing permissions and limitations under the License.
// 
// Additional rights, including the ability to physically implement a softcore that
// is compliant with the required sections of the Power ISA Specification, are
// available at no cost under the terms of the OpenPOWER Power ISA EULA, which can be
// obtained (along with the Power ISA) here: https://openpowerfoundation.org. 

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
