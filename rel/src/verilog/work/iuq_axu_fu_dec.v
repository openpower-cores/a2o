// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns







`include "tri_a2o.vh"

module iuq_axu_fu_dec(
   input [0:`NCLK_WIDTH-1]   nclk,
   inout                     vdd,
   inout                     gnd,
   
   input                     i_dec_si,
   output                    i_dec_so,
   
   input                     pc_iu_sg_2,
   input                     pc_iu_func_sl_thold_2,
   input                     clkoff_b,
   input                     act_dis,
   input                     tc_ac_ccflush_dc,
   input                     d_mode,
   input                     delay_lclkr,
   input                     mpw1_b,
   input                     mpw2_b,
   
   input                     iu_au_iu4_isram,
   
   input                     iu_au_iu4_instr_v,
   input [0:31]              iu_au_iu4_instr,
   input [0:3]               iu_au_iu4_ucode_ext,		
   input [0:2]               iu_au_iu4_ucode,
   input                     iu_au_iu4_2ucode,
   input                     iu_au_ucode_restart,
   
   
   input [0:7]               iu_au_config_iucr,		
   
   output                    au_iu_iu4_i_dec_b,		
   output [0:2]              au_iu_iu4_ucode,
   
   output                    au_iu_iu4_t1_v,
   output [0:2]              au_iu_iu4_t1_t,
   output [0:`GPR_POOL_ENC-1] au_iu_iu4_t1_a,
   
   output                    au_iu_iu4_t2_v,
   output [0:`GPR_POOL_ENC-1] au_iu_iu4_t2_a,
   output [0:2]              au_iu_iu4_t2_t,
   
   output                    au_iu_iu4_t3_v,
   output [0:`GPR_POOL_ENC-1] au_iu_iu4_t3_a,
   output [0:2]              au_iu_iu4_t3_t,
   
   output                    au_iu_iu4_s1_v,
   output [0:`GPR_POOL_ENC-1] au_iu_iu4_s1_a,
   output [0:2]              au_iu_iu4_s1_t,
   
   output                    au_iu_iu4_s2_v,
   output [0:`GPR_POOL_ENC-1] au_iu_iu4_s2_a,
   output [0:2]              au_iu_iu4_s2_t,
   
   output                    au_iu_iu4_s3_v,
   output [0:`GPR_POOL_ENC-1] au_iu_iu4_s3_a,
   output [0:2]              au_iu_iu4_s3_t,
   
   output [0:2]              au_iu_iu4_ilat,
   output                    au_iu_iu4_ord,
   output                    au_iu_iu4_cord,
   output                    au_iu_iu4_spec,
   output                    au_iu_iu4_type_fp,
   output                    au_iu_iu4_type_ap,
   output                    au_iu_iu4_type_spv,
   output                    au_iu_iu4_type_st,
   output                    au_iu_iu4_async_block,
   
   output                    au_iu_iu4_isload,
   output                    au_iu_iu4_isstore,
   
   output                    au_iu_iu4_rte_lq,
   output                    au_iu_iu4_rte_sq,
   output                    au_iu_iu4_rte_axu0,
   output                    au_iu_iu4_rte_axu1,
   
   output                    au_iu_iu4_no_ram,
   
   
   output [0:31]             fu_dec_debug
   );
   
   
   
      wire                      tidn;
      wire                      tiup;
      
      wire [0:5]                is0_ldst_ra;
      
      wire [0:7]                iu_au_config_iucr_int;
      wire [0:7]                iu_au_config_iucr_l2;
      wire [0:7]                iu_au_config_iucr_din;
      wire [00:31]              is0_instr;
      wire [0:5]                pri_is0;		
      wire [20:31]              sec_is0;		
      wire                      av;		
      wire                      bv;
      wire                      cv;
      wire                      tv;
      wire                      isfu_dec_is0;
      wire                      ld_st_is0;
      wire                      isLoad;
      wire                      isStore;
      
      wire                      st_is0;
      wire                      indexed;
      wire                      fdiv_is0;
      wire                      fsqrt_is0;
      wire                      update_form;
      wire                      forcealign;
      wire                      cr_writer;
      wire                      is0_instr_v;
      wire                      ucode_restart;
      wire                      mffgpr;
      wire                      mftgpr;
      wire                      record_form;
      wire                      fpscr_wr;
      wire                      fpscr_mv;
      wire [0:8]                ldst_tag;
      wire [0:4]                ldst_tag_addr;
      wire                      is0_to_ucode;
      wire                      cordered;
      wire                      ordered;
      wire                      is0_zero_r0;
      
      
      wire [0:7]                config_reg_scin;
      wire [0:7]                config_reg_scout;
      
      wire [0:5]                size;
      wire [3:7]                spare_unused;
      
      wire                      is0_is_ucode;
      wire                      in_ucode_mode;
      wire                      only_from_ucode;
      wire                      only_graphics_mode;
      wire                      graphics_mode;
      wire                      is0_invalid_kill;
      wire                      is0_invalid_kill_uc;
      
      wire                      ldst_extpid;
      wire                      single_precision_ldst;
      wire                      int_word_ldst;
      wire                      sign_ext_ldst;
      wire                      io_port;
      wire                      io_port_ext;
      
      wire                      ignore_flush_is0;
      
      wire                      is0_kill_or_divsqrt_b;
      wire                      au_iu_is0_i_dec;
      wire                      is0_i_dec_b;
      wire                      no_ram;
      
      wire                      ram_mode_v;
      
      wire [0:5]                au_iu_iu4_t1_a6;
      wire [0:5]                au_iu_iu4_t2_a6;
      wire [0:5]                au_iu_iu4_t3_a6;
      wire [0:5]                au_iu_iu4_s1_a6;
      wire [0:5]                au_iu_iu4_s2_a6;
      wire [0:5]                au_iu_iu4_s3_a6;
      
      wire                      pc_iu_func_sl_thold_1;
      wire                      pc_iu_func_sl_thold_0;
      wire                      pc_iu_func_sl_thold_0_b;
      wire                      pc_iu_sg_1;
      wire                      pc_iu_sg_0;
      wire                      force_t;
     

      
      
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
      
      assign tidn = 1'b0;
      assign tiup = 1'b1;
      
      
      assign is0_instr = iu_au_iu4_instr;
      assign is0_instr_v = iu_au_iu4_instr_v;
      assign ucode_restart = iu_au_ucode_restart;
      
      assign pri_is0[0:5] = is0_instr[0:5];
      assign sec_is0[20:31] = is0_instr[20:31];
      
      
      
      
      
      
      
      

