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

//  Description:  XU Pervasive
//
//*****************************************************************************

`include "tri_a2o.vh"

module lq_perv(
   vdd,
   gnd,
   nclk,
   pc_lq_trace_bus_enable,
   pc_lq_debug_mux1_ctrls,
   pc_lq_debug_mux2_ctrls,
   pc_lq_instr_trace_mode,
   pc_lq_instr_trace_tid,
   debug_bus_in,
   coretrace_ctrls_in,
   lq_debug_bus0,
   debug_bus_out,
   coretrace_ctrls_out,
   pc_lq_event_bus_enable,
   pc_lq_event_count_mode,
   ctl_perv_spr_lesr1,
   ctl_perv_spr_lesr2,
   ctl_perv_ex6_perf_events,
   ctl_perv_stq4_perf_events,
   ctl_perv_dir_perf_events,
   lsq_perv_ex7_events,
   lsq_perv_ldq_events,
   lsq_perv_stq_events,
   lsq_perv_odq_events,
   xu_lq_spr_msr_pr,
   xu_lq_spr_msr_gs,
   event_bus_in,
   event_bus_out,
   pc_lq_sg_3,
   pc_lq_func_sl_thold_3,
   pc_lq_func_slp_sl_thold_3,
   pc_lq_func_nsl_thold_3,
   pc_lq_func_slp_nsl_thold_3,
   pc_lq_gptr_sl_thold_3,
   pc_lq_abst_sl_thold_3,
   pc_lq_abst_slp_sl_thold_3,
   pc_lq_time_sl_thold_3,
   pc_lq_repr_sl_thold_3,
   pc_lq_bolt_sl_thold_3,
   pc_lq_cfg_slp_sl_thold_3,
   pc_lq_regf_slp_sl_thold_3,
   pc_lq_cfg_sl_thold_3,
   pc_lq_ary_nsl_thold_3,
   pc_lq_ary_slp_nsl_thold_3,
   pc_lq_fce_3,
   pc_lq_ccflush_dc,
   pc_lq_bo_enable_3,
   an_ac_scan_diag_dc,
   bo_enable_2,
   sg_2,
   fce_2,
   func_sl_thold_2,
   func_slp_sl_thold_2,
   func_nsl_thold_2,
   func_slp_nsl_thold_2,
   abst_sl_thold_2,
   abst_slp_sl_thold_2,
   time_sl_thold_2,
   repr_sl_thold_2,
   bolt_sl_thold_2,
   cfg_slp_sl_thold_2,
   regf_slp_sl_thold_2,
   ary_nsl_thold_2,
   ary_slp_nsl_thold_2,
   cfg_sl_thold_2,
   clkoff_dc_b,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   g6t_clkoff_dc_b,
   g6t_d_mode_dc,
   g6t_delay_lclkr_dc,
   g6t_mpw1_dc_b,
   g6t_mpw2_dc_b,
   g8t_clkoff_dc_b,
   g8t_d_mode_dc,
   g8t_delay_lclkr_dc,
   g8t_mpw1_dc_b,
   g8t_mpw2_dc_b,
   cam_clkoff_dc_b,
   cam_d_mode_dc,
   cam_delay_lclkr_dc,
   cam_act_dis_dc,
   cam_mpw1_dc_b,
   cam_mpw2_dc_b,
   gptr_scan_in,
   gptr_scan_out,
   func_scan_in,
   func_scan_out
);

inout                       vdd;
inout                       gnd;
(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)
input [0:`NCLK_WIDTH-1]     nclk;

