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

//  Description:  XU Multiplier Top
//
//*****************************************************************************

module tri_st_mult_boothrow(
   s_neg,
   s_x,
   s_x2,
   sign_bit_adj,
   x,
   q,
   hot_one
);
   input         s_neg;		// negate the row
   input         s_x;		// shift by 0
   input         s_x2;		// shift by 1
   input         sign_bit_adj;
   input [0:31]  x;		// input (multiplicand)
   output [0:32] q;		// final output
   // lsb term for row below
   output        hot_one;

   wire [1:32]   left;

   //-------------------------------------------------------------------
   // Build the booth mux row bit by bit
   //-------------------------------------------------------------------

   tri_bthmx u00(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(sign_bit_adj),
      .right(left[1]),
      .left(),
      .q(q[0])
   );


   tri_bthmx u01(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[0]),
      .right(left[2]),
      .left(left[1]),
      .q(q[1])
   );


   tri_bthmx u02(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[1]),
      .right(left[3]),
      .left(left[2]),
      .q(q[2])
   );


   tri_bthmx u03(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[2]),
      .right(left[4]),
      .left(left[3]),
      .q(q[3])
   );


   tri_bthmx u04(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[3]),
      .right(left[5]),
      .left(left[4]),
      .q(q[4])
   );


   tri_bthmx u05(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[4]),
      .right(left[6]),
      .left(left[5]),
      .q(q[5])
   );


   tri_bthmx u06(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[5]),
      .right(left[7]),
      .left(left[6]),
      .q(q[6])
   );


   tri_bthmx u07(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[6]),
      .right(left[8]),
      .left(left[7]),
      .q(q[7])
   );


   tri_bthmx u08(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[7]),
      .right(left[9]),
      .left(left[8]),
      .q(q[8])
   );


   tri_bthmx u09(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[8]),
      .right(left[10]),
      .left(left[9]),
      .q(q[9])
   );


   tri_bthmx u10(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[9]),
      .right(left[11]),
      .left(left[10]),
      .q(q[10])
   );


   tri_bthmx u11(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[10]),
      .right(left[12]),
      .left(left[11]),
      .q(q[11])
   );


   tri_bthmx u12(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[11]),
      .right(left[13]),
      .left(left[12]),
      .q(q[12])
   );


   tri_bthmx u13(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[12]),
      .right(left[14]),
      .left(left[13]),
      .q(q[13])
   );


   tri_bthmx u14(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[13]),
      .right(left[15]),
      .left(left[14]),
      .q(q[14])
   );


   tri_bthmx u15(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[14]),
      .right(left[16]),
      .left(left[15]),
      .q(q[15])
   );


   tri_bthmx u16(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[15]),
      .right(left[17]),
      .left(left[16]),
      .q(q[16])
   );


   tri_bthmx u17(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[16]),
      .right(left[18]),
      .left(left[17]),
      .q(q[17])
   );


   tri_bthmx u18(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[17]),
      .right(left[19]),
      .left(left[18]),
      .q(q[18])
   );


   tri_bthmx u19(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[18]),
      .right(left[20]),
      .left(left[19]),
      .q(q[19])
   );


   tri_bthmx u20(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[19]),
      .right(left[21]),
      .left(left[20]),
      .q(q[20])
   );


   tri_bthmx u21(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[20]),
      .right(left[22]),
      .left(left[21]),
      .q(q[21])
   );


   tri_bthmx u22(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[21]),
      .right(left[23]),
      .left(left[22]),
      .q(q[22])
   );


   tri_bthmx u23(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[22]),
      .right(left[24]),
      .left(left[23]),
      .q(q[23])
   );


   tri_bthmx u24(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[23]),
      .right(left[25]),
      .left(left[24]),
      .q(q[24])
   );


   tri_bthmx u25(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[24]),
      .right(left[26]),
      .left(left[25]),
      .q(q[25])
   );


   tri_bthmx u26(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[25]),
      .right(left[27]),
      .left(left[26]),
      .q(q[26])
   );


   tri_bthmx u27(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[26]),
      .right(left[28]),
      .left(left[27]),
      .q(q[27])
   );


   tri_bthmx u28(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[27]),
      .right(left[29]),
      .left(left[28]),
      .q(q[28])
   );


   tri_bthmx u29(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[28]),
      .right(left[30]),
      .left(left[29]),
      .q(q[29])
   );


   tri_bthmx u30(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[29]),
      .right(left[31]),
      .left(left[30]),
      .q(q[30])
   );


   tri_bthmx u31(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[30]),
      .right(left[32]),
      .left(left[31]),
      .q(q[31])
   );


   tri_bthmx u32(
      .sneg(s_neg),
      .sx(s_x),
      .sx2(s_x2),
      .x(x[31]),
      .right(s_neg),
      .left(left[32]),
      .q(q[32])
   );

   assign hot_one = s_neg & (s_x | s_x2);

endmodule
