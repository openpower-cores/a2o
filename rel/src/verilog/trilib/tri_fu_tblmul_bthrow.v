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

   `include "tri_a2o.vh"

module tri_fu_tblmul_bthrow(
   x,
   s_neg,
   s_x,
   s_x2,
   q
);

   input [0:15]  x;		//
   input         s_neg;		// negate the row
   input         s_x;		// shift by 1
   input         s_x2;		// shift by 2
   output [0:16] q;		// final output

   // ENTITY


   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;

   wire [0:16]   left;
   wire          unused;

   ////################################################################
   ////# A row of the repeated part of the booth_mux row
   ////################################################################

   assign unused = left[0];

   tri_fu_mul_bthmux u00(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(tidn),		//i--  ********
      .left(left[0]),		//o--  [n]
      .right(left[1]),		//i--  [n+1]
      .q(q[0])		//o--
   );


   tri_fu_mul_bthmux u01(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[0]),		//i--  [n-1]
      .left(left[1]),		//o--  [n]
      .right(left[2]),		//i--  [n+1]
      .q(q[1])		//o--
   );


   tri_fu_mul_bthmux u02(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[1]),		//i--
      .left(left[2]),		//o--
      .right(left[3]),		//i--
      .q(q[2])		//o--
   );


   tri_fu_mul_bthmux u03(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[2]),		//i--
      .left(left[3]),		//o--
      .right(left[4]),		//i--
      .q(q[3])		//o--
   );


   tri_fu_mul_bthmux u04(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[3]),		//i--
      .left(left[4]),		//o--
      .right(left[5]),		//i--
      .q(q[4])		//o--
   );


   tri_fu_mul_bthmux u05(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[4]),		//i--
      .left(left[5]),		//o--
      .right(left[6]),		//i--
      .q(q[5])		//o--
   );


   tri_fu_mul_bthmux u06(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[5]),		//i--
      .left(left[6]),		//o--
      .right(left[7]),		//i--
      .q(q[6])		//o--
   );


   tri_fu_mul_bthmux u07(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[6]),		//i--
      .left(left[7]),		//o--
      .right(left[8]),		//i--
      .q(q[7])		//o--
   );


   tri_fu_mul_bthmux u08(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[7]),		//i--
      .left(left[8]),		//o--
      .right(left[9]),		//i--
      .q(q[8])		//o--
   );


   tri_fu_mul_bthmux u09(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[8]),		//i--
      .left(left[9]),		//o--
      .right(left[10]),		//i--
      .q(q[9])		//o--
   );


   tri_fu_mul_bthmux u10(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[9]),		//i--
      .left(left[10]),		//o--
      .right(left[11]),		//i--
      .q(q[10])		//o--
   );


   tri_fu_mul_bthmux u11(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[10]),		//i--
      .left(left[11]),		//o--
      .right(left[12]),		//i--
      .q(q[11])		//o--
   );


   tri_fu_mul_bthmux u12(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[11]),		//i--
      .left(left[12]),		//o--
      .right(left[13]),		//i--
      .q(q[12])		//o--
   );


   tri_fu_mul_bthmux u13(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[12]),		//i--
      .left(left[13]),		//o--
      .right(left[14]),		//i--
      .q(q[13])		//o--
   );


   tri_fu_mul_bthmux u14(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[13]),		//i--
      .left(left[14]),		//o--
      .right(left[15]),		//i--
      .q(q[14])		//o--
   );


   tri_fu_mul_bthmux u15(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[14]),		//i--
      .left(left[15]),		//o--
      .right(left[16]),		//i--
      .q(q[15])		//o--
   );


   tri_fu_mul_bthmux u16(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[15]),		//i--
      .left(left[16]),		//o--
      .right(s_neg),		//i--
      .q(q[16])		//o--
   );

endmodule
