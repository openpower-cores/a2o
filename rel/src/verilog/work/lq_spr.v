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


`include "tri_a2o.vh"

module lq_spr
#(
   parameter                  hvmode = 1,
   parameter                  a2mode = 1
)(

   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)
   input [0:`NCLK_WIDTH-1]    nclk,

   input                      d_mode_dc,
   input                      delay_lclkr_dc,
   input                      mpw1_dc_b,
   input                      mpw2_dc_b,

   input                      ccfg_sl_force,
   input                      ccfg_sl_thold_0_b,
   input                      func_sl_force,
   input                      func_sl_thold_0_b,
   input                      func_nsl_force,
   input                      func_nsl_thold_0_b,
   input                      sg_0,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                      scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                     scan_out,

   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                      ccfg_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                     ccfg_scan_out,

   input [0:`THREADS-1]       flush,
   input [0:`THREADS-1]       ex1_valid,
   input                      ex3_data_val,
   input [64-`GPR_WIDTH:63]      ex3_eff_addr,

   // SlowSPR Interface
   input                      slowspr_val_in,
   input                      slowspr_rw_in,
   input [0:1]                slowspr_etid_in,
   input [0:9]                slowspr_addr_in,
   input [64-`GPR_WIDTH:63]      slowspr_data_in,
   input                      slowspr_done_in,

   output                     slowspr_val_out,
   output                     slowspr_rw_out,
   output [0:1]               slowspr_etid_out,
   output [0:9]               slowspr_addr_out,
   output [64-`GPR_WIDTH:63]     slowspr_data_out,
   output                     slowspr_done_out,

   // DAC
   input                      ex2_is_any_load_dac,
   input                      ex2_is_any_store_dac,

   output                     spr_dcc_ex4_dvc1_en,
   output                     spr_dcc_ex4_dvc2_en,
   output                     spr_dcc_ex4_dacrw1_cmpr,
   output                     spr_dcc_ex4_dacrw2_cmpr,
   output                     spr_dcc_ex4_dacrw3_cmpr,
   output                     spr_dcc_ex4_dacrw4_cmpr,

   // SPRs
   input [0:`THREADS-1]       spr_msr_pr,
   input [0:`THREADS-1]       spr_msr_gs,
   input [0:`THREADS-1]       spr_msr_ds,
   input [0:2*`THREADS-1]     spr_dbcr0_dac1,
   input [0:2*`THREADS-1]     spr_dbcr0_dac2,
   input [0:2*`THREADS-1]     spr_dbcr0_dac3,
   input [0:2*`THREADS-1]     spr_dbcr0_dac4,

   output                     spr_xudbg0_exec,
   output [0:`THREADS-1]      spr_xudbg0_tid,
   input                      spr_xudbg0_done,
   input                      spr_xudbg1_valid,
   input [0:3]                spr_xudbg1_watch,
   input [0:3]                spr_xudbg1_parity,
   input [0:6]                spr_xudbg1_lru,
   input                      spr_xudbg1_lock,
   input [33:63]              spr_xudbg2_tag,
   output [0:8*`THREADS-1]    spr_dbcr2_dvc1be,
   output [0:8*`THREADS-1]    spr_dbcr2_dvc2be,
   output [0:2*`THREADS-1]    spr_dbcr2_dvc1m,
   output [0:2*`THREADS-1]    spr_dbcr2_dvc2m,
   output [0:`THREADS-1]      spr_epsc_wr,
   output [0:`THREADS-1]      spr_eplc_wr,
   output [0:31]              spr_pesr,

	output [0:`GPR_WIDTH-1]             spr_dvc1,
	output [0:`GPR_WIDTH-1]             spr_dvc2,
	output [0:5]                        spr_lesr1_muxseleb0,
	output [0:5]                        spr_lesr1_muxseleb1,
	output [0:5]                        spr_lesr1_muxseleb2,
	output [0:5]                        spr_lesr1_muxseleb3,
	output [0:5]                        spr_lesr2_muxseleb4,
	output [0:5]                        spr_lesr2_muxseleb5,
	output [0:5]                        spr_lesr2_muxseleb6,
	output [0:5]                        spr_lesr2_muxseleb7,
	output [0:2]                        spr_lsucr0_lca,
	output [0:2]                        spr_lsucr0_sca,
	output                              spr_lsucr0_lge,
	output                              spr_lsucr0_b2b,
	output                              spr_lsucr0_dfwd,
	output                              spr_lsucr0_clchk,
	output                              spr_lsucr0_ford,
	output [0:7]                        spr_xucr2_rmt3,
	output [0:7]                        spr_xucr2_rmt2,
	output [0:7]                        spr_xucr2_rmt1,
	output [0:7]                        spr_xucr2_rmt0,
	output [0:2]                        spr_xudbg0_way,
	output [0:5]                        spr_xudbg0_row,
	output [0:32*`THREADS-1]            spr_acop_ct,
	output [0:`THREADS-1]               spr_dbcr3_ivc,
	output [0:`THREADS-1]               spr_dscr_lsd,
	output [0:`THREADS-1]               spr_dscr_snse,
	output [0:`THREADS-1]               spr_dscr_sse,
	output [0:3*`THREADS-1]             spr_dscr_dpfd,
	output [0:`THREADS-1]               spr_eplc_epr,
	output [0:`THREADS-1]               spr_eplc_eas,
	output [0:`THREADS-1]               spr_eplc_egs,
	output [0:8*`THREADS-1]             spr_eplc_elpid,
	output [0:14*`THREADS-1]            spr_eplc_epid,
	output [0:`THREADS-1]               spr_epsc_epr,
	output [0:`THREADS-1]               spr_epsc_eas,
	output [0:`THREADS-1]               spr_epsc_egs,
	output [0:8*`THREADS-1]             spr_epsc_elpid,
	output [0:14*`THREADS-1]            spr_epsc_epid,
	output [0:32*`THREADS-1]            spr_hacop_ct,

   // Power
   inout                      vdd,
   inout                      gnd
);


