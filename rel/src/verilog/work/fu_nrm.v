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
   

module fu_nrm(
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
   f_nrm_si,
   f_nrm_so,
   ex4_act_b,
   f_lza_ex5_lza_amt_cp1,
   f_lza_ex5_lza_dcd64_cp1,
   f_lza_ex5_lza_dcd64_cp2,
   f_lza_ex5_lza_dcd64_cp3,
   f_lza_ex5_sh_rgt_en,
   f_add_ex5_res,
   f_add_ex5_sticky,
   f_pic_ex5_byp_prod_nz,
   f_nrm_ex6_res,
   f_nrm_ex6_int_sign,
   f_nrm_ex6_int_lsbs,
   f_nrm_ex6_nrm_sticky_dp,
   f_nrm_ex6_nrm_guard_dp,
   f_nrm_ex6_nrm_lsb_dp,
   f_nrm_ex6_nrm_sticky_sp,
   f_nrm_ex6_nrm_guard_sp,
   f_nrm_ex6_nrm_lsb_sp,
   f_nrm_ex6_exact_zero,
   f_nrm_ex5_extra_shift,
   f_nrm_ex6_fpscr_wr_dat_dfp,
   f_nrm_ex6_fpscr_wr_dat
);
   
   inout         vdd;
   inout         gnd;
   input         clkoff_b;		
   input         act_dis;		
   input         flush;		
   input [4:5]   delay_lclkr;		
   input [4:5]   mpw1_b;		
   input [0:1]   mpw2_b;		
   input         sg_1;
   input         thold_1;
   input         fpu_enable;		
   input  [0:`NCLK_WIDTH-1]         nclk;
   
   input         f_nrm_si;		
   output        f_nrm_so;		
   input         ex4_act_b;		
   
   input [0:7]   f_lza_ex5_lza_amt_cp1;		
   
   input [0:2]   f_lza_ex5_lza_dcd64_cp1;		
   input [0:1]   f_lza_ex5_lza_dcd64_cp2;		
   input [0:0]   f_lza_ex5_lza_dcd64_cp3;		
   input         f_lza_ex5_sh_rgt_en;
   
   input [0:162] f_add_ex5_res;		
   input         f_add_ex5_sticky;		
   input         f_pic_ex5_byp_prod_nz;
   output [0:52] f_nrm_ex6_res;		
   output        f_nrm_ex6_int_sign;		
   output [1:12] f_nrm_ex6_int_lsbs;		
   output        f_nrm_ex6_nrm_sticky_dp;		
   output        f_nrm_ex6_nrm_guard_dp;		
   output        f_nrm_ex6_nrm_lsb_dp;		
   output        f_nrm_ex6_nrm_sticky_sp;		
   output        f_nrm_ex6_nrm_guard_sp;		
   output        f_nrm_ex6_nrm_lsb_sp;		
   output        f_nrm_ex6_exact_zero;		
   output        f_nrm_ex5_extra_shift;		
   output [0:3]  f_nrm_ex6_fpscr_wr_dat_dfp;		
   output [0:31] f_nrm_ex6_fpscr_wr_dat;		
   
   
   
   
   
   
   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;
   
   wire          sg_0;		
   wire          thold_0_b;		
   wire          thold_0;
   wire          force_t;
   wire          ex4_act;		
   wire          ex5_act;		
   wire [0:2]    act_spare_unused;		
   wire [0:3]    act_so;		
   wire [0:3]    act_si;		
   wire [0:52]   ex6_res_so;		
   wire [0:52]   ex6_res_si;		
   wire [0:3]    ex6_nrm_lg_so;		
   wire [0:3]    ex6_nrm_lg_si;		
   wire [0:2]    ex6_nrm_x_so;		
   wire [0:2]    ex6_nrm_x_si;		
   wire [0:12]   ex6_nrm_pass_so;		
   wire [0:12]   ex6_nrm_pass_si;		
   wire [0:35]   ex6_fmv_so;		
   wire [0:35]   ex6_fmv_si;		
   wire [26:72]  ex5_sh2;
   wire          ex5_sh4_25;		
   wire          ex5_sh4_54;		
   wire [0:53]   ex5_nrm_res;		
   wire [0:53]   ex5_sh5_x_b;
   wire [0:53]   ex5_sh5_y_b;
   wire          ex5_lt064_x;		
   wire          ex5_lt128_x;		
   wire          ex5_lt016_x;		
   wire          ex5_lt032_x;		
   wire          ex5_lt048_x;		
   wire          ex5_lt016;		
   wire          ex5_lt032;		
   wire          ex5_lt048;		
   wire          ex5_lt064;		
   wire          ex5_lt080;		
   wire          ex5_lt096;		
   wire          ex5_lt112;		
   wire          ex5_lt128;		
   wire          ex5_lt04_x;		
   wire          ex5_lt08_x;		
   wire          ex5_lt12_x;		
   wire          ex5_lt01_x;		
   wire          ex5_lt02_x;		
   wire          ex5_lt03_x;		
   wire          ex5_sticky_sp;		
   wire          ex5_sticky_dp;		
   wire          ex5_sticky16_dp;		
   wire          ex5_sticky16_sp;		
   wire [0:10]   ex5_or_grp16;		
   wire [0:14]   ex5_lt;		
   wire          ex5_exact_zero;		
   wire          ex5_exact_zero_b;		
   wire [0:52]   ex6_res;		
   wire          ex6_nrm_sticky_dp;
   wire          ex6_nrm_guard_dp;
   wire          ex6_nrm_lsb_dp;
   wire          ex6_nrm_sticky_sp;
   wire          ex6_nrm_guard_sp;
   wire          ex6_nrm_lsb_sp;
   wire          ex6_exact_zero;
   wire          ex6_int_sign;
   wire [1:12]   ex6_int_lsbs;
   wire [0:31]   ex6_fpscr_wr_dat;
   wire [0:3]    ex6_fpscr_wr_dat_dfp;
   wire          ex5_rgt_4more;
   wire          ex5_rgt_3more;
   wire          ex5_rgt_2more;
   wire          ex5_shift_extra_cp2;
   wire          unused;
   
   wire          ex5_sticky_dp_x2_b;
   wire          ex5_sticky_dp_x1_b;
   wire          ex5_sticky_dp_x1;
   wire          ex5_sticky_sp_x2_b;
   wire          ex5_sticky_sp_x1_b;
   wire          ex5_sticky_sp_x1;
   wire          ex6_d1clk;		
   wire          ex6_d2clk;
   wire  [0:`NCLK_WIDTH-1]          ex6_lclk;		
   wire          ex5_sticky_stuff;
   
   assign unused = |(ex5_sh2[41:54]) | |(ex5_nrm_res[0:53]) | ex5_sticky_sp | ex5_sticky_dp | ex5_exact_zero;		
   
   
   
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
   
   tri_lcbnd  ex6_lcb(
      .delay_lclkr(delay_lclkr[5]),		
      .mpw1_b(mpw1_b[5]),		
      .mpw2_b(mpw2_b[1]),		
      .force_t(force_t),		
      .nclk(nclk),		
      .vd(vdd),		
      .gd(gnd),		
      .act(ex5_act),		
      .sg(sg_0),		
      .thold_b(thold_0_b),		
      .d1clk(ex6_d1clk),		
      .d2clk(ex6_d2clk),		
      .lclk(ex6_lclk)		
   );
   
   
   assign ex4_act = (~ex4_act_b);
   
   
   tri_rlmreg_p #(.WIDTH(4),  .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),		
      .d_mode(tiup),							
      .delay_lclkr(delay_lclkr[4]),		
      .mpw1_b(mpw1_b[4]),		
      .mpw2_b(mpw2_b[0]),		
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(fpu_enable),
      .scout(act_so[0:3]),
      .scin(act_si[0:3]),
      .din({  act_spare_unused[0],
              act_spare_unused[1],
              ex4_act,
              act_spare_unused[2]}),
      .dout({  act_spare_unused[0],
               act_spare_unused[1],
               ex5_act,
               act_spare_unused[2]})
   );
   
   
   
   fu_nrm_sh  sh(
      .f_lza_ex5_sh_rgt_en(f_lza_ex5_sh_rgt_en),		
      .f_lza_ex5_lza_amt_cp1(f_lza_ex5_lza_amt_cp1[2:7]),		
      .f_lza_ex5_lza_dcd64_cp1(f_lza_ex5_lza_dcd64_cp1[0:2]),		
      .f_lza_ex5_lza_dcd64_cp2(f_lza_ex5_lza_dcd64_cp2[0:1]),		
      .f_lza_ex5_lza_dcd64_cp3(f_lza_ex5_lza_dcd64_cp3[0:0]),		
      .f_add_ex5_res(f_add_ex5_res[0:162]),		
      .ex5_shift_extra_cp1(f_nrm_ex5_extra_shift),		
      .ex5_shift_extra_cp2(ex5_shift_extra_cp2),		
      .ex5_sh4_25(ex5_sh4_25),		
      .ex5_sh4_54(ex5_sh4_54),		
      .ex5_sh2_o(ex5_sh2[26:72]),		
      .ex5_sh5_x_b(ex5_sh5_x_b[0:53]),		
      .ex5_sh5_y_b(ex5_sh5_y_b[0:53])		
   );
   
   assign ex5_nrm_res[0:53] = (~(ex5_sh5_x_b[0:53] & ex5_sh5_y_b[0:53]));		
   
   
   
   assign ex5_lt064_x = (~(f_lza_ex5_lza_amt_cp1[0] | f_lza_ex5_lza_amt_cp1[1]));		
   assign ex5_lt128_x = (~(f_lza_ex5_lza_amt_cp1[0]));		
   
   assign ex5_lt016_x = (~(f_lza_ex5_lza_amt_cp1[2] | f_lza_ex5_lza_amt_cp1[3]));		
   assign ex5_lt032_x = (~(f_lza_ex5_lza_amt_cp1[2]));		
   assign ex5_lt048_x = (~(f_lza_ex5_lza_amt_cp1[2] & f_lza_ex5_lza_amt_cp1[3]));		
   
   assign ex5_lt016 = ex5_lt064_x & ex5_lt016_x;		
   assign ex5_lt032 = ex5_lt064_x & ex5_lt032_x;		
   assign ex5_lt048 = ex5_lt064_x & ex5_lt048_x;		
   assign ex5_lt064 = ex5_lt064_x;		
   assign ex5_lt080 = ex5_lt064_x | (ex5_lt128_x & ex5_lt016_x);		
   assign ex5_lt096 = ex5_lt064_x | (ex5_lt128_x & ex5_lt032_x);		
   assign ex5_lt112 = ex5_lt064_x | (ex5_lt128_x & ex5_lt048_x);		
   assign ex5_lt128 = ex5_lt128_x;		
   
   
   
   assign ex5_rgt_2more = f_lza_ex5_sh_rgt_en & ((~f_lza_ex5_lza_amt_cp1[2]) | (~f_lza_ex5_lza_amt_cp1[3]));		
   assign ex5_rgt_3more = f_lza_ex5_sh_rgt_en & ((~f_lza_ex5_lza_amt_cp1[2]));		
   assign ex5_rgt_4more = f_lza_ex5_sh_rgt_en & ((~f_lza_ex5_lza_amt_cp1[2]) & (~f_lza_ex5_lza_amt_cp1[3]));		
   
   
   
   fu_nrm_or16  or16(
      .f_add_ex5_res(f_add_ex5_res[0:162]),		
      .ex5_or_grp16(ex5_or_grp16[0:10])		
   );
   
   
   
   assign ex5_sticky_stuff = (f_pic_ex5_byp_prod_nz) | (f_add_ex5_sticky);
   
   assign ex5_sticky16_dp = (ex5_or_grp16[1] & ex5_rgt_4more) | (ex5_or_grp16[2] & ex5_rgt_3more) | (ex5_or_grp16[3] & ex5_rgt_2more) | (ex5_or_grp16[4] & f_lza_ex5_sh_rgt_en) | (ex5_or_grp16[5] & (ex5_lt016 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[6] & (ex5_lt032 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[7] & (ex5_lt048 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[8] & (ex5_lt064 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[9] & (ex5_lt080 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[10] & (ex5_lt096 | f_lza_ex5_sh_rgt_en)) | (ex5_sh2[70]) | (ex5_sh2[71]) | (ex5_sh2[72]) | (ex5_sticky_stuff);		
   
   assign ex5_sticky16_sp = (ex5_or_grp16[0] & ex5_rgt_3more) | (ex5_or_grp16[1] & ex5_rgt_2more) | (ex5_or_grp16[2] & f_lza_ex5_sh_rgt_en) | (ex5_or_grp16[3] & (ex5_lt016 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[4] & (ex5_lt032 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[5] & (ex5_lt048 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[6] & (ex5_lt064 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[7] & (ex5_lt080 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[8] & (ex5_lt096 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[9] & (ex5_lt112 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[10] & (ex5_lt128 | f_lza_ex5_sh_rgt_en)) | (ex5_sticky_stuff);		
   
   assign ex5_exact_zero_b = ex5_or_grp16[0] | ex5_or_grp16[1] | ex5_or_grp16[2] | ex5_or_grp16[3] | ex5_or_grp16[4] | ex5_or_grp16[5] | ex5_or_grp16[6] | ex5_or_grp16[7] | ex5_or_grp16[8] | ex5_or_grp16[9] | ex5_or_grp16[10] | (ex5_sticky_stuff);
   
   assign ex5_exact_zero = (~ex5_exact_zero_b);
   
   
   assign ex5_lt04_x = (~(f_lza_ex5_lza_amt_cp1[4] | f_lza_ex5_lza_amt_cp1[5]));		
   assign ex5_lt08_x = (~(f_lza_ex5_lza_amt_cp1[4]));		
   assign ex5_lt12_x = (~(f_lza_ex5_lza_amt_cp1[4] & f_lza_ex5_lza_amt_cp1[5]));		
   
   assign ex5_lt01_x = (~(f_lza_ex5_lza_amt_cp1[6] | f_lza_ex5_lza_amt_cp1[7]));		
   assign ex5_lt02_x = (~(f_lza_ex5_lza_amt_cp1[6]));		
   assign ex5_lt03_x = (~(f_lza_ex5_lza_amt_cp1[6] & f_lza_ex5_lza_amt_cp1[7]));		
   
   assign ex5_lt[0] = ex5_lt04_x & ex5_lt01_x;		
   assign ex5_lt[1] = ex5_lt04_x & ex5_lt02_x;		
   assign ex5_lt[2] = ex5_lt04_x & ex5_lt03_x;		
   assign ex5_lt[3] = ex5_lt04_x;		
   
   assign ex5_lt[4] = ex5_lt04_x | (ex5_lt08_x & ex5_lt01_x);		
   assign ex5_lt[5] = ex5_lt04_x | (ex5_lt08_x & ex5_lt02_x);		
   assign ex5_lt[6] = ex5_lt04_x | (ex5_lt08_x & ex5_lt03_x);		
   assign ex5_lt[7] = (ex5_lt08_x);		
   
   assign ex5_lt[8] = ex5_lt08_x | (ex5_lt12_x & ex5_lt01_x);		
   assign ex5_lt[9] = ex5_lt08_x | (ex5_lt12_x & ex5_lt02_x);		
   assign ex5_lt[10] = ex5_lt08_x | (ex5_lt12_x & ex5_lt03_x);		
   assign ex5_lt[11] = (ex5_lt12_x);		
   
   assign ex5_lt[12] = ex5_lt12_x | ex5_lt01_x;		
   assign ex5_lt[13] = ex5_lt12_x | ex5_lt02_x;		
   assign ex5_lt[14] = ex5_lt12_x | ex5_lt03_x;		
   
   
   assign ex5_sticky_sp_x1 = (ex5_lt[14] & ex5_sh2[40]) | (ex5_lt[13] & ex5_sh2[39]) | (ex5_lt[12] & ex5_sh2[38]) | (ex5_lt[11] & ex5_sh2[37]) | (ex5_lt[10] & ex5_sh2[36]) | (ex5_lt[9] & ex5_sh2[35]) | (ex5_lt[8] & ex5_sh2[34]) | (ex5_lt[7] & ex5_sh2[33]) | (ex5_lt[6] & ex5_sh2[32]) | (ex5_lt[5] & ex5_sh2[31]) | (ex5_lt[4] & ex5_sh2[30]) | (ex5_lt[3] & ex5_sh2[29]) | (ex5_lt[2] & ex5_sh2[28]) | (ex5_lt[1] & ex5_sh2[27]) | (ex5_lt[0] & ex5_sh2[26]) | (ex5_sticky16_sp);		
   
   assign ex5_sticky_sp_x2_b = (~((~ex5_shift_extra_cp2) & ex5_sh4_25));
   assign ex5_sticky_sp_x1_b = (~ex5_sticky_sp_x1);
   assign ex5_sticky_sp = (~(ex5_sticky_sp_x1_b & ex5_sticky_sp_x2_b));
   
   assign ex5_sticky_dp_x1 = (ex5_lt[14] & ex5_sh2[69]) | (ex5_lt[13] & ex5_sh2[68]) | (ex5_lt[12] & ex5_sh2[67]) | (ex5_lt[11] & ex5_sh2[66]) | (ex5_lt[10] & ex5_sh2[65]) | (ex5_lt[9] & ex5_sh2[64]) | (ex5_lt[8] & ex5_sh2[63]) | (ex5_lt[7] & ex5_sh2[62]) | (ex5_lt[6] & ex5_sh2[61]) | (ex5_lt[5] & ex5_sh2[60]) | (ex5_lt[4] & ex5_sh2[59]) | (ex5_lt[3] & ex5_sh2[58]) | (ex5_lt[2] & ex5_sh2[57]) | (ex5_lt[1] & ex5_sh2[56]) | (ex5_lt[0] & ex5_sh2[55]) | (ex5_sticky16_dp);		
   
   assign ex5_sticky_dp_x2_b = (~((~ex5_shift_extra_cp2) & ex5_sh4_54));
   assign ex5_sticky_dp_x1_b = (~ex5_sticky_dp_x1);
   assign ex5_sticky_dp = (~(ex5_sticky_dp_x1_b & ex5_sticky_dp_x2_b));
   
   
   
   tri_nand2_nlats #(.WIDTH(53),  .NEEDS_SRESET(0)) ex6_res_lat(  
      .vd(vdd),
      .gd(gnd),								  
      .lclk(ex6_lclk),		
      .d1clk(ex6_d1clk),
      .d2clk(ex6_d2clk),
      .scanin(ex6_res_si),
      .scanout(ex6_res_so),
      .a1(ex5_sh5_x_b[0:52]),
      .a2(ex5_sh5_y_b[0:52]),
      .qb(ex6_res[0:52])		
   );
   
   tri_nand2_nlats #(.WIDTH(4),  .NEEDS_SRESET(0)) ex6_nrm_lg_lat( 
      .vd(vdd),
      .gd(gnd),								  
      .lclk(ex6_lclk),		
      .d1clk(ex6_d1clk),
      .d2clk(ex6_d2clk),
      .scanin(ex6_nrm_lg_si),
      .scanout(ex6_nrm_lg_so),
      .a1({ex5_sh5_x_b[23],
           ex5_sh5_x_b[24],
           ex5_sh5_x_b[52],
           ex5_sh5_x_b[53]}),
      .a2({ex5_sh5_y_b[23],
           ex5_sh5_y_b[24],
           ex5_sh5_y_b[52],
           ex5_sh5_y_b[53]}),
      .qb({ex6_nrm_lsb_sp,		
           ex6_nrm_guard_sp,		
           ex6_nrm_lsb_dp,		
           ex6_nrm_guard_dp})		
   );
   
   tri_nand2_nlats #(.WIDTH(3),   .NEEDS_SRESET(0)) ex6_nrm_x_lat( 
      .vd(vdd),
      .gd(gnd),								  
      .lclk(ex6_lclk),		
      .d1clk(ex6_d1clk),
      .d2clk(ex6_d2clk),
      .scanin(ex6_nrm_x_si),
      .scanout(ex6_nrm_x_so),
      .a1({ ex5_sticky_sp_x2_b,
            ex5_sticky_dp_x2_b,
            ex5_exact_zero_b}),
      .a2({ ex5_sticky_sp_x1_b,
            ex5_sticky_dp_x1_b,
            tiup}),
      .qb({ ex6_nrm_sticky_sp,		
            ex6_nrm_sticky_dp,		
            ex6_exact_zero})		
   );
   
   
   tri_rlmreg_p #(.WIDTH(13),  .IBUF(1'B1), .NEEDS_SRESET(0)) ex6_nrm_pass_lat(
      .force_t(force_t),		
      .d_mode(tiup),								       
      .delay_lclkr(delay_lclkr[5]),		
      .mpw1_b(mpw1_b[5]),		
      .mpw2_b(mpw2_b[1]),		
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex5_act),
      .scout(ex6_nrm_pass_so),
      .scin(ex6_nrm_pass_si),
      .din({f_add_ex5_res[99],
            f_add_ex5_res[151:162]}),		
      .dout({ex6_int_sign,		
             ex6_int_lsbs[1:12]})		
   );
   
   
   tri_rlmreg_p #(.WIDTH(36), .IBUF(1'B1), .NEEDS_SRESET(1)) ex6_fmv_lat(
      .force_t(force_t),		
      .d_mode(tiup),									 
      .delay_lclkr(delay_lclkr[5]),		
      .mpw1_b(mpw1_b[5]),		
      .mpw2_b(mpw2_b[1]),		
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex5_act),
      .scout(ex6_fmv_so),
      .scin(ex6_fmv_si),
      .din(f_add_ex5_res[17:52]),		
      .dout({ex6_fpscr_wr_dat_dfp[0:3],
             ex6_fpscr_wr_dat[0:31]})		
   );
   
   assign f_nrm_ex6_res = ex6_res[0:52];		
   assign f_nrm_ex6_nrm_lsb_sp = ex6_nrm_lsb_sp;		
   assign f_nrm_ex6_nrm_guard_sp = ex6_nrm_guard_sp;		
   assign f_nrm_ex6_nrm_sticky_sp = ex6_nrm_sticky_sp;		
   assign f_nrm_ex6_nrm_lsb_dp = ex6_nrm_lsb_dp;		
   assign f_nrm_ex6_nrm_guard_dp = ex6_nrm_guard_dp;		
   assign f_nrm_ex6_nrm_sticky_dp = ex6_nrm_sticky_dp;		
   assign f_nrm_ex6_exact_zero = ex6_exact_zero;		
   assign f_nrm_ex6_int_lsbs = ex6_int_lsbs[1:12];		
   assign f_nrm_ex6_fpscr_wr_dat = ex6_fpscr_wr_dat[0:31];		
   assign f_nrm_ex6_fpscr_wr_dat_dfp = ex6_fpscr_wr_dat_dfp[0:3];		
   assign f_nrm_ex6_int_sign = ex6_int_sign;		
   
   
   assign act_si[0:3] = {act_so[1:3], f_nrm_si};
   assign ex6_res_si[0:52] = {ex6_res_so[1:52], act_so[0]};
   assign ex6_nrm_lg_si[0:3] = {ex6_nrm_lg_so[1:3], ex6_res_so[0]};
   assign ex6_nrm_x_si[0:2] = {ex6_nrm_x_so[1:2], ex6_nrm_lg_so[0]};
   assign ex6_nrm_pass_si[0:12] = {ex6_nrm_pass_so[1:12], ex6_nrm_x_so[0]};
   assign ex6_fmv_si[0:35] = {ex6_fmv_so[1:35], ex6_nrm_pass_so[0]};
   assign f_nrm_so = ex6_fmv_so[0];
   
endmodule
