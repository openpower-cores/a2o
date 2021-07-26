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

//********************************************************************
//*
//* TITLE:
//*
//* NAME: iuq_dec_top.vhdl
//*
//*********************************************************************


`include "tri_a2o.vh"

module iuq_dec_top(
   inout                         vdd,
   inout                         gnd,
   input [0:`NCLK_WIDTH-1]       nclk,
   input                         pc_iu_sg_2,
   input                         pc_iu_func_sl_thold_2,
   input                         clkoff_b,
   input                         act_dis,
   input                         tc_ac_ccflush_dc,
   input                         d_mode,
   input                         delay_lclkr,
   input                         mpw1_b,
   input                         mpw2_b,
   input [0:3]                   scan_in,
   output [0:3]                  scan_out,

   input                         xu_iu_epcr_dgtmi,
   input                         xu_iu_msrp_uclep,
   input                         xu_iu_msr_pr,
   input                         xu_iu_msr_gs,
   input                         xu_iu_msr_ucle,
   input                         xu_iu_ccr2_ucode_dis,

   input [0:31]                  spr_dec_mask,
   input [0:31]                  spr_dec_match,
   input [0:7]                   iu_au_config_iucr,
   input                         mm_iu_tlbwe_binv,

   input                         cp_iu_iu4_flush,
   input			 uc_ib_iu3_flush_all,
   input                         br_iu_redirect,

   input                         ib_id_iu4_0_valid,
   input [62-`EFF_IFAR_WIDTH:61]  ib_id_iu4_0_ifar,
   input [62-`EFF_IFAR_WIDTH:61]  ib_id_iu4_0_bta,
   input [0:69]                  ib_id_iu4_0_instr,
   input [0:2]                   ib_id_iu4_0_ucode,
   input [0:3]                   ib_id_iu4_0_ucode_ext,
   input                         ib_id_iu4_0_isram,
   input [0:31]                  ib_id_iu4_0_fuse_data,
   input                         ib_id_iu4_0_fuse_val,

   input                         ib_id_iu4_1_valid,
   input [62-`EFF_IFAR_WIDTH:61]  ib_id_iu4_1_ifar,
   input [62-`EFF_IFAR_WIDTH:61]  ib_id_iu4_1_bta,
   input [0:69]                  ib_id_iu4_1_instr,
   input [0:2]                   ib_id_iu4_1_ucode,
   input [0:3]                   ib_id_iu4_1_ucode_ext,
   input                         ib_id_iu4_1_isram,
   input [0:31]                  ib_id_iu4_1_fuse_data,
   input                         ib_id_iu4_1_fuse_val,

   output                        id_ib_iu4_stall,

   // Decoded instruction to send to rename
   output                        fdec_frn_iu5_i0_vld,
   output [0:2]                  fdec_frn_iu5_i0_ucode,
   output                        fdec_frn_iu5_i0_2ucode,
   output                        fdec_frn_iu5_i0_fuse_nop,
   output                        fdec_frn_iu5_i0_rte_lq,
   output                        fdec_frn_iu5_i0_rte_sq,
   output                        fdec_frn_iu5_i0_rte_fx0,
   output                        fdec_frn_iu5_i0_rte_fx1,
   output                        fdec_frn_iu5_i0_rte_axu0,
   output                        fdec_frn_iu5_i0_rte_axu1,
   output                        fdec_frn_iu5_i0_valop,
   output                        fdec_frn_iu5_i0_ord,
   output                        fdec_frn_iu5_i0_cord,
   output [0:2]                  fdec_frn_iu5_i0_error,
   output [0:19]                 fdec_frn_iu5_i0_fusion,
   output                        fdec_frn_iu5_i0_spec,
   output                        fdec_frn_iu5_i0_type_fp,
   output                        fdec_frn_iu5_i0_type_ap,
   output                        fdec_frn_iu5_i0_type_spv,
   output                        fdec_frn_iu5_i0_type_st,
   output                        fdec_frn_iu5_i0_async_block,
   output                        fdec_frn_iu5_i0_np1_flush,
   output                        fdec_frn_iu5_i0_core_block,
   output                        fdec_frn_iu5_i0_isram,
   output                        fdec_frn_iu5_i0_isload,
   output                        fdec_frn_iu5_i0_isstore,
   output [0:31]                 fdec_frn_iu5_i0_instr,
   output [62-`EFF_IFAR_WIDTH:61] fdec_frn_iu5_i0_ifar,
   output [62-`EFF_IFAR_WIDTH:61] fdec_frn_iu5_i0_bta,
   output [0:3]                  fdec_frn_iu5_i0_ilat,
   output                        fdec_frn_iu5_i0_t1_v,
   output [0:2]                  fdec_frn_iu5_i0_t1_t,
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_i0_t1_a,
   output                        fdec_frn_iu5_i0_t2_v,
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_i0_t2_a,
   output [0:2]                  fdec_frn_iu5_i0_t2_t,
   output                        fdec_frn_iu5_i0_t3_v,
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_i0_t3_a,
   output [0:2]                  fdec_frn_iu5_i0_t3_t,
   output                        fdec_frn_iu5_i0_s1_v,
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_i0_s1_a,
   output [0:2]                  fdec_frn_iu5_i0_s1_t,
   output                        fdec_frn_iu5_i0_s2_v,
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_i0_s2_a,
   output [0:2]                  fdec_frn_iu5_i0_s2_t,
   output                        fdec_frn_iu5_i0_s3_v,
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_i0_s3_a,
   output [0:2]                  fdec_frn_iu5_i0_s3_t,
   output                        fdec_frn_iu5_i0_br_pred,
   output                        fdec_frn_iu5_i0_bh_update,
   output [0:1]                  fdec_frn_iu5_i0_bh0_hist,
   output [0:1]                  fdec_frn_iu5_i0_bh1_hist,
   output [0:1]                  fdec_frn_iu5_i0_bh2_hist,
   output [0:17]                  fdec_frn_iu5_i0_gshare,
   output [0:2]                  fdec_frn_iu5_i0_ls_ptr,
   output                        fdec_frn_iu5_i0_match,
   output                        fdec_frn_iu5_i0_btb_entry,
   output [0:1]                  fdec_frn_iu5_i0_btb_hist,
   output                        fdec_frn_iu5_i0_bta_val,

   output                        fdec_frn_iu5_i1_vld,
   output [0:2]                  fdec_frn_iu5_i1_ucode,
   output                        fdec_frn_iu5_i1_fuse_nop,
   output                        fdec_frn_iu5_i1_rte_lq,
   output                        fdec_frn_iu5_i1_rte_sq,
   output                        fdec_frn_iu5_i1_rte_fx0,
   output                        fdec_frn_iu5_i1_rte_fx1,
   output                        fdec_frn_iu5_i1_rte_axu0,
   output                        fdec_frn_iu5_i1_rte_axu1,
   output                        fdec_frn_iu5_i1_valop,
   output                        fdec_frn_iu5_i1_ord,
   output                        fdec_frn_iu5_i1_cord,
   output [0:2]                  fdec_frn_iu5_i1_error,
   output [0:19]                 fdec_frn_iu5_i1_fusion,
   output                        fdec_frn_iu5_i1_spec,
   output                        fdec_frn_iu5_i1_type_fp,
   output                        fdec_frn_iu5_i1_type_ap,
   output                        fdec_frn_iu5_i1_type_spv,
   output                        fdec_frn_iu5_i1_type_st,
   output                        fdec_frn_iu5_i1_async_block,
   output                        fdec_frn_iu5_i1_np1_flush,
   output                        fdec_frn_iu5_i1_core_block,
   output                        fdec_frn_iu5_i1_isram,
   output                        fdec_frn_iu5_i1_isload,
   output                        fdec_frn_iu5_i1_isstore,
   output [0:31]                 fdec_frn_iu5_i1_instr,
   output [62-`EFF_IFAR_WIDTH:61] fdec_frn_iu5_i1_ifar,
   output [62-`EFF_IFAR_WIDTH:61] fdec_frn_iu5_i1_bta,
   output [0:3]                  fdec_frn_iu5_i1_ilat,
   output                        fdec_frn_iu5_i1_t1_v,
   output [0:2]                  fdec_frn_iu5_i1_t1_t,
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_i1_t1_a,
   output                        fdec_frn_iu5_i1_t2_v,
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_i1_t2_a,
   output [0:2]                  fdec_frn_iu5_i1_t2_t,
   output                        fdec_frn_iu5_i1_t3_v,
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_i1_t3_a,
   output [0:2]                  fdec_frn_iu5_i1_t3_t,
   output                        fdec_frn_iu5_i1_s1_v,
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_i1_s1_a,
   output [0:2]                  fdec_frn_iu5_i1_s1_t,
   output                        fdec_frn_iu5_i1_s2_v,
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_i1_s2_a,
   output [0:2]                  fdec_frn_iu5_i1_s2_t,
   output                        fdec_frn_iu5_i1_s3_v,
   output [0:`GPR_POOL_ENC-1]     fdec_frn_iu5_i1_s3_a,
   output [0:2]                  fdec_frn_iu5_i1_s3_t,
   output                        fdec_frn_iu5_i1_br_pred,
   output                        fdec_frn_iu5_i1_bh_update,
   output [0:1]                  fdec_frn_iu5_i1_bh0_hist,
   output [0:1]                  fdec_frn_iu5_i1_bh1_hist,
   output [0:1]                  fdec_frn_iu5_i1_bh2_hist,
   output [0:17]                  fdec_frn_iu5_i1_gshare,
   output [0:2]                  fdec_frn_iu5_i1_ls_ptr,
   output                        fdec_frn_iu5_i1_match,
   output                        fdec_frn_iu5_i1_btb_entry,
   output [0:1]                  fdec_frn_iu5_i1_btb_hist,
   output                        fdec_frn_iu5_i1_bta_val,

   input                         frn_fdec_iu5_stall
   );

   //AXU Interface
   wire                          au_iu_iu4_i0_i_dec_b;
   wire [0:2]                    au_iu_iu4_i0_ucode;
   wire                          au_iu_iu4_i0_t1_v;
   wire [0:2]                    au_iu_iu4_i0_t1_t;
   wire [0:`GPR_POOL_ENC-1]       au_iu_iu4_i0_t1_a;
   wire                          au_iu_iu4_i0_t2_v;
   wire [0:`GPR_POOL_ENC-1]       au_iu_iu4_i0_t2_a;
   wire [0:2]                    au_iu_iu4_i0_t2_t;
   wire                          au_iu_iu4_i0_t3_v;
   wire [0:`GPR_POOL_ENC-1]       au_iu_iu4_i0_t3_a;
   wire [0:2]                    au_iu_iu4_i0_t3_t;
   wire                          au_iu_iu4_i0_s1_v;
   wire [0:`GPR_POOL_ENC-1]       au_iu_iu4_i0_s1_a;
   wire [0:2]                    au_iu_iu4_i0_s1_t;
   wire                          au_iu_iu4_i0_s2_v;
   wire [0:`GPR_POOL_ENC-1]       au_iu_iu4_i0_s2_a;
   wire [0:2]                    au_iu_iu4_i0_s2_t;
   wire                          au_iu_iu4_i0_s3_v;
   wire [0:`GPR_POOL_ENC-1]       au_iu_iu4_i0_s3_a;
   wire [0:2]                    au_iu_iu4_i0_s3_t;
   wire [0:2]                    au_iu_iu4_i0_ilat;
   wire                          au_iu_iu4_i0_ord;
   wire                          au_iu_iu4_i0_cord;
   wire                          au_iu_iu4_i0_spec;
   wire                          au_iu_iu4_i0_type_fp;
   wire                          au_iu_iu4_i0_type_ap;
   wire                          au_iu_iu4_i0_type_spv;
   wire                          au_iu_iu4_i0_type_st;
   wire                          au_iu_iu4_i0_async_block;
   wire                          au_iu_iu4_i0_isload;
   wire                          au_iu_iu4_i0_isstore;
   wire                          au_iu_iu4_i0_rte_lq;
   wire                          au_iu_iu4_i0_rte_sq;
   wire                          au_iu_iu4_i0_rte_axu0;
   wire                          au_iu_iu4_i0_rte_axu1;
   wire                          au_iu_iu4_i0_no_ram;

   wire                          au_iu_iu4_i1_i_dec_b;		// decoded a valid FU instruction (inverted) 0509
   wire [0:2]                    au_iu_iu4_i1_ucode;
   wire                          au_iu_iu4_i1_t1_v;
   wire [0:2]                    au_iu_iu4_i1_t1_t;
   wire [0:`GPR_POOL_ENC-1]       au_iu_iu4_i1_t1_a;
   wire                          au_iu_iu4_i1_t2_v;
   wire [0:`GPR_POOL_ENC-1]       au_iu_iu4_i1_t2_a;
   wire [0:2]                    au_iu_iu4_i1_t2_t;
   wire                          au_iu_iu4_i1_t3_v;
   wire [0:`GPR_POOL_ENC-1]       au_iu_iu4_i1_t3_a;
   wire [0:2]                    au_iu_iu4_i1_t3_t;
   wire                          au_iu_iu4_i1_s1_v;
   wire [0:`GPR_POOL_ENC-1]       au_iu_iu4_i1_s1_a;
   wire [0:2]                    au_iu_iu4_i1_s1_t;
   wire                          au_iu_iu4_i1_s2_v;
   wire [0:`GPR_POOL_ENC-1]       au_iu_iu4_i1_s2_a;
   wire [0:2]                    au_iu_iu4_i1_s2_t;
   wire                          au_iu_iu4_i1_s3_v;
   wire [0:`GPR_POOL_ENC-1]       au_iu_iu4_i1_s3_a;
   wire [0:2]                    au_iu_iu4_i1_s3_t;
   wire [0:2]                    au_iu_iu4_i1_ilat;
   wire                          au_iu_iu4_i1_ord;
   wire                          au_iu_iu4_i1_cord;
   wire                          au_iu_iu4_i1_spec;
   wire                          au_iu_iu4_i1_type_fp;
   wire                          au_iu_iu4_i1_type_ap;
   wire                          au_iu_iu4_i1_type_spv;
   wire                          au_iu_iu4_i1_type_st;
   wire                          au_iu_iu4_i1_async_block;
   wire                          au_iu_iu4_i1_isload;
   wire                          au_iu_iu4_i1_isstore;
   wire                          au_iu_iu4_i1_rte_lq;
   wire                          au_iu_iu4_i1_rte_sq;
   wire                          au_iu_iu4_i1_rte_axu0;
   wire                          au_iu_iu4_i1_rte_axu1;
   wire                          au_iu_iu4_i1_no_ram;

   wire                          fdec_frn_iu5_i0_vld_int;
   wire                          iu5_stall;

   assign iu5_stall = frn_fdec_iu5_stall & fdec_frn_iu5_i0_vld_int;
   assign id_ib_iu4_stall = iu5_stall;
   assign fdec_frn_iu5_i0_vld = fdec_frn_iu5_i0_vld_int;

   iuq_idec  fx_dec0(
  		.vdd(vdd),
  		.gnd(gnd),
  		.nclk(nclk),
  		.pc_iu_sg_2(pc_iu_sg_2),
  		.pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
  		.clkoff_b(clkoff_b),
  		.act_dis(act_dis),
  		.tc_ac_ccflush_dc(tc_ac_ccflush_dc),
  		.d_mode(d_mode),
  		.delay_lclkr(delay_lclkr),
  		.mpw1_b(mpw1_b),
  		.mpw2_b(mpw2_b),
  		.scan_in(scan_in[0]),
  		.scan_out(scan_out[0]),

  		.xu_iu_epcr_dgtmi(xu_iu_epcr_dgtmi),
  		.xu_iu_msrp_uclep(xu_iu_msrp_uclep),
  		.xu_iu_msr_pr(xu_iu_msr_pr),
  		.xu_iu_msr_gs(xu_iu_msr_gs),
  		.xu_iu_msr_ucle(xu_iu_msr_ucle),
  		.xu_iu_ccr2_ucode_dis(xu_iu_ccr2_ucode_dis),
  		.mm_iu_tlbwe_binv(mm_iu_tlbwe_binv),

  		.spr_dec_mask(spr_dec_mask),
  		.spr_dec_match(spr_dec_match),

  		.cp_iu_iu4_flush(cp_iu_iu4_flush),
                .uc_ib_iu3_flush_all(uc_ib_iu3_flush_all),
  		.br_iu_redirect(br_iu_redirect),

  		.ib_id_iu4_valid(ib_id_iu4_0_valid),
  		.ib_id_iu4_ifar(ib_id_iu4_0_ifar),
  		.ib_id_iu4_bta(ib_id_iu4_0_bta),
  		.ib_id_iu4_instr(ib_id_iu4_0_instr),
  		.ib_id_iu4_ucode(ib_id_iu4_0_ucode),
  		.ib_id_iu4_ucode_ext(ib_id_iu4_0_ucode_ext),
  		.ib_id_iu4_isram(ib_id_iu4_0_isram),
  		.ib_id_iu4_fuse_data(ib_id_iu4_0_fuse_data),
  		.ib_id_iu4_fuse_val(ib_id_iu4_0_fuse_val),

  		//AXU Interface
  		.au_iu_iu4_i_dec_b(au_iu_iu4_i0_i_dec_b),
  		.au_iu_iu4_ucode(au_iu_iu4_i0_ucode),
  		.au_iu_iu4_t1_v(au_iu_iu4_i0_t1_v),
  		.au_iu_iu4_t1_t(au_iu_iu4_i0_t1_t),
  		.au_iu_iu4_t1_a(au_iu_iu4_i0_t1_a),
  		.au_iu_iu4_t2_v(au_iu_iu4_i0_t2_v),
  		.au_iu_iu4_t2_a(au_iu_iu4_i0_t2_a),
  		.au_iu_iu4_t2_t(au_iu_iu4_i0_t2_t),
  		.au_iu_iu4_t3_v(au_iu_iu4_i0_t3_v),
  		.au_iu_iu4_t3_a(au_iu_iu4_i0_t3_a),
  		.au_iu_iu4_t3_t(au_iu_iu4_i0_t3_t),
  		.au_iu_iu4_s1_v(au_iu_iu4_i0_s1_v),
  		.au_iu_iu4_s1_a(au_iu_iu4_i0_s1_a),
  		.au_iu_iu4_s1_t(au_iu_iu4_i0_s1_t),
  		.au_iu_iu4_s2_v(au_iu_iu4_i0_s2_v),
  		.au_iu_iu4_s2_a(au_iu_iu4_i0_s2_a),
  		.au_iu_iu4_s2_t(au_iu_iu4_i0_s2_t),
  		.au_iu_iu4_s3_v(au_iu_iu4_i0_s3_v),
  		.au_iu_iu4_s3_a(au_iu_iu4_i0_s3_a),
  		.au_iu_iu4_s3_t(au_iu_iu4_i0_s3_t),
  		.au_iu_iu4_ilat(au_iu_iu4_i0_ilat),
  		.au_iu_iu4_ord(au_iu_iu4_i0_ord),
  		.au_iu_iu4_cord(au_iu_iu4_i0_cord),
  		.au_iu_iu4_spec(au_iu_iu4_i0_spec),
  		.au_iu_iu4_type_fp(au_iu_iu4_i0_type_fp),
  		.au_iu_iu4_type_ap(au_iu_iu4_i0_type_ap),
  		.au_iu_iu4_type_spv(au_iu_iu4_i0_type_spv),
  		.au_iu_iu4_type_st(au_iu_iu4_i0_type_st),
  		.au_iu_iu4_async_block(au_iu_iu4_i0_async_block),
  		.au_iu_iu4_isload(au_iu_iu4_i0_isload),
  		.au_iu_iu4_isstore(au_iu_iu4_i0_isstore),
  		.au_iu_iu4_rte_lq(au_iu_iu4_i0_rte_lq),
  		.au_iu_iu4_rte_sq(au_iu_iu4_i0_rte_sq),
  		.au_iu_iu4_rte_axu0(au_iu_iu4_i0_rte_axu0),
  		.au_iu_iu4_rte_axu1(au_iu_iu4_i0_rte_axu1),
  		.au_iu_iu4_no_ram(au_iu_iu4_i0_no_ram),

  		// Decoded instruction to send to rename
  		.fdec_frn_iu5_ix_vld(fdec_frn_iu5_i0_vld_int),
  		.fdec_frn_iu5_ix_ucode(fdec_frn_iu5_i0_ucode),
  		.fdec_frn_iu5_ix_2ucode(fdec_frn_iu5_i0_2ucode),
  		.fdec_frn_iu5_ix_fuse_nop(fdec_frn_iu5_i0_fuse_nop),
  		.fdec_frn_iu5_ix_rte_lq(fdec_frn_iu5_i0_rte_lq),
  		.fdec_frn_iu5_ix_rte_sq(fdec_frn_iu5_i0_rte_sq),
  		.fdec_frn_iu5_ix_rte_fx0(fdec_frn_iu5_i0_rte_fx0),
  		.fdec_frn_iu5_ix_rte_fx1(fdec_frn_iu5_i0_rte_fx1),
  		.fdec_frn_iu5_ix_rte_axu0(fdec_frn_iu5_i0_rte_axu0),
  		.fdec_frn_iu5_ix_rte_axu1(fdec_frn_iu5_i0_rte_axu1),
  		.fdec_frn_iu5_ix_valop(fdec_frn_iu5_i0_valop),
  		.fdec_frn_iu5_ix_ord(fdec_frn_iu5_i0_ord),
  		.fdec_frn_iu5_ix_cord(fdec_frn_iu5_i0_cord),
  		.fdec_frn_iu5_ix_error(fdec_frn_iu5_i0_error),
  		.fdec_frn_iu5_ix_fusion(fdec_frn_iu5_i0_fusion),
  		.fdec_frn_iu5_ix_spec(fdec_frn_iu5_i0_spec),
  		.fdec_frn_iu5_ix_type_fp(fdec_frn_iu5_i0_type_fp),
  		.fdec_frn_iu5_ix_type_ap(fdec_frn_iu5_i0_type_ap),
  		.fdec_frn_iu5_ix_type_spv(fdec_frn_iu5_i0_type_spv),
  		.fdec_frn_iu5_ix_type_st(fdec_frn_iu5_i0_type_st),
  		.fdec_frn_iu5_ix_async_block(fdec_frn_iu5_i0_async_block),
  		.fdec_frn_iu5_ix_np1_flush(fdec_frn_iu5_i0_np1_flush),
  		.fdec_frn_iu5_ix_core_block(fdec_frn_iu5_i0_core_block),
  		.fdec_frn_iu5_ix_isram(fdec_frn_iu5_i0_isram),
  		.fdec_frn_iu5_ix_isload(fdec_frn_iu5_i0_isload),
  		.fdec_frn_iu5_ix_isstore(fdec_frn_iu5_i0_isstore),
  		.fdec_frn_iu5_ix_instr(fdec_frn_iu5_i0_instr),
  		.fdec_frn_iu5_ix_ifar(fdec_frn_iu5_i0_ifar),
  		.fdec_frn_iu5_ix_bta(fdec_frn_iu5_i0_bta),
  		.fdec_frn_iu5_ix_ilat(fdec_frn_iu5_i0_ilat),
  		.fdec_frn_iu5_ix_t1_v(fdec_frn_iu5_i0_t1_v),
  		.fdec_frn_iu5_ix_t1_t(fdec_frn_iu5_i0_t1_t),
  		.fdec_frn_iu5_ix_t1_a(fdec_frn_iu5_i0_t1_a),
  		.fdec_frn_iu5_ix_t2_v(fdec_frn_iu5_i0_t2_v),
  		.fdec_frn_iu5_ix_t2_a(fdec_frn_iu5_i0_t2_a),
  		.fdec_frn_iu5_ix_t2_t(fdec_frn_iu5_i0_t2_t),
  		.fdec_frn_iu5_ix_t3_v(fdec_frn_iu5_i0_t3_v),
  		.fdec_frn_iu5_ix_t3_a(fdec_frn_iu5_i0_t3_a),
  		.fdec_frn_iu5_ix_t3_t(fdec_frn_iu5_i0_t3_t),
  		.fdec_frn_iu5_ix_s1_v(fdec_frn_iu5_i0_s1_v),
  		.fdec_frn_iu5_ix_s1_a(fdec_frn_iu5_i0_s1_a),
  		.fdec_frn_iu5_ix_s1_t(fdec_frn_iu5_i0_s1_t),
  		.fdec_frn_iu5_ix_s2_v(fdec_frn_iu5_i0_s2_v),
  		.fdec_frn_iu5_ix_s2_a(fdec_frn_iu5_i0_s2_a),
  		.fdec_frn_iu5_ix_s2_t(fdec_frn_iu5_i0_s2_t),
  		.fdec_frn_iu5_ix_s3_v(fdec_frn_iu5_i0_s3_v),
  		.fdec_frn_iu5_ix_s3_a(fdec_frn_iu5_i0_s3_a),
  		.fdec_frn_iu5_ix_s3_t(fdec_frn_iu5_i0_s3_t),
  		.fdec_frn_iu5_ix_br_pred(fdec_frn_iu5_i0_br_pred),
  		.fdec_frn_iu5_ix_bh_update(fdec_frn_iu5_i0_bh_update),
  		.fdec_frn_iu5_ix_bh0_hist(fdec_frn_iu5_i0_bh0_hist),
  		.fdec_frn_iu5_ix_bh1_hist(fdec_frn_iu5_i0_bh1_hist),
  		.fdec_frn_iu5_ix_bh2_hist(fdec_frn_iu5_i0_bh2_hist),
  		.fdec_frn_iu5_ix_gshare(fdec_frn_iu5_i0_gshare),
  		.fdec_frn_iu5_ix_ls_ptr(fdec_frn_iu5_i0_ls_ptr),
  		.fdec_frn_iu5_ix_match(fdec_frn_iu5_i0_match),
  		.fdec_frn_iu5_ix_btb_entry(fdec_frn_iu5_i0_btb_entry),
  		.fdec_frn_iu5_ix_btb_hist(fdec_frn_iu5_i0_btb_hist),
  		.fdec_frn_iu5_ix_bta_val(fdec_frn_iu5_i0_bta_val),

  		.frn_fdec_iu5_stall(iu5_stall)
   );

   iuq_idec  fx_dec1(
   	.vdd(vdd),
   	.gnd(gnd),
   	.nclk(nclk),
   	.pc_iu_sg_2(pc_iu_sg_2),
   	.pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
   	.clkoff_b(clkoff_b),
   	.act_dis(act_dis),
   	.tc_ac_ccflush_dc(tc_ac_ccflush_dc),
   	.d_mode(d_mode),
   	.delay_lclkr(delay_lclkr),
   	.mpw1_b(mpw1_b),
   	.mpw2_b(mpw2_b),
   	.scan_in(scan_in[1]),
   	.scan_out(scan_out[1]),

   	.xu_iu_epcr_dgtmi(xu_iu_epcr_dgtmi),
   	.xu_iu_msrp_uclep(xu_iu_msrp_uclep),
   	.xu_iu_msr_pr(xu_iu_msr_pr),
   	.xu_iu_msr_gs(xu_iu_msr_gs),
   	.xu_iu_msr_ucle(xu_iu_msr_ucle),
   	.xu_iu_ccr2_ucode_dis(xu_iu_ccr2_ucode_dis),
   	.mm_iu_tlbwe_binv(mm_iu_tlbwe_binv),

   	.spr_dec_mask(spr_dec_mask),
   	.spr_dec_match(spr_dec_match),

   	.cp_iu_iu4_flush(cp_iu_iu4_flush),
        .uc_ib_iu3_flush_all(uc_ib_iu3_flush_all),
   	.br_iu_redirect(br_iu_redirect),

   	.ib_id_iu4_valid(ib_id_iu4_1_valid),
   	.ib_id_iu4_ifar(ib_id_iu4_1_ifar),
   	.ib_id_iu4_bta(ib_id_iu4_1_bta),
   	.ib_id_iu4_instr(ib_id_iu4_1_instr),
   	.ib_id_iu4_ucode(ib_id_iu4_1_ucode),
   	.ib_id_iu4_ucode_ext(ib_id_iu4_1_ucode_ext),
   	.ib_id_iu4_isram(ib_id_iu4_1_isram),
   	.ib_id_iu4_fuse_data(ib_id_iu4_1_fuse_data),
   	.ib_id_iu4_fuse_val(ib_id_iu4_1_fuse_val),

   	//AXU Interface
   	.au_iu_iu4_i_dec_b(au_iu_iu4_i1_i_dec_b),
   	.au_iu_iu4_ucode(au_iu_iu4_i1_ucode),
   	.au_iu_iu4_t1_v(au_iu_iu4_i1_t1_v),
   	.au_iu_iu4_t1_t(au_iu_iu4_i1_t1_t),
   	.au_iu_iu4_t1_a(au_iu_iu4_i1_t1_a),
   	.au_iu_iu4_t2_v(au_iu_iu4_i1_t2_v),
   	.au_iu_iu4_t2_a(au_iu_iu4_i1_t2_a),
   	.au_iu_iu4_t2_t(au_iu_iu4_i1_t2_t),
   	.au_iu_iu4_t3_v(au_iu_iu4_i1_t3_v),
   	.au_iu_iu4_t3_a(au_iu_iu4_i1_t3_a),
   	.au_iu_iu4_t3_t(au_iu_iu4_i1_t3_t),
   	.au_iu_iu4_s1_v(au_iu_iu4_i1_s1_v),
   	.au_iu_iu4_s1_a(au_iu_iu4_i1_s1_a),
   	.au_iu_iu4_s1_t(au_iu_iu4_i1_s1_t),
   	.au_iu_iu4_s2_v(au_iu_iu4_i1_s2_v),
   	.au_iu_iu4_s2_a(au_iu_iu4_i1_s2_a),
   	.au_iu_iu4_s2_t(au_iu_iu4_i1_s2_t),
   	.au_iu_iu4_s3_v(au_iu_iu4_i1_s3_v),
   	.au_iu_iu4_s3_a(au_iu_iu4_i1_s3_a),
   	.au_iu_iu4_s3_t(au_iu_iu4_i1_s3_t),
   	.au_iu_iu4_ilat(au_iu_iu4_i1_ilat),
   	.au_iu_iu4_ord(au_iu_iu4_i1_ord),
   	.au_iu_iu4_cord(au_iu_iu4_i1_cord),
   	.au_iu_iu4_spec(au_iu_iu4_i1_spec),
   	.au_iu_iu4_type_fp(au_iu_iu4_i1_type_fp),
   	.au_iu_iu4_type_ap(au_iu_iu4_i1_type_ap),
   	.au_iu_iu4_type_spv(au_iu_iu4_i1_type_spv),
   	.au_iu_iu4_type_st(au_iu_iu4_i1_type_st),
   	.au_iu_iu4_async_block(au_iu_iu4_i1_async_block),
   	.au_iu_iu4_isload(au_iu_iu4_i1_isload),
   	.au_iu_iu4_isstore(au_iu_iu4_i1_isstore),
   	.au_iu_iu4_rte_lq(au_iu_iu4_i1_rte_lq),
   	.au_iu_iu4_rte_sq(au_iu_iu4_i1_rte_sq),
   	.au_iu_iu4_rte_axu0(au_iu_iu4_i1_rte_axu0),
   	.au_iu_iu4_rte_axu1(au_iu_iu4_i1_rte_axu1),
   	.au_iu_iu4_no_ram(au_iu_iu4_i1_no_ram),

   	// Decoded instruction to send to rename
   	.fdec_frn_iu5_ix_vld(fdec_frn_iu5_i1_vld),
   	.fdec_frn_iu5_ix_ucode(fdec_frn_iu5_i1_ucode),
   	.fdec_frn_iu5_ix_2ucode(),
   	.fdec_frn_iu5_ix_fuse_nop(fdec_frn_iu5_i1_fuse_nop),
   	.fdec_frn_iu5_ix_rte_lq(fdec_frn_iu5_i1_rte_lq),
   	.fdec_frn_iu5_ix_rte_sq(fdec_frn_iu5_i1_rte_sq),
   	.fdec_frn_iu5_ix_rte_fx0(fdec_frn_iu5_i1_rte_fx0),
   	.fdec_frn_iu5_ix_rte_fx1(fdec_frn_iu5_i1_rte_fx1),
   	.fdec_frn_iu5_ix_rte_axu0(fdec_frn_iu5_i1_rte_axu0),
   	.fdec_frn_iu5_ix_rte_axu1(fdec_frn_iu5_i1_rte_axu1),
   	.fdec_frn_iu5_ix_valop(fdec_frn_iu5_i1_valop),
   	.fdec_frn_iu5_ix_ord(fdec_frn_iu5_i1_ord),
   	.fdec_frn_iu5_ix_cord(fdec_frn_iu5_i1_cord),
   	.fdec_frn_iu5_ix_error(fdec_frn_iu5_i1_error),
   	.fdec_frn_iu5_ix_fusion(fdec_frn_iu5_i1_fusion),
   	.fdec_frn_iu5_ix_spec(fdec_frn_iu5_i1_spec),
   	.fdec_frn_iu5_ix_type_fp(fdec_frn_iu5_i1_type_fp),
   	.fdec_frn_iu5_ix_type_ap(fdec_frn_iu5_i1_type_ap),
   	.fdec_frn_iu5_ix_type_spv(fdec_frn_iu5_i1_type_spv),
   	.fdec_frn_iu5_ix_type_st(fdec_frn_iu5_i1_type_st),
   	.fdec_frn_iu5_ix_async_block(fdec_frn_iu5_i1_async_block),
   	.fdec_frn_iu5_ix_np1_flush(fdec_frn_iu5_i1_np1_flush),
   	.fdec_frn_iu5_ix_core_block(fdec_frn_iu5_i1_core_block),
   	.fdec_frn_iu5_ix_isram(fdec_frn_iu5_i1_isram),
   	.fdec_frn_iu5_ix_isload(fdec_frn_iu5_i1_isload),
   	.fdec_frn_iu5_ix_isstore(fdec_frn_iu5_i1_isstore),
   	.fdec_frn_iu5_ix_instr(fdec_frn_iu5_i1_instr),
   	.fdec_frn_iu5_ix_ifar(fdec_frn_iu5_i1_ifar),
   	.fdec_frn_iu5_ix_bta(fdec_frn_iu5_i1_bta),
   	.fdec_frn_iu5_ix_ilat(fdec_frn_iu5_i1_ilat),
   	.fdec_frn_iu5_ix_t1_v(fdec_frn_iu5_i1_t1_v),
   	.fdec_frn_iu5_ix_t1_t(fdec_frn_iu5_i1_t1_t),
   	.fdec_frn_iu5_ix_t1_a(fdec_frn_iu5_i1_t1_a),
   	.fdec_frn_iu5_ix_t2_v(fdec_frn_iu5_i1_t2_v),
   	.fdec_frn_iu5_ix_t2_a(fdec_frn_iu5_i1_t2_a),
   	.fdec_frn_iu5_ix_t2_t(fdec_frn_iu5_i1_t2_t),
   	.fdec_frn_iu5_ix_t3_v(fdec_frn_iu5_i1_t3_v),
   	.fdec_frn_iu5_ix_t3_a(fdec_frn_iu5_i1_t3_a),
   	.fdec_frn_iu5_ix_t3_t(fdec_frn_iu5_i1_t3_t),
   	.fdec_frn_iu5_ix_s1_v(fdec_frn_iu5_i1_s1_v),
   	.fdec_frn_iu5_ix_s1_a(fdec_frn_iu5_i1_s1_a),
   	.fdec_frn_iu5_ix_s1_t(fdec_frn_iu5_i1_s1_t),
   	.fdec_frn_iu5_ix_s2_v(fdec_frn_iu5_i1_s2_v),
   	.fdec_frn_iu5_ix_s2_a(fdec_frn_iu5_i1_s2_a),
   	.fdec_frn_iu5_ix_s2_t(fdec_frn_iu5_i1_s2_t),
   	.fdec_frn_iu5_ix_s3_v(fdec_frn_iu5_i1_s3_v),
   	.fdec_frn_iu5_ix_s3_a(fdec_frn_iu5_i1_s3_a),
   	.fdec_frn_iu5_ix_s3_t(fdec_frn_iu5_i1_s3_t),
   	.fdec_frn_iu5_ix_br_pred(fdec_frn_iu5_i1_br_pred),
   	.fdec_frn_iu5_ix_bh_update(fdec_frn_iu5_i1_bh_update),
   	.fdec_frn_iu5_ix_bh0_hist(fdec_frn_iu5_i1_bh0_hist),
   	.fdec_frn_iu5_ix_bh1_hist(fdec_frn_iu5_i1_bh1_hist),
   	.fdec_frn_iu5_ix_bh2_hist(fdec_frn_iu5_i1_bh2_hist),
   	.fdec_frn_iu5_ix_gshare(fdec_frn_iu5_i1_gshare),
   	.fdec_frn_iu5_ix_ls_ptr(fdec_frn_iu5_i1_ls_ptr),
   	.fdec_frn_iu5_ix_match(fdec_frn_iu5_i1_match),
   	.fdec_frn_iu5_ix_btb_entry(fdec_frn_iu5_i1_btb_entry),
   	.fdec_frn_iu5_ix_btb_hist(fdec_frn_iu5_i1_btb_hist),
   	.fdec_frn_iu5_ix_bta_val(fdec_frn_iu5_i1_bta_val),

   	.frn_fdec_iu5_stall(iu5_stall)
   );

   iuq_axu_fu_dec  axu_dec0(
	   .vdd(vdd),
	   .gnd(gnd),
	   .nclk(nclk),
	   .i_dec_si(scan_in[2]),
	   .i_dec_so(scan_out[2]),
	   .pc_iu_sg_2(pc_iu_sg_2),
	   .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
	   .clkoff_b(clkoff_b),
	   .act_dis(act_dis),
	   .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
	   .d_mode(d_mode),
	   .delay_lclkr(delay_lclkr),
	   .mpw1_b(mpw1_b),
	   .mpw2_b(mpw2_b),

	   .iu_au_iu4_isram(ib_id_iu4_0_isram),
	   .iu_au_ucode_restart(1'b0),
	   .iu_au_config_iucr(iu_au_config_iucr),
	   .iu_au_iu4_instr_v(ib_id_iu4_0_valid),
	   .iu_au_iu4_instr(ib_id_iu4_0_instr[0:31]),
	   .iu_au_iu4_ucode_ext(ib_id_iu4_0_ucode_ext),
	   .iu_au_iu4_ucode(ib_id_iu4_0_ucode),
	   .iu_au_iu4_2ucode(1'b0),
	   .au_iu_iu4_i_dec_b(au_iu_iu4_i0_i_dec_b),
	   .au_iu_iu4_ucode(au_iu_iu4_i0_ucode),
	   .au_iu_iu4_t1_v(au_iu_iu4_i0_t1_v),
	   .au_iu_iu4_t1_t(au_iu_iu4_i0_t1_t),
	   .au_iu_iu4_t1_a(au_iu_iu4_i0_t1_a),
	   .au_iu_iu4_t2_v(au_iu_iu4_i0_t2_v),
	   .au_iu_iu4_t2_a(au_iu_iu4_i0_t2_a),
	   .au_iu_iu4_t2_t(au_iu_iu4_i0_t2_t),
	   .au_iu_iu4_t3_v(au_iu_iu4_i0_t3_v),
	   .au_iu_iu4_t3_a(au_iu_iu4_i0_t3_a),
	   .au_iu_iu4_t3_t(au_iu_iu4_i0_t3_t),
	   .au_iu_iu4_s1_v(au_iu_iu4_i0_s1_v),
	   .au_iu_iu4_s1_a(au_iu_iu4_i0_s1_a),
	   .au_iu_iu4_s1_t(au_iu_iu4_i0_s1_t),
	   .au_iu_iu4_s2_v(au_iu_iu4_i0_s2_v),
	   .au_iu_iu4_s2_a(au_iu_iu4_i0_s2_a),
	   .au_iu_iu4_s2_t(au_iu_iu4_i0_s2_t),
	   .au_iu_iu4_s3_v(au_iu_iu4_i0_s3_v),
	   .au_iu_iu4_s3_a(au_iu_iu4_i0_s3_a),
	   .au_iu_iu4_s3_t(au_iu_iu4_i0_s3_t),
	   .au_iu_iu4_ilat(au_iu_iu4_i0_ilat),
	   .au_iu_iu4_ord(au_iu_iu4_i0_ord),
	   .au_iu_iu4_cord(au_iu_iu4_i0_cord),
	   .au_iu_iu4_spec(au_iu_iu4_i0_spec),
	   .au_iu_iu4_type_fp(au_iu_iu4_i0_type_fp),
	   .au_iu_iu4_type_ap(au_iu_iu4_i0_type_ap),
	   .au_iu_iu4_type_spv(au_iu_iu4_i0_type_spv),
	   .au_iu_iu4_type_st(au_iu_iu4_i0_type_st),
	   .au_iu_iu4_async_block(au_iu_iu4_i0_async_block),
	   .au_iu_iu4_isload(au_iu_iu4_i0_isload),
	   .au_iu_iu4_isstore(au_iu_iu4_i0_isstore),
	   .au_iu_iu4_rte_lq(au_iu_iu4_i0_rte_lq),
	   .au_iu_iu4_rte_sq(au_iu_iu4_i0_rte_sq),
	   .au_iu_iu4_rte_axu0(au_iu_iu4_i0_rte_axu0),
	   .au_iu_iu4_rte_axu1(au_iu_iu4_i0_rte_axu1),
	   .au_iu_iu4_no_ram(au_iu_iu4_i0_no_ram)
   );

   iuq_axu_fu_dec  axu_dec1(
   	.vdd(vdd),
   	.gnd(gnd),
   	.nclk(nclk),
   	.i_dec_si(scan_in[3]),
   	.i_dec_so(scan_out[3]),
   	.pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
   	.pc_iu_sg_2(pc_iu_sg_2),
   	.clkoff_b(clkoff_b),
   	.act_dis(act_dis),
   	.tc_ac_ccflush_dc(tc_ac_ccflush_dc),
   	.d_mode(d_mode),
   	.delay_lclkr(delay_lclkr),
   	.mpw1_b(mpw1_b),
   	.mpw2_b(mpw2_b),

   	.iu_au_iu4_isram(ib_id_iu4_1_isram),
   	.iu_au_ucode_restart(1'b0),
   	.iu_au_config_iucr(iu_au_config_iucr),
   	.iu_au_iu4_instr_v(ib_id_iu4_1_valid),
   	.iu_au_iu4_instr(ib_id_iu4_1_instr[0:31]),
   	.iu_au_iu4_ucode_ext(ib_id_iu4_1_ucode_ext),
   	.iu_au_iu4_ucode(ib_id_iu4_1_ucode),
   	.iu_au_iu4_2ucode(1'b0),
   	.au_iu_iu4_i_dec_b(au_iu_iu4_i1_i_dec_b),
   	.au_iu_iu4_ucode(au_iu_iu4_i1_ucode),
   	.au_iu_iu4_t1_v(au_iu_iu4_i1_t1_v),
   	.au_iu_iu4_t1_t(au_iu_iu4_i1_t1_t),
   	.au_iu_iu4_t1_a(au_iu_iu4_i1_t1_a),
   	.au_iu_iu4_t2_v(au_iu_iu4_i1_t2_v),
   	.au_iu_iu4_t2_a(au_iu_iu4_i1_t2_a),
   	.au_iu_iu4_t2_t(au_iu_iu4_i1_t2_t),
   	.au_iu_iu4_t3_v(au_iu_iu4_i1_t3_v),
   	.au_iu_iu4_t3_a(au_iu_iu4_i1_t3_a),
   	.au_iu_iu4_t3_t(au_iu_iu4_i1_t3_t),
   	.au_iu_iu4_s1_v(au_iu_iu4_i1_s1_v),
   	.au_iu_iu4_s1_a(au_iu_iu4_i1_s1_a),
   	.au_iu_iu4_s1_t(au_iu_iu4_i1_s1_t),
   	.au_iu_iu4_s2_v(au_iu_iu4_i1_s2_v),
   	.au_iu_iu4_s2_a(au_iu_iu4_i1_s2_a),
   	.au_iu_iu4_s2_t(au_iu_iu4_i1_s2_t),
   	.au_iu_iu4_s3_v(au_iu_iu4_i1_s3_v),
   	.au_iu_iu4_s3_a(au_iu_iu4_i1_s3_a),
   	.au_iu_iu4_s3_t(au_iu_iu4_i1_s3_t),
   	.au_iu_iu4_ilat(au_iu_iu4_i1_ilat),
   	.au_iu_iu4_ord(au_iu_iu4_i1_ord),
   	.au_iu_iu4_cord(au_iu_iu4_i1_cord),
   	.au_iu_iu4_spec(au_iu_iu4_i1_spec),
   	.au_iu_iu4_type_fp(au_iu_iu4_i1_type_fp),
   	.au_iu_iu4_type_ap(au_iu_iu4_i1_type_ap),
   	.au_iu_iu4_type_spv(au_iu_iu4_i1_type_spv),
   	.au_iu_iu4_type_st(au_iu_iu4_i1_type_st),
   	.au_iu_iu4_async_block(au_iu_iu4_i1_async_block),
   	.au_iu_iu4_isload(au_iu_iu4_i1_isload),
   	.au_iu_iu4_isstore(au_iu_iu4_i1_isstore),
   	.au_iu_iu4_rte_lq(au_iu_iu4_i1_rte_lq),
   	.au_iu_iu4_rte_sq(au_iu_iu4_i1_rte_sq),
   	.au_iu_iu4_rte_axu0(au_iu_iu4_i1_rte_axu0),
   	.au_iu_iu4_rte_axu1(au_iu_iu4_i1_rte_axu1),
   	.au_iu_iu4_no_ram(au_iu_iu4_i1_no_ram)
   );

endmodule