localparam                 tiup = 1'b1;
wire                       slowspr_val_in_q;		   // input=>slowspr_val_in      ,act=>tiup              ,scan=>Y ,sleep=>N, ring=>func
wire                       slowspr_rw_in_q;		   // input=>slowspr_rw_in       ,act=>slowspr_act_in    ,scan=>Y ,sleep=>N, ring=>func
wire [0:1]                 slowspr_etid_in_q;		// input=>slowspr_etid_in     ,act=>slowspr_act_in    ,scan=>Y ,sleep=>N, ring=>func
wire [0:9]                 slowspr_addr_in_q;		// input=>slowspr_addr_in     ,act=>slowspr_act_in    ,scan=>Y ,sleep=>N, ring=>func
wire [64-`GPR_WIDTH:63]       slowspr_data_in_q;		// input=>slowspr_data_in     ,act=>slowspr_act_in    ,scan=>Y ,sleep=>N, ring=>func
wire                       slowspr_done_in_q;		// input=>slowspr_done_in     ,act=>tiup              ,scan=>Y ,sleep=>N, ring=>func
wire                       slowspr_val_out_q;		// input=>slowspr_val_in_q    ,act=>tiup              ,scan=>Y ,sleep=>N, ring=>func
wire                       slowspr_rw_out_q;		   // input=>slowspr_rw_in_q     ,act=>slowspr_val_in_q  ,scan=>Y ,sleep=>N, ring=>func
wire [0:1]                 slowspr_etid_out_q;		// input=>slowspr_etid_in_q   ,act=>slowspr_val_in_q  ,scan=>Y ,sleep=>N, ring=>func
wire [0:9]                 slowspr_addr_out_q;		// input=>slowspr_addr_in_q   ,act=>slowspr_val_in_q  ,scan=>Y ,sleep=>N, ring=>func
wire [64-`GPR_WIDTH:63]       slowspr_data_out_q;		// input=>slowspr_data_out_d  ,act=>slowspr_val_in_q  ,scan=>Y ,sleep=>N, ring=>func
wire [64-`GPR_WIDTH:63]       slowspr_data_out_d;
wire                       slowspr_done_out_q;		// input=>slowspr_done_out_d  ,act=>tiup              ,scan=>Y ,sleep=>N, ring=>func
wire                       slowspr_done_out_d;
wire [0:`THREADS-1]        flush_q;		            // input=>flush               ,act=>tiup              ,scan=>Y ,sleep=>N, ring=>func

