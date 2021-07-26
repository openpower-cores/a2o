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

//  Description:  FXU Decode
//
//*****************************************************************************
`include "tri_a2o.vh"
module xu0_dec(
   //-------------------------------------------------------------------
   // Clocks & Power
   //-------------------------------------------------------------------
   input [0:`NCLK_WIDTH-1]                         nclk,
   inout                                           vdd,
   inout                                           gnd,

   //-------------------------------------------------------------------
   // Pervasive
   //-------------------------------------------------------------------
   input                                           d_mode_dc,
   input [0:0]                                     delay_lclkr_dc,
   input [0:0]                                     mpw1_dc_b,
   input                                           mpw2_dc_b,
   input                                           func_sl_force,
   input                                           func_sl_thold_0_b,
   input                                           sg_0,
   input                                           scan_in,
   output                                          scan_out,

   //-------------------------------------------------------------------
   // Interface with CP
   //-------------------------------------------------------------------
   input [0:`THREADS-1]                            cp_flush,
   input [0:`ITAG_SIZE_ENC-1]                      cp_next_itag_t0,
   `ifndef THREADS1
   input [0:`ITAG_SIZE_ENC-1]                      cp_next_itag_t1,
   `endif

   output [0:`THREADS-1]                           dec_ex0_flush,
   output [0:`THREADS-1]                           dec_ex1_flush,
   output [0:`THREADS-1]                           dec_ex2_flush,
   output [0:`THREADS-1]                           dec_ex3_flush,
   output [0:`THREADS-1]                           dec_cp_flush,

   //-------------------------------------------------------------------
   // Interface with RV
   //-------------------------------------------------------------------
   input [0:`THREADS-1]                            rv_xu0_vld,
   input                                           rv_xu0_ex0_ord,
   input [0:19]                                    rv_xu0_ex0_fusion,
   input [0:31]                                    rv_xu0_ex0_instr,
   input [0:`ITAG_SIZE_ENC-1]                      rv_xu0_ex0_itag,
   input [0:2]                                     rv_xu0_ex0_ucode,
   input                                           rv_xu0_ex0_s1_v,
   input                                           rv_xu0_ex0_s2_v,
   input [0:2]                                     rv_xu0_ex0_s2_t,
   input                                           rv_xu0_ex0_s3_v,
   input [0:2]                                     rv_xu0_ex0_s3_t,
   input                                           rv_xu0_ex0_t1_v,
   input [0:`GPR_POOL_ENC-1]                       rv_xu0_ex0_t1_p,
   input [0:2]                                     rv_xu0_ex0_t1_t,
   input                                           rv_xu0_ex0_t2_v,
   input [0:`GPR_POOL_ENC-1]                       rv_xu0_ex0_t2_p,
   input [0:2]                                     rv_xu0_ex0_t2_t,
   input                                           rv_xu0_ex0_t3_v,
   input [0:`GPR_POOL_ENC-1]                       rv_xu0_ex0_t3_p,
   input [0:2]                                     rv_xu0_ex0_t3_t,
   input [0:`THREADS-1]                            rv_xu0_ex0_spec_flush,
   input [0:`THREADS-1]                            rv_xu0_ex1_spec_flush,
   input [0:`THREADS-1]                            rv_xu0_ex2_spec_flush,

   output                                          xu0_rv_ord_complete,
   output [0:`ITAG_SIZE_ENC-1]                     xu0_rv_ord_itag,
   output                                          xu0_rv_hold_all,

   //-------------------------------------------------------------------
   // Interface with IU
   //-------------------------------------------------------------------
   output [0:`THREADS-1]                           xu0_iu_execute_vld,
   output [0:`ITAG_SIZE_ENC-1]                     xu0_iu_itag,
   output [0:`THREADS-1]                           xu0_iu_mtiar,
   output                                          xu0_iu_exception_val,
   output [0:4]                                    xu0_iu_exception,
   output                                          xu0_iu_n_flush,
   output                                          xu0_iu_np1_flush,
   output                                          xu0_iu_flush2ucode,
   output [0:3]                                    xu0_iu_perf_events,

   output [0:`THREADS-1]                           xu_iu_np1_async_flush,
   input [0:`THREADS-1]                            iu_xu_async_complete,
   input                                           iu_xu_credits_returned,

   output                                          xu0_pc_ram_done,

   output [0:`THREADS-1]                           xu_iu_pri_val,
   output [0:2]                                    xu_iu_pri,

   //-------------------------------------------------------------------
   // Interface with ALU
   //-------------------------------------------------------------------
   output                                          dec_pop_ex1_act,
   output                                          dec_alu_ex1_act,
   output [0:31]                                   dec_alu_ex1_instr,
   output                                          dec_alu_ex1_sel_isel,
   output [0:`GPR_WIDTH/8-1]                       dec_alu_ex1_add_rs1_inv,
   output [0:1]                                    dec_alu_ex2_add_ci_sel,
   output                                          dec_alu_ex1_sel_trap,
   output                                          dec_alu_ex1_sel_cmpl,
   output                                          dec_alu_ex1_sel_cmp,
   output                                          dec_alu_ex1_msb_64b_sel,
   output                                          dec_alu_ex1_xer_ov_en,
   output                                          dec_alu_ex1_xer_ca_en,
   input                                           alu_dec_ex3_trap_val,
   output                                          xu0_xu1_ex3_act,

   //-------------------------------------------------------------------
   // Interface with MUL
   //-------------------------------------------------------------------
   output                                          dec_mul_ex1_mul_recform,
   output [0:`THREADS-1]                           dec_mul_ex1_mul_val,
   output                                          dec_mul_ex1_mul_ord,
   output                                          dec_mul_ex1_mul_ret,
   output                                          dec_mul_ex1_mul_sign,
   output                                          dec_mul_ex1_mul_size,
   output                                          dec_mul_ex1_mul_imm,
   output                                          dec_mul_ex1_xer_ov_update,
   input                                           mul_dec_ex6_ord_done,

   output [0:`THREADS-1]                           dec_ord_flush,

   //-------------------------------------------------------------------
   // Interface with DIV
   //-------------------------------------------------------------------
   output [0:7]                                    dec_div_ex1_div_ctr,
   output                                          dec_div_ex1_div_act,
   output [0:`THREADS-1]                           dec_div_ex1_div_val,
   output                                          dec_div_ex1_div_sign,
   output                                          dec_div_ex1_div_size,
   output                                          dec_div_ex1_div_extd,
   output                                          dec_div_ex1_div_recform,
   output                                          dec_div_ex1_xer_ov_update,
   input                                           div_dec_ex4_done,

   //-------------------------------------------------------------------
   // Interface with SPR
   //-------------------------------------------------------------------
   input                                           spr_xu_ord_read_done,
   input                                           spr_xu_ord_write_done,
   input                                           spr_dec_ex4_spr_hypv,
   input                                           spr_dec_ex4_spr_illeg,
   input                                           spr_dec_ex4_spr_priv,
   input                                           spr_dec_ex4_np1_flush,

   input                                           xu_slowspr_val_in,
   input                                           xu_slowspr_rw_in,

   //-------------------------------------------------------------------
   // Interface with BCD
   //-------------------------------------------------------------------
   output                                          dec_bcd_ex1_val,
   output                                          dec_bcd_ex1_is_addg6s,
   output                                          dec_bcd_ex1_is_cdtbcd,

   //-------------------------------------------------------------------
   // Interface with BYP
   //-------------------------------------------------------------------
   input                                           byp_dec_ex2_abort,
   output                                          dec_byp_ex0_act,
   output [64-`GPR_WIDTH:63]                       dec_byp_ex1_imm,
   output [24:25]                                  dec_byp_ex1_instr,
   output                                          dec_byp_ex0_rs2_sel_imm,
   output                                          dec_byp_ex0_rs1_sel_zero,

   output                                          dec_byp_ex1_is_mflr,
   output                                          dec_byp_ex1_is_mfxer,
   output                                          dec_byp_ex1_is_mtxer,
   output                                          dec_byp_ex1_is_mfcr_sel,
   output [0:7]                                    dec_byp_ex1_is_mfcr,
   output [0:7]                                    dec_byp_ex1_is_mtcr,
   output                                          dec_byp_ex1_is_mfctr,
   output [2:3]                                    dec_byp_ex1_cr_sel,
   output [2:3]                                    dec_byp_ex1_xer_sel,
   output                                          dec_byp_ex1_rs_capt,
   output                                          dec_byp_ex1_ra_capt,

   output                                          dec_byp_ex3_mtiar,
   output                                          dec_byp_ex5_ord_sel,
   output                                          dec_byp_ex4_pop_done,
   output                                          dec_byp_ex3_cnt_done,
   output                                          dec_byp_ex3_prm_done,
   output                                          dec_byp_ex3_dlm_done,
   output [25:25]                                  dec_cnt_ex2_instr,

   output                                          dec_byp_ex4_hpriv,
   output [0:31]                                   dec_byp_ex4_instr,

   output                                          dec_byp_ex3_is_mtspr,
   output                                          dec_br_ex0_act,

   //-------------------------------------------------------------------
   // Interface with BR
   //-------------------------------------------------------------------
   input [0:`THREADS-1]                            br_dec_ex3_execute_vld,

   //-------------------------------------------------------------------
   // Interface with Regfiles
   //-------------------------------------------------------------------
   output                                          xu0_gpr_ex6_we,
   output [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]    xu0_gpr_ex6_wa,

   output                                          xu0_xer_ex6_we,
   output [0:`XER_POOL_ENC+`THREADS_POOL_ENC-1]    xu0_xer_ex6_wa,

   output                                          xu0_cr_ex6_we,
   output [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]     xu0_cr_ex6_wa,

   output                                          xu0_ctr_ex4_we,
   output [0:`CTR_POOL_ENC+`THREADS_POOL_ENC-1]    xu0_ctr_ex4_wa,

   output                                          xu0_lr_ex4_we,
   output [0:`BR_POOL_ENC+`THREADS_POOL_ENC-1]     xu0_lr_ex4_wa,

   //-------------------------------------------------------------------
   // Interface with MMU / ERATs
   //-------------------------------------------------------------------
   output                                          xu_iu_ord_ready,
   output                                          xu_iu_act,
   output [0:`THREADS-1]                           xu_iu_val,
   output                                          xu_iu_is_eratre,
   output                                          xu_iu_is_eratwe,
   output                                          xu_iu_is_eratsx,
   output                                          xu_iu_is_eratilx,
   output                                          xu_iu_is_erativax,
   output [0:1]                                    xu_iu_ws,
   output [0:2]                                    xu_iu_t,
   input                                           iu_xu_ord_read_done,
   input                                           iu_xu_ord_write_done,
   input                                           iu_xu_ord_n_flush_req,
   input                                           iu_xu_ord_par_err,

   output                                          xu_lq_ord_ready,
   output                                          xu_lq_act,
   output [0:`THREADS-1]                           xu_lq_val,
   output                                          xu_lq_hold_req,
   output                                          xu_lq_is_eratre,
   output                                          xu_lq_is_eratwe,
   output                                          xu_lq_is_eratsx,
   output                                          xu_lq_is_eratilx,
   output [0:1]                                    xu_lq_ws,
   output [0:2]                                    xu_lq_t,
   input                                           lq_xu_ord_read_done,
   input                                           lq_xu_ord_write_done,
   input                                           lq_xu_ord_n_flush_req,
   input                                           lq_xu_ord_par_err,


   output                                          xu_mm_ord_ready,
   output                                          xu_mm_act,
   output [0:`THREADS-1]                           xu_mm_val,
   output [0:`ITAG_SIZE_ENC-1]                     xu_mm_itag,
   output                                          xu_mm_is_tlbre,
   output                                          xu_mm_is_tlbwe,
   output                                          xu_mm_is_tlbsx,
   output                                          xu_mm_is_tlbsxr,
   output                                          xu_mm_is_tlbsrx,
   output                                          xu_mm_is_tlbivax,
   output                                          xu_mm_is_tlbilx,
   input [0:`ITAG_SIZE_ENC-1]                      mm_xu_itag,
   input                                           mm_xu_ord_n_flush_req,
   input                                           mm_xu_ord_read_done,
   input                                           mm_xu_ord_write_done,
   input                                           mm_xu_tlb_miss,
   input                                           mm_xu_lrat_miss,
   input                                           mm_xu_tlb_inelig,
   input                                           mm_xu_pt_fault,
   input                                           mm_xu_hv_priv,
   input                                           mm_xu_illeg_instr,
   input                                           mm_xu_tlb_multihit,
   input                                           mm_xu_tlb_par_err,
   input                                           mm_xu_lru_par_err,
   input                                           mm_xu_local_snoop_reject,

   input [0:1]                                     mm_xu_mmucr0_tlbsel_t0,
   `ifndef THREADS1
   input [0:1]                                     mm_xu_mmucr0_tlbsel_t1,
   `endif
   input                                           mm_xu_tlbwe_binv,

   //-------------------------------------------------------------------
   // SPRs
   //-------------------------------------------------------------------
   output                                          xu_spr_ord_flush,
   output                                          xu_spr_ord_ready,
   output                                          ex1_spr_msr_cm,
   output                                          ex4_spr_msr_cm,

   input [0:`THREADS-1]                            spr_msr_cm,
   input [0:`THREADS-1]                            spr_msr_gs,
   input [0:`THREADS-1]                            spr_msr_pr,
   input [0:`THREADS-1]                            spr_epcr_dgtmi,
   input                                           spr_ccr2_notlb,
   input                                           spr_ccr2_en_attn,
   input                                           spr_ccr4_en_dnh,
   input                                           spr_ccr2_en_pc,
   input [0:31]                                    spr_xesr1,
   input [0:`THREADS-1]                            perf_event_en,

   input [0:`THREADS-1]                            pc_xu_ram_active
);

   localparam                                      tiup = 1'b1;
   localparam                                      tidn = 1'b0;
   localparam                    XER_LEFT          = `GPR_POOL_ENC-`XER_POOL_ENC;
   localparam                    CR_LEFT           = `GPR_POOL_ENC-`CR_POOL_ENC;

   // Latches
	wire [1:5]                    exx_act_q,                 exx_act_d                  ; //  input=>exx_act_d                       ,act=>1'b1
	wire                          ex1_s2_v_q                                            ; //  input=>rv_xu0_ex0_s2_v                 ,act=>exx_act[0]
	wire [0:2]                    ex1_s2_t_q                                            ; //  input=>rv_xu0_ex0_s2_t                 ,act=>exx_act[0]
	wire                          ex1_s3_v_q                                            ; //  input=>rv_xu0_ex0_s3_v                 ,act=>exx_act[0]
	wire [0:2]                    ex1_s3_t_q                                            ; //  input=>rv_xu0_ex0_s3_t                 ,act=>exx_act[0]
	wire [0:2]                    ex1_t1_t_q                                            ; //  input=>rv_xu0_ex0_t1_t                 ,act=>exx_act[0]
	wire [0:2]                    ex1_t2_t_q                                            ; //  input=>rv_xu0_ex0_t2_t                 ,act=>exx_act[0]
	wire [0:2]                    ex1_t3_t_q                                            ; //  input=>rv_xu0_ex0_t3_t                 ,act=>exx_act[0]
	wire                          ex1_t1_v_q                                            ; //  input=>rv_xu0_ex0_t1_v                 ,act=>exx_act[0]
	wire                          ex1_t2_v_q                                            ; //  input=>rv_xu0_ex0_t2_v                 ,act=>exx_act[0]
	wire                          ex1_t3_v_q                                            ; //  input=>rv_xu0_ex0_t3_v                 ,act=>exx_act[0]
	wire [0:`GPR_POOL_ENC-1]      ex1_t1_p_q                                            ; //  input=>rv_xu0_ex0_t1_p                 ,act=>exx_act[0]
	wire [0:`XER_POOL_ENC-1]      ex1_t2_p_q                                            ; //  input=>rv_xu0_ex0_t2_p[XER_LEFT:`GPR_POOL_ENC-1]  ,act=>exx_act[0]
	wire [0:`CR_POOL_ENC-1]       ex1_t3_p_q                                            ; //  input=>rv_xu0_ex0_t3_p[CR_LEFT:`GPR_POOL_ENC-1]   ,act=>exx_act[0]
	wire [0:31]                   ex1_instr_q,               ex0_instr                  ; //  input=>ex0_instr                       ,act=>exx_act[0]
	wire [0:2]                    ex1_ucode_q                                           ; //  input=>rv_xu0_ex0_ucode                ,act=>exx_act[0]
	wire [0:`ITAG_SIZE_ENC-1]     ex1_itag_q                                            ; //  input=>rv_xu0_ex0_itag                 ,act=>exx_act[0]
	wire [0:1]                    ex2_add_ci_sel_q,          ex1_add_ci_sel             ; //  input=>ex1_add_ci_sel                  ,act=>exx_act[1]
	wire [0:`ITAG_SIZE_ENC-1]     ex2_itag_q                                            ; //  input=>ex1_itag_q                      ,act=>exx_act[1]
	wire [0:`GPR_POOL_ENC-1]      ex2_t1_p_q                                            ; //  input=>ex1_t1_p_q                      ,act=>exx_act[1]
	wire [0:`XER_POOL_ENC-1]      ex2_t2_p_q                                            ; //  input=>ex1_t2_p_q                      ,act=>exx_act[1]
	wire [0:`CR_POOL_ENC-1]       ex2_t3_p_q                                            ; //  input=>ex1_t3_p_q                      ,act=>exx_act[1]
	wire [0:`GPR_POOL_ENC-1]      ex3_t1_p_q                                            ; //  input=>ex2_t1_p_q                      ,act=>exx_act[2]
	wire [0:`XER_POOL_ENC-1]      ex3_t2_p_q                                            ; //  input=>ex2_t2_p_q                      ,act=>exx_act[2]
	wire [0:`CR_POOL_ENC-1]       ex3_t3_p_q                                            ; //  input=>ex2_t3_p_q                      ,act=>exx_act[2]
	wire [0:`ITAG_SIZE_ENC-1]     ex3_itag_q                                            ; //  input=>ex2_itag_q                      ,act=>exx_act[2]
	wire [0:`ITAG_SIZE_ENC-1]     ex4_itag_q,                ex3_itag                   ; //  input=>ex3_itag                        ,act=>exx_act[3]
	wire [0:`THREADS-1]           cp_flush_q                                            ; //  input=>cp_flush                        ,act=>1'b1
	wire [0:`THREADS-1]           ex0_val_q,                 rv2_val                    ; //  input=>rv2_val                         ,act=>1'b1
	wire [0:`THREADS-1]           ex1_val_q,                 ex0_val                    ; //  input=>ex0_val                         ,act=>1'b1
	wire [0:`THREADS-1]           ex2_val_q,                 ex1_val                    ; //  input=>ex1_val                         ,act=>1'b1
	wire [0:`THREADS-1]           ex3_val_q,                 ex2_val                    ; //  input=>ex2_val                         ,act=>1'b1
	wire [0:`THREADS-1]           ex4_val_q,                 ex3_val                    ; //  input=>ex3_val                         ,act=>1'b1
	wire [0:`THREADS-1]           ex5_val_q,                 ex4_val                    ; //  input=>ex4_val                         ,act=>1'b1
	wire [0:`THREADS-1]           ex6_val_q,                 ex5_val                    ; //  input=>ex5_val                         ,act=>1'b1
	wire [0:`THREADS-1]           ex1_ord_val_q,             ex0_ord_val                ; //  input=>ex0_ord_val                     ,act=>1'b1
	wire [0:`THREADS-1]           ex2_ord_val_q,             ex1_ord_val                ; //  input=>ex1_ord_val                     ,act=>1'b1
	wire [0:`THREADS-1]           ex3_ord_val_q,             ex2_ord_val                ; //  input=>ex2_ord_val                     ,act=>1'b1
	wire [0:`THREADS-1]           ex4_ord_val_q,             ex3_ord_val                ; //  input=>ex3_ord_val                     ,act=>1'b1
	wire [0:`THREADS-1]           spr_msr_cm_q                                          ; //  input=>spr_msr_cm                      ,act=>1'b1
	wire [0:`THREADS-1]           spr_msr_gs_q                                          ; //  input=>spr_msr_gs                      ,act=>1'b1
	wire [0:`THREADS-1]           spr_msr_pr_q                                          ; //  input=>spr_msr_pr                      ,act=>1'b1
	wire [0:`THREADS-1]           spr_epcr_dgtmi_q                                      ; //  input=>spr_epcr_dgtmi                  ,act=>1'b1
	wire                          spr_ccr2_notlb_q                                      ; //  input=>spr_ccr2_notlb                  ,act=>1'b1
	wire [0:`THREADS-1]           ex4_br_val_q                                          ; //  input=>br_dec_ex3_execute_vld          ,act=>1'b1
	wire                          ex1_ord_q,                 ex0_ord                    ; //  input=>ex0_ord                         ,act=>1'b1
	wire                          ex2_ord_q                                             ; //  input=>ex1_ord_q                       ,act=>1'b1
	wire                          ex3_ord_q                                             ; //  input=>ex2_ord_q                       ,act=>exx_act[2]
	wire                          ex2_t1_v_q                                            ; //  input=>ex2_t1_v_q                      ,act=>exx_act[1]
	wire                          ex2_t2_v_q                                            ; //  input=>ex1_t2_v_q                      ,act=>exx_act[1]
   wire                          ex2_t3_v_q                                            ; //  input=>ex1_t3_v_q                      ,act=>exx_act[1]
	wire [0:2]                    ex2_t1_t_q                                            ; //  input=>ex1_t1_t_q                      ,act=>exx_act[1]
	wire [0:2]                    ex2_t2_t_q                                            ; //  input=>ex1_t2_t_q                      ,act=>exx_act[1]
	wire [0:2]                    ex2_t3_t_q                                            ; //  input=>ex1_t3_t_q                      ,act=>exx_act[1]
	wire                          ex3_t1_v_q                                            ; //  input=>ex2_t1_v_q                      ,act=>exx_act[2]
	wire                          ex3_t2_v_q                                            ; //  input=>ex2_t2_v_q                      ,act=>exx_act[2]
	wire                          ex3_t3_v_q                                            ; //  input=>ex2_t3_v_q                      ,act=>exx_act[2]
	wire [0:2]                    ex3_t1_t_q                                            ; //  input=>ex2_t1_t_q                      ,act=>exx_act[2]
	wire [0:2]                    ex3_t2_t_q                                            ; //  input=>ex2_t2_t_q                      ,act=>exx_act[2]
	wire [0:2]                    ex3_t3_t_q                                            ; //  input=>ex2_t3_t_q                      ,act=>exx_act[2]
	wire                          ex4_t1_v_q                                            ; //  input=>ex3_t1_v_q                      ,act=>exx_act[3]
	wire                          ex4_t2_v_q                                            ; //  input=>ex3_t2_v_q                      ,act=>exx_act[3]
	wire                          ex4_t3_v_q                                            ; //  input=>ex3_t3_v_q                      ,act=>exx_act[3]
	wire [0:2]                    ex4_t1_t_q                                            ; //  input=>ex3_t1_t_q                      ,act=>exx_act[3]
	wire [0:2]                    ex4_t2_t_q                                            ; //  input=>ex3_t2_t_q                      ,act=>exx_act[3]
	wire [0:2]                    ex4_t3_t_q                                            ; //  input=>ex3_t3_t_q                      ,act=>exx_act[3]
	wire [0:`GPR_POOL_ENC-1]         ex4_t1_p_q                                         ; //  input=>ex3_t1_p_q                      ,act=>exx_act[3]
	wire [XER_LEFT:`GPR_POOL_ENC-1]  ex4_t2_p_q                                         ; //  input=>ex3_t2_p_q                      ,act=>exx_act[3]
	wire [CR_LEFT:`GPR_POOL_ENC-1]   ex4_t3_p_q                                         ; //  input=>ex3_t3_p_q                      ,act=>exx_act[3]
	wire                          ex5_t1_v_q                                            ; //  input=>ex4_t1_v_q                      ,act=>exx_act[4]
	wire                          ex5_t2_v_q                                            ; //  input=>ex4_t2_v_q                      ,act=>exx_act[4]
	wire                          ex5_t3_v_q                                            ; //  input=>ex4_t3_v_q                      ,act=>exx_act[4]
	wire [0:2]                    ex5_t1_t_q                                            ; //  input=>ex4_t1_t_q                      ,act=>exx_act[4]
	wire [0:2]                    ex5_t2_t_q                                            ; //  input=>ex4_t2_t_q                      ,act=>exx_act[4]
	wire [0:2]                    ex5_t3_t_q                                            ; //  input=>ex4_t3_t_q                      ,act=>exx_act[4]
	wire [0:`GPR_POOL_ENC-1]         ex5_t1_p_q                                         ; //  input=>ex4_t1_p_q                      ,act=>exx_act[4]
	wire [XER_LEFT:`GPR_POOL_ENC-1]  ex5_t2_p_q                                         ; //  input=>ex4_t2_p_q                      ,act=>exx_act[4]
	wire [CR_LEFT:`GPR_POOL_ENC-1]   ex5_t3_p_q                                         ; //  input=>ex4_t3_p_q                      ,act=>exx_act[4]
	wire                          ex5_ord_t1_v_q                                        ; //  input=>ex4_t1_v_q                      ,act=>ex4_ord_act
	wire                          ex5_ord_t2_v_q                                        ; //  input=>ex4_t2_v_q                      ,act=>ex4_ord_act
	wire                          ex5_ord_t3_v_q                                        ; //  input=>ex4_t3_v_q                      ,act=>ex4_ord_act
	wire [0:2]                    ex5_ord_t1_t_q                                        ; //  input=>ex4_t1_t_q                      ,act=>ex4_ord_act
	wire [0:2]                    ex5_ord_t2_t_q                                        ; //  input=>ex4_t2_t_q                      ,act=>ex4_ord_act
	wire [0:2]                    ex5_ord_t3_t_q                                        ; //  input=>ex4_t3_t_q                      ,act=>ex4_ord_act
	wire [0:`GPR_POOL_ENC-1]         ex5_ord_t1_p_q                                     ; //  input=>ex4_t1_p_q                      ,act=>ex4_ord_act
	wire [XER_LEFT:`GPR_POOL_ENC-1]  ex5_ord_t2_p_q                                     ; //  input=>ex4_t2_p_q                      ,act=>ex4_ord_act
	wire [CR_LEFT:`GPR_POOL_ENC-1]   ex5_ord_t3_p_q                                     ; //  input=>ex4_t3_p_q                      ,act=>ex4_ord_act
	wire                          ex6_gpr_we_q,              ex5_gpr_we                 ; //  input=>ex5_gpr_we                      ,act=>1'b1
	wire                          ex6_xer_we_q,              ex5_xer_we                 ; //  input=>ex5_xer_we                      ,act=>1'b1
	wire                          ex6_cr_we_q,               ex5_cr_we                  ; //  input=>ex5_cr_we                       ,act=>1'b1
	wire [CR_LEFT:`GPR_POOL_ENC-1]   ex6_cr_wa_q,            ex5_cr_wa                  ; //  input=>ex5_cr_wa                       ,act=>exx_act[5]
	wire                          ex4_ctr_we_q,              ex3_ctr_we                 ; //  input=>ex3_ctr_we                      ,act=>1'b1
	wire                          ex4_lr_we_q,               ex3_lr_we                  ; //  input=>ex3_lr_we                       ,act=>1'b1
	wire [0:`GPR_POOL_ENC-1]         ex6_t1_p_q,             ex5_t1_p                   ; //  input=>ex5_t1_p                        ,act=>exx_act[5]
	wire [XER_LEFT:`GPR_POOL_ENC-1]  ex6_t2_p_q,             ex5_t2_p                   ; //  input=>ex5_t2_p                        ,act=>exx_act[5]
	wire                          spr_ccr2_en_attn_q                                    ; //  input=>spr_ccr2_en_attn                ,act=>1'b1
	wire                          spr_ccr4_en_dnh_q                                     ; //  input=>spr_ccr4_en_dnh                 ,act=>1'b1
	wire                          spr_ccr2_en_pc_q                                      ; //  input=>spr_ccr2_en_pc                  ,act=>1'b1
	wire [0:`THREADS-1]           ex2_ord_tid_q                                         ; //  input=>ex1_ord_val_q                   ,act=>ex1_ord_act
	wire [0:`ITAG_SIZE_ENC-1]     ex2_ord_itag_q                                        ; //  input=>ex1_itag_q                      ,act=>ex1_ord_act
	wire                          ex2_ord_is_eratre_q                                   ; //  input=>ex1_is_eratre                   ,act=>ex1_ord_act
	wire                          ex2_ord_is_eratwe_q                                   ; //  input=>ex1_is_eratwe                   ,act=>ex1_ord_act
	wire                          ex2_ord_is_eratsx_q                                   ; //  input=>ex1_is_eratsx                   ,act=>ex1_ord_act
	wire                          ex2_ord_is_eratilx_q                                  ; //  input=>ex1_is_eratilx                  ,act=>ex1_ord_act
	wire                          ex2_ord_is_erativax_q                                 ; //  input=>ex1_is_erativax                 ,act=>ex1_ord_act
	wire                          ex2_ord_is_tlbre_q                                    ; //  input=>ex1_is_tlbre                    ,act=>ex1_ord_act
	wire                          ex2_ord_is_tlbwe_q                                    ; //  input=>ex1_is_tlbwe                    ,act=>ex1_ord_act
	wire                          ex2_ord_is_tlbsx_q                                    ; //  input=>ex1_is_tlbsx                    ,act=>ex1_ord_act
	wire                          ex2_ord_is_tlbsxr_q                                   ; //  input=>ex1_is_tlbsxr                   ,act=>ex1_ord_act
	wire                          ex2_ord_is_tlbsrx_q                                   ; //  input=>ex1_is_tlbsrx                   ,act=>ex1_ord_act
	wire                          ex2_ord_is_tlbivax_q                                  ; //  input=>ex1_is_tlbivax                  ,act=>ex1_ord_act
	wire                          ex2_ord_is_tlbilx_q                                   ; //  input=>ex1_is_tlbilx                   ,act=>ex1_ord_act
	wire [19:20]                  ex2_ord_tlb_ws_q                                      ; //  input=>ex1_instr_q[19:20]              ,act=>ex1_ord_act
	wire [8:10]                   ex2_ord_tlb_t_q                                       ; //  input=>ex1_instr_q[8:10]               ,act=>ex1_ord_act
	wire                          ex2_priv_excep_q,          ex1_priv_excep             ; //  input=>ex1_priv_excep                  ,act=>exx_act[1]
	wire                          ex2_hyp_priv_excep_q,      ex1_hyp_priv_excep         ; //  input=>ex1_hyp_priv_excep              ,act=>exx_act[1]
	wire                          ex2_illegal_op_q,          ex1_illegal_op             ; //  input=>ex1_illegal_op                  ,act=>exx_act[1]
	wire                          ex2_flush2ucode_q,         ex1_flush2ucode            ; //  input=>ex1_flush2ucode                 ,act=>1'b1
	wire                          ex2_tlb_illeg_q,           ex1_tlb_illeg              ; //  input=>ex1_tlb_illeg                   ,act=>exx_act[1]
	wire                          ex3_priv_excep_q                                      ; //  input=>ex2_priv_excep_q                ,act=>exx_act[2]
	wire                          ex3_hyp_priv_excep_q                                  ; //  input=>ex2_hyp_priv_excep_q            ,act=>exx_act[2]
	wire                          ex3_illegal_op_q                                      ; //  input=>ex2_illegal_op_q                ,act=>exx_act[2]
	wire                          ex3_flush2ucode_q,         ex2_flush2ucode            ; //  input=>ex2_flush2ucode                 ,act=>1'b1
	wire                          ex4_flush2ucode_q,         ex3_flush2ucode            ; //  input=>ex3_flush2ucode                 ,act=>1'b1
	wire                          ex1_ord_complete_q,        ex0_ord_complete           ; //  input=>ex0_ord_complete                ,act=>1'b1
	wire                          ex2_ord_complete_q,        ex1_ord_complete           ; //  input=>ex1_ord_complete                ,act=>1'b1
	wire                          ex3_ord_complete_q,        ex2_ord_complete           ; //  input=>ex2_ord_complete                ,act=>1'b1
	wire                          ex4_ord_complete_q,        ex3_ord_complete           ; //  input=>ex3_ord_complete                ,act=>1'b1
	wire                          ex5_ord_complete_q,        ex4_ord_complete           ; //  input=>ex4_ord_complete                ,act=>1'b1
	wire                          ex6_ord_complete_q,        ex5_ord_complete           ; //  input=>ex5_ord_complete                ,act=>1'b1
	wire [0:2]                    xu_iu_pri_q,               xu_iu_pri_d                ; //  input=>xu_iu_pri_d                     ,act=>ex1_ord_act
	wire [0:`THREADS-1]           xu_iu_pri_val_q,           xu_iu_pri_val_d            ; //  input=>xu_iu_pri_val_d                 ,act=>1'b1
	wire                          xu_iu_hold_val_q,          xu_iu_hold_val_d           ; //  input=>xu_iu_hold_val_d                ,act=>1'b1
	wire                          xu_lq_hold_val_q,          xu_lq_hold_val_d           ; //  input=>xu_lq_hold_val_d                ,act=>1'b1
	wire                          xu_mm_hold_val_q,          xu_mm_hold_val_d           ; //  input=>xu_mm_hold_val_d                ,act=>1'b1
	wire                          xu_iu_val_q,               xu_iu_val_d                ; //  input=>xu_iu_val_d                     ,act=>1'b1
	wire                          xu_lq_val_q,               xu_lq_val_d                ; //  input=>xu_lq_val_d                     ,act=>1'b1
	wire                          xu_mm_val_q,               xu_mm_val_d                ; //  input=>xu_mm_val_d                     ,act=>1'b1
	wire [0:`THREADS-1]           xu_iu_val_2_q,             xu_iu_val_2_d              ; //  input=>xu_iu_val_2_d                   ,act=>1'b1
	wire [0:`THREADS-1]           xu_lq_val_2_q,             xu_lq_val_2_d              ; //  input=>xu_lq_val_2_d                   ,act=>1'b1
	wire [0:`THREADS-1]           xu_mm_val_2_q,             xu_mm_val_2_d              ; //  input=>xu_mm_val_2_d                   ,act=>1'b1
	wire                          ord_tlb_miss_q,            ord_tlb_miss_d             ; //  input=>ord_tlb_miss_d                  ,act=>ord_outstanding_act
	wire                          ord_lrat_miss_q,           ord_lrat_miss_d            ; //  input=>ord_lrat_miss_d                 ,act=>ord_outstanding_act
	wire                          ord_tlb_inelig_q,          ord_tlb_inelig_d           ; //  input=>ord_tlb_inelig_d                ,act=>ord_outstanding_act
	wire                          ord_pt_fault_q,            ord_pt_fault_d             ; //  input=>ord_pt_fault_d                  ,act=>ord_outstanding_act
	wire                          ord_hv_priv_q,             ord_hv_priv_d              ; //  input=>ord_hv_priv_d                   ,act=>ord_outstanding_act
	wire                          ord_illeg_mmu_q,           ord_illeg_mmu_d            ; //  input=>ord_illeg_mmu_d                 ,act=>ord_outstanding_act
	wire                          ord_lq_flush_q,            ord_lq_flush_d             ; //  input=>ord_lq_flush_d                  ,act=>ord_outstanding_act
	wire                          ord_spr_priv_q,            ord_spr_priv_d             ; //  input=>ord_spr_priv_d                  ,act=>ord_outstanding_act
	wire                          ord_spr_illegal_spr_q,     ord_spr_illegal_spr_d      ; //  input=>ord_spr_illegal_spr_d           ,act=>ord_outstanding_act
	wire                          ord_hyp_priv_spr_q,        ord_hyp_priv_spr_d         ; //  input=>ord_hyp_priv_spr_d              ,act=>ord_outstanding_act
	wire                          ord_ex3_np1_flush_q,       ord_ex3_np1_flush_d        ; //  input=>ord_ex3_np1_flush_d             ,act=>ord_outstanding_act
	wire                          ord_ill_tlb_q,             ord_ill_tlb_d              ; //  input=>ord_ill_tlb_d                   ,act=>ord_outstanding_act
	wire                          ord_priv_q,                ord_priv_d                 ; //  input=>ord_priv_d                      ,act=>ord_outstanding_act
	wire                          ord_hyp_priv_q,            ord_hyp_priv_d             ; //  input=>ord_hyp_priv_d                  ,act=>ord_outstanding_act
	wire                          ord_hold_lq_q,             ord_hold_lq_d              ; //  input=>ord_hold_lq_d                   ,act=>ord_outstanding_act
	wire                          ord_outstanding_q,         ord_outstanding_d          ; //  input=>ord_outstanding_d               ,act=>ord_outstanding_act
	wire                          ord_flushed_q,             ord_flushed_d              ; //  input=>ord_flushed_d                   ,act=>ord_outstanding_act
	wire                          ord_done_q,                ord_done_d                 ; //  input=>ord_done_d                      ,act=>1'b1
	wire                          ord_mmu_req_sent_q,        ord_mmu_req_sent_d         ; //  input=>ord_mmu_req_sent_d              ,act=>ord_outstanding_act
	wire                          ord_core_block_q,          ord_core_block_d           ; //  input=>ord_core_block_d                ,act=>ord_outstanding_act
   wire                          ord_ierat_par_err_q,       ord_ierat_par_err_d        ; //  input=>ord_ierat_par_err_d             ,act=>ord_outstanding_act
   wire                          ord_derat_par_err_q,       ord_derat_par_err_d        ; //  input=>ord_derat_par_err_d             ,act=>ord_outstanding_act
   wire                          ord_tlb_multihit_q,        ord_tlb_multihit_d         ; //  input=>ord_tlb_multihit_d              ,act=>ord_outstanding_act
   wire                          ord_tlb_par_err_q,         ord_tlb_par_err_d          ; //  input=>ord_tlb_par_err_d               ,act=>ord_outstanding_act
   wire                          ord_tlb_lru_par_err_q,     ord_tlb_lru_par_err_d      ; //  input=>ord_tlb_lru_par_err_d           ,act=>ord_outstanding_act
   wire                          ord_local_snoop_reject_q,  ord_local_snoop_reject_d   ; //  input=>ord_local_snoop_reject_d        ,act=>ord_outstanding_act
	wire [0:1]                    mmu_ord_n_flush_req_q,     mmu_ord_n_flush_req_d      ; //  input=>mmu_ord_n_flush_req_d           ,act=>1'b1
	wire [0:1]                    iu_ord_n_flush_req_q,      iu_ord_n_flush_req_d       ; //  input=>iu_ord_n_flush_req_d           ,act=>1'b1
	wire [0:1]                    lq_ord_n_flush_req_q,      lq_ord_n_flush_req_d       ; //  input=>lq_ord_n_flush_req_d           ,act=>1'b1
	wire                          ex4_np1_flush_q,           ex3_np1_flush              ; //  input=>ex3_np1_flush                   ,act=>1'b1
	wire                          ex4_n_flush_q,             ex3_n_flush                ; //  input=>ex3_n_flush                     ,act=>1'b1
	wire                          ex4_excep_val_q,           ex3_excep_val              ; //  input=>ex3_excep_val                   ,act=>1'b1
	wire [0:4]                    ex4_excep_vector_q,        ex3_excep_vector           ; //  input=>ex3_excep_vector                ,act=>1'b1
	wire [0:2]                    ex2_ucode_q                                           ; //  input=>ex1_ucode_q                     ,act=>exx_act[1]
	wire                          ex2_is_ehpriv_q,           ex1_is_ehpriv              ; //  input=>ex1_is_ehpriv                   ,act=>exx_act[1]
	wire                          ex3_is_ehpriv_q                                       ; //  input=>ex2_is_ehpriv_q                 ,act=>exx_act[2]
	wire                          ex2_is_mtiar_q                                        ; //  input=>ex1_is_mtiar                    ,act=>exx_act[1]
	wire                          ex3_mtiar_sel_q,           ex2_mtiar_sel              ; //  input=>ex2_mtiar_sel                   ,act=>1'b1
	wire                          ord_mtiar_q,               ord_mtiar_d                ; //  input=>ord_mtiar_d                     ,act=>1'b1
	wire [0:31]                   ord_instr_q,               ord_instr_d                ; //  input=>ord_instr_d                     ,act=>ex1_ord_valid
	wire                          ex2_is_erativax_q                                     ; //  input=>ex1_is_erativax                 ,act=>ex1_ord_act
	wire [0:`THREADS-1]           xu0_iu_mtiar_q,            xu0_iu_mtiar_d             ; //  input=>xu0_iu_mtiar_d                  ,act=>1'b1
	wire                          ord_is_cp_next_q,          ord_is_cp_next             ; //  input=>ord_is_cp_next                  ,act=>1'b1
	wire                          ord_flush_1_q                                         ; //  input=>ord_spec_flush                  ,act=>1'b1
	wire                          ord_flush_2_q                                         ; //  input=>ord_flush_1_q                   ,act=>1'b1
	wire [0:1]  spr_mmucr0_tlbsel_q[0:`THREADS-1],  spr_mmucr0_tlbsel_d[0:`THREADS-1]   ; //  input=>spr_mmucr0_tlbsel_d             ,act=>1'b1
	wire                          mm_xu_tlbwe_binv_q                                    ; //  input=>mm_xu_tlbwe_binv                ,act=>1'b1
	wire [0:31]                   ex2_instr_q                                           ; //  input=>ex1_instr_q                     ,act=>exx_act[1]
	wire [0:31]                   ex3_instr_q                                           ; //  input=>ex2_instr_q                     ,act=>exx_act[2]
	wire [0:31]                   ex4_instr_q                                           ; //  input=>ex3_instr_q                     ,act=>exx_act[3]
	wire                          ex4_hpriv_q,               ex3_hpriv                  ; //  input=>ex3_hpriv                       ,act=>1'b1
	wire                          ex2_any_popcnt_q,          ex1_any_popcnt             ; //  input=>ex1_any_popcnt                  ,act=>exx_act[1]
	wire                          ex3_any_popcnt_q                                      ; //  input=>ex2_any_popcnt_q                ,act=>exx_act[2]
	wire                          ex4_any_popcnt_q                                      ; //  input=>ex3_any_popcnt_q                ,act=>exx_act[3]
	wire                          ex2_any_cntlz_q,           ex1_any_cntlz              ; //  input=>ex1_any_cntlz                   ,act=>exx_act[1]
	wire                          ex3_any_cntlz_q                                       ; //  input=>ex2_any_cntlz_q                 ,act=>exx_act[2]
	wire                          ex2_is_bpermd_q                                       ; //  input=>ex1_is_bpermd                   ,act=>exx_act[1]
	wire                          ex3_is_bpermd_q                                       ; //  input=>ex2_is_bpermd_q                 ,act=>exx_act[2]
	wire                          ex2_is_dlmzb_q                                        ; //  input=>ex1_is_dlmzb                    ,act=>exx_act[1]
	wire                          ex3_is_dlmzb_q                                        ; //  input=>ex2_is_dlmzb_q                  ,act=>exx_act[2]
	wire                          ex2_mul_multicyc_q,        ex1_mul_multicyc           ; //  input=>ex1_mul_multicyc                ,act=>1'b1
	wire                          ex3_mul_multicyc_q                                    ; //  input=>ex2_mul_multicyc_q              ,act=>1'b1
	wire                          ex2_mul_2c_q,              ex1_mul_2c                 ; //  input=>ex1_mul_2c                      ,act=>1'b1
	wire                          ex2_mul_3c_q,              ex1_mul_3c                 ; //  input=>ex1_mul_3c                      ,act=>1'b1
	wire                          ex2_mul_4c_q,              ex1_mul_4c                 ; //  input=>ex1_mul_4c                      ,act=>1'b1
	wire                          ex3_mul_2c_q                                          ; //  input=>ex2_mul_2c_q                    ,act=>1'b1
	wire                          ex3_mul_3c_q                                          ; //  input=>ex2_mul_3c_q                    ,act=>1'b1
	wire                          ex3_mul_4c_q                                          ; //  input=>ex2_mul_4c_q                    ,act=>1'b1
	wire                          ex4_mul_2c_q,              ex4_mul_2c_d               ; //  input=>ex4_mul_2c_d                    ,act=>1'b1
	wire                          ex4_mul_3c_q,              ex4_mul_3c_d               ; //  input=>ex4_mul_3c_d                    ,act=>1'b1
	wire                          ex4_mul_4c_q,              ex4_mul_4c_d               ; //  input=>ex4_mul_4c_d                    ,act=>1'b1
	wire                          ex5_mul_3c_q,              ex5_mul_3c_d               ; //  input=>ex5_mul_3c_d                    ,act=>1'b1
	wire                          ex5_mul_4c_q,              ex5_mul_4c_d               ; //  input=>ex5_mul_4c_d                    ,act=>1'b1
	wire                          ex6_mul_4c_q,              ex6_mul_4c_d               ; //  input=>ex6_mul_4c_d                    ,act=>1'b1
	wire [0:`THREADS-1]           exx_mul_tid_q,             exx_mul_tid_d              ; //  input=>exx_mul_tid_d                   ,act=>1'b1
	wire                          ex2_is_mtspr_q                                        ; //  input=>ex1_is_mtspr                    ,act=>exx_act[1]
	wire                          ex3_is_mtspr_q                                        ; //  input=>ex2_is_mtspr_q                  ,act=>exx_act[2]
	wire                          ex6_ram_active_q,          ex6_ram_active_d           ; //  input=>ex6_ram_active_d                ,act=>1'b1
	wire [0:`THREADS-1]           ex6_tid_q,                 ex6_tid_d                  ; //  input=>ex6_tid_d                       ,act=>1'b1
	wire [0:`THREADS-1]           ex1_spec_flush_q                                      ; //  input=>rv_xu0_ex0_spec_flush           ,act=>1'b1
	wire [0:`THREADS-1]           ex2_spec_flush_q                                      ; //  input=>rv_xu0_ex1_spec_flush           ,act=>1'b1
	wire [0:`THREADS-1]           ex3_spec_flush_q                                      ; //  input=>rv_xu0_ex2_spec_flush           ,act=>1'b1
	wire [0:`THREADS-1]           ord_async_flush_before_q,  ord_async_flush_before_d   ; //  input=>ord_async_flush_before_d        ,act=>1'b1
	wire [0:`THREADS-1]           ord_async_flush_after_q,   ord_async_flush_after_d    ; //  input=>ord_async_flush_after_d         ,act=>1'b1
    wire                          ord_async_credit_wait_q,   ord_async_credit_wait_d    ; //  input=>ord_async_credit_wait_d         ,act=>1'b1
	wire [0:`THREADS-1]           async_flush_req_q,         async_flush_req_d          ; //  input=>async_flush_req_d               ,act=>1'b1
	wire [0:`THREADS-1]           async_flush_req_2_q                                   ; //  input=>async_flush_req_q               ,act=>1'b1
    wire [0:`THREADS-1]           iu_async_complete_q                                   ; //  input=>iu_xu_async_complete            ,act=>1'b1
    wire                          iu_xu_credits_returned_q                              ; //  input=>iu_xu_credits_returned          ,act=>1'b1
    wire                          ex2_any_mfspr_q,           ex1_any_mfspr              ; //  input=>ex1_any_mfspr                   ,act=>exx_act[1]
	wire                          ex3_any_mfspr_q,           ex2_any_mfspr              ; //  input=>ex2_any_mfspr                   ,act=>exx_act[2]
	wire                          ex2_any_mtspr_q,           ex1_any_mtspr              ; //  input=>ex1_any_mtspr                   ,act=>exx_act[1]
	wire                          ex3_any_mtspr_q,           ex2_any_mtspr              ; //  input=>ex2_any_mtspr                   ,act=>exx_act[2]
   wire [0:3]                    ex4_perf_event_q                                      ; //  input=>ex3_perf_event                  ,act=>exx_act[3]
   wire                          ord_any_mfspr_q                                       ; //  input=>ex1_any_mfspr                   ,act=>ex1_ord_act
   wire                          ord_any_mtspr_q                                       ; //  input=>ex1_any_mtspr                   ,act=>ex1_ord_act
   wire [0:5]                    ord_timer_q,               ord_timer_d                ; //  input=>ord_timer_d                     ,act=>ord_outstanding_act
   wire [0:1]                    ord_timeout_q,             ord_timeout_d              ; //  input=>ord_timeout_d                   ,act=>1'b1
   // Scanchain
	localparam exx_act_offset                             = 0;
	localparam ex1_s2_v_offset                            = exx_act_offset                 + 5;
	localparam ex1_s2_t_offset                            = ex1_s2_v_offset                + 1;
	localparam ex1_s3_v_offset                            = ex1_s2_t_offset                + 3;
	localparam ex1_s3_t_offset                            = ex1_s3_v_offset                + 1;
	localparam ex1_t1_t_offset                            = ex1_s3_t_offset                + 3;
	localparam ex1_t2_t_offset                            = ex1_t1_t_offset                + 3;
	localparam ex1_t3_t_offset                            = ex1_t2_t_offset                + 3;
	localparam ex1_t1_v_offset                            = ex1_t3_t_offset                + 3;
	localparam ex1_t2_v_offset                            = ex1_t1_v_offset                + 1;
	localparam ex1_t3_v_offset                            = ex1_t2_v_offset                + 1;
	localparam ex1_t1_p_offset                            = ex1_t3_v_offset                + 1;
	localparam ex1_t2_p_offset                            = ex1_t1_p_offset                + `GPR_POOL_ENC;
	localparam ex1_t3_p_offset                            = ex1_t2_p_offset                + `XER_POOL_ENC;
	localparam ex1_instr_offset                           = ex1_t3_p_offset                + `CR_POOL_ENC;
	localparam ex1_ucode_offset                           = ex1_instr_offset               + 32;
	localparam ex1_itag_offset                            = ex1_ucode_offset               + 3;
	localparam ex2_add_ci_sel_offset                      = ex1_itag_offset                + `ITAG_SIZE_ENC;
	localparam ex2_itag_offset                            = ex2_add_ci_sel_offset          + 2;
	localparam ex2_t1_p_offset                            = ex2_itag_offset                + `ITAG_SIZE_ENC;
	localparam ex2_t2_p_offset                            = ex2_t1_p_offset                + `GPR_POOL_ENC;
	localparam ex2_t3_p_offset                            = ex2_t2_p_offset                + `XER_POOL_ENC;
	localparam ex3_t1_p_offset                            = ex2_t3_p_offset                + `CR_POOL_ENC;
	localparam ex3_t2_p_offset                            = ex3_t1_p_offset                + `GPR_POOL_ENC;
	localparam ex3_t3_p_offset                            = ex3_t2_p_offset                + `XER_POOL_ENC;
	localparam ex3_itag_offset                            = ex3_t3_p_offset                + `CR_POOL_ENC;
	localparam ex4_itag_offset                            = ex3_itag_offset                + `ITAG_SIZE_ENC;
	localparam cp_flush_offset                            = ex4_itag_offset                + `ITAG_SIZE_ENC;
	localparam ex0_val_offset                             = cp_flush_offset                + `THREADS;
	localparam ex1_val_offset                             = ex0_val_offset                 + `THREADS;
	localparam ex2_val_offset                             = ex1_val_offset                 + `THREADS;
	localparam ex3_val_offset                             = ex2_val_offset                 + `THREADS;
	localparam ex4_val_offset                             = ex3_val_offset                 + `THREADS;
	localparam ex5_val_offset                             = ex4_val_offset                 + `THREADS;
	localparam ex6_val_offset                             = ex5_val_offset                 + `THREADS;
	localparam ex1_ord_val_offset                         = ex6_val_offset                 + `THREADS;
	localparam ex2_ord_val_offset                         = ex1_ord_val_offset             + `THREADS;
	localparam ex3_ord_val_offset                         = ex2_ord_val_offset             + `THREADS;
	localparam ex4_ord_val_offset                         = ex3_ord_val_offset             + `THREADS;
	localparam spr_msr_cm_offset                          = ex4_ord_val_offset             + `THREADS;
	localparam spr_msr_gs_offset                          = spr_msr_cm_offset              + `THREADS;
	localparam spr_msr_pr_offset                          = spr_msr_gs_offset              + `THREADS;
	localparam spr_epcr_dgtmi_offset                      = spr_msr_pr_offset              + `THREADS;
	localparam spr_ccr2_notlb_offset                      = spr_epcr_dgtmi_offset          + `THREADS;
	localparam ex4_br_val_offset                          = spr_ccr2_notlb_offset          + 1;
	localparam ex1_ord_offset                             = ex4_br_val_offset              + `THREADS;
	localparam ex2_ord_offset                             = ex1_ord_offset                 + 1;
	localparam ex3_ord_offset                             = ex2_ord_offset                 + 1;
	localparam ex2_t1_v_offset                            = ex3_ord_offset                 + 1;
	localparam ex2_t2_v_offset                            = ex2_t1_v_offset                + 1;
	localparam ex2_t3_v_offset                            = ex2_t2_v_offset                + 1;
	localparam ex2_t1_t_offset                            = ex2_t3_v_offset                + 1;
	localparam ex2_t2_t_offset                            = ex2_t1_t_offset                + 3;
	localparam ex2_t3_t_offset                            = ex2_t2_t_offset                + 3;
	localparam ex3_t1_v_offset                            = ex2_t3_t_offset                + 3;
	localparam ex3_t2_v_offset                            = ex3_t1_v_offset                + 1;
	localparam ex3_t3_v_offset                            = ex3_t2_v_offset                + 1;
	localparam ex3_t1_t_offset                            = ex3_t3_v_offset                + 1;
	localparam ex3_t2_t_offset                            = ex3_t1_t_offset                + 3;
	localparam ex3_t3_t_offset                            = ex3_t2_t_offset                + 3;
	localparam ex4_t1_v_offset                            = ex3_t3_t_offset                + 3;
	localparam ex4_t2_v_offset                            = ex4_t1_v_offset                + 1;
	localparam ex4_t3_v_offset                            = ex4_t2_v_offset                + 1;
	localparam ex4_t1_t_offset                            = ex4_t3_v_offset                + 1;
	localparam ex4_t2_t_offset                            = ex4_t1_t_offset                + 3;
	localparam ex4_t3_t_offset                            = ex4_t2_t_offset                + 3;
	localparam ex4_t1_p_offset                            = ex4_t3_t_offset                + 3;
	localparam ex4_t2_p_offset                            = ex4_t1_p_offset                + `GPR_POOL_ENC;
	localparam ex4_t3_p_offset                            = ex4_t2_p_offset                + -XER_LEFT+`GPR_POOL_ENC;
	localparam ex5_t1_v_offset                            = ex4_t3_p_offset                + -CR_LEFT+`GPR_POOL_ENC;
	localparam ex5_t2_v_offset                            = ex5_t1_v_offset                + 1;
	localparam ex5_t3_v_offset                            = ex5_t2_v_offset                + 1;
	localparam ex5_t1_t_offset                            = ex5_t3_v_offset                + 1;
	localparam ex5_t2_t_offset                            = ex5_t1_t_offset                + 3;
	localparam ex5_t3_t_offset                            = ex5_t2_t_offset                + 3;
	localparam ex5_t1_p_offset                            = ex5_t3_t_offset                + 3;
	localparam ex5_t2_p_offset                            = ex5_t1_p_offset                + `GPR_POOL_ENC;
	localparam ex5_t3_p_offset                            = ex5_t2_p_offset                + -XER_LEFT+`GPR_POOL_ENC;
	localparam ex5_ord_t1_v_offset                        = ex5_t3_p_offset                + -CR_LEFT+`GPR_POOL_ENC;
	localparam ex5_ord_t2_v_offset                        = ex5_ord_t1_v_offset            + 1;
	localparam ex5_ord_t3_v_offset                        = ex5_ord_t2_v_offset            + 1;
	localparam ex5_ord_t1_t_offset                        = ex5_ord_t3_v_offset            + 1;
	localparam ex5_ord_t2_t_offset                        = ex5_ord_t1_t_offset            + 3;
	localparam ex5_ord_t3_t_offset                        = ex5_ord_t2_t_offset            + 3;
	localparam ex5_ord_t1_p_offset                        = ex5_ord_t3_t_offset            + 3;
	localparam ex5_ord_t2_p_offset                        = ex5_ord_t1_p_offset            + `GPR_POOL_ENC;
	localparam ex5_ord_t3_p_offset                        = ex5_ord_t2_p_offset            + -XER_LEFT+`GPR_POOL_ENC;
	localparam ex6_gpr_we_offset                          = ex5_ord_t3_p_offset            + -CR_LEFT+`GPR_POOL_ENC;
	localparam ex6_xer_we_offset                          = ex6_gpr_we_offset              + 1;
	localparam ex6_cr_we_offset                           = ex6_xer_we_offset              + 1;
	localparam ex6_cr_wa_offset                           = ex6_cr_we_offset               + 1;
	localparam ex4_ctr_we_offset                          = ex6_cr_wa_offset               + -CR_LEFT+`GPR_POOL_ENC;
	localparam ex4_lr_we_offset                           = ex4_ctr_we_offset              + 1;
	localparam ex6_t1_p_offset                            = ex4_lr_we_offset               + 1;
	localparam ex6_t2_p_offset                            = ex6_t1_p_offset                + `GPR_POOL_ENC;
	localparam spr_ccr2_en_attn_offset                    = ex6_t2_p_offset                + -XER_LEFT+`GPR_POOL_ENC;
	localparam spr_ccr4_en_dnh_offset                     = spr_ccr2_en_attn_offset        + 1;
	localparam spr_ccr2_en_pc_offset                      = spr_ccr4_en_dnh_offset         + 1;
	localparam ex2_ord_tid_offset                         = spr_ccr2_en_pc_offset          + 1;
	localparam ex2_ord_itag_offset                        = ex2_ord_tid_offset             + `THREADS;
	localparam ex2_ord_is_eratre_offset                   = ex2_ord_itag_offset            + `ITAG_SIZE_ENC;
	localparam ex2_ord_is_eratwe_offset                   = ex2_ord_is_eratre_offset       + 1;
	localparam ex2_ord_is_eratsx_offset                   = ex2_ord_is_eratwe_offset       + 1;
	localparam ex2_ord_is_eratilx_offset                  = ex2_ord_is_eratsx_offset       + 1;
	localparam ex2_ord_is_erativax_offset                 = ex2_ord_is_eratilx_offset      + 1;
	localparam ex2_ord_is_tlbre_offset                    = ex2_ord_is_erativax_offset     + 1;
	localparam ex2_ord_is_tlbwe_offset                    = ex2_ord_is_tlbre_offset        + 1;
	localparam ex2_ord_is_tlbsx_offset                    = ex2_ord_is_tlbwe_offset        + 1;
	localparam ex2_ord_is_tlbsxr_offset                   = ex2_ord_is_tlbsx_offset        + 1;
	localparam ex2_ord_is_tlbsrx_offset                   = ex2_ord_is_tlbsxr_offset       + 1;
	localparam ex2_ord_is_tlbivax_offset                  = ex2_ord_is_tlbsrx_offset       + 1;
	localparam ex2_ord_is_tlbilx_offset                   = ex2_ord_is_tlbivax_offset      + 1;
	localparam ex2_ord_tlb_ws_offset                      = ex2_ord_is_tlbilx_offset       + 1;
	localparam ex2_ord_tlb_t_offset                       = ex2_ord_tlb_ws_offset          + 2;
	localparam ex2_priv_excep_offset                      = ex2_ord_tlb_t_offset           + 3;
	localparam ex2_hyp_priv_excep_offset                  = ex2_priv_excep_offset          + 1;
	localparam ex2_illegal_op_offset                      = ex2_hyp_priv_excep_offset      + 1;
	localparam ex2_flush2ucode_offset                     = ex2_illegal_op_offset          + 1;
	localparam ex2_tlb_illeg_offset                       = ex2_flush2ucode_offset         + 1;
	localparam ex3_priv_excep_offset                      = ex2_tlb_illeg_offset           + 1;
	localparam ex3_hyp_priv_excep_offset                  = ex3_priv_excep_offset          + 1;
	localparam ex3_illegal_op_offset                      = ex3_hyp_priv_excep_offset      + 1;
	localparam ex3_flush2ucode_offset                     = ex3_illegal_op_offset          + 1;
	localparam ex4_flush2ucode_offset                     = ex3_flush2ucode_offset         + 1;
	localparam ex1_ord_complete_offset                    = ex4_flush2ucode_offset         + 1;
	localparam ex2_ord_complete_offset                    = ex1_ord_complete_offset        + 1;
	localparam ex3_ord_complete_offset                    = ex2_ord_complete_offset        + 1;
	localparam ex4_ord_complete_offset                    = ex3_ord_complete_offset        + 1;
	localparam ex5_ord_complete_offset                    = ex4_ord_complete_offset        + 1;
	localparam ex6_ord_complete_offset                    = ex5_ord_complete_offset        + 1;
	localparam xu_iu_pri_offset                           = ex6_ord_complete_offset        + 1;
	localparam xu_iu_pri_val_offset                       = xu_iu_pri_offset               + 3;
	localparam xu_iu_hold_val_offset                      = xu_iu_pri_val_offset           + `THREADS;
	localparam xu_lq_hold_val_offset                      = xu_iu_hold_val_offset          + 1;
	localparam xu_mm_hold_val_offset                      = xu_lq_hold_val_offset          + 1;
	localparam xu_iu_val_offset                           = xu_mm_hold_val_offset          + 1;
	localparam xu_lq_val_offset                           = xu_iu_val_offset               + 1;
	localparam xu_mm_val_offset                           = xu_lq_val_offset               + 1;
	localparam xu_iu_val_2_offset                         = xu_mm_val_offset               + 1;
	localparam xu_lq_val_2_offset                         = xu_iu_val_2_offset             + `THREADS;
	localparam xu_mm_val_2_offset                         = xu_lq_val_2_offset             + `THREADS;
	localparam ord_tlb_miss_offset                        = xu_mm_val_2_offset             + `THREADS;
	localparam ord_lrat_miss_offset                       = ord_tlb_miss_offset            + 1;
	localparam ord_tlb_inelig_offset                      = ord_lrat_miss_offset           + 1;
	localparam ord_pt_fault_offset                        = ord_tlb_inelig_offset          + 1;
	localparam ord_hv_priv_offset                         = ord_pt_fault_offset            + 1;
	localparam ord_illeg_mmu_offset                       = ord_hv_priv_offset             + 1;
	localparam ord_lq_flush_offset                        = ord_illeg_mmu_offset           + 1;
	localparam ord_spr_priv_offset                        = ord_lq_flush_offset            + 1;
	localparam ord_spr_illegal_spr_offset                 = ord_spr_priv_offset            + 1;
	localparam ord_hyp_priv_spr_offset                    = ord_spr_illegal_spr_offset     + 1;
	localparam ord_ex3_np1_flush_offset                   = ord_hyp_priv_spr_offset        + 1;
	localparam ord_ill_tlb_offset                         = ord_ex3_np1_flush_offset       + 1;
	localparam ord_priv_offset                            = ord_ill_tlb_offset             + 1;
	localparam ord_hyp_priv_offset                        = ord_priv_offset                + 1;
	localparam ord_hold_lq_offset                         = ord_hyp_priv_offset            + 1;
	localparam ord_outstanding_offset                     = ord_hold_lq_offset             + 1;
	localparam ord_flushed_offset                         = ord_outstanding_offset         + 1;
	localparam ord_done_offset                            = ord_flushed_offset             + 1;
	localparam ord_mmu_req_sent_offset                    = ord_done_offset                + 1;
	localparam ord_core_block_offset                      = ord_mmu_req_sent_offset        + 1;
	localparam ord_ierat_par_err_offset                   = ord_core_block_offset          + 1;
	localparam ord_derat_par_err_offset                   = ord_ierat_par_err_offset       + 1;
	localparam ord_tlb_multihit_offset                    = ord_derat_par_err_offset       + 1;
	localparam ord_tlb_par_err_offset                     = ord_tlb_multihit_offset        + 1;
	localparam ord_tlb_lru_par_err_offset                 = ord_tlb_par_err_offset         + 1;
	localparam ord_local_snoop_reject_offset              = ord_tlb_lru_par_err_offset     + 1;
	localparam mmu_ord_n_flush_req_offset                 = ord_local_snoop_reject_offset  + 1;
	localparam iu_ord_n_flush_req_offset                  = mmu_ord_n_flush_req_offset     + 2;
	localparam lq_ord_n_flush_req_offset                  = iu_ord_n_flush_req_offset      + 2;
	localparam ex4_np1_flush_offset                       = lq_ord_n_flush_req_offset      + 2;
	localparam ex4_n_flush_offset                         = ex4_np1_flush_offset           + 1;
	localparam ex4_excep_val_offset                       = ex4_n_flush_offset             + 1;
	localparam ex4_excep_vector_offset                    = ex4_excep_val_offset           + 1;
	localparam ex2_ucode_offset                           = ex4_excep_vector_offset        + 5;
	localparam ex2_is_ehpriv_offset                       = ex2_ucode_offset               + 3;
	localparam ex3_is_ehpriv_offset                       = ex2_is_ehpriv_offset           + 1;
	localparam ex2_is_mtiar_offset                        = ex3_is_ehpriv_offset           + 1;
	localparam ex3_mtiar_sel_offset                       = ex2_is_mtiar_offset            + 1;
	localparam ord_mtiar_offset                           = ex3_mtiar_sel_offset           + 1;
	localparam ord_instr_offset                           = ord_mtiar_offset               + 1;
	localparam ex2_is_erativax_offset                     = ord_instr_offset               + 32;
	localparam xu0_iu_mtiar_offset                        = ex2_is_erativax_offset         + 1;
	localparam ord_is_cp_next_offset                      = xu0_iu_mtiar_offset            + `THREADS;
	localparam ord_flush_1_offset                         = ord_is_cp_next_offset          + 1;
	localparam ord_flush_2_offset                         = ord_flush_1_offset             + 1;
	localparam spr_mmucr0_tlbsel_offset                   = ord_flush_2_offset             + 1;
	localparam mm_xu_tlbwe_binv_offset                    = spr_mmucr0_tlbsel_offset       + `THREADS*2;
	localparam ex2_instr_offset                           = mm_xu_tlbwe_binv_offset        + 1;
	localparam ex3_instr_offset                           = ex2_instr_offset               + 32;
	localparam ex4_instr_offset                           = ex3_instr_offset               + 32;
	localparam ex4_hpriv_offset                           = ex4_instr_offset               + 32;
	localparam ex2_any_popcnt_offset                      = ex4_hpriv_offset               + 1;
	localparam ex3_any_popcnt_offset                      = ex2_any_popcnt_offset          + 1;
	localparam ex4_any_popcnt_offset                      = ex3_any_popcnt_offset          + 1;
	localparam ex2_any_cntlz_offset                       = ex4_any_popcnt_offset          + 1;
	localparam ex3_any_cntlz_offset                       = ex2_any_cntlz_offset           + 1;
	localparam ex2_is_bpermd_offset                       = ex3_any_cntlz_offset           + 1;
	localparam ex3_is_bpermd_offset                       = ex2_is_bpermd_offset           + 1;
	localparam ex2_is_dlmzb_offset                        = ex3_is_bpermd_offset           + 1;
	localparam ex3_is_dlmzb_offset                        = ex2_is_dlmzb_offset            + 1;
	localparam ex2_mul_multicyc_offset                    = ex3_is_dlmzb_offset            + 1;
	localparam ex3_mul_multicyc_offset                    = ex2_mul_multicyc_offset        + 1;
	localparam ex2_mul_2c_offset                          = ex3_mul_multicyc_offset        + 1;
	localparam ex2_mul_3c_offset                          = ex2_mul_2c_offset              + 1;
	localparam ex2_mul_4c_offset                          = ex2_mul_3c_offset              + 1;
	localparam ex3_mul_2c_offset                          = ex2_mul_4c_offset              + 1;
	localparam ex3_mul_3c_offset                          = ex3_mul_2c_offset              + 1;
	localparam ex3_mul_4c_offset                          = ex3_mul_3c_offset              + 1;
	localparam ex4_mul_2c_offset                          = ex3_mul_4c_offset              + 1;
	localparam ex4_mul_3c_offset                          = ex4_mul_2c_offset              + 1;
	localparam ex4_mul_4c_offset                          = ex4_mul_3c_offset              + 1;
	localparam ex5_mul_3c_offset                          = ex4_mul_4c_offset              + 1;
	localparam ex5_mul_4c_offset                          = ex5_mul_3c_offset              + 1;
	localparam ex6_mul_4c_offset                          = ex5_mul_4c_offset              + 1;
	localparam exx_mul_tid_offset                         = ex6_mul_4c_offset              + 1;
	localparam ex2_is_mtspr_offset                        = exx_mul_tid_offset             + `THREADS;
	localparam ex3_is_mtspr_offset                        = ex2_is_mtspr_offset            + 1;
	localparam ex6_ram_active_offset                      = ex3_is_mtspr_offset            + 1;
	localparam ex6_tid_offset                             = ex6_ram_active_offset          + 1;
	localparam ex1_spec_flush_offset                      = ex6_tid_offset                 + `THREADS;
	localparam ex2_spec_flush_offset                      = ex1_spec_flush_offset          + `THREADS;
	localparam ex3_spec_flush_offset                      = ex2_spec_flush_offset          + `THREADS;
	localparam ord_async_flush_before_offset              = ex3_spec_flush_offset          + `THREADS;
	localparam ord_async_flush_after_offset               = ord_async_flush_before_offset  + `THREADS;
    localparam ord_async_credit_wait_offset               = ord_async_flush_after_offset   + `THREADS;
    localparam async_flush_req_offset                     = ord_async_credit_wait_offset   + 1;
	localparam async_flush_req_2_offset                   = async_flush_req_offset         + `THREADS;
	localparam iu_async_complete_offset                   = async_flush_req_2_offset       + `THREADS;
    localparam iu_xu_credits_returned_offset              = iu_async_complete_offset       + `THREADS;
    localparam ex2_any_mfspr_offset                       = iu_xu_credits_returned_offset  + 1;
	localparam ex3_any_mfspr_offset                       = ex2_any_mfspr_offset           + 1;
	localparam ex2_any_mtspr_offset                       = ex3_any_mfspr_offset           + 1;
	localparam ex3_any_mtspr_offset                       = ex2_any_mtspr_offset           + 1;
	localparam ex4_perf_event_offset                      = ex3_any_mtspr_offset           + 1;
	localparam ord_any_mfspr_offset                       = ex4_perf_event_offset          + 4;
	localparam ord_any_mtspr_offset                       = ord_any_mfspr_offset           + 1;
	localparam ord_timer_offset                           = ord_any_mtspr_offset           + 1;
	localparam ord_timeout_offset                         = ord_timer_offset               + 6;
	localparam scan_right                                 = ord_timeout_offset             + 2;
   localparam DEX0 = 0;
   localparam DEX1 = 0;
   localparam DEX2 = 0;
   localparam DEX3 = 0;
   localparam DEX4 = 0;
   localparam DEX5 = 0;
   localparam DEX6 = 0;
   localparam DEX7 = 0;
   localparam DEX8 = 0;
   localparam DX = 0;
   wire [0:scan_right-1]                           siv;
   wire [0:scan_right-1]                           sov;
   // Signals
   wire [0:5]                                      exx_act;
   wire  ex0_is_b,        ex0_is_bc,        ex0_is_addi,      ex0_is_addic,     ex0_is_addicr,    ex0_is_addme,
         ex0_is_addis,    ex0_is_addze,     ex0_is_andir,     ex0_is_andisr,    ex0_is_cmpi,      ex0_is_cmpli,
         ex0_is_mulli,    ex0_is_neg,       ex0_is_ori,       ex0_is_oris,      ex0_is_subfic,    ex0_is_subfze,
         ex0_is_twi,      ex0_is_tdi,       ex0_is_xori,      ex0_is_xoris,     ex0_is_subfme,
         ex0_is_mtcrf,    ex0_is_mtmsr,     ex0_is_mtspr,     ex0_is_wrtee,
         ex0_is_wrteei,   ex0_is_eratwe,    ex0_is_erativax,  ex0_is_eratsx;
   wire  ex1_opcode_is_31, ex1_opcode_is_19, ex1_opcode_is_0;
   wire  ex1_is_adde,     ex1_is_addi,     ex1_is_addic,    ex1_is_addicr,   ex1_is_addis,    ex1_is_addme,
         ex1_is_addze,    ex1_is_andir,    ex1_is_andisr,   ex1_is_cmp,      ex1_is_cmpi,     ex1_is_cmpl,
         ex1_is_cmpli,    ex1_is_neg,      ex1_is_ori,      ex1_is_mulldo,   ex1_is_dnh,
         ex1_is_mulhd,    ex1_is_mulhdu,   ex1_is_mulhw,    ex1_is_mulhwu,   ex1_is_mulld,    ex1_is_attn,
         ex1_is_mulli,    ex1_is_mullw,    ex1_is_divd,     ex1_is_divdu,    ex1_is_divw,     ex1_is_divwu,
         ex1_is_divwe,    ex1_is_divweu,   ex1_is_divde,    ex1_is_divdeu,   ex1_is_mflr,     ex1_is_mfxer,
         ex1_is_mfctr,    ex1_is_mfcr,     ex1_is_mtcrf,    ex1_is_mtiar,    ex1_is_eratilx,  ex1_is_erativax,
         ex1_is_eratre,   ex1_is_eratsx,   ex1_is_eratwe,   ex1_is_tlbilx,   ex1_is_tlbivax,  ex1_is_tlbre,
         ex1_is_tlbsx,    ex1_is_tlbsxr,   ex1_is_tlbsrx,   ex1_is_mtxer,    ex1_is_tlbwe,    ex1_is_mftar,
         ex1_is_bc,       ex1_is_wrtee,    ex1_is_wrteei,   ex1_is_mtmsr,    ex1_is_mtspr,    ex1_is_msgclr,
         ex1_is_oris,     ex1_is_subf,
         ex1_is_subfc,    ex1_is_subfe,    ex1_is_subfic,   ex1_is_subfme,   ex1_is_subfze,   ex1_is_td,
         ex1_is_tdi,      ex1_is_tw,       ex1_is_twi,      ex1_is_xori,     ex1_is_xoris,    ex1_is_isel,
         ex1_is_pri1,     ex1_is_pri2,     ex1_is_pri3,     ex1_is_pri4,     ex1_is_pri5,     ex1_is_pri6,
         ex1_is_pri7,     ex1_is_add,      ex1_is_addc,     ex1_is_srad,     ex1_is_sradi,    ex1_is_sraw,
         ex1_is_srawi,    ex1_is_popcntb,  ex1_is_popcntw,  ex1_is_popcntd,  ex1_is_cntlzw,   ex1_is_cntlzd,
         ex1_is_bpermd,   ex1_is_dlmzb,    ex1_is_addg6s,   ex1_is_cdtbcd,   ex1_is_cbcdtd,   ex1_is_mfspr,
         ex1_is_mfmsr,    ex1_is_mftb;
   wire [0:`THREADS-1]                             ex0_flush;
   wire [0:`THREADS-1]                             ex1_flush;
   wire [0:`THREADS-1]                             ex2_flush;
   wire [0:`THREADS-1]                             ex3_flush;
   wire                                            ord_flush;
   wire                                            ex1_ord_valid;
   wire                                            ex2_ord_valid;
