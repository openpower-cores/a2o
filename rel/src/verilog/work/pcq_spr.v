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

//
//  Description: Pervasive Core SPRs and slowSPR Interface
//
//*****************************************************************************

module pcq_spr(
// Include model build parameters
`include "tri_a2o.vh"

   inout                     vdd,
   inout                     gnd,
   input  [0:`NCLK_WIDTH-1]  nclk,
   // pervasive signals
   input                     scan_dis_dc_b,
   input                     lcb_clkoff_dc_b,
   input                     lcb_mpw1_dc_b,
   input                     lcb_mpw2_dc_b,
   input                     lcb_delay_lclkr_dc,
   input                     lcb_act_dis_dc,
   input                     pc_pc_func_sl_thold_0,
   input                     pc_pc_sg_0,
   input                     func_scan_in,
   output                    func_scan_out,
   // slowSPR Interface
   input                     slowspr_val_in,
   input                     slowspr_rw_in,
   input  [0:1]              slowspr_etid_in,
   input  [0:9]              slowspr_addr_in,
   input  [64-`GPR_WIDTH:63] slowspr_data_in,
   input                     slowspr_done_in,
   input  [0:`THREADS-1]     cp_flush,
   output                    slowspr_val_out,
   output                    slowspr_rw_out,
   output [0:1]              slowspr_etid_out,
   output [0:9]              slowspr_addr_out,
   output [64-`GPR_WIDTH:63] slowspr_data_out,
   output                    slowspr_done_out,
   // Event Mux Controls
   output [0:39]             pc_rv_event_mux_ctrls,
   // CESR1 Controls
   output                    pc_iu_event_bus_enable,
   output                    pc_fu_event_bus_enable,
   output                    pc_rv_event_bus_enable,
   output                    pc_mm_event_bus_enable,
   output                    pc_xu_event_bus_enable,
   output                    pc_lq_event_bus_enable,
   output [0:2]              pc_iu_event_count_mode,
   output [0:2]              pc_fu_event_count_mode,
   output [0:2]              pc_rv_event_count_mode,
   output [0:2]              pc_mm_event_count_mode,
   output [0:2]              pc_xu_event_count_mode,
   output [0:2]              pc_lq_event_count_mode,
   output                    sp_rg_trace_bus_enable,
   output                    pc_iu_instr_trace_mode,
   output                    pc_iu_instr_trace_tid,
   output                    pc_lq_instr_trace_mode,
   output                    pc_lq_instr_trace_tid,
   output                    pc_xu_instr_trace_mode,
   output                    pc_xu_instr_trace_tid,
   output                    pc_lq_event_bus_seldbghi,
   output                    pc_lq_event_bus_seldbglo,
   input  [0:`THREADS-1]     xu_pc_perfmon_alert,
   output [0:`THREADS-1]     pc_xu_spr_cesr1_pmae,
   // SRAMD data and load pulse
   input                     rg_rg_load_sramd,
   input  [0:63]             rg_rg_sramd_din,
   // Trace/Trigger Signals
   output [0:7]              dbg_spr
);


//=====================================================================
// Signal Declarations
//=====================================================================
   // Scan Ring Constants:
   // Register sizes
   parameter                 CESR1_SIZE = 12;
   parameter                 CESR1_IS0_SIZE = 2;
   parameter                 CESR1_IS1_SIZE = 2;
   parameter                 RESR1_SIZE = 20;
   parameter                 RESR2_SIZE = 20;
   parameter                 SRAMD_SIZE = 64;
   parameter                 MISC_SIZE = 2;

   // start of func scan chain ordering
   parameter                 CP_FLUSH_OFFSET = 0;
   parameter                 SLOWSPR_VAL_OFFSET = CP_FLUSH_OFFSET + `THREADS;
   parameter                 SLOWSPR_RW_OFFSET = SLOWSPR_VAL_OFFSET + 1;
   parameter                 SLOWSPR_ETID_OFFSET = SLOWSPR_RW_OFFSET + 1;
   parameter                 SLOWSPR_ADDR_OFFSET = SLOWSPR_ETID_OFFSET + 2;
   parameter                 SLOWSPR_DATA_OFFSET = SLOWSPR_ADDR_OFFSET + 10;
   parameter                 SLOWSPR_DONE_OFFSET = SLOWSPR_DATA_OFFSET + `GPR_WIDTH;
   parameter                 CESR1_OFFSET = SLOWSPR_DONE_OFFSET + 1;
   parameter                 CESR1_IS0_OFFSET = CESR1_OFFSET + CESR1_SIZE;
   parameter                 CESR1_IS1_OFFSET = CESR1_IS0_OFFSET + CESR1_IS0_SIZE;
   parameter                 RESR1_OFFSET = CESR1_IS1_OFFSET + CESR1_IS1_SIZE;
   parameter                 RESR2_OFFSET = RESR1_OFFSET + RESR1_SIZE;
   parameter                 SRAMD_OFFSET = RESR2_OFFSET + RESR2_SIZE;
   parameter                 MISC_OFFSET = SRAMD_OFFSET + SRAMD_SIZE;
   parameter                 FUNC_RIGHT = MISC_OFFSET + MISC_SIZE - 1;
   // end of func scan chain ordering

   parameter [32:63]         CESR1_MASK        = 32'b11111011110011110000000000000000;
   parameter [32:63]         EVENTMUX_32_MASK  = 32'b11111111111111111111111111111111;
   parameter [32:63]         EVENTMUX_64_MASK  = 32'b11111111111111111111000000000000;
   parameter [32:63]         EVENTMUX_128_MASK = 32'b11111111111111111111111100000000;

   //--------------------------
   // signals
   //--------------------------
   wire [0:`THREADS-1]       cp_flush_l2;
   wire                      slowspr_val_d;
   wire                      slowspr_val_l2;
   wire                      slowspr_rw_d;
   wire                      slowspr_rw_l2;
   wire [0:1]                slowspr_etid_d;
   wire [0:1]                slowspr_etid_l2;
   wire [0:9]                slowspr_addr_d;
   wire [0:9]                slowspr_addr_l2;
   wire [64-`GPR_WIDTH:63]   slowspr_data_d;
   wire [64-`GPR_WIDTH:63]   slowspr_data_l2;
   wire                      slowspr_done_d;
   wire                      slowspr_done_l2;

   wire                      pc_done_int;
   wire [64-`GPR_WIDTH:63]   pc_data_int;
   wire [32:63]              pc_reg_data;

   wire                      cesr1_sel;
   wire                      cesr1_wren;
   wire                      cesr1_rden;
   wire [32:32+CESR1_SIZE-1] cesr1_d;
   wire [32:32+CESR1_SIZE-1] cesr1_l2;
   wire [32:63]              cesr1_out;
   // Instruction Sampling PMAE/PMAO latches
   wire [0:1]                cesr1_is_wren;
   wire [0:1]                cesr1_is0_d;
   wire [0:1]                cesr1_is0_l2;
   wire [0:1]                cesr1_is1_d;
   wire [0:1]                cesr1_is1_l2;
   wire [0:1]                perfmon_alert_din;
   wire [0:1]                perfmon_alert_q;
   wire [0:1]                update_is_ctrls;

   wire                      resr1_sel;
   wire                      resr1_wren;
   wire                      resr1_rden;
   wire [32:32+RESR1_SIZE-1] resr1_d;
   wire [32:32+RESR1_SIZE-1] resr1_l2;
   wire [32:63]              resr1_out;

   wire                      resr2_sel;
   wire                      resr2_wren;
   wire                      resr2_rden;
   wire [32:32+RESR2_SIZE-1] resr2_d;
   wire [32:32+RESR2_SIZE-1] resr2_l2;
   wire [32:63]              resr2_out;

   wire                      sramd_sel;
   wire                      sramd_wren;
   wire                      sramd_rden;
   wire [0:SRAMD_SIZE-1]     sramd_d;
   wire [0:SRAMD_SIZE-1]     sramd_l2;
   wire [0:63]               sramd_out;

   wire [0:3]                slowspr_tid;

   // misc, pervasive signals
   wire                      tiup;
   wire                      pc_pc_func_sl_thold_0_b;
   wire                      force_func;
   wire [0:FUNC_RIGHT]       func_siv;
   wire [0:FUNC_RIGHT]       func_sov;


// Get rid of sinkless net messages
// synopsys translate_off
(* analysis_not_referenced="true" *)
// synopsys translate_on
   wire                      unused_signals;
   assign unused_signals = (|slowspr_tid[2:3]);


//!! Bugspray Include: pcq_spr;


   assign tiup = 1'b1;

//=====================================================================
// Latches
//=====================================================================
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_pc_func_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[CP_FLUSH_OFFSET:CP_FLUSH_OFFSET + `THREADS - 1]),
      .scout(func_sov[CP_FLUSH_OFFSET:CP_FLUSH_OFFSET + `THREADS - 1]),
      .din(cp_flush),
      .dout(cp_flush_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) slowspr_val_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_pc_func_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[SLOWSPR_VAL_OFFSET]),
      .scout(func_sov[SLOWSPR_VAL_OFFSET]),
      .din(slowspr_val_d),
      .dout(slowspr_val_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) slowspr_rw_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(slowspr_val_d),
      .thold_b(pc_pc_func_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[SLOWSPR_RW_OFFSET]),
      .scout(func_sov[SLOWSPR_RW_OFFSET]),
      .din(slowspr_rw_d),
      .dout(slowspr_rw_l2)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) slowspr_etid_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(slowspr_val_d),
      .thold_b(pc_pc_func_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[SLOWSPR_ETID_OFFSET:SLOWSPR_ETID_OFFSET + 2 - 1]),
      .scout(func_sov[SLOWSPR_ETID_OFFSET:SLOWSPR_ETID_OFFSET + 2 - 1]),
      .din(slowspr_etid_d),
      .dout(slowspr_etid_l2)
   );

   tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) slowspr_addr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(slowspr_val_d),
      .thold_b(pc_pc_func_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[SLOWSPR_ADDR_OFFSET:SLOWSPR_ADDR_OFFSET + 10 - 1]),
      .scout(func_sov[SLOWSPR_ADDR_OFFSET:SLOWSPR_ADDR_OFFSET + 10 - 1]),
      .din(slowspr_addr_d),
      .dout(slowspr_addr_l2)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) slowspr_data_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(slowspr_val_d),
      .thold_b(pc_pc_func_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[SLOWSPR_DATA_OFFSET:SLOWSPR_DATA_OFFSET  + `GPR_WIDTH - 1]),
      .scout(func_sov[SLOWSPR_DATA_OFFSET:SLOWSPR_DATA_OFFSET + `GPR_WIDTH - 1]),
      .din(slowspr_data_d),
      .dout(slowspr_data_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) slowspr_done_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_pc_func_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[SLOWSPR_DONE_OFFSET]),
      .scout(func_sov[SLOWSPR_DONE_OFFSET]),
      .din(slowspr_done_d),
      .dout(slowspr_done_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(CESR1_SIZE), .INIT(0)) cesr1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cesr1_wren),
      .thold_b(pc_pc_func_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[CESR1_OFFSET:CESR1_OFFSET + CESR1_SIZE - 1]),
      .scout(func_sov[CESR1_OFFSET:CESR1_OFFSET + CESR1_SIZE - 1]),
      .din(cesr1_d),
      .dout(cesr1_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(CESR1_IS0_SIZE), .INIT(0)) cesr1_is0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cesr1_is_wren[0]),
      .thold_b(pc_pc_func_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[CESR1_IS0_OFFSET:CESR1_IS0_OFFSET + CESR1_IS0_SIZE - 1]),
      .scout(func_sov[CESR1_IS0_OFFSET:CESR1_IS0_OFFSET + CESR1_IS0_SIZE - 1]),
      .din(cesr1_is0_d),
      .dout(cesr1_is0_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(CESR1_IS1_SIZE), .INIT(0)) cesr1_is1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cesr1_is_wren[1]),
      .thold_b(pc_pc_func_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[CESR1_IS1_OFFSET:CESR1_IS1_OFFSET + CESR1_IS1_SIZE - 1]),
      .scout(func_sov[CESR1_IS1_OFFSET:CESR1_IS1_OFFSET + CESR1_IS1_SIZE - 1]),
      .din(cesr1_is1_d),
      .dout(cesr1_is1_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(RESR1_SIZE), .INIT(0)) resr1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(resr1_wren),
      .thold_b(pc_pc_func_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[RESR1_OFFSET:RESR1_OFFSET + RESR1_SIZE - 1]),
      .scout(func_sov[RESR1_OFFSET:RESR1_OFFSET + RESR1_SIZE - 1]),
      .din(resr1_d),
      .dout(resr1_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(RESR2_SIZE), .INIT(0)) resr2_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(resr2_wren),
      .thold_b(pc_pc_func_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[RESR2_OFFSET:RESR2_OFFSET + RESR2_SIZE - 1]),
      .scout(func_sov[RESR2_OFFSET:RESR2_OFFSET + RESR2_SIZE - 1]),
      .din(resr2_d),
      .dout(resr2_l2)
   );

   tri_ser_rlmreg_p #(.WIDTH(SRAMD_SIZE), .INIT(0)) sramd_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(sramd_wren),
      .thold_b(pc_pc_func_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[SRAMD_OFFSET:SRAMD_OFFSET + SRAMD_SIZE - 1]),
      .scout(func_sov[SRAMD_OFFSET:SRAMD_OFFSET + SRAMD_SIZE - 1]),
      .din(sramd_d),
      .dout(sramd_l2)
   );

   tri_rlmreg_p #(.WIDTH(MISC_SIZE), .INIT(0)) misc_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_pc_func_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[MISC_OFFSET:MISC_OFFSET + MISC_SIZE - 1]),
      .scout(func_sov[MISC_OFFSET:MISC_OFFSET + MISC_SIZE - 1]),
      .din(perfmon_alert_din),
      .dout(perfmon_alert_q)
   );

//=====================================================================
// inputs + staging
//=====================================================================
   assign slowspr_val_d  = slowspr_val_in & !(|(slowspr_tid[0:`THREADS-1] & cp_flush_l2));
   assign slowspr_rw_d   = slowspr_rw_in;
   assign slowspr_etid_d = slowspr_etid_in;
   assign slowspr_addr_d = slowspr_addr_in;
   assign slowspr_data_d = slowspr_data_in;
   assign slowspr_done_d = slowspr_done_in;

