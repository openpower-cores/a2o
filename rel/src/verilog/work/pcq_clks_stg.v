// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.




module pcq_clks_stg( 
`include "tri_a2o.vh"

   inout      			vdd,
   inout      			gnd,
   input   [0:`NCLK_WIDTH-1]    nclk,
   input      			ccflush_out_dc,
   input      			gptr_sl_thold_5,
   input      			time_sl_thold_5,
   input      			repr_sl_thold_5,
   input      			cfg_sl_thold_5,
   input      			cfg_slp_sl_thold_5,
   input      			abst_sl_thold_5,
   input      			abst_slp_sl_thold_5,
   input      			regf_sl_thold_5,
   input      			regf_slp_sl_thold_5,
   input      			func_sl_thold_5,
   input      			func_slp_sl_thold_5,
   input      			func_nsl_thold_5,
   input      			func_slp_nsl_thold_5,
   input      			ary_nsl_thold_5,
   input      			ary_slp_nsl_thold_5,
   input      			rtim_sl_thold_5,
   input      			sg_5,
   input      			fce_5,
   output     			pc_pc_ccflush_out_dc,
   output     			pc_pc_gptr_sl_thold_4,
   output     			pc_pc_time_sl_thold_4,
   output     			pc_pc_repr_sl_thold_4,
   output     			pc_pc_abst_sl_thold_4,
   output     			pc_pc_abst_slp_sl_thold_4,
   output     			pc_pc_regf_sl_thold_4,
   output     			pc_pc_regf_slp_sl_thold_4,
   output     			pc_pc_func_sl_thold_4,
   output     			pc_pc_func_slp_sl_thold_4,
   output    	 		pc_pc_cfg_sl_thold_4,
   output     			pc_pc_cfg_slp_sl_thold_4,
   output     			pc_pc_func_nsl_thold_4,
   output     			pc_pc_func_slp_nsl_thold_4,
   output     			pc_pc_ary_nsl_thold_4,
   output     			pc_pc_ary_slp_nsl_thold_4,
   output     			pc_pc_rtim_sl_thold_4,
   output     			pc_pc_sg_4,
   output     			pc_pc_fce_4,
   output               	pc_fu_ccflush_dc,
   output               	pc_fu_gptr_sl_thold_3,
   output               	pc_fu_time_sl_thold_3,
   output               	pc_fu_repr_sl_thold_3,
   output               	pc_fu_abst_sl_thold_3,
   output               	pc_fu_abst_slp_sl_thold_3,
   output [0:1]               	pc_fu_func_sl_thold_3,
   output [0:1]               	pc_fu_func_slp_sl_thold_3,
   output               	pc_fu_cfg_sl_thold_3,
   output               	pc_fu_cfg_slp_sl_thold_3,
   output               	pc_fu_func_nsl_thold_3,
   output               	pc_fu_func_slp_nsl_thold_3,
   output               	pc_fu_ary_nsl_thold_3,
   output               	pc_fu_ary_slp_nsl_thold_3,
   output [0:1]              	pc_fu_sg_3,
   output               	pc_fu_fce_3,
   output     			pc_pc_ccflush_dc,
   output     			pc_pc_gptr_sl_thold_0,
   output     			pc_pc_func_sl_thold_0,
   output     			pc_pc_func_slp_sl_thold_0,
   output     			pc_pc_cfg_sl_thold_0,
   output     			pc_pc_cfg_slp_sl_thold_0,
   output     			pc_pc_sg_0
);
   
   
   wire       pc_pc_gptr_sl_thold_4_int;
   wire       pc_pc_time_sl_thold_4_int;
   wire       pc_pc_repr_sl_thold_4_int;
   wire       pc_pc_abst_sl_thold_4_int;
   wire       pc_pc_abst_slp_sl_thold_4_int;
   wire       pc_pc_regf_sl_thold_4_int;
   wire       pc_pc_regf_slp_sl_thold_4_int;
   wire       pc_pc_func_sl_thold_4_int;
   wire       pc_pc_func_slp_sl_thold_4_int;
   wire       pc_pc_cfg_sl_thold_4_int;
   wire       pc_pc_cfg_slp_sl_thold_4_int;
   wire       pc_pc_func_nsl_thold_4_int;
   wire       pc_pc_func_slp_nsl_thold_4_int;
   wire       pc_pc_ary_nsl_thold_4_int;
   wire       pc_pc_ary_slp_nsl_thold_4_int;
   wire       pc_pc_rtim_sl_thold_4_int;
   wire       pc_pc_sg_4_int;
   wire       pc_pc_fce_4_int;

   wire       pc_pc_gptr_sl_thold_3;
   wire       pc_pc_abst_sl_thold_3;
   wire       pc_pc_func_sl_thold_3;
   wire       pc_pc_func_slp_sl_thold_3;
   wire       pc_pc_cfg_slp_sl_thold_3;
   wire       pc_pc_cfg_sl_thold_3;
   wire       pc_pc_sg_3;
   wire       pc_pc_gptr_sl_thold_2;
   wire       pc_pc_abst_sl_thold_2;
   wire       pc_pc_func_sl_thold_2;
   wire       pc_pc_func_slp_sl_thold_2;
   wire       pc_pc_cfg_slp_sl_thold_2;
   wire       pc_pc_cfg_sl_thold_2;
   wire       pc_pc_sg_2;
   wire       pc_pc_gptr_sl_thold_1;
   wire       pc_pc_abst_sl_thold_1;
   wire       pc_pc_func_sl_thold_1;
   wire       pc_pc_func_slp_sl_thold_1;
   wire       pc_pc_cfg_slp_sl_thold_1;
   wire       pc_pc_cfg_sl_thold_1;
   wire       pc_pc_sg_1;
   

   assign pc_pc_ccflush_out_dc = ccflush_out_dc;
   assign pc_pc_ccflush_dc     = ccflush_out_dc;
   assign pc_fu_ccflush_dc     = ccflush_out_dc;


   tri_plat #(.WIDTH(18)) lvl5to4_plat(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),

      .din({gptr_sl_thold_5,		    time_sl_thold_5,		     repr_sl_thold_5,
            rtim_sl_thold_5,		    abst_sl_thold_5,		     abst_slp_sl_thold_5, 
            regf_sl_thold_5,		    regf_slp_sl_thold_5,	     func_sl_thold_5,
            func_slp_sl_thold_5,	    cfg_sl_thold_5,		     cfg_slp_sl_thold_5,
            func_nsl_thold_5,		    func_slp_nsl_thold_5,	     ary_nsl_thold_5,
            ary_slp_nsl_thold_5,	    sg_5,			     fce_5}),

      .q(  {pc_pc_gptr_sl_thold_4_int,      pc_pc_time_sl_thold_4_int,       pc_pc_repr_sl_thold_4_int,  
            pc_pc_rtim_sl_thold_4_int, 	    pc_pc_abst_sl_thold_4_int,       pc_pc_abst_slp_sl_thold_4_int,      
            pc_pc_regf_sl_thold_4_int,      pc_pc_regf_slp_sl_thold_4_int,   pc_pc_func_sl_thold_4_int,
            pc_pc_func_slp_sl_thold_4_int,  pc_pc_cfg_sl_thold_4_int,        pc_pc_cfg_slp_sl_thold_4_int,
            pc_pc_func_nsl_thold_4_int,     pc_pc_func_slp_nsl_thold_4_int,  pc_pc_ary_nsl_thold_4_int,
            pc_pc_ary_slp_nsl_thold_4_int,  pc_pc_sg_4_int, 		     pc_pc_fce_4_int})
   );


   assign pc_pc_gptr_sl_thold_4      =  pc_pc_gptr_sl_thold_4_int;
   assign pc_pc_time_sl_thold_4      =  pc_pc_time_sl_thold_4_int;
   assign pc_pc_repr_sl_thold_4      =  pc_pc_repr_sl_thold_4_int;
   assign pc_pc_abst_sl_thold_4      =  pc_pc_abst_sl_thold_4_int;
   assign pc_pc_abst_slp_sl_thold_4  =  pc_pc_abst_slp_sl_thold_4_int;
   assign pc_pc_regf_sl_thold_4      =  pc_pc_regf_sl_thold_4_int;
   assign pc_pc_regf_slp_sl_thold_4  =  pc_pc_regf_slp_sl_thold_4_int;
   assign pc_pc_func_sl_thold_4      =  pc_pc_func_sl_thold_4_int;
   assign pc_pc_func_slp_sl_thold_4  =  pc_pc_func_slp_sl_thold_4_int;
   assign pc_pc_cfg_sl_thold_4       =  pc_pc_cfg_sl_thold_4_int;
   assign pc_pc_cfg_slp_sl_thold_4   =  pc_pc_cfg_slp_sl_thold_4_int;
   assign pc_pc_func_nsl_thold_4     =  pc_pc_func_nsl_thold_4_int;
   assign pc_pc_func_slp_nsl_thold_4 =  pc_pc_func_slp_nsl_thold_4_int;
   assign pc_pc_ary_nsl_thold_4      =  pc_pc_ary_nsl_thold_4_int;
   assign pc_pc_ary_slp_nsl_thold_4  =  pc_pc_ary_slp_nsl_thold_4_int;
   assign pc_pc_rtim_sl_thold_4      =  pc_pc_rtim_sl_thold_4_int;
   assign pc_pc_sg_4                 =	pc_pc_sg_4_int;
   assign pc_pc_fce_4                =	pc_pc_fce_4_int;

   
   tri_plat #(.WIDTH(18)) fu_clkstg_4to3(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),

      .din({pc_pc_gptr_sl_thold_4_int,		pc_pc_time_sl_thold_4_int,	pc_pc_repr_sl_thold_4_int,
            pc_pc_abst_sl_thold_4_int,		pc_pc_abst_slp_sl_thold_4_int,	pc_pc_func_sl_thold_4_int,
	    pc_pc_func_sl_thold_4_int,		pc_pc_func_slp_sl_thold_4_int,  pc_pc_func_slp_sl_thold_4_int,	
	    pc_pc_cfg_sl_thold_4_int,       	pc_pc_cfg_slp_sl_thold_4_int,   pc_pc_func_nsl_thold_4_int,
	    pc_pc_func_slp_nsl_thold_4_int,     pc_pc_ary_nsl_thold_4_int,      pc_pc_ary_slp_nsl_thold_4_int,
	    pc_pc_sg_4_int,            		pc_pc_sg_4_int,			pc_pc_fce_4_int }),

      .q(  {pc_fu_gptr_sl_thold_3,		pc_fu_time_sl_thold_3,		pc_fu_repr_sl_thold_3,
            pc_fu_abst_sl_thold_3,		pc_fu_abst_slp_sl_thold_3,	pc_fu_func_sl_thold_3[0],
	    pc_fu_func_sl_thold_3[1],		pc_fu_func_slp_sl_thold_3[0],	pc_fu_func_slp_sl_thold_3[1],		
	    pc_fu_cfg_sl_thold_3,       	pc_fu_cfg_slp_sl_thold_3,     	pc_fu_func_nsl_thold_3,
	    pc_fu_func_slp_nsl_thold_3,     	pc_fu_ary_nsl_thold_3,		pc_fu_ary_slp_nsl_thold_3,
	    pc_fu_sg_3[0],		       	pc_fu_sg_3[1],			pc_fu_fce_3 })
   );
   

   tri_plat #(.WIDTH(6)) pc_lvl4to3(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),

      .din({pc_pc_func_sl_thold_4_int,     pc_pc_func_slp_sl_thold_4_int,  pc_pc_cfg_sl_thold_4_int,
            pc_pc_cfg_slp_sl_thold_4_int,  pc_pc_gptr_sl_thold_4_int,      pc_pc_sg_4_int}),

      .q(  {pc_pc_func_sl_thold_3,         pc_pc_func_slp_sl_thold_3,      pc_pc_cfg_sl_thold_3,
            pc_pc_cfg_slp_sl_thold_3,      pc_pc_gptr_sl_thold_3,          pc_pc_sg_3})
   );
   
   tri_plat #(.WIDTH(1)) func_3_2(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_func_sl_thold_3),
      .q(pc_pc_func_sl_thold_2)
   );
   
   tri_plat #(.WIDTH(1)) func_2_1(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_func_sl_thold_2),
      .q(pc_pc_func_sl_thold_1)
   );
   
   tri_plat #(.WIDTH(1)) func_1_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_func_sl_thold_1),
      .q(pc_pc_func_sl_thold_0)
   );
   
   tri_plat #(.WIDTH(1)) func_slp_3_2(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_func_slp_sl_thold_3),
      .q(pc_pc_func_slp_sl_thold_2)
   );
      
   tri_plat #(.WIDTH(1)) func_slp_2_1(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_func_slp_sl_thold_2),
      .q(pc_pc_func_slp_sl_thold_1)
   );
   
   tri_plat #(.WIDTH(1)) func_slp_1_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_func_slp_sl_thold_1),
      .q(pc_pc_func_slp_sl_thold_0)
   );
   
   tri_plat #(.WIDTH(1)) cfg_3_2(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_cfg_sl_thold_3),
      .q(pc_pc_cfg_sl_thold_2)
   );
   
   tri_plat #(.WIDTH(1)) cfg_2_1(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_cfg_sl_thold_2),
      .q(pc_pc_cfg_sl_thold_1)
   );
      
   tri_plat #(.WIDTH(1)) cfg_1_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_cfg_sl_thold_1),
      .q(pc_pc_cfg_sl_thold_0)
   );
   
   tri_plat #(.WIDTH(1)) cfg_slp_3_2(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_cfg_slp_sl_thold_3),
      .q(pc_pc_cfg_slp_sl_thold_2)
   );
   
   tri_plat #(.WIDTH(1)) cfg_slp_2_1(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_cfg_slp_sl_thold_2),
      .q(pc_pc_cfg_slp_sl_thold_1)
   );
   
   tri_plat #(.WIDTH(1)) cfg_slp_1_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_cfg_slp_sl_thold_1),
      .q(pc_pc_cfg_slp_sl_thold_0)
   );
      
   tri_plat #(.WIDTH(1)) gptr_3_2(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_gptr_sl_thold_3),
      .q(pc_pc_gptr_sl_thold_2)
   );
   
   tri_plat #(.WIDTH(1)) gptr_2_1(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_gptr_sl_thold_2),
      .q(pc_pc_gptr_sl_thold_1)
   );
   
   tri_plat #(.WIDTH(1)) gptr_1_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_gptr_sl_thold_1),
      .q(pc_pc_gptr_sl_thold_0)
   );
   
   tri_plat #(.WIDTH(1)) sg_3_2(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_sg_3),
      .q(pc_pc_sg_2)
   );
   
   tri_plat #(.WIDTH(1)) sg_2_1(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_sg_2),
      .q(pc_pc_sg_1)
   );
   
   tri_plat #(.WIDTH(1)) sg_1_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_out_dc),
      .din(pc_pc_sg_1),
      .q(pc_pc_sg_0)
   );
      

endmodule

