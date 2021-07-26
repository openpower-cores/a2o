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
////#####  Q Quotient digit selection logic                              #######
////############################################################################

module fu_divsqrt_q_table(
   x,
   cin,
   q
);
`include "tri_a2o.vh"

   input [0:3]  x;
   input        cin;

   output  q;

   wire    nor123;
   wire    nor123_b;

   wire    x0_b;
   wire    not0and1or2or3_b;
   wire    nor01;
   wire    nor23;
   wire    not0or1or2or3_and_cin_b;


//// Implements this table:
//    assign exx_q_bit0_prebuf = (exx_sum4 == 4'b0000) ? exx_q_bit0_cin :
//                               (exx_sum4 == 4'b0001) ? 1'b1 :
//                               (exx_sum4 == 4'b0010) ? 1'b1 :
//                               (exx_sum4 == 4'b0011) ? 1'b1 :
//                               (exx_sum4 == 4'b0100) ? 1'b1 :
//                               (exx_sum4 == 4'b0101) ? 1'b1 :
//                               (exx_sum4 == 4'b0110) ? 1'b1 :
//                               (exx_sum4 == 4'b0111) ? 1'b1 :
//                               1'b0;


   tri_nor3 #(.WIDTH(1), .BTR("NOR3_X4M_A9TH"))  DIVSQRT_N_TABLE_NOR3_01(nor123, x[1], x[2], x[3]);
   tri_inv  #(.WIDTH(1), .BTR("INV_X3M_A9TH"))   DIVSQRT_N_TABLE_INV_02a(nor123_b, nor123);
   tri_inv  #(.WIDTH(1), .BTR("INV_X5B_A9TH"))   DIVSQRT_N_TABLE_INV_02b(x0_b, x[0]);

   tri_nand2 #(.WIDTH(1), .BTR("NAND2_X4A_A9TH")) DIVSQRT_N_TABLE_NAND2_03(not0and1or2or3_b, x0_b, nor123_b);
//
   tri_nor2 #(.WIDTH(1), .BTR("NOR2_X8B_A9TH"))  DIVSQRT_N_TABLE_NOR2_01a(nor01, x[0], x[1]);
   tri_nor2 #(.WIDTH(1), .BTR("NOR2_X4B_A9TH"))  DIVSQRT_N_TABLE_NOR2_01b(nor23, x[2], x[3]);

   tri_nand3 #(.WIDTH(1), .BTR("NAND3_X6M_A9TH")) DIVSQRT_N_TABLE_NAND3_02(not0or1or2or3_and_cin_b, nor01, nor23, cin);
//

   tri_nand2 #(.WIDTH(1), .BTR("NAND2_X8A_A9TH")) DIVSQRT_N_TABLE_NAND2_04(q, not0or1or2or3_and_cin_b, not0and1or2or3_b);


endmodule
