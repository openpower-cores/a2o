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

//********************************************************************
//*
//* TITLE: Branch Unit
//*
//* NAME: xu0_br.vhdl
//*
//*********************************************************************
`include "tri_a2o.vh"


module xu0_br(
   vdd,
   gnd,
   nclk,
   pc_br_func_sl_thold_2,
   pc_br_sg_2,
   clkoff_b,
   act_dis,
   tc_ac_ccflush_dc,
   d_mode,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   scan_in,
   scan_out,
   rv_br_vld,
   rv_br_ex0_fusion,
   rv_br_ex0_instr,
   rv_br_ex0_ifar,
   rv_br_ex0_itag,
   rv_br_ex0_t2_p,
   rv_br_ex0_t3_p,
   rv_br_ex0_bta_val,
   rv_br_ex0_pred_bta,
   rv_br_ex0_pred,
   rv_br_ex0_ls_ptr,
   rv_br_ex0_gshare,
   rv_br_ex0_bh_update,
   rv_br_ex0_spec_flush,
   rv_br_ex1_spec_flush,
   bp_br_ex2_abort,
   dec_br_ex0_act,
   byp_br_ex2_cr1,
   byp_br_ex2_cr2,
   byp_br_ex2_cr3,
   byp_br_ex2_lr1,
   byp_br_ex2_lr2,
   byp_br_ex2_ctr,
   mux_br_ex3_cr,
   br_lr_we,
   br_lr_wd,
   br_ctr_we,
   br_ctr_wd,
   br_cr_we,
   br_cr_wd,
   br_iu_execute_vld,
   br_iu_itag,
   br_iu_taken,
   br_iu_bta,
   br_iu_ls_ptr,
   br_iu_ls_data,
   br_iu_ls_update,
   br_iu_gshare,
   br_iu_perf_events,
   br_iu_redirect,
   perf_event_en,
   spr_xesr2,
   spr_msr_cm,
   br_dec_ex3_execute_vld,
   iu_br_t0_flush_ifar,
`ifndef THREADS1
   iu_br_t1_flush_ifar,
