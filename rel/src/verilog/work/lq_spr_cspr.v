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

module lq_spr_cspr
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

   input [0:`THREADS-1]       ex1_valid,
   input [0:`THREADS-1]       flush,

   // SlowSPR Interface
   input                      slowspr_val_in,
   input                      slowspr_rw_in,
   input [0:9]                slowspr_addr_in,
   input [64-`GPR_WIDTH:63]      slowspr_data_in,

   output                     cspr_done,
   output [64-`GPR_WIDTH:63]     cspr_rt,

   input                      ex3_data_val,
   input [64-`GPR_WIDTH:63]      ex3_eff_addr,

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

   output [0:`THREADS-1]      cspr_tspr_msr_pr,
   output [0:`THREADS-1]      cspr_tspr_msr_gs,

   input [0:2*`THREADS-1]     tspr_cspr_dbcr2_dac1us,
   input [0:2*`THREADS-1]     tspr_cspr_dbcr2_dac1er,
   input [0:2*`THREADS-1]     tspr_cspr_dbcr2_dac2us,
   input [0:2*`THREADS-1]     tspr_cspr_dbcr2_dac2er,
   input [0:2*`THREADS-1]     tspr_cspr_dbcr3_dac3us,
   input [0:2*`THREADS-1]     tspr_cspr_dbcr3_dac3er,
   input [0:2*`THREADS-1]     tspr_cspr_dbcr3_dac4us,
   input [0:2*`THREADS-1]     tspr_cspr_dbcr3_dac4er,

   input [0:`THREADS-1]       tspr_cspr_dbcr2_dac12m,
   input [0:`THREADS-1]       tspr_cspr_dbcr3_dac34m,
   input [0:2*`THREADS-1]     tspr_cspr_dbcr2_dvc1m,
   input [0:2*`THREADS-1]     tspr_cspr_dbcr2_dvc2m,
   input [0:8*`THREADS-1]     tspr_cspr_dbcr2_dvc1be,
   input [0:8*`THREADS-1]     tspr_cspr_dbcr2_dvc2be,

   output                     spr_xudbg0_exec,
   input                      spr_xudbg0_done,
   input                      spr_xudbg1_valid,
   input [0:3]                spr_xudbg1_watch,
   input [0:3]                spr_xudbg1_parity,
   input [0:6]                spr_xudbg1_lru,
   input                      spr_xudbg1_lock,
   input [33:63]              spr_xudbg2_tag,
   output [0:31]	      spr_pesr,

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

   inout                      vdd,
   inout                      gnd
);


// SPR Registers
	// SPR Registers
	wire [64-(`GPR_WIDTH):63]     dac1_d,                   dac1_q;
	wire [64-(`GPR_WIDTH):63]     dac2_d,                   dac2_q;
	wire [64-(`GPR_WIDTH):63]     dac3_d,                   dac3_q;
	wire [64-(`GPR_WIDTH):63]     dac4_d,                   dac4_q;
	wire [64-(`GPR_WIDTH):63]     dvc1_d,                   dvc1_q;
	wire [64-(`GPR_WIDTH):63]     dvc2_d,                   dvc2_q;
	wire [40:63]                  lesr1_d,                  lesr1_q;
	wire [40:63]                  lesr2_d,                  lesr2_q;
	wire [53:63]                  lsucr0_d,                 lsucr0_q;
	wire [32:63]                  pesr_d,                   pesr_q;
	wire [32:63]                  xucr2_d,                  xucr2_q;
	wire [55:63]                  xudbg0_d,                 xudbg0_q;
// FUNC Scanchain
	localparam dac1_offset                    = 0;
	localparam dac2_offset                    = dac1_offset                    + `GPR_WIDTH*a2mode;
	localparam dac3_offset                    = dac2_offset                    + `GPR_WIDTH*a2mode;
	localparam dac4_offset                    = dac3_offset                    + `GPR_WIDTH;
	localparam dvc1_offset                    = dac4_offset                    + `GPR_WIDTH;
	localparam dvc2_offset                    = dvc1_offset                    + `GPR_WIDTH*a2mode;
	localparam lesr1_offset                   = dvc2_offset                    + `GPR_WIDTH*a2mode;
	localparam lesr2_offset                   = lesr1_offset                   + 24;
	localparam pesr_offset                    = lesr2_offset                   + 24;
	localparam xucr2_offset                   = pesr_offset                    + 32;
	localparam xudbg0_offset                  = xucr2_offset                   + 32;
	localparam last_reg_offset                = xudbg0_offset                  + 9;
// CCFG Scanchain
	localparam lsucr0_offset_ccfg             = 0;
	localparam last_reg_offset_ccfg           = lsucr0_offset_ccfg             + 11;
// Latches
wire [2:3]                 exx_act_q;		// input=>exx_act_d                  , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire [2:3]                 exx_act_d;
wire [0:7]                 ex3_dac12m_q;		// input=>ex3_dac12m_d               , act=>exx_act(2)           , scan=>N, sleep=>N, ring=>func
wire [0:7]                 ex3_dac12m_d;
wire [0:7]                 ex3_dac34m_q;		// input=>ex3_dac34m_d               , act=>exx_act(2)           , scan=>N, sleep=>N, ring=>func
wire [0:7]                 ex3_dac34m_d;
wire                       ex3_is_any_load_dac_q;		// input=>ex2_is_any_load_dac        , act=>exx_act(2)           , scan=>N, sleep=>N, ring=>func
wire                       ex3_is_any_store_dac_q;		// input=>ex2_is_any_store_dac       , act=>exx_act(2)           , scan=>N, sleep=>N, ring=>func
wire [0:3]                 ex4_dacrw_cmpr_q;		// input=>ex4_dacrw_cmpr_d           , act=>exx_act(3)           , scan=>Y, sleep=>N, ring=>func
wire [0:3]                 ex4_dacrw_cmpr_d;
wire [0:`THREADS-1]        ex2_val_q;		// input=>ex1_val                    , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire [0:`THREADS-1]        ex1_val;
wire [0:`THREADS-1]        ex3_val_q;		// input=>ex2_val                    , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire [0:`THREADS-1]        ex2_val;
wire [0:`THREADS-1]        ex4_val_q;		// input=>ex3_val                    , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire [0:`THREADS-1]        ex3_val;
wire [0:1]                 dbcr0_dac1_q[0:`THREADS-1];		// input=>spr_dbcr0_dac1             , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire [0:1]                 dbcr0_dac2_q[0:`THREADS-1];		// input=>spr_dbcr0_dac2             , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire [0:1]                 dbcr0_dac3_q[0:`THREADS-1];		// input=>spr_dbcr0_dac3             , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire [0:1]                 dbcr0_dac4_q[0:`THREADS-1];		// input=>spr_dbcr0_dac4             , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire [0:`THREADS-1]        dbcr2_dvc1m_on_q;		// input=>dbcr2_dvc1m_on_d           , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire [0:`THREADS-1]        dbcr2_dvc1m_on_d;
wire [0:`THREADS-1]        dbcr2_dvc2m_on_q;		// input=>dbcr2_dvc2m_on_d           , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire [0:`THREADS-1]        dbcr2_dvc2m_on_d;
wire [0:`THREADS-1]        msr_ds_q;		// input=>spr_msr_ds                 , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire [0:`THREADS-1]        msr_pr_q;		// input=>spr_msr_pr                 , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire [0:`THREADS-1]        msr_gs_q;		// input=>spr_msr_gs                 , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire                       ex4_data_val_q;		// input=>ex3_data_val               , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire                       dvc1_act_q;		// input=>dvc1_act_d                 , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire                       dvc1_act_d;
wire                       dvc2_act_q;		// input=>dvc2_act_d                 , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire                       dvc2_act_d;
wire                       xudbg0_inprog_q;		// input=>xudbg0_inprog_d            , act=>tiup                 , scan=>Y, sleep=>N, ring=>func
wire                       xudbg0_inprog_d;
wire                       xudbg0_done_d;
wire                       xudbg0_done_q;
// Scanchains
parameter                  exx_act_offset = last_reg_offset;
parameter                  ex3_dac12m_offset = exx_act_offset + 2;
parameter                  ex3_dac34m_offset = ex3_dac12m_offset + 8;
parameter                  ex3_is_any_load_dac_offset = ex3_dac34m_offset + 8;
parameter                  ex3_is_any_store_dac_offset = ex3_is_any_load_dac_offset + 1;
parameter                  ex4_dacrw_cmpr_offset = ex3_is_any_store_dac_offset + 1;
parameter                  ex2_val_offset = ex4_dacrw_cmpr_offset + 4;
parameter                  ex3_val_offset = ex2_val_offset + `THREADS;
parameter                  ex4_val_offset = ex3_val_offset + `THREADS;
parameter                  dbcr0_dac1_offset = ex4_val_offset + `THREADS;
parameter                  dbcr0_dac2_offset = dbcr0_dac1_offset + (`THREADS) * 2;
parameter                  dbcr0_dac3_offset = dbcr0_dac2_offset + (`THREADS) * 2;
parameter                  dbcr0_dac4_offset = dbcr0_dac3_offset + (`THREADS) * 2;
parameter                  dbcr2_dvc1m_on_offset = dbcr0_dac4_offset + (`THREADS) * 2;
parameter                  dbcr2_dvc2m_on_offset = dbcr2_dvc1m_on_offset + `THREADS;
parameter                  msr_ds_offset = dbcr2_dvc2m_on_offset + `THREADS;
parameter                  msr_pr_offset = msr_ds_offset + `THREADS;
parameter                  msr_gs_offset = msr_pr_offset + `THREADS;
parameter                  ex4_data_val_offset = msr_gs_offset + `THREADS;
parameter                  dvc1_act_offset = ex4_data_val_offset + 1;
parameter                  dvc2_act_offset = dvc1_act_offset + 1;
parameter                  xudbg0_inprog_offset = dvc2_act_offset + 1;
parameter                  xudbg0_done_offset = xudbg0_inprog_offset + 1;
parameter                  scan_right = xudbg0_done_offset + 1;

wire [0:scan_right-1]      siv;
wire [0:scan_right-1]      sov;
parameter                  scan_right_ccfg = last_reg_offset_ccfg;
wire [0:scan_right_ccfg-1] siv_ccfg;
wire [0:scan_right_ccfg-1] sov_ccfg;
// Signals
wire                       tiup;
wire [0:63]                tidn;
wire                       sspr_spr_we;
wire [11:20]               sspr_instr;
wire                       sspr_is_mtspr;
wire [64-`GPR_WIDTH:63]       sspr_spr_wd;
wire [64-`GPR_WIDTH:63]       ex3_dac2_mask;
wire [64-`GPR_WIDTH:63]       ex3_dac4_mask;
wire                       ex3_dac1_cmpr;
wire                       ex3_dac1_cmpr_sel;
wire                       ex3_dac2_cmpr;
wire                       ex3_dac2_cmpr_sel;
wire                       ex3_dac3_cmpr;
wire                       ex3_dac3_cmpr_sel;
wire                       ex3_dac4_cmpr;
wire                       ex3_dac4_cmpr_sel;
wire [0:`THREADS-1]        ex3_dac1r_en;
wire [0:`THREADS-1]        ex3_dac1w_en;
wire [0:`THREADS-1]        ex3_dac2r_en;
wire [0:`THREADS-1]        ex3_dac2w_en;
wire [0:`THREADS-1]        ex3_dac3r_en;
wire [0:`THREADS-1]        ex3_dac3w_en;
wire [0:`THREADS-1]        ex3_dac4r_en;
wire [0:`THREADS-1]        ex3_dac4w_en;
wire [0:`THREADS-1]        ex3_dac1r_cmpr;
wire [0:`THREADS-1]        ex3_dac1w_cmpr;
wire [0:`THREADS-1]        ex3_dac2r_cmpr;
wire [0:`THREADS-1]        ex3_dac2w_cmpr;
wire [0:`THREADS-1]        ex3_dac3r_cmpr;
wire [0:`THREADS-1]        ex3_dac3w_cmpr;
wire [0:`THREADS-1]        ex3_dac4r_cmpr;
wire [0:`THREADS-1]        ex3_dac4w_cmpr;
wire [1:3]                 exx_act;

// Data

	wire [64-(`GPR_WIDTH):63]        sspr_dac1_di;
	wire [64-(`GPR_WIDTH):63]        sspr_dac2_di;
	wire [64-(`GPR_WIDTH):63]        sspr_dac3_di;
	wire [64-(`GPR_WIDTH):63]        sspr_dac4_di;
	wire [64-(`GPR_WIDTH):63]        sspr_dvc1_di;
	wire [64-(`GPR_WIDTH):63]        sspr_dvc2_di;
	wire [40:63]                     sspr_lesr1_di;
	wire [40:63]                     sspr_lesr2_di;
	wire [53:63]                     sspr_lsucr0_di;
	wire [32:63]                     sspr_pesr_di;
	wire [32:63]                     sspr_xucr2_di;
	wire [55:63]                     sspr_xudbg0_di;
	wire
		sspr_dac1_rdec , sspr_dac2_rdec , sspr_dac3_rdec , sspr_dac4_rdec
		, sspr_dvc1_rdec , sspr_dvc2_rdec , sspr_lesr1_rdec, sspr_lesr2_rdec
		, sspr_lsucr0_rdec, sspr_pesr_rdec , sspr_xucr2_rdec, sspr_xudbg0_rdec
		, sspr_xudbg1_rdec, sspr_xudbg2_rdec;
	wire
		sspr_dac1_re   , sspr_dac2_re   , sspr_dac3_re   , sspr_dac4_re
		, sspr_dvc1_re   , sspr_dvc2_re   , sspr_lesr1_re  , sspr_lesr2_re
		, sspr_lsucr0_re , sspr_pesr_re   , sspr_xucr2_re  , sspr_xudbg0_re
		, sspr_xudbg1_re , sspr_xudbg2_re ;
	wire
		sspr_dac1_wdec , sspr_dac2_wdec , sspr_dac3_wdec , sspr_dac4_wdec
		, sspr_dvc1_wdec , sspr_dvc2_wdec , sspr_lesr1_wdec, sspr_lesr2_wdec
		, sspr_lsucr0_wdec, sspr_pesr_wdec , sspr_xucr2_wdec, sspr_xudbg0_wdec;
	wire
		sspr_dac1_we   , sspr_dac2_we   , sspr_dac3_we   , sspr_dac4_we
		, sspr_dvc1_we   , sspr_dvc2_we   , sspr_lesr1_we  , sspr_lesr2_we
		, sspr_lsucr0_we , sspr_pesr_we   , sspr_xucr2_we  , sspr_xudbg0_we ;
	wire
		dac1_act       , dac2_act       , dac3_act       , dac4_act
		, dvc1_act       , dvc2_act       , lesr1_act      , lesr2_act
		, lsucr0_act     , pesr_act       , xucr2_act      , xudbg0_act
		, xudbg1_act     , xudbg2_act     ;
	wire [0:64]
		dac1_do        , dac2_do        , dac3_do        , dac4_do
		, dvc1_do        , dvc2_do        , lesr1_do       , lesr2_do
		, lsucr0_do      , pesr_do        , xucr2_do       , xudbg0_do
		, xudbg1_do      , xudbg2_do      ;
wire [0:2*`THREADS-1]      dbcr0_dac1_int;
wire [0:2*`THREADS-1]      dbcr0_dac2_int;
wire [0:2*`THREADS-1]      dbcr0_dac3_int;
wire [0:2*`THREADS-1]      dbcr0_dac4_int;
wire [0:7]                 tspr_cspr_dbcr2_dvc1be_int[0:`THREADS-1];
wire [0:7]                 tspr_cspr_dbcr2_dvc2be_int[0:`THREADS-1];
wire [0:1]                 tspr_cspr_dbcr2_dvc1m_int[0:`THREADS-1];
wire [0:1]                 tspr_cspr_dbcr2_dvc2m_int[0:`THREADS-1];

//!! Bugspray Include: lq_spr_cspr;

assign tiup = 1'b1;
assign tidn = {64{1'b0}};

assign exx_act_d = exx_act[1:2];

assign exx_act[1] = |(ex1_valid);
assign exx_act[2] = exx_act_q[2];
assign exx_act[3] = exx_act_q[3];

assign ex1_val = ex1_valid & (~flush);
assign ex2_val = ex2_val_q & (~flush);
assign ex3_val = ex3_val_q & (~flush);

assign sspr_is_mtspr = (~slowspr_rw_in);
assign sspr_instr = {slowspr_addr_in[5:9], slowspr_addr_in[0:4]};
assign sspr_spr_we = slowspr_val_in;
assign sspr_spr_wd = slowspr_data_in;

// SPR Input Control
// DAC1
assign dac1_act = sspr_dac1_we;
assign dac1_d = sspr_dac1_di;

// DAC2
assign dac2_act = sspr_dac2_we;
assign dac2_d = sspr_dac2_di;

// DAC3
assign dac3_act = sspr_dac3_we;
assign dac3_d = sspr_dac3_di;

// DAC4
assign dac4_act = sspr_dac4_we;
assign dac4_d = sspr_dac4_di;

// DVC1
assign dvc1_act = sspr_dvc1_we;
assign dvc1_act_d = sspr_dvc1_we;
assign dvc1_d = sspr_dvc1_di;

// DVC2
assign dvc2_act = sspr_dvc2_we;
assign dvc2_act_d = sspr_dvc2_we;
assign dvc2_d = sspr_dvc2_di;

// LSUCR0
assign lsucr0_act = sspr_lsucr0_we;
assign lsucr0_d = sspr_lsucr0_di;

// PESR
assign pesr_act = sspr_pesr_we;
assign pesr_d   = sspr_pesr_di;

// XUCR2
assign xucr2_act = sspr_xucr2_we;
assign xucr2_d = sspr_xucr2_di;

// XUDBG0
assign xudbg0_act      = sspr_xudbg0_we & (~xudbg0_inprog_q);
assign xudbg0_d        = sspr_xudbg0_di;

wire [0:1] xudbg0_done_sel = {(sspr_xudbg0_we & (~xudbg0_inprog_q)), spr_xudbg0_done};
assign xudbg0_done_d   = (xudbg0_done_sel == 2'b00) ? xudbg0_done_q      :
                         (xudbg0_done_sel == 2'b10) ? sspr_spr_wd[63] :
                                                      spr_xudbg0_done;

assign spr_xudbg0_exec = sspr_xudbg0_we & sspr_spr_wd[62] & (~xudbg0_inprog_q);
assign xudbg0_inprog_d = (sspr_xudbg0_we & sspr_spr_wd[62]) | (xudbg0_inprog_q & (~spr_xudbg0_done));

// XUDBG0
assign xudbg1_act = tiup;

// XUDBG0
assign xudbg2_act = tiup;

// LESR1
assign lesr1_act = sspr_lesr1_we;
assign lesr1_d = sspr_lesr1_di;

// LESR2
assign lesr2_act = sspr_lesr2_we;
assign lesr2_d = sspr_lesr2_di;

// Compare Address Against DAC regs
assign ex3_dac12m_d = {8{|(tspr_cspr_dbcr2_dac12m & ex2_val_q)}};
assign ex3_dac34m_d = {8{|(tspr_cspr_dbcr3_dac34m & ex2_val_q)}};

assign ex3_dac2_mask = dac2_q | {`GPR_WIDTH/8{~ex3_dac12m_q}};
assign ex3_dac4_mask = dac4_q | {`GPR_WIDTH/8{~ex3_dac34m_q}};

assign ex3_dac1_cmpr = &((ex3_eff_addr ~^ dac1_q) | (~ex3_dac2_mask));
assign ex3_dac2_cmpr = &((ex3_eff_addr ~^ dac2_q));
assign ex3_dac3_cmpr = &((ex3_eff_addr ~^ dac3_q) | (~ex3_dac4_mask));
assign ex3_dac4_cmpr = &((ex3_eff_addr ~^ dac4_q));

assign ex3_dac1_cmpr_sel = ex3_dac1_cmpr;
assign ex3_dac2_cmpr_sel = (ex3_dac12m_q[0] == 1'b0) ? ex3_dac2_cmpr :
                           ex3_dac1_cmpr;
assign ex3_dac3_cmpr_sel = ex3_dac3_cmpr;
assign ex3_dac4_cmpr_sel = (ex3_dac34m_q[0] == 1'b0) ? ex3_dac4_cmpr :
                           ex3_dac3_cmpr;

// Determine if DAC is enabled for this thread
generate begin : sprTidOut
  genvar tid;
  for (tid=0; tid<`THREADS; tid=tid+1) begin : sprTidOut
 	assign dbcr0_dac1_int[tid*2:(tid*2)+1] = dbcr0_dac1_q[tid];
 	assign dbcr0_dac2_int[tid*2:(tid*2)+1] = dbcr0_dac2_q[tid];
 	assign dbcr0_dac3_int[tid*2:(tid*2)+1] = dbcr0_dac3_q[tid];
 	assign dbcr0_dac4_int[tid*2:(tid*2)+1] = dbcr0_dac4_q[tid];
   assign tspr_cspr_dbcr2_dvc1be_int[tid] = tspr_cspr_dbcr2_dvc1be[tid*8:tid*8+7];
   assign tspr_cspr_dbcr2_dvc2be_int[tid] = tspr_cspr_dbcr2_dvc2be[tid*8:tid*8+7];
   assign tspr_cspr_dbcr2_dvc1m_int[tid]  = tspr_cspr_dbcr2_dvc1m[tid*2:tid*2+1];
   assign tspr_cspr_dbcr2_dvc2m_int[tid]  = tspr_cspr_dbcr2_dvc2m[tid*2:tid*2+1];
  end
end
endgenerate

lq_spr_dacen  lq_spr_dac1en(
   .spr_msr_pr(msr_pr_q),
   .spr_msr_ds(msr_ds_q),
   .spr_dbcr0_dac(dbcr0_dac1_int),
   .spr_dbcr_dac_us(tspr_cspr_dbcr2_dac1us),
   .spr_dbcr_dac_er(tspr_cspr_dbcr2_dac1er),
   .val(ex3_val_q),
   .load(ex3_is_any_load_dac_q),
   .store(ex3_is_any_store_dac_q),
   .dacr_en(ex3_dac1r_en),
   .dacw_en(ex3_dac1w_en)
);


lq_spr_dacen  lq_spr_dac2en(
   .spr_msr_pr(msr_pr_q),
   .spr_msr_ds(msr_ds_q),
   .spr_dbcr0_dac(dbcr0_dac2_int),
   .spr_dbcr_dac_us(tspr_cspr_dbcr2_dac2us),
   .spr_dbcr_dac_er(tspr_cspr_dbcr2_dac2er),
   .val(ex3_val_q),
   .load(ex3_is_any_load_dac_q),
   .store(ex3_is_any_store_dac_q),
   .dacr_en(ex3_dac2r_en),
   .dacw_en(ex3_dac2w_en)
);


lq_spr_dacen  lq_spr_dac3en(
   .spr_msr_pr(msr_pr_q),
   .spr_msr_ds(msr_ds_q),
   .spr_dbcr0_dac(dbcr0_dac3_int),
   .spr_dbcr_dac_us(tspr_cspr_dbcr3_dac3us),
   .spr_dbcr_dac_er(tspr_cspr_dbcr3_dac3er),
   .val(ex3_val_q),
   .load(ex3_is_any_load_dac_q),
   .store(ex3_is_any_store_dac_q),
   .dacr_en(ex3_dac3r_en),
   .dacw_en(ex3_dac3w_en)
);


lq_spr_dacen  lq_spr_dac4en(
   .spr_msr_pr(msr_pr_q),
   .spr_msr_ds(msr_ds_q),
   .spr_dbcr0_dac(dbcr0_dac4_int),
   .spr_dbcr_dac_us(tspr_cspr_dbcr3_dac4us),
   .spr_dbcr_dac_er(tspr_cspr_dbcr3_dac4er),
   .val(ex3_val_q),
   .load(ex3_is_any_load_dac_q),
   .store(ex3_is_any_store_dac_q),
   .dacr_en(ex3_dac4r_en),
   .dacw_en(ex3_dac4w_en)
);

generate begin : lq_spr_dvc_cmp
      genvar                     t;
      for (t = 0; t <= `THREADS - 1; t = t + 1) begin : lq_spr_dvc_cmp
         assign dbcr2_dvc1m_on_d[t] = |(tspr_cspr_dbcr2_dvc1m_int[t]) & |(tspr_cspr_dbcr2_dvc1be_int[t][8 - `GPR_WIDTH/8:7]);
         assign dbcr2_dvc2m_on_d[t] = |(tspr_cspr_dbcr2_dvc2m_int[t]) & |(tspr_cspr_dbcr2_dvc2be_int[t][8 - `GPR_WIDTH/8:7]);
      end
end
endgenerate

assign ex3_dac1r_cmpr = ex3_dac1r_en & {`THREADS{ex3_dac1_cmpr_sel}};
assign ex3_dac2r_cmpr = ex3_dac2r_en & {`THREADS{ex3_dac2_cmpr_sel}};
assign ex3_dac3r_cmpr = ex3_dac3r_en & {`THREADS{ex3_dac3_cmpr_sel}};
assign ex3_dac4r_cmpr = ex3_dac4r_en & {`THREADS{ex3_dac4_cmpr_sel}};

assign ex3_dac1w_cmpr = ex3_dac1w_en & {`THREADS{ex3_dac1_cmpr_sel}};
assign ex3_dac2w_cmpr = ex3_dac2w_en & {`THREADS{ex3_dac2_cmpr_sel}};
assign ex3_dac3w_cmpr = ex3_dac3w_en & {`THREADS{ex3_dac3_cmpr_sel}};
assign ex3_dac4w_cmpr = ex3_dac4w_en & {`THREADS{ex3_dac4_cmpr_sel}};

assign ex4_dacrw_cmpr_d[0] = |({ex3_dac1r_cmpr, ex3_dac1w_cmpr});
assign ex4_dacrw_cmpr_d[1] = |({ex3_dac2r_cmpr, ex3_dac2w_cmpr});
assign ex4_dacrw_cmpr_d[2] = |({ex3_dac3r_cmpr, ex3_dac3w_cmpr});
assign ex4_dacrw_cmpr_d[3] = |({ex3_dac4r_cmpr, ex3_dac4w_cmpr});

assign spr_dcc_ex4_dvc1_en = |(ex4_val_q & dbcr2_dvc1m_on_q) & ex4_dacrw_cmpr_q[0] & ex4_data_val_q;
assign spr_dcc_ex4_dvc2_en = |(ex4_val_q & dbcr2_dvc2m_on_q) & ex4_dacrw_cmpr_q[1] & ex4_data_val_q;
assign spr_dcc_ex4_dacrw1_cmpr = |(ex4_val_q & (~dbcr2_dvc1m_on_q)) & ex4_dacrw_cmpr_q[0];
assign spr_dcc_ex4_dacrw2_cmpr = |(ex4_val_q & (~dbcr2_dvc2m_on_q)) & ex4_dacrw_cmpr_q[1];
assign spr_dcc_ex4_dacrw3_cmpr = |(ex4_val_q) & ex4_dacrw_cmpr_q[2];
assign spr_dcc_ex4_dacrw4_cmpr = |(ex4_val_q) & ex4_dacrw_cmpr_q[3];

assign spr_pesr     = pesr_q;

generate
   if (a2mode == 0 & hvmode == 0) begin : readmux_00
			assign cspr_rt =
			(dac3_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dac3_re           }}) |
			(dac4_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dac4_re           }}) |
			(lesr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_lesr1_re          }}) |
			(lesr2_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_lesr2_re          }}) |
			(lsucr0_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_lsucr0_re         }}) |
			(pesr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_pesr_re           }}) |
			(xucr2_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_xucr2_re          }}) |
			(xudbg0_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_xudbg0_re         }}) |
			(xudbg1_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_xudbg1_re         }}) |
			(xudbg2_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_xudbg2_re         }});
   end
endgenerate
generate
   if (a2mode == 0 & hvmode == 1) begin : readmux_01
			assign cspr_rt =
			(dac3_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dac3_re           }}) |
			(dac4_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dac4_re           }}) |
			(lesr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_lesr1_re          }}) |
			(lesr2_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_lesr2_re          }}) |
			(lsucr0_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_lsucr0_re         }}) |
			(pesr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_pesr_re           }}) |
			(xucr2_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_xucr2_re          }}) |
			(xudbg0_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_xudbg0_re         }}) |
			(xudbg1_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_xudbg1_re         }}) |
			(xudbg2_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_xudbg2_re         }});
   end
endgenerate
generate
   if (a2mode == 1 & hvmode == 0) begin : readmux_10
			assign cspr_rt =
			(dac1_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dac1_re           }}) |
			(dac2_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dac2_re           }}) |
			(dac3_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dac3_re           }}) |
			(dac4_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dac4_re           }}) |
			(dvc1_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dvc1_re           }}) |
			(dvc2_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dvc2_re           }}) |
			(lesr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_lesr1_re          }}) |
			(lesr2_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_lesr2_re          }}) |
			(lsucr0_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_lsucr0_re         }}) |
			(pesr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_pesr_re           }}) |
			(xucr2_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_xucr2_re          }}) |
			(xudbg0_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_xudbg0_re         }}) |
			(xudbg1_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_xudbg1_re         }}) |
			(xudbg2_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_xudbg2_re         }});
   end
endgenerate
generate
   if (a2mode == 1 & hvmode == 1) begin : readmux_11
			assign cspr_rt =
			(dac1_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dac1_re           }}) |
			(dac2_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dac2_re           }}) |
			(dac3_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dac3_re           }}) |
			(dac4_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dac4_re           }}) |
			(dvc1_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dvc1_re           }}) |
			(dvc2_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dvc2_re           }}) |
			(lesr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_lesr1_re          }}) |
			(lesr2_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_lesr2_re          }}) |
			(lsucr0_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_lsucr0_re         }}) |
			(pesr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_pesr_re           }}) |
			(xucr2_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_xucr2_re          }}) |
			(xudbg0_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_xudbg0_re         }}) |
			(xudbg1_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_xudbg1_re         }}) |
			(xudbg2_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{sspr_xudbg2_re         }});
   end
endgenerate

	assign sspr_dac1_rdec      = (sspr_instr[11:20] == 10'b1110001001);   //  316
	assign sspr_dac2_rdec      = (sspr_instr[11:20] == 10'b1110101001);   //  317
	assign sspr_dac3_rdec      = (sspr_instr[11:20] == 10'b1000111010);   //  849
	assign sspr_dac4_rdec      = (sspr_instr[11:20] == 10'b1001011010);   //  850
	assign sspr_dvc1_rdec      = (sspr_instr[11:20] == 10'b1111001001);   //  318
	assign sspr_dvc2_rdec      = (sspr_instr[11:20] == 10'b1111101001);   //  319
	assign sspr_lesr1_rdec     = (sspr_instr[11:20] == 10'b1100011100);   //  920
	assign sspr_lesr2_rdec     = (sspr_instr[11:20] == 10'b1100111100);   //  921
	assign sspr_lsucr0_rdec    = (sspr_instr[11:20] == 10'b1001111001);   //  819
	assign sspr_pesr_rdec      = (sspr_instr[11:20] == 10'b1110111011);   //  893
	assign sspr_xucr2_rdec     = (sspr_instr[11:20] == 10'b1100011111);   // 1016
	assign sspr_xudbg0_rdec    = (sspr_instr[11:20] == 10'b1010111011);   //  885
	assign sspr_xudbg1_rdec    = (sspr_instr[11:20] == 10'b1011011011);   //  886
	assign sspr_xudbg2_rdec    = (sspr_instr[11:20] == 10'b1011111011);   //  887
	assign sspr_dac1_re        =  sspr_dac1_rdec;
	assign sspr_dac2_re        =  sspr_dac2_rdec;
	assign sspr_dac3_re        =  sspr_dac3_rdec;
	assign sspr_dac4_re        =  sspr_dac4_rdec;
	assign sspr_dvc1_re        =  sspr_dvc1_rdec;
	assign sspr_dvc2_re        =  sspr_dvc2_rdec;
	assign sspr_lesr1_re       =  sspr_lesr1_rdec;
	assign sspr_lesr2_re       =  sspr_lesr2_rdec;
	assign sspr_lsucr0_re      =  sspr_lsucr0_rdec;
	assign sspr_pesr_re        =  sspr_pesr_rdec;
	assign sspr_xucr2_re       =  sspr_xucr2_rdec;
	assign sspr_xudbg0_re      =  sspr_xudbg0_rdec;
	assign sspr_xudbg1_re      =  sspr_xudbg1_rdec;
	assign sspr_xudbg2_re      =  sspr_xudbg2_rdec;

	assign sspr_dac1_wdec      = sspr_dac1_rdec;
	assign sspr_dac2_wdec      = sspr_dac2_rdec;
	assign sspr_dac3_wdec      = sspr_dac3_rdec;
	assign sspr_dac4_wdec      = sspr_dac4_rdec;
	assign sspr_dvc1_wdec      = sspr_dvc1_rdec;
	assign sspr_dvc2_wdec      = sspr_dvc2_rdec;
	assign sspr_lesr1_wdec     = sspr_lesr1_rdec;
	assign sspr_lesr2_wdec     = sspr_lesr2_rdec;
	assign sspr_lsucr0_wdec    = sspr_lsucr0_rdec;
	assign sspr_pesr_wdec      = sspr_pesr_rdec;
	assign sspr_xucr2_wdec     = sspr_xucr2_rdec;
	assign sspr_xudbg0_wdec    = sspr_xudbg0_rdec;
	assign sspr_dac1_we       = sspr_spr_we & sspr_is_mtspr &  sspr_dac1_wdec;
	assign sspr_dac2_we       = sspr_spr_we & sspr_is_mtspr &  sspr_dac2_wdec;
	assign sspr_dac3_we       = sspr_spr_we & sspr_is_mtspr &  sspr_dac3_wdec;
	assign sspr_dac4_we       = sspr_spr_we & sspr_is_mtspr &  sspr_dac4_wdec;
	assign sspr_dvc1_we       = sspr_spr_we & sspr_is_mtspr &  sspr_dvc1_wdec;
	assign sspr_dvc2_we       = sspr_spr_we & sspr_is_mtspr &  sspr_dvc2_wdec;
	assign sspr_lesr1_we      = sspr_spr_we & sspr_is_mtspr &  sspr_lesr1_wdec;
	assign sspr_lesr2_we      = sspr_spr_we & sspr_is_mtspr &  sspr_lesr2_wdec;
	assign sspr_lsucr0_we     = sspr_spr_we & sspr_is_mtspr &  sspr_lsucr0_wdec;
	assign sspr_pesr_we       = sspr_spr_we & sspr_is_mtspr &  sspr_pesr_wdec;
	assign sspr_xucr2_we      = sspr_spr_we & sspr_is_mtspr &  sspr_xucr2_wdec;
	assign sspr_xudbg0_we     = sspr_spr_we & sspr_is_mtspr &  sspr_xudbg0_wdec;

assign cspr_done = slowspr_val_in & (
                             sspr_dac1_rdec       | sspr_dac2_rdec       | sspr_dac3_rdec
                           | sspr_dac4_rdec       | sspr_dvc1_rdec       | sspr_dvc2_rdec
                           | sspr_lesr1_rdec      | sspr_lesr2_rdec      | sspr_lsucr0_rdec
                           | sspr_pesr_rdec       | sspr_xucr2_rdec      | sspr_xudbg0_rdec
                           | sspr_xudbg1_rdec     | sspr_xudbg2_rdec     );


assign cspr_tspr_msr_pr = msr_pr_q;
assign cspr_tspr_msr_gs = msr_gs_q;

	assign spr_dvc1                    = dvc1_q[64-(`GPR_WIDTH):63];
	assign spr_dvc2                    = dvc2_q[64-(`GPR_WIDTH):63];
	assign spr_lesr1_muxseleb0         = lesr1_q[40:45];
	assign spr_lesr1_muxseleb1         = lesr1_q[46:51];
	assign spr_lesr1_muxseleb2         = lesr1_q[52:57];
	assign spr_lesr1_muxseleb3         = lesr1_q[58:63];
	assign spr_lesr2_muxseleb4         = lesr2_q[40:45];
	assign spr_lesr2_muxseleb5         = lesr2_q[46:51];
	assign spr_lesr2_muxseleb6         = lesr2_q[52:57];
	assign spr_lesr2_muxseleb7         = lesr2_q[58:63];
	assign spr_lsucr0_lca              = lsucr0_q[53:55];
	assign spr_lsucr0_sca              = lsucr0_q[56:58];
	assign spr_lsucr0_lge              = lsucr0_q[59];
	assign spr_lsucr0_b2b              = lsucr0_q[60];
	assign spr_lsucr0_dfwd             = lsucr0_q[61];
	assign spr_lsucr0_clchk            = lsucr0_q[62];
	assign spr_lsucr0_ford             = lsucr0_q[63];
	assign spr_xucr2_rmt3              = xucr2_q[32:39];
	assign spr_xucr2_rmt2              = xucr2_q[40:47];
	assign spr_xucr2_rmt1              = xucr2_q[48:55];
	assign spr_xucr2_rmt0              = xucr2_q[56:63];
	assign spr_xudbg0_way              = xudbg0_q[55:57];
	assign spr_xudbg0_row              = xudbg0_q[58:63];

	// DAC1
	assign sspr_dac1_di    = { sspr_spr_wd[64-(`GPR_WIDTH):63]  }; //DAC1

	assign dac1_do         = { tidn[0:64-(`GPR_WIDTH)]          ,
                              dac1_q[64-(`GPR_WIDTH):63]       }; //DAC1
	// DAC2
	assign sspr_dac2_di    = { sspr_spr_wd[64-(`GPR_WIDTH):63]  }; //DAC2

	assign dac2_do         = { tidn[0:64-(`GPR_WIDTH)]          ,
                              dac2_q[64-(`GPR_WIDTH):63]       }; //DAC2
	// DAC3
	assign sspr_dac3_di    = { sspr_spr_wd[64-(`GPR_WIDTH):63]  }; //DAC3

	assign dac3_do         = { tidn[0:64-(`GPR_WIDTH)]          ,
                              dac3_q[64-(`GPR_WIDTH):63]       }; //DAC3
	// DAC4
	assign sspr_dac4_di    = { sspr_spr_wd[64-(`GPR_WIDTH):63]  }; //DAC4

	assign dac4_do         = { tidn[0:64-(`GPR_WIDTH)]          ,
                              dac4_q[64-(`GPR_WIDTH):63]       }; //DAC4
	// DVC1
	assign sspr_dvc1_di    = { sspr_spr_wd[64-(`GPR_WIDTH):63]  }; //DVC1

	assign dvc1_do         = { tidn[0:64-(`GPR_WIDTH)]          ,
                              dvc1_q[64-(`GPR_WIDTH):63]       }; //DVC1
	// DVC2
	assign sspr_dvc2_di    = { sspr_spr_wd[64-(`GPR_WIDTH):63]  }; //DVC2

	assign dvc2_do         = { tidn[0:64-(`GPR_WIDTH)]          ,
                              dvc2_q[64-(`GPR_WIDTH):63]       }; //DVC2
	// LESR1
	assign sspr_lesr1_di   = { sspr_spr_wd[32:37]               , //MUXSELEB0
                              sspr_spr_wd[38:43]               , //MUXSELEB1
                              sspr_spr_wd[44:49]               , //MUXSELEB2
                              sspr_spr_wd[50:55]               }; //MUXSELEB3

	assign lesr1_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              lesr1_q[40:45]                   , //MUXSELEB0
                              lesr1_q[46:51]                   , //MUXSELEB1
                              lesr1_q[52:57]                   , //MUXSELEB2
                              lesr1_q[58:63]                   , //MUXSELEB3
                              tidn[56:63]                      }; /////
	// LESR2
	assign sspr_lesr2_di   = { sspr_spr_wd[32:37]               , //MUXSELEB4
                              sspr_spr_wd[38:43]               , //MUXSELEB5
                              sspr_spr_wd[44:49]               , //MUXSELEB6
                              sspr_spr_wd[50:55]               }; //MUXSELEB7

	assign lesr2_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              lesr2_q[40:45]                   , //MUXSELEB4
                              lesr2_q[46:51]                   , //MUXSELEB5
                              lesr2_q[52:57]                   , //MUXSELEB6
                              lesr2_q[58:63]                   , //MUXSELEB7
                              tidn[56:63]                      }; /////
	// LSUCR0
	assign sspr_lsucr0_di  = { sspr_spr_wd[49:51]               , //LCA
                              sspr_spr_wd[53:55]               , //SCA
                              sspr_spr_wd[59:59]               , //LGE
                              sspr_spr_wd[60:60]               , //B2B
                              sspr_spr_wd[61:61]               , //DFWD
                              sspr_spr_wd[62:62]               , //CLCHK
                              sspr_spr_wd[63:63]               }; //FORD

	assign lsucr0_do       = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:48]                      , /////
                              lsucr0_q[53:55]                  , //LCA
                              tidn[52:52]                      , /////
                              lsucr0_q[56:58]                  , //SCA
                              tidn[56:58]                      , /////
                              lsucr0_q[59:59]                  , //LGE
                              lsucr0_q[60:60]                  , //B2B
                              lsucr0_q[61:61]                  , //DFWD
                              lsucr0_q[62:62]                  , //CLCHK
                              lsucr0_q[63:63]                  }; //FORD
	// PESR
	assign sspr_pesr_di    = { sspr_spr_wd[32:35]               , //MUXSELEB0
                              sspr_spr_wd[36:39]               , //MUXSELEB1
                              sspr_spr_wd[40:43]               , //MUXSELEB2
                              sspr_spr_wd[44:47]               , //MUXSELEB3
                              sspr_spr_wd[48:51]               , //MUXSELEB4
                              sspr_spr_wd[52:55]               , //MUXSELEB5
                              sspr_spr_wd[56:59]               , //MUXSELEB6
                              sspr_spr_wd[60:63]               }; //MUXSELEB7

	assign pesr_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              pesr_q[32:35]                    , //MUXSELEB0
                              pesr_q[36:39]                    , //MUXSELEB1
                              pesr_q[40:43]                    , //MUXSELEB2
                              pesr_q[44:47]                    , //MUXSELEB3
                              pesr_q[48:51]                    , //MUXSELEB4
                              pesr_q[52:55]                    , //MUXSELEB5
                              pesr_q[56:59]                    , //MUXSELEB6
                              pesr_q[60:63]                    }; //MUXSELEB7
	// XUCR2
	assign sspr_xucr2_di   = { sspr_spr_wd[32:39]               , //RMT3
                              sspr_spr_wd[40:47]               , //RMT2
                              sspr_spr_wd[48:55]               , //RMT1
                              sspr_spr_wd[56:63]               }; //RMT0

	assign xucr2_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              xucr2_q[32:39]                   , //RMT3
                              xucr2_q[40:47]                   , //RMT2
                              xucr2_q[48:55]                   , //RMT1
                              xucr2_q[56:63]                   }; //RMT0
	// XUDBG0
	assign sspr_xudbg0_di  = { sspr_spr_wd[49:51]               , //WAY
                              sspr_spr_wd[52:57]               }; //ROW

	assign xudbg0_do       = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:48]                      , /////
                              xudbg0_q[55:57]                  , //WAY
                              xudbg0_q[58:63]                  , //ROW
                              tidn[58:61]                      , /////
                              1'b0                             , //EXEC
                              xudbg0_done_q                    }; //DONE
	// XUDBG1
	assign xudbg1_do       = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:44]                      , /////
                              spr_xudbg1_watch[0:3]            , //WATCH
                              spr_xudbg1_lru[0:6]              , //LRU
                              spr_xudbg1_parity[0:3]           , //PARITY
                              tidn[60:61]                      , /////
                              spr_xudbg1_lock                  , //LOCK
                              spr_xudbg1_valid                 }; //VALID
	// XUDBG2
	assign xudbg2_do       = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:32]                      , /////
                              spr_xudbg2_tag[33:63]            }; //TAG

	// Unused Signals
	assign unused_do_bits = |{
		dac1_do[0:64-`GPR_WIDTH]
		,dac2_do[0:64-`GPR_WIDTH]
		,dac3_do[0:64-`GPR_WIDTH]
		,dac4_do[0:64-`GPR_WIDTH]
		,dvc1_do[0:64-`GPR_WIDTH]
		,dvc2_do[0:64-`GPR_WIDTH]
		,lesr1_do[0:64-`GPR_WIDTH]
		,lesr2_do[0:64-`GPR_WIDTH]
		,lsucr0_do[0:64-`GPR_WIDTH]
		,pesr_do[0:64-`GPR_WIDTH]
		,xucr2_do[0:64-`GPR_WIDTH]
		,xudbg0_do[0:64-`GPR_WIDTH]
		,xudbg1_do[0:64-`GPR_WIDTH]
		,xudbg2_do[0:64-`GPR_WIDTH]
		};

generate
	if (a2mode == 1) begin : dac1_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) dac1_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dac1_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[dac1_offset:dac1_offset + `GPR_WIDTH - 1]),
        .scout(sov[dac1_offset:dac1_offset + `GPR_WIDTH - 1]),
        .din(dac1_d),
        .dout(dac1_q)
     );
	end
	if (a2mode == 0) begin : dac1_latch_tie
		assign dac1_q          = {`GPR_WIDTH{1'b0}};
	end
endgenerate
generate
	if (a2mode == 1) begin : dac2_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) dac2_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dac2_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[dac2_offset:dac2_offset + `GPR_WIDTH - 1]),
        .scout(sov[dac2_offset:dac2_offset + `GPR_WIDTH - 1]),
        .din(dac2_d),
        .dout(dac2_q)
     );
	end
	if (a2mode == 0) begin : dac2_latch_tie
		assign dac2_q          = {`GPR_WIDTH{1'b0}};
	end
endgenerate
     tri_ser_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) dac3_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dac3_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[dac3_offset:dac3_offset + `GPR_WIDTH - 1]),
        .scout(sov[dac3_offset:dac3_offset + `GPR_WIDTH - 1]),
        .din(dac3_d),
        .dout(dac3_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) dac4_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dac4_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[dac4_offset:dac4_offset + `GPR_WIDTH - 1]),
        .scout(sov[dac4_offset:dac4_offset + `GPR_WIDTH - 1]),
        .din(dac4_d),
        .dout(dac4_q)
     );
generate
	if (a2mode == 1) begin : dvc1_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) dvc1_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dvc1_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[dvc1_offset:dvc1_offset + `GPR_WIDTH - 1]),
        .scout(sov[dvc1_offset:dvc1_offset + `GPR_WIDTH - 1]),
        .din(dvc1_d),
        .dout(dvc1_q)
     );
	end
	if (a2mode == 0) begin : dvc1_latch_tie
		assign dvc1_q          = {`GPR_WIDTH{1'b0}};
	end
endgenerate
generate
	if (a2mode == 1) begin : dvc2_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) dvc2_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dvc2_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[dvc2_offset:dvc2_offset + `GPR_WIDTH - 1]),
        .scout(sov[dvc2_offset:dvc2_offset + `GPR_WIDTH - 1]),
        .din(dvc2_d),
        .dout(dvc2_q)
     );
	end
	if (a2mode == 0) begin : dvc2_latch_tie
		assign dvc2_q          = {`GPR_WIDTH{1'b0}};
	end
endgenerate
     tri_ser_rlmreg_p #(.WIDTH(24), .INIT(0), .NEEDS_SRESET(1)) lesr1_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(lesr1_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[lesr1_offset:lesr1_offset + 24 - 1]),
        .scout(sov[lesr1_offset:lesr1_offset + 24 - 1]),
        .din(lesr1_d),
        .dout(lesr1_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(24), .INIT(0), .NEEDS_SRESET(1)) lesr2_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(lesr2_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[lesr2_offset:lesr2_offset + 24 - 1]),
        .scout(sov[lesr2_offset:lesr2_offset + 24 - 1]),
        .din(lesr2_d),
        .dout(lesr2_q)
     );
     //wtf set dfwd=1 tri_ser_rlmreg_p #(.WIDTH(11), .INIT(1848), .NEEDS_SRESET(1)) lsucr0_latch(
     tri_ser_rlmreg_p #(.WIDTH(11), .INIT(1852), .NEEDS_SRESET(1)) lsucr0_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(lsucr0_act),
        .force_t(ccfg_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(ccfg_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv_ccfg[lsucr0_offset_ccfg:lsucr0_offset_ccfg + 11 - 1]),
        .scout(sov_ccfg[lsucr0_offset_ccfg:lsucr0_offset_ccfg + 11 - 1]),
        .din(lsucr0_d),
        .dout(lsucr0_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) pesr_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(pesr_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[pesr_offset:pesr_offset + 32 - 1]),
        .scout(sov[pesr_offset:pesr_offset + 32 - 1]),
        .din(pesr_d),
        .dout(pesr_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) xucr2_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(xucr2_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[xucr2_offset:xucr2_offset + 32 - 1]),
        .scout(sov[xucr2_offset:xucr2_offset + 32 - 1]),
        .din(xucr2_d),
        .dout(xucr2_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(9), .INIT(0), .NEEDS_SRESET(1)) xudbg0_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(xudbg0_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[xudbg0_offset:xudbg0_offset + 9 - 1]),
        .scout(sov[xudbg0_offset:xudbg0_offset + 9 - 1]),
        .din(xudbg0_d),
        .dout(xudbg0_q)
     );


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xudbg0_done_reg(
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
   .scin(siv[xudbg0_done_offset]),
   .scout(sov[xudbg0_done_offset]),
   .din(xudbg0_done_d),
   .dout(xudbg0_done_q)
);

// Latch Instances

tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) exx_act_latch(
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
   .scin(siv[exx_act_offset:exx_act_offset + 2 - 1]),
   .scout(sov[exx_act_offset:exx_act_offset + 2 - 1]),
   .din(exx_act_d),
   .dout(exx_act_q)
);

tri_regk #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex3_dac12m_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(exx_act[2]),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_dac12m_offset:ex3_dac12m_offset + 8 - 1]),
   .scout(sov[ex3_dac12m_offset:ex3_dac12m_offset + 8 - 1]),
   .din(ex3_dac12m_d),
   .dout(ex3_dac12m_q)
);

tri_regk #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex3_dac34m_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(exx_act[2]),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_dac34m_offset:ex3_dac34m_offset + 8 - 1]),
   .scout(sov[ex3_dac34m_offset:ex3_dac34m_offset + 8 - 1]),
   .din(ex3_dac34m_d),
   .dout(ex3_dac34m_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_is_any_load_dac_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(exx_act[2]),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_is_any_load_dac_offset]),
   .scout(sov[ex3_is_any_load_dac_offset]),
   .din(ex2_is_any_load_dac),
   .dout(ex3_is_any_load_dac_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_is_any_store_dac_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(exx_act[2]),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_is_any_store_dac_offset]),
   .scout(sov[ex3_is_any_store_dac_offset]),
   .din(ex2_is_any_store_dac),
   .dout(ex3_is_any_store_dac_q)
);

tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex4_dacrw_cmpr_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(exx_act[3]),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_dacrw_cmpr_offset:ex4_dacrw_cmpr_offset + 4 - 1]),
   .scout(sov[ex4_dacrw_cmpr_offset:ex4_dacrw_cmpr_offset + 4 - 1]),
   .din(ex4_dacrw_cmpr_d),
   .dout(ex4_dacrw_cmpr_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex2_val_latch(
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
   .scin(siv[ex2_val_offset:ex2_val_offset + `THREADS - 1]),
   .scout(sov[ex2_val_offset:ex2_val_offset + `THREADS - 1]),
   .din(ex1_val),
   .dout(ex2_val_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_val_latch(
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
   .scin(siv[ex3_val_offset:ex3_val_offset + `THREADS - 1]),
   .scout(sov[ex3_val_offset:ex3_val_offset + `THREADS - 1]),
   .din(ex2_val),
   .dout(ex3_val_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_val_latch(
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
   .scin(siv[ex4_val_offset:ex4_val_offset + `THREADS - 1]),
   .scout(sov[ex4_val_offset:ex4_val_offset + `THREADS - 1]),
   .din(ex3_val),
   .dout(ex4_val_q)
);
generate begin : dbcr0_dac1
      genvar                     tid;
      for (tid = 0; tid <= `THREADS - 1; tid = tid + 1) begin : dbcr0_dac1

         tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) dbcr0_dac1_latch(
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
            .scin(siv[dbcr0_dac1_offset + 2 * tid:dbcr0_dac1_offset + 2 * (tid + 1) - 1]),
            .scout(sov[dbcr0_dac1_offset + 2 * tid:dbcr0_dac1_offset + 2 * (tid + 1) - 1]),
            .din(spr_dbcr0_dac1[tid*2:tid*2+1]),
            .dout(dbcr0_dac1_q[tid])
         );
      end
   end
