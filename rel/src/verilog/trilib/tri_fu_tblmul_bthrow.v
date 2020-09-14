// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns


   `include "tri_a2o.vh"
   
module tri_fu_tblmul_bthrow(
   x,
   s_neg,
   s_x,
   s_x2,
   q
);
   
   input [0:15]  x;		
   input         s_neg;		
   input         s_x;		
   input         s_x2;		
   output [0:16] q;		
   
   
   
   
   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;
   
   wire [0:16]   left;		
   wire          unused;
   
   
   assign unused = left[0];
   
   
   tri_fu_mul_bthmux u00(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(tidn),		
      .left(left[0]),		
      .right(left[1]),		
      .q(q[0])		
   );
   
   
   tri_fu_mul_bthmux u01(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[0]),		
      .left(left[1]),		
      .right(left[2]),		
      .q(q[1])		
   );
   
   
   tri_fu_mul_bthmux u02(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[1]),		
      .left(left[2]),		
      .right(left[3]),		
      .q(q[2])		
   );
   
   
   tri_fu_mul_bthmux u03(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[2]),		
      .left(left[3]),		
      .right(left[4]),		
      .q(q[3])		
   );
   
   
   tri_fu_mul_bthmux u04(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[3]),		
      .left(left[4]),		
      .right(left[5]),		
      .q(q[4])		
   );
   
   
   tri_fu_mul_bthmux u05(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[4]),		
      .left(left[5]),		
      .right(left[6]),		
      .q(q[5])		
   );
   
   
   tri_fu_mul_bthmux u06(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[5]),		
      .left(left[6]),		
      .right(left[7]),		
      .q(q[6])		
   );
   
   
   tri_fu_mul_bthmux u07(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[6]),		
      .left(left[7]),		
      .right(left[8]),		
      .q(q[7])		
   );
   
   
   tri_fu_mul_bthmux u08(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[7]),		
      .left(left[8]),		
      .right(left[9]),		
      .q(q[8])		
   );
   
   
   tri_fu_mul_bthmux u09(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[8]),		
      .left(left[9]),		
      .right(left[10]),		
      .q(q[9])		
   );
   
   
   tri_fu_mul_bthmux u10(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[9]),		
      .left(left[10]),		
      .right(left[11]),		
      .q(q[10])		
   );
   
   
   tri_fu_mul_bthmux u11(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[10]),		
      .left(left[11]),		
      .right(left[12]),		
      .q(q[11])		
   );
   
   
   tri_fu_mul_bthmux u12(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[11]),		
      .left(left[12]),		
      .right(left[13]),		
      .q(q[12])		
   );
   
   
   tri_fu_mul_bthmux u13(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[12]),		
      .left(left[13]),		
      .right(left[14]),		
      .q(q[13])		
   );
   
   
   tri_fu_mul_bthmux u14(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[13]),		
      .left(left[14]),		
      .right(left[15]),		
      .q(q[14])		
   );
   
   
   tri_fu_mul_bthmux u15(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[14]),		
      .left(left[15]),		
      .right(left[16]),		
      .q(q[15])		
   );
   
   
   tri_fu_mul_bthmux u16(
      .sneg(s_neg),		
      .sx(s_x),		
      .sx2(s_x2),		
      .x(x[15]),		
      .left(left[16]),		
      .right(s_neg),		
      .q(q[16])		
   );
   
endmodule