// Scanchain
parameter                  slowspr_val_in_offset = `THREADS + 1;
parameter                  slowspr_rw_in_offset = slowspr_val_in_offset + 1;
parameter                  slowspr_etid_in_offset = slowspr_rw_in_offset + 1;
parameter                  slowspr_addr_in_offset = slowspr_etid_in_offset + 2;
parameter                  slowspr_data_in_offset = slowspr_addr_in_offset + 10;
parameter                  slowspr_done_in_offset = slowspr_data_in_offset + `GPR_WIDTH;
parameter                  slowspr_val_out_offset = slowspr_done_in_offset + 1;
parameter                  slowspr_rw_out_offset = slowspr_val_out_offset + 1;
parameter                  slowspr_etid_out_offset = slowspr_rw_out_offset + 1;
parameter                  slowspr_addr_out_offset = slowspr_etid_out_offset + 2;
parameter                  slowspr_data_out_offset = slowspr_addr_out_offset + 10;
parameter                  slowspr_done_out_offset = slowspr_data_out_offset + `GPR_WIDTH;
parameter                  flush_offset = slowspr_done_out_offset + 1;
parameter                  scan_right = flush_offset + `THREADS;
wire [0:scan_right-1]      siv;
wire [0:scan_right-1]      sov;
// Signals
wire                       slowspr_act_in;
wire [0:`THREADS-1]        slowspr_val_tid;
wire [0:3]                 slowspr_tid;
wire [0:3]                 slowspr_tid_in;
wire [0:2*`THREADS-1]      tspr_cspr_dbcr2_dac1us;
wire [0:2*`THREADS-1]      tspr_cspr_dbcr2_dac1er;
wire [0:2*`THREADS-1]      tspr_cspr_dbcr2_dac2us;
wire [0:2*`THREADS-1]      tspr_cspr_dbcr2_dac2er;
wire [0:2*`THREADS-1]      tspr_cspr_dbcr3_dac3us;
wire [0:2*`THREADS-1]      tspr_cspr_dbcr3_dac3er;
wire [0:2*`THREADS-1]      tspr_cspr_dbcr3_dac4us;
wire [0:2*`THREADS-1]      tspr_cspr_dbcr3_dac4er;
wire [0:`THREADS-1]        tspr_cspr_dbcr2_dac12m;
wire [0:`THREADS-1]        tspr_cspr_dbcr3_dac34m;
wire [0:2*`THREADS-1]      tspr_cspr_dbcr2_dvc1m;
wire [0:2*`THREADS-1]      tspr_cspr_dbcr2_dvc2m;
wire [0:8*`THREADS-1]      tspr_cspr_dbcr2_dvc1be;
wire [0:8*`THREADS-1]      tspr_cspr_dbcr2_dvc2be;
wire [0:`THREADS-1]        tspr_done;
wire [0:`THREADS-1]        tspr_sel;
wire [0:`GPR_WIDTH-1]         tspr_rt[0:`THREADS-1];
wire                       cspr_done;
wire [64-`GPR_WIDTH:63]       cspr_rt;
wire [0:`THREADS-1]        cspr_tspr_msr_pr;
wire [0:`THREADS-1]        cspr_tspr_msr_gs;
wire                       slowspr_val_in_gate;
wire                       slowspr_val_in_stg;
reg [0:`GPR_WIDTH-1]          tspr_tid_mux;

assign slowspr_tid = (slowspr_etid_in_q == 2'b00) ? 4'b1000 :
                     (slowspr_etid_in_q == 2'b01) ? 4'b0100 :
                     (slowspr_etid_in_q == 2'b10) ? 4'b0010 :
                     (slowspr_etid_in_q == 2'b11) ? 4'b0001 :
                     4'b0000;

assign slowspr_tid_in = (slowspr_etid_in == 2'b00) ? 4'b1000 :
                        (slowspr_etid_in == 2'b01) ? 4'b0100 :
                        (slowspr_etid_in == 2'b10) ? 4'b0010 :
                        (slowspr_etid_in == 2'b11) ? 4'b0001 :
                        4'b0000;

assign slowspr_val_tid = slowspr_tid[0:`THREADS-1] & {`THREADS{slowspr_val_in_q}};
assign tspr_sel = tspr_done & slowspr_val_tid;
assign slowspr_val_in_gate = slowspr_val_in & ~(|(slowspr_tid_in[0:`THREADS - 1] & flush_q));
assign slowspr_val_in_stg = slowspr_val_in_q & ~(|(slowspr_tid[0:`THREADS - 1] & flush_q));
assign slowspr_act_in = slowspr_val_in;
assign slowspr_val_out = slowspr_val_out_q;
assign slowspr_rw_out = slowspr_rw_out_q;
assign slowspr_etid_out = slowspr_etid_out_q;
assign slowspr_addr_out = slowspr_addr_out_q;
assign slowspr_data_out = slowspr_data_out_q;
assign slowspr_done_out = slowspr_done_out_q;
assign spr_xudbg0_tid   = slowspr_tid[0:`THREADS-1];

always @* begin : tsprMux
   reg [0:`GPR_WIDTH-1]       tspr;
   integer                 tid;
   tspr = {`GPR_WIDTH{1'b0}};
   for (tid=0; tid<`THREADS; tid=tid+1) begin
      tspr = (tspr_rt[tid] & {`GPR_WIDTH{tspr_sel[tid]}}) | tspr;
   end
   tspr_tid_mux <= tspr;
end

assign slowspr_done_out_d = slowspr_done_in_q | |(tspr_done) | cspr_done;
assign slowspr_data_out_d = slowspr_data_in_q | tspr_tid_mux | (cspr_rt & {`GPR_WIDTH{cspr_done}});

assign spr_dbcr2_dvc1be = tspr_cspr_dbcr2_dvc1be;
assign spr_dbcr2_dvc2be = tspr_cspr_dbcr2_dvc2be;
assign spr_dbcr2_dvc1m = tspr_cspr_dbcr2_dvc1m;
assign spr_dbcr2_dvc2m = tspr_cspr_dbcr2_dvc2m;

lq_spr_cspr #(.hvmode(hvmode), .a2mode(a2mode)) lq_spr_cspr(
   .nclk(nclk),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc),
   .mpw1_dc_b(mpw1_dc_b),
   .mpw2_dc_b(mpw2_dc_b),
   .ccfg_sl_force(ccfg_sl_force),
   .ccfg_sl_thold_0_b(ccfg_sl_thold_0_b),
   .func_sl_force(func_sl_force),
   .func_sl_thold_0_b(func_sl_thold_0_b),
   .func_nsl_force(func_nsl_force),
   .func_nsl_thold_0_b(func_nsl_thold_0_b),
   .sg_0(sg_0),
   .scan_in(siv[`THREADS]),
   .scan_out(sov[`THREADS]),
   .ccfg_scan_in(ccfg_scan_in),
   .ccfg_scan_out(ccfg_scan_out),

   .flush(flush_q),
   .ex1_valid(ex1_valid),
   .ex3_data_val(ex3_data_val),
   .ex3_eff_addr(ex3_eff_addr),
   // SlowSPR Interface
   .slowspr_val_in(slowspr_val_in_q),
   .slowspr_rw_in(slowspr_rw_in_q),
   .slowspr_addr_in(slowspr_addr_in_q),
   .slowspr_data_in(slowspr_data_in_q),
   .cspr_done(cspr_done),
   .cspr_rt(cspr_rt),
   // DAC
   .ex2_is_any_load_dac(ex2_is_any_load_dac),
   .ex2_is_any_store_dac(ex2_is_any_store_dac),
   .spr_dcc_ex4_dvc1_en(spr_dcc_ex4_dvc1_en),
   .spr_dcc_ex4_dvc2_en(spr_dcc_ex4_dvc2_en),
   .spr_dcc_ex4_dacrw1_cmpr(spr_dcc_ex4_dacrw1_cmpr),
   .spr_dcc_ex4_dacrw2_cmpr(spr_dcc_ex4_dacrw2_cmpr),
   .spr_dcc_ex4_dacrw3_cmpr(spr_dcc_ex4_dacrw3_cmpr),
   .spr_dcc_ex4_dacrw4_cmpr(spr_dcc_ex4_dacrw4_cmpr),

   // SPRs
   .spr_msr_pr(spr_msr_pr),
   .spr_msr_gs(spr_msr_gs),
   .spr_msr_ds(spr_msr_ds),
   .spr_dbcr0_dac1(spr_dbcr0_dac1),
   .spr_dbcr0_dac2(spr_dbcr0_dac2),
   .spr_dbcr0_dac3(spr_dbcr0_dac3),
   .spr_dbcr0_dac4(spr_dbcr0_dac4),
   .spr_xudbg0_exec(spr_xudbg0_exec),
   .spr_xudbg0_done(spr_xudbg0_done),
   .spr_xudbg1_valid(spr_xudbg1_valid),
   .spr_xudbg1_watch(spr_xudbg1_watch),
   .spr_xudbg1_parity(spr_xudbg1_parity),
   .spr_xudbg1_lru(spr_xudbg1_lru),
   .spr_xudbg1_lock(spr_xudbg1_lock),
   .spr_xudbg2_tag(spr_xudbg2_tag),
   .spr_pesr(spr_pesr),
   .cspr_tspr_msr_pr(cspr_tspr_msr_pr),
   .cspr_tspr_msr_gs(cspr_tspr_msr_gs),
   .tspr_cspr_dbcr2_dac1us(tspr_cspr_dbcr2_dac1us),
   .tspr_cspr_dbcr2_dac1er(tspr_cspr_dbcr2_dac1er),
   .tspr_cspr_dbcr2_dac2us(tspr_cspr_dbcr2_dac2us),
   .tspr_cspr_dbcr2_dac2er(tspr_cspr_dbcr2_dac2er),
   .tspr_cspr_dbcr3_dac3us(tspr_cspr_dbcr3_dac3us),
   .tspr_cspr_dbcr3_dac3er(tspr_cspr_dbcr3_dac3er),
   .tspr_cspr_dbcr3_dac4us(tspr_cspr_dbcr3_dac4us),
   .tspr_cspr_dbcr3_dac4er(tspr_cspr_dbcr3_dac4er),
   .tspr_cspr_dbcr2_dac12m(tspr_cspr_dbcr2_dac12m),
   .tspr_cspr_dbcr3_dac34m(tspr_cspr_dbcr3_dac34m),
   .tspr_cspr_dbcr2_dvc1m(tspr_cspr_dbcr2_dvc1m),
   .tspr_cspr_dbcr2_dvc2m(tspr_cspr_dbcr2_dvc2m),
   .tspr_cspr_dbcr2_dvc1be(tspr_cspr_dbcr2_dvc1be),
   .tspr_cspr_dbcr2_dvc2be(tspr_cspr_dbcr2_dvc2be),

		.spr_dvc1(spr_dvc1),
		.spr_dvc2(spr_dvc2),
		.spr_lesr1_muxseleb0(spr_lesr1_muxseleb0),
		.spr_lesr1_muxseleb1(spr_lesr1_muxseleb1),
		.spr_lesr1_muxseleb2(spr_lesr1_muxseleb2),
		.spr_lesr1_muxseleb3(spr_lesr1_muxseleb3),
		.spr_lesr2_muxseleb4(spr_lesr2_muxseleb4),
		.spr_lesr2_muxseleb5(spr_lesr2_muxseleb5),
		.spr_lesr2_muxseleb6(spr_lesr2_muxseleb6),
		.spr_lesr2_muxseleb7(spr_lesr2_muxseleb7),
		.spr_lsucr0_lca(spr_lsucr0_lca),
		.spr_lsucr0_sca(spr_lsucr0_sca),
		.spr_lsucr0_lge(spr_lsucr0_lge),
		.spr_lsucr0_b2b(spr_lsucr0_b2b),
		.spr_lsucr0_dfwd(spr_lsucr0_dfwd),
		.spr_lsucr0_clchk(spr_lsucr0_clchk),
		.spr_lsucr0_ford(spr_lsucr0_ford),
		.spr_xucr2_rmt3(spr_xucr2_rmt3),
		.spr_xucr2_rmt2(spr_xucr2_rmt2),
		.spr_xucr2_rmt1(spr_xucr2_rmt1),
		.spr_xucr2_rmt0(spr_xucr2_rmt0),
		.spr_xudbg0_way(spr_xudbg0_way),
		.spr_xudbg0_row(spr_xudbg0_row),
   // Power
   .vdd(vdd),
   .gnd(gnd)
);

generate begin : thread
      genvar                     t;
      for (t=0; t<`THREADS; t=t+1) begin : thread
         lq_spr_tspr #(.hvmode(hvmode), .a2mode(a2mode)) lq_spr_tspr(
            .nclk(nclk),
            .d_mode_dc(d_mode_dc),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_force(func_sl_force),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(siv[t]),
            .scan_out(sov[t]),
            // SlowSPR Interface
            .slowspr_val_in(slowspr_val_tid[t]),
            .slowspr_rw_in(slowspr_rw_in_q),
            .slowspr_addr_in(slowspr_addr_in_q),
            .slowspr_data_in(slowspr_data_in_q),
            .tspr_done(tspr_done[t]),
            .tspr_rt(tspr_rt[t]),
            // SPRs
            .cspr_tspr_msr_pr(cspr_tspr_msr_pr[t]),
            .cspr_tspr_msr_gs(cspr_tspr_msr_gs[t]),
            .tspr_cspr_dbcr2_dac1us(tspr_cspr_dbcr2_dac1us[t*2:2*(t+1)-1]),
            .tspr_cspr_dbcr2_dac1er(tspr_cspr_dbcr2_dac1er[t*2:2*(t+1)-1]),
            .tspr_cspr_dbcr2_dac2us(tspr_cspr_dbcr2_dac2us[t*2:2*(t+1)-1]),
            .tspr_cspr_dbcr2_dac2er(tspr_cspr_dbcr2_dac2er[t*2:2*(t+1)-1]),
            .tspr_cspr_dbcr3_dac3us(tspr_cspr_dbcr3_dac3us[t*2:2*(t+1)-1]),
            .tspr_cspr_dbcr3_dac3er(tspr_cspr_dbcr3_dac3er[t*2:2*(t+1)-1]),
            .tspr_cspr_dbcr3_dac4us(tspr_cspr_dbcr3_dac4us[t*2:2*(t+1)-1]),
            .tspr_cspr_dbcr3_dac4er(tspr_cspr_dbcr3_dac4er[t*2:2*(t+1)-1]),
            .tspr_cspr_dbcr2_dac12m(tspr_cspr_dbcr2_dac12m[t]),
            .tspr_cspr_dbcr3_dac34m(tspr_cspr_dbcr3_dac34m[t]),
            .tspr_cspr_dbcr2_dvc1m(tspr_cspr_dbcr2_dvc1m[t*2:2*(t+1)-1]),
            .tspr_cspr_dbcr2_dvc2m(tspr_cspr_dbcr2_dvc2m[t*2:2*(t+1)-1]),
            .tspr_cspr_dbcr2_dvc1be(tspr_cspr_dbcr2_dvc1be[t*8:8*(t+1)-1]),
            .tspr_cspr_dbcr2_dvc2be(tspr_cspr_dbcr2_dvc2be[t*8:8*(t+1)-1]),
            .spr_epsc_wr(spr_epsc_wr[t]),
            .spr_eplc_wr(spr_eplc_wr[t]),
		.spr_acop_ct(spr_acop_ct[32*t : 32*(t+1)-1]),
		.spr_dbcr3_ivc(spr_dbcr3_ivc[t]),
		.spr_dscr_lsd(spr_dscr_lsd[t]),
		.spr_dscr_snse(spr_dscr_snse[t]),
		.spr_dscr_sse(spr_dscr_sse[t]),
		.spr_dscr_dpfd(spr_dscr_dpfd[3*t : 3*(t+1)-1]),
		.spr_eplc_epr(spr_eplc_epr[t]),
		.spr_eplc_eas(spr_eplc_eas[t]),
		.spr_eplc_egs(spr_eplc_egs[t]),
		.spr_eplc_elpid(spr_eplc_elpid[8*t : 8*(t+1)-1]),
		.spr_eplc_epid(spr_eplc_epid[14*t : 14*(t+1)-1]),
		.spr_epsc_epr(spr_epsc_epr[t]),
		.spr_epsc_eas(spr_epsc_eas[t]),
		.spr_epsc_egs(spr_epsc_egs[t]),
		.spr_epsc_elpid(spr_epsc_elpid[8*t : 8*(t+1)-1]),
		.spr_epsc_epid(spr_epsc_epid[14*t : 14*(t+1)-1]),
		.spr_hacop_ct(spr_hacop_ct[32*t : 32*(t+1)-1]),
            // Power
            .vdd(vdd),
            .gnd(gnd)
         );
      end
   end
endgenerate

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) slowspr_val_in_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[slowspr_val_in_offset]),
   .scout(sov[slowspr_val_in_offset]),
   .din(slowspr_val_in_gate),
   .dout(slowspr_val_in_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) slowspr_rw_in_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(slowspr_act_in),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[slowspr_rw_in_offset]),
   .scout(sov[slowspr_rw_in_offset]),
   .din(slowspr_rw_in),
   .dout(slowspr_rw_in_q)
);

tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) slowspr_etid_in_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(slowspr_act_in),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[slowspr_etid_in_offset:slowspr_etid_in_offset + 2 - 1]),
   .scout(sov[slowspr_etid_in_offset:slowspr_etid_in_offset + 2 - 1]),
   .din(slowspr_etid_in),
   .dout(slowspr_etid_in_q)
);

tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) slowspr_addr_in_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(slowspr_act_in),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[slowspr_addr_in_offset:slowspr_addr_in_offset + 10 - 1]),
   .scout(sov[slowspr_addr_in_offset:slowspr_addr_in_offset + 10 - 1]),
   .din(slowspr_addr_in),
   .dout(slowspr_addr_in_q)
);

tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) slowspr_data_in_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(slowspr_act_in),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[slowspr_data_in_offset:slowspr_data_in_offset + `GPR_WIDTH - 1]),
   .scout(sov[slowspr_data_in_offset:slowspr_data_in_offset + `GPR_WIDTH - 1]),
   .din(slowspr_data_in),
   .dout(slowspr_data_in_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) slowspr_done_in_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[slowspr_done_in_offset]),
   .scout(sov[slowspr_done_in_offset]),
   .din(slowspr_done_in),
   .dout(slowspr_done_in_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) slowspr_val_out_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[slowspr_val_out_offset]),
   .scout(sov[slowspr_val_out_offset]),
   .din(slowspr_val_in_stg),
   .dout(slowspr_val_out_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) slowspr_rw_out_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(slowspr_val_in_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[slowspr_rw_out_offset]),
   .scout(sov[slowspr_rw_out_offset]),
   .din(slowspr_rw_in_q),
   .dout(slowspr_rw_out_q)
);

tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) slowspr_etid_out_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(slowspr_val_in_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[slowspr_etid_out_offset:slowspr_etid_out_offset + 2 - 1]),
   .scout(sov[slowspr_etid_out_offset:slowspr_etid_out_offset + 2 - 1]),
   .din(slowspr_etid_in_q),
   .dout(slowspr_etid_out_q)
);

tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) slowspr_addr_out_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(slowspr_val_in_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[slowspr_addr_out_offset:slowspr_addr_out_offset + 10 - 1]),
   .scout(sov[slowspr_addr_out_offset:slowspr_addr_out_offset + 10 - 1]),
   .din(slowspr_addr_in_q),
   .dout(slowspr_addr_out_q)
);

tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) slowspr_data_out_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(slowspr_val_in_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[slowspr_data_out_offset:slowspr_data_out_offset + `GPR_WIDTH - 1]),
   .scout(sov[slowspr_data_out_offset:slowspr_data_out_offset + `GPR_WIDTH - 1]),
   .din(slowspr_data_out_d),
   .dout(slowspr_data_out_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) slowspr_done_out_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[slowspr_done_out_offset]),
   .scout(sov[slowspr_done_out_offset]),
   .din(slowspr_done_out_d),
   .dout(slowspr_done_out_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) flush_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[flush_offset:flush_offset + `THREADS - 1]),
   .scout(sov[flush_offset:flush_offset + `THREADS - 1]),
   .din(flush),
   .dout(flush_q)
);

assign siv[0:scan_right - 1] = {sov[1:scan_right - 1], scan_in};
assign scan_out = sov[0];

endmodule
