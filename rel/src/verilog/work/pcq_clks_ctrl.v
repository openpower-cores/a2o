// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.




module pcq_clks_ctrl( 
`include "tri_a2o.vh"

   inout			vdd,
   inout			gnd,
   input  [0:`NCLK_WIDTH-1]	nclk,
   input			rtim_sl_thold_6,
   input			func_sl_thold_6,
   input			func_nsl_thold_6,
   input			ary_nsl_thold_6,
   input			sg_6,
   input			fce_6,
   input			gsd_test_enable_dc,
   input			gsd_test_acmode_dc,
   input			ccflush_dc,
   input			ccenable_dc,
   input			lbist_en_dc,
   input			lbist_ip_dc,
   input			rg_ck_fast_xstop,
   input			ct_ck_pm_ccflush_disable,
   input			ct_ck_pm_raise_tholds,
   input  [0:8]			scan_type_dc,
   output			ccflush_out_dc,
   output			gptr_sl_thold_5,
   output			time_sl_thold_5,
   output			repr_sl_thold_5,
   output			cfg_sl_thold_5,
   output			cfg_slp_sl_thold_5,
   output			abst_sl_thold_5,
   output			abst_slp_sl_thold_5,
   output			regf_sl_thold_5,
   output			regf_slp_sl_thold_5,
   output			func_sl_thold_5,
   output			func_slp_sl_thold_5,
   output			func_nsl_thold_5,
   output			func_slp_nsl_thold_5,
   output			ary_nsl_thold_5,
   output			ary_slp_nsl_thold_5,
   output			rtim_sl_thold_5,
   output			sg_5,
   output			fce_5
);

   

   parameter   			SCANTYPE_SIZE = 9;	
	
   parameter   			SCANTYPE_FUNC = 0;
   parameter   			SCANTYPE_MODE = 1;
   parameter   			SCANTYPE_CCFG = 2;
   parameter   			SCANTYPE_GPTR = 2;
   parameter   			SCANTYPE_REGF = 3;
   parameter   			SCANTYPE_FUSE = 3;
   parameter   			SCANTYPE_LBST = 4;
   parameter   			SCANTYPE_ABST = 5;
   parameter   			SCANTYPE_REPR = 6;
   parameter   			SCANTYPE_TIME = 7;
   parameter   			SCANTYPE_BNDY = 8;
   parameter   			SCANTYPE_FARY = 9;
   
   wire				fast_xstop_gated_staged;
   wire				fce_in;
   wire				sg_in;
   wire				ary_nsl_thold;
   wire				func_nsl_thold;
   wire				rtim_sl_thold;
   wire				func_sl_thold;
   wire				gptr_sl_thold_in;
   wire				time_sl_thold_in;
   wire				repr_sl_thold_in;
   wire				rtim_sl_thold_in;
   wire				cfg_run_sl_thold_in;
   wire				cfg_slp_sl_thold_in;
   wire				abst_run_sl_thold_in;
   wire				abst_slp_sl_thold_in;
   wire				regf_run_sl_thold_in;
   wire				regf_slp_sl_thold_in;
   wire				func_run_sl_thold_in;
   wire				func_slp_sl_thold_in;
   wire				func_run_nsl_thold_in;
   wire				func_slp_nsl_thold_in;
   wire				ary_run_nsl_thold_in;
   wire				ary_slp_nsl_thold_in;
   wire				pm_ccflush_disable_dc;
   wire				ccflush_out_dc_int;
   wire				testdc;
   wire				thold_overide_ctrl;
   wire [0:SCANTYPE_SIZE-1] 	scan_type_b; 
      

