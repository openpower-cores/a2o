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

// *!****************************************************************
// *! FILE NAME    :  tri_fu_mul_bthrow.vhdl
// *! DESCRIPTION  :  Booth Decode
// *!****************************************************************

module tri_fu_mul_bthrow(
   x,
   s_neg,
   s_x,
   s_x2,
   hot_one,
   q
);
   input [0:53]  x;
   input         s_neg;		// negate the row
   input         s_x;		// shift by 1
   input         s_x2;		// shift by 2
   output        hot_one;		// lsb term for row below
   output [0:54] q;		// final output

   // ENTITY


   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;

   wire [0:54]   left;
   wire          unused;

   assign unused = left[0];		// dangling pin from edge bit

   ////###############################################################
   //# A row of the repeated part of the booth_mux row
   ////###############################################################

   tri_fu_mul_bthmux u00(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(tidn),		//i--  ********
      .right(left[1]),		//i--  [n+1]
      .left(left[0]),		//o--  [n]
      .q(q[0])		//o--
   );


   tri_fu_mul_bthmux u01(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[0]),		//i--  [n-1]
      .right(left[2]),		//i--  [n+1]
      .left(left[1]),		//o--  [n]
      .q(q[1])		//o--
   );


   tri_fu_mul_bthmux u02(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[1]),		//i--
      .right(left[3]),		//i--
      .left(left[2]),		//o--
      .q(q[2])		//o--
   );


   tri_fu_mul_bthmux u03(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[2]),		//i--
      .right(left[4]),		//i--
      .left(left[3]),		//o--
      .q(q[3])		//o--
   );


   tri_fu_mul_bthmux u04(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[3]),		//i--
      .right(left[5]),		//i--
      .left(left[4]),		//o--
      .q(q[4])		//o--
   );


   tri_fu_mul_bthmux u05(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[4]),		//i--
      .right(left[6]),		//i--
      .left(left[5]),		//o--
      .q(q[5])		//o--
   );


   tri_fu_mul_bthmux u06(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[5]),		//i--
      .right(left[7]),		//i--
      .left(left[6]),		//o--
      .q(q[6])		//o--
   );


   tri_fu_mul_bthmux u07(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[6]),		//i--
      .right(left[8]),		//i--
      .left(left[7]),		//o--
      .q(q[7])		//o--
   );


   tri_fu_mul_bthmux u08(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[7]),		//i--
      .right(left[9]),		//i--
      .left(left[8]),		//o--
      .q(q[8])		//o--
   );


   tri_fu_mul_bthmux u09(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[8]),		//i--
      .right(left[10]),		//i--
      .left(left[9]),		//o--
      .q(q[9])		//o--
   );


   tri_fu_mul_bthmux u10(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[9]),		//i--
      .right(left[11]),		//i--
      .left(left[10]),		//o--
      .q(q[10])		//o--
   );


   tri_fu_mul_bthmux u11(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[10]),		//i--
      .right(left[12]),		//i--
      .left(left[11]),		//o--
      .q(q[11])		//o--
   );


   tri_fu_mul_bthmux u12(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[11]),		//i--
      .right(left[13]),		//i--
      .left(left[12]),		//o--
      .q(q[12])		//o--
   );


   tri_fu_mul_bthmux u13(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[12]),		//i--
      .right(left[14]),		//i--
      .left(left[13]),		//o--
      .q(q[13])		//o--
   );


   tri_fu_mul_bthmux u14(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[13]),		//i--
      .right(left[15]),		//i--
      .left(left[14]),		//o--
      .q(q[14])		//o--
   );


   tri_fu_mul_bthmux u15(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[14]),		//i--
      .right(left[16]),		//i--
      .left(left[15]),		//o--
      .q(q[15])		//o--
   );


   tri_fu_mul_bthmux u16(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[15]),		//i--
      .right(left[17]),		//i--
      .left(left[16]),		//o--
      .q(q[16])		//o--
   );


   tri_fu_mul_bthmux u17(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[16]),		//i--
      .right(left[18]),		//i--
      .left(left[17]),		//o--
      .q(q[17])		//o--
   );


   tri_fu_mul_bthmux u18(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[17]),		//i--
      .right(left[19]),		//i--
      .left(left[18]),		//o--
      .q(q[18])		//o--
   );


   tri_fu_mul_bthmux u19(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[18]),		//i--
      .right(left[20]),		//i--
      .left(left[19]),		//o--
      .q(q[19])		//o--
   );


   tri_fu_mul_bthmux u20(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[19]),		//i--
      .right(left[21]),		//i--
      .left(left[20]),		//o--
      .q(q[20])		//o--
   );


   tri_fu_mul_bthmux u21(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[20]),		//i--
      .right(left[22]),		//i--
      .left(left[21]),		//o--
      .q(q[21])		//o--
   );


   tri_fu_mul_bthmux u22(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[21]),		//i--
      .right(left[23]),		//i--
      .left(left[22]),		//o--
      .q(q[22])		//o--
   );


   tri_fu_mul_bthmux u23(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[22]),		//i--
      .right(left[24]),		//i--
      .left(left[23]),		//o--
      .q(q[23])		//o--
   );


   tri_fu_mul_bthmux u24(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[23]),		//i--
      .right(left[25]),		//i--
      .left(left[24]),		//o--
      .q(q[24])		//o--
   );


   tri_fu_mul_bthmux u25(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[24]),		//i--
      .right(left[26]),		//i--
      .left(left[25]),		//o--
      .q(q[25])		//o--
   );


   tri_fu_mul_bthmux u26(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[25]),		//i--
      .right(left[27]),		//i--
      .left(left[26]),		//o--
      .q(q[26])		//o--
   );


   tri_fu_mul_bthmux u27(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[26]),		//i--
      .right(left[28]),		//i--
      .left(left[27]),		//o--
      .q(q[27])		//o--
   );


   tri_fu_mul_bthmux u28(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[27]),		//i--
      .right(left[29]),		//i--
      .left(left[28]),		//o--
      .q(q[28])		//o--
   );


   tri_fu_mul_bthmux u29(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[28]),		//i--
      .right(left[30]),		//i--
      .left(left[29]),		//o--
      .q(q[29])		//o--
   );


   tri_fu_mul_bthmux u30(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[29]),		//i--
      .right(left[31]),		//i--
      .left(left[30]),		//o--
      .q(q[30])		//o--
   );


   tri_fu_mul_bthmux u31(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[30]),		//i--
      .right(left[32]),		//i--
      .left(left[31]),		//o--
      .q(q[31])		//o--
   );


   tri_fu_mul_bthmux u32(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[31]),		//i--
      .right(left[33]),		//i--
      .left(left[32]),		//o--
      .q(q[32])		//o--
   );


   tri_fu_mul_bthmux u33(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[32]),		//i--
      .right(left[34]),		//i--
      .left(left[33]),		//o--
      .q(q[33])		//o--
   );


   tri_fu_mul_bthmux u34(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[33]),		//i--
      .right(left[35]),		//i--
      .left(left[34]),		//o--
      .q(q[34])		//o--
   );


   tri_fu_mul_bthmux u35(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[34]),		//i--
      .right(left[36]),		//i--
      .left(left[35]),		//o--
      .q(q[35])		//o--
   );


   tri_fu_mul_bthmux u36(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[35]),		//i--
      .right(left[37]),		//i--
      .left(left[36]),		//o--
      .q(q[36])		//o--
   );


   tri_fu_mul_bthmux u37(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[36]),		//i--
      .right(left[38]),		//i--
      .left(left[37]),		//o--
      .q(q[37])		//o--
   );


   tri_fu_mul_bthmux u38(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[37]),		//i--
      .right(left[39]),		//i--
      .left(left[38]),		//o--
      .q(q[38])		//o--
   );


   tri_fu_mul_bthmux u39(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[38]),		//i--
      .right(left[40]),		//i--
      .left(left[39]),		//o--
      .q(q[39])		//o--
   );


   tri_fu_mul_bthmux u40(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[39]),		//i--
      .right(left[41]),		//i--
      .left(left[40]),		//o--
      .q(q[40])		//o--
   );


   tri_fu_mul_bthmux u41(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[40]),		//i--
      .right(left[42]),		//i--
      .left(left[41]),		//o--
      .q(q[41])		//o--
   );


   tri_fu_mul_bthmux u42(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[41]),		//i--
      .right(left[43]),		//i--
      .left(left[42]),		//o--
      .q(q[42])		//o--
   );


   tri_fu_mul_bthmux u43(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[42]),		//i--
      .right(left[44]),		//i--
      .left(left[43]),		//o--
      .q(q[43])		//o--
   );


   tri_fu_mul_bthmux u44(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[43]),		//i--
      .right(left[45]),		//i--
      .left(left[44]),		//o--
      .q(q[44])		//o--
   );


   tri_fu_mul_bthmux u45(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[44]),		//i--
      .right(left[46]),		//i--
      .left(left[45]),		//o--
      .q(q[45])		//o--
   );


   tri_fu_mul_bthmux u46(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[45]),		//i--
      .right(left[47]),		//i--
      .left(left[46]),		//o--
      .q(q[46])		//o--
   );


   tri_fu_mul_bthmux u47(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[46]),		//i--
      .right(left[48]),		//i--
      .left(left[47]),		//o--
      .q(q[47])		//o--
   );


   tri_fu_mul_bthmux u48(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[47]),		//i--
      .right(left[49]),		//i--
      .left(left[48]),		//o--
      .q(q[48])		//o--
   );


   tri_fu_mul_bthmux u49(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[48]),		//i--
      .right(left[50]),		//i--
      .left(left[49]),		//o--
      .q(q[49])		//o--
   );


   tri_fu_mul_bthmux u50(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[49]),		//i--
      .right(left[51]),		//i--
      .left(left[50]),		//o--
      .q(q[50])		//o--
   );


   tri_fu_mul_bthmux u51(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[50]),		//i--
      .right(left[52]),		//i--
      .left(left[51]),		//o--
      .q(q[51])		//o--
   );


   tri_fu_mul_bthmux u52(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[51]),		//i--
      .right(left[53]),		//i--
      .left(left[52]),		//o--
      .q(q[52])		//o--
   );


   tri_fu_mul_bthmux u53(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[52]),		//i--
      .right(left[54]),		//i--
      .left(left[53]),		//o--
      .q(q[53])		//o--
   );


   tri_fu_mul_bthmux u54(
      .sneg(s_neg),		//i--
      .sx(s_x),		//i--
      .sx2(s_x2),		//i--
      .x(x[53]),		//i--
      .right(s_neg),		//i--
      .left(left[54]),		//o--
      .q(q[54])		//o--
   );

   // For negate -A = !A + 1 ... this term is the plus 1.
   // this has same bit weight as LSB, so it jumps down a row to free spot in compressor tree.

   assign hot_one = (s_neg & (s_x | s_x2));

endmodule
