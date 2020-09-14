// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.



module tri_fu_mul_bthrow(
   x,
   s_neg,
   s_x,
   s_x2,
   hot_one,
   q
);
   input [0:53]  x;
   input         s_neg;		
   input         s_x;		
   input         s_x2;		
   output        hot_one;		
   output [0:54] q;		
   
   
   
   
   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;
   
   wire [0:54]   left;
   wire          unused;
   
   assign unused = left[0];		
   
   
   tri_fu_mul_bthmux u00(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(tidn),		
      .right(left[1]),		
      .left(left[0]),		
      .q(q[0])		
   );
   
   
   tri_fu_mul_bthmux u01(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[0]),		
      .right(left[2]),		
      .left(left[1]),		
      .q(q[1])		
   );
   
   
   tri_fu_mul_bthmux u02(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[1]),		
      .right(left[3]),		
      .left(left[2]),		
      .q(q[2])		
   );
   
   
   tri_fu_mul_bthmux u03(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[2]),		
      .right(left[4]),		
      .left(left[3]),		
      .q(q[3])		
   );
   
   
   tri_fu_mul_bthmux u04(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[3]),		
      .right(left[5]),		
      .left(left[4]),		
      .q(q[4])		
   );
   
   
   tri_fu_mul_bthmux u05(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[4]),		
      .right(left[6]),		
      .left(left[5]),		
      .q(q[5])		
   );
   
   
   tri_fu_mul_bthmux u06(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[5]),		
      .right(left[7]),		
      .left(left[6]),		
      .q(q[6])		
   );
   
   
   tri_fu_mul_bthmux u07(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[6]),		
      .right(left[8]),		
      .left(left[7]),		
      .q(q[7])		
   );
   
   
   tri_fu_mul_bthmux u08(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[7]),		
      .right(left[9]),		
      .left(left[8]),		
      .q(q[8])		
   );
   
   
   tri_fu_mul_bthmux u09(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[8]),		
      .right(left[10]),		
      .left(left[9]),		
      .q(q[9])		
   );
   
   
   tri_fu_mul_bthmux u10(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[9]),		
      .right(left[11]),		
      .left(left[10]),		
      .q(q[10])		
   );
   
   
   tri_fu_mul_bthmux u11(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[10]),		
      .right(left[12]),		
      .left(left[11]),		
      .q(q[11])		
   );
   
   
   tri_fu_mul_bthmux u12(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[11]),		
      .right(left[13]),		
      .left(left[12]),		
      .q(q[12])		
   );
   
   
   tri_fu_mul_bthmux u13(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[12]),		
      .right(left[14]),		
      .left(left[13]),		
      .q(q[13])		
   );
   
   
   tri_fu_mul_bthmux u14(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[13]),		
      .right(left[15]),		
      .left(left[14]),		
      .q(q[14])		
   );
   
   
   tri_fu_mul_bthmux u15(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[14]),		
      .right(left[16]),		
      .left(left[15]),		
      .q(q[15])		
   );
   
   
   tri_fu_mul_bthmux u16(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[15]),		
      .right(left[17]),		
      .left(left[16]),		
      .q(q[16])		
   );
   
   
   tri_fu_mul_bthmux u17(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[16]),		
      .right(left[18]),		
      .left(left[17]),		
      .q(q[17])		
   );
   
   
   tri_fu_mul_bthmux u18(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[17]),		
      .right(left[19]),		
      .left(left[18]),		
      .q(q[18])		
   );
   
   
   tri_fu_mul_bthmux u19(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[18]),		
      .right(left[20]),		
      .left(left[19]),		
      .q(q[19])		
   );
   
   
   tri_fu_mul_bthmux u20(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[19]),		
      .right(left[21]),		
      .left(left[20]),		
      .q(q[20])		
   );
   
   
   tri_fu_mul_bthmux u21(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[20]),		
      .right(left[22]),		
      .left(left[21]),		
      .q(q[21])		
   );
   
   
   tri_fu_mul_bthmux u22(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[21]),		
      .right(left[23]),		
      .left(left[22]),		
      .q(q[22])		
   );
   
   
   tri_fu_mul_bthmux u23(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[22]),		
      .right(left[24]),		
      .left(left[23]),		
      .q(q[23])		
   );
   
   
   tri_fu_mul_bthmux u24(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[23]),		
      .right(left[25]),		
      .left(left[24]),		
      .q(q[24])		
   );
   
   
   tri_fu_mul_bthmux u25(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[24]),		
      .right(left[26]),		
      .left(left[25]),		
      .q(q[25])		
   );
   
   
   tri_fu_mul_bthmux u26(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[25]),		
      .right(left[27]),		
      .left(left[26]),		
      .q(q[26])		
   );
   
   
   tri_fu_mul_bthmux u27(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[26]),		
      .right(left[28]),		
      .left(left[27]),		
      .q(q[27])		
   );
   
   
   tri_fu_mul_bthmux u28(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[27]),		
      .right(left[29]),		
      .left(left[28]),		
      .q(q[28])		
   );
   
   
   tri_fu_mul_bthmux u29(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[28]),		
      .right(left[30]),		
      .left(left[29]),		
      .q(q[29])		
   );
   
   
   tri_fu_mul_bthmux u30(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[29]),		
      .right(left[31]),		
      .left(left[30]),		
      .q(q[30])		
   );
   
   
   tri_fu_mul_bthmux u31(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[30]),		
      .right(left[32]),		
      .left(left[31]),		
      .q(q[31])		
   );
   
   
   tri_fu_mul_bthmux u32(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[31]),		
      .right(left[33]),		
      .left(left[32]),		
      .q(q[32])		
   );
   
   
   tri_fu_mul_bthmux u33(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[32]),		
      .right(left[34]),		
      .left(left[33]),		
      .q(q[33])		
   );
   
   
   tri_fu_mul_bthmux u34(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[33]),		
      .right(left[35]),		
      .left(left[34]),		
      .q(q[34])		
   );
   
   
   tri_fu_mul_bthmux u35(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[34]),		
      .right(left[36]),		
      .left(left[35]),		
      .q(q[35])		
   );
   
   
   tri_fu_mul_bthmux u36(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[35]),		
      .right(left[37]),		
      .left(left[36]),		
      .q(q[36])		
   );
   
   
   tri_fu_mul_bthmux u37(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[36]),		
      .right(left[38]),		
      .left(left[37]),		
      .q(q[37])		
   );
   
   
   tri_fu_mul_bthmux u38(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[37]),		
      .right(left[39]),		
      .left(left[38]),		
      .q(q[38])		
   );
   
   
   tri_fu_mul_bthmux u39(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[38]),		
      .right(left[40]),		
      .left(left[39]),		
      .q(q[39])		
   );
   
   
   tri_fu_mul_bthmux u40(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[39]),		
      .right(left[41]),		
      .left(left[40]),		
      .q(q[40])		
   );
   
   
   tri_fu_mul_bthmux u41(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[40]),		
      .right(left[42]),		
      .left(left[41]),		
      .q(q[41])		
   );
   
   
   tri_fu_mul_bthmux u42(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[41]),		
      .right(left[43]),		
      .left(left[42]),		
      .q(q[42])		
   );
   
   
   tri_fu_mul_bthmux u43(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[42]),		
      .right(left[44]),		
      .left(left[43]),		
      .q(q[43])		
   );
   
   
   tri_fu_mul_bthmux u44(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[43]),		
      .right(left[45]),		
      .left(left[44]),		
      .q(q[44])		
   );
   
   
   tri_fu_mul_bthmux u45(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[44]),		
      .right(left[46]),		
      .left(left[45]),		
      .q(q[45])		
   );
   
   
   tri_fu_mul_bthmux u46(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[45]),		
      .right(left[47]),		
      .left(left[46]),		
      .q(q[46])		
   );
   
   
   tri_fu_mul_bthmux u47(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[46]),		
      .right(left[48]),		
      .left(left[47]),		
      .q(q[47])		
   );
   
   
   tri_fu_mul_bthmux u48(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[47]),		
      .right(left[49]),		
      .left(left[48]),		
      .q(q[48])		
   );
   
   
   tri_fu_mul_bthmux u49(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[48]),		
      .right(left[50]),		
      .left(left[49]),		
      .q(q[49])		
   );
   
   
   tri_fu_mul_bthmux u50(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[49]),		
      .right(left[51]),		
      .left(left[50]),		
      .q(q[50])		
   );
   
   
   tri_fu_mul_bthmux u51(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[50]),		
      .right(left[52]),		
      .left(left[51]),		
      .q(q[51])		
   );
   
   
   tri_fu_mul_bthmux u52(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[51]),		
      .right(left[53]),		
      .left(left[52]),		
      .q(q[52])		
   );
   
   
   tri_fu_mul_bthmux u53(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[52]),		
      .right(left[54]),		
      .left(left[53]),		
      .q(q[53])		
   );
   
   
   tri_fu_mul_bthmux u54(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[53]),		
      .right(s_neg),		
      .left(left[54]),		
      .q(q[54])		
   );
   
   

   assign hot_one = (s_neg & (s_x | s_x2));
   
endmodule
