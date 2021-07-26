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
//  Description: Pervasive Core Thread Controls
//
//*****************************************************************************

module pcq_ctrl(
// Include model build parameters
`include "tri_a2o.vh"

   inout			vdd,
   inout			gnd,
   input  [0:`NCLK_WIDTH-1] 	nclk,
   input			scan_dis_dc_b,
   input			lcb_clkoff_dc_b,
   input			lcb_mpw1_dc_b,
   input			lcb_mpw2_dc_b,
   input			lcb_delay_lclkr_dc,
   input			lcb_act_dis_dc,
   input			pc_pc_func_slp_sl_thold_0,
   input			pc_pc_sg_0,
   input			func_scan_in,
   output			func_scan_out,
   // Reset Related
   output			pc_lq_init_reset,
   output			pc_iu_init_reset,
   output			ct_rg_hold_during_init,
   // Power Management
   output [0:`THREADS-1]	ct_rg_power_managed,
   output			ac_an_power_managed,
   output			ac_an_rvwinkle_mode,
   output			pc_xu_pm_hold_thread,
   output			ct_ck_pm_ccflush_disable,
   output			ct_ck_pm_raise_tholds,
   input			rg_ct_dis_pwr_savings,
   input  [0:1]			xu_pc_spr_ccr0_pme,
   input  [0:`THREADS-1]	xu_pc_spr_ccr0_we,
   // Trace/Trigger Signals
   output [0:14]		dbg_ctrls
);


//=====================================================================
// Signal Declarations
//=====================================================================
   parameter                   INITACTIVE_SIZE = 1;
   parameter                   HOLDCNTR_SIZE = 3;
   parameter                   INITCNTR_SIZE = 9;
   parameter                   INITERAT_SIZE = 1;
   parameter                   PMCTRLS_T0_SIZE = 15;
   parameter                   PMCTRLS_T1_SIZE = 2 * (`THREADS - 1);
   parameter                   SPARECTRL_SIZE = 6;

   //---------------------------------------------------------------------
   // Scan Ring Ordering:
   // start of func scan chain ordering
   parameter                   	INITACTIVE_OFFSET = 0;
   parameter                   	HOLDCNTR_OFFSET = INITACTIVE_OFFSET + INITACTIVE_SIZE;
   parameter                   	INITCNTR_OFFSET = HOLDCNTR_OFFSET + HOLDCNTR_SIZE;
   parameter                   	INITERAT_OFFSET = INITCNTR_OFFSET + INITCNTR_SIZE;
   parameter                   	PMCTRLS_T0_OFFSET = INITERAT_OFFSET + INITERAT_SIZE;
   parameter                   	PMCTRLS_T1_OFFSET = PMCTRLS_T0_OFFSET + PMCTRLS_T0_SIZE;
   parameter                   	SPARECTRL_OFFSET = PMCTRLS_T1_OFFSET + PMCTRLS_T1_SIZE;
   parameter                   	FUNC_RIGHT = SPARECTRL_OFFSET + SPARECTRL_SIZE - 1;
   // end of func scan chain ordering

   //---------------------------------------------------------------------
   // Array Initialization Controls:
   parameter 			HOLDCNT_IDLE  = 0;
   parameter 	        	HOLDCNT_DONE  = 7;
   parameter  	       		INITCNT_START = 15+(`INIT_BHT*496); // sets INITCNTR to 15 or 511
   parameter 	        	INITCNT_DONE  = 0;

   //---------------------------------------------------------------------
   // Basic/Misc signals
   wire                        tiup;
   wire [0:FUNC_RIGHT]         func_siv;
   wire [0:FUNC_RIGHT]         func_sov;
   wire                        pc_pc_func_slp_sl_thold_0_b;
   wire                        force_funcslp;
   // Reset Signals
   wire                        initcntr_enabled;
   // Power management Signals
   wire [0:1]                  spr_ccr0_pme_q;
   wire [0:`THREADS-1]         spr_ccr0_we_q;
   wire                        pm_sleep_enable;
   wire                        pm_rvw_enable;
   wire [0:`THREADS-1]         thread_stopped;
   wire                        pmstate_q_anded;
   // Latch definitions begin
   wire [0:HOLDCNTR_SIZE-1]    holdcntr_d;
   wire [0:HOLDCNTR_SIZE-1]    holdcntr_q;
   wire [0:INITCNTR_SIZE-1]    initcntr_d;
   wire [0:INITCNTR_SIZE-1]    initcntr_q;
   wire                        init_active_d;
   wire                        init_active_q;
   wire                        initerat_d;
   wire                        initerat_q;
   wire			       pmstate_enab;
   wire [0:`THREADS-1]         pmstate_d;
   wire [0:`THREADS-1]         pmstate_q;
   wire                        pmstate_all_d;
   wire                        pmstate_all_q;
   wire [0:7]                  pmclkctrl_dly_d;
   wire [0:7]                  pmclkctrl_dly_q;
   wire                        power_managed_d;
   wire                        power_managed_q;
   wire                        rvwinkled_d;
   wire                        rvwinkled_q;
   wire                        pm_ccflush_disable_int;
   wire                        pm_raise_tholds_int;
   wire [0:SPARECTRL_SIZE-1]   spare_ctrl_wrapped_q;