assign isfu_dec_is0 =  ( pri_is0[0] &  pri_is0[1] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] & ~sec_is0[21] & ~sec_is0[22]
		 & ~sec_is0[23] & ~sec_is0[24] & ~sec_is0[25]
		 &  sec_is0[27] & ~sec_is0[29] & ~sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] & ~pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] & ~sec_is0[21] & ~sec_is0[22]
		 &  sec_is0[23] &  sec_is0[24] & ~sec_is0[27]
		 &  sec_is0[28] & ~sec_is0[29] &  sec_is0[30]
		 & ~sec_is0[31]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] & ~sec_is0[21] &  sec_is0[22]
		 &  sec_is0[23] &  sec_is0[27] & ~sec_is0[28]
		 & ~sec_is0[29] & ~sec_is0[30]) |
		( pri_is0[1] &  pri_is0[2] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] &  sec_is0[21] & ~sec_is0[23]
		 &  sec_is0[24] &  sec_is0[26] & ~sec_is0[27]
		 &  sec_is0[28] &  sec_is0[29] &  sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[4] &  pri_is0[5]
		 &  sec_is0[21] &  sec_is0[22] &  sec_is0[24]
		 & ~sec_is0[25] &  sec_is0[27] &  sec_is0[28]
		 &  sec_is0[29] & ~sec_is0[30]) |
		( pri_is0[1] &  pri_is0[2] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] &  sec_is0[21] &  sec_is0[24]
		 & ~sec_is0[25] &  sec_is0[26] & ~sec_is0[27]
		 &  sec_is0[28] &  sec_is0[29] &  sec_is0[30]) |
		( pri_is0[1] &  pri_is0[2] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] &  sec_is0[21] & ~sec_is0[22]
		 &  sec_is0[26] & ~sec_is0[27] &  sec_is0[28]
		 &  sec_is0[29] &  sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] & ~sec_is0[21] & ~sec_is0[24]
		 & ~sec_is0[25] &  sec_is0[27] & ~sec_is0[28]
		 & ~sec_is0[29] & ~sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] & ~sec_is0[21] & ~sec_is0[22]
		 & ~sec_is0[23] & ~sec_is0[24] & ~sec_is0[28]
		 & ~sec_is0[29] & ~sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] &  sec_is0[21] &  sec_is0[22]
		 & ~sec_is0[24] &  sec_is0[25] &  sec_is0[27]
		 &  sec_is0[28] &  sec_is0[29]) |
		( pri_is0[1] &  pri_is0[2] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] &  sec_is0[21] & ~sec_is0[22]
		 & ~sec_is0[23] &  sec_is0[24] &  sec_is0[25]
		 &  sec_is0[26] &  sec_is0[27] &  sec_is0[28]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] &  sec_is0[21] & ~sec_is0[22]
		 &  sec_is0[24] & ~sec_is0[25] & ~sec_is0[27]
		 &  sec_is0[28] &  sec_is0[29] &  sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] & ~sec_is0[21] & ~sec_is0[22]
		 & ~sec_is0[23] & ~sec_is0[25] & ~sec_is0[28]
		 & ~sec_is0[29] & ~sec_is0[30]) |
		( pri_is0[1] &  pri_is0[2] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] &  sec_is0[21] & ~sec_is0[22]
		 &  sec_is0[24] &  sec_is0[26] &  sec_is0[28]
		 &  sec_is0[29] &  sec_is0[30]) |
		( pri_is0[1] &  pri_is0[2] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] &  sec_is0[21] & ~sec_is0[22]
		 &  sec_is0[23] &  sec_is0[24] & ~sec_is0[25]
		 &  sec_is0[26] &  sec_is0[27] &  sec_is0[28]
		 &  sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] & ~sec_is0[21] & ~sec_is0[22]
		 & ~sec_is0[23] & ~sec_is0[24] &  sec_is0[25]
		 & ~sec_is0[27] &  sec_is0[28] &  sec_is0[29]
		 & ~sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] & ~sec_is0[21] & ~sec_is0[22]
		 & ~sec_is0[24] & ~sec_is0[27] & ~sec_is0[28]
		 & ~sec_is0[29] & ~sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] & ~sec_is0[21] & ~sec_is0[22]
		 &  sec_is0[23] & ~sec_is0[24] & ~sec_is0[25]
		 &  sec_is0[28] &  sec_is0[29] & ~sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] & ~sec_is0[21] & ~sec_is0[22]
		 & ~sec_is0[23] &  sec_is0[24] & ~sec_is0[25]
		 & ~sec_is0[27] &  sec_is0[28] &  sec_is0[29]
		 & ~sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] & ~sec_is0[21] & ~sec_is0[22]
		 & ~sec_is0[24] & ~sec_is0[25] &  sec_is0[27]
		 &  sec_is0[28] &  sec_is0[29]) |
		( pri_is0[1] &  pri_is0[2] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] &  sec_is0[21] & ~sec_is0[22]
		 &  sec_is0[24] &  sec_is0[25] &  sec_is0[26]
		 &  sec_is0[27] &  sec_is0[28] &  sec_is0[29]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[4] &  pri_is0[5]
		 &  sec_is0[26] &  sec_is0[27] & ~sec_is0[29]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[4] &  pri_is0[5]
		 &  sec_is0[26] &  sec_is0[29] & ~sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[4] &  pri_is0[5]
		 &  sec_is0[26] &  sec_is0[28] & ~sec_is0[29]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[4] &  pri_is0[5]
		 &  sec_is0[26] &  sec_is0[27] &  sec_is0[28]) |
		( pri_is0[0] &  pri_is0[1] & ~pri_is0[2]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] &  sec_is0[26] &  sec_is0[28]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[3] &  pri_is0[4]
		 &  pri_is0[5] &  sec_is0[26] & ~sec_is0[30]);

