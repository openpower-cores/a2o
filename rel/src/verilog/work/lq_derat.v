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

//******************************************************************************
//* TITLE: Data Side Effective to Real Address Translation
//* NAME: lq_derat.vhdl
//******************************************************************************

`include "tri_a2o.vh"





module lq_derat(
   gnd,
   vdd,
   vcs,
   nclk,
   pc_xu_init_reset,
   pc_xu_ccflush_dc,
   tc_scan_dis_dc_b,
   tc_scan_diag_dc,
   tc_lbist_en_dc,
   an_ac_atpg_en_dc,
   an_ac_grffence_en_dc,
   lcb_d_mode_dc,
   lcb_clkoff_dc_b,
   lcb_act_dis_dc,
   lcb_mpw1_dc_b,
   lcb_mpw2_dc_b,
   lcb_delay_lclkr_dc,
   pc_func_sl_thold_2,
   pc_func_slp_sl_thold_2,
   pc_func_slp_nsl_thold_2,
   pc_cfg_slp_sl_thold_2,
   pc_regf_slp_sl_thold_2,
   pc_time_sl_thold_2,
   pc_sg_2,
   pc_fce_2,
   cam_clkoff_dc_b,
   cam_act_dis_dc,
   cam_d_mode_dc,
   cam_delay_lclkr_dc,
   cam_mpw1_dc_b,
   cam_mpw2_dc_b,
   ac_func_scan_in,
   ac_func_scan_out,
   ac_ccfg_scan_in,
   ac_ccfg_scan_out,
   time_scan_in,
   time_scan_out,
   regf_scan_in,
   regf_scan_out,
   dec_derat_ex1_derat_act,
   dec_derat_ex0_val,
   dec_derat_ex0_is_extload,
   dec_derat_ex0_is_extstore,
   dec_derat_ex1_itag,
   dec_derat_ex1_pfetch_val,
   dec_derat_ex1_is_load,
   dec_derat_ex1_is_store,
   dec_derat_ex1_is_touch,
   dec_derat_ex1_icbtls_instr,
   dec_derat_ex1_icblc_instr,
   dec_derat_ex1_ra_eq_ea,
   dec_derat_ex1_byte_rev,
   byp_derat_ex2_req_aborted,
   dcc_derat_ex3_strg_noop,
   dcc_derat_ex5_blk_tlb_req,
   dcc_derat_ex6_cplt,
   dcc_derat_ex6_cplt_itag,
   dir_derat_ex2_epn_arr,
   dir_derat_ex2_epn_nonarr,
   iu_lq_recirc_val,
   iu_lq_cp_next_itag,
   lsq_ctl_oldest_tid,
   lsq_ctl_oldest_itag,
   derat_dcc_ex4_restart,
   derat_dcc_ex4_setHold,
   derat_dcc_clr_hold,
   derat_dcc_emq_idle,
   xu_lq_act,
   xu_lq_val,
   xu_lq_is_eratre,
   xu_lq_is_eratwe,
   xu_lq_is_eratsx,
   xu_lq_is_eratilx,
   xu_lq_ws,
   xu_lq_ra_entry,
   xu_lq_rs_data,
   lq_xu_ex5_data,
   lq_xu_ord_par_err,
   lq_xu_ord_read_done,
   lq_xu_ord_write_done,
   iu_lq_isync,
   iu_lq_csync,
   mm_derat_rel_val,
   mm_derat_rel_data,
   mm_derat_rel_emq,
   mm_lq_itag,
   mm_lq_tlb_miss,
   mm_lq_tlb_inelig,
   mm_lq_pt_fault,
   mm_lq_lrat_miss,
   mm_lq_tlb_multihit,
   mm_lq_tlb_par_err,
   mm_lq_lru_par_err,
   lsq_ctl_rv0_binv_val,
   mm_lq_snoop_coming,
   mm_lq_snoop_val,
   mm_lq_snoop_attr,
   mm_lq_snoop_vpn,
   lq_mm_snoop_ack,
   derat_dec_rv1_snoop_addr,
   derat_rv1_snoop_val,
   iu_lq_cp_flush,
   derat_dec_hole_all,
   derat_dcc_ex3_e,
   derat_dcc_ex3_itagHit,
   derat_dcc_ex4_rpn,
   derat_dcc_ex4_wimge,
   derat_dcc_ex4_u,
   derat_dcc_ex4_wlc,
   derat_dcc_ex4_attr,
   derat_dcc_ex4_vf,
   derat_dcc_ex4_miss,
   derat_dcc_ex4_tlb_err,
   derat_dcc_ex4_dsi,
   derat_dcc_ex4_par_err_flush,
   derat_dcc_ex4_multihit_err_flush,
   derat_dcc_ex4_par_err_det,
   derat_dcc_ex4_multihit_err_det,
   derat_dcc_ex4_noop_touch,
   derat_dcc_ex4_tlb_inelig,
   derat_dcc_ex4_pt_fault,
   derat_dcc_ex4_lrat_miss,
   derat_dcc_ex4_tlb_multihit,
   derat_dcc_ex4_tlb_par_err,
   derat_dcc_ex4_lru_par_err,
   derat_fir_par_err,
   derat_fir_multihit,
   lq_mm_req,
   lq_mm_req_nonspec,
   lq_mm_req_itag,
   lq_mm_req_epn,
   lq_mm_thdid,
   lq_mm_req_emq,
   lq_mm_ttype,
   lq_mm_state,
   lq_mm_lpid,
   lq_mm_tid,
   lq_mm_perf_dtlb,
   lq_mm_mmucr0_we,
   lq_mm_mmucr0,
   lq_mm_mmucr1_we,
   lq_mm_mmucr1,
   spr_xucr0_clkg_ctl_b1,
   xu_lq_spr_msr_hv,
   xu_lq_spr_msr_pr,
   xu_lq_spr_msr_ds,
   xu_lq_spr_msr_cm,
   xu_lq_spr_ccr2_notlb,
   xu_lq_spr_ccr2_dfrat,
   xu_lq_spr_ccr2_dfratsc,
   xu_lq_spr_xucr4_mmu_mchk,
   spr_derat_eplc_wr,
   spr_derat_eplc_epr,
   spr_derat_eplc_eas,
   spr_derat_eplc_egs,
   spr_derat_eplc_elpid,
   spr_derat_eplc_epid,
   spr_derat_epsc_wr,
   spr_derat_epsc_epr,
   spr_derat_epsc_eas,
   spr_derat_epsc_egs,
   spr_derat_epsc_elpid,
   spr_derat_epsc_epid,
   mm_lq_pid,
   mm_lq_mmucr0,
   mm_lq_mmucr1,
   derat_xu_debug_group0,
   derat_xu_debug_group1,
   derat_xu_debug_group2,
   derat_xu_debug_group3
);

   // Parameters used from tri_a2o.vh

   //   parameter                         EXPAND_TYPE   = 1;
   //   parameter                         GPR_WIDTH_ENC = 6;
   //   parameter                         ITAG_SIZE_ENC = 7;
   //   parameter                         EMQ_ENTRIES   = 4;
   //   parameter                         THREADS       = 2;





   inout                             gnd;


   inout                             vdd;


   inout                             vcs;


   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

   input [0:`NCLK_WIDTH-1]           nclk;
   input                             pc_xu_init_reset;
   input                             pc_xu_ccflush_dc;
   input                             tc_scan_dis_dc_b;
   input                             tc_scan_diag_dc;
   input                             tc_lbist_en_dc;
   input                             an_ac_atpg_en_dc;
   input                             an_ac_grffence_en_dc;

   input                             lcb_d_mode_dc;
   input                             lcb_clkoff_dc_b;
   input                             lcb_act_dis_dc;
   input [0:4]                       lcb_mpw1_dc_b;
   input                             lcb_mpw2_dc_b;
   input [0:4]                       lcb_delay_lclkr_dc;

   input                             pc_func_sl_thold_2;
   input                             pc_func_slp_sl_thold_2;
   input                             pc_func_slp_nsl_thold_2;
   input                             pc_cfg_slp_sl_thold_2;
   input                             pc_regf_slp_sl_thold_2;
   input                             pc_time_sl_thold_2;
   input                             pc_sg_2;
   input                             pc_fce_2;
   input                             cam_clkoff_dc_b;
   input                             cam_act_dis_dc;
   input                             cam_d_mode_dc;
   input [0:4]                       cam_delay_lclkr_dc;
   input [0:4]                       cam_mpw1_dc_b;
   input                             cam_mpw2_dc_b;


   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

   input [0:1]                       ac_func_scan_in;

   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

   output [0:1]                      ac_func_scan_out;

   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

   input                             ac_ccfg_scan_in;

   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

   output                            ac_ccfg_scan_out;

   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

   input                             time_scan_in;

   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

   output                            time_scan_out;

   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

   input [0:6]                       regf_scan_in;

   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

   output [0:6]                      regf_scan_out;

   input                             dec_derat_ex1_derat_act;
   input [0:`THREADS-1]              dec_derat_ex0_val;
   input                             dec_derat_ex0_is_extload;
   input                             dec_derat_ex0_is_extstore;
   input [0:`ITAG_SIZE_ENC-1]        dec_derat_ex1_itag;
   input [0:`THREADS-1]              dec_derat_ex1_pfetch_val;
   input                             dec_derat_ex1_is_load;
   input                             dec_derat_ex1_is_store;
   input                             dec_derat_ex1_is_touch;
   input                             dec_derat_ex1_icbtls_instr;
   input                             dec_derat_ex1_icblc_instr;
   input                             dec_derat_ex1_ra_eq_ea;
   input                             dec_derat_ex1_byte_rev;
   input                             byp_derat_ex2_req_aborted;
   input                             dcc_derat_ex3_strg_noop;
   input                             dcc_derat_ex5_blk_tlb_req;
   input [0:`THREADS-1]              dcc_derat_ex6_cplt;
   input [0:`ITAG_SIZE_ENC-1]        dcc_derat_ex6_cplt_itag;

   input [64-(2**`GPR_WIDTH_ENC):51] dir_derat_ex2_epn_arr;
   input [64-(2**`GPR_WIDTH_ENC):51] dir_derat_ex2_epn_nonarr;
   input [0:`THREADS-1]              iu_lq_recirc_val;
   input [0:(`THREADS*`ITAG_SIZE_ENC)-1] iu_lq_cp_next_itag;

   input [0:`THREADS-1]              lsq_ctl_oldest_tid;
   input [0:`ITAG_SIZE_ENC-1]        lsq_ctl_oldest_itag;

   output                            derat_dcc_ex4_restart;

   output                            derat_dcc_ex4_setHold;
   output [0:`THREADS-1]             derat_dcc_clr_hold;
   output [0:`THREADS-1]             derat_dcc_emq_idle;
   input                             xu_lq_act;
   input [0:`THREADS-1]              xu_lq_val;
   input                             xu_lq_is_eratre;
   input                             xu_lq_is_eratwe;
   input                             xu_lq_is_eratsx;
   input                             xu_lq_is_eratilx;
   input [0:1]                       xu_lq_ws;
   input [0:4]                       xu_lq_ra_entry;
   input [64-(2**`GPR_WIDTH_ENC):63] xu_lq_rs_data;
   output [64-(2**`GPR_WIDTH_ENC):63] lq_xu_ex5_data;
   output                            lq_xu_ord_par_err;
   output                            lq_xu_ord_read_done;
   output                            lq_xu_ord_write_done;

   input                             iu_lq_isync;
   input                             iu_lq_csync;

   input [0:4]                       mm_derat_rel_val;
   input [0:131]                     mm_derat_rel_data;
   input [0:`EMQ_ENTRIES-1]          mm_derat_rel_emq;
   input [0:`ITAG_SIZE_ENC-1]        mm_lq_itag;
   input [0:`THREADS-1]              mm_lq_tlb_miss;
   input [0:`THREADS-1]              mm_lq_tlb_inelig;
   input [0:`THREADS-1]              mm_lq_pt_fault;
   input [0:`THREADS-1]              mm_lq_lrat_miss;
   input [0:`THREADS-1]              mm_lq_tlb_multihit;
   input [0:`THREADS-1]              mm_lq_tlb_par_err;
   input [0:`THREADS-1]              mm_lq_lru_par_err;

   input                             lsq_ctl_rv0_binv_val;
   input                             mm_lq_snoop_coming;
   input                             mm_lq_snoop_val;
   input [0:25]                      mm_lq_snoop_attr;
   input [0:51]                      mm_lq_snoop_vpn;
   output                            lq_mm_snoop_ack;
   output [0:51]                     derat_dec_rv1_snoop_addr;
   output                            derat_rv1_snoop_val;
   input [0:`THREADS-1]              iu_lq_cp_flush;
   output                            derat_dec_hole_all;
   output                            derat_dcc_ex3_e;
   output                            derat_dcc_ex3_itagHit;

   output [22:51]                    derat_dcc_ex4_rpn;
   output [0:4]                      derat_dcc_ex4_wimge;
   output [0:3]                      derat_dcc_ex4_u;
   output [0:1]                      derat_dcc_ex4_wlc;
   output [0:5]                      derat_dcc_ex4_attr;
   output                            derat_dcc_ex4_vf;
   output                            derat_dcc_ex4_miss;
   output                            derat_dcc_ex4_tlb_err;
   output                            derat_dcc_ex4_dsi;
   output                            derat_dcc_ex4_par_err_flush;
   output                            derat_dcc_ex4_multihit_err_flush;
   output                            derat_dcc_ex4_par_err_det;
   output                            derat_dcc_ex4_multihit_err_det;
   output                            derat_dcc_ex4_noop_touch;
   output                            derat_dcc_ex4_tlb_inelig;
   output                            derat_dcc_ex4_pt_fault;
   output                            derat_dcc_ex4_lrat_miss;
   output                            derat_dcc_ex4_tlb_multihit;
   output                            derat_dcc_ex4_tlb_par_err;
   output                            derat_dcc_ex4_lru_par_err;

   output                            derat_fir_par_err;
   output                            derat_fir_multihit;

   output                            lq_mm_req;
   output                            lq_mm_req_nonspec;
   output [0:`ITAG_SIZE_ENC-1]       lq_mm_req_itag;
   output [64-(2**`GPR_WIDTH_ENC):51] lq_mm_req_epn;
   output [0:`THREADS-1]             lq_mm_thdid;
   output [0:`EMQ_ENTRIES-1]         lq_mm_req_emq;
   output [0:1]                      lq_mm_ttype;
   output [0:3]                      lq_mm_state;
   output [0:7]                      lq_mm_lpid;
   output [0:13]                     lq_mm_tid;
   output [0:`THREADS-1]             lq_mm_mmucr0_we;
   output [0:17]                     lq_mm_mmucr0;
   output [0:`THREADS-1]             lq_mm_mmucr1_we;
   output [0:4]                      lq_mm_mmucr1;
   output [0:`THREADS-1]             lq_mm_perf_dtlb;
   input                             spr_xucr0_clkg_ctl_b1;

   input [0:`THREADS-1]              xu_lq_spr_msr_hv;
   input [0:`THREADS-1]              xu_lq_spr_msr_pr;
   input [0:`THREADS-1]              xu_lq_spr_msr_ds;
   input [0:`THREADS-1]              xu_lq_spr_msr_cm;
   input                             xu_lq_spr_ccr2_notlb;
   input                             xu_lq_spr_ccr2_dfrat;
   input [0:8]                       xu_lq_spr_ccr2_dfratsc;
   input                             xu_lq_spr_xucr4_mmu_mchk;

   input [0:`THREADS-1]              spr_derat_eplc_wr;
   input [0:`THREADS-1]              spr_derat_eplc_epr;
   input [0:`THREADS-1]              spr_derat_eplc_eas;
   input [0:`THREADS-1]              spr_derat_eplc_egs;
   input [0:(8*`THREADS)-1]          spr_derat_eplc_elpid;
   input [0:(14*`THREADS)-1]         spr_derat_eplc_epid;

   input [0:`THREADS-1]              spr_derat_epsc_wr;
   input [0:`THREADS-1]              spr_derat_epsc_epr;
   input [0:`THREADS-1]              spr_derat_epsc_eas;
   input [0:`THREADS-1]              spr_derat_epsc_egs;
   input [0:(8*`THREADS)-1]          spr_derat_epsc_elpid;
   input [0:(14*`THREADS)-1]         spr_derat_epsc_epid;

   input [0:(`THREADS*14)-1]         mm_lq_pid;
   input [0:(`THREADS*20)-1]         mm_lq_mmucr0;
   input [0:9]                       mm_lq_mmucr1;
   output [0:87]                     derat_xu_debug_group0;
   output [0:87]                     derat_xu_debug_group1;
   output [0:87]                     derat_xu_debug_group2;
   output [0:87]                     derat_xu_debug_group3;

   //@@  Signal Declarations
   wire [1:19]                       CAM_MASK_BITS_PT;
   wire [1:31]                       EX3_FIRST_HIT_ENTRY_PT;
   wire [1:32]                       EX3_MULTIHIT_B_PT;
   wire [1:32]                       LRU_RMT_VEC_D_PT;
   wire [1:161]                      LRU_SET_RESET_VEC_PT;
   wire [1:31]                       LRU_WAY_ENCODE_PT;
   //--------------------------
   // components
   //--------------------------

   //--------------------------
   // constants
   //--------------------------
   parameter                         GPR_WIDTH         = 2 ** `GPR_WIDTH_ENC;
   parameter [0:2]                   EMQ_IDLE          = 3'b100;
   parameter [0:2]                   EMQ_RPEN          = 3'b010;
   parameter [0:2]                   EMQ_REXCP         = 3'b001;
   // Field/Signal sizes
   parameter                         ttype_width       = 12;
   parameter                         state_width       = 4;
   parameter                         lpid_width        = 8;
   parameter                         pid_width         = 14;
   parameter                         pid_width_erat    = 8;
   parameter                         extclass_width    = 2;
   parameter                         tlbsel_width      = 2;
   parameter                         epn_width         = 52;
   parameter                         vpn_width         = 61;
   parameter                         rpn_width         = 30;
   parameter                         ws_width          = 2;
   parameter                         rs_is_width       = 9;
   parameter                         error_width       = 3;
   parameter                         cam_data_width    = 84;
   parameter                         array_data_width  = 68;
   parameter                         num_entry         = 32;
   parameter                         num_entry_log2    = 5;
   parameter                         por_seq_width     = 3;
   parameter                         watermark_width   = 5;
   parameter                         eptr_width        = 5;
   parameter                         lru_width         = 31;
   parameter                         bcfg_width        = 123;
   parameter                         ex3_epn_width     = 30;
   // Generate flags
   parameter                         check_parity      = 1;
   parameter                         MMU_Mode_Value    = 1'b0;
   parameter [0:1]                   TlbSel_Tlb        = 2'b00;
   parameter [0:1]                   TlbSel_IErat      = 2'b10;
   parameter [0:1]                   TlbSel_DErat      = 2'b11;
   parameter [0:2]                   CAM_PgSize_1GB    = 3'b110;
   parameter [0:2]                   CAM_PgSize_16MB   = 3'b111;
   parameter [0:2]                   CAM_PgSize_1MB    = 3'b101;
   parameter [0:2]                   CAM_PgSize_64KB   = 3'b011;
   parameter [0:2]                   CAM_PgSize_4KB    = 3'b001;
   parameter [0:3]                   WS0_PgSize_1GB    = 4'b1010;
   parameter [0:3]                   WS0_PgSize_16MB   = 4'b0111;
   parameter [0:3]                   WS0_PgSize_1MB    = 4'b0101;
   parameter [0:3]                   WS0_PgSize_64KB   = 4'b0011;
   parameter [0:3]                   WS0_PgSize_4KB    = 4'b0001;
   parameter                         eratpos_epn       = 0;
   parameter                         eratpos_x         = 52;
   parameter                         eratpos_size      = 53;
   parameter                         eratpos_v         = 56;
   parameter                         eratpos_thdid     = 57;
   parameter                         eratpos_class     = 61;
   parameter                         eratpos_extclass  = 63;
   parameter                         eratpos_wren      = 65;
   parameter                         eratpos_rpnrsvd   = 66;
   parameter                         eratpos_rpn       = 70;
   parameter                         eratpos_r         = 100;
   parameter                         eratpos_c         = 101;
   parameter                         eratpos_relsoon   = 102;
   parameter                         eratpos_wlc       = 103;
   parameter                         eratpos_resvattr  = 105;
   parameter                         eratpos_vf        = 106;
   parameter                         eratpos_ubits     = 107;
   parameter                         eratpos_wimge     = 111;
   parameter                         eratpos_usxwr     = 116;
   parameter                         eratpos_gs        = 122;
   parameter                         eratpos_ts        = 123;
   parameter                         eratpos_tid       = 124;
   parameter [0:2]                   PorSeq_Idle       = 3'b000;
   parameter [0:2]                   PorSeq_Stg1       = 3'b001;
   parameter [0:2]                   PorSeq_Stg2       = 3'b011;
   parameter [0:2]                   PorSeq_Stg3       = 3'b010;
   parameter [0:2]                   PorSeq_Stg4       = 3'b110;
   parameter [0:2]                   PorSeq_Stg5       = 3'b100;
   parameter [0:2]                   PorSeq_Stg6       = 3'b101;
   parameter [0:2]                   PorSeq_Stg7       = 3'b111;
   parameter [0:num_entry_log2-1]    Por_Wr_Entry_Num1 = 5'b11110;
   parameter [0:num_entry_log2-1]    Por_Wr_Entry_Num2 = 5'b11111;
   // wr_cam_data -----------------------------------------------------------------
   //  0:51   - EPN
   //  52     - X
   //  53:55  - SIZE
   //  56     - V
   //  57:60  - ThdID
   //  61:62  - Class
   //  63:64  - ExtClass | TID_NZ
   //  65     - TGS
   //  66     - TS
   //  67:74  - TID
   //  75:78  - epn_cmpmasks:  34_39, 40_43, 44_47, 48_51
   //  79:82  - xbit_cmpmasks: 34_51, 40_51, 44_51, 48_51
   //  83     - parity for 75:82
   parameter [0:83]                  Por_Wr_Cam_Data1 = {52'b0000000000000000000000000000000011111111111111111111, 1'b0, 3'b001, 1'b1, 4'b1111, 2'b00, 2'b00, 2'b00, 8'b00000000, 8'b11110000, 1'b0};
   parameter [0:83]                  Por_Wr_Cam_Data2 = {52'b0000000000000000000000000000000000000000000000000000, 1'b0, 3'b001, 1'b1, 4'b1111, 2'b00, 2'b10, 2'b00, 8'b00000000, 8'b11110000, 1'b0};
   // 16x143 version, 42b RA
   // wr_array_data
   //  0:29   - RPN
   //  30:31  - R,C
   //  32:35  - ResvAttr
   //  36:39  - U0-U3
   //  40:44  - WIMGE
   //  45:46  - UX,SX
   //  47:48  - UW,SW
   //  49:50  - UR,SR
   //  51:60  - CAM parity
   //  61:67  - Array parity
   parameter [0:67]                  Por_Wr_Array_Data1 = {30'b111111111111111111111111111111, 2'b00, 4'b0000, 4'b0000, 5'b01010, 2'b01, 2'b00, 2'b01, 10'b0000001000, 7'b0000000};
   parameter [0:67]                  Por_Wr_Array_Data2 = {30'b000000000000000000000000000000, 2'b00, 4'b0000, 4'b0000, 5'b01010, 2'b01, 2'b00, 2'b01, 10'b0000001010, 7'b0000000};


   parameter                         spr_msr_hv_offset               = 0;
   parameter                         spr_msr_pr_offset               = spr_msr_hv_offset + `THREADS;
   parameter                         spr_msr_ds_offset               = spr_msr_pr_offset + `THREADS;
   parameter                         spr_msr_cm_offset               = spr_msr_ds_offset + `THREADS;
   parameter                         spr_ccr2_notlb_offset           = spr_msr_cm_offset + `THREADS;
   parameter                         xucr4_mmu_mchk_offset           = spr_ccr2_notlb_offset + 1;
   parameter                         mchk_flash_inv_offset           = xucr4_mmu_mchk_offset + 1;
   parameter                         cp_next_val_offset              = mchk_flash_inv_offset + 4;
   parameter                         cp_next_itag_offset             = cp_next_val_offset + `THREADS;
   parameter                         ex2_byte_rev_offset             = cp_next_itag_offset + `THREADS * `ITAG_SIZE_ENC;
   parameter                         ex3_byte_rev_offset             = ex2_byte_rev_offset + 1;
   parameter                         ex1_valid_offset                = ex3_byte_rev_offset + 1;
   parameter                         ex1_ttype_offset                = ex1_valid_offset + `THREADS;
   parameter                         ex2_valid_offset                = ex1_ttype_offset + 2;
   parameter                         ex2_pfetch_val_offset           = ex2_valid_offset + `THREADS;
   parameter                         ex2_itag_offset                 = ex2_pfetch_val_offset + `THREADS;
   parameter                         ex2_ttype_offset                = ex2_itag_offset + `ITAG_SIZE_ENC;
   parameter                         ex2_ws_offset                   = ex2_ttype_offset + ttype_width;
   parameter                         ex2_rs_is_offset                = ex2_ws_offset + ws_width;
   parameter                         ex2_ra_entry_offset             = ex2_rs_is_offset + rs_is_width;
   parameter                         ex2_state_offset                = ex2_ra_entry_offset + 5;
   parameter                         ex2_pid_offset                  = ex2_state_offset + state_width;
   parameter                         ex2_extclass_offset             = ex2_pid_offset + pid_width;
   parameter                         ex2_tlbsel_offset               = ex2_extclass_offset + extclass_width;
   parameter                         ex2_data_in_offset              = ex2_tlbsel_offset + tlbsel_width;
   parameter                         ex3_valid_offset                = ex2_data_in_offset + GPR_WIDTH;
   parameter                         ex3_pfetch_val_offset           = ex3_valid_offset + `THREADS;
   parameter                         ex3_itag_offset                 = ex3_pfetch_val_offset + `THREADS;
   parameter                         ex3_ttype_offset                = ex3_itag_offset + `ITAG_SIZE_ENC;
   parameter                         ex3_ws_offset                   = ex3_ttype_offset + ttype_width;
   parameter                         ex3_rs_is_offset                = ex3_ws_offset + ws_width;
   parameter                         ex3_ra_entry_offset             = ex3_rs_is_offset + rs_is_width;
   parameter                         ex3_state_offset                = ex3_ra_entry_offset + 5;
   parameter                         ex3_pid_offset                  = ex3_state_offset + state_width;
   parameter                         ex3_extclass_offset             = ex3_pid_offset + pid_width;
   parameter                         ex3_tlbsel_offset               = ex3_extclass_offset + extclass_width;
   parameter                         ex4_valid_offset                = ex3_tlbsel_offset + tlbsel_width;
   parameter                         ex4_pfetch_val_offset           = ex4_valid_offset + `THREADS;
   parameter                         ex4_itag_offset                 = ex4_pfetch_val_offset + `THREADS;
   parameter                         ex4_ttype_offset                = ex4_itag_offset + `ITAG_SIZE_ENC;
   parameter                         ex4_ws_offset                   = ex4_ttype_offset + ttype_width;
   parameter                         ex4_rs_is_offset                = ex4_ws_offset + ws_width;
   parameter                         ex4_ra_entry_offset             = ex4_rs_is_offset + rs_is_width;
   parameter                         ex4_state_offset                = ex4_ra_entry_offset + 5;
   parameter                         ex4_pid_offset                  = ex4_state_offset + state_width;
   parameter                         ex4_lpid_offset                 = ex4_pid_offset + pid_width;
   parameter                         ex4_extclass_offset             = ex4_lpid_offset + lpid_width;
   parameter                         ex4_tlbsel_offset               = ex4_extclass_offset + extclass_width;
   parameter                         ex5_valid_offset                = ex4_tlbsel_offset + tlbsel_width;
   parameter                         ex5_pfetch_val_offset           = ex5_valid_offset + `THREADS;
   parameter                         ex5_itag_offset                 = ex5_pfetch_val_offset + `THREADS;
   parameter                         ex5_ttype_offset                = ex5_itag_offset + `ITAG_SIZE_ENC;
   parameter                         ex5_ws_offset                   = ex5_ttype_offset + ttype_width;
   parameter                         ex5_rs_is_offset                = ex5_ws_offset + ws_width;
   parameter                         ex5_ra_entry_offset             = ex5_rs_is_offset + rs_is_width;
   parameter                         ex5_state_offset                = ex5_ra_entry_offset + 5;
   parameter                         ex5_pid_offset                  = ex5_state_offset + state_width;
   parameter                         ex5_lpid_offset                 = ex5_pid_offset + pid_width;
   parameter                         ex5_extclass_offset             = ex5_lpid_offset + lpid_width;
   parameter                         ex5_tlbsel_offset               = ex5_extclass_offset + extclass_width;
   parameter                         ex6_valid_offset                = ex5_tlbsel_offset + tlbsel_width;
   parameter                         ex6_pfetch_val_offset           = ex6_valid_offset + `THREADS;
   parameter                         ex6_itag_offset                 = ex6_pfetch_val_offset + `THREADS;
   parameter                         ex6_ttype_offset                = ex6_itag_offset + `ITAG_SIZE_ENC;
   parameter                         ex6_ws_offset                   = ex6_ttype_offset + ttype_width;
   parameter                         ex6_rs_is_offset                = ex6_ws_offset + ws_width;
   parameter                         ex6_ra_entry_offset             = ex6_rs_is_offset + rs_is_width;
   parameter                         ex6_state_offset                = ex6_ra_entry_offset + 5;
   parameter                         ex6_pid_offset                  = ex6_state_offset + state_width;
   parameter                         ex6_extclass_offset             = ex6_pid_offset + pid_width;
   parameter                         ex6_tlbsel_offset               = ex6_extclass_offset + extclass_width;
   parameter                         ex7_valid_offset                = ex6_tlbsel_offset + tlbsel_width;
   parameter                         ex7_pfetch_val_offset           = ex7_valid_offset + `THREADS;
   parameter                         ex7_ttype_offset                = ex7_pfetch_val_offset + `THREADS;
   parameter                         ex7_ws_offset                   = ex7_ttype_offset + ttype_width;
   parameter                         ex7_rs_is_offset                = ex7_ws_offset + ws_width;
   parameter                         ex7_ra_entry_offset             = ex7_rs_is_offset + rs_is_width;
   parameter                         ex7_state_offset                = ex7_ra_entry_offset + 5;
   parameter                         ex7_pid_offset                  = ex7_state_offset + state_width;
   parameter                         ex7_extclass_offset             = ex7_pid_offset + pid_width;
   parameter                         ex7_tlbsel_offset               = ex7_extclass_offset + extclass_width;
   parameter                         ex8_valid_offset                = ex7_tlbsel_offset + tlbsel_width;
   parameter                         ex8_pfetch_val_offset           = ex8_valid_offset + `THREADS;
   parameter                         ex8_ttype_offset                = ex8_pfetch_val_offset + `THREADS;
   parameter                         ex8_tlbsel_offset               = ex8_ttype_offset + ttype_width;
   parameter                         ex5_data_out_offset             = ex8_tlbsel_offset + tlbsel_width;
   parameter                         tlb_req_inprogress_offset       = ex5_data_out_offset + GPR_WIDTH;
   parameter                         ex3_dsi_offset                  = tlb_req_inprogress_offset + 1;
   parameter                         ex3_noop_touch_offset           = ex3_dsi_offset + 8 + 2 * `THREADS;
   parameter                         ex4_miss_offset                 = ex3_noop_touch_offset + 8 + 2 * `THREADS;
   parameter                         ex4_dsi_offset                  = ex4_miss_offset + `THREADS;
   parameter                         ex4_noop_touch_offset           = ex4_dsi_offset + 8 + 2 * `THREADS;
   parameter                         ex4_multihit_offset             = ex4_noop_touch_offset + 8 + 2 * `THREADS;
   parameter                         ex4_multihit_b_pt_offset        = ex4_multihit_offset + `THREADS;
   parameter                         ex4_first_hit_entry_pt_offset   = ex4_multihit_b_pt_offset + num_entry;
   parameter                         ex4_parerr_offset               = ex4_first_hit_entry_pt_offset + num_entry - 1;
   parameter                         ex4_attr_offset                 = ex4_parerr_offset + `THREADS + 2;
   parameter                         ex4_hit_offset                  = ex4_attr_offset + 6;
   parameter                         ex4_cam_hit_offset              = ex4_hit_offset + 1;
   parameter                         ex3_debug_offset                = ex4_cam_hit_offset + 1;
   parameter                         ex4_debug_offset                = ex3_debug_offset + 11;
   parameter                         rw_entry_offset                 = ex4_debug_offset + 17;
   parameter                         rw_entry_val_offset             = rw_entry_offset + 5;
   parameter                         rw_entry_le_offset              = rw_entry_val_offset + 1;
   parameter                         cam_entry_le_offset             = rw_entry_le_offset + 1;
   parameter                         spare_a_offset                  = cam_entry_le_offset + 32;
   parameter                         scan_right_0                    = spare_a_offset + 16 - 1;

   // parerr macro is commented out below
   parameter                         ex3_comp_addr_offset            = 0;
   parameter                         ex4_rpn_offset                  = ex3_comp_addr_offset + 30;
   parameter                         ex4_wimge_offset                = ex4_rpn_offset + 30;
   parameter                         ex4_cam_cmp_data_offset         = ex4_wimge_offset + 5;
   parameter                         ex4_array_cmp_data_offset       = ex4_cam_cmp_data_offset + cam_data_width;
   parameter                         ex4_rd_cam_data_offset          = ex4_array_cmp_data_offset + array_data_width;
   parameter                         ex4_rd_array_data_offset        = ex4_rd_cam_data_offset + cam_data_width;
   parameter                         ex5_parerr_offset               = ex4_rd_array_data_offset + array_data_width;
   parameter                         ex5_fir_parerr_offset           = ex5_parerr_offset + `THREADS + 5;
   parameter                         ex5_fir_multihit_offset         = ex5_fir_parerr_offset + `THREADS + 3;
   parameter                         ex5_deen_offset                 = ex5_fir_multihit_offset + `THREADS;
   parameter                         ex5_hit_offset                  = ex5_deen_offset + num_entry_log2 + `THREADS;
   parameter                         ex6_deen_offset                 = ex5_hit_offset + 1;
   parameter                         ex6_hit_offset                  = ex6_deen_offset + num_entry_log2 + `THREADS;
   parameter                         ex7_deen_offset                 = ex6_hit_offset + 1;
   parameter                         ex7_hit_offset                  = ex7_deen_offset + num_entry_log2 + `THREADS;
   parameter                         barrier_done_offset             = ex7_hit_offset + 1;
   parameter                         mmucr1_offset                   = barrier_done_offset + `THREADS;
   parameter                         rpn_holdreg_offset              = mmucr1_offset + 10;
   parameter                         entry_valid_offset              = rpn_holdreg_offset + 64 * `THREADS;
   parameter                         entry_match_offset              = entry_valid_offset + 32;
   parameter                         watermark_offset                = entry_match_offset + 32;
   parameter                         mmucr1_b0_cpy_offset            = watermark_offset + watermark_width;
   parameter                         lru_rmt_vec_offset              = mmucr1_b0_cpy_offset + 1;
   parameter                         eptr_offset                     = lru_rmt_vec_offset + lru_width + 1;
   parameter                         lru_offset                      = eptr_offset + eptr_width;
   parameter                         lru_update_event_offset         = lru_offset + lru_width;
   parameter                         lru_debug_offset                = lru_update_event_offset + 10;
   parameter                         snoop_val_offset                = lru_debug_offset + 41;
   parameter                         snoop_attr_offset               = snoop_val_offset + 3;
   parameter                         snoop_addr_offset               = snoop_attr_offset + 26;
   parameter                         ex3_epn_offset                  = snoop_addr_offset + epn_width;
   parameter                         ex4_epn_offset                  = ex3_epn_offset + (2 ** `GPR_WIDTH_ENC) - 12;
   parameter                         ex5_epn_offset                  = ex4_epn_offset + (2 ** `GPR_WIDTH_ENC) - 12;
   parameter                         por_seq_offset                  = ex5_epn_offset + (2 ** `GPR_WIDTH_ENC) - 12;
   parameter                         pc_xu_init_reset_offset         = por_seq_offset + 3;
   parameter                         tlb_rel_val_offset              = pc_xu_init_reset_offset + 1;
   parameter                         tlb_rel_data_offset             = tlb_rel_val_offset + 5;
   parameter                         tlb_rel_emq_offset              = tlb_rel_data_offset + 132;
   parameter                         eplc_wr_offset                  = tlb_rel_emq_offset + `EMQ_ENTRIES;
   parameter                         epsc_wr_offset                  = eplc_wr_offset + 2 * `THREADS + 1;
   parameter                         ccr2_frat_paranoia_offset       = epsc_wr_offset + 2 * `THREADS + 1;
   parameter                         clkg_ctl_override_offset        = ccr2_frat_paranoia_offset + 12;
   parameter                         ex1_stg_act_offset              = clkg_ctl_override_offset + 1;
   parameter                         ex2_stg_act_offset              = ex1_stg_act_offset + 1;
   parameter                         ex3_stg_act_offset              = ex2_stg_act_offset + 1;
   parameter                         ex4_stg_act_offset              = ex3_stg_act_offset + 1;
   parameter                         ex5_stg_act_offset              = ex4_stg_act_offset + 1;
   parameter                         ex6_stg_act_offset              = ex5_stg_act_offset + 1;
   parameter                         tlb_rel_act_offset              = ex6_stg_act_offset + 1;
   parameter                         snoopp_act_offset               = tlb_rel_act_offset + 1;
   parameter                         an_ac_grffence_en_dc_offset     = snoopp_act_offset + 1;
   parameter                         spare_b_offset                  = an_ac_grffence_en_dc_offset + 1;
   parameter                         csync_val_offset                = spare_b_offset + 16;
   parameter                         isync_val_offset                = csync_val_offset + 2;
   parameter                         rel_val_offset                  = isync_val_offset + 2;
   parameter                         rel_hit_offset                  = rel_val_offset + 4;
   parameter                         rel_data_offset                 = rel_hit_offset + 1;
   parameter                         rel_emq_offset                  = rel_data_offset + 132;
   parameter                         rel_int_upd_val_offset          = rel_emq_offset + `EMQ_ENTRIES;
   parameter                         epsc_wr_val_offset              = rel_int_upd_val_offset + `EMQ_ENTRIES;
   parameter                         eplc_wr_val_offset              = epsc_wr_val_offset + `THREADS;
   parameter                         rv1_binv_val_offset             = eplc_wr_val_offset + `THREADS;
   parameter                         snoopp_val_offset               = rv1_binv_val_offset + 1;
   parameter                         snoopp_attr_offset              = snoopp_val_offset + 1;
   parameter                         snoopp_vpn_offset               = snoopp_attr_offset + 26;
   parameter                         ttype_val_offset                = snoopp_vpn_offset + epn_width;
   parameter                         ttype_offset                    = ttype_val_offset + `THREADS;
   parameter                         ws_offset                       = ttype_offset + 4;
   parameter                         ra_entry_offset                 = ws_offset + ws_width;
   parameter                         rs_data_offset                  = ra_entry_offset + 5;
   parameter                         eratre_hole_offset              = rs_data_offset + GPR_WIDTH;
   parameter                         eratwe_hole_offset              = eratre_hole_offset + 4;
   parameter                         rv1_csync_val_offset            = eratwe_hole_offset + 4;
   parameter                         ex0_csync_val_offset            = rv1_csync_val_offset + 1;
   parameter                         rv1_isync_val_offset            = ex0_csync_val_offset + 1;
   parameter                         ex0_isync_val_offset            = rv1_isync_val_offset + 1;
   parameter                         rv1_rel_val_offset              = ex0_isync_val_offset + 1;
   parameter                         ex0_rel_val_offset              = rv1_rel_val_offset + 4;
   parameter                         ex1_rel_val_offset              = ex0_rel_val_offset + 4;
   parameter                         rv1_epsc_wr_val_offset          = ex1_rel_val_offset + 4;
   parameter                         ex0_epsc_wr_val_offset          = rv1_epsc_wr_val_offset + `THREADS;
   parameter                         rv1_eplc_wr_val_offset          = ex0_epsc_wr_val_offset + `THREADS;
   parameter                         ex0_eplc_wr_val_offset          = rv1_eplc_wr_val_offset + `THREADS;
   parameter                         ex0_binv_val_offset             = ex0_eplc_wr_val_offset + `THREADS;
   parameter                         ex1_binv_val_offset             = ex0_binv_val_offset + 1;
   parameter                         rv1_snoop_val_offset            = ex1_binv_val_offset + 1;
   parameter                         ex0_snoop_val_offset            = rv1_snoop_val_offset + 1;
   parameter                         ex1_snoop_val_offset            = ex0_snoop_val_offset + 1;
   parameter                         rv1_ttype_val_offset            = ex1_snoop_val_offset + 1;
   parameter                         ex0_ttype_val_offset            = rv1_ttype_val_offset + `THREADS;
   parameter                         rv1_ttype_offset                = ex0_ttype_val_offset + `THREADS;
   parameter                         ex0_ttype_offset                = rv1_ttype_offset + 4;
   parameter                         ex1_ttype03_offset              = ex0_ttype_offset + 4;
   parameter                         ex1_ttype67_offset              = ex1_ttype03_offset + 4;
   parameter                         ex1_valid_op_offset             = ex1_ttype67_offset + 2;
   parameter                         ex2_valid_op_offset             = ex1_valid_op_offset + `THREADS;
   parameter                         ex3_valid_op_offset             = ex2_valid_op_offset + `THREADS;
   parameter                         ex4_valid_op_offset             = ex3_valid_op_offset + `THREADS;
   parameter                         ex5_valid_op_offset             = ex4_valid_op_offset + `THREADS;
   parameter                         ex6_valid_op_offset             = ex5_valid_op_offset + `THREADS;
   parameter                         ex7_valid_op_offset             = ex6_valid_op_offset + `THREADS;
   parameter                         ex8_valid_op_offset             = ex7_valid_op_offset + `THREADS;
   parameter                         lq_xu_ord_write_done_offset     = ex8_valid_op_offset + `THREADS;
   parameter                         lq_xu_ord_read_done_offset      = lq_xu_ord_write_done_offset + 1;
   parameter                         xu_lq_act_offset                = lq_xu_ord_read_done_offset + 1;
   parameter                         xu_lq_val_offset                = xu_lq_act_offset + 1;
   parameter                         xu_lq_is_eratre_offset          = xu_lq_val_offset + `THREADS;
   parameter                         xu_lq_is_eratwe_offset          = xu_lq_is_eratre_offset + 1;
   parameter                         xu_lq_is_eratsx_offset          = xu_lq_is_eratwe_offset + 1;
   parameter                         xu_lq_is_eratilx_offset         = xu_lq_is_eratsx_offset + 1;
   parameter                         xu_lq_ws_offset                 = xu_lq_is_eratilx_offset + 1;
   parameter                         xu_lq_ra_entry_offset           = xu_lq_ws_offset + 2;
   parameter                         xu_lq_rs_data_offset            = xu_lq_ra_entry_offset + 5;
   parameter                         cp_flush_offset                 = xu_lq_rs_data_offset + GPR_WIDTH;
   parameter                         ex4_oldest_itag_offset          = cp_flush_offset + `THREADS;
   parameter                         ex4_nonspec_val_offset          = ex4_oldest_itag_offset + 1;
   parameter                         ex4_tlbmiss_offset              = ex4_nonspec_val_offset + 1;
   parameter                         ex4_tlbinelig_offset            = ex4_tlbmiss_offset + 1;
   parameter                         ex4_ptfault_offset              = ex4_tlbinelig_offset + 1;
   parameter                         ex4_lratmiss_offset             = ex4_ptfault_offset + 1;
   parameter                         ex4_tlb_multihit_offset         = ex4_lratmiss_offset + 1;
   parameter                         ex4_tlb_par_err_offset          = ex4_tlb_multihit_offset + 1;
   parameter                         ex4_lru_par_err_offset          = ex4_tlb_par_err_offset + 1;
   parameter                         ex4_tlb_excp_det_offset         = ex4_lru_par_err_offset + 1;
   parameter                         ex3_eratm_itag_hit_offset       = ex4_tlb_excp_det_offset + 1;
   parameter                         ex4_emq_excp_rpt_offset         = ex3_eratm_itag_hit_offset + `EMQ_ENTRIES;
   parameter                         ex5_emq_excp_rpt_offset         = ex4_emq_excp_rpt_offset + `EMQ_ENTRIES;
   parameter                         ex6_emq_excp_rpt_offset         = ex5_emq_excp_rpt_offset + `EMQ_ENTRIES;
   parameter                         ex5_tlb_excp_val_offset         = ex6_emq_excp_rpt_offset + `EMQ_ENTRIES;
   parameter                         ex6_tlb_excp_val_offset         = ex5_tlb_excp_val_offset + `THREADS;
   parameter                         ex4_gate_miss_offset            = ex6_tlb_excp_val_offset + `THREADS;
   parameter                         ex4_full_restart_offset         = ex4_gate_miss_offset + 1;
   parameter                         ex4_itag_hit_restart_offset     = ex4_full_restart_offset + 1;
   parameter                         ex4_epn_hit_restart_offset      = ex4_itag_hit_restart_offset + 1;
   parameter                         ex4_setHold_offset              = ex4_epn_hit_restart_offset + 1;
   parameter                         ex5_tlbreq_val_offset           = ex4_setHold_offset + 1;
   parameter                         ex5_tlbreq_nonspec_offset       = ex5_tlbreq_val_offset + 1;
   parameter                         ex5_thdid_offset                = ex5_tlbreq_nonspec_offset + 1;
   parameter                         ex5_emq_offset                  = ex5_thdid_offset + `THREADS;
   parameter                         ex5_tlbreq_ttype_offset         = ex5_emq_offset + `EMQ_ENTRIES;
   parameter                         ex5_perf_dtlb_offset            = ex5_tlbreq_ttype_offset + 2;
   parameter                         derat_dcc_clr_hold_offset       = ex5_perf_dtlb_offset + `THREADS;
   parameter                         eratm_entry_state_offset        = derat_dcc_clr_hold_offset + `THREADS;
   parameter                         eratm_entry_itag_offset         = eratm_entry_state_offset + 3 * `EMQ_ENTRIES;
   parameter                         eratm_entry_tid_offset          = eratm_entry_itag_offset + `ITAG_SIZE_ENC * `EMQ_ENTRIES;
   parameter                         eratm_entry_epn_offset          = eratm_entry_tid_offset + `THREADS * `EMQ_ENTRIES;
   parameter                         eratm_entry_nonspec_val_offset  = eratm_entry_epn_offset + ((2 ** `GPR_WIDTH_ENC) - 12) * `EMQ_ENTRIES;
   parameter                         eratm_entry_mkill_offset        = eratm_entry_nonspec_val_offset + `EMQ_ENTRIES;
   parameter                         eratm_hold_tid_offset           = eratm_entry_mkill_offset + `EMQ_ENTRIES;
   parameter                         mm_int_rpt_itag_offset          = eratm_hold_tid_offset + `THREADS;
   parameter                         mm_int_rpt_tlbmiss_offset       = mm_int_rpt_itag_offset + `ITAG_SIZE_ENC;
   parameter                         mm_int_rpt_tlbinelig_offset     = mm_int_rpt_tlbmiss_offset + 1;
   parameter                         mm_int_rpt_ptfault_offset       = mm_int_rpt_tlbinelig_offset + 1;
   parameter                         mm_int_rpt_lratmiss_offset      = mm_int_rpt_ptfault_offset + 1;
   parameter                         mm_int_rpt_tlb_multihit_offset  = mm_int_rpt_lratmiss_offset + 1;
   parameter                         mm_int_rpt_tlb_par_err_offset   = mm_int_rpt_tlb_multihit_offset + 1;
   parameter                         mm_int_rpt_lru_par_err_offset   = mm_int_rpt_tlb_par_err_offset + 1;
   parameter                         eratm_entry_tlbmiss_offset      = mm_int_rpt_lru_par_err_offset + 1;
   parameter                         eratm_entry_tlbinelig_offset    = eratm_entry_tlbmiss_offset + `EMQ_ENTRIES;
   parameter                         eratm_entry_ptfault_offset      = eratm_entry_tlbinelig_offset + `EMQ_ENTRIES;
   parameter                         eratm_entry_lratmiss_offset     = eratm_entry_ptfault_offset + `EMQ_ENTRIES;
   parameter                         eratm_entry_tlb_multihit_offset = eratm_entry_lratmiss_offset + `EMQ_ENTRIES;
   parameter                         eratm_entry_tlb_par_err_offset  = eratm_entry_tlb_multihit_offset + `EMQ_ENTRIES;
   parameter                         eratm_entry_lru_par_err_offset  = eratm_entry_tlb_par_err_offset + `EMQ_ENTRIES;
   parameter                         scan_right_1                    = eratm_entry_lru_par_err_offset + `EMQ_ENTRIES - 1;

   parameter                         bcfg_offset                     = 0;
   parameter                         boot_scan_right                 = bcfg_offset + bcfg_width - 1;

   //--------------------------
   // signals
   //--------------------------
   // Latch signals
   wire [0:`THREADS-1]                ex1_valid_d;
   wire [0:`THREADS-1]                ex1_valid_q;
   wire [10:11]                       ex1_ttype_d;
   wire [10:11]                       ex1_ttype_q;
   wire [0:`THREADS-1]                ex2_valid_d;
   wire [0:`THREADS-1]                ex2_valid_q;
   wire [0:`THREADS-1]                ex2_pfetch_val_d;
   wire [0:`THREADS-1]                ex2_pfetch_val_q;
   wire [0:`ITAG_SIZE_ENC-1]          ex2_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]          ex2_itag_q;
   wire [0:ttype_width-1]             ex2_ttype_d;
   wire [0:ttype_width-1]             ex2_ttype_q;
   wire [0:ws_width-1]                ex2_ws_d;
   wire [0:ws_width-1]                ex2_ws_q;
   wire [0:rs_is_width-1]             ex2_rs_is_d;
   wire [0:rs_is_width-1]             ex2_rs_is_q;
   wire [0:4]                         ex2_ra_entry_d;
   wire [0:4]                         ex2_ra_entry_q;
   wire [0:state_width-1]             ex2_state_d;
   wire [0:state_width-1]             ex2_state_q;
   wire [0:pid_width-1]               ex2_pid_d;
   wire [0:pid_width-1]               ex2_pid_q;
   reg  [0:extclass_width-1]          ex2_extclass_d;
   wire [0:extclass_width-1]          ex2_extclass_q;
   reg  [0:tlbsel_width-1]            ex2_tlbsel_d;
   wire [0:tlbsel_width-1]            ex2_tlbsel_q;
   wire [0:`THREADS-1]                ex3_valid_d;
   wire [0:`THREADS-1]                ex3_valid_q;
   wire [0:`ITAG_SIZE_ENC-1]          ex3_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]          ex3_itag_q;
   wire [0:`THREADS-1]                ex3_pfetch_val_d;
   wire [0:`THREADS-1]                ex3_pfetch_val_q;
   wire [0:ttype_width-1]             ex3_ttype_d;
   wire [0:ttype_width-1]             ex3_ttype_q;
   wire [0:ws_width-1]                ex3_ws_d;
   wire [0:ws_width-1]                ex3_ws_q;
   wire [0:rs_is_width-1]             ex3_rs_is_d;
   wire [0:rs_is_width-1]             ex3_rs_is_q;
   wire [0:4]                         ex3_ra_entry_d;
   wire [0:4]                         ex3_ra_entry_q;
   wire [0:state_width-1]             ex3_state_d;
   wire [0:state_width-1]             ex3_state_q;
   wire [0:pid_width-1]               ex3_pid_d;
   wire [0:pid_width-1]               ex3_pid_q;
   wire [0:extclass_width-1]          ex3_extclass_d;
   wire [0:extclass_width-1]          ex3_extclass_q;
   wire [0:tlbsel_width-1]            ex3_tlbsel_d;
   wire [0:tlbsel_width-1]            ex3_tlbsel_q;
   wire [0:`THREADS-1]                ex4_valid_d;
   wire [0:`THREADS-1]                ex4_valid_q;
   wire [0:`THREADS-1]                ex4_pfetch_val_d;
   wire [0:`THREADS-1]                ex4_pfetch_val_q;
   wire [0:`ITAG_SIZE_ENC-1]          ex4_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]          ex4_itag_q;
   wire [0:ttype_width-1]             ex4_ttype_d;
   wire [0:ttype_width-1]             ex4_ttype_q;
   wire [0:ws_width-1]                ex4_ws_d;
   wire [0:ws_width-1]                ex4_ws_q;
   wire [0:rs_is_width-1]             ex4_rs_is_d;
   wire [0:rs_is_width-1]             ex4_rs_is_q;
   wire [0:4]                         ex4_ra_entry_d;
   wire [0:4]                         ex4_ra_entry_q;
   wire [0:state_width-1]             ex4_state_d;
   wire [0:state_width-1]             ex4_state_q;
   wire [0:pid_width-1]               ex4_pid_d;
   wire [0:pid_width-1]               ex4_pid_q;
   wire [0:lpid_width-1]              ex4_lpid_d;
   wire [0:lpid_width-1]              ex4_lpid_q;
   wire [0:extclass_width-1]          ex4_extclass_d;
   wire [0:extclass_width-1]          ex4_extclass_q;
   wire [0:tlbsel_width-1]            ex4_tlbsel_d;
   wire [0:tlbsel_width-1]            ex4_tlbsel_q;
   wire [0:`THREADS-1]                ex5_valid_d;
   wire [0:`THREADS-1]                ex5_valid_q;
   wire [0:`THREADS-1]                ex5_pfetch_val_d;
   wire [0:`THREADS-1]                ex5_pfetch_val_q;
   wire [0:`ITAG_SIZE_ENC-1]          ex5_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]          ex5_itag_q;
   wire [0:ttype_width-1]             ex5_ttype_d;
   wire [0:ttype_width-1]             ex5_ttype_q;
   wire [0:ws_width-1]                ex5_ws_d;
   wire [0:ws_width-1]                ex5_ws_q;
   wire [0:rs_is_width-1]             ex5_rs_is_d;
   wire [0:rs_is_width-1]             ex5_rs_is_q;
   wire [0:4]                         ex5_ra_entry_d;
   wire [0:4]                         ex5_ra_entry_q;
   wire [0:state_width-1]             ex5_state_d;
   wire [0:state_width-1]             ex5_state_q;
   wire [0:pid_width-1]               ex5_pid_d;
   wire [0:pid_width-1]               ex5_pid_q;
   wire [0:lpid_width-1]              ex5_lpid_d;
   wire [0:lpid_width-1]              ex5_lpid_q;
   wire [0:extclass_width-1]          ex5_extclass_d;
   wire [0:extclass_width-1]          ex5_extclass_q;
   wire [0:tlbsel_width-1]            ex5_tlbsel_d;
   wire [0:tlbsel_width-1]            ex5_tlbsel_q;
   wire [0:`THREADS-1]                ex6_valid_d;
   wire [0:`THREADS-1]                ex6_valid_q;
   wire [0:`THREADS-1]                ex6_pfetch_val_d;
   wire [0:`THREADS-1]                ex6_pfetch_val_q;
   wire [0:`ITAG_SIZE_ENC-1]          ex6_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]          ex6_itag_q;
   wire [0:ttype_width-1]             ex6_ttype_d;
   wire [0:ttype_width-1]             ex6_ttype_q;
   wire [0:ws_width-1]                ex6_ws_d;
   wire [0:ws_width-1]                ex6_ws_q;
   wire [0:rs_is_width-1]             ex6_rs_is_d;
   wire [0:rs_is_width-1]             ex6_rs_is_q;
   wire [0:4]                         ex6_ra_entry_d;
   wire [0:4]                         ex6_ra_entry_q;
   wire [0:state_width-1]             ex6_state_d;
   wire [0:state_width-1]             ex6_state_q;
   wire [0:pid_width-1]               ex6_pid_d;
   wire [0:pid_width-1]               ex6_pid_q;
   wire [0:extclass_width-1]          ex6_extclass_d;
   wire [0:extclass_width-1]          ex6_extclass_q;
   wire [0:tlbsel_width-1]            ex6_tlbsel_d;
   wire [0:tlbsel_width-1]            ex6_tlbsel_q;
   wire [0:`THREADS-1]                ex7_valid_d;
   wire [0:`THREADS-1]                ex7_valid_q;
   wire [0:`THREADS-1]                ex7_pfetch_val_d;
   wire [0:`THREADS-1]                ex7_pfetch_val_q;
   wire [0:ttype_width-1]             ex7_ttype_d;
   wire [0:ttype_width-1]             ex7_ttype_q;
   wire [0:ws_width-1]                ex7_ws_d;
   wire [0:ws_width-1]                ex7_ws_q;
   wire [0:rs_is_width-1]             ex7_rs_is_d;
   wire [0:rs_is_width-1]             ex7_rs_is_q;
   wire [0:4]                         ex7_ra_entry_d;
   wire [0:4]                         ex7_ra_entry_q;
   wire [0:state_width-1]             ex7_state_d;
   wire [0:state_width-1]             ex7_state_q;
   wire [0:pid_width-1]               ex7_pid_d;
   wire [0:pid_width-1]               ex7_pid_q;
   wire [0:extclass_width-1]          ex7_extclass_d;
   wire [0:extclass_width-1]          ex7_extclass_q;
   wire [0:tlbsel_width-1]            ex7_tlbsel_d;
   wire [0:tlbsel_width-1]            ex7_tlbsel_q;
   wire [0:`THREADS-1]                ex8_valid_d;
   wire [0:`THREADS-1]                ex8_valid_q;
   wire [0:`THREADS-1]                ex8_pfetch_val_d;
   wire [0:`THREADS-1]                ex8_pfetch_val_q;
   wire [0:ttype_width-1]             ex8_ttype_d;
   wire [0:ttype_width-1]             ex8_ttype_q;
   wire [0:tlbsel_width-1]            ex8_tlbsel_d;
   wire [0:tlbsel_width-1]            ex8_tlbsel_q;
   wire [64-GPR_WIDTH:63]             ex2_data_in_d;
   wire [64-GPR_WIDTH:63]             ex2_data_in_q;
   wire [64-GPR_WIDTH:63]             ex5_data_out_d;
   wire [64-GPR_WIDTH:63]             ex5_data_out_q;
   wire                               tlb_req_inprogress_d;
   wire                               tlb_req_inprogress_q;
   wire                               ex2_deratre;
   wire                               ex2_deratwe;
   wire                               ex2_deratsx;
   wire                               ex2_deratwe_ws3;
   wire [0:7+2*`THREADS]              ex3_dsi_d;
   wire [0:7+2*`THREADS]              ex3_dsi_q;
   wire [0:7+2*`THREADS]              ex3_noop_touch_d;
   wire [0:7+2*`THREADS]              ex3_noop_touch_q;
   wire [0:`THREADS-1]                ex4_miss_d;
   wire [0:`THREADS-1]                ex4_miss_q;
   wire [0:7+2*`THREADS]              ex4_dsi_d;
   wire [0:7+2*`THREADS]              ex4_dsi_q;
   wire [0:7+2*`THREADS]              ex4_noop_touch_d;
   wire [0:7+2*`THREADS]              ex4_noop_touch_q;
   wire [0:`THREADS-1]                ex4_multihit_d;
   wire [0:`THREADS-1]                ex4_multihit_q;
   wire [1:num_entry]                 ex4_multihit_b_pt_d;
   wire [1:num_entry]                 ex4_multihit_b_pt_q;
   wire [1:num_entry-1]               ex4_first_hit_entry_pt_d;
   wire [1:num_entry-1]               ex4_first_hit_entry_pt_q;
   wire [0:`THREADS+1]                ex4_parerr_d;
   wire [0:`THREADS+1]                ex4_parerr_q;
   wire [0:5]                         ex4_attr_d;
   wire [0:5]                         ex4_attr_q;
   wire                               ex4_hit_d;
   wire                               ex4_hit_q;
   wire                               ex4_cam_hit_q;
   wire [0:10]                        ex3_debug_d;
   wire [0:10]                        ex3_debug_q;
   wire [0:16]                        ex4_debug_d;
   wire [0:16]                        ex4_debug_q;
   wire [0:cam_data_width-1]          ex4_cam_cmp_data_d;
   wire [0:cam_data_width-1]          ex4_cam_cmp_data_q;
   wire [0:array_data_width-1]        ex4_array_cmp_data_d;
   wire [0:array_data_width-1]        ex4_array_cmp_data_q;
   wire [0:array_data_width-1]        ex4_rd_array_data_d;
   wire [0:array_data_width-1]        ex4_rd_array_data_q;
   wire [0:cam_data_width-1]          ex4_rd_cam_data_d;
   wire [0:cam_data_width-1]          ex4_rd_cam_data_q;
   wire [0:`THREADS+4]                ex5_parerr_d;
   wire [0:`THREADS+4]                ex5_parerr_q;
   wire [0:`THREADS+2]                ex5_fir_parerr_d;
   wire [0:`THREADS+2]                ex5_fir_parerr_q;
   wire [0:`THREADS-1]                ex5_fir_multihit_d;
   wire [0:`THREADS-1]                ex5_fir_multihit_q;
   wire [0:`THREADS+num_entry_log2-1] ex5_deen_d;
   wire [0:`THREADS+num_entry_log2-1] ex5_deen_q;
   wire                               ex5_hit_d;
   wire                               ex5_hit_q;
   wire [0:`THREADS+num_entry_log2-1] ex6_deen_d;
   wire [0:`THREADS+num_entry_log2-1] ex6_deen_q;
   wire                               ex6_hit_d;
   wire                               ex6_hit_q;
   wire [0:`THREADS+num_entry_log2-1] ex7_deen_d;
   wire [0:`THREADS+num_entry_log2-1] ex7_deen_q;
   wire                               ex7_hit_d;
   wire                               ex7_hit_q;
   wire                               ex4_deratwe;
   wire                               ex5_deratwe;
   wire                               ex6_deratwe;
   wire                               ex7_deratwe;
   wire                               ex8_deratwe;
   wire [0:`THREADS-1]                barrier_done_d;
   wire [0:`THREADS-1]                barrier_done_q;
   wire [0:9]                         mmucr1_d;
   wire [0:9]                         mmucr1_q;
   wire [22:51]                       ex3_comp_addr_d;
   wire [22:51]                       ex3_comp_addr_q;
   wire [22:51]                       ex4_rpn_d;
   wire [22:51]                       ex4_rpn_q;
   wire [0:4]                         ex4_wimge_d;
   wire [0:4]                         ex4_wimge_q;
   wire                               mmucr1_b0_cpy_d;
   wire                               mmucr1_b0_cpy_q;
   wire [0:lru_width]                 lru_rmt_vec_d;
   wire [0:lru_width]                 lru_rmt_vec_q;
   wire [0:7]                         ex4_dsi;
   wire [3:7]                         ex4_noop_touch;
   reg  [0:2]                         por_seq_d;
   wire [0:2]                         por_seq_q;
   wire [0:63]                        rpn_holdreg_d[0:`THREADS-1];
   wire [0:63]                        rpn_holdreg_q[0:`THREADS-1];
   reg  [0:63]                        ex2_rpn_holdreg;
   wire [0:watermark_width-1]         watermark_d;
   wire [0:watermark_width-1]         watermark_q;
   wire [0:eptr_width-1]              eptr_d;
   wire [0:eptr_width-1]              eptr_q;
   wire [1:lru_width]                 lru_d;
   wire [1:lru_width]                 lru_q;
   wire [0:9]                         lru_update_event_d;
   wire [0:9]                         lru_update_event_q;
   wire [0:40]                        lru_debug_d;
   wire [0:40]                        lru_debug_q;
   wire [0:2]                         snoop_val_d;
   wire [0:2]                         snoop_val_q;
   wire [0:25]                        snoop_attr_d;
   wire [0:25]                        snoop_attr_q;
   wire [52-epn_width:51]             snoop_addr_d;
   wire [52-epn_width:51]             snoop_addr_q;
   wire [64-(2**`GPR_WIDTH_ENC):51]   ex3_epn_d;
   wire [64-(2**`GPR_WIDTH_ENC):51]   ex3_epn_q;
   wire [64-(2**`GPR_WIDTH_ENC):51]   ex4_epn_q;
   wire [64-(2**`GPR_WIDTH_ENC):51]   ex5_epn_q;
   wire                               pc_xu_init_reset_q;
   wire [0:4]                         tlb_rel_val_d;
   wire [0:4]                         tlb_rel_val_q;
   wire [0:131]                       tlb_rel_data_d;
   wire [0:131]                       tlb_rel_data_q;
   wire [0:`EMQ_ENTRIES-1]            tlb_rel_emq_d;
   wire [0:`EMQ_ENTRIES-1]            tlb_rel_emq_q;
   wire [0:2*`THREADS]                eplc_wr_d;
   wire [0:2*`THREADS]                eplc_wr_q;
   wire [0:2*`THREADS]                epsc_wr_d;
   wire [0:2*`THREADS]                epsc_wr_q;
   wire [0:11]                        ccr2_frat_paranoia_d;
   wire [0:11]                        ccr2_frat_paranoia_q;
   wire                               ex2_byte_rev_d;
   wire                               ex2_byte_rev_q;
   wire                               ex3_byte_rev_d;
   wire                               ex3_byte_rev_q;
   wire [0:bcfg_width-1]              bcfg_q;
   wire [0:bcfg_width-1]              bcfg_q_b;
   // logic signals
   reg  [0:1]                         por_wr_cam_val;
   reg  [0:1]                         por_wr_array_val;
   reg  [0:cam_data_width-1]          por_wr_cam_data;
   reg  [0:array_data_width-1]        por_wr_array_data;
   reg  [0:num_entry_log2-1]          por_wr_entry;
   reg  [0:`THREADS-1]                por_hold_req;
   wire                               ex3_multihit;
   wire                               ex3_multihit_b;
   wire [0:num_entry_log2-1]          ex3_first_hit_entry;
   wire [0:num_entry_log2-1]          ex4_first_hit_entry;
   wire                               ex4_dsi_enab;
   wire                               ex4_noop_touch_enab;
   wire                               ex4_multihit_enab;
   wire [0:1]                         ex4_parerr_enab;


   wire [0:2+num_entry_log2-1]        ex4_eratsx_data;
   wire [0:num_entry_log2-1]          lru_way_encode;
   wire [0:lru_width]                 lru_rmt_vec;
   wire [1:lru_width]                 lru_reset_vec;
   wire [1:lru_width]                 lru_set_vec;
   wire [1:lru_width]                 lru_op_vec;
   wire [1:lru_width]                 lru_vp_vec;
   wire [1:lru_width]                 lru_eff;
   wire [0:lru_width]                 lru_watermark_mask;
   wire [0:lru_width]                 entry_valid_watermarked;
   //signal lru_update_event             : std_ulogic;
   wire [0:eptr_width-1]              eptr_p1;
   //signal ex4_valid_32b  : std_ulogic;
   wire                               ex1_is_icbtlslc;
   wire [50:67]                       ex4_cmp_data_calc_par;
   wire                               ex4_cmp_data_parerr_epn_mac;
   wire                               ex4_cmp_data_parerr_rpn_mac;
   wire                               ex4_cmp_data_parerr_epn;
   wire                               ex4_cmp_data_parerr_rpn;
   wire [50:67]                       ex4_rd_data_calc_par;
   wire                               ex4_rd_data_parerr_epn;
   wire                               ex4_rd_data_parerr_rpn;


   wire                               ex5_parerr_enab;
   wire                               ex5_fir_parerr_enab;
   wire                               ex1_mmucr0_gs;
   wire                               ex1_mmucr0_ts;
   wire                               ex1_eplc_epr;
   wire                               ex1_epsc_epr;
   wire                               ex1_eplc_egs;
   wire                               ex1_epsc_egs;
   wire                               ex1_eplc_eas;
   wire                               ex1_epsc_eas;
   reg  [0:pid_width-1]               ex1_pid;
   reg  [0:pid_width-1]               ex1_mmucr0_pid;
   reg  [0:pid_width-1]               ex1_eplc_epid;
   reg  [0:pid_width-1]               ex1_epsc_epid;
   wire [0:3]                         tlb_rel_cmpmask;
   wire [0:3]                         tlb_rel_xbitmask;
   wire                               tlb_rel_maskpar;
   wire [0:3]                         ex2_data_cmpmask;
   wire [0:3]                         ex2_data_xbitmask;
   wire                               ex2_data_maskpar;
   wire [0:`THREADS-1]                cp_flush_d;
   wire [0:`THREADS-1]                cp_flush_q;
   // CAM/Array signals
   // Read Port
   wire                               rd_val;
   wire [0:4]                         rw_entry;
   // Write Port
   wire [51:67]                       wr_array_par;
   wire [0:array_data_width-1-10-7]   wr_array_data_nopar;
   wire [0:array_data_width-1]        wr_array_data;
   wire [0:cam_data_width-1]          wr_cam_data;
   wire [0:1]                         wr_array_val;
   wire [0:1]                         wr_cam_val;
   wire                               wr_val_early;
   // CAM Port
   wire                               comp_request;
   wire [0:51]                        comp_addr;
   wire [0:1]                         addr_enable;
   wire [0:2]                         comp_pgsize;
   wire                               pgsize_enable;
   wire [0:1]                         comp_class;
   wire [0:2]                         class_enable;
   wire [0:1]                         comp_extclass;
   wire [0:1]                         extclass_enable;
   wire [0:1]                         comp_state;
   wire [0:1]                         state_enable;
   wire [0:3]                         comp_thdid;
   wire [0:1]                         thdid_enable;
   wire [0:7]                         comp_pid;
   wire                               pid_enable;
   wire                               comp_invalidate;
   wire                               flash_invalidate;
   // Array Outputs
   wire [0:array_data_width-1]        array_cmp_data;
   wire [0:array_data_width-1]        rd_array_data;
   // CAM Outputs
   wire [0:cam_data_width-1]          cam_cmp_data;
   wire                               cam_hit;
   wire [0:4]                         cam_hit_entry;
   wire [0:31]                        entry_match;
   wire [0:31]                        entry_match_q;
   wire [0:31]                        entry_valid;
   wire [0:31]                        entry_valid_q;
   wire [0:cam_data_width-1]          rd_cam_data;


   wire [0:2]                         cam_pgsize;
   wire [0:3]                         ws0_pgsize;
   // new cam _np2 signals
   wire                               bypass_mux_enab_np1;
   wire [0:20]                        bypass_attr_np1;
   wire [0:20]                        attr_np2;
   wire [22:51]                       rpn_np2;
   // Pervasive
   wire                               pc_sg_1;
   wire                               pc_sg_0;
   wire                               pc_func_sl_thold_1;
   wire                               pc_func_sl_thold_0;
   wire                               pc_func_sl_thold_0_b;
   wire                               pc_func_slp_sl_thold_1;
   wire                               pc_func_slp_sl_thold_0;
   wire                               pc_func_slp_sl_thold_0_b;
   wire                               pc_func_sl_force;
   wire                               pc_func_slp_sl_force;
   wire                               pc_cfg_slp_sl_thold_1;
   wire                               pc_cfg_slp_sl_thold_0;
   wire                               pc_cfg_slp_sl_thold_0_b;
   wire                               pc_cfg_slp_sl_force;
   wire                               lcb_dclk;
   wire [0:`NCLK_WIDTH-1]             lcb_lclk;
   wire                               init_alias;
   // Clock Gating
   wire                               clkg_ctl_override_d;
   wire                               clkg_ctl_override_q;
   wire                               ex1_stg_act_d;
   wire                               ex1_stg_act_q;
   wire                               ex2_stg_act_d;
   wire                               ex2_stg_act_q;
   wire                               ex3_stg_act_d;
   wire                               ex3_stg_act_q;
   wire                               ex4_stg_act_d;
   wire                               ex4_stg_act_q;
   wire                               ex5_stg_act_d;
   wire                               ex5_stg_act_q;
   wire                               ex6_stg_act_d;
   wire                               ex6_stg_act_q;
   wire                               an_ac_grffence_en_dc_q;
   wire                               ex3_cmp_data_act;
   wire                               ex3_rd_data_act;
   wire                               entry_valid_act;
   wire                               entry_match_act;
   wire                               snoopp_act_q;
   wire                               snoopp_act;
   wire                               snoop_act;
   wire                               tlb_rel_act_d;
   wire                               tlb_rel_act_q;
   wire                               tlb_rel_act;
   wire                               mchk_flash_inv_act;
   wire [0:15]                        spare_a_q;
   wire [0:15]                        spare_b_q;
   wire [0:39]                        unused_dc;


   //- new latches and signals for A20 --------------------------------------------
   wire [0:1]                         csync_val_d;
   wire [0:1]                         csync_val_q;
   wire [0:1]                         isync_val_d;
   wire [0:1]                         isync_val_q;
   wire [0:3]                         rel_val_d;
   wire [0:3]                         rel_val_q;
   wire                               rel_hit_d;
   wire                               rel_hit_q;
   wire [0:131]                       rel_data_d;
   wire [0:131]                       rel_data_q;
   wire [0:`EMQ_ENTRIES-1]            rel_emq_d;
   wire [0:`EMQ_ENTRIES-1]            rel_emq_q;
   wire [0:`EMQ_ENTRIES-1]            rel_int_upd_val_d;
   wire [0:`EMQ_ENTRIES-1]            rel_int_upd_val_q;
   wire [0:`THREADS-1]                epsc_wr_val_d;
   wire [0:`THREADS-1]                epsc_wr_val_q;
   wire [0:`THREADS-1]                eplc_wr_val_d;
   wire [0:`THREADS-1]                eplc_wr_val_q;
   wire                               snoopp_val_d;
   wire                               snoopp_val_q;
   wire [0:25]                        snoopp_attr_d;
   wire [0:25]                        snoopp_attr_q;
   wire [52-epn_width:51]             snoopp_vpn_d;
   wire [52-epn_width:51]             snoopp_vpn_q;
   wire [0:`THREADS-1]                ttype_val_d;
   wire [0:`THREADS-1]                ttype_val_q;
   wire [0:3]                         ttype_d;
   wire [0:3]                         ttype_q;
   wire [0:ws_width-1]                ws_d;
   wire [0:ws_width-1]                ws_q;
   wire [0:4]                         ra_entry_d;
   wire [0:4]                         ra_entry_q;
   wire [64-GPR_WIDTH:63]             rs_data_d;
   wire [64-GPR_WIDTH:63]             rs_data_q;
   wire [0:3]                         eratre_hole_d;
   wire [0:3]                         eratre_hole_q;
   wire [0:3]                         eratwe_hole_d;
   wire [0:3]                         eratwe_hole_q;
   wire                               rv1_csync_val_d;
   wire                               rv1_csync_val_q;
   wire                               ex0_csync_val_d;
   wire                               ex0_csync_val_q;
   wire                               rv1_isync_val_d;
   wire                               rv1_isync_val_q;
   wire                               ex0_isync_val_d;
   wire                               ex0_isync_val_q;
   wire [0:3]                         rv1_rel_val_d;
   wire [0:3]                         rv1_rel_val_q;
   wire [0:3]                         ex0_rel_val_d;
   wire [0:3]                         ex0_rel_val_q;
   wire [0:3]                         ex1_rel_val_d;
   wire [0:3]                         ex1_rel_val_q;
   wire [0:`THREADS-1]                rv1_epsc_wr_val_d;
   wire [0:`THREADS-1]                rv1_epsc_wr_val_q;
   wire [0:`THREADS-1]                ex0_epsc_wr_val_d;
   wire [0:`THREADS-1]                ex0_epsc_wr_val_q;
   wire [0:`THREADS-1]                rv1_eplc_wr_val_d;
   wire [0:`THREADS-1]                rv1_eplc_wr_val_q;
   wire [0:`THREADS-1]                ex0_eplc_wr_val_d;
   wire [0:`THREADS-1]                ex0_eplc_wr_val_q;
   wire                               rv1_binv_val_d;
   wire                               rv1_binv_val_q;
   wire                               ex0_binv_val_d;
   wire                               ex0_binv_val_q;
   wire                               ex1_binv_val_d;
   wire                               ex1_binv_val_q;
   wire                               rv1_snoop_val_d;
   wire                               rv1_snoop_val_q;
   wire                               ex0_snoop_val_d;
   wire                               ex0_snoop_val_q;
   wire                               ex1_snoop_val_d;
   wire                               ex1_snoop_val_q;
   wire [0:`THREADS-1]                rv1_ttype_val_d;
   wire [0:`THREADS-1]                rv1_ttype_val_q;
   wire [0:`THREADS-1]                ex0_ttype_val_d;
   wire [0:`THREADS-1]                ex0_ttype_val_q;
   wire [0:3]                         rv1_ttype_d;
   wire [0:3]                         rv1_ttype_q;
   wire [0:3]                         ex0_ttype_d;
   wire [0:3]                         ex0_ttype_q;
   wire [0:3]                         ex1_ttype03_d;
   wire [0:3]                         ex1_ttype03_q;
   wire [0:1]                         ex1_ttype67_d;
   wire [0:1]                         ex1_ttype67_q;
   wire [0:`THREADS-1]                ex1_valid_op_d;
   wire [0:`THREADS-1]                ex1_valid_op_q;
   wire [0:`THREADS-1]                ex2_valid_op_d;
   wire [0:`THREADS-1]                ex2_valid_op_q;
   wire [0:`THREADS-1]                ex3_valid_op_d;
   wire [0:`THREADS-1]                ex3_valid_op_q;
   wire [0:`THREADS-1]                ex4_valid_op_d;
   wire [0:`THREADS-1]                ex4_valid_op_q;
   wire [0:`THREADS-1]                ex5_valid_op_d;
   wire [0:`THREADS-1]                ex5_valid_op_q;
   wire [0:`THREADS-1]                ex6_valid_op_d;
   wire [0:`THREADS-1]                ex6_valid_op_q;
   wire [0:`THREADS-1]                ex7_valid_op_d;
   wire [0:`THREADS-1]                ex7_valid_op_q;
   wire [0:`THREADS-1]                ex8_valid_op_d;
   wire [0:`THREADS-1]                ex8_valid_op_q;
   wire [0:`THREADS-1]                ex1_valid;
   wire [0:`THREADS-1]                ex2_valid;
   wire [0:`THREADS-1]                ex3_valid;
   wire [0:`THREADS-1]                ex3_valid_req;
   wire [0:`THREADS-1]                ex4_valid;
   wire [0:`THREADS-1]                ex5_valid;
   wire [0:`THREADS-1]                ex6_valid;
   wire [0:`THREADS-1]                ex7_valid;
   wire [0:`THREADS-1]                ex8_valid;

   wire [0:4]                         arb_pri;
   wire                               eratrw_hole;
   wire                               rel_hole;
   wire                               csync_next;
   wire                               rel_next;
   wire                               epsc_next;
   wire                               eplc_next;
   wire                               snoop_next;
   wire                               eratre_next;
   wire                               eratwe_next;
   wire                               eratsx_next;
   wire [0:19]                        derat_mmucr0[0:`THREADS-1];
   wire [0:`THREADS-1]                derat_mmucr0_gs;
   wire [0:`THREADS-1]                derat_mmucr0_ts;
   wire [0:7]                         derat_eplc_elpid[0:`THREADS-1];
   wire [0:13]                        derat_eplc_epid[0:`THREADS-1];
   wire [0:7]                         derat_epsc_elpid[0:`THREADS-1];
   wire [0:13]                        derat_epsc_epid[0:`THREADS-1];
   wire [0:13]                        derat_pid[0:`THREADS-1];
   reg  [0:7]                         ex3_eplc_elpid;
   reg  [0:7]                         ex3_epsc_elpid;
   wire [0:`THREADS-1]                spr_msr_hv_d;
   wire [0:`THREADS-1]                spr_msr_hv_q;
   wire [0:`THREADS-1]                spr_msr_pr_d;
   wire [0:`THREADS-1]                spr_msr_pr_q;
   wire [0:`THREADS-1]                spr_msr_ds_d;
   wire [0:`THREADS-1]                spr_msr_ds_q;
   wire [0:`THREADS-1]                spr_msr_cm_d;
   wire [0:`THREADS-1]                spr_msr_cm_q;
   wire                               spr_ccr2_notlb_d;
   wire                               spr_ccr2_notlb_q;
   wire                               xucr4_mmu_mchk_q;
   wire [0:3]                         mchk_flash_inv_d;
   wire [0:3]                         mchk_flash_inv_q;
   wire                               mchk_flash_inv_enab;
   wire [0:`THREADS-1]                cp_next_val_d;
   wire [0:`THREADS-1]                cp_next_val_q;
   wire [0:`ITAG_SIZE_ENC-1]          cp_next_itag_q[0:`THREADS-1];
   wire                               ex4_eratm_val;
   wire [0:`EMQ_ENTRIES-1]            ex4_entry_wrt_val;
   wire                               eratm_por_reset;
   wire                               ex3_oldest_itag;
   wire                               ex4_oldest_itag_d;
   wire                               ex4_oldest_itag_q;
   wire                               ex3_eratm_chk_val;
   wire                               ex3_eratm_epn_m;
   wire [0:`EMQ_ENTRIES-1]            ex3_eratm_epn_hit;
   wire [0:`EMQ_ENTRIES-1]            ex3_eratm_epn_hit_restart;
   wire [0:`EMQ_ENTRIES-1]            ex2_eratm_itag_hit;
   wire [0:`EMQ_ENTRIES-1]            ex3_eratm_itag_hit;
   wire [0:`EMQ_ENTRIES-1]            ex3_eratm_itag_hit_d;
   wire [0:`EMQ_ENTRIES-1]            ex3_eratm_itag_hit_q;
   wire [0:`EMQ_ENTRIES-1]            ex3_eratm_itag_hit_restart;
   wire [0:`EMQ_ENTRIES-1]            ex3_eratm_itag_hit_setHold;
   wire [0:`EMQ_ENTRIES-1]            ex3_eratm_hit_restart;
   wire [0:`EMQ_ENTRIES-1]            ex3_eratm_hit_setHold;
   wire [0:`EMQ_ENTRIES-1]            ex3_eratm_hit_report;
   wire                               ex3_eratm_full;
   wire [0:`EMQ_ENTRIES-1]            ex3_emq_tlbmiss;
   wire [0:`EMQ_ENTRIES-1]            ex3_emq_tlbinelig;
   wire [0:`EMQ_ENTRIES-1]            ex3_emq_ptfault;
   wire [0:`EMQ_ENTRIES-1]            ex3_emq_lratmiss;
   wire [0:`EMQ_ENTRIES-1]            ex3_emq_multihit;
   wire [0:`EMQ_ENTRIES-1]            ex3_emq_tlb_par;
   wire [0:`EMQ_ENTRIES-1]            ex3_emq_lru_par;
   wire [0:`EMQ_ENTRIES-1]            ex4_emq_excp_rpt_d;
   wire [0:`EMQ_ENTRIES-1]            ex4_emq_excp_rpt_q;
   wire [0:`EMQ_ENTRIES-1]            ex5_emq_excp_rpt_d;
   wire [0:`EMQ_ENTRIES-1]            ex5_emq_excp_rpt_q;
   wire [0:`EMQ_ENTRIES-1]            ex6_emq_excp_rpt_d;
   wire [0:`EMQ_ENTRIES-1]            ex6_emq_excp_rpt_q;
   wire [0:`THREADS-1]                ex5_tlb_excp_val_d;
   wire [0:`THREADS-1]                ex5_tlb_excp_val_q;
   wire [0:`THREADS-1]                ex6_tlb_excp_val_d;
   wire [0:`THREADS-1]                ex6_tlb_excp_val_q;
   wire                               ex6_tlb_cplt_val;
   wire [0:`EMQ_ENTRIES-1]            ex6_emq_excp_rpt;
   wire                               ex3_tlbmiss;
   wire                               ex4_tlbmiss_d;
   wire                               ex4_tlbmiss_q;
   wire                               ex3_tlbinelig;
   wire                               ex4_tlbinelig_d;
   wire                               ex4_tlbinelig_q;
   wire                               ex3_ptfault;
   wire                               ex4_ptfault_d;
   wire                               ex4_ptfault_q;
   wire                               ex3_lratmiss;
   wire                               ex4_lratmiss_d;
   wire                               ex4_lratmiss_q;
   wire                               ex3_tlb_multihit;
   wire                               ex4_tlb_multihit_d;
   wire                               ex4_tlb_multihit_q;
   wire                               ex3_tlb_par_err;
   wire                               ex4_tlb_par_err_d;
   wire                               ex4_tlb_par_err_q;
   wire                               ex3_lru_par_err;
   wire                               ex4_lru_par_err_d;
   wire                               ex4_lru_par_err_q;
   wire                               ex4_tlb_excp_det_d;
   wire                               ex4_tlb_excp_det_q;
   wire [0:`THREADS-1]                ex3_cp_next_tid;
   reg  [0:`THREADS-1]                emq_tid_idle;
   wire                               ex3_nonspec_val;
   wire                               ex4_nonspec_val_d;
   wire                               ex4_nonspec_val_q;
   wire                               ex4_gate_miss_d;
   wire                               ex4_gate_miss_q;
   wire                               ex4_full_restart;
   wire                               ex4_full_restart_d;
   wire                               ex4_full_restart_q;
   wire                               ex4_hit_restart;
   wire                               ex4_itag_hit_restart_d;
   wire                               ex4_itag_hit_restart_q;
   wire                               ex4_epn_hit_restart_d;
   wire                               ex4_epn_hit_restart_q;
   wire                               ex4_setHold;
   wire [0:`THREADS-1]                ex4_setHold_tid;
   wire                               ex4_setHold_d;
   wire                               ex4_setHold_q;
   wire [0:`THREADS-1]                derat_dcc_clr_hold_d;
   wire [0:`THREADS-1]                derat_dcc_clr_hold_q;
   wire                               ex4_derat_restart;
   wire                               ex4_tlbreq_val;
   wire                               ex5_tlbreq_val_d;
   wire                               ex5_tlbreq_val_q;
   wire                               ex5_tlbreq_val;
   wire                               ex5_tlbreq_nonspec_d;
   wire                               ex5_tlbreq_nonspec_q;
   wire [0:`THREADS-1]                ex5_thdid_d;
   wire [0:`THREADS-1]                ex5_thdid_q;
   wire [0:`EMQ_ENTRIES-1]            ex5_emq_d;
   wire [0:`EMQ_ENTRIES-1]            ex5_emq_q;
   wire [0:1]                         ex5_tlbreq_ttype_d;
   wire [0:1]                         ex5_tlbreq_ttype_q;
   wire                               ex5_tlbreq_blk;
   wire [0:`EMQ_ENTRIES-1]            ex5_emq_tlbreq_blk;
   wire [0:`THREADS-1]                ex5_perf_dtlb_d, ex5_perf_dtlb_q;
   wire                               ex4_miss_w_tlb;
   wire                               ex4_miss_wo_tlb;
   wire [0:`EMQ_ENTRIES-1]            eratm_tlb_rel_val;
   wire [0:`EMQ_ENTRIES-1]            eratm_wrt_ptr;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_available;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_cpl;
   reg  [0:2]                         eratm_entry_nxt_state[0:`EMQ_ENTRIES-1];
   wire [0:2]                         eratm_entry_state_d[0:`EMQ_ENTRIES-1];
   wire [0:2]                         eratm_entry_state_q[0:`EMQ_ENTRIES-1];
   wire [0:`ITAG_SIZE_ENC-1]          eratm_entry_itag_d[0:`EMQ_ENTRIES-1];
   wire [0:`ITAG_SIZE_ENC-1]          eratm_entry_itag_q[0:`EMQ_ENTRIES-1];
   wire [0:`THREADS-1]                eratm_entry_tid_d[0:`EMQ_ENTRIES-1];
   wire [0:`THREADS-1]                eratm_entry_tid_q[0:`EMQ_ENTRIES-1];
   wire [0:`THREADS-1]                eratm_entry_tid_inuse[0:`EMQ_ENTRIES-1];
   wire [64-(2**`GPR_WIDTH_ENC):51]   eratm_entry_epn_d[0:`EMQ_ENTRIES-1];
   wire [64-(2**`GPR_WIDTH_ENC):51]   eratm_entry_epn_q[0:`EMQ_ENTRIES-1];
   reg  [0:`EMQ_ENTRIES-1]            eratm_entry_nonspec_val_d;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_nonspec_val_q;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_mkill;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_mkill_d;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_mkill_q;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_kill;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_inuse;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_relPend;
   reg  [0:`EMQ_ENTRIES-1]            eratm_entry_clr_hold;
   wire                               eratm_clrHold;
   wire [0:`THREADS-1]                eratm_clrHold_tid;
   wire [0:1]                         eratm_setHold_tid_ctrl[0:`THREADS-1];
   wire [0:`THREADS-1]                eratm_hold_tid_d;
   wire [0:`THREADS-1]                eratm_hold_tid_q;
   wire [0:`ITAG_SIZE_ENC-1]          mm_int_rpt_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]          mm_int_rpt_itag_q;
   wire                               mm_int_rpt_tlbmiss_d;
   wire                               mm_int_rpt_tlbmiss_q;
   wire                               mm_int_rpt_tlbinelig_d;
   wire                               mm_int_rpt_tlbinelig_q;
   wire                               mm_int_rpt_ptfault_d;
   wire                               mm_int_rpt_ptfault_q;
   wire                               mm_int_rpt_lratmiss_d;
   wire                               mm_int_rpt_lratmiss_q;
   wire                               mm_int_rpt_tlb_multihit_d;
   wire                               mm_int_rpt_tlb_multihit_q;
   wire                               mm_int_rpt_tlb_par_err_d;
   wire                               mm_int_rpt_tlb_par_err_q;
   wire                               mm_int_rpt_lru_par_err_d;
   wire                               mm_int_rpt_lru_par_err_q;
   wire [0:`EMQ_ENTRIES-1]            mm_int_rpt_tlbmiss_val;
   wire [0:`EMQ_ENTRIES-1]            mm_int_rpt_tlbinelig_val;
   wire [0:`EMQ_ENTRIES-1]            mm_int_rpt_ptfault_val;
   wire [0:`EMQ_ENTRIES-1]            mm_int_rpt_lratmiss_val;
   wire [0:`EMQ_ENTRIES-1]            mm_int_rpt_tlb_multihit_val;
   wire [0:`EMQ_ENTRIES-1]            mm_int_rpt_tlb_par_err_val;
   wire [0:`EMQ_ENTRIES-1]            mm_int_rpt_lru_par_err_val;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_tlbmiss_d;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_tlbmiss_q;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_tlbinelig_d;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_tlbinelig_q;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_ptfault_d;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_ptfault_q;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_lratmiss_d;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_lratmiss_q;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_tlb_multihit_d;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_tlb_multihit_q;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_tlb_par_err_d;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_tlb_par_err_q;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_lru_par_err_d;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_lru_par_err_q;
   wire [0:`EMQ_ENTRIES-1]            eratm_entry_int_det;
   wire [0:4]                         rw_entry_d;
   wire [0:4]                         rw_entry_q;
   wire                               rw_entry_val_d;
   wire                               rw_entry_val_q;
   wire                               rw_entry_le_d;
   wire                               rw_entry_le_q;
   wire [0:31]                        cam_entry_le_wr;
   wire [0:31]                        cam_entry_le;
   wire [0:31]                        cam_entry_le_d;
   wire [0:31]                        cam_entry_le_q;
   wire [0:31]                        ex3_cam_byte_rev;
   wire [0:31]                        ex3_cam_entry_le;
   wire                               ex3_cam_hit_le;
   wire [0:`THREADS-1]                ex3_strg_noop;
   wire                               lq_xu_ord_write_done_d;
   wire                               lq_xu_ord_write_done_q;
   wire                               lq_xu_ord_read_done_d;
   wire                               lq_xu_ord_read_done_q;
   wire                               xu_lq_act_d;
   wire                               xu_lq_act_q;
   wire [0:`THREADS-1]                xu_lq_val_d;
   wire [0:`THREADS-1]                xu_lq_val_q;
   wire                               xu_lq_is_eratre_d;
   wire                               xu_lq_is_eratre_q;
   wire                               xu_lq_is_eratwe_d;
   wire                               xu_lq_is_eratwe_q;
   wire                               xu_lq_is_eratsx_d;
   wire                               xu_lq_is_eratsx_q;
   wire                               xu_lq_is_eratilx_d;
   wire                               xu_lq_is_eratilx_q;
   wire [0:1]                         xu_lq_ws_d;
   wire [0:1]                         xu_lq_ws_q;
   wire [0:4]                         xu_lq_ra_entry_d;
   wire [0:4]                         xu_lq_ra_entry_q;
   wire [64-(2**`GPR_WIDTH_ENC):63]    xu_lq_rs_data_d;
   wire [64-(2**`GPR_WIDTH_ENC):63]    xu_lq_rs_data_q;
   wire                               csinv_complete;
   wire [0:scan_right_0]              siv_0;
   wire [0:scan_right_0]              sov_0;
   wire [0:scan_right_1]              siv_1;
   wire [0:scan_right_1]              sov_1;
   wire [0:boot_scan_right]           bsiv;
   wire [0:boot_scan_right]           bsov;
   // cam component scan chains
   wire                               func_si_cam_int;
   wire                               func_so_cam_int;
   //signal tidn                        : std_ulogic;
   wire                               tiup;
   //begin
   //@@ START OF EXECUTABLE CODE FOR LQ_DERAT

   //## figtree_source: lq_derat.fig;
   //---------------------------------------------------------------------
   // ACT Generation
   //---------------------------------------------------------------------
   assign clkg_ctl_override_d = spr_xucr0_clkg_ctl_b1;
   assign ex1_stg_act_d       = ((|(dec_derat_ex0_val)) | clkg_ctl_override_q | (|(ex0_ttype_val_q)));
   assign ex2_stg_act_d       = ((dec_derat_ex1_derat_act | dec_derat_ex1_ra_eq_ea | clkg_ctl_override_q) | (|(ex1_valid_op_q)) | |(dec_derat_ex1_pfetch_val));
   assign ex3_stg_act_d       = ex2_stg_act_q;
   assign ex4_stg_act_d       = ex3_stg_act_q;
   assign ex5_stg_act_d       = ex4_stg_act_q;
   assign ex6_stg_act_d       = ex5_stg_act_q;
   assign ex3_cmp_data_act    = ex3_stg_act_q & (~(an_ac_grffence_en_dc_q));
   assign ex3_rd_data_act     = ex3_stg_act_q & (~(an_ac_grffence_en_dc_q));
   assign entry_valid_act     = (~an_ac_grffence_en_dc_q);
   assign entry_match_act     = (~an_ac_grffence_en_dc_q);
   assign mchk_flash_inv_act  = (~an_ac_grffence_en_dc_q);
   assign tlb_rel_act_d       = mm_derat_rel_data[eratpos_relsoon];
   assign tlb_rel_act         = (tlb_rel_act_q & (~(spr_ccr2_notlb_q))) | clkg_ctl_override_q;
   assign snoopp_act          = snoopp_act_q | clkg_ctl_override_q;
   assign snoop_act           = snoop_next | ex1_snoop_val_q | clkg_ctl_override_q;
   assign cp_flush_d          = iu_lq_cp_flush;
   //---------------------------------------------------------------------
   // SPR
   //---------------------------------------------------------------------
   assign spr_msr_hv_d        = xu_lq_spr_msr_hv;
   assign spr_msr_pr_d        = xu_lq_spr_msr_pr;
   assign spr_msr_ds_d        = xu_lq_spr_msr_ds;
   assign spr_msr_cm_d        = xu_lq_spr_msr_cm;
   assign spr_ccr2_notlb_d    = xu_lq_spr_ccr2_notlb;
   //---------------------------------------------------------------------
   // Inputs from Completion
   //---------------------------------------------------------------------
   assign cp_next_val_d       = iu_lq_recirc_val;
   //---------------------------------------------------------------------
   // ERAT Operation Bus
   //---------------------------------------------------------------------
   assign xu_lq_act_d         = xu_lq_act;
   assign xu_lq_val_d         = xu_lq_val & (~cp_flush_q);
   assign xu_lq_is_eratre_d   = xu_lq_is_eratre;
   assign xu_lq_is_eratwe_d   = xu_lq_is_eratwe;
   assign xu_lq_is_eratsx_d   = xu_lq_is_eratsx;
   assign xu_lq_is_eratilx_d  = xu_lq_is_eratilx;
   assign xu_lq_ws_d          = xu_lq_ws;
   assign xu_lq_ra_entry_d    = xu_lq_ra_entry;
   // RS Data contains the following
   // either RB Data for eratsx or RS Data for eratwe
   assign xu_lq_rs_data_d     = xu_lq_rs_data;
   //---------------------------------------------------------------------
   // Logic
   //---------------------------------------------------------------------
   assign tiup                = 1'b1;
   assign init_alias          = pc_xu_init_reset_q;
   assign mmucr1_d            = mm_lq_mmucr1;
   assign ex2_byte_rev_d      = dec_derat_ex1_byte_rev;
   assign ex3_byte_rev_d      = ex2_byte_rev_q;

   // timing latches for the ifrat delusional paranoia real mode
   assign ccr2_frat_paranoia_d[0:3] = xu_lq_spr_ccr2_dfratsc[0:3];
   assign ccr2_frat_paranoia_d[4]   = xu_lq_spr_ccr2_dfratsc[4];
   assign ccr2_frat_paranoia_d[5:8] = xu_lq_spr_ccr2_dfratsc[5:8];
   assign ccr2_frat_paranoia_d[9]   = xu_lq_spr_ccr2_dfrat;
   assign ccr2_frat_paranoia_d[10]  = dec_derat_ex1_ra_eq_ea;
   assign ccr2_frat_paranoia_d[11]  = ccr2_frat_paranoia_q[10];
   //- latch incoming valid and  data  --------------------------------------------
   // mmucr1: 0-DRRE, 1-REE, 2-CEE,
   //         3-Disable any context sync inst from invalidating extclass=0 erat entries,
   //         4-Disable isync inst from invalidating extclass=0 erat entries,
   //         5:6-PEI, 7:8-DCTID|DTTID, 9-DCCD
   // ttype <= 0-eratre & 1-eratwe & 2-eratsx & 3-eratilx & 4-load & 5-store &
   //          6-csync & 7-isync & 8-icbtlslc & 9-touch & 10-extload & 11-extstore;
   // context synch operation
   assign csync_val_d[0] = iu_lq_csync;
   assign isync_val_d[0] = iu_lq_isync;
   assign csync_val_d[1] = ((csync_val_q[0] == 1'b1 & mmucr1_q[3] == 1'b0 & spr_ccr2_notlb_q == MMU_Mode_Value)) ? 1'b1 :
                           (csync_next == 1'b1) ? 1'b0 :
                           csync_val_q[1];
   assign isync_val_d[1] = ((isync_val_q[0] == 1'b1 & mmucr1_q[4] == 1'b0 & spr_ccr2_notlb_q == MMU_Mode_Value)) ? 1'b1 :
                           (csync_next == 1'b1) ? 1'b0 :
                           isync_val_q[1];
   // tlb reload                                                                   -- one hot val, 4 reloads
   assign rel_val_d  = (|(mm_derat_rel_val) == 1'b1) ? mm_derat_rel_val[0:3] :
                       (rel_next == 1'b1) ? {4{1'b0}} :
                       rel_val_q;
   assign rel_hit_d  = (|(mm_derat_rel_val) == 1'b1) ? mm_derat_rel_val[4] :
                       rel_hit_q;
   assign rel_data_d = (|(mm_derat_rel_val) == 1'b1) ? mm_derat_rel_data :
                       rel_data_q;
   assign rel_emq_d  = (|(mm_derat_rel_val) == 1'b1) ? mm_derat_rel_emq :
                       rel_emq_q;
   // Need to update Interrupt Status for each EMQ when the reload is valid
   assign rel_int_upd_val_d = (mm_derat_rel_emq & {`EMQ_ENTRIES{(|(mm_derat_rel_val))}});
   // write External PID Lo
   assign epsc_wr_val_d  = (|(spr_derat_epsc_wr) == 1'b1) ? spr_derat_epsc_wr :
                           (epsc_next == 1'b1) ? {`THREADS{1'b0}} :
                           epsc_wr_val_q;
   assign eplc_wr_val_d  = (|(spr_derat_eplc_wr) == 1'b1) ? spr_derat_eplc_wr :
                           (eplc_next == 1'b1) ? {`THREADS{1'b0}} :
                           eplc_wr_val_q;
   // D$ snoop
   assign rv1_binv_val_d = lsq_ctl_rv0_binv_val;
   // tlbivax or tlbilx sno
   assign snoopp_val_d  = (mm_lq_snoop_val == 1'b1) ? 1'b1 :
                          (snoop_next == 1'b1) ? 1'b0 :
                          snoopp_val_q;
   assign snoopp_attr_d = (mm_lq_snoop_val == 1'b1) ? mm_lq_snoop_attr :
                          snoopp_attr_q;
   assign snoopp_vpn_d  = (mm_lq_snoop_val == 1'b1) ? mm_lq_snoop_vpn :
                          snoopp_vpn_q;
   // ordered ttype = 0-eratre 1-eratwe 2-eratsx 3-eratilx
   // ttype_val_d, ttype_d,                                                        -- fix (is ilx is not needed) check with Jon
   assign ttype_val_d   = (|(xu_lq_val_q) == 1'b1) ? (xu_lq_val_q & (~cp_flush_q)) :
                          ((eratre_next | eratwe_next | eratsx_next) == 1'b1) ? {`THREADS{1'b0}} :
                          (ttype_val_q & (~cp_flush_q));
   assign ttype_d       = (|(xu_lq_val_q) == 1'b1) ? {xu_lq_is_eratre_q, xu_lq_is_eratwe_q, xu_lq_is_eratsx_q, 1'b0} :
                          ((eratre_next | eratwe_next | eratsx_next) == 1'b1) ? 4'b0000 :
                          ttype_q;
   assign ws_d          = (|(xu_lq_val_q) == 1'b1) ? xu_lq_ws_q :
                          ws_q;
   assign ra_entry_d    = (|(xu_lq_val_q) == 1'b1) ? xu_lq_ra_entry_q :
                          ra_entry_q;
   assign rs_data_d     = (|(xu_lq_val_q) == 1'b1) ? xu_lq_rs_data_q :
                          rs_data_q;
   // generate pipeline hole for non-ld/st ops ------------------------------------
   // eratre op extended hole
   assign eratre_hole_d[3]   = (~(|(eratre_hole_q))) & eratre_next;
   assign eratre_hole_d[2]   = eratre_hole_q[3];
   assign eratre_hole_d[1]   = eratre_hole_q[2];
   assign eratre_hole_d[0]   = eratre_hole_q[1];
   assign eratwe_hole_d[3]   = (~(|(eratwe_hole_q))) & eratwe_next;
   assign eratwe_hole_d[2]   = eratwe_hole_q[3];
   assign eratwe_hole_d[1]   = eratwe_hole_q[2];
   assign eratwe_hole_d[0]   = eratwe_hole_q[1];
   assign eratrw_hole        = |({eratre_hole_q, eratwe_hole_q});

   assign rel_hole        =  tlb_rel_act_q | lru_update_event_q[0] | |(rel_val_q | rv1_rel_val_q | ex0_rel_val_q | ex1_rel_val_q | tlb_rel_val_q[0:3]);

   assign derat_dec_hole_all = |({csync_val_q[1], isync_val_q[1], rel_hole, epsc_wr_val_q, eplc_wr_val_q,
                                  snoopp_val_q, ttype_val_q, eratrw_hole, por_hold_req});

   //- arb Priorities -------------------------------------------------------------
   assign arb_pri[0]         = ~(eratrw_hole);
   assign arb_pri[1]         = ~(csync_val_q[1] | isync_val_q[1] | eratrw_hole);
   assign arb_pri[2]         = ~(csync_val_q[1] | isync_val_q[1] | |(rel_val_q[0:3]) | eratrw_hole);
   assign arb_pri[3]         = ~(csync_val_q[1] | isync_val_q[1] | |(rel_val_q[0:3]) | |(epsc_wr_val_q) | |(eplc_wr_val_q) | eratrw_hole | lsq_ctl_rv0_binv_val);
   assign arb_pri[4]         = ~(csync_val_q[1] | isync_val_q[1] | |(rel_val_q[0:3]) | |(epsc_wr_val_q) | |(eplc_wr_val_q) | snoopp_val_q | lsq_ctl_rv0_binv_val);

   assign csync_next         = (csync_val_q[1] | isync_val_q[1]) & arb_pri[0];
   assign rel_next           = (|(rel_val_q[0:3])) & arb_pri[1];
   assign epsc_next          = (|(epsc_wr_val_q)) & arb_pri[2];
   assign eplc_next          = (|(eplc_wr_val_q)) & arb_pri[2];
   assign snoop_next         = snoopp_val_q & arb_pri[3];
   assign eratre_next        = (|((ttype_val_q) & (~cp_flush_q))) & ttype_q[0] & arb_pri[4];
   assign eratwe_next        = (|((ttype_val_q) & (~cp_flush_q))) & ttype_q[1] & arb_pri[4];
   assign eratsx_next        = (|((ttype_val_q) & (~cp_flush_q))) & ttype_q[2] & arb_pri[4];

   // last priority lsu op (load, store, etc)

   //- pipe valids to the old interface -------------------------------------------
   assign rv1_ttype_val_d    = ((eratre_next | eratwe_next | eratsx_next) == 1'b1) ? (ttype_val_q & (~cp_flush_q)) :
                               {`THREADS{1'b0}};
   assign rv1_ttype_d        = ttype_q;
   assign rv1_csync_val_d    = csync_val_q[1] & csync_next;
   assign rv1_isync_val_d    = isync_val_q[1] & csync_next;
   assign rv1_rel_val_d      = (rel_next == 1'b1) ? rel_val_q :
                               {4{1'b0}};
   assign rv1_epsc_wr_val_d  = (epsc_next == 1'b1) ? epsc_wr_val_q :
                               {`THREADS{1'b0}};
   assign rv1_eplc_wr_val_d  = (eplc_next == 1'b1) ? eplc_wr_val_q :
                               {`THREADS{1'b0}};
   assign rv1_snoop_val_d    = snoop_next;
   assign ex0_ttype_val_d    = rv1_ttype_val_q & (~cp_flush_q);
   assign ex0_ttype_d        = rv1_ttype_q;
   assign ex0_isync_val_d    = rv1_isync_val_q;
   assign ex0_csync_val_d    = rv1_csync_val_q;
   assign ex0_rel_val_d      = rv1_rel_val_q;
   assign ex0_epsc_wr_val_d  = rv1_epsc_wr_val_q;
   assign ex0_eplc_wr_val_d  = rv1_eplc_wr_val_q;
   assign ex0_snoop_val_d    = rv1_snoop_val_q;
   assign ex0_binv_val_d     = rv1_binv_val_q;
   assign ex1_binv_val_d     = ex0_binv_val_q;
   assign ex1_rel_val_d      = ex0_rel_val_q;
   assign ex1_snoop_val_d    = ex0_snoop_val_q;
   assign ex1_ttype03_d      = (ex0_ttype_q & {4{(|(ex0_ttype_val_q))}});
   assign ex1_ttype67_d      = {ex0_csync_val_q, ex0_isync_val_q};

   // old logic -------------------------------------------------------------------
   // reloads
   assign tlb_rel_val_d      = {ex1_rel_val_q, (rel_hit_q & (|(ex1_rel_val_q)))};
   assign tlb_rel_data_d     = rel_data_q;
   assign tlb_rel_emq_d      = rel_emq_q;
   // ex0 -------------------------------------------------------------------------
   // Need to separate ex0_csync_val and ex0_isync_val because they should not be blocked by byp_derat_ex2_req_aborted
   assign ex1_valid_d        = (dec_derat_ex0_val & (~cp_flush_q));
   assign ex1_ttype_d        = (({dec_derat_ex0_is_extload, dec_derat_ex0_is_extstore}) & {2{(|(dec_derat_ex0_val))}});
   assign ex1_valid_op_d     = ex0_ttype_val_q & (~cp_flush_q);
   // ex1 -------------------------------------------------------------------------
   assign ex1_valid          = ((ex1_valid_q | ex1_valid_op_q) & (~cp_flush_q)) | dec_derat_ex1_pfetch_val;
   assign ex1_is_icbtlslc    = dec_derat_ex1_icbtls_instr | dec_derat_ex1_icblc_instr;
   assign ex1_eplc_epr       = |(spr_derat_eplc_epr & ex1_valid);
   assign ex1_eplc_egs       = |(spr_derat_eplc_egs & ex1_valid);
   assign ex1_eplc_eas       = |(spr_derat_eplc_eas & ex1_valid);
   assign ex1_epsc_epr       = |(spr_derat_epsc_epr & ex1_valid);
   assign ex1_epsc_egs       = |(spr_derat_epsc_egs & ex1_valid);
   assign ex1_epsc_eas       = |(spr_derat_epsc_eas & ex1_valid);
   assign ex1_mmucr0_gs      = |(derat_mmucr0_gs & ex1_valid);
   assign ex1_mmucr0_ts      = |(derat_mmucr0_ts & ex1_valid);
   // ttype <= 0-eratre 1-eratwe 2-eratsx   3-eratilx  4-load      5-store
   //          6-csync  7-isync  8-icbtlslc 9-touch   10-extload 11-extstore
   assign ex2_valid_d        = ex1_valid_q & (~cp_flush_q);
   assign ex2_itag_d         = dec_derat_ex1_itag;
   assign ex2_pfetch_val_d   = dec_derat_ex1_pfetch_val;
   assign ex2_valid_op_d     = ex1_valid_op_q & (~cp_flush_q);
   assign ex2_valid          = (((ex2_valid_q & {`THREADS{~byp_derat_ex2_req_aborted}}) | ex2_valid_op_q) & (~cp_flush_q)) | ex2_pfetch_val_q;
   assign ex2_ttype_d        = {ex1_ttype03_q,
                               (({dec_derat_ex1_is_load, dec_derat_ex1_is_store}) & {2{(~(|(ex1_ttype03_q)))}}),
                               ex1_ttype67_q,
                               (({ex1_is_icbtlslc, dec_derat_ex1_is_touch, ex1_ttype_q[10], ex1_ttype_q[11]}) & {4{(~(|(ex1_ttype03_q)))}})};

   assign ex2_ws_d           = ws_q;
   assign ex2_rs_is_d        = {rs_is_width{1'b0}};
   assign ex2_ra_entry_d     = ra_entry_q;
   assign csinv_complete     = |(ex2_ttype_q[6:7]);

   generate
      begin : sprThrd
         genvar tid;
         for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
         begin : sprThrd
            assign derat_mmucr0[tid]     = mm_lq_mmucr0[tid*20:(tid*20)+20-1];
            assign derat_mmucr0_gs[tid]  = mm_lq_mmucr0[(tid*20)+2];
            assign derat_mmucr0_ts[tid]  = mm_lq_mmucr0[(tid*20)+3];
            assign derat_eplc_elpid[tid] = spr_derat_eplc_elpid[8 * tid:(8 * tid) + 7];
            assign derat_eplc_epid[tid]  = spr_derat_eplc_epid[14 * tid:(14 * tid) + 13];
            assign derat_epsc_elpid[tid] = spr_derat_epsc_elpid[8 * tid:(8 * tid) + 7];
            assign derat_epsc_epid[tid]  = spr_derat_epsc_epid[14 * tid:(14 * tid) + 13];
            assign derat_pid[tid]        = mm_lq_pid[tid*14:(tid*14)+14-1];
         end
      end
   endgenerate

   //always @(derat_eplc_epid or derat_epsc_epid or derat_mmucr0 or derat_pid or derat_eplc_elpid or derat_epsc_elpid or ex3_ttype_q[10:11] or rpn_holdreg_q or ex1_valid or ex2_valid or ex3_valid_req)
   always @(*)
   begin: tidSpr
      reg [0:13] eplc_epid;
      reg [0:13] epsc_epid;
      reg [0:13] mmucr0_pid;
      reg [0:13] pid;
      reg [0:7]  eplc_elpid;
      reg [0:7]  epsc_elpid;
      reg [0:1]  extclass;
      reg [0:1]  tlbsel;
      reg [0:63] rpnHold;
      (* analysis_not_referenced="true" *)
      integer    tid;

      eplc_epid  = {14{1'b0}};
      epsc_epid  = {14{1'b0}};
      mmucr0_pid = {14{1'b0}};
      pid        = {14{1'b0}};
      eplc_elpid = {8{1'b0}};
      epsc_elpid = {8{1'b0}};
      extclass   = {2{1'b0}};
      tlbsel     = {2{1'b0}};
      rpnHold    = {64{1'b0}};

      for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
      begin
         eplc_epid  = (derat_eplc_epid[tid] & {14{ex1_valid[tid]}}) | eplc_epid;
         epsc_epid  = (derat_epsc_epid[tid] & {14{ex1_valid[tid]}}) | epsc_epid;
         mmucr0_pid = (derat_mmucr0[tid][6:19] & {14{ex1_valid[tid]}}) | mmucr0_pid;
         pid        = (derat_pid[tid] &  {14{ex1_valid[tid]}}) | pid;
         eplc_elpid = (derat_eplc_elpid[tid] & {8{(ex3_valid_req[tid] & ex3_ttype_q[10])}}) | eplc_elpid;
         epsc_elpid = (derat_epsc_elpid[tid] & {8{(ex3_valid_req[tid] & ex3_ttype_q[11])}}) | epsc_elpid;
         extclass   = (derat_mmucr0[tid][0:1] & {2{ex1_valid[tid]}}) | extclass;
         tlbsel     = (derat_mmucr0[tid][4:5] & {2{ex1_valid[tid]}}) | tlbsel;
         rpnHold    = (rpn_holdreg_q[tid] &  {64{ex2_valid[tid]}}) | rpnHold;
      end
      ex1_eplc_epid   <= eplc_epid;
      ex1_epsc_epid   <= epsc_epid;
      ex1_mmucr0_pid  <= mmucr0_pid;
      ex1_pid         <= pid;
      ex3_eplc_elpid  <= eplc_elpid;
      ex3_epsc_elpid  <= epsc_elpid;
      ex2_extclass_d  <= extclass;
      ex2_tlbsel_d    <= tlbsel;
      ex2_rpn_holdreg <= rpnHold;
   end
   assign ex2_state_d[0] = (ex1_ttype_q[10] == 1'b1) ? ex1_eplc_epr :
                           (ex1_ttype_q[11] == 1'b1) ? ex1_epsc_epr :
                           |(spr_msr_pr_q & ex1_valid);
   assign ex2_state_d[1] = (ex1_ttype_q[10] == 1'b1) ? ex1_eplc_egs :
                           (ex1_ttype_q[11] == 1'b1) ? ex1_epsc_egs :
                           ((ex1_ttype03_q[1] == 1'b1 | ex1_ttype03_q[2] == 1'b1)) ? ex1_mmucr0_gs :
                           |(spr_msr_hv_q & ex1_valid);
   assign ex2_state_d[2] = (ex1_ttype_q[10] == 1'b1) ? ex1_eplc_eas :
                           (ex1_ttype_q[11] == 1'b1) ? ex1_epsc_eas :
                           ((ex1_ttype03_q[1] == 1'b1 | ex1_ttype03_q[2] == 1'b1)) ? ex1_mmucr0_ts :
                           |(spr_msr_ds_q & ex1_valid);
   assign ex2_state_d[3] = |(spr_msr_cm_q & ex1_valid);
   assign ex2_pid_d      = (ex1_ttype_q[10] == 1'b1) ? ex1_eplc_epid :
                           (ex1_ttype_q[11] == 1'b1) ? ex1_epsc_epid :
                           ((ex1_ttype03_q[1] == 1'b1 | ex1_ttype03_q[2] == 1'b1)) ? ex1_mmucr0_pid :
                           ex1_pid;
   assign ex2_data_in_d  = rs_data_q;
   // ex2 -------------------------------------------------------------------------
   assign ex2_deratre      = (|(ex2_valid_op_q)) & ex2_ttype_q[0] & ex2_tlbsel_q[0] & ex2_tlbsel_q[1];
   assign ex2_deratwe      = (|(ex2_valid_op_q)) & ex2_ttype_q[1] & ex2_tlbsel_q[0] & ex2_tlbsel_q[1];
   assign ex2_deratsx      = (|(ex2_valid_op_q)) & ex2_ttype_q[2] & ex2_tlbsel_q[0] & ex2_tlbsel_q[1];
   assign ex3_valid_d      = (ex2_valid_q & {`THREADS{~byp_derat_ex2_req_aborted}}) & ~cp_flush_q;
   assign ex3_itag_d       = ex2_itag_q;
   assign ex3_pfetch_val_d = ex2_pfetch_val_q;
   assign ex3_valid_op_d   = ex2_valid_op_q & (~cp_flush_q);
   assign ex3_strg_noop    = {`THREADS{dcc_derat_ex3_strg_noop}};
   assign ex3_valid        = (((ex3_valid_q & (~ex3_strg_noop)) | ex3_valid_op_q) & (~(cp_flush_q))) | ex3_pfetch_val_q;
   assign ex3_valid_req    = ex3_valid_q | ex3_valid_op_q | ex3_pfetch_val_q;
   assign ex3_ttype_d      = ex2_ttype_q;
   assign ex3_ws_d         = ex2_ws_q;
   assign ex3_rs_is_d      = ex2_rs_is_d;
   assign ex3_ra_entry_d   = ex2_ra_entry_d;
   assign ex3_state_d      = ex2_state_q;
   assign ex3_extclass_d   = ex2_extclass_q;
   assign ex3_tlbsel_d     = ex2_tlbsel_q;
   assign ex3_pid_d        = ex2_pid_q;
   // ex3 -------------------------------------------------------------------------
   assign ex4_valid_d      = ex3_valid_q & (~(cp_flush_q | ex3_strg_noop));
   assign ex4_itag_d       = ex3_itag_q;
   assign ex4_pfetch_val_d = ex3_pfetch_val_q;
   assign ex4_valid_op_d   = ex3_valid_op_q & (~cp_flush_q);
   assign ex4_ttype_d      = ex3_ttype_q;
   assign ex4_ws_d         = ex3_ws_q;
   assign ex4_rs_is_d      = ex3_rs_is_q;
   assign ex4_ra_entry_d   = ex3_ra_entry_q;
   // state: 0:pr 1:gs 2:ds 3:cm
   assign ex4_state_d      = ex3_state_q;
   assign ex4_extclass_d   = ex3_extclass_q;
   assign ex4_tlbsel_d     = ex3_tlbsel_q;
   assign ex4_pid_d        = ex3_pid_q;
   assign ex4_lpid_d[0:lpid_width - 1] = ex3_eplc_elpid | ex3_epsc_elpid;
   // ex4 -------------------------------------------------------------------------
   // ttype <= 0-eratre 1-eratwe 2-eratsx   3-eratilx  4-load      5-store
   //          6-csync  7-isync  8-icbtlslc 9-touch   10-extload 11-extstore
   assign ex4_valid        = ((ex4_valid_q | ex4_valid_op_q) & (~cp_flush_q)) | ex4_pfetch_val_q;
   assign ex4_deratwe      = (|(ex4_valid)) & ex4_ttype_q[1] & ex4_tlbsel_q[0] & ex4_tlbsel_q[1];
   assign ex4_rd_array_data_d = rd_array_data;
   assign ex4_rd_cam_data_d = rd_cam_data;
   assign ex5_valid_d      = ex4_valid_q & (~(cp_flush_q)) & (~(ex4_miss_q));
   assign ex5_itag_d       = ex4_itag_q;
   assign ex5_pfetch_val_d = ex4_pfetch_val_q;
   assign ex5_valid_op_d   = ex4_valid_op_q & (~cp_flush_q);
   assign ex5_ttype_d      = ex4_ttype_q;
   assign ex5_ws_d         = ex4_ws_q;
   assign ex5_rs_is_d      = ex4_rs_is_q;
   // ra_entry becomes hit_entry for search, inval, load, or store
   assign ex5_ra_entry_d   = (ex4_ttype_q[2:5] != 4'b0000) ? ex4_first_hit_entry :
                             ex4_ra_entry_q;
   assign ex5_tlbsel_d     = ex4_tlbsel_q;
   // muxes for tlbre and sending mmucr0 ExtClass,State,TID
   assign ex5_extclass_d   = ((|(ex4_valid) == 1'b1 & ex4_ttype_q[0] == 1'b1 & ex4_ws_q == 2'b00)) ? ex4_rd_cam_data_q[63:64] :
                              ex4_extclass_q;
   assign ex5_state_d      = ((|(ex4_valid) == 1'b1 & ex4_ttype_q[0] == 1'b1 & ex4_ws_q == 2'b00)) ? {ex4_state_q[0], ex4_rd_cam_data_q[65:66], ex4_state_q[3]} :
                             ex4_state_q;
   assign ex5_pid_d        = ((|(ex4_valid) == 1'b1 & ex4_ttype_q[0] == 1'b1 & ex4_ws_q == 2'b00)) ? {ex4_rd_cam_data_q[61:62], ex4_rd_cam_data_q[57:60], ex4_rd_cam_data_q[67:74]} :
                             ex4_pid_q;
   assign ex5_lpid_d       = ex4_lpid_q;
   // ex5 -------------------------------------------------------------------------
   assign ex5_valid        = ((ex5_valid_q | ex5_valid_op_q) & (~cp_flush_q)) | ex5_pfetch_val_q;
   assign ex5_deratwe      = (|(ex5_valid)) & ex5_ttype_q[1] & ex5_tlbsel_q[0] & ex5_tlbsel_q[1];
   assign ex6_valid_d      = ex5_valid_q & (~(cp_flush_q));
   assign ex6_itag_d       = ex5_itag_q;
   assign ex6_valid_op_d   = ex5_valid_op_q & (~cp_flush_q);
   assign ex6_pfetch_val_d = ex5_pfetch_val_q;
   assign ex6_ws_d         = ex5_ws_q;
   assign ex6_rs_is_d      = ex5_rs_is_q;
   assign ex6_ra_entry_d   = ex5_ra_entry_q;
   assign ex6_ttype_d      = ex5_ttype_q;
   assign ex6_extclass_d   = ex5_extclass_q;
   // state: 0:pr 1:gs 2:ds 3:cm
   assign ex6_state_d      = ex5_state_q;
   assign ex6_pid_d        = ex5_pid_q;
   assign ex6_tlbsel_d     = ex5_tlbsel_q;
   // ex6 -------------------------------------------------------------------------
   assign ex6_valid        = ((ex6_valid_q | ex6_valid_op_q) & (~cp_flush_q)) | ex6_pfetch_val_q;
   assign ex6_deratwe      = (|(ex6_valid)) & ex6_ttype_q[1] & ex6_tlbsel_q[0] & ex6_tlbsel_q[1];
   assign ex7_valid_d      = ex6_valid_q & (~(cp_flush_q));
   assign ex7_valid_op_d   = ex6_valid_op_q & (~cp_flush_q);
   assign ex7_pfetch_val_d = ex6_pfetch_val_q;
   assign ex7_ws_d         = ex6_ws_q;
   assign ex7_rs_is_d      = ex6_rs_is_q;
   assign ex7_ra_entry_d   = ex6_ra_entry_q;
   assign ex7_extclass_d   = ex6_extclass_q;
   assign ex7_tlbsel_d     = ex6_tlbsel_q;
   assign ex7_pid_d        = ex6_pid_q;
   assign ex7_state_d      = ex6_state_q;
   assign ex7_ttype_d      = ex6_ttype_q;
   // mmucr1: 0-DRRE, 1-REE, 2-CEE,
   //         3-Disable any context sync inst from invalidating extclass=0 erat entries,
   //         4-Disable isync inst from invalidating extclass=0 erat entries,
   //         5:6-PEI, 7:8-DCTID|DTTID, 9-DCCD
   // ttype <= 0-eratre & 1-eratwe & 2-eratsx & 3-eratilx & 4-load & 5-store &
   //          6-csync & 7-isync & 8-icbtlslc & 9-touch & 10-extload & 11-extstore;
   // ex7 -------------------------------------------------------------------------
   assign ex7_valid        = ((ex7_valid_q | ex7_valid_op_q) & (~cp_flush_q)) | ex7_pfetch_val_q;
   assign ex7_deratwe      = (|(ex7_valid)) & ex7_ttype_q[1] & ex7_tlbsel_q[0] & ex7_tlbsel_q[1];
   // for flushing
   assign ex8_valid_d      = ex7_valid_q;
   assign ex8_valid_op_d   = ex7_valid_op_q & (~cp_flush_q);
   assign ex8_pfetch_val_d = ex7_pfetch_val_q;
   assign ex8_ttype_d      = ex7_ttype_q;
   assign ex8_tlbsel_d     = ex7_tlbsel_q;
   // ex8 -------------------------------------------------------------------------
   assign ex8_valid        = ((ex8_valid_q | ex8_valid_op_q) & (~cp_flush_q)) | ex8_pfetch_val_q;
   assign ex8_deratwe      = (|(ex8_valid)) & ex8_ttype_q[1] & ex8_tlbsel_q[0] & ex8_tlbsel_q[1];
   // formation of ex3 phase multihit complement signal
   //
   // Final Table Listing
   //      *INPUTS*==============================*OUTPUTS*==========*
   //      |                                     |                  |
   //      | entry_match                         |  ex3_multihit_b  |
   //      | |                                   |  |               |
   //      | |                                   |  |               |
   //      | |                                   |  |               |
   //      | |         1111111111222222222233    |  |               |
   //      | 01234567890123456789012345678901    |  |               |
   //      *TYPE*================================+==================+
   //      | PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP    |  P               |
   //      *POLARITY*--------------------------->|  +               |
   //      *PHASE*------------------------------>|  T               |
   //      *OPTIMIZE*--------------------------->|   A                |
   //      *TERMS*===============================+==================+
   //    1 | -0000000000000000000000000000000    |  1               |
   //    2 | 0-000000000000000000000000000000    |  1               |
   //    3 | 00-00000000000000000000000000000    |  1               |
   //    4 | 000-0000000000000000000000000000    |  1               |
   //    5 | 0000-000000000000000000000000000    |  1               |
   //    6 | 00000-00000000000000000000000000    |  1               |
   //    7 | 000000-0000000000000000000000000    |  1               |
   //    8 | 0000000-000000000000000000000000    |  1               |
   //    9 | 00000000-00000000000000000000000    |  1               |
   //   10 | 000000000-0000000000000000000000    |  1               |
   //   11 | 0000000000-000000000000000000000    |  1               |
   //   12 | 00000000000-00000000000000000000    |  1               |
   //   13 | 000000000000-0000000000000000000    |  1               |
   //   14 | 0000000000000-000000000000000000    |  1               |
   //   15 | 00000000000000-00000000000000000    |  1               |
   //   16 | 000000000000000-0000000000000000    |  1               |
   //   17 | 0000000000000000-000000000000000    |  1               |
   //   18 | 00000000000000000-00000000000000    |  1               |
   //   19 | 000000000000000000-0000000000000    |  1               |
   //   20 | 0000000000000000000-000000000000    |  1               |
   //   21 | 00000000000000000000-00000000000    |  1               |
   //   22 | 000000000000000000000-0000000000    |  1               |
   //   23 | 0000000000000000000000-000000000    |  1               |
   //   24 | 00000000000000000000000-00000000    |  1               |
   //   25 | 000000000000000000000000-0000000    |  1               |
   //   26 | 0000000000000000000000000-000000    |  1               |
   //   27 | 00000000000000000000000000-00000    |  1               |
   //   28 | 000000000000000000000000000-0000    |  1               |
   //   29 | 0000000000000000000000000000-000    |  1               |
   //   30 | 00000000000000000000000000000-00    |  1               |
   //   31 | 000000000000000000000000000000-0    |  1               |
   //   32 | 0000000000000000000000000000000-    |  1               |
   //      *========================================================*
   //
   // Table EX3_MULTIHIT_B Signal Assignments for Product Terms
   assign EX3_MULTIHIT_B_PT[1] = (({entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[2] = (({entry_match[0], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[3] = (({entry_match[0], entry_match[1], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[4] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[5] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[6] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[7] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[8] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[9] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[10] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) == 31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[11] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[12] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[13] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[14] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[15] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[16] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[17] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[18] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[19] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[20] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[21] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[22] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[23] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[24] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[25] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[26] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[27] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[28] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[29] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[29], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[30] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[30], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[31] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[31]}) ==  31'b0000000000000000000000000000000);
   assign EX3_MULTIHIT_B_PT[32] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30]}) ==  31'b0000000000000000000000000000000);
   // Table EX3_MULTIHIT_B Signal Assignments for Outputs
   assign ex3_multihit_b = (EX3_MULTIHIT_B_PT[1] | EX3_MULTIHIT_B_PT[2] | EX3_MULTIHIT_B_PT[3] | EX3_MULTIHIT_B_PT[4] | EX3_MULTIHIT_B_PT[5] | EX3_MULTIHIT_B_PT[6] | EX3_MULTIHIT_B_PT[7] | EX3_MULTIHIT_B_PT[8] | EX3_MULTIHIT_B_PT[9] | EX3_MULTIHIT_B_PT[10] | EX3_MULTIHIT_B_PT[11] | EX3_MULTIHIT_B_PT[12] | EX3_MULTIHIT_B_PT[13] | EX3_MULTIHIT_B_PT[14] | EX3_MULTIHIT_B_PT[15] | EX3_MULTIHIT_B_PT[16] | EX3_MULTIHIT_B_PT[17] | EX3_MULTIHIT_B_PT[18] | EX3_MULTIHIT_B_PT[19] | EX3_MULTIHIT_B_PT[20] | EX3_MULTIHIT_B_PT[21] | EX3_MULTIHIT_B_PT[22] | EX3_MULTIHIT_B_PT[23] | EX3_MULTIHIT_B_PT[24] | EX3_MULTIHIT_B_PT[25] | EX3_MULTIHIT_B_PT[26] | EX3_MULTIHIT_B_PT[27] | EX3_MULTIHIT_B_PT[28] | EX3_MULTIHIT_B_PT[29] | EX3_MULTIHIT_B_PT[30] | EX3_MULTIHIT_B_PT[31] | EX3_MULTIHIT_B_PT[32]);

   assign ex3_multihit = (~ex3_multihit_b);
   assign ex4_multihit_b_pt_d = EX3_MULTIHIT_B_PT;
   assign ex4_multihit_enab = (~(|(ex4_multihit_b_pt_q)));
   // Encoder for the ex3 phase first hit entry number
   //
   // Final Table Listing
   //      *INPUTS*==============================*OUTPUTS*==============*
   //      |                                     |                      |
   //      | entry_match                         |  ex3_first_hit_entry |
   //      | |                                   |  |                   |
   //      | |                                   |  |                   |
   //      | |                                   |  |                   |
   //      | |         1111111111222222222233    |  |                   |
   //      | 01234567890123456789012345678901    |  01234               |
   //      *TYPE*================================+======================+
   //      | PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP    |  PPPPP               |
   //      *POLARITY*--------------------------->|  +++++               |
   //      *PHASE*------------------------------>|  TTTTT               |
   //      *OPTIMIZE*--------------------------->|   AAAAA                |
   //      *TERMS*===============================+======================+
   //    1 | 00000000000000000000000000000001    |  11111               |
   //    2 | 0000000000000000000000000000001-    |  1111.               |
   //    3 | 000000000000000000000000000001--    |  111.1               |
   //    4 | 00000000000000000000000000001---    |  111..               |
   //    5 | 0000000000000000000000000001----    |  11.11               |
   //    6 | 000000000000000000000000001-----    |  11.1.               |
   //    7 | 00000000000000000000000001------    |  11..1               |
   //    8 | 0000000000000000000000001-------    |  11...               |
   //    9 | 000000000000000000000001--------    |  1.111               |
   //   10 | 00000000000000000000001---------    |  1.11.               |
   //   11 | 0000000000000000000001----------    |  1.1.1               |
   //   12 | 000000000000000000001-----------    |  1.1..               |
   //   13 | 00000000000000000001------------    |  1..11               |
   //   14 | 0000000000000000001-------------    |  1..1.               |
   //   15 | 000000000000000001--------------    |  1...1               |
   //   16 | 00000000000000001---------------    |  1....               |
   //   17 | 0000000000000001----------------    |  .1111               |
   //   18 | 000000000000001-----------------    |  .111.               |
   //   19 | 00000000000001------------------    |  .11.1               |
   //   20 | 0000000000001-------------------    |  .11..               |
   //   21 | 000000000001--------------------    |  .1.11               |
   //   22 | 00000000001---------------------    |  .1.1.               |
   //   23 | 0000000001----------------------    |  .1..1               |
   //   24 | 000000001-----------------------    |  .1...               |
   //   25 | 00000001------------------------    |  ..111               |
   //   26 | 0000001-------------------------    |  ..11.               |
   //   27 | 000001--------------------------    |  ..1.1               |
   //   28 | 00001---------------------------    |  ..1..               |
   //   29 | 0001----------------------------    |  ...11               |
   //   30 | 001-----------------------------    |  ...1.               |
   //   31 | 01------------------------------    |  ....1               |
   //      *============================================================*
   //
   // Table EX3_FIRST_HIT_ENTRY Signal Assignments for Product Terms
   assign EX3_FIRST_HIT_ENTRY_PT[1]  = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30], entry_match[31]}) == 32'b00000000000000000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[2]  = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29], entry_match[30]}) == 31'b0000000000000000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[3]  = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28], entry_match[29]}) == 30'b000000000000000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[4]  = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27], entry_match[28]}) == 29'b00000000000000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[5]  = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26], entry_match[27]}) == 28'b0000000000000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[6]  = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25], entry_match[26]}) == 27'b000000000000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[7]  = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24], entry_match[25]}) == 26'b00000000000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[8]  = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23], entry_match[24]}) == 25'b0000000000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[9]  = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22], entry_match[23]}) == 24'b000000000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[10] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21], entry_match[22]}) == 23'b00000000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[11] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20], entry_match[21]}) == 22'b0000000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[12] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19], entry_match[20]}) == 21'b000000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[13] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18], entry_match[19]}) == 20'b00000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[14] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17], entry_match[18]}) == 19'b0000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[15] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16], entry_match[17]}) == 18'b000000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[16] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15], entry_match[16]}) == 17'b00000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[17] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14], entry_match[15]}) == 16'b0000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[18] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13], entry_match[14]}) == 15'b000000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[19] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12], entry_match[13]}) == 14'b00000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[20] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11], entry_match[12]}) == 13'b0000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[21] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10], entry_match[11]}) == 12'b000000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[22] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9], entry_match[10]}) == 11'b00000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[23] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8], entry_match[9]}) == 10'b0000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[24] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7], entry_match[8]}) == 9'b000000001);
   assign EX3_FIRST_HIT_ENTRY_PT[25] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6], entry_match[7]}) == 8'b00000001);
   assign EX3_FIRST_HIT_ENTRY_PT[26] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5], entry_match[6]}) == 7'b0000001);
   assign EX3_FIRST_HIT_ENTRY_PT[27] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4], entry_match[5]}) == 6'b000001);
   assign EX3_FIRST_HIT_ENTRY_PT[28] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3], entry_match[4]}) == 5'b00001);
   assign EX3_FIRST_HIT_ENTRY_PT[29] = (({entry_match[0], entry_match[1], entry_match[2], entry_match[3]}) == 4'b0001);
   assign EX3_FIRST_HIT_ENTRY_PT[30] = (({entry_match[0], entry_match[1], entry_match[2]}) == 3'b001);
   assign EX3_FIRST_HIT_ENTRY_PT[31] = (({entry_match[0], entry_match[1]}) == 2'b01);
   // Table EX3_FIRST_HIT_ENTRY Signal Assignments for Outputs
   assign ex3_first_hit_entry[0] = (EX3_FIRST_HIT_ENTRY_PT[1] | EX3_FIRST_HIT_ENTRY_PT[2] | EX3_FIRST_HIT_ENTRY_PT[3] | EX3_FIRST_HIT_ENTRY_PT[4] | EX3_FIRST_HIT_ENTRY_PT[5] | EX3_FIRST_HIT_ENTRY_PT[6] | EX3_FIRST_HIT_ENTRY_PT[7] | EX3_FIRST_HIT_ENTRY_PT[8] | EX3_FIRST_HIT_ENTRY_PT[9] | EX3_FIRST_HIT_ENTRY_PT[10] | EX3_FIRST_HIT_ENTRY_PT[11] | EX3_FIRST_HIT_ENTRY_PT[12] | EX3_FIRST_HIT_ENTRY_PT[13] | EX3_FIRST_HIT_ENTRY_PT[14] | EX3_FIRST_HIT_ENTRY_PT[15] | EX3_FIRST_HIT_ENTRY_PT[16]);
   assign ex3_first_hit_entry[1] = (EX3_FIRST_HIT_ENTRY_PT[1] | EX3_FIRST_HIT_ENTRY_PT[2] | EX3_FIRST_HIT_ENTRY_PT[3] | EX3_FIRST_HIT_ENTRY_PT[4] | EX3_FIRST_HIT_ENTRY_PT[5] | EX3_FIRST_HIT_ENTRY_PT[6] | EX3_FIRST_HIT_ENTRY_PT[7] | EX3_FIRST_HIT_ENTRY_PT[8] | EX3_FIRST_HIT_ENTRY_PT[17] | EX3_FIRST_HIT_ENTRY_PT[18] | EX3_FIRST_HIT_ENTRY_PT[19] | EX3_FIRST_HIT_ENTRY_PT[20] | EX3_FIRST_HIT_ENTRY_PT[21] | EX3_FIRST_HIT_ENTRY_PT[22] | EX3_FIRST_HIT_ENTRY_PT[23] | EX3_FIRST_HIT_ENTRY_PT[24]);
   assign ex3_first_hit_entry[2] = (EX3_FIRST_HIT_ENTRY_PT[1] | EX3_FIRST_HIT_ENTRY_PT[2] | EX3_FIRST_HIT_ENTRY_PT[3] | EX3_FIRST_HIT_ENTRY_PT[4] | EX3_FIRST_HIT_ENTRY_PT[9] | EX3_FIRST_HIT_ENTRY_PT[10] | EX3_FIRST_HIT_ENTRY_PT[11] | EX3_FIRST_HIT_ENTRY_PT[12] | EX3_FIRST_HIT_ENTRY_PT[17] | EX3_FIRST_HIT_ENTRY_PT[18] | EX3_FIRST_HIT_ENTRY_PT[19] | EX3_FIRST_HIT_ENTRY_PT[20] | EX3_FIRST_HIT_ENTRY_PT[25] | EX3_FIRST_HIT_ENTRY_PT[26] | EX3_FIRST_HIT_ENTRY_PT[27] | EX3_FIRST_HIT_ENTRY_PT[28]);
   assign ex3_first_hit_entry[3] = (EX3_FIRST_HIT_ENTRY_PT[1] | EX3_FIRST_HIT_ENTRY_PT[2] | EX3_FIRST_HIT_ENTRY_PT[5] | EX3_FIRST_HIT_ENTRY_PT[6] | EX3_FIRST_HIT_ENTRY_PT[9] | EX3_FIRST_HIT_ENTRY_PT[10] | EX3_FIRST_HIT_ENTRY_PT[13] | EX3_FIRST_HIT_ENTRY_PT[14] | EX3_FIRST_HIT_ENTRY_PT[17] | EX3_FIRST_HIT_ENTRY_PT[18] | EX3_FIRST_HIT_ENTRY_PT[21] | EX3_FIRST_HIT_ENTRY_PT[22] | EX3_FIRST_HIT_ENTRY_PT[25] | EX3_FIRST_HIT_ENTRY_PT[26] | EX3_FIRST_HIT_ENTRY_PT[29] | EX3_FIRST_HIT_ENTRY_PT[30]);
   assign ex3_first_hit_entry[4] = (EX3_FIRST_HIT_ENTRY_PT[1] | EX3_FIRST_HIT_ENTRY_PT[3] | EX3_FIRST_HIT_ENTRY_PT[5] | EX3_FIRST_HIT_ENTRY_PT[7] | EX3_FIRST_HIT_ENTRY_PT[9] | EX3_FIRST_HIT_ENTRY_PT[11] | EX3_FIRST_HIT_ENTRY_PT[13] | EX3_FIRST_HIT_ENTRY_PT[15] | EX3_FIRST_HIT_ENTRY_PT[17] | EX3_FIRST_HIT_ENTRY_PT[19] | EX3_FIRST_HIT_ENTRY_PT[21] | EX3_FIRST_HIT_ENTRY_PT[23] | EX3_FIRST_HIT_ENTRY_PT[25] | EX3_FIRST_HIT_ENTRY_PT[27] | EX3_FIRST_HIT_ENTRY_PT[29] | EX3_FIRST_HIT_ENTRY_PT[31]);

   assign ex4_first_hit_entry_pt_d = EX3_FIRST_HIT_ENTRY_PT;
   assign ex4_first_hit_entry[0] = (ex4_first_hit_entry_pt_q[1] | ex4_first_hit_entry_pt_q[2] | ex4_first_hit_entry_pt_q[3] | ex4_first_hit_entry_pt_q[4] | ex4_first_hit_entry_pt_q[5] | ex4_first_hit_entry_pt_q[6] | ex4_first_hit_entry_pt_q[7] | ex4_first_hit_entry_pt_q[8] | ex4_first_hit_entry_pt_q[9] | ex4_first_hit_entry_pt_q[10] | ex4_first_hit_entry_pt_q[11] | ex4_first_hit_entry_pt_q[12] | ex4_first_hit_entry_pt_q[13] | ex4_first_hit_entry_pt_q[14] | ex4_first_hit_entry_pt_q[15] | ex4_first_hit_entry_pt_q[16]);
   assign ex4_first_hit_entry[1] = (ex4_first_hit_entry_pt_q[1] | ex4_first_hit_entry_pt_q[2] | ex4_first_hit_entry_pt_q[3] | ex4_first_hit_entry_pt_q[4] | ex4_first_hit_entry_pt_q[5] | ex4_first_hit_entry_pt_q[6] | ex4_first_hit_entry_pt_q[7] | ex4_first_hit_entry_pt_q[8] | ex4_first_hit_entry_pt_q[17] | ex4_first_hit_entry_pt_q[18] | ex4_first_hit_entry_pt_q[19] | ex4_first_hit_entry_pt_q[20] | ex4_first_hit_entry_pt_q[21] | ex4_first_hit_entry_pt_q[22] | ex4_first_hit_entry_pt_q[23] | ex4_first_hit_entry_pt_q[24]);
   assign ex4_first_hit_entry[2] = (ex4_first_hit_entry_pt_q[1] | ex4_first_hit_entry_pt_q[2] | ex4_first_hit_entry_pt_q[3] | ex4_first_hit_entry_pt_q[4] | ex4_first_hit_entry_pt_q[9] | ex4_first_hit_entry_pt_q[10] | ex4_first_hit_entry_pt_q[11] | ex4_first_hit_entry_pt_q[12] | ex4_first_hit_entry_pt_q[17] | ex4_first_hit_entry_pt_q[18] | ex4_first_hit_entry_pt_q[19] | ex4_first_hit_entry_pt_q[20] | ex4_first_hit_entry_pt_q[25] | ex4_first_hit_entry_pt_q[26] | ex4_first_hit_entry_pt_q[27] | ex4_first_hit_entry_pt_q[28]);
   assign ex4_first_hit_entry[3] = (ex4_first_hit_entry_pt_q[1] | ex4_first_hit_entry_pt_q[2] | ex4_first_hit_entry_pt_q[5] | ex4_first_hit_entry_pt_q[6] | ex4_first_hit_entry_pt_q[9] | ex4_first_hit_entry_pt_q[10] | ex4_first_hit_entry_pt_q[13] | ex4_first_hit_entry_pt_q[14] | ex4_first_hit_entry_pt_q[17] | ex4_first_hit_entry_pt_q[18] | ex4_first_hit_entry_pt_q[21] | ex4_first_hit_entry_pt_q[22] | ex4_first_hit_entry_pt_q[25] | ex4_first_hit_entry_pt_q[26] | ex4_first_hit_entry_pt_q[29] | ex4_first_hit_entry_pt_q[30]);
   assign ex4_first_hit_entry[4] = (ex4_first_hit_entry_pt_q[1] | ex4_first_hit_entry_pt_q[3] | ex4_first_hit_entry_pt_q[5] | ex4_first_hit_entry_pt_q[7] | ex4_first_hit_entry_pt_q[9] | ex4_first_hit_entry_pt_q[11] | ex4_first_hit_entry_pt_q[13] | ex4_first_hit_entry_pt_q[15] | ex4_first_hit_entry_pt_q[17] | ex4_first_hit_entry_pt_q[19] | ex4_first_hit_entry_pt_q[21] | ex4_first_hit_entry_pt_q[23] | ex4_first_hit_entry_pt_q[25] | ex4_first_hit_entry_pt_q[27] | ex4_first_hit_entry_pt_q[29] | ex4_first_hit_entry_pt_q[31]);

   // ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore

   assign ex4_miss_d = ((cam_hit == 1'b0 & ex3_ttype_q[4:5] != 2'b00 & ex3_ttype_q[9] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & ccr2_frat_paranoia_q[11] == 1'b0)) ? (ex3_valid) :
                       {`THREADS{1'b0}};
   assign ex4_hit_d = ((cam_hit == 1'b1 & ex3_ttype_q[2:5] != 4'b0000)) ? (|(ex3_valid)) :
                      1'b0;
   assign ex4_eratsx_data = {ex4_multihit_enab, ex4_hit_q, ex4_first_hit_entry};

   //------------------------------------------------------------------------------
   assign tlb_req_inprogress_d = |(eratm_entry_relPend & (~tlb_rel_val_q[0:`EMQ_ENTRIES - 1])) & (~(ccr2_frat_paranoia_q[9] | (|(por_hold_req)) | spr_ccr2_notlb_q));

   //ttype: 0-eratre,   1-eratwe, 2-eratsx,   3-eratilx,
   //       4-load,     5-store,  6-csync,    7-isync,
   //       8-icbtlslc, 9-touch, 10-extload, 11-extstore

   //-- these ex4 versions are for lsu translation sources of parity errors being sent derat -> dcc
   assign ex4_parerr_d[0:`THREADS - 1] = (ex3_valid);

   //assign ex4_parerr_d[`THREADS] = (cam_hit & (ex3_ttype_q[4] | ex3_ttype_q[5]) & (~ex3_ttype_q[9]) & (~ccr2_frat_paranoia_q[9])); // term0, load/store either word
   assign ex4_parerr_d[`THREADS] = (cam_hit & (ex3_ttype_q[4] | ex3_ttype_q[5]) & (~ccr2_frat_paranoia_q[9])); // term0, load/store either word

   assign ex4_parerr_d[`THREADS + 1] = (cam_hit & ex3_ttype_q[2] & ex3_tlbsel_q[0] & ex3_tlbsel_q[1] &
                                           (~(ex4_deratwe | ex5_deratwe | ex6_deratwe | ex7_deratwe | ex8_deratwe)));  // term1,  eratsx epn word (and no eratwe in front of it)

   assign ex4_parerr_enab[0] = (ex4_parerr_q[`THREADS] & ~ex4_multihit_enab & (ex4_cmp_data_parerr_epn | ex4_cmp_data_parerr_rpn));    // load/store
   assign ex4_parerr_enab[1] = (ex4_parerr_q[`THREADS + 1] & ~ex4_multihit_enab & ex4_cmp_data_parerr_epn);    // eratsx

   //  This function is controlled by XUCR4.MMU_MCHK and CCR2.NOTLB  bits.
   assign mchk_flash_inv_d[0] = ex4_parerr_q[`THREADS] & (ex4_cmp_data_parerr_epn | ex4_cmp_data_parerr_rpn);  // parerr on load/store (not touch) and cam hit
   assign mchk_flash_inv_d[1] = ex4_parerr_q[`THREADS] & ex4_multihit_enab;                                   // multihit on load/store (not touch) and cam hit
   assign mchk_flash_inv_d[2] = (mchk_flash_inv_q[0] | mchk_flash_inv_q[1]) & (|(ex5_parerr_q[0:`THREADS - 1] & ~cp_flush_q)); // ex5 phase
   assign mchk_flash_inv_d[3] = mchk_flash_inv_enab;  // ex6 phase, needed since flash in cyc n results in entry_valid=0 in cyc n+2

   assign mchk_flash_inv_enab = mchk_flash_inv_q[2] & (~(spr_ccr2_notlb_q)) & (~(xucr4_mmu_mchk_q));  // ex6 phase, parerr/multihit on load/store and tlb mode and mmu_mchk disabled

   //-- these ex5 versions are for ordered erat op sources of parity errors being sent lq -> xu with ordered done handshake
   assign ex5_parerr_d[0:`THREADS - 1] = ex4_valid;
   assign ex5_parerr_d[`THREADS]     = (ex4_ttype_q[0] & (~ex4_ws_q[0]) & (~ex4_ws_q[1]) & ex4_tlbsel_q[0] & ex4_tlbsel_q[1] &
                                          (~(ex5_deratwe | ex6_deratwe | ex7_deratwe)));  // eratre, epn ws=0 (and no eratwe in front of it)
   assign ex5_parerr_d[`THREADS + 1] = (ex4_ttype_q[0] & (^(ex4_ws_q)) & ex4_tlbsel_q[0] & ex4_tlbsel_q[1] &
                                          (~(ex5_deratwe | ex6_deratwe | ex7_deratwe)));  // eratre, rpn ws=1 or 2 (and no eratwe in front of it)
   assign ex5_parerr_d[`THREADS + 2] = ex4_rd_data_parerr_epn;
   assign ex5_parerr_d[`THREADS + 3] = ex4_rd_data_parerr_rpn;
   assign ex5_parerr_d[`THREADS + 4] = ex4_parerr_enab[1];

   // this is for derat to xu ord op reporting
   assign ex5_parerr_enab = (ex5_parerr_q[`THREADS] & ex5_parerr_q[`THREADS + 2]) |        // eratre
                              (ex5_parerr_q[`THREADS + 1] & ex5_parerr_q[`THREADS + 3]) |    // eratre
                               ex5_parerr_q[`THREADS + 4];                                   // eratsx

   assign lq_xu_ord_par_err = |(ex5_parerr_q[0:`THREADS - 1]) & ex5_parerr_enab;

   //-- these fir versions are catch-all for any source of parity errors
   assign ex5_fir_parerr_d[0:`THREADS - 1] = ex4_valid;
   assign ex5_fir_parerr_d[`THREADS] = (ex4_ttype_q[0] & (~ex4_ws_q[0]) & (~ex4_ws_q[1]) & ex4_tlbsel_q[0] & ex4_tlbsel_q[1] &
                                           (~(ex5_deratwe | ex6_deratwe | ex7_deratwe))); // eratre, epn ws=0
   assign ex5_fir_parerr_d[`THREADS + 1] = (ex4_ttype_q[0] & (^(ex4_ws_q)) & ex4_tlbsel_q[0] & ex4_tlbsel_q[1] &
                                              (~(ex5_deratwe | ex6_deratwe | ex7_deratwe))); // eratre, rpn ws=1 or 2
   assign ex5_fir_parerr_d[`THREADS + 2] = |(ex4_parerr_enab[0:1]);  // load/store, or eratsx

   assign ex5_fir_parerr_enab = (ex5_fir_parerr_q[`THREADS] & ex5_parerr_q[`THREADS + 2]) |        // eratre, epn ws=0
                                  (ex5_fir_parerr_q[`THREADS + 1] & ex5_parerr_q[`THREADS + 3]) |    // eratre, rpn ws=1 or 2
                                   ex5_fir_parerr_q[`THREADS + 2];                                   // load/store, or eratsx epn

   // ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore

   // ### multihit error generation for translation types (eratsx mhit doesn't generate error, rather gives rt status bit)
   assign ex4_multihit_d = ((cam_hit == 1'b1 & ex3_ttype_q[4:5] != 2'b00 & ccr2_frat_paranoia_q[9] == 1'b0)) ? (ex3_valid) :
                           {`THREADS{1'b0}};
   assign ex5_fir_multihit_d = ((ex4_ttype_q[4:5] != 2'b00 & ex4_multihit_enab == 1'b1)) ? (ex4_multihit_q & ex4_valid) :
                               {`THREADS{1'b0}};
   assign ex5_deen_d[0:`THREADS - 1] = (((ex4_ttype_q[4] == 1'b1 | ex4_ttype_q[5] == 1'b1) & ex4_multihit_enab == 1'b1)) ? (ex4_multihit_q & ex4_valid) :
                                      {`THREADS{1'b0}};
   assign ex5_deen_d[`THREADS:`THREADS + num_entry_log2 - 1] = (ex4_ttype_q[2] == 1'b1 | ex4_ttype_q[4] == 1'b1 | ex4_ttype_q[5] == 1'b1) ? ex4_eratsx_data[2:2 + num_entry_log2 - 1] :
                                                             ((ex4_ttype_q[0] == 1'b1 & (ex4_ws_q == 2'b00 | ex4_ws_q == 2'b01 | ex4_ws_q == 2'b10) & ex4_tlbsel_q == TlbSel_DErat)) ? ex4_ra_entry_q :
                                                             {num_entry_log2{1'b0}};
   assign ex5_hit_d = (|(ex4_valid) == 1'b1) ? ex4_hit_q :
                      1'b0;
   assign ex6_deen_d[0:`THREADS - 1] = (ex5_deen_q[0:`THREADS - 1] & (~(cp_flush_q))) | (ex5_fir_parerr_q[0:`THREADS - 1] & (~(cp_flush_q)) & {`THREADS{ex5_fir_parerr_enab}});
   assign ex6_deen_d[`THREADS:`THREADS + num_entry_log2 - 1] = ex5_deen_q[`THREADS:`THREADS + num_entry_log2 - 1];
   assign ex6_hit_d = (|(ex5_valid & (~(cp_flush_q))) == 1'b1) ? ex5_hit_q :
                      1'b0;

   assign ex7_deen_d = {( ex6_deen_q[0:`THREADS - 1] & (~(cp_flush_q)) & {`THREADS{~mchk_flash_inv_enab}} ), ex6_deen_q[`THREADS:`THREADS + num_entry_log2 - 1]};
   assign ex7_hit_d = (|(ex6_valid & (~(cp_flush_q))) == 1'b1) ? ex6_hit_q :
                      1'b0;
   assign barrier_done_d = ((ex7_ttype_q[0] == 1'b1)) ? ex7_valid :
                           {`THREADS{1'b0}};

   // 16x143 version, 42b RA
   // wr_array_data
   //  0:29  - RPN
   //  30:31  - R,C
   //  32:35  - ResvAttr
   //  36:39  - U0-U3
   //  40:44  - WIMGE
   //  45:46  - UX,SX
   //  47:48  - UW,SW
   //  49:50  - UR,SR
   //  51:60  - CAM parity
   //  61:67  - Array parity

   // ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore
   // state: 0:pr 1:gs 2:ds 3:cm

   // ttype[8] is defined as: (icbtls | icblc)
   // ttype[9]=is_touch is defined in lq_dec.v as: (dcbt | dcbtep | dcbtst | dcbtstep | icbt) |
   //                                             ((dcbtls | dcbtstls | dcblc) & CT /= 0 or 2) |
   //                                             ((icbtls | icblc) & CT /= 0 or 2);

   assign ex3_dsi_d[0] = (ex2_ttype_q[5] & (~ex2_ttype_q[8]) & (~ex2_ttype_q[9]) & ex2_state_q[0] & (~ccr2_frat_paranoia_q[9]));     // store, not touch
   assign ex3_dsi_d[1] = (ex2_ttype_q[4] & (~ex2_ttype_q[8]) & (~ex2_ttype_q[9]) & ex2_state_q[0] & (~ccr2_frat_paranoia_q[9]));     // load, not touch
   assign ex3_dsi_d[2] = (ex2_ttype_q[4] & ex2_ttype_q[8] & (~ex2_ttype_q[9]) & ex2_state_q[0] & (~ccr2_frat_paranoia_q[9]));        // load, icbtls/icblc, touch=0 means TC=0 or 2 goodness
   assign ex3_dsi_d[3] = (ex2_ttype_q[5] & (~ex2_ttype_q[8]) & (~ex2_ttype_q[9]) & (~ex2_state_q[0]) & (~ccr2_frat_paranoia_q[9]));  // store, not touch
   assign ex3_dsi_d[4] = (ex2_ttype_q[4] & (~ex2_ttype_q[8]) & (~ex2_ttype_q[9]) & (~ex2_state_q[0]) & (~ccr2_frat_paranoia_q[9]));  // load, not touch
   assign ex3_dsi_d[5] = (ex2_ttype_q[4] & ex2_ttype_q[8] & (~ex2_ttype_q[9]) & (~ex2_state_q[0]) & (~ccr2_frat_paranoia_q[9]));     // load,  icbtls/icblc,  touch=0 means TC=0 or 2 goodness
   assign ex3_dsi_d[6] = (ex2_ttype_q[5] & (~ex2_ttype_q[8]) & (~ex2_ttype_q[9]) & mmucr1_q[2] & (~ccr2_frat_paranoia_q[9]));        // store (and not touch) with change exception enabled
   assign ex3_dsi_d[7] = (ex2_ttype_q[4] & (~ex2_ttype_q[8]) & (~ex2_ttype_q[9]) & mmucr1_q[1] & (~ccr2_frat_paranoia_q[9]));        // load (and not touch) with reference exception enabled
   assign ex3_dsi_d[8:7 + (2 * `THREADS)] = {ex2_valid, ex2_valid};
   assign ex4_dsi_d[0:7] = ex3_dsi_q[0:7];
   assign ex4_dsi_d[8:7 + (2 * `THREADS)] = ex3_dsi_q[8:7 + 2 * `THREADS] & (~(({cp_flush_q, cp_flush_q}) | ({ex3_strg_noop, ex3_strg_noop})));
   assign ex4_dsi[0] = ex4_dsi_q[0] & (~ex4_array_cmp_data_q[47]);  // store, not touch, not user writeable
   assign ex4_dsi[1] = ex4_dsi_q[1] & (~ex4_array_cmp_data_q[49]);  // load, not touch, not user readable
   assign ex4_dsi[2] = ex4_dsi_q[2] & (~ex4_array_cmp_data_q[45]) & (~ex4_array_cmp_data_q[49]);  // load, icbtls/icblc, not user readable and not executable; touch=0 means TC=0 or 2 goodness
   assign ex4_dsi[3] = ex4_dsi_q[3] & (~ex4_array_cmp_data_q[48]);  // store, not touch, not supervisor writeable
   assign ex4_dsi[4] = ex4_dsi_q[4] & (~ex4_array_cmp_data_q[50]);  // load, not touch, not supervisor readable
   assign ex4_dsi[5] = ex4_dsi_q[5] & (~ex4_array_cmp_data_q[46]) & (~ex4_array_cmp_data_q[50]);  // load,  icbtls/icblc, not supervisor readable and not executable; touch=0 means TC=0 or 2 goodness
   assign ex4_dsi[6] = ex4_dsi_q[6] & (~ex4_array_cmp_data_q[31]);  // store (and not touch) and C=0 with change exception enabled
   assign ex4_dsi[7] = ex4_dsi_q[7] & (~ex4_array_cmp_data_q[30]);  // load (and not touch) and R=0 with reference exception enabled
   assign ex4_dsi_enab = (|(ex4_dsi)) & (~(|(ex4_miss_q)));

   // ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore
   // state: 0:pr 1:gs 2:ds 3:cm

   // ttype[8] is defined as: (icbtls | icblc)
   // ttype[9]=is_touch is defined in lq_dec.v as: (dcbt | dcbtep | dcbtst | dcbtstep | icbt) |
   //                                             ((dcbtls | dcbtstls | dcblc) & CT /= 0 or 2) |
   //                                             ((icbtls | icblc) & CT /= 0 or 2);
   //   i.e. either it's one of the 5 touch instructions
   //           (in which case ISA says in event of access or miss exception, no-op the touch and do not generate the interrupt), or
   //        it's a lock set/clear op with a reserved/bad cache type field CT /= 0 or 2
   //           (in which case the instruction is treated as a no-op, and we no-op the it's side-affects here)

   // touch that would have caused exception needs to be no-op
   assign ex3_noop_touch_d[0] = ((ex2_ttype_q[4] | ex2_ttype_q[5]) & ex2_ttype_q[9]);
   assign ex3_noop_touch_d[1] = ((ex2_ttype_q[4] | ex2_ttype_q[5]) & ex2_ttype_q[9]);
   assign ex3_noop_touch_d[2] = ((ex2_ttype_q[4] | ex2_ttype_q[5]) & ex2_ttype_q[9]);
   assign ex3_noop_touch_d[3] = (ex2_ttype_q[4] & (~ex2_ttype_q[8]) & ex2_ttype_q[9] & ex2_state_q[0]);     // User load, is_touch but not icbtls/lc
   assign ex3_noop_touch_d[4] = (ex2_ttype_q[4] & (~ex2_ttype_q[8]) & ex2_ttype_q[9] & (~ex2_state_q[0]));  // Sup load, is_touch but not icbtls/lc
   assign ex3_noop_touch_d[5] = (ex2_ttype_q[5] & (~ex2_ttype_q[8]) & ex2_ttype_q[9] & ex2_state_q[0]);     // User store, is_touch but not icbtls/lc
   assign ex3_noop_touch_d[6] = (ex2_ttype_q[5] & (~ex2_ttype_q[8]) & ex2_ttype_q[9] & (~ex2_state_q[0]));  // Sup store, is_touch but not icbtls/lc
   assign ex3_noop_touch_d[7] = (ex2_ttype_q[4] & ex2_ttype_q[8] & ex2_ttype_q[9]);                         // Load, icbtls or icbtlc, and CT /= 0 or 2
   assign ex3_noop_touch_d[8:7 + (2 * `THREADS)] = {ex2_valid, ex2_valid};
   assign ex4_noop_touch_d[0] = ex3_noop_touch_q[0] & (~cam_hit);
   assign ex4_noop_touch_d[1:7] = ex3_noop_touch_q[1:7];
   assign ex4_noop_touch[3] = ex4_noop_touch_q[3] & (~ex4_array_cmp_data_q[49]);   // User load, is_touch, not readable access error
   assign ex4_noop_touch[4] = ex4_noop_touch_q[4] & (~ex4_array_cmp_data_q[50]);   // Sup load, is_touch, not readable access error
   assign ex4_noop_touch[5] = ex4_noop_touch_q[5] & (~ex4_array_cmp_data_q[47]);   // User store, is_touch, not writeable access error
   assign ex4_noop_touch[6] = ex4_noop_touch_q[6] & (~ex4_array_cmp_data_q[48]);   // Sup store, is_touch, not writeable access error
   assign ex4_noop_touch[7] = ex4_noop_touch_q[7];                                 // Load, icbtls or icbtlc, and CT /= 0 or 2
   assign ex4_noop_touch_d[8:7 + (2 * `THREADS)] = ex3_noop_touch_q[8:7 + (2 * `THREADS)] & (~(({cp_flush_q, cp_flush_q}) | ({ex3_strg_noop, ex3_strg_noop})));
   assign ex4_noop_touch_enab = ex4_noop_touch_q[0] | (|(ex4_noop_touch[3:7]));

   // mmucr1_q: 0-DRRE, 1-REE, 2-CEE, 3-csync, 4-isync, 5:6-DPEI, 7:8-DCTID/DTTID, 9-DCCD
   //ttype: 0-eratre,   1-eratwe, 2-eratsx,   3-eratilx,
   //       4-load,     5-store,  6-csync,    7-isync,
   //       8-icbtlslc, 9-touch, 10-extload, 11-extstore
   assign ex4_attr_d = array_cmp_data[45:50] | ({6{ccr2_frat_paranoia_q[9]}});
   assign snoop_val_d[0] = (snoop_val_q[0] == 1'b0) ? ex1_snoop_val_q :
                           ((tlb_rel_val_q[4] == 1'b0 & epsc_wr_q[2 * `THREADS] == 1'b0 & eplc_wr_q[2 * `THREADS] == 1'b0 & snoop_val_q[1] == 1'b1)) ? 1'b0 :
                           snoop_val_q[0];
   assign snoop_val_d[1] = (~ex1_binv_val_q);
   assign snoop_val_d[2] = ((tlb_rel_val_q[4] == 1'b1 | epsc_wr_q[2 * `THREADS] == 1'b1 | eplc_wr_q[2 * `THREADS] == 1'b1 | snoop_val_q[1] == 1'b0)) ? 1'b0 :
                           snoop_val_q[0];
   assign snoop_attr_d = (snoop_val_q[0] == 1'b0) ? snoopp_attr_q :
                         snoop_attr_q;
   assign snoop_addr_d = (snoop_val_q[0] == 1'b0) ? snoopp_vpn_q :
                         snoop_addr_q;
   assign lq_mm_snoop_ack = snoop_val_q[2];

   generate begin : rpnTid
         genvar tid;
         for (tid = 0; tid <= `THREADS - 1; tid = tid + 1) begin : rpnTid
            if (GPR_WIDTH == 64) begin : gen64_holdreg
               assign rpn_holdreg_d[tid][0:19]  = ((ex2_valid_op_q[tid] == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b01 & ex2_tlbsel_q == TlbSel_DErat & ex2_state_q[3] == 1'b1)) ? ex2_data_in_q[0:19] :
                                                  ((ex2_valid_op_q[tid] == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b10 & ex2_tlbsel_q == TlbSel_DErat & ex2_state_q[3] == 1'b0)) ? ex2_data_in_q[32:51] :
                                                  rpn_holdreg_q[tid][0:19];
               assign rpn_holdreg_d[tid][20:31] = ((ex2_valid_op_q[tid] == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b01 & ex2_tlbsel_q == TlbSel_DErat & ex2_state_q[3] == 1'b1)) ? ex2_data_in_q[20:31] :
                                                  ((ex2_valid_op_q[tid] == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b01 & ex2_tlbsel_q == TlbSel_DErat & ex2_state_q[3] == 1'b0)) ? ex2_data_in_q[52:63] :
                                                  rpn_holdreg_q[tid][20:31];
               assign rpn_holdreg_d[tid][32:51] = ((ex2_valid_op_q[tid] == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b01 & ex2_tlbsel_q == TlbSel_DErat & ex2_state_q[3] == 1'b1)) ? ex2_data_in_q[32:51] :
                                                  ((ex2_valid_op_q[tid] == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b01 & ex2_tlbsel_q == TlbSel_DErat & ex2_state_q[3] == 1'b0)) ? ex2_data_in_q[32:51] :
                                                  rpn_holdreg_q[tid][32:51];
               assign rpn_holdreg_d[tid][52:63] = ((ex2_valid_op_q[tid] == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b01 & ex2_tlbsel_q == TlbSel_DErat & ex2_state_q[3] == 1'b1)) ? ex2_data_in_q[52:63] :
                                                  ((ex2_valid_op_q[tid] == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b10 & ex2_tlbsel_q == TlbSel_DErat & ex2_state_q[3] == 1'b0)) ? ex2_data_in_q[52:63] :
                                                  rpn_holdreg_q[tid][52:63];
            end
            if (GPR_WIDTH == 32) begin : gen32_holdreg
               assign rpn_holdreg_d[tid][32:51] = ((ex2_valid_op_q[tid] == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b01 & ex2_tlbsel_q == TlbSel_DErat)) ? ex2_data_in_q[32:51] :
                                                  rpn_holdreg_q[tid][32:51];
               assign rpn_holdreg_d[tid][20:31] = ((ex2_valid_op_q[tid] == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b01 & ex2_tlbsel_q == TlbSel_DErat)) ? ex2_data_in_q[52:63] :
                                                  rpn_holdreg_q[tid][20:31];
               assign rpn_holdreg_d[tid][52:63] = ((ex2_valid_op_q[tid] == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b10 & ex2_tlbsel_q == TlbSel_DErat)) ? ex2_data_in_q[52:63] :
                                                  rpn_holdreg_q[tid][52:63];
               assign rpn_holdreg_d[tid][0:19]  = ((ex2_valid_op_q[tid] == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b10 & ex2_tlbsel_q == TlbSel_DErat)) ? ex2_data_in_q[32:51] :
                                                  rpn_holdreg_q[tid][0:19];
            end
         end
      end
   endgenerate

   assign ex2_deratwe_ws3 = (|(ex2_valid_op_q)) & ex2_ttype_q[1] & (ex2_ws_q == 2'b11) & (ex2_tlbsel_q == TlbSel_DErat);
   assign watermark_d = (ex2_deratwe_ws3 == 1'b1) ? ex2_data_in_q[64 - watermark_width:63] :
                        watermark_q;

   // entry pointer for round-robin mode
   assign eptr_d = ((ex2_deratwe_ws3 == 1'b1 | csinv_complete == 1'b1) & mmucr1_q[0] == 1'b1) ? {eptr_width{1'b0}} :
                   (eptr_q == 5'b11111 & ((|(ex2_valid_op_q) == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b00 & ex2_tlbsel_q == TlbSel_DErat & mmucr1_q[0] == 1'b1) | (tlb_rel_val_q[0:3] != 4'b0000 & tlb_rel_val_q[4] == 1'b1 & tlb_rel_data_q[eratpos_wren] == 1'b1 & mmucr1_q[0] == 1'b1))) ? {eptr_width{1'b0}} :
                   (eptr_q == watermark_q & ((|(ex2_valid_op_q) == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b00 & ex2_tlbsel_q == TlbSel_DErat & mmucr1_q[0] == 1'b1) | (tlb_rel_val_q[0:3] != 4'b0000 & tlb_rel_val_q[4] == 1'b1 & tlb_rel_data_q[eratpos_wren] == 1'b1 & mmucr1_q[0] == 1'b1))) ? {eptr_width{1'b0}} :
                   (((|(ex2_valid_op_q) == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b00 & ex2_tlbsel_q == TlbSel_DErat & mmucr1_q[0] == 1'b1) | (tlb_rel_val_q[0:3] != 4'b0000 & tlb_rel_val_q[4] == 1'b1 & tlb_rel_data_q[eratpos_wren] == 1'b1 & mmucr1_q[0] == 1'b1))) ? eptr_p1 :
                   eptr_q;
   assign eptr_p1 = (eptr_q == 5'b00000) ? 5'b00001 :
                    (eptr_q == 5'b00001) ? 5'b00010 :
                    (eptr_q == 5'b00010) ? 5'b00011 :
                    (eptr_q == 5'b00011) ? 5'b00100 :
                    (eptr_q == 5'b00100) ? 5'b00101 :
                    (eptr_q == 5'b00101) ? 5'b00110 :
                    (eptr_q == 5'b00110) ? 5'b00111 :
                    (eptr_q == 5'b00111) ? 5'b01000 :
                    (eptr_q == 5'b01000) ? 5'b01001 :
                    (eptr_q == 5'b01001) ? 5'b01010 :
                    (eptr_q == 5'b01010) ? 5'b01011 :
                    (eptr_q == 5'b01011) ? 5'b01100 :
                    (eptr_q == 5'b01100) ? 5'b01101 :
                    (eptr_q == 5'b01101) ? 5'b01110 :
                    (eptr_q == 5'b01110) ? 5'b01111 :
                    (eptr_q == 5'b01111) ? 5'b10000 :
                    (eptr_q == 5'b10000) ? 5'b10001 :
                    (eptr_q == 5'b10001) ? 5'b10010 :
                    (eptr_q == 5'b10010) ? 5'b10011 :
                    (eptr_q == 5'b10011) ? 5'b10100 :
                    (eptr_q == 5'b10100) ? 5'b10101 :
                    (eptr_q == 5'b10101) ? 5'b10110 :
                    (eptr_q == 5'b10110) ? 5'b10111 :
                    (eptr_q == 5'b10111) ? 5'b11000 :
                    (eptr_q == 5'b11000) ? 5'b11001 :
                    (eptr_q == 5'b11001) ? 5'b11010 :
                    (eptr_q == 5'b11010) ? 5'b11011 :
                    (eptr_q == 5'b11011) ? 5'b11100 :
                    (eptr_q == 5'b11100) ? 5'b11101 :
                    (eptr_q == 5'b11101) ? 5'b11110 :
                    (eptr_q == 5'b11110) ? 5'b11111 :
                    5'b00000;
   generate begin : epn_mask
         genvar                            i;
         for (i = (64 - (2 ** `GPR_WIDTH_ENC)); i <= 51; i = i + 1) begin : epn_mask
            if (i < 32) begin : R0
               assign ex3_epn_d[i] = (ex2_state_q[3] & dir_derat_ex2_epn_nonarr[i]);
            end
            if (i >= 32) begin : R1
               assign ex3_epn_d[i] = dir_derat_ex2_epn_nonarr[i];
            end
         end
      end
   endgenerate

   // lru_update_event
   // 0: tlb reload
   // 1: invalidate snoop
   // 2: csync or isync enabled
   // 3: eratwe WS=0
   // 4: load or store hit
   // 5: ex4 cam write type events
   // 6: ex4 cam invalidate type events
   // 7: ex4 cam translation type events
   // 8: superset, ex3
   // 9: superset, delayed to ex4
   assign lru_update_event_d[0] = (tlb_rel_data_q[eratpos_wren] & (|(tlb_rel_val_q[0:3])) & tlb_rel_val_q[4]);
   assign lru_update_event_d[1] = (snoop_val_q[0] & snoop_val_q[1]);
   assign lru_update_event_d[2] = csinv_complete;
   assign lru_update_event_d[3] = (|(ex2_valid_op_q) & ex2_ttype_q[1] & (ex2_ws_q == 2'b00) & (ex2_tlbsel_q == TlbSel_DErat) & (lru_way_encode == ex2_ra_entry_q));
   assign lru_update_event_d[4] = (|(ex2_valid) & |(ex2_ttype_q[4:5]));
   assign lru_update_event_d[5] = lru_update_event_q[0] | lru_update_event_q[3];
   assign lru_update_event_d[6] = lru_update_event_q[1] | lru_update_event_q[2];
   assign lru_update_event_d[7] = lru_update_event_q[4] & cam_hit;
   assign lru_update_event_d[8] = (tlb_rel_data_q[eratpos_wren] & (|(tlb_rel_val_q[0:3])) & tlb_rel_val_q[4]) | (snoop_val_q[0] & snoop_val_q[1]) | (csinv_complete) | (|(ex2_valid_op_q) & ex2_ttype_q[1] & (ex2_ws_q == 2'b00) & (ex2_tlbsel_q == TlbSel_DErat) & (lru_way_encode == ex2_ra_entry_q));
   assign lru_update_event_d[9] = lru_update_event_q[8] | (lru_update_event_q[4] & cam_hit);
   //?generate begin n(1 to 31);
   //lru_d(<n>) <= '1' when lru_set_vec(<n>)='1' and lru_op_vec(<n>)='0' and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
   //        else  '0' when lru_reset_vec(<n>)='1' and lru_op_vec(<n>)='0' and lru_update_event_q(9)='1' and mmucr1_q(0)='0'
   //        else lru_q(<n>);
   //lru_eff(<n>) <= (lru_vp_vec(<n>) and lru_op_vec(<n>)) or (lru_q(<n>) and not lru_op_vec(<n>));
   //?generate end;
   assign lru_d[1] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                     (lru_reset_vec[1] == 1'b1 & lru_op_vec[1] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                     (lru_set_vec[1] == 1'b1 & lru_op_vec[1] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                     lru_q[1];
   assign lru_eff[1] = (lru_vp_vec[1] & lru_op_vec[1]) | (lru_q[1] & (~lru_op_vec[1]));
   assign lru_d[2] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                     (lru_reset_vec[2] == 1'b1 & lru_op_vec[2] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                     (lru_set_vec[2] == 1'b1 & lru_op_vec[2] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                     lru_q[2];
   assign lru_eff[2] = (lru_vp_vec[2] & lru_op_vec[2]) | (lru_q[2] & (~lru_op_vec[2]));
   assign lru_d[3] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                     (lru_reset_vec[3] == 1'b1 & lru_op_vec[3] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                     (lru_set_vec[3] == 1'b1 & lru_op_vec[3] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                     lru_q[3];
   assign lru_eff[3] = (lru_vp_vec[3] & lru_op_vec[3]) | (lru_q[3] & (~lru_op_vec[3]));
   assign lru_d[4] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                     (lru_reset_vec[4] == 1'b1 & lru_op_vec[4] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                     (lru_set_vec[4] == 1'b1 & lru_op_vec[4] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                     lru_q[4];
   assign lru_eff[4] = (lru_vp_vec[4] & lru_op_vec[4]) | (lru_q[4] & (~lru_op_vec[4]));
   assign lru_d[5] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                     (lru_reset_vec[5] == 1'b1 & lru_op_vec[5] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                     (lru_set_vec[5] == 1'b1 & lru_op_vec[5] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                     lru_q[5];
   assign lru_eff[5] = (lru_vp_vec[5] & lru_op_vec[5]) | (lru_q[5] & (~lru_op_vec[5]));
   assign lru_d[6] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                     (lru_reset_vec[6] == 1'b1 & lru_op_vec[6] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                     (lru_set_vec[6] == 1'b1 & lru_op_vec[6] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                     lru_q[6];
   assign lru_eff[6] = (lru_vp_vec[6] & lru_op_vec[6]) | (lru_q[6] & (~lru_op_vec[6]));
   assign lru_d[7] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                     (lru_reset_vec[7] == 1'b1 & lru_op_vec[7] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                     (lru_set_vec[7] == 1'b1 & lru_op_vec[7] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                     lru_q[7];
   assign lru_eff[7] = (lru_vp_vec[7] & lru_op_vec[7]) | (lru_q[7] & (~lru_op_vec[7]));
   assign lru_d[8] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                     (lru_reset_vec[8] == 1'b1 & lru_op_vec[8] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                     (lru_set_vec[8] == 1'b1 & lru_op_vec[8] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                     lru_q[8];
   assign lru_eff[8] = (lru_vp_vec[8] & lru_op_vec[8]) | (lru_q[8] & (~lru_op_vec[8]));
   assign lru_d[9] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                     (lru_reset_vec[9] == 1'b1 & lru_op_vec[9] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                     (lru_set_vec[9] == 1'b1 & lru_op_vec[9] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                     lru_q[9];
   assign lru_eff[9] = (lru_vp_vec[9] & lru_op_vec[9]) | (lru_q[9] & (~lru_op_vec[9]));
   assign lru_d[10] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[10] == 1'b1 & lru_op_vec[10] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[10] == 1'b1 & lru_op_vec[10] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[10];
   assign lru_eff[10] = (lru_vp_vec[10] & lru_op_vec[10]) | (lru_q[10] & (~lru_op_vec[10]));
   assign lru_d[11] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[11] == 1'b1 & lru_op_vec[11] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[11] == 1'b1 & lru_op_vec[11] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[11];
   assign lru_eff[11] = (lru_vp_vec[11] & lru_op_vec[11]) | (lru_q[11] & (~lru_op_vec[11]));
   assign lru_d[12] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[12] == 1'b1 & lru_op_vec[12] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[12] == 1'b1 & lru_op_vec[12] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[12];
   assign lru_eff[12] = (lru_vp_vec[12] & lru_op_vec[12]) | (lru_q[12] & (~lru_op_vec[12]));
   assign lru_d[13] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[13] == 1'b1 & lru_op_vec[13] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[13] == 1'b1 & lru_op_vec[13] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[13];
   assign lru_eff[13] = (lru_vp_vec[13] & lru_op_vec[13]) | (lru_q[13] & (~lru_op_vec[13]));
   assign lru_d[14] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[14] == 1'b1 & lru_op_vec[14] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[14] == 1'b1 & lru_op_vec[14] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[14];
   assign lru_eff[14] = (lru_vp_vec[14] & lru_op_vec[14]) | (lru_q[14] & (~lru_op_vec[14]));
   assign lru_d[15] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[15] == 1'b1 & lru_op_vec[15] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[15] == 1'b1 & lru_op_vec[15] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[15];
   assign lru_eff[15] = (lru_vp_vec[15] & lru_op_vec[15]) | (lru_q[15] & (~lru_op_vec[15]));
   assign lru_d[16] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[16] == 1'b1 & lru_op_vec[16] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[16] == 1'b1 & lru_op_vec[16] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[16];
   assign lru_eff[16] = (lru_vp_vec[16] & lru_op_vec[16]) | (lru_q[16] & (~lru_op_vec[16]));
   assign lru_d[17] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[17] == 1'b1 & lru_op_vec[17] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[17] == 1'b1 & lru_op_vec[17] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[17];
   assign lru_eff[17] = (lru_vp_vec[17] & lru_op_vec[17]) | (lru_q[17] & (~lru_op_vec[17]));
   assign lru_d[18] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[18] == 1'b1 & lru_op_vec[18] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[18] == 1'b1 & lru_op_vec[18] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[18];
   assign lru_eff[18] = (lru_vp_vec[18] & lru_op_vec[18]) | (lru_q[18] & (~lru_op_vec[18]));
   assign lru_d[19] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[19] == 1'b1 & lru_op_vec[19] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[19] == 1'b1 & lru_op_vec[19] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[19];
   assign lru_eff[19] = (lru_vp_vec[19] & lru_op_vec[19]) | (lru_q[19] & (~lru_op_vec[19]));
   assign lru_d[20] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[20] == 1'b1 & lru_op_vec[20] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[20] == 1'b1 & lru_op_vec[20] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[20];
   assign lru_eff[20] = (lru_vp_vec[20] & lru_op_vec[20]) | (lru_q[20] & (~lru_op_vec[20]));
   assign lru_d[21] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[21] == 1'b1 & lru_op_vec[21] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[21] == 1'b1 & lru_op_vec[21] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[21];
   assign lru_eff[21] = (lru_vp_vec[21] & lru_op_vec[21]) | (lru_q[21] & (~lru_op_vec[21]));
   assign lru_d[22] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[22] == 1'b1 & lru_op_vec[22] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[22] == 1'b1 & lru_op_vec[22] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[22];
   assign lru_eff[22] = (lru_vp_vec[22] & lru_op_vec[22]) | (lru_q[22] & (~lru_op_vec[22]));
   assign lru_d[23] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[23] == 1'b1 & lru_op_vec[23] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[23] == 1'b1 & lru_op_vec[23] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[23];
   assign lru_eff[23] = (lru_vp_vec[23] & lru_op_vec[23]) | (lru_q[23] & (~lru_op_vec[23]));
   assign lru_d[24] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[24] == 1'b1 & lru_op_vec[24] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[24] == 1'b1 & lru_op_vec[24] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[24];
   assign lru_eff[24] = (lru_vp_vec[24] & lru_op_vec[24]) | (lru_q[24] & (~lru_op_vec[24]));
   assign lru_d[25] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[25] == 1'b1 & lru_op_vec[25] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[25] == 1'b1 & lru_op_vec[25] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[25];
   assign lru_eff[25] = (lru_vp_vec[25] & lru_op_vec[25]) | (lru_q[25] & (~lru_op_vec[25]));
   assign lru_d[26] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[26] == 1'b1 & lru_op_vec[26] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[26] == 1'b1 & lru_op_vec[26] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[26];
   assign lru_eff[26] = (lru_vp_vec[26] & lru_op_vec[26]) | (lru_q[26] & (~lru_op_vec[26]));
   assign lru_d[27] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[27] == 1'b1 & lru_op_vec[27] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[27] == 1'b1 & lru_op_vec[27] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[27];
   assign lru_eff[27] = (lru_vp_vec[27] & lru_op_vec[27]) | (lru_q[27] & (~lru_op_vec[27]));
   assign lru_d[28] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[28] == 1'b1 & lru_op_vec[28] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[28] == 1'b1 & lru_op_vec[28] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[28];
   assign lru_eff[28] = (lru_vp_vec[28] & lru_op_vec[28]) | (lru_q[28] & (~lru_op_vec[28]));
   assign lru_d[29] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[29] == 1'b1 & lru_op_vec[29] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[29] == 1'b1 & lru_op_vec[29] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[29];
   assign lru_eff[29] = (lru_vp_vec[29] & lru_op_vec[29]) | (lru_q[29] & (~lru_op_vec[29]));
   assign lru_d[30] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[30] == 1'b1 & lru_op_vec[30] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[30] == 1'b1 & lru_op_vec[30] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[30];
   assign lru_eff[30] = (lru_vp_vec[30] & lru_op_vec[30]) | (lru_q[30] & (~lru_op_vec[30]));
   assign lru_d[31] = (((ex2_deratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1)) ? 1'b0 :
                      (lru_reset_vec[31] == 1'b1 & lru_op_vec[31] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b0 :
                      (lru_set_vec[31] == 1'b1 & lru_op_vec[31] == 1'b0 & lru_update_event_q[9] == 1'b1 & mmucr1_q[0] == 1'b0) ? 1'b1 :
                      lru_q[31];
   assign lru_eff[31] = (lru_vp_vec[31] & lru_op_vec[31]) | (lru_q[31] & (~lru_op_vec[31]));
   // RMT override enable:  Op= OR(all RMT entries below and left of p) XOR OR(all RMT entries below and right of p)
   assign lru_op_vec[1] = (lru_rmt_vec[0] | lru_rmt_vec[1] | lru_rmt_vec[2] | lru_rmt_vec[3] | lru_rmt_vec[4] | lru_rmt_vec[5] | lru_rmt_vec[6] | lru_rmt_vec[7] | lru_rmt_vec[8] | lru_rmt_vec[9] | lru_rmt_vec[10] | lru_rmt_vec[11] | lru_rmt_vec[12] | lru_rmt_vec[13] | lru_rmt_vec[14] | lru_rmt_vec[15]) ^ (lru_rmt_vec[16] | lru_rmt_vec[17] | lru_rmt_vec[18] | lru_rmt_vec[19] | lru_rmt_vec[20] | lru_rmt_vec[21] | lru_rmt_vec[22] | lru_rmt_vec[23] | lru_rmt_vec[24] | lru_rmt_vec[25] | lru_rmt_vec[26] | lru_rmt_vec[27] | lru_rmt_vec[28] | lru_rmt_vec[29] | lru_rmt_vec[30] | lru_rmt_vec[31]);
   assign lru_op_vec[2] = (lru_rmt_vec[0] | lru_rmt_vec[1] | lru_rmt_vec[2] | lru_rmt_vec[3] | lru_rmt_vec[4] | lru_rmt_vec[5] | lru_rmt_vec[6] | lru_rmt_vec[7]) ^ (lru_rmt_vec[8] | lru_rmt_vec[9] | lru_rmt_vec[10] | lru_rmt_vec[11] | lru_rmt_vec[12] | lru_rmt_vec[13] | lru_rmt_vec[14] | lru_rmt_vec[15]);
   assign lru_op_vec[3] = (lru_rmt_vec[16] | lru_rmt_vec[17] | lru_rmt_vec[18] | lru_rmt_vec[19] | lru_rmt_vec[20] | lru_rmt_vec[21] | lru_rmt_vec[22] | lru_rmt_vec[23]) ^ (lru_rmt_vec[24] | lru_rmt_vec[25] | lru_rmt_vec[26] | lru_rmt_vec[27] | lru_rmt_vec[28] | lru_rmt_vec[29] | lru_rmt_vec[30] | lru_rmt_vec[31]);
   assign lru_op_vec[4] = (lru_rmt_vec[0] | lru_rmt_vec[1] | lru_rmt_vec[2] | lru_rmt_vec[3]) ^ (lru_rmt_vec[4] | lru_rmt_vec[5] | lru_rmt_vec[6] | lru_rmt_vec[7]);
   assign lru_op_vec[5] = (lru_rmt_vec[8] | lru_rmt_vec[9] | lru_rmt_vec[10] | lru_rmt_vec[11]) ^ (lru_rmt_vec[12] | lru_rmt_vec[13] | lru_rmt_vec[14] | lru_rmt_vec[15]);
   assign lru_op_vec[6] = (lru_rmt_vec[16] | lru_rmt_vec[17] | lru_rmt_vec[18] | lru_rmt_vec[19]) ^ (lru_rmt_vec[20] | lru_rmt_vec[21] | lru_rmt_vec[22] | lru_rmt_vec[23]);
   assign lru_op_vec[7] = (lru_rmt_vec[24] | lru_rmt_vec[25] | lru_rmt_vec[26] | lru_rmt_vec[27]) ^ (lru_rmt_vec[28] | lru_rmt_vec[29] | lru_rmt_vec[30] | lru_rmt_vec[31]);
   assign lru_op_vec[8] = (lru_rmt_vec[0] | lru_rmt_vec[1]) ^ (lru_rmt_vec[2] | lru_rmt_vec[3]);
   assign lru_op_vec[9] = (lru_rmt_vec[4] | lru_rmt_vec[5]) ^ (lru_rmt_vec[6] | lru_rmt_vec[7]);
   assign lru_op_vec[10] = (lru_rmt_vec[8] | lru_rmt_vec[9]) ^ (lru_rmt_vec[10] | lru_rmt_vec[11]);
   assign lru_op_vec[11] = (lru_rmt_vec[12] | lru_rmt_vec[13]) ^ (lru_rmt_vec[14] | lru_rmt_vec[15]);
   assign lru_op_vec[12] = (lru_rmt_vec[16] | lru_rmt_vec[17]) ^ (lru_rmt_vec[18] | lru_rmt_vec[19]);
   assign lru_op_vec[13] = (lru_rmt_vec[20] | lru_rmt_vec[21]) ^ (lru_rmt_vec[22] | lru_rmt_vec[23]);
   assign lru_op_vec[14] = (lru_rmt_vec[24] | lru_rmt_vec[25]) ^ (lru_rmt_vec[26] | lru_rmt_vec[27]);
   assign lru_op_vec[15] = (lru_rmt_vec[28] | lru_rmt_vec[29]) ^ (lru_rmt_vec[30] | lru_rmt_vec[31]);
   assign lru_op_vec[16] = lru_rmt_vec[0] ^ lru_rmt_vec[1];
   assign lru_op_vec[17] = lru_rmt_vec[2] ^ lru_rmt_vec[3];
   assign lru_op_vec[18] = lru_rmt_vec[4] ^ lru_rmt_vec[5];
   assign lru_op_vec[19] = lru_rmt_vec[6] ^ lru_rmt_vec[7];
   assign lru_op_vec[20] = lru_rmt_vec[8] ^ lru_rmt_vec[9];
   assign lru_op_vec[21] = lru_rmt_vec[10] ^ lru_rmt_vec[11];
   assign lru_op_vec[22] = lru_rmt_vec[12] ^ lru_rmt_vec[13];
   assign lru_op_vec[23] = lru_rmt_vec[14] ^ lru_rmt_vec[15];
   assign lru_op_vec[24] = lru_rmt_vec[16] ^ lru_rmt_vec[17];
   assign lru_op_vec[25] = lru_rmt_vec[18] ^ lru_rmt_vec[19];
   assign lru_op_vec[26] = lru_rmt_vec[20] ^ lru_rmt_vec[21];
   assign lru_op_vec[27] = lru_rmt_vec[22] ^ lru_rmt_vec[23];
   assign lru_op_vec[28] = lru_rmt_vec[24] ^ lru_rmt_vec[25];
   assign lru_op_vec[29] = lru_rmt_vec[26] ^ lru_rmt_vec[27];
   assign lru_op_vec[30] = lru_rmt_vec[28] ^ lru_rmt_vec[29];
   assign lru_op_vec[31] = lru_rmt_vec[30] ^ lru_rmt_vec[31];
   // RMT override value: Vp= OR(all RMT entries below and right of p)
   assign lru_vp_vec[1] = (lru_rmt_vec[16] | lru_rmt_vec[17] | lru_rmt_vec[18] | lru_rmt_vec[19] | lru_rmt_vec[20] | lru_rmt_vec[21] | lru_rmt_vec[22] | lru_rmt_vec[23] | lru_rmt_vec[24] | lru_rmt_vec[25] | lru_rmt_vec[26] | lru_rmt_vec[27] | lru_rmt_vec[28] | lru_rmt_vec[29] | lru_rmt_vec[30] | lru_rmt_vec[31]);
   assign lru_vp_vec[2] = (lru_rmt_vec[8] | lru_rmt_vec[9] | lru_rmt_vec[10] | lru_rmt_vec[11] | lru_rmt_vec[12] | lru_rmt_vec[13] | lru_rmt_vec[14] | lru_rmt_vec[15]);
   assign lru_vp_vec[3] = (lru_rmt_vec[24] | lru_rmt_vec[25] | lru_rmt_vec[26] | lru_rmt_vec[27] | lru_rmt_vec[28] | lru_rmt_vec[29] | lru_rmt_vec[30] | lru_rmt_vec[31]);
   assign lru_vp_vec[4] = (lru_rmt_vec[4] | lru_rmt_vec[5] | lru_rmt_vec[6] | lru_rmt_vec[7]);
   assign lru_vp_vec[5] = (lru_rmt_vec[12] | lru_rmt_vec[13] | lru_rmt_vec[14] | lru_rmt_vec[15]);
   assign lru_vp_vec[6] = (lru_rmt_vec[20] | lru_rmt_vec[21] | lru_rmt_vec[22] | lru_rmt_vec[23]);
   assign lru_vp_vec[7] = (lru_rmt_vec[28] | lru_rmt_vec[29] | lru_rmt_vec[30] | lru_rmt_vec[31]);
   assign lru_vp_vec[8] = (lru_rmt_vec[2] | lru_rmt_vec[3]);
   assign lru_vp_vec[9] = (lru_rmt_vec[6] | lru_rmt_vec[7]);
   assign lru_vp_vec[10] = (lru_rmt_vec[10] | lru_rmt_vec[11]);
   assign lru_vp_vec[11] = (lru_rmt_vec[14] | lru_rmt_vec[15]);
   assign lru_vp_vec[12] = (lru_rmt_vec[18] | lru_rmt_vec[19]);
   assign lru_vp_vec[13] = (lru_rmt_vec[22] | lru_rmt_vec[23]);
   assign lru_vp_vec[14] = (lru_rmt_vec[26] | lru_rmt_vec[27]);
   assign lru_vp_vec[15] = (lru_rmt_vec[30] | lru_rmt_vec[31]);
   assign lru_vp_vec[16] = lru_rmt_vec[1];
   assign lru_vp_vec[17] = lru_rmt_vec[3];
   assign lru_vp_vec[18] = lru_rmt_vec[5];
   assign lru_vp_vec[19] = lru_rmt_vec[7];
   assign lru_vp_vec[20] = lru_rmt_vec[9];
   assign lru_vp_vec[21] = lru_rmt_vec[11];
   assign lru_vp_vec[22] = lru_rmt_vec[13];
   assign lru_vp_vec[23] = lru_rmt_vec[15];
   assign lru_vp_vec[24] = lru_rmt_vec[17];
   assign lru_vp_vec[25] = lru_rmt_vec[19];
   assign lru_vp_vec[26] = lru_rmt_vec[21];
   assign lru_vp_vec[27] = lru_rmt_vec[23];
   assign lru_vp_vec[28] = lru_rmt_vec[25];
   assign lru_vp_vec[29] = lru_rmt_vec[27];
   assign lru_vp_vec[30] = lru_rmt_vec[29];
   assign lru_vp_vec[31] = lru_rmt_vec[31];
   // mmucr1_q: 0-DRRE, 1-REE, 2-CEE, 3-csync, 4-isync, 5:6-DPEI, 7:8-DCTID/DTTID, 9-DCCD
   //
   // Final Table Listing
   //      *INPUTS*=========*OUTPUTS*============================*
   //      |                |                                    |
   //      |                |  lru_rmt_vec_d                     |
   //      | watermark_d    |  |                                 |
   //      | |              |  |                                 |
   //      | |              |  |                                 |
   //      | |              |  |         1111111111222222222233  |
   //      | 01234          |  01234567890123456789012345678901  |
   //      *TYPE*===========+====================================+
   //      | PPPPP          |  PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP  |
   //      *POLARITY*------>|  ++++++++++++++++++++++++++++++++  |
   //      *PHASE*--------->|  TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT  |
   //      *OPTIMIZE*------>|   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
   //      *TERMS*==========+====================================+
   //    1 | 11111          |  ...............................1  |
   //    2 | -1111          |  ...............1................  |
   //    3 | 1-111          |  .......................1........  |
   //    4 | --111          |  .......1........................  |
   //    5 | 11-11          |  ...........................1....  |
   //    6 | -1-11          |  ...........1....................  |
   //    7 | 1--11          |  ...................1............  |
   //    8 | ---11          |  ...1............................  |
   //    9 | 111-1          |  .............................1..  |
   //   10 | -11-1          |  .............1..................  |
   //   11 | 1-1-1          |  .....................1..........  |
   //   12 | --1-1          |  .....1..........................  |
   //   13 | 11--1          |  .........................1......  |
   //   14 | -1--1          |  .........1......................  |
   //   15 | 1---1          |  .................1..............  |
   //   16 | ----1          |  .1..............................  |
   //   17 | 1111-          |  .............................11.  |
   //   18 | -111-          |  .............11.................  |
   //   19 | 1-11-          |  .....................11.........  |
   //   20 | --11-          |  .....11.........................  |
   //   21 | 11-1-          |  .........................11.....  |
   //   22 | -1-1-          |  .........11.....................  |
   //   23 | 1--1-          |  .................11.............  |
   //   24 | ---1-          |  .11.............................  |
   //   25 | 111--          |  .........................1111...  |
   //   26 | -11--          |  .........1111...................  |
   //   27 | 1-1--          |  .................1111...........  |
   //   28 | --1--          |  .1111...........................  |
   //   29 | 11---          |  .................11111111.......  |
   //   30 | -1---          |  .11111111.......................  |
   //   31 | 1----          |  .1111111111111111...............  |
   //   32 | -----          |  1...............................  |
   //      *=====================================================*
   //
   // Table LRU_RMT_VEC_D Signal Assignments for Product Terms
   assign LRU_RMT_VEC_D_PT[1]  = (({watermark_d[0], watermark_d[1], watermark_d[2], watermark_d[3], watermark_d[4]}) == 5'b11111);
   assign LRU_RMT_VEC_D_PT[2]  = (({watermark_d[1], watermark_d[2], watermark_d[3], watermark_d[4]}) == 4'b1111);
   assign LRU_RMT_VEC_D_PT[3]  = (({watermark_d[0], watermark_d[2], watermark_d[3], watermark_d[4]}) == 4'b1111);
   assign LRU_RMT_VEC_D_PT[4]  = (({watermark_d[2], watermark_d[3], watermark_d[4]}) == 3'b111);
   assign LRU_RMT_VEC_D_PT[5]  = (({watermark_d[0], watermark_d[1], watermark_d[3], watermark_d[4]}) == 4'b1111);
   assign LRU_RMT_VEC_D_PT[6]  = (({watermark_d[1], watermark_d[3], watermark_d[4]}) == 3'b111);
   assign LRU_RMT_VEC_D_PT[7]  = (({watermark_d[0], watermark_d[3], watermark_d[4]}) == 3'b111);
   assign LRU_RMT_VEC_D_PT[8]  = (({watermark_d[3], watermark_d[4]}) == 2'b11);
   assign LRU_RMT_VEC_D_PT[9]  = (({watermark_d[0], watermark_d[1], watermark_d[2], watermark_d[4]}) == 4'b1111);
   assign LRU_RMT_VEC_D_PT[10] = (({watermark_d[1], watermark_d[2], watermark_d[4]}) == 3'b111);
   assign LRU_RMT_VEC_D_PT[11] = (({watermark_d[0], watermark_d[2], watermark_d[4]}) == 3'b111);
   assign LRU_RMT_VEC_D_PT[12] = (({watermark_d[2], watermark_d[4]}) == 2'b11);
   assign LRU_RMT_VEC_D_PT[13] = (({watermark_d[0], watermark_d[1], watermark_d[4]}) == 3'b111);
   assign LRU_RMT_VEC_D_PT[14] = (({watermark_d[1], watermark_d[4]}) == 2'b11);
   assign LRU_RMT_VEC_D_PT[15] = (({watermark_d[0], watermark_d[4]}) == 2'b11);
   assign LRU_RMT_VEC_D_PT[16] = ((watermark_d[4]) == 1'b1);
   assign LRU_RMT_VEC_D_PT[17] = (({watermark_d[0], watermark_d[1], watermark_d[2], watermark_d[3]}) == 4'b1111);
   assign LRU_RMT_VEC_D_PT[18] = (({watermark_d[1], watermark_d[2], watermark_d[3]}) == 3'b111);
   assign LRU_RMT_VEC_D_PT[19] = (({watermark_d[0], watermark_d[2], watermark_d[3]}) == 3'b111);
   assign LRU_RMT_VEC_D_PT[20] = (({watermark_d[2], watermark_d[3]}) == 2'b11);
   assign LRU_RMT_VEC_D_PT[21] = (({watermark_d[0], watermark_d[1], watermark_d[3]}) == 3'b111);
   assign LRU_RMT_VEC_D_PT[22] = (({watermark_d[1], watermark_d[3]}) == 2'b11);
   assign LRU_RMT_VEC_D_PT[23] = (({watermark_d[0], watermark_d[3]}) == 2'b11);
   assign LRU_RMT_VEC_D_PT[24] = ((watermark_d[3]) == 1'b1);
   assign LRU_RMT_VEC_D_PT[25] = (({watermark_d[0], watermark_d[1], watermark_d[2]}) == 3'b111);
   assign LRU_RMT_VEC_D_PT[26] = (({watermark_d[1], watermark_d[2]}) == 2'b11);
   assign LRU_RMT_VEC_D_PT[27] = (({watermark_d[0], watermark_d[2]}) == 2'b11);
   assign LRU_RMT_VEC_D_PT[28] = ((watermark_d[2]) == 1'b1);
   assign LRU_RMT_VEC_D_PT[29] = (({watermark_d[0], watermark_d[1]}) == 2'b11);
   assign LRU_RMT_VEC_D_PT[30] = ((watermark_d[1]) == 1'b1);
   assign LRU_RMT_VEC_D_PT[31] = ((watermark_d[0]) == 1'b1);
   assign LRU_RMT_VEC_D_PT[32] = 1'b1;
   // Table LRU_RMT_VEC_D Signal Assignments for Outputs
   assign lru_rmt_vec_d[0] = (LRU_RMT_VEC_D_PT[32]);
   assign lru_rmt_vec_d[1] = (LRU_RMT_VEC_D_PT[16] | LRU_RMT_VEC_D_PT[24] | LRU_RMT_VEC_D_PT[28] | LRU_RMT_VEC_D_PT[30] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[2] = (LRU_RMT_VEC_D_PT[24] | LRU_RMT_VEC_D_PT[28] | LRU_RMT_VEC_D_PT[30] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[3] = (LRU_RMT_VEC_D_PT[8] | LRU_RMT_VEC_D_PT[28] | LRU_RMT_VEC_D_PT[30] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[4] = (LRU_RMT_VEC_D_PT[28] | LRU_RMT_VEC_D_PT[30] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[5] = (LRU_RMT_VEC_D_PT[12] | LRU_RMT_VEC_D_PT[20] | LRU_RMT_VEC_D_PT[30] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[6] = (LRU_RMT_VEC_D_PT[20] | LRU_RMT_VEC_D_PT[30] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[7] = (LRU_RMT_VEC_D_PT[4] | LRU_RMT_VEC_D_PT[30] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[8] = (LRU_RMT_VEC_D_PT[30] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[9] = (LRU_RMT_VEC_D_PT[14] | LRU_RMT_VEC_D_PT[22] | LRU_RMT_VEC_D_PT[26] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[10] = (LRU_RMT_VEC_D_PT[22] | LRU_RMT_VEC_D_PT[26] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[11] = (LRU_RMT_VEC_D_PT[6] | LRU_RMT_VEC_D_PT[26] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[12] = (LRU_RMT_VEC_D_PT[26] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[13] = (LRU_RMT_VEC_D_PT[10] | LRU_RMT_VEC_D_PT[18] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[14] = (LRU_RMT_VEC_D_PT[18] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[15] = (LRU_RMT_VEC_D_PT[2] | LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[16] = (LRU_RMT_VEC_D_PT[31]);
   assign lru_rmt_vec_d[17] = (LRU_RMT_VEC_D_PT[15] | LRU_RMT_VEC_D_PT[23] | LRU_RMT_VEC_D_PT[27] | LRU_RMT_VEC_D_PT[29]);
   assign lru_rmt_vec_d[18] = (LRU_RMT_VEC_D_PT[23] | LRU_RMT_VEC_D_PT[27] | LRU_RMT_VEC_D_PT[29]);
   assign lru_rmt_vec_d[19] = (LRU_RMT_VEC_D_PT[7] | LRU_RMT_VEC_D_PT[27] | LRU_RMT_VEC_D_PT[29]);
   assign lru_rmt_vec_d[20] = (LRU_RMT_VEC_D_PT[27] | LRU_RMT_VEC_D_PT[29]);
   assign lru_rmt_vec_d[21] = (LRU_RMT_VEC_D_PT[11] | LRU_RMT_VEC_D_PT[19] | LRU_RMT_VEC_D_PT[29]);
   assign lru_rmt_vec_d[22] = (LRU_RMT_VEC_D_PT[19] | LRU_RMT_VEC_D_PT[29]);
   assign lru_rmt_vec_d[23] = (LRU_RMT_VEC_D_PT[3] | LRU_RMT_VEC_D_PT[29]);
   assign lru_rmt_vec_d[24] = (LRU_RMT_VEC_D_PT[29]);
   assign lru_rmt_vec_d[25] = (LRU_RMT_VEC_D_PT[13] | LRU_RMT_VEC_D_PT[21] | LRU_RMT_VEC_D_PT[25]);
   assign lru_rmt_vec_d[26] = (LRU_RMT_VEC_D_PT[21] | LRU_RMT_VEC_D_PT[25]);
   assign lru_rmt_vec_d[27] = (LRU_RMT_VEC_D_PT[5] | LRU_RMT_VEC_D_PT[25]);
   assign lru_rmt_vec_d[28] = (LRU_RMT_VEC_D_PT[25]);
   assign lru_rmt_vec_d[29] = (LRU_RMT_VEC_D_PT[9] | LRU_RMT_VEC_D_PT[17]);
   assign lru_rmt_vec_d[30] = (LRU_RMT_VEC_D_PT[17]);
   assign lru_rmt_vec_d[31] = (LRU_RMT_VEC_D_PT[1]);

   assign mmucr1_b0_cpy_d         = mmucr1_d[0];
   assign lru_rmt_vec             = lru_rmt_vec_q;
   assign lru_watermark_mask      = (~lru_rmt_vec_q);
   assign entry_valid_watermarked = entry_valid_q | lru_watermark_mask;
   // lru_update_event
   // 0: tlb reload
   // 1: invalidate snoop
   // 2: csync or isync enabled
   // 3: eratwe WS=0
   // 4: load or store hit
   // 5: cam write type events
   // 6: cam invalidate type events
   // 7: cam translation type events
   // 8: superset, ex3
   // 9: superset, delayed to ex4
   // logic for the LRU reset and set bit vectors
   // ?TABLE lru_set_reset_vec LISTING(final) OPTIMIZE PARMS(ON-SET, OFF-SET);
   //
   // Final Table Listing
   //      *INPUTS*========================================================================================================*OUTPUTS*=============================================================*
   //      |                                                                                                               |                                                                     |
   //      | lru_update_event_q                                                                                            |  lru_reset_vec                                                      |
   //      | |         entry_valid_watermarked                                                                             |  |                                 lru_set_vec                      |
   //      | |         |                                lru_q                                                              |  |                                 |                                |
   //      | |         |                                |                               entry_match_q                      |  |                                 |                                |
   //      | |         |                                |                               |                                  |  |                                 |                                |
   //      | |         |                                |                               |                                  |  |                                 |                                |
   //      | |         |         1111111111222222222233 |        1111111111222222222233 |         1111111111222222222233   |  |        1111111111222222222233   |        1111111111222222222233  |
   //      | 012345678 01234567890123456789012345678901 1234567890123456789012345678901 01234567890123456789012345678901   |  1234567890123456789012345678901   1234567890123456789012345678901  |
   //      *TYPE*==========================================================================================================+=====================================================================+
   //      | PPPPPPPPP PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP   |  PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP   PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP  |
   //      *POLARITY*----------------------------------------------------------------------------------------------------->|  +++++++++++++++++++++++++++++++   +++++++++++++++++++++++++++++++  |
   //      *PHASE*-------------------------------------------------------------------------------------------------------->|  TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT   TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT  |
   //      *OPTIMIZE*----------------------------------------------------------------------------------------------------->|   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB   |
   //      *TERMS*=========================================================================================================+=====================================================================+
   //    1 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000000000000000000000001   |  1.1...1.......1...............1   ...............................  |
   //    2 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000000000000000000001-   |  1.1...1.......1................   ...............................  |
   //    3 | -----001- 1111111111111111111111111111111- ------------------------------- 0000000000000000000000000000001-   |  ...............................   ..............................1  |
   //    4 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000000000000000000001--   |  1.1...1......................1.   ...............................  |
   //    5 | -----001- 111111111111111111111111111111-- ------------------------------- 0000000000000000000000000000-1--   |  ...............................   ..............1................  |
   //    6 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000000000000000000001---   |  1.1...1........................   ..............1..............1.  |
   //    7 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000000000000000001----   |  1.1..........1..............1..   ...............................  |
   //    8 | -----001- 1111111111111111111111111111---- ------------------------------- 000000000000000000000000---1----   |  ...............................   ......1........................  |
   //    9 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000000000000000001-----   |  1.1..........1.................   ......1.....................1..  |
   //   10 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000000000000000001------   |  1.1........................1...   ...............................  |
   //   11 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000000000000000-1------   |  ...............................   ......1......1.................  |
   //   12 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000000000000001-------   |  1.1............................   ......1......1.............1...  |
   //   13 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000000000000001--------   |  1....1......1.............1....   ...............................  |
   //   14 | -----001- 111111111111111111111111-------- ------------------------------- 0000000000000000-------1--------   |  ...............................   ..1............................  |
   //   15 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000000000000001---------   |  1....1......1..................   ..1.......................1....  |
   //   16 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000000000001----------   |  1....1...................1.....   ...............................  |
   //   17 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000000000000-1----------   |  ...............................   ..1.........1..................  |
   //   18 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000000000001-----------   |  1....1.........................   ..1.........1............1.....  |
   //   19 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000000000001------------   |  1..........1............1......   ...............................  |
   //   20 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000000---1------------   |  ...............................   ..1..1.........................  |
   //   21 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000000001-------------   |  1..........1...................   ..1..1..................1......  |
   //   22 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000000001--------------   |  1......................1.......   ...............................  |
   //   23 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000000-1--------------   |  ...............................   ..1..1.....1...................  |
   //   24 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000000001---------------   |  ...............................   ..1..1.....1...........1.......  |
   //   25 | -----001- ----------------1111111111111111 ------------------------------- 00000000000000001---------------   |  1..............................   ...............................  |
   //   26 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000000001----------------   |  .1..1.....1...........1........   ...............................  |
   //   27 | -----001- 1111111111111111---------------- ------------------------------- ---------------1----------------   |  ...............................   1..............................  |
   //   28 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000001-----------------   |  .1..1.....1....................   1.....................1........  |
   //   29 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000000001------------------   |  .1..1................1.........   ...............................  |
   //   30 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000000-1------------------   |  ...............................   1.........1....................  |
   //   31 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000000001-------------------   |  .1..1..........................   1.........1..........1.........  |
   //   32 | -----001- 11111111111111111111111111111111 ------------------------------- 000000000001--------------------   |  .1.......1..........1..........   ...............................  |
   //   33 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000---1--------------------   |  ...............................   1...1..........................  |
   //   34 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000001---------------------   |  .1.......1.....................   1...1...............1..........  |
   //   35 | -----001- 11111111111111111111111111111111 ------------------------------- 0000000001----------------------   |  .1.................1...........   ...............................  |
   //   36 | -----001- 11111111111111111111111111111111 ------------------------------- 00000000-1----------------------   |  ...............................   1...1....1.....................  |
   //   37 | -----001- 11111111111111111111111111111111 ------------------------------- 000000001-----------------------   |  ...............................   1...1....1.........1...........  |
   //   38 | -----001- --------111111111111111111111111 ------------------------------- 000000001-----------------------   |  .1.............................   ...............................  |
   //   39 | -----001- 11111111111111111111111111111111 ------------------------------- 00000001------------------------   |  ...1....1.........1............   ...............................  |
   //   40 | -----001- 11111111111111111111111111111111 ------------------------------- -------1------------------------   |  ...............................   11.............................  |
   //   41 | -----001- 11111111111111111111111111111111 ------------------------------- 0000001-------------------------   |  ...1....1......................   11................1............  |
   //   42 | -----001- 11111111111111111111111111111111 ------------------------------- 000001--------------------------   |  ...1.............1.............   ...............................  |
   //   43 | -----001- 11111111111111111111111111111111 ------------------------------- 0000-1--------------------------   |  ...............................   11......1......................  |
   //   44 | -----001- 11111111111111111111111111111111 ------------------------------- 00001---------------------------   |  ...............................   11......1........1.............  |
   //   45 | -----001- ----1111111111111111111111111111 ------------------------------- 00001---------------------------   |  ...1...........................   ...............................  |
   //   46 | -----001- 11111111111111111111111111111111 ------------------------------- 0001----------------------------   |  .......1........1..............   ...............................  |
   //   47 | -----001- 11111111111111111111111111111111 ------------------------------- ---1----------------------------   |  ...............................   11.1...........................  |
   //   48 | -----001- 11111111111111111111111111111111 ------------------------------- 001-----------------------------   |  ...............................   11.1............1..............  |
   //   49 | -----001- --111111111111111111111111111111 ------------------------------- 001-----------------------------   |  .......1.......................   ...............................  |
   //   50 | -----001- -1111111111111111111111111111111 ------------------------------- 01------------------------------   |  ...............1...............   ...............................  |
   //   51 | -----001- 11111111111111111111111111111111 ------------------------------- -1------------------------------   |  ...............................   11.1...1.......................  |
   //   52 | -----001- 11111111111111111111111111111111 ------------------------------- 1-------------------------------   |  ...............................   11.1...1.......1...............  |
   //   53 | -----1--- 1111111111111111111111111111111- 1-1---1-------1---------------0 --------------------------------   |  ...............................   ..............................1  |
   //   54 | -----1--- 111111111111111111111111111111-1 1-1---1-------1---------------1 --------------------------------   |  ..............................1   ...............................  |
   //   55 | -----1--- 11111111111111111111111111111-11 1-1---1-------0--------------0- --------------------------------   |  ...............................   .............................1.  |
   //   56 | -----1--- 1111111111111111111111111111-111 1-1---1-------0--------------1- --------------------------------   |  .............................1.   ...............................  |
   //   57 | -----1--- 111111111111111111111111111-1111 1-1---0------1--------------0-- --------------------------------   |  ...............................   ............................1..  |
   //   58 | -----1--- 11111111111111111111111111-11111 1-1---0------1--------------1-- --------------------------------   |  ............................1..   ...............................  |
   //   59 | -----1--- 1111111111111111111111111-111111 1-1---0------0-------------0--- --------------------------------   |  ...............................   ...........................1...  |
   //   60 | -----1--- 111111111111111111111111-1111111 1-1---0------0-------------1--- --------------------------------   |  ...........................1...   ...............................  |
   //   61 | -----1--- 11111111111111111111111-11111111 1-0--1------1-------------0---- --------------------------------   |  ...............................   ..........................1....  |
   //   62 | -----1--- 1111111111111111111111-111111111 1-0--1------1-------------1---- --------------------------------   |  ..........................1....   ...............................  |
   //   63 | -----1--- 111111111111111111111-1111111111 1-0--1------0------------0----- --------------------------------   |  ...............................   .........................1.....  |
   //   64 | -----1--- 11111111111111111111-11111111111 1-0--1------0------------1----- --------------------------------   |  .........................1.....   ...............................  |
   //   65 | -----1--- 1111111111111111111-111111111111 1-0--0-----1------------0------ --------------------------------   |  ...............................   ........................1......  |
   //   66 | -----1--- 111111111111111111-1111111111111 1-0--0-----1------------1------ --------------------------------   |  ........................1......   ...............................  |
   //   67 | -----1--- 11111111111111111-11111111111111 1-0--0-----0-----------0------- --------------------------------   |  ...............................   .......................1.......  |
   //   68 | -----1--- 1111111111111111-111111111111111 1-0--0-----0-----------1------- --------------------------------   |  .......................1.......   ...............................  |
   //   69 | -----1--- 111111111111111-1111111111111111 01--1-----1-----------0-------- --------------------------------   |  ...............................   ......................1........  |
   //   70 | -----1--- 11111111111111-11111111111111111 01--1-----1-----------1-------- --------------------------------   |  ......................1........   ...............................  |
   //   71 | -----1--- 1111111111111-111111111111111111 01--1-----0----------0--------- --------------------------------   |  ...............................   .....................1.........  |
   //   72 | -----1--- 111111111111-1111111111111111111 01--1-----0----------1--------- --------------------------------   |  .....................1.........   ...............................  |
   //   73 | -----1--- 11111111111-11111111111111111111 01--0----1----------0---------- --------------------------------   |  ...............................   ....................1..........  |
   //   74 | -----1--- 1111111111-111111111111111111111 01--0----1----------1---------- --------------------------------   |  ....................1..........   ...............................  |
   //   75 | -----1--- 111111111-1111111111111111111111 01--0----0---------0----------- --------------------------------   |  ...............................   ...................1...........  |
   //   76 | -----1--- 11111111-11111111111111111111111 01--0----0---------1----------- --------------------------------   |  ...................1...........   ...............................  |
   //   77 | -----1--- 1111111-111111111111111111111111 00-1----1---------0------------ --------------------------------   |  ...............................   ..................1............  |
   //   78 | -----1--- 111111-1111111111111111111111111 00-1----1---------1------------ --------------------------------   |  ..................1............   ...............................  |
   //   79 | -----1--- 11111-11111111111111111111111111 00-1----0--------0------------- --------------------------------   |  ...............................   .................1.............  |
   //   80 | -----1--- 1111-111111111111111111111111111 00-1----0--------1------------- --------------------------------   |  .................1.............   ...............................  |
   //   81 | -----1--- 111-1111111111111111111111111111 00-0---1--------0-------------- --------------------------------   |  ...............................   ................1..............  |
   //   82 | -----1--- 11-11111111111111111111111111111 00-0---1--------1-------------- --------------------------------   |  ................1..............   ...............................  |
   //   83 | -----1--- 1-111111111111111111111111111111 00-0---0-------0--------------- --------------------------------   |  ...............................   ...............1...............  |
   //   84 | -----1--- -1111111111111111111111111111111 00-0---0-------1--------------- --------------------------------   |  ...............1...............   ...............................  |
   //   85 | -----1--- 111111111111111111111111111111-- 1-1---1-------0---------------- --------------------------------   |  ...............................   ..............1................  |
   //   86 | -----1--- 1111111111111111111111111111--11 1-1---1-------1---------------- --------------------------------   |  ..............1................   ...............................  |
   //   87 | -----1--- 11111111111111111111111111--1111 1-1---0------0----------------- --------------------------------   |  ...............................   .............1.................  |
   //   88 | -----1--- 111111111111111111111111--111111 1-1---0------1----------------- --------------------------------   |  .............1.................   ...............................  |
   //   89 | -----1--- 1111111111111111111111--11111111 1-0--1------0------------------ --------------------------------   |  ...............................   ............1..................  |
   //   90 | -----1--- 11111111111111111111--1111111111 1-0--1------1------------------ --------------------------------   |  ............1..................   ...............................  |
   //   91 | -----1--- 111111111111111111--111111111111 1-0--0-----0------------------- --------------------------------   |  ...............................   ...........1...................  |
   //   92 | -----1--- 1111111111111111--11111111111111 1-0--0-----1------------------- --------------------------------   |  ...........1...................   ...............................  |
   //   93 | -----1--- 11111111111111--1111111111111111 01--1-----0-------------------- --------------------------------   |  ...............................   ..........1....................  |
   //   94 | -----1--- 111111111111--111111111111111111 01--1-----1-------------------- --------------------------------   |  ..........1....................   ...............................  |
   //   95 | -----1--- 1111111111--11111111111111111111 01--0----0--------------------- --------------------------------   |  ...............................   .........1.....................  |
   //   96 | -----1--- 11111111--1111111111111111111111 01--0----1--------------------- --------------------------------   |  .........1.....................   ...............................  |
   //   97 | -----1--- 111111--111111111111111111111111 00-1----0---------------------- --------------------------------   |  ...............................   ........1......................  |
   //   98 | -----1--- 1111--11111111111111111111111111 00-1----1---------------------- --------------------------------   |  ........1......................   ...............................  |
   //   99 | -----1--- 11--1111111111111111111111111111 00-0---0----------------------- --------------------------------   |  ...............................   .......1.......................  |
   //   100 | -----1--- --111111111111111111111111111111 00-0---1----------------------- --------------------------------   |  .......1.......................   ...............................  |
   //   101 | -----1--- 1111111111111111111111111111---- 1-1---0------------------------ --------------------------------   |  ...............................   ......1........................  |
   //   102 | -----1--- 111111111111111111111111----1111 1-1---1------------------------ --------------------------------   |  ......1........................   ...............................  |
   //   103 | -----1--- 11111111111111111111----11111111 1-0--0------------------------- --------------------------------   |  ...............................   .....1.........................  |
   //   104 | -----1--- 1111111111111111----111111111111 1-0--1------------------------- --------------------------------   |  .....1.........................   ...............................  |
   //   105 | -----1--- 111111111111----1111111111111111 01--0-------------------------- --------------------------------   |  ...............................   ....1..........................  |
   //   106 | -----1--- 11111111----11111111111111111111 01--1-------------------------- --------------------------------   |  ....1..........................   ...............................  |
   //   107 | -----1--- 1111----111111111111111111111111 00-0--------------------------- --------------------------------   |  ...............................   ...1...........................  |
   //   108 | -----1--- ----1111111111111111111111111111 00-1--------------------------- --------------------------------   |  ...1...........................   ...............................  |
   //   109 | -----1--- 111111111111111111111111-------- 1-0---------------------------- --------------------------------   |  ...............................   ..1............................  |
   //   110 | -----1--- 1111111111111111--------11111111 1-1---------------------------- --------------------------------   |  ..1............................   ...............................  |
   //   111 | -----1--- 11111111--------1111111111111111 00----------------------------- --------------------------------   |  ...............................   .1.............................  |
   //   112 | -----1--- --------111111111111111111111111 01----------------------------- --------------------------------   |  .1.............................   ...............................  |
   //   113 | -----1--- 1111111111111111---------------- 0------------------------------ --------------------------------   |  ...............................   1..............................  |
   //   114 | -----1--- ----------------1111111111111111 1------------------------------ --------------------------------   |  1..............................   ...............................  |
   //   115 | --------- 11111111111111111111111111111110 ------------------------------- --------------------------------   |  ...............................   1.1...1.......1...............1  |
   //   116 | --------- 1111111111111111111111111111110- ------------------------------- --------------------------------   |  ..............................1   1.1...1.......1................  |
   //   117 | --------- 111111111111111111111111111110-- ------------------------------- --------------------------------   |  ...............................   1.1...1......................1.  |
   //   118 | --------- 1111111111111111111111111111-0-- ------------------------------- --------------------------------   |  ..............1................   ...............................  |
   //   119 | --------- 11111111111111111111111111110--- ------------------------------- --------------------------------   |  ..............1..............1.   1.1...1........................  |
   //   120 | --------- 1111111111111111111111111110---- ------------------------------- --------------------------------   |  ...............................   1.1..........1..............1..  |
   //   121 | --------- 111111111111111111111111---0---- ------------------------------- --------------------------------   |  ......1........................   ...............................  |
   //   122 | --------- 111111111111111111111111110----- ------------------------------- --------------------------------   |  ......1.....................1..   1.1..........1.................  |
   //   123 | --------- 11111111111111111111111110------ ------------------------------- --------------------------------   |  ...............................   1.1........................1...  |
   //   124 | --------- 111111111111111111111111-0------ ------------------------------- --------------------------------   |  ......1......1.................   ...............................  |
   //   125 | --------- 1111111111111111111111110------- ------------------------------- --------------------------------   |  ......1......1.............1...   1.1............................  |
   //   126 | --------- 111111111111111111111110-------- ------------------------------- --------------------------------   |  ...............................   1....1......1.............1....  |
   //   127 | --------- 1111111111111111-------0-------- ------------------------------- --------------------------------   |  ..1............................   ...............................  |
   //   128 | --------- 11111111111111111111110--------- ------------------------------- --------------------------------   |  ..1.......................1....   1....1......1..................  |
   //   129 | --------- 1111111111111111111110---------- ------------------------------- --------------------------------   |  ...............................   1....1...................1.....  |
   //   130 | --------- 11111111111111111111-0---------- ------------------------------- --------------------------------   |  ..1.........1..................   ...............................  |
   //   131 | --------- 111111111111111111110----------- ------------------------------- --------------------------------   |  ..1.........1............1.....   1....1.........................  |
   //   132 | --------- 11111111111111111110------------ ------------------------------- --------------------------------   |  ...............................   1..........1............1......  |
   //   133 | --------- 1111111111111111---0------------ ------------------------------- --------------------------------   |  ..1..1.........................   ...............................  |
   //   134 | --------- 1111111111111111110------------- ------------------------------- --------------------------------   |  ..1..1..................1......   1..........1...................  |
   //   135 | --------- 111111111111111110-------------- ------------------------------- --------------------------------   |  ...............................   1......................1.......  |
   //   136 | --------- 1111111111111111-0-------------- ------------------------------- --------------------------------   |  ..1..1.....1...................   ...............................  |
   //   137 | --------- 11111111111111110--------------- ------------------------------- --------------------------------   |  ..1..1.....1...........1.......   1..............................  |
   //   138 | --------- 1111111111111110---------------- ------------------------------- --------------------------------   |  ...............................   .1..1.....1...........1........  |
   //   139 | --------- ---------------0---------------- ------------------------------- --------------------------------   |  1..............................   ...............................  |
   //   140 | --------- 111111111111110----------------- ------------------------------- --------------------------------   |  1.....................1........   .1..1.....1....................  |
   //   141 | --------- 11111111111110------------------ ------------------------------- --------------------------------   |  ...............................   .1..1................1.........  |
   //   142 | --------- 111111111111-0------------------ ------------------------------- --------------------------------   |  1.........1....................   ...............................  |
   //   143 | --------- 1111111111110------------------- ------------------------------- --------------------------------   |  1.........1..........1.........   .1..1..........................  |
   //   144 | --------- 111111111110-------------------- ------------------------------- --------------------------------   |  ...............................   .1.......1..........1..........  |
   //   145 | --------- 11111111---0-------------------- ------------------------------- --------------------------------   |  1...1..........................   ...............................  |
   //   146 | --------- 11111111110--------------------- ------------------------------- --------------------------------   |  1...1...............1..........   .1.......1.....................  |
   //   147 | --------- 1111111110---------------------- ------------------------------- --------------------------------   |  ...............................   .1.................1...........  |
   //   148 | --------- 11111111-0---------------------- ------------------------------- --------------------------------   |  1...1....1.....................   ...............................  |
   //   149 | --------- 111111110----------------------- ------------------------------- --------------------------------   |  1...1....1.........1...........   .1.............................  |
   //   150 | --------- 11111110------------------------ ------------------------------- --------------------------------   |  ...............................   ...1....1.........1............  |
   //   151 | --------- -------0------------------------ ------------------------------- --------------------------------   |  11.............................   ...............................  |
   //   152 | --------- 1111110------------------------- ------------------------------- --------------------------------   |  11................1............   ...1....1......................  |
   //   153 | --------- 111110-------------------------- ------------------------------- --------------------------------   |  ...............................   ...1.............1.............  |
   //   154 | --------- 1111-0-------------------------- ------------------------------- --------------------------------   |  11......1......................   ...............................  |
   //   155 | --------- 11110--------------------------- ------------------------------- --------------------------------   |  11......1........1.............   ...1...........................  |
   //   156 | --------- 1110---------------------------- ------------------------------- --------------------------------   |  ...............................   .......1........1..............  |
   //   157 | --------- ---0---------------------------- ------------------------------- --------------------------------   |  11.1...........................   ...............................  |
   //   158 | --------- 110----------------------------- ------------------------------- --------------------------------   |  11.1............1..............   .......1.......................  |
   //   159 | --------- 10------------------------------ ------------------------------- --------------------------------   |  ...............................   ...............1...............  |
   //   160 | --------- -0------------------------------ ------------------------------- --------------------------------   |  11.1...1.......................   ...............................  |
   //   161 | --------- 0------------------------------- ------------------------------- --------------------------------   |  11.1...1.......1...............   ...............................  |
   //      *=====================================================================================================================================================================================*
   //
   // Table LRU_SET_RESET_VEC Signal Assignments for Product Terms
   assign LRU_SET_RESET_VEC_PT[1] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21], entry_match_q[22], entry_match_q[23], entry_match_q[24], entry_match_q[25], entry_match_q[26], entry_match_q[27], entry_match_q[28], entry_match_q[29], entry_match_q[30], entry_match_q[31]}) == {55'b0011111111111111111111111111111111100000000000000000000, 12'b000000000001});
   assign LRU_SET_RESET_VEC_PT[2] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21], entry_match_q[22], entry_match_q[23], entry_match_q[24], entry_match_q[25], entry_match_q[26], entry_match_q[27], entry_match_q[28], entry_match_q[29], entry_match_q[30]}) == 66'b001111111111111111111111111111111110000000000000000000000000000001);
   assign LRU_SET_RESET_VEC_PT[3] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21], entry_match_q[22], entry_match_q[23], entry_match_q[24], entry_match_q[25], entry_match_q[26], entry_match_q[27], entry_match_q[28], entry_match_q[29], entry_match_q[30]}) == {55'b0011111111111111111111111111111111000000000000000000000, 10'b0000000001});
   assign LRU_SET_RESET_VEC_PT[4] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21], entry_match_q[22], entry_match_q[23], entry_match_q[24], entry_match_q[25], entry_match_q[26], entry_match_q[27], entry_match_q[28], entry_match_q[29]}) == {55'b0011111111111111111111111111111111100000000000000000000, 10'b0000000001});
   assign LRU_SET_RESET_VEC_PT[5] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21], entry_match_q[22], entry_match_q[23], entry_match_q[24], entry_match_q[25], entry_match_q[26], entry_match_q[27], entry_match_q[29]}) == 62'b00111111111111111111111111111111100000000000000000000000000001);
   assign LRU_SET_RESET_VEC_PT[6] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21], entry_match_q[22], entry_match_q[23], entry_match_q[24], entry_match_q[25], entry_match_q[26], entry_match_q[27], entry_match_q[28]}) == 64'b0011111111111111111111111111111111100000000000000000000000000001);
   assign LRU_SET_RESET_VEC_PT[7] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21], entry_match_q[22], entry_match_q[23], entry_match_q[24], entry_match_q[25], entry_match_q[26], entry_match_q[27]}) == {55'b0011111111111111111111111111111111100000000000000000000, 8'b00000001});
   assign LRU_SET_RESET_VEC_PT[8] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21], entry_match_q[22], entry_match_q[23], entry_match_q[27]}) == 56'b00111111111111111111111111111110000000000000000000000001);
   assign LRU_SET_RESET_VEC_PT[9] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21], entry_match_q[22], entry_match_q[23], entry_match_q[24], entry_match_q[25], entry_match_q[26]}) == 62'b00111111111111111111111111111111111000000000000000000000000001);
   assign LRU_SET_RESET_VEC_PT[10] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21], entry_match_q[22], entry_match_q[23], entry_match_q[24], entry_match_q[25]}) == {55'b0011111111111111111111111111111111100000000000000000000, 6'b000001});
   assign LRU_SET_RESET_VEC_PT[11] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21], entry_match_q[22], entry_match_q[23], entry_match_q[25]}) == 60'b001111111111111111111111111111111110000000000000000000000001);
   assign LRU_SET_RESET_VEC_PT[12] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21], entry_match_q[22], entry_match_q[23], entry_match_q[24]}) == 60'b001111111111111111111111111111111110000000000000000000000001);
   assign LRU_SET_RESET_VEC_PT[13] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21], entry_match_q[22], entry_match_q[23]}) == {55'b0011111111111111111111111111111111100000000000000000000, 4'b0001});
   assign LRU_SET_RESET_VEC_PT[14] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[23]}) == 44'b00111111111111111111111111100000000000000001);
   assign LRU_SET_RESET_VEC_PT[15] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21], entry_match_q[22]}) == 58'b0011111111111111111111111111111111100000000000000000000001);
   assign LRU_SET_RESET_VEC_PT[16] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20], entry_match_q[21]}) == {55'b0011111111111111111111111111111111100000000000000000000, 2'b01});
   assign LRU_SET_RESET_VEC_PT[17] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[21]}) == 56'b00111111111111111111111111111111111000000000000000000001);
   assign LRU_SET_RESET_VEC_PT[18] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19], entry_match_q[20]}) == 56'b00111111111111111111111111111111111000000000000000000001);
   assign LRU_SET_RESET_VEC_PT[19] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18], entry_match_q[19]}) == 55'b0011111111111111111111111111111111100000000000000000001);
   assign LRU_SET_RESET_VEC_PT[20] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[19]}) == 52'b0011111111111111111111111111111111100000000000000001);
   assign LRU_SET_RESET_VEC_PT[21] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17], entry_match_q[18]}) == 54'b001111111111111111111111111111111110000000000000000001);
   assign LRU_SET_RESET_VEC_PT[22] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16], entry_match_q[17]}) == 53'b00111111111111111111111111111111111000000000000000001);
   assign LRU_SET_RESET_VEC_PT[23] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[17]}) == 52'b0011111111111111111111111111111111100000000000000001);
   assign LRU_SET_RESET_VEC_PT[24] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16]}) == 52'b0011111111111111111111111111111111100000000000000001);
   assign LRU_SET_RESET_VEC_PT[25] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15], entry_match_q[16]}) == 36'b001111111111111111100000000000000001);
   assign LRU_SET_RESET_VEC_PT[26] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14], entry_match_q[15]}) == 51'b001111111111111111111111111111111110000000000000001);
   assign LRU_SET_RESET_VEC_PT[27] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_match_q[15]}) == 20'b00111111111111111111);
   assign LRU_SET_RESET_VEC_PT[28] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13], entry_match_q[14]}) == 50'b00111111111111111111111111111111111000000000000001);
   assign LRU_SET_RESET_VEC_PT[29] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12], entry_match_q[13]}) == 49'b0011111111111111111111111111111111100000000000001);
   assign LRU_SET_RESET_VEC_PT[30] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[13]}) == 48'b001111111111111111111111111111111110000000000001);
   assign LRU_SET_RESET_VEC_PT[31] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11], entry_match_q[12]}) == 48'b001111111111111111111111111111111110000000000001);
   assign LRU_SET_RESET_VEC_PT[32] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10], entry_match_q[11]}) == 47'b00111111111111111111111111111111111000000000001);
   assign LRU_SET_RESET_VEC_PT[33] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[11]}) == 44'b00111111111111111111111111111111111000000001);
   assign LRU_SET_RESET_VEC_PT[34] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9], entry_match_q[10]}) == 46'b0011111111111111111111111111111111100000000001);
   assign LRU_SET_RESET_VEC_PT[35] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8], entry_match_q[9]}) == 45'b001111111111111111111111111111111110000000001);
   assign LRU_SET_RESET_VEC_PT[36] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[9]}) == 44'b00111111111111111111111111111111111000000001);
   assign LRU_SET_RESET_VEC_PT[37] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8]}) == 44'b00111111111111111111111111111111111000000001);
   assign LRU_SET_RESET_VEC_PT[38] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7], entry_match_q[8]}) == 36'b001111111111111111111111111000000001);
   assign LRU_SET_RESET_VEC_PT[39] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6], entry_match_q[7]}) == 43'b0011111111111111111111111111111111100000001);
   assign LRU_SET_RESET_VEC_PT[40] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[7]}) == 36'b001111111111111111111111111111111111);
   assign LRU_SET_RESET_VEC_PT[41] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5], entry_match_q[6]}) == 42'b001111111111111111111111111111111110000001);
   assign LRU_SET_RESET_VEC_PT[42] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4], entry_match_q[5]}) == 41'b00111111111111111111111111111111111000001);
   assign LRU_SET_RESET_VEC_PT[43] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[5]}) == 40'b0011111111111111111111111111111111100001);
   assign LRU_SET_RESET_VEC_PT[44] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4]}) == 40'b0011111111111111111111111111111111100001);
   assign LRU_SET_RESET_VEC_PT[45] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3], entry_match_q[4]}) == 36'b001111111111111111111111111111100001);
   assign LRU_SET_RESET_VEC_PT[46] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2], entry_match_q[3]}) == 39'b001111111111111111111111111111111110001);
   assign LRU_SET_RESET_VEC_PT[47] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[3]}) == 36'b001111111111111111111111111111111111);
   assign LRU_SET_RESET_VEC_PT[48] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2]}) == 38'b00111111111111111111111111111111111001);
   assign LRU_SET_RESET_VEC_PT[49] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1], entry_match_q[2]}) == 36'b001111111111111111111111111111111001);
   assign LRU_SET_RESET_VEC_PT[50] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0], entry_match_q[1]}) == 36'b001111111111111111111111111111111101);
   assign LRU_SET_RESET_VEC_PT[51] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[1]}) == 36'b001111111111111111111111111111111111);
   assign LRU_SET_RESET_VEC_PT[52] = (({lru_update_event_q[5], lru_update_event_q[6], lru_update_event_q[7], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], entry_match_q[0]}) == 36'b001111111111111111111111111111111111);
   assign LRU_SET_RESET_VEC_PT[53] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], lru_q[1], lru_q[3], lru_q[7], lru_q[15], lru_q[31]}) == 37'b1111111111111111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[54] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[7], lru_q[15], lru_q[31]}) == 37'b1111111111111111111111111111111111111);
   assign LRU_SET_RESET_VEC_PT[55] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[7], lru_q[15], lru_q[30]}) == 37'b1111111111111111111111111111111111100);
   assign LRU_SET_RESET_VEC_PT[56] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[7], lru_q[15], lru_q[30]}) == 37'b1111111111111111111111111111111111101);
   assign LRU_SET_RESET_VEC_PT[57] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[7], lru_q[14], lru_q[29]}) == 37'b1111111111111111111111111111111111010);
   assign LRU_SET_RESET_VEC_PT[58] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[7], lru_q[14], lru_q[29]}) == 37'b1111111111111111111111111111111111011);
   assign LRU_SET_RESET_VEC_PT[59] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[7], lru_q[14], lru_q[28]}) == 37'b1111111111111111111111111111111111000);
   assign LRU_SET_RESET_VEC_PT[60] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[7], lru_q[14], lru_q[28]}) == 37'b1111111111111111111111111111111111001);
   assign LRU_SET_RESET_VEC_PT[61] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[6], lru_q[13], lru_q[27]}) == 37'b1111111111111111111111111111111110110);
   assign LRU_SET_RESET_VEC_PT[62] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[6], lru_q[13], lru_q[27]}) == 37'b1111111111111111111111111111111110111);
   assign LRU_SET_RESET_VEC_PT[63] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[6], lru_q[13], lru_q[26]}) == 37'b1111111111111111111111111111111110100);
   assign LRU_SET_RESET_VEC_PT[64] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[6], lru_q[13], lru_q[26]}) == 37'b1111111111111111111111111111111110101);
   assign LRU_SET_RESET_VEC_PT[65] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[6], lru_q[12], lru_q[25]}) == 37'b1111111111111111111111111111111110010);
   assign LRU_SET_RESET_VEC_PT[66] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[6], lru_q[12], lru_q[25]}) == 37'b1111111111111111111111111111111110011);
   assign LRU_SET_RESET_VEC_PT[67] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[6], lru_q[12], lru_q[24]}) == 37'b1111111111111111111111111111111110000);
   assign LRU_SET_RESET_VEC_PT[68] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[6], lru_q[12], lru_q[24]}) == 37'b1111111111111111111111111111111110001);
   assign LRU_SET_RESET_VEC_PT[69] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[5], lru_q[11], lru_q[23]}) == 37'b1111111111111111111111111111111101110);
   assign LRU_SET_RESET_VEC_PT[70] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[5], lru_q[11], lru_q[23]}) == 37'b1111111111111111111111111111111101111);
   assign LRU_SET_RESET_VEC_PT[71] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[5], lru_q[11], lru_q[22]}) == 37'b1111111111111111111111111111111101100);
   assign LRU_SET_RESET_VEC_PT[72] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[5], lru_q[11], lru_q[22]}) == 37'b1111111111111111111111111111111101101);
   assign LRU_SET_RESET_VEC_PT[73] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[5], lru_q[10], lru_q[21]}) == 37'b1111111111111111111111111111111101010);
   assign LRU_SET_RESET_VEC_PT[74] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[5], lru_q[10], lru_q[21]}) == 37'b1111111111111111111111111111111101011);
   assign LRU_SET_RESET_VEC_PT[75] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[5], lru_q[10], lru_q[20]}) == 37'b1111111111111111111111111111111101000);
   assign LRU_SET_RESET_VEC_PT[76] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[5], lru_q[10], lru_q[20]}) == 37'b1111111111111111111111111111111101001);
   assign LRU_SET_RESET_VEC_PT[77] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[4], lru_q[9], lru_q[19]}) == 37'b1111111111111111111111111111111100110);
   assign LRU_SET_RESET_VEC_PT[78] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[4], lru_q[9], lru_q[19]}) == 37'b1111111111111111111111111111111100111);
   assign LRU_SET_RESET_VEC_PT[79] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[4], lru_q[9], lru_q[18]}) == 37'b1111111111111111111111111111111100100);
   assign LRU_SET_RESET_VEC_PT[80] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[4], lru_q[9], lru_q[18]}) == 37'b1111111111111111111111111111111100101);
   assign LRU_SET_RESET_VEC_PT[81] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[4], lru_q[8], lru_q[17]}) == 37'b1111111111111111111111111111111100010);
   assign LRU_SET_RESET_VEC_PT[82] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[4], lru_q[8], lru_q[17]}) == 37'b1111111111111111111111111111111100011);
   assign LRU_SET_RESET_VEC_PT[83] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[4], lru_q[8], lru_q[16]}) == 37'b1111111111111111111111111111111100000);
   assign LRU_SET_RESET_VEC_PT[84] = (({lru_update_event_q[5], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[4], lru_q[8], lru_q[16]}) == 37'b1111111111111111111111111111111100001);
   assign LRU_SET_RESET_VEC_PT[85] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], lru_q[1], lru_q[3], lru_q[7], lru_q[15]}) == 35'b11111111111111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[86] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[7], lru_q[15]}) == 35'b11111111111111111111111111111111111);
   assign LRU_SET_RESET_VEC_PT[87] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[7], lru_q[14]}) == 35'b11111111111111111111111111111111100);
   assign LRU_SET_RESET_VEC_PT[88] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[7], lru_q[14]}) == 35'b11111111111111111111111111111111101);
   assign LRU_SET_RESET_VEC_PT[89] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[6], lru_q[13]}) == 35'b11111111111111111111111111111111010);
   assign LRU_SET_RESET_VEC_PT[90] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[6], lru_q[13]}) == 35'b11111111111111111111111111111111011);
   assign LRU_SET_RESET_VEC_PT[91] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[6], lru_q[12]}) == 35'b11111111111111111111111111111111000);
   assign LRU_SET_RESET_VEC_PT[92] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[6], lru_q[12]}) == 35'b11111111111111111111111111111111001);
   assign LRU_SET_RESET_VEC_PT[93] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[5], lru_q[11]}) == 35'b11111111111111111111111111111110110);
   assign LRU_SET_RESET_VEC_PT[94] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[5], lru_q[11]}) == 35'b11111111111111111111111111111110111);
   assign LRU_SET_RESET_VEC_PT[95] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[5], lru_q[10]}) == 35'b11111111111111111111111111111110100);
   assign LRU_SET_RESET_VEC_PT[96] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[5], lru_q[10]}) == 35'b11111111111111111111111111111110101);
   assign LRU_SET_RESET_VEC_PT[97] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[4], lru_q[9]}) == 35'b11111111111111111111111111111110010);
   assign LRU_SET_RESET_VEC_PT[98] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[4], lru_q[9]}) == 35'b11111111111111111111111111111110011);
   assign LRU_SET_RESET_VEC_PT[99] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[4], lru_q[8]}) == 35'b11111111111111111111111111111110000);
   assign LRU_SET_RESET_VEC_PT[100] = (({lru_update_event_q[5], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[4], lru_q[8]}) == 35'b11111111111111111111111111111110001);
   assign LRU_SET_RESET_VEC_PT[101] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], lru_q[1], lru_q[3], lru_q[7]}) == 32'b11111111111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[102] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[7]}) == 32'b11111111111111111111111111111111);
   assign LRU_SET_RESET_VEC_PT[103] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[6]}) == 32'b11111111111111111111111111111100);
   assign LRU_SET_RESET_VEC_PT[104] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3], lru_q[6]}) == 32'b11111111111111111111111111111101);
   assign LRU_SET_RESET_VEC_PT[105] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[5]}) == 32'b11111111111111111111111111111010);
   assign LRU_SET_RESET_VEC_PT[106] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[5]}) == 32'b11111111111111111111111111111011);
   assign LRU_SET_RESET_VEC_PT[107] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[4]}) == 32'b11111111111111111111111111111000);
   assign LRU_SET_RESET_VEC_PT[108] = (({lru_update_event_q[5], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2], lru_q[4]}) == 32'b11111111111111111111111111111001);
   assign LRU_SET_RESET_VEC_PT[109] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], lru_q[1], lru_q[3]}) == 27'b111111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[110] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[3]}) == 27'b111111111111111111111111111);
   assign LRU_SET_RESET_VEC_PT[111] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2]}) == 27'b111111111111111111111111100);
   assign LRU_SET_RESET_VEC_PT[112] = (({lru_update_event_q[5], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1], lru_q[2]}) == 27'b111111111111111111111111101);
   assign LRU_SET_RESET_VEC_PT[113] = (({lru_update_event_q[5], entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], lru_q[1]}) == 18'b111111111111111110);
   assign LRU_SET_RESET_VEC_PT[114] = (({lru_update_event_q[5], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31], lru_q[1]}) == 18'b111111111111111111);
   assign LRU_SET_RESET_VEC_PT[115] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30], entry_valid_watermarked[31]}) == 32'b11111111111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[116] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29], entry_valid_watermarked[30]}) == 31'b1111111111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[117] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28], entry_valid_watermarked[29]}) == 30'b111111111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[118] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[29]}) == 29'b11111111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[119] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27], entry_valid_watermarked[28]}) == 29'b11111111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[120] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26], entry_valid_watermarked[27]}) == 28'b1111111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[121] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[27]}) == 25'b1111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[122] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25], entry_valid_watermarked[26]}) == 27'b111111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[123] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24], entry_valid_watermarked[25]}) == 26'b11111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[124] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[25]}) == 25'b1111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[125] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23], entry_valid_watermarked[24]}) == 25'b1111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[126] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22], entry_valid_watermarked[23]}) == 24'b111111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[127] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[23]}) == 17'b11111111111111110);
   assign LRU_SET_RESET_VEC_PT[128] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21], entry_valid_watermarked[22]}) == 23'b11111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[129] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20], entry_valid_watermarked[21]}) == 22'b1111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[130] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[21]}) == 21'b111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[131] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19], entry_valid_watermarked[20]}) == 21'b111111111111111111110);
   assign LRU_SET_RESET_VEC_PT[132] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18], entry_valid_watermarked[19]}) == 20'b11111111111111111110);
   assign LRU_SET_RESET_VEC_PT[133] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[19]}) == 17'b11111111111111110);
   assign LRU_SET_RESET_VEC_PT[134] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17], entry_valid_watermarked[18]}) == 19'b1111111111111111110);
   assign LRU_SET_RESET_VEC_PT[135] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16], entry_valid_watermarked[17]}) == 18'b111111111111111110);
   assign LRU_SET_RESET_VEC_PT[136] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[17]}) == 17'b11111111111111110);
   assign LRU_SET_RESET_VEC_PT[137] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15], entry_valid_watermarked[16]}) == 17'b11111111111111110);
   assign LRU_SET_RESET_VEC_PT[138] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14], entry_valid_watermarked[15]}) == 16'b1111111111111110);
   assign LRU_SET_RESET_VEC_PT[139] = ((entry_valid_watermarked[15]) == 1'b0);
   assign LRU_SET_RESET_VEC_PT[140] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13], entry_valid_watermarked[14]}) == 15'b111111111111110);
   assign LRU_SET_RESET_VEC_PT[141] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12], entry_valid_watermarked[13]}) == 14'b11111111111110);
   assign LRU_SET_RESET_VEC_PT[142] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[13]}) == 13'b1111111111110);
   assign LRU_SET_RESET_VEC_PT[143] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11], entry_valid_watermarked[12]}) == 13'b1111111111110);
   assign LRU_SET_RESET_VEC_PT[144] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10], entry_valid_watermarked[11]}) == 12'b111111111110);
   assign LRU_SET_RESET_VEC_PT[145] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[11]}) == 9'b111111110);
   assign LRU_SET_RESET_VEC_PT[146] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9], entry_valid_watermarked[10]}) == 11'b11111111110);
   assign LRU_SET_RESET_VEC_PT[147] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8], entry_valid_watermarked[9]}) == 10'b1111111110);
   assign LRU_SET_RESET_VEC_PT[148] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[9]}) == 9'b111111110);
   assign LRU_SET_RESET_VEC_PT[149] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7], entry_valid_watermarked[8]}) == 9'b111111110);
   assign LRU_SET_RESET_VEC_PT[150] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6], entry_valid_watermarked[7]}) == 8'b11111110);
   assign LRU_SET_RESET_VEC_PT[151] = ((entry_valid_watermarked[7]) == 1'b0);
   assign LRU_SET_RESET_VEC_PT[152] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5], entry_valid_watermarked[6]}) == 7'b1111110);
   assign LRU_SET_RESET_VEC_PT[153] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4], entry_valid_watermarked[5]}) == 6'b111110);
   assign LRU_SET_RESET_VEC_PT[154] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[5]}) == 5'b11110);
   assign LRU_SET_RESET_VEC_PT[155] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3], entry_valid_watermarked[4]}) == 5'b11110);
   assign LRU_SET_RESET_VEC_PT[156] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2], entry_valid_watermarked[3]}) == 4'b1110);
   assign LRU_SET_RESET_VEC_PT[157] = ((entry_valid_watermarked[3]) == 1'b0);
   assign LRU_SET_RESET_VEC_PT[158] = (({entry_valid_watermarked[0], entry_valid_watermarked[1], entry_valid_watermarked[2]}) == 3'b110);
   assign LRU_SET_RESET_VEC_PT[159] = (({entry_valid_watermarked[0], entry_valid_watermarked[1]}) == 2'b10);
   assign LRU_SET_RESET_VEC_PT[160] = ((entry_valid_watermarked[1]) == 1'b0);
   assign LRU_SET_RESET_VEC_PT[161] = ((entry_valid_watermarked[0]) == 1'b0);
   // Table LRU_SET_RESET_VEC Signal Assignments for Outputs
   assign lru_reset_vec[1] = (LRU_SET_RESET_VEC_PT[1] | LRU_SET_RESET_VEC_PT[2] | LRU_SET_RESET_VEC_PT[4] | LRU_SET_RESET_VEC_PT[6] | LRU_SET_RESET_VEC_PT[7] | LRU_SET_RESET_VEC_PT[9] | LRU_SET_RESET_VEC_PT[10] | LRU_SET_RESET_VEC_PT[12] | LRU_SET_RESET_VEC_PT[13] | LRU_SET_RESET_VEC_PT[15] | LRU_SET_RESET_VEC_PT[16] | LRU_SET_RESET_VEC_PT[18] | LRU_SET_RESET_VEC_PT[19] | LRU_SET_RESET_VEC_PT[21] | LRU_SET_RESET_VEC_PT[22] | LRU_SET_RESET_VEC_PT[25] | LRU_SET_RESET_VEC_PT[114] | LRU_SET_RESET_VEC_PT[139] | LRU_SET_RESET_VEC_PT[140] | LRU_SET_RESET_VEC_PT[142] | LRU_SET_RESET_VEC_PT[143] | LRU_SET_RESET_VEC_PT[145] | LRU_SET_RESET_VEC_PT[146] | LRU_SET_RESET_VEC_PT[148] | LRU_SET_RESET_VEC_PT[149] | LRU_SET_RESET_VEC_PT[151] | LRU_SET_RESET_VEC_PT[152] | LRU_SET_RESET_VEC_PT[154] | LRU_SET_RESET_VEC_PT[155] | LRU_SET_RESET_VEC_PT[157] | LRU_SET_RESET_VEC_PT[158] | LRU_SET_RESET_VEC_PT[160] | LRU_SET_RESET_VEC_PT[161]);
   assign lru_reset_vec[2] = (LRU_SET_RESET_VEC_PT[26] | LRU_SET_RESET_VEC_PT[28] | LRU_SET_RESET_VEC_PT[29] | LRU_SET_RESET_VEC_PT[31] | LRU_SET_RESET_VEC_PT[32] | LRU_SET_RESET_VEC_PT[34] | LRU_SET_RESET_VEC_PT[35] | LRU_SET_RESET_VEC_PT[38] | LRU_SET_RESET_VEC_PT[112] | LRU_SET_RESET_VEC_PT[151] | LRU_SET_RESET_VEC_PT[152] | LRU_SET_RESET_VEC_PT[154] | LRU_SET_RESET_VEC_PT[155] | LRU_SET_RESET_VEC_PT[157] | LRU_SET_RESET_VEC_PT[158] | LRU_SET_RESET_VEC_PT[160] | LRU_SET_RESET_VEC_PT[161]);
   assign lru_reset_vec[3] = (LRU_SET_RESET_VEC_PT[1] | LRU_SET_RESET_VEC_PT[2] | LRU_SET_RESET_VEC_PT[4] | LRU_SET_RESET_VEC_PT[6] | LRU_SET_RESET_VEC_PT[7] | LRU_SET_RESET_VEC_PT[9] | LRU_SET_RESET_VEC_PT[10] | LRU_SET_RESET_VEC_PT[12] | LRU_SET_RESET_VEC_PT[110] | LRU_SET_RESET_VEC_PT[127] | LRU_SET_RESET_VEC_PT[128] | LRU_SET_RESET_VEC_PT[130] | LRU_SET_RESET_VEC_PT[131] | LRU_SET_RESET_VEC_PT[133] | LRU_SET_RESET_VEC_PT[134] | LRU_SET_RESET_VEC_PT[136] | LRU_SET_RESET_VEC_PT[137]);
   assign lru_reset_vec[4] = (LRU_SET_RESET_VEC_PT[39] | LRU_SET_RESET_VEC_PT[41] | LRU_SET_RESET_VEC_PT[42] | LRU_SET_RESET_VEC_PT[45] | LRU_SET_RESET_VEC_PT[108] | LRU_SET_RESET_VEC_PT[157] | LRU_SET_RESET_VEC_PT[158] | LRU_SET_RESET_VEC_PT[160] | LRU_SET_RESET_VEC_PT[161]);
   assign lru_reset_vec[5] = (LRU_SET_RESET_VEC_PT[26] | LRU_SET_RESET_VEC_PT[28] | LRU_SET_RESET_VEC_PT[29] | LRU_SET_RESET_VEC_PT[31] | LRU_SET_RESET_VEC_PT[106] | LRU_SET_RESET_VEC_PT[145] | LRU_SET_RESET_VEC_PT[146] | LRU_SET_RESET_VEC_PT[148] | LRU_SET_RESET_VEC_PT[149]);
   assign lru_reset_vec[6] = (LRU_SET_RESET_VEC_PT[13] | LRU_SET_RESET_VEC_PT[15] | LRU_SET_RESET_VEC_PT[16] | LRU_SET_RESET_VEC_PT[18] | LRU_SET_RESET_VEC_PT[104] | LRU_SET_RESET_VEC_PT[133] | LRU_SET_RESET_VEC_PT[134] | LRU_SET_RESET_VEC_PT[136] | LRU_SET_RESET_VEC_PT[137]);
   assign lru_reset_vec[7] = (LRU_SET_RESET_VEC_PT[1] | LRU_SET_RESET_VEC_PT[2] | LRU_SET_RESET_VEC_PT[4] | LRU_SET_RESET_VEC_PT[6] | LRU_SET_RESET_VEC_PT[102] | LRU_SET_RESET_VEC_PT[121] | LRU_SET_RESET_VEC_PT[122] | LRU_SET_RESET_VEC_PT[124] | LRU_SET_RESET_VEC_PT[125]);
   assign lru_reset_vec[8] = (LRU_SET_RESET_VEC_PT[46] | LRU_SET_RESET_VEC_PT[49] | LRU_SET_RESET_VEC_PT[100] | LRU_SET_RESET_VEC_PT[160] | LRU_SET_RESET_VEC_PT[161]);
   assign lru_reset_vec[9] = (LRU_SET_RESET_VEC_PT[39] | LRU_SET_RESET_VEC_PT[41] | LRU_SET_RESET_VEC_PT[98] | LRU_SET_RESET_VEC_PT[154] | LRU_SET_RESET_VEC_PT[155]);
   assign lru_reset_vec[10] = (LRU_SET_RESET_VEC_PT[32] | LRU_SET_RESET_VEC_PT[34] | LRU_SET_RESET_VEC_PT[96] | LRU_SET_RESET_VEC_PT[148] | LRU_SET_RESET_VEC_PT[149]);
   assign lru_reset_vec[11] = (LRU_SET_RESET_VEC_PT[26] | LRU_SET_RESET_VEC_PT[28] | LRU_SET_RESET_VEC_PT[94] | LRU_SET_RESET_VEC_PT[142] | LRU_SET_RESET_VEC_PT[143]);
   assign lru_reset_vec[12] = (LRU_SET_RESET_VEC_PT[19] | LRU_SET_RESET_VEC_PT[21] | LRU_SET_RESET_VEC_PT[92] | LRU_SET_RESET_VEC_PT[136] | LRU_SET_RESET_VEC_PT[137]);
   assign lru_reset_vec[13] = (LRU_SET_RESET_VEC_PT[13] | LRU_SET_RESET_VEC_PT[15] | LRU_SET_RESET_VEC_PT[90] | LRU_SET_RESET_VEC_PT[130] | LRU_SET_RESET_VEC_PT[131]);
   assign lru_reset_vec[14] = (LRU_SET_RESET_VEC_PT[7] | LRU_SET_RESET_VEC_PT[9] | LRU_SET_RESET_VEC_PT[88] | LRU_SET_RESET_VEC_PT[124] | LRU_SET_RESET_VEC_PT[125]);
   assign lru_reset_vec[15] = (LRU_SET_RESET_VEC_PT[1] | LRU_SET_RESET_VEC_PT[2] | LRU_SET_RESET_VEC_PT[86] | LRU_SET_RESET_VEC_PT[118] | LRU_SET_RESET_VEC_PT[119]);
   assign lru_reset_vec[16] = (LRU_SET_RESET_VEC_PT[50] | LRU_SET_RESET_VEC_PT[84] | LRU_SET_RESET_VEC_PT[161]);
   assign lru_reset_vec[17] = (LRU_SET_RESET_VEC_PT[46] | LRU_SET_RESET_VEC_PT[82] | LRU_SET_RESET_VEC_PT[158]);
   assign lru_reset_vec[18] = (LRU_SET_RESET_VEC_PT[42] | LRU_SET_RESET_VEC_PT[80] | LRU_SET_RESET_VEC_PT[155]);
   assign lru_reset_vec[19] = (LRU_SET_RESET_VEC_PT[39] | LRU_SET_RESET_VEC_PT[78] | LRU_SET_RESET_VEC_PT[152]);
   assign lru_reset_vec[20] = (LRU_SET_RESET_VEC_PT[35] | LRU_SET_RESET_VEC_PT[76] | LRU_SET_RESET_VEC_PT[149]);
   assign lru_reset_vec[21] = (LRU_SET_RESET_VEC_PT[32] | LRU_SET_RESET_VEC_PT[74] | LRU_SET_RESET_VEC_PT[146]);
   assign lru_reset_vec[22] = (LRU_SET_RESET_VEC_PT[29] | LRU_SET_RESET_VEC_PT[72] | LRU_SET_RESET_VEC_PT[143]);
   assign lru_reset_vec[23] = (LRU_SET_RESET_VEC_PT[26] | LRU_SET_RESET_VEC_PT[70] | LRU_SET_RESET_VEC_PT[140]);
   assign lru_reset_vec[24] = (LRU_SET_RESET_VEC_PT[22] | LRU_SET_RESET_VEC_PT[68] | LRU_SET_RESET_VEC_PT[137]);
   assign lru_reset_vec[25] = (LRU_SET_RESET_VEC_PT[19] | LRU_SET_RESET_VEC_PT[66] | LRU_SET_RESET_VEC_PT[134]);
   assign lru_reset_vec[26] = (LRU_SET_RESET_VEC_PT[16] | LRU_SET_RESET_VEC_PT[64] | LRU_SET_RESET_VEC_PT[131]);
   assign lru_reset_vec[27] = (LRU_SET_RESET_VEC_PT[13] | LRU_SET_RESET_VEC_PT[62] | LRU_SET_RESET_VEC_PT[128]);
   assign lru_reset_vec[28] = (LRU_SET_RESET_VEC_PT[10] | LRU_SET_RESET_VEC_PT[60] | LRU_SET_RESET_VEC_PT[125]);
   assign lru_reset_vec[29] = (LRU_SET_RESET_VEC_PT[7] | LRU_SET_RESET_VEC_PT[58] | LRU_SET_RESET_VEC_PT[122]);
   assign lru_reset_vec[30] = (LRU_SET_RESET_VEC_PT[4] | LRU_SET_RESET_VEC_PT[56] | LRU_SET_RESET_VEC_PT[119]);
   assign lru_reset_vec[31] = (LRU_SET_RESET_VEC_PT[1] | LRU_SET_RESET_VEC_PT[54] | LRU_SET_RESET_VEC_PT[116]);
   assign lru_set_vec[1] = (LRU_SET_RESET_VEC_PT[27] | LRU_SET_RESET_VEC_PT[28] | LRU_SET_RESET_VEC_PT[30] | LRU_SET_RESET_VEC_PT[31] | LRU_SET_RESET_VEC_PT[33] | LRU_SET_RESET_VEC_PT[34] | LRU_SET_RESET_VEC_PT[36] | LRU_SET_RESET_VEC_PT[37] | LRU_SET_RESET_VEC_PT[40] | LRU_SET_RESET_VEC_PT[41] | LRU_SET_RESET_VEC_PT[43] | LRU_SET_RESET_VEC_PT[44] | LRU_SET_RESET_VEC_PT[47] | LRU_SET_RESET_VEC_PT[48] | LRU_SET_RESET_VEC_PT[51] | LRU_SET_RESET_VEC_PT[52] | LRU_SET_RESET_VEC_PT[113] | LRU_SET_RESET_VEC_PT[115] | LRU_SET_RESET_VEC_PT[116] | LRU_SET_RESET_VEC_PT[117] | LRU_SET_RESET_VEC_PT[119] | LRU_SET_RESET_VEC_PT[120] | LRU_SET_RESET_VEC_PT[122] | LRU_SET_RESET_VEC_PT[123] | LRU_SET_RESET_VEC_PT[125] | LRU_SET_RESET_VEC_PT[126] | LRU_SET_RESET_VEC_PT[128] | LRU_SET_RESET_VEC_PT[129] | LRU_SET_RESET_VEC_PT[131] | LRU_SET_RESET_VEC_PT[132] | LRU_SET_RESET_VEC_PT[134] | LRU_SET_RESET_VEC_PT[135] | LRU_SET_RESET_VEC_PT[137]);
   assign lru_set_vec[2] = (LRU_SET_RESET_VEC_PT[40] | LRU_SET_RESET_VEC_PT[41] | LRU_SET_RESET_VEC_PT[43] | LRU_SET_RESET_VEC_PT[44] | LRU_SET_RESET_VEC_PT[47] | LRU_SET_RESET_VEC_PT[48] | LRU_SET_RESET_VEC_PT[51] | LRU_SET_RESET_VEC_PT[52] | LRU_SET_RESET_VEC_PT[111] | LRU_SET_RESET_VEC_PT[138] | LRU_SET_RESET_VEC_PT[140] | LRU_SET_RESET_VEC_PT[141] | LRU_SET_RESET_VEC_PT[143] | LRU_SET_RESET_VEC_PT[144] | LRU_SET_RESET_VEC_PT[146] | LRU_SET_RESET_VEC_PT[147] | LRU_SET_RESET_VEC_PT[149]);
   assign lru_set_vec[3] = (LRU_SET_RESET_VEC_PT[14] | LRU_SET_RESET_VEC_PT[15] | LRU_SET_RESET_VEC_PT[17] | LRU_SET_RESET_VEC_PT[18] | LRU_SET_RESET_VEC_PT[20] | LRU_SET_RESET_VEC_PT[21] | LRU_SET_RESET_VEC_PT[23] | LRU_SET_RESET_VEC_PT[24] | LRU_SET_RESET_VEC_PT[109] | LRU_SET_RESET_VEC_PT[115] | LRU_SET_RESET_VEC_PT[116] | LRU_SET_RESET_VEC_PT[117] | LRU_SET_RESET_VEC_PT[119] | LRU_SET_RESET_VEC_PT[120] | LRU_SET_RESET_VEC_PT[122] | LRU_SET_RESET_VEC_PT[123] | LRU_SET_RESET_VEC_PT[125]);
   assign lru_set_vec[4] = (LRU_SET_RESET_VEC_PT[47] | LRU_SET_RESET_VEC_PT[48] | LRU_SET_RESET_VEC_PT[51] | LRU_SET_RESET_VEC_PT[52] | LRU_SET_RESET_VEC_PT[107] | LRU_SET_RESET_VEC_PT[150] | LRU_SET_RESET_VEC_PT[152] | LRU_SET_RESET_VEC_PT[153] | LRU_SET_RESET_VEC_PT[155]);
   assign lru_set_vec[5] = (LRU_SET_RESET_VEC_PT[33] | LRU_SET_RESET_VEC_PT[34] | LRU_SET_RESET_VEC_PT[36] | LRU_SET_RESET_VEC_PT[37] | LRU_SET_RESET_VEC_PT[105] | LRU_SET_RESET_VEC_PT[138] | LRU_SET_RESET_VEC_PT[140] | LRU_SET_RESET_VEC_PT[141] | LRU_SET_RESET_VEC_PT[143]);
   assign lru_set_vec[6] = (LRU_SET_RESET_VEC_PT[20] | LRU_SET_RESET_VEC_PT[21] | LRU_SET_RESET_VEC_PT[23] | LRU_SET_RESET_VEC_PT[24] | LRU_SET_RESET_VEC_PT[103] | LRU_SET_RESET_VEC_PT[126] | LRU_SET_RESET_VEC_PT[128] | LRU_SET_RESET_VEC_PT[129] | LRU_SET_RESET_VEC_PT[131]);
   assign lru_set_vec[7] = (LRU_SET_RESET_VEC_PT[8] | LRU_SET_RESET_VEC_PT[9] | LRU_SET_RESET_VEC_PT[11] | LRU_SET_RESET_VEC_PT[12] | LRU_SET_RESET_VEC_PT[101] | LRU_SET_RESET_VEC_PT[115] | LRU_SET_RESET_VEC_PT[116] | LRU_SET_RESET_VEC_PT[117] | LRU_SET_RESET_VEC_PT[119]);
   assign lru_set_vec[8] = (LRU_SET_RESET_VEC_PT[51] | LRU_SET_RESET_VEC_PT[52] | LRU_SET_RESET_VEC_PT[99] | LRU_SET_RESET_VEC_PT[156] | LRU_SET_RESET_VEC_PT[158]);
   assign lru_set_vec[9] = (LRU_SET_RESET_VEC_PT[43] | LRU_SET_RESET_VEC_PT[44] | LRU_SET_RESET_VEC_PT[97] | LRU_SET_RESET_VEC_PT[150] | LRU_SET_RESET_VEC_PT[152]);
   assign lru_set_vec[10] = (LRU_SET_RESET_VEC_PT[36] | LRU_SET_RESET_VEC_PT[37] | LRU_SET_RESET_VEC_PT[95] | LRU_SET_RESET_VEC_PT[144] | LRU_SET_RESET_VEC_PT[146]);
   assign lru_set_vec[11] = (LRU_SET_RESET_VEC_PT[30] | LRU_SET_RESET_VEC_PT[31] | LRU_SET_RESET_VEC_PT[93] | LRU_SET_RESET_VEC_PT[138] | LRU_SET_RESET_VEC_PT[140]);
   assign lru_set_vec[12] = (LRU_SET_RESET_VEC_PT[23] | LRU_SET_RESET_VEC_PT[24] | LRU_SET_RESET_VEC_PT[91] | LRU_SET_RESET_VEC_PT[132] | LRU_SET_RESET_VEC_PT[134]);
   assign lru_set_vec[13] = (LRU_SET_RESET_VEC_PT[17] | LRU_SET_RESET_VEC_PT[18] | LRU_SET_RESET_VEC_PT[89] | LRU_SET_RESET_VEC_PT[126] | LRU_SET_RESET_VEC_PT[128]);
   assign lru_set_vec[14] = (LRU_SET_RESET_VEC_PT[11] | LRU_SET_RESET_VEC_PT[12] | LRU_SET_RESET_VEC_PT[87] | LRU_SET_RESET_VEC_PT[120] | LRU_SET_RESET_VEC_PT[122]);
   assign lru_set_vec[15] = (LRU_SET_RESET_VEC_PT[5] | LRU_SET_RESET_VEC_PT[6] | LRU_SET_RESET_VEC_PT[85] | LRU_SET_RESET_VEC_PT[115] | LRU_SET_RESET_VEC_PT[116]);
   assign lru_set_vec[16] = (LRU_SET_RESET_VEC_PT[52] | LRU_SET_RESET_VEC_PT[83] | LRU_SET_RESET_VEC_PT[159]);
   assign lru_set_vec[17] = (LRU_SET_RESET_VEC_PT[48] | LRU_SET_RESET_VEC_PT[81] | LRU_SET_RESET_VEC_PT[156]);
   assign lru_set_vec[18] = (LRU_SET_RESET_VEC_PT[44] | LRU_SET_RESET_VEC_PT[79] | LRU_SET_RESET_VEC_PT[153]);
   assign lru_set_vec[19] = (LRU_SET_RESET_VEC_PT[41] | LRU_SET_RESET_VEC_PT[77] | LRU_SET_RESET_VEC_PT[150]);
   assign lru_set_vec[20] = (LRU_SET_RESET_VEC_PT[37] | LRU_SET_RESET_VEC_PT[75] | LRU_SET_RESET_VEC_PT[147]);
   assign lru_set_vec[21] = (LRU_SET_RESET_VEC_PT[34] | LRU_SET_RESET_VEC_PT[73] | LRU_SET_RESET_VEC_PT[144]);
   assign lru_set_vec[22] = (LRU_SET_RESET_VEC_PT[31] | LRU_SET_RESET_VEC_PT[71] | LRU_SET_RESET_VEC_PT[141]);
   assign lru_set_vec[23] = (LRU_SET_RESET_VEC_PT[28] | LRU_SET_RESET_VEC_PT[69] | LRU_SET_RESET_VEC_PT[138]);
   assign lru_set_vec[24] = (LRU_SET_RESET_VEC_PT[24] | LRU_SET_RESET_VEC_PT[67] | LRU_SET_RESET_VEC_PT[135]);
   assign lru_set_vec[25] = (LRU_SET_RESET_VEC_PT[21] | LRU_SET_RESET_VEC_PT[65] | LRU_SET_RESET_VEC_PT[132]);
   assign lru_set_vec[26] = (LRU_SET_RESET_VEC_PT[18] | LRU_SET_RESET_VEC_PT[63] | LRU_SET_RESET_VEC_PT[129]);
   assign lru_set_vec[27] = (LRU_SET_RESET_VEC_PT[15] | LRU_SET_RESET_VEC_PT[61] | LRU_SET_RESET_VEC_PT[126]);
   assign lru_set_vec[28] = (LRU_SET_RESET_VEC_PT[12] | LRU_SET_RESET_VEC_PT[59] | LRU_SET_RESET_VEC_PT[123]);
   assign lru_set_vec[29] = (LRU_SET_RESET_VEC_PT[9] | LRU_SET_RESET_VEC_PT[57] | LRU_SET_RESET_VEC_PT[120]);
   assign lru_set_vec[30] = (LRU_SET_RESET_VEC_PT[6] | LRU_SET_RESET_VEC_PT[55] | LRU_SET_RESET_VEC_PT[117]);
   assign lru_set_vec[31] = (LRU_SET_RESET_VEC_PT[3] | LRU_SET_RESET_VEC_PT[53] | LRU_SET_RESET_VEC_PT[115]);

   // Encoder for the LRU selected entry
   //
   // Final Table Listing
   //      *INPUTS*=======================================*OUTPUTS*==========*
   //      |                                              |                  |
   //      | mmucr1_q                                     |  lru_way_encode  |
   //      | |         lru_eff                            |  |               |
   //      | |         |                                  |  |               |
   //      | |         |                                  |  |               |
   //      | |         |        1111111111222222222233    |  |               |
   //      | 012345678 1234567890123456789012345678901    |  01234           |
   //      *TYPE*=========================================+==================+
   //      | PPPPPPPPP PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP    |  PPPPP           |
   //      *POLARITY*------------------------------------>|  +++++           |
   //      *PHASE*--------------------------------------->|  TTTTT           |
   //      *OPTIMIZE*------------------------------------>|   AAAAA            |
   //      *TERMS*========================================+==================+
   //    1 | --------- 1-1---1-------1---------------1    |  ....1           |
   //    2 | --------- 1-1---1-------0--------------1-    |  ....1           |
   //    3 | --------- 1-1---0------1--------------1--    |  ....1           |
   //    4 | --------- 1-1---0------0-------------1---    |  ....1           |
   //    5 | --------- 1-0--1------1-------------1----    |  ....1           |
   //    6 | --------- 1-0--1------0------------1-----    |  ....1           |
   //    7 | --------- 1-0--0-----1------------1------    |  ....1           |
   //    8 | --------- 1-0--0-----0-----------1-------    |  ....1           |
   //    9 | --------- 01--1-----1-----------1--------    |  ....1           |
   //   10 | --------- 01--1-----0----------1---------    |  ....1           |
   //   11 | --------- 01--0----1----------1----------    |  ....1           |
   //   12 | --------- 01--0----0---------1-----------    |  ....1           |
   //   13 | --------- 00-1----1---------1------------    |  ....1           |
   //   14 | --------- 00-1----0--------1-------------    |  ....1           |
   //   15 | --------- 00-0---1--------1--------------    |  ....1           |
   //   16 | --------- 00-0---0-------1---------------    |  ....1           |
   //   17 | --------- 1-1---1-------1----------------    |  ...1.           |
   //   18 | --------- 1-1---0------1-----------------    |  ...1.           |
   //   19 | --------- 1-0--1------1------------------    |  ...1.           |
   //   20 | --------- 1-0--0-----1-------------------    |  ...1.           |
   //   21 | --------- 01--1-----1--------------------    |  ...1.           |
   //   22 | --------- 01--0----1---------------------    |  ...1.           |
   //   23 | --------- 00-1----1----------------------    |  ...1.           |
   //   24 | --------- 00-0---1-----------------------    |  ...1.           |
   //   25 | --------- 1-1---1------------------------    |  ..1..           |
   //   26 | --------- 1-0--1-------------------------    |  ..1..           |
   //   27 | --------- 01--1--------------------------    |  ..1..           |
   //   28 | --------- 00-1---------------------------    |  ..1..           |
   //   29 | --------- 1-1----------------------------    |  .1...           |
   //   30 | --------- 01-----------------------------    |  .1...           |
   //   31 | --------- 1------------------------------    |  1....           |
   //      *=================================================================*
   //
   // Table LRU_WAY_ENCODE Signal Assignments for Product Terms
   assign LRU_WAY_ENCODE_PT[1] = (({lru_eff[1], lru_eff[3], lru_eff[7], lru_eff[15], lru_eff[31]}) == 5'b11111);
   assign LRU_WAY_ENCODE_PT[2] = (({lru_eff[1], lru_eff[3], lru_eff[7], lru_eff[15], lru_eff[30]}) == 5'b11101);
   assign LRU_WAY_ENCODE_PT[3] = (({lru_eff[1], lru_eff[3], lru_eff[7], lru_eff[14], lru_eff[29]}) == 5'b11011);
   assign LRU_WAY_ENCODE_PT[4] = (({lru_eff[1], lru_eff[3], lru_eff[7], lru_eff[14], lru_eff[28]}) == 5'b11001);
   assign LRU_WAY_ENCODE_PT[5] = (({lru_eff[1], lru_eff[3], lru_eff[6], lru_eff[13], lru_eff[27]}) == 5'b10111);
   assign LRU_WAY_ENCODE_PT[6] = (({lru_eff[1], lru_eff[3], lru_eff[6], lru_eff[13], lru_eff[26]}) == 5'b10101);
   assign LRU_WAY_ENCODE_PT[7] = (({lru_eff[1], lru_eff[3], lru_eff[6], lru_eff[12], lru_eff[25]}) == 5'b10011);
   assign LRU_WAY_ENCODE_PT[8] = (({lru_eff[1], lru_eff[3], lru_eff[6], lru_eff[12], lru_eff[24]}) == 5'b10001);
   assign LRU_WAY_ENCODE_PT[9] = (({lru_eff[1], lru_eff[2], lru_eff[5], lru_eff[11], lru_eff[23]}) == 5'b01111);
   assign LRU_WAY_ENCODE_PT[10] = (({lru_eff[1], lru_eff[2], lru_eff[5], lru_eff[11], lru_eff[22]}) == 5'b01101);
   assign LRU_WAY_ENCODE_PT[11] = (({lru_eff[1], lru_eff[2], lru_eff[5], lru_eff[10], lru_eff[21]}) == 5'b01011);
   assign LRU_WAY_ENCODE_PT[12] = (({lru_eff[1], lru_eff[2], lru_eff[5], lru_eff[10], lru_eff[20]}) == 5'b01001);
   assign LRU_WAY_ENCODE_PT[13] = (({lru_eff[1], lru_eff[2], lru_eff[4], lru_eff[9], lru_eff[19]}) == 5'b00111);
   assign LRU_WAY_ENCODE_PT[14] = (({lru_eff[1], lru_eff[2], lru_eff[4], lru_eff[9], lru_eff[18]}) == 5'b00101);
   assign LRU_WAY_ENCODE_PT[15] = (({lru_eff[1], lru_eff[2], lru_eff[4], lru_eff[8], lru_eff[17]}) == 5'b00011);
   assign LRU_WAY_ENCODE_PT[16] = (({lru_eff[1], lru_eff[2], lru_eff[4], lru_eff[8], lru_eff[16]}) == 5'b00001);
   assign LRU_WAY_ENCODE_PT[17] = (({lru_eff[1], lru_eff[3], lru_eff[7], lru_eff[15]}) == 4'b1111);
   assign LRU_WAY_ENCODE_PT[18] = (({lru_eff[1], lru_eff[3], lru_eff[7], lru_eff[14]}) == 4'b1101);
   assign LRU_WAY_ENCODE_PT[19] = (({lru_eff[1], lru_eff[3], lru_eff[6], lru_eff[13]}) == 4'b1011);
   assign LRU_WAY_ENCODE_PT[20] = (({lru_eff[1], lru_eff[3], lru_eff[6], lru_eff[12]}) == 4'b1001);
   assign LRU_WAY_ENCODE_PT[21] = (({lru_eff[1], lru_eff[2], lru_eff[5], lru_eff[11]}) == 4'b0111);
   assign LRU_WAY_ENCODE_PT[22] = (({lru_eff[1], lru_eff[2], lru_eff[5], lru_eff[10]}) == 4'b0101);
   assign LRU_WAY_ENCODE_PT[23] = (({lru_eff[1], lru_eff[2], lru_eff[4], lru_eff[9]}) == 4'b0011);
   assign LRU_WAY_ENCODE_PT[24] = (({lru_eff[1], lru_eff[2], lru_eff[4], lru_eff[8]}) == 4'b0001);
   assign LRU_WAY_ENCODE_PT[25] = (({lru_eff[1], lru_eff[3], lru_eff[7]}) == 3'b111);
   assign LRU_WAY_ENCODE_PT[26] = (({lru_eff[1], lru_eff[3], lru_eff[6]}) == 3'b101);
   assign LRU_WAY_ENCODE_PT[27] = (({lru_eff[1], lru_eff[2], lru_eff[5]}) == 3'b011);
   assign LRU_WAY_ENCODE_PT[28] = (({lru_eff[1], lru_eff[2], lru_eff[4]}) == 3'b001);
   assign LRU_WAY_ENCODE_PT[29] = (({lru_eff[1], lru_eff[3]}) == 2'b11);
   assign LRU_WAY_ENCODE_PT[30] = (({lru_eff[1], lru_eff[2]}) == 2'b01);
   assign LRU_WAY_ENCODE_PT[31] = ((lru_eff[1]) == 1'b1);
   // Table LRU_WAY_ENCODE Signal Assignments for Outputs
   assign lru_way_encode[0] = (LRU_WAY_ENCODE_PT[31]);
   assign lru_way_encode[1] = (LRU_WAY_ENCODE_PT[29] | LRU_WAY_ENCODE_PT[30]);
   assign lru_way_encode[2] = (LRU_WAY_ENCODE_PT[25] | LRU_WAY_ENCODE_PT[26] | LRU_WAY_ENCODE_PT[27] | LRU_WAY_ENCODE_PT[28]);
   assign lru_way_encode[3] = (LRU_WAY_ENCODE_PT[17] | LRU_WAY_ENCODE_PT[18] | LRU_WAY_ENCODE_PT[19] | LRU_WAY_ENCODE_PT[20] | LRU_WAY_ENCODE_PT[21] | LRU_WAY_ENCODE_PT[22] | LRU_WAY_ENCODE_PT[23] | LRU_WAY_ENCODE_PT[24]);
   assign lru_way_encode[4] = (LRU_WAY_ENCODE_PT[1] | LRU_WAY_ENCODE_PT[2] | LRU_WAY_ENCODE_PT[3] | LRU_WAY_ENCODE_PT[4] | LRU_WAY_ENCODE_PT[5] | LRU_WAY_ENCODE_PT[6] | LRU_WAY_ENCODE_PT[7] | LRU_WAY_ENCODE_PT[8] | LRU_WAY_ENCODE_PT[9] | LRU_WAY_ENCODE_PT[10] | LRU_WAY_ENCODE_PT[11] | LRU_WAY_ENCODE_PT[12] | LRU_WAY_ENCODE_PT[13] | LRU_WAY_ENCODE_PT[14] | LRU_WAY_ENCODE_PT[15] | LRU_WAY_ENCODE_PT[16]);

   // power-on reset sequencer to load initial erat entries

   always @(por_seq_q or init_alias or bcfg_q[0:106])
   begin: Por_Sequencer
      por_wr_cam_val    <= {2{1'b0}};
      por_wr_array_val  <= {2{1'b0}};
      por_wr_cam_data   <= {cam_data_width{1'b0}};
      por_wr_array_data <= {array_data_width{1'b0}};
      por_wr_entry      <= {num_entry_log2{1'b0}};
      case (por_seq_q)
         PorSeq_Idle :
            begin
               por_wr_cam_val    <= {2{1'b0}};
               por_wr_array_val  <= {2{1'b0}};
               por_hold_req      <= {`THREADS{init_alias}};

               if (init_alias == 1'b1)
                  por_seq_d      <= PorSeq_Stg1;
               else
                  por_seq_d      <= PorSeq_Idle;
            end
         PorSeq_Stg1 :
            begin
               por_wr_cam_val    <= {2{1'b0}};
               por_wr_array_val  <= {2{1'b0}};
               por_seq_d         <= PorSeq_Stg2;
               por_hold_req      <= {`THREADS{1'b1}};
            end

         PorSeq_Stg2 :
            begin
               por_wr_cam_val    <= {2{1'b1}};
               por_wr_array_val  <= {2{1'b1}};
               por_wr_entry      <= Por_Wr_Entry_Num1;
               por_wr_cam_data   <= {bcfg_q[0:51], Por_Wr_Cam_Data1[52:83]};
               // 16x143 version, 42b RA
               // wr_array_data
               //  0:29  - RPN
               //  30:31  - R,C
               //  32:35  - ResvAttr
               //  36:39  - U0-U3
               //  40:44  - WIMGE
               //  45:46  - UX,SX
               //  47:48  - UW,SW
               //  49:50  - UR,SR
               //  51:60  - CAM parity
               //  61:67  - Array parity
               por_wr_array_data <= {bcfg_q[52:81], Por_Wr_Array_Data1[30:35], bcfg_q[82:85], Por_Wr_Array_Data1[40:43], bcfg_q[86], Por_Wr_Array_Data1[45:67]};
               por_hold_req      <= {`THREADS{1'b1}};
               por_seq_d         <= PorSeq_Stg3;
            end

         PorSeq_Stg3 :
            begin
               por_wr_cam_val    <= {2{1'b0}};
               por_wr_array_val  <= {2{1'b0}};
               por_hold_req      <= {`THREADS{1'b1}};
               por_seq_d         <= PorSeq_Stg4;
            end

         PorSeq_Stg4 :
            begin
               por_wr_cam_val    <= {2{1'b1}};
               por_wr_array_val  <= {2{1'b1}};
               por_wr_entry      <= Por_Wr_Entry_Num2;
               por_wr_cam_data   <= Por_Wr_Cam_Data2;
               por_wr_array_data <= {bcfg_q[52:61], bcfg_q[87:106], Por_Wr_Array_Data2[30:35], bcfg_q[82:85], Por_Wr_Array_Data2[40:43], bcfg_q[86], Por_Wr_Array_Data2[45:67]};
               por_hold_req      <= {`THREADS{1'b1}};
               por_seq_d         <= PorSeq_Stg5;
            end

         PorSeq_Stg5 :
            begin
               por_wr_cam_val    <= {2{1'b0}};
               por_wr_array_val  <= {2{1'b0}};
               por_hold_req      <= {`THREADS{1'b1}};
               por_seq_d         <= PorSeq_Stg6;
            end

         PorSeq_Stg6 :
            begin
               por_wr_cam_val    <= {2{1'b0}};
               por_wr_array_val  <= {2{1'b0}};
               por_hold_req      <= {`THREADS{1'b0}};
               por_seq_d         <= PorSeq_Stg7;
            end

         PorSeq_Stg7 :
            begin
               por_wr_cam_val    <= {2{1'b0}};
               por_wr_array_val  <= {2{1'b0}};
               por_hold_req      <= {`THREADS{1'b0}};
               if (init_alias == 1'b0)
                  por_seq_d      <= PorSeq_Idle;
               else
                  por_seq_d      <= PorSeq_Stg7;
            end

         default :
            por_seq_d   <= PorSeq_Idle;
      endcase
   end
   // page size 4b to 3b swizzles for cam write
   assign cam_pgsize[0:2] = (CAM_PgSize_1GB  & ({3{(ex2_data_in_q[56:59] == WS0_PgSize_1GB)}})) |
                            (CAM_PgSize_16MB & ({3{(ex2_data_in_q[56:59] == WS0_PgSize_16MB)}})) |
                            (CAM_PgSize_1MB  & ({3{(ex2_data_in_q[56:59] == WS0_PgSize_1MB)}})) |
                            (CAM_PgSize_64KB & ({3{(ex2_data_in_q[56:59] == WS0_PgSize_64KB)}})) |
                            (CAM_PgSize_4KB  & ({3{(~((ex2_data_in_q[56:59] == WS0_PgSize_1GB) |
                            (ex2_data_in_q[56:59] == WS0_PgSize_16MB) |
                            (ex2_data_in_q[56:59] == WS0_PgSize_1MB) |
                            (ex2_data_in_q[56:59] == WS0_PgSize_64KB)))}}));
   // page size 3b to 4b swizzles for cam read
   assign ws0_pgsize[0:3] = (WS0_PgSize_1GB  & ({4{(ex4_rd_cam_data_q[53:55] == CAM_PgSize_1GB)}})) |
                            (WS0_PgSize_16MB & ({4{(ex4_rd_cam_data_q[53:55] == CAM_PgSize_16MB)}})) |
                            (WS0_PgSize_1MB  & ({4{(ex4_rd_cam_data_q[53:55] == CAM_PgSize_1MB)}})) |
                            (WS0_PgSize_64KB & ({4{(ex4_rd_cam_data_q[53:55] == CAM_PgSize_64KB)}})) |
                            (WS0_PgSize_4KB  & ({4{(ex4_rd_cam_data_q[53:55] == CAM_PgSize_4KB)}}));
   // CAM control signal assignments
   assign rd_val = (|(ex2_valid_op_q & (~cp_flush_q))) & ex2_ttype_q[0] & (ex2_tlbsel_q == TlbSel_DErat);
   assign rw_entry = (por_wr_entry   & ({5{(|(por_seq_q))}})) |
                     (eptr_q         & ({5{(|(tlb_rel_val_q[0:3]) & tlb_rel_val_q[4] & mmucr1_q[0])}})) |
                     (lru_way_encode & ({5{(|(tlb_rel_val_q[0:3]) & tlb_rel_val_q[4] & (~mmucr1_q[0]))}})) |
                     (eptr_q         & ({5{(|(ex2_valid_op_q) & ex2_ttype_q[1] & (ex2_tlbsel_q == TlbSel_DErat) & (~tlb_rel_val_q[4]) & mmucr1_q[0])}})) |
                     (ex2_ra_entry_q & ({5{(|(ex2_valid_op_q) & ex2_ttype_q[1] & (ex2_tlbsel_q == TlbSel_DErat) & (~tlb_rel_val_q[4]) & (~mmucr1_q[0]))}})) |
                     (ex2_ra_entry_q & ({5{(|(ex2_valid_op_q) & ex2_ttype_q[0] & (~tlb_rel_val_q[4]))}}));
   // Write Port
   assign wr_cam_val = (por_seq_q != PorSeq_Idle) ? por_wr_cam_val :
                       ((csinv_complete == 1'b1)) ? {2{1'b0}} :
                       ((tlb_rel_val_q[0:3] != 4'b0000 & tlb_rel_val_q[4] == 1'b1)) ? {2{tlb_rel_data_q[eratpos_wren]}} :
                       ((|(ex2_valid_op_q) == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b00 & ex2_tlbsel_q == TlbSel_DErat)) ? {2{1'b1}} :
                       {2{1'b0}};
   // write port act pin
   assign wr_val_early = (|(por_seq_q)) | tlb_req_inprogress_q | (|(ex1_valid_op_q) & ex1_ttype03_q[1]) | (|(ex2_valid_op_q) & ex2_ttype_q[1]);
   // state <= PR & GS or mmucr0(8) & IS or mmucr0(9) & CM
   // tlb_low_data
   //  0:51  - EPN
   //  52:55  - SIZE (4b)
   //  56:59  - ThdID
   //  60:61  - Class
   //  62  - ExtClass
   //  63  - TID_NZ
   //  64:65  - reserved (2b)
   //  66:73  - 8b for LPID
   //  74:83  - parity 10bits
   // wr_ws0_data (LO)
   //  0:51  - EPN
   //  52:53  - Class
   //  54  - V
   //  55  - X
   //  56:59  - SIZE
   //  60:63  - ThdID
   // wr_cam_data
   //  0:51  - EPN
   //  52  - X
   //  53:55  - SIZE
   //  56  - V
   //  57:60  - ThdID
   //  61:62  - Class
   //  63:64  - ExtClass | TID_NZ
   //  65  - TGS
   //  66  - TS
   //  67:74  - TID
   //  75:78  - epn_cmpmasks:  34_39, 40_43, 44_47, 48_51
   //  79:82  - xbit_cmpmasks: 34_51, 40_51, 44_51, 48_51
   //  83  - parity for 75:82
   //--------- this is what the erat expects on reload bus
   //  0:51  - EPN
   //  52  - X
   //  53:55  - SIZE
   //  56  - V
   //  57:60  - ThdID
   //  61:62  - Class
   //  63:64  - ExtClass | TID_NZ
   //  65  - write enable
   //  0:3 66:69 - reserved RPN
   //  4:33 70:99 - RPN
   //  34:35 100:101 - R,C
   //  36 102 - reserved
   //  37:38 103:104 - WLC
   //  39 105 - ResvAttr
   //  40 106 - VF
   //  41:44 107:110 - U0-U3
   //  45:49 111:115 - WIMGE
   //  50:51 116:117 - UX,SX
   //  52:53 118:119 - UW,SW
   //  54:55 120:121 - UR,SR
   //  56 122 - GS
   //  57 123 - TS
   //  58:65 124:131 - TID lsbs

   generate
      if (GPR_WIDTH == 64)
      begin : gen64_wr_cam_data
         assign wr_cam_data = (por_wr_cam_data & {84{(por_seq_q[0] | por_seq_q[1] | por_seq_q[2])}}) |
                              (({tlb_rel_data_q[0:64], tlb_rel_data_q[122:131], tlb_rel_cmpmask[0:3], tlb_rel_xbitmask[0:3], tlb_rel_maskpar}) &
                              ({84{((tlb_rel_val_q[0] | tlb_rel_val_q[1] | tlb_rel_val_q[2] | tlb_rel_val_q[3]) & tlb_rel_val_q[4])}})) |
                              (({(ex2_data_in_q[0:31] & ({32{ex2_state_q[3]}})), ex2_data_in_q[32:51],
                                  ex2_data_in_q[55], cam_pgsize[0:2], ex2_data_in_q[54],
                                 (({ex2_data_in_q[60:61], 2'b00} & {4{~(mmucr1_q[8])}}) | (ex2_pid_q[pid_width-12 : pid_width-9] & {4{mmucr1_q[8]}})),
                                 (( ex2_data_in_q[52:53] & {2{~(mmucr1_q[7])}}) | (ex2_pid_q[pid_width-14 : pid_width-13] & {2{mmucr1_q[7]}})),
                                  ex2_extclass_q, ex2_state_q[1:2], ex2_pid_q[pid_width - 8:pid_width - 1],
                               ex2_data_cmpmask[0:3], ex2_data_xbitmask[0:3], ex2_data_maskpar}) &
                               ({84{(|(ex2_valid_op_q) & ex2_ttype_q[1] & (~ex2_ws_q[0]) & (~ex2_ws_q[1]) & (~tlb_rel_val_q[4]))}}));
      end
   endgenerate

   generate
      if (GPR_WIDTH == 32)
      begin : gen32_wr_cam_data
         assign wr_cam_data = (por_wr_cam_data & ({84{(por_seq_q[0] | por_seq_q[1] | por_seq_q[2])}})) |
                              (({tlb_rel_data_q[0:64], tlb_rel_data_q[122:131], tlb_rel_cmpmask[0:3], tlb_rel_xbitmask[0:3], tlb_rel_maskpar}) &
                              ({84{((tlb_rel_val_q[0] | tlb_rel_val_q[1] | tlb_rel_val_q[2] | tlb_rel_val_q[3]) & tlb_rel_val_q[4])}})) |
                              (({({32{1'b0}}), ex2_data_in_q[32:51], ex2_data_in_q[55], cam_pgsize[0:2], ex2_data_in_q[54],
                              (({ex2_data_in_q[60:61], 2'b00} & {4{~(mmucr1_q[8])}}) | (ex2_pid_q[pid_width-12 : pid_width-9] & {4{(mmucr1_q[8])}})),
                              (( ex2_data_in_q[52:53] & {2{~(mmucr1_q[7])}}) | (ex2_pid_q[pid_width-14 : pid_width-13] & {2{(mmucr1_q[7])}})),
                              ex2_extclass_q, ex2_state_q[1:2], ex2_pid_q[pid_width - 8:pid_width - 1], ex2_data_cmpmask[0:3], ex2_data_xbitmask[0:3], ex2_data_maskpar}) &
                              ({84{(|(ex2_valid_op_q) & ex2_ttype_q[1] & (~ex2_ws_q[0]) & (~ex2_ws_q[1]) & (~tlb_rel_val_q[4]))}}));
      end
   endgenerate

   //        wr_cam_data(75)   (76)    (77)   (78)           (79)   (80)   (81)   (82)
   //             cmpmask(0)    (1)     (2)    (3)    xbitmask(0)    (1)    (2)    (3)
   //   xbit  pgsize      34_39  40_43  44_47  48_51           34_39  40_43  44_47  48_51    size
   //    0     001          1      1      1      1               0      0      0      0       4K
   //    0     011          1      1      1      0               0      0      0      0       64K
   //    0     101          1      1      0      0               0      0      0      0       1M
   //    0     111          1      0      0      0               0      0      0      0       16M
   //    0     110          0      0      0      0               0      0      0      0       1G
   //    1     001          1      1      1      1               0      0      0      0       4K
   //    1     011          1      1      1      0               0      0      0      1       64K
   //    1     101          1      1      0      0               0      0      1      0       1M
   //    1     111          1      0      0      0               0      1      0      0       16M
   //    1     110          0      0      0      0               1      0      0      0       1G
   // Encoder for the cam compare mask bits write data
   //
   // Final Table Listing
   //      *INPUTS*==================*OUTPUTS*===================================*
   //      |                         |                                           |
   //      | tlb_rel_data_q          |  tlb_rel_cmpmask                          |
   //      | |    ex2_data_in_q      |  |    tlb_rel_xbitmask                    |
   //      | |    |                  |  |    |    tlb_rel_maskpar                |
   //      | |    |                  |  |    |    |  ex2_data_cmpmask            |
   //      | |    |                  |  |    |    |  |    ex2_data_xbitmask      |
   //      | |    |                  |  |    |    |  |    |    ex2_data_maskpar  |
   //      | |    |                  |  |    |    |  |    |    |                 |
   //      | 5555 55555              |  |    |    |  |    |    |                 |
   //      | 2345 56789              |  0123 0123 |  0123 0123 |                 |
   //      *TYPE*====================+===========================================+
   //      | PPPP PPPPP              |  PPPP PPPP P  PPPP PPPP P                 |
   //      *POLARITY*--------------->|  ++++ ++++ +  ++++ ++++ +                 |
   //      *PHASE*------------------>|  TTTT TTTT T  TTTT TTTT T                 |
   //      *OPTIMIZE*--------------->|   AAAA AAAA A  AAAA AAAA A                  |
   //      *TERMS*===================+===========================================+
   //    1 | ---- 11010              |  .... .... .  .... 1... 1                 |
   //    2 | ---- -0--0              |  .... .... .  1111 .... .                 |
   //    3 | ---- 10101              |  .... .... .  .... ..1. 1                 |
   //    4 | ---- 10011              |  .... .... .  1... ...1 .                 |
   //    5 | ---- 10111              |  .... .... .  1... .1.. .                 |
   //    6 | ---- 00-11              |  .... .... .  1... .... 1                 |
   //    7 | ---- -1--1              |  .... .... .  1111 .... .                 |
   //    8 | ---- --00-              |  .... .... .  ..11 .... .                 |
   //    9 | ---- ---0-              |  .... .... .  11.. .... .                 |
   //   10 | ---- -00--              |  .... .... .  .11. .... .                 |
   //   11 | ---- -11--              |  .... .... .  1111 .... .                 |
   //   12 | 1--0 -----              |  .... 1... 1  .... .... .                 |
   //   13 | 1111 -----              |  1... .1.. .  .... .... .                 |
   //   14 | 0-11 -----              |  1... .... 1  .... .... .                 |
   //   15 | -00- -----              |  ...1 .... .  .... .... .                 |
   //   16 | 110- -----              |  .... ..1. 1  .... .... .                 |
   //   17 | --0- -----              |  11.. .... .  .... .... .                 |
   //   18 | 101- -----              |  1... ...1 .  .... .... .                 |
   //   19 | -0-- -----              |  .11. .... .  .... .... .                 |
   //      *=====================================================================*
   //
   // Table CAM_MASK_BITS Signal Assignments for Product Terms
   assign CAM_MASK_BITS_PT[1] = (({ex2_data_in_q[55], ex2_data_in_q[56], ex2_data_in_q[57], ex2_data_in_q[58], ex2_data_in_q[59]}) == 5'b11010);
   assign CAM_MASK_BITS_PT[2] = (({ex2_data_in_q[56], ex2_data_in_q[59]}) == 2'b00);
   assign CAM_MASK_BITS_PT[3] = (({ex2_data_in_q[55], ex2_data_in_q[56], ex2_data_in_q[57], ex2_data_in_q[58], ex2_data_in_q[59]}) == 5'b10101);
   assign CAM_MASK_BITS_PT[4] = (({ex2_data_in_q[55], ex2_data_in_q[56], ex2_data_in_q[57], ex2_data_in_q[58], ex2_data_in_q[59]}) == 5'b10011);
   assign CAM_MASK_BITS_PT[5] = (({ex2_data_in_q[55], ex2_data_in_q[56], ex2_data_in_q[57], ex2_data_in_q[58], ex2_data_in_q[59]}) == 5'b10111);
   assign CAM_MASK_BITS_PT[6] = (({ex2_data_in_q[55], ex2_data_in_q[56], ex2_data_in_q[58], ex2_data_in_q[59]}) == 4'b0011);
   assign CAM_MASK_BITS_PT[7] = (({ex2_data_in_q[56], ex2_data_in_q[59]}) == 2'b11);
   assign CAM_MASK_BITS_PT[8] = (({ex2_data_in_q[57], ex2_data_in_q[58]}) == 2'b00);
   assign CAM_MASK_BITS_PT[9] = ((ex2_data_in_q[58]) == 1'b0);
   assign CAM_MASK_BITS_PT[10] = (({ex2_data_in_q[56], ex2_data_in_q[57]}) == 2'b00);
   assign CAM_MASK_BITS_PT[11] = (({ex2_data_in_q[56], ex2_data_in_q[57]}) == 2'b11);
   assign CAM_MASK_BITS_PT[12] = (({tlb_rel_data_q[52], tlb_rel_data_q[55]}) == 2'b10);
   assign CAM_MASK_BITS_PT[13] = (({tlb_rel_data_q[52], tlb_rel_data_q[53], tlb_rel_data_q[54], tlb_rel_data_q[55]}) == 4'b1111);
   assign CAM_MASK_BITS_PT[14] = (({tlb_rel_data_q[52], tlb_rel_data_q[54], tlb_rel_data_q[55]}) == 3'b011);
   assign CAM_MASK_BITS_PT[15] = (({tlb_rel_data_q[53], tlb_rel_data_q[54]}) == 2'b00);
   assign CAM_MASK_BITS_PT[16] = (({tlb_rel_data_q[52], tlb_rel_data_q[53], tlb_rel_data_q[54]}) == 3'b110);
   assign CAM_MASK_BITS_PT[17] = ((tlb_rel_data_q[54]) == 1'b0);
   assign CAM_MASK_BITS_PT[18] = (({tlb_rel_data_q[52], tlb_rel_data_q[53], tlb_rel_data_q[54]}) == 3'b101);
   assign CAM_MASK_BITS_PT[19] = ((tlb_rel_data_q[53]) == 1'b0);
   // Table CAM_MASK_BITS Signal Assignments for Outputs
   assign tlb_rel_cmpmask[0] = (CAM_MASK_BITS_PT[13] | CAM_MASK_BITS_PT[14] | CAM_MASK_BITS_PT[17] | CAM_MASK_BITS_PT[18]);
   assign tlb_rel_cmpmask[1] = (CAM_MASK_BITS_PT[17] | CAM_MASK_BITS_PT[19]);
   assign tlb_rel_cmpmask[2] = (CAM_MASK_BITS_PT[19]);
   assign tlb_rel_cmpmask[3] = (CAM_MASK_BITS_PT[15]);
   assign tlb_rel_xbitmask[0] = (CAM_MASK_BITS_PT[12]);
   assign tlb_rel_xbitmask[1] = (CAM_MASK_BITS_PT[13]);
   assign tlb_rel_xbitmask[2] = (CAM_MASK_BITS_PT[16]);
   assign tlb_rel_xbitmask[3] = (CAM_MASK_BITS_PT[18]);
   assign tlb_rel_maskpar = (CAM_MASK_BITS_PT[12] | CAM_MASK_BITS_PT[14] | CAM_MASK_BITS_PT[16]);
   assign ex2_data_cmpmask[0] = (CAM_MASK_BITS_PT[2] | CAM_MASK_BITS_PT[4] | CAM_MASK_BITS_PT[5] | CAM_MASK_BITS_PT[6] | CAM_MASK_BITS_PT[7] | CAM_MASK_BITS_PT[9] | CAM_MASK_BITS_PT[11]);
   assign ex2_data_cmpmask[1] = (CAM_MASK_BITS_PT[2] | CAM_MASK_BITS_PT[7] | CAM_MASK_BITS_PT[9] | CAM_MASK_BITS_PT[10] | CAM_MASK_BITS_PT[11]);
   assign ex2_data_cmpmask[2] = (CAM_MASK_BITS_PT[2] | CAM_MASK_BITS_PT[7] | CAM_MASK_BITS_PT[8] | CAM_MASK_BITS_PT[10] | CAM_MASK_BITS_PT[11]);
   assign ex2_data_cmpmask[3] = (CAM_MASK_BITS_PT[2] | CAM_MASK_BITS_PT[7] | CAM_MASK_BITS_PT[8] | CAM_MASK_BITS_PT[11]);
   assign ex2_data_xbitmask[0] = (CAM_MASK_BITS_PT[1]);
   assign ex2_data_xbitmask[1] = (CAM_MASK_BITS_PT[5]);
   assign ex2_data_xbitmask[2] = (CAM_MASK_BITS_PT[3]);
   assign ex2_data_xbitmask[3] = (CAM_MASK_BITS_PT[4]);
   assign ex2_data_maskpar = (CAM_MASK_BITS_PT[1] | CAM_MASK_BITS_PT[3] | CAM_MASK_BITS_PT[6]);

   assign wr_array_val = (por_seq_q != PorSeq_Idle) ? por_wr_array_val :
                         ((csinv_complete == 1'b1)) ? 2'b00 :
                         ((tlb_rel_val_q[0:3] != 4'b0000 & tlb_rel_val_q[4] == 1'b1)) ? {2{tlb_rel_data_q[eratpos_wren]}} :
                         ((((|(ex2_valid_op_q)) == 1'b1) & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b00 & ex2_tlbsel_q == TlbSel_DErat)) ? 2'b11 :
                         2'b00;

   // tlb_high_data
   //  84       -  0      - X-bit
   //  85:87    -  1:3    - reserved (3b)
   //  88:117   -  4:33   - RPN (30b)
   //  118:119  -  34:35  - R,C
   //  120:121  -  36:37  - WLC (2b)
   //  122      -  38     - ResvAttr
   //  123      -  39     - VF
   //  124      -  40     - IND
   //  125:128  -  41:44  - U0-U3
   //  129:133  -  45:49  - WIMGE
   //  134:136  -  50:52  - UX,UW,UR
   //  137:139  -  53:55  - SX,SW,SR
   //  140      -  56  - GS
   //  141      -  57  - TS
   //  142:143  -  58:59  - reserved (2b)
   //  144:149  -  60:65  - 6b TID msbs
   //  150:157  -  66:73  - 8b TID lsbs
   //  158:167  -  74:83  - parity 10bits
   // 16x143 version, 42b RA
   // wr_array_data
   //  0:29  - RPN
   //  30:31  - R,C
   //  32:35  - ResvAttr
   //  36:39  - U0-U3
   //  40:44  - WIMGE
   //  45:46  - UX,SX
   //  47:48  - UW,SW
   //  49:50  - UR,SR
   //  51:60  - CAM parity
   //  61:67  - Array parity
   // wr_ws1_data (HI)
   //  0:7  - unused
   //  8:9  - WLC
   //  10  - ResvAttr
   //  11  - unused
   //  12:15  - U0-U3
   //  16:17  - R,C
   //  18:21  - unused
   //  22:51  - RPN
   //  52:56  - WIMGE
   //  57  - VF
   //  58:59  - UX,SX
   //  60:61  - UW,SW
   //  62:63  - UR,SR
   assign wr_array_data_nopar = (por_wr_array_data[0:50] & ({51{(por_seq_q[0] | por_seq_q[1] | por_seq_q[2])}})) |
                                (({tlb_rel_data_q[70:101], tlb_rel_data_q[103:121]}) & ({51{((tlb_rel_val_q[0] | tlb_rel_val_q[1] | tlb_rel_val_q[2] | tlb_rel_val_q[3]) & tlb_rel_val_q[4])}})) |
                                (({ex2_rpn_holdreg[22:51], ex2_rpn_holdreg[16:17], ex2_rpn_holdreg[8:10], ex2_rpn_holdreg[57], ex2_rpn_holdreg[12:15], ex2_rpn_holdreg[52:56], ex2_rpn_holdreg[58:63]}) &
                                ({51{(|(ex2_valid_op_q) & ex2_ttype_q[1] & (~ex2_ws_q[0]) & (~ex2_ws_q[1]) & (~tlb_rel_val_q[4]))}}));
   //  wr_cam_val(0) -> epn(0:51), xbit, size(0:2), V, ThdID(0:3), class(0:1), array_dat(51:58)
   //    epn(0:7)                  - wr_cam_data 0:7    - wr_array_par(51)
   //    epn(8:15)                 - wr_cam_data 8:15   - wr_array_par(52)
   //    epn(16:23)                - wr_cam_data 16:23  - wr_array_par(53)
   //    epn(24:31)                - wr_cam_data 24:31  - wr_array_par(54)
   //    epn(32:39)                - wr_cam_data 32:39  - wr_array_par(55)
   //    epn(40:47)                - wr_cam_data 40:47  - wr_array_par(56)
   //    epn(48:51),xbit,size(0:2) - wr_cam_data 48:55  - wr_array_par(57)
   //    V,ThdID(0:3),class(0:1)   - wr_cam_data 56:62  - wr_array_par(58)
   assign wr_array_par[51] = ^(wr_cam_data[0:7]);
   assign wr_array_par[52] = ^(wr_cam_data[8:15]);
   assign wr_array_par[53] = ^(wr_cam_data[16:23]);
   assign wr_array_par[54] = ^(wr_cam_data[24:31]);
   assign wr_array_par[55] = ^(wr_cam_data[32:39]);
   assign wr_array_par[56] = ^(wr_cam_data[40:47]);
   assign wr_array_par[57] = ^(wr_cam_data[48:55]);
   assign wr_array_par[58] = ^(wr_cam_data[57:62]);
   //  wr_cam_val(1) -> extclass, tid_nz, gs, as, tid(6:13), array_dat(59:60)
   //    extclass,tid_nz,gs,as     - wr_cam_data 63:66  - wr_array_par(59)
   //    tid(6:13)                 - wr_cam_data 67:74  - wr_array_par(60)
   assign wr_array_par[59] = ^(wr_cam_data[63:66]);
   assign wr_array_par[60] = ^(wr_cam_data[67:74]);
   //  wr_array_val(0) -> rpn(22:51), array_dat(61:64)
   //    rpn(22:27)                          - wr_array_data 0:5    - wr_array_par(61)
   //    rpn(28:35)                          - wr_array_data 6:13   - wr_array_par(62)
   //    rpn(36:43)                          - wr_array_data 14:21  - wr_array_par(63)
   //    rpn(44:51)                          - wr_array_data 22:29  - wr_array_par(64)
   assign wr_array_par[61] = ^(wr_array_data_nopar[0:5]);
   assign wr_array_par[62] = ^(wr_array_data_nopar[6:13]);
   assign wr_array_par[63] = ^(wr_array_data_nopar[14:21]);
   assign wr_array_par[64] = ^(wr_array_data_nopar[22:29]);
   //  wr_array_val(1) -> R,C, WLC(0:1), resvattr, VF, ubits(0:3), wimge(0:4), UX,SX,UW,SW,UR,SR, array_dat(65:67)
   //    R,C,WLC(0:1),resvattr,VF,ubits(0:1) - wr_array_data 30:37  - wr_array_par(65)
   //    ubits(2:3),WIMGE(0:4)               - wr_array_data 38:44  - wr_array_par(66)
   //    UX,SX,UW,SW,UR,SR                   - wr_array_data 45:50  - wr_array_par(67)
   assign wr_array_par[65] = ^(wr_array_data_nopar[30:37]);
   assign wr_array_par[66] = ^(wr_array_data_nopar[38:44]);
   assign wr_array_par[67] = ^(wr_array_data_nopar[45:50]);
   assign wr_array_data[0:50] = wr_array_data_nopar;
   assign wr_array_data[51:67] = (((tlb_rel_val_q[0:3] != 4'b0000 & tlb_rel_val_q[4] == 1'b1) | por_seq_q != PorSeq_Idle)) ? ({wr_array_par[51:60], wr_array_par[61:67]}) :
                                 ((|(ex2_valid_op_q) == 1'b1 & ex2_ttype_q[1] == 1'b1 & ex2_ws_q == 2'b00)) ? ({(wr_array_par[51] ^ mmucr1_q[5]), wr_array_par[52:60], (wr_array_par[61] ^ mmucr1_q[6]), wr_array_par[62:67]}) :
                                 {17{1'b0}};
   // Parity Checking
   assign ex4_rd_data_calc_par[50] = ^(ex4_rd_cam_data_q[75:82]);
   assign ex4_rd_data_calc_par[51] = ^(ex4_rd_cam_data_q[0:7]);
   assign ex4_rd_data_calc_par[52] = ^(ex4_rd_cam_data_q[8:15]);
   assign ex4_rd_data_calc_par[53] = ^(ex4_rd_cam_data_q[16:23]);
   assign ex4_rd_data_calc_par[54] = ^(ex4_rd_cam_data_q[24:31]);
   assign ex4_rd_data_calc_par[55] = ^(ex4_rd_cam_data_q[32:39]);
   assign ex4_rd_data_calc_par[56] = ^(ex4_rd_cam_data_q[40:47]);
   assign ex4_rd_data_calc_par[57] = ^(ex4_rd_cam_data_q[48:55]);
   assign ex4_rd_data_calc_par[58] = ^(ex4_rd_cam_data_q[57:62]);
   assign ex4_rd_data_calc_par[59] = ^(ex4_rd_cam_data_q[63:66]);
   assign ex4_rd_data_calc_par[60] = ^(ex4_rd_cam_data_q[67:74]);
   assign ex4_rd_data_calc_par[61] = ^(ex4_rd_array_data_q[0:5]);
   assign ex4_rd_data_calc_par[62] = ^(ex4_rd_array_data_q[6:13]);
   assign ex4_rd_data_calc_par[63] = ^(ex4_rd_array_data_q[14:21]);
   assign ex4_rd_data_calc_par[64] = ^(ex4_rd_array_data_q[22:29]);
   assign ex4_rd_data_calc_par[65] = ^(ex4_rd_array_data_q[30:37]);
   assign ex4_rd_data_calc_par[66] = ^(ex4_rd_array_data_q[38:44]);
   assign ex4_rd_data_calc_par[67] = ^(ex4_rd_array_data_q[45:50]);
   generate
      if (check_parity == 0)
      begin : parerr_gen0
         assign ex4_cmp_data_parerr_epn = 1'b0;
         assign ex4_cmp_data_parerr_rpn = 1'b0;
      end
   endgenerate
   generate
      if (check_parity == 1)
      begin : parerr_gen1
         assign ex4_cmp_data_parerr_epn = ex4_cmp_data_parerr_epn_mac;
         assign ex4_cmp_data_parerr_rpn = ex4_cmp_data_parerr_rpn_mac;
      end
   endgenerate
   generate
      if (check_parity == 0)
      begin : parerr_gen2
         assign ex4_rd_data_parerr_epn = 1'b0;
         assign ex4_rd_data_parerr_rpn = 1'b0;
      end
   endgenerate
   generate
      if (check_parity == 1)
      begin : parerr_gen3
         assign ex4_rd_data_parerr_epn = |(ex4_rd_data_calc_par[50:60] ^ ({ex4_rd_cam_data_q[83], ex4_rd_array_data_q[51:60]}));
         assign ex4_rd_data_parerr_rpn = |(ex4_rd_data_calc_par[61:67] ^ ex4_rd_array_data_q[61:67]);
      end
   endgenerate
   // Adding Little Endian capture latches for timing
   assign rw_entry_d         = rw_entry;
   assign rw_entry_val_d     = &(wr_array_val);
   assign rw_entry_le_d      = wr_array_data[44];
   assign cam_entry_le_wr[0] = (rw_entry_q == 5'b00000) & rw_entry_val_q;
   assign cam_entry_le[0]    = (cam_entry_le_wr[0] == 1'b1) ? rw_entry_le_q :
                               cam_entry_le_q[0];
   assign cam_entry_le_d[0]  = cam_entry_le[0];
   assign cam_entry_le_wr[1] = (rw_entry_q == 5'b00001) & rw_entry_val_q;
   assign cam_entry_le[1]    = (cam_entry_le_wr[1] == 1'b1) ? rw_entry_le_q :
                               cam_entry_le_q[1];
   assign cam_entry_le_d[1]  = cam_entry_le[1];
   assign cam_entry_le_wr[2] = (rw_entry_q == 5'b00010) & rw_entry_val_q;
   assign cam_entry_le[2]    = (cam_entry_le_wr[2] == 1'b1) ? rw_entry_le_q :
                               cam_entry_le_q[2];
   assign cam_entry_le_d[2]  = cam_entry_le[2];
   assign cam_entry_le_wr[3] = (rw_entry_q == 5'b00011) & rw_entry_val_q;
   assign cam_entry_le[3]    = (cam_entry_le_wr[3] == 1'b1) ? rw_entry_le_q :
                               cam_entry_le_q[3];
   assign cam_entry_le_d[3]  = cam_entry_le[3];
   assign cam_entry_le_wr[4] = (rw_entry_q == 5'b00100) & rw_entry_val_q;
   assign cam_entry_le[4]    = (cam_entry_le_wr[4] == 1'b1) ? rw_entry_le_q :
                               cam_entry_le_q[4];
   assign cam_entry_le_d[4]  = cam_entry_le[4];
   assign cam_entry_le_wr[5] = (rw_entry_q == 5'b00101) & rw_entry_val_q;
   assign cam_entry_le[5]    = (cam_entry_le_wr[5] == 1'b1) ? rw_entry_le_q :
                               cam_entry_le_q[5];
   assign cam_entry_le_d[5]  = cam_entry_le[5];
   assign cam_entry_le_wr[6] = (rw_entry_q == 5'b00110) & rw_entry_val_q;
   assign cam_entry_le[6]    = (cam_entry_le_wr[6] == 1'b1) ? rw_entry_le_q :
                               cam_entry_le_q[6];
   assign cam_entry_le_d[6]  = cam_entry_le[6];
   assign cam_entry_le_wr[7] = (rw_entry_q == 5'b00111) & rw_entry_val_q;
   assign cam_entry_le[7]    = (cam_entry_le_wr[7] == 1'b1) ? rw_entry_le_q :
                               cam_entry_le_q[7];
   assign cam_entry_le_d[7]  = cam_entry_le[7];
   assign cam_entry_le_wr[8] = (rw_entry_q == 5'b01000) & rw_entry_val_q;
   assign cam_entry_le[8]    = (cam_entry_le_wr[8] == 1'b1) ? rw_entry_le_q :
                               cam_entry_le_q[8];
   assign cam_entry_le_d[8]  = cam_entry_le[8];
   assign cam_entry_le_wr[9] = (rw_entry_q == 5'b01001) & rw_entry_val_q;
   assign cam_entry_le[9]    = (cam_entry_le_wr[9] == 1'b1) ? rw_entry_le_q :
                               cam_entry_le_q[9];
   assign cam_entry_le_d[9]   = cam_entry_le[9];
   assign cam_entry_le_wr[10] = (rw_entry_q == 5'b01010) & rw_entry_val_q;
   assign cam_entry_le[10]    = (cam_entry_le_wr[10] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[10];
   assign cam_entry_le_d[10]  = cam_entry_le[10];
   assign cam_entry_le_wr[11] = (rw_entry_q == 5'b01011) & rw_entry_val_q;
   assign cam_entry_le[11]    = (cam_entry_le_wr[11] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[11];
   assign cam_entry_le_d[11]  = cam_entry_le[11];
   assign cam_entry_le_wr[12] = (rw_entry_q == 5'b01100) & rw_entry_val_q;
   assign cam_entry_le[12]    = (cam_entry_le_wr[12] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[12];
   assign cam_entry_le_d[12]  = cam_entry_le[12];
   assign cam_entry_le_wr[13] = (rw_entry_q == 5'b01101) & rw_entry_val_q;
   assign cam_entry_le[13]    = (cam_entry_le_wr[13] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[13];
   assign cam_entry_le_d[13]  = cam_entry_le[13];
   assign cam_entry_le_wr[14] = (rw_entry_q == 5'b01110) & rw_entry_val_q;
   assign cam_entry_le[14]    = (cam_entry_le_wr[14] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[14];
   assign cam_entry_le_d[14]  = cam_entry_le[14];
   assign cam_entry_le_wr[15] = (rw_entry_q == 5'b01111) & rw_entry_val_q;
   assign cam_entry_le[15]    = (cam_entry_le_wr[15] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[15];
   assign cam_entry_le_d[15]  = cam_entry_le[15];
   assign cam_entry_le_wr[16] = (rw_entry_q == 5'b10000) & rw_entry_val_q;
   assign cam_entry_le[16]    = (cam_entry_le_wr[16] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[16];
   assign cam_entry_le_d[16]  = cam_entry_le[16];
   assign cam_entry_le_wr[17] = (rw_entry_q == 5'b10001) & rw_entry_val_q;
   assign cam_entry_le[17]    = (cam_entry_le_wr[17] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[17];
   assign cam_entry_le_d[17]  = cam_entry_le[17];
   assign cam_entry_le_wr[18] = (rw_entry_q == 5'b10010) & rw_entry_val_q;
   assign cam_entry_le[18]    = (cam_entry_le_wr[18] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[18];
   assign cam_entry_le_d[18]  = cam_entry_le[18];
   assign cam_entry_le_wr[19] = (rw_entry_q == 5'b10011) & rw_entry_val_q;
   assign cam_entry_le[19]    = (cam_entry_le_wr[19] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[19];
   assign cam_entry_le_d[19]  = cam_entry_le[19];
   assign cam_entry_le_wr[20] = (rw_entry_q == 5'b10100) & rw_entry_val_q;
   assign cam_entry_le[20]    = (cam_entry_le_wr[20] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[20];
   assign cam_entry_le_d[20]  = cam_entry_le[20];
   assign cam_entry_le_wr[21] = (rw_entry_q == 5'b10101) & rw_entry_val_q;
   assign cam_entry_le[21]    = (cam_entry_le_wr[21] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[21];
   assign cam_entry_le_d[21]  = cam_entry_le[21];
   assign cam_entry_le_wr[22] = (rw_entry_q == 5'b10110) & rw_entry_val_q;
   assign cam_entry_le[22]    = (cam_entry_le_wr[22] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[22];
   assign cam_entry_le_d[22]  = cam_entry_le[22];
   assign cam_entry_le_wr[23] = (rw_entry_q == 5'b10111) & rw_entry_val_q;
   assign cam_entry_le[23]    = (cam_entry_le_wr[23] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[23];
   assign cam_entry_le_d[23]  = cam_entry_le[23];
   assign cam_entry_le_wr[24] = (rw_entry_q == 5'b11000) & rw_entry_val_q;
   assign cam_entry_le[24]    = (cam_entry_le_wr[24] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[24];
   assign cam_entry_le_d[24]  = cam_entry_le[24];
   assign cam_entry_le_wr[25] = (rw_entry_q == 5'b11001) & rw_entry_val_q;
   assign cam_entry_le[25]    = (cam_entry_le_wr[25] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[25];
   assign cam_entry_le_d[25]  = cam_entry_le[25];
   assign cam_entry_le_wr[26] = (rw_entry_q == 5'b11010) & rw_entry_val_q;
   assign cam_entry_le[26]    = (cam_entry_le_wr[26] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[26];
   assign cam_entry_le_d[26]  = cam_entry_le[26];
   assign cam_entry_le_wr[27] = (rw_entry_q == 5'b11011) & rw_entry_val_q;
   assign cam_entry_le[27]    = (cam_entry_le_wr[27] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[27];
   assign cam_entry_le_d[27]  = cam_entry_le[27];
   assign cam_entry_le_wr[28] = (rw_entry_q == 5'b11100) & rw_entry_val_q;
   assign cam_entry_le[28]    = (cam_entry_le_wr[28] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[28];
   assign cam_entry_le_d[28]  = cam_entry_le[28];
   assign cam_entry_le_wr[29] = (rw_entry_q == 5'b11101) & rw_entry_val_q;
   assign cam_entry_le[29]    = (cam_entry_le_wr[29] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[29];
   assign cam_entry_le_d[29]  = cam_entry_le[29];
   assign cam_entry_le_wr[30] = (rw_entry_q == 5'b11110) & rw_entry_val_q;
   assign cam_entry_le[30]    = (cam_entry_le_wr[30] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[30];
   assign cam_entry_le_d[30]  = cam_entry_le[30];
   assign cam_entry_le_wr[31] = (rw_entry_q == 5'b11111) & rw_entry_val_q;
   assign cam_entry_le[31]    = (cam_entry_le_wr[31] == 1'b1) ? rw_entry_le_q :
                                cam_entry_le_q[31];
   assign cam_entry_le_d[31]  = cam_entry_le[31];
   assign ex3_cam_byte_rev    = (cam_entry_le ^ ({32{ex3_byte_rev_q}}));
   assign ex3_cam_entry_le    = (ex3_cam_byte_rev & {32{(~ccr2_frat_paranoia_q[9])}});
   assign ex3_cam_hit_le      = |((ex3_cam_entry_le & entry_match));
   // ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore
   // end of parity checking ------------------------------------------------------
   // epsc waits for tlb_reloads
   assign epsc_wr_d[0:`THREADS - 1] = ex0_epsc_wr_val_q;
   assign epsc_wr_d[`THREADS:(2 * `THREADS) - 1] = (|(tlb_rel_val_q[0:4]) == 1'b1) ? (epsc_wr_q[0:`THREADS - 1] | epsc_wr_q[`THREADS:(2 * `THREADS) - 1]) :
                                               epsc_wr_q[0:`THREADS - 1];
   assign epsc_wr_d[2 * `THREADS] = (|(tlb_rel_val_q[0:4]) == 1'b1) ? (|(epsc_wr_q[0:`THREADS - 1]) | epsc_wr_q[2 * `THREADS]) :
                                   |(epsc_wr_q[0:`THREADS - 1]);
   // eplc waits for tlb_reloads and epsc accesses
   assign eplc_wr_d[0:`THREADS - 1] = ex0_eplc_wr_val_q;
   assign eplc_wr_d[`THREADS:2 * `THREADS - 1] = ((|(tlb_rel_val_q[0:4]) == 1'b1 | epsc_wr_q[2 * `THREADS] == 1'b1)) ? (eplc_wr_q[0:`THREADS - 1] | eplc_wr_q[`THREADS:(2 * `THREADS) - 1]) :
                                               eplc_wr_q[0:`THREADS - 1];
   assign eplc_wr_d[2 * `THREADS] = ((|(tlb_rel_val_q[0:4]) == 1'b1 | epsc_wr_q[2 * `THREADS] == 1'b1)) ? (|(eplc_wr_q[0:`THREADS - 1]) | eplc_wr_q[2 * `THREADS]) :
                                   |(eplc_wr_q[0:`THREADS - 1]);
   // CAM Port
   assign flash_invalidate = (por_seq_q == PorSeq_Stg1) | mchk_flash_inv_enab;
   assign comp_invalidate = ((csinv_complete == 1'b1)) ? 1'b1 :
                            ((tlb_rel_val_q[0:3] != 4'b0000 & tlb_rel_val_q[4] == 1'b1)) ? 1'b0 :
                            (((eplc_wr_q[2 * `THREADS] == 1'b1 | epsc_wr_q[2 * `THREADS] == 1'b1) & tlb_rel_val_q[4] == 1'b0 & mmucr1_q[7] == 1'b0)) ? 1'b1 :
                            (snoop_val_q[0:1] == 2'b11) ? 1'b1 :
                            1'b0;
   assign comp_request = (((csinv_complete == 1'b1) | ((eplc_wr_q[2 * `THREADS] == 1'b1 | epsc_wr_q[2 * `THREADS] == 1'b1) & tlb_rel_val_q[4] == 1'b0 & mmucr1_q[7] == 1'b0) |
                         (snoop_val_q[0:1] == 2'b11 & tlb_rel_val_q[0:3] == 4'b0000) | ((|(ex2_valid_op_q)) == 1'b1 & ex2_ttype_q[2] == 1'b1 & ex2_tlbsel_q == TlbSel_DErat) |
                         ((|(ex2_valid)) == 1'b1 & ex2_ttype_q[4:5] != 2'b00) | ((|(ex2_pfetch_val_q)) == 1'b1))) ? 1'b1 :
                         1'b0;
   generate
      if (GPR_WIDTH == 64)
      begin : gen64_comp_addr
         assign comp_addr = dir_derat_ex2_epn_arr;
         assign derat_dec_rv1_snoop_addr = ((|(rv1_ttype_val_q)) == 1'b0) ? snoop_addr_q :
                                           rs_data_q[0:51];
         assign derat_rv1_snoop_val = (rv1_snoop_val_q) | (|(rv1_ttype_val_q) & rv1_ttype_q[2]);
      end
   endgenerate
   generate
      if (GPR_WIDTH == 32)
      begin : gen32_comp_addr
         assign comp_addr = {{32{1'b0}}, dir_derat_ex2_epn_arr[32:51]};
         assign derat_dec_rv1_snoop_addr = ((|(rv1_ttype_val_q)) == 1'b0) ? {{32{1'b0}}, snoop_addr_q[32:51]} :
                                           {{32{1'b0}}, rs_data_q[32:51]};
         assign derat_rv1_snoop_val = (rv1_snoop_val_q) | (|(rv1_ttype_val_q) & rv1_ttype_q[2]);
      end
   endgenerate
   assign ex3_comp_addr_d = comp_addr[22:51];
   // ex2_rs_is(0 to 9) from erativax instr.
   //   RS(55)    -> ex2_rs_is(0)   -> snoop_attr(0)     -> Local
   //   RS(56:57) -> ex2_rs_is(1:2) -> snoop_attr(0:1)   -> IS
   //   RS(58:59) -> ex2_rs_is(3:4) -> snoop_attr(2:3)   -> Class
   //   n/a       ->  n/a           -> snoop_attr(4:5)   -> State
   //   n/a       ->  n/a           -> snoop_attr(6:13)  -> TID(6:13)
   //   RS(60:63) -> ex2_rs_is(5:8) -> snoop_attr(14:17) -> Size
   //   n/a       ->  n/a           -> snoop_attr(20:25) -> TID(0:5)
   // snoop_attr:
   //          0 -> Local
   //        1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=epn, 4=class0, 5=class1, 6=class2, 7=class3
   //        4:5 -> GS/TS
   //       6:13 -> TID(6:13)
   //      14:17 -> Size
   //      18    -> reserved for tlb, extclass_enable(0) for erats
   //      19    -> mmucsr0.tlb0fi for tlb, or TID_NZ for erats
   //      20:25 -> TID(0:5)
   // ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore
   assign addr_enable = (((csinv_complete == 1'b1) | (epsc_wr_q[2 * `THREADS] == 1'b1 | eplc_wr_q[2 * `THREADS] == 1'b1) | (snoop_val_q[0:1] == 2'b11 & snoop_attr_q[1:3] != 3'b011))) ? 2'b00 :
                        ((snoop_val_q[0:1] == 2'b11 & snoop_attr_q[0:3] == 4'b0011)) ? 2'b10 :
                        ((snoop_val_q[0:1] == 2'b11 & snoop_attr_q[0:3] == 4'b1011)) ? 2'b11 :
                        ((((|(ex2_valid_op_q)) == 1'b1 & ex2_ttype_q[2] == 1'b1 & ex2_tlbsel_q == TlbSel_DErat) |
                        ((|(ex2_valid)) == 1'b1 & ex2_ttype_q[4:5] != 2'b00) |
                        ((|(ex2_pfetch_val_q)) == 1'b1))) ? 2'b11 :
                        2'b00;
   assign comp_pgsize = (snoop_attr_q[14:17] == WS0_PgSize_1GB)  ? CAM_PgSize_1GB :
                        (snoop_attr_q[14:17] == WS0_PgSize_16MB) ? CAM_PgSize_16MB :
                        (snoop_attr_q[14:17] == WS0_PgSize_1MB)  ? CAM_PgSize_1MB :
                        (snoop_attr_q[14:17] == WS0_PgSize_64KB) ? CAM_PgSize_64KB :
                        CAM_PgSize_4KB;
   assign pgsize_enable = ((csinv_complete == 1'b1)) ? 1'b0 :
                          ((epsc_wr_q[2 * `THREADS] == 1'b1 | eplc_wr_q[2 * `THREADS] == 1'b1)) ? 1'b0 :
                          ((snoop_val_q[0:1] == 2'b11 & snoop_attr_q[0:3] == 4'b0011)) ? 1'b1 :
                          1'b0;
   // ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore
   //  mmucr1_q: 0-DRRE, 1-REE, 2-CEE, 3-csync, 4-isync, 5:6-DPEI, 7:8-DCTID/DTTID, 9:DCCD
   assign comp_class = ((epsc_wr_q[2 * `THREADS] == 1'b1 & mmucr1_q[7] == 1'b0)) ? 2'b11 :
                       ((epsc_wr_q[2 * `THREADS] == 1'b0 & eplc_wr_q[2 * `THREADS] == 1'b1 & mmucr1_q[7] == 1'b0)) ? 2'b10 :
                       ((snoop_val_q[0:1] == 2'b11 & mmucr1_q[7] == 1'b1)) ? snoop_attr_q[20:21] :
                       ((snoop_val_q[0:1] == 2'b11)) ? snoop_attr_q[2:3] :
                       (mmucr1_q[7] == 1'b1) ? ex2_pid_q[pid_width - 14:pid_width - 13] :
                       ({(ex2_ttype_q[10] | ex2_ttype_q[11]), ex2_ttype_q[11]});
   assign class_enable[0] = (((mmucr1_q[7] == 1'b1) | (csinv_complete == 1'b1))) ? 1'b0 :
                            ((((eplc_wr_q[2 * `THREADS] == 1'b1 | epsc_wr_q[2 * `THREADS] == 1'b1) & tlb_rel_val_q[4] == 1'b0 & mmucr1_q[7] == 1'b0) |
                            (snoop_val_q[0:1] == 2'b11 & snoop_attr_q[1] == 1'b1) | ((|(ex2_valid)) == 1'b1 & ex2_ttype_q[10:11] != 2'b00 & mmucr1_q[9] == 1'b0) |
                            ((|(ex2_valid)) == 1'b1 & ex2_ttype_q[4:5] != 2'b00 & mmucr1_q[9] == 1'b0) |
                            ((|(ex2_pfetch_val_q)) == 1'b1 & mmucr1_q[9] == 1'b0))) ? 1'b1 :
                            1'b0;
   assign class_enable[1] = (((mmucr1_q[7] == 1'b1) | (csinv_complete == 1'b1))) ? 1'b0 :
                            ((((eplc_wr_q[2 * `THREADS] == 1'b1 | epsc_wr_q[2 * `THREADS] == 1'b1) & tlb_rel_val_q[4] == 1'b0 & mmucr1_q[7] == 1'b0) |
                            (snoop_val_q[0:1] == 2'b11 & snoop_attr_q[1] == 1'b1) | ((|(ex2_valid)) == 1'b1 & ex2_ttype_q[10:11] != 2'b00 & mmucr1_q[9] == 1'b0))) ? 1'b1 :
                            1'b0;
   assign class_enable[2] = pid_enable & mmucr1_q[7];
   // snoop_attr:
   //          0 -> Local
   //        1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=epn, 4=class0, 5=class1, 6=class2, 7=class3
   //        4:5 -> GS/TS
   //       6:13 -> TID(6:13)
   //      14:17 -> Size
   //      18    -> reserved for tlb, extclass_enable(0) for erats
   //      19    -> mmucsr0.tlb0fi for tlb, or TID_NZ for erats
   //      20:25 -> TID(0:5)
   assign comp_extclass[0]   = 1'b0;
   assign comp_extclass[1]   = snoop_attr_q[19];
   assign extclass_enable[0] = (csinv_complete == 1'b1) | ((eplc_wr_q[2 * `THREADS] | epsc_wr_q[2 * `THREADS]) & (~mmucr1_q[7])) | (snoop_val_q[0] & snoop_attr_q[18]);
   assign extclass_enable[1] = (~csinv_complete) & (snoop_val_q[0] & (~snoop_attr_q[1]) & snoop_attr_q[3]);
   // state: 0:pr 1:gs 2:ds 3:cm
   // cam state bits are 0:GS, 1:TS
   assign comp_state = ((snoop_val_q[0:1] == 2'b11 & snoop_attr_q[1:2] == 2'b01)) ? snoop_attr_q[4:5] :
                       ex2_state_q[1:2];
   assign state_enable = (((csinv_complete == 1'b1) | (epsc_wr_q[2 * `THREADS] == 1'b1 | eplc_wr_q[2 * `THREADS] == 1'b1) | (snoop_val_q[0:1] == 2'b11 & snoop_attr_q[1:2] != 2'b01))) ? 2'b00 :
                         ((snoop_val_q[0:1] == 2'b11 & snoop_attr_q[1:3] == 3'b010)) ? 2'b10 :
                         ((snoop_val_q[0:1] == 2'b11 & snoop_attr_q[1:3] == 3'b011)) ? 2'b11 :
                         ((((|(ex2_valid_op_q)) == 1'b1 & ex2_ttype_q[2] == 1'b1 & ex2_tlbsel_q == TlbSel_DErat) |
                         ((|(ex2_valid)) == 1'b1 & ex2_ttype_q[4:5] != 2'b00) |
                         ((|(ex2_pfetch_val_q)) == 1'b1))) ? 2'b11 :
                         2'b00;
   //  mmucr1_q: 0-DRRE, 1-REE, 2-CEE, 3-csync, 4-isync, 5:6-DPEI, 7:8-DCTID/DTTID, 9-DCCD
   generate begin : compTids
         genvar                            tid;
         for (tid = 0; tid <= 3; tid = tid + 1) begin : compTids
            if (tid < `THREADS) begin : validTid
               assign comp_thdid[tid] = ((snoop_val_q[0:1] == 2'b11 & mmucr1_q[8] == 1'b1)) ? snoop_attr_q[22 + tid] :
                                        ((mmucr1_q[8] == 1'b1)) ? ex2_pid_q[(pid_width - 12) + tid] :
                                        ((epsc_wr_q[2 * `THREADS] == 1'b1 & mmucr1_q[8] == 1'b0)) ? epsc_wr_q[`THREADS + tid] :
                                        ((epsc_wr_q[2 * `THREADS] == 1'b0 & eplc_wr_q[2 * `THREADS] == 1'b1 & mmucr1_q[8] == 1'b0)) ? eplc_wr_q[`THREADS + tid] :
                                        ((snoop_val_q[0:1] == 2'b11 & mmucr1_q[8] == 1'b0)) ? 1'b1 :
                                        ((ex2_pfetch_val_q[tid]) == 1'b1) ? 1'b1 :
                                        ex2_valid[tid];
            end
            if (tid >= `THREADS) begin : nonValidTid
               assign comp_thdid[tid] = ((snoop_val_q[0:1] == 2'b11 & mmucr1_q[8] == 1'b1)) ? snoop_attr_q[22 + tid] :
                                        ((mmucr1_q[8] == 1'b1)) ? ex2_pid_q[(pid_width - 12) + tid] :
                                        ((epsc_wr_q[2 * `THREADS] == 1'b1 & mmucr1_q[8] == 1'b0)) ? 1'b0 :
                                        ((epsc_wr_q[2 * `THREADS] == 1'b0 & eplc_wr_q[2 * `THREADS] == 1'b1 & mmucr1_q[8] == 1'b0)) ? 1'b0 :
                                        ((snoop_val_q[0:1] == 2'b11 & mmucr1_q[8] == 1'b0)) ? 1'b1 :
                                        1'b0;
            end
         end
      end
   endgenerate
   assign thdid_enable[0] = (((mmucr1_q[8] == 1'b1) | (csinv_complete == 1'b1))) ? 1'b0 :
                            (((epsc_wr_q[2 * `THREADS] == 1'b1 & tlb_rel_val_q[4] == 1'b0 & mmucr1_q[8] == 1'b0) | (epsc_wr_q[2 * `THREADS] == 1'b0 & eplc_wr_q[2 * `THREADS] == 1'b1 & tlb_rel_val_q[4] == 1'b0 & mmucr1_q[8] == 1'b0))) ? 1'b1 :
                            ((snoop_val_q[0:1] == 2'b11)) ? 1'b0 :
                            ((((|(ex2_valid_op_q)) == 1'b1 & ex2_ttype_q[2] == 1'b1 & ex2_tlbsel_q == TlbSel_DErat) | ((|(ex2_valid)) == 1'b1 & (|(ex2_ttype_q[4:5])) == 1'b1) | ((|(ex2_pfetch_val_q)) == 1'b1))) ? 1'b1 :
                            1'b0;
   assign thdid_enable[1] = pid_enable & mmucr1_q[8];
   assign comp_pid = ((snoop_val_q[0:1] == 2'b11)) ? snoop_attr_q[6:13] :
                     ex2_pid_q[pid_width - 8:pid_width - 1];
   assign pid_enable = (((csinv_complete == 1'b1) | (epsc_wr_q[2 * `THREADS] == 1'b1 | eplc_wr_q[2 * `THREADS] == 1'b1) | (snoop_val_q[0:1] == 2'b11 & snoop_attr_q[1] == 1'b1) | (snoop_val_q[0:1] == 2'b11 & snoop_attr_q[3] == 1'b0))) ? 1'b0 :
                       (((snoop_val_q[0:1] == 2'b11 & snoop_attr_q[1:3] == 3'b001) | (snoop_val_q[0:1] == 2'b11 & snoop_attr_q[1:3] == 3'b011) | ((|(ex2_valid_op_q) == 1'b1) & ex2_ttype_q[2] == 1'b1 & ex2_tlbsel_q == TlbSel_DErat) | ((|(ex2_valid)) == 1'b1 & ex2_ttype_q[4:5] != 2'b00) | ((|(ex2_pfetch_val_q)) == 1'b1))) ? 1'b1 :
                       1'b0;
   // wr_cam_data
   //  0:51  - EPN
   //  52  - X
   //  53:55  - SIZE
   //  56  - V
   //  57:60  - ThdID
   //  61:62  - Class
   //  63:64  - ExtClass | TID_NZ
   //  65  - TGS
   //  66  - TS
   //  67:74  - TID
   //  75:78  - epn_cmpmasks:  34_39, 40_43, 44_47, 48_51
   //  79:82  - xbit_cmpmasks: 34_51, 40_51, 44_51, 48_51
   //  83  - parity for 75:82
   // 16x143 version, 42b RA
   // wr_array_data
   //  0:29  - RPN
   //  30:31  - R,C
   //  32:35  - ResvAttr
   //  36:39  - U0-U3
   //  40:44  - WIMGE
   //  45:46  - UX,SX
   //  47:48  - UW,SW
   //  49:50  - UR,SR
   //  51:60  - CAM parity
   //  61:67  - Array parity
   // wr_ws0_data (LO)
   //  0:51  - EPN
   //  52:53  - Class
   //  54  - V
   //  55  - X
   //  56:59  - SIZE
   //  60:63  - ThdID
   // CAM.ExtClass - MMUCR ExtClass
   // CAM.TS - MMUCR TS
   // CAM.TID - MMUCR TID
   // wr_ws1_data (HI)
   //  0:7  - unused
   //  8:9  - WLC
   //  10  - ResvAttr
   //  11  - unused
   //  12:15  - U0-U3
   //  16:17  - R,C
   //  18:21  - unused
   //  22:51  - RPN
   //  52:56  - WIMGE
   //  57  - VF
   //  58:59  - UX,SX
   //  60:61  - UW,SW
   //  62:63  - UR,SR
   // state: 0:pr 1:gs 2:ds 3:cm
   // ttype <= 0-eratre 1-eratwe 2-eratsx 3-eratilx 4-load 5-store 6-csync 7-isync 8-icbtlslc 9-touch 10-extload 11-extstore
   //                EPN                    Class                   V
   //                 X                 SIZE                 ThdID
   //                Unused      ResvAttr                  U0-U3                       R,C
   //                 RPN                      WIMGE                     Unused   UX,SW,UW,SW,UR,SR

   generate
      if (`GPR_WIDTH == 64)
      begin : gen64_data_out
         assign ex5_data_out_d = (({({32{1'b0}}), ex4_rd_cam_data_q[32:51],
                                         (ex4_rd_cam_data_q[61:62] & {2{~(mmucr1_q[7])}}),
                                          ex4_rd_cam_data_q[56], ex4_rd_cam_data_q[52], ws0_pgsize[0:3],
                                         (ex4_rd_cam_data_q[57:58] | {2{mmucr1_q[8]}}), 2'b0}) &
                                            ({`GPR_WIDTH{(|(ex4_valid) & ex4_ttype_q[0] & (~ex4_ws_q[0]) & (~ex4_ws_q[1]) & (~ex4_state_q[3]))}})) |
                                (({({32{1'b0}}), ex4_rd_array_data_q[10:29], 2'b00, ex4_rd_array_data_q[0:9]}) &
                                            ({`GPR_WIDTH{(|(ex4_valid) & ex4_ttype_q[0] & (~ex4_ws_q[0]) & ex4_ws_q[1] & (~ex4_state_q[3]))}})) |
                                (({({32{1'b0}}), 8'b00000000, ex4_rd_array_data_q[32:34], 1'b0, ex4_rd_array_data_q[36:39], ex4_rd_array_data_q[30:31], 2'b00, ex4_rd_array_data_q[40:44], ex4_rd_array_data_q[35], ex4_rd_array_data_q[45:50]}) &
                                            ({`GPR_WIDTH{(|(ex4_valid) & ex4_ttype_q[0] & ex4_ws_q[0] & (~ex4_ws_q[1]) & (~ex4_state_q[3]))}})) |
                                (({ex4_rd_cam_data_q[0:51],
                                         (ex4_rd_cam_data_q[61:62] & {2{~(mmucr1_q[7])}}),
                                          ex4_rd_cam_data_q[56], ex4_rd_cam_data_q[52], ws0_pgsize[0:3],
                                         (ex4_rd_cam_data_q[57:58] | {2{mmucr1_q[8]}}), 2'b0}) &
                                            ({`GPR_WIDTH{(|(ex4_valid) & ex4_ttype_q[0] & (~ex4_ws_q[0]) & (~ex4_ws_q[1]) & ex4_state_q[3])}})) |
                                (({8'b00000000, ex4_rd_array_data_q[32:34], 1'b0, ex4_rd_array_data_q[36:39], ex4_rd_array_data_q[30:31], 4'b0000, ex4_rd_array_data_q[0:29], ex4_rd_array_data_q[40:44], ex4_rd_array_data_q[35], ex4_rd_array_data_q[45:50]}) &
                                            ({`GPR_WIDTH{(|(ex4_valid) & ex4_ttype_q[0] & (~ex4_ws_q[0]) & ex4_ws_q[1] & ex4_state_q[3])}})) |
                                (({({59{1'b0}}), eptr_q}) &
                                            ({`GPR_WIDTH{(|(ex4_valid) & ex4_ttype_q[0] & ex4_ws_q[0] & ex4_ws_q[1] & mmucr1_q[0])}})) |
                                (({({59{1'b0}}), lru_way_encode}) &
                                            ({`GPR_WIDTH{(|(ex4_valid) & ex4_ttype_q[0] & ex4_ws_q[0] & ex4_ws_q[1] & (~mmucr1_q[0]))}})) |
                                (({({50{1'b0}}), ex4_eratsx_data[0:1], ({7{1'b0}}), ex4_eratsx_data[2:2 + num_entry_log2 - 1]}) &
                                            ({`GPR_WIDTH{(|(ex4_valid) & ex4_ttype_q[2])}}));
      end
   endgenerate

   generate
      if (`GPR_WIDTH == 32)
      begin : gen32_data_out
         assign ex5_data_out_d = (({ex4_rd_cam_data_q[32:51],
                                         (ex4_rd_cam_data_q[61:62] & {2{~(mmucr1_q[7])}}),
                                          ex4_rd_cam_data_q[56], ex4_rd_cam_data_q[52], ws0_pgsize[0:3],
                                         (ex4_rd_cam_data_q[57:58] | {2{mmucr1_q[8]}}), 2'b0}) &
                                             ({`GPR_WIDTH{(|(ex4_valid) & ex4_ttype_q[0] & (~ex4_ws_q[0]) & (~ex4_ws_q[1]))}})) |
                                   (({ex4_rd_array_data_q[10:29], 2'b00, ex4_rd_array_data_q[0:9]}) &
                                             ({`GPR_WIDTH{(|(ex4_valid) & ex4_ttype_q[0] & (~ex4_ws_q[0]) & ex4_ws_q[1])}})) |
                                   (({8'b00000000, ex4_rd_array_data_q[32:34], 1'b0, ex4_rd_array_data_q[36:39], ex4_rd_array_data_q[30:31], 2'b00, ex4_rd_array_data_q[40:44], ex4_rd_array_data_q[35], ex4_rd_array_data_q[45:50]}) &
                                             ({`GPR_WIDTH{(|(ex4_valid) & ex4_ttype_q[0] & ex4_ws_q[0] & (~ex4_ws_q[1]))}})) |
                                   (({({27{1'b0}}), eptr_q}) &
                                             ({`GPR_WIDTH{(|(ex4_valid) & ex4_ttype_q[0] & ex4_ws_q[0] & ex4_ws_q[1] & mmucr1_q[0])}})) |
                                   (({({27{1'b0}}), lru_way_encode}) &
                                             ({`GPR_WIDTH{(|(ex4_valid) & ex4_ttype_q[0] & ex4_ws_q[0] & ex4_ws_q[1] & (~mmucr1_q[0]))}})) |
                                   (({({18{1'b0}}), ex4_eratsx_data[0:1], ({7{1'b0}}), ex4_eratsx_data[2:2 + num_entry_log2 - 1]}) &
                                             ({`GPR_WIDTH{(|(ex4_valid) & ex4_ttype_q[2])}}));
      end
   endgenerate

   //ex4_valid_32b <= or_reduce(ex4_valid_q and not(spr_msr_cm_q));
   // ERAT outputs
   // 16x143 version
   // pass thru epn offset bits depending on page size from cam entry
   // adding frat paranoia bypass bit 9 for ra=ea... bit 10 also bypass ra=ea for other xu reasons
   // bit 10 affects only rpn, not the attr/prot bits
   //        wr_cam_data(75)   (76)    (77)   (78)           (79)   (80)   (81)   (82)
   //             cmpmask(0)    (1)     (2)    (3)    xbitmask(0)    (1)    (2)    (3)
   //   xbit  pgsize      34_39  40_43  44_47  48_51           34_39  40_43  44_47  48_51    size
   //    0     001          1      1      1      1               0      0      0      0       4K
   //    0     011          1      1      1      0               0      0      0      0       64K
   //    0     101          1      1      0      0               0      0      0      0       1M
   //    0     111          1      0      0      0               0      0      0      0       16M
   //    0     110          0      0      0      0               0      0      0      0       1G
   generate
      if (ex3_epn_width == rpn_width)
      begin : gen_mcompar_breaks_timing_1
         assign derat_dcc_ex3_e = ((ccr2_frat_paranoia_q[4] ^ ex3_byte_rev_q) & ccr2_frat_paranoia_q[9]) | ex3_cam_hit_le;
      end
   endgenerate
   //gen_no_frat_1: if ex3_epn_width = 18 generate
   //     derat_dcc_ex3_e <= ex3_cam_hit_le;
   //end generate gen_no_frat_1;
   // new cam _np2  bypass attributes (bit numbering per array)
   //  30:31  - R,C
   //  32:33  - WLC
   //  34  - ResvAttr
   //  35  - VF
   //  36:39  - U0-U3
   //  40:44  - WIMGE
   //  45:46  - UX,SX
   //  47:48  - UW,SW
   //  49:50  - UR,SR
   assign bypass_mux_enab_np1    = (ccr2_frat_paranoia_q[9] | ccr2_frat_paranoia_q[11]);
   assign bypass_attr_np1[0:5]   = {6{1'b0}};
   assign bypass_attr_np1[6:9]   = ccr2_frat_paranoia_q[5:8];
   assign bypass_attr_np1[10:14] = ccr2_frat_paranoia_q[0:4];
   assign bypass_attr_np1[15:20] = 6'b111111;
   // Had to remove ex4_gate_miss from equation, was causing a livelock scenario since the oldest itag was not
   // able to report a recirc valid to IU, the gate_miss was gating that report
   assign ex4_miss_w_tlb             = (|(ex4_miss_q) & (~(spr_ccr2_notlb_q | ex4_nonspec_val_q))) | ex4_tlbmiss_q;
   assign ex4_miss_wo_tlb            = |(ex4_miss_q) & spr_ccr2_notlb_q;
   assign derat_dcc_ex4_tlb_err      = ex4_miss_w_tlb | ex4_miss_wo_tlb;
   assign derat_dcc_ex4_miss         = |(ex4_miss_q);
   assign derat_dcc_ex4_dsi          = |(ex4_dsi_q[8 + `THREADS:7 + 2 * `THREADS]) & ex4_dsi_enab;
   assign derat_dcc_ex4_noop_touch   = |(ex4_noop_touch_q[8 + `THREADS:7 + 2 * `THREADS]) & ex4_noop_touch_enab;

   assign derat_dcc_ex4_multihit_err_flush = |(ex4_multihit_q[0:`THREADS-1] & ~ex4_pfetch_val_q) & ex4_multihit_enab;  // load/store, not eratsx and not prefetch
   assign derat_dcc_ex4_par_err_flush      = |(ex4_parerr_q[0:`THREADS-1] & ~ex4_pfetch_val_q) & ex4_parerr_enab[0];  // load/store, not eratsx and not prefetch
   assign derat_dcc_ex4_multihit_err_det   = |(ex4_multihit_q[0:`THREADS-1]) & ex4_multihit_enab;  // load/store, not eratsx
   assign derat_dcc_ex4_par_err_det        = |(ex4_parerr_q[0:`THREADS-1]) & ex4_parerr_enab[0];  // load/store, not eratsx

   // TLB reporting due to derat miss
   assign derat_dcc_ex4_tlb_inelig   = ex4_tlbinelig_q;
   assign derat_dcc_ex4_pt_fault     = ex4_ptfault_q;
   assign derat_dcc_ex4_lrat_miss    = ex4_lratmiss_q;
   assign derat_dcc_ex4_tlb_multihit = ex4_tlb_multihit_q;
   assign derat_dcc_ex4_tlb_par_err  = ex4_tlb_par_err_q;
   assign derat_dcc_ex4_lru_par_err  = ex4_lru_par_err_q;

   // Reporting to fir regs, err_rpt buffer macro is over in lq_fgen.v
   assign derat_fir_par_err          = |(ex5_fir_parerr_q[0:`THREADS - 1]) & ex5_fir_parerr_enab;  // any source of parerr
   assign derat_fir_multihit         = |(ex5_fir_multihit_q[0:`THREADS - 1]);                      // any source of multihit

   assign lq_xu_ex5_data             = ex5_data_out_q;

   // Derat Miss Request to the MMU
   assign lq_mm_req                  = ex5_tlbreq_val;
   assign lq_mm_req_nonspec          = ex5_tlbreq_nonspec_q;
   assign lq_mm_req_itag             = ex5_itag_q;
   assign lq_mm_req_epn              = ex5_epn_q;
   assign lq_mm_thdid                = ex5_thdid_q;
   assign lq_mm_req_emq              = ex5_emq_q;
   assign lq_mm_state                = ex5_state_q;
   assign lq_mm_ttype                = ex5_tlbreq_ttype_q;
   assign lq_mm_tid                  = ex5_pid_q;
   assign lq_mm_lpid                 = ex5_lpid_q;
   assign lq_mm_mmucr0               = {ex7_extclass_q, ex7_state_q[1:2], ex7_pid_q};
   assign lq_mm_mmucr0_we            = ((ex7_ttype_q[0] == 1'b1 & ex7_ws_q == 2'b00 & ex7_tlbsel_q == TlbSel_DErat)) ? ex7_valid :
                                       {`THREADS{1'b0}};
   assign lq_mm_mmucr1               = ex7_deen_q[`THREADS:`THREADS+num_entry_log2-1];
   assign lq_mm_mmucr1_we            = ex7_deen_q[0:`THREADS-1];

   assign lq_mm_perf_dtlb            = ex5_perf_dtlb_q;

   //---------------------------------------------------------------------
   // CAM Instantiation
   //---------------------------------------------------------------------
   //derat_cam: entity work.tri_cam_32x143_1r1w1c

   tri_cam_32x143_1r1w1c derat_cam(
      .gnd(gnd),
      .vdd(vdd),
      .vcs(vcs),
      .nclk(nclk),

      .tc_ccflush_dc(pc_xu_ccflush_dc),
      .tc_scan_dis_dc_b(tc_scan_dis_dc_b),
      .tc_scan_diag_dc(tc_scan_diag_dc),
      .tc_lbist_en_dc(tc_lbist_en_dc),
      .an_ac_atpg_en_dc(an_ac_atpg_en_dc),

      .lcb_d_mode_dc(cam_d_mode_dc),
      .lcb_clkoff_dc_b(cam_clkoff_dc_b),
      .lcb_act_dis_dc(cam_act_dis_dc),
      .lcb_mpw1_dc_b(cam_mpw1_dc_b[0:3]),
      .lcb_mpw2_dc_b(cam_mpw2_dc_b),
      .lcb_delay_lclkr_dc(cam_delay_lclkr_dc[0:3]),

      .pc_sg_2(pc_sg_2),
      .pc_func_slp_sl_thold_2(pc_func_slp_sl_thold_2),
      .pc_func_slp_nsl_thold_2(pc_func_slp_nsl_thold_2),
      .pc_regf_slp_sl_thold_2(pc_regf_slp_sl_thold_2),
      .pc_time_sl_thold_2(pc_time_sl_thold_2),
      .pc_fce_2(pc_fce_2),

      .func_scan_in(func_si_cam_int),
      .func_scan_out(func_so_cam_int),
      .regfile_scan_in(regf_scan_in),
      .regfile_scan_out(regf_scan_out),
      .time_scan_in(time_scan_in),
      .time_scan_out(time_scan_out),

      .rd_val(rd_val),
      .rd_val_late(tiup),
      .rw_entry(rw_entry),
      .wr_array_data(wr_array_data),
      .wr_cam_data(wr_cam_data),
      .wr_array_val(wr_array_val),
      .wr_cam_val(wr_cam_val),
      .wr_val_early(wr_val_early),
      .comp_request(comp_request),
      .comp_addr(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .comp_class(comp_class),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .state_enable(state_enable),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .comp_invalidate(comp_invalidate),
      .flash_invalidate(flash_invalidate),

      .array_cmp_data(array_cmp_data),
      .rd_array_data(rd_array_data),
      .cam_cmp_data(cam_cmp_data),
      .cam_hit(cam_hit),
      .cam_hit_entry(cam_hit_entry),
      .entry_match(entry_match),
      .entry_valid(entry_valid),
      .rd_cam_data(rd_cam_data),

      //--- new ports for IO plus -----------------------
      .bypass_mux_enab_np1(bypass_mux_enab_np1),
      .bypass_attr_np1(bypass_attr_np1),
      .attr_np2(attr_np2),
      .rpn_np2(rpn_np2)
   );

   // Parity Calculation
   assign ex4_cam_cmp_data_d          = cam_cmp_data;
   assign ex4_array_cmp_data_d        = array_cmp_data;
   assign ex4_cmp_data_calc_par[50]   = ^(ex4_cam_cmp_data_q[75:82]);
   assign ex4_cmp_data_calc_par[51]   = ^(ex4_cam_cmp_data_q[0:7]);
   assign ex4_cmp_data_calc_par[52]   = ^(ex4_cam_cmp_data_q[8:15]);
   assign ex4_cmp_data_calc_par[53]   = ^(ex4_cam_cmp_data_q[16:23]);
   assign ex4_cmp_data_calc_par[54]   = ^(ex4_cam_cmp_data_q[24:31]);
   assign ex4_cmp_data_calc_par[55]   = ^(ex4_cam_cmp_data_q[32:39]);
   assign ex4_cmp_data_calc_par[56]   = ^(ex4_cam_cmp_data_q[40:47]);
   assign ex4_cmp_data_calc_par[57]   = ^(ex4_cam_cmp_data_q[48:55]);
   assign ex4_cmp_data_calc_par[58]   = ^(ex4_cam_cmp_data_q[57:62]);
   assign ex4_cmp_data_calc_par[59]   = ^(ex4_cam_cmp_data_q[63:66]);
   assign ex4_cmp_data_calc_par[60]   = ^(ex4_cam_cmp_data_q[67:74]);
   assign ex4_cmp_data_calc_par[61]   = ^(ex4_array_cmp_data_q[0:5]);
   assign ex4_cmp_data_calc_par[62]   = ^(ex4_array_cmp_data_q[6:13]);
   assign ex4_cmp_data_calc_par[63]   = ^(ex4_array_cmp_data_q[14:21]);
   assign ex4_cmp_data_calc_par[64]   = ^(ex4_array_cmp_data_q[22:29]);
   assign ex4_cmp_data_calc_par[65]   = ^(ex4_array_cmp_data_q[30:37]);
   assign ex4_cmp_data_calc_par[66]   = ^(ex4_array_cmp_data_q[38:44]);
   assign ex4_cmp_data_calc_par[67]   = ^(ex4_array_cmp_data_q[45:50]);
   assign ex4_cmp_data_parerr_epn_mac = |(ex4_cmp_data_calc_par[50:60] ^ ({ex4_cam_cmp_data_q[83], ex4_array_cmp_data_q[51:60]}));
   assign ex4_cmp_data_parerr_rpn_mac = |(ex4_cmp_data_calc_par[61:67] ^ ex4_array_cmp_data_q[61:67]);

   //---------------------------------------------------------------------
   // ERAT MISS Queue
   //---------------------------------------------------------------------
   // MMU Interrupt Report Logic
   assign mm_int_rpt_itag_d           = mm_lq_itag;
   assign mm_int_rpt_tlbmiss_d        = |(mm_lq_tlb_miss);
   assign mm_int_rpt_tlbinelig_d      = |(mm_lq_tlb_inelig);
   assign mm_int_rpt_ptfault_d        = |(mm_lq_pt_fault);
   assign mm_int_rpt_lratmiss_d       = |(mm_lq_lrat_miss);
   assign mm_int_rpt_tlb_multihit_d   = |(mm_lq_tlb_multihit);
   assign mm_int_rpt_tlb_par_err_d    = |(mm_lq_tlb_par_err);
   assign mm_int_rpt_lru_par_err_d    = |(mm_lq_lru_par_err);
   // ERATM Entry WRT pointer Logic
   // Look for first IDLE state machine from ERATMISSQ(0) -> ERATMISSQ(`EMQ_ENTRIES-1)
   assign eratm_wrt_ptr[0] = eratm_entry_available[0];

   generate begin : EMPriWrt
         genvar emq;
         for (emq = 1; emq <= `EMQ_ENTRIES - 1; emq = emq + 1) begin : EMPriWrt
            assign eratm_wrt_ptr[emq] = &((~eratm_entry_available[0:emq - 1])) & eratm_entry_available[emq];
         end
      end
   endgenerate

   // ERATMISS Queue Update Valid
   assign ex4_eratm_val     = |(ex4_miss_q & (~cp_flush_q)) & (~(spr_ccr2_notlb_q | ex4_gate_miss_q));
   assign ex4_entry_wrt_val = (eratm_wrt_ptr & {`EMQ_ENTRIES{ex4_eratm_val}});
   assign eratm_por_reset   = |(por_hold_req);
   // Instruction check against the ERATMISS Queue is valid
   assign ex3_eratm_chk_val = |(ex3_valid_q & (~cp_flush_q)) & |(ex3_ttype_q[4:5]) & (~ex3_ttype_q[9]);

   // Compare against ex4_epn that will be updating the ERATMISS Queue with the ex3_epn
   // The ERATMISS Queue epn is valid in ex5, so this covers the back-2-back case
   assign ex3_eratm_epn_m = ex3_eratm_chk_val & ex4_eratm_val & (ex4_epn_q == ex3_epn_q) & (~ex3_oldest_itag);

   generate begin : ERATMQ
         genvar emq;
         for (emq = 0; emq <= `EMQ_ENTRIES - 1; emq = emq + 1) begin : ERATMQ

            assign eratm_tlb_rel_val[emq] = |(tlb_rel_val_q[0:3]) & tlb_rel_emq_q[emq];

            always @(*) begin: emqState
               eratm_entry_nxt_state[emq]     <= EMQ_IDLE;
               eratm_entry_nonspec_val_d[emq] <= eratm_entry_nonspec_val_q[emq];
               eratm_entry_clr_hold[emq]      <= 1'b0;
               case (eratm_entry_state_q[emq])

                  EMQ_IDLE :
                     if (ex4_entry_wrt_val[emq] == 1'b1)
                     begin
                        eratm_entry_nxt_state[emq]     <= EMQ_RPEN;
                        eratm_entry_nonspec_val_d[emq] <= ex4_nonspec_val_q;
                     end
                     else
                     begin
                        eratm_entry_nxt_state[emq]     <= EMQ_IDLE;
                        eratm_entry_nonspec_val_d[emq] <= 1'b0;
                     end

                  EMQ_RPEN :
                     if ((eratm_por_reset == 1'b1) | (ex5_emq_tlbreq_blk[emq] == 1'b1) | (eratm_tlb_rel_val[emq] == 1'b1 & (eratm_entry_int_det[emq] == 1'b0 | eratm_entry_nonspec_val_q[emq] == 1'b0)))
                     begin
                        eratm_entry_nxt_state[emq]     <= EMQ_IDLE;
                        eratm_entry_clr_hold[emq]      <= 1'b1;
                        eratm_entry_nonspec_val_d[emq] <= 1'b0;
                     end
                     else if (eratm_tlb_rel_val[emq] == 1'b1 & eratm_entry_int_det[emq] == 1'b1 & eratm_entry_nonspec_val_q[emq] == 1'b1)
                     begin
                        eratm_entry_nxt_state[emq]     <= EMQ_REXCP;
                        eratm_entry_clr_hold[emq]      <= 1'b1;
                     end
                     else
                        eratm_entry_nxt_state[emq]     <= EMQ_RPEN;

                  EMQ_REXCP :
                     if (eratm_entry_cpl[emq] == 1'b1)
                     begin
                        eratm_entry_nxt_state[emq]     <= EMQ_IDLE;
                        eratm_entry_clr_hold[emq]      <= 1'b1;
                        eratm_entry_nonspec_val_d[emq] <= 1'b0;
                     end
                     else
                        eratm_entry_nxt_state[emq]     <= EMQ_REXCP;

                  default :
                     begin
                        eratm_entry_nxt_state[emq]     <= EMQ_IDLE;
                        eratm_entry_nonspec_val_d[emq] <= eratm_entry_nonspec_val_q[emq];
                        eratm_entry_clr_hold[emq]      <= 1'b0;
                     end
               endcase
            end

            assign eratm_entry_state_d[emq]       = eratm_entry_nxt_state[emq];

            if (emq == 0) begin : entryZero
               assign eratm_entry_available[emq] = eratm_entry_state_q[emq][0] & ex4_oldest_itag_q;
            end

            if (emq != 0) begin : entryNZero
               assign eratm_entry_available[emq] = eratm_entry_state_q[emq][0] & (~ex4_oldest_itag_q);
            end

            assign eratm_entry_cpl[emq]            = ex6_emq_excp_rpt[emq] | (|(por_hold_req)) | eratm_entry_kill[emq];
            assign eratm_entry_itag_d[emq]         = (ex4_entry_wrt_val[emq] == 1'b1) ? ex4_itag_q :
                                                     eratm_entry_itag_q[emq];
            assign eratm_entry_tid_d[emq]          = (ex4_entry_wrt_val[emq] == 1'b1) ? ex4_valid_q :
                                                     eratm_entry_tid_q[emq];
            assign eratm_entry_epn_d[emq]          = (ex4_entry_wrt_val[emq] == 1'b1) ? ex4_epn_q :
                                                     eratm_entry_epn_q[emq];
            assign eratm_entry_mkill[emq]          = (~eratm_entry_state_q[emq][0]) & (|(eratm_entry_tid_q[emq] & cp_flush_q));
            assign eratm_entry_kill[emq]           = eratm_entry_mkill[emq] | eratm_entry_mkill_q[emq];
            assign eratm_entry_mkill_d[emq]        = ({ex4_entry_wrt_val[emq], eratm_entry_mkill[emq]} == 2'b00) ? eratm_entry_mkill_q[emq] :
                                                     ({ex4_entry_wrt_val[emq], eratm_entry_mkill[emq]} == 2'b01) ? 1'b1 :
                                                     1'b0;
            assign eratm_entry_tid_inuse[emq]      = eratm_entry_tid_q[emq] & {`THREADS{~eratm_entry_state_q[emq][0]}};
            assign eratm_entry_inuse[emq]          = (~(eratm_entry_state_q[emq][0])) | (ex4_entry_wrt_val[emq]);
            assign eratm_entry_relPend[emq]        = eratm_entry_state_q[emq][1];
            assign ex3_eratm_epn_hit[emq]          = ex3_eratm_chk_val & (eratm_entry_epn_q[emq] == ex3_epn_q);
            assign ex3_eratm_epn_hit_restart[emq]  = ex3_eratm_epn_hit[emq] & eratm_entry_state_q[emq][1] & (~ex3_oldest_itag);

            assign ex2_eratm_itag_hit[emq]         = (eratm_entry_itag_q[emq] == ex2_itag_q) & (|(ex2_valid_q & eratm_entry_tid_q[emq])) &
                                                     ~(eratm_entry_kill[emq] | eratm_entry_state_q[emq][0]);
            assign ex3_eratm_itag_hit_d[emq]       = ex2_eratm_itag_hit[emq];
            assign ex3_eratm_itag_hit[emq]         = ex3_eratm_itag_hit_q[emq] & |(ex3_valid_q & ~cp_flush_q); // Gate Cache Access to Data and Dir if ITAG hit
            assign ex3_eratm_itag_hit_restart[emq] = ex3_eratm_itag_hit[emq] & ~eratm_entry_state_q[emq][2];   // Restart if it wasnt IDLE in EX2 and not currently in REXCP state
            assign ex3_eratm_itag_hit_setHold[emq] = ex3_eratm_itag_hit[emq] &  eratm_entry_state_q[emq][1];   // SetHold only if Reload is Pending
            assign ex3_eratm_hit_report[emq]       = ex3_eratm_itag_hit[emq] &  eratm_entry_state_q[emq][2];   // Report Exception only if in REXCP state
            assign ex3_eratm_hit_restart[emq]      = ex3_eratm_itag_hit_restart[emq] | ex3_eratm_epn_hit_restart[emq];
            assign ex3_eratm_hit_setHold[emq]      = (ex3_eratm_itag_hit_setHold[emq] | ex3_eratm_epn_hit_restart[emq]) & ~eratm_entry_clr_hold[emq];
            assign mm_int_rpt_tlbmiss_val[emq]     = eratm_entry_state_q[emq][1] & mm_int_rpt_tlbmiss_q & rel_int_upd_val_q[emq];
            assign eratm_entry_tlbmiss_d[emq]      = ({ex4_entry_wrt_val[emq], mm_int_rpt_tlbmiss_val[emq]} == 2'b00) ? eratm_entry_tlbmiss_q[emq] :
                                                     ({ex4_entry_wrt_val[emq], mm_int_rpt_tlbmiss_val[emq]} == 2'b01) ? mm_int_rpt_tlbmiss_q :
                                                     1'b0;
            assign mm_int_rpt_tlbinelig_val[emq]   = eratm_entry_state_q[emq][1] & mm_int_rpt_tlbinelig_q & rel_int_upd_val_q[emq];
            assign eratm_entry_tlbinelig_d[emq]    = ({ex4_entry_wrt_val[emq], mm_int_rpt_tlbinelig_val[emq]} == 2'b00) ? eratm_entry_tlbinelig_q[emq] :
                                                     ({ex4_entry_wrt_val[emq], mm_int_rpt_tlbinelig_val[emq]} == 2'b01) ? mm_int_rpt_tlbinelig_q :
                                                     1'b0;
            assign mm_int_rpt_ptfault_val[emq]     = eratm_entry_state_q[emq][1] & mm_int_rpt_ptfault_q & rel_int_upd_val_q[emq];
            assign eratm_entry_ptfault_d[emq]      = ({ex4_entry_wrt_val[emq], mm_int_rpt_ptfault_val[emq]} == 2'b00) ? eratm_entry_ptfault_q[emq] :
                                                     ({ex4_entry_wrt_val[emq], mm_int_rpt_ptfault_val[emq]} == 2'b01) ? mm_int_rpt_ptfault_q :
                                                     1'b0;
            assign mm_int_rpt_lratmiss_val[emq]    = eratm_entry_state_q[emq][1] & mm_int_rpt_lratmiss_q & rel_int_upd_val_q[emq];
            assign eratm_entry_lratmiss_d[emq]     = ({ex4_entry_wrt_val[emq], mm_int_rpt_lratmiss_val[emq]} == 2'b00) ? eratm_entry_lratmiss_q[emq] :
                                                     ({ex4_entry_wrt_val[emq], mm_int_rpt_lratmiss_val[emq]} == 2'b01) ? mm_int_rpt_lratmiss_q :
                                                     1'b0;
            assign mm_int_rpt_tlb_multihit_val[emq]= eratm_entry_state_q[emq][1] & mm_int_rpt_tlb_multihit_q & rel_int_upd_val_q[emq];
            assign eratm_entry_tlb_multihit_d[emq] = ({ex4_entry_wrt_val[emq], mm_int_rpt_tlb_multihit_val[emq]} == 2'b00) ? eratm_entry_tlb_multihit_q[emq] :
                                                     ({ex4_entry_wrt_val[emq], mm_int_rpt_tlb_multihit_val[emq]} == 2'b01) ? mm_int_rpt_tlb_multihit_q :
                                                     1'b0;
            assign mm_int_rpt_tlb_par_err_val[emq] = eratm_entry_state_q[emq][1] & mm_int_rpt_tlb_par_err_q & rel_int_upd_val_q[emq];
            assign eratm_entry_tlb_par_err_d[emq]  = ({ex4_entry_wrt_val[emq], mm_int_rpt_tlb_par_err_val[emq]} == 2'b00) ? eratm_entry_tlb_par_err_q[emq] :
                                                     ({ex4_entry_wrt_val[emq], mm_int_rpt_tlb_par_err_val[emq]} == 2'b01) ? mm_int_rpt_tlb_par_err_q :
                                                     1'b0;
            assign mm_int_rpt_lru_par_err_val[emq] = eratm_entry_state_q[emq][1] & mm_int_rpt_lru_par_err_q & rel_int_upd_val_q[emq];
            assign eratm_entry_lru_par_err_d[emq]  = ({ex4_entry_wrt_val[emq], mm_int_rpt_lru_par_err_val[emq]} == 2'b00) ? eratm_entry_lru_par_err_q[emq] :
                                                     ({ex4_entry_wrt_val[emq], mm_int_rpt_lru_par_err_val[emq]} == 2'b01) ? mm_int_rpt_lru_par_err_q :
                                                     1'b0;
            assign eratm_entry_int_det[emq]        = eratm_entry_tlbmiss_q[emq] | eratm_entry_tlbinelig_q[emq] | eratm_entry_ptfault_q[emq] | eratm_entry_lratmiss_q[emq] | eratm_entry_tlb_multihit_q[emq] | eratm_entry_tlb_par_err_q[emq] | eratm_entry_lru_par_err_q[emq];
         end
      end
   endgenerate

   // Request is the oldest ITAG
   assign ex3_oldest_itag      = (lsq_ctl_oldest_itag == ex3_itag_q) & (|(lsq_ctl_oldest_tid & ex3_valid_q));
   assign ex4_oldest_itag_d    = ex3_oldest_itag;

   generate begin : cpNextItag
         genvar tid;
         for (tid = 0; tid <= `THREADS - 1; tid = tid + 1) begin : cpNextItag
            assign ex3_cp_next_tid[tid] = ex3_valid_q[tid] & cp_next_val_q[tid] & (ex3_itag_q == cp_next_itag_q[tid]);
         end
      end
   endgenerate

   // Thread Quiesced OR reduce
   always @(*) begin: tidQuiesce
      reg [0:`THREADS-1]                                      tidQ;

      (* analysis_not_referenced="true" *)

      integer                                                 emq;
      tidQ = {`THREADS{1'b0}};
      for (emq=0; emq<`EMQ_ENTRIES; emq=emq+1) begin
         tidQ = (eratm_entry_tid_inuse[emq]) | tidQ;
      end
      emq_tid_idle <= ~tidQ;
   end

   assign ex3_nonspec_val      = |(ex3_cp_next_tid);
   assign ex4_nonspec_val_d    = ex3_nonspec_val;
   assign ex3_emq_tlbmiss      = ex3_eratm_hit_report & eratm_entry_tlbmiss_q;
   assign ex3_emq_tlbinelig    = ex3_eratm_hit_report & eratm_entry_tlbinelig_q;
   assign ex3_emq_ptfault      = ex3_eratm_hit_report & eratm_entry_ptfault_q;
   assign ex3_emq_lratmiss     = ex3_eratm_hit_report & eratm_entry_lratmiss_q;
   assign ex3_emq_multihit     = ex3_eratm_hit_report & eratm_entry_tlb_multihit_q;
   assign ex3_emq_tlb_par      = ex3_eratm_hit_report & eratm_entry_tlb_par_err_q;
   assign ex3_emq_lru_par      = ex3_eratm_hit_report & eratm_entry_lru_par_err_q;
   assign ex3_tlbmiss          = |(ex3_emq_tlbmiss);
   assign ex4_tlbmiss_d        = ex3_tlbmiss;
   assign ex3_tlbinelig        = |(ex3_emq_tlbinelig);
   assign ex4_tlbinelig_d      = ex3_tlbinelig;
   assign ex3_ptfault          = |(ex3_emq_ptfault);
   assign ex4_ptfault_d        = ex3_ptfault;
   assign ex3_lratmiss         = |(ex3_emq_lratmiss);
   assign ex4_lratmiss_d       = ex3_lratmiss;
   assign ex3_tlb_multihit     = |(ex3_emq_multihit);
   assign ex4_tlb_multihit_d   = ex3_tlb_multihit;
   assign ex3_tlb_par_err      = |(ex3_emq_tlb_par);
   assign ex4_tlb_par_err_d    = ex3_tlb_par_err;
   assign ex3_lru_par_err      = |(ex3_emq_lru_par);
   assign ex4_lru_par_err_d    = ex3_lru_par_err;
   assign ex4_tlb_excp_det_d   = ex3_tlbmiss | ex3_tlbinelig | ex3_ptfault | ex3_lratmiss | ex3_tlb_multihit | ex3_tlb_par_err | ex3_lru_par_err;
   assign ex4_emq_excp_rpt_d   = ex3_emq_tlbmiss | ex3_emq_tlbinelig | ex3_emq_ptfault | ex3_emq_lratmiss | ex3_emq_multihit | ex3_emq_tlb_par | ex3_emq_lru_par;
   assign ex5_emq_excp_rpt_d   = ex4_emq_excp_rpt_q;
   assign ex6_emq_excp_rpt_d   = ex5_emq_excp_rpt_q;
   assign ex5_tlb_excp_val_d   = (ex4_valid_q & {`THREADS{ex4_tlb_excp_det_q}}) & (~cp_flush_q);
   assign ex6_tlb_excp_val_d   = ex5_tlb_excp_val_q & (~cp_flush_q);
   assign ex6_tlb_cplt_val     = |(ex6_tlb_excp_val_q & dcc_derat_ex6_cplt) & (ex6_itag_q == dcc_derat_ex6_cplt_itag);
   assign ex6_emq_excp_rpt     = (ex6_emq_excp_rpt_q & {`EMQ_ENTRIES{ex6_tlb_cplt_val}});
   // ERATM State Machines are all busy
   // ERAT FULL Cases
   // 1) All entries are in use
   // 2) Oldest ITAG and entry 0 is in use (entry 0 is reserved for oldest, but oldest could have been flushed so new oldest cant use it)
   // 3) Not the oldest ITAG and all entries except 0 are in use
   assign ex3_eratm_full         = &(eratm_entry_inuse) | (ex3_oldest_itag & eratm_entry_inuse[0]) | ((~ex3_oldest_itag) & (&(eratm_entry_inuse[1:`EMQ_ENTRIES - 1])));
   // Request needs to restart
   assign ex4_gate_miss_d        = (|(ex3_eratm_hit_restart)) | ex3_eratm_epn_m | ex3_eratm_full | (|(ex3_eratm_hit_report));
   assign ex4_full_restart_d     = ex3_eratm_full;
   assign ex4_epn_hit_restart_d  = |(ex3_eratm_epn_hit_restart) | ex3_eratm_epn_m;
   assign ex4_itag_hit_restart_d = |(ex3_eratm_itag_hit_restart);
   assign ex4_setHold_d          = |(ex3_eratm_hit_setHold) | ex3_eratm_epn_m | (ex3_eratm_full & (~(|(eratm_entry_clr_hold))));
   // Request to the MMU Valid
   assign ex4_tlbreq_val         = |((ex4_miss_q & (~cp_flush_q))) & (~(spr_ccr2_notlb_q | ex4_gate_miss_q));
   assign ex5_tlbreq_val_d       = ex4_tlbreq_val;
   assign ex5_tlbreq_val         = ex5_tlbreq_val_q & (~dcc_derat_ex5_blk_tlb_req);
   assign ex5_tlbreq_nonspec_d   = ex4_nonspec_val_q;
   assign ex5_thdid_d            = ex4_valid_q;
   assign ex5_emq_d              = eratm_wrt_ptr;
   assign ex5_tlbreq_ttype_d     = (ex4_ttype_q[11] == 1'b1) ? 2'b11 :
                                   (ex4_ttype_q[10] == 1'b1) ? 2'b10 :
                                   (ex4_ttype_q[5] == 1'b1) ? 2'b01 :
                                   2'b00;
   assign ex5_perf_dtlb_d        = {`THREADS{((ex4_miss_w_tlb | ex4_miss_wo_tlb) & ~ex4_gate_miss_q)}} & ex4_valid_q & ~cp_flush_q;

   // Request to the MMU was blocked due to a higher priority interrupt
   assign ex5_tlbreq_blk         = ex5_tlbreq_val_q & dcc_derat_ex5_blk_tlb_req;
   assign ex5_emq_tlbreq_blk     = (ex5_emq_q & {`EMQ_ENTRIES{ex5_tlbreq_blk}});
   // Need to restart the request for the following reasons
   // 1) ERATM State machines are all busy
   // 2) ERATM State machines 1 to `EMQ_ENTRIES are busy and
   //    this request is not the oldest
   // 3) Current Requests ITAG is already using a state machine
   // 4) Current Requests derat misses EPN hit an outstanding MMU requests EPN
   // 5) Current Requests is sending the NonSpeculative Request to the TLB
   // Dont want to restart if current request is sending DERAT MISS indicator or TLB Exception detected
   assign ex4_full_restart       = |(ex4_miss_q) & (ex4_full_restart_q | ex4_nonspec_val_q);
   assign ex4_hit_restart        = ex4_itag_hit_restart_q | (|(ex4_miss_q) & ex4_epn_hit_restart_q);
   assign ex4_derat_restart      = (ex4_full_restart | ex4_hit_restart) & (~(spr_ccr2_notlb_q | ex4_tlb_excp_det_q));
   assign ex4_setHold            = ex4_eratm_val | (ex4_derat_restart & ex4_setHold_q);
   assign ex4_setHold_tid        = (ex4_valid_q & {`THREADS{ex4_setHold}});
   assign eratm_clrHold          = |(eratm_entry_clr_hold);
   assign eratm_clrHold_tid      = {`THREADS{eratm_clrHold}};

   generate begin : holdTid
         genvar                            tid;
         for (tid = 0; tid <= `THREADS - 1; tid = tid + 1) begin : holdTid
            assign eratm_setHold_tid_ctrl[tid] = {ex4_setHold_tid[tid], eratm_clrHold_tid[tid]};
            assign eratm_hold_tid_d[tid] = (eratm_setHold_tid_ctrl[tid] == 2'b00) ? eratm_hold_tid_q[tid] :
                                           (eratm_setHold_tid_ctrl[tid] == 2'b10) ? ex4_setHold_tid[tid] :
                                           1'b0;
         end
      end
   endgenerate

   assign derat_dcc_ex3_itagHit = |ex3_eratm_itag_hit;
   assign derat_dcc_ex4_restart = ex4_derat_restart;
   assign derat_dcc_ex4_setHold = ex4_setHold;
   assign derat_dcc_clr_hold_d  = eratm_clrHold_tid;
   assign derat_dcc_clr_hold    = derat_dcc_clr_hold_q;
   assign derat_dcc_emq_idle    = emq_tid_idle;
   //---------------------------------------------------------------------
   // Effective Address equals Real Address Muxing
   assign ex4_rpn_d[22:33] = (ex3_comp_addr_q[22:33] & ({12{bypass_mux_enab_np1}})) | (array_cmp_data[0:11] & ({12{(~bypass_mux_enab_np1)}}));
   assign ex4_rpn_d[34:39] = (ex3_comp_addr_q[34:39] & ({6{(((~cam_cmp_data[75])) | bypass_mux_enab_np1)}})) | (array_cmp_data[12:17] & ({6{(cam_cmp_data[75] & (~bypass_mux_enab_np1))}}));
   assign ex4_rpn_d[40:43] = (ex3_comp_addr_q[40:43] & ({4{(((~cam_cmp_data[76])) | bypass_mux_enab_np1)}})) | (array_cmp_data[18:21] & ({4{(cam_cmp_data[76] & (~bypass_mux_enab_np1))}}));
   assign ex4_rpn_d[44:47] = (ex3_comp_addr_q[44:47] & ({4{(((~cam_cmp_data[77])) | bypass_mux_enab_np1)}})) | (array_cmp_data[22:25] & ({4{(cam_cmp_data[77] & (~bypass_mux_enab_np1))}}));
   assign ex4_rpn_d[48:51] = (ex3_comp_addr_q[48:51] & ({4{(((~cam_cmp_data[78])) | bypass_mux_enab_np1)}})) | (array_cmp_data[26:29] & ({4{(cam_cmp_data[78] & (~bypass_mux_enab_np1))}}));
   assign ex4_wimge_d      = (array_cmp_data[40:44] & {5{(~bypass_mux_enab_np1)}}) | (bypass_attr_np1[10:14] & {5{bypass_mux_enab_np1}});

   // bypass attributes (bit numbering per array)
   //  30:31  - R,C
   //  32:33  - WLC
   //  34  - ResvAttr
   //  35  - VF
   //  36:39  - U0-U3
   //  40:44  - WIMGE
   //  45:46  - UX,SX
   //  47:48  - UW,SW
   //  49:50  - UR,SR
   assign derat_dcc_ex4_rpn      = ex4_rpn_q;
   assign derat_dcc_ex4_wimge    = ex4_wimge_q;
   assign derat_dcc_ex4_u        = attr_np2[6:9];
   assign derat_dcc_ex4_wlc      = attr_np2[2:3];
   assign derat_dcc_ex4_attr     = attr_np2[15:20];
   assign derat_dcc_ex4_vf       = attr_np2[5] & (~(|(ex4_miss_q)));

   // ERAT Operation is Complete
   assign lq_xu_ord_write_done_d = |(ex4_valid) & (ex4_ttype_q[0] | ex4_ttype_q[2]);
   assign lq_xu_ord_read_done_d  = |(ex4_valid) & ex4_ttype_q[1];
   assign lq_xu_ord_write_done   = lq_xu_ord_write_done_q;
   assign lq_xu_ord_read_done    = lq_xu_ord_read_done_q;

   // debug bus outputs
   assign ex3_debug_d[0]     = comp_request;
   assign ex3_debug_d[1]     = comp_invalidate;
   assign ex3_debug_d[2]     = (csinv_complete);
   assign ex3_debug_d[3]     = ((eplc_wr_q[2 * `THREADS] | epsc_wr_q[2 * `THREADS]) & (~(tlb_rel_val_q[4])) & (~(mmucr1_q[7])));
   assign ex3_debug_d[4]     = (snoop_val_q[0] & snoop_val_q[1] & (~(|(tlb_rel_val_q[0:3]))));
   assign ex3_debug_d[5]     = (|(ex2_valid_op_q) & ex2_ttype_q[2] & (ex2_tlbsel_q == TlbSel_DErat));
   assign ex3_debug_d[6]     = (|(ex2_valid) & (|(ex2_ttype_q[4:5])));
   assign ex3_debug_d[7]     = (|(tlb_rel_val_q[0:3]) & tlb_rel_val_q[4]);
   assign ex3_debug_d[8]     = (|(tlb_rel_val_q[0:3]));
   assign ex3_debug_d[9]     = (snoop_val_q[0] & snoop_val_q[1]);
   assign ex3_debug_d[10]    = (eplc_wr_q[2 * `THREADS] | epsc_wr_q[2 * `THREADS]);
   assign ex4_debug_d[0:10]  = ex3_debug_q[0:10];
   assign ex4_debug_d[11:15] = ex4_first_hit_entry;
   assign ex4_debug_d[16]    = ex3_multihit;
   assign lru_debug_d[0]     = lru_update_event_q[0];
   assign lru_debug_d[1]     = lru_update_event_q[1];
   assign lru_debug_d[2]     = lru_update_event_q[2];
   assign lru_debug_d[3]     = lru_update_event_q[3];
   assign lru_debug_d[4]     = lru_update_event_q[4] & cam_hit;
   assign lru_debug_d[5:35]  = lru_eff;
   assign lru_debug_d[36:40] = lru_way_encode;
   // debug groups:  out std_ulogic_vector(0 to 87);
   assign derat_xu_debug_group0[0:83]  = ex4_cam_cmp_data_q[0:83];
   assign derat_xu_debug_group0[84]    = ex4_cam_hit_q;
   assign derat_xu_debug_group0[85]    = ex4_debug_q[0];
   assign derat_xu_debug_group0[86]    = ex4_debug_q[1];
   assign derat_xu_debug_group0[87]    = ex4_debug_q[9];
   assign derat_xu_debug_group1[0:67]  = ex4_array_cmp_data_q[0:67];
   assign derat_xu_debug_group1[68]    = ex4_cam_hit_q;
   assign derat_xu_debug_group1[69]    = ex4_debug_q[16];
   assign derat_xu_debug_group1[70:74] = ex4_debug_q[11:15];
   assign derat_xu_debug_group1[75]    = ex4_debug_q[0];
   assign derat_xu_debug_group1[76]    = ex4_debug_q[1];
   assign derat_xu_debug_group1[77]    = ex4_debug_q[2];
   assign derat_xu_debug_group1[78]    = ex4_debug_q[3];
   assign derat_xu_debug_group1[79]    = ex4_debug_q[4];
   assign derat_xu_debug_group1[80]    = ex4_debug_q[5];
   assign derat_xu_debug_group1[81]    = ex4_debug_q[6];
   assign derat_xu_debug_group1[82]    = ex4_debug_q[7];
   assign derat_xu_debug_group1[83]    = ex4_debug_q[8];
   assign derat_xu_debug_group1[84]    = ex4_debug_q[9];
   assign derat_xu_debug_group1[85]    = ex4_debug_q[10];
   assign derat_xu_debug_group1[86]    = ex4_ttype_q[8];
   assign derat_xu_debug_group1[87]    = ex4_ttype_q[9];
   assign derat_xu_debug_group2[0:31]  = entry_valid_q[0:31];
   assign derat_xu_debug_group2[32:63] = entry_match_q[0:31];
   assign derat_xu_debug_group2[64:73] = lru_update_event_q[0:9];
   assign derat_xu_debug_group2[74:78] = lru_debug_q[36:40];
   assign derat_xu_debug_group2[79:83] = watermark_q[0:4];
   assign derat_xu_debug_group2[84]    = ex4_cam_hit_q;
   assign derat_xu_debug_group2[85]    = ex4_debug_q[0];
   assign derat_xu_debug_group2[86]    = ex4_debug_q[1];
   assign derat_xu_debug_group2[87]    = ex4_debug_q[9];
   assign derat_xu_debug_group3[0]     = ex4_cam_hit_q;
   assign derat_xu_debug_group3[1]     = ex4_debug_q[0];
   assign derat_xu_debug_group3[2]     = ex4_debug_q[1];
   assign derat_xu_debug_group3[3]     = ex4_debug_q[9];
   assign derat_xu_debug_group3[4:8]   = ex4_debug_q[11:15];
   assign derat_xu_debug_group3[9]     = lru_update_event_q[9];
   assign derat_xu_debug_group3[10:14] = lru_debug_q[0:4];
   assign derat_xu_debug_group3[15:19] = watermark_q[0:4];
   assign derat_xu_debug_group3[20]    = 1'b0;
   assign derat_xu_debug_group3[21:51] = lru_q[1:31];
   assign derat_xu_debug_group3[52:82] = lru_debug_q[5:35];
   assign derat_xu_debug_group3[83:87] = lru_debug_q[36:40];
   // unused spare signal assignments
   assign unused_dc[0] = |(lcb_delay_lclkr_dc[1:4]);
   assign unused_dc[1] = |(lcb_mpw1_dc_b[1:4]);
   assign unused_dc[2] = mchk_flash_inv_q[3];
   assign unused_dc[3] = 1'b0;
   assign unused_dc[4] = pc_func_sl_force;
   assign unused_dc[5] = pc_func_sl_thold_0_b;
   assign unused_dc[6] = 1'b0;
   assign unused_dc[7] = |(ex2_rs_is_q);
   assign unused_dc[8] = |(ex2_ra_entry_q);
   assign unused_dc[9] = |(cam_hit_entry);
   assign unused_dc[10] = |(ex3_first_hit_entry);
   assign unused_dc[11] = |(ex4_dsi_q[8:8 + `THREADS - 1]);
   assign unused_dc[12] = |(ex4_noop_touch_q[1:2]);
   assign unused_dc[13] = |(ex4_noop_touch_q[8:8 + `THREADS - 1]);
   assign unused_dc[14] = |(ex4_attr_q);
   assign unused_dc[15] = ex4_rd_cam_data_q[56];
   assign unused_dc[16] = |(ex7_rs_is_q);
   assign unused_dc[17] = ex7_state_q[0];
   assign unused_dc[18] = ex8_ttype_q[0];
   assign unused_dc[19] = |(ex8_ttype_q[2:11]);
   assign unused_dc[20] = |(tlb_rel_data_q[eratpos_rpnrsvd:eratpos_rpnrsvd + 3]);
   assign unused_dc[21] = 1'b0;
   assign unused_dc[22] = 1'b0;
   assign unused_dc[23] = 1'b0;
   assign unused_dc[24] = |(attr_np2[0:1]);
   assign unused_dc[25] = attr_np2[4];
   assign unused_dc[26] = mmucr1_b0_cpy_q;
   assign unused_dc[27] = |(bcfg_q_b[0:15]);
   assign unused_dc[28] = |(bcfg_q_b[16:31]);
   assign unused_dc[29] = |(bcfg_q_b[32:47]);
   assign unused_dc[30] = |(bcfg_q_b[48:51]);
   assign unused_dc[31] = |(bcfg_q_b[52:61]);
   assign unused_dc[32] = |(bcfg_q_b[62:77]);
   assign unused_dc[33] = |(bcfg_q_b[78:81]);
   assign unused_dc[34] = |(bcfg_q_b[82:86]);
   assign unused_dc[35] = |(por_wr_array_data[51:67]);
   assign unused_dc[36] = |(bcfg_q_b[87:102]);
   assign unused_dc[37] = |(bcfg_q_b[103:106]);
   assign unused_dc[38] = |(bcfg_q[107:122]);
   assign unused_dc[39] = |(bcfg_q_b[107:122]);
   //---------------------------------------------------------------------
   // Latches
   //---------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_hv_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_msr_hv_offset:spr_msr_hv_offset + `THREADS - 1]),
      .scout(sov_0[spr_msr_hv_offset:spr_msr_hv_offset + `THREADS - 1]),
      .din(spr_msr_hv_d),
      .dout(spr_msr_hv_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_pr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_msr_pr_offset:spr_msr_pr_offset + `THREADS - 1]),
      .scout(sov_0[spr_msr_pr_offset:spr_msr_pr_offset + `THREADS - 1]),
      .din(spr_msr_pr_d),
      .dout(spr_msr_pr_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_ds_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_msr_ds_offset:spr_msr_ds_offset + `THREADS - 1]),
      .scout(sov_0[spr_msr_ds_offset:spr_msr_ds_offset + `THREADS - 1]),
      .din(spr_msr_ds_d),
      .dout(spr_msr_ds_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_cm_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_msr_cm_offset:spr_msr_cm_offset + `THREADS - 1]),
      .scout(sov_0[spr_msr_cm_offset:spr_msr_cm_offset + `THREADS - 1]),
      .din(spr_msr_cm_d),
      .dout(spr_msr_cm_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_ccr2_notlb_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_ccr2_notlb_offset]),
      .scout(sov_0[spr_ccr2_notlb_offset]),
      .din(spr_ccr2_notlb_d),
      .dout(spr_ccr2_notlb_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) mchk_flash_inv_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mchk_flash_inv_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[mchk_flash_inv_offset:mchk_flash_inv_offset + 4 - 1]),
      .scout(sov_0[mchk_flash_inv_offset:mchk_flash_inv_offset + 4 - 1]),
      .din(mchk_flash_inv_d),
      .dout(mchk_flash_inv_q)
   );

   tri_rlmlatch_p #(.INIT(1), .NEEDS_SRESET(1)) xucr4_mmu_mchk_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[xucr4_mmu_mchk_offset]),
      .scout(sov_0[xucr4_mmu_mchk_offset]),
      .din(xu_lq_spr_xucr4_mmu_mchk),
      .dout(xucr4_mmu_mchk_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_next_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[cp_next_val_offset:cp_next_val_offset + `THREADS - 1]),
      .scout(sov_0[cp_next_val_offset:cp_next_val_offset + `THREADS - 1]),
      .din(cp_next_val_d),
      .dout(cp_next_val_q)
   );
   generate

         genvar tid;

         for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
         begin : cp_next_itag

            tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) cp_next_itag_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(tiup),
               .thold_b(pc_func_slp_sl_thold_0_b),
               .sg(pc_sg_0),
               .force_t(pc_func_slp_sl_force),
               .delay_lclkr(lcb_delay_lclkr_dc[0]),
               .mpw1_b(lcb_mpw1_dc_b[0]),
               .mpw2_b(lcb_mpw2_dc_b),
               .d_mode(lcb_d_mode_dc),
               .scin(siv_0[cp_next_itag_offset + `ITAG_SIZE_ENC * tid:cp_next_itag_offset + `ITAG_SIZE_ENC * (tid + 1) - 1]),
               .scout(sov_0[cp_next_itag_offset + `ITAG_SIZE_ENC * tid:cp_next_itag_offset + `ITAG_SIZE_ENC * (tid + 1) - 1]),
               .din(iu_lq_cp_next_itag[tid*`ITAG_SIZE_ENC:(tid*`ITAG_SIZE_ENC)+`ITAG_SIZE_ENC-1]),
               .dout(cp_next_itag_q[tid])
            );
         end

         for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
         begin : rpn_holdreg

            tri_rlmreg_p #(.WIDTH(64), .INIT(0), .NEEDS_SRESET(1)) rpn_holdreg_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(tiup),
               .thold_b(pc_func_slp_sl_thold_0_b),
               .sg(pc_sg_0),
               .force_t(pc_func_slp_sl_force),
               .delay_lclkr(lcb_delay_lclkr_dc[0]),
               .mpw1_b(lcb_mpw1_dc_b[0]),
               .mpw2_b(lcb_mpw2_dc_b),
               .d_mode(lcb_d_mode_dc),
               .scin(siv_1[rpn_holdreg_offset + (64 * tid):rpn_holdreg_offset + (64 * (tid + 1)) - 1]),
               .scout(sov_1[rpn_holdreg_offset + (64 * tid):rpn_holdreg_offset + (64 * (tid + 1)) - 1]),
               .din(rpn_holdreg_d[tid][0:63]),
               .dout(rpn_holdreg_q[tid][0:63])
            );
         end

    endgenerate

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_byte_rev_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_byte_rev_offset]),
      .scout(sov_0[ex2_byte_rev_offset]),
      .din(ex2_byte_rev_d),
      .dout(ex2_byte_rev_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_byte_rev_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_byte_rev_offset]),
      .scout(sov_0[ex3_byte_rev_offset]),
      .din(ex3_byte_rev_d),
      .dout(ex3_byte_rev_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex1_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex1_valid_offset:ex1_valid_offset + `THREADS - 1]),
      .scout(sov_0[ex1_valid_offset:ex1_valid_offset + `THREADS - 1]),
      .din(ex1_valid_d[0:`THREADS - 1]),
      .dout(ex1_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex1_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex1_ttype_offset:ex1_ttype_offset + 2 - 1]),
      .scout(sov_0[ex1_ttype_offset:ex1_ttype_offset + 2 - 1]),
      .din(ex1_ttype_d),
      .dout(ex1_ttype_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex2_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_valid_offset:ex2_valid_offset + `THREADS - 1]),
      .scout(sov_0[ex2_valid_offset:ex2_valid_offset + `THREADS - 1]),
      .din(ex2_valid_d[0:`THREADS - 1]),
      .dout(ex2_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex2_pfetch_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_pfetch_val_offset:ex2_pfetch_val_offset + `THREADS - 1]),
      .scout(sov_0[ex2_pfetch_val_offset:ex2_pfetch_val_offset + `THREADS - 1]),
      .din(ex2_pfetch_val_d[0:`THREADS - 1]),
      .dout(ex2_pfetch_val_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex2_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_itag_offset:ex2_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov_0[ex2_itag_offset:ex2_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ex2_itag_d[0:`ITAG_SIZE_ENC - 1]),
      .dout(ex2_itag_q[0:`ITAG_SIZE_ENC - 1])
   );

   tri_rlmreg_p #(.WIDTH(ttype_width), .INIT(0), .NEEDS_SRESET(1)) ex2_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_ttype_offset:ex2_ttype_offset + ttype_width - 1]),
      .scout(sov_0[ex2_ttype_offset:ex2_ttype_offset + ttype_width - 1]),
      .din(ex2_ttype_d),
      .dout(ex2_ttype_q)
   );

   tri_rlmreg_p #(.WIDTH(ws_width), .INIT(0), .NEEDS_SRESET(1)) ex2_ws_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex1_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_ws_offset:ex2_ws_offset + ws_width - 1]),
      .scout(sov_0[ex2_ws_offset:ex2_ws_offset + ws_width - 1]),
      .din(ex2_ws_d[0:ws_width - 1]),
      .dout(ex2_ws_q[0:ws_width - 1])
   );
   // next 2 latches should not be needed

   tri_rlmreg_p #(.WIDTH(rs_is_width), .INIT(0), .NEEDS_SRESET(1)) ex2_rs_is_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex1_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_rs_is_offset:ex2_rs_is_offset + rs_is_width - 1]),
      .scout(sov_0[ex2_rs_is_offset:ex2_rs_is_offset + rs_is_width - 1]),
      .din(ex2_rs_is_d[0:rs_is_width - 1]),
      .dout(ex2_rs_is_q[0:rs_is_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) ex2_ra_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex1_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_ra_entry_offset:ex2_ra_entry_offset + 5 - 1]),
      .scout(sov_0[ex2_ra_entry_offset:ex2_ra_entry_offset + 5 - 1]),
      .din(ex2_ra_entry_d),
      .dout(ex2_ra_entry_q)
   );

   tri_rlmreg_p #(.WIDTH(state_width), .INIT(0), .NEEDS_SRESET(1)) ex2_state_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_state_offset:ex2_state_offset + state_width - 1]),
      .scout(sov_0[ex2_state_offset:ex2_state_offset + state_width - 1]),
      .din(ex2_state_d[0:state_width - 1]),
      .dout(ex2_state_q[0:state_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(pid_width), .INIT(0), .NEEDS_SRESET(1)) ex2_pid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_pid_offset:ex2_pid_offset + pid_width - 1]),
      .scout(sov_0[ex2_pid_offset:ex2_pid_offset + pid_width - 1]),
      .din(ex2_pid_d),
      .dout(ex2_pid_q)
   );

   tri_rlmreg_p #(.WIDTH(extclass_width), .INIT(0), .NEEDS_SRESET(1)) ex2_extclass_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex1_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_extclass_offset:ex2_extclass_offset + extclass_width - 1]),
      .scout(sov_0[ex2_extclass_offset:ex2_extclass_offset + extclass_width - 1]),
      .din(ex2_extclass_d[0:extclass_width - 1]),
      .dout(ex2_extclass_q[0:extclass_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(tlbsel_width), .INIT(0), .NEEDS_SRESET(1)) ex2_tlbsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex1_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_tlbsel_offset:ex2_tlbsel_offset + tlbsel_width - 1]),
      .scout(sov_0[ex2_tlbsel_offset:ex2_tlbsel_offset + tlbsel_width - 1]),
      .din(ex2_tlbsel_d[0:tlbsel_width - 1]),
      .dout(ex2_tlbsel_q[0:tlbsel_width - 1])
   );
   //------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex2_data_in_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex1_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_data_in_offset:ex2_data_in_offset + (`GPR_WIDTH) - 1]),
      .scout(sov_0[ex2_data_in_offset:ex2_data_in_offset + (`GPR_WIDTH) - 1]),
      .din(ex2_data_in_d[64 - `GPR_WIDTH:63]),
      .dout(ex2_data_in_q[64 - `GPR_WIDTH:63])
   );
   //-----------------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_valid_offset:ex3_valid_offset + `THREADS - 1]),
      .scout(sov_0[ex3_valid_offset:ex3_valid_offset + `THREADS - 1]),
      .din(ex3_valid_d[0:`THREADS - 1]),
      .dout(ex3_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_pfetch_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_pfetch_val_offset:ex3_pfetch_val_offset + `THREADS - 1]),
      .scout(sov_0[ex3_pfetch_val_offset:ex3_pfetch_val_offset + `THREADS - 1]),
      .din(ex3_pfetch_val_d[0:`THREADS - 1]),
      .dout(ex3_pfetch_val_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex3_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_itag_offset:ex3_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov_0[ex3_itag_offset:ex3_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ex3_itag_d[0:`ITAG_SIZE_ENC - 1]),
      .dout(ex3_itag_q[0:`ITAG_SIZE_ENC - 1])
   );

   tri_rlmreg_p #(.WIDTH(ttype_width), .INIT(0), .NEEDS_SRESET(1)) ex3_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_ttype_offset:ex3_ttype_offset + ttype_width - 1]),
      .scout(sov_0[ex3_ttype_offset:ex3_ttype_offset + ttype_width - 1]),
      .din(ex3_ttype_d[0:ttype_width - 1]),
      .dout(ex3_ttype_q[0:ttype_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ws_width), .INIT(0), .NEEDS_SRESET(1)) ex3_ws_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_ws_offset:ex3_ws_offset + ws_width - 1]),
      .scout(sov_0[ex3_ws_offset:ex3_ws_offset + ws_width - 1]),
      .din(ex3_ws_d[0:ws_width - 1]),
      .dout(ex3_ws_q[0:ws_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(rs_is_width), .INIT(0), .NEEDS_SRESET(1)) ex3_rs_is_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_rs_is_offset:ex3_rs_is_offset + rs_is_width - 1]),
      .scout(sov_0[ex3_rs_is_offset:ex3_rs_is_offset + rs_is_width - 1]),
      .din(ex3_rs_is_d[0:rs_is_width - 1]),
      .dout(ex3_rs_is_q[0:rs_is_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) ex3_ra_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_ra_entry_offset:ex3_ra_entry_offset + 5 - 1]),
      .scout(sov_0[ex3_ra_entry_offset:ex3_ra_entry_offset + 5 - 1]),
      .din(ex3_ra_entry_d),
      .dout(ex3_ra_entry_q)
   );

   tri_rlmreg_p #(.WIDTH(state_width), .INIT(0), .NEEDS_SRESET(1)) ex3_state_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_state_offset:ex3_state_offset + state_width - 1]),
      .scout(sov_0[ex3_state_offset:ex3_state_offset + state_width - 1]),
      .din(ex3_state_d[0:state_width - 1]),
      .dout(ex3_state_q[0:state_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(pid_width), .INIT(0), .NEEDS_SRESET(1)) ex3_pid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_pid_offset:ex3_pid_offset + pid_width - 1]),
      .scout(sov_0[ex3_pid_offset:ex3_pid_offset + pid_width - 1]),
      .din(ex3_pid_d),
      .dout(ex3_pid_q)
   );

   tri_rlmreg_p #(.WIDTH(extclass_width), .INIT(0), .NEEDS_SRESET(1)) ex3_extclass_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_extclass_offset:ex3_extclass_offset + extclass_width - 1]),
      .scout(sov_0[ex3_extclass_offset:ex3_extclass_offset + extclass_width - 1]),
      .din(ex3_extclass_d[0:extclass_width - 1]),
      .dout(ex3_extclass_q[0:extclass_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(tlbsel_width), .INIT(0), .NEEDS_SRESET(1)) ex3_tlbsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_tlbsel_offset:ex3_tlbsel_offset + tlbsel_width - 1]),
      .scout(sov_0[ex3_tlbsel_offset:ex3_tlbsel_offset + tlbsel_width - 1]),
      .din(ex3_tlbsel_d[0:tlbsel_width - 1]),
      .dout(ex3_tlbsel_q[0:tlbsel_width - 1])
   );
   //-----------------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_valid_offset:ex4_valid_offset + `THREADS - 1]),
      .scout(sov_0[ex4_valid_offset:ex4_valid_offset + `THREADS - 1]),
      .din(ex4_valid_d[0:`THREADS - 1]),
      .dout(ex4_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_pfetch_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_pfetch_val_offset:ex4_pfetch_val_offset + `THREADS - 1]),
      .scout(sov_0[ex4_pfetch_val_offset:ex4_pfetch_val_offset + `THREADS - 1]),
      .din(ex4_pfetch_val_d[0:`THREADS - 1]),
      .dout(ex4_pfetch_val_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex4_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_itag_offset:ex4_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov_0[ex4_itag_offset:ex4_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ex4_itag_d[0:`ITAG_SIZE_ENC - 1]),
      .dout(ex4_itag_q[0:`ITAG_SIZE_ENC - 1])
   );

   tri_rlmreg_p #(.WIDTH(ttype_width), .INIT(0), .NEEDS_SRESET(1)) ex4_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_ttype_offset:ex4_ttype_offset + ttype_width - 1]),
      .scout(sov_0[ex4_ttype_offset:ex4_ttype_offset + ttype_width - 1]),
      .din(ex4_ttype_d[0:ttype_width - 1]),
      .dout(ex4_ttype_q[0:ttype_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ws_width), .INIT(0), .NEEDS_SRESET(1)) ex4_ws_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_ws_offset:ex4_ws_offset + ws_width - 1]),
      .scout(sov_0[ex4_ws_offset:ex4_ws_offset + ws_width - 1]),
      .din(ex4_ws_d[0:ws_width - 1]),
      .dout(ex4_ws_q[0:ws_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(rs_is_width), .INIT(0), .NEEDS_SRESET(1)) ex4_rs_is_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_rs_is_offset:ex4_rs_is_offset + rs_is_width - 1]),
      .scout(sov_0[ex4_rs_is_offset:ex4_rs_is_offset + rs_is_width - 1]),
      .din(ex4_rs_is_d[0:rs_is_width - 1]),
      .dout(ex4_rs_is_q[0:rs_is_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) ex4_ra_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_ra_entry_offset:ex4_ra_entry_offset + 5 - 1]),
      .scout(sov_0[ex4_ra_entry_offset:ex4_ra_entry_offset + 5 - 1]),
      .din(ex4_ra_entry_d),
      .dout(ex4_ra_entry_q)
   );

   tri_rlmreg_p #(.WIDTH(state_width), .INIT(0), .NEEDS_SRESET(1)) ex4_state_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_state_offset:ex4_state_offset + state_width - 1]),
      .scout(sov_0[ex4_state_offset:ex4_state_offset + state_width - 1]),
      .din(ex4_state_d[0:state_width - 1]),
      .dout(ex4_state_q[0:state_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(pid_width), .INIT(0), .NEEDS_SRESET(1)) ex4_pid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_pid_offset:ex4_pid_offset + pid_width - 1]),
      .scout(sov_0[ex4_pid_offset:ex4_pid_offset + pid_width - 1]),
      .din(ex4_pid_d),
      .dout(ex4_pid_q)
   );

   tri_rlmreg_p #(.WIDTH(lpid_width), .INIT(0), .NEEDS_SRESET(1)) ex4_lpid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_lpid_offset:ex4_lpid_offset + lpid_width - 1]),
      .scout(sov_0[ex4_lpid_offset:ex4_lpid_offset + lpid_width - 1]),
      .din(ex4_lpid_d),
      .dout(ex4_lpid_q)
   );

   tri_rlmreg_p #(.WIDTH(extclass_width), .INIT(0), .NEEDS_SRESET(1)) ex4_extclass_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_extclass_offset:ex4_extclass_offset + extclass_width - 1]),
      .scout(sov_0[ex4_extclass_offset:ex4_extclass_offset + extclass_width - 1]),
      .din(ex4_extclass_d[0:extclass_width - 1]),
      .dout(ex4_extclass_q[0:extclass_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(tlbsel_width), .INIT(0), .NEEDS_SRESET(1)) ex4_tlbsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_tlbsel_offset:ex4_tlbsel_offset + tlbsel_width - 1]),
      .scout(sov_0[ex4_tlbsel_offset:ex4_tlbsel_offset + tlbsel_width - 1]),
      .din(ex4_tlbsel_d[0:tlbsel_width - 1]),
      .dout(ex4_tlbsel_q[0:tlbsel_width - 1])
   );
   //-----------------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_valid_offset:ex5_valid_offset + `THREADS - 1]),
      .scout(sov_0[ex5_valid_offset:ex5_valid_offset + `THREADS - 1]),
      .din(ex5_valid_d[0:`THREADS - 1]),
      .dout(ex5_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_pfetch_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_pfetch_val_offset:ex5_pfetch_val_offset + `THREADS - 1]),
      .scout(sov_0[ex5_pfetch_val_offset:ex5_pfetch_val_offset + `THREADS - 1]),
      .din(ex5_pfetch_val_d[0:`THREADS - 1]),
      .dout(ex5_pfetch_val_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex5_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_itag_offset:ex5_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov_0[ex5_itag_offset:ex5_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ex5_itag_d[0:`ITAG_SIZE_ENC - 1]),
      .dout(ex5_itag_q[0:`ITAG_SIZE_ENC - 1])
   );

   tri_rlmreg_p #(.WIDTH(ttype_width), .INIT(0), .NEEDS_SRESET(1)) ex5_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_ttype_offset:ex5_ttype_offset + ttype_width - 1]),
      .scout(sov_0[ex5_ttype_offset:ex5_ttype_offset + ttype_width - 1]),
      .din(ex5_ttype_d[0:ttype_width - 1]),
      .dout(ex5_ttype_q[0:ttype_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ws_width), .INIT(0), .NEEDS_SRESET(1)) ex5_ws_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_ws_offset:ex5_ws_offset + ws_width - 1]),
      .scout(sov_0[ex5_ws_offset:ex5_ws_offset + ws_width - 1]),
      .din(ex5_ws_d[0:ws_width - 1]),
      .dout(ex5_ws_q[0:ws_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(rs_is_width), .INIT(0), .NEEDS_SRESET(1)) ex5_rs_is_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_rs_is_offset:ex5_rs_is_offset + rs_is_width - 1]),
      .scout(sov_0[ex5_rs_is_offset:ex5_rs_is_offset + rs_is_width - 1]),
      .din(ex5_rs_is_d[0:rs_is_width - 1]),
      .dout(ex5_rs_is_q[0:rs_is_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) ex5_ra_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_ra_entry_offset:ex5_ra_entry_offset + 5 - 1]),
      .scout(sov_0[ex5_ra_entry_offset:ex5_ra_entry_offset + 5 - 1]),
      .din(ex5_ra_entry_d),
      .dout(ex5_ra_entry_q)
   );

   tri_rlmreg_p #(.WIDTH(state_width), .INIT(0), .NEEDS_SRESET(1)) ex5_state_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_state_offset:ex5_state_offset + state_width - 1]),
      .scout(sov_0[ex5_state_offset:ex5_state_offset + state_width - 1]),
      .din(ex5_state_d[0:state_width - 1]),
      .dout(ex5_state_q[0:state_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(pid_width), .INIT(0), .NEEDS_SRESET(1)) ex5_pid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_pid_offset:ex5_pid_offset + pid_width - 1]),
      .scout(sov_0[ex5_pid_offset:ex5_pid_offset + pid_width - 1]),
      .din(ex5_pid_d),
      .dout(ex5_pid_q)
   );

   tri_rlmreg_p #(.WIDTH(lpid_width), .INIT(0), .NEEDS_SRESET(1)) ex5_lpid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_lpid_offset:ex5_lpid_offset + lpid_width - 1]),
      .scout(sov_0[ex5_lpid_offset:ex5_lpid_offset + lpid_width - 1]),
      .din(ex5_lpid_d),
      .dout(ex5_lpid_q)
   );

   tri_rlmreg_p #(.WIDTH(extclass_width), .INIT(0), .NEEDS_SRESET(1)) ex5_extclass_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_extclass_offset:ex5_extclass_offset + extclass_width - 1]),
      .scout(sov_0[ex5_extclass_offset:ex5_extclass_offset + extclass_width - 1]),
      .din(ex5_extclass_d[0:extclass_width - 1]),
      .dout(ex5_extclass_q[0:extclass_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(tlbsel_width), .INIT(0), .NEEDS_SRESET(1)) ex5_tlbsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_tlbsel_offset:ex5_tlbsel_offset + tlbsel_width - 1]),
      .scout(sov_0[ex5_tlbsel_offset:ex5_tlbsel_offset + tlbsel_width - 1]),
      .din(ex5_tlbsel_d[0:tlbsel_width - 1]),
      .dout(ex5_tlbsel_q[0:tlbsel_width - 1])
   );
   //-----------------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex6_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_valid_offset:ex6_valid_offset + `THREADS - 1]),
      .scout(sov_0[ex6_valid_offset:ex6_valid_offset + `THREADS - 1]),
      .din(ex6_valid_d[0:`THREADS - 1]),
      .dout(ex6_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex6_pfetch_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_pfetch_val_offset:ex6_pfetch_val_offset + `THREADS - 1]),
      .scout(sov_0[ex6_pfetch_val_offset:ex6_pfetch_val_offset + `THREADS - 1]),
      .din(ex6_pfetch_val_d[0:`THREADS - 1]),
      .dout(ex6_pfetch_val_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex6_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_itag_offset:ex6_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov_0[ex6_itag_offset:ex6_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ex6_itag_d[0:`ITAG_SIZE_ENC - 1]),
      .dout(ex6_itag_q[0:`ITAG_SIZE_ENC - 1])
   );

   tri_rlmreg_p #(.WIDTH(ttype_width), .INIT(0), .NEEDS_SRESET(1)) ex6_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_ttype_offset:ex6_ttype_offset + ttype_width - 1]),
      .scout(sov_0[ex6_ttype_offset:ex6_ttype_offset + ttype_width - 1]),
      .din(ex6_ttype_d[0:ttype_width - 1]),
      .dout(ex6_ttype_q[0:ttype_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ws_width), .INIT(0), .NEEDS_SRESET(1)) ex6_ws_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_ws_offset:ex6_ws_offset + ws_width - 1]),
      .scout(sov_0[ex6_ws_offset:ex6_ws_offset + ws_width - 1]),
      .din(ex6_ws_d[0:ws_width - 1]),
      .dout(ex6_ws_q[0:ws_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(rs_is_width), .INIT(0), .NEEDS_SRESET(1)) ex6_rs_is_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_rs_is_offset:ex6_rs_is_offset + rs_is_width - 1]),
      .scout(sov_0[ex6_rs_is_offset:ex6_rs_is_offset + rs_is_width - 1]),
      .din(ex6_rs_is_d[0:rs_is_width - 1]),
      .dout(ex6_rs_is_q[0:rs_is_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) ex6_ra_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_ra_entry_offset:ex6_ra_entry_offset + 5 - 1]),
      .scout(sov_0[ex6_ra_entry_offset:ex6_ra_entry_offset + 5 - 1]),
      .din(ex6_ra_entry_d),
      .dout(ex6_ra_entry_q)
   );

   tri_rlmreg_p #(.WIDTH(state_width), .INIT(0), .NEEDS_SRESET(1)) ex6_state_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_state_offset:ex6_state_offset + state_width - 1]),
      .scout(sov_0[ex6_state_offset:ex6_state_offset + state_width - 1]),
      .din(ex6_state_d[0:state_width - 1]),
      .dout(ex6_state_q[0:state_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(pid_width), .INIT(0), .NEEDS_SRESET(1)) ex6_pid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_pid_offset:ex6_pid_offset + pid_width - 1]),
      .scout(sov_0[ex6_pid_offset:ex6_pid_offset + pid_width - 1]),
      .din(ex6_pid_d),
      .dout(ex6_pid_q)
   );

   tri_rlmreg_p #(.WIDTH(extclass_width), .INIT(0), .NEEDS_SRESET(1)) ex6_extclass_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_extclass_offset:ex6_extclass_offset + extclass_width - 1]),
      .scout(sov_0[ex6_extclass_offset:ex6_extclass_offset + extclass_width - 1]),
      .din(ex6_extclass_d[0:extclass_width - 1]),
      .dout(ex6_extclass_q[0:extclass_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(tlbsel_width), .INIT(0), .NEEDS_SRESET(1)) ex6_tlbsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_tlbsel_offset:ex6_tlbsel_offset + tlbsel_width - 1]),
      .scout(sov_0[ex6_tlbsel_offset:ex6_tlbsel_offset + tlbsel_width - 1]),
      .din(ex6_tlbsel_d[0:tlbsel_width - 1]),
      .dout(ex6_tlbsel_q[0:tlbsel_width - 1])
   );
   //-----------------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex7_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex7_valid_offset:ex7_valid_offset + `THREADS - 1]),
      .scout(sov_0[ex7_valid_offset:ex7_valid_offset + `THREADS - 1]),
      .din(ex7_valid_d[0:`THREADS - 1]),
      .dout(ex7_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex7_pfetch_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex7_pfetch_val_offset:ex7_pfetch_val_offset + `THREADS - 1]),
      .scout(sov_0[ex7_pfetch_val_offset:ex7_pfetch_val_offset + `THREADS - 1]),
      .din(ex7_pfetch_val_d[0:`THREADS - 1]),
      .dout(ex7_pfetch_val_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(ttype_width), .INIT(0), .NEEDS_SRESET(1)) ex7_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex7_ttype_offset:ex7_ttype_offset + ttype_width - 1]),
      .scout(sov_0[ex7_ttype_offset:ex7_ttype_offset + ttype_width - 1]),
      .din(ex7_ttype_d[0:ttype_width - 1]),
      .dout(ex7_ttype_q[0:ttype_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ws_width), .INIT(0), .NEEDS_SRESET(1)) ex7_ws_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex7_ws_offset:ex7_ws_offset + ws_width - 1]),
      .scout(sov_0[ex7_ws_offset:ex7_ws_offset + ws_width - 1]),
      .din(ex7_ws_d[0:ws_width - 1]),
      .dout(ex7_ws_q[0:ws_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(rs_is_width), .INIT(0), .NEEDS_SRESET(1)) ex7_rs_is_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex7_rs_is_offset:ex7_rs_is_offset + rs_is_width - 1]),
      .scout(sov_0[ex7_rs_is_offset:ex7_rs_is_offset + rs_is_width - 1]),
      .din(ex7_rs_is_d[0:rs_is_width - 1]),
      .dout(ex7_rs_is_q[0:rs_is_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) ex7_ra_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex7_ra_entry_offset:ex7_ra_entry_offset + 5 - 1]),
      .scout(sov_0[ex7_ra_entry_offset:ex7_ra_entry_offset + 5 - 1]),
      .din(ex7_ra_entry_d),
      .dout(ex7_ra_entry_q)
   );

   tri_rlmreg_p #(.WIDTH(state_width), .INIT(0), .NEEDS_SRESET(1)) ex7_state_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex7_state_offset:ex7_state_offset + state_width - 1]),
      .scout(sov_0[ex7_state_offset:ex7_state_offset + state_width - 1]),
      .din(ex7_state_d[0:state_width - 1]),
      .dout(ex7_state_q[0:state_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(pid_width), .INIT(0), .NEEDS_SRESET(1)) ex7_pid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex7_pid_offset:ex7_pid_offset + pid_width - 1]),
      .scout(sov_0[ex7_pid_offset:ex7_pid_offset + pid_width - 1]),
      .din(ex7_pid_d),
      .dout(ex7_pid_q)
   );

   tri_rlmreg_p #(.WIDTH(extclass_width), .INIT(0), .NEEDS_SRESET(1)) ex7_extclass_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex7_extclass_offset:ex7_extclass_offset + extclass_width - 1]),
      .scout(sov_0[ex7_extclass_offset:ex7_extclass_offset + extclass_width - 1]),
      .din(ex7_extclass_d[0:extclass_width - 1]),
      .dout(ex7_extclass_q[0:extclass_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(tlbsel_width), .INIT(0), .NEEDS_SRESET(1)) ex7_tlbsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex7_tlbsel_offset:ex7_tlbsel_offset + tlbsel_width - 1]),
      .scout(sov_0[ex7_tlbsel_offset:ex7_tlbsel_offset + tlbsel_width - 1]),
      .din(ex7_tlbsel_d[0:tlbsel_width - 1]),
      .dout(ex7_tlbsel_q[0:tlbsel_width - 1])
   );
   //-----------------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex8_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex8_valid_offset:ex8_valid_offset + `THREADS - 1]),
      .scout(sov_0[ex8_valid_offset:ex8_valid_offset + `THREADS - 1]),
      .din(ex8_valid_d[0:`THREADS - 1]),
      .dout(ex8_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex8_pfetch_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex8_pfetch_val_offset:ex8_pfetch_val_offset + `THREADS - 1]),
      .scout(sov_0[ex8_pfetch_val_offset:ex8_pfetch_val_offset + `THREADS - 1]),
      .din(ex8_pfetch_val_d[0:`THREADS - 1]),
      .dout(ex8_pfetch_val_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(ttype_width), .INIT(0), .NEEDS_SRESET(1)) ex8_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex8_ttype_offset:ex8_ttype_offset + ttype_width - 1]),
      .scout(sov_0[ex8_ttype_offset:ex8_ttype_offset + ttype_width - 1]),
      .din(ex8_ttype_d[0:ttype_width - 1]),
      .dout(ex8_ttype_q[0:ttype_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(tlbsel_width), .INIT(0), .NEEDS_SRESET(1)) ex8_tlbsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex8_tlbsel_offset:ex8_tlbsel_offset + tlbsel_width - 1]),
      .scout(sov_0[ex8_tlbsel_offset:ex8_tlbsel_offset + tlbsel_width - 1]),
      .din(ex8_tlbsel_d[0:tlbsel_width - 1]),
      .dout(ex8_tlbsel_q[0:tlbsel_width - 1])
   );
   //------------------------------------------------

   tri_rlmreg_p #(.WIDTH(GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex5_data_out_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_data_out_offset:ex5_data_out_offset + GPR_WIDTH - 1]),
      .scout(sov_0[ex5_data_out_offset:ex5_data_out_offset + GPR_WIDTH - 1]),
      .din(ex5_data_out_d[64 - GPR_WIDTH:63]),
      .dout(ex5_data_out_q[64 - GPR_WIDTH:63])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_req_inprogress_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_req_inprogress_offset]),
      .scout(sov_0[tlb_req_inprogress_offset]),
      .din(tlb_req_inprogress_d),
      .dout(tlb_req_inprogress_q)
   );

   tri_rlmreg_p #(.WIDTH((7+(2*`THREADS)+1)), .INIT(0), .NEEDS_SRESET(1)) ex3_dsi_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_dsi_offset:ex3_dsi_offset + (7+(2*`THREADS)+1) - 1]),
      .scout(sov_0[ex3_dsi_offset:ex3_dsi_offset + (7+(2*`THREADS)+1) - 1]),
      .din(ex3_dsi_d),
      .dout(ex3_dsi_q)
   );

   tri_rlmreg_p #(.WIDTH((7+(2*`THREADS)+1)), .INIT(0), .NEEDS_SRESET(1)) ex3_noop_touch_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_noop_touch_offset:ex3_noop_touch_offset + (7+(2*`THREADS)+1) - 1]),
      .scout(sov_0[ex3_noop_touch_offset:ex3_noop_touch_offset + (7+(2*`THREADS)+1) - 1]),
      .din(ex3_noop_touch_d),
      .dout(ex3_noop_touch_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_miss_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_miss_offset:ex4_miss_offset + `THREADS - 1]),
      .scout(sov_0[ex4_miss_offset:ex4_miss_offset + `THREADS - 1]),
      .din(ex4_miss_d[0:`THREADS - 1]),
      .dout(ex4_miss_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH((7+(2*`THREADS)+1)), .INIT(0), .NEEDS_SRESET(1)) ex4_dsi_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_dsi_offset:ex4_dsi_offset + (7+(2*`THREADS)+1) - 1]),
      .scout(sov_0[ex4_dsi_offset:ex4_dsi_offset + (7+(2*`THREADS)+1) - 1]),
      .din(ex4_dsi_d),
      .dout(ex4_dsi_q)
   );

   tri_rlmreg_p #(.WIDTH((7+(2*`THREADS)+1)), .INIT(0), .NEEDS_SRESET(1)) ex4_noop_touch_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_noop_touch_offset:ex4_noop_touch_offset + (7+(2*`THREADS)+1) - 1]),
      .scout(sov_0[ex4_noop_touch_offset:ex4_noop_touch_offset + (7+(2*`THREADS)+1) - 1]),
      .din(ex4_noop_touch_d),
      .dout(ex4_noop_touch_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_multihit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_multihit_offset:ex4_multihit_offset + `THREADS - 1]),
      .scout(sov_0[ex4_multihit_offset:ex4_multihit_offset + `THREADS - 1]),
      .din(ex4_multihit_d[0:`THREADS - 1]),
      .dout(ex4_multihit_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(num_entry), .INIT(0), .NEEDS_SRESET(1)) ex4_multihit_b_pt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_multihit_b_pt_offset:ex4_multihit_b_pt_offset + num_entry - 1]),
      .scout(sov_0[ex4_multihit_b_pt_offset:ex4_multihit_b_pt_offset + num_entry - 1]),
      .din(ex4_multihit_b_pt_d),
      .dout(ex4_multihit_b_pt_q)
   );

   tri_rlmreg_p #(.WIDTH((num_entry-1)), .INIT(0), .NEEDS_SRESET(1)) ex4_first_hit_entry_pt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_first_hit_entry_pt_offset:ex4_first_hit_entry_pt_offset + (num_entry-1) - 1]),
      .scout(sov_0[ex4_first_hit_entry_pt_offset:ex4_first_hit_entry_pt_offset + (num_entry-1) - 1]),
      .din(ex4_first_hit_entry_pt_d),
      .dout(ex4_first_hit_entry_pt_q)
   );

   tri_rlmreg_p #(.WIDTH((`THREADS+2)), .INIT(0), .NEEDS_SRESET(1)) ex4_parerr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_parerr_offset:ex4_parerr_offset + (`THREADS+2) - 1]),
      .scout(sov_0[ex4_parerr_offset:ex4_parerr_offset + (`THREADS+2) - 1]),
      .din(ex4_parerr_d),
      .dout(ex4_parerr_q)
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) ex4_attr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_attr_offset:ex4_attr_offset + 6 - 1]),
      .scout(sov_0[ex4_attr_offset:ex4_attr_offset + 6 - 1]),
      .din(ex4_attr_d[0:5]),
      .dout(ex4_attr_q[0:5])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_cam_hit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_cam_hit_offset]),
      .scout(sov_0[ex4_cam_hit_offset]),
      .din(cam_hit),
      .dout(ex4_cam_hit_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_hit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_hit_offset]),
      .scout(sov_0[ex4_hit_offset]),
      .din(ex4_hit_d),
      .dout(ex4_hit_q)
   );

   tri_rlmreg_p #(.WIDTH(11), .INIT(0), .NEEDS_SRESET(1)) ex3_debug_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_debug_offset:ex3_debug_offset + 11 - 1]),
      .scout(sov_0[ex3_debug_offset:ex3_debug_offset + 11 - 1]),
      .din(ex3_debug_d),
      .dout(ex3_debug_q)
   );

   tri_rlmreg_p #(.WIDTH(17), .INIT(0), .NEEDS_SRESET(1)) ex4_debug_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_debug_offset:ex4_debug_offset + 17 - 1]),
      .scout(sov_0[ex4_debug_offset:ex4_debug_offset + 17 - 1]),
      .din(ex4_debug_d),
      .dout(ex4_debug_q)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) rw_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[rw_entry_offset:rw_entry_offset + 5 - 1]),
      .scout(sov_0[rw_entry_offset:rw_entry_offset + 5 - 1]),
      .din(rw_entry_d),
      .dout(rw_entry_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rw_entry_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[rw_entry_val_offset]),
      .scout(sov_0[rw_entry_val_offset]),
      .din(rw_entry_val_d),
      .dout(rw_entry_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rw_entry_le_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[rw_entry_le_offset]),
      .scout(sov_0[rw_entry_le_offset]),
      .din(rw_entry_le_d),
      .dout(rw_entry_le_q)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) cam_entry_le_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(rw_entry_val_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[cam_entry_le_offset:cam_entry_le_offset + 32 - 1]),
      .scout(sov_0[cam_entry_le_offset:cam_entry_le_offset + 32 - 1]),
      .din(cam_entry_le_d),
      .dout(cam_entry_le_q)
   );

   tri_rlmreg_p #(.WIDTH(30), .INIT(0), .NEEDS_SRESET(1)) ex3_comp_addr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex3_comp_addr_offset:ex3_comp_addr_offset + 30 - 1]),
      .scout(sov_1[ex3_comp_addr_offset:ex3_comp_addr_offset + 30 - 1]),
      .din(ex3_comp_addr_d),
      .dout(ex3_comp_addr_q)
   );

   tri_rlmreg_p #(.WIDTH(30), .INIT(0), .NEEDS_SRESET(1)) ex4_rpn_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_rpn_offset:ex4_rpn_offset + 30 - 1]),
      .scout(sov_1[ex4_rpn_offset:ex4_rpn_offset + 30 - 1]),
      .din(ex4_rpn_d),
      .dout(ex4_rpn_q)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) ex4_wimge_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_wimge_offset:ex4_wimge_offset + 5 - 1]),
      .scout(sov_1[ex4_wimge_offset:ex4_wimge_offset + 5 - 1]),
      .din(ex4_wimge_d),
      .dout(ex4_wimge_q)
   );

   tri_rlmreg_p #(.WIDTH(cam_data_width), .INIT(0), .NEEDS_SRESET(1)) ex4_cam_cmp_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_cmp_data_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_cam_cmp_data_offset:ex4_cam_cmp_data_offset + cam_data_width - 1]),
      .scout(sov_1[ex4_cam_cmp_data_offset:ex4_cam_cmp_data_offset + cam_data_width - 1]),
      .din(ex4_cam_cmp_data_d),
      .dout(ex4_cam_cmp_data_q)
   );

   tri_rlmreg_p #(.WIDTH(array_data_width), .INIT(0), .NEEDS_SRESET(1)) ex4_array_cmp_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_cmp_data_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_array_cmp_data_offset:ex4_array_cmp_data_offset + array_data_width - 1]),
      .scout(sov_1[ex4_array_cmp_data_offset:ex4_array_cmp_data_offset + array_data_width - 1]),
      .din(ex4_array_cmp_data_d),
      .dout(ex4_array_cmp_data_q)
   );

   tri_rlmreg_p #(.WIDTH(array_data_width), .INIT(0), .NEEDS_SRESET(1)) ex4_rd_array_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_rd_data_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_rd_array_data_offset:ex4_rd_array_data_offset + array_data_width - 1]),
      .scout(sov_1[ex4_rd_array_data_offset:ex4_rd_array_data_offset + array_data_width - 1]),
      .din(ex4_rd_array_data_d[0:array_data_width - 1]),
      .dout(ex4_rd_array_data_q[0:array_data_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(cam_data_width), .INIT(0), .NEEDS_SRESET(1)) ex4_rd_cam_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_rd_data_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_rd_cam_data_offset:ex4_rd_cam_data_offset + cam_data_width - 1]),
      .scout(sov_1[ex4_rd_cam_data_offset:ex4_rd_cam_data_offset + cam_data_width - 1]),
      .din(ex4_rd_cam_data_d[0:cam_data_width - 1]),
      .dout(ex4_rd_cam_data_q[0:cam_data_width - 1])
   );

   tri_rlmreg_p #(.WIDTH((`THREADS+5)), .INIT(0), .NEEDS_SRESET(1)) ex5_parerr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_parerr_offset:ex5_parerr_offset + (`THREADS+5) - 1]),
      .scout(sov_1[ex5_parerr_offset:ex5_parerr_offset + (`THREADS+5) - 1]),
      .din(ex5_parerr_d),
      .dout(ex5_parerr_q)
   );

   tri_rlmreg_p #(.WIDTH((`THREADS+3)), .INIT(0), .NEEDS_SRESET(1)) ex5_fir_parerr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_fir_parerr_offset:ex5_fir_parerr_offset + (`THREADS+3) - 1]),
      .scout(sov_1[ex5_fir_parerr_offset:ex5_fir_parerr_offset + (`THREADS+3) - 1]),
      .din(ex5_fir_parerr_d),
      .dout(ex5_fir_parerr_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_fir_multihit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_fir_multihit_offset:ex5_fir_multihit_offset + `THREADS - 1]),
      .scout(sov_1[ex5_fir_multihit_offset:ex5_fir_multihit_offset + `THREADS - 1]),
      .din(ex5_fir_multihit_d[0:`THREADS - 1]),
      .dout(ex5_fir_multihit_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH((`THREADS+num_entry_log2-1+1)), .INIT(0), .NEEDS_SRESET(1)) ex5_deen_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_deen_offset:ex5_deen_offset + (`THREADS+num_entry_log2-1+1) - 1]),
      .scout(sov_1[ex5_deen_offset:ex5_deen_offset + (`THREADS+num_entry_log2-1+1) - 1]),
      .din(ex5_deen_d[0:(`THREADS+num_entry_log2-1+1) - 1]),
      .dout(ex5_deen_q[0:(`THREADS+num_entry_log2-1+1) - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_hit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_hit_offset]),
      .scout(sov_1[ex5_hit_offset]),
      .din(ex5_hit_d),
      .dout(ex5_hit_q)
   );

   tri_rlmreg_p #(.WIDTH((`THREADS+num_entry_log2)), .INIT(0), .NEEDS_SRESET(1)) ex6_deen_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex6_deen_offset:ex6_deen_offset + (`THREADS+num_entry_log2) - 1]),
      .scout(sov_1[ex6_deen_offset:ex6_deen_offset + (`THREADS+num_entry_log2) - 1]),
      .din(ex6_deen_d[0:`THREADS+num_entry_log2 - 1]),
      .dout(ex6_deen_q[0:`THREADS+num_entry_log2 - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_hit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex6_hit_offset]),
      .scout(sov_1[ex6_hit_offset]),
      .din(ex6_hit_d),
      .dout(ex6_hit_q)
   );

   tri_rlmreg_p #(.WIDTH((`THREADS+num_entry_log2)), .INIT(0), .NEEDS_SRESET(1)) ex7_deen_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex7_deen_offset:ex7_deen_offset + (`THREADS+num_entry_log2) - 1]),
      .scout(sov_1[ex7_deen_offset:ex7_deen_offset + (`THREADS+num_entry_log2) - 1]),
      .din(ex7_deen_d[0:`THREADS+num_entry_log2 - 1]),
      .dout(ex7_deen_q[0:`THREADS+num_entry_log2 - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex7_hit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex7_hit_offset]),
      .scout(sov_1[ex7_hit_offset]),
      .din(ex7_hit_d),
      .dout(ex7_hit_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) barrier_done_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[barrier_done_offset:barrier_done_offset + `THREADS - 1]),
      .scout(sov_1[barrier_done_offset:barrier_done_offset + `THREADS - 1]),
      .din(barrier_done_d[0:`THREADS - 1]),
      .dout(barrier_done_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) mmucr1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mmucr1_offset:mmucr1_offset + 10 - 1]),
      .scout(sov_1[mmucr1_offset:mmucr1_offset + 10 - 1]),
      .din(mmucr1_d),
      .dout(mmucr1_q)
   );
/*
   generate
      begin : rpn_holdreg
         genvar                            tid;
         for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
         begin : rpn_holdreg

            tri_rlmreg_p #(.WIDTH(64), .INIT(0), .NEEDS_SRESET(1)) rpn_holdreg_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(tiup),
               .thold_b(pc_func_slp_sl_thold_0_b),
               .sg(pc_sg_0),
               .force_t(pc_func_slp_sl_force),
               .delay_lclkr(lcb_delay_lclkr_dc[0]),
               .mpw1_b(lcb_mpw1_dc_b[0]),
               .mpw2_b(lcb_mpw2_dc_b),
               .d_mode(lcb_d_mode_dc),
               .scin(siv_1[rpn_holdreg_offset + (64 * tid):rpn_holdreg_offset + (64 * (tid + 1)) - 1]),
               .scout(sov_1[rpn_holdreg_offset + (64 * tid):rpn_holdreg_offset + (64 * (tid + 1)) - 1]),
               .din(rpn_holdreg_d[tid][0:63]),
               .dout(rpn_holdreg_q[tid][0:63])
            );
         end
      end
   endgenerate
*/

   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) entry_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(entry_valid_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[entry_valid_offset:entry_valid_offset + 32 - 1]),
      .scout(sov_1[entry_valid_offset:entry_valid_offset + 32 - 1]),
      .din(entry_valid),
      .dout(entry_valid_q)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) entry_match_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(entry_match_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[entry_match_offset:entry_match_offset + 32 - 1]),
      .scout(sov_1[entry_match_offset:entry_match_offset + 32 - 1]),
      .din(entry_match),
      .dout(entry_match_q)
   );

   tri_rlmreg_p #(.WIDTH(watermark_width), .INIT(29), .NEEDS_SRESET(1)) watermark_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[watermark_offset:watermark_offset + watermark_width - 1]),
      .scout(sov_1[watermark_offset:watermark_offset + watermark_width - 1]),
      .din(watermark_d[0:watermark_width - 1]),
      .dout(watermark_q[0:watermark_width - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mmucr1_b0_cpy_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mmucr1_b0_cpy_offset]),
      .scout(sov_1[mmucr1_b0_cpy_offset]),
      .din(mmucr1_b0_cpy_d),
      .dout(mmucr1_b0_cpy_q)
   );

   tri_rlmreg_p #(.WIDTH((lru_width+1)), .INIT(0), .NEEDS_SRESET(1)) lru_rmt_vec_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[lru_rmt_vec_offset:lru_rmt_vec_offset + (lru_width+1) - 1]),
      .scout(sov_1[lru_rmt_vec_offset:lru_rmt_vec_offset + (lru_width+1) - 1]),
      .din(lru_rmt_vec_d),
      .dout(lru_rmt_vec_q)
   );

   tri_rlmreg_p #(.WIDTH(eptr_width), .INIT(0), .NEEDS_SRESET(1)) eptr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eptr_offset:eptr_offset + eptr_width - 1]),
      .scout(sov_1[eptr_offset:eptr_offset + eptr_width - 1]),
      .din(eptr_d[0:eptr_width - 1]),
      .dout(eptr_q[0:eptr_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(lru_width), .INIT(0), .NEEDS_SRESET(1)) lru_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[lru_offset:lru_offset + lru_width - 1]),
      .scout(sov_1[lru_offset:lru_offset + lru_width - 1]),
      .din(lru_d[1:lru_width]),
      .dout(lru_q[1:lru_width])
   );

   tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) lru_update_event_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[lru_update_event_offset:lru_update_event_offset + 10 - 1]),
      .scout(sov_1[lru_update_event_offset:lru_update_event_offset + 10 - 1]),
      .din(lru_update_event_d),
      .dout(lru_update_event_q)
   );


   tri_rlmreg_p #(.WIDTH(41), .INIT(0), .NEEDS_SRESET(1)) lru_debug_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[lru_debug_offset:lru_debug_offset + 41 - 1]),
      .scout(sov_1[lru_debug_offset:lru_debug_offset + 41 - 1]),
      .din(lru_debug_d),
      .dout(lru_debug_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) snoop_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[snoop_val_offset:snoop_val_offset + 3 - 1]),
      .scout(sov_1[snoop_val_offset:snoop_val_offset + 3 - 1]),
      .din(snoop_val_d),
      .dout(snoop_val_q)
   );

   tri_rlmreg_p #(.WIDTH(26), .INIT(0), .NEEDS_SRESET(1)) snoop_attr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(snoop_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[snoop_attr_offset:snoop_attr_offset + 26 - 1]),
      .scout(sov_1[snoop_attr_offset:snoop_attr_offset + 26 - 1]),
      .din(snoop_attr_d),
      .dout(snoop_attr_q)
   );

   tri_rlmreg_p #(.WIDTH((epn_width)), .INIT(0), .NEEDS_SRESET(1)) snoop_addr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(snoop_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[snoop_addr_offset:snoop_addr_offset + epn_width - 1]),
      .scout(sov_1[snoop_addr_offset:snoop_addr_offset + epn_width - 1]),
      .din(snoop_addr_d[52 - epn_width:51]),
      .dout(snoop_addr_q[52 - epn_width:51])
   );

   tri_rlmreg_p #(.WIDTH((51-(64-(2**`GPR_WIDTH_ENC))+1)), .INIT(0), .NEEDS_SRESET(1)) ex3_epn_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex3_epn_offset:ex3_epn_offset + (51-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
      .scout(sov_1[ex3_epn_offset:ex3_epn_offset + (51-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
      .din(ex3_epn_d),
      .dout(ex3_epn_q)
   );

   tri_rlmreg_p #(.WIDTH((51-(64-(2**`GPR_WIDTH_ENC))+1)), .INIT(0), .NEEDS_SRESET(1)) ex4_epn_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_epn_offset:ex4_epn_offset + (51-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
      .scout(sov_1[ex4_epn_offset:ex4_epn_offset + (51-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
      .din(ex3_epn_q),
      .dout(ex4_epn_q)
   );

   tri_rlmreg_p #(.WIDTH((51-(64-(2**`GPR_WIDTH_ENC))+1)), .INIT(0), .NEEDS_SRESET(1)) ex5_epn_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_epn_offset:ex5_epn_offset + (51-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
      .scout(sov_1[ex5_epn_offset:ex5_epn_offset + (51-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
      .din(ex4_epn_q),
      .dout(ex5_epn_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) por_seq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[por_seq_offset:por_seq_offset + 3 - 1]),
      .scout(sov_1[por_seq_offset:por_seq_offset + 3 - 1]),
      .din(por_seq_d[0:por_seq_width - 1]),
      .dout(por_seq_q[0:por_seq_width - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_xu_init_reset_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[pc_xu_init_reset_offset]),
      .scout(sov_1[pc_xu_init_reset_offset]),
      .din(pc_xu_init_reset),
      .dout(pc_xu_init_reset_q)
   );
   // timing latches for reloads

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) tlb_rel_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[tlb_rel_val_offset:tlb_rel_val_offset + 5 - 1]),
      .scout(sov_1[tlb_rel_val_offset:tlb_rel_val_offset + 5 - 1]),
      .din(tlb_rel_val_d),
      .dout(tlb_rel_val_q)
   );

   tri_rlmreg_p #(.WIDTH(132), .INIT(0), .NEEDS_SRESET(1)) tlb_rel_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tlb_rel_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[tlb_rel_data_offset:tlb_rel_data_offset + 132 - 1]),
      .scout(sov_1[tlb_rel_data_offset:tlb_rel_data_offset + 132 - 1]),
      .din(tlb_rel_data_d),
      .dout(tlb_rel_data_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) tlb_rel_emq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tlb_rel_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[tlb_rel_emq_offset:tlb_rel_emq_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[tlb_rel_emq_offset:tlb_rel_emq_offset + `EMQ_ENTRIES - 1]),
      .din(tlb_rel_emq_d),
      .dout(tlb_rel_emq_q)
   );

   tri_rlmreg_p #(.WIDTH((2*`THREADS+1)), .INIT(0), .NEEDS_SRESET(1)) eplc_wr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eplc_wr_offset:eplc_wr_offset + (2*`THREADS+1) - 1]),
      .scout(sov_1[eplc_wr_offset:eplc_wr_offset + (2*`THREADS+1) - 1]),
      .din(eplc_wr_d),
      .dout(eplc_wr_q)
   );

   tri_rlmreg_p #(.WIDTH((2*`THREADS+1)), .INIT(0), .NEEDS_SRESET(1)) epsc_wr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[epsc_wr_offset:epsc_wr_offset + (2*`THREADS+1) - 1]),
      .scout(sov_1[epsc_wr_offset:epsc_wr_offset + (2*`THREADS+1) - 1]),
      .din(epsc_wr_d),
      .dout(epsc_wr_q)
   );

   tri_rlmreg_p #(.WIDTH(12), .INIT(0), .NEEDS_SRESET(1)) ccr2_frat_paranoia_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ccr2_frat_paranoia_offset:ccr2_frat_paranoia_offset + 12 - 1]),
      .scout(sov_1[ccr2_frat_paranoia_offset:ccr2_frat_paranoia_offset + 12 - 1]),
      .din(ccr2_frat_paranoia_d),
      .dout(ccr2_frat_paranoia_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) clkg_ctl_override_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[clkg_ctl_override_offset]),
      .scout(sov_1[clkg_ctl_override_offset]),
      .din(clkg_ctl_override_d),
      .dout(clkg_ctl_override_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex1_stg_act_offset]),
      .scout(sov_1[ex1_stg_act_offset]),
      .din(ex1_stg_act_d),
      .dout(ex1_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex2_stg_act_offset]),
      .scout(sov_1[ex2_stg_act_offset]),
      .din(ex2_stg_act_d),
      .dout(ex2_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex3_stg_act_offset]),
      .scout(sov_1[ex3_stg_act_offset]),
      .din(ex3_stg_act_d),
      .dout(ex3_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_stg_act_offset]),
      .scout(sov_1[ex4_stg_act_offset]),
      .din(ex4_stg_act_d),
      .dout(ex4_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_stg_act_offset]),
      .scout(sov_1[ex5_stg_act_offset]),
      .din(ex5_stg_act_d),
      .dout(ex5_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex6_stg_act_offset]),
      .scout(sov_1[ex6_stg_act_offset]),
      .din(ex6_stg_act_d),
      .dout(ex6_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_rel_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[tlb_rel_act_offset]),
      .scout(sov_1[tlb_rel_act_offset]),
      .din(tlb_rel_act_d),
      .dout(tlb_rel_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) snoopp_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[snoopp_act_offset]),
      .scout(sov_1[snoopp_act_offset]),
      .din(mm_lq_snoop_coming),
      .dout(snoopp_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_grffence_en_dc_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[an_ac_grffence_en_dc_offset]),
      .scout(sov_1[an_ac_grffence_en_dc_offset]),
      .din(an_ac_grffence_en_dc),
      .dout(an_ac_grffence_en_dc_q)
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) spare_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spare_a_offset:spare_a_offset + 16 - 1]),
      .scout(sov_0[spare_a_offset:spare_a_offset + 16 - 1]),
      .din(spare_a_q),
      .dout(spare_a_q)
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) spare_b_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spare_b_offset:spare_b_offset + 16 - 1]),
      .scout(sov_1[spare_b_offset:spare_b_offset + 16 - 1]),
      .din(spare_b_q),
      .dout(spare_b_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) csync_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[csync_val_offset:csync_val_offset + 2 - 1]),
      .scout(sov_1[csync_val_offset:csync_val_offset + 2 - 1]),
      .din(csync_val_d),
      .dout(csync_val_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) isync_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[isync_val_offset:isync_val_offset + 2 - 1]),
      .scout(sov_1[isync_val_offset:isync_val_offset + 2 - 1]),
      .din(isync_val_d),
      .dout(isync_val_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) rel_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rel_val_offset:rel_val_offset + 4 - 1]),
      .scout(sov_1[rel_val_offset:rel_val_offset + 4 - 1]),
      .din(rel_val_d),
      .dout(rel_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel_hit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rel_hit_offset]),
      .scout(sov_1[rel_hit_offset]),
      .din(rel_hit_d),
      .dout(rel_hit_q)
   );

   tri_rlmreg_p #(.WIDTH(132), .INIT(0), .NEEDS_SRESET(1)) rel_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tlb_rel_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rel_data_offset:rel_data_offset + 132 - 1]),
      .scout(sov_1[rel_data_offset:rel_data_offset + 132 - 1]),
      .din(rel_data_d),
      .dout(rel_data_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) rel_emq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tlb_rel_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rel_emq_offset:rel_emq_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[rel_emq_offset:rel_emq_offset + `EMQ_ENTRIES - 1]),
      .din(rel_emq_d),
      .dout(rel_emq_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) rel_int_upd_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tlb_rel_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rel_int_upd_val_offset:rel_int_upd_val_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[rel_int_upd_val_offset:rel_int_upd_val_offset + `EMQ_ENTRIES - 1]),
      .din(rel_int_upd_val_d),
      .dout(rel_int_upd_val_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) epsc_wr_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[epsc_wr_val_offset:epsc_wr_val_offset + `THREADS - 1]),
      .scout(sov_1[epsc_wr_val_offset:epsc_wr_val_offset + `THREADS - 1]),
      .din(epsc_wr_val_d),
      .dout(epsc_wr_val_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) eplc_wr_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eplc_wr_val_offset:eplc_wr_val_offset + `THREADS - 1]),
      .scout(sov_1[eplc_wr_val_offset:eplc_wr_val_offset + `THREADS - 1]),
      .din(eplc_wr_val_d),
      .dout(eplc_wr_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rv1_binv_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rv1_binv_val_offset]),
      .scout(sov_1[rv1_binv_val_offset]),
      .din(rv1_binv_val_d),
      .dout(rv1_binv_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) snoopp_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[snoopp_val_offset]),
      .scout(sov_1[snoopp_val_offset]),
      .din(snoopp_val_d),
      .dout(snoopp_val_q)
   );

   tri_rlmreg_p #(.WIDTH(26), .INIT(0), .NEEDS_SRESET(1)) snoopp_attr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(snoopp_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[snoopp_attr_offset:snoopp_attr_offset + 26 - 1]),
      .scout(sov_1[snoopp_attr_offset:snoopp_attr_offset + 26 - 1]),
      .din(snoopp_attr_d),
      .dout(snoopp_attr_q)
   );

   tri_rlmreg_p #(.WIDTH((epn_width)), .INIT(0), .NEEDS_SRESET(1)) snoopp_vpn_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(snoopp_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[snoopp_vpn_offset:snoopp_vpn_offset + epn_width - 1]),
      .scout(sov_1[snoopp_vpn_offset:snoopp_vpn_offset + epn_width - 1]),
      .din(snoopp_vpn_d),
      .dout(snoopp_vpn_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ttype_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ttype_val_offset:ttype_val_offset + `THREADS - 1]),
      .scout(sov_1[ttype_val_offset:ttype_val_offset + `THREADS - 1]),
      .din(ttype_val_d),
      .dout(ttype_val_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ttype_offset:ttype_offset + 4 - 1]),
      .scout(sov_1[ttype_offset:ttype_offset + 4 - 1]),
      .din(ttype_d),
      .dout(ttype_q)
   );

   tri_rlmreg_p #(.WIDTH(ws_width), .INIT(0), .NEEDS_SRESET(1)) ws_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ws_offset:ws_offset + ws_width - 1]),
      .scout(sov_1[ws_offset:ws_offset + ws_width - 1]),
      .din(ws_d),
      .dout(ws_q)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) ra_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ra_entry_offset:ra_entry_offset + 5 - 1]),
      .scout(sov_1[ra_entry_offset:ra_entry_offset + 5 - 1]),
      .din(ra_entry_d),
      .dout(ra_entry_q)
   );

   tri_rlmreg_p #(.WIDTH(GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) rs_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rs_data_offset:rs_data_offset + GPR_WIDTH - 1]),
      .scout(sov_1[rs_data_offset:rs_data_offset + GPR_WIDTH - 1]),
      .din(rs_data_d),
      .dout(rs_data_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) eratre_hole_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eratre_hole_offset:eratre_hole_offset + 4 - 1]),
      .scout(sov_1[eratre_hole_offset:eratre_hole_offset + 4 - 1]),
      .din(eratre_hole_d),
      .dout(eratre_hole_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) eratwe_hole_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eratwe_hole_offset:eratwe_hole_offset + 4 - 1]),
      .scout(sov_1[eratwe_hole_offset:eratwe_hole_offset + 4 - 1]),
      .din(eratwe_hole_d),
      .dout(eratwe_hole_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rv1_csync_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rv1_csync_val_offset]),
      .scout(sov_1[rv1_csync_val_offset]),
      .din(rv1_csync_val_d),
      .dout(rv1_csync_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_csync_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex0_csync_val_offset]),
      .scout(sov_1[ex0_csync_val_offset]),
      .din(ex0_csync_val_d),
      .dout(ex0_csync_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rv1_isync_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rv1_isync_val_offset]),
      .scout(sov_1[rv1_isync_val_offset]),
      .din(rv1_isync_val_d),
      .dout(rv1_isync_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_isync_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex0_isync_val_offset]),
      .scout(sov_1[ex0_isync_val_offset]),
      .din(ex0_isync_val_d),
      .dout(ex0_isync_val_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) rv1_rel_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rv1_rel_val_offset:rv1_rel_val_offset + 4 - 1]),
      .scout(sov_1[rv1_rel_val_offset:rv1_rel_val_offset + 4 - 1]),
      .din(rv1_rel_val_d),
      .dout(rv1_rel_val_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex0_rel_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex0_rel_val_offset:ex0_rel_val_offset + 4 - 1]),
      .scout(sov_1[ex0_rel_val_offset:ex0_rel_val_offset + 4 - 1]),
      .din(ex0_rel_val_d),
      .dout(ex0_rel_val_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex1_rel_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex1_rel_val_offset:ex1_rel_val_offset + 4 - 1]),
      .scout(sov_1[ex1_rel_val_offset:ex1_rel_val_offset + 4 - 1]),
      .din(ex1_rel_val_d),
      .dout(ex1_rel_val_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) rv1_epsc_wr_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rv1_epsc_wr_val_offset:rv1_epsc_wr_val_offset + `THREADS - 1]),
      .scout(sov_1[rv1_epsc_wr_val_offset:rv1_epsc_wr_val_offset + `THREADS - 1]),
      .din(rv1_epsc_wr_val_d),
      .dout(rv1_epsc_wr_val_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex0_epsc_wr_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex0_epsc_wr_val_offset:ex0_epsc_wr_val_offset + `THREADS - 1]),
      .scout(sov_1[ex0_epsc_wr_val_offset:ex0_epsc_wr_val_offset + `THREADS - 1]),
      .din(ex0_epsc_wr_val_d),
      .dout(ex0_epsc_wr_val_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) rv1_eplc_wr_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rv1_eplc_wr_val_offset:rv1_eplc_wr_val_offset + `THREADS - 1]),
      .scout(sov_1[rv1_eplc_wr_val_offset:rv1_eplc_wr_val_offset + `THREADS - 1]),
      .din(rv1_eplc_wr_val_d),
      .dout(rv1_eplc_wr_val_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex0_eplc_wr_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex0_eplc_wr_val_offset:ex0_eplc_wr_val_offset + `THREADS - 1]),
      .scout(sov_1[ex0_eplc_wr_val_offset:ex0_eplc_wr_val_offset + `THREADS - 1]),
      .din(ex0_eplc_wr_val_d),
      .dout(ex0_eplc_wr_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_binv_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex0_binv_val_offset]),
      .scout(sov_1[ex0_binv_val_offset]),
      .din(ex0_binv_val_d),
      .dout(ex0_binv_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_binv_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex1_binv_val_offset]),
      .scout(sov_1[ex1_binv_val_offset]),
      .din(ex1_binv_val_d),
      .dout(ex1_binv_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rv1_snoop_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rv1_snoop_val_offset]),
      .scout(sov_1[rv1_snoop_val_offset]),
      .din(rv1_snoop_val_d),
      .dout(rv1_snoop_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_snoop_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex0_snoop_val_offset]),
      .scout(sov_1[ex0_snoop_val_offset]),
      .din(ex0_snoop_val_d),
      .dout(ex0_snoop_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_snoop_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex1_snoop_val_offset]),
      .scout(sov_1[ex1_snoop_val_offset]),
      .din(ex1_snoop_val_d),
      .dout(ex1_snoop_val_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) rv1_ttype_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rv1_ttype_val_offset:rv1_ttype_val_offset + `THREADS - 1]),
      .scout(sov_1[rv1_ttype_val_offset:rv1_ttype_val_offset + `THREADS - 1]),
      .din(rv1_ttype_val_d),
      .dout(rv1_ttype_val_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex0_ttype_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex0_ttype_val_offset:ex0_ttype_val_offset + `THREADS - 1]),
      .scout(sov_1[ex0_ttype_val_offset:ex0_ttype_val_offset + `THREADS - 1]),
      .din(ex0_ttype_val_d),
      .dout(ex0_ttype_val_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) rv1_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[rv1_ttype_offset:rv1_ttype_offset + 4 - 1]),
      .scout(sov_1[rv1_ttype_offset:rv1_ttype_offset + 4 - 1]),
      .din(rv1_ttype_d),
      .dout(rv1_ttype_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex0_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex0_ttype_offset:ex0_ttype_offset + 4 - 1]),
      .scout(sov_1[ex0_ttype_offset:ex0_ttype_offset + 4 - 1]),
      .din(ex0_ttype_d),
      .dout(ex0_ttype_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex1_ttype03_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex1_ttype03_offset:ex1_ttype03_offset + 4 - 1]),
      .scout(sov_1[ex1_ttype03_offset:ex1_ttype03_offset + 4 - 1]),
      .din(ex1_ttype03_d),
      .dout(ex1_ttype03_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex1_ttype67_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex1_ttype67_offset:ex1_ttype67_offset + 2 - 1]),
      .scout(sov_1[ex1_ttype67_offset:ex1_ttype67_offset + 2 - 1]),
      .din(ex1_ttype67_d),
      .dout(ex1_ttype67_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex1_valid_op_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex1_valid_op_offset:ex1_valid_op_offset + `THREADS - 1]),
      .scout(sov_1[ex1_valid_op_offset:ex1_valid_op_offset + `THREADS - 1]),
      .din(ex1_valid_op_d),
      .dout(ex1_valid_op_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex2_valid_op_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex2_valid_op_offset:ex2_valid_op_offset + `THREADS - 1]),
      .scout(sov_1[ex2_valid_op_offset:ex2_valid_op_offset + `THREADS - 1]),
      .din(ex2_valid_op_d),
      .dout(ex2_valid_op_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_valid_op_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex3_valid_op_offset:ex3_valid_op_offset + `THREADS - 1]),
      .scout(sov_1[ex3_valid_op_offset:ex3_valid_op_offset + `THREADS - 1]),
      .din(ex3_valid_op_d),
      .dout(ex3_valid_op_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_valid_op_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_valid_op_offset:ex4_valid_op_offset + `THREADS - 1]),
      .scout(sov_1[ex4_valid_op_offset:ex4_valid_op_offset + `THREADS - 1]),
      .din(ex4_valid_op_d),
      .dout(ex4_valid_op_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_valid_op_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_valid_op_offset:ex5_valid_op_offset + `THREADS - 1]),
      .scout(sov_1[ex5_valid_op_offset:ex5_valid_op_offset + `THREADS - 1]),
      .din(ex5_valid_op_d),
      .dout(ex5_valid_op_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex6_valid_op_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex6_valid_op_offset:ex6_valid_op_offset + `THREADS - 1]),
      .scout(sov_1[ex6_valid_op_offset:ex6_valid_op_offset + `THREADS - 1]),
      .din(ex6_valid_op_d),
      .dout(ex6_valid_op_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex7_valid_op_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex7_valid_op_offset:ex7_valid_op_offset + `THREADS - 1]),
      .scout(sov_1[ex7_valid_op_offset:ex7_valid_op_offset + `THREADS - 1]),
      .din(ex7_valid_op_d),
      .dout(ex7_valid_op_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex8_valid_op_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex8_valid_op_offset:ex8_valid_op_offset + `THREADS - 1]),
      .scout(sov_1[ex8_valid_op_offset:ex8_valid_op_offset + `THREADS - 1]),
      .din(ex8_valid_op_d),
      .dout(ex8_valid_op_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq_xu_ord_write_done_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[lq_xu_ord_write_done_offset]),
      .scout(sov_1[lq_xu_ord_write_done_offset]),
      .din(lq_xu_ord_write_done_d),
      .dout(lq_xu_ord_write_done_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq_xu_ord_read_done_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[lq_xu_ord_read_done_offset]),
      .scout(sov_1[lq_xu_ord_read_done_offset]),
      .din(lq_xu_ord_read_done_d),
      .dout(lq_xu_ord_read_done_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_lq_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[xu_lq_act_offset]),
      .scout(sov_1[xu_lq_act_offset]),
      .din(xu_lq_act_d),
      .dout(xu_lq_act_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) xu_lq_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[xu_lq_val_offset:xu_lq_val_offset + `THREADS - 1]),
      .scout(sov_1[xu_lq_val_offset:xu_lq_val_offset + `THREADS - 1]),
      .din(xu_lq_val_d),
      .dout(xu_lq_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_lq_is_eratre_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(xu_lq_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[xu_lq_is_eratre_offset]),
      .scout(sov_1[xu_lq_is_eratre_offset]),
      .din(xu_lq_is_eratre_d),
      .dout(xu_lq_is_eratre_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_lq_is_eratwe_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(xu_lq_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[xu_lq_is_eratwe_offset]),
      .scout(sov_1[xu_lq_is_eratwe_offset]),
      .din(xu_lq_is_eratwe_d),
      .dout(xu_lq_is_eratwe_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_lq_is_eratsx_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(xu_lq_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[xu_lq_is_eratsx_offset]),
      .scout(sov_1[xu_lq_is_eratsx_offset]),
      .din(xu_lq_is_eratsx_d),
      .dout(xu_lq_is_eratsx_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_lq_is_eratilx_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(xu_lq_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[xu_lq_is_eratilx_offset]),
      .scout(sov_1[xu_lq_is_eratilx_offset]),
      .din(xu_lq_is_eratilx_d),
      .dout(xu_lq_is_eratilx_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) xu_lq_ws_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(xu_lq_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[xu_lq_ws_offset:xu_lq_ws_offset + 2 - 1]),
      .scout(sov_1[xu_lq_ws_offset:xu_lq_ws_offset + 2 - 1]),
      .din(xu_lq_ws_d),
      .dout(xu_lq_ws_q)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) xu_lq_ra_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(xu_lq_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[xu_lq_ra_entry_offset:xu_lq_ra_entry_offset + 5 - 1]),
      .scout(sov_1[xu_lq_ra_entry_offset:xu_lq_ra_entry_offset + 5 - 1]),
      .din(xu_lq_ra_entry_d),
      .dout(xu_lq_ra_entry_q)
   );

   tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) xu_lq_rs_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(xu_lq_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[xu_lq_rs_data_offset:xu_lq_rs_data_offset + (2**`GPR_WIDTH_ENC) - 1]),
      .scout(sov_1[xu_lq_rs_data_offset:xu_lq_rs_data_offset + (2**`GPR_WIDTH_ENC) - 1]),
      .din(xu_lq_rs_data_d),
      .dout(xu_lq_rs_data_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
      .scout(sov_1[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
      .din(cp_flush_d),
      .dout(cp_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_oldest_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_oldest_itag_offset]),
      .scout(sov_1[ex4_oldest_itag_offset]),
      .din(ex4_oldest_itag_d),
      .dout(ex4_oldest_itag_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_nonspec_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_nonspec_val_offset]),
      .scout(sov_1[ex4_nonspec_val_offset]),
      .din(ex4_nonspec_val_d),
      .dout(ex4_nonspec_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_tlbmiss_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_tlbmiss_offset]),
      .scout(sov_1[ex4_tlbmiss_offset]),
      .din(ex4_tlbmiss_d),
      .dout(ex4_tlbmiss_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_tlbinelig_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_tlbinelig_offset]),
      .scout(sov_1[ex4_tlbinelig_offset]),
      .din(ex4_tlbinelig_d),
      .dout(ex4_tlbinelig_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_ptfault_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_ptfault_offset]),
      .scout(sov_1[ex4_ptfault_offset]),
      .din(ex4_ptfault_d),
      .dout(ex4_ptfault_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_lratmiss_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_lratmiss_offset]),
      .scout(sov_1[ex4_lratmiss_offset]),
      .din(ex4_lratmiss_d),
      .dout(ex4_lratmiss_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_tlb_multihit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_tlb_multihit_offset]),
      .scout(sov_1[ex4_tlb_multihit_offset]),
      .din(ex4_tlb_multihit_d),
      .dout(ex4_tlb_multihit_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_tlb_par_err_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_tlb_par_err_offset]),
      .scout(sov_1[ex4_tlb_par_err_offset]),
      .din(ex4_tlb_par_err_d),
      .dout(ex4_tlb_par_err_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_lru_par_err_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_lru_par_err_offset]),
      .scout(sov_1[ex4_lru_par_err_offset]),
      .din(ex4_lru_par_err_d),
      .dout(ex4_lru_par_err_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_tlb_excp_det_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_tlb_excp_det_offset]),
      .scout(sov_1[ex4_tlb_excp_det_offset]),
      .din(ex4_tlb_excp_det_d),
      .dout(ex4_tlb_excp_det_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ex3_eratm_itag_hit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex3_eratm_itag_hit_offset:ex3_eratm_itag_hit_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[ex3_eratm_itag_hit_offset:ex3_eratm_itag_hit_offset + `EMQ_ENTRIES - 1]),
      .din(ex3_eratm_itag_hit_d),
      .dout(ex3_eratm_itag_hit_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ex4_emq_excp_rpt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_emq_excp_rpt_offset:ex4_emq_excp_rpt_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[ex4_emq_excp_rpt_offset:ex4_emq_excp_rpt_offset + `EMQ_ENTRIES - 1]),
      .din(ex4_emq_excp_rpt_d),
      .dout(ex4_emq_excp_rpt_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ex5_emq_excp_rpt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_emq_excp_rpt_offset:ex5_emq_excp_rpt_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[ex5_emq_excp_rpt_offset:ex5_emq_excp_rpt_offset + `EMQ_ENTRIES - 1]),
      .din(ex5_emq_excp_rpt_d),
      .dout(ex5_emq_excp_rpt_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ex6_emq_excp_rpt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex6_emq_excp_rpt_offset:ex6_emq_excp_rpt_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[ex6_emq_excp_rpt_offset:ex6_emq_excp_rpt_offset + `EMQ_ENTRIES - 1]),
      .din(ex6_emq_excp_rpt_d),
      .dout(ex6_emq_excp_rpt_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_tlb_excp_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_tlb_excp_val_offset:ex5_tlb_excp_val_offset + `THREADS - 1]),
      .scout(sov_1[ex5_tlb_excp_val_offset:ex5_tlb_excp_val_offset + `THREADS - 1]),
      .din(ex5_tlb_excp_val_d),
      .dout(ex5_tlb_excp_val_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex6_tlb_excp_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex6_tlb_excp_val_offset:ex6_tlb_excp_val_offset + `THREADS - 1]),
      .scout(sov_1[ex6_tlb_excp_val_offset:ex6_tlb_excp_val_offset + `THREADS - 1]),
      .din(ex6_tlb_excp_val_d),
      .dout(ex6_tlb_excp_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_gate_miss_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_gate_miss_offset]),
      .scout(sov_1[ex4_gate_miss_offset]),
      .din(ex4_gate_miss_d),
      .dout(ex4_gate_miss_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_full_restart_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_full_restart_offset]),
      .scout(sov_1[ex4_full_restart_offset]),
      .din(ex4_full_restart_d),
      .dout(ex4_full_restart_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_itag_hit_restart_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_itag_hit_restart_offset]),
      .scout(sov_1[ex4_itag_hit_restart_offset]),
      .din(ex4_itag_hit_restart_d),
      .dout(ex4_itag_hit_restart_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_epn_hit_restart_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_epn_hit_restart_offset]),
      .scout(sov_1[ex4_epn_hit_restart_offset]),
      .din(ex4_epn_hit_restart_d),
      .dout(ex4_epn_hit_restart_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_setHold_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_setHold_offset]),
      .scout(sov_1[ex4_setHold_offset]),
      .din(ex4_setHold_d),
      .dout(ex4_setHold_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_tlbreq_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_tlbreq_val_offset]),
      .scout(sov_1[ex5_tlbreq_val_offset]),
      .din(ex5_tlbreq_val_d),
      .dout(ex5_tlbreq_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_tlbreq_nonspec_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_tlbreq_nonspec_offset]),
      .scout(sov_1[ex5_tlbreq_nonspec_offset]),
      .din(ex5_tlbreq_nonspec_d),
      .dout(ex5_tlbreq_nonspec_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_thdid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_thdid_offset:ex5_thdid_offset + `THREADS - 1]),
      .scout(sov_1[ex5_thdid_offset:ex5_thdid_offset + `THREADS - 1]),
      .din(ex5_thdid_d),
      .dout(ex5_thdid_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ex5_emq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_emq_offset:ex5_emq_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[ex5_emq_offset:ex5_emq_offset + `EMQ_ENTRIES - 1]),
      .din(ex5_emq_d),
      .dout(ex5_emq_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex5_tlbreq_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_tlbreq_ttype_offset:ex5_tlbreq_ttype_offset + 2 - 1]),
      .scout(sov_1[ex5_tlbreq_ttype_offset:ex5_tlbreq_ttype_offset + 2 - 1]),
      .din(ex5_tlbreq_ttype_d),
      .dout(ex5_tlbreq_ttype_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_perf_dtlb_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_perf_dtlb_offset:ex5_perf_dtlb_offset + `THREADS - 1]),
      .scout(sov_1[ex5_perf_dtlb_offset:ex5_perf_dtlb_offset + `THREADS - 1]),
      .din(ex5_perf_dtlb_d),
      .dout(ex5_perf_dtlb_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) derat_dcc_clr_hold_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[derat_dcc_clr_hold_offset:derat_dcc_clr_hold_offset + `THREADS - 1]),
      .scout(sov_1[derat_dcc_clr_hold_offset:derat_dcc_clr_hold_offset + `THREADS - 1]),
      .din(derat_dcc_clr_hold_d),
      .dout(derat_dcc_clr_hold_q)
   );

   generate

         genvar emq;

         for (emq = 0; emq <= `EMQ_ENTRIES - 1; emq = emq + 1)
         begin : eratm_entry_state

            tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_state_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(tiup),
               .thold_b(pc_func_slp_sl_thold_0_b),
               .sg(pc_sg_0),
               .force_t(pc_func_slp_sl_force),
               .delay_lclkr(lcb_delay_lclkr_dc[0]),
               .mpw1_b(lcb_mpw1_dc_b[0]),
               .mpw2_b(lcb_mpw2_dc_b),
               .d_mode(lcb_d_mode_dc),
               .scin(siv_1[eratm_entry_state_offset + (3 * emq):eratm_entry_state_offset + (3 * (emq + 1)) - 1]),
               .scout(sov_1[eratm_entry_state_offset + (3 * emq):eratm_entry_state_offset + (3 * (emq + 1)) - 1]),
               .din(eratm_entry_state_d[emq]),
               .dout(eratm_entry_state_q[emq])
            );
         end

         for (emq = 0; emq <= `EMQ_ENTRIES - 1; emq = emq + 1)
         begin : eratm_entry_itag

            tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_itag_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(ex4_entry_wrt_val[emq]),
               .thold_b(pc_func_slp_sl_thold_0_b),
               .sg(pc_sg_0),
               .force_t(pc_func_slp_sl_force),
               .delay_lclkr(lcb_delay_lclkr_dc[0]),
               .mpw1_b(lcb_mpw1_dc_b[0]),
               .mpw2_b(lcb_mpw2_dc_b),
               .d_mode(lcb_d_mode_dc),
               .scin(siv_1[eratm_entry_itag_offset + (`ITAG_SIZE_ENC * emq):eratm_entry_itag_offset + (`ITAG_SIZE_ENC * (emq + 1)) - 1]),
               .scout(sov_1[eratm_entry_itag_offset + (`ITAG_SIZE_ENC * emq):eratm_entry_itag_offset + (`ITAG_SIZE_ENC * (emq + 1)) - 1]),
               .din(eratm_entry_itag_d[emq]),
               .dout(eratm_entry_itag_q[emq])
            );
         end

         for (emq = 0; emq <= `EMQ_ENTRIES - 1; emq = emq + 1)
         begin : eratm_entry_tid

            tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_tid_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(ex4_entry_wrt_val[emq]),
               .thold_b(pc_func_slp_sl_thold_0_b),
               .sg(pc_sg_0),
               .force_t(pc_func_slp_sl_force),
               .delay_lclkr(lcb_delay_lclkr_dc[0]),
               .mpw1_b(lcb_mpw1_dc_b[0]),
               .mpw2_b(lcb_mpw2_dc_b),
               .d_mode(lcb_d_mode_dc),
               .scin(siv_1[eratm_entry_tid_offset + (`THREADS * emq):eratm_entry_tid_offset + (`THREADS * (emq + 1)) - 1]),
               .scout(sov_1[eratm_entry_tid_offset + (`THREADS * emq):eratm_entry_tid_offset + (`THREADS * (emq + 1)) - 1]),
               .din(eratm_entry_tid_d[emq]),
               .dout(eratm_entry_tid_q[emq])
            );
         end

         for (emq = 0; emq <= `EMQ_ENTRIES - 1; emq = emq + 1)
         begin : eratm_entry_epn

            tri_rlmreg_p #(.WIDTH((51-(64-(2**`GPR_WIDTH_ENC))+1)), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_epn_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(ex4_entry_wrt_val[emq]),
               .thold_b(pc_func_slp_sl_thold_0_b),
               .sg(pc_sg_0),
               .force_t(pc_func_slp_sl_force),
               .delay_lclkr(lcb_delay_lclkr_dc[0]),
               .mpw1_b(lcb_mpw1_dc_b[0]),
               .mpw2_b(lcb_mpw2_dc_b),
               .d_mode(lcb_d_mode_dc),
               .scin(siv_1[eratm_entry_epn_offset + ((51-(64-(2**`GPR_WIDTH_ENC))+1) * emq):eratm_entry_epn_offset + ((51-(64-(2**`GPR_WIDTH_ENC))+1) * (emq + 1)) - 1]),
               .scout(sov_1[eratm_entry_epn_offset + ((51-(64-(2**`GPR_WIDTH_ENC))+1) * emq):eratm_entry_epn_offset + ((51-(64-(2**`GPR_WIDTH_ENC))+1) * (emq + 1)) - 1]),
               .din(eratm_entry_epn_d[emq]),
               .dout(eratm_entry_epn_q[emq])
            );
         end

   endgenerate
/*
   generate
      begin : eratm_entry_itag
         genvar                            emq;
         for (emq = 0; emq <= `EMQ_ENTRIES - 1; emq = emq + 1)
         begin : eratm_entry_itag

            tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_itag_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(ex4_entry_wrt_val[emq]),
               .thold_b(pc_func_slp_sl_thold_0_b),
               .sg(pc_sg_0),
               .force_t(pc_func_slp_sl_force),
               .delay_lclkr(lcb_delay_lclkr_dc[0]),
               .mpw1_b(lcb_mpw1_dc_b[0]),
               .mpw2_b(lcb_mpw2_dc_b),
               .d_mode(lcb_d_mode_dc),
               .scin(siv_1[eratm_entry_itag_offset + (`ITAG_SIZE_ENC * emq):eratm_entry_itag_offset + (`ITAG_SIZE_ENC * (emq + 1)) - 1]),
               .scout(sov_1[eratm_entry_itag_offset + (`ITAG_SIZE_ENC * emq):eratm_entry_itag_offset + (`ITAG_SIZE_ENC * (emq + 1)) - 1]),
               .din(eratm_entry_itag_d[emq]),
               .dout(eratm_entry_itag_q[emq])
            );
         end
      end
   endgenerate
*/
/*
   generate
      begin : eratm_entry_tid
         genvar                            emq;
         for (emq = 0; emq <= `EMQ_ENTRIES - 1; emq = emq + 1)
         begin : eratm_entry_tid

            tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_tid_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(ex4_entry_wrt_val[emq]),
               .thold_b(pc_func_slp_sl_thold_0_b),
               .sg(pc_sg_0),
               .force_t(pc_func_slp_sl_force),
               .delay_lclkr(lcb_delay_lclkr_dc[0]),
               .mpw1_b(lcb_mpw1_dc_b[0]),
               .mpw2_b(lcb_mpw2_dc_b),
               .d_mode(lcb_d_mode_dc),
               .scin(siv_1[eratm_entry_tid_offset + (`THREADS * emq):eratm_entry_tid_offset + (`THREADS * (emq + 1)) - 1]),
               .scout(sov_1[eratm_entry_tid_offset + (`THREADS * emq):eratm_entry_tid_offset + (`THREADS * (emq + 1)) - 1]),
               .din(eratm_entry_tid_d[emq]),
               .dout(eratm_entry_tid_q[emq])
            );
         end
      end
   endgenerate
*/
/*
   generate
      begin : eratm_entry_epn
         genvar                            emq;
         for (emq = 0; emq <= `EMQ_ENTRIES - 1; emq = emq + 1)
         begin : eratm_entry_epn

            tri_rlmreg_p #(.WIDTH((51-(64-(2**GPR_WIDTH_ENC))+1)), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_epn_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(ex4_entry_wrt_val[emq]),
               .thold_b(pc_func_slp_sl_thold_0_b),
               .sg(pc_sg_0),
               .force_t(pc_func_slp_sl_force),
               .delay_lclkr(lcb_delay_lclkr_dc[0]),
               .mpw1_b(lcb_mpw1_dc_b[0]),
               .mpw2_b(lcb_mpw2_dc_b),
               .d_mode(lcb_d_mode_dc),
               .scin(siv_1[eratm_entry_epn_offset + ((51-(64-(2**GPR_WIDTH_ENC))+1) * emq):eratm_entry_epn_offset + ((51-(64-(2**GPR_WIDTH_ENC))+1) * (emq + 1)) - 1]),
               .scout(sov_1[eratm_entry_epn_offset + ((51-(64-(2**GPR_WIDTH_ENC))+1) * emq):eratm_entry_epn_offset + ((51-(64-(2**GPR_WIDTH_ENC))+1) * (emq + 1)) - 1]),
               .din(eratm_entry_epn_d[emq]),
               .dout(eratm_entry_epn_q[emq])
            );
         end
      end
   endgenerate
*/

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_nonspec_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eratm_entry_nonspec_val_offset:eratm_entry_nonspec_val_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[eratm_entry_nonspec_val_offset:eratm_entry_nonspec_val_offset + `EMQ_ENTRIES - 1]),
      .din(eratm_entry_nonspec_val_d),
      .dout(eratm_entry_nonspec_val_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_mkill_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eratm_entry_mkill_offset:eratm_entry_mkill_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[eratm_entry_mkill_offset:eratm_entry_mkill_offset + `EMQ_ENTRIES - 1]),
      .din(eratm_entry_mkill_d),
      .dout(eratm_entry_mkill_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) eratm_hold_tid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eratm_hold_tid_offset:eratm_hold_tid_offset + `THREADS - 1]),
      .scout(sov_1[eratm_hold_tid_offset:eratm_hold_tid_offset + `THREADS - 1]),
      .din(eratm_hold_tid_d),
      .dout(eratm_hold_tid_q)
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) mm_int_rpt_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mm_int_rpt_itag_offset:mm_int_rpt_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov_1[mm_int_rpt_itag_offset:mm_int_rpt_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(mm_int_rpt_itag_d),
      .dout(mm_int_rpt_itag_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mm_int_rpt_tlbmiss_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mm_int_rpt_tlbmiss_offset]),
      .scout(sov_1[mm_int_rpt_tlbmiss_offset]),
      .din(mm_int_rpt_tlbmiss_d),
      .dout(mm_int_rpt_tlbmiss_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mm_int_rpt_tlbinelig_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mm_int_rpt_tlbinelig_offset]),
      .scout(sov_1[mm_int_rpt_tlbinelig_offset]),
      .din(mm_int_rpt_tlbinelig_d),
      .dout(mm_int_rpt_tlbinelig_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mm_int_rpt_ptfault_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mm_int_rpt_ptfault_offset]),
      .scout(sov_1[mm_int_rpt_ptfault_offset]),
      .din(mm_int_rpt_ptfault_d),
      .dout(mm_int_rpt_ptfault_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mm_int_rpt_lratmiss_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mm_int_rpt_lratmiss_offset]),
      .scout(sov_1[mm_int_rpt_lratmiss_offset]),
      .din(mm_int_rpt_lratmiss_d),
      .dout(mm_int_rpt_lratmiss_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mm_int_rpt_tlb_multihit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mm_int_rpt_tlb_multihit_offset]),
      .scout(sov_1[mm_int_rpt_tlb_multihit_offset]),
      .din(mm_int_rpt_tlb_multihit_d),
      .dout(mm_int_rpt_tlb_multihit_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mm_int_rpt_tlb_par_err_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mm_int_rpt_tlb_par_err_offset]),
      .scout(sov_1[mm_int_rpt_tlb_par_err_offset]),
      .din(mm_int_rpt_tlb_par_err_d),
      .dout(mm_int_rpt_tlb_par_err_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mm_int_rpt_lru_par_err_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mm_int_rpt_lru_par_err_offset]),
      .scout(sov_1[mm_int_rpt_lru_par_err_offset]),
      .din(mm_int_rpt_lru_par_err_d),
      .dout(mm_int_rpt_lru_par_err_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_tlbmiss_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eratm_entry_tlbmiss_offset:eratm_entry_tlbmiss_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[eratm_entry_tlbmiss_offset:eratm_entry_tlbmiss_offset + `EMQ_ENTRIES - 1]),
      .din(eratm_entry_tlbmiss_d),
      .dout(eratm_entry_tlbmiss_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_tlbinelig_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eratm_entry_tlbinelig_offset:eratm_entry_tlbinelig_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[eratm_entry_tlbinelig_offset:eratm_entry_tlbinelig_offset + `EMQ_ENTRIES - 1]),
      .din(eratm_entry_tlbinelig_d),
      .dout(eratm_entry_tlbinelig_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_ptfault_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eratm_entry_ptfault_offset:eratm_entry_ptfault_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[eratm_entry_ptfault_offset:eratm_entry_ptfault_offset + `EMQ_ENTRIES - 1]),
      .din(eratm_entry_ptfault_d),
      .dout(eratm_entry_ptfault_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_lratmiss_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eratm_entry_lratmiss_offset:eratm_entry_lratmiss_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[eratm_entry_lratmiss_offset:eratm_entry_lratmiss_offset + `EMQ_ENTRIES - 1]),
      .din(eratm_entry_lratmiss_d),
      .dout(eratm_entry_lratmiss_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_tlb_multihit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eratm_entry_tlb_multihit_offset:eratm_entry_tlb_multihit_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[eratm_entry_tlb_multihit_offset:eratm_entry_tlb_multihit_offset + `EMQ_ENTRIES - 1]),
      .din(eratm_entry_tlb_multihit_d),
      .dout(eratm_entry_tlb_multihit_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_tlb_par_err_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eratm_entry_tlb_par_err_offset:eratm_entry_tlb_par_err_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[eratm_entry_tlb_par_err_offset:eratm_entry_tlb_par_err_offset + `EMQ_ENTRIES - 1]),
      .din(eratm_entry_tlb_par_err_d),
      .dout(eratm_entry_tlb_par_err_q)
   );

   tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) eratm_entry_lru_par_err_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[eratm_entry_lru_par_err_offset:eratm_entry_lru_par_err_offset + `EMQ_ENTRIES - 1]),
      .scout(sov_1[eratm_entry_lru_par_err_offset:eratm_entry_lru_par_err_offset + `EMQ_ENTRIES - 1]),
      .din(eratm_entry_lru_par_err_d),
      .dout(eratm_entry_lru_par_err_q)
   );


   //------------------------------------------------
   // scan only latches for boot config
   //------------------------------------------------

         tri_slat_scan #(.WIDTH(16), .INIT(`DERAT_BCFG_EPN_0TO15), .RESET_INVERTS_SCAN(1'b1)) bcfg_epn_0to15_latch(
            .vd(vdd),
            .gd(gnd),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk),
            .scan_in(bsiv[bcfg_offset:bcfg_offset + 15]),
            .scan_out(bsov[bcfg_offset:bcfg_offset + 15]),
            .q(bcfg_q[0:15]),
            .q_b(bcfg_q_b[0:15])
         );

         tri_slat_scan #(.WIDTH(16), .INIT(`DERAT_BCFG_EPN_16TO31), .RESET_INVERTS_SCAN(1'b1)) bcfg_epn_16to31_latch(
            .vd(vdd),
            .gd(gnd),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk),
            .scan_in(bsiv[bcfg_offset + 16:bcfg_offset + 31]),
            .scan_out(bsov[bcfg_offset + 16:bcfg_offset + 31]),
            .q(bcfg_q[16:31]),
            .q_b(bcfg_q_b[16:31])
         );

         tri_slat_scan #(.WIDTH(16), .INIT(`DERAT_BCFG_EPN_32TO47), .RESET_INVERTS_SCAN(1'b1)) bcfg_epn_32to47_latch(
            .vd(vdd),
            .gd(gnd),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk),
            .scan_in(bsiv[bcfg_offset + 32:bcfg_offset + 47]),
            .scan_out(bsov[bcfg_offset + 32:bcfg_offset + 47]),
            .q(bcfg_q[32:47]),
            .q_b(bcfg_q_b[32:47])
         );

         tri_slat_scan #(.WIDTH(4), .INIT(`DERAT_BCFG_EPN_48TO51), .RESET_INVERTS_SCAN(1'b1)) bcfg_epn_48to51_latch(
            .vd(vdd),
            .gd(gnd),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk),
            .scan_in(bsiv[bcfg_offset + 48:bcfg_offset + 51]),
            .scan_out(bsov[bcfg_offset + 48:bcfg_offset + 51]),
            .q(bcfg_q[48:51]),
            .q_b(bcfg_q_b[48:51])
         );

         tri_slat_scan #(.WIDTH(10), .INIT(`DERAT_BCFG_RPN_22TO31), .RESET_INVERTS_SCAN(1'b1)) bcfg_rpn_22to31_latch(
            .vd(vdd),
            .gd(gnd),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk),
            .scan_in(bsiv[bcfg_offset + 52:bcfg_offset + 61]),
            .scan_out(bsov[bcfg_offset + 52:bcfg_offset + 61]),
            .q(bcfg_q[52:61]),
            .q_b(bcfg_q_b[52:61])
         );

         tri_slat_scan #(.WIDTH(16), .INIT(`DERAT_BCFG_RPN_32TO47), .RESET_INVERTS_SCAN(1'b1)) bcfg_rpn_32to47_latch(
            .vd(vdd),
            .gd(gnd),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk),
            .scan_in(bsiv[bcfg_offset + 62:bcfg_offset + 77]),
            .scan_out(bsov[bcfg_offset + 62:bcfg_offset + 77]),
            .q(bcfg_q[62:77]),
            .q_b(bcfg_q_b[62:77])
         );

         tri_slat_scan #(.WIDTH(4), .INIT(`DERAT_BCFG_RPN_48TO51), .RESET_INVERTS_SCAN(1'b1)) bcfg_rpn_48to51_latch(
            .vd(vdd),
            .gd(gnd),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk),
            .scan_in(bsiv[bcfg_offset + 78:bcfg_offset + 81]),
            .scan_out(bsov[bcfg_offset + 78:bcfg_offset + 81]),
            .q(bcfg_q[78:81]),
            .q_b(bcfg_q_b[78:81])
         );

         tri_slat_scan #(.WIDTH(5), .INIT(`DERAT_BCFG_ATTR), .RESET_INVERTS_SCAN(1'b1)) bcfg_attr_latch(
            .vd(vdd),
            .gd(gnd),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk),
            .scan_in(bsiv[bcfg_offset + 82:bcfg_offset + 86]),
            .scan_out(bsov[bcfg_offset + 82:bcfg_offset + 86]),
            .q(bcfg_q[82:86]),
            .q_b(bcfg_q_b[82:86])
         );

         tri_slat_scan #(.WIDTH(16), .INIT(`DERAT_BCFG_RPN2_32TO47), .RESET_INVERTS_SCAN(1'b1)) bcfg_rpn2_32to47_latch(
            .vd(vdd),
            .gd(gnd),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk),
            .scan_in(bsiv[bcfg_offset + 87:bcfg_offset + 102]),
            .scan_out(bsov[bcfg_offset + 87:bcfg_offset + 102]),
            .q(bcfg_q[87:102]),
            .q_b(bcfg_q_b[87:102])
         );

         tri_slat_scan #(.WIDTH(4), .INIT(`DERAT_BCFG_RPN2_48TO51), .RESET_INVERTS_SCAN(1'b1)) bcfg_rpn2_48to51_latch(
            .vd(vdd),
            .gd(gnd),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk),
            .scan_in(bsiv[bcfg_offset + 103:bcfg_offset + 106]),
            .scan_out(bsov[bcfg_offset + 103:bcfg_offset + 106]),
            .q(bcfg_q[103:106]),
            .q_b(bcfg_q_b[103:106])
         );

         tri_slat_scan #(.WIDTH(16), .INIT(0), .RESET_INVERTS_SCAN(1'b1)) bcfg_spare_latch(
            .vd(vdd),
            .gd(gnd),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk),
            .scan_in(bsiv[bcfg_offset + 107:bcfg_offset + 122]),
            .scan_out(bsov[bcfg_offset + 107:bcfg_offset + 122]),
            .q(bcfg_q[107:122]),
            .q_b(bcfg_q_b[107:122])
         );

   //------------------------------------------------
   // thold/sg latches
   //------------------------------------------------

   tri_plat #(.WIDTH(4)) perv_2to1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(pc_xu_ccflush_dc),
      .din({pc_func_sl_thold_2, pc_func_slp_sl_thold_2, pc_cfg_slp_sl_thold_2, pc_sg_2}),
      .q({pc_func_sl_thold_1, pc_func_slp_sl_thold_1, pc_cfg_slp_sl_thold_1, pc_sg_1})
   );

   tri_plat #(.WIDTH(4)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(pc_xu_ccflush_dc),
      .din({pc_func_sl_thold_1, pc_func_slp_sl_thold_1, pc_cfg_slp_sl_thold_1, pc_sg_1}),
      .q({pc_func_sl_thold_0, pc_func_slp_sl_thold_0, pc_cfg_slp_sl_thold_0, pc_sg_0})
   );

   tri_lcbor  perv_lcbor_func_sl(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(pc_func_sl_thold_0),
      .sg(pc_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(pc_func_sl_force),
      .thold_b(pc_func_sl_thold_0_b)
   );

   tri_lcbor  perv_lcbor_func_slp_sl(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(pc_func_slp_sl_thold_0),
      .sg(pc_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(pc_func_slp_sl_force),
      .thold_b(pc_func_slp_sl_thold_0_b)
   );

         //------------------------------------------------
         // local clock buffer for boot config
         //------------------------------------------------

         tri_lcbs bcfg_lcb(
            .vd(vdd),
            .gd(gnd),
            .delay_lclkr(lcb_delay_lclkr_dc[0]),
            .nclk(nclk),
            .force_t(pc_cfg_slp_sl_force),
            .thold_b(pc_cfg_slp_sl_thold_0_b),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk)
         );
         // these terms in the absence of another lcbor component
         //  that drives the thold_b and force into the bcfg_lcb for slat's
         assign pc_cfg_slp_sl_thold_0_b = (~pc_cfg_slp_sl_thold_0);
         assign pc_cfg_slp_sl_force     = pc_sg_0;

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv_0[0:scan_right_0]   = {sov_0[1:scan_right_0], ac_func_scan_in[0]};
   assign func_si_cam_int         = sov_0[0];
   assign ac_func_scan_out[0]     = func_so_cam_int;
   assign siv_1[0:scan_right_1]   = {sov_1[1:scan_right_1], ac_func_scan_in[1]};
   assign ac_func_scan_out[1]     = sov_1[0];
   assign bsiv[0:boot_scan_right] = {bsov[1:boot_scan_right], ac_ccfg_scan_in};
   assign ac_ccfg_scan_out        = bsov[0];

endmodule
