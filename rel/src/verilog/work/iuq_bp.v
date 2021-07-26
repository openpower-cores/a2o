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

module iuq_bp(
   iu2_0_bh0_rd_data,
   iu2_1_bh0_rd_data,
   iu2_2_bh0_rd_data,
   iu2_3_bh0_rd_data,
   iu2_0_bh1_rd_data,
   iu2_1_bh1_rd_data,
   iu2_2_bh1_rd_data,
   iu2_3_bh1_rd_data,
   iu2_0_bh2_rd_data,
   iu2_1_bh2_rd_data,
   iu2_2_bh2_rd_data,
   iu2_3_bh2_rd_data,
   iu0_bh0_rd_addr,
   iu0_bh1_rd_addr,
   iu0_bh2_rd_addr,
   iu0_bh0_rd_act,
   iu0_bh1_rd_act,
   iu0_bh2_rd_act,
   ex5_bh0_wr_data,
   ex5_bh1_wr_data,
   ex5_bh2_wr_data,
   ex5_bh0_wr_addr,
   ex5_bh1_wr_addr,
   ex5_bh2_wr_addr,
   ex5_bh0_wr_act,
   ex5_bh1_wr_act,
   ex5_bh2_wr_act,
   iu0_btb_rd_addr,
   iu0_btb_rd_act,
   iu2_btb_rd_data,
   ex5_btb_wr_addr,
   ex5_btb_wr_act,
   ex5_btb_wr_data,
   ic_bp_iu0_val,
   ic_bp_iu0_ifar,
   ic_bp_iu2_val,
   ic_bp_iu2_ifar,
   ic_bp_iu2_error,
   ic_bp_iu2_2ucode,
   ic_bp_iu2_flush,
   ic_bp_iu3_flush,
   ic_bp_iu3_ecc_err,
   ic_bp_iu2_0_instr,
   ic_bp_iu2_1_instr,
   ic_bp_iu2_2_instr,
   ic_bp_iu2_3_instr,
   bp_ib_iu3_val,
   bp_ib_iu3_ifar,
   bp_ib_iu3_bta,
   bp_ib_iu3_0_instr,
   bp_ib_iu3_1_instr,
   bp_ib_iu3_2_instr,
   bp_ib_iu3_3_instr,
   bp_ic_iu3_hold,
   bp_ic_iu2_redirect,
   bp_ic_iu3_redirect,
   bp_ic_iu4_redirect,
   bp_ic_redirect_ifar,
   cp_bp_ifar,
   cp_bp_val,
   cp_bp_bh0_hist,
   cp_bp_bh1_hist,
   cp_bp_bh2_hist,
   cp_bp_br_pred,
   cp_bp_br_taken,
   cp_bp_bh_update,
   cp_bp_bcctr,
   cp_bp_bclr,
   cp_bp_getNIA,
   cp_bp_group,
   cp_bp_lk,
   cp_bp_bh,
   cp_bp_bta,
   cp_bp_gshare,
   cp_bp_ls_ptr,
   cp_bp_btb_hist,
   cp_bp_btb_entry,
   br_iu_gshare,
   br_iu_ls_ptr,
   br_iu_ls_data,
   br_iu_ls_update,
   iu_flush,
   br_iu_redirect,
   cp_flush,
   ib_ic_iu4_redirect,
   uc_iu4_flush,
   spr_bp_config,
   spr_bp_size,
   xu_iu_msr_de,
   xu_iu_dbcr0_icmp,
   xu_iu_dbcr0_brt,
   xu_iu_iac1_en,
   xu_iu_iac2_en,
   xu_iu_iac3_en,
   xu_iu_iac4_en,
   lq_iu_spr_dbcr3_ivc,
   xu_iu_single_instr_mode,
   spr_single_issue,
   vdd,
   gnd,
   nclk,
   pc_iu_sg_2,
   pc_iu_func_sl_thold_2,
   clkoff_b,
   act_dis,
   tc_ac_ccflush_dc,
   d_mode,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   scan_in,
   scan_out
);
//   parameter                     `EFF_IFAR_ARCH = 62;
//   parameter                     `EFF_IFAR_WIDTH = 20;
//   parameter                     PRED_TYPE = 0;		// 0 = hybrid, 1 = gskew