assign tv =  (~pri_is0[3] &  sec_is0[30] & ~sec_is0[31]) |
	( pri_is0[2] &  pri_is0[4] & ~sec_is0[21] &  sec_is0[22]) |
	( pri_is0[2] &  sec_is0[20] & ~sec_is0[23] & ~sec_is0[24]
	 & ~sec_is0[26] & ~sec_is0[27] & ~sec_is0[28] &  sec_is0[29]
	 &  sec_is0[30]) |
	( pri_is0[2] &  sec_is0[22] & ~sec_is0[23] &  sec_is0[24]
	 &  sec_is0[26] & ~sec_is0[27] &  sec_is0[28] &  sec_is0[29]
	 &  sec_is0[30]) |
	( pri_is0[2] &  pri_is0[4] &  sec_is0[22] & ~sec_is0[24]
	 &  sec_is0[27]) |
	( pri_is0[2] &  pri_is0[4] &  sec_is0[21] & ~sec_is0[22]
	 & ~sec_is0[23] &  sec_is0[28]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] & ~sec_is0[25]
	 &  sec_is0[27]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] & ~sec_is0[23]
	 &  sec_is0[27]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] &  sec_is0[26]) |
	(~pri_is0[2] & ~pri_is0[3]);

assign av =  ( pri_is0[3] &  sec_is0[20] & ~sec_is0[22] & ~sec_is0[23]
	 &  sec_is0[24] & ~sec_is0[26] & ~sec_is0[27] & ~sec_is0[28]
	 &  sec_is0[29] &  sec_is0[30]) |
	( pri_is0[0] &  pri_is0[3] &  pri_is0[4] & ~sec_is0[22]
	 & ~sec_is0[23] & ~sec_is0[24] & ~sec_is0[25] & ~sec_is0[26]
	 & ~sec_is0[28]) |
	( pri_is0[0] &  pri_is0[3] &  pri_is0[4] & ~sec_is0[23]
	 &  sec_is0[25] & ~sec_is0[26] & ~sec_is0[27] & ~sec_is0[29]) |
	(~pri_is0[0] &  sec_is0[21] &  sec_is0[23] &  sec_is0[24]
	 & ~sec_is0[25] &  sec_is0[29]) |
	( pri_is0[0] &  pri_is0[3] &  pri_is0[4] & ~sec_is0[24]
	 & ~sec_is0[25] & ~sec_is0[26] & ~sec_is0[27] & ~sec_is0[29]
	 & ~sec_is0[30]) |
	(~pri_is0[0] &  sec_is0[21] & ~sec_is0[22] &  sec_is0[23]
	 & ~sec_is0[27]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] &  sec_is0[26]
	 &  sec_is0[27] &  sec_is0[28]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] &  sec_is0[26]
	 & ~sec_is0[27] & ~sec_is0[28] &  sec_is0[29]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] &  sec_is0[26]
	 &  sec_is0[28] & ~sec_is0[29]) |
	( pri_is0[0] &  pri_is0[2] &  sec_is0[26] &  sec_is0[30]) |
	( pri_is0[1] & ~pri_is0[2] &  pri_is0[3]);

assign bv =  (~pri_is0[0] &  sec_is0[21] & ~sec_is0[25] & ~sec_is0[29]) |
	( pri_is0[2] & ~pri_is0[3] &  sec_is0[28] &  sec_is0[30]
	 & ~sec_is0[31]) |
	(~pri_is0[0] &  sec_is0[21] &  sec_is0[23] &  sec_is0[25]
	 &  sec_is0[27] &  sec_is0[28] &  sec_is0[29]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] & ~sec_is0[24]
	 & ~sec_is0[27] & ~sec_is0[28] & ~sec_is0[29] & ~sec_is0[30]) |
	( pri_is0[2] &  pri_is0[4] &  sec_is0[22] & ~sec_is0[24]
	 & ~sec_is0[26]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] &  sec_is0[23]
	 &  sec_is0[24] & ~sec_is0[25] &  sec_is0[29]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] & ~sec_is0[25]
	 & ~sec_is0[26] &  sec_is0[27]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] & ~sec_is0[21]
	 &  sec_is0[24] &  sec_is0[27] & ~sec_is0[30]) |
	( pri_is0[0] &  pri_is0[2] &  sec_is0[26] &  sec_is0[28]
	 &  sec_is0[30]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] & ~sec_is0[23]
	 & ~sec_is0[26] &  sec_is0[27]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] &  sec_is0[26]
	 & ~sec_is0[30]);

assign cv =  ( pri_is0[0] &  pri_is0[2] &  sec_is0[26] & ~sec_is0[28]
	 &  sec_is0[30]) |
	( pri_is0[0] &  pri_is0[2] &  sec_is0[26] &  sec_is0[29]
	 &  sec_is0[30]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] &  sec_is0[26]
	 &  sec_is0[27] &  sec_is0[28]);

