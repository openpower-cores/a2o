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

`timescale 1 ns / 1 ns

////############################################################################
////#####  NQ Quotient digit selection logic                              #########
////############################################################################

module fu_divsqrt_nq_table(
   x,
   nq
);
`include "tri_a2o.vh"

   input [0:3]  x;
   output  nq;

   wire    not1111;
   wire    nq_b;

//// Implements this table:
//   assign exx_nq_bit0        = (exx_sum4 == 4'b1000) ? 1'b1 :
//                               (exx_sum4 == 4'b1001) ? 1'b1 :
//                               (exx_sum4 == 4'b1010) ? 1'b1 :
//                               (exx_sum4 == 4'b1011) ? 1'b1 :
//                               (exx_sum4 == 4'b1100) ? 1'b1 :
//                               (exx_sum4 == 4'b1101) ? 1'b1 :
//                               (exx_sum4 == 4'b1110) ? 1'b1 :
//                               1'b0;


   tri_nand4 #(.WIDTH(1), .BTR("NAND4_X4M_A9TH")) DIVSQRT_NQ_TABLE_NAND4_00(not1111, x[0], x[1], x[2], x[3]);

   tri_nand2 #(.WIDTH(1), .BTR("NAND2_X6A_A9TH")) DIVSQRT_NQ_TABLE_NAND2_00(nq_b, x[0], not1111);

   tri_inv   #(.WIDTH(1), .BTR("INV_X11M_A9TH")) DIVSQRT_NQ_TABLE_INV_00(nq, nq_b);

endmodule