`include "tri_a2o.vh"

   //in from bht
   input [0:1]                   iu2_0_bh0_rd_data;
   input [0:1]                   iu2_1_bh0_rd_data;
   input [0:1]                   iu2_2_bh0_rd_data;
   input [0:1]                   iu2_3_bh0_rd_data;

   input [0:1]                   iu2_0_bh1_rd_data;
   input [0:1]                   iu2_1_bh1_rd_data;
   input [0:1]                   iu2_2_bh1_rd_data;
   input [0:1]                   iu2_3_bh1_rd_data;

   input			iu2_0_bh2_rd_data;
   input			iu2_1_bh2_rd_data;
   input			iu2_2_bh2_rd_data;
   input			iu2_3_bh2_rd_data;

   //out to bht
   output [0:9]                  iu0_bh0_rd_addr;
   output [0:9]                  iu0_bh1_rd_addr;
   output [0:8]                  iu0_bh2_rd_addr;
   output                        iu0_bh0_rd_act;
   output                        iu0_bh1_rd_act;
   output                        iu0_bh2_rd_act;
   output [0:1]                  ex5_bh0_wr_data;
   output [0:1]                  ex5_bh1_wr_data;
   output                        ex5_bh2_wr_data;
   output [0:9]                  ex5_bh0_wr_addr;
   output [0:9]                  ex5_bh1_wr_addr;
   output [0:8]                  ex5_bh2_wr_addr;
   output [0:3]                  ex5_bh0_wr_act;
   output [0:3]                  ex5_bh1_wr_act;
   output [0:3]                  ex5_bh2_wr_act;

   //in/out to btb
   output [0:5]                  iu0_btb_rd_addr;
   output                        iu0_btb_rd_act;
   input  [0:63]		 iu2_btb_rd_data;
   output [0:5]                  ex5_btb_wr_addr;
   output                        ex5_btb_wr_act;
   output [0:63]		 ex5_btb_wr_data;

   //iu0
   input                         ic_bp_iu0_val;
   input [50:59]                 ic_bp_iu0_ifar;

   //iu2
   input [0:3]                   ic_bp_iu2_val;
   input [62-`EFF_IFAR_WIDTH:61]  ic_bp_iu2_ifar;
   input [0:2]                   ic_bp_iu2_error;
   input                         ic_bp_iu2_2ucode;
   input                         ic_bp_iu2_flush;
   input                         ic_bp_iu3_flush;
   input                         ic_bp_iu3_ecc_err;

   //iu2 instruction(0:31) + predecode(32:35)
   input [0:35]                  ic_bp_iu2_0_instr;
   input [0:35]                  ic_bp_iu2_1_instr;
   input [0:35]                  ic_bp_iu2_2_instr;
   input [0:35]                  ic_bp_iu2_3_instr;

   //iu3
   output [0:3]                  bp_ib_iu3_val;
   output [62-`EFF_IFAR_WIDTH:61] bp_ib_iu3_ifar;
   output [62-`EFF_IFAR_WIDTH:61] bp_ib_iu3_bta;

   //iu3 instruction(0:31) +
   output [0:69]                 bp_ib_iu3_0_instr;
   output [0:69]                 bp_ib_iu3_1_instr;
   output [0:69]                 bp_ib_iu3_2_instr;
   output [0:69]                 bp_ib_iu3_3_instr;

   //iu4 hold/redirect
   output                        bp_ic_iu3_hold;
   output                        bp_ic_iu2_redirect;
   output                        bp_ic_iu3_redirect;
   output                        bp_ic_iu4_redirect;
   output [62-`EFF_IFAR_WIDTH:61] bp_ic_redirect_ifar;

   //ex4 update
   input [62-`EFF_IFAR_WIDTH:61]  cp_bp_ifar;
   input                         cp_bp_val;
   input [0:1]                   cp_bp_bh0_hist;
   input [0:1]                   cp_bp_bh1_hist;
   input [0:1]                   cp_bp_bh2_hist;
   input                         cp_bp_br_pred;
   input                         cp_bp_br_taken;
   input                         cp_bp_bh_update;
   input                         cp_bp_bcctr;
   input                         cp_bp_bclr;
   input                         cp_bp_getNIA;
   input                         cp_bp_group;
   input                         cp_bp_lk;
   input [0:1]                   cp_bp_bh;
   input [62-`EFF_IFAR_WIDTH:61]  cp_bp_bta;
   input [0:9]                   cp_bp_gshare;
   input [0:2]                   cp_bp_ls_ptr;
   input [0:1]                   cp_bp_btb_hist;
   input                         cp_bp_btb_entry;

   //br unit repairs
   input [0:17]                  br_iu_gshare;
   input [0:2]                   br_iu_ls_ptr;
   input [62-`EFF_IFAR_WIDTH:61]  br_iu_ls_data;
   input                         br_iu_ls_update;

   //flush conditions
   input                         iu_flush;
   input                         br_iu_redirect;
   input                         cp_flush;
   input                         ib_ic_iu4_redirect;
   input                         uc_iu4_flush;

   //config bits
   input [0:5]                   spr_bp_config;
   input [0:1]                   spr_bp_size;
   input                         xu_iu_msr_de;
   input                         xu_iu_dbcr0_icmp;
   input                         xu_iu_dbcr0_brt;
   input			 xu_iu_iac1_en;
   input			 xu_iu_iac2_en;
   input			 xu_iu_iac3_en;
   input			 xu_iu_iac4_en;
   input                         lq_iu_spr_dbcr3_ivc;
   input                         xu_iu_single_instr_mode;
   input                         spr_single_issue;

   //pervasive
   inout                         vdd;
   inout                         gnd;
   (* pin_data="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]       nclk;
   input                         pc_iu_sg_2;
   input                         pc_iu_func_sl_thold_2;
   input                         clkoff_b;
   input                         act_dis;
   input                         tc_ac_ccflush_dc;
   input                         d_mode;
   input                         delay_lclkr;
   input                         mpw1_b;
   input                         mpw2_b;
   input [0:1]                   scan_in;

   output [0:1]                  scan_out;

   localparam [0:31]					value_1 = 32'h00000001;
   localparam [0:31]					value_2 = 32'h00000002;

   //--------------------------
   // components
   //--------------------------

   //--------------------------
   // constants
   //--------------------------

   //scan chain 0

      parameter                     iu0_btb_hist_offset = 0;
      parameter                     iu1_btb_hist_offset = iu0_btb_hist_offset + 128;
      parameter                     iu2_btb_hist_offset = iu1_btb_hist_offset + 2;
      parameter                     gshare_offset = iu2_btb_hist_offset + 2;
      parameter                     gshare_shift0_offset = gshare_offset + 16;
      parameter                     cp_gshare_offset = gshare_shift0_offset + 5;
      parameter                     cp_gs_count_offset = cp_gshare_offset + 16;
      parameter                     cp_gs_taken_offset = cp_gs_count_offset + 2;
      parameter                     iu1_gs_pos_offset = cp_gs_taken_offset + 1;
      parameter                     iu2_gs_pos_offset = iu1_gs_pos_offset + 3;
      parameter                     iu3_gs_pos_offset = iu2_gs_pos_offset + 3;
      parameter                     iu1_gshare_offset = iu3_gs_pos_offset + 3;
      parameter                     iu2_gshare_offset = iu1_gshare_offset + 10;
      parameter                     iu3_bh_offset = iu2_gshare_offset + 10;
      parameter                     iu3_lk_offset = iu3_bh_offset + 2;
      parameter                     iu3_aa_offset = iu3_lk_offset + 1;
      parameter                     iu3_b_offset = iu3_aa_offset + 1;
      parameter                     iu3_bclr_offset = iu3_b_offset + 1;
      parameter                     iu3_bcctr_offset = iu3_bclr_offset + 1;
      parameter                     iu3_opcode_offset = iu3_bcctr_offset + 1;
      parameter                     iu3_bo_offset = iu3_opcode_offset + 6;
      parameter                     iu3_bi_offset = iu3_bo_offset + 5;
      parameter                     iu3_tar_offset = iu3_bi_offset + 5;
      parameter                     iu3_ifar_offset = iu3_tar_offset + 24;
      parameter                     iu3_ifar_pri_offset = iu3_ifar_offset + `EFF_IFAR_WIDTH;
      parameter                     iu3_pr_val_offset = iu3_ifar_pri_offset + 2;
      parameter                     iu3_lnk_offset = iu3_pr_val_offset + 1;
      parameter                     iu3_btb_offset = iu3_lnk_offset + `EFF_IFAR_WIDTH;
      parameter                     iu3_nfg_offset = iu3_btb_offset + `EFF_IFAR_WIDTH;
      parameter                     iu3_val_offset = iu3_nfg_offset + `EFF_IFAR_WIDTH;
      parameter                     iu3_0_instr_offset = iu3_val_offset + 4;
      parameter                     iu3_1_instr_offset = iu3_0_instr_offset + 61;
      parameter                     iu3_2_instr_offset = iu3_1_instr_offset + 61;
      parameter                     iu3_3_instr_offset = iu3_2_instr_offset + 61;
      parameter                     iu3_btb_redirect_offset = iu3_3_instr_offset + 61;
      parameter                     iu3_btb_misdirect_offset = iu3_btb_redirect_offset + 1;
      parameter                     iu3_btb_link_offset = iu3_btb_misdirect_offset + 1;
      parameter                     iu4_redirect_ifar_offset = iu3_btb_link_offset + 1;
      parameter                     iu4_redirect_offset = iu4_redirect_ifar_offset + `EFF_IFAR_WIDTH;
      parameter                     iu4_ls_push_offset = iu4_redirect_offset + 1;
      parameter                     iu4_ls_pop_offset = iu4_ls_push_offset + 1;
      parameter                     iu4_ifar_offset = iu4_ls_pop_offset + 1;
      parameter                     scan_right0 = iu4_ifar_offset + `EFF_IFAR_WIDTH - 1;

      //scan chain 1
      parameter                     iu5_ls_t0_ptr_offset = 0;
      parameter                     iu5_ls_t00_offset = iu5_ls_t0_ptr_offset + 8;
      parameter                     iu5_ls_t01_offset = iu5_ls_t00_offset + `EFF_IFAR_WIDTH;
      parameter                     iu5_ls_t02_offset = iu5_ls_t01_offset + `EFF_IFAR_WIDTH;
      parameter                     iu5_ls_t03_offset = iu5_ls_t02_offset + `EFF_IFAR_WIDTH;
      parameter                     iu5_ls_t04_offset = iu5_ls_t03_offset + `EFF_IFAR_WIDTH;
      parameter                     iu5_ls_t05_offset = iu5_ls_t04_offset + `EFF_IFAR_WIDTH;
      parameter                     iu5_ls_t06_offset = iu5_ls_t05_offset + `EFF_IFAR_WIDTH;
      parameter                     iu5_ls_t07_offset = iu5_ls_t06_offset + `EFF_IFAR_WIDTH;
      parameter                     ex6_ls_t00_offset = iu5_ls_t07_offset + `EFF_IFAR_WIDTH;
      parameter                     ex6_ls_t01_offset = ex6_ls_t00_offset + `EFF_IFAR_WIDTH;
      parameter                     ex6_ls_t02_offset = ex6_ls_t01_offset + `EFF_IFAR_WIDTH;
      parameter                     ex6_ls_t03_offset = ex6_ls_t02_offset + `EFF_IFAR_WIDTH;
      parameter                     ex6_ls_t04_offset = ex6_ls_t03_offset + `EFF_IFAR_WIDTH;
      parameter                     ex6_ls_t05_offset = ex6_ls_t04_offset + `EFF_IFAR_WIDTH;
      parameter                     ex6_ls_t06_offset = ex6_ls_t05_offset + `EFF_IFAR_WIDTH;
      parameter                     ex6_ls_t07_offset = ex6_ls_t06_offset + `EFF_IFAR_WIDTH;
      parameter                     ex5_val_offset = ex6_ls_t07_offset + `EFF_IFAR_WIDTH;
      parameter                     ex5_ifar_offset = ex5_val_offset + 1;
      parameter                     ex5_bh_update_offset = ex5_ifar_offset + `EFF_IFAR_WIDTH;
      parameter                     ex5_gshare_offset = ex5_bh_update_offset + 1;
      parameter                     ex5_bh0_hist_offset = ex5_gshare_offset + 10;
      parameter                     ex5_bh1_hist_offset = ex5_bh0_hist_offset + 2;
      parameter                     ex5_bh2_hist_offset = ex5_bh1_hist_offset + 2;
      parameter                     ex5_br_pred_offset = ex5_bh2_hist_offset + 2;
      parameter                     ex5_bcctr_offset = ex5_br_pred_offset + 1;
      parameter                     ex5_bta_offset = ex5_bcctr_offset + 1;
      parameter                     ex5_br_taken_offset = ex5_bta_offset + `EFF_IFAR_WIDTH;
      parameter                     ex5_ls_ptr_offset = ex5_br_taken_offset + 1;
      parameter                     ex5_bclr_offset = ex5_ls_ptr_offset + 8;
      parameter                     ex5_getNIA_offset = ex5_bclr_offset + 1;
      parameter                     ex5_group_offset = ex5_getNIA_offset + 1;
      parameter                     ex5_lk_offset = ex5_group_offset + 1;
      parameter                     ex5_bh_offset = ex5_lk_offset + 1;
      parameter                     ex5_ls_push_offset = ex5_bh_offset + 2;
      parameter                     ex5_ls_pop_offset = ex5_ls_push_offset + 1;
      parameter                     ex5_flush_offset = ex5_ls_pop_offset + 1;
      parameter                     ex5_btb_hist_offset = ex5_flush_offset + 1;
      parameter                     ex5_btb_entry_offset = ex5_btb_hist_offset + 2;
      parameter                     ex5_btb_repl_offset = ex5_btb_entry_offset + 1;
      parameter                     ex6_ls_t0_ptr_offset = ex5_btb_repl_offset + 128;
      parameter                     bp_config_offset = ex6_ls_t0_ptr_offset + 8;
      parameter                     br_iu_gshare_offset = bp_config_offset + 7;
      parameter                     br_iu_ls_ptr_offset = br_iu_gshare_offset + 18;
      parameter                     br_iu_ls_data_offset = br_iu_ls_ptr_offset + 8;
      parameter                     br_iu_ls_update_offset = br_iu_ls_data_offset + `EFF_IFAR_WIDTH;
      parameter                     br_iu_redirect_offset = br_iu_ls_update_offset + 1;
      parameter                     cp_flush_offset = br_iu_redirect_offset + 1;
      parameter                     iu_flush_offset = cp_flush_offset + 1;
      parameter                     bcache_data0_offset = iu_flush_offset + 1;
      parameter                     bcache_data1_offset = bcache_data0_offset + 16;
      parameter                     bcache_data2_offset = bcache_data1_offset + 16;
      parameter                     bcache_data3_offset = bcache_data2_offset + 16;
      parameter                     bcache_data4_offset = bcache_data3_offset + 16;
      parameter                     bcache_data5_offset = bcache_data4_offset + 16;
      parameter                     bcache_data6_offset = bcache_data5_offset + 16;
      parameter                     bcache_data7_offset = bcache_data6_offset + 16;
      parameter                     scan_right1 = bcache_data7_offset + 16 - 1;

      //--------------------------
      // signals
      //--------------------------

      wire                          fuse_en;

      wire                          bp_dy_en;
      wire                          bp_st_en;
      wire                          bp_bt_en;
      wire [0:1]		    bp_gs_mode;

      wire [0:6]                    bp_config_d;
      wire [0:6]                    bp_config_q;

      wire [0:9]                    iu0_bh_ti0gs0_rd_addr;
      wire [0:9]                    iu0_bh_ti0gs1_rd_addr;
      wire [0:8]                    iu0_bh_ti0gs2_rd_addr;
      wire [0:9]                    iu0_gshare0;
      wire [0:9]                    iu0_gshare1;
      wire [0:8]                    iu0_gshare2;

      wire [0:9]                    ex5_bh_ti0gs0_wr_addr;
      wire [0:9]                    ex5_bh_ti0gs1_wr_addr;
      wire [0:8]                    ex5_bh_ti0gs2_wr_addr;
      wire [0:9]                    ex5_gshare0;
      wire [0:9]                    ex5_gshare1;
      wire [0:8]                    ex5_gshare2;
      wire [0:3]                    ex5_bh_wr_act;

      wire [0:0]                    gshare_act;
      wire                          gshare_taken;

      wire [0:4]                    gshare_shift;
      wire [0:4]                    gshare_shift1;
      wire [0:4]                    gshare_shift2;
      wire [0:4]                    gshare_shift3;
      wire [0:4]                    gshare_shift4;
      wire [0:4]                    gshare_shift0_d;
      wire [0:4]                    gshare_shift0_q;

      wire                          cp_gshare_shift;
      wire                          cp_gshare_taken;
      wire [0:15]                   cp_gshare_d;
      wire [0:15]                   cp_gshare_q;

      wire [0:15]                   gshare_d;
      wire [0:15]                   gshare_q;

      wire [0:9]                    iu1_gshare_d;
      wire [0:9]                    iu1_gshare_q;
      wire [0:9]                    iu2_gshare_d;
      wire [0:9]                    iu2_gshare_q;

      wire                          iu2_0_bh_pred;
      wire                          iu2_1_bh_pred;
      wire                          iu2_2_bh_pred;
      wire                          iu2_3_bh_pred;

      wire [0:1]                    iu2_0_bh0_hist;
      wire [0:1]                    iu2_1_bh0_hist;
      wire [0:1]                    iu2_2_bh0_hist;
      wire [0:1]                    iu2_3_bh0_hist;

      wire [0:1]                    iu2_0_bh1_hist;
      wire [0:1]                    iu2_1_bh1_hist;
      wire [0:1]                    iu2_2_bh1_hist;
      wire [0:1]                    iu2_3_bh1_hist;

      wire			    iu2_0_bh2_hist;
      wire			    iu2_1_bh2_hist;
      wire			    iu2_2_bh2_hist;
      wire			    iu2_3_bh2_hist;

      wire [0:3]                    iu2_fuse;
      wire [0:3]                    iu2_uc;
      wire [0:3]                    iu2_br_val;
      wire [0:3]                    iu2_br_hard;
      wire [0:3]                    iu2_hint_val;
      wire [0:3]                    iu2_hint;
      wire [0:3]                    iu2_bh_pred;

      wire [0:3]                    iu2_bh_update;
      wire [0:3]                    iu2_br_dynamic;
      wire [0:3]                    iu2_br_static;
      wire [0:3]                    iu2_br_pred;

      wire [0:33]                   iu2_instr_pri;

      wire [62-`EFF_IFAR_WIDTH:61]   iu2_lnk;
      wire [62-`EFF_IFAR_WIDTH:61]   iu2_btb;
      wire [0:2]                    iu2_ls_ptr;

      wire [62-`EFF_IFAR_WIDTH:61]   iu2_btb_tag;
      wire                          iu2_btb_link;
      wire [0:1]                    iu2_btb_hist;
      wire [0:3]                    iu2_btb_entry;

      wire                          iu1_flush;
      wire                          iu2_flush;

      wire                          iu2_redirect;
      wire                          iu3_btb_redirect_d;
      wire                          iu3_btb_redirect_q;
      wire                          iu3_btb_misdirect_d;
      wire                          iu3_btb_misdirect_q;
      wire                          iu3_btb_link_d;
      wire                          iu3_btb_link_q;

      wire [0:1]                    iu0_btb_hist_new;
      wire [0:127]                  iu0_btb_hist_out;
      wire                          iu0_btb_hist_act;
      wire [0:127]                  iu0_btb_hist_d;
      wire [0:127]                  iu0_btb_hist_q;
      wire [0:1]                    iu1_btb_hist_d;
      wire [0:1]                    iu1_btb_hist_q;
      wire [0:1]                    iu2_btb_hist_d;
      wire [0:1]                    iu2_btb_hist_q;

      wire [0:127]                  ex5_btb_hist_out;
      wire [0:1]                    ex5_btb_hist;
      wire [0:1]                    ex5_btb_repl_cnt;
      wire [0:1]                    ex5_btb_repl_new;
      wire [0:127]                  ex5_btb_repl_out;
      wire [0:127]                  ex5_btb_repl_d;
      wire [0:127]                  ex5_btb_repl_q;

      wire                          iu3_b_d;
      wire                          iu3_b_q;
      wire [62-`EFF_IFAR_WIDTH:61]   iu3_bd;
      wire [62-`EFF_IFAR_WIDTH:61]   iu3_li;

      wire                          iu3_act;
      wire [0:3]                    iu3_instr_act;

      wire [0:3]                    iu3_bh_update;
      wire [0:3]                    iu3_br_pred;

      wire [0:1]                    iu3_bh_d;
      wire [0:1]                    iu3_bh_q;
      wire                          iu3_lk_d;
      wire                          iu3_lk_q;
      wire                          iu3_aa_d;
      wire                          iu3_aa_q;

      wire                          iu3_bclr_d;
      wire                          iu3_bclr_q;
      wire                          iu3_bcctr_d;
      wire                          iu3_bcctr_q;

      wire [0:5]                    iu3_opcode_d;
      wire [0:5]                    iu3_opcode_q;
      wire [6:10]                   iu3_bo_d;
      wire [6:10]                   iu3_bo_q;
      wire [11:15]                  iu3_bi_d;
      wire [11:15]                  iu3_bi_q;
      wire                          iu3_getNIA;

      wire [6:29]                   iu3_tar_d;
      wire [6:29]                   iu3_tar_q;
      wire [62-`EFF_IFAR_WIDTH:61]   iu3_abs;

      wire [62-`EFF_IFAR_WIDTH:61]   iu3_ifar_d;
      wire [62-`EFF_IFAR_WIDTH:61]   iu3_ifar_q;
      wire [60:61]                  iu3_ifar_pri_d;
      wire [60:61]                  iu3_ifar_pri_q;

      wire [62-`EFF_IFAR_WIDTH:61]   iu3_off;
      wire [62-`EFF_IFAR_WIDTH:61]   iu3_bta;

      wire [62-`EFF_IFAR_WIDTH:61]   iu3_lnk_d;
      wire [62-`EFF_IFAR_WIDTH:61]   iu3_lnk_q;
      wire [62-`EFF_IFAR_WIDTH:61]   iu3_btb_d;
      wire [62-`EFF_IFAR_WIDTH:61]   iu3_btb_q;
      wire [62-`EFF_IFAR_WIDTH:61]   iu3_nfg_d;
      wire [62-`EFF_IFAR_WIDTH:61]   iu3_nfg_q;

      wire                          iu3_pr_val_d;
      wire                          iu3_pr_val_q;

      wire [0:3]                    iu3_val_d;
      wire [0:3]                    iu3_val_q;

      wire [0:60]                   iu3_0_instr_d;
      wire [0:60]                   iu3_0_instr_q;
      wire [0:60]                   iu3_1_instr_d;
      wire [0:60]                   iu3_1_instr_q;
      wire [0:60]                   iu3_2_instr_d;
      wire [0:60]                   iu3_2_instr_q;
      wire [0:60]                   iu3_3_instr_d;
      wire [0:60]                   iu3_3_instr_q;

      wire                          bp_ib_iu3_bta_val;

      wire                          iu3_flush;
      wire                          iu3_redirect;
      wire                          iu3_redirect_early;

      wire                          iu4_flush;

      wire [62-`EFF_IFAR_WIDTH:61]   iu4_redirect_ifar_d;
      wire [62-`EFF_IFAR_WIDTH:61]   iu4_redirect_ifar_q;
      wire                          iu4_redirect_d;
      wire                          iu4_redirect_q;
      wire                          iu4_redirect_act;

      wire                          iu4_act;

      wire                          iu4_ls_push_d;
      wire                          iu4_ls_push_q;
      wire                          iu4_ls_pop_d;
      wire                          iu4_ls_pop_q;

      wire [62-`EFF_IFAR_WIDTH:61]   iu4_ifar_d;
      wire [62-`EFF_IFAR_WIDTH:61]   iu4_ifar_q;

      wire [62-`EFF_IFAR_WIDTH:61]   ex5_ifar_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex5_ifar_q;
      wire                          ex5_val_d;
      wire                          ex5_val_q;
      wire                          ex5_bh_update_d;
      wire                          ex5_bh_update_q;
      wire [0:9]                    ex5_gshare_d;
      wire [0:9]                    ex5_gshare_q;
      wire [0:1]                    ex5_bh0_hist_d;
      wire [0:1]                    ex5_bh0_hist_q;
      wire [0:1]                    ex5_bh1_hist_d;
      wire [0:1]                    ex5_bh1_hist_q;
      wire [0:1]                    ex5_bh2_hist_d;
      wire [0:1]                    ex5_bh2_hist_q;
      wire                          ex5_br_pred_d;
      wire                          ex5_br_pred_q;
      wire                          ex5_br_taken_d;
      wire                          ex5_br_taken_q;
      wire                          ex5_bcctr_d;
      wire                          ex5_bcctr_q;
      wire                          ex5_bclr_d;
      wire                          ex5_bclr_q;
      wire                          ex5_getNIA_d;
      wire                          ex5_getNIA_q;
      wire                          ex5_group_d;
      wire                          ex5_group_q;
      wire                          ex5_lk_d;
      wire                          ex5_lk_q;
      wire [0:1]                    ex5_bh_d;
      wire [0:1]                    ex5_bh_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex5_bta_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex5_bta_q;
      wire [0:7]                    ex5_ls_ptr_d;
      wire [0:7]                    ex5_ls_ptr_q;
      wire [0:1]                    ex5_btb_hist_d;
      wire [0:1]                    ex5_btb_hist_q;
      wire                          ex5_btb_entry_d;
      wire                          ex5_btb_entry_q;

      wire                          ex5_ls_push_d;
      wire                          ex5_ls_push_q;
      wire                          ex5_ls_pop_d;
      wire                          ex5_ls_pop_q;

      wire                          ex6_ls_ptr_act;
      wire [0:7]                    ex6_ls_t0_ptr_d;
      wire [0:7]                    ex6_ls_t0_ptr_q;

      wire                          ex5_flush_d;
      wire                          ex5_flush_q;

      wire                          ex5_bh0_dec;
      wire                          ex5_bh0_inc;
      wire                          ex5_bh1_dec;
      wire                          ex5_bh1_inc;
      wire                          ex5_bh2_dec;
      wire                          ex5_bh2_inc;

      wire                          ex5_bh0_wr_en;
      wire                          ex5_bh1_wr_en;
      wire                          ex5_bh2_wr_en;

      wire [0:7]                    iu5_ls_t0_ptr_d;
      wire [0:7]                    iu5_ls_t0_ptr_q;
      wire [0:0]                    iu5_ls_ptr_act;

      wire                          iu4_ls_update;
      wire                          ex5_ls_update;
      wire                          ex5_repair;

      wire [62-`EFF_IFAR_WIDTH:61]   iu4_nia;
      wire [62-`EFF_IFAR_WIDTH:61]   ex5_nia;

      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t00_d;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t00_q;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t01_d;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t01_q;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t02_d;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t02_q;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t03_d;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t03_q;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t04_d;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t04_q;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t05_d;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t05_q;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t06_d;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t06_q;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t07_d;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ls_t07_q;
      wire [0:7]                    iu5_ls_t0_act;

      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t00_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t00_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t01_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t01_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t02_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t02_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t03_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t03_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t04_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t04_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t05_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t05_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t06_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t06_q;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t07_d;
      wire [62-`EFF_IFAR_WIDTH:61]   ex6_ls_t07_q;
      wire [0:7]                    ex6_ls_t0_act;

      wire                          br_iu_redirect_q;
      wire                          cp_flush_q;
      wire                          iu_flush_q;

      wire [0:17]                   br_iu_gshare_d;
      wire [0:17]                   br_iu_gshare_q;
      wire [0:7]                    br_iu_ls_ptr_d;
      wire [0:7]                    br_iu_ls_ptr_q;
      wire [62-`EFF_IFAR_WIDTH:61]  br_iu_ls_data_d;
      wire [62-`EFF_IFAR_WIDTH:61]  br_iu_ls_data_q;
      wire                          br_iu_ls_update_d;
      wire                          br_iu_ls_update_q;

      wire [0:31]                   xnop;

      wire                          tiup;
      wire                          tidn;

      wire                          pc_iu_func_sl_thold_1;
      wire                          pc_iu_func_sl_thold_0;
      wire                          pc_iu_func_sl_thold_0_b;
      wire                          pc_iu_sg_1;
      wire                          pc_iu_sg_0;
      wire                          force_t;

      wire [0:scan_right0]          siv0;
      wire [0:scan_right0]          sov0;

      wire [0:scan_right1]          siv1;
      wire [0:scan_right1]          sov1;

wire  iu0_val;
wire [0:1] iu3_gs_count_next;
wire [0:1] iu3_gs_count;
wire [0:5] iu3_gs_counts;
wire [0:1] iu3_gs_count0;
wire [0:1] iu3_gs_count1;
wire [0:1] iu3_gs_count2;
wire [0:1] iu3_gs_count3;
wire [0:2] iu3_gs_pos;
wire [0:1] cp_gs_count;
wire [0:1] cp_gs_count_d;
wire [0:1] cp_gs_count_q;
wire  cp_gs_taken;
wire  cp_gs_taken_d;
wire  cp_gs_taken_q;
wire  cp_gs_group;
wire [0:2] iu3_gs_pos_d;
wire [0:2] iu3_gs_pos_q;
wire [0:2] iu2_gs_pos_d;
wire [0:2] iu2_gs_pos_q;
wire [0:2] iu1_gs_pos_d;
wire [0:2] iu1_gs_pos_q;


wire [0:1] ex5_bh0_hist;
wire [0:1] ex5_bh1_hist;
wire [0:1] bcache_bh0_hist;
wire [0:1] bcache_bh1_hist;
wire [0:1] bcache_bh0_wr_data;
wire [0:1] bcache_bh1_wr_data;
wire [0:11] bcache_wr_addr;
wire [0:15] bcache_data_new;
wire [0:15] bcache_data0_d;
wire [0:15] bcache_data0_q;
wire [0:15] bcache_data1_d;
wire [0:15] bcache_data1_q;
wire [0:15] bcache_data2_d;
wire [0:15] bcache_data2_q;
wire [0:15] bcache_data3_d;
wire [0:15] bcache_data3_q;
wire [0:15] bcache_data4_d;
wire [0:15] bcache_data4_q;
wire [0:15] bcache_data5_d;
wire [0:15] bcache_data5_q;
wire [0:15] bcache_data6_d;
wire [0:15] bcache_data6_q;
wire [0:15] bcache_data7_d;
wire [0:15] bcache_data7_q;
wire [0:7] bcache_hit;
wire [0:7] bcache_shift;

      assign tiup = 1'b1;
      assign tidn = 1'b0;

      //-------------------------------------------------
      //-- config bits
      //-------------------------------------------------

      assign bp_config_d[0:5] = spr_bp_config[0:5];

      assign bp_config_d[6] = xu_iu_msr_de |
                              xu_iu_dbcr0_icmp |
	                      xu_iu_dbcr0_brt |
                              xu_iu_iac1_en |
                              xu_iu_iac2_en |
                              xu_iu_iac3_en |
                              xu_iu_iac4_en |
                              lq_iu_spr_dbcr3_ivc |
                              xu_iu_single_instr_mode |
                              spr_single_issue;


      assign bp_dy_en = bp_config_q[0];		//dynamic prediction enable     default = 1
      assign bp_st_en = bp_config_q[1];		//static prediction enable      default = 0
      assign bp_bt_en = bp_config_q[2];		//btb enable                    default = 1

      //fused branches enable default = 1
      assign fuse_en = bp_config_q[3] & (~bp_config_q[6]);		//disable compare/branch fusion when debug enable or single instruction mode

      assign bp_gs_mode[0:1] = bp_config_q[4:5];	//length of BHT2 gshare hash	00 = 0 bits (default), 01 = 2 bits, 10 = 6 bits


      //-----------------------------------------------
      // latched xu interface
      //-----------------------------------------------

      assign ex5_flush_d = cp_flush_q & iu_flush_q;

      assign ex5_ifar_d = cp_bp_ifar;
      assign ex5_val_d = cp_bp_val & (~cp_flush_q);
      assign ex5_bh0_hist_d = cp_bp_bh0_hist;
      assign ex5_bh1_hist_d = cp_bp_bh1_hist;
      assign ex5_bh2_hist_d = cp_bp_bh2_hist;
      assign ex5_br_pred_d = cp_bp_br_pred;
      assign ex5_br_taken_d = cp_bp_br_taken;
      assign ex5_bh_update_d = cp_bp_bh_update;
      assign ex5_gshare_d = cp_bp_gshare;
      assign ex5_bcctr_d = cp_bp_bcctr;
      assign ex5_bclr_d = cp_bp_bclr;
      assign ex5_getNIA_d = cp_bp_getNIA;
      assign ex5_group_d = cp_bp_group;
      assign ex5_lk_d = cp_bp_lk;
      assign ex5_bh_d = cp_bp_bh;
      assign ex5_bta_d = cp_bp_bta;
      assign ex5_btb_hist_d = cp_bp_btb_hist;
      assign ex5_btb_entry_d = cp_bp_btb_entry;

      assign ex5_ls_ptr_d[0] = cp_bp_ls_ptr[0:2] == 3'b000;
      assign ex5_ls_ptr_d[1] = cp_bp_ls_ptr[0:2] == 3'b001;
      assign ex5_ls_ptr_d[2] = cp_bp_ls_ptr[0:2] == 3'b010;
      assign ex5_ls_ptr_d[3] = cp_bp_ls_ptr[0:2] == 3'b011;
      assign ex5_ls_ptr_d[4] = cp_bp_ls_ptr[0:2] == 3'b100;
      assign ex5_ls_ptr_d[5] = cp_bp_ls_ptr[0:2] == 3'b101;
      assign ex5_ls_ptr_d[6] = cp_bp_ls_ptr[0:2] == 3'b110;
      assign ex5_ls_ptr_d[7] = cp_bp_ls_ptr[0:2] == 3'b111;

      //-----------------------------------------------
      // latched br interface
      //-----------------------------------------------

      assign br_iu_gshare_d = br_iu_gshare;
      assign br_iu_ls_data_d = br_iu_ls_data;
      assign br_iu_ls_update_d = br_iu_ls_update;

      assign br_iu_ls_ptr_d[0] = br_iu_ls_ptr[0:2] == 3'b000;
      assign br_iu_ls_ptr_d[1] = br_iu_ls_ptr[0:2] == 3'b001;
      assign br_iu_ls_ptr_d[2] = br_iu_ls_ptr[0:2] == 3'b010;
      assign br_iu_ls_ptr_d[3] = br_iu_ls_ptr[0:2] == 3'b011;
      assign br_iu_ls_ptr_d[4] = br_iu_ls_ptr[0:2] == 3'b100;
      assign br_iu_ls_ptr_d[5] = br_iu_ls_ptr[0:2] == 3'b101;
      assign br_iu_ls_ptr_d[6] = br_iu_ls_ptr[0:2] == 3'b110;
      assign br_iu_ls_ptr_d[7] = br_iu_ls_ptr[0:2] == 3'b111;

      //-----------------------------------------------
      // read branch history table
      //-----------------------------------------------

      assign iu0_bh0_rd_act = iu0_val;
      assign iu0_bh1_rd_act = iu0_val;
      assign iu0_bh2_rd_act = iu0_val;

      assign iu0_val = ic_bp_iu0_val & ~iu1_flush;

      assign iu0_bh_ti0gs0_rd_addr[0:9] = (ic_bp_iu0_ifar[50:59] ^ iu0_gshare0[0:9]);
      assign iu0_bh_ti0gs1_rd_addr[0:9] = (ic_bp_iu0_ifar[50:59] ^ iu0_gshare1[0:9]);
      assign iu0_bh_ti0gs2_rd_addr[0:8] = (ic_bp_iu0_ifar[51:59] ^ iu0_gshare2[0:8]);

      assign iu0_bh0_rd_addr[0:9] = iu0_bh_ti0gs0_rd_addr[0:9];
      assign iu0_bh1_rd_addr[0:9] = iu0_bh_ti0gs1_rd_addr[0:9];
      assign iu0_bh2_rd_addr[0:8] = iu0_bh_ti0gs2_rd_addr[0:8];

      assign iu0_gshare0[0:9] = gshare_q[0:9];
      assign iu0_gshare1[0:9] = gshare_q[0:9];

      assign iu0_gshare2[0:8] = bp_gs_mode[0:1] == 2'b10 ? {gshare_q[0:5], 3'b000    } :
	                        bp_gs_mode[0:1] == 2'b01 ? {gshare_q[0:1], 7'b0000000} :
                                                                           9'b000000000;

      assign iu1_gshare_d[0:9] = gshare_q[0:9];
      assign iu2_gshare_d[0:9] = iu1_gshare_q[0:9];

      //-----------------------------------------------
      // write branch history table
      //-----------------------------------------------

      assign ex5_bh0_wr_act = ({4{ex5_bh0_wr_en}} & ex5_bh_wr_act);
      assign ex5_bh1_wr_act = ({4{ex5_bh1_wr_en}} & ex5_bh_wr_act);
      assign ex5_bh2_wr_act = ({4{ex5_bh2_wr_en}} & ex5_bh_wr_act);

      assign ex5_bh_ti0gs0_wr_addr[0:9] = (ex5_ifar_q[50:59] ^ ex5_gshare0[0:9]);
      assign ex5_bh_ti0gs1_wr_addr[0:9] = (ex5_ifar_q[50:59] ^ ex5_gshare1[0:9]);
      assign ex5_bh_ti0gs2_wr_addr[0:8] = (ex5_ifar_q[51:59] ^ ex5_gshare2[0:8]);

      assign ex5_bh0_wr_addr[0:9] = ex5_bh_ti0gs0_wr_addr[0:9];
      assign ex5_bh1_wr_addr[0:9] = ex5_bh_ti0gs1_wr_addr[0:9];
      assign ex5_bh2_wr_addr[0:8] = ex5_bh_ti0gs2_wr_addr[0:8];

      assign ex5_gshare0[0:9] = ex5_gshare_q[0:9];
      assign ex5_gshare1[0:9] = ex5_gshare_q[0:9];

      assign ex5_gshare2[0:8] = bp_gs_mode[0:1] == 2'b10 ? {ex5_gshare_q[0:5], 3'b000    } :
	                        bp_gs_mode[0:1] == 2'b01 ? {ex5_gshare_q[0:1], 7'b0000000} :
                                                                               9'b000000000;


      //-----------------------------------------------
      // update branch hitstory
      //-----------------------------------------------

/*
      assign ex5_bh_wr_act[0] = ex5_ifar_q[60:61] == 2'b00;
      assign ex5_bh_wr_act[1] = ex5_ifar_q[60:61] == 2'b01;
      assign ex5_bh_wr_act[2] = ex5_ifar_q[60:61] == 2'b10;
      assign ex5_bh_wr_act[3] = ex5_ifar_q[60:61] == 2'b11;

      assign ex5_bh0_dec = ex5_br_taken_q == 1'b0 & ex5_bh0_hist_q[0:1] != 2'b00;
      assign ex5_bh1_dec = ex5_br_taken_q == 1'b0 & ex5_bh1_hist_q[0:1] != 2'b00;
      assign ex5_bh2_dec = ex5_br_taken_q == 1'b0 & ex5_bh2_hist_q[0] != 1'b0;

      assign ex5_bh0_inc = ex5_br_taken_q == 1'b1 & ex5_bh0_hist_q[0:1] != 2'b11;
      assign ex5_bh1_inc = ex5_br_taken_q == 1'b1 & ex5_bh1_hist_q[0:1] != 2'b11;
      assign ex5_bh2_inc = ex5_br_taken_q == 1'b1 & ex5_bh2_hist_q[0] != 1'b1;

      assign ex5_bh0_wr_data[0:1] = (ex5_bh0_inc == 1'b1) ? ex5_bh0_hist_q[0:1] + 2'b01 :
                                    (ex5_bh0_dec == 1'b1) ? ex5_bh0_hist_q[0:1] - 2'b01 :
                                    ex5_bh0_hist_q[0:1];
      assign ex5_bh1_wr_data[0:1] = (ex5_bh1_inc == 1'b1) ? ex5_bh1_hist_q[0:1] + 2'b01 :
                                    (ex5_bh1_dec == 1'b1) ? ex5_bh1_hist_q[0:1] - 2'b01 :
                                    ex5_bh1_hist_q[0:1];
      assign ex5_bh2_wr_data = ex5_br_taken_q;

      assign ex5_bh0_wr_en = ex5_val_q == 1'b1 & ex5_bh_update_q == 1'b1 & ex5_bh2_hist_q[0] == 1'b0;
      assign ex5_bh1_wr_en = ex5_val_q == 1'b1 & ex5_bh_update_q == 1'b1 & ex5_bh2_hist_q[0] == 1'b1;
      assign ex5_bh2_wr_en = ex5_val_q == 1'b1 & ex5_bh_update_q == 1'b1;
*/

      assign ex5_bh_wr_act[0] = ex5_ifar_q[60:61] == 2'b00;
      assign ex5_bh_wr_act[1] = ex5_ifar_q[60:61] == 2'b01;
      assign ex5_bh_wr_act[2] = ex5_ifar_q[60:61] == 2'b10;
      assign ex5_bh_wr_act[3] = ex5_ifar_q[60:61] == 2'b11;

      assign ex5_bh0_dec = ex5_br_taken_q == 1'b0 & ex5_bh0_hist[0:1] != 2'b00 & ex5_bh2_hist_q[0] == 1'b0;
      assign ex5_bh1_dec = ex5_br_taken_q == 1'b0 & ex5_bh1_hist[0:1] != 2'b00 & ex5_bh2_hist_q[0] == 1'b1;
      assign ex5_bh2_dec = ex5_br_taken_q == 1'b0 & ex5_bh2_hist_q[0] != 1'b0;

      assign ex5_bh0_inc = ex5_br_taken_q == 1'b1 & ex5_bh0_hist[0:1] != 2'b11 & ex5_bh2_hist_q[0] == 1'b0;
      assign ex5_bh1_inc = ex5_br_taken_q == 1'b1 & ex5_bh1_hist[0:1] != 2'b11 & ex5_bh2_hist_q[0] == 1'b1;
      assign ex5_bh2_inc = ex5_br_taken_q == 1'b1 & ex5_bh2_hist_q[0] != 1'b1;

      assign bcache_bh0_wr_data[0:1] = (ex5_bh0_inc == 1'b1) ? ex5_bh0_hist[0:1] + 2'b01 :
                                       (ex5_bh0_dec == 1'b1) ? ex5_bh0_hist[0:1] - 2'b01 :
                                        ex5_bh0_hist[0:1];
      assign bcache_bh1_wr_data[0:1] = (ex5_bh1_inc == 1'b1) ? ex5_bh1_hist[0:1] + 2'b01 :
                                       (ex5_bh1_dec == 1'b1) ? ex5_bh1_hist[0:1] - 2'b01 :
                                        ex5_bh1_hist[0:1];
      assign ex5_bh2_wr_data         = ex5_br_taken_q;

      assign ex5_bh0_wr_en = ex5_val_q == 1'b1 & ex5_bh_update_q == 1'b1 & ex5_bh2_hist_q[0] == 1'b0;
      assign ex5_bh1_wr_en = ex5_val_q == 1'b1 & ex5_bh_update_q == 1'b1 & ex5_bh2_hist_q[0] == 1'b1;
      assign ex5_bh2_wr_en = ex5_val_q == 1'b1 & ex5_bh_update_q == 1'b1;


      //-----------------------------------------------
      // recent branch history cache
      //----------------------------------------------

      assign ex5_bh0_hist = |(bcache_hit[0:7]) ? bcache_bh0_hist : ex5_bh0_hist_q;
      assign ex5_bh1_hist = |(bcache_hit[0:7]) ? bcache_bh1_hist : ex5_bh1_hist_q;

      assign ex5_bh0_wr_data = bcache_bh0_wr_data;
      assign ex5_bh1_wr_data = bcache_bh1_wr_data;

      assign bcache_wr_addr = {ex5_bh_ti0gs0_wr_addr, ex5_ifar_q[60:61]};

      //branch cache:  bht_index[0:9], bht0_hist[0:1], bht1_hist[0:1]
      assign bcache_data_new[0:15] = {bcache_wr_addr[0:11], bcache_bh0_wr_data[0:1], bcache_bh1_wr_data[0:1]};

      assign bcache_data0_d = bcache_shift[0] ? bcache_data1_q  :
	                                        bcache_data0_q  ;

      assign bcache_data1_d = bcache_shift[1] ? bcache_data2_q  :
	                                        bcache_data1_q  ;

      assign bcache_data2_d = bcache_shift[2] ? bcache_data3_q  :
	                                        bcache_data2_q  ;

      assign bcache_data3_d = bcache_shift[3] ? bcache_data4_q  :
	                                        bcache_data3_q  ;

      assign bcache_data4_d = bcache_shift[4] ? bcache_data5_q  :
	                                        bcache_data4_q  ;

      assign bcache_data5_d = bcache_shift[5] ? bcache_data6_q  :
	                                        bcache_data5_q  ;

      assign bcache_data6_d = bcache_shift[6] ? bcache_data7_q  :
	                                        bcache_data6_q  ;

      assign bcache_data7_d = bcache_shift[7] ? bcache_data_new :
	                                        bcache_data7_q  ;


      assign bcache_hit[0] = ex5_val_q & ex5_bh_update_q & (bcache_data0_q[0:11] == bcache_data_new[0:11]);
      assign bcache_hit[1] = ex5_val_q & ex5_bh_update_q & (bcache_data1_q[0:11] == bcache_data_new[0:11]);
      assign bcache_hit[2] = ex5_val_q & ex5_bh_update_q & (bcache_data2_q[0:11] == bcache_data_new[0:11]);
      assign bcache_hit[3] = ex5_val_q & ex5_bh_update_q & (bcache_data3_q[0:11] == bcache_data_new[0:11]);
      assign bcache_hit[4] = ex5_val_q & ex5_bh_update_q & (bcache_data4_q[0:11] == bcache_data_new[0:11]);
      assign bcache_hit[5] = ex5_val_q & ex5_bh_update_q & (bcache_data5_q[0:11] == bcache_data_new[0:11]);
      assign bcache_hit[6] = ex5_val_q & ex5_bh_update_q & (bcache_data6_q[0:11] == bcache_data_new[0:11]);
      assign bcache_hit[7] = ex5_val_q & ex5_bh_update_q & (bcache_data7_q[0:11] == bcache_data_new[0:11]);

      assign bcache_shift[0] = ex5_val_q & ex5_bh_update_q & ~(|(bcache_hit[1:7]));
      assign bcache_shift[1] = ex5_val_q & ex5_bh_update_q & ~(|(bcache_hit[2:7]));
      assign bcache_shift[2] = ex5_val_q & ex5_bh_update_q & ~(|(bcache_hit[3:7]));
      assign bcache_shift[3] = ex5_val_q & ex5_bh_update_q & ~(|(bcache_hit[4:7]));
      assign bcache_shift[4] = ex5_val_q & ex5_bh_update_q & ~(|(bcache_hit[5:7]));
      assign bcache_shift[5] = ex5_val_q & ex5_bh_update_q & ~(|(bcache_hit[6:7]));
      assign bcache_shift[6] = ex5_val_q & ex5_bh_update_q & ~(  bcache_hit[7]   );
      assign bcache_shift[7] = ex5_val_q & ex5_bh_update_q;

      assign bcache_bh0_hist = bcache_hit[0] ? bcache_data0_q[12:13] :
	                       bcache_hit[1] ? bcache_data1_q[12:13] :
	                       bcache_hit[2] ? bcache_data2_q[12:13] :
	                       bcache_hit[3] ? bcache_data3_q[12:13] :
	                       bcache_hit[4] ? bcache_data4_q[12:13] :
	                       bcache_hit[5] ? bcache_data5_q[12:13] :
	                       bcache_hit[6] ? bcache_data6_q[12:13] :
	                       bcache_hit[7] ? bcache_data7_q[12:13] :
                                                               2'b00 ;

      assign bcache_bh1_hist = bcache_hit[0] ? bcache_data0_q[14:15] :
	                       bcache_hit[1] ? bcache_data1_q[14:15] :
	                       bcache_hit[2] ? bcache_data2_q[14:15] :
	                       bcache_hit[3] ? bcache_data3_q[14:15] :
	                       bcache_hit[4] ? bcache_data4_q[14:15] :
	                       bcache_hit[5] ? bcache_data5_q[14:15] :
	                       bcache_hit[6] ? bcache_data6_q[14:15] :
	                       bcache_hit[7] ? bcache_data7_q[14:15] :
                                                               2'b00 ;


      //-----------------------------------------------
      // update global history
      //-----------------------------------------------

      assign gshare_shift0_d[0:4] = (ex5_repair & cp_gs_count_d[0:1] == 2'b00)          ? 5'b10000 :
                                    (ex5_repair & cp_gs_count_d[0:1] == 2'b01)          ? 5'b01000 :
                                    (ex5_repair & cp_gs_count_d[0:1] == 2'b10)          ? 5'b00100 :
                                    (ex5_repair & cp_gs_count_d[0:1] == 2'b11)          ? 5'b00010 :
                                    (br_iu_redirect_q & br_iu_gshare_q[16:17] == 2'b00) ? 5'b10000 :
                                    (br_iu_redirect_q & br_iu_gshare_q[16:17] == 2'b01) ? 5'b01000 :
                                    (br_iu_redirect_q & br_iu_gshare_q[16:17] == 2'b10) ? 5'b00100 :
				    (br_iu_redirect_q & br_iu_gshare_q[16:17] == 2'b11) ? 5'b00010 :
                                    (iu3_val_q[0])                                      ? 5'b10000 :
				     gshare_shift0_q[0:4];

      assign gshare_shift1[0:4] = ((iu3_val_q[0] & iu3_bh_update[0]) == 1'b1) ? {1'b0, gshare_shift0_q[0:3]} :
				  gshare_shift0_q[0:4];
      assign gshare_shift2[0:4] = ((iu3_val_q[1] & iu3_bh_update[1]) == 1'b1) ? {1'b0, gshare_shift1[0:3]} :
                                  gshare_shift1[0:4];
      assign gshare_shift3[0:4] = ((iu3_val_q[2] & iu3_bh_update[2]) == 1'b1) ? {1'b0, gshare_shift2[0:3]} :
                                  gshare_shift2[0:4];
      assign gshare_shift4[0:4] = ((iu3_val_q[3] & iu3_bh_update[3]) == 1'b1) ? {1'b0, gshare_shift3[0:3]} :
                                  gshare_shift3[0:4];

      assign gshare_shift = ({5{~iu3_flush}} & gshare_shift4);
      assign gshare_taken = |(iu3_val_q[0:3] & iu3_bh_update[0:3] & iu3_br_pred[0:3]);


      //need to make pipeline gshares the NEXT CYCLE value to give me a pre-shifted restore point (iu3 uses iu2 to assume shift)
      //taken branches per fetch group
      assign gshare_d[0:2] =    (ex5_repair) ? cp_gshare_d[0:2] :
                                (br_iu_redirect_q) ? br_iu_gshare_q[0:2] :
	                        (iu3_redirect) ? ({iu3_pr_val_q, iu2_gshare_q[1:2]}) :
	                        (iu2_redirect) ? ({1'b1, iu1_gshare_q[1:2]}) :
                                (iu0_val) ? ({1'b0, gshare_q[0:1]}) :
                                gshare_q[0:2];

      //taken branches
      assign gshare_d[3:9] =    (ex5_repair == 1'b1) ? cp_gshare_d[3:9] :
                                (br_iu_redirect_q == 1'b1) ? br_iu_gshare_q[3:9] :
	                        (iu3_redirect) ? ({iu2_gshare_q[3:9]}) :
	                        (iu2_redirect) ? ({iu1_gshare_q[3:9]}) :
	                        ((iu0_val) & (iu3_gs_count_next[0:1] == 2'b11))  ? ({gshare_q[2], 2'b00, gshare_q[3:6]}) :
	                        ((iu0_val) & (iu3_gs_count_next[0:1] == 2'b10))  ? ({gshare_q[2], 1'b0,  gshare_q[3:7]}) :
	                        ((iu0_val) & (iu3_gs_count_next[0:1] == 2'b01))  ? ({gshare_q[2],        gshare_q[3:8]}) :
	                        ((iu0_val) & (iu3_gs_count_next[0:1] == 2'b00))  ? ({                    gshare_q[3:9]}) :
                                gshare_q[3:9];




      //branches per fetch group
      assign iu3_gs_count_next[0:1] = (iu3_gs_pos[2]) ? iu3_gs_count[0:1] : gshare_q[14:15];

      assign iu3_gs_count[0:1] = (gshare_shift[4] == 1'b1) ? 2'b11 :
                                 (gshare_shift[3] == 1'b1) ? 2'b11 :
                                 (gshare_shift[2] == 1'b1) ? 2'b10 :
                                 (gshare_shift[1] == 1'b1) ? 2'b01 :
                                                             2'b00 ;

//if a CURRENT instruction is in a given position, the OLD/RECOVERY point is pushed forward by that amount
      assign iu3_gs_counts[0:1] = (iu3_gs_pos[0]) ? (gshare_q[12:13]) :
                                  (iu3_gs_pos[1]) ? (gshare_q[14:15]) :
                                  (iu3_gs_pos[2]) ? (gshare_q[10:11]) :
                                                                  2'b00 ;

      assign iu3_gs_counts[2:3] = (iu3_gs_pos[0]) ? (gshare_q[14:15]) :
                                  (iu3_gs_pos[1]) ? (gshare_q[10:11]) :
                                  (iu3_gs_pos[2]) ? (gshare_q[12:13]) :
                                                                  2'b00 ;

      assign iu3_gs_counts[4:5] = (iu3_gs_pos[0]) ? (gshare_q[10:11]) :
                                  (iu3_gs_pos[1]) ? (gshare_q[12:13]) :
                                  (iu3_gs_pos[2]) ? (gshare_q[14:15]) :
                                                                  2'b00 ;


      //track position of current instruction in gshare history
      assign iu1_gs_pos_d[0:2] = (iu0_val) ? 3'b100 :
                                                   3'b000 ;
      assign iu2_gs_pos_d[0:2] = (iu0_val) ? ({1'b0, iu1_gs_pos_q[0:1]}) :
                                                           iu1_gs_pos_q[0:2];
      assign iu3_gs_pos_d[0:2] = (iu2_redirect) ? 3'b100 :
                                 (iu0_val) ? ({1'b0, iu2_gs_pos_q[0:1]}) :
                                                           iu2_gs_pos_q[0:2];

      assign iu3_gs_pos[0:2] = iu3_gs_pos_q[0:2] & {3{iu3_val_q[0] & ~iu3_flush}};

      assign gshare_d[10:15] = (ex5_repair) ? cp_gshare_d[10:15] :
                                  (br_iu_redirect_q) ? br_iu_gshare_q[10:15] :
	                          (iu3_redirect & iu3_gs_pos[0]) ? ({iu3_gs_count[0:1], gshare_q[12:15]}) :
	                          (iu3_redirect & iu3_gs_pos[1]) ? ({iu3_gs_count[0:1], gshare_q[14:15], gshare_q[10:11]}) :
	                          (iu3_redirect & iu3_gs_pos[2]) ? ({iu3_gs_count[0:1], gshare_q[10:13]}) :
	                          (iu2_redirect & iu3_gs_pos[1]) ? ({gshare_q[10:11], iu3_gs_count[0:1], gshare_q[14:15]}) :
	                          (iu2_redirect & iu3_gs_pos[2]) ? ({gshare_q[12:13], iu3_gs_count[0:1], gshare_q[10:11]}) :
	                          (iu2_redirect & iu2_gs_pos_q[0]) ? ({gshare_q[10:15]}) :
	                          (iu2_redirect & iu2_gs_pos_q[1]) ? ({gshare_q[12:15], gshare_q[10:11]}) :
	                          (iu0_val & iu3_gs_pos[0]) ? ({gshare_q[14:15], iu3_gs_count[0:1], gshare_q[12:13]}) :
	                          (iu0_val & iu3_gs_pos[1]) ? ({gshare_q[14:15], gshare_q[10:11], iu3_gs_count[0:1]}) :
	                          (iu0_val & iu3_gs_pos[2]) ? ({iu3_gs_count[0:1], gshare_q[10:13]}) :
	                          (iu3_gs_pos[0]) ? ({iu3_gs_count[0:1], gshare_q[12:15]}) :
	                          (iu3_gs_pos[1]) ? ({gshare_q[10:11], iu3_gs_count[0:1], gshare_q[14:15]}) :
	                          (iu3_gs_pos[2]) ? ({gshare_q[10:13], iu3_gs_count[0:1]}) :
	                          (iu0_val) ? ({gshare_q[14:15], gshare_q[10:13]}) :
                                  gshare_q[10:15];



      //replace iu3_gshare[10:11] per instruction with the following counts for outgoing instructions.
      assign iu3_gs_count0[0:1] = (gshare_shift1[1] == 1'b1) ? 2'b01 :
                                                               2'b00 ;

      assign iu3_gs_count1[0:1] = (gshare_shift2[2] == 1'b1) ? 2'b10 :
                                  (gshare_shift2[1] == 1'b1) ? 2'b01 :
                                                               2'b00 ;

      assign iu3_gs_count2[0:1] = (gshare_shift3[3] == 1'b1) ? 2'b11 :
                                  (gshare_shift3[2] == 1'b1) ? 2'b10 :
                                  (gshare_shift3[1] == 1'b1) ? 2'b01 :
                                                               2'b00 ;

      assign iu3_gs_count3[0:1] = (gshare_shift4[4] == 1'b1) ? 2'b11 :
                                  (gshare_shift4[3] == 1'b1) ? 2'b11 :
                                  (gshare_shift4[2] == 1'b1) ? 2'b10 :
                                  (gshare_shift4[1] == 1'b1) ? 2'b01 :
                                                               2'b00 ;




      assign gshare_act[0] = tiup;


      //completion time repair
      assign cp_gshare_shift = ex5_val_q & ex5_bh_update_q;
      assign cp_gshare_taken = ex5_val_q & ex5_br_taken_q;

      assign cp_gshare_d[0:2] = (cp_gs_group) ? ({cp_gs_taken, cp_gshare_q[0:1]}) :
	                        cp_gshare_q[0:2];

      assign cp_gshare_d[3:9] = (cp_gs_group & cp_gshare_q[14:15] == 2'b11) ? ({cp_gshare_q[2], 2'b00, cp_gshare_q[6:9]}) :
	                        (cp_gs_group & cp_gshare_q[14:15] == 2'b10) ? ({cp_gshare_q[2], 1'b0 , cp_gshare_q[5:9]}) :
	                        (cp_gs_group & cp_gshare_q[14:15] == 2'b01) ? ({cp_gshare_q[2]       , cp_gshare_q[4:9]}) :
	                        (cp_gs_group & cp_gshare_q[14:15] == 2'b00) ? ({                       cp_gshare_q[3:9]}) :
	                                                                                               cp_gshare_q[3:9]   ;

      assign cp_gshare_d[10:15] = (cp_gs_group) ? ({cp_gs_count[0:1], cp_gshare_q[10:13]}) :
	                          cp_gshare_q[10:15];

      assign cp_gs_group        = cp_gshare_taken | ex5_group_q;

      assign cp_gs_count[0:1]   = (cp_gs_count_q[0:1] == 2'b11) ? 2'b11 :
                                  (cp_gshare_shift) ? cp_gs_count_q[0:1] + 2'b01 :
				                      cp_gs_count_q[0:1];

      assign cp_gs_count_d[0:1] = (cp_gs_group) ? 2'b00 :
				   cp_gs_count[0:1];

      assign cp_gs_taken = cp_gshare_taken | cp_gs_taken_q;

      assign cp_gs_taken_d = (cp_gs_group) ? 1'b0 :
		              cp_gs_taken;



      //-----------------------------------------------
      // rotate branch history to match instructions
      //-----------------------------------------------

      assign iu2_0_bh0_hist = (ic_bp_iu2_ifar[60:61] == 2'b11) ? iu2_3_bh0_rd_data[0:1] :
                              (ic_bp_iu2_ifar[60:61] == 2'b10) ? iu2_2_bh0_rd_data[0:1] :
                              (ic_bp_iu2_ifar[60:61] == 2'b01) ? iu2_1_bh0_rd_data[0:1] :
                              iu2_0_bh0_rd_data[0:1];
      assign iu2_1_bh0_hist = (ic_bp_iu2_ifar[60:61] == 2'b10) ? iu2_3_bh0_rd_data[0:1] :
                              (ic_bp_iu2_ifar[60:61] == 2'b01) ? iu2_2_bh0_rd_data[0:1] :
                              iu2_1_bh0_rd_data[0:1];
      assign iu2_2_bh0_hist = (ic_bp_iu2_ifar[60:61] == 2'b01) ? iu2_3_bh0_rd_data[0:1] :
                              iu2_2_bh0_rd_data[0:1];
      assign iu2_3_bh0_hist = iu2_3_bh0_rd_data[0:1];

      assign iu2_0_bh1_hist = (ic_bp_iu2_ifar[60:61] == 2'b11) ? iu2_3_bh1_rd_data[0:1] :
                              (ic_bp_iu2_ifar[60:61] == 2'b10) ? iu2_2_bh1_rd_data[0:1] :
                              (ic_bp_iu2_ifar[60:61] == 2'b01) ? iu2_1_bh1_rd_data[0:1] :
                              iu2_0_bh1_rd_data[0:1];
      assign iu2_1_bh1_hist = (ic_bp_iu2_ifar[60:61] == 2'b10) ? iu2_3_bh1_rd_data[0:1] :
                              (ic_bp_iu2_ifar[60:61] == 2'b01) ? iu2_2_bh1_rd_data[0:1] :
                              iu2_1_bh1_rd_data[0:1];
      assign iu2_2_bh1_hist = (ic_bp_iu2_ifar[60:61] == 2'b01) ? iu2_3_bh1_rd_data[0:1] :
                              iu2_2_bh1_rd_data[0:1];
      assign iu2_3_bh1_hist = iu2_3_bh1_rd_data[0:1];

      assign iu2_0_bh2_hist = (ic_bp_iu2_ifar[60:61] == 2'b11) ? iu2_3_bh2_rd_data  :
	                      (ic_bp_iu2_ifar[60:61] == 2'b10) ? iu2_2_bh2_rd_data  :
			      (ic_bp_iu2_ifar[60:61] == 2'b01) ? iu2_1_bh2_rd_data :
			      iu2_0_bh2_rd_data;
      assign iu2_1_bh2_hist = (ic_bp_iu2_ifar[60:61] == 2'b10) ? iu2_3_bh2_rd_data :
                              (ic_bp_iu2_ifar[60:61] == 2'b01) ? iu2_2_bh2_rd_data :
                              iu2_1_bh2_rd_data;
      assign iu2_2_bh2_hist = (ic_bp_iu2_ifar[60:61] == 2'b01) ? iu2_3_bh2_rd_data :
                              iu2_2_bh2_rd_data;
      assign iu2_3_bh2_hist = iu2_3_bh2_rd_data;

      //-----------------------------------------------
      // bht selection
      //-----------------------------------------------

      assign iu2_0_bh_pred = (iu2_0_bh0_hist[0] & iu2_0_bh2_hist == 1'b0) | (iu2_0_bh1_hist[0] & iu2_0_bh2_hist == 1'b1);

      assign iu2_1_bh_pred = (iu2_1_bh0_hist[0] & iu2_1_bh2_hist == 1'b0) | (iu2_1_bh1_hist[0] & iu2_1_bh2_hist == 1'b1);

      assign iu2_2_bh_pred = (iu2_2_bh0_hist[0] & iu2_2_bh2_hist == 1'b0) | (iu2_2_bh1_hist[0] & iu2_2_bh2_hist == 1'b1);

      assign iu2_3_bh_pred = (iu2_3_bh0_hist[0] & iu2_3_bh2_hist == 1'b0) | (iu2_3_bh1_hist[0] & iu2_3_bh2_hist == 1'b1);

      //-----------------------------------------------
      // predict branches
      //-----------------------------------------------

      assign iu2_uc[0:3] = ({ic_bp_iu2_0_instr[33], ic_bp_iu2_1_instr[33], ic_bp_iu2_2_instr[33], ic_bp_iu2_3_instr[33]}) & (~({ic_bp_iu2_0_instr[32], ic_bp_iu2_1_instr[32], ic_bp_iu2_2_instr[32], ic_bp_iu2_3_instr[32]}));

      assign iu2_fuse[0:3] = ({4{fuse_en}} & ({ic_bp_iu2_0_instr[34], ic_bp_iu2_1_instr[34], ic_bp_iu2_2_instr[34], ic_bp_iu2_3_instr[34]}) &
                                             (~{ic_bp_iu2_0_instr[32], ic_bp_iu2_1_instr[32], ic_bp_iu2_2_instr[32], ic_bp_iu2_3_instr[32]}));

      assign iu2_br_val[0:3] = {ic_bp_iu2_0_instr[32], ic_bp_iu2_1_instr[32], ic_bp_iu2_2_instr[32], ic_bp_iu2_3_instr[32]};
      assign iu2_br_hard[0:3] = {ic_bp_iu2_0_instr[33], ic_bp_iu2_1_instr[33], ic_bp_iu2_2_instr[33], ic_bp_iu2_3_instr[33]};
      assign iu2_hint_val[0:3] = {ic_bp_iu2_0_instr[34], ic_bp_iu2_1_instr[34], ic_bp_iu2_2_instr[34], ic_bp_iu2_3_instr[34]};
      assign iu2_hint[0:3] = {ic_bp_iu2_0_instr[35], ic_bp_iu2_1_instr[35], ic_bp_iu2_2_instr[35], ic_bp_iu2_3_instr[35]};

      assign iu2_bh_pred[0:3] = {iu2_0_bh_pred, iu2_1_bh_pred, iu2_2_bh_pred, iu2_3_bh_pred};

      assign iu2_br_dynamic[0:3] = ({4{bp_dy_en}} & ~(iu2_br_hard[0:3] | iu2_hint_val[0:3]));
      assign iu2_br_static[0:3]  = ({4{bp_st_en & ~bp_dy_en}} & ~(iu2_br_hard[0:3] | iu2_hint_val[0:3]));

      assign iu2_br_pred[0:3] = ic_bp_iu2_val[0:3] & iu2_br_val[0:3] & (iu2_br_hard[0:3] | (iu2_hint_val[0:3] & iu2_hint[0:3]) | (iu2_br_dynamic[0:3] & iu2_bh_pred[0:3]) | (iu2_br_static[0:3]));

      assign iu2_bh_update[0:3] = iu2_br_val[0:3] & iu2_br_dynamic[0:3];

      //-----------------------------------------------
      // prioritize branch instructions
      //-----------------------------------------------

      assign iu2_instr_pri[0:33] = (iu2_br_pred[0] == 1'b1) ? ic_bp_iu2_0_instr[0:33] :
                                   (iu2_br_pred[1] == 1'b1) ? ic_bp_iu2_1_instr[0:33] :
                                   (iu2_br_pred[2] == 1'b1) ? ic_bp_iu2_2_instr[0:33] :
                                   ic_bp_iu2_3_instr[0:33];

      assign iu3_ifar_pri_d[60:61] = (iu2_br_pred[0] == 1'b1) ? ic_bp_iu2_ifar[60:61] :
                                     (iu2_br_pred[1] == 1'b1) ? ic_bp_iu2_ifar[60:61] + 2'b01 :
                                     (iu2_br_pred[2] == 1'b1) ? ic_bp_iu2_ifar[60:61] + 2'b10 :
                                     ic_bp_iu2_ifar[60:61] + 2'b11;

      assign iu3_bclr_d = (iu2_br_pred[0] == 1'b1) ? ic_bp_iu2_0_instr[0:5] == 6'b010011 & ic_bp_iu2_0_instr[21:30] == 10'b0000010000 :
                          (iu2_br_pred[1] == 1'b1) ? ic_bp_iu2_1_instr[0:5] == 6'b010011 & ic_bp_iu2_1_instr[21:30] == 10'b0000010000 :
                          (iu2_br_pred[2] == 1'b1) ? ic_bp_iu2_2_instr[0:5] == 6'b010011 & ic_bp_iu2_2_instr[21:30] == 10'b0000010000 :
                          ic_bp_iu2_3_instr[0:5] == 6'b010011 & ic_bp_iu2_3_instr[21:30] == 10'b0000010000;

      assign iu3_bcctr_d = (iu2_br_pred[0] == 1'b1) ? (ic_bp_iu2_0_instr[0:5] == 6'b010011 & ic_bp_iu2_0_instr[21:30] == 10'b1000110000) | (ic_bp_iu2_0_instr[0:5] == 6'b010011 & ic_bp_iu2_0_instr[21:30] == 10'b1000010000) : 		//bctar
                           (iu2_br_pred[1] == 1'b1) ? (ic_bp_iu2_1_instr[0:5] == 6'b010011 & ic_bp_iu2_1_instr[21:30] == 10'b1000110000) | (ic_bp_iu2_1_instr[0:5] == 6'b010011 & ic_bp_iu2_1_instr[21:30] == 10'b1000010000) : 		//bctar
                           (iu2_br_pred[2] == 1'b1) ? (ic_bp_iu2_2_instr[0:5] == 6'b010011 & ic_bp_iu2_2_instr[21:30] == 10'b1000110000) | (ic_bp_iu2_2_instr[0:5] == 6'b010011 & ic_bp_iu2_2_instr[21:30] == 10'b1000010000) : 		//bctar
                           (ic_bp_iu2_3_instr[0:5] == 6'b010011 & ic_bp_iu2_3_instr[21:30] == 10'b1000110000) | (ic_bp_iu2_3_instr[0:5] == 6'b010011 & ic_bp_iu2_3_instr[21:30] == 10'b1000010000);		//bctar

      //-----------------------------------------------
      // decode priority branch instruction
      //-----------------------------------------------

      assign iu3_b_d = iu2_instr_pri[33];
      assign iu3_tar_d[6:29] = iu2_instr_pri[6:29];

      generate
         begin : xhdl1
            genvar                        i;
            for (i = 62 - `EFF_IFAR_WIDTH; i <= 61; i = i + 1)
            begin : sign_extend
               if (i < 48)
               begin : bd0
                  assign iu3_bd[i] = iu3_tar_q[16];
               end
            if (i > 47)
            begin : bd1
               assign iu3_bd[i] = iu3_tar_q[i - 32];
            end
         if (i < 38)
         begin : li0
            assign iu3_li[i] = iu3_tar_q[6];
         end
      if (i > 37)
      begin : li1
         assign iu3_li[i] = iu3_tar_q[i - 32];
      end