//!! Bugspray Include: pcq_ctrl;

   assign tiup = 1'b1;

//=====================================================================
// Reset State Machine
//=====================================================================
   // HOLDCNTR: Delays start of array initialization for 7 cycles.  Provides some time
   //           after clock start to ensure clock controls have propagated to LCBs. .
   assign holdcntr_d =  init_active_q == 1'b0		? HOLDCNT_IDLE  :
		        holdcntr_q == HOLDCNT_DONE 	? HOLDCNT_DONE  :
                        holdcntr_q + 3'b001;

   // Latch ACT control: Goes inactive once array initialization is over.
   assign initcntr_enabled = init_active_q | (|holdcntr_q);


   // INITCNTR: Initialized to a value; counts down while array init signal held active.
   //           Default time is 16 cycles, which is long enough for the ERATs to initialize.
   //           To initialize the BHT, the array init signal is kept active for 512 cycles.
   //           Controlled by `INIT_BHT (0=16 cycles; 1=512 cycles)
   assign initcntr_d =  holdcntr_q != HOLDCNT_DONE	? initcntr_q  :
		        initcntr_q == INITCNT_DONE 	? INITCNT_DONE  :
                        initcntr_q - 9'b000000001;


   // INITERAT:  The initerat latch controls the init_reset signals to IU and XU.
   // 		 Goes active when HOLDCNTR=7, and shuts off when INITCNTR counts down to 0.
   assign initerat_d = ( holdcntr_q < HOLDCNT_DONE-1)	? 1'b0 :
                       (|initcntr_q);


   // INIT_ACTIVE: init_active_q initializes to '1'; cleared after INITCNTR counts down to 0.
   assign init_active_d = (initcntr_q == INITCNT_DONE)	? 1'b0 :
                          init_active_q;


