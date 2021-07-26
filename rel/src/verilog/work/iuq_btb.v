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
// This is the ENTITY for iuq_btb
//
// *********************************************************************

`include "tri_a2o.vh"

module iuq_btb(
   // power pins
   inout                         gnd,
   inout                         vdd,
   inout                         vcs,

   // clock and clockcontrol ports
   input [0:`NCLK_WIDTH-1]       nclk,
   input                         pc_iu_func_sl_thold_2,
   input                         pc_iu_sg_2,
   input                         pc_iu_fce_2,
   input                         tc_ac_ccflush_dc,
   input                         clkoff_b,
   input                         act_dis,
   input                         d_mode,
   input                         delay_lclkr,
   input                         mpw1_b,
   input                         mpw2_b,
   input                         scan_in,
   output                        scan_out,

   // ports
   input                         r_act,
   input                         w_act,
   input [0:5]                   r_addr,
   input [0:5]                   w_addr,
   input [0:2*`EFF_IFAR_WIDTH+2]  data_in,
   output [0:2*`EFF_IFAR_WIDTH+2] data_out,
   input			pc_iu_init_reset
   );


   //--------------------------
   // constants
   //--------------------------

      parameter                     data_in_offset = 0;
      parameter                     w_act_offset = data_in_offset + 2 * `EFF_IFAR_WIDTH + 3;
      parameter                     r_act_offset = w_act_offset + 1;
      parameter                     w_addr_offset = r_act_offset + 1;
      parameter                     r_addr_offset = w_addr_offset + 6;
      parameter                     reset_w_addr_offset = r_addr_offset + 6;
      parameter                     data_out_offset = reset_w_addr_offset + 6;
      parameter                     scan_right = data_out_offset + 2 * `EFF_IFAR_WIDTH + 3 - 1;

      //--------------------------
      // signals
      //--------------------------

      wire [0:71]                   w_data_in;
      wire [0:71]                   r_data_out;

      wire [0:5]                    zeros;

      wire                          pc_iu_func_sl_thold_1;
      wire                          pc_iu_func_sl_thold_0;
      wire                          pc_iu_func_sl_thold_0_b;
      wire                          pc_iu_sg_1;
      wire                          pc_iu_sg_0;
      wire                          pc_iu_fce_1;
      (* analysis_not_referenced="true" *)
      wire                          pc_iu_fce_0;
      wire                          force_t;

      wire [0:scan_right]           siv;
      wire [0:scan_right]           sov;

      wire                          tiup;
      wire                          tidn;

      wire                          write_thru;

      wire [0:2*`EFF_IFAR_WIDTH+2]   data_in_d;
      wire [0:2*`EFF_IFAR_WIDTH+2]   data_in_q;
      wire                          w_act_d;
      wire                          w_act_q;
      wire                          r_act_d;
      wire                          r_act_q;
      wire [0:5]                    w_addr_d;
      wire [0:5]                    w_addr_q;
      wire [0:5]                    r_addr_d;
      wire [0:5]                    r_addr_q;
      wire [0:2*`EFF_IFAR_WIDTH+2]   data_out_d;
      wire [0:2*`EFF_IFAR_WIDTH+2]   data_out_q;

      wire                          lat_wi_act;
      wire                          lat_ri_act;
      wire                          lat_ro_act;

      wire		  reset_act;
      wire [0:5]	  reset_w_addr_d;
      wire [0:5]	  reset_w_addr_q;
      wire		  w_act_in;
      wire [0:5]          w_addr_in;

      //unused
(* analysis_not_referenced="true" *)
      wire	abst_scan_out;
(* analysis_not_referenced="true" *)
      wire	time_scan_out;
(* analysis_not_referenced="true" *)
      wire	repr_scan_out;
(* analysis_not_referenced="true" *)
      wire	bo_pc_failout;
