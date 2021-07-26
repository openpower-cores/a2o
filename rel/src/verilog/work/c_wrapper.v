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

`define THREADS1
`include "tri_a2o.vh"

module c_wrapper(
//   vcs,
//   vdd,
//   gnd,
   clk,
   clk2x,
   clk4x,
   reset,
   an_ac_coreid,
   an_ac_pm_thread_stop,
   an_ac_ext_interrupt,
   an_ac_crit_interrupt,
   an_ac_perf_interrupt,
   an_ac_external_mchk,
   an_ac_flh2l2_gate,
   an_ac_reservation_vld,
   ac_an_debug_trigger,
   an_ac_debug_stop,
   an_ac_tb_update_enable,
   an_ac_tb_update_pulse,
   an_ac_hang_pulse,
   ac_an_pm_thread_running,
   ac_an_machine_check,
   ac_an_recov_err,
   ac_an_checkstop,
   ac_an_local_checkstop,

   an_ac_stcx_complete,
   an_ac_stcx_pass,

   an_ac_reld_data_vld,
   an_ac_reld_core_tag,
   an_ac_reld_data,
   an_ac_reld_qw,
   an_ac_reld_ecc_err,
   an_ac_reld_ecc_err_ue,
   an_ac_reld_data_coming,

   an_ac_reld_crit_qw,
   an_ac_reld_l1_dump,

   an_ac_req_ld_pop,
   an_ac_req_st_pop,
   an_ac_req_st_gather,
   an_ac_sync_ack,

   ac_an_req_pwr_token,
   ac_an_req,
   ac_an_req_ra,
   ac_an_req_ttype,
   ac_an_req_thread,
   ac_an_req_wimg_w,
   ac_an_req_wimg_i,
   ac_an_req_wimg_m,
   ac_an_req_wimg_g,
   ac_an_req_user_defined,
   ac_an_req_ld_core_tag,
   ac_an_req_ld_xfr_len,
   ac_an_st_byte_enbl,
   ac_an_st_data,
   ac_an_req_endian,
   ac_an_st_data_pwr_token
);

        input clk;
        input clk2x;
        input clk4x;
        input reset;
        input [0:7]    an_ac_coreid;
        input [0:3]    an_ac_pm_thread_stop;
        input [0:3]    an_ac_ext_interrupt;
        input [0:3]    an_ac_crit_interrupt;
        input [0:3]    an_ac_perf_interrupt;
        input [0:3]    an_ac_external_mchk;
        input          an_ac_flh2l2_gate;      // Gate L1 Hit forwarding SPR config bit
        input [0:3]    an_ac_reservation_vld;
        output [0:3]    ac_an_debug_trigger;
        input          an_ac_debug_stop;
        input          an_ac_tb_update_enable;
        input          an_ac_tb_update_pulse;
        input  [0:3]    an_ac_hang_pulse;
        output [0:3]   ac_an_pm_thread_running;
        output [0:3]   ac_an_machine_check;
        output [0:2]   ac_an_recov_err;
        output [0:2]   ac_an_checkstop;
        output [0:2]   ac_an_local_checkstop;

   wire         scan_in;
   wire         scan_out;

   // Pervasive clock control
   wire          an_ac_rtim_sl_thold_8;
   wire          an_ac_func_sl_thold_8;
   wire          an_ac_func_nsl_thold_8;
   wire          an_ac_ary_nsl_thold_8;
   wire          an_ac_sg_8;
   wire          an_ac_fce_8;
   wire [0:7]    an_ac_abst_scan_in;

   // L2 STCX complete
   input [0:3]    an_ac_stcx_complete;
   input [0:3]    an_ac_stcx_pass;

   // ICBI ACK Interface
   wire          an_ac_icbi_ack;
   wire [0:1]    an_ac_icbi_ack_thread;

   // Back invalidate interface
   wire          an_ac_back_inv;
   wire [22:63]  an_ac_back_inv_addr;
   wire [0:4]    an_ac_back_inv_target;     // connect to bit(0)
   wire          an_ac_back_inv_local;
   wire          an_ac_back_inv_lbit;
   wire          an_ac_back_inv_gs;
   wire          an_ac_back_inv_ind;
   wire [0:7]    an_ac_back_inv_lpar_id;
   wire         ac_an_back_inv_reject;
   wire [0:7]   ac_an_lpar_id;

   // L2 Reload Inputs
   input          an_ac_reld_data_vld;    // reload data is coming next cycle
   input [0:4]    an_ac_reld_core_tag;    // reload data destinatoin tag (which load queue)
   input [0:127]  an_ac_reld_data;     // Reload Data
   input [57:59]  an_ac_reld_qw;    // quadword address of reload data beat
   input          an_ac_reld_ecc_err;     // Reload Data contains a Correctable ECC error
   input          an_ac_reld_ecc_err_ue;     // Reload Data contains an Uncorrectable ECC error
   input          an_ac_reld_data_coming;
   wire          an_ac_reld_ditc;
   input          an_ac_reld_crit_qw;
   input          an_ac_reld_l1_dump;
   wire [0:3]    an_ac_req_spare_ctrl_a1;      // spare control bits from L2

   // load/store credit control
   input          an_ac_req_ld_pop;    // credit for a load (L2 can take a load command)
   input          an_ac_req_st_pop;    // credit for a store (L2 can take a store command)
   input          an_ac_req_st_gather;    // credit for a store due to L2 gathering of store commands
   input [0:3]    an_ac_sync_ack;

   //SCOM Satellite
   wire [0:3]    an_ac_scom_sat_id;
   wire          an_ac_scom_dch;
   wire          an_ac_scom_cch;
   wire         ac_an_scom_dch;
   wire         ac_an_scom_cch;

   // FIR and Error Signals
   wire [0:0]   ac_an_special_attn;
   wire         ac_an_trace_error;
   wire     ac_an_livelock_active;
   wire          an_ac_checkstop;

   // Perfmon Event Bus
   wire [0:3]   ac_an_event_bus0;
   wire [0:3]   ac_an_event_bus1;

   // Reset related
   wire          an_ac_reset_1_complete;
   wire          an_ac_reset_2_complete;
   wire          an_ac_reset_3_complete;
   wire          an_ac_reset_wd_complete;

   // Power Management
   wire [0:0]    an_ac_pm_fetch_halt;
   wire         ac_an_power_managed;
   wire         ac_an_rvwinkle_mode;

   // Clock, Test, and LCB Controls
   wire          an_ac_gsd_test_enable_dc;
   wire          an_ac_gsd_test_acmode_dc;
   wire          an_ac_ccflush_dc;
   wire          an_ac_ccenable_dc;
   wire          an_ac_lbist_en_dc;
   wire          an_ac_lbist_ip_dc;
   wire          an_ac_lbist_ac_mode_dc;
   wire          an_ac_scan_diag_dc;
   wire          an_ac_scan_dis_dc_b;

   //Thold input to clock control macro
   wire [0:8]    an_ac_scan_type_dc;

   // Pervasive
   wire         ac_an_reset_1_request;
   wire         ac_an_reset_2_request;
   wire         ac_an_reset_3_request;
   wire         ac_an_reset_wd_request;
   wire          an_ac_lbist_ary_wrt_thru_dc;
   wire [0:0]    an_ac_sleep_en;
   wire [0:3]    an_ac_chipid_dc;
   wire [0:0]    an_ac_uncond_dbg_event;
   wire [0:31]  ac_an_debug_bus;
   wire         ac_an_coretrace_first_valid;  // coretrace_ctrls[0]
   wire     ac_an_coretrace_valid;   // coretrace_ctrls[1]
   wire [0:1]     ac_an_coretrace_type;    // coretrace_ctrls[2:3]

   // L2 Outputs
   output         ac_an_req_pwr_token;    // power token for command coming next cycle
   output         ac_an_req;     // command request valid
   output [22:63] ac_an_req_ra;     // real address for request
   output [0:5]   ac_an_req_ttype;     // command (transaction) type
   output [0:2]   ac_an_req_thread;    // encoded thread ID
   output         ac_an_req_wimg_w;    // write-through
   output         ac_an_req_wimg_i;    // cache-inhibited
   output         ac_an_req_wimg_m;    // memory coherence required
   output         ac_an_req_wimg_g;    // guarded memory
   output [0:3]   ac_an_req_user_defined;    // User Defined Bits
   wire [0:3]   ac_an_req_spare_ctrl_a0;      // Spare bits
   output [0:4]   ac_an_req_ld_core_tag;     // load command tag (which load Q)
   output [0:2]   ac_an_req_ld_xfr_len;      // transfer length for non-cacheable load
   output [0:31]  ac_an_st_byte_enbl;     // byte enables for store data
   output [0:255] ac_an_st_data;    // store data
   output         ac_an_req_endian;    // endian mode (0=big endian, 1=little endian)
   output         ac_an_st_data_pwr_token;      // store data power token


   // constant EXPAND_TYPE           : integer $ 1;

   wire           clk_reset;
   wire [0:15]    rate;
   wire [0:3]     div2;
   wire [0:3]     div3;
   wire [0:`NCLK_WIDTH-1]          nclk;
   wire [1:3]     osc;


   // component variable_osc

   // Pervasive clock control

   // L2 STCX complete

   // ICBI ACK Interface

   // Back invalidate interface
   // connect to bit(0)

   // L2 Reload Inputs
   // reload data is coming next cycle
   // reload data destinatoin tag (which load queue)
   // Reload Data
   // quadword address of reload data beat
   // Reload Data contains a Correctable ECC error
   // Reload Data contains an Uncorrectable ECC error
   // spare control bits from L2

   // load/store credit control
   // Gate L1 Hit forwarding SPR config bit
   // credit for a load (L2 can take a load command)
   // credit for a store (L2 can take a store command)
   // credit for a store due to L2 gathering of store commands

   //SCOM Satellite

   // FIR and Error Signals

   // Perfmon Event Bus

   // Reset related

   // Power Management

   // Clock, Test, and LCB Controls

   //Thold input to clock control macro

   // PSRO Sensors

   // ABIST Engine

   // Bolt-On ABIST system interface

   // Pervasive

   // L2 Outputs
   // power token for command coming next cycle
   // command request valid
   // real address for request
   // command (transaction) type
   // encoded thread ID
   // write-through
   // cache-inhibited
   // memory coherence required
   // guarded memory
   // User Defined Bits
   // Spare bits
   // load command tag (which load Q)
   // transfer length for non-cacheable load
   // byte enables for store data
   // store data
   // endian mode (0=big endian, 1=little endian)
   // store data power token

   assign rate = 16'b0000000100000000;
   assign div2 = 4'b0010;
   assign div3 = 4'b0100;
   assign clk_reset = 1'b1;

   assign an_ac_ccflush_dc = 1'b0;
    assign an_ac_rtim_sl_thold_8= 1'b0;
    assign an_ac_func_sl_thold_8= 1'b0;
    assign an_ac_func_nsl_thold_8= 1'b0;
    assign an_ac_ary_nsl_thold_8= 1'b0;
    assign an_ac_sg_8= 1'b0;
    assign an_ac_fce_8= 1'b0;
   assign scan_in = 'b0;
   assign an_ac_abst_scan_in = 'b0;
   assign an_ac_icbi_ack = 'b0;
   assign an_ac_icbi_ack_thread = 'b0;
   assign an_ac_back_inv = 'b0;
   assign an_ac_back_inv_addr = 'b0;
   assign an_ac_back_inv_target = 'b0;
   assign an_ac_back_inv_local = 'b0;
   assign an_ac_back_inv_lbit = 'b0;
   assign an_ac_back_inv_gs = 'b0;
   assign an_ac_back_inv_ind = 'b0;
   assign an_ac_back_inv_lpar_id = 'b0;
   assign an_ac_reld_ditc = 'b0;
   assign an_ac_req_spare_ctrl_a1 = 'b0;
   assign an_ac_scom_sat_id = 'b0;
   assign an_ac_scom_dch = 'b0;
   assign an_ac_scom_cch = 'b0;
   assign an_ac_checkstop = 'b0;
   assign an_ac_reset_1_complete = 'b0;
   assign an_ac_reset_2_complete = 'b0;
   assign an_ac_reset_3_complete = 'b0;
   assign an_ac_reset_wd_complete = 'b0;
   assign an_ac_pm_fetch_halt = 'b0;
   assign an_ac_gsd_test_enable_dc = 'b0;
   assign an_ac_gsd_test_acmode_dc = 'b0;
   assign an_ac_ccflush_dc = 'b0;
   assign an_ac_ccenable_dc = 'b0;
   assign an_ac_lbist_en_dc = 'b0;
   assign an_ac_lbist_ip_dc = 'b0;
   assign an_ac_lbist_ac_mode_dc = 'b0;
   assign an_ac_scan_diag_dc = 'b0;
   assign an_ac_scan_dis_dc_b = 'b0;
   assign an_ac_scan_type_dc = 'b0;
   assign an_ac_lbist_ary_wrt_thru_dc = 'b0;
   assign an_ac_sleep_en = 'b0;
   assign an_ac_chipid_dc = 'b0;
   assign an_ac_uncond_dbg_event = 'b0;

   assign nclk[0] = clk;
   assign nclk[1] = reset;
   assign nclk[2] = clk2x;
   assign nclk[3] = clk4x;
   assign nclk[4] = 'b0;
   assign nclk[5] = 'b0;




(*dont_touch = "true" *)   c c0(
//      .vcs(vcs),
//      .vdd(vdd),
//      .gnd(gnd),
      .nclk(nclk),
      .scan_in(scan_in),
      .scan_out(scan_out),

      // Pervasive clock control
      .an_ac_rtim_sl_thold_8(an_ac_rtim_sl_thold_8),
      .an_ac_func_sl_thold_8(an_ac_func_sl_thold_8),
      .an_ac_func_nsl_thold_8(an_ac_func_nsl_thold_8),
      .an_ac_ary_nsl_thold_8(an_ac_ary_nsl_thold_8),
      .an_ac_sg_8(an_ac_sg_8),
      .an_ac_fce_8(an_ac_fce_8),
      .an_ac_abst_scan_in(an_ac_abst_scan_in),

      // L2 STCX complete
      .an_ac_stcx_complete(an_ac_stcx_complete[0:`THREADS-1]),
      .an_ac_stcx_pass(an_ac_stcx_pass[0:`THREADS-1]),

      // ICBI ACK Interface
      .an_ac_icbi_ack(an_ac_icbi_ack),
      .an_ac_icbi_ack_thread(an_ac_icbi_ack_thread),

      // Back invalidate interface
      .an_ac_back_inv(an_ac_back_inv),
      .an_ac_back_inv_addr(an_ac_back_inv_addr),
      .an_ac_back_inv_target(an_ac_back_inv_target),
      .an_ac_back_inv_local(an_ac_back_inv_local),
      .an_ac_back_inv_lbit(an_ac_back_inv_lbit),
      .an_ac_back_inv_gs(an_ac_back_inv_gs),
      .an_ac_back_inv_ind(an_ac_back_inv_ind),
      .an_ac_back_inv_lpar_id(an_ac_back_inv_lpar_id),
      .ac_an_back_inv_reject(ac_an_back_inv_reject),
      .ac_an_lpar_id(ac_an_lpar_id),

      // L2 Reload Inputs
      .an_ac_reld_data_vld(an_ac_reld_data_vld),
      .an_ac_reld_core_tag(an_ac_reld_core_tag),
      .an_ac_reld_data(an_ac_reld_data),
      .an_ac_reld_qw(an_ac_reld_qw[58:59]),
      .an_ac_reld_ecc_err(an_ac_reld_ecc_err),
      .an_ac_reld_ecc_err_ue(an_ac_reld_ecc_err_ue),
      .an_ac_reld_data_coming(an_ac_reld_data_coming),
      .an_ac_reld_ditc(an_ac_reld_ditc),
      .an_ac_reld_crit_qw(an_ac_reld_crit_qw),
      .an_ac_reld_l1_dump(an_ac_reld_l1_dump),
      .an_ac_req_spare_ctrl_a1(an_ac_req_spare_ctrl_a1),

      // load/store credit control
      .an_ac_flh2l2_gate(an_ac_flh2l2_gate),
      .an_ac_req_ld_pop(an_ac_req_ld_pop),
      .an_ac_req_st_pop(an_ac_req_st_pop),
      .an_ac_req_st_gather(an_ac_req_st_gather),
      .an_ac_sync_ack(an_ac_sync_ack[0:`THREADS-1]),

      //SCOM Satellite
      .an_ac_scom_sat_id(an_ac_scom_sat_id),
      .an_ac_scom_dch(an_ac_scom_dch),
      .an_ac_scom_cch(an_ac_scom_cch),
      .ac_an_scom_dch(ac_an_scom_dch),
      .ac_an_scom_cch(ac_an_scom_cch),

      // FIR and Error Signals
      .ac_an_special_attn(ac_an_special_attn),
      .ac_an_checkstop(ac_an_checkstop),
      .ac_an_local_checkstop(ac_an_local_checkstop),
      .ac_an_recov_err(ac_an_recov_err),
      .ac_an_trace_error(ac_an_trace_error),
      .ac_an_livelock_active(ac_an_livelock_active),
      .an_ac_checkstop(an_ac_checkstop),
      .an_ac_external_mchk(an_ac_external_mchk[0:`THREADS-1]),

      // Perfmon Event Bus
      .ac_an_event_bus0(ac_an_event_bus0),
      .ac_an_event_bus1(ac_an_event_bus1),

      // Reset related
      .an_ac_reset_1_complete(an_ac_reset_1_complete),
      .an_ac_reset_2_complete(an_ac_reset_2_complete),
      .an_ac_reset_3_complete(an_ac_reset_3_complete),
      .an_ac_reset_wd_complete(an_ac_reset_wd_complete),

      // Power Management
      .ac_an_pm_thread_running(ac_an_pm_thread_running[0:`THREADS-1]),
      .an_ac_pm_thread_stop(an_ac_pm_thread_stop[0:`THREADS-1]),
      .an_ac_pm_fetch_halt(an_ac_pm_fetch_halt),
      .ac_an_power_managed(ac_an_power_managed),
      .ac_an_rvwinkle_mode(ac_an_rvwinkle_mode),

      // Clock, Test, and LCB Controls
      .an_ac_gsd_test_enable_dc(an_ac_gsd_test_enable_dc),
      .an_ac_gsd_test_acmode_dc(an_ac_gsd_test_acmode_dc),
      .an_ac_ccflush_dc(an_ac_ccflush_dc),
      .an_ac_ccenable_dc(an_ac_ccenable_dc),
      .an_ac_lbist_en_dc(an_ac_lbist_en_dc),
      .an_ac_lbist_ip_dc(an_ac_lbist_ip_dc),
      .an_ac_lbist_ac_mode_dc(an_ac_lbist_ac_mode_dc),
      .an_ac_scan_diag_dc(an_ac_scan_diag_dc),
      .an_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),

      //Thold input to clock control macro
      .an_ac_scan_type_dc(an_ac_scan_type_dc),

      // Pervasive
      .ac_an_reset_1_request(ac_an_reset_1_request),
      .ac_an_reset_2_request(ac_an_reset_2_request),
      .ac_an_reset_3_request(ac_an_reset_3_request),
      .ac_an_reset_wd_request(ac_an_reset_wd_request),
      .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
      .an_ac_reservation_vld(an_ac_reservation_vld[0:`THREADS-1]),
      .an_ac_sleep_en(an_ac_sleep_en),
      .an_ac_ext_interrupt(an_ac_ext_interrupt[0:`THREADS-1]),
      .an_ac_crit_interrupt(an_ac_crit_interrupt[0:`THREADS-1]),
      .an_ac_perf_interrupt(an_ac_perf_interrupt[0:`THREADS-1]),
      .an_ac_hang_pulse(an_ac_hang_pulse[0:`THREADS-1]),
      .an_ac_tb_update_enable(an_ac_tb_update_enable),
      .an_ac_tb_update_pulse(an_ac_tb_update_pulse),
      .an_ac_chipid_dc(an_ac_chipid_dc),
      .an_ac_coreid(an_ac_coreid),
      .ac_an_machine_check(ac_an_machine_check[0:`THREADS-1]),
      .an_ac_debug_stop(an_ac_debug_stop),
      .ac_an_debug_trigger(ac_an_debug_trigger[0:`THREADS-1]),
      .an_ac_uncond_dbg_event(an_ac_uncond_dbg_event),
      .ac_an_debug_bus(ac_an_debug_bus),
      .ac_an_coretrace_first_valid(ac_an_coretrace_first_valid),
      .ac_an_coretrace_valid(ac_an_coretrace_valid),
      .ac_an_coretrace_type(ac_an_coretrace_type),

      // L2 Outputs
      .ac_an_req_pwr_token(ac_an_req_pwr_token),
      .ac_an_req(ac_an_req),
      .ac_an_req_ra(ac_an_req_ra),
      .ac_an_req_ttype(ac_an_req_ttype),
      .ac_an_req_thread(ac_an_req_thread),
      .ac_an_req_wimg_w(ac_an_req_wimg_w),
      .ac_an_req_wimg_i(ac_an_req_wimg_i),
      .ac_an_req_wimg_m(ac_an_req_wimg_m),
      .ac_an_req_wimg_g(ac_an_req_wimg_g),
      .ac_an_req_user_defined(ac_an_req_user_defined),
      .ac_an_req_spare_ctrl_a0(ac_an_req_spare_ctrl_a0),
      .ac_an_req_ld_core_tag(ac_an_req_ld_core_tag),
      .ac_an_req_ld_xfr_len(ac_an_req_ld_xfr_len),
      .ac_an_st_byte_enbl(ac_an_st_byte_enbl),
      .ac_an_st_data(ac_an_st_data),
      .ac_an_req_endian(ac_an_req_endian),
      .ac_an_st_data_pwr_token(ac_an_st_data_pwr_token)
   );

endmodule
