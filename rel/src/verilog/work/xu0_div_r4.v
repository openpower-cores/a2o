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

//  Description:  XU Divide
//
//*****************************************************************************
`include "tri_a2o.vh"
module xu0_div_r4(
   // Clocks
   input [0:`NCLK_WIDTH-1] nclk,

   // Power
   inout                  vdd,
   inout                  gnd,

   // Pervasive
   input                  d_mode_dc,
   input                  delay_lclkr_dc,
   input                  mpw1_dc_b,
   input                  mpw2_dc_b,
   input                  func_sl_force,
   input                  func_sl_thold_0_b,
   input                  sg_0,
   input                  scan_in,
   output                 scan_out,

   // Decode Inputs
   input [0:7]            dec_div_ex1_div_ctr,
   input                  dec_div_ex1_div_act,
   input [0:`THREADS-1]    dec_div_ex1_div_val,
   input                  dec_div_ex1_div_sign,		// 0: Unsigned, 1: Signed
   input                  dec_div_ex1_div_size,		// 0: 32x32, 1: 64x64
   input                  dec_div_ex1_div_extd,		// 0: regular, 1: extended
   input                  dec_div_ex1_div_recform,
   input                  dec_div_ex1_xer_ov_update,

   // Source Data
   input [64-`GPR_WIDTH:63]  byp_div_ex2_rs1,		// NUM/DIVIDEND/RA
   input [64-`GPR_WIDTH:63]  byp_div_ex2_rs2,		// DEN/DIVISOR /RB
   input [0:9]            byp_div_ex2_xer,

   // Flush cycle counter
   input [0:`THREADS-1]    cp_flush,

   // Target Data
   output [64-`GPR_WIDTH:63] div_byp_ex4_rt,
   output                 div_byp_ex4_done,

   // Overflow
   output [0:9]           div_byp_ex4_xer,

   // Record form
   output [0:3]           div_byp_ex4_cr,

   // CM
   input                  ex1_spr_msr_cm,

   output [0:`THREADS-1]  div_spr_running
);

   localparam             msb = 64 - `GPR_WIDTH;
   // Latches
   wire [0:`THREADS-1]    perf_divrunning_q, perf_divrunning_d;
   wire [0:7]             ex2_div_ctr_q;
   wire                   ex2_div_val_q;
   wire                   ex2_div_sign_q;
   wire                   ex2_div_size_q;
   wire                   ex2_div_extd_q;
   wire                   ex2_div_recform_q;
   wire                   ex2_xer_ov_update_q;
   wire                   ex3_div_val_q;
   wire                   ex3_cycle_act_d;
   wire                   ex3_cycle_act_q;
   wire [0:7]             ex3_cycles_d;
   wire [0:7]             ex3_cycles_q;
   wire [msb:65]          ex3_denom_d;
   wire [msb:65]          ex3_denom_q;
   wire [msb:65]          ex3_dmask_d;
   wire [msb:65]          ex3_dmask_q;
   wire [msb:65]          ex3_dmask_q2;

   wire                   ex3_div_ovf_q;
   wire                   ex3_xer_ov_update_q;
   wire                   ex3_div_recform_q;
   wire                   ex3_div_size_q;
   wire                   ex3_div_sign_q;
   wire                   ex3_div_extd_q;
   wire                   ex3_2s_rslt_q;
   wire                   ex3_div_done_q;
   wire                   ex4_div_val_q;
   wire                   ex4_cycle_watch_d;
   wire                   ex4_cycle_watch_q;
   wire                   ex4_quot_watch_d;
   wire                   ex4_quot_watch_q;
   wire                   ex4_quot_watch_d_old;
   wire                   ex4_div_ovf_d;
   wire                   ex4_div_ovf_q;
   wire                   ex4_xer_ov_update_q;
   wire                   ex4_div_done_d;
   wire                   ex4_div_done_q;
   wire                   ex5_div_done_d;
   wire                   ex5_div_done_q;
   wire [msb:63]          ex4_quotient_d;
   wire [msb:63]          ex4_quotient_q;
   wire                   ex4_div_recform_q;
   wire                   ex4_div_size_q;
   wire                   ex4_2s_rslt_q;
   wire [msb:63]          ex4_div_rt_d;
   wire [msb:63]          ex4_div_rt_q;
   wire                   ex3_numer_eq_zero_q;
   wire                   ex3_numer_eq_zero_d;
   wire                   ex3_div_ovf_cond3;
   wire                   ex4_div_ovf_cond3_q;
   wire                   ex2_spr_msr_cm_q;
   wire [0:9]             xersrc_q;
   wire [0:`THREADS-1]     cp_flush_q;		//input=>cp_flush
   wire [0:`THREADS-1]     ex2_div_tid_q;		//input=>ex1_div_tid
   wire [0:`THREADS-1]     ex1_div_tid;
   wire [0:`THREADS-1]     ex3_div_tid_q;		//input=>ex2_div_tid_q
   wire                   ex2_cycles_sel0;
   wire                   ex2_cycles_sel1;
   wire                   ex2_cycles_sel2;
   wire                   ex3_oddshift_d;
   wire                   ex3_oddshift_q;
   wire                   ex3_oddshift;
   wire                   ex3_oddshift_set;
   wire                   ex3_oddshift_done;
   wire                   ex2_div_cnt_done;
   wire                   ex2_div_cnt_almost_done;
   wire                   ex2_div_almost_done;
   wire                   ex3_denom_shift_ctrl;
   wire                   ex3_denom_shift_ctrl0;
   wire                   ex3_denom_shift_ctrl1;
   wire                   ex3_denom_shift_ctrl2;
   wire                   ex3_dmask_shift_ctrl0;
   wire                   ex3_dmask_shift_ctrl1;
   wire                   ex3_dmask_shift_ctrl2;
   wire                   ex3_divrunning_d;
   wire                   ex3_divrunning_q;
   wire                   ex3_divrunning;
   wire                   ex3_divrunning_set;
   wire                   ex4_divrunning_act_d;
   wire                   ex4_divrunning_act_q;
   wire                   divrunning_act;
   wire                   ex4_divrunning_act_set;

   wire [msb:66]          ex3_lev0_csaout_sum;
   wire [msb:66]          ex3_lev0_csaout_carry;
   wire [msb:66]          ex3_lev0_csaoutsh_sum;
   wire [msb:66]          ex3_lev0_csaoutsh_carry;

   wire [msb:66]          ex3_lev0_csaout_carryout;
   wire [msb:66]          ex3_lev0_csaout_carryout_oddshift;
   wire [msb:66]          ex3_lev1_csaout_sum;
   wire [msb:66]          ex3_lev1_csaout_carry;
   wire [msb:66]          ex3_lev2_csaout_sum;
   wire [msb:66]          ex3_lev2_csaout_carry;
   wire [msb:66]          ex3_lev3_csaout_sum;
   wire [msb:66]          ex3_lev3_csaout_carry;
   wire [msb:66]          ex3_lev1_csaout_carryout;
   wire [msb:66]          ex3_lev2_csaout_carryout;
   wire [msb:66]          ex3_lev3_csaout_carryout;
   wire [msb:66]          ex3_lev22_csaout_carryout;
   wire [msb:66]          ex3_lev22_csaout_sum;
   wire [msb:66]          ex3_lev22_csaout_carry;

   wire [msb:66]          ex3_numer_d;
   wire [msb:66]          ex3_numer_q;
   wire [msb:66]          ex3_PR_sum_d;
   wire [msb:66]          ex3_PR_sum_q;
   wire [msb:66]          ex3_PR_carry_d;
   wire [msb:66]          ex3_PR_carry_q;
   wire [msb:66]          ex3_PR_sum_shift;
   wire [msb:66]          ex3_PR_sum_final;
   wire [msb:66]          ex3_PR_carry_shift;
   wire [msb:66]          ex3_PR_carry_final;
   wire [msb:66]          ex3_PR_sum_q_shifted;
   wire [msb:66]          ex3_PR_carry_q_shifted;
   wire                   ex3_quotient_ovf_cond4;
   wire                   ex3_quotient_ovf_cond4_wd;
   wire                   ex3_quotient_ovf_cond4_dw;

   wire                   ex3_PR_shiftctrl1;
   wire                   ex3_PR_shiftctrl2;
   wire                   ex3_PR_shiftctrl3;
   wire                   ex3_q_bit0;
   wire                   ex3_q_bit0_cin;
   wire                   ex3_q_bit1;
   wire                   ex3_q_bit1_cin;
   wire                   ex3_q_bit2;
   wire                   ex3_q_bit2_cin;
   wire                   ex3_q_bit3;
   wire                   ex3_q_bit3_cin;
   wire [0:1]             ex3_q_bit22_sel;
   wire                   ex3_nq_bit0;
   wire                   ex3_nq_bit1;
   wire                   ex3_nq_bit2;
   wire                   ex3_nq_bit3;
   wire                   ex3_q_bit22;
   wire                   ex3_nq_bit22;
   wire [msb:63]          ex4_div_rt;
   wire [msb:63]          ex3_Qin_lev0;
   wire [msb:63]          ex3_QMin_lev0;
   wire [msb:63]          ex3_Qin_lev1;
   wire [msb:63]          ex3_QMin_lev1;
   wire                   ex3_Qin_lev0_sel0;
   wire                   ex3_Qin_lev0_sel1;
   wire                   ex3_QMin_lev0_sel0;
   wire                   ex3_QMin_lev0_sel1;
   wire                   ex3_QMin_lev0_sel2;
   wire                   ex3_Qin_lev1_sel0;
   wire                   ex3_Qin_lev1_sel1;
   wire                   ex3_Qin_lev1_sel2;
   wire                   ex3_Qin_lev1_selinit;
   wire                   ex3_QMin_lev1_sel0;
   wire                   ex3_QMin_lev1_sel1;
   wire                   ex3_QMin_lev1_sel2;
   wire                   ex3_QMin_lev1_selinit;
   wire [0:3]             ex3_sum4;
   wire [0:3]             ex3_sum4addres;
   wire [0:3]             ex3_sum4_lev1;
   wire [0:3]             ex3_sum4_lev2;
   wire [0:3]             ex3_sum4_lev3;
   wire                   ex3_lev0_selD;
   wire                   ex3_lev0_selnD;
   wire                   ex3_lev0_sel0;
   wire                   ex3_lev22_selD;
   wire                   ex3_lev22_selnD;
   wire                   ex3_lev22_sel0;
   wire [msb:65]          ex3_denomQ_lev0;
   wire [msb:65]          ex3_denomQ_lev22;
   wire                   ex3_Q_sel0;
   wire                   ex3_Q_sel1;
   wire                   ex3_Q_sel2;
   wire [msb:63]          ex3_Q_q;
   wire [msb:63]          ex3_Q_d;
   wire [msb:63]          ex3_QM_q;
   wire [msb:63]          ex3_QM_d;
   wire [msb:66]          ex3_add_rslt;
   wire                   ex3_add_rslt_sign_d;
   wire                   ex3_add_rslt_sign_q;
   wire                   ex3_quotient_correction;
   wire                   ex4_quotient_correction;
   wire [msb:63]          ex4_div_rt_op1;
   wire [msb:63]          ex4_div_rt_op2;
   wire                   ex4_addop_sel0;
   wire                   ex4_addop_sel1;
   wire                   ex4_addop_sel2;
   wire                   ex4_addop_sel3;



    // synopsys translate_off
    (* analysis_not_referenced="true" *)
    // synopsys translate_on
   wire unused;

   // Scanchains
   localparam             ex2_div_ctr_offset = 0;
   localparam             ex2_div_val_offset = ex2_div_ctr_offset + 8;
   localparam             ex2_div_sign_offset = ex2_div_val_offset + 1;
   localparam             ex2_div_size_offset = ex2_div_sign_offset + 1;
   localparam             ex2_div_extd_offset = ex2_div_size_offset + 1;
   localparam             ex2_div_recform_offset = ex2_div_extd_offset + 1;
   localparam             ex2_xer_ov_update_offset = ex2_div_recform_offset + 1;
   localparam             ex3_div_val_offset = ex2_xer_ov_update_offset + 1;
   localparam             ex3_cycle_act_offset = ex3_div_val_offset + 1;
   localparam             ex3_cycles_offset = ex3_cycle_act_offset + 1;
   localparam             ex3_denom_offset = ex3_cycles_offset + 8;
   localparam             ex3_numer_offset = ex3_denom_offset + (65-msb+1);

   localparam             ex3_PR_sum_offset = ex3_numer_offset + (66-msb+1);
   localparam             ex3_PR_carry_offset = ex3_PR_sum_offset + (66-msb+1);
   localparam             ex3_Q_offset = ex3_PR_carry_offset + (66-msb+1);
   localparam             ex3_QM_offset = ex3_Q_offset + (63-msb+1);
   localparam             ex3_oddshift_offset = ex3_QM_offset + (63-msb+1);
   localparam             ex3_divrunning_offset = ex3_oddshift_offset + 1;
   localparam             ex4_divrunning_act_offset = ex3_divrunning_offset + 1;
   localparam             ex3_divflush_1d_offset = ex4_divrunning_act_offset + 1;
   localparam             ex4_divflush_2d_offset = ex3_divflush_1d_offset + 1;

   localparam             ex3_add_rslt_sign_offset = ex4_divflush_2d_offset + 1;
   localparam             ex4_quotient_correction_offset = ex3_add_rslt_sign_offset + 1;
   localparam             ex3_dmask_offset = ex4_quotient_correction_offset + 1;

   localparam             ex3_div_ovf_offset = ex3_dmask_offset + (65-msb+1);
   localparam             ex3_xer_ov_update_offset = ex3_div_ovf_offset + 1;
   localparam             ex3_div_recform_offset = ex3_xer_ov_update_offset + 1;
   localparam             ex3_div_size_offset = ex3_div_recform_offset + 1;
   localparam             ex3_div_sign_offset = ex3_div_size_offset + 1;
   localparam             ex3_div_extd_offset = ex3_div_sign_offset + 1;
   localparam             ex3_2s_rslt_offset = ex3_div_extd_offset + 1;
   localparam             ex3_div_done_offset = ex3_2s_rslt_offset + 1;
   localparam             ex4_div_val_offset = ex3_div_done_offset + 1;
   localparam             ex4_cycle_watch_offset = ex4_div_val_offset + 1;
   localparam             ex4_quot_watch_offset = ex4_cycle_watch_offset + 1;
   localparam             ex4_div_ovf_offset = ex4_quot_watch_offset + 1;
   localparam             ex4_xer_ov_update_offset = ex4_div_ovf_offset + 1;
   localparam             ex4_div_done_offset = ex4_xer_ov_update_offset + 1;
   localparam             ex5_div_done_offset = ex4_div_done_offset + 1;
   localparam             ex4_quotient_offset = ex5_div_done_offset + 1;
   localparam             ex4_div_recform_offset = ex4_quotient_offset + (63-msb+1);
   localparam             ex4_div_size_offset = ex4_div_recform_offset + 1;
   localparam             ex4_2s_rslt_offset = ex4_div_size_offset + 1;
   localparam             ex4_div_rt_offset = ex4_2s_rslt_offset + 1;
   localparam             ex3_numer_eq_zero_offset = ex4_div_rt_offset + (63-msb+1);
   localparam             ex4_div_ovf_cond3_offset = ex3_numer_eq_zero_offset + 1;
   localparam             ex2_spr_msr_cm_offset = ex4_div_ovf_cond3_offset + 1;
   localparam             xersrc_offset = ex2_spr_msr_cm_offset + 1;
   localparam             cp_flush_offset = xersrc_offset + 10;
   localparam             ex2_div_tid_offset = cp_flush_offset + `THREADS;
   localparam             ex3_div_tid_offset = ex2_div_tid_offset + `THREADS;
	localparam             perf_divrunning_offset = ex3_div_tid_offset + `THREADS;
	localparam             scan_right = perf_divrunning_offset         + `THREADS;

   wire [0:scan_right-1]  sov;
   wire [0:scan_right-1]  siv;
   // Signals
   wire [msb:65]          ex3_denom_norm;

   wire [msb:63]          ex2_denom;
   wire [msb:63]          ex2_numer;
   wire [msb:65]          mask;
   wire [msb:66]          ex3_sub_rslt;
   wire                   ex2_div_done;
   wire                   ex2_num_cmp0_lo_nomsb;
   wire                   ex2_num_cmp0_hi_nomsb;
   wire                   ex2_num_cmp0_lo;
   wire                   ex2_num_cmp0_hi;
   wire                   ex2_den_cmp0_lo;
   wire                   ex2_den_cmp0_hi;
   wire                   ex2_den_cmp1_lo;
   wire                   ex2_den_cmp1_hi;
   wire                   ex4_qot_cmp0_lo;
   wire                   ex4_qot_cmp0_hi;
   wire                   ex2_div_ovf_cond1_wd;
   wire                   ex2_div_ovf_cond1_dw;
   wire                   ex2_div_ovf_cond1;
   wire                   ex2_div_ovf_cond2;
   wire                   ex3_div_ovf_cond4;
   wire                   ex3_rslt_sign;
   wire                   ex3_den_eq_num;
   wire                   ex3_den_gte_num;
   wire                   ex2_div_ovf;
   wire [msb:63]          ex2_divsrc_0;
   wire [msb:63]          ex2_divsrc_0_2s;
   wire [msb:63]          ex2_divsrc_1;
   wire [msb:63]          ex2_divsrc_1_2s;
   wire                   ex2_2s_rslt;
   wire                   ex2_src0_sign;
   wire                   ex2_src1_sign;

   wire                   ex4_cmp0_undef;
   wire                   ex4_cmp0_eq;
   wire                   ex4_cmp0_gt;
   wire                   ex4_cmp0_lt;
   wire [msb:63]          ex4_quotient_2s;
   wire [0:7]             ex3_cycles_din;
   wire                   ex3_cycles_gt_64;
   wire                   ex3_cycles_gt_32;
   wire                   ex4_lt;
   wire [msb:65]          ex3_denom_rot;
   wire [msb:65]          ex3_denom_rot2;
   wire                   ex1_div_val;
   wire                   ex1_div_v;
   wire                   ex2_div_val;
   wire                   div_flush;
   wire                   div_flush_1d;
   wire                   div_flush_2d;
   wire                   tiup;
   wire                   tidn;

   //--------------------------------------------------------------
   //!! Bugspray Include: xu0_div_r4;




   //     def divide(num,den,size):
   //         q = 0
   //         m = pow(2,size)-1
   //         cycle = size+1
   //
   //         # Normalize
   //         p = m
   //
   //         while cycle>0:
   //             r = den & p
   //             if r == 0:
   //                 break
   //             den = rotR1(den,size)
   //             p = p>>1
   //             cycle -= 1
   //
   //         den = ((~den + 1) & m) | 2**size
   //         size = size + 1
   //         m = pow(2,size)-1
   //
   //         # Divide
   //         while cycle>0:
   //             # Subtract
   //             a = (num+den) & m
   //             if signbit(a,size)==0:    # Positive
   //                 q = rotL1(q,size,m) | 1     # 0b...x | 0b0001 = 0b...1
   //                 num = rotL1(a,size,m)
   //             else:
   //                 q = rotL1(q,size,m) & -2    # 0b...x & 0b1110 = 0b...0
   //                 num = rotL1(num,size,m)
   //             cycle -= 1
   //     return q

   assign tiup = 1'b1;
   assign tidn = 1'b0;
   //-------------------------------------------------------------------
   // Summary example, divd
   //-------------------------------------------------------------------
   // ex2_cycles_din=33  ex1_div_val=1
   // ex2_cycles_din=32  ex2_denom_q contains the unnormalized denominator
   //                    and ex2_denom_shift_ctrl* indicates if it will need to be rotated
   //
   // when the denominator is finished shifting, ex2_denom_shift_ctrl=0 and
   // quotient bits will start showing up in ex2_Qin_lev1
   // if the denominator needed to be shifted by an odd amount, ex2_cycles_din will be held
   // for an extra cycle. The last cycle it will be repeated is when ex2_denom_shift_ctrl1=1
   //
   //
   //
   // ex2_cycles_din=33    (first cycle that ex2_denom_shift_ctrl is on?)
   //
   // ex2_cycles_din=1     ex1_div_almost_done=1.  this is the last cycle that the algorithm can be working in
   //                      ex2_Q_d contains the quotient before correction for 2's comp and off-by-one.
   //                      ex2_PR_sum_q should contain the intermediate sum or the original numerator
   //                      in this cycle (such as in the case of a long denom rotate)
   //                      also denominator rotation should be finished, and ex2_denom_q must contain the normalized denominator
   //
   // ex2_cycles_din=0     the final remainder is summed in this cycle to determine if a quotient correction
   //                      is needed.  ex3_quotient_d contains the intermediate result
   //                      ex2_quotient_correction is the result of the remainder sum
   //
   // ex2_cycles_din=0-1  (one cycle after) ex3_div_rt_d is the result of the quotient corrected/2's comp result.
   //                      ex3_div_rt_op2 contains the correction value
   //                      ex3_quotient_q contains the unadjusted quotient (not 2's comp yet, not quotient corrected)
   //
   // ex2_cycles_din=0-2  (two cycles after) ex3_div_rt contains the result, and ex3_div_done_q=1
   //                      ex3_div_rt_q contains the result before overflow gating
   //

   //-------------------------------------------------------------------
   // unused
   //-------------------------------------------------------------------
   assign unused = |( {ex3_lev0_sel0,
                       ex3_lev0_csaout_carryout[0],
                       ex3_lev0_csaout_carryout_oddshift,
                       ex3_lev1_csaout_sum[4],
                       ex3_lev1_csaout_sum[6:66],
                       ex3_lev1_csaout_carryout[0],
                       ex3_lev1_csaout_carry[4],
                       ex3_lev1_csaout_carry[6:66],
                       ex3_lev2_csaout_sum[4],
                       ex3_lev2_csaout_sum[6:66],
                       ex3_lev2_csaout_carryout[0],
                       ex3_lev2_csaout_carry[4],
                       ex3_lev2_csaout_carry[6:66],
                       ex3_lev3_csaout_sum[4],
                       ex3_lev3_csaout_sum[6:66],
                       ex3_lev3_csaout_carryout[0],
                       ex3_lev3_csaout_carry[4],
                       ex3_lev3_csaout_carry[6:66],
                       ex3_lev22_sel0,
                       ex3_lev22_csaout_carryout[0],
                       ex3_add_rslt[1:66],
                       ex3_sub_rslt[1:66],
                       ex4_quot_watch_d_old,
                       div_flush_2d,
                       ex3_add_rslt_sign_q,
                       ex4_div_recform_q,
                       ex3_div_tid_q
  });

   //-------------------------------------------------------------------
   // Initialize cycle counter
   //-------------------------------------------------------------------
   assign ex1_div_val = |(dec_div_ex1_div_val & (~cp_flush));
   assign ex1_div_v = |(dec_div_ex1_div_val);

   assign ex1_div_tid = dec_div_ex1_div_val;

   assign ex2_div_val = ex2_div_val_q & (~div_flush);

   // ATW div_flush was originally using ex3_div_tid, which is not upated early enough.
   // Some signal used were ex2 stage, so div_tid was not yet updated
   // Changed to use EX2 signal, and clock gated ex2_div_tid_q latch
   assign div_flush = |(ex2_div_tid_q & cp_flush_q);

   assign ex2_cycles_sel0 = ex2_div_val;
   assign ex2_cycles_sel1 = (ex3_oddshift_set | ((ex2_div_cnt_almost_done) & ex3_denom_shift_ctrl)) & (~ex2_div_val);
   assign ex2_cycles_sel2 = (~(ex3_oddshift_set | ((ex2_div_cnt_almost_done) & ex3_denom_shift_ctrl))) & (~ex2_div_val);

   // init
   assign ex3_cycles_din = (ex2_div_ctr_q          & {8{ex2_cycles_sel0}}) |
                           (ex3_cycles_q           & {8{ex2_cycles_sel1}}) |
                           ((ex3_cycles_q - 8'b00000001)  & {8{ex2_cycles_sel2}});		// hold for odd cases
   // decrement

   // Clear counter if the divide was flushed
   assign ex3_cycles_d =  div_flush==1'b0 ? ex3_cycles_din : 8'b0;

   assign ex3_cycle_act_d = ex2_div_val | (ex3_cycle_act_q & ~ex3_div_done_q & |ex3_cycles_q);

   assign ex2_div_cnt_done        = (ex3_cycles_q == 8'b00000001) ? 1'b1 : 1'b0;
   assign ex2_div_cnt_almost_done = (ex3_cycles_q == 8'b00000010) ? 1'b1 : 1'b0;

   assign ex2_div_done = ex2_div_cnt_done & (~ex3_denom_shift_ctrl1) & (~div_flush);
   assign ex2_div_almost_done = ex2_div_cnt_almost_done & (~ex3_denom_shift_ctrl1) & (~div_flush);

   assign ex4_div_done_d = ex3_div_done_q & (~div_flush);

   assign div_byp_ex4_done = ex4_div_done_q;

   assign ex5_div_done_d = ex4_div_done_q;

   //-------------------------------------------------------------------
   // 2's complement negative operands for signed divide
   //-------------------------------------------------------------------
   assign ex2_divsrc_0_2s = (~byp_div_ex2_rs1) + 1;
   assign ex2_divsrc_1_2s = (~byp_div_ex2_rs2) + 1;

   // Need to 2's complement the result if one of the operands is negative
   generate
      if (`GPR_WIDTH == 64)
      begin : div_64b_2scomp

         assign ex2_2s_rslt = (ex2_div_size_q == 1'b1) ? (byp_div_ex2_rs1[0] ^ byp_div_ex2_rs2[0]) & ex2_div_sign_q :
                              (byp_div_ex2_rs1[32] ^ byp_div_ex2_rs2[32]) & ex2_div_sign_q;

         assign ex2_src0_sign = (ex2_div_size_q == 1'b1) ? byp_div_ex2_rs1[0] :
                                byp_div_ex2_rs1[32];
         assign ex2_src1_sign = (ex2_div_size_q == 1'b1) ? byp_div_ex2_rs2[0] :
                                byp_div_ex2_rs2[32];
      end
   endgenerate
   generate
      if (`GPR_WIDTH == 32)
      begin : div_32b_2scomp
         assign ex2_2s_rslt = (byp_div_ex2_rs1[32] ^ byp_div_ex2_rs2[32]) & ex2_div_sign_q;
         assign ex2_src0_sign = byp_div_ex2_rs1[32];
         assign ex2_src1_sign = byp_div_ex2_rs2[32];
      end
   endgenerate

   assign ex2_divsrc_0 = ((ex2_div_sign_q & ex2_src0_sign) == 1'b1) ? ex2_divsrc_0_2s :
                         byp_div_ex2_rs1;

   //-------------------------------------------------------------------
   // Fixup Operands for Word/DW Mode
   //-------------------------------------------------------------------
   assign ex2_divsrc_1 = ((ex2_div_sign_q & ex2_src1_sign) == 1'b1) ? ex2_divsrc_1_2s :
                         byp_div_ex2_rs2;

   generate
      if (`GPR_WIDTH == 64)
      begin : div_setup_64b

         assign ex2_denom[0:31]  = (ex2_div_size_q == 1'b1) ? ex2_divsrc_1[0:31]  : ex2_divsrc_1[32:63];
         assign ex2_denom[32:63] = (ex2_div_size_q == 1'b1) ? ex2_divsrc_1[32:63] : 32'b0;

         assign ex2_numer[0:31]  = (ex2_div_size_q == 1'b1) ? ex2_divsrc_0[0:31]  : ex2_divsrc_0[32:63];
         assign ex2_numer[32:63] = (ex2_div_size_q == 1'b1) ? ex2_divsrc_0[32:63] : 32'b0;

         assign mask = {{34{1'b1}}, {32{ex2_div_size_q}}};

         // Rotate just the upper 32 for word mode

         assign ex3_denom_rot[0]     = (ex2_div_size_q == 1'b1) ? ex3_denom_q[65]     : ex3_denom_q[33];
         assign ex3_denom_rot[1:33]  =                            ex3_denom_q[msb:32];
         assign ex3_denom_rot[34:65] = (ex3_div_size_q == 1'b1) ? ex3_denom_q[33:64]  : 32'b0;

         assign ex3_denom_rot2[0]    = (ex2_div_size_q == 1'b1) ? ex3_denom_q[64]     : ex3_denom_q[32];

         assign ex3_denom_rot2[1]    = (ex2_div_size_q == 1'b1) ? ex3_denom_q[65]     : ex3_denom_q[33];
         assign ex3_denom_rot2[2:33] =                            ex3_denom_q[msb:31];
         assign ex3_denom_rot2[34:65]= (ex3_div_size_q == 1'b1) ? ex3_denom_q[32:63]  : 32'b0;
      end
   endgenerate

   generate
      if (`GPR_WIDTH == 32)
      begin : div_setup_32b
         assign ex2_denom = ex2_divsrc_1;
         assign ex2_numer = ex2_divsrc_0;

         assign mask = {65-msb{1'b1}};

         assign ex3_denom_rot = {ex3_denom_q[65], ex3_denom_q[msb:64]};
         assign ex3_denom_rot2 = {ex3_denom_q[64], ex3_denom_q[65], ex3_denom_q[msb:63]};
      end
   endgenerate

   //-------------------------------------------------------------------
   // Normalize Denominator
   //-------------------------------------------------------------------
   // Grab denominator from bypass, shift until normalized, then hold.

   // Mask

   assign ex3_dmask_shift_ctrl0 = ex2_div_val_q;
   assign ex3_dmask_shift_ctrl1 = ex3_denom_shift_ctrl1 & (~ex2_div_val_q);
   assign ex3_dmask_shift_ctrl2 = ex3_denom_shift_ctrl2 & (~ex2_div_val_q);

   assign ex3_dmask_d = (mask                               & {66-msb{ex3_dmask_shift_ctrl0}}) |
                        ({1'b0, ex3_dmask_q[msb:64]}        & {66-msb{ex3_dmask_shift_ctrl1}}) |
                        ({2'b00, ex3_dmask_q[msb:63]}       & {66-msb{ex3_dmask_shift_ctrl2}});

   assign ex3_dmask_q2 = (({ex3_dmask_q[msb:64], 1'b0})           & {66-msb{  ex2_div_size_q}}) |
                         (({ex3_dmask_q[msb:32], 1'b0, 32'd0})     & {66-msb{(~ex2_div_size_q)}});		// still can shift one more

   assign ex3_denom_shift_ctrl = ex3_denom_shift_ctrl1 | ex3_denom_shift_ctrl2;
   assign ex3_denom_shift_ctrl0 = (~ex3_denom_shift_ctrl);
   assign ex3_denom_shift_ctrl1 = ((ex3_denom_q[65] & ex3_dmask_q[65] & ex2_div_size_q) | (ex3_denom_q[33] & ex3_dmask_q[33] & (~ex2_div_size_q))) & (~ex3_denom_shift_ctrl2);
   assign ex3_denom_shift_ctrl2 = |(ex3_denom_q & ex3_dmask_q2);

   // don't shift
   assign ex3_denom_norm = (ex3_denom_q      & {66-msb{ex3_denom_shift_ctrl0}}) |
                           (ex3_denom_rot    & {66-msb{ex3_denom_shift_ctrl1}}) |
                           (ex3_denom_rot2   & {66-msb{ex3_denom_shift_ctrl2}});		// rotate 1 right
   // rotate 2 right

   assign ex3_denom_d = (ex2_div_val_q == 1'b1) ? {2'b00, ex2_denom} :
                        ex3_denom_norm;
   assign ex3_oddshift_set = ex3_denom_shift_ctrl1 & ex3_divrunning;
   assign ex3_oddshift_d = (ex3_oddshift_set | ex3_oddshift_q) & (~(ex4_div_done_q | div_flush));
   assign ex3_oddshift = ex3_oddshift_q;

   assign ex3_divrunning_set = ex2_div_val_q;
   assign ex3_divrunning_d = (ex3_divrunning_set | ex3_divrunning_q) & (~(ex3_div_done_q | div_flush));
   assign ex3_divrunning = ex3_divrunning_q;

   assign perf_divrunning_d = dec_div_ex1_div_val | (perf_divrunning_q & ~({`THREADS{ex2_div_done}} | cp_flush_q));

   assign div_spr_running  = perf_divrunning_q;

   assign ex4_divrunning_act_set = ex1_div_v;
   assign ex4_divrunning_act_d = ex4_divrunning_act_set | (ex4_divrunning_act_q & (~ex5_div_done_q));
   assign divrunning_act = ex4_divrunning_act_q;

   //-------------------------------------------------------------------
   // Load the numerator upon init, or shift by 1 if odd, 2 if even
   //-------------------------------------------------------------------

   assign ex3_PR_sum_d = (ex2_div_val_q == 1'b1) ? {3'b000, ex2_numer} : 		// hold if the denom is being normalized
                         ex3_PR_sum_shift;
   assign ex3_PR_shiftctrl1 = ex3_denom_shift_ctrl;
   assign ex3_PR_shiftctrl2 = (~(ex3_oddshift_done)) & (~ex3_denom_shift_ctrl);
   assign ex3_PR_shiftctrl3 = ex3_oddshift_done & (~ex3_denom_shift_ctrl);

   // oddshift
   assign ex3_PR_sum_shift = (ex3_lev0_csaoutsh_sum[msb:66]       & {67-msb{ex3_PR_shiftctrl3}}) |
                             (ex3_PR_sum_final[msb:66]            & {67-msb{ex3_PR_shiftctrl2}}) |
                             (ex3_PR_sum_q[msb:66]                & {67-msb{ex3_PR_shiftctrl1}});		// dividing
   // hold if normalizing

   assign ex3_PR_carry_d = (ex2_div_val_q == 1'b1) ? {67-msb{1'b0}} : 		// oddshift
                           ex3_PR_carry_shift;
   assign ex3_PR_carry_shift = (ex3_lev0_csaoutsh_carry[msb:66]   & {67-msb{ex3_PR_shiftctrl3}}) |
                               (ex3_PR_carry_final[msb:66]        & {67-msb{ex3_PR_shiftctrl2}}) |
                               (ex3_PR_carry_q[msb:66]            & {67-msb{ex3_PR_shiftctrl1}});		// hold if normalizing

   //-------------------------------------------------------------------
   // Initial 4-bit add and quotient select
   //-------------------------------------------------------------------

   assign ex3_sum4addres = ex3_PR_sum_q[msb + 0:msb + 3] + ex3_PR_carry_q[msb + 0:msb + 3];

   assign ex3_sum4 = ex3_sum4addres;

   assign ex3_q_bit0_cin = ex3_PR_sum_q[msb + 5] | ex3_PR_carry_q[msb + 5];

   assign ex3_q_bit0 = (ex3_sum4 == 4'b0000) ? ex3_q_bit0_cin :
                       (ex3_sum4 == 4'b0001) ? 1'b1 :
                       (ex3_sum4 == 4'b0010) ? 1'b1 :
                       (ex3_sum4 == 4'b0011) ? 1'b1 :
                       (ex3_sum4 == 4'b0100) ? 1'b1 :
                       (ex3_sum4 == 4'b0101) ? 1'b1 :
                       (ex3_sum4 == 4'b0110) ? 1'b1 :
                       (ex3_sum4 == 4'b0111) ? 1'b1 :
                       1'b0;

   //-------------------------------------------------------------------
   // on-the-fly quotient digit conversion logic for level 0
   //-------------------------------------------------------------------
   // Qin=(Q & q) if q >= 0.  Qin=(QM & 1) if q < 0

   assign ex3_nq_bit0 = (ex3_sum4 == 4'b1000) ? 1'b1 :
                        (ex3_sum4 == 4'b1001) ? 1'b1 :
                        (ex3_sum4 == 4'b1010) ? 1'b1 :
                        (ex3_sum4 == 4'b1011) ? 1'b1 :
                        (ex3_sum4 == 4'b1100) ? 1'b1 :
                        (ex3_sum4 == 4'b1101) ? 1'b1 :
                        (ex3_sum4 == 4'b1110) ? 1'b1 :
                        1'b0;
   assign ex3_Qin_lev0_sel0 = ex3_q_bit0 | ((~ex3_nq_bit0));
   assign ex3_Qin_lev0_sel1 = ex3_nq_bit0;

   assign ex3_Qin_lev0[msb:63] = (({ex3_Q_q[msb + 1:63], ex3_q_bit0}) & {`GPR_WIDTH{ex3_Qin_lev0_sel0}}) | (({ex3_QM_q[msb + 1:63], 1'b1}) & {`GPR_WIDTH{ex3_Qin_lev0_sel1}});

   // QMin=(Q & 0) if q > 0. QMin=(QM & 0) if q < 0.  QMin=(QM & 1) if q = 0
   assign ex3_QMin_lev0_sel0 = ex3_q_bit0;
   assign ex3_QMin_lev0_sel1 = ex3_nq_bit0;
   assign ex3_QMin_lev0_sel2 = (~(ex3_nq_bit0 | ex3_q_bit0));

   assign ex3_QMin_lev0[msb:63] = (({ex3_Q_q[msb + 1:63], 1'b0})     & {`GPR_WIDTH{ex3_QMin_lev0_sel0}}) |
                                  (({ex3_QM_q[msb + 1:63], 1'b0})    & {`GPR_WIDTH{ex3_QMin_lev0_sel1}}) |
                                  (({ex3_QM_q[msb + 1:63], 1'b1})    & {`GPR_WIDTH{ex3_QMin_lev0_sel2}});

   //-------------------------------------------------------------------
   // Initial Denominator mux and 3:2 CSA
   //-------------------------------------------------------------------

   assign ex3_PR_sum_q_shifted = {ex3_PR_sum_q[msb + 1:66], 1'b0};
   assign ex3_PR_carry_q_shifted = {ex3_PR_carry_q[msb + 1:66], 1'b0};

   assign ex3_lev0_selD = ex3_nq_bit0 & (~ex3_q_bit0);
   assign ex3_lev0_selnD = ex3_q_bit0 & (~ex3_nq_bit0);
   assign ex3_lev0_sel0 = (~ex3_q_bit0) & (~ex3_nq_bit0);

   assign ex3_denomQ_lev0 = ((~ex3_denom_q) & {66-msb{ex3_lev0_selnD}}) | (ex3_denom_q & {66-msb{ex3_lev0_selD}});

   assign ex3_lev0_csaoutsh_sum = {ex3_lev0_selnD, ex3_denomQ_lev0} ^ ex3_PR_sum_q_shifted ^ ex3_PR_carry_q_shifted;

   assign ex3_lev0_csaout_carryout = (({ex3_lev0_selnD, ex3_denomQ_lev0}) & ex3_PR_sum_q_shifted) | (({ex3_lev0_selnD, ex3_denomQ_lev0}) & ex3_PR_carry_q_shifted) | (ex3_PR_sum_q_shifted & ex3_PR_carry_q_shifted);

   assign ex3_lev0_csaout_carryout_oddshift = (({ex3_lev0_selnD, ex3_denomQ_lev0}) & ex3_PR_sum_q) | (({ex3_lev0_selnD, ex3_denomQ_lev0}) & ex3_PR_carry_q) | (ex3_PR_sum_q & ex3_PR_carry_q);

   assign ex3_lev0_csaoutsh_carry[msb:66] = {ex3_lev0_csaout_carryout[msb + 1:66], ex3_lev0_selnD};

   // todo above:  the selnD tacked on at the end needs to go into the middle for the word case?

   //-------------------------------------------------------------------
   // Pick -d, 0, +d
   //-------------------------------------------------------------------
   // neg d, +q ========================================================
   assign ex3_lev1_csaout_sum = ({1'b1, (~ex3_denom_q)}) ^ ex3_PR_sum_q_shifted ^ ex3_PR_carry_q_shifted;

   assign ex3_lev1_csaout_carryout = (({1'b1, (~ex3_denom_q)}) & ex3_PR_sum_q_shifted) | (({1'b1, (~ex3_denom_q)}) & ex3_PR_carry_q_shifted) | (ex3_PR_sum_q_shifted & ex3_PR_carry_q_shifted);

   assign ex3_lev1_csaout_carry[msb:66] = {ex3_lev1_csaout_carryout[msb + 1:66], 1'b1};

   assign ex3_sum4_lev1 = ex3_lev1_csaout_sum[msb + 0:msb + 3] + ex3_lev1_csaout_carry[msb + 0:msb + 3];

   assign ex3_q_bit1_cin = ex3_lev1_csaout_sum[msb + 5] | ex3_lev1_csaout_carry[msb + 5];

   assign ex3_q_bit1 = (ex3_sum4_lev1 == 4'b0000) ? ex3_q_bit1_cin :
                       (ex3_sum4_lev1 == 4'b0001) ? 1'b1 :
                       (ex3_sum4_lev1 == 4'b0010) ? 1'b1 :
                       (ex3_sum4_lev1 == 4'b0011) ? 1'b1 :
                       (ex3_sum4_lev1 == 4'b0100) ? 1'b1 :
                       (ex3_sum4_lev1 == 4'b0101) ? 1'b1 :
                       (ex3_sum4_lev1 == 4'b0110) ? 1'b1 :
                       (ex3_sum4_lev1 == 4'b0111) ? 1'b1 :
                       1'b0;

   // zero ===========================================================
   assign ex3_nq_bit1 = (ex3_sum4_lev1 == 4'b1000) ? 1'b1 :
                        (ex3_sum4_lev1 == 4'b1001) ? 1'b1 :
                        (ex3_sum4_lev1 == 4'b1010) ? 1'b1 :
                        (ex3_sum4_lev1 == 4'b1011) ? 1'b1 :
                        (ex3_sum4_lev1 == 4'b1100) ? 1'b1 :
                        (ex3_sum4_lev1 == 4'b1101) ? 1'b1 :
                        (ex3_sum4_lev1 == 4'b1110) ? 1'b1 :
                        1'b0;
   assign ex3_lev2_csaout_sum = ex3_PR_sum_q_shifted ^ ex3_PR_carry_q_shifted;

   assign ex3_lev2_csaout_carryout = (ex3_PR_sum_q_shifted & ex3_PR_carry_q_shifted);

   assign ex3_lev2_csaout_carry[msb:66] = {ex3_lev2_csaout_carryout[msb + 1:66], 1'b0};

   assign ex3_sum4_lev2 = ex3_lev2_csaout_sum[msb + 0:msb + 3] + ex3_lev2_csaout_carry[msb + 0:msb + 3];

   assign ex3_q_bit2_cin = ex3_lev2_csaout_sum[msb + 5] | ex3_lev2_csaout_carry[msb + 5];

   assign ex3_q_bit2 = (ex3_sum4_lev2 == 4'b0000) ? ex3_q_bit2_cin :
                       (ex3_sum4_lev2 == 4'b0001) ? 1'b1 :
                       (ex3_sum4_lev2 == 4'b0010) ? 1'b1 :
                       (ex3_sum4_lev2 == 4'b0011) ? 1'b1 :
                       (ex3_sum4_lev2 == 4'b0100) ? 1'b1 :
                       (ex3_sum4_lev2 == 4'b0101) ? 1'b1 :
                       (ex3_sum4_lev2 == 4'b0110) ? 1'b1 :
                       (ex3_sum4_lev2 == 4'b0111) ? 1'b1 :
                       1'b0;

   // pos d, -q =======================================================
   assign ex3_nq_bit2 = (ex3_sum4_lev2 == 4'b1000) ? 1'b1 :
                        (ex3_sum4_lev2 == 4'b1001) ? 1'b1 :
                        (ex3_sum4_lev2 == 4'b1010) ? 1'b1 :
                        (ex3_sum4_lev2 == 4'b1011) ? 1'b1 :
                        (ex3_sum4_lev2 == 4'b1100) ? 1'b1 :
                        (ex3_sum4_lev2 == 4'b1101) ? 1'b1 :
                        (ex3_sum4_lev2 == 4'b1110) ? 1'b1 :
                        1'b0;
   assign ex3_lev3_csaout_sum = ({1'b0, ex3_denom_q}) ^ ex3_PR_sum_q_shifted ^ ex3_PR_carry_q_shifted;

   assign ex3_lev3_csaout_carryout = (({1'b0, ex3_denom_q}) & ex3_PR_sum_q_shifted) | (({1'b0, ex3_denom_q}) & ex3_PR_carry_q_shifted) | (ex3_PR_sum_q_shifted & ex3_PR_carry_q_shifted);

   assign ex3_lev3_csaout_carry[msb:66] = {ex3_lev3_csaout_carryout[msb + 1:66], 1'b0};

   assign ex3_sum4_lev3 = ex3_lev3_csaout_sum[msb + 0:msb + 3] + ex3_lev3_csaout_carry[msb + 0:msb + 3];

   assign ex3_q_bit3_cin = ex3_lev3_csaout_sum[msb + 5] | ex3_lev3_csaout_carry[msb + 5];

   assign ex3_q_bit3 = (ex3_sum4_lev3 == 4'b0000) ? ex3_q_bit3_cin :
                       (ex3_sum4_lev3 == 4'b0001) ? 1'b1 :
                       (ex3_sum4_lev3 == 4'b0010) ? 1'b1 :
                       (ex3_sum4_lev3 == 4'b0011) ? 1'b1 :
                       (ex3_sum4_lev3 == 4'b0100) ? 1'b1 :
                       (ex3_sum4_lev3 == 4'b0101) ? 1'b1 :
                       (ex3_sum4_lev3 == 4'b0110) ? 1'b1 :
                       (ex3_sum4_lev3 == 4'b0111) ? 1'b1 :
                       1'b0;

   //-------------------------------------------------------------------
   // Mux between these three to get the next quotient bit
   //-------------------------------------------------------------------
   assign ex3_nq_bit3 = (ex3_sum4_lev3 == 4'b1000) ? 1'b1 :
                        (ex3_sum4_lev3 == 4'b1001) ? 1'b1 :
                        (ex3_sum4_lev3 == 4'b1010) ? 1'b1 :
                        (ex3_sum4_lev3 == 4'b1011) ? 1'b1 :
                        (ex3_sum4_lev3 == 4'b1100) ? 1'b1 :
                        (ex3_sum4_lev3 == 4'b1101) ? 1'b1 :
                        (ex3_sum4_lev3 == 4'b1110) ? 1'b1 :
                        1'b0;
   assign ex3_q_bit22_sel = {ex3_q_bit0, ex3_nq_bit0};

   assign ex3_q_bit22 = (ex3_q_bit22_sel == 2'b10) ? ex3_q_bit1 :
                        (ex3_q_bit22_sel == 2'b00) ? ex3_q_bit2 :
                        (ex3_q_bit22_sel == 2'b01) ? ex3_q_bit3 :
                        1'b0;

   //-------------------------------------------------------------------
   // Final Denominator mux and 3:2 CSA
   //-------------------------------------------------------------------
   // shift left by 1 again
   assign ex3_nq_bit22 = (ex3_q_bit22_sel == 2'b10) ? ex3_nq_bit1 :
                         (ex3_q_bit22_sel == 2'b00) ? ex3_nq_bit2 :
                         (ex3_q_bit22_sel == 2'b01) ? ex3_nq_bit3 :
                         1'b0;
   assign ex3_lev0_csaout_sum[msb:66] = {ex3_lev0_csaoutsh_sum[msb + 1:66], 1'b0};
   assign ex3_lev0_csaout_carry[msb:66] = {ex3_lev0_csaoutsh_carry[msb + 1:66], 1'b0};

   assign ex3_lev22_selD = ex3_nq_bit22 & (~ex3_q_bit22);
   assign ex3_lev22_selnD = ex3_q_bit22 & (~ex3_nq_bit22);
   assign ex3_lev22_sel0 = (~ex3_q_bit22) & (~ex3_nq_bit22);

   assign ex3_denomQ_lev22 = ((~ex3_denom_q) & {66-msb{ex3_lev22_selnD}}) | (ex3_denom_q & {66-msb{ex3_lev22_selD}});

   assign ex3_lev22_csaout_sum = ({ex3_lev22_selnD, ex3_denomQ_lev22}) ^ ex3_lev0_csaout_sum ^ ex3_lev0_csaout_carry;

   assign ex3_lev22_csaout_carryout = (({ex3_lev22_selnD, ex3_denomQ_lev22}) & ex3_lev0_csaout_sum) | (({ex3_lev22_selnD, ex3_denomQ_lev22}) & ex3_lev0_csaout_carry) | (ex3_lev0_csaout_sum & ex3_lev0_csaout_carry);

   assign ex3_lev22_csaout_carry[msb:66] = {ex3_lev22_csaout_carryout[msb + 1:66], ex3_lev22_selnD};

   assign ex3_PR_sum_final = ex3_lev22_csaout_sum;
   assign ex3_PR_carry_final = ex3_lev22_csaout_carry;

   //-------------------------------------------------------------------
   // on-the-fly quotient digit conversion logic
   //-------------------------------------------------------------------
   // Qin=(Q & q) if q >= 0.  Qin=(QM & 1) if q < 0
   assign ex3_oddshift_done = ex3_oddshift & ex2_div_almost_done;

   assign ex3_Qin_lev1_sel0 = (ex3_q_bit22 | ((~ex3_nq_bit22))) & (~ex2_div_val_q) & (~(ex3_oddshift_done));		// todo:  is there a better way to clear this?
   assign ex3_Qin_lev1_sel1 = ex3_nq_bit22 & (~ex2_div_val_q) & (~(ex3_oddshift_done));
   assign ex3_Qin_lev1_sel2 = (ex3_oddshift_done) & (~ex2_div_val_q);
   assign ex3_Qin_lev1_selinit = ex2_div_val_q;		// initial state

   assign ex3_Qin_lev1[msb:63] = (({ex3_Qin_lev0[msb + 1:63], ex3_q_bit22}) & {`GPR_WIDTH{ex3_Qin_lev1_sel0}}) | (({ex3_QMin_lev0[msb + 1:63], 1'b1}) & {`GPR_WIDTH{ex3_Qin_lev1_sel1}}) | ((ex3_Qin_lev0[msb:63]) & {`GPR_WIDTH{ex3_Qin_lev1_sel2}}) | (`GPR_WIDTH'b0 & {`GPR_WIDTH{ex3_Qin_lev1_selinit}});		// just pass through for oddshifts

   assign ex3_quotient_ovf_cond4_wd = (ex3_Q_q[msb + 32] & ex3_Qin_lev0_sel0) | (ex3_QM_q[msb + 32] & ex3_Qin_lev0_sel1) | (ex3_Qin_lev0[msb + 32] & ex3_Qin_lev1_sel0) | (ex3_QMin_lev0[msb + 32] & ex3_Qin_lev1_sel1);		// shifted out of lev0

   // cond4 bug.  dont know if overflow until the last cycle.
   assign ex3_quotient_ovf_cond4_dw = (ex3_Q_q[msb] & ex3_Qin_lev0_sel0) | (ex3_QM_q[msb] & ex3_Qin_lev0_sel1) | (ex3_Qin_lev0[msb] & ex3_Qin_lev1_sel0) | (ex3_QMin_lev0[msb] & ex3_Qin_lev1_sel1);		// shifted out of lev0
   // may also need to gate this with ex2_denom_shift_ctrl*
   // may also need to undo for the quotient correction case

   // QMin=(Q & 0) if q > 0. QMin=(QM & 0) if q < 0.  QMin=(QM & 1) if q = 0
   assign ex3_quotient_ovf_cond4 = (ex3_div_size_q == 1'b1) ? ex3_quotient_ovf_cond4_dw :
                                   ex3_quotient_ovf_cond4_wd;
   assign ex3_QMin_lev1_sel0 = ex3_q_bit22 & (~ex2_div_val_q);
   assign ex3_QMin_lev1_sel1 = ex3_nq_bit22 & (~ex2_div_val_q);
   assign ex3_QMin_lev1_sel2 = ((~(ex3_nq_bit22 | ex3_q_bit22))) & (~ex2_div_val_q);
   assign ex3_QMin_lev1_selinit = ex2_div_val_q;

   assign ex3_QMin_lev1[msb:63] = (({ex3_Qin_lev0[msb + 1:63], 1'b0}) & {`GPR_WIDTH{ex3_QMin_lev1_sel0}}) | (({ex3_QMin_lev0[msb + 1:63], 1'b0}) & {`GPR_WIDTH{ex3_QMin_lev1_sel1}}) | (({ex3_QMin_lev0[msb + 1:63], 1'b1}) & {`GPR_WIDTH{ex3_QMin_lev1_sel2}}) | (`GPR_WIDTH'b0 & {`GPR_WIDTH{ex3_QMin_lev1_selinit}});

   assign ex3_Q_d = (ex3_Qin_lev1         & {`GPR_WIDTH{ex3_denom_shift_ctrl0}}) |
                    ({`GPR_WIDTH{tidn}}   & {`GPR_WIDTH{ex3_denom_shift_ctrl}});

   assign ex3_QM_d = (ex3_QMin_lev1                      & {64-msb{ex3_denom_shift_ctrl0}}) |
                     (({ex3_QM_q[msb + 1:63], 1'b1})     & {64-msb{ex3_denom_shift_ctrl1}}) |
                     (({ex3_QM_q[msb + 2:63], 2'b11})    & {64-msb{ex3_denom_shift_ctrl2}});

   //-------------------------------------------------------------------
   // final quotient correction:  if the sign of the remainder != sign of the numerator, subtract 1 from the quotient, and
   //                              add 1 dividend to the remainder
   //-------------------------------------------------------------------

   // add the final sum and carry to get the real remainder
   assign ex3_add_rslt[msb:66] = ex3_PR_sum_q[msb:66] + ex3_PR_carry_q[msb:66];

   assign ex3_add_rslt_sign_d = ex3_add_rslt[msb];

   assign ex3_quotient_correction = ex3_add_rslt_sign_d;

   //-------------------------------------------------------------------
   // Adder
   //-------------------------------------------------------------------
   assign ex3_numer_d = (ex2_div_val_q == 1'b1) ? {3'b000, ex2_numer} :
                        ex3_numer_q;
   assign ex3_sub_rslt = ex3_numer_q - {1'b0, ex3_denom_q};

   //-------------------------------------------------------------------
   // Quotient
   //-------------------------------------------------------------------

   assign ex3_Q_sel0 = ex3_div_val_q;
   assign ex3_Q_sel1 = ((~ex2_div_done) | ex2_div_almost_done) & (~ex3_div_val_q);		// was ex1_div_almost_done and not ex2_div_val_q;
   assign ex3_Q_sel2 = ex2_div_done & (~ex3_div_val_q);

   assign ex4_quotient_d = ({`GPR_WIDTH{tidn}} & {`GPR_WIDTH{ex3_Q_sel0}}) |
                           (ex3_Q_d          & {`GPR_WIDTH{ex3_Q_sel1}}) |
                           (ex4_quotient_q   & {`GPR_WIDTH{ex3_Q_sel2}});		// latch the quotient while the remainder is summed

   // 2's complement quotient if necessary for signed divide
   assign ex4_quotient_2s = (~ex4_quotient_q);

   assign ex4_div_rt_op1 = (ex4_2s_rslt_q == 1'b1) ? ex4_quotient_2s : 		// 00
                           ex4_quotient_q;
   assign ex4_addop_sel0 = (~ex4_2s_rslt_q) & (~ex4_quotient_correction);
   assign ex4_addop_sel1 = ex4_2s_rslt_q & (~ex4_quotient_correction);		// 10
   assign ex4_addop_sel2 = (~ex4_2s_rslt_q) & ex4_quotient_correction;		// 01
   assign ex4_addop_sel3 = ex4_2s_rslt_q & ex4_quotient_correction;		// 11

   // 0x00000000
   // 0xFFFFFFFF
   assign ex4_div_rt_op2 = ( {`GPR_WIDTH{1'b0}}              & {64-msb{ex4_addop_sel0}}) |
                           ({{`GPR_WIDTH-1{1'b0}},1'b1}      & {64-msb{ex4_addop_sel1}}) |
                           ( {`GPR_WIDTH{1'b1}}              & {64-msb{ex4_addop_sel2}}) |
                           ({{`GPR_WIDTH-2{1'b0}},2'b10}     & {64-msb{ex4_addop_sel3}});		// 0x00000001
   // 0x00000002

   //-------------------------------------------------------------------
   // Return quotient
   //-------------------------------------------------------------------
   assign ex4_div_rt_d = ex4_div_rt_op1 + ex4_div_rt_op2;

   // Return Zero for all undefined cases
   assign ex3_rslt_sign = (ex3_div_size_q == 1'b1) ? ex4_div_rt_d[msb] :
                          ex4_div_rt_d[32];
   generate
      if (`GPR_WIDTH == 64)
      begin : div_rslt_64b
         assign ex4_div_rt[0:31] = (~(ex4_div_ovf_q | ~ex4_div_size_q))==1'b1 ? ex4_div_rt_q[0:31] : 32'b0;
      end
   endgenerate
   assign ex4_div_rt[32:63] = (~(ex4_div_ovf_q))==1'b1 ? ex4_div_rt_q[32:63] : 32'b0;

   assign div_byp_ex4_rt = ex4_div_rt;

   //                   Divide Undefined/Overflow Conditions
   // ------------------------------------------------------------------------------
   //        |     Cond 1     |     Cond 2     |    Cond 3     |    Cond 4         |
   // -----------------------------------------------------------------------------+
   //        | 0x8000... / -1 | <anything> / 0 |   RA >= RB    | Result doesn't    |
   //        |                |                |               | fit in 32/64 bits |
   // -----------------------------------------------------------------------------+
   // divw   |        X       |       X        |               |                   |
   // divwu  |                |       X        |               |                   |
   // divwe  |        X       |       X        |               |       X           |
   // divweu |                |       X        |      X        |                   |
   // divd   |        X       |       X        |               |                   |
   // divdu  |                |       X        |               |                   |
   // divde  |        X       |       X        |               |       X           |
   // divdeu |                |       X        |      X        |                   |
   // -----------------------------------------------------------------------------+

   assign ex2_num_cmp0_lo_nomsb = (~|(byp_div_ex2_rs1[33:63]));
   assign ex2_den_cmp0_lo = (~|(byp_div_ex2_rs2[32:63]));
   assign ex2_den_cmp1_lo = &(byp_div_ex2_rs2[32:63]);
   assign ex4_qot_cmp0_lo = (~|(ex4_div_rt_q[32:63]));
   assign ex2_num_cmp0_lo = (~byp_div_ex2_rs1[32]) & ex2_num_cmp0_lo_nomsb;
   assign ex2_div_ovf_cond1_wd = byp_div_ex2_rs1[32] & ex2_num_cmp0_lo_nomsb & ex2_den_cmp1_lo;

   generate
      if (`GPR_WIDTH == 64)
      begin : div_64b_oflow
         assign ex2_num_cmp0_hi_nomsb = (~|(byp_div_ex2_rs1[1:31]));
         assign ex2_den_cmp0_hi = (~|(byp_div_ex2_rs2[0:31]));
         assign ex2_den_cmp1_hi = &(byp_div_ex2_rs2[0:31]);
         assign ex4_qot_cmp0_hi = (~|(ex4_div_rt_q[0:31]));
         assign ex2_num_cmp0_hi = (~byp_div_ex2_rs1[0]) & ex2_num_cmp0_hi_nomsb;
         assign ex2_div_ovf_cond1_dw = byp_div_ex2_rs1[0] & ex2_num_cmp0_hi_nomsb & (~byp_div_ex2_rs1[32]) & ex2_num_cmp0_lo_nomsb & ex2_den_cmp1_lo & ex2_den_cmp1_hi;
      end
   endgenerate

   generate
      if (`GPR_WIDTH == 32)
      begin : div_32b_oflow
         assign ex2_num_cmp0_hi_nomsb = 1'b1;
         assign ex2_den_cmp0_hi = 1'b1;
         assign ex2_den_cmp1_hi = 1'b1;
         assign ex2_div_ovf_cond1_dw = 1'b1;
         assign ex2_num_cmp0_hi = 1'b1;
         assign ex4_qot_cmp0_hi = 1'b1;
      end
   endgenerate

   assign ex2_div_ovf_cond1 = (ex2_div_size_q == 1'b1) ? ex2_div_ovf_cond1_dw :
                              ex2_div_ovf_cond1_wd;
   assign ex2_div_ovf_cond2 = ex2_den_cmp0_lo & (ex2_den_cmp0_hi | (~ex2_div_size_q));

   assign ex2_div_ovf = (ex2_div_ovf_cond1 & ex2_div_sign_q) | ex2_div_ovf_cond2;

   // Condition 3
   assign ex3_den_eq_num = &(ex3_denom_q ~^ ex3_numer_q[msb + 1:66]);
   assign ex3_den_gte_num = (~(ex3_sub_rslt[msb])) | ex3_den_eq_num;
   assign ex3_div_ovf_cond3 = ex3_den_gte_num & (~ex3_div_sign_q) & ex3_div_extd_q;

   // Condition 4
   // Need to watch quotient for first 65 cycles of divde, 33 cycles of divwe
   assign ex3_cycles_gt_64 = ((ex3_cycles_q > 8'd35)) ? 1'b1 :
                             1'b0;
   assign ex3_cycles_gt_32 = ((ex3_cycles_q > 8'd19)) ? 1'b1 :
                             1'b0;

   // If any bit is pushed during the watch period, flag overflow
   assign ex4_cycle_watch_d = (ex3_div_size_q == 1'b1) ? ex3_cycles_gt_64 :
                              ex3_cycles_gt_32;
   assign ex4_quot_watch_d_old = (ex4_quot_watch_q | (ex4_cycle_watch_q & ex4_quotient_q[63])) & (~ex4_div_val_q);
   assign ex4_quot_watch_d = (ex4_quot_watch_q | (ex3_quotient_ovf_cond4 & (~ex2_div_done))) & (~ex4_div_val_q);

   assign ex3_numer_eq_zero_d = ex2_num_cmp0_lo & (ex2_num_cmp0_hi | (~ex2_div_size_q));

   // overflow out of 32/64 bits
   assign ex3_div_ovf_cond4 = ex4_quot_watch_q | ((ex3_rslt_sign ^ ex3_2s_rslt_q) & (~ex3_numer_eq_zero_q)) | (ex3_rslt_sign & ex3_numer_eq_zero_q);		// result sign differs from expected, numerator not equal to zero
   // result sign is negative , numerator equal to zero

   assign ex4_div_ovf_d = ex3_div_ovf_q | ex4_div_ovf_cond3_q | (ex3_div_ovf_cond4 & (ex3_div_sign_q & ex3_div_extd_q));

   assign div_byp_ex4_xer[0] = (ex4_xer_ov_update_q == 1'b1) ? ex4_div_ovf_q | xersrc_q[0] :
                               xersrc_q[0];

   assign div_byp_ex4_xer[1] = (ex4_xer_ov_update_q == 1'b1) ? ex4_div_ovf_q :
                               xersrc_q[1];
   assign div_byp_ex4_xer[2:9] = xersrc_q[2:9];

   //-------------------------------------------------------------------
   // Record forms
   //-------------------------------------------------------------------
   // Overflow Cases
   assign ex4_cmp0_undef = ex4_div_ovf_q | ((~ex4_div_size_q) & ex2_spr_msr_cm_q);		// Word op in 64b mode

   assign ex4_lt = (ex2_spr_msr_cm_q == 1'b1) ? ex4_div_rt_q[msb] :
                   ex4_div_rt_q[32];
   assign ex4_cmp0_eq = (ex4_qot_cmp0_lo & (ex4_qot_cmp0_hi | (~ex2_spr_msr_cm_q))) & (~ex4_cmp0_undef);

   assign ex4_cmp0_lt = ex4_lt & (~ex4_cmp0_eq) & (~ex4_cmp0_undef);
   assign ex4_cmp0_gt = (~ex4_lt) & (~ex4_cmp0_eq) & (~ex4_cmp0_undef);

   assign div_byp_ex4_cr = {ex4_cmp0_lt, ex4_cmp0_gt, ex4_cmp0_eq, (xersrc_q[0] | (ex4_div_ovf_q & ex4_xer_ov_update_q))};


   //-------------------------------------------------------------------
   // Latches
   //-------------------------------------------------------------------
   //mark_unused(xersrc_q[1])mark_unused(ex4_div_recform_q)
   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex2_div_ctr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_div_ex1_div_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_div_ctr_offset:ex2_div_ctr_offset + 8 - 1]),
      .scout(sov[ex2_div_ctr_offset:ex2_div_ctr_offset + 8 - 1]),
      .din(dec_div_ex1_div_ctr),
      .dout(ex2_div_ctr_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_div_val_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_div_val_offset]),
      .scout(sov[ex2_div_val_offset]),
      .din(ex1_div_val),
      .dout(ex2_div_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_div_sign_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_div_ex1_div_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_div_sign_offset]),
      .scout(sov[ex2_div_sign_offset]),
      .din(dec_div_ex1_div_sign),
      .dout(ex2_div_sign_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_div_size_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_div_ex1_div_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_div_size_offset]),
      .scout(sov[ex2_div_size_offset]),
      .din(dec_div_ex1_div_size),
      .dout(ex2_div_size_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_div_extd_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_div_ex1_div_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_div_extd_offset]),
      .scout(sov[ex2_div_extd_offset]),
      .din(dec_div_ex1_div_extd),
      .dout(ex2_div_extd_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_div_recform_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_div_ex1_div_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_div_recform_offset]),
      .scout(sov[ex2_div_recform_offset]),
      .din(dec_div_ex1_div_recform),
      .dout(ex2_div_recform_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_xer_ov_update_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_div_ex1_div_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_xer_ov_update_offset]),
      .scout(sov[ex2_xer_ov_update_offset]),
      .din(dec_div_ex1_xer_ov_update),
      .dout(ex2_xer_ov_update_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_div_val_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_div_val_offset]),
      .scout(sov[ex3_div_val_offset]),
      .din(ex2_div_val_q),
      .dout(ex3_div_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_cycle_act_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_cycle_act_offset]),
      .scout(sov[ex3_cycle_act_offset]),
      .din(ex3_cycle_act_d),
      .dout(ex3_cycle_act_q)
   );

   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex3_cycles_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_cycle_act_d),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_cycles_offset:ex3_cycles_offset + 8 - 1]),
      .scout(sov[ex3_cycles_offset:ex3_cycles_offset + 8 - 1]),
      .din(ex3_cycles_d),
      .dout(ex3_cycles_q)
   );

   tri_rlmreg_p #(.WIDTH((65-msb+1)), .INIT(0), .NEEDS_SRESET(1)) ex3_denom_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(divrunning_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_denom_offset:ex3_denom_offset + (65-msb+1) - 1]),
      .scout(sov[ex3_denom_offset:ex3_denom_offset + (65-msb+1) - 1]),
      .din(ex3_denom_d),
      .dout(ex3_denom_q)
   );

   tri_rlmreg_p #(.WIDTH((66-msb+1)), .INIT(0), .NEEDS_SRESET(1)) ex3_numer_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(divrunning_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_numer_offset:ex3_numer_offset + (66-msb+1) - 1]),
      .scout(sov[ex3_numer_offset:ex3_numer_offset + (66-msb+1) - 1]),
      .din(ex3_numer_d),
      .dout(ex3_numer_q)
   );

   // begin r4 latches


   tri_rlmreg_p #(.WIDTH((66-msb+1)), .INIT(0), .NEEDS_SRESET(1)) ex3_PR_sum_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(divrunning_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_PR_sum_offset:ex3_PR_sum_offset + (66-msb+1) - 1]),
      .scout(sov[ex3_PR_sum_offset:ex3_PR_sum_offset + (66-msb+1) - 1]),
      .din(ex3_PR_sum_d),
      .dout(ex3_PR_sum_q)
   );


   tri_rlmreg_p #(.WIDTH((66-msb+1)), .INIT(0), .NEEDS_SRESET(1)) ex3_PR_carry_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(divrunning_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_PR_carry_offset:ex3_PR_carry_offset + (66-msb+1) - 1]),
      .scout(sov[ex3_PR_carry_offset:ex3_PR_carry_offset + (66-msb+1) - 1]),
      .din(ex3_PR_carry_d),
      .dout(ex3_PR_carry_q)
   );

   tri_rlmreg_p #(.WIDTH((63-msb+1)), .INIT(0), .NEEDS_SRESET(1)) ex3_Q_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(divrunning_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_Q_offset:ex3_Q_offset + (63-msb+1) - 1]),
      .scout(sov[ex3_Q_offset:ex3_Q_offset + (63-msb+1) - 1]),
      .din(ex3_Q_d),
      .dout(ex3_Q_q)
   );

   tri_rlmreg_p #(.WIDTH((63-msb+1)), .INIT(0), .NEEDS_SRESET(1)) ex3_QM_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(divrunning_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_QM_offset:ex3_QM_offset + (63-msb+1) - 1]),
      .scout(sov[ex3_QM_offset:ex3_QM_offset + (63-msb+1) - 1]),
      .din(ex3_QM_d),
      .dout(ex3_QM_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_oddshift_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(divrunning_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_oddshift_offset]),
      .scout(sov[ex3_oddshift_offset]),
      .din(ex3_oddshift_d),
      .dout(ex3_oddshift_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_divrunning_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_divrunning_offset]),
      .scout(sov[ex3_divrunning_offset]),
      .din(ex3_divrunning_d),
      .dout(ex3_divrunning_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_divrunning_act_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_divrunning_act_offset]),
      .scout(sov[ex4_divrunning_act_offset]),
      .din(ex4_divrunning_act_d),
      .dout(ex4_divrunning_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_divflush_1d_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_divflush_1d_offset]),
      .scout(sov[ex3_divflush_1d_offset]),
      .din(div_flush),
      .dout(div_flush_1d)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_divflush_2d_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_divflush_2d_offset]),
      .scout(sov[ex4_divflush_2d_offset]),
      .din(div_flush_1d),
      .dout(div_flush_2d)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_add_rslt_sign_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_add_rslt_sign_offset]),
      .scout(sov[ex3_add_rslt_sign_offset]),
      .din(ex3_add_rslt_sign_d),
      .dout(ex3_add_rslt_sign_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_quotient_correction_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_quotient_correction_offset]),
      .scout(sov[ex4_quotient_correction_offset]),
      .din(ex3_quotient_correction),
      .dout(ex4_quotient_correction)
   );

   tri_rlmreg_p #(.WIDTH((65-msb+1)), .INIT(0), .NEEDS_SRESET(1)) ex3_dmask_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(divrunning_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_dmask_offset:ex3_dmask_offset + (65-msb+1) - 1]),
      .scout(sov[ex3_dmask_offset:ex3_dmask_offset + (65-msb+1) - 1]),
      .din(ex3_dmask_d),
      .dout(ex3_dmask_q)
   );
   // end r4 latches


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_div_ovf_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_div_val_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_div_ovf_offset]),
      .scout(sov[ex3_div_ovf_offset]),
      .din(ex2_div_ovf),
      .dout(ex3_div_ovf_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_xer_ov_update_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
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

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_div_recform_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_div_recform_offset]),
      .scout(sov[ex3_div_recform_offset]),
      .din(ex2_div_recform_q),
      .dout(ex3_div_recform_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_div_size_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_div_val_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_div_size_offset]),
      .scout(sov[ex3_div_size_offset]),
      .din(ex2_div_size_q),
      .dout(ex3_div_size_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_div_sign_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_div_val_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_div_sign_offset]),
      .scout(sov[ex3_div_sign_offset]),
      .din(ex2_div_sign_q),
      .dout(ex3_div_sign_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_div_extd_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_div_val_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_div_extd_offset]),
      .scout(sov[ex3_div_extd_offset]),
      .din(ex2_div_extd_q),
      .dout(ex3_div_extd_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_2s_rslt_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_div_val_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_2s_rslt_offset]),
      .scout(sov[ex3_2s_rslt_offset]),
      .din(ex2_2s_rslt),
      .dout(ex3_2s_rslt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_div_done_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_div_done_offset]),
      .scout(sov[ex3_div_done_offset]),
      .din(ex2_div_done),
      .dout(ex3_div_done_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_div_val_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_div_val_offset]),
      .scout(sov[ex4_div_val_offset]),
      .din(ex3_div_val_q),
      .dout(ex4_div_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_cycle_watch_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_cycle_watch_offset]),
      .scout(sov[ex4_cycle_watch_offset]),
      .din(ex4_cycle_watch_d),
      .dout(ex4_cycle_watch_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_quot_watch_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_quot_watch_offset]),
      .scout(sov[ex4_quot_watch_offset]),
      .din(ex4_quot_watch_d),
      .dout(ex4_quot_watch_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_div_ovf_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_div_ovf_offset]),
      .scout(sov[ex4_div_ovf_offset]),
      .din(ex4_div_ovf_d),
      .dout(ex4_div_ovf_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_xer_ov_update_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
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

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_div_done_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_div_done_offset]),
      .scout(sov[ex4_div_done_offset]),
      .din(ex4_div_done_d),
      .dout(ex4_div_done_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_div_done_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex5_div_done_offset]),
      .scout(sov[ex5_div_done_offset]),
      .din(ex5_div_done_d),
      .dout(ex5_div_done_q)
   );

   tri_rlmreg_p #(.WIDTH((63-msb+1)), .INIT(0), .NEEDS_SRESET(1)) ex4_quotient_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(divrunning_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_quotient_offset:ex4_quotient_offset + (63-msb+1) - 1]),
      .scout(sov[ex4_quotient_offset:ex4_quotient_offset + (63-msb+1) - 1]),
      .din(ex4_quotient_d),
      .dout(ex4_quotient_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_div_recform_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_div_recform_offset]),
      .scout(sov[ex4_div_recform_offset]),
      .din(ex3_div_recform_q),
      .dout(ex4_div_recform_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_div_size_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_div_size_offset]),
      .scout(sov[ex4_div_size_offset]),
      .din(ex3_div_size_q),
      .dout(ex4_div_size_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_2s_rslt_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_2s_rslt_offset]),
      .scout(sov[ex4_2s_rslt_offset]),
      .din(ex3_2s_rslt_q),
      .dout(ex4_2s_rslt_q)
   );

   tri_rlmreg_p #(.WIDTH((63-msb+1)), .INIT(0), .NEEDS_SRESET(1)) ex4_div_rt_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(divrunning_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_div_rt_offset:ex4_div_rt_offset + (63-msb+1) - 1]),
      .scout(sov[ex4_div_rt_offset:ex4_div_rt_offset + (63-msb+1) - 1]),
      .din(ex4_div_rt_d),
      .dout(ex4_div_rt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_div_ovf_cond3_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_div_val_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_div_ovf_cond3_offset]),
      .scout(sov[ex4_div_ovf_cond3_offset]),
      .din(ex3_div_ovf_cond3),
      .dout(ex4_div_ovf_cond3_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_spr_msr_cm_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_div_ex1_div_act),
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

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_numer_eq_zero_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_div_val_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_numer_eq_zero_offset]),
      .scout(sov[ex3_numer_eq_zero_offset]),
      .din(ex3_numer_eq_zero_d),
      .dout(ex3_numer_eq_zero_q)
   );

   tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) xersrc_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_div_val_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[xersrc_offset:xersrc_offset + 10 - 1]),
      .scout(sov[xersrc_offset:xersrc_offset + 10 - 1]),
      .din(byp_div_ex2_xer),
      .dout(xersrc_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
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

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex2_div_tid_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_div_ex1_div_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_div_tid_offset:ex2_div_tid_offset + `THREADS - 1]),
      .scout(sov[ex2_div_tid_offset:ex2_div_tid_offset + `THREADS - 1]),
      .din(ex1_div_tid),
      .dout(ex2_div_tid_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_div_tid_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_div_val_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_div_tid_offset:ex3_div_tid_offset + `THREADS - 1]),
      .scout(sov[ex3_div_tid_offset:ex3_div_tid_offset + `THREADS - 1]),
      .din(ex2_div_tid_q),
      .dout(ex3_div_tid_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) perf_divrunning_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[perf_divrunning_offset : perf_divrunning_offset + `THREADS-1]),
      .scout(sov[perf_divrunning_offset : perf_divrunning_offset + `THREADS-1]),
      .din(perf_divrunning_d),
      .dout(perf_divrunning_q)
   );

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];

endmodule
