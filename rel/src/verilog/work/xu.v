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

//  Description:  Dual Execution Unit
//
//*****************************************************************************
`include "tri_a2o.vh"
(* recursive_synthesis="0" *)
module xu(
   //-------------------------------------------------------------------
   // Clocks & Power
   //-------------------------------------------------------------------
   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) // nclk
   input [0:`NCLK_WIDTH-1]                                  nclk,

   //-------------------------------------------------------------------
   // Pervasive
   //-------------------------------------------------------------------
   input                                                    pc_xu_ccflush_dc,
   input                                                    clkoff_dc_b,
   input                                                    d_mode_dc,
   input                                                    delay_lclkr_dc,
   input                                                    mpw1_dc_b,
   input                                                    mpw2_dc_b,
   input                                                    func_sl_force,
   input                                                    func_sl_thold_0_b,
   input                                                    func_slp_sl_thold_0_b,
   input                                                    sg_0,
   input                                                    fce_0,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *) // scan_in
   input                                                    scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) // scan_out
   output                                                   scan_out,

   output                                                   xu_pc_ram_done,
   output [64-`GPR_WIDTH:63]                                xu_pc_ram_data,

   //-------------------------------------------------------------------
   // CP Flush Interface
   //-------------------------------------------------------------------
   input [0:`THREADS-1]                                     cp_flush,
   input [62-`EFF_IFAR_ARCH : 61-`EFF_IFAR_WIDTH]           iu_br_t0_flush_ifar,
   input [0:`ITAG_SIZE_ENC-1]                               cp_next_itag_t0,
   `ifndef THREADS1
   input [62-`EFF_IFAR_ARCH : 61-`EFF_IFAR_WIDTH]  iu_br_t1_flush_ifar,
   input [0:`ITAG_SIZE_ENC-1]                      cp_next_itag_t1,
   `endif

   //-------------------------------------------------------------------
   // BR Interface with CP
   //-------------------------------------------------------------------
   output [0:`THREADS-1]                                    br_iu_execute_vld,
   output [0:`ITAG_SIZE_ENC-1]                              br_iu_itag,
   output                                                   br_iu_taken,
   output [62-`EFF_IFAR_ARCH:61]                            br_iu_bta,
   output [0:17]                                            br_iu_gshare,
   output [0:2]                                             br_iu_ls_ptr,
   output [62-`EFF_IFAR_WIDTH:61]                           br_iu_ls_data,
   output                                                   br_iu_ls_update,
   output [0:`THREADS-1]                                    br_iu_redirect,
   output [0:3]						    br_iu_perf_events,

   //-------------------------------------------------------------------
   // RV->XU0 Issue
   //-------------------------------------------------------------------
   input [0:`THREADS-1]                                     rv_xu0_vld,
   input                                                    rv_xu0_s1_v,
   input [0:`GPR_POOL_ENC-1]                                rv_xu0_s1_p,
   input                                                    rv_xu0_s2_v,
   input [0:`GPR_POOL_ENC-1]                                rv_xu0_s2_p,
   input                                                    rv_xu0_s3_v,
   input [0:`GPR_POOL_ENC-1]                                rv_xu0_s3_p,
   input                                                    rv_xu0_ex0_ord,
   input [0:19]                                             rv_xu0_ex0_fusion,
   input [0:31]                                             rv_xu0_ex0_instr,
   input [62-`EFF_IFAR_WIDTH:61]                            rv_xu0_ex0_ifar,
   input [0:`ITAG_SIZE_ENC-1]                               rv_xu0_ex0_itag,
   input [0:2]                                              rv_xu0_ex0_ucode,
   input                                                    rv_xu0_ex0_bta_val,
   input [62-`EFF_IFAR_WIDTH:61]                            rv_xu0_ex0_pred_bta,
   input                                                    rv_xu0_ex0_pred,
   input [0:2]                                              rv_xu0_ex0_ls_ptr,
   input                                                    rv_xu0_ex0_bh_update,
   input [0:17]                                              rv_xu0_ex0_gshare,
   input                                                    rv_xu0_ex0_s1_v,
   input                                                    rv_xu0_ex0_s2_v,
   input [0:2]                                              rv_xu0_ex0_s2_t,
   input                                                    rv_xu0_ex0_s3_v,
   input [0:2]                                              rv_xu0_ex0_s3_t,
   input                                                    rv_xu0_ex0_t1_v,
   input [0:`GPR_POOL_ENC-1]                                rv_xu0_ex0_t1_p,
   input [0:2]                                              rv_xu0_ex0_t1_t,
   input                                                    rv_xu0_ex0_t2_v,
   input [0:`GPR_POOL_ENC-1]                                rv_xu0_ex0_t2_p,
   input [0:2]                                              rv_xu0_ex0_t2_t,
   input                                                    rv_xu0_ex0_t3_v,
   input [0:`GPR_POOL_ENC-1]                                rv_xu0_ex0_t3_p,
   input [0:2]                                              rv_xu0_ex0_t3_t,
   input [0:`THREADS-1]                                     rv_xu0_ex0_spec_flush,
   input [0:`THREADS-1]                                     rv_xu0_ex1_spec_flush,
   input [0:`THREADS-1]                                     rv_xu0_ex2_spec_flush,
   input [1:11]                                             rv_xu0_s1_fxu0_sel,
   input [1:11]                                             rv_xu0_s2_fxu0_sel,
   input [2:11]                                             rv_xu0_s3_fxu0_sel,
   input [1:6]                                              rv_xu0_s1_fxu1_sel,
   input [1:6]                                              rv_xu0_s2_fxu1_sel,
   input [2:6]                                              rv_xu0_s3_fxu1_sel,
   input [4:8]                                              rv_xu0_s1_lq_sel,
   input [4:8]                                              rv_xu0_s2_lq_sel,
   input [4:8]                                              rv_xu0_s3_lq_sel,
   input [2:3]                                              rv_xu0_s1_rel_sel,
   input [2:3]                                              rv_xu0_s2_rel_sel,

   output                                                   xu0_rv_ord_complete,
   output [0:`ITAG_SIZE_ENC-1]                              xu0_rv_ord_itag,
   output                                                   xu0_rv_hold_all,

   //-------------------------------------------------------------------
   // External Bypass Inputs
   //-------------------------------------------------------------------
   input                                                   lq_xu_ex5_act,
   input                                                   lq_xu_ex5_abort,
   input [(128-`STQ_DATA_SIZE):127]                        lq_xu_ex5_rt,
   input [64-`GPR_WIDTH:63]                                lq_xu_ex5_data,
   input [64-`GPR_WIDTH:63]                                iu_xu_ex5_data,
   input [0:3]                                             lq_xu_ex5_cr,

   //-------------------------------------------------------------------
   // MMU/ERATs
   //-------------------------------------------------------------------
   output                                                  xu_iu_ord_ready,
   output                                                  xu_iu_act,
   output [0:`THREADS-1]                                   xu_iu_val,
   output                                                  xu_iu_is_eratre,
   output                                                  xu_iu_is_eratwe,
   output                                                  xu_iu_is_eratsx,
   output                                                  xu_iu_is_eratilx,
   output                                                  xu_iu_is_erativax,
   output [0:1]                                            xu_iu_ws,
   output [0:2]                                            xu_iu_t,
   output [0:8]                                            xu_iu_rs_is,
   output [0:3]                                            xu_iu_ra_entry,
   output [64-`GPR_WIDTH:51]                               xu_iu_rb,
   output [64-`GPR_WIDTH:63]                               xu_iu_rs_data,
   input                                                   iu_xu_ord_read_done,
   input                                                   iu_xu_ord_write_done,
   input                                                   iu_xu_ord_n_flush_req,
   input                                                   iu_xu_ord_par_err,

   output                                                  xu_lq_ord_ready,
   output                                                  xu_lq_act,
   output [0:`THREADS-1]                                   xu_lq_val,
   output                                                  xu_lq_hold_req,
   output                                                  xu_lq_is_eratre,
   output                                                  xu_lq_is_eratwe,
   output                                                  xu_lq_is_eratsx,
   output                                                  xu_lq_is_eratilx,
   output [0:1]                                            xu_lq_ws,
   output [0:2]                                            xu_lq_t,
   output [0:8]                                            xu_lq_rs_is,
   output [0:4]                                            xu_lq_ra_entry,
   output [64-`GPR_WIDTH:51]                               xu_lq_rb,
   output [64-`GPR_WIDTH:63]                               xu_lq_rs_data,
   input                                                   lq_xu_ord_read_done,
   input                                                   lq_xu_ord_write_done,
   input                                                   lq_xu_ord_n_flush_req,
   input                                                   lq_xu_ord_par_err,

   output                                                  xu_mm_ord_ready,
   output                                                  xu_mm_act,
   output [0:`THREADS-1]                                   xu_mm_val,
   output [0:`ITAG_SIZE_ENC-1]                             xu_mm_itag,
   output                                                  xu_mm_is_tlbre,
   output                                                  xu_mm_is_tlbwe,
   output                                                  xu_mm_is_tlbsx,
   output                                                  xu_mm_is_tlbsxr,
   output                                                  xu_mm_is_tlbsrx,
   output                                                  xu_mm_is_tlbivax,
   output                                                  xu_mm_is_tlbilx,
   output [0:11]                                           xu_mm_ra_entry,
   output [64-`GPR_WIDTH:63]                               xu_mm_rb,
   input [0:`ITAG_SIZE_ENC-1]                              mm_xu_itag,
   input                                                   mm_xu_ord_n_flush_req,
   input                                                   mm_xu_ord_read_done,
   input                                                   mm_xu_ord_write_done,
   input                                                   mm_xu_tlb_miss,
   input                                                   mm_xu_lrat_miss,
   input                                                   mm_xu_tlb_inelig,
   input                                                   mm_xu_pt_fault,
   input                                                   mm_xu_hv_priv,
   input                                                   mm_xu_illeg_instr,
   input                                                   mm_xu_tlb_multihit,
   input                                                   mm_xu_tlb_par_err,
   input                                                   mm_xu_lru_par_err,
   input                                                   mm_xu_local_snoop_reject,
   input [0:1]                                             mm_xu_mmucr0_tlbsel_t0,
   `ifndef THREADS1
   input [0:1]                                             mm_xu_mmucr0_tlbsel_t1,
   `endif
   input                                                   mm_xu_tlbwe_binv,
   input                                                   mm_xu_cr0_eq,
   input                                                   mm_xu_cr0_eq_valid,

   //-------------------------------------------------------------------
   // External Bypass Outputs
   //-------------------------------------------------------------------
   output                                                  xu0_lq_ex3_act,
   output                                                  xu0_lq_ex3_abort,
   output [64-`GPR_WIDTH:63]                               xu0_lq_ex3_rt,
   output [64-`GPR_WIDTH:63]                               xu0_lq_ex4_rt,
   output                                                  xu0_lq_ex6_act,
   output [64-`GPR_WIDTH:63]                               xu0_lq_ex6_rt,

   //-------------------------------------------------------------------
   // XU0 Completion
   //-------------------------------------------------------------------
   output [0:`THREADS-1]                                   xu0_iu_execute_vld,
   output [0:`ITAG_SIZE_ENC-1]                             xu0_iu_itag,
   output [0:`THREADS-1]                                   xu0_iu_mtiar,
   output                                                  xu0_iu_exception_val,
   output [0:4]                                            xu0_iu_exception,
   output                                                  xu0_iu_n_flush,
   output                                                  xu0_iu_np1_flush,
   output                                                  xu0_iu_flush2ucode,
   output [0:3]                                            xu0_iu_perf_events,
   output [62-`EFF_IFAR_ARCH:61]                           xu0_iu_bta,
   output [0:`THREADS-1]                                   xu_iu_pri_val,
   output [0:2]                                            xu_iu_pri,
   output [0:`THREADS-1]                                   xu_iu_ucode_xer_val,
   output [3:9]                                            xu_iu_ucode_xer,

   output                                                  xu1_rv_ex2_s1_abort,
   output                                                  xu1_rv_ex2_s2_abort,
   output                                                  xu1_rv_ex2_s3_abort,
   //-------------------------------------------------------------------
   // Slow SPRs
   //-------------------------------------------------------------------
   input                                                   xu_slowspr_val_in,
   input                                                   xu_slowspr_rw_in,
   input [64-`GPR_WIDTH:63]                                xu_slowspr_data_in,
   input                                                   xu_slowspr_done_in,

   //-------------------------------------------------------------------
   // RV->XU1 Issue
   //-------------------------------------------------------------------
   input [0:`THREADS-1]                                     rv_xu1_vld,
   input                                                    rv_xu1_s1_v,
   input [0:`GPR_POOL_ENC-1]                                rv_xu1_s1_p,
   input                                                    rv_xu1_s2_v,
   input [0:`GPR_POOL_ENC-1]                                rv_xu1_s2_p,
   input                                                    rv_xu1_s3_v,
   input [0:`GPR_POOL_ENC-1]                                rv_xu1_s3_p,
   input [0:31]                                             rv_xu1_ex0_instr,
   input [0:`ITAG_SIZE_ENC-1]                               rv_xu1_ex0_itag,
   input                                                    rv_xu1_ex0_isstore,
   input [1:1]                                              rv_xu1_ex0_ucode,
   input                                                    rv_xu1_ex0_t1_v,
   input [0:`GPR_POOL_ENC-1]                                rv_xu1_ex0_t1_p,
   input                                                    rv_xu1_ex0_t2_v,
   input [0:`GPR_POOL_ENC-1]                                rv_xu1_ex0_t2_p,
   input                                                    rv_xu1_ex0_t3_v,
   input [0:`GPR_POOL_ENC-1]                                rv_xu1_ex0_t3_p,
   input                                                    rv_xu1_ex0_s1_v,
   input [0:2]                                              rv_xu1_ex0_s3_t,
   input [0:`THREADS-1]                                     rv_xu1_ex0_spec_flush,
   input [0:`THREADS-1]                                     rv_xu1_ex1_spec_flush,
   input [0:`THREADS-1]                                     rv_xu1_ex2_spec_flush,
   input [1:11]                                             rv_xu1_s1_fxu0_sel,
   input [1:11]                                             rv_xu1_s2_fxu0_sel,
   input [2:11]                                             rv_xu1_s3_fxu0_sel,
   input [1:6]                                              rv_xu1_s1_fxu1_sel,
   input [1:6]                                              rv_xu1_s2_fxu1_sel,
   input [2:6]                                              rv_xu1_s3_fxu1_sel,
   input [4:8]                                              rv_xu1_s1_lq_sel,
   input [4:8]                                              rv_xu1_s2_lq_sel,
   input [4:8]                                              rv_xu1_s3_lq_sel,
   input [2:3]                                              rv_xu1_s1_rel_sel,
   input [2:3]                                              rv_xu1_s2_rel_sel,

   //-------------------------------------------------------------------
   // Store Interface
   //-------------------------------------------------------------------
   output [0:`THREADS-1]                                    xu1_lq_ex2_stq_val,
   output [0:`ITAG_SIZE_ENC-1]                              xu1_lq_ex2_stq_itag,
   output [1:4]                                             xu1_lq_ex2_stq_size,
   output                                                   xu1_lq_ex3_illeg_lswx,
   output                                                   xu1_lq_ex3_strg_noop,
   output [(64-`GPR_WIDTH)/8:7]                             xu1_lq_ex2_stq_dvc1_cmp,
   output [(64-`GPR_WIDTH)/8:7]                             xu1_lq_ex2_stq_dvc2_cmp,

   //-------------------------------------------------------------------
   // XU1 Completion
   //-------------------------------------------------------------------
   output [0:`THREADS-1]                                    xu1_iu_execute_vld,
   output [0:`ITAG_SIZE_ENC-1]                              xu1_iu_itag,

   output                                                   xu0_rv_ex2_s1_abort,
   output                                                   xu0_rv_ex2_s2_abort,
   output                                                   xu0_rv_ex2_s3_abort,
   //-------------------------------------------------------------------
   // External Bypass Outputs
   //-------------------------------------------------------------------
   output                                                   xu1_lq_ex3_act,
   output                                                   xu1_lq_ex3_abort,
   output [64-`GPR_WIDTH:63]                                xu1_lq_ex3_rt,

   //-------------------------------------------------------------------
   // Unit Write Ports
   //-------------------------------------------------------------------
   output                                                   xu0_gpr_ex6_we,
   output [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]             xu0_gpr_ex6_wa,
   output [64-`GPR_WIDTH:63+`GPR_WIDTH/8]                   xu0_gpr_ex6_wd,
   output                                                   xu1_gpr_ex3_we,
   output [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]             xu1_gpr_ex3_wa,
   output [64-`GPR_WIDTH:63+`GPR_WIDTH/8]                   xu1_gpr_ex3_wd,

   input                                                       lq_xu_gpr_ex5_we,
   input [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  lq_xu_gpr_ex5_wa,
   input                                                       lq_xu_gpr_rel_we,
   input [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  lq_xu_gpr_rel_wa,
   input [(128-`STQ_DATA_SIZE):127+`STQ_DATA_SIZE/8]       lq_xu_gpr_rel_wd,

   input                                                   lq_xu_cr_ex5_we,
   input [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]              lq_xu_cr_ex5_wa,
   input                                                   lq_xu_cr_l2_we,
   input [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]              lq_xu_cr_l2_wa,
   input [0:3]                                             lq_xu_cr_l2_wd,
   input                                                   axu_xu_cr_w0e,
   input [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]              axu_xu_cr_w0a,
   input [0:3]                                             axu_xu_cr_w0d,

   input [0:`XER_POOL_ENC-1]                               iu_rf_xer_p_t0,
   `ifndef THREADS1
   input [0:`XER_POOL_ENC-1]                               iu_rf_xer_p_t1,
   `endif
   output [0:`THREADS-1]                                   xer_lq_cp_rd,

   //-------------------------------------------------------------------
   // AXU Pass Thru Interface
   //-------------------------------------------------------------------
   input [59:63]                                           lq_xu_axu_ex4_addr,
   input                                                   lq_xu_axu_ex5_we,
   input                                                   lq_xu_axu_ex5_le,
   output [59:63]                                          xu_axu_lq_ex4_addr,
   output                                                  xu_axu_lq_ex5_we,
   output                                                  xu_axu_lq_ex5_le,
   output [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1] xu_axu_lq_ex5_wa,
   output [(128-`STQ_DATA_SIZE):127]                       xu_axu_lq_ex5_wd,
   output                                                  xu_axu_lq_ex5_abort,

   input                                                   lq_xu_axu_rel_we,
   input                                                   lq_xu_axu_rel_le,
   output                                                  xu_axu_lq_rel_we,
   output                                                  xu_axu_lq_rel_le,
   output [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1] xu_axu_lq_rel_wa,
   output [(128-`STQ_DATA_SIZE):128+((`STQ_DATA_SIZE-1)/8)]  xu_axu_lq_rel_wd,

   input [0:`THREADS-1]                                    axu_xu_lq_ex_stq_val,
   input [0:`ITAG_SIZE_ENC-1]                              axu_xu_lq_ex_stq_itag,
   input [128-`STQ_DATA_SIZE:127]                          axu_xu_lq_exp1_stq_data,
   output [0:`THREADS-1]                                   xu_lq_axu_ex_stq_val,
   output [0:`ITAG_SIZE_ENC-1]                             xu_lq_axu_ex_stq_itag,
   output [128-`STQ_DATA_SIZE:127]                         xu_lq_axu_exp1_stq_data,

   // Interrupt Interface
   input [0:`THREADS-1]                                    iu_xu_rfi,
   input [0:`THREADS-1]                                    iu_xu_rfgi,
   input [0:`THREADS-1]                                    iu_xu_rfci,
   input [0:`THREADS-1]                                    iu_xu_rfmci,
   input [0:`THREADS-1]                                    iu_xu_act,
   input [0:`THREADS-1]                                    iu_xu_int,
   input [0:`THREADS-1]                                    iu_xu_gint,
   input [0:`THREADS-1]                                    iu_xu_cint,
   input [0:`THREADS-1]                                    iu_xu_mcint,
   input [0:`THREADS-1]                                    iu_xu_dear_update,
   input [0:`THREADS-1]                                    iu_xu_dbsr_update,
   input [0:`THREADS-1]                                    iu_xu_esr_update,
   input [0:`THREADS-1]                                    iu_xu_force_gsrr,
   input [0:`THREADS-1]                                    iu_xu_dbsr_ude,
   input [0:`THREADS-1]                                    iu_xu_dbsr_ide,
   output [0:`THREADS-1]                                   xu_iu_dbsr_ide,

   input  [62-`EFF_IFAR_ARCH:61]                           iu_xu_nia_t0,
   input  [0:16]                                           iu_xu_esr_t0,
   input  [0:14]                                           iu_xu_mcsr_t0,
   input  [0:18]                                           iu_xu_dbsr_t0,
   input  [64-`GPR_WIDTH:63]                               iu_xu_dear_t0,
   output [62-`EFF_IFAR_ARCH:61]                           xu_iu_rest_ifar_t0,

   `ifndef THREADS1
   input  [62-`EFF_IFAR_ARCH:61]                           iu_xu_nia_t1,
   input  [0:16]                                           iu_xu_esr_t1,
   input  [0:14]                                           iu_xu_mcsr_t1,
   input  [0:18]                                           iu_xu_dbsr_t1,
   input  [64-`GPR_WIDTH:63]                               iu_xu_dear_t1,
   output [62-`EFF_IFAR_ARCH:61]                           xu_iu_rest_ifar_t1,
   `endif

   // Async Interrupt Request Interface
   output [0:`THREADS-1]                                   xu_iu_external_mchk,
   output [0:`THREADS-1]                                   xu_iu_ext_interrupt,
   output [0:`THREADS-1]                                   xu_iu_dec_interrupt,
   output [0:`THREADS-1]                                   xu_iu_udec_interrupt,
   output [0:`THREADS-1]                                   xu_iu_perf_interrupt,
   output [0:`THREADS-1]                                   xu_iu_fit_interrupt,
   output [0:`THREADS-1]                                   xu_iu_crit_interrupt,
   output [0:`THREADS-1]                                   xu_iu_wdog_interrupt,
   output [0:`THREADS-1]                                   xu_iu_gwdog_interrupt,
   output [0:`THREADS-1]                                   xu_iu_gfit_interrupt,
   output [0:`THREADS-1]                                   xu_iu_gdec_interrupt,
   output [0:`THREADS-1]                                   xu_iu_dbell_interrupt,
   output [0:`THREADS-1]                                   xu_iu_cdbell_interrupt,
   output [0:`THREADS-1]                                   xu_iu_gdbell_interrupt,
   output [0:`THREADS-1]                                   xu_iu_gcdbell_interrupt,
   output [0:`THREADS-1]                                   xu_iu_gmcdbell_interrupt,
   input [0:`THREADS-1]                                    iu_xu_dbell_taken,
   input [0:`THREADS-1]                                    iu_xu_cdbell_taken,
   input [0:`THREADS-1]                                    iu_xu_gdbell_taken,
   input [0:`THREADS-1]                                    iu_xu_gcdbell_taken,
   input [0:`THREADS-1]                                    iu_xu_gmcdbell_taken,

   // Doorbell Interrupts
   input                                                   lq_xu_dbell_val,
   input [0:4]                                             lq_xu_dbell_type,
   input                                                   lq_xu_dbell_brdcast,
   input                                                   lq_xu_dbell_lpid_match,
   input [50:63]                                           lq_xu_dbell_pirtag,

   // Slow SPR Out
   output                                                  xu_slowspr_val_out,
   output                                                  xu_slowspr_rw_out,
   output [0:1]                                            xu_slowspr_etid_out,
   output [11:20]                                          xu_slowspr_addr_out,
   output [64-`GPR_WIDTH:63]                               xu_slowspr_data_out,

   // Trap
   output [0:`THREADS-1]                                   xu_iu_fp_precise,
   // Run State
   input                                                   pc_xu_pm_hold_thread,
   input [0:`THREADS-1]                                    iu_xu_stop,
   output [0:`THREADS-1]                                   xu_pc_running,
   output [0:`THREADS-1]                                   xu_iu_run_thread,
   output [0:`THREADS-1]                                   xu_iu_single_instr_mode,
   output [0:`THREADS-1]                                   xu_iu_raise_iss_pri,
   output [0:`THREADS-1]                                   xu_iu_np1_async_flush,
   input [0:`THREADS-1]                                    iu_xu_async_complete,
   input                                                   iu_xu_credits_returned,
   output [0:`THREADS-1]                                   xu_pc_spr_ccr0_we,
   output [0:`THREADS-1]                                   xu_pc_stop_dnh_instr,
   input [0:`THREADS-1]                                    iu_xu_quiesce,
   input [0:`THREADS-1] 						                 iu_xu_icache_quiesce,
   input [0:`THREADS-1]                                    lq_xu_quiesce,
   input [0:`THREADS-1]                                    mm_xu_quiesce,
   input [0:`THREADS-1]                                    bx_xu_quiesce,

   // PCCR0 Controls
   input                                                   pc_xu_extirpts_dis_on_stop,
   input                                                   pc_xu_timebase_dis_on_stop,
   input                                                   pc_xu_decrem_dis_on_stop,

   // MSR Override
   input [0:`THREADS-1]                                    pc_xu_ram_active,
   output [0:`THREADS-1]                                   xu_iu_msrovride_enab,
   input                                                   pc_xu_msrovride_enab,
   input                                                   pc_xu_msrovride_pr,
   input                                                   pc_xu_msrovride_gs,
   input                                                   pc_xu_msrovride_de,
   // SIAR
   input  [0:`THREADS-1]                                   pc_xu_spr_cesr1_pmae,
   output [0:`THREADS-1]                                   xu_pc_perfmon_alert,

   // LiveLock
   input [0:`THREADS-1]                                    iu_xu_instr_cpl,
   output [0:`THREADS-1]                                   xu_pc_err_llbust_attempt,
   output [0:`THREADS-1]                                   xu_pc_err_llbust_failed,

   // Resets
   input                                                   pc_xu_reset_wd_complete,
   input                                                   pc_xu_reset_1_complete,
   input                                                   pc_xu_reset_2_complete,
   input                                                   pc_xu_reset_3_complete,
   output                                                  ac_tc_reset_1_request,
   output                                                  ac_tc_reset_2_request,
   output                                                  ac_tc_reset_3_request,
   output                                                  ac_tc_reset_wd_request,

   // Err Inject
   input [0:`THREADS-1]                                    pc_xu_inj_llbust_attempt,
   input [0:`THREADS-1]                                    pc_xu_inj_llbust_failed,
   input [0:`THREADS-1]                                    pc_xu_inj_wdt_reset,
   output [0:`THREADS-1]                                   xu_pc_err_wdt_reset,

   // Parity Errors
   input [0:`THREADS-1]                                    pc_xu_inj_sprg_ecc,
   output [0:`THREADS-1]                                   xu_pc_err_sprg_ecc,
   output [0:`THREADS-1]                                   xu_pc_err_sprg_ue,

   // PERF
   input [0:2]                                              pc_xu_event_count_mode,
   input                                                    pc_xu_event_bus_enable,
   input  [0:4*`THREADS-1]                                  xu_event_bus_in,
   output [0:4*`THREADS-1]                                  xu_event_bus_out,

   // Debug
   input  [0:10] 							                        pc_xu_debug_mux_ctrls,
   input  [0:31] 							                        xu_debug_bus_in,
   output [0:31] 							                        xu_debug_bus_out,
   input  [0:3] 							                        xu_coretrace_ctrls_in,
   output [0:3] 							                        xu_coretrace_ctrls_out,

   // SPRs
   input [54:61]                                           an_ac_coreid,
   input [32:35]                                           an_ac_chipid_dc,
   input [8:15]                                            spr_pvr_version_dc,
   input [12:15]                                           spr_pvr_revision_dc,
   input [16:19]                                           spr_pvr_revision_minor_dc,
   input [0:`THREADS-1]                                    an_ac_ext_interrupt,
   input [0:`THREADS-1]                                    an_ac_crit_interrupt,
   input [0:`THREADS-1]                                    an_ac_perf_interrupt,
   input [0:`THREADS-1]                                    an_ac_reservation_vld,
   input                                                   an_ac_tb_update_pulse,
   input                                                   an_ac_tb_update_enable,
   input [0:`THREADS-1]                                    an_ac_sleep_en,
   input [0:`THREADS-1]                                    an_ac_hang_pulse,
   output [0:`THREADS-1]                                   ac_tc_machine_check,
   input [0:`THREADS-1]                                    an_ac_external_mchk,
   input                                                   pc_xu_instr_trace_mode,
   input [0:1]                                             pc_xu_instr_trace_tid,
   input [0:`THREADS-1]                                    spr_dbcr0_edm,
   output [0:3]                                            spr_xucr0_clkg_ctl,
   output [0:`THREADS-1]                                   xu_iu_iac1_en,
   output [0:`THREADS-1]                                   xu_iu_iac2_en,
   output [0:`THREADS-1]                                   xu_iu_iac3_en,
   output [0:`THREADS-1]                                   xu_iu_iac4_en,
   input                                                   lq_xu_spr_xucr0_cslc_xuop,
   input                                                   lq_xu_spr_xucr0_cslc_binv,
   input                                                   lq_xu_spr_xucr0_clo,
   input                                                   lq_xu_spr_xucr0_cul,
   output [0:`THREADS-1]                                   spr_epcr_extgs,
   output [0:`THREADS-1]                                   spr_epcr_icm,
   output [0:`THREADS-1]                                   spr_epcr_gicm,
   output [0:`THREADS-1]                                   spr_msr_de,
   output [0:`THREADS-1]                                   spr_msr_pr,
   output [0:`THREADS-1]                                   spr_msr_is,
   output [0:`THREADS-1]                                   spr_msr_cm,
   output [0:`THREADS-1]                                   spr_msr_gs,
   output [0:`THREADS-1]                                   spr_msr_ee,
   output [0:`THREADS-1]                                   spr_msr_ce,
   output [0:`THREADS-1]                                   spr_msr_me,
   output [0:`THREADS-1]                                   spr_msr_fe0,
   output [0:`THREADS-1]                                   spr_msr_fe1,
   output                                                  xu_lsu_spr_xucr0_clfc,
   output [0:1]                                            xu_pc_spr_ccr0_pme,
   output                                                  spr_ccr2_en_dcr,
   output                                                  spr_ccr2_en_trace,
   output [0:8]                                            spr_ccr2_ifratsc,
   output                                                  spr_ccr2_ifrat,
   output [0:8]                                            spr_ccr2_dfratsc,
   output                                                  spr_ccr2_dfrat,
   output                                                  spr_ccr2_ucode_dis,
   output [0:3]                                            spr_ccr2_ap,
   output                                                  spr_ccr2_en_ditc,
   output                                                  spr_ccr2_en_icswx,
   output                                                  spr_ccr2_notlb,
   output                                                  spr_ccr2_en_pc,
   output [0:3]                                            spr_xucr0_trace_um,
   output                                                  xu_lsu_spr_xucr0_mbar_ack,
   output                                                  xu_lsu_spr_xucr0_tlbsync,
   output                                                  spr_xucr0_cls,
   output                                                  xu_lsu_spr_xucr0_aflsta,
   output                                                  spr_xucr0_mddp,
   output                                                  xu_lsu_spr_xucr0_cred,
   output                                                  xu_lsu_spr_xucr0_rel,
   output                                                  spr_xucr0_mdcp,
   output                                                  xu_lsu_spr_xucr0_flsta,
   output                                                  xu_lsu_spr_xucr0_l2siw,
   output                                                  xu_lsu_spr_xucr0_flh2l2,
   output                                                  xu_lsu_spr_xucr0_dcdis,
   output                                                  xu_lsu_spr_xucr0_wlk,
   output [0:`THREADS-1]                                   spr_dbcr0_idm,
   output [0:`THREADS-1]                                   spr_dbcr0_icmp,
   output [0:`THREADS-1]                                   spr_dbcr0_brt,
   output [0:`THREADS-1]                                   spr_dbcr0_irpt,
   output [0:`THREADS-1]                                   spr_dbcr0_trap,
   output [0:2*`THREADS-1]                                 spr_dbcr0_dac1,
   output [0:2*`THREADS-1]                                 spr_dbcr0_dac2,
   output [0:`THREADS-1]                                   spr_dbcr0_ret,
   output [0:2*`THREADS-1]                                 spr_dbcr0_dac3,
   output [0:2*`THREADS-1]                                 spr_dbcr0_dac4,
   output [0:`THREADS-1]                                   spr_dbcr1_iac12m,
   output [0:`THREADS-1]                                   spr_dbcr1_iac34m,
   output [0:`THREADS-1]                                   spr_epcr_dtlbgs,
   output [0:`THREADS-1]                                   spr_epcr_itlbgs,
   output [0:`THREADS-1]                                   spr_epcr_dsigs,
   output [0:`THREADS-1]                                   spr_epcr_isigs,
   output [0:`THREADS-1]                                   spr_epcr_duvd,
   output [0:`THREADS-1]                                   spr_epcr_dgtmi,
   output [0:`THREADS-1]                                   xu_mm_spr_epcr_dmiuh,
   output [0:`THREADS-1]                                   spr_msr_ucle,
   output [0:`THREADS-1]                                   spr_msr_spv,
   output [0:`THREADS-1]                                   spr_msr_fp,
   output [0:`THREADS-1]                                   spr_msr_ds,
   output [0:`THREADS-1]                                   spr_msrp_uclep,
   output                                                  spr_xucr4_mmu_mchk,
   output                                                  spr_xucr4_mddmh,

   input                                                   an_ac_scan_dis_dc_b,
   input                                                   an_ac_scan_diag_dc,

   // BOLT-ON
   input                                                   bo_enable_2,		// general bolt-on enable
   input                                                   pc_xu_bo_reset,		// reset
   input                                                   pc_xu_bo_unload,		// unload sticky bits
   input                                                   pc_xu_bo_repair,		// execute sticky bit decode
   input                                                   pc_xu_bo_shdata,		// shift data for timing write and diag loop
   input                                                   pc_xu_bo_select,		// select for mask and hier writes
   output                                                  xu_pc_bo_fail,		// fail/no-fix reg
   output                                                  xu_pc_bo_diagout,
   // ABIST
   input                                                   an_ac_lbist_ary_wrt_thru_dc,
   input                                                   pc_xu_abist_ena_dc,
   input                                                   pc_xu_abist_g8t_wenb,
   input [4:9]                                             pc_xu_abist_waddr_0,
   input [0:3]                                             pc_xu_abist_di_0,
   input                                                   pc_xu_abist_g8t1p_renb_0,
   input [4:9]                                             pc_xu_abist_raddr_0,
   input                                                   pc_xu_abist_wl32_comp_ena,
   input                                                   pc_xu_abist_raw_dc_b,
   input [0:3]                                             pc_xu_abist_g8t_dcomp,
   input                                                   pc_xu_abist_g8t_bw_1,
   input                                                   pc_xu_abist_g8t_bw_0,

   input                                                   pc_xu_trace_bus_enable
);

   //!! Bugspray Include: xu;

   // Power signals
   wire 			   vdd;
   wire 			   gnd;
   assign vdd = 1'b1;
   assign gnd = 1'b0;

   localparam                                              AXU_TARGET_ENC = `AXU_SPARE_ENC + `GPR_POOL_ENC + `THREADS_POOL_ENC;

   // Latches
	wire                          xu_pc_ram_done_q,          xu_pc_ram_done_d           ; //  input=>xu_pc_ram_done_d                ,act=>1'b1
	wire [64-`GPR_WIDTH:63]       xu_pc_ram_data_q,          xu_pc_ram_data_d           ; //  input=>xu_pc_ram_data_d                ,act=>xu_pc_ram_done_d
	wire                          lq_xu_gpr_ex6_we_q,        lq_xu_gpr_ex6_we_d         ; //  input=>lq_xu_gpr_ex6_we_d              ,act=>1'b1
	wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1] lq_xu_gpr_ex6_wa_q,   lq_xu_gpr_ex6_wa_d ; //  input=>lq_xu_gpr_ex6_wa_d              ,act=>lq_xu_ex5_act
	wire [64-`GPR_WIDTH:63]       lq_xu_gpr_ex6_wd_q,        lq_xu_gpr_ex6_wd_d         ; //  input=>lq_xu_gpr_ex6_wd_d              ,act=>lq_xu_ex5_act
	// Scanchain
   localparam xu_pc_ram_done_offset                      = 16+`THREADS;
	localparam xu_pc_ram_data_offset                      = xu_pc_ram_done_offset          + 1;
	localparam lq_xu_gpr_ex6_we_offset                    = xu_pc_ram_data_offset          + `GPR_WIDTH;
	localparam lq_xu_gpr_ex6_wa_offset                    = lq_xu_gpr_ex6_we_offset        + 1;
	localparam lq_xu_gpr_ex6_wd_offset                    = lq_xu_gpr_ex6_wa_offset        + `GPR_POOL_ENC+`THREADS_POOL_ENC;
   localparam scan_right                                 = lq_xu_gpr_ex6_wd_offset        + `GPR_WIDTH;
   wire [0:scan_right-1]                                    siv;
   wire [0:scan_right-1]                                    sov;
   // Signals
   wire [64-`GPR_WIDTH:63]                                  gpr_xu0_ex1_r1d;
   wire [64-`GPR_WIDTH:63]                                  gpr_xu0_ex1_r2d;
   wire [0:9]                                               xer_xu0_ex1_r2d;
   wire [0:9]                                               xer_xu0_ex1_r3d;
   wire [0:3]                                               cr_xu0_ex1_r1d;
   wire [0:3]                                               cr_xu0_ex1_r2d;
   wire [0:3]                                               cr_xu0_ex1_r3d;
   wire [64-`GPR_WIDTH:63]                                  lr_xu0_ex1_r1d;
   wire [64-`GPR_WIDTH:63]                                  lr_xu0_ex1_r2d;
   wire [64-`GPR_WIDTH:63]                                  ctr_xu0_ex1_r2d;
   wire                                                     xu0_xu1_ex3_act;
   wire                                                     xu1_xu0_ex3_act;
   wire [64-`GPR_WIDTH:63]                                  xu1_xu0_ex2_rt;
   wire [64-`GPR_WIDTH:63]                                  xu1_xu0_ex3_rt;
   wire [64-`GPR_WIDTH:63]                                  xu1_xu0_ex4_rt;
   wire [64-`GPR_WIDTH:63]                                  xu1_xu0_ex5_rt;
   wire [64-`GPR_WIDTH:63]                                  xu0_xu1_ex2_rt;
   wire [64-`GPR_WIDTH:63]                                  xu0_xu1_ex3_rt;
   wire [64-`GPR_WIDTH:63]                                  xu0_xu1_ex4_rt;
   wire [64-`GPR_WIDTH:63]                                  xu0_xu1_ex5_rt;
   wire [64-`GPR_WIDTH:63]                                  xu0_xu1_ex6_rt;
   wire [64-`GPR_WIDTH:63]                                  xu0_xu1_ex7_rt;
   wire [64-`GPR_WIDTH:63]                                  xu0_xu1_ex8_rt;
   wire [64-`GPR_WIDTH:63]                                  xu0_xu1_ex6_lq_rt;
   wire [64-`GPR_WIDTH:63]                                  xu0_xu1_ex7_lq_rt;
   wire [64-`GPR_WIDTH:63]                                  xu0_xu1_ex8_lq_rt;
   wire [64-`GPR_WIDTH:63]                                  spr_xu_ex4_rd_data;
   wire [64-`GPR_WIDTH:63]                                  xu_spr_ex2_rs1;
   wire [0:3]                                               xu1_xu0_ex3_cr;
   wire [0:9]                                               xu1_xu0_ex3_xer;
   wire [0:3]                                               xu0_xu1_ex3_cr;
   wire [0:3]                                               xu0_xu1_ex4_cr;
   wire [0:3]                                               xu0_xu1_ex6_cr;
   wire [0:9]                                               xu0_xu1_ex3_xer;
   wire [0:9]                                               xu0_xu1_ex4_xer;
   wire [0:9]                                               xu0_xu1_ex6_xer;
   wire                                                     xu0_gpr_ex6_we_int;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]               xu0_gpr_ex6_wa_int;
   wire [64-`GPR_WIDTH:65+`GPR_WIDTH/8]                     xu0_gpr_ex6_wd_int;
   wire                                                     xu0_xer_ex6_we;
   wire [0:`XER_POOL_ENC+`THREADS_POOL_ENC-1]               xu0_xer_ex6_wa;
   wire [0:9]                                               xu0_xer_ex6_w0d;
   wire                                                     xu0_cr_ex6_we;
   wire [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]                xu0_cr_ex6_wa;
   wire [0:3]                                               xu0_cr_ex6_w0d;
   wire                                                     xu0_ctr_ex4_we;
   wire [0:`CTR_POOL_ENC+`THREADS_POOL_ENC-1]               xu0_ctr_ex4_wa;
   wire [64-`GPR_WIDTH:63]                                  xu0_ctr_ex4_w0d;
   wire                                                     xu0_lr_ex4_we;
   wire [0:`BR_POOL_ENC+`THREADS_POOL_ENC-1]                xu0_lr_ex4_wa;
   wire [64-`GPR_WIDTH:63]                                  xu0_lr_ex4_w0d;
   wire                                                     spr_xu_ord_read_done;
   wire                                                     spr_xu_ord_write_done;
   wire                                                     spr_dec_ex4_spr_hypv;
   wire                                                     spr_dec_ex4_spr_illeg;
   wire                                                     spr_dec_ex4_spr_priv;
   wire                                                     spr_dec_ex4_np1_flush;
   wire [0:`THREADS-1]                                      spr_msr_cm_int;
   wire [0:`THREADS-1]                                      spr_msr_gs_int;
   wire [0:`THREADS-1]                                      spr_msr_pr_int;
   wire [0:`THREADS-1]                                      spr_epcr_dgtmi_int;
   wire                                                     spr_ccr2_notlb_int;
   wire [64-`GPR_WIDTH:63]                                  gpr_xu1_ex1_r1d;
   wire [64-`GPR_WIDTH:63]                                  gpr_xu1_ex1_r2d;
   wire [0:9]                                               xer_xu1_ex1_r3d;
   wire [0:3]                                               cr_xu1_ex1_r3d;
   wire                                                     xu1_gpr_ex3_we_int;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]               xu1_gpr_ex3_wa_int;
   wire [64-`GPR_WIDTH:65+`GPR_WIDTH/8]                     xu1_gpr_ex3_wd_int;
   wire                                                     xu1_xer_ex3_we;
   wire [0:`XER_POOL_ENC+`THREADS_POOL_ENC-1]               xu1_xer_ex3_wa;
   wire [0:9]                                               xu1_xer_ex3_w0d;
   wire                                                     xu1_cr_ex3_we;
   wire [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]                xu1_cr_ex3_wa;
   wire [0:3]                                               xu1_cr_ex3_w0d;
   wire                                                     spr_ccr2_en_attn;
   wire                                                     spr_ccr4_en_dnh;
   wire                                                     spr_ccr2_en_pc_int;
   wire                                                     func_sl_thold_0,func_slp_sl_thold_0;
   wire [0:10]                                              spr_debug_mux_ctrls;
   wire [0:31]                                              spr_debug_data_in;
   wire [0:31]                                              spr_debug_data_out;
   wire [0:11]                                              spr_trigger_data_in;
   wire [0:11]                                              spr_trigger_data_out;
   wire                                                     xu_spr_ord_ready;
   wire                                                     xu_spr_ord_flush;
   wire                                                     xu0_pc_ram_done;
   wire                                                     xu1_pc_ram_done;
   wire [64-`GPR_WIDTH:63]                                  xu0_pc_ram_data;
   wire [64-`GPR_WIDTH:63]                                  xu1_pc_ram_data;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]               rv_xu0_s1_p_int;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]               rv_xu0_s2_p_int;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]               rv_xu0_s3_p_int;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]               rv_xu1_s1_p_int;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]               rv_xu1_s2_p_int;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]               rv_xu1_s3_p_int;
   wire [0:`GPR_WIDTH/8-1]                                  lq_xu_gpr_ex6_par;
   wire [(64-`GPR_WIDTH):66+(`GPR_WIDTH/8-1)]               lq_xu_gpr_ex6_wd_int;
   wire [0:3]                                               lq_xu_cr_ex5_wd;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]               lq_xu_gpr_rel_wa_int;
   wire [(64-`GPR_WIDTH):66+(`GPR_WIDTH/8-1)]               lq_xu_gpr_rel_wd_int;
   wire [0:9]                                               xer_lq_cp_r0d;
   wire [0:9]                                               xer_lq_cp_r1d;
   wire [0:`XER_POOL_ENC+`THREADS_POOL_ENC-1]               iu_rf_xer_t0_p_int;
   wire [0:`XER_POOL_ENC+`THREADS_POOL_ENC-1]               iu_rf_xer_t1_p_int;
   wire                                                     rv_xu0_s3_gpr_v;
   `ifndef THREADS1
   wire [64-`GPR_WIDTH:63]                                  spr_dvc1_t1;
   wire [64-`GPR_WIDTH:63]                                  spr_dvc2_t1;
   `endif
   wire [64-`GPR_WIDTH:63]                                  spr_dvc1_t0;
   wire [64-`GPR_WIDTH:63]                                  spr_dvc2_t0;
   wire                                                     xu1_xu0_ex2_abort;
   wire                                                     xu0_xu1_ex2_abort;
   wire                                                     xu0_xu1_ex6_abort;
   wire [0:`THREADS-1]                                      div_spr_running;
   wire [0:`THREADS-1]                                      mul_spr_running;
   wire [0:31]                                              spr_xesr1;
   wire [0:31]                                              spr_xesr2;
   wire [0:`THREADS-1]                                      perf_event_en;

   wire [0:31]                                              xu0_debug_bus_in;
   wire [0:31]                                              xu0_debug_bus_out;
   wire [0:3]                                               xu0_coretrace_ctrls_in;
   wire [0:3]                                               xu0_coretrace_ctrls_out;
   wire [0:31]                                              xu1_debug_bus_in;
   wire [0:31]                                              xu1_debug_bus_out;
   wire [0:3]                                               xu1_coretrace_ctrls_in;
   wire [0:3]                                               xu1_coretrace_ctrls_out;


   wire                                                     tiup;

   //<<TEMP>>
   assign func_slp_sl_thold_0 = ~func_slp_sl_thold_0_b;
   assign func_sl_thold_0 = ~func_sl_thold_0_b;
   assign spr_debug_mux_ctrls = {11{1'b0}};
   assign spr_debug_data_in = {32{1'b0}};
   //<<TEMP>>

   assign tiup = 1'b1;

   `ifdef THREADS1
         assign iu_rf_xer_t0_p_int = iu_rf_xer_p_t0;
         assign iu_rf_xer_t1_p_int = {`XER_POOL_ENC+`THREADS_POOL_ENC{1'b0}};
         assign xer_lq_cp_rd = xer_lq_cp_r0d[0:0];
   `else
         assign iu_rf_xer_t0_p_int = {iu_rf_xer_p_t0, 1'b0};
         assign iu_rf_xer_t1_p_int = {iu_rf_xer_p_t1, 1'b1};
         assign xer_lq_cp_rd = {xer_lq_cp_r0d[0], xer_lq_cp_r1d[0]};
   `endif

   assign spr_msr_cm = spr_msr_cm_int;
   assign spr_msr_gs = spr_msr_gs_int;
   assign spr_msr_pr = spr_msr_pr_int;
   assign spr_epcr_dgtmi = spr_epcr_dgtmi_int;
   assign spr_ccr2_notlb = spr_ccr2_notlb_int;
   assign spr_ccr2_en_pc = spr_ccr2_en_pc_int;

   assign xu0_gpr_ex6_we = xu0_gpr_ex6_we_int;
   assign xu0_gpr_ex6_wa = xu0_gpr_ex6_wa_int;
   assign xu0_gpr_ex6_wd = xu0_gpr_ex6_wd_int[64 - `GPR_WIDTH:63 + `GPR_WIDTH/8];		// Fix me
   assign xu1_gpr_ex3_we = xu1_gpr_ex3_we_int;
   assign xu1_gpr_ex3_wa = xu1_gpr_ex3_wa_int;
   assign xu1_gpr_ex3_wd = xu1_gpr_ex3_wd_int[64 - `GPR_WIDTH:63 + `GPR_WIDTH/8];		// Fix me

   //-------------------------------------------------------------------
   // LQ Load Hit GPR Update
   //-------------------------------------------------------------------
   assign lq_xu_gpr_ex6_we_d = lq_xu_gpr_ex5_we;
   assign lq_xu_gpr_ex6_wa_d = lq_xu_gpr_ex5_wa[AXU_TARGET_ENC - (`GPR_POOL_ENC + `THREADS_POOL_ENC):AXU_TARGET_ENC - 1];
   assign lq_xu_gpr_ex6_wd_d = lq_xu_ex5_rt[128 - `GPR_WIDTH:127];

   generate begin : parGen
      genvar b;
      for (b=0;b<=`GPR_WIDTH/8-1;b=b+1)
      begin : parGen
         assign lq_xu_gpr_ex6_par[b] = ^(lq_xu_gpr_ex6_wd_q[(64 - `GPR_WIDTH) + b * 8:(64 - `GPR_WIDTH) + (b * 8) + 7]);
      end
   end
   endgenerate

   assign lq_xu_gpr_ex6_wd_int = {lq_xu_gpr_ex6_wd_q, lq_xu_gpr_ex6_par, 2'b10};

   //-------------------------------------------------------------------
   // LQ Reload GPR Update
   //-------------------------------------------------------------------
   // GPR Reload Write Address
   assign lq_xu_gpr_rel_wa_int                              = lq_xu_gpr_rel_wa[AXU_TARGET_ENC-(`GPR_POOL_ENC+`THREADS_POOL_ENC):AXU_TARGET_ENC-1];
   // GPR Reload Write Data
   assign lq_xu_gpr_rel_wd_int[(64-`GPR_WIDTH):63]          = lq_xu_gpr_rel_wd[(128-`GPR_WIDTH):127];
   // GPR Reload Write Data Parity
   assign lq_xu_gpr_rel_wd_int[64:63+`GPR_WIDTH/8]          = lq_xu_gpr_rel_wd[`STQ_DATA_SIZE+`STQ_DATA_SIZE/8-`GPR_WIDTH/8:`STQ_DATA_SIZE+`STQ_DATA_SIZE/8-1];
   assign lq_xu_gpr_rel_wd_int[65+(`GPR_WIDTH/8-1):66+(`GPR_WIDTH/8-1)] = 2'b11;

   // LQ CR Data
   assign lq_xu_cr_ex5_wd = lq_xu_ex5_cr;

   assign xu_pc_ram_done_d = xu0_pc_ram_done | xu1_pc_ram_done;
   assign xu_pc_ram_data_d = (xu0_pc_ram_done == 1'b1) ? xu0_pc_ram_data :
                             xu1_pc_ram_data;

   assign xu_pc_ram_done = xu_pc_ram_done_q;
   assign xu_pc_ram_data = xu_pc_ram_data_q;

   assign xu0_lq_ex3_act = xu0_xu1_ex3_act;
   assign xu1_lq_ex3_act = xu1_xu0_ex3_act;

   `ifdef THREADS1
   assign rv_xu0_s1_p_int = rv_xu0_s1_p;
   assign rv_xu0_s2_p_int = rv_xu0_s2_p;
   assign rv_xu0_s3_p_int = rv_xu0_s3_p;
   assign rv_xu1_s1_p_int = rv_xu1_s1_p;
   assign rv_xu1_s2_p_int = rv_xu1_s2_p;
   assign rv_xu1_s3_p_int = rv_xu1_s3_p;
   `else
   assign rv_xu0_s1_p_int ={rv_xu0_s1_p, rv_xu0_vld[1]};
   assign rv_xu0_s2_p_int ={rv_xu0_s2_p, rv_xu0_vld[1]};
   assign rv_xu0_s3_p_int ={rv_xu0_s3_p, rv_xu0_vld[1]};
   assign rv_xu1_s1_p_int ={rv_xu1_s1_p, rv_xu1_vld[1]};
   assign rv_xu1_s2_p_int ={rv_xu1_s2_p, rv_xu1_vld[1]};
   assign rv_xu1_s3_p_int ={rv_xu1_s3_p, rv_xu1_vld[1]};
   `endif

   assign rv_xu0_s3_gpr_v = |(rv_xu0_vld) & rv_xu0_s3_v;

   //-------------------------------------------------------------------
   // AXU Pass Thru Interface
   //-------------------------------------------------------------------
   assign xu_axu_lq_ex4_addr = lq_xu_axu_ex4_addr;
   assign xu_axu_lq_ex5_we = lq_xu_axu_ex5_we;
   assign xu_axu_lq_ex5_le = lq_xu_axu_ex5_le;
   assign xu_axu_lq_ex5_wa = lq_xu_gpr_ex5_wa;
   assign xu_axu_lq_ex5_wd = lq_xu_ex5_rt;
   assign xu_axu_lq_ex5_abort = lq_xu_ex5_abort;

   assign xu_axu_lq_rel_we = lq_xu_axu_rel_we;
   assign xu_axu_lq_rel_le = lq_xu_axu_rel_le;
   assign xu_axu_lq_rel_wa = lq_xu_gpr_rel_wa;
   assign xu_axu_lq_rel_wd = lq_xu_gpr_rel_wd;

   assign xu_lq_axu_ex_stq_val = axu_xu_lq_ex_stq_val;
   assign xu_lq_axu_ex_stq_itag = axu_xu_lq_ex_stq_itag;
   assign xu_lq_axu_exp1_stq_data = axu_xu_lq_exp1_stq_data;


   //-------------------------------------------------------------------
   // Debug Bus Wrap
   //-------------------------------------------------------------------
   assign xu0_debug_bus_in             = xu_debug_bus_in;
   assign xu0_coretrace_ctrls_in       = xu_coretrace_ctrls_in;

   assign xu1_debug_bus_in             = xu0_debug_bus_out;
   assign xu1_coretrace_ctrls_in       = xu0_coretrace_ctrls_out;

   assign xu_debug_bus_out             = xu1_debug_bus_out;
   assign xu_coretrace_ctrls_out       = xu1_coretrace_ctrls_out;


   xu0 xu0(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .pc_xu_ccflush_dc(pc_xu_ccflush_dc),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[0]),
      .scan_out(sov[0]),
      .xu0_pc_ram_done(xu0_pc_ram_done),
      .cp_flush(cp_flush),
      .iu_br_t0_flush_ifar(iu_br_t0_flush_ifar),
      .cp_next_itag_t0(cp_next_itag_t0),
      `ifndef THREADS1
      .iu_br_t1_flush_ifar(iu_br_t1_flush_ifar),
      .cp_next_itag_t1(cp_next_itag_t1),
      `endif
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
      .rv_xu0_vld(rv_xu0_vld),
      .rv_xu0_ex0_ord(rv_xu0_ex0_ord),
      .rv_xu0_ex0_fusion(rv_xu0_ex0_fusion),
      .rv_xu0_ex0_instr(rv_xu0_ex0_instr),
      .rv_xu0_ex0_ifar(rv_xu0_ex0_ifar),
      .rv_xu0_ex0_itag(rv_xu0_ex0_itag),
      .rv_xu0_ex0_ucode(rv_xu0_ex0_ucode),
      .rv_xu0_ex0_bta_val(rv_xu0_ex0_bta_val),
      .rv_xu0_ex0_pred_bta(rv_xu0_ex0_pred_bta),
      .rv_xu0_ex0_pred(rv_xu0_ex0_pred),
      .rv_xu0_ex0_ls_ptr(rv_xu0_ex0_ls_ptr),
      .rv_xu0_ex0_bh_update(rv_xu0_ex0_bh_update),
      .rv_xu0_ex0_gshare(rv_xu0_ex0_gshare),
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
      .xu0_rv_ord_complete(xu0_rv_ord_complete),
      .xu0_rv_ord_itag(xu0_rv_ord_itag),
      .xu0_rv_hold_all(xu0_rv_hold_all),
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
      .xu0_xu1_ex3_act(xu0_xu1_ex3_act),
      .xu1_xu0_ex3_act(xu1_xu0_ex3_act),
      .lq_xu_ex5_act(lq_xu_ex5_act),
      .xu1_xu0_ex2_abort(xu1_xu0_ex2_abort),
      .xu1_xu0_ex2_rt(xu1_xu0_ex2_rt),
      .xu1_xu0_ex3_rt(xu1_xu0_ex3_rt),
      .xu1_xu0_ex4_rt(xu1_xu0_ex4_rt),
      .xu1_xu0_ex5_rt(xu1_xu0_ex5_rt),
      .lq_xu_ex5_abort(lq_xu_ex5_abort),
      .lq_xu_ex5_rt(lq_xu_ex5_rt),
      .lq_xu_ex5_data(lq_xu_ex5_data),
      .lq_xu_rel_act(lq_xu_gpr_rel_we),
      .lq_xu_rel_rt(lq_xu_gpr_rel_wd_int[(64-`GPR_WIDTH):63]),
      .iu_xu_ex5_data(iu_xu_ex5_data),
      .spr_xu_ex4_rd_data(spr_xu_ex4_rd_data),
      .xu_spr_ex2_rs1(xu_spr_ex2_rs1),
      .lq_xu_ex5_cr(lq_xu_ex5_cr),
      .xu1_xu0_ex3_cr(xu1_xu0_ex3_cr),
      .xu1_xu0_ex3_xer(xu1_xu0_ex3_xer),
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
      .xu_iu_rs_is(xu_iu_rs_is),
      .xu_iu_ra_entry(xu_iu_ra_entry),
      .xu_iu_rb(xu_iu_rb),
      .xu_iu_rs_data(xu_iu_rs_data),
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
      .xu_lq_rs_is(xu_lq_rs_is),
      .xu_lq_ra_entry(xu_lq_ra_entry),
      .xu_lq_rb(xu_lq_rb),
      .xu_lq_rs_data(xu_lq_rs_data),
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
      .xu_mm_ra_entry(xu_mm_ra_entry),
      .xu_mm_rb(xu_mm_rb),
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
      .mm_xu_cr0_eq(mm_xu_cr0_eq),		// for record forms
      .mm_xu_cr0_eq_valid(mm_xu_cr0_eq_valid),		// for record forms
      .xu_spr_ord_ready(xu_spr_ord_ready),
      .xu_spr_ord_flush(xu_spr_ord_flush),
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
      .xu0_rv_ex2_s1_abort(xu0_rv_ex2_s1_abort),
      .xu0_rv_ex2_s2_abort(xu0_rv_ex2_s2_abort),
      .xu0_rv_ex2_s3_abort(xu0_rv_ex2_s3_abort),
      .xu0_gpr_ex6_we(xu0_gpr_ex6_we_int),
      .xu0_gpr_ex6_wa(xu0_gpr_ex6_wa_int),
      .xu0_gpr_ex6_wd(xu0_gpr_ex6_wd_int),
      .xu0_xer_ex6_we(xu0_xer_ex6_we),
      .xu0_xer_ex6_wa(xu0_xer_ex6_wa),
      .xu0_xer_ex6_w0d(xu0_xer_ex6_w0d),
      .xu0_cr_ex6_we(xu0_cr_ex6_we),
      .xu0_cr_ex6_wa(xu0_cr_ex6_wa),
      .xu0_cr_ex6_w0d(xu0_cr_ex6_w0d),
      .xu0_ctr_ex4_we(xu0_ctr_ex4_we),
      .xu0_ctr_ex4_wa(xu0_ctr_ex4_wa),
      .xu0_ctr_ex4_w0d(xu0_ctr_ex4_w0d),
      .xu0_lr_ex4_we(xu0_lr_ex4_we),
      .xu0_lr_ex4_wa(xu0_lr_ex4_wa),
      .xu0_lr_ex4_w0d(xu0_lr_ex4_w0d),
      .xu0_iu_execute_vld(xu0_iu_execute_vld),
      .xu0_iu_itag(xu0_iu_itag),
      .xu0_iu_mtiar(xu0_iu_mtiar),
      .xu0_iu_exception_val(xu0_iu_exception_val),
      .xu0_iu_exception(xu0_iu_exception),
      .xu0_iu_n_flush(xu0_iu_n_flush),
      .xu0_iu_np1_flush(xu0_iu_np1_flush),
      .xu0_iu_flush2ucode(xu0_iu_flush2ucode),
      .xu0_iu_perf_events(xu0_iu_perf_events),
      .xu0_iu_bta(xu0_iu_bta),
      .xu_iu_np1_async_flush(xu_iu_np1_async_flush),
      .iu_xu_async_complete(iu_xu_async_complete),
      .iu_xu_credits_returned(iu_xu_credits_returned),
      .xu_iu_pri_val(xu_iu_pri_val),
      .xu_iu_pri(xu_iu_pri),
      .spr_xu_ord_read_done(spr_xu_ord_read_done),
      .spr_xu_ord_write_done(spr_xu_ord_write_done),
      .spr_dec_ex4_spr_hypv(spr_dec_ex4_spr_hypv),
      .spr_dec_ex4_spr_illeg(spr_dec_ex4_spr_illeg),
      .spr_dec_ex4_spr_priv(spr_dec_ex4_spr_priv),
      .spr_dec_ex4_np1_flush(spr_dec_ex4_np1_flush),
      .xu_slowspr_val_in(xu_slowspr_val_in),
      .xu_slowspr_rw_in(xu_slowspr_rw_in),
      .xu_slowspr_data_in(xu_slowspr_data_in),
      .xu_slowspr_done_in(xu_slowspr_done_in),
      .spr_msr_cm(spr_msr_cm_int),
      .spr_msr_gs(spr_msr_gs_int),
      .spr_msr_pr(spr_msr_pr_int),
      .spr_epcr_dgtmi(spr_epcr_dgtmi_int),
      .spr_ccr2_notlb(spr_ccr2_notlb_int),
      .spr_ccr2_en_attn(spr_ccr2_en_attn),
      .spr_ccr4_en_dnh(spr_ccr4_en_dnh),
      .spr_ccr2_en_pc(spr_ccr2_en_pc_int),
      .spr_xesr1(spr_xesr1),
      .spr_xesr2(spr_xesr2),
      .perf_event_en(perf_event_en),
      .pc_xu_ram_active(pc_xu_ram_active),
      .div_spr_running(div_spr_running),
      .mul_spr_running(mul_spr_running),
      .pc_xu_debug_mux_ctrls(pc_xu_debug_mux_ctrls),
      .xu0_debug_bus_in(xu0_debug_bus_in),
      .xu0_debug_bus_out(xu0_debug_bus_out),
      .xu0_coretrace_ctrls_in(xu0_coretrace_ctrls_in),
      .xu0_coretrace_ctrls_out(xu0_coretrace_ctrls_out)
   );


   xu1 xu1(
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
      .scan_in(siv[1]),
      .scan_out(sov[1]),
      .xu1_pc_ram_done(xu1_pc_ram_done),
      .xu1_pc_ram_data(xu1_pc_ram_data),
      .xu0_xu1_ex3_act(xu0_xu1_ex3_act),
      .lq_xu_ex5_act(lq_xu_ex5_act),
      .spr_msr_cm(spr_msr_cm_int),		// 0=> 0,
      .cp_flush(cp_flush),
      .rv_xu1_vld(rv_xu1_vld),
      .rv_xu1_ex0_instr(rv_xu1_ex0_instr),
      .rv_xu1_ex0_itag(rv_xu1_ex0_itag),
      .rv_xu1_ex0_isstore(rv_xu1_ex0_isstore),
      .rv_xu1_ex0_ucode(rv_xu1_ex0_ucode),
      .rv_xu1_s1_v(rv_xu1_s1_v),
      .rv_xu1_s2_v(rv_xu1_s2_v),
      .rv_xu1_s3_v(rv_xu1_s3_v),
      .rv_xu1_ex0_t1_v(rv_xu1_ex0_t1_v),
      .rv_xu1_ex0_t1_p(rv_xu1_ex0_t1_p),
      .rv_xu1_ex0_t2_v(rv_xu1_ex0_t2_v),
      .rv_xu1_ex0_t2_p(rv_xu1_ex0_t2_p),
      .rv_xu1_ex0_t3_v(rv_xu1_ex0_t3_v),
      .rv_xu1_ex0_t3_p(rv_xu1_ex0_t3_p),
      .rv_xu1_ex0_s1_v(rv_xu1_ex0_s1_v),
      .rv_xu1_ex0_s3_t(rv_xu1_ex0_s3_t),
      .rv_xu1_ex0_spec_flush(rv_xu1_ex0_spec_flush),
      .rv_xu1_ex1_spec_flush(rv_xu1_ex1_spec_flush),
      .rv_xu1_ex2_spec_flush(rv_xu1_ex2_spec_flush),
      .rv_xu1_s1_fxu0_sel(rv_xu1_s1_fxu0_sel),
      .rv_xu1_s2_fxu0_sel(rv_xu1_s2_fxu0_sel),
      .rv_xu1_s3_fxu0_sel(rv_xu1_s3_fxu0_sel),
      .rv_xu1_s1_fxu1_sel(rv_xu1_s1_fxu1_sel),
      .rv_xu1_s2_fxu1_sel(rv_xu1_s2_fxu1_sel),
      .rv_xu1_s3_fxu1_sel(rv_xu1_s3_fxu1_sel),
      .rv_xu1_s1_lq_sel(rv_xu1_s1_lq_sel),
      .rv_xu1_s2_lq_sel(rv_xu1_s2_lq_sel),
      .rv_xu1_s3_lq_sel(rv_xu1_s3_lq_sel),
      .rv_xu1_s1_rel_sel(rv_xu1_s1_rel_sel),
      .rv_xu1_s2_rel_sel(rv_xu1_s2_rel_sel),
      .xu1_lq_ex2_stq_val(xu1_lq_ex2_stq_val),
      .xu1_lq_ex2_stq_itag(xu1_lq_ex2_stq_itag),
      .xu1_lq_ex2_stq_size(xu1_lq_ex2_stq_size),
      .xu1_lq_ex3_illeg_lswx(xu1_lq_ex3_illeg_lswx),
      .xu1_lq_ex3_strg_noop(xu1_lq_ex3_strg_noop),
      .xu1_lq_ex2_stq_dvc1_cmp(xu1_lq_ex2_stq_dvc1_cmp),
      .xu1_lq_ex2_stq_dvc2_cmp(xu1_lq_ex2_stq_dvc2_cmp),
      .xu1_iu_execute_vld(xu1_iu_execute_vld),
      .xu1_iu_itag(xu1_iu_itag),
      .xu_iu_ucode_xer_val(xu_iu_ucode_xer_val),
      .xu_iu_ucode_xer(xu_iu_ucode_xer),
      .xu1_rv_ex2_s1_abort(xu1_rv_ex2_s1_abort),
      .xu1_rv_ex2_s2_abort(xu1_rv_ex2_s2_abort),
      .xu1_rv_ex2_s3_abort(xu1_rv_ex2_s3_abort),
      .gpr_xu1_ex1_r1d(gpr_xu1_ex1_r1d),
      .gpr_xu1_ex1_r2d(gpr_xu1_ex1_r2d),
      .xer_xu1_ex1_r3d(xer_xu1_ex1_r3d),
      .cr_xu1_ex1_r3d(cr_xu1_ex1_r3d),
      .xu1_xu0_ex3_act(xu1_xu0_ex3_act),
      .xu0_xu1_ex2_abort(xu0_xu1_ex2_abort),
      .xu0_xu1_ex6_abort(xu0_xu1_ex6_abort),
      .lq_xu_ex5_abort(lq_xu_ex5_abort),
      .xu1_xu0_ex2_abort(xu1_xu0_ex2_abort),
      .xu1_lq_ex3_abort(xu1_lq_ex3_abort),
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
      .lq_xu_ex5_rt(lq_xu_ex5_rt),
      .lq_xu_rel_act(lq_xu_gpr_rel_we),
      .lq_xu_rel_rt(lq_xu_gpr_rel_wd_int[(64-`GPR_WIDTH):63]),
      .lq_xu_ex5_cr(lq_xu_ex5_cr),
      .xu0_xu1_ex3_cr(xu0_xu1_ex3_cr),
      .xu0_xu1_ex4_cr(xu0_xu1_ex4_cr),
      .xu0_xu1_ex6_cr(xu0_xu1_ex6_cr),
      .xu0_xu1_ex3_xer(xu0_xu1_ex3_xer),
      .xu0_xu1_ex4_xer(xu0_xu1_ex4_xer),
      .xu0_xu1_ex6_xer(xu0_xu1_ex6_xer),
      .xu1_xu0_ex2_rt(xu1_xu0_ex2_rt),
      .xu1_xu0_ex3_rt(xu1_xu0_ex3_rt),
      .xu1_xu0_ex4_rt(xu1_xu0_ex4_rt),
      .xu1_xu0_ex5_rt(xu1_xu0_ex5_rt),
      .xu1_lq_ex3_rt(xu1_lq_ex3_rt),
      .xu1_xu0_ex3_cr(xu1_xu0_ex3_cr),
      .xu1_xu0_ex3_xer(xu1_xu0_ex3_xer),
      .xu1_gpr_ex3_we(xu1_gpr_ex3_we_int),
      .xu1_gpr_ex3_wa(xu1_gpr_ex3_wa_int),
      .xu1_gpr_ex3_wd(xu1_gpr_ex3_wd_int),
      .xu1_xer_ex3_we(xu1_xer_ex3_we),
      .xu1_xer_ex3_wa(xu1_xer_ex3_wa),
      .xu1_xer_ex3_w0d(xu1_xer_ex3_w0d),
      .xu1_cr_ex3_we(xu1_cr_ex3_we),
      .xu1_cr_ex3_wa(xu1_cr_ex3_wa),
      .xu1_cr_ex3_w0d(xu1_cr_ex3_w0d),
      .pc_xu_ram_active(pc_xu_ram_active),
      `ifndef THREADS1
      .spr_dvc1_t1(spr_dvc1_t1),
      .spr_dvc2_t1(spr_dvc2_t1),
      `endif
      .spr_dvc1_t0(spr_dvc1_t0),
      .spr_dvc2_t0(spr_dvc2_t0),
      .pc_xu_debug_mux_ctrls(pc_xu_debug_mux_ctrls),
      .xu1_debug_bus_in(xu1_debug_bus_in),
      .xu1_debug_bus_out(xu1_debug_bus_out),
      .xu1_coretrace_ctrls_in(xu1_coretrace_ctrls_in),
      .xu1_coretrace_ctrls_out(xu1_coretrace_ctrls_out)
   );


   xu_rf #(.WIDTH(4), .PAR_WIDTH(1), .POOL_ENC(`CR_POOL_ENC + `THREADS_POOL_ENC), .POOL(`CR_POOL * `THREADS), .RD_PORTS(4), .WR_PORTS(5), .BYPASS(1)) cr(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .func_nsl_force(func_sl_force),
      .func_nsl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[2]),
      .scan_out(sov[2]),
      .r0e_e(rv_xu0_s1_v),
      .r0e(rv_xu0_s1_v),
      .r0a(rv_xu0_s1_p_int[`GPR_POOL_ENC-`CR_POOL_ENC:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]),
      .r0d(cr_xu0_ex1_r1d),
      .r1e_e(rv_xu0_s2_v),
      .r1e(rv_xu0_s2_v),
      .r1a(rv_xu0_s2_p_int[`GPR_POOL_ENC-`CR_POOL_ENC:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]),
      .r1d(cr_xu0_ex1_r2d),
      .r2e_e(rv_xu0_s3_v),
      .r2e(rv_xu0_s3_v),
      .r2a(rv_xu0_s3_p_int[`GPR_POOL_ENC-`CR_POOL_ENC:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]),
      .r2d(cr_xu0_ex1_r3d),
      .r3e_e(rv_xu1_s3_v),
      .r3e(rv_xu1_s3_v),
      .r3a(rv_xu1_s3_p_int[`GPR_POOL_ENC-`CR_POOL_ENC:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]),
      .r3d(cr_xu1_ex1_r3d),
      .w0e_e(xu0_cr_ex6_we),
      .w0e(xu0_cr_ex6_we),
      .w0a(xu0_cr_ex6_wa),
      .w0d(xu0_cr_ex6_w0d),
      .w1e_e(xu1_cr_ex3_we),
      .w1e(xu1_cr_ex3_we),
      .w1a(xu1_cr_ex3_wa),
      .w1d(xu1_cr_ex3_w0d),
      .w2e_e(lq_xu_cr_ex5_we),
      .w2e(lq_xu_cr_ex5_we),
      .w2a(lq_xu_cr_ex5_wa),
      .w2d(lq_xu_cr_ex5_wd),
      .w3e_e(lq_xu_cr_l2_we),
      .w3e(lq_xu_cr_l2_we),
      .w3a(lq_xu_cr_l2_wa),
      .w3d(lq_xu_cr_l2_wd),
      .w4e_e(axu_xu_cr_w0e),
      .w4e(axu_xu_cr_w0e),
      .w4a(axu_xu_cr_w0a),
      .w4d(axu_xu_cr_w0d)
   );


   xu_rf #(.WIDTH(10), .PAR_WIDTH(2),  .POOL_ENC(`XER_POOL_ENC + `THREADS_POOL_ENC), .POOL(`XER_POOL * `THREADS), .RD_PORTS(3 + `THREADS), .WR_PORTS(2), .BYPASS(1)) xer(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .func_nsl_force(func_sl_force),
      .func_nsl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[3]),
      .scan_out(sov[3]),
      .r0e_e(rv_xu0_s2_v),
      .r0e(rv_xu0_s2_v),
      .r0a(rv_xu0_s2_p_int[`GPR_POOL_ENC-`XER_POOL_ENC:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]),
      .r0d(xer_xu0_ex1_r2d),
      .r1e_e(rv_xu0_s3_v),
      .r1e(rv_xu0_s3_v),
      .r1a(rv_xu0_s3_p_int[`GPR_POOL_ENC-`XER_POOL_ENC:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]),
      .r1d(xer_xu0_ex1_r3d),
      .r2e_e(rv_xu1_s3_v),
      .r2e(rv_xu1_s3_v),
      .r2a(rv_xu1_s3_p_int[`GPR_POOL_ENC-`XER_POOL_ENC:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]),
      .r2d(xer_xu1_ex1_r3d),
      .r3e_e(tiup),
      .r3e(tiup),
      .r3a(iu_rf_xer_t0_p_int),
      .r3d(xer_lq_cp_r0d),
      .r4e_e(tiup),
      .r4e(tiup),
      .r4a(iu_rf_xer_t1_p_int),
      .r4d(xer_lq_cp_r1d),
      .w0e_e(xu0_xer_ex6_we),
      .w0e(xu0_xer_ex6_we),
      .w0a(xu0_xer_ex6_wa),
      .w0d(xu0_xer_ex6_w0d),
      .w1e_e(xu1_xer_ex3_we),
      .w1e(xu1_xer_ex3_we),
      .w1a(xu1_xer_ex3_wa),
      .w1d(xu1_xer_ex3_w0d),
      .w2e(1'b0),
      .w3e(1'b0),
      .w4e(1'b0)
   );


   xu_rf #(.WIDTH(`GPR_WIDTH), .PAR_WIDTH(`GPR_WIDTH/8),  .POOL_ENC(`BR_POOL_ENC + `THREADS_POOL_ENC), .POOL(`BR_POOL * `THREADS), .RD_PORTS(2), .WR_PORTS(1), .BYPASS(1)) lr(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .func_nsl_force(func_sl_force),
      .func_nsl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[4]),
      .scan_out(sov[4]),
      .r0e_e(rv_xu0_s1_v),
      .r0e(rv_xu0_s1_v),
      .r0a(rv_xu0_s1_p_int[`GPR_POOL_ENC-`BR_POOL_ENC:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]),
      .r0d(lr_xu0_ex1_r1d),
      .r1e_e(rv_xu0_s2_v),
      .r1e(rv_xu0_s2_v),
      .r1a(rv_xu0_s2_p_int[`GPR_POOL_ENC-`BR_POOL_ENC:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]),
      .r1d(lr_xu0_ex1_r2d),
      .w0e_e(xu0_lr_ex4_we),
      .w0e(xu0_lr_ex4_we),
      .w0a(xu0_lr_ex4_wa),
      .w0d(xu0_lr_ex4_w0d),
      .w1e(1'b0),
      .w2e(1'b0),
      .w3e(1'b0),
      .w4e(1'b0)
   );


   xu_rf #(.WIDTH(`GPR_WIDTH), .PAR_WIDTH(`GPR_WIDTH/8),   .POOL_ENC(`CTR_POOL_ENC + `THREADS_POOL_ENC), .POOL(`CTR_POOL * `THREADS), .RD_PORTS(1), .WR_PORTS(1), .BYPASS(1)) ctr(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .func_nsl_force(func_sl_force),
      .func_nsl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[5]),
      .scan_out(sov[5]),
      .r0e_e(rv_xu0_s2_v),
      .r0e(rv_xu0_s2_v),
      .r0a(rv_xu0_s2_p_int[`GPR_POOL_ENC-`CTR_POOL_ENC:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]),
      .r0d(ctr_xu0_ex1_r2d),
      .w0e_e(xu0_ctr_ex4_we),
      .w0e(xu0_ctr_ex4_we),
      .w0a(xu0_ctr_ex4_wa),
      .w0d(xu0_ctr_ex4_w0d),
      .w1e(1'b0),
      .w2e(1'b0),
      .w3e(1'b0),
      .w4e(1'b0)
   );


   xu_gpr gpr(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .pc_xu_ccflush_dc(pc_xu_ccflush_dc),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[6]),
      .scan_out(sov[6]),
      .r0e(rv_xu0_s1_v),
      .r0a(rv_xu0_s1_p_int),
      .r0d(gpr_xu0_ex1_r1d),
      .r1e(rv_xu0_s2_v),
      .r1a(rv_xu0_s2_p_int),
      .r1d(gpr_xu0_ex1_r2d),
      .r2e(rv_xu1_s1_v),
      .r2a(rv_xu1_s1_p_int),
      .r2d(gpr_xu1_ex1_r1d),
      .r3e(rv_xu1_s2_v),
      .r3a(rv_xu1_s2_p_int),
      .r3d(gpr_xu1_ex1_r2d),
      .r4e(rv_xu0_s3_gpr_v),
      .r4t_q(rv_xu0_ex0_s3_t),
      .r4a(rv_xu0_s3_p_int),
      .r0_pe(),
      .r1_pe(),
      .r2_pe(),
      .r3_pe(),
      .w0e(xu0_gpr_ex6_we_int),
      .w0a(xu0_gpr_ex6_wa_int),
      .w0d(xu0_gpr_ex6_wd_int),
      .w1e(xu1_gpr_ex3_we_int),
      .w1a(xu1_gpr_ex3_wa_int),
      .w1d(xu1_gpr_ex3_wd_int),
      .w2e(lq_xu_gpr_ex6_we_q),
      .w2a(lq_xu_gpr_ex6_wa_q),
      .w2d(lq_xu_gpr_ex6_wd_int),
      .w3e(lq_xu_gpr_rel_we),
      .w3a(lq_xu_gpr_rel_wa_int),
      .w3d(lq_xu_gpr_rel_wd_int)
   );


   xu_spr #(.hvmode(1), .a2mode(1)) spr(
      .nclk(nclk),

      // CHIP IO
      .an_ac_chipid_dc(an_ac_chipid_dc),
      .an_ac_coreid(an_ac_coreid),
      .spr_pvr_version_dc(spr_pvr_version_dc),
      .spr_pvr_revision_dc(spr_pvr_revision_dc),
      .spr_pvr_revision_minor_dc(spr_pvr_revision_minor_dc),
      .an_ac_ext_interrupt(an_ac_ext_interrupt),
      .an_ac_crit_interrupt(an_ac_crit_interrupt),
      .an_ac_perf_interrupt(an_ac_perf_interrupt),
      .an_ac_reservation_vld(an_ac_reservation_vld),
      .an_ac_tb_update_pulse(an_ac_tb_update_pulse),
      .an_ac_tb_update_enable(an_ac_tb_update_enable),
      .an_ac_sleep_en(an_ac_sleep_en),
      .an_ac_hang_pulse(an_ac_hang_pulse),
      .ac_tc_machine_check(ac_tc_machine_check),
      .an_ac_external_mchk(an_ac_external_mchk),
      .pc_xu_instr_trace_mode(pc_xu_instr_trace_mode),
      .pc_xu_instr_trace_tid(pc_xu_instr_trace_tid),

      .an_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
      .an_ac_scan_diag_dc(an_ac_scan_diag_dc),
      .pc_xu_ccflush_dc(pc_xu_ccflush_dc),
      .clkoff_dc_b(clkoff_dc_b),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_thold_2(func_sl_thold_0),
      .func_slp_sl_thold_2(func_slp_sl_thold_0),
      .func_nsl_thold_2(func_sl_thold_0),
      .func_slp_nsl_thold_2(func_slp_sl_thold_0),
      .cfg_sl_thold_2(func_sl_thold_0),
      .cfg_slp_sl_thold_2(func_slp_sl_thold_0),
      .ary_nsl_thold_2(func_sl_thold_0),
      .time_sl_thold_2(func_sl_thold_0),
      .abst_sl_thold_2(func_sl_thold_0),
      .repr_sl_thold_2(func_sl_thold_0),
      .gptr_sl_thold_2(func_sl_thold_0),
      .bolt_sl_thold_2(func_sl_thold_0),
      .sg_2(sg_0),
      .fce_2(fce_0),
      .func_scan_in(siv[7:8 + `THREADS]),
      .func_scan_out(sov[7:8 + `THREADS]),
      .bcfg_scan_in(siv[9 + `THREADS]),
      .bcfg_scan_out(sov[9 + `THREADS]),
      .ccfg_scan_in(siv[10 + `THREADS]),
      .ccfg_scan_out(sov[10 + `THREADS]),
      .dcfg_scan_in(siv[11 + `THREADS]),
      .dcfg_scan_out(sov[11 + `THREADS]),
      .time_scan_in(siv[12 + `THREADS]),
      .time_scan_out(sov[12 + `THREADS]),
      .abst_scan_in(siv[13 + `THREADS]),
      .abst_scan_out(sov[13 + `THREADS]),
      .repr_scan_in(siv[14 + `THREADS]),
      .repr_scan_out(sov[14 + `THREADS]),
      .gptr_scan_in(siv[15 + `THREADS]),
      .gptr_scan_out(sov[15 + `THREADS]),

      // Decode
      .rv_xu_vld(rv_xu0_vld),
      .rv_xu_ex0_ord(rv_xu0_ex0_ord),
      .rv_xu_ex0_instr(rv_xu0_ex0_instr),
      .rv_xu_ex0_ifar(rv_xu0_ex0_ifar),

      .spr_xu_ord_read_done(spr_xu_ord_read_done),
      .spr_xu_ord_write_done(spr_xu_ord_write_done),
      .xu_spr_ord_ready(xu_spr_ord_ready),
      .xu_spr_ord_flush(xu_spr_ord_flush),
      .cp_flush(cp_flush),

      // Read Data
      .spr_xu_ex4_rd_data(spr_xu_ex4_rd_data),

      // Write Data
      .xu_spr_ex2_rs1(xu_spr_ex2_rs1),

      // Interrupt Interface
      .iu_xu_rfi(iu_xu_rfi),
      .iu_xu_rfgi(iu_xu_rfgi),
      .iu_xu_rfci(iu_xu_rfci),
      .iu_xu_rfmci(iu_xu_rfmci),
      .iu_xu_act(iu_xu_act),
      .iu_xu_int(iu_xu_int),
      .iu_xu_gint(iu_xu_gint),
      .iu_xu_cint(iu_xu_cint),
      .iu_xu_mcint(iu_xu_mcint),
      .iu_xu_dear_update(iu_xu_dear_update),
      .iu_xu_dbsr_update(iu_xu_dbsr_update),
      .iu_xu_esr_update(iu_xu_esr_update),
      .iu_xu_force_gsrr(iu_xu_force_gsrr),
      .iu_xu_dbsr_ude(iu_xu_dbsr_ude),
      .iu_xu_dbsr_ide(iu_xu_dbsr_ide),
      .xu_iu_dbsr_ide(xu_iu_dbsr_ide),

      .iu_xu_nia_t0(iu_xu_nia_t0),
      .iu_xu_esr_t0(iu_xu_esr_t0),
      .iu_xu_mcsr_t0(iu_xu_mcsr_t0),
      .iu_xu_dbsr_t0(iu_xu_dbsr_t0),
      .iu_xu_dear_t0(iu_xu_dear_t0),
      .xu_iu_rest_ifar_t0(xu_iu_rest_ifar_t0),
      `ifndef THREADS1
      .iu_xu_nia_t1(iu_xu_nia_t1),
      .iu_xu_esr_t1(iu_xu_esr_t1),
      .iu_xu_mcsr_t1(iu_xu_mcsr_t1),
      .iu_xu_dbsr_t1(iu_xu_dbsr_t1),
      .iu_xu_dear_t1(iu_xu_dear_t1),
      .xu_iu_rest_ifar_t1(xu_iu_rest_ifar_t1),
      `endif

      // Async Interrupt Req Interface
      .xu_iu_external_mchk(xu_iu_external_mchk),
      .xu_iu_ext_interrupt(xu_iu_ext_interrupt),
      .xu_iu_dec_interrupt(xu_iu_dec_interrupt),
      .xu_iu_udec_interrupt(xu_iu_udec_interrupt),
      .xu_iu_perf_interrupt(xu_iu_perf_interrupt),
      .xu_iu_fit_interrupt(xu_iu_fit_interrupt),
      .xu_iu_crit_interrupt(xu_iu_crit_interrupt),
      .xu_iu_wdog_interrupt(xu_iu_wdog_interrupt),
      .xu_iu_gwdog_interrupt(xu_iu_gwdog_interrupt),
      .xu_iu_gfit_interrupt(xu_iu_gfit_interrupt),
      .xu_iu_gdec_interrupt(xu_iu_gdec_interrupt),
      .xu_iu_dbell_interrupt(xu_iu_dbell_interrupt),
      .xu_iu_cdbell_interrupt(xu_iu_cdbell_interrupt),
      .xu_iu_gdbell_interrupt(xu_iu_gdbell_interrupt),
      .xu_iu_gcdbell_interrupt(xu_iu_gcdbell_interrupt),
      .xu_iu_gmcdbell_interrupt(xu_iu_gmcdbell_interrupt),
      .iu_xu_dbell_taken(iu_xu_dbell_taken),
      .iu_xu_cdbell_taken(iu_xu_cdbell_taken),
      .iu_xu_gdbell_taken(iu_xu_gdbell_taken),
      .iu_xu_gcdbell_taken(iu_xu_gcdbell_taken),
      .iu_xu_gmcdbell_taken(iu_xu_gmcdbell_taken),

      // DBELL Int
      .lq_xu_dbell_val(lq_xu_dbell_val),
      .lq_xu_dbell_type(lq_xu_dbell_type),
      .lq_xu_dbell_brdcast(lq_xu_dbell_brdcast),
      .lq_xu_dbell_lpid_match(lq_xu_dbell_lpid_match),
      .lq_xu_dbell_pirtag(lq_xu_dbell_pirtag),

      // Slow SPR Bus
      .xu_slowspr_val_out(xu_slowspr_val_out),
      .xu_slowspr_rw_out(xu_slowspr_rw_out),
      .xu_slowspr_etid_out(xu_slowspr_etid_out),
      .xu_slowspr_addr_out(xu_slowspr_addr_out),
      .xu_slowspr_data_out(xu_slowspr_data_out),
      .ac_an_dcr_act(),
      .ac_an_dcr_val(),
      .ac_an_dcr_read(),
      .ac_an_dcr_user(),
      .ac_an_dcr_etid(),
      .ac_an_dcr_addr(),
      .ac_an_dcr_data(),

      // DCR Bus

      // Trap
      .xu_iu_fp_precise(xu_iu_fp_precise),
      .spr_dec_ex4_spr_hypv(spr_dec_ex4_spr_hypv),
      .spr_dec_ex4_spr_illeg(spr_dec_ex4_spr_illeg),
      .spr_dec_ex4_spr_priv(spr_dec_ex4_spr_priv),
      .spr_dec_ex4_np1_flush(spr_dec_ex4_np1_flush),

      // Run State
      .pc_xu_pm_hold_thread(pc_xu_pm_hold_thread),
      .iu_xu_stop(iu_xu_stop),
      .xu_pc_running(xu_pc_running),
      .xu_iu_run_thread(xu_iu_run_thread),
      .xu_iu_single_instr_mode(xu_iu_single_instr_mode),
      .xu_iu_raise_iss_pri(xu_iu_raise_iss_pri),
      .xu_pc_spr_ccr0_we(xu_pc_spr_ccr0_we),
      .xu_pc_stop_dnh_instr(xu_pc_stop_dnh_instr),

      // Quiesce
      .iu_xu_icache_quiesce(iu_xu_icache_quiesce),
      .iu_xu_quiesce(iu_xu_quiesce),
      .lq_xu_quiesce(lq_xu_quiesce),
      .mm_xu_quiesce(mm_xu_quiesce),
      .bx_xu_quiesce(bx_xu_quiesce),

      // PCCR0
      .pc_xu_extirpts_dis_on_stop(pc_xu_extirpts_dis_on_stop),
      .pc_xu_timebase_dis_on_stop(pc_xu_timebase_dis_on_stop),
      .pc_xu_decrem_dis_on_stop(pc_xu_decrem_dis_on_stop),

      // MSR Override
      .pc_xu_ram_active(pc_xu_ram_active),
      .xu_iu_msrovride_enab(xu_iu_msrovride_enab),
      .pc_xu_msrovride_enab(pc_xu_msrovride_enab),
      .pc_xu_msrovride_pr(pc_xu_msrovride_pr),
      .pc_xu_msrovride_gs(pc_xu_msrovride_gs),
      .pc_xu_msrovride_de(pc_xu_msrovride_de),
      // SIAR
      .pc_xu_spr_cesr1_pmae(pc_xu_spr_cesr1_pmae),
      .xu_pc_perfmon_alert(xu_pc_perfmon_alert),

      // LiveLock
      .iu_xu_instr_cpl(iu_xu_instr_cpl),
      .xu_pc_err_llbust_attempt(xu_pc_err_llbust_attempt),
      .xu_pc_err_llbust_failed(xu_pc_err_llbust_failed),

      // Resets
      .pc_xu_reset_wd_complete(pc_xu_reset_wd_complete),
      .pc_xu_reset_1_complete(pc_xu_reset_1_complete),
      .pc_xu_reset_2_complete(pc_xu_reset_2_complete),
      .pc_xu_reset_3_complete(pc_xu_reset_3_complete),
      .ac_tc_reset_1_request(ac_tc_reset_1_request),
      .ac_tc_reset_2_request(ac_tc_reset_2_request),
      .ac_tc_reset_3_request(ac_tc_reset_3_request),
      .ac_tc_reset_wd_request(ac_tc_reset_wd_request),

      // Err Inject
      .pc_xu_inj_llbust_attempt(pc_xu_inj_llbust_attempt),
      .pc_xu_inj_llbust_failed(pc_xu_inj_llbust_failed),
      .pc_xu_inj_wdt_reset(pc_xu_inj_wdt_reset),
      .xu_pc_err_wdt_reset(xu_pc_err_wdt_reset),

      // Parity
      .pc_xu_inj_sprg_ecc(pc_xu_inj_sprg_ecc),
      .xu_pc_err_sprg_ecc(xu_pc_err_sprg_ecc),
      .xu_pc_err_sprg_ue(xu_pc_err_sprg_ue),
      // Perf
      .pc_xu_event_count_mode(pc_xu_event_count_mode),
      .pc_xu_event_bus_enable(pc_xu_event_bus_enable),
      .xu_event_bus_in(xu_event_bus_in),
      .xu_event_bus_out(xu_event_bus_out),
      .div_spr_running(div_spr_running),
      .mul_spr_running(mul_spr_running),

      // SPRs
      .spr_xesr1(spr_xesr1),
      .spr_xesr2(spr_xesr2),
      .perf_event_en(perf_event_en),
      .spr_dbcr0_edm(spr_dbcr0_edm),
      .spr_xucr0_clkg_ctl(spr_xucr0_clkg_ctl),
      .xu_iu_iac1_en(xu_iu_iac1_en),
      .xu_iu_iac2_en(xu_iu_iac2_en),
      .xu_iu_iac3_en(xu_iu_iac3_en),
      .xu_iu_iac4_en(xu_iu_iac4_en),
      .lq_xu_spr_xucr0_cslc_xuop(lq_xu_spr_xucr0_cslc_xuop),
      .lq_xu_spr_xucr0_cslc_binv(lq_xu_spr_xucr0_cslc_binv),
      .lq_xu_spr_xucr0_clo(lq_xu_spr_xucr0_clo),
      .lq_xu_spr_xucr0_cul(lq_xu_spr_xucr0_cul),
      .spr_epcr_extgs(spr_epcr_extgs),
      .spr_epcr_icm(spr_epcr_icm),
      .spr_epcr_gicm(spr_epcr_gicm),
      .spr_msr_de(spr_msr_de),
      .spr_msr_pr(spr_msr_pr_int),
      .spr_msr_is(spr_msr_is),
      .spr_msr_cm(spr_msr_cm_int),
      .spr_msr_gs(spr_msr_gs_int),
      .spr_msr_ee(spr_msr_ee),
      .spr_msr_ce(spr_msr_ce),
      .spr_msr_me(spr_msr_me),
      .spr_msr_fe0(spr_msr_fe0),
      .spr_msr_fe1(spr_msr_fe1),
      .spr_ccr2_en_pc(spr_ccr2_en_pc_int),
      .xu_lsu_spr_xucr0_clfc(xu_lsu_spr_xucr0_clfc),
      .xu_pc_spr_ccr0_pme(xu_pc_spr_ccr0_pme),
      .spr_ccr2_en_dcr(spr_ccr2_en_dcr),
      .spr_ccr2_en_trace(spr_ccr2_en_trace),
      .spr_ccr2_ifratsc(spr_ccr2_ifratsc),
      .spr_ccr2_ifrat(spr_ccr2_ifrat),
      .spr_ccr2_dfratsc(spr_ccr2_dfratsc),
      .spr_ccr2_dfrat(spr_ccr2_dfrat),
      .spr_ccr2_ucode_dis(spr_ccr2_ucode_dis),
      .spr_ccr2_ap(spr_ccr2_ap),
      .spr_ccr2_en_attn(spr_ccr2_en_attn),
      .spr_ccr4_en_dnh(spr_ccr4_en_dnh),
      .spr_ccr2_en_ditc(spr_ccr2_en_ditc),
      .spr_ccr2_en_icswx(spr_ccr2_en_icswx),
      .spr_ccr2_notlb(spr_ccr2_notlb_int),
      .spr_xucr0_trace_um(spr_xucr0_trace_um),
      .xu_lsu_spr_xucr0_mbar_ack(xu_lsu_spr_xucr0_mbar_ack),
      .xu_lsu_spr_xucr0_tlbsync(xu_lsu_spr_xucr0_tlbsync),
      .spr_xucr0_cls(spr_xucr0_cls),
      .xu_lsu_spr_xucr0_aflsta(xu_lsu_spr_xucr0_aflsta),
      .spr_xucr0_mddp(spr_xucr0_mddp),
      .xu_lsu_spr_xucr0_cred(xu_lsu_spr_xucr0_cred),
      .xu_lsu_spr_xucr0_rel(xu_lsu_spr_xucr0_rel),
      .spr_xucr0_mdcp(spr_xucr0_mdcp),
      .xu_lsu_spr_xucr0_flsta(xu_lsu_spr_xucr0_flsta),
      .xu_lsu_spr_xucr0_l2siw(xu_lsu_spr_xucr0_l2siw),
      .xu_lsu_spr_xucr0_flh2l2(xu_lsu_spr_xucr0_flh2l2),
      .xu_lsu_spr_xucr0_dcdis(xu_lsu_spr_xucr0_dcdis),
      .xu_lsu_spr_xucr0_wlk(xu_lsu_spr_xucr0_wlk),
      .spr_dbcr0_idm(spr_dbcr0_idm),
      .spr_dbcr0_icmp(spr_dbcr0_icmp),
      .spr_dbcr0_brt(spr_dbcr0_brt),
      .spr_dbcr0_irpt(spr_dbcr0_irpt),
      .spr_dbcr0_trap(spr_dbcr0_trap),
      .spr_dbcr0_dac1(spr_dbcr0_dac1),
      .spr_dbcr0_dac2(spr_dbcr0_dac2),
      .spr_dbcr0_ret(spr_dbcr0_ret),
      .spr_dbcr0_dac3(spr_dbcr0_dac3),
      .spr_dbcr0_dac4(spr_dbcr0_dac4),
      .spr_dbcr1_iac12m(spr_dbcr1_iac12m),
      .spr_dbcr1_iac34m(spr_dbcr1_iac34m),
      .spr_epcr_dtlbgs(spr_epcr_dtlbgs),
      .spr_epcr_itlbgs(spr_epcr_itlbgs),
      .spr_epcr_dsigs(spr_epcr_dsigs),
      .spr_epcr_isigs(spr_epcr_isigs),
      .spr_epcr_duvd(spr_epcr_duvd),
      .spr_epcr_dgtmi(spr_epcr_dgtmi_int),
      .xu_mm_spr_epcr_dmiuh(xu_mm_spr_epcr_dmiuh),
      .spr_msr_ucle(spr_msr_ucle),
      .spr_msr_spv(spr_msr_spv),
      .spr_msr_fp(spr_msr_fp),
      .spr_msr_ds(spr_msr_ds),
      .spr_msrp_uclep(spr_msrp_uclep),
      .spr_xucr4_mmu_mchk(spr_xucr4_mmu_mchk),
      .spr_xucr4_mddmh(spr_xucr4_mddmh),
      `ifndef THREADS1
      .spr_dvc1_t1(spr_dvc1_t1),
      .spr_dvc2_t1(spr_dvc2_t1),
      `endif
      .spr_dvc1_t0(spr_dvc1_t0),
      .spr_dvc2_t0(spr_dvc2_t0),

      // BOLT-ON
      .bo_enable_2(bo_enable_2),		// general bolt-on enable
      .pc_xu_bo_reset(pc_xu_bo_reset),		// reset
      .pc_xu_bo_unload(pc_xu_bo_unload),		// unload sticky bits
      .pc_xu_bo_repair(pc_xu_bo_repair),		// execute sticky bit decode
      .pc_xu_bo_shdata(pc_xu_bo_shdata),		// shift data for timing write and diag loop
      .pc_xu_bo_select(pc_xu_bo_select),		// select for mask and hier writes
      .xu_pc_bo_fail(xu_pc_bo_fail),		// fail/no-fix reg
      .xu_pc_bo_diagout(xu_pc_bo_diagout),
      // ABIST
      .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
      .pc_xu_abist_ena_dc(pc_xu_abist_ena_dc),
      .pc_xu_abist_g8t_wenb(pc_xu_abist_g8t_wenb),
      .pc_xu_abist_waddr_0(pc_xu_abist_waddr_0),
      .pc_xu_abist_di_0(pc_xu_abist_di_0),
      .pc_xu_abist_g8t1p_renb_0(pc_xu_abist_g8t1p_renb_0),
      .pc_xu_abist_raddr_0(pc_xu_abist_raddr_0),
      .pc_xu_abist_wl32_comp_ena(pc_xu_abist_wl32_comp_ena),
      .pc_xu_abist_raw_dc_b(pc_xu_abist_raw_dc_b),
      .pc_xu_abist_g8t_dcomp(pc_xu_abist_g8t_dcomp),
      .pc_xu_abist_g8t_bw_1(pc_xu_abist_g8t_bw_1),
      .pc_xu_abist_g8t_bw_0(pc_xu_abist_g8t_bw_0),

      // Debug
      .pc_xu_trace_bus_enable(pc_xu_trace_bus_enable),
      .spr_debug_mux_ctrls(spr_debug_mux_ctrls),
      .spr_debug_data_in(spr_debug_data_in),
      .spr_debug_data_out(spr_debug_data_out),

      // Power
      .vcs(vdd),
      .vdd(vdd),
      .gnd(gnd)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_pc_ram_done_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[xu_pc_ram_done_offset]),
      .scout(sov[xu_pc_ram_done_offset]),
      .din(xu_pc_ram_done_d),
      .dout(xu_pc_ram_done_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) xu_pc_ram_data_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(xu_pc_ram_done_d),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[xu_pc_ram_data_offset : xu_pc_ram_data_offset + `GPR_WIDTH-1]),
      .scout(sov[xu_pc_ram_data_offset : xu_pc_ram_data_offset + `GPR_WIDTH-1]),
      .din(xu_pc_ram_data_d),
      .dout(xu_pc_ram_data_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq_xu_gpr_ex6_we_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[lq_xu_gpr_ex6_we_offset]),
      .scout(sov[lq_xu_gpr_ex6_we_offset]),
      .din(lq_xu_gpr_ex6_we_d),
      .dout(lq_xu_gpr_ex6_we_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC+`THREADS_POOL_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) lq_xu_gpr_ex6_wa_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(lq_xu_ex5_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[lq_xu_gpr_ex6_wa_offset : lq_xu_gpr_ex6_wa_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC-1]),
      .scout(sov[lq_xu_gpr_ex6_wa_offset : lq_xu_gpr_ex6_wa_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC-1]),
      .din(lq_xu_gpr_ex6_wa_d),
      .dout(lq_xu_gpr_ex6_wa_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) lq_xu_gpr_ex6_wd_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(lq_xu_ex5_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[lq_xu_gpr_ex6_wd_offset : lq_xu_gpr_ex6_wd_offset + `GPR_WIDTH-1]),
      .scout(sov[lq_xu_gpr_ex6_wd_offset : lq_xu_gpr_ex6_wd_offset + `GPR_WIDTH-1]),
      .din(lq_xu_gpr_ex6_wd_d),
      .dout(lq_xu_gpr_ex6_wd_q)
   );

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];


endmodule