end
end
endgenerate

assign iu3_bh_d[0:1] = iu2_instr_pri[19:20];
assign iu3_lk_d = iu2_instr_pri[31];
assign iu3_aa_d = iu2_instr_pri[30];

assign iu3_pr_val_d = |(iu2_br_pred[0:3]) & (~iu2_flush) & (~ic_bp_iu2_error[0]);

// bcl 20,31,$+4 is special case.  not a subroutine call, used to get next instruction address, should not be placed on link stack.
assign iu3_opcode_d[0:5] = iu2_instr_pri[0:5];
assign iu3_bo_d[6:10] = iu2_instr_pri[6:10];
assign iu3_bi_d[11:15] = iu2_instr_pri[11:15];

assign iu3_getNIA = iu3_opcode_q[0:5] == 6'b010000 & iu3_bo_q[6:10] == 5'b10100 & iu3_bi_q[11:15] == 5'b11111 & iu3_bd[62-`EFF_IFAR_WIDTH:61] == value_1[32-`EFF_IFAR_WIDTH:31] & iu3_aa_q == 1'b0 & iu3_lk_q == 1'b1;

//-----------------------------------------------
// calculate branch target address
//-----------------------------------------------

assign iu3_abs[62 - `EFF_IFAR_WIDTH:61] = (iu3_b_q == 1'b1) ? iu3_li[62 - `EFF_IFAR_WIDTH:61] :
                                         iu3_bd[62 - `EFF_IFAR_WIDTH:61];

assign iu3_off[62 - `EFF_IFAR_WIDTH:61] = iu3_abs[62 - `EFF_IFAR_WIDTH:61] + ({iu3_ifar_q[62 - `EFF_IFAR_WIDTH:59], iu3_ifar_pri_q[60:61]});

