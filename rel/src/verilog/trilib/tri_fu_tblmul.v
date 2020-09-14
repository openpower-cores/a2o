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
   
module tri_fu_tblmul(
   vdd,
   gnd,
   x,
   y,
   z,
   tbl_sum,
   tbl_car
);
   inout         vdd;
   inout         gnd;
   input [1:15]  x;		
   input [7:22]  y;		
   input [0:20]  z;		
   
   
   output [0:36] tbl_sum;
   output [0:35] tbl_car;
   
   
   
   
   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;
   
   wire [1:7]    sub_adj_lsb;
   wire [1:7]    sub_adj_lsb_b;
   wire [1:7]    sub_adj_msb_b;
   wire          sub_adj_msb_7x_b;
   wire          sub_adj_msb_7x;
   wire          sub_adj_msb_7y;
   wire [0:7]    s_x;
   wire [0:7]    s_x2;
   
   wire [0:7]    s_neg;
   
   wire [6:24]   pp0_0;
   wire [6:26]   pp0_1;
   wire [8:28]   pp0_2;
   wire [10:30]  pp0_3;
   wire [12:32]  pp0_4;
   wire [14:34]  pp0_5;
   wire [16:36]  pp0_6;
   wire [17:36]  pp0_7;
   
   wire [0:26]   pp1_0_sum;
   wire [0:24]   pp1_0_car;
   wire [8:32]   pp1_1_sum;
   wire [9:30]   pp1_1_car;
   wire [14:36]  pp1_2_sum;
   wire [15:36]  pp1_2_car;
   wire          pp1_0_car_unused;
   
   wire [0:32]   pp2_0_sum;
   wire [0:26]   pp2_0_car;
   wire [9:36]   pp2_1_sum;
   wire [13:36]  pp2_1_car;
   wire          pp2_0_car_unused;
   
   wire [0:36]   pp3_0_sum;
   wire [8:25]   pp3_0_ko;
   wire [0:35]   pp3_0_car;
   wire          pp3_0_car_unused;
   wire [0:20]   z_b;
   (* analysis_not_referenced="TRUE" *) 
   wire          unused;
   
   
   
   
   assign unused = pp1_0_car_unused | pp2_0_car_unused | pp3_0_car_unused | pp0_0[23] | pp0_1[25] | pp0_2[27] | pp0_3[29] | pp0_4[31] | pp0_5[33] | pp0_6[35] | pp1_0_car[23] | pp1_0_sum[25] | pp1_1_car[28] | pp1_1_sum[31] | pp1_2_car[34] | pp2_0_car[24] | pp2_0_sum[31] | pp2_1_car[30] | pp2_1_car[34] | s_neg[0] | pp1_1_car[29] | pp1_2_car[35] | pp2_0_car[25] | pp2_1_car[35];
   
   
   
   tri_fu_tblmul_bthdcd bd0(
      .i0(tidn),		
      .i1(x[1]),		
      .i2(x[2]),		
      .s_neg(s_neg[0]),		
      .s_x(s_x[0]),		
      .s_x2(s_x2[0])		
   );
   
   
   tri_fu_tblmul_bthdcd bd1(
      .i0(x[2]),		
      .i1(x[3]),		
      .i2(x[4]),		
      .s_neg(s_neg[1]),		
      .s_x(s_x[1]),		
      .s_x2(s_x2[1])		
   );
   
   
   tri_fu_tblmul_bthdcd bd2(
      .i0(x[4]),		
      .i1(x[5]),		
      .i2(x[6]),		
      .s_neg(s_neg[2]),		
      .s_x(s_x[2]),		
      .s_x2(s_x2[2])		
   );
   
   
   tri_fu_tblmul_bthdcd bd3(
      .i0(x[6]),		
      .i1(x[7]),		
      .i2(x[8]),		
      .s_neg(s_neg[3]),		
      .s_x(s_x[3]),		
      .s_x2(s_x2[3])		
   );
   
   
   tri_fu_tblmul_bthdcd bd4(
      .i0(x[8]),		
      .i1(x[9]),		
      .i2(x[10]),		
      .s_neg(s_neg[4]),		
      .s_x(s_x[4]),		
      .s_x2(s_x2[4])		
   );
   
   
   tri_fu_tblmul_bthdcd bd5(
      .i0(x[10]),		
      .i1(x[11]),		
      .i2(x[12]),		
      .s_neg(s_neg[5]),		
      .s_x(s_x[5]),		
      .s_x2(s_x2[5])		
   );
   
   
   tri_fu_tblmul_bthdcd bd6(
      .i0(x[12]),		
      .i1(x[13]),		
      .i2(x[14]),		
      .s_neg(s_neg[6]),		
      .s_x(s_x[6]),		
      .s_x2(s_x2[6])		
   );
   
   
   tri_fu_tblmul_bthdcd bd7(
      .i0(x[14]),		
      .i1(x[15]),		
      .i2(tidn),		
      .s_neg(s_neg[7]),		
      .s_x(s_x[7]),		
      .s_x2(s_x2[7])		
   );
   
   
   
   assign sub_adj_lsb_b[1] = (~(s_neg[1] & (s_x[1] | s_x2[1])));
   assign sub_adj_lsb_b[2] = (~(s_neg[2] & (s_x[2] | s_x2[2])));
   assign sub_adj_lsb_b[3] = (~(s_neg[3] & (s_x[3] | s_x2[3])));
   assign sub_adj_lsb_b[4] = (~(s_neg[4] & (s_x[4] | s_x2[4])));
   assign sub_adj_lsb_b[5] = (~(s_neg[5] & (s_x[5] | s_x2[5])));
   assign sub_adj_lsb_b[6] = (~(s_neg[6] & (s_x[6] | s_x2[6])));
   assign sub_adj_lsb_b[7] = (~(s_neg[7] & (s_x[7] | s_x2[7])));
   
   assign sub_adj_lsb[1] = (~sub_adj_lsb_b[1]);
   assign sub_adj_lsb[2] = (~sub_adj_lsb_b[2]);
   assign sub_adj_lsb[3] = (~sub_adj_lsb_b[3]);
   assign sub_adj_lsb[4] = (~sub_adj_lsb_b[4]);
   assign sub_adj_lsb[5] = (~sub_adj_lsb_b[5]);
   assign sub_adj_lsb[6] = (~sub_adj_lsb_b[6]);
   assign sub_adj_lsb[7] = (~sub_adj_lsb_b[7]);
   
   assign sub_adj_msb_b[1] = (~(s_neg[1] & (s_x[1] | s_x2[1])));
   assign sub_adj_msb_b[2] = (~(s_neg[2] & (s_x[2] | s_x2[2])));
   assign sub_adj_msb_b[3] = (~(s_neg[3] & (s_x[3] | s_x2[3])));
   assign sub_adj_msb_b[4] = (~(s_neg[4] & (s_x[4] | s_x2[4])));
   assign sub_adj_msb_b[5] = (~(s_neg[5] & (s_x[5] | s_x2[5])));
   assign sub_adj_msb_b[6] = (~(s_neg[6] & (s_x[6] | s_x2[6])));
   assign sub_adj_msb_b[7] = (~(s_neg[7] & (s_x[7] | s_x2[7])));
   assign sub_adj_msb_7x_b = (~(s_neg[7] & (s_x[7] | s_x2[7])));
   
   assign sub_adj_msb_7x = (~sub_adj_msb_7x_b);
   assign sub_adj_msb_7y = (~sub_adj_msb_7x_b);
   
   
   tri_fu_tblmul_bthrow bm0(
      .s_neg(tidn),		
      .s_x(s_x[0]),		
      .s_x2(s_x2[0]),		
      .x(y[7:22]),		
      .q(pp0_0[6:22])		
   );
   assign pp0_0[23] = tidn;
   assign pp0_0[24] = sub_adj_lsb[1];
   
   assign pp0_1[6] = tiup;
   assign pp0_1[7] = sub_adj_msb_b[1];
   
   tri_fu_tblmul_bthrow bm1(
      .s_neg(s_neg[1]),		
      .s_x(s_x[1]),		
      .s_x2(s_x2[1]),		
      .x(y[7:22]),		
      .q(pp0_1[8:24])		
   );
   assign pp0_1[25] = tidn;
   assign pp0_1[26] = sub_adj_lsb[2];
   
   assign pp0_2[8] = tiup;
   assign pp0_2[9] = sub_adj_msb_b[2];
   
   tri_fu_tblmul_bthrow bm2(
      .s_neg(s_neg[2]),		
      .s_x(s_x[2]),		
      .s_x2(s_x2[2]),		
      .x(y[7:22]),		
      .q(pp0_2[10:26])		
   );
   assign pp0_2[27] = tidn;
   assign pp0_2[28] = sub_adj_lsb[3];
   
   assign pp0_3[10] = tiup;
   assign pp0_3[11] = sub_adj_msb_b[3];
   
   tri_fu_tblmul_bthrow bm3(
      .s_neg(s_neg[3]),		
      .s_x(s_x[3]),		
      .s_x2(s_x2[3]),		
      .x(y[7:22]),		
      .q(pp0_3[12:28])		
   );
   assign pp0_3[29] = tidn;
   assign pp0_3[30] = sub_adj_lsb[4];
   
   assign pp0_4[12] = tiup;
   assign pp0_4[13] = sub_adj_msb_b[4];
   
   tri_fu_tblmul_bthrow bm4(
      .s_neg(s_neg[4]),		
      .s_x(s_x[4]),		
      .s_x2(s_x2[4]),		
      .x(y[7:22]),		
      .q(pp0_4[14:30])		
   );
   assign pp0_4[31] = tidn;
   assign pp0_4[32] = sub_adj_lsb[5];
   
   assign pp0_5[14] = tiup;
   assign pp0_5[15] = sub_adj_msb_b[5];
   
   tri_fu_tblmul_bthrow bm5(
      .s_neg(s_neg[5]),		
      .s_x(s_x[5]),		
      .s_x2(s_x2[5]),		
      .x(y[7:22]),		
      .q(pp0_5[16:32])		
   );
   assign pp0_5[33] = tidn;
   assign pp0_5[34] = sub_adj_lsb[6];
   
   assign pp0_6[16] = tiup;
   assign pp0_6[17] = sub_adj_msb_b[6];
   
   tri_fu_tblmul_bthrow bm6(
      .s_neg(s_neg[6]),		
      .s_x(s_x[6]),		
      .s_x2(s_x2[6]),		
      .x(y[7:22]),		
      .q(pp0_6[18:34])		
   );
   assign pp0_6[35] = tidn;
   assign pp0_6[36] = sub_adj_lsb[7];
   
   assign pp0_7[17] = sub_adj_msb_b[7];
   assign pp0_7[18] = sub_adj_msb_7x;
   assign pp0_7[19] = sub_adj_msb_7y;
   
   tri_fu_tblmul_bthrow bm7(
      .s_neg(s_neg[7]),		
      .s_x(s_x[7]),		
      .s_x2(s_x2[7]),		
      .x(y[7:22]),		
      .q(pp0_7[20:36])		
   );
   
   
   
   
   
   assign z_b[0:20] = (~z[0:20]);
   
   
   assign pp1_0_sum[26] = pp0_1[26];
   assign pp1_0_sum[25] = tidn;
   assign pp1_0_sum[24] = pp0_0[24];
   assign pp1_0_car[24] = pp0_1[24];
   assign pp1_0_sum[23] = pp0_1[23];
   assign pp1_0_car[23] = tidn;
   assign pp1_0_sum[22] = pp0_0[22];
   assign pp1_0_car[22] = pp0_1[22];
   assign pp1_0_sum[21] = pp0_0[21];
   assign pp1_0_car[21] = pp0_1[21];
   assign pp1_0_car[20] = tidn;
   tri_csa32 pp1_0_csa_20(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[20]),		
      .b(pp0_0[20]),		
      .c(pp0_1[20]),		
      .sum(pp1_0_sum[20]),		
      .car(pp1_0_car[19])		
   );
   
   tri_csa32 pp1_0_csa_19(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[19]),		
      .b(pp0_0[19]),		
      .c(pp0_1[19]),		
      .sum(pp1_0_sum[19]),		
      .car(pp1_0_car[18])		
   );
   
   tri_csa32 pp1_0_csa_18(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[18]),		
      .b(pp0_0[18]),		
      .c(pp0_1[18]),		
      .sum(pp1_0_sum[18]),		
      .car(pp1_0_car[17])		
   );
   
   tri_csa32 pp1_0_csa_17(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[17]),		
      .b(pp0_0[17]),		
      .c(pp0_1[17]),		
      .sum(pp1_0_sum[17]),		
      .car(pp1_0_car[16])		
   );
   
   tri_csa32 pp1_0_csa_16(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[16]),		
      .b(pp0_0[16]),		
      .c(pp0_1[16]),		
      .sum(pp1_0_sum[16]),		
      .car(pp1_0_car[15])		
   );
   
   tri_csa32 pp1_0_csa_15(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[15]),		
      .b(pp0_0[15]),		
      .c(pp0_1[15]),		
      .sum(pp1_0_sum[15]),		
      .car(pp1_0_car[14])		
   );
   
   tri_csa32 pp1_0_csa_14(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[14]),		
      .b(pp0_0[14]),		
      .c(pp0_1[14]),		
      .sum(pp1_0_sum[14]),		
      .car(pp1_0_car[13])		
   );
   
   tri_csa32 pp1_0_csa_13(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[13]),		
      .b(pp0_0[13]),		
      .c(pp0_1[13]),		
      .sum(pp1_0_sum[13]),		
      .car(pp1_0_car[12])		
   );
   
   tri_csa32 pp1_0_csa_12(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[12]),		
      .b(pp0_0[12]),		
      .c(pp0_1[12]),		
      .sum(pp1_0_sum[12]),		
      .car(pp1_0_car[11])		
   );
   
   tri_csa32 pp1_0_csa_11(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[11]),		
      .b(pp0_0[11]),		
      .c(pp0_1[11]),		
      .sum(pp1_0_sum[11]),		
      .car(pp1_0_car[10])		
   );
   
   tri_csa32 pp1_0_csa_10(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[10]),		
      .b(pp0_0[10]),		
      .c(pp0_1[10]),		
      .sum(pp1_0_sum[10]),		
      .car(pp1_0_car[9])		
   );
   
   tri_csa32 pp1_0_csa_9(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[9]),		
      .b(pp0_0[9]),		
      .c(pp0_1[9]),		
      .sum(pp1_0_sum[9]),		
      .car(pp1_0_car[8])		
   );
   
   tri_csa32 pp1_0_csa_8(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[8]),		
      .b(pp0_0[8]),		
      .c(pp0_1[8]),		
      .sum(pp1_0_sum[8]),		
      .car(pp1_0_car[7])		
   );
   
   tri_csa32 pp1_0_csa_7(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[7]),		
      .b(pp0_0[7]),		
      .c(pp0_1[7]),		
      .sum(pp1_0_sum[7]),		
      .car(pp1_0_car[6])		
   );
   
   tri_csa32 pp1_0_csa_6(
      .vd(vdd),
      .gd(gnd),
      .a(z_b[6]),		
      .b(pp0_0[6]),		
      .c(pp0_1[6]),		
      .sum(pp1_0_sum[6]),		
      .car(pp1_0_car[5])		
   );
   
   tri_fu_csa22_h2 pp1_0_csa_5(
      .a(z_b[5]),		
      .b(tiup),		
      .sum(pp1_0_sum[5]),		
      .car(pp1_0_car[4])		
   );
   
   tri_fu_csa22_h2 pp1_0_csa_4(
      .a(z_b[4]),		
      .b(tiup),		
      .sum(pp1_0_sum[4]),		
      .car(pp1_0_car[3])		
   );
   
   tri_fu_csa22_h2 pp1_0_csa_3(
      .a(z_b[3]),		
      .b(tiup),		
      .sum(pp1_0_sum[3]),		
      .car(pp1_0_car[2])		
   );
   
   tri_fu_csa22_h2 pp1_0_csa_2(
      .a(z_b[2]),		
      .b(tiup),		
      .sum(pp1_0_sum[2]),		
      .car(pp1_0_car[1])		
   );
   
   tri_fu_csa22_h2 pp1_0_csa_1(
      .a(z_b[1]),		
      .b(tiup),		
      .sum(pp1_0_sum[1]),		
      .car(pp1_0_car[0])		
   );
   
   tri_fu_csa22_h2 pp1_0_csa_0(
      .a(z_b[0]),		
      .b(tiup),		
      .sum(pp1_0_sum[0]),		
      .car(pp1_0_car_unused)		
   );
   
   
   assign pp1_1_sum[32] = pp0_4[32];
   assign pp1_1_sum[31] = tidn;
   assign pp1_1_sum[30] = pp0_3[30];
   assign pp1_1_car[30] = pp0_4[30];
   assign pp1_1_sum[29] = pp0_4[29];
   assign pp1_1_car[29] = tidn;
   assign pp1_1_car[28] = tidn;
   
   tri_csa32 pp1_1_csa_28(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[28]),		
      .b(pp0_3[28]),		
      .c(pp0_4[28]),		
      .sum(pp1_1_sum[28]),		
      .car(pp1_1_car[27])		
   );
   
   tri_fu_csa22_h2 pp1_1_csa_27(
      .a(pp0_3[27]),		
      .b(pp0_4[27]),		
      .sum(pp1_1_sum[27]),		
      .car(pp1_1_car[26])		
   );
   
   tri_csa32 pp1_1_csa_26(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[26]),		
      .b(pp0_3[26]),		
      .c(pp0_4[26]),		
      .sum(pp1_1_sum[26]),		
      .car(pp1_1_car[25])		
   );
   
   tri_csa32 pp1_1_csa_25(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[25]),		
      .b(pp0_3[25]),		
      .c(pp0_4[25]),		
      .sum(pp1_1_sum[25]),		
      .car(pp1_1_car[24])		
   );
   
   tri_csa32 pp1_1_csa_24(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[24]),		
      .b(pp0_3[24]),		
      .c(pp0_4[24]),		
      .sum(pp1_1_sum[24]),		
      .car(pp1_1_car[23])		
   );
   
   tri_csa32 pp1_1_csa_23(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[23]),		
      .b(pp0_3[23]),		
      .c(pp0_4[23]),		
      .sum(pp1_1_sum[23]),		
      .car(pp1_1_car[22])		
   );
   
   tri_csa32 pp1_1_csa_22(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[22]),		
      .b(pp0_3[22]),		
      .c(pp0_4[22]),		
      .sum(pp1_1_sum[22]),		
      .car(pp1_1_car[21])		
   );
   
   tri_csa32 pp1_1_csa_21(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[21]),		
      .b(pp0_3[21]),		
      .c(pp0_4[21]),		
      .sum(pp1_1_sum[21]),		
      .car(pp1_1_car[20])		
   );
   
   tri_csa32 pp1_1_csa_20(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[20]),		
      .b(pp0_3[20]),		
      .c(pp0_4[20]),		
      .sum(pp1_1_sum[20]),		
      .car(pp1_1_car[19])		
   );
   
   tri_csa32 pp1_1_csa_19(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[19]),		
      .b(pp0_3[19]),		
      .c(pp0_4[19]),		
      .sum(pp1_1_sum[19]),		
      .car(pp1_1_car[18])		
   );
   
   tri_csa32 pp1_1_csa_18(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[18]),		
      .b(pp0_3[18]),		
      .c(pp0_4[18]),		
      .sum(pp1_1_sum[18]),		
      .car(pp1_1_car[17])		
   );
   
   tri_csa32 pp1_1_csa_17(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[17]),		
      .b(pp0_3[17]),		
      .c(pp0_4[17]),		
      .sum(pp1_1_sum[17]),		
      .car(pp1_1_car[16])		
   );
   
   tri_csa32 pp1_1_csa_16(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[16]),		
      .b(pp0_3[16]),		
      .c(pp0_4[16]),		
      .sum(pp1_1_sum[16]),		
      .car(pp1_1_car[15])		
   );
   
   tri_csa32 pp1_1_csa_15(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[15]),		
      .b(pp0_3[15]),		
      .c(pp0_4[15]),		
      .sum(pp1_1_sum[15]),		
      .car(pp1_1_car[14])		
   );
   
   tri_csa32 pp1_1_csa_14(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[14]),		
      .b(pp0_3[14]),		
      .c(pp0_4[14]),		
      .sum(pp1_1_sum[14]),		
      .car(pp1_1_car[13])		
   );
   
   tri_csa32 pp1_1_csa_13(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[13]),		
      .b(pp0_3[13]),		
      .c(pp0_4[13]),		
      .sum(pp1_1_sum[13]),		
      .car(pp1_1_car[12])		
   );
   
   tri_csa32 pp1_1_csa_12(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_2[12]),		
      .b(pp0_3[12]),		
      .c(pp0_4[12]),		
      .sum(pp1_1_sum[12]),		
      .car(pp1_1_car[11])		
   );
   
   tri_fu_csa22_h2 pp1_1_csa_11(
      .a(pp0_2[11]),		
      .b(pp0_3[11]),		
      .sum(pp1_1_sum[11]),		
      .car(pp1_1_car[10])		
   );
   
   tri_fu_csa22_h2 pp1_1_csa_10(
      .a(pp0_2[10]),		
      .b(pp0_3[10]),		
      .sum(pp1_1_sum[10]),		
      .car(pp1_1_car[9])		
   );
   assign pp1_1_sum[9] = pp0_2[9];
   assign pp1_1_sum[8] = pp0_2[8];
   
   
   assign pp1_2_sum[36] = pp0_6[36];
   assign pp1_2_car[36] = pp0_7[36];
   assign pp1_2_sum[35] = pp0_7[35];
   assign pp1_2_car[35] = tidn;
   assign pp1_2_car[34] = tidn;
   
   tri_csa32 pp1_2_csa_34(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[34]),		
      .b(pp0_6[34]),		
      .c(pp0_7[34]),		
      .sum(pp1_2_sum[34]),		
      .car(pp1_2_car[33])		
   );
   
   tri_fu_csa22_h2 pp1_2_csa_33(
      .a(pp0_6[33]),		
      .b(pp0_7[33]),		
      .sum(pp1_2_sum[33]),		
      .car(pp1_2_car[32])		
   );
   
   tri_csa32 pp1_2_csa_32(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[32]),		
      .b(pp0_6[32]),		
      .c(pp0_7[32]),		
      .sum(pp1_2_sum[32]),		
      .car(pp1_2_car[31])		
   );
   
   tri_csa32 pp1_2_csa_31(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[31]),		
      .b(pp0_6[31]),		
      .c(pp0_7[31]),		
      .sum(pp1_2_sum[31]),		
      .car(pp1_2_car[30])		
   );
   
   tri_csa32 pp1_2_csa_30(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[30]),		
      .b(pp0_6[30]),		
      .c(pp0_7[30]),		
      .sum(pp1_2_sum[30]),		
      .car(pp1_2_car[29])		
   );
   
   tri_csa32 pp1_2_csa_29(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[29]),		
      .b(pp0_6[29]),		
      .c(pp0_7[29]),		
      .sum(pp1_2_sum[29]),		
      .car(pp1_2_car[28])		
   );
   
   tri_csa32 pp1_2_csa_28(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[28]),		
      .b(pp0_6[28]),		
      .c(pp0_7[28]),		
      .sum(pp1_2_sum[28]),		
      .car(pp1_2_car[27])		
   );
   
   tri_csa32 pp1_2_csa_27(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[27]),		
      .b(pp0_6[27]),		
      .c(pp0_7[27]),		
      .sum(pp1_2_sum[27]),		
      .car(pp1_2_car[26])		
   );
   
   tri_csa32 pp1_2_csa_26(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[26]),		
      .b(pp0_6[26]),		
      .c(pp0_7[26]),		
      .sum(pp1_2_sum[26]),		
      .car(pp1_2_car[25])		
   );
   
   tri_csa32 pp1_2_csa_25(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[25]),		
      .b(pp0_6[25]),		
      .c(pp0_7[25]),		
      .sum(pp1_2_sum[25]),		
      .car(pp1_2_car[24])		
   );
   
   tri_csa32 pp1_2_csa_24(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[24]),		
      .b(pp0_6[24]),		
      .c(pp0_7[24]),		
      .sum(pp1_2_sum[24]),		
      .car(pp1_2_car[23])		
   );
   
   tri_csa32 pp1_2_csa_23(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[23]),		
      .b(pp0_6[23]),		
      .c(pp0_7[23]),		
      .sum(pp1_2_sum[23]),		
      .car(pp1_2_car[22])		
   );
   
   tri_csa32 pp1_2_csa_22(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[22]),		
      .b(pp0_6[22]),		
      .c(pp0_7[22]),		
      .sum(pp1_2_sum[22]),		
      .car(pp1_2_car[21])		
   );
   
   tri_csa32 pp1_2_csa_21(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[21]),		
      .b(pp0_6[21]),		
      .c(pp0_7[21]),		
      .sum(pp1_2_sum[21]),		
      .car(pp1_2_car[20])		
   );
   
   tri_csa32 pp1_2_csa_20(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[20]),		
      .b(pp0_6[20]),		
      .c(pp0_7[20]),		
      .sum(pp1_2_sum[20]),		
      .car(pp1_2_car[19])		
   );
   
   tri_csa32 pp1_2_csa_19(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[19]),		
      .b(pp0_6[19]),		
      .c(pp0_7[19]),		
      .sum(pp1_2_sum[19]),		
      .car(pp1_2_car[18])		
   );
   
   tri_csa32 pp1_2_csa_18(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[18]),		
      .b(pp0_6[18]),		
      .c(pp0_7[18]),		
      .sum(pp1_2_sum[18]),		
      .car(pp1_2_car[17])		
   );
   
   tri_csa32 pp1_2_csa_17(
      .vd(vdd),
      .gd(gnd),
      .a(pp0_5[17]),		
      .b(pp0_6[17]),		
      .c(pp0_7[17]),		
      .sum(pp1_2_sum[17]),		
      .car(pp1_2_car[16])		
   );
   
   tri_fu_csa22_h2 pp1_2_csa_16(
      .a(pp0_5[16]),		
      .b(pp0_6[16]),		
      .sum(pp1_2_sum[16]),		
      .car(pp1_2_car[15])		
   );
   assign pp1_2_sum[15] = pp0_5[15];
   assign pp1_2_sum[14] = pp0_5[14];
   
   
   
   
   
   assign pp2_0_sum[32] = pp1_1_sum[32];
   assign pp2_0_sum[31] = tidn;
   assign pp2_0_sum[30] = pp1_1_sum[30];
   assign pp2_0_sum[29] = pp1_1_sum[29];
   assign pp2_0_sum[28] = pp1_1_sum[28];
   assign pp2_0_sum[27] = pp1_1_sum[27];
   assign pp2_0_sum[26] = pp1_0_sum[26];
   assign pp2_0_car[26] = pp1_1_sum[26];
   assign pp2_0_sum[25] = pp1_1_sum[25];
   assign pp2_0_car[25] = tidn;
   assign pp2_0_car[24] = tidn;
   
   tri_csa32 pp2_0_csa_24(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[24]),		
      .b(pp1_0_car[24]),		
      .c(pp1_1_sum[24]),		
      .sum(pp2_0_sum[24]),		
      .car(pp2_0_car[23])		
   );
   
   tri_fu_csa22_h2 pp2_0_csa_23(
      .a(pp1_0_sum[23]),		
      .b(pp1_1_sum[23]),		
      .sum(pp2_0_sum[23]),		
      .car(pp2_0_car[22])		
   );
   
   tri_csa32 pp2_0_csa_22(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[22]),		
      .b(pp1_0_car[22]),		
      .c(pp1_1_sum[22]),		
      .sum(pp2_0_sum[22]),		
      .car(pp2_0_car[21])		
   );
   
   tri_csa32 pp2_0_csa_21(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[21]),		
      .b(pp1_0_car[21]),		
      .c(pp1_1_sum[21]),		
      .sum(pp2_0_sum[21]),		
      .car(pp2_0_car[20])		
   );
   
   tri_csa32 pp2_0_csa_20(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[20]),		
      .b(pp1_0_car[20]),		
      .c(pp1_1_sum[20]),		
      .sum(pp2_0_sum[20]),		
      .car(pp2_0_car[19])		
   );
   
   tri_csa32 pp2_0_csa_19(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[19]),		
      .b(pp1_0_car[19]),		
      .c(pp1_1_sum[19]),		
      .sum(pp2_0_sum[19]),		
      .car(pp2_0_car[18])		
   );
   
   tri_csa32 pp2_0_csa_18(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[18]),		
      .b(pp1_0_car[18]),		
      .c(pp1_1_sum[18]),		
      .sum(pp2_0_sum[18]),		
      .car(pp2_0_car[17])		
   );
   
   tri_csa32 pp2_0_csa_17(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[17]),		
      .b(pp1_0_car[17]),		
      .c(pp1_1_sum[17]),		
      .sum(pp2_0_sum[17]),		
      .car(pp2_0_car[16])		
   );
   
   tri_csa32 pp2_0_csa_16(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[16]),		
      .b(pp1_0_car[16]),		
      .c(pp1_1_sum[16]),		
      .sum(pp2_0_sum[16]),		
      .car(pp2_0_car[15])		
   );
   
   tri_csa32 pp2_0_csa_15(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[15]),		
      .b(pp1_0_car[15]),		
      .c(pp1_1_sum[15]),		
      .sum(pp2_0_sum[15]),		
      .car(pp2_0_car[14])		
   );
   
   tri_csa32 pp2_0_csa_14(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[14]),		
      .b(pp1_0_car[14]),		
      .c(pp1_1_sum[14]),		
      .sum(pp2_0_sum[14]),		
      .car(pp2_0_car[13])		
   );
   
   tri_csa32 pp2_0_csa_13(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[13]),		
      .b(pp1_0_car[13]),		
      .c(pp1_1_sum[13]),		
      .sum(pp2_0_sum[13]),		
      .car(pp2_0_car[12])		
   );
   
   tri_csa32 pp2_0_csa_12(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[12]),		
      .b(pp1_0_car[12]),		
      .c(pp1_1_sum[12]),		
      .sum(pp2_0_sum[12]),		
      .car(pp2_0_car[11])		
   );
   
   tri_csa32 pp2_0_csa_11(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[11]),		
      .b(pp1_0_car[11]),		
      .c(pp1_1_sum[11]),		
      .sum(pp2_0_sum[11]),		
      .car(pp2_0_car[10])		
   );
   
   tri_csa32 pp2_0_csa_10(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[10]),		
      .b(pp1_0_car[10]),		
      .c(pp1_1_sum[10]),		
      .sum(pp2_0_sum[10]),		
      .car(pp2_0_car[9])		
   );
   
   tri_csa32 pp2_0_csa_9(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[9]),		
      .b(pp1_0_car[9]),		
      .c(pp1_1_sum[9]),		
      .sum(pp2_0_sum[9]),		
      .car(pp2_0_car[8])		
   );
   
   tri_csa32 pp2_0_csa_8(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_0_sum[8]),		
      .b(pp1_0_car[8]),		
      .c(pp1_1_sum[8]),		
      .sum(pp2_0_sum[8]),		
      .car(pp2_0_car[7])		
   );
   
   tri_fu_csa22_h2 pp2_0_csa_7(
      .a(pp1_0_sum[7]),		
      .b(pp1_0_car[7]),		
      .sum(pp2_0_sum[7]),		
      .car(pp2_0_car[6])		
   );
   
   tri_fu_csa22_h2 pp2_0_csa_6(
      .a(pp1_0_sum[6]),		
      .b(pp1_0_car[6]),		
      .sum(pp2_0_sum[6]),		
      .car(pp2_0_car[5])		
   );
   
   tri_fu_csa22_h2 pp2_0_csa_5(
      .a(pp1_0_sum[5]),		
      .b(pp1_0_car[5]),		
      .sum(pp2_0_sum[5]),		
      .car(pp2_0_car[4])		
   );
   
   tri_fu_csa22_h2 pp2_0_csa_4(
      .a(pp1_0_sum[4]),		
      .b(pp1_0_car[4]),		
      .sum(pp2_0_sum[4]),		
      .car(pp2_0_car[3])		
   );
   
   tri_fu_csa22_h2 pp2_0_csa_3(
      .a(pp1_0_sum[3]),		
      .b(pp1_0_car[3]),		
      .sum(pp2_0_sum[3]),		
      .car(pp2_0_car[2])		
   );
   
   tri_fu_csa22_h2 pp2_0_csa_2(
      .a(pp1_0_sum[2]),		
      .b(pp1_0_car[2]),		
      .sum(pp2_0_sum[2]),		
      .car(pp2_0_car[1])		
   );
   
   tri_fu_csa22_h2 pp2_0_csa_1(
      .a(pp1_0_sum[1]),		
      .b(pp1_0_car[1]),		
      .sum(pp2_0_sum[1]),		
      .car(pp2_0_car[0])		
   );
   
   tri_fu_csa22_h2 pp2_0_csa_0(
      .a(pp1_0_sum[0]),		
      .b(pp1_0_car[0]),		
      .sum(pp2_0_sum[0]),		
      .car(pp2_0_car_unused)		
   );
   
   
   
   assign pp2_1_sum[36] = pp1_2_sum[36];
   assign pp2_1_car[36] = pp1_2_car[36];
   assign pp2_1_sum[35] = pp1_2_sum[35];
   assign pp2_1_car[35] = tidn;
   assign pp2_1_sum[34] = pp1_2_sum[34];
   assign pp2_1_car[34] = tidn;
   assign pp2_1_sum[33] = pp1_2_sum[33];
   assign pp2_1_car[33] = pp1_2_car[33];
   assign pp2_1_sum[32] = pp1_2_sum[32];
   assign pp2_1_car[32] = pp1_2_car[32];
   assign pp2_1_sum[31] = pp1_2_sum[31];
   assign pp2_1_car[31] = pp1_2_car[31];
   assign pp2_1_car[30] = tidn;
   
   tri_csa32 pp2_1_csa_30(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_1_car[30]),		
      .b(pp1_2_sum[30]),		
      .c(pp1_2_car[30]),		
      .sum(pp2_1_sum[30]),		
      .car(pp2_1_car[29])		
   );
   
   tri_fu_csa22_h2 pp2_1_csa_29(
      .a(pp1_2_sum[29]),		
      .b(pp1_2_car[29]),		
      .sum(pp2_1_sum[29]),		
      .car(pp2_1_car[28])		
   );
   
   tri_fu_csa22_h2 pp2_1_csa_28(
      .a(pp1_2_sum[28]),		
      .b(pp1_2_car[28]),		
      .sum(pp2_1_sum[28]),		
      .car(pp2_1_car[27])		
   );
   
   tri_csa32 pp2_1_csa_27(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_1_car[27]),		
      .b(pp1_2_sum[27]),		
      .c(pp1_2_car[27]),		
      .sum(pp2_1_sum[27]),		
      .car(pp2_1_car[26])		
   );
   
   tri_csa32 pp2_1_csa_26(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_1_car[26]),		
      .b(pp1_2_sum[26]),		
      .c(pp1_2_car[26]),		
      .sum(pp2_1_sum[26]),		
      .car(pp2_1_car[25])		
   );
   
   tri_csa32 pp2_1_csa_25(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_1_car[25]),		
      .b(pp1_2_sum[25]),		
      .c(pp1_2_car[25]),		
      .sum(pp2_1_sum[25]),		
      .car(pp2_1_car[24])		
   );
   
   tri_csa32 pp2_1_csa_24(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_1_car[24]),		
      .b(pp1_2_sum[24]),		
      .c(pp1_2_car[24]),		
      .sum(pp2_1_sum[24]),		
      .car(pp2_1_car[23])		
   );
   
   tri_csa32 pp2_1_csa_23(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_1_car[23]),		
      .b(pp1_2_sum[23]),		
      .c(pp1_2_car[23]),		
      .sum(pp2_1_sum[23]),		
      .car(pp2_1_car[22])		
   );
   
   tri_csa32 pp2_1_csa_22(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_1_car[22]),		
      .b(pp1_2_sum[22]),		
      .c(pp1_2_car[22]),		
      .sum(pp2_1_sum[22]),		
      .car(pp2_1_car[21])		
   );
   
   tri_csa32 pp2_1_csa_21(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_1_car[21]),		
      .b(pp1_2_sum[21]),		
      .c(pp1_2_car[21]),		
      .sum(pp2_1_sum[21]),		
      .car(pp2_1_car[20])		
   );
   
   tri_csa32 pp2_1_csa_20(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_1_car[20]),		
      .b(pp1_2_sum[20]),		
      .c(pp1_2_car[20]),		
      .sum(pp2_1_sum[20]),		
      .car(pp2_1_car[19])		
   );
   
   tri_csa32 pp2_1_csa_19(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_1_car[19]),		
      .b(pp1_2_sum[19]),		
      .c(pp1_2_car[19]),		
      .sum(pp2_1_sum[19]),		
      .car(pp2_1_car[18])		
   );
   
   tri_csa32 pp2_1_csa_18(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_1_car[18]),		
      .b(pp1_2_sum[18]),		
      .c(pp1_2_car[18]),		
      .sum(pp2_1_sum[18]),		
      .car(pp2_1_car[17])		
   );
   
   tri_csa32 pp2_1_csa_17(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_1_car[17]),		
      .b(pp1_2_sum[17]),		
      .c(pp1_2_car[17]),		
      .sum(pp2_1_sum[17]),		
      .car(pp2_1_car[16])		
   );
   
   tri_csa32 pp2_1_csa_16(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_1_car[16]),		
      .b(pp1_2_sum[16]),		
      .c(pp1_2_car[16]),		
      .sum(pp2_1_sum[16]),		
      .car(pp2_1_car[15])		
   );
   
   tri_csa32 pp2_1_csa_15(
      .vd(vdd),
      .gd(gnd),
      .a(pp1_1_car[15]),		
      .b(pp1_2_sum[15]),		
      .c(pp1_2_car[15]),		
      .sum(pp2_1_sum[15]),		
      .car(pp2_1_car[14])		
   );
   
   tri_fu_csa22_h2 pp2_1_csa_14(
      .a(pp1_1_car[14]),		
      .b(pp1_2_sum[14]),		
      .sum(pp2_1_sum[14]),		
      .car(pp2_1_car[13])		
   );
   assign pp2_1_sum[13] = pp1_1_car[13];
   assign pp2_1_sum[12] = pp1_1_car[12];
   assign pp2_1_sum[11] = pp1_1_car[11];
   assign pp2_1_sum[10] = pp1_1_car[10];
   assign pp2_1_sum[9] = pp1_1_car[9];
   
   
   
   
   
   tri_fu_csa22_h2 pp3_0_csa_36(
      .a(pp2_1_sum[36]),		
      .b(pp2_1_car[36]),		
      .sum(pp3_0_sum[36]),		
      .car(pp3_0_car[35])		
   );
   assign pp3_0_sum[35] = pp2_1_sum[35];
   assign pp3_0_sum[34] = pp2_1_sum[34];
   assign pp3_0_car[34] = tidn;
   assign pp3_0_sum[33] = pp2_1_sum[33];
   assign pp3_0_car[33] = pp2_1_car[33];
   assign pp3_0_car[32] = tidn;
   
   tri_csa32 pp3_0_csa_32(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[32]),		
      .b(pp2_1_sum[32]),		
      .c(pp2_1_car[32]),		
      .sum(pp3_0_sum[32]),		
      .car(pp3_0_car[31])		
   );
   
   tri_fu_csa22_h2 pp3_0_csa_31(
      .a(pp2_1_sum[31]),		
      .b(pp2_1_car[31]),		
      .sum(pp3_0_sum[31]),		
      .car(pp3_0_car[30])		
   );
   
   tri_fu_csa22_h2 pp3_0_csa_30(
      .a(pp2_0_sum[30]),		
      .b(pp2_1_sum[30]),		
      .sum(pp3_0_sum[30]),		
      .car(pp3_0_car[29])		
   );
   
   tri_csa32 pp3_0_csa_29(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[29]),		
      .b(pp2_1_sum[29]),		
      .c(pp2_1_car[29]),		
      .sum(pp3_0_sum[29]),		
      .car(pp3_0_car[28])		
   );
   
   tri_csa32 pp3_0_csa_28(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[28]),		
      .b(pp2_1_sum[28]),		
      .c(pp2_1_car[28]),		
      .sum(pp3_0_sum[28]),		
      .car(pp3_0_car[27])		
   );
   
   tri_csa32 pp3_0_csa_27(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[27]),		
      .b(pp2_1_sum[27]),		
      .c(pp2_1_car[27]),		
      .sum(pp3_0_sum[27]),		
      .car(pp3_0_car[26])		
   );
   tri_csa42 pp3_0_csa_26(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[26]),		
      .b(pp2_0_car[26]),		
      .c(pp2_1_sum[26]),		
      .d(pp2_1_car[26]),		
      .ki(tidn),		
      .ko(pp3_0_ko[25]),		
      .sum(pp3_0_sum[26]),		
      .car(pp3_0_car[25])		
   );
   
   tri_csa42 pp3_0_csa_25(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[25]),		
      .b(tidn),		
      .c(pp2_1_sum[25]),		
      .d(pp2_1_car[25]),		
      .ki(pp3_0_ko[25]),		
      .ko(pp3_0_ko[24]),		
      .sum(pp3_0_sum[25]),		
      .car(pp3_0_car[24])		
   );
   
   tri_csa42 pp3_0_csa_24(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[24]),		
      .b(tidn),		
      .c(pp2_1_sum[24]),		
      .d(pp2_1_car[24]),		
      .ki(pp3_0_ko[24]),		
      .ko(pp3_0_ko[23]),		
      .sum(pp3_0_sum[24]),		
      .car(pp3_0_car[23])		
   );
   
   tri_csa42 pp3_0_csa_23(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[23]),		
      .b(pp2_0_car[23]),		
      .c(pp2_1_sum[23]),		
      .d(pp2_1_car[23]),		
      .ki(pp3_0_ko[23]),		
      .ko(pp3_0_ko[22]),		
      .sum(pp3_0_sum[23]),		
      .car(pp3_0_car[22])		
   );
   
   tri_csa42 pp3_0_csa_22(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[22]),		
      .b(pp2_0_car[22]),		
      .c(pp2_1_sum[22]),		
      .d(pp2_1_car[22]),		
      .ki(pp3_0_ko[22]),		
      .ko(pp3_0_ko[21]),		
      .sum(pp3_0_sum[22]),		
      .car(pp3_0_car[21])		
   );
   
   tri_csa42 pp3_0_csa_21(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[21]),		
      .b(pp2_0_car[21]),		
      .c(pp2_1_sum[21]),		
      .d(pp2_1_car[21]),		
      .ki(pp3_0_ko[21]),		
      .ko(pp3_0_ko[20]),		
      .sum(pp3_0_sum[21]),		
      .car(pp3_0_car[20])		
   );
   
   tri_csa42 pp3_0_csa_20(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[20]),		
      .b(pp2_0_car[20]),		
      .c(pp2_1_sum[20]),		
      .d(pp2_1_car[20]),		
      .ki(pp3_0_ko[20]),		
      .ko(pp3_0_ko[19]),		
      .sum(pp3_0_sum[20]),		
      .car(pp3_0_car[19])		
   );
   
   tri_csa42 pp3_0_csa_19(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[19]),		
      .b(pp2_0_car[19]),		
      .c(pp2_1_sum[19]),		
      .d(pp2_1_car[19]),		
      .ki(pp3_0_ko[19]),		
      .ko(pp3_0_ko[18]),		
      .sum(pp3_0_sum[19]),		
      .car(pp3_0_car[18])		
   );
   
   tri_csa42 pp3_0_csa_18(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[18]),		
      .b(pp2_0_car[18]),		
      .c(pp2_1_sum[18]),		
      .d(pp2_1_car[18]),		
      .ki(pp3_0_ko[18]),		
      .ko(pp3_0_ko[17]),		
      .sum(pp3_0_sum[18]),		
      .car(pp3_0_car[17])		
   );
   
   tri_csa42 pp3_0_csa_17(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[17]),		
      .b(pp2_0_car[17]),		
      .c(pp2_1_sum[17]),		
      .d(pp2_1_car[17]),		
      .ki(pp3_0_ko[17]),		
      .ko(pp3_0_ko[16]),		
      .sum(pp3_0_sum[17]),		
      .car(pp3_0_car[16])		
   );
   
   tri_csa42 pp3_0_csa_16(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[16]),		
      .b(pp2_0_car[16]),		
      .c(pp2_1_sum[16]),		
      .d(pp2_1_car[16]),		
      .ki(pp3_0_ko[16]),		
      .ko(pp3_0_ko[15]),		
      .sum(pp3_0_sum[16]),		
      .car(pp3_0_car[15])		
   );
   
   tri_csa42 pp3_0_csa_15(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[15]),		
      .b(pp2_0_car[15]),		
      .c(pp2_1_sum[15]),		
      .d(pp2_1_car[15]),		
      .ki(pp3_0_ko[15]),		
      .ko(pp3_0_ko[14]),		
      .sum(pp3_0_sum[15]),		
      .car(pp3_0_car[14])		
   );
   
   tri_csa42 pp3_0_csa_14(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[14]),		
      .b(pp2_0_car[14]),		
      .c(pp2_1_sum[14]),		
      .d(pp2_1_car[14]),		
      .ki(pp3_0_ko[14]),		
      .ko(pp3_0_ko[13]),		
      .sum(pp3_0_sum[14]),		
      .car(pp3_0_car[13])		
   );
   
   tri_csa42 pp3_0_csa_13(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[13]),		
      .b(pp2_0_car[13]),		
      .c(pp2_1_sum[13]),		
      .d(pp2_1_car[13]),		
      .ki(pp3_0_ko[13]),		
      .ko(pp3_0_ko[12]),		
      .sum(pp3_0_sum[13]),		
      .car(pp3_0_car[12])		
   );
   
   tri_csa42 pp3_0_csa_12(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[12]),		
      .b(pp2_0_car[12]),		
      .c(pp2_1_sum[12]),		
      .d(tidn),		
      .ki(pp3_0_ko[12]),		
      .ko(pp3_0_ko[11]),		
      .sum(pp3_0_sum[12]),		
      .car(pp3_0_car[11])		
   );
   
   tri_csa42 pp3_0_csa_11(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[11]),		
      .b(pp2_0_car[11]),		
      .c(pp2_1_sum[11]),		
      .d(tidn),		
      .ki(pp3_0_ko[11]),		
      .ko(pp3_0_ko[10]),		
      .sum(pp3_0_sum[11]),		
      .car(pp3_0_car[10])		
   );
   
   tri_csa42 pp3_0_csa_10(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[10]),		
      .b(pp2_0_car[10]),		
      .c(pp2_1_sum[10]),		
      .d(tidn),		
      .ki(pp3_0_ko[10]),		
      .ko(pp3_0_ko[9]),		
      .sum(pp3_0_sum[10]),		
      .car(pp3_0_car[9])		
   );
   
   tri_csa42 pp3_0_csa_9(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[9]),		
      .b(pp2_0_car[9]),		
      .c(pp2_1_sum[9]),		
      .d(tidn),		
      .ki(pp3_0_ko[9]),		
      .ko(pp3_0_ko[8]),		
      .sum(pp3_0_sum[9]),		
      .car(pp3_0_car[8])		
   );
   
   tri_csa32 pp3_0_csa_8(
      .vd(vdd),
      .gd(gnd),
      .a(pp2_0_sum[8]),		
      .b(pp2_0_car[8]),		
      .c(pp3_0_ko[8]),		
      .sum(pp3_0_sum[8]),		
      .car(pp3_0_car[7])		
   );
   
   tri_fu_csa22_h2 pp3_0_csa_7(
      .a(pp2_0_sum[7]),		
      .b(pp2_0_car[7]),		
      .sum(pp3_0_sum[7]),		
      .car(pp3_0_car[6])		
   );
   
   tri_fu_csa22_h2 pp3_0_csa_6(
      .a(pp2_0_sum[6]),		
      .b(pp2_0_car[6]),		
      .sum(pp3_0_sum[6]),		
      .car(pp3_0_car[5])		
   );
   
   tri_fu_csa22_h2 pp3_0_csa_5(
      .a(pp2_0_sum[5]),		
      .b(pp2_0_car[5]),		
      .sum(pp3_0_sum[5]),		
      .car(pp3_0_car[4])		
   );
   
   tri_fu_csa22_h2 pp3_0_csa_4(
      .a(pp2_0_sum[4]),		
      .b(pp2_0_car[4]),		
      .sum(pp3_0_sum[4]),		
      .car(pp3_0_car[3])		
   );
   
   tri_fu_csa22_h2 pp3_0_csa_3(
      .a(pp2_0_sum[3]),		
      .b(pp2_0_car[3]),		
      .sum(pp3_0_sum[3]),		
      .car(pp3_0_car[2])		
   );
   
   tri_fu_csa22_h2 pp3_0_csa_2(
      .a(pp2_0_sum[2]),		
      .b(pp2_0_car[2]),		
      .sum(pp3_0_sum[2]),		
      .car(pp3_0_car[1])		
   );
   
   tri_fu_csa22_h2 pp3_0_csa_1(
      .a(pp2_0_sum[1]),		
      .b(pp2_0_car[1]),		
      .sum(pp3_0_sum[1]),		
      .car(pp3_0_car[0])		
   );
   
   tri_fu_csa22_h2 pp3_0_csa_0(
      .a(pp2_0_sum[0]),		
      .b(pp2_0_car[0]),		
      .sum(pp3_0_sum[0]),		
      .car(pp3_0_car_unused)		
   );
   
   
   assign tbl_sum[0:36] = pp3_0_sum[0:36];
   assign tbl_car[0:35] = pp3_0_car[0:35];
   
endmodule
