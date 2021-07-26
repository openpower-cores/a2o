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

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@ replicate critical select latch to PO
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//xxx_lcbor: tri_lcbor generic map (expand_type => expand_type ) port map (
//    clkoff_b => clkoff_b,
//    thold    => pc_func_sl_thold_0(0),
//    sg       => pc_sg_0(0),
//    act_dis  => act_dis,
//    force    => force,
//    thold_b  => pc_func_sl_thold_0_b );
//
//    print "alter --d_mode 0 b\n";
//    print "alter delay_lclkr  0 b\n";
//    print "alter mpw1_b 1 b\n";
//    print "alter mpw2_b 1 b\n";
//    print "alter clkoff_b 1 b\n";
//    print "alter dis_act 0 b\n";
//    print "alter scan_diag 0 b\n";

// PPC FP STORE reformating
// (1) DP STORE : sp_denorm   needs to   normalize
// (2) SP STORE : dp_norm may need  to denormalize
// (3) stfwix   : pass througn

   `include "tri_a2o.vh"


module fu_sto(
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
   f_sto_si,
   f_sto_so,
   f_dcd_ex1_sto_act,
   f_dcd_ex1_sto_v,
   f_fpr_ex2_s_expo_extra,
   f_fpr_ex2_s_par,
   f_sto_ex3_s_parity_check,
   f_dcd_ex1_sto_dp,
   f_dcd_ex1_sto_sp,
   f_dcd_ex1_sto_wd,
   f_byp_ex1_s_sign,
   f_byp_ex1_s_expo,
   f_byp_ex1_s_frac,
   f_sto_ex3_sto_data
);
   inout         vdd;
   inout         gnd;
   input         clkoff_b;		// tiup
   input         act_dis;		// ??tidn??
   input         flush;		// ??tidn??
   input [1:2]   delay_lclkr;		// tidn,
   input [1:2]   mpw1_b;		// tidn,
   input [0:0]   mpw2_b;		// tidn,
   input         sg_1;
   input         thold_1;
   input         fpu_enable;		//dc_act
   input [0:`NCLK_WIDTH-1]         nclk;

   input         f_sto_si;
   output        f_sto_so;
   input         f_dcd_ex1_sto_act;
   input         f_dcd_ex1_sto_v;

   input [0:1]   f_fpr_ex2_s_expo_extra;
   input [0:7]   f_fpr_ex2_s_par;
   output        f_sto_ex3_s_parity_check;		// raw calculation

   input         f_dcd_ex1_sto_dp;
   input         f_dcd_ex1_sto_sp;
   input         f_dcd_ex1_sto_wd;

   input         f_byp_ex1_s_sign;
   input [1:11]  f_byp_ex1_s_expo;
   input [0:52]  f_byp_ex1_s_frac;

   output [0:63] f_sto_ex3_sto_data;

   // end ports

   // ENTITY


   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;

   wire          sg_0;
   wire          thold_0_b;
   wire          thold_0;

   wire          ex1_act;

   wire          ex2_act;

   (* analysis_not_referenced="TRUE" *)
   wire [0:1]    spare_unused;

   //-----------------
   wire [0:3]    act_so;		//SCAN
   wire [0:3]    act_si;		//SCAN
   wire [0:2]    ex2_sins_so;
   wire [0:2]    ex2_sins_si;
   wire [0:64]   ex2_sop_so;
   wire [0:64]   ex2_sop_si;
   wire [0:72]   ex3_sto_so;
   wire [0:72]   ex3_sto_si;
   //-----------------
   wire          ex2_s_sign;
   wire [1:11]   ex2_s_expo;
   wire [0:52]   ex2_s_frac;
   wire [0:63]   ex2_sto_data;
   wire [0:63]   ex3_sto_data;
   wire          ex2_sto_dp;
   wire          ex2_sto_sp;
   wire          ex2_sto_wd;
   wire          ex2_den_ramt8_02;
   wire          ex2_den_ramt8_18;
   wire          ex2_den_ramt4_12;
   wire          ex2_den_ramt4_08;
   wire          ex2_den_ramt4_04;
   wire          ex2_den_ramt4_00;
   wire          ex2_den_ramt1_03;
   wire          ex2_den_ramt1_02;
   wire          ex2_den_ramt1_01;
   wire          ex2_den_ramt1_00;
   wire          ex2_expo_eq896;
   wire          ex2_expo_ge896;
   wire          ex2_expo_lt896;
   wire          ex2_sts_lt896;
   wire          ex2_sts_ge896;
   wire          ex2_sts_expo_nz;
   wire          ex2_fixden;
   wire          ex2_fixden_small;
   wire          ex2_fixden_big;
   wire          ex2_std_nonden;
   wire          ex2_std_fixden_big;
   wire          ex2_std_fixden_small;
   wire          ex2_std_nonbig;
   wire          ex2_std_nonden_wd;
   wire          ex2_std_lamt8_02;
   wire          ex2_std_lamt8_10;
   wire          ex2_std_lamt8_18;
   wire          ex2_std_lamt2_0;
   wire          ex2_std_lamt2_2;
   wire          ex2_std_lamt2_4;
   wire          ex2_std_lamt2_6;
   wire          ex2_std_lamt1_0;
   wire          ex2_std_lamt1_1;
   wire [0:23]   ex2_sts_sh8;
   wire [0:23]   ex2_sts_sh4;
   wire [0:23]   ex2_sts_sh1;
   wire [0:23]   ex2_sts_nrm;
   wire [1:23]   ex2_sts_frac;
   wire [1:8]    ex2_sts_expo;
   wire [0:10]   ex2_clz02_or;
   wire [0:10]   ex2_clz02_enc4;
   wire [0:5]    ex2_clz04_or;
   wire [0:5]    ex2_clz04_enc3;
   wire [0:5]    ex2_clz04_enc4;
   wire [0:2]    ex2_clz08_or;
   wire [0:2]    ex2_clz08_enc2;
   wire [0:2]    ex2_clz08_enc3;
   wire [0:2]    ex2_clz08_enc4;
   wire [0:1]    ex2_clz16_or;
   wire [0:1]    ex2_clz16_enc1;
   wire [0:1]    ex2_clz16_enc2;
   wire [0:1]    ex2_clz16_enc3;
   wire [0:1]    ex2_clz16_enc4;
   wire [0:4]    ex2_sto_clz;
   wire [1:11]   ex2_expo_nonden;
   wire [1:11]   ex2_expo_fixden;
   wire [1:11]   ex2_std_expo;
   wire [1:52]   ex2_std_frac_nrm;
   wire [0:23]   ex2_std_sh8;
   wire [0:23]   ex2_std_sh2;
   wire [1:23]   ex2_std_frac_den;
   wire          ex2_ge874;
   wire          ex2_any_edge;
   wire [0:63]   ex3_sto_data_rot0_b;
   wire [0:63]   ex3_sto_data_rot1_b;

   wire [0:3]    ex3_sto_wd;
   wire [0:3]    ex3_sto_sp;
   wire          force_t;

   wire          ex2_s_party_chick;
   wire          ex3_s_party_chick;
   wire [0:7]    ex2_s_party;

   wire          ex2_sto_v;


   (* analysis_not_referenced="TRUE" *) // unused
   wire [0:1]    unused;

   ////############################################
   ////# pervasive
   ////############################################

   assign unused[0] = ex2_sts_sh1[0] | ex2_sts_nrm[0] | ex2_std_sh2[0];


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

    assign ex1_act = f_dcd_ex1_sto_act;

   tri_rlmreg_p #(.WIDTH(4)) act_lat(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .force_t(force_t),		// tidn
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[1]),		// tidn,
      .mpw1_b(mpw1_b[1]),		// tidn,
      .mpw2_b(mpw2_b[0]),		// tidn,
      .act(tiup),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(act_so),
      .scin(act_si),
      //-----------------
      .din({   ex1_act,
	       spare_unused[0],
               spare_unused[1],
               f_dcd_ex1_sto_v}),
      //-----------------
      .dout({  ex2_act,
	       spare_unused[0],
               spare_unused[1],
               ex2_sto_v})
   );
   assign  unused[1] = ex2_sto_v;


   ////##############################################
   ////# EX2 latch inputs from ex1
   ////##############################################


   tri_rlmreg_p #(.WIDTH(3),  .IBUF(1'B1)) ex2_sins_lat(
      .force_t(force_t),		//tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[1]),		//tidn,
      .mpw1_b(mpw1_b[1]),		//tidn,
      .mpw2_b(mpw2_b[0]),		//tidn,
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex1_act),
      .vd(vdd),
      .gd(gnd),
      .scout(ex2_sins_so),
      .scin(ex2_sins_si),
      //-----------------
      .din({   f_dcd_ex1_sto_dp,
               f_dcd_ex1_sto_sp,
               f_dcd_ex1_sto_wd}),
      //-----------------
      .dout({  ex2_sto_dp,
               ex2_sto_sp,
               ex2_sto_wd})
   );


   tri_rlmreg_p #(.WIDTH(65),  .NEEDS_SRESET(0), .IBUF(1'B1)) ex2_sop_lat(
      .force_t(force_t),		//tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[1]),		//tidn,
      .mpw1_b(mpw1_b[1]),		//tidn,
      .mpw2_b(mpw2_b[0]),		//tidn,
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex1_act),
      .vd(vdd),
      .gd(gnd),
      .scout(ex2_sop_so),
      .scin(ex2_sop_si),
      //-----------------
      .din({ f_byp_ex1_s_sign,
             f_byp_ex1_s_expo[1:11],
             f_byp_ex1_s_frac[0:52]}),
      //-----------------
      .dout({ ex2_s_sign,
              ex2_s_expo[1:11],
              ex2_s_frac[0:52]})
   );

   ////##############################################
   ////# EX2 logic
   ////##############################################

   ////###################################################
   ////# shifting  for store sp
   ////###################################################
   // output of dp instr with expo below x381 needs to denormalize to sp format.
   // x380 d896 011_1000_0000 => right  1      11 11 11 <== treat as special case
   // x37F d895 011_0111_1111 => right  2      00 00 00
   // x37E d894 011_0111_1110 => right  3      00 00 01
   // x37D d893 011_0111_1101 => right  4      00 00 10
   // x37C d892 011_0111_1100 => right  5      00 00 11
   // x37B d891 011_0111_1011 => right  6      00 01 00
   // x37A d890 011_0111_1010 => right  7      00 01 01
   // x379 d889 011_0111_1001 => right  8      00 01 10
   // x378 d888 011_0111_1000 => right  9      00 01 11
   // x377 d887 011_0111_0111 => right 10      00 10 00
   // x376 d886 011_0111_0110 => right 11      00 10 01
   // x375 d885 011_0111_0101 => right 12      00 10 10
   // x374 d884 011_0111_0100 => right 13      00 10 11
   // x373 d883 011_0111_0011 => right 14      00 11 00
   // x372 d882 011_0111_0010 => right 15      00 11 01
   // x371 d881 011_0111_0001 => right 16      00 11 10
   // x370 d880 011_0111_0000 => right 17      00 11 11
   // x36F d879 011_0110_1111 => right 18      01 00 00
   // x36E d878 011_0110_1110 => right 19      01 00 01
   // x36B d877 011_0110_1101 => right 20      01 00 10
   // x36C d876 011_0110_1100 => right 21      01 00 11
   // x36B d875 011_0110_1011 => right 22      01 01 00
   // x36A d874 011_0110_1010 => right 23      01 01 01
   // x369 d873 011_0110_1001 => right 24      01 01 10   ===>  result is zero after here
   //------------------------
   //           000 0000 0011
   //           123 4567 8901

   assign ex2_den_ramt8_02 = ex2_s_expo[6] & ex2_s_expo[7];
   assign ex2_den_ramt8_18 = ex2_s_expo[6] & (~ex2_s_expo[7]);

   assign ex2_den_ramt4_12 = (~ex2_s_expo[8]) & (~ex2_s_expo[9]);
   assign ex2_den_ramt4_08 = (~ex2_s_expo[8]) & ex2_s_expo[9];
   assign ex2_den_ramt4_04 = ex2_s_expo[8] & (~ex2_s_expo[9]);
   assign ex2_den_ramt4_00 = ex2_s_expo[8] & ex2_s_expo[9];

   assign ex2_den_ramt1_03 = (~ex2_s_expo[10]) & (~ex2_s_expo[11]);
   assign ex2_den_ramt1_02 = (~ex2_s_expo[10]) & ex2_s_expo[11];
   assign ex2_den_ramt1_01 = ex2_s_expo[10] & (~ex2_s_expo[11]);
   assign ex2_den_ramt1_00 = ex2_s_expo[10] & ex2_s_expo[11];

   assign ex2_expo_eq896 = (~ex2_s_expo[1]) & ex2_s_expo[2] & ex2_s_expo[3] & ex2_s_expo[4] & (~ex2_s_expo[5]) & (~ex2_s_expo[6]) & (~ex2_s_expo[7]) & (~ex2_s_expo[8]) & (~ex2_s_expo[9]) & (~ex2_s_expo[10]) & (~ex2_s_expo[11]);		// 011_1000_0000

   assign ex2_expo_ge896 = (ex2_s_expo[1]) | (ex2_s_expo[2] & ex2_s_expo[3] & ex2_s_expo[4]);

   assign ex2_ge874 = (ex2_s_expo[1]) | (ex2_s_expo[2] & ex2_s_expo[3] & ex2_s_expo[4]) | (ex2_s_expo[2] & ex2_s_expo[3] & ex2_s_expo[5] & ex2_s_expo[6]);		// 011_0110_1010 -- enough so shifter does not wrap 011_0110_xxxx

   assign ex2_expo_lt896 = (~ex2_expo_ge896);
   assign ex2_sts_lt896 = ex2_sto_sp & ex2_expo_lt896 & ex2_ge874;		// result = zero when lt 874
   assign ex2_sts_ge896 = ex2_sto_sp & ex2_expo_ge896;

   assign ex2_sts_sh8[0:23] = ({24{ex2_den_ramt8_02}} & ({{2{tidn}}, ex2_s_frac[0:21]})) |
                              ({24{ex2_den_ramt8_18}} & ({{18{tidn}}, ex2_s_frac[0:5]}));

   assign ex2_sts_sh4[0:23] = ({24{ex2_den_ramt4_12}} & ({{12{tidn}}, ex2_sts_sh8[0:11]})) |
                              ({24{ex2_den_ramt4_08}} & ({{8{tidn}}, ex2_sts_sh8[0:15]})) |
                              ({24{ex2_den_ramt4_04}} & ({{4{tidn}}, ex2_sts_sh8[0:19]})) |
                              ({24{ex2_den_ramt4_00}} & (ex2_sts_sh8[0:23]));

   assign ex2_sts_sh1[0:23] = ({24{ex2_den_ramt1_03}} & ({{3{tidn}}, ex2_sts_sh4[0:20]})) |
                              ({24{ex2_den_ramt1_02}} & ({{2{tidn}}, ex2_sts_sh4[0:21]})) |
                              ({24{ex2_den_ramt1_01}} & ({tidn, ex2_sts_sh4[0:22]})) |
                              ({24{ex2_den_ramt1_00}} & (ex2_sts_sh4[0:23]));

   assign ex2_sts_nrm[0:23] = ({24{ex2_expo_eq896}} & ({tidn, ex2_s_frac[0:22]})) |
                              ({24{(~ex2_expo_eq896)}} & (ex2_s_frac[0:23]));

   assign ex2_sts_frac[1:23] = ({23{ex2_sts_lt896}} & ex2_sts_sh1[1:23]) |
                               ({23{ex2_sts_ge896}} & ex2_sts_nrm[1:23]);

   ////###################################################
   ////# store_sp : calc shift amount :
   ////###################################################

   assign ex2_sts_expo_nz = ex2_sto_sp & ex2_expo_ge896;
   assign ex2_sts_expo[1] = ex2_s_expo[1] & ex2_sts_expo_nz;
   assign ex2_sts_expo[2:7] = ex2_s_expo[5:10] & {6{ex2_sts_expo_nz}};
   assign ex2_sts_expo[8] = ex2_s_expo[11] & ex2_s_frac[0] & ex2_sts_expo_nz;

   ////###################################################
   ////# normalization shift left amount for store_dp
   ////###################################################
   // count leading zeroes to get the shift amount
   //bit pos dp_expo    bin_expo     inv clz lsb   shift left to norm
   //
   // 00      x381     011_1000_0001  1_1110          00  0_0000 <== normal
   // 01      x380     011_1000_0000  1_1111          01  0_0001
   // 02      x37F     011_0111_1111  0_0000          02  0_0010 <=== start clz on bit 2;
   // 03      x37E     011_0111_1110  0_0001          03  0_0010
   // 04      x37D     011_0111_1101  0_0010          04  0_0010
   // 05      x37C     011_0111_1100  0_0011          05  0_0010
   // 06      x37B     011_0111_1011  0_0100          06  0_0010
   // 07      x37A     011_0111_1010  0_0101          07  0_0010
   // 08      x379     011_0111_1001  0_0110          08  0_0010
   // 09      x378     011_0111_1000  0_0111          09  0_0010
   // 10      x377     011_0111_0111  0_1000          10  0_0010
   // 11      x376     011_0111_0110  0_1001          11  0_0010
   // 12      x375     011_0111_0101  0_1010          12  0_0010
   // 13      x374     011_0111_0100  0_1011          13  0_0010
   // 14      x373     011_0111_0011  0_1100          14  0_0010
   // 15      x372     011_0111_0010  0_1101          15  0_0010
   // 16      x371     011_0111_0001  0_1110          16  0_0010
   // 17      x370     011_0111_0000  0_1111          17  0_0010
   // 18      x36F     011_0110_1111  1_0000          18  0_0010
   // 19      x36E     011_0110_1110  1_0001          19  0_0010
   // 20      x36D     011_0110_1101  1_0010          20  0_0010
   // 21      x36C     011_0110_1100  1_0011          21  0_0010
   // 22      x36B     011_0110_1011  1_0100          22  0_0010
   // 23      x36A     011_0110_1010  1_0101          23  0_0010

   // if clz does not find leading bit (shift of 0 is ok)

   assign ex2_clz02_or[0] = ex2_s_frac[2] | ex2_s_frac[3];
   assign ex2_clz02_enc4[0] = (~ex2_s_frac[2]) & ex2_s_frac[3];

   assign ex2_clz02_or[1] = ex2_s_frac[4] | ex2_s_frac[5];
   assign ex2_clz02_enc4[1] = (~ex2_s_frac[4]) & ex2_s_frac[5];

   assign ex2_clz02_or[2] = ex2_s_frac[6] | ex2_s_frac[7];
   assign ex2_clz02_enc4[2] = (~ex2_s_frac[6]) & ex2_s_frac[7];

   assign ex2_clz02_or[3] = ex2_s_frac[8] | ex2_s_frac[9];
   assign ex2_clz02_enc4[3] = (~ex2_s_frac[8]) & ex2_s_frac[9];

   assign ex2_clz02_or[4] = ex2_s_frac[10] | ex2_s_frac[11];
   assign ex2_clz02_enc4[4] = (~ex2_s_frac[10]) & ex2_s_frac[11];

   assign ex2_clz02_or[5] = ex2_s_frac[12] | ex2_s_frac[13];
   assign ex2_clz02_enc4[5] = (~ex2_s_frac[12]) & ex2_s_frac[13];

   assign ex2_clz02_or[6] = ex2_s_frac[14] | ex2_s_frac[15];
   assign ex2_clz02_enc4[6] = (~ex2_s_frac[14]) & ex2_s_frac[15];

   assign ex2_clz02_or[7] = ex2_s_frac[16] | ex2_s_frac[17];
   assign ex2_clz02_enc4[7] = (~ex2_s_frac[16]) & ex2_s_frac[17];

   assign ex2_clz02_or[8] = ex2_s_frac[18] | ex2_s_frac[19];
   assign ex2_clz02_enc4[8] = (~ex2_s_frac[18]) & ex2_s_frac[19];

   assign ex2_clz02_or[9] = ex2_s_frac[20] | ex2_s_frac[21];
   assign ex2_clz02_enc4[9] = (~ex2_s_frac[20]) & ex2_s_frac[21];

   assign ex2_clz02_or[10] = ex2_s_frac[22] | ex2_s_frac[23];
   assign ex2_clz02_enc4[10] = (~ex2_s_frac[22]) & ex2_s_frac[23];

   assign ex2_clz04_or[0] = ex2_clz02_or[0] | ex2_clz02_or[1];
   assign ex2_clz04_enc3[0] = (~ex2_clz02_or[0]) & ex2_clz02_or[1];
   assign ex2_clz04_enc4[0] = ex2_clz02_enc4[0] | ((~ex2_clz02_or[0]) & ex2_clz02_enc4[1]);

   assign ex2_clz04_or[1] = ex2_clz02_or[2] | ex2_clz02_or[3];
   assign ex2_clz04_enc3[1] = (~ex2_clz02_or[2]) & ex2_clz02_or[3];
   assign ex2_clz04_enc4[1] = ex2_clz02_enc4[2] | ((~ex2_clz02_or[2]) & ex2_clz02_enc4[3]);

   assign ex2_clz04_or[2] = ex2_clz02_or[4] | ex2_clz02_or[5];
   assign ex2_clz04_enc3[2] = (~ex2_clz02_or[4]) & ex2_clz02_or[5];
   assign ex2_clz04_enc4[2] = ex2_clz02_enc4[4] | ((~ex2_clz02_or[4]) & ex2_clz02_enc4[5]);

   assign ex2_clz04_or[3] = ex2_clz02_or[6] | ex2_clz02_or[7];
   assign ex2_clz04_enc3[3] = (~ex2_clz02_or[6]) & ex2_clz02_or[7];
   assign ex2_clz04_enc4[3] = ex2_clz02_enc4[6] | ((~ex2_clz02_or[6]) & ex2_clz02_enc4[7]);

   assign ex2_clz04_or[4] = ex2_clz02_or[8] | ex2_clz02_or[9];
   assign ex2_clz04_enc3[4] = (~ex2_clz02_or[8]) & ex2_clz02_or[9];
   assign ex2_clz04_enc4[4] = ex2_clz02_enc4[8] | ((~ex2_clz02_or[8]) & ex2_clz02_enc4[9]);

   assign ex2_clz04_or[5] = ex2_clz02_or[10];
   assign ex2_clz04_enc3[5] = tidn;
   assign ex2_clz04_enc4[5] = ex2_clz02_enc4[10];

   assign ex2_clz08_or[0] = ex2_clz04_or[0] | ex2_clz04_or[1];
   assign ex2_clz08_enc2[0] = (~ex2_clz04_or[0]) & ex2_clz04_or[1];
   assign ex2_clz08_enc3[0] = ex2_clz04_enc3[0] | ((~ex2_clz04_or[0]) & ex2_clz04_enc3[1]);
   assign ex2_clz08_enc4[0] = ex2_clz04_enc4[0] | ((~ex2_clz04_or[0]) & ex2_clz04_enc4[1]);

   assign ex2_clz08_or[1] = ex2_clz04_or[2] | ex2_clz04_or[3];
   assign ex2_clz08_enc2[1] = (~ex2_clz04_or[2]) & ex2_clz04_or[3];
   assign ex2_clz08_enc3[1] = ex2_clz04_enc3[2] | ((~ex2_clz04_or[2]) & ex2_clz04_enc3[3]);
   assign ex2_clz08_enc4[1] = ex2_clz04_enc4[2] | ((~ex2_clz04_or[2]) & ex2_clz04_enc4[3]);

   assign ex2_clz08_or[2] = ex2_clz04_or[4] | ex2_clz04_or[5];
   assign ex2_clz08_enc2[2] = (~ex2_clz04_or[4]) & ex2_clz04_or[5];
   assign ex2_clz08_enc3[2] = ex2_clz04_enc3[4] | ((~ex2_clz04_or[4]) & ex2_clz04_enc3[5]);
   assign ex2_clz08_enc4[2] = ex2_clz04_enc4[4] | ((~ex2_clz04_or[4]) & ex2_clz04_enc4[5]);

   assign ex2_clz16_or[0] = ex2_clz08_or[0] | ex2_clz08_or[1];
   assign ex2_clz16_enc1[0] = (~ex2_clz08_or[0]) & ex2_clz08_or[1];
   assign ex2_clz16_enc2[0] = ex2_clz08_enc2[0] | ((~ex2_clz08_or[0]) & ex2_clz08_enc2[1]);
   assign ex2_clz16_enc3[0] = ex2_clz08_enc3[0] | ((~ex2_clz08_or[0]) & ex2_clz08_enc3[1]);
   assign ex2_clz16_enc4[0] = ex2_clz08_enc4[0] | ((~ex2_clz08_or[0]) & ex2_clz08_enc4[1]);

   assign ex2_clz16_or[1] = ex2_clz08_or[2];
   assign ex2_clz16_enc1[1] = tidn;
   assign ex2_clz16_enc2[1] = ex2_clz08_enc2[2];
   assign ex2_clz16_enc3[1] = ex2_clz08_enc3[2];
   assign ex2_clz16_enc4[1] = ex2_clz08_enc4[2];

   assign ex2_sto_clz[0] = (~ex2_clz16_or[0]) & ex2_clz16_or[1];
   assign ex2_sto_clz[1] = ex2_clz16_enc1[0] | ((~ex2_clz16_or[0]) & ex2_clz16_enc1[1]);
   assign ex2_sto_clz[2] = ex2_clz16_enc2[0] | ((~ex2_clz16_or[0]) & ex2_clz16_enc2[1]);
   assign ex2_sto_clz[3] = ex2_clz16_enc3[0] | ((~ex2_clz16_or[0]) & ex2_clz16_enc3[1]);
   assign ex2_sto_clz[4] = ex2_clz16_enc4[0] | ((~ex2_clz16_or[0]) & ex2_clz16_enc4[1]);

   assign ex2_any_edge = (ex2_clz16_or[0] | ex2_clz16_or[1]);

   ////###################################################
   ////# exponent for store dp
   ////###################################################
   // exponent must be zero when input is zero  x001 * !imp

   assign ex2_fixden = ex2_s_expo[2] & (~ex2_s_frac[0]);		// sp denorm or zero
   assign ex2_fixden_small = ex2_s_expo[2] & (~ex2_s_frac[0]) & ex2_s_frac[1];
   assign ex2_fixden_big = ex2_s_expo[2] & (~ex2_s_frac[0]) & (~ex2_s_frac[1]);

   assign ex2_std_nonden = ex2_sto_dp & (~ex2_fixden);
   assign ex2_std_fixden_big = ex2_sto_dp & ex2_fixden_big;		// denorm more than 1
   assign ex2_std_fixden_small = ex2_sto_dp & ex2_fixden_small;		// denorm by 1
   assign ex2_std_nonbig = ex2_sto_dp & (~ex2_fixden_big);

   // dp denorm/zero turn of expo lsb
   // sp denorm(1)   goes to x380 (turn off lsb)
   assign ex2_expo_nonden[1:10] = ex2_s_expo[1:10] & {10{ex2_std_nonbig}};
   assign ex2_expo_nonden[11] = ex2_s_expo[11] & ex2_s_frac[0] & ex2_std_nonden;

   assign ex2_expo_fixden[1] = tidn;		// 011_011x_xxx
   assign ex2_expo_fixden[2] = ex2_any_edge;		// 011_011x_xxx
   assign ex2_expo_fixden[3] = ex2_any_edge;		// 011_011x_xxx
   assign ex2_expo_fixden[4] = tidn;		// 011_011x_xxx
   assign ex2_expo_fixden[5] = ex2_any_edge;		// 011_011x_xxx
   assign ex2_expo_fixden[6] = ex2_any_edge;		// 011_011x_xxx
   assign ex2_expo_fixden[7:11] = (~ex2_sto_clz[0:4]) & {5{ex2_any_edge}};

   assign ex2_std_expo[1:11] = (ex2_expo_nonden[1:11]) |
                               (ex2_expo_fixden[1:11] & {11{ex2_std_fixden_big}});

   ////#########################################################################
   ////# shifting for store dp
   ////#########################################################################

   assign ex2_std_nonden_wd = ex2_std_nonden | ex2_sto_wd;

   assign ex2_std_frac_nrm[1:20] = (ex2_s_frac[2:21] & {20{ex2_std_fixden_small}}) |
                                   (ex2_s_frac[1:20] & {20{ex2_std_nonden}});
   assign ex2_std_frac_nrm[21:52] = (({ex2_s_frac[22:52], tidn}) & {32{ex2_std_fixden_small}}) |
                                      (ex2_s_frac[21:52] & {32{ex2_std_nonden_wd}});		// stfiwx has a 32 bit result   f[21:52]

   assign ex2_std_lamt8_02 = (~ex2_sto_clz[0]) & (~ex2_sto_clz[1]);		// 0 + 2
   assign ex2_std_lamt8_10 = (~ex2_sto_clz[0]) & ex2_sto_clz[1];		// 8 + 2
   assign ex2_std_lamt8_18 = ex2_sto_clz[0] & (~ex2_sto_clz[1]);		//16 + 2

   assign ex2_std_lamt2_0 = (~ex2_sto_clz[2]) & (~ex2_sto_clz[3]);
   assign ex2_std_lamt2_2 = (~ex2_sto_clz[2]) & ex2_sto_clz[3];
   assign ex2_std_lamt2_4 = ex2_sto_clz[2] & (~ex2_sto_clz[3]);
   assign ex2_std_lamt2_6 = ex2_sto_clz[2] & ex2_sto_clz[3];

   assign ex2_std_lamt1_0 = ex2_std_fixden_big & (~ex2_sto_clz[4]);
   assign ex2_std_lamt1_1 = ex2_std_fixden_big & ex2_sto_clz[4];

   //@--  -- if the input was an sp denorm (sp format) then there are only 24 input bits [0:23]

   assign ex2_std_sh8[0:23] = (({ex2_s_frac[2:23], {2{tidn}}}) & {24{ex2_std_lamt8_02}}) |
                              (({ex2_s_frac[10:23], {10{tidn}}}) & {24{ex2_std_lamt8_10}}) |
                              (({ex2_s_frac[18:23], {18{tidn}}}) & {24{ex2_std_lamt8_18}});

   assign ex2_std_sh2[0:23] = (ex2_std_sh8[0:23] &           {24{ex2_std_lamt2_0}}) |
                              (({ex2_std_sh8[2:23], {2{tidn}}}) & {24{ex2_std_lamt2_2}}) |
                              (({ex2_std_sh8[4:23], {4{tidn}}}) & {24{ex2_std_lamt2_4}}) |
                              (({ex2_std_sh8[6:23], {6{tidn}}}) & {24{ex2_std_lamt2_6}});

   assign ex2_std_frac_den[1:23] = (ex2_std_sh2[1:23] &           {23{ex2_std_lamt1_0}}) |
                                   (({ex2_std_sh2[2:23], tidn}) & {23{ex2_std_lamt1_1}});

   ////###################################################
   ////# final combinations
   ////###################################################

   assign ex2_sto_data[0] = ex2_s_sign & (~ex2_sto_wd);		// sign bit

   assign ex2_sto_data[1:8] = ex2_sts_expo[1:8] | ex2_std_expo[1:8];

   assign ex2_sto_data[9:11] = ex2_sts_frac[1:3] | ex2_std_expo[9:11];

   assign ex2_sto_data[12:31] = ex2_sts_frac[4:23] | ex2_std_frac_nrm[1:20] | ex2_std_frac_den[1:20];

   assign ex2_sto_data[32:34] = ex2_std_frac_nrm[21:23] | ex2_std_frac_den[21:23];		//03 bits (includes stfwix)

   assign ex2_sto_data[35:63] = ex2_std_frac_nrm[24:52];		//29 bits (includes stfwix)

   ////##############################################
   ////# EX3 latches
   ////##############################################


   tri_rlmreg_p #(.WIDTH(73),  .NEEDS_SRESET(0), .IBUF(1'B1)) ex3_sto_lat(
      .force_t(force_t),		//tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),		//tidn,
      .mpw1_b(mpw1_b[2]),		//tidn,
      .mpw2_b(mpw2_b[0]),		//tidn,
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex2_act),
      .vd(vdd),
      .gd(gnd),
      .scout(ex3_sto_so),
      .scin(ex3_sto_si),
      //-----------------
      .din({   ex2_sto_data[0:63],
               ex2_sto_sp,
               ex2_sto_sp,
               ex2_sto_sp,
               ex2_sto_sp,
               ex2_sto_wd,
               ex2_sto_wd,
               ex2_sto_wd,
               ex2_sto_wd,
               ex2_s_party_chick}),

      .dout({  ex3_sto_data[0:63],		//LAT--
               ex3_sto_sp[0],		//LAT--
               ex3_sto_sp[1],		//LAT--
               ex3_sto_sp[2],		//LAT--
               ex3_sto_sp[3],		//LAT--
               ex3_sto_wd[0],		//LAT--
               ex3_sto_wd[1],		//LAT--
               ex3_sto_wd[2],		//LAT--
               ex3_sto_wd[3],		//LAT--
               ex3_s_party_chick})		//LAT--
   );

   assign f_sto_ex3_s_parity_check = ex3_s_party_chick;

   //    1     unused
   //    2       xx
   //    3        1
   //    4        2
   //    5        3
   //    6        4
   //    7        5
   //    8        6
   //    9        7
   //   10        8
   //   11        9
   //   12       10
   //   13       11

   assign ex2_s_party[0] = ex2_s_sign ^ f_fpr_ex2_s_expo_extra[0] ^ f_fpr_ex2_s_expo_extra[1] ^ ex2_s_expo[1] ^ ex2_s_expo[2] ^ ex2_s_expo[3] ^ ex2_s_expo[4] ^ ex2_s_expo[5] ^ ex2_s_expo[6] ^ ex2_s_expo[7];
   assign ex2_s_party[1] = ex2_s_expo[8] ^ ex2_s_expo[9] ^ ex2_s_expo[10] ^ ex2_s_expo[11] ^ ex2_s_frac[0] ^ ex2_s_frac[1] ^ ex2_s_frac[2] ^ ex2_s_frac[3] ^ ex2_s_frac[4];
   assign ex2_s_party[2] = ex2_s_frac[5] ^ ex2_s_frac[6] ^ ex2_s_frac[7] ^ ex2_s_frac[8] ^ ex2_s_frac[9] ^ ex2_s_frac[10] ^ ex2_s_frac[11] ^ ex2_s_frac[12];
   assign ex2_s_party[3] = ex2_s_frac[13] ^ ex2_s_frac[14] ^ ex2_s_frac[15] ^ ex2_s_frac[16] ^ ex2_s_frac[17] ^ ex2_s_frac[18] ^ ex2_s_frac[19] ^ ex2_s_frac[20];
   assign ex2_s_party[4] = ex2_s_frac[21] ^ ex2_s_frac[22] ^ ex2_s_frac[23] ^ ex2_s_frac[24] ^ ex2_s_frac[25] ^ ex2_s_frac[26] ^ ex2_s_frac[27] ^ ex2_s_frac[28];
   assign ex2_s_party[5] = ex2_s_frac[29] ^ ex2_s_frac[30] ^ ex2_s_frac[31] ^ ex2_s_frac[32] ^ ex2_s_frac[33] ^ ex2_s_frac[34] ^ ex2_s_frac[35] ^ ex2_s_frac[36];
   assign ex2_s_party[6] = ex2_s_frac[37] ^ ex2_s_frac[38] ^ ex2_s_frac[39] ^ ex2_s_frac[40] ^ ex2_s_frac[41] ^ ex2_s_frac[42] ^ ex2_s_frac[43] ^ ex2_s_frac[44];
   assign ex2_s_party[7] = ex2_s_frac[45] ^ ex2_s_frac[46] ^ ex2_s_frac[47] ^ ex2_s_frac[48] ^ ex2_s_frac[49] ^ ex2_s_frac[50] ^ ex2_s_frac[51] ^ ex2_s_frac[52];

   assign ex2_s_party_chick = (ex2_s_party[0] ^ f_fpr_ex2_s_par[0]) | (ex2_s_party[1] ^ f_fpr_ex2_s_par[1]) | (ex2_s_party[2] ^ f_fpr_ex2_s_par[2]) | (ex2_s_party[3] ^ f_fpr_ex2_s_par[3]) | (ex2_s_party[4] ^ f_fpr_ex2_s_par[4]) | (ex2_s_party[5] ^ f_fpr_ex2_s_par[5]) | (ex2_s_party[6] ^ f_fpr_ex2_s_par[6]) | (ex2_s_party[7] ^ f_fpr_ex2_s_par[7]);

   ////##############################################
   ////# EX3 logic
   ////##############################################
   //@@ ex3_sto_data_rot(0 to 31) <=
   //@@      ( ex3_sto_data( 0 to 31) and ( 0 to 31=> not ex3_sto_wd) ) or
   //@@      ( ex3_sto_data(32 to 63) and ( 0 to 31=>     ex3_sto_wd) );
   //@@
   //@@    ex3_sto_data_rot(32 to 63) <=
   //@@          ( ex3_sto_data( 0 to 31) and (32 to 63=>     ex3_sto_sp) ) or
   //@@          ( ex3_sto_data(32 to 63) and (32 to 63=> not ex3_sto_sp) );
   //@@
   //@@
   //@@    f_sto_ex3_sto_data(  0 to 63)  <= ex3_sto_data_rot(0 to 63);
   //@@

   assign ex3_sto_data_rot0_b[0] = (~(ex3_sto_data[0] & (~ex3_sto_wd[0])));
   assign ex3_sto_data_rot0_b[1] = (~(ex3_sto_data[1] & (~ex3_sto_wd[0])));
   assign ex3_sto_data_rot0_b[2] = (~(ex3_sto_data[2] & (~ex3_sto_wd[0])));
   assign ex3_sto_data_rot0_b[3] = (~(ex3_sto_data[3] & (~ex3_sto_wd[0])));
   assign ex3_sto_data_rot0_b[4] = (~(ex3_sto_data[4] & (~ex3_sto_wd[0])));
   assign ex3_sto_data_rot0_b[5] = (~(ex3_sto_data[5] & (~ex3_sto_wd[0])));
   assign ex3_sto_data_rot0_b[6] = (~(ex3_sto_data[6] & (~ex3_sto_wd[0])));
   assign ex3_sto_data_rot0_b[7] = (~(ex3_sto_data[7] & (~ex3_sto_wd[0])));
   assign ex3_sto_data_rot0_b[8] = (~(ex3_sto_data[8] & (~ex3_sto_wd[1])));
   assign ex3_sto_data_rot0_b[9] = (~(ex3_sto_data[9] & (~ex3_sto_wd[1])));
   assign ex3_sto_data_rot0_b[10] = (~(ex3_sto_data[10] & (~ex3_sto_wd[1])));
   assign ex3_sto_data_rot0_b[11] = (~(ex3_sto_data[11] & (~ex3_sto_wd[1])));
   assign ex3_sto_data_rot0_b[12] = (~(ex3_sto_data[12] & (~ex3_sto_wd[1])));
   assign ex3_sto_data_rot0_b[13] = (~(ex3_sto_data[13] & (~ex3_sto_wd[1])));
   assign ex3_sto_data_rot0_b[14] = (~(ex3_sto_data[14] & (~ex3_sto_wd[1])));
   assign ex3_sto_data_rot0_b[15] = (~(ex3_sto_data[15] & (~ex3_sto_wd[1])));
   assign ex3_sto_data_rot0_b[16] = (~(ex3_sto_data[16] & (~ex3_sto_wd[2])));
   assign ex3_sto_data_rot0_b[17] = (~(ex3_sto_data[17] & (~ex3_sto_wd[2])));
   assign ex3_sto_data_rot0_b[18] = (~(ex3_sto_data[18] & (~ex3_sto_wd[2])));
   assign ex3_sto_data_rot0_b[19] = (~(ex3_sto_data[19] & (~ex3_sto_wd[2])));
   assign ex3_sto_data_rot0_b[20] = (~(ex3_sto_data[20] & (~ex3_sto_wd[2])));
   assign ex3_sto_data_rot0_b[21] = (~(ex3_sto_data[21] & (~ex3_sto_wd[2])));
   assign ex3_sto_data_rot0_b[22] = (~(ex3_sto_data[22] & (~ex3_sto_wd[2])));
   assign ex3_sto_data_rot0_b[23] = (~(ex3_sto_data[23] & (~ex3_sto_wd[2])));
   assign ex3_sto_data_rot0_b[24] = (~(ex3_sto_data[24] & (~ex3_sto_wd[3])));
   assign ex3_sto_data_rot0_b[25] = (~(ex3_sto_data[25] & (~ex3_sto_wd[3])));
   assign ex3_sto_data_rot0_b[26] = (~(ex3_sto_data[26] & (~ex3_sto_wd[3])));
   assign ex3_sto_data_rot0_b[27] = (~(ex3_sto_data[27] & (~ex3_sto_wd[3])));
   assign ex3_sto_data_rot0_b[28] = (~(ex3_sto_data[28] & (~ex3_sto_wd[3])));
   assign ex3_sto_data_rot0_b[29] = (~(ex3_sto_data[29] & (~ex3_sto_wd[3])));
   assign ex3_sto_data_rot0_b[30] = (~(ex3_sto_data[30] & (~ex3_sto_wd[3])));
   assign ex3_sto_data_rot0_b[31] = (~(ex3_sto_data[31] & (~ex3_sto_wd[3])));
   assign ex3_sto_data_rot0_b[32] = (~(ex3_sto_data[0] & ex3_sto_sp[0]));
   assign ex3_sto_data_rot0_b[33] = (~(ex3_sto_data[1] & ex3_sto_sp[0]));
   assign ex3_sto_data_rot0_b[34] = (~(ex3_sto_data[2] & ex3_sto_sp[0]));
   assign ex3_sto_data_rot0_b[35] = (~(ex3_sto_data[3] & ex3_sto_sp[0]));
   assign ex3_sto_data_rot0_b[36] = (~(ex3_sto_data[4] & ex3_sto_sp[0]));
   assign ex3_sto_data_rot0_b[37] = (~(ex3_sto_data[5] & ex3_sto_sp[0]));
   assign ex3_sto_data_rot0_b[38] = (~(ex3_sto_data[6] & ex3_sto_sp[0]));
   assign ex3_sto_data_rot0_b[39] = (~(ex3_sto_data[7] & ex3_sto_sp[0]));
   assign ex3_sto_data_rot0_b[40] = (~(ex3_sto_data[8] & ex3_sto_sp[1]));
   assign ex3_sto_data_rot0_b[41] = (~(ex3_sto_data[9] & ex3_sto_sp[1]));
   assign ex3_sto_data_rot0_b[42] = (~(ex3_sto_data[10] & ex3_sto_sp[1]));
   assign ex3_sto_data_rot0_b[43] = (~(ex3_sto_data[11] & ex3_sto_sp[1]));
   assign ex3_sto_data_rot0_b[44] = (~(ex3_sto_data[12] & ex3_sto_sp[1]));
   assign ex3_sto_data_rot0_b[45] = (~(ex3_sto_data[13] & ex3_sto_sp[1]));
   assign ex3_sto_data_rot0_b[46] = (~(ex3_sto_data[14] & ex3_sto_sp[1]));
   assign ex3_sto_data_rot0_b[47] = (~(ex3_sto_data[15] & ex3_sto_sp[1]));
   assign ex3_sto_data_rot0_b[48] = (~(ex3_sto_data[16] & ex3_sto_sp[2]));
   assign ex3_sto_data_rot0_b[49] = (~(ex3_sto_data[17] & ex3_sto_sp[2]));
   assign ex3_sto_data_rot0_b[50] = (~(ex3_sto_data[18] & ex3_sto_sp[2]));
   assign ex3_sto_data_rot0_b[51] = (~(ex3_sto_data[19] & ex3_sto_sp[2]));
   assign ex3_sto_data_rot0_b[52] = (~(ex3_sto_data[20] & ex3_sto_sp[2]));
   assign ex3_sto_data_rot0_b[53] = (~(ex3_sto_data[21] & ex3_sto_sp[2]));
   assign ex3_sto_data_rot0_b[54] = (~(ex3_sto_data[22] & ex3_sto_sp[2]));
   assign ex3_sto_data_rot0_b[55] = (~(ex3_sto_data[23] & ex3_sto_sp[2]));
   assign ex3_sto_data_rot0_b[56] = (~(ex3_sto_data[24] & ex3_sto_sp[3]));
   assign ex3_sto_data_rot0_b[57] = (~(ex3_sto_data[25] & ex3_sto_sp[3]));
   assign ex3_sto_data_rot0_b[58] = (~(ex3_sto_data[26] & ex3_sto_sp[3]));
   assign ex3_sto_data_rot0_b[59] = (~(ex3_sto_data[27] & ex3_sto_sp[3]));
   assign ex3_sto_data_rot0_b[60] = (~(ex3_sto_data[28] & ex3_sto_sp[3]));
   assign ex3_sto_data_rot0_b[61] = (~(ex3_sto_data[29] & ex3_sto_sp[3]));
   assign ex3_sto_data_rot0_b[62] = (~(ex3_sto_data[30] & ex3_sto_sp[3]));
   assign ex3_sto_data_rot0_b[63] = (~(ex3_sto_data[31] & ex3_sto_sp[3]));

   assign ex3_sto_data_rot1_b[0] = (~(ex3_sto_data[32] & ex3_sto_wd[0]));
   assign ex3_sto_data_rot1_b[1] = (~(ex3_sto_data[33] & ex3_sto_wd[0]));
   assign ex3_sto_data_rot1_b[2] = (~(ex3_sto_data[34] & ex3_sto_wd[0]));
   assign ex3_sto_data_rot1_b[3] = (~(ex3_sto_data[35] & ex3_sto_wd[0]));
   assign ex3_sto_data_rot1_b[4] = (~(ex3_sto_data[36] & ex3_sto_wd[0]));
   assign ex3_sto_data_rot1_b[5] = (~(ex3_sto_data[37] & ex3_sto_wd[0]));
   assign ex3_sto_data_rot1_b[6] = (~(ex3_sto_data[38] & ex3_sto_wd[0]));
   assign ex3_sto_data_rot1_b[7] = (~(ex3_sto_data[39] & ex3_sto_wd[0]));
   assign ex3_sto_data_rot1_b[8] = (~(ex3_sto_data[40] & ex3_sto_wd[1]));
   assign ex3_sto_data_rot1_b[9] = (~(ex3_sto_data[41] & ex3_sto_wd[1]));
   assign ex3_sto_data_rot1_b[10] = (~(ex3_sto_data[42] & ex3_sto_wd[1]));
   assign ex3_sto_data_rot1_b[11] = (~(ex3_sto_data[43] & ex3_sto_wd[1]));
   assign ex3_sto_data_rot1_b[12] = (~(ex3_sto_data[44] & ex3_sto_wd[1]));
   assign ex3_sto_data_rot1_b[13] = (~(ex3_sto_data[45] & ex3_sto_wd[1]));
   assign ex3_sto_data_rot1_b[14] = (~(ex3_sto_data[46] & ex3_sto_wd[1]));
   assign ex3_sto_data_rot1_b[15] = (~(ex3_sto_data[47] & ex3_sto_wd[1]));
   assign ex3_sto_data_rot1_b[16] = (~(ex3_sto_data[48] & ex3_sto_wd[2]));
   assign ex3_sto_data_rot1_b[17] = (~(ex3_sto_data[49] & ex3_sto_wd[2]));
   assign ex3_sto_data_rot1_b[18] = (~(ex3_sto_data[50] & ex3_sto_wd[2]));
   assign ex3_sto_data_rot1_b[19] = (~(ex3_sto_data[51] & ex3_sto_wd[2]));
   assign ex3_sto_data_rot1_b[20] = (~(ex3_sto_data[52] & ex3_sto_wd[2]));
   assign ex3_sto_data_rot1_b[21] = (~(ex3_sto_data[53] & ex3_sto_wd[2]));
   assign ex3_sto_data_rot1_b[22] = (~(ex3_sto_data[54] & ex3_sto_wd[2]));
   assign ex3_sto_data_rot1_b[23] = (~(ex3_sto_data[55] & ex3_sto_wd[2]));
   assign ex3_sto_data_rot1_b[24] = (~(ex3_sto_data[56] & ex3_sto_wd[3]));
   assign ex3_sto_data_rot1_b[25] = (~(ex3_sto_data[57] & ex3_sto_wd[3]));
   assign ex3_sto_data_rot1_b[26] = (~(ex3_sto_data[58] & ex3_sto_wd[3]));
   assign ex3_sto_data_rot1_b[27] = (~(ex3_sto_data[59] & ex3_sto_wd[3]));
   assign ex3_sto_data_rot1_b[28] = (~(ex3_sto_data[60] & ex3_sto_wd[3]));
   assign ex3_sto_data_rot1_b[29] = (~(ex3_sto_data[61] & ex3_sto_wd[3]));
   assign ex3_sto_data_rot1_b[30] = (~(ex3_sto_data[62] & ex3_sto_wd[3]));
   assign ex3_sto_data_rot1_b[31] = (~(ex3_sto_data[63] & ex3_sto_wd[3]));
   assign ex3_sto_data_rot1_b[32] = (~(ex3_sto_data[32] & (~ex3_sto_sp[0])));
   assign ex3_sto_data_rot1_b[33] = (~(ex3_sto_data[33] & (~ex3_sto_sp[0])));
   assign ex3_sto_data_rot1_b[34] = (~(ex3_sto_data[34] & (~ex3_sto_sp[0])));
   assign ex3_sto_data_rot1_b[35] = (~(ex3_sto_data[35] & (~ex3_sto_sp[0])));
   assign ex3_sto_data_rot1_b[36] = (~(ex3_sto_data[36] & (~ex3_sto_sp[0])));
   assign ex3_sto_data_rot1_b[37] = (~(ex3_sto_data[37] & (~ex3_sto_sp[0])));
   assign ex3_sto_data_rot1_b[38] = (~(ex3_sto_data[38] & (~ex3_sto_sp[0])));
   assign ex3_sto_data_rot1_b[39] = (~(ex3_sto_data[39] & (~ex3_sto_sp[0])));
   assign ex3_sto_data_rot1_b[40] = (~(ex3_sto_data[40] & (~ex3_sto_sp[1])));
   assign ex3_sto_data_rot1_b[41] = (~(ex3_sto_data[41] & (~ex3_sto_sp[1])));
   assign ex3_sto_data_rot1_b[42] = (~(ex3_sto_data[42] & (~ex3_sto_sp[1])));
   assign ex3_sto_data_rot1_b[43] = (~(ex3_sto_data[43] & (~ex3_sto_sp[1])));
   assign ex3_sto_data_rot1_b[44] = (~(ex3_sto_data[44] & (~ex3_sto_sp[1])));
   assign ex3_sto_data_rot1_b[45] = (~(ex3_sto_data[45] & (~ex3_sto_sp[1])));
   assign ex3_sto_data_rot1_b[46] = (~(ex3_sto_data[46] & (~ex3_sto_sp[1])));
   assign ex3_sto_data_rot1_b[47] = (~(ex3_sto_data[47] & (~ex3_sto_sp[1])));
   assign ex3_sto_data_rot1_b[48] = (~(ex3_sto_data[48] & (~ex3_sto_sp[2])));
   assign ex3_sto_data_rot1_b[49] = (~(ex3_sto_data[49] & (~ex3_sto_sp[2])));
   assign ex3_sto_data_rot1_b[50] = (~(ex3_sto_data[50] & (~ex3_sto_sp[2])));
   assign ex3_sto_data_rot1_b[51] = (~(ex3_sto_data[51] & (~ex3_sto_sp[2])));
   assign ex3_sto_data_rot1_b[52] = (~(ex3_sto_data[52] & (~ex3_sto_sp[2])));
   assign ex3_sto_data_rot1_b[53] = (~(ex3_sto_data[53] & (~ex3_sto_sp[2])));
   assign ex3_sto_data_rot1_b[54] = (~(ex3_sto_data[54] & (~ex3_sto_sp[2])));
   assign ex3_sto_data_rot1_b[55] = (~(ex3_sto_data[55] & (~ex3_sto_sp[2])));
   assign ex3_sto_data_rot1_b[56] = (~(ex3_sto_data[56] & (~ex3_sto_sp[3])));
   assign ex3_sto_data_rot1_b[57] = (~(ex3_sto_data[57] & (~ex3_sto_sp[3])));
   assign ex3_sto_data_rot1_b[58] = (~(ex3_sto_data[58] & (~ex3_sto_sp[3])));
   assign ex3_sto_data_rot1_b[59] = (~(ex3_sto_data[59] & (~ex3_sto_sp[3])));
   assign ex3_sto_data_rot1_b[60] = (~(ex3_sto_data[60] & (~ex3_sto_sp[3])));
   assign ex3_sto_data_rot1_b[61] = (~(ex3_sto_data[61] & (~ex3_sto_sp[3])));
   assign ex3_sto_data_rot1_b[62] = (~(ex3_sto_data[62] & (~ex3_sto_sp[3])));
   assign ex3_sto_data_rot1_b[63] = (~(ex3_sto_data[63] & (~ex3_sto_sp[3])));

   assign f_sto_ex3_sto_data[0:63] = (~(ex3_sto_data_rot0_b[0:63] & ex3_sto_data_rot1_b[0:63]));

   ////############################################
   ////# scan
   ////############################################

   assign ex2_sins_si[0:2] = {ex2_sins_so[1:2], f_sto_si};
   assign ex2_sop_si[0:64] = {ex2_sop_so[1:64], ex2_sins_so[0]};
   assign ex3_sto_si[0:72] = {ex3_sto_so[1:72], ex2_sop_so[0]};
   assign act_si[0:3] = {act_so[1:3], ex3_sto_so[0]};
   assign f_sto_so = act_so[0];

endmodule