// Pervasive Debug Control
input                       pc_lq_trace_bus_enable;
input [0:10]                pc_lq_debug_mux1_ctrls;
input [0:10]                pc_lq_debug_mux2_ctrls;
input                       pc_lq_instr_trace_mode;
input [0:`THREADS-1]        pc_lq_instr_trace_tid;

// Pass Thru Debug Trace Bus
input [0:31]                debug_bus_in;
input [0:3]                 coretrace_ctrls_in;

// Debug Data
input [0:31]                lq_debug_bus0;

// Outputs
output [0:31]               debug_bus_out;
output [0:3]                coretrace_ctrls_out;

// Pervasive Performance Event Control
input                       pc_lq_event_bus_enable;
input [0:2]                 pc_lq_event_count_mode;
input [0:23]                ctl_perv_spr_lesr1;
input [0:23]                ctl_perv_spr_lesr2;
input [0:18+`THREADS-1]     ctl_perv_ex6_perf_events;
input [0:6+`THREADS-1]      ctl_perv_stq4_perf_events;
input [0:(`THREADS*3)+1]    ctl_perv_dir_perf_events;
input [0:`THREADS-1]        lsq_perv_ex7_events;
input [0:(2*`THREADS)+3]    lsq_perv_ldq_events;
input [0:(3*`THREADS)+2]    lsq_perv_stq_events;
input [0:4+`THREADS-1]      lsq_perv_odq_events;

input [0:`THREADS-1]        xu_lq_spr_msr_pr;
input [0:`THREADS-1]        xu_lq_spr_msr_gs;

// Performance Event Outputs
input [0:(4*`THREADS)-1]    event_bus_in;
output [0:(4*`THREADS)-1]   event_bus_out;

// Pervasive Clock Controls
input                       pc_lq_sg_3;
input                       pc_lq_func_sl_thold_3;
input                       pc_lq_func_slp_sl_thold_3;
input                       pc_lq_func_nsl_thold_3;
input                       pc_lq_func_slp_nsl_thold_3;
input                       pc_lq_gptr_sl_thold_3;
input                       pc_lq_abst_sl_thold_3;
input                       pc_lq_abst_slp_sl_thold_3;
input                       pc_lq_time_sl_thold_3;
input                       pc_lq_repr_sl_thold_3;
input                       pc_lq_bolt_sl_thold_3;
input                       pc_lq_cfg_slp_sl_thold_3;
input                       pc_lq_regf_slp_sl_thold_3;
input                       pc_lq_cfg_sl_thold_3;
input                       pc_lq_ary_nsl_thold_3;
input                       pc_lq_ary_slp_nsl_thold_3;
input                       pc_lq_fce_3;
input                       pc_lq_ccflush_dc;
input                       pc_lq_bo_enable_3;
input                       an_ac_scan_diag_dc;
output                      bo_enable_2;
output                      sg_2;
output                      fce_2;
output                      func_sl_thold_2;
output                      func_slp_sl_thold_2;
output                      func_nsl_thold_2;
output                      func_slp_nsl_thold_2;
output                      abst_sl_thold_2;
output                      abst_slp_sl_thold_2;
output                      time_sl_thold_2;
output                      repr_sl_thold_2;
output                      bolt_sl_thold_2;
output                      cfg_slp_sl_thold_2;
output                      regf_slp_sl_thold_2;
output                      ary_nsl_thold_2;
output                      ary_slp_nsl_thold_2;
output                      cfg_sl_thold_2;
output                      clkoff_dc_b;
output                      d_mode_dc;
output [0:9]                delay_lclkr_dc;
output [0:9]                mpw1_dc_b;
output                      mpw2_dc_b;
output                      g6t_clkoff_dc_b;
output                      g6t_d_mode_dc;
output [0:4]                g6t_delay_lclkr_dc;
output [0:4]                g6t_mpw1_dc_b;
output                      g6t_mpw2_dc_b;
output                      g8t_clkoff_dc_b;
output                      g8t_d_mode_dc;
output [0:4]                g8t_delay_lclkr_dc;
output [0:4]                g8t_mpw1_dc_b;
output                      g8t_mpw2_dc_b;
output                      cam_clkoff_dc_b;
output                      cam_d_mode_dc;
output [0:4]                cam_delay_lclkr_dc;
output                      cam_act_dis_dc;
output [0:4]                cam_mpw1_dc_b;
output                      cam_mpw2_dc_b;
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input                       gptr_scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output                      gptr_scan_out;
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input                       func_scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output                      func_scan_out;

//--------------------------
// signals
//--------------------------
wire [0:4]                  gptr_siv;
wire [0:4]                  gptr_sov;
wire                        perv_sg_2;
wire                        gptr_sl_thold_2;
wire                        gptr_sl_thold_1;
wire                        sg_1;
wire                        gptr_sl_thold_0;
wire                        sg_0;
wire                        g6t_clkoff_dc_b_int;
wire                        g6t_d_mode_dc_int;
wire [0:4]                  g6t_delay_lclkr_dc_int;
wire                        g6t_act_dis_dc_int;
wire [0:4]                  g6t_mpw1_dc_b_int;
wire                        g6t_mpw2_dc_b_int;
wire                        g8t_clkoff_dc_b_int;
wire                        g8t_d_mode_dc_int;
wire [0:4]                  g8t_delay_lclkr_dc_int;
wire                        g8t_act_dis_dc_int;
wire [0:4]                  g8t_mpw1_dc_b_int;
wire                        g8t_mpw2_dc_b_int;
wire                        cam_clkoff_dc_b_int;
wire                        cam_d_mode_dc_int;
wire [0:4]                  cam_delay_lclkr_dc_int;
wire                        cam_act_dis_ac_int;
wire [0:4]                  cam_mpw1_dc_b_int;
wire                        cam_mpw2_dc_b_int;
wire                        func_slp_sl_thold_2_int;
wire                        func_slp_sl_thold_1;
wire                        func_slp_sl_thold_0;
wire                        func_slp_sl_thold_0_b;
wire                        func_slp_sl_force;
wire [0:1]                  clkoff_dc_b_int;
wire [0:1]                  d_mode_dc_int;
wire [0:1]                  act_dis_dc_int;
wire [0:9]                  delay_lclkr_dc_int;
wire [0:9]                  mpw1_dc_b_int;
wire [0:1]                  mpw2_dc_b_int;
wire                        pc_lq_trace_bus_enable_q;
wire [0:10]                 pc_lq_debug_mux1_ctrls_q;
wire [0:10]                 pc_lq_debug_mux2_ctrls_q;
wire                        pc_lq_instr_trace_mode_q;
wire [0:`THREADS-1]         pc_lq_instr_trace_tid_q;
wire                        pc_lq_event_bus_enable_q;
wire [0:2]                  pc_lq_event_count_mode_q;
wire [0:31]                 lq_dbg_data_mux1[0:31];
wire [0:31]                 lq_dbg_data_mux2[0:31];
wire [0:31]                 lq_mux1_debug_data_in;
wire [0:3]                  lq_mux1_coretrace_in;
wire [0:31]                 lq_mux1_debug_data_out_d;
wire [0:31]                 lq_mux1_debug_data_out_q;
wire [0:3]                  lq_mux1_coretrace_out_d;
wire [0:3]                  lq_mux1_coretrace_out_q;
wire [0:31]                 lq_mux2_debug_data_in;
wire [0:3]                  lq_mux2_coretrace_in;
wire [0:31]                 lq_mux2_debug_data_out_d;
wire [0:31]                 lq_mux2_debug_data_out_q;
wire [0:3]                  lq_mux2_coretrace_out_d;
wire [0:3]                  lq_mux2_coretrace_out_q;
wire [0:`THREADS-1]         spr_msr_gs_d;
wire [0:`THREADS-1]         spr_msr_gs_q;
wire [0:`THREADS-1]         spr_msr_pr_d;
wire [0:`THREADS-1]         spr_msr_pr_q;
wire [0:47]                 perf_event_mux_ctrl;
wire [0:`THREADS-1]         perf_event_en_d;
wire [0:`THREADS-1]         perf_event_en_q;
wire [0:(4*`THREADS)-1]     perf_event_data_d;
wire [0:(4*`THREADS)-1]     perf_event_data_q;
wire [0:17]                 ex6_perf_events[0:`THREADS-1];
wire [0:5]                  stq4_perf_events[0:`THREADS-1];
wire [0:3]                  odq_perf_events[0:`THREADS-1];
wire [0:4]                  dir_perf_events[0:`THREADS-1];
wire [0:5]                  stq_perf_events[0:`THREADS-1];
wire [0:5]                  ldq_perf_events[0:`THREADS-1];
wire [1:63]                 lq_perf_events[0:`THREADS-1];
wire [1:63]                 lq_events_en[0:`THREADS-1];

//--------------------------
// register constants
//--------------------------
parameter                   pc_lq_trace_bus_enable_offset = 0;
parameter                   pc_lq_debug_mux1_ctrls_offset = pc_lq_trace_bus_enable_offset + 1;
parameter                   pc_lq_debug_mux2_ctrls_offset = pc_lq_debug_mux1_ctrls_offset + 11;
parameter                   pc_lq_instr_trace_mode_offset = pc_lq_debug_mux2_ctrls_offset + 11;
parameter                   pc_lq_instr_trace_tid_offset = pc_lq_instr_trace_mode_offset + 1;
parameter                   lq_mux1_debug_data_out_offset = pc_lq_instr_trace_tid_offset + `THREADS;
parameter                   lq_mux1_coretrace_out_offset = lq_mux1_debug_data_out_offset + 32;
parameter                   lq_mux2_debug_data_out_offset = lq_mux1_coretrace_out_offset + 4;
parameter                   lq_mux2_coretrace_out_offset = lq_mux2_debug_data_out_offset + 32;
parameter                   spr_msr_gs_offset = lq_mux2_coretrace_out_offset + 4;
parameter                   spr_msr_pr_offset = spr_msr_gs_offset + `THREADS;
parameter                   pc_lq_event_bus_enable_offset = spr_msr_pr_offset + `THREADS;
parameter                   perf_event_en_offset = pc_lq_event_bus_enable_offset + 1;
parameter                   perf_event_data_offset = perf_event_en_offset + `THREADS;
parameter                   pc_lq_event_count_mode_offset = perf_event_data_offset + (4*`THREADS);
parameter                   scan_right = pc_lq_event_count_mode_offset + 3 - 1;

wire                        tiup;
wire                        tidn;
wire [0:scan_right]         siv;
wire [0:scan_right]         sov;
(* analysis_not_referenced="true" *)
wire                        unused;

assign tiup = 1;
assign tidn = 0;
assign unused = (|perf_event_mux_ctrl) | clkoff_dc_b_int[1] | d_mode_dc_int[1] | act_dis_dc_int[1] | mpw2_dc_b_int[1] |
                g6t_act_dis_dc_int | g8t_act_dis_dc_int | cam_act_dis_ac_int;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Debug Bus Control Logic
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

generate
  begin : dbgData
    genvar bus;
    for (bus=0; bus<32; bus=bus+1) begin : dbgData
      assign lq_dbg_data_mux1[bus] = lq_debug_bus0;
      assign lq_dbg_data_mux2[bus] = lq_debug_bus0;
    end
  end
endgenerate

assign lq_mux1_debug_data_in    = debug_bus_in;
assign lq_mux1_coretrace_in     = coretrace_ctrls_in;

tri_debug_mux32 dbgMux1(
   .select_bits(pc_lq_debug_mux1_ctrls_q),
   .trace_data_in(lq_mux1_debug_data_in),
   .coretrace_ctrls_in(lq_mux1_coretrace_in),
   .dbg_group0(lq_dbg_data_mux1[0]),
   .dbg_group1(lq_dbg_data_mux1[1]),
   .dbg_group2(lq_dbg_data_mux1[2]),
   .dbg_group3(lq_dbg_data_mux1[3]),
   .dbg_group4(lq_dbg_data_mux1[4]),
   .dbg_group5(lq_dbg_data_mux1[5]),
   .dbg_group6(lq_dbg_data_mux1[6]),
   .dbg_group7(lq_dbg_data_mux1[7]),
   .dbg_group8(lq_dbg_data_mux1[8]),
   .dbg_group9(lq_dbg_data_mux1[9]),
   .dbg_group10(lq_dbg_data_mux1[10]),
   .dbg_group11(lq_dbg_data_mux1[11]),
   .dbg_group12(lq_dbg_data_mux1[12]),
   .dbg_group13(lq_dbg_data_mux1[13]),
   .dbg_group14(lq_dbg_data_mux1[14]),
   .dbg_group15(lq_dbg_data_mux1[15]),
   .dbg_group16(lq_dbg_data_mux1[16]),
   .dbg_group17(lq_dbg_data_mux1[17]),
   .dbg_group18(lq_dbg_data_mux1[18]),
   .dbg_group19(lq_dbg_data_mux1[19]),
   .dbg_group20(lq_dbg_data_mux1[20]),
   .dbg_group21(lq_dbg_data_mux1[21]),
   .dbg_group22(lq_dbg_data_mux1[22]),
   .dbg_group23(lq_dbg_data_mux1[23]),
   .dbg_group24(lq_dbg_data_mux1[24]),
   .dbg_group25(lq_dbg_data_mux1[25]),
   .dbg_group26(lq_dbg_data_mux1[26]),
   .dbg_group27(lq_dbg_data_mux1[27]),
   .dbg_group28(lq_dbg_data_mux1[28]),
   .dbg_group29(lq_dbg_data_mux1[29]),
   .dbg_group30(lq_dbg_data_mux1[30]),
   .dbg_group31(lq_dbg_data_mux1[31]),
   .trace_data_out(lq_mux1_debug_data_out_d),
   .coretrace_ctrls_out(lq_mux1_coretrace_out_d)
);

assign lq_mux2_debug_data_in    = lq_mux1_debug_data_out_q;
assign lq_mux2_coretrace_in     = lq_mux1_coretrace_out_q;

tri_debug_mux32 dbgmux2(
   .select_bits(pc_lq_debug_mux2_ctrls_q),
   .trace_data_in(lq_mux2_debug_data_in),
   .coretrace_ctrls_in(lq_mux2_coretrace_in),
   .dbg_group0(lq_dbg_data_mux2[0]),
   .dbg_group1(lq_dbg_data_mux2[1]),
   .dbg_group2(lq_dbg_data_mux2[2]),
   .dbg_group3(lq_dbg_data_mux2[3]),
   .dbg_group4(lq_dbg_data_mux2[4]),
   .dbg_group5(lq_dbg_data_mux2[5]),
   .dbg_group6(lq_dbg_data_mux2[6]),
   .dbg_group7(lq_dbg_data_mux2[7]),
   .dbg_group8(lq_dbg_data_mux2[8]),
   .dbg_group9(lq_dbg_data_mux2[9]),
   .dbg_group10(lq_dbg_data_mux2[10]),
   .dbg_group11(lq_dbg_data_mux2[11]),
   .dbg_group12(lq_dbg_data_mux2[12]),
   .dbg_group13(lq_dbg_data_mux2[13]),
   .dbg_group14(lq_dbg_data_mux2[14]),
   .dbg_group15(lq_dbg_data_mux2[15]),
   .dbg_group16(lq_dbg_data_mux2[16]),
   .dbg_group17(lq_dbg_data_mux2[17]),
   .dbg_group18(lq_dbg_data_mux2[18]),
   .dbg_group19(lq_dbg_data_mux2[19]),
   .dbg_group20(lq_dbg_data_mux2[20]),
   .dbg_group21(lq_dbg_data_mux2[21]),
   .dbg_group22(lq_dbg_data_mux2[22]),
   .dbg_group23(lq_dbg_data_mux2[23]),
   .dbg_group24(lq_dbg_data_mux2[24]),
   .dbg_group25(lq_dbg_data_mux2[25]),
   .dbg_group26(lq_dbg_data_mux2[26]),
   .dbg_group27(lq_dbg_data_mux2[27]),
   .dbg_group28(lq_dbg_data_mux2[28]),
   .dbg_group29(lq_dbg_data_mux2[29]),
   .dbg_group30(lq_dbg_data_mux2[30]),
   .dbg_group31(lq_dbg_data_mux2[31]),
   .trace_data_out(lq_mux2_debug_data_out_d),
   .coretrace_ctrls_out(lq_mux2_coretrace_out_d)
);

assign debug_bus_out       = lq_mux2_debug_data_out_q;
assign coretrace_ctrls_out = lq_mux2_coretrace_out_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Performance Events Control Logic
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// MSR[GS] Guest State
// 1 => Processor is in Guest State
// 0 => Processor is in Hypervisor State
assign spr_msr_gs_d = xu_lq_spr_msr_gs;

// MSR[PR] Problem State
// 1 => Processor is in User Mode
// 0 => Processor is in Supervisor Mode
assign spr_msr_pr_d = xu_lq_spr_msr_pr;

// Processor State Control
assign perf_event_en_d = ( spr_msr_pr_q &                 {`THREADS{pc_lq_event_count_mode_q[0]}}) |    // User
                         (~spr_msr_pr_q &  spr_msr_gs_q & {`THREADS{pc_lq_event_count_mode_q[1]}}) |    // Guest Supervisor
                         (~spr_msr_pr_q & ~spr_msr_gs_q & {`THREADS{pc_lq_event_count_mode_q[2]}});     // Hypervisor

// Muxing
assign perf_event_mux_ctrl = {ctl_perv_spr_lesr1, ctl_perv_spr_lesr2};

generate begin : TidPerf
  genvar tid;
  for (tid=0;tid<`THREADS;tid=tid+1) begin : TidPerf
      // Generate Events Per Thread
      assign ex6_perf_events[tid]  = ctl_perv_ex6_perf_events[0:17] & {18{ctl_perv_ex6_perf_events[18+tid]}};
      assign stq4_perf_events[tid] = ctl_perv_stq4_perf_events[0:5] & {6{ctl_perv_stq4_perf_events[6+tid]}};
      assign odq_perf_events[tid]  = lsq_perv_odq_events[0:3]       & {4{lsq_perv_odq_events[4+tid]}};
      assign dir_perf_events[tid]  = {ctl_perv_dir_perf_events[0:1],                ctl_perv_dir_perf_events[2+(0*`THREADS)+tid],
                                      ctl_perv_dir_perf_events[2+(1*`THREADS)+tid], ctl_perv_dir_perf_events[2+(2*`THREADS)+tid]};
      assign stq_perf_events[tid]  = {lsq_perv_stq_events[0:2],                lsq_perv_stq_events[3+(0*`THREADS)+tid],
                                      lsq_perv_stq_events[3+(1*`THREADS)+tid], lsq_perv_stq_events[3+(2*`THREADS)+tid]};
      assign ldq_perf_events[tid]  = {lsq_perv_ldq_events[0:3],                lsq_perv_ldq_events[4+(0*`THREADS)+tid],
                                      lsq_perv_ldq_events[4+(1*`THREADS)+tid]};

      // Tie Up all performance events
      // (0)  =>                              => empty events, tied to 0           <-- Needs to always be 0
      // (1)  =>                              => empty events, tied to 0
      // (2)  =>                              => empty events, tied to 0
      // (3)  =>                              => empty events, tied to 0
      // (4)  =>                              => empty events, tied to 0
      // (5)  =>                              => empty events, tied to 0
      // (6)  => perf_ex6_derat_attmpts       => ctl_perv_ex6_perf_events(0)
      // (7)  => perf_ex6_derat_restarts      => ctl_perv_ex6_perf_events(1)
      assign lq_perf_events[tid][1:7]   = {{5{1'b0}}, ex6_perf_events[tid][0:1]};

      // (8)  => perf_ex6_pfetch_iss          => ctl_perv_ex6_perf_events(2)
      // (9)  => perf_ex6_pfetch_hit          => ctl_perv_ex6_perf_events(3)
      // (10) => perf_ex6_pfetch_emiss        => ctl_perv_ex6_perf_events(4)
      // (11) => perf_ex6_pfetch_ldq_full     => ctl_perv_ex6_perf_events(5)
      // (12) => perf_ex6_pfetch_ldq_hit      => ctl_perv_ex6_perf_events(6)
      // (13) => perf_ex6_pfetch_stq_restart  => ctl_perv_ex6_perf_events(7)
      // (14) => perf_ex6_pfetch_odq_restart  => lsq_perv_ex7_events(0)
      // (15) => perf_ex6_dir_restart         => ctl_perv_ex6_perf_events(8)
      assign lq_perf_events[tid][8:15]  = {ex6_perf_events[tid][2:7], lsq_perv_ex7_events[tid], ex6_perf_events[tid][8]};

      // (16) => perf_ex6_dec_restart         => ctl_perv_ex6_perf_events(9)
      // (17) => perf_ex6_wNComp_restart      => ctl_perv_ex6_perf_events(10)
      // (18) => perf_ex6_ldq_full            => ctl_perv_ex6_perf_events(11)
      // (19) => perf_ex6_ldq_hit             => ctl_perv_ex6_perf_events(12)
      // (20) => perf_ex6_lgq_full            => ctl_perv_ex6_perf_events(13)
      // (21) => perf_ex6_lgq_hit             => ctl_perv_ex6_perf_events(14)
      // (22) => perf_ex6_stq_sametid         => ctl_perv_ex6_perf_events(15)
      // (23) => perf_ex6_stq_difftid         => ctl_perv_ex6_perf_events(16)
      assign lq_perf_events[tid][16:23] = ex6_perf_events[tid][9:16];

      // (24) => perf_dir_binv_val            => ctl_perv_dir_perf_events(0)
      // (25) => perf_dir_binv_hit            => ctl_perv_dir_perf_events(1)
      // (26) => perf_dir_binv_watchlost      => ctl_perv_dir_perf_events(2+(0*`THREADS))
      // (27) => perf_dir_evict_watchlost     => ctl_perv_dir_perf_events(2+(1*`THREADS))
      // (28) => perf_dir_interTid_watchlost  => ctl_perv_dir_perf_events(2+(2*`THREADS))
      // (29) => perf_stq_stores              => ctl_perv_stq4_perf_events(0)
      // (30) => perf_stq_store_miss          => ctl_perv_stq4_perf_events(1)
      // (31) => perf_stq_stcx_exec           => ctl_perv_stq4_perf_events(2)
      assign lq_perf_events[tid][24:31] = {dir_perf_events[tid], stq4_perf_events[tid][0:2]};

      // (32) => perf_stq_stcx_fail           => lsq_perv_stq_events(3+(0*`THREADS))
      // (33) => perf_stq_axu_store           => ctl_perv_stq4_perf_events(3)
      // (34) => perf_stq_icswxr_nbusy        => lsq_perv_stq_events(3+(1*`THREADS))
      // (35) => perf_stq_icswxr_busy         => lsq_perv_stq_events(3+(2*`THREADS))
      // (36) => perf_stq_wclr                => ctl_perv_stq4_perf_events(4)
      // (37) => perf_stq_wclr_set            => ctl_perv_stq4_perf_events(5)
      // (38) => perf_ldq_cpl_larx            => lsq_perv_ldq_events(4+(0*`THREADS))
      // (39) => perf_ldq_rel_attmpt          => lsq_perv_ldq_events(0)
      assign lq_perf_events[tid][32:39] = {stq_perf_events[tid][3], stq4_perf_events[tid][3], stq_perf_events[tid][4:5], stq4_perf_events[tid][4:5],
                                           ldq_perf_events[tid][4], ldq_perf_events[tid][0]};

      // (40) => perf_ldq_rel_cmmt            => lsq_perv_ldq_events(1)
      // (41) => perf_ldq_rel_need_hole       => lsq_perv_ldq_events(2)
      // (42) => perf_stq_cmmt_attmpt         => lsq_perv_stq_events(0)
      // (43) => perf_stq_cmmt_val            => lsq_perv_stq_events(1)
      // (44) => perf_stq_need_hole           => lsq_perv_stq_events(2)
      // (45) => perf_ex6_align_flush         => ctl_perv_ex6_perf_events(17)
      // (46) => perf_ldq_cpl_binv            => lsq_perv_ldq_events(4+(1*`THREADS))
      // (47) =>                              => lsq_perv_odq_events(0)
      assign lq_perf_events[tid][40:47] = {ldq_perf_events[tid][1:2], stq_perf_events[tid][0:2], ex6_perf_events[tid][17], ldq_perf_events[tid][5],
                                           odq_perf_events[tid][0]};

      // (48) =>                              => lsq_perv_odq_events(1)
      // (49) =>                              => lsq_perv_odq_events(2)
      // (50) =>                              => lsq_perv_odq_events(3)
      // (51) => perf_ldq_rel_latency         => lsq_perv_ldq_events(3)
      // (52) => perf_com_loads               => commit events, tied to 0
      // (53) => perf_com_loadmiss            => commit events, tied to 0
      // (54) => perf_com_cinh_loads          => commit events, tied to 0
      // (55) => perf_com_load_fwd            => commit events, tied to 0
      assign lq_perf_events[tid][48:55] = {odq_perf_events[tid][1:3], ldq_perf_events[tid][3], {4{1'b0}}};

      // (56) => perf_com_axu_load            => commit events, tied to 0
      // (57) => perf_com_dcbt_sent           => commit events, tied to 0
      // (58) => perf_com_dcbt_hit            => commit events, tied to 0
      // (59) => perf_com_watch_set           => commit events, tied to 0
      // (60) => perf_com_watch_dup           => commit events, tied to 0
      // (61) => perf_com_wchkall             => commit events, tied to 0
      // (62) => perf_com_wchkall_succ        => commit events, tied to 0
      // (63) => ex5_ld_gath_q                => commit events, tied to 0
      assign lq_perf_events[tid][56:63] = {8{1'b0}};

      assign lq_events_en[tid]  = lq_perf_events[tid] & {63{perf_event_en_q[tid]}};

      tri_event_mux1t #(.EVENTS_IN(64)) perfMux(
         .vd(vdd),
         .gd(gnd),
         .select_bits(perf_event_mux_ctrl[tid*24:(tid*24)+23]),
         .unit_events_in(lq_events_en[tid]),
         .event_bus_in(event_bus_in[tid*4:(tid*4)+3]),
         .event_bus_out(perf_event_data_d[tid*4:(tid*4)+3])
      );
  end
end
endgenerate

assign event_bus_out = perf_event_data_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Pervasive Clock Control Logic
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

tri_plat #(.WIDTH(18)) perv_3to2_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .flush(pc_lq_ccflush_dc),
   .din({pc_lq_func_sl_thold_3,
         pc_lq_func_slp_sl_thold_3,
         pc_lq_gptr_sl_thold_3,
         pc_lq_sg_3,
         pc_lq_fce_3,
         pc_lq_func_nsl_thold_3,
         pc_lq_func_slp_nsl_thold_3,
         pc_lq_abst_sl_thold_3,
         pc_lq_abst_slp_sl_thold_3,
         pc_lq_time_sl_thold_3,
         pc_lq_ary_nsl_thold_3,
         pc_lq_ary_slp_nsl_thold_3,
         pc_lq_cfg_sl_thold_3,
         pc_lq_repr_sl_thold_3,
         pc_lq_bolt_sl_thold_3,
         pc_lq_cfg_slp_sl_thold_3,
         pc_lq_regf_slp_sl_thold_3,
         pc_lq_bo_enable_3}),
   .q({func_sl_thold_2,
       func_slp_sl_thold_2_int,
       gptr_sl_thold_2,
       perv_sg_2,
       fce_2,
       func_nsl_thold_2,
       func_slp_nsl_thold_2,
       abst_sl_thold_2,
       abst_slp_sl_thold_2,
       time_sl_thold_2,
       ary_nsl_thold_2,
       ary_slp_nsl_thold_2,
       cfg_sl_thold_2,
       repr_sl_thold_2,
       bolt_sl_thold_2,
       cfg_slp_sl_thold_2,
       regf_slp_sl_thold_2,
       bo_enable_2})
);

assign sg_2 = perv_sg_2;

assign g6t_clkoff_dc_b     = g6t_clkoff_dc_b_int;
assign g6t_d_mode_dc       = g6t_d_mode_dc_int;
assign g6t_delay_lclkr_dc  = g6t_delay_lclkr_dc_int;
assign g6t_mpw1_dc_b       = g6t_mpw1_dc_b_int;
assign g6t_mpw2_dc_b       = g6t_mpw2_dc_b_int;

assign g8t_clkoff_dc_b     = g8t_clkoff_dc_b_int;
assign g8t_d_mode_dc       = g8t_d_mode_dc_int;
assign g8t_delay_lclkr_dc  = g8t_delay_lclkr_dc_int;
assign g8t_mpw1_dc_b       = g8t_mpw1_dc_b_int;
assign g8t_mpw2_dc_b       = g8t_mpw2_dc_b_int;

assign cam_clkoff_dc_b     = cam_clkoff_dc_b_int;
assign cam_delay_lclkr_dc  = cam_delay_lclkr_dc_int;
assign cam_act_dis_dc      = 1'b0;
assign cam_d_mode_dc       = cam_d_mode_dc_int;
assign cam_mpw1_dc_b       = cam_mpw1_dc_b_int;
assign cam_mpw2_dc_b       = cam_mpw2_dc_b_int;

assign func_slp_sl_thold_2 = func_slp_sl_thold_2_int;
assign clkoff_dc_b         = clkoff_dc_b_int[0];
assign d_mode_dc           = d_mode_dc_int[0];
assign delay_lclkr_dc      = delay_lclkr_dc_int;
assign mpw1_dc_b           = mpw1_dc_b_int;
assign mpw2_dc_b           = mpw2_dc_b_int[0];


tri_plat #(.WIDTH(3)) perv_2to1_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .flush(pc_lq_ccflush_dc),
   .din({gptr_sl_thold_2,
         func_slp_sl_thold_2_int,
         perv_sg_2}),
   .q({gptr_sl_thold_1,
       func_slp_sl_thold_1,
       sg_1})
);

tri_plat #(.WIDTH(3)) perv_1to0_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .flush(pc_lq_ccflush_dc),
   .din({gptr_sl_thold_1,
         func_slp_sl_thold_1,
         sg_1}),
   .q({gptr_sl_thold_0,
       func_slp_sl_thold_0,
       sg_0})
);

tri_lcbor perv_lcbor_func_slp_sl(
   .clkoff_b(clkoff_dc_b_int[0]),
   .thold(func_slp_sl_thold_0),
   .sg(sg_0),
   .act_dis(tidn),
   .force_t(func_slp_sl_force),
   .thold_b(func_slp_sl_thold_0_b)
);

tri_lcbcntl_mac perv_lcbctrl_0(
   .vdd(vdd),
   .gnd(gnd),
   .sg(sg_0),
   .nclk(nclk),
   .scan_in(gptr_siv[3]),
   .scan_diag_dc(an_ac_scan_diag_dc),
   .thold(gptr_sl_thold_0),
   .clkoff_dc_b(clkoff_dc_b_int[0]),
   .delay_lclkr_dc(delay_lclkr_dc_int[0:4]),
   .act_dis_dc(act_dis_dc_int[0]),
   .d_mode_dc(d_mode_dc_int[0]),
   .mpw1_dc_b(mpw1_dc_b_int[0:4]),
   .mpw2_dc_b(mpw2_dc_b_int[0]),
   .scan_out(gptr_sov[3])
);

tri_lcbcntl_mac perv_lcbctrl_1(
   .vdd(vdd),
   .gnd(gnd),
   .sg(sg_0),
   .nclk(nclk),
   .scan_in(gptr_siv[4]),
   .scan_diag_dc(an_ac_scan_diag_dc),
   .thold(gptr_sl_thold_0),
   .clkoff_dc_b(clkoff_dc_b_int[1]),
   .delay_lclkr_dc(delay_lclkr_dc_int[5:9]),
   .act_dis_dc(act_dis_dc_int[1]),
   .d_mode_dc(d_mode_dc_int[1]),
   .mpw1_dc_b(mpw1_dc_b_int[5:9]),
   .mpw2_dc_b(mpw2_dc_b_int[1]),
   .scan_out(gptr_sov[4])
);

tri_lcbcntl_array_mac perv_lcbctrl_g6t_0(
   .vdd(vdd),
   .gnd(gnd),
   .sg(sg_0),
   .nclk(nclk),
   .scan_in(gptr_siv[0]),
   .scan_diag_dc(an_ac_scan_diag_dc),
   .thold(gptr_sl_thold_0),
   .clkoff_dc_b(g6t_clkoff_dc_b_int),
   .delay_lclkr_dc(g6t_delay_lclkr_dc_int[0:4]),
   .act_dis_dc(g6t_act_dis_dc_int),
   .d_mode_dc(g6t_d_mode_dc_int),
   .mpw1_dc_b(g6t_mpw1_dc_b_int[0:4]),
   .mpw2_dc_b(g6t_mpw2_dc_b_int),
   .scan_out(gptr_sov[0])
);

tri_lcbcntl_array_mac perv_lcbctrl_g8t_0(
   .vdd(vdd),
   .gnd(gnd),
   .sg(sg_0),
   .nclk(nclk),
   .scan_in(gptr_siv[1]),
   .scan_diag_dc(an_ac_scan_diag_dc),
   .thold(gptr_sl_thold_0),
   .clkoff_dc_b(g8t_clkoff_dc_b_int),
   .delay_lclkr_dc(g8t_delay_lclkr_dc_int[0:4]),
   .act_dis_dc(g8t_act_dis_dc_int),
   .d_mode_dc(g8t_d_mode_dc_int),
   .mpw1_dc_b(g8t_mpw1_dc_b_int[0:4]),
   .mpw2_dc_b(g8t_mpw2_dc_b_int),
   .scan_out(gptr_sov[1])
);

tri_lcbcntl_array_mac perv_lcbctrl_cam_0(
   .vdd(vdd),
   .gnd(gnd),
   .sg(sg_0),
   .nclk(nclk),
   .scan_in(gptr_siv[2]),
   .scan_diag_dc(an_ac_scan_diag_dc),
   .thold(gptr_sl_thold_0),
   .clkoff_dc_b(cam_clkoff_dc_b_int),
   .delay_lclkr_dc(cam_delay_lclkr_dc_int[0:4]),
   .act_dis_dc(cam_act_dis_ac_int),
   .d_mode_dc(cam_d_mode_dc_int),
   .mpw1_dc_b(cam_mpw1_dc_b_int[0:4]),
   .mpw2_dc_b(cam_mpw2_dc_b_int),
   .scan_out(gptr_sov[2])
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Registers
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_lq_trace_bus_enable_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[pc_lq_trace_bus_enable_offset]),
   .scout(sov[pc_lq_trace_bus_enable_offset]),
   .din(pc_lq_trace_bus_enable),
   .dout(pc_lq_trace_bus_enable_q)
);

tri_rlmreg_p #(.WIDTH(11), .INIT(0), .NEEDS_SRESET(1)) pc_lq_debug_mux1_ctrls_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(pc_lq_trace_bus_enable_q),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[pc_lq_debug_mux1_ctrls_offset:pc_lq_debug_mux1_ctrls_offset + 11 - 1]),
   .scout(sov[pc_lq_debug_mux1_ctrls_offset:pc_lq_debug_mux1_ctrls_offset + 11 - 1]),
   .din(pc_lq_debug_mux1_ctrls),
   .dout(pc_lq_debug_mux1_ctrls_q)
);

tri_rlmreg_p #(.WIDTH(11), .INIT(0), .NEEDS_SRESET(1)) pc_lq_debug_mux2_ctrls_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(pc_lq_trace_bus_enable_q),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[pc_lq_debug_mux2_ctrls_offset:pc_lq_debug_mux2_ctrls_offset + 11 - 1]),
   .scout(sov[pc_lq_debug_mux2_ctrls_offset:pc_lq_debug_mux2_ctrls_offset + 11 - 1]),
   .din(pc_lq_debug_mux2_ctrls),
   .dout(pc_lq_debug_mux2_ctrls_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_lq_instr_trace_mode_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[pc_lq_instr_trace_mode_offset]),
   .scout(sov[pc_lq_instr_trace_mode_offset]),
   .din(pc_lq_instr_trace_mode),
   .dout(pc_lq_instr_trace_mode_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) pc_lq_instr_trace_tid_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(pc_lq_trace_bus_enable_q),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[pc_lq_instr_trace_tid_offset:pc_lq_instr_trace_tid_offset + `THREADS - 1]),
   .scout(sov[pc_lq_instr_trace_tid_offset:pc_lq_instr_trace_tid_offset + `THREADS - 1]),
   .din(pc_lq_instr_trace_tid),
   .dout(pc_lq_instr_trace_tid_q)
);

tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) lq_mux1_debug_data_out_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(pc_lq_trace_bus_enable_q),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq_mux1_debug_data_out_offset:lq_mux1_debug_data_out_offset + 32 - 1]),
   .scout(sov[lq_mux1_debug_data_out_offset:lq_mux1_debug_data_out_offset + 32 - 1]),
   .din(lq_mux1_debug_data_out_d),
   .dout(lq_mux1_debug_data_out_q)
);

tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lq_mux1_coretrace_out_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(pc_lq_trace_bus_enable_q),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq_mux1_coretrace_out_offset:lq_mux1_coretrace_out_offset + 4 - 1]),
   .scout(sov[lq_mux1_coretrace_out_offset:lq_mux1_coretrace_out_offset + 4 - 1]),
   .din(lq_mux1_coretrace_out_d),
   .dout(lq_mux1_coretrace_out_q)
);

tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) lq_mux2_debug_data_out_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(pc_lq_trace_bus_enable_q),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq_mux2_debug_data_out_offset:lq_mux2_debug_data_out_offset + 32 - 1]),
   .scout(sov[lq_mux2_debug_data_out_offset:lq_mux2_debug_data_out_offset + 32 - 1]),
   .din(lq_mux2_debug_data_out_d),
   .dout(lq_mux2_debug_data_out_q)
);

tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lq_mux2_coretrace_out_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(pc_lq_trace_bus_enable_q),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq_mux2_coretrace_out_offset:lq_mux2_coretrace_out_offset + 4 - 1]),
   .scout(sov[lq_mux2_coretrace_out_offset:lq_mux2_coretrace_out_offset + 4 - 1]),
   .din(lq_mux2_coretrace_out_d),
   .dout(lq_mux2_coretrace_out_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_gs_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[spr_msr_gs_offset:spr_msr_gs_offset + `THREADS - 1]),
   .scout(sov[spr_msr_gs_offset:spr_msr_gs_offset + `THREADS - 1]),
   .din(spr_msr_gs_d),
   .dout(spr_msr_gs_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_pr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[spr_msr_pr_offset:spr_msr_pr_offset + `THREADS - 1]),
   .scout(sov[spr_msr_pr_offset:spr_msr_pr_offset + `THREADS - 1]),
   .din(spr_msr_pr_d),
   .dout(spr_msr_pr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_lq_event_bus_enable_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[pc_lq_event_bus_enable_offset]),
   .scout(sov[pc_lq_event_bus_enable_offset]),
   .din(pc_lq_event_bus_enable),
   .dout(pc_lq_event_bus_enable_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) perf_event_en_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(pc_lq_event_bus_enable_q),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[perf_event_en_offset:perf_event_en_offset + `THREADS - 1]),
   .scout(sov[perf_event_en_offset:perf_event_en_offset + `THREADS - 1]),
   .din(perf_event_en_d),
   .dout(perf_event_en_q)
);