// wire                                            ex3_ord_valid;
   wire                                            ex1_valid;
   wire                                            ex3_valid;
// wire                                            ex4_valid;
   wire                                            ex5_valid;
   wire                                            ex6_valid;
   wire                                            ex1_add_rs1_inv;
   wire                                            ex1_any_trap;
   wire                                            ex1_any_cmpl;
   wire                                            ex1_any_cmp;
   wire                                            ex1_alu_cmp;
   wire                                            ex1_any_tw;
   wire                                            ex1_any_td;
   wire                                            ex1_force_64b_cmp;
   wire                                            ex1_force_32b_cmp;
   wire                                            ex0_use_imm;
   wire                                            ex1_imm_size;
   wire                                            ex1_imm_signext;
   wire                                            ex1_shift_imm;
   wire                                            ex1_zero_imm;
   wire                                            ex1_ones_imm;
   wire [6:31]                                     ex1_extd_imm;
   wire [64-`GPR_WIDTH:63]                         ex1_shifted_imm;
   wire                                            ex1_tlb_illeg_ws;
   wire                                            ex1_tlb_illeg_ws2;
   wire                                            ex1_tlb_illeg_ws3;
   wire                                            ex1_tlb_illeg_t;
   wire                                            ex1_tlb_illeg_sel;
   wire [0:`THREADS-1]                             ex6_val;
   wire                                            ex1_mul_val;
   wire                                            ex1_div_val;
   wire [0:2]                                      ex1_div_ctr_sel;
   wire                                            ex5_t1_v;
   wire                                            ex5_t2_v;
   wire                                            ex5_t3_v;
   wire [0:2]                                      ex5_t1_t;
   wire [0:2]                                      ex5_t2_t;
   wire [0:2]                                      ex5_t3_t;
   wire                                            ex4_ord_act;
   wire                                            ex1_ord_act;
   wire                                            ex5_cr1_we;
   wire                                            ex5_cr3_we;
   wire [CR_LEFT:`GPR_POOL_ENC-1]                  ex5_t3_p;
   wire                                            ex1_spr_msr_cm_int;
   wire                                            ord_write_gpr;
   wire                                            ord_read_gpr;
   wire                                            mmu_ord_itag_match;
   wire                                            ord_other;
   wire                                            spr_ord_done;
   wire                                            ex1_any_pri;
   wire [0:`THREADS-1]                             xu_iu_pri_val_int;
   wire                                            ex2_ord_erat_val;
   wire                                            ex2_ord_mmu_val;
   wire [0:16]                                     ex3_excep_cond;
   wire [0:16]                                     ex3_excep_pri;
   wire                                            mmu_error;
   wire                                            ex3_ord_np1_flush;
   wire                                            cp_flush_ord;
   wire                                            cp_flush_ord_tid;
   wire                                            ex6_ord_complete;
   wire [0:`THREADS-1]                             ex1_tid;
   wire                                            ord_spec_flush;
   wire                                            ex1_ord_capt;
   wire                                            ex0_mul_insert;
   wire                                            ex3_mul_insert;
   wire [0:`THREADS-1]                             ex2_ord_cp_next_cmp;
   wire [0:1]                                      ex0_tlbsel;
   wire [0:1]                                      ex1_tlbsel;
   wire [0:1]                                      ex2_tlbsel;
   wire                                            ex0_rs1_sel_zero_trm1;
   wire                                            ex1_is_credit_wait;
   wire                                            ex1_async_flush_before;
   wire                                            ex1_async_flush_after;
   wire [0:`THREADS-1]                             ord_async_flush_before_set;
   wire [0:`THREADS-1]                             ord_async_flush_after_set;
   wire                                            ord_async_credit_wait_set;
   wire                                            ord_async_done;
   wire                                            ex0_opcode_is_19;
   wire                                            ex0_opcode_is_31;
   wire [0:`THREADS-1]                             ex3_tid;
   wire [0:3]                                      ex3_perf_event;
   wire                                            ord_outstanding_act;
   wire                                            ord_waiting;

   //!! Bugspray Include: xu0_dec;

   //-------------------------------------------------------------------------
   // Valids / Act
   //-------------------------------------------------------------------------
   assign dec_ex0_flush       = ex0_flush;
   assign dec_ex1_flush       = ex1_flush;
   assign dec_ex2_flush       = ex2_flush;
   assign dec_ex3_flush       = ex3_flush;
   assign dec_cp_flush        = cp_flush_q;

   assign ex0_flush           = cp_flush_q;
   assign ex1_flush           = cp_flush_q | ex1_spec_flush_q;
   assign ex2_flush           = cp_flush_q | ex2_spec_flush_q | {`THREADS{byp_dec_ex2_abort}};
   assign ex3_flush           = cp_flush_q | ex3_spec_flush_q;

   assign rv2_val             = rv_xu0_vld   & ~cp_flush_q;
   assign ex0_val             = ex0_val_q    & ~ex0_flush   & ~{`THREADS{rv_xu0_ex0_ord}};
   assign ex1_val             = ex1_val_q    & ~ex1_flush;
   assign ex2_val             = ex2_val_q    & ~ex2_flush;
   assign ex3_val             =(ex3_val_q    & ~ex3_flush   & ~{`THREADS{ex3_mul_multicyc_q}}) | (exx_mul_tid_q & {`THREADS{ex3_mul_insert}});
   assign ex4_val             = ex4_val_q    & ~cp_flush_q;
   assign ex5_val             = ex5_val_q    & ~cp_flush_q;
   assign ex6_val             = ex6_val_q    & ~cp_flush_q;

   assign exx_mul_tid_d       = ex3_mul_multicyc_q ? ex3_val_q : exx_mul_tid_q;

   assign ex0_ord_val         = ex0_val_q      & ~ex0_flush   & {`THREADS{rv_xu0_ex0_ord}};
   assign ex1_ord_val         = ex1_ord_val_q  & ~ex1_flush;
   assign ex2_ord_val         = ex2_ord_val_q  & ~ex2_flush;
   assign ex3_ord_val         = ex3_ord_val_q  & ~ex3_flush;

   // This is used for clock gating later... rs/ra_capt
   assign ex0_ord             = |ex0_val_q & rv_xu0_ex0_ord;

   assign ex1_valid           = |(ex1_val);
   assign ex3_valid           = |(ex3_val);
   assign ex5_valid           = |(ex5_val);
   assign ex6_valid           = |(ex6_val);

   assign ex1_ord_act         = ex1_ord_q;

   assign ex4_ord_act         = |(ex4_ord_val_q);

   assign ex1_ord_valid       = |(ex1_ord_val);
   assign ex2_ord_valid       = |(ex2_ord_val);

   assign cp_flush_ord_tid    = |(cp_flush_q & ex2_ord_tid_q);

   assign cp_flush_ord        = ord_outstanding_q & cp_flush_ord_tid;

   assign ord_spec_flush      = |(ex1_spec_flush_q & ex1_ord_val_q) |
                                |(ex2_spec_flush_q & ex2_ord_val_q) |
                                |(ex3_spec_flush_q & ex3_ord_val_q) |
                               (byp_dec_ex2_abort & |ex2_ord_val_q);

   assign ord_flush           = ord_spec_flush | cp_flush_ord;

   assign dec_ord_flush       = {`THREADS{ord_flush}};

   assign xu_spr_ord_flush    = ord_spec_flush;

   assign exx_act[0]          = |(ex0_val_q);
   assign exx_act[1]          = exx_act_q[1];
   assign exx_act[2]          = exx_act_q[2] | ex2_ord_complete_q;
   assign exx_act[3]          = exx_act_q[3] | ex3_mul_insert;
   assign exx_act[4]          = exx_act_q[4];
   assign exx_act[5]          = exx_act_q[5];

   assign exx_act_d[1:5]      = exx_act[0:4];

   assign xu0_xu1_ex3_act     = exx_act_q[3];

   assign dec_br_ex0_act      = ex0_opcode_is_19 | ex0_is_b | ex0_is_bc | rv_xu0_ex0_fusion[0];

   assign ex1_spr_msr_cm_int  = |((ex1_val_q | ex1_ord_val_q) & spr_msr_cm_q);
   assign ex1_spr_msr_cm      = ex1_spr_msr_cm_int;
   assign ex4_spr_msr_cm      = |((ex4_val_q | ex4_ord_val_q) & spr_msr_cm_q);

   //-------------------------------------------------------------------------
   // ALU control logic
   //-------------------------------------------------------------------------
   assign dec_pop_ex1_act        = exx_act[1];
   assign dec_alu_ex1_act        = exx_act[1];
   assign dec_alu_ex1_instr      = ex1_instr_q;
   assign dec_alu_ex1_sel_isel   = ex1_is_isel;
   assign dec_alu_ex2_add_ci_sel = ex2_add_ci_sel_q;
   assign dec_alu_ex1_add_rs1_inv   = {`GPR_WIDTH/8{ex1_add_rs1_inv}};
   assign dec_alu_ex1_sel_trap   = ex1_any_trap;
   assign dec_alu_ex1_sel_cmpl   = ex1_any_cmpl;
   assign dec_alu_ex1_sel_cmp    = ex1_any_cmp;
   assign dec_byp_ex0_act        = exx_act[0];
   assign dec_byp_ex1_instr      = ex1_instr_q[24:25];
   assign dec_byp_ex3_is_mtspr   = ex3_is_mtspr_q;
   assign dec_byp_ex0_rs1_sel_zero  = ex0_rs1_sel_zero_trm1 | (ex0_is_eratsx & ~ex0_tlbsel[1]);

   // CI uses XER[CA]
   assign ex0_rs1_sel_zero_trm1 = (|ex1_ord_val_q & ex1_is_erativax) ? ~ex1_s3_v_q : ~rv_xu0_ex0_s1_v;

   assign ex1_add_ci_sel[0]      =  ex1_is_adde    | ex1_is_addme    | ex1_is_addze |
                                    ex1_is_subfme  | ex1_is_subfze   | ex1_is_subfe;
   // CI uses 1
   assign ex1_add_ci_sel[1]      =  ex1_is_subf    | ex1_is_subfc    | ex1_is_subfic |
                                    ex1_is_neg     | ex1_alu_cmp     | ex1_any_trap;

   assign ex1_add_rs1_inv        =  ex1_add_ci_sel[1] |
                                    ex1_is_subfme  | ex1_is_subfze   | ex1_is_subfe;

   assign ex1_any_tw             = ex1_is_tw | ex1_is_twi;
   assign ex1_any_td             = ex1_is_td | ex1_is_tdi;

   assign ex1_any_trap           = ex1_any_tw | ex1_any_td;

   assign ex1_any_cmp            = ex1_is_cmp | ex1_is_cmpi;

   assign ex1_any_cmpl           = ex1_is_cmpl | ex1_is_cmpli;

   assign ex1_alu_cmp            = ex1_any_cmp | ex1_any_cmpl;

   // Traps, Compares and back invalidates operate regardless of msr[cm]
   assign ex1_force_64b_cmp      = ex1_any_td | (ex1_alu_cmp &  ex1_instr_q[10]);
   assign ex1_force_32b_cmp      = ex1_any_tw | (ex1_alu_cmp & ~ex1_instr_q[10]);

   assign dec_alu_ex1_msb_64b_sel = (ex1_spr_msr_cm_int & ~ex1_force_32b_cmp) | ex1_force_64b_cmp;

   assign dec_alu_ex1_xer_ca_en  =  ex1_is_addc    | ex1_is_addic    | ex1_is_addicr   |
                                    ex1_is_adde    | ex1_is_addme    | ex1_is_addze    |
                                    ex1_is_subfc   | ex1_is_subfic   | ex1_is_subfme   |
                                    ex1_is_subfe   | ex1_is_subfze   | ex1_is_srad     |
                                    ex1_is_sradi   | ex1_is_sraw     | ex1_is_srawi    ;

   assign dec_alu_ex1_xer_ov_en  = ex1_instr_q[21] & (
                                    ex1_is_add     | ex1_is_addc     | ex1_is_adde     |
                                    ex1_is_addme   | ex1_is_addze    | ex1_is_subf     |
                                    ex1_is_subfc   | ex1_is_subfe    | ex1_is_subfme   |
                                    ex1_is_subfze  | ex1_is_neg);

   assign ex1_any_popcnt         =  ex1_is_popcntb | ex1_is_popcntw  | ex1_is_popcntd;

   assign ex1_any_cntlz          = ex1_is_cntlzw   | ex1_is_cntlzd;

   assign dec_byp_ex4_pop_done   = ex4_any_popcnt_q;
   assign dec_byp_ex3_cnt_done   = ex3_any_cntlz_q;
   assign dec_byp_ex3_prm_done   = ex3_is_bpermd_q;
   assign dec_byp_ex3_dlm_done   = ex3_is_dlmzb_q;
   assign dec_cnt_ex2_instr      = ex2_instr_q[25:25];

   //----------------------------------------------------------------------------------------------------------------------------------------
   // Immediate Logic
   //----------------------------------------------------------------------------------------------------------------------------------------
   // Determine what ops use immediate:
   assign ex0_use_imm   =  ex0_is_b       | ex0_is_bc    | ex0_is_addi  | ex0_is_addic    | ex0_is_addicr   | ex0_is_addme |
                           ex0_is_addis   | ex0_is_addze | ex0_is_andir | ex0_is_andisr   | ex0_is_cmpi     | ex0_is_cmpli |
                           ex0_is_mulli   | ex0_is_neg   | ex0_is_ori   | ex0_is_oris     | ex0_is_subfic   | ex0_is_subfze |
                           ex0_is_twi     | ex0_is_tdi   | ex0_is_xori  | ex0_is_xoris    | ex0_is_subfme   | ex0_is_mtcrf |
                           ex0_is_mtmsr   | ex0_is_mtspr | ex0_is_wrteei | ex0_is_wrtee   | ex0_is_eratwe;

   // Determine ops that use 15 bit immediate
   assign ex1_imm_size  =  ex1_is_addi    | ex1_is_addis | ex1_is_subfic | ex1_is_addic   | ex1_is_addicr   | ex1_is_mulli |
                           ex1_is_ori     | ex1_is_oris  | ex1_is_andir  | ex1_is_andisr  | ex1_is_xori     | ex1_is_xoris |
                           ex1_is_bc      | ex1_is_cmpli | ex1_is_cmpi   | ex1_is_twi     | ex1_is_tdi      | ex1_is_wrteei;

   // Determine ops that use sign-extended immediate
   assign ex1_imm_signext = ex1_is_addi   | ex1_is_addis | ex1_is_subfic | ex1_is_addic   | ex1_is_addicr   | ex1_is_mulli |
                            ex1_is_bc     | ex1_is_cmpi  | ex1_is_twi    | ex1_is_tdi;

   assign ex1_shift_imm =  ex1_is_addis   | ex1_is_oris  | ex1_is_andisr | ex1_is_xoris;		// Immediate needs to be shifted

   assign ex1_zero_imm  =  ex1_is_mtcrf   | ex1_is_mtmsr | ex1_is_mtspr  | ex1_is_wrtee   | ex1_is_neg      | ex1_is_addze |
                           ex1_is_subfze  | ex1_is_eratwe | ex1_is_mtiar;		               // Immediate should be zeroed

   assign ex1_ones_imm  =  ex1_is_addme   | ex1_is_subfme;     // Immediate should be all ones

   assign ex1_extd_imm = ({ex1_imm_size, ex1_imm_signext} == 2'b11) ? {{10{ex1_instr_q[16]}},   ex1_instr_q[16:31]} :
                         ({ex1_imm_size, ex1_imm_signext} == 2'b10) ? {10'b0,                   ex1_instr_q[16:31]} :
                                                                                                ex1_instr_q[6:31];

   assign ex1_shifted_imm = (ex1_shift_imm == 1'b0) ? {{`GPR_WIDTH-26{ex1_extd_imm[6]}} , ex1_extd_imm} :
                                                      {{`GPR_WIDTH-32{ex1_extd_imm[15]}}, ex1_extd_imm[16:31], 16'b0};

   // Immediate tied down or tied up as needed
   assign dec_byp_ex1_imm = (ex1_shifted_imm & {`GPR_WIDTH{~ex1_zero_imm}}) | {`GPR_WIDTH{ex1_ones_imm}};

   assign dec_byp_ex0_rs2_sel_imm = ex0_use_imm;

   //-------------------------------------------------------------------------
   // TLB Illegal Ops
   //-------------------------------------------------------------------------
   // WS>3 is reserved
   assign ex1_tlb_illeg_ws    = (ex1_is_eratwe | ex1_is_eratre) & ex1_instr_q[16:18] != 3'b000;
   // WS=2 is reserved in 64b mode
   assign ex1_tlb_illeg_ws2   = (ex1_is_eratwe | ex1_is_eratre) & ex1_instr_q[19:20] == 2'b10 & ex1_spr_msr_cm_int;
   // WS=3 is reserved for eratwe when targeting anything other than erats
   assign ex1_tlb_illeg_ws3   = ex1_is_eratwe & ex1_instr_q[19:20] == 2'b11 & ex1_tlbsel[0] == 1'b0;
   // T=2 is reserved
   assign ex1_tlb_illeg_t     = ex1_is_tlbilx & ex1_instr_q[8:10] == 3'b010;
   // Target other than erats is illegid for some erat ops, and all tlb ops illegid when no TLB is present
   assign ex1_tlb_illeg_sel   = ((ex1_is_tlbwe | ex1_is_tlbre | ex1_is_tlbsx | ex1_is_tlbsxr | ex1_is_tlbsrx | ex1_is_tlbilx | ex1_is_tlbivax) & spr_ccr2_notlb_q) |
                                ((ex1_is_eratwe | ex1_is_eratre | ex1_is_eratsx) & (~ex1_tlbsel[0])) |
                                ((ex1_is_erativax) & (~spr_ccr2_notlb_q));		      // erativax illegid in TLB mode, use tlbivax

   assign ex1_tlb_illeg       = ex1_tlb_illeg_ws | ex1_tlb_illeg_ws2 | ex1_tlb_illeg_ws3 | ex1_tlb_illeg_sel | ex1_tlb_illeg_t;

   //-------------------------------------------------------------------------
   // Multiply Decode
   //-------------------------------------------------------------------------
   assign dec_mul_ex1_mul_val = (ex1_ord_val | ex1_val) & {`THREADS{ex1_mul_val}};

   assign ex1_mul_val            =  ex1_is_mulhw   | ex1_is_mulhwu   | ex1_is_mullw    | ex1_is_mulhd |
                                    ex1_is_mulhdu  | ex1_is_mulld    | ex1_is_mulldo   | ex1_is_mulli ;

   assign dec_mul_ex1_mul_ord    = ex1_ord_q;
   assign dec_mul_ex1_mul_recform = ex1_instr_q[31] & (
                                    ex1_is_mulhd   | ex1_is_mulhdu   | ex1_is_mulhw    | ex1_is_mulhwu |
                                    ex1_is_mulld   | ex1_is_mulldo   | ex1_is_mullw);

   assign dec_mul_ex1_mul_ret    =  ex1_is_mulhw   | ex1_is_mulhwu   | ex1_is_mulhd    | ex1_is_mulhdu;
   assign dec_mul_ex1_mul_size   =  ex1_is_mulld   | ex1_is_mulldo   | ex1_is_mulhd    | ex1_is_mulhdu | ex1_is_mulli;
   assign dec_mul_ex1_mul_sign   = ~(ex1_is_mulhdu | ex1_is_mulhwu);
   assign dec_mul_ex1_mul_imm    =  ex1_is_mulli;

   assign dec_mul_ex1_xer_ov_update = (ex1_is_mulld | ex1_is_mulldo | ex1_is_mullw) & ex1_instr_q[21];

   assign ex1_mul_2c             = ex1_valid & ex1_is_mulli;
   assign ex1_mul_3c             = ex1_valid & ex1_is_mulld;
   assign ex1_mul_4c             = ex1_valid & (ex1_is_mulldo | ex1_is_mulhd | ex1_is_mulhdu);
   assign ex1_mul_multicyc       = ex1_mul_2c | ex1_mul_3c | ex1_mul_4c;

   assign ex4_mul_2c_d           = ex3_mul_2c_q & |(ex3_val_q     & ~ex3_flush);
   assign ex4_mul_3c_d           = ex3_mul_3c_q & |(ex3_val_q     & ~ex3_flush);
   assign ex4_mul_4c_d           = ex3_mul_4c_q & |(ex3_val_q     & ~ex3_flush);

   assign ex5_mul_3c_d           = ex4_mul_3c_q & |(exx_mul_tid_q & ~cp_flush_q);
   assign ex5_mul_4c_d           = ex4_mul_4c_q & |(exx_mul_tid_q & ~cp_flush_q);

   assign ex6_mul_4c_d           = ex5_mul_4c_q & |(exx_mul_tid_q & ~cp_flush_q);

   assign ex0_mul_insert         = ex1_mul_2c | ex2_mul_3c_q | ex3_mul_4c_q;
   assign ex3_mul_insert         = (ex4_mul_2c_q | ex5_mul_3c_q | ex6_mul_4c_q) & |(exx_mul_tid_q & ~cp_flush_q);

   //--------------------------------------------------------------------------
   // DIV control logic
   //--------------------------------------------------------------------------
   assign dec_div_ex1_div_act    = |(ex1_ord_val_q) & ex1_div_val;

   assign dec_div_ex1_div_val    = ex1_ord_val & {`THREADS{ex1_div_val}};

   assign ex1_div_val            =(ex1_is_divd  | ex1_is_divdu    | ex1_is_divw  | ex1_is_divwu |
                                   ex1_is_divde | ex1_is_divdeu   | ex1_is_divwe | ex1_is_divweu);

   assign dec_div_ex1_div_sign   = ex1_is_divw  | ex1_is_divd     | ex1_is_divwe | ex1_is_divde;

   assign dec_div_ex1_div_size   = ex1_is_divd  | ex1_is_divdu    | ex1_is_divde | ex1_is_divdeu;

   assign dec_div_ex1_div_extd   = ex1_is_divde | ex1_is_divdeu   | ex1_is_divwe | ex1_is_divweu;

   assign dec_div_ex1_div_recform =(ex1_is_divd | ex1_is_divdu    | ex1_is_divw  | ex1_is_divwu |
                                   ex1_is_divde | ex1_is_divdeu   | ex1_is_divwe | ex1_is_divweu) & ex1_instr_q[31];

   assign dec_div_ex1_div_ctr = (ex1_div_ctr_sel == 3'b100) ? 8'b01000010 :
                                (ex1_div_ctr_sel == 3'b010) ? 8'b00100010 :
                                (ex1_div_ctr_sel == 3'b001) ? 8'b00010010 :
                                                              8'b00000000 ;
   assign ex1_div_ctr_sel[0]  = ex1_is_divde | ex1_is_divdeu;
   assign ex1_div_ctr_sel[1]  = ex1_is_divd  | ex1_is_divdu    | ex1_is_divwe | ex1_is_divweu;
   assign ex1_div_ctr_sel[2]  = ex1_is_divw  | ex1_is_divwu;

   assign dec_div_ex1_xer_ov_update =(ex1_is_divd | ex1_is_divde | ex1_is_divdeu | ex1_is_divdu |
                                      ex1_is_divw | ex1_is_divwe | ex1_is_divweu | ex1_is_divwu) & ex1_instr_q[21];

   //--------------------------------------------------------------------------
   // BCD control logic
   //--------------------------------------------------------------------------
   assign dec_bcd_ex1_val        = ex1_valid & (ex1_is_cdtbcd | ex1_is_cbcdtd | ex1_is_addg6s);
   assign dec_bcd_ex1_is_addg6s  = ex1_is_addg6s;
   assign dec_bcd_ex1_is_cdtbcd  = ex1_is_cdtbcd;

   //--------------------------------------------------------------------------
   // mt/mf bypassed SPRs
   //--------------------------------------------------------------------------
   assign dec_byp_ex1_is_mflr    = ex1_is_mflr | ex1_is_mftar;
   assign dec_byp_ex1_is_mfxer   = ex1_is_mfxer;
   assign dec_byp_ex1_is_mtxer   = ex1_is_mtxer;
   assign dec_byp_ex1_is_mfctr   = ex1_is_mfctr;
   assign dec_byp_ex1_is_mfcr    = ex1_instr_q[12:19] & {8{ex1_is_mfcr}};
   assign dec_byp_ex1_is_mtcr    = ex1_instr_q[12:19] & {8{ex1_is_mtcrf}};
   assign dec_byp_ex1_is_mfcr_sel = ex1_is_mfcr;		// A2i compatability

   assign dec_byp_ex1_cr_sel[2]  = ex1_s2_v_q & (ex1_s2_t_q == `cr_t);
   assign dec_byp_ex1_cr_sel[3]  = ex1_s3_v_q & (ex1_s3_t_q == `cr_t);
   assign dec_byp_ex1_xer_sel[2] = ex1_s2_v_q & (ex1_s2_t_q == `xer_t);
   assign dec_byp_ex1_xer_sel[3] = ex1_s3_v_q & (ex1_s3_t_q == `xer_t);

   //-------------------------------------------------------------------------
   // Privilege Levels
   //-------------------------------------------------------------------------
   assign ex1_tid                = ex1_val_q | ex1_ord_val_q;

   assign ex1_priv_excep = (  ex1_is_eratilx | ex1_is_erativax | ex1_is_eratre   | ex1_is_eratsx   |
                              ex1_is_eratwe  | ex1_is_tlbilx   | ex1_is_tlbivax  | ex1_is_tlbre    |
                              ex1_is_tlbwe   | ex1_is_tlbsrx   | ex1_is_tlbsx    | ex1_is_tlbsxr   ) & |(ex1_tid & spr_msr_pr_q);

   assign ex1_hyp_priv_excep=(ex1_is_eratilx | ex1_is_erativax | ex1_is_eratre   | ex1_is_eratsx   |
                               ex1_is_eratwe | ex1_is_tlbsx    | ex1_is_tlbsxr   | ex1_is_tlbivax  | ex1_is_tlbre |
                            ((ex1_is_tlbwe   | ex1_is_tlbsrx   | ex1_is_tlbilx) & |(ex1_tid & spr_epcr_dgtmi_q)))
                             & |(ex1_tid & (spr_msr_pr_q | spr_msr_gs_q));

   assign ex1_illegal_op         = (ex1_is_attn    &  ~spr_ccr2_en_attn_q) |
                                   (ex1_is_dnh     &  ~spr_ccr4_en_dnh_q)  ;

   assign ex1_flush2ucode        = ex1_is_mtcrf &
                                  ~((ex1_instr_q[12:19] == 8'b10000000) | (ex1_instr_q[12:19] == 8'b01000000) |
                                    (ex1_instr_q[12:19] == 8'b00100000) | (ex1_instr_q[12:19] == 8'b00010000) |
                                    (ex1_instr_q[12:19] == 8'b00001000) | (ex1_instr_q[12:19] == 8'b00000100) |
                                    (ex1_instr_q[12:19] == 8'b00000010) | (ex1_instr_q[12:19] == 8'b00000001) |
                                    (ex1_instr_q[12:19] == 8'b00000000));

   //--------------------------------------------------------------------------
   // Ordered
   //--------------------------------------------------------------------------
   // 1008 CCR0
   assign ex1_async_flush_after     = ex1_is_mtspr &  ((ex1_instr_q[11:20] == 10'b1000011111) |    // 1008 CCR0
                                                       (ex1_instr_q[11:20] == 10'b1011101101));		//  439 TENC

   assign ex1_async_flush_before    = ex1_is_eratilx | ex1_is_tlbilx | ex1_is_tlbivax | (ex1_is_tlbwe & mm_xu_tlbwe_binv_q) | (ex1_is_mtspr & (ex1_instr_q[11:20] == 10'b1011011111 |   // XUCR0
                                                                                                                                               ex1_instr_q[11:20] == 10'b1000011001 |   // cpcr0 816
                                                                                                                                               ex1_instr_q[11:20] == 10'b1000111001 |   // cpcr1 817
                                                                                                                                               ex1_instr_q[11:20] == 10'b1001011001 |   // cpcr2 818
                                                                                                                                               ex1_instr_q[11:20] == 10'b1010011001 |   // cpcr3 820
                                                                                                                                               ex1_instr_q[11:20] == 10'b1010111001 |   // cpcr4 821
                                                                                                                                               ex1_instr_q[11:20] == 10'b1011011001 )); // cpcr5 822

   assign ex1_is_credit_wait        = (ex1_is_mtspr & (ex1_instr_q[11:20] == 10'b1011011111 |   // XUCR0
                                                       ex1_instr_q[11:20] == 10'b1000011001 |   // cpcr0 816
                                                       ex1_instr_q[11:20] == 10'b1000111001 |   // cpcr1 817
                                                       ex1_instr_q[11:20] == 10'b1001011001 |   // cpcr2 818
                                                       ex1_instr_q[11:20] == 10'b1010011001 |   // cpcr3 820
                                                       ex1_instr_q[11:20] == 10'b1010111001 |   // cpcr4 821
                                                       ex1_instr_q[11:20] == 10'b1011011001 )); // cpcr5 822

   assign ex2_mtiar_sel             = ex2_ord_valid & ex2_is_mtiar_q;

   assign dec_byp_ex3_mtiar         = ex3_mtiar_sel_q;

   assign ex1_any_pri               = ex1_is_pri1 | ex1_is_pri2 | ex1_is_pri3 | ex1_is_pri4 | ex1_is_pri5 | ex1_is_pri6 | ex1_is_pri7;

   assign xu_iu_pri_val             = xu_iu_pri_val_int;
   assign xu_iu_pri_val_int         = xu_iu_pri_val_q & {`THREADS{ord_is_cp_next_q}};

   assign xu_iu_pri_val_d           = ((ex1_ord_val & {`THREADS{ex1_any_pri}}) | xu_iu_pri_val_q) & ~xu_iu_pri_val_int & ~cp_flush_q;

   assign xu_iu_pri                 = xu_iu_pri_q;
   assign xu_iu_pri_d               =  (3'b001 & {3{(ex1_ord_capt & ex1_is_pri1)}}) |
                                       (3'b010 & {3{(ex1_ord_capt & ex1_is_pri2)}}) |
                                       (3'b011 & {3{(ex1_ord_capt & ex1_is_pri3)}}) |
                                       (3'b100 & {3{(ex1_ord_capt & ex1_is_pri4)}}) |
                                       (3'b101 & {3{(ex1_ord_capt & ex1_is_pri5)}}) |
                                       (3'b110 & {3{(ex1_ord_capt & ex1_is_pri6)}}) |
                                       (3'b111 & {3{(ex1_ord_capt & ex1_is_pri7)}});

   assign ex2_ord_erat_val          = (ex2_ord_is_eratre_q | ex2_ord_is_eratwe_q | ex2_ord_is_eratsx_q) & ~(ex2_priv_excep_q | ex2_hyp_priv_excep_q | ex2_tlb_illeg_q);

   assign ex2_ord_mmu_val           = (ex2_ord_is_tlbre_q | ex2_ord_is_tlbwe_q | ex2_ord_is_tlbsx_q |
                                       ex2_ord_is_tlbsxr_q | ex2_ord_is_tlbsrx_q | ex2_ord_is_tlbilx_q |
                                       ex2_ord_is_tlbivax_q | ex2_ord_is_eratilx_q | ex2_ord_is_erativax_q) & (~(ex2_priv_excep_q | ex2_hyp_priv_excep_q | ex2_tlb_illeg_q));

   assign xu_iu_hold_val_d = (ex2_ord_valid == 1'b1) ? (ex2_tlbsel == 2'b10 & ex2_ord_erat_val) : xu_iu_hold_val_q & ~ord_mmu_req_sent_q;
   assign xu_lq_hold_val_d = (ex2_ord_valid == 1'b1) ? (ex2_tlbsel == 2'b11 & ex2_ord_erat_val) : xu_lq_hold_val_q & ~ord_mmu_req_sent_q;
   assign xu_mm_hold_val_d = (ex2_ord_valid == 1'b1) ? (ex2_ord_mmu_val)                        : xu_mm_hold_val_q & ~ord_mmu_req_sent_q;

   // Data is ready by EX5.
   assign ord_mmu_req_sent_d  = (xu_iu_val_d | xu_lq_val_d | xu_mm_val_d) & ord_outstanding_q & ord_is_cp_next_q;

   // mmu_ord_n_flush_req_q is mmu busy, so just retry tlb op again.
   // iu_ord_n_flush_req_q is eratsx collision with I$ back_inv or tlb reload, so just retry erat op again.
   // lq_ord_n_flush_req_q is spare/future use for now because derat has arbiter for collisions.
   assign xu_iu_val_d   = (xu_iu_hold_val_q & ord_outstanding_q & ord_is_cp_next_q & ~ord_mmu_req_sent_q & ~cp_flush_ord_tid) | iu_ord_n_flush_req_q[1];
   assign xu_lq_val_d   = (xu_lq_hold_val_q & ord_outstanding_q & ord_is_cp_next_q & ~ord_mmu_req_sent_q & ~cp_flush_ord_tid) | lq_ord_n_flush_req_q[1];
   assign xu_mm_val_d   = (xu_mm_hold_val_q & ord_outstanding_q & ord_is_cp_next_q & ~ord_mmu_req_sent_q & ~cp_flush_ord_tid) | mmu_ord_n_flush_req_q[1];

   assign xu_iu_act     = xu_iu_val_q;
   assign xu_lq_act     = xu_lq_val_q;
   assign xu_mm_act     = xu_mm_val_q;

   assign xu_iu_val_2_d = ex2_ord_tid_q & {`THREADS{xu_iu_val_q}} & ~cp_flush_q;
   assign xu_lq_val_2_d = ex2_ord_tid_q & {`THREADS{xu_lq_val_q}} & ~cp_flush_q;
   assign xu_mm_val_2_d = ex2_ord_tid_q & {`THREADS{xu_mm_val_q}} & ~cp_flush_q;

   assign xu_iu_val     = xu_iu_val_2_q;
   assign xu_lq_val     = xu_lq_val_2_q;
   assign xu_mm_val     = xu_mm_val_2_q;

   assign xu_mm_itag    = ex2_ord_itag_q;
   assign xu_lq_hold_req   = ord_hold_lq_q;

   assign xu_iu_ord_ready  = ord_is_cp_next_q;
   assign xu_lq_ord_ready  = ord_is_cp_next_q;
   assign xu_mm_ord_ready  = ord_is_cp_next_q;
   assign xu_spr_ord_ready = ord_is_cp_next_q;

   assign ex2_ord_cp_next_cmp[0] = (cp_next_itag_t0 == ex2_ord_itag_q) & ex2_ord_tid_q[0];
   `ifndef THREADS1
      assign ex2_ord_cp_next_cmp[1] = (cp_next_itag_t1 == ex2_ord_itag_q) & ex2_ord_tid_q[1];
   `endif


   assign ord_async_flush_before_set   = ~ex1_ord_val_q & {`THREADS{(ex1_ord_valid & ex1_async_flush_before)}};
   assign ord_async_flush_before_d     = (ord_async_flush_before_set | ord_async_flush_before_q) & ~(iu_async_complete_q | {`THREADS{ord_flush}});

   assign ord_async_flush_after_set    = ~ex1_ord_val_q & {`THREADS{(ex1_ord_valid & ex1_async_flush_after)}};
   assign ord_async_flush_after_d      = (ord_async_flush_after_set  | ord_async_flush_after_q)  & ~(iu_async_complete_q | {`THREADS{ord_flush}});

   assign ord_async_credit_wait_set    = ex1_ord_valid & ex1_is_credit_wait;
   assign ord_async_credit_wait_d      = (ord_async_credit_wait_set  | ord_async_credit_wait_q)  & ~(iu_xu_credits_returned_q | ord_flush);

   assign xu_iu_np1_async_flush        = async_flush_req_q & ~async_flush_req_2_q;

   assign async_flush_req_d            = (ord_async_flush_after_q  & {`THREADS{|ex2_ord_cp_next_cmp & ord_done_q}}) |
                                         (ord_async_flush_before_q & {`THREADS{|ex2_ord_cp_next_cmp}});

   assign ord_is_cp_next               = |ex2_ord_cp_next_cmp & ord_outstanding_q & ~((|ord_async_flush_before_q) | ord_async_credit_wait_q);

   assign mmu_ord_itag_match           = (mm_xu_itag == ex2_ord_itag_q) & ord_outstanding_q;

   assign spr_ord_done                 = spr_xu_ord_write_done | spr_xu_ord_read_done | xu_slowspr_val_in;

   assign ex1_ord_capt                 = |(ex1_ord_val_q);

   assign ord_instr_d            = ex1_instr_q;
   assign ord_mtiar_d            = ((ex2_ord_valid          & ex2_is_mtiar_q)       | ord_mtiar_q        ) & ~ex1_ord_capt;
   assign ord_tlb_miss_d         = ((mm_xu_tlb_miss         & mmu_ord_itag_match)   | ord_tlb_miss_q     ) & ~ex1_ord_capt;
   assign ord_lrat_miss_d        = ((mm_xu_lrat_miss        & mmu_ord_itag_match)   | ord_lrat_miss_q    ) & ~ex1_ord_capt;
   assign ord_tlb_inelig_d       = ((mm_xu_tlb_inelig       & mmu_ord_itag_match)   | ord_tlb_inelig_q   ) & ~ex1_ord_capt;
   assign ord_pt_fault_d         = ((mm_xu_pt_fault         & mmu_ord_itag_match)   | ord_pt_fault_q     ) & ~ex1_ord_capt;
   assign ord_hv_priv_d          = ((mm_xu_hv_priv          & mmu_ord_itag_match)   | ord_hv_priv_q      ) & ~ex1_ord_capt;
   assign ord_illeg_mmu_d        = (mm_xu_illeg_instr                               | ord_illeg_mmu_q    ) & ~ex1_ord_capt;
   assign ord_lq_flush_d         = (lq_xu_ord_n_flush_req                           | ord_lq_flush_q     ) & ~ex1_ord_capt;
   assign ord_spr_priv_d         = ((spr_dec_ex4_spr_priv   & spr_ord_done)         | ord_spr_priv_q     ) & ~ex1_ord_capt;
   assign ord_spr_illegal_spr_d  = ((spr_dec_ex4_spr_illeg  & spr_ord_done)         |
                                    (ex2_ord_valid          & ex2_illegal_op_q)     | ord_spr_illegal_spr_q) & ~ex1_ord_capt;
   assign ord_hyp_priv_spr_d     = ((spr_dec_ex4_spr_hypv   & spr_ord_done)         | ord_hyp_priv_spr_q ) & ~ex1_ord_capt;
   assign ord_ex3_np1_flush_d    = ((spr_dec_ex4_np1_flush  & spr_ord_done)         | ord_ex3_np1_flush_q) & ~ex1_ord_capt;
   assign ord_ill_tlb_d          = ((ex2_ord_valid          & ex2_tlb_illeg_q)      | ord_ill_tlb_q      ) & ~ex1_ord_capt;
   assign ord_priv_d             = ((ex2_ord_valid          & ex2_priv_excep_q)     | ord_priv_q         ) & ~ex1_ord_capt;
   assign ord_hyp_priv_d         = ((ex2_ord_valid          & ex2_hyp_priv_excep_q) | ord_hyp_priv_q     ) & ~ex1_ord_capt;

   assign ord_ierat_par_err_d    = (((iu_xu_ord_read_done | iu_xu_ord_write_done) & iu_xu_ord_par_err)        | ord_ierat_par_err_q)     & ~ex1_ord_capt;
   assign ord_derat_par_err_d    = (((lq_xu_ord_read_done | lq_xu_ord_write_done) & lq_xu_ord_par_err)        | ord_derat_par_err_q)     & ~ex1_ord_capt;
   assign ord_tlb_multihit_d     = ((mmu_ord_itag_match                           & mm_xu_tlb_multihit)       | ord_tlb_multihit_q)      & ~ex1_ord_capt;
   assign ord_tlb_par_err_d      = ((mmu_ord_itag_match                           & mm_xu_tlb_par_err)        | ord_tlb_par_err_q)       & ~ex1_ord_capt;
   assign ord_tlb_lru_par_err_d  = ((mmu_ord_itag_match                           & mm_xu_lru_par_err)        | ord_tlb_lru_par_err_q)   & ~ex1_ord_capt;
   assign ord_local_snoop_reject_d=((mmu_ord_itag_match                           & mm_xu_local_snoop_reject) | ord_local_snoop_reject_q)& ~ex1_ord_capt;


   // Don't hold the lq off for core-blocker instructions
   assign ord_hold_lq_d       = ((mmu_ord_n_flush_req_q[0]  & ~ord_core_block_q)    | ord_hold_lq_q      ) & ~ex1_ord_capt & ord_outstanding_q;

   assign mmu_error     = (mm_xu_tlb_miss | mm_xu_lrat_miss | mm_xu_tlb_inelig | mm_xu_pt_fault | mm_xu_hv_priv | mm_xu_illeg_instr) & mmu_ord_itag_match;

   assign mmu_ord_n_flush_req_d  = {(mm_xu_ord_n_flush_req & mmu_ord_itag_match & ord_outstanding_q), mmu_ord_n_flush_req_q[0]};
   assign iu_ord_n_flush_req_d   = {(iu_xu_ord_n_flush_req                      & ord_outstanding_q), iu_ord_n_flush_req_q[0]};
   assign lq_ord_n_flush_req_d   = {(lq_xu_ord_n_flush_req                      & ord_outstanding_q), lq_ord_n_flush_req_q[0]};

   assign ord_outstanding_act = (|ex1_ord_val_q) | ord_outstanding_q | ex1_ord_complete_q |
                                                                       ex2_ord_complete_q |
                                                                       ex3_ord_complete_q |
                                                                       ex4_ord_complete_q |
                                                                       ex5_ord_complete_q |
                                                                       ex6_ord_complete_q ;

   assign ord_outstanding_d = (ex1_ord_valid | ord_outstanding_q) & ~(ex0_ord_complete | ord_flush);

   assign ord_done_d          = ((ord_outstanding_q & (ord_write_gpr | ord_read_gpr | ord_other)) | ord_done_q) & ~ex0_ord_complete & ~cp_flush_ord;

   assign ord_flushed_d       = (~ex1_ord_valid & ord_flushed_q) | (ord_flush & ord_outstanding_q);

   assign ord_async_done      = ~(|(ord_async_flush_before_q | ord_async_flush_after_q) | ord_async_credit_wait_q);

   assign ord_waiting         = ord_outstanding_q & ord_done_q & ord_async_done;

   assign ord_timer_d         = ord_waiting ? (ord_timer_q + 6'd1) : 6'd0;

   assign ord_timeout_d[0]    = ord_timer_q == 6'b111111;
   assign ord_timeout_d[1]    = ord_timeout_q[0];

   assign xu0_rv_hold_all     = |ord_timeout_q;

   assign ex0_ord_complete    = ord_waiting & ~|ex0_val_q & ~ex0_mul_insert & ~cp_flush_ord;
   assign ex1_ord_complete    = ex1_ord_complete_q & ~cp_flush_ord_tid;
   assign ex2_ord_complete    = ex2_ord_complete_q & ~cp_flush_ord_tid;
   assign ex3_ord_complete    = ex3_ord_complete_q & ~cp_flush_ord_tid;
   assign ex4_ord_complete    = ex4_ord_complete_q & ~cp_flush_ord_tid;
   assign ex5_ord_complete    = ex5_ord_complete_q & ~cp_flush_ord_tid;
   assign ex6_ord_complete    = ex6_ord_complete_q & ~cp_flush_ord_tid;

   assign ord_other           = ord_ill_tlb_q | ord_priv_q | ord_hyp_priv_q | ord_illeg_mmu_q | ord_ierat_par_err_q |
                                ord_derat_par_err_q | ord_tlb_multihit_q | ord_tlb_par_err_q | ord_tlb_lru_par_err_q | ord_local_snoop_reject_q;

   assign ord_write_gpr =   ((xu_slowspr_val_in & xu_slowspr_rw_in) |                        // SlowSPR Read
                              spr_xu_ord_write_done |                                        // FastSPR Read
                              iu_xu_ord_read_done |                                          // IU IERAT read
                              lq_xu_ord_read_done |                                          // LQ DERAT read
                             (mm_xu_ord_read_done & (~mm_xu_ord_n_flush_req | mmu_error)) |  // MMU read
                              div_dec_ex4_done |                                             // Divide
                              mul_dec_ex6_ord_done                                           // Mult
                                                   ) & ~cp_flush_ord_tid;

   assign ord_read_gpr =    ((xu_slowspr_val_in & ~xu_slowspr_rw_in) |                       // SlowSPR Write
                              spr_xu_ord_read_done |                                         // FastSPR Write
                              iu_xu_ord_write_done |                                         // IU IERAT Write
                             (mm_xu_ord_write_done & (~mm_xu_ord_n_flush_req | mmu_error)) | // MMU read
                              lq_xu_ord_write_done |                                         // LQ DERAT Write
                              lq_xu_ord_n_flush_req |                                        //
                              |xu_iu_pri_val_int                                             //
                                                   ) & ~cp_flush_ord_tid;


   assign dec_byp_ex1_rs_capt = ex1_ord_q | (|ex2_ord_val_q & ex2_is_erativax_q);
   assign dec_byp_ex1_ra_capt = ex1_ord_q;
   assign dec_byp_ex5_ord_sel = ex5_ord_complete_q;

   assign xu0_rv_ord_complete = ex2_ord_complete;
   assign xu0_rv_ord_itag     = ex2_ord_itag_q;

   assign ex3_hpriv           = |(ex3_excep_cond[9:11]);
   assign dec_byp_ex4_hpriv   = ex4_hpriv_q;
   assign dec_byp_ex4_instr   = (ex4_instr_q & {32{~ex4_ord_complete}}) |
                                (ord_instr_q & {32{ ex4_ord_complete}});

   // TLB Parity Error                             0
   // TLB LRU Parity                               1
   // TLB Multihit                                 2
   // IERAT parity                                 3
   // DERAT parity                                 4
   // Program XU sourced illegal instruction type  5
   // Program SPR sourced illegal SPR              6
   // Program SPR sourced priviledged SPR          7
   // Program XU sourced priviledged instruction   8
   // Hypervisor Priviledge Priviledged SPR        9
   // Hypervisor Priviledge ehpriv instruction     10
   // Hypervisor Priviledge XU sourced priviledged 11
   // TLB Ineligile                                12
   // MMU illegal Mas                              13
   // Program Trap Instruction                     14
   // LRAT Miss                                    15

   assign ex3_excep_cond[0] = ex3_ord_complete     & ord_tlb_par_err_q;
   assign ex3_excep_cond[1] = ex3_ord_complete     & ord_tlb_lru_par_err_q;
   assign ex3_excep_cond[2] = ex3_ord_complete     & ord_tlb_multihit_q;
   assign ex3_excep_cond[3] = ex3_ord_complete     & ord_ierat_par_err_q;
   assign ex3_excep_cond[4] = ex3_ord_complete     & ord_derat_par_err_q;
   assign ex3_excep_cond[5] =(ex3_valid            & ex3_illegal_op_q) |
                             (ex3_ord_complete     & ord_ill_tlb_q);
   assign ex3_excep_cond[6] = ex3_ord_complete     & ord_spr_illegal_spr_q;
   assign ex3_excep_cond[7] =(ex3_valid            & ex3_priv_excep_q) |
                             (ex3_ord_complete     & ord_priv_q);
   assign ex3_excep_cond[8] = ex3_ord_complete     & ord_spr_priv_q;
   assign ex3_excep_cond[9] = ex3_ord_complete     & ord_hyp_priv_spr_q;
   assign ex3_excep_cond[10]= ex3_valid            & ex3_is_ehpriv_q;
   assign ex3_excep_cond[11]=(ex3_valid            & ex3_hyp_priv_excep_q) |
                             (ex3_ord_complete     & (ord_hyp_priv_q | ord_hv_priv_q));
   assign ex3_excep_cond[12]= ex3_ord_complete     & ord_tlb_inelig_q;
   assign ex3_excep_cond[13]= ex3_ord_complete     & ord_illeg_mmu_q;
   assign ex3_excep_cond[14]= ex3_valid            & alu_dec_ex3_trap_val;
   assign ex3_excep_cond[15]= ex3_ord_complete     & ord_lrat_miss_q;
   assign ex3_excep_cond[16]= ex3_ord_complete     & ord_local_snoop_reject_q;



   assign ex3_ord_np1_flush = ex3_ord_complete     & ord_ex3_np1_flush_q;

   tri_pri #(.SIZE(17)) excep_pri(
      .cond(ex3_excep_cond),
      .pri(ex3_excep_pri),
      .or_cond(ex3_excep_val)
   );

   assign ex3_excep_vector =  (5'd0  & {5{ex3_excep_pri[0]}}) |
                              (5'd1  & {5{ex3_excep_pri[1]}}) |
                              (5'd2  & {5{ex3_excep_pri[2]}}) |
                              (5'd3  & {5{ex3_excep_pri[3]}}) |
                              (5'd4  & {5{ex3_excep_pri[4]}}) |
                              (5'd5  & {5{ex3_excep_pri[5]}}) |
                              (5'd6  & {5{ex3_excep_pri[6]}}) |
                              (5'd7  & {5{ex3_excep_pri[7]}}) |
                              (5'd8  & {5{ex3_excep_pri[8]}}) |
                              (5'd9  & {5{ex3_excep_pri[9]}}) |
                              (5'd10 & {5{ex3_excep_pri[10]}})|
                              (5'd11 & {5{ex3_excep_pri[11]}})|
                              (5'd12 & {5{ex3_excep_pri[12]}})|
                              (5'd13 & {5{ex3_excep_pri[13]}})|
                              (5'd14 & {5{ex3_excep_pri[14]}})|
                              (5'd15 & {5{ex3_excep_pri[15]}})|
                              (5'd16 & {5{ex3_excep_pri[16]}});

   assign ex3_n_flush   = ex3_excep_val | ex3_flush2ucode;
   assign ex3_np1_flush = ex3_ord_np1_flush;

   assign ex2_flush2ucode = ex2_flush2ucode_q & ex2_ucode_q != 3'b010;
   assign ex3_flush2ucode = ex3_flush2ucode_q & ~ex3_ord_complete;

   assign xu0_iu_exception_val   = ex4_excep_val_q;
   assign xu0_iu_exception       = ex4_excep_vector_q;
   assign xu0_iu_n_flush         = ex4_n_flush_q;
   assign xu0_iu_np1_flush       = ex4_np1_flush_q;
   assign xu0_iu_flush2ucode     = ex4_flush2ucode_q;
   assign xu0_iu_perf_events       = ex4_perf_event_q;

   assign xu_iu_is_eratre        = ex2_ord_is_eratre_q;
   assign xu_iu_is_eratwe        = ex2_ord_is_eratwe_q;
   assign xu_iu_is_eratsx        = ex2_ord_is_eratsx_q;
   assign xu_iu_is_eratilx       = ex2_ord_is_eratilx_q;
   assign xu_iu_is_erativax      = ex2_ord_is_erativax_q;
   assign xu_iu_ws               = ex2_ord_tlb_ws_q;
   assign xu_iu_t                = ex2_ord_tlb_t_q;

   assign xu_lq_is_eratre        = ex2_ord_is_eratre_q;
   assign xu_lq_is_eratwe        = ex2_ord_is_eratwe_q;
   assign xu_lq_is_eratsx        = ex2_ord_is_eratsx_q;
   assign xu_lq_is_eratilx       = ex2_ord_is_eratilx_q;
   assign xu_lq_ws               = ex2_ord_tlb_ws_q;
   assign xu_lq_t                = ex2_ord_tlb_t_q;

   assign xu_mm_is_tlbre         = ex2_ord_is_tlbre_q;
   assign xu_mm_is_tlbwe         = ex2_ord_is_tlbwe_q;
   assign xu_mm_is_tlbsx         = ex2_ord_is_tlbsx_q;
   assign xu_mm_is_tlbsxr        = ex2_ord_is_tlbsxr_q;
   assign xu_mm_is_tlbsrx        = ex2_ord_is_tlbsrx_q;
   assign xu_mm_is_tlbivax       = ex2_ord_is_tlbivax_q;
   assign xu_mm_is_tlbilx        = ex2_ord_is_tlbilx_q;


   `ifdef THREADS1
   assign spr_mmucr0_tlbsel_d[0] = mm_xu_mmucr0_tlbsel_t0;

   assign ex0_tlbsel    =  ex0_val_q[0]==1'b1      ?  spr_mmucr0_tlbsel_q[0] :
                                                      2'b00;

   assign ex1_tlbsel    =  ex1_ord_val[0]==1'b1    ?  spr_mmucr0_tlbsel_q[0] :
                                                      2'b00;

   assign ex2_tlbsel    =  ex2_ord_tid_q[0]==1'b1  ?  spr_mmucr0_tlbsel_q[0] :
                                                      2'b00;

   `else
   assign spr_mmucr0_tlbsel_d[0] = mm_xu_mmucr0_tlbsel_t0;
   assign spr_mmucr0_tlbsel_d[1] = mm_xu_mmucr0_tlbsel_t1;

   assign ex0_tlbsel    =  ex0_val_q[1]==1'b1      ?  spr_mmucr0_tlbsel_q[1] :
                           ex0_val_q[0]==1'b1      ?  spr_mmucr0_tlbsel_q[0] :
                                                      2'b00;

   assign ex1_tlbsel    =  ex1_ord_val[1]==1'b1    ?  spr_mmucr0_tlbsel_q[1] :
                           ex1_ord_val[0]==1'b1    ?  spr_mmucr0_tlbsel_q[0] :
                                                      2'b00;

   assign ex2_tlbsel    =  ex2_ord_tid_q[1]==1'b1  ?  spr_mmucr0_tlbsel_q[1] :
                           ex2_ord_tid_q[0]==1'b1  ?  spr_mmucr0_tlbsel_q[0] :
                                                      2'b00;
   `endif


   //-------------------------------------------------------------------------
   // Write Enables
   //-------------------------------------------------------------------------

   assign ex5_t1_v   = (ex5_ord_complete_q == 1'b1) ? ex5_ord_t1_v_q : ex5_t1_v_q;
   assign ex5_t1_t   = (ex5_ord_complete_q == 1'b1) ? ex5_ord_t1_t_q : ex5_t1_t_q;
   assign ex5_t1_p   = (ex5_ord_complete_q == 1'b1) ? ex5_ord_t1_p_q : ex5_t1_p_q;
   assign ex5_t2_v   = (ex5_ord_complete_q == 1'b1) ? ex5_ord_t2_v_q : ex5_t2_v_q;
   assign ex5_t2_t   = (ex5_ord_complete_q == 1'b1) ? ex5_ord_t2_t_q : ex5_t2_t_q;
   assign ex5_t2_p   = (ex5_ord_complete_q == 1'b1) ? ex5_ord_t2_p_q : ex5_t2_p_q;
   assign ex5_t3_v   = (ex5_ord_complete_q == 1'b1) ? ex5_ord_t3_v_q : ex5_t3_v_q;
   assign ex5_t3_t   = (ex5_ord_complete_q == 1'b1) ? ex5_ord_t3_t_q : ex5_t3_t_q;
   assign ex5_t3_p   = (ex5_ord_complete_q == 1'b1) ? ex5_ord_t3_p_q : ex5_t3_p_q;
   assign ex3_itag   = (ex3_ord_complete   == 1'b1) ? ex2_ord_itag_q : ex3_itag_q;
   assign ex6_tid_d  = (ex5_ord_complete_q == 1'b1) ? ex2_ord_tid_q  : ex5_val_q;

   assign ex5_cr1_we = ex5_t1_v & (ex5_t1_t == `cr_t);
   assign ex5_cr3_we = ex5_t3_v & (ex5_t3_t == `cr_t);

   assign ex5_cr_we  = (ex5_valid | ex5_ord_complete) & (ex5_cr1_we | ex5_cr3_we);
   assign ex5_gpr_we = (ex5_valid | ex5_ord_complete) & ex5_t1_v & (ex5_t1_t == `gpr_t);
   assign ex5_xer_we = (ex5_valid | ex5_ord_complete) & ex5_t2_v & (ex5_t2_t == `xer_t);

   assign ex3_ctr_we = ex3_valid & ex3_t2_v_q & (ex3_t2_t_q == `ctr_t);
   assign ex3_lr_we  = ex3_valid & ex3_t3_v_q & (ex3_t3_t_q == `lr_t);

   assign ex5_cr_wa  = (ex5_t1_p[`GPR_POOL_ENC-`CR_POOL_ENC:`GPR_POOL_ENC-1] & {`CR_POOL_ENC{ex5_cr1_we}}) |
                       (ex5_t3_p[`GPR_POOL_ENC-`CR_POOL_ENC:`GPR_POOL_ENC-1] & {`CR_POOL_ENC{ex5_cr3_we}});

   assign xu0_gpr_ex6_we   = ex6_gpr_we_q;
   assign xu0_xer_ex6_we   = ex6_xer_we_q;
   assign xu0_cr_ex6_we    = ex6_cr_we_q;
   assign xu0_ctr_ex4_we   = ex4_ctr_we_q;
   assign xu0_lr_ex4_we    = ex4_lr_we_q;

   assign xu0_iu_mtiar_d[0] = ex2_ord_tid_q[0] & ex3_ord_complete & ord_mtiar_q;
   `ifdef THREADS1
      assign xu0_gpr_ex6_wa   =  ex6_t1_p_q[0:`GPR_POOL_ENC-1];
      assign xu0_xer_ex6_wa   =  ex6_t2_p_q[`GPR_POOL_ENC-`XER_POOL_ENC:`GPR_POOL_ENC-1];
      assign xu0_cr_ex6_wa    =  ex6_cr_wa_q[`GPR_POOL_ENC-`CR_POOL_ENC:`GPR_POOL_ENC-1];
      assign xu0_ctr_ex4_wa   =  ex4_t2_p_q[`GPR_POOL_ENC-`CTR_POOL_ENC:`GPR_POOL_ENC-1];
      assign xu0_lr_ex4_wa    =  ex4_t3_p_q[`GPR_POOL_ENC-`BR_POOL_ENC:`GPR_POOL_ENC-1];
   `else
      assign xu0_gpr_ex6_wa   = {ex6_t1_p_q[0:`GPR_POOL_ENC-1]                            ,ex6_tid_q[1]};
      assign xu0_xer_ex6_wa   = {ex6_t2_p_q[`GPR_POOL_ENC-`XER_POOL_ENC:`GPR_POOL_ENC-1]  ,ex6_tid_q[1]};
      assign xu0_cr_ex6_wa    = {ex6_cr_wa_q[`GPR_POOL_ENC-`CR_POOL_ENC:`GPR_POOL_ENC-1]  ,ex6_tid_q[1]};
      assign xu0_ctr_ex4_wa   = {ex4_t2_p_q[`GPR_POOL_ENC-`CTR_POOL_ENC:`GPR_POOL_ENC-1]  ,ex4_val_q[1]};
      assign xu0_lr_ex4_wa    = {ex4_t3_p_q[`GPR_POOL_ENC-`BR_POOL_ENC:`GPR_POOL_ENC-1]   ,ex4_val_q[1]};
      assign xu0_iu_mtiar_d[1] = ex2_ord_tid_q[1] & ex3_ord_complete & ord_mtiar_q;
   `endif


   assign xu0_iu_execute_vld  = (ex4_val | (ex2_ord_tid_q & {`THREADS{ex4_ord_complete}})) & ~ex4_br_val_q;
   assign xu0_iu_itag         = ex4_itag_q;

   assign xu0_iu_mtiar     = xu0_iu_mtiar_q;

   assign ex6_ram_active_d = |(ex6_tid_d & pc_xu_ram_active);

   assign xu0_pc_ram_done  = (ex6_valid | ex6_ord_complete) & ex6_ram_active_q;

   //-------------------------------------------------------------------------
   // Perf Events
   //-------------------------------------------------------------------------
   assign ex1_any_mfspr    = ex1_is_mfspr | ex1_is_mfmsr | ex1_is_mftb | ex1_is_mfcr;
   assign ex1_any_mtspr    = ex1_is_mtspr | ex1_is_mtmsr |               ex1_is_mtcrf | ex1_is_wrtee | ex1_is_wrteei;

   assign ex2_any_mfspr    = ex2_ord_complete_q ? ord_any_mfspr_q : ex2_any_mfspr_q;
   assign ex2_any_mtspr    = ex2_ord_complete_q ? ord_any_mtspr_q : ex2_any_mtspr_q;

   assign ex3_tid          = (ex3_val_q | (ex2_ord_tid_q & {`THREADS{ex3_ord_complete_q}}));

   generate begin : perf_event
      genvar  t,e;
      for (e=0;e<=3;e=e+1) begin : thread
         for (t=0;t<=`THREADS-1;t=t+1) begin : thread
            assign ex3_perf_event[e]           = (spr_xesr1[4*e+16*t:4*e+16*t+3] == 4'd10 ? (ex3_tid[t] & perf_event_en[t] & ex3_any_mfspr_q) : 1'b0) |
                                                 (spr_xesr1[4*e+16*t:4*e+16*t+3] == 4'd11 ? (ex3_tid[t] & perf_event_en[t] & ex3_any_mtspr_q) : 1'b0) ;
         end
      end
   end
   endgenerate

   //-------------------------------------------------------------------------
   // Decode
   //-------------------------------------------------------------------------

   assign ex0_instr[0:5] = (rv_xu0_ex0_fusion[0:2] == 3'b100)  ?  6'b011111 :
                           (rv_xu0_ex0_fusion[0:2] == 3'b101)  ?  6'b001011 :
                           (rv_xu0_ex0_fusion[0:2] == 3'b110)  ?  6'b011111 :
                           (rv_xu0_ex0_fusion[0:2] == 3'b111)  ?  6'b001010 :
                                                                  rv_xu0_ex0_instr[0:5];

   assign ex0_instr[6:9] = (rv_xu0_ex0_fusion[0] == 1'b1)      ?  4'b0000 :
                                                                  rv_xu0_ex0_instr[6:9];

   assign ex0_instr[10]    = (rv_xu0_ex0_fusion[0] == 1'b1)    ?  rv_xu0_ex0_fusion[3] :
                                                                  rv_xu0_ex0_instr[10];

   assign ex0_instr[11:15] = (rv_xu0_ex0_fusion[0] == 1'b1)    ?  5'b00000 :
                                                                  rv_xu0_ex0_instr[11:15];

   assign ex0_instr[16:20] = (rv_xu0_ex0_fusion[0:2] == 3'b100) ? 5'b00000 :
                             (rv_xu0_ex0_fusion[0:2] == 3'b101) ? rv_xu0_ex0_fusion[4:8] :
                             (rv_xu0_ex0_fusion[0:2] == 3'b110) ? 5'b00000 :
                             (rv_xu0_ex0_fusion[0:2] == 3'b111) ? rv_xu0_ex0_fusion[4:8] :
                                                                  rv_xu0_ex0_instr[16:20];

   assign ex0_instr[21:30] = (rv_xu0_ex0_fusion[0:2] == 3'b100) ? 10'b0000000000 :
                             (rv_xu0_ex0_fusion[0:2] == 3'b101) ? rv_xu0_ex0_fusion[9:18] :
                             (rv_xu0_ex0_fusion[0:2] == 3'b110) ? 10'b0000100000 :
                             (rv_xu0_ex0_fusion[0:2] == 3'b111) ? rv_xu0_ex0_fusion[9:18] :
                                                                  rv_xu0_ex0_instr[21:30];

   // Kill the opcode31 if fusion is on, so I don't get a false decode.
   assign ex0_instr[31] = (rv_xu0_ex0_fusion[0:2] == 3'b100) ? 1'b0 :
                          (rv_xu0_ex0_fusion[0:2] == 3'b101) ? rv_xu0_ex0_fusion[19] :
                          (rv_xu0_ex0_fusion[0:2] == 3'b110) ? 1'b0 :
                          (rv_xu0_ex0_fusion[0:2] == 3'b111) ? rv_xu0_ex0_fusion[19] :
                                                               rv_xu0_ex0_instr[31];

   assign ex0_opcode_is_31 = (rv_xu0_ex0_instr[0:5] == 6'b011111) & (rv_xu0_ex0_fusion[0] == 1'b0);
   assign ex0_opcode_is_19 = (rv_xu0_ex0_instr[0:5] == 6'b010011);

   assign ex0_is_b         = (                     rv_xu0_ex0_instr[0:5]    == 6'b010010)       ? 1'b1 : 1'b0;
   assign ex0_is_bc        = (                     ex0_instr[0:5]           == 6'b010000)       ? 1'b1 : 1'b0;
   assign ex0_is_addi      = (                     rv_xu0_ex0_instr[0:5]    == 6'b001110)       ? 1'b1 : 1'b0;
   assign ex0_is_addic     = (                     rv_xu0_ex0_instr[0:5]    == 6'b001100)       ? 1'b1 : 1'b0;
   assign ex0_is_addicr    = (                     rv_xu0_ex0_instr[0:5]    == 6'b001101)       ? 1'b1 : 1'b0;
   assign ex0_is_addme     = (ex0_opcode_is_31  &  rv_xu0_ex0_instr[22:30]  == 9'b011101010)    ? 1'b1 : 1'b0;
   assign ex0_is_addis     = (                     rv_xu0_ex0_instr[0:5]    == 6'b001111)       ? 1'b1 : 1'b0;
   assign ex0_is_addze     = (ex0_opcode_is_31  &  rv_xu0_ex0_instr[22:30]  == 9'b011001010)    ? 1'b1 : 1'b0;
   assign ex0_is_andir     = (                     rv_xu0_ex0_instr[0:5]    == 6'b011100)       ? 1'b1 : 1'b0;
   assign ex0_is_andisr    = (                     rv_xu0_ex0_instr[0:5]    == 6'b011101)       ? 1'b1 : 1'b0;
   assign ex0_is_cmpi      = (                     ex0_instr[0:5]           == 6'b001011)       ? 1'b1 : 1'b0;
   assign ex0_is_cmpli     = (                     ex0_instr[0:5]           == 6'b001010)       ? 1'b1 : 1'b0;
   assign ex0_is_mulli     = (                     rv_xu0_ex0_instr[0:5]    == 6'b000111)       ? 1'b1 : 1'b0;
   assign ex0_is_neg       = (ex0_opcode_is_31  &  rv_xu0_ex0_instr[22:30]  == 9'b001101000)    ? 1'b1 : 1'b0;
   assign ex0_is_ori       = (                     rv_xu0_ex0_instr[0:5]    == 6'b011000)       ? 1'b1 : 1'b0;
   assign ex0_is_oris      = (                     rv_xu0_ex0_instr[0:5]    == 6'b011001)       ? 1'b1 : 1'b0;
   assign ex0_is_subfic    = (                     rv_xu0_ex0_instr[0:5]    == 6'b001000)       ? 1'b1 : 1'b0;
   assign ex0_is_subfze    = (ex0_opcode_is_31  &  rv_xu0_ex0_instr[22:30]  == 9'b011001000)    ? 1'b1 : 1'b0;
   assign ex0_is_twi       = (                     rv_xu0_ex0_instr[0:5]    == 6'b000011)       ? 1'b1 : 1'b0;
   assign ex0_is_tdi       = (                     rv_xu0_ex0_instr[0:5]    == 6'b000010)       ? 1'b1 : 1'b0;
   assign ex0_is_xori      = (                     rv_xu0_ex0_instr[0:5]    == 6'b011010)       ? 1'b1 : 1'b0;
   assign ex0_is_xoris     = (                     rv_xu0_ex0_instr[0:5]    == 6'b011011)       ? 1'b1 : 1'b0;
   assign ex0_is_subfme    = (ex0_opcode_is_31  &  rv_xu0_ex0_instr[22:30]  == 9'b011101000)    ? 1'b1 : 1'b0;
   assign ex0_is_mtcrf     = (ex0_opcode_is_31  &  rv_xu0_ex0_instr[21:30] == 10'b0010010000)   ? 1'b1 : 1'b0;
   assign ex0_is_mtmsr     = (ex0_opcode_is_31  &  rv_xu0_ex0_instr[21:30] == 10'b0010010010)   ? 1'b1 : 1'b0;
   assign ex0_is_mtspr     = (ex0_opcode_is_31  &  rv_xu0_ex0_instr[21:30] == 10'b0111010011)   ? 1'b1 : 1'b0;
   assign ex0_is_wrtee     = (ex0_opcode_is_31  &  rv_xu0_ex0_instr[21:30] == 10'b0010000011)   ? 1'b1 : 1'b0;
   assign ex0_is_wrteei    = (ex0_opcode_is_31  &  rv_xu0_ex0_instr[21:30] == 10'b0010100011)   ? 1'b1 : 1'b0;
   assign ex0_is_eratwe    = (ex0_opcode_is_31  &  rv_xu0_ex0_instr[21:30] == 10'b0011010011)   ? 1'b1 : 1'b0;
   assign ex0_is_erativax  = (ex0_opcode_is_31  &  rv_xu0_ex0_instr[21:30] == 10'b1100110011)   ? 1'b1 : 1'b0;
   assign ex0_is_eratsx    = (ex0_opcode_is_31  &  rv_xu0_ex0_instr[21:30] == 10'b0010010011)   ? 1'b1 : 1'b0;

   assign ex1_opcode_is_0  = ex1_instr_q[0:5] == 6'b000000;
   assign ex1_opcode_is_19 = ex1_instr_q[0:5] == 6'b010011;
   assign ex1_opcode_is_31 = ex1_instr_q[0:5] == 6'b011111;

   assign ex1_is_add       = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b100001010)             ? 1'b1 : 1'b0;
   assign ex1_is_addc      = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b000001010)             ? 1'b1 : 1'b0;
   assign ex1_is_adde      = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b010001010)             ? 1'b1 : 1'b0;
   assign ex1_is_addi      = (                     ex1_instr_q[0:5]     ==  6'b001110)                ? 1'b1 : 1'b0;
   assign ex1_is_addic     = (                     ex1_instr_q[0:5]     ==  6'b001100)                ? 1'b1 : 1'b0;
   assign ex1_is_addicr    = (                     ex1_instr_q[0:5]     ==  6'b001101)                ? 1'b1 : 1'b0;
   assign ex1_is_addis     = (                     ex1_instr_q[0:5]     ==  6'b001111)                ? 1'b1 : 1'b0;
   assign ex1_is_addme     = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b011101010)             ? 1'b1 : 1'b0;
   assign ex1_is_addze     = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b011001010)             ? 1'b1 : 1'b0;
   assign ex1_is_andir     = (                     ex1_instr_q[0:5]     ==  6'b011100)                ? 1'b1 : 1'b0;
   assign ex1_is_andisr    = (                     ex1_instr_q[0:5]     ==  6'b011101)                ? 1'b1 : 1'b0;
   assign ex1_is_addg6s    = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b001001010)             ? 1'b1 : 1'b0;
   assign ex1_is_attn      = (ex1_opcode_is_0   &  ex1_instr_q[21:30]   == 10'b0100000000)            ? 1'b1 : 1'b0;
   assign ex1_is_bc        = (                     ex1_instr_q[0:5]     ==  6'b010000)                ? 1'b1 : 1'b0;
   assign ex1_is_bpermd    = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0011111100)            ? 1'b1 : 1'b0;
   assign ex1_is_cdtbcd    = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0100011010)            ? 1'b1 : 1'b0;
   assign ex1_is_cbcdtd    = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0100111010)            ? 1'b1 : 1'b0;
   assign ex1_is_cmp       = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0000000000)            ? 1'b1 : 1'b0;
   assign ex1_is_cmpi      = (                     ex1_instr_q[0:5]     ==  6'b001011)                ? 1'b1 : 1'b0;
   assign ex1_is_cmpl      = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0000100000)            ? 1'b1 : 1'b0;
   assign ex1_is_cmpli     = (                     ex1_instr_q[0:5]     ==  6'b001010)                ? 1'b1 : 1'b0;
   assign ex1_is_cntlzw    = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0000011010)            ? 1'b1 : 1'b0;
   assign ex1_is_cntlzd    = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0000111010)            ? 1'b1 : 1'b0;
   assign ex1_is_divd      = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b111101001)             ? 1'b1 : 1'b0;
   assign ex1_is_divdu     = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b111001001)             ? 1'b1 : 1'b0;
   assign ex1_is_divw      = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b111101011)             ? 1'b1 : 1'b0;
   assign ex1_is_divwu     = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b111001011)             ? 1'b1 : 1'b0;
   assign ex1_is_divwe     = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b110101011)             ? 1'b1 : 1'b0;
   assign ex1_is_divweu    = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b110001011)             ? 1'b1 : 1'b0;
   assign ex1_is_divde     = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b110101001)             ? 1'b1 : 1'b0;
   assign ex1_is_divdeu    = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b110001001)             ? 1'b1 : 1'b0;
   assign ex1_is_dlmzb     = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b001001110)             ? 1'b1 : 1'b0;
   assign ex1_is_dnh       = (ex1_opcode_is_19  &  ex1_instr_q[21:30]   == 10'b0011000110)            ? 1'b1 : 1'b0;
   assign ex1_is_ehpriv    = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0100001110)            ? 1'b1 : 1'b0;
   assign ex1_is_eratilx   = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0000110011)            ? 1'b1 : 1'b0;
   assign ex1_is_erativax  = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b1100110011)            ? 1'b1 : 1'b0;
   assign ex1_is_eratre    = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0010110011)            ? 1'b1 : 1'b0;
   assign ex1_is_eratsx    = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0010010011)            ? 1'b1 : 1'b0;
   assign ex1_is_eratwe    = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0011010011)            ? 1'b1 : 1'b0;
   assign ex1_is_isel      = (ex1_opcode_is_31  &  ex1_instr_q[26:30]   ==  5'b01111)                 ? 1'b1 : 1'b0;
   assign ex1_is_mtxer     = (ex1_opcode_is_31  &  ex1_instr_q[11:30]   == 20'b00001000000111010011)  ? 1'b1 : 1'b0;
   assign ex1_is_mfxer     = (ex1_opcode_is_31  &  ex1_instr_q[11:30]   == 20'b00001000000101010011)  ? 1'b1 : 1'b0;
   assign ex1_is_mflr      = (ex1_opcode_is_31  &  ex1_instr_q[11:30]   == 20'b01000000000101010011)  ? 1'b1 : 1'b0;
   assign ex1_is_mftar     = (ex1_opcode_is_31  &  ex1_instr_q[11:30]   == 20'b01111110010101010011)  ? 1'b1 : 1'b0;
   assign ex1_is_mfctr     = (ex1_opcode_is_31  &  ex1_instr_q[11:30]   == 20'b01001000000101010011)  ? 1'b1 : 1'b0;
   assign ex1_is_msgclr    = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0011101110)            ? 1'b1 : 1'b0;
   assign ex1_is_mtiar     = (ex1_opcode_is_31  &  ex1_instr_q[11:30]   == 20'b10010110110111010011)  ? 1'b1 : 1'b0;
   assign ex1_is_mfcr      = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0000010011)            ? 1'b1 : 1'b0;
   assign ex1_is_mtcrf     = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0010010000)            ? 1'b1 : 1'b0;
   assign ex1_is_mtmsr     = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0010010010)            ? 1'b1 : 1'b0;
   assign ex1_is_mtspr     = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0111010011)            ? 1'b1 : 1'b0;
   assign ex1_is_mulhd     = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b001001001)             ? 1'b1 : 1'b0;
   assign ex1_is_mulhdu    = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b000001001)             ? 1'b1 : 1'b0;
   assign ex1_is_mulhw     = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b001001011)             ? 1'b1 : 1'b0;
   assign ex1_is_mulhwu    = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b000001011)             ? 1'b1 : 1'b0;
   assign ex1_is_mulld     = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0011101001)            ? 1'b1 : 1'b0;
   assign ex1_is_mulldo    = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b1011101001)            ? 1'b1 : 1'b0;
   assign ex1_is_mulli     = (                     ex1_instr_q[0:5]     ==  6'b000111)                ? 1'b1 : 1'b0;
   assign ex1_is_mullw     = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b011101011)             ? 1'b1 : 1'b0;
   assign ex1_is_neg       = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b001101000)             ? 1'b1 : 1'b0;
   assign ex1_is_ori       = (                     ex1_instr_q[0:5]     ==  6'b011000)                ? 1'b1 : 1'b0;
   assign ex1_is_oris      = (                     ex1_instr_q[0:5]     ==  6'b011001)                ? 1'b1 : 1'b0;
   assign ex1_is_popcntb   = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0001111010)            ? 1'b1 : 1'b0;
   assign ex1_is_popcntw   = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0101111010)            ? 1'b1 : 1'b0;
   assign ex1_is_popcntd   = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0111111010)            ? 1'b1 : 1'b0;
   assign ex1_is_srad      = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b1100011010)            ? 1'b1 : 1'b0;
   assign ex1_is_sradi     = (ex1_opcode_is_31  &  ex1_instr_q[21:29]   ==  9'b110011101)             ? 1'b1 : 1'b0;
   assign ex1_is_sraw      = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b1100011000)            ? 1'b1 : 1'b0;
   assign ex1_is_srawi     = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b1100111000)            ? 1'b1 : 1'b0;
   assign ex1_is_subf      = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b000101000)             ? 1'b1 : 1'b0;
   assign ex1_is_subfc     = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b000001000)             ? 1'b1 : 1'b0;
   assign ex1_is_subfe     = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b010001000)             ? 1'b1 : 1'b0;
   assign ex1_is_subfic    = (                     ex1_instr_q[0:5]     ==  6'b001000)                ? 1'b1 : 1'b0;
   assign ex1_is_subfme    = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b011101000)             ? 1'b1 : 1'b0;
   assign ex1_is_subfze    = (ex1_opcode_is_31  &  ex1_instr_q[22:30]   ==  9'b011001000)             ? 1'b1 : 1'b0;
   assign ex1_is_tlbilx    = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0000010010)            ? 1'b1 : 1'b0;
   assign ex1_is_tlbivax   = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b1100010010)            ? 1'b1 : 1'b0;
   assign ex1_is_tlbre     = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b1110110010)            ? 1'b1 : 1'b0;
   assign ex1_is_tlbsx     = (ex1_opcode_is_31  &  ex1_instr_q[21:31]   == 11'b11100100100)           ? 1'b1 : 1'b0;
   assign ex1_is_tlbsxr    = (ex1_opcode_is_31  &  ex1_instr_q[21:31]   == 11'b11100100101)           ? 1'b1 : 1'b0;
   assign ex1_is_tlbsrx    = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b1101010010)            ? 1'b1 : 1'b0;
   assign ex1_is_tlbwe     = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b1111010010)            ? 1'b1 : 1'b0;
   assign ex1_is_td        = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0001000100)            ? 1'b1 : 1'b0;
   assign ex1_is_tdi       = (                     ex1_instr_q[0:5]     ==  6'b000010)                ? 1'b1 : 1'b0;
   assign ex1_is_tw        = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0000000100)            ? 1'b1 : 1'b0;
   assign ex1_is_twi       = (                     ex1_instr_q[0:5]     ==  6'b000011)                ? 1'b1 : 1'b0;
   assign ex1_is_wrtee     = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0010000011)            ? 1'b1 : 1'b0;
   assign ex1_is_wrteei    = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0010100011)            ? 1'b1 : 1'b0;
   assign ex1_is_xori      = (                     ex1_instr_q[0:5]     ==  6'b011010)                ? 1'b1 : 1'b0;
   assign ex1_is_xoris     = (                     ex1_instr_q[0:5]     ==  6'b011011)                ? 1'b1 : 1'b0;
   assign ex1_is_mfspr     = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0101010011)            ? 1'b1 : 1'b0; // 31/339
   assign ex1_is_mfmsr     = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0001010011)            ? 1'b1 : 1'b0; // 31/083
   assign ex1_is_mftb      = (ex1_opcode_is_31  &  ex1_instr_q[21:30]   == 10'b0101110011)            ? 1'b1 : 1'b0; // 31/371


   assign ex1_is_pri1 = (ex1_opcode_is_31 & ex1_instr_q[6:31] == 26'b11111111111111101101111000)      ? 1'b1 : 1'b0;
   assign ex1_is_pri2 = (ex1_opcode_is_31 & ex1_instr_q[6:31] == 26'b00001000010000101101111000)      ? 1'b1 : 1'b0;
   assign ex1_is_pri3 = (ex1_opcode_is_31 & ex1_instr_q[6:31] == 26'b00110001100011001101111000)      ? 1'b1 : 1'b0;
   assign ex1_is_pri4 = (ex1_opcode_is_31 & ex1_instr_q[6:31] == 26'b00010000100001001101111000)      ? 1'b1 : 1'b0;
   assign ex1_is_pri5 = (ex1_opcode_is_31 & ex1_instr_q[6:31] == 26'b00101001010010101101111000)      ? 1'b1 : 1'b0;
   assign ex1_is_pri6 = (ex1_opcode_is_31 & ex1_instr_q[6:31] == 26'b00011000110001101101111000)      ? 1'b1 : 1'b0;
   assign ex1_is_pri7 = (ex1_opcode_is_31 & ex1_instr_q[6:31] == 26'b00111001110011101101111000)      ? 1'b1 : 1'b0;

   //------------------------------------------------------------------------------------------
   // Latches
   //------------------------------------------------------------------------------------------
   tri_rlmreg_p #(.WIDTH(5), .OFFSET(1),.INIT(0), .NEEDS_SRESET(1)) exx_act_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_act_offset : exx_act_offset + 5-1]),
      .scout(sov[exx_act_offset : exx_act_offset + 5-1]),
      .din(exx_act_d),
      .dout(exx_act_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_s2_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex1_s2_v_offset]),
      .scout(sov[ex1_s2_v_offset]),
      .din(rv_xu0_ex0_s2_v),
      .dout(ex1_s2_v_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_s2_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_s2_t_offset : ex1_s2_t_offset + 3-1]),
      .scout(sov[ex1_s2_t_offset : ex1_s2_t_offset + 3-1]),
      .din(rv_xu0_ex0_s2_t),
      .dout(ex1_s2_t_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_s3_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex1_s3_v_offset]),
      .scout(sov[ex1_s3_v_offset]),
      .din(rv_xu0_ex0_s3_v),
      .dout(ex1_s3_v_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_s3_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_s3_t_offset : ex1_s3_t_offset + 3-1]),
      .scout(sov[ex1_s3_t_offset : ex1_s3_t_offset + 3-1]),
      .din(rv_xu0_ex0_s3_t),
      .dout(ex1_s3_t_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_t1_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_t1_t_offset : ex1_t1_t_offset + 3-1]),
      .scout(sov[ex1_t1_t_offset : ex1_t1_t_offset + 3-1]),
      .din(rv_xu0_ex0_t1_t),
      .dout(ex1_t1_t_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_t2_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_t2_t_offset : ex1_t2_t_offset + 3-1]),
      .scout(sov[ex1_t2_t_offset : ex1_t2_t_offset + 3-1]),
      .din(rv_xu0_ex0_t2_t),
      .dout(ex1_t2_t_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_t3_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_t3_t_offset : ex1_t3_t_offset + 3-1]),
      .scout(sov[ex1_t3_t_offset : ex1_t3_t_offset + 3-1]),
      .din(rv_xu0_ex0_t3_t),
      .dout(ex1_t3_t_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_t1_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex1_t1_v_offset]),
      .scout(sov[ex1_t1_v_offset]),
      .din(rv_xu0_ex0_t1_v),
      .dout(ex1_t1_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_t2_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex1_t2_v_offset]),
      .scout(sov[ex1_t2_v_offset]),
      .din(rv_xu0_ex0_t2_v),
      .dout(ex1_t2_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_t3_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex1_t3_v_offset]),
      .scout(sov[ex1_t3_v_offset]),
      .din(rv_xu0_ex0_t3_v),
      .dout(ex1_t3_v_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_t1_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_t1_p_offset : ex1_t1_p_offset + `GPR_POOL_ENC-1]),
      .scout(sov[ex1_t1_p_offset : ex1_t1_p_offset + `GPR_POOL_ENC-1]),
      .din(rv_xu0_ex0_t1_p),
      .dout(ex1_t1_p_q)
   );
   tri_rlmreg_p #(.WIDTH(`XER_POOL_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_t2_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_t2_p_offset : ex1_t2_p_offset + `XER_POOL_ENC-1]),
      .scout(sov[ex1_t2_p_offset : ex1_t2_p_offset + `XER_POOL_ENC-1]),
      .din(rv_xu0_ex0_t2_p[XER_LEFT:`GPR_POOL_ENC-1]),
      .dout(ex1_t2_p_q)
   );
   tri_rlmreg_p #(.WIDTH(`CR_POOL_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_t3_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_t3_p_offset : ex1_t3_p_offset + `CR_POOL_ENC-1]),
      .scout(sov[ex1_t3_p_offset : ex1_t3_p_offset + `CR_POOL_ENC-1]),
      .din(rv_xu0_ex0_t3_p[CR_LEFT:`GPR_POOL_ENC-1]),
      .dout(ex1_t3_p_q)
   );
   tri_rlmreg_p #(.WIDTH(32), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_instr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_instr_offset : ex1_instr_offset + 32-1]),
      .scout(sov[ex1_instr_offset : ex1_instr_offset + 32-1]),
      .din(ex0_instr),
      .dout(ex1_instr_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_ucode_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_ucode_offset : ex1_ucode_offset + 3-1]),
      .scout(sov[ex1_ucode_offset : ex1_ucode_offset + 3-1]),
      .din(rv_xu0_ex0_ucode),
      .dout(ex1_ucode_q)
   );
   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_itag_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_itag_offset : ex1_itag_offset + `ITAG_SIZE_ENC-1]),
      .scout(sov[ex1_itag_offset : ex1_itag_offset + `ITAG_SIZE_ENC-1]),
      .din(rv_xu0_ex0_itag),
      .dout(ex1_itag_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_add_ci_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_add_ci_sel_offset : ex2_add_ci_sel_offset + 2-1]),
      .scout(sov[ex2_add_ci_sel_offset : ex2_add_ci_sel_offset + 2-1]),
      .din(ex1_add_ci_sel),
      .dout(ex2_add_ci_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_itag_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_itag_offset : ex2_itag_offset + `ITAG_SIZE_ENC-1]),
      .scout(sov[ex2_itag_offset : ex2_itag_offset + `ITAG_SIZE_ENC-1]),
      .din(ex1_itag_q),
      .dout(ex2_itag_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_t1_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_t1_p_offset : ex2_t1_p_offset + `GPR_POOL_ENC-1]),
      .scout(sov[ex2_t1_p_offset : ex2_t1_p_offset + `GPR_POOL_ENC-1]),
      .din(ex1_t1_p_q),
      .dout(ex2_t1_p_q)
   );
   tri_rlmreg_p #(.WIDTH(`XER_POOL_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_t2_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_t2_p_offset : ex2_t2_p_offset + `XER_POOL_ENC-1]),
      .scout(sov[ex2_t2_p_offset : ex2_t2_p_offset + `XER_POOL_ENC-1]),
      .din(ex1_t2_p_q),
      .dout(ex2_t2_p_q)
   );
   tri_rlmreg_p #(.WIDTH(`CR_POOL_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_t3_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_t3_p_offset : ex2_t3_p_offset + `CR_POOL_ENC-1]),
      .scout(sov[ex2_t3_p_offset : ex2_t3_p_offset + `CR_POOL_ENC-1]),
      .din(ex1_t3_p_q),
      .dout(ex2_t3_p_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_t1_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_t1_p_offset : ex3_t1_p_offset + `GPR_POOL_ENC-1]),
      .scout(sov[ex3_t1_p_offset : ex3_t1_p_offset + `GPR_POOL_ENC-1]),
      .din(ex2_t1_p_q),
      .dout(ex3_t1_p_q)
   );
   tri_rlmreg_p #(.WIDTH(`XER_POOL_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_t2_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_t2_p_offset : ex3_t2_p_offset + `XER_POOL_ENC-1]),
      .scout(sov[ex3_t2_p_offset : ex3_t2_p_offset + `XER_POOL_ENC-1]),
      .din(ex2_t2_p_q),
      .dout(ex3_t2_p_q)
   );
   tri_rlmreg_p #(.WIDTH(`CR_POOL_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_t3_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_t3_p_offset : ex3_t3_p_offset + `CR_POOL_ENC-1]),
      .scout(sov[ex3_t3_p_offset : ex3_t3_p_offset + `CR_POOL_ENC-1]),
      .din(ex2_t3_p_q),
      .dout(ex3_t3_p_q)
   );
   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_itag_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_itag_offset : ex3_itag_offset + `ITAG_SIZE_ENC-1]),
      .scout(sov[ex3_itag_offset : ex3_itag_offset + `ITAG_SIZE_ENC-1]),
      .din(ex2_itag_q),
      .dout(ex3_itag_q)
   );
   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_itag_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_itag_offset : ex4_itag_offset + `ITAG_SIZE_ENC-1]),
      .scout(sov[ex4_itag_offset : ex4_itag_offset + `ITAG_SIZE_ENC-1]),
      .din(ex3_itag),
      .dout(ex4_itag_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) cp_flush_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[cp_flush_offset : cp_flush_offset + `THREADS-1]),
      .scout(sov[cp_flush_offset : cp_flush_offset + `THREADS-1]),
      .din(cp_flush),
      .dout(cp_flush_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex0_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX0]),
      .mpw1_b(mpw1_dc_b[DEX0]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex0_val_offset : ex0_val_offset + `THREADS-1]),
      .scout(sov[ex0_val_offset : ex0_val_offset + `THREADS-1]),
      .din(rv2_val),
      .dout(ex0_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_val_offset : ex1_val_offset + `THREADS-1]),
      .scout(sov[ex1_val_offset : ex1_val_offset + `THREADS-1]),
      .din(ex0_val),
      .dout(ex1_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_val_offset : ex2_val_offset + `THREADS-1]),
      .scout(sov[ex2_val_offset : ex2_val_offset + `THREADS-1]),
      .din(ex1_val),
      .dout(ex2_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_val_offset : ex3_val_offset + `THREADS-1]),
      .scout(sov[ex3_val_offset : ex3_val_offset + `THREADS-1]),
      .din(ex2_val),
      .dout(ex3_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_val_offset : ex4_val_offset + `THREADS-1]),
      .scout(sov[ex4_val_offset : ex4_val_offset + `THREADS-1]),
      .din(ex3_val),
      .dout(ex4_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex5_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_val_offset : ex5_val_offset + `THREADS-1]),
      .scout(sov[ex5_val_offset : ex5_val_offset + `THREADS-1]),
      .din(ex4_val),
      .dout(ex5_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex6_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex6_val_offset : ex6_val_offset + `THREADS-1]),
      .scout(sov[ex6_val_offset : ex6_val_offset + `THREADS-1]),
      .din(ex5_val),
      .dout(ex6_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_ord_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_ord_val_offset : ex1_ord_val_offset + `THREADS-1]),
      .scout(sov[ex1_ord_val_offset : ex1_ord_val_offset + `THREADS-1]),
      .din(ex0_ord_val),
      .dout(ex1_ord_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_ord_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_ord_val_offset : ex2_ord_val_offset + `THREADS-1]),
      .scout(sov[ex2_ord_val_offset : ex2_ord_val_offset + `THREADS-1]),
      .din(ex1_ord_val),
      .dout(ex2_ord_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_ord_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_ord_val_offset : ex3_ord_val_offset + `THREADS-1]),
      .scout(sov[ex3_ord_val_offset : ex3_ord_val_offset + `THREADS-1]),
      .din(ex2_ord_val),
      .dout(ex3_ord_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_ord_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_ord_val_offset : ex4_ord_val_offset + `THREADS-1]),
      .scout(sov[ex4_ord_val_offset : ex4_ord_val_offset + `THREADS-1]),
      .din(ex3_ord_val),
      .dout(ex4_ord_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) spr_msr_cm_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[spr_msr_cm_offset : spr_msr_cm_offset + `THREADS-1]),
      .scout(sov[spr_msr_cm_offset : spr_msr_cm_offset + `THREADS-1]),
      .din(spr_msr_cm),
      .dout(spr_msr_cm_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) spr_msr_gs_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[spr_msr_gs_offset : spr_msr_gs_offset + `THREADS-1]),
      .scout(sov[spr_msr_gs_offset : spr_msr_gs_offset + `THREADS-1]),
      .din(spr_msr_gs),
      .dout(spr_msr_gs_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) spr_msr_pr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[spr_msr_pr_offset : spr_msr_pr_offset + `THREADS-1]),
      .scout(sov[spr_msr_pr_offset : spr_msr_pr_offset + `THREADS-1]),
      .din(spr_msr_pr),
      .dout(spr_msr_pr_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) spr_epcr_dgtmi_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[spr_epcr_dgtmi_offset : spr_epcr_dgtmi_offset + `THREADS-1]),
      .scout(sov[spr_epcr_dgtmi_offset : spr_epcr_dgtmi_offset + `THREADS-1]),
      .din(spr_epcr_dgtmi),
      .dout(spr_epcr_dgtmi_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_ccr2_notlb_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[spr_ccr2_notlb_offset]),
      .scout(sov[spr_ccr2_notlb_offset]),
      .din(spr_ccr2_notlb),
      .dout(spr_ccr2_notlb_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_br_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_br_val_offset : ex4_br_val_offset + `THREADS-1]),
      .scout(sov[ex4_br_val_offset : ex4_br_val_offset + `THREADS-1]),
      .din(br_dec_ex3_execute_vld),
      .dout(ex4_br_val_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_ord_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex1_ord_offset]),
      .scout(sov[ex1_ord_offset]),
      .din(ex0_ord),
      .dout(ex1_ord_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ord_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ord_offset]),
      .scout(sov[ex2_ord_offset]),
      .din(ex1_ord_q),
      .dout(ex2_ord_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_ord_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_ord_offset]),
      .scout(sov[ex3_ord_offset]),
      .din(ex2_ord_q),
      .dout(ex3_ord_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_t1_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_t1_v_offset]),
      .scout(sov[ex2_t1_v_offset]),
      .din(ex1_t1_v_q),
      .dout(ex2_t1_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_t2_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_t2_v_offset]),
      .scout(sov[ex2_t2_v_offset]),
      .din(ex1_t2_v_q),
      .dout(ex2_t2_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_t3_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_t3_v_offset]),
      .scout(sov[ex2_t3_v_offset]),
      .din(ex1_t3_v_q),
      .dout(ex2_t3_v_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_t1_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_t1_t_offset : ex2_t1_t_offset + 3-1]),
      .scout(sov[ex2_t1_t_offset : ex2_t1_t_offset + 3-1]),
      .din(ex1_t1_t_q),
      .dout(ex2_t1_t_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_t2_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_t2_t_offset : ex2_t2_t_offset + 3-1]),
      .scout(sov[ex2_t2_t_offset : ex2_t2_t_offset + 3-1]),
      .din(ex1_t2_t_q),
      .dout(ex2_t2_t_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_t3_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_t3_t_offset : ex2_t3_t_offset + 3-1]),
      .scout(sov[ex2_t3_t_offset : ex2_t3_t_offset + 3-1]),
      .din(ex1_t3_t_q),
      .dout(ex2_t3_t_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_t1_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_t1_v_offset]),
      .scout(sov[ex3_t1_v_offset]),
      .din(ex2_t1_v_q),
      .dout(ex3_t1_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_t2_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_t2_v_offset]),
      .scout(sov[ex3_t2_v_offset]),
      .din(ex2_t2_v_q),
      .dout(ex3_t2_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_t3_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_t3_v_offset]),
      .scout(sov[ex3_t3_v_offset]),
      .din(ex2_t3_v_q),
      .dout(ex3_t3_v_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_t1_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_t1_t_offset : ex3_t1_t_offset + 3-1]),
      .scout(sov[ex3_t1_t_offset : ex3_t1_t_offset + 3-1]),
      .din(ex2_t1_t_q),
      .dout(ex3_t1_t_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_t2_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_t2_t_offset : ex3_t2_t_offset + 3-1]),
      .scout(sov[ex3_t2_t_offset : ex3_t2_t_offset + 3-1]),
      .din(ex2_t2_t_q),
      .dout(ex3_t2_t_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_t3_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_t3_t_offset : ex3_t3_t_offset + 3-1]),
      .scout(sov[ex3_t3_t_offset : ex3_t3_t_offset + 3-1]),
      .din(ex2_t3_t_q),
      .dout(ex3_t3_t_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_t1_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_t1_v_offset]),
      .scout(sov[ex4_t1_v_offset]),
      .din(ex3_t1_v_q),
      .dout(ex4_t1_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_t2_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_t2_v_offset]),
      .scout(sov[ex4_t2_v_offset]),
      .din(ex3_t2_v_q),
      .dout(ex4_t2_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_t3_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_t3_v_offset]),
      .scout(sov[ex4_t3_v_offset]),
      .din(ex3_t3_v_q),
      .dout(ex4_t3_v_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_t1_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_t1_t_offset : ex4_t1_t_offset + 3-1]),
      .scout(sov[ex4_t1_t_offset : ex4_t1_t_offset + 3-1]),
      .din(ex3_t1_t_q),
      .dout(ex4_t1_t_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_t2_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_t2_t_offset : ex4_t2_t_offset + 3-1]),
      .scout(sov[ex4_t2_t_offset : ex4_t2_t_offset + 3-1]),
      .din(ex3_t2_t_q),
      .dout(ex4_t2_t_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_t3_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_t3_t_offset : ex4_t3_t_offset + 3-1]),
      .scout(sov[ex4_t3_t_offset : ex4_t3_t_offset + 3-1]),
      .din(ex3_t3_t_q),
      .dout(ex4_t3_t_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_t1_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_t1_p_offset : ex4_t1_p_offset + `GPR_POOL_ENC-1]),
      .scout(sov[ex4_t1_p_offset : ex4_t1_p_offset + `GPR_POOL_ENC-1]),
      .din(ex3_t1_p_q),
      .dout(ex4_t1_p_q)
   );
   tri_rlmreg_p #(.WIDTH(-XER_LEFT+`GPR_POOL_ENC), .OFFSET(XER_LEFT),.INIT(0), .NEEDS_SRESET(1)) ex4_t2_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_t2_p_offset : ex4_t2_p_offset + -XER_LEFT+`GPR_POOL_ENC-1]),
      .scout(sov[ex4_t2_p_offset : ex4_t2_p_offset + -XER_LEFT+`GPR_POOL_ENC-1]),
      .din(ex3_t2_p_q),
      .dout(ex4_t2_p_q)
   );
   tri_rlmreg_p #(.WIDTH(-CR_LEFT+`GPR_POOL_ENC), .OFFSET(CR_LEFT),.INIT(0), .NEEDS_SRESET(1)) ex4_t3_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_t3_p_offset : ex4_t3_p_offset + -CR_LEFT+`GPR_POOL_ENC-1]),
      .scout(sov[ex4_t3_p_offset : ex4_t3_p_offset + -CR_LEFT+`GPR_POOL_ENC-1]),
      .din(ex3_t3_p_q),
      .dout(ex4_t3_p_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_t1_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[4]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex5_t1_v_offset]),
      .scout(sov[ex5_t1_v_offset]),
      .din(ex4_t1_v_q),
      .dout(ex5_t1_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_t2_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[4]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex5_t2_v_offset]),
      .scout(sov[ex5_t2_v_offset]),
      .din(ex4_t2_v_q),
      .dout(ex5_t2_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_t3_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[4]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex5_t3_v_offset]),
      .scout(sov[ex5_t3_v_offset]),
      .din(ex4_t3_v_q),
      .dout(ex5_t3_v_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex5_t1_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[4]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_t1_t_offset : ex5_t1_t_offset + 3-1]),
      .scout(sov[ex5_t1_t_offset : ex5_t1_t_offset + 3-1]),
      .din(ex4_t1_t_q),
      .dout(ex5_t1_t_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex5_t2_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[4]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_t2_t_offset : ex5_t2_t_offset + 3-1]),
      .scout(sov[ex5_t2_t_offset : ex5_t2_t_offset + 3-1]),
      .din(ex4_t2_t_q),
      .dout(ex5_t2_t_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex5_t3_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[4]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_t3_t_offset : ex5_t3_t_offset + 3-1]),
      .scout(sov[ex5_t3_t_offset : ex5_t3_t_offset + 3-1]),
      .din(ex4_t3_t_q),
      .dout(ex5_t3_t_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex5_t1_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[4]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_t1_p_offset : ex5_t1_p_offset + `GPR_POOL_ENC-1]),
      .scout(sov[ex5_t1_p_offset : ex5_t1_p_offset + `GPR_POOL_ENC-1]),
      .din(ex4_t1_p_q),
      .dout(ex5_t1_p_q)
   );
   tri_rlmreg_p #(.WIDTH(-XER_LEFT+`GPR_POOL_ENC), .OFFSET(XER_LEFT),.INIT(0), .NEEDS_SRESET(1)) ex5_t2_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[4]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_t2_p_offset : ex5_t2_p_offset + -XER_LEFT+`GPR_POOL_ENC-1]),
      .scout(sov[ex5_t2_p_offset : ex5_t2_p_offset + -XER_LEFT+`GPR_POOL_ENC-1]),
      .din(ex4_t2_p_q),
      .dout(ex5_t2_p_q)
   );
   tri_rlmreg_p #(.WIDTH(-CR_LEFT+`GPR_POOL_ENC), .OFFSET(CR_LEFT),.INIT(0), .NEEDS_SRESET(1)) ex5_t3_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[4]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_t3_p_offset : ex5_t3_p_offset + -CR_LEFT+`GPR_POOL_ENC-1]),
      .scout(sov[ex5_t3_p_offset : ex5_t3_p_offset + -CR_LEFT+`GPR_POOL_ENC-1]),
      .din(ex4_t3_p_q),
      .dout(ex5_t3_p_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_ord_t1_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex4_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex5_ord_t1_v_offset]),
      .scout(sov[ex5_ord_t1_v_offset]),
      .din(ex4_t1_v_q),
      .dout(ex5_ord_t1_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_ord_t2_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex4_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex5_ord_t2_v_offset]),
      .scout(sov[ex5_ord_t2_v_offset]),
      .din(ex4_t2_v_q),
      .dout(ex5_ord_t2_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_ord_t3_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex4_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex5_ord_t3_v_offset]),
      .scout(sov[ex5_ord_t3_v_offset]),
      .din(ex4_t3_v_q),
      .dout(ex5_ord_t3_v_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex5_ord_t1_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex4_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_ord_t1_t_offset : ex5_ord_t1_t_offset + 3-1]),
      .scout(sov[ex5_ord_t1_t_offset : ex5_ord_t1_t_offset + 3-1]),
      .din(ex4_t1_t_q),
      .dout(ex5_ord_t1_t_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex5_ord_t2_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex4_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_ord_t2_t_offset : ex5_ord_t2_t_offset + 3-1]),
      .scout(sov[ex5_ord_t2_t_offset : ex5_ord_t2_t_offset + 3-1]),
      .din(ex4_t2_t_q),
      .dout(ex5_ord_t2_t_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex5_ord_t3_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex4_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_ord_t3_t_offset : ex5_ord_t3_t_offset + 3-1]),
      .scout(sov[ex5_ord_t3_t_offset : ex5_ord_t3_t_offset + 3-1]),
      .din(ex4_t3_t_q),
      .dout(ex5_ord_t3_t_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex5_ord_t1_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex4_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_ord_t1_p_offset : ex5_ord_t1_p_offset + `GPR_POOL_ENC-1]),
      .scout(sov[ex5_ord_t1_p_offset : ex5_ord_t1_p_offset + `GPR_POOL_ENC-1]),
      .din(ex4_t1_p_q),
      .dout(ex5_ord_t1_p_q)
   );
   tri_rlmreg_p #(.WIDTH(-XER_LEFT+`GPR_POOL_ENC), .OFFSET(XER_LEFT),.INIT(0), .NEEDS_SRESET(1)) ex5_ord_t2_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex4_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_ord_t2_p_offset : ex5_ord_t2_p_offset + -XER_LEFT+`GPR_POOL_ENC-1]),
      .scout(sov[ex5_ord_t2_p_offset : ex5_ord_t2_p_offset + -XER_LEFT+`GPR_POOL_ENC-1]),
      .din(ex4_t2_p_q),
      .dout(ex5_ord_t2_p_q)
   );
   tri_rlmreg_p #(.WIDTH(-CR_LEFT+`GPR_POOL_ENC), .OFFSET(CR_LEFT),.INIT(0), .NEEDS_SRESET(1)) ex5_ord_t3_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex4_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_ord_t3_p_offset : ex5_ord_t3_p_offset + -CR_LEFT+`GPR_POOL_ENC-1]),
      .scout(sov[ex5_ord_t3_p_offset : ex5_ord_t3_p_offset + -CR_LEFT+`GPR_POOL_ENC-1]),
      .din(ex4_t3_p_q),
      .dout(ex5_ord_t3_p_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_gpr_we_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex6_gpr_we_offset]),
      .scout(sov[ex6_gpr_we_offset]),
      .din(ex5_gpr_we),
      .dout(ex6_gpr_we_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_xer_we_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex6_xer_we_offset]),
      .scout(sov[ex6_xer_we_offset]),
      .din(ex5_xer_we),
      .dout(ex6_xer_we_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_cr_we_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex6_cr_we_offset]),
      .scout(sov[ex6_cr_we_offset]),
      .din(ex5_cr_we),
      .dout(ex6_cr_we_q)
   );
   tri_rlmreg_p #(.WIDTH(-CR_LEFT+`GPR_POOL_ENC), .OFFSET(CR_LEFT),.INIT(0), .NEEDS_SRESET(1)) ex6_cr_wa_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[5]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex6_cr_wa_offset : ex6_cr_wa_offset + -CR_LEFT+`GPR_POOL_ENC-1]),
      .scout(sov[ex6_cr_wa_offset : ex6_cr_wa_offset + -CR_LEFT+`GPR_POOL_ENC-1]),
      .din(ex5_cr_wa),
      .dout(ex6_cr_wa_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_ctr_we_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_ctr_we_offset]),
      .scout(sov[ex4_ctr_we_offset]),
      .din(ex3_ctr_we),
      .dout(ex4_ctr_we_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_lr_we_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_lr_we_offset]),
      .scout(sov[ex4_lr_we_offset]),
      .din(ex3_lr_we),
      .dout(ex4_lr_we_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex6_t1_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[5]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex6_t1_p_offset : ex6_t1_p_offset + `GPR_POOL_ENC-1]),
      .scout(sov[ex6_t1_p_offset : ex6_t1_p_offset + `GPR_POOL_ENC-1]),
      .din(ex5_t1_p),
      .dout(ex6_t1_p_q)
   );
   tri_rlmreg_p #(.WIDTH(-XER_LEFT+`GPR_POOL_ENC), .OFFSET(XER_LEFT),.INIT(0), .NEEDS_SRESET(1)) ex6_t2_p_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[5]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex6_t2_p_offset : ex6_t2_p_offset + -XER_LEFT+`GPR_POOL_ENC-1]),
      .scout(sov[ex6_t2_p_offset : ex6_t2_p_offset + -XER_LEFT+`GPR_POOL_ENC-1]),
      .din(ex5_t2_p),
      .dout(ex6_t2_p_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_ccr2_en_attn_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[spr_ccr2_en_attn_offset]),
      .scout(sov[spr_ccr2_en_attn_offset]),
      .din(spr_ccr2_en_attn),
      .dout(spr_ccr2_en_attn_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_ccr4_en_dnh_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[spr_ccr4_en_dnh_offset]),
      .scout(sov[spr_ccr4_en_dnh_offset]),
      .din(spr_ccr4_en_dnh),
      .dout(spr_ccr4_en_dnh_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_ccr2_en_pc_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[spr_ccr2_en_pc_offset]),
      .scout(sov[spr_ccr2_en_pc_offset]),
      .din(spr_ccr2_en_pc),
      .dout(spr_ccr2_en_pc_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_ord_tid_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_ord_tid_offset : ex2_ord_tid_offset + `THREADS-1]),
      .scout(sov[ex2_ord_tid_offset : ex2_ord_tid_offset + `THREADS-1]),
      .din(ex1_ord_val_q),
      .dout(ex2_ord_tid_q)
   );
   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_ord_itag_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_ord_itag_offset : ex2_ord_itag_offset + `ITAG_SIZE_ENC-1]),
      .scout(sov[ex2_ord_itag_offset : ex2_ord_itag_offset + `ITAG_SIZE_ENC-1]),
      .din(ex1_itag_q),
      .dout(ex2_ord_itag_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ord_is_eratre_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ord_is_eratre_offset]),
      .scout(sov[ex2_ord_is_eratre_offset]),
      .din(ex1_is_eratre),
      .dout(ex2_ord_is_eratre_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ord_is_eratwe_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ord_is_eratwe_offset]),
      .scout(sov[ex2_ord_is_eratwe_offset]),
      .din(ex1_is_eratwe),
      .dout(ex2_ord_is_eratwe_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ord_is_eratsx_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ord_is_eratsx_offset]),
      .scout(sov[ex2_ord_is_eratsx_offset]),
      .din(ex1_is_eratsx),
      .dout(ex2_ord_is_eratsx_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ord_is_eratilx_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ord_is_eratilx_offset]),
      .scout(sov[ex2_ord_is_eratilx_offset]),
      .din(ex1_is_eratilx),
      .dout(ex2_ord_is_eratilx_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ord_is_erativax_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ord_is_erativax_offset]),
      .scout(sov[ex2_ord_is_erativax_offset]),
      .din(ex1_is_erativax),
      .dout(ex2_ord_is_erativax_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ord_is_tlbre_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ord_is_tlbre_offset]),
      .scout(sov[ex2_ord_is_tlbre_offset]),
      .din(ex1_is_tlbre),
      .dout(ex2_ord_is_tlbre_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ord_is_tlbwe_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ord_is_tlbwe_offset]),
      .scout(sov[ex2_ord_is_tlbwe_offset]),
      .din(ex1_is_tlbwe),
      .dout(ex2_ord_is_tlbwe_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ord_is_tlbsx_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ord_is_tlbsx_offset]),
      .scout(sov[ex2_ord_is_tlbsx_offset]),
      .din(ex1_is_tlbsx),
      .dout(ex2_ord_is_tlbsx_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ord_is_tlbsxr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ord_is_tlbsxr_offset]),
      .scout(sov[ex2_ord_is_tlbsxr_offset]),
      .din(ex1_is_tlbsxr),
      .dout(ex2_ord_is_tlbsxr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ord_is_tlbsrx_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ord_is_tlbsrx_offset]),
      .scout(sov[ex2_ord_is_tlbsrx_offset]),
      .din(ex1_is_tlbsrx),
      .dout(ex2_ord_is_tlbsrx_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ord_is_tlbivax_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ord_is_tlbivax_offset]),
      .scout(sov[ex2_ord_is_tlbivax_offset]),
      .din(ex1_is_tlbivax),
      .dout(ex2_ord_is_tlbivax_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ord_is_tlbilx_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ord_is_tlbilx_offset]),
      .scout(sov[ex2_ord_is_tlbilx_offset]),
      .din(ex1_is_tlbilx),
      .dout(ex2_ord_is_tlbilx_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(19),.INIT(0), .NEEDS_SRESET(1)) ex2_ord_tlb_ws_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_ord_tlb_ws_offset : ex2_ord_tlb_ws_offset + 2-1]),
      .scout(sov[ex2_ord_tlb_ws_offset : ex2_ord_tlb_ws_offset + 2-1]),
      .din(ex1_instr_q[19:20]),
      .dout(ex2_ord_tlb_ws_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(8),.INIT(0), .NEEDS_SRESET(1)) ex2_ord_tlb_t_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_ord_tlb_t_offset : ex2_ord_tlb_t_offset + 3-1]),
      .scout(sov[ex2_ord_tlb_t_offset : ex2_ord_tlb_t_offset + 3-1]),
      .din(ex1_instr_q[8:10]),
      .dout(ex2_ord_tlb_t_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_priv_excep_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_priv_excep_offset]),
      .scout(sov[ex2_priv_excep_offset]),
      .din(ex1_priv_excep),
      .dout(ex2_priv_excep_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_hyp_priv_excep_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_hyp_priv_excep_offset]),
      .scout(sov[ex2_hyp_priv_excep_offset]),
      .din(ex1_hyp_priv_excep),
      .dout(ex2_hyp_priv_excep_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_illegal_op_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_illegal_op_offset]),
      .scout(sov[ex2_illegal_op_offset]),
      .din(ex1_illegal_op),
      .dout(ex2_illegal_op_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_flush2ucode_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_flush2ucode_offset]),
      .scout(sov[ex2_flush2ucode_offset]),
      .din(ex1_flush2ucode),
      .dout(ex2_flush2ucode_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_tlb_illeg_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_tlb_illeg_offset]),
      .scout(sov[ex2_tlb_illeg_offset]),
      .din(ex1_tlb_illeg),
      .dout(ex2_tlb_illeg_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_priv_excep_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_priv_excep_offset]),
      .scout(sov[ex3_priv_excep_offset]),
      .din(ex2_priv_excep_q),
      .dout(ex3_priv_excep_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_hyp_priv_excep_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_hyp_priv_excep_offset]),
      .scout(sov[ex3_hyp_priv_excep_offset]),
      .din(ex2_hyp_priv_excep_q),
      .dout(ex3_hyp_priv_excep_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_illegal_op_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_illegal_op_offset]),
      .scout(sov[ex3_illegal_op_offset]),
      .din(ex2_illegal_op_q),
      .dout(ex3_illegal_op_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_flush2ucode_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_flush2ucode_offset]),
      .scout(sov[ex3_flush2ucode_offset]),
      .din(ex2_flush2ucode),
      .dout(ex3_flush2ucode_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_flush2ucode_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_flush2ucode_offset]),
      .scout(sov[ex4_flush2ucode_offset]),
      .din(ex3_flush2ucode),
      .dout(ex4_flush2ucode_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_ord_complete_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex1_ord_complete_offset]),
      .scout(sov[ex1_ord_complete_offset]),
      .din(ex0_ord_complete),
      .dout(ex1_ord_complete_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ord_complete_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ord_complete_offset]),
      .scout(sov[ex2_ord_complete_offset]),
      .din(ex1_ord_complete),
      .dout(ex2_ord_complete_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_ord_complete_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_ord_complete_offset]),
      .scout(sov[ex3_ord_complete_offset]),
      .din(ex2_ord_complete),
      .dout(ex3_ord_complete_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_ord_complete_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_ord_complete_offset]),
      .scout(sov[ex4_ord_complete_offset]),
      .din(ex3_ord_complete),
      .dout(ex4_ord_complete_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_ord_complete_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex5_ord_complete_offset]),
      .scout(sov[ex5_ord_complete_offset]),
      .din(ex4_ord_complete),
      .dout(ex5_ord_complete_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_ord_complete_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex6_ord_complete_offset]),
      .scout(sov[ex6_ord_complete_offset]),
      .din(ex5_ord_complete),
      .dout(ex6_ord_complete_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) xu_iu_pri_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[xu_iu_pri_offset : xu_iu_pri_offset + 3-1]),
      .scout(sov[xu_iu_pri_offset : xu_iu_pri_offset + 3-1]),
      .din(xu_iu_pri_d),
      .dout(xu_iu_pri_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) xu_iu_pri_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[xu_iu_pri_val_offset : xu_iu_pri_val_offset + `THREADS-1]),
      .scout(sov[xu_iu_pri_val_offset : xu_iu_pri_val_offset + `THREADS-1]),
      .din(xu_iu_pri_val_d),
      .dout(xu_iu_pri_val_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_iu_hold_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[xu_iu_hold_val_offset]),
      .scout(sov[xu_iu_hold_val_offset]),
      .din(xu_iu_hold_val_d),
      .dout(xu_iu_hold_val_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_lq_hold_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[xu_lq_hold_val_offset]),
      .scout(sov[xu_lq_hold_val_offset]),
      .din(xu_lq_hold_val_d),
      .dout(xu_lq_hold_val_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_mm_hold_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[xu_mm_hold_val_offset]),
      .scout(sov[xu_mm_hold_val_offset]),
      .din(xu_mm_hold_val_d),
      .dout(xu_mm_hold_val_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_iu_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[xu_iu_val_offset]),
      .scout(sov[xu_iu_val_offset]),
      .din(xu_iu_val_d),
      .dout(xu_iu_val_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_lq_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[xu_lq_val_offset]),
      .scout(sov[xu_lq_val_offset]),
      .din(xu_lq_val_d),
      .dout(xu_lq_val_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_mm_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[xu_mm_val_offset]),
      .scout(sov[xu_mm_val_offset]),
      .din(xu_mm_val_d),
      .dout(xu_mm_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) xu_iu_val_2_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[xu_iu_val_2_offset : xu_iu_val_2_offset + `THREADS-1]),
      .scout(sov[xu_iu_val_2_offset : xu_iu_val_2_offset + `THREADS-1]),
      .din(xu_iu_val_2_d),
      .dout(xu_iu_val_2_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) xu_lq_val_2_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[xu_lq_val_2_offset : xu_lq_val_2_offset + `THREADS-1]),
      .scout(sov[xu_lq_val_2_offset : xu_lq_val_2_offset + `THREADS-1]),
      .din(xu_lq_val_2_d),
      .dout(xu_lq_val_2_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) xu_mm_val_2_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[xu_mm_val_2_offset : xu_mm_val_2_offset + `THREADS-1]),
      .scout(sov[xu_mm_val_2_offset : xu_mm_val_2_offset + `THREADS-1]),
      .din(xu_mm_val_2_d),
      .dout(xu_mm_val_2_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_tlb_miss_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_tlb_miss_offset]),
      .scout(sov[ord_tlb_miss_offset]),
      .din(ord_tlb_miss_d),
      .dout(ord_tlb_miss_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_lrat_miss_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_lrat_miss_offset]),
      .scout(sov[ord_lrat_miss_offset]),
      .din(ord_lrat_miss_d),
      .dout(ord_lrat_miss_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_tlb_inelig_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_tlb_inelig_offset]),
      .scout(sov[ord_tlb_inelig_offset]),
      .din(ord_tlb_inelig_d),
      .dout(ord_tlb_inelig_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_pt_fault_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_pt_fault_offset]),
      .scout(sov[ord_pt_fault_offset]),
      .din(ord_pt_fault_d),
      .dout(ord_pt_fault_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_hv_priv_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_hv_priv_offset]),
      .scout(sov[ord_hv_priv_offset]),
      .din(ord_hv_priv_d),
      .dout(ord_hv_priv_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_illeg_mmu_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_illeg_mmu_offset]),
      .scout(sov[ord_illeg_mmu_offset]),
      .din(ord_illeg_mmu_d),
      .dout(ord_illeg_mmu_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_lq_flush_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_lq_flush_offset]),
      .scout(sov[ord_lq_flush_offset]),
      .din(ord_lq_flush_d),
      .dout(ord_lq_flush_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_spr_priv_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_spr_priv_offset]),
      .scout(sov[ord_spr_priv_offset]),
      .din(ord_spr_priv_d),
      .dout(ord_spr_priv_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_spr_illegal_spr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_spr_illegal_spr_offset]),
      .scout(sov[ord_spr_illegal_spr_offset]),
      .din(ord_spr_illegal_spr_d),
      .dout(ord_spr_illegal_spr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_hyp_priv_spr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_hyp_priv_spr_offset]),
      .scout(sov[ord_hyp_priv_spr_offset]),
      .din(ord_hyp_priv_spr_d),
      .dout(ord_hyp_priv_spr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_ex3_np1_flush_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_ex3_np1_flush_offset]),
      .scout(sov[ord_ex3_np1_flush_offset]),
      .din(ord_ex3_np1_flush_d),
      .dout(ord_ex3_np1_flush_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_ill_tlb_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_ill_tlb_offset]),
      .scout(sov[ord_ill_tlb_offset]),
      .din(ord_ill_tlb_d),
      .dout(ord_ill_tlb_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_priv_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_priv_offset]),
      .scout(sov[ord_priv_offset]),
      .din(ord_priv_d),
      .dout(ord_priv_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_hyp_priv_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_hyp_priv_offset]),
      .scout(sov[ord_hyp_priv_offset]),
      .din(ord_hyp_priv_d),
      .dout(ord_hyp_priv_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_hold_lq_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_hold_lq_offset]),
      .scout(sov[ord_hold_lq_offset]),
      .din(ord_hold_lq_d),
      .dout(ord_hold_lq_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_outstanding_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_outstanding_offset]),
      .scout(sov[ord_outstanding_offset]),
      .din(ord_outstanding_d),
      .dout(ord_outstanding_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_flushed_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_flushed_offset]),
      .scout(sov[ord_flushed_offset]),
      .din(ord_flushed_d),
      .dout(ord_flushed_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_done_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_done_offset]),
      .scout(sov[ord_done_offset]),
      .din(ord_done_d),
      .dout(ord_done_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_mmu_req_sent_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_mmu_req_sent_offset]),
      .scout(sov[ord_mmu_req_sent_offset]),
      .din(ord_mmu_req_sent_d),
      .dout(ord_mmu_req_sent_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_core_block_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_core_block_offset]),
      .scout(sov[ord_core_block_offset]),
      .din(ord_core_block_d),
      .dout(ord_core_block_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_ierat_par_err_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_ierat_par_err_offset]),
      .scout(sov[ord_ierat_par_err_offset]),
      .din(ord_ierat_par_err_d),
      .dout(ord_ierat_par_err_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_derat_par_err_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_derat_par_err_offset]),
      .scout(sov[ord_derat_par_err_offset]),
      .din(ord_derat_par_err_d),
      .dout(ord_derat_par_err_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_tlb_multihit_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_tlb_multihit_offset]),
      .scout(sov[ord_tlb_multihit_offset]),
      .din(ord_tlb_multihit_d),
      .dout(ord_tlb_multihit_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_tlb_par_err_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_tlb_par_err_offset]),
      .scout(sov[ord_tlb_par_err_offset]),
      .din(ord_tlb_par_err_d),
      .dout(ord_tlb_par_err_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_tlb_lru_par_err_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_tlb_lru_par_err_offset]),
      .scout(sov[ord_tlb_lru_par_err_offset]),
      .din(ord_tlb_lru_par_err_d),
      .dout(ord_tlb_lru_par_err_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_local_snoop_reject_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_local_snoop_reject_offset]),
      .scout(sov[ord_local_snoop_reject_offset]),
      .din(ord_local_snoop_reject_d),
      .dout(ord_local_snoop_reject_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) mmu_ord_n_flush_req_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[mmu_ord_n_flush_req_offset : mmu_ord_n_flush_req_offset + 2-1]),
      .scout(sov[mmu_ord_n_flush_req_offset : mmu_ord_n_flush_req_offset + 2-1]),
      .din(mmu_ord_n_flush_req_d),
      .dout(mmu_ord_n_flush_req_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) iu_ord_n_flush_req_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[iu_ord_n_flush_req_offset : iu_ord_n_flush_req_offset + 2-1]),
      .scout(sov[iu_ord_n_flush_req_offset : iu_ord_n_flush_req_offset + 2-1]),
      .din(iu_ord_n_flush_req_d),
      .dout(iu_ord_n_flush_req_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) lq_ord_n_flush_req_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[lq_ord_n_flush_req_offset : lq_ord_n_flush_req_offset + 2-1]),
      .scout(sov[lq_ord_n_flush_req_offset : lq_ord_n_flush_req_offset + 2-1]),
      .din(lq_ord_n_flush_req_d),
      .dout(lq_ord_n_flush_req_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_np1_flush_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_np1_flush_offset]),
      .scout(sov[ex4_np1_flush_offset]),
      .din(ex3_np1_flush),
      .dout(ex4_np1_flush_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_n_flush_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_n_flush_offset]),
      .scout(sov[ex4_n_flush_offset]),
      .din(ex3_n_flush),
      .dout(ex4_n_flush_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_excep_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_excep_val_offset]),
      .scout(sov[ex4_excep_val_offset]),
      .din(ex3_excep_val),
      .dout(ex4_excep_val_q)
   );
   tri_rlmreg_p #(.WIDTH(5), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_excep_vector_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_excep_vector_offset : ex4_excep_vector_offset + 5-1]),
      .scout(sov[ex4_excep_vector_offset : ex4_excep_vector_offset + 5-1]),
      .din(ex3_excep_vector),
      .dout(ex4_excep_vector_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_ucode_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_ucode_offset : ex2_ucode_offset + 3-1]),
      .scout(sov[ex2_ucode_offset : ex2_ucode_offset + 3-1]),
      .din(ex1_ucode_q),
      .dout(ex2_ucode_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_ehpriv_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_ehpriv_offset]),
      .scout(sov[ex2_is_ehpriv_offset]),
      .din(ex1_is_ehpriv),
      .dout(ex2_is_ehpriv_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_is_ehpriv_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_is_ehpriv_offset]),
      .scout(sov[ex3_is_ehpriv_offset]),
      .din(ex2_is_ehpriv_q),
      .dout(ex3_is_ehpriv_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_mtiar_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_mtiar_offset]),
      .scout(sov[ex2_is_mtiar_offset]),
      .din(ex1_is_mtiar),
      .dout(ex2_is_mtiar_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_mtiar_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_mtiar_sel_offset]),
      .scout(sov[ex3_mtiar_sel_offset]),
      .din(ex2_mtiar_sel),
      .dout(ex3_mtiar_sel_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_mtiar_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_mtiar_offset]),
      .scout(sov[ord_mtiar_offset]),
      .din(ord_mtiar_d),
      .dout(ord_mtiar_q)
   );
   tri_rlmreg_p #(.WIDTH(32), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ord_instr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_valid),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ord_instr_offset : ord_instr_offset + 32-1]),
      .scout(sov[ord_instr_offset : ord_instr_offset + 32-1]),
      .din(ord_instr_d),
      .dout(ord_instr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_erativax_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_erativax_offset]),
      .scout(sov[ex2_is_erativax_offset]),
      .din(ex1_is_erativax),
      .dout(ex2_is_erativax_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) xu0_iu_mtiar_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[xu0_iu_mtiar_offset : xu0_iu_mtiar_offset + `THREADS-1]),
      .scout(sov[xu0_iu_mtiar_offset : xu0_iu_mtiar_offset + `THREADS-1]),
      .din(xu0_iu_mtiar_d),
      .dout(xu0_iu_mtiar_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_is_cp_next_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_is_cp_next_offset]),
      .scout(sov[ord_is_cp_next_offset]),
      .din(ord_is_cp_next),
      .dout(ord_is_cp_next_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_flush_1_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_flush_1_offset]),
      .scout(sov[ord_flush_1_offset]),
      .din(ord_spec_flush),
      .dout(ord_flush_1_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_flush_2_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_flush_2_offset]),
      .scout(sov[ord_flush_2_offset]),
      .din(ord_flush_1_q),
      .dout(ord_flush_2_q)
   );
generate begin : spr_mmucr0_tlbsel_gen
   genvar i;
   for (i=0;i<`THREADS;i=i+1) begin : spr_mmucr0_tlbsel_entry
	   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) spr_mmucr0_tlbsel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(1'b1),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
	      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[spr_mmucr0_tlbsel_offset + (i)*2 : spr_mmucr0_tlbsel_offset + (i+1)*2-1]),
	      .scout(sov[spr_mmucr0_tlbsel_offset + (i)*2 : spr_mmucr0_tlbsel_offset + (i+1)*2-1]),
	      .din(spr_mmucr0_tlbsel_d[i]),
	      .dout(spr_mmucr0_tlbsel_q[i])
	   );
   end
end
endgenerate
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mm_xu_tlbwe_binv_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mm_xu_tlbwe_binv_offset]),
      .scout(sov[mm_xu_tlbwe_binv_offset]),
      .din(mm_xu_tlbwe_binv),
      .dout(mm_xu_tlbwe_binv_q)
   );
   tri_rlmreg_p #(.WIDTH(32), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_instr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_instr_offset : ex2_instr_offset + 32-1]),
      .scout(sov[ex2_instr_offset : ex2_instr_offset + 32-1]),
      .din(ex1_instr_q),
      .dout(ex2_instr_q)
   );
   tri_rlmreg_p #(.WIDTH(32), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_instr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_instr_offset : ex3_instr_offset + 32-1]),
      .scout(sov[ex3_instr_offset : ex3_instr_offset + 32-1]),
      .din(ex2_instr_q),
      .dout(ex3_instr_q)
   );
   tri_rlmreg_p #(.WIDTH(32), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_instr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_instr_offset : ex4_instr_offset + 32-1]),
      .scout(sov[ex4_instr_offset : ex4_instr_offset + 32-1]),
      .din(ex3_instr_q),
      .dout(ex4_instr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_hpriv_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_hpriv_offset]),
      .scout(sov[ex4_hpriv_offset]),
      .din(ex3_hpriv),
      .dout(ex4_hpriv_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_any_popcnt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_any_popcnt_offset]),
      .scout(sov[ex2_any_popcnt_offset]),
      .din(ex1_any_popcnt),
      .dout(ex2_any_popcnt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_any_popcnt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_any_popcnt_offset]),
      .scout(sov[ex3_any_popcnt_offset]),
      .din(ex2_any_popcnt_q),
      .dout(ex3_any_popcnt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_any_popcnt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_any_popcnt_offset]),
      .scout(sov[ex4_any_popcnt_offset]),
      .din(ex3_any_popcnt_q),
      .dout(ex4_any_popcnt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_any_cntlz_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_any_cntlz_offset]),
      .scout(sov[ex2_any_cntlz_offset]),
      .din(ex1_any_cntlz),
      .dout(ex2_any_cntlz_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_any_cntlz_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_any_cntlz_offset]),
      .scout(sov[ex3_any_cntlz_offset]),
      .din(ex2_any_cntlz_q),
      .dout(ex3_any_cntlz_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_bpermd_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_bpermd_offset]),
      .scout(sov[ex2_is_bpermd_offset]),
      .din(ex1_is_bpermd),
      .dout(ex2_is_bpermd_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_is_bpermd_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_is_bpermd_offset]),
      .scout(sov[ex3_is_bpermd_offset]),
      .din(ex2_is_bpermd_q),
      .dout(ex3_is_bpermd_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_dlmzb_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_dlmzb_offset]),
      .scout(sov[ex2_is_dlmzb_offset]),
      .din(ex1_is_dlmzb),
      .dout(ex2_is_dlmzb_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_is_dlmzb_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_is_dlmzb_offset]),
      .scout(sov[ex3_is_dlmzb_offset]),
      .din(ex2_is_dlmzb_q),
      .dout(ex3_is_dlmzb_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_mul_multicyc_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_mul_multicyc_offset]),
      .scout(sov[ex2_mul_multicyc_offset]),
      .din(ex1_mul_multicyc),
      .dout(ex2_mul_multicyc_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_mul_multicyc_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_mul_multicyc_offset]),
      .scout(sov[ex3_mul_multicyc_offset]),
      .din(ex2_mul_multicyc_q),
      .dout(ex3_mul_multicyc_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_mul_2c_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_mul_2c_offset]),
      .scout(sov[ex2_mul_2c_offset]),
      .din(ex1_mul_2c),
      .dout(ex2_mul_2c_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_mul_3c_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_mul_3c_offset]),
      .scout(sov[ex2_mul_3c_offset]),
      .din(ex1_mul_3c),
      .dout(ex2_mul_3c_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_mul_4c_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_mul_4c_offset]),
      .scout(sov[ex2_mul_4c_offset]),
      .din(ex1_mul_4c),
      .dout(ex2_mul_4c_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_mul_2c_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_mul_2c_offset]),
      .scout(sov[ex3_mul_2c_offset]),
      .din(ex2_mul_2c_q),
      .dout(ex3_mul_2c_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_mul_3c_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_mul_3c_offset]),
      .scout(sov[ex3_mul_3c_offset]),
      .din(ex2_mul_3c_q),
      .dout(ex3_mul_3c_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_mul_4c_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_mul_4c_offset]),
      .scout(sov[ex3_mul_4c_offset]),
      .din(ex2_mul_4c_q),
      .dout(ex3_mul_4c_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_mul_2c_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_mul_2c_offset]),
      .scout(sov[ex4_mul_2c_offset]),
      .din(ex4_mul_2c_d),
      .dout(ex4_mul_2c_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_mul_3c_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_mul_3c_offset]),
      .scout(sov[ex4_mul_3c_offset]),
      .din(ex4_mul_3c_d),
      .dout(ex4_mul_3c_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_mul_4c_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_mul_4c_offset]),
      .scout(sov[ex4_mul_4c_offset]),
      .din(ex4_mul_4c_d),
      .dout(ex4_mul_4c_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_mul_3c_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex5_mul_3c_offset]),
      .scout(sov[ex5_mul_3c_offset]),
      .din(ex5_mul_3c_d),
      .dout(ex5_mul_3c_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_mul_4c_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex5_mul_4c_offset]),
      .scout(sov[ex5_mul_4c_offset]),
      .din(ex5_mul_4c_d),
      .dout(ex5_mul_4c_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_mul_4c_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex6_mul_4c_offset]),
      .scout(sov[ex6_mul_4c_offset]),
      .din(ex6_mul_4c_d),
      .dout(ex6_mul_4c_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) exx_mul_tid_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_mul_tid_offset : exx_mul_tid_offset + `THREADS-1]),
      .scout(sov[exx_mul_tid_offset : exx_mul_tid_offset + `THREADS-1]),
      .din(exx_mul_tid_d),
      .dout(exx_mul_tid_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_mtspr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_mtspr_offset]),
      .scout(sov[ex2_is_mtspr_offset]),
      .din(ex1_is_mtspr),
      .dout(ex2_is_mtspr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_is_mtspr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_is_mtspr_offset]),
      .scout(sov[ex3_is_mtspr_offset]),
      .din(ex2_is_mtspr_q),
      .dout(ex3_is_mtspr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_ram_active_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex6_ram_active_offset]),
      .scout(sov[ex6_ram_active_offset]),
      .din(ex6_ram_active_d),
      .dout(ex6_ram_active_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex6_tid_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex6_tid_offset : ex6_tid_offset + `THREADS-1]),
      .scout(sov[ex6_tid_offset : ex6_tid_offset + `THREADS-1]),
      .din(ex6_tid_d),
      .dout(ex6_tid_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spec_flush_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_spec_flush_offset : ex1_spec_flush_offset + `THREADS-1]),
      .scout(sov[ex1_spec_flush_offset : ex1_spec_flush_offset + `THREADS-1]),
      .din(rv_xu0_ex0_spec_flush),
      .dout(ex1_spec_flush_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_spec_flush_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_spec_flush_offset : ex2_spec_flush_offset + `THREADS-1]),
      .scout(sov[ex2_spec_flush_offset : ex2_spec_flush_offset + `THREADS-1]),
      .din(rv_xu0_ex1_spec_flush),
      .dout(ex2_spec_flush_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_spec_flush_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_spec_flush_offset : ex3_spec_flush_offset + `THREADS-1]),
      .scout(sov[ex3_spec_flush_offset : ex3_spec_flush_offset + `THREADS-1]),
      .din(rv_xu0_ex2_spec_flush),
      .dout(ex3_spec_flush_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ord_async_flush_before_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ord_async_flush_before_offset : ord_async_flush_before_offset + `THREADS-1]),
      .scout(sov[ord_async_flush_before_offset : ord_async_flush_before_offset + `THREADS-1]),
      .din(ord_async_flush_before_d),
      .dout(ord_async_flush_before_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ord_async_flush_after_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ord_async_flush_after_offset : ord_async_flush_after_offset + `THREADS-1]),
      .scout(sov[ord_async_flush_after_offset : ord_async_flush_after_offset + `THREADS-1]),
      .din(ord_async_flush_after_d),
      .dout(ord_async_flush_after_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_async_credit_wait_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_async_credit_wait_offset]),
      .scout(sov[ord_async_credit_wait_offset]),
      .din(ord_async_credit_wait_d),
      .dout(ord_async_credit_wait_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) async_flush_req_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[async_flush_req_offset : async_flush_req_offset + `THREADS-1]),
      .scout(sov[async_flush_req_offset : async_flush_req_offset + `THREADS-1]),
      .din(async_flush_req_d),
      .dout(async_flush_req_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) async_flush_req_2_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[async_flush_req_2_offset : async_flush_req_2_offset + `THREADS-1]),
      .scout(sov[async_flush_req_2_offset : async_flush_req_2_offset + `THREADS-1]),
      .din(async_flush_req_q),
      .dout(async_flush_req_2_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) iu_async_complete_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[iu_async_complete_offset : iu_async_complete_offset + `THREADS-1]),
      .scout(sov[iu_async_complete_offset : iu_async_complete_offset + `THREADS-1]),
      .din(iu_xu_async_complete),
      .dout(iu_async_complete_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_xu_credits_returned_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_xu_credits_returned_offset]),
      .scout(sov[iu_xu_credits_returned_offset]),
      .din(iu_xu_credits_returned),
      .dout(iu_xu_credits_returned_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_any_mfspr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_any_mfspr_offset]),
      .scout(sov[ex2_any_mfspr_offset]),
      .din(ex1_any_mfspr),
      .dout(ex2_any_mfspr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_any_mfspr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_any_mfspr_offset]),
      .scout(sov[ex3_any_mfspr_offset]),
      .din(ex2_any_mfspr),
      .dout(ex3_any_mfspr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_any_mtspr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_any_mtspr_offset]),
      .scout(sov[ex2_any_mtspr_offset]),
      .din(ex1_any_mtspr),
      .dout(ex2_any_mtspr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_any_mtspr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_any_mtspr_offset]),
      .scout(sov[ex3_any_mtspr_offset]),
      .din(ex2_any_mtspr),
      .dout(ex3_any_mtspr_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_perf_event_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_perf_event_offset : ex4_perf_event_offset + 4-1]),
      .scout(sov[ex4_perf_event_offset : ex4_perf_event_offset + 4-1]),
      .din(ex3_perf_event),
      .dout(ex4_perf_event_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_any_mfspr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_any_mfspr_offset]),
      .scout(sov[ord_any_mfspr_offset]),
      .din(ex1_any_mfspr),
      .dout(ord_any_mfspr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ord_any_mtspr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_ord_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ord_any_mtspr_offset]),
      .scout(sov[ord_any_mtspr_offset]),
      .din(ex1_any_mtspr),
      .dout(ord_any_mtspr_q)
   );
   tri_rlmreg_p #(.WIDTH(6), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ord_timer_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_outstanding_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ord_timer_offset : ord_timer_offset + 6-1]),
      .scout(sov[ord_timer_offset : ord_timer_offset + 6-1]),
      .din(ord_timer_d),
      .dout(ord_timer_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ord_timeout_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ord_timeout_offset : ord_timeout_offset + 2-1]),
      .scout(sov[ord_timeout_offset : ord_timeout_offset + 2-1]),
      .din(ord_timeout_d),
      .dout(ord_timeout_q)
   );

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];

   assign unused = |{rv_xu0_ex0_t2_p[0:1],rv_xu0_ex0_t3_p[0]};
   assign ord_core_block_d = 1'b0;

endmodule