endgenerate
generate begin : dbcr0_dac2
      genvar                     tid;
      for (tid = 0; tid <= `THREADS - 1; tid = tid + 1) begin : dbcr0_dac2

         tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) dbcr0_dac2_latch(
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
            .scin(siv[dbcr0_dac2_offset + 2 * tid:dbcr0_dac2_offset + 2 * (tid + 1) - 1]),
            .scout(sov[dbcr0_dac2_offset + 2 * tid:dbcr0_dac2_offset + 2 * (tid + 1) - 1]),
            .din(spr_dbcr0_dac2[tid*2:tid*2+1]),
            .dout(dbcr0_dac2_q[tid])
         );
      end
end
endgenerate
generate begin : dbcr0_dac3
      genvar                     tid;
      for (tid = 0; tid <= `THREADS - 1; tid = tid + 1) begin : dbcr0_dac3

         tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) dbcr0_dac3_latch(
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
            .scin(siv[dbcr0_dac3_offset + 2 * tid:dbcr0_dac3_offset + 2 * (tid + 1) - 1]),
            .scout(sov[dbcr0_dac3_offset + 2 * tid:dbcr0_dac3_offset + 2 * (tid + 1) - 1]),
            .din(spr_dbcr0_dac3[tid*2:tid*2+1]),
            .dout(dbcr0_dac3_q[tid])
         );
      end
