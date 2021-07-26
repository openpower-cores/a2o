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
//  Description: Generic Local FIR Component
//
//*****************************************************************************

module pcq_local_fir2(
// Include model build parameters
`include "tri_a2o.vh"

   nclk,
   vdd,
   gnd,
   lcb_clkoff_dc_b,
   lcb_mpw1_dc_b,
   lcb_mpw2_dc_b,
   lcb_delay_lclkr_dc,
   lcb_act_dis_dc,
   lcb_sg_0,
   lcb_func_slp_sl_thold_0,
   lcb_cfg_slp_sl_thold_0,
   mode_scan_siv,
   mode_scan_sov,
   func_scan_siv,
   func_scan_sov,
   sys_xstop_in,
   error_in,
   xstop_err,
   recov_err,
   lxstop_mchk,
   trace_error,
   recov_reset,
   fir_out,
   act0_out,
   act1_out,
   mask_out,
   sc_parity_error_inject,
   sc_active,
   sc_wr_q,
   sc_addr_v,
   sc_wdata,
   sc_rdata,
   fir_parity_check
);

   parameter                      WIDTH = 1;			// this must be >=1 and <=64
   parameter                      IMPL_LXSTOP_MCHK = 1'b1;	// generate local checkstop /machine check output
   parameter                      USE_RECOV_RESET = 1'b0;	// this adds a reset feature without the second wof register.
   parameter [0:WIDTH-1]          FIR_INIT = 1'b0;		// init value for fir register; length = width !
   parameter [0:WIDTH-1]          FIR_MASK_INIT = 1'b0;		// init value for fir mask register; length = width !
   parameter                      FIR_MASK_PAR_INIT = 1'b0;	// init value for fir mask register even parity
   parameter [0:WIDTH-1]          FIR_ACTION0_INIT = 1'b0;	// init value for fir action0 register; length = width !
   parameter                      FIR_ACTION0_PAR_INIT = 1'b0;	// init value for fir action0 register even parity
   parameter [0:WIDTH-1]          FIR_ACTION1_INIT = 1'b0;	// init value for fir action1 register; length = width !
   parameter                      FIR_ACTION1_PAR_INIT = 1'b0;	// init value for fir action1 register even parity

//=====================================================================
// Port Definitions
//=====================================================================
   //  Global lines for clocking and scan control
   input  [0:`NCLK_WIDTH-1]       nclk;
   inout                          vdd;
   inout                          gnd;
   input                          lcb_clkoff_dc_b;		//from lcb_cntl external to component
   input                          lcb_mpw1_dc_b;		//from lcb_cntl external to component
   input                          lcb_mpw2_dc_b;		//from lcb_cntl external to component
   input                          lcb_delay_lclkr_dc;		//from lcb_cntl external to component
   input                          lcb_act_dis_dc;		//from lcb_cntl external to component
   input                          lcb_sg_0;
   input                          lcb_func_slp_sl_thold_0;
   input                          lcb_cfg_slp_sl_thold_0;
   input  [0:3*(WIDTH+1)+WIDTH-1] mode_scan_siv;		// scan vector in
   output [0:3*(WIDTH+1)+WIDTH-1] mode_scan_sov;		// scan vector out
   input  [0:4]                   func_scan_siv;		// scan vector in
   output [0:4]                   func_scan_sov;		// scan vector out
   // External interface
   input                          sys_xstop_in;			// freeze FIR on system checkstop from chip GEM
   input  [0:WIDTH-1]             error_in;			// needs to be directly off a latch for timing
   output                         xstop_err;			// checkstop   output to Global FIR
   output                         recov_err;			// recoverable output to Global FIR
   output                         lxstop_mchk;			// use ONLY if IMPL_LXSTOP_MCHK = true
   output                         trace_error;			// connect to error_input of closest trdata macro
   input                          recov_reset;			// only needed if USE_RECOV_RESET = true
   output [0:WIDTH-1]             fir_out;			    // output of current FIR state if needed
   output [0:WIDTH-1]             act0_out;			// output of current FIR Act0 state if needed
   output [0:WIDTH-1]             act1_out;			// output of current FIR Act1 state if needed
   output [0:WIDTH-1]             mask_out;			// output of current FIR Mask state if needed
   // SCOM register connections
   input                          sc_parity_error_inject;	// Force parity error
   input                          sc_active;
   input                          sc_wr_q;
   input  [0:8]                   sc_addr_v;
   input  [0:WIDTH-1]             sc_wdata;
   output [0:WIDTH-1]             sc_rdata;
   output [0:2]                   fir_parity_check;		// Action0, Action1, Mask reg parity checks

