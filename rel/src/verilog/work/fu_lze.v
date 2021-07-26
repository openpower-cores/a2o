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

   `include "tri_a2o.vh"


module fu_lze(
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
   f_lze_si,
   f_lze_so,
   ex2_act_b,
   f_eie_ex3_lzo_expo,
   f_eie_ex3_b_expo,
   f_eie_ex3_use_bexp,
   f_pic_ex3_lzo_dis_prod,
   f_pic_ex3_sp_lzo,
   f_pic_ex3_est_recip,
   f_pic_ex3_est_rsqrt,
   f_fmt_ex3_pass_msb_dp,
   f_pic_ex3_frsp_ue1,
   f_alg_ex3_byp_nonflip,
   f_pic_ex3_b_valid,
   f_alg_ex3_sel_byp,
   f_pic_ex3_to_integer,
   f_pic_ex3_prenorm,
   f_lze_ex3_lzo_din,
   f_lze_ex4_sh_rgt_amt,
   f_lze_ex4_sh_rgt_en
);
   inout          vdd;
   inout          gnd;
   input          clkoff_b;		// tiup
   input          act_dis;		// ??tidn??
   input          flush;		// ??tidn??
   input [2:3]    delay_lclkr;		// tidn,
   input [2:3]    mpw1_b;		// tidn,
   input [0:0]    mpw2_b;		// tidn,
   input          sg_1;
   input          thold_1;
   input          fpu_enable;		//dc_act
   input  [0:`NCLK_WIDTH-1]         nclk;

   input          f_lze_si;		//perv
   output         f_lze_so;		//perv
   input          ex2_act_b;		//act

   input [1:13]   f_eie_ex3_lzo_expo;
   input [1:13]   f_eie_ex3_b_expo;
   input          f_eie_ex3_use_bexp;
   input          f_pic_ex3_lzo_dis_prod;
   input          f_pic_ex3_sp_lzo;
   input          f_pic_ex3_est_recip;
   input          f_pic_ex3_est_rsqrt;
   input          f_fmt_ex3_pass_msb_dp;
   input          f_pic_ex3_frsp_ue1;
   input          f_alg_ex3_byp_nonflip;
   input          f_pic_ex3_b_valid;
   input          f_alg_ex3_sel_byp;
   input          f_pic_ex3_to_integer;
   input          f_pic_ex3_prenorm;
   output [0:162] f_lze_ex3_lzo_din;
   output [0:7]   f_lze_ex4_sh_rgt_amt;
   output         f_lze_ex4_sh_rgt_en;

   // ENTITY


   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;

   wire           thold_0_b;
   wire           thold_0;
   wire           force_t;
   wire           sg_0;
   wire           ex2_act;
   wire           ex3_act;
   (* analysis_not_referenced="TRUE" *) // spare_unused
   wire [0:3]     spare_unused;
   wire           ex3_dp_001_by;
   wire           ex3_sp_001_by;
   wire           ex3_addr_dp_by;
   wire           ex3_addr_sp_by;
   wire           ex3_en_addr_dp_by;
   wire           ex3_en_addr_sp_by;
   wire           ex3_lzo_en;
   wire           ex3_lzo_en_rapsp;
   wire           ex3_lzo_en_by;
   wire           ex3_expo_neg_dp_by;
   wire           ex3_expo_neg_sp_by;
   wire           ex3_expo_6_adj_by;
   wire           ex3_addr_dp;
   wire           ex3_addr_sp;
   wire           ex3_addr_sp_rap;
   wire           ex3_en_addr_dp;
   wire           ex3_en_addr_sp;
   wire           ex3_en_addr_sp_rap;
   wire           ex3_lzo_cont;
   wire           ex3_lzo_cont_dp;
   wire           ex3_lzo_cont_sp;
   wire           ex3_expo_neg_dp;
   wire           ex3_expo_neg_sp;
   wire           ex3_expo_6_adj;
   wire           ex3_ins_est;
   wire           ex3_sh_rgt_en_by;
   wire           ex3_sh_rgt_en_p;
   wire           ex3_sh_rgt_en;
   wire           ex3_lzo_forbyp_0;
   wire           ex3_lzo_nonbyp_0;
   wire           ex4_sh_rgt_en;
   wire [1:13]    ex3_expo_by;
   wire [0:0]     ex3_lzo_dcd_hi_by;
   wire [0:0]     ex3_lzo_dcd_lo_by;
   wire [1:13]    ex3_expo;
   wire [0:10]    ex3_lzo_dcd_hi;
   wire [0:15]    ex3_lzo_dcd_lo;
   wire [8:13]    ex3_expo_p_sim_p;
   wire [9:13]    ex3_expo_p_sim_g;
   wire [8:13]    ex3_expo_p_sim;
   wire [8:13]    ex3_expo_sim_p;
   wire [9:13]    ex3_expo_sim_g;
   wire [8:13]    ex3_expo_sim;
   wire [0:7]     ex3_sh_rgt_amt;
   wire [0:8]     ex4_shr_so;
   wire [0:8]     ex4_shr_si;
   wire [0:4]     act_so;
   wire [0:4]     act_si;
   wire [0:7]     ex4_sh_rgt_amt;
   wire           ex3_lzo_dcd_0;
   wire [0:162]   ex3_lzo_dcd_b;
   (* analysis_not_referenced="TRUE" *) // unused
   wire           unused;
   wire           f_alg_ex3_sel_byp_b;
   wire           ex3_lzo_nonbyp_0_b;
   wire           ex3_lzo_forbyp_0_b;
   //-=###############################################################
   //-= map block attributes
   //-=###############################################################

   assign unused = ex3_lzo_dcd_b[0];

   //-=###############################################################
   //-= pervasive
   //-=###############################################################


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

   //-=###############################################################
   //-= act
   //-=###############################################################

   assign ex2_act = (~ex2_act_b);


   tri_rlmreg_p #(.WIDTH(5), .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),		// tidn,
      .mpw1_b(mpw1_b[2]),		// tidn,
      .mpw2_b(mpw2_b[0]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(fpu_enable),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(act_so),
      .scin(act_si),
      //-----------------
      .din({ spare_unused[0],
             spare_unused[1],
             ex2_act,
             spare_unused[2],
             spare_unused[3]}),
      //-----------------
      .dout({ spare_unused[0],
              spare_unused[1],
              ex3_act,
              spare_unused[2],
              spare_unused[3]})
   );

   //-=###############################################################
   //-= ex3 logic
   //-=###############################################################

   assign ex3_dp_001_by = (~ex3_expo_by[1]) & (~ex3_expo_by[2]) & (~ex3_expo_by[3]) & (~ex3_expo_by[4]) & (~ex3_expo_by[5]) & (~ex3_expo_by[6]) & (~ex3_expo_by[7]) & (~ex3_expo_by[8]) & (~ex3_expo_by[9]) & (~ex3_expo_by[10]) & (~ex3_expo_by[11]) & (~ex3_expo_by[12]) & ex3_expo_by[13];		//x001

   assign ex3_sp_001_by = (~ex3_expo_by[1]) & (~ex3_expo_by[2]) & (~ex3_expo_by[3]) & ex3_expo_by[4] & ex3_expo_by[5] & ex3_expo_by[6] & (~ex3_expo_by[7]) & (~ex3_expo_by[8]) & (~ex3_expo_by[9]) & (~ex3_expo_by[10]) & (~ex3_expo_by[11]) & (~ex3_expo_by[12]) & ex3_expo_by[13];		//x381

   //----------------------------------------------------------------
   // lzo dcd when B = denorm.
   // sp denorm in dp_format may need to denormalize.
   // sp is bypassed at [26] so there is room to do this on the left
   //----------------------------------------------------------------
   // if B is normalized when bypassed, then no need for denorm because it will not shift left ?
   // for EffSub, b MSB can move right 1 position ... only if BFrac = 0000111111,can't if bypass norm
   // If B==0 then should NOT bypass ... except for Move instructions.

   assign ex3_expo_by[1:13] = f_eie_ex3_b_expo[1:13];

   //=#------------------------------------------------
   //=#-- LZO Decode
   //=#------------------------------------------------
   // the product exponent points at [0] in the dataflow.
   // the lzo puts a marker (false edge) at the point where shifting must stop
   // so the lza will not create a denormal exponent. (001/897) dp/sp.
   // if p_expo==1 then maker @ 0
   // if p_expo==2 then maker @ 1
   // if p_expo==3 then maker @ 2
   //
   // false edges are also used to control shifting for to-integer, aligner-bypass

   assign ex3_addr_dp_by = (~ex3_expo_by[1]) & (~ex3_expo_by[2]) & (~ex3_expo_by[3]) & (~ex3_expo_by[4]) & (~ex3_expo_by[5]);		// x001 (1) in bits above decode 256

   assign ex3_addr_sp_by = (~ex3_expo_by[1]) & (~ex3_expo_by[2]) & (~ex3_expo_by[3]) & ex3_expo_by[4] & ex3_expo_by[5];		// x381 (897) in bits above decode 256

   assign ex3_en_addr_dp_by = ex3_addr_dp_by & ex3_lzo_cont_dp;
   assign ex3_en_addr_sp_by = ex3_addr_sp_by & ex3_lzo_cont_sp;

   // want to avoid shift right for sp op with shOv of sp_den in dp format
   // sp is bypassed 26 positions to the left , mark with LZO to create the denorm.

   assign ex3_lzo_en_by = (ex3_en_addr_dp_by | ex3_en_addr_sp_by) & ex3_lzo_cont;

   //decode 0
   assign ex3_expo_neg_dp_by = (ex3_lzo_en_by & ex3_lzo_dcd_hi_by[0] & ex3_lzo_dcd_lo_by[0]) | (ex3_expo_by[1]);		//negative exponent

   // dp denorm starts at 0, but sp denorm starts at 896 (x380)
   // sp addr 0_0011_xxxx_xxxx covers 0768-1023 <and with decode bits>
   //         0_000x_xxxx_xxxx covers 0000,0001
   //         0_00x0_xxxx_xxxx covers 0000,0010

   assign ex3_expo_neg_sp_by = (ex3_expo_by[1]) | ((~ex3_expo_by[2]) & (~ex3_expo_by[3]) & (~ex3_expo_by[4])) | ((~ex3_expo_by[2]) & (~ex3_expo_by[3]) & (~ex3_expo_by[5])) | ((~ex3_expo_by[2]) & (~ex3_expo_by[3]) & (~ex3_expo_by[6])) | ((~ex3_expo_by[2]) & (~ex3_expo_by[3]) & ex3_expo_by[4] & ex3_expo_by[5] & ex3_expo_by[6] & (~(ex3_expo_by[7] | ex3_expo_by[8] | ex3_expo_by[9] | ex3_expo_by[10] | ex3_expo_by[11] | ex3_expo_by[12] | ex3_expo_by[13])));		// negative

   assign ex3_expo_6_adj_by = ((~ex3_expo_by[6]) & f_pic_ex3_sp_lzo) | (ex3_expo_by[6] & (~f_pic_ex3_sp_lzo));

   assign ex3_lzo_dcd_0 = ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[1];

   assign ex3_lzo_dcd_hi_by[0] = (~ex3_expo_6_adj_by) & (~ex3_expo_by[7]) & (~ex3_expo_by[8]) & (~ex3_expo_by[9]) & ex3_lzo_en_by;

   assign ex3_lzo_dcd_lo_by[0] = (~ex3_expo_by[10]) & (~ex3_expo_by[11]) & (~ex3_expo_by[12]) & (~ex3_expo_by[13]);

   //=#------------------------------------------------
   //=#-- LZO Decode
   //=#------------------------------------------------
   // the product exponent points at [0] in the dataflow.
   // the lzo puts a marker (false edge) at the point where shifting must stop
   // so the lza will not create a denormal exponent. (001/897) dp/sp.
   // if p_expo==1 then maker @ 0
   // if p_expo==2 then maker @ 1
   // if p_expo==3 then maker @ 2
   //
   // false edges are also used to control shifting for to-integer, aligner-bypass

   assign ex3_expo[1:13] = f_eie_ex3_lzo_expo[1:13];
   assign ex3_addr_dp = (~ex3_expo[1]) & (~ex3_expo[2]) & (~ex3_expo[3]) & (~ex3_expo[4]) & (~ex3_expo[5]);		// x001 (1) in bits above decode 256

   assign ex3_addr_sp = (~ex3_expo[1]) & (~ex3_expo[2]) & (~ex3_expo[3]) & ex3_expo[4] & ex3_expo[5];		// x381 (897) in bits above decode 256

   assign ex3_addr_sp_rap = (~ex3_expo[1]) & (~ex3_expo[2]) & ex3_expo[3] & (~ex3_expo[4]) & (~ex3_expo[5]);		// x381 (897) in bits above decode 256

   assign ex3_en_addr_dp = ex3_addr_dp & ex3_lzo_cont_dp;
   assign ex3_en_addr_sp = ex3_addr_sp & ex3_lzo_cont_sp;
   assign ex3_en_addr_sp_rap = ex3_addr_sp_rap & ex3_lzo_cont_sp;

   assign ex3_lzo_cont = (~f_pic_ex3_lzo_dis_prod);
   assign ex3_lzo_cont_dp = (~f_pic_ex3_lzo_dis_prod) & (~f_pic_ex3_sp_lzo);
   assign ex3_lzo_cont_sp = (~f_pic_ex3_lzo_dis_prod) & f_pic_ex3_sp_lzo;

   // want to avoid shift right for sp op with shOv of sp_den in dp format
   // sp is bypassed 26 positions to the left , mark with LZO to create the denorm.

   assign ex3_lzo_en = (ex3_en_addr_dp | ex3_en_addr_sp) & ex3_lzo_cont;
   assign ex3_lzo_en_rapsp = (ex3_en_addr_dp | ex3_en_addr_sp_rap) & ex3_lzo_cont;

   //decode 0
   assign ex3_expo_neg_dp = (ex3_lzo_en & ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[0]) | (ex3_expo[1]);		//negative exponent

   // dp denorm starts at 0, but sp denorm starts at 896 (x380)
   // sp addr 0_0011_xxxx_xxxx covers 0768-1023 <and with decode bits>
   //         0_000x_xxxx_xxxx covers 0000,0001
   //         0_00x0_xxxx_xxxx covers 0000,0010

   assign ex3_expo_neg_sp = (ex3_expo[1]) | ((~ex3_expo[2]) & (~ex3_expo[3]) & (~ex3_expo[4])) | ((~ex3_expo[2]) & (~ex3_expo[3]) & (~ex3_expo[5])) | ((~ex3_expo[2]) & (~ex3_expo[3]) & (~ex3_expo[6])) | ((~ex3_expo[2]) & (~ex3_expo[3]) & ex3_expo[4] & ex3_expo[5] & ex3_expo[6] & (~(ex3_expo[7] | ex3_expo[8] | ex3_expo[9] | ex3_expo[10] | ex3_expo[11] | ex3_expo[12] | ex3_expo[13])));		// negative

   assign ex3_expo_6_adj = ((~ex3_expo[6]) & f_pic_ex3_sp_lzo) | (ex3_expo[6] & (~f_pic_ex3_sp_lzo));

   assign ex3_lzo_dcd_hi[0] = (~ex3_expo_6_adj) & (~ex3_expo[7]) & (~ex3_expo[8]) & (~ex3_expo[9]) & ex3_lzo_en;
   assign ex3_lzo_dcd_hi[1] = (~ex3_expo_6_adj) & (~ex3_expo[7]) & (~ex3_expo[8]) & ex3_expo[9] & ex3_lzo_en;
   assign ex3_lzo_dcd_hi[2] = (~ex3_expo_6_adj) & (~ex3_expo[7]) & ex3_expo[8] & (~ex3_expo[9]) & ex3_lzo_en;
   assign ex3_lzo_dcd_hi[3] = (~ex3_expo_6_adj) & (~ex3_expo[7]) & ex3_expo[8] & ex3_expo[9] & ex3_lzo_en;
   assign ex3_lzo_dcd_hi[4] = (~ex3_expo_6_adj) & ex3_expo[7] & (~ex3_expo[8]) & (~ex3_expo[9]) & ex3_lzo_en;
   assign ex3_lzo_dcd_hi[5] = (~ex3_expo_6_adj) & ex3_expo[7] & (~ex3_expo[8]) & ex3_expo[9] & ex3_lzo_en;
   assign ex3_lzo_dcd_hi[6] = (~ex3_expo_6_adj) & ex3_expo[7] & ex3_expo[8] & (~ex3_expo[9]) & ex3_lzo_en;
   assign ex3_lzo_dcd_hi[7] = (~ex3_expo_6_adj) & ex3_expo[7] & ex3_expo[8] & ex3_expo[9] & ex3_lzo_en;
   assign ex3_lzo_dcd_hi[8] = ex3_expo_6_adj & (~ex3_expo[7]) & (~ex3_expo[8]) & (~ex3_expo[9]) & ex3_lzo_en_rapsp;
   assign ex3_lzo_dcd_hi[9] = ex3_expo_6_adj & (~ex3_expo[7]) & (~ex3_expo[8]) & ex3_expo[9] & ex3_lzo_en_rapsp;
   assign ex3_lzo_dcd_hi[10] = ex3_expo_6_adj & (~ex3_expo[7]) & ex3_expo[8] & (~ex3_expo[9]) & ex3_lzo_en_rapsp;

   assign ex3_lzo_dcd_lo[0] = (~ex3_expo[10]) & (~ex3_expo[11]) & (~ex3_expo[12]) & (~ex3_expo[13]);
   assign ex3_lzo_dcd_lo[1] = (~ex3_expo[10]) & (~ex3_expo[11]) & (~ex3_expo[12]) & ex3_expo[13];
   assign ex3_lzo_dcd_lo[2] = (~ex3_expo[10]) & (~ex3_expo[11]) & ex3_expo[12] & (~ex3_expo[13]);
   assign ex3_lzo_dcd_lo[3] = (~ex3_expo[10]) & (~ex3_expo[11]) & ex3_expo[12] & ex3_expo[13];
   assign ex3_lzo_dcd_lo[4] = (~ex3_expo[10]) & ex3_expo[11] & (~ex3_expo[12]) & (~ex3_expo[13]);
   assign ex3_lzo_dcd_lo[5] = (~ex3_expo[10]) & ex3_expo[11] & (~ex3_expo[12]) & ex3_expo[13];
   assign ex3_lzo_dcd_lo[6] = (~ex3_expo[10]) & ex3_expo[11] & ex3_expo[12] & (~ex3_expo[13]);
   assign ex3_lzo_dcd_lo[7] = (~ex3_expo[10]) & ex3_expo[11] & ex3_expo[12] & ex3_expo[13];
   assign ex3_lzo_dcd_lo[8] = ex3_expo[10] & (~ex3_expo[11]) & (~ex3_expo[12]) & (~ex3_expo[13]);
   assign ex3_lzo_dcd_lo[9] = ex3_expo[10] & (~ex3_expo[11]) & (~ex3_expo[12]) & ex3_expo[13];
   assign ex3_lzo_dcd_lo[10] = ex3_expo[10] & (~ex3_expo[11]) & ex3_expo[12] & (~ex3_expo[13]);
   assign ex3_lzo_dcd_lo[11] = ex3_expo[10] & (~ex3_expo[11]) & ex3_expo[12] & ex3_expo[13];
   assign ex3_lzo_dcd_lo[12] = ex3_expo[10] & ex3_expo[11] & (~ex3_expo[12]) & (~ex3_expo[13]);
   assign ex3_lzo_dcd_lo[13] = ex3_expo[10] & ex3_expo[11] & (~ex3_expo[12]) & ex3_expo[13];
   assign ex3_lzo_dcd_lo[14] = ex3_expo[10] & ex3_expo[11] & ex3_expo[12] & (~ex3_expo[13]);
   assign ex3_lzo_dcd_lo[15] = ex3_expo[10] & ex3_expo[11] & ex3_expo[12] & ex3_expo[13];

   assign ex3_lzo_dcd_b[0] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[1]));
   assign ex3_lzo_dcd_b[1] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[2]));
   assign ex3_lzo_dcd_b[2] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[3]));
   assign ex3_lzo_dcd_b[3] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[4]));
   assign ex3_lzo_dcd_b[4] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[5]));
   assign ex3_lzo_dcd_b[5] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[6]));
   assign ex3_lzo_dcd_b[6] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[7]));
   assign ex3_lzo_dcd_b[7] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[8]));
   assign ex3_lzo_dcd_b[8] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[9]));
   assign ex3_lzo_dcd_b[9] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[10]));
   assign ex3_lzo_dcd_b[10] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[11]));
   assign ex3_lzo_dcd_b[11] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[12]));
   assign ex3_lzo_dcd_b[12] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[13]));
   assign ex3_lzo_dcd_b[13] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[14]));
   assign ex3_lzo_dcd_b[14] = (~(ex3_lzo_dcd_hi[0] & ex3_lzo_dcd_lo[15]));

   assign ex3_lzo_dcd_b[15] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[0]));
   assign ex3_lzo_dcd_b[16] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[1]));
   assign ex3_lzo_dcd_b[17] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[2]));
   assign ex3_lzo_dcd_b[18] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[3]));
   assign ex3_lzo_dcd_b[19] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[4]));
   assign ex3_lzo_dcd_b[20] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[5]));
   assign ex3_lzo_dcd_b[21] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[6]));
   assign ex3_lzo_dcd_b[22] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[7]));
   assign ex3_lzo_dcd_b[23] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[8]));
   assign ex3_lzo_dcd_b[24] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[9]));
   assign ex3_lzo_dcd_b[25] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[10]));
   assign ex3_lzo_dcd_b[26] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[11]));
   assign ex3_lzo_dcd_b[27] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[12]));
   assign ex3_lzo_dcd_b[28] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[13]));
   assign ex3_lzo_dcd_b[29] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[14]));
   assign ex3_lzo_dcd_b[30] = (~(ex3_lzo_dcd_hi[1] & ex3_lzo_dcd_lo[15]));

   assign ex3_lzo_dcd_b[31] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[0]));
   assign ex3_lzo_dcd_b[32] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[1]));
   assign ex3_lzo_dcd_b[33] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[2]));
   assign ex3_lzo_dcd_b[34] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[3]));
   assign ex3_lzo_dcd_b[35] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[4]));
   assign ex3_lzo_dcd_b[36] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[5]));
   assign ex3_lzo_dcd_b[37] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[6]));
   assign ex3_lzo_dcd_b[38] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[7]));
   assign ex3_lzo_dcd_b[39] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[8]));
   assign ex3_lzo_dcd_b[40] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[9]));
   assign ex3_lzo_dcd_b[41] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[10]));
   assign ex3_lzo_dcd_b[42] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[11]));
   assign ex3_lzo_dcd_b[43] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[12]));
   assign ex3_lzo_dcd_b[44] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[13]));
   assign ex3_lzo_dcd_b[45] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[14]));
   assign ex3_lzo_dcd_b[46] = (~(ex3_lzo_dcd_hi[2] & ex3_lzo_dcd_lo[15]));

   assign ex3_lzo_dcd_b[47] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[0]));
   assign ex3_lzo_dcd_b[48] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[1]));
   assign ex3_lzo_dcd_b[49] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[2]));
   assign ex3_lzo_dcd_b[50] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[3]));
   assign ex3_lzo_dcd_b[51] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[4]));
   assign ex3_lzo_dcd_b[52] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[5]));
   assign ex3_lzo_dcd_b[53] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[6]));
   assign ex3_lzo_dcd_b[54] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[7]));
   assign ex3_lzo_dcd_b[55] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[8]));
   assign ex3_lzo_dcd_b[56] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[9]));
   assign ex3_lzo_dcd_b[57] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[10]));
   assign ex3_lzo_dcd_b[58] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[11]));
   assign ex3_lzo_dcd_b[59] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[12]));
   assign ex3_lzo_dcd_b[60] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[13]));
   assign ex3_lzo_dcd_b[61] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[14]));
   assign ex3_lzo_dcd_b[62] = (~(ex3_lzo_dcd_hi[3] & ex3_lzo_dcd_lo[15]));

   assign ex3_lzo_dcd_b[63] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[0]));
   assign ex3_lzo_dcd_b[64] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[1]));
   assign ex3_lzo_dcd_b[65] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[2]));
   assign ex3_lzo_dcd_b[66] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[3]));
   assign ex3_lzo_dcd_b[67] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[4]));
   assign ex3_lzo_dcd_b[68] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[5]));
   assign ex3_lzo_dcd_b[69] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[6]));
   assign ex3_lzo_dcd_b[70] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[7]));
   assign ex3_lzo_dcd_b[71] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[8]));
   assign ex3_lzo_dcd_b[72] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[9]));
   assign ex3_lzo_dcd_b[73] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[10]));
   assign ex3_lzo_dcd_b[74] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[11]));
   assign ex3_lzo_dcd_b[75] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[12]));
   assign ex3_lzo_dcd_b[76] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[13]));
   assign ex3_lzo_dcd_b[77] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[14]));
   assign ex3_lzo_dcd_b[78] = (~(ex3_lzo_dcd_hi[4] & ex3_lzo_dcd_lo[15]));

   assign ex3_lzo_dcd_b[79] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[0]));
   assign ex3_lzo_dcd_b[80] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[1]));
   assign ex3_lzo_dcd_b[81] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[2]));
   assign ex3_lzo_dcd_b[82] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[3]));
   assign ex3_lzo_dcd_b[83] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[4]));
   assign ex3_lzo_dcd_b[84] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[5]));
   assign ex3_lzo_dcd_b[85] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[6]));
   assign ex3_lzo_dcd_b[86] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[7]));
   assign ex3_lzo_dcd_b[87] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[8]));
   assign ex3_lzo_dcd_b[88] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[9]));
   assign ex3_lzo_dcd_b[89] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[10]));
   assign ex3_lzo_dcd_b[90] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[11]));
   assign ex3_lzo_dcd_b[91] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[12]));
   assign ex3_lzo_dcd_b[92] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[13]));
   assign ex3_lzo_dcd_b[93] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[14]));
   assign ex3_lzo_dcd_b[94] = (~(ex3_lzo_dcd_hi[5] & ex3_lzo_dcd_lo[15]));

   assign ex3_lzo_dcd_b[95] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[0]));
   assign ex3_lzo_dcd_b[96] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[1]));
   assign ex3_lzo_dcd_b[97] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[2]));
   assign ex3_lzo_dcd_b[98] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[3]));
   assign ex3_lzo_dcd_b[99] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[4]));
   assign ex3_lzo_dcd_b[100] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[5]));
   assign ex3_lzo_dcd_b[101] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[6]));
   assign ex3_lzo_dcd_b[102] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[7]));
   assign ex3_lzo_dcd_b[103] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[8]));
   assign ex3_lzo_dcd_b[104] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[9]));
   assign ex3_lzo_dcd_b[105] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[10]));
   assign ex3_lzo_dcd_b[106] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[11]));
   assign ex3_lzo_dcd_b[107] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[12]));
   assign ex3_lzo_dcd_b[108] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[13]));
   assign ex3_lzo_dcd_b[109] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[14]));
   assign ex3_lzo_dcd_b[110] = (~(ex3_lzo_dcd_hi[6] & ex3_lzo_dcd_lo[15]));

   assign ex3_lzo_dcd_b[111] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[0]));
   assign ex3_lzo_dcd_b[112] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[1]));
   assign ex3_lzo_dcd_b[113] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[2]));
   assign ex3_lzo_dcd_b[114] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[3]));
   assign ex3_lzo_dcd_b[115] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[4]));
   assign ex3_lzo_dcd_b[116] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[5]));
   assign ex3_lzo_dcd_b[117] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[6]));
   assign ex3_lzo_dcd_b[118] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[7]));
   assign ex3_lzo_dcd_b[119] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[8]));
   assign ex3_lzo_dcd_b[120] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[9]));
   assign ex3_lzo_dcd_b[121] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[10]));
   assign ex3_lzo_dcd_b[122] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[11]));
   assign ex3_lzo_dcd_b[123] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[12]));
   assign ex3_lzo_dcd_b[124] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[13]));
   assign ex3_lzo_dcd_b[125] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[14]));
   assign ex3_lzo_dcd_b[126] = (~(ex3_lzo_dcd_hi[7] & ex3_lzo_dcd_lo[15]));

   assign ex3_lzo_dcd_b[127] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[0]));
   assign ex3_lzo_dcd_b[128] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[1]));
   assign ex3_lzo_dcd_b[129] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[2]));
   assign ex3_lzo_dcd_b[130] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[3]));
   assign ex3_lzo_dcd_b[131] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[4]));
   assign ex3_lzo_dcd_b[132] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[5]));
   assign ex3_lzo_dcd_b[133] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[6]));
   assign ex3_lzo_dcd_b[134] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[7]));
   assign ex3_lzo_dcd_b[135] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[8]));
   assign ex3_lzo_dcd_b[136] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[9]));
   assign ex3_lzo_dcd_b[137] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[10]));
   assign ex3_lzo_dcd_b[138] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[11]));
   assign ex3_lzo_dcd_b[139] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[12]));
   assign ex3_lzo_dcd_b[140] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[13]));
   assign ex3_lzo_dcd_b[141] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[14]));
   assign ex3_lzo_dcd_b[142] = (~(ex3_lzo_dcd_hi[8] & ex3_lzo_dcd_lo[15]));

   assign ex3_lzo_dcd_b[143] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[0]));
   assign ex3_lzo_dcd_b[144] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[1]));
   assign ex3_lzo_dcd_b[145] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[2]));
   assign ex3_lzo_dcd_b[146] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[3]));
   assign ex3_lzo_dcd_b[147] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[4]));
   assign ex3_lzo_dcd_b[148] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[5]));
   assign ex3_lzo_dcd_b[149] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[6]));
   assign ex3_lzo_dcd_b[150] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[7]));
   assign ex3_lzo_dcd_b[151] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[8]));
   assign ex3_lzo_dcd_b[152] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[9]));
   assign ex3_lzo_dcd_b[153] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[10]));
   assign ex3_lzo_dcd_b[154] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[11]));
   assign ex3_lzo_dcd_b[155] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[12]));
   assign ex3_lzo_dcd_b[156] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[13]));
   assign ex3_lzo_dcd_b[157] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[14]));
   assign ex3_lzo_dcd_b[158] = (~(ex3_lzo_dcd_hi[9] & ex3_lzo_dcd_lo[15]));

   assign ex3_lzo_dcd_b[159] = (~(ex3_lzo_dcd_hi[10] & ex3_lzo_dcd_lo[0]));
   assign ex3_lzo_dcd_b[160] = (~(ex3_lzo_dcd_hi[10] & ex3_lzo_dcd_lo[1]));
   assign ex3_lzo_dcd_b[161] = (~(ex3_lzo_dcd_hi[10] & ex3_lzo_dcd_lo[2]));
   assign ex3_lzo_dcd_b[162] = (~(ex3_lzo_dcd_hi[10] & ex3_lzo_dcd_lo[3]));

   //-----------------------------------------

   assign f_alg_ex3_sel_byp_b = (~(f_alg_ex3_sel_byp));
   assign ex3_lzo_nonbyp_0_b = (~(ex3_lzo_nonbyp_0));
   assign ex3_lzo_forbyp_0_b = (~(ex3_lzo_forbyp_0));

   assign f_lze_ex3_lzo_din[0] = (~((f_alg_ex3_sel_byp | ex3_lzo_nonbyp_0_b) & (f_alg_ex3_sel_byp_b | ex3_lzo_forbyp_0_b)));		// neg input and/or
   assign f_lze_ex3_lzo_din[1] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[1]));		// neg input and --
   assign f_lze_ex3_lzo_din[2] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[2]));		// neg input and --
   assign f_lze_ex3_lzo_din[3] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[3]));		// neg input and --
   assign f_lze_ex3_lzo_din[4] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[4]));		// neg input and --
   assign f_lze_ex3_lzo_din[5] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[5]));		// neg input and --
   assign f_lze_ex3_lzo_din[6] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[6]));		// neg input and --
   assign f_lze_ex3_lzo_din[7] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[7]));		// neg input and --
   assign f_lze_ex3_lzo_din[8] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[8]));		// neg input and --
   assign f_lze_ex3_lzo_din[9] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[9]));		// neg input and --
   assign f_lze_ex3_lzo_din[10] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[10]));		// neg input and --
   assign f_lze_ex3_lzo_din[11] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[11]));		// neg input and --
   assign f_lze_ex3_lzo_din[12] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[12]));		// neg input and --
   assign f_lze_ex3_lzo_din[13] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[13]));		// neg input and --
   assign f_lze_ex3_lzo_din[14] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[14]));		// neg input and --
   assign f_lze_ex3_lzo_din[15] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[15]));		// neg input and --
   assign f_lze_ex3_lzo_din[16] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[16]));		// neg input and --
   assign f_lze_ex3_lzo_din[17] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[17]));		// neg input and --
   assign f_lze_ex3_lzo_din[18] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[18]));		// neg input and --
   assign f_lze_ex3_lzo_din[19] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[19]));		// neg input and --
   assign f_lze_ex3_lzo_din[20] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[20]));		// neg input and --
   assign f_lze_ex3_lzo_din[21] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[21]));		// neg input and --
   assign f_lze_ex3_lzo_din[22] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[22]));		// neg input and --
   assign f_lze_ex3_lzo_din[23] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[23]));		// neg input and --
   assign f_lze_ex3_lzo_din[24] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[24]));		// neg input and --
   assign f_lze_ex3_lzo_din[25] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[25]));		// neg input and --
   assign f_lze_ex3_lzo_din[26] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[26]));		// neg input and --
   assign f_lze_ex3_lzo_din[27] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[27]));		// neg input and --
   assign f_lze_ex3_lzo_din[28] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[28]));		// neg input and --
   assign f_lze_ex3_lzo_din[29] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[29]));		// neg input and --
   assign f_lze_ex3_lzo_din[30] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[30]));		// neg input and --
   assign f_lze_ex3_lzo_din[31] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[31]));		// neg input and --
   assign f_lze_ex3_lzo_din[32] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[32]));		// neg input and --
   assign f_lze_ex3_lzo_din[33] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[33]));		// neg input and --
   assign f_lze_ex3_lzo_din[34] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[34]));		// neg input and --
   assign f_lze_ex3_lzo_din[35] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[35]));		// neg input and --
   assign f_lze_ex3_lzo_din[36] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[36]));		// neg input and --
   assign f_lze_ex3_lzo_din[37] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[37]));		// neg input and --
   assign f_lze_ex3_lzo_din[38] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[38]));		// neg input and --
   assign f_lze_ex3_lzo_din[39] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[39]));		// neg input and --
   assign f_lze_ex3_lzo_din[40] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[40]));		// neg input and --
   assign f_lze_ex3_lzo_din[41] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[41]));		// neg input and --
   assign f_lze_ex3_lzo_din[42] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[42]));		// neg input and --
   assign f_lze_ex3_lzo_din[43] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[43]));		// neg input and --
   assign f_lze_ex3_lzo_din[44] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[44]));		// neg input and --
   assign f_lze_ex3_lzo_din[45] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[45]));		// neg input and --
   assign f_lze_ex3_lzo_din[46] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[46]));		// neg input and --
   assign f_lze_ex3_lzo_din[47] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[47]));		// neg input and --
   assign f_lze_ex3_lzo_din[48] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[48]));		// neg input and --
   assign f_lze_ex3_lzo_din[49] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[49]));		// neg input and --
   assign f_lze_ex3_lzo_din[50] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[50]));		// neg input and --
   assign f_lze_ex3_lzo_din[51] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[51]));		// neg input and --
   assign f_lze_ex3_lzo_din[52] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[52]));		// neg input and --
   assign f_lze_ex3_lzo_din[53] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[53]));		// neg input and --
   assign f_lze_ex3_lzo_din[54] = (~(f_alg_ex3_sel_byp | ex3_lzo_dcd_b[54]));		// neg input and --
   assign f_lze_ex3_lzo_din[55] = (~ex3_lzo_dcd_b[55]);
   assign f_lze_ex3_lzo_din[56] = (~ex3_lzo_dcd_b[56]);
   assign f_lze_ex3_lzo_din[57] = (~ex3_lzo_dcd_b[57]);
   assign f_lze_ex3_lzo_din[58] = (~ex3_lzo_dcd_b[58]);
   assign f_lze_ex3_lzo_din[59] = (~ex3_lzo_dcd_b[59]);
   assign f_lze_ex3_lzo_din[60] = (~ex3_lzo_dcd_b[60]);
   assign f_lze_ex3_lzo_din[61] = (~ex3_lzo_dcd_b[61]);
   assign f_lze_ex3_lzo_din[62] = (~ex3_lzo_dcd_b[62]);
   assign f_lze_ex3_lzo_din[63] = (~ex3_lzo_dcd_b[63]);
   assign f_lze_ex3_lzo_din[64] = (~ex3_lzo_dcd_b[64]);
   assign f_lze_ex3_lzo_din[65] = (~ex3_lzo_dcd_b[65]);
   assign f_lze_ex3_lzo_din[66] = (~ex3_lzo_dcd_b[66]);
   assign f_lze_ex3_lzo_din[67] = (~ex3_lzo_dcd_b[67]);
   assign f_lze_ex3_lzo_din[68] = (~ex3_lzo_dcd_b[68]);
   assign f_lze_ex3_lzo_din[69] = (~ex3_lzo_dcd_b[69]);
   assign f_lze_ex3_lzo_din[70] = (~ex3_lzo_dcd_b[70]);
   assign f_lze_ex3_lzo_din[71] = (~ex3_lzo_dcd_b[71]);
   assign f_lze_ex3_lzo_din[72] = (~ex3_lzo_dcd_b[72]);
   assign f_lze_ex3_lzo_din[73] = (~ex3_lzo_dcd_b[73]);
   assign f_lze_ex3_lzo_din[74] = (~ex3_lzo_dcd_b[74]);
   assign f_lze_ex3_lzo_din[75] = (~ex3_lzo_dcd_b[75]);
   assign f_lze_ex3_lzo_din[76] = (~ex3_lzo_dcd_b[76]);
   assign f_lze_ex3_lzo_din[77] = (~ex3_lzo_dcd_b[77]);
   assign f_lze_ex3_lzo_din[78] = (~ex3_lzo_dcd_b[78]);
   assign f_lze_ex3_lzo_din[79] = (~ex3_lzo_dcd_b[79]);
   assign f_lze_ex3_lzo_din[80] = (~ex3_lzo_dcd_b[80]);
   assign f_lze_ex3_lzo_din[81] = (~ex3_lzo_dcd_b[81]);
   assign f_lze_ex3_lzo_din[82] = (~ex3_lzo_dcd_b[82]);
   assign f_lze_ex3_lzo_din[83] = (~ex3_lzo_dcd_b[83]);
   assign f_lze_ex3_lzo_din[84] = (~ex3_lzo_dcd_b[84]);
   assign f_lze_ex3_lzo_din[85] = (~ex3_lzo_dcd_b[85]);
   assign f_lze_ex3_lzo_din[86] = (~ex3_lzo_dcd_b[86]);
   assign f_lze_ex3_lzo_din[87] = (~ex3_lzo_dcd_b[87]);
   assign f_lze_ex3_lzo_din[88] = (~ex3_lzo_dcd_b[88]);
   assign f_lze_ex3_lzo_din[89] = (~ex3_lzo_dcd_b[89]);
   assign f_lze_ex3_lzo_din[90] = (~ex3_lzo_dcd_b[90]);
   assign f_lze_ex3_lzo_din[91] = (~ex3_lzo_dcd_b[91]);
   assign f_lze_ex3_lzo_din[92] = (~ex3_lzo_dcd_b[92]);
   assign f_lze_ex3_lzo_din[93] = (~ex3_lzo_dcd_b[93]);
   assign f_lze_ex3_lzo_din[94] = (~ex3_lzo_dcd_b[94]);
   assign f_lze_ex3_lzo_din[95] = (~ex3_lzo_dcd_b[95]);
   assign f_lze_ex3_lzo_din[96] = (~ex3_lzo_dcd_b[96]);
   assign f_lze_ex3_lzo_din[97] = (~ex3_lzo_dcd_b[97]);
   assign f_lze_ex3_lzo_din[98] = (~ex3_lzo_dcd_b[98]);
   assign f_lze_ex3_lzo_din[99] = (~(ex3_lzo_dcd_b[99] & (~f_pic_ex3_to_integer)));
   assign f_lze_ex3_lzo_din[100] = (~ex3_lzo_dcd_b[100]);
   assign f_lze_ex3_lzo_din[101] = (~ex3_lzo_dcd_b[101]);
   assign f_lze_ex3_lzo_din[102] = (~ex3_lzo_dcd_b[102]);
   assign f_lze_ex3_lzo_din[103] = (~ex3_lzo_dcd_b[103]);
   assign f_lze_ex3_lzo_din[104] = (~ex3_lzo_dcd_b[104]);
   assign f_lze_ex3_lzo_din[105] = (~ex3_lzo_dcd_b[105]);
   assign f_lze_ex3_lzo_din[106] = (~ex3_lzo_dcd_b[106]);
   assign f_lze_ex3_lzo_din[107] = (~ex3_lzo_dcd_b[107]);
   assign f_lze_ex3_lzo_din[108] = (~ex3_lzo_dcd_b[108]);
   assign f_lze_ex3_lzo_din[109] = (~ex3_lzo_dcd_b[109]);
   assign f_lze_ex3_lzo_din[110] = (~ex3_lzo_dcd_b[110]);
   assign f_lze_ex3_lzo_din[111] = (~ex3_lzo_dcd_b[111]);
   assign f_lze_ex3_lzo_din[112] = (~ex3_lzo_dcd_b[112]);
   assign f_lze_ex3_lzo_din[113] = (~ex3_lzo_dcd_b[113]);
   assign f_lze_ex3_lzo_din[114] = (~ex3_lzo_dcd_b[114]);
   assign f_lze_ex3_lzo_din[115] = (~ex3_lzo_dcd_b[115]);
   assign f_lze_ex3_lzo_din[116] = (~ex3_lzo_dcd_b[116]);
   assign f_lze_ex3_lzo_din[117] = (~ex3_lzo_dcd_b[117]);
   assign f_lze_ex3_lzo_din[118] = (~ex3_lzo_dcd_b[118]);
   assign f_lze_ex3_lzo_din[119] = (~ex3_lzo_dcd_b[119]);
   assign f_lze_ex3_lzo_din[120] = (~ex3_lzo_dcd_b[120]);
   assign f_lze_ex3_lzo_din[121] = (~ex3_lzo_dcd_b[121]);
   assign f_lze_ex3_lzo_din[122] = (~ex3_lzo_dcd_b[122]);
   assign f_lze_ex3_lzo_din[123] = (~ex3_lzo_dcd_b[123]);
   assign f_lze_ex3_lzo_din[124] = (~ex3_lzo_dcd_b[124]);
   assign f_lze_ex3_lzo_din[125] = (~ex3_lzo_dcd_b[125]);
   assign f_lze_ex3_lzo_din[126] = (~ex3_lzo_dcd_b[126]);
   assign f_lze_ex3_lzo_din[127] = (~ex3_lzo_dcd_b[127]);
   assign f_lze_ex3_lzo_din[128] = (~ex3_lzo_dcd_b[128]);
   assign f_lze_ex3_lzo_din[129] = (~ex3_lzo_dcd_b[129]);
   assign f_lze_ex3_lzo_din[130] = (~ex3_lzo_dcd_b[130]);
   assign f_lze_ex3_lzo_din[131] = (~ex3_lzo_dcd_b[131]);
   assign f_lze_ex3_lzo_din[132] = (~ex3_lzo_dcd_b[132]);
   assign f_lze_ex3_lzo_din[133] = (~ex3_lzo_dcd_b[133]);
   assign f_lze_ex3_lzo_din[134] = (~ex3_lzo_dcd_b[134]);
   assign f_lze_ex3_lzo_din[135] = (~ex3_lzo_dcd_b[135]);
   assign f_lze_ex3_lzo_din[136] = (~ex3_lzo_dcd_b[136]);
   assign f_lze_ex3_lzo_din[137] = (~ex3_lzo_dcd_b[137]);
   assign f_lze_ex3_lzo_din[138] = (~ex3_lzo_dcd_b[138]);
   assign f_lze_ex3_lzo_din[139] = (~ex3_lzo_dcd_b[139]);
   assign f_lze_ex3_lzo_din[140] = (~ex3_lzo_dcd_b[140]);
   assign f_lze_ex3_lzo_din[141] = (~ex3_lzo_dcd_b[141]);
   assign f_lze_ex3_lzo_din[142] = (~ex3_lzo_dcd_b[142]);
   assign f_lze_ex3_lzo_din[143] = (~ex3_lzo_dcd_b[143]);
   assign f_lze_ex3_lzo_din[144] = (~ex3_lzo_dcd_b[144]);
   assign f_lze_ex3_lzo_din[145] = (~ex3_lzo_dcd_b[145]);
   assign f_lze_ex3_lzo_din[146] = (~ex3_lzo_dcd_b[146]);
   assign f_lze_ex3_lzo_din[147] = (~ex3_lzo_dcd_b[147]);
   assign f_lze_ex3_lzo_din[148] = (~ex3_lzo_dcd_b[148]);
   assign f_lze_ex3_lzo_din[149] = (~ex3_lzo_dcd_b[149]);
   assign f_lze_ex3_lzo_din[150] = (~ex3_lzo_dcd_b[150]);
   assign f_lze_ex3_lzo_din[151] = (~ex3_lzo_dcd_b[151]);
   assign f_lze_ex3_lzo_din[152] = (~ex3_lzo_dcd_b[152]);
   assign f_lze_ex3_lzo_din[153] = (~ex3_lzo_dcd_b[153]);
   assign f_lze_ex3_lzo_din[154] = (~ex3_lzo_dcd_b[154]);
   assign f_lze_ex3_lzo_din[155] = (~ex3_lzo_dcd_b[155]);
   assign f_lze_ex3_lzo_din[156] = (~ex3_lzo_dcd_b[156]);
   assign f_lze_ex3_lzo_din[157] = (~ex3_lzo_dcd_b[157]);
   assign f_lze_ex3_lzo_din[158] = (~ex3_lzo_dcd_b[158]);
   assign f_lze_ex3_lzo_din[159] = (~ex3_lzo_dcd_b[159]);
   assign f_lze_ex3_lzo_din[160] = (~ex3_lzo_dcd_b[160]);
   assign f_lze_ex3_lzo_din[161] = (~ex3_lzo_dcd_b[161]);
   assign f_lze_ex3_lzo_din[162] = (~ex3_lzo_dcd_b[162]);

   ////##------------------------------------------
   ////## shift right stuff ... some could be in cycle 3
   ////##------------------------------------------

   // enable shift right when bypassing a denormal B operand (and NOT ue=1 or PRRENORM)

   assign ex3_ins_est = f_pic_ex3_est_recip | f_pic_ex3_est_rsqrt;

   assign ex3_sh_rgt_en_by = (f_eie_ex3_use_bexp & ex3_expo_neg_sp_by & ex3_lzo_cont_sp & (~f_alg_ex3_byp_nonflip) & (~ex3_ins_est)) | (f_eie_ex3_use_bexp & ex3_expo_neg_dp_by & ex3_lzo_cont_dp & (~f_alg_ex3_byp_nonflip) & (~ex3_ins_est));		// set LZO[0] so can just OR into result
   assign ex3_sh_rgt_en_p = ((~f_eie_ex3_use_bexp) & ex3_expo_neg_sp & ex3_lzo_cont_sp & (~f_alg_ex3_byp_nonflip)) | ((~f_eie_ex3_use_bexp) & ex3_expo_neg_dp & ex3_lzo_cont_dp & (~f_alg_ex3_byp_nonflip));		// set LZO[0] so can just OR into result

   assign ex3_sh_rgt_en = ex3_sh_rgt_en_by | ex3_sh_rgt_en_p;

   ////----------------------------------------------------------------------------------------------
   //// you might be thinking that the shift right amount needs a limiter (so that amounts > 64
   //// do not wrap a round and leave bits in the result when the result should be zero).
   //// (1) if the shift amount belongs to the "B" operand, (bypass) and since we only shift right
   ////     when B is a denorm (it has a bit on) then the maximum shift right is (52) because
   ////     the smallest b exponent (expo min) after prenorm is -52.
   ////     there is the possibility that a divide could create an artificially small Bexpo.
   ////     if that is true the shift right amount should be zero (right 64 followed by left 0).
   //// (2) otherwise the right shift amount comes from the product exponent.
   ////     the product exponent could be very small, however for a multiply add if it becomes
   ////     too small then the exponent will come from the addend, so no problem.
   ////     a multiply instruction does not have an addend, and it could have a very small exponent.
   ////     BUT, the lead bit is at [55] and even if the shift right goes right 64 followed by left 64,
   ////     it will not but a bit into the result or guard fields.
   ////-----------------------------------------------------------------------------------------------

   // calculate shift right amount (DP) ... expo must be correct value to subtract in expo logic
   // decode =  0 shift right 1     -(-1) for expo   0_0000_0000_0000 -> 1_1111_1111_1111  -x = !x + 1,   !x = -x - 1
   // decode = -1 shift right 2     -(-2) for expo   0_0000_0000_0001 -> 1_1111_1111_1110
   // decode = -2 shift right 3     -(-3) for expo   0_0000_0000_0010 -> 1_1111_1111_1101
   //
   // max = -53                                      0_0000_0011_0101 -> 1_1111_1100_1010
   //                                                                    * **** **dd_dddd

   // calculate shift right amount (SP)
   // decode = x380 shift right 1     -(-1) for expo   0_0011_1000_0000 -> 1_1100_0111_1111  -x = !x + 1,   !x = -x - 1
   // decode = x37F shift right 2     -(-2) for expo   0_0011_1000_0001 -> 1_1100_0111_1110
   // decode = x37E shift right 3     -(-3) for expo   0_0011_1000_0010 -> 1_1100_0111_1101
   //                                                                      * **** **dd_dddd

   // expo = Bexpo - lza
   //        Bexpo + (!lza)  ... lza is usually sign extended and inverted to make a negative number,
   //        Bexpo must be added to in denorm cases
   //        Make lza a negative number, so that when it is flipped it becomes a positive number.
   //
   //                              expo_adj
   // expo = x380 896 0_0011_1000_0000    1  -( 1)      1111_1111
   // expo = x37f 895 0_0011_0111_1111    2  -( 2)      1111_1110
   // expo = x37e 894 0_0011_0111_1110    3             1111_1101
   // expo = x37d 893 0_0011_0111_1101    4             1111_1100
   // expo = x37c 892 0_0011_0111_1100    5
   // expo = x37b 891 0_0011_0111_1011    6
   // expo = x37a 890 0_0011_0111_1010    7
   // expo = x379 889 0_0011_0111_1001    8
   // expo = x378 888 0_0011_0111_1000    9
   // expo = x377 887 0_0011_0111_0111   10
   // expo = x376 886 0_0011_0111_0110   11
   // expo = x375 885 0_0011_0111_0101   12
   // expo = x374 884 0_0011_0111_0100   13
   // expo = x373 883 0_0011_0111_0011   14
   // expo = x372 882 0_0011_0111_0010   15
   // expo = x371 881 0_0011_0111_0001   16
   // expo = x370 880 0_0011_0111_0000   17
   // expo = x36f 879 0_0011_0110_1111   18
   // expo = x36e 878 0_0011_0110_1110   19
   // expo = x36d 877 0_0011_0110_1101   20
   // expo = x36c 876 0_0011_0110_1100   21
   // expo = x36b 875 0_0011_0110_1011   22
   // expo = x36a 874 0_0011_0110_1010   23 -(23)       1110_1001
   //-----------------------------
   // expo = x369 873 0_0011_0110_1001   24 -(24)       1110_1000

   // if p_exp an be more neg then -63 , then this needs to be detected and shAmt forced to a const.

   assign ex3_expo_p_sim_p[8:13] = (~ex3_expo[8:13]);

   assign ex3_expo_p_sim_g[13] = ex3_expo[13];
   assign ex3_expo_p_sim_g[12] = ex3_expo[13] | ex3_expo[12];
   assign ex3_expo_p_sim_g[11] = ex3_expo[13] | ex3_expo[12] | ex3_expo[11];
   assign ex3_expo_p_sim_g[10] = ex3_expo[13] | ex3_expo[12] | ex3_expo[11] | ex3_expo[10];
   assign ex3_expo_p_sim_g[9] = ex3_expo[13] | ex3_expo[12] | ex3_expo[11] | ex3_expo[10] | ex3_expo[9];

   assign ex3_expo_p_sim[13] = ex3_expo_p_sim_p[13];
   assign ex3_expo_p_sim[12] = ex3_expo_p_sim_p[12] ^ (ex3_expo_p_sim_g[13]);
   assign ex3_expo_p_sim[11] = ex3_expo_p_sim_p[11] ^ (ex3_expo_p_sim_g[12]);
   assign ex3_expo_p_sim[10] = ex3_expo_p_sim_p[10] ^ (ex3_expo_p_sim_g[11]);
   assign ex3_expo_p_sim[9] = ex3_expo_p_sim_p[9] ^ (ex3_expo_p_sim_g[10]);
   assign ex3_expo_p_sim[8] = ex3_expo_p_sim_p[8] ^ (ex3_expo_p_sim_g[9]);

   assign ex3_expo_sim_p[8:13] = (~ex3_expo_by[8:13]);

   assign ex3_expo_sim_g[13] = ex3_expo_by[13];
   assign ex3_expo_sim_g[12] = ex3_expo_by[13] | ex3_expo_by[12];
   assign ex3_expo_sim_g[11] = ex3_expo_by[13] | ex3_expo_by[12] | ex3_expo_by[11];
   assign ex3_expo_sim_g[10] = ex3_expo_by[13] | ex3_expo_by[12] | ex3_expo_by[11] | ex3_expo_by[10];
   assign ex3_expo_sim_g[9] = ex3_expo_by[13] | ex3_expo_by[12] | ex3_expo_by[11] | ex3_expo_by[10] | ex3_expo_by[9];

   assign ex3_expo_sim[13] = ex3_expo_sim_p[13];
   assign ex3_expo_sim[12] = ex3_expo_sim_p[12] ^ (ex3_expo_sim_g[13]);
   assign ex3_expo_sim[11] = ex3_expo_sim_p[11] ^ (ex3_expo_sim_g[12]);
   assign ex3_expo_sim[10] = ex3_expo_sim_p[10] ^ (ex3_expo_sim_g[11]);
   assign ex3_expo_sim[9] = ex3_expo_sim_p[9] ^ (ex3_expo_sim_g[10]);
   assign ex3_expo_sim[8] = ex3_expo_sim_p[8] ^ (ex3_expo_sim_g[9]);

   // testing a new (simpler) version -------------
   // could include these in lzo dis
   // could include these in lzo_dis
   assign ex3_lzo_forbyp_0 = (f_pic_ex3_est_recip) | (f_pic_ex3_est_rsqrt) | (f_alg_ex3_byp_nonflip & (~f_pic_ex3_prenorm)) | ((~f_fmt_ex3_pass_msb_dp) & (~f_pic_ex3_lzo_dis_prod)) | ((ex3_expo_neg_dp_by | ex3_dp_001_by) & ex3_lzo_cont_dp) | ((ex3_expo_neg_sp_by | ex3_sp_001_by) & ex3_lzo_cont_sp);		// allow norm to decr MSB then renormalize

   assign ex3_lzo_nonbyp_0 = (ex3_lzo_dcd_0) | (ex3_expo_neg_dp & ex3_lzo_cont_dp) | (ex3_expo_neg_sp & ex3_lzo_cont_sp) | (f_pic_ex3_est_recip) | (f_pic_ex3_est_rsqrt);

   assign ex3_sh_rgt_amt[0] = ex3_sh_rgt_en;		// huge shift right should give "0"
   assign ex3_sh_rgt_amt[1] = ex3_sh_rgt_en;		// huge shift right should give "0"
   assign ex3_sh_rgt_amt[2] = (ex3_sh_rgt_en_p & ex3_expo_p_sim[8]) | (ex3_sh_rgt_en_by & ex3_expo_sim[8]);
   assign ex3_sh_rgt_amt[3] = (ex3_sh_rgt_en_p & ex3_expo_p_sim[9]) | (ex3_sh_rgt_en_by & ex3_expo_sim[9]);
   assign ex3_sh_rgt_amt[4] = (ex3_sh_rgt_en_p & ex3_expo_p_sim[10]) | (ex3_sh_rgt_en_by & ex3_expo_sim[10]);
   assign ex3_sh_rgt_amt[5] = (ex3_sh_rgt_en_p & ex3_expo_p_sim[11]) | (ex3_sh_rgt_en_by & ex3_expo_sim[11]);
   assign ex3_sh_rgt_amt[6] = (ex3_sh_rgt_en_p & ex3_expo_p_sim[12]) | (ex3_sh_rgt_en_by & ex3_expo_sim[12]);
   assign ex3_sh_rgt_amt[7] = (ex3_sh_rgt_en_p & ex3_expo_p_sim[13]) | (ex3_sh_rgt_en_by & ex3_expo_sim[13]);

   // bit_to_set   |------ b_expo ----------|
   //  0           897  x381 0_0011_1000_0001  <== all normal SP numbers go here
   //  1           896  x380 0_0011_1000_0000
   //  2           895  x37f 0_0011_0111_1111
   //  3           894  x37e 0_0011_0111_1110
   //  4           893  x37d 0_0011_0111_1101
   //  5           892  x37c 0_0011_0111_1100
   //  6           891  x37b 0_0011_0111_1011
   //  7           890  x37a 0_0011_0111_1010
   //  8           889  x379 0_0011_0111_1001
   //  9           888  x378 0_0011_0111_1000
   // 10           887  x377 0_0011_0111_0111
   // 11           886  x376 0_0011_0111_0110
   // 12           885  x375 0_0011_0111_0101
   // 13           884  x374 0_0011_0111_0100  expo = (884 +26 -13) = 884 + 13 = 897
   // 14           883  x373 0_0011_0111_0011
   // 15           882  x372 0_0011_0111_0010
   // 16           881  x371 0_0011_0111_0001
   // 17           880  x370 0_0011_0111_0000
   // 18           879  x36f 0_0011_0011_1111
   // 19           878  x36e 0_0011_0011_1110
   // 20           877  x36d 0_0011_0011_1101
   // 21           876  x36c 0_0011_0011_1100
   // 22           875  x36b 0_0011_0011_1011
   // 23           874  x36a 0_0011_0011_1010
   // -----------------------------------------
   // 24           873  x369 0_0011_0011_1001 <=== if this or smaller do nothing (special case sp invalid)
   //

   //-=###############################################################
   //-=## ex4 latches
   //-=###############################################################


   tri_rlmreg_p #(.WIDTH(9),  .NEEDS_SRESET(0)) ex4_shr_lat(
      .force_t(force_t),		// tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),		// tidn,
      .mpw1_b(mpw1_b[3]),		// tidn,
      .mpw2_b(mpw2_b[0]),		// tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex4_shr_so),
      .scin(ex4_shr_si),
      //-----------------
      .din({ex3_sh_rgt_amt[0:7],
            ex3_sh_rgt_en}),
      //-----------------
      .dout({ex4_sh_rgt_amt[0:7],
             ex4_sh_rgt_en})
   );

   assign f_lze_ex4_sh_rgt_amt[0:7] = ex4_sh_rgt_amt[0:7];		//OUTPUT--
   assign f_lze_ex4_sh_rgt_en = ex4_sh_rgt_en;		//OUTPUT--

   //-=###############################################################
   //-= scan string
   //-=###############################################################

   assign ex4_shr_si[0:8] = {ex4_shr_so[1:8], f_lze_si};
   assign act_si[0:4] = {act_so[1:4], ex4_shr_so[0]};

   assign f_lze_so = act_so[0];

endmodule
