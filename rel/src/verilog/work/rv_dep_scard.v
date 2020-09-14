// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.


`timescale 1 ns / 1 ns

module rv_dep_scard(
   iu_xx_zap,
   rv0_sc_act,
   ta_v,
   ta_itag,
   tb_v,
   tb_itag,
   xx_rv_itag_v,
   xx_rv_itag_abort,
   xx_rv_itag_ary0,
   xx_rv_itag_ary1,
   xx_rv_itag_ary2,
   xx_rv_itag_ary3,
   xx_rv_itag_ary4,
   xx_rv_itag_ary5,
   xx_rv_itag_ary6,
   i0_s1_itag,
   i0_s1_itag_v,
   i0_s2_itag,
   i0_s2_itag_v,
   i0_s3_itag,
   i0_s3_itag_v,
   i1_s1_itag,
   i1_s1_itag_v,
   i1_s2_itag,
   i1_s2_itag_v,
   i1_s3_itag,
   i1_s3_itag_v,
   vdd,
   gnd,
   nclk,
   chip_b_sl_sg_0_t,
   chip_b_sl_2_thold_0_b,
   force_t,
   d_mode,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   scan_in,
   scan_out
);
   

   `include "tri_a2o.vh"

   parameter                     num_entries_g = 32;
   parameter                     itag_width_enc_g = 6;

   
   input                         iu_xx_zap;
   input                         rv0_sc_act;
   
   input 			 ta_v;
   input [0:itag_width_enc_g-1]  ta_itag;
   
   input 			 tb_v;
   input [0:itag_width_enc_g-1]  tb_itag;
   
   input [0:6] 			 xx_rv_itag_v;
   input [0:6] 			 xx_rv_itag_abort;
   input [0:itag_width_enc_g-1]  xx_rv_itag_ary0;
   input [0:itag_width_enc_g-1]  xx_rv_itag_ary1;
   input [0:itag_width_enc_g-1]  xx_rv_itag_ary2;
   input [0:itag_width_enc_g-1]  xx_rv_itag_ary3;
   input [0:itag_width_enc_g-1]  xx_rv_itag_ary4;
   input [0:itag_width_enc_g-1]  xx_rv_itag_ary5;
   input [0:itag_width_enc_g-1]  xx_rv_itag_ary6;
   
   input [0:itag_width_enc_g-1]  i0_s1_itag;
   output                        i0_s1_itag_v;
   
   input [0:itag_width_enc_g-1]  i0_s2_itag;
   output                        i0_s2_itag_v;
   
   input [0:itag_width_enc_g-1]  i0_s3_itag;
   output                        i0_s3_itag_v;
   
   input [0:itag_width_enc_g-1]  i1_s1_itag;
   output                        i1_s1_itag_v;
   
   input [0:itag_width_enc_g-1]  i1_s2_itag;
   output                        i1_s2_itag_v;
   
   input [0:itag_width_enc_g-1]  i1_s3_itag;
   output                        i1_s3_itag_v;
   
   inout                         vdd;
   inout                         gnd;
   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) 
   input [0:`NCLK_WIDTH-1] 	 nclk;
   input                         chip_b_sl_sg_0_t;
   input                         chip_b_sl_2_thold_0_b;
   input                         force_t;
   input                         d_mode;
   input                         delay_lclkr;
   input                         mpw1_b;
   input                         mpw2_b;
   input                         scan_in;
   output                        scan_out;

   
   
   wire [0:num_entries_g-1]      i0_s1_itag_v_gated;
   wire [0:num_entries_g-1]      i0_s2_itag_v_gated;
   wire [0:num_entries_g-1]      i0_s3_itag_v_gated;
   wire [0:num_entries_g-1]      i1_s1_itag_v_gated;
   wire [0:num_entries_g-1]      i1_s2_itag_v_gated;
   wire [0:num_entries_g-1]      i1_s3_itag_v_gated;
   
   wire [0:num_entries_g-1] 	 scorecard_d;
   wire [0:num_entries_g-1] 	 scorecard_q;
   
   wire [0:num_entries_g-1]      score_ta_match;
   wire [0:num_entries_g-1]      score_tb_match;
   wire [0:num_entries_g-1]      itag_ary0_match;
   wire [0:num_entries_g-1]      itag_ary1_match;
   wire [0:num_entries_g-1]      itag_ary2_match;
   wire [0:num_entries_g-1]      itag_ary3_match;
   wire [0:num_entries_g-1]      itag_ary4_match;
   wire [0:num_entries_g-1]      itag_ary5_match;
   wire [0:num_entries_g-1]      itag_ary6_match;
   wire [0:num_entries_g-1]      score_set;
   wire [0:num_entries_g-1]      score_reset;
   
   
   `define                       scorecard_offset 0
   
   `define                       scan_right  `scorecard_offset + num_entries_g
   wire [0:`scan_right-1]         siv;
   wire [0:`scan_right-1]         sov;
   
   
   
   generate
      begin : xhdl1
         genvar                        i;
         for (i = 0; i <= num_entries_g - 1; i = i + 1)
           begin : g0
	      wire [0:itag_width_enc_g-1] id = i;
              assign score_ta_match[i] = (ta_v & (id == ta_itag));
              assign score_tb_match[i] = (tb_v & (id == tb_itag));
	      
              assign itag_ary0_match[i] = (id == xx_rv_itag_ary0);
              assign itag_ary1_match[i] = (id == xx_rv_itag_ary1);
              assign itag_ary2_match[i] = (id == xx_rv_itag_ary2);
              assign itag_ary3_match[i] = (id == xx_rv_itag_ary3);
              assign itag_ary4_match[i] = (id == xx_rv_itag_ary4);
              assign itag_ary5_match[i] = (id == xx_rv_itag_ary5);
              assign itag_ary6_match[i] = (id == xx_rv_itag_ary6);

              assign score_reset[i] = (xx_rv_itag_v[0] & ~xx_rv_itag_abort[0] & itag_ary0_match[i]) |
				    (xx_rv_itag_v[1] & ~xx_rv_itag_abort[1] & itag_ary1_match[i]) |
				    (xx_rv_itag_v[2] & ~xx_rv_itag_abort[2] & itag_ary2_match[i]) |
				    (xx_rv_itag_v[3] & ~xx_rv_itag_abort[3] & itag_ary3_match[i]) |
				    (xx_rv_itag_v[4] & ~xx_rv_itag_abort[4] & itag_ary4_match[i]) |
				    (xx_rv_itag_v[5] & ~xx_rv_itag_abort[5] & itag_ary5_match[i]) |
				    (xx_rv_itag_v[6] & ~xx_rv_itag_abort[6] & itag_ary6_match[i]) ;
              assign score_set[i] = (xx_rv_itag_v[0] & xx_rv_itag_abort[0] & itag_ary0_match[i]) |
				      (xx_rv_itag_v[1] & xx_rv_itag_abort[1] & itag_ary1_match[i]) |
				      (xx_rv_itag_v[2] & xx_rv_itag_abort[2] & itag_ary2_match[i]) |
				      (xx_rv_itag_v[3] & xx_rv_itag_abort[3] & itag_ary3_match[i]) |
				      (xx_rv_itag_v[4] & xx_rv_itag_abort[4] & itag_ary4_match[i]) |
				      (xx_rv_itag_v[5] & xx_rv_itag_abort[5] & itag_ary5_match[i]) |
				      (xx_rv_itag_v[6] & xx_rv_itag_abort[6] & itag_ary6_match[i]) ;
	      

              assign scorecard_d[i] = (score_ta_match[i] | score_tb_match[i] | score_set[i] | scorecard_q[i]) & (~score_reset[i]) & (~iu_xx_zap);
           end
      end
   endgenerate
      
   
   generate
      begin : xhdl2
         genvar                        i;
         for (i = 0; i <= num_entries_g - 1; i = i + 1)
           begin : g1
	      wire [0:itag_width_enc_g-1] id = i;
              assign i0_s1_itag_v_gated[i] = (scorecard_q[i]) & (i0_s1_itag == id);
              assign i0_s2_itag_v_gated[i] = (scorecard_q[i]) & (i0_s2_itag == id);
              assign i0_s3_itag_v_gated[i] = (scorecard_q[i]) & (i0_s3_itag == id);
              assign i1_s1_itag_v_gated[i] = (scorecard_q[i]) & (i1_s1_itag == id);
              assign i1_s2_itag_v_gated[i] = (scorecard_q[i]) & (i1_s2_itag == id);
              assign i1_s3_itag_v_gated[i] = (scorecard_q[i]) & (i1_s3_itag == id);
           end
      end
   endgenerate
   assign i0_s1_itag_v = |(i0_s1_itag_v_gated);
   assign i0_s2_itag_v = |(i0_s2_itag_v_gated);
   assign i0_s3_itag_v = |(i0_s3_itag_v_gated);
   assign i1_s1_itag_v = |(i1_s1_itag_v_gated);
   assign i1_s2_itag_v = |(i1_s2_itag_v_gated);
   assign i1_s3_itag_v = |(i1_s3_itag_v_gated);
         
         
                  
                  tri_rlmreg_p #(.WIDTH(num_entries_g), .INIT(0) ) scorecard_reg(
                     .vd(vdd),
                     .gd(gnd),
                     .nclk(nclk),
                     .act(rv0_sc_act),
                     .thold_b(chip_b_sl_2_thold_0_b),
                     .sg(chip_b_sl_sg_0_t),
                     .force_t(force_t),
                     .delay_lclkr(delay_lclkr),
                     .mpw1_b(mpw1_b),
                     .mpw2_b(mpw2_b),
                     .d_mode(d_mode),
                     .scin(siv[`scorecard_offset :`scorecard_offset + num_entries_g - 1]),
                     .scout(sov[`scorecard_offset :`scorecard_offset + num_entries_g - 1]),
                     .din(scorecard_d),
                     .dout(scorecard_q)
                  );
            
            assign siv[0:`scan_right-1] = {sov[1:`scan_right-1], scan_in};
            assign scan_out = sov[0];
            
endmodule

