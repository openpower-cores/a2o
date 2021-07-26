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
// This is the ENTITY for rv_perv
//
// *********************************************************************

module rv_perv(		// 0 = ibm umbra, 1 = xilinx, 2 = ibm mpg
`include "tri_a2o.vh"

   inout        vdd,
   inout        gnd,
   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) // nclk
   input [0:`NCLK_WIDTH-1] nclk,

   input 		 rp_rv_ccflush_dc,
   input 		 rp_rv_func_sl_thold_3,
   input 		 rp_rv_gptr_sl_thold_3,
   input 		 rp_rv_sg_3,
   input 		 rp_rv_fce_3,
   input 		 an_ac_scan_diag_dc,
   input 		 an_ac_scan_dis_dc_b,

   input                 d_mode,

   output 		 func_sl_thold_1,
   output 		 fce_1,
   output 		 sg_1,

   output 		 clkoff_dc_b,
   output 		 act_dis,
   output [0:9] 	 delay_lclkr_dc,
   output [0:9] 	 mpw1_dc_b,
   output 		 mpw2_dc_b,
   input 		 gptr_scan_in,
   output 		 gptr_scan_out,
   input 		 scan_in,
   output 		 scan_out,

   //------------------------------------------------------------------------------------------------------------
   // Debug and Perf
   //------------------------------------------------------------------------------------------------------------
   input [0:8*`THREADS-1]                        fx0_rvs_perf_bus,
   input [0:31]                                  fx0_rvs_dbg_bus,
   input [0:8*`THREADS-1]                        fx1_rvs_perf_bus,
   input [0:31]                                  fx1_rvs_dbg_bus,
   input [0:8*`THREADS-1]                        lq_rvs_perf_bus,
   input [0:31]                                  lq_rvs_dbg_bus,
   input [0:8*`THREADS-1]                        axu0_rvs_perf_bus,
   input [0:31]                                  axu0_rvs_dbg_bus,

   input [0:`THREADS-1]                          spr_msr_gs,
   input [0:`THREADS-1]                          spr_msr_pr,

   input 		                         pc_rv_trace_bus_enable,
   input [0:10]  				 pc_rv_debug_mux_ctrls,
   input                                         pc_rv_event_bus_enable,
   input [0:2] 				         pc_rv_event_count_mode,
   input [0:39]                                  pc_rv_event_mux_ctrls,
   input [0:4*`THREADS-1]                         rv_event_bus_in,
   output [0:4*`THREADS-1]                        rv_event_bus_out,
   output [0:31]             	                 debug_bus_out,
   input  [0:31]             	                 debug_bus_in,
   input  [0:3]		                         coretrace_ctrls_in,
   output [0:3]		    	                 coretrace_ctrls_out
 );

   wire 		 func_sl_thold_2;
   wire 		 gptr_sl_thold_2;

   wire 		 sg_2;
   wire 		 fce_2;

   wire 		 gptr_sl_thold_1;
   wire 		 func_sl_thold_1_int;
   wire 		 sg_1_int;

   wire 		 gptr_sl_thold_0;
   wire 		 func_sl_thold_0;

   wire                  force_t;

   wire 		 sg_0;
   wire 		 gptr_sio;
   wire [0:9] 		 prv_delay_lclkr_dc;
   wire [0:9] 		 prv_mpw1_dc_b;
   wire 		 prv_mpw2_dc_b;
   wire 		 prv_act_dis;
   wire 		 prv_clkoff_dc_b;

   // Debug and Perf
   wire 		 trc_act;
   wire 		 evt_act;
   wire 		 delay_lclkr;
   wire 		 mpw1_b;
   wire 		 mpw2_b;

   wire [0:31] 		 debug_bus_mux;
   wire [0:3] 		 coretrace_ctrls_mux;

   wire [0:10] 		 debug_mux_ctrls;
   wire [0:39] 		 event_mux_ctrls;
   wire [0:2] 		 event_count_mode;
   wire [0:`THREADS-1]   spr_msr_gs_q;
   wire [0:`THREADS-1]   spr_msr_pr_q;
   wire [0:`THREADS-1]   event_en;

   wire [0:32*`THREADS-1]	   event_bus_in;
   wire [0:4*`THREADS-1] 	   event_bus_d;
   wire [0:4*`THREADS-1] 	   event_bus_q;



   wire [0:31] 			   dbg_group0;
   wire [0:31] 			   dbg_group1;
   wire [0:31] 			   dbg_group2;
   wire [0:31] 			   dbg_group3;

   // Unused Signals
   (* analysis_not_referenced="TRUE" *)
   wire 		 act0_dis_dc;
   (* analysis_not_referenced="TRUE" *)
   wire 		 d0_mode_dc;
   (* analysis_not_referenced="TRUE" *)
   wire 		 clkoff1_dc_b;
   (* analysis_not_referenced="TRUE" *)
   wire 		 act1_dis_dc;
   (* analysis_not_referenced="TRUE" *)
   wire 		 d1_mode_dc;
   (* analysis_not_referenced="TRUE" *)
   wire 		 nc_mpw2_dc_b;
   (* analysis_not_referenced="TRUE" *)
   wire 		 unused;


   //------------------------------------------------------------------------------------------------------------
   // Scan Chains
   //------------------------------------------------------------------------------------------------------------
   parameter                      debug_bus_offset = 0 + 0;
   parameter                      debug_mux_offset = debug_bus_offset + 32;
   parameter                      event_bus_offset = debug_mux_offset + 11;
   parameter                      event_count_offset = event_bus_offset + 4*`THREADS;
   parameter                      spr_msr_gs_offset = event_count_offset + 3;
   parameter                      spr_msr_pr_offset = spr_msr_gs_offset + `THREADS;
   parameter                      event_mux_ctrls_offset = spr_msr_pr_offset + `THREADS;
   parameter                      coretrace_ctrls_offset = event_mux_ctrls_offset + 40;

   parameter                      scan_right = coretrace_ctrls_offset + 4;
   wire [0:scan_right-1] 	   siv;
   wire [0:scan_right-1] 	   sov;

   assign unused = an_ac_scan_dis_dc_b ;


   tri_plat #(.WIDTH(4))
   perv_3to2_reg(
		 .vd(vdd),
		 .gd(gnd),
		 .nclk(nclk),
		 .flush(rp_rv_ccflush_dc),
		 .din({rp_rv_func_sl_thold_3, rp_rv_gptr_sl_thold_3, rp_rv_sg_3, rp_rv_fce_3}),
		 .q({func_sl_thold_2, gptr_sl_thold_2, sg_2, fce_2})
		 );


   tri_plat #(.WIDTH(4))
   perv_2to1_reg(
		 .vd(vdd),
		 .gd(gnd),
		 .nclk(nclk),
		 .flush(rp_rv_ccflush_dc),
		 .din({func_sl_thold_2, gptr_sl_thold_2, sg_2, fce_2}),
		 .q({func_sl_thold_1_int, gptr_sl_thold_1, sg_1_int, fce_1})
		 );

   assign func_sl_thold_1 = func_sl_thold_1_int;
   assign sg_1 = sg_1_int;


   tri_plat #(.WIDTH(3))
   perv_1to0_reg(
		 .vd(vdd),
		 .gd(gnd),
		 .nclk(nclk),
		 .flush(rp_rv_ccflush_dc),
		 .din({gptr_sl_thold_1 , func_sl_thold_1_int, sg_1_int}),
		 .q({gptr_sl_thold_0,  func_sl_thold_0, sg_0})
		 );

      tri_lcbor
     perv_lcbor(
		.clkoff_b(prv_clkoff_dc_b),
		.thold(func_sl_thold_0),
		.sg(sg_0),
		.act_dis(prv_act_dis),
		.force_t(force_t),
		.thold_b(func_sl_thold_0_b)
		);

   // Pipeline mapping of mpw1_b and delay_lclkr
   // RF0
   // RF1  0
   // EX1  1
   // EX2  2
   // EX3  3
   // EX4  4
   // EX5  5
   // EX6  6
   // EX7  7


   tri_lcbcntl_mac
   perv_lcbctrl0(
		 .vdd(vdd),
		 .gnd(gnd),
		 .sg(sg_0),
		 .nclk(nclk),
		 .scan_in(gptr_scan_in),
		 .scan_diag_dc(an_ac_scan_diag_dc),
		 .thold(gptr_sl_thold_0),
		 .clkoff_dc_b(prv_clkoff_dc_b),
		 .delay_lclkr_dc(prv_delay_lclkr_dc[0:4]),
		 .act_dis_dc(act0_dis_dc),
		 .d_mode_dc(d0_mode_dc),
		 .mpw1_dc_b(prv_mpw1_dc_b[0:4]),
		 .mpw2_dc_b(prv_mpw2_dc_b),
		 .scan_out(gptr_sio)
		 );


   tri_lcbcntl_mac
   perv_lcbctrl1(
		 .vdd(vdd),
		 .gnd(gnd),
		 .sg(sg_0),
		 .nclk(nclk),
		 .scan_in(gptr_sio),
		 .scan_diag_dc(an_ac_scan_diag_dc),
		 .thold(gptr_sl_thold_0),
		 .clkoff_dc_b(clkoff1_dc_b),
		 .delay_lclkr_dc(prv_delay_lclkr_dc[5:9]),
		 .act_dis_dc(act1_dis_dc),
		 .d_mode_dc(d1_mode_dc),
		 .mpw1_dc_b(prv_mpw1_dc_b[5:9]),
		 .mpw2_dc_b(nc_mpw2_dc_b),
		 .scan_out(gptr_scan_out)
		 );

   //Outputs
   assign delay_lclkr_dc[0:9] = prv_delay_lclkr_dc[0:9];
   assign mpw1_dc_b[0:9] = prv_mpw1_dc_b[0:9];
   assign mpw2_dc_b = prv_mpw2_dc_b;

   //never disable act pins, they are used functionally
   assign prv_act_dis = 1'b0;
   assign act_dis = prv_act_dis;
   assign clkoff_dc_b = prv_clkoff_dc_b;


   //------------------------------------------------------------------------------------------------------------
   // Perf bus
   //------------------------------------------------------------------------------------------------------------

   assign event_en      = (  spr_msr_pr_q  &                   {`THREADS{event_count_mode[0]}}) |  //-- User
                          ((~spr_msr_pr_q) &   spr_msr_gs_q  & {`THREADS{event_count_mode[1]}}) |  //-- Guest Supervisor
                          ((~spr_msr_pr_q) & (~spr_msr_gs_q) & {`THREADS{event_count_mode[2]}});   //-- Hypervisor

   assign event_bus_in[ 0: 7] =  fx0_rvs_perf_bus[0:7] & {8{event_en[0]}};
   assign event_bus_in[ 8:15] =  fx1_rvs_perf_bus[0:7] & {8{event_en[0]}};
   assign event_bus_in[16:23] =   lq_rvs_perf_bus[0:7] & {8{event_en[0]}};
   assign event_bus_in[24:31] = axu0_rvs_perf_bus[0:7] & {8{event_en[0]}};


   tri_event_mux1t #(.EVENTS_IN(32), .EVENTS_OUT(4))
   event_mux0(
	     .vd(vdd),
	     .gd(gnd),
	     .event_bus_in(rv_event_bus_in[0:3]),
	     .event_bus_out(event_bus_d[0:3]),
	     .unit_events_in(event_bus_in[1:31]),
	     .select_bits(event_mux_ctrls[0:19])
	     );

