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
//  Description: Pervasive Core Debug/Event Bus Controls
//
//*****************************************************************************

module pcq_dbg(
// Include model build parameters
`include "tri_a2o.vh"

   inout                    vdd,
   inout                    gnd,
   input  [0:`NCLK_WIDTH-1] nclk,
   input                    scan_dis_dc_b,
   input                    lcb_clkoff_dc_b,
   input                    lcb_mpw1_dc_b,
   input                    lcb_mpw2_dc_b,
   input                    lcb_delay_lclkr_dc,
   input                    lcb_act_dis_dc,
   input                    pc_pc_func_slp_sl_thold_0,
   input                    pc_pc_sg_0,
   input                    func_scan_in,
   output                   func_scan_out,
   // Trace/Trigger Bus
   output [0:31]            debug_bus_out,
   input  [0:31]            debug_bus_in,
   input                    rg_db_trace_bus_enable,
   input  [0:10]            rg_db_debug_mux_ctrls,
   input  [0:3]		    coretrace_ctrls_in,
   output [0:3]		    coretrace_ctrls_out,
   //PC Unit internal debug signals
   input  [0:11]            rg_db_dbg_scom,
   input  [0:24]            rg_db_dbg_thrctls,
   input  [0:15]            rg_db_dbg_ram,
   input  [0:27]            rg_db_dbg_fir0_err,
   input  [0:19]            rg_db_dbg_fir1_err,
   input  [0:19]            rg_db_dbg_fir2_err,
   input  [0:14]            rg_db_dbg_fir_misc,
   input  [0:14]            ct_db_dbg_ctrls,
   input  [0:7]             rg_db_dbg_spr
);