(* analysis_not_referenced="true" *)  
   wire   unused_signals;
   assign unused_signals = (scan_type_b[2] | scan_type_b[4] | (|scan_type_b[6:8]) | lbist_ip_dc);


   
   
   assign testdc = gsd_test_enable_dc & (~gsd_test_acmode_dc);
   
   assign sg_in  = sg_6  & ccenable_dc;
   assign fce_in = fce_6 & ccenable_dc;
   
   assign scan_type_b = ({SCANTYPE_SIZE {sg_in}} & (~scan_type_dc));
   
   assign thold_overide_ctrl = fast_xstop_gated_staged & (~sg_in) & (~lbist_en_dc) & (~gsd_test_enable_dc);
   
   assign rtim_sl_thold  = rtim_sl_thold_6;
   assign func_sl_thold  = func_sl_thold_6  | thold_overide_ctrl;
   assign func_nsl_thold = func_nsl_thold_6 | thold_overide_ctrl;
   assign ary_nsl_thold  = ary_nsl_thold_6  | thold_overide_ctrl;
   
   assign pm_ccflush_disable_dc = ct_ck_pm_ccflush_disable;
   
   assign ccflush_out_dc_int = ccflush_dc & ((~pm_ccflush_disable_dc) | lbist_en_dc | testdc);
   assign ccflush_out_dc     = ccflush_out_dc_int;

  
   assign gptr_sl_thold_in = func_sl_thold | (~scan_type_dc[SCANTYPE_GPTR]) | (~ccenable_dc);
   
   assign time_sl_thold_in = func_sl_thold | (~scan_type_dc[SCANTYPE_TIME]) | (~ccenable_dc);
   
   assign repr_sl_thold_in = func_sl_thold | (~scan_type_dc[SCANTYPE_REPR]) | (~ccenable_dc);
   
   assign cfg_run_sl_thold_in  = func_sl_thold | scan_type_b[SCANTYPE_MODE] | (ct_ck_pm_raise_tholds & (~sg_in) & (~lbist_en_dc) & (~gsd_test_enable_dc));
   
   assign cfg_slp_sl_thold_in  = func_sl_thold | scan_type_b[SCANTYPE_MODE];
      
   assign abst_run_sl_thold_in = func_sl_thold | scan_type_b[SCANTYPE_ABST] | (ct_ck_pm_raise_tholds & (~sg_in) & (~lbist_en_dc) & (~gsd_test_enable_dc));
   
   assign abst_slp_sl_thold_in = func_sl_thold | scan_type_b[SCANTYPE_ABST];
   
   assign regf_run_sl_thold_in = func_sl_thold | scan_type_b[SCANTYPE_REGF] | (ct_ck_pm_raise_tholds & (~sg_in) & (~lbist_en_dc) & (~gsd_test_enable_dc));
   
   assign regf_slp_sl_thold_in = func_sl_thold | scan_type_b[SCANTYPE_REGF];
   
   assign func_run_sl_thold_in = func_sl_thold | scan_type_b[SCANTYPE_FUNC] | (ct_ck_pm_raise_tholds & (~sg_in) & (~lbist_en_dc) & (~gsd_test_enable_dc));
   
   assign func_slp_sl_thold_in = func_sl_thold | scan_type_b[SCANTYPE_FUNC];
   
   assign func_run_nsl_thold_in = func_nsl_thold | (ct_ck_pm_raise_tholds & (~fce_in) & (~lbist_en_dc) & (~gsd_test_enable_dc));
   
   assign func_slp_nsl_thold_in = func_nsl_thold;
   
   assign ary_run_nsl_thold_in = ary_nsl_thold | (ct_ck_pm_raise_tholds & (~fce_in) & (~lbist_en_dc) & (~gsd_test_enable_dc));
   
   assign ary_slp_nsl_thold_in = ary_nsl_thold;
   
   assign rtim_sl_thold_in = rtim_sl_thold;
   

   tri_plat #(.WIDTH(1)) fast_stop_staging(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc_int),
      .din(rg_ck_fast_xstop),
      .q(fast_xstop_gated_staged)
   );
   
   tri_plat #(.WIDTH(2)) sg_fce_plat(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc_int),
      .din({sg_in, fce_in}),
      .q  ({sg_5,  fce_5 })
   );
      
   tri_plat #(.WIDTH(16)) thold_plat(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc_int),

      .din({gptr_sl_thold_in,      time_sl_thold_in,     repr_sl_thold_in,     cfg_run_sl_thold_in,
            cfg_slp_sl_thold_in,   abst_run_sl_thold_in, abst_slp_sl_thold_in, regf_run_sl_thold_in,
            regf_slp_sl_thold_in,  func_run_sl_thold_in, func_slp_sl_thold_in, func_run_nsl_thold_in,
	    func_slp_nsl_thold_in, ary_run_nsl_thold_in, ary_slp_nsl_thold_in, rtim_sl_thold_in}),

      .q  ({gptr_sl_thold_5,       time_sl_thold_5,      repr_sl_thold_5,      cfg_sl_thold_5,
            cfg_slp_sl_thold_5,    abst_sl_thold_5,      abst_slp_sl_thold_5,  regf_sl_thold_5,
            regf_slp_sl_thold_5,   func_sl_thold_5,      func_slp_sl_thold_5,  func_nsl_thold_5,
	    func_slp_nsl_thold_5,  ary_nsl_thold_5,      ary_slp_nsl_thold_5,  rtim_sl_thold_5})
   );


endmodule      

