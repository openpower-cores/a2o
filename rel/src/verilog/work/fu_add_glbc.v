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

module fu_add_glbc(
   ex4_g16,
   ex4_t16,
   ex4_inc_all1,
   ex4_effsub,
   ex4_effsub_npz,
   ex4_effadd_npz,
   f_alg_ex4_frc_sel_p1,
   f_alg_ex4_sticky,
   f_pic_ex4_is_nan,
   f_pic_ex4_is_gt,
   f_pic_ex4_is_lt,
   f_pic_ex4_is_eq,
   f_pic_ex4_cmp_sgnpos,
   f_pic_ex4_cmp_sgnneg,
   ex4_g128,
   ex4_g128_b,
   ex4_t128,
   ex4_t128_b,
   ex4_flip_inc_p0,
   ex4_flip_inc_p1,
   ex4_inc_sel_p0,
   ex4_inc_sel_p1,
   ex4_eac_sel_p0n,
   ex4_eac_sel_p0,
   ex4_eac_sel_p1,
   ex4_sign_carry,
   ex4_flag_nan_cp1,
   ex4_flag_gt_cp1,
   ex4_flag_lt_cp1,
   ex4_flag_eq_cp1,
   ex4_flag_nan,
   ex4_flag_gt,
   ex4_flag_lt,
   ex4_flag_eq
);
   input [0:6]  ex4_g16;		// from each byte section
   input [0:6]  ex4_t16;		// from each byte section

   input        ex4_inc_all1;
   input        ex4_effsub;
   input        ex4_effsub_npz;
   input        ex4_effadd_npz;
   input        f_alg_ex4_frc_sel_p1;
   input        f_alg_ex4_sticky;
   input        f_pic_ex4_is_nan;
   input        f_pic_ex4_is_gt;
   input        f_pic_ex4_is_lt;
   input        f_pic_ex4_is_eq;
   input        f_pic_ex4_cmp_sgnpos;
   input        f_pic_ex4_cmp_sgnneg;
   //------------------
   output [1:6] ex4_g128;		// to each byte section
   output [1:6] ex4_g128_b;		// to each byte section
   output [1:6] ex4_t128;		// to each byte section
   output [1:6] ex4_t128_b;		// to each byte section
   //------------------
   output       ex4_flip_inc_p0;
   output       ex4_flip_inc_p1;
   output       ex4_inc_sel_p0;
   output       ex4_inc_sel_p1;
   output [0:6] ex4_eac_sel_p0n;
   output [0:6] ex4_eac_sel_p0;
   output [0:6] ex4_eac_sel_p1;

   output       ex4_sign_carry;
   output       ex4_flag_nan_cp1;
   output       ex4_flag_gt_cp1;
   output       ex4_flag_lt_cp1;
   output       ex4_flag_eq_cp1;
   output       ex4_flag_nan;
   output       ex4_flag_gt;
   output       ex4_flag_lt;
   output       ex4_flag_eq;

   parameter    tiup = 1'b1;
   parameter    tidn = 1'b0;

   wire         cp0_g32_01_b;
   wire         cp0_g32_23_b;
   wire         cp0_g32_45_b;
   wire         cp0_g32_66_b;
   wire         cp0_t32_01_b;
   wire         cp0_t32_23_b;
   wire         cp0_t32_45_b;
   wire         cp0_t32_66_b;
   wire         cp0_g64_03;
   wire         cp0_g64_46;
   wire         cp0_t64_03;
   wire         cp0_t64_46;
   wire         cp0_g128_06_b;
   wire         cp0_t128_06_b;
   wire         cp0_all1_b;
   wire         cp0_all1_p;
   wire         cp0_co_p0;
   wire         cp0_co_p1;
   wire         cp0_flip_inc_p1_b;
   wire         ex4_inc_sel_p0_b;
   wire         ex4_sign_carry_b;
   wire         ex4_my_gt_b;
   wire         ex4_my_lt;
   wire         ex4_my_eq_b;
   wire         ex4_my_gt;
   wire         ex4_my_eq;
   wire         ex4_gt_pos_b;
   wire         ex4_gt_neg_b;
   wire         ex4_lt_pos_b;
   wire         ex4_lt_neg_b;
   wire         ex4_eq_eq_b;
   wire         ex4_is_gt_b;
   wire         ex4_is_lt_b;
   wire         ex4_is_eq_b;
   wire         ex4_sgn_eq;

   wire         cp7_g32_00_b;
   wire         cp7_g32_12_b;
   wire         cp7_g32_34_b;
   wire         cp7_g32_56_b;
   wire         cp7_t32_00_b;
   wire         cp7_t32_12_b;
   wire         cp7_t32_34_b;
   wire         cp7_g64_02;
   wire         cp7_g64_36;
   wire         cp7_t64_02;
   wire         cp7_g128_06_b;
   wire         cp7_all1_b;
   wire         cp7_all1_p;
   wire         cp7_co_p0;
   wire         cp7_sel_p0n_x_b;
   wire         cp7_sel_p0n_y_b;
   wire         cp7_sel_p0_b;
   wire         cp7_sel_p1_b;
   wire         cp7_sub_sticky;
   wire         cp7_sub_stickyn;
   wire         cp7_add_frcp1_b;
   wire         cp7_add_frcp0_b;

   wire         cp6_g32_00_b;
   wire         cp6_g32_12_b;
   wire         cp6_g32_34_b;
   wire         cp6_g32_56_b;
   wire         cp6_t32_00_b;
   wire         cp6_t32_12_b;
   wire         cp6_t32_34_b;
   wire         cp6_g64_02;
   wire         cp6_g64_36;
   wire         cp6_t64_02;
   wire         cp6_g128_06_b;
   wire         cp6_all1_b;
   wire         cp6_all1_p;
   wire         cp6_co_p0;
   wire         cp6_sel_p0n_x_b;
   wire         cp6_sel_p0n_y_b;
   wire         cp6_sel_p0_b;
   wire         cp6_sel_p1_b;
   wire         cp6_sub_sticky;
   wire         cp6_sub_stickyn;
   wire         cp6_add_frcp1_b;
   wire         cp6_add_frcp0_b;

   wire         cp5_g32_00_b;
   wire         cp5_g32_12_b;
   wire         cp5_g32_34_b;
   wire         cp5_g32_56_b;
   wire         cp5_t32_00_b;
   wire         cp5_t32_12_b;
   wire         cp5_t32_34_b;
   wire         cp5_t32_56_b;
   wire         cp5_g64_02;
   wire         cp5_g64_36;
   wire         cp5_t64_02;
   wire         cp5_g128_06_b;
   wire         cp5_all1_b;
   wire         cp5_all1_p;
   wire         cp5_co_p0;
   wire         cp5_sel_p0n_x_b;
   wire         cp5_sel_p0n_y_b;
   wire         cp5_sel_p0_b;
   wire         cp5_sel_p1_b;
   wire         cp5_sub_sticky;
   wire         cp5_sub_stickyn;
   wire         cp5_add_frcp1_b;
   wire         cp5_add_frcp0_b;

   wire         cp4_g32_01_b;
   wire         cp4_g32_23_b;
   wire         cp4_g32_45_b;
   wire         cp4_g32_66_b;
   wire         cp4_t32_01_b;
   wire         cp4_t32_23_b;
   wire         cp4_t32_45_b;
   wire         cp4_t32_66_b;
   wire         cp4_g64_03;
   wire         cp4_g64_46;
   wire         cp4_t64_03;
   wire         cp4_t64_46;
   wire         cp4_g128_06_b;
   wire         cp4_all1_b;
   wire         cp4_all1_p;
   wire         cp4_co_p0;
   wire         cp4_sel_p0n_x_b;
   wire         cp4_sel_p0n_y_b;
   wire         cp4_sel_p0_b;
   wire         cp4_sel_p1_b;
   wire         cp4_sub_sticky;
   wire         cp4_sub_stickyn;
   wire         cp4_add_frcp1_b;
   wire         cp4_add_frcp0_b;

   wire         cp3_g32_00_b;
   wire         cp3_g32_12_b;
   wire         cp3_g32_34_b;
   wire         cp3_g32_56_b;
   wire         cp3_t32_00_b;
   wire         cp3_t32_12_b;
   wire         cp3_t32_34_b;
   wire         cp3_t32_56_b;
   wire         cp3_g64_02;
   wire         cp3_g64_36;
   wire         cp3_t64_02;
   wire         cp3_t64_36;
   wire         cp3_g128_06_b;
   wire         cp3_all1_b;
   wire         cp3_all1_p;
   wire         cp3_co_p0;
   wire         cp3_sel_p0n_x_b;
   wire         cp3_sel_p0n_y_b;
   wire         cp3_sel_p0_b;
   wire         cp3_sel_p1_b;
   wire         cp3_sub_sticky;
   wire         cp3_sub_stickyn;
   wire         cp3_add_frcp1_b;
   wire         cp3_add_frcp0_b;

   wire         cp2_g32_01_b;
   wire         cp2_g32_23_b;
   wire         cp2_g32_45_b;
   wire         cp2_g32_66_b;
   wire         cp2_t32_01_b;
   wire         cp2_t32_23_b;
   wire         cp2_t32_45_b;
   wire         cp2_t32_66_b;
   wire         cp2_g64_03;
   wire         cp2_g64_46;
   wire         cp2_t64_03;
   wire         cp2_t64_46;
   wire         cp2_g128_06_b;
   wire         cp2_all1_b;
   wire         cp2_all1_p;
   wire         cp2_co_p0;
   wire         cp2_sel_p0n_x_b;
   wire         cp2_sel_p0n_y_b;
   wire         cp2_sel_p0_b;
   wire         cp2_sel_p1_b;
   wire         cp2_sub_sticky;
   wire         cp2_sub_stickyn;
   wire         cp2_add_frcp1_b;
   wire         cp2_add_frcp0_b;

   wire         cp1_g32_01_b;
   wire         cp1_g32_23_b;
   wire         cp1_g32_45_b;
   wire         cp1_g32_66_b;
   wire         cp1_t32_01_b;
   wire         cp1_t32_23_b;
   wire         cp1_t32_45_b;
   wire         cp1_t32_66_b;
   wire         cp1_g64_03;
   wire         cp1_g64_46;
   wire         cp1_t64_03;
   wire         cp1_t64_46;
   wire         cp1_g128_06_b;
   wire         cp1_all1_b;
   wire         cp1_all1_p;
   wire         cp1_co_p0;
   wire         cp1_sel_p0n_x_b;
   wire         cp1_sel_p0n_y_b;
   wire         cp1_sel_p0_b;
   wire         cp1_sel_p1_b;
   wire         cp1_sub_sticky;
   wire         cp1_sub_stickyn;
   wire         cp1_add_frcp1_b;
   wire         cp1_add_frcp0_b;

   wire         cp1_g32_11_b;		//EXTRA
   wire         cp1_t32_11_b;
   wire         cp1_g64_13;
   wire         cp1_t64_13;
   wire         cp1_g128_16_b;
   wire         cp1_t128_16_b;
   wire         cp2_g64_23;
   wire         cp2_t64_23;
   wire         cp2_g128_26_b;
   wire         cp2_t128_26_b;
   wire         cp3_g128_36_b;
   wire         cp3_t128_36_b;
   wire         cp4_g128_46_b;
   wire         cp4_t128_46_b;
   wire         cp5_g64_56;
   wire         cp5_t64_56;
   wire         cp5_g128_56_b;
   wire         cp5_t128_56_b;
   wire         cp6_g32_66_b;
   wire         cp6_t32_66_b;

   wire         cp1_g128_16;		//DRIVER
   wire         cp1_t128_16;
   wire         cp2_g128_26;
   wire         cp2_t128_26;
   wire         cp3_g128_36;
   wire         cp3_t128_36;
   wire         cp4_g128_46;
   wire         cp4_t128_46;
   wire         cp5_g128_56;
   wire         cp5_t128_56;
   wire         cp6_g128_66;
   wire         cp6_t128_66;


   //=#########################################
   //= global carry chain <PARALLEL VERSIONS>
   //=#########################################
   // try to put all long wire from BYT to global
   // parallel copies should allow for smaller aoi/oai blocks

   //=#########################################
   //= CMP COPY
   //=#########################################

   //      --compare stuff----
   //        -- c0 : gt
   //        -- c1 : ge
   //
   //      ex4_my_eq <=    (ex4_add_co_p1 and ex4_inc_all1 ) and not ex4_add_co_p0; --  ge * !gt
   //      ex4_my_gt <=    (ex4_add_co_p0 and ex4_inc_all1 )                          ; --        gt
   //      ex4_my_lt <= not(ex4_add_co_p1 and ex4_inc_all1 )                          ; -- !ge
   //
   //      ex4_flag_nan  <= f_pic_ex4_is_nan;
   //      ex4_flag_gt   <= f_pic_ex4_is_gt  or (f_pic_ex4_cmp_sgnpos and ex4_my_gt) or (f_pic_ex4_cmp_sgnneg and ex4_my_lt) ;
   //      ex4_flag_lt   <= f_pic_ex4_is_lt  or (f_pic_ex4_cmp_sgnpos and ex4_my_lt) or (f_pic_ex4_cmp_sgnneg and ex4_my_gt) ;
   //      ex4_flag_eq   <= f_pic_ex4_is_eq  or (f_pic_ex4_cmp_sgnpos and ex4_my_eq) or (f_pic_ex4_cmp_sgnneg and ex4_my_eq) ;

   assign cp0_g32_01_b = (~(ex4_g16[0] | (ex4_t16[0] & ex4_g16[1])));		//cw_aoi21
   assign cp0_g32_23_b = (~(ex4_g16[2] | (ex4_t16[2] & ex4_g16[3])));		//cw_aoi21
   assign cp0_g32_45_b = (~(ex4_g16[4] | (ex4_t16[4] & ex4_g16[5])));		//cw_aoi21
   assign cp0_g32_66_b = (~(ex4_g16[6]));		//cw_invert --done

   assign cp0_t32_01_b = (~(ex4_t16[0] & ex4_t16[1]));		//cw_nand2
   assign cp0_t32_23_b = (~(ex4_t16[2] & ex4_t16[3]));		//cw_nand2
   assign cp0_t32_45_b = (~(ex4_t16[4] & ex4_t16[5]));		//cw_nand2
   assign cp0_t32_66_b = (~(ex4_t16[6]));		//cw_invert

   assign cp0_g64_03 = (~(cp0_g32_01_b & (cp0_t32_01_b | cp0_g32_23_b)));		//cw_oai21
   assign cp0_g64_46 = (~(cp0_g32_45_b & (cp0_t32_45_b | cp0_g32_66_b)));		//cw_oai21

   assign cp0_t64_03 = (~(cp0_t32_01_b | cp0_t32_23_b));		//cw_nor2
   assign cp0_t64_46 = (~(cp0_g32_45_b & (cp0_t32_45_b | cp0_t32_66_b)));		//cw_oai21

   assign cp0_g128_06_b = (~(cp0_g64_03 | (cp0_t64_03 & cp0_g64_46)));		//cw_aoi21
   assign cp0_t128_06_b = (~(cp0_g64_03 | (cp0_t64_03 & cp0_t64_46)));		//cw_aoi21

   assign cp0_all1_b = (~ex4_inc_all1);		//cw_invert
   assign cp0_all1_p = (~cp0_all1_b);		//cw_invert
   assign cp0_co_p0 = (~(cp0_g128_06_b));		//cw_invert
   assign cp0_co_p1 = (~(cp0_t128_06_b));		//cw_invert

   //-------------- incr eac selects --------------------

   assign ex4_flip_inc_p0 = ex4_effsub;		//NOT MAPPED --output--
   assign cp0_flip_inc_p1_b = (~(ex4_effsub & cp0_all1_b));		//cw_nand2
   assign ex4_flip_inc_p1 = (~(cp0_flip_inc_p1_b));		//cw_invert --output--

   assign ex4_inc_sel_p1 = (~cp0_g128_06_b);		//cw_invert --OUTPUT--
   assign ex4_inc_sel_p0_b = (~cp0_g128_06_b);		//cw_invert
   assign ex4_inc_sel_p0 = (~ex4_inc_sel_p0_b);		//cw_invert --OUTPUT--

   //-------------- sign selects --------------------

   assign ex4_sign_carry_b = (~(ex4_effsub & cp0_all1_p & cp0_co_p0));		//cw_nand3
   assign ex4_sign_carry = (~(ex4_sign_carry_b));		//cw_invert --OUTPUT--

   //--------------- compares ---------------------------

   assign ex4_my_gt_b = (~(cp0_co_p0 & cp0_all1_p));		//cw_nand2
   assign ex4_my_lt = (~(cp0_co_p1 & cp0_all1_p));		//cw_nand2
   assign ex4_my_eq_b = (~(cp0_co_p1 & cp0_all1_p & cp0_g128_06_b));		//cw_nand3

   assign ex4_my_gt = (~ex4_my_gt_b);		//cw_invert
   assign ex4_my_eq = (~ex4_my_eq_b);		//cw_invert

   assign ex4_gt_pos_b = (~(ex4_my_gt & f_pic_ex4_cmp_sgnpos));		//cw_nand2
   assign ex4_gt_neg_b = (~(ex4_my_lt & f_pic_ex4_cmp_sgnneg));		//cw_nand2
   assign ex4_lt_pos_b = (~(ex4_my_lt & f_pic_ex4_cmp_sgnpos));		//cw_nand2
   assign ex4_lt_neg_b = (~(ex4_my_gt & f_pic_ex4_cmp_sgnneg));		//cw_nand2
   assign ex4_eq_eq_b = (~(ex4_my_eq & ex4_sgn_eq));		//cw_nand3

   assign ex4_flag_gt = (~(ex4_gt_pos_b & ex4_gt_neg_b & ex4_is_gt_b));		//cw_nand3 --output--
   assign ex4_flag_gt_cp1 = (~(ex4_gt_pos_b & ex4_gt_neg_b & ex4_is_gt_b));		//cw_nand3 --output--
   assign ex4_flag_lt = (~(ex4_lt_pos_b & ex4_lt_neg_b & ex4_is_lt_b));		//cw_nand3 --output--
   assign ex4_flag_lt_cp1 = (~(ex4_lt_pos_b & ex4_lt_neg_b & ex4_is_lt_b));		//cw_nand3 --output--
   assign ex4_flag_eq = (~(ex4_eq_eq_b & ex4_is_eq_b));		//cw_nand2 --output--
   assign ex4_flag_eq_cp1 = (~(ex4_eq_eq_b & ex4_is_eq_b));		//cw_nand2 --output--

   assign ex4_flag_nan = f_pic_ex4_is_nan;		//NOT MAPPED --output--
   assign ex4_flag_nan_cp1 = f_pic_ex4_is_nan;		//NOT MAPPED --output--

   assign ex4_is_gt_b = (~(f_pic_ex4_is_gt));		//NOT MAPPED
   assign ex4_is_lt_b = (~(f_pic_ex4_is_lt));		//NOT MAPPED
   assign ex4_is_eq_b = (~(f_pic_ex4_is_eq));		//NOT MAPPED
   assign ex4_sgn_eq = f_pic_ex4_cmp_sgnpos | f_pic_ex4_cmp_sgnneg;		//NOT MAPPED

   //=#########################################
   //= BYT_0 MSB COPY
   //=#########################################

   assign cp1_g32_11_b = (~(ex4_g16[1]));		//cw_aoi21 --EXTRA
   assign cp1_g32_01_b = (~(ex4_g16[0] | (ex4_t16[0] & ex4_g16[1])));		//cw_aoi21
   assign cp1_g32_23_b = (~(ex4_g16[2] | (ex4_t16[2] & ex4_g16[3])));		//cw_aoi21
   assign cp1_g32_45_b = (~(ex4_g16[4] | (ex4_t16[4] & ex4_g16[5])));		//cw_aoi21
   assign cp1_g32_66_b = (~(ex4_g16[6]));		//cw_invert --done

   assign cp1_t32_11_b = (~(ex4_t16[1]));		//cw_invert --EXTRA
   assign cp1_t32_01_b = (~(ex4_t16[0] & ex4_t16[1]));		//cw_nand2
   assign cp1_t32_23_b = (~(ex4_t16[2] & ex4_t16[3]));		//cw_nand2
   assign cp1_t32_45_b = (~(ex4_t16[4] & ex4_t16[5]));		//cw_nand2
   assign cp1_t32_66_b = (~(ex4_t16[6]));		//cw_invert

   assign cp1_g64_03 = (~(cp1_g32_01_b & (cp1_t32_01_b | cp1_g32_23_b)));		//cw_oai21
   assign cp1_g64_13 = (~(cp1_g32_11_b & (cp1_t32_11_b | cp1_g32_23_b)));		//cw_oai21 --EXTRA
   assign cp1_g64_46 = (~(cp1_g32_45_b & (cp1_t32_45_b | cp1_g32_66_b)));		//cw_oai21

   assign cp1_t64_03 = (~(cp1_t32_01_b | cp1_t32_23_b));		//cw_nor2
   assign cp1_t64_13 = (~(cp1_t32_11_b | cp1_t32_23_b));		//cw_nor2 --EXTRA
   assign cp1_t64_46 = (~(cp1_g32_45_b & (cp1_t32_45_b | cp1_t32_66_b)));		//cw_oai21

   assign cp1_g128_06_b = (~(cp1_g64_03 | (cp1_t64_03 & cp1_g64_46)));		//cw_aoi21
   assign cp1_g128_16_b = (~(cp1_g64_13 | (cp1_t64_13 & cp1_g64_46)));		//cw_aoi21 --EXTRA
   assign cp1_t128_16_b = (~(cp1_g64_13 | (cp1_t64_13 & cp1_t64_46)));		//cw_aoi21 --EXTRA

   assign ex4_g128[1] = (~(cp1_g128_16_b));		//cw_invert --OUTPUT--
   assign cp1_g128_16 = (~(cp1_g128_16_b));		//cw_invert
   assign ex4_g128_b[1] = (~(cp1_g128_16));		//cw_invert --OUTPUT--
   assign ex4_t128[1] = (~(cp1_t128_16_b));		//cw_invert --OUTPUT--
   assign cp1_t128_16 = (~(cp1_t128_16_b));		//cw_invert
   assign ex4_t128_b[1] = (~(cp1_t128_16));		//cw_invert --OUTPUT--

   assign cp1_all1_b = (~ex4_inc_all1);		//cw_invert
   assign cp1_all1_p = (~cp1_all1_b);		//cw_invert
   assign cp1_co_p0 = (~(cp1_g128_06_b));		//cw_invert

   assign cp1_sel_p0n_x_b = (~(cp1_all1_b & ex4_effsub_npz));		//cw_nand2
   assign cp1_sel_p0n_y_b = (~(cp1_g128_06_b & ex4_effsub_npz));		//cw_nand2
   assign cp1_sel_p0_b = (~(cp1_co_p0 & cp1_all1_p & cp1_sub_sticky));		//cw_nand3
   assign cp1_sel_p1_b = (~(cp1_co_p0 & cp1_all1_p & cp1_sub_stickyn));		//cw_nand3

   assign ex4_eac_sel_p0n[0] = (~(cp1_sel_p0n_x_b & cp1_sel_p0n_y_b));		//cw_nand2 --OUTPUT--
   assign ex4_eac_sel_p0[0] = (~(cp1_sel_p0_b & cp1_add_frcp0_b));		//cw_nand2 --OUTPUT--
   assign ex4_eac_sel_p1[0] = (~(cp1_sel_p1_b & cp1_add_frcp1_b));		//cw_nand2 --OUTPUT--

   assign cp1_sub_sticky = ex4_effsub_npz & f_alg_ex4_sticky;		//NOT MAPPED
   assign cp1_sub_stickyn = ex4_effsub_npz & (~f_alg_ex4_sticky);		//NOT MAPPED
   assign cp1_add_frcp1_b = (~(ex4_effadd_npz & f_alg_ex4_frc_sel_p1));		//NOT MAPPED
   assign cp1_add_frcp0_b = (~(ex4_effadd_npz & (~f_alg_ex4_frc_sel_p1)));		//NOT MAPPED

   //=#########################################
   //= BYT_1 MSB COPY
   //=#########################################

   assign cp2_g32_01_b = (~(ex4_g16[0] | (ex4_t16[0] & ex4_g16[1])));		//cw_aoi21
   assign cp2_g32_23_b = (~(ex4_g16[2] | (ex4_t16[2] & ex4_g16[3])));		//cw_aoi21
   assign cp2_g32_45_b = (~(ex4_g16[4] | (ex4_t16[4] & ex4_g16[5])));		//cw_aoi21
   assign cp2_g32_66_b = (~(ex4_g16[6]));		//cw_invert --done

   assign cp2_t32_01_b = (~(ex4_t16[0] & ex4_t16[1]));		//cw_nand2
   assign cp2_t32_23_b = (~(ex4_t16[2] & ex4_t16[3]));		//cw_nand2
   assign cp2_t32_45_b = (~(ex4_t16[4] & ex4_t16[5]));		//cw_nand2
   assign cp2_t32_66_b = (~(ex4_t16[6]));		//cw_invert

   assign cp2_g64_23 = (~(cp2_g32_23_b));		//cw_invert --EXTRA
   assign cp2_g64_03 = (~(cp2_g32_01_b & (cp2_t32_01_b | cp2_g32_23_b)));		//cw_oai21
   assign cp2_g64_46 = (~(cp2_g32_45_b & (cp2_t32_45_b | cp2_g32_66_b)));		//cw_oai21

   assign cp2_t64_23 = (~(cp2_t32_23_b));		//cw_invert --EXTRA
   assign cp2_t64_03 = (~(cp2_t32_01_b | cp2_t32_23_b));		//cw_nor2
   assign cp2_t64_46 = (~(cp2_g32_45_b & (cp2_t32_45_b | cp2_t32_66_b)));		//cw_oai21

   assign cp2_g128_06_b = (~(cp2_g64_03 | (cp2_t64_03 & cp2_g64_46)));		//cw_aoi21
   assign cp2_g128_26_b = (~(cp2_g64_23 | (cp2_t64_23 & cp2_g64_46)));		//cw_aoi21 --EXTRA
   assign cp2_t128_26_b = (~(cp2_g64_23 | (cp2_t64_23 & cp2_t64_46)));		//cw_aoi21 --EXTRA

   assign ex4_g128[2] = (~(cp2_g128_26_b));		//cw_invert --OUTPUT--
   assign cp2_g128_26 = (~(cp2_g128_26_b));		//cw_invert
   assign ex4_g128_b[2] = (~(cp2_g128_26));		//cw_invert --OUTPUT--
   assign ex4_t128[2] = (~(cp2_t128_26_b));		//cw_invert --OUTPUT--
   assign cp2_t128_26 = (~(cp2_t128_26_b));		//cw_invert
   assign ex4_t128_b[2] = (~(cp2_t128_26));		//cw_invert --OUTPUT--

   assign cp2_all1_b = (~ex4_inc_all1);		//cw_invert
   assign cp2_all1_p = (~cp2_all1_b);		//cw_invert
   assign cp2_co_p0 = (~(cp2_g128_06_b));		//cw_invert

   assign cp2_sel_p0n_x_b = (~(cp2_all1_b & ex4_effsub_npz));		//cw_nand2
   assign cp2_sel_p0n_y_b = (~(cp2_g128_06_b & ex4_effsub_npz));		//cw_nand2
   assign cp2_sel_p0_b = (~(cp2_co_p0 & cp2_all1_p & cp2_sub_sticky));		//cw_nand3
   assign cp2_sel_p1_b = (~(cp2_co_p0 & cp2_all1_p & cp2_sub_stickyn));		//cw_nand3

   assign ex4_eac_sel_p0n[1] = (~(cp2_sel_p0n_x_b & cp2_sel_p0n_y_b));		//cw_nand2 --OUTPUT--
   assign ex4_eac_sel_p0[1] = (~(cp2_sel_p0_b & cp2_add_frcp0_b));		//cw_nand2 --OUTPUT--
   assign ex4_eac_sel_p1[1] = (~(cp2_sel_p1_b & cp2_add_frcp1_b));		//cw_nand2 --OUTPUT--

   assign cp2_sub_sticky = ex4_effsub_npz & f_alg_ex4_sticky;		//NOT MAPPED
   assign cp2_sub_stickyn = ex4_effsub_npz & (~f_alg_ex4_sticky);		//NOT MAPPED
   assign cp2_add_frcp1_b = (~(ex4_effadd_npz & f_alg_ex4_frc_sel_p1));		//NOT MAPPED
   assign cp2_add_frcp0_b = (~(ex4_effadd_npz & (~f_alg_ex4_frc_sel_p1)));		//NOT MAPPED

   //=#########################################
   //= BYT_2 MSB COPY
   //=#########################################

   assign cp3_g32_00_b = (~(ex4_g16[0]));		//cw_invert
   assign cp3_g32_12_b = (~(ex4_g16[1] | (ex4_t16[1] & ex4_g16[2])));		//cw_aoi21
   assign cp3_g32_34_b = (~(ex4_g16[3] | (ex4_t16[3] & ex4_g16[4])));		//cw_aoi21
   assign cp3_g32_56_b = (~(ex4_g16[5] | (ex4_t16[5] & ex4_g16[6])));		//cw_aoi21

   assign cp3_t32_00_b = (~(ex4_t16[0]));		//cw_invert
   assign cp3_t32_12_b = (~(ex4_t16[1] & ex4_t16[2]));		//cw_nand2
   assign cp3_t32_34_b = (~(ex4_t16[3] & ex4_t16[4]));		//cw_nand2
   assign cp3_t32_56_b = (~(ex4_g16[5] | (ex4_t16[5] & ex4_t16[6])));		//cw_aoi21

   assign cp3_g64_02 = (~(cp3_g32_00_b & (cp3_t32_00_b | cp3_g32_12_b)));		//cw_oai21
   assign cp3_g64_36 = (~(cp3_g32_34_b & (cp3_t32_34_b | cp3_g32_56_b)));		//cw_oai21

   assign cp3_t64_02 = (~(cp3_t32_00_b | cp3_t32_12_b));		//cw_nor2
   assign cp3_t64_36 = (~(cp3_g32_34_b & (cp3_t32_34_b | cp3_t32_56_b)));		//cw_oai21

   assign cp3_g128_06_b = (~(cp3_g64_02 | (cp3_t64_02 & cp3_g64_36)));		//cw_aoi21
   assign cp3_g128_36_b = (~(cp3_g64_36));		//cw_invert --EXTRA
   assign cp3_t128_36_b = (~(cp3_t64_36));		//cw_invert --EXTRA

   assign ex4_g128[3] = (~(cp3_g128_36_b));		//cw_invert --OUTPUT--
   assign cp3_g128_36 = (~(cp3_g128_36_b));		//cw_invert
   assign ex4_g128_b[3] = (~(cp3_g128_36));		//cw_invert --OUTPUT--
   assign ex4_t128[3] = (~(cp3_t128_36_b));		//cw_invert --OUTPUT--
   assign cp3_t128_36 = (~(cp3_t128_36_b));		//cw_invert
   assign ex4_t128_b[3] = (~(cp3_t128_36));		//cw_invert --OUTPUT--

   assign cp3_all1_b = (~ex4_inc_all1);		//cw_invert
   assign cp3_all1_p = (~cp3_all1_b);		//cw_invert
   assign cp3_co_p0 = (~(cp3_g128_06_b));		//cw_invert

   assign cp3_sel_p0n_x_b = (~(cp3_all1_b & ex4_effsub_npz));		//cw_nand2
   assign cp3_sel_p0n_y_b = (~(cp3_g128_06_b & ex4_effsub_npz));		//cw_nand2
   assign cp3_sel_p0_b = (~(cp3_co_p0 & cp3_all1_p & cp3_sub_sticky));		//cw_nand3
   assign cp3_sel_p1_b = (~(cp3_co_p0 & cp3_all1_p & cp3_sub_stickyn));		//cw_nand3

   assign ex4_eac_sel_p0n[2] = (~(cp3_sel_p0n_x_b & cp3_sel_p0n_y_b));		//cw_nand2 --OUTPUT--
   assign ex4_eac_sel_p0[2] = (~(cp3_sel_p0_b & cp3_add_frcp0_b));		//cw_nand2 --OUTPUT--
   assign ex4_eac_sel_p1[2] = (~(cp3_sel_p1_b & cp3_add_frcp1_b));		//cw_nand2 --OUTPUT--

   assign cp3_sub_sticky = ex4_effsub_npz & f_alg_ex4_sticky;		//NOT MAPPED
   assign cp3_sub_stickyn = ex4_effsub_npz & (~f_alg_ex4_sticky);		//NOT MAPPED
   assign cp3_add_frcp1_b = (~(ex4_effadd_npz & f_alg_ex4_frc_sel_p1));		//NOT MAPPED
   assign cp3_add_frcp0_b = (~(ex4_effadd_npz & (~f_alg_ex4_frc_sel_p1)));		//NOT MAPPED

   //=#########################################
   //= BYT_3 MSB COPY
   //=#########################################

   assign cp4_g32_01_b = (~(ex4_g16[0] | (ex4_t16[0] & ex4_g16[1])));		//cw_aoi21
   assign cp4_g32_23_b = (~(ex4_g16[2] | (ex4_t16[2] & ex4_g16[3])));		//cw_aoi21
   assign cp4_g32_45_b = (~(ex4_g16[4] | (ex4_t16[4] & ex4_g16[5])));		//cw_aoi21
   assign cp4_g32_66_b = (~(ex4_g16[6]));		//cw_invert --done

   assign cp4_t32_01_b = (~(ex4_t16[0] & ex4_t16[1]));		//cw_nand2
   assign cp4_t32_23_b = (~(ex4_t16[2] & ex4_t16[3]));		//cw_nand2
   assign cp4_t32_45_b = (~(ex4_t16[4] & ex4_t16[5]));		//cw_nand2
   assign cp4_t32_66_b = (~(ex4_t16[6]));		//cw_invert

   assign cp4_g64_03 = (~(cp4_g32_01_b & (cp4_t32_01_b | cp4_g32_23_b)));		//cw_oai21
   assign cp4_g64_46 = (~(cp4_g32_45_b & (cp4_t32_45_b | cp4_g32_66_b)));		//cw_oai21

   assign cp4_t64_03 = (~(cp4_t32_01_b | cp4_t32_23_b));		//cw_nor2
   assign cp4_t64_46 = (~(cp4_g32_45_b & (cp4_t32_45_b | cp4_t32_66_b)));		//cw_oai21

   assign cp4_g128_06_b = (~(cp4_g64_03 | (cp4_t64_03 & cp4_g64_46)));		//cw_aoi21
   assign cp4_g128_46_b = (~(cp4_g64_46));		//cw_invert --EXTRA
   assign cp4_t128_46_b = (~(cp4_t64_46));		//cw_invert --EXTRA

   assign ex4_g128[4] = (~(cp4_g128_46_b));		//cw_invert --OUTPUT--
   assign cp4_g128_46 = (~(cp4_g128_46_b));		//cw_invert
   assign ex4_g128_b[4] = (~(cp4_g128_46));		//cw_invert --OUTPUT--
   assign ex4_t128[4] = (~(cp4_t128_46_b));		//cw_invert --OUTPUT--
   assign cp4_t128_46 = (~(cp4_t128_46_b));		//cw_invert
   assign ex4_t128_b[4] = (~(cp4_t128_46));		//cw_invert --OUTPUT--

   assign cp4_all1_b = (~ex4_inc_all1);		//cw_invert
   assign cp4_all1_p = (~cp4_all1_b);		//cw_invert
   assign cp4_co_p0 = (~(cp4_g128_06_b));		//cw_invert

   assign cp4_sel_p0n_x_b = (~(cp4_all1_b & ex4_effsub_npz));		//cw_nand2
   assign cp4_sel_p0n_y_b = (~(cp4_g128_06_b & ex4_effsub_npz));		//cw_nand2
   assign cp4_sel_p0_b = (~(cp4_co_p0 & cp4_all1_p & cp4_sub_sticky));		//cw_nand3
   assign cp4_sel_p1_b = (~(cp4_co_p0 & cp4_all1_p & cp4_sub_stickyn));		//cw_nand3

   assign ex4_eac_sel_p0n[3] = (~(cp4_sel_p0n_x_b & cp4_sel_p0n_y_b));		//cw_nand2 --OUTPUT--
   assign ex4_eac_sel_p0[3] = (~(cp4_sel_p0_b & cp4_add_frcp0_b));		//cw_nand2 --OUTPUT--
   assign ex4_eac_sel_p1[3] = (~(cp4_sel_p1_b & cp4_add_frcp1_b));		//cw_nand2 --OUTPUT--

   assign cp4_sub_sticky = ex4_effsub_npz & f_alg_ex4_sticky;		//NOT MAPPED
   assign cp4_sub_stickyn = ex4_effsub_npz & (~f_alg_ex4_sticky);		//NOT MAPPED
   assign cp4_add_frcp1_b = (~(ex4_effadd_npz & f_alg_ex4_frc_sel_p1));		//NOT MAPPED
   assign cp4_add_frcp0_b = (~(ex4_effadd_npz & (~f_alg_ex4_frc_sel_p1)));		//NOT MAPPED

   //=#########################################
   //= BYT_4
   //=#########################################

   assign cp5_g32_00_b = (~(ex4_g16[0]));		//cw_invert
   assign cp5_g32_12_b = (~(ex4_g16[1] | (ex4_t16[1] & ex4_g16[2])));		//cw_aoi21
   assign cp5_g32_34_b = (~(ex4_g16[3] | (ex4_t16[3] & ex4_g16[4])));		//cw_aoi21
   assign cp5_g32_56_b = (~(ex4_g16[5] | (ex4_t16[5] & ex4_g16[6])));		//cw_aoi21

   assign cp5_t32_00_b = (~(ex4_t16[0]));		//cw_invert
   assign cp5_t32_12_b = (~(ex4_t16[1] & ex4_t16[2]));		//cw_nand2
   assign cp5_t32_34_b = (~(ex4_t16[3] & ex4_t16[4]));		//cw_nand2
   assign cp5_t32_56_b = (~(ex4_g16[5] | (ex4_t16[5] & ex4_t16[6])));		//cw_aoi21

   assign cp5_g64_02 = (~(cp5_g32_00_b & (cp5_t32_00_b | cp5_g32_12_b)));		//cw_oai21
   assign cp5_g64_36 = (~(cp5_g32_34_b & (cp5_t32_34_b | cp5_g32_56_b)));		//cw_oai21
   assign cp5_g64_56 = (~(cp5_g32_56_b));		//cw_invert --EXTRA

   assign cp5_t64_02 = (~(cp5_t32_00_b | cp5_t32_12_b));		//cw_nor2
   assign cp5_t64_56 = (~(cp5_t32_56_b));		//cw_invert --EXTRA

   assign cp5_g128_06_b = (~(cp5_g64_02 | (cp5_t64_02 & cp5_g64_36)));		//cw_aoi21
   assign cp5_g128_56_b = (~(cp5_g64_56));		//cw_invert --EXTRA
   assign cp5_t128_56_b = (~(cp5_t64_56));		//cw_invert --EXTRA

   assign ex4_g128[5] = (~(cp5_g128_56_b));		//cw_invert --OUTPUT--
   assign cp5_g128_56 = (~(cp5_g128_56_b));		//cw_invert
   assign ex4_g128_b[5] = (~(cp5_g128_56));		//cw_invert --OUTPUT--
   assign ex4_t128[5] = (~(cp5_t128_56_b));		//cw_invert --OUTPUT--
   assign cp5_t128_56 = (~(cp5_t128_56_b));		//cw_invert
   assign ex4_t128_b[5] = (~(cp5_t128_56));		//cw_invert --OUTPUT--

   assign cp5_all1_b = (~ex4_inc_all1);		//cw_invert
   assign cp5_all1_p = (~cp5_all1_b);		//cw_invert
   assign cp5_co_p0 = (~(cp5_g128_06_b));		//cw_invert

   assign cp5_sel_p0n_x_b = (~(cp5_all1_b & ex4_effsub_npz));		//cw_nand2
   assign cp5_sel_p0n_y_b = (~(cp5_g128_06_b & ex4_effsub_npz));		//cw_nand2
   assign cp5_sel_p0_b = (~(cp5_co_p0 & cp5_all1_p & cp5_sub_sticky));		//cw_nand3
   assign cp5_sel_p1_b = (~(cp5_co_p0 & cp5_all1_p & cp5_sub_stickyn));		//cw_nand3

   assign ex4_eac_sel_p0n[4] = (~(cp5_sel_p0n_x_b & cp5_sel_p0n_y_b));		//cw_nand2 --OUTPUT--
   assign ex4_eac_sel_p0[4] = (~(cp5_sel_p0_b & cp5_add_frcp0_b));		//cw_nand2 --OUTPUT--
   assign ex4_eac_sel_p1[4] = (~(cp5_sel_p1_b & cp5_add_frcp1_b));		//cw_nand2 --OUTPUT--

   assign cp5_sub_sticky = ex4_effsub_npz & f_alg_ex4_sticky;		//NOT MAPPED
   assign cp5_sub_stickyn = ex4_effsub_npz & (~f_alg_ex4_sticky);		//NOT MAPPED
   assign cp5_add_frcp1_b = (~(ex4_effadd_npz & f_alg_ex4_frc_sel_p1));		//NOT MAPPED
   assign cp5_add_frcp0_b = (~(ex4_effadd_npz & (~f_alg_ex4_frc_sel_p1)));		//NOT MAPPED

   //=#########################################
   //= BYT_5
   //=#########################################

   assign cp6_g32_00_b = (~(ex4_g16[0]));		//cw_invert
   assign cp6_g32_12_b = (~(ex4_g16[1] | (ex4_t16[1] & ex4_g16[2])));		//cw_aoi21
   assign cp6_g32_34_b = (~(ex4_g16[3] | (ex4_t16[3] & ex4_g16[4])));		//cw_aoi21
   assign cp6_g32_56_b = (~(ex4_g16[5] | (ex4_t16[5] & ex4_g16[6])));		//cw_aoi21
   assign cp6_g32_66_b = (~(ex4_g16[6]));		//cw_invert EXTRA

   assign cp6_t32_00_b = (~(ex4_t16[0]));		//cw_invert
   assign cp6_t32_12_b = (~(ex4_t16[1] & ex4_t16[2]));		//cw_nand2
   assign cp6_t32_34_b = (~(ex4_t16[3] & ex4_t16[4]));		//cw_nand2
   assign cp6_t32_66_b = (~(ex4_t16[6]));		//cw_invert EXTRA

   assign cp6_g64_02 = (~(cp6_g32_00_b & (cp6_t32_00_b | cp6_g32_12_b)));		//cw_oai21
   assign cp6_g64_36 = (~(cp6_g32_34_b & (cp6_t32_34_b | cp6_g32_56_b)));		//cw_oai21

   assign cp6_t64_02 = (~(cp6_t32_00_b | cp6_t32_12_b));		//cw_nor2

   assign cp6_g128_06_b = (~(cp6_g64_02 | (cp6_t64_02 & cp6_g64_36)));		//cw_aoi21

   assign ex4_g128[6] = (~(cp6_g32_66_b));		//cw_invert --OUTPUT--
   assign cp6_g128_66 = (~(cp6_g32_66_b));		//cw_invert
   assign ex4_g128_b[6] = (~(cp6_g128_66));		//cw_invert --OUTPUT--
   assign ex4_t128[6] = (~(cp6_t32_66_b));		//cw_invert --OUTPUT--
   assign cp6_t128_66 = (~(cp6_t32_66_b));		//cw_invert
   assign ex4_t128_b[6] = (~(cp6_t128_66));		//cw_invert --OUTPUT--

   assign cp6_all1_b = (~ex4_inc_all1);		//cw_invert
   assign cp6_all1_p = (~cp6_all1_b);		//cw_invert
   assign cp6_co_p0 = (~(cp6_g128_06_b));		//cw_invert

   assign cp6_sel_p0n_x_b = (~(cp6_all1_b & ex4_effsub_npz));		//cw_nand2
   assign cp6_sel_p0n_y_b = (~(cp6_g128_06_b & ex4_effsub_npz));		//cw_nand2
   assign cp6_sel_p0_b = (~(cp6_co_p0 & cp6_all1_p & cp6_sub_sticky));		//cw_nand3
   assign cp6_sel_p1_b = (~(cp6_co_p0 & cp6_all1_p & cp6_sub_stickyn));		//cw_nand3

   assign ex4_eac_sel_p0n[5] = (~(cp6_sel_p0n_x_b & cp6_sel_p0n_y_b));		//cw_nand2 --OUTPUT--
   assign ex4_eac_sel_p0[5] = (~(cp6_sel_p0_b & cp6_add_frcp0_b));		//cw_nand2 --OUTPUT--
   assign ex4_eac_sel_p1[5] = (~(cp6_sel_p1_b & cp6_add_frcp1_b));		//cw_nand2 --OUTPUT--

   assign cp6_sub_sticky = ex4_effsub_npz & f_alg_ex4_sticky;		//NOT MAPPED
   assign cp6_sub_stickyn = ex4_effsub_npz & (~f_alg_ex4_sticky);		//NOT MAPPED
   assign cp6_add_frcp1_b = (~(ex4_effadd_npz & f_alg_ex4_frc_sel_p1));		//NOT MAPPED
   assign cp6_add_frcp0_b = (~(ex4_effadd_npz & (~f_alg_ex4_frc_sel_p1)));		//NOT MAPPED

   //=#########################################
   //= BYT_6 LSB COPY
   //=#########################################

   assign cp7_g32_00_b = (~(ex4_g16[0]));		//cw_invert
   assign cp7_g32_12_b = (~(ex4_g16[1] | (ex4_t16[1] & ex4_g16[2])));		//cw_aoi21
   assign cp7_g32_34_b = (~(ex4_g16[3] | (ex4_t16[3] & ex4_g16[4])));		//cw_aoi21
   assign cp7_g32_56_b = (~(ex4_g16[5] | (ex4_t16[5] & ex4_g16[6])));		//cw_aoi21

   assign cp7_t32_00_b = (~(ex4_t16[0]));		//cw_invert
   assign cp7_t32_12_b = (~(ex4_t16[1] & ex4_t16[2]));		//cw_nand2
   assign cp7_t32_34_b = (~(ex4_t16[3] & ex4_t16[4]));		//cw_nand2

   assign cp7_g64_02 = (~(cp7_g32_00_b & (cp7_t32_00_b | cp7_g32_12_b)));		//cw_oai21
   assign cp7_g64_36 = (~(cp7_g32_34_b & (cp7_t32_34_b | cp7_g32_56_b)));		//cw_oai21

   assign cp7_t64_02 = (~(cp7_t32_00_b | cp7_t32_12_b));		//cw_nor2

   assign cp7_g128_06_b = (~(cp7_g64_02 | (cp7_t64_02 & cp7_g64_36)));		//cw_aoi21

   assign cp7_all1_b = (~ex4_inc_all1);		//cw_invert
   assign cp7_all1_p = (~cp7_all1_b);		//cw_invert
   assign cp7_co_p0 = (~(cp7_g128_06_b));		//cw_invert

   assign cp7_sel_p0n_x_b = (~(cp7_all1_b & ex4_effsub_npz));		//cw_nand2
   assign cp7_sel_p0n_y_b = (~(cp7_g128_06_b & ex4_effsub_npz));		//cw_nand2
   assign cp7_sel_p0_b = (~(cp7_co_p0 & cp7_all1_p & cp7_sub_sticky));		//cw_nand3
   assign cp7_sel_p1_b = (~(cp7_co_p0 & cp7_all1_p & cp7_sub_stickyn));		//cw_nand3

   assign ex4_eac_sel_p0n[6] = (~(cp7_sel_p0n_x_b & cp7_sel_p0n_y_b));		//cw_nand2 --OUTPUT--
   assign ex4_eac_sel_p0[6] = (~(cp7_sel_p0_b & cp7_add_frcp0_b));		//cw_nand2 --OUTPUT--
   assign ex4_eac_sel_p1[6] = (~(cp7_sel_p1_b & cp7_add_frcp1_b));		//cw_nand2 --OUTPUT--

   assign cp7_sub_sticky = ex4_effsub_npz & f_alg_ex4_sticky;		//NOT MAPPED
   assign cp7_sub_stickyn = ex4_effsub_npz & (~f_alg_ex4_sticky);		//NOT MAPPED
   assign cp7_add_frcp1_b = (~(ex4_effadd_npz & f_alg_ex4_frc_sel_p1));		//NOT MAPPED
   assign cp7_add_frcp0_b = (~(ex4_effadd_npz & (~f_alg_ex4_frc_sel_p1)));		//NOT MAPPED

endmodule
