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

//*****************************************************************************
//*
//*  TITLE: TRI_PARITY_RECOVERY
//*
//*  NAME:  tri_parity_recovery
//*
//*****************************************************************************

   `include "tri_a2o.vh"

module tri_parity_recovery(
    perr_si,
    perr_so,
    delay_lclkr,
    mpw1_b,
    mpw2_b,
    nclk,
    force_t,
    thold_0_b,
    sg_0,

    gnd,
    vdd,

    ex3_hangcounter_trigger,

    ex3_a_parity_check,
    ex3_b_parity_check,
    ex3_c_parity_check,
    ex3_s_parity_check,

    rf0_instr_fra,
    rf0_instr_frb,
    rf0_instr_frc,
    rf0_tid,

    rf0_dcd_fra,
    rf0_dcd_frb,
    rf0_dcd_frc,
    rf0_dcd_tid,

    ex1_instr_fra,
    ex1_instr_frb,
    ex1_instr_frc,
    ex1_instr_frs,

    ex3_fra_v,
    ex3_frb_v,
    ex3_frc_v,
    ex3_str_v,

    ex3_frs_byp,

    ex3_fdivsqrt_start,
    ex3_instr_v,
    msr_fp_act,

    cp_flush_1d,

    ex7_is_fixperr,

    xx_ex4_regfile_err_det,
    xx_ex5_regfile_err_det,
    xx_ex6_regfile_err_det,
    xx_ex7_regfile_err_det,
    xx_ex8_regfile_err_det,

    xx_ex1_perr_sm_instr_v,
    xx_ex2_perr_sm_instr_v,
    xx_ex3_perr_sm_instr_v,
    xx_ex4_perr_sm_instr_v,
    xx_ex5_perr_sm_instr_v,
    xx_ex6_perr_sm_instr_v,
    xx_ex7_perr_sm_instr_v,
    xx_ex8_perr_sm_instr_v,

    xx_perr_sm_running,

    xx_ex2_perr_force_c,
    xx_ex2_perr_fsel_ovrd,

    xx_perr_tid_l2,
    xx_perr_sm_l2,
    xx_perr_addr_l2,

    ex3_sto_parity_err,
    xx_rv_hold_all,

    xx_ex0_regfile_ue,
    xx_ex0_regfile_ce,

    xx_pc_err_regfile_parity,
    xx_pc_err_regfile_ue


 );
   parameter                                THREADS = 2;

   input                                    perr_si;
   output                                   perr_so;
   input [0:9]                              delay_lclkr;

   input [0:9]                              mpw1_b;
   input [0:1]                              mpw2_b;
   input  [0:`NCLK_WIDTH-1]                 nclk;
   input                                    force_t;
   input                                    thold_0_b;
   input                                    sg_0;

   inout                                    gnd;
   inout                                    vdd;

   input                                    ex3_hangcounter_trigger;

   input                                    ex3_a_parity_check;
   input                                    ex3_b_parity_check;
   input                                    ex3_c_parity_check;
   input                                    ex3_s_parity_check;

   input [0:5]                              rf0_instr_fra;
   input [0:5]                              rf0_instr_frb;
   input [0:5]                              rf0_instr_frc;
   input [0:1]                              rf0_tid;

   output [0:5]                             rf0_dcd_fra;
   output [0:5]                             rf0_dcd_frb;
   output [0:5]                             rf0_dcd_frc;
   output [0:1]                             rf0_dcd_tid;

   input [0:5]                              ex1_instr_fra;
   input [0:5]                              ex1_instr_frb;
   input [0:5]                              ex1_instr_frc;
   input [0:5]                              ex1_instr_frs;

   input                                    ex3_fra_v;
   input                                    ex3_frb_v;
   input                                    ex3_frc_v;
   input                                    ex3_str_v;
   input                                    ex3_frs_byp;

   input [0:1]                              ex3_fdivsqrt_start;
   input [0:1]                              ex3_instr_v;
   input                                    msr_fp_act;
   input [0:1]                              cp_flush_1d;

   output                                   ex7_is_fixperr;

   output [0:1]                             xx_ex4_regfile_err_det;
   output [0:1]                             xx_ex5_regfile_err_det;
   output [0:1]                             xx_ex6_regfile_err_det;
   output [0:1]                             xx_ex7_regfile_err_det;
   output [0:1]                             xx_ex8_regfile_err_det;

   output                                   xx_ex1_perr_sm_instr_v;
   output                                   xx_ex2_perr_sm_instr_v;
   output                                   xx_ex3_perr_sm_instr_v;
   output                                   xx_ex4_perr_sm_instr_v;
   output                                   xx_ex5_perr_sm_instr_v;
   output                                   xx_ex6_perr_sm_instr_v;
   output                                   xx_ex7_perr_sm_instr_v;
   output                                   xx_ex8_perr_sm_instr_v;

   output                                   xx_perr_sm_running;

   output                                   xx_ex2_perr_force_c;
   output                                   xx_ex2_perr_fsel_ovrd;
   output [0:1]                             xx_perr_tid_l2;

   output [0:2] 			    xx_perr_sm_l2;
   output [0:5] 			    xx_perr_addr_l2;

   output                                   ex3_sto_parity_err;
   output                                   xx_rv_hold_all;

   output                                   xx_ex0_regfile_ue;
   output                                   xx_ex0_regfile_ce;

   output [0:`THREADS-1]                    xx_pc_err_regfile_parity;
   output [0:`THREADS-1]                    xx_pc_err_regfile_ue;

   // parity err ---------

   (* analysis_not_referenced="TRUE" *) // unused
   wire [0:2] 				    spare_unused;

   wire                                     perr_sm_running;
   wire [0:23]                              ex3_perr_si;

   wire [0:23]                              ex3_perr_so;

   wire [0:1]                               ex3_fpr_perr;
   wire [0:1]                               ex3_fpr_reg_perr;
   wire                                     ex3_regfile_err_det_any;
   wire                                     ex3_capture_addr;

   wire [0:1]                               ex4_regfile_err_det_din;
   wire [0:1]                               ex5_regfile_err_det_din;
   wire [0:1]                               ex6_regfile_err_det_din;
   wire [0:1]                               ex7_regfile_err_det_din;
   wire                                     regfile_seq_beg;
   wire                                     regfile_seq_end;

   wire                                     ex4_regfile_err_det_any;
   wire                                     ex5_regfile_err_det_any;
   wire                                     ex6_regfile_err_det_any;

   wire [0:1] 				    ex4_sto_err_det;

   wire [0:1]                               ex4_regfile_err_det;
   wire [0:1]                               ex5_regfile_err_det;
   wire [0:1]                               ex6_regfile_err_det;
   wire [0:1]                               ex7_regfile_err_det;
   wire [0:1]                               ex8_regfile_err_det;
   wire                                     ex3_f0a_perr;
   wire                                     ex3_f0c_perr;
   wire                                     ex3_f1b_perr;
   wire                                     ex3_f1s_perr;
   wire [0:1]                               ex3_sto_perr;
   wire [0:0] 				    holdall_si;
   wire [0:0] 				    holdall_so;

   wire                                     rv_hold_all_din;
   wire                                     rv_hold_all_q;
   wire [0:1]                               err_regfile_parity;
   wire [0:1]                               err_regfile_ue;
   wire [0:1]                               ex3_abc_perr;
   wire [0:1]                               ex3_abc_perr_x;
   wire [0:1]                               ex3_abc_perr_y;

   wire                                     ex1_perr_move_f0_to_f1;
   wire                                     ex1_perr_move_f1_to_f0;

   wire                                     ex0_regfile_ce;
   wire                                     ex0_regfile_ue;

   wire [0:23]                              ex2_perr_si;

   wire [0:23]                              ex2_perr_so;

   wire [0:5]                               ex3_instr_fra;
   wire [0:5]                               ex3_instr_frb;
   wire [0:5]                               ex3_instr_frc;
   wire [0:5]                               ex3_instr_frs;
   wire [0:5]                               ex2_instr_fra;
   wire [0:5]                               ex2_instr_frb;
   wire [0:5]                               ex2_instr_frc;
   wire [0:5]                               ex2_instr_frs;

   wire                                     new_perr_sm_instr_v;

   wire                                     rf0_perr_sm_instr_v;
   wire                                     rf0_perr_sm_instr_v_b;
   wire                                     ex0_perr_sm_instr_v;
   wire                                     ex1_perr_sm_instr_v;
   wire                                     ex2_perr_sm_instr_v;
   wire                                     ex3_perr_sm_instr_v;
   wire                                     ex4_perr_sm_instr_v;
   wire                                     ex5_perr_sm_instr_v;
   wire                                     ex6_perr_sm_instr_v;
   wire                                     ex7_perr_sm_instr_v;
   wire                                     ex8_perr_sm_instr_v;

   wire                                     rf0_perr_move_f0_to_f1;
   wire                                     rf0_perr_move_f1_to_f0;
   wire                                     rf0_perr_fixed_itself;
   wire                                     perr_move_f0_to_f1_l2;
   wire                                     perr_move_f1_to_f0_l2;
   wire                                     rf0_perr_force_c;
   wire                                     ex0_perr_force_c;
   wire                                     ex1_perr_force_c;
   wire                                     ex2_perr_force_c;

   wire [0:5]                               perr_addr_din;
   wire [0:5]                               perr_addr_l2;
   wire [0:30]                              perr_ctl_si;
   wire [0:30]                              perr_ctl_so;
   wire                                     perr_move_f0_to_f1;
   wire                                     perr_move_f1_to_f0;
   wire [0:2]                               perr_sm_din;
   wire [0:2]                               perr_sm_l2;
   wire [0:2]                               perr_sm_ns;
   wire [0:2]                               perr_sm_si;
   wire [0:2]                               perr_sm_so;

   wire [0:1]                               perr_tid_din;

   wire [0:1]                               perr_tid_l2;

   wire                                     rf0_regfile_ce;
   wire                                     rf0_regfile_ue;


   wire [0:3]                               ex4_ctl_perr_si;
   wire [0:3]                               ex4_ctl_perr_so;

   wire [0:8] 				    exx_regfile_err_det_si;
   wire [0:8] 				    exx_regfile_err_det_so;

   wire [0:5]                               rf0_frb_iu_x_b;
   wire [0:5]                               rf0_frb_perr_x_b;
   wire [0:5]                               rf0_frc_iu_x_b;
   wire [0:5]                               rf0_frc_perr_x_b;

   wire                                     ex3_a_perr_check;
   wire                                     ex3_b_perr_check;
   wire                                     ex3_c_perr_check;
   wire                                     ex3_s_perr_check;
   //------------- end parity

   wire                                     tilo;
   wire                                     tihi;
   wire                                     tidn;
   wire                                     tiup;

   //-------------------------------------------------------------------------------------------------
   assign tilo = 1'b0;
   assign tihi = 1'b1;
   assign tidn = 1'b0;
   assign tiup = 1'b1;

   //----------------------------------------------------------------------
   // Parity State Machine / parity section
   assign xx_ex4_regfile_err_det = ex4_regfile_err_det;
   assign xx_ex5_regfile_err_det = ex5_regfile_err_det;
   assign xx_ex6_regfile_err_det = ex6_regfile_err_det;
   assign xx_ex7_regfile_err_det = ex7_regfile_err_det;
   assign xx_ex8_regfile_err_det = ex8_regfile_err_det;

   assign xx_ex1_perr_sm_instr_v = ex1_perr_sm_instr_v;
   assign xx_ex2_perr_sm_instr_v = ex2_perr_sm_instr_v;
   assign xx_ex3_perr_sm_instr_v = ex3_perr_sm_instr_v;
   assign xx_ex4_perr_sm_instr_v = ex4_perr_sm_instr_v;
   assign xx_ex5_perr_sm_instr_v = ex5_perr_sm_instr_v;
   assign xx_ex6_perr_sm_instr_v = ex6_perr_sm_instr_v;
   assign xx_ex7_perr_sm_instr_v = ex7_perr_sm_instr_v;
   assign xx_ex8_perr_sm_instr_v = ex8_perr_sm_instr_v;

   assign xx_perr_tid_l2 = perr_tid_l2;
   assign xx_perr_sm_l2 = perr_sm_l2;

   assign ex4_regfile_err_det_din[0:1] = ex4_regfile_err_det[0:1] & (~cp_flush_1d[0:1]);
   assign ex5_regfile_err_det_din[0:1] = ex5_regfile_err_det[0:1] & (~cp_flush_1d[0:1]);
   assign ex6_regfile_err_det_din[0:1] = ex6_regfile_err_det[0:1] & (~cp_flush_1d[0:1]);
   assign ex7_regfile_err_det_din[0:1] = ex7_regfile_err_det[0:1] & (~cp_flush_1d[0:1]);

   assign xx_ex0_regfile_ue = ex0_regfile_ue;
   assign xx_ex0_regfile_ce = ex0_regfile_ce;

   assign xx_perr_addr_l2 = perr_addr_l2;


   tri_rlmreg_p #(.INIT(0),  .WIDTH(9)) exx_regfile_err_det_lat(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(exx_regfile_err_det_si[0:8]),
      .scout(exx_regfile_err_det_so[0:8]),
      //-------------------------------------------
      .din({  ex4_regfile_err_det_din[0:1],
              ex5_regfile_err_det_din[0:1],
              ex6_regfile_err_det_din[0:1],
              ex7_regfile_err_det_din[0:1],
              ex6_perr_sm_instr_v
           }),

      //-------------------------------------------
      .dout({ ex5_regfile_err_det[0:1],
	      ex6_regfile_err_det[0:1],
	      ex7_regfile_err_det[0:1],
	      ex8_regfile_err_det[0:1],
              ex7_is_fixperr
       })
   );
   //-------------------------------------------

   tri_rlmreg_p #(.INIT(0), .WIDTH(4)) ex4_ctl_perr(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),
      .mpw1_b(mpw1_b[4]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex4_ctl_perr_si[0:3]),
      .scout(ex4_ctl_perr_so[0:3]),
      //-------------------------------------------
      .din({
                ex3_fpr_reg_perr[0:1],
		ex3_sto_perr[0:1]
           }),
      //-------------------------------------------
      .dout(  {
                ex4_regfile_err_det[0:1],
                ex4_sto_err_det[0:1]
           })
   );
   //-------------------------------------------


   tri_rlmreg_p #(.INIT(0), .WIDTH(24)) ex2_perr(
      .nclk(nclk),
      .act(tiup),
      .force_t(force_t),
       .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),
      .mpw1_b(mpw1_b[2]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex2_perr_si[0:23]),
      .scout(ex2_perr_so[0:23]),
      .din({ex1_instr_frs[0:5],
            ex1_instr_fra[0:5],
            ex1_instr_frb[0:5],
            ex1_instr_frc[0:5]
            }),
      //-------------------------------------------
      .dout({ex2_instr_frs[0:5],
             ex2_instr_fra[0:5],
             ex2_instr_frb[0:5],
             ex2_instr_frc[0:5]
            })
   );

   //-------------------------------------------
   tri_rlmreg_p #(.INIT(0), .WIDTH(24)) ex3_perr(
      .nclk(nclk),
      .act(tiup),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),
      .mpw1_b(mpw1_b[3]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex3_perr_si[0:23]),
      .scout(ex3_perr_so[0:23]),
      .din({ex2_instr_frs[0:5],
	    ex2_instr_fra[0:5],
	    ex2_instr_frb[0:5],
            ex2_instr_frc[0:5]
           }),
      //-------------------------------------------
      .dout(  {ex3_instr_frs[0:5],
	       ex3_instr_fra[0:5],
               ex3_instr_frb[0:5],
               ex3_instr_frc[0:5]
                })
   );
   //-------------------------------------------


   // Parity Checking

   assign ex3_a_perr_check = ex3_a_parity_check;
   assign ex3_b_perr_check = ex3_b_parity_check;
   assign ex3_c_perr_check = ex3_c_parity_check;
   assign ex3_s_perr_check = ex3_s_parity_check;


   assign ex3_sto_perr[0:1] = {2{(ex3_s_perr_check & ex3_str_v & ~ex3_frs_byp)}} & ex3_instr_v[0:1];

   assign ex3_sto_parity_err = |(ex3_sto_perr);

   assign ex3_abc_perr_x =    {2{((ex3_a_perr_check & ex3_fra_v) |
                                  (ex3_b_perr_check & ex3_frb_v) |
                                  (ex3_c_perr_check & ex3_frc_v)) }};

   assign ex3_abc_perr_y =    (ex3_instr_v[0:1] | ex3_fdivsqrt_start[0:1]);


   assign ex3_abc_perr[0:1] = ex3_abc_perr_x[0:1] & ex3_abc_perr_y[0:1];


   assign ex3_fpr_perr[0:1] = (ex3_sto_perr[0:1] | ex3_abc_perr[0:1]) & (~cp_flush_1d[0:1]) & {2{msr_fp_act}};

   assign ex3_regfile_err_det_any = |(ex3_fpr_perr);

   assign ex3_fpr_reg_perr[0:1] = ( ex3_abc_perr[0:1]) & (~cp_flush_1d[0:1]) & {2{msr_fp_act}};


   assign ex3_f0a_perr = ex3_a_perr_check & ex3_fra_v;
   assign ex3_f0c_perr = ex3_c_perr_check & (ex3_frc_v | (perr_sm_l2[1] & ex3_perr_sm_instr_v));
   assign ex3_f1b_perr = ex3_b_perr_check & (ex3_frb_v | (perr_sm_l2[1] & ex3_perr_sm_instr_v));


   assign ex3_f1s_perr = ex3_s_perr_check & ex3_str_v;


   assign ex4_regfile_err_det_any = |(ex4_regfile_err_det[0:1])  | |(ex4_sto_err_det[0:1]);


   tri_rlmreg_p #(.INIT(4),  .WIDTH(3)) perr_sm(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(perr_sm_si[0:2]),
      .scout(perr_sm_so[0:2]),
      .din(perr_sm_din[0:2]),
      //-------------------------------------------
      .dout(  perr_sm_l2[0:2])
   );
   //-------------------------------------------

   tri_rlmreg_p #(.INIT(0),  .WIDTH(31)) perr_ctl(
      .nclk(nclk),
      .act(tiup),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(perr_ctl_si[0:30]),
      .scout(perr_ctl_so[0:30]),
      .din({    perr_addr_din[0:5],
                perr_tid_din[0:1],
		spare_unused[0:1],
                perr_move_f0_to_f1,
                perr_move_f1_to_f0,
                rf0_perr_force_c,
                ex0_perr_force_c,
                ex1_perr_force_c,
                new_perr_sm_instr_v,
                rf0_perr_sm_instr_v,
                ex0_perr_sm_instr_v,
                ex1_perr_sm_instr_v,
                ex2_perr_sm_instr_v,
                ex3_perr_sm_instr_v,
                ex4_perr_sm_instr_v,
                ex5_perr_sm_instr_v,
                ex6_perr_sm_instr_v,
                ex7_perr_sm_instr_v,
		ex4_regfile_err_det_any,
                ex5_regfile_err_det_any, // ex3_regfile_err_det, //xu_fu_regfile_seq_beg, // need extra cycles for holdall to take effect
                ex6_regfile_err_det_any,
                regfile_seq_end,
                rf0_regfile_ue,
                rf0_regfile_ce}),
      //-------------------------------------------
      .dout({   perr_addr_l2[0:5],
                perr_tid_l2[0:1],
		spare_unused[0:1],
                perr_move_f0_to_f1_l2,
                perr_move_f1_to_f0_l2,
                ex0_perr_force_c,
                ex1_perr_force_c,
		ex2_perr_force_c,
                rf0_perr_sm_instr_v,
                ex0_perr_sm_instr_v,
                ex1_perr_sm_instr_v,
                ex2_perr_sm_instr_v,
                ex3_perr_sm_instr_v,
                ex4_perr_sm_instr_v,
                ex5_perr_sm_instr_v,
                ex6_perr_sm_instr_v,
                ex7_perr_sm_instr_v,
                ex8_perr_sm_instr_v,
		ex5_regfile_err_det_any,
		ex6_regfile_err_det_any,
                regfile_seq_beg,
                spare_unused[2],
                ex0_regfile_ue,
                ex0_regfile_ce})
   );
   //-------------------------------------------

   assign rf0_perr_sm_instr_v_b = (~rf0_perr_sm_instr_v);

   // State 0 = 100 = Default, no parity error
   // State 1 = 010 = Parity error detected.  Flush System, and read out both entries
   // State 2 = 001 = Move good to bad, or UE

   assign         perr_sm_running = (~perr_sm_l2[0]);
   assign        xx_perr_sm_running = (~perr_sm_l2[0]);

   // Goto State0 at the end of the sequence.  That's either after a UE, or writeback is done
   assign perr_sm_ns[0] = (perr_sm_l2[2] & rf0_regfile_ue) | (perr_sm_l2[2] & ex7_perr_sm_instr_v);
   assign regfile_seq_end = perr_sm_ns[0];

   // Goto State1 when a parity error is detected.
   assign perr_sm_ns[1] = perr_sm_l2[0] & regfile_seq_beg;

   // Goto State2 when both sets of data have been read out
   assign perr_sm_ns[2] = perr_sm_l2[1] & ex7_perr_sm_instr_v;

   // set move decision.  Both means Uncorrectable Error
   assign perr_move_f0_to_f1 = (ex3_f1b_perr          & ( (perr_sm_l2[1] & ex3_perr_sm_instr_v))) |
	                       (perr_move_f0_to_f1_l2 & (~(perr_sm_l2[1] & ex3_perr_sm_instr_v)));

   assign perr_move_f1_to_f0 = (ex3_f0c_perr          & ( (perr_sm_l2[1] & ex3_perr_sm_instr_v))) |
	                       (perr_move_f1_to_f0_l2 & (~(perr_sm_l2[1] & ex3_perr_sm_instr_v)));


   assign rf0_perr_move_f0_to_f1 = perr_move_f0_to_f1_l2 & (perr_sm_l2[2] & rf0_perr_sm_instr_v);
   assign rf0_perr_move_f1_to_f0 = perr_move_f1_to_f0_l2 & (perr_sm_l2[2] & rf0_perr_sm_instr_v);
   assign rf0_perr_fixed_itself = (~(perr_move_f1_to_f0_l2 | perr_move_f0_to_f1_l2)) & (perr_sm_l2[2] & rf0_perr_sm_instr_v); // this is for the case where initially a parity error was detected, but when re-read out of the regfile both copies are correct. We still want to report this.

   assign rf0_perr_force_c       = rf0_perr_move_f0_to_f1 & (~rf0_perr_move_f1_to_f0);

   assign xx_ex2_perr_force_c = ex2_perr_force_c;
   assign xx_ex2_perr_fsel_ovrd = ex2_perr_sm_instr_v & perr_sm_l2[2];  //cyc  // perr_insert


   assign perr_sm_din[0:2] = (3'b100 & {3{perr_sm_ns[0]}}) |
                             (3'b010 & {3{perr_sm_ns[1]}}) |
                             (3'b001 & {3{perr_sm_ns[2]}}) |
                             (perr_sm_l2 & {3{(~(|(perr_sm_ns[0:2])))}});

   // Send a dummy instruction down the pipe for reading or writing the regfiles
   assign new_perr_sm_instr_v = perr_sm_ns[1] | perr_sm_ns[2];

   // Save the offending address and tid on any parity error and hold.
   assign ex3_capture_addr = ex3_regfile_err_det_any & perr_sm_l2[0] &
                              (~ex4_regfile_err_det_any) &
                              (~ex5_regfile_err_det_any) & // need to cover the cycles while waiting for rv to hold_all
                              (~ex6_regfile_err_det_any) & // safety cycle
                              (~regfile_seq_beg);


   assign perr_addr_din[0:5] = ((ex3_f0a_perr & ex3_capture_addr) == 1'b1) ? ex3_instr_fra[0:5] :
                               ((ex3_f1b_perr & ex3_capture_addr) == 1'b1) ? ex3_instr_frb[0:5] :
                               ((ex3_f0c_perr & ex3_capture_addr) == 1'b1) ? ex3_instr_frc[0:5] :
                               ((ex3_f1s_perr & ex3_capture_addr) == 1'b1) ? ex3_instr_frs[0:5] :
                               perr_addr_l2[0:5];

   assign perr_tid_din[0:1] = (ex3_fpr_perr[0:1] & {2{ (ex3_capture_addr)}}) |
                              (perr_tid_l2[0:1] &  {2{~(ex3_capture_addr)}});

   //Mux into the FPR address
   // perr_insert

   assign rf0_frc_perr_x_b[0:5] = (~(perr_addr_l2[0:5] & {6{rf0_perr_sm_instr_v}}));

   assign rf0_frc_iu_x_b[0:5] = (~(rf0_instr_frc[0:5] &  {6{rf0_perr_sm_instr_v_b}}));

   assign rf0_dcd_frc[0:5] = (~(rf0_frc_perr_x_b[0:5] & rf0_frc_iu_x_b[0:5]));


   assign rf0_frb_perr_x_b[0:5] = (~(perr_addr_l2[0:5] & {6{rf0_perr_sm_instr_v}}));

   assign rf0_frb_iu_x_b[0:5] = (~(rf0_instr_frb[0:5] & {6{rf0_perr_sm_instr_v_b}}));

   assign rf0_dcd_frb[0:5] = (~(rf0_frb_perr_x_b[0:5] & rf0_frb_iu_x_b[0:5]));

   assign rf0_dcd_fra[0:5] = rf0_instr_fra[0:5];

   assign rf0_dcd_tid[0:1] = (rf0_tid[0:1]      & {2{rf0_perr_sm_instr_v_b}}) |
                               (perr_tid_l2[0:1] & {2{rf0_perr_sm_instr_v}});


   // Determine if we have a ue or ce to report to PC
   // state prefixes are for the recirc, not relevant to PC
   assign rf0_regfile_ce = (rf0_perr_move_f0_to_f1 | rf0_perr_move_f1_to_f0 | rf0_perr_fixed_itself) & (~(rf0_perr_move_f0_to_f1 & rf0_perr_move_f1_to_f0));
   assign rf0_regfile_ue = rf0_perr_move_f0_to_f1 & rf0_perr_move_f1_to_f0;

   assign err_regfile_parity[0:1] = perr_tid_l2[0:1] & {2{ex0_regfile_ce}};
   assign err_regfile_ue[0:1] = perr_tid_l2[0:1] & {2{ex0_regfile_ue}};




   generate
      if (THREADS == 1)
      begin : dcd_err_rpt_thr1

        tri_direct_err_rpt #(.WIDTH(2)) fu_err_rpt(
           .vd(vdd),
           .gd(gnd),
           .err_in({ err_regfile_parity[0],
                     err_regfile_ue[0]}),
           .err_out({xx_pc_err_regfile_parity[0],
                     xx_pc_err_regfile_ue[0]  })
        );

      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : dcd_err_rpt_thr2

         tri_direct_err_rpt #(.WIDTH(4)) fu_err_rpt(
            .vd(vdd),
            .gd(gnd),
            .err_in({ err_regfile_parity[0],
                      err_regfile_parity[1],

                      err_regfile_ue[0],
                      err_regfile_ue[1]
              }),
            .err_out({xx_pc_err_regfile_parity[0],
                      xx_pc_err_regfile_parity[1],

                      xx_pc_err_regfile_ue[0],
                      xx_pc_err_regfile_ue[1]  })
         );

      end
   endgenerate






   //----------------------------------------------------------------------


   assign   rv_hold_all_din = ex3_hangcounter_trigger |
                              ex3_regfile_err_det_any |
                              ex4_regfile_err_det_any |
                              ex5_regfile_err_det_any |
                              ex6_regfile_err_det_any |
                              regfile_seq_beg | perr_sm_running;


   tri_rlmreg_p #(.INIT(0),  .WIDTH(1)) holdall_lat(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(holdall_si[0:0]),
      .scout(holdall_so[0:0]),

      .din(rv_hold_all_din),
      //-------------------------------------------
      .dout(rv_hold_all_q)
   );
   //-------------------------------------------


   assign         xx_rv_hold_all = rv_hold_all_q;

   //-------------------------------------------

   // perr
   assign ex2_perr_si[0:23] = {ex2_perr_so[1:23], perr_si};
   assign ex3_perr_si[0:23] = {ex3_perr_so[1:23], ex2_perr_so[0]};
   assign perr_sm_si[0:2] = {perr_sm_so[1:2], ex3_perr_so[0]};
   assign perr_ctl_si[0:30] = {perr_ctl_so[1:30], perr_sm_so[0]};
   assign ex4_ctl_perr_si[0:3] = {ex4_ctl_perr_so[1:3], perr_ctl_so[0]};
   assign holdall_si[0] = {ex4_ctl_perr_so[0]};
   assign exx_regfile_err_det_si[0:8] = {exx_regfile_err_det_so[1:8], holdall_so[0]};

   assign perr_so = exx_regfile_err_det_so[0];

   // end perr


 endmodule