assign record_form =  ( pri_is0[0] &  pri_is0[2] & ~sec_is0[21] &  sec_is0[24]
	 &  sec_is0[27] &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] & ~sec_is0[23] &  sec_is0[29]
		 &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] & ~sec_is0[25] &  sec_is0[28]
		 &  sec_is0[29] &  sec_is0[31]) |
		( pri_is0[2] &  sec_is0[22] & ~sec_is0[24]
		 &  sec_is0[27] &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] & ~sec_is0[23] &  sec_is0[27]
		 &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] & ~sec_is0[25] &  sec_is0[27]
		 &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] &  sec_is0[26] &  sec_is0[30]
		 &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] &  sec_is0[26] &  sec_is0[29]
		 &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] &  sec_is0[26] &  sec_is0[28]
		 &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] &  sec_is0[26] &  sec_is0[27]
		 &  sec_is0[31]);

assign fpscr_wr =  ( pri_is0[2] & ~pri_is0[3] & ~sec_is0[30] &  sec_is0[31]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] & ~sec_is0[23]
	 & ~sec_is0[24] & ~sec_is0[26] & ~sec_is0[27] & ~sec_is0[29]) |
	( pri_is0[2] &  pri_is0[4] &  sec_is0[22] & ~sec_is0[25]
	 &  sec_is0[27] &  sec_is0[29]) |
	( pri_is0[2] &  pri_is0[4] &  sec_is0[21] & ~sec_is0[24]
	 &  sec_is0[27]) |
	( pri_is0[2] &  pri_is0[4] & ~sec_is0[21] &  sec_is0[22]
	 &  sec_is0[23] &  sec_is0[27]) |
	( pri_is0[0] &  pri_is0[2] &  sec_is0[26] & ~sec_is0[29]
	 &  sec_is0[30]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] &  sec_is0[26]
	 &  sec_is0[28] & ~sec_is0[30]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[3] &  pri_is0[4]
	 & ~sec_is0[25] &  sec_is0[27] &  sec_is0[28]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] &  sec_is0[26]
	 &  sec_is0[29] & ~sec_is0[30]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] &  sec_is0[26]
	 &  sec_is0[27]);

assign cordered =  ( pri_is0[2] & ~sec_is0[21] &  sec_is0[22] &  sec_is0[27]
	 &  sec_is0[31]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] & ~sec_is0[23]
	 &  sec_is0[24] & ~sec_is0[26] & ~sec_is0[27]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] & ~sec_is0[23]
	 & ~sec_is0[26] & ~sec_is0[27] &  sec_is0[29]) |
	( pri_is0[2] &  sec_is0[22] & ~sec_is0[24] &  sec_is0[27]
	 &  sec_is0[31]) |
	( pri_is0[0] &  pri_is0[2] &  pri_is0[4] & ~sec_is0[25]
	 & ~sec_is0[26] & ~sec_is0[27] &  sec_is0[28] &  sec_is0[29]) |
	( pri_is0[0] &  pri_is0[2] & ~sec_is0[23] &  sec_is0[27]
	 &  sec_is0[31]) |
	( pri_is0[0] &  pri_is0[2] & ~sec_is0[25] &  sec_is0[27]
	 &  sec_is0[31]) |
	( pri_is0[0] &  pri_is0[2] &  sec_is0[26] & ~sec_is0[27]
	 & ~sec_is0[28] &  sec_is0[30]) |
	( pri_is0[0] &  pri_is0[2] &  sec_is0[26] &  sec_is0[29]
	 &  sec_is0[31]) |
	( pri_is0[0] &  pri_is0[2] &  sec_is0[26] &  sec_is0[27]
	 &  sec_is0[31]) |
	( pri_is0[0] &  pri_is0[2] &  sec_is0[26] &  sec_is0[28]
	 &  sec_is0[31]);

assign ordered =  ( pri_is0[0] &  pri_is0[2] &  pri_is0[4] &  sec_is0[26]
	 & ~sec_is0[27] &  sec_is0[29] & ~sec_is0[30]);

assign fpscr_mv =  ( pri_is0[0] &  pri_is0[4] & ~sec_is0[25] &  sec_is0[28]
	 &  sec_is0[29]) |
	( pri_is0[0] &  pri_is0[4] & ~sec_is0[23]);

assign ld_st_is0 =  (~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
	 &  pri_is0[4] &  pri_is0[5] &  sec_is0[20] & ~sec_is0[21]
	 & ~sec_is0[22] & ~sec_is0[23] & ~sec_is0[26] & ~sec_is0[27]
	 & ~sec_is0[28] &  sec_is0[29] &  sec_is0[30]) |
		(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21]
		 & ~sec_is0[22] & ~sec_is0[23] &  sec_is0[24]
		 &  sec_is0[25] &  sec_is0[26] &  sec_is0[27]
		 &  sec_is0[28]) |
		(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21]
		 & ~sec_is0[22] &  sec_is0[23] &  sec_is0[24]
		 & ~sec_is0[25] &  sec_is0[26] &  sec_is0[27]
		 &  sec_is0[28] &  sec_is0[30]) |
		(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21]
		 & ~sec_is0[22] &  sec_is0[24] &  sec_is0[25]
		 &  sec_is0[26] &  sec_is0[27] &  sec_is0[28]
		 &  sec_is0[29]) |
		(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21]
		 &  sec_is0[24] & ~sec_is0[25] &  sec_is0[26]
		 & ~sec_is0[27] &  sec_is0[28] &  sec_is0[29]
		 &  sec_is0[30]) |
		(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21]
		 & ~sec_is0[22] &  sec_is0[26] & ~sec_is0[27]
		 &  sec_is0[28] &  sec_is0[29] &  sec_is0[30]) |
		(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21]
		 & ~sec_is0[23] &  sec_is0[24] &  sec_is0[26]
		 & ~sec_is0[27] &  sec_is0[28] &  sec_is0[29]
		 &  sec_is0[30]) |
		(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21]
		 & ~sec_is0[22] &  sec_is0[24] &  sec_is0[26]
		 &  sec_is0[28] &  sec_is0[29] &  sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] & ~pri_is0[2]);

