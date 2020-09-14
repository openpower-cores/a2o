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
   

module fu_sa3(
   vdd,
   gnd,
   clkoff_b,
   act_dis,
   flush,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   sg_1,
   thold_1,
   fpu_enable,
   nclk,
   f_sa3_si,
   f_sa3_so,
   ex2_act_b,
   f_mul_ex3_sum,
   f_mul_ex3_car,
   f_alg_ex3_res,
   f_sa3_ex4_s_lza,
   f_sa3_ex4_c_lza,
   f_sa3_ex4_s_add,
   f_sa3_ex4_c_add
);
   inout           vdd;
   inout           gnd;
   input           clkoff_b;		
   input           act_dis;		
   input           flush;		
   input [2:3]     delay_lclkr;		
   input [2:3]     mpw1_b;		
   input [0:0]     mpw2_b;		
   input           sg_1;
   input           thold_1;
   input           fpu_enable;		
   input  [0:`NCLK_WIDTH-1]          nclk;
   
   input           f_sa3_si;		
   output          f_sa3_so;		
   input           ex2_act_b;		
   
   input [54:161]  f_mul_ex3_sum;
   input [54:161]  f_mul_ex3_car;
   input [0:162]   f_alg_ex3_res;
   
   output [0:162]  f_sa3_ex4_s_lza;		
   output [53:161] f_sa3_ex4_c_lza;		
   
   output [0:162]  f_sa3_ex4_s_add;		
   output [53:161] f_sa3_ex4_c_add;		
   
   
   
   
   parameter       tiup = 1'b1;
   parameter       tidn = 1'b0;
   
   wire            thold_0_b;
   wire            thold_0;
   wire            force_t;
   wire            sg_0;
   
   (* analysis_not_referenced="TRUE" *) 
   wire [0:3]      act_spare_unused;
   
   wire            ex3_act;
   wire [0:4]      act_so;
   wire [0:4]      act_si;
   wire [0:162]    ex4_sum;
   wire [53:161]   ex4_car;
   wire            ex2_act;
   wire [0:109]    ex4_053_sum_si;
   wire [0:109]    ex4_053_sum_so;
   wire [0:108]    ex4_053_car_si;
   wire [0:108]    ex4_053_car_so;
   wire [0:52]     ex4_000_si;
   wire [0:52]     ex4_000_so;
   wire [0:162]    ex4_sum_lza_b;
   wire [0:162]    ex4_sum_add_b;
   wire [53:161]   ex4_car_lza_b;
   wire [53:161]   ex4_car_add_b;
   wire            sa3_ex4_d2clk;
   wire            sa3_ex4_d1clk;
   wire [0:`NCLK_WIDTH-1]            sa3_ex4_lclk;


   wire [0:52]     ex3_alg_b;		
   wire [53:162]   ex3_sum_b;		
   wire [53:161]   ex3_car_b;		
   
   wire [55:161]   f_alg_ex3_res_b;
   wire [55:161]   f_mul_ex3_sum_b;
   wire [55:161]   f_mul_ex3_car_b;
   
   
   
   
   
   
   assign ex3_sum_b[54] = (~((~(f_mul_ex3_sum[54] | f_mul_ex3_car[54])) ^ f_alg_ex3_res[54]));
   assign ex3_car_b[53] = (~((f_mul_ex3_sum[54] | f_mul_ex3_car[54]) | f_alg_ex3_res[54]));
   
   
   
   assign ex3_alg_b[0:52] = (~f_alg_ex3_res[0:52]);		
   
   
   assign f_alg_ex3_res_b[55:161] = (~(f_alg_ex3_res[55:161]));		
   assign f_mul_ex3_sum_b[55:161] = (~(f_mul_ex3_sum[55:161]));		
   assign f_mul_ex3_car_b[55:161] = (~(f_mul_ex3_car[55:161]));		
   
   tri_csa32 res_csa_55(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[55]),		
      .b(f_mul_ex3_sum_b[55]),		
      .c(f_mul_ex3_car_b[55]),		
      .sum(ex3_sum_b[55]),		
      .car(ex3_car_b[54])		
   );
   
   tri_csa32 res_csa_56(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[56]),		
      .b(f_mul_ex3_sum_b[56]),		
      .c(f_mul_ex3_car_b[56]),		
      .sum(ex3_sum_b[56]),		
      .car(ex3_car_b[55])		
   );
   
   tri_csa32 res_csa_57(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[57]),		
      .b(f_mul_ex3_sum_b[57]),		
      .c(f_mul_ex3_car_b[57]),		
      .sum(ex3_sum_b[57]),		
      .car(ex3_car_b[56])		
   );
   
   tri_csa32 res_csa_58(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[58]),		
      .b(f_mul_ex3_sum_b[58]),		
      .c(f_mul_ex3_car_b[58]),		
      .sum(ex3_sum_b[58]),		
      .car(ex3_car_b[57])		
   );
   
   tri_csa32 res_csa_59(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[59]),		
      .b(f_mul_ex3_sum_b[59]),		
      .c(f_mul_ex3_car_b[59]),		
      .sum(ex3_sum_b[59]),		
      .car(ex3_car_b[58])		
   );
   
   tri_csa32 res_csa_60(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[60]),		
      .b(f_mul_ex3_sum_b[60]),		
      .c(f_mul_ex3_car_b[60]),		
      .sum(ex3_sum_b[60]),		
      .car(ex3_car_b[59])		
   );
   
   tri_csa32 res_csa_61(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[61]),		
      .b(f_mul_ex3_sum_b[61]),		
      .c(f_mul_ex3_car_b[61]),		
      .sum(ex3_sum_b[61]),		
      .car(ex3_car_b[60])		
   );
   
   tri_csa32 res_csa_62(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[62]),		
      .b(f_mul_ex3_sum_b[62]),		
      .c(f_mul_ex3_car_b[62]),		
      .sum(ex3_sum_b[62]),		
      .car(ex3_car_b[61])		
   );
   
   tri_csa32 res_csa_63(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[63]),		
      .b(f_mul_ex3_sum_b[63]),		
      .c(f_mul_ex3_car_b[63]),		
      .sum(ex3_sum_b[63]),		
      .car(ex3_car_b[62])		
   );
   
   tri_csa32 res_csa_64(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[64]),		
      .b(f_mul_ex3_sum_b[64]),		
      .c(f_mul_ex3_car_b[64]),		
      .sum(ex3_sum_b[64]),		
      .car(ex3_car_b[63])		
   );
   
   tri_csa32 res_csa_65(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[65]),		
      .b(f_mul_ex3_sum_b[65]),		
      .c(f_mul_ex3_car_b[65]),		
      .sum(ex3_sum_b[65]),		
      .car(ex3_car_b[64])		
   );
   
   tri_csa32 res_csa_66(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[66]),		
      .b(f_mul_ex3_sum_b[66]),		
      .c(f_mul_ex3_car_b[66]),		
      .sum(ex3_sum_b[66]),		
      .car(ex3_car_b[65])		
   );
   
   tri_csa32 res_csa_67(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[67]),		
      .b(f_mul_ex3_sum_b[67]),		
      .c(f_mul_ex3_car_b[67]),		
      .sum(ex3_sum_b[67]),		
      .car(ex3_car_b[66])		
   );
   
   tri_csa32 res_csa_68(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[68]),		
      .b(f_mul_ex3_sum_b[68]),		
      .c(f_mul_ex3_car_b[68]),		
      .sum(ex3_sum_b[68]),		
      .car(ex3_car_b[67])		
   );
   
   tri_csa32 res_csa_69(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[69]),		
      .b(f_mul_ex3_sum_b[69]),		
      .c(f_mul_ex3_car_b[69]),		
      .sum(ex3_sum_b[69]),		
      .car(ex3_car_b[68])		
   );
   
   tri_csa32 res_csa_70(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[70]),		
      .b(f_mul_ex3_sum_b[70]),		
      .c(f_mul_ex3_car_b[70]),		
      .sum(ex3_sum_b[70]),		
      .car(ex3_car_b[69])		
   );
   
   tri_csa32 res_csa_71(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[71]),		
      .b(f_mul_ex3_sum_b[71]),		
      .c(f_mul_ex3_car_b[71]),		
      .sum(ex3_sum_b[71]),		
      .car(ex3_car_b[70])		
   );
   
   tri_csa32 res_csa_72(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[72]),		
      .b(f_mul_ex3_sum_b[72]),		
      .c(f_mul_ex3_car_b[72]),		
      .sum(ex3_sum_b[72]),		
      .car(ex3_car_b[71])		
   );
   
   tri_csa32 res_csa_73(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[73]),		
      .b(f_mul_ex3_sum_b[73]),		
      .c(f_mul_ex3_car_b[73]),		
      .sum(ex3_sum_b[73]),		
      .car(ex3_car_b[72])		
   );
   
   tri_csa32 res_csa_74(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[74]),		
      .b(f_mul_ex3_sum_b[74]),		
      .c(f_mul_ex3_car_b[74]),		
      .sum(ex3_sum_b[74]),		
      .car(ex3_car_b[73])		
   );
   
   tri_csa32 res_csa_75(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[75]),		
      .b(f_mul_ex3_sum_b[75]),		
      .c(f_mul_ex3_car_b[75]),		
      .sum(ex3_sum_b[75]),		
      .car(ex3_car_b[74])		
   );
   
   tri_csa32 res_csa_76(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[76]),		
      .b(f_mul_ex3_sum_b[76]),		
      .c(f_mul_ex3_car_b[76]),		
      .sum(ex3_sum_b[76]),		
      .car(ex3_car_b[75])		
   );
   
   tri_csa32 res_csa_77(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[77]),		
      .b(f_mul_ex3_sum_b[77]),		
      .c(f_mul_ex3_car_b[77]),		
      .sum(ex3_sum_b[77]),		
      .car(ex3_car_b[76])		
   );
   
   tri_csa32 res_csa_78(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[78]),		
      .b(f_mul_ex3_sum_b[78]),		
      .c(f_mul_ex3_car_b[78]),		
      .sum(ex3_sum_b[78]),		
      .car(ex3_car_b[77])		
   );
   
   tri_csa32 res_csa_79(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[79]),		
      .b(f_mul_ex3_sum_b[79]),		
      .c(f_mul_ex3_car_b[79]),		
      .sum(ex3_sum_b[79]),		
      .car(ex3_car_b[78])		
   );
   
   tri_csa32 res_csa_80(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[80]),		
      .b(f_mul_ex3_sum_b[80]),		
      .c(f_mul_ex3_car_b[80]),		
      .sum(ex3_sum_b[80]),		
      .car(ex3_car_b[79])		
   );
   
   tri_csa32 res_csa_81(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[81]),		
      .b(f_mul_ex3_sum_b[81]),		
      .c(f_mul_ex3_car_b[81]),		
      .sum(ex3_sum_b[81]),		
      .car(ex3_car_b[80])		
   );
   
   tri_csa32 res_csa_82(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[82]),		
      .b(f_mul_ex3_sum_b[82]),		
      .c(f_mul_ex3_car_b[82]),		
      .sum(ex3_sum_b[82]),		
      .car(ex3_car_b[81])		
   );
   
   tri_csa32 res_csa_83(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[83]),		
      .b(f_mul_ex3_sum_b[83]),		
      .c(f_mul_ex3_car_b[83]),		
      .sum(ex3_sum_b[83]),		
      .car(ex3_car_b[82])		
   );
   
   tri_csa32 res_csa_84(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[84]),		
      .b(f_mul_ex3_sum_b[84]),		
      .c(f_mul_ex3_car_b[84]),		
      .sum(ex3_sum_b[84]),		
      .car(ex3_car_b[83])		
   );
   
   tri_csa32 res_csa_85(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[85]),		
      .b(f_mul_ex3_sum_b[85]),		
      .c(f_mul_ex3_car_b[85]),		
      .sum(ex3_sum_b[85]),		
      .car(ex3_car_b[84])		
   );
   
   tri_csa32 res_csa_86(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[86]),		
      .b(f_mul_ex3_sum_b[86]),		
      .c(f_mul_ex3_car_b[86]),		
      .sum(ex3_sum_b[86]),		
      .car(ex3_car_b[85])		
   );
   
   tri_csa32 res_csa_87(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[87]),		
      .b(f_mul_ex3_sum_b[87]),		
      .c(f_mul_ex3_car_b[87]),		
      .sum(ex3_sum_b[87]),		
      .car(ex3_car_b[86])		
   );
   
   tri_csa32 res_csa_88(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[88]),		
      .b(f_mul_ex3_sum_b[88]),		
      .c(f_mul_ex3_car_b[88]),		
      .sum(ex3_sum_b[88]),		
      .car(ex3_car_b[87])		
   );
   
   tri_csa32 res_csa_89(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[89]),		
      .b(f_mul_ex3_sum_b[89]),		
      .c(f_mul_ex3_car_b[89]),		
      .sum(ex3_sum_b[89]),		
      .car(ex3_car_b[88])		
   );
   
   tri_csa32 res_csa_90(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[90]),		
      .b(f_mul_ex3_sum_b[90]),		
      .c(f_mul_ex3_car_b[90]),		
      .sum(ex3_sum_b[90]),		
      .car(ex3_car_b[89])		
   );
   
   tri_csa32 res_csa_91(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[91]),		
      .b(f_mul_ex3_sum_b[91]),		
      .c(f_mul_ex3_car_b[91]),		
      .sum(ex3_sum_b[91]),		
      .car(ex3_car_b[90])		
   );
   
   tri_csa32 res_csa_92(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[92]),		
      .b(f_mul_ex3_sum_b[92]),		
      .c(f_mul_ex3_car_b[92]),		
      .sum(ex3_sum_b[92]),		
      .car(ex3_car_b[91])		
   );
   
   tri_csa32 res_csa_93(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[93]),		
      .b(f_mul_ex3_sum_b[93]),		
      .c(f_mul_ex3_car_b[93]),		
      .sum(ex3_sum_b[93]),		
      .car(ex3_car_b[92])		
   );
   
   tri_csa32 res_csa_94(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[94]),		
      .b(f_mul_ex3_sum_b[94]),		
      .c(f_mul_ex3_car_b[94]),		
      .sum(ex3_sum_b[94]),		
      .car(ex3_car_b[93])		
   );
   
   tri_csa32 res_csa_95(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[95]),		
      .b(f_mul_ex3_sum_b[95]),		
      .c(f_mul_ex3_car_b[95]),		
      .sum(ex3_sum_b[95]),		
      .car(ex3_car_b[94])		
   );
   
   tri_csa32 res_csa_96(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[96]),		
      .b(f_mul_ex3_sum_b[96]),		
      .c(f_mul_ex3_car_b[96]),		
      .sum(ex3_sum_b[96]),		
      .car(ex3_car_b[95])		
   );
   
   tri_csa32 res_csa_97(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[97]),		
      .b(f_mul_ex3_sum_b[97]),		
      .c(f_mul_ex3_car_b[97]),		
      .sum(ex3_sum_b[97]),		
      .car(ex3_car_b[96])		
   );
   
   tri_csa32 res_csa_98(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[98]),		
      .b(f_mul_ex3_sum_b[98]),		
      .c(f_mul_ex3_car_b[98]),		
      .sum(ex3_sum_b[98]),		
      .car(ex3_car_b[97])		
   );
   
   tri_csa32 res_csa_99(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[99]),		
      .b(f_mul_ex3_sum_b[99]),		
      .c(f_mul_ex3_car_b[99]),		
      .sum(ex3_sum_b[99]),		
      .car(ex3_car_b[98])		
   );
   
   tri_csa32 res_csa_100(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[100]),		
      .b(f_mul_ex3_sum_b[100]),		
      .c(f_mul_ex3_car_b[100]),		
      .sum(ex3_sum_b[100]),		
      .car(ex3_car_b[99])		
   );
   
   tri_csa32 res_csa_101(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[101]),		
      .b(f_mul_ex3_sum_b[101]),		
      .c(f_mul_ex3_car_b[101]),		
      .sum(ex3_sum_b[101]),		
      .car(ex3_car_b[100])		
   );
   
   tri_csa32 res_csa_102(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[102]),		
      .b(f_mul_ex3_sum_b[102]),		
      .c(f_mul_ex3_car_b[102]),		
      .sum(ex3_sum_b[102]),		
      .car(ex3_car_b[101])		
   );
   
   tri_csa32 res_csa_103(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[103]),		
      .b(f_mul_ex3_sum_b[103]),		
      .c(f_mul_ex3_car_b[103]),		
      .sum(ex3_sum_b[103]),		
      .car(ex3_car_b[102])		
   );
   
   tri_csa32 res_csa_104(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[104]),		
      .b(f_mul_ex3_sum_b[104]),		
      .c(f_mul_ex3_car_b[104]),		
      .sum(ex3_sum_b[104]),		
      .car(ex3_car_b[103])		
   );
   
   tri_csa32 res_csa_105(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[105]),		
      .b(f_mul_ex3_sum_b[105]),		
      .c(f_mul_ex3_car_b[105]),		
      .sum(ex3_sum_b[105]),		
      .car(ex3_car_b[104])		
   );
   
   tri_csa32 res_csa_106(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[106]),		
      .b(f_mul_ex3_sum_b[106]),		
      .c(f_mul_ex3_car_b[106]),		
      .sum(ex3_sum_b[106]),		
      .car(ex3_car_b[105])		
   );
   
   tri_csa32 res_csa_107(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[107]),		
      .b(f_mul_ex3_sum_b[107]),		
      .c(f_mul_ex3_car_b[107]),		
      .sum(ex3_sum_b[107]),		
      .car(ex3_car_b[106])		
   );
   
   tri_csa32 res_csa_108(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[108]),		
      .b(f_mul_ex3_sum_b[108]),		
      .c(f_mul_ex3_car_b[108]),		
      .sum(ex3_sum_b[108]),		
      .car(ex3_car_b[107])		
   );
   
   tri_csa32 res_csa_109(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[109]),		
      .b(f_mul_ex3_sum_b[109]),		
      .c(f_mul_ex3_car_b[109]),		
      .sum(ex3_sum_b[109]),		
      .car(ex3_car_b[108])		
   );
   
   tri_csa32 res_csa_110(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[110]),		
      .b(f_mul_ex3_sum_b[110]),		
      .c(f_mul_ex3_car_b[110]),		
      .sum(ex3_sum_b[110]),		
      .car(ex3_car_b[109])		
   );
   
   tri_csa32 res_csa_111(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[111]),		
      .b(f_mul_ex3_sum_b[111]),		
      .c(f_mul_ex3_car_b[111]),		
      .sum(ex3_sum_b[111]),		
      .car(ex3_car_b[110])		
   );
   
   tri_csa32 res_csa_112(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[112]),		
      .b(f_mul_ex3_sum_b[112]),		
      .c(f_mul_ex3_car_b[112]),		
      .sum(ex3_sum_b[112]),		
      .car(ex3_car_b[111])		
   );
   
   tri_csa32 res_csa_113(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[113]),		
      .b(f_mul_ex3_sum_b[113]),		
      .c(f_mul_ex3_car_b[113]),		
      .sum(ex3_sum_b[113]),		
      .car(ex3_car_b[112])		
   );
   
   tri_csa32 res_csa_114(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[114]),		
      .b(f_mul_ex3_sum_b[114]),		
      .c(f_mul_ex3_car_b[114]),		
      .sum(ex3_sum_b[114]),		
      .car(ex3_car_b[113])		
   );
   
   tri_csa32 res_csa_115(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[115]),		
      .b(f_mul_ex3_sum_b[115]),		
      .c(f_mul_ex3_car_b[115]),		
      .sum(ex3_sum_b[115]),		
      .car(ex3_car_b[114])		
   );
   
   tri_csa32 res_csa_116(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[116]),		
      .b(f_mul_ex3_sum_b[116]),		
      .c(f_mul_ex3_car_b[116]),		
      .sum(ex3_sum_b[116]),		
      .car(ex3_car_b[115])		
   );
   
   tri_csa32 res_csa_117(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[117]),		
      .b(f_mul_ex3_sum_b[117]),		
      .c(f_mul_ex3_car_b[117]),		
      .sum(ex3_sum_b[117]),		
      .car(ex3_car_b[116])		
   );
   
   tri_csa32 res_csa_118(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[118]),		
      .b(f_mul_ex3_sum_b[118]),		
      .c(f_mul_ex3_car_b[118]),		
      .sum(ex3_sum_b[118]),		
      .car(ex3_car_b[117])		
   );
   
   tri_csa32 res_csa_119(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[119]),		
      .b(f_mul_ex3_sum_b[119]),		
      .c(f_mul_ex3_car_b[119]),		
      .sum(ex3_sum_b[119]),		
      .car(ex3_car_b[118])		
   );
   
   tri_csa32 res_csa_120(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[120]),		
      .b(f_mul_ex3_sum_b[120]),		
      .c(f_mul_ex3_car_b[120]),		
      .sum(ex3_sum_b[120]),		
      .car(ex3_car_b[119])		
   );
   
   tri_csa32 res_csa_121(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[121]),		
      .b(f_mul_ex3_sum_b[121]),		
      .c(f_mul_ex3_car_b[121]),		
      .sum(ex3_sum_b[121]),		
      .car(ex3_car_b[120])		
   );
   
   tri_csa32 res_csa_122(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[122]),		
      .b(f_mul_ex3_sum_b[122]),		
      .c(f_mul_ex3_car_b[122]),		
      .sum(ex3_sum_b[122]),		
      .car(ex3_car_b[121])		
   );
   
   tri_csa32 res_csa_123(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[123]),		
      .b(f_mul_ex3_sum_b[123]),		
      .c(f_mul_ex3_car_b[123]),		
      .sum(ex3_sum_b[123]),		
      .car(ex3_car_b[122])		
   );
   
   tri_csa32 res_csa_124(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[124]),		
      .b(f_mul_ex3_sum_b[124]),		
      .c(f_mul_ex3_car_b[124]),		
      .sum(ex3_sum_b[124]),		
      .car(ex3_car_b[123])		
   );
   
   tri_csa32 res_csa_125(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[125]),		
      .b(f_mul_ex3_sum_b[125]),		
      .c(f_mul_ex3_car_b[125]),		
      .sum(ex3_sum_b[125]),		
      .car(ex3_car_b[124])		
   );
   
   tri_csa32 res_csa_126(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[126]),		
      .b(f_mul_ex3_sum_b[126]),		
      .c(f_mul_ex3_car_b[126]),		
      .sum(ex3_sum_b[126]),		
      .car(ex3_car_b[125])		
   );
   
   tri_csa32 res_csa_127(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[127]),		
      .b(f_mul_ex3_sum_b[127]),		
      .c(f_mul_ex3_car_b[127]),		
      .sum(ex3_sum_b[127]),		
      .car(ex3_car_b[126])		
   );
   
   tri_csa32 res_csa_128(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[128]),		
      .b(f_mul_ex3_sum_b[128]),		
      .c(f_mul_ex3_car_b[128]),		
      .sum(ex3_sum_b[128]),		
      .car(ex3_car_b[127])		
   );
   
   tri_csa32 res_csa_129(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[129]),		
      .b(f_mul_ex3_sum_b[129]),		
      .c(f_mul_ex3_car_b[129]),		
      .sum(ex3_sum_b[129]),		
      .car(ex3_car_b[128])		
   );
   
   tri_csa32 res_csa_130(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[130]),		
      .b(f_mul_ex3_sum_b[130]),		
      .c(f_mul_ex3_car_b[130]),		
      .sum(ex3_sum_b[130]),		
      .car(ex3_car_b[129])		
   );
   
   tri_csa32 res_csa_131(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[131]),		
      .b(f_mul_ex3_sum_b[131]),		
      .c(f_mul_ex3_car_b[131]),		
      .sum(ex3_sum_b[131]),		
      .car(ex3_car_b[130])		
   );
   
   tri_csa32 res_csa_132(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[132]),		
      .b(f_mul_ex3_sum_b[132]),		
      .c(f_mul_ex3_car_b[132]),		
      .sum(ex3_sum_b[132]),		
      .car(ex3_car_b[131])		
   );
   
   tri_csa32 res_csa_133(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[133]),		
      .b(f_mul_ex3_sum_b[133]),		
      .c(f_mul_ex3_car_b[133]),		
      .sum(ex3_sum_b[133]),		
      .car(ex3_car_b[132])		
   );
   
   tri_csa32 res_csa_134(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[134]),		
      .b(f_mul_ex3_sum_b[134]),		
      .c(f_mul_ex3_car_b[134]),		
      .sum(ex3_sum_b[134]),		
      .car(ex3_car_b[133])		
   );
   
   tri_csa32 res_csa_135(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[135]),		
      .b(f_mul_ex3_sum_b[135]),		
      .c(f_mul_ex3_car_b[135]),		
      .sum(ex3_sum_b[135]),		
      .car(ex3_car_b[134])		
   );
   
   tri_csa32 res_csa_136(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[136]),		
      .b(f_mul_ex3_sum_b[136]),		
      .c(f_mul_ex3_car_b[136]),		
      .sum(ex3_sum_b[136]),		
      .car(ex3_car_b[135])		
   );
   
   tri_csa32 res_csa_137(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[137]),		
      .b(f_mul_ex3_sum_b[137]),		
      .c(f_mul_ex3_car_b[137]),		
      .sum(ex3_sum_b[137]),		
      .car(ex3_car_b[136])		
   );
   
   tri_csa32 res_csa_138(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[138]),		
      .b(f_mul_ex3_sum_b[138]),		
      .c(f_mul_ex3_car_b[138]),		
      .sum(ex3_sum_b[138]),		
      .car(ex3_car_b[137])		
   );
   
   tri_csa32 res_csa_139(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[139]),		
      .b(f_mul_ex3_sum_b[139]),		
      .c(f_mul_ex3_car_b[139]),		
      .sum(ex3_sum_b[139]),		
      .car(ex3_car_b[138])		
   );
   
   tri_csa32 res_csa_140(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[140]),		
      .b(f_mul_ex3_sum_b[140]),		
      .c(f_mul_ex3_car_b[140]),		
      .sum(ex3_sum_b[140]),		
      .car(ex3_car_b[139])		
   );
   
   tri_csa32 res_csa_141(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[141]),		
      .b(f_mul_ex3_sum_b[141]),		
      .c(f_mul_ex3_car_b[141]),		
      .sum(ex3_sum_b[141]),		
      .car(ex3_car_b[140])		
   );
   
   tri_csa32 res_csa_142(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[142]),		
      .b(f_mul_ex3_sum_b[142]),		
      .c(f_mul_ex3_car_b[142]),		
      .sum(ex3_sum_b[142]),		
      .car(ex3_car_b[141])		
   );
   
   tri_csa32 res_csa_143(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[143]),		
      .b(f_mul_ex3_sum_b[143]),		
      .c(f_mul_ex3_car_b[143]),		
      .sum(ex3_sum_b[143]),		
      .car(ex3_car_b[142])		
   );
   
   tri_csa32 res_csa_144(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[144]),		
      .b(f_mul_ex3_sum_b[144]),		
      .c(f_mul_ex3_car_b[144]),		
      .sum(ex3_sum_b[144]),		
      .car(ex3_car_b[143])		
   );
   
   tri_csa32 res_csa_145(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[145]),		
      .b(f_mul_ex3_sum_b[145]),		
      .c(f_mul_ex3_car_b[145]),		
      .sum(ex3_sum_b[145]),		
      .car(ex3_car_b[144])		
   );
   
   tri_csa32 res_csa_146(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[146]),		
      .b(f_mul_ex3_sum_b[146]),		
      .c(f_mul_ex3_car_b[146]),		
      .sum(ex3_sum_b[146]),		
      .car(ex3_car_b[145])		
   );
   
   tri_csa32 res_csa_147(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[147]),		
      .b(f_mul_ex3_sum_b[147]),		
      .c(f_mul_ex3_car_b[147]),		
      .sum(ex3_sum_b[147]),		
      .car(ex3_car_b[146])		
   );
   
   tri_csa32 res_csa_148(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[148]),		
      .b(f_mul_ex3_sum_b[148]),		
      .c(f_mul_ex3_car_b[148]),		
      .sum(ex3_sum_b[148]),		
      .car(ex3_car_b[147])		
   );
   
   tri_csa32 res_csa_149(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[149]),		
      .b(f_mul_ex3_sum_b[149]),		
      .c(f_mul_ex3_car_b[149]),		
      .sum(ex3_sum_b[149]),		
      .car(ex3_car_b[148])		
   );
   
   tri_csa32 res_csa_150(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[150]),		
      .b(f_mul_ex3_sum_b[150]),		
      .c(f_mul_ex3_car_b[150]),		
      .sum(ex3_sum_b[150]),		
      .car(ex3_car_b[149])		
   );
   
   tri_csa32 res_csa_151(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[151]),		
      .b(f_mul_ex3_sum_b[151]),		
      .c(f_mul_ex3_car_b[151]),		
      .sum(ex3_sum_b[151]),		
      .car(ex3_car_b[150])		
   );
   
   tri_csa32 res_csa_152(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[152]),		
      .b(f_mul_ex3_sum_b[152]),		
      .c(f_mul_ex3_car_b[152]),		
      .sum(ex3_sum_b[152]),		
      .car(ex3_car_b[151])		
   );
   
   tri_csa32 res_csa_153(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[153]),		
      .b(f_mul_ex3_sum_b[153]),		
      .c(f_mul_ex3_car_b[153]),		
      .sum(ex3_sum_b[153]),		
      .car(ex3_car_b[152])		
   );
   
   tri_csa32 res_csa_154(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[154]),		
      .b(f_mul_ex3_sum_b[154]),		
      .c(f_mul_ex3_car_b[154]),		
      .sum(ex3_sum_b[154]),		
      .car(ex3_car_b[153])		
   );
   
   tri_csa32 res_csa_155(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[155]),		
      .b(f_mul_ex3_sum_b[155]),		
      .c(f_mul_ex3_car_b[155]),		
      .sum(ex3_sum_b[155]),		
      .car(ex3_car_b[154])		
   );
   
   tri_csa32 res_csa_156(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[156]),		
      .b(f_mul_ex3_sum_b[156]),		
      .c(f_mul_ex3_car_b[156]),		
      .sum(ex3_sum_b[156]),		
      .car(ex3_car_b[155])		
   );
   
   tri_csa32 res_csa_157(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[157]),		
      .b(f_mul_ex3_sum_b[157]),		
      .c(f_mul_ex3_car_b[157]),		
      .sum(ex3_sum_b[157]),		
      .car(ex3_car_b[156])		
   );
   
   tri_csa32 res_csa_158(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[158]),		
      .b(f_mul_ex3_sum_b[158]),		
      .c(f_mul_ex3_car_b[158]),		
      .sum(ex3_sum_b[158]),		
      .car(ex3_car_b[157])		
   );
   
   tri_csa32 res_csa_159(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[159]),		
      .b(f_mul_ex3_sum_b[159]),		
      .c(f_mul_ex3_car_b[159]),		
      .sum(ex3_sum_b[159]),		
      .car(ex3_car_b[158])		
   );
   
   tri_csa32 res_csa_160(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[160]),		
      .b(f_mul_ex3_sum_b[160]),		
      .c(f_mul_ex3_car_b[160]),		
      .sum(ex3_sum_b[160]),		
      .car(ex3_car_b[159])		
   );
   
   tri_csa32 res_csa_161(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[161]),		
      .b(f_mul_ex3_sum_b[161]),		
      .c(f_mul_ex3_car_b[161]),		
      .sum(ex3_sum_b[161]),		
      .car(ex3_car_b[160])		
   );
   
   assign ex3_sum_b[53] = (~f_alg_ex3_res[53]);
   assign ex3_sum_b[162] = (~f_alg_ex3_res[162]);
   assign ex3_car_b[161] = tiup;		
   
   
   
   tri_inv_nlats #(.WIDTH(53),  .NEEDS_SRESET(0)) ex4_000_lat( 
      .vd(vdd),
      .gd(gnd),
      .lclk(sa3_ex4_lclk),		
      .d1clk(sa3_ex4_d1clk),
      .d2clk(sa3_ex4_d2clk),
      .scanin(ex4_000_si),
      .scanout(ex4_000_so),
      .d(ex3_alg_b[0:52]),
      .qb(ex4_sum[0:52])
   );
   
   tri_inv_nlats #(.WIDTH(110),  .NEEDS_SRESET(0)) ex4_053_sum_lat( 
      .vd(vdd),
      .gd(gnd),
      .lclk(sa3_ex4_lclk),		
      .d1clk(sa3_ex4_d1clk),
      .d2clk(sa3_ex4_d2clk),
      .scanin(ex4_053_sum_si),
      .scanout(ex4_053_sum_so),
      .d(ex3_sum_b[53:162]),
      .qb(ex4_sum[53:162])
   );
   
   tri_inv_nlats #(.WIDTH(109),  .NEEDS_SRESET(0)) ex4_053_car_lat( 
      .vd(vdd),
      .gd(gnd),
      .lclk(sa3_ex4_lclk),		
      .d1clk(sa3_ex4_d1clk),
      .d2clk(sa3_ex4_d2clk),
      .scanin(ex4_053_car_si),
      .scanout(ex4_053_car_so),
      .d(ex3_car_b[53:161]),
      .qb(ex4_car[53:161])
   );
   
   assign ex4_sum_lza_b[0:162] = (~ex4_sum[0:162]);
   assign ex4_car_lza_b[53:161] = (~ex4_car[53:161]);
   assign ex4_sum_add_b[0:162] = (~ex4_sum[0:162]);
   assign ex4_car_add_b[53:161] = (~ex4_car[53:161]);
   
   assign f_sa3_ex4_s_lza[0:162] = (~ex4_sum_lza_b[0:162]);
   assign f_sa3_ex4_c_lza[53:161] = (~ex4_car_lza_b[53:161]);
   assign f_sa3_ex4_s_add[0:162] = (~ex4_sum_add_b[0:162]);
   assign f_sa3_ex4_c_add[53:161] = (~ex4_car_add_b[53:161]);
   
   
   
   tri_plat  thold_reg_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(flush),
      .din(thold_1),		
      .q(thold_0)
   );
   
   
   tri_plat  sg_reg_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(flush),
      .din(sg_1),
      .q(sg_0)
   );
   
   
   tri_lcbor  lcbor_0(
      .clkoff_b(clkoff_b),
      .thold(thold_0),
      .sg(sg_0),
      .act_dis(act_dis),
      .force_t(force_t),
      .thold_b(thold_0_b)
   );
   
   
   assign ex2_act = (~ex2_act_b);
   
   
   tri_rlmreg_p #(.WIDTH(5), .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),		
      .d_mode(tiup),						       
      .delay_lclkr(delay_lclkr[2]),		
      .mpw1_b(mpw1_b[2]),		
      .mpw2_b(mpw2_b[0]),		
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(fpu_enable),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(act_so),
      .scin(act_si),
      .din({ act_spare_unused[0],
             act_spare_unused[1],
             ex2_act,
             act_spare_unused[2],
             act_spare_unused[3]}),
      .dout({act_spare_unused[0],
             act_spare_unused[1],
             ex3_act,
             act_spare_unused[2],
             act_spare_unused[3]})
   );
   
   
   tri_lcbnd  sa3_ex4_lcb(
      .delay_lclkr(delay_lclkr[3]),		
      .mpw1_b(mpw1_b[3]),		
      .mpw2_b(mpw2_b[0]),		
      .force_t(force_t),		
      .nclk(nclk),		
      .vd(vdd),		
      .gd(gnd),		
      .act(ex3_act),		
      .sg(sg_0),		
      .thold_b(thold_0_b),		
      .d1clk(sa3_ex4_d1clk),		
      .d2clk(sa3_ex4_d2clk),		
      .lclk(sa3_ex4_lclk)		
   );
   
   
   assign ex4_053_car_si[0:108] = {ex4_053_car_so[1:108], f_sa3_si};
   assign ex4_053_sum_si[0:109] = {ex4_053_sum_so[1:109], ex4_053_car_so[0]};
   assign ex4_000_si[0:52] = {ex4_000_so[1:52], ex4_053_sum_so[0]};
   assign act_si[0:4] = {act_so[1:4], ex4_000_so[0]};
   assign f_sa3_so = act_so[0];
   
endmodule
