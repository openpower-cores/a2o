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

//-----------------------------------------------------------------------------------------------------
// Title:   rv_dep.vhdl
// Desc:       Holds the dependency scorecards and second level of itag muxing.
//
//-----------------------------------------------------------------------------------------------------

module rv_dep(

`include "tri_a2o.vh"


	      //------------------------------------------------------------------------------------------------------------
	      // IU Control
	      //------------------------------------------------------------------------------------------------------------
	      input                         iu_xx_zap,
	      input                         rv0_i0_act,
	      input                         rv0_i1_act,

	      //------------------------------------------------------------------------------------------------------------
	      // Instruction Sources
	      //------------------------------------------------------------------------------------------------------------
	      input 			 rv0_instr_i0_vld,
	      input                         rv0_instr_i0_t1_v,
	      input                         rv0_instr_i0_t2_v,
	      input                         rv0_instr_i0_t3_v,
	      input [0:`ITAG_SIZE_ENC-1]     rv0_instr_i0_itag,

	      input                         rv0_instr_i0_s1_v,
	      input [0:`ITAG_SIZE_ENC-1]     rv0_instr_i0_s1_itag,
	      input                         rv0_instr_i0_s2_v,
	      input [0:`ITAG_SIZE_ENC-1]     rv0_instr_i0_s2_itag,
	      input                         rv0_instr_i0_s3_v,
	      input [0:`ITAG_SIZE_ENC-1]     rv0_instr_i0_s3_itag,

	      input 			 rv0_instr_i1_vld,
	      input                         rv0_instr_i1_t1_v,
	      input                         rv0_instr_i1_t2_v,
	      input                         rv0_instr_i1_t3_v,
	      input [0:`ITAG_SIZE_ENC-1]     rv0_instr_i1_itag,

	      input                         rv0_instr_i1_s1_v,
	      input [0:`ITAG_SIZE_ENC-1] 	 rv0_instr_i1_s1_itag,
	      input                         rv0_instr_i1_s2_v,
	      input [0:`ITAG_SIZE_ENC-1] 	 rv0_instr_i1_s2_itag,
	      input                         rv0_instr_i1_s3_v,
	      input [0:`ITAG_SIZE_ENC-1] 	 rv0_instr_i1_s3_itag,

	      //------------------------------------------------------------------------------------------------------------
	      // ITAG Busses
	      //------------------------------------------------------------------------------------------------------------
	      input 			 fx0_rv_itag_vld,
	      input [0:`ITAG_SIZE_ENC-1] 	 fx0_rv_itag,
	      input 			 fx1_rv_itag_vld,
	      input [0:`ITAG_SIZE_ENC-1] 	 fx1_rv_itag,
	      input 			 lq_rv_itag0_vld,
	      input [0:`ITAG_SIZE_ENC-1] 	 lq_rv_itag0,
	      input 			 lq_rv_itag1_vld,
	      input [0:`ITAG_SIZE_ENC-1] 	 lq_rv_itag1,
	      input 			 lq_rv_itag2_vld,
	      input [0:`ITAG_SIZE_ENC-1] 	 lq_rv_itag2,
	      input 			 axu0_rv_itag_vld,
	      input [0:`ITAG_SIZE_ENC-1] 	 axu0_rv_itag,
	      input 			 axu1_rv_itag_vld,
	      input [0:`ITAG_SIZE_ENC-1] 	 axu1_rv_itag,

	      input 			   fx0_rv_itag_abort,
	      input 			   fx1_rv_itag_abort,
	      input 			   lq_rv_itag0_abort,
	      input 			   lq_rv_itag1_abort,
	      input 			   axu0_rv_itag_abort,
	      input 			   axu1_rv_itag_abort,

	      //------------------------------------------------------------------------------------------------------------
	      // Source Hit Information
	      //------------------------------------------------------------------------------------------------------------
	      output                        rv0_instr_i0_s1_dep_hit,
	      output                        rv0_instr_i0_s2_dep_hit,
	      output                        rv0_instr_i0_s3_dep_hit,

	      output                        rv0_instr_i1_s1_dep_hit,
	      output                        rv0_instr_i1_s2_dep_hit,
	      output                        rv0_instr_i1_s3_dep_hit,

	      //------------------------------------------------------------------------------------------------------------
	      // Pervasive
	      //------------------------------------------------------------------------------------------------------------
	      inout                         vdd,
	      inout                         gnd,
	      (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) // nclk
	      input [0:`NCLK_WIDTH-1] 	 nclk,

	      input                         func_sl_thold_1,
	      input                         sg_1,
	      input                         clkoff_b,
	      input                         act_dis,
	      input                         ccflush_dc,

	      input                         d_mode,
	      input                         delay_lclkr,
	      input                         mpw1_b,
	      input                         mpw2_b,
	      input                         scan_in,
	      output                        scan_out
	      );

   //------------------------------------------------------------------------------------------------------------
   // Misc
   //------------------------------------------------------------------------------------------------------------
   wire                          tiup;

   parameter                     zero = 0;

   //------------------------------------------------------------------------------------------------------------
   // Input Latches
   //------------------------------------------------------------------------------------------------------------
   wire                          rv0_sc_act;
   wire [0:6] 			 xx_rv_itag_v_d;
   wire [0:6] 			 xx_rv_itag_v_q;
   wire [0:6] 			 xx_rv_itag_abort_d;
   wire [0:6] 			 xx_rv_itag_abort_q;
   wire [0:`ITAG_SIZE_ENC-2-1] 	 xx_rv_itag_ary0_d;
   wire [0:`ITAG_SIZE_ENC-2-1] 	 xx_rv_itag_ary1_d;
   wire [0:`ITAG_SIZE_ENC-2-1] 	 xx_rv_itag_ary2_d;
   wire [0:`ITAG_SIZE_ENC-2-1] 	 xx_rv_itag_ary3_d;
   wire [0:`ITAG_SIZE_ENC-2-1] 	 xx_rv_itag_ary4_d;
   wire [0:`ITAG_SIZE_ENC-2-1] 	 xx_rv_itag_ary5_d;
   wire [0:`ITAG_SIZE_ENC-2-1] 	 xx_rv_itag_ary6_d;
   wire [0:`ITAG_SIZE_ENC-2-1] 	 xx_rv_itag_ary0_q;
   wire [0:`ITAG_SIZE_ENC-2-1] 	 xx_rv_itag_ary1_q;
   wire [0:`ITAG_SIZE_ENC-2-1] 	 xx_rv_itag_ary2_q;
   wire [0:`ITAG_SIZE_ENC-2-1] 	 xx_rv_itag_ary3_q;
   wire [0:`ITAG_SIZE_ENC-2-1] 	 xx_rv_itag_ary4_q;
   wire [0:`ITAG_SIZE_ENC-2-1] 	 xx_rv_itag_ary5_q;
   wire [0:`ITAG_SIZE_ENC-2-1] 	 xx_rv_itag_ary6_q;

   //------------------------------------------------------------------------------------------------------------
   // GPR PRF Scorecard Signals
   //------------------------------------------------------------------------------------------------------------

   wire 			 i0_target_v;
   wire 			 i1_target_v;

   wire                          rv0_instr_i0_s1_dep_hit_v;
   wire                          rv0_instr_i0_s2_dep_hit_v;
   wire                          rv0_instr_i0_s3_dep_hit_v;
   wire                          rv0_instr_i1_s1_dep_hit_v;
   wire                          rv0_instr_i1_s2_dep_hit_v;
   wire                          rv0_instr_i1_s3_dep_hit_v;

   //------------------------------------------------------------------------------------------------------------
   // Scan
   //------------------------------------------------------------------------------------------------------------
   parameter                     scorecard_offset = 0;
   parameter                     xx_rv_itag_v_offset = scorecard_offset + 1;
   parameter                     xx_rv_itag_abort_offset = xx_rv_itag_v_offset + 7;
   parameter                     xx_rv_itag_ary0_offset = xx_rv_itag_abort_offset + 7;
   parameter                     xx_rv_itag_ary1_offset = xx_rv_itag_ary0_offset + `ITAG_SIZE_ENC-2;
   parameter                     xx_rv_itag_ary2_offset = xx_rv_itag_ary1_offset + `ITAG_SIZE_ENC-2;
   parameter                     xx_rv_itag_ary3_offset = xx_rv_itag_ary2_offset + `ITAG_SIZE_ENC-2;
   parameter                     xx_rv_itag_ary4_offset = xx_rv_itag_ary3_offset + `ITAG_SIZE_ENC-2;
   parameter                     xx_rv_itag_ary5_offset = xx_rv_itag_ary4_offset + `ITAG_SIZE_ENC-2;
   parameter                     xx_rv_itag_ary6_offset = xx_rv_itag_ary5_offset + `ITAG_SIZE_ENC-2;

   parameter                     scan_right = xx_rv_itag_ary6_offset + `ITAG_SIZE_ENC-2;
   wire [0:scan_right-1]         siv;
   wire [0:scan_right-1]         sov;

   wire                          func_sl_thold_0;
   wire                          func_sl_thold_0_b;
   wire                          sg_0;
   wire                          force_t;
   (* analysis_not_referenced="true" *)
   wire 			 unused;

   assign rv0_sc_act = rv0_i0_act | rv0_i1_act | (|xx_rv_itag_v_q) | (|iu_xx_zap);

   //------------------------------------------------------------------------------------------------------------
   // GPR PRF Scorecard
   //------------------------------------------------------------------------------------------------------------

   assign i0_target_v = rv0_instr_i0_vld & (rv0_instr_i0_t1_v | rv0_instr_i0_t2_v | rv0_instr_i0_t3_v);
   assign i1_target_v = rv0_instr_i1_vld & (rv0_instr_i1_t1_v | rv0_instr_i1_t2_v | rv0_instr_i1_t3_v);


   //num_entries_enc_g       => ``GPR_POOL_ENC,
   rv_dep_scard #(.num_entries_g(2 ** (`ITAG_SIZE_ENC - 2)), .itag_width_enc_g(`ITAG_SIZE_ENC - 2) ) sc(
      .iu_xx_zap(iu_xx_zap),
      .rv0_sc_act(rv0_sc_act),

      .ta_v(i0_target_v),
      .ta_itag(rv0_instr_i0_itag[2:`ITAG_SIZE_ENC - 1]),

      .tb_v(i1_target_v),
      .tb_itag(rv0_instr_i1_itag[2:`ITAG_SIZE_ENC - 1]),

      .xx_rv_itag_v(xx_rv_itag_v_q),
      .xx_rv_itag_abort(xx_rv_itag_abort_q),
      .xx_rv_itag_ary0(xx_rv_itag_ary0_q),
      .xx_rv_itag_ary1(xx_rv_itag_ary1_q),
      .xx_rv_itag_ary2(xx_rv_itag_ary2_q),
      .xx_rv_itag_ary3(xx_rv_itag_ary3_q),
      .xx_rv_itag_ary4(xx_rv_itag_ary4_q),
      .xx_rv_itag_ary5(xx_rv_itag_ary5_q),
      .xx_rv_itag_ary6(xx_rv_itag_ary6_q),

      .i0_s1_itag(rv0_instr_i0_s1_itag[2:`ITAG_SIZE_ENC - 1]),
      .i0_s2_itag(rv0_instr_i0_s2_itag[2:`ITAG_SIZE_ENC - 1]),
      .i0_s3_itag(rv0_instr_i0_s3_itag[2:`ITAG_SIZE_ENC - 1]),
      .i1_s1_itag(rv0_instr_i1_s1_itag[2:`ITAG_SIZE_ENC - 1]),
      .i1_s2_itag(rv0_instr_i1_s2_itag[2:`ITAG_SIZE_ENC - 1]),
      .i1_s3_itag(rv0_instr_i1_s3_itag[2:`ITAG_SIZE_ENC - 1]),
      .i0_s1_itag_v(rv0_instr_i0_s1_dep_hit_v),
      .i0_s2_itag_v(rv0_instr_i0_s2_dep_hit_v),
      .i0_s3_itag_v(rv0_instr_i0_s3_dep_hit_v),
      .i1_s1_itag_v(rv0_instr_i1_s1_dep_hit_v),
      .i1_s2_itag_v(rv0_instr_i1_s2_dep_hit_v),
      .i1_s3_itag_v(rv0_instr_i1_s3_dep_hit_v),

      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .chip_b_sl_sg_0_t(sg_0),
      .chip_b_sl_2_thold_0_b(func_sl_thold_0_b),
      .force_t(force_t),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scan_in(siv[scorecard_offset]),
      .scan_out(sov[scorecard_offset])
   );

   assign rv0_instr_i0_s1_dep_hit = rv0_instr_i0_s1_dep_hit_v & (rv0_instr_i0_s1_v & ~rv0_instr_i0_s1_itag[1]);
   assign rv0_instr_i0_s2_dep_hit = rv0_instr_i0_s2_dep_hit_v & (rv0_instr_i0_s2_v & ~rv0_instr_i0_s2_itag[1]);
   assign rv0_instr_i0_s3_dep_hit = rv0_instr_i0_s3_dep_hit_v & (rv0_instr_i0_s3_v & ~rv0_instr_i0_s3_itag[1]);

   assign rv0_instr_i1_s1_dep_hit = rv0_instr_i1_s1_dep_hit_v & (rv0_instr_i1_s1_v & ~rv0_instr_i1_s1_itag[1]);
   assign rv0_instr_i1_s2_dep_hit = rv0_instr_i1_s2_dep_hit_v & (rv0_instr_i1_s2_v & ~rv0_instr_i1_s2_itag[1]);
   assign rv0_instr_i1_s3_dep_hit = rv0_instr_i1_s3_dep_hit_v & (rv0_instr_i1_s3_v & ~rv0_instr_i1_s3_itag[1]);

   //------------------------------------------------------------------------------------------------------------
   // Misc
   //------------------------------------------------------------------------------------------------------------
   assign tiup = 1'b1;

   //------------------------------------------------------------------------------------------------------------
   // Release/Abort Busses
   //------------------------------------------------------------------------------------------------------------
   assign xx_rv_itag_v_d[0] = fx0_rv_itag_vld & ~(iu_xx_zap);
   assign xx_rv_itag_v_d[1] = fx1_rv_itag_vld & ~(iu_xx_zap);
   assign xx_rv_itag_v_d[2] = lq_rv_itag0_vld & ~(iu_xx_zap);
   assign xx_rv_itag_v_d[3] = lq_rv_itag1_vld & ~(iu_xx_zap);
   assign xx_rv_itag_v_d[4] = lq_rv_itag2_vld & ~(iu_xx_zap);
   assign xx_rv_itag_v_d[5] = axu0_rv_itag_vld & ~(iu_xx_zap);
   assign xx_rv_itag_v_d[6] = axu1_rv_itag_vld & ~(iu_xx_zap);

   assign xx_rv_itag_ary0_d = fx0_rv_itag[2:`ITAG_SIZE_ENC - 1];
   assign xx_rv_itag_ary1_d = fx1_rv_itag[2:`ITAG_SIZE_ENC - 1];
   assign xx_rv_itag_ary2_d = lq_rv_itag0[2:`ITAG_SIZE_ENC - 1];
   assign xx_rv_itag_ary3_d = lq_rv_itag1[2:`ITAG_SIZE_ENC - 1];
   assign xx_rv_itag_ary4_d = lq_rv_itag2[2:`ITAG_SIZE_ENC - 1];
   assign xx_rv_itag_ary5_d = axu0_rv_itag[2:`ITAG_SIZE_ENC - 1];
   assign xx_rv_itag_ary6_d = axu1_rv_itag[2:`ITAG_SIZE_ENC - 1];

   assign xx_rv_itag_abort_d[0] = fx0_rv_itag_abort;
   assign xx_rv_itag_abort_d[1] = fx1_rv_itag_abort;
   assign xx_rv_itag_abort_d[2] = lq_rv_itag0_abort;
   assign xx_rv_itag_abort_d[3] = lq_rv_itag1_abort;
   assign xx_rv_itag_abort_d[4] = 1'b0;
   assign xx_rv_itag_abort_d[5] = axu0_rv_itag_abort;
   assign xx_rv_itag_abort_d[6] = axu1_rv_itag_abort;



   //------------------------------------------------------------------------------------------------------------
   // Latches
   //------------------------------------------------------------------------------------------------------------


   tri_rlmreg_p #(.WIDTH(7), .INIT(0) ) xx_rv_itag_v_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[xx_rv_itag_v_offset:xx_rv_itag_v_offset + 7 - 1]),
      .scout(sov[xx_rv_itag_v_offset:xx_rv_itag_v_offset + 7 - 1]),
      .din(xx_rv_itag_v_d),
      .dout(xx_rv_itag_v_q)
   );
   tri_rlmreg_p #(.WIDTH(7), .INIT(0) ) xx_rv_itag_abort_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[xx_rv_itag_abort_offset:xx_rv_itag_abort_offset + 7 - 1]),
      .scout(sov[xx_rv_itag_abort_offset:xx_rv_itag_abort_offset + 7 - 1]),
      .din(xx_rv_itag_abort_d),
      .dout(xx_rv_itag_abort_q)
   );

            tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC-2), .INIT(0)) xx_rv_itag_ary0_q_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(tiup),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin( siv[xx_rv_itag_ary0_offset :xx_rv_itag_ary0_offset + `ITAG_SIZE_ENC-2  - 1]),
               .scout(sov[xx_rv_itag_ary0_offset :xx_rv_itag_ary0_offset + `ITAG_SIZE_ENC-2  - 1]),
               .din(xx_rv_itag_ary0_d),
               .dout(xx_rv_itag_ary0_q)
            );
            tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC-2), .INIT(0)) xx_rv_itag_ary1_q_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(tiup),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin( siv[xx_rv_itag_ary1_offset :xx_rv_itag_ary1_offset + `ITAG_SIZE_ENC-2  - 1]),
               .scout(sov[xx_rv_itag_ary1_offset :xx_rv_itag_ary1_offset + `ITAG_SIZE_ENC-2  - 1]),
               .din(xx_rv_itag_ary1_d),
               .dout(xx_rv_itag_ary1_q)
            );
            tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC-2), .INIT(0)) xx_rv_itag_ary2_q_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(tiup),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin( siv[xx_rv_itag_ary2_offset :xx_rv_itag_ary2_offset + `ITAG_SIZE_ENC-2  - 1]),
               .scout(sov[xx_rv_itag_ary2_offset :xx_rv_itag_ary2_offset + `ITAG_SIZE_ENC-2  - 1]),
               .din(xx_rv_itag_ary2_d),
               .dout(xx_rv_itag_ary2_q)
            );
            tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC-2), .INIT(0)) xx_rv_itag_ary3_q_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(tiup),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin( siv[xx_rv_itag_ary3_offset :xx_rv_itag_ary3_offset + `ITAG_SIZE_ENC-2  - 1]),
               .scout(sov[xx_rv_itag_ary3_offset :xx_rv_itag_ary3_offset + `ITAG_SIZE_ENC-2  - 1]),
               .din(xx_rv_itag_ary3_d),
               .dout(xx_rv_itag_ary3_q)
            );
            tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC-2), .INIT(0)) xx_rv_itag_ary4_q_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(tiup),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin( siv[xx_rv_itag_ary4_offset :xx_rv_itag_ary4_offset + `ITAG_SIZE_ENC-2  - 1]),
               .scout(sov[xx_rv_itag_ary4_offset :xx_rv_itag_ary4_offset + `ITAG_SIZE_ENC-2  - 1]),
               .din(xx_rv_itag_ary4_d),
               .dout(xx_rv_itag_ary4_q)
            );
            tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC-2), .INIT(0)) xx_rv_itag_ary5_q_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(tiup),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin( siv[xx_rv_itag_ary5_offset :xx_rv_itag_ary5_offset + `ITAG_SIZE_ENC-2  - 1]),
               .scout(sov[xx_rv_itag_ary5_offset :xx_rv_itag_ary5_offset + `ITAG_SIZE_ENC-2  - 1]),
               .din(xx_rv_itag_ary5_d),
               .dout(xx_rv_itag_ary5_q)
            );
            tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC-2), .INIT(0)) xx_rv_itag_ary6_q_reg(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(tiup),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(force_t),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .d_mode(d_mode),
               .scin( siv[xx_rv_itag_ary6_offset :xx_rv_itag_ary6_offset + `ITAG_SIZE_ENC-2  - 1]),
               .scout(sov[xx_rv_itag_ary6_offset :xx_rv_itag_ary6_offset + `ITAG_SIZE_ENC-2  - 1]),
               .din(xx_rv_itag_ary6_d),
               .dout(xx_rv_itag_ary6_q)
            );



      //---------------------------------------------------------------------
      // Scan
      //---------------------------------------------------------------------
      assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
      assign scan_out = sov[0];

      //-----------------------------------------------
      // pervasive
      //-----------------------------------------------


      tri_plat #(.WIDTH(2)) perv_1to0_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(ccflush_dc),
         .din({func_sl_thold_1,sg_1}),
         .q({func_sl_thold_0,sg_0})
      );


      tri_lcbor perv_lcbor(
         .clkoff_b(clkoff_b),
         .thold(func_sl_thold_0),
         .sg(sg_0),
         .act_dis(act_dis),
         .force_t(force_t),
         .thold_b(func_sl_thold_0_b)
      );

      //-----------------------------------------------
      // unused signals
      //-----------------------------------------------
   assign unused =  rv0_instr_i0_s1_itag[0] | rv0_instr_i0_s2_itag[0] | rv0_instr_i0_s3_itag[0] |
		    rv0_instr_i1_s1_itag[0] | rv0_instr_i1_s2_itag[0] | rv0_instr_i1_s3_itag[0] |
		    |rv0_instr_i0_itag[0:1] | |rv0_instr_i1_itag[0:1] |
		    |fx0_rv_itag[0:1] | |fx1_rv_itag[0:1] | |lq_rv_itag0[0:1] | |lq_rv_itag1[0:1] | |lq_rv_itag2[0:1] | |axu0_rv_itag[0:1] | |axu1_rv_itag[0:1] ;



endmodule