//=====================================================================
// Power Management Latches
//=====================================================================
// XU signals indicate when power-savings is enabled (sleep or rvw modes), and which
// THREADS are stopped.
// The pmstate latch tracks which THREADS are stopped when either power-savings mode
// is enabled.  The rvwinkled latch only when pm_rvw_enable is set.
// If all THREADS are stopped when power-savings is enabled, then signals to the
// clock control macro will initiate power savings actions.  These controls force
// ccflush_dc inactive to ensure all PLATs are clocking.  After a delay period, the
// run tholds will be raised to stop clocks.
// When coming out of power-savings, the tholds will be disabled prior to deactivating
// ccflush_dc.
   assign pm_sleep_enable = (~spr_ccr0_pme_q[0]) &   spr_ccr0_pme_q[1];
   assign pm_rvw_enable   =   spr_ccr0_pme_q[0]  & (~spr_ccr0_pme_q[1]);
   assign thread_stopped  =   spr_ccr0_we_q;


   assign pmstate_enab = (pm_sleep_enable | pm_rvw_enable) & (~initcntr_enabled);
   assign pmstate_d    = {`THREADS{pmstate_enab}} & thread_stopped[0:`THREADS - 1];

   //      Once all CCR0[WE] bits are set, pmstate_all_q is held active until pmclkctrl_dly_q(7).
   //      Forces an orderly sequence through PM controls, even if one thread wakes-up right away.
   assign pmstate_q_anded = (&pmstate_q);

   assign pmstate_all_d   = ((~pmclkctrl_dly_q[7]) & (pmstate_q_anded | pmstate_all_q)) |
                            (pmstate_q_anded & pmstate_all_q);

   assign power_managed_d =  pmstate_all_d | pmclkctrl_dly_q[6];
   assign rvwinkled_d     = (pmstate_all_d | pmclkctrl_dly_q[6]) & pm_rvw_enable;

   assign pmclkctrl_dly_d[0:7] = {pmstate_all_q, pmclkctrl_dly_q[0:6]};


