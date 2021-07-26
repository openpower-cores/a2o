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

//  Description:  XU Rotate/Logical Unit
//
//*****************************************************************************

module tri_st_rot_dec(
   i,
   ex1_zm_ins,
   ex1_mb_ins,
   ex1_me_ins_b,
   ex1_sh_amt,
   ex1_sh_right,
   ex1_sh_word,
   ex1_use_rb_amt_hi,
   ex1_use_rb_amt_lo,
   ex1_use_me_rb_hi,
   ex1_use_me_rb_lo,
   ex1_use_mb_rb_hi,
   ex1_use_mb_rb_lo,
   ex1_use_me_ins_hi,
   ex1_use_me_ins_lo,
   ex1_use_mb_ins_hi,
   ex1_use_mb_ins_lo,
   ex1_ins_prtyw,
   ex1_ins_prtyd,
   ex1_chk_shov_wd,
   ex1_chk_shov_dw,
   ex1_mb_gt_me,
   ex1_cmp_byt,
   ex1_sgnxtd_byte,
   ex1_sgnxtd_half,
   ex1_sgnxtd_wd,
   ex1_sra_dw,
   ex1_sra_wd,
   ex1_log_fcn,
   ex1_sel_rot_log
);
   input [0:31] i;

   output       ex1_zm_ins;
   output [0:5] ex1_mb_ins;
   output [0:5] ex1_me_ins_b;
   output [0:5] ex1_sh_amt;
   output       ex1_sh_right;
   output       ex1_sh_word;

   output       ex1_use_rb_amt_hi;
   output       ex1_use_rb_amt_lo;
   output       ex1_use_me_rb_hi;
   output       ex1_use_me_rb_lo;
   output       ex1_use_mb_rb_hi;
   output       ex1_use_mb_rb_lo;
   output       ex1_use_me_ins_hi;
   output       ex1_use_me_ins_lo;
   output       ex1_use_mb_ins_hi;
   output       ex1_use_mb_ins_lo;
   output       ex1_ins_prtyw;
   output       ex1_ins_prtyd;

   output       ex1_chk_shov_wd;
   output       ex1_chk_shov_dw;
   output       ex1_mb_gt_me;

   output       ex1_cmp_byt;

   output       ex1_sgnxtd_byte;
   output       ex1_sgnxtd_half;
   output       ex1_sgnxtd_wd;
   output       ex1_sra_dw;
   output       ex1_sra_wd;

   output [0:3] ex1_log_fcn;

   output       ex1_sel_rot_log;

   wire         cmp_byt;
   wire         rotlw;
   wire         imm_log;
   wire         rotld;
   wire         x31;
   wire         f0_xxxx00;
   wire         f0_xxx0xx;
   wire         f0_xxxx0x;
   wire         f1_1xxxx;
   wire         f1_111xx;
   wire         f1_110xx;
   wire         f1_x1x1x;
   wire         f1_x1xx0;
   wire         f1_x1xx1;
   wire         f1_xxx00;
   wire         f1_xxx11;
   wire         f1_xx10x;
   wire         f2_11xxx;
   wire         f2_xx0xx;
   wire         f2_xxx00;
   wire         f2_xxx0x;
   wire         f2_111xx;
   wire         f1_xxx01;
   wire         f1_xxx10;
   wire         f2_xx01x;
   wire         f2_xx00x;
   wire         rotlw_nm;
   wire         rotlw_pass;
   wire         rotld_pass;
   wire         sh_lft_rb;
   wire         sh_lft_rb_dw;
   wire         sh_rgt;
   wire         sh_rgt_rb;
   wire         sh_rgt_rb_dw;
   wire         shift_imm;
   wire         sh_rb;
   wire         sh_rb_dw;
   wire         sh_rb_wd;
   wire         x31_sh_log_sgn;
   wire         op_sgn_xtd;
   wire         op_sra;
   wire         wd_if_sh;
   wire         xtd_log;
   wire         sh_word_int;
   wire         imm_xor_or;
   wire         imm_and_or;
   wire         xtd_nor;
   wire         xtd_eqv_orc_nand;
   wire         xtd_nand;
   wire         xtd_andc_xor_or;
   wire         xtd_and_eqv_orc;
   wire         xtd_or_orc;
   wire         xtd_xor_or;
   wire         sel_ins_amt_hi;
   wire         sel_ins_me_lo_wd;
   wire         sel_ins_me_lo_dw;
   wire         sel_ins_amt_lo;
   wire         sel_ins_me_hi;
   wire         rot_imm_mb;
   wire         gt5_g_45;
   wire         gt5_g_23;
   wire         gt5_g_1;
   wire         gt5_t_23;
   wire         gt5_t_1;
   wire         mb_gt_me_cmp_wd0_b;
   wire         mb_gt_me_cmp_wd1_b;
   wire         mb_gt_me_cmp_wd2_b;
   wire         mb_gt_me_cmp_wd;
   wire         gt6_g_45;
   wire         gt6_g_23;
   wire         gt6_g_01;
   wire         gt6_t_23;
   wire         gt6_t_01;
   wire         mb_gt_me_cmp_dw0_b;
   wire         mb_gt_me_cmp_dw1_b;
   wire         mb_gt_me_cmp_dw2_b;
   wire         mb_gt_me_cmp_dw;
   wire [0:5]   me_ins;
   wire [1:5]   gt5_in0;
   wire [1:5]   gt5_in1;
   wire [0:5]   gt6_in0;
   wire [0:5]   gt6_in1;
   wire [1:5]   gt5_g_b;
   wire [1:4]   gt5_t_b;
   wire [0:5]   gt6_g_b;
   wire [0:4]   gt6_t_b;
   wire         f0_xxxx11;
   wire         f1_0xxxx;
   wire         f1_1xxx0;
   wire         f1_xxxx0;
   wire         f1_xxxx1;
   wire         f2_xxx1x;
   wire         f1_xx1xx;
   wire         xtd_nand_or_orc;
   wire         rld_cr;
   wire         rld_cl;
   wire         rld_icr;
   wire         rld_icl;
   wire         rld_ic;
   wire         rld_imi;
   wire         sh_lft_imm_dw;
   wire         sh_lft_imm;
   wire         sh_rgt_imm_dw;
   wire         sh_rgt_imm;
   wire         rotld_en_mbgtme;
   wire [0:3]   rf1_log_fcn;
   wire         isel;
   wire         prtyw;
   wire         prtyd;

   //--------------------------------------------------
   // decode primary field opcode bits [0:5]        ---
   //--------------------------------------------------
   assign ex1_ins_prtyw = prtyw;
   assign ex1_ins_prtyd = prtyd;

   assign isel = (x31 == 1'b1 & i[26:30] == 5'b01111) ? 1'b1 :
                 1'b0;

   assign cmp_byt = (x31 == 1'b1 & i[21:30] == 10'b0111111100) ? 1'b1 : 		// 31/508
                    1'b0;
   assign prtyw = (x31 == 1'b1 & i[21:30] == 10'b0010011010) ? 1'b1 : 		// 31/154
                  1'b0;
   assign prtyd = (x31 == 1'b1 & i[21:30] == 10'b0010111010) ? 1'b1 : 		// 31/186
                  1'b0;

   assign rotlw = (~i[0]) & i[1] & (~i[2]) & i[3];		//0101xx (20:23)
   assign imm_log = (~i[0]) & i[1] & i[2] & ((~i[3]) | (~i[4]));		//0110xx (24:27)
   //01110x (28,29)
   assign rotld = (~i[0]) & i[1] & i[2] & i[3] & i[4] & (~i[5]);		//011110 (30)
   assign x31 = (~i[0]) & i[1] & i[2] & i[3] & i[4] & i[5];		//011111 (31)

   assign f0_xxxx00 = (~i[4]) & (~i[5]);
   assign f0_xxx0xx = (~i[3]);
   assign f0_xxxx0x = (~i[4]);
   assign f0_xxxx11 = i[4] & i[5];

   //---------------------------------------------------
   // decode i(21:25)
   //---------------------------------------------------

   assign f1_0xxxx = (~i[21]);
   assign f1_110xx = i[21] & i[22] & (~i[23]);
   assign f1_111xx = i[21] & i[22] & i[23];
   assign f1_1xxx0 = i[21] & (~i[25]);
   assign f1_1xxxx = i[21];
   assign f1_x1x1x = i[22] & i[24];
   assign f1_xx1xx = i[23];
   assign f1_x1xx0 = i[22] & (~i[25]);
   assign f1_x1xx1 = i[22] & i[25];
   assign f1_xx10x = i[23] & (~i[24]);
   assign f1_xxx01 = (~i[24]) & i[25];
   assign f1_xxx11 = i[24] & i[25];
   assign f1_xxxx0 = (~i[25]);
   assign f1_xxxx1 = i[25];
   assign f1_xxx00 = (~i[24]) & (~i[25]);
   assign f1_xxx10 = i[24] & (~i[25]);

   //---------------------------------------------------
   // decode i(26:30)
   //---------------------------------------------------

   assign f2_11xxx = i[26] & i[27];		// shifts / logicals / sign_xtd
   assign f2_xxx0x = (~i[29]);		// word / double
   assign f2_111xx = i[26] & i[27] & i[28];
   assign f2_xx01x = (~i[28]) & i[29];
   assign f2_xx00x = (~i[28]) & (~i[29]);
   assign f2_xxx1x = i[29];

   assign f2_xx0xx = (~i[28]);
   assign f2_xxx00 = (~i[29]) & (~i[30]);

   assign rotlw_nm = rotlw & f0_xxxx11;
   assign rotlw_pass = rotlw & f0_xxxx00;

   assign rotld_pass = rld_imi;

   assign sh_lft_rb = x31 & f1_0xxxx;
   assign sh_lft_rb_dw = x31 & f1_0xxxx & f2_xxx1x;
   assign sh_rgt = x31 & f1_1xxxx;
   assign sh_rgt_rb = x31 & f1_1xxx0;
   assign sh_rgt_rb_dw = x31 & f1_1xxx0 & f2_xxx1x;
   assign shift_imm = x31 & f1_xxxx1;
   assign sh_rb = x31 & f1_xxxx0;
   assign sh_rb_dw = x31 & f1_xxxx0 & f2_xxx1x;
   assign sh_rb_wd = x31 & f1_xxxx0 & f2_xxx0x;
   assign x31_sh_log_sgn = x31 & f2_11xxx & (f2_xx0xx | f2_xxx00);		// Exclude loads/stores
   assign op_sgn_xtd = x31 & f1_111xx;
   assign op_sra = x31 & f1_110xx;
   assign wd_if_sh = x31 & f2_xxx0x;
   assign xtd_log = x31 & f2_111xx;

   assign sh_lft_imm_dw = 0;
   assign sh_lft_imm = 0;
   assign sh_rgt_imm_dw = x31 & i[21] & i[25] & i[29];
   assign sh_rgt_imm = x31 & i[21] & i[25];

   //---------------------------------------------------
   // output signal
   //---------------------------------------------------
   assign ex1_cmp_byt = cmp_byt;

   // (select to rot/log result instead of the adder result)
   assign ex1_sel_rot_log = (cmp_byt) | (rotlw) | (imm_log) | (rotld) | (isel) | (x31_sh_log_sgn);
   // prtyw, prtyd already included here....

   // (zero out the mask to pass "insert_data" as the result)
   // This latched, full decode ok.
   assign ex1_zm_ins = (isel) | (cmp_byt) | (xtd_log) | (imm_log) | (op_sgn_xtd) | (prtyw) | (prtyd);		// sgn extends

   // (only needs to be correct when shifting)
   assign ex1_sh_right = sh_rgt;

   assign sh_word_int = (rotlw) | (wd_if_sh);

   // (only needs to be correct when shifting)
   assign ex1_sh_word = sh_word_int;

   assign ex1_sgnxtd_byte = op_sgn_xtd & f1_xxx01 & (~isel);
   assign ex1_sgnxtd_half = op_sgn_xtd & f1_xxx00 & (~isel);
   assign ex1_sgnxtd_wd = op_sgn_xtd & f1_xxx10 & (~isel);
   assign ex1_sra_dw = op_sra & f2_xx01x & (~isel);
   assign ex1_sra_wd = op_sra & f2_xx00x & (~isel);

   assign imm_xor_or = f0_xxx0xx;
   assign imm_and_or = f0_xxxx0x;
   assign xtd_nor = f1_xxx11;
   assign xtd_eqv_orc_nand = f1_x1xx0;
   assign xtd_nand = f1_x1x1x;
   assign xtd_nand_or_orc = f1_xx1xx;
   assign xtd_andc_xor_or = f1_xxx01;
   assign xtd_and_eqv_orc = f1_xxx00;
   assign xtd_or_orc = f1_xx10x;
   assign xtd_xor_or = f1_x1xx1;

   assign ex1_log_fcn = (cmp_byt == 1'b1) ? 4'b1001 : 		// xtd_log nor
                        rf1_log_fcn;
   assign rf1_log_fcn[0] = (xtd_log & xtd_nor) | (xtd_log & xtd_eqv_orc_nand) | (cmp_byt);		// xtd_log eqv,orc,nand
   // xnor

   // xtd_log xor,or
   // xor,or
   // pass  rlwimi
   assign rf1_log_fcn[1] = (xtd_log & xtd_xor_or) | (xtd_log & xtd_nand) | (imm_log & imm_xor_or) | (rotlw_pass) | (rotld_pass);		// xtd_log nand
   // pass  rldimi

   // xtd_log andc,xor,or
   assign rf1_log_fcn[2] = (xtd_log & xtd_andc_xor_or) | (xtd_log & xtd_nand_or_orc) | (imm_log & imm_xor_or);		// xtd_log nand_or_orc
   // xor,or

   // xnor
   // xtd_log or,orc
   // and,or
   // pass  rlwimi
   assign rf1_log_fcn[3] = (cmp_byt) | (xtd_log & xtd_and_eqv_orc) | (xtd_log & xtd_or_orc) | (imm_log & imm_and_or) | (rotlw_pass) | (rotld_pass);		// xtd_log and,eqv_orc
   // pass  rldimi

   assign ex1_chk_shov_dw = (sh_rb_dw);
   assign ex1_chk_shov_wd = (sh_rb_wd);

   //---------------------------------------------

   assign ex1_me_ins_b[0:5] = (~me_ins[0:5]);

   assign me_ins[0] = (rotlw) | (i[26] & sel_ins_me_hi) | ((~i[30]) & sel_ins_amt_hi);		// force_msb

   assign me_ins[1:5] = (i[26:30] & {5{sel_ins_me_lo_wd}}) | (i[21:25] & {5{sel_ins_me_lo_dw}}) | ((~i[16:20]) & {5{sel_ins_amt_lo}});

   assign sel_ins_me_lo_wd = rotlw;
   assign sel_ins_me_lo_dw = rld_cr | rld_icr;

   assign sel_ins_amt_lo = rld_ic | rld_imi | sh_lft_rb;
   assign sel_ins_amt_hi = rld_ic | rld_imi | sh_lft_rb_dw;
   assign sel_ins_me_hi = rld_cr | rld_icr;

   assign ex1_use_me_rb_hi = (sh_lft_rb_dw);
   assign ex1_use_me_rb_lo = (sh_lft_rb);

   assign ex1_use_me_ins_hi = rld_cr | rld_icr | rld_imi | rld_ic | rotlw | sh_lft_imm_dw;
   assign ex1_use_me_ins_lo = rld_cr | rld_icr | rld_imi | rld_ic | rotlw | sh_lft_imm;

   assign rld_icl = rotld & (~i[27]) & (~i[28]) & (~i[29]);
   assign rld_icr = rotld & (~i[27]) & (~i[28]) & i[29];
   assign rld_ic = rotld & (~i[27]) & i[28] & (~i[29]);
   assign rld_imi = rotld & (~i[27]) & i[28] & i[29];
   assign rld_cl = rotld & i[27] & (~i[30]);
   assign rld_cr = rotld & i[27] & i[30];

   //---------------------------------------------

   assign ex1_mb_ins[0] = (i[26] & rot_imm_mb) | (i[30] & shift_imm) | (rotlw) | (wd_if_sh);		// force_msb
   // force_msb

   assign ex1_mb_ins[1:5] = (i[21:25] & {5{rot_imm_mb}}) | (i[16:20] & {5{shift_imm}});

   assign rot_imm_mb = (rotlw) | (rld_cl | rld_icl | rld_ic | rld_imi);

   assign ex1_use_mb_rb_lo = sh_rgt_rb;
   assign ex1_use_mb_rb_hi = sh_rgt_rb_dw;
   assign ex1_use_mb_ins_hi = rld_cl | rld_icl | rld_imi | rld_ic | rotlw | sh_rgt_imm_dw | wd_if_sh;
   assign ex1_use_mb_ins_lo = rld_cl | rld_icl | rld_imi | rld_ic | rotlw | sh_rgt_imm;

   //---------------------------------------------

   assign ex1_use_rb_amt_hi = (rld_cr) | (rld_cl) | (sh_rb_dw);

   assign ex1_use_rb_amt_lo = (rld_cr) | (rld_cl) | (rotlw_nm) | (sh_rb);		// rlwnm

   assign ex1_sh_amt[0] = i[30] & (~sh_word_int);
   assign ex1_sh_amt[1:5] = i[16:20];

   //---------------------------------------------

   assign rotld_en_mbgtme = rld_imi | rld_ic;

   assign ex1_mb_gt_me = (mb_gt_me_cmp_wd & rotlw) | (mb_gt_me_cmp_dw & rotld_en_mbgtme);		// rldic,rldimi

   //-------------------------------------------

   assign gt5_in1[1:5] = i[21:25];		// mb
   assign gt5_in0[1:5] = (~i[26:30]);		// me

   assign gt6_in1[0:5] = {i[26], i[21:25]};		// mb
   assign gt6_in0[0:5] = {i[30], i[16:20]};		// me not( not amt )

   //------------------------------------------

   assign gt5_g_b[1:5] = (~(gt5_in0[1:5] & gt5_in1[1:5]));
   assign gt5_t_b[1:4] = (~(gt5_in0[1:4] | gt5_in1[1:4]));

   assign gt5_g_45 = (~(gt5_g_b[4] & (gt5_t_b[4] | gt5_g_b[5])));
   assign gt5_g_23 = (~(gt5_g_b[2] & (gt5_t_b[2] | gt5_g_b[3])));
   assign gt5_g_1 = (~(gt5_g_b[1]));

   assign gt5_t_23 = (~(gt5_t_b[2] | gt5_t_b[3]));
   assign gt5_t_1 = (~(gt5_t_b[1]));

   assign mb_gt_me_cmp_wd0_b = (~(gt5_g_1));
   assign mb_gt_me_cmp_wd1_b = (~(gt5_g_23 & gt5_t_1));
   assign mb_gt_me_cmp_wd2_b = (~(gt5_g_45 & gt5_t_1 & gt5_t_23));

   assign mb_gt_me_cmp_wd = (~(mb_gt_me_cmp_wd0_b & mb_gt_me_cmp_wd1_b & mb_gt_me_cmp_wd2_b));

   //--------------------------------------------

   assign gt6_g_b[0:5] = (~(gt6_in0[0:5] & gt6_in1[0:5]));
   assign gt6_t_b[0:4] = (~(gt6_in0[0:4] | gt6_in1[0:4]));

   assign gt6_g_45 = (~(gt6_g_b[4] & (gt6_t_b[4] | gt6_g_b[5])));
   assign gt6_g_23 = (~(gt6_g_b[2] & (gt6_t_b[2] | gt6_g_b[3])));
   assign gt6_g_01 = (~(gt6_g_b[0] & (gt6_t_b[0] | gt6_g_b[1])));

   assign gt6_t_23 = (~(gt6_t_b[2] | gt6_t_b[3]));
   assign gt6_t_01 = (~(gt6_t_b[0] | gt6_t_b[1]));

   assign mb_gt_me_cmp_dw0_b = (~(gt6_g_01));
   assign mb_gt_me_cmp_dw1_b = (~(gt6_g_23 & gt6_t_01));
   assign mb_gt_me_cmp_dw2_b = (~(gt6_g_45 & gt6_t_01 & gt6_t_23));

   assign mb_gt_me_cmp_dw = (~(mb_gt_me_cmp_dw0_b & mb_gt_me_cmp_dw1_b & mb_gt_me_cmp_dw2_b));


endmodule