//=====================================================================
// Signal Declarations
//=====================================================================
   parameter                RAMCTRL_SIZE = 2;
   parameter                SCMISC_SIZE = 7;
   parameter                FIRMISC_SIZE = 2;
   parameter                TRACEOUT_SIZE = 32;
   parameter                CORETRACE_SIZE = 4;

   //---------------------------------------------------------------------
   // Scan Ring Ordering:
   // start of func scan chain ordering
   parameter                RAMCTRL_OFFSET = 0;
   parameter                SCMISC_OFFSET = RAMCTRL_OFFSET + RAMCTRL_SIZE;
   parameter                FIRMISC_OFFSET = SCMISC_OFFSET + SCMISC_SIZE;
   parameter                TRACEOUT_OFFSET = FIRMISC_OFFSET + FIRMISC_SIZE;
   parameter                CORETRACE_OFFSET = TRACEOUT_OFFSET + TRACEOUT_SIZE;
   parameter                FUNC_RIGHT = CORETRACE_OFFSET + CORETRACE_SIZE - 1;
   // end of func scan chain ordering

   //---------------------------------------------------------------------
   // Basic/Misc signals
   wire [0:FUNC_RIGHT]      func_siv;
   wire [0:FUNC_RIGHT]      func_sov;
   wire                     pc_pc_func_slp_sl_thold_0_b;
   wire                     force_func;

   // Trace/Trigger/Event Mux signals
   wire [0:TRACEOUT_SIZE-1] debug_group_0;
   wire [0:TRACEOUT_SIZE-1] debug_group_1;
   wire [0:TRACEOUT_SIZE-1] debug_group_2;
   wire [0:TRACEOUT_SIZE-1] debug_group_3;
   wire [0:TRACEOUT_SIZE-1] debug_group_4;
   wire [0:TRACEOUT_SIZE-1] debug_group_5;
   wire [0:TRACEOUT_SIZE-1] debug_group_6;
   wire [0:TRACEOUT_SIZE-1] debug_group_7;
   // Trace/Trigger input signals
   wire [0:31]              fir0_errors_q;
   wire [0:31]              fir1_errors_q;
   wire [0:31]              fir2_errors_q;
   wire [0:2]               fir_xstop_err_q;
   wire [0:2]               fir_lxstop_err_q;
   wire [0:2]               fir_recov_err_q;
   wire                     fir0_recov_err_pulse_q;
   wire                     fir1_recov_err_pulse_q;
   wire                     fir2_recov_err_pulse_q;
   wire                     fir_block_ram_mode_q;
   wire [0:1]               fir_xstop_per_thread_d;
   wire [0:1]               fir_xstop_per_thread_q;
   //
   wire                     scmisc_sc_act_d;
   wire                     scmisc_sc_act_q;
   wire                     scmisc_sc_req_q;
   wire                     scmisc_sc_wr_q;
   wire [0:5]               scmisc_scaddr_predecode_d;
   wire [0:5]               scmisc_scaddr_predecode_q;
   wire   	            scmisc_scaddr_nvld_q;
   wire   	            scmisc_sc_wr_nvld_q;
   wire   	            scmisc_sc_rd_nvld_q;
   //
   wire                     ram_mode_q;
   wire [0:1]               ram_active_q;
   wire                     ram_execute_q;
   wire			    ram_msrovren_q;
   wire			    ram_msrovrpr_q;
   wire			    ram_msrovrgs_q;
   wire			    ram_msrovrde_q;
   wire			    ram_unsupported_q;
   wire			    ram_instr_overrun_d;
   wire			    ram_instr_overrun_q;
   wire                     ram_interrupt_q;
   wire			    ram_mode_xstop_d;
   wire			    ram_mode_xstop_q;
   wire                     ram_done_q;
   wire                     ram_xu_ram_data_val_q;
   wire                     ram_fu_ram_data_val_q;
   wire                     ram_lq_ram_data_val_q;
   //
   wire       	            regs_xstop_report_ovrid;
   wire    	            regs_dis_pwr_savings;
   wire    	            regs_dis_overrun_chks;
   wire		            regs_maxRecErrCntrValue;
   wire		            regs_ext_debug_stop_q;
   wire [0:1]	            regs_spattn_data_q;
   wire [0:1]	            regs_power_managed_q;
   wire [0:1]	            regs_pm_thread_stop_q;
   wire [0:1]	            regs_stop_dbg_event_q;
   wire	[0:1]	            regs_stop_dbg_dnh_q;
   wire [0:1]	            regs_tx_stop_q;
   wire [0:1]	            regs_thread_running_q;
   wire [0:1]	            regs_tx_step_q;
   wire [0:1]	            regs_tx_step_done_q;
   wire	[0:1]	            regs_tx_step_req_q;
   //
   wire			    ctrls_pmstate_q_anded;
   wire			    ctrls_pmstate_all_q;
   wire                     ctrls_power_managed_q;
   wire                     ctrls_pm_rvwinkled_q;
   wire [0:7]               ctrls_pmclkctrl_dly_q;
   wire                     ctrls_dis_pwr_sav_q;
   wire                     ctrls_ccflush_dis_q;
   wire                     ctrls_raise_tholds_q;
   //
   wire 	            spr_cesr1_wren;
   wire 	            spr_sramd_wren;
   wire [0:1]               spr_perfmon_alert_q;
   wire [0:1]               spr_cesr1_is0_l2;
   wire [0:1]               spr_cesr1_is1_l2;
   // Latch definitions begin
   wire [0:TRACEOUT_SIZE-1] trace_data_out_d;
   wire [0:TRACEOUT_SIZE-1] trace_data_out_q;
   wire [0:3] 		    coretrace_ctrls_out_d;
   wire [0:3] 		    coretrace_ctrls_out_q;