tri_rlmreg_p #(.WIDTH((4*`THREADS)), .INIT(0), .NEEDS_SRESET(1)) perf_event_data_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(pc_lq_event_bus_enable_q),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[perf_event_data_offset:perf_event_data_offset + (4*`THREADS) - 1]),
   .scout(sov[perf_event_data_offset:perf_event_data_offset + (4*`THREADS) - 1]),
   .din(perf_event_data_d),
   .dout(perf_event_data_q)
);

tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) pc_lq_event_count_mode_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(pc_lq_event_bus_enable_q),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc_int[0]),
   .delay_lclkr(delay_lclkr_dc_int[0]),
   .mpw1_b(mpw1_dc_b_int[0]),
   .mpw2_b(mpw2_dc_b_int[0]),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[pc_lq_event_count_mode_offset:pc_lq_event_count_mode_offset + 3 - 1]),
   .scout(sov[pc_lq_event_count_mode_offset:pc_lq_event_count_mode_offset + 3 - 1]),
   .din(pc_lq_event_count_mode),
   .dout(pc_lq_event_count_mode_q)
);

assign gptr_siv[0:4]     = {gptr_sov[1:4], gptr_scan_in};
assign gptr_scan_out     = gptr_sov[0];
assign siv[0:scan_right] = {sov[1:scan_right], func_scan_in};
assign func_scan_out     = sov[0];

endmodule
