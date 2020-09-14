// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.


`include "tri_a2o.vh"

module tri_st_mult(
   nclk,
   vdd,
   gnd,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   func_sl_force,
   func_sl_thold_0_b,
   sg_0,
   scan_in,
   scan_out,
   dec_mul_ex1_mul_recform,
   dec_mul_ex1_mul_val,
   dec_mul_ex1_mul_ord,
   dec_mul_ex1_mul_ret,
   dec_mul_ex1_mul_sign,
   dec_mul_ex1_mul_size,
   dec_mul_ex1_mul_imm,
   dec_mul_ex1_xer_ov_update,
   cp_flush,
   ex1_spr_msr_cm,
   byp_mul_ex2_rs1,
   byp_mul_ex2_rs2,
   byp_mul_ex2_abort,
   byp_mul_ex2_xer,
   mul_byp_ex6_rt,
   mul_byp_ex6_xer,
   mul_byp_ex6_cr,
   mul_byp_ex5_abort,
   mul_byp_ex5_ord_done,
   mul_byp_ex5_done,
   mul_spr_running
);
   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) 
   input [0:`NCLK_WIDTH-1] nclk;
   inout                  vdd;
   inout                  gnd;
   
   input                  d_mode_dc;
   input                  delay_lclkr_dc;
   input                  mpw1_dc_b;
   input                  mpw2_dc_b;
   input                  func_sl_force;
   input                  func_sl_thold_0_b;
   input                  sg_0;
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *) 
   input                  scan_in;
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) 
   output                 scan_out;
   
   input                  dec_mul_ex1_mul_recform;
   input [0:`THREADS-1]   dec_mul_ex1_mul_val;
   input                  dec_mul_ex1_mul_ord;
   input                  dec_mul_ex1_mul_ret;		
   input                  dec_mul_ex1_mul_sign;		
   input                  dec_mul_ex1_mul_size;		
   input                  dec_mul_ex1_mul_imm;		
   input                  dec_mul_ex1_xer_ov_update;
   input [0:`THREADS-1]   cp_flush;
   
   input                  ex1_spr_msr_cm;
   
   input [0:`GPR_WIDTH-1] byp_mul_ex2_rs1;
   input [0:`GPR_WIDTH-1] byp_mul_ex2_rs2;
   input                  byp_mul_ex2_abort;
   input [0:9]            byp_mul_ex2_xer;
   
   output [0:`GPR_WIDTH-1] mul_byp_ex6_rt;
   output [0:9]           mul_byp_ex6_xer;
   output [0:3]           mul_byp_ex6_cr;
   
   output                 mul_byp_ex5_abort;
   output                 mul_byp_ex5_ord_done;
   output                 mul_byp_ex5_done;
   output [0:`THREADS-1]  mul_spr_running;
   

   wire [0:3]             ex2_mulstage;
   wire [0:3]             ex2_mulstage_shift;
   wire [0:3]             ex3_ready_stage;
   wire                   ex6_cmp0_eq;
   wire                   ex6_cmp0_gt;
   wire                   ex6_cmp0_lt;
   wire                   ex6_xer_ov;
   wire                   ex6_xer_so;
   wire                   ex6_xer_ov_gated;
   wire [196:264]         ex4_recycle_s;
   wire [196:264]         ex4_recycle_c;
   wire [196:264]         ex5_pp5_0s;
   wire [196:264]         ex5_pp5_0c;
   wire                   ex4_recyc_sh00;
   wire                   ex4_recyc_sh32;
   wire                   ex4_xtd;
   wire                   ex4_xtd_196_or;
   wire                   ex4_xtd_196_and;
   wire                   ex4_xtd_197_or;
   wire                   ex4_xtd_197_and;
   wire                   ex4_xtd_ge1;
   wire                   ex4_xtd_ge2;
   wire                   ex4_xtd_ge3;
   wire                   ex2_bs_sign;
   wire                   ex2_bd_sign;
   wire [0:63]            ex5_xi;
   wire [0:63]            ex5_yi;
   wire [0:63]            ex5_p;
   wire [1:63]            ex5_g;
   wire [1:63]            ex5_t;
   wire [0:63]            ex5_res;
   wire                   rslt_lo_act;
   wire                   ex5_ret_mulhw;
   wire                   ex5_ret_mullw;
   wire                   ex5_ret_mulli;
   wire                   ex5_ret_mulld;
   wire                   ex5_ret_mulldo;
   wire                   ex5_ret_mulhd;

   wire [0:63]            ex6_result;
   wire [0:63]            ex5_all0_test;
   wire                   ex5_all0_test_mid;
   wire [0:63]            ex5_all1_test;
   wire                   ex5_all1_test_mid;
   wire                   ex5_all0;
   wire                   ex5_all1;
   wire                   ex5_all0_lo;
   wire                   ex5_all0_hi;
   wire                   ex5_all1_hi;
   wire                   ex6_sign_rt_cmp0;
   wire                   ex6_eq;
   wire                   ex5_cout_32;
   wire [0:63]            ex5_xi_b;
   wire [0:63]            ex5_yi_b;
   wire                   ex2_mulsrc0_act;
   wire                   ex2_mulsrc1_act;
   wire [32:63]           ex3_bs_lo;
   wire [32:63]           ex3_bd_lo;
   wire                   ex3_act;
   wire                   ex4_act;
   wire                   ex5_act;
   wire                   ex1_mul_val;
   wire [0:63]            ex6_rslt_hw;
   wire [0:63]            ex6_rslt_ld_li;
   wire [0:63]            ex6_rslt_ldo;
   wire [0:63]            ex6_rslt_lw_hd;

   wire                   ex2_spr_msr_cm_q;		
   wire                   ex3_spr_msr_cm_q;		
   wire                   ex4_spr_msr_cm_q;		
   wire                   ex5_spr_msr_cm_q;		
   wire                   ex2_mul_is_ord_q;		
   wire                   ex3_mul_is_ord_q;		
   wire                   ex4_mul_is_ord_q;		
   wire                   ex5_mul_is_ord_q;		
   wire [0:9]             ex3_xer_src_q;		
   wire [0:9]             ex4_xer_src_q;		
   wire [0:9]             ex5_xer_src_q;		
   wire [0:9]             ex6_xer_src_q;		
   wire                   ex2_mul_val_q;		
   wire [0:3]             ex3_mulstage_d;    
   wire [0:3]             ex4_mulstage_d;
   wire [0:3]             ex5_mulstage_d;
   wire [0:3]             ex6_mulstage_d;
   wire [0:3]             ex3_mulstage_q;		
   wire [0:3]             ex4_mulstage_q;
   wire [0:3]             ex5_mulstage_q;
   wire [0:3]             ex6_mulstage_q;
   wire                   ex2_is_recform_q;		
   wire                   ex3_is_recform_q;
   wire                   ex4_is_recform_q;
   wire                   ex5_is_recform_q;
   wire                   ex6_is_recform_q;
   wire [0:2]             ex2_retsel_q;		
   wire [0:2]             ex2_retsel_d;
   wire [0:2]             ex3_retsel_q;
   wire [0:2]             ex4_retsel_q;
   wire [0:2]             ex5_retsel_q;
   wire [3:8]             exx_mul_abort_d;
   wire [3:8]             exx_mul_abort_q;
   wire                   ex2_mul_size_q;
   wire                   ex2_mul_sign_q;
   wire                   ex4_mul_done_q;		
   wire                   ex4_mul_done_d;
   wire                   ex5_mul_done_q;
   wire                   ex2_xer_ov_update_q;		
   wire                   ex3_xer_ov_update_q;
   wire                   ex4_xer_ov_update_q;
   wire                   ex5_xer_ov_update_q;
   wire                   ex6_xer_ov_update_q;
   wire                   ex3_bs_lo_sign_q;		
   wire                   ex3_bs_lo_sign_d;
   wire                   ex3_bd_lo_sign_q;
   wire                   ex3_bd_lo_sign_d;
   wire                   ex5_ci_q;
   wire                   ex5_ci_d;
   wire [0:63]            ex6_res_q;
   wire                   ex6_all0_q;		
   wire                   ex6_all1_q;
   wire                   ex6_all0_lo_q;
   wire                   ex6_all0_hi_q;
   wire                   ex6_all1_hi_q;
   wire                   carry_32_dly1_q;		
   wire                   all0_lo_dly1_q;		
   wire                   all0_lo_dly2_q;
   wire                   all0_lo_dly3_q;
   wire [0:31]            rslt_lo_q;		
   wire [0:31]            rslt_lo_d;
   wire [0:31]            rslt_lo_dly_q;		
   wire [0:31]            rslt_lo_dly_d;
   wire [0:63]            ex3_mulsrc_0_q;		
   wire [0:63]            ex2_mulsrc_0;
   wire [0:63]            ex3_mulsrc_1_q;		
   wire [0:63]            ex2_mulsrc_1;
   wire [0:7]             ex6_rslt_hw_q;
   wire [0:7]             ex6_rslt_hw_d;
   wire [0:7]             ex6_rslt_ld_li_q;
   wire [0:7]             ex6_rslt_ld_li_d;
   wire [0:7]             ex6_rslt_ldo_q;
   wire [0:7]             ex6_rslt_ldo_d;
   wire [0:7]             ex6_rslt_lw_hd_q;
   wire [0:7]             ex6_rslt_lw_hd_d;
   wire                   ex6_cmp0_sel_reshi_q;
   wire                   ex6_cmp0_sel_reshi_d;
   wire                   ex6_cmp0_sel_reslo_q;
   wire                   ex6_cmp0_sel_reslo_d;
   wire                   ex6_cmp0_sel_reslodly_q;
   wire                   ex6_cmp0_sel_reslodly_d;
   wire                   ex6_cmp0_sel_reslodly2_q;
   wire                   ex6_cmp0_sel_reslodly2_d;
   wire                   ex6_eq_sel_all0_b_q;
   wire                   ex6_eq_sel_all0_b_d;
   wire                   ex6_eq_sel_all0_hi_b_q;
   wire                   ex6_eq_sel_all0_hi_b_d;
   wire                   ex6_eq_sel_all0_lo_b_q;
   wire                   ex6_eq_sel_all0_lo_b_d;
   wire                   ex6_eq_sel_all0_lo1_b_q;
   wire                   ex6_eq_sel_all0_lo1_b_d;
   wire                   ex6_eq_sel_all0_lo2_b_q;
   wire                   ex6_eq_sel_all0_lo2_b_d;
   wire                   ex6_eq_sel_all0_lo3_b_q;
   wire                   ex6_eq_sel_all0_lo3_b_d;
   wire                   ex6_ret_mullw_q;
   wire                   ex6_ret_mulldo_q;
   wire                   ex6_cmp0_undef_q;
   wire                   ex6_cmp0_undef_d;
   wire [0:`THREADS-1]    cp_flush_q;		
   wire [0:`THREADS-1]    ex2_mul_tid_q;		
   wire [0:`THREADS-1]    ex3_mul_tid_q;		
   wire [0:`THREADS-1]    ex4_mul_tid_q;		
   wire [0:`THREADS-1]    ex5_mul_tid_q;		
   wire                   rslt_lo_act_q;		
   localparam             ex2_spr_msr_cm_offset = 1;
   localparam             ex3_spr_msr_cm_offset = ex2_spr_msr_cm_offset + 1;
   localparam             ex4_spr_msr_cm_offset = ex3_spr_msr_cm_offset + 1;
   localparam             ex5_spr_msr_cm_offset = ex4_spr_msr_cm_offset + 1;
   localparam             ex2_mul_is_ord_offset = ex5_spr_msr_cm_offset + 1;
   localparam             ex3_mul_is_ord_offset = ex2_mul_is_ord_offset + 1;
   localparam             ex4_mul_is_ord_offset = ex3_mul_is_ord_offset + 1;
   localparam             ex5_mul_is_ord_offset = ex4_mul_is_ord_offset + 1;
   localparam             ex3_xer_src_offset = ex5_mul_is_ord_offset + 1;
   localparam             ex4_xer_src_offset = ex3_xer_src_offset + 10;
   localparam             ex5_xer_src_offset = ex4_xer_src_offset + 10;
   localparam             ex6_xer_src_offset = ex5_xer_src_offset + 10;
   localparam             ex2_mul_val_offset = ex6_xer_src_offset + 10;
   localparam             ex3_mulstage_offset = ex2_mul_val_offset + 1;
   localparam             ex4_mulstage_offset = ex3_mulstage_offset + 4;
   localparam             ex5_mulstage_offset = ex4_mulstage_offset + 4;
   localparam             ex6_mulstage_offset = ex5_mulstage_offset + 4;
   localparam             ex2_retsel_offset = ex6_mulstage_offset + 4;
   localparam             ex3_retsel_offset = ex2_retsel_offset + 3;
   localparam             ex4_retsel_offset = ex3_retsel_offset + 3;
   localparam             ex5_retsel_offset = ex4_retsel_offset + 3;
   localparam             exx_mul_abort_offset = ex4_retsel_offset + 3;
   localparam             ex4_mul_done_offset = exx_mul_abort_offset + 6;
   localparam             ex5_mul_done_offset = ex4_mul_done_offset + 1;
   localparam             ex2_is_recform_offset = ex5_mul_done_offset + 1;
   localparam             ex3_is_recform_offset = ex2_is_recform_offset + 1;
   localparam             ex4_is_recform_offset = ex3_is_recform_offset + 1;
   localparam             ex5_is_recform_offset = ex4_is_recform_offset + 1;
   localparam             ex6_is_recform_offset = ex5_is_recform_offset + 1;
   localparam             ex2_xer_ov_update_offset = ex6_is_recform_offset + 1;
   localparam             ex3_xer_ov_update_offset = ex2_xer_ov_update_offset + 1;
   localparam             ex4_xer_ov_update_offset = ex3_xer_ov_update_offset + 1;
   localparam             ex5_xer_ov_update_offset = ex4_xer_ov_update_offset + 1;
   localparam             ex6_xer_ov_update_offset = ex5_xer_ov_update_offset + 1;
   localparam             ex2_mul_size_offset = ex6_xer_ov_update_offset + 1;
   localparam             ex2_mul_sign_offset = ex2_mul_size_offset + 1;
   localparam             ex3_bs_lo_sign_offset = ex2_mul_sign_offset + 1;
   localparam             ex3_bd_lo_sign_offset = ex3_bs_lo_sign_offset + 1;
   localparam             ex6_all0_offset = ex3_bd_lo_sign_offset + 1;
   localparam             ex6_all1_offset = ex6_all0_offset + 1;
   localparam             ex6_all0_lo_offset = ex6_all1_offset + 1;
   localparam             ex6_all0_hi_offset = ex6_all0_lo_offset + 1;
   localparam             ex6_all1_hi_offset = ex6_all0_hi_offset + 1;
   localparam             ex5_ci_offset = ex6_all1_hi_offset + 1;
   localparam             ex6_res_offset = ex5_ci_offset + 1;
   localparam             carry_32_dly1_offset = ex6_res_offset + 64;
   localparam             all0_lo_dly1_offset = carry_32_dly1_offset + 1;
   localparam             all0_lo_dly2_offset = all0_lo_dly1_offset + 1;
   localparam             all0_lo_dly3_offset = all0_lo_dly2_offset + 1;
   localparam             rslt_lo_offset = all0_lo_dly3_offset + 1;
   localparam             rslt_lo_dly_offset = rslt_lo_offset + 32;
   localparam             ex3_mulsrc_0_offset = rslt_lo_dly_offset + 32;
   localparam             ex3_mulsrc_1_offset = ex3_mulsrc_0_offset + 64;
   localparam             ex6_rslt_hw_offset = ex3_mulsrc_1_offset + 64;
   localparam             ex6_rslt_ld_li_offset = ex6_rslt_hw_offset + 8;
   localparam             ex6_rslt_ldo_offset = ex6_rslt_ld_li_offset + 8;
   localparam             ex6_rslt_lw_hd_offset = ex6_rslt_ldo_offset + 8;
   localparam             ex6_cmp0_sel_reshi_offset = ex6_rslt_lw_hd_offset + 8;
   localparam             ex6_cmp0_sel_reslo_offset = ex6_cmp0_sel_reshi_offset + 1;
   localparam             ex6_cmp0_sel_reslodly_offset = ex6_cmp0_sel_reslo_offset + 1;
   localparam             ex6_cmp0_sel_reslodly2_offset = ex6_cmp0_sel_reslodly_offset + 1;
   localparam             ex6_eq_sel_all0_b_offset = ex6_cmp0_sel_reslodly2_offset + 1;
   localparam             ex6_eq_sel_all0_hi_b_offset = ex6_eq_sel_all0_b_offset + 1;
   localparam             ex6_eq_sel_all0_lo_b_offset = ex6_eq_sel_all0_hi_b_offset + 1;
   localparam             ex6_eq_sel_all0_lo1_b_offset = ex6_eq_sel_all0_lo_b_offset + 1;
   localparam             ex6_eq_sel_all0_lo2_b_offset = ex6_eq_sel_all0_lo1_b_offset + 1;
   localparam             ex6_eq_sel_all0_lo3_b_offset = ex6_eq_sel_all0_lo2_b_offset + 1;
   localparam             ex6_ret_mullw_offset = ex6_eq_sel_all0_lo3_b_offset + 1;
   localparam             ex6_ret_mulldo_offset = ex6_ret_mullw_offset + 1;
   localparam             ex6_cmp0_undef_offset = ex6_ret_mulldo_offset + 1;
   localparam             cp_flush_offset = ex6_cmp0_undef_offset + 1;
   localparam             ex2_mul_tid_offset = cp_flush_offset + `THREADS;
   localparam             ex3_mul_tid_offset = ex2_mul_tid_offset + `THREADS;
	localparam             ex4_mul_tid_offset = ex3_mul_tid_offset + `THREADS;
	localparam             ex5_mul_tid_offset = ex4_mul_tid_offset             + `THREADS;
   localparam             rslt_lo_act_offset = ex5_mul_tid_offset             + `THREADS;
   localparam             scan_right = rslt_lo_act_offset + 1;
   wire [0:scan_right-1]  siv;
   wire [0:scan_right-1]  sov;

   assign ex2_retsel_d = {dec_mul_ex1_mul_ret, dec_mul_ex1_mul_size, dec_mul_ex1_mul_imm};

   generate
      if (`GPR_WIDTH == 64)
      begin : mult_64b_stagecnt
         assign ex2_mulstage_shift = {1'b0,ex3_mulstage_q[0:2]};
      end
   endgenerate
   generate
      if (`GPR_WIDTH == 32)
      begin : mult_32b_stagecnt
         assign ex2_mulstage_shift = 4'b0000;
      end
   endgenerate
   
   assign ex1_mul_val = | dec_mul_ex1_mul_val;
   
   assign ex2_mulstage = (ex2_mul_val_q == 1'b1) ? 4'b1000 : ex2_mulstage_shift;
   
   wire   ex2_flush = |(ex2_mul_tid_q & cp_flush_q);
   wire   ex3_flush = |(ex3_mul_tid_q & cp_flush_q);
   wire   ex4_flush = |(ex4_mul_tid_q & cp_flush_q);
   wire   ex5_flush = |(ex5_mul_tid_q & cp_flush_q);
      
   assign ex3_mulstage_d  = ex2_mulstage     & ~{4{ex2_flush}};
   assign ex4_mulstage_d  = ex3_mulstage_q   & ~{4{ex3_flush}};
   assign ex5_mulstage_d  = ex4_mulstage_q   & ~{4{ex4_flush}};
   assign ex6_mulstage_d  = ex5_mulstage_q   & ~{4{ex5_flush}};
   
   assign mul_spr_running = ex5_mul_tid_q & {`THREADS{|ex5_mulstage_q}};   

   assign exx_mul_abort_d[3] = byp_mul_ex2_abort;
   assign exx_mul_abort_d[4] = exx_mul_abort_q[3];
   assign exx_mul_abort_d[5] = exx_mul_abort_q[4];
   assign exx_mul_abort_d[6] = exx_mul_abort_q[5];
   assign exx_mul_abort_d[7] = exx_mul_abort_q[6];
   assign exx_mul_abort_d[8] = exx_mul_abort_q[7];

   assign mul_byp_ex5_abort = (exx_mul_abort_q[5] & (ex5_ret_mulhw | ex5_ret_mullw)) |
                              (exx_mul_abort_q[6] & (ex5_ret_mulli))                 |
                              (exx_mul_abort_q[7] & (ex5_ret_mulld))                 |
                              (exx_mul_abort_q[8] & (ex5_ret_mulldo | ex5_ret_mulhd)) ;





   assign ex3_bs_lo_sign_d = ((ex2_bs_sign & ex2_mul_sign_q & (ex2_mulstage[1] | ex2_mulstage[3])) & ex2_mul_size_q) | (ex2_bs_sign & ex2_mul_sign_q & (~ex2_mul_size_q)) | (ex2_bs_sign & ex2_mul_sign_q & ex2_mulstage[1] & ex2_retsel_q[2]);
   assign ex3_bd_lo_sign_d = ((ex2_bd_sign & ex2_mul_sign_q & (ex2_mulstage[2] | ex2_mulstage[3])) & ex2_mul_size_q) | (ex2_bd_sign & ex2_mul_sign_q & (~ex2_mul_size_q)) | (ex2_bd_sign & ex2_mul_sign_q & ex2_retsel_q[2]);

   assign ex2_mulsrc0_act = |(ex2_mulstage);
   assign ex2_mulsrc1_act = ex2_mulstage[0] | ex2_mulstage[2];

   assign ex2_mulsrc_0[0:63] = (ex2_mul_val_q == 1'b1) ? byp_mul_ex2_rs1[0:63] : 
                               {ex3_mulsrc_0_q[32:63], ex3_mulsrc_0_q[0:31]};

   assign ex2_mulsrc_1[0:63] = (ex2_mul_val_q == 1'b1) ? byp_mul_ex2_rs2[0:63] : 
                               {ex3_mulsrc_1_q[32:63], ex3_mulsrc_1_q[0:31]};

   assign ex2_bd_sign = ((ex2_mulstage[1] | ex2_mulstage[3]) == 1'b1) ? ex3_mulsrc_1_q[32] : 
                        ex2_mulsrc_1[32];
   assign ex2_bs_sign = ex2_mulsrc_0[32];
   assign ex3_bs_lo = ex3_mulsrc_0_q[32:63];
   assign ex3_bd_lo = ex3_mulsrc_1_q[32:63];



   tri_st_mult_core mcore(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[0]),
      .scan_out(sov[0]),
      .ex3_act(ex3_act),
      .ex4_act(ex4_act),
      .ex3_bs_lo_sign(ex3_bs_lo_sign_q),
      .ex3_bd_lo_sign(ex3_bd_lo_sign_q),
      .ex3_bs_lo(ex3_bs_lo),
      .ex3_bd_lo(ex3_bd_lo),
      .ex4_recycle_s(ex4_recycle_s[196:264]),
      .ex4_recycle_c(ex4_recycle_c[196:263]),
      .ex5_pp5_0s_out(ex5_pp5_0s),
      .ex5_pp5_0c_out(ex5_pp5_0c[196:263])
   );

   assign ex5_pp5_0c[264] = 0;

   assign ex3_act = | ex3_mulstage_q;
   assign ex4_act = | ex4_mulstage_q;
   assign ex5_act = | ex5_mulstage_q;


   assign ex5_ci_d = (carry_32_dly1_q & ex4_mulstage_q[2]) | (ex5_cout_32 & ((ex4_mulstage_q[3] & ex4_retsel_q[1]) | (ex4_mulstage_q[1] & ex4_retsel_q[2])));		

   assign ex5_xi = ex5_pp5_0s[200:263];
   assign ex5_yi = ex5_pp5_0c[200:263];

   assign ex5_p = ex5_xi[0:63] ^ ex5_yi[0:63];
   assign ex5_g = ex5_xi[1:63] & ex5_yi[1:63];
   assign ex5_t = ex5_xi[1:63] | ex5_yi[1:63];

   assign ex5_xi_b[0:63] = (~ex5_xi[0:63]);
   assign ex5_yi_b[0:63] = (~ex5_yi[0:63]);


   tri_st_add cla64ci(
      .x_b(ex5_xi_b[0:63]),
      .y_b(ex5_yi_b[0:63]),
      .ci(ex5_ci_q),
      .sum(ex5_res[0:63]),
      .cout_32(ex5_cout_32),
      .cout_0()
   );

   assign ex4_recyc_sh32 = ex4_retsel_q[1] & (ex4_mulstage_q[1] | ex4_mulstage_q[3]);
   assign ex4_recyc_sh00 = ex4_retsel_q[1] & (ex4_mulstage_q[2]);

   assign ex4_xtd_196_or = ex5_pp5_0s[196] | ex5_pp5_0c[196];
   assign ex4_xtd_196_and = ex5_pp5_0s[196] & ex5_pp5_0c[196];
   assign ex4_xtd_197_or = ex5_pp5_0s[197] | ex5_pp5_0c[197];
   assign ex4_xtd_197_and = ex5_pp5_0s[197] & ex5_pp5_0c[197];

   assign ex4_xtd_ge1 = ex4_xtd_196_or | ex4_xtd_197_or;
   assign ex4_xtd_ge2 = ex4_xtd_196_or | ex4_xtd_197_and;
   assign ex4_xtd_ge3 = ex4_xtd_196_and | (ex4_xtd_196_or & ex4_xtd_197_or);

   assign ex4_xtd = (ex4_mulstage_q[1] & ex4_retsel_q[1] & (~ex4_xtd_ge1)) | (ex4_mulstage_q[2] & ex4_retsel_q[1] & (~ex4_xtd_ge2)) | (ex4_mulstage_q[3] & ex4_retsel_q[1] & (~ex4_xtd_ge3));

   assign ex4_recycle_s[196] = ex5_pp5_0s[196] & (ex4_retsel_q[1] & (~ex4_mulstage_q[0]));
   assign ex4_recycle_c[196] = ex5_pp5_0c[196] & (ex4_retsel_q[1] & (~ex4_mulstage_q[0]));

   assign ex4_recycle_s[197] = ex5_pp5_0s[197] & (ex4_retsel_q[1] & (~ex4_mulstage_q[0]));
   assign ex4_recycle_c[197] = ex5_pp5_0c[197] & (ex4_retsel_q[1] & (~ex4_mulstage_q[0]));

   assign ex4_recycle_s[198:264] = ({67{ex4_recyc_sh00}} & (ex5_pp5_0s[198:264])) |
                                   ({67{ex4_recyc_sh32}} & ({{32{ex4_xtd}}, ex5_pp5_0s[198:231], 1'b0}));

   assign ex4_recycle_c[198:264] = ({67{ex4_recyc_sh00}} & (ex5_pp5_0c[198:264])) |
                                   ({67{ex4_recyc_sh32}} & ({32'b0, ex5_pp5_0c[198:231], 1'b0}));

   assign rslt_lo_act = ex6_mulstage_q[0] | ex6_mulstage_q[2];

   assign rslt_lo_d = ex6_res_q[32:63];
   assign rslt_lo_dly_d = rslt_lo_q;


   assign ex5_ret_mulhw = ex5_retsel_q[0] & (~ex5_retsel_q[1]) & (~ex5_retsel_q[2]);
   assign ex5_ret_mullw = (~ex5_retsel_q[0]) & (~ex5_retsel_q[1]) & (~ex5_retsel_q[2]);
   assign ex5_ret_mulli = ex5_retsel_q[2];
   assign ex5_ret_mulld = (~ex5_retsel_q[0]) & ex5_retsel_q[1] & (~ex5_retsel_q[2]) & (~ex5_xer_ov_update_q);
   assign ex5_ret_mulldo = (~ex5_retsel_q[0]) & ex5_retsel_q[1] & (~ex5_retsel_q[2]) & ex5_xer_ov_update_q;
   assign ex5_ret_mulhd = ex5_retsel_q[0] & ex5_retsel_q[1] & (~ex5_retsel_q[2]);

   assign ex6_rslt_hw_d    = {8{(ex5_ret_mulhw)}};
   assign ex6_rslt_ld_li_d = {8{(ex5_ret_mulli | ex5_ret_mulld)}};
   assign ex6_rslt_ldo_d   = {8{(ex5_ret_mulldo)}};
   assign ex6_rslt_lw_hd_d = {8{(ex5_ret_mullw | ex5_ret_mulhd)}};

   generate
   genvar                 i;
   for (i = 0; i <= 7; i = i + 1)
      begin : fanout_gen
         assign ex6_rslt_hw[8*i:8*i+7]    = {8{ex6_rslt_hw_q[i]}};
         assign ex6_rslt_ld_li[8*i:8*i+7] = {8{ex6_rslt_ld_li_q[i]}};
         assign ex6_rslt_ldo[8*i:8*i+7]   = {8{ex6_rslt_ldo_q[i]}};
         assign ex6_rslt_lw_hd[8*i:8*i+7] = {8{ex6_rslt_lw_hd_q[i]}};
      end
   endgenerate

      assign ex6_result = ({32'b0, ex6_res_q[0:31]}         & ex6_rslt_hw) |
                          ({ex6_res_q[32:63], rslt_lo_q}    & ex6_rslt_ld_li) |
                          ({rslt_lo_q, rslt_lo_dly_q}       & ex6_rslt_ldo) |
                          (ex6_res_q                        & ex6_rslt_lw_hd);

      assign ex5_all0_test[0:62] = ((~ex5_p[0:62]) & (~ex5_t[1:63])) | (ex5_p[0:62] & ex5_t[1:63]);
      assign ex5_all0_test[63] = ((~ex5_p[63]) & (~ex5_ci_q)) | (ex5_p[63] & ex5_ci_q);
      assign ex5_all0_test_mid = ((~ex5_p[31]) & (~ex5_cout_32)) | (ex5_p[31] & ex5_cout_32);

      assign ex5_all1_test[0:62] = (ex5_p[0:62] & (~ex5_g[1:63])) | ((~ex5_p[0:62]) & ex5_g[1:63]);
      assign ex5_all1_test[63] = (ex5_p[63] & (~ex5_ci_q)) | ((~ex5_p[63]) & ex5_ci_q);
      assign ex5_all1_test_mid = (ex5_p[31] & (~ex5_cout_32)) | ((~ex5_p[31]) & ex5_cout_32);

      assign ex5_all0 = &(ex5_all0_test[0:63]);
      assign ex5_all1 = &(ex5_all1_test[0:63]);
      assign ex5_all0_lo = &(ex5_all0_test[32:63]);
      assign ex5_all0_hi = &({ex5_all0_test[0:30], ex5_all0_test_mid});
      assign ex5_all1_hi = &({ex5_all1_test[0:30], ex5_all1_test_mid});



      assign ex6_cmp0_undef_d = ex5_ret_mulhw & ex5_spr_msr_cm_q;

      assign ex6_cmp0_sel_reshi_d = (ex5_ret_mulhw) | ((ex5_ret_mullw | ex5_ret_mulhd) & ex5_spr_msr_cm_q);
      assign ex6_cmp0_sel_reslo_d = ((ex5_ret_mullw | ex5_ret_mulhd) & (~ex5_spr_msr_cm_q)) | (ex5_ret_mulld & ex5_spr_msr_cm_q);
      assign ex6_cmp0_sel_reslodly_d = (ex5_ret_mulld & (~ex5_spr_msr_cm_q)) | (ex5_ret_mulldo & ex5_spr_msr_cm_q);
      assign ex6_cmp0_sel_reslodly2_d = (ex5_ret_mulldo & (~ex5_spr_msr_cm_q));

      assign ex6_sign_rt_cmp0 = (ex6_cmp0_sel_reshi_q & ex6_res_q[0]) | (ex6_cmp0_sel_reslo_q & ex6_res_q[32]) | (ex6_cmp0_sel_reslodly_q & rslt_lo_q[0]) | (ex6_cmp0_sel_reslodly2_q & rslt_lo_dly_q[0]);



      assign ex6_eq_sel_all0_hi_b_d = (~(ex5_ret_mulhw));

      assign ex6_eq_sel_all0_b_d = (~((ex5_ret_mullw & ex5_spr_msr_cm_q) | (ex5_ret_mulhd & ex5_spr_msr_cm_q)));

      assign ex6_eq_sel_all0_lo_b_d = (~((ex5_ret_mullw & (~ex5_spr_msr_cm_q)) | (ex5_ret_mulhd & (~ex5_spr_msr_cm_q)) | (ex5_ret_mulld & ex5_spr_msr_cm_q)));

      assign ex6_eq_sel_all0_lo1_b_d = (~((ex5_ret_mulldo & ex5_spr_msr_cm_q)));

      assign ex6_eq_sel_all0_lo2_b_d = (~(ex5_ret_mulld));

      assign ex6_eq_sel_all0_lo3_b_d = (~(ex5_ret_mulldo));

      assign ex6_eq = (ex6_eq_sel_all0_b_q | ex6_all0_q) & (ex6_eq_sel_all0_lo_b_q | ex6_all0_lo_q) & (ex6_eq_sel_all0_lo1_b_q | all0_lo_dly1_q) & (ex6_eq_sel_all0_lo2_b_q | all0_lo_dly2_q) & (ex6_eq_sel_all0_lo3_b_q | all0_lo_dly3_q) & (ex6_eq_sel_all0_hi_b_q | ex6_all0_hi_q);

      assign ex6_cmp0_eq = ex6_eq & (~ex6_cmp0_undef_q);
      assign ex6_cmp0_gt = (~ex6_sign_rt_cmp0) & (~ex6_eq) & (~ex6_cmp0_undef_q);
      assign ex6_cmp0_lt = ex6_sign_rt_cmp0 & (~ex6_eq) & (~ex6_cmp0_undef_q);



      assign ex6_xer_ov = (ex6_ret_mullw_q & (((~ex6_res_q[32]) & (~ex6_all0_hi_q)) | (ex6_res_q[32] & (~ex6_all1_hi_q)))) | (ex6_ret_mulldo_q & (((~rslt_lo_q[0]) & (~ex6_all0_q)) | (rslt_lo_q[0] & (~ex6_all1_q))));

      assign ex6_xer_ov_gated = (ex6_xer_ov & ex6_xer_ov_update_q) | (ex6_xer_src_q[1] & (~ex6_xer_ov_update_q));

      assign ex6_xer_so = (ex6_xer_src_q[0] | (ex6_xer_ov & ex6_xer_ov_update_q));

      assign mul_byp_ex6_rt = ex6_result[64 - (`GPR_WIDTH):63];
      assign mul_byp_ex6_cr = {ex6_cmp0_lt, ex6_cmp0_gt, ex6_cmp0_eq, ex6_xer_so};
      assign mul_byp_ex6_xer = {ex6_xer_so, ex6_xer_ov_gated, ex6_xer_src_q[2:9]};



      assign ex3_ready_stage[0] = ((~ex3_retsel_q[1]) & (~ex3_retsel_q[2]));
      assign ex3_ready_stage[1] = (ex3_retsel_q[2]);
      assign ex3_ready_stage[2] = ((~ex3_retsel_q[0]) & ex3_retsel_q[1] & (~ex3_retsel_q[2]) & (~ex3_xer_ov_update_q));
      assign ex3_ready_stage[3] = ((~ex3_retsel_q[0]) & ex3_retsel_q[1] & (~ex3_retsel_q[2]) & ex3_xer_ov_update_q) | (ex3_retsel_q[0] & ex3_retsel_q[1] & (~ex3_retsel_q[2]));


      assign ex4_mul_done_d = |(ex3_ready_stage & ex3_mulstage_q);


      assign mul_byp_ex5_ord_done = ex5_mul_done_q &  ex5_mul_is_ord_q & ~ex5_flush;
      assign mul_byp_ex5_done     = ex5_mul_done_q & ~ex5_mul_is_ord_q & ~ex5_flush;



      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_spr_msr_cm_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex1_mul_val),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex2_spr_msr_cm_offset]),
         .scout(sov[ex2_spr_msr_cm_offset]),
         .din(ex1_spr_msr_cm),
         .dout(ex2_spr_msr_cm_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_spr_msr_cm_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex2_mul_val_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex3_spr_msr_cm_offset]),
         .scout(sov[ex3_spr_msr_cm_offset]),
         .din(ex2_spr_msr_cm_q),
         .dout(ex3_spr_msr_cm_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_spr_msr_cm_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex3_act),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex4_spr_msr_cm_offset]),
         .scout(sov[ex4_spr_msr_cm_offset]),
         .din(ex3_spr_msr_cm_q),
         .dout(ex4_spr_msr_cm_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_spr_msr_cm_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex4_act),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex5_spr_msr_cm_offset]),
         .scout(sov[ex5_spr_msr_cm_offset]),
         .din(ex4_spr_msr_cm_q),
         .dout(ex5_spr_msr_cm_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_mul_is_ord_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex1_mul_val),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex2_mul_is_ord_offset]),
         .scout(sov[ex2_mul_is_ord_offset]),
         .din(dec_mul_ex1_mul_ord),
         .dout(ex2_mul_is_ord_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_mul_is_ord_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex2_mul_val_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex3_mul_is_ord_offset]),
         .scout(sov[ex3_mul_is_ord_offset]),
         .din(ex2_mul_is_ord_q),
         .dout(ex3_mul_is_ord_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_mul_is_ord_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex3_act),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex4_mul_is_ord_offset]),
         .scout(sov[ex4_mul_is_ord_offset]),
         .din(ex3_mul_is_ord_q),
         .dout(ex4_mul_is_ord_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_mul_is_ord_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex4_act),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex5_mul_is_ord_offset]),
         .scout(sov[ex5_mul_is_ord_offset]),
         .din(ex4_mul_is_ord_q),
         .dout(ex5_mul_is_ord_q)
      );

      tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) ex3_xer_src_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex2_mul_val_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex3_xer_src_offset:ex3_xer_src_offset + 10 - 1]),
         .scout(sov[ex3_xer_src_offset:ex3_xer_src_offset + 10 - 1]),
         .din(byp_mul_ex2_xer),
         .dout(ex3_xer_src_q)
      );

      tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) ex4_xer_src_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex3_act),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex4_xer_src_offset:ex4_xer_src_offset + 10 - 1]),
         .scout(sov[ex4_xer_src_offset:ex4_xer_src_offset + 10 - 1]),
         .din(ex3_xer_src_q),
         .dout(ex4_xer_src_q)
      );

      tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) ex5_xer_src_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex4_act),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex5_xer_src_offset:ex5_xer_src_offset + 10 - 1]),
         .scout(sov[ex5_xer_src_offset:ex5_xer_src_offset + 10 - 1]),
         .din(ex4_xer_src_q),
         .dout(ex5_xer_src_q)
      );

      tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) ex6_xer_src_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_act),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_xer_src_offset:ex6_xer_src_offset + 10 - 1]),
         .scout(sov[ex6_xer_src_offset:ex6_xer_src_offset + 10 - 1]),
         .din(ex5_xer_src_q),
         .dout(ex6_xer_src_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_mul_val_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex2_mul_val_offset]),
         .scout(sov[ex2_mul_val_offset]),
         .din(ex1_mul_val),
         .dout(ex2_mul_val_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex3_mulstage_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex3_mulstage_offset:ex3_mulstage_offset + 4 - 1]),
         .scout(sov[ex3_mulstage_offset:ex3_mulstage_offset + 4 - 1]),
         .din(ex3_mulstage_d),
         .dout(ex3_mulstage_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex4_mulstage_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex4_mulstage_offset:ex4_mulstage_offset + 4 - 1]),
         .scout(sov[ex4_mulstage_offset:ex4_mulstage_offset + 4 - 1]),
         .din(ex4_mulstage_d),
         .dout(ex4_mulstage_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex5_mulstage_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex5_mulstage_offset:ex5_mulstage_offset + 4 - 1]),
         .scout(sov[ex5_mulstage_offset:ex5_mulstage_offset + 4 - 1]),
         .din(ex5_mulstage_d),
         .dout(ex5_mulstage_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex6_mulstage_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_mulstage_offset:ex6_mulstage_offset + 4 - 1]),
         .scout(sov[ex6_mulstage_offset:ex6_mulstage_offset + 4 - 1]),
         .din(ex6_mulstage_d),
         .dout(ex6_mulstage_q)
      );

      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex2_retsel_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex1_mul_val),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex2_retsel_offset:ex2_retsel_offset + 3 - 1]),
         .scout(sov[ex2_retsel_offset:ex2_retsel_offset + 3 - 1]),
         .din(ex2_retsel_d),
         .dout(ex2_retsel_q)
      );

      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex3_retsel_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex2_mul_val_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex3_retsel_offset:ex3_retsel_offset + 3 - 1]),
         .scout(sov[ex3_retsel_offset:ex3_retsel_offset + 3 - 1]),
         .din(ex2_retsel_q),
         .dout(ex3_retsel_q)
      );

      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex4_retsel_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex4_retsel_offset:ex4_retsel_offset + 3 - 1]),
         .scout(sov[ex4_retsel_offset:ex4_retsel_offset + 3 - 1]),
         .din(ex3_retsel_q),
         .dout(ex4_retsel_q)
      );

      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex5_retsel_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex5_retsel_offset:ex5_retsel_offset + 3 - 1]),
         .scout(sov[ex5_retsel_offset:ex5_retsel_offset + 3 - 1]),
         .din(ex4_retsel_q),
         .dout(ex5_retsel_q)
      );

      tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) exx_mul_abort_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[exx_mul_abort_offset:exx_mul_abort_offset + 6 -1]),
         .scout(sov[exx_mul_abort_offset:exx_mul_abort_offset + 6 -1]),
         .din(exx_mul_abort_d),
         .dout(exx_mul_abort_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_mul_done_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex4_mul_done_offset]),
         .scout(sov[ex4_mul_done_offset]),
         .din(ex4_mul_done_d),
         .dout(ex4_mul_done_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_mul_done_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex5_mul_done_offset]),
         .scout(sov[ex5_mul_done_offset]),
         .din(ex4_mul_done_q),
         .dout(ex5_mul_done_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_recform_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex1_mul_val),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex2_is_recform_offset]),
         .scout(sov[ex2_is_recform_offset]),
         .din(dec_mul_ex1_mul_recform),
         .dout(ex2_is_recform_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_is_recform_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex3_is_recform_offset]),
         .scout(sov[ex3_is_recform_offset]),
         .din(ex2_is_recform_q),
         .dout(ex3_is_recform_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_is_recform_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex4_is_recform_offset]),
         .scout(sov[ex4_is_recform_offset]),
         .din(ex3_is_recform_q),
         .dout(ex4_is_recform_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_is_recform_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex5_is_recform_offset]),
         .scout(sov[ex5_is_recform_offset]),
         .din(ex4_is_recform_q),
         .dout(ex5_is_recform_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_is_recform_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_is_recform_offset]),
         .scout(sov[ex6_is_recform_offset]),
         .din(ex5_is_recform_q),
         .dout(ex6_is_recform_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_xer_ov_update_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex1_mul_val),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex2_xer_ov_update_offset]),
         .scout(sov[ex2_xer_ov_update_offset]),
         .din(dec_mul_ex1_xer_ov_update),
         .dout(ex2_xer_ov_update_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_xer_ov_update_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex3_xer_ov_update_offset]),
         .scout(sov[ex3_xer_ov_update_offset]),
         .din(ex2_xer_ov_update_q),
         .dout(ex3_xer_ov_update_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_xer_ov_update_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex4_xer_ov_update_offset]),
         .scout(sov[ex4_xer_ov_update_offset]),
         .din(ex3_xer_ov_update_q),
         .dout(ex4_xer_ov_update_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_xer_ov_update_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex5_xer_ov_update_offset]),
         .scout(sov[ex5_xer_ov_update_offset]),
         .din(ex4_xer_ov_update_q),
         .dout(ex5_xer_ov_update_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_xer_ov_update_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_xer_ov_update_offset]),
         .scout(sov[ex6_xer_ov_update_offset]),
         .din(ex5_xer_ov_update_q),
         .dout(ex6_xer_ov_update_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_mul_size_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex1_mul_val),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex2_mul_size_offset]),
         .scout(sov[ex2_mul_size_offset]),
         .din(dec_mul_ex1_mul_size),
         .dout(ex2_mul_size_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_mul_sign_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex1_mul_val),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex2_mul_sign_offset]),
         .scout(sov[ex2_mul_sign_offset]),
         .din(dec_mul_ex1_mul_sign),
         .dout(ex2_mul_sign_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_bs_lo_sign_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex3_bs_lo_sign_offset]),
         .scout(sov[ex3_bs_lo_sign_offset]),
         .din(ex3_bs_lo_sign_d),
         .dout(ex3_bs_lo_sign_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_bd_lo_sign_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex3_bd_lo_sign_offset]),
         .scout(sov[ex3_bd_lo_sign_offset]),
         .din(ex3_bd_lo_sign_d),
         .dout(ex3_bd_lo_sign_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_all0_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_all0_offset]),
         .scout(sov[ex6_all0_offset]),
         .din(ex5_all0),
         .dout(ex6_all0_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_all1_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_all1_offset]),
         .scout(sov[ex6_all1_offset]),
         .din(ex5_all1),
         .dout(ex6_all1_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_all0_lo_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_all0_lo_offset]),
         .scout(sov[ex6_all0_lo_offset]),
         .din(ex5_all0_lo),
         .dout(ex6_all0_lo_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_all0_hi_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_all0_hi_offset]),
         .scout(sov[ex6_all0_hi_offset]),
         .din(ex5_all0_hi),
         .dout(ex6_all0_hi_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_all1_hi_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_all1_hi_offset]),
         .scout(sov[ex6_all1_hi_offset]),
         .din(ex5_all1_hi),
         .dout(ex6_all1_hi_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_ci_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex5_ci_offset]),
         .scout(sov[ex5_ci_offset]),
         .din(ex5_ci_d),
         .dout(ex5_ci_q)
      );

      tri_rlmreg_p #(.WIDTH(64), .INIT(0), .NEEDS_SRESET(1)) ex6_res_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_act),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_res_offset:ex6_res_offset + 64 - 1]),
         .scout(sov[ex6_res_offset:ex6_res_offset + 64 - 1]),
         .din(ex5_res),
         .dout(ex6_res_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) carry_32_dly1_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[carry_32_dly1_offset]),
         .scout(sov[carry_32_dly1_offset]),
         .din(ex5_cout_32),
         .dout(carry_32_dly1_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) all0_lo_dly1_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[all0_lo_dly1_offset]),
         .scout(sov[all0_lo_dly1_offset]),
         .din(ex6_all0_lo_q),
         .dout(all0_lo_dly1_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) all0_lo_dly2_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[all0_lo_dly2_offset]),
         .scout(sov[all0_lo_dly2_offset]),
         .din(all0_lo_dly1_q),
         .dout(all0_lo_dly2_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) all0_lo_dly3_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[all0_lo_dly3_offset]),
         .scout(sov[all0_lo_dly3_offset]),
         .din(all0_lo_dly2_q),
         .dout(all0_lo_dly3_q)
      );

      tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) rslt_lo_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(rslt_lo_act),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[rslt_lo_offset:rslt_lo_offset + 32 - 1]),
         .scout(sov[rslt_lo_offset:rslt_lo_offset + 32 - 1]),
         .din(rslt_lo_d),
         .dout(rslt_lo_q)
      );

      tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) rslt_lo_dly_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(rslt_lo_act_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[rslt_lo_dly_offset:rslt_lo_dly_offset + 32 - 1]),
         .scout(sov[rslt_lo_dly_offset:rslt_lo_dly_offset + 32 - 1]),
         .din(rslt_lo_dly_d),
         .dout(rslt_lo_dly_q)
      );

      tri_rlmreg_p #(.WIDTH(64), .INIT(0), .NEEDS_SRESET(1)) ex3_mulsrc_0_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex2_mulsrc0_act),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex3_mulsrc_0_offset:ex3_mulsrc_0_offset + 64 - 1]),
         .scout(sov[ex3_mulsrc_0_offset:ex3_mulsrc_0_offset + 64 - 1]),
         .din(ex2_mulsrc_0),
         .dout(ex3_mulsrc_0_q)
      );

      tri_rlmreg_p #(.WIDTH(64), .INIT(0), .NEEDS_SRESET(1)) ex3_mulsrc_1_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex2_mulsrc1_act),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex3_mulsrc_1_offset:ex3_mulsrc_1_offset + 64 - 1]),
         .scout(sov[ex3_mulsrc_1_offset:ex3_mulsrc_1_offset + 64 - 1]),
         .din(ex2_mulsrc_1),
         .dout(ex3_mulsrc_1_q)
      );

      tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex6_rslt_hw_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_rslt_hw_offset:ex6_rslt_hw_offset + 8 - 1]),
         .scout(sov[ex6_rslt_hw_offset:ex6_rslt_hw_offset + 8 - 1]),
         .din(ex6_rslt_hw_d),
         .dout(ex6_rslt_hw_q)
      );

      tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex6_rslt_ld_li_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_rslt_ld_li_offset:ex6_rslt_ld_li_offset + 8 - 1]),
         .scout(sov[ex6_rslt_ld_li_offset:ex6_rslt_ld_li_offset + 8 - 1]),
         .din(ex6_rslt_ld_li_d),
         .dout(ex6_rslt_ld_li_q)
      );

      tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex6_rslt_ldo_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_rslt_ldo_offset:ex6_rslt_ldo_offset + 8 - 1]),
         .scout(sov[ex6_rslt_ldo_offset:ex6_rslt_ldo_offset + 8 - 1]),
         .din(ex6_rslt_ldo_d),
         .dout(ex6_rslt_ldo_q)
      );

      tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex6_rslt_lw_hd_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_rslt_lw_hd_offset:ex6_rslt_lw_hd_offset + 8 - 1]),
         .scout(sov[ex6_rslt_lw_hd_offset:ex6_rslt_lw_hd_offset + 8 - 1]),
         .din(ex6_rslt_lw_hd_d),
         .dout(ex6_rslt_lw_hd_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_cmp0_sel_reshi_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_cmp0_sel_reshi_offset]),
         .scout(sov[ex6_cmp0_sel_reshi_offset]),
         .din(ex6_cmp0_sel_reshi_d),
         .dout(ex6_cmp0_sel_reshi_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_cmp0_sel_reslo_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_cmp0_sel_reslo_offset]),
         .scout(sov[ex6_cmp0_sel_reslo_offset]),
         .din(ex6_cmp0_sel_reslo_d),
         .dout(ex6_cmp0_sel_reslo_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_cmp0_sel_reslodly_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_cmp0_sel_reslodly_offset]),
         .scout(sov[ex6_cmp0_sel_reslodly_offset]),
         .din(ex6_cmp0_sel_reslodly_d),
         .dout(ex6_cmp0_sel_reslodly_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_cmp0_sel_reslodly2_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_cmp0_sel_reslodly2_offset]),
         .scout(sov[ex6_cmp0_sel_reslodly2_offset]),
         .din(ex6_cmp0_sel_reslodly2_d),
         .dout(ex6_cmp0_sel_reslodly2_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_eq_sel_all0_b_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_eq_sel_all0_b_offset]),
         .scout(sov[ex6_eq_sel_all0_b_offset]),
         .din(ex6_eq_sel_all0_b_d),
         .dout(ex6_eq_sel_all0_b_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_eq_sel_all0_lo_b_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_eq_sel_all0_lo_b_offset]),
         .scout(sov[ex6_eq_sel_all0_lo_b_offset]),
         .din(ex6_eq_sel_all0_lo_b_d),
         .dout(ex6_eq_sel_all0_lo_b_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_eq_sel_all0_hi_b_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_eq_sel_all0_hi_b_offset]),
         .scout(sov[ex6_eq_sel_all0_hi_b_offset]),
         .din(ex6_eq_sel_all0_hi_b_d),
         .dout(ex6_eq_sel_all0_hi_b_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_eq_sel_all0_lo1_b_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_eq_sel_all0_lo1_b_offset]),
         .scout(sov[ex6_eq_sel_all0_lo1_b_offset]),
         .din(ex6_eq_sel_all0_lo1_b_d),
         .dout(ex6_eq_sel_all0_lo1_b_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_eq_sel_all0_lo2_b_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_eq_sel_all0_lo2_b_offset]),
         .scout(sov[ex6_eq_sel_all0_lo2_b_offset]),
         .din(ex6_eq_sel_all0_lo2_b_d),
         .dout(ex6_eq_sel_all0_lo2_b_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_eq_sel_all0_lo3_b_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_eq_sel_all0_lo3_b_offset]),
         .scout(sov[ex6_eq_sel_all0_lo3_b_offset]),
         .din(ex6_eq_sel_all0_lo3_b_d),
         .dout(ex6_eq_sel_all0_lo3_b_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_ret_mullw_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_ret_mullw_offset]),
         .scout(sov[ex6_ret_mullw_offset]),
         .din(ex5_ret_mullw),
         .dout(ex6_ret_mullw_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_ret_mulldo_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_ret_mulldo_offset]),
         .scout(sov[ex6_ret_mulldo_offset]),
         .din(ex5_ret_mulldo),
         .dout(ex6_ret_mulldo_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_cmp0_undef_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex5_mul_done_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex6_cmp0_undef_offset]),
         .scout(sov[ex6_cmp0_undef_offset]),
         .din(ex6_cmp0_undef_d),
         .dout(ex6_cmp0_undef_q)
      );

      tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
         .scout(sov[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
         .din(cp_flush),
         .dout(cp_flush_q)
      );

      tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex2_mul_tid_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex2_mul_tid_offset:ex2_mul_tid_offset + `THREADS - 1]),
         .scout(sov[ex2_mul_tid_offset:ex2_mul_tid_offset + `THREADS - 1]),
         .din(dec_mul_ex1_mul_val),
         .dout(ex2_mul_tid_q)
      );

      tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_mul_tid_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(ex2_mul_val_q),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ex3_mul_tid_offset:ex3_mul_tid_offset + `THREADS - 1]),
         .scout(sov[ex3_mul_tid_offset:ex3_mul_tid_offset + `THREADS - 1]),
         .din(ex2_mul_tid_q),
         .dout(ex3_mul_tid_q)
      );
      tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_mul_tid_latch(
         .nclk(nclk), .vd(vdd), .gd(gnd),
         .act(ex3_act),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b), .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin (siv[ex4_mul_tid_offset : ex4_mul_tid_offset + `THREADS-1]),
         .scout(sov[ex4_mul_tid_offset : ex4_mul_tid_offset + `THREADS-1]),
         .din(ex3_mul_tid_q),
         .dout(ex4_mul_tid_q)
      );
      tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex5_mul_tid_latch(
         .nclk(nclk), .vd(vdd), .gd(gnd),
         .act(ex4_act),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b), .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin (siv[ex5_mul_tid_offset : ex5_mul_tid_offset + `THREADS-1]),
         .scout(sov[ex5_mul_tid_offset : ex5_mul_tid_offset + `THREADS-1]),
         .din(ex4_mul_tid_q),
         .dout(ex5_mul_tid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rslt_lo_act_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(1'b1),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[rslt_lo_act_offset]),
         .scout(sov[rslt_lo_act_offset]),
         .din(rslt_lo_act),
         .dout(rslt_lo_act_q)
      );

      assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
      assign scan_out = sov[0];
         
endmodule
