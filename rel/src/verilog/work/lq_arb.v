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

//  Description:  XU LSU Store Data Rotator Wrapper
//
//*****************************************************************************

// ##########################################################################################
// VHDL Contents
// 1) Load Queue
// 2) Store Queue
// 3) Load/Store Queue Control
// ##########################################################################################

`include "tri_a2o.vh"

//   parameter                              EXPAND_TYPE = 2;		// 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
// `define                                   LOAD_CREDITS   16
// `define                                   STORE_CREDITS   32
//   parameter                              ITAG_SIZE_ENC = 7;
//   parameter                              CL_SIZE = 6;		// 6 => 64B CLINE, 7 => 128B CLINE
//   parameter                              THREADS = 2;		// Number of Threads in the system
//   parameter                              STQ_DATA_SIZE = 64;		// 64 or 128 Bit store data sizes supported
//   parameter                              REAL_IFAR_WIDTH = 42;		// real addressing bits

module lq_arb(
   imq_arb_iuq_ld_req_avail,
   imq_arb_iuq_tid,
   imq_arb_iuq_usr_def,
   imq_arb_iuq_wimge,
   imq_arb_iuq_p_addr,
   imq_arb_iuq_ttype,
   imq_arb_iuq_opSize,
   imq_arb_iuq_cTag,
   imq_arb_mmq_ld_req_avail,
   imq_arb_mmq_st_req_avail,
   imq_arb_mmq_tid,
   imq_arb_mmq_usr_def,
   imq_arb_mmq_wimge,
   imq_arb_mmq_p_addr,
   imq_arb_mmq_ttype,
   imq_arb_mmq_opSize,
   imq_arb_mmq_cTag,
   imq_arb_mmq_st_data,
   ldq_arb_ld_req_pwrToken,
   ldq_arb_ld_req_avail,
   ldq_arb_tid,
   ldq_arb_usr_def,
   ldq_arb_wimge,
   ldq_arb_p_addr,
   ldq_arb_ttype,
   ldq_arb_opSize,
   ldq_arb_cTag,
   stq_arb_stq1_stg_act,
   stq_arb_st_req_avail,
   stq_arb_stq3_cmmt_val,
   stq_arb_stq3_cmmt_reject,
   stq_arb_stq3_req_val,
   stq_arb_stq3_tid,
   stq_arb_stq3_usrDef,
   stq_arb_stq3_wimge,
   stq_arb_stq3_p_addr,
   stq_arb_stq3_ttype,
   stq_arb_stq3_opSize,
   stq_arb_stq3_byteEn,
   stq_arb_stq3_cTag,
   dat_lsq_stq4_128data,
   ldq_arb_rel1_stg_act,
   ldq_arb_rel1_data_sel,
   ldq_arb_rel1_data,
   ldq_arb_rel1_blk_store,
   ldq_arb_rel1_axu_val,
   ldq_arb_rel1_op_size,
   ldq_arb_rel1_addr,
   ldq_arb_rel1_ci,
   ldq_arb_rel1_byte_swap,
   ldq_arb_rel1_thrd_id,
   ldq_arb_rel2_rdat_sel,
   stq_arb_stq1_axu_val,
   stq_arb_stq1_epid_val,
   stq_arb_stq1_opSize,
   stq_arb_stq1_p_addr,
   stq_arb_stq1_wimge_i,
   stq_arb_stq1_store_data,
   stq_arb_stq1_byte_swap,
   stq_arb_stq1_thrd_id,
   stq_arb_release_itag_vld,
   stq_arb_release_itag,
   stq_arb_release_tid,
   l2_lsq_req_ld_pop,
   l2_lsq_req_st_pop,
   l2_lsq_req_st_gather,
   ctl_lsq_stq3_icswx_data,
   ldq_arb_rel2_rd_data,
   arb_ldq_rel2_wrt_data,
   arb_stq_cred_avail,
   arb_ldq_ldq_unit_sel,
   arb_imq_iuq_unit_sel,
   arb_imq_mmq_unit_sel,
   lsq_ctl_stq1_axu_val,
   lsq_ctl_stq1_epid_val,
   lsq_dat_stq1_le_mode,
   lsq_dat_stq1_op_size,
   lsq_dat_stq1_addr,
   lsq_dat_stq2_store_data,
   lsq_ctl_stq1_addr,
   lsq_ctl_stq1_ci,
   lsq_ctl_stq1_thrd_id,
   lsq_ctl_stq_release_itag_vld,
   lsq_ctl_stq_release_itag,
   lsq_ctl_stq_release_tid,
   lsq_l2_pwrToken,
   lsq_l2_valid,
   lsq_l2_tid,
   lsq_l2_p_addr,
   lsq_l2_wimge,
   lsq_l2_usrDef,
   lsq_l2_byteEn,
   lsq_l2_ttype,
   lsq_l2_opSize,
   lsq_l2_coreTag,
   lsq_l2_dataToken,
   lsq_l2_st_data,
   ctl_lsq_spr_lsucr0_b2b,
   xu_lq_spr_xucr0_cred,
   xu_lq_spr_xucr0_cls,
   lq_pc_err_l2credit_overrun,
   vdd,
   gnd,
   nclk,
   sg_0,
   func_sl_thold_0_b,
   func_sl_force,
   func_slp_sl_thold_0_b,
   func_slp_sl_force,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   scan_in,
   scan_out
);

   // IUQ Request to the L2
   input                                  imq_arb_iuq_ld_req_avail;
   input [0:1]                            imq_arb_iuq_tid;
   input [0:3]                            imq_arb_iuq_usr_def;
   input [0:4]                            imq_arb_iuq_wimge;
   input [64-`REAL_IFAR_WIDTH:63]         imq_arb_iuq_p_addr;
   input [0:5]                            imq_arb_iuq_ttype;
   input [0:2]                            imq_arb_iuq_opSize;
   input [0:4]                            imq_arb_iuq_cTag;

   // MMQ Request to the L2
   input                                  imq_arb_mmq_ld_req_avail;
   input                                  imq_arb_mmq_st_req_avail;
   input [0:1]                            imq_arb_mmq_tid;
   input [0:3]                            imq_arb_mmq_usr_def;
   input [0:4]                            imq_arb_mmq_wimge;
   input [64-`REAL_IFAR_WIDTH:63]         imq_arb_mmq_p_addr;
   input [0:5]                            imq_arb_mmq_ttype;
   input [0:2]                            imq_arb_mmq_opSize;
   input [0:4]                            imq_arb_mmq_cTag;
   input [0:15]                           imq_arb_mmq_st_data;

   // LDQ Request to the L2
   input                                  ldq_arb_ld_req_pwrToken;
   input                                  ldq_arb_ld_req_avail;
   input [0:1]                            ldq_arb_tid;
   input [0:3]                            ldq_arb_usr_def;
   input [0:4]                            ldq_arb_wimge;
   input [64-`REAL_IFAR_WIDTH:63]         ldq_arb_p_addr;
   input [0:5]                            ldq_arb_ttype;
   input [0:2]                            ldq_arb_opSize;
   input [0:4]                            ldq_arb_cTag;

   // Store Type Request to L2
   input                                  stq_arb_stq1_stg_act;
   input                                  stq_arb_st_req_avail;
   input                                  stq_arb_stq3_cmmt_val;
   input                                  stq_arb_stq3_cmmt_reject;
   input                                  stq_arb_stq3_req_val;
   input [0:1]                            stq_arb_stq3_tid;
   input [0:3]                            stq_arb_stq3_usrDef;
   input [0:4]                            stq_arb_stq3_wimge;
   input [64-`REAL_IFAR_WIDTH:63]         stq_arb_stq3_p_addr;
   input [0:5]                            stq_arb_stq3_ttype;
   input [0:2]                            stq_arb_stq3_opSize;
   input [0:15]                           stq_arb_stq3_byteEn;
   input [0:4]                            stq_arb_stq3_cTag;
   input [0:127]                          dat_lsq_stq4_128data;

   // Common Between LDQ and STQ
   input                                  ldq_arb_rel1_stg_act;
   input                                  ldq_arb_rel1_data_sel;
   input [0:127]                          ldq_arb_rel1_data;
   input                                  ldq_arb_rel1_blk_store;
   input                                  ldq_arb_rel1_axu_val;
   input [0:2]                            ldq_arb_rel1_op_size;
   input [64-`REAL_IFAR_WIDTH:63]         ldq_arb_rel1_addr;
   input                                  ldq_arb_rel1_ci;
   input                                  ldq_arb_rel1_byte_swap;
   input [0:`THREADS-1]                   ldq_arb_rel1_thrd_id;
   input                                  ldq_arb_rel2_rdat_sel;
   input                                  stq_arb_stq1_axu_val;
   input                                  stq_arb_stq1_epid_val;
   input [0:2]                            stq_arb_stq1_opSize;
   input [64-`REAL_IFAR_WIDTH:63]         stq_arb_stq1_p_addr;
   input                                  stq_arb_stq1_wimge_i;
   input [(128-`STQ_DATA_SIZE):127]       stq_arb_stq1_store_data;
   input                                  stq_arb_stq1_byte_swap;
   input [0:`THREADS-1]                   stq_arb_stq1_thrd_id;
   input                                  stq_arb_release_itag_vld;
   input [0:`ITAG_SIZE_ENC-1]             stq_arb_release_itag;
   input [0:`THREADS-1]                   stq_arb_release_tid;

   // L2 Credit Control
   input                                  l2_lsq_req_ld_pop;
   input                                  l2_lsq_req_st_pop;
   input                                  l2_lsq_req_st_gather;

   // ICSWX Data to be sent to the L2
   input [0:26]                           ctl_lsq_stq3_icswx_data;

   // Interface with Reload Data Queue
   input [0:143]                          ldq_arb_rel2_rd_data;
   output [0:143]                         arb_ldq_rel2_wrt_data;

   // L2 Credits Available
   output                                 arb_stq_cred_avail;

   // Unit Selected to Send Request to the L2
   output                                 arb_ldq_ldq_unit_sel;
   output                                 arb_imq_iuq_unit_sel;
   output                                 arb_imq_mmq_unit_sel;

   // Common Between LDQ and STQ
   output                                 lsq_ctl_stq1_axu_val;
   output                                 lsq_ctl_stq1_epid_val;
   output                                 lsq_dat_stq1_le_mode;
   output [0:2]                           lsq_dat_stq1_op_size;
   output [52:63]                         lsq_dat_stq1_addr;
   output [0:143]                         lsq_dat_stq2_store_data;
   output [64-`REAL_IFAR_WIDTH:63-`CL_SIZE] lsq_ctl_stq1_addr;
   output                                 lsq_ctl_stq1_ci;
   output [0:`THREADS-1]                  lsq_ctl_stq1_thrd_id;

   // STCX/ICSWX Itag Complete
   output                                 lsq_ctl_stq_release_itag_vld;
   output [0:`ITAG_SIZE_ENC-1]            lsq_ctl_stq_release_itag;
   output [0:`THREADS-1]                  lsq_ctl_stq_release_tid;

   // L2 Request Signals
   output                                 lsq_l2_pwrToken;
   output                                 lsq_l2_valid;
   output [0:1]                           lsq_l2_tid;
   output [64-`REAL_IFAR_WIDTH:63]        lsq_l2_p_addr;
   output [0:4]                           lsq_l2_wimge;
   output [0:3]                           lsq_l2_usrDef;
   output [0:15]                          lsq_l2_byteEn;
   output [0:5]                           lsq_l2_ttype;
   output [0:2]                           lsq_l2_opSize;
   output [0:4]                           lsq_l2_coreTag;
   output                                 lsq_l2_dataToken;
   output [0:127]                         lsq_l2_st_data;

   // SPR Bits
   input                                  ctl_lsq_spr_lsucr0_b2b;		// LSUCR0[B2B] Mode enabled
   input                                  xu_lq_spr_xucr0_cred;         // XUCR0[CRED] Mode enabled
   input                                  xu_lq_spr_xucr0_cls;          // XUCR0[CLS] Mode enabled

   // Pervasive Error Report
   output                                 lq_pc_err_l2credit_overrun;

   // Pervasive


   inout                                  vdd;


   inout                                  gnd;

   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

   input [0:`NCLK_WIDTH-1]                nclk;
   input                                  sg_0;
   input                                  func_sl_thold_0_b;
   input                                  func_sl_force;
   input                                  func_slp_sl_thold_0_b;
   input                                  func_slp_sl_force;
   input                                  d_mode_dc;
   input                                  delay_lclkr_dc;
   input                                  mpw1_dc_b;
   input                                  mpw2_dc_b;

   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

   input                                  scan_in;

   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

   output                                 scan_out;

   //--------------------------
   // signals
   //--------------------------

   wire [0:2]                             lsq_dat_stq1_op_size_int;
   wire [52:63]                           ldq_dat_stq1_addr_int;
   wire [0:`THREADS-1]                    ldq_stq1_thrd_id;
   wire [64-`REAL_IFAR_WIDTH:63]          ldq_stq_stq1_addr;
   wire                                   ldq_stq_stq1_le_mode;
   wire                                   req_l2_val_d;
   wire                                   req_l2_val_q;
   wire                                   req_l2_ld_sent_d;
   wire                                   req_l2_ld_sent_q;
   wire [0:3]                             req_sel_usrDef_d;
   wire [0:3]                             req_sel_usrDef_q;
   wire [0:15]                            req_sel_byteEn_d;
   wire [0:15]                            req_sel_byteEn_q;
   wire [0:4]                             req_sel_wimge_d;
   wire [0:4]                             req_sel_wimge_q;
   wire [64-`REAL_IFAR_WIDTH:63]          req_sel_p_addr_d;
   wire [64-`REAL_IFAR_WIDTH:63]          req_sel_p_addr_q;
   wire [0:5]                             req_sel_ttype_d;
   wire [0:5]                             req_sel_ttype_q;
   wire [0:1]                             req_sel_tid_d;
   wire [0:1]                             req_sel_tid_q;
   wire [0:2]                             req_sel_opSize_d;
   wire [0:2]                             req_sel_opSize_q;
   wire [0:4]                             req_sel_cTag_d;
   wire [0:4]                             req_sel_cTag_q;
   wire [0:3]                             unit_req_sel_usrDef;
   wire [0:4]                             unit_req_sel_wimge;
   wire [64-`REAL_IFAR_WIDTH:63]          unit_req_sel_p_addr;
   wire [0:5]                             unit_req_sel_ttype;
   wire [0:1]                             unit_req_sel_tid;
   wire [0:2]                             unit_req_sel_opSize;
   wire [0:4]                             unit_req_sel_cTag;
   wire [0:3]                             unit_req_val;
   wire [0:3]                             unit_last_sel_d;
   wire [0:3]                             unit_last_sel_q;
   wire [0:3]                             queue_unit_sel;
   wire                                   req_l2_sent;
   wire                                   req_l2_ld_pwrToken;
   wire                                   req_l2_ld_val;
   wire                                   req_l2_st_val;
   wire                                   req_l2_act;
   wire                                   ld_type_credAvail;
   wire                                   st_type_credAvail;
   wire                                   st_req_noCreds;
   wire                                   st_req_2inpipe;
   wire                                   st_req_1inpipe;
   wire                                   st_req_0Creds;
   wire                                   st2_req_val;
   wire                                   st3_req_val;
   wire                                   mmq1_req_val;
   wire                                   mmq2_req_val_d;
   wire                                   mmq2_req_val_q;
   wire                                   mmq3_req_val_d;
   wire                                   mmq3_req_val_q;
   wire                                   stq4_data_override_d;
   wire                                   stq4_data_override_q;
   wire                                   stq2_req_val_d;
   wire                                   stq2_req_val_q;
   wire                                   stq3_icswx_val;
   wire [64-`REAL_IFAR_WIDTH:63]          req_l2_st_p_addr;
   wire [0:4]                             req_l2_st_wimge;
   wire [0:3]                             req_l2_st_usrDef;
   wire [0:5]                             req_l2_st_ttype;
   wire [0:1]                             req_l2_st_tid;
   wire [0:2]                             req_l2_st_opSize;
   wire                                   ld_st_noCred_flp_d;
   wire                                   ld_st_noCred_flp_q;
   wire                                   stq3_store_type_cmmt;
   wire                                   stq3_store_type_rej;
   wire                                   st_rej_hold_cred_d;
   wire                                   st_rej_hold_cred_q;
   wire                                   ld_noCred_hold_d;
   wire                                   ld_noCred_hold_q;
   wire                                   ld_noCred_release;
   wire                                   ld_pop_rcvd_d;
   wire                                   ld_pop_rcvd_q;
   wire                                   ld_cred_blk_rst;
   wire                                   ld_cred_blk_run;
   wire                                   ld_cred_blk_zero;
   wire [0:3]                             ld_cred_blk_decr;
   wire [0:3]                             ld_cred_blk_init;
   wire [0:3]                             ld_cred_blk_cnt_d;
   wire [0:3]                             ld_cred_blk_cnt_q;
   wire                                   load_req_sent;
   wire [0:4]                             load_cred_incr;
   wire [0:4]                             load_cred_decr;
   wire [0:1]                             load_cred_sel;
   wire [0:4]                             load_cred_cnt_d;
   wire [0:4]                             load_cred_cnt_q;
   wire                                   ld_cred_err_d;
   wire                                   ld_cred_err_q;
   wire                                   ld_req_0Creds;
   wire                                   ld_req_noCreds;
   wire                                   store_req_sent;
   wire [0:5]                             store_cred_incr;
   wire [0:5]                             store_cred_incr2;
   wire [0:5]                             store_cred_decr;
   wire [0:2]                             store_cred_sel;
   wire [0:5]                             store_cred_cnt_d;
   wire [0:5]                             store_cred_cnt_q;
   wire                                   st_cred_err_d;
   wire                                   st_cred_err_q;
   wire [0:26]                            stq4_req_st_data_d;
   wire [0:26]                            stq4_req_st_data_q;
   wire [0:127]                           req_l2_st_data;
   wire [0:143]                           stq2_store_data;
   wire [0:127]                           stq2_store_data_d;
   wire [0:127]                           stq2_store_data_q;
   wire [0:15]                            stq2_store_parity;
   wire [0:143]                           rel2_wrt_data;
   wire                                   spr_lsucr0_b2b_d;
   wire                                   spr_lsucr0_b2b_q;
   wire                                   spr_xucr0_cred_d;
   wire                                   spr_xucr0_cred_q;
   wire                                   spr_xucr0_cls_d;
   wire                                   spr_xucr0_cls_q;
   wire                                   st_b2b_st_dis;
   wire                                   ld_b2b_ld_dis;
   wire                                   stq1_stg_act;
   wire                                   lsq_l2credit_overrun;
   wire [0:4]                             ld_cred_max;
   wire [0:5]                             st_cred_max;

   //--------------------------
   // constants
   //--------------------------

   parameter                              req_l2_val_offset = 0;
   parameter                              req_l2_ld_sent_offset = req_l2_val_offset + 1;
   parameter                              req_sel_usrDef_offset = req_l2_ld_sent_offset + 1;
   parameter                              req_sel_byteEn_offset = req_sel_usrDef_offset + 4;
   parameter                              req_sel_wimge_offset = req_sel_byteEn_offset + 16;
   parameter                              req_sel_p_addr_offset = req_sel_wimge_offset + 5;
   parameter                              req_sel_ttype_offset = req_sel_p_addr_offset + `REAL_IFAR_WIDTH;
   parameter                              req_sel_tid_offset = req_sel_ttype_offset + 6;
   parameter                              req_sel_opSize_offset = req_sel_tid_offset + 2;
   parameter                              req_sel_cTag_offset = req_sel_opSize_offset + 3;
   parameter                              unit_last_sel_offset = req_sel_cTag_offset + 5;
   parameter                              load_cred_cnt_offset = unit_last_sel_offset + 4;
   parameter                              ld_cred_err_offset = load_cred_cnt_offset + 5;
   parameter                              ld_st_noCred_flp_offset = ld_cred_err_offset + 1;
   parameter                              st_rej_hold_cred_offset = ld_st_noCred_flp_offset + 1;
   parameter                              ld_noCred_hold_offset = st_rej_hold_cred_offset + 1;
   parameter                              ld_pop_rcvd_offset = ld_noCred_hold_offset + 1;
   parameter                              ld_cred_blk_cnt_offset = ld_pop_rcvd_offset + 1;
   parameter                              store_cred_cnt_offset = ld_cred_blk_cnt_offset + 4;
   parameter                              st_cred_err_offset = store_cred_cnt_offset + 6;
   parameter                              spr_lsucr0_b2b_offset = st_cred_err_offset + 1;
   parameter                              spr_xucr0_cred_offset = spr_lsucr0_b2b_offset + 1;
   parameter                              spr_xucr0_cls_offset = spr_xucr0_cred_offset + 1;
   parameter                              stq2_req_val_offset = spr_xucr0_cls_offset + 1;
   parameter                              mmq2_req_val_offset = stq2_req_val_offset + 1;
   parameter                              mmq3_req_val_offset = mmq2_req_val_offset + 1;
   parameter                              stq4_data_override_offset = mmq3_req_val_offset + 1;
   parameter                              stq4_req_st_data_offset = stq4_data_override_offset + 1;
   parameter                              stq2_store_data_offset = stq4_req_st_data_offset + 27;
   parameter                              scan_right = stq2_store_data_offset + 128 - 1;

   wire                                   tiup;
   wire [0:scan_right]                    siv;
   wire [0:scan_right]                    sov;

   assign tiup = 1'b1;

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // LSU Config Bits
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   // LSUCR0[B2B] Back-2-Back allowed for same type of L2 request
   // 1 => Back-2-Back allowed
   // 0 => Back-2-Back not allowed, LSI Mode
   assign spr_lsucr0_b2b_d = ctl_lsq_spr_lsucr0_b2b;

   // XUCR0[CRED] L2 Credit Control
   // 1 => Can only send one load or store when there is 1 store credit and 1 load credit
   // 0 => No restrictions when there is 1 store credit and 1 load credit
   assign spr_xucr0_cred_d = xu_lq_spr_xucr0_cred;

   // XUCR0[CLS] 128 Byte Cacheline Enabled
   // 1 => 128 Byte Cacheline
   // 0 => 64 Byte Cacheline
   assign spr_xucr0_cls_d = xu_lq_spr_xucr0_cls;

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // Select Between LDQ and STQ Common
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // Reloads have higher priority than Commit Pipe

   assign lsq_ctl_stq1_axu_val = (ldq_arb_rel1_blk_store == 1'b1) ? ldq_arb_rel1_axu_val :
                                                                    stq_arb_stq1_axu_val;

   assign lsq_ctl_stq1_epid_val = stq_arb_stq1_epid_val & (~ldq_arb_rel1_blk_store);

   assign lsq_dat_stq1_op_size_int = (ldq_arb_rel1_blk_store == 1'b1) ? ldq_arb_rel1_op_size :
                                                                        stq_arb_stq1_opSize;

   assign ldq_stq_stq1_addr = (ldq_arb_rel1_blk_store == 1'b1) ? ldq_arb_rel1_addr :
                                                                 stq_arb_stq1_p_addr;

   assign lsq_ctl_stq1_ci = (ldq_arb_rel1_blk_store == 1'b1) ? ldq_arb_rel1_ci :
                                                               stq_arb_stq1_wimge_i;

   assign ldq_stq_stq1_le_mode = (ldq_arb_rel1_blk_store == 1'b1) ? ldq_arb_rel1_byte_swap :
                                                                    stq_arb_stq1_byte_swap;

   assign ldq_stq1_thrd_id = (ldq_arb_rel1_blk_store == 1'b1) ? ldq_arb_rel1_thrd_id :
                                                                stq_arb_stq1_thrd_id;

   assign ldq_dat_stq1_addr_int = ldq_stq_stq1_addr[52:63];

   assign lsq_dat_stq1_op_size = lsq_dat_stq1_op_size_int;
   assign lsq_dat_stq1_addr    = ldq_dat_stq1_addr_int[52:63];
   assign lsq_ctl_stq1_thrd_id = ldq_stq1_thrd_id;
   assign lsq_ctl_stq1_addr    = ldq_stq_stq1_addr[64 - `REAL_IFAR_WIDTH:63 - `CL_SIZE];
   assign lsq_dat_stq1_le_mode = ldq_stq_stq1_le_mode;
   assign stq1_stg_act         = ldq_arb_rel1_stg_act | stq_arb_stq1_stg_act;

   assign lsq_ctl_stq_release_itag_vld = stq_arb_release_itag_vld;
   assign lsq_ctl_stq_release_itag     = stq_arb_release_itag;
   assign lsq_ctl_stq_release_tid      = stq_arb_release_tid;

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // Store Data Muxing
   // Data that needs to be rotated or written to the cache
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   generate
      if (`STQ_DATA_SIZE == 128) begin : stqDat128
         // Select between L2 reload Data and Store Data
         assign stq2_store_data_d = (ldq_arb_rel1_data_sel == 1'b1) ? ldq_arb_rel1_data :
                                                                      stq_arb_stq1_store_data;
      end
   endgenerate

   generate
      if (`STQ_DATA_SIZE == 64) begin : stqDat64
         assign stq2_store_data_d[0:63] = ldq_arb_rel1_data[0:63];

         // Select between L2 reload Data and Store Data
         assign stq2_store_data_d[64:127] = (ldq_arb_rel1_data_sel == 1'b1) ? ldq_arb_rel1_data[64:127] :
                                                                              stq_arb_stq1_store_data[64:127];
      end
   endgenerate

   generate begin : parGen
         genvar t;
         for (t = 0; t <= 15; t = t + 1) begin : parGen
            assign stq2_store_parity[t] = ^(stq2_store_data_q[t * 8:(t * 8) + 7]);
         end
      end
   endgenerate

   assign rel2_wrt_data = {stq2_store_data_q, stq2_store_parity};

   // Select betweeen L2/Store and Reload Queue Data
   assign stq2_store_data = (ldq_arb_rel2_rdat_sel == 1'b1) ? ldq_arb_rel2_rd_data :
                                                              rel2_wrt_data;

   assign lsq_dat_stq2_store_data = stq2_store_data;
   assign arb_ldq_rel2_wrt_data  = rel2_wrt_data;

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // L2 Credit Control
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   // Need to flip the no credit available to ldq and stq when running in XUCR0[CRED] mode and there are no load credits or store credits
   // Cant send both load and store requests out, need to pick one, so will ping pong between load and store
   // Want to hold flp to point to load if the store was rejected and didnt commit to the L1/L2
   // 1 => Load Queue has no Credit
   // 0 => Store Queue has no Credit
   assign ld_st_noCred_flp_d   = spr_xucr0_cred_q & (~ld_st_noCred_flp_q | ld_noCred_hold_q);
   assign stq3_store_type_cmmt = stq_arb_stq3_cmmt_val | mmq3_req_val_q;
   assign stq3_store_type_rej  = stq_arb_stq3_cmmt_reject & ~mmq3_req_val_q;
   assign st_rej_hold_cred_d   = spr_xucr0_cred_q & (stq3_store_type_rej | (st_rej_hold_cred_q & ~stq_arb_stq3_cmmt_val));
   assign ld_noCred_hold_d     = spr_xucr0_cred_q & (load_req_sent | (ld_noCred_hold_q & ~ld_noCred_release));
   assign ld_noCred_release    = ld_pop_rcvd_q & ~|(ld_cred_blk_cnt_q) & ~st_rej_hold_cred_q;
   assign ld_pop_rcvd_d        = l2_lsq_req_ld_pop | (ld_pop_rcvd_q & ~load_req_sent);

   assign ld_cred_blk_rst      = spr_xucr0_cred_q & l2_lsq_req_ld_pop;
   assign ld_cred_blk_run      = |(ld_cred_blk_cnt_q);
   assign ld_cred_blk_zero     = stq3_store_type_cmmt | stq3_store_type_rej;
   assign ld_cred_blk_decr     = ld_cred_blk_cnt_q - 4'b0001;
   assign ld_cred_blk_init     = {1'b1, spr_xucr0_cls_q, 2'b00};
   assign ld_cred_blk_cnt_d    = ld_cred_blk_rst  ? ld_cred_blk_init :
                                 ld_cred_blk_zero ? 4'b0000 :
                                 ld_cred_blk_run  ? ld_cred_blk_decr :
                                 ld_cred_blk_cnt_q;

   // Load Credit Control
   assign load_req_sent  = |(unit_req_val);
   assign load_cred_incr = load_cred_cnt_q + 5'b00001;
   assign load_cred_decr = load_cred_cnt_q - 5'b00001;
   assign load_cred_sel  = {l2_lsq_req_ld_pop, load_req_sent};

   assign load_cred_cnt_d = (load_cred_sel == 2'b10) ? load_cred_incr :
                            (load_cred_sel == 2'b01) ? load_cred_decr :
                                                       load_cred_cnt_q;

   assign ld_req_0Creds     = (load_cred_cnt_q == 5'b00000);
   assign ld_req_noCreds    = ld_req_0Creds | (spr_xucr0_cred_q & (st_req_0Creds | st_req_1inpipe | st_req_2inpipe | ld_st_noCred_flp_q));
   assign ld_type_credAvail = ~(ld_req_noCreds | ld_b2b_ld_dis);
   assign ld_cred_max       = 5'd`LOAD_CREDITS;
   assign ld_cred_err_d     = (load_cred_cnt_q > ld_cred_max);
   assign ld_b2b_ld_dis     = req_l2_ld_sent_q & (~spr_lsucr0_b2b_q);

   // Store Credit Control
   assign store_req_sent   = stq_arb_stq3_req_val | mmq3_req_val_q;
   assign store_cred_incr  = store_cred_cnt_q + 6'b00001;
   assign store_cred_incr2 = store_cred_cnt_q + 6'b00010;
   assign store_cred_decr  = store_cred_cnt_q - 6'b00001;
   assign store_cred_sel   = {l2_lsq_req_st_pop, l2_lsq_req_st_gather, store_req_sent};

   //000 store_cred_cnt_q
   //001 store_cred_decr
   //010 store_cred_incr
   //011 store_cred_cnt_q
   //100 store_cred_incr
   //101 store_cred_cnt_q
   //110 store_cred_incr2
   //111 store_cred_incr

   assign store_cred_cnt_d = (store_cred_sel == 3'b001) ? store_cred_decr :
                             (store_cred_sel == 3'b110) ? store_cred_incr2 :
                             (store_cred_sel == 3'b000) ? store_cred_cnt_q :
                             (store_cred_sel == 3'b011) ? store_cred_cnt_q :
                             (store_cred_sel == 3'b101) ? store_cred_cnt_q :
                                                          store_cred_incr;

   assign st_cred_max       = 6'd`STORE_CREDITS;
   assign st_cred_err_d     = (store_cred_cnt_q > st_cred_max);
   assign st_req_2inpipe    = (store_cred_cnt_q == 6'b000010) & st2_req_val & st3_req_val;
   assign st_req_1inpipe    = (store_cred_cnt_q == 6'b000001) & (st2_req_val ^ st3_req_val);
   assign st_req_0Creds     = (store_cred_cnt_q == 6'b000000);
   assign st_req_noCreds    = st_req_0Creds | st_req_1inpipe | st_req_2inpipe | (spr_xucr0_cred_q & (ld_req_0Creds | ~ld_st_noCred_flp_q));
   assign st_type_credAvail = ~(st_req_noCreds | st_b2b_st_dis);
   assign st2_req_val       = mmq2_req_val_q | stq2_req_val_q;
   assign st3_req_val       = (mmq3_req_val_q | stq_arb_stq3_req_val);
   assign stq2_req_val_d    = stq_arb_st_req_avail & (~mmq1_req_val);
   assign stq3_icswx_val    = (stq_arb_stq3_ttype[0:4] == 5'b10011);
   assign st_b2b_st_dis     = st2_req_val & (~spr_lsucr0_b2b_q);

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // L2 Request Arbiter
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   // Need to block off request when store request is about to be sent to L2
   assign unit_req_val[0] = ldq_arb_ld_req_avail & ld_type_credAvail & (~req_l2_st_val);
   assign unit_req_val[1] = imq_arb_iuq_ld_req_avail & ld_type_credAvail & (~req_l2_st_val);
   assign unit_req_val[2] = imq_arb_mmq_ld_req_avail & ld_type_credAvail & (~req_l2_st_val);
   assign unit_req_val[3] = 1'b0;

   assign queue_unit_sel[0] = (unit_last_sel_q[0] & (~(|(unit_req_val[1:3]))) & unit_req_val[0]) |
                              (unit_last_sel_q[1] & (~(|(unit_req_val[2:3]))) & unit_req_val[0]) |
                              (unit_last_sel_q[2] & (~unit_req_val[3])        & unit_req_val[0]) |
                              (unit_last_sel_q[3] & unit_req_val[0]);

   assign queue_unit_sel[1] = (unit_last_sel_q[0]                                                  & unit_req_val[1]) |
                              (unit_last_sel_q[1] & (~(|(({unit_req_val[0], unit_req_val[2:3]})))) & unit_req_val[1]) |
                              (unit_last_sel_q[2] & (~(|(({unit_req_val[0], unit_req_val[3]}))))   & unit_req_val[1]) |
                              (unit_last_sel_q[3] & (~unit_req_val[0])                             & unit_req_val[1]);

   assign queue_unit_sel[2] = (unit_last_sel_q[0] & (~unit_req_val[1])                             & unit_req_val[2]) |
                              (unit_last_sel_q[1]                                                  & unit_req_val[2]) |
                              (unit_last_sel_q[2] & (~(|(({unit_req_val[0:1], unit_req_val[3]})))) & unit_req_val[2]) |
                              (unit_last_sel_q[3] & (~(|(unit_req_val[0:1])))                      & unit_req_val[2]);

   assign queue_unit_sel[3] = (unit_last_sel_q[0] & (~(|(unit_req_val[1:2]))) & unit_req_val[3]) |
                              (unit_last_sel_q[1] & (~unit_req_val[2])        & unit_req_val[3]) |
                              (unit_last_sel_q[2]                             & unit_req_val[3]) |
                              (unit_last_sel_q[3] & (~(|(unit_req_val[0:2]))) & unit_req_val[3]);

   assign unit_last_sel_d = (req_l2_sent == 1'b1) ? queue_unit_sel :
                                                    unit_last_sel_q;

   // Unit Select
   assign unit_req_sel_usrDef = (ldq_arb_usr_def     & {4{queue_unit_sel[0]}}) |
                                (imq_arb_iuq_usr_def & {4{queue_unit_sel[1]}}) |
                                (imq_arb_mmq_usr_def & {4{queue_unit_sel[2]}});

   assign unit_req_sel_wimge = (ldq_arb_wimge     & {5{queue_unit_sel[0]}}) |
                               (imq_arb_iuq_wimge & {5{queue_unit_sel[1]}}) |
                               (imq_arb_mmq_wimge & {5{queue_unit_sel[2]}});

   assign unit_req_sel_p_addr = (ldq_arb_p_addr     & {`REAL_IFAR_WIDTH{queue_unit_sel[0]}}) |
                                (imq_arb_iuq_p_addr & {`REAL_IFAR_WIDTH{queue_unit_sel[1]}}) |
                                (imq_arb_mmq_p_addr & {`REAL_IFAR_WIDTH{queue_unit_sel[2]}});

   assign unit_req_sel_ttype = (ldq_arb_ttype     & {6{queue_unit_sel[0]}}) |
                               (imq_arb_iuq_ttype & {6{queue_unit_sel[1]}}) |
                               (imq_arb_mmq_ttype & {6{queue_unit_sel[2]}});

   assign unit_req_sel_tid = (ldq_arb_tid     & {2{queue_unit_sel[0]}}) |
                             (imq_arb_iuq_tid & {2{queue_unit_sel[1]}}) |
                             (imq_arb_mmq_tid & {2{queue_unit_sel[2]}});

   assign unit_req_sel_opSize = (ldq_arb_opSize     & {3{queue_unit_sel[0]}}) |
                                (imq_arb_iuq_opSize & {3{queue_unit_sel[1]}}) |
                                (imq_arb_mmq_opSize & {3{queue_unit_sel[2]}});

   assign unit_req_sel_cTag = (ldq_arb_cTag     & {5{queue_unit_sel[0]}}) |
                              (imq_arb_iuq_cTag & {5{queue_unit_sel[1]}}) |
                              (imq_arb_mmq_cTag & {5{queue_unit_sel[2]}});

   assign req_l2_sent = |(queue_unit_sel);
   assign req_l2_ld_pwrToken = (ldq_arb_ld_req_pwrToken | imq_arb_iuq_ld_req_avail | imq_arb_mmq_ld_req_avail) & ld_type_credAvail;
   assign req_l2_ld_val = (ldq_arb_ld_req_avail | imq_arb_iuq_ld_req_avail | imq_arb_mmq_ld_req_avail) & ld_type_credAvail;
   assign req_l2_ld_sent_d = req_l2_ld_val;
   assign req_l2_st_val = (stq_arb_stq3_req_val | mmq3_req_val_q);
   assign req_l2_val_d = req_l2_ld_val | stq_arb_stq3_req_val | mmq3_req_val_q;
   assign req_l2_act = ldq_arb_ld_req_pwrToken | imq_arb_iuq_ld_req_avail | imq_arb_mmq_ld_req_avail | stq_arb_stq3_req_val | mmq3_req_val_q;
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // MMQ Store Type Request Delay
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   assign mmq1_req_val         = imq_arb_mmq_st_req_avail & st_type_credAvail & (~(mmq2_req_val_q | mmq3_req_val_q));
   assign mmq2_req_val_d       = mmq1_req_val;
   assign mmq3_req_val_d       = mmq2_req_val_q;
   assign stq4_data_override_d = mmq3_req_val_q | stq3_icswx_val;

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // Mux Between Store and other requests
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   assign req_l2_st_p_addr = (mmq3_req_val_q == 1'b0) ? stq_arb_stq3_p_addr :
                                                        imq_arb_mmq_p_addr;

   assign req_l2_st_wimge = (mmq3_req_val_q == 1'b0) ? stq_arb_stq3_wimge :
                                                       imq_arb_mmq_wimge;

   assign req_l2_st_usrDef = (mmq3_req_val_q == 1'b0) ? stq_arb_stq3_usrDef :
                                                        imq_arb_mmq_usr_def;

   assign req_sel_byteEn_d = stq_arb_stq3_byteEn & {16{(~mmq3_req_val_q)}};

   assign req_l2_st_ttype = (mmq3_req_val_q == 1'b0) ? stq_arb_stq3_ttype :
                                                       imq_arb_mmq_ttype;

   assign req_l2_st_tid = (mmq3_req_val_q == 1'b0) ? stq_arb_stq3_tid :
                                                     imq_arb_mmq_tid;

   assign req_l2_st_opSize = stq_arb_stq3_opSize & {3{(~mmq3_req_val_q)}};

   assign req_sel_p_addr_d = (req_l2_st_val == 1'b1) ? req_l2_st_p_addr :
                                                       unit_req_sel_p_addr;

   assign req_sel_wimge_d = (req_l2_st_val == 1'b1) ? req_l2_st_wimge :
                                                      unit_req_sel_wimge;

   assign req_sel_usrDef_d = (req_l2_st_val == 1'b1) ? req_l2_st_usrDef :
                                                       unit_req_sel_usrDef;

   assign req_sel_ttype_d = (req_l2_st_val == 1'b1) ? req_l2_st_ttype :
                                                      unit_req_sel_ttype;

   assign req_sel_tid_d = (req_l2_st_val == 1'b1) ? req_l2_st_tid :
                                                    unit_req_sel_tid;

   assign req_sel_opSize_d = (req_l2_st_val == 1'b1) ? req_l2_st_opSize :
                                                       unit_req_sel_opSize;

   assign req_sel_cTag_d = (req_l2_st_val == 1'b1) ? stq_arb_stq3_cTag :
                                                     unit_req_sel_cTag;

   // Select between icswx and mmu request
   // ICSWX Store Data Format
   // (0:2)        => ~GS,PR,DS
   // (3:9)        => "0000000"
   // (10:31)      => RS(10:31)
   // (32:39)      => LPID
   // (40:41)      => "00"
   // (42:55)      => PID
   // TLBIVAX Store Data Format
   // (0:31)       => unusedBits
   // (32:39)      => LPAR_ID
   // (40:44)      => Reserved
   // (45:47)      => IND,GS,L
   // (48:55)      => unusedBits
   assign stq4_req_st_data_d[3:18] = (mmq3_req_val_q == 1'b1) ? imq_arb_mmq_st_data[0:15] :
                                                                ctl_lsq_stq3_icswx_data[3:18];

   assign stq4_req_st_data_d[0:2]   = ctl_lsq_stq3_icswx_data[0:2];
   assign stq4_req_st_data_d[19:26] = ctl_lsq_stq3_icswx_data[19:26];

   assign req_l2_st_data[32:55] = (stq4_data_override_q == 1'b0) ? dat_lsq_stq4_128data[32:55] :
                                                                   stq4_req_st_data_q[3:26];

   assign req_l2_st_data[0:2] = (stq4_data_override_q == 1'b0) ? dat_lsq_stq4_128data[0:2] :
                                                                 stq4_req_st_data_q[0:2];

   assign req_l2_st_data[3:9]    = dat_lsq_stq4_128data[3:9] & {7{(~stq4_data_override_q)}};
   assign req_l2_st_data[10:31]  = dat_lsq_stq4_128data[10:31];
   assign req_l2_st_data[56:127] = dat_lsq_stq4_128data[56:127];

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // Outputs
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   assign lsq_l2credit_overrun = ld_cred_err_q | st_cred_err_q;

   tri_direct_err_rpt #(.WIDTH(1)) err_rpt(
      .vd(vdd),
      .gd(gnd),
      .err_in(lsq_l2credit_overrun),
      .err_out(lq_pc_err_l2credit_overrun)
   );

   // Credits Available
   assign arb_stq_cred_avail = st_type_credAvail & (~imq_arb_mmq_st_req_avail);

   // Unit Selected to Send request to L2
   assign arb_ldq_ldq_unit_sel = queue_unit_sel[0];
   assign arb_imq_iuq_unit_sel = queue_unit_sel[1];
   assign arb_imq_mmq_unit_sel = queue_unit_sel[2] | mmq3_req_val_q;

   // L2 Request
   assign lsq_l2_pwrToken  = req_l2_ld_pwrToken | stq_arb_stq3_req_val | mmq3_req_val_q;
   assign lsq_l2_valid     = req_l2_val_q;
   assign lsq_l2_tid       = req_sel_tid_q;
   assign lsq_l2_p_addr    = req_sel_p_addr_q;
   assign lsq_l2_wimge     = req_sel_wimge_q;
   assign lsq_l2_usrDef    = req_sel_usrDef_q;
   assign lsq_l2_byteEn    = req_sel_byteEn_q;
   assign lsq_l2_ttype     = req_sel_ttype_q;
   assign lsq_l2_opSize    = req_sel_opSize_q;
   assign lsq_l2_coreTag   = req_sel_cTag_q;
   assign lsq_l2_dataToken = stq_arb_stq3_req_val | mmq3_req_val_q;
   assign lsq_l2_st_data   = req_l2_st_data;

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // REGISTERS
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) req_l2_val_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[req_l2_val_offset]),
      .scout(sov[req_l2_val_offset]),
      .din(req_l2_val_d),
      .dout(req_l2_val_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) req_l2_ld_sent_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[req_l2_ld_sent_offset]),
      .scout(sov[req_l2_ld_sent_offset]),
      .din(req_l2_ld_sent_d),
      .dout(req_l2_ld_sent_q)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) req_sel_usrDef_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(req_l2_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[req_sel_usrDef_offset:req_sel_usrDef_offset + 4 - 1]),
      .scout(sov[req_sel_usrDef_offset:req_sel_usrDef_offset + 4 - 1]),
      .din(req_sel_usrDef_d),
      .dout(req_sel_usrDef_q)
   );


   tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) req_sel_byteEn_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(req_l2_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[req_sel_byteEn_offset:req_sel_byteEn_offset + 16 - 1]),
      .scout(sov[req_sel_byteEn_offset:req_sel_byteEn_offset + 16 - 1]),
      .din(req_sel_byteEn_d),
      .dout(req_sel_byteEn_q)
   );


   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) req_sel_wimge_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(req_l2_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[req_sel_wimge_offset:req_sel_wimge_offset + 5 - 1]),
      .scout(sov[req_sel_wimge_offset:req_sel_wimge_offset + 5 - 1]),
      .din(req_sel_wimge_d),
      .dout(req_sel_wimge_q)
   );


   tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) req_sel_p_addr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(req_l2_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[req_sel_p_addr_offset:req_sel_p_addr_offset + `REAL_IFAR_WIDTH - 1]),
      .scout(sov[req_sel_p_addr_offset:req_sel_p_addr_offset + `REAL_IFAR_WIDTH - 1]),
      .din(req_sel_p_addr_d),
      .dout(req_sel_p_addr_q)
   );


   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) req_sel_ttype_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(req_l2_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[req_sel_ttype_offset:req_sel_ttype_offset + 6 - 1]),
      .scout(sov[req_sel_ttype_offset:req_sel_ttype_offset + 6 - 1]),
      .din(req_sel_ttype_d),
      .dout(req_sel_ttype_q)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) req_sel_tid_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(req_l2_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[req_sel_tid_offset:req_sel_tid_offset + 2 - 1]),
      .scout(sov[req_sel_tid_offset:req_sel_tid_offset + 2 - 1]),
      .din(req_sel_tid_d),
      .dout(req_sel_tid_q)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) req_sel_opSize_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(req_l2_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[req_sel_opSize_offset:req_sel_opSize_offset + 3 - 1]),
      .scout(sov[req_sel_opSize_offset:req_sel_opSize_offset + 3 - 1]),
      .din(req_sel_opSize_d),
      .dout(req_sel_opSize_q)
   );


   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) req_sel_cTag_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(req_l2_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[req_sel_cTag_offset:req_sel_cTag_offset + 5 - 1]),
      .scout(sov[req_sel_cTag_offset:req_sel_cTag_offset + 5 - 1]),
      .din(req_sel_cTag_d),
      .dout(req_sel_cTag_q)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(1), .NEEDS_SRESET(1)) unit_last_sel_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[unit_last_sel_offset:unit_last_sel_offset + 4 - 1]),
      .scout(sov[unit_last_sel_offset:unit_last_sel_offset + 4 - 1]),
      .din(unit_last_sel_d),
      .dout(unit_last_sel_q)
   );


   tri_rlmreg_p #(.WIDTH(5), .INIT(`LOAD_CREDITS), .NEEDS_SRESET(1)) load_cred_cnt_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[load_cred_cnt_offset:load_cred_cnt_offset + 5 - 1]),
      .scout(sov[load_cred_cnt_offset:load_cred_cnt_offset + 5 - 1]),
      .din(load_cred_cnt_d),
      .dout(load_cred_cnt_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ld_cred_err_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ld_cred_err_offset]),
      .scout(sov[ld_cred_err_offset]),
      .din(ld_cred_err_d),
      .dout(ld_cred_err_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ld_st_noCred_flp_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ld_st_noCred_flp_offset]),
      .scout(sov[ld_st_noCred_flp_offset]),
      .din(ld_st_noCred_flp_d),
      .dout(ld_st_noCred_flp_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) st_rej_hold_cred_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[st_rej_hold_cred_offset]),
      .scout(sov[st_rej_hold_cred_offset]),
      .din(st_rej_hold_cred_d),
      .dout(st_rej_hold_cred_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ld_noCred_hold_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ld_noCred_hold_offset]),
      .scout(sov[ld_noCred_hold_offset]),
      .din(ld_noCred_hold_d),
      .dout(ld_noCred_hold_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ld_pop_rcvd_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ld_pop_rcvd_offset]),
      .scout(sov[ld_pop_rcvd_offset]),
      .din(ld_pop_rcvd_d),
      .dout(ld_pop_rcvd_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ld_cred_blk_cnt_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ld_cred_blk_cnt_offset:ld_cred_blk_cnt_offset + 4 - 1]),
      .scout(sov[ld_cred_blk_cnt_offset:ld_cred_blk_cnt_offset + 4 - 1]),
      .din(ld_cred_blk_cnt_d),
      .dout(ld_cred_blk_cnt_q)
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(`STORE_CREDITS), .NEEDS_SRESET(1)) store_cred_cnt_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[store_cred_cnt_offset:store_cred_cnt_offset + 6 - 1]),
      .scout(sov[store_cred_cnt_offset:store_cred_cnt_offset + 6 - 1]),
      .din(store_cred_cnt_d),
      .dout(store_cred_cnt_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) st_cred_err_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[st_cred_err_offset]),
      .scout(sov[st_cred_err_offset]),
      .din(st_cred_err_d),
      .dout(st_cred_err_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_lsucr0_b2b_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[spr_lsucr0_b2b_offset]),
      .scout(sov[spr_lsucr0_b2b_offset]),
      .din(spr_lsucr0_b2b_d),
      .dout(spr_lsucr0_b2b_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_cred_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[spr_xucr0_cred_offset]),
      .scout(sov[spr_xucr0_cred_offset]),
      .din(spr_xucr0_cred_d),
      .dout(spr_xucr0_cred_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_cls_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[spr_xucr0_cls_offset]),
      .scout(sov[spr_xucr0_cls_offset]),
      .din(spr_xucr0_cls_d),
      .dout(spr_xucr0_cls_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_req_val_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[stq2_req_val_offset]),
      .scout(sov[stq2_req_val_offset]),
      .din(stq2_req_val_d),
      .dout(stq2_req_val_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mmq2_req_val_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mmq2_req_val_offset]),
      .scout(sov[mmq2_req_val_offset]),
      .din(mmq2_req_val_d),
      .dout(mmq2_req_val_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mmq3_req_val_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mmq3_req_val_offset]),
      .scout(sov[mmq3_req_val_offset]),
      .din(mmq3_req_val_d),
      .dout(mmq3_req_val_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_data_override_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[stq4_data_override_offset]),
      .scout(sov[stq4_data_override_offset]),
      .din(stq4_data_override_d),
      .dout(stq4_data_override_q)
   );


   tri_rlmreg_p #(.WIDTH(27), .INIT(0), .NEEDS_SRESET(1)) stq4_req_st_data_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(req_l2_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[stq4_req_st_data_offset:stq4_req_st_data_offset + 27 - 1]),
      .scout(sov[stq4_req_st_data_offset:stq4_req_st_data_offset + 27 - 1]),
      .din(stq4_req_st_data_d),
      .dout(stq4_req_st_data_q)
   );


   tri_rlmreg_p #(.WIDTH(128), .INIT(0), .NEEDS_SRESET(1)) stq2_store_data_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stq1_stg_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[stq2_store_data_offset:stq2_store_data_offset + 128 - 1]),
      .scout(sov[stq2_store_data_offset:stq2_store_data_offset + 128 - 1]),
      .din(stq2_store_data_d),
      .dout(stq2_store_data_q)
   );

   assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
   assign scan_out = sov[0];

endmodule
