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

module fu_lza(
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
   f_lza_si,
   f_lza_so,
   ex2_act_b,
   f_sa3_ex4_s,
   f_sa3_ex4_c,
   f_alg_ex3_effsub_eac_b,
   f_lze_ex3_lzo_din,
   f_lze_ex4_sh_rgt_amt,
   f_lze_ex4_sh_rgt_en,
   f_lza_ex5_no_lza_edge,
   f_lza_ex5_lza_amt,
   f_lza_ex5_lza_dcd64_cp1,
   f_lza_ex5_lza_dcd64_cp2,
   f_lza_ex5_lza_dcd64_cp3,
   f_lza_ex5_sh_rgt_en,
   f_lza_ex5_sh_rgt_en_eov,
   f_lza_ex5_lza_amt_eov
);

   inout          vdd;
   inout          gnd;
   input          clkoff_b;		// tiup
   input          act_dis;		// ??tidn??
   input          flush;		// ??tidn??
   input [3:4]    delay_lclkr;		// tidn,
   input [3:4]    mpw1_b;		// tidn,
   input [0:0]    mpw2_b;		// tidn,
   input          sg_1;
   input          thold_1;
   input          fpu_enable;		//dc_act
   input  [0:`NCLK_WIDTH-1]           nclk;

   input          f_lza_si;		//perv
   output         f_lza_so;		//perv
   input          ex2_act_b;		//act

   input [0:162]  f_sa3_ex4_s;		// data
   input [53:161] f_sa3_ex4_c;		// data
   input          f_alg_ex3_effsub_eac_b;

   input [0:162]  f_lze_ex3_lzo_din;
   input [0:7]    f_lze_ex4_sh_rgt_amt;
   input          f_lze_ex4_sh_rgt_en;

   output         f_lza_ex5_no_lza_edge;		//fpic
   output [0:7]   f_lza_ex5_lza_amt;		//fnrm
   output [0:2]   f_lza_ex5_lza_dcd64_cp1;		//fnrm
   output [0:1]   f_lza_ex5_lza_dcd64_cp2;		//fnrm
   output [0:0]   f_lza_ex5_lza_dcd64_cp3;		//fnrm
   output         f_lza_ex5_sh_rgt_en;
   output         f_lza_ex5_sh_rgt_en_eov;
   output [0:7]   f_lza_ex5_lza_amt_eov;		//feov

   // ENTITY


   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;

   wire           thold_0_b;
   wire           thold_0;
   wire           force_t;
   wire           sg_0;
   wire           ex3_act;
   wire           ex4_act;
   wire           ex2_act;
   (* analysis_not_referenced="TRUE" *)
   wire [0:3]     act_spare_unused;
   //--------------------------------------
   wire [0:5]     act_so;		//SCAN
   wire [0:5]     act_si;		//SCAN
   wire [0:162]   ex4_lzo_so;		//SCAN
   wire [0:162]   ex4_lzo_si;		//SCAN
   wire [0:0]     ex4_sub_so;		//SCAN
   wire [0:0]     ex4_sub_si;		//SCAN
   wire [0:15]    ex5_amt_so;		//SCAN
   wire [0:15]    ex5_amt_si;		//SCAN
   wire [0:8]     ex5_dcd_so;		//SCAN
   wire [0:8]     ex5_dcd_si;		//SCAN
   //--------------------------------------
   wire           ex4_lza_any_b;
   wire           ex4_effsub;
   wire           ex5_no_edge;
   wire           ex4_no_edge_b;
   wire [0:162]   ex4_lzo;
   wire [0:7]     ex4_lza_amt_b;
   wire [0:7]     ex5_amt_eov;
   wire [0:7]     ex5_amt;
   wire [0:162]   ex4_sum;
   wire [53:162]  ex4_car;
   wire [0:162]   ex4_lv0_or;
   wire           ex4_sh_rgt_en_b;
   wire           ex4_lv6_or_0_b;
   wire           ex4_lv6_or_1_b;
   wire           ex4_lv6_or_0_t;
   wire           ex4_lv6_or_1_t;
   wire           ex4_lza_dcd64_0_b;
   wire           ex4_lza_dcd64_1_b;
   wire           ex4_lza_dcd64_2_b;
   wire [0:2]     ex5_lza_dcd64_cp1;
   wire [0:1]     ex5_lza_dcd64_cp2;
   wire [0:0]     ex5_lza_dcd64_cp3;
   wire           ex5_sh_rgt_en;
   wire           ex5_sh_rgt_en_eov;
   wire           ex3_effsub_eac;
   wire           ex3_effsub_eac_b;
   wire [0:162]   ex4_lzo_b;
   wire [0:162]   ex4_lzo_l2_b;
   wire           ex4_lv6_or_0;
   wire           ex4_lv6_or_1;
   wire [0:7]     ex4_rgt_amt_b;
   wire           lza_ex5_d1clk;
   wire           lza_ex5_d2clk;
   wire           lza_ex4_d1clk;
   wire           lza_ex4_d2clk;
   wire  [0:`NCLK_WIDTH-1]           lza_ex5_lclk;
   wire  [0:`NCLK_WIDTH-1]           lza_ex4_lclk;

   //=###############################################################
   //= map block attributes
   //=###############################################################

   //=###############################################################
   //= pervasive
   //=###############################################################


   tri_plat thold_reg_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(flush),
      .din(thold_1),
      .q(thold_0)
   );


   tri_plat sg_reg_0(
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

   //=###############################################################
   //= act
   //=###############################################################

   assign ex2_act = (~ex2_act_b);


   tri_rlmreg_p #(.WIDTH(6),  .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),		//i-- tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),		//i-- tidn,
      .mpw1_b(mpw1_b[3]),		//i-- tidn,
      .mpw2_b(mpw2_b[0]),		//i-- tidn,
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
             ex3_act,
             act_spare_unused[2],
             act_spare_unused[3]}),
      //-----------------
      .dout({ act_spare_unused[0],
              act_spare_unused[1],
              ex3_act,
              ex4_act,
              act_spare_unused[2],
              act_spare_unused[3]})
   );


   tri_lcbnd  lza_ex4_lcb(
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
      .d1clk(lza_ex4_d1clk),		//out
      .d2clk(lza_ex4_d2clk),		//out
      .lclk(lza_ex4_lclk)		//out
   );


   tri_lcbnd  lza_ex5_lcb(
      .delay_lclkr(delay_lclkr[4]),		// tidn ,--in
      .mpw1_b(mpw1_b[4]),		// tidn ,--in
      .mpw2_b(mpw2_b[0]),		// tidn ,--in
      .force_t(force_t),		// tidn ,--in
      .nclk(nclk),		//in
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .act(ex4_act),		//in
      .sg(sg_0),		//in
      .thold_b(thold_0_b),		//in
      .d1clk(lza_ex5_d1clk),		//out
      .d2clk(lza_ex5_d2clk),		//out
      .lclk(lza_ex5_lclk)		//out
   );

   //=###############################################################
   //= ex4 latches
   //=###############################################################


   tri_inv_nlats #(.WIDTH(163),  .NEEDS_SRESET(0)) ex4_lzo_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(lza_ex4_lclk),		// lclk.clk
      .d1clk(lza_ex4_d1clk),
      .d2clk(lza_ex4_d2clk),
      .scanin(ex4_lzo_si),
      .scanout(ex4_lzo_so),
      .d(f_lze_ex3_lzo_din[0:162]),
      .qb(ex4_lzo_l2_b[0:162])
   );

   assign ex4_lzo[0:162] = (~ex4_lzo_l2_b[0:162]);
   assign ex4_lzo_b[0:162] = (~ex4_lzo[0:162]);

   assign ex3_effsub_eac = (~f_alg_ex3_effsub_eac_b);
   assign ex3_effsub_eac_b = (~ex3_effsub_eac);


   tri_inv_nlats #(.WIDTH(1),  .NEEDS_SRESET(0)) ex4_sub_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(lza_ex4_lclk),		// lclk.clk
      .d1clk(lza_ex4_d1clk),
      .d2clk(lza_ex4_d2clk),
      .scanin(ex4_sub_si[0]),
      .scanout(ex4_sub_so[0]),
      .d(ex3_effsub_eac_b),
      .qb(ex4_effsub)
   );

   assign ex4_sum[0:52] = f_sa3_ex4_s[0:52];

   //=###############################################################
   //= ex4 logic
   //=###############################################################

   assign ex4_sum[53:162] = f_sa3_ex4_s[53:162];
   assign ex4_car[53:162] = {f_sa3_ex4_c[53:161], tidn};

   //=#------------------------------------------------
   //=#-- EDGE DETECTION
   //=#------------------------------------------------


   fu_lza_ej lzaej(
      .effsub(ex4_effsub),		//i--
      .sum(ex4_sum[0:162]),		//i--
      .car(ex4_car[53:162]),		//i--
      .lzo_b(ex4_lzo_b[0:162]),		//i--
      .edge_t(ex4_lv0_or[0:162])		//o--
   );

   //=#------------------------------------------------
   //=#-- ENCODING TREE (CLZ) count leading zeroes
   //=#------------------------------------------------


   fu_lza_clz lzaclz(
      .lv0_or(ex4_lv0_or[0:162]),		//i--
      .lv6_or_0(ex4_lv6_or_0),		//o--
      .lv6_or_1(ex4_lv6_or_1),		//o--
      .lza_any_b(ex4_lza_any_b),		//i--
      .lza_amt_b(ex4_lza_amt_b[0:7])		//o--
   );

   assign ex4_no_edge_b = (~ex4_lza_any_b);

   //=###############################################################
   //= ex5 latches
   //=###############################################################

   assign ex4_rgt_amt_b[0:7] = (~f_lze_ex4_sh_rgt_amt[0:7]);

   assign ex4_sh_rgt_en_b = (~f_lze_ex4_sh_rgt_en);

   assign ex4_lv6_or_0_b = (~ex4_lv6_or_0);
   assign ex4_lv6_or_1_b = (~ex4_lv6_or_1);
   assign ex4_lv6_or_0_t = (~ex4_lv6_or_0_b);
   assign ex4_lv6_or_1_t = (~ex4_lv6_or_1_b);

   assign ex4_lza_dcd64_0_b = (~(ex4_lv6_or_0_t & ex4_sh_rgt_en_b));
   assign ex4_lza_dcd64_1_b = (~(ex4_lv6_or_0_b & ex4_lv6_or_1_t & ex4_sh_rgt_en_b));
   assign ex4_lza_dcd64_2_b = (~(ex4_lv6_or_0_b & ex4_lv6_or_1_b & ex4_sh_rgt_en_b));

   tri_inv_nlats #(.WIDTH(9),   .NEEDS_SRESET(0)) ex5_dcd_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(lza_ex5_lclk),		// lclk.clk
      .d1clk(lza_ex5_d1clk),
      .d2clk(lza_ex5_d2clk),
      .scanin(ex5_dcd_si[0:8]),
      .scanout(ex5_dcd_so[0:8]),
      .d({ex4_lza_dcd64_0_b,		//( 0)
           ex4_lza_dcd64_0_b,		//( 1)
           ex4_lza_dcd64_0_b,		//( 2)
           ex4_lza_dcd64_1_b,		//( 3)
           ex4_lza_dcd64_1_b,		//( 4)
           ex4_lza_dcd64_2_b,		//( 5)
           ex4_sh_rgt_en_b,		//( 6)
           ex4_sh_rgt_en_b,		//( 7)
           ex4_no_edge_b}),		//(24)
      //-----------------
      .qb({ex5_lza_dcd64_cp1[0],		//( 6)
           ex5_lza_dcd64_cp2[0],		//( 9)
           ex5_lza_dcd64_cp3[0],		//( 1)
           ex5_lza_dcd64_cp1[1],		//( 7)
           ex5_lza_dcd64_cp2[1],		//( 0)
           ex5_lza_dcd64_cp1[2],		//( 8)
           ex5_sh_rgt_en,		//( 2)
           ex5_sh_rgt_en_eov,		//( 3)
           ex5_no_edge})		//(24)
   );


   tri_nand2_nlats #(.WIDTH(16),   .NEEDS_SRESET(0)) ex5_amt_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(lza_ex5_lclk),		//in   --lclk.clk
      .d1clk(lza_ex5_d1clk),		//in
      .d2clk(lza_ex5_d2clk),		//in
      .scanin(ex5_amt_si[0:15]),
      .scanout(ex5_amt_so[0:15]),
      .a1({  ex4_lza_amt_b[0],		//( 8)
             ex4_lza_amt_b[0],		//( 9)
             ex4_lza_amt_b[1],		//(10)
             ex4_lza_amt_b[1],		//(11)
             ex4_lza_amt_b[2],		//(12)
             ex4_lza_amt_b[2],		//(13)
             ex4_lza_amt_b[3],		//(14)
             ex4_lza_amt_b[3],		//(15)
             ex4_lza_amt_b[4],		//(16)
             ex4_lza_amt_b[4],		//(17)
             ex4_lza_amt_b[5],		//(18)
             ex4_lza_amt_b[5],		//(19)
             ex4_lza_amt_b[6],		//(20)
             ex4_lza_amt_b[6],		//(21)
             ex4_lza_amt_b[7],		//(22)
             ex4_lza_amt_b[7]}),		//(23)

      .a2({  ex4_rgt_amt_b[0],		//( 8)
             ex4_rgt_amt_b[0],		//( 9)
             ex4_rgt_amt_b[1],		//(10)
             ex4_rgt_amt_b[1],		//(11)
             ex4_rgt_amt_b[2],		//(12)
             ex4_rgt_amt_b[2],		//(13)
             ex4_rgt_amt_b[3],		//(14)
             ex4_rgt_amt_b[3],		//(15)
             ex4_rgt_amt_b[4],		//(16)
             ex4_rgt_amt_b[4],		//(17)
             ex4_rgt_amt_b[5],		//(18)
             ex4_rgt_amt_b[5],		//(19)
             ex4_rgt_amt_b[6],		//(20)
             ex4_rgt_amt_b[6],		//(21)
             ex4_rgt_amt_b[7],		//(22)
             ex4_rgt_amt_b[7] }),		//(23)

      //-----------------
      .qb({  ex5_amt[0],		//( 0)
             ex5_amt_eov[0],		//( 8)
             ex5_amt[1],		//(11)
             ex5_amt_eov[1],		//(19)
             ex5_amt[2],		//(12)
             ex5_amt_eov[2],		//(10)
             ex5_amt[3],		//(13)
             ex5_amt_eov[3],		//(11)
             ex5_amt[4],		//(14)
             ex5_amt_eov[4],		//(12)
             ex5_amt[5],		//(15)
             ex5_amt_eov[5],		//(13)
             ex5_amt[6],		//(26)
             ex5_amt_eov[6],		//(24)
             ex5_amt[7],		//(27)
             ex5_amt_eov[7]})		//(24)
   );

   assign f_lza_ex5_sh_rgt_en = ex5_sh_rgt_en;
   assign f_lza_ex5_sh_rgt_en_eov = ex5_sh_rgt_en_eov;

   assign f_lza_ex5_lza_amt = ex5_amt[0:7];		//output-- --fnrm--

   assign f_lza_ex5_lza_dcd64_cp1[0:2] = ex5_lza_dcd64_cp1[0:2];		//ouptut-- --fnrm
   assign f_lza_ex5_lza_dcd64_cp2[0:1] = ex5_lza_dcd64_cp2[0:1];		//ouptut-- --fnrm
   assign f_lza_ex5_lza_dcd64_cp3[0] = ex5_lza_dcd64_cp3[0];		//ouptut-- --fnrm

   assign f_lza_ex5_lza_amt_eov = ex5_amt_eov[0:7];		//output-- --feov--
   assign f_lza_ex5_no_lza_edge = ex5_no_edge;		//output-- --fpic--

   //=###############################################################
   //= scan string
   //=###############################################################

   assign ex4_lzo_si[0:162] = {ex4_lzo_so[1:162], f_lza_si};
   assign ex4_sub_si[0] = ex4_lzo_so[0];
   assign ex5_amt_si[0:15] = {ex5_amt_so[1:15], ex4_sub_so[0]};
   assign ex5_dcd_si[0:8] = {ex5_dcd_so[1:8], ex5_amt_so[0]};
   assign act_si[0:5] = {act_so[1:5], ex5_dcd_so[0]};
   assign f_lza_so = act_so[0];

endmodule
