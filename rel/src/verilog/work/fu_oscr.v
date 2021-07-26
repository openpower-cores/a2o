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

////## some inputs and their latches can be droped (fr/fi always enabled together)
////##                                             (ox/ux always enabled together)
////## spec always sets fr=fi=ox=ux=0
////##############################################################################

// cyc ex5 NORM  :  fpscr_rd
// cyc ex6 RND   :
// cyc ex7 FPSCR :  fpscr_wr
//
//
// FPSCR BIT DEFINITIONS
// ---------------- status 3:12,21:23 resetable
// [ 0] fx    exception transition 0->1  (except mtfs,mtfsi)
// [ 1] fex   "or" of enabled exceptions
// [ 2] vex   "or" of invalid exceptions
// [ 3] ox
// [ 4] ux
// [ 5] zx
// [ 6] xx
// [ 7] vxsnan
// [ 8] vxisi (inf-sub-inf)
// [ 9] vxidi
// [10] vxzdz
// [11] vximz
// [12] vxvc
// [13] fr
// [14] fi
// [15] FPRF C
// [16] FPRF fpcc(lt)
// [17] FPRF fpcc(gt)
// [18] FPRF fpcc(eq)
// [19] FPRF fpcc(nan)
// [20] RESERVED
// [21] vx-soft
// [22] vx-sqrt
// [23] vx-vci
// -------------- control
// [24] ve
// [25] oe
// [26] ue
// [27] ze
// [28] xe
// [29] non-ieee
// [30:31] rnd_mode 00:nr 01:zr 02:pi 03:ni
//---------------
// FPRF
// 10001  QNAN     [0]  qnan | den | (sign*zero)
// 01001 -INF      [1]  sign * !zero
// 01000 -norm     [2] !sign * !zero * !qnan
// 11000 -den      [3]  zero
// 10010 -zero     [4]  inf   | qnan
// 00010 +zero
// 10100 +den
// 00100 +norm
// 00101 +inf

