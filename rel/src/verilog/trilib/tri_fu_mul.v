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
   

module tri_fu_mul(
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
   f_mul_si,
   f_mul_so,
   ex2_act,
   f_fmt_ex2_a_frac,
   f_fmt_ex2_a_frac_17,
   f_fmt_ex2_a_frac_35,
   f_fmt_ex2_c_frac,
   f_mul_ex3_sum,
   f_mul_ex3_car
);
   
   inout          vdd;
   inout          gnd;
   input          clkoff_b;		
   input          act_dis;		
   input          flush;		
   input          delay_lclkr;		
   input          mpw1_b;		
   input          mpw2_b;		
   input          sg_1;
   input          thold_1;
   input          fpu_enable;		
   input  [0:`NCLK_WIDTH-1]         nclk;
   
   input          f_mul_si;		
   output         f_mul_so;		
   input          ex2_act;		
   
   input [0:52]   f_fmt_ex2_a_frac;		
   input          f_fmt_ex2_a_frac_17;		
   input          f_fmt_ex2_a_frac_35;		
   input [0:53]   f_fmt_ex2_c_frac;		
   
   output [1:108] f_mul_ex3_sum;
   output [1:108] f_mul_ex3_car;
   
   
   
   
   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;
   
   wire           thold_0_b;
   wire           thold_0;
   wire           force_t;
   wire           sg_0;
   wire [0:3]     spare_unused;
   wire [0:3]     act_so;		
   wire [0:3]     act_si;
   wire           m92_0_so;
   wire           m92_1_so;
   wire           m92_2_so;
   wire [36:108]  pp3_05;
   wire [35:108]  pp3_04;
   wire [18:90]   pp3_03;
   wire [17:90]   pp3_02;
   wire [0:72]    pp3_01;
   wire [0:72]    pp3_00;
   
   wire           hot_one_msb_unused;
   wire           hot_one_74;
   wire           hot_one_92;
   wire           xtd_unused;
   
   wire [1:108]   pp5_00;
   wire [1:108]   pp5_01;
   
   
   
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
   
   
   
   tri_rlmreg_p #(.WIDTH(4),  .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),		
      .d_mode(tiup),							
      .delay_lclkr(delay_lclkr),		
      .mpw1_b(mpw1_b),		
      .mpw2_b(mpw2_b),		
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(fpu_enable),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(act_so),
      .scin(act_si),
      .din({ spare_unused[0],
             spare_unused[1],
             spare_unused[2],
             spare_unused[3]}),
      .dout({spare_unused[0],
             spare_unused[1],
             spare_unused[2],
             spare_unused[3]})
   );
   
   assign act_si[0:3] = {act_so[1:3], m92_2_so};
   
   assign f_mul_so = act_so[0];
   
   
   
   
   
   
   tri_fu_mul_92 #(.inst(2)) m92_2(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .force_t(force_t),		
      .lcb_delay_lclkr(delay_lclkr),		
      .lcb_mpw1_b(mpw1_b),		
      .lcb_mpw2_b(mpw2_b),		
      .thold_b(thold_0_b),		
      .lcb_sg(sg_0),		
      .si(f_mul_si),		
      .so(m92_0_so),		
      .ex2_act(ex2_act),		
      .c_frac(f_fmt_ex2_c_frac[0:53]),		
      .a_frac({f_fmt_ex2_a_frac[35:52],		
              tidn}),		
      .hot_one_out(hot_one_92),		
      .sum92(pp3_05[36:108]),		
      .car92(pp3_04[35:108])		
   );
   
   
   tri_fu_mul_92 #(.inst(1)) m92_1(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .force_t(force_t),		
      .lcb_delay_lclkr(delay_lclkr),		
      .lcb_mpw1_b(mpw1_b),		
      .lcb_mpw2_b(mpw2_b),		
      .thold_b(thold_0_b),		
      .lcb_sg(sg_0),		
      .si(m92_0_so),		
      .so(m92_1_so),		
      .ex2_act(ex2_act),		
      .c_frac(f_fmt_ex2_c_frac[0:53]),		
      .a_frac({f_fmt_ex2_a_frac[17:34],		
               f_fmt_ex2_a_frac_35}),		
      .hot_one_out(hot_one_74),		
      .sum92(pp3_03[18:90]),		
      .car92(pp3_02[17:90])		
   );
   
   
   tri_fu_mul_92 #(.inst(0)) m92_0(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .force_t(force_t),		
      .lcb_delay_lclkr(delay_lclkr),		
      .lcb_mpw1_b(mpw1_b),		
      .lcb_mpw2_b(mpw2_b),		
      .thold_b(thold_0_b),		
      .lcb_sg(sg_0),		
      .si(m92_1_so),		
      .so(m92_2_so),		
      .ex2_act(ex2_act),		
      .c_frac(f_fmt_ex2_c_frac[0:53]),		
      .a_frac({tidn,		
               f_fmt_ex2_a_frac[0:16],		
               f_fmt_ex2_a_frac_17}),		
      .hot_one_out(hot_one_msb_unused),		
      .sum92(pp3_01[0:72]),		
      .car92({xtd_unused,		
              pp3_00[0:72]})		
   );
   
   
   
   tri_fu_mul_62 m62(
      .vdd(vdd),
      .gnd(gnd),
      .hot_one_92(hot_one_92),		
      .hot_one_74(hot_one_74),		
      .pp3_05(pp3_05[36:108]),		
      .pp3_04(pp3_04[35:108]),		
      .pp3_03(pp3_03[18:90]),		
      .pp3_02(pp3_02[17:90]),		
      .pp3_01(pp3_01[0:72]),		
      .pp3_00(pp3_00[0:72]),		
      
      .sum62(pp5_01[1:108]),		
      .car62(pp5_00[1:108])		
   );
   
   
   assign f_mul_ex3_sum[1:108] = pp5_01[1:108];		
   assign f_mul_ex3_car[1:108] = pp5_00[1:108];		
   
endmodule