assign st_is0 =  (~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[20]
		 & ~sec_is0[21] & ~sec_is0[22] & ~sec_is0[23]
		 &  sec_is0[24] & ~sec_is0[26] & ~sec_is0[27]
		 & ~sec_is0[28] &  sec_is0[29] &  sec_is0[30]) |
	(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
	 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21] & ~sec_is0[22]
	 &  sec_is0[23] &  sec_is0[24] &  sec_is0[25] &  sec_is0[26]
	 &  sec_is0[27] &  sec_is0[28] &  sec_is0[29]) |
	(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
	 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21] & ~sec_is0[22]
	 &  sec_is0[23] &  sec_is0[24] & ~sec_is0[25] &  sec_is0[26]
	 &  sec_is0[27] &  sec_is0[28] &  sec_is0[30]) |
	(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
	 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21] &  sec_is0[23]
	 &  sec_is0[24] & ~sec_is0[25] &  sec_is0[26] & ~sec_is0[27]
	 &  sec_is0[28] &  sec_is0[29] &  sec_is0[30]) |
	(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
	 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21] & ~sec_is0[22]
	 &  sec_is0[23] &  sec_is0[26] & ~sec_is0[27] &  sec_is0[28]
	 &  sec_is0[29] &  sec_is0[30]) |
	( pri_is0[0] &  pri_is0[1] & ~pri_is0[2] &  pri_is0[3]);

assign indexed =  ( pri_is0[2] &  sec_is0[20] & ~sec_is0[23] & ~sec_is0[25]
	 & ~sec_is0[26] & ~sec_is0[27] & ~sec_is0[28] &  sec_is0[29]
	 &  sec_is0[30]) |
	(~pri_is0[0] &  sec_is0[21] &  sec_is0[25] &  sec_is0[26]
	 & ~sec_is0[27] &  sec_is0[28] &  sec_is0[29] &  sec_is0[30]) |
	(~pri_is0[0] &  sec_is0[21] &  sec_is0[24] &  sec_is0[26]
	 & ~sec_is0[27] &  sec_is0[28] &  sec_is0[29] &  sec_is0[30]) |
	(~pri_is0[0] &  sec_is0[21] & ~sec_is0[22] & ~sec_is0[25]
	 &  sec_is0[29]);

assign update_form =  (~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
	 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21] & ~sec_is0[22]
	 &  sec_is0[25] &  sec_is0[26] & ~sec_is0[27] &  sec_is0[28]
	 &  sec_is0[29] &  sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] & ~pri_is0[2] &  pri_is0[5]);

assign forcealign =  ( pri_is0[2] &  pri_is0[3] &  pri_is0[4] &  sec_is0[21]
		 &  sec_is0[22] &  sec_is0[23] &  sec_is0[24]
		 &  sec_is0[25] &  sec_is0[26]);

assign single_precision_ldst =  ( pri_is0[1] & ~pri_is0[2] & ~pri_is0[4]) |
		(~pri_is0[0] &  sec_is0[21] & ~sec_is0[22]
		 &  sec_is0[28] &  sec_is0[29] & ~sec_is0[30]) |
		(~pri_is0[0] &  sec_is0[21] & ~sec_is0[22]
		 & ~sec_is0[24]);

assign int_word_ldst =  ( pri_is0[2] &  sec_is0[20] & ~sec_is0[22]
		 & ~sec_is0[23] & ~sec_is0[26] & ~sec_is0[27]
		 & ~sec_is0[28] &  sec_is0[29] &  sec_is0[30]) |
		(~pri_is0[0] &  sec_is0[22] &  sec_is0[24]
		 &  sec_is0[26] & ~sec_is0[27] &  sec_is0[28]
		 &  sec_is0[29] &  sec_is0[30]) |
		(~pri_is0[0] &  sec_is0[21] & ~sec_is0[22]
		 & ~sec_is0[23] &  sec_is0[28] & ~sec_is0[29]) |
		(~pri_is0[0] &  sec_is0[21] & ~sec_is0[25]
		 & ~sec_is0[29]);

assign sign_ext_ldst =  (~pri_is0[0] &  sec_is0[21] & ~sec_is0[22]
		 & ~sec_is0[23] &  sec_is0[28] & ~sec_is0[29]
		 & ~sec_is0[30]) |
		(~pri_is0[0] &  sec_is0[22] & ~sec_is0[23]
		 &  sec_is0[24] & ~sec_is0[25]);

assign ldst_extpid =  (~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21]
		 & ~sec_is0[22] &  sec_is0[24] & ~sec_is0[25]
		 &  sec_is0[26] &  sec_is0[27] &  sec_is0[28]
		 &  sec_is0[29] &  sec_is0[30]);

assign io_port =  (~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[20]
		 & ~sec_is0[21] & ~sec_is0[22] & ~sec_is0[23]
		 & ~sec_is0[26] & ~sec_is0[27] & ~sec_is0[28]
		 &  sec_is0[29] &  sec_is0[30]);

assign io_port_ext =  (~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[20]
		 & ~sec_is0[21] & ~sec_is0[22] & ~sec_is0[23]
		 & ~sec_is0[25] & ~sec_is0[26] & ~sec_is0[27]
		 & ~sec_is0[28] &  sec_is0[29] &  sec_is0[30]);

assign size[0] =  (~pri_is0[1] & ~pri_is0[3]);

