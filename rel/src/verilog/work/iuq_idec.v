// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns






module iuq_idec(
   vdd,
   gnd,
   nclk,
   pc_iu_sg_2,
   pc_iu_func_sl_thold_2,
   clkoff_b,
   act_dis,
   tc_ac_ccflush_dc,
   d_mode,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   scan_in,
   scan_out,
   xu_iu_epcr_dgtmi,
   xu_iu_msrp_uclep,
   xu_iu_msr_pr,
   xu_iu_msr_gs,
   xu_iu_msr_ucle,
   xu_iu_ccr2_ucode_dis,
   mm_iu_tlbwe_binv,
   spr_dec_mask,
   spr_dec_match,
   cp_iu_iu4_flush,
   uc_ib_iu3_flush_all,
   br_iu_redirect,
   ib_id_iu4_valid,
   ib_id_iu4_ifar,
   ib_id_iu4_bta,
   ib_id_iu4_instr,
   ib_id_iu4_ucode,
   ib_id_iu4_ucode_ext,
   ib_id_iu4_isram,
   ib_id_iu4_fuse_val,
   ib_id_iu4_fuse_data,
   au_iu_iu4_i_dec_b,
   au_iu_iu4_ucode,
   au_iu_iu4_t1_v,
   au_iu_iu4_t1_t,
   au_iu_iu4_t1_a,
   au_iu_iu4_t2_v,
   au_iu_iu4_t2_a,
   au_iu_iu4_t2_t,
   au_iu_iu4_t3_v,
   au_iu_iu4_t3_a,
   au_iu_iu4_t3_t,
   au_iu_iu4_s1_v,
   au_iu_iu4_s1_a,
   au_iu_iu4_s1_t,
   au_iu_iu4_s2_v,
   au_iu_iu4_s2_a,
   au_iu_iu4_s2_t,
   au_iu_iu4_s3_v,
   au_iu_iu4_s3_a,
   au_iu_iu4_s3_t,
   au_iu_iu4_ilat,
   au_iu_iu4_ord,
   au_iu_iu4_cord,
   au_iu_iu4_spec,
   au_iu_iu4_type_fp,
   au_iu_iu4_type_ap,
   au_iu_iu4_type_spv,
   au_iu_iu4_type_st,
   au_iu_iu4_async_block,
   au_iu_iu4_isload,
   au_iu_iu4_isstore,
   au_iu_iu4_rte_lq,
   au_iu_iu4_rte_sq,
   au_iu_iu4_rte_axu0,
   au_iu_iu4_rte_axu1,
   au_iu_iu4_no_ram,
   fdec_frn_iu5_ix_vld,
   fdec_frn_iu5_ix_ucode,
   fdec_frn_iu5_ix_2ucode,
   fdec_frn_iu5_ix_fuse_nop,
   fdec_frn_iu5_ix_rte_lq,
   fdec_frn_iu5_ix_rte_sq,
   fdec_frn_iu5_ix_rte_fx0,
   fdec_frn_iu5_ix_rte_fx1,
   fdec_frn_iu5_ix_rte_axu0,
   fdec_frn_iu5_ix_rte_axu1,
   fdec_frn_iu5_ix_valop,
   fdec_frn_iu5_ix_ord,
   fdec_frn_iu5_ix_cord,
   fdec_frn_iu5_ix_error,
   fdec_frn_iu5_ix_fusion,
   fdec_frn_iu5_ix_spec,
   fdec_frn_iu5_ix_type_fp,
   fdec_frn_iu5_ix_type_ap,
   fdec_frn_iu5_ix_type_spv,
   fdec_frn_iu5_ix_type_st,
   fdec_frn_iu5_ix_async_block,
   fdec_frn_iu5_ix_np1_flush,
   fdec_frn_iu5_ix_core_block,
   fdec_frn_iu5_ix_isram,
   fdec_frn_iu5_ix_isload,
   fdec_frn_iu5_ix_isstore,
   fdec_frn_iu5_ix_instr,
   fdec_frn_iu5_ix_ifar,
   fdec_frn_iu5_ix_bta,
   fdec_frn_iu5_ix_ilat,
   fdec_frn_iu5_ix_t1_v,
   fdec_frn_iu5_ix_t1_t,
   fdec_frn_iu5_ix_t1_a,
   fdec_frn_iu5_ix_t2_v,
   fdec_frn_iu5_ix_t2_a,
   fdec_frn_iu5_ix_t2_t,
   fdec_frn_iu5_ix_t3_v,
   fdec_frn_iu5_ix_t3_a,
   fdec_frn_iu5_ix_t3_t,
   fdec_frn_iu5_ix_s1_v,
   fdec_frn_iu5_ix_s1_a,
   fdec_frn_iu5_ix_s1_t,
   fdec_frn_iu5_ix_s2_v,
   fdec_frn_iu5_ix_s2_a,
   fdec_frn_iu5_ix_s2_t,
   fdec_frn_iu5_ix_s3_v,
   fdec_frn_iu5_ix_s3_a,
   fdec_frn_iu5_ix_s3_t,
   fdec_frn_iu5_ix_br_pred,
   fdec_frn_iu5_ix_bh_update,
   fdec_frn_iu5_ix_bh0_hist,
   fdec_frn_iu5_ix_bh1_hist,
   fdec_frn_iu5_ix_bh2_hist,
   fdec_frn_iu5_ix_gshare,
   fdec_frn_iu5_ix_ls_ptr,
   fdec_frn_iu5_ix_match,
   fdec_frn_iu5_ix_btb_entry,
   fdec_frn_iu5_ix_btb_hist,
   fdec_frn_iu5_ix_bta_val,
   frn_fdec_iu5_stall
);
`include "tri_a2o.vh"
   inout                         vdd;
   inout                         gnd;
   input [0:`NCLK_WIDTH-1]       nclk;
   input                         pc_iu_sg_2;
   input                         pc_iu_func_sl_thold_2;
   input                         clkoff_b;
   input                         act_dis;
   input                         tc_ac_ccflush_dc;
   input                         d_mode;
   input                         delay_lclkr;
   input                         mpw1_b;
   input                         mpw2_b;
   input                         scan_in;
   output                        scan_out;
   
   input                         xu_iu_epcr_dgtmi;
   input                         xu_iu_msrp_uclep;
   input                         xu_iu_msr_pr;
   input                         xu_iu_msr_gs;
   input                         xu_iu_msr_ucle;
   input                         xu_iu_ccr2_ucode_dis;
   input                         mm_iu_tlbwe_binv;
   
   input [0:31]                  spr_dec_mask;
   input [0:31]                  spr_dec_match;
   
   input                         cp_iu_iu4_flush;
   input			 uc_ib_iu3_flush_all;
   input                         br_iu_redirect;
   
   input                         ib_id_iu4_valid;
   input [62-`EFF_IFAR_WIDTH:61]  ib_id_iu4_ifar;
   input [62-`EFF_IFAR_WIDTH:61]  ib_id_iu4_bta;
   input [0:69]                  ib_id_iu4_instr;
   input [0:2]                   ib_id_iu4_ucode;
   input [0:3]                   ib_id_iu4_ucode_ext;
   input                         ib_id_iu4_isram;
   input                         ib_id_iu4_fuse_val;
   input [0:31]                  ib_id_iu4_fuse_data;
   
   input                         au_iu_iu4_i_dec_b;
   input [0:2]                   au_iu_iu4_ucode;
   input                         au_iu_iu4_t1_v;
   input [0:2]                   au_iu_iu4_t1_t;
   input [0:`GPR_POOL_ENC-1]      au_iu_iu4_t1_a;
   input                         au_iu_iu4_t2_v;
   input [0:`GPR_POOL_ENC-1]      au_iu_iu4_t2_a;
   input [0:2]                   au_iu_iu4_t2_t;
   input                         au_iu_iu4_t3_v;
   input [0:`GPR_POOL_ENC-1]      au_iu_iu4_t3_a;
   input [0:2]                   au_iu_iu4_t3_t;
   input                         au_iu_iu4_s1_v;
   input [0:`GPR_POOL_ENC-1]      au_iu_iu4_s1_a;
   input [0:2]                   au_iu_iu4_s1_t;
   input                         au_iu_iu4_s2_v;
   input [0:`GPR_POOL_ENC-1]      au_iu_iu4_s2_a;
   input [0:2]                   au_iu_iu4_s2_t;
   input                         au_iu_iu4_s3_v;
   input [0:`GPR_POOL_ENC-1]      au_iu_iu4_s3_a;
   input [0:2]                   au_iu_iu4_s3_t;
   input [0:2]                   au_iu_iu4_ilat;
   input                         au_iu_iu4_ord;
   input                         au_iu_iu4_cord;
   input                         au_iu_iu4_spec;
   input                         au_iu_iu4_type_fp;
   input                         au_iu_iu4_type_ap;
   input                         au_iu_iu4_type_spv;
   input                         au_iu_iu4_type_st;
   input                         au_iu_iu4_async_block;
   input                         au_iu_iu4_isload;
   input                         au_iu_iu4_isstore;
   input                         au_iu_iu4_rte_lq;
   input                         au_iu_iu4_rte_sq;
   input                         au_iu_iu4_rte_axu0;
   input                         au_iu_iu4_rte_axu1;
   input                         au_iu_iu4_no_ram;
   
   output                        fdec_frn_iu5_ix_vld;
   output [0:2]                  fdec_frn_iu5_ix_ucode;
   output                        fdec_frn_iu5_ix_2ucode;
   output                        fdec_frn_iu5_ix_fuse_nop;
   output                        fdec_frn_iu5_ix_rte_lq;
   output                        fdec_frn_iu5_ix_rte_sq;
   output                        fdec_frn_iu5_ix_rte_fx0;
   output                        fdec_frn_iu5_ix_rte_fx1;
   output                        fdec_frn_iu5_ix_rte_axu0;
   output                        fdec_frn_iu5_ix_rte_axu1;
   output                        fdec_frn_iu5_ix_valop;
   output                        fdec_frn_iu5_ix_ord;
   output                        fdec_frn_iu5_ix_cord;
   output [0:2]                  fdec_frn_iu5_ix_error;
   output [0:19]                 fdec_frn_iu5_ix_fusion;
   output                        fdec_frn_iu5_ix_spec;
   output                        fdec_frn_iu5_ix_type_fp;
   output                        fdec_frn_iu5_ix_type_ap;
   output                        fdec_frn_iu5_ix_type_spv;
   output                        fdec_frn_iu5_ix_type_st;
   output                        fdec_frn_iu5_ix_async_block;
   output                        fdec_frn_iu5_ix_np1_flush;
   output                        fdec_frn_iu5_ix_core_block;
   output                        fdec_frn_iu5_ix_isram;
   output                        fdec_frn_iu5_ix_isload;
   output                        fdec_frn_iu5_ix_isstore;
   output [0:31]                 fdec_frn_iu5_ix_instr;
   output [62-`EFF_IFAR_WIDTH:61] fdec_frn_iu5_ix_ifar;
   output [62-`EFF_IFAR_WIDTH:61] fdec_frn_iu5_ix_bta;
   output [0:3]                  fdec_frn_iu5_ix_ilat;
   output                        fdec_frn_iu5_ix_t1_v;
   output [0:2]                  fdec_frn_iu5_ix_t1_t;
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_ix_t1_a;
   output                        fdec_frn_iu5_ix_t2_v;
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_ix_t2_a;
   output [0:2]                  fdec_frn_iu5_ix_t2_t;
   output                        fdec_frn_iu5_ix_t3_v;
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_ix_t3_a;
   output [0:2]                  fdec_frn_iu5_ix_t3_t;
   output                        fdec_frn_iu5_ix_s1_v;
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_ix_s1_a;
   output [0:2]                  fdec_frn_iu5_ix_s1_t;
   output                        fdec_frn_iu5_ix_s2_v;
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_ix_s2_a;
   output [0:2]                  fdec_frn_iu5_ix_s2_t;
   output                        fdec_frn_iu5_ix_s3_v;
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_ix_s3_a;
   output [0:2]                  fdec_frn_iu5_ix_s3_t;
   output                        fdec_frn_iu5_ix_br_pred;
   output                        fdec_frn_iu5_ix_bh_update;
   output [0:1]                  fdec_frn_iu5_ix_bh0_hist;
   output [0:1]                  fdec_frn_iu5_ix_bh1_hist;
   output [0:1]                  fdec_frn_iu5_ix_bh2_hist;
   output [0:17]                  fdec_frn_iu5_ix_gshare;
   output [0:2]                  fdec_frn_iu5_ix_ls_ptr;
   output                        fdec_frn_iu5_ix_match;
   output                        fdec_frn_iu5_ix_btb_entry;
   output [0:1]                  fdec_frn_iu5_ix_btb_hist;
   output                        fdec_frn_iu5_ix_bta_val;
   
   input                         frn_fdec_iu5_stall;
   
   
      wire [1:107]                  br_dep_pt;
      wire [1:223]                  instruction_decoder_pt;
      wire                          updatescr;
      wire [0:1]                    updatescr_sel;
      wire                          updatesctr;
      wire                          updateslr;
      wire                          updatesxer;
      wire                          usescr;
      wire                          usescr2;
      wire [0:1]                    usescr_sel;
      wire                          usesctr;
      wire                          useslr;
      wire                          usestar;
      wire                          usesxer;
      wire                          async_block;
      wire                          core_block;
      wire                          dec_val;
      wire                          isload;
      wire                          issue_fx0;
      wire                          issue_fx1;
      wire                          issue_lq;
      wire                          issue_sq;
      wire [0:3]                    latency;
      wire                          no_pre;
      wire                          no_ram;
      wire                          np1_flush;
      wire                          ordered;
      wire                          s1_sel;
      wire                          s1_vld;
      wire                          s2_sel;
      wire                          s2_vld;
      wire                          s3_vld;
      wire                          spec;
      wire                          ta_sel;
      wire                          ta_vld;
      wire                          zero_r0;
      parameter                     iu5_vld_offset = 0;
      parameter                     iu5_ucode_offset = iu5_vld_offset + 1;
      parameter                     iu5_2ucode_offset = iu5_ucode_offset + 3;
      parameter                     iu5_fuse_nop_offset = iu5_2ucode_offset + 1;
      parameter                     iu5_error_offset = iu5_fuse_nop_offset + 1;
      parameter                     iu5_btb_entry_offset = iu5_error_offset + 3;
      parameter                     iu5_btb_hist_offset = iu5_btb_entry_offset + 1;
      parameter                     iu5_bta_val_offset = iu5_btb_hist_offset + 2;
      parameter                     iu5_fusion_offset = iu5_bta_val_offset + 1;
      parameter                     iu5_rte_lq_offset = iu5_fusion_offset + 20;
      parameter                     iu5_rte_sq_offset = iu5_rte_lq_offset + 1;
      parameter                     iu5_rte_fx0_offset = iu5_rte_sq_offset + 1;
      parameter                     iu5_rte_fx1_offset = iu5_rte_fx0_offset + 1;
      parameter                     iu5_rte_axu0_offset = iu5_rte_fx1_offset + 1;
      parameter                     iu5_rte_axu1_offset = iu5_rte_axu0_offset + 1;
      parameter                     iu5_valop_offset = iu5_rte_axu1_offset + 1;
      parameter                     iu5_ord_offset = iu5_valop_offset + 1;
      parameter                     iu5_cord_offset = iu5_ord_offset + 1;
      parameter                     iu5_spec_offset = iu5_cord_offset + 1;
      parameter                     iu5_isram_offset = iu5_spec_offset + 1;
      parameter                     iu5_type_fp_offset = iu5_isram_offset + 1;
      parameter                     iu5_type_ap_offset = iu5_type_fp_offset + 1;
      parameter                     iu5_type_spv_offset = iu5_type_ap_offset + 1;
      parameter                     iu5_type_st_offset = iu5_type_spv_offset + 1;
      parameter                     iu5_async_block_offset = iu5_type_st_offset + 1;
      parameter                     iu5_np1_flush_offset = iu5_async_block_offset + 1;
      parameter                     iu5_core_block_offset = iu5_np1_flush_offset + 1;
      parameter                     iu5_isload_offset = iu5_core_block_offset + 1;
      parameter                     iu5_isstore_offset = iu5_isload_offset + 1;
      parameter                     iu5_instr_offset = iu5_isstore_offset + 1;
      parameter                     iu5_ifar_offset = iu5_instr_offset + 32;
      parameter                     iu5_bta_offset = iu5_ifar_offset + `EFF_IFAR_WIDTH;
      parameter                     iu5_ilat_offset = iu5_bta_offset + `EFF_IFAR_WIDTH;
      parameter                     iu5_t1_v_offset = iu5_ilat_offset + 4;
      parameter                     iu5_t1_t_offset = iu5_t1_v_offset + 1;
      parameter                     iu5_t1_a_offset = iu5_t1_t_offset + 3;
      parameter                     iu5_t2_v_offset = iu5_t1_a_offset + `GPR_POOL_ENC;
      parameter                     iu5_t2_a_offset = iu5_t2_v_offset + 1;
      parameter                     iu5_t2_t_offset = iu5_t2_a_offset + `GPR_POOL_ENC;
      parameter                     iu5_t3_v_offset = iu5_t2_t_offset + 3;
      parameter                     iu5_t3_a_offset = iu5_t3_v_offset + 1;
      parameter                     iu5_t3_t_offset = iu5_t3_a_offset + `GPR_POOL_ENC;
      parameter                     iu5_s1_v_offset = iu5_t3_t_offset + 3;
      parameter                     iu5_s1_a_offset = iu5_s1_v_offset + 1;
      parameter                     iu5_s1_t_offset = iu5_s1_a_offset + `GPR_POOL_ENC;
      parameter                     iu5_s2_v_offset = iu5_s1_t_offset + 3;
      parameter                     iu5_s2_a_offset = iu5_s2_v_offset + 1;
      parameter                     iu5_s2_t_offset = iu5_s2_a_offset + `GPR_POOL_ENC;
      parameter                     iu5_s3_v_offset = iu5_s2_t_offset + 3;
      parameter                     iu5_s3_a_offset = iu5_s3_v_offset + 1;
      parameter                     iu5_s3_t_offset = iu5_s3_a_offset + `GPR_POOL_ENC;
      parameter                     iu5_br_pred_offset = iu5_s3_t_offset + 3;
      parameter                     iu5_bh_update_offset = iu5_br_pred_offset + 1;
      parameter                     iu5_bh0_hist_offset = iu5_bh_update_offset + 1;
      parameter                     iu5_bh1_hist_offset = iu5_bh0_hist_offset + 2;
      parameter                     iu5_bh2_hist_offset = iu5_bh1_hist_offset + 2;
      parameter                     iu5_gshare_offset = iu5_bh2_hist_offset + 2;
      parameter                     iu5_ls_ptr_offset = iu5_gshare_offset + 18;
      parameter                     iu5_match_offset = iu5_ls_ptr_offset + 3;
      parameter                     spr_epcr_dgtmi_offset = iu5_match_offset + 1;
      parameter                     spr_msrp_uclep_offset = spr_epcr_dgtmi_offset + 1;
      parameter                     spr_msr_pr_offset = spr_msrp_uclep_offset + 1;
      parameter                     spr_msr_gs_offset = spr_msr_pr_offset + 1;
      parameter                     spr_msr_ucle_offset = spr_msr_gs_offset + 1;
      parameter                     spr_ccr2_ucode_dis_offset = spr_msr_ucle_offset + 1;
      parameter                     cp_flush_offset = spr_ccr2_ucode_dis_offset + 1;
      parameter                     scan_right = cp_flush_offset + 1 - 1;
      wire [0:scan_right]           siv;
      wire [0:scan_right]           sov;
      wire                          tiup;
      wire                          core64;
      wire                          cp_flush_d;
      wire                          cp_flush_q;
      wire                          iu4_instr_vld;
      wire [62-`EFF_IFAR_WIDTH:61]   iu4_ifar;
      wire [62-`EFF_IFAR_WIDTH:61]   iu4_bta;
      wire [0:31]                   iu4_instr;
      wire [0:3]                    iu4_instr_ucode_ext;
      wire                          iu4_instr_br_pred;
      wire                          iu4_instr_bh_update;
      wire [0:1]                    iu4_instr_bh0_hist;
      wire [0:1]                    iu4_instr_bh1_hist;
      wire [0:1]                    iu4_instr_bh2_hist;
      wire [0:17]                    iu4_instr_gshare;
      wire [0:2]                    iu4_instr_ls_ptr;
      wire                          iu4_instr_match;
      wire [0:2]                    iu4_instr_error;
      wire                          iu4_instr_btb_entry;
      wire [0:1]                    iu4_instr_btb_hist;
      wire                          iu4_instr_bta_val;
      wire [0:2]                    iu4_instr_ucode;
      wire                          iu4_instr_2ucode;
      wire                          iu4_instr_isram;
      wire                          iu4_fuse_val;
      wire [0:31]                   iu4_fuse_cmp;
      wire                          iu4_fuse_nop;
      wire                          iu4_is_mtcpcr;
      reg                           iu5_vld_d;
      reg [0:2]                     iu5_ucode_d;
      reg                           iu5_2ucode_d;
      reg                           iu5_fuse_nop_d;
      reg [0:2]                     iu5_error_d;
      reg                           iu5_btb_entry_d;
      reg [0:1]                     iu5_btb_hist_d;
      reg                           iu5_bta_val_d;
      reg [0:19]                    iu5_fusion_d;
      reg                           iu5_rte_lq_d;
      reg                           iu5_rte_sq_d;
      reg                           iu5_rte_fx0_d;
      reg                           iu5_rte_fx1_d;
      reg                           iu5_rte_axu0_d;
      reg                           iu5_rte_axu1_d;
      reg                           iu5_valop_d;
      reg                           iu5_ord_d;
      reg                           iu5_cord_d;
      reg                           iu5_spec_d;
      reg                           iu5_type_fp_d;
      reg                           iu5_type_ap_d;
      reg                           iu5_type_spv_d;
      reg                           iu5_type_st_d;
      reg                           iu5_async_block_d;
      reg                           iu5_np1_flush_d;
      reg                           iu5_core_block_d;
      reg                           iu5_isram_d;
      reg                           iu5_isload_d;
      reg                           iu5_isstore_d;
      reg [0:31]                    iu5_instr_d;
      reg [62-`EFF_IFAR_WIDTH:61]    iu5_ifar_d;
      reg [62-`EFF_IFAR_WIDTH:61]    iu5_bta_d;
      reg [0:3]                     iu5_ilat_d;
      reg                           iu5_t1_v_d;
      reg [0:2]                     iu5_t1_t_d;
      reg [0:`GPR_POOL_ENC-1]        iu5_t1_a_d;
      reg                           iu5_t2_v_d;
      reg [0:`GPR_POOL_ENC-1]        iu5_t2_a_d;
      reg [0:2]                     iu5_t2_t_d;
      reg                           iu5_t3_v_d;
      reg [0:`GPR_POOL_ENC-1]        iu5_t3_a_d;
      reg [0:2]                     iu5_t3_t_d;
      reg                           iu5_s1_v_d;
      reg [0:`GPR_POOL_ENC-1]        iu5_s1_a_d;
      reg [0:2]                     iu5_s1_t_d;
      reg                           iu5_s2_v_d;
      reg [0:`GPR_POOL_ENC-1]        iu5_s2_a_d;
      reg [0:2]                     iu5_s2_t_d;
      reg                           iu5_s3_v_d;
      reg [0:`GPR_POOL_ENC-1]        iu5_s3_a_d;
      reg [0:2]                     iu5_s3_t_d;
      reg                           iu5_br_pred_d;
      reg                           iu5_bh_update_d;
      reg [0:1]                     iu5_bh0_hist_d;
      reg [0:1]                     iu5_bh1_hist_d;
      reg [0:1]                     iu5_bh2_hist_d;
      reg [0:17]                     iu5_gshare_d;
      reg [0:2]                     iu5_ls_ptr_d;
      reg                           iu5_match_d;
      wire                          iu5_vld_q;
      wire [0:2]                    iu5_ucode_q;
      wire                          iu5_2ucode_q;
      wire                          iu5_fuse_nop_q;
      wire [0:2]                    iu5_error_q;
      wire                          iu5_btb_entry_q;
      wire [0:1]                    iu5_btb_hist_q;
      wire                          iu5_bta_val_q;
      wire [0:19]                   iu5_fusion_q;
      wire                          iu5_rte_lq_q;
      wire                          iu5_rte_sq_q;
      wire                          iu5_rte_fx0_q;
      wire                          iu5_rte_fx1_q;
      wire                          iu5_rte_axu0_q;
      wire                          iu5_rte_axu1_q;
      wire                          iu5_valop_q;
      wire                          iu5_ord_q;
      wire                          iu5_cord_q;
      wire                          iu5_spec_q;
      wire                          iu5_type_fp_q;
      wire                          iu5_type_ap_q;
      wire                          iu5_type_spv_q;
      wire                          iu5_type_st_q;
      wire                          iu5_async_block_q;
      wire                          iu5_np1_flush_q;
      wire                          iu5_core_block_q;
      wire                          iu5_isram_q;
      wire                          iu5_isload_q;
      wire                          iu5_isstore_q;
      wire [0:31]                   iu5_instr_q;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ifar_q;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_bta_q;
      wire [0:3]                    iu5_ilat_q;
      wire                          iu5_t1_v_q;
      wire [0:2]                    iu5_t1_t_q;
      wire [0:`GPR_POOL_ENC-1]       iu5_t1_a_q;
      wire                          iu5_t2_v_q;
      wire [0:`GPR_POOL_ENC-1]       iu5_t2_a_q;
      wire [0:2]                    iu5_t2_t_q;
      wire                          iu5_t3_v_q;
      wire [0:`GPR_POOL_ENC-1]       iu5_t3_a_q;
      wire [0:2]                    iu5_t3_t_q;
      wire                          iu5_s1_v_q;
      wire [0:`GPR_POOL_ENC-1]       iu5_s1_a_q;
      wire [0:2]                    iu5_s1_t_q;
      wire                          iu5_s2_v_q;
      wire [0:`GPR_POOL_ENC-1]       iu5_s2_a_q;
      wire [0:2]                    iu5_s2_t_q;
      wire                          iu5_s3_v_q;
      wire [0:`GPR_POOL_ENC-1]       iu5_s3_a_q;
      wire [0:2]                    iu5_s3_t_q;
      wire                          iu5_br_pred_q;
      wire                          iu5_bh_update_q;
      wire [0:1]                    iu5_bh0_hist_q;
      wire [0:1]                    iu5_bh1_hist_q;
      wire [0:1]                    iu5_bh2_hist_q;
      wire [0:17]                    iu5_gshare_q;
      wire [0:2]                    iu5_ls_ptr_q;
      wire                          iu5_match_q;
      wire                          iu5_vld_din;
      wire [0:2]                    iu5_ucode_din;
      wire                          iu5_2ucode_din;
      wire                          iu5_fuse_nop_din;
      wire [0:2]                    iu5_error_din;
      wire                          iu5_btb_entry_din;
      wire [0:1]                    iu5_btb_hist_din;
      wire                          iu5_bta_val_din;
      wire [0:19]                   iu5_fusion_din;
      wire                          iu5_rte_lq_din;
      wire                          iu5_rte_sq_din;
      wire                          iu5_rte_fx0_din;
      wire                          iu5_rte_fx1_din;
      wire                          iu5_rte_axu0_din;
      wire                          iu5_rte_axu1_din;
      wire                          iu5_valop_din;
      wire                          iu5_ord_din;
      wire                          iu5_cord_din;
      wire                          iu5_spec_din;
      wire                          iu5_type_fp_din;
      wire                          iu5_type_ap_din;
      wire                          iu5_type_spv_din;
      wire                          iu5_type_st_din;
      wire                          iu5_async_block_din;
      wire                          iu5_np1_flush_din;
      wire                          iu5_core_block_din;
      wire                          iu5_isram_din;
      wire                          iu5_isload_din;
      wire                          iu5_isstore_din;
      wire [0:31]                   iu5_instr_din;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ifar_din;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_bta_din;
      wire [0:3]                    iu5_ilat_din;
      wire                          iu5_t1_v_din;
      wire [0:2]                    iu5_t1_t_din;
      wire [0:`GPR_POOL_ENC-1]       iu5_t1_a_din;
      wire                          iu5_t2_v_din;
      wire [0:`GPR_POOL_ENC-1]       iu5_t2_a_din;
      wire [0:2]                    iu5_t2_t_din;
      wire                          iu5_t3_v_din;
      wire [0:`GPR_POOL_ENC-1]       iu5_t3_a_din;
      wire [0:2]                    iu5_t3_t_din;
      wire                          iu5_s1_v_din;
      wire [0:`GPR_POOL_ENC-1]       iu5_s1_a_din;
      wire [0:2]                    iu5_s1_t_din;
      wire                          iu5_s2_v_din;
      wire [0:`GPR_POOL_ENC-1]       iu5_s2_a_din;
      wire [0:2]                    iu5_s2_t_din;
      wire                          iu5_s3_v_din;
      wire [0:`GPR_POOL_ENC-1]       iu5_s3_a_din;
      wire [0:2]                    iu5_s3_t_din;
      wire                          iu5_br_pred_din;
      wire                          iu5_bh_update_din;
      wire [0:1]                    iu5_bh0_hist_din;
      wire [0:1]                    iu5_bh1_hist_din;
      wire [0:1]                    iu5_bh2_hist_din;
      wire [0:17]                    iu5_gshare_din;
      wire [0:2]                    iu5_ls_ptr_din;
      wire                          iu5_match_din;
      wire                          iu5_vld_woaxu;
      wire [0:2]                    iu5_ucode_woaxu;
      wire                          iu5_2ucode_woaxu;
      wire                          iu5_fuse_nop_woaxu;
      wire [0:2]                    iu5_error_woaxu;
      wire                          iu5_btb_entry_woaxu;
      wire [0:1]                    iu5_btb_hist_woaxu;
      wire                          iu5_bta_val_woaxu;
      wire [0:19]                   iu5_fusion_woaxu;
      wire                          iu5_rte_lq_woaxu;
      wire                          iu5_rte_sq_woaxu;
      wire                          iu5_rte_fx0_woaxu;
      wire                          iu5_rte_fx1_woaxu;
      wire                          iu5_rte_axu0_woaxu;
      wire                          iu5_rte_axu1_woaxu;
      wire                          iu5_valop_woaxu;
      wire                          iu5_ord_woaxu;
      wire                          iu5_cord_woaxu;
      wire                          iu5_spec_woaxu;
      wire                          iu5_type_fp_woaxu;
      wire                          iu5_type_ap_woaxu;
      wire                          iu5_type_spv_woaxu;
      wire                          iu5_type_st_woaxu;
      wire                          iu5_async_block_woaxu;
      wire                          iu5_np1_flush_woaxu;
      wire                          iu5_core_block_woaxu;
      wire                          iu5_isram_woaxu;
      wire                          iu5_isload_woaxu;
      wire                          iu5_isstore_woaxu;
      wire [0:31]                   iu5_instr_woaxu;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_ifar_woaxu;
      wire [62-`EFF_IFAR_WIDTH:61]   iu5_bta_woaxu;
      wire [0:3]                    iu5_ilat_woaxu;
      wire                          iu5_t1_v_woaxu;
      wire [0:2]                    iu5_t1_t_woaxu;
      wire [0:`GPR_POOL_ENC-1]       iu5_t1_a_woaxu;
      wire                          iu5_t2_v_woaxu;
      wire [0:`GPR_POOL_ENC-1]       iu5_t2_a_woaxu;
      wire [0:2]                    iu5_t2_t_woaxu;
      wire                          iu5_t3_v_woaxu;
      wire [0:`GPR_POOL_ENC-1]       iu5_t3_a_woaxu;
      wire [0:2]                    iu5_t3_t_woaxu;
      wire                          iu5_s1_v_woaxu;
      wire [0:`GPR_POOL_ENC-1]       iu5_s1_a_woaxu;
      wire [0:2]                    iu5_s1_t_woaxu;
      wire                          iu5_s2_v_woaxu;
      wire [0:`GPR_POOL_ENC-1]       iu5_s2_a_woaxu;
      wire [0:2]                    iu5_s2_t_woaxu;
      wire                          iu5_s3_v_woaxu;
      wire [0:`GPR_POOL_ENC-1]       iu5_s3_a_woaxu;
      wire [0:2]                    iu5_s3_t_woaxu;
      wire                          iu5_br_pred_woaxu;
      wire                          iu5_bh_update_woaxu;
      wire [0:1]                    iu5_bh0_hist_woaxu;
      wire [0:1]                    iu5_bh1_hist_woaxu;
      wire [0:1]                    iu5_bh2_hist_woaxu;
      wire [0:17]                    iu5_gshare_woaxu;
      wire [0:2]                    iu5_ls_ptr_woaxu;
      wire                          iu5_match_woaxu;
      wire [0:5]                    iu5_t1_a_woaxu6;
      wire [0:5]                    iu5_t2_a_woaxu6;
      wire [0:5]                    iu5_t3_a_woaxu6;
      wire [0:5]                    iu5_s1_a_woaxu6;
      wire [0:5]                    iu5_s2_a_woaxu6;
      wire [0:5]                    iu5_s3_a_woaxu6;
      wire                          iu5_valid_act;
      wire                          iu5_instr_act;
      wire                          iu4_is_mtiar;
      wire                          spr_epcr_dgtmi_q;
      wire                          spr_msrp_uclep_q;
      wire                          spr_msr_pr_q;
      wire                          spr_msr_gs_q;
      wire                          spr_msr_ucle_q;
      wire                          spr_ccr2_ucode_dis_q;
      wire                          pc_iu_func_sl_thold_1;
      wire                          pc_iu_func_sl_thold_0;
      wire                          pc_iu_func_sl_thold_0_b;
      wire                          pc_iu_sg_1;
      wire                          pc_iu_sg_0;
      wire                          force_t;
      wire                          axu;
      wire                          naxu;
      wire                          multi_cr;
      wire                          or_ppr32_val;
      wire                          or_ppr32;
      wire                          mtspr_trace_val;
      wire                          erativax_val;
      wire                          tlbwe_with_binv;
      wire                          mtspr_nop;
      wire                          mfspr_nop;
      wire                          spr_nop;
      wire                          mtspr_tar;
      wire                          mfspr_tar;
      wire                          mtspr_tenc;
      wire                          mtspr_xucr0;
      wire                          mtspr_ccr0;
      wire                          mfspr_mmucr1;
      wire [0:5]                    SPR_addr;
      

     assign tiup = 1'b1;
      assign cp_flush_d = cp_iu_iu4_flush | br_iu_redirect | uc_ib_iu3_flush_all;
      assign iu4_instr_vld = ib_id_iu4_valid;
      assign iu4_ifar = ib_id_iu4_ifar;
      assign iu4_bta = ib_id_iu4_bta;
      assign iu4_instr = ib_id_iu4_instr[0:31];
      assign iu4_instr_br_pred = ib_id_iu4_instr[32];
      assign iu4_instr_bh_update = ib_id_iu4_instr[33];
      assign iu4_instr_bh0_hist = ib_id_iu4_instr[34:35];
      assign iu4_instr_bh1_hist = ib_id_iu4_instr[36:37];
      assign iu4_instr_bh2_hist = ib_id_iu4_instr[38:39];
      assign iu4_instr_gshare = {ib_id_iu4_instr[40:49], ib_id_iu4_instr[62:69]};
      assign iu4_instr_ls_ptr = ib_id_iu4_instr[50:52];
      assign iu4_instr_match = (spr_dec_mask[0:31] & iu4_instr[0:31]) == (spr_dec_mask[0:31] & spr_dec_match[0:31]);
      assign iu4_instr_error = ib_id_iu4_instr[53:55];
      assign iu4_fuse_nop = ib_id_iu4_instr[57];
      assign iu4_instr_btb_entry = ib_id_iu4_instr[58];
      assign iu4_instr_btb_hist = ib_id_iu4_instr[59:60];
      assign iu4_instr_bta_val = ib_id_iu4_instr[61];
      assign iu4_instr_ucode_ext = ib_id_iu4_ucode_ext;
      assign iu4_instr_ucode = ib_id_iu4_ucode;
      assign iu4_instr_2ucode = ib_id_iu4_instr[59];
      assign iu4_instr_isram = ib_id_iu4_isram;
      assign iu4_is_mtiar = ((iu4_instr[0:5] == 6'b011111) & (iu4_instr[11:20] == 10'b1001011011) & (iu4_instr[21:30] == 10'b0111010011)) ? 1'b1 : 
                            1'b0;
      assign iu4_fuse_val = ib_id_iu4_fuse_val;
      assign iu4_fuse_cmp = ib_id_iu4_fuse_data;

      assign iu4_is_mtcpcr = (~iu4_fuse_val & (iu4_instr[0:5] == 6'b011111) & (iu4_instr[21:30] == 10'b0111010011)) &
                             ((iu4_instr[11:20] == 10'b1000011001) | (iu4_instr[11:20] == 10'b1000111001) | (iu4_instr[11:20] == 10'b1001011001) |
                              (iu4_instr[11:20] == 10'b1010011001) | (iu4_instr[11:20] == 10'b1010111001) | (iu4_instr[11:20] == 10'b1011011001));

      generate
         if (`GPR_WIDTH == 64)
         begin : c64
            assign core64 = 1'b1;
         end
      endgenerate
      generate
         if (`GPR_WIDTH == 32)
         begin : c32
            assign core64 = 1'b0;
         end
      endgenerate
      assign multi_cr = (~(iu4_instr[12:19] == 8'b00000000 | iu4_instr[12:19] == 8'b10000000 | iu4_instr[12:19] == 8'b01000000 | iu4_instr[12:19] == 8'b00100000 | iu4_instr[12:19] == 8'b00010000 | iu4_instr[12:19] == 8'b00001000 | iu4_instr[12:19] == 8'b00000100 | iu4_instr[12:19] == 8'b00000010 | iu4_instr[12:19] == 8'b00000001));
      assign or_ppr32 = (iu4_instr[0:5] == 6'b011111 & iu4_instr[21:31] == 11'b01101111000) & (iu4_instr[6:10] == iu4_instr[11:15] & iu4_instr[11:15] == iu4_instr[16:20]);
      assign or_ppr32_val = (iu4_instr[16:20] == 5'b11111 | iu4_instr[16:20] == 5'b00001 | iu4_instr[16:20] == 5'b00110 | iu4_instr[16:20] == 5'b00010 | iu4_instr[16:20] == 5'b00101 | iu4_instr[16:20] == 5'b00011 | iu4_instr[16:20] == 5'b00111) & or_ppr32 & (~(|(iu4_instr_ucode)));
      assign mtspr_trace_val = (iu4_instr[0:5] == 6'b011111) & (iu4_instr[11:30] == 20'b01110111110111010011);
      assign erativax_val = (iu4_instr[0:5] == 6'b011111 & iu4_instr[21:30] == 10'b1100110011);
      assign tlbwe_with_binv = (iu4_instr[0:5] == 6'b011111 & iu4_instr[21:30] == 10'b1111010010) & mm_iu_tlbwe_binv;
      assign mtspr_nop = iu4_instr[0:5] == 6'b011111 & iu4_instr[11:13] == 3'b010 & iu4_instr[16:30] == 15'b110010111010011;
      assign mfspr_nop = iu4_instr[0:5] == 6'b011111 & iu4_instr[11:13] == 3'b010 & iu4_instr[16:30] == 15'b110010101010011;
      assign spr_nop = mtspr_nop | mfspr_nop;
      assign mtspr_tar = iu4_instr[0:5] == 6'b011111 & iu4_instr[11:20] == 10'b0111111001 & iu4_instr[21:30] == 10'b0111010011;
      assign mfspr_tar = iu4_instr[0:5] == 6'b011111 & iu4_instr[11:20] == 10'b0111111001 & iu4_instr[21:30] == 10'b0101010011;
      assign mtspr_tenc = iu4_instr[0:5] == 6'b011111 & iu4_instr[11:20] == 10'b1011101101 & iu4_instr[21:30] == 10'b0111010011;
      assign mtspr_xucr0 = iu4_instr[0:5] == 6'b011111 & iu4_instr[11:20] == 10'b1011011111 & iu4_instr[21:30] == 10'b0111010011;
      assign mtspr_ccr0 = iu4_instr[0:5] == 6'b011111 & iu4_instr[11:20] == 10'b1000011111 & iu4_instr[21:30] == 10'b0111010011;
      assign mfspr_mmucr1 = iu4_instr[0:5] == 6'b011111 & iu4_instr[11:20] == 10'b1110111111 & iu4_instr[21:30] == 10'b0101010011;






assign br_dep_pt[1] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[8] , iu4_instr[31] , 
    iu4_fuse_cmp[0] , iu4_fuse_cmp[1] , 
    iu4_fuse_cmp[2] , iu4_fuse_cmp[3] , 
    iu4_fuse_cmp[4] , iu4_fuse_cmp[5] , 
    iu4_fuse_cmp[21] , iu4_fuse_cmp[22] , 
    iu4_fuse_cmp[23] , iu4_fuse_cmp[24] , 
    iu4_fuse_cmp[26] , iu4_fuse_cmp[27] , 
    iu4_fuse_cmp[28] , iu4_fuse_cmp[29] , 
    iu4_fuse_cmp[30] }) === 23'b01000011011111000000000);
assign br_dep_pt[2] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[8] , iu4_fuse_val , 
    iu4_fuse_cmp[0] , iu4_fuse_cmp[1] , 
    iu4_fuse_cmp[2] , iu4_fuse_cmp[3] , 
    iu4_fuse_cmp[4] , iu4_fuse_cmp[5] , 
    iu4_fuse_cmp[21] , iu4_fuse_cmp[22] , 
    iu4_fuse_cmp[23] , iu4_fuse_cmp[24] , 
    iu4_fuse_cmp[26] , iu4_fuse_cmp[27] , 
    iu4_fuse_cmp[28] , iu4_fuse_cmp[29] , 
    iu4_fuse_cmp[30] }) === 23'b01000011011111000000000);
assign br_dep_pt[3] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[12] , 
    iu4_instr[13] , iu4_instr[14] , 
    iu4_instr[15] , iu4_instr[16] , 
    iu4_instr[17] , iu4_instr[18] , 
    iu4_instr[19] , iu4_instr[20] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 27'b011111010010000001110100110);
assign br_dep_pt[4] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[12] , 
    iu4_instr[13] , iu4_instr[14] , 
    iu4_instr[15] , iu4_instr[16] , 
    iu4_instr[17] , iu4_instr[18] , 
    iu4_instr[19] , iu4_instr[20] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 27'b011111010000000001110100110);
assign br_dep_pt[5] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[12] , 
    iu4_instr[13] , iu4_instr[14] , 
    iu4_instr[15] , iu4_instr[16] , 
    iu4_instr[17] , iu4_instr[18] , 
    iu4_instr[19] , iu4_instr[20] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 27'b011111010000000001010100110);
assign br_dep_pt[6] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[12] , 
    iu4_instr[13] , iu4_instr[14] , 
    iu4_instr[15] , iu4_instr[16] , 
    iu4_instr[17] , iu4_instr[18] , 
    iu4_instr[19] , iu4_instr[20] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 27'b011111000010000001110100110);
assign br_dep_pt[7] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[12] , 
    iu4_instr[13] , iu4_instr[14] , 
    iu4_instr[15] , iu4_instr[16] , 
    iu4_instr[17] , iu4_instr[18] , 
    iu4_instr[19] , iu4_instr[20] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 27'b011111010010000001010100110);
assign br_dep_pt[8] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[5] , iu4_instr[11] , 
    iu4_instr[12] , iu4_instr[13] , 
    iu4_instr[14] , iu4_instr[15] , 
    iu4_instr[16] , iu4_instr[17] , 
    iu4_instr[18] , iu4_instr[19] , 
    iu4_instr[20] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 26'b01111000010000001010100110);
assign br_dep_pt[9] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[8] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_cmp[0] , 
    iu4_fuse_cmp[1] , iu4_fuse_cmp[2] , 
    iu4_fuse_cmp[3] , iu4_fuse_cmp[4]
     }) === 22'b0100111000010000100101);
assign br_dep_pt[10] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[8] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_cmp[0] , 
    iu4_fuse_cmp[1] , iu4_fuse_cmp[2] , 
    iu4_fuse_cmp[3] , iu4_fuse_cmp[4]
     }) === 22'b0100111100010000100101);
assign br_dep_pt[11] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[8] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val , 
    iu4_fuse_cmp[0] , iu4_fuse_cmp[1] , 
    iu4_fuse_cmp[2] , iu4_fuse_cmp[3] , 
    iu4_fuse_cmp[4] }) === 23'b01001111000110000100101);
assign br_dep_pt[12] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[8] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val , 
    iu4_fuse_cmp[0] , iu4_fuse_cmp[1] , 
    iu4_fuse_cmp[2] , iu4_fuse_cmp[3] , 
    iu4_fuse_cmp[4] }) === 23'b01001111000010000100101);
assign br_dep_pt[13] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[8] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val , 
    iu4_fuse_cmp[0] , iu4_fuse_cmp[1] , 
    iu4_fuse_cmp[2] , iu4_fuse_cmp[3] , 
    iu4_fuse_cmp[4] }) === 23'b01001110000010000100101);
assign br_dep_pt[14] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[8] , iu4_fuse_cmp[0] , 
    iu4_fuse_cmp[1] , iu4_fuse_cmp[2] , 
    iu4_fuse_cmp[3] , iu4_fuse_cmp[4]
     }) === 12'b010000000101);
assign br_dep_pt[15] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[31] , iu4_fuse_cmp[0] , 
    iu4_fuse_cmp[1] , iu4_fuse_cmp[2] , 
    iu4_fuse_cmp[3] , iu4_fuse_cmp[4]
     }) === 12'b010000100101);
assign br_dep_pt[16] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[6] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01001100000000000);
assign br_dep_pt[17] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 17'b01001000001000010);
assign br_dep_pt[18] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[6] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 18'b010011010001100000);
assign br_dep_pt[19] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[8] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 18'b010011010001100000);
assign br_dep_pt[20] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[6] , iu4_instr[8] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 18'b010011010000100000);
assign br_dep_pt[21] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 17'b01001100011000010);
assign br_dep_pt[22] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[3] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 16'b1011111001110110);
assign br_dep_pt[23] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 16'b0111000100111010);
assign br_dep_pt[24] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[8] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 18'b010011110000100000);
assign br_dep_pt[25] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[8] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 18'b010011000000100000);
assign br_dep_pt[26] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[8] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 17'b01001100001000010);
assign br_dep_pt[27] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 18'b011111100000100110);
assign br_dep_pt[28] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[19] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 19'b0111111100100100000);
assign br_dep_pt[29] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[18] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 19'b0111111100100100000);
assign br_dep_pt[30] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[17] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 19'b0111111100100100000);
assign br_dep_pt[31] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[16] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 19'b0111111100100100000);
assign br_dep_pt[32] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[14] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 19'b0111111100100100000);
assign br_dep_pt[33] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[13] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 19'b0111111100100100000);
assign br_dep_pt[34] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[15] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 19'b0111111100100100000);
assign br_dep_pt[35] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[12] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 19'b0111111100100100000);
assign br_dep_pt[36] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_fuse_val , iu4_fuse_cmp[0] , 
    iu4_fuse_cmp[1] , iu4_fuse_cmp[2] , 
    iu4_fuse_cmp[3] , iu4_fuse_cmp[4]
     }) === 12'b010000100101);
assign br_dep_pt[37] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_fuse_val }) === 17'b10111111100111010);
assign br_dep_pt[38] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01001110001100000);
assign br_dep_pt[39] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111100010011100);
assign br_dep_pt[40] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 16'b1011100110101010);
assign br_dep_pt[41] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_fuse_val
     }) === 16'b1011111101110100);
assign br_dep_pt[42] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01001100000100000);
assign br_dep_pt[43] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[3] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 15'b101111100110010);
assign br_dep_pt[44] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_fuse_val
     }) === 16'b0111111011101010);
assign br_dep_pt[45] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111100000100110);
assign br_dep_pt[46] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 16'b0111101101011010);
assign br_dep_pt[47] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111111100001100);
assign br_dep_pt[48] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 15'b011111001100010);
assign br_dep_pt[49] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0100110101000010);
assign br_dep_pt[50] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[5] , iu4_instr[11] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111000100100000);
assign br_dep_pt[51] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0100110110000010);
assign br_dep_pt[52] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b101111111101010);
assign br_dep_pt[53] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0100110011000010);
assign br_dep_pt[54] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 16'b0111110101001010);
assign br_dep_pt[55] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0100110001000010);
assign br_dep_pt[56] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 15'b011111011011010);
assign br_dep_pt[57] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111111010110);
assign br_dep_pt[58] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0100110100000010);
assign br_dep_pt[59] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b1011111110011000);
assign br_dep_pt[60] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111001010000);
assign br_dep_pt[61] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[3] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 16'b1011111101101010);
assign br_dep_pt[62] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01001100000000000);
assign br_dep_pt[63] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0100110010000010);
assign br_dep_pt[64] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111000101010);
assign br_dep_pt[65] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 16'b0111001101010010);
assign br_dep_pt[66] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 16'b0111001001001110);
assign br_dep_pt[67] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111000010100);
assign br_dep_pt[68] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111100110000);
assign br_dep_pt[69] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 15'b011101001011010);
assign br_dep_pt[70] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 15'b011101101110010);
assign br_dep_pt[71] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 15'b011111100101010);
assign br_dep_pt[72] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[3] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 16'b1011100001101010);
assign br_dep_pt[73] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 13'b0111011010010);
assign br_dep_pt[74] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 15'b011100011110010);
assign br_dep_pt[75] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111110000000000);
assign br_dep_pt[76] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[3] , 
    iu4_instr[5] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 14'b10111011101010);
assign br_dep_pt[77] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[3] , 
    iu4_instr[5] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 15'b101110000101110);
assign br_dep_pt[78] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 15'b011111101101010);
assign br_dep_pt[79] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 14'b01110111010110);
assign br_dep_pt[80] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 12'b011111011110);
assign br_dep_pt[81] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 13'b0111000010010);
assign br_dep_pt[82] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01111101101000);
assign br_dep_pt[83] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 14'b01110101110010);
assign br_dep_pt[84] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110000000000);
assign br_dep_pt[85] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[3] , 
    iu4_instr[5] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 14'b10111000010110);
assign br_dep_pt[86] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[3] , 
    iu4_instr[5] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 13'b1011111010110);
assign br_dep_pt[87] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 14'b01110001110010);
assign br_dep_pt[88] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 14'b01110000101110);
assign br_dep_pt[89] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 14'b01110000001110);
assign br_dep_pt[90] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 13'b0111110101110);
assign br_dep_pt[91] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 14'b01110010100010);
assign br_dep_pt[92] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01111100001000);
assign br_dep_pt[93] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 14'b01110000101010);
assign br_dep_pt[94] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[6] , iu4_fuse_val
     }) === 8'b01000000);
assign br_dep_pt[95] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[8] , iu4_fuse_val
     }) === 8'b01000000);
assign br_dep_pt[96] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 14'b01110000010010);
assign br_dep_pt[97] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 14'b01110000100010);
assign br_dep_pt[98] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_fuse_val }) === 7'b0100000);
assign br_dep_pt[99] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 10'b1011100010);
assign br_dep_pt[100] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[5] , iu4_instr[31] , 
    iu4_fuse_val }) === 7'b0100010);
assign br_dep_pt[101] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[5] , iu4_fuse_val
     }) === 6'b001000);
assign br_dep_pt[102] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[27] , iu4_instr[31] , 
    iu4_fuse_val }) === 9'b101110010);
assign br_dep_pt[103] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_fuse_val }) === 7'b0011010);
assign br_dep_pt[104] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_fuse_val
     }) === 6'b001010);
assign br_dep_pt[105] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 6'b011010);
assign br_dep_pt[106] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_fuse_val
     }) === 6'b011100);
assign br_dep_pt[107] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[5] , iu4_instr[31] , 
    iu4_fuse_val }) === 7'b0101110);
assign updateslr = 
    (br_dep_pt[1] | br_dep_pt[4]
     | br_dep_pt[9] | br_dep_pt[10]
     | br_dep_pt[15] | br_dep_pt[17]
     | br_dep_pt[21] | br_dep_pt[26]
     | br_dep_pt[100]);
assign updatescr = 
    (br_dep_pt[2] | br_dep_pt[11]
     | br_dep_pt[12] | br_dep_pt[13]
     | br_dep_pt[22] | br_dep_pt[23]
     | br_dep_pt[28] | br_dep_pt[29]
     | br_dep_pt[30] | br_dep_pt[31]
     | br_dep_pt[32] | br_dep_pt[33]
     | br_dep_pt[34] | br_dep_pt[35]
     | br_dep_pt[36] | br_dep_pt[40]
     | br_dep_pt[43] | br_dep_pt[46]
     | br_dep_pt[47] | br_dep_pt[48]
     | br_dep_pt[49] | br_dep_pt[50]
     | br_dep_pt[51] | br_dep_pt[53]
     | br_dep_pt[54] | br_dep_pt[55]
     | br_dep_pt[56] | br_dep_pt[58]
     | br_dep_pt[61] | br_dep_pt[62]
     | br_dep_pt[63] | br_dep_pt[65]
     | br_dep_pt[66] | br_dep_pt[69]
     | br_dep_pt[70] | br_dep_pt[71]
     | br_dep_pt[72] | br_dep_pt[73]
     | br_dep_pt[74] | br_dep_pt[75]
     | br_dep_pt[76] | br_dep_pt[77]
     | br_dep_pt[78] | br_dep_pt[79]
     | br_dep_pt[81] | br_dep_pt[83]
     | br_dep_pt[84] | br_dep_pt[85]
     | br_dep_pt[86] | br_dep_pt[87]
     | br_dep_pt[88] | br_dep_pt[89]
     | br_dep_pt[90] | br_dep_pt[91]
     | br_dep_pt[93] | br_dep_pt[96]
     | br_dep_pt[97] | br_dep_pt[99]
     | br_dep_pt[102] | br_dep_pt[103]
     | br_dep_pt[104] | br_dep_pt[105]
     | br_dep_pt[106] | br_dep_pt[107]
    );
assign updatesctr = 
    (br_dep_pt[3] | br_dep_pt[14]
     | br_dep_pt[19] | br_dep_pt[25]
     | br_dep_pt[95]);
assign updatesxer = 
    (br_dep_pt[6] | br_dep_pt[37]
     | br_dep_pt[39] | br_dep_pt[41]
     | br_dep_pt[44] | br_dep_pt[52]
     | br_dep_pt[57] | br_dep_pt[59]
     | br_dep_pt[60] | br_dep_pt[67]
     | br_dep_pt[68] | br_dep_pt[75]
     | br_dep_pt[82] | br_dep_pt[92]
     | br_dep_pt[101] | br_dep_pt[103]
    );
assign useslr = 
    (br_dep_pt[5] | br_dep_pt[13]
     | br_dep_pt[42]);
assign usescr = 
    (br_dep_pt[16] | br_dep_pt[18]
     | br_dep_pt[20] | br_dep_pt[45]
     | br_dep_pt[49] | br_dep_pt[51]
     | br_dep_pt[53] | br_dep_pt[55]
     | br_dep_pt[58] | br_dep_pt[62]
     | br_dep_pt[63] | br_dep_pt[80]
     | br_dep_pt[94]);
assign usesctr = 
    (br_dep_pt[7] | br_dep_pt[12]
     | br_dep_pt[14] | br_dep_pt[19]
     | br_dep_pt[24] | br_dep_pt[25]
     | br_dep_pt[95]);
assign usesxer = 
    (br_dep_pt[2] | br_dep_pt[8]
     | br_dep_pt[11] | br_dep_pt[12]
     | br_dep_pt[13] | br_dep_pt[36]
     | br_dep_pt[37] | br_dep_pt[39]
     | br_dep_pt[41] | br_dep_pt[44]
     | br_dep_pt[47] | br_dep_pt[52]
     | br_dep_pt[57] | br_dep_pt[59]
     | br_dep_pt[60] | br_dep_pt[61]
     | br_dep_pt[64] | br_dep_pt[65]
     | br_dep_pt[67] | br_dep_pt[68]
     | br_dep_pt[70] | br_dep_pt[72]
     | br_dep_pt[74] | br_dep_pt[75]
     | br_dep_pt[76] | br_dep_pt[77]
     | br_dep_pt[78] | br_dep_pt[79]
     | br_dep_pt[82] | br_dep_pt[83]
     | br_dep_pt[84] | br_dep_pt[85]
     | br_dep_pt[86] | br_dep_pt[87]
     | br_dep_pt[88] | br_dep_pt[89]
     | br_dep_pt[90] | br_dep_pt[91]
     | br_dep_pt[92] | br_dep_pt[93]
     | br_dep_pt[96] | br_dep_pt[97]
     | br_dep_pt[99] | br_dep_pt[101]
     | br_dep_pt[102] | br_dep_pt[103]
     | br_dep_pt[104] | br_dep_pt[105]
     | br_dep_pt[106] | br_dep_pt[107]
    );
assign usestar = 
    (br_dep_pt[11] | br_dep_pt[38]
    );
assign usescr2 = 
    (br_dep_pt[49] | br_dep_pt[51]
     | br_dep_pt[53] | br_dep_pt[55]
     | br_dep_pt[58] | br_dep_pt[63]
    );
assign usescr_sel[0] = 
    (br_dep_pt[27] | br_dep_pt[80]
    );
assign usescr_sel[1] = 
    (br_dep_pt[24] | br_dep_pt[27]
     | br_dep_pt[38] | br_dep_pt[42]
     | br_dep_pt[49] | br_dep_pt[51]
     | br_dep_pt[53] | br_dep_pt[55]
     | br_dep_pt[58] | br_dep_pt[62]
     | br_dep_pt[63] | br_dep_pt[98]
    );
assign updatescr_sel[0] = 
    (br_dep_pt[28] | br_dep_pt[29]
     | br_dep_pt[30] | br_dep_pt[31]
     | br_dep_pt[32] | br_dep_pt[33]
     | br_dep_pt[34] | br_dep_pt[35]
     | br_dep_pt[47] | br_dep_pt[49]
     | br_dep_pt[51] | br_dep_pt[53]
     | br_dep_pt[55] | br_dep_pt[58]
     | br_dep_pt[62] | br_dep_pt[63]
     | br_dep_pt[75] | br_dep_pt[84]
     | br_dep_pt[104]);
assign updatescr_sel[1] = 
    (br_dep_pt[2] | br_dep_pt[11]
     | br_dep_pt[12] | br_dep_pt[13]
     | br_dep_pt[28] | br_dep_pt[29]
     | br_dep_pt[30] | br_dep_pt[31]
     | br_dep_pt[32] | br_dep_pt[33]
     | br_dep_pt[34] | br_dep_pt[35]
     | br_dep_pt[36]);

assign instruction_decoder_pt[1] =
    (({ iu4_fuse_val , iu4_fuse_cmp[0] , 
    iu4_fuse_cmp[1] , iu4_fuse_cmp[2] , 
    iu4_fuse_cmp[3] , iu4_fuse_cmp[4] , 
    iu4_fuse_cmp[5] , iu4_fuse_cmp[21] , 
    iu4_fuse_cmp[22] , iu4_fuse_cmp[23] , 
    iu4_fuse_cmp[24] , iu4_fuse_cmp[26] , 
    iu4_fuse_cmp[27] , iu4_fuse_cmp[28] , 
    iu4_fuse_cmp[29] , iu4_fuse_cmp[30]
     }) === 16'b1011111000000000);
assign instruction_decoder_pt[2] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b00000001000000000);
assign instruction_decoder_pt[3] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[10] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 18'b011111010010101100);
assign instruction_decoder_pt[4] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[9] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 18'b011111110010101100);
assign instruction_decoder_pt[5] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 17'b01111111011011010);
assign instruction_decoder_pt[6] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0100100000100000);
assign instruction_decoder_pt[7] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01001100100101100);
assign instruction_decoder_pt[8] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 18'b011111000100100000);
assign instruction_decoder_pt[9] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b10111111010010);
assign instruction_decoder_pt[10] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0100110001001100);
assign instruction_decoder_pt[11] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111111000100100);
assign instruction_decoder_pt[12] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 17'b01111101001011010);
assign instruction_decoder_pt[13] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[12] , iu4_instr[15] , 
    iu4_instr[21] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111100010100110);
assign instruction_decoder_pt[14] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111110000000000);
assign instruction_decoder_pt[15] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_fuse_val
     }) === 16'b0100110000110010);
assign instruction_decoder_pt[16] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 18'b011111000000100110);
assign instruction_decoder_pt[17] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 16'b0111110000001110);
assign instruction_decoder_pt[18] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111101011100110);
assign instruction_decoder_pt[19] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[8] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0100111000100000);
assign instruction_decoder_pt[20] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01111000101010);
assign instruction_decoder_pt[21] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0100110001100000);
assign instruction_decoder_pt[22] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111110101100);
assign instruction_decoder_pt[23] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[15] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110010010000);
assign instruction_decoder_pt[24] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[12] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110010010000);
assign instruction_decoder_pt[25] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[19] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110010010000);
assign instruction_decoder_pt[26] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[18] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110010010000);
assign instruction_decoder_pt[27] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[17] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110010010000);
assign instruction_decoder_pt[28] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[16] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110010010000);
assign instruction_decoder_pt[29] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[14] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110010010000);
assign instruction_decoder_pt[30] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[13] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110010010000);
assign instruction_decoder_pt[31] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111100101100110);
assign instruction_decoder_pt[32] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 14'b01110000100010);
assign instruction_decoder_pt[33] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111000101010);
assign instruction_decoder_pt[34] =
    (({ iu4_instr[0] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111100100100110);
assign instruction_decoder_pt[35] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_fuse_val
     }) === 16'b0111110110010110);
assign instruction_decoder_pt[36] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b010010101000010);
assign instruction_decoder_pt[37] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111100001111100);
assign instruction_decoder_pt[38] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01111000010000);
assign instruction_decoder_pt[39] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 14'b01110000101010);
assign instruction_decoder_pt[40] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01001100110001100);
assign instruction_decoder_pt[41] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[21] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b010010001000010);
assign instruction_decoder_pt[42] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b010010100000010);
assign instruction_decoder_pt[43] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b010010011000010);
assign instruction_decoder_pt[44] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[21] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b010010110000010);
assign instruction_decoder_pt[45] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[20] , iu4_instr[21] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111010100110);
assign instruction_decoder_pt[46] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[19] , iu4_instr[21] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111010100110);
assign instruction_decoder_pt[47] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[18] , iu4_instr[21] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111010100110);
assign instruction_decoder_pt[48] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[17] , iu4_instr[21] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111010100110);
assign instruction_decoder_pt[49] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[16] , iu4_instr[21] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111010100110);
assign instruction_decoder_pt[50] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[14] , iu4_instr[21] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111010100110);
assign instruction_decoder_pt[51] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[13] , iu4_instr[21] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111010100110);
assign instruction_decoder_pt[52] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01111000010100);
assign instruction_decoder_pt[53] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[21] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111010100110);
assign instruction_decoder_pt[54] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b010010010000010);
assign instruction_decoder_pt[55] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111110101100);
assign instruction_decoder_pt[56] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 18'b101111100111111000);
assign instruction_decoder_pt[57] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111111110100100);
assign instruction_decoder_pt[58] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b1011110000001000);
assign instruction_decoder_pt[59] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 13'b0111000011110);
assign instruction_decoder_pt[60] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111010000110);
assign instruction_decoder_pt[61] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01110110000110);
assign instruction_decoder_pt[62] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01110110000110);
assign instruction_decoder_pt[63] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111110001101100);
assign instruction_decoder_pt[64] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111100110011100);
assign instruction_decoder_pt[65] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110010100110);
assign instruction_decoder_pt[66] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111111101100);
assign instruction_decoder_pt[67] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111100111011100);
assign instruction_decoder_pt[68] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01110100000110);
assign instruction_decoder_pt[69] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01010000000000);
assign instruction_decoder_pt[70] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111010000110);
assign instruction_decoder_pt[71] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_fuse_val
     }) === 14'b01110100001110);
assign instruction_decoder_pt[72] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b1011111111010010);
assign instruction_decoder_pt[73] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111110100100);
assign instruction_decoder_pt[74] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110001000110);
assign instruction_decoder_pt[75] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 13'b0111000000110);
assign instruction_decoder_pt[76] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111010101100);
assign instruction_decoder_pt[77] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111111101100);
assign instruction_decoder_pt[78] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011110000000000);
assign instruction_decoder_pt[79] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111110101100);
assign instruction_decoder_pt[80] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[11] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011110000100110);
assign instruction_decoder_pt[81] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_instr[31] , 
    iu4_fuse_val }) === 17'b01111111001001010);
assign instruction_decoder_pt[82] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110000110100);
assign instruction_decoder_pt[83] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111101111001100);
assign instruction_decoder_pt[84] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b10111110101110110);
assign instruction_decoder_pt[85] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_fuse_val
     }) === 16'b0111110010010010);
assign instruction_decoder_pt[86] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111000010100);
assign instruction_decoder_pt[87] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111100111111110);
assign instruction_decoder_pt[88] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b10111110111110100);
assign instruction_decoder_pt[89] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 18'b011111101011011010);
assign instruction_decoder_pt[90] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111100010100110);
assign instruction_decoder_pt[91] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01110010010000);
assign instruction_decoder_pt[92] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111111001100);
assign instruction_decoder_pt[93] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 18'b011111001101010010);
assign instruction_decoder_pt[94] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_fuse_val }) === 15'b101111100111010);
assign instruction_decoder_pt[95] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b1011111100011000);
assign instruction_decoder_pt[96] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111111001100);
assign instruction_decoder_pt[97] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 18'b011111101101011010);
assign instruction_decoder_pt[98] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111100010011100);
assign instruction_decoder_pt[99] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111111010110);
assign instruction_decoder_pt[100] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111100111001100);
assign instruction_decoder_pt[101] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110010010100);
assign instruction_decoder_pt[102] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110110100110);
assign instruction_decoder_pt[103] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110000000110);
assign instruction_decoder_pt[104] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01110101100110);
assign instruction_decoder_pt[105] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b101111110110100);
assign instruction_decoder_pt[106] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110000101000);
assign instruction_decoder_pt[107] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_fuse_val }) === 11'b10111100110);
assign instruction_decoder_pt[108] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b10111110000110110);
assign instruction_decoder_pt[109] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111111111110);
assign instruction_decoder_pt[110] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 18'b101111100101011010);
assign instruction_decoder_pt[111] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111100111101100);
assign instruction_decoder_pt[112] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b1011111000010010);
assign instruction_decoder_pt[113] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b10111110101010110);
assign instruction_decoder_pt[114] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 12'b011110100100);
assign instruction_decoder_pt[115] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b1011111000110100);
assign instruction_decoder_pt[116] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111111001100110);
assign instruction_decoder_pt[117] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110100110100);
assign instruction_decoder_pt[118] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b1011110000110110);
assign instruction_decoder_pt[119] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011110000000000);
assign instruction_decoder_pt[120] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 18'b011111001001011010);
assign instruction_decoder_pt[121] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111000010110);
assign instruction_decoder_pt[122] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b10111111010010100);
assign instruction_decoder_pt[123] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01111000010000);
assign instruction_decoder_pt[124] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b10111111000010100);
assign instruction_decoder_pt[125] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111100000100100);
assign instruction_decoder_pt[126] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110000110100);
assign instruction_decoder_pt[127] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111100010101100);
assign instruction_decoder_pt[128] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111100100100);
assign instruction_decoder_pt[129] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110100111110);
assign instruction_decoder_pt[130] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b101110010110100);
assign instruction_decoder_pt[131] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110001111110);
assign instruction_decoder_pt[132] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01111100110000);
assign instruction_decoder_pt[133] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111001000110);
assign instruction_decoder_pt[134] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b01111100001100110);
assign instruction_decoder_pt[135] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011110001111000);
assign instruction_decoder_pt[136] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111000110000);
assign instruction_decoder_pt[137] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01111000010100);
assign instruction_decoder_pt[138] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[30] , 
    iu4_fuse_val }) === 17'b10111110010110110);
assign instruction_decoder_pt[139] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 13'b0111011010000);
assign instruction_decoder_pt[140] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111100101010);
assign instruction_decoder_pt[141] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110011110100);
assign instruction_decoder_pt[142] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011100100110100);
assign instruction_decoder_pt[143] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110010001100);
assign instruction_decoder_pt[144] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01111110110100);
assign instruction_decoder_pt[145] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[24] , 
    iu4_instr[25] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110110001100);
assign instruction_decoder_pt[146] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011110000011000);
assign instruction_decoder_pt[147] =
    (({ iu4_fuse_val , iu4_fuse_cmp[0] , 
    iu4_fuse_cmp[1] , iu4_fuse_cmp[2] , 
    iu4_fuse_cmp[3] , iu4_fuse_cmp[4]
     }) === 6'b100101);
assign instruction_decoder_pt[148] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b1011111001001110);
assign instruction_decoder_pt[149] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b1011111000001110);
assign instruction_decoder_pt[150] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[5] , iu4_fuse_val
     }) === 6'b101100);
assign instruction_decoder_pt[151] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01111011111000);
assign instruction_decoder_pt[152] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 8'b01000110);
assign instruction_decoder_pt[153] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b1011111000101000);
assign instruction_decoder_pt[154] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110001101000);
assign instruction_decoder_pt[155] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[21] , 
    iu4_instr[22] , iu4_instr[24] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01111010111000);
assign instruction_decoder_pt[156] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111100101100);
assign instruction_decoder_pt[157] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111111000101100);
assign instruction_decoder_pt[158] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_fuse_val }) === 7'b0101000);
assign instruction_decoder_pt[159] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b10111111101010);
assign instruction_decoder_pt[160] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111001101110);
assign instruction_decoder_pt[161] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110101101110);
assign instruction_decoder_pt[162] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 16'b0111110011101110);
assign instruction_decoder_pt[163] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 12'b011101101000);
assign instruction_decoder_pt[164] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_fuse_val }) === 15'b011111000010110);
assign instruction_decoder_pt[165] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 10'b1111010010);
assign instruction_decoder_pt[166] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[22] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[30] , 
    iu4_fuse_val }) === 13'b0111100001000);
assign instruction_decoder_pt[167] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[22] , iu4_instr[23] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 14'b01111111010110);
assign instruction_decoder_pt[168] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[24] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111010011110);
assign instruction_decoder_pt[169] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111001011110);
assign instruction_decoder_pt[170] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[22] , 
    iu4_instr[23] , iu4_instr[25] , 
    iu4_instr[26] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111000011110);
assign instruction_decoder_pt[171] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[21] , iu4_instr[23] , 
    iu4_instr[25] , iu4_instr[26] , 
    iu4_instr[27] , iu4_instr[28] , 
    iu4_instr[29] , iu4_instr[30] , 
    iu4_fuse_val }) === 15'b011111000101110);
assign instruction_decoder_pt[172] =
    (({ iu4_instr[0] , iu4_instr[2] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[10] , iu4_fuse_val
     }) === 6'b010010);
assign instruction_decoder_pt[173] =
    (({ iu4_instr[0] , iu4_instr[2] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[7] , iu4_fuse_val
     }) === 6'b010010);
assign instruction_decoder_pt[174] =
    (({ iu4_instr[0] , iu4_instr[2] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[6] , iu4_fuse_val
     }) === 6'b010010);
assign instruction_decoder_pt[175] =
    (({ iu4_instr[0] , iu4_instr[2] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[20] , iu4_fuse_val
     }) === 6'b010010);
assign instruction_decoder_pt[176] =
    (({ iu4_instr[0] , iu4_instr[2] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[9] , iu4_fuse_val
     }) === 6'b010010);
assign instruction_decoder_pt[177] =
    (({ iu4_instr[0] , iu4_instr[2] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[8] , iu4_fuse_val
     }) === 6'b010010);
assign instruction_decoder_pt[178] =
    (({ iu4_instr[0] , iu4_instr[2] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 6'b010010);
assign instruction_decoder_pt[179] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 10'b1111110000);
assign instruction_decoder_pt[180] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_fuse_val }) === 7'b0001110);
assign instruction_decoder_pt[181] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 8'b11101000);
assign instruction_decoder_pt[182] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_fuse_val }) === 11'b10111101000);
assign instruction_decoder_pt[183] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[3] , 
    iu4_instr[4] , iu4_fuse_val
     }) === 6'b100010);
assign instruction_decoder_pt[184] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_instr[26] , iu4_instr[27] , 
    iu4_instr[28] , iu4_instr[29] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 12'b011111011110);
assign instruction_decoder_pt[185] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_instr[30] , 
    iu4_instr[31] , iu4_fuse_val
     }) === 10'b1111110010);
assign instruction_decoder_pt[186] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[15] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[187] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[12] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[188] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[19] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[189] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[18] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[190] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[17] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[191] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[16] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[192] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[14] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[193] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[13] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[194] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[11] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[195] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[196] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[25] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[197] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[21] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[198] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[22] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[199] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[24] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[200] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[27] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[201] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[5] , iu4_fuse_val
     }) === 6'b010000);
assign instruction_decoder_pt[202] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[30] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[203] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[28] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[204] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[23] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[205] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[29] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[206] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[26] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[207] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[5] , iu4_fuse_val
     }) === 6'b100100);
assign instruction_decoder_pt[208] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_fuse_val
     }) === 6'b101000);
assign instruction_decoder_pt[209] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[5] , iu4_fuse_val
     }) === 6'b011010);
assign instruction_decoder_pt[210] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_fuse_val }) === 5'b10000);
assign instruction_decoder_pt[211] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_instr[5] , iu4_fuse_val
     }) === 6'b001000);
assign instruction_decoder_pt[212] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_fuse_val }) === 5'b00110);
assign instruction_decoder_pt[213] =
    (({ core64 , iu4_instr[0] , 
    iu4_instr[1] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_instr[27] , iu4_fuse_val
     }) === 8'b10111000);
assign instruction_decoder_pt[214] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[5] , 
    iu4_fuse_val }) === 5'b10010);
assign instruction_decoder_pt[215] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_fuse_val
     }) === 6'b101110);
assign instruction_decoder_pt[216] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[5] , iu4_fuse_val
     }) === 6'b100110);
assign instruction_decoder_pt[217] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_instr[5] , iu4_fuse_val
     }) === 6'b101010);
assign instruction_decoder_pt[218] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_fuse_val
     }) === 6'b001110);
assign instruction_decoder_pt[219] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[4] , 
    iu4_fuse_val }) === 5'b01100);
assign instruction_decoder_pt[220] =
    (({ iu4_instr[0] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_fuse_val }) === 5'b01010);
assign instruction_decoder_pt[221] =
    (({ iu4_instr[0] , iu4_instr[2] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_fuse_val }) === 5'b01100);
assign instruction_decoder_pt[222] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[2] , iu4_instr[3] , 
    iu4_instr[4] , iu4_instr[5] , 
    iu4_fuse_val }) === 7'b0101110);
assign instruction_decoder_pt[223] =
    (({ iu4_instr[0] , iu4_instr[1] , 
    iu4_instr[3] , iu4_instr[4] , 
    iu4_fuse_val }) === 5'b01100);
assign ta_vld = 
    (instruction_decoder_pt[16] | instruction_decoder_pt[20]
     | instruction_decoder_pt[31] | instruction_decoder_pt[34]
     | instruction_decoder_pt[56] | instruction_decoder_pt[59]
     | instruction_decoder_pt[72] | instruction_decoder_pt[80]
     | instruction_decoder_pt[84] | instruction_decoder_pt[88]
     | instruction_decoder_pt[90] | instruction_decoder_pt[93]
     | instruction_decoder_pt[94] | instruction_decoder_pt[95]
     | instruction_decoder_pt[98] | instruction_decoder_pt[99]
     | instruction_decoder_pt[101] | instruction_decoder_pt[103]
     | instruction_decoder_pt[104] | instruction_decoder_pt[105]
     | instruction_decoder_pt[106] | instruction_decoder_pt[108]
     | instruction_decoder_pt[112] | instruction_decoder_pt[113]
     | instruction_decoder_pt[115] | instruction_decoder_pt[117]
     | instruction_decoder_pt[118] | instruction_decoder_pt[121]
     | instruction_decoder_pt[123] | instruction_decoder_pt[124]
     | instruction_decoder_pt[126] | instruction_decoder_pt[130]
     | instruction_decoder_pt[132] | instruction_decoder_pt[135]
     | instruction_decoder_pt[136] | instruction_decoder_pt[137]
     | instruction_decoder_pt[138] | instruction_decoder_pt[139]
     | instruction_decoder_pt[141] | instruction_decoder_pt[142]
     | instruction_decoder_pt[144] | instruction_decoder_pt[146]
     | instruction_decoder_pt[149] | instruction_decoder_pt[150]
     | instruction_decoder_pt[151] | instruction_decoder_pt[153]
     | instruction_decoder_pt[154] | instruction_decoder_pt[155]
     | instruction_decoder_pt[157] | instruction_decoder_pt[159]
     | instruction_decoder_pt[160] | instruction_decoder_pt[161]
     | instruction_decoder_pt[162] | instruction_decoder_pt[163]
     | instruction_decoder_pt[165] | instruction_decoder_pt[166]
     | instruction_decoder_pt[167] | instruction_decoder_pt[170]
     | instruction_decoder_pt[171] | instruction_decoder_pt[172]
     | instruction_decoder_pt[173] | instruction_decoder_pt[174]
     | instruction_decoder_pt[175] | instruction_decoder_pt[176]
     | instruction_decoder_pt[177] | instruction_decoder_pt[178]
     | instruction_decoder_pt[180] | instruction_decoder_pt[181]
     | instruction_decoder_pt[182] | instruction_decoder_pt[184]
     | instruction_decoder_pt[185] | instruction_decoder_pt[186]
     | instruction_decoder_pt[187] | instruction_decoder_pt[188]
     | instruction_decoder_pt[189] | instruction_decoder_pt[190]
     | instruction_decoder_pt[191] | instruction_decoder_pt[192]
     | instruction_decoder_pt[193] | instruction_decoder_pt[194]
     | instruction_decoder_pt[195] | instruction_decoder_pt[196]
     | instruction_decoder_pt[197] | instruction_decoder_pt[198]
     | instruction_decoder_pt[199] | instruction_decoder_pt[200]
     | instruction_decoder_pt[202] | instruction_decoder_pt[203]
     | instruction_decoder_pt[204] | instruction_decoder_pt[205]
     | instruction_decoder_pt[206] | instruction_decoder_pt[209]
     | instruction_decoder_pt[210] | instruction_decoder_pt[211]
     | instruction_decoder_pt[213] | instruction_decoder_pt[214]
     | instruction_decoder_pt[216] | instruction_decoder_pt[217]
     | instruction_decoder_pt[218] | instruction_decoder_pt[221]
     | instruction_decoder_pt[222] | instruction_decoder_pt[223]
    );
assign ta_sel = 
    (instruction_decoder_pt[56] | instruction_decoder_pt[88]
     | instruction_decoder_pt[94] | instruction_decoder_pt[95]
     | instruction_decoder_pt[98] | instruction_decoder_pt[105]
     | instruction_decoder_pt[115] | instruction_decoder_pt[117]
     | instruction_decoder_pt[118] | instruction_decoder_pt[126]
     | instruction_decoder_pt[130] | instruction_decoder_pt[132]
     | instruction_decoder_pt[135] | instruction_decoder_pt[136]
     | instruction_decoder_pt[138] | instruction_decoder_pt[141]
     | instruction_decoder_pt[142] | instruction_decoder_pt[144]
     | instruction_decoder_pt[146] | instruction_decoder_pt[151]
     | instruction_decoder_pt[155] | instruction_decoder_pt[161]
     | instruction_decoder_pt[162] | instruction_decoder_pt[182]
     | instruction_decoder_pt[185] | instruction_decoder_pt[213]
     | instruction_decoder_pt[216] | instruction_decoder_pt[217]
     | instruction_decoder_pt[219] | instruction_decoder_pt[220]
     | instruction_decoder_pt[222] | instruction_decoder_pt[223]
    );
assign s1_vld = 
    (instruction_decoder_pt[1] | instruction_decoder_pt[8]
     | instruction_decoder_pt[23] | instruction_decoder_pt[24]
     | instruction_decoder_pt[25] | instruction_decoder_pt[26]
     | instruction_decoder_pt[27] | instruction_decoder_pt[28]
     | instruction_decoder_pt[29] | instruction_decoder_pt[30]
     | instruction_decoder_pt[55] | instruction_decoder_pt[56]
     | instruction_decoder_pt[58] | instruction_decoder_pt[61]
     | instruction_decoder_pt[62] | instruction_decoder_pt[66]
     | instruction_decoder_pt[68] | instruction_decoder_pt[72]
     | instruction_decoder_pt[75] | instruction_decoder_pt[78]
     | instruction_decoder_pt[79] | instruction_decoder_pt[81]
     | instruction_decoder_pt[83] | instruction_decoder_pt[84]
     | instruction_decoder_pt[85] | instruction_decoder_pt[86]
     | instruction_decoder_pt[87] | instruction_decoder_pt[88]
     | instruction_decoder_pt[89] | instruction_decoder_pt[93]
     | instruction_decoder_pt[94] | instruction_decoder_pt[95]
     | instruction_decoder_pt[97] | instruction_decoder_pt[98]
     | instruction_decoder_pt[99] | instruction_decoder_pt[100]
     | instruction_decoder_pt[101] | instruction_decoder_pt[102]
     | instruction_decoder_pt[105] | instruction_decoder_pt[108]
     | instruction_decoder_pt[109] | instruction_decoder_pt[110]
     | instruction_decoder_pt[111] | instruction_decoder_pt[112]
     | instruction_decoder_pt[113] | instruction_decoder_pt[115]
     | instruction_decoder_pt[116] | instruction_decoder_pt[117]
     | instruction_decoder_pt[118] | instruction_decoder_pt[119]
     | instruction_decoder_pt[120] | instruction_decoder_pt[121]
     | instruction_decoder_pt[122] | instruction_decoder_pt[123]
     | instruction_decoder_pt[124] | instruction_decoder_pt[125]
     | instruction_decoder_pt[126] | instruction_decoder_pt[127]
     | instruction_decoder_pt[128] | instruction_decoder_pt[129]
     | instruction_decoder_pt[130] | instruction_decoder_pt[131]
     | instruction_decoder_pt[132] | instruction_decoder_pt[134]
     | instruction_decoder_pt[135] | instruction_decoder_pt[136]
     | instruction_decoder_pt[137] | instruction_decoder_pt[138]
     | instruction_decoder_pt[139] | instruction_decoder_pt[140]
     | instruction_decoder_pt[141] | instruction_decoder_pt[142]
     | instruction_decoder_pt[143] | instruction_decoder_pt[144]
     | instruction_decoder_pt[145] | instruction_decoder_pt[146]
     | instruction_decoder_pt[147] | instruction_decoder_pt[148]
     | instruction_decoder_pt[149] | instruction_decoder_pt[151]
     | instruction_decoder_pt[153] | instruction_decoder_pt[154]
     | instruction_decoder_pt[155] | instruction_decoder_pt[156]
     | instruction_decoder_pt[157] | instruction_decoder_pt[159]
     | instruction_decoder_pt[160] | instruction_decoder_pt[161]
     | instruction_decoder_pt[162] | instruction_decoder_pt[163]
     | instruction_decoder_pt[164] | instruction_decoder_pt[165]
     | instruction_decoder_pt[166] | instruction_decoder_pt[167]
     | instruction_decoder_pt[168] | instruction_decoder_pt[169]
     | instruction_decoder_pt[170] | instruction_decoder_pt[171]
     | instruction_decoder_pt[172] | instruction_decoder_pt[173]
     | instruction_decoder_pt[174] | instruction_decoder_pt[175]
     | instruction_decoder_pt[176] | instruction_decoder_pt[177]
     | instruction_decoder_pt[178] | instruction_decoder_pt[179]
     | instruction_decoder_pt[181] | instruction_decoder_pt[182]
     | instruction_decoder_pt[183] | instruction_decoder_pt[184]
     | instruction_decoder_pt[185] | instruction_decoder_pt[186]
     | instruction_decoder_pt[187] | instruction_decoder_pt[188]
     | instruction_decoder_pt[189] | instruction_decoder_pt[190]
     | instruction_decoder_pt[191] | instruction_decoder_pt[192]
     | instruction_decoder_pt[193] | instruction_decoder_pt[194]
     | instruction_decoder_pt[196] | instruction_decoder_pt[197]
     | instruction_decoder_pt[198] | instruction_decoder_pt[199]
     | instruction_decoder_pt[200] | instruction_decoder_pt[202]
     | instruction_decoder_pt[203] | instruction_decoder_pt[204]
     | instruction_decoder_pt[205] | instruction_decoder_pt[206]
     | instruction_decoder_pt[207] | instruction_decoder_pt[208]
     | instruction_decoder_pt[209] | instruction_decoder_pt[210]
     | instruction_decoder_pt[211] | instruction_decoder_pt[212]
     | instruction_decoder_pt[213] | instruction_decoder_pt[214]
     | instruction_decoder_pt[215] | instruction_decoder_pt[216]
     | instruction_decoder_pt[217] | instruction_decoder_pt[218]
     | instruction_decoder_pt[220] | instruction_decoder_pt[221]
     | instruction_decoder_pt[222] | instruction_decoder_pt[223]
    );
assign s1_sel = 
    (instruction_decoder_pt[56] | instruction_decoder_pt[61]
     | instruction_decoder_pt[62] | instruction_decoder_pt[68]
     | instruction_decoder_pt[88] | instruction_decoder_pt[91]
     | instruction_decoder_pt[94] | instruction_decoder_pt[95]
     | instruction_decoder_pt[98] | instruction_decoder_pt[102]
     | instruction_decoder_pt[105] | instruction_decoder_pt[115]
     | instruction_decoder_pt[117] | instruction_decoder_pt[118]
     | instruction_decoder_pt[126] | instruction_decoder_pt[130]
     | instruction_decoder_pt[132] | instruction_decoder_pt[135]
     | instruction_decoder_pt[136] | instruction_decoder_pt[141]
     | instruction_decoder_pt[142] | instruction_decoder_pt[144]
     | instruction_decoder_pt[146] | instruction_decoder_pt[151]
     | instruction_decoder_pt[155] | instruction_decoder_pt[182]
     | instruction_decoder_pt[195] | instruction_decoder_pt[213]
     | instruction_decoder_pt[219] | instruction_decoder_pt[222]
     | instruction_decoder_pt[223]);
assign s2_vld = 
    (instruction_decoder_pt[1] | instruction_decoder_pt[31]
     | instruction_decoder_pt[33] | instruction_decoder_pt[55]
     | instruction_decoder_pt[56] | instruction_decoder_pt[58]
     | instruction_decoder_pt[64] | instruction_decoder_pt[65]
     | instruction_decoder_pt[66] | instruction_decoder_pt[67]
     | instruction_decoder_pt[70] | instruction_decoder_pt[72]
     | instruction_decoder_pt[78] | instruction_decoder_pt[79]
     | instruction_decoder_pt[81] | instruction_decoder_pt[83]
     | instruction_decoder_pt[84] | instruction_decoder_pt[86]
     | instruction_decoder_pt[87] | instruction_decoder_pt[89]
     | instruction_decoder_pt[93] | instruction_decoder_pt[95]
     | instruction_decoder_pt[97] | instruction_decoder_pt[98]
     | instruction_decoder_pt[99] | instruction_decoder_pt[100]
     | instruction_decoder_pt[101] | instruction_decoder_pt[107]
     | instruction_decoder_pt[108] | instruction_decoder_pt[109]
     | instruction_decoder_pt[110] | instruction_decoder_pt[111]
     | instruction_decoder_pt[112] | instruction_decoder_pt[113]
     | instruction_decoder_pt[116] | instruction_decoder_pt[118]
     | instruction_decoder_pt[119] | instruction_decoder_pt[120]
     | instruction_decoder_pt[121] | instruction_decoder_pt[122]
     | instruction_decoder_pt[123] | instruction_decoder_pt[124]
     | instruction_decoder_pt[125] | instruction_decoder_pt[127]
     | instruction_decoder_pt[128] | instruction_decoder_pt[129]
     | instruction_decoder_pt[131] | instruction_decoder_pt[134]
     | instruction_decoder_pt[135] | instruction_decoder_pt[136]
     | instruction_decoder_pt[137] | instruction_decoder_pt[138]
     | instruction_decoder_pt[143] | instruction_decoder_pt[145]
     | instruction_decoder_pt[146] | instruction_decoder_pt[148]
     | instruction_decoder_pt[149] | instruction_decoder_pt[151]
     | instruction_decoder_pt[153] | instruction_decoder_pt[154]
     | instruction_decoder_pt[155] | instruction_decoder_pt[156]
     | instruction_decoder_pt[157] | instruction_decoder_pt[158]
     | instruction_decoder_pt[159] | instruction_decoder_pt[160]
     | instruction_decoder_pt[161] | instruction_decoder_pt[162]
     | instruction_decoder_pt[164] | instruction_decoder_pt[166]
     | instruction_decoder_pt[167] | instruction_decoder_pt[168]
     | instruction_decoder_pt[169] | instruction_decoder_pt[170]
     | instruction_decoder_pt[171] | instruction_decoder_pt[182]
     | instruction_decoder_pt[184] | instruction_decoder_pt[222]
    );
assign s2_sel = 
    (instruction_decoder_pt[31] | instruction_decoder_pt[70]
     | instruction_decoder_pt[102] | instruction_decoder_pt[213]
     | instruction_decoder_pt[223]);
assign s3_vld = 
    (instruction_decoder_pt[22] | instruction_decoder_pt[35]
     | instruction_decoder_pt[74] | instruction_decoder_pt[89]
     | instruction_decoder_pt[97] | instruction_decoder_pt[110]
     | instruction_decoder_pt[116] | instruction_decoder_pt[120]
     | instruction_decoder_pt[122] | instruction_decoder_pt[138]
     | instruction_decoder_pt[148] | instruction_decoder_pt[156]
     | instruction_decoder_pt[161] | instruction_decoder_pt[162]
     | instruction_decoder_pt[168] | instruction_decoder_pt[169]
     | instruction_decoder_pt[179] | instruction_decoder_pt[185]
     | instruction_decoder_pt[207] | instruction_decoder_pt[208]
     | instruction_decoder_pt[216] | instruction_decoder_pt[217]
    );
assign issue_lq = 
    (instruction_decoder_pt[63] | instruction_decoder_pt[64]
     | instruction_decoder_pt[74] | instruction_decoder_pt[76]
     | instruction_decoder_pt[77] | instruction_decoder_pt[82]
     | instruction_decoder_pt[83] | instruction_decoder_pt[84]
     | instruction_decoder_pt[87] | instruction_decoder_pt[89]
     | instruction_decoder_pt[92] | instruction_decoder_pt[93]
     | instruction_decoder_pt[96] | instruction_decoder_pt[97]
     | instruction_decoder_pt[100] | instruction_decoder_pt[103]
     | instruction_decoder_pt[106] | instruction_decoder_pt[108]
     | instruction_decoder_pt[109] | instruction_decoder_pt[110]
     | instruction_decoder_pt[111] | instruction_decoder_pt[113]
     | instruction_decoder_pt[120] | instruction_decoder_pt[122]
     | instruction_decoder_pt[124] | instruction_decoder_pt[127]
     | instruction_decoder_pt[129] | instruction_decoder_pt[131]
     | instruction_decoder_pt[138] | instruction_decoder_pt[140]
     | instruction_decoder_pt[143] | instruction_decoder_pt[145]
     | instruction_decoder_pt[148] | instruction_decoder_pt[149]
     | instruction_decoder_pt[153] | instruction_decoder_pt[154]
     | instruction_decoder_pt[156] | instruction_decoder_pt[157]
     | instruction_decoder_pt[160] | instruction_decoder_pt[161]
     | instruction_decoder_pt[162] | instruction_decoder_pt[164]
     | instruction_decoder_pt[165] | instruction_decoder_pt[168]
     | instruction_decoder_pt[169] | instruction_decoder_pt[170]
     | instruction_decoder_pt[171] | instruction_decoder_pt[179]
     | instruction_decoder_pt[181] | instruction_decoder_pt[185]
     | instruction_decoder_pt[207] | instruction_decoder_pt[208]
     | instruction_decoder_pt[210] | instruction_decoder_pt[214]
     | instruction_decoder_pt[215] | instruction_decoder_pt[216]
     | instruction_decoder_pt[217]);
assign issue_sq = 
    (instruction_decoder_pt[33] | instruction_decoder_pt[55]
     | instruction_decoder_pt[63] | instruction_decoder_pt[64]
     | instruction_decoder_pt[76] | instruction_decoder_pt[77]
     | instruction_decoder_pt[82] | instruction_decoder_pt[89]
     | instruction_decoder_pt[92] | instruction_decoder_pt[97]
     | instruction_decoder_pt[100] | instruction_decoder_pt[109]
     | instruction_decoder_pt[110] | instruction_decoder_pt[120]
     | instruction_decoder_pt[122] | instruction_decoder_pt[127]
     | instruction_decoder_pt[131] | instruction_decoder_pt[138]
     | instruction_decoder_pt[145] | instruction_decoder_pt[148]
     | instruction_decoder_pt[156] | instruction_decoder_pt[161]
     | instruction_decoder_pt[162] | instruction_decoder_pt[168]
     | instruction_decoder_pt[169] | instruction_decoder_pt[179]
     | instruction_decoder_pt[185] | instruction_decoder_pt[207]
     | instruction_decoder_pt[208] | instruction_decoder_pt[216]
     | instruction_decoder_pt[217]);
assign issue_fx0 = 
    (instruction_decoder_pt[1] | instruction_decoder_pt[2]
     | instruction_decoder_pt[19] | instruction_decoder_pt[21]
     | instruction_decoder_pt[23] | instruction_decoder_pt[24]
     | instruction_decoder_pt[25] | instruction_decoder_pt[26]
     | instruction_decoder_pt[27] | instruction_decoder_pt[28]
     | instruction_decoder_pt[29] | instruction_decoder_pt[30]
     | instruction_decoder_pt[36] | instruction_decoder_pt[37]
     | instruction_decoder_pt[40] | instruction_decoder_pt[41]
     | instruction_decoder_pt[42] | instruction_decoder_pt[43]
     | instruction_decoder_pt[44] | instruction_decoder_pt[54]
     | instruction_decoder_pt[56] | instruction_decoder_pt[57]
     | instruction_decoder_pt[58] | instruction_decoder_pt[67]
     | instruction_decoder_pt[69] | instruction_decoder_pt[71]
     | instruction_decoder_pt[72] | instruction_decoder_pt[73]
     | instruction_decoder_pt[78] | instruction_decoder_pt[80]
     | instruction_decoder_pt[81] | instruction_decoder_pt[85]
     | instruction_decoder_pt[88] | instruction_decoder_pt[90]
     | instruction_decoder_pt[94] | instruction_decoder_pt[95]
     | instruction_decoder_pt[98] | instruction_decoder_pt[99]
     | instruction_decoder_pt[101] | instruction_decoder_pt[102]
     | instruction_decoder_pt[104] | instruction_decoder_pt[105]
     | instruction_decoder_pt[112] | instruction_decoder_pt[115]
     | instruction_decoder_pt[116] | instruction_decoder_pt[117]
     | instruction_decoder_pt[118] | instruction_decoder_pt[119]
     | instruction_decoder_pt[121] | instruction_decoder_pt[123]
     | instruction_decoder_pt[125] | instruction_decoder_pt[126]
     | instruction_decoder_pt[128] | instruction_decoder_pt[130]
     | instruction_decoder_pt[132] | instruction_decoder_pt[133]
     | instruction_decoder_pt[134] | instruction_decoder_pt[135]
     | instruction_decoder_pt[136] | instruction_decoder_pt[137]
     | instruction_decoder_pt[139] | instruction_decoder_pt[141]
     | instruction_decoder_pt[142] | instruction_decoder_pt[144]
     | instruction_decoder_pt[146] | instruction_decoder_pt[147]
     | instruction_decoder_pt[151] | instruction_decoder_pt[155]
     | instruction_decoder_pt[159] | instruction_decoder_pt[163]
     | instruction_decoder_pt[166] | instruction_decoder_pt[167]
     | instruction_decoder_pt[182] | instruction_decoder_pt[183]
     | instruction_decoder_pt[184] | instruction_decoder_pt[201]
     | instruction_decoder_pt[211] | instruction_decoder_pt[212]
     | instruction_decoder_pt[213] | instruction_decoder_pt[218]
     | instruction_decoder_pt[219] | instruction_decoder_pt[220]
     | instruction_decoder_pt[221] | instruction_decoder_pt[222]
     | instruction_decoder_pt[223]);
assign issue_fx1 = 
    (instruction_decoder_pt[22] | instruction_decoder_pt[33]
     | instruction_decoder_pt[35] | instruction_decoder_pt[89]
     | instruction_decoder_pt[94] | instruction_decoder_pt[95]
     | instruction_decoder_pt[97] | instruction_decoder_pt[105]
     | instruction_decoder_pt[110] | instruction_decoder_pt[118]
     | instruction_decoder_pt[119] | instruction_decoder_pt[120]
     | instruction_decoder_pt[122] | instruction_decoder_pt[123]
     | instruction_decoder_pt[130] | instruction_decoder_pt[132]
     | instruction_decoder_pt[135] | instruction_decoder_pt[136]
     | instruction_decoder_pt[137] | instruction_decoder_pt[138]
     | instruction_decoder_pt[139] | instruction_decoder_pt[142]
     | instruction_decoder_pt[144] | instruction_decoder_pt[146]
     | instruction_decoder_pt[148] | instruction_decoder_pt[151]
     | instruction_decoder_pt[155] | instruction_decoder_pt[156]
     | instruction_decoder_pt[161] | instruction_decoder_pt[162]
     | instruction_decoder_pt[163] | instruction_decoder_pt[166]
     | instruction_decoder_pt[168] | instruction_decoder_pt[169]
     | instruction_decoder_pt[179] | instruction_decoder_pt[182]
     | instruction_decoder_pt[184] | instruction_decoder_pt[185]
     | instruction_decoder_pt[207] | instruction_decoder_pt[208]
     | instruction_decoder_pt[211] | instruction_decoder_pt[213]
     | instruction_decoder_pt[216] | instruction_decoder_pt[217]
     | instruction_decoder_pt[218] | instruction_decoder_pt[219]
     | instruction_decoder_pt[220] | instruction_decoder_pt[221]
     | instruction_decoder_pt[222] | instruction_decoder_pt[223]
    );
assign latency[0] = 
    1'b0;
assign latency[1] = 
    (instruction_decoder_pt[2] | instruction_decoder_pt[13]
     | instruction_decoder_pt[17] | instruction_decoder_pt[18]
     | instruction_decoder_pt[40] | instruction_decoder_pt[45]
     | instruction_decoder_pt[46] | instruction_decoder_pt[47]
     | instruction_decoder_pt[48] | instruction_decoder_pt[49]
     | instruction_decoder_pt[50] | instruction_decoder_pt[51]
     | instruction_decoder_pt[53] | instruction_decoder_pt[57]
     | instruction_decoder_pt[65] | instruction_decoder_pt[67]
     | instruction_decoder_pt[72] | instruction_decoder_pt[73]
     | instruction_decoder_pt[81] | instruction_decoder_pt[85]
     | instruction_decoder_pt[88] | instruction_decoder_pt[89]
     | instruction_decoder_pt[90] | instruction_decoder_pt[93]
     | instruction_decoder_pt[97] | instruction_decoder_pt[99]
     | instruction_decoder_pt[103] | instruction_decoder_pt[106]
     | instruction_decoder_pt[110] | instruction_decoder_pt[112]
     | instruction_decoder_pt[116] | instruction_decoder_pt[120]
     | instruction_decoder_pt[121] | instruction_decoder_pt[125]
     | instruction_decoder_pt[128] | instruction_decoder_pt[133]
     | instruction_decoder_pt[134] | instruction_decoder_pt[141]
     | instruction_decoder_pt[153] | instruction_decoder_pt[154]
     | instruction_decoder_pt[159] | instruction_decoder_pt[167]
     | instruction_decoder_pt[180]);
assign latency[2] = 
    (instruction_decoder_pt[1] | instruction_decoder_pt[2]
     | instruction_decoder_pt[6] | instruction_decoder_pt[13]
     | instruction_decoder_pt[18] | instruction_decoder_pt[19]
     | instruction_decoder_pt[21] | instruction_decoder_pt[36]
     | instruction_decoder_pt[40] | instruction_decoder_pt[41]
     | instruction_decoder_pt[42] | instruction_decoder_pt[43]
     | instruction_decoder_pt[44] | instruction_decoder_pt[45]
     | instruction_decoder_pt[46] | instruction_decoder_pt[47]
     | instruction_decoder_pt[48] | instruction_decoder_pt[49]
     | instruction_decoder_pt[50] | instruction_decoder_pt[51]
     | instruction_decoder_pt[53] | instruction_decoder_pt[54]
     | instruction_decoder_pt[56] | instruction_decoder_pt[57]
     | instruction_decoder_pt[63] | instruction_decoder_pt[64]
     | instruction_decoder_pt[65] | instruction_decoder_pt[67]
     | instruction_decoder_pt[72] | instruction_decoder_pt[73]
     | instruction_decoder_pt[74] | instruction_decoder_pt[76]
     | instruction_decoder_pt[77] | instruction_decoder_pt[81]
     | instruction_decoder_pt[82] | instruction_decoder_pt[83]
     | instruction_decoder_pt[84] | instruction_decoder_pt[85]
     | instruction_decoder_pt[87] | instruction_decoder_pt[88]
     | instruction_decoder_pt[89] | instruction_decoder_pt[90]
     | instruction_decoder_pt[92] | instruction_decoder_pt[93]
     | instruction_decoder_pt[96] | instruction_decoder_pt[97]
     | instruction_decoder_pt[100] | instruction_decoder_pt[101]
     | instruction_decoder_pt[103] | instruction_decoder_pt[106]
     | instruction_decoder_pt[108] | instruction_decoder_pt[109]
     | instruction_decoder_pt[110] | instruction_decoder_pt[111]
     | instruction_decoder_pt[112] | instruction_decoder_pt[113]
     | instruction_decoder_pt[115] | instruction_decoder_pt[116]
     | instruction_decoder_pt[117] | instruction_decoder_pt[120]
     | instruction_decoder_pt[122] | instruction_decoder_pt[124]
     | instruction_decoder_pt[125] | instruction_decoder_pt[126]
     | instruction_decoder_pt[127] | instruction_decoder_pt[128]
     | instruction_decoder_pt[129] | instruction_decoder_pt[131]
     | instruction_decoder_pt[133] | instruction_decoder_pt[134]
     | instruction_decoder_pt[138] | instruction_decoder_pt[140]
     | instruction_decoder_pt[141] | instruction_decoder_pt[143]
     | instruction_decoder_pt[145] | instruction_decoder_pt[147]
     | instruction_decoder_pt[148] | instruction_decoder_pt[149]
     | instruction_decoder_pt[153] | instruction_decoder_pt[154]
     | instruction_decoder_pt[156] | instruction_decoder_pt[157]
     | instruction_decoder_pt[159] | instruction_decoder_pt[160]
     | instruction_decoder_pt[161] | instruction_decoder_pt[162]
     | instruction_decoder_pt[164] | instruction_decoder_pt[165]
     | instruction_decoder_pt[167] | instruction_decoder_pt[168]
     | instruction_decoder_pt[169] | instruction_decoder_pt[170]
     | instruction_decoder_pt[171] | instruction_decoder_pt[179]
     | instruction_decoder_pt[181] | instruction_decoder_pt[185]
     | instruction_decoder_pt[201] | instruction_decoder_pt[207]
     | instruction_decoder_pt[208] | instruction_decoder_pt[210]
     | instruction_decoder_pt[214] | instruction_decoder_pt[215]
     | instruction_decoder_pt[216] | instruction_decoder_pt[217]
    );
assign latency[3] = 
    (instruction_decoder_pt[1] | instruction_decoder_pt[9]
     | instruction_decoder_pt[19] | instruction_decoder_pt[21]
     | instruction_decoder_pt[32] | instruction_decoder_pt[36]
     | instruction_decoder_pt[38] | instruction_decoder_pt[39]
     | instruction_decoder_pt[40] | instruction_decoder_pt[41]
     | instruction_decoder_pt[42] | instruction_decoder_pt[43]
     | instruction_decoder_pt[44] | instruction_decoder_pt[52]
     | instruction_decoder_pt[54] | instruction_decoder_pt[63]
     | instruction_decoder_pt[64] | instruction_decoder_pt[67]
     | instruction_decoder_pt[69] | instruction_decoder_pt[71]
     | instruction_decoder_pt[74] | instruction_decoder_pt[76]
     | instruction_decoder_pt[77] | instruction_decoder_pt[80]
     | instruction_decoder_pt[82] | instruction_decoder_pt[83]
     | instruction_decoder_pt[84] | instruction_decoder_pt[87]
     | instruction_decoder_pt[88] | instruction_decoder_pt[89]
     | instruction_decoder_pt[90] | instruction_decoder_pt[91]
     | instruction_decoder_pt[92] | instruction_decoder_pt[93]
     | instruction_decoder_pt[94] | instruction_decoder_pt[95]
     | instruction_decoder_pt[96] | instruction_decoder_pt[97]
     | instruction_decoder_pt[98] | instruction_decoder_pt[100]
     | instruction_decoder_pt[102] | instruction_decoder_pt[103]
     | instruction_decoder_pt[104] | instruction_decoder_pt[105]
     | instruction_decoder_pt[106] | instruction_decoder_pt[108]
     | instruction_decoder_pt[109] | instruction_decoder_pt[110]
     | instruction_decoder_pt[111] | instruction_decoder_pt[112]
     | instruction_decoder_pt[113] | instruction_decoder_pt[116]
     | instruction_decoder_pt[118] | instruction_decoder_pt[119]
     | instruction_decoder_pt[120] | instruction_decoder_pt[122]
     | instruction_decoder_pt[124] | instruction_decoder_pt[127]
     | instruction_decoder_pt[129] | instruction_decoder_pt[130]
     | instruction_decoder_pt[131] | instruction_decoder_pt[132]
     | instruction_decoder_pt[133] | instruction_decoder_pt[134]
     | instruction_decoder_pt[135] | instruction_decoder_pt[136]
     | instruction_decoder_pt[138] | instruction_decoder_pt[139]
     | instruction_decoder_pt[140] | instruction_decoder_pt[141]
     | instruction_decoder_pt[142] | instruction_decoder_pt[143]
     | instruction_decoder_pt[144] | instruction_decoder_pt[145]
     | instruction_decoder_pt[146] | instruction_decoder_pt[147]
     | instruction_decoder_pt[148] | instruction_decoder_pt[149]
     | instruction_decoder_pt[151] | instruction_decoder_pt[153]
     | instruction_decoder_pt[154] | instruction_decoder_pt[155]
     | instruction_decoder_pt[156] | instruction_decoder_pt[157]
     | instruction_decoder_pt[159] | instruction_decoder_pt[160]
     | instruction_decoder_pt[161] | instruction_decoder_pt[162]
     | instruction_decoder_pt[163] | instruction_decoder_pt[164]
     | instruction_decoder_pt[165] | instruction_decoder_pt[166]
     | instruction_decoder_pt[167] | instruction_decoder_pt[168]
     | instruction_decoder_pt[169] | instruction_decoder_pt[170]
     | instruction_decoder_pt[171] | instruction_decoder_pt[179]
     | instruction_decoder_pt[180] | instruction_decoder_pt[181]
     | instruction_decoder_pt[182] | instruction_decoder_pt[184]
     | instruction_decoder_pt[185] | instruction_decoder_pt[201]
     | instruction_decoder_pt[207] | instruction_decoder_pt[208]
     | instruction_decoder_pt[210] | instruction_decoder_pt[211]
     | instruction_decoder_pt[213] | instruction_decoder_pt[214]
     | instruction_decoder_pt[215] | instruction_decoder_pt[216]
     | instruction_decoder_pt[217] | instruction_decoder_pt[219]
     | instruction_decoder_pt[220] | instruction_decoder_pt[221]
     | instruction_decoder_pt[222] | instruction_decoder_pt[223]
    );
assign ordered = 
    (instruction_decoder_pt[10] | instruction_decoder_pt[13]
     | instruction_decoder_pt[15] | instruction_decoder_pt[18]
     | instruction_decoder_pt[37] | instruction_decoder_pt[40]
     | instruction_decoder_pt[45] | instruction_decoder_pt[46]
     | instruction_decoder_pt[47] | instruction_decoder_pt[48]
     | instruction_decoder_pt[49] | instruction_decoder_pt[50]
     | instruction_decoder_pt[51] | instruction_decoder_pt[53]
     | instruction_decoder_pt[57] | instruction_decoder_pt[60]
     | instruction_decoder_pt[65] | instruction_decoder_pt[67]
     | instruction_decoder_pt[70] | instruction_decoder_pt[73]
     | instruction_decoder_pt[81] | instruction_decoder_pt[85]
     | instruction_decoder_pt[90] | instruction_decoder_pt[116]
     | instruction_decoder_pt[125] | instruction_decoder_pt[128]
     | instruction_decoder_pt[133] | instruction_decoder_pt[134]
     | instruction_decoder_pt[152] | instruction_decoder_pt[159]
     | instruction_decoder_pt[167]);
assign spec = 
    (instruction_decoder_pt[77] | instruction_decoder_pt[79]
     | instruction_decoder_pt[83] | instruction_decoder_pt[84]
     | instruction_decoder_pt[86] | instruction_decoder_pt[87]
     | instruction_decoder_pt[89] | instruction_decoder_pt[93]
     | instruction_decoder_pt[96] | instruction_decoder_pt[97]
     | instruction_decoder_pt[100] | instruction_decoder_pt[108]
     | instruction_decoder_pt[109] | instruction_decoder_pt[110]
     | instruction_decoder_pt[111] | instruction_decoder_pt[113]
     | instruction_decoder_pt[120] | instruction_decoder_pt[122]
     | instruction_decoder_pt[124] | instruction_decoder_pt[127]
     | instruction_decoder_pt[129] | instruction_decoder_pt[131]
     | instruction_decoder_pt[138] | instruction_decoder_pt[140]
     | instruction_decoder_pt[143] | instruction_decoder_pt[145]
     | instruction_decoder_pt[148] | instruction_decoder_pt[149]
     | instruction_decoder_pt[153] | instruction_decoder_pt[154]
     | instruction_decoder_pt[156] | instruction_decoder_pt[157]
     | instruction_decoder_pt[160] | instruction_decoder_pt[161]
     | instruction_decoder_pt[162] | instruction_decoder_pt[164]
     | instruction_decoder_pt[165] | instruction_decoder_pt[168]
     | instruction_decoder_pt[169] | instruction_decoder_pt[170]
     | instruction_decoder_pt[171] | instruction_decoder_pt[179]
     | instruction_decoder_pt[181] | instruction_decoder_pt[185]
     | instruction_decoder_pt[207] | instruction_decoder_pt[208]
     | instruction_decoder_pt[210] | instruction_decoder_pt[214]
     | instruction_decoder_pt[215] | instruction_decoder_pt[216]
     | instruction_decoder_pt[217]);
assign isload = 
    (instruction_decoder_pt[83] | instruction_decoder_pt[87]
     | instruction_decoder_pt[93] | instruction_decoder_pt[106]
     | instruction_decoder_pt[111] | instruction_decoder_pt[113]
     | instruction_decoder_pt[124] | instruction_decoder_pt[129]
     | instruction_decoder_pt[143] | instruction_decoder_pt[149]
     | instruction_decoder_pt[150] | instruction_decoder_pt[153]
     | instruction_decoder_pt[154] | instruction_decoder_pt[157]
     | instruction_decoder_pt[164] | instruction_decoder_pt[170]
     | instruction_decoder_pt[171] | instruction_decoder_pt[181]
     | instruction_decoder_pt[210]);
assign zero_r0 = 
    (instruction_decoder_pt[34] | instruction_decoder_pt[55]
     | instruction_decoder_pt[66] | instruction_decoder_pt[79]
     | instruction_decoder_pt[81] | instruction_decoder_pt[83]
     | instruction_decoder_pt[86] | instruction_decoder_pt[87]
     | instruction_decoder_pt[89] | instruction_decoder_pt[93]
     | instruction_decoder_pt[97] | instruction_decoder_pt[100]
     | instruction_decoder_pt[109] | instruction_decoder_pt[110]
     | instruction_decoder_pt[111] | instruction_decoder_pt[113]
     | instruction_decoder_pt[116] | instruction_decoder_pt[120]
     | instruction_decoder_pt[122] | instruction_decoder_pt[124]
     | instruction_decoder_pt[125] | instruction_decoder_pt[127]
     | instruction_decoder_pt[128] | instruction_decoder_pt[129]
     | instruction_decoder_pt[131] | instruction_decoder_pt[134]
     | instruction_decoder_pt[140] | instruction_decoder_pt[143]
     | instruction_decoder_pt[145] | instruction_decoder_pt[148]
     | instruction_decoder_pt[149] | instruction_decoder_pt[153]
     | instruction_decoder_pt[154] | instruction_decoder_pt[156]
     | instruction_decoder_pt[157] | instruction_decoder_pt[164]
     | instruction_decoder_pt[168] | instruction_decoder_pt[169]
     | instruction_decoder_pt[170] | instruction_decoder_pt[171]
     | instruction_decoder_pt[179] | instruction_decoder_pt[181]
     | instruction_decoder_pt[184] | instruction_decoder_pt[207]
     | instruction_decoder_pt[208] | instruction_decoder_pt[210]
     | instruction_decoder_pt[215] | instruction_decoder_pt[218]
    );
assign dec_val = 
    (instruction_decoder_pt[1] | instruction_decoder_pt[2]
     | instruction_decoder_pt[7] | instruction_decoder_pt[10]
     | instruction_decoder_pt[14] | instruction_decoder_pt[15]
     | instruction_decoder_pt[16] | instruction_decoder_pt[19]
     | instruction_decoder_pt[21] | instruction_decoder_pt[36]
     | instruction_decoder_pt[37] | instruction_decoder_pt[40]
     | instruction_decoder_pt[41] | instruction_decoder_pt[42]
     | instruction_decoder_pt[43] | instruction_decoder_pt[44]
     | instruction_decoder_pt[54] | instruction_decoder_pt[56]
     | instruction_decoder_pt[57] | instruction_decoder_pt[58]
     | instruction_decoder_pt[60] | instruction_decoder_pt[63]
     | instruction_decoder_pt[64] | instruction_decoder_pt[66]
     | instruction_decoder_pt[67] | instruction_decoder_pt[69]
     | instruction_decoder_pt[70] | instruction_decoder_pt[71]
     | instruction_decoder_pt[72] | instruction_decoder_pt[73]
     | instruction_decoder_pt[74] | instruction_decoder_pt[76]
     | instruction_decoder_pt[78] | instruction_decoder_pt[80]
     | instruction_decoder_pt[81] | instruction_decoder_pt[82]
     | instruction_decoder_pt[83] | instruction_decoder_pt[84]
     | instruction_decoder_pt[87] | instruction_decoder_pt[88]
     | instruction_decoder_pt[89] | instruction_decoder_pt[90]
     | instruction_decoder_pt[91] | instruction_decoder_pt[92]
     | instruction_decoder_pt[93] | instruction_decoder_pt[94]
     | instruction_decoder_pt[95] | instruction_decoder_pt[96]
     | instruction_decoder_pt[97] | instruction_decoder_pt[98]
     | instruction_decoder_pt[99] | instruction_decoder_pt[100]
     | instruction_decoder_pt[101] | instruction_decoder_pt[102]
     | instruction_decoder_pt[103] | instruction_decoder_pt[104]
     | instruction_decoder_pt[105] | instruction_decoder_pt[106]
     | instruction_decoder_pt[108] | instruction_decoder_pt[109]
     | instruction_decoder_pt[110] | instruction_decoder_pt[111]
     | instruction_decoder_pt[112] | instruction_decoder_pt[113]
     | instruction_decoder_pt[114] | instruction_decoder_pt[115]
     | instruction_decoder_pt[116] | instruction_decoder_pt[117]
     | instruction_decoder_pt[118] | instruction_decoder_pt[119]
     | instruction_decoder_pt[120] | instruction_decoder_pt[121]
     | instruction_decoder_pt[122] | instruction_decoder_pt[123]
     | instruction_decoder_pt[124] | instruction_decoder_pt[125]
     | instruction_decoder_pt[126] | instruction_decoder_pt[127]
     | instruction_decoder_pt[128] | instruction_decoder_pt[129]
     | instruction_decoder_pt[130] | instruction_decoder_pt[131]
     | instruction_decoder_pt[132] | instruction_decoder_pt[133]
     | instruction_decoder_pt[134] | instruction_decoder_pt[135]
     | instruction_decoder_pt[136] | instruction_decoder_pt[137]
     | instruction_decoder_pt[138] | instruction_decoder_pt[139]
     | instruction_decoder_pt[140] | instruction_decoder_pt[141]
     | instruction_decoder_pt[142] | instruction_decoder_pt[143]
     | instruction_decoder_pt[144] | instruction_decoder_pt[145]
     | instruction_decoder_pt[146] | instruction_decoder_pt[147]
     | instruction_decoder_pt[148] | instruction_decoder_pt[149]
     | instruction_decoder_pt[151] | instruction_decoder_pt[152]
     | instruction_decoder_pt[153] | instruction_decoder_pt[154]
     | instruction_decoder_pt[155] | instruction_decoder_pt[156]
     | instruction_decoder_pt[157] | instruction_decoder_pt[159]
     | instruction_decoder_pt[160] | instruction_decoder_pt[161]
     | instruction_decoder_pt[162] | instruction_decoder_pt[163]
     | instruction_decoder_pt[164] | instruction_decoder_pt[165]
     | instruction_decoder_pt[166] | instruction_decoder_pt[167]
     | instruction_decoder_pt[168] | instruction_decoder_pt[169]
     | instruction_decoder_pt[170] | instruction_decoder_pt[171]
     | instruction_decoder_pt[179] | instruction_decoder_pt[181]
     | instruction_decoder_pt[182] | instruction_decoder_pt[183]
     | instruction_decoder_pt[184] | instruction_decoder_pt[185]
     | instruction_decoder_pt[201] | instruction_decoder_pt[207]
     | instruction_decoder_pt[208] | instruction_decoder_pt[210]
     | instruction_decoder_pt[211] | instruction_decoder_pt[212]
     | instruction_decoder_pt[213] | instruction_decoder_pt[214]
     | instruction_decoder_pt[215] | instruction_decoder_pt[216]
     | instruction_decoder_pt[217] | instruction_decoder_pt[218]
     | instruction_decoder_pt[219] | instruction_decoder_pt[220]
     | instruction_decoder_pt[221] | instruction_decoder_pt[222]
     | instruction_decoder_pt[223]);
assign async_block = 
    (instruction_decoder_pt[37] | instruction_decoder_pt[40]
     | instruction_decoder_pt[57] | instruction_decoder_pt[67]
     | instruction_decoder_pt[73] | instruction_decoder_pt[81]
     | instruction_decoder_pt[85] | instruction_decoder_pt[102]
     | instruction_decoder_pt[116] | instruction_decoder_pt[125]
     | instruction_decoder_pt[128] | instruction_decoder_pt[133]
     | instruction_decoder_pt[134]);
assign np1_flush = 
    (instruction_decoder_pt[2] | instruction_decoder_pt[3]
     | instruction_decoder_pt[4] | instruction_decoder_pt[5]
     | instruction_decoder_pt[7] | instruction_decoder_pt[11]
     | instruction_decoder_pt[12] | instruction_decoder_pt[40]
     | instruction_decoder_pt[57] | instruction_decoder_pt[63]
     | instruction_decoder_pt[97] | instruction_decoder_pt[110]
     | instruction_decoder_pt[116] | instruction_decoder_pt[125]
     | instruction_decoder_pt[134]);
assign core_block = 
    (instruction_decoder_pt[11] | instruction_decoder_pt[116]
     | instruction_decoder_pt[125] | instruction_decoder_pt[134]
    );
assign no_ram = 
    (instruction_decoder_pt[8] | instruction_decoder_pt[14]
     | instruction_decoder_pt[16] | instruction_decoder_pt[84]
     | instruction_decoder_pt[108] | instruction_decoder_pt[140]
     | instruction_decoder_pt[160] | instruction_decoder_pt[165]
     | instruction_decoder_pt[214] | instruction_decoder_pt[215]
    );
assign no_pre = 
    (instruction_decoder_pt[89] | instruction_decoder_pt[97]
     | instruction_decoder_pt[110] | instruction_decoder_pt[120]
     | instruction_decoder_pt[122] | instruction_decoder_pt[138]
     | instruction_decoder_pt[148] | instruction_decoder_pt[156]
     | instruction_decoder_pt[161] | instruction_decoder_pt[162]
     | instruction_decoder_pt[168] | instruction_decoder_pt[169]
     | instruction_decoder_pt[179] | instruction_decoder_pt[185]
     | instruction_decoder_pt[207] | instruction_decoder_pt[208]
     | instruction_decoder_pt[216] | instruction_decoder_pt[217]
    );


     
      assign SPR_addr = 6'b000000;
      assign iu5_vld_woaxu = iu4_instr_vld;
      assign iu5_ucode_woaxu = iu4_instr_ucode;
      assign iu5_2ucode_woaxu = iu4_instr_2ucode;
      assign iu5_fuse_nop_woaxu = iu4_fuse_nop;
      assign iu5_rte_lq_woaxu = (issue_lq | mtspr_trace_val);
      assign iu5_rte_sq_woaxu = (issue_sq | mtspr_trace_val);
      assign iu5_rte_fx0_woaxu = (issue_fx0 | or_ppr32_val) & (~(mtspr_trace_val)) & (~iu4_fuse_nop) & (~spr_nop);
      assign iu5_rte_fx1_woaxu = issue_fx1 & (~(or_ppr32_val)) & (~iu4_fuse_nop);
      assign iu5_rte_axu0_woaxu = 1'b0;
      assign iu5_rte_axu1_woaxu = 1'b0;
      assign iu5_valop_woaxu = dec_val;
      assign iu5_ord_woaxu = (ordered | or_ppr32_val | iu4_is_mtcpcr) & (~(mfspr_tar | mtspr_tar)) & (~(mtspr_trace_val));
      assign iu5_cord_woaxu = erativax_val;
      assign iu5_spec_woaxu = spec;
      assign iu5_type_fp_woaxu = 1'b0;
      assign iu5_type_ap_woaxu = 1'b0;
      assign iu5_type_spv_woaxu = 1'b0;
      assign iu5_type_st_woaxu = 1'b0;
      assign iu5_async_block_woaxu = iu4_fuse_nop | iu4_fuse_val | iu4_instr_ucode[0] | async_block | or_ppr32_val | mfspr_mmucr1;
      assign iu5_np1_flush_woaxu = mtspr_tenc | mtspr_xucr0 | mtspr_ccr0 | np1_flush | iu4_is_mtcpcr;
      assign iu5_core_block_woaxu = tlbwe_with_binv | mtspr_tenc | mtspr_xucr0 | mtspr_ccr0 | core_block | iu4_is_mtcpcr;
      assign iu5_isram_woaxu = iu4_instr_isram;
      assign iu5_isload_woaxu = isload;
      assign iu5_isstore_woaxu = issue_sq | mtspr_trace_val;
      assign iu5_instr_woaxu = iu4_instr;
      assign iu5_ifar_woaxu = iu4_ifar;
      assign iu5_bta_woaxu = iu4_bta;
      assign iu5_ilat_woaxu = ((mfspr_tar | mtspr_tar) == 1'b1) ? 4'b0001 : 
                              latency;
      assign iu5_t1_v_woaxu = (ta_vld | iu4_fuse_val) & (~(iu4_instr_ucode[1] | or_ppr32_val)) & (~iu4_fuse_nop) & (~spr_nop);
      assign iu5_t1_a_woaxu6 = (iu4_fuse_val == 1'b1) ? {3'b000, iu4_fuse_cmp[6:8]} : 
                               (ta_sel == 1'b0) ? {iu4_instr_ucode_ext[0], iu4_instr[6:10]} : 
                               {iu4_instr_ucode_ext[0], iu4_instr[11:15]};
      assign iu5_t1_t_woaxu = (iu4_fuse_val == 1'b1) ? `cr_t : 
                              `gpr_t;
      assign iu5_t2_v_woaxu = (updatesxer | updatesctr) & (~(iu4_instr_ucode[1] | or_ppr32_val)) & (~iu4_fuse_nop);
      assign iu5_t2_a_woaxu6 = SPR_addr;
      assign iu5_t2_t_woaxu = (updatesxer ? `xer_t : 0 ) | (updatesctr ? `ctr_t : 0 );
      assign iu5_t3_v_woaxu = ((updatescr & (~iu4_fuse_val)) | updateslr | mtspr_tar) & (~(iu4_instr_ucode[1] | or_ppr32_val)) & (~iu4_fuse_nop);
      assign iu5_t3_a_woaxu6 = (updatescr_sel == 2'b10 ? {3'b000, iu4_instr[6:8]} : 0 ) |
	(iu4_instr[13] & updatescr_sel == 2'b11 ? 6'b000001 : 0 ) |
	(iu4_instr[14] & updatescr_sel == 2'b11 ? 6'b000010 : 0 ) |
	(iu4_instr[15] & updatescr_sel == 2'b11 ? 6'b000011 : 0 ) |
	(iu4_instr[16] & updatescr_sel == 2'b11 ? 6'b000100 : 0 ) |
	(iu4_instr[17] & updatescr_sel == 2'b11 ? 6'b000101 : 0 ) |
	(iu4_instr[18] & updatescr_sel == 2'b11 ? 6'b000110 : 0 ) |
	(iu4_instr[19] & updatescr_sel == 2'b11 ? 6'b000111 : 0 ) |
        (mtspr_tar ? 6'b000001 : 0 );
      assign iu5_t3_t_woaxu = (updatescr & (~iu4_fuse_val) ? `cr_t : 0 ) | ((updateslr | mtspr_tar) ? `lr_t : 0 );
      assign iu5_s1_v_woaxu = (s1_vld & (~(zero_r0 & iu5_s1_a_woaxu[0:5] == 6'b000000))) | useslr | mfspr_tar | usescr2 | usestar;
      assign iu5_s1_a_woaxu6 = (s1_vld == 1'b1 & s1_sel == 1'b0 & iu4_fuse_val == 1'b1) ? {iu4_instr_ucode_ext[1], iu4_fuse_cmp[11:15]} : 
                               (s1_vld == 1'b1 & s1_sel == 1'b0 & iu4_fuse_val == 1'b0) ? {iu4_instr_ucode_ext[1], iu4_instr[11:15]} : 
                               (s1_vld == 1'b1 & s1_sel == 1'b1) ? {iu4_instr_ucode_ext[1], iu4_instr[6:10]} : 
                               (usescr2 == 1'b1) ? {3'b000, iu4_instr[6:8]} : 
                               ((usestar | mfspr_tar) == 1'b1) ? 6'b000001 : 
                               0;
      assign iu5_s1_t_woaxu = (s1_vld == 1'b1) ? `gpr_t : 
                              ((useslr | mfspr_tar) == 1'b1) ? `lr_t : 
                              ((usestar | mfspr_tar) == 1'b1) ? `lr_t : 
                              (usescr2 == 1'b1) ? `cr_t : 
                              `spr_t;
      assign iu5_s2_v_woaxu = s2_vld | usesctr | usescr2 | (usesxer & s3_vld) | ((useslr | usestar) & iu4_fuse_val);
      assign iu5_s2_a_woaxu6 = (s2_vld == 1'b1 & s2_sel == 1'b0 & iu4_fuse_val == 1'b1) ? {iu4_instr_ucode_ext[2], iu4_fuse_cmp[16:20]} : 
                               (s2_vld == 1'b1 & s2_sel == 1'b0 & iu4_fuse_val == 1'b0) ? {iu4_instr_ucode_ext[2], iu4_instr[16:20]} : 
                               (s2_vld == 1'b1 & s2_sel == 1'b1) ? {iu4_instr_ucode_ext[2], iu4_instr[11:15]} : 
                               (usescr2 == 1'b1) ? {3'b000, iu4_instr[16:18]} :
                               (usestar == 1'b1 & iu4_fuse_val == 1'b1) ? 6'b000001 : 
                               0;
      assign iu5_s2_t_woaxu = (s2_vld == 1'b1) ? `gpr_t : 
                              (usesctr == 1'b1) ? `ctr_t : 
                              (usescr2 == 1'b1) ? `cr_t : 
                              (useslr == 1'b1 & iu4_fuse_val == 1'b1) ? `lr_t : 
                              (usestar == 1'b1 & iu4_fuse_val == 1'b1) ? `lr_t : 
                              `xer_t;
      assign iu5_s3_v_woaxu = s3_vld | usescr | usesxer;
      assign iu5_s3_a_woaxu6 = (usesxer == 1'b1) ? 0 : 
                               (s3_vld == 1'b1) ? {iu4_instr_ucode_ext[3], iu4_instr[6:10]} : 
                               (usescr == 1'b1) ?
	((usescr_sel == 2'b01 ? {3'b000, iu4_instr[11:13]} : 0 ) |
	 (usescr_sel == 2'b10 ? {3'b000, iu4_instr[21:23]} : 0 ) |
	 ((iu4_instr[13] & (~(multi_cr))) & usescr_sel == 2'b11 ? 6'b000001 : 0 ) |
	 ((iu4_instr[14] & (~(multi_cr))) & usescr_sel == 2'b11 ? 6'b000010 : 0 ) |
	 ((iu4_instr[15] & (~(multi_cr))) & usescr_sel == 2'b11 ? 6'b000011 : 0 ) |
	 ((iu4_instr[16] & (~(multi_cr))) & usescr_sel == 2'b11 ? 6'b000100 : 0 ) |
	 ((iu4_instr[17] & (~(multi_cr))) & usescr_sel == 2'b11 ? 6'b000101 : 0 ) |
	 ((iu4_instr[18] & (~(multi_cr))) & usescr_sel == 2'b11 ? 6'b000110 : 0 ) |
	 ((iu4_instr[19] & (~(multi_cr))) & usescr_sel == 2'b11 ? 6'b000111 : 0 ) ) : 
                               0;
      assign iu5_s3_t_woaxu = (usesxer == 1'b1) ? `xer_t : 
                              (usescr == 1'b1) ? `cr_t : 
                              `gpr_t;
      generate
         if (`GPR_POOL_ENC > 6)
         begin : gpr_pool
            assign iu5_t1_a_woaxu[0:`GPR_POOL_ENC - 7] = 1'b0;
            assign iu5_t2_a_woaxu[0:`GPR_POOL_ENC - 7] = 1'b0;
            assign iu5_t3_a_woaxu[0:`GPR_POOL_ENC - 7] = 1'b0;
            assign iu5_s1_a_woaxu[0:`GPR_POOL_ENC - 7] = 1'b0;
            assign iu5_s2_a_woaxu[0:`GPR_POOL_ENC - 7] = 1'b0;
            assign iu5_s3_a_woaxu[0:`GPR_POOL_ENC - 7] = 1'b0;
         end
      endgenerate
      assign iu5_t1_a_woaxu[`GPR_POOL_ENC - 6:`GPR_POOL_ENC - 1] = iu5_t1_a_woaxu6[0:5];
      assign iu5_t2_a_woaxu[`GPR_POOL_ENC - 6:`GPR_POOL_ENC - 1] = iu5_t2_a_woaxu6[0:5];
      assign iu5_t3_a_woaxu[`GPR_POOL_ENC - 6:`GPR_POOL_ENC - 1] = iu5_t3_a_woaxu6[0:5];
      assign iu5_s1_a_woaxu[`GPR_POOL_ENC - 6:`GPR_POOL_ENC - 1] = iu5_s1_a_woaxu6[0:5];
      assign iu5_s2_a_woaxu[`GPR_POOL_ENC - 6:`GPR_POOL_ENC - 1] = iu5_s2_a_woaxu6[0:5];
      assign iu5_s3_a_woaxu[`GPR_POOL_ENC - 6:`GPR_POOL_ENC - 1] = iu5_s3_a_woaxu6[0:5];
      assign iu5_br_pred_woaxu = iu4_instr_br_pred;
      assign iu5_bh_update_woaxu = iu4_instr_bh_update;
      assign iu5_bh0_hist_woaxu = iu4_instr_bh0_hist;
      assign iu5_bh1_hist_woaxu = iu4_instr_bh1_hist;
      assign iu5_bh2_hist_woaxu = iu4_instr_bh2_hist;
      assign iu5_gshare_woaxu = iu4_instr_gshare;
      assign iu5_ls_ptr_woaxu = iu4_instr_ls_ptr;
      assign iu5_match_woaxu = iu4_instr_match;
      assign iu5_error_woaxu = iu4_instr_error | {3{(iu4_instr_isram & no_ram & naxu)}} | {3{(iu4_instr_isram & au_iu_iu4_no_ram & axu)}};
      assign iu5_btb_entry_woaxu = iu4_instr_btb_entry;
      assign iu5_btb_hist_woaxu = iu4_instr_btb_hist;
      assign iu5_bta_val_woaxu = iu4_instr_bta_val;
      assign iu5_fusion_woaxu[0] = iu4_fuse_val;
      assign iu5_fusion_woaxu[1:2] = (iu4_fuse_cmp[0:5] == 6'b011111 & iu4_fuse_cmp[21:30] == 10'b0000000000 ? 2'b00 : 0 ) |
				     (iu4_fuse_cmp[0:5] == 6'b001011 ? 2'b01 : 0 ) |
                                     (iu4_fuse_cmp[0:5] == 6'b011111 & iu4_fuse_cmp[21:30] == 10'b0000100000 ? 2'b10 : 0 ) |
	                             (iu4_fuse_cmp[0:5] == 6'b001010 ? 2'b11 : 0 );
      assign iu5_fusion_woaxu[3] = iu4_fuse_cmp[10];
      assign iu5_fusion_woaxu[4:19] = iu4_fuse_cmp[16:31];
      assign naxu = au_iu_iu4_i_dec_b;
      assign axu = (~au_iu_iu4_i_dec_b);
      assign iu5_vld_din = iu5_vld_woaxu;
      assign iu5_ucode_din = (iu4_instr_vld ? ((naxu == 1'b1 ? iu5_ucode_woaxu[0:2] : 0 ) | (axu == 1'b1 ? au_iu_iu4_ucode[0:2] : 0 )) : 0 );
      assign iu5_2ucode_din = iu5_2ucode_woaxu;
      assign iu5_fuse_nop_din = iu5_fuse_nop_woaxu;
      assign iu5_rte_lq_din = (~|(iu5_error_din)) & iu4_instr_vld & (~(spr_ccr2_ucode_dis_q & iu5_ucode_din[1])) & ((iu5_rte_lq_woaxu & naxu) | (au_iu_iu4_rte_lq & axu));
      assign iu5_rte_sq_din = (~|(iu5_error_din)) & iu4_instr_vld & (~(spr_ccr2_ucode_dis_q & iu5_ucode_din[1])) & ((iu5_rte_sq_woaxu & naxu) | (au_iu_iu4_rte_sq & axu));
      assign iu5_rte_fx0_din = (~|(iu5_error_din)) & iu4_instr_vld & (~(spr_ccr2_ucode_dis_q & iu5_ucode_din[1])) & (iu5_rte_fx0_woaxu & (~axu));
      assign iu5_rte_fx1_din = (~|(iu5_error_din)) & iu4_instr_vld & (~((spr_ccr2_ucode_dis_q | no_pre) & iu5_ucode_din[1])) & (iu5_rte_fx1_woaxu & (~axu));
      assign iu5_rte_axu0_din = (~|(iu5_error_din)) & iu4_instr_vld & (~(spr_ccr2_ucode_dis_q & iu5_ucode_din[1])) & ((iu5_rte_axu0_woaxu & naxu) | (au_iu_iu4_rte_axu0 & axu));
      assign iu5_rte_axu1_din = (~|(iu5_error_din)) & iu4_instr_vld & (~(spr_ccr2_ucode_dis_q & iu5_ucode_din[1])) & ((iu5_rte_axu1_woaxu & naxu) | (au_iu_iu4_rte_axu1 & axu));
      assign iu5_valop_din = iu5_valop_woaxu | axu;
      assign iu5_ord_din = (iu5_ord_woaxu & naxu) | (au_iu_iu4_ord & axu);
      assign iu5_cord_din = (iu5_cord_woaxu & naxu) | (au_iu_iu4_cord & axu);
      assign iu5_spec_din = (iu5_spec_woaxu & naxu) | (au_iu_iu4_spec & axu);
      assign iu5_type_fp_din = ((iu5_type_fp_woaxu & naxu) | (au_iu_iu4_type_fp & axu));
      assign iu5_type_ap_din = ((iu5_type_ap_woaxu & naxu) | (au_iu_iu4_type_ap & axu));
      assign iu5_type_spv_din = ((iu5_type_spv_woaxu & naxu) | (au_iu_iu4_type_spv & axu));
      assign iu5_type_st_din = ((iu5_type_st_woaxu & naxu) | (au_iu_iu4_type_st & axu));
      assign iu5_async_block_din = ((iu5_async_block_woaxu & naxu) | (au_iu_iu4_async_block & axu));
      assign iu5_np1_flush_din = iu5_np1_flush_woaxu;
      assign iu5_core_block_din = iu4_instr_vld & iu5_core_block_woaxu;
      assign iu5_isram_din = iu5_isram_woaxu;
      assign iu5_isload_din = (~|(iu5_error_din)) & (~(iu4_instr_ucode[1])) & ((iu5_isload_woaxu & naxu) | (au_iu_iu4_isload & axu));
      assign iu5_isstore_din = (~|(iu5_error_din)) & (~(iu4_instr_ucode[1])) & ((iu5_isstore_woaxu & naxu) | (au_iu_iu4_isstore & axu));
      assign iu5_instr_din = iu5_instr_woaxu;
      assign iu5_ifar_din = iu5_ifar_woaxu;
      assign iu5_bta_din = iu5_bta_woaxu;
      assign iu5_ilat_din = (naxu ? iu5_ilat_woaxu : 0 ) | ({1'b0, (axu ? au_iu_iu4_ilat : 0 )});
      assign iu5_t1_v_din = iu4_instr_vld & ((iu5_t1_v_woaxu & naxu) | (au_iu_iu4_t1_v & axu));
      assign iu5_t1_t_din = (iu5_t1_t_woaxu & {3{naxu}}) | (au_iu_iu4_t1_t & {3{axu}});
      assign iu5_t1_a_din = (naxu ? iu5_t1_a_woaxu[0:`GPR_POOL_ENC - 1] : 0 ) | (axu ? au_iu_iu4_t1_a[0:`GPR_POOL_ENC - 1] : 0 );
      assign iu5_t2_v_din = iu4_instr_vld & ((iu5_t2_v_woaxu & naxu) | (au_iu_iu4_t2_v & axu));
      assign iu5_t2_a_din = (naxu ? iu5_t2_a_woaxu[0:`GPR_POOL_ENC - 1] : 0 ) | (axu ? au_iu_iu4_t2_a[0:`GPR_POOL_ENC - 1] : 0 );
      assign iu5_t2_t_din = (naxu ? iu5_t2_t_woaxu[0:2] : 0 ) | (axu ? au_iu_iu4_t2_t[0:2] : 0 );
      assign iu5_t3_v_din = iu4_instr_vld & ((iu5_t3_v_woaxu & naxu) | (au_iu_iu4_t3_v & axu));
      assign iu5_t3_a_din = (naxu ? iu5_t3_a_woaxu[0:`GPR_POOL_ENC - 1] : 0 ) | (axu ? au_iu_iu4_t3_a[0:`GPR_POOL_ENC - 1] : 0 );
      assign iu5_t3_t_din = (naxu ? iu5_t3_t_woaxu[0:2] : 0 ) | (axu ? au_iu_iu4_t3_t[0:2] : 0 );
      assign iu5_s1_v_din = (iu5_s1_v_woaxu & naxu) | (au_iu_iu4_s1_v & axu);
      assign iu5_s1_a_din = (naxu ? iu5_s1_a_woaxu[0:`GPR_POOL_ENC - 1] : 0 ) | (axu ? au_iu_iu4_s1_a[0:`GPR_POOL_ENC - 1] : 0 );
      assign iu5_s1_t_din = (naxu ? iu5_s1_t_woaxu[0:2] : 0 ) | (axu ? au_iu_iu4_s1_t[0:2] : 0 );
      assign iu5_s2_v_din = (iu5_s2_v_woaxu & naxu) | (au_iu_iu4_s2_v & axu);
      assign iu5_s2_a_din = (naxu ? iu5_s2_a_woaxu[0:`GPR_POOL_ENC - 1] : 0 ) | (axu ? au_iu_iu4_s2_a[0:`GPR_POOL_ENC - 1] : 0 );
      assign iu5_s2_t_din = (naxu ? iu5_s2_t_woaxu[0:2] : 0 ) | (axu ? au_iu_iu4_s2_t[0:2] : 0 );
      assign iu5_s3_v_din = (iu5_s3_v_woaxu & naxu) | (au_iu_iu4_s3_v & axu);
      assign iu5_s3_a_din = (naxu ? iu5_s3_a_woaxu[0:`GPR_POOL_ENC - 1] : 0 ) | (axu ? au_iu_iu4_s3_a[0:`GPR_POOL_ENC - 1] : 0 );
      assign iu5_s3_t_din = (naxu ? iu5_s3_t_woaxu[0:2] : 0 ) | (axu ? au_iu_iu4_s3_t[0:2] : 0 );
      assign iu5_br_pred_din = iu5_br_pred_woaxu;
      assign iu5_bh_update_din = iu5_bh_update_woaxu;
      assign iu5_bh0_hist_din = iu5_bh0_hist_woaxu;
      assign iu5_bh1_hist_din = iu5_bh1_hist_woaxu;
      assign iu5_bh2_hist_din = iu5_bh2_hist_woaxu;
      assign iu5_gshare_din = iu5_gshare_woaxu;
      assign iu5_ls_ptr_din = iu5_ls_ptr_woaxu;
      assign iu5_match_din = iu5_match_woaxu;
      assign iu5_error_din = iu5_error_woaxu;
      assign iu5_btb_entry_din = iu5_btb_entry_woaxu;
      assign iu5_btb_hist_din = iu5_btb_hist_woaxu;
      assign iu5_bta_val_din = iu5_bta_val_woaxu;
      assign iu5_fusion_din = iu5_fusion_woaxu;
      
      
      
      always @(iu5_vld_q or cp_flush_q or frn_fdec_iu5_stall or iu5_vld_din or iu5_ucode_din or iu5_2ucode_din or iu5_fuse_nop_din or iu5_error_din or iu5_btb_entry_din or iu5_btb_hist_din or iu5_bta_val_din or iu5_fusion_din or iu5_rte_lq_din or iu5_rte_sq_din or iu5_rte_fx0_din or iu5_rte_fx1_din or iu5_rte_axu0_din or iu5_rte_axu1_din or iu5_valop_din or iu5_ord_din or iu5_cord_din or iu5_spec_din or iu5_isram_din or iu5_isload_din or iu5_isstore_din or iu5_instr_din or iu5_ifar_din or iu5_bta_din or iu5_ilat_din or iu5_t1_v_din or iu5_t1_t_din or iu5_t1_a_din or iu5_t2_v_din or iu5_t2_a_din or iu5_t2_t_din or iu5_t3_v_din or iu5_t3_a_din or iu5_t3_t_din or iu5_s1_v_din or iu5_s1_a_din or iu5_s1_t_din or iu5_s2_v_din or iu5_s2_a_din or iu5_s2_t_din or iu5_s3_v_din or iu5_s3_a_din or iu5_s3_t_din or iu5_br_pred_din or iu5_bh_update_din or iu5_bh0_hist_din or iu5_bh1_hist_din or iu5_bh2_hist_din or iu5_gshare_din or iu5_ls_ptr_din or iu5_match_din or iu5_async_block_din or iu5_np1_flush_din or iu5_core_block_din or iu5_type_fp_din or iu5_type_ap_din or iu5_type_spv_din or iu5_type_st_din or iu5_ucode_q or iu5_2ucode_q or iu5_fuse_nop_q or iu5_error_q or iu5_btb_hist_q or iu5_btb_entry_q or iu5_bta_val_q or iu5_fusion_q or iu5_rte_lq_q or iu5_rte_sq_q or iu5_rte_fx0_q or iu5_rte_fx1_q or iu5_rte_axu0_q or iu5_rte_axu1_q or iu5_valop_q or iu5_ord_q or iu5_cord_q or iu5_spec_q or iu5_isram_q or iu5_isload_q or iu5_isstore_q or iu5_instr_q or iu5_ifar_q or iu5_bta_q or iu5_ilat_q or iu5_t1_v_q or iu5_t1_t_q or iu5_t1_a_q or iu5_t2_v_q or iu5_t2_a_q or iu5_t2_t_q or iu5_t3_v_q or iu5_t3_a_q or iu5_t3_t_q or iu5_s1_v_q or iu5_s1_a_q or iu5_s1_t_q or iu5_s2_v_q or iu5_s2_a_q or iu5_s2_t_q or iu5_s3_v_q or iu5_s3_a_q or iu5_s3_t_q or iu5_br_pred_q or iu5_bh_update_q or iu5_bh0_hist_q or iu5_bh1_hist_q or iu5_bh2_hist_q or iu5_gshare_q or iu5_ls_ptr_q or iu5_match_q or iu5_async_block_q or iu5_np1_flush_q or iu5_core_block_q or iu5_type_fp_q or iu5_type_ap_q or iu5_type_spv_q or iu5_type_st_q)
      begin: iu5_instr_proc
         
         iu5_vld_d <= iu5_vld_din;
         iu5_ucode_d <= iu5_ucode_din;
         iu5_2ucode_d <= iu5_2ucode_din;
         iu5_fuse_nop_d <= iu5_fuse_nop_din;
         iu5_error_d <= iu5_error_din;
         iu5_btb_entry_d <= iu5_btb_entry_din;
         iu5_btb_hist_d <= iu5_btb_hist_din;
         iu5_bta_val_d <= iu5_bta_val_din;
         iu5_fusion_d <= iu5_fusion_din;
         iu5_rte_lq_d <= iu5_rte_lq_din;
         iu5_rte_sq_d <= iu5_rte_sq_din;
         iu5_rte_fx0_d <= iu5_rte_fx0_din;
         iu5_rte_fx1_d <= iu5_rte_fx1_din;
         iu5_rte_axu0_d <= iu5_rte_axu0_din;
         iu5_rte_axu1_d <= iu5_rte_axu1_din;
         iu5_valop_d <= iu5_valop_din;
         iu5_ord_d <= iu5_ord_din;
         iu5_cord_d <= iu5_cord_din;
         iu5_spec_d <= iu5_spec_din;
         iu5_isram_d <= iu5_isram_din;
         iu5_isload_d <= iu5_isload_din;
         iu5_isstore_d <= iu5_isstore_din;
         iu5_instr_d <= iu5_instr_din;
         iu5_ifar_d <= iu5_ifar_din;
         iu5_bta_d <= iu5_bta_din;
         iu5_ilat_d <= iu5_ilat_din;
         iu5_t1_v_d <= iu5_t1_v_din;
         iu5_t1_t_d <= iu5_t1_t_din;
         iu5_t1_a_d <= iu5_t1_a_din;
         iu5_t2_v_d <= iu5_t2_v_din;
         iu5_t2_a_d <= iu5_t2_a_din;
         iu5_t2_t_d <= iu5_t2_t_din;
         iu5_t3_v_d <= iu5_t3_v_din;
         iu5_t3_a_d <= iu5_t3_a_din;
         iu5_t3_t_d <= iu5_t3_t_din;
         iu5_s1_v_d <= iu5_s1_v_din;
         iu5_s1_a_d <= iu5_s1_a_din;
         iu5_s1_t_d <= iu5_s1_t_din;
         iu5_s2_v_d <= iu5_s2_v_din;
         iu5_s2_a_d <= iu5_s2_a_din;
         iu5_s2_t_d <= iu5_s2_t_din;
         iu5_s3_v_d <= iu5_s3_v_din;
         iu5_s3_a_d <= iu5_s3_a_din;
         iu5_s3_t_d <= iu5_s3_t_din;
         iu5_br_pred_d <= iu5_br_pred_din;
         iu5_bh_update_d <= iu5_bh_update_din;
         iu5_bh0_hist_d <= iu5_bh0_hist_din;
         iu5_bh1_hist_d <= iu5_bh1_hist_din;
         iu5_bh2_hist_d <= iu5_bh2_hist_din;
         iu5_gshare_d <= iu5_gshare_din;
         iu5_ls_ptr_d <= iu5_ls_ptr_din;
         iu5_match_d <= iu5_match_din;
         iu5_async_block_d <= iu5_async_block_din;
         iu5_np1_flush_d <= iu5_np1_flush_din;
         iu5_core_block_d <= iu5_core_block_din;
         iu5_type_fp_d <= iu5_type_fp_din;
         iu5_type_ap_d <= iu5_type_ap_din;
         iu5_type_spv_d <= iu5_type_spv_din;
         iu5_type_st_d <= iu5_type_st_din;
         if (frn_fdec_iu5_stall == 1'b1)
         begin
            iu5_vld_d <= iu5_vld_q;
            iu5_ucode_d <= iu5_ucode_q;
            iu5_2ucode_d <= iu5_2ucode_q;
            iu5_fuse_nop_d <= iu5_fuse_nop_q;
            iu5_error_d <= iu5_error_q;
            iu5_btb_entry_d <= iu5_btb_entry_q;
            iu5_btb_hist_d <= iu5_btb_hist_q;
            iu5_bta_val_d <= iu5_bta_val_q;
            iu5_fusion_d <= iu5_fusion_q;
            iu5_rte_lq_d <= iu5_rte_lq_q;
            iu5_rte_sq_d <= iu5_rte_sq_q;
            iu5_rte_fx0_d <= iu5_rte_fx0_q;
            iu5_rte_fx1_d <= iu5_rte_fx1_q;
            iu5_rte_axu0_d <= iu5_rte_axu0_q;
            iu5_rte_axu1_d <= iu5_rte_axu1_q;
            iu5_valop_d <= iu5_valop_q;
            iu5_ord_d <= iu5_ord_q;
            iu5_cord_d <= iu5_cord_q;
            iu5_spec_d <= iu5_spec_q;
            iu5_isram_d <= iu5_isram_q;
            iu5_isload_d <= iu5_isload_q;
            iu5_isstore_d <= iu5_isstore_q;
            iu5_instr_d <= iu5_instr_q;
            iu5_ifar_d <= iu5_ifar_q;
            iu5_bta_d <= iu5_bta_q;
            iu5_ilat_d <= iu5_ilat_q;
            iu5_t1_v_d <= iu5_t1_v_q;
            iu5_t1_t_d <= iu5_t1_t_q;
            iu5_t1_a_d <= iu5_t1_a_q;
            iu5_t2_v_d <= iu5_t2_v_q;
            iu5_t2_a_d <= iu5_t2_a_q;
            iu5_t2_t_d <= iu5_t2_t_q;
            iu5_t3_v_d <= iu5_t3_v_q;
            iu5_t3_a_d <= iu5_t3_a_q;
            iu5_t3_t_d <= iu5_t3_t_q;
            iu5_s1_v_d <= iu5_s1_v_q;
            iu5_s1_a_d <= iu5_s1_a_q;
            iu5_s1_t_d <= iu5_s1_t_q;
            iu5_s2_v_d <= iu5_s2_v_q;
            iu5_s2_a_d <= iu5_s2_a_q;
            iu5_s2_t_d <= iu5_s2_t_q;
            iu5_s3_v_d <= iu5_s3_v_q;
            iu5_s3_a_d <= iu5_s3_a_q;
            iu5_s3_t_d <= iu5_s3_t_q;
            iu5_br_pred_d <= iu5_br_pred_q;
            iu5_bh_update_d <= iu5_bh_update_q;
            iu5_bh0_hist_d <= iu5_bh0_hist_q;
            iu5_bh1_hist_d <= iu5_bh1_hist_q;
            iu5_bh2_hist_d <= iu5_bh2_hist_q;
            iu5_gshare_d <= iu5_gshare_q;
            iu5_ls_ptr_d <= iu5_ls_ptr_q;
            iu5_match_d <= iu5_match_q;
            iu5_async_block_d <= iu5_async_block_q;
            iu5_np1_flush_d <= iu5_np1_flush_q;
            iu5_core_block_d <= iu5_core_block_q;
            iu5_type_fp_d <= iu5_type_fp_q;
            iu5_type_ap_d <= iu5_type_ap_q;
            iu5_type_spv_d <= iu5_type_spv_q;
            iu5_type_st_d <= iu5_type_st_q;
         end
         if (cp_flush_q == 1'b1)
         begin
            iu5_vld_d <= 1'b0;
            iu5_rte_lq_d <= 1'b0;
            iu5_rte_sq_d <= 1'b0;
            iu5_rte_fx0_d <= 1'b0;
            iu5_rte_fx1_d <= 1'b0;
            iu5_rte_axu0_d <= 1'b0;
            iu5_rte_axu1_d <= 1'b0;
            iu5_isload_d <= 1'b0;
            iu5_isstore_d <= 1'b0;
            iu5_ucode_d <= 3'b0;
            iu5_2ucode_d <= 1'b0;
            iu5_t1_v_d <= 1'b0;
            iu5_t2_v_d <= 1'b0;
            iu5_t3_v_d <= 1'b0;
            iu5_core_block_d <= 1'b0;
         end
      end
      assign iu5_valid_act = iu5_vld_din | iu5_vld_q | cp_flush_q;
      assign iu5_instr_act = iu5_vld_din;
       
      tri_rlmlatch_p #(.INIT(0)) iu5_vld(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_valid_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_vld_offset]),
         .scout(sov[iu5_vld_offset]),
         .din(iu5_vld_d),
         .dout(iu5_vld_q)
      );
       
      tri_rlmreg_p #(.WIDTH(3), .INIT(0)) iu5_ucode(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_valid_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_ucode_offset:iu5_ucode_offset + 3 - 1]),
         .scout(sov[iu5_ucode_offset:iu5_ucode_offset + 3 - 1]),
         .din(iu5_ucode_d),
         .dout(iu5_ucode_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_2ucode(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_2ucode_offset]),
         .scout(sov[iu5_2ucode_offset]),
         .din(iu5_2ucode_d),
         .dout(iu5_2ucode_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_fuse_nop(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_fuse_nop_offset]),
         .scout(sov[iu5_fuse_nop_offset]),
         .din(iu5_fuse_nop_d),
         .dout(iu5_fuse_nop_q)
      );
      
      tri_rlmreg_p #(.WIDTH(3), .INIT(0)) iu5_error(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_error_offset:iu5_error_offset + 3 - 1]),
         .scout(sov[iu5_error_offset:iu5_error_offset + 3 - 1]),
         .din(iu5_error_d),
         .dout(iu5_error_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_btb_entry(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_btb_entry_offset]),
         .scout(sov[iu5_btb_entry_offset]),
         .din(iu5_btb_entry_d),
         .dout(iu5_btb_entry_q)
      );
      
      tri_rlmreg_p #(.WIDTH(2), .INIT(0)) iu5_btb_hist(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_btb_hist_offset:iu5_btb_hist_offset + 2 - 1]),
         .scout(sov[iu5_btb_hist_offset:iu5_btb_hist_offset + 2 - 1]),
         .din(iu5_btb_hist_d),
         .dout(iu5_btb_hist_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_bta_val(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_bta_val_offset]),
         .scout(sov[iu5_bta_val_offset]),
         .din(iu5_bta_val_d),
         .dout(iu5_bta_val_q)
      );
      
      tri_rlmreg_p #(.WIDTH(20), .INIT(0)) iu5_fusion(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_fusion_offset:iu5_fusion_offset + 20 - 1]),
         .scout(sov[iu5_fusion_offset:iu5_fusion_offset + 20 - 1]),
         .din(iu5_fusion_d),
         .dout(iu5_fusion_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_rte_lq(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_valid_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_rte_lq_offset]),
         .scout(sov[iu5_rte_lq_offset]),
         .din(iu5_rte_lq_d),
         .dout(iu5_rte_lq_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_rte_sq(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_valid_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_rte_sq_offset]),
         .scout(sov[iu5_rte_sq_offset]),
         .din(iu5_rte_sq_d),
         .dout(iu5_rte_sq_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_rte_fx0(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_valid_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_rte_fx0_offset]),
         .scout(sov[iu5_rte_fx0_offset]),
         .din(iu5_rte_fx0_d),
         .dout(iu5_rte_fx0_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_rte_fx1(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_valid_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_rte_fx1_offset]),
         .scout(sov[iu5_rte_fx1_offset]),
         .din(iu5_rte_fx1_d),
         .dout(iu5_rte_fx1_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_rte_axu0(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_valid_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_rte_axu0_offset]),
         .scout(sov[iu5_rte_axu0_offset]),
         .din(iu5_rte_axu0_d),
         .dout(iu5_rte_axu0_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_rte_axu1(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_valid_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_rte_axu1_offset]),
         .scout(sov[iu5_rte_axu1_offset]),
         .din(iu5_rte_axu1_d),
         .dout(iu5_rte_axu1_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_valop(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_valop_offset]),
         .scout(sov[iu5_valop_offset]),
         .din(iu5_valop_d),
         .dout(iu5_valop_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_ord(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_ord_offset]),
         .scout(sov[iu5_ord_offset]),
         .din(iu5_ord_d),
         .dout(iu5_ord_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_cord(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_cord_offset]),
         .scout(sov[iu5_cord_offset]),
         .din(iu5_cord_d),
         .dout(iu5_cord_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_spec(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_spec_offset]),
         .scout(sov[iu5_spec_offset]),
         .din(iu5_spec_d),
         .dout(iu5_spec_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_type_fp(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_type_fp_offset]),
         .scout(sov[iu5_type_fp_offset]),
         .din(iu5_type_fp_d),
         .dout(iu5_type_fp_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_type_ap(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_type_ap_offset]),
         .scout(sov[iu5_type_ap_offset]),
         .din(iu5_type_ap_d),
         .dout(iu5_type_ap_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_type_spv(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_type_spv_offset]),
         .scout(sov[iu5_type_spv_offset]),
         .din(iu5_type_spv_d),
         .dout(iu5_type_spv_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_type_st(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_type_st_offset]),
         .scout(sov[iu5_type_st_offset]),
         .din(iu5_type_st_d),
         .dout(iu5_type_st_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_async_block(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_async_block_offset]),
         .scout(sov[iu5_async_block_offset]),
         .din(iu5_async_block_d),
         .dout(iu5_async_block_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_np1_flush(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_np1_flush_offset]),
         .scout(sov[iu5_np1_flush_offset]),
         .din(iu5_np1_flush_d),
         .dout(iu5_np1_flush_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_core_block(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_valid_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_core_block_offset]),
         .scout(sov[iu5_core_block_offset]),
         .din(iu5_core_block_d),
         .dout(iu5_core_block_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_isram(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_isram_offset]),
         .scout(sov[iu5_isram_offset]),
         .din(iu5_isram_d),
         .dout(iu5_isram_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_isload(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_valid_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_isload_offset]),
         .scout(sov[iu5_isload_offset]),
         .din(iu5_isload_d),
         .dout(iu5_isload_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_isstore(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_valid_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_isstore_offset]),
         .scout(sov[iu5_isstore_offset]),
         .din(iu5_isstore_d),
         .dout(iu5_isstore_q)
      );
      
      tri_rlmreg_p #(.WIDTH(32), .INIT(0)) iu5_instr(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_instr_offset:iu5_instr_offset + 32 - 1]),
         .scout(sov[iu5_instr_offset:iu5_instr_offset + 32 - 1]),
         .din(iu5_instr_d),
         .dout(iu5_instr_q)
      );
      
      tri_rlmreg_p #(.WIDTH((`EFF_IFAR_WIDTH)), .INIT(0)) iu5_ifar(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_ifar_offset:iu5_ifar_offset + (`EFF_IFAR_WIDTH) - 1]),
         .scout(sov[iu5_ifar_offset:iu5_ifar_offset + (`EFF_IFAR_WIDTH) - 1]),
         .din(iu5_ifar_d),
         .dout(iu5_ifar_q)
      );
      
      tri_rlmreg_p #(.WIDTH((`EFF_IFAR_WIDTH)), .INIT(0)) iu5_bta(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_bta_offset:iu5_bta_offset + (`EFF_IFAR_WIDTH) - 1]),
         .scout(sov[iu5_bta_offset:iu5_bta_offset + (`EFF_IFAR_WIDTH) - 1]),
         .din(iu5_bta_d),
         .dout(iu5_bta_q)
      );
      
      tri_rlmreg_p #(.WIDTH(4), .INIT(0)) iu5_ilat(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_ilat_offset:iu5_ilat_offset + 4 - 1]),
         .scout(sov[iu5_ilat_offset:iu5_ilat_offset + 4 - 1]),
         .din(iu5_ilat_d),
         .dout(iu5_ilat_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_t1_v(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_valid_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_t1_v_offset]),
         .scout(sov[iu5_t1_v_offset]),
         .din(iu5_t1_v_d),
         .dout(iu5_t1_v_q)
      );
      
      tri_rlmreg_p #(.WIDTH(3), .INIT(0)) iu5_t1_t(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_t1_t_offset:iu5_t1_t_offset + 3 - 1]),
         .scout(sov[iu5_t1_t_offset:iu5_t1_t_offset + 3 - 1]),
         .din(iu5_t1_t_d),
         .dout(iu5_t1_t_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) iu5_t1_a(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_t1_a_offset:iu5_t1_a_offset + `GPR_POOL_ENC - 1]),
         .scout(sov[iu5_t1_a_offset:iu5_t1_a_offset + `GPR_POOL_ENC - 1]),
         .din(iu5_t1_a_d),
         .dout(iu5_t1_a_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_t2_v(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_valid_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_t2_v_offset]),
         .scout(sov[iu5_t2_v_offset]),
         .din(iu5_t2_v_d),
         .dout(iu5_t2_v_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) iu5_t2_a(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_t2_a_offset:iu5_t2_a_offset + `GPR_POOL_ENC - 1]),
         .scout(sov[iu5_t2_a_offset:iu5_t2_a_offset + `GPR_POOL_ENC - 1]),
         .din(iu5_t2_a_d),
         .dout(iu5_t2_a_q)
      );
      
      tri_rlmreg_p #(.WIDTH(3), .INIT(0)) iu5_t2_t(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_t2_t_offset:iu5_t2_t_offset + 3 - 1]),
         .scout(sov[iu5_t2_t_offset:iu5_t2_t_offset + 3 - 1]),
         .din(iu5_t2_t_d),
         .dout(iu5_t2_t_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_t3_v(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_valid_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_t3_v_offset]),
         .scout(sov[iu5_t3_v_offset]),
         .din(iu5_t3_v_d),
         .dout(iu5_t3_v_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) iu5_t3_a(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_t3_a_offset:iu5_t3_a_offset + `GPR_POOL_ENC - 1]),
         .scout(sov[iu5_t3_a_offset:iu5_t3_a_offset + `GPR_POOL_ENC - 1]),
         .din(iu5_t3_a_d),
         .dout(iu5_t3_a_q)
      );
      
      tri_rlmreg_p #(.WIDTH(3), .INIT(0)) iu5_t3_t(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_t3_t_offset:iu5_t3_t_offset + 3 - 1]),
         .scout(sov[iu5_t3_t_offset:iu5_t3_t_offset + 3 - 1]),
         .din(iu5_t3_t_d),
         .dout(iu5_t3_t_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_s1_v(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_s1_v_offset]),
         .scout(sov[iu5_s1_v_offset]),
         .din(iu5_s1_v_d),
         .dout(iu5_s1_v_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) iu5_s1_a(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_s1_a_offset:iu5_s1_a_offset + `GPR_POOL_ENC - 1]),
         .scout(sov[iu5_s1_a_offset:iu5_s1_a_offset + `GPR_POOL_ENC - 1]),
         .din(iu5_s1_a_d),
         .dout(iu5_s1_a_q)
      );
      
      tri_rlmreg_p #(.WIDTH(3), .INIT(0)) iu5_s1_t(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_s1_t_offset:iu5_s1_t_offset + 3 - 1]),
         .scout(sov[iu5_s1_t_offset:iu5_s1_t_offset + 3 - 1]),
         .din(iu5_s1_t_d),
         .dout(iu5_s1_t_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_s2_v(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_s2_v_offset]),
         .scout(sov[iu5_s2_v_offset]),
         .din(iu5_s2_v_d),
         .dout(iu5_s2_v_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) iu5_s2_a(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_s2_a_offset:iu5_s2_a_offset + `GPR_POOL_ENC - 1]),
         .scout(sov[iu5_s2_a_offset:iu5_s2_a_offset + `GPR_POOL_ENC - 1]),
         .din(iu5_s2_a_d),
         .dout(iu5_s2_a_q)
      );
      
      tri_rlmreg_p #(.WIDTH(3), .INIT(0)) iu5_s2_t(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_s2_t_offset:iu5_s2_t_offset + 3 - 1]),
         .scout(sov[iu5_s2_t_offset:iu5_s2_t_offset + 3 - 1]),
         .din(iu5_s2_t_d),
         .dout(iu5_s2_t_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_s3_v(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_s3_v_offset]),
         .scout(sov[iu5_s3_v_offset]),
         .din(iu5_s3_v_d),
         .dout(iu5_s3_v_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) iu5_s3_a(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_s3_a_offset:iu5_s3_a_offset + `GPR_POOL_ENC - 1]),
         .scout(sov[iu5_s3_a_offset:iu5_s3_a_offset + `GPR_POOL_ENC - 1]),
         .din(iu5_s3_a_d),
         .dout(iu5_s3_a_q)
      );
      
      tri_rlmreg_p #(.WIDTH(3), .INIT(0)) iu5_s3_t(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_s3_t_offset:iu5_s3_t_offset + 3 - 1]),
         .scout(sov[iu5_s3_t_offset:iu5_s3_t_offset + 3 - 1]),
         .din(iu5_s3_t_d),
         .dout(iu5_s3_t_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_br_pred(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_br_pred_offset]),
         .scout(sov[iu5_br_pred_offset]),
         .din(iu5_br_pred_d),
         .dout(iu5_br_pred_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_bh_update(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_bh_update_offset]),
         .scout(sov[iu5_bh_update_offset]),
         .din(iu5_bh_update_d),
         .dout(iu5_bh_update_q)
      );
      
      tri_rlmreg_p #(.WIDTH(2), .INIT(0)) iu5_bh0_hist(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_bh0_hist_offset:iu5_bh0_hist_offset + 2 - 1]),
         .scout(sov[iu5_bh0_hist_offset:iu5_bh0_hist_offset + 2 - 1]),
         .din(iu5_bh0_hist_d),
         .dout(iu5_bh0_hist_q)
      );
      
      tri_rlmreg_p #(.WIDTH(2), .INIT(0)) iu5_bh1_hist(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_bh1_hist_offset:iu5_bh1_hist_offset + 2 - 1]),
         .scout(sov[iu5_bh1_hist_offset:iu5_bh1_hist_offset + 2 - 1]),
         .din(iu5_bh1_hist_d),
         .dout(iu5_bh1_hist_q)
      );
      
      tri_rlmreg_p #(.WIDTH(2), .INIT(0)) iu5_bh2_hist(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_bh2_hist_offset:iu5_bh2_hist_offset + 2 - 1]),
         .scout(sov[iu5_bh2_hist_offset:iu5_bh2_hist_offset + 2 - 1]),
         .din(iu5_bh2_hist_d),
         .dout(iu5_bh2_hist_q)
      );
      
      tri_rlmreg_p #(.WIDTH(18), .INIT(0)) iu5_gshare(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_gshare_offset:iu5_gshare_offset + 18 - 1]),
         .scout(sov[iu5_gshare_offset:iu5_gshare_offset + 18 - 1]),
         .din(iu5_gshare_d),
         .dout(iu5_gshare_q)
      );
      
      tri_rlmreg_p #(.WIDTH(3), .INIT(0)) iu5_ls_ptr(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_ls_ptr_offset:iu5_ls_ptr_offset + 3 - 1]),
         .scout(sov[iu5_ls_ptr_offset:iu5_ls_ptr_offset + 3 - 1]),
         .din(iu5_ls_ptr_d),
         .dout(iu5_ls_ptr_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) iu5_match(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(iu5_instr_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[iu5_match_offset]),
         .scout(sov[iu5_match_offset]),
         .din(iu5_match_d),
         .dout(iu5_match_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) spr_epcr_dgtmi_latch(
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
         .scin(siv[spr_epcr_dgtmi_offset]),
         .scout(sov[spr_epcr_dgtmi_offset]),
         .din(xu_iu_epcr_dgtmi),
         .dout(spr_epcr_dgtmi_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) spr_msrp_uclep_latch(
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
         .scin(siv[spr_msrp_uclep_offset]),
         .scout(sov[spr_msrp_uclep_offset]),
         .din(xu_iu_msrp_uclep),
         .dout(spr_msrp_uclep_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) spr_msr_pr_latch(
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
         .scin(siv[spr_msr_pr_offset]),
         .scout(sov[spr_msr_pr_offset]),
         .din(xu_iu_msr_pr),
         .dout(spr_msr_pr_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) spr_msr_gs_latch(
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
         .scin(siv[spr_msr_gs_offset]),
         .scout(sov[spr_msr_gs_offset]),
         .din(xu_iu_msr_gs),
         .dout(spr_msr_gs_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) spr_msr_ucle_latch(
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
         .scin(siv[spr_msr_ucle_offset]),
         .scout(sov[spr_msr_ucle_offset]),
         .din(xu_iu_msr_ucle),
         .dout(spr_msr_ucle_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) spr_ccr2_ucode_dis_latch(
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
         .scin(siv[spr_ccr2_ucode_dis_offset]),
         .scout(sov[spr_ccr2_ucode_dis_offset]),
         .din(xu_iu_ccr2_ucode_dis),
         .dout(spr_ccr2_ucode_dis_q)
      );
      
      tri_rlmlatch_p #(.INIT(0)) cp_flush_latch(
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
         .scin(siv[cp_flush_offset]),
         .scout(sov[cp_flush_offset]),
         .din(cp_flush_d),
         .dout(cp_flush_q)
      );
      assign fdec_frn_iu5_ix_vld = iu5_vld_q;
      assign fdec_frn_iu5_ix_ucode = iu5_ucode_q;
      assign fdec_frn_iu5_ix_2ucode = iu5_2ucode_q;
      assign fdec_frn_iu5_ix_fuse_nop = iu5_fuse_nop_q;
      assign fdec_frn_iu5_ix_error = iu5_error_q;
      assign fdec_frn_iu5_ix_fusion = iu5_fusion_q;
      assign fdec_frn_iu5_ix_rte_lq = iu5_rte_lq_q;
      assign fdec_frn_iu5_ix_rte_sq = iu5_rte_sq_q;
      assign fdec_frn_iu5_ix_rte_fx0 = iu5_rte_fx0_q;
      assign fdec_frn_iu5_ix_rte_fx1 = iu5_rte_fx1_q;
      assign fdec_frn_iu5_ix_rte_axu0 = iu5_rte_axu0_q;
      assign fdec_frn_iu5_ix_rte_axu1 = iu5_rte_axu1_q;
      assign fdec_frn_iu5_ix_valop = iu5_valop_q;
      assign fdec_frn_iu5_ix_ord = iu5_ord_q;
      assign fdec_frn_iu5_ix_cord = iu5_cord_q;
      assign fdec_frn_iu5_ix_spec = iu5_spec_q;
      assign fdec_frn_iu5_ix_type_fp = iu5_type_fp_q;
      assign fdec_frn_iu5_ix_type_ap = iu5_type_ap_q;
      assign fdec_frn_iu5_ix_type_spv = iu5_type_spv_q;
      assign fdec_frn_iu5_ix_type_st = iu5_type_st_q;
      assign fdec_frn_iu5_ix_async_block = iu5_async_block_q;
      assign fdec_frn_iu5_ix_np1_flush = iu5_np1_flush_q;
      assign fdec_frn_iu5_ix_core_block = iu5_core_block_q;
      assign fdec_frn_iu5_ix_isram = iu5_isram_q;
      assign fdec_frn_iu5_ix_isload = iu5_isload_q;
      assign fdec_frn_iu5_ix_isstore = iu5_isstore_q;
      assign fdec_frn_iu5_ix_instr = iu5_instr_q;
      assign fdec_frn_iu5_ix_ifar = iu5_ifar_q;
      assign fdec_frn_iu5_ix_bta = iu5_bta_q;
      assign fdec_frn_iu5_ix_ilat = iu5_ilat_q;
      assign fdec_frn_iu5_ix_t1_v = iu5_t1_v_q;
      assign fdec_frn_iu5_ix_t1_t = iu5_t1_t_q;
      assign fdec_frn_iu5_ix_t1_a = iu5_t1_a_q;
      assign fdec_frn_iu5_ix_t2_v = iu5_t2_v_q;
      assign fdec_frn_iu5_ix_t2_a = iu5_t2_a_q;
      assign fdec_frn_iu5_ix_t2_t = iu5_t2_t_q;
      assign fdec_frn_iu5_ix_t3_v = iu5_t3_v_q;
      assign fdec_frn_iu5_ix_t3_a = iu5_t3_a_q;
      assign fdec_frn_iu5_ix_t3_t = iu5_t3_t_q;
      assign fdec_frn_iu5_ix_s1_v = iu5_s1_v_q;
      assign fdec_frn_iu5_ix_s1_a = iu5_s1_a_q;
      assign fdec_frn_iu5_ix_s1_t = iu5_s1_t_q;
      assign fdec_frn_iu5_ix_s2_v = iu5_s2_v_q;
      assign fdec_frn_iu5_ix_s2_a = iu5_s2_a_q;
      assign fdec_frn_iu5_ix_s2_t = iu5_s2_t_q;
      assign fdec_frn_iu5_ix_s3_v = iu5_s3_v_q;
      assign fdec_frn_iu5_ix_s3_a = iu5_s3_a_q;
      assign fdec_frn_iu5_ix_s3_t = iu5_s3_t_q;
      assign fdec_frn_iu5_ix_br_pred = iu5_br_pred_q;
      assign fdec_frn_iu5_ix_bh_update = iu5_bh_update_q;
      assign fdec_frn_iu5_ix_bh0_hist = iu5_bh0_hist_q;
      assign fdec_frn_iu5_ix_bh1_hist = iu5_bh1_hist_q;
      assign fdec_frn_iu5_ix_bh2_hist = iu5_bh2_hist_q;
      assign fdec_frn_iu5_ix_gshare = iu5_gshare_q;
      assign fdec_frn_iu5_ix_ls_ptr = iu5_ls_ptr_q;
      assign fdec_frn_iu5_ix_match = iu5_match_q;
      assign fdec_frn_iu5_ix_btb_entry = iu5_btb_entry_q;
      assign fdec_frn_iu5_ix_btb_hist = iu5_btb_hist_q;
      assign fdec_frn_iu5_ix_bta_val = iu5_bta_val_q;
      
   tri_plat #(.WIDTH(2)) perv_2to1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({pc_iu_func_sl_thold_2,pc_iu_sg_2}),
      .q({pc_iu_func_sl_thold_1,pc_iu_sg_1})
   );
   
   
   tri_plat #(.WIDTH(2)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({pc_iu_func_sl_thold_1,pc_iu_sg_1}),
      .q({pc_iu_func_sl_thold_0,pc_iu_sg_0})
   );

      tri_lcbor  perv_lcbor(
         .clkoff_b(clkoff_b),
         .thold(pc_iu_func_sl_thold_0),
         .sg(pc_iu_sg_0),
         .act_dis(act_dis),
         .force_t(force_t),
         .thold_b(pc_iu_func_sl_thold_0_b)
      );
      assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
      assign scan_out = sov[0];
      
endmodule
