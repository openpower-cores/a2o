// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.




module pcq_ctrl(
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
   output			pc_lq_init_reset,
   output			pc_iu_init_reset,
   output			ct_rg_hold_during_init,
   output [0:`THREADS-1]	ct_rg_power_managed,
   output			ac_an_power_managed,
   output			ac_an_rvwinkle_mode,
   output			pc_xu_pm_hold_thread,
   output			ct_ck_pm_ccflush_disable,
   output			ct_ck_pm_raise_tholds,
   input			rg_ct_dis_pwr_savings,
   input  [0:1]			xu_pc_spr_ccr0_pme,
   input  [0:`THREADS-1]	xu_pc_spr_ccr0_we,
   output [0:14]		dbg_ctrls
);

   
   parameter                   INITACTIVE_SIZE = 1;
   parameter                   HOLDCNTR_SIZE = 3;
   parameter                   INITCNTR_SIZE = 9;
   parameter                   INITERAT_SIZE = 1;
   parameter                   PMCTRLS_T0_SIZE = 15;
   parameter                   PMCTRLS_T1_SIZE = 2 * (`THREADS - 1);
   parameter                   SPARECTRL_SIZE = 6;
   
   parameter                   	INITACTIVE_OFFSET = 0;
   parameter                   	HOLDCNTR_OFFSET = INITACTIVE_OFFSET + INITACTIVE_SIZE;
   parameter                   	INITCNTR_OFFSET = HOLDCNTR_OFFSET + HOLDCNTR_SIZE;
   parameter                   	INITERAT_OFFSET = INITCNTR_OFFSET + INITCNTR_SIZE;
   parameter                   	PMCTRLS_T0_OFFSET = INITERAT_OFFSET + INITERAT_SIZE;
   parameter                   	PMCTRLS_T1_OFFSET = PMCTRLS_T0_OFFSET + PMCTRLS_T0_SIZE;
   parameter                   	SPARECTRL_OFFSET = PMCTRLS_T1_OFFSET + PMCTRLS_T1_SIZE;
   parameter                   	FUNC_RIGHT = SPARECTRL_OFFSET + SPARECTRL_SIZE - 1;
   
   parameter 			HOLDCNT_IDLE  = 0;
   parameter 	        	HOLDCNT_DONE  = 7;
   parameter  	       		INITCNT_START = 15+(`INIT_BHT*496); 
   parameter 	        	INITCNT_DONE  = 0;
  
   wire                        tiup;
   wire [0:FUNC_RIGHT]         func_siv;
   wire [0:FUNC_RIGHT]         func_sov;
   wire                        pc_pc_func_slp_sl_thold_0_b;
   wire                        force_funcslp;
   wire                        initcntr_enabled;
   wire [0:1]                  spr_ccr0_pme_q;
   wire [0:`THREADS-1]         spr_ccr0_we_q;
   wire                        pm_sleep_enable;
   wire                        pm_rvw_enable;
   wire [0:`THREADS-1]         thread_stopped;
   wire                        pmstate_q_anded;	
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
   

   
   assign tiup = 1'b1;
   
   assign holdcntr_d =  init_active_q == 1'b0		? HOLDCNT_IDLE  : 
		        holdcntr_q == HOLDCNT_DONE 	? HOLDCNT_DONE  : 
                        holdcntr_q + 3'b001;

   assign initcntr_enabled = init_active_q | (|holdcntr_q);
   

   assign initcntr_d =  holdcntr_q != HOLDCNT_DONE	? initcntr_q  : 
		        initcntr_q == INITCNT_DONE 	? INITCNT_DONE  : 
                        initcntr_q - 9'b000000001;
  
   
   assign initerat_d = ( holdcntr_q < HOLDCNT_DONE-1)	? 1'b0 : 
                       (|initcntr_q);

   
   assign init_active_d = (initcntr_q == INITCNT_DONE)	? 1'b0 : 
                          init_active_q;

   
   assign pm_sleep_enable = (~spr_ccr0_pme_q[0]) &   spr_ccr0_pme_q[1];
   assign pm_rvw_enable   =   spr_ccr0_pme_q[0]  & (~spr_ccr0_pme_q[1]);
   assign thread_stopped  =   spr_ccr0_we_q;


   assign pmstate_enab = (pm_sleep_enable | pm_rvw_enable) & (~initcntr_enabled);
   assign pmstate_d    = {`THREADS{pmstate_enab}} & thread_stopped[0:`THREADS - 1];


   assign pmstate_q_anded = (&pmstate_q);
   
   assign pmstate_all_d   = ((~pmclkctrl_dly_q[7]) & (pmstate_q_anded | pmstate_all_q)) |
                            (pmstate_q_anded & pmstate_all_q);
   
   assign power_managed_d =  pmstate_all_d | pmclkctrl_dly_q[6];
   assign rvwinkled_d     = (pmstate_all_d | pmclkctrl_dly_q[6]) & pm_rvw_enable;
   
   assign pmclkctrl_dly_d[0:7] = {pmstate_all_q, pmclkctrl_dly_q[0:6]};

   
   assign ct_rg_hold_during_init = init_active_q;
   
   assign pc_iu_init_reset = initerat_q;
   assign pc_lq_init_reset = initerat_q;
   
   assign ct_rg_power_managed = pmstate_q[0:`THREADS - 1];
   
   assign ac_an_rvwinkle_mode = rvwinkled_q;
   assign ac_an_power_managed = power_managed_q;
   assign pc_xu_pm_hold_thread = power_managed_q;
   
   assign pm_ccflush_disable_int   = pmstate_all_q | pmclkctrl_dly_q[7];
   assign ct_ck_pm_ccflush_disable = pm_ccflush_disable_int & (~rg_ct_dis_pwr_savings);
   assign pm_raise_tholds_int = pmstate_all_q & pmclkctrl_dly_q[7];
   assign ct_ck_pm_raise_tholds = pm_raise_tholds_int & (~rg_ct_dis_pwr_savings);

   
   assign dbg_ctrls = { pmstate_q_anded,		
			pmstate_all_q,			
			power_managed_q,		
                        rvwinkled_q,			
                        pmclkctrl_dly_q[0:7],		
                        rg_ct_dis_pwr_savings,		
                        pm_ccflush_disable_int,		
                        pm_raise_tholds_int		
                      };

      
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
      
   tri_lcbor  lcbor_funcslp(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(pc_pc_func_slp_sl_thold_0),
      .sg(pc_pc_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(force_funcslp),
      .thold_b(pc_pc_func_slp_sl_thold_0_b)
   );
   
   assign func_siv[0:FUNC_RIGHT] = {func_scan_in, func_sov[0:FUNC_RIGHT - 1]};
   assign func_scan_out = func_sov[FUNC_RIGHT] & scan_dis_dc_b;


endmodule

