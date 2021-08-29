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

//  Description:  Simple Execution Unit
//
//*****************************************************************************
`include "tri_a2o.vh"
module xu0
(
   //-------------------------------------------------------------------
   // Clocks & Power
   //-------------------------------------------------------------------
   input [0:`NCLK_WIDTH-1]                   nclk,
   inout                                     vdd,
   inout                                     gnd,

   //-------------------------------------------------------------------
   // Pervasive
   //-------------------------------------------------------------------
   input                                     pc_xu_ccflush_dc,
   input                                     d_mode_dc,
   input                                     delay_lclkr_dc,
   input                                     mpw1_dc_b,
   input                                     mpw2_dc_b,
   input                                     func_sl_force,
   input                                     func_sl_thold_0_b,
   input                                     sg_0,
   input                                     scan_in,
   output                                    scan_out,

   output                                    xu0_pc_ram_done,

   //-------------------------------------------------------------------
   // Interface with CP
   //-------------------------------------------------------------------
   input [0:`THREADS-1]                      cp_flush,
   input [62-`EFF_IFAR_ARCH : 61-`EFF_IFAR_WIDTH]  iu_br_t0_flush_ifar,
   input [0:`ITAG_SIZE_ENC-1]                      cp_next_itag_t0,
   `ifndef THREADS1
   input [62-`EFF_IFAR_ARCH : 61-`EFF_IFAR_WIDTH]  iu_br_t1_flush_ifar,
   input [0:`ITAG_SIZE_ENC-1]                      cp_next_itag_t1,
   `endif

   //-------------------------------------------------------------------
   // BR's Interface with CP
   //-------------------------------------------------------------------
   output [0:`THREADS-1]                     br_iu_execute_vld,
   output [0:`ITAG_SIZE_ENC-1]               br_iu_itag,
   output                                    br_iu_taken,
   output [62-`EFF_IFAR_ARCH:61]             br_iu_bta,
   output [0:17]                             br_iu_gshare,
   output [0:2]                              br_iu_ls_ptr,
   output [62-`EFF_IFAR_WIDTH:61]            br_iu_ls_data,
   output                                    br_iu_ls_update,
   output [0:`THREADS-1]                     br_iu_redirect,
   output [0:3]			             br_iu_perf_events,

   //-------------------------------------------------------------------
   // Interface with RV
   //-------------------------------------------------------------------
   input [0:`THREADS-1]                      rv_xu0_vld,
   input                                     rv_xu0_ex0_ord,
   input [0:19]                              rv_xu0_ex0_fusion,
   input [0:31]                              rv_xu0_ex0_instr,
   input [62-`EFF_IFAR_WIDTH:61]             rv_xu0_ex0_ifar,
   input [0:`ITAG_SIZE_ENC-1]                rv_xu0_ex0_itag,
   input [0:2]                               rv_xu0_ex0_ucode,
   input                                     rv_xu0_ex0_bta_val,
   input [62-`EFF_IFAR_WIDTH:61]             rv_xu0_ex0_pred_bta,
   input                                     rv_xu0_ex0_pred,
   input [0:2]                               rv_xu0_ex0_ls_ptr,
   input                                     rv_xu0_ex0_bh_update,
   input [0:17]                              rv_xu0_ex0_gshare,
   input                                     rv_xu0_ex0_s1_v,
   input                                     rv_xu0_ex0_s2_v,
   input [0:2]                               rv_xu0_ex0_s2_t,
   input                                     rv_xu0_ex0_s3_v,
   input [0:2]                               rv_xu0_ex0_s3_t,
   input                                     rv_xu0_ex0_t1_v,
   input [0:`GPR_POOL_ENC-1]                rv_xu0_ex0_t1_p,
   input [0:2]                               rv_xu0_ex0_t1_t,
   input                                     rv_xu0_ex0_t2_v,
   input [0:`GPR_POOL_ENC-1]                rv_xu0_ex0_t2_p,
   input [0:2]                               rv_xu0_ex0_t2_t,
   input                                     rv_xu0_ex0_t3_v,
   input [0:`GPR_POOL_ENC-1]                rv_xu0_ex0_t3_p,
   input [0:2]                               rv_xu0_ex0_t3_t,
   input [0:`THREADS-1]                      rv_xu0_ex0_spec_flush,
   input [0:`THREADS-1]                      rv_xu0_ex1_spec_flush,
   input [0:`THREADS-1]                      rv_xu0_ex2_spec_flush,
   input [1:11]                              rv_xu0_s1_fxu0_sel,
   input [1:11]                              rv_xu0_s2_fxu0_sel,
   input [2:11]                              rv_xu0_s3_fxu0_sel,
   input [1:6]                               rv_xu0_s1_fxu1_sel,
   input [1:6]                               rv_xu0_s2_fxu1_sel,
   input [2:6]                               rv_xu0_s3_fxu1_sel,
   input [4:8]                               rv_xu0_s1_lq_sel,
   input [4:8]                               rv_xu0_s2_lq_sel,
   input [4:8]                               rv_xu0_s3_lq_sel,
   input [2:3]                               rv_xu0_s1_rel_sel,
   input [2:3]                               rv_xu0_s2_rel_sel,

   output                                    xu0_rv_ord_complete,
   output [0:`ITAG_SIZE_ENC-1]               xu0_rv_ord_itag,
   output                                    xu0_rv_hold_all,
   //-------------------------------------------------------------------
   // Bypass Inputs
   //-------------------------------------------------------------------
   // Regfile Data
   input [64-`GPR_WIDTH:63]                  gpr_xu0_ex1_r1d,
   input [64-`GPR_WIDTH:63]                  gpr_xu0_ex1_r2d,
   input [0:9]                               xer_xu0_ex1_r2d,
   input [0:9]                               xer_xu0_ex1_r3d,
   input [0:3]                               cr_xu0_ex1_r1d,
   input [0:3]                               cr_xu0_ex1_r2d,
   input [0:3]                               cr_xu0_ex1_r3d,
   input [64-`GPR_WIDTH:63]                  lr_xu0_ex1_r1d,
   input [64-`GPR_WIDTH:63]                  lr_xu0_ex1_r2d,
   input [64-`GPR_WIDTH:63]                  ctr_xu0_ex1_r2d,

   // External Bypass
   output                                    xu0_xu1_ex3_act,
   input                                     xu1_xu0_ex3_act,
   input                                     lq_xu_ex5_act,

   input                                     xu1_xu0_ex2_abort,
   input [64-`GPR_WIDTH:63]                  xu1_xu0_ex2_rt,
   input [64-`GPR_WIDTH:63]                  xu1_xu0_ex3_rt,
   input [64-`GPR_WIDTH:63]                  xu1_xu0_ex4_rt,
   input [64-`GPR_WIDTH:63]                  xu1_xu0_ex5_rt,
   input                                     lq_xu_ex5_abort,
   input [64-`GPR_WIDTH:63]                  lq_xu_ex5_rt,
   input                                     lq_xu_rel_act,
   input [64-`GPR_WIDTH:63]                  lq_xu_rel_rt,
   input [64-`GPR_WIDTH:63]                  lq_xu_ex5_data,
   input [64-`GPR_WIDTH:63]                  iu_xu_ex5_data,

   input [64-`GPR_WIDTH:63]                  spr_xu_ex4_rd_data,
   output [64-`GPR_WIDTH:63]                 xu_spr_ex2_rs1,

   // CR
   input [0:3]                               lq_xu_ex5_cr,
   input [0:3]                               xu1_xu0_ex3_cr,
   // XER
   input [0:9]                               xu1_xu0_ex3_xer,

   //-------------------------------------------------------------------
   // Interface with MMU / ERATs
   //-------------------------------------------------------------------
   output                                    xu_iu_ord_ready,
   output                                    xu_iu_act,
   output [0:`THREADS-1]                     xu_iu_val,
   output                                    xu_iu_is_eratre,
   output                                    xu_iu_is_eratwe,
   output                                    xu_iu_is_eratsx,
   output                                    xu_iu_is_eratilx,
   output                                    xu_iu_is_erativax,
   output [0:1]                              xu_iu_ws,
   output [0:2]                              xu_iu_t,
   output [0:8]                              xu_iu_rs_is,
   output [0:3]                              xu_iu_ra_entry,
   output [64-`GPR_WIDTH:51]                 xu_iu_rb,
   output [64-`GPR_WIDTH:63]                 xu_iu_rs_data,
   input                                     iu_xu_ord_read_done,
   input                                     iu_xu_ord_write_done,
   input                                     iu_xu_ord_n_flush_req,
   input                                     iu_xu_ord_par_err,

   output                                    xu_lq_ord_ready,
   output                                    xu_lq_act,
   output [0:`THREADS-1]                     xu_lq_val,
   output                                    xu_lq_hold_req,
   output                                    xu_lq_is_eratre,
   output                                    xu_lq_is_eratwe,
   output                                    xu_lq_is_eratsx,
   output                                    xu_lq_is_eratilx,
   output [0:1]                              xu_lq_ws,
   output [0:2]                              xu_lq_t,
   output [0:8]                              xu_lq_rs_is,
   output [0:4]                              xu_lq_ra_entry,
   output [64-`GPR_WIDTH:51]                 xu_lq_rb,
   output [64-`GPR_WIDTH:63]                 xu_lq_rs_data,
   input                                     lq_xu_ord_read_done,
   input                                     lq_xu_ord_write_done,
   input                                     lq_xu_ord_n_flush_req,
   input                                     lq_xu_ord_par_err,

   output                                    xu_mm_ord_ready,
   output                                    xu_mm_act,
   output [0:`THREADS-1]                     xu_mm_val,
   output [0:`ITAG_SIZE_ENC-1]               xu_mm_itag,
   output                                    xu_mm_is_tlbre,
   output                                    xu_mm_is_tlbwe,
   output                                    xu_mm_is_tlbsx,
   output                                    xu_mm_is_tlbsxr,
   output                                    xu_mm_is_tlbsrx,
   output                                    xu_mm_is_tlbivax,
   output                                    xu_mm_is_tlbilx,
   output [0:11]                             xu_mm_ra_entry,
   output [64-`GPR_WIDTH:63]                 xu_mm_rb,
   input [0:`ITAG_SIZE_ENC-1]                mm_xu_itag,
   input                                     mm_xu_ord_n_flush_req,
   input                                     mm_xu_ord_read_done,
   input                                     mm_xu_ord_write_done,
   input                                     mm_xu_tlb_miss,
   input                                     mm_xu_lrat_miss,
   input                                     mm_xu_tlb_inelig,
   input                                     mm_xu_pt_fault,
   input                                     mm_xu_hv_priv,
   input                                     mm_xu_illeg_instr,
   input                                     mm_xu_tlb_multihit,
   input                                     mm_xu_tlb_par_err,
   input                                     mm_xu_lru_par_err,
   input                                           mm_xu_local_snoop_reject,
   input [0:1]                               mm_xu_mmucr0_tlbsel_t0,
   `ifndef THREADS1
   input [0:1]                               mm_xu_mmucr0_tlbsel_t1,
   `endif
   input                                     mm_xu_tlbwe_binv,
   input                                     mm_xu_cr0_eq,		// for record forms
   input                                     mm_xu_cr0_eq_valid,		// for record forms

   output                                    xu_spr_ord_ready,
   output                                    xu_spr_ord_flush,
   //-------------------------------------------------------------------
   // Bypass Outputs
   //-------------------------------------------------------------------
   output                                    xu0_xu1_ex2_abort,
   output                                    xu0_xu1_ex6_abort,
   output                                    xu0_lq_ex3_abort,
   output [64-`GPR_WIDTH:63]                 xu0_xu1_ex2_rt,
   output [64-`GPR_WIDTH:63]                 xu0_xu1_ex3_rt,
   output [64-`GPR_WIDTH:63]                 xu0_xu1_ex4_rt,
   output [64-`GPR_WIDTH:63]                 xu0_xu1_ex5_rt,
   output [64-`GPR_WIDTH:63]                 xu0_xu1_ex6_rt,
   output [64-`GPR_WIDTH:63]                 xu0_xu1_ex7_rt,
   output [64-`GPR_WIDTH:63]                 xu0_xu1_ex8_rt,
   output [64-`GPR_WIDTH:63]                 xu0_xu1_ex6_lq_rt,
   output [64-`GPR_WIDTH:63]                 xu0_xu1_ex7_lq_rt,
   output [64-`GPR_WIDTH:63]                 xu0_xu1_ex8_lq_rt,
   output [64-`GPR_WIDTH:63]                 xu0_lq_ex3_rt,
   output [64-`GPR_WIDTH:63]                 xu0_lq_ex4_rt,
   output                                    xu0_lq_ex6_act,
   output [64-`GPR_WIDTH:63]                 xu0_lq_ex6_rt,
   output [64-`GPR_WIDTH:63]                 xu0_pc_ram_data,

   // CR
   output [0:3]                              xu0_xu1_ex3_cr,
   output [0:3]                              xu0_xu1_ex4_cr,
   output [0:3]                              xu0_xu1_ex6_cr,

   // XER
   output [0:9]                              xu0_xu1_ex3_xer,
   output [0:9]                              xu0_xu1_ex4_xer,
   output [0:9]                              xu0_xu1_ex6_xer,

   // Abort
   output                                    xu0_rv_ex2_s1_abort,
   output                                    xu0_rv_ex2_s2_abort,
   output                                    xu0_rv_ex2_s3_abort,

   //-------------------------------------------------------------------
   // Target Outputs
   //-------------------------------------------------------------------
   output                                       xu0_gpr_ex6_we,
   output [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1] xu0_gpr_ex6_wa,
   output [64-`GPR_WIDTH:65+`GPR_WIDTH/8]       xu0_gpr_ex6_wd,

   output                                       xu0_xer_ex6_we,
   output [0:`XER_POOL_ENC+`THREADS_POOL_ENC-1] xu0_xer_ex6_wa,
   output [0:9]                                 xu0_xer_ex6_w0d,

   output                                       xu0_cr_ex6_we,
   output [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]  xu0_cr_ex6_wa,
   output [0:3]                                 xu0_cr_ex6_w0d,

   output                                       xu0_ctr_ex4_we,
   output [0:`CTR_POOL_ENC+`THREADS_POOL_ENC-1] xu0_ctr_ex4_wa,
   output [64-`GPR_WIDTH:63]                    xu0_ctr_ex4_w0d,

   output                                       xu0_lr_ex4_we,
   output [0:`BR_POOL_ENC+`THREADS_POOL_ENC-1]  xu0_lr_ex4_wa,
   output [64-`GPR_WIDTH:63]                    xu0_lr_ex4_w0d,

   //-------------------------------------------------------------------
   // Interface with IU
   //-------------------------------------------------------------------
   output [0:`THREADS-1]                     xu0_iu_execute_vld,
   output [0:`ITAG_SIZE_ENC-1]               xu0_iu_itag,
   output [0:`THREADS-1]                     xu0_iu_mtiar,
   output                                    xu0_iu_exception_val,
   output [0:4]                              xu0_iu_exception,
   output                                    xu0_iu_n_flush,
   output                                    xu0_iu_np1_flush,
   output                                    xu0_iu_flush2ucode,
   output [0:3]                              xu0_iu_perf_events,
   output [62-`EFF_IFAR_ARCH:61]             xu0_iu_bta,
   output [0:`THREADS-1]                     xu_iu_np1_async_flush,
   input [0:`THREADS-1]                      iu_xu_async_complete,
   input                                     iu_xu_credits_returned,
   output [0:`THREADS-1]                     xu_iu_pri_val,
   output [0:2]                              xu_iu_pri,

   //-------------------------------------------------------------------
   // Interface with SPR
   //-------------------------------------------------------------------
   input                                     spr_xu_ord_read_done,
   input                                     spr_xu_ord_write_done,
   input                                     spr_dec_ex4_spr_hypv,
   input                                     spr_dec_ex4_spr_illeg,
   input                                     spr_dec_ex4_spr_priv,
   input                                     spr_dec_ex4_np1_flush,
   output [0:`THREADS-1]                     div_spr_running,
   output [0:`THREADS-1]                     mul_spr_running,

   //-------------------------------------------------------------------
   // SlowSPRs
   //-------------------------------------------------------------------
   input                                     xu_slowspr_val_in,
   input                                     xu_slowspr_rw_in,
   input [64-`GPR_WIDTH:63]                  xu_slowspr_data_in,
   input                                     xu_slowspr_done_in,

   //-------------------------------------------------------------------
   // SPRs
   //-------------------------------------------------------------------
   input [0:`THREADS-1]                      spr_msr_cm,
   input [0:`THREADS-1]                      spr_msr_gs,
   input [0:`THREADS-1]                      spr_msr_pr,
   input [0:`THREADS-1]                      spr_epcr_dgtmi,
   input                                     spr_ccr2_notlb,
   input                                     spr_ccr2_en_attn,
   input                                     spr_ccr4_en_dnh,
   input                                     spr_ccr2_en_pc,
   input [0:31]                              spr_xesr1,
   input [0:31]                              spr_xesr2,
   input [0:`THREADS-1]                      perf_event_en,

   // Debug
   input  [0:10] 							         pc_xu_debug_mux_ctrls,
   input  [0:31] 							         xu0_debug_bus_in,
   output [0:31] 							         xu0_debug_bus_out,
   input  [0:3] 							         xu0_coretrace_ctrls_in,
   output [0:3] 							         xu0_coretrace_ctrls_out,

   input [0:`THREADS-1]                      pc_xu_ram_active
);

   //!! bugspray include: xu0_byp;

   localparam                                scan_right = 8;
   wire [0:scan_right-1]                     siv;
   wire [0:scan_right-1]                     sov;
   // Signals
   wire                                      dec_byp_ex0_act;
   wire [64-`GPR_WIDTH:63]                   dec_byp_ex1_imm;
   wire [24:25]                              dec_byp_ex1_instr;
   wire                                      dec_byp_ex0_rs2_sel_imm;
   wire                                      dec_byp_ex0_rs1_sel_zero;
   wire                                      dec_byp_ex1_is_mflr;
   wire                                      dec_byp_ex1_is_mfxer;
   wire                                      dec_byp_ex1_is_mtxer;
   wire                                      dec_byp_ex1_is_mfcr_sel;
   wire [0:7]                                dec_byp_ex1_is_mfcr;
   wire [0:7]                                dec_byp_ex1_is_mtcr;
   wire                                      dec_byp_ex1_is_mfctr;
   wire                                      dec_byp_ex3_is_mtspr;
   wire [2:3]                                dec_byp_ex1_cr_sel;
   wire [2:3]                                dec_byp_ex1_xer_sel;
   wire                                      alu_dec_ex3_trap_val;
   wire                                      dec_byp_ex5_ord_sel;
   wire                                      dec_byp_ex3_mtiar;
   wire                                      dec_pop_ex1_act;
   wire                                      dec_alu_ex1_act;
   wire [0:31]                               dec_alu_ex1_instr;
   wire                                      dec_alu_ex1_sel_isel;
   wire [0:`GPR_WIDTH/8-1]                   dec_alu_ex1_add_rs1_inv;
   wire [0:1]                                dec_alu_ex2_add_ci_sel;
   wire                                      dec_alu_ex1_sel_trap;
   wire                                      dec_alu_ex1_sel_cmpl;
   wire                                      dec_alu_ex1_sel_cmp;
   wire                                      dec_alu_ex1_msb_64b_sel;
   wire                                      dec_alu_ex1_xer_ov_en;
   wire                                      dec_alu_ex1_xer_ca_en;
   wire [64-`GPR_WIDTH:63]                   alu_byp_ex2_add_rt;
   wire [64-`GPR_WIDTH:63]                   alu_byp_ex3_rt;
   wire [0:3]                                alu_byp_ex3_cr;
   wire [0:9]                                alu_byp_ex3_xer;
   wire [64-`GPR_WIDTH:63]                   byp_alu_ex2_rs1;
   wire [64-`GPR_WIDTH:63]                   byp_alu_ex2_rs2;
   wire                                      byp_alu_ex2_cr_bit;
   wire [0:9]                                byp_alu_ex2_xer;
   wire [64-`GPR_WIDTH:63]                   byp_pop_ex2_rs1;
   wire [64-`GPR_WIDTH:63]                   byp_cnt_ex2_rs1;
   wire [64-`GPR_WIDTH:63]                   byp_div_ex2_rs1;
   wire [64-`GPR_WIDTH:63]                   byp_div_ex2_rs2;
   wire [0:9]                                byp_div_ex2_xer;
   wire [0:`GPR_WIDTH-1]                     byp_mul_ex2_rs1;
   wire [0:`GPR_WIDTH-1]                     byp_mul_ex2_rs2;
   wire                                      byp_mul_ex2_abort;
   wire [0:9]                                byp_mul_ex2_xer;
   wire [32:63]                              byp_dlm_ex2_rs1;
   wire [32:63]                              byp_dlm_ex2_rs2;
   wire [0:2]                                byp_dlm_ex2_xer;
   wire                                      br_byp_ex3_lr_we;
   wire [64-`GPR_WIDTH:63]                   br_byp_ex3_lr_wd;
   wire                                      br_byp_ex3_ctr_we;
   wire [64-`GPR_WIDTH:63]                   br_byp_ex3_ctr_wd;
   wire                                      br_byp_ex3_cr_we;
   wire [0:3]                                br_byp_ex3_cr_wd;
   wire [64-`GPR_WIDTH:63]                   div_byp_ex4_rt;
   wire                                      div_byp_ex4_done;
   wire [0:9]                                div_byp_ex4_xer;
   wire [0:3]                                div_byp_ex4_cr;
   wire [0:7]                                dec_div_ex1_div_ctr;
   wire [0:`THREADS-1]                       dec_div_ex1_div_val;
   wire                                      dec_div_ex1_div_act;
   wire                                      dec_div_ex1_div_sign;
   wire                                      dec_div_ex1_div_size;
   wire                                      dec_div_ex1_div_extd;
   wire                                      dec_div_ex1_div_recform;
   wire                                      dec_div_ex1_xer_ov_update;
   wire                                      dec_mul_ex1_mul_recform;
   wire [0:`THREADS-1]                       dec_mul_ex1_mul_val;
   wire                                      dec_mul_ex1_mul_ord;
   wire                                      dec_mul_ex1_mul_ret;
   wire                                      dec_mul_ex1_mul_sign;
   wire                                      dec_mul_ex1_mul_size;
   wire                                      dec_mul_ex1_mul_imm;
   wire                                      dec_mul_ex1_xer_ov_update;
   wire                                      mul_byp_ex5_ord_done;
   wire                                      mul_byp_ex5_done;
   wire                                      mul_byp_ex5_abort;
   wire [64-`GPR_WIDTH:63]                   mul_byp_ex6_rt;
   wire [0:9]                                mul_byp_ex6_xer;
   wire [0:3]                                mul_byp_ex6_cr;
   wire [0:3]                                byp_br_ex3_cr;
   wire [0:3]                                byp_br_ex2_cr1;
   wire [0:3]                                byp_br_ex2_cr2;
   wire [0:3]                                byp_br_ex2_cr3;
   wire [64-`GPR_WIDTH:63]                   byp_br_ex2_lr1;
   wire [64-`GPR_WIDTH:63]                   byp_br_ex2_lr2;
   wire [64-`GPR_WIDTH:63]                   byp_br_ex2_ctr;
   wire                                      ex1_spr_msr_cm;
   wire                                      ex4_spr_msr_cm;
   wire [0:`THREADS-1]                       br_dec_ex3_execute_vld;
   wire                                      dec_byp_ex1_rs_capt;
   wire                                      dec_byp_ex1_ra_capt;
   wire                                      mul_dec_ex6_ord_done;
   wire                                      div_dec_ex4_done;
   wire [64-`GPR_WIDTH:63]                   pop_byp_ex4_rt;
   wire [57:63]                              cnt_byp_ex2_rt;
   wire [56:63]                              prm_byp_ex2_rt;
   wire [25:25]                              dec_cnt_ex2_instr;
   wire                                      dec_byp_ex4_pop_done;
   wire                                      dec_byp_ex3_cnt_done;
   wire                                      dec_byp_ex3_prm_done;
   wire                                      dec_byp_ex3_dlm_done;
   wire                                      dec_br_ex0_act;
   wire [60:63]                              dlm_byp_ex2_rt;
   wire [0:9]                                dlm_byp_ex2_xer;
   wire [0:3]                                dlm_byp_ex2_cr;
   wire                                      dec_bcd_ex1_val;
   wire                                      dec_bcd_ex1_is_addg6s;
   wire                                      dec_bcd_ex1_is_cdtbcd;
   wire [64-`GPR_WIDTH:63]                   byp_bcd_ex2_rs1;
   wire [64-`GPR_WIDTH:63]                   byp_bcd_ex2_rs2;
   wire [64-`GPR_WIDTH:63]                   bcd_byp_ex3_rt;
   wire                                      bcd_byp_ex3_done;
   wire [0:`THREADS-1]                       dec_ord_flush;
   wire                                      dec_byp_ex4_hpriv;
   wire [0:31]                               dec_byp_ex4_instr;
   wire                                      byp_dec_ex2_abort;

   assign mul_dec_ex6_ord_done = mul_byp_ex5_ord_done;
   assign div_dec_ex4_done = div_byp_ex4_done;

   assign xu0_debug_bus_out            = xu0_debug_bus_in;
   assign xu0_coretrace_ctrls_out      = xu0_coretrace_ctrls_in;


   xu_alu alu(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[0]),
      .scan_out(sov[0]),
      .dec_alu_ex1_act(dec_alu_ex1_act),
      .dec_alu_ex1_instr(dec_alu_ex1_instr),
      .dec_alu_ex1_sel_isel(dec_alu_ex1_sel_isel),
      .dec_alu_ex1_add_rs1_inv(dec_alu_ex1_add_rs1_inv),
      .dec_alu_ex2_add_ci_sel(dec_alu_ex2_add_ci_sel),
      .dec_alu_ex1_sel_trap(dec_alu_ex1_sel_trap),
      .dec_alu_ex1_sel_cmpl(dec_alu_ex1_sel_cmpl),
      .dec_alu_ex1_sel_cmp(dec_alu_ex1_sel_cmp),
      .dec_alu_ex1_msb_64b_sel(dec_alu_ex1_msb_64b_sel),
      .dec_alu_ex1_xer_ov_en(dec_alu_ex1_xer_ov_en),
      .dec_alu_ex1_xer_ca_en(dec_alu_ex1_xer_ca_en),
      .byp_alu_ex2_rs1(byp_alu_ex2_rs1),
      .byp_alu_ex2_rs2(byp_alu_ex2_rs2),
      .byp_alu_ex2_cr_bit(byp_alu_ex2_cr_bit),
      .byp_alu_ex2_xer(byp_alu_ex2_xer),
      .alu_byp_ex2_add_rt(alu_byp_ex2_add_rt),
      .alu_byp_ex3_rt(alu_byp_ex3_rt),
      .alu_byp_ex3_cr(alu_byp_ex3_cr),
      .alu_byp_ex3_xer(alu_byp_ex3_xer),
      .alu_dec_ex3_trap_val(alu_dec_ex3_trap_val)
   );


   tri_st_popcnt pop(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .d_mode_dc(d_mode_dc),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[1]),
      .scan_out(sov[1]),
      .ex1_act(dec_pop_ex1_act),
      .ex1_instr(dec_alu_ex1_instr[22:23]),
      .ex2_popcnt_rs1(byp_pop_ex2_rs1),
      .ex4_popcnt_rt(pop_byp_ex4_rt)
   );


   tri_st_cntlz cnt(
      .dword(dec_cnt_ex2_instr[25]),
      .a(byp_cnt_ex2_rs1),
      .y(cnt_byp_ex2_rt)
   );

   generate begin : bperm
      genvar i;
      for (i=0;i<=7;i=i+1) begin : bprm_bit
         xu0_bprm bperm_bit(
            .a(byp_alu_ex2_rs2),
            .s(byp_alu_ex2_rs1[8 * i + 0:8 * i + 7]),
            .y(prm_byp_ex2_rt[56 + i])
         );
      end
   end
   endgenerate


   xu0_bcd bcd(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[2]),
      .scan_out(sov[2]),
      .dec_bcd_ex1_val(dec_bcd_ex1_val),
      .dec_bcd_ex1_is_addg6s(dec_bcd_ex1_is_addg6s),
      .dec_bcd_ex1_is_cdtbcd(dec_bcd_ex1_is_cdtbcd),
      .byp_bcd_ex2_rs1(byp_bcd_ex2_rs1),
      .byp_bcd_ex2_rs2(byp_bcd_ex2_rs2),
      .bcd_byp_ex3_rt(bcd_byp_ex3_rt),
      .bcd_byp_ex3_done(bcd_byp_ex3_done)
   );


   xu0_dlmzb dlm(
      .byp_dlm_ex2_rs1(byp_dlm_ex2_rs1),
      .byp_dlm_ex2_rs2(byp_dlm_ex2_rs2),
      .byp_dlm_ex2_xer(byp_dlm_ex2_xer),
      .dlm_byp_ex2_xer(dlm_byp_ex2_xer),
      .dlm_byp_ex2_cr(dlm_byp_ex2_cr),
      .dlm_byp_ex2_rt(dlm_byp_ex2_rt)
   );


   xu0_div_r4 div(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[3]),
      .scan_out(sov[3]),
      .dec_div_ex1_div_ctr(dec_div_ex1_div_ctr),
      .dec_div_ex1_div_act(dec_div_ex1_div_act),
      .dec_div_ex1_div_val(dec_div_ex1_div_val),
      .dec_div_ex1_div_sign(dec_div_ex1_div_sign),
      .dec_div_ex1_div_size(dec_div_ex1_div_size),
      .dec_div_ex1_div_extd(dec_div_ex1_div_extd),
      .dec_div_ex1_div_recform(dec_div_ex1_div_recform),
      .dec_div_ex1_xer_ov_update(dec_div_ex1_xer_ov_update),
      .byp_div_ex2_rs1(byp_div_ex2_rs1),
      .byp_div_ex2_rs2(byp_div_ex2_rs2),
      .byp_div_ex2_xer(byp_div_ex2_xer),
      .cp_flush(dec_ord_flush),
      .div_byp_ex4_rt(div_byp_ex4_rt),
      .div_byp_ex4_done(div_byp_ex4_done),
      .div_byp_ex4_xer(div_byp_ex4_xer),
      .div_byp_ex4_cr(div_byp_ex4_cr),
      .ex1_spr_msr_cm(ex1_spr_msr_cm),
      .div_spr_running(div_spr_running)
   );


   tri_st_mult mult(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[4]),
      .scan_out(sov[4]),
      .dec_mul_ex1_mul_recform(dec_mul_ex1_mul_recform),
      .dec_mul_ex1_mul_val(dec_mul_ex1_mul_val),
      .dec_mul_ex1_mul_ord(dec_mul_ex1_mul_ord),
      .dec_mul_ex1_mul_ret(dec_mul_ex1_mul_ret),
      .dec_mul_ex1_mul_sign(dec_mul_ex1_mul_sign),
      .dec_mul_ex1_mul_size(dec_mul_ex1_mul_size),
      .dec_mul_ex1_mul_imm(dec_mul_ex1_mul_imm),
      .dec_mul_ex1_xer_ov_update(dec_mul_ex1_xer_ov_update),
      .cp_flush(cp_flush),
      .ex1_spr_msr_cm(ex1_spr_msr_cm),
      .byp_mul_ex2_rs1(byp_mul_ex2_rs1),
      .byp_mul_ex2_rs2(byp_mul_ex2_rs2),
      .byp_mul_ex2_abort(byp_mul_ex2_abort),
      .byp_mul_ex2_xer(byp_mul_ex2_xer),
      .mul_byp_ex5_abort(mul_byp_ex5_abort),
      .mul_byp_ex6_rt(mul_byp_ex6_rt),
      .mul_byp_ex6_xer(mul_byp_ex6_xer),
      .mul_byp_ex6_cr(mul_byp_ex6_cr),
      .mul_byp_ex5_ord_done(mul_byp_ex5_ord_done),
      .mul_byp_ex5_done(mul_byp_ex5_done),
      .mul_spr_running(mul_spr_running)
   );


   xu0_br br(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .pc_br_func_sl_thold_2(1'b0),		//<<TEMP>>
      .pc_br_sg_2(1'b1),		//<<TEMP>>
      .clkoff_b(1'b1),		//<<TEMP>>
      .act_dis(1'b0),		//<<TEMP>>
      .tc_ac_ccflush_dc(pc_xu_ccflush_dc),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .scan_in(siv[5]),
      .scan_out(sov[5]),
      .rv_br_vld(rv_xu0_vld),
      .rv_br_ex0_fusion(rv_xu0_ex0_fusion[0]),
      .rv_br_ex0_instr(rv_xu0_ex0_instr),
      .rv_br_ex0_ifar(rv_xu0_ex0_ifar),
      .rv_br_ex0_itag(rv_xu0_ex0_itag),
      .rv_br_ex0_t2_p(rv_xu0_ex0_t2_p),
      .rv_br_ex0_t3_p(rv_xu0_ex0_t3_p),
      .rv_br_ex0_bta_val(rv_xu0_ex0_bta_val),
      .rv_br_ex0_pred_bta(rv_xu0_ex0_pred_bta),
      .rv_br_ex0_pred(rv_xu0_ex0_pred),
      .rv_br_ex0_ls_ptr(rv_xu0_ex0_ls_ptr),
      .rv_br_ex0_bh_update(rv_xu0_ex0_bh_update),
      .rv_br_ex0_gshare(rv_xu0_ex0_gshare),
      .rv_br_ex0_spec_flush(rv_xu0_ex0_spec_flush),
      .rv_br_ex1_spec_flush(rv_xu0_ex1_spec_flush),
      .dec_br_ex0_act(dec_br_ex0_act),
      .bp_br_ex2_abort(byp_dec_ex2_abort),
      .byp_br_ex2_cr1(byp_br_ex2_cr1),
      .byp_br_ex2_cr2(byp_br_ex2_cr2),
      .byp_br_ex2_cr3(byp_br_ex2_cr3),
      .byp_br_ex2_lr1(byp_br_ex2_lr1),
      .byp_br_ex2_lr2(byp_br_ex2_lr2),
      .byp_br_ex2_ctr(byp_br_ex2_ctr),
      .mux_br_ex3_cr(byp_br_ex3_cr),
      .br_lr_we(br_byp_ex3_lr_we),
      .br_lr_wd(br_byp_ex3_lr_wd),
      .br_ctr_we(br_byp_ex3_ctr_we),
      .br_ctr_wd(br_byp_ex3_ctr_wd),
      .br_cr_we(br_byp_ex3_cr_we),
      .br_cr_wd(br_byp_ex3_cr_wd),
      .br_iu_execute_vld(br_iu_execute_vld),
      .br_iu_itag(br_iu_itag),
      .br_iu_taken(br_iu_taken),
      .br_iu_bta(br_iu_bta),
      .br_iu_gshare(br_iu_gshare),
      .br_iu_ls_ptr(br_iu_ls_ptr),
      .br_iu_ls_data(br_iu_ls_data),
      .br_iu_ls_update(br_iu_ls_update),
      .br_iu_redirect(br_iu_redirect),
      .br_iu_perf_events(br_iu_perf_events),
      .perf_event_en(perf_event_en),
      .spr_xesr2(spr_xesr2),
      .spr_msr_cm(spr_msr_cm),		//<<TEMP>>
      .br_dec_ex3_execute_vld(br_dec_ex3_execute_vld),
      .iu_br_t0_flush_ifar(iu_br_t0_flush_ifar),
      `ifndef THREADS1
      .iu_br_t1_flush_ifar(iu_br_t1_flush_ifar),
      `endif
      .iu_br_flush(cp_flush)
   );


   xu0_byp byp(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[6]),
      .scan_out(sov[6]),
      .ex4_spr_msr_cm(ex4_spr_msr_cm),
      .dec_byp_ex0_act(dec_byp_ex0_act),
      .xu1_xu0_ex3_act(xu1_xu0_ex3_act),
      .lq_xu_ex5_act(lq_xu_ex5_act),
      .dec_byp_ex1_imm(dec_byp_ex1_imm),
      .dec_byp_ex1_instr(dec_byp_ex1_instr),
      .dec_byp_ex1_is_mflr(dec_byp_ex1_is_mflr),
      .dec_byp_ex1_is_mfxer(dec_byp_ex1_is_mfxer),
      .dec_byp_ex1_is_mtxer(dec_byp_ex1_is_mtxer),
      .dec_byp_ex1_is_mfcr_sel(dec_byp_ex1_is_mfcr_sel),
      .dec_byp_ex1_is_mfcr(dec_byp_ex1_is_mfcr),
      .dec_byp_ex1_is_mtcr(dec_byp_ex1_is_mtcr),
      .dec_byp_ex1_is_mfctr(dec_byp_ex1_is_mfctr),
      .dec_byp_ex3_is_mtspr(dec_byp_ex3_is_mtspr),
      .dec_byp_ex1_cr_sel(dec_byp_ex1_cr_sel),
      .dec_byp_ex1_xer_sel(dec_byp_ex1_xer_sel),
      .dec_byp_ex1_rs_capt(dec_byp_ex1_rs_capt),
      .dec_byp_ex1_ra_capt(dec_byp_ex1_ra_capt),
      .dec_byp_ex0_rs2_sel_imm(dec_byp_ex0_rs2_sel_imm),
      .dec_byp_ex0_rs1_sel_zero(dec_byp_ex0_rs1_sel_zero),
      .dec_byp_ex3_mtiar(dec_byp_ex3_mtiar),
      .dec_byp_ex4_hpriv(dec_byp_ex4_hpriv),
      .dec_byp_ex4_instr(dec_byp_ex4_instr),
      .dec_byp_ex5_ord_sel(dec_byp_ex5_ord_sel),
      .rv_xu0_ex0_s1_v(rv_xu0_ex0_s1_v),
      .rv_xu0_ex0_s2_v(rv_xu0_ex0_s2_v),
      .rv_xu0_ex0_s3_v(rv_xu0_ex0_s3_v),
      .rv_xu0_s1_fxu0_sel(rv_xu0_s1_fxu0_sel),
      .rv_xu0_s2_fxu0_sel(rv_xu0_s2_fxu0_sel),
      .rv_xu0_s3_fxu0_sel(rv_xu0_s3_fxu0_sel),
      .rv_xu0_s1_fxu1_sel(rv_xu0_s1_fxu1_sel),
      .rv_xu0_s2_fxu1_sel(rv_xu0_s2_fxu1_sel),
      .rv_xu0_s3_fxu1_sel(rv_xu0_s3_fxu1_sel),
      .rv_xu0_s1_lq_sel(rv_xu0_s1_lq_sel),
      .rv_xu0_s2_lq_sel(rv_xu0_s2_lq_sel),
      .rv_xu0_s3_lq_sel(rv_xu0_s3_lq_sel),
      .rv_xu0_s1_rel_sel(rv_xu0_s1_rel_sel),
      .rv_xu0_s2_rel_sel(rv_xu0_s2_rel_sel),
      .gpr_xu0_ex1_r1d(gpr_xu0_ex1_r1d),
      .gpr_xu0_ex1_r2d(gpr_xu0_ex1_r2d),
      .xer_xu0_ex1_r2d(xer_xu0_ex1_r2d),
      .xer_xu0_ex1_r3d(xer_xu0_ex1_r3d),
      .cr_xu0_ex1_r1d(cr_xu0_ex1_r1d),
      .cr_xu0_ex1_r2d(cr_xu0_ex1_r2d),
      .cr_xu0_ex1_r3d(cr_xu0_ex1_r3d),
      .lr_xu0_ex1_r1d(lr_xu0_ex1_r1d),
      .lr_xu0_ex1_r2d(lr_xu0_ex1_r2d),
      .ctr_xu0_ex1_r2d(ctr_xu0_ex1_r2d),
      .xu1_xu0_ex2_abort(xu1_xu0_ex2_abort),
      .xu1_xu0_ex2_rt(xu1_xu0_ex2_rt),
      .xu1_xu0_ex3_rt(xu1_xu0_ex3_rt),
      .xu1_xu0_ex4_rt(xu1_xu0_ex4_rt),
      .xu1_xu0_ex5_rt(xu1_xu0_ex5_rt),
      .lq_xu_ex5_abort(lq_xu_ex5_abort),
      .lq_xu_ex5_rt(lq_xu_ex5_rt),
      .lq_xu_rel_act(lq_xu_rel_act),
      .lq_xu_rel_rt(lq_xu_rel_rt),
      .lq_xu_ex5_data(lq_xu_ex5_data),
      .lq_xu_ex5_cr(lq_xu_ex5_cr),
      .xu1_xu0_ex3_cr(xu1_xu0_ex3_cr),
      .xu1_xu0_ex3_xer(xu1_xu0_ex3_xer),
      .alu_byp_ex2_add_rt(alu_byp_ex2_add_rt),
      .alu_byp_ex3_rt(alu_byp_ex3_rt),
      .alu_byp_ex3_cr(alu_byp_ex3_cr),
      .alu_byp_ex3_xer(alu_byp_ex3_xer),
      .br_byp_ex3_lr_we(br_byp_ex3_lr_we),
      .br_byp_ex3_lr_wd(br_byp_ex3_lr_wd),
      .br_byp_ex3_ctr_we(br_byp_ex3_ctr_we),
      .br_byp_ex3_ctr_wd(br_byp_ex3_ctr_wd),
      .br_byp_ex3_cr_we(br_byp_ex3_cr_we),
      .br_byp_ex3_cr_wd(br_byp_ex3_cr_wd),
      .spr_xu_ord_write_done(spr_xu_ord_write_done),
      .spr_xu_ex4_rd_data(spr_xu_ex4_rd_data),
      .xu_spr_ex2_rs1(xu_spr_ex2_rs1),
      .xu_slowspr_val_in(xu_slowspr_val_in),
      .xu_slowspr_rw_in(xu_slowspr_rw_in),
      .xu_slowspr_data_in(xu_slowspr_data_in),
      .xu_slowspr_done_in(xu_slowspr_done_in),
      .div_byp_ex4_done(div_byp_ex4_done),
      .div_byp_ex4_rt(div_byp_ex4_rt),
      .div_byp_ex4_xer(div_byp_ex4_xer),
      .div_byp_ex4_cr(div_byp_ex4_cr),
      .mul_byp_ex5_ord_done(mul_byp_ex5_ord_done),
      .mul_byp_ex5_done(mul_byp_ex5_done),
      .mul_byp_ex5_abort(mul_byp_ex5_abort),
      .mul_byp_ex6_rt(mul_byp_ex6_rt),
      .mul_byp_ex6_xer(mul_byp_ex6_xer),
      .mul_byp_ex6_cr(mul_byp_ex6_cr),
      .dec_byp_ex4_pop_done(dec_byp_ex4_pop_done),
      .dec_byp_ex3_cnt_done(dec_byp_ex3_cnt_done),
      .dec_byp_ex3_prm_done(dec_byp_ex3_prm_done),
      .dec_byp_ex3_dlm_done(dec_byp_ex3_dlm_done),
      .bcd_byp_ex3_done(bcd_byp_ex3_done),
      .pop_byp_ex4_rt(pop_byp_ex4_rt),
      .cnt_byp_ex2_rt(cnt_byp_ex2_rt),
      .prm_byp_ex2_rt(prm_byp_ex2_rt),
      .dlm_byp_ex2_rt(dlm_byp_ex2_rt),
      .dlm_byp_ex2_xer(dlm_byp_ex2_xer),
      .dlm_byp_ex2_cr(dlm_byp_ex2_cr),
      .bcd_byp_ex3_rt(bcd_byp_ex3_rt),
      .iu_xu_ord_write_done(iu_xu_ord_write_done),
      .iu_xu_ex5_data(iu_xu_ex5_data),
      .lq_xu_ord_write_done(lq_xu_ord_write_done),
      .mm_xu_cr0_eq(mm_xu_cr0_eq),
      .mm_xu_cr0_eq_valid(mm_xu_cr0_eq_valid),
      .xu0_iu_bta(xu0_iu_bta),
      .xu_iu_rs_is(xu_iu_rs_is),
      .xu_iu_ra_entry(xu_iu_ra_entry),
      .xu_iu_rb(xu_iu_rb),
      .xu_iu_rs_data(xu_iu_rs_data),
      .xu_lq_rs_is(xu_lq_rs_is),
      .xu_lq_ra_entry(xu_lq_ra_entry),
      .xu_lq_rb(xu_lq_rb),
      .xu_lq_rs_data(xu_lq_rs_data),
      .xu_mm_ra_entry(xu_mm_ra_entry),
      .xu_mm_rb(xu_mm_rb),
      .xu0_xu1_ex2_abort(xu0_xu1_ex2_abort),
      .xu0_xu1_ex6_abort(xu0_xu1_ex6_abort),
      .xu0_lq_ex3_abort(xu0_lq_ex3_abort),
      .xu0_xu1_ex2_rt(xu0_xu1_ex2_rt),
      .xu0_xu1_ex3_rt(xu0_xu1_ex3_rt),
      .xu0_xu1_ex4_rt(xu0_xu1_ex4_rt),
      .xu0_xu1_ex5_rt(xu0_xu1_ex5_rt),
      .xu0_xu1_ex6_rt(xu0_xu1_ex6_rt),
      .xu0_xu1_ex7_rt(xu0_xu1_ex7_rt),
      .xu0_xu1_ex8_rt(xu0_xu1_ex8_rt),
      .xu0_xu1_ex6_lq_rt(xu0_xu1_ex6_lq_rt),
      .xu0_xu1_ex7_lq_rt(xu0_xu1_ex7_lq_rt),
      .xu0_xu1_ex8_lq_rt(xu0_xu1_ex8_lq_rt),
      .xu0_lq_ex3_rt(xu0_lq_ex3_rt),
      .xu0_lq_ex4_rt(xu0_lq_ex4_rt),
      .xu0_lq_ex6_act(xu0_lq_ex6_act),
      .xu0_lq_ex6_rt(xu0_lq_ex6_rt),
      .xu0_pc_ram_data(xu0_pc_ram_data),
      .xu0_xu1_ex3_cr(xu0_xu1_ex3_cr),
      .xu0_xu1_ex4_cr(xu0_xu1_ex4_cr),
      .xu0_xu1_ex6_cr(xu0_xu1_ex6_cr),
      .xu0_xu1_ex3_xer(xu0_xu1_ex3_xer),
      .xu0_xu1_ex4_xer(xu0_xu1_ex4_xer),
      .xu0_xu1_ex6_xer(xu0_xu1_ex6_xer),
      .byp_alu_ex2_rs1(byp_alu_ex2_rs1),
      .byp_alu_ex2_rs2(byp_alu_ex2_rs2),
      .byp_alu_ex2_cr_bit(byp_alu_ex2_cr_bit),
      .byp_alu_ex2_xer(byp_alu_ex2_xer),
      .byp_pop_ex2_rs1(byp_pop_ex2_rs1),
      .byp_cnt_ex2_rs1(byp_cnt_ex2_rs1),
      .byp_div_ex2_rs1(byp_div_ex2_rs1),
      .byp_div_ex2_rs2(byp_div_ex2_rs2),
      .byp_div_ex2_xer(byp_div_ex2_xer),
      .byp_mul_ex2_rs1(byp_mul_ex2_rs1),
      .byp_mul_ex2_rs2(byp_mul_ex2_rs2),
      .byp_mul_ex2_abort(byp_mul_ex2_abort),
      .byp_mul_ex2_xer(byp_mul_ex2_xer),
      .byp_dlm_ex2_rs1(byp_dlm_ex2_rs1),
      .byp_dlm_ex2_rs2(byp_dlm_ex2_rs2),
      .byp_dlm_ex2_xer(byp_dlm_ex2_xer),
      .byp_bcd_ex2_rs1(byp_bcd_ex2_rs1),
      .byp_bcd_ex2_rs2(byp_bcd_ex2_rs2),
      .byp_br_ex3_cr(byp_br_ex3_cr),
      .byp_br_ex2_cr1(byp_br_ex2_cr1),
      .byp_br_ex2_cr2(byp_br_ex2_cr2),
      .byp_br_ex2_cr3(byp_br_ex2_cr3),
      .byp_br_ex2_lr1(byp_br_ex2_lr1),
      .byp_br_ex2_lr2(byp_br_ex2_lr2),
      .byp_br_ex2_ctr(byp_br_ex2_ctr),
      .xu0_rv_ex2_s1_abort(xu0_rv_ex2_s1_abort),
      .xu0_rv_ex2_s2_abort(xu0_rv_ex2_s2_abort),
      .xu0_rv_ex2_s3_abort(xu0_rv_ex2_s3_abort),
      .byp_dec_ex2_abort(byp_dec_ex2_abort),
      .xu0_gpr_ex6_wd(xu0_gpr_ex6_wd),
      .xu0_xer_ex6_w0d(xu0_xer_ex6_w0d),
      .xu0_cr_ex6_w0d(xu0_cr_ex6_w0d),
      .xu0_ctr_ex4_w0d(xu0_ctr_ex4_w0d),
      .xu0_lr_ex4_w0d(xu0_lr_ex4_w0d)
   );


   xu0_dec dec(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[7]),
      .scan_out(sov[7]),
      .cp_flush(cp_flush),
      .cp_next_itag_t0(cp_next_itag_t0),
      `ifndef THREADS1
      .cp_next_itag_t1(cp_next_itag_t1),
      `endif
      .dec_ex0_flush(),
      .dec_ex1_flush(),
      .dec_ex2_flush(),
      .dec_ex3_flush(),
      .dec_cp_flush(),
      .rv_xu0_vld(rv_xu0_vld),
      .rv_xu0_ex0_ord(rv_xu0_ex0_ord),
      .rv_xu0_ex0_fusion(rv_xu0_ex0_fusion),
      .rv_xu0_ex0_instr(rv_xu0_ex0_instr),
      .rv_xu0_ex0_itag(rv_xu0_ex0_itag),
      .rv_xu0_ex0_ucode(rv_xu0_ex0_ucode),
      .rv_xu0_ex0_s1_v(rv_xu0_ex0_s1_v),
      .rv_xu0_ex0_s2_v(rv_xu0_ex0_s2_v),
      .rv_xu0_ex0_s2_t(rv_xu0_ex0_s2_t),
      .rv_xu0_ex0_s3_v(rv_xu0_ex0_s3_v),
      .rv_xu0_ex0_s3_t(rv_xu0_ex0_s3_t),
      .rv_xu0_ex0_t1_v(rv_xu0_ex0_t1_v),
      .rv_xu0_ex0_t1_p(rv_xu0_ex0_t1_p),
      .rv_xu0_ex0_t1_t(rv_xu0_ex0_t1_t),
      .rv_xu0_ex0_t2_v(rv_xu0_ex0_t2_v),
      .rv_xu0_ex0_t2_p(rv_xu0_ex0_t2_p),
      .rv_xu0_ex0_t2_t(rv_xu0_ex0_t2_t),
      .rv_xu0_ex0_t3_v(rv_xu0_ex0_t3_v),
      .rv_xu0_ex0_t3_p(rv_xu0_ex0_t3_p),
      .rv_xu0_ex0_t3_t(rv_xu0_ex0_t3_t),
      .rv_xu0_ex0_spec_flush(rv_xu0_ex0_spec_flush),
      .rv_xu0_ex1_spec_flush(rv_xu0_ex1_spec_flush),
      .rv_xu0_ex2_spec_flush(rv_xu0_ex2_spec_flush),
      .xu0_rv_ord_complete(xu0_rv_ord_complete),
      .xu0_rv_ord_itag(xu0_rv_ord_itag),
      .xu0_rv_hold_all(xu0_rv_hold_all),
      .xu0_iu_execute_vld(xu0_iu_execute_vld),
      .xu0_iu_itag(xu0_iu_itag),
      .xu0_iu_mtiar(xu0_iu_mtiar),
      .xu0_iu_exception_val(xu0_iu_exception_val),
      .xu0_iu_exception(xu0_iu_exception),
      .xu0_iu_n_flush(xu0_iu_n_flush),
      .xu0_iu_np1_flush(xu0_iu_np1_flush),
      .xu0_iu_flush2ucode(xu0_iu_flush2ucode),
      .xu0_iu_perf_events(xu0_iu_perf_events),
      .xu0_pc_ram_done(xu0_pc_ram_done),
      .xu_iu_np1_async_flush(xu_iu_np1_async_flush),
      .iu_xu_async_complete(iu_xu_async_complete),
      .iu_xu_credits_returned(iu_xu_credits_returned),
      .xu_iu_pri_val(xu_iu_pri_val),
      .xu_iu_pri(xu_iu_pri),
      .dec_pop_ex1_act(dec_pop_ex1_act),
      .dec_alu_ex1_act(dec_alu_ex1_act),
      .dec_alu_ex1_instr(dec_alu_ex1_instr),
      .dec_alu_ex1_sel_isel(dec_alu_ex1_sel_isel),
      .dec_alu_ex1_add_rs1_inv(dec_alu_ex1_add_rs1_inv),
      .dec_alu_ex2_add_ci_sel(dec_alu_ex2_add_ci_sel),
      .dec_alu_ex1_sel_trap(dec_alu_ex1_sel_trap),
      .dec_alu_ex1_sel_cmpl(dec_alu_ex1_sel_cmpl),
      .dec_alu_ex1_sel_cmp(dec_alu_ex1_sel_cmp),
      .dec_alu_ex1_msb_64b_sel(dec_alu_ex1_msb_64b_sel),
      .dec_alu_ex1_xer_ov_en(dec_alu_ex1_xer_ov_en),
      .dec_alu_ex1_xer_ca_en(dec_alu_ex1_xer_ca_en),
      .alu_dec_ex3_trap_val(alu_dec_ex3_trap_val),
      .xu0_xu1_ex3_act(xu0_xu1_ex3_act),
      .dec_mul_ex1_mul_recform(dec_mul_ex1_mul_recform),
      .dec_mul_ex1_mul_val(dec_mul_ex1_mul_val),
      .dec_mul_ex1_mul_ord(dec_mul_ex1_mul_ord),
      .dec_mul_ex1_mul_ret(dec_mul_ex1_mul_ret),
      .dec_mul_ex1_mul_sign(dec_mul_ex1_mul_sign),
      .dec_mul_ex1_mul_size(dec_mul_ex1_mul_size),
      .dec_mul_ex1_mul_imm(dec_mul_ex1_mul_imm),
      .dec_mul_ex1_xer_ov_update(dec_mul_ex1_xer_ov_update),
      .mul_dec_ex6_ord_done(mul_dec_ex6_ord_done),
      .dec_ord_flush(dec_ord_flush),
      .dec_div_ex1_div_ctr(dec_div_ex1_div_ctr),
      .dec_div_ex1_div_act(dec_div_ex1_div_act),
      .dec_div_ex1_div_val(dec_div_ex1_div_val),
      .dec_div_ex1_div_sign(dec_div_ex1_div_sign),
      .dec_div_ex1_div_size(dec_div_ex1_div_size),
      .dec_div_ex1_div_extd(dec_div_ex1_div_extd),
      .dec_div_ex1_div_recform(dec_div_ex1_div_recform),
      .dec_div_ex1_xer_ov_update(dec_div_ex1_xer_ov_update),
      .div_dec_ex4_done(div_dec_ex4_done),
      .spr_xu_ord_read_done(spr_xu_ord_read_done),
      .spr_xu_ord_write_done(spr_xu_ord_write_done),
      .spr_dec_ex4_spr_hypv(spr_dec_ex4_spr_hypv),
      .spr_dec_ex4_spr_illeg(spr_dec_ex4_spr_illeg),
      .spr_dec_ex4_spr_priv(spr_dec_ex4_spr_priv),
      .spr_dec_ex4_np1_flush(spr_dec_ex4_np1_flush),
      .xu_slowspr_val_in(xu_slowspr_val_in),
      .xu_slowspr_rw_in(xu_slowspr_rw_in),
      .dec_bcd_ex1_val(dec_bcd_ex1_val),
      .dec_bcd_ex1_is_addg6s(dec_bcd_ex1_is_addg6s),
      .dec_bcd_ex1_is_cdtbcd(dec_bcd_ex1_is_cdtbcd),
      .byp_dec_ex2_abort(byp_dec_ex2_abort),
      .dec_byp_ex0_act(dec_byp_ex0_act),
      .dec_byp_ex1_imm(dec_byp_ex1_imm),
      .dec_byp_ex1_instr(dec_byp_ex1_instr),
      .dec_byp_ex0_rs2_sel_imm(dec_byp_ex0_rs2_sel_imm),
      .dec_byp_ex0_rs1_sel_zero(dec_byp_ex0_rs1_sel_zero),
      .dec_byp_ex1_is_mflr(dec_byp_ex1_is_mflr),
      .dec_byp_ex1_is_mfxer(dec_byp_ex1_is_mfxer),
      .dec_byp_ex1_is_mtxer(dec_byp_ex1_is_mtxer),
      .dec_byp_ex1_is_mfcr_sel(dec_byp_ex1_is_mfcr_sel),
      .dec_byp_ex1_is_mfcr(dec_byp_ex1_is_mfcr),
      .dec_byp_ex1_is_mtcr(dec_byp_ex1_is_mtcr),
      .dec_byp_ex1_is_mfctr(dec_byp_ex1_is_mfctr),
      .dec_byp_ex3_is_mtspr(dec_byp_ex3_is_mtspr),
      .dec_byp_ex1_cr_sel(dec_byp_ex1_cr_sel),
      .dec_byp_ex1_xer_sel(dec_byp_ex1_xer_sel),
      .dec_byp_ex1_rs_capt(dec_byp_ex1_rs_capt),
      .dec_byp_ex1_ra_capt(dec_byp_ex1_ra_capt),
      .dec_byp_ex3_mtiar(dec_byp_ex3_mtiar),
      .dec_byp_ex5_ord_sel(dec_byp_ex5_ord_sel),
      .dec_byp_ex4_pop_done(dec_byp_ex4_pop_done),
      .dec_byp_ex3_cnt_done(dec_byp_ex3_cnt_done),
      .dec_byp_ex3_prm_done(dec_byp_ex3_prm_done),
      .dec_byp_ex3_dlm_done(dec_byp_ex3_dlm_done),
      .dec_byp_ex4_hpriv(dec_byp_ex4_hpriv),
      .dec_byp_ex4_instr(dec_byp_ex4_instr),
      .dec_cnt_ex2_instr(dec_cnt_ex2_instr),
      .dec_br_ex0_act(dec_br_ex0_act),
      .br_dec_ex3_execute_vld(br_dec_ex3_execute_vld),
      .xu0_gpr_ex6_we(xu0_gpr_ex6_we),
      .xu0_gpr_ex6_wa(xu0_gpr_ex6_wa),
      .xu0_xer_ex6_we(xu0_xer_ex6_we),
      .xu0_xer_ex6_wa(xu0_xer_ex6_wa),
      .xu0_cr_ex6_we(xu0_cr_ex6_we),
      .xu0_cr_ex6_wa(xu0_cr_ex6_wa),
      .xu0_ctr_ex4_we(xu0_ctr_ex4_we),
      .xu0_ctr_ex4_wa(xu0_ctr_ex4_wa),
      .xu0_lr_ex4_we(xu0_lr_ex4_we),
      .xu0_lr_ex4_wa(xu0_lr_ex4_wa),
      .xu_iu_ord_ready(xu_iu_ord_ready),
      .xu_iu_act(xu_iu_act),
      .xu_iu_val(xu_iu_val),
      .xu_iu_is_eratre(xu_iu_is_eratre),
      .xu_iu_is_eratwe(xu_iu_is_eratwe),
      .xu_iu_is_eratsx(xu_iu_is_eratsx),
      .xu_iu_is_eratilx(xu_iu_is_eratilx),
      .xu_iu_is_erativax(xu_iu_is_erativax),
      .xu_iu_ws(xu_iu_ws),
      .xu_iu_t(xu_iu_t),
      .iu_xu_ord_read_done(iu_xu_ord_read_done),
      .iu_xu_ord_write_done(iu_xu_ord_write_done),
      .iu_xu_ord_n_flush_req(iu_xu_ord_n_flush_req),
      .iu_xu_ord_par_err(iu_xu_ord_par_err),
      .xu_lq_ord_ready(xu_lq_ord_ready),
      .xu_lq_act(xu_lq_act),
      .xu_lq_val(xu_lq_val),
      .xu_lq_hold_req(xu_lq_hold_req),
      .xu_lq_is_eratre(xu_lq_is_eratre),
      .xu_lq_is_eratwe(xu_lq_is_eratwe),
      .xu_lq_is_eratsx(xu_lq_is_eratsx),
      .xu_lq_is_eratilx(xu_lq_is_eratilx),
      .xu_lq_ws(xu_lq_ws),
      .xu_lq_t(xu_lq_t),
      .lq_xu_ord_read_done(lq_xu_ord_read_done),
      .lq_xu_ord_write_done(lq_xu_ord_write_done),
      .lq_xu_ord_n_flush_req(lq_xu_ord_n_flush_req),
      .lq_xu_ord_par_err(lq_xu_ord_par_err),
      .xu_mm_ord_ready(xu_mm_ord_ready),
      .xu_mm_act(xu_mm_act),
      .xu_mm_val(xu_mm_val),
      .xu_mm_itag(xu_mm_itag),
      .xu_mm_is_tlbre(xu_mm_is_tlbre),
      .xu_mm_is_tlbwe(xu_mm_is_tlbwe),
      .xu_mm_is_tlbsx(xu_mm_is_tlbsx),
      .xu_mm_is_tlbsxr(xu_mm_is_tlbsxr),
      .xu_mm_is_tlbsrx(xu_mm_is_tlbsrx),
      .xu_mm_is_tlbivax(xu_mm_is_tlbivax),
      .xu_mm_is_tlbilx(xu_mm_is_tlbilx),
      .mm_xu_itag(mm_xu_itag),
      .mm_xu_ord_n_flush_req(mm_xu_ord_n_flush_req),
      .mm_xu_ord_read_done(mm_xu_ord_read_done),
      .mm_xu_ord_write_done(mm_xu_ord_write_done),
      .mm_xu_tlb_miss(mm_xu_tlb_miss),
      .mm_xu_lrat_miss(mm_xu_lrat_miss),
      .mm_xu_tlb_inelig(mm_xu_tlb_inelig),
      .mm_xu_pt_fault(mm_xu_pt_fault),
      .mm_xu_hv_priv(mm_xu_hv_priv),
      .mm_xu_illeg_instr(mm_xu_illeg_instr),
      .mm_xu_tlb_multihit(mm_xu_tlb_multihit),
      .mm_xu_tlb_par_err(mm_xu_tlb_par_err),
      .mm_xu_lru_par_err(mm_xu_lru_par_err),
      .mm_xu_local_snoop_reject(mm_xu_local_snoop_reject),
      .mm_xu_mmucr0_tlbsel_t0(mm_xu_mmucr0_tlbsel_t0),
      `ifndef THREADS1
      .mm_xu_mmucr0_tlbsel_t1(mm_xu_mmucr0_tlbsel_t1),
      `endif
      .mm_xu_tlbwe_binv(mm_xu_tlbwe_binv),
      .xu_spr_ord_flush(xu_spr_ord_flush),
      .xu_spr_ord_ready(xu_spr_ord_ready),
      .ex1_spr_msr_cm(ex1_spr_msr_cm),
      .ex4_spr_msr_cm(ex4_spr_msr_cm),
      .spr_msr_cm(spr_msr_cm),
      .spr_msr_gs(spr_msr_gs),
      .spr_msr_pr(spr_msr_pr),
      .spr_epcr_dgtmi(spr_epcr_dgtmi),
      .spr_ccr2_notlb(spr_ccr2_notlb),
      .spr_ccr2_en_attn(spr_ccr2_en_attn),
      .spr_ccr4_en_dnh(spr_ccr4_en_dnh),
      .spr_ccr2_en_pc(spr_ccr2_en_pc),
      .spr_xesr1(spr_xesr1),
      .perf_event_en(perf_event_en),
      .pc_xu_ram_active(pc_xu_ram_active)
   );

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];


endmodule