//=====================================================================
// Outputs
//=====================================================================
   assign slowspr_tid = (slowspr_etid_in == 2'b00) ? 4'b1000 :
                        (slowspr_etid_in == 2'b01) ? 4'b0100 :
                        (slowspr_etid_in == 2'b10) ? 4'b0010 :
                        (slowspr_etid_in == 2'b11) ? 4'b0001 :
                        4'b0000;
   assign slowspr_val_out  = slowspr_val_l2;
   assign slowspr_rw_out   = slowspr_rw_l2;
   assign slowspr_etid_out = slowspr_etid_l2;
   assign slowspr_addr_out = slowspr_addr_l2;
   assign slowspr_data_out = slowspr_data_l2 | pc_data_int;
   assign slowspr_done_out = slowspr_done_l2 | pc_done_int;

   assign pc_rv_event_mux_ctrls = {resr1_out[32:51], resr2_out[32:51]};

   // CESR1 controls miscellaneous performance related functions:
   // Event bus enable to all units.
   assign pc_iu_event_bus_enable = cesr1_out[32];
   assign pc_fu_event_bus_enable = cesr1_out[32];
   assign pc_rv_event_bus_enable = cesr1_out[32];
   assign pc_mm_event_bus_enable = cesr1_out[32];
   assign pc_xu_event_bus_enable = cesr1_out[32];
   assign pc_lq_event_bus_enable = cesr1_out[32];
   // Count modes function to all units.
   assign pc_iu_event_count_mode = cesr1_out[33:35];
   assign pc_fu_event_count_mode = cesr1_out[33:35];
   assign pc_rv_event_count_mode = cesr1_out[33:35];
   assign pc_mm_event_count_mode = cesr1_out[33:35];
   assign pc_xu_event_count_mode = cesr1_out[33:35];
   assign pc_lq_event_count_mode = cesr1_out[33:35];
   // Trace bus enable to all units (from pcq_regs).
   assign sp_rg_trace_bus_enable = cesr1_out[36];
   // Select trace bits for event counting.
   assign pc_lq_event_bus_seldbghi = cesr1_out[38];
   assign pc_lq_event_bus_seldbglo = cesr1_out[39];
   // Instruction tracing.
   assign pc_iu_instr_trace_mode = cesr1_out[40];
   assign pc_iu_instr_trace_tid = cesr1_out[41];
   assign pc_lq_instr_trace_mode = cesr1_out[40];
   assign pc_lq_instr_trace_tid = cesr1_out[41];
   assign pc_xu_instr_trace_mode = cesr1_out[40];
   assign pc_xu_instr_trace_tid = cesr1_out[41];

//=====================================================================
// Instruction sampling
//=====================================================================
   generate
      if (`THREADS == 1)
      begin : T1_INSTRSAMP
         assign pc_xu_spr_cesr1_pmae = cesr1_is0_l2[0];
         assign perfmon_alert_din = {xu_pc_perfmon_alert[0], 1'b0};
      end
   endgenerate

   generate
      if (`THREADS == 2)
      begin : T2_INSTRSAMP
         assign pc_xu_spr_cesr1_pmae = {cesr1_is0_l2[0], cesr1_is1_l2[0]};
         assign perfmon_alert_din = xu_pc_perfmon_alert[0:1];
      end
   endgenerate

//=====================================================================
// register select
//=====================================================================
   assign cesr1_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1110010000;		// 912
   assign resr1_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1110011010;		// 922
   assign resr2_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1110011011;		// 923
   assign sramd_sel = slowspr_val_l2 & slowspr_addr_l2 == 10'b1101111110;		// 894

   assign pc_done_int = cesr1_sel | resr1_sel | resr2_sel | sramd_sel;

//=====================================================================
// register write
//=====================================================================
   assign cesr1_wren = cesr1_sel & slowspr_rw_l2 == 1'b0;
   assign resr1_wren = resr1_sel & slowspr_rw_l2 == 1'b0;
   assign resr2_wren = resr2_sel & slowspr_rw_l2 == 1'b0;
   assign sramd_wren = rg_rg_load_sramd;

   assign cesr1_d = CESR1_MASK[32:32 + CESR1_SIZE - 1] & slowspr_data_l2[32:32 + CESR1_SIZE - 1];
   assign resr1_d = EVENTMUX_64_MASK[32:32 + RESR1_SIZE - 1] & slowspr_data_l2[32:32 + RESR1_SIZE - 1];
   assign resr2_d = EVENTMUX_64_MASK[32:32 + RESR2_SIZE - 1] & slowspr_data_l2[32:32 + RESR2_SIZE - 1];
   assign sramd_d = rg_rg_sramd_din;

   // Instruction Sampling
   assign update_is_ctrls = {(perfmon_alert_q[0] & cesr1_is0_l2[0]), (perfmon_alert_q[1] & cesr1_is1_l2[0])};
   assign cesr1_is_wren   = {(cesr1_wren | update_is_ctrls[0]), (cesr1_wren | update_is_ctrls[1])};

   assign cesr1_is0_d[0] =  CESR1_MASK[44] & slowspr_data_l2[44] & (~update_is_ctrls[0]);			// PMAE_T0 cleared on perfmon alert.
   assign cesr1_is0_d[1] = (CESR1_MASK[45] & slowspr_data_l2[45] & (~update_is_ctrls[0])) | update_is_ctrls[0];	// PMAO_T0 set on perfmon alert.
   assign cesr1_is1_d[0] =  CESR1_MASK[46] & slowspr_data_l2[46] & (~update_is_ctrls[1]);			// PMAE_T1 cleared on perfmon alert.
   assign cesr1_is1_d[1] = (CESR1_MASK[47] & slowspr_data_l2[47] & (~update_is_ctrls[1])) | update_is_ctrls[1];	// PMAO_T1 set on perfmon alert.

//=====================================================================
// register read
//=====================================================================
   assign cesr1_rden = cesr1_sel & slowspr_rw_l2 == 1'b1;
   assign resr1_rden = resr1_sel & slowspr_rw_l2 == 1'b1;
   assign resr2_rden = resr2_sel & slowspr_rw_l2 == 1'b1;
   assign sramd_rden = sramd_sel & slowspr_rw_l2 == 1'b1;

   assign cesr1_out[32:63] = {cesr1_l2, cesr1_is0_l2, cesr1_is1_l2, {64-(32+CESR1_SIZE+CESR1_IS0_SIZE+CESR1_IS1_SIZE){1'b0}} };
   assign resr1_out[32:63] = {resr1_l2, {64-(32+RESR1_SIZE){1'b0}} };
   assign resr2_out[32:63] = {resr2_l2, {64-(32+RESR2_SIZE){1'b0}} };
   assign sramd_out[0:63]  = sramd_l2;

   assign pc_reg_data[32:63] = (cesr1_rden == 1'b1) ? cesr1_out :
                               (resr1_rden == 1'b1) ? resr1_out :
                               (resr2_rden == 1'b1) ? resr2_out :
                               (sramd_rden == 1'b1) ? sramd_out[32:63] :
                               {32{1'b0}};

   generate
      if (`GPR_WIDTH > 32)
      begin : r64
         assign pc_data_int[0:31] = (sramd_rden == 1'b1) ? sramd_out[0:31] :
                                    {32{1'b0}};
      end
   endgenerate
   assign pc_data_int[32:63] = pc_reg_data[32:63];


//=====================================================================
// Trace/Trigger Signals
//=====================================================================
   assign dbg_spr = { cesr1_wren,		// 0
   		      sramd_wren,		// 1
		      perfmon_alert_q[0:1],	// 2:3
		      cesr1_is0_l2[0:1],	// 4:5
		      cesr1_is1_l2[0:1]		// 6:7
                    };

//=====================================================================
// Thold/SG Staging
//=====================================================================
   // func_slp lcbor
   tri_lcbor lcbor_funcslp(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(pc_pc_func_sl_thold_0),
      .sg(pc_pc_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(force_func),
      .thold_b(pc_pc_func_sl_thold_0_b)
   );

//=====================================================================
// Scan Connections
//=====================================================================
   // Func ring
   assign func_siv[0:FUNC_RIGHT] = {func_scan_in, func_sov[0:FUNC_RIGHT - 1]};
   assign func_scan_out = func_sov[FUNC_RIGHT] & scan_dis_dc_b;


endmodule