end
endgenerate
generate begin : dbcr0_dac4
      genvar                     tid;
      for (tid = 0; tid <= `THREADS - 1; tid = tid + 1) begin : dbcr0_dac4

         tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) dbcr0_dac4_latch(
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
            .scin(siv[dbcr0_dac4_offset + 2 * tid:dbcr0_dac4_offset + 2 * (tid + 1) - 1]),
            .scout(sov[dbcr0_dac4_offset + 2 * tid:dbcr0_dac4_offset + 2 * (tid + 1) - 1]),
            .din(spr_dbcr0_dac4[tid*2:tid*2+1]),
            .dout(dbcr0_dac4_q[tid])
         );
      end
end
endgenerate

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) dbcr2_dvc1m_on_latch(
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
   .scin(siv[dbcr2_dvc1m_on_offset:dbcr2_dvc1m_on_offset + `THREADS - 1]),
   .scout(sov[dbcr2_dvc1m_on_offset:dbcr2_dvc1m_on_offset + `THREADS - 1]),
   .din(dbcr2_dvc1m_on_d),
   .dout(dbcr2_dvc1m_on_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) dbcr2_dvc2m_on_latch(
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
   .scin(siv[dbcr2_dvc2m_on_offset:dbcr2_dvc2m_on_offset + `THREADS - 1]),
   .scout(sov[dbcr2_dvc2m_on_offset:dbcr2_dvc2m_on_offset + `THREADS - 1]),
   .din(dbcr2_dvc2m_on_d),
   .dout(dbcr2_dvc2m_on_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) msr_ds_latch(
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
   .scin(siv[msr_ds_offset:msr_ds_offset + `THREADS - 1]),
   .scout(sov[msr_ds_offset:msr_ds_offset + `THREADS - 1]),
   .din(spr_msr_ds),
   .dout(msr_ds_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) msr_pr_latch(
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
   .scin(siv[msr_pr_offset:msr_pr_offset + `THREADS - 1]),
   .scout(sov[msr_pr_offset:msr_pr_offset + `THREADS - 1]),
   .din(spr_msr_pr),
   .dout(msr_pr_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) msr_gs_latch(
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
   .scin(siv[msr_gs_offset:msr_gs_offset + `THREADS - 1]),
   .scout(sov[msr_gs_offset:msr_gs_offset + `THREADS - 1]),
   .din(spr_msr_gs),
   .dout(msr_gs_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_data_val_reg(
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
   .scin(siv[ex4_data_val_offset]),
   .scout(sov[ex4_data_val_offset]),
   .din(ex3_data_val),
   .dout(ex4_data_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dvc1_act_reg(
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
   .scin(siv[dvc1_act_offset]),
   .scout(sov[dvc1_act_offset]),
   .din(dvc1_act_d),
   .dout(dvc1_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dvc2_act_reg(
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
   .scin(siv[dvc2_act_offset]),
   .scout(sov[dvc2_act_offset]),
   .din(dvc2_act_d),
   .dout(dvc2_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xudbg0_inprog_reg(
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
   .scin(siv[xudbg0_inprog_offset]),
   .scout(sov[xudbg0_inprog_offset]),
   .din(xudbg0_inprog_d),
   .dout(xudbg0_inprog_q)
);

assign siv[0:scan_right - 1] = {sov[1:scan_right - 1], scan_in};
assign scan_out = sov[0];

assign siv_ccfg[0:scan_right_ccfg - 1] = {sov_ccfg[1:scan_right_ccfg - 1], ccfg_scan_in};
assign ccfg_scan_out = sov_ccfg[0];

endmodule