assign iu3_bta[62 - `EFF_IFAR_WIDTH:61] = (iu3_aa_q == 1'b1) ? iu3_abs[62 - `EFF_IFAR_WIDTH:61] :
                                         iu3_off[62 - `EFF_IFAR_WIDTH:61];

//-----------------------------------------------
// forward validated instructions
//-----------------------------------------------

// Using xori 0,0,0 (xnop) when erat error
assign xnop[0:31] = {6'b011010, 26'b0};

assign iu3_act = ic_bp_iu2_val[0];
assign iu3_instr_act[0:3] = ic_bp_iu2_val[0:3];

assign iu3_ifar_d[62 - `EFF_IFAR_WIDTH:61] = ic_bp_iu2_ifar[62 - `EFF_IFAR_WIDTH:61];

assign iu3_val_d[0] = (~iu2_flush) & ic_bp_iu2_val[0];
assign iu3_val_d[1] = (~iu2_flush) & ic_bp_iu2_val[1] & (ic_bp_iu2_error[0] | ((~iu2_br_pred[0])));
assign iu3_val_d[2] = (~iu2_flush) & ic_bp_iu2_val[2] & (ic_bp_iu2_error[0] | ((~iu2_br_pred[0]) & (~iu2_br_pred[1])));
assign iu3_val_d[3] = (~iu2_flush) & ic_bp_iu2_val[3] & (ic_bp_iu2_error[0] | ((~iu2_br_pred[0]) & (~iu2_br_pred[1]) & (~iu2_br_pred[2])));

assign iu3_0_instr_d[0:31] = (ic_bp_iu2_error[0] == 1'b0) ? ic_bp_iu2_0_instr[0:31] :
                             xnop[0:31];
assign iu3_1_instr_d[0:31] = (ic_bp_iu2_error[0] == 1'b0) ? ic_bp_iu2_1_instr[0:31] :
                             xnop[0:31];
assign iu3_2_instr_d[0:31] = (ic_bp_iu2_error[0] == 1'b0) ? ic_bp_iu2_2_instr[0:31] :
                             xnop[0:31];
assign iu3_3_instr_d[0:31] = (ic_bp_iu2_error[0] == 1'b0) ? ic_bp_iu2_3_instr[0:31] :
                             xnop[0:31];

assign iu3_0_instr_d[32] = iu2_br_pred[0] & (~ic_bp_iu2_error[0]);
assign iu3_1_instr_d[32] = iu2_br_pred[1] & (~ic_bp_iu2_error[0]);
assign iu3_2_instr_d[32] = iu2_br_pred[2] & (~ic_bp_iu2_error[0]);
assign iu3_3_instr_d[32] = iu2_br_pred[3] & (~ic_bp_iu2_error[0]);

assign iu3_0_instr_d[33] = iu2_bh_update[0] & (~ic_bp_iu2_error[0]);
assign iu3_1_instr_d[33] = iu2_bh_update[1] & (~ic_bp_iu2_error[0]);
assign iu3_2_instr_d[33] = iu2_bh_update[2] & (~ic_bp_iu2_error[0]);
assign iu3_3_instr_d[33] = iu2_bh_update[3] & (~ic_bp_iu2_error[0]);

assign iu3_0_instr_d[34:35] = iu2_0_bh0_hist;
assign iu3_1_instr_d[34:35] = iu2_1_bh0_hist;
assign iu3_2_instr_d[34:35] = iu2_2_bh0_hist;
assign iu3_3_instr_d[34:35] = iu2_3_bh0_hist;

assign iu3_0_instr_d[36:37] = iu2_0_bh1_hist;
assign iu3_1_instr_d[36:37] = iu2_1_bh1_hist;
assign iu3_2_instr_d[36:37] = iu2_2_bh1_hist;
assign iu3_3_instr_d[36:37] = iu2_3_bh1_hist;

assign iu3_0_instr_d[38] = iu2_0_bh2_hist;
assign iu3_1_instr_d[38] = iu2_1_bh2_hist;
assign iu3_2_instr_d[38] = iu2_2_bh2_hist;
assign iu3_3_instr_d[38] = iu2_3_bh2_hist;

assign iu3_0_instr_d[39] = 1'b0;
assign iu3_1_instr_d[39] = 1'b0;
assign iu3_2_instr_d[39] = 1'b0;
assign iu3_3_instr_d[39] = 1'b0;

assign iu3_0_instr_d[40:49] = iu2_gshare_q[0:9];
assign iu3_1_instr_d[40:49] = iu2_gshare_q[0:9];
assign iu3_2_instr_d[40:49] = iu2_gshare_q[0:9];
assign iu3_3_instr_d[40:49] = iu2_gshare_q[0:9];

assign iu3_0_instr_d[50:52] = iu2_ls_ptr[0:2];
assign iu3_1_instr_d[50:52] = iu2_ls_ptr[0:2];
assign iu3_2_instr_d[50:52] = iu2_ls_ptr[0:2];
assign iu3_3_instr_d[50:52] = iu2_ls_ptr[0:2];

assign iu3_0_instr_d[53:55] = ic_bp_iu2_error[0:2];
assign iu3_1_instr_d[53:55] = ic_bp_iu2_error[0:2];
assign iu3_2_instr_d[53:55] = ic_bp_iu2_error[0:2];
assign iu3_3_instr_d[53:55] = ic_bp_iu2_error[0:2];

assign iu3_0_instr_d[56] = (iu2_uc[0] | ic_bp_iu2_2ucode) & (~ic_bp_iu2_error[0]);
assign iu3_1_instr_d[56] = iu2_uc[1] & (~ic_bp_iu2_error[0]);
assign iu3_2_instr_d[56] = iu2_uc[2] & (~ic_bp_iu2_error[0]);
assign iu3_3_instr_d[56] = iu2_uc[3] & (~ic_bp_iu2_error[0]);

assign iu3_0_instr_d[57] = iu2_fuse[0] & (~ic_bp_iu2_error[0]);
assign iu3_1_instr_d[57] = iu2_fuse[1] & (~ic_bp_iu2_error[0]);
assign iu3_2_instr_d[57] = iu2_fuse[2] & (~ic_bp_iu2_error[0]);
assign iu3_3_instr_d[57] = iu2_fuse[3] & (~ic_bp_iu2_error[0]);

assign iu3_0_instr_d[58] = iu2_btb_entry[0];
assign iu3_1_instr_d[58] = iu2_btb_entry[1];
assign iu3_2_instr_d[58] = iu2_btb_entry[2];
assign iu3_3_instr_d[58] = iu2_btb_entry[3];

assign iu3_0_instr_d[59] = ic_bp_iu2_2ucode;
assign iu3_1_instr_d[59] = ic_bp_iu2_2ucode;
assign iu3_2_instr_d[59] = ic_bp_iu2_2ucode;
assign iu3_3_instr_d[59] = ic_bp_iu2_2ucode;

assign iu3_0_instr_d[60] = 1'b0;
assign iu3_1_instr_d[60] = 1'b0;
assign iu3_2_instr_d[60] = 1'b0;
assign iu3_3_instr_d[60] = 1'b0;

assign iu3_br_pred[0:3] = {iu3_0_instr_q[32], iu3_1_instr_q[32], iu3_2_instr_q[32], iu3_3_instr_q[32]};
assign iu3_bh_update[0:3] = {iu3_0_instr_q[33], iu3_1_instr_q[33], iu3_2_instr_q[33], iu3_3_instr_q[33]};

//-----------------------------------------------
// detect incoming flushes
//-----------------------------------------------

assign iu1_flush = iu2_flush | iu2_redirect;

assign iu2_flush = iu_flush_q | br_iu_redirect_q | ic_bp_iu2_flush | ic_bp_iu3_flush | iu3_redirect | iu4_redirect_q | ib_ic_iu4_redirect | uc_iu4_flush;

assign iu3_flush = iu_flush_q | br_iu_redirect_q | ic_bp_iu3_flush | iu4_redirect_q | ib_ic_iu4_redirect | uc_iu4_flush;

assign iu4_flush = iu_flush_q | br_iu_redirect_q | ib_ic_iu4_redirect | uc_iu4_flush;		//it is possible to remove iu_flush from iu4_flush for timing but will have performance impact

//-----------------------------------------------
// ex link stack pointers
//-----------------------------------------------

//valid can be concurrent with flush
assign ex5_ls_push_d = ex5_val_d & ex5_br_taken_d & (~ex5_bclr_d) & ex5_lk_d & (~ex5_getNIA_d);
assign ex5_ls_pop_d = ex5_val_d & ex5_br_taken_d & ex5_bclr_d & ex5_bh_d[0:1] == 2'b00;

assign ex6_ls_t0_ptr_d[0:7] = (ex5_ls_push_q == 1'b1 & ex5_ls_pop_q == 1'b0) ? {ex5_ls_ptr_q[7], ex5_ls_ptr_q[0:6]} :
                              (ex5_ls_push_q == 1'b0 & ex5_ls_pop_q == 1'b1) ? {ex5_ls_ptr_q[1:7], ex5_ls_ptr_q[0]} :
                              ex6_ls_t0_ptr_q[0:7];

assign ex6_ls_ptr_act = ex5_ls_push_q ^ ex5_ls_pop_q;
//-----------------------------------------------
// maintain link stack contents
//-----------------------------------------------

assign ex5_ls_update = ex5_ls_push_q;

assign ex5_nia[62 - `EFF_IFAR_WIDTH:61] = ex5_ifar_q[62-`EFF_IFAR_WIDTH:61] + value_1[32-`EFF_IFAR_WIDTH:31];