//=====================================================================
// Outputs
//=====================================================================
   // Used as part of thread stop signal to XU.
   // Keeps THREADS stopped until after the Reset SM completes count.
   assign ct_rg_hold_during_init = init_active_q;

   // Init pulse to IU and XU to force initialization of IERAT, DERAT and BHT.
   // IU also holds instruction fetch until init signal released.
   assign pc_iu_init_reset = initerat_q;
   assign pc_lq_init_reset = initerat_q;

   // To THRCTL[Tx_PM]; indicates core power-managed via software actions.
   assign ct_rg_power_managed = pmstate_q[0:`THREADS - 1];

   // Core in rvwinkle power-savings state. L2 can prepare for Chiplet power-down.
   assign ac_an_rvwinkle_mode = rvwinkled_q;
   // Core in power-savings state due to any combination of power-savings instructions
   assign ac_an_power_managed = power_managed_q;
   assign pc_xu_pm_hold_thread = power_managed_q;

   // Goes to clock controls to disable plat flush controls
   assign pm_ccflush_disable_int   = pmstate_all_q | pmclkctrl_dly_q[7];
   assign ct_ck_pm_ccflush_disable = pm_ccflush_disable_int & (~rg_ct_dis_pwr_savings);
   // Goes to clock controls to activate run tholds
   assign pm_raise_tholds_int = pmstate_all_q & pmclkctrl_dly_q[7];
   assign ct_ck_pm_raise_tholds = pm_raise_tholds_int & (~rg_ct_dis_pwr_savings);


//=====================================================================
// Trace/Trigger Signals
//=====================================================================
   assign dbg_ctrls = { pmstate_q_anded,		// 0
			pmstate_all_q,			// 1
			power_managed_q,		// 2
                        rvwinkled_q,			// 3
                        pmclkctrl_dly_q[0:7],		// 4:11
                        rg_ct_dis_pwr_savings,		// 12
                        pm_ccflush_disable_int,		// 13
                        pm_raise_tholds_int		// 14
                      };


//=====================================================================
// Latches
//=====================================================================
   // func ring registers start
   tri_rlmlatch_p #(.INIT(1)) initactive(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_pc_func_slp_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ INITACTIVE_OFFSET]),
      .scout(func_sov[INITACTIVE_OFFSET]),
      .din(init_active_d),
      .dout(init_active_q)
   );

   tri_rlmreg_p #(.WIDTH(HOLDCNTR_SIZE), .INIT(0)) holdcntr(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(initcntr_enabled),
      .thold_b(pc_pc_func_slp_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ HOLDCNTR_OFFSET:HOLDCNTR_OFFSET + HOLDCNTR_SIZE - 1]),
      .scout(func_sov[HOLDCNTR_OFFSET:HOLDCNTR_OFFSET + HOLDCNTR_SIZE - 1]),
      .din(holdcntr_d),
      .dout(holdcntr_q)
   );

   tri_rlmreg_p #(.WIDTH(INITCNTR_SIZE), .INIT(INITCNT_START)) initcntr(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(initcntr_enabled),
      .thold_b(pc_pc_func_slp_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ INITCNTR_OFFSET:INITCNTR_OFFSET + INITCNTR_SIZE - 1]),
      .scout(func_sov[INITCNTR_OFFSET:INITCNTR_OFFSET + INITCNTR_SIZE - 1]),
      .din(initcntr_d),
      .dout(initcntr_q)
   );

   tri_rlmlatch_p #(.INIT(0)) initerat(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(initcntr_enabled),
      .thold_b(pc_pc_func_slp_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ INITERAT_OFFSET]),
      .scout(func_sov[INITERAT_OFFSET]),
      .din(initerat_d),
      .dout(initerat_q)
   );

   tri_rlmreg_p #(.WIDTH(PMCTRLS_T0_SIZE), .INIT(0)) pmctrls_t0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_pc_func_slp_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ PMCTRLS_T0_OFFSET:PMCTRLS_T0_OFFSET + PMCTRLS_T0_SIZE - 1]),
      .scout(func_sov[PMCTRLS_T0_OFFSET:PMCTRLS_T0_OFFSET + PMCTRLS_T0_SIZE - 1]),

      .din( {pmclkctrl_dly_d, xu_pc_spr_ccr0_pme, xu_pc_spr_ccr0_we[0], pmstate_d[0],
             pmstate_all_d,   rvwinkled_d,        power_managed_d}),

      .dout({pmclkctrl_dly_q, spr_ccr0_pme_q,     spr_ccr0_we_q[0],     pmstate_q[0],
             pmstate_all_q,   rvwinkled_q,        power_managed_q})
   );

   generate
      if (`THREADS > 1)
      begin : T1_pmctrls
         tri_rlmreg_p #(.WIDTH(PMCTRLS_T1_SIZE), .INIT(0)) pmctrls_t1(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(tiup),
            .thold_b(pc_pc_func_slp_sl_thold_0_b),
            .sg(pc_pc_sg_0),
            .force_t(force_funcslp),
            .delay_lclkr(lcb_delay_lclkr_dc),
            .mpw1_b(lcb_mpw1_dc_b),
            .mpw2_b(lcb_mpw2_dc_b),
            .scin(func_siv[ PMCTRLS_T1_OFFSET:PMCTRLS_T1_OFFSET + PMCTRLS_T1_SIZE - 1]),
            .scout(func_sov[PMCTRLS_T1_OFFSET:PMCTRLS_T1_OFFSET + PMCTRLS_T1_SIZE - 1]),
	    .din({xu_pc_spr_ccr0_we[1], pmstate_d[1]}),
	    .dout({spr_ccr0_we_q[1], pmstate_q[1]})
         );
      end
   endgenerate


   tri_rlmreg_p #(.WIDTH(SPARECTRL_SIZE), .INIT(0)) sparectrl(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_pc_func_slp_sl_thold_0_b),
      .sg(pc_pc_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ SPARECTRL_OFFSET:SPARECTRL_OFFSET + SPARECTRL_SIZE - 1]),
      .scout(func_sov[SPARECTRL_OFFSET:SPARECTRL_OFFSET + SPARECTRL_SIZE - 1]),
      .din(spare_ctrl_wrapped_q),
      .dout(spare_ctrl_wrapped_q)
   );
   // func ring registers end

//=====================================================================
// Thold/SG Staging
//=====================================================================
   // func_slp lcbor
   tri_lcbor  lcbor_funcslp(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(pc_pc_func_slp_sl_thold_0),
      .sg(pc_pc_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(force_funcslp),
      .thold_b(pc_pc_func_slp_sl_thold_0_b)
   );

//=====================================================================
// Scan Connections
//=====================================================================
   // Func ring
   assign func_siv[0:FUNC_RIGHT] = {func_scan_in, func_sov[0:FUNC_RIGHT - 1]};
   assign func_scan_out = func_sov[FUNC_RIGHT] & scan_dis_dc_b;


endmodule