(* analysis_not_referenced="true" *)
      wire	bo_pc_diagloop;


      assign tiup = 1'b1;
      assign tidn = 1'b0;

      assign reset_act			= pc_iu_init_reset;
      assign reset_w_addr_d[0:5]	= reset_w_addr_q[0:5] + 6'b000001;


      //-- data in
      //
      assign zeros[0:5] = {6{1'b0}};
      //
      //-- arrays
      //

      // tri array

	assign w_act_in		= reset_act | w_act;
        assign w_addr_in[0:5]	= reset_act ? reset_w_addr_q[0:5] : w_addr[0:5];
	assign w_data_in[0:71]  = reset_act ? 0 : {data_in[0:2 * `EFF_IFAR_WIDTH + 2], {(71 - (2 * `EFF_IFAR_WIDTH + 2)){1'b0}} };


      tri_64x72_1r1w  btb0(
         .vdd(vdd),
         .vcs(vcs),
         .gnd(gnd),
         .nclk(nclk),
         .sg_0(pc_iu_sg_0),
         .abst_sl_thold_0(tidn),
         .ary_nsl_thold_0(tidn),
         .time_sl_thold_0(tiup),
         .repr_sl_thold_0(tiup),
         // Reads
         .rd0_act(r_act),
         .rd0_adr(r_addr),
         .do0(r_data_out),
         // Writes
         .wr_act(w_act_in),
         .wr_adr(w_addr_in),
         .di(w_data_in),
         // Scan
         .abst_scan_in(tidn),
         .abst_scan_out(abst_scan_out),
         .time_scan_in(tidn),
         .time_scan_out(time_scan_out),
         .repr_scan_in(tidn),
         .repr_scan_out(repr_scan_out),
         // Misc Pervasive
         .scan_dis_dc_b(tidn),		//an_ac_scan_dis_dc_b,
         .scan_diag_dc(tidn),		//an_ac_scan_diag_dc,
         .ccflush_dc(tc_ac_ccflush_dc),
         .clkoff_dc_b(clkoff_b),		//g8t_clkoff_dc_b,
         .d_mode_dc(d_mode),		//g8t_d_mode_dc,
         .mpw1_dc_b({5{mpw1_b}}),		//g8t_mpw1_dc_b,
         .mpw2_dc_b(mpw2_b),		//g8t_mpw2_dc_b,
         .delay_lclkr_dc({5{delay_lclkr}}),		//g8t_delay_lclkr_dc,
         // BOLT-ON
         .lcb_bolt_sl_thold_0(tidn),		//bolt_sl_thold_0,
         .pc_bo_enable_2(tidn),		//bo_enable_2,                       -- general bolt-on enable
         .pc_bo_reset(tidn),		//pc_xu_bo_reset,                    -- reset
         .pc_bo_unload(tidn),		//pc_xu_bo_unload,                   -- unload sticky bits
         .pc_bo_repair(tidn),		//pc_xu_bo_repair,                   -- execute sticky bit decode
         .pc_bo_shdata(tidn),		//pc_xu_bo_shdata,                   -- shift data for timing write and diag loop
         .pc_bo_select(tidn),		//pc_xu_bo_select,                   -- select for mask and hier writes
         .bo_pc_failout(bo_pc_failout),
         .bo_pc_diagloop(bo_pc_diagloop),
         .tri_lcb_mpw1_dc_b(mpw1_b),		//mpw1_dc_b,
         .tri_lcb_mpw2_dc_b(mpw2_b),		//mpw2_dc_b,
         .tri_lcb_delay_lclkr_dc(delay_lclkr),		//delay_lclkr_dc,
         .tri_lcb_clkoff_dc_b(clkoff_b),		//clkoff_dc_b,
         .tri_lcb_act_dis_dc(act_dis),
         // ABIST
         .abist_bw_odd(tidn),		//abist_g8t_bw_1_q,
         .abist_bw_even(tidn),		//abist_g8t_bw_0_q,
         .tc_lbist_ary_wrt_thru_dc(tidn),		//an_ac_lbist_ary_wrt_thru_dc,
         .abist_ena_1(tidn),		//pc_xu_abist_ena_dc,
         .wr_abst_act(tidn),		//abist_g8t_wenb_q,
         .abist_wr_adr(zeros[0:5]),		//abist_waddr_0_q,
         .abist_di(zeros[0:3]),		//abist_di_0_q,
         .rd0_abst_act(tidn),		//abist_g8t1p_renb_0_q,
         .abist_rd0_adr(zeros[0:5]),		//abist_raddr_0_q,
         .abist_g8t_rd0_comp_ena(tidn),		//abist_wl32_comp_ena_q,
         .abist_raw_dc_b(tidn),		//pc_xu_abist_raw_dc_b,
         .obs0_abist_cmp(zeros[0:3])		//abist_g8t_dcomp_q
      );

      // write through support

      assign data_in_d[0:2 * `EFF_IFAR_WIDTH + 2] = data_in[0:2 * `EFF_IFAR_WIDTH + 2];
      assign w_act_d = w_act;
      assign r_act_d = r_act;
      assign w_addr_d[0:5] = w_addr[0:5];
      assign r_addr_d[0:5] = r_addr[0:5];

      assign write_thru = w_act_q & (w_addr_q[0:5] == r_addr_q[0:5]) & r_act_q;

      // data out

      assign data_out_d[0:2 * `EFF_IFAR_WIDTH + 2] = (write_thru == 1'b1) ? data_in_q[0:2 * `EFF_IFAR_WIDTH + 2] :
                                                    r_data_out[0:2 * `EFF_IFAR_WIDTH + 2];

      assign data_out[0:2 * `EFF_IFAR_WIDTH + 2] = data_out_q[0:2 * `EFF_IFAR_WIDTH + 2];

      //latch acts
      assign lat_wi_act = w_act;
      assign lat_ri_act = r_act;
      assign lat_ro_act = r_act_q;

      // latches


      tri_rlmreg_p #(.WIDTH((2*`EFF_IFAR_WIDTH+2+1)), .INIT(0)) data_in_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lat_wi_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[data_in_offset:data_in_offset + (2*`EFF_IFAR_WIDTH+2+1) - 1]),
         .scout(sov[data_in_offset:data_in_offset + (2*`EFF_IFAR_WIDTH+2+1) - 1]),
         .din(data_in_d),
         .dout(data_in_q)
      );


      tri_rlmlatch_p #(.INIT(0)) w_act_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tiup),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[w_act_offset]),
         .scout(sov[w_act_offset]),
         .din(w_act_d),
         .dout(w_act_q)
      );


      tri_rlmlatch_p #(.INIT(0)) r_act_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tiup),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[r_act_offset]),
         .scout(sov[r_act_offset]),
         .din(r_act_d),
         .dout(r_act_q)
      );


      tri_rlmreg_p #(.WIDTH(6), .INIT(0)) w_addr_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lat_wi_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[w_addr_offset:w_addr_offset + 6 - 1]),
         .scout(sov[w_addr_offset:w_addr_offset + 6 - 1]),
         .din(w_addr_d),
         .dout(w_addr_q)
      );


      tri_rlmreg_p #(.WIDTH(6), .INIT(0)) r_addr_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lat_ri_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[r_addr_offset:r_addr_offset + 6 - 1]),
         .scout(sov[r_addr_offset:r_addr_offset + 6 - 1]),
         .din(r_addr_d),
         .dout(r_addr_q)
      );


      tri_rlmreg_p #(.WIDTH((2*`EFF_IFAR_WIDTH+2+1)), .INIT(0)) data_out_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lat_ro_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[data_out_offset:data_out_offset + (2*`EFF_IFAR_WIDTH+2+1) - 1]),
         .scout(sov[data_out_offset:data_out_offset + (2*`EFF_IFAR_WIDTH+2+1) - 1]),
         .din(data_out_d),
         .dout(data_out_q)
      );

      tri_rlmreg_p #(.WIDTH(6), .INIT(0)) reset_w_addr_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reset_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[reset_w_addr_offset:reset_w_addr_offset + 6 - 1]),
         .scout(sov[reset_w_addr_offset:reset_w_addr_offset + 6 - 1]),
         .din(reset_w_addr_d),
         .dout(reset_w_addr_q)
      );

      //-----------------------------------------------
      // pervasive
      //-----------------------------------------------


      tri_plat #(.WIDTH(3)) perv_2to1_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ac_ccflush_dc),
         .din({pc_iu_func_sl_thold_2, pc_iu_sg_2, pc_iu_fce_2}),
         .q({pc_iu_func_sl_thold_1, pc_iu_sg_1, pc_iu_fce_1})
      );


      tri_plat #(.WIDTH(3)) perv_1to0_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ac_ccflush_dc),
         .din({pc_iu_func_sl_thold_1, pc_iu_sg_1, pc_iu_fce_1}),
         .q({pc_iu_func_sl_thold_0, pc_iu_sg_0, pc_iu_fce_0})
      );


      tri_lcbor  perv_lcbor(
         .clkoff_b(clkoff_b),
         .thold(pc_iu_func_sl_thold_0),
         .sg(pc_iu_sg_0),
         .act_dis(act_dis),
         .force_t(force_t),
         .thold_b(pc_iu_func_sl_thold_0_b)
      );

      //-----------------------------------------------
      // scan
      //-----------------------------------------------

      assign siv[0:scan_right] = {scan_in, sov[0:scan_right - 1]};
      assign scan_out = sov[scan_right];


endmodule