assign ex6_ls_t00_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_ls_update == 1'b1) ? ex5_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              ex6_ls_t00_q[62 - `EFF_IFAR_WIDTH:61];
assign ex6_ls_t01_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_ls_update == 1'b1) ? ex5_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              ex6_ls_t01_q[62 - `EFF_IFAR_WIDTH:61];
assign ex6_ls_t02_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_ls_update == 1'b1) ? ex5_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              ex6_ls_t02_q[62 - `EFF_IFAR_WIDTH:61];
assign ex6_ls_t03_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_ls_update == 1'b1) ? ex5_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              ex6_ls_t03_q[62 - `EFF_IFAR_WIDTH:61];
assign ex6_ls_t04_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_ls_update == 1'b1) ? ex5_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              ex6_ls_t04_q[62 - `EFF_IFAR_WIDTH:61];
assign ex6_ls_t05_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_ls_update == 1'b1) ? ex5_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              ex6_ls_t05_q[62 - `EFF_IFAR_WIDTH:61];
assign ex6_ls_t06_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_ls_update == 1'b1) ? ex5_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              ex6_ls_t06_q[62 - `EFF_IFAR_WIDTH:61];
assign ex6_ls_t07_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_ls_update == 1'b1) ? ex5_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              ex6_ls_t07_q[62 - `EFF_IFAR_WIDTH:61];