assign size[1] =  (~pri_is0[1] & ~pri_is0[3]);

assign size[2] =  ( pri_is0[4] &  sec_is0[21] & ~sec_is0[22] & ~sec_is0[25]
		 &  sec_is0[27] &  sec_is0[29]) |
	( pri_is0[4] &  sec_is0[21] & ~sec_is0[22] &  sec_is0[24]
	 & ~sec_is0[27]) |
	(~pri_is0[2] &  pri_is0[4]);

assign size[3] =  ( pri_is0[2] &  pri_is0[4] &  sec_is0[21] & ~sec_is0[22]
	 & ~sec_is0[24]) |
	( pri_is0[2] &  sec_is0[22] &  sec_is0[24] &  sec_is0[26]
	 & ~sec_is0[27] &  sec_is0[28] &  sec_is0[29] &  sec_is0[30]) |
	( pri_is0[1] & ~pri_is0[2] & ~pri_is0[4]);

assign size[4] =  (~pri_is0[1] & ~pri_is0[3]);

assign size[5] =  (~pri_is0[1] & ~pri_is0[3]);

assign cr_writer =  ( pri_is0[2] &  sec_is0[20] & ~sec_is0[22] & ~sec_is0[23]
	 & ~sec_is0[26] & ~sec_is0[27] & ~sec_is0[28] &  sec_is0[29]
	 &  sec_is0[30] &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] & ~sec_is0[25] & ~sec_is0[26]
		 & ~sec_is0[29] & ~sec_is0[30] &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] & ~sec_is0[21] &  sec_is0[24]
		 &  sec_is0[27] &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] & ~sec_is0[23] & ~sec_is0[26]
		 &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] &  pri_is0[4] & ~sec_is0[22]
		 & ~sec_is0[26] & ~sec_is0[27] & ~sec_is0[28]
		 & ~sec_is0[29] & ~sec_is0[30]) |
		( pri_is0[0] &  pri_is0[2] & ~sec_is0[25] &  sec_is0[28]
		 &  sec_is0[29] &  sec_is0[31]) |
		( pri_is0[2] &  sec_is0[22] & ~sec_is0[24]
		 &  sec_is0[27] &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] &  sec_is0[26] &  sec_is0[30]
		 &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] &  sec_is0[26] &  sec_is0[29]
		 &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] &  sec_is0[26] &  sec_is0[28]
		 &  sec_is0[31]) |
		( pri_is0[0] &  pri_is0[2] &  sec_is0[26] &  sec_is0[27]
		 &  sec_is0[31]);

assign mffgpr =  (~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[20]
		 & ~sec_is0[21] & ~sec_is0[22] & ~sec_is0[23]
		 & ~sec_is0[24] & ~sec_is0[26] & ~sec_is0[27]
		 & ~sec_is0[28] &  sec_is0[29] &  sec_is0[30]) |
	(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
	 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21] & ~sec_is0[22]
	 & ~sec_is0[23] &  sec_is0[24] &  sec_is0[25] &  sec_is0[26]
	 &  sec_is0[27] &  sec_is0[28]);

assign mftgpr =  (~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
	 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21] & ~sec_is0[22]
	 &  sec_is0[23] &  sec_is0[24] & ~sec_is0[25] &  sec_is0[26]
	 &  sec_is0[27] &  sec_is0[28] & ~sec_is0[29] &  sec_is0[30]) |
	(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
	 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21] & ~sec_is0[22]
	 &  sec_is0[23] &  sec_is0[24] &  sec_is0[25] &  sec_is0[26]
	 &  sec_is0[27] &  sec_is0[28] &  sec_is0[29]) |
	(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
	 &  pri_is0[4] &  pri_is0[5] &  sec_is0[20] & ~sec_is0[21]
	 & ~sec_is0[22] & ~sec_is0[23] &  sec_is0[24] & ~sec_is0[26]
	 & ~sec_is0[27] & ~sec_is0[28] &  sec_is0[29] &  sec_is0[30]);

assign fdiv_is0 =  ( pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[4]
	 &  pri_is0[5] &  sec_is0[26] & ~sec_is0[27] & ~sec_is0[28]
	 &  sec_is0[29] & ~sec_is0[30]);

assign fsqrt_is0 =  ( pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[4]
	 &  pri_is0[5] &  sec_is0[26] & ~sec_is0[27] &  sec_is0[28]
	 &  sec_is0[29] & ~sec_is0[30]);

assign only_from_ucode =  (~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
	 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21] & ~sec_is0[22]
	 &  sec_is0[24] &  sec_is0[25] &  sec_is0[26] &  sec_is0[27]
	 &  sec_is0[28] &  sec_is0[29]) |
		(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21]
		 & ~sec_is0[22] &  sec_is0[23] &  sec_is0[24]
		 & ~sec_is0[25] &  sec_is0[26] &  sec_is0[27]
		 &  sec_is0[28] & ~sec_is0[29] &  sec_is0[30]) |
		(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21]
		 & ~sec_is0[22] & ~sec_is0[23] &  sec_is0[24]
		 &  sec_is0[25] &  sec_is0[26] &  sec_is0[27]
		 &  sec_is0[28]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[4]
		 &  pri_is0[5] &  sec_is0[26] & ~sec_is0[27]
		 & ~sec_is0[28] & ~sec_is0[29] &  sec_is0[30]) |
		( pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[26]
		 & ~sec_is0[27] & ~sec_is0[28] & ~sec_is0[29]);

assign no_ram =  (~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21]
		 & ~sec_is0[22] & ~sec_is0[23] &  sec_is0[25]
		 &  sec_is0[26] & ~sec_is0[27] &  sec_is0[28]
		 &  sec_is0[29] &  sec_is0[30]) |
	( pri_is0[0] &  pri_is0[1] & ~pri_is0[2] & ~pri_is0[3]
	 &  pri_is0[5]);

