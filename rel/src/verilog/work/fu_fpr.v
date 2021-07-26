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

//*****************************************************************************
//*
//*  TITLE: F_DP_FPR
//*
//*  NAME:  fu_fpr.vhdl
//*
//*  DESC:   This is the Floating Point Register file
//*
//*****************************************************************************

   `include "tri_a2o.vh"

module fu_fpr(
   nclk,
   clkoff_b,
   act_dis,
   flush,
   delay_lclkra,
   delay_lclkrb,
   mpw1_ba,
   mpw1_bb,
   mpw2_b,
   abst_sl_thold_1,
   time_sl_thold_1,
   ary_nsl_thold_1,
   gptr_sl_thold_0,
   fce_1,
   thold_1,
   sg_1,
   scan_dis_dc_b,
   scan_diag_dc,
   lbist_en_dc,
   f_fpr_si,
   f_fpr_so,
   f_fpr_ab_si,
   f_fpr_ab_so,
   time_scan_in,
   time_scan_out,
   gptr_scan_in,
   gptr_scan_out,
   vdd,
// vcs,
   gnd,
   pc_fu_abist_di_0,
   pc_fu_abist_di_1,
   pc_fu_abist_ena_dc,
   pc_fu_abist_grf_renb_0,
   pc_fu_abist_grf_renb_1,
   pc_fu_abist_grf_wenb_0,
   pc_fu_abist_grf_wenb_1,
   pc_fu_abist_raddr_0,
   pc_fu_abist_raddr_1,
   pc_fu_abist_raw_dc_b,
   pc_fu_abist_waddr_0,
   pc_fu_abist_waddr_1,
   pc_fu_abist_wl144_comp_ena,
   pc_fu_inj_regfile_parity,
   f_dcd_msr_fp_act,
   iu_fu_rf0_fra_v,
   iu_fu_rf0_frb_v,
   iu_fu_rf0_frc_v,
   iu_fu_rf0_str_v,
   iu_fu_rf0_tid,
   f_dcd_rf0_fra,
   f_dcd_rf0_frb,
   f_dcd_rf0_frc,
   f_dcd_rf0_tid,
   iu_fu_rf0_ldst_tag,
   f_dcd_ex6_frt_tid,
   f_dcd_ex7_frt_addr,
   f_dcd_ex7_frt_tid,
   f_dcd_ex7_frt_wen,
   f_rnd_ex7_res_expo,
   f_rnd_ex7_res_frac,
   f_rnd_ex7_res_sign,
   xu_fu_ex5_load_val,
   xu_fu_ex5_load_tag,
   xu_fu_ex5_load_data,
   lq_gpr_rel_we,
   lq_gpr_rel_le,
   lq_gpr_rel_wa,
   lq_gpr_rel_wd,
   f_fpr_ex6_load_addr,
   f_fpr_ex6_load_v,
   f_fpr_ex6_reload_addr,
   f_fpr_ex6_reload_v,

   f_fpr_ex1_s_sign,
   f_fpr_ex1_s_expo,
   f_fpr_ex1_s_frac,
   f_fpr_ex1_a_sign,
   f_fpr_ex1_a_expo,
   f_fpr_ex1_a_frac,
   f_fpr_ex1_c_sign,
   f_fpr_ex1_c_expo,
   f_fpr_ex1_c_frac,
   f_fpr_ex1_b_sign,
   f_fpr_ex1_b_expo,
   f_fpr_ex1_b_frac,
   f_fpr_ex8_frt_sign,
   f_fpr_ex8_frt_expo,
   f_fpr_ex8_frt_frac,
   f_fpr_ex9_frt_sign,
   f_fpr_ex9_frt_expo,
   f_fpr_ex9_frt_frac,

   f_fpr_ex6_load_sign,
   f_fpr_ex6_load_expo,
   f_fpr_ex6_load_frac,
   f_fpr_ex7_load_sign,
   f_fpr_ex7_load_expo,
   f_fpr_ex7_load_frac,
   f_fpr_ex8_load_sign,
   f_fpr_ex8_load_expo,
   f_fpr_ex8_load_frac,

   f_fpr_ex6_reload_sign,
   f_fpr_ex6_reload_expo,
   f_fpr_ex6_reload_frac,
   f_fpr_ex7_reload_sign,
   f_fpr_ex7_reload_expo,
   f_fpr_ex7_reload_frac,
   f_fpr_ex8_reload_sign,
   f_fpr_ex8_reload_expo,
   f_fpr_ex8_reload_frac,

   f_fpr_ex2_s_expo_extra,
   f_fpr_ex2_a_par,
   f_fpr_ex2_b_par,
   f_fpr_ex2_c_par,
   f_fpr_ex2_s_par
);
   parameter           fpr_pool = 64;
   parameter           fpr_pool_enc = 7;
   parameter           threads = 2;
   parameter           axu_spare_enc = 3;

   input  [0:`NCLK_WIDTH-1]              nclk;
   input               clkoff_b;		// tiup
   input               act_dis;		// ??tidn??
   input               flush;		// ??tidn??
   input [0:1]         delay_lclkra;		// tidn,
   input [6:7]         delay_lclkrb;
   input [0:1]         mpw1_ba;		// tidn,
   input [6:7]         mpw1_bb;
   input [0:1]         mpw2_b;		// tidn,

   input               abst_sl_thold_1;
   input               time_sl_thold_1;
   input               ary_nsl_thold_1;
   input               gptr_sl_thold_0;
   input               fce_1;
   input               thold_1;
   input               sg_1;
   input               scan_dis_dc_b;
   input               scan_diag_dc;
   input               lbist_en_dc;

   input               f_fpr_si;
   output              f_fpr_so;
   input               f_fpr_ab_si;
   output              f_fpr_ab_so;
   input               time_scan_in;
   output              time_scan_out;
   input               gptr_scan_in;
   output              gptr_scan_out;
   inout               vdd;
   //inout               vcs;
   inout               gnd;
   // ABIST
   input [0:3]         pc_fu_abist_di_0;
   input [0:3]         pc_fu_abist_di_1;
   input               pc_fu_abist_ena_dc;
   input               pc_fu_abist_grf_renb_0;
   input               pc_fu_abist_grf_renb_1;
   input               pc_fu_abist_grf_wenb_0;
   input               pc_fu_abist_grf_wenb_1;
   input [0:9]         pc_fu_abist_raddr_0;
   input [0:9]         pc_fu_abist_raddr_1;
   input               pc_fu_abist_raw_dc_b;
   input [0:9]         pc_fu_abist_waddr_0;
   input [0:9]         pc_fu_abist_waddr_1;
   input               pc_fu_abist_wl144_comp_ena;
   input [0:`THREADS-1] pc_fu_inj_regfile_parity;
   input               f_dcd_msr_fp_act;
   input               iu_fu_rf0_fra_v;
   input               iu_fu_rf0_frb_v;
   input               iu_fu_rf0_frc_v;
   input               iu_fu_rf0_str_v;

   // Interface to IU
   input [0:threads-1] iu_fu_rf0_tid;		// one hot
   input [0:5]         f_dcd_rf0_fra;
   input [0:5]         f_dcd_rf0_frb;
   input [0:5]         f_dcd_rf0_frc;
   input [0:1]         f_dcd_rf0_tid;
   input [0:9]         iu_fu_rf0_ldst_tag;
   //----------------------------------------------
   input [0:1]         f_dcd_ex6_frt_tid; // one hot
   input [0:5]         f_dcd_ex7_frt_addr;
   input [0:1]         f_dcd_ex7_frt_tid;
   input               f_dcd_ex7_frt_wen;
   input [1:13]        f_rnd_ex7_res_expo;
   input [0:52]        f_rnd_ex7_res_frac;
   input               f_rnd_ex7_res_sign;
   //----------------------------------------------
   input               xu_fu_ex5_load_val;
   input [0:7+threads] xu_fu_ex5_load_tag;
   input [192:255]     xu_fu_ex5_load_data;

   input               lq_gpr_rel_we;
   input               lq_gpr_rel_le;
   input [0:7+threads] lq_gpr_rel_wa;
   input [64:127]      lq_gpr_rel_wd;		//      :out std_ulogic_vector((128-STQ_DATA_SIZE) to 127);
   //----------------------------------------------
   output [0:7]        f_fpr_ex6_load_addr;
   output              f_fpr_ex6_load_v;
   output [0:7]        f_fpr_ex6_reload_addr;
   output              f_fpr_ex6_reload_v;

   output              f_fpr_ex1_s_sign;
   output [1:11]       f_fpr_ex1_s_expo;
   output [0:52]       f_fpr_ex1_s_frac;
   output              f_fpr_ex1_a_sign;
   output [1:13]       f_fpr_ex1_a_expo;
   output [0:52]       f_fpr_ex1_a_frac;
   output              f_fpr_ex1_c_sign;
   output [1:13]       f_fpr_ex1_c_expo;
   output [0:52]       f_fpr_ex1_c_frac;
   output              f_fpr_ex1_b_sign;
   output [1:13]       f_fpr_ex1_b_expo;
   output [0:52]       f_fpr_ex1_b_frac;
   output              f_fpr_ex8_frt_sign;
   output [1:13]       f_fpr_ex8_frt_expo;
   output [0:52]       f_fpr_ex8_frt_frac;
   output              f_fpr_ex9_frt_sign;
   output [1:13]       f_fpr_ex9_frt_expo;
   output [0:52]       f_fpr_ex9_frt_frac;

   output              f_fpr_ex6_load_sign;
   output [3:13]       f_fpr_ex6_load_expo;
   output [0:52]       f_fpr_ex6_load_frac;
   output              f_fpr_ex7_load_sign;
   output [3:13]       f_fpr_ex7_load_expo;
   output [0:52]       f_fpr_ex7_load_frac;
   output              f_fpr_ex8_load_sign;
   output [3:13]       f_fpr_ex8_load_expo;
   output [0:52]       f_fpr_ex8_load_frac;

   output              f_fpr_ex6_reload_sign;
   output [3:13]       f_fpr_ex6_reload_expo;
   output [0:52]       f_fpr_ex6_reload_frac;
   output              f_fpr_ex7_reload_sign;
   output [3:13]       f_fpr_ex7_reload_expo;
   output [0:52]       f_fpr_ex7_reload_frac;
   output              f_fpr_ex8_reload_sign;
   output [3:13]       f_fpr_ex8_reload_expo;
   output [0:52]       f_fpr_ex8_reload_frac;

   output [0:1]        f_fpr_ex2_s_expo_extra;
   output [0:7]        f_fpr_ex2_a_par;
   output [0:7]        f_fpr_ex2_b_par;
   output [0:7]        f_fpr_ex2_c_par;
   output [0:7]        f_fpr_ex2_s_par;
   // This entity contains macros


   // ####################### SIGNALS ####################### --
   wire                tilo;
   wire                tihi;
   wire                tiup;
   wire                tidn;

   wire [0:3]          pc_fu_inj_regfile_parity_int;


   wire                thold_0;
   wire                thold_0_b;
   wire                sg_0;
   wire                force_t;
   wire                ab_thold_0;
   wire                ab_thold_0_b;
   wire                ab_force;
   wire                time_sl_thold_0;

   wire [0:1]          load_tid_enc;
   wire [0:7]          load_addr;
   wire                load_wen;

   wire [0:63]         ex6_load_data_raw;
   wire [0:31]         ex6_load_sp_data_raw;
   wire [0:65]         ex6_load_data;
   wire [0:65]         ex6_load_data_byp;
   wire [0:65]         ex7_load_data_byp;
   wire [0:65]         ex8_load_data_byp;
   wire [0:65]         ex6_reload_data_byp;
   wire [0:65]         ex7_reload_data_byp;
   wire [0:65]         ex8_reload_data_byp;
   wire                ex5_load_val;
   wire                ex5_load_v;
   wire [0:9]          ex5_load_tag;
   wire                ex6_load_val;
   wire [0:9]          ex6_load_tag;

   wire [0:1]          reload_tid_enc;
   wire [0:7]          reload_addr;
   wire                reload_wen;

   wire                ex5_reload_val;
   wire                ex5_reload_v;
   wire [0:9]          ex5_reload_tag;
   wire [0:63]         ex6_reload_data_raw;
   wire [0:31]         ex6_reload_sp_data_raw;
   wire [0:65]         ex6_reload_data;
   wire                ex6_reload_val;
   wire [0:9]          ex6_reload_tag;

   wire [0:3]          perr_inject;
   wire                ex6_ld_perr_inj;
   wire                ex7_ld_perr_inj;
   wire                ex6_rld_perr_inj;
   wire                ex7_rld_perr_inj;
   wire                ex6_targ_perr_inj;
   wire                ex7_targ_perr_inj;

   wire                r0e_en_func;
   wire                r1e_en_func;

   wire [0:73]         load_data_f0;
   wire [0:73]         load_data_f1;
   wire [0:7]          load_data_parity;
   wire [0:7]          load_data_parity_inj;
   wire                load_sp;
   wire                load_int;
   wire                load_sign_ext;
   wire                load_int_1up;
   wire                load_dp_exp_zero;
   wire                load_sp_exp_zero;
   wire                load_sp_exp_ones;
   wire [0:65]         load_sp_data;
   wire [0:65]         load_dp_data;

   wire [0:73]         reload_data_f0;
   wire [0:73]         reload_data_f1;
   wire [0:7]          reload_data_parity;
   wire [0:7]          reload_data_parity_inj;
   wire                reload_sp;
   wire                reload_int;
   wire                reload_sign_ext;
   wire                reload_int_1up;
   wire                reload_dp_exp_zero;
   wire                reload_sp_exp_zero;
   wire                reload_sp_exp_ones;
   wire [0:65]         reload_sp_data;
   wire [0:65]         reload_dp_data;

   wire [0:7]          rf0_fra_addr;
   wire [0:7]          rf0_frb_addr;
   wire [0:7]          rf0_frc_addr;
   wire [0:7]          rf0_frs_addr;

   wire [0:7]          frt_addr;
   wire                frt_wen;
   wire [0:63]         frt_data;
   wire [0:7]          frt_data_parity;

   wire [0:66]         ex7_frt_data;
   wire [0:66]         ex8_frt_data;
   wire [0:66]         ex9_frt_data;
   wire [0:131]        ldwt_lat_si;
   wire [0:131]        ldwt_lat_so;
   wire [0:131]        reldwt_lat_si;
   wire [0:131]        reldwt_lat_so;
   wire [0:133]        tgwt_lat_si;
   wire [0:133]        tgwt_lat_so;

   wire [0:77]         rf1_fra;
   wire [0:77]         rf1_frb;
   wire [0:77]         rf1_frc;
   wire [0:77]         rf1_frs;

   wire [0:9]          abist_raddr_0;
   wire [0:9]          abist_raddr_1;
   wire [0:9]          abist_waddr_0;
   wire [0:9]          abist_waddr_1;
   wire [0:52]         ab_reg_si;
   wire [0:52]         ab_reg_so;

   wire                abist_comp_en;		// when abist tested
   wire                r0e_abist_comp_en;		// when abist tested
   wire                r1e_abist_comp_en;		// when abist tested

   wire                lcb_act_dis_dc;
   wire [0:1]          lcb_clkoff_dc_b;
   wire                lcb_d_mode_dc;
   wire [0:4]          lcb_delay_lclkr_dc;		//<lclk delay>
   wire                fce_0;
   wire [0:6]          lcb_mpw1_dc_b;		// <clock shapg>
   wire                lcb_mpw2_dc_b;
   wire                lcb_sg_0;
   wire                lcb_abst_sl_thold_0;
   wire                ary_nsl_thold_0;
   wire                clkoff_dc_b;
   wire                d_mode_dc;

   wire                scan_in_0;
   wire                scan_out_0;

   wire                scan_in_1;
   wire                scan_out_1;

   wire                r0e_en_abist;
   wire [0:7]          r0e_addr_abist;

   wire                r1e_en_abist;
   wire [0:7]          r1e_addr_abist;
   wire                w0e_act;
   wire                w0e_en_func;
   wire                w0e_en_abist;
   wire [0:7]          w0e_addr_func;
   wire [0:7]          w0e_addr_abist;
   wire [0:77]         w0e_data_func_f0;
   wire [0:77]         w0e_data_func_f1;

   wire [0:77]         rel_data_func_f0;
   wire [0:77]         rel_data_func_f1;

   wire [0:3]          w0e_data_abist;
   wire                w0l_act;
   wire                w0l_en_func;
   wire                w0l_en_abist;
   wire [0:7]          w0l_addr_func;
   wire [0:7]          w0l_addr_abist;
   wire [0:77]         w0l_data_func_f0;
   wire [0:77]         w0l_data_func_f1;
   wire [0:3]          w0l_data_abist;

   wire [0:77]         fra_data_out;
   wire [0:77]         frb_data_out;
   wire [0:77]         frc_data_out;
   wire [0:77]         frs_data_out;
   wire [0:7]          ex1_fra_par;
   wire [0:7]          ex1_frb_par;
   wire [0:7]          ex1_frc_par;
   wire [0:7]          ex1_frs_par;
   wire [0:1]          ex1_s_expo_extra;

   wire [0:63]         ex7_ldat_si;
   wire [0:63]         ex7_ldat_so;
   wire [0:63]         ex7_rldat_si;
   wire [0:63]         ex7_rldat_so;

   wire [0:11]         ex7_lctl_si;
   wire [0:11]         ex7_lctl_so;
   wire [0:9]          ex7_rlctl_si;
   wire [0:9]          ex7_rlctl_so;

   wire [0:1]          ex7_ldv_si;
   wire [0:1]          ex7_ldv_so;
   wire [0:4]          ex6_lctl_si;
   wire [0:4]          ex6_lctl_so;
   wire [0:33]         ex1_par_si;
   wire [0:33]         ex1_par_so;
   wire                ld_par3239;
   wire                ld_par3239_inj;
   wire                ld_par4047;
   wire                ld_par4855;
   wire                ld_par5663;
   wire                ld_par6163;
   wire                ld_par6163_inj;
   wire                ld_par0007;
   wire                ld_par0815;
   wire                ld_par1623;
   wire                ld_par2431;
   wire                ld_par32_3436;
   wire                ld_par3744;
   wire                ld_par4552;
   wire                ld_par5360;
   wire                load_dp_nint;
   wire                load_dp_int;
   wire                load_sp_all1;
   wire                load_sp_nall1;

   wire                rld_par3239;
   wire                rld_par3239_inj;
   wire                rld_par4047;
   wire                rld_par4855;
   wire                rld_par5663;
   wire                rld_par6163;
   wire                rld_par6163_inj;
   wire                rld_par0007;
   wire                rld_par0815;
   wire                rld_par1623;
   wire                rld_par2431;
   wire                rld_par32_3436;
   wire                rld_par3744;
   wire                rld_par4552;
   wire                rld_par5360;
   wire                reload_dp_nint;
   wire                reload_dp_int;
   wire                reload_sp_all1;
   wire                reload_sp_nall1;

   wire [0:77]         zeros;
   wire [1:25]         spare_unused;

   //----------------------------------------------------------------------
   // Pervasive


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


   tri_lcbor lcbor_0(
      .clkoff_b(clkoff_b),
      .thold(thold_0),
      .sg(sg_0),
      .act_dis(act_dis),
      .force_t(force_t),
      .thold_b(thold_0_b)
   );


   tri_plat #(.WIDTH(4)) ab_thold_reg_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(flush),
      .din({abst_sl_thold_1,
            time_sl_thold_1,
            ary_nsl_thold_1,
            fce_1}),
      .q({ ab_thold_0,
           time_sl_thold_0,
           ary_nsl_thold_0,
           fce_0})
   );


   tri_lcbor  ab_lcbor_0(
      .clkoff_b(clkoff_b),
      .thold(ab_thold_0),
      .sg(sg_0),
      .act_dis(act_dis),
      .force_t(ab_force),
      .thold_b(ab_thold_0_b)
   );

   //----------------------------------------------------------------------
   // Act Latches

   assign tilo = 1'b0;
   assign tihi = 1'b1;
   assign zeros = {78{tilo}};
   assign tiup = 1'b1;
   assign tidn = 1'b1;

   //----------------------------------------------------------------------
   // Load Data

   generate
      if (threads == 1)
      begin : fpr_inj_perr_thr1_1
         assign pc_fu_inj_regfile_parity_int[0:3] = {pc_fu_inj_regfile_parity[0], tidn, tidn, tidn};
      end
   endgenerate

   generate
      if (threads == 2)
      begin : fpr_inj_perr_thr2_2
         assign pc_fu_inj_regfile_parity_int[0:3] = {pc_fu_inj_regfile_parity[0], pc_fu_inj_regfile_parity[1], tidn, tidn};
      end
   endgenerate

   tri_rlmreg_p #(.INIT(0),  .WIDTH(5)) ex6_lctl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkrb[6]),
      .mpw1_b(mpw1_bb[6]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex6_lctl_si[0:4]),
      .scout(ex6_lctl_so[0:4]),

      .din({ pc_fu_inj_regfile_parity_int[0:3],
             ex6_targ_perr_inj}),

      .dout({ perr_inject[0:3],
              ex7_targ_perr_inj})
   );

   assign ex5_load_val = xu_fu_ex5_load_val;
   assign ex5_load_v = ex5_load_val;

   generate
      if (threads == 1)
      begin : dcd_loadtag_thr1_1
         assign ex5_load_tag[0:9] = {xu_fu_ex5_load_tag[0:2], 1'b0, xu_fu_ex5_load_tag[3:8]};
      end
   endgenerate

   generate
      if (threads == 2)
      begin : dcd_loadtag_thr2_1
         assign ex5_load_tag[0:9] = xu_fu_ex5_load_tag[0:9];
      end
   endgenerate

   assign ex5_reload_val = lq_gpr_rel_we;
   assign ex5_reload_v = ex5_reload_val;

   generate
      if (threads == 1)
      begin : dcd_reloadtag_thr1_1
         assign ex5_reload_tag[0:9] = {lq_gpr_rel_wa[0:2], 1'b0, lq_gpr_rel_wa[3:8]};
      end
   endgenerate

   generate
      if (threads == 2)
      begin : dcd_reloadtag_thr2_1
         assign ex5_reload_tag[0:9] = lq_gpr_rel_wa[0:9];
      end
   endgenerate

   assign ex6_ld_perr_inj = ((ex6_load_val) & (~ex6_load_tag[3]) & perr_inject[0]) |
                            ((ex6_load_val) & ( ex6_load_tag[3]) & perr_inject[1]);

   assign ex6_rld_perr_inj = ((ex6_reload_val) & (~ex6_reload_tag[3]) & perr_inject[0]) |
                             ((ex6_reload_val) & ( ex6_reload_tag[3]) & perr_inject[1]);


   assign ex6_targ_perr_inj = (f_dcd_ex6_frt_tid[0] & perr_inject[0]) |
                              (f_dcd_ex6_frt_tid[1] & perr_inject[1]);




   tri_rlmreg_p #(.INIT(0), .WIDTH(2)) ex6_ldv(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkrb[6]),
      .mpw1_b(mpw1_bb[6]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex7_ldv_si[0:1]),
      .scout(ex7_ldv_so[0:1]),
      .din({ex5_load_val,
            ex5_reload_val}),
      .dout({ex6_load_val,
             ex6_reload_val})
   );


   tri_rlmreg_p #(.INIT(0), .WIDTH(12)) ex7_lctl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkrb[6]),  //todo separate these out into ex6 and ex7?
      .mpw1_b(mpw1_bb[6]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex7_lctl_si[0:11]),
      .scout(ex7_lctl_so[0:11]),
      .din({ex5_load_tag[0:9],
            ex6_ld_perr_inj,
            ex6_rld_perr_inj}),
      .dout({ex6_load_tag[0:9],
             ex7_ld_perr_inj,
             ex7_rld_perr_inj})
   );

   tri_rlmreg_p #(.INIT(0),  .WIDTH(10)) ex7_rlctl(
      .nclk(nclk),
      .act(ex5_reload_v),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkrb[6]),
      .mpw1_b(mpw1_bb[6]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex7_rlctl_si[0:9]),
      .scout(ex7_rlctl_so[0:9]),
      .din(ex5_reload_tag[0:9]),
      .dout(ex6_reload_tag[0:9])
   );


   tri_rlmreg_p #(.INIT(0),  .WIDTH(64), .NEEDS_SRESET(0)) ex7_ldat(
      .nclk(nclk),
      .act(ex5_load_v),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkrb[7]),
      .mpw1_b(mpw1_bb[7]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex7_ldat_si[0:63]),
      .scout(ex7_ldat_so[0:63]),
      .din(xu_fu_ex5_load_data[192:255]),
      .dout(ex6_load_data_raw[0:63])
   );


   tri_rlmreg_p #(.INIT(0),  .WIDTH(64), .NEEDS_SRESET(0)) ex7_rldat(
      .nclk(nclk),
      .act(ex5_reload_v),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkrb[7]),
      .mpw1_b(mpw1_bb[7]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex7_rldat_si[0:63]),
      .scout(ex7_rldat_so[0:63]),
      .din(lq_gpr_rel_wd[64:127]),
      .dout(ex6_reload_data_raw[0:63])
   );

   assign load_tid_enc[0] = tilo;
   assign load_tid_enc[1] = tilo;

   assign load_addr[1:7] = ex6_load_tag[3:9];

   assign load_sp = ex6_load_tag[0];		// bit 0 of the tag indicates that the instr was an lfs*
   assign load_int = ex6_load_tag[1];		// bit 1 is lfi*
   assign load_sign_ext = ex6_load_tag[2];		// bit 1 is lfiwax

   assign load_wen = ex6_load_val;

   assign reload_tid_enc[0] = tilo;
   assign reload_tid_enc[1] = tilo;

   assign reload_addr[0:7] = {1'b0, ex6_reload_tag[3:9]};

   assign reload_sp = ex6_reload_tag[0];		// bit 0 of the tag indicates that the instr was an lfs*
   assign reload_int = ex6_reload_tag[1];		// bit 1 is lfi*
   assign reload_sign_ext = ex6_reload_tag[2];		// bit 1 is lfiwax

   assign reload_wen = ex6_reload_val;

   // FPU LOADS
   //
   // Double precision (DP) loads are straight forward.
   // To get rid of the mathematical discontinuity in the ieee number system,
   // We add the implicit bit and change the zero exponent from x000 to x001.
   // This needs to be undone when data is stored.
   //
   // the spec says that Single Precision loads (SP) should be fully normalized
   // and converted to double format before storing.
   // there is not time to do that, so we take a short cut and deal with the problems
   // when the operand is used.
   // The Double precision exponent bias is 1023.
   // The Single precision exponent bias is  127.
   // The difference x380 is added to convert the exponent.
   // (actually no adder is needed)
   //          x380 => "0_0011_1000_0000
   //           SP             Dddd_dddd
   //          if D=0   0_0011_1ddd_dddd    --> {D, !D, !D, !D}
   //          if D=1   0_0100_0ddd_dddd    --> {D, !D, !D, !D}
   //
   // also for SP -> SP_infinity is converted to DP infinity
   //             -> (0) is converted to x381 (instead of x380) and the implicit bit is added.
   // so .... there are now 2 numbers that mean zero
   //            1) (exp==x001) and (IMP_bit==0) and (FRAC==0)
   //            2) (exp==x381) and (IMP_bit==0) and (FRAC==0)
   // the only time the SP load needs correcting (prenormalization) is
   //           (exp==x381) and (IMP_bit==0) and (FRAC==0) <== SP denorm can be converted to DP norm.
   //
   //------------------------------------------------------------------------------------------------
   // INPUT LOAD DATA FORMAT  LdDin[0:63] :
   //
   //           lfd       lfs
   //  [00:00] sign       [00:00] sign
   //  [01:11] exponent   [01:08] exponent
   //  [12:63] fraction   [09:31] fraction
   // -----------------------------------------------------------------------------------------------
   // OUTPUT LOAD DATA FORMAT ... add implicit bit
   //
   //          DP                                   |  SP
   //  ---------------------------------------------|-------------------------------------------------
   // [00:00]  Din[00]                              |  Din[00]                           <--- Sgn
   // [01:01]  Din[01]                              |  Din[01]                           <--- exp[00]     //03
   // [02:02]  Din[02]                              | ~Din[01] | (Din[01:08]="11111111") <--- exp[01]     //04
   // [03:03]  Din[03]                              | ~Din[01] | (Din[01:08]="11111111") <--- exp[02]     //05
   // [04:04]  Din[04]                              | ~Din[01] | (Din[01:08]="11111111") <--- exp[03]     //06
   // [05:10]  Din[05:10]                           |  Din[02:07]                        <--- exp[04:09]  //07:12
   // [11:11]  Din[11] | (Din[01:11]="00000000000") |  Din[08] | (Din[01:08]="00000000") <--- exp[10]     //13
   // [12:12]           ~(Din[01:11]="00000000000") |           ~(Din[01:08]="00000000") <--- frac[00]    //imlicit bit
   // [13:35]  Din[12:34]                           |  Din[09:31]                        <--- frac[01:23]
   // [36:64]  Din[35:63]                           |  (0:28=>'0')                       <--- frac[24:52]
   //  ---------------------------------------------|-------------------------------------------------
   //------------------------------------------------------------------------------
   // LOAD FPU/FPR data format
   //
   // Double-precision load: lfd*
   //
   // Value Loaded  Internal Representation [sign exponent imp fraction]  Format name
   // ------------  ----------------------------------------------------  -----------
   // 0             x 00000000001 0 0000...                               Zero
   // Denormal      x 00000000001 0 xxxx...                               Denormal
   // Normal        x xxxxxxxxxxx 1 xxxx...                               Normal
   // Inf           x 11111111111 1 0000...                               Inf
   // NaN           x 11111111111 1 qxxx...                               NaN
   //
   // Single-precision denormal form (SP_DENORM)
   //  exp = 0x381, imp = 0, frac != 0 (frac == 0: SP_DENORM0)
   //
   // Single-precision load: lfs*
   //
   // Value Loaded  Internal Representation [sign exponent imp fraction]  Format name
   // ------------  ----------------------------------------------------  -----------
   // 0             x 01110000001 0 000000000000000000000000000...        SP_DENORM0
   // Denormal      x 01110000001 0 xxxxxxxxxxxxxxxxxxxxxxx0000...        SP_DENORM
   // Normal        x xXXXxxxxxxx 1 xxxxxxxxxxxxxxxxxxxxxxx0000...        Normal
   // Inf           x 11111111111 1 000000000000000000000000000...        Inf
   // NaN           x 11111111111 1 qxxxxxxxxxxxxxxxxxxxxxx0000...        NaN
   //------------------------------------------------------------------------------
   // Convert Incoming SP loads to DP format
   // DP bias = 1023
   // SP bias =  127
   // diff = x380 => 0_0011_1000_0000
   //        SP             Dddd_dddd
   // if D=0, 0_0011_1ddd_dddd -> {D,!D,!D,!D}
   // if D=1, 0_0100_0ddd_dddd -> {D,!D,!D,!D}

   // For lfiwax and lfiwzx, either set upper (32) to zeros or ones
   assign load_int_1up = load_int & load_sign_ext & load_sp_data[0];
   assign reload_int_1up = reload_int & reload_sign_ext & reload_sp_data[0];

   // Due to the XU rotator, all SP loads (words) are aligned to the right
   assign ex6_load_sp_data_raw[0:31] = ex6_load_data_raw[32:63];
   assign ex6_reload_sp_data_raw[0:31] = ex6_reload_data_raw[32:63];

   assign load_dp_exp_zero = ex6_load_data_raw[1:11] == 11'b00000000000;
   assign load_sp_exp_zero = ex6_load_sp_data_raw[1:8] == 8'b00000000;
   assign load_sp_exp_ones = ex6_load_sp_data_raw[1:8] == 8'b11111111;

   assign load_sp_data[0] = ex6_load_sp_data_raw[0];		// sign
   assign load_sp_data[1] = tilo;		// exp02
   assign load_sp_data[2] = ex6_load_sp_data_raw[1];		// exp03
   assign load_sp_data[3] = (~ex6_load_sp_data_raw[1]) | load_sp_exp_ones;		// exp04
   assign load_sp_data[4] = (~ex6_load_sp_data_raw[1]) | load_sp_exp_ones;		// exp05
   assign load_sp_data[5] = (~ex6_load_sp_data_raw[1]) | load_sp_exp_ones;		// exp06
   assign load_sp_data[6:11] = ex6_load_sp_data_raw[2:7];		// exp07-12
   assign load_sp_data[12] = ex6_load_sp_data_raw[8] | load_sp_exp_zero;		// exp13
   assign load_sp_data[13] = (~load_sp_exp_zero);		// implicit
   assign load_sp_data[14:36] = ex6_load_sp_data_raw[9:31];		// frac01:23
   assign load_sp_data[37:65] = {29{tilo}};		// frac24:52

   assign load_dp_data[0] = (ex6_load_data_raw[0] & (~load_int)) | load_int_1up;		// sign
   assign load_dp_data[1] = tilo;		// exp02
   assign load_dp_data[2:11] = (ex6_load_data_raw[1:10] & {10{(~load_int)}}) | {10{load_int_1up}};		// exp03-12
   assign load_dp_data[12] = (ex6_load_data_raw[11] | load_dp_exp_zero) | load_int | load_int_1up;		// exp13
   assign load_dp_data[13] = ((~load_dp_exp_zero) & (~load_int)) | load_int_1up;		// implicit
   assign load_dp_data[14:33] = (ex6_load_data_raw[12:31] & {20{(~load_int)}}) | {20{load_int_1up}};		// fraction
   assign load_dp_data[34:65] = ex6_load_data_raw[32:63];		// fraction

   assign ex6_load_data[0:65] = (load_dp_data[0:65] & {66{(~load_sp)}}) | (load_sp_data[0:65] & {66{load_sp}});

   assign load_data_f0[0:73] = {ex6_load_data[0:65], load_data_parity[0:7]};
   assign load_data_f1[0:73] = {ex6_load_data[0:65], load_data_parity_inj[0:7]};

   assign reload_dp_exp_zero = ex6_reload_data_raw[1:11] == 11'b00000000000;
   assign reload_sp_exp_zero = ex6_reload_sp_data_raw[1:8] == 8'b00000000;
   assign reload_sp_exp_ones = ex6_reload_sp_data_raw[1:8] == 8'b11111111;

   assign reload_sp_data[0] = ex6_reload_sp_data_raw[0];		// sign
   assign reload_sp_data[1] = tilo;		// exp02
   assign reload_sp_data[2] = ex6_reload_sp_data_raw[1];		// exp03
   assign reload_sp_data[3] = (~ex6_reload_sp_data_raw[1]) | reload_sp_exp_ones;		// exp04
   assign reload_sp_data[4] = (~ex6_reload_sp_data_raw[1]) | reload_sp_exp_ones;		// exp05
   assign reload_sp_data[5] = (~ex6_reload_sp_data_raw[1]) | reload_sp_exp_ones;		// exp06
   assign reload_sp_data[6:11] = ex6_reload_sp_data_raw[2:7];		// exp07-12
   assign reload_sp_data[12] = ex6_reload_sp_data_raw[8] | reload_sp_exp_zero;		// exp13
   assign reload_sp_data[13] = (~reload_sp_exp_zero);		// implicit
   assign reload_sp_data[14:36] = ex6_reload_sp_data_raw[9:31];		// frac01:23
   assign reload_sp_data[37:65] = {29{tilo}};		// frac24:52

   assign reload_dp_data[0] = (ex6_reload_data_raw[0] & (~reload_int)) | reload_int_1up;		// sign
   assign reload_dp_data[1] = tilo;		// exp02
   assign reload_dp_data[2:11] = (ex6_reload_data_raw[1:10] & {10{(~reload_int)}}) | {10{reload_int_1up}};		// exp03-12
   assign reload_dp_data[12] = (ex6_reload_data_raw[11] | reload_dp_exp_zero) | reload_int | reload_int_1up;		// exp13
   assign reload_dp_data[13] = ((~reload_dp_exp_zero) & (~reload_int)) | reload_int_1up;		// implicit
   assign reload_dp_data[14:33] = (ex6_reload_data_raw[12:31] & {20{(~reload_int)}}) | {20{reload_int_1up}};		// fraction
   assign reload_dp_data[34:65] = ex6_reload_data_raw[32:63];		// fraction

   assign ex6_reload_data[0:65] = (reload_dp_data[0:65] & {66{(~reload_sp)}}) | (reload_sp_data[0:65] & {66{reload_sp}});

   assign reload_data_f0[0:73] = {ex6_reload_data[0:65], reload_data_parity[0:7]};
   assign reload_data_f1[0:73] = {ex6_reload_data[0:65], reload_data_parity_inj[0:7]};



   assign ld_par0007 = ex6_load_data_raw[0] ^ ex6_load_data_raw[1] ^ ex6_load_data_raw[2] ^ ex6_load_data_raw[3] ^ ex6_load_data_raw[4] ^ ex6_load_data_raw[5] ^ ex6_load_data_raw[6] ^ ex6_load_data_raw[7];
   assign ld_par32_3436 = ex6_load_data_raw[32] ^ ex6_load_data_raw[34] ^ ex6_load_data_raw[35] ^ ex6_load_data_raw[36];
   assign ld_par0815 = ex6_load_data_raw[8] ^ ex6_load_data_raw[9] ^ ex6_load_data_raw[10] ^ ex6_load_data_raw[11] ^ ex6_load_data_raw[12] ^ ex6_load_data_raw[13] ^ ex6_load_data_raw[14] ^ ex6_load_data_raw[15];
   assign ld_par3744 = ex6_load_data_raw[37] ^ ex6_load_data_raw[38] ^ ex6_load_data_raw[39] ^ ex6_load_data_raw[40] ^ ex6_load_data_raw[41] ^ ex6_load_data_raw[42] ^ ex6_load_data_raw[43] ^ ex6_load_data_raw[44];
   assign ld_par1623 = ex6_load_data_raw[16] ^ ex6_load_data_raw[17] ^ ex6_load_data_raw[18] ^ ex6_load_data_raw[19] ^ ex6_load_data_raw[20] ^ ex6_load_data_raw[21] ^ ex6_load_data_raw[22] ^ ex6_load_data_raw[23];
   assign ld_par4552 = ex6_load_data_raw[45] ^ ex6_load_data_raw[46] ^ ex6_load_data_raw[47] ^ ex6_load_data_raw[48] ^ ex6_load_data_raw[49] ^ ex6_load_data_raw[50] ^ ex6_load_data_raw[51] ^ ex6_load_data_raw[52];
   assign ld_par2431 = ex6_load_data_raw[24] ^ ex6_load_data_raw[25] ^ ex6_load_data_raw[26] ^ ex6_load_data_raw[27] ^ ex6_load_data_raw[28] ^ ex6_load_data_raw[29] ^ ex6_load_data_raw[30] ^ ex6_load_data_raw[31];
   assign ld_par5360 = ex6_load_data_raw[53] ^ ex6_load_data_raw[54] ^ ex6_load_data_raw[55] ^ ex6_load_data_raw[56] ^ ex6_load_data_raw[57] ^ ex6_load_data_raw[58] ^ ex6_load_data_raw[59] ^ ex6_load_data_raw[60];
   assign ld_par3239 = ex6_load_data_raw[32] ^ ex6_load_data_raw[33] ^ ex6_load_data_raw[34] ^ ex6_load_data_raw[35] ^ ex6_load_data_raw[36] ^ ex6_load_data_raw[37] ^ ex6_load_data_raw[38] ^ ex6_load_data_raw[39];
   assign ld_par4047 = ex6_load_data_raw[40] ^ ex6_load_data_raw[41] ^ ex6_load_data_raw[42] ^ ex6_load_data_raw[43] ^ ex6_load_data_raw[44] ^ ex6_load_data_raw[45] ^ ex6_load_data_raw[46] ^ ex6_load_data_raw[47];
   assign ld_par4855 = ex6_load_data_raw[48] ^ ex6_load_data_raw[49] ^ ex6_load_data_raw[50] ^ ex6_load_data_raw[51] ^ ex6_load_data_raw[52] ^ ex6_load_data_raw[53] ^ ex6_load_data_raw[54] ^ ex6_load_data_raw[55];
   assign ld_par5663 = ex6_load_data_raw[56] ^ ex6_load_data_raw[57] ^ ex6_load_data_raw[58] ^ ex6_load_data_raw[59] ^ ex6_load_data_raw[60] ^ ex6_load_data_raw[61] ^ ex6_load_data_raw[62] ^ ex6_load_data_raw[63];

   assign ld_par3239_inj = ex6_load_data_raw[32] ^ ex6_load_data_raw[33] ^ ex6_load_data_raw[34] ^ ex6_load_data_raw[35] ^ ex6_load_data_raw[36] ^ ex6_load_data_raw[37] ^ ex6_load_data_raw[38] ^ ex6_load_data_raw[39] ^ ex7_ld_perr_inj;

   assign ld_par6163 = ex6_load_data_raw[61] ^ ex6_load_data_raw[62] ^ ex6_load_data_raw[63];
   assign ld_par6163_inj = ex6_load_data_raw[61] ^ ex6_load_data_raw[62] ^ ex6_load_data_raw[63] ^ ex7_ld_perr_inj;

   //ld_pgen_premux

   assign load_dp_nint = (~load_sp) & (~load_int);
   assign load_dp_int = (~load_sp) & load_int;
   assign load_sp_all1 = load_sp & load_sp_exp_ones;
   assign load_sp_nall1 = load_sp & (~load_sp_exp_ones);

   assign load_data_parity[0] = (ld_par0007 & load_dp_nint) | (ld_par32_3436 & load_sp_all1) | ((~ld_par32_3436) & load_sp_nall1);
   assign load_data_parity[1] = ((~ld_par0815) & load_dp_nint) | ((~ld_par3744) & load_sp) | load_dp_int;
   assign load_data_parity[2] = (ld_par1623 & load_dp_nint) | (ld_par4552 & load_sp);
   assign load_data_parity[3] = (ld_par2431 & load_dp_nint) | (ld_par5360 & load_sp);
   assign load_data_parity[4] = (ld_par3239 & (~load_sp)) | (ld_par6163 & load_sp);
   assign load_data_parity[5] = (ld_par4047 & (~load_sp));
   assign load_data_parity[6] = (ld_par4855 & (~load_sp));
   assign load_data_parity[7] = (ld_par5663 & (~load_sp));


   assign load_data_parity_inj[0] = (ld_par0007 & load_dp_nint) | (ld_par32_3436 & load_sp_all1) | ((~ld_par32_3436) & load_sp_nall1);
   assign load_data_parity_inj[1] = ((~ld_par0815) & load_dp_nint) | ((~ld_par3744) & load_sp) | load_dp_int;
   assign load_data_parity_inj[2] = (ld_par1623 & load_dp_nint) | (ld_par4552 & load_sp);
   assign load_data_parity_inj[3] = (ld_par2431 & load_dp_nint) | (ld_par5360 & load_sp);
   assign load_data_parity_inj[4] = (ld_par3239_inj & (~load_sp)) | (ld_par6163_inj & load_sp);
   assign load_data_parity_inj[5] = (ld_par4047 & (~load_sp));
   assign load_data_parity_inj[6] = (ld_par4855 & (~load_sp));
   assign load_data_parity_inj[7] = (ld_par5663 & (~load_sp));




   assign rld_par0007 = ex6_reload_data_raw[0] ^ ex6_reload_data_raw[1] ^ ex6_reload_data_raw[2] ^ ex6_reload_data_raw[3] ^ ex6_reload_data_raw[4] ^ ex6_reload_data_raw[5] ^ ex6_reload_data_raw[6] ^ ex6_reload_data_raw[7];		//rld_pgen_premux--

   assign rld_par32_3436 = ex6_reload_data_raw[32] ^ ex6_reload_data_raw[34] ^ ex6_reload_data_raw[35] ^ ex6_reload_data_raw[36];		//rld_pgen_premux--

   assign rld_par0815 = ex6_reload_data_raw[8] ^ ex6_reload_data_raw[9] ^ ex6_reload_data_raw[10] ^ ex6_reload_data_raw[11] ^ ex6_reload_data_raw[12] ^ ex6_reload_data_raw[13] ^ ex6_reload_data_raw[14] ^ ex6_reload_data_raw[15];		//rld_pgen_premux--
   assign rld_par3744 = ex6_reload_data_raw[37] ^ ex6_reload_data_raw[38] ^ ex6_reload_data_raw[39] ^ ex6_reload_data_raw[40] ^ ex6_reload_data_raw[41] ^ ex6_reload_data_raw[42] ^ ex6_reload_data_raw[43] ^ ex6_reload_data_raw[44];		//rld_pgen_premux--
   assign rld_par1623 = ex6_reload_data_raw[16] ^ ex6_reload_data_raw[17] ^ ex6_reload_data_raw[18] ^ ex6_reload_data_raw[19] ^ ex6_reload_data_raw[20] ^ ex6_reload_data_raw[21] ^ ex6_reload_data_raw[22] ^ ex6_reload_data_raw[23];		//rld_pgen_premux--
   assign rld_par4552 = ex6_reload_data_raw[45] ^ ex6_reload_data_raw[46] ^ ex6_reload_data_raw[47] ^ ex6_reload_data_raw[48] ^ ex6_reload_data_raw[49] ^ ex6_reload_data_raw[50] ^ ex6_reload_data_raw[51] ^ ex6_reload_data_raw[52];		//rld_pgen_premux--
   assign rld_par2431 = ex6_reload_data_raw[24] ^ ex6_reload_data_raw[25] ^ ex6_reload_data_raw[26] ^ ex6_reload_data_raw[27] ^ ex6_reload_data_raw[28] ^ ex6_reload_data_raw[29] ^ ex6_reload_data_raw[30] ^ ex6_reload_data_raw[31];		//rld_pgen_premux--
   assign rld_par5360 = ex6_reload_data_raw[53] ^ ex6_reload_data_raw[54] ^ ex6_reload_data_raw[55] ^ ex6_reload_data_raw[56] ^ ex6_reload_data_raw[57] ^ ex6_reload_data_raw[58] ^ ex6_reload_data_raw[59] ^ ex6_reload_data_raw[60];		//rld_pgen_premux--
   assign rld_par3239 = ex6_reload_data_raw[32] ^ ex6_reload_data_raw[33] ^ ex6_reload_data_raw[34] ^ ex6_reload_data_raw[35] ^ ex6_reload_data_raw[36] ^ ex6_reload_data_raw[37] ^ ex6_reload_data_raw[38] ^ ex6_reload_data_raw[39];		//rld_pgen_premux--

   assign rld_par4047 = ex6_reload_data_raw[40] ^ ex6_reload_data_raw[41] ^ ex6_reload_data_raw[42] ^ ex6_reload_data_raw[43] ^ ex6_reload_data_raw[44] ^ ex6_reload_data_raw[45] ^ ex6_reload_data_raw[46] ^ ex6_reload_data_raw[47];		//rld_pgen_premux--
   assign rld_par4855 = ex6_reload_data_raw[48] ^ ex6_reload_data_raw[49] ^ ex6_reload_data_raw[50] ^ ex6_reload_data_raw[51] ^ ex6_reload_data_raw[52] ^ ex6_reload_data_raw[53] ^ ex6_reload_data_raw[54] ^ ex6_reload_data_raw[55];		//rld_pgen_premux--
   assign rld_par5663 = ex6_reload_data_raw[56] ^ ex6_reload_data_raw[57] ^ ex6_reload_data_raw[58] ^ ex6_reload_data_raw[59] ^ ex6_reload_data_raw[60] ^ ex6_reload_data_raw[61] ^ ex6_reload_data_raw[62] ^ ex6_reload_data_raw[63];		//rld_pgen_premux--
   assign rld_par6163 = ex6_reload_data_raw[61] ^ ex6_reload_data_raw[62] ^ ex6_reload_data_raw[63];		//rld_pgen_premux--

   assign rld_par3239_inj = ex6_reload_data_raw[32] ^ ex6_reload_data_raw[33] ^ ex6_reload_data_raw[34] ^ ex6_reload_data_raw[35] ^ ex6_reload_data_raw[36] ^ ex6_reload_data_raw[37] ^ ex6_reload_data_raw[38] ^ ex6_reload_data_raw[39] ^ ex7_rld_perr_inj;		//rld_pgen_premux--
   assign rld_par6163_inj = ex6_reload_data_raw[61] ^ ex6_reload_data_raw[62] ^ ex6_reload_data_raw[63] ^ ex7_rld_perr_inj;		//rld_pgen_premux--




   assign reload_dp_nint = (~reload_sp) & (~reload_int);		//rld_pgen_premux--
   assign reload_dp_int = (~reload_sp) & reload_int;		//rld_pgen_premux--
   assign reload_sp_all1 = reload_sp & reload_sp_exp_ones;		//rld_pgen_premux--
   assign reload_sp_nall1 = reload_sp & (~reload_sp_exp_ones);		//rld_pgen_premux--

   assign reload_data_parity[0] = (rld_par0007 & reload_dp_nint) | (rld_par32_3436 & reload_sp_all1) | ((~rld_par32_3436) & reload_sp_nall1);		//rld_pgen_premux--
   assign reload_data_parity[1] = ((~rld_par0815) & reload_dp_nint) | ((~rld_par3744) & reload_sp) | reload_dp_int;		//rld_pgen_premux--
   assign reload_data_parity[2] = (rld_par1623 & reload_dp_nint) | (rld_par4552 & reload_sp);		//rld_pgen_premux--
   assign reload_data_parity[3] = (rld_par2431 & reload_dp_nint) | (rld_par5360 & reload_sp);		//rld_pgen_premux--
   assign reload_data_parity[4] = (rld_par3239 & (~reload_sp)) | (rld_par6163 & reload_sp);		//rld_pgen_premux--
   assign reload_data_parity[5] = (rld_par4047 & (~reload_sp));		//rld_pgen_premux--
   assign reload_data_parity[6] = (rld_par4855 & (~reload_sp));		//rld_pgen_premux--
   assign reload_data_parity[7] = (rld_par5663 & (~reload_sp));		//rld_pgen_premux--


   assign reload_data_parity_inj[0] = (rld_par0007 & reload_dp_nint) | (rld_par32_3436 & reload_sp_all1) | ((~rld_par32_3436) & reload_sp_nall1);		//rld_pgen_premux--
   assign reload_data_parity_inj[1] = ((~rld_par0815) & reload_dp_nint) | ((~rld_par3744) & reload_sp) | reload_dp_int;		//rld_pgen_premux--
   assign reload_data_parity_inj[2] = (rld_par1623 & reload_dp_nint) | (rld_par4552 & reload_sp);		//rld_pgen_premux--
   assign reload_data_parity_inj[3] = (rld_par2431 & reload_dp_nint) | (rld_par5360 & reload_sp);		//rld_pgen_premux--
   assign reload_data_parity_inj[4] = (rld_par3239_inj & (~reload_sp)) | (rld_par6163_inj & reload_sp);		//rld_pgen_premux--
   assign reload_data_parity_inj[5] = (rld_par4047 & (~reload_sp));		//rld_pgen_premux--
   assign reload_data_parity_inj[6] = (rld_par4855 & (~reload_sp));		//rld_pgen_premux--
   assign reload_data_parity_inj[7] = (rld_par5663 & (~reload_sp));		//rld_pgen_premux--




   //verity_out(0 to 73) <= load_data(0 to 73) ; --VERTIY--

   //----------------------------------------------------------------------
   // Target Data

   generate
      if (threads == 1)
      begin : frt_addr_thr_1
         assign frt_addr[1:7] = {1'b0, f_dcd_ex7_frt_addr[0:5]};
         assign spare_unused[1] = f_dcd_ex7_frt_tid[1];
      end
   endgenerate

   generate
      if (threads == 2)
      begin : frt_addr_thr_2
         assign frt_addr[1:7] = {f_dcd_ex7_frt_addr[0:5], f_dcd_ex7_frt_tid[1]};
         assign spare_unused[1] = tidn;
      end
   endgenerate

   assign frt_wen = f_dcd_ex7_frt_wen;
   assign frt_data[0:63] = {f_rnd_ex7_res_sign, f_rnd_ex7_res_expo[3:13], f_rnd_ex7_res_frac[1:52]};

   assign frt_data_parity[0] = f_rnd_ex7_res_sign ^ f_rnd_ex7_res_expo[1] ^ f_rnd_ex7_res_expo[2] ^ f_rnd_ex7_res_expo[3] ^ f_rnd_ex7_res_expo[4] ^ f_rnd_ex7_res_expo[5] ^ f_rnd_ex7_res_expo[6] ^ f_rnd_ex7_res_expo[7] ^ f_rnd_ex7_res_expo[8] ^ f_rnd_ex7_res_expo[9];
   assign frt_data_parity[1] = f_rnd_ex7_res_expo[10] ^ f_rnd_ex7_res_expo[11] ^ f_rnd_ex7_res_expo[12] ^ f_rnd_ex7_res_expo[13] ^ f_rnd_ex7_res_frac[0] ^ f_rnd_ex7_res_frac[1] ^ f_rnd_ex7_res_frac[2] ^ f_rnd_ex7_res_frac[3] ^ f_rnd_ex7_res_frac[4];
   assign frt_data_parity[2] = f_rnd_ex7_res_frac[5] ^ f_rnd_ex7_res_frac[6] ^ f_rnd_ex7_res_frac[7] ^ f_rnd_ex7_res_frac[8] ^ f_rnd_ex7_res_frac[9] ^ f_rnd_ex7_res_frac[10] ^ f_rnd_ex7_res_frac[11] ^ f_rnd_ex7_res_frac[12];
   assign frt_data_parity[3] = f_rnd_ex7_res_frac[13] ^ f_rnd_ex7_res_frac[14] ^ f_rnd_ex7_res_frac[15] ^ f_rnd_ex7_res_frac[16] ^ f_rnd_ex7_res_frac[17] ^ f_rnd_ex7_res_frac[18] ^ f_rnd_ex7_res_frac[19] ^ f_rnd_ex7_res_frac[20];
   assign frt_data_parity[4] = f_rnd_ex7_res_frac[21] ^ f_rnd_ex7_res_frac[22] ^ f_rnd_ex7_res_frac[23] ^ f_rnd_ex7_res_frac[24] ^ f_rnd_ex7_res_frac[25] ^ f_rnd_ex7_res_frac[26] ^ f_rnd_ex7_res_frac[27] ^ f_rnd_ex7_res_frac[28];
   assign frt_data_parity[5] = f_rnd_ex7_res_frac[29] ^ f_rnd_ex7_res_frac[30] ^ f_rnd_ex7_res_frac[31] ^ f_rnd_ex7_res_frac[32] ^ f_rnd_ex7_res_frac[33] ^ f_rnd_ex7_res_frac[34] ^ f_rnd_ex7_res_frac[35] ^ f_rnd_ex7_res_frac[36];
   assign frt_data_parity[6] = f_rnd_ex7_res_frac[37] ^ f_rnd_ex7_res_frac[38] ^ f_rnd_ex7_res_frac[39] ^ f_rnd_ex7_res_frac[40] ^ f_rnd_ex7_res_frac[41] ^ f_rnd_ex7_res_frac[42] ^ f_rnd_ex7_res_frac[43] ^ f_rnd_ex7_res_frac[44];
   assign frt_data_parity[7] = f_rnd_ex7_res_frac[45] ^ f_rnd_ex7_res_frac[46] ^ f_rnd_ex7_res_frac[47] ^ f_rnd_ex7_res_frac[48] ^ f_rnd_ex7_res_frac[49] ^ f_rnd_ex7_res_frac[50] ^ f_rnd_ex7_res_frac[51] ^ f_rnd_ex7_res_frac[52];

   //----------------------------------------------------------------------
   // Source Address

   generate
      if (threads == 1)
      begin : addr_gen_1
         assign rf0_fra_addr[1:7] = {1'b0, f_dcd_rf0_fra[0:5]};		//uc_hook
         assign rf0_frb_addr[1:7] = {1'b0, f_dcd_rf0_frb[0:5]};
         assign rf0_frc_addr[1:7] = {1'b0, f_dcd_rf0_frc[0:5]};
      end
   endgenerate

   generate
      if (threads == 2)
      begin : addr_gen_2
         assign rf0_fra_addr[1:7] = {f_dcd_rf0_fra[0:5], f_dcd_rf0_tid[1]};		//uc_hook
         assign rf0_frb_addr[1:7] = {f_dcd_rf0_frb[0:5], f_dcd_rf0_tid[1]};
         assign rf0_frc_addr[1:7] = {f_dcd_rf0_frc[0:5], f_dcd_rf0_tid[1]};
      end
   endgenerate

   assign rf0_frs_addr[1:7] = iu_fu_rf0_ldst_tag[3:9];

   // Microcode Scratch Registers
   assign rf0_fra_addr[0] = tilo;		// uc_hook
   assign rf0_frb_addr[0] = tilo;
   assign rf0_frc_addr[0] = tilo;

   assign frt_addr[0] = tilo;
   assign rf0_frs_addr[0] = tilo;		// Don't need to store from scratch regs
   assign load_addr[0] = tilo;		// Don't need to load into scratch regs

   // For bypass writethru compare
   assign f_fpr_ex6_load_addr[0:7] = {1'b0, ex6_load_tag[3:9]};	// bit 9 is the tid
   assign f_fpr_ex6_reload_addr[0:7] = {1'b0, ex6_reload_tag[3:9]};	// bit 9 is the tid

   assign f_fpr_ex6_load_v = load_wen;
   assign f_fpr_ex6_reload_v =  reload_wen;

   //----------------------------------------------------------------------
   // RF0

   //----------------------------------------------------------------------
   // RF1

   assign w0e_en_func = load_wen;
   assign w0e_addr_func[0:7] = load_addr[0:7];
   assign w0l_en_func = frt_wen;
   assign w0l_addr_func[0:7] = frt_addr[0:7];

   //parity(0 to 7)<= data(66 to 73)    0:7
   //"000"                              8:10
   //sign          <= data(0);          11
   //expo(1)                            12
   //expo(2 to 13) <= data(1 to 12);    13:24
   //frac(0 to 52) <= data(13 to 65);   25:77

   assign w0e_data_func_f0[0:77] = {load_data_f0[66:73], 3'b000, load_data_f0[0], 1'b0, load_data_f0[1:65]};
   assign w0e_data_func_f1[0:77] = {load_data_f1[66:73], 3'b000, load_data_f1[0], 1'b0, load_data_f1[1:65]};

   assign rel_data_func_f0[0:77] = {reload_data_f0[66:73], 3'b000, reload_data_f0[0], 1'b0, reload_data_f0[1:65]};
   assign rel_data_func_f1[0:77] = {reload_data_f1[66:73], 3'b000, reload_data_f1[0], 1'b0, reload_data_f1[1:65]};


   assign w0l_data_func_f0[0:77] = {frt_data_parity[0:7], 3'b000, f_rnd_ex7_res_sign, f_rnd_ex7_res_expo[1:13], f_rnd_ex7_res_frac[0:52]};
   assign w0l_data_func_f1[0:77] = {frt_data_parity[0:6], (frt_data_parity[7] ^ ex7_targ_perr_inj), 3'b000, f_rnd_ex7_res_sign, f_rnd_ex7_res_expo[1:13], f_rnd_ex7_res_frac[0:52]};

   assign rf1_fra[0:77] = fra_data_out[0:77];		//frac
   assign rf1_frb[0:77] = frb_data_out[0:77];		//frac
   assign rf1_frc[0:77] = frc_data_out[0:77];		//frac
   assign rf1_frs[0:77] = frs_data_out[0:77];		//frac

   //   -- Array Instantiation
   //   f0 : entity tri.tri_144x78_2r2w
   //   generic map (expand_type => expand_type)
   //   port map(
   //      vdd                            => vdd                            ,
   //      gnd                            => gnd                            ,
   //      nclk                           => nclk                           ,
   //      abist_en                       => pc_fu_abist_ena_dc             ,
   //      abist_raw_dc_b                 => pc_fu_abist_raw_dc_b           ,
   //      r0e_abist_comp_en              => r0e_abist_comp_en              ,
   //      r1e_abist_comp_en              => r1e_abist_comp_en              ,
   //--    lbist_en                       => lbist_en_dc                    ,
   //--    tri_state_en                   => tri_state_en                   ,
   //      lcb_act_dis_dc                 => lcb_act_dis_dc                 ,
   //      lcb_clkoff_dc_b                => lcb_clkoff_dc_b                ,
   //      lcb_d_mode_dc                  => lcb_d_mode_dc                  ,
   //      lcb_delay_lclkr_dc             => lcb_delay_lclkr_dc             ,
   //      lcb_fce_0                      => fce_0                          ,
   //      lcb_mpw1_dc_b                  => lcb_mpw1_dc_b(1 to 6)          ,
   //      lcb_mpw2_dc_b                  => lcb_mpw2_dc_b                  ,
   //      lcb_scan_diag_dc               => scan_diag_dc                   ,
   //      lcb_scan_dis_dc_b              => scan_dis_dc_b                  ,
   //      lcb_sg_0                       => lcb_sg_0                       ,
   //      lcb_abst_sl_thold_0            => lcb_abst_sl_thold_0            ,
   //      lcb_ary_nsl_thold_0            => ary_nsl_thold_0                ,
   //      r_scan_in                      => r_scan_in_0                    ,
   //      r_scan_out                     => r_scan_out_0                   ,
   //      w_scan_in                      => w_scan_in_0                    ,
   //      w_scan_out                     => w_scan_out_0                   ,
   //      -- Read Port FRA
   //      r0e_act                        => r0e_act                        ,
   //      r0e_en_func                    => r0e_en_func                    ,
   //      r0e_en_abist                   => r0e_en_abist                   ,
   //      r0e_addr_func                  => rf0_fra_addr                   ,
   //      r0e_addr_abist                 => r0e_addr_abist                 ,
   //      r0e_data_out                   => fra_data_out                   ,
   //      r0e_byp_e                      => rf1_bypsel_a_load1       ,
   //      r0e_byp_l                      => rf1_bypsel_a_res1        ,
   //      r0e_byp_r                      => rf1_a_r0e_byp_r,
   //      -- Read Port FRC
   //      r1e_act                        => r1e_act                        ,
   //      r1e_en_func                    => r1e_en_func                    ,
   //      r1e_en_abist                   => r1e_en_abist                   ,
   //      r1e_addr_func                  => rf0_frc_addr                   ,
   //      r1e_addr_abist                 => r1e_addr_abist                 ,
   //      r1e_data_out                   => frc_data_out                   ,
   //      r1e_byp_e                      => rf1_bypsel_c_load1       ,
   //      r1e_byp_l                      => rf1_bypsel_c_res1        ,
   //      r1e_byp_r                      => rf1_c_r1e_byp_r,
   //      -- Write Ports
   //      w0e_act                        => w0e_act                        ,
   //      w0e_en_func                    => w0e_en_func                    ,
   //      w0e_en_abist                   => w0e_en_abist                   ,
   //      w0e_addr_func                  => w0e_addr_func                  ,
   //      w0e_addr_abist                 => w0e_addr_abist                 ,
   //      w0e_data_func                  => w0e_data_func                  ,
   //      w0e_data_abist                 => w0e_data_abist                 ,
   //      w0e_pw_sel                     => "0000",  -- TODO
   //      w0e_rsdly_sel                  => "00",    -- TODO
   //      w0l_act                        => w0l_act                        ,
   //      w0l_en_func                    => w0l_en_func                    ,
   //      w0l_en_abist                   => w0l_en_abist                   ,
   //      w0l_addr_func                  => w0l_addr_func                  ,
   //      w0l_addr_abist                 => w0l_addr_abist                 ,
   //      w0l_data_func                  => w0l_data_func                  ,
   //      w0l_data_abist                 => w0l_data_abist                 ,
   //      w0l_pw_sel                     => "0000",  -- TODO
   //      w0l_rsdly_sel                  => "00"     -- TODO
   //      );

   //   -- Array Instantiation
   //   f1 : entity tri.tri_144x78_2r2w
   //   generic map (expand_type => expand_type)
   //   port map(
   //      vdd                            => vdd                            ,
   //      gnd                            => gnd                            ,
   //      nclk                           => nclk                           ,
   //      abist_en                       => pc_fu_abist_ena_dc             ,
   //      abist_raw_dc_b                 => pc_fu_abist_raw_dc_b           ,
   //      r0e_abist_comp_en              => r0e_abist_comp_en              ,
   //      r1e_abist_comp_en              => r1e_abist_comp_en              ,
   //--    lbist_en                       => lbist_en_dc                    ,
   //--    tri_state_en                   => tri_state_en                   ,
   //      lcb_act_dis_dc                 => lcb_act_dis_dc                 ,
   //      lcb_clkoff_dc_b                => lcb_clkoff_dc_b                ,
   //      lcb_d_mode_dc                  => lcb_d_mode_dc                  ,
   //      lcb_delay_lclkr_dc             => lcb_delay_lclkr_dc             ,
   //      lcb_fce_0                      => fce_0                          ,
   //      lcb_mpw1_dc_b                  => lcb_mpw1_dc_b(1 to 6)          ,
   //      lcb_mpw2_dc_b                  => lcb_mpw2_dc_b                  ,
   //      lcb_scan_diag_dc               => scan_diag_dc                   ,
   //      lcb_scan_dis_dc_b              => scan_dis_dc_b                  ,
   //      lcb_sg_0                       => lcb_sg_0                       ,
   //      lcb_abst_sl_thold_0            => lcb_abst_sl_thold_0            ,
   //      lcb_ary_nsl_thold_0            => ary_nsl_thold_0                ,
   //      r_scan_in                      => r_scan_in_1                    ,
   //      r_scan_out                     => r_scan_out_1                   ,
   //      w_scan_in                      => w_scan_in_1                    ,
   //      w_scan_out                     => w_scan_out_1                   ,
   //      -- Read Port FRB
   //      r0e_act                        => r0e_act                        ,
   //      r0e_en_func                    => r0e_en_func                    ,
   //      r0e_en_abist                   => r0e_en_abist                   ,
   //      r0e_addr_func                  => rf0_frb_addr                   ,
   //      r0e_addr_abist                 => r0e_addr_abist                 ,
   //      r0e_data_out                   => frb_data_out                   ,
   //      r0e_byp_e                      => rf1_bypsel_b_load1       ,
   //      r0e_byp_l                      => rf1_bypsel_b_res1        ,
   //      r0e_byp_r                      => rf1_b_r0e_byp_r,
   //      -- Read Port FRS
   //      r1e_act                        => r1e_act                        ,
   //      r1e_en_func                    => r1e_en_func                    ,
   //      r1e_en_abist                   => r1e_en_abist                   ,
   //      r1e_addr_func                  => rf0_frs_addr                   ,
   //      r1e_addr_abist                 => r1e_addr_abist                 ,
   //      r1e_data_out                   => frs_data_out                   ,
   //      r1e_byp_e                      => rf1_bypsel_s_load1             ,
   //      r1e_byp_l                      => rf1_bypsel_s_res1              ,
   //      r1e_byp_r                      => rf1_s_r1e_byp_r,
   //      -- Write Ports
   //      w0e_act                        => w0e_act                        ,
   //      w0e_en_func                    => w0e_en_func                    ,
   //      w0e_en_abist                   => w0e_en_abist                   ,
   //      w0e_addr_func                  => w0e_addr_func                  ,
   //      w0e_addr_abist                 => w0e_addr_abist                 ,
   //      w0e_data_func                  => w0e_data_func                  ,
   //      w0e_data_abist                 => w0e_data_abist                 ,
   //      w0e_pw_sel                     => "0000",  -- TODO
   //      w0e_rsdly_sel                  => "00",    -- TODO
   //      w0l_act                        => w0l_act                        ,
   //      w0l_en_func                    => w0l_en_func                    ,
   //      w0l_en_abist                   => w0l_en_abist                   ,
   //      w0l_addr_func                  => w0l_addr_func                  ,
   //      w0l_addr_abist                 => w0l_addr_abist                 ,
   //      w0l_data_func                  => w0l_data_func                  ,
   //      w0l_data_abist                 => w0l_data_abist                 ,
   //      w0l_pw_sel                     => "0000",  -- TODO
   //      w0l_rsdly_sel                  => "00"     -- TODO
   //      );

   //

   assign r0e_en_func = tiup;
   assign r1e_en_func = tiup;


   tri_144x78_2r4w  fpr0( // .regsize(64),  #( .gpr_pool(fpr_pool), .gpr_pool_enc(fpr_pool_enc))
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .delay_lclkr_dc(delay_lclkra[0]),
      .mpw1_dc_b(mpw1_ba[0]),
      .mpw2_dc_b(mpw2_b[0]),
      .func_sl_force(force_t),
      .func_sl_thold_0_b(thold_0_b),
      .func_slp_sl_force(force_t),
      .func_slp_sl_thold_0_b(thold_0_b),
      .sg_0(sg_0),
      .scan_in(scan_in_0),
      .scan_out(scan_out_0),
      // Read Port FRA
      .r_late_en_1(r0e_en_func),
      .r_addr_in_1(rf0_fra_addr[(3 - threads):7]),		// rf0_fra_addr(1 to 7),
      .r_data_out_1(fra_data_out),
      // Read Port FRC
      .r_late_en_2(r1e_en_func),
      .r_addr_in_2(rf0_frc_addr[(3 - threads):7]),		//rf0_frc_addr(1 to 7),
      .r_data_out_2(frc_data_out),
      // Write Ports
      .w_late_en_1(w0e_en_func),
      .w_addr_in_1(w0e_addr_func[(3 - threads):7]),		//w0e_addr_func(1 to 7),
      .w_data_in_1(w0e_data_func_f0),
      .w_late_en_2(w0l_en_func),
      .w_addr_in_2(w0l_addr_func[(3 - threads):7]),		//w0l_addr_func(1 to 7)
      .w_data_in_2(w0l_data_func_f0),
      .w_late_en_3(reload_wen),
      .w_addr_in_3(reload_addr[(3 - threads):7]),		//reload_addr(1 to 7),
      .w_data_in_3(rel_data_func_f0),
      .w_late_en_4(tilo),
      .w_addr_in_4(zeros[(3 - threads):7]),
      .w_data_in_4(zeros[0:77])
   );


   tri_144x78_2r4w  fpr1(// .regsize(64),#(  .gpr_pool(fpr_pool), .gpr_pool_enc(fpr_pool_enc))
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .delay_lclkr_dc(delay_lclkra[0]),
      .mpw1_dc_b(mpw1_ba[0]),
      .mpw2_dc_b(mpw2_b[0]),
      .func_sl_force(force_t),
      .func_sl_thold_0_b(thold_0_b),
      .func_slp_sl_force(force_t),
      .func_slp_sl_thold_0_b(thold_0_b),
      .sg_0(sg_0),
      .scan_in(scan_in_1),
      .scan_out(scan_out_1),
      // Read Port FRB
      .r_late_en_1(r0e_en_func),
      .r_addr_in_1(rf0_frb_addr[(3 - threads):7]),		//rf0_frb_addr(1 to 7),
      .r_data_out_1(frb_data_out),
      // Read Port FRS
      .r_late_en_2(r1e_en_func),
      .r_addr_in_2(rf0_frs_addr[(3 - threads):7]),		//rf0_frs_addr(1 to 7),
      .r_data_out_2(frs_data_out),
      // Write Ports
      .w_late_en_1(w0e_en_func),
      .w_addr_in_1(w0e_addr_func[(3 - threads):7]),		//w0e_addr_func(1 to 7),
      .w_data_in_1(w0e_data_func_f1),
      .w_late_en_2(w0l_en_func),
      .w_addr_in_2(w0l_addr_func[(3 - threads):7]),		//w0l_addr_func(1 to 7),
      .w_data_in_2(w0l_data_func_f1),
      .w_late_en_3(reload_wen),
      .w_addr_in_3(reload_addr[(3 - threads):7]),		//reload_addr(1 to 7),
      .w_data_in_3(rel_data_func_f1),
      .w_late_en_4(tilo),
      .w_addr_in_4(zeros[(3 - threads):7]),
      .w_data_in_4(zeros[0:77])
   );

   // ABIST timing latches

   tri_rlmreg_p #(.INIT(0),  .WIDTH(53), .NEEDS_SRESET(0)) ab_reg(
      .nclk(nclk),
      .act(tihi),
      .force_t(ab_force),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkra[0]),
      .mpw1_b(mpw1_ba[0]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(ab_thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ab_reg_si[0:52]),
      .scout(ab_reg_so[0:52]),
      .din({  pc_fu_abist_di_0[0:3],
              pc_fu_abist_di_1[0:3],
              pc_fu_abist_grf_renb_0,
              pc_fu_abist_grf_renb_1,
              pc_fu_abist_grf_wenb_0,
              pc_fu_abist_grf_wenb_1,
	      pc_fu_abist_raddr_0[0:9],
	      pc_fu_abist_raddr_1[0:9],
	      pc_fu_abist_waddr_0[0:9],
              pc_fu_abist_waddr_1[0:9],
              pc_fu_abist_wl144_comp_ena}),
      .dout({ w0e_data_abist[0:3],
              w0l_data_abist[0:3],
              r0e_en_abist,
              r1e_en_abist,
              w0e_en_abist,
              w0l_en_abist,
	      abist_raddr_0[0:9],
	      abist_raddr_1[0:9],
	      abist_waddr_0[0:9],
              abist_waddr_1[0:9],
              abist_comp_en })
   );


   tri_lcbcntl_array_mac lcbctrl(
      .vdd(vdd),
      .gnd(gnd),
      .sg(sg_0),
      .nclk(nclk),
      .scan_in(time_scan_in),		// Connects to time scan ring
      .scan_diag_dc(scan_diag_dc),
      .thold(time_sl_thold_0),		//Connects to time thold
      .clkoff_dc_b(clkoff_dc_b),
      .delay_lclkr_dc(lcb_delay_lclkr_dc[0:4]),
      .act_dis_dc(lcb_act_dis_dc),
      .d_mode_dc(d_mode_dc),
      .mpw1_dc_b(lcb_mpw1_dc_b[0:4]),
      .mpw2_dc_b(lcb_mpw2_dc_b),
      .scan_out(time_scan_out)		// Connects to time scan ring
   );

   assign lcb_mpw1_dc_b[5:6] = 2'b00;		// TODO:  What is to be done with this?

   // Other inputs
   assign r0e_abist_comp_en = abist_comp_en;
   assign r1e_abist_comp_en = abist_comp_en;

   assign lcb_sg_0 = sg_0;
   assign lcb_abst_sl_thold_0 = ab_thold_0;

   assign lcb_d_mode_dc = d_mode_dc;
   assign lcb_clkoff_dc_b = {2{clkoff_dc_b}};


   assign r0e_addr_abist[0:7] = abist_raddr_0[2:9];

   assign r1e_addr_abist[0:7] = abist_raddr_1[2:9];
   assign w0e_act = 1'b1;
   assign w0e_addr_abist[0:7] = abist_waddr_1[2:9];
   assign w0l_act = 1'b1;
   assign w0l_addr_abist[0:7] = abist_waddr_1[2:9];

   //----------------------------------------------------------------------
   // Parity Checking


   tri_rlmreg_p #(.INIT(0), .WIDTH(34), .NEEDS_SRESET(0)) ex1_par(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkra[1]),
      .mpw1_b(mpw1_ba[1]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex1_par_si[0:33]),
      .scout(ex1_par_so[0:33]),
      .din({  rf1_fra[0:7],
	      rf1_frb[0:7],
	      rf1_frc[0:7],
              rf1_frs[0:7],
              rf1_frs[12:13]}),

      .dout({ ex1_fra_par[0:7],
	      ex1_frb_par[0:7],
	      ex1_frc_par[0:7],
              ex1_frs_par[0:7],
              ex1_s_expo_extra[0:1]})
   );

   assign f_fpr_ex2_a_par[0:7] = ex1_fra_par[0:7];
   assign f_fpr_ex2_b_par[0:7] = ex1_frb_par[0:7];
   assign f_fpr_ex2_c_par[0:7] = ex1_frc_par[0:7];
   assign f_fpr_ex2_s_par[0:7] = ex1_frs_par[0:7];

   //----------------------------------------------------------------------
   // Read Port Outputs

   //parity(0 to 7)<= data(66 to 73)    0:7
   //"000"                              8:10
   //sign          <= data(0);          11
   //expo(1)                            12
   //expo(2 to 13) <= data(1 to 12);    13:24
   //frac(0 to 52) <= data(13 to 65);   25:77

   assign f_fpr_ex1_a_sign = rf1_fra[11];
   assign f_fpr_ex1_a_expo[1:13] = rf1_fra[12:24];
   assign f_fpr_ex1_a_frac[0:52] = rf1_fra[25:77];
   assign f_fpr_ex1_c_sign = rf1_frc[11];
   assign f_fpr_ex1_c_expo[1:13] = rf1_frc[12:24];
   assign f_fpr_ex1_c_frac[0:52] = rf1_frc[25:77];
   assign f_fpr_ex1_b_sign = rf1_frb[11];
   assign f_fpr_ex1_b_expo[1:13] = rf1_frb[12:24];
   assign f_fpr_ex1_b_frac[0:52] = rf1_frb[25:77];

   assign f_fpr_ex1_s_sign = rf1_frs[11];
   assign f_fpr_ex1_s_expo[1:11] = rf1_frs[14:24];
   assign f_fpr_ex1_s_frac[0:52] = rf1_frs[25:77];
   // For Parity checking only, not used by store
   assign f_fpr_ex2_s_expo_extra = ex1_s_expo_extra;

   //----------------------------------------------------------------------
   // Write-thru bypass

   // Load Bypass


   tri_rlmreg_p #(.INIT(0),  .WIDTH(132), .NEEDS_SRESET(0)) ldwt_lat(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkrb[7]),  //todo, break out into ex7, ex8
      .mpw1_b(mpw1_bb[7]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ldwt_lat_si[0:131]),
      .scout(ldwt_lat_so[0:131]),
      //-------------------------------------------
      .din({ ex6_load_data_byp[0:65],
             ex7_load_data_byp[0:65] }),
      //-------------------------------------------
      .dout({ex7_load_data_byp[0:65],
             ex8_load_data_byp[0:65] })
   );
   //-------------------------------------------
   tri_rlmreg_p #(.INIT(0),  .WIDTH(132), .NEEDS_SRESET(0)) reldwt_lat(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkrb[7]),
      .mpw1_b(mpw1_bb[7]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(reldwt_lat_si[0:131]),
      .scout(reldwt_lat_so[0:131]),
      //-------------------------------------------
      .din({ ex6_reload_data_byp[0:65],
             ex7_reload_data_byp[0:65] }),
      //-------------------------------------------
      .dout({ex7_reload_data_byp[0:65],
             ex8_reload_data_byp[0:65] })
   );
   //-------------------------------------------

   assign ex6_reload_data_byp = ex6_reload_data[0:65];

   assign ex6_load_data_byp = ex6_load_data[0:65];


   assign f_fpr_ex6_load_sign = ex6_load_data_byp[0];
   assign f_fpr_ex6_load_expo[3:13] = ex6_load_data_byp[2:12];
   assign f_fpr_ex6_load_frac[0:52] = ex6_load_data_byp[13:65];

   // Latched Write Ports for bypass
   assign f_fpr_ex7_load_sign = ex7_load_data_byp[0];
   assign f_fpr_ex7_load_expo[3:13] = ex7_load_data_byp[2:12];
   assign f_fpr_ex7_load_frac[0:52] = ex7_load_data_byp[13:65];

   assign f_fpr_ex8_load_sign = ex8_load_data_byp[0];
   assign f_fpr_ex8_load_expo[3:13] = ex8_load_data_byp[2:12];
   assign f_fpr_ex8_load_frac[0:52] = ex8_load_data_byp[13:65];

// reload

   assign f_fpr_ex6_reload_sign = ex6_reload_data_byp[0];
   assign f_fpr_ex6_reload_expo[3:13] = ex6_reload_data_byp[2:12];
   assign f_fpr_ex6_reload_frac[0:52] = ex6_reload_data_byp[13:65];

   // Latched Write Ports for bypass
   assign f_fpr_ex7_reload_sign = ex7_reload_data_byp[0];
   assign f_fpr_ex7_reload_expo[3:13] = ex7_reload_data_byp[2:12];
   assign f_fpr_ex7_reload_frac[0:52] = ex7_reload_data_byp[13:65];

   assign f_fpr_ex8_reload_sign = ex8_reload_data_byp[0];
   assign f_fpr_ex8_reload_expo[3:13] = ex8_reload_data_byp[2:12];
   assign f_fpr_ex8_reload_frac[0:52] = ex8_reload_data_byp[13:65];


   // Target Bypass

   tri_rlmreg_p #(.INIT(0),  .WIDTH(134), .NEEDS_SRESET(0)) tgwt_lat(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkrb[7]),// todo, need 8,9?
      .mpw1_b(mpw1_bb[7]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(tgwt_lat_si[0:133]),
      .scout(tgwt_lat_so[0:133]),
      //-------------------------------------------
      .din({ex7_frt_data[0:66],
            ex8_frt_data[0:66] }),
      //-------------------------------------------
      .dout({ex8_frt_data[0:66],
             ex9_frt_data[0:66] })
   );
   //-------------------------------------------

   assign ex7_frt_data[0] = f_rnd_ex7_res_sign;
   assign ex7_frt_data[1:13] = f_rnd_ex7_res_expo[1:13];
   assign ex7_frt_data[14:66] = f_rnd_ex7_res_frac[0:52];

   assign f_fpr_ex8_frt_sign = ex8_frt_data[0];
   assign f_fpr_ex8_frt_expo[1:13] = ex8_frt_data[1:13];
   assign f_fpr_ex8_frt_frac[0:52] = ex8_frt_data[14:66];

   assign f_fpr_ex9_frt_sign = ex9_frt_data[0];
   assign f_fpr_ex9_frt_expo[1:13] = ex9_frt_data[1:13];
   assign f_fpr_ex9_frt_frac[0:52] = ex9_frt_data[14:66];

   //----------------------------------------------------------------------
   // Scan Chains

   assign ex7_ldat_si[0:63] = {ex7_ldat_so[1:63], f_fpr_si};
   assign ex7_rldat_si[0:63] = {ex7_rldat_so[1:63], ex7_ldat_so[0]};

   assign ex7_ldv_si[0:1] = {ex7_ldv_so[1], ex7_rldat_so[0]};
   assign ex7_lctl_si[0:11] = {ex7_lctl_so[1:11], ex7_ldv_so[0]};
   assign ex7_rlctl_si[0:9] = {ex7_rlctl_so[1:9], ex7_lctl_so[0]};

   assign ex6_lctl_si[0:4] = {ex6_lctl_so[1:4], ex7_rlctl_so[0]};
   assign ex1_par_si[0:33] = {ex1_par_so[1:33], ex6_lctl_so[0]};
   assign ldwt_lat_si[0:131] = {ldwt_lat_so[1:131], ex1_par_so[0]};
   assign reldwt_lat_si[0:131] = {reldwt_lat_so[1:131],ldwt_lat_so[0] };
   assign tgwt_lat_si[0:133] = {tgwt_lat_so[1:133], reldwt_lat_so[0]};



    assign f_fpr_so = tgwt_lat_so[0];


   assign scan_in_0 = f_fpr_ab_si;
   assign scan_in_1 = scan_out_0;

   assign ab_reg_si[0:52] = {ab_reg_so[1:52], scan_out_1};
   assign f_fpr_ab_so = ab_reg_so[0];

   //----------------------------------------------------------------------
   // Unused

   assign spare_unused[2:4] = iu_fu_rf0_ldst_tag[0:2];
   assign spare_unused[5:7] = rf1_fra[8:10];
   assign spare_unused[8:10] = rf1_frb[8:10];
   assign spare_unused[11:13] = rf1_frc[8:10];
   assign spare_unused[14:16] = rf1_frs[8:10];

   assign spare_unused[17:18] = abist_raddr_0[0:1];
   assign spare_unused[19:20] = abist_raddr_1[0:1];
   assign spare_unused[21:22] = abist_waddr_0[0:1];
   assign spare_unused[23:24] = abist_waddr_1[0:1];
   assign spare_unused[25] = lcb_mpw1_dc_b[0];

endmodule