assign ex6_ls_t0_act[0:7] = (ex5_ls_update == 1'b1) ? ex6_ls_t0_ptr_d[0:7] :
                            8'b00000000;

//-----------------------------------------------
// iu link stack pointers
//-----------------------------------------------

assign iu4_ls_push_d = iu3_pr_val_q & (~iu3_flush) & (~iu3_bclr_q) & iu3_lk_q & (~iu3_getNIA);
assign iu4_ls_pop_d = iu3_pr_val_q & (~iu3_flush) & iu3_bclr_q & iu3_bh_q[0:1] == 2'b00;

assign ex5_repair = ex5_flush_q;

assign iu5_ls_t0_ptr_d[0:7] = (ex5_repair == 1'b1) ? ex6_ls_t0_ptr_d[0:7] :
                              (br_iu_redirect_q == 1'b1) ? br_iu_ls_ptr_q[0:7] :
                              (iu4_ls_push_q == 1'b1 & iu4_ls_pop_q == 1'b0) ? {iu5_ls_t0_ptr_q[7], iu5_ls_t0_ptr_q[0:6]} :
                              (iu4_ls_push_q == 1'b0 & iu4_ls_pop_q == 1'b1) ? {iu5_ls_t0_ptr_q[1:7], iu5_ls_t0_ptr_q[0]} :
                              iu5_ls_t0_ptr_q[0:7];

assign iu5_ls_ptr_act[0] = br_iu_redirect_q | ex5_repair | (~iu4_flush);

//-----------------------------------------------
// maintain link stack contents
//-----------------------------------------------

assign iu4_ls_update = iu4_ls_push_q & (~iu4_flush);

assign iu4_ifar_d[62 - `EFF_IFAR_WIDTH:61] = ({iu3_ifar_q[62 - `EFF_IFAR_WIDTH:59], iu3_ifar_pri_q[60:61]});
assign iu4_act = iu3_pr_val_q & iu3_lk_q;

assign iu4_nia[62 - `EFF_IFAR_WIDTH:61] = iu4_ifar_q[62 - `EFF_IFAR_WIDTH:61] + value_1[32-`EFF_IFAR_WIDTH:31];

assign iu5_ls_t00_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_repair == 1'b1) ? ex6_ls_t00_d[62 - `EFF_IFAR_WIDTH:61] :
                                              (br_iu_redirect_q == 1'b1 & br_iu_ls_update_q == 1'b1) ? br_iu_ls_data_q[62 - `EFF_IFAR_WIDTH:61] :
                                              (iu4_ls_update == 1'b1) ? iu4_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              iu5_ls_t00_q[62 - `EFF_IFAR_WIDTH:61];
assign iu5_ls_t01_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_repair == 1'b1) ? ex6_ls_t01_d[62 - `EFF_IFAR_WIDTH:61] :
                                              (br_iu_redirect_q == 1'b1 & br_iu_ls_update_q == 1'b1) ? br_iu_ls_data_q[62 - `EFF_IFAR_WIDTH:61] :
                                              (iu4_ls_update == 1'b1) ? iu4_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              iu5_ls_t01_q[62 - `EFF_IFAR_WIDTH:61];
assign iu5_ls_t02_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_repair == 1'b1) ? ex6_ls_t02_d[62 - `EFF_IFAR_WIDTH:61] :
                                              (br_iu_redirect_q == 1'b1 & br_iu_ls_update_q == 1'b1) ? br_iu_ls_data_q[62 - `EFF_IFAR_WIDTH:61] :
                                              (iu4_ls_update == 1'b1) ? iu4_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              iu5_ls_t02_q[62 - `EFF_IFAR_WIDTH:61];
assign iu5_ls_t03_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_repair == 1'b1) ? ex6_ls_t03_d[62 - `EFF_IFAR_WIDTH:61] :
                                              (br_iu_redirect_q == 1'b1 & br_iu_ls_update_q == 1'b1) ? br_iu_ls_data_q[62 - `EFF_IFAR_WIDTH:61] :
                                              (iu4_ls_update == 1'b1) ? iu4_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              iu5_ls_t03_q[62 - `EFF_IFAR_WIDTH:61];
assign iu5_ls_t04_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_repair == 1'b1) ? ex6_ls_t04_d[62 - `EFF_IFAR_WIDTH:61] :
                                              (br_iu_redirect_q == 1'b1 & br_iu_ls_update_q == 1'b1) ? br_iu_ls_data_q[62 - `EFF_IFAR_WIDTH:61] :
                                              (iu4_ls_update == 1'b1) ? iu4_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              iu5_ls_t04_q[62 - `EFF_IFAR_WIDTH:61];
assign iu5_ls_t05_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_repair == 1'b1) ? ex6_ls_t05_d[62 - `EFF_IFAR_WIDTH:61] :
                                              (br_iu_redirect_q == 1'b1 & br_iu_ls_update_q == 1'b1) ? br_iu_ls_data_q[62 - `EFF_IFAR_WIDTH:61] :
                                              (iu4_ls_update == 1'b1) ? iu4_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              iu5_ls_t05_q[62 - `EFF_IFAR_WIDTH:61];
assign iu5_ls_t06_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_repair == 1'b1) ? ex6_ls_t06_d[62 - `EFF_IFAR_WIDTH:61] :
                                              (br_iu_redirect_q == 1'b1 & br_iu_ls_update_q == 1'b1) ? br_iu_ls_data_q[62 - `EFF_IFAR_WIDTH:61] :
                                              (iu4_ls_update == 1'b1) ? iu4_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              iu5_ls_t06_q[62 - `EFF_IFAR_WIDTH:61];
assign iu5_ls_t07_d[62 - `EFF_IFAR_WIDTH:61] = (ex5_repair == 1'b1) ? ex6_ls_t07_d[62 - `EFF_IFAR_WIDTH:61] :
                                              (br_iu_redirect_q == 1'b1 & br_iu_ls_update_q == 1'b1) ? br_iu_ls_data_q[62 - `EFF_IFAR_WIDTH:61] :
                                              (iu4_ls_update == 1'b1) ? iu4_nia[62 - `EFF_IFAR_WIDTH:61] :
                                              iu5_ls_t07_q[62 - `EFF_IFAR_WIDTH:61];

assign iu5_ls_t0_act[0:7] = (ex5_repair == 1'b1) ? 8'b11111111 :
                            (iu4_ls_push_q == 1'b1 | (br_iu_redirect_q == 1'b1 & br_iu_ls_update_q == 1'b1)) ? iu5_ls_t0_ptr_d[0:7] :
                            8'b00000000;

//-----------------------------------------------
// mux out link address
//-----------------------------------------------

assign iu2_lnk[62-`EFF_IFAR_WIDTH:61] = ({`EFF_IFAR_WIDTH{iu5_ls_t0_ptr_q[0]}} & iu5_ls_t00_q[62 - `EFF_IFAR_WIDTH:61]) |
                                        ({`EFF_IFAR_WIDTH{iu5_ls_t0_ptr_q[1]}} & iu5_ls_t01_q[62 - `EFF_IFAR_WIDTH:61]) |
                                        ({`EFF_IFAR_WIDTH{iu5_ls_t0_ptr_q[2]}} & iu5_ls_t02_q[62 - `EFF_IFAR_WIDTH:61]) |
                                        ({`EFF_IFAR_WIDTH{iu5_ls_t0_ptr_q[3]}} & iu5_ls_t03_q[62 - `EFF_IFAR_WIDTH:61]) |
                                        ({`EFF_IFAR_WIDTH{iu5_ls_t0_ptr_q[4]}} & iu5_ls_t04_q[62 - `EFF_IFAR_WIDTH:61]) |
                                        ({`EFF_IFAR_WIDTH{iu5_ls_t0_ptr_q[5]}} & iu5_ls_t05_q[62 - `EFF_IFAR_WIDTH:61]) |
                                        ({`EFF_IFAR_WIDTH{iu5_ls_t0_ptr_q[6]}} & iu5_ls_t06_q[62 - `EFF_IFAR_WIDTH:61]) |
                                        ({`EFF_IFAR_WIDTH{iu5_ls_t0_ptr_q[7]}} & iu5_ls_t07_q[62 - `EFF_IFAR_WIDTH:61]);

assign iu2_ls_ptr[0:2] = ({3{iu5_ls_t0_ptr_q[0]}} & 3'b000) |
                         ({3{iu5_ls_t0_ptr_q[1]}} & 3'b001) |
                         ({3{iu5_ls_t0_ptr_q[2]}} & 3'b010) |
                         ({3{iu5_ls_t0_ptr_q[3]}} & 3'b011) |
                         ({3{iu5_ls_t0_ptr_q[4]}} & 3'b100) |
                         ({3{iu5_ls_t0_ptr_q[5]}} & 3'b101) |
                         ({3{iu5_ls_t0_ptr_q[6]}} & 3'b110) |
                         ({3{iu5_ls_t0_ptr_q[7]}} & 3'b111) ;



//-----------------------------------------------
// read btb for bcctr
//-----------------------------------------------

//btb has READ gating to prevent r/w collisions, with external write thru.  writes are never blocked, so its okay to read as often as we like
assign iu0_btb_rd_act = ic_bp_iu0_val;
assign iu0_btb_rd_addr[0:5] = ic_bp_iu0_ifar[54:59];

assign iu2_btb[62 - `EFF_IFAR_WIDTH:61] = iu2_btb_rd_data[0:`EFF_IFAR_WIDTH - 1];
assign iu2_btb_tag[62 - `EFF_IFAR_WIDTH:61] = iu2_btb_rd_data[`EFF_IFAR_WIDTH:2 * `EFF_IFAR_WIDTH - 1];
assign iu2_btb_link = iu2_btb_rd_data[2 * `EFF_IFAR_WIDTH];
assign iu2_btb_hist[0:1] = iu2_btb_hist_q[0:1];

assign iu2_btb_entry[0] = ic_bp_iu2_ifar[62 - `EFF_IFAR_WIDTH:59] == iu2_btb_tag[62 - `EFF_IFAR_WIDTH:59] & iu2_btb_tag[60:61] == ic_bp_iu2_ifar[60:61];
assign iu2_btb_entry[1] = ic_bp_iu2_ifar[62 - `EFF_IFAR_WIDTH:59] == iu2_btb_tag[62 - `EFF_IFAR_WIDTH:59] & iu2_btb_tag[60:61] == ic_bp_iu2_ifar[60:61] + 2'b01;
assign iu2_btb_entry[2] = ic_bp_iu2_ifar[62 - `EFF_IFAR_WIDTH:59] == iu2_btb_tag[62 - `EFF_IFAR_WIDTH:59] & iu2_btb_tag[60:61] == ic_bp_iu2_ifar[60:61] + 2'b10;
assign iu2_btb_entry[3] = ic_bp_iu2_ifar[62 - `EFF_IFAR_WIDTH:59] == iu2_btb_tag[62 - `EFF_IFAR_WIDTH:59] & iu2_btb_tag[60:61] == ic_bp_iu2_ifar[60:61] + 2'b11;

//-----------------------------------------------
// read/write btb replacement counter
//-----------------------------------------------

assign ex5_btb_repl_new[0:1] = ((ex5_btb_entry_q == 1'b0 & ex5_br_taken_q == 1'b1 & (ex5_btb_repl_cnt[0:1] == 2'b00 | ex5_bcctr_q == 1'b1 | (ex5_bclr_q == 1'b1 & ex5_bh_q[0:1] != 2'b00)))) ? 2'b01 :
                               (ex5_btb_entry_q == 1'b0 & ex5_br_taken_q == 1'b1 & ex5_btb_repl_cnt[0:1] != 2'b00) ? ex5_btb_repl_cnt[0:1] - 2'b01 :
                               (ex5_br_taken_q == 1'b1 & ex5_btb_hist[0] == 1'b1 & (ex5_bcctr_q == 1'b1 | (ex5_bclr_q == 1'b1 & ex5_bh_q[0:1] != 2'b00))) ? 2'b11 :
                               (ex5_br_taken_q == 1'b1 & ex5_btb_hist[0] == 1'b1 & ex5_btb_repl_cnt[0:1] != 2'b11) ? ex5_btb_repl_cnt[0:1] + 2'b01 :
                               ex5_btb_repl_cnt[0:1];

generate
begin : xhdl2
   genvar                        i;
   for (i = 0; i <= 63; i = i + 1)
   begin : repl_cnt
   	wire [54:59] id = i;
      assign ex5_btb_repl_d[2 * i:2 * i + 1] = (ex5_ifar_q[54:59] == id) ? ex5_btb_repl_new[0:1] :
                                               ex5_btb_repl_q[2 * i:2 * i + 1];
      assign ex5_btb_repl_out[i] = ex5_btb_repl_q[2 * i] & ex5_ifar_q[54:59] == id;
      assign ex5_btb_repl_out[i + 64] = ex5_btb_repl_q[2 * i + 1] & ex5_ifar_q[54:59] == id;
   end
end
endgenerate

assign ex5_btb_repl_cnt[0:1] = {|(ex5_btb_repl_out[0:63]), |(ex5_btb_repl_out[64:127])};

//-----------------------------------------------
// read/write btb history
//-----------------------------------------------

assign iu0_btb_hist_new[0:1] = (ex5_val_q == 1'b0 & ex5_btb_entry_q == 1'b1 & ex5_btb_hist[0:1] != 2'b00) ? ex5_btb_hist[0:1] - 2'b01 :
                               ((ex5_btb_entry_q == 1'b0 & ex5_br_taken_q == 1'b1 & (ex5_btb_repl_cnt[0:1] == 2'b00 | ex5_bcctr_q == 1'b1 | (ex5_bclr_q == 1'b1 & ex5_bh_q[0:1] != 2'b00)))) ? 2'b10 :
                               (ex5_br_taken_q == 1'b1 & ex5_btb_hist[0:1] != 2'b11) ? ex5_btb_hist[0:1] + 2'b01 :
                               (ex5_br_taken_q == 1'b0 & ex5_btb_hist[0:1] != 2'b00) ? ex5_btb_hist[0:1] - 2'b01 :
                               ex5_btb_hist[0:1];

generate
   begin : xhdl3
      genvar                        i;
      for (i = 0; i <= 63; i = i + 1)
      begin : btb_hist
      	wire [54:59] id = i;
         assign iu0_btb_hist_d[2 * i:2 * i + 1] = (ex5_ifar_q[54:59] == id) ? iu0_btb_hist_new[0:1] :
                                                  iu0_btb_hist_q[2 * i:2 * i + 1];
         assign iu0_btb_hist_out[i] = iu0_btb_hist_q[2 * i] & ic_bp_iu0_ifar[54:59] == id;
         assign iu0_btb_hist_out[i + 64] = iu0_btb_hist_q[2 * i + 1] & ic_bp_iu0_ifar[54:59] == id;
         assign ex5_btb_hist_out[i] = iu0_btb_hist_q[2 * i] & ex5_ifar_q[54:59] == id;
         assign ex5_btb_hist_out[i + 64] = iu0_btb_hist_q[2 * i + 1] & ex5_ifar_q[54:59] == id;
      end
   end
   endgenerate

   assign iu1_btb_hist_d[0:1] = {|(iu0_btb_hist_out[0:63]), |(iu0_btb_hist_out[64:127])};
   assign iu2_btb_hist_d[0:1] = iu1_btb_hist_q[0:1];

   assign ex5_btb_hist[0:1] = {|(ex5_btb_hist_out[0:63]), |(ex5_btb_hist_out[64:127])};

   assign iu0_btb_hist_act = (ex5_val_q == 1'b0 & ex5_btb_entry_q == 1'b1) | (ex5_val_q == 1'b1 & ((ex5_btb_entry_q == 1'b1) | (ex5_btb_entry_q == 1'b0 & ex5_br_taken_q & (ex5_btb_repl_cnt[0:1] == 2'b00 | ex5_bcctr_q == 1'b1 | (ex5_bclr_q == 1'b1 & ex5_bh_q[0:1] != 2'b00)))));

   //-----------------------------------------------
   // write btb
   //-----------------------------------------------

   //target
   //branch to link
     assign ex5_btb_wr_data[0:63] = {ex5_bta_q[62 - `EFF_IFAR_WIDTH:61], ex5_ifar_q[62 - `EFF_IFAR_WIDTH:61], (ex5_bclr_q & ex5_bh_q[0:1] == 2'b00), {(64-(2*`EFF_IFAR_WIDTH + 1)){1'b0}}};		//tag

   assign ex5_btb_wr_addr[0:5] = ex5_ifar_q[54:59];

   assign ex5_btb_wr_act = (ex5_val_q == 1'b1 & ((ex5_btb_entry_q == 1'b1 & ex5_br_taken_q) | (ex5_btb_entry_q == 1'b0 & ex5_br_taken_q & (ex5_btb_repl_cnt[0:1] == 2'b00 | ex5_bcctr_q == 1'b1 | (ex5_bclr_q == 1'b1 & ex5_bh_q[0:1] != 2'b00)))));

   //-----------------------------------------------
   // select indirect ifar
   //-----------------------------------------------

   assign iu3_lnk_d[62 - `EFF_IFAR_WIDTH:61] = iu2_lnk[62 - `EFF_IFAR_WIDTH:61];
   assign iu3_btb_d[62 - `EFF_IFAR_WIDTH:61] = iu2_btb[62 - `EFF_IFAR_WIDTH:61];

   //next fetch group address
   assign iu3_nfg_d[62-`EFF_IFAR_WIDTH:59] = ic_bp_iu2_ifar[62 - `EFF_IFAR_WIDTH:59] + value_1[34-`EFF_IFAR_WIDTH:31];
   assign iu3_nfg_d[60:61] = 2'b00;

   //-----------------------------------------------
   // redirect instruction pointer
   //-----------------------------------------------

   assign iu2_redirect = bp_bt_en & ic_bp_iu2_val[0] & ic_bp_iu2_error[0:2] == 3'b000 & iu2_btb_hist[0] & ic_bp_iu2_ifar[62 - `EFF_IFAR_WIDTH:53] == iu2_btb_tag[62 - `EFF_IFAR_WIDTH:53] & ic_bp_iu2_ifar[60:61] <= iu2_btb_tag[60:61];

   assign iu3_btb_redirect_d = iu2_redirect & (~iu2_flush);
   assign iu3_btb_misdirect_d = iu2_redirect & (~iu2_flush) & iu2_btb_tag[60:61] != iu3_ifar_pri_d[60:61];
   assign iu3_btb_link_d = iu2_btb_link;

   assign iu4_redirect_act = iu3_redirect;

   assign iu4_redirect_ifar_d[62 - `EFF_IFAR_WIDTH:61] = iu3_bta[62 - `EFF_IFAR_WIDTH:61];

   assign iu3_redirect = (iu3_pr_val_q ^ iu3_btb_redirect_q) | (iu3_btb_redirect_q & ((iu3_bclr_q == 1'b1 & iu3_bh_q[0:1] == 2'b00) ^ iu3_btb_link_q == 1'b1)) | (iu3_btb_misdirect_q & (~(((iu3_bcctr_q == 1'b1 | (iu3_bclr_q == 1'b1 & iu3_bh_q[0:1] != 2'b00)) & iu3_btb_link_q == 1'b0) | (iu3_bclr_q == 1'b1 & iu3_bh_q[0:1] == 2'b00 & iu3_btb_link_q == 1'b1))));

   assign iu3_redirect_early = iu3_bclr_q | iu3_bcctr_q | (~iu3_pr_val_q);
   assign iu4_redirect_d = iu3_redirect & (~iu3_redirect_early) & (~iu3_flush);

   assign bp_ic_redirect_ifar[62 - `EFF_IFAR_WIDTH:61] = (iu4_redirect_q == 1'b1) ? iu4_redirect_ifar_q[62 - `EFF_IFAR_WIDTH:61] :
                                                        ((iu3_redirect == 1'b1 & iu3_pr_val_q == 1'b0)) ? iu3_nfg_q[62 - `EFF_IFAR_WIDTH:61] :
                                                        ((iu3_redirect == 1'b1 & iu3_bclr_q == 1'b1 & iu3_bh_q[0:1] == 2'b00)) ? iu3_lnk_q[62 - `EFF_IFAR_WIDTH:61] :
                                                        ((iu3_redirect == 1'b1)) ? iu3_btb_q[62 - `EFF_IFAR_WIDTH:61] :
                                                        ((iu2_btb_link == 1'b1)) ? iu3_lnk_d[62 - `EFF_IFAR_WIDTH:61] :
                                                        iu3_btb_d[62 - `EFF_IFAR_WIDTH:61];

   assign bp_ic_iu4_redirect = iu4_redirect_q;
   assign bp_ic_iu3_redirect = iu3_redirect;
   assign bp_ic_iu2_redirect = iu2_redirect;

   //-----------------------------------------------
   // out of sync hold of link stack instructions
   //-----------------------------------------------

   assign bp_ic_iu3_hold = 1'b0;

   //-----------------------------------------------
   // output validated instructions
   //-----------------------------------------------

   assign bp_ib_iu3_ifar[62 - `EFF_IFAR_WIDTH:61] = iu3_ifar_q[62 - `EFF_IFAR_WIDTH:61];

   assign bp_ib_iu3_val[0:3] = ({4{~ic_bp_iu3_flush}} & iu3_val_q[0:3]);

   assign bp_ib_iu3_0_instr[0:69] = {iu3_0_instr_q[0:53], (iu3_0_instr_q[54] | ic_bp_iu3_ecc_err), iu3_0_instr_q[55:60], bp_ib_iu3_bta_val, iu3_gs_counts[0:5], iu3_gs_count0[0:1]};
   assign bp_ib_iu3_1_instr[0:69] = {iu3_1_instr_q[0:53], (iu3_1_instr_q[54] | ic_bp_iu3_ecc_err), iu3_1_instr_q[55:60], bp_ib_iu3_bta_val, iu3_gs_counts[0:5], iu3_gs_count1[0:1]};
   assign bp_ib_iu3_2_instr[0:69] = {iu3_2_instr_q[0:53], (iu3_2_instr_q[54] | ic_bp_iu3_ecc_err), iu3_2_instr_q[55:60], bp_ib_iu3_bta_val, iu3_gs_counts[0:5], iu3_gs_count2[0:1]};
   assign bp_ib_iu3_3_instr[0:69] = {iu3_3_instr_q[0:53], (iu3_3_instr_q[54] | ic_bp_iu3_ecc_err), iu3_3_instr_q[55:60], bp_ib_iu3_bta_val, iu3_gs_counts[0:5], iu3_gs_count3[0:1]};

   assign bp_ib_iu3_bta[62 - `EFF_IFAR_WIDTH:61] = ((iu3_bclr_q == 1'b1 & iu3_bh_q[0:1] == 2'b00)) ? iu3_lnk_q[62 - `EFF_IFAR_WIDTH:61] :
                                                  iu3_btb_q[62 - `EFF_IFAR_WIDTH:61];

   assign bp_ib_iu3_bta_val = (~iu4_redirect_d);

   //-----------------------------------------------
   // latches
   //-----------------------------------------------

   //scan chain 0

   tri_rlmreg_p #(.WIDTH(128), .INIT(0)) iu0_btb_hist_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu0_btb_hist_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu0_btb_hist_offset:iu0_btb_hist_offset + 127]),
      .scout(sov0[iu0_btb_hist_offset:iu0_btb_hist_offset + 127]),
      .din(iu0_btb_hist_d[0:127]),
      .dout(iu0_btb_hist_q[0:127])
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) iu1_btb_hist_reg(
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
      .scin(siv0[iu1_btb_hist_offset:iu1_btb_hist_offset + 1]),
      .scout(sov0[iu1_btb_hist_offset:iu1_btb_hist_offset + 1]),
      .din(iu1_btb_hist_d[0:1]),
      .dout(iu1_btb_hist_q[0:1])
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) iu2_btb_hist_reg(
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
      .scin(siv0[iu2_btb_hist_offset:iu2_btb_hist_offset + 1]),
      .scout(sov0[iu2_btb_hist_offset:iu2_btb_hist_offset + 1]),
      .din(iu2_btb_hist_d[0:1]),
      .dout(iu2_btb_hist_q[0:1])
   );


   tri_rlmreg_p #(.WIDTH(16), .INIT(0)) gshare_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(gshare_act[0]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[gshare_offset:gshare_offset + 15]),
      .scout(sov0[gshare_offset:gshare_offset + 15]),
      .din(gshare_d[0:15]),
      .dout(gshare_q[0:15])
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0)) gshare_shift0_reg(
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
      .scin(siv0[gshare_shift0_offset:gshare_shift0_offset + 4]),
      .scout(sov0[gshare_shift0_offset:gshare_shift0_offset + 4]),
      .din(gshare_shift0_d[0:4]),
      .dout(gshare_shift0_q[0:4])
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(0)) cp_gshare_reg(
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
      .scin(siv0[cp_gshare_offset:cp_gshare_offset + 15]),
      .scout(sov0[cp_gshare_offset:cp_gshare_offset + 15]),
      .din(cp_gshare_d[0:15]),
      .dout(cp_gshare_q[0:15])
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) cp_gs_count_reg(
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
      .scin(siv0[cp_gs_count_offset:cp_gs_count_offset + 1]),
      .scout(sov0[cp_gs_count_offset:cp_gs_count_offset + 1]),
      .din(cp_gs_count_d[0:1]),
      .dout(cp_gs_count_q[0:1])
   );

   tri_rlmlatch_p #(.INIT(0)) cp_gs_taken_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[cp_gs_taken_offset]),
      .scout(sov0[cp_gs_taken_offset]),
      .din(cp_gs_taken_d),
      .dout(cp_gs_taken_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) iu1_gs_pos_reg(
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
      .scin(siv0[iu1_gs_pos_offset:iu1_gs_pos_offset + 2]),
      .scout(sov0[iu1_gs_pos_offset:iu1_gs_pos_offset + 2]),
      .din(iu1_gs_pos_d[0:2]),
      .dout(iu1_gs_pos_q[0:2])
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) iu2_gs_pos_reg(
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
      .scin(siv0[iu2_gs_pos_offset:iu2_gs_pos_offset + 2]),
      .scout(sov0[iu2_gs_pos_offset:iu2_gs_pos_offset + 2]),
      .din(iu2_gs_pos_d[0:2]),
      .dout(iu2_gs_pos_q[0:2])
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) iu3_gs_pos_reg(
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
      .scin(siv0[iu3_gs_pos_offset:iu3_gs_pos_offset + 2]),
      .scout(sov0[iu3_gs_pos_offset:iu3_gs_pos_offset + 2]),
      .din(iu3_gs_pos_d[0:2]),
      .dout(iu3_gs_pos_q[0:2])
   );

   tri_rlmreg_p #(.WIDTH(10), .INIT(0)) iu1_gshare_reg(
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
      .scin(siv0[iu1_gshare_offset:iu1_gshare_offset + 9]),
      .scout(sov0[iu1_gshare_offset:iu1_gshare_offset + 9]),
      .din(iu1_gshare_d[0:9]),
      .dout(iu1_gshare_q[0:9])
   );


   tri_rlmreg_p #(.WIDTH(10), .INIT(0)) iu2_gshare_reg(
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
      .scin(siv0[iu2_gshare_offset:iu2_gshare_offset + 9]),
      .scout(sov0[iu2_gshare_offset:iu2_gshare_offset + 9]),
      .din(iu2_gshare_d[0:9]),
      .dout(iu2_gshare_q[0:9])
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) iu3_bh_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_bh_offset:iu3_bh_offset + 1]),
      .scout(sov0[iu3_bh_offset:iu3_bh_offset + 1]),
      .din(iu3_bh_d[0:1]),
      .dout(iu3_bh_q[0:1])
   );


   tri_rlmlatch_p #(.INIT(0)) iu3_lk_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_lk_offset]),
      .scout(sov0[iu3_lk_offset]),
      .din(iu3_lk_d),
      .dout(iu3_lk_q)
   );


   tri_rlmlatch_p #(.INIT(0)) iu3_aa_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_aa_offset]),
      .scout(sov0[iu3_aa_offset]),
      .din(iu3_aa_d),
      .dout(iu3_aa_q)
   );


   tri_rlmlatch_p #(.INIT(0)) iu3_b_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_b_offset]),
      .scout(sov0[iu3_b_offset]),
      .din(iu3_b_d),
      .dout(iu3_b_q)
   );


   tri_rlmlatch_p #(.INIT(0)) iu3_bclr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_bclr_offset]),
      .scout(sov0[iu3_bclr_offset]),
      .din(iu3_bclr_d),
      .dout(iu3_bclr_q)
   );


   tri_rlmlatch_p #(.INIT(0)) iu3_bcctr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_bcctr_offset]),
      .scout(sov0[iu3_bcctr_offset]),
      .din(iu3_bcctr_d),
      .dout(iu3_bcctr_q)
   );


   tri_rlmreg_p #(.WIDTH(6), .INIT(0)) iu3_opcode_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_opcode_offset:iu3_opcode_offset + 5]),
      .scout(sov0[iu3_opcode_offset:iu3_opcode_offset + 5]),
      .din(iu3_opcode_d[0:5]),
      .dout(iu3_opcode_q[0:5])
   );


   tri_rlmreg_p #(.WIDTH(5), .INIT(0)) iu3_bo_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_bo_offset:iu3_bo_offset + 4]),
      .scout(sov0[iu3_bo_offset:iu3_bo_offset + 4]),
      .din(iu3_bo_d[6:10]),
      .dout(iu3_bo_q[6:10])
   );


   tri_rlmreg_p #(.WIDTH(5), .INIT(0)) iu3_bi_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_bi_offset:iu3_bi_offset + 4]),
      .scout(sov0[iu3_bi_offset:iu3_bi_offset + 4]),
      .din(iu3_bi_d[11:15]),
      .dout(iu3_bi_q[11:15])
   );


   tri_rlmreg_p #(.WIDTH(24), .INIT(0)) iu3_tar_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_tar_offset:iu3_tar_offset + 23]),
      .scout(sov0[iu3_tar_offset:iu3_tar_offset + 23]),
      .din(iu3_tar_d[6:29]),
      .dout(iu3_tar_q[6:29])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) iu3_ifar_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_ifar_offset:iu3_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov0[iu3_ifar_offset:iu3_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .din(iu3_ifar_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(iu3_ifar_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) iu3_ifar_pri_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_ifar_pri_offset:iu3_ifar_pri_offset + 1]),
      .scout(sov0[iu3_ifar_pri_offset:iu3_ifar_pri_offset + 1]),
      .din(iu3_ifar_pri_d[60:61]),
      .dout(iu3_ifar_pri_q[60:61])
   );


   tri_rlmlatch_p #(.INIT(0)) iu3_pr_val_reg(
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
      .scin(siv0[iu3_pr_val_offset]),
      .scout(sov0[iu3_pr_val_offset]),
      .din(iu3_pr_val_d),
      .dout(iu3_pr_val_q)
   );

   tri_rlmreg_p #(.WIDTH((`EFF_IFAR_WIDTH)), .INIT(0)) iu3_lnk_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_lnk_offset:iu3_lnk_offset + (`EFF_IFAR_WIDTH) - 1]),
      .scout(sov0[iu3_lnk_offset:iu3_lnk_offset + (`EFF_IFAR_WIDTH) - 1]),
      .din(iu3_lnk_d),
      .dout(iu3_lnk_q)
   );


   tri_rlmreg_p #(.WIDTH((`EFF_IFAR_WIDTH)), .INIT(0)) iu3_btb_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_btb_offset:iu3_btb_offset + (`EFF_IFAR_WIDTH) - 1]),
      .scout(sov0[iu3_btb_offset:iu3_btb_offset + (`EFF_IFAR_WIDTH) - 1]),
      .din(iu3_btb_d),
      .dout(iu3_btb_q)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) iu3_val_reg(
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
      .scin(siv0[iu3_val_offset:iu3_val_offset + 3]),
      .scout(sov0[iu3_val_offset:iu3_val_offset + 3]),
      .din(iu3_val_d[0:3]),
      .dout(iu3_val_q[0:3])
   );


   tri_rlmreg_p #(.WIDTH(61), .INIT(0)) iu3_0_instr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_instr_act[0]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_0_instr_offset:iu3_0_instr_offset + 61 - 1]),
      .scout(sov0[iu3_0_instr_offset:iu3_0_instr_offset + 61 - 1]),
      .din(iu3_0_instr_d),
      .dout(iu3_0_instr_q)
   );


   tri_rlmreg_p #(.WIDTH(61), .INIT(0)) iu3_1_instr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_instr_act[1]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_1_instr_offset:iu3_1_instr_offset + 61 - 1]),
      .scout(sov0[iu3_1_instr_offset:iu3_1_instr_offset + 61 - 1]),
      .din(iu3_1_instr_d),
      .dout(iu3_1_instr_q)
   );


   tri_rlmreg_p #(.WIDTH(61), .INIT(0)) iu3_2_instr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_instr_act[2]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_2_instr_offset:iu3_2_instr_offset + 61 - 1]),
      .scout(sov0[iu3_2_instr_offset:iu3_2_instr_offset + 61 - 1]),
      .din(iu3_2_instr_d),
      .dout(iu3_2_instr_q)
   );


   tri_rlmreg_p #(.WIDTH(61), .INIT(0)) iu3_3_instr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_instr_act[3]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_3_instr_offset:iu3_3_instr_offset + 61 - 1]),
      .scout(sov0[iu3_3_instr_offset:iu3_3_instr_offset + 61 - 1]),
      .din(iu3_3_instr_d),
      .dout(iu3_3_instr_q)
   );


   tri_rlmlatch_p #(.INIT(0)) iu3_btb_redirect_reg(
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
      .scin(siv0[iu3_btb_redirect_offset]),
      .scout(sov0[iu3_btb_redirect_offset]),
      .din(iu3_btb_redirect_d),
      .dout(iu3_btb_redirect_q)
   );


   tri_rlmlatch_p #(.INIT(0)) iu3_btb_misdirect_reg(
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
      .scin(siv0[iu3_btb_misdirect_offset]),
      .scout(sov0[iu3_btb_misdirect_offset]),
      .din(iu3_btb_misdirect_d),
      .dout(iu3_btb_misdirect_q)
   );


   tri_rlmlatch_p #(.INIT(0)) iu3_btb_link_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_btb_link_offset]),
      .scout(sov0[iu3_btb_link_offset]),
      .din(iu3_btb_link_d),
      .dout(iu3_btb_link_q)
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) iu3_nfg_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu3_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu3_nfg_offset:iu3_nfg_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov0[iu3_nfg_offset:iu3_nfg_offset + `EFF_IFAR_WIDTH - 1]),
      .din(iu3_nfg_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(iu3_nfg_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) iu4_redirect_ifar_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu4_redirect_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu4_redirect_ifar_offset:iu4_redirect_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov0[iu4_redirect_ifar_offset:iu4_redirect_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .din(iu4_redirect_ifar_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(iu4_redirect_ifar_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmlatch_p #(.INIT(0)) iu4_redirect_reg(
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
      .scin(siv0[iu4_redirect_offset]),
      .scout(sov0[iu4_redirect_offset]),
      .din(iu4_redirect_d),
      .dout(iu4_redirect_q)
   );


   tri_rlmlatch_p #(.INIT(0)) iu4_ls_push_reg(
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
      .scin(siv0[iu4_ls_push_offset]),
      .scout(sov0[iu4_ls_push_offset]),
      .din(iu4_ls_push_d),
      .dout(iu4_ls_push_q)
   );


   tri_rlmlatch_p #(.INIT(0)) iu4_ls_pop_reg(
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
      .scin(siv0[iu4_ls_pop_offset]),
      .scout(sov0[iu4_ls_pop_offset]),
      .din(iu4_ls_pop_d),
      .dout(iu4_ls_pop_q)
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) iu4_ifar_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu4_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv0[iu4_ifar_offset:iu4_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov0[iu4_ifar_offset:iu4_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .din(iu4_ifar_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(iu4_ifar_q[62 - `EFF_IFAR_WIDTH:61])
   );

   //scan chain 1

   tri_rlmreg_p #(.WIDTH(8), .INIT(128)) iu5_ls_t0_ptr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu5_ls_ptr_act[0]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[iu5_ls_t0_ptr_offset:iu5_ls_t0_ptr_offset + 7]),
      .scout(sov1[iu5_ls_t0_ptr_offset:iu5_ls_t0_ptr_offset + 7]),
      .din(iu5_ls_t0_ptr_d[0:7]),
      .dout(iu5_ls_t0_ptr_q[0:7])
   );

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) iu5_ls_t00_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu5_ls_t0_act[0]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[iu5_ls_t00_offset:iu5_ls_t00_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[iu5_ls_t00_offset:iu5_ls_t00_offset + `EFF_IFAR_WIDTH - 1]),
      .din(iu5_ls_t00_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(iu5_ls_t00_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) iu5_ls_t01_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu5_ls_t0_act[1]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[iu5_ls_t01_offset:iu5_ls_t01_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[iu5_ls_t01_offset:iu5_ls_t01_offset + `EFF_IFAR_WIDTH - 1]),
      .din(iu5_ls_t01_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(iu5_ls_t01_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) iu5_ls_t02_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu5_ls_t0_act[2]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[iu5_ls_t02_offset:iu5_ls_t02_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[iu5_ls_t02_offset:iu5_ls_t02_offset + `EFF_IFAR_WIDTH - 1]),
      .din(iu5_ls_t02_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(iu5_ls_t02_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) iu5_ls_t03_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu5_ls_t0_act[3]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[iu5_ls_t03_offset:iu5_ls_t03_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[iu5_ls_t03_offset:iu5_ls_t03_offset + `EFF_IFAR_WIDTH - 1]),
      .din(iu5_ls_t03_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(iu5_ls_t03_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) iu5_ls_t04_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu5_ls_t0_act[4]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[iu5_ls_t04_offset:iu5_ls_t04_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[iu5_ls_t04_offset:iu5_ls_t04_offset + `EFF_IFAR_WIDTH - 1]),
      .din(iu5_ls_t04_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(iu5_ls_t04_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) iu5_ls_t05_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu5_ls_t0_act[5]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[iu5_ls_t05_offset:iu5_ls_t05_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[iu5_ls_t05_offset:iu5_ls_t05_offset + `EFF_IFAR_WIDTH - 1]),
      .din(iu5_ls_t05_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(iu5_ls_t05_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) iu5_ls_t06_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu5_ls_t0_act[6]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[iu5_ls_t06_offset:iu5_ls_t06_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[iu5_ls_t06_offset:iu5_ls_t06_offset + `EFF_IFAR_WIDTH - 1]),
      .din(iu5_ls_t06_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(iu5_ls_t06_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) iu5_ls_t07_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu5_ls_t0_act[7]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[iu5_ls_t07_offset:iu5_ls_t07_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[iu5_ls_t07_offset:iu5_ls_t07_offset + `EFF_IFAR_WIDTH - 1]),
      .din(iu5_ls_t07_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(iu5_ls_t07_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) ex6_ls_t00_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_ls_t0_act[0]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex6_ls_t00_offset:ex6_ls_t00_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[ex6_ls_t00_offset:ex6_ls_t00_offset + `EFF_IFAR_WIDTH - 1]),
      .din(ex6_ls_t00_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(ex6_ls_t00_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) ex6_ls_t01_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_ls_t0_act[1]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex6_ls_t01_offset:ex6_ls_t01_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[ex6_ls_t01_offset:ex6_ls_t01_offset + `EFF_IFAR_WIDTH - 1]),
      .din(ex6_ls_t01_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(ex6_ls_t01_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) ex6_ls_t02_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_ls_t0_act[2]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex6_ls_t02_offset:ex6_ls_t02_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[ex6_ls_t02_offset:ex6_ls_t02_offset + `EFF_IFAR_WIDTH - 1]),
      .din(ex6_ls_t02_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(ex6_ls_t02_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) ex6_ls_t03_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_ls_t0_act[3]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex6_ls_t03_offset:ex6_ls_t03_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[ex6_ls_t03_offset:ex6_ls_t03_offset + `EFF_IFAR_WIDTH - 1]),
      .din(ex6_ls_t03_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(ex6_ls_t03_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) ex6_ls_t04_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_ls_t0_act[4]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex6_ls_t04_offset:ex6_ls_t04_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[ex6_ls_t04_offset:ex6_ls_t04_offset + `EFF_IFAR_WIDTH - 1]),
      .din(ex6_ls_t04_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(ex6_ls_t04_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) ex6_ls_t05_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_ls_t0_act[5]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex6_ls_t05_offset:ex6_ls_t05_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[ex6_ls_t05_offset:ex6_ls_t05_offset + `EFF_IFAR_WIDTH - 1]),
      .din(ex6_ls_t05_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(ex6_ls_t05_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) ex6_ls_t06_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_ls_t0_act[6]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex6_ls_t06_offset:ex6_ls_t06_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[ex6_ls_t06_offset:ex6_ls_t06_offset + `EFF_IFAR_WIDTH - 1]),
      .din(ex6_ls_t06_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(ex6_ls_t06_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) ex6_ls_t07_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_ls_t0_act[7]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex6_ls_t07_offset:ex6_ls_t07_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[ex6_ls_t07_offset:ex6_ls_t07_offset + `EFF_IFAR_WIDTH - 1]),
      .din(ex6_ls_t07_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(ex6_ls_t07_q[62 - `EFF_IFAR_WIDTH:61])
   );

   tri_rlmlatch_p #(.INIT(0)) ex5_val_reg(
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
      .scin(siv1[ex5_val_offset]),
      .scout(sov1[ex5_val_offset]),
      .din(ex5_val_d),
      .dout(ex5_val_q)
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) ex5_ifar_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_ifar_offset:ex5_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[ex5_ifar_offset:ex5_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .din(ex5_ifar_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(ex5_ifar_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmlatch_p #(.INIT(0)) ex5_bh_update_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_bh_update_offset]),
      .scout(sov1[ex5_bh_update_offset]),
      .din(ex5_bh_update_d),
      .dout(ex5_bh_update_q)
   );


   tri_rlmreg_p #(.WIDTH(10), .INIT(0)) ex5_gshare_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_gshare_offset:ex5_gshare_offset + 9]),
      .scout(sov1[ex5_gshare_offset:ex5_gshare_offset + 9]),
      .din(ex5_gshare_d[0:9]),
      .dout(ex5_gshare_q[0:9])
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) ex5_bh0_hist_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_bh0_hist_offset:ex5_bh0_hist_offset + 1]),
      .scout(sov1[ex5_bh0_hist_offset:ex5_bh0_hist_offset + 1]),
      .din(ex5_bh0_hist_d[0:1]),
      .dout(ex5_bh0_hist_q[0:1])
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) ex5_bh1_hist_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_bh1_hist_offset:ex5_bh1_hist_offset + 1]),
      .scout(sov1[ex5_bh1_hist_offset:ex5_bh1_hist_offset + 1]),
      .din(ex5_bh1_hist_d[0:1]),
      .dout(ex5_bh1_hist_q[0:1])
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) ex5_bh2_hist_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_bh2_hist_offset:ex5_bh2_hist_offset + 1]),
      .scout(sov1[ex5_bh2_hist_offset:ex5_bh2_hist_offset + 1]),
      .din(ex5_bh2_hist_d[0:1]),
      .dout(ex5_bh2_hist_q[0:1])
   );


   tri_rlmlatch_p #(.INIT(0)) ex5_br_pred_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_br_pred_offset]),
      .scout(sov1[ex5_br_pred_offset]),
      .din(ex5_br_pred_d),
      .dout(ex5_br_pred_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex5_br_taken_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_br_taken_offset]),
      .scout(sov1[ex5_br_taken_offset]),
      .din(ex5_br_taken_d),
      .dout(ex5_br_taken_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex5_bcctr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_bcctr_offset]),
      .scout(sov1[ex5_bcctr_offset]),
      .din(ex5_bcctr_d),
      .dout(ex5_bcctr_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex5_bclr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_bclr_offset]),
      .scout(sov1[ex5_bclr_offset]),
      .din(ex5_bclr_d),
      .dout(ex5_bclr_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex5_getNIA_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_getNIA_offset]),
      .scout(sov1[ex5_getNIA_offset]),
      .din(ex5_getNIA_d),
      .dout(ex5_getNIA_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex5_lk_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_lk_offset]),
      .scout(sov1[ex5_lk_offset]),
      .din(ex5_lk_d),
      .dout(ex5_lk_q)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) ex5_bh_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_bh_offset:ex5_bh_offset + 1]),
      .scout(sov1[ex5_bh_offset:ex5_bh_offset + 1]),
      .din(ex5_bh_d[0:1]),
      .dout(ex5_bh_q[0:1])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) ex5_bta_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_bta_offset:ex5_bta_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[ex5_bta_offset:ex5_bta_offset + `EFF_IFAR_WIDTH - 1]),
      .din(ex5_bta_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(ex5_bta_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmreg_p #(.WIDTH(8), .INIT(0)) ex5_ls_ptr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_ls_ptr_offset:ex5_ls_ptr_offset + 7]),
      .scout(sov1[ex5_ls_ptr_offset:ex5_ls_ptr_offset + 7]),
      .din(ex5_ls_ptr_d[0:7]),
      .dout(ex5_ls_ptr_q[0:7])
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) ex5_btb_hist_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_btb_hist_offset:ex5_btb_hist_offset + 1]),
      .scout(sov1[ex5_btb_hist_offset:ex5_btb_hist_offset + 1]),
      .din(ex5_btb_hist_d[0:1]),
      .dout(ex5_btb_hist_q[0:1])
   );


   tri_rlmlatch_p #(.INIT(0)) ex5_btb_entry_reg(
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
      .scin(siv1[ex5_btb_entry_offset]),
      .scout(sov1[ex5_btb_entry_offset]),
      .din(ex5_btb_entry_d),
      .dout(ex5_btb_entry_q)
   );


   tri_rlmreg_p #(.WIDTH(128), .INIT(0)) ex5_btb_repl_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_val_q),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex5_btb_repl_offset:ex5_btb_repl_offset + 127]),
      .scout(sov1[ex5_btb_repl_offset:ex5_btb_repl_offset + 127]),
      .din(ex5_btb_repl_d[0:127]),
      .dout(ex5_btb_repl_q[0:127])
   );


   tri_rlmlatch_p #(.INIT(0)) ex5_ls_push_reg(
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
      .scin(siv1[ex5_ls_push_offset]),
      .scout(sov1[ex5_ls_push_offset]),
      .din(ex5_ls_push_d),
      .dout(ex5_ls_push_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex5_ls_pop_reg(
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
      .scin(siv1[ex5_ls_pop_offset]),
      .scout(sov1[ex5_ls_pop_offset]),
      .din(ex5_ls_pop_d),
      .dout(ex5_ls_pop_q)
   );


   tri_rlmlatch_p #(.INIT(0)) ex5_group_reg(
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
      .scin(siv1[ex5_group_offset]),
      .scout(sov1[ex5_group_offset]),
      .din(ex5_group_d),
      .dout(ex5_group_q)
   );

   tri_rlmlatch_p #(.INIT(0)) ex5_flush_reg(
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
      .scin(siv1[ex5_flush_offset]),
      .scout(sov1[ex5_flush_offset]),
      .din(ex5_flush_d),
      .dout(ex5_flush_q)
   );


   tri_rlmreg_p #(.WIDTH(8), .INIT(128)) ex6_ls_t0_ptr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_ls_ptr_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[ex6_ls_t0_ptr_offset:ex6_ls_t0_ptr_offset + 7]),
      .scout(sov1[ex6_ls_t0_ptr_offset:ex6_ls_t0_ptr_offset + 7]),
      .din(ex6_ls_t0_ptr_d[0:7]),
      .dout(ex6_ls_t0_ptr_q[0:7])
   );


   tri_rlmreg_p #(.WIDTH(7), .INIT(0)) bp_config_reg(
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
      .scin(siv1[bp_config_offset:bp_config_offset + 6]),
      .scout(sov1[bp_config_offset:bp_config_offset + 6]),
      .din(bp_config_d[0:6]),
      .dout(bp_config_q[0:6])
   );


   tri_rlmreg_p #(.WIDTH(18), .INIT(0)) br_iu_gshare_reg(
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
      .scin(siv1[br_iu_gshare_offset:br_iu_gshare_offset + 17]),
      .scout(sov1[br_iu_gshare_offset:br_iu_gshare_offset + 17]),
      .din(br_iu_gshare_d[0:17]),
      .dout(br_iu_gshare_q[0:17])
   );


   tri_rlmreg_p #(.WIDTH(8), .INIT(0)) br_iu_ls_ptr_reg(
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
      .scin(siv1[br_iu_ls_ptr_offset:br_iu_ls_ptr_offset + 7]),
      .scout(sov1[br_iu_ls_ptr_offset:br_iu_ls_ptr_offset + 7]),
      .din(br_iu_ls_ptr_d[0:7]),
      .dout(br_iu_ls_ptr_q[0:7])
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) br_iu_ls_data_reg(
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
      .scin(siv1[br_iu_ls_data_offset:br_iu_ls_data_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov1[br_iu_ls_data_offset:br_iu_ls_data_offset + `EFF_IFAR_WIDTH - 1]),
      .din(br_iu_ls_data_d[62 - `EFF_IFAR_WIDTH:61]),
      .dout(br_iu_ls_data_q[62 - `EFF_IFAR_WIDTH:61])
   );


   tri_rlmlatch_p #(.INIT(0)) br_iu_ls_update_reg(
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
      .scin(siv1[br_iu_ls_update_offset]),
      .scout(sov1[br_iu_ls_update_offset]),
      .din(br_iu_ls_update_d),
      .dout(br_iu_ls_update_q)
   );


   tri_rlmlatch_p #(.INIT(0)) br_iu_redirect_reg(
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
      .scin(siv1[br_iu_redirect_offset]),
      .scout(sov1[br_iu_redirect_offset]),
      .din(br_iu_redirect),
      .dout(br_iu_redirect_q)
   );


   tri_rlmlatch_p #(.INIT(0)) cp_flush_reg(
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
      .scin(siv1[cp_flush_offset]),
      .scout(sov1[cp_flush_offset]),
      .din(cp_flush),
      .dout(cp_flush_q)
   );


   tri_rlmlatch_p #(.INIT(0)) iu_flush_reg(
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
      .scin(siv1[iu_flush_offset]),
      .scout(sov1[iu_flush_offset]),
      .din(iu_flush),
      .dout(iu_flush_q)
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(0)) bcache_data0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(bcache_shift[0]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[bcache_data0_offset:bcache_data0_offset + 15]),
      .scout(sov1[bcache_data0_offset:bcache_data0_offset + 15]),
      .din(bcache_data0_d[0:15]),
      .dout(bcache_data0_q[0:15])
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(0)) bcache_data1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(bcache_shift[1]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[bcache_data1_offset:bcache_data1_offset + 15]),
      .scout(sov1[bcache_data1_offset:bcache_data1_offset + 15]),
      .din(bcache_data1_d[0:15]),
      .dout(bcache_data1_q[0:15])
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(0)) bcache_data2_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(bcache_shift[2]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[bcache_data2_offset:bcache_data2_offset + 15]),
      .scout(sov1[bcache_data2_offset:bcache_data2_offset + 15]),
      .din(bcache_data2_d[0:15]),
      .dout(bcache_data2_q[0:15])
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(0)) bcache_data3_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(bcache_shift[3]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[bcache_data3_offset:bcache_data3_offset + 15]),
      .scout(sov1[bcache_data3_offset:bcache_data3_offset + 15]),
      .din(bcache_data3_d[0:15]),
      .dout(bcache_data3_q[0:15])
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(0)) bcache_data4_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(bcache_shift[4]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[bcache_data4_offset:bcache_data4_offset + 15]),
      .scout(sov1[bcache_data4_offset:bcache_data4_offset + 15]),
      .din(bcache_data4_d[0:15]),
      .dout(bcache_data4_q[0:15])
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(0)) bcache_data5_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(bcache_shift[5]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[bcache_data5_offset:bcache_data5_offset + 15]),
      .scout(sov1[bcache_data5_offset:bcache_data5_offset + 15]),
      .din(bcache_data5_d[0:15]),
      .dout(bcache_data5_q[0:15])
   );


   tri_rlmreg_p #(.WIDTH(16), .INIT(0)) bcache_data6_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(bcache_shift[6]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[bcache_data6_offset:bcache_data6_offset + 15]),
      .scout(sov1[bcache_data6_offset:bcache_data6_offset + 15]),
      .din(bcache_data6_d[0:15]),
      .dout(bcache_data6_q[0:15])
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(0)) bcache_data7_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(bcache_shift[7]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv1[bcache_data7_offset:bcache_data7_offset + 15]),
      .scout(sov1[bcache_data7_offset:bcache_data7_offset + 15]),
      .din(bcache_data7_d[0:15]),
      .dout(bcache_data7_q[0:15])
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

   //-----------------------------------------------
   // scan
   //-----------------------------------------------

   assign siv0[0:scan_right0] = {scan_in[0], sov0[0:scan_right0 - 1]};
   assign scan_out[0] = sov0[scan_right0];

   assign siv1[0:scan_right1] = {scan_in[1], sov1[0:scan_right1 - 1]};
   assign scan_out[1] = sov1[scan_right1];

endmodule