assign only_graphics_mode =  ( pri_is0[0] &  pri_is0[1] &  pri_is0[2]
	 & ~pri_is0[3] &  pri_is0[4] &  pri_is0[5] & ~sec_is0[21]
	 & ~sec_is0[22] &  sec_is0[23] &  sec_is0[24] & ~sec_is0[26]
	 & ~sec_is0[27] &  sec_is0[28] & ~sec_is0[29] &  sec_is0[30]
	 & ~sec_is0[31]) |
		(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21]
		 & ~sec_is0[22] & ~sec_is0[23] &  sec_is0[24]
		 &  sec_is0[25] &  sec_is0[26] &  sec_is0[27]
		 &  sec_is0[28]) |
		(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21]
		 & ~sec_is0[22] &  sec_is0[23] &  sec_is0[24]
		 & ~sec_is0[25] &  sec_is0[26] &  sec_is0[27]
		 &  sec_is0[28] & ~sec_is0[29] &  sec_is0[30]) |
		(~pri_is0[0] &  pri_is0[1] &  pri_is0[2] &  pri_is0[3]
		 &  pri_is0[4] &  pri_is0[5] &  sec_is0[21]
		 & ~sec_is0[22] &  sec_is0[24] &  sec_is0[25]
		 &  sec_is0[26] &  sec_is0[27] &  sec_is0[28]
		 &  sec_is0[29]);


      
      
      assign ldst_tag = {single_precision_ldst, int_word_ldst, sign_ext_ldst, iu_au_iu4_ucode_ext[0], ldst_tag_addr[0:4]};		
      
      assign ldst_tag_addr = (mftgpr == 1'b0) ? is0_instr[06:10] : 
                             is0_instr[16:20];
      
      assign ram_mode_v = iu_au_iu4_isram;
      
      assign iu_au_config_iucr_din = iu_au_config_iucr;
      
      assign config_reg_scin = 0;
      
      
      tri_rlmreg_p #(.INIT(0), .WIDTH(8)) config_reg(
         .vd(vdd),
         .gd(gnd),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .nclk(nclk),
         .mpw1_b(mpw1_b),
         .act(tiup),
         .mpw2_b(mpw2_b),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
	 .d_mode(tiup),					     
         .scin(config_reg_scin[0:7]),
         .scout(config_reg_scout[0:7]),
         .din(iu_au_config_iucr_din),
         .dout(iu_au_config_iucr_l2)
      );
      
      assign iu_au_config_iucr_int[0:7] = iu_au_config_iucr_l2[0:7];
      
      assign graphics_mode = iu_au_config_iucr_int[0];
      
      assign spare_unused[4:7] = iu_au_config_iucr_int[4:7];
      
      
      assign is0_is_ucode = iu_au_iu4_ucode[0];
      
      assign in_ucode_mode = iu_au_iu4_ucode[0] & is0_instr_v;
      
      
      
      
      assign is0_invalid_kill_uc = ((~(in_ucode_mode | ram_mode_v)) & only_from_ucode) | ((~(graphics_mode | in_ucode_mode | ram_mode_v)) & only_graphics_mode);		
      
      
      
      assign is0_invalid_kill = ((~(graphics_mode | in_ucode_mode)) & only_graphics_mode) | is0_invalid_kill_uc;		
      
      assign au_iu_iu4_no_ram = no_ram;
      
      assign is0_kill_or_divsqrt_b = (~(is0_invalid_kill));
      
      assign is0_i_dec_b = (~(isfu_dec_is0 & is0_kill_or_divsqrt_b));		
      assign au_iu_iu4_i_dec_b = is0_i_dec_b;
      
      assign au_iu_is0_i_dec = (~is0_i_dec_b);
      assign spare_unused[3] = au_iu_is0_i_dec;
      
      
      assign ignore_flush_is0 = 1'b0;		
      
      
      assign is0_to_ucode = (iu_au_iu4_2ucode) & isfu_dec_is0;		
      assign au_iu_iu4_ucode[0:2] = iu_au_iu4_ucode[0:2];
      
      assign is0_ldst_ra = (mftgpr == 1'b0) ? {iu_au_iu4_ucode_ext[1], is0_instr[11:15]} : 
                           {iu_au_iu4_ucode_ext[0], is0_instr[6:10]};		
      
      
      
      
      
      assign is0_zero_r0 = ld_st_is0 & (is0_ldst_ra == 6'b000000);
      
      
      
      assign au_iu_iu4_t1_v = (update_form | mftgpr | fpscr_wr) & (~iu_au_iu4_ucode[1]);
      assign au_iu_iu4_t1_t[0:2] = (fpscr_wr == 1'b1) ? 3'b111 : 		
                                   3'b000;
      assign au_iu_iu4_t1_a6[0:5] = (({iu_au_iu4_ucode_ext[1], is0_instr[11:15]}) & ({6{(~mftgpr) & (~fpscr_wr)}})) |
                                    (({iu_au_iu4_ucode_ext[0], is0_instr[6:10]})  & ({6{  mftgpr  & (~fpscr_wr)}})) |
	                            ((6'b000000) & ({6{fpscr_wr}}));
      
      assign au_iu_iu4_t2_v = tv & (~iu_au_iu4_ucode[1]);
      assign au_iu_iu4_t2_a6[0:5] = (tv == 1'b0 & fpscr_wr == 1'b1) ? 6'b110000 : 		
                                    {iu_au_iu4_ucode_ext[0], is0_instr[06:10]};
      assign au_iu_iu4_t2_t[0:2] = 3'b110;		
      
      assign au_iu_iu4_t3_v = cr_writer & (~iu_au_iu4_ucode[1]);
      assign au_iu_iu4_t3_a6[0:5] = ({3'b000, is0_instr[06:08]} & {6{(~record_form)}}) | ((6'b000001) & {6{record_form}});
      assign au_iu_iu4_t3_t[0:2] = 3'b001;		
      
      assign au_iu_iu4_s1_v = ((ld_st_is0 & (~is0_zero_r0) & (~mftgpr) & (~mffgpr)) & ld_st_is0) | (av & (~ld_st_is0));
      assign au_iu_iu4_s1_a6[0:5] = ((is0_ldst_ra[0:5]) & {6{ld_st_is0}}) | (({iu_au_iu4_ucode_ext[1], is0_instr[11:15]}) & {6{(~ld_st_is0)}});
      
	assign au_iu_iu4_s1_t[0:2] = (3'b000 & {3{ld_st_is0}}) | (3'b110 & {3{(~ld_st_is0)}});		
      
      assign au_iu_iu4_s2_v = ((indexed | mffgpr) & ld_st_is0) | (bv & (~ld_st_is0));
      assign au_iu_iu4_s2_a6[0:5] = {iu_au_iu4_ucode_ext[2], is0_instr[16:20]};
	assign au_iu_iu4_s2_t[0:2] = (3'b000 & {3{ld_st_is0}}) | (3'b110 & {3{(~ld_st_is0)}});		
      
      assign au_iu_iu4_s3_v = (st_is0 & (~mftgpr) & ld_st_is0) | (cv & (~ld_st_is0));
	assign au_iu_iu4_s3_a6[0:5] = (({iu_au_iu4_ucode_ext[0], is0_instr[06:10]}) & {6{ld_st_is0 & (~(mffgpr | mftgpr))}}) |
	                              (({iu_au_iu4_ucode_ext[2], is0_instr[16:20]}) & {6{ld_st_is0 & (  mffgpr | mftgpr) }}) |
	                              (({iu_au_iu4_ucode_ext[3], is0_instr[21:25]}) & {6{(~ld_st_is0)}});
	assign au_iu_iu4_s3_t[0:2] = (3'b000 & {3{mffgpr}}) | (3'b110 & {3{(~mffgpr)}});		
      
      generate
         if (`GPR_POOL_ENC > 6)
         begin : gpr_pool
            assign au_iu_iu4_t1_a[0:`GPR_POOL_ENC - 7] = 0;
            assign au_iu_iu4_t2_a[0:`GPR_POOL_ENC - 7] = 0;
            assign au_iu_iu4_t3_a[0:`GPR_POOL_ENC - 7] = 0;
            assign au_iu_iu4_s1_a[0:`GPR_POOL_ENC - 7] = 0;
            assign au_iu_iu4_s2_a[0:`GPR_POOL_ENC - 7] = 0;
            assign au_iu_iu4_s3_a[0:`GPR_POOL_ENC - 7] = 0;
         end
      endgenerate
      assign au_iu_iu4_t1_a[`GPR_POOL_ENC - 6:`GPR_POOL_ENC - 1] = au_iu_iu4_t1_a6[0:5];
      assign au_iu_iu4_t2_a[`GPR_POOL_ENC - 6:`GPR_POOL_ENC - 1] = au_iu_iu4_t2_a6[0:5];
      assign au_iu_iu4_t3_a[`GPR_POOL_ENC - 6:`GPR_POOL_ENC - 1] = au_iu_iu4_t3_a6[0:5];
      assign au_iu_iu4_s1_a[`GPR_POOL_ENC - 6:`GPR_POOL_ENC - 1] = au_iu_iu4_s1_a6[0:5];
      assign au_iu_iu4_s2_a[`GPR_POOL_ENC - 6:`GPR_POOL_ENC - 1] = au_iu_iu4_s2_a6[0:5];
      assign au_iu_iu4_s3_a[`GPR_POOL_ENC - 6:`GPR_POOL_ENC - 1] = au_iu_iu4_s3_a6[0:5];
      
      assign isLoad = ld_st_is0 & (~st_is0) & (~(mffgpr | mftgpr));
      assign isStore = ld_st_is0 & (st_is0 | mftgpr) & (~mffgpr);

      assign au_iu_iu4_isload = isLoad;
      assign au_iu_iu4_isstore = isStore;
      
      assign au_iu_iu4_ilat[0:2] = (3'b100 & {3{ld_st_is0 & (~st_is0)}}) | (3'b011 & {3{ld_st_is0 & st_is0 & (~mftgpr)}}) | (3'b110 & {3{ld_st_is0 & st_is0 & mftgpr}}) | (3'b110 & {3{(~ld_st_is0)}});
      assign au_iu_iu4_ord = ordered & (~iu_au_iu4_ucode[1]);
      assign au_iu_iu4_cord = cordered & (~iu_au_iu4_ucode[1]);
      
      assign au_iu_iu4_spec = ld_st_is0;		
      
      assign au_iu_iu4_type_fp = isfu_dec_is0;
      assign au_iu_iu4_type_ap = 1'b0;
      assign au_iu_iu4_type_spv = 1'b0;
      assign au_iu_iu4_type_st = st_is0;
      
      assign au_iu_iu4_rte_lq = ld_st_is0;
      assign au_iu_iu4_rte_sq = isStore;
      assign au_iu_iu4_rte_axu0 = isfu_dec_is0 & (~(ld_st_is0 & (~st_is0))) & ~(isStore & iu_au_iu4_ucode[1]); 
      assign au_iu_iu4_rte_axu1 = 1'b0;
      
      assign au_iu_iu4_async_block = fpscr_mv;
      
      
      assign i_dec_so = 1'b0;
      assign fu_dec_debug = 0;
      

endmodule
