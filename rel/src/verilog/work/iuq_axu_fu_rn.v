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

//* *******************************************************************
//*
//* TITLE:
//*
//* NAME: iuq_axu_fu_rn.vhdl
//*
//*********************************************************************

(* block_type="leaf" *)
(* recursive_synthesis="2" *)

`include "tri_a2o.vh"

module iuq_axu_fu_rn #(
	parameter                    FPR_POOL = 64,
	parameter                    FPR_UCODE_POOL = 4,
	parameter                    FPSCR_POOL_ENC = 5)
   (
   inout                        vdd,
   inout                        gnd,
   input [0:`NCLK_WIDTH-1]      nclk,
   input                        pc_iu_func_sl_thold_2,		// acts as reset for non-ibm types
   input                        pc_iu_sg_2,
   input                        clkoff_b,
   input                        act_dis,
   input                        tc_ac_ccflush_dc,
   input                        d_mode,
   input                        delay_lclkr,
   input                        mpw1_b,
   input                        mpw2_b,
   input                        func_scan_in,
   output                       func_scan_out,

   //-----------------------------
   // Inputs to rename from decode
   //-----------------------------
   input                        iu_au_iu5_i0_vld,
   input [0:2]                  iu_au_iu5_i0_ucode,
   input                        iu_au_iu5_i0_rte_lq,
   input                        iu_au_iu5_i0_rte_sq,
   input                        iu_au_iu5_i0_rte_fx0,
   input                        iu_au_iu5_i0_rte_fx1,
   input                        iu_au_iu5_i0_rte_axu0,
   input                        iu_au_iu5_i0_rte_axu1,
   input                        iu_au_iu5_i0_ord,
   input                        iu_au_iu5_i0_cord,
   input [0:31]                 iu_au_iu5_i0_instr,
   input [62-`EFF_IFAR_WIDTH:61] iu_au_iu5_i0_ifar,
   input [0:9]                  iu_au_iu5_i0_gshare,
   input [0:3]                  iu_au_iu5_i0_ilat,
   input                        iu_au_iu5_i0_isload,
   input                        iu_au_iu5_i0_t1_v,
   input [0:2]                  iu_au_iu5_i0_t1_t,
   input [0:`GPR_POOL_ENC-1]     iu_au_iu5_i0_t1_a,
   input                        iu_au_iu5_i0_t2_v,
   input [0:2]                  iu_au_iu5_i0_t2_t,
   input [0:`GPR_POOL_ENC-1]     iu_au_iu5_i0_t2_a,
   input                        iu_au_iu5_i0_t3_v,
   input [0:2]                  iu_au_iu5_i0_t3_t,
   input [0:`GPR_POOL_ENC-1]     iu_au_iu5_i0_t3_a,
   input                        iu_au_iu5_i0_s1_v,
   input [0:2]                  iu_au_iu5_i0_s1_t,
   input [0:`GPR_POOL_ENC-1]     iu_au_iu5_i0_s1_a,
   input                        iu_au_iu5_i0_s2_v,
   input [0:2]                  iu_au_iu5_i0_s2_t,
   input [0:`GPR_POOL_ENC-1]     iu_au_iu5_i0_s2_a,
   input                        iu_au_iu5_i0_s3_v,
   input [0:2]                  iu_au_iu5_i0_s3_t,
   input [0:`GPR_POOL_ENC-1]     iu_au_iu5_i0_s3_a,

   input                        iu_au_iu5_i1_vld,
   input [0:2]                  iu_au_iu5_i1_ucode,
   input                        iu_au_iu5_i1_rte_lq,
   input                        iu_au_iu5_i1_rte_sq,
   input                        iu_au_iu5_i1_rte_fx0,
   input                        iu_au_iu5_i1_rte_fx1,
   input                        iu_au_iu5_i1_rte_axu0,
   input                        iu_au_iu5_i1_rte_axu1,
   input                        iu_au_iu5_i1_ord,
   input                        iu_au_iu5_i1_cord,
   input [0:31]                 iu_au_iu5_i1_instr,
   input [62-`EFF_IFAR_WIDTH:61] iu_au_iu5_i1_ifar,
   input [0:9]                  iu_au_iu5_i1_gshare,
   input [0:3]                  iu_au_iu5_i1_ilat,
   input                        iu_au_iu5_i1_isload,
   input                        iu_au_iu5_i1_t1_v,
   input [0:2]                  iu_au_iu5_i1_t1_t,
   input [0:`GPR_POOL_ENC-1]     iu_au_iu5_i1_t1_a,
   input                        iu_au_iu5_i1_t2_v,
   input [0:2]                  iu_au_iu5_i1_t2_t,
   input [0:`GPR_POOL_ENC-1]     iu_au_iu5_i1_t2_a,
   input                        iu_au_iu5_i1_t3_v,
   input [0:2]                  iu_au_iu5_i1_t3_t,
   input [0:`GPR_POOL_ENC-1]     iu_au_iu5_i1_t3_a,
   input                        iu_au_iu5_i1_s1_v,
   input [0:2]                  iu_au_iu5_i1_s1_t,
   input [0:`GPR_POOL_ENC-1]     iu_au_iu5_i1_s1_a,
   input                        iu_au_iu5_i1_s2_v,
   input [0:2]                  iu_au_iu5_i1_s2_t,
   input [0:`GPR_POOL_ENC-1]     iu_au_iu5_i1_s2_a,
   input                        iu_au_iu5_i1_s3_v,
   input [0:2]                  iu_au_iu5_i1_s3_t,
   input [0:`GPR_POOL_ENC-1]     iu_au_iu5_i1_s3_a,

   //-----------------------------
   // SPR values
   //-----------------------------
   input                        spr_single_issue,

   //-----------------------------
   // Stall to decode
   //-----------------------------
   output                       au_iu_iu5_stall,

   //----------------------------
   // Completion Interface
   //----------------------------
   input                        cp_rn_i0_axu_exception_val,
   input [0:3]                  cp_rn_i0_axu_exception,
   input [0:`ITAG_SIZE_ENC-1]    cp_rn_i0_itag,
   input                        cp_rn_i0_t1_v,
   input [0:2]                  cp_rn_i0_t1_t,
   input [0:`GPR_POOL_ENC-1]     cp_rn_i0_t1_p,
   input [0:`GPR_POOL_ENC-1]     cp_rn_i0_t1_a,
   input                        cp_rn_i0_t2_v,
   input [0:2]                  cp_rn_i0_t2_t,
   input [0:`GPR_POOL_ENC-1]     cp_rn_i0_t2_p,
   input [0:`GPR_POOL_ENC-1]     cp_rn_i0_t2_a,
   input                        cp_rn_i0_t3_v,
   input [0:2]                  cp_rn_i0_t3_t,
   input [0:`GPR_POOL_ENC-1]     cp_rn_i0_t3_p,
   input [0:`GPR_POOL_ENC-1]     cp_rn_i0_t3_a,

   input                        cp_rn_i1_axu_exception_val,
   input [0:3]                  cp_rn_i1_axu_exception,
   input [0:`ITAG_SIZE_ENC-1]    cp_rn_i1_itag,
   input                        cp_rn_i1_t1_v,
   input [0:2]                  cp_rn_i1_t1_t,
   input [0:`GPR_POOL_ENC-1]     cp_rn_i1_t1_p,
   input [0:`GPR_POOL_ENC-1]     cp_rn_i1_t1_a,
   input                        cp_rn_i1_t2_v,
   input [0:2]                  cp_rn_i1_t2_t,
   input [0:`GPR_POOL_ENC-1]     cp_rn_i1_t2_p,
   input [0:`GPR_POOL_ENC-1]     cp_rn_i1_t2_a,
   input                        cp_rn_i1_t3_v,
   input [0:2]                  cp_rn_i1_t3_t,
   input [0:`GPR_POOL_ENC-1]     cp_rn_i1_t3_p,
   input [0:`GPR_POOL_ENC-1]     cp_rn_i1_t3_a,

   input                        cp_flush,
   input                        br_iu_redirect,

   //----------------------------------------------------------------
   // Interface to Rename
   //----------------------------------------------------------------
   input                        iu_au_iu5_send_ok,
   input [0:`ITAG_SIZE_ENC-1]    iu_au_iu5_next_itag_i0,
   input [0:`ITAG_SIZE_ENC-1]    iu_au_iu5_next_itag_i1,
   output                       au_iu_iu5_axu0_send_ok,
   output                       au_iu_iu5_axu1_send_ok,

   output [0:`GPR_POOL_ENC-1]    au_iu_iu5_i0_t1_p,
   output [0:`GPR_POOL_ENC-1]    au_iu_iu5_i0_t2_p,
   output [0:`GPR_POOL_ENC-1]    au_iu_iu5_i0_t3_p,
   output [0:`GPR_POOL_ENC-1]    au_iu_iu5_i0_s1_p,
   output [0:`GPR_POOL_ENC-1]    au_iu_iu5_i0_s2_p,
   output [0:`GPR_POOL_ENC-1]    au_iu_iu5_i0_s3_p,

   output [0:`ITAG_SIZE_ENC-1]   au_iu_iu5_i0_s1_itag,
   output [0:`ITAG_SIZE_ENC-1]   au_iu_iu5_i0_s2_itag,
   output [0:`ITAG_SIZE_ENC-1]   au_iu_iu5_i0_s3_itag,

   output [0:`GPR_POOL_ENC-1]    au_iu_iu5_i1_t1_p,
   output [0:`GPR_POOL_ENC-1]    au_iu_iu5_i1_t2_p,
   output [0:`GPR_POOL_ENC-1]    au_iu_iu5_i1_t3_p,
   output [0:`GPR_POOL_ENC-1]    au_iu_iu5_i1_s1_p,
   output [0:`GPR_POOL_ENC-1]    au_iu_iu5_i1_s2_p,
   output [0:`GPR_POOL_ENC-1]    au_iu_iu5_i1_s3_p,
   output                        au_iu_iu5_i1_s1_dep_hit,
   output                        au_iu_iu5_i1_s2_dep_hit,
   output                        au_iu_iu5_i1_s3_dep_hit,

   output [0:`ITAG_SIZE_ENC-1]   au_iu_iu5_i1_s1_itag,
   output [0:`ITAG_SIZE_ENC-1]   au_iu_iu5_i1_s2_itag,

   output [0:`ITAG_SIZE_ENC-1]   au_iu_iu5_i1_s3_itag
   );

   parameter                    cp_flush_offset = 0;
   parameter                    br_iu_hold_offset = cp_flush_offset + 1;
   parameter                    scan_right = br_iu_hold_offset + 1 - 1;

   // scan
   wire [0:scan_right]          siv;
   wire [0:scan_right]          sov;
   wire [0:1]                   map_siv;
   wire [0:1]                   map_sov;

   wire                         tidn;
   wire                         tiup;

   // Latch to delay the flush signal
   wire                         cp_flush_d;
   wire                         cp_flush_l2;
   wire                         br_iu_hold_d;
   wire                         br_iu_hold_l2;

   // Source lookups from pools note may not be valid if source if type not of the right type
   wire [0:`GPR_POOL_ENC-1]      fpr_iu5_i0_src1_p;
   wire [0:`GPR_POOL_ENC-1]      fpr_iu5_i0_src2_p;
   wire [0:`GPR_POOL_ENC-1]      fpr_iu5_i0_src3_p;
   wire [0:`GPR_POOL_ENC-1]      fpr_iu5_i1_src1_p;
   wire [0:`GPR_POOL_ENC-1]      fpr_iu5_i1_src2_p;
   wire [0:`GPR_POOL_ENC-1]      fpr_iu5_i1_src3_p;

   // Source lookups from pools note may not be valid if source if type not of the right type
   wire [0:`ITAG_SIZE_ENC-1]     fpr_iu5_i0_src1_itag;
   wire [0:`ITAG_SIZE_ENC-1]     fpr_iu5_i0_src2_itag;
   wire [0:`ITAG_SIZE_ENC-1]     fpr_iu5_i0_src3_itag;
   wire [0:`ITAG_SIZE_ENC-1]     fpr_iu5_i1_src1_itag;
   wire [0:`ITAG_SIZE_ENC-1]     fpr_iu5_i1_src2_itag;
   wire [0:`ITAG_SIZE_ENC-1]     fpr_iu5_i1_src3_itag;

   // I1 dependency hit vs I0 for each source this is used by RV
   wire                          fpr_s1_dep_hit;
   wire                          fpr_s2_dep_hit;
   wire                          fpr_s3_dep_hit;

   // Free from completion to the fpr pool
   wire                         fpr_cp_i0_wr_v;
   wire [0:`GPR_POOL_ENC-1]      fpr_cp_i0_wr_a;
   wire [0:`GPR_POOL_ENC-1]      fpr_cp_i0_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]     fpr_cp_i0_wr_itag;
   wire                         fpr_cp_i1_wr_v;
   wire [0:`GPR_POOL_ENC-1]      fpr_cp_i1_wr_a;
   wire [0:`GPR_POOL_ENC-1]      fpr_cp_i1_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]     fpr_cp_i1_wr_itag;

   wire                         fpr_spec_i0_wr_v;
   wire                         fpr_spec_i0_wr_v_fast;
   wire [0:`GPR_POOL_ENC-1]      fpr_spec_i0_wr_a;
   wire [0:`GPR_POOL_ENC-1]      fpr_spec_i0_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]     fpr_spec_i0_wr_itag;
   wire                         fpr_spec_i1_wr_v;
   wire                         fpr_spec_i1_wr_v_fast;
   wire [0:`GPR_POOL_ENC-1]      fpr_spec_i1_wr_a;
   wire [0:`GPR_POOL_ENC-1]      fpr_spec_i1_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]     fpr_spec_i1_wr_itag;

   wire                         next_fpr_0_v;
   wire [0:`GPR_POOL_ENC-1]      next_fpr_0;
   wire                         next_fpr_1_v;
   wire [0:`GPR_POOL_ENC-1]      next_fpr_1;

   wire                         fpscr_cp_i0_wr_v;
   wire [0:FPSCR_POOL_ENC-1]    fpscr_cp_i0_wr_a;
   wire [0:FPSCR_POOL_ENC-1]    fpscr_cp_i0_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]     fpscr_cp_i0_wr_itag;
   wire                         fpscr_cp_i1_wr_v;
   wire [0:FPSCR_POOL_ENC-1]    fpscr_cp_i1_wr_a;
   wire [0:FPSCR_POOL_ENC-1]    fpscr_cp_i1_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]     fpscr_cp_i1_wr_itag;

   wire                         fpscr_spec_i0_wr_v;
   wire                         fpscr_spec_i0_wr_v_fast;
   wire [0:FPSCR_POOL_ENC-1]    fpscr_spec_i0_wr_a;
   wire [0:FPSCR_POOL_ENC-1]    fpscr_spec_i0_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]     fpscr_spec_i0_wr_itag;
   wire                         fpscr_spec_i1_wr_v;
   wire                         fpscr_spec_i1_wr_v_fast;
   wire [0:FPSCR_POOL_ENC-1]    fpscr_spec_i1_wr_a;
   wire [0:FPSCR_POOL_ENC-1]    fpscr_spec_i1_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]     fpscr_spec_i1_wr_itag;

   wire                         next_fpscr_0_v;
   wire [0:FPSCR_POOL_ENC-1]    next_fpscr_0;
   wire                         next_fpscr_1_v;
   wire [0:FPSCR_POOL_ENC-1]    next_fpscr_1;

   wire [0:1]                   fpr_send_cnt;
   wire [0:1]                   fpscr_send_cnt;

   wire                         fpr_send_ok;
   wire                         fpscr_send_ok;

   wire                         send_instructions;

   // Pervasive
   wire                         pc_iu_func_sl_thold_1;
   wire                         pc_iu_func_sl_thold_0;
   wire                         pc_iu_func_sl_thold_0_b;
   wire                         pc_iu_sg_1;
   wire                         pc_iu_sg_0;
   wire                         force_t;

   // This signal compares credits left and issues LQ/FX instructions to FX when set
   wire                         dual_issue_use_fx;
   //--------------------------------------------------------------

   assign tidn = 1'b0;
   assign tiup = 1'b1;

   assign cp_flush_d = cp_flush;
   assign br_iu_hold_d = (br_iu_redirect | br_iu_hold_l2) & (~(cp_flush_l2));

   assign fpr_send_cnt = ({(iu_au_iu5_i0_t2_v & (iu_au_iu5_i0_t2_t == `axu0_t)), (iu_au_iu5_i1_t2_v & (iu_au_iu5_i1_t2_t == `axu0_t))});

   assign fpscr_send_cnt = ({(iu_au_iu5_i0_t1_v & (iu_au_iu5_i0_t1_t == `axu1_t)), (iu_au_iu5_i1_t1_v & (iu_au_iu5_i1_t1_t == `axu1_t))});

   assign fpr_send_ok = (fpr_send_cnt == 2'b00) | ((fpr_send_cnt[0] ^ fpr_send_cnt[1]) & next_fpr_0_v) | (next_fpr_0_v & next_fpr_1_v);

   assign fpscr_send_ok = (fpscr_send_cnt == 2'b00) | ((fpscr_send_cnt[0] ^ fpscr_send_cnt[1]) & next_fpscr_0_v) | (next_fpscr_0_v & next_fpscr_1_v);


   assign au_iu_iu5_axu0_send_ok = fpr_send_ok & fpscr_send_ok;
   assign au_iu_iu5_axu1_send_ok = 1'b1;

   //todo...  frn may not send instr due to other credits...
   assign send_instructions = (fpr_send_ok & fpscr_send_ok & iu_au_iu5_send_ok & iu_au_iu5_i0_vld) & (~(br_iu_hold_l2));

   assign dual_issue_use_fx = 1'b0;

   //-----------------------------------------------------------------------
   //-- Outputs
   //-----------------------------------------------------------------------

   assign au_iu_iu5_stall = (~(fpr_send_ok & fpscr_send_ok));

   assign au_iu_iu5_i0_t1_p[0:`GPR_POOL_ENC - 1] = {2'b00,next_fpscr_0};
   assign au_iu_iu5_i0_t2_p = next_fpr_0;
   assign au_iu_iu5_i0_t3_p = 0;

   assign au_iu_iu5_i0_s1_p = fpr_iu5_i0_src1_p;
   assign au_iu_iu5_i0_s2_p = fpr_iu5_i0_src2_p;
   assign au_iu_iu5_i0_s3_p = fpr_iu5_i0_src3_p;

   assign au_iu_iu5_i0_s1_itag = fpr_iu5_i0_src1_itag;
   assign au_iu_iu5_i0_s2_itag = fpr_iu5_i0_src2_itag;
   assign au_iu_iu5_i0_s3_itag = fpr_iu5_i0_src3_itag;

   assign au_iu_iu5_i1_t1_p[0:`GPR_POOL_ENC - 1] = {2'b00,next_fpscr_1};
   assign au_iu_iu5_i1_t2_p = next_fpr_1;
   assign au_iu_iu5_i1_t3_p = 0;

   assign au_iu_iu5_i1_s1_p = fpr_iu5_i1_src1_p;
   assign au_iu_iu5_i1_s2_p = fpr_iu5_i1_src2_p;
   assign au_iu_iu5_i1_s3_p = fpr_iu5_i1_src3_p;

   assign au_iu_iu5_i1_s1_itag = fpr_iu5_i1_src1_itag;
   assign au_iu_iu5_i1_s2_itag = fpr_iu5_i1_src2_itag;
   assign au_iu_iu5_i1_s3_itag = fpr_iu5_i1_src3_itag;

   assign au_iu_iu5_i1_s1_dep_hit = fpr_s1_dep_hit & (iu_au_iu5_i1_s1_t == `axu0_t);
   assign au_iu_iu5_i1_s2_dep_hit = fpr_s2_dep_hit & (iu_au_iu5_i1_s2_t == `axu0_t);
   assign au_iu_iu5_i1_s3_dep_hit = fpr_s3_dep_hit & (iu_au_iu5_i1_s3_t == `axu0_t);

   //-----------------------------------------------------------------------
   //-- FPR Renamer
   //-----------------------------------------------------------------------
   // Gate the FPR write enable by killing its completion report to the rn mapper

   assign fpr_cp_i0_wr_v = cp_rn_i0_t2_v & (cp_rn_i0_t2_t == `axu0_t) & (~(cp_rn_i0_axu_exception[0:3] == 4'b0101));
   assign fpr_cp_i0_wr_a = cp_rn_i0_t2_a;
   assign fpr_cp_i0_wr_p = cp_rn_i0_t2_p;
   assign fpr_cp_i0_wr_itag = cp_rn_i0_itag;
   assign fpr_cp_i1_wr_v = cp_rn_i1_t2_v & (cp_rn_i1_t2_t == `axu0_t) & (~(cp_rn_i1_axu_exception[0:3] == 4'b0101));
   assign fpr_cp_i1_wr_a = cp_rn_i1_t2_a;
   assign fpr_cp_i1_wr_p = cp_rn_i1_t2_p;
   assign fpr_cp_i1_wr_itag = cp_rn_i1_itag;

   assign fpr_spec_i0_wr_v = send_instructions & (~(fpr_send_cnt[0:1] == 2'b00));
   assign fpr_spec_i0_wr_v_fast = (~(fpr_send_cnt[0:1] == 2'b00));
   assign fpr_spec_i0_wr_a = (fpr_send_cnt[0] ? iu_au_iu5_i0_t2_a : 0) | (((~(fpr_send_cnt[0])) & fpr_send_cnt[1]) ? iu_au_iu5_i1_t2_a : 0);
   assign fpr_spec_i0_wr_p = next_fpr_0;
   assign fpr_spec_i0_wr_itag = (fpr_send_cnt[0] ? iu_au_iu5_next_itag_i0 : 0) | (((~(fpr_send_cnt[0])) & fpr_send_cnt[1]) ? iu_au_iu5_next_itag_i1 : 0);
   assign fpr_spec_i1_wr_v = send_instructions & (fpr_send_cnt[0:1] == 2'b11);
   assign fpr_spec_i1_wr_v_fast = (fpr_send_cnt[0:1] == 2'b11);
   assign fpr_spec_i1_wr_a = iu_au_iu5_i1_t2_a;
   assign fpr_spec_i1_wr_p = next_fpr_1;
   assign fpr_spec_i1_wr_itag = iu_au_iu5_next_itag_i1;

   assign fpr_s1_dep_hit = fpr_spec_i0_wr_v_fast & fpr_send_cnt[0] & (fpr_spec_i0_wr_a == iu_au_iu5_i1_s1_a);
   assign fpr_s2_dep_hit = fpr_spec_i0_wr_v_fast & fpr_send_cnt[0] & (fpr_spec_i0_wr_a == iu_au_iu5_i1_s2_a);
   assign fpr_s3_dep_hit = fpr_spec_i0_wr_v_fast & fpr_send_cnt[0] & (fpr_spec_i0_wr_a == iu_au_iu5_i1_s3_a);

   iuq_rn_map #(.ARCHITECTED_REGISTER_DEPTH((32 + FPR_UCODE_POOL)), .REGISTER_RENAME_DEPTH(FPR_POOL), .STORAGE_WIDTH(`GPR_POOL_ENC)) fpr_rn_map(
   	.vdd(vdd),
   	.gnd(gnd),
   	.nclk(nclk),
   	.pc_iu_func_sl_thold_0_b(pc_iu_func_sl_thold_0_b),
   	.pc_iu_sg_0(pc_iu_sg_0),
   	.force_t(force_t),
   	.d_mode(d_mode),
   	.delay_lclkr(delay_lclkr),
   	.mpw1_b(mpw1_b),
   	.mpw2_b(mpw2_b),
   	.func_scan_in(map_siv[0]),
   	.func_scan_out(map_sov[0]),

   	.take_a(fpr_spec_i0_wr_v),
   	.take_b(fpr_spec_i1_wr_v),
   	.next_reg_a_val(next_fpr_0_v),
   	.next_reg_a(next_fpr_0),
   	.next_reg_b_val(next_fpr_1_v),
   	.next_reg_b(next_fpr_1),

   	.src1_a(iu_au_iu5_i0_s1_a),		//fdec_frn_iu5_i0_s1_a,
   	.src1_p(fpr_iu5_i0_src1_p),
   	.src1_itag(fpr_iu5_i0_src1_itag),
   	.src2_a(iu_au_iu5_i0_s2_a),		//fdec_frn_iu5_i0_s2_a,
   	.src2_p(fpr_iu5_i0_src2_p),
   	.src2_itag(fpr_iu5_i0_src2_itag),
   	.src3_a(iu_au_iu5_i0_s3_a),		//fdec_frn_iu5_i0_s3_a,
   	.src3_p(fpr_iu5_i0_src3_p),
   	.src3_itag(fpr_iu5_i0_src3_itag),
   	.src4_a(iu_au_iu5_i1_s1_a),		//fdec_frn_iu5_i1_s1_a,
   	.src4_p(fpr_iu5_i1_src1_p),
   	.src4_itag(fpr_iu5_i1_src1_itag),
   	.src5_a(iu_au_iu5_i1_s2_a),		//fdec_frn_iu5_i1_s2_a,
   	.src5_p(fpr_iu5_i1_src2_p),
   	.src5_itag(fpr_iu5_i1_src2_itag),
   	.src6_a(iu_au_iu5_i1_s3_a),		//fdec_frn_iu5_i1_s3_a,
   	.src6_p(fpr_iu5_i1_src3_p),
   	.src6_itag(fpr_iu5_i1_src3_itag),

   	.comp_0_wr_val(fpr_cp_i0_wr_v),
   	.comp_0_wr_arc(fpr_cp_i0_wr_a),
   	.comp_0_wr_rename(fpr_cp_i0_wr_p),
   	.comp_0_wr_itag(fpr_cp_i0_wr_itag),

   	.comp_1_wr_val(fpr_cp_i1_wr_v),
   	.comp_1_wr_arc(fpr_cp_i1_wr_a),
   	.comp_1_wr_rename(fpr_cp_i1_wr_p),
   	.comp_1_wr_itag(fpr_cp_i1_wr_itag),

   	.spec_0_wr_val(fpr_spec_i0_wr_v),
   	.spec_0_wr_val_fast(fpr_spec_i0_wr_v_fast),
   	.spec_0_wr_arc(fpr_spec_i0_wr_a),
   	.spec_0_wr_rename(fpr_spec_i0_wr_p),
   	.spec_0_wr_itag(fpr_spec_i0_wr_itag),

      .spec_1_dep_hit_s1(fpr_s1_dep_hit),
      .spec_1_dep_hit_s2(fpr_s2_dep_hit),
      .spec_1_dep_hit_s3(fpr_s3_dep_hit),
   	.spec_1_wr_val(fpr_spec_i1_wr_v),
   	.spec_1_wr_val_fast(fpr_spec_i1_wr_v_fast),
   	.spec_1_wr_arc(fpr_spec_i1_wr_a),
   	.spec_1_wr_rename(fpr_spec_i1_wr_p),
   	.spec_1_wr_itag(fpr_spec_i1_wr_itag),

   	.flush_map(cp_flush_l2)
   );

   //-----------------------------------------------------------------------
   //-- FPSCR Renamer
   //-----------------------------------------------------------------------
   assign fpscr_cp_i0_wr_v = cp_rn_i0_t1_v & (cp_rn_i0_t1_t == `axu1_t);
   assign fpscr_cp_i0_wr_a = cp_rn_i0_t1_a[1:`GPR_POOL_ENC - 1];
   assign fpscr_cp_i0_wr_p = cp_rn_i0_t1_p[1:`GPR_POOL_ENC - 1];
   assign fpscr_cp_i0_wr_itag = cp_rn_i0_itag;
   assign fpscr_cp_i1_wr_v = cp_rn_i1_t1_v & (cp_rn_i1_t1_t == `axu1_t);
   assign fpscr_cp_i1_wr_a = cp_rn_i1_t1_a[1:`GPR_POOL_ENC - 1];
   assign fpscr_cp_i1_wr_p = cp_rn_i1_t1_p[1:`GPR_POOL_ENC - 1];
   assign fpscr_cp_i1_wr_itag = cp_rn_i1_itag;

   assign fpscr_spec_i0_wr_v = send_instructions & (~(fpscr_send_cnt[0:1] == 2'b00));
   assign fpscr_spec_i0_wr_v_fast = (~(fpscr_send_cnt[0:1] == 2'b00));
   assign fpscr_spec_i0_wr_a = (fpscr_send_cnt[0] ? iu_au_iu5_i0_t1_a[1:`GPR_POOL_ENC - 1] : 0) | (((~(fpscr_send_cnt[0])) & fpscr_send_cnt[1]) ? iu_au_iu5_i1_t1_a[1:`GPR_POOL_ENC - 1] : 0);
   assign fpscr_spec_i0_wr_p = next_fpscr_0;
   assign fpscr_spec_i0_wr_itag = (fpscr_send_cnt[0] ? iu_au_iu5_next_itag_i0 : 0) | (((~(fpscr_send_cnt[0])) & fpscr_send_cnt[1]) ? iu_au_iu5_next_itag_i1 : 0);
   assign fpscr_spec_i1_wr_v = send_instructions & (fpscr_send_cnt[0:1] == 2'b11);
   assign fpscr_spec_i1_wr_v_fast = (fpscr_send_cnt[0:1] == 2'b11);
   assign fpscr_spec_i1_wr_a = iu_au_iu5_i1_t1_a[1:`GPR_POOL_ENC - 1];
   assign fpscr_spec_i1_wr_p = next_fpscr_1;
   assign fpscr_spec_i1_wr_itag = iu_au_iu5_next_itag_i1;


`ifndef THREADS1

 // 24 entries per thread for dual thread
   iuq_rn_map #(.ARCHITECTED_REGISTER_DEPTH(1), .REGISTER_RENAME_DEPTH(24), .STORAGE_WIDTH(5)) fpscr_rn_map(		//`GPR_POOL_ENC)
   	.vdd(vdd),
   	.gnd(gnd),
   	.nclk(nclk),
   	.pc_iu_func_sl_thold_0_b(pc_iu_func_sl_thold_0_b),
   	.pc_iu_sg_0(pc_iu_sg_0),
   	.force_t(force_t),
   	.d_mode(d_mode),
   	.delay_lclkr(delay_lclkr),
   	.mpw1_b(mpw1_b),
   	.mpw2_b(mpw2_b),
   	.func_scan_in(map_siv[1]),
   	.func_scan_out(map_sov[1]),

   	.take_a(fpscr_spec_i0_wr_v),
   	.take_b(fpscr_spec_i1_wr_v),
   	.next_reg_a_val(next_fpscr_0_v),
   	.next_reg_a(next_fpscr_0),
   	.next_reg_b_val(next_fpscr_1_v),
   	.next_reg_b(next_fpscr_1),

   	.src1_a(iu_au_iu5_i0_s1_a[1:`GPR_POOL_ENC - 1]),
   	.src1_p(),
   	.src1_itag(),
   	.src2_a(iu_au_iu5_i0_s2_a[1:`GPR_POOL_ENC - 1]),
   	.src2_p(),
   	.src2_itag(),
   	.src3_a(iu_au_iu5_i0_s3_a[1:`GPR_POOL_ENC - 1]),
   	.src3_p(),
   	.src3_itag(),
   	.src4_a(iu_au_iu5_i1_s1_a[1:`GPR_POOL_ENC - 1]),
   	.src4_p(),
   	.src4_itag(),
   	.src5_a(iu_au_iu5_i1_s2_a[1:`GPR_POOL_ENC - 1]),
   	.src5_p(),
   	.src5_itag(),
   	.src6_a(iu_au_iu5_i1_s3_a[1:`GPR_POOL_ENC - 1]),
   	.src6_p(),
   	.src6_itag(),

   	.comp_0_wr_val(fpscr_cp_i0_wr_v),
   	.comp_0_wr_arc(fpscr_cp_i0_wr_a),
   	.comp_0_wr_rename(fpscr_cp_i0_wr_p),
   	.comp_0_wr_itag(fpscr_cp_i0_wr_itag),

   	.comp_1_wr_val(fpscr_cp_i1_wr_v),
   	.comp_1_wr_arc(fpscr_cp_i1_wr_a),
   	.comp_1_wr_rename(fpscr_cp_i1_wr_p),
   	.comp_1_wr_itag(fpscr_cp_i1_wr_itag),

   	.spec_0_wr_val(fpscr_spec_i0_wr_v),
   	.spec_0_wr_val_fast(fpscr_spec_i0_wr_v_fast),
   	.spec_0_wr_arc(fpscr_spec_i0_wr_a),
   	.spec_0_wr_rename(fpscr_spec_i0_wr_p),
   	.spec_0_wr_itag(fpscr_spec_i0_wr_itag),

      .spec_1_dep_hit_s1(gnd),
      .spec_1_dep_hit_s2(gnd),
      .spec_1_dep_hit_s3(gnd),
   	.spec_1_wr_val(fpscr_spec_i1_wr_v),
   	.spec_1_wr_val_fast(fpscr_spec_i1_wr_v_fast),
   	.spec_1_wr_arc(fpscr_spec_i1_wr_a),
   	.spec_1_wr_rename(fpscr_spec_i1_wr_p),
   	.spec_1_wr_itag(fpscr_spec_i1_wr_itag),

   	.flush_map(cp_flush_l2)
   );


 `else
 // 32 if single thread
   iuq_rn_map #(.ARCHITECTED_REGISTER_DEPTH(1), .REGISTER_RENAME_DEPTH(32), .STORAGE_WIDTH(5)) fpscr_rn_map(		//`GPR_POOL_ENC)
   	.vdd(vdd),
   	.gnd(gnd),
   	.nclk(nclk),
   	.pc_iu_func_sl_thold_0_b(pc_iu_func_sl_thold_0_b),
   	.pc_iu_sg_0(pc_iu_sg_0),
   	.force_t(force_t),
   	.d_mode(d_mode),
   	.delay_lclkr(delay_lclkr),
   	.mpw1_b(mpw1_b),
   	.mpw2_b(mpw2_b),
   	.func_scan_in(map_siv[1]),
   	.func_scan_out(map_sov[1]),

   	.take_a(fpscr_spec_i0_wr_v),
   	.take_b(fpscr_spec_i1_wr_v),
   	.next_reg_a_val(next_fpscr_0_v),
   	.next_reg_a(next_fpscr_0),
   	.next_reg_b_val(next_fpscr_1_v),
   	.next_reg_b(next_fpscr_1),

   	.src1_a(iu_au_iu5_i0_s1_a[1:`GPR_POOL_ENC - 1]),
   	.src1_p(),
   	.src1_itag(),
   	.src2_a(iu_au_iu5_i0_s2_a[1:`GPR_POOL_ENC - 1]),
   	.src2_p(),
   	.src2_itag(),
   	.src3_a(iu_au_iu5_i0_s3_a[1:`GPR_POOL_ENC - 1]),
   	.src3_p(),
   	.src3_itag(),
   	.src4_a(iu_au_iu5_i1_s1_a[1:`GPR_POOL_ENC - 1]),
   	.src4_p(),
   	.src4_itag(),
   	.src5_a(iu_au_iu5_i1_s2_a[1:`GPR_POOL_ENC - 1]),
   	.src5_p(),
   	.src5_itag(),
   	.src6_a(iu_au_iu5_i1_s3_a[1:`GPR_POOL_ENC - 1]),
   	.src6_p(),
   	.src6_itag(),

   	.comp_0_wr_val(fpscr_cp_i0_wr_v),
   	.comp_0_wr_arc(fpscr_cp_i0_wr_a),
   	.comp_0_wr_rename(fpscr_cp_i0_wr_p),
   	.comp_0_wr_itag(fpscr_cp_i0_wr_itag),

   	.comp_1_wr_val(fpscr_cp_i1_wr_v),
   	.comp_1_wr_arc(fpscr_cp_i1_wr_a),
   	.comp_1_wr_rename(fpscr_cp_i1_wr_p),
   	.comp_1_wr_itag(fpscr_cp_i1_wr_itag),

   	.spec_0_wr_val(fpscr_spec_i0_wr_v),
   	.spec_0_wr_val_fast(fpscr_spec_i0_wr_v_fast),
   	.spec_0_wr_arc(fpscr_spec_i0_wr_a),
   	.spec_0_wr_rename(fpscr_spec_i0_wr_p),
   	.spec_0_wr_itag(fpscr_spec_i0_wr_itag),

      .spec_1_dep_hit_s1(gnd),
      .spec_1_dep_hit_s2(gnd),
      .spec_1_dep_hit_s3(gnd),
   	.spec_1_wr_val(fpscr_spec_i1_wr_v),
   	.spec_1_wr_val_fast(fpscr_spec_i1_wr_v_fast),
   	.spec_1_wr_arc(fpscr_spec_i1_wr_a),
   	.spec_1_wr_rename(fpscr_spec_i1_wr_p),
   	.spec_1_wr_itag(fpscr_spec_i1_wr_itag),

   	.flush_map(cp_flush_l2)
   );

 `endif



   tri_rlmlatch_p #(.INIT(0)) cp_flush_latch(
   	.vd(vdd),
   	.gd(gnd),
   	.nclk(nclk),
   	.act(tiup),
   	.thold_b(pc_iu_func_sl_thold_0_b),
   	.sg(pc_iu_sg_0),
   	.force_t(force_t),
   	.delay_lclkr(delay_lclkr),
   	.mpw1_b(mpw1_b),
   	.mpw2_b(mpw2_b),
   	.d_mode(d_mode),
   	.scin(siv[cp_flush_offset]),
   	.scout(sov[cp_flush_offset]),
   	.din(cp_flush_d),
   	.dout(cp_flush_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) br_iu_hold_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[br_iu_hold_offset]),
      .scout(sov[br_iu_hold_offset]),
      .din(br_iu_hold_d),
      .dout(br_iu_hold_l2)
   );

   //-----------------------------------------------
   // pervasive
   //-----------------------------------------------


   tri_plat #(.WIDTH(2)) perv_2to1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({pc_iu_func_sl_thold_2,pc_iu_sg_2}),
      .q({pc_iu_func_sl_thold_1,pc_iu_sg_1})
   );


   tri_plat #(.WIDTH(2)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({pc_iu_func_sl_thold_1,pc_iu_sg_1}),
      .q({pc_iu_func_sl_thold_0,pc_iu_sg_0})
   );


   tri_lcbor  perv_lcbor(
	   .clkoff_b(clkoff_b),
	   .thold(pc_iu_func_sl_thold_0),
	   .sg(pc_iu_sg_0),
	   .act_dis(act_dis),
	   .force_t(force_t),
	   .thold_b(pc_iu_func_sl_thold_0_b)
   );

   assign map_siv = {func_scan_in, map_sov[0]};
   assign siv = {sov[1:scan_right], map_sov[1]};
   assign func_scan_out = sov[0];

endmodule

