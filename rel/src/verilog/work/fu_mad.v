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
   
module fu_mad(
   f_dcd_ex7_cancel,
   f_dcd_ex1_bypsel_a_res0,
   f_dcd_ex1_bypsel_a_res1,
   f_dcd_ex1_bypsel_a_res2,
   f_dcd_ex1_bypsel_a_load0,
   f_dcd_ex1_bypsel_a_load1,
   f_dcd_ex1_bypsel_a_load2,
   f_dcd_ex1_bypsel_a_reload0,
   f_dcd_ex1_bypsel_a_reload1,
   f_dcd_ex1_bypsel_a_reload2,
	      
   f_dcd_ex1_bypsel_b_res0,
   f_dcd_ex1_bypsel_b_res1,
   f_dcd_ex1_bypsel_b_res2,
   f_dcd_ex1_bypsel_b_load0,
   f_dcd_ex1_bypsel_b_load1,
   f_dcd_ex1_bypsel_b_load2,
   f_dcd_ex1_bypsel_b_reload0,
   f_dcd_ex1_bypsel_b_reload1,
   f_dcd_ex1_bypsel_b_reload2,
	      
   f_dcd_ex1_bypsel_c_res0,
   f_dcd_ex1_bypsel_c_res1,
   f_dcd_ex1_bypsel_c_res2,
   f_dcd_ex1_bypsel_c_load0,
   f_dcd_ex1_bypsel_c_load1,
   f_dcd_ex1_bypsel_c_load2,
   f_dcd_ex1_bypsel_c_reload0,
   f_dcd_ex1_bypsel_c_reload1,
   f_dcd_ex1_bypsel_c_reload2,
	      
   f_dcd_ex1_bypsel_s_res0,
   f_dcd_ex1_bypsel_s_res1,
   f_dcd_ex1_bypsel_s_res2,
   f_dcd_ex1_bypsel_s_load0,
   f_dcd_ex1_bypsel_s_load1,
   f_dcd_ex1_bypsel_s_load2,
   f_dcd_ex1_bypsel_s_reload0,
   f_dcd_ex1_bypsel_s_reload1,
   f_dcd_ex1_bypsel_s_reload2,
	      
   f_dcd_ex2_perr_force_c,   
   f_dcd_ex2_perr_fsel_ovrd,
	      
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
	      
   f_fpr_ex1_s_sign,
   f_fpr_ex1_s_expo,
   f_fpr_ex1_s_frac,
   f_byp_ex1_s_sign,
   f_byp_ex1_s_expo,
   f_byp_ex1_s_frac,
   f_pic_ex6_scr_upd_move_b,
   f_dcd_ex7_fpscr_wr,
   f_dcd_ex7_fpscr_addr,
   f_dsq_debug,
   cp_axu_i0_t1_v,
   cp_axu_i0_t0_t1_t,
   cp_axu_i0_t1_t1_t,
   cp_axu_i0_t0_t1_p,
   cp_axu_i0_t1_t1_p,	      
   cp_axu_i1_t1_v,
   cp_axu_i1_t0_t1_t,
   cp_axu_i1_t1_t1_t,
   cp_axu_i1_t0_t1_p,
   cp_axu_i1_t1_t1_p,	      

   f_fpr_ex1_a_sign,
   f_fpr_ex1_a_expo,
   f_fpr_ex1_a_frac,
   f_fpr_ex2_a_par,
   f_fpr_ex1_c_sign,
   f_fpr_ex1_c_expo,
   f_fpr_ex1_c_frac,
   f_fpr_ex2_c_par,
   f_fpr_ex1_b_sign,
   f_fpr_ex1_b_expo,
   f_fpr_ex1_b_frac,
   f_fpr_ex2_b_par,
   f_dcd_ex1_aop_valid,
   f_dcd_ex1_cop_valid,
   f_dcd_ex1_bop_valid,
   f_dcd_ex1_thread,
   f_dcd_ex1_sp,
   f_dcd_ex1_emin_dp,
   f_dcd_ex1_emin_sp,
   f_dcd_ex1_force_pass_b,
   f_dcd_ex1_fsel_b,
   f_dcd_ex1_from_integer_b,
   f_dcd_ex1_to_integer_b,
   f_dcd_ex1_rnd_to_int_b,
   f_dcd_ex1_math_b,
   f_dcd_ex1_est_recip_b,
   f_dcd_ex1_est_rsqrt_b,
   f_dcd_ex1_move_b,
   f_dcd_ex1_prenorm_b,
   f_dcd_ex1_frsp_b,
   f_dcd_ex1_compare_b,
   f_dcd_ex1_ordered_b,
   f_dcd_ex1_pow2e_b,
   f_dcd_ex1_log2e_b,
   f_dcd_ex1_ftdiv,
   f_dcd_ex1_ftsqrt,
   f_dcd_ex1_nj_deno,
   f_dcd_ex1_nj_deni,
   f_dcd_ex1_sp_conv_b,
   f_dcd_ex1_word_b,
   f_dcd_ex1_uns_b,
   f_dcd_ex1_sub_op_b,
   f_dcd_ex1_force_excp_dis,
   f_dcd_ex1_op_rnd_v_b,
   f_dcd_ex1_op_rnd_b,
   f_dcd_ex1_inv_sign_b,
   f_dcd_ex1_sign_ctl_b,
   f_dcd_ex1_sgncpy_b,
   f_dcd_ex1_fpscr_bit_data_b,
   f_dcd_ex1_fpscr_bit_mask_b,
   f_dcd_ex1_fpscr_nib_mask_b,
   f_dcd_ex1_mv_to_scr_b,
   f_dcd_ex1_mv_from_scr_b,
   f_dcd_ex1_mtfsbx_b,
   f_dcd_ex1_mcrfs_b,
   f_dcd_ex1_mtfsf_b,
   f_dcd_ex1_mtfsfi_b,
   f_dcd_ex1_uc_fc_hulp,
   f_dcd_ex1_uc_fa_pos,
   f_dcd_ex1_uc_fc_pos,
   f_dcd_ex1_uc_fb_pos,
   f_dcd_ex1_uc_fc_0_5,
   f_dcd_ex1_uc_fc_1_0,
   f_dcd_ex1_uc_fc_1_minus,
   f_dcd_ex1_uc_fb_1_0,
   f_dcd_ex1_uc_fb_0_75,
   f_dcd_ex1_uc_fb_0_5,
   f_dcd_ex1_uc_ft_pos,
   f_dcd_ex1_uc_ft_neg,

   f_dcd_ex1_uc_mid,
   f_dcd_ex1_uc_end,
   f_dcd_ex1_uc_special,
   f_dcd_ex3_uc_zx,
   f_dcd_ex3_uc_vxidi,
   f_dcd_ex3_uc_vxzdz,
   f_dcd_ex3_uc_vxsqrt,
   f_dcd_ex3_uc_vxsnan,
   f_dcd_ex3_uc_inc_lsb,
   f_dcd_ex3_uc_gs_v,
   f_dcd_ex3_uc_gs,
   f_mad_ex7_uc_sign,
   f_mad_ex7_uc_zero,
   f_mad_ex4_uc_special,
   f_mad_ex4_uc_zx,
   f_mad_ex4_uc_vxidi,
   f_mad_ex4_uc_vxzdz,
   f_mad_ex4_uc_vxsqrt,
   f_mad_ex4_uc_vxsnan,
   f_mad_ex4_uc_res_sign,
   f_mad_ex4_uc_round_mode,
   f_mad_ex3_a_parity_check,
   f_mad_ex3_c_parity_check,
   f_mad_ex3_b_parity_check,
   f_dcd_ex0_div,
   f_dcd_ex0_divs,
   f_dcd_ex0_sqrt,
   f_dcd_ex0_sqrts,
   f_dcd_ex0_record_v,
   f_dcd_ex2_divsqrt_v,
   f_dcd_ex2_divsqrt_hole_v,
   f_dcd_flush,
   f_dcd_ex1_itag,
   f_dcd_ex1_fpscr_addr,
   f_dcd_ex1_instr_frt,
   f_dcd_ex1_instr_tid,
   f_dcd_ex1_divsqrt_cr_bf,
   f_dcd_axucr0_deno,	      
   f_dsq_ex5_divsqrt_v,
   f_dsq_ex6_divsqrt_v,
   f_dsq_ex6_divsqrt_record_v,
   f_dsq_ex6_divsqrt_cr_bf,
   f_dsq_ex6_divsqrt_v_suppress,
   f_dsq_ex5_divsqrt_itag,
   f_dsq_ex6_divsqrt_fpscr_addr,
   f_dsq_ex6_divsqrt_instr_frt,
   f_dsq_ex6_divsqrt_instr_tid,
   f_dsq_ex3_hangcounter_trigger,	      
   f_ex3_b_den_flush,
   f_scr_ex8_cr_fld,
   f_scr_ex6_fpscr_ni_thr0,
   f_scr_ex6_fpscr_ni_thr1,	      
   f_add_ex5_fpcc_iu,
   f_pic_ex6_fpr_wr_dis_b,
   f_rnd_ex7_res_expo,
   f_rnd_ex7_res_frac,
   f_rnd_ex7_res_sign,
   f_scr_ex8_fx_thread0,
   f_scr_ex8_fx_thread1,
   f_scr_cpl_fx_thread0,
   f_scr_cpl_fx_thread1,
   ex1_thread_b,
   f_dcd_ex1_act,
   vdd,
   gnd,
   scan_in,
   scan_out,
   clkoff_b,
   act_dis,
   flush,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   thold_1,
   sg_1,
   fpu_enable,
   nclk
);
   parameter           THREADS = 2;
   input               f_dcd_ex7_cancel;		
   
   input               f_dcd_ex1_bypsel_a_res0;
   input               f_dcd_ex1_bypsel_a_res1;
   input               f_dcd_ex1_bypsel_a_res2;
   input               f_dcd_ex1_bypsel_a_load0;
   input               f_dcd_ex1_bypsel_a_load1;
   input               f_dcd_ex1_bypsel_a_load2;
   input               f_dcd_ex1_bypsel_a_reload0;
   input               f_dcd_ex1_bypsel_a_reload1;
   input               f_dcd_ex1_bypsel_a_reload2;
      
   input               f_dcd_ex1_bypsel_b_res0;
   input               f_dcd_ex1_bypsel_b_res1;
   input               f_dcd_ex1_bypsel_b_res2;
   input               f_dcd_ex1_bypsel_b_load0;
   input               f_dcd_ex1_bypsel_b_load1;
   input               f_dcd_ex1_bypsel_b_load2;
   input               f_dcd_ex1_bypsel_b_reload0;
   input               f_dcd_ex1_bypsel_b_reload1;
   input               f_dcd_ex1_bypsel_b_reload2;
      
   input               f_dcd_ex1_bypsel_c_res0;
   input               f_dcd_ex1_bypsel_c_res1;
   input               f_dcd_ex1_bypsel_c_res2;
   input               f_dcd_ex1_bypsel_c_load0;
   input               f_dcd_ex1_bypsel_c_load1;
   input               f_dcd_ex1_bypsel_c_load2;
   input               f_dcd_ex1_bypsel_c_reload0;
   input               f_dcd_ex1_bypsel_c_reload1;
   input               f_dcd_ex1_bypsel_c_reload2;
     
   input               f_dcd_ex1_bypsel_s_res0;
   input               f_dcd_ex1_bypsel_s_res1;
   input               f_dcd_ex1_bypsel_s_res2;
   input               f_dcd_ex1_bypsel_s_load0;
   input               f_dcd_ex1_bypsel_s_load1;
   input               f_dcd_ex1_bypsel_s_load2;
   input               f_dcd_ex1_bypsel_s_reload0;
   input               f_dcd_ex1_bypsel_s_reload1;
   input               f_dcd_ex1_bypsel_s_reload2;  

   input               f_dcd_ex2_perr_force_c;
   
   input               f_dcd_ex2_perr_fsel_ovrd;
   
 
   input               f_fpr_ex8_frt_sign;		
   input [1:13]        f_fpr_ex8_frt_expo;		
   input [0:52]        f_fpr_ex8_frt_frac;		
   input               f_fpr_ex9_frt_sign;		
   input [1:13]        f_fpr_ex9_frt_expo;		
   input [0:52]        f_fpr_ex9_frt_frac;		
   
   input               f_fpr_ex6_load_sign;
   input [3:13]        f_fpr_ex6_load_expo;
   input [0:52]        f_fpr_ex6_load_frac;   
   input               f_fpr_ex7_load_sign;		
   input [3:13]        f_fpr_ex7_load_expo;		
   input [0:52]        f_fpr_ex7_load_frac;		
   input               f_fpr_ex8_load_sign;		
   input [3:13]        f_fpr_ex8_load_expo;		
   input [0:52]        f_fpr_ex8_load_frac;		
   
   input               f_fpr_ex6_reload_sign;
   input [3:13]        f_fpr_ex6_reload_expo;
   input [0:52]        f_fpr_ex6_reload_frac;   
   input               f_fpr_ex7_reload_sign;		
   input [3:13]        f_fpr_ex7_reload_expo;		
   input [0:52]        f_fpr_ex7_reload_frac;		
   input               f_fpr_ex8_reload_sign;		
   input [3:13]        f_fpr_ex8_reload_expo;		
   input [0:52]        f_fpr_ex8_reload_frac;
   
   input               f_fpr_ex1_s_sign;
   input [3:13]        f_fpr_ex1_s_expo;
   input [0:52]        f_fpr_ex1_s_frac;		
   
   output              f_byp_ex1_s_sign;
   output [3:13]       f_byp_ex1_s_expo;
   output [0:52]       f_byp_ex1_s_frac;
   
   output              f_pic_ex6_scr_upd_move_b;
   input               f_dcd_ex7_fpscr_wr;
   input [0:5]         f_dcd_ex7_fpscr_addr;
   output [0:63]       f_dsq_debug;
   
   input [0:THREADS-1] cp_axu_i0_t1_v;
   input [0:2] 	       cp_axu_i0_t0_t1_t;
   input [0:2] 	       cp_axu_i0_t1_t1_t;
   input [0:5] 	       cp_axu_i0_t0_t1_p;
   input [0:5] 	       cp_axu_i0_t1_t1_p;
         
   input [0:THREADS-1] cp_axu_i1_t1_v;
   input [0:2] 	       cp_axu_i1_t0_t1_t;
   input [0:2] 	       cp_axu_i1_t1_t1_t;
   input [0:5] 	       cp_axu_i1_t0_t1_p;
   input [0:5] 	       cp_axu_i1_t1_t1_p;
    

   input               f_fpr_ex1_a_sign;
   input [1:13]        f_fpr_ex1_a_expo;
   input [0:52]        f_fpr_ex1_a_frac;
   input [0:7]         f_fpr_ex2_a_par;		
   
   input               f_fpr_ex1_c_sign;
   input [1:13]        f_fpr_ex1_c_expo;
   input [0:52]        f_fpr_ex1_c_frac;
   input [0:7]         f_fpr_ex2_c_par;		
   
   input               f_fpr_ex1_b_sign;
   input [1:13]        f_fpr_ex1_b_expo;
   input [0:52]        f_fpr_ex1_b_frac;
   input [0:7]         f_fpr_ex2_b_par;		
   
   input               f_dcd_ex1_aop_valid;
   input               f_dcd_ex1_cop_valid;
   input               f_dcd_ex1_bop_valid;
   input [0:1]         f_dcd_ex1_thread;
   input               f_dcd_ex1_sp;		
   input               f_dcd_ex1_emin_dp;		
   input               f_dcd_ex1_emin_sp;		
   input               f_dcd_ex1_force_pass_b;		
   
   input               f_dcd_ex1_fsel_b;		
   input               f_dcd_ex1_from_integer_b;		
   input               f_dcd_ex1_to_integer_b;		
   input               f_dcd_ex1_rnd_to_int_b;		
   input               f_dcd_ex1_math_b;		
   input               f_dcd_ex1_est_recip_b;		
   input               f_dcd_ex1_est_rsqrt_b;		
   input               f_dcd_ex1_move_b;		
   input               f_dcd_ex1_prenorm_b;		
   input               f_dcd_ex1_frsp_b;		
   input               f_dcd_ex1_compare_b;		
   input               f_dcd_ex1_ordered_b;		
   
   input               f_dcd_ex1_pow2e_b;		
   input               f_dcd_ex1_log2e_b;		
   
   input               f_dcd_ex1_ftdiv;		
   input               f_dcd_ex1_ftsqrt;		
   
   input               f_dcd_ex1_nj_deno;		
   input               f_dcd_ex1_nj_deni;		
   
   input               f_dcd_ex1_sp_conv_b;		
   input               f_dcd_ex1_word_b;		
   input               f_dcd_ex1_uns_b;		
   input               f_dcd_ex1_sub_op_b;		
   
   input               f_dcd_ex1_force_excp_dis;
   
   input               f_dcd_ex1_op_rnd_v_b;		
   input [0:1]         f_dcd_ex1_op_rnd_b;		
   input               f_dcd_ex1_inv_sign_b;		
   input [0:1]         f_dcd_ex1_sign_ctl_b;		
   input               f_dcd_ex1_sgncpy_b;		
   
   input [0:3]         f_dcd_ex1_fpscr_bit_data_b;		
   input [0:3]         f_dcd_ex1_fpscr_bit_mask_b;		
   input [0:8]         f_dcd_ex1_fpscr_nib_mask_b;		
   
   input               f_dcd_ex1_mv_to_scr_b;		
   input               f_dcd_ex1_mv_from_scr_b;		
   input               f_dcd_ex1_mtfsbx_b;		
   input               f_dcd_ex1_mcrfs_b;		
   input               f_dcd_ex1_mtfsf_b;		
   input               f_dcd_ex1_mtfsfi_b;		
   
   input               f_dcd_ex1_uc_fc_hulp;		
   input               f_dcd_ex1_uc_fa_pos;		
   input               f_dcd_ex1_uc_fc_pos;		
   input               f_dcd_ex1_uc_fb_pos;		
   input               f_dcd_ex1_uc_fc_0_5;		
   input               f_dcd_ex1_uc_fc_1_0;		
   input               f_dcd_ex1_uc_fc_1_minus;		
   input               f_dcd_ex1_uc_fb_1_0;		
   input               f_dcd_ex1_uc_fb_0_75;		
   input               f_dcd_ex1_uc_fb_0_5;		
   input               f_dcd_ex1_uc_ft_pos;		
   input               f_dcd_ex1_uc_ft_neg;		
   

   input               f_dcd_ex1_uc_mid;
   input               f_dcd_ex1_uc_end;
   input               f_dcd_ex1_uc_special;
   input               f_dcd_ex3_uc_zx;
   input               f_dcd_ex3_uc_vxidi;
   input               f_dcd_ex3_uc_vxzdz;
   input               f_dcd_ex3_uc_vxsqrt;
   input               f_dcd_ex3_uc_vxsnan;
   
   input               f_dcd_ex3_uc_inc_lsb;
   input               f_dcd_ex3_uc_gs_v;
   input [0:1]         f_dcd_ex3_uc_gs;
   
   output              f_mad_ex7_uc_sign;
   output              f_mad_ex7_uc_zero;
   output              f_mad_ex4_uc_special;
   output              f_mad_ex4_uc_zx;
   output              f_mad_ex4_uc_vxidi;
   output              f_mad_ex4_uc_vxzdz;
   output              f_mad_ex4_uc_vxsqrt;
   output              f_mad_ex4_uc_vxsnan;
   output              f_mad_ex4_uc_res_sign;
   output [0:1]        f_mad_ex4_uc_round_mode;
   
   output              f_mad_ex3_a_parity_check;		
   output              f_mad_ex3_c_parity_check;		
   output              f_mad_ex3_b_parity_check;		
   
   input               f_dcd_ex0_div;
   input               f_dcd_ex0_divs;
   input               f_dcd_ex0_sqrt;
   input               f_dcd_ex0_sqrts;
   input               f_dcd_ex0_record_v;
   input               f_dcd_ex2_divsqrt_v;
   
   input               f_dcd_ex2_divsqrt_hole_v;
   input [0:1]         f_dcd_flush;
   input [0:6]         f_dcd_ex1_itag;
   input [0:5]         f_dcd_ex1_fpscr_addr;
   input [0:5]         f_dcd_ex1_instr_frt;
   input [0:3]         f_dcd_ex1_instr_tid;
   
   input [0:4]         f_dcd_ex1_divsqrt_cr_bf;
   input               f_dcd_axucr0_deno;
   
   output [0:1]        f_dsq_ex5_divsqrt_v;
   output [0:1]        f_dsq_ex6_divsqrt_v;
   output              f_dsq_ex6_divsqrt_record_v;
   output [0:4]        f_dsq_ex6_divsqrt_cr_bf;
   
   output              f_dsq_ex6_divsqrt_v_suppress;
   output [0:6]        f_dsq_ex5_divsqrt_itag;
   output [0:5]        f_dsq_ex6_divsqrt_fpscr_addr;
   output [0:5]        f_dsq_ex6_divsqrt_instr_frt;
   output [0:3]        f_dsq_ex6_divsqrt_instr_tid;
   output              f_dsq_ex3_hangcounter_trigger;
   
   output              f_ex3_b_den_flush;		
   
   output [0:3]        f_scr_ex8_cr_fld;		
   output              f_scr_ex6_fpscr_ni_thr0;
   output              f_scr_ex6_fpscr_ni_thr1;   
   output [0:3]        f_add_ex5_fpcc_iu;		
   output              f_pic_ex6_fpr_wr_dis_b;		
   output [1:13]       f_rnd_ex7_res_expo;		
   output [0:52]       f_rnd_ex7_res_frac;		
   output              f_rnd_ex7_res_sign;		
   output [0:3]        f_scr_ex8_fx_thread0;		
   output [0:3]        f_scr_ex8_fx_thread1;		
   output [0:3]        f_scr_cpl_fx_thread0;		
   output [0:3]        f_scr_cpl_fx_thread1;		
   
   input [0:3]         ex1_thread_b;
   input               f_dcd_ex1_act;		
   inout               vdd;
   inout               gnd;
   input [0:18]        scan_in;		
   output [0:18]       scan_out;		
   
   input               clkoff_b;		
   input               act_dis;		
   input               flush;		
   input [1:7]         delay_lclkr;		
   input [1:7]         mpw1_b;		
   input [0:1]         mpw2_b;		
   input               thold_1;
   input               sg_1;
   input               fpu_enable;
   input  [0:`NCLK_WIDTH-1]              nclk;
   
   
   parameter           tiup = 1'b1;
   parameter           tidn = 1'b0;
   
   wire                f_fmt_ex2_inf_and_beyond_sp;
   wire                perv_eie_sg_1;		
   wire                perv_eov_sg_1;		
   wire                perv_fmt_sg_1;		
   wire                perv_mul_sg_1;		
   wire                perv_alg_sg_1;		
   wire                perv_add_sg_1;		
   wire                perv_lza_sg_1;		
   wire                perv_nrm_sg_1;		
   wire                perv_rnd_sg_1;		
   wire                perv_scr_sg_1;		
   wire                perv_pic_sg_1;		
   wire                perv_cr2_sg_1;		
   wire                perv_eie_thold_1;		
   wire                perv_eov_thold_1;		
   wire                perv_fmt_thold_1;		
   wire                perv_mul_thold_1;		
   wire                perv_alg_thold_1;		
   wire                perv_add_thold_1;		
   wire                perv_lza_thold_1;		
   wire                perv_nrm_thold_1;		
   wire                perv_rnd_thold_1;		
   wire                perv_scr_thold_1;		
   wire                perv_pic_thold_1;		
   wire                perv_cr2_thold_1;		
   wire                perv_eie_fpu_enable;		
   wire                perv_eov_fpu_enable;		
   wire                perv_fmt_fpu_enable;		
   wire                perv_mul_fpu_enable;		
   wire                perv_alg_fpu_enable;		
   wire                perv_add_fpu_enable;		
   wire                perv_lza_fpu_enable;		
   wire                perv_nrm_fpu_enable;		
   wire                perv_rnd_fpu_enable;		
   wire                perv_scr_fpu_enable;		
   wire                perv_pic_fpu_enable;		
   wire                perv_cr2_fpu_enable;		
   
   wire                f_eov_ex5_may_ovf;
   wire                f_add_ex5_flag_eq;		
   wire                f_add_ex5_flag_gt;		
   wire                f_add_ex5_flag_lt;		
   wire                f_add_ex5_flag_nan;		
   wire [0:162]        f_add_ex5_res;		
   wire                f_add_ex5_sign_carry;		
   wire                f_add_ex5_sticky;		
   wire [0:1]          f_add_ex5_to_int_ovf_dw;		
   wire [0:1]          f_add_ex5_to_int_ovf_wd;		
   wire                f_alg_ex3_effsub_eac_b;		
   wire                f_alg_ex3_prod_z;		
   wire [0:162]        f_alg_ex3_res;		
   wire                f_alg_ex3_sel_byp;		
   wire                f_alg_ex3_sh_ovf;		
   wire                f_alg_ex3_sh_unf;		
   wire                f_alg_ex4_frc_sel_p1;		
   wire                f_alg_ex4_int_fi;		
   wire                f_alg_ex4_int_fr;		
   wire                f_alg_ex4_sticky;		
   
   wire [0:7]          f_scr_fpscr_ctrl_thr0;
   wire [0:7]          f_scr_fpscr_ctrl_thr1;
   
   wire [1:13]         f_byp_fmt_ex2_a_expo;		
   wire [1:13]         f_byp_eie_ex2_a_expo;		
   wire [1:13]         f_byp_alg_ex2_a_expo;		
   wire [1:13]         f_byp_fmt_ex2_b_expo;		
   wire [1:13]         f_byp_eie_ex2_b_expo;		
   wire [1:13]         f_byp_alg_ex2_b_expo;		
   wire [1:13]         f_byp_fmt_ex2_c_expo;		
   wire [1:13]         f_byp_eie_ex2_c_expo;		
   wire [1:13]         f_byp_alg_ex2_c_expo;		
   wire [0:52]         f_byp_fmt_ex2_a_frac;		
   wire [0:52]         f_byp_fmt_ex2_c_frac;		
   wire [0:52]         f_byp_fmt_ex2_b_frac;		
   wire [0:52]         f_byp_mul_ex2_a_frac;		
   wire                f_byp_mul_ex2_a_frac_17;		
   wire                f_byp_mul_ex2_a_frac_35;		
   wire [0:53]         f_byp_mul_ex2_c_frac;		
   wire [0:52]         f_byp_alg_ex2_b_frac;		
   wire                f_byp_fmt_ex2_a_sign;		
   wire                f_byp_fmt_ex2_b_sign;		
   wire                f_byp_fmt_ex2_c_sign;		
   wire                f_byp_pic_ex2_a_sign;		
   wire                f_byp_pic_ex2_b_sign;		
   wire                f_byp_pic_ex2_c_sign;		
   wire                f_byp_alg_ex2_b_sign;		
   
   wire [0:7]          f_cr2_ex2_fpscr_shadow;		
   wire                f_pic_ex3_rnd_inf_ok;		
   wire                f_pic_ex3_rnd_nr;		
   wire [0:3]          f_cr2_ex4_fpscr_bit_data_b;
   wire [0:3]          f_cr2_ex4_fpscr_bit_mask_b;
   wire [0:8]          f_cr2_ex4_fpscr_nib_mask_b;
   wire                f_cr2_ex4_mcrfs_b;		
   wire                f_cr2_ex4_mtfsbx_b;		
   wire                f_cr2_ex4_mtfsf_b;		
   wire                f_cr2_ex4_mtfsfi_b;		
   wire [0:3]          f_cr2_ex4_thread_b;		
   wire                f_pic_add_ex2_act_b;		
   wire                f_pic_eov_ex3_act_b;		
   wire                f_pic_ex2_effsub_raw;		
   wire                f_pic_ex2_from_integer;		
   wire                f_pic_ex2_fsel;		
   wire                f_pic_ex2_sh_ovf_do;		
   wire                f_pic_ex2_sh_ovf_ig_b;		
   wire                f_pic_ex2_sh_unf_do;		
   wire                f_pic_ex2_sh_unf_ig_b;		
   wire                f_pic_ex3_force_sel_bexp;		
   wire                f_pic_ex3_lzo_dis_prod;		
   wire                f_pic_ex3_sp_b;		
   wire                f_pic_ex3_sp_lzo;		
   wire                f_pic_ex3_to_integer;		
   wire                f_pic_ex3_prenorm;		
   wire                f_pic_ex4_cmp_sgnneg;		
   wire                f_pic_ex4_cmp_sgnpos;		
   wire                f_pic_ex4_is_eq;		
   wire                f_pic_ex4_is_gt;		
   wire                f_pic_ex4_is_lt;		
   wire                f_pic_ex4_is_nan;		
   wire                f_pic_ex4_sel_est;		
   wire                f_pic_ex4_sp_b;		
   wire                f_pic_ex5_nj_deno;		
   wire                f_pic_ex5_oe;		
   wire                f_pic_ex5_ov_en;		
   wire                f_pic_ex5_ovf_en_oe0_b;		
   wire                f_pic_ex5_ovf_en_oe1_b;		
   wire                f_pic_ex5_quiet_b;		
   wire                f_pic_ex6_uc_inc_lsb;		
   wire                f_pic_ex6_uc_guard;		
   wire                f_pic_ex6_uc_sticky;		
   wire                f_pic_ex6_uc_g_v;		
   wire                f_pic_ex6_uc_s_v;		
   wire                f_pic_ex5_rnd_inf_ok_b;		
   wire                f_pic_ex5_rnd_ni_b;		
   wire                f_pic_ex5_rnd_nr_b;		
   wire                f_pic_ex5_sel_est_b;		
   wire                f_pic_ex5_sel_fpscr_b;		
   wire                f_pic_ex5_sp_b;		
   wire                f_pic_ex5_spec_inf_b;		
   wire                f_pic_ex5_spec_sel_k_e;		
   wire                f_pic_ex5_spec_sel_k_f;		
   wire                f_pic_ex5_to_int_ov_all;		
   wire                f_pic_ex5_to_integer_b;		
   wire                f_pic_ex5_word_b;		
   wire                f_pic_ex5_uns_b;		
   wire                f_pic_ex5_ue;		
   wire                f_pic_ex5_uf_en;		
   wire                f_pic_ex5_unf_en_ue0_b;		
   wire                f_pic_ex5_unf_en_ue1_b;		
   wire                f_pic_ex6_en_exact_zero;		
   wire                f_pic_ex6_compare_b;		
   wire                f_pic_ex3_ue1;		
   wire                f_pic_ex3_frsp_ue1;		
   wire                f_pic_ex2_frsp_ue1;		
   wire                f_pic_ex6_frsp;		
   wire                f_pic_ex6_fi_pipe_v_b;		
   wire                f_pic_ex6_fi_spec_b;		
   wire                f_pic_ex6_flag_vxcvi_b;		
   wire                f_pic_ex6_flag_vxidi_b;		
   wire                f_pic_ex6_flag_vximz_b;		
   wire                f_pic_ex6_flag_vxisi_b;		
   wire                f_pic_ex6_flag_vxsnan_b;		
   wire                f_pic_ex6_flag_vxsqrt_b;		
   wire                f_pic_ex6_flag_vxvc_b;		
   wire                f_pic_ex6_flag_vxzdz_b;		
   wire                f_pic_ex6_flag_zx_b;		
   wire                f_pic_ex6_fprf_hold_b;		
   wire                f_pic_ex6_fprf_pipe_v_b;		
   wire [0:4]          f_pic_ex6_fprf_spec_b;		
   wire                f_pic_ex6_fr_pipe_v_b;		
   wire                f_pic_ex6_fr_spec_b;		
   wire                f_pic_ex6_invert_sign;		
   wire                f_pic_ex5_byp_prod_nz;		
   wire                f_pic_ex6_k_nan;
   wire                f_pic_ex6_k_inf;
   wire                f_pic_ex6_k_max;
   wire                f_pic_ex6_k_zer;
   wire                f_pic_ex6_k_one;
   wire                f_pic_ex6_k_int_maxpos;
   wire                f_pic_ex6_k_int_maxneg;
   wire                f_pic_ex6_k_int_zer;
   wire                f_pic_ex6_ox_pipe_v_b;		
   wire                f_pic_ex6_round_sign;		
   wire                f_pic_ex6_scr_upd_move_b_int;		
   wire                f_pic_ex6_scr_upd_pipe_b;		
   wire                f_pic_ex6_ux_pipe_v_b;		
   wire                f_pic_lza_ex2_act_b;		
   wire                f_pic_mul_ex2_act;		
   wire                f_pic_fmt_ex2_act;
   wire                f_pic_eie_ex2_act;
   wire                f_pic_alg_ex2_act;
   wire                f_pic_cr2_ex2_act;
   wire                f_fmt_ex3_be_den;
   
   wire                f_pic_nrm_ex4_act_b;		
   wire                f_pic_rnd_ex4_act_b;		
   wire                f_pic_scr_ex3_act_b;		
   wire                f_eie_ex3_dw_ov;		
   wire                f_eie_ex3_dw_ov_if;		
   wire [1:13]         f_eie_ex3_lzo_expo;		
   wire [1:13]         f_eie_ex3_b_expo;		
   wire [1:13]         f_eie_ex3_tbl_expo;		
   wire                f_eie_ex3_wd_ov;		
   wire                f_eie_ex3_wd_ov_if;		
   wire [1:13]         f_eie_ex4_iexp;		
   wire [1:13]         f_eov_ex6_expo_p0;		
   wire [3:7]          f_eov_ex6_expo_p0_ue1oe1;		
   wire [1:13]         f_eov_ex6_expo_p1;		
   wire [3:7]          f_eov_ex6_expo_p1_ue1oe1;		
   wire                f_eov_ex6_ovf_expo;		
   wire                f_eov_ex6_ovf_if_expo;		
   wire                f_eov_ex6_sel_k_e;		
   wire                f_eov_ex6_sel_k_f;		
   wire                f_eov_ex6_sel_kif_e;		
   wire                f_eov_ex6_sel_kif_f;		
   wire                f_eov_ex6_unf_expo;		
   wire                f_fmt_ex2_a_expo_max;		
   wire                f_fmt_ex2_a_expo_max_dsq;		
   wire                f_fmt_ex2_a_zero;		
   wire                f_fmt_ex2_a_zero_dsq;		
   wire                f_fmt_ex2_a_frac_msb;		
   wire                f_fmt_ex2_a_frac_zero;		
   wire                f_fmt_ex2_b_expo_max;		
   wire                f_fmt_ex2_b_expo_max_dsq;		
   wire                f_fmt_ex2_b_zero;		
   wire                f_fmt_ex2_b_zero_dsq;		
   wire                f_fmt_ex2_b_frac_msb;		
   wire                f_fmt_ex2_b_frac_z32;
   wire                f_fmt_ex2_b_frac_zero;		
   wire [45:52]        f_fmt_ex2_bop_byt;		
   wire                f_fmt_ex2_c_expo_max;		
   wire                f_fmt_ex2_c_zero;		
   wire                f_fmt_ex2_c_frac_msb;		
   wire                f_fmt_ex2_c_frac_zero;		
   wire                f_fmt_ex2_sp_invalid;		
   wire                f_fmt_ex2_pass_sel;		
   wire                f_fmt_ex2_prod_zero;		
   wire                f_fmt_ex3_fsel_bsel;		
   wire [0:52]         f_fmt_ex3_pass_frac;		
   wire                f_fmt_ex3_pass_sign;		
   wire                f_fmt_ex3_pass_msb;		
   wire                f_fmt_ex2_b_imp;		
   wire [0:7]          f_lza_ex5_lza_amt;		
   wire [0:2]          f_lza_ex5_lza_dcd64_cp1;
   wire [0:1]          f_lza_ex5_lza_dcd64_cp2;
   wire [0:0]          f_lza_ex5_lza_dcd64_cp3;
   wire                f_lza_ex5_sh_rgt_en;
   wire                f_lza_ex5_sh_rgt_en_eov;
   wire [0:7]          f_lza_ex5_lza_amt_eov;		
   wire                f_lza_ex5_no_lza_edge;		
   wire [1:108]        f_mul_ex3_car;		
   wire [1:108]        f_mul_ex3_sum;		
   wire                f_nrm_ex5_extra_shift;		
   wire                f_nrm_ex6_exact_zero;		
   wire [0:31]         f_nrm_ex6_fpscr_wr_dat;		
   wire [0:3]          f_nrm_ex6_fpscr_wr_dat_dfp;		
   wire [1:12]         f_nrm_ex6_int_lsbs;		
   wire                f_nrm_ex6_int_sign;
   wire                f_nrm_ex6_nrm_guard_dp;		
   wire                f_nrm_ex6_nrm_guard_sp;		
   wire                f_nrm_ex6_nrm_lsb_dp;		
   wire                f_nrm_ex6_nrm_lsb_sp;		
   wire                f_nrm_ex6_nrm_sticky_dp;		
   wire                f_nrm_ex6_nrm_sticky_sp;		
   wire [0:52]         f_nrm_ex6_res;		
   wire                f_rnd_ex7_flag_den;		
   wire                f_rnd_ex7_flag_fi;		
   wire                f_rnd_ex7_flag_inf;		
   wire                f_rnd_ex7_flag_ox;		
   wire                f_rnd_ex7_flag_sgn;		
   wire                f_rnd_ex7_flag_up;		
   wire                f_rnd_ex7_flag_ux;		
   wire                f_rnd_ex7_flag_zer;		
   wire [53:161]       f_sa3_ex4_c_lza;		
   wire [0:162]        f_sa3_ex4_s_lza;		
   wire [53:161]       f_sa3_ex4_c_add;		
   wire [0:162]        f_sa3_ex4_s_add;		
   wire [0:3]          f_scr_ex6_fpscr_rd_dat_dfp;		
   wire [0:31]         f_scr_ex6_fpscr_rd_dat;		
   wire [0:1]          f_scr_ex6_fpscr_rm_thr0;		
   wire [0:4]          f_scr_ex6_fpscr_ee_thr0;		
   wire                f_scr_ex6_fpscr_ni_thr0_int;		
   
   wire [0:1]          f_scr_ex6_fpscr_rm_thr1;		
   wire [0:4]          f_scr_ex6_fpscr_ee_thr1;		
   wire                f_scr_ex6_fpscr_ni_thr1_int;		
      
   wire [24:31]        f_cr2_ex6_fpscr_rd_dat;		
   wire [24:31]        f_cr2_ex7_fpscr_rd_dat;		
   wire                f_pic_tbl_ex2_act;
   wire                f_pic_ex2_ftdiv;
   
   wire                f_pic_ex3_math_bzer_b;
   wire                perv_sa3_thold_1;
   wire                perv_sa3_sg_1;
   wire                perv_sa3_fpu_enable;
   wire                f_pic_ex3_b_valid;
   wire                f_alg_ex3_byp_nonflip;
   wire                f_pic_ex2_rnd_to_int;
   wire                f_eie_ex3_lt_bias;
   wire                f_eie_ex3_eq_bias_m1;
   wire                f_pic_ex3_est_recip;
   wire                f_pic_ex3_est_rsqrt;
   wire                f_tbe_ex4_may_ov;
   wire [1:13]         f_tbe_ex4_res_expo;
   wire                perv_tbe_sg_1;
   wire                perv_tbe_thold_1;
   wire                perv_tbe_fpu_enable;
   wire                perv_tbl_sg_1;
   wire                perv_tbl_thold_1;
   wire                perv_tbl_fpu_enable;
   wire                f_tbe_ex4_recip_2046;
   wire                f_tbe_ex4_recip_2045;
   wire [1:19]         f_fmt_ex2_b_frac;
   wire [0:26]         f_tbl_ex6_est_frac;
   wire                f_tbl_ex6_recip_den;
   wire                f_eie_ex3_use_bexp;
   wire                rnd_ex7_res_sign;
   wire [1:13]         rnd_ex7_res_expo;
   wire [0:52]         rnd_ex7_res_frac;
   wire                f_pic_ex2_flush_en_dp;
   wire                f_pic_ex2_flush_en_sp;
   wire                f_fmt_ex3_lu_den_recip;
   wire                f_fmt_ex3_lu_den_rsqrto;
   wire                f_tbe_ex4_recip_2044;
   wire                f_tbe_ex4_lu_sh;
   
   wire [0:162]        f_lze_ex3_lzo_din;
   wire [0:7]          f_lze_ex4_sh_rgt_amt;
   wire                f_lze_ex4_sh_rgt_en;
   wire                f_alg_ex2_sign_frmw;
   wire                f_tbe_ex4_match_en_sp;
   wire                f_tbe_ex4_match_en_dp;
   wire                f_tbl_ex5_unf_expo;
   wire                f_tbe_ex4_recip_ue1;
   wire                f_fmt_ex2_bexpu_le126;
   wire                f_fmt_ex2_gt126;
   wire                f_fmt_ex2_ge128;
   wire                f_gst_ex6_logexp_v;
   wire                f_gst_ex6_logexp_sign;
   wire [1:11]         f_gst_ex6_logexp_exp;
   wire [0:19]         f_gst_ex6_logexp_fract;
   wire                f_fmt_ex2_b_sign_gst;
   wire [1:13]         f_fmt_ex2_b_expo_gst_b;
   wire                f_pic_ex2_log2e;
   wire                f_pic_ex2_pow2e;
   wire                f_fmt_ex2_a_sign_div;
   wire [01:13]        f_fmt_ex2_a_expo_div_b;
   wire [01:52]        f_fmt_ex2_a_frac_div;
   wire                f_fmt_ex2_b_sign_div;
   wire [01:13]        f_fmt_ex2_b_expo_div_b;
   wire [01:52]        f_fmt_ex2_b_frac_div;
   
   wire                f_dsq_ex6_divsqrt_v_int_suppress;
   wire [0:1]          f_dsq_ex6_divsqrt_v_int;
   wire                f_dsq_ex6_divsqrt_record_v_int;
   wire [0:1]          f_dsq_ex5_divsqrt_v_int;
   wire [0:6]          f_dsq_ex5_divsqrt_itag_int;
   
   wire [0:5]          f_dsq_ex6_divsqrt_fpscr_addr_int;
   wire [0:5]          f_dsq_ex6_divsqrt_instr_frt_int;
   wire [0:3]          f_dsq_ex6_divsqrt_instr_tid_int;
   wire                f_dsq_ex3_hangcounter_trigger_int;

   
   wire [0:4]          f_dsq_ex6_divsqrt_cr_bf_int;
   
   wire                f_dsq_ex6_divsqrt_sign;
   wire [01:13]        f_dsq_ex6_divsqrt_exp;
   wire [00:52]        f_dsq_ex6_divsqrt_fract;
   
   wire [00:15]        f_dsq_ex6_divsqrt_flag_fpscr;
   
   wire                f_mad_ex3_uc_a_expo_den;		
   wire                f_mad_ex3_uc_a_expo_den_sp;
   wire                f_pic_ex2_nj_deni;
   wire                f_fmt_ex3_ae_ge_54;
   wire                f_fmt_ex3_be_ge_54;
   wire                f_fmt_ex3_be_ge_2;
   wire                f_fmt_ex3_be_ge_2044;
   wire                f_fmt_ex3_tdiv_rng_chk;


 
   
   fu_byp  fbyp(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[1]),		
      .mpw1_b(mpw1_b[1]),		
      .mpw2_b(mpw2_b[0]),		
      .thold_1(perv_fmt_thold_1),		
      .sg_1(perv_fmt_sg_1),		
      .fpu_enable(perv_fmt_fpu_enable),		
      
      .f_byp_si(scan_in[0]),		
      .f_byp_so(scan_out[0]),		
      .ex1_act(f_dcd_ex1_act),		
      
      .f_fpr_ex8_frt_sign(f_fpr_ex8_frt_sign),		
      .f_fpr_ex8_frt_expo(f_fpr_ex8_frt_expo[1:13]),		
      .f_fpr_ex8_frt_frac(f_fpr_ex8_frt_frac[0:52]),		
      .f_fpr_ex9_frt_sign(f_fpr_ex9_frt_sign),		
      .f_fpr_ex9_frt_expo(f_fpr_ex9_frt_expo[1:13]),		
      .f_fpr_ex9_frt_frac(f_fpr_ex9_frt_frac[0:52]),		

      .f_fpr_ex6_load_sign(f_fpr_ex6_load_sign),		
      .f_fpr_ex6_load_expo(f_fpr_ex6_load_expo[3:13]),		
      .f_fpr_ex6_load_frac(f_fpr_ex6_load_frac[0:52]),		
      .f_fpr_ex7_load_sign(f_fpr_ex7_load_sign),		
      .f_fpr_ex7_load_expo(f_fpr_ex7_load_expo[3:13]),		
      .f_fpr_ex7_load_frac(f_fpr_ex7_load_frac[0:52]),		
      .f_fpr_ex8_load_sign(f_fpr_ex8_load_sign),		
      .f_fpr_ex8_load_expo(f_fpr_ex8_load_expo[3:13]),		
      .f_fpr_ex8_load_frac(f_fpr_ex8_load_frac[0:52]),		

      .f_fpr_ex6_reload_sign(f_fpr_ex6_reload_sign),		
      .f_fpr_ex6_reload_expo(f_fpr_ex6_reload_expo[3:13]),		
      .f_fpr_ex6_reload_frac(f_fpr_ex6_reload_frac[0:52]),		
      .f_fpr_ex7_reload_sign(f_fpr_ex7_reload_sign),		
      .f_fpr_ex7_reload_expo(f_fpr_ex7_reload_expo[3:13]),		
      .f_fpr_ex7_reload_frac(f_fpr_ex7_reload_frac[0:52]),		
      .f_fpr_ex8_reload_sign(f_fpr_ex8_reload_sign),		
      .f_fpr_ex8_reload_expo(f_fpr_ex8_reload_expo[3:13]),		
      .f_fpr_ex8_reload_frac(f_fpr_ex8_reload_frac[0:52]),		

		
      .f_fpr_ex1_s_sign(f_fpr_ex1_s_sign),
      .f_fpr_ex1_s_expo(f_fpr_ex1_s_expo),
      .f_fpr_ex1_s_frac(f_fpr_ex1_s_frac),
      .f_byp_ex1_s_sign(f_byp_ex1_s_sign),
      .f_byp_ex1_s_expo(f_byp_ex1_s_expo),
      .f_byp_ex1_s_frac(f_byp_ex1_s_frac),
      
      .f_dcd_ex1_div_beg(tidn),		
		
      .f_dcd_ex1_uc_fa_pos(f_dcd_ex1_uc_fa_pos),		
      .f_dcd_ex1_uc_fc_pos(f_dcd_ex1_uc_fc_pos),		
      .f_dcd_ex1_uc_fb_pos(f_dcd_ex1_uc_fb_pos),		
      .f_dcd_ex1_uc_fc_0_5(f_dcd_ex1_uc_fc_0_5),		
      .f_dcd_ex1_uc_fc_1_0(f_dcd_ex1_uc_fc_1_0),		
      .f_dcd_ex1_uc_fc_1_minus(f_dcd_ex1_uc_fc_1_minus),		
      .f_dcd_ex1_uc_fb_1_0(f_dcd_ex1_uc_fb_1_0),		
      .f_dcd_ex1_uc_fb_0_75(f_dcd_ex1_uc_fb_0_75),		
      .f_dcd_ex1_uc_fb_0_5(f_dcd_ex1_uc_fb_0_5),		
      
      .f_dcd_ex1_uc_fc_hulp(f_dcd_ex1_uc_fc_hulp),		
      .f_dcd_ex1_bypsel_a_res0(f_dcd_ex1_bypsel_a_res0),		
      .f_dcd_ex1_bypsel_a_res1(f_dcd_ex1_bypsel_a_res1),		
      .f_dcd_ex1_bypsel_a_load0(f_dcd_ex1_bypsel_a_load0),		
      .f_dcd_ex1_bypsel_a_load1(f_dcd_ex1_bypsel_a_load1),		
      .f_dcd_ex1_bypsel_a_load2(f_dcd_ex1_bypsel_a_load2),
      .f_dcd_ex1_bypsel_a_reload0(f_dcd_ex1_bypsel_a_reload0),		
      .f_dcd_ex1_bypsel_a_reload1(f_dcd_ex1_bypsel_a_reload1),		
      .f_dcd_ex1_bypsel_a_reload2(f_dcd_ex1_bypsel_a_reload2),
		
      .f_dcd_ex1_bypsel_b_res0(f_dcd_ex1_bypsel_b_res0),		
      .f_dcd_ex1_bypsel_b_res1(f_dcd_ex1_bypsel_b_res1),		
      .f_dcd_ex1_bypsel_b_load0(f_dcd_ex1_bypsel_b_load0),		
      .f_dcd_ex1_bypsel_b_load1(f_dcd_ex1_bypsel_b_load1),		
      .f_dcd_ex1_bypsel_b_load2(f_dcd_ex1_bypsel_b_load2),
      .f_dcd_ex1_bypsel_b_reload0(f_dcd_ex1_bypsel_b_reload0),		
      .f_dcd_ex1_bypsel_b_reload1(f_dcd_ex1_bypsel_b_reload1),		
      .f_dcd_ex1_bypsel_b_reload2(f_dcd_ex1_bypsel_b_reload2),
		
      .f_dcd_ex1_bypsel_c_res0(f_dcd_ex1_bypsel_c_res0),		
      .f_dcd_ex1_bypsel_c_res1(f_dcd_ex1_bypsel_c_res1),		
      .f_dcd_ex1_bypsel_c_load0(f_dcd_ex1_bypsel_c_load0),		
      .f_dcd_ex1_bypsel_c_load1(f_dcd_ex1_bypsel_c_load1),		
      .f_dcd_ex1_bypsel_c_load2(f_dcd_ex1_bypsel_c_load2),
      .f_dcd_ex1_bypsel_c_reload0(f_dcd_ex1_bypsel_c_reload0),		
      .f_dcd_ex1_bypsel_c_reload1(f_dcd_ex1_bypsel_c_reload1),		
      .f_dcd_ex1_bypsel_c_reload2(f_dcd_ex1_bypsel_c_reload2),
            		
      .f_dcd_ex1_bypsel_a_res2(f_dcd_ex1_bypsel_a_res2),
      .f_dcd_ex1_bypsel_b_res2(f_dcd_ex1_bypsel_b_res2),
      .f_dcd_ex1_bypsel_c_res2(f_dcd_ex1_bypsel_c_res2),
      .f_dcd_ex1_bypsel_s_res0(f_dcd_ex1_bypsel_s_res0),
      .f_dcd_ex1_bypsel_s_res1(f_dcd_ex1_bypsel_s_res1),
      .f_dcd_ex1_bypsel_s_res2(f_dcd_ex1_bypsel_s_res2),		
      .f_dcd_ex1_bypsel_s_load0(f_dcd_ex1_bypsel_s_load0),
      .f_dcd_ex1_bypsel_s_load1(f_dcd_ex1_bypsel_s_load1),
      .f_dcd_ex1_bypsel_s_load2(f_dcd_ex1_bypsel_s_load2),
      .f_dcd_ex1_bypsel_s_reload0(f_dcd_ex1_bypsel_s_reload0),
      .f_dcd_ex1_bypsel_s_reload1(f_dcd_ex1_bypsel_s_reload1),
      .f_dcd_ex1_bypsel_s_reload2(f_dcd_ex1_bypsel_s_reload2),    
  
      .f_rnd_ex7_res_sign(rnd_ex7_res_sign),		
      .f_rnd_ex7_res_expo(rnd_ex7_res_expo[1:13]),		
      .f_rnd_ex7_res_frac(rnd_ex7_res_frac[0:52]),		

      .f_fpr_ex1_a_sign(f_fpr_ex1_a_sign),		
      .f_fpr_ex1_a_expo(f_fpr_ex1_a_expo[1:13]),		
      .f_fpr_ex1_a_frac(f_fpr_ex1_a_frac[0:52]),		
      .f_fpr_ex1_c_sign(f_fpr_ex1_c_sign),		
      .f_fpr_ex1_c_expo(f_fpr_ex1_c_expo[1:13]),		
      .f_fpr_ex1_c_frac(f_fpr_ex1_c_frac[0:52]),		
      .f_fpr_ex1_b_sign(f_fpr_ex1_b_sign),		
      .f_fpr_ex1_b_expo(f_fpr_ex1_b_expo[1:13]),		
      .f_fpr_ex1_b_frac(f_fpr_ex1_b_frac[0:52]),		
      .f_dcd_ex1_aop_valid(f_dcd_ex1_aop_valid),		
      .f_dcd_ex1_cop_valid(f_dcd_ex1_cop_valid),		
      .f_dcd_ex1_bop_valid(f_dcd_ex1_bop_valid),		
      .f_dcd_ex1_sp(f_dcd_ex1_sp),		
      .f_dcd_ex1_to_integer_b(f_dcd_ex1_to_integer_b),		
      .f_dcd_ex1_emin_dp(f_dcd_ex1_emin_dp),		
      .f_dcd_ex1_emin_sp(f_dcd_ex1_emin_sp),		
      
      .f_byp_fmt_ex2_a_expo(f_byp_fmt_ex2_a_expo[1:13]),		
      .f_byp_eie_ex2_a_expo(f_byp_eie_ex2_a_expo[1:13]),		
      .f_byp_alg_ex2_a_expo(f_byp_alg_ex2_a_expo[1:13]),		
      .f_byp_fmt_ex2_c_expo(f_byp_fmt_ex2_c_expo[1:13]),		
      .f_byp_eie_ex2_c_expo(f_byp_eie_ex2_c_expo[1:13]),		
      .f_byp_alg_ex2_c_expo(f_byp_alg_ex2_c_expo[1:13]),		
      .f_byp_fmt_ex2_b_expo(f_byp_fmt_ex2_b_expo[1:13]),		
      .f_byp_eie_ex2_b_expo(f_byp_eie_ex2_b_expo[1:13]),		
      .f_byp_alg_ex2_b_expo(f_byp_alg_ex2_b_expo[1:13]),		
      .f_byp_fmt_ex2_a_sign(f_byp_fmt_ex2_a_sign),		
      .f_byp_fmt_ex2_c_sign(f_byp_fmt_ex2_c_sign),		
      .f_byp_fmt_ex2_b_sign(f_byp_fmt_ex2_b_sign),		
      .f_byp_pic_ex2_a_sign(f_byp_pic_ex2_a_sign),		
      .f_byp_pic_ex2_c_sign(f_byp_pic_ex2_c_sign),		
      .f_byp_pic_ex2_b_sign(f_byp_pic_ex2_b_sign),		
      .f_byp_alg_ex2_b_sign(f_byp_alg_ex2_b_sign),		
      .f_byp_mul_ex2_a_frac_17(f_byp_mul_ex2_a_frac_17),		
      .f_byp_mul_ex2_a_frac_35(f_byp_mul_ex2_a_frac_35),		
      .f_byp_mul_ex2_a_frac(f_byp_mul_ex2_a_frac[0:52]),		
      .f_byp_fmt_ex2_a_frac(f_byp_fmt_ex2_a_frac[0:52]),		
      .f_byp_mul_ex2_c_frac({f_byp_mul_ex2_c_frac[0:52], f_byp_mul_ex2_c_frac[53]}),		
      .f_byp_fmt_ex2_c_frac(f_byp_fmt_ex2_c_frac[0:52]),		
      .f_byp_alg_ex2_b_frac(f_byp_alg_ex2_b_frac[0:52]),		
      .f_byp_fmt_ex2_b_frac(f_byp_fmt_ex2_b_frac[0:52])		
   );


   
   fu_fmt  ffmt(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[1:2]),		
      .mpw1_b(mpw1_b[1:2]),		
      .mpw2_b(mpw2_b[0:0]),		
      .thold_1(perv_fmt_thold_1),		
      .sg_1(perv_fmt_sg_1),		
      .fpu_enable(perv_fmt_fpu_enable),		
      
      .f_fmt_si(scan_in[1]),		
      .f_fmt_so(scan_out[1]),		
      .ex1_act(f_dcd_ex1_act), 
      .ex2_act(f_pic_fmt_ex2_act),
		
      .f_dcd_ex2_perr_force_c(f_dcd_ex2_perr_force_c),    
      .f_dcd_ex2_perr_fsel_ovrd(f_dcd_ex2_perr_fsel_ovrd),  
      .f_pic_ex2_ftdiv(f_pic_ex2_ftdiv),
      .f_fmt_ex3_be_den(f_fmt_ex3_be_den),		
      .f_fpr_ex2_a_par(f_fpr_ex2_a_par[0:7]),		
      .f_fpr_ex2_c_par(f_fpr_ex2_c_par[0:7]),		
      .f_fpr_ex2_b_par(f_fpr_ex2_b_par[0:7]),		
      
      .f_mad_ex3_a_parity_check(f_mad_ex3_a_parity_check),		
      .f_mad_ex3_c_parity_check(f_mad_ex3_c_parity_check),		
      .f_mad_ex3_b_parity_check(f_mad_ex3_b_parity_check),		
      .f_fmt_ex3_ae_ge_54(f_fmt_ex3_ae_ge_54),		
      .f_fmt_ex3_be_ge_54(f_fmt_ex3_be_ge_54),		
      .f_fmt_ex3_be_ge_2(f_fmt_ex3_be_ge_2),		
      .f_fmt_ex3_be_ge_2044(f_fmt_ex3_be_ge_2044),		
      .f_fmt_ex3_tdiv_rng_chk(f_fmt_ex3_tdiv_rng_chk),		
      
      .f_byp_fmt_ex2_a_sign(f_byp_fmt_ex2_a_sign),		
      .f_byp_fmt_ex2_c_sign(f_byp_fmt_ex2_c_sign),		
      .f_byp_fmt_ex2_b_sign(f_byp_fmt_ex2_b_sign),		
      .f_byp_fmt_ex2_a_expo(f_byp_fmt_ex2_a_expo[1:13]),		
      .f_byp_fmt_ex2_c_expo(f_byp_fmt_ex2_c_expo[1:13]),		
      .f_byp_fmt_ex2_b_expo(f_byp_fmt_ex2_b_expo[1:13]),		
      
      .f_byp_fmt_ex2_a_frac(f_byp_fmt_ex2_a_frac[0:52]),		
      .f_byp_fmt_ex2_c_frac(f_byp_fmt_ex2_c_frac[0:52]),		
      .f_byp_fmt_ex2_b_frac(f_byp_fmt_ex2_b_frac[0:52]),		
      
      .f_dcd_ex1_sp(f_dcd_ex1_sp),		
      .f_dcd_ex1_from_integer_b(f_dcd_ex1_from_integer_b),		
      .f_dcd_ex1_sgncpy_b(f_dcd_ex1_sgncpy_b),		
      .f_dcd_ex1_uc_mid(f_dcd_ex1_uc_mid),		
      .f_dcd_ex1_uc_end(f_dcd_ex1_uc_end),		
      .f_dcd_ex1_uc_special(f_dcd_ex1_uc_special),		
      .f_dcd_ex1_aop_valid(f_dcd_ex1_aop_valid),		
      .f_dcd_ex1_cop_valid(f_dcd_ex1_cop_valid),		
      .f_dcd_ex1_bop_valid(f_dcd_ex1_bop_valid),		
      .f_dcd_ex1_fsel_b(f_dcd_ex1_fsel_b),		
      .f_dcd_ex1_force_pass_b(f_dcd_ex1_force_pass_b),		
      .f_dcd_ex2_divsqrt_v(f_dcd_ex2_divsqrt_v),		
      .f_pic_ex2_flush_en_sp(f_pic_ex2_flush_en_sp),		
      .f_pic_ex2_flush_en_dp(f_pic_ex2_flush_en_dp),		
      .f_pic_ex2_nj_deni(f_pic_ex2_nj_deni),		
      .f_fmt_ex3_lu_den_recip(f_fmt_ex3_lu_den_recip),		
      .f_fmt_ex3_lu_den_rsqrto(f_fmt_ex3_lu_den_rsqrto),		
      .f_fmt_ex2_bop_byt(f_fmt_ex2_bop_byt[45:52]),		
      .f_fmt_ex2_b_frac(f_fmt_ex2_b_frac[1:19]),		
      
      .f_fmt_ex2_a_sign_div(f_fmt_ex2_a_sign_div),		
      .f_fmt_ex2_a_expo_div_b(f_fmt_ex2_a_expo_div_b),		
      .f_fmt_ex2_a_frac_div(f_fmt_ex2_a_frac_div),		
      
      .f_fmt_ex2_b_sign_div(f_fmt_ex2_b_sign_div),		
      .f_fmt_ex2_b_expo_div_b(f_fmt_ex2_b_expo_div_b),		
      .f_fmt_ex2_b_frac_div(f_fmt_ex2_b_frac_div),		
      
      .f_fmt_ex2_bexpu_le126(f_fmt_ex2_bexpu_le126),		
      .f_fmt_ex2_gt126(f_fmt_ex2_gt126),		
      .f_fmt_ex2_ge128(f_fmt_ex2_ge128),		
      .f_fmt_ex2_inf_and_beyond_sp(f_fmt_ex2_inf_and_beyond_sp),		
      
      .f_fmt_ex2_b_sign_gst(f_fmt_ex2_b_sign_gst),		
      .f_fmt_ex2_b_expo_gst_b(f_fmt_ex2_b_expo_gst_b[1:13]),		
      .f_mad_ex3_uc_a_expo_den(f_mad_ex3_uc_a_expo_den),		
      .f_mad_ex3_uc_a_expo_den_sp(f_mad_ex3_uc_a_expo_den_sp),		
      .f_fmt_ex2_a_zero(f_fmt_ex2_a_zero),		
      .f_fmt_ex2_a_zero_dsq(f_fmt_ex2_a_zero_dsq),		
      .f_fmt_ex2_a_expo_max(f_fmt_ex2_a_expo_max),		
      .f_fmt_ex2_a_expo_max_dsq(f_fmt_ex2_a_expo_max_dsq),		
      .f_fmt_ex2_a_frac_zero(f_fmt_ex2_a_frac_zero),		
      .f_fmt_ex2_a_frac_msb(f_fmt_ex2_a_frac_msb),		
      .f_fmt_ex2_c_zero(f_fmt_ex2_c_zero),		
      .f_fmt_ex2_c_expo_max(f_fmt_ex2_c_expo_max),		
      .f_fmt_ex2_c_frac_zero(f_fmt_ex2_c_frac_zero),		
      .f_fmt_ex2_c_frac_msb(f_fmt_ex2_c_frac_msb),		
      .f_fmt_ex2_b_zero(f_fmt_ex2_b_zero),		
      .f_fmt_ex2_b_zero_dsq(f_fmt_ex2_b_zero_dsq),		
      .f_fmt_ex2_b_expo_max(f_fmt_ex2_b_expo_max),		
      .f_fmt_ex2_b_expo_max_dsq(f_fmt_ex2_b_expo_max_dsq),		
      .f_fmt_ex2_b_frac_zero(f_fmt_ex2_b_frac_zero),		
      .f_fmt_ex2_b_frac_msb(f_fmt_ex2_b_frac_msb),		
      .f_fmt_ex2_b_frac_z32(f_fmt_ex2_b_frac_z32),		
      .f_fmt_ex2_prod_zero(f_fmt_ex2_prod_zero),		
      .f_fmt_ex2_pass_sel(f_fmt_ex2_pass_sel),		
      .f_fmt_ex2_sp_invalid(f_fmt_ex2_sp_invalid),		
      .f_ex3_b_den_flush(f_ex3_b_den_flush),		
      .f_fmt_ex3_fsel_bsel(f_fmt_ex3_fsel_bsel),		
      .f_fmt_ex3_pass_sign(f_fmt_ex3_pass_sign),		
      .f_fmt_ex3_pass_msb(f_fmt_ex3_pass_msb),		
      .f_fmt_ex2_b_imp(f_fmt_ex2_b_imp),		
      .f_fmt_ex3_pass_frac(f_fmt_ex3_pass_frac[0:52])		
   );
   
   fu_eie  feie(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[2:3]),		
      .mpw1_b(mpw1_b[2:3]),		
      .mpw2_b(mpw2_b[0:0]),		
      .thold_1(perv_eie_thold_1),		
      .sg_1(perv_eie_sg_1),		
      .fpu_enable(perv_eie_fpu_enable),		
      
      .f_eie_si(scan_in[2]),		
      .f_eie_so(scan_out[2]),		
      .ex2_act(f_pic_eie_ex2_act),		
      .f_byp_eie_ex2_a_expo(f_byp_eie_ex2_a_expo[1:13]),		
      .f_byp_eie_ex2_c_expo(f_byp_eie_ex2_c_expo[1:13]),		
      .f_byp_eie_ex2_b_expo(f_byp_eie_ex2_b_expo[1:13]),		
      .f_pic_ex2_from_integer(f_pic_ex2_from_integer),		
      .f_pic_ex2_fsel(f_pic_ex2_fsel),		
      .f_pic_ex3_frsp_ue1(f_pic_ex3_frsp_ue1),		
      .f_alg_ex3_sel_byp(f_alg_ex3_sel_byp),		
      .f_fmt_ex3_fsel_bsel(f_fmt_ex3_fsel_bsel),		
      .f_pic_ex3_force_sel_bexp(f_pic_ex3_force_sel_bexp),		
      .f_pic_ex3_sp_b(f_pic_ex3_sp_b),		
      .f_pic_ex3_math_bzer_b(f_pic_ex3_math_bzer_b),		
      .f_eie_ex3_lt_bias(f_eie_ex3_lt_bias),		
      .f_eie_ex3_eq_bias_m1(f_eie_ex3_eq_bias_m1),		
      .f_eie_ex3_wd_ov(f_eie_ex3_wd_ov),		
      .f_eie_ex3_dw_ov(f_eie_ex3_dw_ov),		
      .f_eie_ex3_wd_ov_if(f_eie_ex3_wd_ov_if),		
      .f_eie_ex3_dw_ov_if(f_eie_ex3_dw_ov_if),		
      .f_eie_ex3_lzo_expo(f_eie_ex3_lzo_expo[1:13]),		
      .f_eie_ex3_b_expo(f_eie_ex3_b_expo[1:13]),		
      .f_eie_ex3_use_bexp(f_eie_ex3_use_bexp),		
      .f_eie_ex3_tbl_expo(f_eie_ex3_tbl_expo[1:13]),		
      .f_eie_ex4_iexp(f_eie_ex4_iexp[1:13])		
   );
   
   fu_eov  feov(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[4:5]),		
      .mpw1_b(mpw1_b[4:5]),		
      .mpw2_b(mpw2_b[0:1]),		
      .thold_1(perv_eov_thold_1),		
      .sg_1(perv_eov_sg_1),		
      .fpu_enable(perv_eov_fpu_enable),		
      
      .f_eov_si(scan_in[3]),		
      .f_eov_so(scan_out[3]),		
      .ex3_act_b(f_pic_eov_ex3_act_b),		
      .f_tbl_ex5_unf_expo(f_tbl_ex5_unf_expo),		
      .f_tbe_ex4_may_ov(f_tbe_ex4_may_ov),		
      .f_tbe_ex4_expo(f_tbe_ex4_res_expo[1:13]),		
      .f_pic_ex4_sel_est(f_pic_ex4_sel_est),		
      .f_eie_ex4_iexp(f_eie_ex4_iexp[1:13]),		
      .f_pic_ex4_sp_b(f_pic_ex4_sp_b),		
      .f_lza_ex5_sh_rgt_en_eov(f_lza_ex5_sh_rgt_en_eov),		
      .f_pic_ex5_oe(f_pic_ex5_oe),		
      .f_pic_ex5_ue(f_pic_ex5_ue),		
      .f_pic_ex5_ov_en(f_pic_ex5_ov_en),		
      .f_pic_ex5_uf_en(f_pic_ex5_uf_en),		
      .f_pic_ex5_spec_sel_k_e(f_pic_ex5_spec_sel_k_e),		
      .f_pic_ex5_spec_sel_k_f(f_pic_ex5_spec_sel_k_f),		
      .f_pic_ex5_sel_ov_spec(tidn),		
      
      .f_pic_ex5_to_int_ov_all(f_pic_ex5_to_int_ov_all),		
      
      .f_lza_ex5_no_lza_edge(f_lza_ex5_no_lza_edge),		
      .f_lza_ex5_lza_amt_eov(f_lza_ex5_lza_amt_eov[0:7]),		
      .f_nrm_ex5_extra_shift(f_nrm_ex5_extra_shift),		
      .f_eov_ex5_may_ovf(f_eov_ex5_may_ovf),		
      .f_eov_ex6_sel_k_f(f_eov_ex6_sel_k_f),		
      .f_eov_ex6_sel_k_e(f_eov_ex6_sel_k_e),		
      .f_eov_ex6_sel_kif_f(f_eov_ex6_sel_kif_f),		
      .f_eov_ex6_sel_kif_e(f_eov_ex6_sel_kif_e),		
      .f_eov_ex6_unf_expo(f_eov_ex6_unf_expo),		
      .f_eov_ex6_ovf_expo(f_eov_ex6_ovf_expo),		
      .f_eov_ex6_ovf_if_expo(f_eov_ex6_ovf_if_expo),		
      .f_eov_ex6_expo_p0(f_eov_ex6_expo_p0[1:13]),		
      .f_eov_ex6_expo_p1(f_eov_ex6_expo_p1[1:13]),		
      .f_eov_ex6_expo_p0_ue1oe1(f_eov_ex6_expo_p0_ue1oe1[3:7]),		
      .f_eov_ex6_expo_p1_ue1oe1(f_eov_ex6_expo_p1_ue1oe1[3:7])		
   );
   

   
   tri_fu_mul  fmul(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[2]),		
      .mpw1_b(mpw1_b[2]),		
      .mpw2_b(mpw2_b[0]),		
      .thold_1(perv_mul_thold_1),		
      .sg_1(perv_mul_sg_1),		
      .fpu_enable(perv_mul_fpu_enable),		
      
      .f_mul_si(scan_in[4]),		
      .f_mul_so(scan_out[4]),		
      .ex2_act(f_pic_mul_ex2_act),		
      .f_fmt_ex2_a_frac(f_byp_mul_ex2_a_frac[0:52]),		
      .f_fmt_ex2_a_frac_17(f_byp_mul_ex2_a_frac_17),		
      .f_fmt_ex2_a_frac_35(f_byp_mul_ex2_a_frac_35),		
      .f_fmt_ex2_c_frac(f_byp_mul_ex2_c_frac[0:53]),		
      .f_mul_ex3_sum(f_mul_ex3_sum[1:108]),		
      .f_mul_ex3_car(f_mul_ex3_car[1:108])		
   );
   
   fu_alg  falg(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[1:3]),		
      .mpw1_b(mpw1_b[1:3]),		
      .mpw2_b(mpw2_b[0:0]),		
      .thold_1(perv_alg_thold_1),		
      .sg_1(perv_alg_sg_1),		
      .fpu_enable(perv_alg_fpu_enable),		
      
      .f_alg_si(scan_in[5]),		
      .f_alg_so(scan_out[5]),		
      .ex1_act(f_dcd_ex1_act),		
      .ex2_act(f_pic_alg_ex2_act),		
      .f_dcd_ex1_sp(f_dcd_ex1_sp),		
      
      .f_pic_ex2_frsp_ue1(f_pic_ex2_frsp_ue1),		
      
      .f_byp_alg_ex2_b_frac(f_byp_alg_ex2_b_frac[0:52]),		
      .f_byp_alg_ex2_b_sign(f_byp_alg_ex2_b_sign),		
      .f_byp_alg_ex2_b_expo(f_byp_alg_ex2_b_expo[1:13]),		
      .f_byp_alg_ex2_a_expo(f_byp_alg_ex2_a_expo[1:13]),		
      .f_byp_alg_ex2_c_expo(f_byp_alg_ex2_c_expo[1:13]),		
      
      .f_fmt_ex2_prod_zero(f_fmt_ex2_prod_zero),		
      .f_fmt_ex2_b_zero(f_fmt_ex2_b_zero),		
      .f_fmt_ex2_pass_sel(f_fmt_ex2_pass_sel),		
      .f_fmt_ex3_pass_frac(f_fmt_ex3_pass_frac[0:52]),		
      .f_dcd_ex1_word_b(f_dcd_ex1_word_b),		
      .f_dcd_ex1_uns_b(f_dcd_ex1_uns_b),		
      .f_dcd_ex1_from_integer_b(f_dcd_ex1_from_integer_b),		
      .f_dcd_ex1_to_integer_b(f_dcd_ex1_to_integer_b),		
      .f_pic_ex2_rnd_to_int(f_pic_ex2_rnd_to_int),		
      .f_pic_ex2_effsub_raw(f_pic_ex2_effsub_raw),		
      .f_pic_ex2_sh_unf_ig_b(f_pic_ex2_sh_unf_ig_b),		
      .f_pic_ex2_sh_unf_do(f_pic_ex2_sh_unf_do),		
      .f_pic_ex2_sh_ovf_ig_b(f_pic_ex2_sh_ovf_ig_b),		
      .f_pic_ex2_sh_ovf_do(f_pic_ex2_sh_ovf_do),		
      .f_pic_ex3_rnd_nr(f_pic_ex3_rnd_nr),		
      .f_pic_ex3_rnd_inf_ok(f_pic_ex3_rnd_inf_ok),		
      .f_alg_ex2_sign_frmw(f_alg_ex2_sign_frmw),		
      .f_alg_ex3_res(f_alg_ex3_res[0:162]),		
      .f_alg_ex3_sel_byp(f_alg_ex3_sel_byp),		
      .f_alg_ex3_effsub_eac_b(f_alg_ex3_effsub_eac_b),		
      .f_alg_ex3_prod_z(f_alg_ex3_prod_z),		
      .f_alg_ex3_sh_unf(f_alg_ex3_sh_unf),		
      .f_alg_ex3_sh_ovf(f_alg_ex3_sh_ovf),		
      .f_alg_ex3_byp_nonflip(f_alg_ex3_byp_nonflip),		
      .f_alg_ex4_frc_sel_p1(f_alg_ex4_frc_sel_p1),		
      .f_alg_ex4_sticky(f_alg_ex4_sticky),		
      .f_alg_ex4_int_fr(f_alg_ex4_int_fr),		
      .f_alg_ex4_int_fi(f_alg_ex4_int_fi)		
   );
   
   fu_sa3  fsa3(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[2:3]),		
      .mpw1_b(mpw1_b[2:3]),		
      .mpw2_b(mpw2_b[0:0]),		
      .thold_1(perv_sa3_thold_1),		
      .sg_1(perv_sa3_sg_1),		
      .fpu_enable(perv_sa3_fpu_enable),		
      
      .f_sa3_si(scan_in[6]),		
      .f_sa3_so(scan_out[6]),		
      .ex2_act_b(f_pic_add_ex2_act_b),		
      .f_mul_ex3_sum(f_mul_ex3_sum[1:108]),		
      .f_mul_ex3_car(f_mul_ex3_car[1:108]),		
      .f_alg_ex3_res(f_alg_ex3_res[0:162]),		
      .f_sa3_ex4_s_lza(f_sa3_ex4_s_lza[0:162]),		
      .f_sa3_ex4_c_lza(f_sa3_ex4_c_lza[53:161]),		
      .f_sa3_ex4_s_add(f_sa3_ex4_s_add[0:162]),		
      .f_sa3_ex4_c_add(f_sa3_ex4_c_add[53:161])		
   );
   
   fu_add  fadd(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[3:4]),		
      .mpw1_b(mpw1_b[3:4]),		
      .mpw2_b(mpw2_b[0:0]),		
      .thold_1(perv_add_thold_1),		
      .sg_1(perv_add_sg_1),		
      .fpu_enable(perv_add_fpu_enable),		
      
      .f_add_si(scan_in[7]),		
      .f_add_so(scan_out[7]),		
      .ex2_act_b(f_pic_add_ex2_act_b),		
      .f_sa3_ex4_s(f_sa3_ex4_s_add[0:162]),		
      .f_sa3_ex4_c(f_sa3_ex4_c_add[53:161]),		
      .f_alg_ex4_frc_sel_p1(f_alg_ex4_frc_sel_p1),		
      .f_alg_ex4_sticky(f_alg_ex4_sticky),		
      .f_alg_ex3_effsub_eac_b(f_alg_ex3_effsub_eac_b),		
      .f_alg_ex3_prod_z(f_alg_ex3_prod_z),		
      .f_pic_ex4_is_gt(f_pic_ex4_is_gt),		
      .f_pic_ex4_is_lt(f_pic_ex4_is_lt),		
      .f_pic_ex4_is_eq(f_pic_ex4_is_eq),		
      .f_pic_ex4_is_nan(f_pic_ex4_is_nan),		
      .f_pic_ex4_cmp_sgnpos(f_pic_ex4_cmp_sgnpos),		
      .f_pic_ex4_cmp_sgnneg(f_pic_ex4_cmp_sgnneg),		
      .f_add_ex5_res(f_add_ex5_res[0:162]),		
      .f_add_ex5_flag_nan(f_add_ex5_flag_nan),		
      .f_add_ex5_flag_gt(f_add_ex5_flag_gt),		
      .f_add_ex5_flag_lt(f_add_ex5_flag_lt),		
      .f_add_ex5_flag_eq(f_add_ex5_flag_eq),		
      .f_add_ex5_fpcc_iu(f_add_ex5_fpcc_iu[0:3]),		
      .f_add_ex5_sign_carry(f_add_ex5_sign_carry),		
      .f_add_ex5_to_int_ovf_wd(f_add_ex5_to_int_ovf_wd[0:1]),		
      .f_add_ex5_to_int_ovf_dw(f_add_ex5_to_int_ovf_dw[0:1]),		
      .f_add_ex5_sticky(f_add_ex5_sticky)		
   );
   
   fu_lze  flze(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[2:3]),		
      .mpw1_b(mpw1_b[2:3]),		
      .mpw2_b(mpw2_b[0:0]),		
      .thold_1(perv_lza_thold_1),		
      .sg_1(perv_lza_sg_1),		
      .fpu_enable(perv_lza_fpu_enable),		
      
      .f_lze_si(scan_in[8]),		
      .f_lze_so(scan_out[8]),		
      .ex2_act_b(f_pic_lza_ex2_act_b),		
      .f_eie_ex3_lzo_expo(f_eie_ex3_lzo_expo[1:13]),		
      .f_eie_ex3_b_expo(f_eie_ex3_b_expo[1:13]),		
      .f_pic_ex3_est_recip(f_pic_ex3_est_recip),		
      .f_pic_ex3_est_rsqrt(f_pic_ex3_est_rsqrt),		
      .f_alg_ex3_byp_nonflip(f_alg_ex3_byp_nonflip),		
      .f_eie_ex3_use_bexp(f_eie_ex3_use_bexp),		
      .f_pic_ex3_b_valid(f_pic_ex3_b_valid),		
      .f_pic_ex3_lzo_dis_prod(f_pic_ex3_lzo_dis_prod),		
      .f_pic_ex3_sp_lzo(f_pic_ex3_sp_lzo),		
      .f_pic_ex3_frsp_ue1(f_pic_ex3_frsp_ue1),		
      .f_fmt_ex3_pass_msb_dp(f_fmt_ex3_pass_frac[0]),		
      .f_alg_ex3_sel_byp(f_alg_ex3_sel_byp),		
      .f_pic_ex3_to_integer(f_pic_ex3_to_integer),		
      .f_pic_ex3_prenorm(f_pic_ex3_prenorm),		
      
      .f_lze_ex3_lzo_din(f_lze_ex3_lzo_din[0:162]),		
      .f_lze_ex4_sh_rgt_amt(f_lze_ex4_sh_rgt_amt[0:7]),		
      .f_lze_ex4_sh_rgt_en(f_lze_ex4_sh_rgt_en)		
   );
   
   
   fu_lza  flza(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[3:4]),		
      .mpw1_b(mpw1_b[3:4]),		
      .mpw2_b(mpw2_b[0:0]),		
      .thold_1(perv_lza_thold_1),		
      .sg_1(perv_lza_sg_1),		
      .fpu_enable(perv_lza_fpu_enable),		
      
      .f_lza_si(scan_in[9]),		
      .f_lza_so(scan_out[9]),		
      .ex2_act_b(f_pic_lza_ex2_act_b),		
      .f_sa3_ex4_s(f_sa3_ex4_s_lza[0:162]),		
      .f_sa3_ex4_c(f_sa3_ex4_c_lza[53:161]),		
      .f_alg_ex3_effsub_eac_b(f_alg_ex3_effsub_eac_b),		
      
      .f_lze_ex3_lzo_din(f_lze_ex3_lzo_din[0:162]),		
      .f_lze_ex4_sh_rgt_amt(f_lze_ex4_sh_rgt_amt[0:7]),		
      .f_lze_ex4_sh_rgt_en(f_lze_ex4_sh_rgt_en),		
      
      .f_lza_ex5_no_lza_edge(f_lza_ex5_no_lza_edge),		
      .f_lza_ex5_lza_amt(f_lza_ex5_lza_amt[0:7]),		
      .f_lza_ex5_sh_rgt_en(f_lza_ex5_sh_rgt_en),		
      .f_lza_ex5_sh_rgt_en_eov(f_lza_ex5_sh_rgt_en_eov),		
      .f_lza_ex5_lza_dcd64_cp1(f_lza_ex5_lza_dcd64_cp1[0:2]),		
      .f_lza_ex5_lza_dcd64_cp2(f_lza_ex5_lza_dcd64_cp2[0:1]),		
      .f_lza_ex5_lza_dcd64_cp3(f_lza_ex5_lza_dcd64_cp3[0]),		
      
      .f_lza_ex5_lza_amt_eov(f_lza_ex5_lza_amt_eov[0:7])		
   );
   
   fu_nrm  fnrm(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[4:5]),		
      .mpw1_b(mpw1_b[4:5]),		
      .mpw2_b(mpw2_b[0:1]),		
      .thold_1(perv_nrm_thold_1),		
      .sg_1(perv_nrm_sg_1),		
      .fpu_enable(perv_nrm_fpu_enable),		
      
      .f_nrm_si(scan_in[10]),		
      .f_nrm_so(scan_out[10]),		
      .ex4_act_b(f_pic_nrm_ex4_act_b),		
      
      .f_lza_ex5_sh_rgt_en(f_lza_ex5_sh_rgt_en),		
      .f_lza_ex5_lza_amt_cp1(f_lza_ex5_lza_amt[0:7]),		
      .f_lza_ex5_lza_dcd64_cp1(f_lza_ex5_lza_dcd64_cp1[0:2]),		
      .f_lza_ex5_lza_dcd64_cp2(f_lza_ex5_lza_dcd64_cp2[0:1]),		
      .f_lza_ex5_lza_dcd64_cp3(f_lza_ex5_lza_dcd64_cp3[0]),		
      
      .f_add_ex5_res(f_add_ex5_res[0:162]),		
      .f_add_ex5_sticky(f_add_ex5_sticky),		
      .f_pic_ex5_byp_prod_nz(f_pic_ex5_byp_prod_nz),		
      .f_nrm_ex6_res(f_nrm_ex6_res[0:52]),		
      .f_nrm_ex6_int_lsbs(f_nrm_ex6_int_lsbs[1:12]),		
      .f_nrm_ex6_int_sign(f_nrm_ex6_int_sign),		
      .f_nrm_ex6_nrm_sticky_dp(f_nrm_ex6_nrm_sticky_dp),		
      .f_nrm_ex6_nrm_guard_dp(f_nrm_ex6_nrm_guard_dp),		
      .f_nrm_ex6_nrm_lsb_dp(f_nrm_ex6_nrm_lsb_dp),		
      .f_nrm_ex6_nrm_sticky_sp(f_nrm_ex6_nrm_sticky_sp),		
      .f_nrm_ex6_nrm_guard_sp(f_nrm_ex6_nrm_guard_sp),		
      .f_nrm_ex6_nrm_lsb_sp(f_nrm_ex6_nrm_lsb_sp),		
      .f_nrm_ex6_exact_zero(f_nrm_ex6_exact_zero),		
      .f_nrm_ex5_extra_shift(f_nrm_ex5_extra_shift),		
      .f_nrm_ex6_fpscr_wr_dat_dfp(f_nrm_ex6_fpscr_wr_dat_dfp[0:3]),		
      .f_nrm_ex6_fpscr_wr_dat(f_nrm_ex6_fpscr_wr_dat[0:31])		
   );
   
   fu_rnd  frnd(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[5:6]),		
      .mpw1_b(mpw1_b[5:6]),		
      .mpw2_b(mpw2_b[1:1]),		
      .thold_1(perv_rnd_thold_1),		
      .sg_1(perv_rnd_sg_1),		
      .fpu_enable(perv_rnd_fpu_enable),		
      
      .f_rnd_si(scan_in[11]),		
      .f_rnd_so(scan_out[11]),		
      .ex4_act_b(f_pic_rnd_ex4_act_b),		
      .f_pic_ex5_sel_est_b(f_pic_ex5_sel_est_b),		
      .f_tbl_ex6_est_frac(f_tbl_ex6_est_frac[0:26]),		
      .f_nrm_ex6_res(f_nrm_ex6_res[0:52]),		
      .f_nrm_ex6_int_lsbs(f_nrm_ex6_int_lsbs[1:12]),		
      .f_nrm_ex6_int_sign(f_nrm_ex6_int_sign),		
      .f_nrm_ex6_nrm_sticky_dp(f_nrm_ex6_nrm_sticky_dp),		
      .f_nrm_ex6_nrm_guard_dp(f_nrm_ex6_nrm_guard_dp),		
      .f_nrm_ex6_nrm_lsb_dp(f_nrm_ex6_nrm_lsb_dp),		
      .f_nrm_ex6_nrm_sticky_sp(f_nrm_ex6_nrm_sticky_sp),		
      .f_nrm_ex6_nrm_guard_sp(f_nrm_ex6_nrm_guard_sp),		
      .f_nrm_ex6_nrm_lsb_sp(f_nrm_ex6_nrm_lsb_sp),		
      .f_nrm_ex6_exact_zero(f_nrm_ex6_exact_zero),		
      .f_pic_ex6_invert_sign(f_pic_ex6_invert_sign),		
      .f_pic_ex6_en_exact_zero(f_pic_ex6_en_exact_zero),		
      .f_pic_ex6_k_nan(f_pic_ex6_k_nan),		
      .f_pic_ex6_k_inf(f_pic_ex6_k_inf),		
      .f_pic_ex6_k_max(f_pic_ex6_k_max),		
      .f_pic_ex6_k_zer(f_pic_ex6_k_zer),		
      .f_pic_ex6_k_one(f_pic_ex6_k_one),		
      .f_pic_ex6_k_int_maxpos(f_pic_ex6_k_int_maxpos),		
      .f_pic_ex6_k_int_maxneg(f_pic_ex6_k_int_maxneg),		
      .f_pic_ex6_k_int_zer(f_pic_ex6_k_int_zer),		
      .f_tbl_ex6_recip_den(f_tbl_ex6_recip_den),		
      .f_pic_ex5_rnd_ni_b(f_pic_ex5_rnd_ni_b),		
      .f_pic_ex5_rnd_nr_b(f_pic_ex5_rnd_nr_b),		
      .f_pic_ex5_rnd_inf_ok_b(f_pic_ex5_rnd_inf_ok_b),		
      .f_pic_ex6_uc_inc_lsb(f_pic_ex6_uc_inc_lsb),		
      .f_pic_ex6_uc_guard(f_pic_ex6_uc_guard),		
      .f_pic_ex6_uc_sticky(f_pic_ex6_uc_sticky),		
      .f_pic_ex6_uc_g_v(f_pic_ex6_uc_g_v),		
      .f_pic_ex6_uc_s_v(f_pic_ex6_uc_s_v),		
      .f_pic_ex5_sel_fpscr_b(f_pic_ex5_sel_fpscr_b),		
      .f_pic_ex5_to_integer_b(f_pic_ex5_to_integer_b),		
      .f_pic_ex5_word_b(f_pic_ex5_word_b),		
      .f_pic_ex5_uns_b(f_pic_ex5_uns_b),		
      .f_pic_ex5_sp_b(f_pic_ex5_sp_b),		
      .f_pic_ex5_spec_inf_b(f_pic_ex5_spec_inf_b),		
      .f_pic_ex5_quiet_b(f_pic_ex5_quiet_b),		
      .f_pic_ex5_nj_deno(f_pic_ex5_nj_deno),		
      .f_pic_ex5_unf_en_ue0_b(f_pic_ex5_unf_en_ue0_b),		
      .f_pic_ex5_unf_en_ue1_b(f_pic_ex5_unf_en_ue1_b),		
      .f_pic_ex5_ovf_en_oe0_b(f_pic_ex5_ovf_en_oe0_b),		
      .f_pic_ex5_ovf_en_oe1_b(f_pic_ex5_ovf_en_oe1_b),		
      .f_pic_ex6_round_sign(f_pic_ex6_round_sign),		
      .f_scr_ex6_fpscr_rd_dat_dfp(f_scr_ex6_fpscr_rd_dat_dfp[0:3]),		
      .f_scr_ex6_fpscr_rd_dat(f_scr_ex6_fpscr_rd_dat[0:31]),		
      .f_eov_ex6_sel_k_f(f_eov_ex6_sel_k_f),		
      .f_eov_ex6_sel_k_e(f_eov_ex6_sel_k_e),		
      .f_eov_ex6_sel_kif_f(f_eov_ex6_sel_kif_f),		
      .f_eov_ex6_sel_kif_e(f_eov_ex6_sel_kif_e),		
      .f_eov_ex6_ovf_expo(f_eov_ex6_ovf_expo),		
      .f_eov_ex6_ovf_if_expo(f_eov_ex6_ovf_if_expo),		
      .f_eov_ex6_unf_expo(f_eov_ex6_unf_expo),		
      .f_pic_ex6_frsp(f_pic_ex6_frsp),		
      .f_eov_ex6_expo_p0(f_eov_ex6_expo_p0[1:13]),		
      .f_eov_ex6_expo_p1(f_eov_ex6_expo_p1[1:13]),		
      .f_eov_ex6_expo_p0_ue1oe1(f_eov_ex6_expo_p0_ue1oe1[3:7]),		
      .f_eov_ex6_expo_p1_ue1oe1(f_eov_ex6_expo_p1_ue1oe1[3:7]),		
      .f_gst_ex6_logexp_v(f_gst_ex6_logexp_v),		
      .f_gst_ex6_logexp_sign(f_gst_ex6_logexp_sign),		
      .f_gst_ex6_logexp_exp(f_gst_ex6_logexp_exp[1:11]),		
      .f_gst_ex6_logexp_fract(f_gst_ex6_logexp_fract[0:19]),		
      .f_dsq_ex6_divsqrt_v(f_dsq_ex6_divsqrt_v_int),		
      
      .f_dsq_ex6_divsqrt_sign(f_dsq_ex6_divsqrt_sign),		
      .f_dsq_ex6_divsqrt_exp(f_dsq_ex6_divsqrt_exp),		
      .f_dsq_ex6_divsqrt_fract(f_dsq_ex6_divsqrt_fract),		
      .f_dsq_ex6_divsqrt_flag_fpscr(f_dsq_ex6_divsqrt_flag_fpscr[0:10]),		
      
      .f_mad_ex7_uc_sign(f_mad_ex7_uc_sign),		
      .f_mad_ex7_uc_zero(f_mad_ex7_uc_zero),		
      .f_rnd_ex7_res_sign(rnd_ex7_res_sign),		
      .f_rnd_ex7_res_expo(rnd_ex7_res_expo[1:13]),		
      .f_rnd_ex7_res_frac(rnd_ex7_res_frac[0:52]),		
      .f_rnd_ex7_flag_up(f_rnd_ex7_flag_up),		
      .f_rnd_ex7_flag_fi(f_rnd_ex7_flag_fi),		
      .f_rnd_ex7_flag_ox(f_rnd_ex7_flag_ox),		
      .f_rnd_ex7_flag_den(f_rnd_ex7_flag_den),		
      .f_rnd_ex7_flag_sgn(f_rnd_ex7_flag_sgn),		
      .f_rnd_ex7_flag_inf(f_rnd_ex7_flag_inf),		
      .f_rnd_ex7_flag_zer(f_rnd_ex7_flag_zer),		
      .f_rnd_ex7_flag_ux(f_rnd_ex7_flag_ux)		
   );
   
   assign f_rnd_ex7_res_sign = rnd_ex7_res_sign;
   assign f_rnd_ex7_res_expo[1:13] = rnd_ex7_res_expo[1:13];
   assign f_rnd_ex7_res_frac[0:52] = rnd_ex7_res_frac[0:52];
   
   fu_gst  fgst(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[2:5]),		
      .mpw1_b(mpw1_b[2:5]),		
      .mpw2_b(mpw2_b[0:1]),		
      .thold_1(perv_rnd_thold_1),		
      .sg_1(perv_rnd_sg_1),		
      .fpu_enable(perv_rnd_fpu_enable),		
      
      .f_gst_si(scan_in[12]),		
      .f_gst_so(scan_out[12]),		
      .ex1_act(f_dcd_ex1_act),		
      .f_fmt_ex2_b_sign_gst(f_fmt_ex2_b_sign_gst),		
      .f_fmt_ex2_b_expo_gst_b(f_fmt_ex2_b_expo_gst_b[1:13]),		
      .f_fmt_ex2_b_frac_gst(f_fmt_ex2_b_frac[1:19]),		
      .f_pic_ex2_floges(f_pic_ex2_log2e),		
      .f_pic_ex2_fexptes(f_pic_ex2_pow2e),		
      .f_gst_ex6_logexp_v(f_gst_ex6_logexp_v),		
      .f_gst_ex6_logexp_sign(f_gst_ex6_logexp_sign),		
      .f_gst_ex6_logexp_exp(f_gst_ex6_logexp_exp[1:11]),		
      .f_gst_ex6_logexp_fract(f_gst_ex6_logexp_fract[0:19])		
   );
   
   fu_divsqrt  fdsq(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[1]),		
      .mpw1_b(mpw1_b[1]),		
      .mpw2_b(mpw2_b[0]),		
      .thold_1(perv_rnd_thold_1),		
      .sg_1(perv_rnd_sg_1),		
      .fpu_enable(perv_rnd_fpu_enable),		
      
      .f_dsq_si(scan_in[13]),		
      .f_dsq_so(scan_out[13]),		
      .ex0_act_b(tidn),		
      
      .f_dcd_ex0_div(f_dcd_ex0_div),		
      .f_dcd_ex0_divs(f_dcd_ex0_divs),		
      .f_dcd_ex0_sqrt(f_dcd_ex0_sqrt),		
      .f_dcd_ex0_sqrts(f_dcd_ex0_sqrts),		
      .f_dcd_ex0_record_v(f_dcd_ex0_record_v),		
      
      .f_dcd_ex2_divsqrt_hole_v(f_dcd_ex2_divsqrt_hole_v),		
      .f_dcd_flush(f_dcd_flush),		
      .f_dcd_ex1_itag(f_dcd_ex1_itag),		
      .f_dcd_ex1_fpscr_addr(f_dcd_ex1_fpscr_addr),		
      .f_dcd_ex1_instr_frt(f_dcd_ex1_instr_frt),		
      .f_dcd_ex1_instr_tid(f_dcd_ex1_instr_tid),		
      
      .f_dcd_ex1_divsqrt_cr_bf(f_dcd_ex1_divsqrt_cr_bf),		
      .f_dcd_axucr0_deno(f_dcd_axucr0_deno),
      .f_fmt_ex2_a_sign_div(f_fmt_ex2_a_sign_div),		
      .f_fmt_ex2_a_expo_div_b(f_fmt_ex2_a_expo_div_b),		
      .f_fmt_ex2_a_frac_div(f_fmt_ex2_a_frac_div),		
      
      .f_fmt_ex2_b_sign_div(f_fmt_ex2_b_sign_div),		
      .f_fmt_ex2_b_expo_div_b(f_fmt_ex2_b_expo_div_b),		
      .f_fmt_ex2_b_frac_div(f_fmt_ex2_b_frac_div),		
      .f_fmt_ex2_a_zero_dsq(f_fmt_ex2_a_zero_dsq),		
      .f_fmt_ex2_a_zero(f_fmt_ex2_a_zero),		
      
      .f_fmt_ex2_a_expo_max(f_fmt_ex2_a_expo_max),		
      .f_fmt_ex2_a_expo_max_dsq(f_fmt_ex2_a_expo_max_dsq),		
      .f_fmt_ex2_a_frac_zero(f_fmt_ex2_a_frac_zero),		
      .f_fmt_ex2_b_zero_dsq(f_fmt_ex2_b_zero_dsq),		
      .f_fmt_ex2_b_zero(f_fmt_ex2_b_zero),		
      
      .f_fmt_ex2_b_expo_max(f_fmt_ex2_b_expo_max),		
      .f_fmt_ex2_b_expo_max_dsq(f_fmt_ex2_b_expo_max_dsq),		
      .f_fmt_ex2_b_frac_zero(f_fmt_ex2_b_frac_zero),		
      .f_dsq_ex3_hangcounter_trigger(f_dsq_ex3_hangcounter_trigger_int),
      .f_dsq_ex5_divsqrt_v(f_dsq_ex5_divsqrt_v_int),		
      .f_dsq_ex6_divsqrt_v(f_dsq_ex6_divsqrt_v_int),		
      .f_dsq_ex6_divsqrt_record_v(f_dsq_ex6_divsqrt_record_v_int),		
      
      .f_dsq_ex6_divsqrt_v_suppress(f_dsq_ex6_divsqrt_v_int_suppress),		
      
      .f_dsq_ex5_divsqrt_itag(f_dsq_ex5_divsqrt_itag_int),		
      .f_dsq_ex6_divsqrt_fpscr_addr(f_dsq_ex6_divsqrt_fpscr_addr_int),		
      .f_dsq_ex6_divsqrt_instr_frt(f_dsq_ex6_divsqrt_instr_frt_int),		
      .f_dsq_ex6_divsqrt_instr_tid(f_dsq_ex6_divsqrt_instr_tid_int),		
      
      .f_dsq_ex6_divsqrt_cr_bf(f_dsq_ex6_divsqrt_cr_bf_int),		
      
      .f_scr_ex6_fpscr_rm_thr0(f_scr_ex6_fpscr_rm_thr0),		
      .f_scr_ex6_fpscr_ee_thr0(f_scr_ex6_fpscr_ee_thr0),		
      .f_scr_ex6_fpscr_rm_thr1(f_scr_ex6_fpscr_rm_thr1),		
      .f_scr_ex6_fpscr_ee_thr1(f_scr_ex6_fpscr_ee_thr1),		
      
      .f_dsq_ex6_divsqrt_sign(f_dsq_ex6_divsqrt_sign),		
      .f_dsq_ex6_divsqrt_exp(f_dsq_ex6_divsqrt_exp),		
      .f_dsq_ex6_divsqrt_fract(f_dsq_ex6_divsqrt_fract),		
      .f_dsq_ex6_divsqrt_flag_fpscr(f_dsq_ex6_divsqrt_flag_fpscr),
      .f_dsq_debug(f_dsq_debug)		
   );
   
   assign f_dsq_ex5_divsqrt_v = f_dsq_ex5_divsqrt_v_int;
   assign f_dsq_ex6_divsqrt_v = f_dsq_ex6_divsqrt_v_int;
   assign f_dsq_ex6_divsqrt_record_v = f_dsq_ex6_divsqrt_record_v_int;
   assign f_dsq_ex6_divsqrt_v_suppress = f_dsq_ex6_divsqrt_v_int_suppress;
   assign f_dsq_ex5_divsqrt_itag = f_dsq_ex5_divsqrt_itag_int;
   assign f_dsq_ex6_divsqrt_fpscr_addr = f_dsq_ex6_divsqrt_fpscr_addr_int;
   assign f_dsq_ex6_divsqrt_instr_frt = f_dsq_ex6_divsqrt_instr_frt_int;
   assign f_dsq_ex6_divsqrt_instr_tid = f_dsq_ex6_divsqrt_instr_tid_int;
   assign f_dsq_ex3_hangcounter_trigger = f_dsq_ex3_hangcounter_trigger_int;
   
   assign f_dsq_ex6_divsqrt_cr_bf = f_dsq_ex6_divsqrt_cr_bf_int;
   
   fu_pic  fpic(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[1:5]),		
      .mpw1_b(mpw1_b[1:5]),		
      .mpw2_b(mpw2_b[0:1]),		
      .thold_1(perv_pic_thold_1),		
      .sg_1(perv_pic_sg_1),		
      .fpu_enable(perv_pic_fpu_enable),		
      
      .f_pic_si(scan_in[14]),		
      .f_pic_so(scan_out[14]),		
      .f_dcd_ex1_act(f_dcd_ex1_act),		
      .f_cr2_ex2_fpscr_shadow_thr0(f_scr_fpscr_ctrl_thr0),		
      .f_cr2_ex2_fpscr_shadow_thr1(f_scr_fpscr_ctrl_thr1),		
      .f_dcd_ex1_pow2e_b(f_dcd_ex1_pow2e_b),		
      .f_dcd_ex1_log2e_b(f_dcd_ex1_log2e_b),		
      .f_byp_pic_ex2_a_sign(f_byp_pic_ex2_a_sign),		
      .f_byp_pic_ex2_c_sign(f_byp_pic_ex2_c_sign),		
      .f_byp_pic_ex2_b_sign(f_byp_pic_ex2_b_sign),		
      .f_dcd_ex1_aop_valid(f_dcd_ex1_aop_valid),		
      .f_dcd_ex1_cop_valid(f_dcd_ex1_cop_valid),		
      .f_dcd_ex1_bop_valid(f_dcd_ex1_bop_valid),		
      .f_dcd_ex1_thread(f_dcd_ex1_thread),		
      
      .f_dcd_ex1_uc_ft_neg(f_dcd_ex1_uc_ft_neg),		
      .f_dcd_ex1_uc_ft_pos(f_dcd_ex1_uc_ft_pos),		
      .f_dcd_ex1_fsel_b(f_dcd_ex1_fsel_b),		
      .f_dcd_ex1_from_integer_b(f_dcd_ex1_from_integer_b),		
      .f_dcd_ex1_to_integer_b(f_dcd_ex1_to_integer_b),		
      .f_dcd_ex1_rnd_to_int_b(f_dcd_ex1_rnd_to_int_b),		
      .f_dcd_ex1_math_b(f_dcd_ex1_math_b),		
      .f_dcd_ex1_est_recip_b(f_dcd_ex1_est_recip_b),		
      .f_dcd_ex1_ftdiv(f_dcd_ex1_ftdiv),		
      .f_dcd_ex1_ftsqrt(f_dcd_ex1_ftsqrt),		
      .f_fmt_ex3_ae_ge_54(f_fmt_ex3_ae_ge_54),		
      .f_fmt_ex3_be_ge_54(f_fmt_ex3_be_ge_54),		
      .f_fmt_ex3_be_ge_2(f_fmt_ex3_be_ge_2),		
      .f_fmt_ex3_be_ge_2044(f_fmt_ex3_be_ge_2044),		
      .f_fmt_ex3_tdiv_rng_chk(f_fmt_ex3_tdiv_rng_chk),		
      
      .f_dcd_ex1_est_rsqrt_b(f_dcd_ex1_est_rsqrt_b),		
      .f_dcd_ex1_move_b(f_dcd_ex1_move_b),		
      .f_dcd_ex1_prenorm_b(f_dcd_ex1_prenorm_b),		
      .f_dcd_ex1_frsp_b(f_dcd_ex1_frsp_b),		
      .f_dcd_ex1_sp(f_dcd_ex1_sp),		
      .f_dcd_ex1_sp_conv_b(f_dcd_ex1_sp_conv_b),		
      .f_dcd_ex1_word_b(f_dcd_ex1_word_b),		
      .f_dcd_ex1_uns_b(f_dcd_ex1_uns_b),		
      .f_dcd_ex1_sub_op_b(f_dcd_ex1_sub_op_b),		
      .f_dcd_ex1_op_rnd_v_b(f_dcd_ex1_op_rnd_v_b),		
      .f_dcd_ex1_op_rnd_b(f_dcd_ex1_op_rnd_b[0:1]),		
      .f_dcd_ex1_inv_sign_b(f_dcd_ex1_inv_sign_b),		
      .f_dcd_ex1_sign_ctl_b(f_dcd_ex1_sign_ctl_b[0:1]),		
      .f_dcd_ex1_sgncpy_b(f_dcd_ex1_sgncpy_b),		
      .f_dcd_ex1_nj_deno(f_dcd_ex1_nj_deno),		
      .f_dcd_ex1_mv_to_scr_b(f_dcd_ex1_mv_to_scr_b),		
      .f_dcd_ex1_mv_from_scr_b(f_dcd_ex1_mv_from_scr_b),		
      .f_dcd_ex1_compare_b(f_dcd_ex1_compare_b),		
      .f_dcd_ex1_ordered_b(f_dcd_ex1_ordered_b),		
      .f_alg_ex2_sign_frmw(f_alg_ex2_sign_frmw),		
      .f_dcd_ex1_force_excp_dis(f_dcd_ex1_force_excp_dis),		
      .f_pic_ex2_log2e(f_pic_ex2_log2e),		
      .f_pic_ex2_pow2e(f_pic_ex2_pow2e),		
      .f_fmt_ex2_bexpu_le126(f_fmt_ex2_bexpu_le126),		
      .f_fmt_ex2_gt126(f_fmt_ex2_gt126),		
      .f_fmt_ex2_ge128(f_fmt_ex2_ge128),		
      .f_fmt_ex2_inf_and_beyond_sp(f_fmt_ex2_inf_and_beyond_sp),		
      .f_fmt_ex2_sp_invalid(f_fmt_ex2_sp_invalid),		
      .f_fmt_ex2_a_zero(f_fmt_ex2_a_zero),		
      .f_fmt_ex2_a_expo_max(f_fmt_ex2_a_expo_max),		
      .f_fmt_ex2_a_frac_zero(f_fmt_ex2_a_frac_zero),		
      .f_fmt_ex2_a_frac_msb(f_fmt_ex2_a_frac_msb),		
      .f_fmt_ex2_c_zero(f_fmt_ex2_c_zero),		
      .f_fmt_ex2_c_expo_max(f_fmt_ex2_c_expo_max),		
      .f_fmt_ex2_c_frac_zero(f_fmt_ex2_c_frac_zero),		
      .f_fmt_ex2_c_frac_msb(f_fmt_ex2_c_frac_msb),		
      .f_fmt_ex2_b_zero(f_fmt_ex2_b_zero),		
      .f_fmt_ex2_b_expo_max(f_fmt_ex2_b_expo_max),		
      .f_fmt_ex2_b_frac_zero(f_fmt_ex2_b_frac_zero),		
      .f_fmt_ex2_b_frac_msb(f_fmt_ex2_b_frac_msb),		
      .f_fmt_ex2_prod_zero(f_fmt_ex2_prod_zero),		
      .f_fmt_ex3_pass_sign(f_fmt_ex3_pass_sign),		
      .f_fmt_ex3_pass_msb(f_fmt_ex3_pass_msb),		
      .f_fmt_ex2_b_frac_z32(f_fmt_ex2_b_frac_z32),		
      .f_fmt_ex2_b_imp(f_fmt_ex2_b_imp),		
      .f_eie_ex3_wd_ov(f_eie_ex3_wd_ov),		
      .f_eie_ex3_dw_ov(f_eie_ex3_dw_ov),		
      .f_eie_ex3_wd_ov_if(f_eie_ex3_wd_ov_if),		
      .f_eie_ex3_dw_ov_if(f_eie_ex3_dw_ov_if),		
      .f_eie_ex3_lt_bias(f_eie_ex3_lt_bias),		
      .f_eie_ex3_eq_bias_m1(f_eie_ex3_eq_bias_m1),		
      .f_alg_ex3_sel_byp(f_alg_ex3_sel_byp),		
      .f_alg_ex3_effsub_eac_b(f_alg_ex3_effsub_eac_b),		
      .f_alg_ex3_sh_unf(f_alg_ex3_sh_unf),		
      .f_alg_ex3_sh_ovf(f_alg_ex3_sh_ovf),		
      .f_alg_ex4_int_fr(f_alg_ex4_int_fr),		
      .f_alg_ex4_int_fi(f_alg_ex4_int_fi),		
      .f_eov_ex5_may_ovf(f_eov_ex5_may_ovf),		
      .f_add_ex5_fpcc_iu({f_add_ex5_flag_lt, f_add_ex5_flag_gt, f_add_ex5_flag_eq, f_add_ex5_flag_nan}),		
      .f_add_ex5_sign_carry(f_add_ex5_sign_carry),		
      .f_dcd_ex1_div_beg(tidn),		
      .f_dcd_ex1_sqrt_beg(tidn),		
      .f_pic_ex6_fpr_wr_dis_b(f_pic_ex6_fpr_wr_dis_b),		
      .f_add_ex5_to_int_ovf_wd(f_add_ex5_to_int_ovf_wd[0:1]),		
      .f_add_ex5_to_int_ovf_dw(f_add_ex5_to_int_ovf_dw[0:1]),		
      .f_pic_ex2_flush_en_sp(f_pic_ex2_flush_en_sp),		
      .f_pic_ex2_flush_en_dp(f_pic_ex2_flush_en_dp),		
      .f_pic_ex2_rnd_to_int(f_pic_ex2_rnd_to_int),		
		 
	       
      .f_fmt_ex3_be_den (f_fmt_ex3_be_den) ,	
      .f_pic_fmt_ex2_act(f_pic_fmt_ex2_act),	
      .f_pic_eie_ex2_act(f_pic_eie_ex2_act),	
      .f_pic_mul_ex2_act(f_pic_mul_ex2_act),	
      .f_pic_alg_ex2_act(f_pic_alg_ex2_act),	
      .f_pic_cr2_ex2_act(f_pic_cr2_ex2_act),	
      .f_pic_tbl_ex2_act(f_pic_tbl_ex2_act),	
      .f_pic_ex2_ftdiv  (f_pic_ex2_ftdiv  ),	
		 
		 
      .f_pic_add_ex2_act_b(f_pic_add_ex2_act_b),		
      .f_pic_lza_ex2_act_b(f_pic_lza_ex2_act_b),		
      .f_pic_eov_ex3_act_b(f_pic_eov_ex3_act_b),		
      .f_pic_nrm_ex4_act_b(f_pic_nrm_ex4_act_b),		
      .f_pic_rnd_ex4_act_b(f_pic_rnd_ex4_act_b),		
      .f_pic_scr_ex3_act_b(f_pic_scr_ex3_act_b),		
      .f_pic_ex2_effsub_raw(f_pic_ex2_effsub_raw),		
      .f_pic_ex4_sel_est(f_pic_ex4_sel_est),		
      .f_pic_ex2_from_integer(f_pic_ex2_from_integer),		
      .f_pic_ex3_ue1(f_pic_ex3_ue1),		
      .f_pic_ex3_frsp_ue1(f_pic_ex3_frsp_ue1),		
      .f_pic_ex2_frsp_ue1(f_pic_ex2_frsp_ue1),		
      .f_pic_ex2_fsel(f_pic_ex2_fsel),		
      .f_pic_ex2_sh_ovf_do(f_pic_ex2_sh_ovf_do),		
      .f_pic_ex2_sh_ovf_ig_b(f_pic_ex2_sh_ovf_ig_b),		
      .f_pic_ex2_sh_unf_do(f_pic_ex2_sh_unf_do),		
      .f_pic_ex2_sh_unf_ig_b(f_pic_ex2_sh_unf_ig_b),		
      .f_pic_ex3_est_recip(f_pic_ex3_est_recip),		
      .f_pic_ex3_est_rsqrt(f_pic_ex3_est_rsqrt),		
      .f_pic_ex3_force_sel_bexp(f_pic_ex3_force_sel_bexp),		
      .f_pic_ex3_lzo_dis_prod(f_pic_ex3_lzo_dis_prod),		
      .f_pic_ex3_sp_b(f_pic_ex3_sp_b),		
      .f_pic_ex3_sp_lzo(f_pic_ex3_sp_lzo),		
      .f_pic_ex3_to_integer(f_pic_ex3_to_integer),		
      .f_pic_ex3_prenorm(f_pic_ex3_prenorm),		
      .f_pic_ex3_b_valid(f_pic_ex3_b_valid),		
      .f_pic_ex3_rnd_nr(f_pic_ex3_rnd_nr),		
      .f_pic_ex3_rnd_inf_ok(f_pic_ex3_rnd_inf_ok),		
      .f_pic_ex3_math_bzer_b(f_pic_ex3_math_bzer_b),		
      .f_pic_ex4_cmp_sgnneg(f_pic_ex4_cmp_sgnneg),		
      .f_pic_ex4_cmp_sgnpos(f_pic_ex4_cmp_sgnpos),		
      .f_pic_ex4_is_eq(f_pic_ex4_is_eq),		
      .f_pic_ex4_is_gt(f_pic_ex4_is_gt),		
      .f_pic_ex4_is_lt(f_pic_ex4_is_lt),		
      .f_pic_ex4_is_nan(f_pic_ex4_is_nan),		
      .f_pic_ex4_sp_b(f_pic_ex4_sp_b),		
      .f_dcd_ex1_uc_mid(f_dcd_ex1_uc_mid),		
      .f_dcd_ex1_uc_end(f_dcd_ex1_uc_end),		
      .f_dcd_ex1_uc_special(f_dcd_ex1_uc_special),		
      .f_mad_ex3_uc_a_expo_den_sp(f_mad_ex3_uc_a_expo_den_sp),		
      .f_mad_ex3_uc_a_expo_den(f_mad_ex3_uc_a_expo_den),		
      .f_dcd_ex3_uc_zx(f_dcd_ex3_uc_zx),		
      .f_dcd_ex3_uc_vxidi(f_dcd_ex3_uc_vxidi),		
      .f_dcd_ex3_uc_vxzdz(f_dcd_ex3_uc_vxzdz),		
      .f_dcd_ex3_uc_vxsqrt(f_dcd_ex3_uc_vxsqrt),		
      .f_dcd_ex3_uc_vxsnan(f_dcd_ex3_uc_vxsnan),		
      .f_mad_ex4_uc_special(f_mad_ex4_uc_special),		
      .f_mad_ex4_uc_zx(f_mad_ex4_uc_zx),		
      .f_mad_ex4_uc_vxidi(f_mad_ex4_uc_vxidi),		
      .f_mad_ex4_uc_vxzdz(f_mad_ex4_uc_vxzdz),		
      .f_mad_ex4_uc_vxsqrt(f_mad_ex4_uc_vxsqrt),		
      .f_mad_ex4_uc_vxsnan(f_mad_ex4_uc_vxsnan),		
      .f_mad_ex4_uc_res_sign(f_mad_ex4_uc_res_sign),		
      .f_mad_ex4_uc_round_mode(f_mad_ex4_uc_round_mode[0:1]),		
      .f_pic_ex5_byp_prod_nz(f_pic_ex5_byp_prod_nz),		
      .f_pic_ex5_sel_est_b(f_pic_ex5_sel_est_b),		
      .f_pic_ex5_nj_deno(f_pic_ex5_nj_deno),		
      .f_pic_ex5_oe(f_pic_ex5_oe),		
      .f_pic_ex5_ov_en(f_pic_ex5_ov_en),		
      .f_pic_ex5_ovf_en_oe0_b(f_pic_ex5_ovf_en_oe0_b),		
      .f_pic_ex5_ovf_en_oe1_b(f_pic_ex5_ovf_en_oe1_b),		
      .f_pic_ex5_quiet_b(f_pic_ex5_quiet_b),		
      .f_pic_ex5_rnd_inf_ok_b(f_pic_ex5_rnd_inf_ok_b),		
      .f_pic_ex5_rnd_ni_b(f_pic_ex5_rnd_ni_b),		
      .f_pic_ex5_rnd_nr_b(f_pic_ex5_rnd_nr_b),		
      .f_pic_ex5_sel_fpscr_b(f_pic_ex5_sel_fpscr_b),		
      .f_pic_ex5_sp_b(f_pic_ex5_sp_b),		
      .f_pic_ex5_spec_inf_b(f_pic_ex5_spec_inf_b),		
      .f_pic_ex5_spec_sel_k_e(f_pic_ex5_spec_sel_k_e),		
      .f_pic_ex5_spec_sel_k_f(f_pic_ex5_spec_sel_k_f),		
      .f_dcd_ex3_uc_inc_lsb(f_dcd_ex3_uc_inc_lsb),		
      .f_dcd_ex3_uc_guard(f_dcd_ex3_uc_gs[0]),		
      .f_dcd_ex3_uc_sticky(f_dcd_ex3_uc_gs[1]),		
      .f_dcd_ex3_uc_gs_v(f_dcd_ex3_uc_gs_v),		
      .f_pic_ex6_uc_inc_lsb(f_pic_ex6_uc_inc_lsb),		
      .f_pic_ex6_uc_guard(f_pic_ex6_uc_guard),		
      .f_pic_ex6_uc_sticky(f_pic_ex6_uc_sticky),		
      .f_pic_ex6_uc_g_v(f_pic_ex6_uc_g_v),		
      .f_pic_ex6_uc_s_v(f_pic_ex6_uc_s_v),		
      .f_pic_ex5_to_int_ov_all(f_pic_ex5_to_int_ov_all),		
      .f_pic_ex5_to_integer_b(f_pic_ex5_to_integer_b),		
      .f_pic_ex5_word_b(f_pic_ex5_word_b),		
      .f_pic_ex5_uns_b(f_pic_ex5_uns_b),		
      .f_pic_ex5_ue(f_pic_ex5_ue),		
      .f_pic_ex5_uf_en(f_pic_ex5_uf_en),		
      .f_pic_ex5_unf_en_ue0_b(f_pic_ex5_unf_en_ue0_b),		
      .f_pic_ex5_unf_en_ue1_b(f_pic_ex5_unf_en_ue1_b),		
      .f_pic_ex6_en_exact_zero(f_pic_ex6_en_exact_zero),		
      .f_pic_ex6_compare_b(f_pic_ex6_compare_b),		
      .f_pic_ex6_frsp(f_pic_ex6_frsp),		
      .f_pic_ex6_fi_pipe_v_b(f_pic_ex6_fi_pipe_v_b),		
      .f_pic_ex6_fi_spec_b(f_pic_ex6_fi_spec_b),		
      .f_pic_ex6_flag_vxcvi_b(f_pic_ex6_flag_vxcvi_b),		
      .f_pic_ex6_flag_vxidi_b(f_pic_ex6_flag_vxidi_b),		
      .f_pic_ex6_flag_vximz_b(f_pic_ex6_flag_vximz_b),		
      .f_pic_ex6_flag_vxisi_b(f_pic_ex6_flag_vxisi_b),		
      .f_pic_ex6_flag_vxsnan_b(f_pic_ex6_flag_vxsnan_b),		
      .f_pic_ex6_flag_vxsqrt_b(f_pic_ex6_flag_vxsqrt_b),		
      .f_pic_ex6_flag_vxvc_b(f_pic_ex6_flag_vxvc_b),		
      .f_pic_ex6_flag_vxzdz_b(f_pic_ex6_flag_vxzdz_b),		
      .f_pic_ex6_flag_zx_b(f_pic_ex6_flag_zx_b),		
      .f_pic_ex6_fprf_hold_b(f_pic_ex6_fprf_hold_b),		
      .f_pic_ex6_fprf_pipe_v_b(f_pic_ex6_fprf_pipe_v_b),		
      .f_pic_ex6_fprf_spec_b(f_pic_ex6_fprf_spec_b[0:4]),		
      .f_pic_ex6_fr_pipe_v_b(f_pic_ex6_fr_pipe_v_b),		
      .f_pic_ex6_fr_spec_b(f_pic_ex6_fr_spec_b),		
      .f_pic_ex6_invert_sign(f_pic_ex6_invert_sign),		
      .f_pic_ex6_k_nan(f_pic_ex6_k_nan),		
      .f_pic_ex6_k_inf(f_pic_ex6_k_inf),		
      .f_pic_ex6_k_max(f_pic_ex6_k_max),		
      .f_pic_ex6_k_zer(f_pic_ex6_k_zer),		
      .f_pic_ex6_k_one(f_pic_ex6_k_one),		
      .f_pic_ex6_k_int_maxpos(f_pic_ex6_k_int_maxpos),		
      .f_pic_ex6_k_int_maxneg(f_pic_ex6_k_int_maxneg),		
      .f_pic_ex6_k_int_zer(f_pic_ex6_k_int_zer),		
      .f_pic_ex6_ox_pipe_v_b(f_pic_ex6_ox_pipe_v_b),		
      .f_pic_ex6_round_sign(f_pic_ex6_round_sign),		
      .f_pic_ex6_scr_upd_move_b(f_pic_ex6_scr_upd_move_b_int),		
      .f_pic_ex6_scr_upd_pipe_b(f_pic_ex6_scr_upd_pipe_b),		
      .f_pic_ex2_nj_deni(f_pic_ex2_nj_deni),		
      .f_dcd_ex1_nj_deni(f_dcd_ex1_nj_deni),		
      .f_pic_ex6_ux_pipe_v_b(f_pic_ex6_ux_pipe_v_b)		
   );
   
   assign f_pic_ex6_scr_upd_move_b = f_pic_ex6_scr_upd_move_b_int;
   
   fu_cr2  fcr2(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[1:7]),		
      .mpw1_b(mpw1_b[1:7]),		
      .mpw2_b(mpw2_b[0:1]),		
      .thold_1(perv_cr2_thold_1),		
      .sg_1(perv_cr2_sg_1),		
      .fpu_enable(perv_cr2_fpu_enable),		
      
      .f_cr2_si(scan_in[15]),		
      .f_cr2_so(scan_out[15]),		
      .ex1_act(f_dcd_ex1_act),		
      .ex2_act(f_pic_cr2_ex2_act),		
      .ex1_thread_b(ex1_thread_b[0:3]),		
      .f_dcd_ex7_cancel(f_dcd_ex7_cancel),		
      .f_fmt_ex2_bop_byt(f_fmt_ex2_bop_byt[45:52]),		
      .f_dcd_ex1_fpscr_bit_data_b(f_dcd_ex1_fpscr_bit_data_b[0:3]),		
      .f_dcd_ex1_fpscr_bit_mask_b(f_dcd_ex1_fpscr_bit_mask_b[0:3]),		
      .f_dcd_ex1_fpscr_nib_mask_b(f_dcd_ex1_fpscr_nib_mask_b[0:8]),		
      .f_dcd_ex1_mtfsbx_b(f_dcd_ex1_mtfsbx_b),		
      .f_dcd_ex1_mcrfs_b(f_dcd_ex1_mcrfs_b),		
      .f_dcd_ex1_mtfsf_b(f_dcd_ex1_mtfsf_b),		
      .f_dcd_ex1_mtfsfi_b(f_dcd_ex1_mtfsfi_b),		
      .f_cr2_ex4_thread_b(f_cr2_ex4_thread_b[0:3]),		
      .f_cr2_ex4_fpscr_bit_data_b(f_cr2_ex4_fpscr_bit_data_b[0:3]),		
      .f_cr2_ex4_fpscr_bit_mask_b(f_cr2_ex4_fpscr_bit_mask_b[0:3]),		
      .f_cr2_ex4_fpscr_nib_mask_b(f_cr2_ex4_fpscr_nib_mask_b[0:8]),		
      .f_cr2_ex4_mtfsbx_b(f_cr2_ex4_mtfsbx_b),		
      .f_cr2_ex4_mcrfs_b(f_cr2_ex4_mcrfs_b),		
      .f_cr2_ex4_mtfsf_b(f_cr2_ex4_mtfsf_b),		
      .f_cr2_ex4_mtfsfi_b(f_cr2_ex4_mtfsfi_b),		
      .f_cr2_ex6_fpscr_rd_dat(f_cr2_ex6_fpscr_rd_dat[24:31]),		
      .f_cr2_ex7_fpscr_rd_dat(f_cr2_ex7_fpscr_rd_dat[24:31])		
   );
   
   assign f_cr2_ex2_fpscr_shadow[0:7] = f_scr_ex6_fpscr_rd_dat[24:31];		
   
   
   fu_oscr #( .THREADS(THREADS)) fscr(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[4:7]),		
      .mpw1_b(mpw1_b[4:7]),		
      .mpw2_b(mpw2_b[0:1]),		
      .thold_1(perv_scr_thold_1),		
      .sg_1(perv_scr_sg_1),		
      .fpu_enable(perv_scr_fpu_enable),		
      
      .f_scr_si(scan_in[16]),		
      .f_scr_so(scan_out[16]),		
      .ex3_act_b(f_pic_scr_ex3_act_b),		
      .f_cr2_ex4_thread_b(f_cr2_ex4_thread_b[0:3]),		
      
      .f_dcd_ex7_cancel(f_dcd_ex7_cancel),		
      
      .f_pic_ex6_scr_upd_move_b(f_pic_ex6_scr_upd_move_b_int),		
      .f_pic_ex6_scr_upd_pipe_b(f_pic_ex6_scr_upd_pipe_b),		
      .f_pic_ex6_fprf_spec_b(f_pic_ex6_fprf_spec_b[0:4]),		
      .f_pic_ex6_compare_b(f_pic_ex6_compare_b),		
      .f_pic_ex6_fprf_pipe_v_b(f_pic_ex6_fprf_pipe_v_b),		
      .f_pic_ex6_fprf_hold_b(f_pic_ex6_fprf_hold_b),		
      .f_pic_ex6_fi_spec_b(f_pic_ex6_fi_spec_b),		
      .f_pic_ex6_fi_pipe_v_b(f_pic_ex6_fi_pipe_v_b),		
      .f_pic_ex6_fr_spec_b(f_pic_ex6_fr_spec_b),		
      .f_pic_ex6_fr_pipe_v_b(f_pic_ex6_fr_pipe_v_b),		
      .f_pic_ex6_ox_spec_b(tiup),		
      .f_pic_ex6_ox_pipe_v_b(f_pic_ex6_ox_pipe_v_b),		
      .f_pic_ex6_ux_spec_b(tiup),		
      .f_pic_ex6_ux_pipe_v_b(f_pic_ex6_ux_pipe_v_b),		
      .f_pic_ex6_flag_vxsnan_b(f_pic_ex6_flag_vxsnan_b),		
      .f_pic_ex6_flag_vxisi_b(f_pic_ex6_flag_vxisi_b),		
      .f_pic_ex6_flag_vxidi_b(f_pic_ex6_flag_vxidi_b),		
      .f_pic_ex6_flag_vxzdz_b(f_pic_ex6_flag_vxzdz_b),		
      .f_pic_ex6_flag_vximz_b(f_pic_ex6_flag_vximz_b),		
      .f_pic_ex6_flag_vxvc_b(f_pic_ex6_flag_vxvc_b),		
      .f_pic_ex6_flag_vxsqrt_b(f_pic_ex6_flag_vxsqrt_b),		
      .f_pic_ex6_flag_vxcvi_b(f_pic_ex6_flag_vxcvi_b),		
      .f_pic_ex6_flag_zx_b(f_pic_ex6_flag_zx_b),		
      .f_nrm_ex6_fpscr_wr_dat_dfp(f_nrm_ex6_fpscr_wr_dat_dfp[0:3]),		
      .f_nrm_ex6_fpscr_wr_dat(f_nrm_ex6_fpscr_wr_dat[0:31]),		
      .f_cr2_ex4_fpscr_bit_data_b(f_cr2_ex4_fpscr_bit_data_b[0:3]),		
      .f_cr2_ex4_fpscr_bit_mask_b(f_cr2_ex4_fpscr_bit_mask_b[0:3]),		
      .f_cr2_ex4_fpscr_nib_mask_b(f_cr2_ex4_fpscr_nib_mask_b[0:8]),		
      .f_cr2_ex4_mtfsbx_b(f_cr2_ex4_mtfsbx_b),		
      .f_cr2_ex4_mcrfs_b(f_cr2_ex4_mcrfs_b),		
      .f_cr2_ex4_mtfsf_b(f_cr2_ex4_mtfsf_b),		
      .f_cr2_ex4_mtfsfi_b(f_cr2_ex4_mtfsfi_b),		
      .f_dsq_ex6_divsqrt_v(f_dsq_ex6_divsqrt_v_int),		
      .f_dsq_ex6_divsqrt_v_suppress(f_dsq_ex6_divsqrt_v_int_suppress),		
      
      .f_dsq_ex6_divsqrt_flag_fpscr_zx(f_dsq_ex6_divsqrt_flag_fpscr[2]),		
      .f_dsq_ex6_divsqrt_flag_fpscr_idi(f_dsq_ex6_divsqrt_flag_fpscr[11]),		
      .f_dsq_ex6_divsqrt_flag_fpscr_zdz(f_dsq_ex6_divsqrt_flag_fpscr[12]),		
      .f_dsq_ex6_divsqrt_flag_fpscr_sqrt(f_dsq_ex6_divsqrt_flag_fpscr[13]),		
      .f_dsq_ex6_divsqrt_flag_fpscr_nan(f_dsq_ex6_divsqrt_flag_fpscr[14]),		
      .f_dsq_ex6_divsqrt_flag_fpscr_snan(f_dsq_ex6_divsqrt_flag_fpscr[15]),		
      
      .f_rnd_ex7_flag_up(f_rnd_ex7_flag_up),		
      .f_rnd_ex7_flag_fi(f_rnd_ex7_flag_fi),		
      .f_rnd_ex7_flag_ox(f_rnd_ex7_flag_ox),		
      .f_rnd_ex7_flag_den(f_rnd_ex7_flag_den),		
      .f_rnd_ex7_flag_sgn(f_rnd_ex7_flag_sgn),		
      .f_rnd_ex7_flag_inf(f_rnd_ex7_flag_inf),		
      .f_rnd_ex7_flag_zer(f_rnd_ex7_flag_zer),		
      .f_rnd_ex7_flag_ux(f_rnd_ex7_flag_ux),		
      .f_cr2_ex7_fpscr_rd_dat(f_cr2_ex7_fpscr_rd_dat[24:31]),		
      .f_cr2_ex6_fpscr_rd_dat(f_cr2_ex6_fpscr_rd_dat[24:31]),		
      .f_dcd_ex7_fpscr_wr(f_dcd_ex7_fpscr_wr),		
      .f_dcd_ex7_fpscr_addr(f_dcd_ex7_fpscr_addr),		
      .cp_axu_i0_t1_v(cp_axu_i0_t1_v),
      .cp_axu_i0_t0_t1_t(cp_axu_i0_t0_t1_t),
      .cp_axu_i0_t1_t1_t(cp_axu_i0_t1_t1_t),								     
      .cp_axu_i0_t0_t1_p(cp_axu_i0_t0_t1_p),
      .cp_axu_i0_t1_t1_p(cp_axu_i0_t1_t1_p),
      .cp_axu_i1_t1_v(cp_axu_i1_t1_v),
      .cp_axu_i1_t0_t1_t(cp_axu_i1_t0_t1_t),
      .cp_axu_i1_t1_t1_t(cp_axu_i1_t1_t1_t),								     
      .cp_axu_i1_t0_t1_p(cp_axu_i1_t0_t1_p),
      .cp_axu_i1_t1_t1_p(cp_axu_i1_t1_t1_p),
								     
      .f_scr_ex6_fpscr_rd_dat(f_scr_ex6_fpscr_rd_dat[0:31]),		
      .f_scr_fpscr_ctrl_thr0(f_scr_fpscr_ctrl_thr0),
      .f_scr_fpscr_ctrl_thr1(f_scr_fpscr_ctrl_thr1),
      .f_scr_ex6_fpscr_rd_dat_dfp(f_scr_ex6_fpscr_rd_dat_dfp[0:3]),		
      .f_scr_ex6_fpscr_rm_thr0(f_scr_ex6_fpscr_rm_thr0),		
      .f_scr_ex6_fpscr_ee_thr0(f_scr_ex6_fpscr_ee_thr0),		
      .f_scr_ex6_fpscr_ni_thr0(f_scr_ex6_fpscr_ni_thr0_int),		
				      				      
      .f_scr_ex6_fpscr_rm_thr1(f_scr_ex6_fpscr_rm_thr1),		
      .f_scr_ex6_fpscr_ee_thr1(f_scr_ex6_fpscr_ee_thr1),		
      .f_scr_ex6_fpscr_ni_thr1(f_scr_ex6_fpscr_ni_thr1_int),		
				        
      .f_scr_ex8_cr_fld(f_scr_ex8_cr_fld[0:3]),		
      .f_scr_ex8_fx_thread0(f_scr_ex8_fx_thread0[0:3]),		
      .f_scr_ex8_fx_thread1(f_scr_ex8_fx_thread1[0:3]),		
      .f_scr_cpl_fx_thread0(f_scr_cpl_fx_thread0[0:3]),		
      .f_scr_cpl_fx_thread1(f_scr_cpl_fx_thread1[0:3])		
   );

   assign f_scr_ex6_fpscr_ni_thr0 = f_scr_ex6_fpscr_ni_thr0_int;
   assign f_scr_ex6_fpscr_ni_thr1 = f_scr_ex6_fpscr_ni_thr1_int;

   
   fu_tblexp  ftbe(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[2:3]),		
      .mpw1_b(mpw1_b[2:3]),		
      .mpw2_b(mpw2_b[0:0]),		
      .thold_1(perv_tbe_thold_1),		
      .sg_1(perv_tbe_sg_1),		
      .fpu_enable(perv_tbe_fpu_enable),		
      
      .si(scan_in[17]),		
      .so(scan_out[17]),		
      .ex2_act_b(f_pic_lza_ex2_act_b),		
      .f_pic_ex3_ue1(f_pic_ex3_ue1),		
      .f_pic_ex3_sp_b(f_pic_ex3_sp_b),		
      .f_pic_ex3_est_recip(f_pic_ex3_est_recip),		
      .f_pic_ex3_est_rsqrt(f_pic_ex3_est_rsqrt),		
      .f_eie_ex3_tbl_expo(f_eie_ex3_tbl_expo[1:13]),		
      .f_fmt_ex3_lu_den_recip(f_fmt_ex3_lu_den_recip),		
      .f_fmt_ex3_lu_den_rsqrto(f_fmt_ex3_lu_den_rsqrto),		
      .f_tbe_ex4_match_en_sp(f_tbe_ex4_match_en_sp),		
      .f_tbe_ex4_match_en_dp(f_tbe_ex4_match_en_dp),		
      .f_tbe_ex4_recip_2046(f_tbe_ex4_recip_2046),		
      .f_tbe_ex4_recip_2045(f_tbe_ex4_recip_2045),		
      .f_tbe_ex4_recip_2044(f_tbe_ex4_recip_2044),		
      .f_tbe_ex4_lu_sh(f_tbe_ex4_lu_sh),		
      .f_tbe_ex4_recip_ue1(f_tbe_ex4_recip_ue1),		
      .f_tbe_ex4_may_ov(f_tbe_ex4_may_ov),		
      .f_tbe_ex4_res_expo(f_tbe_ex4_res_expo[1:13])		
   );
   
   
   fu_tbllut  ftbl(
      .vdd(vdd),		
      .gnd(gnd),		
      .nclk(nclk),		
      .clkoff_b(clkoff_b),		
      .act_dis(act_dis),		
      .flush(flush),		
      .delay_lclkr(delay_lclkr[2:5]),		
      .mpw1_b(mpw1_b[2:5]),		
      .mpw2_b(mpw2_b[0:1]),		
      .thold_1(perv_tbl_thold_1),		
      .sg_1(perv_tbl_sg_1),		
      .fpu_enable(perv_tbl_fpu_enable),		
      
      .si(scan_in[18]),		
      .so(scan_out[18]),		
      .ex2_act(f_pic_tbl_ex2_act),		
      .f_fmt_ex2_b_frac(f_fmt_ex2_b_frac[1:6]),		
      .f_fmt_ex3_b_frac(f_fmt_ex3_pass_frac[7:22]),		
      .f_tbe_ex3_expo_lsb(f_eie_ex3_tbl_expo[13]),		
      .f_tbe_ex3_est_recip(f_pic_ex3_est_recip),		
      .f_tbe_ex3_est_rsqrt(f_pic_ex3_est_rsqrt),		
      .f_tbe_ex4_recip_ue1(f_tbe_ex4_recip_ue1),		
      .f_tbe_ex4_lu_sh(f_tbe_ex4_lu_sh),		
      .f_tbe_ex4_match_en_sp(f_tbe_ex4_match_en_sp),		
      .f_tbe_ex4_match_en_dp(f_tbe_ex4_match_en_dp),		
      .f_tbe_ex4_recip_2046(f_tbe_ex4_recip_2046),		
      .f_tbe_ex4_recip_2045(f_tbe_ex4_recip_2045),		
      .f_tbe_ex4_recip_2044(f_tbe_ex4_recip_2044),		
      .f_tbl_ex6_est_frac(f_tbl_ex6_est_frac[0:26]),		
      .f_tbl_ex5_unf_expo(f_tbl_ex5_unf_expo),		
      .f_tbl_ex6_recip_den(f_tbl_ex6_recip_den)		
   );
   
   
   
   
   assign perv_tbl_sg_1 = sg_1;
   assign perv_tbe_sg_1 = sg_1;
   assign perv_eie_sg_1 = sg_1;
   assign perv_eov_sg_1 = sg_1;
   assign perv_fmt_sg_1 = sg_1;
   assign perv_mul_sg_1 = sg_1;
   assign perv_alg_sg_1 = sg_1;
   assign perv_sa3_sg_1 = sg_1;
   assign perv_add_sg_1 = sg_1;
   assign perv_lza_sg_1 = sg_1;
   assign perv_nrm_sg_1 = sg_1;
   assign perv_rnd_sg_1 = sg_1;
   assign perv_scr_sg_1 = sg_1;
   assign perv_pic_sg_1 = sg_1;
   assign perv_cr2_sg_1 = sg_1;
   
   assign perv_tbl_thold_1 = thold_1;
   assign perv_tbe_thold_1 = thold_1;
   assign perv_eie_thold_1 = thold_1;
   assign perv_eov_thold_1 = thold_1;
   assign perv_fmt_thold_1 = thold_1;
   assign perv_mul_thold_1 = thold_1;
   assign perv_alg_thold_1 = thold_1;
   assign perv_sa3_thold_1 = thold_1;
   assign perv_add_thold_1 = thold_1;
   assign perv_lza_thold_1 = thold_1;
   assign perv_nrm_thold_1 = thold_1;
   assign perv_rnd_thold_1 = thold_1;
   assign perv_scr_thold_1 = thold_1;
   assign perv_pic_thold_1 = thold_1;
   assign perv_cr2_thold_1 = thold_1;
   
   assign perv_tbl_fpu_enable = fpu_enable;
   assign perv_tbe_fpu_enable = fpu_enable;
   assign perv_eie_fpu_enable = fpu_enable;
   assign perv_eov_fpu_enable = fpu_enable;
   assign perv_fmt_fpu_enable = fpu_enable;
   assign perv_mul_fpu_enable = fpu_enable;
   assign perv_alg_fpu_enable = fpu_enable;
   assign perv_sa3_fpu_enable = fpu_enable;
   assign perv_add_fpu_enable = fpu_enable;
   assign perv_lza_fpu_enable = fpu_enable;
   assign perv_nrm_fpu_enable = fpu_enable;
   assign perv_rnd_fpu_enable = fpu_enable;
   assign perv_scr_fpu_enable = fpu_enable;
   assign perv_pic_fpu_enable = fpu_enable;
   assign perv_cr2_fpu_enable = fpu_enable;
   
endmodule