//=====================================================================
// Signal Declarations
//=====================================================================
   // Clocks
   wire                           func_d1clk;
   wire                           func_d2clk;
   wire  [0:`NCLK_WIDTH-1]        func_lclk;
   wire                           mode_d1clk;
   wire                           mode_d2clk;
   wire  [0:`NCLK_WIDTH-1]        mode_lclk;
   wire                           scom_mode_d1clk;
   wire                           scom_mode_d2clk;
   wire  [0:`NCLK_WIDTH-1]	  scom_mode_lclk;
   wire                           func_thold_b;
   wire                           func_force;
   wire                           mode_thold_b;
   wire                           mode_force;
   // FIR regs
   wire [0:WIDTH-1]               data_ones;
   wire [0:WIDTH-1]               or_fir;
   wire [0:WIDTH-1]               and_fir;
   wire [0:WIDTH-1]               or_mask;
   wire [0:WIDTH-1]               and_mask;
   wire [0:WIDTH-1]               fir_mask_in;
   wire [0:WIDTH-1]               fir_mask_lt;
   wire [0:WIDTH-1]               masked;
   wire                           fir_mask_par_in;
   wire                           fir_mask_par_lt;
   wire                           fir_mask_par_err;
   wire [0:WIDTH-1]               fir_action0_in;
   wire [0:WIDTH-1]               fir_action0_lt;
   wire                           fir_action0_par_in;
   wire                           fir_action0_par_lt;
   wire                           fir_action0_par_err;
   wire [0:WIDTH-1]               fir_action1_in;
   wire [0:WIDTH-1]               fir_action1_lt;
   wire                           fir_action1_par_in;
   wire                           fir_action1_par_lt;
   wire                           fir_action1_par_err;
   wire [0:WIDTH-1]               fir_reset;
   wire [0:WIDTH-1]               error_input;
   wire [0:WIDTH-1]               fir_error_in_reef;
   wire [0:WIDTH-1]               fir_in;
   wire [0:WIDTH-1]               fir_lt;
   wire                           fir_act;
   wire                           block_fir;
   wire                           or_fir_load;
   wire                           and_fir_ones;
   wire                           and_fir_load;
   wire                           or_mask_load;
   wire                           and_mask_ones;
   wire                           and_mask_load;
   // Error report
   wire                           sys_xstop_lt;
   wire                           recov_in;
   wire                           recov_lt;
   wire                           xstop_in;
   wire                           xstop_lt;
   wire                           trace_error_in;
   wire                           trace_error_lt;
   // Other
   wire                           tieup;
   // Scan chain hookups
   wire [0:3*(WIDTH+1)+WIDTH-1]   mode_si;
   wire [0:3*(WIDTH+1)+WIDTH-1]   mode_so;
   wire [0:4]                     func_si;
   wire [0:4]                     func_so;

// Get rid of sinkless net messages
// synopsys translate_off
(* analysis_not_referenced="true" *)
// synopsys translate_on
   wire                           unused_signals;
   assign unused_signals = recov_reset | sc_addr_v[5];


   assign tieup = 1'b1;
   assign data_ones = {WIDTH {1'b1}};

//******************************************************
//* LCB driver, LCB and Register Instantiations
//******************************************************
   // functional ring regs; NOT power managed
   tri_lcbor  func_lcbor(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(lcb_func_slp_sl_thold_0),
      .sg(lcb_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(func_force),
      .thold_b(func_thold_b)
   );

   tri_lcbnd  func_lcb(
      .act(tieup),				// not power managed
      .vd(vdd),
      .gd(gnd),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .nclk(nclk),
      .force_t(func_force),
      .sg(lcb_sg_0),
      .thold_b(func_thold_b),
      .d1clk(func_d1clk),
      .d2clk(func_d2clk),
      .lclk(func_lclk)
   );


   // config ring regs; NOT power managed
   tri_lcbor  mode_lcbor(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(lcb_cfg_slp_sl_thold_0),
      .sg(lcb_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(mode_force),
      .thold_b(mode_thold_b)
   );

   assign fir_act = sc_active | (|error_in);

   tri_lcbnd  mode_lcb(
      .act(fir_act),			// active during scom access or FIR error input
      .vd(vdd),
      .gd(gnd),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .nclk(nclk),
      .force_t(mode_force),
      .sg(lcb_sg_0),
      .thold_b(mode_thold_b),
      .d1clk(mode_d1clk),
      .d2clk(mode_d2clk),
      .lclk(mode_lclk)
   );

   tri_lcbnd  scom_mode_lcb(
      .act(sc_active),		// active during scom access
      .vd(vdd),
      .gd(gnd),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .nclk(nclk),
      .force_t(mode_force),
      .sg(lcb_sg_0),
      .thold_b(mode_thold_b),
      .d1clk(scom_mode_d1clk),
      .d2clk(scom_mode_d2clk),
      .lclk(scom_mode_lclk)
   );

   //--------------------------------------------------------------------
   // Mode Registers
   //--------------------------------------------------------------------
   tri_nlat_scan #(.WIDTH(WIDTH), .INIT(FIR_ACTION0_INIT)) fir_action0(
      .vd(vdd),
      .gd(gnd),
      .d1clk(scom_mode_d1clk),
      .d2clk(scom_mode_d2clk),
      .lclk(scom_mode_lclk),
      .scan_in( mode_si[0:WIDTH - 1]),
      .scan_out(mode_so[0:WIDTH - 1]),
      .din(fir_action0_in),
      .q(fir_action0_lt)
   );

   tri_nlat_scan #(.WIDTH(1), .INIT(FIR_ACTION0_PAR_INIT)) fir_action0_par(
      .vd(vdd),
      .gd(gnd),
      .d1clk(scom_mode_d1clk),
      .d2clk(scom_mode_d2clk),
      .lclk(scom_mode_lclk),
      .scan_in( mode_si[WIDTH:WIDTH]),
      .scan_out(mode_so[WIDTH:WIDTH]),
      .din(fir_action0_par_in),
      .q(fir_action0_par_lt)
   );

   tri_nlat_scan #(.WIDTH(WIDTH), .INIT(FIR_ACTION1_INIT)) fir_action1(
      .vd(vdd),
      .gd(gnd),
      .d1clk(scom_mode_d1clk),
      .d2clk(scom_mode_d2clk),
      .lclk(scom_mode_lclk),
      .scan_in( mode_si[(WIDTH + 1):(2*WIDTH)]),
      .scan_out(mode_so[(WIDTH + 1):(2*WIDTH)]),
      .din(fir_action1_in),
      .q(fir_action1_lt)
   );

   tri_nlat_scan #(.WIDTH(1), .INIT(FIR_ACTION1_PAR_INIT)) fir_action1_par(
      .vd(vdd),
      .gd(gnd),
      .d1clk(scom_mode_d1clk),
      .d2clk(scom_mode_d2clk),
      .lclk(scom_mode_lclk),
      .scan_in( mode_si[(2*WIDTH + 1):(2*WIDTH + 1)]),
      .scan_out(mode_so[(2*WIDTH + 1):(2*WIDTH + 1)]),
      .din(fir_action1_par_in),
      .q(fir_action1_par_lt)
   );

   tri_nlat_scan #(.WIDTH(WIDTH), .INIT(FIR_MASK_INIT)) fir_mask(
      .vd(vdd),
      .gd(gnd),
      .d1clk(scom_mode_d1clk),
      .d2clk(scom_mode_d2clk),
      .lclk(scom_mode_lclk),
      .scan_in( mode_si[(2*WIDTH + 2):(3*WIDTH + 1)]),
      .scan_out(mode_so[(2*WIDTH + 2):(3*WIDTH + 1)]),
      .din(fir_mask_in),
      .q(fir_mask_lt)
   );

   tri_nlat_scan #(.WIDTH(1), .INIT(FIR_MASK_PAR_INIT)) fir_mask_par(
      .vd(vdd),
      .gd(gnd),
      .d1clk(scom_mode_d1clk),
      .d2clk(scom_mode_d2clk),
      .lclk(scom_mode_lclk),
      .scan_in( mode_si[(3*WIDTH + 2):(3*WIDTH + 2)]),
      .scan_out(mode_so[(3*WIDTH + 2):(3*WIDTH + 2)]),
      .din(fir_mask_par_in),
      .q(fir_mask_par_lt)
   );

   tri_nlat_scan #(.WIDTH(WIDTH), .INIT(FIR_INIT)) fir(
      .vd(vdd),
      .gd(gnd),
      .d1clk(mode_d1clk),
      .d2clk(mode_d2clk),
      .lclk(mode_lclk),
      .scan_in( mode_si[(3*WIDTH + 3):(4*WIDTH + 2)]),
      .scan_out(mode_so[(3*WIDTH + 3):(4*WIDTH + 2)]),
      .din(fir_in),
      .q(fir_lt)
   );


   //--------------------------------------------------------------------
   // Func Registers with no power savings
   //--------------------------------------------------------------------
   tri_nlat #(.WIDTH(1), .INIT(1'b0)) sys_xstop(
      .vd(vdd),
      .gd(gnd),
      .d1clk(func_d1clk),
      .d2clk(func_d2clk),
      .lclk(func_lclk),
      .scan_in(func_si[1]),
      .scan_out(func_so[1]),
      .din(sys_xstop_in),
      .q(sys_xstop_lt)
   );

   tri_nlat #(.WIDTH(1), .INIT(1'b0)) recov(
      .vd(vdd),
      .gd(gnd),
      .d1clk(func_d1clk),
      .d2clk(func_d2clk),
      .lclk(func_lclk),
      .scan_in(func_si[2]),
      .scan_out(func_so[2]),
      .din(recov_in),
      .q(recov_lt)
   );

   tri_nlat #(.WIDTH(1), .INIT(1'b0)) xstop(
      .vd(vdd),
      .gd(gnd),
      .d1clk(func_d1clk),
      .d2clk(func_d2clk),
      .lclk(func_lclk),
      .scan_in(func_si[3]),
      .scan_out(func_so[3]),
      .din(xstop_in),
      .q(xstop_lt)
   );

   tri_nlat #(.WIDTH(1), .INIT(1'b0)) trace_err(
      .vd(vdd),
      .gd(gnd),
      .d1clk(func_d1clk),
      .d2clk(func_d2clk),
      .lclk(func_lclk),
      .scan_in(func_si[4]),
      .scan_out(func_so[4]),
      .din(trace_error_in),
      .q(trace_error_lt)
   );


//******************************************************
//* Optional Recovery Reset
//******************************************************
   generate
      if (USE_RECOV_RESET == 1'b1)
      begin : use_recov_reset_yes
         assign fir_reset = (~({WIDTH {recov_reset}} & (~fir_action0_lt) & fir_action1_lt));
      end
   endgenerate

   generate
      if (USE_RECOV_RESET == 1'b0)
      begin : use_recov_reset_no
         assign fir_reset = {WIDTH {1'b1}};
      end
   endgenerate

//******************************************************
//* FIR
//******************************************************
   // write to x'0' to write FIR directly
   // write to x'1' to And-Mask FIR
   // write to x'2' to Or-Mask FIR
   assign or_fir_load  =    (sc_addr_v[0] | sc_addr_v[2]) & sc_wr_q;
   assign and_fir_ones = (~((sc_addr_v[0] | sc_addr_v[1]) & sc_wr_q));
   assign and_fir_load =     sc_addr_v[1] & sc_wr_q;

   assign or_fir  = ({WIDTH {or_fir_load}} & sc_wdata);
   assign and_fir = ({WIDTH {and_fir_load}} & sc_wdata) | ({WIDTH {and_fir_ones}} & data_ones);


   assign fir_in = ({WIDTH {~block_fir}} & error_input) | or_fir | (fir_lt & and_fir & fir_reset);


   assign fir_error_in_reef = error_in;		// does a signal rename for the reef tool
   assign error_input = fir_error_in_reef;

//******************************************************
//* FIR Mask
//******************************************************
   // write to x'6' to write FIR-MASK directly
   // write to x'7' to And-Mask FIR-MASK
   // write to x'8' to Or-Mask FIR-MASK
   assign or_mask_load  =    (sc_addr_v[6] | sc_addr_v[8]) & sc_wr_q;
   assign and_mask_ones = (~((sc_addr_v[6] | sc_addr_v[7]) & sc_wr_q));
   assign and_mask_load =     sc_addr_v[7] & sc_wr_q;

   assign or_mask  = ({WIDTH {or_mask_load}} & sc_wdata);
   assign and_mask = ({WIDTH {and_mask_load}} & sc_wdata) | ({WIDTH {and_mask_ones}} & data_ones);


   assign fir_mask_in = or_mask | (fir_mask_lt & and_mask);

   assign fir_mask_par_in = ((sc_wr_q & (|sc_addr_v[6:8])) == 1'b1) ? (^fir_mask_in) : fir_mask_par_lt;

   assign fir_mask_par_err = ((^fir_mask_lt) ^ fir_mask_par_lt) | (sc_wr_q & (|sc_addr_v[6:8]) & sc_parity_error_inject);

   assign masked = fir_mask_lt;

//******************************************************
//* Action Registers
//******************************************************
   // write to x'3' to write FIR-Action0 directly
   assign fir_action0_in = ((sc_wr_q & sc_addr_v[3]) == 1'b1) ? sc_wdata : fir_action0_lt;

   assign fir_action0_par_in = ((sc_wr_q & sc_addr_v[3]) == 1'b1) ? (^fir_action0_in) : fir_action0_par_lt;

   assign fir_action0_par_err = ((^fir_action0_lt) ^ fir_action0_par_lt) | (sc_wr_q & sc_addr_v[3] & sc_parity_error_inject);


   // write to x'4' to write FIR-Action1 directly
   assign fir_action1_in = ((sc_wr_q & sc_addr_v[4]) == 1'b1) ? sc_wdata : fir_action1_lt;

   assign fir_action1_par_in = ((sc_wr_q & sc_addr_v[4]) == 1'b1) ? (^fir_action1_in) : fir_action1_par_lt;

   assign fir_action1_par_err = ((^fir_action1_lt) ^ fir_action1_par_lt) | (sc_wr_q & sc_addr_v[4] & sc_parity_error_inject);

//******************************************************
//* Summary
//******************************************************
   assign xstop_in = (|(fir_lt &   fir_action0_lt  & (~fir_action1_lt) & (~masked)));	// fir_action = 10
   assign recov_in = (|(fir_lt & (~fir_action0_lt) &   fir_action1_lt  & (~masked)));	// fir_action = 01

   assign block_fir = xstop_lt | sys_xstop_lt;

   assign xstop_err = xstop_lt;
   assign recov_err = recov_lt;
   assign trace_error = trace_error_lt;

   assign fir_out  = fir_lt;
   assign act0_out = fir_action0_lt;
   assign act1_out = fir_action1_lt;
   assign mask_out = fir_mask_lt;

   assign fir_parity_check = {fir_action0_par_err, fir_action1_par_err, fir_mask_par_err};

//******************************************************
//* SCOM read logic
//******************************************************
   assign sc_rdata =  ({WIDTH {sc_addr_v[0]}} & fir_lt)		|
                      ({WIDTH {sc_addr_v[3]}} & fir_action0_lt)	|
                      ({WIDTH {sc_addr_v[4]}} & fir_action1_lt)	|
                      ({WIDTH {sc_addr_v[6]}} & fir_mask_lt)	;

//******************************************************
//* Optional MCHK Enable Register and Output
//******************************************************
   generate
      if (IMPL_LXSTOP_MCHK == 1'b1)
      begin : mchkgen
         wire		lxstop_mchk_in;
         wire		lxstop_mchk_lt;

         assign lxstop_mchk_in = (|(fir_lt & fir_action0_lt & fir_action1_lt & (~masked)));	// fir_action = 11
         assign lxstop_mchk = lxstop_mchk_lt;

         assign trace_error_in = xstop_in | recov_in | lxstop_mchk_in;

         tri_nlat #(.WIDTH(1), .INIT(1'b0)) mchk(
            .d1clk(func_d1clk),
            .vd(vdd),
            .gd(gnd),
            .lclk(func_lclk),
            .d2clk(func_d2clk),
            .scan_in(func_si[0]),
            .scan_out(func_so[0]),
            .din(lxstop_mchk_in),
            .q(lxstop_mchk_lt)
         );
      end
   endgenerate

   generate
      if (IMPL_LXSTOP_MCHK == 1'b0)
      begin : nomchk
         assign trace_error_in = xstop_in | recov_in;
         assign lxstop_mchk = 1'b0;
         assign func_so[0] = func_si[0];
      end
   endgenerate

//******************************************************
// Scan Chain Connections
//******************************************************
   assign mode_si = mode_scan_siv;
   assign mode_scan_sov = mode_so;

   assign func_si = func_scan_siv;
   assign func_scan_sov = func_so;


endmodule
