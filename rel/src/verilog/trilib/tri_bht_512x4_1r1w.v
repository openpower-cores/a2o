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
// This is the ENTITY for tri_bht_512x4_1r1w
//
// *********************************************************************

(* block_type="soft" *)
(* recursive_synthesis="2" *)
(* pin_default_power_domain="vdd" *)
(* pin_default_ground_domain ="gnd" *)

`include "tri_a2o.vh"

module tri_bht_512x4_1r1w(
   gnd,
   vdd,
   vcs,
   nclk,
   pc_iu_func_sl_thold_2,
   pc_iu_sg_2,
   pc_iu_time_sl_thold_2,
   pc_iu_abst_sl_thold_2,
   pc_iu_ary_nsl_thold_2,
   pc_iu_repr_sl_thold_2,
   pc_iu_bolt_sl_thold_2,
   tc_ac_ccflush_dc,
   tc_ac_scan_dis_dc_b,
   clkoff_b,
   scan_diag_dc,
   act_dis,
   d_mode,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   g8t_clkoff_b,
   g8t_d_mode,
   g8t_delay_lclkr,
   g8t_mpw1_b,
   g8t_mpw2_b,
   func_scan_in,
   time_scan_in,
   abst_scan_in,
   repr_scan_in,
   func_scan_out,
   time_scan_out,
   abst_scan_out,
   repr_scan_out,
   pc_iu_abist_di_0,
   pc_iu_abist_g8t_bw_1,
   pc_iu_abist_g8t_bw_0,
   pc_iu_abist_waddr_0,
   pc_iu_abist_g8t_wenb,
   pc_iu_abist_raddr_0,
   pc_iu_abist_g8t1p_renb_0,
   an_ac_lbist_ary_wrt_thru_dc,
   pc_iu_abist_ena_dc,
   pc_iu_abist_wl128_comp_ena,
   pc_iu_abist_raw_dc_b,
   pc_iu_abist_g8t_dcomp,
   pc_iu_bo_enable_2,
   pc_iu_bo_reset,
   pc_iu_bo_unload,
   pc_iu_bo_repair,
   pc_iu_bo_shdata,
   pc_iu_bo_select,
   iu_pc_bo_fail,
   iu_pc_bo_diagout,
   r_act,
   w_act,
   r_addr,
   w_addr,
   data_in,
   data_out0,
   data_out1,
   data_out2,
   data_out3,
   pc_iu_init_reset
);
   // power pins
   inout               gnd;
   inout               vdd;
   inout               vcs;

   // clock and clockcontrol ports
   input [0:`NCLK_WIDTH-1]              nclk;
   input               pc_iu_func_sl_thold_2;
   input               pc_iu_sg_2;
   input               pc_iu_time_sl_thold_2;
   input               pc_iu_abst_sl_thold_2;
   input               pc_iu_ary_nsl_thold_2;
   input               pc_iu_repr_sl_thold_2;
   input               pc_iu_bolt_sl_thold_2;
   input               tc_ac_ccflush_dc;
   input               tc_ac_scan_dis_dc_b;
   input               clkoff_b;
   input               scan_diag_dc;
   input               act_dis;
   input               d_mode;
   input               delay_lclkr;
   input               mpw1_b;
   input               mpw2_b;
   input               g8t_clkoff_b;
   input               g8t_d_mode;
   input [0:4]         g8t_delay_lclkr;
   input [0:4]         g8t_mpw1_b;
   input               g8t_mpw2_b;
   input               func_scan_in;
   input               time_scan_in;
   input               abst_scan_in;
   input               repr_scan_in;
   output              func_scan_out;
   output              time_scan_out;
   output              abst_scan_out;
   output              repr_scan_out;

   input [0:3]         pc_iu_abist_di_0;
   input               pc_iu_abist_g8t_bw_1;
   input               pc_iu_abist_g8t_bw_0;
   input [3:9]         pc_iu_abist_waddr_0;
   input               pc_iu_abist_g8t_wenb;
   input [3:9]         pc_iu_abist_raddr_0;
   input               pc_iu_abist_g8t1p_renb_0;
   input               an_ac_lbist_ary_wrt_thru_dc;
   input               pc_iu_abist_ena_dc;
   input               pc_iu_abist_wl128_comp_ena;
   input               pc_iu_abist_raw_dc_b;
   input [0:3]         pc_iu_abist_g8t_dcomp;

   // BOLT-ON
   input               pc_iu_bo_enable_2;		// general bolt-on enable
   input               pc_iu_bo_reset;		// reset
   input               pc_iu_bo_unload;		// unload sticky bits
   input               pc_iu_bo_repair;		// execute sticky bit decode
   input               pc_iu_bo_shdata;		// shift data for timing write and diag loop
   input               pc_iu_bo_select;		// select for mask and hier writes
   output              iu_pc_bo_fail;		// fail/no-fix reg
   output              iu_pc_bo_diagout;

   // ports
   input               r_act;
   input [0:3]         w_act;
   input [0:8]         r_addr;
   input [0:8]         w_addr;
   input	       data_in;
   output              data_out0;
   output              data_out1;
   output              data_out2;
   output              data_out3;

   input               pc_iu_init_reset;

   //--------------------------
   // constants
   //--------------------------


      parameter           data_in_offset = 0;
      parameter           w_act_offset = data_in_offset + 1;
      parameter           r_act_offset = w_act_offset + 4;
      parameter           w_addr_offset = r_act_offset + 1;
      parameter           r_addr_offset = w_addr_offset + 9;
      parameter           data_out_offset = r_addr_offset + 9;
      parameter           reset_w_addr_offset = data_out_offset + 4;
      parameter           array_offset = reset_w_addr_offset + 9;
      parameter           scan_right = array_offset + 1 - 1;

      //--------------------------
      // signals
      //--------------------------

      wire                pc_iu_func_sl_thold_1;
      wire                pc_iu_func_sl_thold_0;
      wire                pc_iu_func_sl_thold_0_b;
      wire                pc_iu_time_sl_thold_1;
      wire                pc_iu_time_sl_thold_0;
      wire                pc_iu_ary_nsl_thold_1;
      wire                pc_iu_ary_nsl_thold_0;
      wire                pc_iu_abst_sl_thold_1;
      wire                pc_iu_abst_sl_thold_0;
      wire                pc_iu_repr_sl_thold_1;
      wire                pc_iu_repr_sl_thold_0;
      wire                pc_iu_bolt_sl_thold_1;
      wire                pc_iu_bolt_sl_thold_0;
      wire                pc_iu_sg_1;
      wire                pc_iu_sg_0;
      wire                force_t;

      wire [0:scan_right] siv;
      wire [0:scan_right] sov;

      wire                tiup;

      wire [0:3]          data_out_d;
      wire [0:3]          data_out_q;

      wire                ary_w_en;
      wire [0:8]          ary_w_addr;
      wire [0:15]         ary_w_sel;
      wire [0:15]         ary_w_data;

      wire                ary_r_en;
      wire [0:8]          ary_r_addr;
      wire [0:15]         ary_r_data;

      wire [0:3]          data_out;
      wire [0:3]          write_thru;

      wire                data_in_d;
      wire                data_in_q;
      wire [0:3]          w_act_d;
      wire [0:3]          w_act_q;
      wire                r_act_d;
      wire                r_act_q;
      wire [0:8]          w_addr_d;
      wire [0:8]          w_addr_q;
      wire [0:8]          r_addr_d;
      wire [0:8]          r_addr_q;

      wire                lat_wi_act;
      wire                lat_ri_act;
      wire                lat_ro_act;

      wire		  reset_act;
      wire [0:8]	  reset_w_addr_d;
      wire [0:8]	  reset_w_addr_q;



      assign tiup = 1'b1;

      assign reset_act			= pc_iu_init_reset;
      assign reset_w_addr_d[0:8]	= reset_w_addr_q[0:8] + 9'b000000001;

      assign data_out0 = data_out_q[0];
      assign data_out1 = data_out_q[1];
      assign data_out2 = data_out_q[2];
      assign data_out3 = data_out_q[3];

      assign ary_w_en = reset_act | (|(w_act[0:3]) & (~((w_addr[0:8] == r_addr[0:8]) & r_act == 1'b1)));

      assign ary_w_addr[0:8] = reset_act ? reset_w_addr_q[0:8] : w_addr[0:8];

      assign ary_w_sel[0] = reset_act ? 1'b1 : w_act[0];
      assign ary_w_sel[1] = reset_act ? 1'b1 : w_act[1];
      assign ary_w_sel[2] = reset_act ? 1'b1 : w_act[2];
      assign ary_w_sel[3] = reset_act ? 1'b1 : w_act[3];
      assign ary_w_sel[4] = reset_act ? 1'b1 : 1'b0;
      assign ary_w_sel[5] = reset_act ? 1'b1 : 1'b0;
      assign ary_w_sel[6] = reset_act ? 1'b1 : 1'b0;
      assign ary_w_sel[7] = reset_act ? 1'b1 : 1'b0;
      assign ary_w_sel[8] = reset_act ? 1'b1 : 1'b0;
      assign ary_w_sel[9] = reset_act ? 1'b1 : 1'b0;
      assign ary_w_sel[10] = reset_act ? 1'b1 : 1'b0;
      assign ary_w_sel[11] = reset_act ? 1'b1 : 1'b0;
      assign ary_w_sel[12] = reset_act ? 1'b1 : 1'b0;
      assign ary_w_sel[13] = reset_act ? 1'b1 : 1'b0;
      assign ary_w_sel[14] = reset_act ? 1'b1 : 1'b0;
      assign ary_w_sel[15] = reset_act ? 1'b1 : 1'b0;

      assign ary_w_data[0:15] = reset_act ? 16'b0000000000000000:
                                            {data_in, data_in, data_in, data_in, 12'b000000000000};

      assign ary_r_en = r_act;

      assign ary_r_addr[0:8] = r_addr[0:8];

      assign data_out[0:3] = ary_r_data[0:3];

      //write through support

      assign data_in_d = data_in;
      assign w_act_d[0:3] = w_act[0:3];
      assign r_act_d = r_act;
      assign w_addr_d[0:8] = w_addr[0:8];
      assign r_addr_d[0:8] = r_addr[0:8];

      assign write_thru[0:3] = ((w_addr_q[0:8] == r_addr_q[0:8]) & r_act_q == 1'b1) ? w_act_q[0:3] :
                               4'b0000;

      assign data_out_d[0] = (write_thru[0] == 1'b1) ? data_in_q :
                              data_out[0];
      assign data_out_d[1] = (write_thru[1] == 1'b1) ? data_in_q :
                              data_out[1];
      assign data_out_d[2] = (write_thru[2] == 1'b1) ? data_in_q :
                              data_out[2];
      assign data_out_d[3] = (write_thru[3] == 1'b1) ? data_in_q :
                              data_out[3];

      //latch acts
      assign lat_wi_act = |(w_act[0:3]);
      assign lat_ri_act = r_act;
      assign lat_ro_act = r_act_q;

      //-----------------------------------------------
      // array
      //-----------------------------------------------



            tri_512x16_1r1w_1  bht0(
               .gnd(gnd),
               .vdd(vdd),
               .vcs(vcs),
               .nclk(nclk),

               .rd_act(ary_r_en),
               .wr_act(ary_w_en),

               .lcb_d_mode_dc(g8t_d_mode),
               .lcb_clkoff_dc_b(g8t_clkoff_b),
               .lcb_mpw1_dc_b(g8t_mpw1_b),
               .lcb_mpw2_dc_b(g8t_mpw2_b),
               .lcb_delay_lclkr_dc(g8t_delay_lclkr),
               .ccflush_dc(tc_ac_ccflush_dc),
               .scan_dis_dc_b(tc_ac_scan_dis_dc_b),
               .scan_diag_dc(scan_diag_dc),
               .func_scan_in(siv[array_offset]),
               .func_scan_out(sov[array_offset]),

               .lcb_sg_0(pc_iu_sg_0),
               .lcb_sl_thold_0_b(pc_iu_func_sl_thold_0_b),
               .lcb_time_sl_thold_0(pc_iu_time_sl_thold_0),
               .lcb_abst_sl_thold_0(pc_iu_abst_sl_thold_0),
               .lcb_ary_nsl_thold_0(pc_iu_ary_nsl_thold_0),
               .lcb_repr_sl_thold_0(pc_iu_repr_sl_thold_0),
               .time_scan_in(time_scan_in),
               .time_scan_out(time_scan_out),
               .abst_scan_in(abst_scan_in),
               .abst_scan_out(abst_scan_out),
               .repr_scan_in(repr_scan_in),
               .repr_scan_out(repr_scan_out),

               .abist_di(pc_iu_abist_di_0),
               .abist_bw_odd(pc_iu_abist_g8t_bw_1),
               .abist_bw_even(pc_iu_abist_g8t_bw_0),
               .abist_wr_adr(pc_iu_abist_waddr_0),
               .wr_abst_act(pc_iu_abist_g8t_wenb),
               .abist_rd0_adr(pc_iu_abist_raddr_0),
               .rd0_abst_act(pc_iu_abist_g8t1p_renb_0),
               .tc_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
               .abist_ena_1(pc_iu_abist_ena_dc),
               .abist_g8t_rd0_comp_ena(pc_iu_abist_wl128_comp_ena),
               .abist_raw_dc_b(pc_iu_abist_raw_dc_b),
               .obs0_abist_cmp(pc_iu_abist_g8t_dcomp),

               .lcb_bolt_sl_thold_0(pc_iu_bolt_sl_thold_0),
               .pc_bo_enable_2(pc_iu_bo_enable_2),
               .pc_bo_reset(pc_iu_bo_reset),
               .pc_bo_unload(pc_iu_bo_unload),
               .pc_bo_repair(pc_iu_bo_repair),
               .pc_bo_shdata(pc_iu_bo_shdata),
               .pc_bo_select(pc_iu_bo_select),
               .bo_pc_failout(iu_pc_bo_fail),
               .bo_pc_diagloop(iu_pc_bo_diagout),

               .tri_lcb_mpw1_dc_b(mpw1_b),
               .tri_lcb_mpw2_dc_b(mpw2_b),
               .tri_lcb_delay_lclkr_dc(delay_lclkr),
               .tri_lcb_clkoff_dc_b(clkoff_b),
               .tri_lcb_act_dis_dc(act_dis),

               .bw(ary_w_sel),
               .wr_adr(ary_w_addr),
               .rd_adr(ary_r_addr),
               .di(ary_w_data),
               .do(ary_r_data)
            );

      //-----------------------------------------------
      // latches
      //-----------------------------------------------


      tri_rlmlatch_p #(.INIT(0)) data_in_reg(
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
         .scin(siv[data_in_offset:data_in_offset]),
         .scout(sov[data_in_offset:data_in_offset]),
         .din(data_in_d),
         .dout(data_in_q)
      );


      tri_rlmreg_p #(.WIDTH(4), .INIT(0)) w_act_reg(
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
         .scin(siv[w_act_offset:w_act_offset + 4 - 1]),
         .scout(sov[w_act_offset:w_act_offset + 4 - 1]),
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


      tri_rlmreg_p #(.WIDTH(9), .INIT(0)) w_addr_reg(
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
         .scin(siv[w_addr_offset:w_addr_offset + 9 - 1]),
         .scout(sov[w_addr_offset:w_addr_offset + 9 - 1]),
         .din(w_addr_d),
         .dout(w_addr_q)
      );


      tri_rlmreg_p #(.WIDTH(9), .INIT(0)) r_addr_reg(
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
         .scin(siv[r_addr_offset:r_addr_offset + 9 - 1]),
         .scout(sov[r_addr_offset:r_addr_offset + 9 - 1]),
         .din(r_addr_d),
         .dout(r_addr_q)
      );


      tri_rlmreg_p #(.WIDTH(4), .INIT(0)) data_out_reg(
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
         .scin(siv[data_out_offset:data_out_offset + 4 - 1]),
         .scout(sov[data_out_offset:data_out_offset + 4 - 1]),
         .din(data_out_d),
         .dout(data_out_q)
      );

      tri_rlmreg_p #(.WIDTH(9), .INIT(0)) reset_w_addr_reg(
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
         .scin(siv[reset_w_addr_offset:reset_w_addr_offset + 9 - 1]),
         .scout(sov[reset_w_addr_offset:reset_w_addr_offset + 9 - 1]),
         .din(reset_w_addr_d),
         .dout(reset_w_addr_q)
      );

      //-----------------------------------------------
      // pervasive
      //-----------------------------------------------


      tri_plat #(.WIDTH(7)) perv_2to1_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ac_ccflush_dc),
         .din({pc_iu_func_sl_thold_2, pc_iu_sg_2, pc_iu_time_sl_thold_2, pc_iu_abst_sl_thold_2, pc_iu_ary_nsl_thold_2, pc_iu_repr_sl_thold_2, pc_iu_bolt_sl_thold_2}),
         .q({pc_iu_func_sl_thold_1, pc_iu_sg_1, pc_iu_time_sl_thold_1, pc_iu_abst_sl_thold_1, pc_iu_ary_nsl_thold_1, pc_iu_repr_sl_thold_1, pc_iu_bolt_sl_thold_1})
      );


      tri_plat #(.WIDTH(7)) perv_1to0_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ac_ccflush_dc),
         .din({pc_iu_func_sl_thold_1, pc_iu_sg_1, pc_iu_time_sl_thold_1, pc_iu_abst_sl_thold_1, pc_iu_ary_nsl_thold_1, pc_iu_repr_sl_thold_1, pc_iu_bolt_sl_thold_1}),
         .q({pc_iu_func_sl_thold_0, pc_iu_sg_0, pc_iu_time_sl_thold_0, pc_iu_abst_sl_thold_0, pc_iu_ary_nsl_thold_0, pc_iu_repr_sl_thold_0, pc_iu_bolt_sl_thold_0})
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

      assign siv[0:scan_right] = {func_scan_in, sov[0:scan_right - 1]};
      assign func_scan_out = sov[scan_right];


endmodule
