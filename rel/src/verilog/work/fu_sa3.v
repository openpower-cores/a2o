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
   input           clkoff_b;		// tiup
   input           act_dis;		// ??tidn??
   input           flush;		// ??tidn??
   input [2:3]     delay_lclkr;		// tidn,
   input [2:3]     mpw1_b;		// tidn,
   input [0:0]     mpw2_b;		// tidn,
   input           sg_1;
   input           thold_1;
   input           fpu_enable;		//dc_act
   input  [0:`NCLK_WIDTH-1]          nclk;

   input           f_sa3_si;		//perv
   output          f_sa3_so;		//perv
   input           ex2_act_b;		//act

   input [54:161]  f_mul_ex3_sum;
   input [54:161]  f_mul_ex3_car;
   input [0:162]   f_alg_ex3_res;

   output [0:162]  f_sa3_ex4_s_lza;		// data
   output [53:161] f_sa3_ex4_c_lza;		// data

   output [0:162]  f_sa3_ex4_s_add;		// data
   output [53:161] f_sa3_ex4_c_add;		// data

   // ENTITY


   parameter       tiup = 1'b1;
   parameter       tidn = 1'b0;

   ////#################################
   ////# sigdef : functional
   ////#################################
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

   ////################################################################
   ////# ex3 logic
   ////################################################################

   // just a 3:2 compressor
   //
   // ex3_sum(54 to 159) <= f_mul_ex3_sum(54 to 159) xor f_mul_ex3_car(54 to 159) xor f_alg_ex3_res(54 to 159) ;
   // ex3_sum(160)       <= f_mul_ex3_sum(160)       xor                              f_alg_ex3_res(160)       ;
   //
   // ex3_car(53 to 158) <= ( f_mul_ex3_sum(54 to 159) and f_mul_ex3_car(54 to 159) ) or
   //                       ( f_mul_ex3_sum(54 to 159) and f_alg_ex3_res(54 to 159) ) or
   //                       ( f_alg_ex3_res(54 to 159) and f_mul_ex3_car(54 to 159) ) ;
   // ex3_car(159)       <= ( f_mul_ex3_sum(160)       and f_alg_ex3_res(160)       ) ;
   //---------------------------------------------------------------

   // this model                       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   //
   // aligner  000 001 002 ....... 052 053 054  055 056 .... 158 159 160 161 162
   // mul sum  xxx xxx xxx ....... xxx xxx 054* 055 056 .... 158 159 160 xxx xxx
   // mul car  xxx xxx xxx ....... xxx xxx 054* 055 056 .... 158 159 xxx xxx xxx
   // rid PB   "1" "1" "1" ....... "1" "1" "1"  "0" "0" .... "0" "0" "0" "0" "0"
   //
   // 54* is the pseudo bit ... at most 1 is on

   assign ex3_sum_b[54] = (~((~(f_mul_ex3_sum[54] | f_mul_ex3_car[54])) ^ f_alg_ex3_res[54]));
   assign ex3_car_b[53] = (~((f_mul_ex3_sum[54] | f_mul_ex3_car[54]) | f_alg_ex3_res[54]));

   // rest of bits are normal as expected

   // with 3:2 is it equivalent to invert all the inputs, or invert all the outputs

   assign ex3_alg_b[0:52] = (~f_alg_ex3_res[0:52]);

   assign f_alg_ex3_res_b[55:161] = (~(f_alg_ex3_res[55:161]));
   assign f_mul_ex3_sum_b[55:161] = (~(f_mul_ex3_sum[55:161]));
   assign f_mul_ex3_car_b[55:161] = (~(f_mul_ex3_car[55:161]));

   		//MLT32_X1_A12TH
   tri_csa32 res_csa_55(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[55]),		//i--
      .b(f_mul_ex3_sum_b[55]),		//i--
      .c(f_mul_ex3_car_b[55]),		//i--
      .sum(ex3_sum_b[55]),		//o--
      .car(ex3_car_b[54])		//o--
   );

   tri_csa32 res_csa_56(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[56]),		//i--
      .b(f_mul_ex3_sum_b[56]),		//i--
      .c(f_mul_ex3_car_b[56]),		//i--
      .sum(ex3_sum_b[56]),		//o--
      .car(ex3_car_b[55])		//o--
   );

   tri_csa32 res_csa_57(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[57]),		//i--
      .b(f_mul_ex3_sum_b[57]),		//i--
      .c(f_mul_ex3_car_b[57]),		//i--
      .sum(ex3_sum_b[57]),		//o--
      .car(ex3_car_b[56])		//o--
   );

   tri_csa32 res_csa_58(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[58]),		//i--
      .b(f_mul_ex3_sum_b[58]),		//i--
      .c(f_mul_ex3_car_b[58]),		//i--
      .sum(ex3_sum_b[58]),		//o--
      .car(ex3_car_b[57])		//o--
   );

   tri_csa32 res_csa_59(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[59]),		//i--
      .b(f_mul_ex3_sum_b[59]),		//i--
      .c(f_mul_ex3_car_b[59]),		//i--
      .sum(ex3_sum_b[59]),		//o--
      .car(ex3_car_b[58])		//o--
   );

   tri_csa32 res_csa_60(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[60]),		//i--
      .b(f_mul_ex3_sum_b[60]),		//i--
      .c(f_mul_ex3_car_b[60]),		//i--
      .sum(ex3_sum_b[60]),		//o--
      .car(ex3_car_b[59])		//o--
   );

   tri_csa32 res_csa_61(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[61]),		//i--
      .b(f_mul_ex3_sum_b[61]),		//i--
      .c(f_mul_ex3_car_b[61]),		//i--
      .sum(ex3_sum_b[61]),		//o--
      .car(ex3_car_b[60])		//o--
   );

   tri_csa32 res_csa_62(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[62]),		//i--
      .b(f_mul_ex3_sum_b[62]),		//i--
      .c(f_mul_ex3_car_b[62]),		//i--
      .sum(ex3_sum_b[62]),		//o--
      .car(ex3_car_b[61])		//o--
   );

   tri_csa32 res_csa_63(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[63]),		//i--
      .b(f_mul_ex3_sum_b[63]),		//i--
      .c(f_mul_ex3_car_b[63]),		//i--
      .sum(ex3_sum_b[63]),		//o--
      .car(ex3_car_b[62])		//o--
   );

   tri_csa32 res_csa_64(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[64]),		//i--
      .b(f_mul_ex3_sum_b[64]),		//i--
      .c(f_mul_ex3_car_b[64]),		//i--
      .sum(ex3_sum_b[64]),		//o--
      .car(ex3_car_b[63])		//o--
   );

   tri_csa32 res_csa_65(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[65]),		//i--
      .b(f_mul_ex3_sum_b[65]),		//i--
      .c(f_mul_ex3_car_b[65]),		//i--
      .sum(ex3_sum_b[65]),		//o--
      .car(ex3_car_b[64])		//o--
   );

   tri_csa32 res_csa_66(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[66]),		//i--
      .b(f_mul_ex3_sum_b[66]),		//i--
      .c(f_mul_ex3_car_b[66]),		//i--
      .sum(ex3_sum_b[66]),		//o--
      .car(ex3_car_b[65])		//o--
   );

   tri_csa32 res_csa_67(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[67]),		//i--
      .b(f_mul_ex3_sum_b[67]),		//i--
      .c(f_mul_ex3_car_b[67]),		//i--
      .sum(ex3_sum_b[67]),		//o--
      .car(ex3_car_b[66])		//o--
   );

   tri_csa32 res_csa_68(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[68]),		//i--
      .b(f_mul_ex3_sum_b[68]),		//i--
      .c(f_mul_ex3_car_b[68]),		//i--
      .sum(ex3_sum_b[68]),		//o--
      .car(ex3_car_b[67])		//o--
   );

   tri_csa32 res_csa_69(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[69]),		//i--
      .b(f_mul_ex3_sum_b[69]),		//i--
      .c(f_mul_ex3_car_b[69]),		//i--
      .sum(ex3_sum_b[69]),		//o--
      .car(ex3_car_b[68])		//o--
   );

   tri_csa32 res_csa_70(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[70]),		//i--
      .b(f_mul_ex3_sum_b[70]),		//i--
      .c(f_mul_ex3_car_b[70]),		//i--
      .sum(ex3_sum_b[70]),		//o--
      .car(ex3_car_b[69])		//o--
   );

   tri_csa32 res_csa_71(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[71]),		//i--
      .b(f_mul_ex3_sum_b[71]),		//i--
      .c(f_mul_ex3_car_b[71]),		//i--
      .sum(ex3_sum_b[71]),		//o--
      .car(ex3_car_b[70])		//o--
   );

   tri_csa32 res_csa_72(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[72]),		//i--
      .b(f_mul_ex3_sum_b[72]),		//i--
      .c(f_mul_ex3_car_b[72]),		//i--
      .sum(ex3_sum_b[72]),		//o--
      .car(ex3_car_b[71])		//o--
   );

   tri_csa32 res_csa_73(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[73]),		//i--
      .b(f_mul_ex3_sum_b[73]),		//i--
      .c(f_mul_ex3_car_b[73]),		//i--
      .sum(ex3_sum_b[73]),		//o--
      .car(ex3_car_b[72])		//o--
   );

   tri_csa32 res_csa_74(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[74]),		//i--
      .b(f_mul_ex3_sum_b[74]),		//i--
      .c(f_mul_ex3_car_b[74]),		//i--
      .sum(ex3_sum_b[74]),		//o--
      .car(ex3_car_b[73])		//o--
   );

   tri_csa32 res_csa_75(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[75]),		//i--
      .b(f_mul_ex3_sum_b[75]),		//i--
      .c(f_mul_ex3_car_b[75]),		//i--
      .sum(ex3_sum_b[75]),		//o--
      .car(ex3_car_b[74])		//o--
   );

   tri_csa32 res_csa_76(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[76]),		//i--
      .b(f_mul_ex3_sum_b[76]),		//i--
      .c(f_mul_ex3_car_b[76]),		//i--
      .sum(ex3_sum_b[76]),		//o--
      .car(ex3_car_b[75])		//o--
   );

   tri_csa32 res_csa_77(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[77]),		//i--
      .b(f_mul_ex3_sum_b[77]),		//i--
      .c(f_mul_ex3_car_b[77]),		//i--
      .sum(ex3_sum_b[77]),		//o--
      .car(ex3_car_b[76])		//o--
   );

   tri_csa32 res_csa_78(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[78]),		//i--
      .b(f_mul_ex3_sum_b[78]),		//i--
      .c(f_mul_ex3_car_b[78]),		//i--
      .sum(ex3_sum_b[78]),		//o--
      .car(ex3_car_b[77])		//o--
   );

   tri_csa32 res_csa_79(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[79]),		//i--
      .b(f_mul_ex3_sum_b[79]),		//i--
      .c(f_mul_ex3_car_b[79]),		//i--
      .sum(ex3_sum_b[79]),		//o--
      .car(ex3_car_b[78])		//o--
   );

   tri_csa32 res_csa_80(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[80]),		//i--
      .b(f_mul_ex3_sum_b[80]),		//i--
      .c(f_mul_ex3_car_b[80]),		//i--
      .sum(ex3_sum_b[80]),		//o--
      .car(ex3_car_b[79])		//o--
   );

   tri_csa32 res_csa_81(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[81]),		//i--
      .b(f_mul_ex3_sum_b[81]),		//i--
      .c(f_mul_ex3_car_b[81]),		//i--
      .sum(ex3_sum_b[81]),		//o--
      .car(ex3_car_b[80])		//o--
   );

   tri_csa32 res_csa_82(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[82]),		//i--
      .b(f_mul_ex3_sum_b[82]),		//i--
      .c(f_mul_ex3_car_b[82]),		//i--
      .sum(ex3_sum_b[82]),		//o--
      .car(ex3_car_b[81])		//o--
   );

   tri_csa32 res_csa_83(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[83]),		//i--
      .b(f_mul_ex3_sum_b[83]),		//i--
      .c(f_mul_ex3_car_b[83]),		//i--
      .sum(ex3_sum_b[83]),		//o--
      .car(ex3_car_b[82])		//o--
   );

   tri_csa32 res_csa_84(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[84]),		//i--
      .b(f_mul_ex3_sum_b[84]),		//i--
      .c(f_mul_ex3_car_b[84]),		//i--
      .sum(ex3_sum_b[84]),		//o--
      .car(ex3_car_b[83])		//o--
   );

   tri_csa32 res_csa_85(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[85]),		//i--
      .b(f_mul_ex3_sum_b[85]),		//i--
      .c(f_mul_ex3_car_b[85]),		//i--
      .sum(ex3_sum_b[85]),		//o--
      .car(ex3_car_b[84])		//o--
   );

   tri_csa32 res_csa_86(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[86]),		//i--
      .b(f_mul_ex3_sum_b[86]),		//i--
      .c(f_mul_ex3_car_b[86]),		//i--
      .sum(ex3_sum_b[86]),		//o--
      .car(ex3_car_b[85])		//o--
   );

   tri_csa32 res_csa_87(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[87]),		//i--
      .b(f_mul_ex3_sum_b[87]),		//i--
      .c(f_mul_ex3_car_b[87]),		//i--
      .sum(ex3_sum_b[87]),		//o--
      .car(ex3_car_b[86])		//o--
   );

   tri_csa32 res_csa_88(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[88]),		//i--
      .b(f_mul_ex3_sum_b[88]),		//i--
      .c(f_mul_ex3_car_b[88]),		//i--
      .sum(ex3_sum_b[88]),		//o--
      .car(ex3_car_b[87])		//o--
   );

   tri_csa32 res_csa_89(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[89]),		//i--
      .b(f_mul_ex3_sum_b[89]),		//i--
      .c(f_mul_ex3_car_b[89]),		//i--
      .sum(ex3_sum_b[89]),		//o--
      .car(ex3_car_b[88])		//o--
   );

   tri_csa32 res_csa_90(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[90]),		//i--
      .b(f_mul_ex3_sum_b[90]),		//i--
      .c(f_mul_ex3_car_b[90]),		//i--
      .sum(ex3_sum_b[90]),		//o--
      .car(ex3_car_b[89])		//o--
   );

   tri_csa32 res_csa_91(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[91]),		//i--
      .b(f_mul_ex3_sum_b[91]),		//i--
      .c(f_mul_ex3_car_b[91]),		//i--
      .sum(ex3_sum_b[91]),		//o--
      .car(ex3_car_b[90])		//o--
   );

   tri_csa32 res_csa_92(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[92]),		//i--
      .b(f_mul_ex3_sum_b[92]),		//i--
      .c(f_mul_ex3_car_b[92]),		//i--
      .sum(ex3_sum_b[92]),		//o--
      .car(ex3_car_b[91])		//o--
   );

   tri_csa32 res_csa_93(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[93]),		//i--
      .b(f_mul_ex3_sum_b[93]),		//i--
      .c(f_mul_ex3_car_b[93]),		//i--
      .sum(ex3_sum_b[93]),		//o--
      .car(ex3_car_b[92])		//o--
   );

   tri_csa32 res_csa_94(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[94]),		//i--
      .b(f_mul_ex3_sum_b[94]),		//i--
      .c(f_mul_ex3_car_b[94]),		//i--
      .sum(ex3_sum_b[94]),		//o--
      .car(ex3_car_b[93])		//o--
   );

   tri_csa32 res_csa_95(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[95]),		//i--
      .b(f_mul_ex3_sum_b[95]),		//i--
      .c(f_mul_ex3_car_b[95]),		//i--
      .sum(ex3_sum_b[95]),		//o--
      .car(ex3_car_b[94])		//o--
   );

   tri_csa32 res_csa_96(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[96]),		//i--
      .b(f_mul_ex3_sum_b[96]),		//i--
      .c(f_mul_ex3_car_b[96]),		//i--
      .sum(ex3_sum_b[96]),		//o--
      .car(ex3_car_b[95])		//o--
   );

   tri_csa32 res_csa_97(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[97]),		//i--
      .b(f_mul_ex3_sum_b[97]),		//i--
      .c(f_mul_ex3_car_b[97]),		//i--
      .sum(ex3_sum_b[97]),		//o--
      .car(ex3_car_b[96])		//o--
   );

   tri_csa32 res_csa_98(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[98]),		//i--
      .b(f_mul_ex3_sum_b[98]),		//i--
      .c(f_mul_ex3_car_b[98]),		//i--
      .sum(ex3_sum_b[98]),		//o--
      .car(ex3_car_b[97])		//o--
   );

   tri_csa32 res_csa_99(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[99]),		//i--
      .b(f_mul_ex3_sum_b[99]),		//i--
      .c(f_mul_ex3_car_b[99]),		//i--
      .sum(ex3_sum_b[99]),		//o--
      .car(ex3_car_b[98])		//o--
   );

   tri_csa32 res_csa_100(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[100]),		//i--
      .b(f_mul_ex3_sum_b[100]),		//i--
      .c(f_mul_ex3_car_b[100]),		//i--
      .sum(ex3_sum_b[100]),		//o--
      .car(ex3_car_b[99])		//o--
   );

   tri_csa32 res_csa_101(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[101]),		//i--
      .b(f_mul_ex3_sum_b[101]),		//i--
      .c(f_mul_ex3_car_b[101]),		//i--
      .sum(ex3_sum_b[101]),		//o--
      .car(ex3_car_b[100])		//o--
   );

   tri_csa32 res_csa_102(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[102]),		//i--
      .b(f_mul_ex3_sum_b[102]),		//i--
      .c(f_mul_ex3_car_b[102]),		//i--
      .sum(ex3_sum_b[102]),		//o--
      .car(ex3_car_b[101])		//o--
   );

   tri_csa32 res_csa_103(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[103]),		//i--
      .b(f_mul_ex3_sum_b[103]),		//i--
      .c(f_mul_ex3_car_b[103]),		//i--
      .sum(ex3_sum_b[103]),		//o--
      .car(ex3_car_b[102])		//o--
   );

   tri_csa32 res_csa_104(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[104]),		//i--
      .b(f_mul_ex3_sum_b[104]),		//i--
      .c(f_mul_ex3_car_b[104]),		//i--
      .sum(ex3_sum_b[104]),		//o--
      .car(ex3_car_b[103])		//o--
   );

   tri_csa32 res_csa_105(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[105]),		//i--
      .b(f_mul_ex3_sum_b[105]),		//i--
      .c(f_mul_ex3_car_b[105]),		//i--
      .sum(ex3_sum_b[105]),		//o--
      .car(ex3_car_b[104])		//o--
   );

   tri_csa32 res_csa_106(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[106]),		//i--
      .b(f_mul_ex3_sum_b[106]),		//i--
      .c(f_mul_ex3_car_b[106]),		//i--
      .sum(ex3_sum_b[106]),		//o--
      .car(ex3_car_b[105])		//o--
   );

   tri_csa32 res_csa_107(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[107]),		//i--
      .b(f_mul_ex3_sum_b[107]),		//i--
      .c(f_mul_ex3_car_b[107]),		//i--
      .sum(ex3_sum_b[107]),		//o--
      .car(ex3_car_b[106])		//o--
   );

   tri_csa32 res_csa_108(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[108]),		//i--
      .b(f_mul_ex3_sum_b[108]),		//i--
      .c(f_mul_ex3_car_b[108]),		//i--
      .sum(ex3_sum_b[108]),		//o--
      .car(ex3_car_b[107])		//o--
   );

   tri_csa32 res_csa_109(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[109]),		//i--
      .b(f_mul_ex3_sum_b[109]),		//i--
      .c(f_mul_ex3_car_b[109]),		//i--
      .sum(ex3_sum_b[109]),		//o--
      .car(ex3_car_b[108])		//o--
   );

   tri_csa32 res_csa_110(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[110]),		//i--
      .b(f_mul_ex3_sum_b[110]),		//i--
      .c(f_mul_ex3_car_b[110]),		//i--
      .sum(ex3_sum_b[110]),		//o--
      .car(ex3_car_b[109])		//o--
   );

   tri_csa32 res_csa_111(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[111]),		//i--
      .b(f_mul_ex3_sum_b[111]),		//i--
      .c(f_mul_ex3_car_b[111]),		//i--
      .sum(ex3_sum_b[111]),		//o--
      .car(ex3_car_b[110])		//o--
   );

   tri_csa32 res_csa_112(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[112]),		//i--
      .b(f_mul_ex3_sum_b[112]),		//i--
      .c(f_mul_ex3_car_b[112]),		//i--
      .sum(ex3_sum_b[112]),		//o--
      .car(ex3_car_b[111])		//o--
   );

   tri_csa32 res_csa_113(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[113]),		//i--
      .b(f_mul_ex3_sum_b[113]),		//i--
      .c(f_mul_ex3_car_b[113]),		//i--
      .sum(ex3_sum_b[113]),		//o--
      .car(ex3_car_b[112])		//o--
   );

   tri_csa32 res_csa_114(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[114]),		//i--
      .b(f_mul_ex3_sum_b[114]),		//i--
      .c(f_mul_ex3_car_b[114]),		//i--
      .sum(ex3_sum_b[114]),		//o--
      .car(ex3_car_b[113])		//o--
   );

   tri_csa32 res_csa_115(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[115]),		//i--
      .b(f_mul_ex3_sum_b[115]),		//i--
      .c(f_mul_ex3_car_b[115]),		//i--
      .sum(ex3_sum_b[115]),		//o--
      .car(ex3_car_b[114])		//o--
   );

   tri_csa32 res_csa_116(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[116]),		//i--
      .b(f_mul_ex3_sum_b[116]),		//i--
      .c(f_mul_ex3_car_b[116]),		//i--
      .sum(ex3_sum_b[116]),		//o--
      .car(ex3_car_b[115])		//o--
   );

   tri_csa32 res_csa_117(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[117]),		//i--
      .b(f_mul_ex3_sum_b[117]),		//i--
      .c(f_mul_ex3_car_b[117]),		//i--
      .sum(ex3_sum_b[117]),		//o--
      .car(ex3_car_b[116])		//o--
   );

   tri_csa32 res_csa_118(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[118]),		//i--
      .b(f_mul_ex3_sum_b[118]),		//i--
      .c(f_mul_ex3_car_b[118]),		//i--
      .sum(ex3_sum_b[118]),		//o--
      .car(ex3_car_b[117])		//o--
   );

   tri_csa32 res_csa_119(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[119]),		//i--
      .b(f_mul_ex3_sum_b[119]),		//i--
      .c(f_mul_ex3_car_b[119]),		//i--
      .sum(ex3_sum_b[119]),		//o--
      .car(ex3_car_b[118])		//o--
   );

   tri_csa32 res_csa_120(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[120]),		//i--
      .b(f_mul_ex3_sum_b[120]),		//i--
      .c(f_mul_ex3_car_b[120]),		//i--
      .sum(ex3_sum_b[120]),		//o--
      .car(ex3_car_b[119])		//o--
   );

   tri_csa32 res_csa_121(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[121]),		//i--
      .b(f_mul_ex3_sum_b[121]),		//i--
      .c(f_mul_ex3_car_b[121]),		//i--
      .sum(ex3_sum_b[121]),		//o--
      .car(ex3_car_b[120])		//o--
   );

   tri_csa32 res_csa_122(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[122]),		//i--
      .b(f_mul_ex3_sum_b[122]),		//i--
      .c(f_mul_ex3_car_b[122]),		//i--
      .sum(ex3_sum_b[122]),		//o--
      .car(ex3_car_b[121])		//o--
   );

   tri_csa32 res_csa_123(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[123]),		//i--
      .b(f_mul_ex3_sum_b[123]),		//i--
      .c(f_mul_ex3_car_b[123]),		//i--
      .sum(ex3_sum_b[123]),		//o--
      .car(ex3_car_b[122])		//o--
   );

   tri_csa32 res_csa_124(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[124]),		//i--
      .b(f_mul_ex3_sum_b[124]),		//i--
      .c(f_mul_ex3_car_b[124]),		//i--
      .sum(ex3_sum_b[124]),		//o--
      .car(ex3_car_b[123])		//o--
   );

   tri_csa32 res_csa_125(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[125]),		//i--
      .b(f_mul_ex3_sum_b[125]),		//i--
      .c(f_mul_ex3_car_b[125]),		//i--
      .sum(ex3_sum_b[125]),		//o--
      .car(ex3_car_b[124])		//o--
   );

   tri_csa32 res_csa_126(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[126]),		//i--
      .b(f_mul_ex3_sum_b[126]),		//i--
      .c(f_mul_ex3_car_b[126]),		//i--
      .sum(ex3_sum_b[126]),		//o--
      .car(ex3_car_b[125])		//o--
   );

   tri_csa32 res_csa_127(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[127]),		//i--
      .b(f_mul_ex3_sum_b[127]),		//i--
      .c(f_mul_ex3_car_b[127]),		//i--
      .sum(ex3_sum_b[127]),		//o--
      .car(ex3_car_b[126])		//o--
   );

   tri_csa32 res_csa_128(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[128]),		//i--
      .b(f_mul_ex3_sum_b[128]),		//i--
      .c(f_mul_ex3_car_b[128]),		//i--
      .sum(ex3_sum_b[128]),		//o--
      .car(ex3_car_b[127])		//o--
   );

   tri_csa32 res_csa_129(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[129]),		//i--
      .b(f_mul_ex3_sum_b[129]),		//i--
      .c(f_mul_ex3_car_b[129]),		//i--
      .sum(ex3_sum_b[129]),		//o--
      .car(ex3_car_b[128])		//o--
   );

   tri_csa32 res_csa_130(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[130]),		//i--
      .b(f_mul_ex3_sum_b[130]),		//i--
      .c(f_mul_ex3_car_b[130]),		//i--
      .sum(ex3_sum_b[130]),		//o--
      .car(ex3_car_b[129])		//o--
   );

   tri_csa32 res_csa_131(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[131]),		//i--
      .b(f_mul_ex3_sum_b[131]),		//i--
      .c(f_mul_ex3_car_b[131]),		//i--
      .sum(ex3_sum_b[131]),		//o--
      .car(ex3_car_b[130])		//o--
   );

   tri_csa32 res_csa_132(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[132]),		//i--
      .b(f_mul_ex3_sum_b[132]),		//i--
      .c(f_mul_ex3_car_b[132]),		//i--
      .sum(ex3_sum_b[132]),		//o--
      .car(ex3_car_b[131])		//o--
   );

   tri_csa32 res_csa_133(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[133]),		//i--
      .b(f_mul_ex3_sum_b[133]),		//i--
      .c(f_mul_ex3_car_b[133]),		//i--
      .sum(ex3_sum_b[133]),		//o--
      .car(ex3_car_b[132])		//o--
   );

   tri_csa32 res_csa_134(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[134]),		//i--
      .b(f_mul_ex3_sum_b[134]),		//i--
      .c(f_mul_ex3_car_b[134]),		//i--
      .sum(ex3_sum_b[134]),		//o--
      .car(ex3_car_b[133])		//o--
   );

   tri_csa32 res_csa_135(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[135]),		//i--
      .b(f_mul_ex3_sum_b[135]),		//i--
      .c(f_mul_ex3_car_b[135]),		//i--
      .sum(ex3_sum_b[135]),		//o--
      .car(ex3_car_b[134])		//o--
   );

   tri_csa32 res_csa_136(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[136]),		//i--
      .b(f_mul_ex3_sum_b[136]),		//i--
      .c(f_mul_ex3_car_b[136]),		//i--
      .sum(ex3_sum_b[136]),		//o--
      .car(ex3_car_b[135])		//o--
   );

   tri_csa32 res_csa_137(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[137]),		//i--
      .b(f_mul_ex3_sum_b[137]),		//i--
      .c(f_mul_ex3_car_b[137]),		//i--
      .sum(ex3_sum_b[137]),		//o--
      .car(ex3_car_b[136])		//o--
   );

   tri_csa32 res_csa_138(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[138]),		//i--
      .b(f_mul_ex3_sum_b[138]),		//i--
      .c(f_mul_ex3_car_b[138]),		//i--
      .sum(ex3_sum_b[138]),		//o--
      .car(ex3_car_b[137])		//o--
   );

   tri_csa32 res_csa_139(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[139]),		//i--
      .b(f_mul_ex3_sum_b[139]),		//i--
      .c(f_mul_ex3_car_b[139]),		//i--
      .sum(ex3_sum_b[139]),		//o--
      .car(ex3_car_b[138])		//o--
   );

   tri_csa32 res_csa_140(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[140]),		//i--
      .b(f_mul_ex3_sum_b[140]),		//i--
      .c(f_mul_ex3_car_b[140]),		//i--
      .sum(ex3_sum_b[140]),		//o--
      .car(ex3_car_b[139])		//o--
   );

   tri_csa32 res_csa_141(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[141]),		//i--
      .b(f_mul_ex3_sum_b[141]),		//i--
      .c(f_mul_ex3_car_b[141]),		//i--
      .sum(ex3_sum_b[141]),		//o--
      .car(ex3_car_b[140])		//o--
   );

   tri_csa32 res_csa_142(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[142]),		//i--
      .b(f_mul_ex3_sum_b[142]),		//i--
      .c(f_mul_ex3_car_b[142]),		//i--
      .sum(ex3_sum_b[142]),		//o--
      .car(ex3_car_b[141])		//o--
   );

   tri_csa32 res_csa_143(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[143]),		//i--
      .b(f_mul_ex3_sum_b[143]),		//i--
      .c(f_mul_ex3_car_b[143]),		//i--
      .sum(ex3_sum_b[143]),		//o--
      .car(ex3_car_b[142])		//o--
   );

   tri_csa32 res_csa_144(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[144]),		//i--
      .b(f_mul_ex3_sum_b[144]),		//i--
      .c(f_mul_ex3_car_b[144]),		//i--
      .sum(ex3_sum_b[144]),		//o--
      .car(ex3_car_b[143])		//o--
   );

   tri_csa32 res_csa_145(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[145]),		//i--
      .b(f_mul_ex3_sum_b[145]),		//i--
      .c(f_mul_ex3_car_b[145]),		//i--
      .sum(ex3_sum_b[145]),		//o--
      .car(ex3_car_b[144])		//o--
   );

   tri_csa32 res_csa_146(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[146]),		//i--
      .b(f_mul_ex3_sum_b[146]),		//i--
      .c(f_mul_ex3_car_b[146]),		//i--
      .sum(ex3_sum_b[146]),		//o--
      .car(ex3_car_b[145])		//o--
   );

   tri_csa32 res_csa_147(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[147]),		//i--
      .b(f_mul_ex3_sum_b[147]),		//i--
      .c(f_mul_ex3_car_b[147]),		//i--
      .sum(ex3_sum_b[147]),		//o--
      .car(ex3_car_b[146])		//o--
   );

   tri_csa32 res_csa_148(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[148]),		//i--
      .b(f_mul_ex3_sum_b[148]),		//i--
      .c(f_mul_ex3_car_b[148]),		//i--
      .sum(ex3_sum_b[148]),		//o--
      .car(ex3_car_b[147])		//o--
   );

   tri_csa32 res_csa_149(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[149]),		//i--
      .b(f_mul_ex3_sum_b[149]),		//i--
      .c(f_mul_ex3_car_b[149]),		//i--
      .sum(ex3_sum_b[149]),		//o--
      .car(ex3_car_b[148])		//o--
   );

   tri_csa32 res_csa_150(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[150]),		//i--
      .b(f_mul_ex3_sum_b[150]),		//i--
      .c(f_mul_ex3_car_b[150]),		//i--
      .sum(ex3_sum_b[150]),		//o--
      .car(ex3_car_b[149])		//o--
   );

   tri_csa32 res_csa_151(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[151]),		//i--
      .b(f_mul_ex3_sum_b[151]),		//i--
      .c(f_mul_ex3_car_b[151]),		//i--
      .sum(ex3_sum_b[151]),		//o--
      .car(ex3_car_b[150])		//o--
   );

   tri_csa32 res_csa_152(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[152]),		//i--
      .b(f_mul_ex3_sum_b[152]),		//i--
      .c(f_mul_ex3_car_b[152]),		//i--
      .sum(ex3_sum_b[152]),		//o--
      .car(ex3_car_b[151])		//o--
   );

   tri_csa32 res_csa_153(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[153]),		//i--
      .b(f_mul_ex3_sum_b[153]),		//i--
      .c(f_mul_ex3_car_b[153]),		//i--
      .sum(ex3_sum_b[153]),		//o--
      .car(ex3_car_b[152])		//o--
   );

   tri_csa32 res_csa_154(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[154]),		//i--
      .b(f_mul_ex3_sum_b[154]),		//i--
      .c(f_mul_ex3_car_b[154]),		//i--
      .sum(ex3_sum_b[154]),		//o--
      .car(ex3_car_b[153])		//o--
   );

   tri_csa32 res_csa_155(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[155]),		//i--
      .b(f_mul_ex3_sum_b[155]),		//i--
      .c(f_mul_ex3_car_b[155]),		//i--
      .sum(ex3_sum_b[155]),		//o--
      .car(ex3_car_b[154])		//o--
   );

   tri_csa32 res_csa_156(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[156]),		//i--
      .b(f_mul_ex3_sum_b[156]),		//i--
      .c(f_mul_ex3_car_b[156]),		//i--
      .sum(ex3_sum_b[156]),		//o--
      .car(ex3_car_b[155])		//o--
   );

   tri_csa32 res_csa_157(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[157]),		//i--
      .b(f_mul_ex3_sum_b[157]),		//i--
      .c(f_mul_ex3_car_b[157]),		//i--
      .sum(ex3_sum_b[157]),		//o--
      .car(ex3_car_b[156])		//o--
   );

   tri_csa32 res_csa_158(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[158]),		//i--
      .b(f_mul_ex3_sum_b[158]),		//i--
      .c(f_mul_ex3_car_b[158]),		//i--
      .sum(ex3_sum_b[158]),		//o--
      .car(ex3_car_b[157])		//o--
   );

   tri_csa32 res_csa_159(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[159]),		//i--
      .b(f_mul_ex3_sum_b[159]),		//i--
      .c(f_mul_ex3_car_b[159]),		//i--
      .sum(ex3_sum_b[159]),		//o--
      .car(ex3_car_b[158])		//o--
   );

   tri_csa32 res_csa_160(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[160]),		//i--
      .b(f_mul_ex3_sum_b[160]),		//i--
      .c(f_mul_ex3_car_b[160]),		//i--
      .sum(ex3_sum_b[160]),		//o--
      .car(ex3_car_b[159])		//o--
   );

   tri_csa32 res_csa_161(
      .vd(vdd),
      .gd(gnd),
      .a(f_alg_ex3_res_b[161]),		//i--
      .b(f_mul_ex3_sum_b[161]),		//i--
      .c(f_mul_ex3_car_b[161]),		//i--
      .sum(ex3_sum_b[161]),		//o--
      .car(ex3_car_b[160])		//o--
   );

   assign ex3_sum_b[53] = (~f_alg_ex3_res[53]);
   assign ex3_sum_b[162] = (~f_alg_ex3_res[162]);
   assign ex3_car_b[161] = tiup;

   ////################################################################
   ////# functional latches
   ////################################################################

   // 053:068  : 16sum, 16 carry
   // 069:084
   // 085:100
   // 101:116
   // 117:132
   // 133:148
   // 149:164

   tri_inv_nlats #(.WIDTH(53),  .NEEDS_SRESET(0)) ex4_000_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(sa3_ex4_lclk),		//lclk.clk
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
      .lclk(sa3_ex4_lclk),		//lclk.clk
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
      .lclk(sa3_ex4_lclk),		//lclk.clk
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

   ////################################################################
   ////# pervasive
   ////################################################################


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

   ////################################################################
   ////# act
   ////################################################################

   assign ex2_act = (~ex2_act_b);


   tri_rlmreg_p #(.WIDTH(5), .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),		// tidn,
      .mpw1_b(mpw1_b[2]),		// tidn,
      .mpw2_b(mpw2_b[0]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(fpu_enable),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(act_so),
      .scin(act_si),
      //-----------------
      .din({ act_spare_unused[0],
             act_spare_unused[1],
             ex2_act,
             act_spare_unused[2],
             act_spare_unused[3]}),
      //-----------------
      .dout({act_spare_unused[0],
             act_spare_unused[1],
             ex3_act,
             act_spare_unused[2],
             act_spare_unused[3]})
   );


   tri_lcbnd  sa3_ex4_lcb(
      .delay_lclkr(delay_lclkr[3]),		// tidn ,--in
      .mpw1_b(mpw1_b[3]),		// tidn ,--in
      .mpw2_b(mpw2_b[0]),		// tidn ,--in
      .force_t(force_t),		// tidn ,--in
      .nclk(nclk),		//in
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .act(ex3_act),		//in
      .sg(sg_0),		//in
      .thold_b(thold_0_b),		//in
      .d1clk(sa3_ex4_d1clk),		//out
      .d2clk(sa3_ex4_d2clk),		//out
      .lclk(sa3_ex4_lclk)		//out
   );

   ////################################################################
   ////# scan string
   ////################################################################

   assign ex4_053_car_si[0:108] = {ex4_053_car_so[1:108], f_sa3_si};
   assign ex4_053_sum_si[0:109] = {ex4_053_sum_so[1:109], ex4_053_car_so[0]};
   assign ex4_000_si[0:52] = {ex4_000_so[1:52], ex4_053_sum_so[0]};
   assign act_si[0:4] = {act_so[1:4], ex4_000_so[0]};
   assign f_sa3_so = act_so[0];

endmodule
