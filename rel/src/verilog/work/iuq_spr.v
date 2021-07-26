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

// *********************************************************************
//
// This is the ENTITY for iuq_spr
//
//
// *********************************************************************

`include "tri_a2o.vh"

module iuq_spr(
   // inputs for power and gnd
   inout                        vdd,
   inout                        gnd,

   // inputs from xx
   input                        iu_slowspr_val_in,
   input                        iu_slowspr_rw_in,
   input [0:1]                  iu_slowspr_etid_in,
   input [0:9]                  iu_slowspr_addr_in,
   input [64-`GPR_WIDTH:63]     iu_slowspr_data_in,
   input                        iu_slowspr_done_in,

   // outputs to xx
   output                       iu_slowspr_val_out,
   output                       iu_slowspr_rw_out,
   output [0:1]                 iu_slowspr_etid_out,
   output [0:9]                 iu_slowspr_addr_out,
   output [64-`GPR_WIDTH:63]    iu_slowspr_data_out,
   output                       iu_slowspr_done_out,

   // Need to flush any read instructions coming around the ring
   input [0:`THREADS-1]         cp_flush,

   // Signals for branch prediction enable
   output [0:3]                 spr_ic_bp_config,
   output [0:5]                 spr_bp_config,

   output [0:1]                 spr_bp_size,

   // decoder match/mask
   output [0:31]                spr_dec_mask,
   output [0:31]                spr_dec_match,
   output [0:`THREADS-1]        spr_single_issue,
   //axu config
   output [0:7]                 iu_au_t0_config_iucr,
`ifndef THREADS1
   output [0:7]                 iu_au_t1_config_iucr,
`endif

   // XU issue priority
   output [0:`THREADS-1]        spr_high_pri_mask,
   output [0:`THREADS-1]        spr_med_pri_mask,
   output [0:5]                 spr_t0_low_pri_count,
`ifndef THREADS1
   output [0:5]                 spr_t1_low_pri_count,
`endif
   input [0:`THREADS-1]         xu_iu_raise_iss_pri,

   input [0:`THREADS-1]         xu_iu_pri_val,
   input [0:2]                  xu_iu_pri,

   input [0:`THREADS-1]         spr_msr_gs,
   input [0:`THREADS-1]         spr_msr_pr,

   output [64-`GPR_WIDTH:51]    spr_ivpr,
   output [64-`GPR_WIDTH:51]    spr_givpr,

   output [62-`EFF_IFAR_ARCH:61] spr_iac1,
   output [62-`EFF_IFAR_ARCH:61] spr_iac2,
   output [62-`EFF_IFAR_ARCH:61] spr_iac3,
   output [62-`EFF_IFAR_ARCH:61] spr_iac4,

   output [0:`THREADS-1]        spr_cpcr_we,
   output [0:4]                 spr_t0_cpcr2_fx0_cnt,
   output [0:4]                 spr_t0_cpcr2_fx1_cnt,
   output [0:4]                 spr_t0_cpcr2_lq_cnt,
   output [0:4]                 spr_t0_cpcr2_sq_cnt,
   output [0:4]                 spr_t0_cpcr3_fu0_cnt,
   output [0:4]                 spr_t0_cpcr3_fu1_cnt,
   output [0:6]                 spr_t0_cpcr3_cp_cnt,
   output [0:4]                 spr_t0_cpcr4_fx0_cnt,
   output [0:4]                 spr_t0_cpcr4_fx1_cnt,
   output [0:4]                 spr_t0_cpcr4_lq_cnt,
   output [0:4]                 spr_t0_cpcr4_sq_cnt,
   output [0:4]                 spr_t0_cpcr5_fu0_cnt,
   output [0:4]                 spr_t0_cpcr5_fu1_cnt,
   output [0:6]                 spr_t0_cpcr5_cp_cnt,