//=====================================================================
// Trace/Trigger Bus - Sort out input debug signals
//=====================================================================
   // FIR/Error related signals.
   assign fir0_errors_q[0:31]	   = {rg_db_dbg_fir0_err, { 4 {1'b0}} };
   assign fir1_errors_q[0:31]	   = {rg_db_dbg_fir1_err, {12 {1'b0}} };
   assign fir2_errors_q[0:31]	   = {rg_db_dbg_fir2_err, {12 {1'b0}} };
   assign fir_xstop_err_q	   = rg_db_dbg_fir_misc[0:2];
   assign fir_lxstop_err_q	   = rg_db_dbg_fir_misc[3:5];
   assign fir_recov_err_q	   = rg_db_dbg_fir_misc[6:8];
   assign fir0_recov_err_pulse_q   = rg_db_dbg_fir_misc[9];
   assign fir1_recov_err_pulse_q   = rg_db_dbg_fir_misc[10];
   assign fir2_recov_err_pulse_q   = rg_db_dbg_fir_misc[11];
   assign fir_block_ram_mode_q	   = rg_db_dbg_fir_misc[12];
   assign fir_xstop_per_thread_d   = rg_db_dbg_fir_misc[13:14];
   // SCOM error; control signals
   assign scmisc_sc_act_d	   = rg_db_dbg_scom[0];
   assign scmisc_sc_req_q	   = rg_db_dbg_scom[1];
   assign scmisc_sc_wr_q	   = rg_db_dbg_scom[2];
   assign scmisc_scaddr_predecode_d = rg_db_dbg_scom[3:8];
   assign scmisc_scaddr_nvld_q     = rg_db_dbg_scom[9];
   assign scmisc_sc_wr_nvld_q	   = rg_db_dbg_scom[10];
   assign scmisc_sc_rd_nvld_q	   = rg_db_dbg_scom[11];
   // RAM control signals
   assign ram_mode_q		   = rg_db_dbg_ram[0];
   assign ram_active_q  	   = rg_db_dbg_ram[1:2];
   assign ram_execute_q 	   = rg_db_dbg_ram[3];
   assign ram_msrovren_q	   = rg_db_dbg_ram[4];
   assign ram_msrovrpr_q	   = rg_db_dbg_ram[5];
   assign ram_msrovrgs_q	   = rg_db_dbg_ram[6];
   assign ram_msrovrde_q	   = rg_db_dbg_ram[7];
   assign ram_unsupported_q	   = rg_db_dbg_ram[8];
   assign ram_instr_overrun_d	   = rg_db_dbg_ram[9];
   assign ram_interrupt_q	   = rg_db_dbg_ram[10];
   assign ram_mode_xstop_d	   = rg_db_dbg_ram[11];
   assign ram_done_q		   = rg_db_dbg_ram[12];
   assign ram_xu_ram_data_val_q    = rg_db_dbg_ram[13];
   assign ram_fu_ram_data_val_q    = rg_db_dbg_ram[14];
   assign ram_lq_ram_data_val_q    = rg_db_dbg_ram[15];
   // THRCTL and misc control signals
   assign regs_xstop_report_ovrid  = rg_db_dbg_thrctls[0];
   assign regs_dis_pwr_savings     = rg_db_dbg_thrctls[1];
   assign regs_dis_overrun_chks    = rg_db_dbg_thrctls[2];
   assign regs_maxRecErrCntrValue  = rg_db_dbg_thrctls[3];
   assign regs_ext_debug_stop_q    = rg_db_dbg_thrctls[4];
   assign regs_spattn_data_q	   = rg_db_dbg_thrctls[5:6];
   assign regs_power_managed_q     = rg_db_dbg_thrctls[7:8];
   assign regs_pm_thread_stop_q    = rg_db_dbg_thrctls[9:10];
   assign regs_stop_dbg_event_q    = rg_db_dbg_thrctls[11:12];
   assign regs_stop_dbg_dnh_q	   = rg_db_dbg_thrctls[13:14];
   assign regs_tx_stop_q	   = rg_db_dbg_thrctls[15:16];
   assign regs_thread_running_q    = rg_db_dbg_thrctls[17:18];
   assign regs_tx_step_q	   = rg_db_dbg_thrctls[19:20];
   assign regs_tx_step_done_q	   = rg_db_dbg_thrctls[21:22];
   assign regs_tx_step_req_q	   = rg_db_dbg_thrctls[23:24];
   // Power Management signals
   assign ctrls_pmstate_q_anded    = ct_db_dbg_ctrls[0];
   assign ctrls_pmstate_all_q	   = ct_db_dbg_ctrls[1];
   assign ctrls_power_managed_q    = ct_db_dbg_ctrls[2];
   assign ctrls_pm_rvwinkled_q     = ct_db_dbg_ctrls[3];
   assign ctrls_pmclkctrl_dly_q    = ct_db_dbg_ctrls[4:11];
   assign ctrls_dis_pwr_sav_q	   = ct_db_dbg_ctrls[12];
   assign ctrls_ccflush_dis_q	   = ct_db_dbg_ctrls[13];
   assign ctrls_raise_tholds_q     = ct_db_dbg_ctrls[14];
   // SPRs signals
   assign spr_cesr1_wren	   = rg_db_dbg_spr[0];
   assign spr_sramd_wren	   = rg_db_dbg_spr[1];
   assign spr_perfmon_alert_q	   = rg_db_dbg_spr[2:3];
   assign spr_cesr1_is0_l2	   = rg_db_dbg_spr[4:5];
   assign spr_cesr1_is1_l2	   = rg_db_dbg_spr[6:7];


//=====================================================================
// Trace/Trigger Bus - Form trace bus groups from input debug signals
//=====================================================================
// FIR0[32:59] errors not connected: max_recov_err_cntr_value (32), spare (59)
// FIR1[32:51] errors not connected: wdt_reset (45), debug_event (46), spare (47:51)
// FIR2[32:51] errors not connected: wdt_reset (45), debug_event (46), spare (47:51)

   assign debug_group_0[0:TRACEOUT_SIZE-1] = { fir0_errors_q[0:31] };						//  0:31

   assign debug_group_1[0:TRACEOUT_SIZE-1] = { fir1_errors_q[0:31] };						//  0:31

   assign debug_group_2[0:TRACEOUT_SIZE-1] = { fir2_errors_q[0:31] };						//  0:31


   assign debug_group_3[0:TRACEOUT_SIZE-1] = {
   	    fir_recov_err_q[0:2], fir_xstop_err_q[0:2], fir_lxstop_err_q[0:2], fir_xstop_per_thread_q[0:1], 	//  0:15
	    fir_block_ram_mode_q, fir0_recov_err_pulse_q, fir1_recov_err_pulse_q, fir2_recov_err_pulse_q,
   	    scmisc_sc_act_q, scmisc_sc_req_q, scmisc_sc_wr_q, scmisc_scaddr_nvld_q,  				// 16:31
	    scmisc_sc_wr_nvld_q, scmisc_sc_rd_nvld_q, scmisc_scaddr_predecode_q[0:5], 5'b00000
	  };

   assign debug_group_4[0:TRACEOUT_SIZE-1] = {
   	    regs_maxRecErrCntrValue,    regs_xstop_report_ovrid,    regs_spattn_data_q[0:1],			//  0:15
	    regs_ext_debug_stop_q,      regs_stop_dbg_event_q[0:1], regs_stop_dbg_dnh_q[0:1],
	    regs_pm_thread_stop_q[0:1], regs_thread_running_q[0:1], regs_power_managed_q[0:1],
	    regs_dis_pwr_savings,
	    regs_tx_stop_q[0:1],  regs_tx_step_q[0:1], regs_tx_step_done_q[0:1], regs_tx_step_req_q[0:1], 	// 16:31
	    spr_perfmon_alert_q[0:1], spr_cesr1_is0_l2[0:1], spr_cesr1_is1_l2[0:1],
	    spr_sramd_wren, spr_cesr1_wren
          };

   assign debug_group_5[0:TRACEOUT_SIZE-1] = {
    	    ctrls_pmstate_q_anded, ctrls_pmstate_all_q, ctrls_power_managed_q, ctrls_pm_rvwinkled_q, 		//  0:15
            ctrls_pmclkctrl_dly_q[0:7], ctrls_dis_pwr_sav_q, ctrls_ccflush_dis_q, ctrls_raise_tholds_q,
	    regs_dis_overrun_chks,
   	    ram_mode_q, ram_active_q[0:1], ram_execute_q, ram_done_q, ram_xu_ram_data_val_q, 			// 16:31
	    ram_fu_ram_data_val_q, ram_lq_ram_data_val_q, ram_msrovren_q, ram_msrovrpr_q, ram_msrovrgs_q,
	    ram_msrovrde_q, ram_unsupported_q, ram_instr_overrun_q, ram_interrupt_q, ram_mode_xstop_q
          };

   assign debug_group_6[0:TRACEOUT_SIZE-1] = { {32 {1'b0}} };

   assign debug_group_7[0:TRACEOUT_SIZE-1] = { {32 {1'b0}} };


//=====================================================================
// Trace Bus Mux
//=====================================================================
   tri_debug_mux8  debug_mux(
      .select_bits(rg_db_debug_mux_ctrls),
      .dbg_group0(debug_group_0),
      .dbg_group1(debug_group_1),
      .dbg_group2(debug_group_2),
      .dbg_group3(debug_group_3),
      .dbg_group4(debug_group_4),
      .dbg_group5(debug_group_5),
      .dbg_group6(debug_group_6),
      .dbg_group7(debug_group_7),
      .trace_data_in(debug_bus_in),
      .trace_data_out(trace_data_out_d),
      .coretrace_ctrls_in(coretrace_ctrls_in),
      .coretrace_ctrls_out(coretrace_ctrls_out_d)
   );

//=====================================================================
// Outputs
//=====================================================================
   assign debug_bus_out = trace_data_out_q;

   assign coretrace_ctrls_out = coretrace_ctrls_out_q;

//=====================================================================
// Latches
//=====================================================================
   // func ring registers start
   tri_rlmreg_p #(.WIDTH(RAMCTRL_SIZE), .INIT(0)) ramctrl(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(rg_db_trace_bus_enable),
      .thold_b(pc_pc_func_slp_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[RAMCTRL_OFFSET:RAMCTRL_OFFSET + RAMCTRL_SIZE - 1]),
      .scout(func_sov[RAMCTRL_OFFSET:RAMCTRL_OFFSET + RAMCTRL_SIZE - 1]),
      .din( {ram_instr_overrun_d, ram_mode_xstop_d}),
      .dout({ram_instr_overrun_q, ram_mode_xstop_q})
   );

   tri_rlmreg_p #(.WIDTH(SCMISC_SIZE), .INIT(0)) scmisc(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(rg_db_trace_bus_enable),
      .thold_b(pc_pc_func_slp_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[SCMISC_OFFSET:SCMISC_OFFSET + SCMISC_SIZE - 1]),
      .scout(func_sov[SCMISC_OFFSET:SCMISC_OFFSET + SCMISC_SIZE - 1]),
      .din( {scmisc_sc_act_d, scmisc_scaddr_predecode_d}),
      .dout({scmisc_sc_act_q, scmisc_scaddr_predecode_q})
   );

   tri_rlmreg_p #(.WIDTH(FIRMISC_SIZE), .INIT(0)) firmisc(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(rg_db_trace_bus_enable),
      .thold_b(pc_pc_func_slp_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[FIRMISC_OFFSET:FIRMISC_OFFSET + FIRMISC_SIZE - 1]),
      .scout(func_sov[FIRMISC_OFFSET:FIRMISC_OFFSET + FIRMISC_SIZE - 1]),
      .din( fir_xstop_per_thread_d),
      .dout(fir_xstop_per_thread_q)
   );

   tri_rlmreg_p #(.WIDTH(TRACEOUT_SIZE), .INIT(0)) traceout(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(rg_db_trace_bus_enable),
      .thold_b(pc_pc_func_slp_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[TRACEOUT_OFFSET:TRACEOUT_OFFSET + TRACEOUT_SIZE - 1]),
      .scout(func_sov[TRACEOUT_OFFSET:TRACEOUT_OFFSET + TRACEOUT_SIZE - 1]),
      .din( trace_data_out_d),
      .dout(trace_data_out_q)
   );

   tri_rlmreg_p #(.WIDTH(CORETRACE_SIZE), .INIT(0)) coretrace(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(rg_db_trace_bus_enable),
      .thold_b(pc_pc_func_slp_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_func),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[CORETRACE_OFFSET:CORETRACE_OFFSET + CORETRACE_SIZE - 1]),
      .scout(func_sov[CORETRACE_OFFSET:CORETRACE_OFFSET + CORETRACE_SIZE - 1]),
      .din( coretrace_ctrls_out_d),
      .dout(coretrace_ctrls_out_q)
   );
   // func ring registers end

//=====================================================================
// Thold/SG Staging
//=====================================================================
   // func lcbor
   tri_lcbor  lcbor_func0(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(pc_pc_func_slp_sl_thold_0),
      .sg(pc_pc_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(force_func),
      .thold_b(pc_pc_func_slp_sl_thold_0_b)
   );

//=====================================================================
// Scan Connections
//=====================================================================
   // Func ring
   assign func_siv[0:FUNC_RIGHT] = {func_scan_in, func_sov[0:FUNC_RIGHT - 1]};
   assign func_scan_out = func_sov[FUNC_RIGHT] & scan_dis_dc_b;


endmodule