`ifndef THREADS1

   assign event_bus_in[32:39] =  fx0_rvs_perf_bus[8:15] & {8{event_en[1]}};
   assign event_bus_in[40:47] =  fx1_rvs_perf_bus[8:15] & {8{event_en[1]}};
   assign event_bus_in[48:55] =   lq_rvs_perf_bus[8:15] & {8{event_en[1]}};
   assign event_bus_in[56:63] = axu0_rvs_perf_bus[8:15] & {8{event_en[1]}};

   tri_event_mux1t #(.EVENTS_IN(32), .EVENTS_OUT(4))
   event_mux1(
	     .vd(vdd),
	     .gd(gnd),
	     .event_bus_in(rv_event_bus_in[4:7]),
	     .event_bus_out(event_bus_d[4:7]),
	     .unit_events_in(event_bus_in[32:63]),
	     .select_bits(event_mux_ctrls[20:39])
	     );
`endif

   assign rv_event_bus_out = event_bus_q;


   //------------------------------------------------------------------------------------------------------------
   // Debug bus
   //------------------------------------------------------------------------------------------------------------

   assign dbg_group0 =  fx0_rvs_dbg_bus[0:31] ;
   assign dbg_group1 =  fx1_rvs_dbg_bus[0:31] ;
   assign dbg_group2 =   lq_rvs_dbg_bus[0:31] ;
   assign dbg_group3 = axu0_rvs_dbg_bus[0:31] ;

   tri_debug_mux4 #(.DBG_WIDTH(32))
   dbg_mux(
	   .select_bits(debug_mux_ctrls),
	   .trace_data_in(debug_bus_in),
	   .dbg_group0(dbg_group0),
	   .dbg_group1(dbg_group1),
	   .dbg_group2(dbg_group2),
	   .dbg_group3(dbg_group3),
	   .trace_data_out(debug_bus_mux),
	   .coretrace_ctrls_in(coretrace_ctrls_in),
	   .coretrace_ctrls_out(coretrace_ctrls_mux)
	   );


   //------------------------------------------------------------------------------------------------------------
   // Latches
   //------------------------------------------------------------------------------------------------------------
   assign trc_act = pc_rv_trace_bus_enable;
   assign evt_act = pc_rv_event_bus_enable;
   assign delay_lclkr = prv_delay_lclkr_dc[0];
   assign mpw1_b = prv_mpw1_dc_b[0];
   assign mpw2_b = prv_mpw2_dc_b;

   tri_rlmreg_p #(.WIDTH(32), .INIT(0))
   debug_bus_reg(
		.vd(vdd),
		.gd(gnd),
		.nclk(nclk),
		.act(trc_act),
		.thold_b(func_sl_thold_0_b),
		.sg(sg_0),
		.force_t(force_t),
		.delay_lclkr(delay_lclkr),
		.mpw1_b(mpw1_b),
		.mpw2_b(mpw2_b),
		.d_mode(d_mode),
		.scin(siv[debug_bus_offset:debug_bus_offset + 32 - 1]),
		.scout(sov[debug_bus_offset:debug_bus_offset + 32 - 1]),
		.din(debug_bus_mux),
		.dout(debug_bus_out)
		);
   tri_rlmreg_p #(.WIDTH(11), .INIT(0))
   debug_mux_reg(
		.vd(vdd),
		.gd(gnd),
		.nclk(nclk),
		.act(trc_act),
		.thold_b(func_sl_thold_0_b),
		.sg(sg_0),
		.force_t(force_t),
		.delay_lclkr(delay_lclkr),
		.mpw1_b(mpw1_b),
		.mpw2_b(mpw2_b),
		.d_mode(d_mode),
		.scin(siv[debug_mux_offset:debug_mux_offset + 11 - 1]),
		.scout(sov[debug_mux_offset:debug_mux_offset + 11 - 1]),
		.din(pc_rv_debug_mux_ctrls),
		.dout(debug_mux_ctrls)
		);
   tri_rlmreg_p #(.WIDTH(4*`THREADS), .INIT(0))
   event_bus_reg(
		.vd(vdd),
		.gd(gnd),
		.nclk(nclk),
		.act(evt_act),
		.thold_b(func_sl_thold_0_b),
		.sg(sg_0),
		.force_t(force_t),
		.delay_lclkr(delay_lclkr),
		.mpw1_b(mpw1_b),
		.mpw2_b(mpw2_b),
		.d_mode(d_mode),
		.scin(siv[event_bus_offset:event_bus_offset + 4*`THREADS - 1]),
		.scout(sov[event_bus_offset:event_bus_offset + 4*`THREADS - 1]),
		.din(event_bus_d),
		.dout(event_bus_q)
		);
   tri_rlmreg_p #(.WIDTH(3), .INIT(0))
   event_count_reg(
		.vd(vdd),
		.gd(gnd),
		.nclk(nclk),
		.act(evt_act),
		.thold_b(func_sl_thold_0_b),
		.sg(sg_0),
		.force_t(force_t),
		.delay_lclkr(delay_lclkr),
		.mpw1_b(mpw1_b),
		.mpw2_b(mpw2_b),
		.d_mode(d_mode),
		.scin(siv[event_count_offset:event_count_offset + 3 - 1]),
		.scout(sov[event_count_offset:event_count_offset + 3 - 1]),
		.din(pc_rv_event_count_mode),
		.dout(event_count_mode)
		);
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   spr_msr_gs_reg(
		.vd(vdd),
		.gd(gnd),
		.nclk(nclk),
		.act(evt_act),
		.thold_b(func_sl_thold_0_b),
		.sg(sg_0),
		.force_t(force_t),
		.delay_lclkr(delay_lclkr),
		.mpw1_b(mpw1_b),
		.mpw2_b(mpw2_b),
		.d_mode(d_mode),
		.scin(siv[spr_msr_gs_offset:spr_msr_gs_offset + `THREADS - 1]),
		.scout(sov[spr_msr_gs_offset:spr_msr_gs_offset + `THREADS - 1]),
		.din(spr_msr_gs),
		.dout(spr_msr_gs_q)
		);
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   spr_msr_pr_reg(
		.vd(vdd),
		.gd(gnd),
		.nclk(nclk),
		.act(evt_act),
		.thold_b(func_sl_thold_0_b),
		.sg(sg_0),
		.force_t(force_t),
		.delay_lclkr(delay_lclkr),
		.mpw1_b(mpw1_b),
		.mpw2_b(mpw2_b),
		.d_mode(d_mode),
		.scin(siv[spr_msr_pr_offset:spr_msr_pr_offset + `THREADS - 1]),
		.scout(sov[spr_msr_pr_offset:spr_msr_pr_offset + `THREADS - 1]),
		.din(spr_msr_pr),
		.dout(spr_msr_pr_q)
		);
   tri_rlmreg_p #(.WIDTH(40), .INIT(0))
   event_mux_ctrls_reg(
		.vd(vdd),
		.gd(gnd),
		.nclk(nclk),
		.act(evt_act),
		.thold_b(func_sl_thold_0_b),
		.sg(sg_0),
		.force_t(force_t),
		.delay_lclkr(delay_lclkr),
		.mpw1_b(mpw1_b),
		.mpw2_b(mpw2_b),
		.d_mode(d_mode),
		.scin(siv[event_mux_ctrls_offset:event_mux_ctrls_offset + 40 - 1]),
		.scout(sov[event_mux_ctrls_offset:event_mux_ctrls_offset + 40 - 1]),
		.din(pc_rv_event_mux_ctrls),
		.dout(event_mux_ctrls)
		);
   tri_rlmreg_p #(.WIDTH(4), .INIT(0))
   core_trace_ctrls_reg(
		.vd(vdd),
		.gd(gnd),
		.nclk(nclk),
		.act(trc_act),
		.thold_b(func_sl_thold_0_b),
		.sg(sg_0),
		.force_t(force_t),
		.delay_lclkr(delay_lclkr),
		.mpw1_b(mpw1_b),
		.mpw2_b(mpw2_b),
		.d_mode(d_mode),
		.scin(siv[coretrace_ctrls_offset:coretrace_ctrls_offset + 4 - 1]),
		.scout(sov[coretrace_ctrls_offset:coretrace_ctrls_offset + 4 - 1]),
		.din(coretrace_ctrls_mux),
		.dout(coretrace_ctrls_out)
		);




   //------------------------------------------------------------------------------------------------------------
   // Scan Connections
   //------------------------------------------------------------------------------------------------------------

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];


endmodule