// tvc -F -B -T -O joboutput -c "tri=head" -src fu_divsqrt.vhdl

   `include "tri_a2o.vh"


module fu_oscr(
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
   f_scr_si,
   f_scr_so,
   ex3_act_b,
   f_cr2_ex4_thread_b,
   f_pic_ex6_scr_upd_move_b,
   f_pic_ex6_scr_upd_pipe_b,
   f_dcd_ex7_cancel,
   f_pic_ex6_fprf_spec_b,
   f_pic_ex6_compare_b,
   f_pic_ex6_fprf_pipe_v_b,
   f_pic_ex6_fprf_hold_b,
   f_pic_ex6_fi_spec_b,
   f_pic_ex6_fi_pipe_v_b,
   f_pic_ex6_fr_spec_b,
   f_pic_ex6_fr_pipe_v_b,
   f_pic_ex6_ox_spec_b,
   f_pic_ex6_ox_pipe_v_b,
   f_pic_ex6_ux_spec_b,
   f_pic_ex6_ux_pipe_v_b,
   f_pic_ex6_flag_vxsnan_b,
   f_pic_ex6_flag_vxisi_b,
   f_pic_ex6_flag_vxidi_b,
   f_pic_ex6_flag_vxzdz_b,
   f_pic_ex6_flag_vximz_b,
   f_pic_ex6_flag_vxvc_b,
   f_pic_ex6_flag_vxsqrt_b,
   f_pic_ex6_flag_vxcvi_b,
   f_pic_ex6_flag_zx_b,
   f_cr2_ex4_fpscr_bit_data_b,
   f_cr2_ex4_fpscr_bit_mask_b,
   f_cr2_ex4_fpscr_nib_mask_b,
   f_cr2_ex4_mcrfs_b,
   f_cr2_ex4_mtfsf_b,
   f_cr2_ex4_mtfsfi_b,
   f_cr2_ex4_mtfsbx_b,
   f_nrm_ex6_fpscr_wr_dat_dfp,
   f_scr_ex6_fpscr_rd_dat_dfp,
   f_nrm_ex6_fpscr_wr_dat,
   f_cr2_ex7_fpscr_rd_dat,
   f_cr2_ex6_fpscr_rd_dat,
   f_scr_ex6_fpscr_rd_dat,
   f_scr_fpscr_ctrl_thr0,
   f_scr_fpscr_ctrl_thr1,
   f_scr_ex6_fpscr_rm_thr0,
   f_scr_ex6_fpscr_ee_thr0,
   f_scr_ex6_fpscr_ni_thr0,
   f_scr_ex6_fpscr_rm_thr1,
   f_scr_ex6_fpscr_ee_thr1,
   f_scr_ex6_fpscr_ni_thr1,
   f_dsq_ex6_divsqrt_v,
   f_dsq_ex6_divsqrt_v_suppress,
   f_dsq_ex6_divsqrt_flag_fpscr_zx,
   f_dsq_ex6_divsqrt_flag_fpscr_idi,
   f_dsq_ex6_divsqrt_flag_fpscr_zdz,
   f_dsq_ex6_divsqrt_flag_fpscr_sqrt,
   f_dsq_ex6_divsqrt_flag_fpscr_nan,
   f_dsq_ex6_divsqrt_flag_fpscr_snan,
   f_rnd_ex7_flag_up,
   f_rnd_ex7_flag_fi,
   f_rnd_ex7_flag_ox,
   f_rnd_ex7_flag_den,
   f_rnd_ex7_flag_sgn,
   f_rnd_ex7_flag_inf,
   f_rnd_ex7_flag_zer,
   f_rnd_ex7_flag_ux,
   f_dcd_ex7_fpscr_wr,
   f_dcd_ex7_fpscr_addr,
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
   f_scr_ex8_cr_fld,
   f_scr_ex8_fx_thread0,
   f_scr_ex8_fx_thread1,
   f_scr_cpl_fx_thread0,
   f_scr_cpl_fx_thread1
);
   parameter           THREADS = 2;

   inout               vdd;
   inout               gnd;
   input               clkoff_b;		// tiup
   input               act_dis;		// ??tidn??
   input               flush;		// ??tidn??
   input [4:7]         delay_lclkr;		// tidn,
   input [4:7]         mpw1_b;		// tidn,
   input [0:1]         mpw2_b;		// tidn,
   input               sg_1;
   input               thold_1;
   input               fpu_enable;		//dc_act
   input  [0:`NCLK_WIDTH-1]              nclk;

   input               f_scr_si;		// perv
   output              f_scr_so;		// perv
   input               ex3_act_b;		// act writes
   input [0:3]         f_cr2_ex4_thread_b;		// thread write
   input               f_pic_ex6_scr_upd_move_b;
   input               f_pic_ex6_scr_upd_pipe_b;
   input               f_dcd_ex7_cancel;
   input [0:4]         f_pic_ex6_fprf_spec_b;		//FPRF for special cases
   input               f_pic_ex6_compare_b;
   input               f_pic_ex6_fprf_pipe_v_b;
   input               f_pic_ex6_fprf_hold_b;		//compare
   input               f_pic_ex6_fi_spec_b;
   input               f_pic_ex6_fi_pipe_v_b;
   input               f_pic_ex6_fr_spec_b;
   input               f_pic_ex6_fr_pipe_v_b;
   input               f_pic_ex6_ox_spec_b;
   input               f_pic_ex6_ox_pipe_v_b;
   input               f_pic_ex6_ux_spec_b;
   input               f_pic_ex6_ux_pipe_v_b;
   input               f_pic_ex6_flag_vxsnan_b;		////# sig_nan
   input               f_pic_ex6_flag_vxisi_b;		////# inf_sub_inf
   input               f_pic_ex6_flag_vxidi_b;		////# inf_div_inf
   input               f_pic_ex6_flag_vxzdz_b;		////# zer_div_zer
   input               f_pic_ex6_flag_vximz_b;		////# inf_mul_zer
   input               f_pic_ex6_flag_vxvc_b;		////# inval_cmp
   input               f_pic_ex6_flag_vxsqrt_b;		////# inval_sqrt
   input               f_pic_ex6_flag_vxcvi_b;		////# inval_convert
   input               f_pic_ex6_flag_zx_b;		////# div_zer

   input [0:3]         f_cr2_ex4_fpscr_bit_data_b;
   input [0:3]         f_cr2_ex4_fpscr_bit_mask_b;
   input [0:8]         f_cr2_ex4_fpscr_nib_mask_b;
   input               f_cr2_ex4_mcrfs_b;
   input               f_cr2_ex4_mtfsf_b;
   input               f_cr2_ex4_mtfsfi_b;
   input               f_cr2_ex4_mtfsbx_b;

   input [0:3]         f_nrm_ex6_fpscr_wr_dat_dfp;
   output [0:3]        f_scr_ex6_fpscr_rd_dat_dfp;

   input [0:31]        f_nrm_ex6_fpscr_wr_dat;

   input [24:31]       f_cr2_ex7_fpscr_rd_dat;		////# for update
   input [24:31]       f_cr2_ex6_fpscr_rd_dat;		////# for mffs
   output [0:31]       f_scr_ex6_fpscr_rd_dat;		////# f_rnd
   output [0:7]        f_scr_fpscr_ctrl_thr0;
   output [0:7]        f_scr_fpscr_ctrl_thr1;
   output [0:1]        f_scr_ex6_fpscr_rm_thr0;		////# to fu_divsqrt
   output [0:4]        f_scr_ex6_fpscr_ee_thr0;		////# to fu_divsqrt
   output              f_scr_ex6_fpscr_ni_thr0;

   output [0:1]        f_scr_ex6_fpscr_rm_thr1;		////# to fu_divsqrt
   output [0:4]        f_scr_ex6_fpscr_ee_thr1;		////# to fu_divsqrt
   output              f_scr_ex6_fpscr_ni_thr1;

   input [0:1]         f_dsq_ex6_divsqrt_v;
   input               f_dsq_ex6_divsqrt_v_suppress;

   input               f_dsq_ex6_divsqrt_flag_fpscr_zx;
   input               f_dsq_ex6_divsqrt_flag_fpscr_idi;
   input               f_dsq_ex6_divsqrt_flag_fpscr_zdz;
   input               f_dsq_ex6_divsqrt_flag_fpscr_sqrt;
   input               f_dsq_ex6_divsqrt_flag_fpscr_nan;
   input               f_dsq_ex6_divsqrt_flag_fpscr_snan;

   input               f_rnd_ex7_flag_up;
   input               f_rnd_ex7_flag_fi;
   input               f_rnd_ex7_flag_ox;
   input               f_rnd_ex7_flag_den;
   input               f_rnd_ex7_flag_sgn;
   input               f_rnd_ex7_flag_inf;
   input               f_rnd_ex7_flag_zer;
   input               f_rnd_ex7_flag_ux;

   input               f_dcd_ex7_fpscr_wr;
   input [0:5]         f_dcd_ex7_fpscr_addr;

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



   output [0:3]        f_scr_ex8_cr_fld;		////#iu
   output [0:3]        f_scr_ex8_fx_thread0;		////#iu
   output [0:3]        f_scr_ex8_fx_thread1;		////#iu
   output [0:3]        f_scr_cpl_fx_thread0;		////#iu
   output [0:3]        f_scr_cpl_fx_thread1;		////#iu

   // end ports

   // ENTITY


   parameter           tiup = 1'b1;
   parameter           tidn = 1'b0;

   wire                sg_0;
   wire                thold_0_b;
   wire                thold_0;
   wire                force_t;
   wire                ex4_act;
   wire                ex3_act;
   wire                ex5_act;
   wire                ex6_act;
   wire                ex6_act_din;
   wire                ex6_act_q;
   wire                ex7_act;
   wire                ex7_th0_act;
   wire                ex7_th1_act;
   wire                ex7_th2_act;
   wire                ex7_th3_act;
   wire                ex7_th0_act_wocan;
   wire                ex7_th1_act_wocan;
   wire                ex7_th2_act_wocan;
   wire                ex7_th3_act_wocan;

   (* analysis_not_referenced="TRUE" *)
   wire [0:3]          act_spare_unused;
   (* analysis_not_referenced="TRUE" *)
   wire [0:67]          spare_unused;
   //-----------------
   wire [0:13]         act_so;		//SCAN
   wire [0:13]         act_si;		//SCAN

   wire [0:24]         ex5_ctl_so;		//SCAN
   wire [0:24]         ex5_ctl_si;		//SCAN
   wire [0:24]         ex6_ctl_so;		//SCAN
   wire [0:24]         ex6_ctl_si;		//SCAN
   wire [0:24]         ex7_ctl_so;		//SCAN
   wire [0:24]         ex7_ctl_si;		//SCAN
   wire [0:3]          ex8_ctl_so;		//SCAN
   wire [0:3]          ex8_ctl_si;		//SCAN

   wire [0:26]         ex7_flag_so;		//SCAN
   wire [0:26]         ex7_flag_si;		//SCAN
   wire [0:35]         ex7_mvdat_so;		//SCAN
   wire [0:35]         ex7_mvdat_si;		//SCAN

   wire [0:27]         fpscr_th0_so;		//SCAN
   wire [0:27]         fpscr_th0_si;		//SCAN
   wire [0:27]         fpscr_th1_so;		//SCAN
   wire [0:27]         fpscr_th1_si;		//SCAN
   wire [0:27]         fpscr_th2_so;		//SCAN
   wire [0:27]         fpscr_th2_si;		//SCAN
   wire [0:27]         fpscr_th3_so;		//SCAN
   wire [0:27]         fpscr_th3_si;		//SCAN

   wire [0:3]          ex8_crf_so;		//SCAN
   wire [0:3]          ex8_crf_si;		//SCAN
   //-----------------
   wire [0:23]         ex7_mrg;
   wire [0:3]          ex7_mrg_dfp;
   wire [0:3]          ex7_fpscr_dfp_din;
   wire [0:23]         ex7_fpscr_din;
   wire                ex7_fpscr_din1_thr0;
   wire                ex7_fpscr_din1_thr1;
   wire [0:3]          ex7_cr_fld;
   wire [0:3]          ex7_cr_fld_x;
   wire [0:31]         ex7_fpscr_move;
   wire [0:23]         ex7_fpscr_pipe;
   wire [0:3]          ex7_fpscr_move_dfp;
   wire [0:3]          ex7_fpscr_pipe_dfp;

   wire [0:3]          fpscr_dfp_th0;
   wire [0:3]          fpscr_dfp_th1;
   wire [0:3]          fpscr_dfp_th2;
   wire [0:3]          fpscr_dfp_th3;

   wire [0:23]         fpscr_th0;
   wire [0:23]         fpscr_th1;
   wire [0:23]         fpscr_th2;
   wire [0:23]         fpscr_th3;

   wire [0:31]         fpscr_rd_dat;
   wire [0:3]          fpscr_rd_dat_dfp;
   wire [0:3]          ex8_cr_fld;
   wire [0:4]          ex7_fprf_pipe;

   wire [0:3]          ex5_thread;
   wire [0:3]          ex6_thread;
   wire [0:3]          ex6_thread_q;
   wire [0:3]          ex7_thread;
   wire [0:3]          ex8_thread;

   wire                ex6_th0_act;
   wire                ex6_th1_act;
   wire                ex6_th2_act;
   wire                ex6_th3_act;
   wire                ex7_upd_move;
   wire                ex7_scr_upd_move;
   wire                ex7_upd_pipe;

   wire [0:4]          ex7_fprf_spec;
   wire                ex7_compare;
   wire                ex7_fprf_pipe_v;
   wire                ex7_fprf_hold;
   wire                ex7_fi_spec;
   wire                ex7_fi_pipe_v;
   wire                ex7_fr_spec;
   wire                ex7_fr_pipe_v;
   wire                ex7_ox_spec;
   wire                ex7_ox_pipe_v;
   wire                ex7_ux_spec;
   wire                ex7_ux_pipe_v;
   wire [0:31]         ex7_mv_data;
   wire [0:3]          ex7_mv_data_dfp;
   wire [0:31]         ex7_mv_sel;
   wire [0:3]          ex7_mv_sel_dfp;

   wire                ex7_flag_vxsnan;
   wire                ex7_flag_vxisi;
   wire                ex7_flag_vxidi;
   wire                ex7_flag_vxzdz;
   wire                ex7_flag_vximz;
   wire                ex7_flag_vxvc;
   wire                ex7_flag_vxsqrt;
   wire                ex7_flag_vxcvi;
   wire                ex7_flag_zx;
   wire [0:31]         ex7_fpscr_wr_dat;
   wire [0:3]          ex7_fpscr_wr_dat_dfp;
   wire                ex7_new_excp;
   wire [0:3]          ex5_bit_data;
   wire [0:3]          ex5_bit_mask;
   wire [0:8]          ex5_nib_mask;
   wire                ex5_mcrfs;
   wire                ex5_mtfsf;
   wire                ex5_mtfsfi;
   wire                ex5_mtfsbx;
   wire [0:3]          ex6_bit_data;
   wire [0:3]          ex6_bit_mask;
   wire [0:8]          ex6_nib_mask;
   wire                ex6_mcrfs;
   wire                ex6_mtfsf;
   wire                ex6_mtfsfi;
   wire                ex6_mtfsbx;
   wire [0:3]          ex7_bit_data;
   wire [0:3]          ex7_bit_mask;
   wire [0:8]          ex7_nib_mask;
   wire                ex7_mcrfs;
   wire                ex7_mtfsf;
   wire                ex7_mtfsfi;
   wire                ex7_mtfsbx;
   wire                unused_stuff;
   wire                ex6_scr_upd_move;
   wire                ex6_scr_upd_pipe;
   wire [0:3]          ex4_thread;
   wire [0:3]          ex4_fpscr_bit_data;
   wire [0:3]          ex4_fpscr_bit_mask;
   wire [0:8]          ex4_fpscr_nib_mask;
   wire                ex4_mcrfs;
   wire                ex4_mtfsf;
   wire                ex4_mtfsfi;
   wire                ex4_mtfsbx;
   wire                ex6_flag_vxsnan;
   wire                ex6_flag_vxisi;
   wire                ex6_flag_vxidi;
   wire                ex6_flag_vxzdz;
   wire                ex6_flag_vximz;
   wire                ex6_flag_vxvc;
   wire                ex6_flag_vxsqrt;
   wire                ex6_flag_vxcvi;
   wire                ex6_flag_zx;
   wire [0:4]          ex6_fprf_spec;
   wire                ex6_compare;
   wire                ex6_fprf_pipe_v;
   wire                ex6_fprf_hold;
   wire                ex6_fi_spec;
   wire                ex6_fi_pipe_v;
   wire                ex6_fr_spec;
   wire                ex6_fr_pipe_v;
   wire                ex6_ox_spec;
   wire                ex6_ox_pipe_v;
   wire                ex6_ux_spec;
   wire                ex6_ux_pipe_v;
   wire                ex7_upd_move_nmcrfs;
   wire                ex7_upd_move_thr0;
   wire                ex7_upd_move_thr1;
   wire                ex6_divsqrt_v;
   wire                ex7_divsqrt_v;
   wire                ex6_divsqrt_v_s;
   wire                ex6_divsqrt_v_suppress;
   wire [0:1]          ex6_divsqrt_v_tid;
   wire [0:63]         zeros;
   wire                re0_thr0;

   wire [0:23]         do0_thr0;
   wire [0:23]         do0_thr1;
   wire                re1_thr0;

   wire [0:5]          ra0_thr0;
   wire [0:5]          ra0_thr1;
   wire [0:5]          ra1_thr0;
   wire [0:5]          ra1_thr1;

   wire [0:23]         do1_thr0;
   wire [0:23]         do1_thr1;

   wire                we0_thr0;
   wire                we0_thr1;
   wire [0:5]          wa0;
   wire [0:23]         di0;
   wire                we1;
   wire [0:5]          wa1;
   wire [0:23]         di1;
   wire                re0_2_thr0;
   wire                re1_2_thr0;

   wire                re0_thr1;
   wire                re1_thr1;
   wire                re0_2_thr1;
   wire                re1_2_thr1;

   wire [28:63]        cfpscr_thr0_din;
   wire [28:63]        cfpscr_thr1_din;
   wire [28:63]        cfpscr_thr0_din_i0;
   wire [28:63]        cfpscr_thr1_din_i0;

   wire [28:63]        cfpscr_thr0_l2;
   wire [28:63]        cfpscr_thr1_l2;

   wire [32:63]        cfpscr_pipe_thr1_i0;
   wire                cfpscr_new_excp_thr1_i0;

   wire [32:63]        cfpscr_pipe_thr0_i0;
   wire                cfpscr_new_excp_thr0_i0;

   wire                cfpscr_i0_wr_thr0;
   wire 	       cfpscr_i1_wr_thr0;
   wire 	       cfpscr_i0i1_wr_thr0;

   wire 	       cfpscr_i0_wr_thr1;
   wire 	       cfpscr_i1_wr_thr1;
   wire 	       cfpscr_i0i1_wr_thr1;

   wire [28:63]        cfpscr_thrx_cr;
   wire [28:63]        ex6_cfpscr_thrx_cr;

   wire [0:35]         cfpscr_thr0_si;
   wire [0:35]         cfpscr_thr0_so;
   wire [0:35]         cfpscr_thr1_si;
   wire [0:35]         cfpscr_thr1_so;

   wire [0:3]          cadd_si;
   wire [0:3]          cadd_so;
   wire [0:3]          cadd_thr1_si;
   wire [0:3]          cadd_thr1_so;
   wire [0:23]         ex7_hfpscr_pipe;
   wire [28:63]        cfpscr_pipe_thr0;
   wire [28:63]        cfpscr_pipe_thr1;

   wire [28:63]        cfpscr_move;

   wire [35:55]        upd_i0_fpscr_thr0;
   wire [35:55]        upd_i1_fpscr_thr0;
   wire [35:55]        upd_i0_fpscr_thr1;
   wire [35:55]        upd_i1_fpscr_thr1;

   wire                cfpscr_upd_i0_thr0;
   wire                cfpscr_upd_i1_thr0;
   wire                cfpscr_upd_i0_thr1;
   wire                cfpscr_upd_i1_thr1;

   wire                ex6_divsqrt_flag_fpscr_nan;
   wire                ex7_divsqrt_flag_fpscr_nan;

   wire                cfpscr_mtfsf;
   wire                cfpscr_mtfsfi;
   wire                cfpscr_new_excp_thr0;
   wire                cfpscr_new_excp_thr1;

   wire                cfpscr_upd_move;
   wire                cfpscr_upd_pipe_thr0;
   wire                cfpscr_upd_pipe_thr1;

   wire                upd_i0_thr0;
   wire                upd_i0_thr1;

   wire                upd_i0_fprf_hold_thr0;
   wire                upd_i0_fprf_hold_thr1;

   wire                upd_i0_compare_thr0;
   wire                upd_i0_compare_thr1;

   wire                upd_i1_thr0;
   wire                upd_i1_thr1;
   wire                upd_i1_fprf_hold_thr0;
   wire                upd_i1_fprf_hold_thr1;

   wire                upd_i1_compare_thr0;
   wire                upd_i1_compare_thr1;
   wire                ex7_inv_fpscr_bit;

   wire                upd_i0_fprf_hold_47_thr0;
   wire                upd_i1_fprf_hold_47_thr0;
   wire                upd_i0_fprf_hold_47_thr1;
   wire                upd_i1_fprf_hold_47_thr1;

   wire [0:31]         fwrite_thr0;
   wire [0:31]         fwrite_thr1;
   wire [0:31]         fwrite_thr0_b;
   wire [0:31]         fwrite_thr1_b;
   wire [0:31]         fread0_thr0;
   wire [0:31]         fread0_thr1;
   wire [0:31]         fread1_thr0;
   wire [0:31]         fread1_thr1;

   wire [0:767]        hfpscr_thr0_q;
   wire [0:767]        hfpscr_thr0_din;
   wire [0:575]        hfpscr_thr1_q;
   wire [0:575]        hfpscr_thr1_din;

   wire [0:31]         fread0_thr0_q;
   wire [0:31]         fread1_thr0_q;
   wire [0:31]         fread0_thr1_q;
   wire [0:31]         fread1_thr1_q;

   wire [0:831]        hfpscr_thr0_so;
   wire [0:831]        hfpscr_thr0_si;
   wire [0:639]        hfpscr_thr1_so;
   wire [0:639]        hfpscr_thr1_si;

   genvar              i;

   ////############################################
   ////# pervasive
   ////############################################


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

   ////############################################
   ////# ACT LATCHES
   ////############################################

   assign ex3_act = (~ex3_act_b);
   assign ex6_scr_upd_move = (~f_pic_ex6_scr_upd_move_b);
   assign ex6_divsqrt_v = |(f_dsq_ex6_divsqrt_v);
   assign ex6_divsqrt_v_tid = f_dsq_ex6_divsqrt_v;
   assign ex6_divsqrt_v_s = ex6_divsqrt_v & (~f_dsq_ex6_divsqrt_v_suppress);
   assign ex6_divsqrt_v_suppress = f_dsq_ex6_divsqrt_v_suppress;

   assign ex6_scr_upd_pipe = ((~f_pic_ex6_scr_upd_pipe_b)) | ex6_divsqrt_v;

   assign ex6_act_din = ex6_act | ex6_divsqrt_v;


   tri_rlmreg_p #(.WIDTH(14)) act_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[6]),
      .mpw1_b(mpw1_b[6]),
      .mpw2_b(mpw2_b[1]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(act_so),
      .scin(act_si),
      //-----------------
      .din({    act_spare_unused[0],
                act_spare_unused[1],
                ex3_act,
                ex4_act,
                ex5_act,
                ex6_act_din,
                ex6_th0_act,
                ex6_th1_act,
                ex6_th2_act,
                ex6_th3_act,
                ex6_scr_upd_move,
                ex6_scr_upd_pipe,
                act_spare_unused[2],
                act_spare_unused[3]}),
      //-----------------
      .dout({   act_spare_unused[0],
                act_spare_unused[1],
                ex4_act,
                ex5_act,
                ex6_act_q,
                ex7_act,
                ex7_th0_act_wocan,
                ex7_th1_act_wocan,
                ex7_th2_act_wocan,
                ex7_th3_act_wocan,
                ex7_scr_upd_move,
                ex7_upd_pipe,
                act_spare_unused[2],
                act_spare_unused[3]})
   );

   assign ex6_act = ex6_act_q | ex6_divsqrt_v;

   assign ex7_upd_move = ex7_scr_upd_move & (~f_dcd_ex7_cancel) & (~ex7_divsqrt_v);
   assign ex7_upd_move_thr0 = ex7_upd_move & ex7_thread[0];
   assign ex7_upd_move_thr1 = ex7_upd_move & ex7_thread[1];

   assign ex6_th0_act = (ex6_thread[0] & ex6_act & (ex6_scr_upd_move | ex6_scr_upd_pipe));
   assign ex6_th1_act = (ex6_thread[1] & ex6_act & (ex6_scr_upd_move | ex6_scr_upd_pipe));
   assign ex6_th2_act = (ex6_thread[2] & ex6_act & (ex6_scr_upd_move | ex6_scr_upd_pipe));
   assign ex6_th3_act = (ex6_thread[3] & ex6_act & (ex6_scr_upd_move | ex6_scr_upd_pipe));

   assign ex7_th0_act = ex7_th0_act_wocan & (~f_dcd_ex7_cancel);
   assign ex7_th1_act = ex7_th1_act_wocan & (~f_dcd_ex7_cancel);
   assign ex7_th2_act = ex7_th2_act_wocan & (~f_dcd_ex7_cancel);
   assign ex7_th3_act = ex7_th3_act_wocan & (~f_dcd_ex7_cancel);

   ////##############################################
   ////# EX5 latches
   ////##############################################

   assign ex4_thread[0:3] = (~f_cr2_ex4_thread_b[0:3]);
   assign ex4_fpscr_bit_data[0:3] = (~f_cr2_ex4_fpscr_bit_data_b[0:3]);
   assign ex4_fpscr_bit_mask[0:3] = (~f_cr2_ex4_fpscr_bit_mask_b[0:3]);
   assign ex4_fpscr_nib_mask[0:8] = (~f_cr2_ex4_fpscr_nib_mask_b[0:8]);
   assign ex4_mcrfs = (~f_cr2_ex4_mcrfs_b);
   assign ex4_mtfsf = (~f_cr2_ex4_mtfsf_b);
   assign ex4_mtfsfi = (~f_cr2_ex4_mtfsfi_b);
   assign ex4_mtfsbx = (~f_cr2_ex4_mtfsbx_b);


   tri_rlmreg_p #(.WIDTH(25)) ex5_ctl_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),
      .mpw1_b(mpw1_b[4]),
      .mpw2_b(mpw2_b[0]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex5_ctl_so),
      .scin(ex5_ctl_si),
      //-----------------
      .din({    ex4_thread[0:3],
		ex4_fpscr_bit_data[0:3],
                ex4_fpscr_bit_mask[0:3],
                ex4_fpscr_nib_mask[0:8],
                ex4_mcrfs,
                ex4_mtfsf,
                ex4_mtfsfi,
                ex4_mtfsbx}),
      //-----------------
      .dout({   ex5_thread[0:3],
		ex5_bit_data[0:3],
                ex5_bit_mask[0:3],
                ex5_nib_mask[0:8],
                ex5_mcrfs,
                ex5_mtfsf,
                ex5_mtfsfi,
                ex5_mtfsbx})
   );

   ////##############################################
   ////# EX6 latches
   ////##############################################


   tri_rlmreg_p #(.WIDTH(25)) ex6_ctl_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[5]),
      .mpw1_b(mpw1_b[5]),
      .mpw2_b(mpw2_b[1]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex6_ctl_so),
      .scin(ex6_ctl_si),
      //-----------------
      .din({    ex5_thread[0:3],
		ex5_bit_data[0:3],
                ex5_bit_mask[0:3],
                ex5_nib_mask[0:8],
                ex5_mcrfs,
                ex5_mtfsf,
                ex5_mtfsfi,
                ex5_mtfsbx}),
      //-----------------
      .dout({   ex6_thread_q[0:3],
		ex6_bit_data[0:3],
                ex6_bit_mask[0:3],
                ex6_nib_mask[0:8],
                ex6_mcrfs,
                ex6_mtfsf,
                ex6_mtfsfi,
                ex6_mtfsbx})
   );

   assign ex6_thread[0] = (ex6_thread_q[0] & (~ex6_divsqrt_v)) | ex6_divsqrt_v_tid[0];
   assign ex6_thread[1] = (ex6_thread_q[1] & (~ex6_divsqrt_v)) | ex6_divsqrt_v_tid[1];
   assign ex6_thread[2] = ex6_thread_q[2] & (~ex6_divsqrt_v);
   assign ex6_thread[3] = ex6_thread_q[3] & (~ex6_divsqrt_v);

   ////##############################################
   ////# EX7 latches
   ////##############################################


   tri_rlmreg_p #(.WIDTH(25)) ex7_ctl_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[6]),
      .mpw1_b(mpw1_b[6]),
      .mpw2_b(mpw2_b[1]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex7_ctl_so),
      .scin(ex7_ctl_si),
      //-----------------
      .din({    ex6_thread[0:3],
		ex6_bit_data[0:3],
                ex6_bit_mask[0:3],
                ex6_nib_mask[0:8],
                ex6_mcrfs,
                ex6_mtfsf,
                ex6_mtfsfi,
                ex6_mtfsbx}),
      //-----------------
      .dout({   ex7_thread[0:3],
		ex7_bit_data[0:3],
                ex7_bit_mask[0:3],
                ex7_nib_mask[0:8],
                ex7_mcrfs,
                ex7_mtfsf,
                ex7_mtfsfi,
                ex7_mtfsbx})
   );


   tri_rlmreg_p #(.WIDTH(4)) ex8_ctl_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[7]),
      .mpw1_b(mpw1_b[7]),
      .mpw2_b(mpw2_b[1]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex8_ctl_so),
      .scin(ex8_ctl_si),
      //-----------------
      .din(ex7_thread[0:3]),
      //-----------------
      .dout(ex8_thread[0:3])
   );

   assign ex6_flag_vxsnan = (((~f_pic_ex6_flag_vxsnan_b)) & (~ex6_divsqrt_v)) | ((f_dsq_ex6_divsqrt_flag_fpscr_snan) & ex6_divsqrt_v);

   assign ex6_flag_vxisi = ((~f_pic_ex6_flag_vxisi_b)) & (~ex6_divsqrt_v);

   assign ex6_flag_vxidi = (((~f_pic_ex6_flag_vxidi_b)) & (~ex6_divsqrt_v)) | ((f_dsq_ex6_divsqrt_flag_fpscr_idi) & ex6_divsqrt_v);

   assign ex6_flag_vxzdz = (((~f_pic_ex6_flag_vxzdz_b)) & (~ex6_divsqrt_v)) | ((f_dsq_ex6_divsqrt_flag_fpscr_zdz) & ex6_divsqrt_v);

   assign ex6_flag_vximz = ((~f_pic_ex6_flag_vximz_b)) & (~ex6_divsqrt_v);
   assign ex6_flag_vxvc = ((~f_pic_ex6_flag_vxvc_b)) & (~ex6_divsqrt_v);

   assign ex6_flag_vxsqrt = (((~f_pic_ex6_flag_vxsqrt_b)) & (~ex6_divsqrt_v)) | ((f_dsq_ex6_divsqrt_flag_fpscr_sqrt) & ex6_divsqrt_v);

   assign ex6_flag_vxcvi = ((~f_pic_ex6_flag_vxcvi_b)) & (~ex6_divsqrt_v);

   assign ex6_flag_zx = (((~f_pic_ex6_flag_zx_b)) & (~ex6_divsqrt_v)) | ((f_dsq_ex6_divsqrt_flag_fpscr_zx) & ex6_divsqrt_v);

   assign ex6_fprf_spec[0] = (((~f_pic_ex6_fprf_spec_b[0])) & (~ex6_divsqrt_v));
   assign ex6_fprf_spec[1] = (((~f_pic_ex6_fprf_spec_b[1])) & (~ex6_divsqrt_v));
   assign ex6_fprf_spec[2] = (((~f_pic_ex6_fprf_spec_b[2])) & (~ex6_divsqrt_v));
   assign ex6_fprf_spec[3] = (((~f_pic_ex6_fprf_spec_b[3])) & (~ex6_divsqrt_v));
   assign ex6_fprf_spec[4] = (((~f_pic_ex6_fprf_spec_b[4])) & (~ex6_divsqrt_v));

   assign ex6_compare = ((~f_pic_ex6_compare_b)) & (~ex6_divsqrt_v);
   assign ex6_fprf_pipe_v = (((~f_pic_ex6_fprf_pipe_v_b)) | ex6_divsqrt_v) & (~(f_dsq_ex6_divsqrt_v_suppress & ex6_divsqrt_v));

   assign ex6_fprf_hold = (((~f_pic_ex6_fprf_hold_b)) | (ex6_divsqrt_v & ex6_divsqrt_v_suppress)) & (~ex6_divsqrt_v_s);
   assign ex6_fi_spec = ((~f_pic_ex6_fi_spec_b)) & (~ex6_divsqrt_v);
   assign ex6_fi_pipe_v = ((~f_pic_ex6_fi_pipe_v_b)) | ex6_divsqrt_v;
   assign ex6_fr_spec = ((~f_pic_ex6_fr_spec_b)) & (~ex6_divsqrt_v);
   assign ex6_fr_pipe_v = ((~f_pic_ex6_fr_pipe_v_b)) | ex6_divsqrt_v;
   assign ex6_ox_spec = ((~f_pic_ex6_ox_spec_b)) & (~ex6_divsqrt_v);
   assign ex6_ox_pipe_v = ((~f_pic_ex6_ox_pipe_v_b)) | ex6_divsqrt_v;
   assign ex6_ux_spec = ((~f_pic_ex6_ux_spec_b)) & (~ex6_divsqrt_v);
   assign ex6_ux_pipe_v = ((~f_pic_ex6_ux_pipe_v_b)) | ex6_divsqrt_v;

   assign ex6_divsqrt_flag_fpscr_nan = f_dsq_ex6_divsqrt_flag_fpscr_nan & ex6_divsqrt_v;


   tri_rlmreg_p #(.WIDTH(27)) ex7_flag_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[6]),
      .mpw1_b(mpw1_b[6]),
      .mpw2_b(mpw2_b[1]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),		// ex6_act, -- todo: act pin
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex7_flag_so),
      .scin(ex7_flag_si),
      //-----------------
      .din({    ex6_flag_vxsnan,		////# sig_nan
                ex6_flag_vxisi,		////# inf_sub_inf
                ex6_flag_vxidi,		////# inf_div_inf
                ex6_flag_vxzdz,		////# zer_div_zer
                ex6_flag_vximz,		////# inf_mul_zer
                ex6_flag_vxvc,		////# inval_cmp
                ex6_flag_vxsqrt,		////# inval_sqrt
                ex6_flag_vxcvi,		////# inval_convert
                ex6_flag_zx,		////# div_zer
                ex6_fprf_spec[0:4],		//FPRF/'0'FPCC for special cases
                ex6_compare,
                ex6_fprf_pipe_v,		//fprf update exluding compare
                ex6_fprf_hold,		//fprf update including compare
                ex6_fi_spec,
                ex6_fi_pipe_v,
                ex6_fr_spec,
                ex6_fr_pipe_v,
                ex6_ox_spec,
                ex6_ox_pipe_v,
                ex6_ux_spec,
                ex6_ux_pipe_v,
                ex6_divsqrt_flag_fpscr_nan,
                ex6_divsqrt_v}),
      //-----------------
      .dout({   ex7_flag_vxsnan,		//LAT--
                ex7_flag_vxisi,		//LAT--
                ex7_flag_vxidi,		//LAT--
                ex7_flag_vxzdz,		//LAT--
                ex7_flag_vximz,		//LAT--
                ex7_flag_vxvc,		//LAT--
                ex7_flag_vxsqrt,		//LAT--
                ex7_flag_vxcvi,		//LAT--
                ex7_flag_zx,		//LAT--
                ex7_fprf_spec[0:4],		//LAT--
                ex7_compare,		//LAT--
                ex7_fprf_pipe_v,		//LAT--
                ex7_fprf_hold,		//LAT--
                ex7_fi_spec,		//LAT--
                ex7_fi_pipe_v,		//LAT--
                ex7_fr_spec,		//LAT--
                ex7_fr_pipe_v,		//LAT--
                ex7_ox_spec,		//LAT--
                ex7_ox_pipe_v,		//LAT--
                ex7_ux_spec,		//LAT--
                ex7_ux_pipe_v,		//LAT--
                ex7_divsqrt_flag_fpscr_nan,		//LAT--
                ex7_divsqrt_v})
   );


   tri_rlmreg_p #(.WIDTH(36)) ex7_mvdat_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[6]),
      .mpw1_b(mpw1_b[6]),
      .mpw2_b(mpw2_b[1]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex7_mvdat_so),
      .scin(ex7_mvdat_si),
      //-----------------
      .din({   f_nrm_ex6_fpscr_wr_dat_dfp[0:3],
               f_nrm_ex6_fpscr_wr_dat[0:31]}),
      .dout({  ex7_fpscr_wr_dat_dfp[0:3],		//LAT--
               ex7_fpscr_wr_dat[0:31]})		//LAT--
   );

   ////##############################################
   ////# EX7 logic
   ////##############################################

   ////#-----------------------------------------
   ////# select field for mcrfs
   ////#-----------------------------------------

   assign cfpscr_thrx_cr[28:63] = (cfpscr_thr0_l2[28:63] & {36{ex7_thread[0]}}) |
                                  (cfpscr_thr1_l2[28:63] & {36{ex7_thread[1]}});

   assign ex6_cfpscr_thrx_cr[28:63] = (cfpscr_thr0_l2[28:63] & {36{ex6_thread[0]}}) |
                                      (cfpscr_thr1_l2[28:63] & {36{ex6_thread[1]}});

   assign ex7_cr_fld_x[0:3] =    (ex7_mrg[0:3] &             {4{ex7_nib_mask[0]}}) |
                                 (ex7_mrg[4:7] &             {4{ex7_nib_mask[1]}}) |
                                 (ex7_mrg[8:11] &            {4{ex7_nib_mask[2]}}) |
                                 (ex7_mrg[12:15] &           {4{ex7_nib_mask[3]}}) |
                                 (ex7_mrg[16:19] &           {4{ex7_nib_mask[4]}}) |
                                 (({tidn, ex7_mrg[21:23]}) & {4{ex7_nib_mask[5]}}) |
                                 (cfpscr_thrx_cr[56:59] &    {4{ex7_nib_mask[6]}}) |
                                 (cfpscr_thrx_cr[60:63] &    {4{ex7_nib_mask[7]}});		//[20] is a reserved bit

   assign ex7_upd_move_nmcrfs = ex7_upd_move & (~ex7_mcrfs);

   // fmr
   // the old value
   //( cfpscr_thr0_l2(32 to 35)     and (0 to 3 =>     ex7_upd_pipe                           ) ) or  -- what the math update will be
   //( cfpscr_thr0_l2(32 to 35)     and (0 to 3 =>     ex7_upd_move_nmcrfs                    ) ) ;   -- what the math update will be
   assign ex7_cr_fld[0:3] = (ex7_mrg[0:3] &       {4{(~ex7_upd_move) & (~ex7_upd_pipe)}}) |
                            (ex7_cr_fld_x[0:3] &  {4{ex7_mcrfs}}) |
                            (ex7_fpscr_din[0:3] & {4{ex7_upd_pipe}}) |
                            (ex7_fpscr_din[0:3] & {4{ex7_upd_move_nmcrfs}});		// what the math update will be


   // what the math update will be

   ////#-----------------------------------------------------------------------
   ////# move to logic mtfsf mtfsfi mcrf mtfsb0 mtfsb1
   ////#-----------------------------------------------------------------------
   // if mcrfs  : if nib_mask selects -> reset if (0,3:12,21:23) (bit mask=1111)
   // if mtfsfi : if nib_mask selects -> load with bit data      (bit mask=1111)
   // if mtfsf  : if nib_mask selects -> load with wr_data       (bit mask=1111)
   // if mtfsb0 : if nib_mask selects -> load with bit data      (if bit mask)
   // if mtfsb1 : if nib_mask selects -> load with bit_data      (if bit mask)

   assign ex7_mv_data_dfp[0:3] = (ex7_bit_data[0:3] &         {4{(~ex7_mtfsf)}}) |
                                 (ex7_fpscr_wr_dat_dfp[0:3] & {4{ex7_mtfsf}});

   assign ex7_mv_data[0:3] = (ex7_bit_data[0:3] & {4{(~ex7_mtfsf)}}) | (ex7_fpscr_wr_dat[0:3] & {4{ex7_mtfsf}});
   assign ex7_mv_data[4:7] = (ex7_bit_data[0:3] & {4{(~ex7_mtfsf)}}) | (ex7_fpscr_wr_dat[4:7] & {4{ex7_mtfsf}});
   assign ex7_mv_data[8:11] = (ex7_bit_data[0:3] & {4{(~ex7_mtfsf)}}) | (ex7_fpscr_wr_dat[8:11] & {4{ex7_mtfsf}});
   assign ex7_mv_data[12:15] = (ex7_bit_data[0:3] & {4{(~ex7_mtfsf)}}) | (ex7_fpscr_wr_dat[12:15] & {4{ex7_mtfsf}});
   assign ex7_mv_data[16:19] = (ex7_bit_data[0:3] & {4{(~ex7_mtfsf)}}) | (ex7_fpscr_wr_dat[16:19] & {4{ex7_mtfsf}});
   assign ex7_mv_data[20:23] = (ex7_bit_data[0:3] & {4{(~ex7_mtfsf)}}) | (ex7_fpscr_wr_dat[20:23] & {4{ex7_mtfsf}});
   assign ex7_mv_data[24:27] = (ex7_bit_data[0:3] & {4{(~ex7_mtfsf)}}) | (ex7_fpscr_wr_dat[24:27] & {4{ex7_mtfsf}});
   assign ex7_mv_data[28:31] = (ex7_bit_data[0:3] & {4{(~ex7_mtfsf)}}) | (ex7_fpscr_wr_dat[28:31] & {4{ex7_mtfsf}});

   assign ex7_mv_sel_dfp[0] = ex7_bit_mask[0] & ex7_nib_mask[8];
   assign ex7_mv_sel_dfp[1] = ex7_bit_mask[1] & ex7_nib_mask[8];
   assign ex7_mv_sel_dfp[2] = ex7_bit_mask[2] & ex7_nib_mask[8];
   assign ex7_mv_sel_dfp[3] = ex7_bit_mask[3] & ex7_nib_mask[8];

   assign ex7_mv_sel[0] = ex7_bit_mask[0] & ex7_nib_mask[0];		// fx
   assign ex7_mv_sel[1] = tidn;		//UNUSED                        -- fex
   assign ex7_mv_sel[2] = tidn;		//UNUSED                        -- vx
   assign ex7_mv_sel[3] = ex7_bit_mask[3] & ex7_nib_mask[0];		// ox
   assign ex7_mv_sel[4] = ex7_bit_mask[0] & ex7_nib_mask[1];		// ux
   assign ex7_mv_sel[5] = ex7_bit_mask[1] & ex7_nib_mask[1];		// zx
   assign ex7_mv_sel[6] = ex7_bit_mask[2] & ex7_nib_mask[1];		// xx
   assign ex7_mv_sel[7] = ex7_bit_mask[3] & ex7_nib_mask[1];		// vxsnan
   assign ex7_mv_sel[8] = ex7_bit_mask[0] & ex7_nib_mask[2];		// vxisi
   assign ex7_mv_sel[9] = ex7_bit_mask[1] & ex7_nib_mask[2];		// vxidi
   assign ex7_mv_sel[10] = ex7_bit_mask[2] & ex7_nib_mask[2];		// vxzdz
   assign ex7_mv_sel[11] = ex7_bit_mask[3] & ex7_nib_mask[2];		// vximz
   assign ex7_mv_sel[12] = ex7_bit_mask[0] & ex7_nib_mask[3];		// vxvc
   assign ex7_mv_sel[13] = ex7_bit_mask[1] & ex7_nib_mask[3] & (~ex7_mcrfs);		// fr
   assign ex7_mv_sel[14] = ex7_bit_mask[2] & ex7_nib_mask[3] & (~ex7_mcrfs);		// fi
   assign ex7_mv_sel[15] = ex7_bit_mask[3] & ex7_nib_mask[3] & (~ex7_mcrfs);		// FPRF C
   assign ex7_mv_sel[16] = ex7_bit_mask[0] & ex7_nib_mask[4] & (~ex7_mcrfs);		// FPRF fpcc(lt)
   assign ex7_mv_sel[17] = ex7_bit_mask[1] & ex7_nib_mask[4] & (~ex7_mcrfs);		// FPRF fpcc(gt)
   assign ex7_mv_sel[18] = ex7_bit_mask[2] & ex7_nib_mask[4] & (~ex7_mcrfs);		// FPRF fpcc(eq)
   assign ex7_mv_sel[19] = ex7_bit_mask[3] & ex7_nib_mask[4] & (~ex7_mcrfs);		// FPRF fpcc(nan)
   assign ex7_mv_sel[20] = ex7_bit_mask[0] & ex7_nib_mask[5] & (~ex7_mcrfs);		// RESERVED
   assign ex7_mv_sel[21] = ex7_bit_mask[1] & ex7_nib_mask[5];		// vx-soft
   assign ex7_mv_sel[22] = ex7_bit_mask[2] & ex7_nib_mask[5];		// vx-sqrt
   assign ex7_mv_sel[23] = ex7_bit_mask[3] & ex7_nib_mask[5];		// vx-vci
   assign ex7_mv_sel[24] = ex7_bit_mask[0] & ex7_nib_mask[6] & (~ex7_mcrfs);		// ve
   assign ex7_mv_sel[25] = ex7_bit_mask[1] & ex7_nib_mask[6] & (~ex7_mcrfs);		// oe
   assign ex7_mv_sel[26] = ex7_bit_mask[2] & ex7_nib_mask[6] & (~ex7_mcrfs);		// ue
   assign ex7_mv_sel[27] = ex7_bit_mask[3] & ex7_nib_mask[6] & (~ex7_mcrfs);		// ze
   assign ex7_mv_sel[28] = ex7_bit_mask[0] & ex7_nib_mask[7] & (~ex7_mcrfs);		// xe
   assign ex7_mv_sel[29] = ex7_bit_mask[1] & ex7_nib_mask[7] & (~ex7_mcrfs);		// non-ieee
   assign ex7_mv_sel[30] = ex7_bit_mask[2] & ex7_nib_mask[7] & (~ex7_mcrfs);		// rnd-mode
   assign ex7_mv_sel[31] = ex7_bit_mask[3] & ex7_nib_mask[7] & (~ex7_mcrfs);		// rnd-mode

   assign ex7_fpscr_move[0] = (ex7_mrg[0] & (~ex7_mv_sel[0])) | (ex7_mv_data[0] & ex7_mv_sel[0]);
   assign ex7_fpscr_move[1] = tidn;		////unused (from other bits after move/pipe selection)
   assign ex7_fpscr_move[2] = tidn;		////unused (from other bits after move/pipe selection)
   assign ex7_fpscr_move[3:23] = (ex7_mrg[3:23] & (~ex7_mv_sel[3:23])) | (ex7_mv_data[3:23] & ex7_mv_sel[3:23]);
   assign ex7_fpscr_move[24:31] = (cfpscr_thrx_cr[56:63] & (~ex7_mv_sel[24:31])) | (ex7_mv_data[24:31] & ex7_mv_sel[24:31]);

   assign ex7_fpscr_move_dfp[0:3] = (ex7_mrg_dfp[0:3] & (~ex7_mv_sel_dfp[0:3])) | (ex7_mv_data_dfp[0:3] & ex7_mv_sel_dfp[0:3]);

   ////#------------------------------------------------------------------------
   ////# decode fprf field for pipe settings
   ////#------------------------------------------------------------------------
   // FPRF
   // 10001  QNAN     [0]  qnan | den | (sign*zero)
   // 01001 -INF      [1]  sign * !zero
   // 01000 -norm     [2] !sign * !zero * !qnan
   // 11000 -den      [3]  zero
   // 10010 -zero     [4]  inf   | qnan
   // 00010 +zero
   // 10100 +den
   // 00100 +norm
   // 00101 +inf

   assign ex7_fprf_pipe[0] = (f_rnd_ex7_flag_sgn & f_rnd_ex7_flag_zer) | (f_rnd_ex7_flag_den & (~f_rnd_ex7_flag_zer)) | ex7_divsqrt_flag_fpscr_nan;

   assign ex7_fprf_pipe[1] = (f_rnd_ex7_flag_sgn & (~f_rnd_ex7_flag_zer)) & (~ex7_divsqrt_flag_fpscr_nan);
   assign ex7_fprf_pipe[2] = ((~f_rnd_ex7_flag_sgn) & (~f_rnd_ex7_flag_zer)) & (~ex7_divsqrt_flag_fpscr_nan);
   assign ex7_fprf_pipe[3] = f_rnd_ex7_flag_zer & (~ex7_divsqrt_flag_fpscr_nan);
   assign ex7_fprf_pipe[4] = f_rnd_ex7_flag_inf | ex7_divsqrt_flag_fpscr_nan;

   ////#------------------------------------------------------------------------
   ////# functional updates (excp enable cases, special setting vs pipe setting)
   ////#------------------------------------------------------------------------

   assign ex7_fpscr_pipe[0] = ex7_mrg[0];		// <sticky aspect> check 0->1 excp after selection for move/pipe
   assign ex7_fpscr_pipe[1] = tidn;		//// unused (from other bits after move/pipe selection)
   assign ex7_fpscr_pipe[2] = tidn;		//// unused (from other bits after move/pipe selection)
   assign ex7_fpscr_pipe[3] = ex7_mrg[3] | ex7_ox_spec | (ex7_ox_pipe_v & f_rnd_ex7_flag_ox);		//ox STICKY
   assign ex7_fpscr_pipe[4] = ex7_mrg[4] | ex7_ux_spec | (ex7_ux_pipe_v & f_rnd_ex7_flag_ux);		//ux STICKY
   assign ex7_fpscr_pipe[5] = ex7_mrg[5] | ex7_flag_zx;		//sticky

   assign ex7_fpscr_pipe[6] = (ex7_mrg[6]) | (ex7_fi_spec) | (ex7_fi_pipe_v & f_rnd_ex7_flag_fi);		// ex7_fpscr_pipe(14); --sticky version of fi

   assign ex7_fpscr_pipe[7] = ex7_mrg[7] | ex7_flag_vxsnan;		//sticky
   assign ex7_fpscr_pipe[8] = ex7_mrg[8] | ex7_flag_vxisi;		//sticky
   assign ex7_fpscr_pipe[9] = ex7_mrg[9] | ex7_flag_vxidi;		//sticky
   assign ex7_fpscr_pipe[10] = ex7_mrg[10] | ex7_flag_vxzdz;		//sticky
   assign ex7_fpscr_pipe[11] = ex7_mrg[11] | ex7_flag_vximz;		//sticky
   assign ex7_fpscr_pipe[12] = ex7_mrg[12] | ex7_flag_vxvc;		//sticky

   assign ex7_fpscr_pipe[13] = (ex7_mrg[13] & ex7_compare) | (ex7_fr_spec) | (ex7_fr_pipe_v & f_rnd_ex7_flag_up);		//fr NOT sticky
   assign ex7_fpscr_pipe[14] = (ex7_mrg[14] & ex7_compare) | (ex7_fi_spec) | (ex7_fi_pipe_v & f_rnd_ex7_flag_fi);		//fi NOT sticky

   assign ex7_fpscr_pipe[15] = (ex7_mrg[15] & (ex7_fprf_hold)) | (ex7_mrg[15] & (ex7_compare & (~ex7_divsqrt_v))) | (ex7_fprf_spec[0]) | (ex7_fprf_pipe_v & ex7_fprf_pipe[0]);		//FPRF C    NOT sticky

   assign ex7_fpscr_pipe[16] = (ex7_mrg[16] & (ex7_fprf_hold)) | (ex7_fprf_spec[1]) | (ex7_fprf_pipe_v & ex7_fprf_pipe[1]);		//FPRF fpdd(lt)
   assign ex7_fpscr_pipe[17] = (ex7_mrg[17] & (ex7_fprf_hold)) | (ex7_fprf_spec[2]) | (ex7_fprf_pipe_v & ex7_fprf_pipe[2]);		//FPRF fpcc(gt)
   assign ex7_fpscr_pipe[18] = (ex7_mrg[18] & (ex7_fprf_hold)) | (ex7_fprf_spec[3]) | (ex7_fprf_pipe_v & ex7_fprf_pipe[3]);		//FPRF fpcc(eq)
   assign ex7_fpscr_pipe[19] = (ex7_mrg[19] & (ex7_fprf_hold)) | (ex7_fprf_spec[4]) | (ex7_fprf_pipe_v & ex7_fprf_pipe[4]);		//FPRF fpcc(nan)

   assign ex7_fpscr_pipe[20] = tidn;		// reseved bit <UNUSED>
   assign ex7_fpscr_pipe[21] = ex7_mrg[21];		// VXSOFT
   assign ex7_fpscr_pipe[22] = ex7_mrg[22] | ex7_flag_vxsqrt;		//sticky
   assign ex7_fpscr_pipe[23] = ex7_mrg[23] | ex7_flag_vxcvi;		//sticky

   assign ex7_fpscr_pipe_dfp[0:3] = ex7_mrg_dfp[0:3];

   ////#------------------------------------------------------------------------
   ////# creating the funny or bits afer the selection
   ////#------------------------------------------------------------------------

   assign ex7_fpscr_dfp_din[0] = (ex7_fpscr_move_dfp[0] & ex7_upd_move) | (ex7_fpscr_pipe_dfp[0] & ex7_upd_pipe);
   assign ex7_fpscr_dfp_din[1] = (ex7_fpscr_move_dfp[1] & ex7_upd_move) | (ex7_fpscr_pipe_dfp[1] & ex7_upd_pipe);
   assign ex7_fpscr_dfp_din[2] = (ex7_fpscr_move_dfp[2] & ex7_upd_move) | (ex7_fpscr_pipe_dfp[2] & ex7_upd_pipe);
   assign ex7_fpscr_dfp_din[3] = (ex7_fpscr_move_dfp[3] & ex7_upd_move) | (ex7_fpscr_pipe_dfp[3] & ex7_upd_pipe);

   assign ex7_fpscr_din[23] = (ex7_fpscr_move[23] & ex7_upd_move) | (ex7_fpscr_pipe[23] & ex7_upd_pipe);
   assign ex7_fpscr_din[22] = (ex7_fpscr_move[22] & ex7_upd_move) | (ex7_fpscr_pipe[22] & ex7_upd_pipe);
   assign ex7_fpscr_din[21] = (ex7_fpscr_move[21] & ex7_upd_move) | (ex7_fpscr_pipe[21] & ex7_upd_pipe);
   assign ex7_fpscr_din[20] = tidn;		// reserved
   assign ex7_fpscr_din[19] = (ex7_fpscr_move[19] & ex7_upd_move) | (ex7_fpscr_pipe[19] & ex7_upd_pipe);
   assign ex7_fpscr_din[18] = (ex7_fpscr_move[18] & ex7_upd_move) | (ex7_fpscr_pipe[18] & ex7_upd_pipe);
   assign ex7_fpscr_din[17] = (ex7_fpscr_move[17] & ex7_upd_move) | (ex7_fpscr_pipe[17] & ex7_upd_pipe);
   assign ex7_fpscr_din[16] = (ex7_fpscr_move[16] & ex7_upd_move) | (ex7_fpscr_pipe[16] & ex7_upd_pipe);
   assign ex7_fpscr_din[15] = (ex7_fpscr_move[15] & ex7_upd_move) | (ex7_fpscr_pipe[15] & ex7_upd_pipe);
   assign ex7_fpscr_din[14] = (ex7_fpscr_move[14] & ex7_upd_move) | (ex7_fpscr_pipe[14] & ex7_upd_pipe);
   assign ex7_fpscr_din[13] = (ex7_fpscr_move[13] & ex7_upd_move) | (ex7_fpscr_pipe[13] & ex7_upd_pipe);
   assign ex7_fpscr_din[12] = (ex7_fpscr_move[12] & ex7_upd_move) | (ex7_fpscr_pipe[12] & ex7_upd_pipe);
   assign ex7_fpscr_din[11] = (ex7_fpscr_move[11] & ex7_upd_move) | (ex7_fpscr_pipe[11] & ex7_upd_pipe);
   assign ex7_fpscr_din[10] = (ex7_fpscr_move[10] & ex7_upd_move) | (ex7_fpscr_pipe[10] & ex7_upd_pipe);
   assign ex7_fpscr_din[9] = (ex7_fpscr_move[9] & ex7_upd_move) | (ex7_fpscr_pipe[9] & ex7_upd_pipe);
   assign ex7_fpscr_din[8] = (ex7_fpscr_move[8] & ex7_upd_move) | (ex7_fpscr_pipe[8] & ex7_upd_pipe);
   assign ex7_fpscr_din[7] = (ex7_fpscr_move[7] & ex7_upd_move) | (ex7_fpscr_pipe[7] & ex7_upd_pipe);
   assign ex7_fpscr_din[6] = (ex7_fpscr_move[6] & ex7_upd_move) | (ex7_fpscr_pipe[6] & ex7_upd_pipe);
   assign ex7_fpscr_din[5] = (ex7_fpscr_move[5] & ex7_upd_move) | (ex7_fpscr_pipe[5] & ex7_upd_pipe);
   assign ex7_fpscr_din[4] = (ex7_fpscr_move[4] & ex7_upd_move) | (ex7_fpscr_pipe[4] & ex7_upd_pipe);
   assign ex7_fpscr_din[3] = (ex7_fpscr_move[3] & ex7_upd_move) | (ex7_fpscr_pipe[3] & ex7_upd_pipe);

   // or all invalid operation exceptions
   // vxsnan
   // vxisi
   // vxidi
   // vxzdz
   // vximx
   // vxvc
   // vxzdz
   assign ex7_fpscr_din[2] = ex7_fpscr_din[7] | ex7_fpscr_din[8] | ex7_fpscr_din[9] | ex7_fpscr_din[10] | ex7_fpscr_din[11] | ex7_fpscr_din[12] | ex7_fpscr_din[21] | ex7_fpscr_din[22] | ex7_fpscr_din[23];		// vximx
   // vxvc

   // masked or of all exception bits
   // vx* / ve
   // ox  / oe
   // ux  / ue
   assign ex7_fpscr_din1_thr0 = (ex7_fpscr_din[2] & cfpscr_thr0_din[56]) | (ex7_fpscr_din[3] & cfpscr_thr0_din[57]) | (ex7_fpscr_din[4] & cfpscr_thr0_din[58]) | (ex7_fpscr_din[5] & cfpscr_thr0_din[59]) | (ex7_fpscr_din[6] & cfpscr_thr0_din[60]);		// zx  / ze
   // xx  / xe
   // masked or of all exception bits
   // vx* / ve
   // ox  / oe
   // ux  / ue
   assign ex7_fpscr_din1_thr1 = (ex7_fpscr_din[2] & cfpscr_thr1_din[56]) | (ex7_fpscr_din[3] & cfpscr_thr1_din[57]) | (ex7_fpscr_din[4] & cfpscr_thr1_din[58]) | (ex7_fpscr_din[5] & cfpscr_thr1_din[59]) | (ex7_fpscr_din[6] & cfpscr_thr1_din[60]);		// zx  / ze
   // xx  / xe
   assign ex7_fpscr_din[1] = (ex7_fpscr_din1_thr0 & ex7_thread[0]) | (ex7_fpscr_din1_thr1 & ex7_thread[1]);

   assign ex7_fpscr_din[0] = (ex7_fpscr_move[0] & ex7_upd_move) | (ex7_fpscr_pipe[0] & ex7_upd_pipe) | (ex7_new_excp & (~ex7_mtfsf) & (~ex7_mtfsfi));

   // only check the exception bits
   // ox
   // ux
   // zx
   // xx
   // vxsnan
   // vxisi
   // vxidi
   // vxzdz
   // vximx
   // vxvc
   // vxzdz
   assign ex7_new_excp = ((~ex7_mrg[3]) & ex7_fpscr_din[3]) | ((~ex7_mrg[4]) & ex7_fpscr_din[4]) | ((~ex7_mrg[5]) & ex7_fpscr_din[5]) | ((~ex7_mrg[6]) & ex7_fpscr_din[6]) | ((~ex7_mrg[7]) & ex7_fpscr_din[7]) | ((~ex7_mrg[8]) & ex7_fpscr_din[8]) | ((~ex7_mrg[9]) & ex7_fpscr_din[9]) | ((~ex7_mrg[10]) & ex7_fpscr_din[10]) | ((~ex7_mrg[11]) & ex7_fpscr_din[11]) | ((~ex7_mrg[12]) & ex7_fpscr_din[12]) | ((~ex7_mrg[21]) & ex7_fpscr_din[21]) | ((~ex7_mrg[22]) & ex7_fpscr_din[22]) | ((~ex7_mrg[23]) & ex7_fpscr_din[23]);		// vximx
   // vxvc

   ////##############################################
   ////# EX8 latches
   ////##############################################


   tri_rlmreg_p #(.WIDTH(28)) fpscr_th0_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[7]),
      .mpw1_b(mpw1_b[7]),
      .mpw2_b(mpw2_b[1]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex7_act),
      .scout(fpscr_th0_so),
      .scin(fpscr_th0_si),
      //-----------------
      .din({ ex7_fpscr_dfp_din[0:3],
             ex7_fpscr_din[0:23]}),
      .dout({fpscr_dfp_th0[0:3],		//LAT--
             fpscr_th0[0:23]})		//LAT--
   );


   tri_rlmreg_p #(.WIDTH(28)) fpscr_th1_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[7]),
      .mpw1_b(mpw1_b[7]),
      .mpw2_b(mpw2_b[1]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex7_act),		//ex7_th1_act, todo: act pin
      .scout(fpscr_th1_so),
      .scin(fpscr_th1_si),
      //-----------------
      .din({    ex7_fpscr_dfp_din[0:3],
                ex7_fpscr_din[0:23]}),
      .dout({   fpscr_dfp_th1[0:3],		//LAT--
                fpscr_th1[0:23]})		//LAT--
   );

   tri_rlmreg_p #(.WIDTH(4)) ex8_crf_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[7]),
      .mpw1_b(mpw1_b[7]),
      .mpw2_b(mpw2_b[1]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex7_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex8_crf_so),
      .scin(ex8_crf_si),
      //-----------------
      .din(  ex7_cr_fld[0:3]),
      .dout(  ex8_cr_fld[0:3])		//LAT--
   );

   assign f_scr_ex8_cr_fld[0:3] = ex8_cr_fld[0:3];		//output--   This is the first 4 bits of the fpscr used for speculative exceptions/cr val
   assign f_scr_ex8_fx_thread0[0:3] = fpscr_th0[0:3];		//output--
   assign f_scr_cpl_fx_thread0[0:3] = cfpscr_thr0_l2[32:35];		//output--  This is the completed version, used for async fp enabled

   assign f_scr_ex8_fx_thread1[0:3] = fpscr_th1[0:3];		//output--
   assign f_scr_cpl_fx_thread1[0:3] = cfpscr_thr1_l2[32:35];		//output--  This is the completed version, used for async fp enabled

   ////##############################################
   ////# read fpscr (mixed cycles)
   ////##############################################

   assign fpscr_rd_dat_dfp[0:3] = (ex6_cfpscr_thrx_cr[28:31]);		// write data to bit 20 is "0"

   assign fpscr_rd_dat[0:23] = (ex6_cfpscr_thrx_cr[32:55]);		// write data to bit 20 is "0"

   assign ex7_mrg_dfp[0:3] = (cfpscr_thrx_cr[28:31]);		// write data to bit 20 is "0"

   assign ex7_mrg[0:23] = (cfpscr_thrx_cr[32:55]);		// write data to bit 20 is "0"

   assign fpscr_rd_dat[24:31] = ex6_cfpscr_thrx_cr[56:63];

   assign f_scr_ex6_fpscr_rm_thr0[0:1] = cfpscr_thr0_l2[62:63];
   assign f_scr_ex6_fpscr_ee_thr0[0:4] = cfpscr_thr0_l2[56:60];
   assign f_scr_ex6_fpscr_ni_thr0      = cfpscr_thr0_l2[61];
   assign f_scr_ex6_fpscr_rm_thr1[0:1] = cfpscr_thr1_l2[62:63];
   assign f_scr_ex6_fpscr_ee_thr1[0:4] = cfpscr_thr1_l2[56:60];
   assign f_scr_ex6_fpscr_ni_thr1      = cfpscr_thr1_l2[61];

   assign f_scr_ex6_fpscr_rd_dat[0:31] = fpscr_rd_dat[0:31];
   assign f_scr_ex6_fpscr_rd_dat_dfp[0:3] = fpscr_rd_dat_dfp[0:3];

   assign f_scr_fpscr_ctrl_thr0 = cfpscr_thr0_l2[56:63];
   assign f_scr_fpscr_ctrl_thr1 = cfpscr_thr1_l2[56:63];

   ////##############################################
   ////# FPSCR History Array
   ////##############################################

   assign ex7_hfpscr_pipe[3] = ex7_ox_spec | (ex7_ox_pipe_v & f_rnd_ex7_flag_ox);		//ex7_mrg( 3)  or  --ox STICKY
   assign ex7_hfpscr_pipe[4] = ex7_ux_spec | (ex7_ux_pipe_v & f_rnd_ex7_flag_ux);		//ex7_mrg( 4)  or      --ux STICKY
   assign ex7_hfpscr_pipe[5] = ex7_flag_zx;		//ex7_mrg( 5) or   --sticky

   assign ex7_hfpscr_pipe[6] = (ex7_fi_spec) | (ex7_fi_pipe_v & f_rnd_ex7_flag_fi);		//(ex7_mrg( 6)                         ) or -- ex7_hfpscr_pipe(14); --sticky version of fi (XX)

   assign ex7_hfpscr_pipe[7] = ex7_flag_vxsnan;		//sticky
   assign ex7_hfpscr_pipe[8] = ex7_flag_vxisi;		//sticky
   assign ex7_hfpscr_pipe[9] = ex7_flag_vxidi;		//sticky
   assign ex7_hfpscr_pipe[10] = ex7_flag_vxzdz;		//sticky
   assign ex7_hfpscr_pipe[11] = ex7_flag_vximz;		//sticky
   assign ex7_hfpscr_pipe[12] = ex7_flag_vxvc;		//sticky

   //(ex7_mrg(13)   and     ex7_compare    ) or
   assign ex7_hfpscr_pipe[13] = (ex7_fr_spec) | (ex7_fr_pipe_v & f_rnd_ex7_flag_up);		//fr NOT sticky
   //(ex7_mrg(14)   and     ex7_compare   ) or
   assign ex7_hfpscr_pipe[14] = (ex7_fi_spec) | (ex7_fi_pipe_v & f_rnd_ex7_flag_fi);		//fi NOT sticky

   //(ex7_mrg(15)     and ex7_fprf_hold    ) or
   //(ex7_mrg(15)     and ex7_compare      ) or
   assign ex7_hfpscr_pipe[15] = (ex7_fprf_spec[0]) | (ex7_fprf_pipe_v & ex7_fprf_pipe[0]);		//FPRF C    NOT sticky

   //(ex7_mrg(16)     and ex7_fprf_hold    ) or
   assign ex7_hfpscr_pipe[16] = (ex7_fprf_spec[1]) | (ex7_fprf_pipe_v & ex7_fprf_pipe[1]);		//FPRF fpdd(lt)
   //(ex7_mrg(17)     and ex7_fprf_hold    ) or
   assign ex7_hfpscr_pipe[17] = (ex7_fprf_spec[2]) | (ex7_fprf_pipe_v & ex7_fprf_pipe[2]);		//FPRF fpcc(gt)
   //(ex7_mrg(18)     and ex7_fprf_hold    ) or
   assign ex7_hfpscr_pipe[18] = (ex7_fprf_spec[3]) | (ex7_fprf_pipe_v & ex7_fprf_pipe[3]);		//FPRF fpcc(eq)
   //(ex7_mrg(19)     and ex7_fprf_hold    ) or
   assign ex7_hfpscr_pipe[19] = (ex7_fprf_spec[4]) | (ex7_fprf_pipe_v & ex7_fprf_pipe[4]);		//FPRF fpcc(nan)

   assign ex7_hfpscr_pipe[20] = tidn;		// reseved bit <UNUSED>
   assign ex7_hfpscr_pipe[21] = tidn;		//ex7_mrg(21); -- VXSOFT  --sticky
   assign ex7_hfpscr_pipe[22] = ex7_flag_vxsqrt;		//ex7_mrg(22) or ex7_flag_vxsqrt ;--sticky
   assign ex7_hfpscr_pipe[23] = ex7_flag_vxcvi;		//ex7_mrg(23) or ex7_flag_vxcvi  ;--sticky

   //generic (addressable_ports    : positive $ 64; -- number of addressable register in this array
   //         addressbus_WIDTH     : positive $ 6;   -- WIDTH of the bus to address all ports (2^addressbus_WIDTH >= addressable_ports)
   //         port_bitwidth        : positive $ 64;     -- bitwidth of ports

   assign zeros[0:63] = {64{tidn}};

   //Write

   assign we0_thr0 = f_dcd_ex7_fpscr_wr & ex7_thread[0];
   assign we0_thr1 = f_dcd_ex7_fpscr_wr & ex7_thread[1];
   assign wa0[0:5] = f_dcd_ex7_fpscr_addr[0:5];
   assign di0[0:23] = {ex7_compare, ex7_fprf_hold, ex7_upd_pipe, ex7_hfpscr_pipe[3:23]};

   assign we1 = tidn;
   assign wa1 = {6{tidn}};
   assign di1 = {24{tidn}};

   //Read

   generate
      if (THREADS == 1)
      begin : oscr_val_thr1_1
         assign  re0_thr0 = cp_axu_i0_t1_v[0] & (cp_axu_i0_t0_t1_t == 3'b111);
         assign  re0_thr1 = tidn;
         assign  ra0_thr0[0:5] = cp_axu_i0_t0_t1_p;
         assign  ra0_thr1[0:5] = 6'b000000;
      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : oscr_val_thr2_1
         assign  re0_thr0 = cp_axu_i0_t1_v[0] & (cp_axu_i0_t0_t1_t == 3'b111);
         assign  re0_thr1 = cp_axu_i0_t1_v[1] & (cp_axu_i0_t1_t1_t == 3'b111);
         assign  ra0_thr0[0:5] = cp_axu_i0_t0_t1_p;
         assign  ra0_thr1[0:5] = cp_axu_i0_t1_t1_p;
      end
   endgenerate

   generate
      if (THREADS == 1)
      begin : oscr_val_thr1_2
         assign  re1_thr0 = cp_axu_i1_t1_v[0] & (cp_axu_i1_t0_t1_t == 3'b111);
         assign  re1_thr1 = tidn;
         assign  ra1_thr0[0:5] = cp_axu_i1_t0_t1_p;
         assign  ra1_thr1[0:5] = 6'b000000;
      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : oscr_val_thr2_2
         assign  re1_thr0 = cp_axu_i1_t1_v[0] & (cp_axu_i1_t0_t1_t == 3'b111);
         assign  re1_thr1 = cp_axu_i1_t1_v[1] & (cp_axu_i1_t1_t1_t == 3'b111);
         assign  ra1_thr0[0:5] = cp_axu_i1_t0_t1_p;
         assign  ra1_thr1[0:5] = cp_axu_i1_t1_t1_p;
      end
   endgenerate

   generate
      if (THREADS == 1)
      begin : oscr_hscr_arr_thr1

         assign  fwrite_thr0[00] = (wa0[1:5] == 5'b00000) & we0_thr0;
         assign  fwrite_thr0[01] = (wa0[1:5] == 5'b00001) & we0_thr0;
         assign  fwrite_thr0[02] = (wa0[1:5] == 5'b00010) & we0_thr0;
         assign  fwrite_thr0[03] = (wa0[1:5] == 5'b00011) & we0_thr0;
         assign  fwrite_thr0[04] = (wa0[1:5] == 5'b00100) & we0_thr0;
         assign  fwrite_thr0[05] = (wa0[1:5] == 5'b00101) & we0_thr0;
         assign  fwrite_thr0[06] = (wa0[1:5] == 5'b00110) & we0_thr0;
         assign  fwrite_thr0[07] = (wa0[1:5] == 5'b00111) & we0_thr0;
         assign  fwrite_thr0[08] = (wa0[1:5] == 5'b01000) & we0_thr0;
         assign  fwrite_thr0[09] = (wa0[1:5] == 5'b01001) & we0_thr0;
         assign  fwrite_thr0[10] = (wa0[1:5] == 5'b01010) & we0_thr0;
         assign  fwrite_thr0[11] = (wa0[1:5] == 5'b01011) & we0_thr0;
         assign  fwrite_thr0[12] = (wa0[1:5] == 5'b01100) & we0_thr0;
         assign  fwrite_thr0[13] = (wa0[1:5] == 5'b01101) & we0_thr0;
         assign  fwrite_thr0[14] = (wa0[1:5] == 5'b01110) & we0_thr0;
         assign  fwrite_thr0[15] = (wa0[1:5] == 5'b01111) & we0_thr0;
         assign  fwrite_thr0[16] = (wa0[1:5] == 5'b10000) & we0_thr0;
         assign  fwrite_thr0[17] = (wa0[1:5] == 5'b10001) & we0_thr0;
         assign  fwrite_thr0[18] = (wa0[1:5] == 5'b10010) & we0_thr0;
         assign  fwrite_thr0[19] = (wa0[1:5] == 5'b10011) & we0_thr0;
         assign  fwrite_thr0[20] = (wa0[1:5] == 5'b10100) & we0_thr0;
         assign  fwrite_thr0[21] = (wa0[1:5] == 5'b10101) & we0_thr0;
         assign  fwrite_thr0[22] = (wa0[1:5] == 5'b10110) & we0_thr0;
         assign  fwrite_thr0[23] = (wa0[1:5] == 5'b10111) & we0_thr0;
         assign  fwrite_thr0[24] = (wa0[1:5] == 5'b11000) & we0_thr0;
         assign  fwrite_thr0[25] = (wa0[1:5] == 5'b11001) & we0_thr0;
         assign  fwrite_thr0[26] = (wa0[1:5] == 5'b11010) & we0_thr0;
         assign  fwrite_thr0[27] = (wa0[1:5] == 5'b11011) & we0_thr0;
         assign  fwrite_thr0[28] = (wa0[1:5] == 5'b11100) & we0_thr0;
         assign  fwrite_thr0[29] = (wa0[1:5] == 5'b11101) & we0_thr0;
         assign  fwrite_thr0[30] = (wa0[1:5] == 5'b11110) & we0_thr0;
         assign  fwrite_thr0[31] = (wa0[1:5] == 5'b11111) & we0_thr0;




         assign  fwrite_thr0_b = (~fwrite_thr0);

         assign  fread0_thr0[00] = (ra0_thr0[1:5] == 5'b00000) & re0_thr0;
         assign  fread0_thr0[01] = (ra0_thr0[1:5] == 5'b00001) & re0_thr0;
         assign  fread0_thr0[02] = (ra0_thr0[1:5] == 5'b00010) & re0_thr0;
         assign  fread0_thr0[03] = (ra0_thr0[1:5] == 5'b00011) & re0_thr0;
         assign  fread0_thr0[04] = (ra0_thr0[1:5] == 5'b00100) & re0_thr0;
         assign  fread0_thr0[05] = (ra0_thr0[1:5] == 5'b00101) & re0_thr0;
         assign  fread0_thr0[06] = (ra0_thr0[1:5] == 5'b00110) & re0_thr0;
         assign  fread0_thr0[07] = (ra0_thr0[1:5] == 5'b00111) & re0_thr0;
         assign  fread0_thr0[08] = (ra0_thr0[1:5] == 5'b01000) & re0_thr0;
         assign  fread0_thr0[09] = (ra0_thr0[1:5] == 5'b01001) & re0_thr0;
         assign  fread0_thr0[10] = (ra0_thr0[1:5] == 5'b01010) & re0_thr0;
         assign  fread0_thr0[11] = (ra0_thr0[1:5] == 5'b01011) & re0_thr0;
         assign  fread0_thr0[12] = (ra0_thr0[1:5] == 5'b01100) & re0_thr0;
         assign  fread0_thr0[13] = (ra0_thr0[1:5] == 5'b01101) & re0_thr0;
         assign  fread0_thr0[14] = (ra0_thr0[1:5] == 5'b01110) & re0_thr0;
         assign  fread0_thr0[15] = (ra0_thr0[1:5] == 5'b01111) & re0_thr0;
         assign  fread0_thr0[16] = (ra0_thr0[1:5] == 5'b10000) & re0_thr0;
         assign  fread0_thr0[17] = (ra0_thr0[1:5] == 5'b10001) & re0_thr0;
         assign  fread0_thr0[18] = (ra0_thr0[1:5] == 5'b10010) & re0_thr0;
         assign  fread0_thr0[19] = (ra0_thr0[1:5] == 5'b10011) & re0_thr0;
         assign  fread0_thr0[20] = (ra0_thr0[1:5] == 5'b10100) & re0_thr0;
         assign  fread0_thr0[21] = (ra0_thr0[1:5] == 5'b10101) & re0_thr0;
         assign  fread0_thr0[22] = (ra0_thr0[1:5] == 5'b10110) & re0_thr0;
         assign  fread0_thr0[23] = (ra0_thr0[1:5] == 5'b10111) & re0_thr0;
         assign  fread0_thr0[24] = (ra0_thr0[1:5] == 5'b11000) & re0_thr0;
         assign  fread0_thr0[25] = (ra0_thr0[1:5] == 5'b11001) & re0_thr0;
         assign  fread0_thr0[26] = (ra0_thr0[1:5] == 5'b11010) & re0_thr0;
         assign  fread0_thr0[27] = (ra0_thr0[1:5] == 5'b11011) & re0_thr0;
         assign  fread0_thr0[28] = (ra0_thr0[1:5] == 5'b11100) & re0_thr0;
         assign  fread0_thr0[29] = (ra0_thr0[1:5] == 5'b11101) & re0_thr0;
         assign  fread0_thr0[30] = (ra0_thr0[1:5] == 5'b11110) & re0_thr0;
         assign  fread0_thr0[31] = (ra0_thr0[1:5] == 5'b11111) & re0_thr0;



         assign  fread1_thr0[00] = (ra1_thr0[1:5] == 5'b00000) & re1_thr0;
         assign  fread1_thr0[01] = (ra1_thr0[1:5] == 5'b00001) & re1_thr0;
         assign  fread1_thr0[02] = (ra1_thr0[1:5] == 5'b00010) & re1_thr0;
         assign  fread1_thr0[03] = (ra1_thr0[1:5] == 5'b00011) & re1_thr0;
         assign  fread1_thr0[04] = (ra1_thr0[1:5] == 5'b00100) & re1_thr0;
         assign  fread1_thr0[05] = (ra1_thr0[1:5] == 5'b00101) & re1_thr0;
         assign  fread1_thr0[06] = (ra1_thr0[1:5] == 5'b00110) & re1_thr0;
         assign  fread1_thr0[07] = (ra1_thr0[1:5] == 5'b00111) & re1_thr0;
         assign  fread1_thr0[08] = (ra1_thr0[1:5] == 5'b01000) & re1_thr0;
         assign  fread1_thr0[09] = (ra1_thr0[1:5] == 5'b01001) & re1_thr0;
         assign  fread1_thr0[10] = (ra1_thr0[1:5] == 5'b01010) & re1_thr0;
         assign  fread1_thr0[11] = (ra1_thr0[1:5] == 5'b01011) & re1_thr0;
         assign  fread1_thr0[12] = (ra1_thr0[1:5] == 5'b01100) & re1_thr0;
         assign  fread1_thr0[13] = (ra1_thr0[1:5] == 5'b01101) & re1_thr0;
         assign  fread1_thr0[14] = (ra1_thr0[1:5] == 5'b01110) & re1_thr0;
         assign  fread1_thr0[15] = (ra1_thr0[1:5] == 5'b01111) & re1_thr0;
         assign  fread1_thr0[16] = (ra1_thr0[1:5] == 5'b10000) & re1_thr0;
         assign  fread1_thr0[17] = (ra1_thr0[1:5] == 5'b10001) & re1_thr0;
         assign  fread1_thr0[18] = (ra1_thr0[1:5] == 5'b10010) & re1_thr0;
         assign  fread1_thr0[19] = (ra1_thr0[1:5] == 5'b10011) & re1_thr0;
         assign  fread1_thr0[20] = (ra1_thr0[1:5] == 5'b10100) & re1_thr0;
         assign  fread1_thr0[21] = (ra1_thr0[1:5] == 5'b10101) & re1_thr0;
         assign  fread1_thr0[22] = (ra1_thr0[1:5] == 5'b10110) & re1_thr0;
         assign  fread1_thr0[23] = (ra1_thr0[1:5] == 5'b10111) & re1_thr0;
         assign  fread1_thr0[24] = (ra1_thr0[1:5] == 5'b11000) & re1_thr0;
         assign  fread1_thr0[25] = (ra1_thr0[1:5] == 5'b11001) & re1_thr0;
         assign  fread1_thr0[26] = (ra1_thr0[1:5] == 5'b11010) & re1_thr0;
         assign  fread1_thr0[27] = (ra1_thr0[1:5] == 5'b11011) & re1_thr0;
         assign  fread1_thr0[28] = (ra1_thr0[1:5] == 5'b11100) & re1_thr0;
         assign  fread1_thr0[29] = (ra1_thr0[1:5] == 5'b11101) & re1_thr0;
         assign  fread1_thr0[30] = (ra1_thr0[1:5] == 5'b11110) & re1_thr0;
         assign  fread1_thr0[31] = (ra1_thr0[1:5] == 5'b11111) & re1_thr0;




         begin : xhdl1
           // genvar              i;
            for (i = 0; i <= 31; i = i + 1)
            begin : writeport_hfpscr_thr0
               assign  hfpscr_thr0_din[24 * i:(24 * i) + 23] = ((hfpscr_thr0_q[24 * i:(24 * i) + 23] & {24{fwrite_thr0_b[i]}}) |
                                                                (di0 & {24{fwrite_thr0[i]}}));
            end
         end


         tri_rlmreg_p #(.WIDTH(768 + 64)) hfpscr_thr0_lat(
            .force_t(force_t),
            .d_mode(tiup),
            .delay_lclkr(delay_lclkr[7]),
            .mpw1_b(mpw1_b[7]),
            .mpw2_b(mpw2_b[1]),
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(tiup),
            .thold_b(thold_0_b),
            .sg(sg_0),
            .scout(hfpscr_thr0_so),
            .scin(hfpscr_thr0_si),
            //-----------------
            .din({     hfpscr_thr0_din,
		       fread0_thr0,
                       fread1_thr0 }),

            //-----------------
            .dout({  hfpscr_thr0_q,
		     fread0_thr0_q,
                     fread1_thr0_q })
         );

	 assign        hfpscr_thr0_si[0:831] = {hfpscr_thr0_so[1:831], hfpscr_thr0_so[0]};// todo


         assign do0_thr0 = ((hfpscr_thr0_q[24 * 00:(24 * 00) + 23] & {24{fread0_thr0_q[00]}}) |
                            (hfpscr_thr0_q[24 * 01:(24 * 01) + 23] & {24{fread0_thr0_q[01]}}) |
                            (hfpscr_thr0_q[24 * 02:(24 * 02) + 23] & {24{fread0_thr0_q[02]}}) |
                            (hfpscr_thr0_q[24 * 03:(24 * 03) + 23] & {24{fread0_thr0_q[03]}}) |
                            (hfpscr_thr0_q[24 * 04:(24 * 04) + 23] & {24{fread0_thr0_q[04]}}) |
                            (hfpscr_thr0_q[24 * 05:(24 * 05) + 23] & {24{fread0_thr0_q[05]}}) |
                            (hfpscr_thr0_q[24 * 06:(24 * 06) + 23] & {24{fread0_thr0_q[06]}}) |
                            (hfpscr_thr0_q[24 * 07:(24 * 07) + 23] & {24{fread0_thr0_q[07]}}) |
                            (hfpscr_thr0_q[24 * 08:(24 * 08) + 23] & {24{fread0_thr0_q[08]}}) |
                            (hfpscr_thr0_q[24 * 09:(24 * 09) + 23] & {24{fread0_thr0_q[09]}}) |
                            (hfpscr_thr0_q[24 * 10:(24 * 10) + 23] & {24{fread0_thr0_q[10]}}) |
                            (hfpscr_thr0_q[24 * 11:(24 * 11) + 23] & {24{fread0_thr0_q[11]}}) |
                            (hfpscr_thr0_q[24 * 12:(24 * 12) + 23] & {24{fread0_thr0_q[12]}}) |
                            (hfpscr_thr0_q[24 * 13:(24 * 13) + 23] & {24{fread0_thr0_q[13]}}) |
                            (hfpscr_thr0_q[24 * 14:(24 * 14) + 23] & {24{fread0_thr0_q[14]}}) |
                            (hfpscr_thr0_q[24 * 15:(24 * 15) + 23] & {24{fread0_thr0_q[15]}}) |
                            (hfpscr_thr0_q[24 * 16:(24 * 16) + 23] & {24{fread0_thr0_q[16]}}) |
                            (hfpscr_thr0_q[24 * 17:(24 * 17) + 23] & {24{fread0_thr0_q[17]}}) |
                            (hfpscr_thr0_q[24 * 18:(24 * 18) + 23] & {24{fread0_thr0_q[18]}}) |
                            (hfpscr_thr0_q[24 * 19:(24 * 19) + 23] & {24{fread0_thr0_q[19]}}) |
                            (hfpscr_thr0_q[24 * 20:(24 * 20) + 23] & {24{fread0_thr0_q[20]}}) |
                            (hfpscr_thr0_q[24 * 21:(24 * 21) + 23] & {24{fread0_thr0_q[21]}}) |
                            (hfpscr_thr0_q[24 * 22:(24 * 22) + 23] & {24{fread0_thr0_q[22]}}) |
                            (hfpscr_thr0_q[24 * 23:(24 * 23) + 23] & {24{fread0_thr0_q[23]}}) |
                            (hfpscr_thr0_q[24 * 24:(24 * 24) + 23] & {24{fread0_thr0_q[24]}}) |
                            (hfpscr_thr0_q[24 * 25:(24 * 25) + 23] & {24{fread0_thr0_q[25]}}) |
                            (hfpscr_thr0_q[24 * 26:(24 * 26) + 23] & {24{fread0_thr0_q[26]}}) |
                            (hfpscr_thr0_q[24 * 27:(24 * 27) + 23] & {24{fread0_thr0_q[27]}}) |
                            (hfpscr_thr0_q[24 * 28:(24 * 28) + 23] & {24{fread0_thr0_q[28]}}) |
                            (hfpscr_thr0_q[24 * 29:(24 * 29) + 23] & {24{fread0_thr0_q[29]}}) |
                            (hfpscr_thr0_q[24 * 30:(24 * 30) + 23] & {24{fread0_thr0_q[30]}}) |
                            (hfpscr_thr0_q[24 * 31:(24 * 31) + 23] & {24{fread0_thr0_q[31]}}));




        assign do1_thr0 =  ((hfpscr_thr0_q[24 * 00:(24 * 00) + 23] & {24{fread1_thr0_q[00]}}) |
                            (hfpscr_thr0_q[24 * 01:(24 * 01) + 23] & {24{fread1_thr0_q[01]}}) |
                            (hfpscr_thr0_q[24 * 02:(24 * 02) + 23] & {24{fread1_thr0_q[02]}}) |
                            (hfpscr_thr0_q[24 * 03:(24 * 03) + 23] & {24{fread1_thr0_q[03]}}) |
                            (hfpscr_thr0_q[24 * 04:(24 * 04) + 23] & {24{fread1_thr0_q[04]}}) |
                            (hfpscr_thr0_q[24 * 05:(24 * 05) + 23] & {24{fread1_thr0_q[05]}}) |
                            (hfpscr_thr0_q[24 * 06:(24 * 06) + 23] & {24{fread1_thr0_q[06]}}) |
                            (hfpscr_thr0_q[24 * 07:(24 * 07) + 23] & {24{fread1_thr0_q[07]}}) |
                            (hfpscr_thr0_q[24 * 08:(24 * 08) + 23] & {24{fread1_thr0_q[08]}}) |
                            (hfpscr_thr0_q[24 * 09:(24 * 09) + 23] & {24{fread1_thr0_q[09]}}) |
                            (hfpscr_thr0_q[24 * 10:(24 * 10) + 23] & {24{fread1_thr0_q[10]}}) |
                            (hfpscr_thr0_q[24 * 11:(24 * 11) + 23] & {24{fread1_thr0_q[11]}}) |
                            (hfpscr_thr0_q[24 * 12:(24 * 12) + 23] & {24{fread1_thr0_q[12]}}) |
                            (hfpscr_thr0_q[24 * 13:(24 * 13) + 23] & {24{fread1_thr0_q[13]}}) |
                            (hfpscr_thr0_q[24 * 14:(24 * 14) + 23] & {24{fread1_thr0_q[14]}}) |
                            (hfpscr_thr0_q[24 * 15:(24 * 15) + 23] & {24{fread1_thr0_q[15]}}) |
                            (hfpscr_thr0_q[24 * 16:(24 * 16) + 23] & {24{fread1_thr0_q[16]}}) |
                            (hfpscr_thr0_q[24 * 17:(24 * 17) + 23] & {24{fread1_thr0_q[17]}}) |
                            (hfpscr_thr0_q[24 * 18:(24 * 18) + 23] & {24{fread1_thr0_q[18]}}) |
                            (hfpscr_thr0_q[24 * 19:(24 * 19) + 23] & {24{fread1_thr0_q[19]}}) |
                            (hfpscr_thr0_q[24 * 20:(24 * 20) + 23] & {24{fread1_thr0_q[20]}}) |
                            (hfpscr_thr0_q[24 * 21:(24 * 21) + 23] & {24{fread1_thr0_q[21]}}) |
                            (hfpscr_thr0_q[24 * 22:(24 * 22) + 23] & {24{fread1_thr0_q[22]}}) |
                            (hfpscr_thr0_q[24 * 23:(24 * 23) + 23] & {24{fread1_thr0_q[23]}}) |
                            (hfpscr_thr0_q[24 * 24:(24 * 24) + 23] & {24{fread1_thr0_q[24]}}) |
                            (hfpscr_thr0_q[24 * 25:(24 * 25) + 23] & {24{fread1_thr0_q[25]}}) |
                            (hfpscr_thr0_q[24 * 26:(24 * 26) + 23] & {24{fread1_thr0_q[26]}}) |
                            (hfpscr_thr0_q[24 * 27:(24 * 27) + 23] & {24{fread1_thr0_q[27]}}) |
                            (hfpscr_thr0_q[24 * 28:(24 * 28) + 23] & {24{fread1_thr0_q[28]}}) |
                            (hfpscr_thr0_q[24 * 29:(24 * 29) + 23] & {24{fread1_thr0_q[29]}}) |
                            (hfpscr_thr0_q[24 * 30:(24 * 30) + 23] & {24{fread1_thr0_q[30]}}) |
                            (hfpscr_thr0_q[24 * 31:(24 * 31) + 23] & {24{fread1_thr0_q[31]}}));



         // thread 1:

         assign  fwrite_thr1 = {32{1'b0}};

         assign  fwrite_thr1_b = (~fwrite_thr1);

         assign  fread0_thr1 = {32{1'b0}};

         assign  fread1_thr1 = {32{1'b0}};

         assign  hfpscr_thr1_din = {768{1'b0}};

         assign  do0_thr1 = {24{1'b0}};
         assign  do1_thr1 = {24{1'b0}};
      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : oscr_hscr_arr_thr2
         // FPSCR History Array
         //   hscr_arr_thr0:  entity tri.tri_64xxx_2r2w generic map ( expand_type => expand_type)
         //   port map (
         //      clk                            => nclk                       ,
         //      re0                            => re0_thr0                   ,
         //      ra0                            => ra0_thr0                   ,
         //      do0                            => do0_thr0                   ,

         //      re1                            => re1_thr0                   ,
         //      ra1                            => ra1_thr0                   ,
         //      do1                            => do1_thr0                   ,

         //      we0                            => we0_thr0                   ,
         //      wa0                            => wa0(0 to 5)                ,
         //      di0                            => di0(0 to 63)               ,
         //      we1                            => we1                        ,
         //      wa1                            => wa1(0 to 5)                ,
         //      di1                            => di1(0 to 63)               );

         //   hscr_arr_thr1:  entity tri.tri_64xxx_2r2w generic map ( expand_type => expand_type)
         //   port map (
         //      clk                            => nclk                       ,
         //      re0                            => re0_thr1                   ,
         //      ra0                            => ra0_thr1                   ,
         //      do0                            => do0_thr1                   ,

         //      re1                            => re1_thr1                   ,
         //      ra1                            => ra1_thr1                   ,
         //      do1                            => do1_thr1                   ,

         //      we0                            => we0_thr1                   ,
         //      wa0                            => wa0(0 to 5)                ,
         //      di0                            => di0(0 to 63)               ,
         //      we1                            => we1                        ,
         //      wa1                            => wa1(0 to 5)                ,
         //      di1                            => di1(0 to 63)               );

         assign  fwrite_thr0[00] = (wa0[1:5] == 5'b00000) & we0_thr0;
         assign  fwrite_thr0[01] = (wa0[1:5] == 5'b00001) & we0_thr0;
         assign  fwrite_thr0[02] = (wa0[1:5] == 5'b00010) & we0_thr0;
         assign  fwrite_thr0[03] = (wa0[1:5] == 5'b00011) & we0_thr0;
         assign  fwrite_thr0[04] = (wa0[1:5] == 5'b00100) & we0_thr0;
         assign  fwrite_thr0[05] = (wa0[1:5] == 5'b00101) & we0_thr0;
         assign  fwrite_thr0[06] = (wa0[1:5] == 5'b00110) & we0_thr0;
         assign  fwrite_thr0[07] = (wa0[1:5] == 5'b00111) & we0_thr0;
         assign  fwrite_thr0[08] = (wa0[1:5] == 5'b01000) & we0_thr0;
         assign  fwrite_thr0[09] = (wa0[1:5] == 5'b01001) & we0_thr0;
         assign  fwrite_thr0[10] = (wa0[1:5] == 5'b01010) & we0_thr0;
         assign  fwrite_thr0[11] = (wa0[1:5] == 5'b01011) & we0_thr0;
         assign  fwrite_thr0[12] = (wa0[1:5] == 5'b01100) & we0_thr0;
         assign  fwrite_thr0[13] = (wa0[1:5] == 5'b01101) & we0_thr0;
         assign  fwrite_thr0[14] = (wa0[1:5] == 5'b01110) & we0_thr0;
         assign  fwrite_thr0[15] = (wa0[1:5] == 5'b01111) & we0_thr0;
         assign  fwrite_thr0[16] = (wa0[1:5] == 5'b10000) & we0_thr0;
         assign  fwrite_thr0[17] = (wa0[1:5] == 5'b10001) & we0_thr0;
         assign  fwrite_thr0[18] = (wa0[1:5] == 5'b10010) & we0_thr0;
         assign  fwrite_thr0[19] = (wa0[1:5] == 5'b10011) & we0_thr0;
         assign  fwrite_thr0[20] = (wa0[1:5] == 5'b10100) & we0_thr0;
         assign  fwrite_thr0[21] = (wa0[1:5] == 5'b10101) & we0_thr0;
         assign  fwrite_thr0[22] = (wa0[1:5] == 5'b10110) & we0_thr0;
         assign  fwrite_thr0[23] = (wa0[1:5] == 5'b10111) & we0_thr0;

         assign  fwrite_thr0_b = (~fwrite_thr0);
          assign  fread0_thr0[00] = (ra0_thr0[1:5] == 5'b00000) & re0_thr0;
         assign  fread0_thr0[01] = (ra0_thr0[1:5] == 5'b00001) & re0_thr0;
         assign  fread0_thr0[02] = (ra0_thr0[1:5] == 5'b00010) & re0_thr0;
         assign  fread0_thr0[03] = (ra0_thr0[1:5] == 5'b00011) & re0_thr0;
         assign  fread0_thr0[04] = (ra0_thr0[1:5] == 5'b00100) & re0_thr0;
         assign  fread0_thr0[05] = (ra0_thr0[1:5] == 5'b00101) & re0_thr0;
         assign  fread0_thr0[06] = (ra0_thr0[1:5] == 5'b00110) & re0_thr0;
         assign  fread0_thr0[07] = (ra0_thr0[1:5] == 5'b00111) & re0_thr0;
         assign  fread0_thr0[08] = (ra0_thr0[1:5] == 5'b01000) & re0_thr0;
         assign  fread0_thr0[09] = (ra0_thr0[1:5] == 5'b01001) & re0_thr0;
         assign  fread0_thr0[10] = (ra0_thr0[1:5] == 5'b01010) & re0_thr0;
         assign  fread0_thr0[11] = (ra0_thr0[1:5] == 5'b01011) & re0_thr0;
         assign  fread0_thr0[12] = (ra0_thr0[1:5] == 5'b01100) & re0_thr0;
         assign  fread0_thr0[13] = (ra0_thr0[1:5] == 5'b01101) & re0_thr0;
         assign  fread0_thr0[14] = (ra0_thr0[1:5] == 5'b01110) & re0_thr0;
         assign  fread0_thr0[15] = (ra0_thr0[1:5] == 5'b01111) & re0_thr0;
         assign  fread0_thr0[16] = (ra0_thr0[1:5] == 5'b10000) & re0_thr0;
         assign  fread0_thr0[17] = (ra0_thr0[1:5] == 5'b10001) & re0_thr0;
         assign  fread0_thr0[18] = (ra0_thr0[1:5] == 5'b10010) & re0_thr0;
         assign  fread0_thr0[19] = (ra0_thr0[1:5] == 5'b10011) & re0_thr0;
         assign  fread0_thr0[20] = (ra0_thr0[1:5] == 5'b10100) & re0_thr0;
         assign  fread0_thr0[21] = (ra0_thr0[1:5] == 5'b10101) & re0_thr0;
         assign  fread0_thr0[22] = (ra0_thr0[1:5] == 5'b10110) & re0_thr0;
         assign  fread0_thr0[23] = (ra0_thr0[1:5] == 5'b10111) & re0_thr0;

         assign  fread0_thr0[24:31] = {8{tidn}};



         assign  fread1_thr0[00] = (ra1_thr0[1:5] == 5'b00000) & re1_thr0;
         assign  fread1_thr0[01] = (ra1_thr0[1:5] == 5'b00001) & re1_thr0;
         assign  fread1_thr0[02] = (ra1_thr0[1:5] == 5'b00010) & re1_thr0;
         assign  fread1_thr0[03] = (ra1_thr0[1:5] == 5'b00011) & re1_thr0;
         assign  fread1_thr0[04] = (ra1_thr0[1:5] == 5'b00100) & re1_thr0;
         assign  fread1_thr0[05] = (ra1_thr0[1:5] == 5'b00101) & re1_thr0;
         assign  fread1_thr0[06] = (ra1_thr0[1:5] == 5'b00110) & re1_thr0;
         assign  fread1_thr0[07] = (ra1_thr0[1:5] == 5'b00111) & re1_thr0;
         assign  fread1_thr0[08] = (ra1_thr0[1:5] == 5'b01000) & re1_thr0;
         assign  fread1_thr0[09] = (ra1_thr0[1:5] == 5'b01001) & re1_thr0;
         assign  fread1_thr0[10] = (ra1_thr0[1:5] == 5'b01010) & re1_thr0;
         assign  fread1_thr0[11] = (ra1_thr0[1:5] == 5'b01011) & re1_thr0;
         assign  fread1_thr0[12] = (ra1_thr0[1:5] == 5'b01100) & re1_thr0;
         assign  fread1_thr0[13] = (ra1_thr0[1:5] == 5'b01101) & re1_thr0;
         assign  fread1_thr0[14] = (ra1_thr0[1:5] == 5'b01110) & re1_thr0;
         assign  fread1_thr0[15] = (ra1_thr0[1:5] == 5'b01111) & re1_thr0;
         assign  fread1_thr0[16] = (ra1_thr0[1:5] == 5'b10000) & re1_thr0;
         assign  fread1_thr0[17] = (ra1_thr0[1:5] == 5'b10001) & re1_thr0;
         assign  fread1_thr0[18] = (ra1_thr0[1:5] == 5'b10010) & re1_thr0;
         assign  fread1_thr0[19] = (ra1_thr0[1:5] == 5'b10011) & re1_thr0;
         assign  fread1_thr0[20] = (ra1_thr0[1:5] == 5'b10100) & re1_thr0;
         assign  fread1_thr0[21] = (ra1_thr0[1:5] == 5'b10101) & re1_thr0;
         assign  fread1_thr0[22] = (ra1_thr0[1:5] == 5'b10110) & re1_thr0;
         assign  fread1_thr0[23] = (ra1_thr0[1:5] == 5'b10111) & re1_thr0;

         assign  fread1_thr0[24:31] = {8{tidn}};




         begin : xhdl2
          //  genvar              i;
            for (i = 0; i <= 23; i = i + 1)
            begin : writeport_hfpscr_thr0
               assign  hfpscr_thr0_din[24 * i:(24 * i) + 23] = ((hfpscr_thr0_q[24 * i:(24 * i) + 23] & {24{fwrite_thr0_b[i]}}) |
                                                                (di0 & {24{fwrite_thr0[i]}}));
            end
         end


         tri_rlmreg_p #(.WIDTH(576 + 64)) hfpscr_thr0_lat(
            .force_t(force_t),
            .d_mode(tiup),
            .delay_lclkr(delay_lclkr[7]),
            .mpw1_b(mpw1_b[7]),
            .mpw2_b(mpw2_b[1]),
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(tiup),
            .thold_b(thold_0_b),
            .sg(sg_0),
	    .scout(hfpscr_thr0_so[0:639]),
            .scin(hfpscr_thr0_si[0:639]),
            //-----------------
            .din({  hfpscr_thr0_din[0:575],
		    fread0_thr0,
                    fread1_thr0 }),

            //-----------------
            .dout({  hfpscr_thr0_q[0:575],
		     fread0_thr0_q,
                     fread1_thr0_q })
         );

	 assign        hfpscr_thr0_din[576:767] = {192{tidn}};
	 assign        hfpscr_thr0_q[576:767] = {192{tidn}};

	 assign        hfpscr_thr0_si[0:831] = {hfpscr_thr0_so[1:831], hfpscr_thr0_so[0]};// todo

      assign do0_thr0 = ((hfpscr_thr0_q[24 * 00:(24 * 00) + 23] & {24{fread0_thr0_q[00]}}) |
                            (hfpscr_thr0_q[24 * 01:(24 * 01) + 23] & {24{fread0_thr0_q[01]}}) |
                            (hfpscr_thr0_q[24 * 02:(24 * 02) + 23] & {24{fread0_thr0_q[02]}}) |
                            (hfpscr_thr0_q[24 * 03:(24 * 03) + 23] & {24{fread0_thr0_q[03]}}) |
                            (hfpscr_thr0_q[24 * 04:(24 * 04) + 23] & {24{fread0_thr0_q[04]}}) |
                            (hfpscr_thr0_q[24 * 05:(24 * 05) + 23] & {24{fread0_thr0_q[05]}}) |
                            (hfpscr_thr0_q[24 * 06:(24 * 06) + 23] & {24{fread0_thr0_q[06]}}) |
                            (hfpscr_thr0_q[24 * 07:(24 * 07) + 23] & {24{fread0_thr0_q[07]}}) |
                            (hfpscr_thr0_q[24 * 08:(24 * 08) + 23] & {24{fread0_thr0_q[08]}}) |
                            (hfpscr_thr0_q[24 * 09:(24 * 09) + 23] & {24{fread0_thr0_q[09]}}) |
                            (hfpscr_thr0_q[24 * 10:(24 * 10) + 23] & {24{fread0_thr0_q[10]}}) |
                            (hfpscr_thr0_q[24 * 11:(24 * 11) + 23] & {24{fread0_thr0_q[11]}}) |
                            (hfpscr_thr0_q[24 * 12:(24 * 12) + 23] & {24{fread0_thr0_q[12]}}) |
                            (hfpscr_thr0_q[24 * 13:(24 * 13) + 23] & {24{fread0_thr0_q[13]}}) |
                            (hfpscr_thr0_q[24 * 14:(24 * 14) + 23] & {24{fread0_thr0_q[14]}}) |
                            (hfpscr_thr0_q[24 * 15:(24 * 15) + 23] & {24{fread0_thr0_q[15]}}) |
                            (hfpscr_thr0_q[24 * 16:(24 * 16) + 23] & {24{fread0_thr0_q[16]}}) |
                            (hfpscr_thr0_q[24 * 17:(24 * 17) + 23] & {24{fread0_thr0_q[17]}}) |
                            (hfpscr_thr0_q[24 * 18:(24 * 18) + 23] & {24{fread0_thr0_q[18]}}) |
                            (hfpscr_thr0_q[24 * 19:(24 * 19) + 23] & {24{fread0_thr0_q[19]}}) |
                            (hfpscr_thr0_q[24 * 20:(24 * 20) + 23] & {24{fread0_thr0_q[20]}}) |
                            (hfpscr_thr0_q[24 * 21:(24 * 21) + 23] & {24{fread0_thr0_q[21]}}) |
                            (hfpscr_thr0_q[24 * 22:(24 * 22) + 23] & {24{fread0_thr0_q[22]}}) |
                            (hfpscr_thr0_q[24 * 23:(24 * 23) + 23] & {24{fread0_thr0_q[23]}}));




        assign do1_thr0 =  ((hfpscr_thr0_q[24 * 00:(24 * 00) + 23] & {24{fread1_thr0_q[00]}}) |
                            (hfpscr_thr0_q[24 * 01:(24 * 01) + 23] & {24{fread1_thr0_q[01]}}) |
                            (hfpscr_thr0_q[24 * 02:(24 * 02) + 23] & {24{fread1_thr0_q[02]}}) |
                            (hfpscr_thr0_q[24 * 03:(24 * 03) + 23] & {24{fread1_thr0_q[03]}}) |
                            (hfpscr_thr0_q[24 * 04:(24 * 04) + 23] & {24{fread1_thr0_q[04]}}) |
                            (hfpscr_thr0_q[24 * 05:(24 * 05) + 23] & {24{fread1_thr0_q[05]}}) |
                            (hfpscr_thr0_q[24 * 06:(24 * 06) + 23] & {24{fread1_thr0_q[06]}}) |
                            (hfpscr_thr0_q[24 * 07:(24 * 07) + 23] & {24{fread1_thr0_q[07]}}) |
                            (hfpscr_thr0_q[24 * 08:(24 * 08) + 23] & {24{fread1_thr0_q[08]}}) |
                            (hfpscr_thr0_q[24 * 09:(24 * 09) + 23] & {24{fread1_thr0_q[09]}}) |
                            (hfpscr_thr0_q[24 * 10:(24 * 10) + 23] & {24{fread1_thr0_q[10]}}) |
                            (hfpscr_thr0_q[24 * 11:(24 * 11) + 23] & {24{fread1_thr0_q[11]}}) |
                            (hfpscr_thr0_q[24 * 12:(24 * 12) + 23] & {24{fread1_thr0_q[12]}}) |
                            (hfpscr_thr0_q[24 * 13:(24 * 13) + 23] & {24{fread1_thr0_q[13]}}) |
                            (hfpscr_thr0_q[24 * 14:(24 * 14) + 23] & {24{fread1_thr0_q[14]}}) |
                            (hfpscr_thr0_q[24 * 15:(24 * 15) + 23] & {24{fread1_thr0_q[15]}}) |
                            (hfpscr_thr0_q[24 * 16:(24 * 16) + 23] & {24{fread1_thr0_q[16]}}) |
                            (hfpscr_thr0_q[24 * 17:(24 * 17) + 23] & {24{fread1_thr0_q[17]}}) |
                            (hfpscr_thr0_q[24 * 18:(24 * 18) + 23] & {24{fread1_thr0_q[18]}}) |
                            (hfpscr_thr0_q[24 * 19:(24 * 19) + 23] & {24{fread1_thr0_q[19]}}) |
                            (hfpscr_thr0_q[24 * 20:(24 * 20) + 23] & {24{fread1_thr0_q[20]}}) |
                            (hfpscr_thr0_q[24 * 21:(24 * 21) + 23] & {24{fread1_thr0_q[21]}}) |
                            (hfpscr_thr0_q[24 * 22:(24 * 22) + 23] & {24{fread1_thr0_q[22]}}) |
                            (hfpscr_thr0_q[24 * 23:(24 * 23) + 23] & {24{fread1_thr0_q[23]}}));



         // thread 1:
         assign  fwrite_thr1[00] = (wa0[1:5] == 5'b00000) & we0_thr1;
         assign  fwrite_thr1[01] = (wa0[1:5] == 5'b00001) & we0_thr1;
         assign  fwrite_thr1[02] = (wa0[1:5] == 5'b00010) & we0_thr1;
         assign  fwrite_thr1[03] = (wa0[1:5] == 5'b00011) & we0_thr1;
         assign  fwrite_thr1[04] = (wa0[1:5] == 5'b00100) & we0_thr1;
         assign  fwrite_thr1[05] = (wa0[1:5] == 5'b00101) & we0_thr1;
         assign  fwrite_thr1[06] = (wa0[1:5] == 5'b00110) & we0_thr1;
         assign  fwrite_thr1[07] = (wa0[1:5] == 5'b00111) & we0_thr1;
         assign  fwrite_thr1[08] = (wa0[1:5] == 5'b01000) & we0_thr1;
         assign  fwrite_thr1[09] = (wa0[1:5] == 5'b01001) & we0_thr1;
         assign  fwrite_thr1[10] = (wa0[1:5] == 5'b01010) & we0_thr1;
         assign  fwrite_thr1[11] = (wa0[1:5] == 5'b01011) & we0_thr1;
         assign  fwrite_thr1[12] = (wa0[1:5] == 5'b01100) & we0_thr1;
         assign  fwrite_thr1[13] = (wa0[1:5] == 5'b01101) & we0_thr1;
         assign  fwrite_thr1[14] = (wa0[1:5] == 5'b01110) & we0_thr1;
         assign  fwrite_thr1[15] = (wa0[1:5] == 5'b01111) & we0_thr1;
         assign  fwrite_thr1[16] = (wa0[1:5] == 5'b10000) & we0_thr1;
         assign  fwrite_thr1[17] = (wa0[1:5] == 5'b10001) & we0_thr1;
         assign  fwrite_thr1[18] = (wa0[1:5] == 5'b10010) & we0_thr1;
         assign  fwrite_thr1[19] = (wa0[1:5] == 5'b10011) & we0_thr1;
         assign  fwrite_thr1[20] = (wa0[1:5] == 5'b10100) & we0_thr1;
         assign  fwrite_thr1[21] = (wa0[1:5] == 5'b10101) & we0_thr1;
         assign  fwrite_thr1[22] = (wa0[1:5] == 5'b10110) & we0_thr1;
         assign  fwrite_thr1[23] = (wa0[1:5] == 5'b10111) & we0_thr1;

         assign  fwrite_thr1_b = (~fwrite_thr1);

         assign  fread0_thr1[00] = (ra0_thr1[1:5] == 5'b00000) & re0_thr1;
         assign  fread0_thr1[01] = (ra0_thr1[1:5] == 5'b00001) & re0_thr1;
         assign  fread0_thr1[02] = (ra0_thr1[1:5] == 5'b00010) & re0_thr1;
         assign  fread0_thr1[03] = (ra0_thr1[1:5] == 5'b00011) & re0_thr1;
         assign  fread0_thr1[04] = (ra0_thr1[1:5] == 5'b00100) & re0_thr1;
         assign  fread0_thr1[05] = (ra0_thr1[1:5] == 5'b00101) & re0_thr1;
         assign  fread0_thr1[06] = (ra0_thr1[1:5] == 5'b00110) & re0_thr1;
         assign  fread0_thr1[07] = (ra0_thr1[1:5] == 5'b00111) & re0_thr1;
         assign  fread0_thr1[08] = (ra0_thr1[1:5] == 5'b01000) & re0_thr1;
         assign  fread0_thr1[09] = (ra0_thr1[1:5] == 5'b01001) & re0_thr1;
         assign  fread0_thr1[10] = (ra0_thr1[1:5] == 5'b01010) & re0_thr1;
         assign  fread0_thr1[11] = (ra0_thr1[1:5] == 5'b01011) & re0_thr1;
         assign  fread0_thr1[12] = (ra0_thr1[1:5] == 5'b01100) & re0_thr1;
         assign  fread0_thr1[13] = (ra0_thr1[1:5] == 5'b01101) & re0_thr1;
         assign  fread0_thr1[14] = (ra0_thr1[1:5] == 5'b01110) & re0_thr1;
         assign  fread0_thr1[15] = (ra0_thr1[1:5] == 5'b01111) & re0_thr1;
         assign  fread0_thr1[16] = (ra0_thr1[1:5] == 5'b10000) & re0_thr1;
         assign  fread0_thr1[17] = (ra0_thr1[1:5] == 5'b10001) & re0_thr1;
         assign  fread0_thr1[18] = (ra0_thr1[1:5] == 5'b10010) & re0_thr1;
         assign  fread0_thr1[19] = (ra0_thr1[1:5] == 5'b10011) & re0_thr1;
         assign  fread0_thr1[20] = (ra0_thr1[1:5] == 5'b10100) & re0_thr1;
         assign  fread0_thr1[21] = (ra0_thr1[1:5] == 5'b10101) & re0_thr1;
         assign  fread0_thr1[22] = (ra0_thr1[1:5] == 5'b10110) & re0_thr1;
         assign  fread0_thr1[23] = (ra0_thr1[1:5] == 5'b10111) & re0_thr1;



         assign  fread1_thr1[00] = (ra1_thr1[1:5] == 5'b00000) & re1_thr1;
         assign  fread1_thr1[01] = (ra1_thr1[1:5] == 5'b00001) & re1_thr1;
         assign  fread1_thr1[02] = (ra1_thr1[1:5] == 5'b00010) & re1_thr1;
         assign  fread1_thr1[03] = (ra1_thr1[1:5] == 5'b00011) & re1_thr1;
         assign  fread1_thr1[04] = (ra1_thr1[1:5] == 5'b00100) & re1_thr1;
         assign  fread1_thr1[05] = (ra1_thr1[1:5] == 5'b00101) & re1_thr1;
         assign  fread1_thr1[06] = (ra1_thr1[1:5] == 5'b00110) & re1_thr1;
         assign  fread1_thr1[07] = (ra1_thr1[1:5] == 5'b00111) & re1_thr1;
         assign  fread1_thr1[08] = (ra1_thr1[1:5] == 5'b01000) & re1_thr1;
         assign  fread1_thr1[09] = (ra1_thr1[1:5] == 5'b01001) & re1_thr1;
         assign  fread1_thr1[10] = (ra1_thr1[1:5] == 5'b01010) & re1_thr1;
         assign  fread1_thr1[11] = (ra1_thr1[1:5] == 5'b01011) & re1_thr1;
         assign  fread1_thr1[12] = (ra1_thr1[1:5] == 5'b01100) & re1_thr1;
         assign  fread1_thr1[13] = (ra1_thr1[1:5] == 5'b01101) & re1_thr1;
         assign  fread1_thr1[14] = (ra1_thr1[1:5] == 5'b01110) & re1_thr1;
         assign  fread1_thr1[15] = (ra1_thr1[1:5] == 5'b01111) & re1_thr1;
         assign  fread1_thr1[16] = (ra1_thr1[1:5] == 5'b10000) & re1_thr1;
         assign  fread1_thr1[17] = (ra1_thr1[1:5] == 5'b10001) & re1_thr1;
         assign  fread1_thr1[18] = (ra1_thr1[1:5] == 5'b10010) & re1_thr1;
         assign  fread1_thr1[19] = (ra1_thr1[1:5] == 5'b10011) & re1_thr1;
         assign  fread1_thr1[20] = (ra1_thr1[1:5] == 5'b10100) & re1_thr1;
         assign  fread1_thr1[21] = (ra1_thr1[1:5] == 5'b10101) & re1_thr1;
         assign  fread1_thr1[22] = (ra1_thr1[1:5] == 5'b10110) & re1_thr1;
         assign  fread1_thr1[23] = (ra1_thr1[1:5] == 5'b10111) & re1_thr1;


         begin : xhdl3
          //  genvar              i;
            for (i = 0; i <= 23; i = i + 1)
            begin : writeport_hfpscr_thr1
               assign  hfpscr_thr1_din[24 * i:(24 * i) + 23] = ((hfpscr_thr1_q[24 * i:(24 * i) + 23] & {24{fwrite_thr1_b[i]}}) |
                                                                (di0 & {24{fwrite_thr1[i]}}));
            end
         end


         tri_rlmreg_p #(.WIDTH(576 + 64)) hfpscr_thr1_lat(
            .force_t(force_t),
            .d_mode(tiup),
            .delay_lclkr(delay_lclkr[7]),
            .mpw1_b(mpw1_b[7]),
            .mpw2_b(mpw2_b[1]),
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(tiup),
            .thold_b(thold_0_b),
            .sg(sg_0),
            .scout(hfpscr_thr1_so),
            .scin(hfpscr_thr1_si),
            //-----------------
            .din({  hfpscr_thr1_din,
		    fread0_thr1,
                    fread1_thr1
                    }),

            //-----------------
            .dout({  hfpscr_thr1_q,
		     fread0_thr1_q,
                     fread1_thr1_q })
         );

	 assign hfpscr_thr1_si[0:639] = {hfpscr_thr1_so[1:639], hfpscr_thr1_so[0]};// todo





      assign do0_thr1 = ((hfpscr_thr1_q[24 * 00:(24 * 00) + 23] & {24{fread0_thr1_q[00]}}) |
                            (hfpscr_thr1_q[24 * 01:(24 * 01) + 23] & {24{fread0_thr1_q[01]}}) |
                            (hfpscr_thr1_q[24 * 02:(24 * 02) + 23] & {24{fread0_thr1_q[02]}}) |
                            (hfpscr_thr1_q[24 * 03:(24 * 03) + 23] & {24{fread0_thr1_q[03]}}) |
                            (hfpscr_thr1_q[24 * 04:(24 * 04) + 23] & {24{fread0_thr1_q[04]}}) |
                            (hfpscr_thr1_q[24 * 05:(24 * 05) + 23] & {24{fread0_thr1_q[05]}}) |
                            (hfpscr_thr1_q[24 * 06:(24 * 06) + 23] & {24{fread0_thr1_q[06]}}) |
                            (hfpscr_thr1_q[24 * 07:(24 * 07) + 23] & {24{fread0_thr1_q[07]}}) |
                            (hfpscr_thr1_q[24 * 08:(24 * 08) + 23] & {24{fread0_thr1_q[08]}}) |
                            (hfpscr_thr1_q[24 * 09:(24 * 09) + 23] & {24{fread0_thr1_q[09]}}) |
                            (hfpscr_thr1_q[24 * 10:(24 * 10) + 23] & {24{fread0_thr1_q[10]}}) |
                            (hfpscr_thr1_q[24 * 11:(24 * 11) + 23] & {24{fread0_thr1_q[11]}}) |
                            (hfpscr_thr1_q[24 * 12:(24 * 12) + 23] & {24{fread0_thr1_q[12]}}) |
                            (hfpscr_thr1_q[24 * 13:(24 * 13) + 23] & {24{fread0_thr1_q[13]}}) |
                            (hfpscr_thr1_q[24 * 14:(24 * 14) + 23] & {24{fread0_thr1_q[14]}}) |
                            (hfpscr_thr1_q[24 * 15:(24 * 15) + 23] & {24{fread0_thr1_q[15]}}) |
                            (hfpscr_thr1_q[24 * 16:(24 * 16) + 23] & {24{fread0_thr1_q[16]}}) |
                            (hfpscr_thr1_q[24 * 17:(24 * 17) + 23] & {24{fread0_thr1_q[17]}}) |
                            (hfpscr_thr1_q[24 * 18:(24 * 18) + 23] & {24{fread0_thr1_q[18]}}) |
                            (hfpscr_thr1_q[24 * 19:(24 * 19) + 23] & {24{fread0_thr1_q[19]}}) |
                            (hfpscr_thr1_q[24 * 20:(24 * 20) + 23] & {24{fread0_thr1_q[20]}}) |
                            (hfpscr_thr1_q[24 * 21:(24 * 21) + 23] & {24{fread0_thr1_q[21]}}) |
                            (hfpscr_thr1_q[24 * 22:(24 * 22) + 23] & {24{fread0_thr1_q[22]}}) |
                            (hfpscr_thr1_q[24 * 23:(24 * 23) + 23] & {24{fread0_thr1_q[23]}}));




        assign do1_thr1 =  ((hfpscr_thr1_q[24 * 00:(24 * 00) + 23] & {24{fread1_thr1_q[00]}}) |
                            (hfpscr_thr1_q[24 * 01:(24 * 01) + 23] & {24{fread1_thr1_q[01]}}) |
                            (hfpscr_thr1_q[24 * 02:(24 * 02) + 23] & {24{fread1_thr1_q[02]}}) |
                            (hfpscr_thr1_q[24 * 03:(24 * 03) + 23] & {24{fread1_thr1_q[03]}}) |
                            (hfpscr_thr1_q[24 * 04:(24 * 04) + 23] & {24{fread1_thr1_q[04]}}) |
                            (hfpscr_thr1_q[24 * 05:(24 * 05) + 23] & {24{fread1_thr1_q[05]}}) |
                            (hfpscr_thr1_q[24 * 06:(24 * 06) + 23] & {24{fread1_thr1_q[06]}}) |
                            (hfpscr_thr1_q[24 * 07:(24 * 07) + 23] & {24{fread1_thr1_q[07]}}) |
                            (hfpscr_thr1_q[24 * 08:(24 * 08) + 23] & {24{fread1_thr1_q[08]}}) |
                            (hfpscr_thr1_q[24 * 09:(24 * 09) + 23] & {24{fread1_thr1_q[09]}}) |
                            (hfpscr_thr1_q[24 * 10:(24 * 10) + 23] & {24{fread1_thr1_q[10]}}) |
                            (hfpscr_thr1_q[24 * 11:(24 * 11) + 23] & {24{fread1_thr1_q[11]}}) |
                            (hfpscr_thr1_q[24 * 12:(24 * 12) + 23] & {24{fread1_thr1_q[12]}}) |
                            (hfpscr_thr1_q[24 * 13:(24 * 13) + 23] & {24{fread1_thr1_q[13]}}) |
                            (hfpscr_thr1_q[24 * 14:(24 * 14) + 23] & {24{fread1_thr1_q[14]}}) |
                            (hfpscr_thr1_q[24 * 15:(24 * 15) + 23] & {24{fread1_thr1_q[15]}}) |
                            (hfpscr_thr1_q[24 * 16:(24 * 16) + 23] & {24{fread1_thr1_q[16]}}) |
                            (hfpscr_thr1_q[24 * 17:(24 * 17) + 23] & {24{fread1_thr1_q[17]}}) |
                            (hfpscr_thr1_q[24 * 18:(24 * 18) + 23] & {24{fread1_thr1_q[18]}}) |
                            (hfpscr_thr1_q[24 * 19:(24 * 19) + 23] & {24{fread1_thr1_q[19]}}) |
                            (hfpscr_thr1_q[24 * 20:(24 * 20) + 23] & {24{fread1_thr1_q[20]}}) |
                            (hfpscr_thr1_q[24 * 21:(24 * 21) + 23] & {24{fread1_thr1_q[21]}}) |
                            (hfpscr_thr1_q[24 * 22:(24 * 22) + 23] & {24{fread1_thr1_q[22]}}) |
                            (hfpscr_thr1_q[24 * 23:(24 * 23) + 23] & {24{fread1_thr1_q[23]}}));


      end
   endgenerate

   assign cfpscr_upd_i0_thr0 = do0_thr0[2] & upd_i0_thr0;
   assign upd_i0_fprf_hold_thr0 = do0_thr0[1] & upd_i0_thr0;
   assign upd_i0_compare_thr0 = do0_thr0[0] & upd_i0_thr0;

   assign cfpscr_upd_i1_thr0 = do1_thr0[2] & upd_i1_thr0;
   assign upd_i1_fprf_hold_thr0 = do1_thr0[1] & upd_i1_thr0;
   assign upd_i1_compare_thr0 = do1_thr0[0] & upd_i1_thr0;

   assign cfpscr_upd_i0_thr1 = do0_thr1[2] & upd_i0_thr1;
   assign upd_i0_fprf_hold_thr1 = do0_thr1[1] & upd_i0_thr1;
   assign upd_i0_compare_thr1 = do0_thr1[0] & upd_i0_thr1;

   assign cfpscr_upd_i1_thr1 = do1_thr1[2] & upd_i1_thr1;
   assign upd_i1_fprf_hold_thr1 = do1_thr1[1] & upd_i1_thr1;
   assign upd_i1_compare_thr1 = do1_thr1[0] & upd_i1_thr1;

   assign cfpscr_upd_pipe_thr0 = cfpscr_upd_i0_thr0 | cfpscr_upd_i1_thr0;
   assign cfpscr_upd_pipe_thr1 = cfpscr_upd_i0_thr1 | cfpscr_upd_i1_thr1;

   assign upd_i0_fpscr_thr0[35:55] = do0_thr0[3:23] & {21{cfpscr_upd_i0_thr0}};
   assign upd_i1_fpscr_thr0[35:55] = do1_thr0[3:23] & {21{cfpscr_upd_i1_thr0}};
   assign upd_i0_fpscr_thr1[35:55] = do0_thr1[3:23] & {21{cfpscr_upd_i0_thr1}};
   assign upd_i1_fpscr_thr1[35:55] = do1_thr1[3:23] & {21{cfpscr_upd_i1_thr1}};

   // Move Operations
   assign cfpscr_upd_move = 1'b0;
   assign cfpscr_move[28:63] = {36{1'b0}};
   assign cfpscr_mtfsf = 1'b0;
   assign cfpscr_mtfsfi = 1'b0;
   //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   // Pipe Operations
   assign cfpscr_pipe_thr0[32] = cfpscr_thr0_l2[32];		// <sticky aspect> check 0->1 excp after selection for move/pipe
   assign cfpscr_pipe_thr0[33] = tidn;		//// unused (from other bits after move/pipe selection)
   assign cfpscr_pipe_thr0[34] = tidn;		//// unused (from other bits after move/pipe selection)
   assign cfpscr_pipe_thr0[35] = cfpscr_thr0_l2[35] | upd_i0_fpscr_thr0[35] | upd_i1_fpscr_thr0[35];		//ox STICKY
   assign cfpscr_pipe_thr0[36] = cfpscr_thr0_l2[36] | upd_i0_fpscr_thr0[36] | upd_i1_fpscr_thr0[36];		//ux STICKY
   assign cfpscr_pipe_thr0[37] = cfpscr_thr0_l2[37] | upd_i0_fpscr_thr0[37] | upd_i1_fpscr_thr0[37];		//zx sticky
   assign cfpscr_pipe_thr0[38] = cfpscr_thr0_l2[38] | upd_i0_fpscr_thr0[38] | upd_i1_fpscr_thr0[38];		//xx sticky version of fi

   assign cfpscr_pipe_thr0[39] = cfpscr_thr0_l2[39] | upd_i0_fpscr_thr0[39] | upd_i1_fpscr_thr0[39];		//ex7_flag_vxsnan   ; --sticky
   assign cfpscr_pipe_thr0[40] = cfpscr_thr0_l2[40] | upd_i0_fpscr_thr0[40] | upd_i1_fpscr_thr0[40];		//ex7_flag_vxisi    ; --sticky
   assign cfpscr_pipe_thr0[41] = cfpscr_thr0_l2[41] | upd_i0_fpscr_thr0[41] | upd_i1_fpscr_thr0[41];		//ex7_flag_vxidi    ; --sticky
   assign cfpscr_pipe_thr0[42] = cfpscr_thr0_l2[42] | upd_i0_fpscr_thr0[42] | upd_i1_fpscr_thr0[42];		//ex7_flag_vxzdz    ; --sticky
   assign cfpscr_pipe_thr0[43] = cfpscr_thr0_l2[43] | upd_i0_fpscr_thr0[43] | upd_i1_fpscr_thr0[43];		//ex7_flag_vximz    ; --sticky
   assign cfpscr_pipe_thr0[44] = cfpscr_thr0_l2[44] | upd_i0_fpscr_thr0[44] | upd_i1_fpscr_thr0[44];		//ex7_flag_vxvc     ; --sticky

   //fr NOT sticky
   //no update if 1 compare
   //no update if 1 compare
   assign cfpscr_pipe_thr0[45] = (upd_i0_fpscr_thr0[45] & (~cfpscr_upd_i1_thr0)) | upd_i1_fpscr_thr0[45] | (cfpscr_thr0_l2[45] & (upd_i0_compare_thr0 & (~upd_i1_thr0))) | (cfpscr_thr0_l2[45] & (upd_i1_compare_thr0 & (~upd_i0_thr0))) | (cfpscr_thr0_l2[45] & (upd_i0_compare_thr0 & upd_i1_compare_thr0)) | (upd_i0_fpscr_thr0[45] & ((~upd_i0_compare_thr0) & upd_i0_thr0 & upd_i1_compare_thr0));		//no update if both compares
   //i0 if i1 compare

   assign cfpscr_pipe_thr0[46] = (upd_i0_fpscr_thr0[46] & (~cfpscr_upd_i1_thr0)) | upd_i1_fpscr_thr0[46] | (cfpscr_thr0_l2[46] & (upd_i0_compare_thr0 & (~upd_i1_thr0))) | (cfpscr_thr0_l2[46] & (upd_i1_compare_thr0 & (~upd_i0_thr0))) | (cfpscr_thr0_l2[46] & (upd_i0_compare_thr0 & upd_i1_compare_thr0)) | (upd_i0_fpscr_thr0[46] & ((~upd_i0_compare_thr0) & upd_i0_thr0 & upd_i1_compare_thr0));		//fi NOT sticky

   assign upd_i0_fprf_hold_47_thr0 = upd_i0_compare_thr0 | upd_i0_fprf_hold_thr0;
   assign upd_i1_fprf_hold_47_thr0 = upd_i1_compare_thr0 | upd_i1_fprf_hold_thr0;

   assign cfpscr_pipe_thr0[47] = (upd_i0_fpscr_thr0[47] & (~cfpscr_upd_i1_thr0)) | upd_i1_fpscr_thr0[47] | (cfpscr_thr0_l2[47] & (upd_i0_fprf_hold_47_thr0 & (~upd_i1_thr0))) | (cfpscr_thr0_l2[47] & (upd_i1_fprf_hold_47_thr0 & (~upd_i0_thr0))) | (cfpscr_thr0_l2[47] & (upd_i0_fprf_hold_47_thr0 & upd_i1_fprf_hold_47_thr0)) | (upd_i0_fpscr_thr0[47] & ((~upd_i0_fprf_hold_47_thr0) & upd_i0_thr0 & upd_i1_fprf_hold_47_thr0));		//FPRF C NOT sticky

   assign cfpscr_pipe_thr0[48] = (upd_i0_fpscr_thr0[48] & (~cfpscr_upd_i1_thr0)) | upd_i1_fpscr_thr0[48] | (cfpscr_thr0_l2[48] & (upd_i0_fprf_hold_thr0 & (~upd_i1_thr0))) | (cfpscr_thr0_l2[48] & (upd_i1_fprf_hold_thr0 & (~upd_i0_thr0))) | (cfpscr_thr0_l2[48] & (upd_i0_fprf_hold_thr0 & upd_i1_fprf_hold_thr0)) | (upd_i0_fpscr_thr0[48] & ((~upd_i0_fprf_hold_thr0) & upd_i0_thr0 & upd_i1_fprf_hold_thr0));		//FPRF fpdd(lt)

   assign cfpscr_pipe_thr0[49] = (upd_i0_fpscr_thr0[49] & (~cfpscr_upd_i1_thr0)) | upd_i1_fpscr_thr0[49] | (cfpscr_thr0_l2[49] & (upd_i0_fprf_hold_thr0 & (~upd_i1_thr0))) | (cfpscr_thr0_l2[49] & (upd_i1_fprf_hold_thr0 & (~upd_i0_thr0))) | (cfpscr_thr0_l2[49] & (upd_i0_fprf_hold_thr0 & upd_i1_fprf_hold_thr0)) | (upd_i0_fpscr_thr0[49] & ((~upd_i0_fprf_hold_thr0) & upd_i0_thr0 & upd_i1_fprf_hold_thr0));		//FPRF fpdd(gt)

   assign cfpscr_pipe_thr0[50] = (upd_i0_fpscr_thr0[50] & (~cfpscr_upd_i1_thr0)) | upd_i1_fpscr_thr0[50] | (cfpscr_thr0_l2[50] & (upd_i0_fprf_hold_thr0 & (~upd_i1_thr0))) | (cfpscr_thr0_l2[50] & (upd_i1_fprf_hold_thr0 & (~upd_i0_thr0))) | (cfpscr_thr0_l2[50] & (upd_i0_fprf_hold_thr0 & upd_i1_fprf_hold_thr0)) | (upd_i0_fpscr_thr0[50] & ((~upd_i0_fprf_hold_thr0) & upd_i0_thr0 & upd_i1_fprf_hold_thr0));		//FPRF fpdd(eq)

   assign cfpscr_pipe_thr0[51] = (upd_i0_fpscr_thr0[51] & (~cfpscr_upd_i1_thr0)) | upd_i1_fpscr_thr0[51] | (cfpscr_thr0_l2[51] & (upd_i0_fprf_hold_thr0 & (~upd_i1_thr0))) | (cfpscr_thr0_l2[51] & (upd_i1_fprf_hold_thr0 & (~upd_i0_thr0))) | (cfpscr_thr0_l2[51] & (upd_i0_fprf_hold_thr0 & upd_i1_fprf_hold_thr0)) | (upd_i0_fpscr_thr0[51] & ((~upd_i0_fprf_hold_thr0) & upd_i0_thr0 & upd_i1_fprf_hold_thr0));		//FPRF fpdd(nan)

   assign cfpscr_pipe_thr0[52] = tidn;		//reserved
   assign cfpscr_pipe_thr0[53] = cfpscr_thr0_l2[53];		//VXSOFT sticky
   assign cfpscr_pipe_thr0[54] = cfpscr_thr0_l2[54] | upd_i0_fpscr_thr0[54] | upd_i1_fpscr_thr0[54];		//VXSQRT sticky
   assign cfpscr_pipe_thr0[55] = cfpscr_thr0_l2[55] | upd_i0_fpscr_thr0[55] | upd_i1_fpscr_thr0[55];		//VXCVI  sticky

   //cfpscr_din(28 to 31)   <= cfpscr_pipe_thr0(28 to 31) ;
   assign cfpscr_thr0_din[28] = (ex7_fpscr_move_dfp[0] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[28] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din[29] = (ex7_fpscr_move_dfp[1] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[29] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din[30] = (ex7_fpscr_move_dfp[2] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[30] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din[31] = (ex7_fpscr_move_dfp[3] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[31] & (~ex7_upd_move_thr0));

   // Control Bits
   assign cfpscr_pipe_thr0[56:63] = cfpscr_thr0_l2[56:63];

   assign cfpscr_thr0_din[63] = (ex7_fpscr_move[31] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[63] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din[62] = (ex7_fpscr_move[30] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[62] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din[61] = (ex7_fpscr_move[29] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[61] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din[60] = (ex7_fpscr_move[28] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[60] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din[59] = (ex7_fpscr_move[27] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[59] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din[58] = (ex7_fpscr_move[26] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[58] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din[57] = (ex7_fpscr_move[25] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[57] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din[56] = (ex7_fpscr_move[24] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[56] & (~ex7_upd_move_thr0));

   assign cfpscr_thr0_din[55] = (ex7_fpscr_move[23] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[55] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[55] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[54] = (ex7_fpscr_move[22] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[54] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[54] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[53] = (ex7_fpscr_move[21] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[53] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[53] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[52] = tidn;		// reserved
   assign cfpscr_thr0_din[51] = (ex7_fpscr_move[19] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[51] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[51] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[50] = (ex7_fpscr_move[18] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[50] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[50] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[49] = (ex7_fpscr_move[17] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[49] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[49] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[48] = (ex7_fpscr_move[16] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[48] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[48] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[47] = (ex7_fpscr_move[15] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[47] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[47] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[46] = (ex7_fpscr_move[14] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[46] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[46] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[45] = (ex7_fpscr_move[13] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[45] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[45] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[44] = (ex7_fpscr_move[12] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[44] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[44] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[43] = (ex7_fpscr_move[11] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[43] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[43] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[42] = (ex7_fpscr_move[10] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[42] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[42] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[41] = (ex7_fpscr_move[9] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[41] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[41] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[40] = (ex7_fpscr_move[8] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[40] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[40] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[39] = (ex7_fpscr_move[7] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[39] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[39] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[38] = (ex7_fpscr_move[6] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[38] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[38] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[37] = (ex7_fpscr_move[5] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[37] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[37] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[36] = (ex7_fpscr_move[4] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[36] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[36] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));
   assign cfpscr_thr0_din[35] = (ex7_fpscr_move[3] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[35] & cfpscr_upd_pipe_thr0) | (cfpscr_thr0_l2[35] & (~(ex7_upd_move_thr0 | cfpscr_upd_pipe_thr0)));

   // or all invalid operation exceptions
   // vxsnan
   // vxisi
   // vxidi
   // vxzdz
   // vximx
   // vxvc
   // vxzdz
   assign cfpscr_thr0_din[34] = cfpscr_thr0_din[39] | cfpscr_thr0_din[40] | cfpscr_thr0_din[41] | cfpscr_thr0_din[42] | cfpscr_thr0_din[43] | cfpscr_thr0_din[44] | cfpscr_thr0_din[53] | cfpscr_thr0_din[54] | cfpscr_thr0_din[55];		// vximx
   // vxvc

   // masked or of all exception bits
   // vx* / ve
   // ox  / oe
   // ux  / ue
   assign cfpscr_thr0_din[33] = (cfpscr_thr0_din[34] & cfpscr_thr0_din[56]) | (cfpscr_thr0_din[35] & cfpscr_thr0_din[57]) | (cfpscr_thr0_din[36] & cfpscr_thr0_din[58]) | (cfpscr_thr0_din[37] & cfpscr_thr0_din[59]) | (cfpscr_thr0_din[38] & cfpscr_thr0_din[60]);		// zx  / ze
   // xx  / xe

   assign cfpscr_thr0_din[32] = (ex7_fpscr_move[0] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0[32] & (~ex7_upd_move_thr0)) | (cfpscr_new_excp_thr0 & (~(((ex7_mtfsf | ex7_mtfsfi) & ex7_thread[0]) & (~f_dcd_ex7_cancel))));		//upd_pipe and hold sticky

   // only check the exception bits
   // ox
   // ux
   // zx
   // xx
   // vxsnan
   // vxisi
   // vxidi
   // vxzdz
   // vximx
   // vxvc
   // vxzdz
   assign cfpscr_new_excp_thr0 = ((~cfpscr_thr0_l2[35]) & cfpscr_thr0_din[35]) | ((~cfpscr_thr0_l2[36]) & cfpscr_thr0_din[36]) | ((~cfpscr_thr0_l2[37]) & cfpscr_thr0_din[37]) | ((~cfpscr_thr0_l2[38]) & cfpscr_thr0_din[38]) | ((~cfpscr_thr0_l2[39]) & cfpscr_thr0_din[39]) | ((~cfpscr_thr0_l2[40]) & cfpscr_thr0_din[40]) | ((~cfpscr_thr0_l2[41]) & cfpscr_thr0_din[41]) | ((~cfpscr_thr0_l2[42]) & cfpscr_thr0_din[42]) | ((~cfpscr_thr0_l2[43]) & cfpscr_thr0_din[43]) | ((~cfpscr_thr0_l2[44]) & cfpscr_thr0_din[44]) | ((~cfpscr_thr0_l2[53]) & cfpscr_thr0_din[53]) | ((~cfpscr_thr0_l2[54]) & cfpscr_thr0_din[54]) | ((~cfpscr_thr0_l2[55]) & cfpscr_thr0_din[55]);		// vximx
   // vxvc

   //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   //-FOR RTX only:  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   assign ex7_inv_fpscr_bit = (ex7_nib_mask[0] & ~( |(ex7_nib_mask[1:3]))) &
                              ((~(ex7_bit_mask[0]) &   ex7_bit_mask[1] & ~(ex7_bit_mask[2]) & ~(ex7_bit_mask[3])) |
	                       (~(ex7_bit_mask[0]) & ~(ex7_bit_mask[1]) &  ex7_bit_mask[2]  & ~(ex7_bit_mask[3])));


   assign cfpscr_i0_wr_thr0 = cfpscr_upd_i0_thr0 | (ex7_upd_move_thr0 & ~(ex7_inv_fpscr_bit)); // don't do the write if BT is 1 or 2 (FPSCR 33 or 34)
   assign cfpscr_i1_wr_thr0 = cfpscr_upd_i1_thr0;
   assign cfpscr_i0i1_wr_thr0 = cfpscr_i0_wr_thr0 & cfpscr_i1_wr_thr0;

   assign cfpscr_i0_wr_thr1 = cfpscr_upd_i0_thr1 | (ex7_upd_move_thr1 & ~(ex7_inv_fpscr_bit));
   assign cfpscr_i1_wr_thr1 = cfpscr_upd_i1_thr1;
   assign cfpscr_i0i1_wr_thr1 = cfpscr_i0_wr_thr1 & cfpscr_i1_wr_thr1;


   //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   //-FOR RTX only: Thread 0 i0 completion only -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   assign cfpscr_pipe_thr0_i0[32] = cfpscr_thr0_l2[32];		// <sticky aspect> check 0->1 excp after selection for move/pipe
   assign cfpscr_pipe_thr0_i0[33] = tidn;		//// unused (from other bits after move/pipe selection)
   assign cfpscr_pipe_thr0_i0[34] = tidn;		//// unused (from other bits after move/pipe selection)
   assign cfpscr_pipe_thr0_i0[35] = cfpscr_thr0_l2[35] | upd_i0_fpscr_thr0[35] ;		//ox STICKY
   assign cfpscr_pipe_thr0_i0[36] = cfpscr_thr0_l2[36] | upd_i0_fpscr_thr0[36] ;		//ux STICKY
   assign cfpscr_pipe_thr0_i0[37] = cfpscr_thr0_l2[37] | upd_i0_fpscr_thr0[37] ;		//zx sticky
   assign cfpscr_pipe_thr0_i0[38] = cfpscr_thr0_l2[38] | upd_i0_fpscr_thr0[38] ;		//xx sticky version of fi

   assign cfpscr_pipe_thr0_i0[39] = cfpscr_thr0_l2[39] | upd_i0_fpscr_thr0[39] ;		//ex7_flag_vxsnan   ; --sticky
   assign cfpscr_pipe_thr0_i0[40] = cfpscr_thr0_l2[40] | upd_i0_fpscr_thr0[40] ;		//ex7_flag_vxisi    ; --sticky
   assign cfpscr_pipe_thr0_i0[41] = cfpscr_thr0_l2[41] | upd_i0_fpscr_thr0[41] ;		//ex7_flag_vxidi    ; --sticky
   assign cfpscr_pipe_thr0_i0[42] = cfpscr_thr0_l2[42] | upd_i0_fpscr_thr0[42] ;		//ex7_flag_vxzdz    ; --sticky
   assign cfpscr_pipe_thr0_i0[43] = cfpscr_thr0_l2[43] | upd_i0_fpscr_thr0[43] ;		//ex7_flag_vximz    ; --sticky
   assign cfpscr_pipe_thr0_i0[44] = cfpscr_thr0_l2[44] | upd_i0_fpscr_thr0[44] ;		//ex7_flag_vxvc     ; --sticky

   //fr NOT sticky
   //no update if 1 compare
   //no update if 1 compare
   assign cfpscr_pipe_thr0_i0[45] = (upd_i0_fpscr_thr0[45]) | (cfpscr_thr0_l2[45] & (upd_i0_compare_thr0))  | (upd_i0_fpscr_thr0[45] & ((~upd_i0_compare_thr0) & upd_i0_thr0));		//no update if both compares
   //i0 if i1 compare

   assign cfpscr_pipe_thr0_i0[46] = (upd_i0_fpscr_thr0[46]) | (cfpscr_thr0_l2[46] & (upd_i0_compare_thr0))  | (upd_i0_fpscr_thr0[46] & ((~upd_i0_compare_thr0) & upd_i0_thr0));		//fi NOT sticky

   assign cfpscr_pipe_thr0_i0[47] = (upd_i0_fpscr_thr0[47]) | (cfpscr_thr0_l2[47] & (upd_i0_fprf_hold_47_thr0 ))  | (upd_i0_fpscr_thr0[47] & ((~upd_i0_fprf_hold_47_thr0) & upd_i0_thr0));		//FPRF C NOT sticky

   assign cfpscr_pipe_thr0_i0[48] = (upd_i0_fpscr_thr0[48]) | (cfpscr_thr0_l2[48] & (upd_i0_fprf_hold_thr0 ))  | (upd_i0_fpscr_thr0[48] & ((~upd_i0_fprf_hold_thr0) & upd_i0_thr0));		//FPRF fpdd(lt)

   assign cfpscr_pipe_thr0_i0[49] = (upd_i0_fpscr_thr0[49]) | (cfpscr_thr0_l2[49] & (upd_i0_fprf_hold_thr0 ))  | (upd_i0_fpscr_thr0[49] & ((~upd_i0_fprf_hold_thr0) & upd_i0_thr0));		//FPRF fpdd(gt)

   assign cfpscr_pipe_thr0_i0[50] = (upd_i0_fpscr_thr0[50]) | (cfpscr_thr0_l2[50] & (upd_i0_fprf_hold_thr0 ))  | (upd_i0_fpscr_thr0[50] & ((~upd_i0_fprf_hold_thr0) & upd_i0_thr0));		//FPRF fpdd(eq)

   assign cfpscr_pipe_thr0_i0[51] = (upd_i0_fpscr_thr0[51]) | (cfpscr_thr0_l2[51] & (upd_i0_fprf_hold_thr0 ))  | (upd_i0_fpscr_thr0[51] & ((~upd_i0_fprf_hold_thr0) & upd_i0_thr0));		//FPRF fpdd(nan)

   assign cfpscr_pipe_thr0_i0[52] = tidn;		//reserved
   assign cfpscr_pipe_thr0_i0[53] = cfpscr_thr0_l2[53];		//VXSOFT sticky
   assign cfpscr_pipe_thr0_i0[54] = cfpscr_thr0_l2[54] | upd_i0_fpscr_thr0[54] ;		//VXSQRT sticky
   assign cfpscr_pipe_thr0_i0[55] = cfpscr_thr0_l2[55] | upd_i0_fpscr_thr0[55] ;		//VXCVI  sticky

   //cfpscr_din(28 to 31)   <= cfpscr_pipe_thr0_i0(28 to 31) ;
   assign cfpscr_thr0_din_i0[28] = (ex7_fpscr_move_dfp[0] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[28] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din_i0[29] = (ex7_fpscr_move_dfp[1] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[29] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din_i0[30] = (ex7_fpscr_move_dfp[2] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[30] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din_i0[31] = (ex7_fpscr_move_dfp[3] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[31] & (~ex7_upd_move_thr0));

   // Control Bits
   assign cfpscr_pipe_thr0_i0[56:63] = cfpscr_thr0_l2[56:63];

   assign cfpscr_thr0_din_i0[63] = (ex7_fpscr_move[31] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[63] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din_i0[62] = (ex7_fpscr_move[30] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[62] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din_i0[61] = (ex7_fpscr_move[29] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[61] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din_i0[60] = (ex7_fpscr_move[28] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[60] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din_i0[59] = (ex7_fpscr_move[27] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[59] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din_i0[58] = (ex7_fpscr_move[26] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[58] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din_i0[57] = (ex7_fpscr_move[25] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[57] & (~ex7_upd_move_thr0));
   assign cfpscr_thr0_din_i0[56] = (ex7_fpscr_move[24] & ex7_upd_move_thr0) | (cfpscr_thr0_l2[56] & (~ex7_upd_move_thr0));

   assign cfpscr_thr0_din_i0[55] = (ex7_fpscr_move[23] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[55] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[55] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[54] = (ex7_fpscr_move[22] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[54] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[54] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[53] = (ex7_fpscr_move[21] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[53] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[53] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[52] = tidn;		// reserved
   assign cfpscr_thr0_din_i0[51] = (ex7_fpscr_move[19] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[51] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[51] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[50] = (ex7_fpscr_move[18] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[50] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[50] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[49] = (ex7_fpscr_move[17] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[49] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[49] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[48] = (ex7_fpscr_move[16] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[48] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[48] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[47] = (ex7_fpscr_move[15] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[47] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[47] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[46] = (ex7_fpscr_move[14] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[46] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[46] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[45] = (ex7_fpscr_move[13] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[45] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[45] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[44] = (ex7_fpscr_move[12] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[44] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[44] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[43] = (ex7_fpscr_move[11] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[43] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[43] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[42] = (ex7_fpscr_move[10] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[42] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[42] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[41] = (ex7_fpscr_move[9] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[41] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[41] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[40] = (ex7_fpscr_move[8] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[40] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[40] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[39] = (ex7_fpscr_move[7] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[39] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[39] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[38] = (ex7_fpscr_move[6] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[38] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[38] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[37] = (ex7_fpscr_move[5] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[37] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[37] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[36] = (ex7_fpscr_move[4] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[36] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[36] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));
   assign cfpscr_thr0_din_i0[35] = (ex7_fpscr_move[3] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[35] & cfpscr_upd_i0_thr0) | (cfpscr_thr0_l2[35] & (~(ex7_upd_move_thr0 | cfpscr_upd_i0_thr0)));

   assign cfpscr_thr0_din_i0[34] = cfpscr_thr0_din_i0[39] | cfpscr_thr0_din_i0[40] | cfpscr_thr0_din_i0[41] | cfpscr_thr0_din_i0[42] | cfpscr_thr0_din_i0[43] | cfpscr_thr0_din_i0[44] | cfpscr_thr0_din_i0[53] | cfpscr_thr0_din_i0[54] | cfpscr_thr0_din_i0[55];		// vximx

   assign cfpscr_thr0_din_i0[33] = (cfpscr_thr0_din_i0[34] & cfpscr_thr0_din_i0[56]) | (cfpscr_thr0_din_i0[35] & cfpscr_thr0_din_i0[57]) | (cfpscr_thr0_din_i0[36] & cfpscr_thr0_din_i0[58]) | (cfpscr_thr0_din_i0[37] & cfpscr_thr0_din_i0[59]) | (cfpscr_thr0_din_i0[38] & cfpscr_thr0_din_i0[60]);		// zx  / ze

   assign cfpscr_thr0_din_i0[32] = (ex7_fpscr_move[0] & ex7_upd_move_thr0) | (cfpscr_pipe_thr0_i0[32] & (~ex7_upd_move_thr0)) | (cfpscr_new_excp_thr0_i0 & (~(((ex7_mtfsf | ex7_mtfsfi) & ex7_thread[0]) & (~f_dcd_ex7_cancel))));		//upd_pipe and hold sticky

   assign cfpscr_new_excp_thr0_i0 = ((~cfpscr_thr0_l2[35]) & cfpscr_thr0_din_i0[35]) | ((~cfpscr_thr0_l2[36]) & cfpscr_thr0_din_i0[36]) | ((~cfpscr_thr0_l2[37]) & cfpscr_thr0_din_i0[37]) | ((~cfpscr_thr0_l2[38]) & cfpscr_thr0_din_i0[38]) | ((~cfpscr_thr0_l2[39]) & cfpscr_thr0_din_i0[39]) | ((~cfpscr_thr0_l2[40]) & cfpscr_thr0_din_i0[40]) | ((~cfpscr_thr0_l2[41]) & cfpscr_thr0_din_i0[41]) | ((~cfpscr_thr0_l2[42]) & cfpscr_thr0_din_i0[42]) | ((~cfpscr_thr0_l2[43]) & cfpscr_thr0_din_i0[43]) | ((~cfpscr_thr0_l2[44]) & cfpscr_thr0_din_i0[44]) | ((~cfpscr_thr0_l2[53]) & cfpscr_thr0_din_i0[53]) | ((~cfpscr_thr0_l2[54]) & cfpscr_thr0_din_i0[54]) | ((~cfpscr_thr0_l2[55]) & cfpscr_thr0_din_i0[55]);		// vximx

   assign spare_unused[36:67] = cfpscr_thr0_din_i0[32:63];

   //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


   //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   // Pipe Operations
   assign cfpscr_pipe_thr1[32] = cfpscr_thr1_l2[32];		// <sticky aspect> check 0->1 excp after selection for move/pipe
   assign cfpscr_pipe_thr1[33] = tidn;		//// unused (from other bits after move/pipe selection)
   assign cfpscr_pipe_thr1[34] = tidn;		//// unused (from other bits after move/pipe selection)
   assign cfpscr_pipe_thr1[35] = cfpscr_thr1_l2[35] | upd_i0_fpscr_thr1[35] | upd_i1_fpscr_thr1[35];		//ox STICKY
   assign cfpscr_pipe_thr1[36] = cfpscr_thr1_l2[36] | upd_i0_fpscr_thr1[36] | upd_i1_fpscr_thr1[36];		//ux STICKY
   assign cfpscr_pipe_thr1[37] = cfpscr_thr1_l2[37] | upd_i0_fpscr_thr1[37] | upd_i1_fpscr_thr1[37];		//zx sticky
   assign cfpscr_pipe_thr1[38] = cfpscr_thr1_l2[38] | upd_i0_fpscr_thr1[38] | upd_i1_fpscr_thr1[38];		//xx sticky version of fi

   assign cfpscr_pipe_thr1[39] = cfpscr_thr1_l2[39] | upd_i0_fpscr_thr1[39] | upd_i1_fpscr_thr1[39];		//ex7_flag_vxsnan   ; --sticky
   assign cfpscr_pipe_thr1[40] = cfpscr_thr1_l2[40] | upd_i0_fpscr_thr1[40] | upd_i1_fpscr_thr1[40];		//ex7_flag_vxisi    ; --sticky
   assign cfpscr_pipe_thr1[41] = cfpscr_thr1_l2[41] | upd_i0_fpscr_thr1[41] | upd_i1_fpscr_thr1[41];		//ex7_flag_vxidi    ; --sticky
   assign cfpscr_pipe_thr1[42] = cfpscr_thr1_l2[42] | upd_i0_fpscr_thr1[42] | upd_i1_fpscr_thr1[42];		//ex7_flag_vxzdz    ; --sticky
   assign cfpscr_pipe_thr1[43] = cfpscr_thr1_l2[43] | upd_i0_fpscr_thr1[43] | upd_i1_fpscr_thr1[43];		//ex7_flag_vximz    ; --sticky
   assign cfpscr_pipe_thr1[44] = cfpscr_thr1_l2[44] | upd_i0_fpscr_thr1[44] | upd_i1_fpscr_thr1[44];		//ex7_flag_vxvc     ; --sticky

   //fr NOT sticky
   //no update if 1 compare
   //no update if 1 compare
   assign cfpscr_pipe_thr1[45] = (upd_i0_fpscr_thr1[45] & (~cfpscr_upd_i1_thr1)) | upd_i1_fpscr_thr1[45] | (cfpscr_thr1_l2[45] & (upd_i0_compare_thr1 & (~upd_i1_thr1))) | (cfpscr_thr1_l2[45] & (upd_i1_compare_thr1 & (~upd_i0_thr1))) | (cfpscr_thr1_l2[45] & (upd_i0_compare_thr1 & upd_i1_compare_thr1)) | (upd_i0_fpscr_thr1[45] & ((~upd_i0_compare_thr1) & upd_i0_thr1 & upd_i1_compare_thr1));		//no update if both compares
   //i0 if i1 compare

   assign cfpscr_pipe_thr1[46] = (upd_i0_fpscr_thr1[46] & (~cfpscr_upd_i1_thr1)) | upd_i1_fpscr_thr1[46] | (cfpscr_thr1_l2[46] & (upd_i0_compare_thr1 & (~upd_i1_thr1))) | (cfpscr_thr1_l2[46] & (upd_i1_compare_thr1 & (~upd_i0_thr1))) | (cfpscr_thr1_l2[46] & (upd_i0_compare_thr1 & upd_i1_compare_thr1)) | (upd_i0_fpscr_thr1[46] & ((~upd_i0_compare_thr1) & upd_i0_thr1 & upd_i1_compare_thr1));		//fi NOT sticky

   assign upd_i0_fprf_hold_47_thr1 = upd_i0_compare_thr1 | upd_i0_fprf_hold_thr1;
   assign upd_i1_fprf_hold_47_thr1 = upd_i1_compare_thr1 | upd_i1_fprf_hold_thr1;

   assign cfpscr_pipe_thr1[47] = (upd_i0_fpscr_thr1[47] & (~cfpscr_upd_i1_thr1)) | upd_i1_fpscr_thr1[47] | (cfpscr_thr1_l2[47] & (upd_i0_fprf_hold_47_thr1 & (~upd_i1_thr1))) | (cfpscr_thr1_l2[47] & (upd_i1_fprf_hold_47_thr1 & (~upd_i0_thr1))) | (cfpscr_thr1_l2[47] & (upd_i0_fprf_hold_47_thr1 & upd_i1_fprf_hold_47_thr1)) | (upd_i0_fpscr_thr1[47] & ((~upd_i0_fprf_hold_47_thr1) & upd_i0_thr1 & upd_i1_fprf_hold_47_thr1));		//FPRF C NOT sticky

   assign cfpscr_pipe_thr1[48] = (upd_i0_fpscr_thr1[48] & (~cfpscr_upd_i1_thr1)) | upd_i1_fpscr_thr1[48] | (cfpscr_thr1_l2[48] & (upd_i0_fprf_hold_thr1 & (~upd_i1_thr1))) | (cfpscr_thr1_l2[48] & (upd_i1_fprf_hold_thr1 & (~upd_i0_thr1))) | (cfpscr_thr1_l2[48] & (upd_i0_fprf_hold_thr1 & upd_i1_fprf_hold_thr1)) | (upd_i0_fpscr_thr1[48] & ((~upd_i0_fprf_hold_thr1) & upd_i0_thr1 & upd_i1_fprf_hold_thr1));		//FPRF fpdd(lt)

   assign cfpscr_pipe_thr1[49] = (upd_i0_fpscr_thr1[49] & (~cfpscr_upd_i1_thr1)) | upd_i1_fpscr_thr1[49] | (cfpscr_thr1_l2[49] & (upd_i0_fprf_hold_thr1 & (~upd_i1_thr1))) | (cfpscr_thr1_l2[49] & (upd_i1_fprf_hold_thr1 & (~upd_i0_thr1))) | (cfpscr_thr1_l2[49] & (upd_i0_fprf_hold_thr1 & upd_i1_fprf_hold_thr1)) | (upd_i0_fpscr_thr1[49] & ((~upd_i0_fprf_hold_thr1) & upd_i0_thr1 & upd_i1_fprf_hold_thr1));		//FPRF fpdd(gt)

   assign cfpscr_pipe_thr1[50] = (upd_i0_fpscr_thr1[50] & (~cfpscr_upd_i1_thr1)) | upd_i1_fpscr_thr1[50] | (cfpscr_thr1_l2[50] & (upd_i0_fprf_hold_thr1 & (~upd_i1_thr1))) | (cfpscr_thr1_l2[50] & (upd_i1_fprf_hold_thr1 & (~upd_i0_thr1))) | (cfpscr_thr1_l2[50] & (upd_i0_fprf_hold_thr1 & upd_i1_fprf_hold_thr1)) | (upd_i0_fpscr_thr1[50] & ((~upd_i0_fprf_hold_thr1) & upd_i0_thr1 & upd_i1_fprf_hold_thr1));		//FPRF fpdd(eq)

   assign cfpscr_pipe_thr1[51] = (upd_i0_fpscr_thr1[51] & (~cfpscr_upd_i1_thr1)) | upd_i1_fpscr_thr1[51] | (cfpscr_thr1_l2[51] & (upd_i0_fprf_hold_thr1 & (~upd_i1_thr1))) | (cfpscr_thr1_l2[51] & (upd_i1_fprf_hold_thr1 & (~upd_i0_thr1))) | (cfpscr_thr1_l2[51] & (upd_i0_fprf_hold_thr1 & upd_i1_fprf_hold_thr1)) | (upd_i0_fpscr_thr1[51] & ((~upd_i0_fprf_hold_thr1) & upd_i0_thr1 & upd_i1_fprf_hold_thr1));		//FPRF fpdd(nan)

   assign cfpscr_pipe_thr1[52] = tidn;		//reserved
   assign cfpscr_pipe_thr1[53] = cfpscr_thr1_l2[53];		//VXSOFT sticky
   assign cfpscr_pipe_thr1[54] = cfpscr_thr1_l2[54] | upd_i0_fpscr_thr1[54] | upd_i1_fpscr_thr1[54];		//VXSQRT sticky
   assign cfpscr_pipe_thr1[55] = cfpscr_thr1_l2[55] | upd_i0_fpscr_thr1[55] | upd_i1_fpscr_thr1[55];		//VXCVI  sticky

   //cfpscr_din(28 to 31)   <= cfpscr_pipe_thr1(28 to 31) ;
   assign cfpscr_thr1_din[28] = (ex7_fpscr_move_dfp[0] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[28] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din[29] = (ex7_fpscr_move_dfp[1] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[29] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din[30] = (ex7_fpscr_move_dfp[2] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[30] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din[31] = (ex7_fpscr_move_dfp[3] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[31] & (~ex7_upd_move_thr1));

   // Control Bits
   assign cfpscr_pipe_thr1[56:63] = cfpscr_thr1_l2[56:63];

   assign cfpscr_thr1_din[63] = (ex7_fpscr_move[31] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[63] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din[62] = (ex7_fpscr_move[30] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[62] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din[61] = (ex7_fpscr_move[29] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[61] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din[60] = (ex7_fpscr_move[28] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[60] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din[59] = (ex7_fpscr_move[27] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[59] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din[58] = (ex7_fpscr_move[26] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[58] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din[57] = (ex7_fpscr_move[25] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[57] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din[56] = (ex7_fpscr_move[24] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[56] & (~ex7_upd_move_thr1));

   assign cfpscr_thr1_din[55] = (ex7_fpscr_move[23] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[55] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[55] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[54] = (ex7_fpscr_move[22] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[54] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[54] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[53] = (ex7_fpscr_move[21] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[53] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[53] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[52] = tidn;		// reserved
   assign cfpscr_thr1_din[51] = (ex7_fpscr_move[19] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[51] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[51] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[50] = (ex7_fpscr_move[18] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[50] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[50] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[49] = (ex7_fpscr_move[17] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[49] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[49] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[48] = (ex7_fpscr_move[16] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[48] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[48] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[47] = (ex7_fpscr_move[15] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[47] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[47] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[46] = (ex7_fpscr_move[14] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[46] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[46] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[45] = (ex7_fpscr_move[13] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[45] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[45] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[44] = (ex7_fpscr_move[12] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[44] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[44] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[43] = (ex7_fpscr_move[11] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[43] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[43] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[42] = (ex7_fpscr_move[10] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[42] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[42] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[41] = (ex7_fpscr_move[9] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[41] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[41] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[40] = (ex7_fpscr_move[8] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[40] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[40] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[39] = (ex7_fpscr_move[7] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[39] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[39] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[38] = (ex7_fpscr_move[6] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[38] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[38] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[37] = (ex7_fpscr_move[5] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[37] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[37] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[36] = (ex7_fpscr_move[4] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[36] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[36] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));
   assign cfpscr_thr1_din[35] = (ex7_fpscr_move[3] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[35] & cfpscr_upd_pipe_thr1) | (cfpscr_thr1_l2[35] & (~(ex7_upd_move_thr1 | cfpscr_upd_pipe_thr1)));

   // or all invalid operation exceptions
   // vxsnan
   // vxisi
   // vxidi
   // vxzdz
   // vximx
   // vxvc
   // vxzdz
   assign cfpscr_thr1_din[34] = cfpscr_thr1_din[39] | cfpscr_thr1_din[40] | cfpscr_thr1_din[41] | cfpscr_thr1_din[42] | cfpscr_thr1_din[43] | cfpscr_thr1_din[44] | cfpscr_thr1_din[53] | cfpscr_thr1_din[54] | cfpscr_thr1_din[55];		// vximx
   // vxvc

   // masked or of all exception bits
   // vx* / ve
   // ox  / oe
   // ux  / ue
   assign cfpscr_thr1_din[33] = (cfpscr_thr1_din[34] & cfpscr_thr1_din[56]) | (cfpscr_thr1_din[35] & cfpscr_thr1_din[57]) | (cfpscr_thr1_din[36] & cfpscr_thr1_din[58]) | (cfpscr_thr1_din[37] & cfpscr_thr1_din[59]) | (cfpscr_thr1_din[38] & cfpscr_thr1_din[60]);		// zx  / ze
   // xx  / xe

   assign cfpscr_thr1_din[32] = (ex7_fpscr_move[0] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1[32] & (~ex7_upd_move_thr1)) | (cfpscr_new_excp_thr1 & (~(((ex7_mtfsf | ex7_mtfsfi) & ex7_thread[1]) & (~f_dcd_ex7_cancel))));		//upd_pipe and hold sticky

   // only check the exception bits
   // ox
   // ux
   // zx
   // xx
   // vxsnan
   // vxisi
   // vxidi
   // vxzdz
   // vximx
   // vxvc
   // vxzdz
   assign cfpscr_new_excp_thr1 = ((~cfpscr_thr1_l2[35]) & cfpscr_thr1_din[35]) | ((~cfpscr_thr1_l2[36]) & cfpscr_thr1_din[36]) | ((~cfpscr_thr1_l2[37]) & cfpscr_thr1_din[37]) | ((~cfpscr_thr1_l2[38]) & cfpscr_thr1_din[38]) | ((~cfpscr_thr1_l2[39]) & cfpscr_thr1_din[39]) | ((~cfpscr_thr1_l2[40]) & cfpscr_thr1_din[40]) | ((~cfpscr_thr1_l2[41]) & cfpscr_thr1_din[41]) | ((~cfpscr_thr1_l2[42]) & cfpscr_thr1_din[42]) | ((~cfpscr_thr1_l2[43]) & cfpscr_thr1_din[43]) | ((~cfpscr_thr1_l2[44]) & cfpscr_thr1_din[44]) | ((~cfpscr_thr1_l2[53]) & cfpscr_thr1_din[53]) | ((~cfpscr_thr1_l2[54]) & cfpscr_thr1_din[54]) | ((~cfpscr_thr1_l2[55]) & cfpscr_thr1_din[55]);		// vximx
   // vxvc
   //----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   //-FOR RTX only: Thread 1 i0 completion only -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   assign cfpscr_pipe_thr1_i0[32] = cfpscr_thr1_l2[32];		// <sticky aspect> check 0->1 excp after selection for move/pipe
   assign cfpscr_pipe_thr1_i0[33] = tidn;		//// unused (from other bits after move/pipe selection)
   assign cfpscr_pipe_thr1_i0[34] = tidn;		//// unused (from other bits after move/pipe selection)
   assign cfpscr_pipe_thr1_i0[35] = cfpscr_thr1_l2[35] | upd_i0_fpscr_thr1[35] ;		//ox STICKY
   assign cfpscr_pipe_thr1_i0[36] = cfpscr_thr1_l2[36] | upd_i0_fpscr_thr1[36] ;		//ux STICKY
   assign cfpscr_pipe_thr1_i0[37] = cfpscr_thr1_l2[37] | upd_i0_fpscr_thr1[37] ;		//zx sticky
   assign cfpscr_pipe_thr1_i0[38] = cfpscr_thr1_l2[38] | upd_i0_fpscr_thr1[38] ;		//xx sticky version of fi

   assign cfpscr_pipe_thr1_i0[39] = cfpscr_thr1_l2[39] | upd_i0_fpscr_thr1[39] ;		//ex7_flag_vxsnan   ; --sticky
   assign cfpscr_pipe_thr1_i0[40] = cfpscr_thr1_l2[40] | upd_i0_fpscr_thr1[40] ;		//ex7_flag_vxisi    ; --sticky
   assign cfpscr_pipe_thr1_i0[41] = cfpscr_thr1_l2[41] | upd_i0_fpscr_thr1[41] ;		//ex7_flag_vxidi    ; --sticky
   assign cfpscr_pipe_thr1_i0[42] = cfpscr_thr1_l2[42] | upd_i0_fpscr_thr1[42] ;		//ex7_flag_vxzdz    ; --sticky
   assign cfpscr_pipe_thr1_i0[43] = cfpscr_thr1_l2[43] | upd_i0_fpscr_thr1[43] ;		//ex7_flag_vximz    ; --sticky
   assign cfpscr_pipe_thr1_i0[44] = cfpscr_thr1_l2[44] | upd_i0_fpscr_thr1[44] ;		//ex7_flag_vxvc     ; --sticky

   //fr NOT sticky
   //no update if 1 compare
   //no update if 1 compare
   assign cfpscr_pipe_thr1_i0[45] = (upd_i0_fpscr_thr1[45]) | (cfpscr_thr1_l2[45] & (upd_i0_compare_thr1))  | (upd_i0_fpscr_thr1[45] & ((~upd_i0_compare_thr1) & upd_i0_thr1));		//no update if both compares
   //i0 if i1 compare

   assign cfpscr_pipe_thr1_i0[46] = (upd_i0_fpscr_thr1[46]) | (cfpscr_thr1_l2[46] & (upd_i0_compare_thr1))  | (upd_i0_fpscr_thr1[46] & ((~upd_i0_compare_thr1) & upd_i0_thr1));		//fi NOT sticky

   assign cfpscr_pipe_thr1_i0[47] = (upd_i0_fpscr_thr1[47]) | (cfpscr_thr1_l2[47] & (upd_i0_fprf_hold_47_thr1 ))  | (upd_i0_fpscr_thr1[47] & ((~upd_i0_fprf_hold_47_thr1) & upd_i0_thr1));		//FPRF C NOT sticky

   assign cfpscr_pipe_thr1_i0[48] = (upd_i0_fpscr_thr1[48]) | (cfpscr_thr1_l2[48] & (upd_i0_fprf_hold_thr1 ))  | (upd_i0_fpscr_thr1[48] & ((~upd_i0_fprf_hold_thr1) & upd_i0_thr1));		//FPRF fpdd(lt)

   assign cfpscr_pipe_thr1_i0[49] = (upd_i0_fpscr_thr1[49]) | (cfpscr_thr1_l2[49] & (upd_i0_fprf_hold_thr1 ))  | (upd_i0_fpscr_thr1[49] & ((~upd_i0_fprf_hold_thr1) & upd_i0_thr1));		//FPRF fpdd(gt)

   assign cfpscr_pipe_thr1_i0[50] = (upd_i0_fpscr_thr1[50]) | (cfpscr_thr1_l2[50] & (upd_i0_fprf_hold_thr1 ))  | (upd_i0_fpscr_thr1[50] & ((~upd_i0_fprf_hold_thr1) & upd_i0_thr1));		//FPRF fpdd(eq)

   assign cfpscr_pipe_thr1_i0[51] = (upd_i0_fpscr_thr1[51]) | (cfpscr_thr1_l2[51] & (upd_i0_fprf_hold_thr1 ))  | (upd_i0_fpscr_thr1[51] & ((~upd_i0_fprf_hold_thr1) & upd_i0_thr1));		//FPRF fpdd(nan)

   assign cfpscr_pipe_thr1_i0[52] = tidn;		//reserved
   assign cfpscr_pipe_thr1_i0[53] = cfpscr_thr1_l2[53];		//VXSOFT sticky
   assign cfpscr_pipe_thr1_i0[54] = cfpscr_thr1_l2[54] | upd_i0_fpscr_thr1[54] ;		//VXSQRT sticky
   assign cfpscr_pipe_thr1_i0[55] = cfpscr_thr1_l2[55] | upd_i0_fpscr_thr1[55] ;		//VXCVI  sticky

   assign cfpscr_thr1_din_i0[28] = (ex7_fpscr_move_dfp[0] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[28] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din_i0[29] = (ex7_fpscr_move_dfp[1] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[29] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din_i0[30] = (ex7_fpscr_move_dfp[2] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[30] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din_i0[31] = (ex7_fpscr_move_dfp[3] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[31] & (~ex7_upd_move_thr1));

   // Control Bits
   assign cfpscr_pipe_thr1_i0[56:63] = cfpscr_thr1_l2[56:63];

   assign cfpscr_thr1_din_i0[63] = (ex7_fpscr_move[31] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[63] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din_i0[62] = (ex7_fpscr_move[30] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[62] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din_i0[61] = (ex7_fpscr_move[29] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[61] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din_i0[60] = (ex7_fpscr_move[28] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[60] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din_i0[59] = (ex7_fpscr_move[27] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[59] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din_i0[58] = (ex7_fpscr_move[26] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[58] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din_i0[57] = (ex7_fpscr_move[25] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[57] & (~ex7_upd_move_thr1));
   assign cfpscr_thr1_din_i0[56] = (ex7_fpscr_move[24] & ex7_upd_move_thr1) | (cfpscr_thr1_l2[56] & (~ex7_upd_move_thr1));

   assign cfpscr_thr1_din_i0[55] = (ex7_fpscr_move[23] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[55] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[55] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[54] = (ex7_fpscr_move[22] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[54] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[54] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[53] = (ex7_fpscr_move[21] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[53] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[53] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[52] = tidn;		// reserved
   assign cfpscr_thr1_din_i0[51] = (ex7_fpscr_move[19] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[51] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[51] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[50] = (ex7_fpscr_move[18] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[50] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[50] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[49] = (ex7_fpscr_move[17] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[49] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[49] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[48] = (ex7_fpscr_move[16] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[48] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[48] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[47] = (ex7_fpscr_move[15] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[47] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[47] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[46] = (ex7_fpscr_move[14] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[46] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[46] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[45] = (ex7_fpscr_move[13] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[45] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[45] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[44] = (ex7_fpscr_move[12] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[44] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[44] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[43] = (ex7_fpscr_move[11] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[43] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[43] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[42] = (ex7_fpscr_move[10] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[42] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[42] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[41] = (ex7_fpscr_move[9] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[41] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[41] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[40] = (ex7_fpscr_move[8] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[40] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[40] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[39] = (ex7_fpscr_move[7] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[39] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[39] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[38] = (ex7_fpscr_move[6] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[38] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[38] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[37] = (ex7_fpscr_move[5] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[37] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[37] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[36] = (ex7_fpscr_move[4] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[36] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[36] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));
   assign cfpscr_thr1_din_i0[35] = (ex7_fpscr_move[3] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[35] & cfpscr_upd_i0_thr1) | (cfpscr_thr1_l2[35] & (~(ex7_upd_move_thr1 | cfpscr_upd_i0_thr1)));

   assign cfpscr_thr1_din_i0[34] = cfpscr_thr1_din_i0[39] | cfpscr_thr1_din_i0[40] | cfpscr_thr1_din_i0[41] | cfpscr_thr1_din_i0[42] | cfpscr_thr1_din_i0[43] | cfpscr_thr1_din_i0[44] | cfpscr_thr1_din_i0[53] | cfpscr_thr1_din_i0[54] | cfpscr_thr1_din_i0[55];		// vximx

   assign cfpscr_thr1_din_i0[33] = (cfpscr_thr1_din_i0[34] & cfpscr_thr1_din_i0[56]) | (cfpscr_thr1_din_i0[35] & cfpscr_thr1_din_i0[57]) | (cfpscr_thr1_din_i0[36] & cfpscr_thr1_din_i0[58]) | (cfpscr_thr1_din_i0[37] & cfpscr_thr1_din_i0[59]) | (cfpscr_thr1_din_i0[38] & cfpscr_thr1_din_i0[60]);		// zx  / ze

   assign cfpscr_thr1_din_i0[32] = (ex7_fpscr_move[0] & ex7_upd_move_thr1) | (cfpscr_pipe_thr1_i0[32] & (~ex7_upd_move_thr1)) | (cfpscr_new_excp_thr1_i0 & (~(((ex7_mtfsf | ex7_mtfsfi) & ex7_thread[1]) & (~f_dcd_ex7_cancel))));		//upd_pipe and hold sticky

   assign cfpscr_new_excp_thr1_i0 = ((~cfpscr_thr1_l2[35]) & cfpscr_thr1_din_i0[35]) | ((~cfpscr_thr1_l2[36]) & cfpscr_thr1_din_i0[36]) | ((~cfpscr_thr1_l2[37]) & cfpscr_thr1_din_i0[37]) | ((~cfpscr_thr1_l2[38]) & cfpscr_thr1_din_i0[38]) | ((~cfpscr_thr1_l2[39]) & cfpscr_thr1_din_i0[39]) | ((~cfpscr_thr1_l2[40]) & cfpscr_thr1_din_i0[40]) | ((~cfpscr_thr1_l2[41]) & cfpscr_thr1_din_i0[41]) | ((~cfpscr_thr1_l2[42]) & cfpscr_thr1_din_i0[42]) | ((~cfpscr_thr1_l2[43]) & cfpscr_thr1_din_i0[43]) | ((~cfpscr_thr1_l2[44]) & cfpscr_thr1_din_i0[44]) | ((~cfpscr_thr1_l2[53]) & cfpscr_thr1_din_i0[53]) | ((~cfpscr_thr1_l2[54]) & cfpscr_thr1_din_i0[54]) | ((~cfpscr_thr1_l2[55]) & cfpscr_thr1_din_i0[55]);		// vximx

   assign spare_unused[4:35] = cfpscr_thr1_din_i0[32:63];

   //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   // Completed FPSCR

   tri_rlmreg_p #(.WIDTH(36)) cfpscr_thr0_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[7]),
      .mpw1_b(mpw1_b[7]),
      .mpw2_b(mpw2_b[1]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(cfpscr_thr0_so),
      .scin(cfpscr_thr0_si),
      //-----------------
      .din({  cfpscr_thr0_din[28:63]}),
      .dout({  cfpscr_thr0_l2[28:63]})		//LAT--
   );


   tri_rlmreg_p #(.WIDTH(4)) cadd_lat_thr0(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[7]),
      .mpw1_b(mpw1_b[7]),
      .mpw2_b(mpw2_b[1]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(cadd_so),
      .scin(cadd_si),
      //-----------------
      .din({    re0_thr0,
                re1_thr0,
                re0_2_thr0,
                re1_2_thr0}),
      //-----------------
      .dout({   re0_2_thr0,
                re1_2_thr0,
                spare_unused[0],		//upd_i0_thr0,
                spare_unused[1]})		//upd_i1_thr0   );
   );

   assign upd_i0_thr0 = re0_2_thr0;
   assign upd_i1_thr0 = re1_2_thr0;

   generate
      if (THREADS == 2)
      begin : oscr_cadd_lat_thr1


         tri_rlmreg_p #(.WIDTH(36)) cfpscr_thr1_lat(
            .force_t(force_t),
            .d_mode(tiup),
            .delay_lclkr(delay_lclkr[7]),
            .mpw1_b(mpw1_b[7]),
            .mpw2_b(mpw2_b[1]),
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(tiup),
            .thold_b(thold_0_b),
            .sg(sg_0),
            .scout(cfpscr_thr1_so),
            .scin(cfpscr_thr1_si),
            //-----------------
            .din(  cfpscr_thr1_din[28:63]),
            .dout(  cfpscr_thr1_l2[28:63])		//LAT--
         );


         tri_rlmreg_p #(.WIDTH(4)) cadd_lat_thr1(
            .force_t(force_t),
            .d_mode(tiup),
            .delay_lclkr(delay_lclkr[7]),
            .mpw1_b(mpw1_b[7]),
            .mpw2_b(mpw2_b[1]),
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(tiup),
            .thold_b(thold_0_b),
            .sg(sg_0),
            .scout(cadd_thr1_so),
            .scin(cadd_thr1_si),
            //-----------------
            .din({    re0_thr1,
                      re1_thr1,
                      re0_2_thr1,
                      re1_2_thr1}),
            //-----------------
            .dout({   re0_2_thr1,
                      re1_2_thr1,
                      spare_unused[2],		//upd_i0_thr1,
                      spare_unused[3]})		//upd_i1_thr1   );
         );

         assign  upd_i0_thr1 = re0_2_thr1;
         assign  upd_i1_thr1 = re1_2_thr1;
      end
   endgenerate

   ////############################################
   ////# scan
   ////############################################

   assign ex5_ctl_si[0:24] = {ex5_ctl_so[1:24], f_scr_si};
   assign ex6_ctl_si[0:24] = {ex6_ctl_so[1:24], ex5_ctl_so[0]};
   assign ex7_ctl_si[0:24] = {ex7_ctl_so[1:24], ex6_ctl_so[0]};
   assign ex8_ctl_si[0:3] = {ex8_ctl_so[1:3], ex7_ctl_so[0]};
   assign ex7_flag_si[0:26] = {ex7_flag_so[1:26], ex8_ctl_so[0]};
   assign ex7_mvdat_si[0:35] = {ex7_mvdat_so[1:35], ex7_flag_so[0]};
   assign fpscr_th0_si[0:27] = {fpscr_th0_so[1:27], ex7_mvdat_so[0]};
   assign fpscr_th1_si[0:27] = {fpscr_th1_so[1:27], fpscr_th0_so[0]};
   assign fpscr_th2_si[0:27] = {fpscr_th2_so[1:27], fpscr_th1_so[0]};
   assign fpscr_th3_si[0:27] = {fpscr_th3_so[1:27], fpscr_th2_so[0]};
   assign ex8_crf_si[0:3] = {ex8_crf_so[1:3], fpscr_th3_so[0]};



   assign act_si[0:13] = {act_so[1:13], ex8_crf_so[0]};
   assign f_scr_so = act_so[0];

   //TODO fix me
   assign   ex7_hfpscr_pipe[0:2] = {tidn, tidn, tidn};
   assign   cfpscr_pipe_thr0[28:31] = {4{tidn}};

   assign     cfpscr_pipe_thr1[28:31] = {4{tidn}};
   assign     fpscr_th2_so = {28{tidn}};
   assign     fpscr_th3_so = {28{tidn}};


   assign cfpscr_thr1_si = {36{tidn}};
   assign cfpscr_thr0_si = {36{tidn}};

   assign cadd_thr1_si = {4{tidn}};
   assign cadd_si = {4{tidn}};

   assign fpscr_dfp_th2 =  {4{tidn}};
   assign fpscr_dfp_th3 =  {4{tidn}};
   assign   fpscr_th2 =  {24{tidn}};
   assign   fpscr_th3 =  {24{tidn}};

   assign unused_stuff = |(f_nrm_ex6_fpscr_wr_dat[24:31]) | ex7_mtfsbx | ex7_fpscr_move[1] |
                          ex7_fpscr_move[2] | ex7_fpscr_move[20] | ex7_fpscr_pipe[1] |
                          ex7_fpscr_pipe[2] | ex7_fpscr_pipe[20] | ex7_mv_data[1] | ex7_mv_data[2] |
                          ex7_mv_sel[1] | ex7_mv_sel[2];

endmodule
