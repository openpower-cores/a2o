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

// FPSCR BIT DEFINITIONS
// -------------- control
// [24] ve
// [25] oe
// [26] ue
// [27] ze
// [28] xe
// [29] non-ieee
// [30:31] rnd_mode 00:nr 01:zr 02:pi 03:ni
//
// the rnd_mode must be read in ex3 of the using op
// the rnd_mode is set in ex4 of the sending op (to_integer only)
// there must be a 2 cycle bubble after update op
//
//  set   1  2  3
// read   x  x  1  2

   `include "tri_a2o.vh"

module fu_cr2(
   vdd,
   gnd,
   clkoff_b,
   act_dis,
   flush,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   sg_1,
   thold_1,
   fpu_enable,
   nclk,
   f_cr2_si,
   f_cr2_so,
   ex1_act,
   ex2_act,
   ex1_thread_b,
   f_dcd_ex7_cancel,
   f_fmt_ex2_bop_byt,
   f_dcd_ex1_fpscr_bit_data_b,
   f_dcd_ex1_fpscr_bit_mask_b,
   f_dcd_ex1_fpscr_nib_mask_b,
   f_dcd_ex1_mtfsbx_b,
   f_dcd_ex1_mcrfs_b,
   f_dcd_ex1_mtfsf_b,
   f_dcd_ex1_mtfsfi_b,
   f_cr2_ex4_thread_b,
   f_cr2_ex4_fpscr_bit_data_b,
   f_cr2_ex4_fpscr_bit_mask_b,
   f_cr2_ex4_fpscr_nib_mask_b,
   f_cr2_ex4_mtfsbx_b,
   f_cr2_ex4_mcrfs_b,
   f_cr2_ex4_mtfsf_b,
   f_cr2_ex4_mtfsfi_b,
   f_cr2_ex6_fpscr_rd_dat,
   f_cr2_ex7_fpscr_rd_dat,
   f_cr2_ex2_fpscr_shadow
);

   inout          vdd;
   inout          gnd;
   input          clkoff_b;		// tiup
   input          act_dis;		// ??tidn??
   input          flush;		// ??tidn??
   input [1:7]    delay_lclkr;		// tidn,
   input [1:7]    mpw1_b;		// tidn,
   input [0:1]    mpw2_b;		// tidn,
   input          sg_1;
   input          thold_1;
   input          fpu_enable;		//dc_act
   input  [0:`NCLK_WIDTH-1]         nclk;

   input          f_cr2_si;		// perv
   output         f_cr2_so;		// perv
   input          ex1_act;		// act writes
   input          ex2_act;		// act writes

   input [0:3]    ex1_thread_b;		// thread write
   input          f_dcd_ex7_cancel;

   input [45:52]  f_fmt_ex2_bop_byt;		//for mtfsf to shadow reg
   input [0:3]    f_dcd_ex1_fpscr_bit_data_b;		//data to write to nibble (other than mtfsf)
   input [0:3]    f_dcd_ex1_fpscr_bit_mask_b;		//enable update of bit within the nibble
   input [0:8]    f_dcd_ex1_fpscr_nib_mask_b;		//enable update of this nibble
   input          f_dcd_ex1_mtfsbx_b;		//fpscr set bit, reset bit
   input          f_dcd_ex1_mcrfs_b;		//move fpscr field to cr and reset exceptions
   input          f_dcd_ex1_mtfsf_b;		//move fpr data to fpscr
   input          f_dcd_ex1_mtfsfi_b;		//move immediate data to fpscr

   output [0:3]   f_cr2_ex4_thread_b;		//scr
   output [0:3]   f_cr2_ex4_fpscr_bit_data_b;		//data to write to nibble (other than mtfsf)
   output [0:3]   f_cr2_ex4_fpscr_bit_mask_b;		//enable update of bit within the nibble
   output [0:8]   f_cr2_ex4_fpscr_nib_mask_b;		//enable update of this nibble
   output         f_cr2_ex4_mtfsbx_b;		//fpscr set bit, reset bit
   output         f_cr2_ex4_mcrfs_b;		//move fpscr field to cr and reset exceptions
   output         f_cr2_ex4_mtfsf_b;		//move fpr data to fpscr
   output         f_cr2_ex4_mtfsfi_b;		//move immediate data to fpscr

   output [24:31] f_cr2_ex6_fpscr_rd_dat;		//scr
   output [24:31] f_cr2_ex7_fpscr_rd_dat;		//scr
   output [0:7]   f_cr2_ex2_fpscr_shadow;		//fpic

   // end ports

   // ENTITY


   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;

   wire           sg_0;
   wire           thold_0_b;
   wire           thold_0;
   wire           force_t;
   wire           ex7_th0_act;
   wire           ex7_th1_act;
   wire           ex7_th2_act;
   wire           ex7_th3_act;

   wire           ex3_act;
   wire           ex4_act;
   wire           ex5_act;
   wire           ex6_act;
   wire           ex7_act;
   wire           ex5_mv_to_op;
   wire           ex6_mv_to_op;
   wire           ex7_mv_to_op;

   wire [0:3]     ex2_thread;
   wire [0:3]     ex3_thread;
   wire [0:3]     ex4_thread;
   wire [0:3]     ex5_thread;
   wire [0:3]     ex6_thread;
   wire [0:3]     ex7_thread;

   (* analysis_not_referenced="TRUE" *)
   wire [0:2]     act_spare_unused;
   //-----------------
   wire [0:6]     act_so;		//SCAN
   wire [0:6]     act_si;
   wire [0:33]    ex2_ctl_so;		//SCAN
   wire [0:33]    ex2_ctl_si;
   wire [0:24]    ex3_ctl_so;		//SCAN
   wire [0:24]    ex3_ctl_si;
   wire [0:24]    ex4_ctl_so;		//SCAN
   wire [0:24]    ex4_ctl_si;
   wire [0:4]     ex5_ctl_so;		//SCAN
   wire [0:4]     ex5_ctl_si;
   wire [0:4]     ex6_ctl_so;		//SCAN
   wire [0:4]     ex6_ctl_si;
   wire [0:4]     ex7_ctl_so;		//SCAN
   wire [0:4]     ex7_ctl_si;
   wire [0:7]     shadow0_so;		//SCAN
   wire [0:7]     shadow0_si;
   wire [0:7]     shadow1_so;		//SCAN
   wire [0:7]     shadow1_si;
   wire [0:7]     shadow2_so;		//SCAN
   wire [0:7]     shadow2_si;
   wire [0:7]     shadow3_so;		//SCAN
   wire [0:7]     shadow3_si;
   wire [0:7]     shadow_byp2_so;		//SCAN
   wire [0:7]     shadow_byp2_si;
   wire [0:7]     shadow_byp3_so;		//SCAN
   wire [0:7]     shadow_byp3_si;
   wire [0:7]     shadow_byp4_so;		//SCAN
   wire [0:7]     shadow_byp4_si;
   wire [0:7]     shadow_byp5_so;		//SCAN
   wire [0:7]     shadow_byp5_si;
   wire [0:7]     shadow_byp6_so;		//SCAN
   wire [0:7]     shadow_byp6_si;
   //-----------------
   wire [0:7]     shadow0;
   wire [0:7]     shadow1;
   wire [0:7]     shadow2;
   wire [0:7]     shadow3;
   wire [0:7]     shadow_byp2;
   wire [0:7]     shadow_byp3;
   wire [0:7]     shadow_byp4;
   wire [0:7]     shadow_byp5;
   wire [0:7]     shadow_byp6;
   wire [0:7]     shadow_byp2_din;

   wire [0:7]     ex2_bit_sel;
   wire [0:3]     ex2_fpscr_bit_data;
   wire [0:3]     ex2_fpscr_bit_mask;
   wire [0:8]     ex2_fpscr_nib_mask;
   wire           ex2_mtfsbx;
   wire           ex2_mcrfs;
   wire           ex2_mtfsf;
   wire           ex2_mtfsfi;
   wire [0:3]     ex3_fpscr_bit_data;
   wire [0:3]     ex3_fpscr_bit_mask;
   wire [0:8]     ex3_fpscr_nib_mask;
   wire           ex3_mtfsbx;
   wire           ex3_mcrfs;
   wire           ex3_mtfsf;
   wire           ex3_mtfsfi;

   wire [0:3]     ex4_fpscr_bit_data;
   wire [0:3]     ex4_fpscr_bit_mask;
   wire [0:8]     ex4_fpscr_nib_mask;
   wire           ex4_mtfsbx;
   wire           ex4_mcrfs;
   wire           ex4_mtfsf;
   wire           ex4_mtfsfi;
   wire           ex2_mv_to_op;
   wire           ex3_mv_to_op;
   wire           ex4_mv_to_op;
   wire [0:7]     ex2_fpscr_data;
   wire [0:3]     ex1_thread;
   wire           ex1_rd_sel_0;
   wire           ex2_rd_sel_0;
   wire           ex1_rd_sel_1;
   wire           ex2_rd_sel_1;
   wire           ex1_rd_sel_2;
   wire           ex2_rd_sel_2;
   wire           ex1_rd_sel_3;
   wire           ex2_rd_sel_3;
   wire           ex1_rd_sel_byp2;
   wire           ex2_rd_sel_byp2;
   wire           ex1_rd_sel_byp3;
   wire           ex2_rd_sel_byp3;
   wire           ex1_rd_sel_byp4;
   wire           ex2_rd_sel_byp4;
   wire           ex1_rd_sel_byp5;
   wire           ex2_rd_sel_byp5;
   wire           ex1_rd_sel_byp6;
   wire           ex2_rd_sel_byp6;

   wire           ex1_rd_sel_byp2_pri;
   wire           ex1_rd_sel_byp3_pri;
   wire           ex1_rd_sel_byp4_pri;
   wire           ex1_rd_sel_byp5_pri;
   wire           ex1_rd_sel_byp6_pri;

   wire [0:7]     ex2_fpscr_shadow_mux;
   wire           ex1_thread_match_1;
   wire           ex1_thread_match_2;
   wire           ex1_thread_match_3;
   wire           ex1_thread_match_4;
   wire           ex1_thread_match_5;
   wire [0:3]     ex1_fpscr_bit_data;
   wire [0:3]     ex1_fpscr_bit_mask;
   wire [0:8]     ex1_fpscr_nib_mask;
   wire           ex1_mtfsbx;
   wire           ex1_mcrfs;
   wire           ex1_mtfsf;
   wire           ex1_mtfsfi;
   wire           ex7_cancel;
   wire [24:31]   ex7_fpscr_rd_dat_no_byp;

   ////############################################
   ////# pervasive
   ////############################################


   tri_plat  thold_reg_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(flush),
      .din(thold_1),
      .q(thold_0)
   );


   tri_plat  sg_reg_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(flush),
      .din(sg_1),
      .q(sg_0)
   );


   tri_lcbor  lcbor_0(
      .clkoff_b(clkoff_b),
      .thold(thold_0),
      .sg(sg_0),
      .act_dis(act_dis),
      .force_t(force_t),
      .thold_b(thold_0_b)
   );

   ////############################################
   ////# ACT LATCHES
   ////############################################



   tri_rlmreg_p #(.WIDTH(7), .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[6]),		// tidn,
      .mpw1_b(mpw1_b[6]),		// tidn,
      .mpw2_b(mpw2_b[1]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(fpu_enable),
      .scout(act_so),
      .scin(act_si),
      //---------------
      .din({  act_spare_unused[0],
              act_spare_unused[1],
              ex2_act,
              ex3_act,
              ex4_act,
              ex5_act,
              ex6_act}),
      //-----------------
      .dout({   act_spare_unused[0],
                act_spare_unused[1],
                ex3_act,
                ex4_act,
                ex5_act,
                ex6_act,
                ex7_act})
   );


   assign 	  act_spare_unused[2] = ex1_act; // take this out?

   ////#############################################
   ////## ex2 latches
   ////#############################################

   assign ex1_thread[0:3] = (~ex1_thread_b[0:3]);
   assign ex1_fpscr_bit_data[0:3] = (~f_dcd_ex1_fpscr_bit_data_b[0:3]);
   assign ex1_fpscr_bit_mask[0:3] = (~f_dcd_ex1_fpscr_bit_mask_b[0:3]);
   assign ex1_fpscr_nib_mask[0:8] = (~f_dcd_ex1_fpscr_nib_mask_b[0:8]);
   assign ex1_mtfsbx = (~f_dcd_ex1_mtfsbx_b);
   assign ex1_mcrfs = (~f_dcd_ex1_mcrfs_b);
   assign ex1_mtfsf = (~f_dcd_ex1_mtfsf_b);
   assign ex1_mtfsfi = (~f_dcd_ex1_mtfsfi_b);


   tri_rlmreg_p #(.WIDTH(34)) ex2_ctl_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[1]),		// tidn,
      .mpw1_b(mpw1_b[1]),		// tidn,
      .mpw2_b(mpw2_b[0]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(fpu_enable), //ex1_act
      .scout(ex2_ctl_so),
      .scin(ex2_ctl_si),
      //-----------------
      .din({  ex1_thread[0:3],
              ex1_fpscr_bit_data[0:3],
	      ex1_fpscr_bit_mask[0:3],
              ex1_fpscr_nib_mask[0:8],
              ex1_mtfsbx,
              ex1_mcrfs,
              ex1_mtfsf,
              ex1_mtfsfi,
              ex1_rd_sel_0,
              ex1_rd_sel_1,
              ex1_rd_sel_2,
              ex1_rd_sel_3,
              ex1_rd_sel_byp2_pri,
              ex1_rd_sel_byp3_pri,
              ex1_rd_sel_byp4_pri,
              ex1_rd_sel_byp5_pri,
              ex1_rd_sel_byp6_pri}),
      //-----------------
      .dout({   ex2_thread[0:3],
                ex2_fpscr_bit_data[0:3],
		ex2_fpscr_bit_mask[0:3],
                ex2_fpscr_nib_mask[0:8],
                ex2_mtfsbx,
                ex2_mcrfs,
                ex2_mtfsf,
                ex2_mtfsfi,
                ex2_rd_sel_0,
                ex2_rd_sel_1,
                ex2_rd_sel_2,
                ex2_rd_sel_3,
                ex2_rd_sel_byp2,
                ex2_rd_sel_byp3,
                ex2_rd_sel_byp4,
                ex2_rd_sel_byp5,
                ex2_rd_sel_byp6})
   );

   ////#############################################
   ////## ex3 latches
   ////#############################################


   tri_rlmreg_p #(.WIDTH(25)) ex3_ctl_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),		// tidn,
      .mpw1_b(mpw1_b[2]),		// tidn,
      .mpw2_b(mpw2_b[0]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(fpu_enable),//ex2_act
      .scout(ex3_ctl_so),
      .scin(ex3_ctl_si),
      //-----------------
      .din({  ex2_thread[0:3],
              ex2_fpscr_bit_data[0:3],
	      ex2_fpscr_bit_mask[0:3],
              ex2_fpscr_nib_mask[0:8],
              ex2_mtfsbx,
              ex2_mcrfs,
              ex2_mtfsf,
              ex2_mtfsfi}),
      //-----------------
      .dout({   ex3_thread[0:3],
                ex3_fpscr_bit_data[0:3],
		ex3_fpscr_bit_mask[0:3],
                ex3_fpscr_nib_mask[0:8],
                ex3_mtfsbx,
                ex3_mcrfs,
                ex3_mtfsf,
                ex3_mtfsfi})
   );

   ////#############################################
   ////## ex4 latches
   ////#############################################


   tri_rlmreg_p #(.WIDTH(25)) ex4_ctl_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),		// tidn,
      .mpw1_b(mpw1_b[3]),		// tidn,
      .mpw2_b(mpw2_b[0]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(fpu_enable),//ex3_act
      .scout(ex4_ctl_so),
      .scin(ex4_ctl_si),
      //-----------------
      .din({  ex3_thread[0:3],
              ex3_fpscr_bit_data[0:3],
	      ex3_fpscr_bit_mask[0:3],
              ex3_fpscr_nib_mask[0:8],
              ex3_mtfsbx,
              ex3_mcrfs,
              ex3_mtfsf,
              ex3_mtfsfi}),
      //-----------------
      .dout({   ex4_thread[0:3],
                ex4_fpscr_bit_data[0:3],
		ex4_fpscr_bit_mask[0:3],
                ex4_fpscr_nib_mask[0:8],
                ex4_mtfsbx,
                ex4_mcrfs,
                ex4_mtfsf,
                ex4_mtfsfi})
   );

   assign f_cr2_ex4_thread_b[0:3] = (~ex4_thread[0:3]);		//output--
   assign f_cr2_ex4_fpscr_bit_data_b[0:3] = (~ex4_fpscr_bit_data[0:3]);		//output--
   assign f_cr2_ex4_fpscr_bit_mask_b[0:3] = (~ex4_fpscr_bit_mask[0:3]);		//output--
   assign f_cr2_ex4_fpscr_nib_mask_b[0:8] = (~ex4_fpscr_nib_mask[0:8]);		//output--
   assign f_cr2_ex4_mtfsbx_b = (~ex4_mtfsbx);		//output--
   assign f_cr2_ex4_mcrfs_b = (~ex4_mcrfs);		//output--
   assign f_cr2_ex4_mtfsf_b = (~ex4_mtfsf);		//output--
   assign f_cr2_ex4_mtfsfi_b = (~ex4_mtfsfi);		//output--


   tri_rlmreg_p #(.WIDTH(5)) ex5_ctl_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),		// tidn,
      .mpw1_b(mpw1_b[4]),		// tidn,
      .mpw2_b(mpw2_b[0]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(fpu_enable),//ex4_act
      .scout(ex5_ctl_so),
      .scin(ex5_ctl_si),
      //-----------------
      .din({  ex4_thread[0:3],
              ex4_mv_to_op}),
      //-----------------
      .dout({   ex5_thread[0:3],
                ex5_mv_to_op})
   );

   tri_rlmreg_p #(.WIDTH(5)) ex6_ctl_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[5]),		// tidn,
      .mpw1_b(mpw1_b[5]),		// tidn,
      .mpw2_b(mpw2_b[1]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(fpu_enable),//ex5_act
      .scout(ex6_ctl_so),
      .scin(ex6_ctl_si),
      //-----------------
      .din({  ex5_thread[0:3],
              ex5_mv_to_op}),
      //-----------------
      .dout({   ex6_thread[0:3],
                ex6_mv_to_op})
   );


   tri_rlmreg_p #(.WIDTH(5)) ex7_ctl_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[6]),		// tidn,
      .mpw1_b(mpw1_b[6]),		// tidn,
      .mpw2_b(mpw2_b[1]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(fpu_enable),//ex6_act
      .scout(ex7_ctl_so),
      .scin(ex7_ctl_si),
      //-----------------
      .din({  ex6_thread[0:3],
              ex6_mv_to_op}),
      .dout({   ex7_thread[0:3],
                ex7_mv_to_op})
   );

   assign ex7_cancel = f_dcd_ex7_cancel;

   ////##############################################
   ////# read mux for mffs instruction
   ////##############################################

   assign f_cr2_ex6_fpscr_rd_dat[24:31] = ({8{ex6_thread[0]}} & shadow0[0:7]) |
                                          ({8{ex6_thread[1]}} & shadow1[0:7]) |
                                          ({8{ex6_thread[2]}} & shadow2[0:7]) |
                                          ({8{ex6_thread[3]}} & shadow3[0:7]);		// output to rounder

   assign ex7_fpscr_rd_dat_no_byp[24:31] = ({8{ex7_thread[0]}} & shadow0[0:7]) |
                                           ({8{ex7_thread[1]}} & shadow1[0:7]) |
                                           ({8{ex7_thread[2]}} & shadow2[0:7]) |
                                           ({8{ex7_thread[3]}} & shadow3[0:7]);

   assign f_cr2_ex7_fpscr_rd_dat[24:31] = ({8{ex7_mv_to_op}} & shadow_byp6[0:7]) |
                                          ({8{(~ex7_mv_to_op)}} & ex7_fpscr_rd_dat_no_byp[24:31]);
   ////##############################################
   ////# fpscr write data / merge
   ////##############################################

   assign ex2_bit_sel[0:3] = ex2_fpscr_bit_mask[0:3] & {4{ex2_mv_to_op & ex2_fpscr_nib_mask[6]}};
   assign ex2_bit_sel[4:7] = ex2_fpscr_bit_mask[0:3] & {4{ex2_mv_to_op & ex2_fpscr_nib_mask[7]}};

   assign ex2_fpscr_data[0:3] = (f_fmt_ex2_bop_byt[45:48] & {4{ex2_mtfsf}}) |
                                (ex2_fpscr_bit_data[0:3] & {4{(~ex2_mtfsf)}});
   assign ex2_fpscr_data[4:7] = (f_fmt_ex2_bop_byt[49:52] & {4{ex2_mtfsf}}) |
                                (ex2_fpscr_bit_data[0:3] & {4{(~ex2_mtfsf)}});

   assign shadow_byp2_din[0:7] = (ex2_fpscr_shadow_mux[0:7] & (~ex2_bit_sel[0:7])) |
                                 (ex2_fpscr_data[0:7] & ex2_bit_sel[0:7]);		// may not update all the bits

   ////##############################################
   ////# read mux select generation (for pipeline control bits)
   ////##############################################

   assign ex2_mv_to_op = ex2_mtfsbx | ex2_mtfsf | ex2_mtfsfi;
   assign ex3_mv_to_op = ex3_mtfsbx | ex3_mtfsf | ex3_mtfsfi;
   assign ex4_mv_to_op = ex4_mtfsbx | ex4_mtfsf | ex4_mtfsfi;

   assign ex1_thread_match_1 = (ex1_thread[0] & ex2_thread[0]) | (ex1_thread[1] & ex2_thread[1]) | (ex1_thread[2] & ex2_thread[2]) | (ex1_thread[3] & ex2_thread[3]);

   assign ex1_thread_match_2 = (ex1_thread[0] & ex3_thread[0]) | (ex1_thread[1] & ex3_thread[1]) | (ex1_thread[2] & ex3_thread[2]) | (ex1_thread[3] & ex3_thread[3]);

   assign ex1_thread_match_3 = (ex1_thread[0] & ex4_thread[0]) | (ex1_thread[1] & ex4_thread[1]) | (ex1_thread[2] & ex4_thread[2]) | (ex1_thread[3] & ex4_thread[3]);

   assign ex1_thread_match_4 = (ex1_thread[0] & ex5_thread[0]) | (ex1_thread[1] & ex5_thread[1]) | (ex1_thread[2] & ex5_thread[2]) | (ex1_thread[3] & ex5_thread[3]);

   assign ex1_thread_match_5 = (ex1_thread[0] & ex6_thread[0]) | (ex1_thread[1] & ex6_thread[1]) | (ex1_thread[2] & ex6_thread[2]) | (ex1_thread[3] & ex6_thread[3]);

   assign ex1_rd_sel_byp2 = ex1_thread_match_1 & ex2_mv_to_op;
   assign ex1_rd_sel_byp3 = ex1_thread_match_2 & ex3_mv_to_op;
   assign ex1_rd_sel_byp4 = ex1_thread_match_3 & ex4_mv_to_op;
   assign ex1_rd_sel_byp5 = ex1_thread_match_4 & ex5_mv_to_op;
   assign ex1_rd_sel_byp6 = ex1_thread_match_5 & ex6_mv_to_op;

   assign ex1_rd_sel_0 = ex1_thread[0] & (~ex1_rd_sel_byp2) & (~ex1_rd_sel_byp3) & (~ex1_rd_sel_byp4) & (~ex1_rd_sel_byp5) & (~ex1_rd_sel_byp6);
   assign ex1_rd_sel_1 = ex1_thread[1] & (~ex1_rd_sel_byp2) & (~ex1_rd_sel_byp3) & (~ex1_rd_sel_byp4) & (~ex1_rd_sel_byp5) & (~ex1_rd_sel_byp6);
   assign ex1_rd_sel_2 = ex1_thread[2] & (~ex1_rd_sel_byp2) & (~ex1_rd_sel_byp3) & (~ex1_rd_sel_byp4) & (~ex1_rd_sel_byp5) & (~ex1_rd_sel_byp6);
   assign ex1_rd_sel_3 = ex1_thread[3] & (~ex1_rd_sel_byp2) & (~ex1_rd_sel_byp3) & (~ex1_rd_sel_byp4) & (~ex1_rd_sel_byp5) & (~ex1_rd_sel_byp6);

   assign ex1_rd_sel_byp2_pri = ex1_rd_sel_byp2;
   assign ex1_rd_sel_byp3_pri = (~ex1_rd_sel_byp2) & ex1_rd_sel_byp3;
   assign ex1_rd_sel_byp4_pri = (~ex1_rd_sel_byp2) & (~ex1_rd_sel_byp3) & ex1_rd_sel_byp4;
   assign ex1_rd_sel_byp5_pri = (~ex1_rd_sel_byp2) & (~ex1_rd_sel_byp3) & (~ex1_rd_sel_byp4) & ex1_rd_sel_byp5;
   assign ex1_rd_sel_byp6_pri = (~ex1_rd_sel_byp2) & (~ex1_rd_sel_byp3) & (~ex1_rd_sel_byp4) & (~ex1_rd_sel_byp5) & ex1_rd_sel_byp6;

   ////##############################################
   ////# read mux for pipeline control bits
   ////##############################################

   assign ex2_fpscr_shadow_mux[0:7] = ({8{ex2_rd_sel_0}} & shadow0[0:7]) |
                                      ({8{ex2_rd_sel_1}} & shadow1[0:7]) |
                                      ({8{ex2_rd_sel_2}} & shadow2[0:7]) |
                                      ({8{ex2_rd_sel_3}} & shadow3[0:7]) |
                                      ({8{ex2_rd_sel_byp2}} & shadow_byp2[0:7]) |
                                      ({8{ex2_rd_sel_byp3}} & shadow_byp3[0:7]) |
                                      ({8{ex2_rd_sel_byp4}} & shadow_byp4[0:7]) |
                                      ({8{ex2_rd_sel_byp5}} & shadow_byp5[0:7]) |
                                      ({8{ex2_rd_sel_byp6}} & shadow_byp6[0:7]);
   assign f_cr2_ex2_fpscr_shadow[0:7] = ex2_fpscr_shadow_mux[0:7];

   ////##############################################
   ////# latches
   ////##############################################


   tri_rlmreg_p #(.WIDTH(8)) shadow_byp2_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),		// tidn,
      .mpw1_b(mpw1_b[2]),		// tidn,
      .mpw2_b(mpw2_b[0]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex2_act),
      .scout(shadow_byp2_so),
      .scin(shadow_byp2_si),
      //----------------
      .din(shadow_byp2_din[0:7]),
      .dout(shadow_byp2[0:7])		//LAT--
   );


   tri_rlmreg_p #(.WIDTH(8)) shadow_byp3_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),		// tidn,
      .mpw1_b(mpw1_b[3]),		// tidn,
      .mpw2_b(mpw2_b[0]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex3_act),
      .scout(shadow_byp3_so),
      .scin(shadow_byp3_si),
      //-----------------
      .din(shadow_byp2[0:7]),
      .dout(shadow_byp3[0:7])		//LAT--
   );


   tri_rlmreg_p #(.WIDTH(8)) shadow_byp4_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),		// tidn,
      .mpw1_b(mpw1_b[4]),		// tidn,
      .mpw2_b(mpw2_b[0]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex4_act),
      .scout(shadow_byp4_so),
      .scin(shadow_byp4_si),
      //-----------------
      .din(shadow_byp3[0:7]),
      .dout(shadow_byp4[0:7])		//LAT--
   );


   tri_rlmreg_p #(.WIDTH(8)) shadow_byp5_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[5]),		// tidn,
      .mpw1_b(mpw1_b[5]),		// tidn,
      .mpw2_b(mpw2_b[1]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex5_act),
      .scout(shadow_byp5_so),
      .scin(shadow_byp5_si),
      //-----------------
      .din(shadow_byp4[0:7]),
      .dout(shadow_byp5[0:7])		//LAT--
   );

   tri_rlmreg_p #(.WIDTH(8)) shadow_byp6_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[6]),		// tidn,
      .mpw1_b(mpw1_b[6]),		// tidn,
      .mpw2_b(mpw2_b[1]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex6_act),
      .scout(shadow_byp6_so),
      .scin(shadow_byp6_si),
      //-----------------
      .din(shadow_byp5[0:7]),
      .dout(shadow_byp6[0:7])		//LAT--
   );

   assign ex7_th0_act = ex7_act & ex7_thread[0] & (~ex7_cancel) & ex7_mv_to_op;
   assign ex7_th1_act = ex7_act & ex7_thread[1] & (~ex7_cancel) & ex7_mv_to_op;
   assign ex7_th2_act = ex7_act & ex7_thread[2] & (~ex7_cancel) & ex7_mv_to_op;
   assign ex7_th3_act = ex7_act & ex7_thread[3] & (~ex7_cancel) & ex7_mv_to_op;

   tri_rlmreg_p #(.WIDTH(8)) shadow0_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[7]),		// tidn,
      .mpw1_b(mpw1_b[7]),		// tidn,
      .mpw2_b(mpw2_b[1]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex7_th0_act),
      .scout(shadow0_so),
      .scin(shadow0_si),
      //-----------------
      .din(shadow_byp6[0:7]),
      .dout(shadow0[0:7])		//LAT--
   );


   tri_rlmreg_p #(.WIDTH(8)) shadow1_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[7]),		// tidn,
      .mpw1_b(mpw1_b[7]),		// tidn,
      .mpw2_b(mpw2_b[1]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex7_th1_act),
      .scout(shadow1_so),
      .scin(shadow1_si),
      //-----------------
      .din(shadow_byp6[0:7]),
      .dout(shadow1[0:7])		//LAT--
   );


   tri_rlmreg_p #(.WIDTH(8)) shadow2_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[7]),		// tidn,
      .mpw1_b(mpw1_b[7]),		// tidn,
      .mpw2_b(mpw2_b[1]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex7_th2_act),
      .scout(shadow2_so),
      .scin(shadow2_si),
      //-----------------
      .din(shadow_byp6[0:7]),
      .dout(shadow2[0:7])		//LAT--
   );


   tri_rlmreg_p #(.WIDTH(8)) shadow3_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[7]),		// tidn,
      .mpw1_b(mpw1_b[7]),		// tidn,
      .mpw2_b(mpw2_b[1]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex7_th3_act),
      .scout(shadow3_so),
      .scin(shadow3_si),
      //-----------------
      .din(shadow_byp6[0:7]),
      .dout(shadow3[0:7])		//LAT--
   );

   ////############################################
   ////# scan
   ////############################################

   // initial value must be "11111" for _b latches --

   assign ex2_ctl_si[0:33] = {ex2_ctl_so[1:33], f_cr2_si};
   assign ex3_ctl_si[0:24] = {ex3_ctl_so[1:24], ex2_ctl_so[0]};
   assign ex4_ctl_si[0:24] = {ex4_ctl_so[1:24], ex3_ctl_so[0]};
   assign ex5_ctl_si[0:4] = {ex5_ctl_so[1:4], ex4_ctl_so[0]};
   assign ex6_ctl_si[0:4] = {ex6_ctl_so[1:4], ex5_ctl_so[0]};
   assign ex7_ctl_si[0:4] = {ex7_ctl_so[1:4], ex6_ctl_so[0]};
   assign shadow0_si[0:7] = {shadow0_so[1:7], ex7_ctl_so[0]};
   assign shadow1_si[0:7] = {shadow1_so[1:7], shadow0_so[0]};
   assign shadow2_si[0:7] = {shadow2_so[1:7], shadow1_so[0]};
   assign shadow3_si[0:7] = {shadow3_so[1:7], shadow2_so[0]};
   assign shadow_byp2_si[0:7] = {shadow_byp2_so[1:7], shadow3_so[0]};
   assign shadow_byp3_si[0:7] = {shadow_byp3_so[1:7], shadow_byp2_so[0]};
   assign shadow_byp4_si[0:7] = {shadow_byp4_so[1:7], shadow_byp3_so[0]};
   assign shadow_byp5_si[0:7] = {shadow_byp5_so[1:7], shadow_byp4_so[0]};
   assign shadow_byp6_si[0:7] = {shadow_byp6_so[1:7], shadow_byp5_so[0]};
   assign act_si[0:6] = {act_so[1:6], shadow_byp6_so[0]};
   assign f_cr2_so = act_so[0];

endmodule