`endif
   iu_br_flush
);
//   parameter                     `EXPAND_TYPE = 2;
//   parameter                     `THREADS = 2;
//   parameter                     `EFF_IFAR_ARCH = 62;
//   parameter                     `EFF_IFAR_WIDTH = 20;
//   parameter                     `GPR_WIDTH = 64;
//   parameter                     `ITAG_SIZE_ENC = 7;
//   parameter                     `GPR_POOL_ENC = 6;
//   parameter                     `CTR_POOL_ENC = 3;
//   parameter                     `CR_POOL_ENC = 5;
//   parameter                     `LR_POOL_ENC = 3;
   // pervasive
   // synopsys translate_off
   // synopsys translate_on
   inout                         vdd;
   // synopsys translate_off
   // synopsys translate_on
   inout                         gnd;
   // synopsys translate_off
   (* pin_data="PIN_FUNCTION=/G_CLK/" *) // nclk
   // synopsys translate_on
   input [0:`NCLK_WIDTH-1] nclk;
   input                         pc_br_func_sl_thold_2;
   input                         pc_br_sg_2;
   input                         clkoff_b;
   input                         act_dis;
   input                         tc_ac_ccflush_dc;
   input                         d_mode;
   input                         delay_lclkr;
   input                         mpw1_b;
   input                         mpw2_b;
   // synopsys translate_off
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *) // scan_in
   // synopsys translate_on
   input                         scan_in;
   // synopsys translate_off
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) // scan_out
   // synopsys translate_on
   output                        scan_out;

   input [0:`THREADS-1]           rv_br_vld;
   input                         rv_br_ex0_fusion;
   input [0:31]                  rv_br_ex0_instr;
   input [62-`EFF_IFAR_WIDTH:61]  rv_br_ex0_ifar;
   input [0:`ITAG_SIZE_ENC-1]     rv_br_ex0_itag;
   input [0:`GPR_POOL_ENC-1]      rv_br_ex0_t2_p;
   input [0:`GPR_POOL_ENC-1]      rv_br_ex0_t3_p;
   input                         rv_br_ex0_bta_val;
   input [62-`EFF_IFAR_WIDTH:61]  rv_br_ex0_pred_bta;
   input                         rv_br_ex0_pred;
   input [0:2]                   rv_br_ex0_ls_ptr;
   input [0:17]                  rv_br_ex0_gshare;
   input                         rv_br_ex0_bh_update;
   input [0:`THREADS-1]           rv_br_ex0_spec_flush;
   input [0:`THREADS-1]           rv_br_ex1_spec_flush;
   input		          bp_br_ex2_abort;

   input                         dec_br_ex0_act;
   input [0:3]                   byp_br_ex2_cr1;
   input [0:3]                   byp_br_ex2_cr2;
   input [0:3]                   byp_br_ex2_cr3;
   input [64-`GPR_WIDTH:63]       byp_br_ex2_lr1;
   input [64-`GPR_WIDTH:63]       byp_br_ex2_lr2;
   input [64-`GPR_WIDTH:63]       byp_br_ex2_ctr;
   input [0:3]                   mux_br_ex3_cr;

   output                        br_lr_we;
   output [64-`GPR_WIDTH:63]      br_lr_wd;
   output                        br_ctr_we;
   output [64-`GPR_WIDTH:63]      br_ctr_wd;
   output                        br_cr_we;
   output [0:3]                  br_cr_wd;

   output [0:`THREADS-1]          br_iu_execute_vld;
   output [0:`ITAG_SIZE_ENC-1]    br_iu_itag;
   output                        br_iu_taken;
   output [62-`EFF_IFAR_ARCH:61]  br_iu_bta;
   output [0:2]                  br_iu_ls_ptr;
   output [62-`EFF_IFAR_WIDTH:61] br_iu_ls_data;
   output                        br_iu_ls_update;
   output [0:17]                 br_iu_gshare;
   output [0:3]			 br_iu_perf_events;

   //early branch flush support
   output [0:`THREADS-1]          br_iu_redirect;

   input [0:`THREADS-1]		  perf_event_en;
   input [0:31]			  spr_xesr2;

   input [0:`THREADS-1]           spr_msr_cm;

   output [0:`THREADS-1]          br_dec_ex3_execute_vld;

   input [0:`THREADS-1]           iu_br_flush;

   input [62-`EFF_IFAR_ARCH : 61-`EFF_IFAR_WIDTH] iu_br_t0_flush_ifar;
`ifndef THREADS1
   input [62-`EFF_IFAR_ARCH : 61-`EFF_IFAR_WIDTH] iu_br_t1_flush_ifar;
`endif

      wire                          tiup;
      wire                          tidn;

      wire [0:3]                    ex3_cr1;
      wire [0:3]                    ex3_cr2;
      wire [0:3]                    ex3_cr3_branch;
      wire [0:3]                    ex3_cr3_logical;
      wire [64-`GPR_WIDTH:63]        ex3_ctr;
      wire [64-`GPR_WIDTH:63]        ex3_lr;

      wire [0:3]                    ex3_cr1_d;
      wire [0:3]                    ex3_cr2_d;
      wire [0:3]                    ex3_cr3_d;
      wire [64-`GPR_WIDTH:63]        ex3_ctr_d;
      wire [64-`GPR_WIDTH:63]        ex3_lr1_d;
      wire [64-`GPR_WIDTH:63]        ex3_lr2_d;

      wire [0:3]                    ex3_cr1_q;
      wire [0:3]                    ex3_cr2_q;
      wire [0:3]                    ex3_cr3_q;
      wire [64-`GPR_WIDTH:63]        ex3_ctr_q;
      wire [64-`GPR_WIDTH:63]        ex3_lr1_q;
      wire [64-`GPR_WIDTH:63]        ex3_lr2_q;

      wire [0:`THREADS-1]            ex0_vld_d;		// input=>rv_br_vld                      ,act=>tiup
      wire [0:`THREADS-1]            ex0_vld_q;		// input=>rv_br_vld                      ,act=>tiup

      wire                          ex1_act;
      wire [0:`THREADS-1]            ex1_vld_d;
      wire [0:`THREADS-1]            ex1_vld_q;
      wire                          ex1_fusion_d;
      wire                          ex1_fusion_q;
      wire [0:31]                   ex1_instr_d;
      wire [0:31]                   ex1_instr_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex1_ifar_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex1_ifar_q;
      wire [0:`ITAG_SIZE_ENC-1]      ex1_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]      ex1_itag_q;
      wire [0:`LR_POOL_ENC-1]        ex1_lr_wa_d;
      wire [0:`LR_POOL_ENC-1]        ex1_lr_wa_q;
      wire [0:`CTR_POOL_ENC-1]       ex1_ctr_wa_d;
      wire [0:`CTR_POOL_ENC-1]       ex1_ctr_wa_q;
      wire [0:`CR_POOL_ENC-1]        ex1_cr_wa_d;
      wire [0:`CR_POOL_ENC-1]        ex1_cr_wa_q;

      wire                          ex2_act;
      wire [0:`THREADS-1]            ex2_vld_d;
      wire [0:`THREADS-1]            ex2_vld_q;
      wire                          ex2_slow_d;
      wire                          ex2_slow_q;
      wire                          ex2_fusion_d;
      wire                          ex2_fusion_q;
      wire [0:31]                   ex2_instr_d;
      wire [0:31]                   ex2_instr_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex2_ifar_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex2_ifar_q;
      wire [0:`ITAG_SIZE_ENC-1]      ex2_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]      ex2_itag_q;
      wire [0:`LR_POOL_ENC-1]        ex2_lr_wa_d;
      wire [0:`LR_POOL_ENC-1]        ex2_lr_wa_q;
      wire [0:`CTR_POOL_ENC-1]       ex2_ctr_wa_d;
      wire [0:`CTR_POOL_ENC-1]       ex2_ctr_wa_q;
      wire [0:`CR_POOL_ENC-1]        ex2_cr_wa_d;
      wire [0:`CR_POOL_ENC-1]        ex2_cr_wa_q;

      wire                          ex3_act;
      wire [0:`THREADS-1]            ex3_vld_d;
      wire [0:`THREADS-1]            ex3_vld_q;
      wire                          ex3_slow_d;
      wire                          ex3_slow_q;
      wire                          ex3_fusion_d;
      wire                          ex3_fusion_q;
      wire [6:31]                   ex3_instr_d;
      wire [6:31]                   ex3_instr_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex3_ifar_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex3_ifar_q;
      wire [0:`ITAG_SIZE_ENC-1]      ex3_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]      ex3_itag_q;
      wire [0:`LR_POOL_ENC-1]        ex3_lr_wa_d;
      wire [0:`LR_POOL_ENC-1]        ex3_lr_wa_q;
      wire [0:`CTR_POOL_ENC-1]       ex3_ctr_wa_d;
      wire [0:`CTR_POOL_ENC-1]       ex3_ctr_wa_q;
      wire [0:`CR_POOL_ENC-1]        ex3_cr_wa_d;
      wire [0:`CR_POOL_ENC-1]        ex3_cr_wa_q;
      wire                          ex3_is_b_d;
      wire                          ex3_is_b_q;
      wire                          ex3_is_bc_d;
      wire                          ex3_is_bc_q;
      wire                          ex3_is_bclr_d;
      wire                          ex3_is_bclr_q;
      wire                          ex3_is_bcctr_d;
      wire                          ex3_is_bcctr_q;
      wire                          ex3_is_bctar_d;
      wire                          ex3_is_bctar_q;
      wire                          ex3_is_mcrf_d;
      wire                          ex3_is_mcrf_q;
      wire                          ex3_is_crand_d;
      wire                          ex3_is_crand_q;
      wire                          ex3_is_crandc_d;
      wire                          ex3_is_crandc_q;
      wire                          ex3_is_creqv_d;
      wire                          ex3_is_creqv_q;
      wire                          ex3_is_crnand_d;
      wire                          ex3_is_crnand_q;
      wire                          ex3_is_crnor_d;
      wire                          ex3_is_crnor_q;
      wire                          ex3_is_cror_d;
      wire                          ex3_is_cror_q;
      wire                          ex3_is_crorc_d;
      wire                          ex3_is_crorc_q;
      wire                          ex3_is_crxor_d;
      wire                          ex3_is_crxor_q;
      wire [62-`EFF_IFAR_ARCH : 61-`EFF_IFAR_WIDTH]            br_upper_ifar_d[0:`THREADS-1];
      wire [62-`EFF_IFAR_ARCH : 61-`EFF_IFAR_WIDTH]            br_upper_ifar_q[0:`THREADS-1];
      wire [62-`EFF_IFAR_ARCH : 61-`EFF_IFAR_WIDTH]            br_upper_ifar_mux[0:`THREADS-1];

      wire                          ex4_act;
      wire [0:`THREADS-1]            ex4_vld_d;
      wire [0:`THREADS-1]            ex4_vld_q;
      wire                          ex4_slow_d;
      wire                          ex4_slow_q;
      wire [0:`ITAG_SIZE_ENC-1]      ex4_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]      ex4_itag_q;
      wire [0:`LR_POOL_ENC-1]        ex4_lr_wa_d;
      wire [0:`LR_POOL_ENC-1]        ex4_lr_wa_q;
      wire [0:`CTR_POOL_ENC-1]       ex4_ctr_wa_d;
      wire [0:`CTR_POOL_ENC-1]       ex4_ctr_wa_q;
      wire [0:`CR_POOL_ENC-1]        ex4_cr_wa_d;
      wire [0:`CR_POOL_ENC-1]        ex4_cr_wa_q;
      wire                          ex4_taken_d;
      wire                          ex4_taken_q;
      wire [62-`EFF_IFAR_ARCH:61]    ex4_bta_d;
      wire [62-`EFF_IFAR_ARCH:61]    ex4_bta_q;
      wire                          ex4_lr_we_d;
      wire                          ex4_lr_we_q;
      wire [64-`GPR_WIDTH:63]        ex4_lr_wd_d;
      wire [64-`GPR_WIDTH:63]        ex4_lr_wd_q;
      wire                          ex4_ctr_we_d;
      wire                          ex4_ctr_we_q;
      wire [64-`GPR_WIDTH:63]        ex4_ctr_wd_d;
      wire [64-`GPR_WIDTH:63]        ex4_ctr_wd_q;
      wire                          ex4_cr_we_d;
      wire                          ex4_cr_we_q;
      wire [0:3]                    ex4_cr_wd_d;
      wire [0:3]                    ex4_cr_wd_q;
      wire [0:`THREADS-1]            spr_msr_cm_q;

      wire [0:4]                    ex3_bo;
      wire [0:4]                    ex3_bi;
      wire [62-`EFF_IFAR_ARCH:61]    ex3_bd;
      wire                          ex3_aa;
      wire                          ex3_lk;
      wire [0:1]                    ex3_bh;
      wire                          ex3_getNIA;

      wire [62-`EFF_IFAR_ARCH:61]    ex2_bd;
      wire [62-`EFF_IFAR_ARCH:61]    ex2_li;
      wire                          ex2_aa;

      wire                          ex3_ctr_one;
      wire                          ex3_ctr_one_b;
      wire                          ex3_cr_bit;
      wire                          ex3_br_taken;

      wire [62-`EFF_IFAR_ARCH:61]    ex3_bta;
      wire [62-`EFF_IFAR_ARCH:61]    ex3_nia;

      wire [62-`EFF_IFAR_ARCH:61]    ex2_abs;
      wire [62-`EFF_IFAR_ARCH:61]    ex2_ifar;
      wire [62-`EFF_IFAR_ARCH:61]    ex2_off;
      wire [62-`EFF_IFAR_ARCH:61]    ex2_bta;
      wire [62-`EFF_IFAR_ARCH:61]    ex2_nia;
      wire [62-`EFF_IFAR_ARCH:61]    ex2_nia_pre;
      wire [62-`EFF_IFAR_ARCH:61]    ex3_bta_pre;
      wire [62-`EFF_IFAR_ARCH:61]    ex3_bta_d;
      wire [62-`EFF_IFAR_ARCH:61]    ex3_bta_q;
      wire [62-`EFF_IFAR_ARCH:61]    ex3_nia_d;
      wire [62-`EFF_IFAR_ARCH:61]    ex3_nia_q;

      wire [0:4]                    ex3_bt;
      wire [0:4]                    ex3_ba;
      wire [0:4]                    ex3_bb;

      wire                          ex3_cra;
      wire                          ex3_crb;
      wire                          ex3_crt;

      wire                          ex3_crand;
      wire                          ex3_crandc;
      wire                          ex3_creqv;
      wire                          ex3_crnand;
      wire                          ex3_crnor;
      wire                          ex3_cror;
      wire                          ex3_crorc;
      wire                          ex3_crxor;

      wire                          ex1_pred_d;
      wire                          ex1_pred_q;
      wire                          ex1_bta_val_d;
      wire                          ex1_bta_val_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex1_pred_bta_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex1_pred_bta_q;
      wire                          ex2_pred_d;
      wire                          ex2_pred_q;
      wire                          ex2_bta_val_d;
      wire                          ex2_bta_val_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex2_pred_bta_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex2_pred_bta_q;
      wire                          ex3_pred_d;
      wire                          ex3_pred_q;
      wire                          ex3_bta_val_d;
      wire                          ex3_bta_val_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex3_pred_bta_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex3_pred_bta_q;
      wire [0:`THREADS-1]            ex4_redirect_d;
      wire [0:`THREADS-1]            ex4_redirect_q;

      wire                          ex3_ls_push;
      wire                          ex3_ls_pop;
      wire                          ex3_ls_unpop;
      wire                          ex3_gshare_shift;

      wire [0:17]                   ex1_gshare_d;
      wire [0:17]                   ex1_gshare_q;
      wire [0:17]                   ex2_gshare_d;
      wire [0:17]                   ex2_gshare_q;
      wire [0:17]                   ex3_gshare_d;
      wire [0:17]                   ex3_gshare_q;
      wire [0:17]                   ex4_gshare_d;
      wire [0:17]                   ex4_gshare_q;
      wire                          ex1_bh_update_d;
      wire                          ex1_bh_update_q;
      wire                          ex2_bh_update_d;
      wire                          ex2_bh_update_q;
      wire                          ex3_bh_update_d;
      wire                          ex3_bh_update_q;

      wire [0:2]                    ex1_ls_ptr_d;
      wire [0:2]                    ex1_ls_ptr_q;
      wire [0:2]                    ex2_ls_ptr_d;
      wire [0:2]                    ex2_ls_ptr_q;
      wire [0:2]                    ex3_ls_ptr_d;
      wire [0:2]                    ex3_ls_ptr_q;
      wire [0:2]                    ex4_ls_ptr_d;
      wire [0:2]                    ex4_ls_ptr_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex4_ls_data_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex4_ls_data_q;
      wire                          ex4_ls_update_d;
      wire                          ex4_ls_update_q;

      wire [0:`THREADS-1]            ex3_itag_priority;
      wire [0:`ITAG_SIZE_ENC-1]            ex4_itag_saved_d[0:`THREADS-1];
      wire [0:`ITAG_SIZE_ENC-1]            ex4_itag_saved_q[0:`THREADS-1];
      wire [0:`THREADS-1]            ex4_itag_saved_val_d;
      wire [0:`THREADS-1]            ex4_itag_saved_val_q;

      wire [0:`THREADS-1]            iu_br_flush_d;
      wire [0:`THREADS-1]            iu_br_flush_q;
      wire [62-`EFF_IFAR_ARCH : 61-`EFF_IFAR_WIDTH]            iu_br_flush_ifar_d[0:`THREADS-1];
      wire [62-`EFF_IFAR_ARCH : 61-`EFF_IFAR_WIDTH]            iu_br_flush_ifar_q[0:`THREADS-1];

      wire [0:`THREADS-1]            ex0_vld;

      wire [0:3]	ex4_perf_event_d;	// wired OR
      wire [0:3]	ex4_perf_event_q;

      // scan chains

      parameter                     ex0_vld_offset = 0;
      parameter                     iu_br_flush_offset = ex0_vld_offset + `THREADS;
      parameter                     iu_br_flush_ifar_offset = iu_br_flush_offset + `THREADS;
      parameter                     ex4_itag_saved_offset = iu_br_flush_ifar_offset + `THREADS * (`EFF_IFAR_ARCH-`EFF_IFAR_WIDTH);
      parameter                     ex4_itag_saved_val_offset = ex4_itag_saved_offset + `THREADS * `ITAG_SIZE_ENC;
      parameter                     ex3_cr1_offset = ex4_itag_saved_val_offset + `THREADS;
      parameter                     ex3_cr2_offset = ex3_cr1_offset + 4;
      parameter                     ex3_cr3_offset = ex3_cr2_offset + 4;
      parameter                     ex3_ctr_offset = ex3_cr3_offset + 4;
      parameter                     ex3_lr1_offset = ex3_ctr_offset + (-1+`GPR_WIDTH+1);
      parameter                     ex3_lr2_offset = ex3_lr1_offset + (-1+`GPR_WIDTH+1);
      parameter                     ex1_vld_offset = ex3_lr2_offset + (-1+`GPR_WIDTH+1);
      parameter                     ex1_fusion_offset = ex1_vld_offset + `THREADS;
      parameter                     ex1_instr_offset = ex1_fusion_offset + 1;
      parameter                     ex1_ifar_offset = ex1_instr_offset + 32;
      parameter                     ex1_itag_offset = ex1_ifar_offset + (-1+`EFF_IFAR_WIDTH+1);
      parameter                     ex1_lr_wa_offset = ex1_itag_offset + `ITAG_SIZE_ENC;
      parameter                     ex1_cr_wa_offset = ex1_lr_wa_offset + `LR_POOL_ENC;
      parameter                     ex1_ctr_wa_offset = ex1_cr_wa_offset + `CR_POOL_ENC;
      parameter                     ex1_pred_offset = ex1_ctr_wa_offset + `CTR_POOL_ENC;
      parameter                     ex1_bta_val_offset = ex1_pred_offset + 1;
      parameter                     ex1_pred_bta_offset = ex1_bta_val_offset + 1;
      parameter                     ex1_bh_update_offset = ex1_pred_bta_offset + (-1+`EFF_IFAR_WIDTH+1);
      parameter                     ex1_gshare_offset = ex1_bh_update_offset + 1;
      parameter                     ex1_ls_ptr_offset = ex1_gshare_offset + 18;
      parameter                     ex2_vld_offset = ex1_ls_ptr_offset + 3;
      parameter                     ex2_slow_offset = ex2_vld_offset + `THREADS;
      parameter                     ex2_fusion_offset = ex2_slow_offset + 1;
      parameter                     ex2_instr_offset = ex2_fusion_offset + 1;
      parameter                     ex2_ifar_offset = ex2_instr_offset + 32;
      parameter                     ex2_itag_offset = ex2_ifar_offset + (-1+`EFF_IFAR_WIDTH+1);
      parameter                     ex2_lr_wa_offset = ex2_itag_offset + `ITAG_SIZE_ENC;
      parameter                     ex2_cr_wa_offset = ex2_lr_wa_offset + `LR_POOL_ENC;
      parameter                     ex2_ctr_wa_offset = ex2_cr_wa_offset + `CR_POOL_ENC;
      parameter                     ex2_pred_offset = ex2_ctr_wa_offset + `CTR_POOL_ENC;
      parameter                     ex2_bta_val_offset = ex2_pred_offset + 1;
      parameter                     ex2_pred_bta_offset = ex2_bta_val_offset + 1;
      parameter                     ex2_bh_update_offset = ex2_pred_bta_offset + (-1+`EFF_IFAR_WIDTH+1);
      parameter                     ex2_gshare_offset = ex2_bh_update_offset + 1;
      parameter                     ex2_ls_ptr_offset = ex2_gshare_offset + 18;
      parameter                     ex3_vld_offset = ex2_ls_ptr_offset + 3;
      parameter                     ex3_slow_offset = ex3_vld_offset + `THREADS;
      parameter                     ex3_fusion_offset = ex3_slow_offset + 1;
      parameter                     ex3_instr_offset = ex3_fusion_offset + 1;
      parameter                     ex3_ifar_offset = ex3_instr_offset + 26;
      parameter                     ex3_bta_offset = ex3_ifar_offset + (-1+`EFF_IFAR_WIDTH+1);
      parameter                     ex3_nia_offset = ex3_bta_offset + (-1+`EFF_IFAR_ARCH+1);
      parameter                     ex3_itag_offset = ex3_nia_offset + (-1+`EFF_IFAR_ARCH+1);
      parameter                     ex3_lr_wa_offset = ex3_itag_offset + `ITAG_SIZE_ENC;
      parameter                     ex3_cr_wa_offset = ex3_lr_wa_offset + `LR_POOL_ENC;
      parameter                     ex3_ctr_wa_offset = ex3_cr_wa_offset + `CR_POOL_ENC;
      parameter                     ex3_pred_offset = ex3_ctr_wa_offset + `CTR_POOL_ENC;
      parameter                     ex3_bta_val_offset = ex3_pred_offset + 1;
      parameter                     ex3_pred_bta_offset = ex3_bta_val_offset + 1;
      parameter                     ex3_bh_update_offset = ex3_pred_bta_offset + (-1+`EFF_IFAR_WIDTH+1);
      parameter                     ex3_gshare_offset = ex3_bh_update_offset + 1;
      parameter                     ex3_ls_ptr_offset = ex3_gshare_offset + 18;
      parameter                     ex3_is_b_offset = ex3_ls_ptr_offset + 3;
      parameter                     ex3_is_bc_offset = ex3_is_b_offset + 1;
      parameter                     ex3_is_bclr_offset = ex3_is_bc_offset + 1;
      parameter                     ex3_is_bcctr_offset = ex3_is_bclr_offset + 1;
      parameter                     ex3_is_bctar_offset = ex3_is_bcctr_offset + 1;
      parameter                     ex3_is_mcrf_offset = ex3_is_bctar_offset + 1;
      parameter                     ex3_is_crand_offset = ex3_is_mcrf_offset + 1;
      parameter                     ex3_is_crandc_offset = ex3_is_crand_offset + 1;
      parameter                     ex3_is_creqv_offset = ex3_is_crandc_offset + 1;
      parameter                     ex3_is_crnand_offset = ex3_is_creqv_offset + 1;
      parameter                     ex3_is_crnor_offset = ex3_is_crnand_offset + 1;
      parameter                     ex3_is_cror_offset = ex3_is_crnor_offset + 1;
      parameter                     ex3_is_crorc_offset = ex3_is_cror_offset + 1;
      parameter                     ex3_is_crxor_offset = ex3_is_crorc_offset + 1;
      parameter                     br_upper_ifar_offset = ex3_is_crxor_offset + 1;
      parameter                     ex4_vld_offset = br_upper_ifar_offset + `THREADS * (`EFF_IFAR_ARCH-`EFF_IFAR_WIDTH);
      parameter                     ex4_slow_offset = ex4_vld_offset + `THREADS;
      parameter                     ex4_itag_offset = ex4_slow_offset + 1;
      parameter                     ex4_lr_wa_offset = ex4_itag_offset + `ITAG_SIZE_ENC;
      parameter                     ex4_cr_wa_offset = ex4_lr_wa_offset + `LR_POOL_ENC;
      parameter                     ex4_ctr_wa_offset = ex4_cr_wa_offset + `CR_POOL_ENC;
      parameter                     ex4_taken_offset = ex4_ctr_wa_offset + `CTR_POOL_ENC;
      parameter                     ex4_bta_offset = ex4_taken_offset + 1;
      parameter                     ex4_gshare_offset = ex4_bta_offset + (-1+`EFF_IFAR_ARCH+1);
      parameter                     ex4_ls_ptr_offset = ex4_gshare_offset + 18;
      parameter                     ex4_ls_data_offset = ex4_ls_ptr_offset + 3;
      parameter                     ex4_ls_update_offset = ex4_ls_data_offset + (-1+`EFF_IFAR_WIDTH+1);
      parameter                     ex4_redirect_offset = ex4_ls_update_offset + 1;
      parameter                     ex4_lr_we_offset = ex4_redirect_offset + `THREADS;
      parameter                     ex4_lr_wd_offset = ex4_lr_we_offset + 1;
      parameter                     ex4_cr_we_offset = ex4_lr_wd_offset + (-1+`GPR_WIDTH+1);
      parameter                     ex4_cr_wd_offset = ex4_cr_we_offset + 1;
      parameter                     ex4_perf_event_offset = ex4_cr_wd_offset + 4;
      parameter                     spr_msr_cm_offset = ex4_perf_event_offset + 4;
      parameter                     ex4_ctr_we_offset = spr_msr_cm_offset + `THREADS;
      parameter                     ex4_ctr_wd_offset = ex4_ctr_we_offset + 1;
      parameter                     scan_right = ex4_ctr_wd_offset + (-1+`GPR_WIDTH+1);

      wire [0:scan_right-1]         siv;
      wire [0:scan_right-1]         sov;

      wire                          func_sl_thold_1;
      wire                          func_sl_thold_0;
      wire                          func_sl_thold_0_b;
      wire                          sg_1;
      wire                          sg_0;
      wire                          force_t;

   //!! Bugspray Include: xu0_br;

      assign tiup = 1'b1;
      assign tidn = 1'b0;

      assign iu_br_flush_d = iu_br_flush;
      assign iu_br_flush_ifar_d[0] = iu_br_t0_flush_ifar;
`ifndef THREADS1
      assign iu_br_flush_ifar_d[1] = iu_br_t1_flush_ifar;
`endif

      assign ex0_vld_d = rv_br_vld & (~iu_br_flush_q);

      // Kill valid and act's for non branch ops
assign ex0_vld = (dec_br_ex0_act ? ex0_vld_q : `THREADS'b0 );

assign ex1_vld_d = (rv_br_ex0_fusion | |(ex1_vld_q) ? ex0_vld & (~iu_br_flush_q) & (~rv_br_ex0_spec_flush) : `THREADS'b0 );
      assign ex1_act = |(ex0_vld & (~iu_br_flush_q));
      assign ex1_fusion_d = rv_br_ex0_fusion;
      assign ex1_instr_d = rv_br_ex0_instr;
      assign ex1_ifar_d = rv_br_ex0_ifar;
      assign ex1_itag_d = rv_br_ex0_itag;
      assign ex1_lr_wa_d = rv_br_ex0_t3_p[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1];
      assign ex1_ctr_wa_d = rv_br_ex0_t2_p[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1];
      assign ex1_cr_wa_d = rv_br_ex0_t3_p[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1];
      assign ex1_pred_d = rv_br_ex0_pred;
      assign ex1_bta_val_d = rv_br_ex0_bta_val;
      assign ex1_pred_bta_d = rv_br_ex0_pred_bta;
      assign ex1_ls_ptr_d = rv_br_ex0_ls_ptr;
      assign ex1_bh_update_d = rv_br_ex0_bh_update;
      assign ex1_gshare_d = rv_br_ex0_gshare;

      assign ex2_vld_d = (|(ex1_vld_q) == 1'b1) ? ex1_vld_q & (~iu_br_flush_q) & (~rv_br_ex1_spec_flush) :
                         (rv_br_ex0_fusion == 1'b0) ? ex0_vld & (~iu_br_flush_q) & (~rv_br_ex0_spec_flush) :
                         `THREADS'b0;
      assign ex2_act = |((ex0_vld | ex1_vld_q) & (~iu_br_flush_q));
      assign ex2_slow_d = (|(ex1_vld_q) == 1'b1) ? 1'b1 :
                          1'b0;
      assign ex2_fusion_d = (|(ex1_vld_q) == 1'b1) ? ex1_fusion_q :
                            rv_br_ex0_fusion;
      assign ex2_instr_d = (|(ex1_vld_q) == 1'b1) ? ex1_instr_q :
                           rv_br_ex0_instr;
      assign ex2_ifar_d = (|(ex1_vld_q) == 1'b1) ? ex1_ifar_q :
                          rv_br_ex0_ifar;
      assign ex2_itag_d = (|(ex1_vld_q) == 1'b1) ? ex1_itag_q :
                          rv_br_ex0_itag;
      assign ex2_lr_wa_d = (|(ex1_vld_q) == 1'b1) ? ex1_lr_wa_q :
                           rv_br_ex0_t3_p[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1];
      assign ex2_ctr_wa_d = (|(ex1_vld_q) == 1'b1) ? ex1_ctr_wa_q :
                            rv_br_ex0_t2_p[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1];
      assign ex2_cr_wa_d = (|(ex1_vld_q) == 1'b1) ? ex1_cr_wa_q :
                           rv_br_ex0_t3_p[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1];
      assign ex2_pred_d = (|(ex1_vld_q) == 1'b1) ? ex1_pred_q :
                          rv_br_ex0_pred;
      assign ex2_bta_val_d = (|(ex1_vld_q) == 1'b1) ? ex1_bta_val_q :
                             rv_br_ex0_bta_val;
      assign ex2_pred_bta_d = (|(ex1_vld_q) == 1'b1) ? ex1_pred_bta_q :
                              rv_br_ex0_pred_bta;
      assign ex2_ls_ptr_d = (|(ex1_vld_q) == 1'b1) ? ex1_ls_ptr_q :
                            rv_br_ex0_ls_ptr;
      assign ex2_bh_update_d = (|(ex1_vld_q) == 1'b1) ? ex1_bh_update_q :
                               rv_br_ex0_bh_update;
      assign ex2_gshare_d = (|(ex1_vld_q) == 1'b1) ? ex1_gshare_q :
                            rv_br_ex0_gshare;

      assign ex3_vld_d = (ex2_slow_q == 1'b1) ? ex2_vld_q & (~iu_br_flush_q) & {`THREADS{(~bp_br_ex2_abort)}}:
                         ex2_vld_q & (~iu_br_flush_q) & (~rv_br_ex1_spec_flush);
      assign ex3_act = |(ex2_vld_q & (~iu_br_flush_q));
      assign ex3_slow_d = ex2_slow_q;
      assign ex3_fusion_d = ex2_fusion_q;
      assign ex3_instr_d[6:31] = ex2_instr_q[6:31];
      assign ex3_ifar_d = ex2_ifar_q;
      assign ex3_itag_d = ex2_itag_q;
      assign ex3_lr_wa_d = ex2_lr_wa_q;
      assign ex3_ctr_wa_d = ex2_ctr_wa_q;
      assign ex3_cr_wa_d = ex2_cr_wa_q;
      assign ex3_pred_d = ex2_pred_q;
      assign ex3_bta_val_d = ex2_bta_val_q;
      assign ex3_pred_bta_d = ex2_pred_bta_q;
      assign ex3_ls_ptr_d = ex2_ls_ptr_q;
      assign ex3_bh_update_d = ex2_bh_update_q;
      assign ex3_gshare_d = ex2_gshare_q;

      assign ex4_vld_d = (ex3_slow_q & (ex3_is_b_q | ex3_is_bc_q | ex3_is_bclr_q | ex3_is_bcctr_q | ex3_is_bctar_q | ex3_is_crand_q | ex3_is_crandc_q | ex3_is_creqv_q | ex3_is_crnand_q | ex3_is_crnor_q | ex3_is_cror_q | ex3_is_crorc_q | ex3_is_crxor_q | ex3_is_mcrf_q) ? ex3_vld_q & (~iu_br_flush_q) :
			  (ex3_is_b_q | ex3_is_bc_q | ex3_is_bclr_q | ex3_is_bcctr_q | ex3_is_bctar_q | ex3_is_crand_q | ex3_is_crandc_q | ex3_is_creqv_q | ex3_is_crnand_q | ex3_is_crnor_q | ex3_is_cror_q | ex3_is_crorc_q | ex3_is_crxor_q | ex3_is_mcrf_q) ? ex3_vld_q & (~iu_br_flush_q) & {`THREADS{(~bp_br_ex2_abort)}} :
 `THREADS'b0 );

      assign ex4_act = |(ex4_vld_d);
      assign ex4_slow_d = ex3_slow_q;
      assign ex4_itag_d = ex3_itag_q;
      assign ex4_lr_wa_d = ex3_lr_wa_q;
      assign ex4_ctr_wa_d = ex3_ctr_wa_q;
      assign ex4_cr_wa_d = ex3_cr_wa_q;

      assign br_iu_execute_vld = ex4_vld_q;
      assign br_iu_itag = ex4_itag_q;
      assign br_iu_taken = ex4_taken_q;
      assign br_iu_bta = ex4_bta_q;
      assign br_iu_redirect = ex4_redirect_q;

      assign br_iu_gshare = ex4_gshare_q;
      assign br_iu_ls_ptr = ex4_ls_ptr_q;
      assign br_iu_ls_data = ex4_ls_data_q;
      assign br_iu_ls_update = ex4_ls_update_q;

      assign br_lr_we = (ex3_slow_q == 1'b1) ? ex4_lr_we_d :
                        (ex4_slow_q == 1'b0) ? ex4_lr_we_q :
                        1'b0;
      assign br_lr_wd = (ex3_slow_q == 1'b1) ? ex4_lr_wd_d :
                        ex4_lr_wd_q;
      assign br_ctr_we = (ex3_slow_q == 1'b1) ? ex4_ctr_we_d :
                         (ex4_slow_q == 1'b0) ? ex4_ctr_we_q :
                         1'b0;
      assign br_ctr_wd = (ex3_slow_q == 1'b1) ? ex4_ctr_wd_d :
                         ex4_ctr_wd_q;
      assign br_cr_we = (ex3_slow_q == 1'b1) ? ex4_cr_we_d :
                        (ex4_slow_q == 1'b0) ? ex4_cr_we_q :
                        1'b0;
      assign br_cr_wd = (ex3_slow_q == 1'b1) ? ex4_cr_wd_d :
                        ex4_cr_wd_q;

      assign br_dec_ex3_execute_vld = (ex3_slow_q == 1'b1) ? ex4_vld_d :
                                      (ex4_slow_q == 1'b0) ? ex4_vld_q :
                                      `THREADS'b0;
      //-----------------------------------------------
      // SPR bypass
      //-----------------------------------------------

      assign ex3_cr1_d = byp_br_ex2_cr1;
      assign ex3_cr2_d = byp_br_ex2_cr2;
      assign ex3_cr3_d = byp_br_ex2_cr3;
      assign ex3_ctr_d = byp_br_ex2_ctr;
      assign ex3_lr1_d = byp_br_ex2_lr1;
      assign ex3_lr2_d = byp_br_ex2_lr2;

      assign ex3_cr1 = (ex3_slow_q == 1'b1) ? ex3_cr1_q :
                       ex3_cr1_d;
      assign ex3_cr2 = (ex3_slow_q == 1'b1) ? ex3_cr2_q :
                       ex3_cr2_d;
      assign ex3_cr3_branch = (ex3_fusion_q == 1'b1) ? mux_br_ex3_cr :
                              (ex3_slow_q == 1'b1) ? ex3_cr3_q :
                              ex3_cr3_d;
      assign ex3_cr3_logical = (ex3_slow_q == 1'b1) ? ex3_cr3_q :
                               ex3_cr3_d;
      assign ex3_ctr = (ex3_slow_q == 1'b1) ? ex3_ctr_q :
                       ex3_ctr_d;
      assign ex3_lr = (ex3_fusion_q == 1'b1) ? ex3_lr2_q :
                      (ex3_slow_q == 1'b1) ? ex3_lr1_q :
                      ex3_lr1_d;

      //-----------------------------------------------
      // decode branch instruction
      //-----------------------------------------------

      assign ex3_is_b_d = ex2_instr_q[0:5] == 6'b010010;		// 18
      assign ex3_is_bc_d = ex2_instr_q[0:5] == 6'b010000;		// 16
      assign ex3_is_bclr_d = ex2_instr_q[0:5] == 6'b010011 & ex2_instr_q[21:30] == 10'b0000010000;		// 19/16
      assign ex3_is_bcctr_d = ex2_instr_q[0:5] == 6'b010011 & ex2_instr_q[21:30] == 10'b1000010000;		// 19/528
      assign ex3_is_bctar_d = ex2_instr_q[0:5] == 6'b010011 & ex2_instr_q[21:30] == 10'b1000110000;		// 19/560
      assign ex3_is_mcrf_d = ex2_instr_q[0:5] == 6'b010011 & ex2_instr_q[21:30] == 10'b0000000000;		// 19/0

      assign ex3_bo[0:4] = ex3_instr_q[6:10];
      assign ex3_bi[0:4] = ex3_instr_q[11:15];

      assign ex3_bd[62-`EFF_IFAR_ARCH:47] = {`EFF_IFAR_ARCH-14{ex3_instr_q[16]}};
      assign ex3_bd[48:61] = ex3_instr_q[16:29];

      assign ex3_aa = ex3_instr_q[30];
      assign ex3_lk = ex3_instr_q[31];
      assign ex3_bh[0:1] = ex3_instr_q[19:20];

      assign ex3_getNIA = ex3_is_bc_q == 1'b1 & ex3_bo[0:4] == 5'b10100 & ex3_bi[0:4] == 5'b11111 & ex3_bd[62 - `EFF_IFAR_ARCH:61] == 1 & ex3_aa == 1'b0 & ex3_lk == 1'b1;

      //do addition in ex2 for timing
      assign ex2_bd[62 - `EFF_IFAR_ARCH:47] = {`EFF_IFAR_ARCH-14{ex2_instr_q[16]}};
      assign ex2_bd[48:61] = ex2_instr_q[16:29];

      assign ex2_li[62 - `EFF_IFAR_ARCH:37] = {`EFF_IFAR_ARCH-24{ex2_instr_q[6]}};
      assign ex2_li[38:61] = ex2_instr_q[6:29];

      assign ex2_aa = ex2_instr_q[30];

      //-----------------------------------------------
      // calculate branch direction
      //-----------------------------------------------

      assign ex3_ctr_one = (~|(ex3_ctr[64 - `GPR_WIDTH:62])) & ex3_ctr[63];
      assign ex3_ctr_one_b = (~ex3_ctr_one);

      assign ex3_cr_bit = (ex3_cr3_branch[0] & ex3_bi[3:4] == 2'b00) | (ex3_cr3_branch[1] & ex3_bi[3:4] == 2'b01) | (ex3_cr3_branch[2] & ex3_bi[3:4] == 2'b10) | (ex3_cr3_branch[3] & ex3_bi[3:4] == 2'b11);

      assign ex3_br_taken = (ex3_bo[2] | (ex3_ctr_one_b ^ ex3_bo[3])) & (ex3_bo[0] | (ex3_cr_bit ~^ ex3_bo[1]));

      assign ex4_taken_d = ex3_is_b_q | ((ex3_is_bc_q | ex3_is_bclr_q | ex3_is_bcctr_q | ex3_is_bctar_q) & ex3_br_taken);

      //-----------------------------------------------
      // calculate branch target address
      //-----------------------------------------------

      assign ex2_abs = (ex3_is_b_d == 1'b1) ? ex2_li :
                       ex2_bd;

      generate
         begin : xhdl1
            genvar                        i;
            for (i = 0; i <= `THREADS - 1; i = i + 1)
            begin : thread_ifar
               if (i == 0)
               begin : i0
		   assign br_upper_ifar_mux[i] = (ex2_vld_q[i] ? br_upper_ifar_q[i] : {`EFF_IFAR_ARCH-`EFF_IFAR_WIDTH{1'b0}} );
               end

            if (i > 0)
            begin : i1
		assign br_upper_ifar_mux[i] = (ex2_vld_q[i] ? br_upper_ifar_q[i] : {`EFF_IFAR_ARCH-`EFF_IFAR_WIDTH{1'b0}} ) | br_upper_ifar_mux[i - 1];
            end
      end
   end
   endgenerate

   assign ex2_ifar = {br_upper_ifar_mux[`THREADS - 1], ex2_ifar_q[62 - `EFF_IFAR_WIDTH:61]};

   assign ex2_off = ex2_abs + ex2_ifar;

   assign ex2_bta = (ex2_aa == 1'b1) ? ex2_abs :
                    ex2_off;

   assign ex2_nia_pre = ex2_ifar + 1;

   generate
      begin : xhdl2
         genvar                        i;
         for (i = (62 - `EFF_IFAR_ARCH); i <= 61; i = i + 1)
         begin : ex3NIAMask
            if (i < 32)
            begin : R0
               assign ex2_nia[i] = (|(ex2_vld_q & spr_msr_cm_q) & ex2_nia_pre[i]);
            end
         if (i >= 32)
         begin : R1
            assign ex2_nia[i] = ex2_nia_pre[i];
         end
   end
end
endgenerate

assign ex3_bta_d = ex2_bta;
assign ex3_nia_d = ex2_nia;

assign ex3_bta_pre = (ex3_is_bclr_q == 1'b1 ? ex3_lr[62 - `EFF_IFAR_ARCH:61] : 0 ) | (ex3_is_bcctr_q == 1'b1 ? ex3_ctr[62 - `EFF_IFAR_ARCH:61] : 0 ) | (ex3_is_bctar_q == 1'b1 ? ex3_lr[62 - `EFF_IFAR_ARCH:61] : 0 ) | (ex3_is_b_q == 1'b1 | ex3_is_bc_q == 1'b1 ? ex3_bta_q[62 - `EFF_IFAR_ARCH:61] : 0 );

generate
   begin : xhdl3
      genvar                        i;
      for (i = (62 - `EFF_IFAR_ARCH); i <= 61; i = i + 1)
      begin : ex3BTAMask
         if (i < 32)
         begin : R0
            assign ex3_bta[i] = (|(ex3_vld_q & spr_msr_cm_q) & ex3_bta_pre[i]);
         end
      if (i >= 32)
      begin : R1
         assign ex3_bta[i] = ex3_bta_pre[i];
      end
end
end
endgenerate

	assign ex4_bta_d = (ex4_taken_d == 1'b1 ? ex3_bta[62 - `EFF_IFAR_ARCH:61] : 0 ) | (ex4_taken_d == 1'b0 ? ex3_nia_q[62 - `EFF_IFAR_ARCH:61] : 0 );

assign ex3_nia = ex3_nia_q;

//-----------------------------------------------
// early branch redirect
//-----------------------------------------------

generate
begin : xhdl4
   genvar                        i;
   for (i = 0; i <= (`THREADS - 1); i = i + 1)
   begin : br_thread

      assign ex4_redirect_d[i] = ex3_itag_priority[i] & (~iu_br_flush_q[i]) & ((ex4_taken_d ^ ex3_pred_q) | (ex4_taken_d & ex3_pred_q & (ex3_bta[62 - `EFF_IFAR_ARCH:61 - `EFF_IFAR_WIDTH] != br_upper_ifar_q[i])) | (ex4_taken_d & ex3_pred_q & ex3_bta_val_q & (ex3_bta != {br_upper_ifar_q[i], ex3_pred_bta_q})));

      assign ex3_itag_priority[i] = (ex3_vld_q[i] & ~(bp_br_ex2_abort & ~ex3_slow_q)) & ((ex3_itag_q[0] == ex4_itag_saved_q[i][0] & ex3_itag_q[1:`ITAG_SIZE_ENC - 1] < ex4_itag_saved_q[i][1:`ITAG_SIZE_ENC - 1]) | (ex3_itag_q[0] != ex4_itag_saved_q[i][0] & ex3_itag_q[1:`ITAG_SIZE_ENC - 1] > ex4_itag_saved_q[i][1:`ITAG_SIZE_ENC - 1]) | ((~ex4_itag_saved_val_q[i])));

      assign ex4_itag_saved_d[i] = (ex4_redirect_d[i] == 1'b1) ? ex3_itag_q :
                                   ex4_itag_saved_q[i];

      assign ex4_itag_saved_val_d[i] = (iu_br_flush_q[i] == 1'b1) ? 1'b0 :
                                       (ex4_redirect_d[i] == 1'b1) ? 1'b1 :
					ex4_itag_saved_val_q[i];

      assign br_upper_ifar_d[i] = iu_br_flush_ifar_q[i];

   end
end
endgenerate

//-----------------------------------------------
// link stack repair
//-----------------------------------------------

assign ex3_ls_push = |(ex4_vld_d) & ex4_taken_d & (~ex3_is_bclr_q) & ex3_lk & (~ex3_getNIA);
assign ex3_ls_pop = |(ex4_vld_d) & ex4_taken_d & ex3_is_bclr_q & ex3_bh[0:1] == 2'b00;
assign ex3_ls_unpop = |(ex4_vld_d) & (~ex4_taken_d) & ex3_is_bclr_q & ex3_bh[0:1] == 2'b00;

assign ex4_ls_ptr_d[0:2] = (ex3_ls_push == 1'b1 & ex3_ls_pop == 1'b0) ? ex3_ls_ptr_q[0:2] + 3'b001 :
                           (ex3_ls_push == 1'b0 & ex3_ls_pop == 1'b1) ? ex3_ls_ptr_q[0:2] - 3'b001 :
                           ex3_ls_ptr_q[0:2];

assign ex4_ls_data_d = (ex3_ls_unpop == 1'b1) ? ex3_pred_bta_q :
                       ex3_nia[62 - `EFF_IFAR_WIDTH:61];

assign ex4_ls_update_d = ex3_ls_push | ex3_ls_unpop;

//-----------------------------------------------
// gshare repair
//-----------------------------------------------

assign ex4_gshare_d[0:2] = (|(ex4_vld_d)) & (ex4_taken_d | (ex3_ifar_q[60:61] == 2'b11)) ? {ex4_taken_d, ex3_gshare_q[0:1]} :
                           ex3_gshare_q[0:2];

assign ex4_gshare_d[3:9] = (|(ex4_vld_d) & (ex4_taken_d | (ex3_ifar_q[60:61] == 2'b11)) & ex3_gshare_q[14:15] == 2'b11) ? ({ex3_gshare_q[2], 2'b00, ex3_gshare_q[3:6]}) :
                           (|(ex4_vld_d) & (ex4_taken_d | (ex3_ifar_q[60:61] == 2'b11)) & ex3_gshare_q[14:15] == 2'b10) ? ({ex3_gshare_q[2], 1'b0,  ex3_gshare_q[3:7]}) :
                           (|(ex4_vld_d) & (ex4_taken_d | (ex3_ifar_q[60:61] == 2'b11)) & ex3_gshare_q[14:15] == 2'b01) ? ({ex3_gshare_q[2],        ex3_gshare_q[3:8]}) :
                           (|(ex4_vld_d) & (ex4_taken_d | (ex3_ifar_q[60:61] == 2'b11)) & ex3_gshare_q[14:15] == 2'b00) ? ({                        ex3_gshare_q[3:9]}) :
                           ex3_gshare_q[3:9];


assign ex4_gshare_d[10:15] = (|(ex4_vld_d)) & (ex4_taken_d | (ex3_ifar_q[60:61] == 2'b11)) ? {ex3_gshare_q[16:17], ex3_gshare_q[10:13]} :
                           ex3_gshare_q[10:15];

assign ex4_gshare_d[16:17] = (|(ex4_vld_d)) & (ex4_taken_d | (ex3_ifar_q[60:61] == 2'b11)) ? 2'b00 :
                           ex3_gshare_q[16:17];


//-----------------------------------------------
// update registers
//-----------------------------------------------

assign ex4_lr_we_d = |(ex4_vld_d) & (ex3_is_b_q | ex3_is_bc_q | ex3_is_bclr_q | ex3_is_bcctr_q | ex3_is_bctar_q) & ex3_lk;
assign ex4_lr_wd_d = {ex3_nia[64 - `GPR_WIDTH:61], 2'b00};

assign ex4_ctr_we_d = |(ex4_vld_d) & (ex3_is_bc_q | ex3_is_bclr_q | ex3_is_bcctr_q | ex3_is_bctar_q) & (~ex3_bo[2]);
assign ex4_ctr_wd_d = ex3_ctr[64 - `GPR_WIDTH:63] - 1;

//-----------------------------------------------
// decode logical instruction
//-----------------------------------------------

assign ex3_is_crand_d = ex2_instr_q[0:5] == 6'b010011 & ex2_instr_q[21:30] == 10'b0100000001;		// 19/257
assign ex3_is_crandc_d = ex2_instr_q[0:5] == 6'b010011 & ex2_instr_q[21:30] == 10'b0010000001;		// 19/129
assign ex3_is_creqv_d = ex2_instr_q[0:5] == 6'b010011 & ex2_instr_q[21:30] == 10'b0100100001;		// 19/289
assign ex3_is_crnand_d = ex2_instr_q[0:5] == 6'b010011 & ex2_instr_q[21:30] == 10'b0011100001;		// 19/225
assign ex3_is_crnor_d = ex2_instr_q[0:5] == 6'b010011 & ex2_instr_q[21:30] == 10'b0000100001;		// 19/33
assign ex3_is_cror_d = ex2_instr_q[0:5] == 6'b010011 & ex2_instr_q[21:30] == 10'b0111000001;		// 19/449
assign ex3_is_crorc_d = ex2_instr_q[0:5] == 6'b010011 & ex2_instr_q[21:30] == 10'b0110100001;		// 19/417
assign ex3_is_crxor_d = ex2_instr_q[0:5] == 6'b010011 & ex2_instr_q[21:30] == 10'b0011000001;		// 19/193

//-----------------------------------------------
// calculate condition
//-----------------------------------------------

assign ex3_bt[0:4] = ex3_instr_q[6:10];
assign ex3_ba[0:4] = ex3_instr_q[11:15];
assign ex3_bb[0:4] = ex3_instr_q[16:20];

assign ex3_cra = (ex3_cr3_logical[0] & ex3_ba[3:4] == 2'b00) | (ex3_cr3_logical[1] & ex3_ba[3:4] == 2'b01) | (ex3_cr3_logical[2] & ex3_ba[3:4] == 2'b10) | (ex3_cr3_logical[3] & ex3_ba[3:4] == 2'b11);

assign ex3_crb = (ex3_cr2[0] & ex3_bb[3:4] == 2'b00) | (ex3_cr2[1] & ex3_bb[3:4] == 2'b01) | (ex3_cr2[2] & ex3_bb[3:4] == 2'b10) | (ex3_cr2[3] & ex3_bb[3:4] == 2'b11);

assign ex3_crand = ex3_cra & ex3_crb;
assign ex3_crandc = ex3_cra & (~ex3_crb);
assign ex3_creqv = ex3_cra ~^ ex3_crb;
assign ex3_crnand = ~(ex3_cra & ex3_crb);
assign ex3_crnor = ~(ex3_cra | ex3_crb);
assign ex3_cror = ex3_cra | ex3_crb;
assign ex3_crorc = ex3_cra | (~ex3_crb);
assign ex3_crxor = ex3_cra ^ ex3_crb;

assign ex3_crt = (ex3_crand & ex3_is_crand_q) | (ex3_crandc & ex3_is_crandc_q) | (ex3_creqv & ex3_is_creqv_q) | (ex3_crnand & ex3_is_crnand_q) | (ex3_crnor & ex3_is_crnor_q) | (ex3_cror & ex3_is_cror_q) | (ex3_crorc & ex3_is_crorc_q) | (ex3_crxor & ex3_is_crxor_q);

//-----------------------------------------------
// update registers
//-----------------------------------------------

assign ex4_cr_we_d = |(ex4_vld_d) & (ex3_is_crand_q | ex3_is_crandc_q | ex3_is_creqv_q | ex3_is_crnand_q | ex3_is_crnor_q | ex3_is_cror_q | ex3_is_crorc_q | ex3_is_crxor_q | ex3_is_mcrf_q);

assign ex4_cr_wd_d[0] = (ex3_is_mcrf_q == 1'b1) ? ex3_cr3_logical[0] :
                        (ex3_bt[3:4] == 2'b00) ? ex3_crt :
                        ex3_cr1[0];
assign ex4_cr_wd_d[1] = (ex3_is_mcrf_q == 1'b1) ? ex3_cr3_logical[1] :
                        (ex3_bt[3:4] == 2'b01) ? ex3_crt :
                        ex3_cr1[1];
assign ex4_cr_wd_d[2] = (ex3_is_mcrf_q == 1'b1) ? ex3_cr3_logical[2] :
                        (ex3_bt[3:4] == 2'b10) ? ex3_crt :
                        ex3_cr1[2];
assign ex4_cr_wd_d[3] = (ex3_is_mcrf_q == 1'b1) ? ex3_cr3_logical[3] :
                        (ex3_bt[3:4] == 2'b11) ? ex3_crt :
                        ex3_cr1[3];



//-----------------------------------------------
// performance events
//-----------------------------------------------

assign br_iu_perf_events = ex4_perf_event_q;

//perf events
//1: all instructions executed
//2: all branches executed
//3: mispredicted branch direction
//4: taken branches
//5: mispredicted branch target (within current address range)
//6: mispredicted branch target (outside current address range)

generate begin : perf_event
   genvar  t,e;
   for (e=0;e<=3;e=e+1) begin : thread
      for (t=0;t<=`THREADS-1;t=t+1) begin : thread
         assign ex4_perf_event_d[e] =

(spr_xesr2[4*e+16*t:4*e+16*t+3] == 4'd1 ? (perf_event_en[t] & ex4_vld_d[t]) : 1'b0) |
(spr_xesr2[4*e+16*t:4*e+16*t+3] == 4'd2 ? (perf_event_en[t] & ex4_vld_d[t] & (ex3_is_b_q | ex3_is_bc_q | ex3_is_bclr_q | ex3_is_bcctr_q | ex3_is_bctar_q)) : 1'b0) |
(spr_xesr2[4*e+16*t:4*e+16*t+3] == 4'd3 ? (perf_event_en[t] & ex4_redirect_d[t] & (ex4_taken_d ^ ex3_pred_q)) : 1'b0) |
(spr_xesr2[4*e+16*t:4*e+16*t+3] == 4'd4 ? (perf_event_en[t] & ex4_vld_d[t] & ex4_taken_d) : 1'b0) |
(spr_xesr2[4*e+16*t:4*e+16*t+3] == 4'd5 ? (perf_event_en[t] & ex4_redirect_d[t] & (ex4_taken_d & ex3_pred_q & (ex3_bta[62 - `EFF_IFAR_ARCH:61 - `EFF_IFAR_WIDTH] == br_upper_ifar_q[t]))) : 1'b0) |
(spr_xesr2[4*e+16*t:4*e+16*t+3] == 4'd6 ? (perf_event_en[t] & ex4_redirect_d[t] & (ex4_taken_d & ex3_pred_q & (ex3_bta[62 - `EFF_IFAR_ARCH:61 - `EFF_IFAR_WIDTH] != br_upper_ifar_q[t]))) : 1'b0);
      end
   end
end
endgenerate

//-----------------------------------------------
// latches
//-----------------------------------------------

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ex0_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .d_mode(d_mode),
   .delay_lclkr(delay_lclkr),
   .mpw1_b(mpw1_b),
   .mpw2_b(mpw2_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .force_t(force_t),
   .scin(siv[ex0_vld_offset:ex0_vld_offset + `THREADS - 1]),
   .scout(sov[ex0_vld_offset:ex0_vld_offset + `THREADS - 1]),
   .din(ex0_vld_d),
   .dout(ex0_vld_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu_br_flush_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .d_mode(d_mode),
   .delay_lclkr(delay_lclkr),
   .mpw1_b(mpw1_b),
   .mpw2_b(mpw2_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .force_t(force_t),
   .scin(siv[iu_br_flush_offset:iu_br_flush_offset + `THREADS - 1]),
   .scout(sov[iu_br_flush_offset:iu_br_flush_offset + `THREADS - 1]),
   .din(iu_br_flush_d),
   .dout(iu_br_flush_q)
);

generate
   begin : xhdl5
      genvar                        i;
      for (i = 0; i <= `THREADS - 1; i = i + 1)
      begin : thread_regs


         tri_rlmreg_p #(.WIDTH((`EFF_IFAR_ARCH-`EFF_IFAR_WIDTH)), .INIT(0)) iu_br_flush_ifar_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(iu_br_flush[i]),
            .d_mode(d_mode),
            .delay_lclkr(delay_lclkr),
            .mpw1_b(mpw1_b),
            .mpw2_b(mpw2_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .force_t(force_t),
            .scin(siv[iu_br_flush_ifar_offset + i * (`EFF_IFAR_ARCH-`EFF_IFAR_WIDTH):iu_br_flush_ifar_offset + (i + 1) * (`EFF_IFAR_ARCH-`EFF_IFAR_WIDTH) - 1]),
            .scout(sov[iu_br_flush_ifar_offset + i * (`EFF_IFAR_ARCH-`EFF_IFAR_WIDTH):iu_br_flush_ifar_offset + (i + 1) * (`EFF_IFAR_ARCH-`EFF_IFAR_WIDTH) - 1]),
            .din(iu_br_flush_ifar_d[i]),
            .dout(iu_br_flush_ifar_q[i])
         );

         genvar n;
         for (n = 0; n < (`EFF_IFAR_ARCH-`EFF_IFAR_WIDTH); n = n + 1)
         begin : q_depth_gen
            if((62-`EFF_IFAR_ARCH+n) > 31)
               tri_rlmlatch_p #(.INIT(1), .NEEDS_SRESET(1)) br_upper_ifar_latch(
                  .nclk(nclk),
                  .vd(vdd),
                  .gd(gnd),
                  .act(iu_br_flush_q[i]),
                  .d_mode(d_mode_dc),
                  .delay_lclkr(delay_lclkr_dc),
                  .mpw1_b(mpw1_dc_b),
                  .mpw2_b(mpw2_dc_b),
                  .thold_b(func_sl_thold_0_b),
                  .sg(sg_0),
                  .force_t(force_t),
                  .scin(siv[br_upper_ifar_offset + i*(`EFF_IFAR_ARCH-`EFF_IFAR_WIDTH) + n]),
                  .scout(sov[br_upper_ifar_offset + i*(`EFF_IFAR_ARCH-`EFF_IFAR_WIDTH) + n]),
                  .din(br_upper_ifar_d[i][(62-`EFF_IFAR_ARCH+n)]),
                  .dout(br_upper_ifar_q[i][(62-`EFF_IFAR_ARCH+n)])
               );
            else
               tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) br_upper_ifar_latch(
                  .nclk(nclk),
                  .vd(vdd),
                  .gd(gnd),
                  .act(iu_br_flush_q[i]),
                  .d_mode(d_mode_dc),
                  .delay_lclkr(delay_lclkr_dc),
                  .mpw1_b(mpw1_dc_b),
                  .mpw2_b(mpw2_dc_b),
                  .thold_b(func_sl_thold_0_b),
                  .sg(sg_0),
                  .force_t(force_t),
                  .scin(siv[br_upper_ifar_offset + i*(`EFF_IFAR_ARCH-`EFF_IFAR_WIDTH) + n]),
                  .scout(sov[br_upper_ifar_offset + i*(`EFF_IFAR_ARCH-`EFF_IFAR_WIDTH) + n]),
                  .din(br_upper_ifar_d[i][(62-`EFF_IFAR_ARCH+n)]),
                  .dout(br_upper_ifar_q[i][(62-`EFF_IFAR_ARCH+n)])
               );
	 end



         tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) ex4_itag_saved_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(tiup),
            .d_mode(d_mode),
            .delay_lclkr(delay_lclkr),
            .mpw1_b(mpw1_b),
            .mpw2_b(mpw2_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .force_t(force_t),
            .scin(siv[ex4_itag_saved_offset + i * `ITAG_SIZE_ENC:ex4_itag_saved_offset + (i + 1) * `ITAG_SIZE_ENC - 1]),
            .scout(sov[ex4_itag_saved_offset + i * `ITAG_SIZE_ENC:ex4_itag_saved_offset + (i + 1) * `ITAG_SIZE_ENC - 1]),
            .din(ex4_itag_saved_d[i]),
            .dout(ex4_itag_saved_q[i])
         );
      end
   end
   endgenerate


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) ex3_cr1_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_cr1_offset:ex3_cr1_offset + 4 - 1]),
      .scout(sov[ex3_cr1_offset:ex3_cr1_offset + 4 - 1]),
      .din(ex3_cr1_d),
      .dout(ex3_cr1_q)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) ex3_cr2_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_cr2_offset:ex3_cr2_offset + 4 - 1]),
      .scout(sov[ex3_cr2_offset:ex3_cr2_offset + 4 - 1]),
      .din(ex3_cr2_d),
      .dout(ex3_cr2_q)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) ex3_cr3_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_cr3_offset:ex3_cr3_offset + 4 - 1]),
      .scout(sov[ex3_cr3_offset:ex3_cr3_offset + 4 - 1]),
      .din(ex3_cr3_d),
      .dout(ex3_cr3_q)
   );


   tri_rlmreg_p #(.WIDTH((-1+`GPR_WIDTH+1)), .INIT(0)) ex3_ctr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_ctr_offset:ex3_ctr_offset + (-1+`GPR_WIDTH+1) - 1]),
      .scout(sov[ex3_ctr_offset:ex3_ctr_offset + (-1+`GPR_WIDTH+1) - 1]),
      .din(ex3_ctr_d),
      .dout(ex3_ctr_q)
   );

   tri_rlmreg_p #(.WIDTH((-1+`GPR_WIDTH+1)), .INIT(0)) ex3_lr1_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_lr1_offset:ex3_lr1_offset + (-1+`GPR_WIDTH+1) - 1]),
      .scout(sov[ex3_lr1_offset:ex3_lr1_offset + (-1+`GPR_WIDTH+1) - 1]),
      .din(ex3_lr1_d),
      .dout(ex3_lr1_q)
   );


   tri_rlmreg_p #(.WIDTH((-1+`GPR_WIDTH+1)), .INIT(0)) ex3_lr2_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_lr2_offset:ex3_lr2_offset + (-1+`GPR_WIDTH+1) - 1]),
      .scout(sov[ex3_lr2_offset:ex3_lr2_offset + (-1+`GPR_WIDTH+1) - 1]),
      .din(ex3_lr2_d),
      .dout(ex3_lr2_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ex1_vld_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex1_vld_offset:ex1_vld_offset + `THREADS - 1]),
      .scout(sov[ex1_vld_offset:ex1_vld_offset + `THREADS - 1]),
      .din(ex1_vld_d),
      .dout(ex1_vld_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex1_fusion_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex1_fusion_offset]),
      .scout(sov[ex1_fusion_offset]),
      .din(ex1_fusion_d),
      .dout(ex1_fusion_q)
   );


   tri_rlmreg_p #(.WIDTH(32), .INIT(0)) ex1_instr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex1_instr_offset:ex1_instr_offset + 32 - 1]),
      .scout(sov[ex1_instr_offset:ex1_instr_offset + 32 - 1]),
      .din(ex1_instr_d),
      .dout(ex1_instr_q)
   );


   tri_rlmreg_p #(.WIDTH((-1+`EFF_IFAR_WIDTH+1)), .INIT(0)) ex1_ifar_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex1_ifar_offset:ex1_ifar_offset + (-1+`EFF_IFAR_WIDTH+1) - 1]),
      .scout(sov[ex1_ifar_offset:ex1_ifar_offset + (-1+`EFF_IFAR_WIDTH+1) - 1]),
      .din(ex1_ifar_d),
      .dout(ex1_ifar_q)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) ex1_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex1_itag_offset:ex1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[ex1_itag_offset:ex1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ex1_itag_d),
      .dout(ex1_itag_q)
   );


   tri_rlmreg_p #(.WIDTH(`LR_POOL_ENC), .INIT(0)) ex1_lr_wa_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex1_lr_wa_offset:ex1_lr_wa_offset + `LR_POOL_ENC - 1]),
      .scout(sov[ex1_lr_wa_offset:ex1_lr_wa_offset + `LR_POOL_ENC - 1]),
      .din(ex1_lr_wa_d),
      .dout(ex1_lr_wa_q)
   );


   tri_rlmreg_p #(.WIDTH(`CTR_POOL_ENC), .INIT(0)) ex1_ctr_wa_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex1_ctr_wa_offset:ex1_ctr_wa_offset + `CTR_POOL_ENC - 1]),
      .scout(sov[ex1_ctr_wa_offset:ex1_ctr_wa_offset + `CTR_POOL_ENC - 1]),
      .din(ex1_ctr_wa_d),
      .dout(ex1_ctr_wa_q)
   );


   tri_rlmreg_p #(.WIDTH(`CR_POOL_ENC), .INIT(0)) ex1_cr_wa_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex1_cr_wa_offset:ex1_cr_wa_offset + `CR_POOL_ENC - 1]),
      .scout(sov[ex1_cr_wa_offset:ex1_cr_wa_offset + `CR_POOL_ENC - 1]),
      .din(ex1_cr_wa_d),
      .dout(ex1_cr_wa_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex1_pred_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex1_pred_offset]),
      .scout(sov[ex1_pred_offset]),
      .din(ex1_pred_d),
      .dout(ex1_pred_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex1_bta_val_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex1_bta_val_offset]),
      .scout(sov[ex1_bta_val_offset]),
      .din(ex1_bta_val_d),
      .dout(ex1_bta_val_q)
   );


   tri_rlmreg_p #(.WIDTH((-1+`EFF_IFAR_WIDTH+1)), .INIT(0)) ex1_pred_bta_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex1_pred_bta_offset:ex1_pred_bta_offset + (-1+`EFF_IFAR_WIDTH+1) - 1]),
      .scout(sov[ex1_pred_bta_offset:ex1_pred_bta_offset + (-1+`EFF_IFAR_WIDTH+1) - 1]),
      .din(ex1_pred_bta_d),
      .dout(ex1_pred_bta_q)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) ex1_ls_ptr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex1_ls_ptr_offset:ex1_ls_ptr_offset + 3 - 1]),
      .scout(sov[ex1_ls_ptr_offset:ex1_ls_ptr_offset + 3 - 1]),
      .din(ex1_ls_ptr_d),
      .dout(ex1_ls_ptr_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex1_bh_update_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex1_bh_update_offset]),
      .scout(sov[ex1_bh_update_offset]),
      .din(ex1_bh_update_d),
      .dout(ex1_bh_update_q)
   );


   tri_rlmreg_p #(.WIDTH(18), .INIT(0)) ex1_gshare_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex1_gshare_offset:ex1_gshare_offset + 18 - 1]),
      .scout(sov[ex1_gshare_offset:ex1_gshare_offset + 18 - 1]),
      .din(ex1_gshare_d),
      .dout(ex1_gshare_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ex2_vld_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_vld_offset:ex2_vld_offset + `THREADS - 1]),
      .scout(sov[ex2_vld_offset:ex2_vld_offset + `THREADS - 1]),
      .din(ex2_vld_d),
      .dout(ex2_vld_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex2_slow_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_slow_offset]),
      .scout(sov[ex2_slow_offset]),
      .din(ex2_slow_d),
      .dout(ex2_slow_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex2_fusion_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_fusion_offset]),
      .scout(sov[ex2_fusion_offset]),
      .din(ex2_fusion_d),
      .dout(ex2_fusion_q)
   );


   tri_rlmreg_p #(.WIDTH(32), .INIT(0)) ex2_instr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_instr_offset:ex2_instr_offset + 32 - 1]),
      .scout(sov[ex2_instr_offset:ex2_instr_offset + 32 - 1]),
      .din(ex2_instr_d),
      .dout(ex2_instr_q)
   );


   tri_rlmreg_p #(.WIDTH((-1+`EFF_IFAR_WIDTH+1)), .INIT(0)) ex2_ifar_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_ifar_offset:ex2_ifar_offset + (-1+`EFF_IFAR_WIDTH+1) - 1]),
      .scout(sov[ex2_ifar_offset:ex2_ifar_offset + (-1+`EFF_IFAR_WIDTH+1) - 1]),
      .din(ex2_ifar_d),
      .dout(ex2_ifar_q)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) ex2_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_itag_offset:ex2_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[ex2_itag_offset:ex2_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ex2_itag_d),
      .dout(ex2_itag_q)
   );


   tri_rlmreg_p #(.WIDTH(`LR_POOL_ENC), .INIT(0)) ex2_lr_wa_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_lr_wa_offset:ex2_lr_wa_offset + `LR_POOL_ENC - 1]),
      .scout(sov[ex2_lr_wa_offset:ex2_lr_wa_offset + `LR_POOL_ENC - 1]),
      .din(ex2_lr_wa_d),
      .dout(ex2_lr_wa_q)
   );


   tri_rlmreg_p #(.WIDTH(`CTR_POOL_ENC), .INIT(0)) ex2_ctr_wa_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_ctr_wa_offset:ex2_ctr_wa_offset + `CTR_POOL_ENC - 1]),
      .scout(sov[ex2_ctr_wa_offset:ex2_ctr_wa_offset + `CTR_POOL_ENC - 1]),
      .din(ex2_ctr_wa_d),
      .dout(ex2_ctr_wa_q)
   );


   tri_rlmreg_p #(.WIDTH(`CR_POOL_ENC), .INIT(0)) ex2_cr_wa_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_cr_wa_offset:ex2_cr_wa_offset + `CR_POOL_ENC - 1]),
      .scout(sov[ex2_cr_wa_offset:ex2_cr_wa_offset + `CR_POOL_ENC - 1]),
      .din(ex2_cr_wa_d),
      .dout(ex2_cr_wa_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex2_pred_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_pred_offset]),
      .scout(sov[ex2_pred_offset]),
      .din(ex2_pred_d),
      .dout(ex2_pred_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex2_bta_val_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_bta_val_offset]),
      .scout(sov[ex2_bta_val_offset]),
      .din(ex2_bta_val_d),
      .dout(ex2_bta_val_q)
   );


   tri_rlmreg_p #(.WIDTH((-1+`EFF_IFAR_WIDTH+1)), .INIT(0)) ex2_pred_bta_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_pred_bta_offset:ex2_pred_bta_offset + (-1+`EFF_IFAR_WIDTH+1) - 1]),
      .scout(sov[ex2_pred_bta_offset:ex2_pred_bta_offset + (-1+`EFF_IFAR_WIDTH+1) - 1]),
      .din(ex2_pred_bta_d),
      .dout(ex2_pred_bta_q)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) ex2_ls_ptr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_ls_ptr_offset:ex2_ls_ptr_offset + 3 - 1]),
      .scout(sov[ex2_ls_ptr_offset:ex2_ls_ptr_offset + 3 - 1]),
      .din(ex2_ls_ptr_d),
      .dout(ex2_ls_ptr_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex2_bh_update_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_bh_update_offset]),
      .scout(sov[ex2_bh_update_offset]),
      .din(ex2_bh_update_d),
      .dout(ex2_bh_update_q)
   );


   tri_rlmreg_p #(.WIDTH(18), .INIT(0)) ex2_gshare_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex2_gshare_offset:ex2_gshare_offset + 18 - 1]),
      .scout(sov[ex2_gshare_offset:ex2_gshare_offset + 18 - 1]),
      .din(ex2_gshare_d),
      .dout(ex2_gshare_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ex3_vld_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_vld_offset:ex3_vld_offset + `THREADS - 1]),
      .scout(sov[ex3_vld_offset:ex3_vld_offset + `THREADS - 1]),
      .din(ex3_vld_d),
      .dout(ex3_vld_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_slow_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_slow_offset]),
      .scout(sov[ex3_slow_offset]),
      .din(ex3_slow_d),
      .dout(ex3_slow_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_fusion_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_fusion_offset]),
      .scout(sov[ex3_fusion_offset]),
      .din(ex3_fusion_d),
      .dout(ex3_fusion_q)
   );


   tri_rlmreg_p #(.WIDTH(26), .INIT(0)) ex3_instr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_instr_offset:ex3_instr_offset + 26 - 1]),
      .scout(sov[ex3_instr_offset:ex3_instr_offset + 26 - 1]),
      .din(ex3_instr_d),
      .dout(ex3_instr_q)
   );


   tri_rlmreg_p #(.WIDTH((-1+`EFF_IFAR_WIDTH+1)), .INIT(0)) ex3_ifar_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_ifar_offset:ex3_ifar_offset + (-1+`EFF_IFAR_WIDTH+1) - 1]),
      .scout(sov[ex3_ifar_offset:ex3_ifar_offset + (-1+`EFF_IFAR_WIDTH+1) - 1]),
      .din(ex3_ifar_d),
      .dout(ex3_ifar_q)
   );


   tri_rlmreg_p #(.WIDTH((-1+`EFF_IFAR_ARCH+1)), .INIT(0)) ex3_bta_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_bta_offset:ex3_bta_offset + (-1+`EFF_IFAR_ARCH+1) - 1]),
      .scout(sov[ex3_bta_offset:ex3_bta_offset + (-1+`EFF_IFAR_ARCH+1) - 1]),
      .din(ex3_bta_d),
      .dout(ex3_bta_q)
   );


   tri_rlmreg_p #(.WIDTH((-1+`EFF_IFAR_ARCH+1)), .INIT(0)) ex3_nia_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_nia_offset:ex3_nia_offset + (-1+`EFF_IFAR_ARCH+1) - 1]),
      .scout(sov[ex3_nia_offset:ex3_nia_offset + (-1+`EFF_IFAR_ARCH+1) - 1]),
      .din(ex3_nia_d),
      .dout(ex3_nia_q)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) ex3_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_itag_offset:ex3_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[ex3_itag_offset:ex3_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ex3_itag_d),
      .dout(ex3_itag_q)
   );


   tri_rlmreg_p #(.WIDTH(`LR_POOL_ENC), .INIT(0)) ex3_lr_wa_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_lr_wa_offset:ex3_lr_wa_offset + `LR_POOL_ENC - 1]),
      .scout(sov[ex3_lr_wa_offset:ex3_lr_wa_offset + `LR_POOL_ENC - 1]),
      .din(ex3_lr_wa_d),
      .dout(ex3_lr_wa_q)
   );


   tri_rlmreg_p #(.WIDTH(`CTR_POOL_ENC), .INIT(0)) ex3_ctr_wa_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_ctr_wa_offset:ex3_ctr_wa_offset + `CTR_POOL_ENC - 1]),
      .scout(sov[ex3_ctr_wa_offset:ex3_ctr_wa_offset + `CTR_POOL_ENC - 1]),
      .din(ex3_ctr_wa_d),
      .dout(ex3_ctr_wa_q)
   );


   tri_rlmreg_p #(.WIDTH(`CR_POOL_ENC), .INIT(0)) ex3_cr_wa_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_cr_wa_offset:ex3_cr_wa_offset + `CR_POOL_ENC - 1]),
      .scout(sov[ex3_cr_wa_offset:ex3_cr_wa_offset + `CR_POOL_ENC - 1]),
      .din(ex3_cr_wa_d),
      .dout(ex3_cr_wa_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_is_b_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_is_b_offset]),
      .scout(sov[ex3_is_b_offset]),
      .din(ex3_is_b_d),
      .dout(ex3_is_b_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_is_bc_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_is_bc_offset]),
      .scout(sov[ex3_is_bc_offset]),
      .din(ex3_is_bc_d),
      .dout(ex3_is_bc_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_is_bclr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_is_bclr_offset]),
      .scout(sov[ex3_is_bclr_offset]),
      .din(ex3_is_bclr_d),
      .dout(ex3_is_bclr_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_is_bcctr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_is_bcctr_offset]),
      .scout(sov[ex3_is_bcctr_offset]),
      .din(ex3_is_bcctr_d),
      .dout(ex3_is_bcctr_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_is_bctar_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_is_bctar_offset]),
      .scout(sov[ex3_is_bctar_offset]),
      .din(ex3_is_bctar_d),
      .dout(ex3_is_bctar_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_pred_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_pred_offset]),
      .scout(sov[ex3_pred_offset]),
      .din(ex3_pred_d),
      .dout(ex3_pred_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_bta_val_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_bta_val_offset]),
      .scout(sov[ex3_bta_val_offset]),
      .din(ex3_bta_val_d),
      .dout(ex3_bta_val_q)
   );


   tri_rlmreg_p #(.WIDTH((-1+`EFF_IFAR_WIDTH+1)), .INIT(0)) ex3_pred_bta_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_pred_bta_offset:ex3_pred_bta_offset + (-1+`EFF_IFAR_WIDTH+1) - 1]),
      .scout(sov[ex3_pred_bta_offset:ex3_pred_bta_offset + (-1+`EFF_IFAR_WIDTH+1) - 1]),
      .din(ex3_pred_bta_d),
      .dout(ex3_pred_bta_q)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) ex3_ls_ptr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_ls_ptr_offset:ex3_ls_ptr_offset + 3 - 1]),
      .scout(sov[ex3_ls_ptr_offset:ex3_ls_ptr_offset + 3 - 1]),
      .din(ex3_ls_ptr_d),
      .dout(ex3_ls_ptr_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_bh_update_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_bh_update_offset]),
      .scout(sov[ex3_bh_update_offset]),
      .din(ex3_bh_update_d),
      .dout(ex3_bh_update_q)
   );


   tri_rlmreg_p #(.WIDTH(18), .INIT(0)) ex3_gshare_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_gshare_offset:ex3_gshare_offset + 18 - 1]),
      .scout(sov[ex3_gshare_offset:ex3_gshare_offset + 18 - 1]),
      .din(ex3_gshare_d),
      .dout(ex3_gshare_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_is_mcrf_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_is_mcrf_offset]),
      .scout(sov[ex3_is_mcrf_offset]),
      .din(ex3_is_mcrf_d),
      .dout(ex3_is_mcrf_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_is_crand_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_is_crand_offset]),
      .scout(sov[ex3_is_crand_offset]),
      .din(ex3_is_crand_d),
      .dout(ex3_is_crand_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_is_crandc_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_is_crandc_offset]),
      .scout(sov[ex3_is_crandc_offset]),
      .din(ex3_is_crandc_d),
      .dout(ex3_is_crandc_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_is_creqv_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_is_creqv_offset]),
      .scout(sov[ex3_is_creqv_offset]),
      .din(ex3_is_creqv_d),
      .dout(ex3_is_creqv_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_is_crnand_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_is_crnand_offset]),
      .scout(sov[ex3_is_crnand_offset]),
      .din(ex3_is_crnand_d),
      .dout(ex3_is_crnand_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_is_crnor_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_is_crnor_offset]),
      .scout(sov[ex3_is_crnor_offset]),
      .din(ex3_is_crnor_d),
      .dout(ex3_is_crnor_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_is_cror_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_is_cror_offset]),
      .scout(sov[ex3_is_cror_offset]),
      .din(ex3_is_cror_d),
      .dout(ex3_is_cror_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_is_crorc_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_is_crorc_offset]),
      .scout(sov[ex3_is_crorc_offset]),
      .din(ex3_is_crorc_d),
      .dout(ex3_is_crorc_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex3_is_crxor_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex3_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex3_is_crxor_offset]),
      .scout(sov[ex3_is_crxor_offset]),
      .din(ex3_is_crxor_d),
      .dout(ex3_is_crxor_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ex4_vld_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_vld_offset:ex4_vld_offset + `THREADS - 1]),
      .scout(sov[ex4_vld_offset:ex4_vld_offset + `THREADS - 1]),
      .din(ex4_vld_d),
      .dout(ex4_vld_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex4_slow_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex4_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_slow_offset]),
      .scout(sov[ex4_slow_offset]),
      .din(ex4_slow_d),
      .dout(ex4_slow_q)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) ex4_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex4_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_itag_offset:ex4_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[ex4_itag_offset:ex4_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ex4_itag_d),
      .dout(ex4_itag_q)
   );


   tri_rlmreg_p #(.WIDTH(`LR_POOL_ENC), .INIT(0)) ex4_lr_wa_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex4_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_lr_wa_offset:ex4_lr_wa_offset + `LR_POOL_ENC - 1]),
      .scout(sov[ex4_lr_wa_offset:ex4_lr_wa_offset + `LR_POOL_ENC - 1]),
      .din(ex4_lr_wa_d),
      .dout(ex4_lr_wa_q)
   );


   tri_rlmreg_p #(.WIDTH(`CTR_POOL_ENC), .INIT(0)) ex4_ctr_wa_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex4_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_ctr_wa_offset:ex4_ctr_wa_offset + `CTR_POOL_ENC - 1]),
      .scout(sov[ex4_ctr_wa_offset:ex4_ctr_wa_offset + `CTR_POOL_ENC - 1]),
      .din(ex4_ctr_wa_d),
      .dout(ex4_ctr_wa_q)
   );


   tri_rlmreg_p #(.WIDTH(`CR_POOL_ENC), .INIT(0)) ex4_cr_wa_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex4_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_cr_wa_offset:ex4_cr_wa_offset + `CR_POOL_ENC - 1]),
      .scout(sov[ex4_cr_wa_offset:ex4_cr_wa_offset + `CR_POOL_ENC - 1]),
      .din(ex4_cr_wa_d),
      .dout(ex4_cr_wa_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex4_taken_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex4_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_taken_offset]),
      .scout(sov[ex4_taken_offset]),
      .din(ex4_taken_d),
      .dout(ex4_taken_q)
   );


   tri_rlmreg_p #(.WIDTH((-1+`EFF_IFAR_ARCH+1)), .INIT(0)) ex4_bta_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex4_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_bta_offset:ex4_bta_offset + (-1+`EFF_IFAR_ARCH+1) - 1]),
      .scout(sov[ex4_bta_offset:ex4_bta_offset + (-1+`EFF_IFAR_ARCH+1) - 1]),
      .din(ex4_bta_d),
      .dout(ex4_bta_q)
   );

   tri_rlmreg_p #(.WIDTH(18), .INIT(0)) ex4_gshare_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex4_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_gshare_offset:ex4_gshare_offset + 18 - 1]),
      .scout(sov[ex4_gshare_offset:ex4_gshare_offset + 18 - 1]),
      .din(ex4_gshare_d),
      .dout(ex4_gshare_q)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) ex4_ls_ptr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex4_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_ls_ptr_offset:ex4_ls_ptr_offset + 3 - 1]),
      .scout(sov[ex4_ls_ptr_offset:ex4_ls_ptr_offset + 3 - 1]),
      .din(ex4_ls_ptr_d),
      .dout(ex4_ls_ptr_q)
   );


   tri_rlmreg_p #(.WIDTH((-1+`EFF_IFAR_WIDTH+1)), .INIT(0)) ex4_ls_data_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex4_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_ls_data_offset:ex4_ls_data_offset + (-1+`EFF_IFAR_WIDTH+1) - 1]),
      .scout(sov[ex4_ls_data_offset:ex4_ls_data_offset + (-1+`EFF_IFAR_WIDTH+1) - 1]),
      .din(ex4_ls_data_d),
      .dout(ex4_ls_data_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex4_ls_update_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex4_act),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_ls_update_offset]),
      .scout(sov[ex4_ls_update_offset]),
      .din(ex4_ls_update_d),
      .dout(ex4_ls_update_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ex4_redirect_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_redirect_offset:ex4_redirect_offset + `THREADS - 1]),
      .scout(sov[ex4_redirect_offset:ex4_redirect_offset + `THREADS - 1]),
      .din(ex4_redirect_d),
      .dout(ex4_redirect_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ex4_itag_saved_val_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_itag_saved_val_offset:ex4_itag_saved_val_offset + `THREADS - 1]),
      .scout(sov[ex4_itag_saved_val_offset:ex4_itag_saved_val_offset + `THREADS - 1]),
      .din(ex4_itag_saved_val_d),
      .dout(ex4_itag_saved_val_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex4_lr_we_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_lr_we_offset]),
      .scout(sov[ex4_lr_we_offset]),
      .din(ex4_lr_we_d),
      .dout(ex4_lr_we_q)
   );


   tri_rlmreg_p #(.WIDTH((-1+`GPR_WIDTH+1)), .INIT(0)) ex4_lr_wd_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex4_lr_we_d),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_lr_wd_offset:ex4_lr_wd_offset + (-1+`GPR_WIDTH+1) - 1]),
      .scout(sov[ex4_lr_wd_offset:ex4_lr_wd_offset + (-1+`GPR_WIDTH+1) - 1]),
      .din(ex4_lr_wd_d),
      .dout(ex4_lr_wd_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex4_ctr_we_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_ctr_we_offset]),
      .scout(sov[ex4_ctr_we_offset]),
      .din(ex4_ctr_we_d),
      .dout(ex4_ctr_we_q)
   );


   tri_rlmreg_p #(.WIDTH((-1+`GPR_WIDTH+1)), .INIT(0)) ex4_ctr_wd_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex4_ctr_we_d),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_ctr_wd_offset:ex4_ctr_wd_offset + (-1+`GPR_WIDTH+1) - 1]),
      .scout(sov[ex4_ctr_wd_offset:ex4_ctr_wd_offset + (-1+`GPR_WIDTH+1) - 1]),
      .din(ex4_ctr_wd_d),
      .dout(ex4_ctr_wd_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex4_cr_we_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_cr_we_offset]),
      .scout(sov[ex4_cr_we_offset]),
      .din(ex4_cr_we_d),
      .dout(ex4_cr_we_q)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) ex4_cr_wd_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex4_cr_we_d),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_cr_wd_offset:ex4_cr_wd_offset + 4 - 1]),
      .scout(sov[ex4_cr_wd_offset:ex4_cr_wd_offset + 4 - 1]),
      .din(ex4_cr_wd_d),
      .dout(ex4_cr_wd_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) ex4_perf_event(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[ex4_perf_event_offset:ex4_perf_event_offset + 4 - 1]),
      .scout(sov[ex4_perf_event_offset:ex4_perf_event_offset + 4 - 1]),
      .din(ex4_perf_event_d),
      .dout(ex4_perf_event_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) spr_msr_cm_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .scin(siv[spr_msr_cm_offset:spr_msr_cm_offset + `THREADS - 1]),
      .scout(sov[spr_msr_cm_offset:spr_msr_cm_offset + `THREADS - 1]),
      .din(spr_msr_cm),
      .dout(spr_msr_cm_q)
   );

   //-----------------------------------------------
   // pervasive
   //-----------------------------------------------

   tri_plat #(.WIDTH(2)) perv_2to1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({pc_br_func_sl_thold_2,pc_br_sg_2}),
      .q({func_sl_thold_1,sg_1})
   );


   tri_plat #(.WIDTH(2)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({func_sl_thold_1,sg_1}),
      .q({func_sl_thold_0,sg_0})
   );

   tri_lcbor  perv_lcbor(
      .clkoff_b(clkoff_b),
      .thold(func_sl_thold_0),
      .sg(sg_0),
      .act_dis(act_dis),
      .force_t(force_t),
      .thold_b(func_sl_thold_0_b)
   );

   //-----------------------------------------------
   // scan
   //-----------------------------------------------
   assign siv[0:scan_right - 1] = {sov[1:scan_right - 1], scan_in};
   assign scan_out = sov[0];


endmodule