`ifndef THREADS1
   output [0:4]                 spr_t1_cpcr2_fx0_cnt,
   output [0:4]                 spr_t1_cpcr2_fx1_cnt,
   output [0:4]                 spr_t1_cpcr2_lq_cnt,
   output [0:4]                 spr_t1_cpcr2_sq_cnt,
   output [0:4]                 spr_t1_cpcr3_fu0_cnt,
   output [0:4]                 spr_t1_cpcr3_fu1_cnt,
   output [0:6]                 spr_t1_cpcr3_cp_cnt,
   output [0:4]                 spr_t1_cpcr4_fx0_cnt,
   output [0:4]                 spr_t1_cpcr4_fx1_cnt,
   output [0:4]                 spr_t1_cpcr4_lq_cnt,
   output [0:4]                 spr_t1_cpcr4_sq_cnt,
   output [0:4]                 spr_t1_cpcr5_fu0_cnt,
   output [0:4]                 spr_t1_cpcr5_fu1_cnt,
   output [0:6]                 spr_t1_cpcr5_cp_cnt,
`endif
   output [0:4]                 spr_cpcr0_fx0_cnt,
   output [0:4]                 spr_cpcr0_fx1_cnt,
   output [0:4]                 spr_cpcr0_lq_cnt,
   output [0:4]                 spr_cpcr0_sq_cnt,
   output [0:4]                 spr_cpcr1_fu0_cnt,
   output [0:4]                 spr_cpcr1_fu1_cnt,

   input [0:`THREADS-1]         iu_spr_eheir_update,
   input [0:31]                 iu_spr_t0_eheir,
`ifndef THREADS1
   input [0:31]                 iu_spr_t1_eheir,
`endif

   output                       spr_ic_idir_read,
   output [0:1]                 spr_ic_idir_way,
   output [51:57]               spr_ic_idir_row,
   input                        ic_spr_idir_done,
   input [0:2]                  ic_spr_idir_lru,
   input [0:3]                  ic_spr_idir_parity,
   input                        ic_spr_idir_endian,
   input                        ic_spr_idir_valid,
   input [0:28]                 ic_spr_idir_tag,

   output                       spr_ic_icbi_ack_en,
   output                       spr_ic_cls,
   output                       spr_ic_clockgate_dis,
   output                       spr_ic_prefetch_dis,

   output [0:47]                spr_perf_event_mux_ctrls,
   output [0:31]                spr_cp_perf_event_mux_ctrls,

   //pervasive
   (* pin_data="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]      nclk,
   input                        pc_iu_sg_2,
   input                        pc_iu_func_sl_thold_2,
   input                        clkoff_b,
   input                        act_dis,
   input                        tc_ac_ccflush_dc,
   input                        d_mode,
   input                        delay_lclkr,
   input                        mpw1_b,
   input                        mpw2_b,
   input                        scan_in,
   output                       scan_out);

   //scan chain
   parameter                    slowspr_val_offset = 0;
   parameter                    slowspr_rw_offset = slowspr_val_offset + 1;
   parameter                    slowspr_etid_offset = slowspr_rw_offset + 1;
   parameter                    slowspr_addr_offset = slowspr_etid_offset + 2;
   parameter                    slowspr_data_offset = slowspr_addr_offset + 10;
   parameter                    slowspr_done_offset = slowspr_data_offset + `GPR_WIDTH;
   parameter                    ivpr_offset = slowspr_done_offset + 1;
   parameter                    givpr_offset = ivpr_offset + 52 - (64 - `GPR_WIDTH);
   parameter                    immr0_offset = givpr_offset + 52 - (64 - `GPR_WIDTH);
   parameter                    imr0_offset = immr0_offset + 32;
   parameter                    iucr0_offset = imr0_offset + 32;
   parameter                    eheir_offset = iucr0_offset + 16;
   parameter                    iucr1_offset = eheir_offset + 32 * `THREADS;
   parameter                    iucr2_offset = iucr1_offset + 14 * `THREADS;
   parameter                    ppr32_offset = iucr2_offset + 8 * `THREADS;
   parameter                    iac1_offset = ppr32_offset + 3 * `THREADS;
   parameter                    iac2_offset = iac1_offset + `EFF_IFAR_ARCH;
   parameter                    iac3_offset = iac2_offset + `EFF_IFAR_ARCH;
   parameter                    iac4_offset = iac3_offset + `EFF_IFAR_ARCH;
   parameter                    cpcr_we_offset = iac4_offset + `EFF_IFAR_ARCH;
   parameter                    cpcr0_offset = cpcr_we_offset + `THREADS;
   parameter                    cpcr1_offset = cpcr0_offset + 32;
   parameter                    cpcr2_offset = cpcr1_offset + 32;
   parameter                    cpcr3_offset = cpcr2_offset + 32 * `THREADS;
   parameter                    cpcr4_offset = cpcr3_offset + 32 * `THREADS;
   parameter                    cpcr5_offset = cpcr4_offset + 32 * `THREADS;
   parameter                    iulfsr_offset = cpcr5_offset + 32 * `THREADS;
   parameter                    iudbg0_offset = iulfsr_offset + 32;
   parameter                    iudbg1_offset = iudbg0_offset + 9;
   parameter                    iudbg2_offset = iudbg1_offset + 11;
   parameter                    iudbg0_exec_offset = iudbg2_offset + 29;
   parameter                    iudbg0_done_offset = iudbg0_exec_offset + 1;
   parameter                    iullcr_offset = iudbg0_done_offset + 1;
   parameter                    cp_flush_offset = iullcr_offset + 18;
   parameter                    spr_msr_gs_offset = cp_flush_offset + `THREADS;
   parameter                    spr_msr_pr_offset = spr_msr_gs_offset + `THREADS;
   parameter                    xu_iu_pri_offset = spr_msr_pr_offset + `THREADS;
   parameter                    xu_iu_pri_val_offset = xu_iu_pri_offset + 3;
   parameter                    iesr3_offset = xu_iu_pri_val_offset + `THREADS;
   parameter                    iesr1_offset = iesr3_offset + 32;
   parameter                    iesr2_offset = iesr1_offset + 24;
   parameter                    raise_iss_pri_offset = iesr2_offset + 24;
   parameter                    scan_right = raise_iss_pri_offset + `THREADS - 1;

   parameter [32:63]            IMMR0_MASK = 32'b11111111111111111111111111111111;
   parameter [32:63]            IMR0_MASK = 32'b11111111111111111111111111111111;
   parameter [32:63]            IULFSR_MASK = 32'b11111111111111111111111111111111;
   parameter [32:63]            IUDBG0_MASK = 32'b00000000000000000111111111000011;
   parameter [32:63]            IUDBG1_MASK = 32'b00000000000000000000011111111001;
   parameter [32:63]            IUDBG2_MASK = 32'b00011111111111111111111111111111;
   parameter [32:63]            IULLCR_MASK = 32'b00000000000000111100001111110001;
   parameter [32:63]            IUCR0_MASK = 32'b00000000000000001111001111111111;
   parameter [32:63]            IUCR1_MASK = 32'b00000000000000000011000000111111;
   parameter [32:63]            IUCR2_MASK = 32'b11111111000000000000000000000000;
   parameter [32:63]            PPR32_MASK = 32'b00000000000111000000000000000000;
   parameter [32:63]            EVENTMUX_128_MASK = 32'b11111111111111111111111100000000;

   //--------------------------
   // signals
   //--------------------------
   wire                         slowspr_val_act;

   wire                         slowspr_val_d;
   wire                         slowspr_val_l2;
   wire                         slowspr_rw_d;
   wire                         slowspr_rw_l2;
   wire [0:1]                   slowspr_etid_d;
   wire [0:1]                   slowspr_etid_l2;
   wire [0:9]                   slowspr_addr_d;
   wire [0:9]                   slowspr_addr_l2;
   wire [64-`GPR_WIDTH:63]      slowspr_data_d;
   wire [64-`GPR_WIDTH:63]      slowspr_data_l2;
   wire                         slowspr_done_d;
   wire                         slowspr_done_l2;

   wire                         iu_slowspr_done;
   wire [64-`GPR_WIDTH:63]      iu_slowspr_data;

   wire                         ivpr_sel;
   wire                         ivpr_wren;
   wire                         ivpr_rden;
   wire [64-`GPR_WIDTH:51]      ivpr_d;
   wire [64-`GPR_WIDTH:51]      ivpr_l2;

   wire                         givpr_sel;
   wire                         givpr_wren;
   wire                         givpr_rden;
   wire [64-`GPR_WIDTH:51]      givpr_d;
   wire [64-`GPR_WIDTH:51]      givpr_l2;

   wire                         immr0_sel;
   wire                         immr0_wren;
   wire                         immr0_rden;
   wire [32:63]                 immr0_d;
   wire [32:63]                 immr0_l2;

   wire                         imr0_sel;
   wire                         imr0_wren;
   wire                         imr0_rden;
   wire [32:63]                 imr0_d;
   wire [32:63]                 imr0_l2;

   wire                         iulfsr_sel;
   wire                         iulfsr_wren;
   wire                         iulfsr_rden;
   wire [32:63]                 iulfsr_d;
   wire [32:63]                 iulfsr_l2;
   wire [1:28]                  iulfsr;
   wire                         iulfsr_act;

   wire                         iudbg0_sel;
   wire                         iudbg0_wren;
   wire                         iudbg0_rden;
   wire [49:57]                 iudbg0_d;
   wire [49:57]                 iudbg0_l2;
   wire [32:63]                 iudbg0;

   wire                         iudbg0_exec_wren;
   wire                         iudbg0_exec_d;
   wire                         iudbg0_exec_l2;
   wire                         iudbg0_done_wren;
   wire                         iudbg0_done_d;
   wire                         iudbg0_done_l2;

   wire                         iudbg1_sel;
   wire                         iudbg1_wren;
   wire                         iudbg1_rden;
   wire [53:63]                 iudbg1_d;
   wire [53:63]                 iudbg1_l2;
   wire [32:63]                 iudbg1;

   wire                         iudbg2_sel;
   wire                         iudbg2_wren;
   wire                         iudbg2_rden;
   wire [35:63]                 iudbg2_d;
   wire [35:63]                 iudbg2_l2;
   wire [32:63]                 iudbg2;

   wire                         iullcr_sel;
   wire                         iullcr_wren;
   wire                         iullcr_rden;
   wire [46:63]                 iullcr_d;
   wire [46:63]                 iullcr_l2;
   wire [32:63]                 iullcr;

   wire                         iucr0_sel;
   wire                         iucr0_wren;
   wire                         iucr0_rden;
   wire [48:63]                 iucr0_d;
   wire [48:63]                 iucr0_l2;
   wire [32:63]                 iucr0;

   wire [0:`THREADS-1]          eheir_sel;
   wire [0:`THREADS-1]          eheir_wren;
   wire [0:`THREADS-1]          eheir_rden;
   wire [32:63]                 eheir_d[0:`THREADS-1];
   wire [32:63]                 eheir_l2[0:`THREADS-1];
   wire [32:63]                 eheir[0:`THREADS-1];

   wire [0:`THREADS-1]          iucr1_sel;
   wire [0:`THREADS-1]          iucr1_wren;
   wire [0:`THREADS-1]          iucr1_rden;
   wire [50:63]                 iucr1_d[0:`THREADS-1];
   wire [50:63]                 iucr1_l2[0:`THREADS-1];
   wire [32:63]                 iucr1[0:`THREADS-1];

   wire [0:`THREADS-1]          iucr2_sel;
   wire [0:`THREADS-1]          iucr2_wren;
   wire [0:`THREADS-1]          iucr2_rden;
   wire [0:7]                   iucr2_d[0:`THREADS-1];
   wire [0:7]                   iucr2_l2[0:`THREADS-1];
   wire [32:63]                 iucr2[0:`THREADS-1];

   wire [0:`THREADS-1]          ppr32_sel;
   wire [0:`THREADS-1]          ppr32_wren;
   wire [0:`THREADS-1]          ppr32_rden;
   wire [43:45]                 ppr32_d[0:`THREADS-1];
   wire [43:45]                 ppr32_l2[0:`THREADS-1];
   wire [32:63]                 ppr32[0:`THREADS-1];

   wire                         iac1_sel;
   wire                         iac1_wren;
   wire                         iac1_rden;
   wire [62-`EFF_IFAR_ARCH:61]  iac1_d;
   wire [62-`EFF_IFAR_ARCH:61]  iac1_l2;
   wire [0:63]                  iac1;

   wire                         iac2_sel;
   wire                         iac2_wren;
   wire                         iac2_rden;
   wire [62-`EFF_IFAR_ARCH:61]  iac2_d;
   wire [62-`EFF_IFAR_ARCH:61]  iac2_l2;
   wire [0:63]                  iac2;

   wire                         iac3_sel;
   wire                         iac3_wren;
   wire                         iac3_rden;
   wire [62-`EFF_IFAR_ARCH:61]  iac3_d;
   wire [62-`EFF_IFAR_ARCH:61]  iac3_l2;
   wire [0:63]                  iac3;

   wire                         iac4_sel;
   wire                         iac4_wren;
   wire                         iac4_rden;
   wire [62-`EFF_IFAR_ARCH:61]  iac4_d;
   wire [62-`EFF_IFAR_ARCH:61]  iac4_l2;
   wire [0:63]                  iac4;

   wire [0:`THREADS-1]          spr_cpcr_we_d;
   wire [0:`THREADS-1]          spr_cpcr_we_l2;

   wire                         cpcr0_sel;
   wire                         cpcr0_wren;
   wire                         cpcr0_rden;
   wire [32:63]                 cpcr0_d;
   wire [32:63]                 cpcr0_l2;
   wire [32:63]                 cpcr0;

   wire                         cpcr1_sel;
   wire                         cpcr1_wren;
   wire                         cpcr1_rden;
   wire [32:63]                 cpcr1_d;
   wire [32:63]                 cpcr1_l2;
   wire [32:63]                 cpcr1;

   wire [0:`THREADS-1]          cpcr2_sel;
   wire [0:`THREADS-1]          cpcr2_wren;
   wire [0:`THREADS-1]          cpcr2_rden;
   wire [32:63]                 cpcr2_d[0:`THREADS-1];
   wire [32:63]                 cpcr2_l2[0:`THREADS-1];
   wire [32:63]                 cpcr2[0:`THREADS-1];

   wire [0:`THREADS-1]          cpcr3_sel;
   wire [0:`THREADS-1]          cpcr3_wren;
   wire [0:`THREADS-1]          cpcr3_rden;
   wire [32:63]                 cpcr3_d[0:`THREADS-1];
   wire [32:63]                 cpcr3_l2[0:`THREADS-1];
   wire [32:63]                 cpcr3[0:`THREADS-1];

   wire [0:`THREADS-1]          cpcr4_sel;
   wire [0:`THREADS-1]          cpcr4_wren;
   wire [0:`THREADS-1]          cpcr4_rden;
   wire [32:63]                 cpcr4_d[0:`THREADS-1];
   wire [32:63]                 cpcr4_l2[0:`THREADS-1];
   wire [32:63]                 cpcr4[0:`THREADS-1];

   wire [0:`THREADS-1]          cpcr5_sel;
   wire [0:`THREADS-1]          cpcr5_wren;
   wire [0:`THREADS-1]          cpcr5_rden;
   wire [32:63]                 cpcr5_d[0:`THREADS-1];
   wire [32:63]                 cpcr5_l2[0:`THREADS-1];
   wire [32:63]                 cpcr5[0:`THREADS-1];

   wire [0:`THREADS-1]          hi_pri;
   wire [0:`THREADS-1]          lo_pri;

   wire [0:`THREADS-1]          priv_mode;
   wire [0:`THREADS-1]          hypv_mode;

   wire [0:`THREADS-1]          cp_flush_l2;

   wire [0:`THREADS-1]          spr_msr_gs_l2;
   wire [0:`THREADS-1]          spr_msr_pr_l2;

   wire [0:`THREADS-1]          xu_iu_pri_val_l2;
   wire [0:2]                   xu_iu_pri_l2;

   wire                         iesr3_sel;
   wire                         iesr3_wren;
   wire                         iesr3_rden;
   wire [32:63]                 iesr3_d;
   wire [32:63]                 iesr3_l2;

   wire                         iesr1_sel;
   wire                         iesr1_wren;
   wire                         iesr1_rden;
   wire [32:55]                 iesr1_d;
   wire [32:55]                 iesr1_l2;

   wire                         iesr2_sel;
   wire                         iesr2_wren;
   wire                         iesr2_rden;
   wire [32:55]                 iesr2_d;
   wire [32:55]                 iesr2_l2;

   wire [0:`THREADS-1]          xu_iu_raise_iss_pri_l2;

   // pervasive signals
   wire                         tiup;

   wire                         pc_iu_func_sl_thold_1;
   wire                         pc_iu_func_sl_thold_0;
   wire                         pc_iu_func_sl_thold_0_b;
   wire                         pc_iu_sg_1;
   wire                         pc_iu_sg_0;
   wire                         force_t;

   wire [0:scan_right]          siv;
   wire [0:scan_right]          sov;

   wire [0:3]                   slowspr_tid;

   assign tiup = 1'b1;
   //assign tidn = 1'b0;

   //-----------------------------------------------
   // latches
   //-----------------------------------------------
   tri_rlmlatch_p #(.INIT(0)) slowspr_val_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(slowspr_val_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[slowspr_val_offset]),
      .scout(sov[slowspr_val_offset]),
      .din(slowspr_val_d),
      .dout(slowspr_val_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) slowspr_rw_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(slowspr_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[slowspr_rw_offset]),
      .scout(sov[slowspr_rw_offset]),
      .din(slowspr_rw_d),
      .dout(slowspr_rw_l2)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) slowspr_etid_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(slowspr_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[slowspr_etid_offset:slowspr_etid_offset + 2 - 1]),
      .scout(sov[slowspr_etid_offset:slowspr_etid_offset + 2 - 1]),
      .din(slowspr_etid_d),
      .dout(slowspr_etid_l2)
   );

   tri_rlmreg_p #(.WIDTH(10), .INIT(0)) slowspr_addr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(slowspr_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[slowspr_addr_offset:slowspr_addr_offset + 10 - 1]),
      .scout(sov[slowspr_addr_offset:slowspr_addr_offset + 10 - 1]),
      .din(slowspr_addr_d),
      .dout(slowspr_addr_l2)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0)) slowspr_data_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(slowspr_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[slowspr_data_offset:slowspr_data_offset + `GPR_WIDTH - 1]),
      .scout(sov[slowspr_data_offset:slowspr_data_offset + `GPR_WIDTH - 1]),
      .din(slowspr_data_d),
      .dout(slowspr_data_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) slowspr_done_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(slowspr_val_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[slowspr_done_offset]),
      .scout(sov[slowspr_done_offset]),
      .din(slowspr_done_d),
      .dout(slowspr_done_l2)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH-12), .INIT(0)) ivpr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ivpr_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[ivpr_offset:ivpr_offset + (`GPR_WIDTH-12) - 1]),
      .scout(sov[ivpr_offset:ivpr_offset + (`GPR_WIDTH-12) - 1]),
      .din(ivpr_d),
      .dout(ivpr_l2)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH-12), .INIT(0)) givpr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(givpr_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[givpr_offset:givpr_offset + (`GPR_WIDTH-12) - 1]),
      .scout(sov[givpr_offset:givpr_offset + (`GPR_WIDTH-12) - 1]),
      .din(givpr_d),
      .dout(givpr_l2)
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(65535)) immr0a_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(immr0_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[immr0_offset:immr0_offset + 16 - 1]),
      .scout(sov[immr0_offset:immr0_offset + 16 - 1]),
      .din(immr0_d[32:47]),
      .dout(immr0_l2[32:47])
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(65535)) immr0b_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(immr0_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[immr0_offset + 16:immr0_offset + 32 - 1]),
      .scout(sov[immr0_offset + 16:immr0_offset + 32 - 1]),
      .din(immr0_d[48:63]),
      .dout(immr0_l2[48:63])
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0)) imr0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(imr0_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[imr0_offset:imr0_offset + 32 - 1]),
      .scout(sov[imr0_offset:imr0_offset + 32 - 1]),
      .din(imr0_d),
      .dout(imr0_l2)
   );

   //init 0x000000F9
   tri_rlmreg_p #(.WIDTH(16), .INIT(`INIT_IUCR0)) iucr0_reg(
      //  generic map (width => iucr0_l2'length, init => 249, `EXPAND_TYPE => `EXPAND_TYPE)
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iucr0_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iucr0_offset:iucr0_offset + 16 - 1]),
      .scout(sov[iucr0_offset:iucr0_offset + 16 - 1]),
      .din(iucr0_d),
      .dout(iucr0_l2)
   );

   generate
      begin : xhdl1
         genvar                       i;
         for (i = 0; i <= `THREADS - 1; i = i + 1)
         begin : thread_regs

            //init 0x00001000
            tri_rlmreg_p #(.WIDTH(32), .INIT(0)) eheir_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(eheir_wren[i]),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .sg(pc_iu_sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin(siv[eheir_offset + i * 32:eheir_offset + (i + 1) * 32 - 1]),
               .scout(sov[eheir_offset + i * 32:eheir_offset + (i + 1) * 32 - 1]),
               .din(eheir_d[i]),
               .dout(eheir_l2[i])
            );

            //init 0x00001000
            tri_rlmreg_p #(.WIDTH(14), .INIT(4096)) iucr1_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(iucr1_wren[i]),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .sg(pc_iu_sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin(siv[iucr1_offset + i * 14:iucr1_offset + (i + 1) * 14 - 1]),
               .scout(sov[iucr1_offset + i * 14:iucr1_offset + (i + 1) * 14 - 1]),
               .din(iucr1_d[i]),
               .dout(iucr1_l2[i])
            );

            //init 0x00000000
            tri_rlmreg_p #(.WIDTH(8), .INIT(0)) iucr2_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(iucr2_wren[i]),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .sg(pc_iu_sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin(siv[iucr2_offset + i * 8:iucr2_offset + (i + 1) * 8 - 1]),
               .scout(sov[iucr2_offset + i * 8:iucr2_offset + (i + 1) * 8 - 1]),
               .din(iucr2_d[i]),
               .dout(iucr2_l2[i])
            );

            //init 0x000c0000
            tri_rlmreg_p #(.WIDTH(3), .INIT(3)) ppr32_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(ppr32_wren[i]),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .sg(pc_iu_sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin(siv[ppr32_offset + i * 3:ppr32_offset + (i + 1) * 3 - 1]),
               .scout(sov[ppr32_offset + i * 3:ppr32_offset + (i + 1) * 3 - 1]),
               .din(ppr32_d[i]),
               .dout(ppr32_l2[i])
            );

            // hex 0A0A0E0A = 168431114
            tri_rlmreg_p #(.WIDTH(32), .INIT(168431114)) cpcr2_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(cpcr2_wren[i]),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .sg(pc_iu_sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin(siv[cpcr2_offset + i * 32:cpcr2_offset + (i + 1) * 32 - 1]),
               .scout(sov[cpcr2_offset + i * 32:cpcr2_offset + (i + 1) * 32 - 1]),
               .din(cpcr2_d[i]),
               .dout(cpcr2_l2[i])
            );

            // hex 000A0020 = 655392
            tri_rlmreg_p #(.WIDTH(32), .INIT(655392)) cpcr3_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(cpcr3_wren[i]),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .sg(pc_iu_sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin(siv[cpcr3_offset + i * 32:cpcr3_offset + (i + 1) * 32 - 1]),
               .scout(sov[cpcr3_offset + i * 32:cpcr3_offset + (i + 1) * 32 - 1]),
               .din(cpcr3_d[i]),
               .dout(cpcr3_l2[i])
            );

            // hex 06060806 = 101058566
            tri_rlmreg_p #(.WIDTH(32), .INIT(101058566)) cpcr4_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(cpcr4_wren[i]),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .sg(pc_iu_sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin(siv[cpcr4_offset + i * 32:cpcr4_offset + (i + 1) * 32 - 1]),
               .scout(sov[cpcr4_offset + i * 32:cpcr4_offset + (i + 1) * 32 - 1]),
               .din(cpcr4_d[i]),
               .dout(cpcr4_l2[i])
            );

            // hex 00060010 = 393232
            tri_rlmreg_p #(.WIDTH(32), .INIT(393232)) cpcr5_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(cpcr5_wren[i]),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .sg(pc_iu_sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin(siv[cpcr5_offset + i * 32:cpcr5_offset + (i + 1) * 32 - 1]),
               .scout(sov[cpcr5_offset + i * 32:cpcr5_offset + (i + 1) * 32 - 1]),
               .din(cpcr5_d[i]),
               .dout(cpcr5_l2[i])
            );
         end
      end
   endgenerate

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) cpcr_we_reg(
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
      .scin(siv[cpcr_we_offset:cpcr_we_offset + `THREADS-1]),
      .scout(sov[cpcr_we_offset:cpcr_we_offset + `THREADS-1]),
      .din(spr_cpcr_we_d),
      .dout(spr_cpcr_we_l2)
   );

   // hex 0C0C100C = 202117132
   tri_rlmreg_p #(.WIDTH(32), .INIT(202117132)) cpcr0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cpcr0_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[cpcr0_offset:cpcr0_offset + 32-1]),
      .scout(sov[cpcr0_offset:cpcr0_offset + 32-1]),
      .din(cpcr0_d),
      .dout(cpcr0_l2)
   );

   // hex 000C0C00 = 789504
   tri_rlmreg_p #(.WIDTH(32), .INIT(789504)) cpcr1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cpcr1_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[cpcr1_offset:cpcr1_offset + 32-1]),
      .scout(sov[cpcr1_offset:cpcr1_offset + 32-1]),
      .din(cpcr1_d),
      .dout(cpcr1_l2)
   );

   //init 0x00000000
   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0)) iac1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iac1_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iac1_offset:iac1_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[iac1_offset:iac1_offset + `EFF_IFAR_ARCH - 1]),
      .din(iac1_d),
      .dout(iac1_l2)
   );

   //init 0x00000000
   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0)) iac2_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iac2_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iac2_offset:iac2_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[iac2_offset:iac2_offset + `EFF_IFAR_ARCH - 1]),
      .din(iac2_d),
      .dout(iac2_l2)
   );

   //init 0x00000000
   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0)) iac3_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iac3_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iac3_offset:iac3_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[iac3_offset:iac3_offset + `EFF_IFAR_ARCH - 1]),
      .din(iac3_d),
      .dout(iac3_l2)
   );

   //init 0x00000000
   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0)) iac4_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iac4_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iac4_offset:iac4_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[iac4_offset:iac4_offset + `EFF_IFAR_ARCH - 1]),
      .din(iac4_d),
      .dout(iac4_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(32), .INIT(26)) iulfsr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iulfsr_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iulfsr_offset:iulfsr_offset + 32 - 1]),
      .scout(sov[iulfsr_offset:iulfsr_offset + 32 - 1]),
      .din(iulfsr_d),
      .dout(iulfsr_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(9), .INIT(0)) iudbg0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iudbg0_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iudbg0_offset:iudbg0_offset + 9 - 1]),
      .scout(sov[iudbg0_offset:iudbg0_offset + 9 - 1]),
      .din(iudbg0_d),
      .dout(iudbg0_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iudbg0_done_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iudbg0_done_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iudbg0_done_offset]),
      .scout(sov[iudbg0_done_offset]),
      .din(iudbg0_done_d),
      .dout(iudbg0_done_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iudbg0_exec_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iudbg0_exec_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iudbg0_exec_offset]),
      .scout(sov[iudbg0_exec_offset]),
      .din(iudbg0_exec_d),
      .dout(iudbg0_exec_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(11), .INIT(0)) iudbg1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iudbg1_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iudbg1_offset:iudbg1_offset + 11 - 1]),
      .scout(sov[iudbg1_offset:iudbg1_offset + 11 - 1]),
      .din(iudbg1_d),
      .dout(iudbg1_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(29), .INIT(0)) iudbg2_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iudbg2_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iudbg2_offset:iudbg2_offset + 29 - 1]),
      .scout(sov[iudbg2_offset:iudbg2_offset + 29 - 1]),
      .din(iudbg2_d),
      .dout(iudbg2_l2)
   );

   //init 0x00020040
   tri_ser_rlmreg_p #(.WIDTH(18), .INIT(131136)) iullcr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iullcr_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iullcr_offset:iullcr_offset + 18 - 1]),
      .scout(sov[iullcr_offset:iullcr_offset + 18 - 1]),
      .din(iullcr_d),
      .dout(iullcr_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) cp_flush_latch(
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
      .scin(siv[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
      .scout(sov[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
      .din(cp_flush),
      .dout(cp_flush_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) spr_msr_gs_latch(
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
      .scin(siv[spr_msr_gs_offset:spr_msr_gs_offset + `THREADS - 1]),
      .scout(sov[spr_msr_gs_offset:spr_msr_gs_offset + `THREADS - 1]),
      .din(spr_msr_gs),
      .dout(spr_msr_gs_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) spr_msr_pr_latch(
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
      .scin(siv[spr_msr_pr_offset:spr_msr_pr_offset + `THREADS - 1]),
      .scout(sov[spr_msr_pr_offset:spr_msr_pr_offset + `THREADS - 1]),
      .din(spr_msr_pr),
      .dout(spr_msr_pr_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(3), .INIT(0)) xu_iu_pri_reg(
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
      .scin(siv[xu_iu_pri_offset:xu_iu_pri_offset + 3 - 1]),
      .scout(sov[xu_iu_pri_offset:xu_iu_pri_offset + 3 - 1]),
      .din(xu_iu_pri),
      .dout(xu_iu_pri_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) xu_iu_pri_val_reg(
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
      .scin(siv[xu_iu_pri_val_offset:xu_iu_pri_val_offset + `THREADS - 1]),
      .scout(sov[xu_iu_pri_val_offset:xu_iu_pri_val_offset + `THREADS - 1]),
      .din(xu_iu_pri_val),
      .dout(xu_iu_pri_val_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(32), .INIT(0)) iesr3_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iesr3_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iesr3_offset:iesr3_offset + 32 - 1]),
      .scout(sov[iesr3_offset:iesr3_offset + 32 - 1]),
      .din(iesr3_d),
      .dout(iesr3_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(24), .INIT(0)) iesr1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iesr1_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iesr1_offset:iesr1_offset + 24 - 1]),
      .scout(sov[iesr1_offset:iesr1_offset + 24 - 1]),
      .din(iesr1_d),
      .dout(iesr1_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(24), .INIT(0)) iesr2_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iesr2_wren),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iesr2_offset:iesr2_offset + 24 - 1]),
      .scout(sov[iesr2_offset:iesr2_offset + 24 - 1]),
      .din(iesr2_d),
      .dout(iesr2_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) raise_iss_pri_reg(
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
      .scin(siv[raise_iss_pri_offset:raise_iss_pri_offset + `THREADS - 1]),
      .scout(sov[raise_iss_pri_offset:raise_iss_pri_offset + `THREADS - 1]),
      .din(xu_iu_raise_iss_pri),
      .dout(xu_iu_raise_iss_pri_l2)
   );

   //-----------------------------------------------
   // inputs
   //-----------------------------------------------
   assign slowspr_val_d = iu_slowspr_val_in & ~|(slowspr_tid[0:`THREADS - 1] & cp_flush_l2);
   assign slowspr_rw_d = iu_slowspr_rw_in;
   assign slowspr_etid_d = iu_slowspr_etid_in;
   assign slowspr_addr_d = iu_slowspr_addr_in;
   assign slowspr_data_d = iu_slowspr_data_in;
   assign slowspr_done_d = iu_slowspr_done_in;

   //-----------------------------------------------
   // outputs
   //-----------------------------------------------
   assign slowspr_tid = (iu_slowspr_etid_in == 2'b00) ? 4'b1000 :
                        (iu_slowspr_etid_in == 2'b01) ? 4'b0100 :
                        (iu_slowspr_etid_in == 2'b10) ? 4'b0010 :
                        (iu_slowspr_etid_in == 2'b11) ? 4'b0001 :
                        4'b0000;
   assign iu_slowspr_val_out = slowspr_val_l2;
   assign iu_slowspr_rw_out = slowspr_rw_l2;
   assign iu_slowspr_etid_out = slowspr_etid_l2;
   assign iu_slowspr_addr_out = slowspr_addr_l2;
   assign iu_slowspr_data_out = slowspr_data_l2 | iu_slowspr_data;
   assign iu_slowspr_done_out = slowspr_done_l2 | iu_slowspr_done;

   assign spr_dec_mask[0:31] = immr0_l2[32:63];
   assign spr_dec_match[0:31] = imr0_l2[32:63];

   assign spr_ic_clockgate_dis = iucr0_l2[48];
   assign spr_ic_prefetch_dis = iucr0_l2[49];
   assign spr_ic_cls = iucr0_l2[50];
   assign spr_ic_icbi_ack_en = iucr0_l2[51];

   assign spr_ic_bp_config = iucr0_l2[56:59];
   assign spr_bp_config = {iucr0_l2[60:63], iucr0_l2[54:55]};
   assign spr_single_issue = {`THREADS{1'b0}};
   assign iu_au_t0_config_iucr = iucr2_l2[0];
`ifndef THREADS1
   assign iu_au_t1_config_iucr = iucr2_l2[1];
`endif
   assign spr_ivpr = ivpr_l2;
   assign spr_givpr = givpr_l2;

   assign spr_iac1 = iac1_l2;
   assign spr_iac2 = iac2_l2;
   assign spr_iac3 = iac3_l2;
   assign spr_iac4 = iac4_l2;

   assign spr_cpcr_we = spr_cpcr_we_l2;

   assign spr_t0_cpcr2_fx0_cnt = cpcr2_l2[0][35:39];
   assign spr_t0_cpcr2_fx1_cnt = cpcr2_l2[0][43:47];
   assign spr_t0_cpcr2_lq_cnt = cpcr2_l2[0][51:55];
   assign spr_t0_cpcr2_sq_cnt = cpcr2_l2[0][59:63];
   assign spr_t0_cpcr3_fu0_cnt = cpcr3_l2[0][43:47];
   assign spr_t0_cpcr3_fu1_cnt = cpcr3_l2[0][51:55];
   assign spr_t0_cpcr3_cp_cnt = cpcr3_l2[0][57:63];
   assign spr_t0_cpcr4_fx0_cnt = cpcr4_l2[0][35:39];
   assign spr_t0_cpcr4_fx1_cnt = cpcr4_l2[0][43:47];
   assign spr_t0_cpcr4_lq_cnt = cpcr4_l2[0][51:55];
   assign spr_t0_cpcr4_sq_cnt = cpcr4_l2[0][59:63];
   assign spr_t0_cpcr5_fu0_cnt = cpcr5_l2[0][43:47];
   assign spr_t0_cpcr5_fu1_cnt = cpcr5_l2[0][51:55];
   assign spr_t0_cpcr5_cp_cnt = cpcr5_l2[0][57:63];
`ifndef THREADS1
   assign spr_t1_cpcr2_fx0_cnt = cpcr2_l2[1][35:39];
   assign spr_t1_cpcr2_fx1_cnt = cpcr2_l2[1][43:47];
   assign spr_t1_cpcr2_lq_cnt = cpcr2_l2[1][51:55];
   assign spr_t1_cpcr2_sq_cnt = cpcr2_l2[1][59:63];
   assign spr_t1_cpcr3_fu0_cnt = cpcr3_l2[1][43:47];
   assign spr_t1_cpcr3_fu1_cnt = cpcr3_l2[1][51:55];
   assign spr_t1_cpcr3_cp_cnt = cpcr3_l2[1][57:63];
   assign spr_t1_cpcr4_fx0_cnt = cpcr4_l2[1][35:39];
   assign spr_t1_cpcr4_fx1_cnt = cpcr4_l2[1][43:47];
   assign spr_t1_cpcr4_lq_cnt = cpcr4_l2[1][51:55];
   assign spr_t1_cpcr4_sq_cnt = cpcr4_l2[1][59:63];
   assign spr_t1_cpcr5_fu0_cnt = cpcr5_l2[1][43:47];
   assign spr_t1_cpcr5_fu1_cnt = cpcr5_l2[1][51:55];
   assign spr_t1_cpcr5_cp_cnt = cpcr5_l2[1][57:63];
`endif
   assign spr_cpcr0_fx0_cnt = cpcr0_l2[35:39];
   assign spr_cpcr0_fx1_cnt = cpcr0_l2[43:47];
   assign spr_cpcr0_lq_cnt = cpcr0_l2[51:55];
   assign spr_cpcr0_sq_cnt = cpcr0_l2[59:63];
   assign spr_cpcr1_fu0_cnt = cpcr1_l2[43:47];
   assign spr_cpcr1_fu1_cnt = cpcr1_l2[51:55];

   assign spr_t0_low_pri_count = iucr1_l2[0][58:63];
`ifndef THREADS1
   assign spr_t1_low_pri_count = iucr1_l2[1][58:63];
`endif

   assign spr_bp_size = 2'b0;

   assign spr_ic_idir_read = iudbg0_exec_l2;
   assign spr_ic_idir_way = iudbg0_l2[49:50];
   assign spr_ic_idir_row = iudbg0_l2[51:57];

   assign spr_perf_event_mux_ctrls = {iesr1_l2[32:55], iesr2_l2[32:55]};
   assign spr_cp_perf_event_mux_ctrls = iesr3_l2[32:63];

   //-----------------------------------------------
   // register select
   //-----------------------------------------------
   assign slowspr_val_act = slowspr_val_d | slowspr_val_l2;

   assign ivpr_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b0000111111;		//63
   assign givpr_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b0110111111;		//447
   assign immr0_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1101110001;		//881
   assign imr0_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1101110000;		//880
   assign iulfsr_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1101111011;		//891
   assign iudbg0_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1101111000;		//888
   assign iudbg1_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1101111001;		//889
   assign iudbg2_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1101111010;		//890
   assign iullcr_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1101111100;		//892
   assign iucr0_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1111110011;		//1011
   assign cpcr0_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1100110000;     //816
   assign cpcr1_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1100110001;     //817
   assign eheir_sel[0] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b0000110100) & slowspr_etid_l2 === 2'b00;		//52
   assign iucr1_sel[0] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b1101110011) & slowspr_etid_l2 === 2'b00;		//883,ti
   assign iucr2_sel[0] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b1101110100) & slowspr_etid_l2 === 2'b00;		//884,ti
   assign ppr32_sel[0] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b1110000010) & slowspr_etid_l2 === 2'b00;		//898,ti
   assign cpcr2_sel[0] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b1100110010) & slowspr_etid_l2 === 2'b00;		//818
   assign cpcr3_sel[0] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b1100110100) & slowspr_etid_l2 === 2'b00;		//820
   assign cpcr4_sel[0] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b1100110101) & slowspr_etid_l2 === 2'b00;		//821
   assign cpcr5_sel[0] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b1100110110) & slowspr_etid_l2 === 2'b00;		//822

`ifndef THREADS1
   assign eheir_sel[1] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b0000110100) & slowspr_etid_l2 === 2'b01;		//52
   assign iucr1_sel[1] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b1101110011) & slowspr_etid_l2 === 2'b01;		//883,ti
   assign iucr2_sel[1] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b1101110100) & slowspr_etid_l2 === 2'b01;		//884,ti
   assign ppr32_sel[1] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b1110000010) & slowspr_etid_l2 === 2'b01;		//898,ti
   assign cpcr2_sel[1] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b1100110010) & slowspr_etid_l2 === 2'b01;		//818
   assign cpcr3_sel[1] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b1100110100) & slowspr_etid_l2 === 2'b01;		//820
   assign cpcr4_sel[1] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b1100110101) & slowspr_etid_l2 === 2'b01;		//821
   assign cpcr5_sel[1] = slowspr_val_l2 & (slowspr_addr_l2 == 10'b1100110110) & slowspr_etid_l2 === 2'b01;		//822
`endif

   assign iac1_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b0100111000;		//312
   assign iac2_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b0100111001;		//313
   assign iac3_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b0100111010;		//314
   assign iac4_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b0100111011;		//315
   assign iesr3_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1110011100;		//924
   assign iesr1_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1110010010;		//914
   assign iesr2_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1110010011;		//915

   assign iu_slowspr_done = (ivpr_sel | givpr_sel | immr0_sel | imr0_sel | iulfsr_sel | iullcr_sel | iucr0_sel | iudbg0_sel | iudbg1_sel | iudbg2_sel) |
                            (|eheir_sel) | (|iucr1_sel) | (|iucr2_sel) | (|ppr32_sel) | iac1_sel | iac2_sel | iac3_sel | iac4_sel | cpcr0_sel |
                            cpcr1_sel | (|cpcr2_sel) | (|cpcr3_sel) | (|cpcr4_sel) | (|cpcr5_sel) |iesr3_sel | iesr1_sel | iesr2_sel;

   //-----------------------------------------------
   // set priority levels
   //-----------------------------------------------
   assign priv_mode = (~spr_msr_pr_l2);
   assign hypv_mode = (~spr_msr_pr_l2) & (~spr_msr_gs_l2);

   generate
      begin : priset
         genvar i;
         for (i = 0; i <= `THREADS - 1; i = i + 1)
         begin : pricalc
            assign lo_pri[i] = ~xu_iu_raise_iss_pri_l2[i] &
                               (ppr32_l2[i][43:45] == 3'b000 |
                                ppr32_l2[i][43:45] == 3'b001 |
                                ppr32_l2[i][43:45] == 3'b010);

            assign hi_pri[i] =(ppr32_l2[i][43:45] == 3'b100 & iucr1_l2[i][50:51] == 2'b00) |
                              (ppr32_l2[i][43:45] == 3'b101 & (iucr1_l2[i][50:51] == 2'b00 | iucr1_l2[i][50:51] == 2'b01)) |
                              (ppr32_l2[i][43:45] == 3'b110 & (iucr1_l2[i][50:51] == 2'b00 | iucr1_l2[i][50:51] == 2'b01 | iucr1_l2[i][50:51] == 2'b10)) |
                               ppr32_l2[i][43:45] == 3'b111;

            assign spr_high_pri_mask[i] = hi_pri[i];
            assign spr_med_pri_mask[i] = ~hi_pri[i] & ~lo_pri[i];
         end
      end
   endgenerate


   //-----------------------------------------------
   // register write
   //-----------------------------------------------
   assign iudbg0_exec_wren = iudbg0_wren | iudbg0_exec_l2;
   assign iudbg0_done_wren = iudbg0_wren | ic_spr_idir_done;

   assign iudbg1_wren = ic_spr_idir_done;
   assign iudbg2_wren = ic_spr_idir_done;

   assign ivpr_wren = ivpr_sel & slowspr_rw_l2 == 1'b0;
   assign givpr_wren = givpr_sel & slowspr_rw_l2 == 1'b0;
   assign immr0_wren = immr0_sel & slowspr_rw_l2 == 1'b0;
   assign imr0_wren = imr0_sel & slowspr_rw_l2 == 1'b0;
   assign iulfsr_wren = iulfsr_sel & slowspr_rw_l2 == 1'b0;
   assign iudbg0_wren = iudbg0_sel & slowspr_rw_l2 == 1'b0;
   assign iullcr_wren = iullcr_sel & slowspr_rw_l2 == 1'b0;
   assign iucr0_wren = iucr0_sel & slowspr_rw_l2 == 1'b0;
   assign eheir_wren[0] = ((slowspr_rw_l2 == 1'b0) & eheir_sel[0]) | iu_spr_eheir_update[0];
`ifndef THREADS1
   assign eheir_wren[1] = ((slowspr_rw_l2 == 1'b0) & eheir_sel[1]) | iu_spr_eheir_update[1];
`endif
   assign iucr1_wren = ({`THREADS{slowspr_rw_l2 == 1'b0}} & iucr1_sel);
   assign iucr2_wren = ({`THREADS{slowspr_rw_l2 == 1'b0}} & iucr2_sel);
   assign iac1_wren = iac1_sel & slowspr_rw_l2 == 1'b0;
   assign iac2_wren = iac2_sel & slowspr_rw_l2 == 1'b0;
   assign iac3_wren = iac3_sel & slowspr_rw_l2 == 1'b0;
   assign iac4_wren = iac4_sel & slowspr_rw_l2 == 1'b0;
   assign cpcr0_wren = cpcr0_sel & slowspr_rw_l2 == 1'b0;
   assign cpcr1_wren = cpcr1_sel & slowspr_rw_l2 == 1'b0;
   assign cpcr2_wren = ({`THREADS{slowspr_rw_l2 == 1'b0}} & cpcr2_sel);
   assign cpcr3_wren = ({`THREADS{slowspr_rw_l2 == 1'b0}} & cpcr3_sel);
   assign cpcr4_wren = ({`THREADS{slowspr_rw_l2 == 1'b0}} & cpcr4_sel);
   assign cpcr5_wren = ({`THREADS{slowspr_rw_l2 == 1'b0}} & cpcr5_sel);
   assign iesr3_wren = iesr3_sel & slowspr_rw_l2 == 1'b0;
   assign iesr1_wren = iesr1_sel & slowspr_rw_l2 == 1'b0;
   assign iesr2_wren = iesr2_sel & slowspr_rw_l2 == 1'b0;

   assign ppr32_wren[0] = ((ppr32_sel[0] & slowspr_rw_l2 == 1'b0) | xu_iu_pri_val_l2[0]) &
                          ((ppr32_d[0] == 3'b001 & priv_mode[0]) | (ppr32_d[0] == 3'b010) | (ppr32_d[0] == 3'b011) |
                           (ppr32_d[0] == 3'b100) | (ppr32_d[0] == 3'b101 & priv_mode[0]) | (ppr32_d[0] == 3'b110 & priv_mode[0]) |
                           (ppr32_d[0] == 3'b111 & hypv_mode[0]));

`ifndef THREADS1
   assign ppr32_wren[1] = ((ppr32_sel[1] & slowspr_rw_l2 == 1'b0) | xu_iu_pri_val_l2[1]) &
                          ((ppr32_d[1] == 3'b001 & priv_mode[1]) | (ppr32_d[1] == 3'b010) | (ppr32_d[1] == 3'b011) |
                           (ppr32_d[1] == 3'b100) | (ppr32_d[1] == 3'b101 & priv_mode[1]) | (ppr32_d[1] == 3'b110 & priv_mode[1]) |
                           (ppr32_d[1] == 3'b111 & hypv_mode[1]));
`endif

   assign ivpr_d = slowspr_data_l2[64 - `GPR_WIDTH:51];
   assign givpr_d = slowspr_data_l2[64 - `GPR_WIDTH:51];

   assign immr0_d = IMMR0_MASK & slowspr_data_l2[32:63];
   assign imr0_d = IMR0_MASK & slowspr_data_l2[32:63];

   assign iulfsr[1:28] = iulfsr_l2[32:59];
   assign iulfsr_d = (iulfsr_wren == 1'b1) ? IULFSR_MASK & slowspr_data_l2[32:63] :
   	{(iulfsr[28] ^ iulfsr[27] ^ iulfsr[26] ^ iulfsr[25] ^ iulfsr[24] ^ iulfsr[8]), iulfsr[1:27], iulfsr_l2[60:63]};
   assign iulfsr_act = iulfsr_wren;

   assign iudbg0_d = IUDBG0_MASK[49:57] & slowspr_data_l2[49:57];
   assign iudbg0_exec_d = (iudbg0_wren == 1'b1) ? IUDBG0_MASK[62] & slowspr_data_l2[62] :
   	1'b0;
   assign iudbg0_done_d = (iudbg0_wren == 1'b1) ? IUDBG0_MASK[63] & slowspr_data_l2[63] :
   			ic_spr_idir_done;

   assign iudbg1_d = IUDBG1_MASK[53:63] & ({ic_spr_idir_lru[0:2], ic_spr_idir_parity[0:3], ic_spr_idir_endian, 2'b00, ic_spr_idir_valid});
   assign iudbg2_d = IUDBG2_MASK[35:63] & ic_spr_idir_tag[0:28];

   assign iullcr_d = IULLCR_MASK[46:63] & slowspr_data_l2[46:63];

   assign iucr0_d = IUCR0_MASK[48:63] & ({slowspr_data_l2[48:49], iucr0_l2[50], slowspr_data_l2[51:63]});

        assign eheir_d[0] = (iu_spr_eheir_update[0] == 1'b1) ? iu_spr_t0_eheir : slowspr_data_l2[32:63];
  	assign iucr1_d[0] = IUCR1_MASK[50:63] & slowspr_data_l2[50:63];
  	assign iucr2_d[0] = IUCR2_MASK[32:39] & slowspr_data_l2[32:39];
  	assign ppr32_d[0] = (xu_iu_pri_val_l2[0] == 1'b1) ? PPR32_MASK[43:45] & xu_iu_pri_l2[0:2] : PPR32_MASK[43:45] & slowspr_data_l2[43:45];
  	assign spr_cpcr_we_d[0] = (~slowspr_etid_l2[1] & cpcr0_wren) | (~slowspr_etid_l2[1] & cpcr1_wren) | cpcr2_wren[0] | cpcr3_wren[0] | cpcr4_wren[0] | cpcr5_wren[0];
	assign cpcr0_d    = {3'b0, slowspr_data_l2[35:39], 3'b0, slowspr_data_l2[43:47], 3'b0, slowspr_data_l2[51:55], 3'b0, slowspr_data_l2[59:63]};
	assign cpcr1_d    = {11'b0, slowspr_data_l2[43:47], 3'b0, slowspr_data_l2[51:55], 8'b0};
	assign cpcr2_d[0] = {3'b0, slowspr_data_l2[35:39], 3'b0, slowspr_data_l2[43:47], 3'b0, slowspr_data_l2[51:55], 3'b0, slowspr_data_l2[59:63]};
	assign cpcr3_d[0] = {11'b0, slowspr_data_l2[43:47], 3'b0, slowspr_data_l2[51:55], 1'b0, slowspr_data_l2[57:63]};
	assign cpcr4_d[0] = {3'b0, slowspr_data_l2[35:39], 3'b0, slowspr_data_l2[43:47], 3'b0, slowspr_data_l2[51:55], 3'b0, slowspr_data_l2[59:63]};
	assign cpcr5_d[0] = {11'b0, slowspr_data_l2[43:47], 3'b0, slowspr_data_l2[51:55], 1'b0, slowspr_data_l2[57:63]};

`ifndef THREADS1
        assign eheir_d[1] = (iu_spr_eheir_update[1] == 1'b1) ? iu_spr_t1_eheir : slowspr_data_l2[32:63];
  	assign iucr1_d[1] = IUCR1_MASK[50:63] & slowspr_data_l2[50:63];
  	assign iucr2_d[1] = IUCR2_MASK[32:39] & slowspr_data_l2[32:39];
  	assign ppr32_d[1] = (xu_iu_pri_val_l2[1] == 1'b1) ? PPR32_MASK[43:45] & xu_iu_pri_l2[0:2] : PPR32_MASK[43:45] & slowspr_data_l2[43:45];
  	assign spr_cpcr_we_d[1] = (slowspr_etid_l2[1] & cpcr0_wren) | (slowspr_etid_l2[1] & cpcr1_wren) | cpcr2_wren[1] | cpcr3_wren[1] | cpcr4_wren[1] | cpcr5_wren[1];
	assign cpcr2_d[1] = {3'b0, slowspr_data_l2[35:39], 3'b0, slowspr_data_l2[43:47], 3'b0, slowspr_data_l2[51:55], 3'b0, slowspr_data_l2[59:63]};
	assign cpcr3_d[1] = {11'b0, slowspr_data_l2[43:47], 3'b0, slowspr_data_l2[51:55], 1'b0, slowspr_data_l2[57:63]};
	assign cpcr4_d[1] = {3'b0, slowspr_data_l2[35:39], 3'b0, slowspr_data_l2[43:47], 3'b0, slowspr_data_l2[51:55], 3'b0, slowspr_data_l2[59:63]};
	assign cpcr5_d[1] = {11'b0, slowspr_data_l2[43:47], 3'b0, slowspr_data_l2[51:55], 1'b0, slowspr_data_l2[57:63]};
 `endif

   assign iac1_d = slowspr_data_l2[62 - (`EFF_IFAR_ARCH):61];
   assign iac2_d = slowspr_data_l2[62 - (`EFF_IFAR_ARCH):61];
   assign iac3_d = slowspr_data_l2[62 - (`EFF_IFAR_ARCH):61];
   assign iac4_d = slowspr_data_l2[62 - (`EFF_IFAR_ARCH):61];

   assign iesr3_d = slowspr_data_l2[32:63];
   assign iesr1_d = EVENTMUX_128_MASK[32:55] & slowspr_data_l2[32:55];
   assign iesr2_d = EVENTMUX_128_MASK[32:55] & slowspr_data_l2[32:55];

   //-----------------------------------------------
   // register read
   //-----------------------------------------------
   assign ivpr_rden = ivpr_sel & slowspr_rw_l2 == 1'b1;
   assign givpr_rden = givpr_sel & slowspr_rw_l2 == 1'b1;
   assign immr0_rden = immr0_sel & slowspr_rw_l2 == 1'b1;
   assign imr0_rden = imr0_sel & slowspr_rw_l2 == 1'b1;
   assign iulfsr_rden = iulfsr_sel & slowspr_rw_l2 == 1'b1;
   assign iudbg0_rden = iudbg0_sel & slowspr_rw_l2 == 1'b1;
   assign iudbg1_rden = iudbg1_sel & slowspr_rw_l2 == 1'b1;
   assign iudbg2_rden = iudbg2_sel & slowspr_rw_l2 == 1'b1;
   assign iullcr_rden = iullcr_sel & slowspr_rw_l2 == 1'b1;
   assign iucr0_rden = iucr0_sel & slowspr_rw_l2 == 1'b1;
   assign eheir_rden = {`THREADS{slowspr_rw_l2 == 1'b1}} & eheir_sel;
   assign iucr1_rden = {`THREADS{slowspr_rw_l2 == 1'b1}} & iucr1_sel;
   assign iucr2_rden = {`THREADS{slowspr_rw_l2 == 1'b1}} & iucr2_sel;
   assign ppr32_rden = {`THREADS{slowspr_rw_l2 == 1'b1}} & ppr32_sel;
   assign iac1_rden = iac1_sel & slowspr_rw_l2 == 1'b1;
   assign iac2_rden = iac2_sel & slowspr_rw_l2 == 1'b1;
   assign iac3_rden = iac3_sel & slowspr_rw_l2 == 1'b1;
   assign iac4_rden = iac4_sel & slowspr_rw_l2 == 1'b1;
   assign cpcr0_rden = cpcr0_sel & slowspr_rw_l2 == 1'b1;
   assign cpcr1_rden = cpcr1_sel & slowspr_rw_l2 == 1'b1;
   assign cpcr2_rden = {`THREADS{slowspr_rw_l2 == 1'b1}} & cpcr2_sel;
   assign cpcr3_rden = {`THREADS{slowspr_rw_l2 == 1'b1}} & cpcr3_sel;
   assign cpcr4_rden = {`THREADS{slowspr_rw_l2 == 1'b1}} & cpcr4_sel;
   assign cpcr5_rden = {`THREADS{slowspr_rw_l2 == 1'b1}} & cpcr5_sel;
   assign iesr3_rden = iesr3_sel & slowspr_rw_l2 == 1'b1;
   assign iesr1_rden = iesr1_sel & slowspr_rw_l2 == 1'b1;
   assign iesr2_rden = iesr2_sel & slowspr_rw_l2 == 1'b1;

   generate
   	if (`GPR_WIDTH == 64)
   	begin : r64
   		assign iu_slowspr_data[0:31] = (ivpr_rden == 1'b1) ? ivpr_l2[0:31] :
   			                            (givpr_rden == 1'b1) ? givpr_l2[0:31] :
 			                            	 (iac1_rden == 1'b1) ? iac1[0:31] :
		                            	 	 (iac2_rden == 1'b1) ? iac2[0:31] :
		                            	 	 (iac3_rden == 1'b1) ? iac3[0:31] :
   			                            (iac4_rden == 1'b1) ? iac4[0:31] :
   			                            {32{1'b0}};
   	end
   endgenerate
   assign iu_slowspr_data[32:63] = (ivpr_rden == 1'b1) ? {ivpr_l2[32:51], 12'b000000000000} :
                                   (givpr_rden == 1'b1) ? {givpr_l2[32:51], 12'b000000000000} :
                                   (immr0_rden == 1'b1) ? immr0_l2 :
                                   (imr0_rden == 1'b1) ? imr0_l2 :
                                   (iulfsr_rden == 1'b1) ? iulfsr_l2 :
                                   (iudbg0_rden == 1'b1) ? iudbg0 :
                                   (iudbg1_rden == 1'b1) ? iudbg1 :
                                   (iudbg2_rden == 1'b1) ? iudbg2 :
                                   (iullcr_rden == 1'b1) ? iullcr :
                                   (iucr0_rden == 1'b1) ? iucr0 :
                                   (eheir_rden[0] == 1'b1) ? eheir[0] :
                                   (iucr1_rden[0] == 1'b1) ? iucr1[0] :
                                   (iucr2_rden[0] == 1'b1) ? iucr2[0] :
                                   (ppr32_rden[0] == 1'b1) ? ppr32[0] :
                                   (cpcr0_rden == 1'b1) ? cpcr0 :
                                   (cpcr1_rden == 1'b1) ? cpcr1 :
                                   (cpcr2_rden[0] == 1'b1) ? cpcr2[0] :
                                   (cpcr3_rden[0] == 1'b1) ? cpcr3[0] :
                                   (cpcr4_rden[0] == 1'b1) ? cpcr4[0] :
                                   (cpcr5_rden[0] == 1'b1) ? cpcr5[0] :
`ifndef THREADS1
                                   (eheir_rden[1] == 1'b1) ? eheir[1] :
                                   (iucr1_rden[1] == 1'b1) ? iucr1[1] :
                                   (iucr2_rden[1] == 1'b1) ? iucr2[1] :
                                   (ppr32_rden[1] == 1'b1) ? ppr32[1] :
                                   (cpcr2_rden[1] == 1'b1) ? cpcr2[1] :
                                   (cpcr3_rden[1] == 1'b1) ? cpcr3[1] :
                                   (cpcr4_rden[1] == 1'b1) ? cpcr4[1] :
                                   (cpcr5_rden[1] == 1'b1) ? cpcr5[1] :
`endif
                                   (iac1_rden == 1'b1) ? iac1[32:63] :
                                   (iac2_rden == 1'b1) ? iac2[32:63] :
                                   (iac3_rden == 1'b1) ? iac3[32:63] :
                                   (iac4_rden == 1'b1) ? iac4[32:63] :
                                   (iesr3_rden == 1'b1) ?  iesr3_l2[32:63] :
                                   (iesr1_rden == 1'b1) ? {iesr1_l2[32:55], 8'h00} :
                                   (iesr2_rden == 1'b1) ? {iesr2_l2[32:55], 8'h00} :
                                   {32{1'b0}};

   assign iudbg0[32:63] = {IUDBG0_MASK[32:48], iudbg0_l2[49:57], IUDBG0_MASK[58:61], iudbg0_exec_l2, iudbg0_done_l2};
   assign iudbg1[32:63] = {IUDBG1_MASK[32:52], iudbg1_l2[53:63]};
   assign iudbg2[32:63] = {IUDBG2_MASK[32:34], iudbg2_l2[35:63]};

   assign iullcr[32:63] = {IULLCR_MASK[32:45], iullcr_l2[46:63]};

   assign iucr0[32:63] = {IUCR0_MASK[32:47], iucr0_l2[48:63]};
   assign eheir[0] = {32{eheir_rden[0]}} & eheir_l2[0];
   assign iucr1[0] = {32{iucr1_rden[0]}} & {IUCR1_MASK[32:49], iucr1_l2[0]};
   assign iucr2[0] = {32{iucr2_rden[0]}} & {iucr2_l2[0], IUCR2_MASK[40:63]};
   assign ppr32[0] = {32{ppr32_rden[0]}} & {PPR32_MASK[32:42], ppr32_l2[0], PPR32_MASK[46:63]};
   assign cpcr0    = {32{cpcr0_rden}} & {3'b0, cpcr0_l2[35:39], 3'b0, cpcr0_l2[43:47], 3'b0, cpcr0_l2[51:55], 3'b0, cpcr0_l2[59:63]};
   assign cpcr1    = {32{cpcr1_rden}} & {11'b0, cpcr1_l2[43:47], 3'b0, cpcr1_l2[51:55], 8'b0};
   assign cpcr2[0] = {32{cpcr2_rden[0]}} & {3'b0, cpcr2_l2[0][35:39], 3'b0, cpcr2_l2[0][43:47], 3'b0, cpcr2_l2[0][51:55], 3'b0, cpcr2_l2[0][59:63]};
   assign cpcr3[0] = {32{cpcr3_rden[0]}} & {11'b0, cpcr3_l2[0][43:47], 3'b0, cpcr3_l2[0][51:55], 1'b0, cpcr3_l2[0][57:63]};
   assign cpcr4[0] = {32{cpcr4_rden[0]}} & {3'b0, cpcr4_l2[0][35:39], 3'b0, cpcr4_l2[0][43:47], 3'b0, cpcr4_l2[0][51:55], 3'b0, cpcr4_l2[0][59:63]};
   assign cpcr5[0] = {32{cpcr5_rden[0]}} & {11'b0, cpcr5_l2[0][43:47], 3'b0, cpcr5_l2[0][51:55], 1'b0, cpcr5_l2[0][57:63]};
`ifndef THREADS1
   assign eheir[1] = {32{eheir_rden[1]}} & eheir_l2[1];
   assign iucr1[1] = {32{iucr1_rden[1]}} & {IUCR1_MASK[32:49], iucr1_l2[1]};
   assign iucr2[1] = {32{iucr2_rden[1]}} & {iucr2_l2[1], IUCR2_MASK[40:63]};
   assign ppr32[1] = {32{ppr32_rden[1]}} & {PPR32_MASK[32:42], ppr32_l2[1], PPR32_MASK[46:63]};
   assign cpcr2[1] = {32{cpcr2_rden[1]}} & {3'b0, cpcr2_l2[1][35:39], 3'b0, cpcr2_l2[1][43:47], 3'b0, cpcr2_l2[1][51:55], 3'b0, cpcr2_l2[1][59:63]};
   assign cpcr3[1] = {32{cpcr3_rden[1]}} & {11'b0, cpcr3_l2[1][43:47], 3'b0, cpcr3_l2[1][51:55], 1'b0, cpcr3_l2[1][57:63]};
   assign cpcr4[1] = {32{cpcr4_rden[1]}} & {3'b0, cpcr4_l2[1][35:39], 3'b0, cpcr4_l2[1][43:47], 3'b0, cpcr4_l2[1][51:55], 3'b0, cpcr4_l2[1][59:63]};
   assign cpcr5[1] = {32{cpcr5_rden[1]}} & {11'b0, cpcr5_l2[1][43:47], 3'b0, cpcr5_l2[1][51:55], 1'b0, cpcr5_l2[1][57:63]};
`endif

   generate
   	begin : xhdl7
   		genvar                       i;
   		for (i = 0; i <= 61; i = i + 1)
   		begin : iac_width
   			if (`EFF_IFAR_ARCH > i)
   			begin : R0
   				assign iac1[61 - i] = iac1_l2[61 - i];
   				assign iac2[61 - i] = iac2_l2[61 - i];
   				assign iac3[61 - i] = iac3_l2[61 - i];
   				assign iac4[61 - i] = iac4_l2[61 - i];
   			end
   			if (`EFF_IFAR_ARCH <= i)
   			begin : R1
   				assign iac1[61 - i] = 1'b0;
   				assign iac2[61 - i] = 1'b0;
   				assign iac3[61 - i] = 1'b0;
   				assign iac4[61 - i] = 1'b0;
   			end
   		end
   	end
   endgenerate
   assign iac1[62:63] = 2'b00;
   assign iac2[62:63] = 2'b00;
   assign iac3[62:63] = 2'b00;
   assign iac4[62:63] = 2'b00;

   //-----------------------------------------------
   // pervasive
   //-----------------------------------------------
   tri_plat #(.WIDTH(2)) perv_2to1_reg(
	   .vd(vdd),
	   .gd(gnd),
	   .nclk(nclk),
	   .flush(tc_ac_ccflush_dc),
	   .din({pc_iu_func_sl_thold_2, pc_iu_sg_2}),
	   .q({pc_iu_func_sl_thold_1, pc_iu_sg_1})
   );

   tri_plat #(.WIDTH(2)) perv_1to0_reg(
   	.vd(vdd),
   	.gd(gnd),
   	.nclk(nclk),
   	.flush(tc_ac_ccflush_dc),
	   .din({pc_iu_func_sl_thold_1, pc_iu_sg_1}),
	   .q({pc_iu_func_sl_thold_0, pc_iu_sg_0})
   );

   tri_lcbor perv_lcbor(
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
   assign siv[0:scan_right] = {scan_in, sov[0:scan_right - 1]};
   assign scan_out = sov[scan_right];
endmodule
