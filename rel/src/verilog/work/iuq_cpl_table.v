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

// VHDL 1076 Macro Expander C version 07/11/00
// job was run on Fri Apr 15 16:09:08 2011

//********************************************************************
//*
//* TITLE:
//*
//* NAME: iuq_cpl_table.v
//*
//*********************************************************************

`include "tri_a2o.vh"

module iuq_cpl_table(
   input                        i0_complete,
   input                        i0_bp_pred,
   input                        i0_br_miss,
   input [0:2]                  i0_ucode,
   input                        i0_isram,
   input                        i0_mtiar,
   input                        i0_rollover,
   input                        i0_rfi,
   input                        i0_n_np1_flush,
   input                        i1_complete,
   input                        i1_bp_pred,
   input                        i1_br_miss,
   input [0:2]                  i1_ucode,
   input                        i1_isram,
   input                        i1_mtiar,
   input                        i1_rollover,
   input                        i1_rfi,
   input                        i1_n_np1_flush,

   output                       iu_pc_i0_comp,
   output                       iu_pc_i1_comp,

   input                        icmp_enable,
   input                        irpt_enable,

   output                       select_i0_p1,
   output                       select_i1_p1,
   output                       select_i0_bta,
   output                       select_i1_bta,
   output                       select_i0_bp_bta,
   output                       select_i1_bp_bta,
   output                       select_ucode_p1,
   output                       select_reset,
   output                       select_mtiar,

   input                        cp3_async_int_val,
   input [0:31]                 cp3_async_int,
   input                        cp3_iu_excvec_val,
   input [0:3]                  cp3_iu_excvec,
   input                        cp3_lq_excvec_val,
   input [0:5]                  cp3_lq_excvec,
   input                        cp3_xu_excvec_val,
   input [0:4]                  cp3_xu_excvec,
   input                        cp3_axu_excvec_val,
   input [0:3]                  cp3_axu_excvec,
   input                        cp3_db_val,
   input [0:18]                 cp3_db_events,
   input                        cp3_ld,
   input                        cp3_st,
   input                        cp3_fp,
   input                        cp3_ap,
   input                        cp3_spv,
   input                        cp3_epid,
   input                        cp3_rfi,
   input                        cp3_attn,
   input                        cp3_sc,
   input                        cp3_icmp_block,
   output                       cp3_asyn_irpt_taken,
   output                       cp3_asyn_irpt_needed,
   output                       cp3_asyn_icmp_taken,
   output                       cp3_asyn_icmp_needed,
   output                       cp3_db_events_masked_reduced,
   output [62-`EFF_IFAR_ARCH:61] cp3_exc_nia,
   output                       cp3_mchk_disabled,
   input [64-`GPR_WIDTH:51]     spr_ivpr,
   input [64-`GPR_WIDTH:51]     spr_givpr,
   input                        msr_gs,
   input                        msr_me,
   input                        dbg_int_en,
   input                        dbcr0_irpt,
   input                        epcr_duvd,
   input                        epcr_extgs,
   input                        epcr_dtlbgs,
   input                        epcr_itlbgs,
   input                        epcr_dsigs,
   input                        epcr_isigs,
   input                        epcr_icm,
   input                        epcr_gicm,
   output                       dp_cp_async_flush,
   output                       dp_cp_async_bus_snoop_flush,
   output                       async_np1_flush,
   output                       async_n_flush,
   output                       mm_iu_exception,
   output                       pc_iu_stop,
   output                       mc_int,
   output                       g_int,
   output                       c_int,
   output                       dear_update,
   output                       dbsr_update,
   output                       eheir_update,
   output [0:18]                cp3_dbsr,
   output                       dbell_taken,
   output                       cdbell_taken,
   output                       gdbell_taken,
   output                       gcdbell_taken,
   output                       gmcdbell_taken,

   output                       esr_update,
   output [0:16]                cp3_exc_esr,
   output [0:14]                cp3_exc_mcsr,

   output                       cp_mm_itlb_miss,
   output                       cp_mm_dtlb_miss,
   output                       cp_mm_isi,
   output                       cp_mm_dsi,
   output                       cp_mm_ilrat_miss,
   output                       cp_mm_dlrat_miss,
   output                       cp_mm_imchk,
   output                       cp_mm_dmchk,

   input                        dis_mm_mchk

);

   wire                         ap_async;
   wire                         ap_axu;
   wire                         ap_iu;
   wire                         ap_lq;
   wire                         ap_xu;
   wire                         bo_async;
   wire                         bo_axu;
   wire                         bo_iu;
   wire                         bo_lq;
   wire                         bo_xu;
   wire                         data_async;
   wire                         data_axu;
   wire                         data_iu;
   wire                         data_lq;
   wire                         data_xu;
   wire                         dcache_dir_multi_lq;
   wire                         dcache_dir_par_lq;
   wire                         dcache_l2_ecc_lq;
   wire                         dcache_par_lq;
   wire                         derat_multi_lq;
   wire                         derat_par_lq;
   wire                         derat_par_xu;
   wire [0:1]                   dlk_async;
   wire [0:1]                   dlk_axu;
   wire [0:1]                   dlk_iu;
   wire [0:1]                   dlk_lq;
   wire [0:1]                   dlk_xu;
   wire                         epid_async;
   wire                         epid_axu;
   wire                         epid_iu;
   wire                         epid_lq;
   wire                         epid_xu;
   wire                         esr_async;
   wire                         esr_axu;
   wire                         esr_iu;
   wire                         esr_lq;
   wire                         esr_xu;
   wire                         fp_async;
   wire                         fp_axu;
   wire                         fp_iu;
   wire                         fp_lq;
   wire                         fp_xu;
   wire                         icache_l2_ecc_iu;
   wire                         ierat_multi_iu;
   wire                         ierat_par_iu;
   wire                         ierat_par_xu;
   wire [1:10]                  nia0_pt;
   wire [1:10]                  nia1_pt;
   wire                         pie_async;
   wire                         pie_axu;
   wire                         pie_iu;
   wire                         pie_lq;
   wire                         pie_xu;
   wire                         pil_async;
   wire                         pil_axu;
   wire                         pil_iu;
   wire                         pil_lq;
   wire                         pil_xu;
   wire                         ppr_async;
   wire                         ppr_axu;
   wire                         ppr_iu;
   wire                         ppr_lq;
   wire                         ppr_xu;
   wire                         ptr_async;
   wire                         ptr_axu;
   wire                         ptr_iu;
   wire                         ptr_lq;
   wire                         ptr_xu;
   wire                         pt_async;
   wire                         pt_axu;
   wire                         pt_iu;
   wire                         pt_lq;
   wire                         pt_xu;
   wire                         puo_async;
   wire                         puo_axu;
   wire                         puo_iu;
   wire                         puo_lq;
   wire                         puo_xu;
   wire                         spv_async;
   wire                         spv_axu;
   wire                         spv_iu;
   wire                         spv_lq;
   wire                         spv_xu;
   wire                         st_async;
   wire                         st_axu;
   wire                         st_iu;
   wire                         st_lq;
   wire                         st_xu;
   wire [1:35]                  tbl_async_exection_list_pt;
   wire [1:6]                   tbl_axu_exection_list_pt;
   wire [1:14]                  tbl_iu_exection_list_pt;
   wire [1:28]                  tbl_lq_exection_list_pt;
   wire [1:18]                  tbl_xu_exection_list_pt;
   wire                         tlbi_async;
   wire                         tlbi_axu;
   wire                         tlbi_iu;
   wire                         tlbi_lq;
   wire                         tlbi_xu;
   wire                         tlb_lru_par_async;
   wire                         tlb_lru_par_lq;
   wire                         tlb_lru_par_xu;
   wire                         tlb_multi_async;
   wire                         tlb_multi_lq;
   wire                         tlb_multi_xu;
   wire                         tlb_par_async;
   wire                         tlb_par_lq;
   wire                         tlb_par_xu;
   wire                         tlb_snoop_rej_async;
   wire                         uct_async;
   wire                         uct_axu;
   wire                         uct_iu;
   wire                         uct_lq;
   wire                         uct_xu;
   wire                         ude_input_async;
   wire                         alignment_lq;
   wire                         ap_unavailable_axu;
   wire                         ap_unavailable_lq;
   wire                         async_np1;
   wire                         async_n;
   wire [0:18]                  axu_db_mask;
   wire                         cp3_icmp_excep;
   wire                         crit_async;
   wire                         crit_input_async;
   wire                         data_storage_hv_lq;
   wire                         data_storage_lq;
   wire                         data_storage_xu;
   wire                         data_tlb_lq;
   wire                         dbell_async;
   wire                         dbell_crit_async;
   wire                         debug_async;
   wire                         debug_icmp;
   wire                         debug_irpt;
   wire                         dec_async;
   wire                         dp_cp_async;
   wire                         dp_cp_async_bus_snoop;
   wire                         external_async;
   wire                         fit_async;
   wire                         fp_unavailable_axu;
   wire                         fp_unavailable_lq;
   wire                         guest_async;
   wire                         guest_dbell_async;
   wire                         guest_dbell_crit_async;
   wire                         guest_dbell_mchk_async;
   wire                         guest_dec_async;
   wire                         guest_fit_async;
   wire                         guest_wdog_async;
   wire                         hyp_priv_iu;
   wire                         n_flush_iu;
   wire                         hyp_priv_lq;
   wire                         hyp_priv_xu;
   wire                         i0_bp_bta;
   wire                         i0_bta;
   wire                         i0_check_next;
   wire                         i0_comp;
   wire                         i0_p1;
   wire                         i0_reset;
   wire                         i0_ucode_p1;
   wire                         i1_bp_bta;
   wire                         i1_bta;
   wire                         i1_check_next;
   wire                         i1_comp;
   wire                         i1_p1;
   wire                         i1_reset;
   wire                         i1_ucode_p1;
   wire                         instruction_storage_hv_iu;
   wire                         instruction_storage_iu;
   wire                         instruction_tlb_iu;
   wire                         instr_tlb_async;
   wire                         irpt_taken_async;
   wire [0:18]                  iu_db_mask;
   wire [0:18]                  lq_db_mask;
   wire                         lrat_lq;
   wire                         lrat_miss_async;
   wire                         lrat_xu;
   wire                         mcheck_async;
   wire                         mcheck_iu;
   wire                         mcheck_lq;
   wire                         mcheck_xu;
   wire                         mchk_ext_async;
   wire                         perf_async;
   wire                         program_ap_axu;
   wire                         program_fp_axu;
   wire                         program_fp_en_async;
   wire                         program_iu;
   wire                         program_lq;
   wire                         program_xu;
   wire                         pt_fault_async;
   wire                         system_call_hyp_iu;
   wire                         system_call_iu;
   wire                         tlb_inelig_async;
   wire                         tlb_xu;
   wire                         user_dec_async;
   wire                         vec_unavailable_axu;
   wire                         vec_unavailable_lq;
   wire                         wdog_async;
   wire [0:18]                  xu_db_mask;
   wire                         guest_int;
   wire [0:18]                  cp3_db_events_masked;
   wire                         cp3_db_int_events_val;
   wire [0:18]                  db_mask;
   wire                         debug_irpt_int_dis;
   wire                         debug_icmp_excep;

//table_start
//
//?generate begin a(0 to 1);
//?TABLE NIA<a> LISTING(final) OPTIMIZE PARMS(ON-SET,DC-SET);
//*INPUTS*============================*OUTPUTS*=======================*
//|                                   |                               |
//| i<a>_complete                     |                               |
//| | i<a>_bp_pred                    |                               |
//| | | i<a>_br_miss                  |                               |
//| | | | i<a>_ucode                  |                               |
//| | | | |   i<a>_isram              |                               |
//| | | | |   | i<a>_mtiar            |                               |
//| | | | |   | | i<a>_rfi            |                               |
//| | | | |   | | | i<a>_n_np1_flush  | i<a>_p1                       |
//| | | | |   | | | |                 | | i<a>_bta                    |
//| | | | |   | | | |                 | | | i<a>_bp_bta               |
//| | | | |   | | | |                 | | | | i<a>_ucode_p1           |
//| | | | |   | | | |                 | | | | | i<a>_reset            |
//| | | | |   | | | |                 | | | | | | i<a>_check_next     |
//| | | | |   | | | |                 | | | | | | | i<a>_comp         |
//| | | | |   | | | |                 | | | | | | | |                 |
//| | | | |   | | | |                 | | | | | | | |                 |
//| | | | 012 | | | |                 | | | | | | | |                 |
//*TYPE*==============================+===============================+
//| P P P PPP P P P P                 | S S S S S S S                 |
//*TERMS*=============================+===============================+
//| 1 0 0 000 0 0 0 0                 | 1 0 0 0 0 1 1                 | # Completing
//| 1 0 0 000 0 0 0 1                 | 0 0 0 0 0 0 0                 | # Completing without updating ifar stupid FU exceptions
//| 1 0 0 101 0 0 0 1                 | 0 0 0 0 0 0 0                 | # Completing without updating ifar stupid FU exceptions
//| 1 0 1 --- 0 - 0 .                 | 0 1 0 0 0 0 1                 | # Miss predict
//| 1 1 1 --- 0 0 0 .                 | 0 1 0 0 0 0 1                 | # Miss predict
//| 1 1 0 --- 0 0 0 .                 | 0 0 1 0 0 1 1                 | # Correct predict
//| 1 - - 010 0 0 0 .                 | 0 0 0 0 0 1 0                 | # Ucode Start Complete
//| 1 - - 100 0 0 0 .                 | 0 0 0 0 0 1 0                 | # Ucode Middle Complete
//| 1 - - 101 0 0 0 0                 | 0 0 0 1 0 1 1                 | # Ucode End Complete
//| 1 - - --- 1 0 - .                 | 0 0 0 0 0 1 0                 | # Completing RAM
//| 1 - - --- - 1 - .                 | 0 1 0 0 0 0 0                 | # Completing MTIAR in RAM
//| 0 - - --- - - 1 .                 | 0 0 0 0 1 0 0                 | # Completing RFI Used to only update IAR
//*END*===============================+===============================+
//?TABLE END NIA<a> ;
//?generate end;
//
//
//?TABLE tbl_iu_exection_list LISTING(final) OPTIMIZE PARMS(ON-SET,DC-SET);
//*INPUTS*====================*OUTPUTS*===========================================================================*
//|                           |                                                                                   |
//| cp3_iu_excvec_val         |                                                                                   |
//| | cp3_iu_excvec           | mcheck_iu                                                                         |
//| | |    dis_mm_mchk        | | instruction_tlb_iu                                                              |
//| | |    |                  | | | instruction_storage_iu                                                        |
//| | |    |                  | | | | instruction_storage_hv_iu                                                   |
//| | |    |                  | | | | | system_call_iu                                                            |
//| | |    |                  | | | | | | system_call_hyp_iu                                                      |
//| | |    |                  | | | | | | | program_iu                                                            |
//| | |    |                  | | | | | | | | hyp_priv_iu                                                         |
//| | |    |                  | | | | | | | | | n_flush_iu                                                        |
//| | |    |                  | | | | | | | | | |  FP_iu                                                          |
//| | |    |                  | | | | | | | | | |  | ST_iu                                                        |
//| | |    |                  | | | | | | | | | |  | | DLK_iu                                                     |
//| | |    |                  | | | | | | | | | |  | | |  AP_iu                                                   |
//| | |    |                  | | | | | | | | | |  | | |  | BO_iu                                                 |
//| | |    |                  | | | | | | | | | |  | | |  | | TLBI_iu                                             |
//| | |    |                  | | | | | | | | | |  | | |  | | | PT_iu                                             |
//| | |    |                  | | | | | | | | | |  | | |  | | | | SPV_iu                                          |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | EPID_iu                                       |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | PIL_iu                                      |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | PPR_iu                                    |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | | PTR_iu                                  |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | | | PUO_iu                                |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | | | | PIE_iu                              |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | | | | | UCT_iu                            |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | | | | | | DATA_iu                         |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | | | | | | | ESR_iu                        |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | | | | | | | |                             |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  ICache_l2_ecc_iu           |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | IErat_multi_iu           |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | IErat_par_iu           |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | |                      |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | iu_db_mask           |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | |                    |
//| | |    |                  | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | |         111111111  |
//| | 0123 |                  | | | | | | | | | |  | | 01 | | | | | | | | | | | | | |  | | | 0123456789012345678  |
//*TYPE*======================+===================================================================================+
//| P PPPP P                  | S S S S S S S S S  S S SS S S S S S S S S S S S S S S  S S S SSSSSSSSSSSSSSSSSSS  |
//*TERMS*=====================+===================================================================================+
//| 0 ---- -                  | 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 1111111111111111111  |
//| 1 0000 0                  | 1 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 1 0000000000000000000  | Machine Check           I-ERAT Parity Error                   IEPE           0x000    0
//| 1 0000 1                  | 0 0 0 0 0 0 0 0 1  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 1 0000000000000000000  |                         I-ERAT Parity Error     NFLUSH(NO_MCHK, XUCR4[MMU_MCHK]=0 and CCR2[NOTLB]=0)
//| 1 0001 -                  | 1 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1 0 0 0000000000000000000  | Machine Check           L2 ECC                                               0x000    1
//| 1 0010 0                  | 1 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 1 0 0000000000000000000  | Machine Check           IERAT Multi-hit Error                 IEMH           0x000    2
//| 1 0010 1                  | 0 0 0 0 0 0 0 0 1  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 1 0 0000000000000000000  |                         IERAT Multi-hit Error   NFLUSH(NO_MCHK, XUCR4[MMU_MCHK]=0 and CCR2[NOTLB]=0)
//| 1 0101 -                  | 0 1 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0001011110000000001  | Instruction TLB         ERAT Miss                                            0x1E0    5
//| 1 0110 -                  | 0 0 1 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 1  0 0 0 0001011110000000001  | Instruction Storage     Execution Access Violation                           0x080    6
//| 1 0111 -                  | 0 0 0 0 0 0 1 0 0  0 0 00 0 0 0 0 0 0 0 1 0 0 0 0 0 1  0 0 0 0001011110000000001  | Program	                IU sourced priviledged instruction    PPR            0x0E0    7
//| 1 1000 -                  | 0 0 0 0 0 0 0 1 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0001011110000000001  | Hypervisor Priv         IU source Hypervisor priviledged instruction         0x320    8
//| 1 1001 -                  | 0 0 0 0 1 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0101011110000000001  | System Call             System Call                                          0x120    9
//| 1 1010 -                  | 0 0 0 0 0 1 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0101011110000000001  | System Call             System Call Hypervisor                               0x300   10
//| 1 1011 -                  | 0 0 0 0 0 0 1 0 0  1 0 00 1 0 0 0 1 0 0 0 0 1 0 0 0 1  0 0 0 0001011110000000001  | Program                 Unimplemented Op                     PUO,[FP,AP,SPV] 0x0E0   11
//| 1 1100 -                  | 0 0 0 0 0 0 1 0 0  0 0 00 0 0 0 0 0 0 1 0 0 0 0 0 0 1  0 0 0 0001011110000000001  | Program                 Illegal SC/DCR                        PIL            0x0E0   12
//*END*=======================+===================================================================================+
//?TABLE END tbl_iu_exection_list;
//
//
//?TABLE tbl_lq_exection_list LISTING(final) OPTIMIZE PARMS(ON-SET,DC-SET);
//*INPUTS*===========================*OUTPUTS*==========================================================================================*
//|                                  |                                                                                                  |
//| cp3_lq_excvec_val                | lrat_lq                                                                                          |
//| | cp3_lq_excvec                  | | fp_unavailable_lq                                                                              |
//| | |                              | | | ap_unavailable_lq                                                                            |
//| | |                              | | | | vec_unavailable_lq                                                                         |
//| | |                              | | | | | program_lq                                                                               |
//| | |                              | | | | | | mcheck_lq                                                                              |
//| | |                              | | | | | | | data_tlb_lq                                                                          |
//| | |                              | | | | | | | | data_storage_lq                                                                    |
//| | |                              | | | | | | | | | data_storage_hv_lq                                                               |
//| | |                              | | | | | | | | | | alignment_lq                                                                   |
//| | |                              | | | | | | | | | | | hyp_priv_lq                                                                  |
//| | |                              | | | | | | | | | | | |                                                                            |
//| | |                              | | | | | | | | | | | |  FP_lq                                                                     |
//| | |                              | | | | | | | | | | | |  | ST_lq                                                                   |
//| | |                              | | | | | | | | | | | |  | | DLK_lq                                                                |
//| | |                              | | | | | | | | | | | |  | | |  AP_lq                                                              |
//| | |                              | | | | | | | | | | | |  | | |  | BO_lq                                                            |
//| | |                              | | | | | | | | | | | |  | | |  | | TLBI_lq                                                        |
//| | |                              | | | | | | | | | | | |  | | |  | | | PT_lq                                                        |
//| | |                              | | | | | | | | | | | |  | | |  | | | | SPV_lq                                                     |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | EPID_lq                                                  |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | PIL_lq                                                 |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | PPR_lq                                               |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | PTR_lq                                             |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | PUO_lq                                           |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | PIE_lq                                         |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | UCT_lq                                       |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | DATA_lq                                    |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | ESR_lq                                   |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |                                        |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  DCache_dir_multi_lq                   |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | TLB_LRU_par_lq                      |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | DCache_l2_ecc_lq                  |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | DCache_dir_par_lq               |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | DCache_par_lq                 |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | | DErat_multi_lq              |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | | | TLB_multi_lq              |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | | | | DErat_par_lq            |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | | | | | TLB_par_lq            |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | | | | | | lq_db_mask          |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | | | | | | |                   |
//| | |                              | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | | | | | | |         111111111 |
//| | 012345                         | | | | | | | | | | | |  | | 01 | | | | | | | | | | | | | |  | | | | | | | | | 0123456789012345678 |
//*TYPE*=============================+==================================================================================================+
//| P PPPPPP                         | S S S S S S S S S S S  S S SS S S S S S S S S S S S S S S  S S S S S S S S S SSSSSSSSSSSSSSSSSSS |
//*TERMS*============================+==================================================================================================+
//| 0 ------                         | 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 1111111111111111111 |
//| 1 000000                         | 0 0 0 0 1 0 0 0 0 0 0  1 0 00 0 0 0 0 0 0 1 0 0 0 0 0 0 1  0 0 0 0 0 0 0 0 0 0001011110000000001 | Illegal instr type      LQ Sourced                              PIL                          0x0E0   0
//| 1 000001                         | 0 0 0 0 1 0 0 0 0 0 0  1 0 00 1 0 0 0 1 0 0 1 0 0 0 0 0 1  0 0 0 0 0 0 0 0 0 0001011110000000001 | Program                 LQ Priviledged Program Interrupt        PPR                          0x0E0   1
//| 1 000010                         | 0 1 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0001011110000000001 | FP Unavailable          XU Sourced                                                           0x100   2
//| 1 000011                         | 0 0 1 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0001011110000000001 | AP Unavailable          XU Sourced                                                           0x140   3
//| 1 000100                         | 0 0 0 1 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0001011110000000001 | Vector Unavailable      XU Sourced                                                           0x200   4
//| 1 000101                         | 0 0 0 0 1 0 0 0 0 0 0  1 0 00 1 0 0 0 1 0 0 0 0 1 0 0 0 1  0 0 0 0 0 0 0 0 0 0001011110000000001 | Program                 Unimplemented Op                        PUO,[FP,AP,SPV]              0x0E0   5
//| 1 000110                         | 0 0 0 0 0 0 0 0 0 0 1  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 0 0001011110000000001 | Hypervisor Priv         LQ sourced priviledged instruction                                   0x320   6
//| 1 000111                         | 0 0 0 0 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 1 0 0000011110000000001 | Machine Check           D-ERAT Parity Error                     DEPE                         0x000   7
//| 1 001000                         | 0 0 0 0 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 1 0 0 0 0 0 0000011110000000001 | Machine Check           Data Cache Directory Parity Error       DDPE                         0x000   8
//| 1 001001                         | 0 0 0 0 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 1 0 0 0 0 0000011110000000001 | Machine Check           Data Cache Parity Error                 DCPE                         0x000   9
//| 1 001010                         | 0 0 0 0 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 1 0 0 0 0000011110000000001 | Machine Check           DERAT Multi-hit Error                   DEMH                         0x000   10
//| 1 001011                         | 0 0 0 0 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1 0 0 0 0 0 0 0 0 0000011110000000001 | Machine Check           Data Cache Multi-hit Error              DEMH                         0x000   11
//| 1 001100                         | 0 0 0 0 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 0 0 1 0000011110000000001 | Machine Check           TLB Parity Error                        TLBPE                        0x000   12
//| 1 001101                         | 0 0 0 0 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 1 0 0 0 0 0 0 0 0000011110000000001 | Machine Check           TLB LRU Parity Error                    TLBLRUPE                     0x000   13
//| 1 001110                         | 0 0 0 0 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0 1 0 0 0000011110000000001 | Machine Check           TLB MultiHit Error                      TLBMH                        0x000   14
//| 1 001111                         | 0 0 0 0 0 0 1 0 0 0 0  1 1 00 1 0 0 0 1 1 0 0 0 0 0 0 0 1  0 0 0 0 0 0 0 0 0 0001011110000000001 | Data TLB                TLB/ERAT Miss                           [ST],[FP,AP,SPV],[EPID]      0x1C0   15
//| 1 010000                         | 0 0 0 0 0 0 0 1 0 0 0  1 1 00 1 0 0 1 1 1 0 0 0 0 0 0 0 1  0 0 0 0 0 0 0 0 0 0001011110000000001 | Data Storage            Page Table Fault                        [ST],PT,[FP,AP,SPV],[EPID]   0x060   16
//| 1 010001                         | 0 0 0 0 0 0 0 0 1 0 0  1 1 00 1 0 1 0 1 1 0 0 0 0 0 0 0 1  0 0 0 0 0 0 0 0 0 0001011110000000001 | Data Storage            TLB Ineligible                          [ST],TLBI,[FP,AP,SPV],[EPID] 0x060   17
//| 1 010010                         | 0 0 0 0 0 0 0 1 0 0 0  0 1 10 0 0 0 0 0 0 0 0 0 0 0 0 0 1  0 0 0 0 0 0 0 0 0 0001011110000000001 | Data Storage            D$ Lock Instruction                     [ST],DLK0                    0x060   19
//| 1 010011                         | 0 0 0 0 0 0 0 1 0 0 0  0 1 01 0 0 0 0 0 0 0 0 0 0 0 0 0 1  0 0 0 0 0 0 0 0 0 0001011110000000001 | Data Storage            I$ Lock Instruction                     [ST],DLK1                    0x060   20
//| 1 010100                         | 0 0 0 0 0 0 0 0 1 0 0  1 1 00 1 0 0 0 1 1 0 0 0 0 0 0 0 1  0 0 0 0 0 0 0 0 0 0001011110000000001 | Data Storage            Virtualization Fault bit set            [ST],[FP,AP,SPV],[EPID]      0x060   21
//| 1 010101                         | 0 0 0 0 0 0 0 1 0 0 0  1 1 00 1 0 0 0 1 1 0 0 0 0 0 0 0 1  0 0 0 0 0 0 0 0 0 0001011110000000001 | Data Storage            R/W Access violation                    [ST],[FP,AP,SPV]             0x060   22
//| 1 010110                         | 0 0 0 0 0 0 0 1 0 0 0  0 1 00 0 0 0 0 0 0 0 0 0 0 0 0 0 1  0 0 0 0 0 0 0 0 0 0001011110000000001 | Data Storage            LWARX/STWCX Instruction with I=1 or W=1 [ST]                         0x060   23
//| 1 010111                         | 0 0 0 0 0 0 0 1 0 0 0  0 0 00 0 0 0 0 0 1 0 0 0 0 0 1 0 1  0 0 0 0 0 0 0 0 0 0001011110000000001 | Data Storage            Unavaible Coprocessor Type              UCT,[EPID]                   0x060   24
//| 1 011000                         | 0 0 0 0 0 0 0 0 0 1 0  1 1 00 1 0 0 0 1 1 0 0 0 0 0 0 0 1  0 0 0 0 0 0 0 0 0 0001011110000000001 | Alignment               Load or Store alignment                 [ST],[FP,AP,SPV],[EPID]      0x0C0   25
//| 1 011001                         | 1 0 0 0 0 0 0 0 0 0 0  1 1 00 1 0 0 1 1 1 0 0 0 0 0 0 1 1  0 0 0 0 0 0 0 0 0 0001011110000000001 | LRAT                    Data side LRAT Miss                     [ST],DATA,PT,[FP,AP,SPV],[EPID] 0x340   18
//| 1 011010                         | 0 0 0 0 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 1 0 0 0 0 0 0 0000011110000000001 | Machine Check           Dcache L2 Reload UE                     DL2ECC                       0x000   26
//*END*==============================+==================================================================================================+
//?TABLE END tbl_lq_exection_list;
//
//
//?TABLE tbl_xu_exection_list LISTING(final) OPTIMIZE PARMS(ON-SET,DC-SET);
//*INPUTS*==================*OUTPUTS*==============================================================================*
//|                         |                                                                                      |
//| cp3_xu_excvec_val       | mcheck_xu                                                                            |
//| | cp3_xu_excvec         | | program_xu                                                                         |
//| | |                     | | | cp3_icmp_excep                                                                   |
//| | |                     | | | | hyp_priv_xu                                                                    |
//| | |                     | | | | | data_storage_xu                                                              |
//| | |                     | | | | | | tlb_xu                                                                     |
//| | |                     | | | | | | | lrat_xu                                                                  |
//| | |                     | | | | | | | |                                                                        |
//| | |                     | | | | | | | |  FP_xu                                                                 |
//| | |                     | | | | | | | |  | ST_xu                                                               |
//| | |                     | | | | | | | |  | | DLK_xu                                                            |
//| | |                     | | | | | | | |  | | |  AP_xu                                                          |
//| | |                     | | | | | | | |  | | |  | BO_xu                                                        |
//| | |                     | | | | | | | |  | | |  | | TLBI_xu                                                    |
//| | |                     | | | | | | | |  | | |  | | | PT_xu                                                    |
//| | |                     | | | | | | | |  | | |  | | | | SPV_xu                                                 |
//| | |                     | | | | | | | |  | | |  | | | | | EPID_xu                                              |
//| | |                     | | | | | | | |  | | |  | | | | | | PIL_xu                                             |
//| | |                     | | | | | | | |  | | |  | | | | | | | PPR_xu                                           |
//| | |                     | | | | | | | |  | | |  | | | | | | | | PTR_xu                                         |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | PUO_xu                                       |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | PIE_xu                                     |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | UCT_xu                                   |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | | DATA_xu                                |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | | | ESR_xu                               |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | | | |                                    |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | | | |  TLB_LRU_par_xu                    |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | | | |  | TLB_multi_xu                    |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | IErat_par_xu                  |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | DErat_par_xu                |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | TLB_par_xu                |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | | TLB_snoop_rej_async     |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | | |                       |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | | |                       |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | | |  xu_db_mask           |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | | |  |                    |
//| | |                     | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | | | |  |         111111111  |
//| | 01234                 | | | | | | | |  | | 01 | | | | | | | | | | | | | |  | | | | | |  0123456789012345678  |
//*TYPE*====================+======================================================================================+
//| P PPPPP                 | S S S S S S S  S S SS S S S S S S S S S S S S S S  S S S S S S  SSSSSSSSSSSSSSSSSSS  |
//*TERMS*===================+======================================================================================+
//| 0 -----                 | 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0  1111111111111111111  |
//| 1 00000                 | 1 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 1 0  0000011110000000001  | # Machine Check        TLB Parity Error                        TLBPE                                0
//| 1 00001                 | 1 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1 0 0 0 0 0  0000011110000000001  | # Machine Check        TLB LRU Parity Error                    TLBRUPE                              1
//| 1 00010                 | 1 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 1 0 0 0 0  0000011110000000001  | # Machine Check        TLB Multi-Hit Error                     TLBMH                                2
//| 1 00011                 | 1 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 1 0 0 0  0000011110000000001  | # Machine Check        IERAT search parity error               IEPE                                 3
//| 1 00100                 | 1 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 1 0 0  0000011110000000001  | # Machine Check        DERAT search parity error               DEPE                                 4
//| 1 00101                 | 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 1 0 0 0 0 0 0 1  0 0 0 0 0 0  0001011110000000001  | # Program              XU sourced illegal instruction type     PIL                                  5
//| 1 00110                 | 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 1 0 0 0 0 0 0 1  0 0 0 0 0 0  0001011110000000001  | # Program              SPR sourced illegal SPR                 PIL                                  6
//| 1 00111                 | 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 1 0 0 0 0 0 1  0 0 0 0 0 0  0001011110000000001  | # Program              SPR sourced priviledged SPR             PPR                                  7
//| 1 01000                 | 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 1 0 0 0 0 0 1  0 0 0 0 0 0  0001011110000000001  | # Program              XU sourced priviledged instruction      PPR                                  8
//| 1 01001                 | 0 0 0 1 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0  0001011110000000001  | # Hypervisor Priviledge Priviledged SPR                                                             9
//| 1 01010                 | 0 0 1 1 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0  0001011111000000001  | # Hypervisor Priviledge ehpriv instruction                                                          10
//| 1 01011                 | 0 0 0 1 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 0  0001011110000000001  | # Hypervisor Priviledge XU sourced priviledged instruction                                          11
//| 1 01100                 | 0 0 0 0 0 1 0  1 1 00 1 0 0 0 1 1 0 0 0 0 0 0 0 1  0 0 0 0 0 0  0001011110000000001  | # Data Storage         TLB Ineligible                         [ST],[FP,AP,SPV],[EPID] 0x060         12
//| 1 01101                 | 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 1 0 0 0 0 0 0 1  0 0 0 0 0 0  0001011110000000001  | # Program              MMU Illegal Mas                         PIL                                  13
//| 1 01110                 | 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 1 0 0 0 0 1  0 0 0 0 0 0  0001111110000000001  | # Program              Trap Instruction                        PTR                                  14
//| 1 01111                 | 0 0 0 0 0 0 1  1 1 00 1 0 0 0 1 1 0 0 0 0 0 0 0 1  0 0 0 0 0 0  0001011110000000001  | # LRAT                 Data side LRAT Miss                    [ST],[FP,AP,SPV],[EPID] 0x340         15
//| 1 10000                 | 1 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0 0 1  0001011110000000001  | # Machine Check        TLBIVAX reject                                                               16
//*END*=====================+======================================================================================+
//?TABLE END tbl_xu_exection_list;
//
//?TABLE tbl_axu_exection_list LISTING(final) OPTIMIZE PARMS(ON-SET,DC-SET);
//*INPUTS*================*OUTPUTS*============================================================*
//|                       |                                                                    |
//| cp3_axu_excvec_val    | ap_unavailable_axu                                                 |
//| | cp3_axu_excvec      | | fp_unavailable_axu                                               |
//| | |                   | | | vec_unavailable_axu                                            |
//| | |                   | | | | program_fp_axu                                               |
//| | |                   | | | | | program_ap_axu                                             |
//| | |                   | | | | | |                                                          |
//| | |                   | | | | | |  FP_axu                                                  |
//| | |                   | | | | | |  | ST_axu                                                |
//| | |                   | | | | | |  | | DLK_axu                                             |
//| | |                   | | | | | |  | | |  AP_axu                                           |
//| | |                   | | | | | |  | | |  | BO_axu                                         |
//| | |                   | | | | | |  | | |  | | TLBI_axu                                     |
//| | |                   | | | | | |  | | |  | | | PT_axu                                     |
//| | |                   | | | | | |  | | |  | | | | SPV_axu                                  |
//| | |                   | | | | | |  | | |  | | | | | EPID_axu                               |
//| | |                   | | | | | |  | | |  | | | | | | PIL_axu                              |
//| | |                   | | | | | |  | | |  | | | | | | | PPR_axu                            |
//| | |                   | | | | | |  | | |  | | | | | | | | PTR_axu                          |
//| | |                   | | | | | |  | | |  | | | | | | | | | PUO_axu                        |
//| | |                   | | | | | |  | | |  | | | | | | | | | | PIE_axu                      |
//| | |                   | | | | | |  | | |  | | | | | | | | | | | UCT_axu                    |
//| | |                   | | | | | |  | | |  | | | | | | | | | | | | DATA_axu                 |
//| | |                   | | | | | |  | | |  | | | | | | | | | | | | | ESR_axu                |
//| | |                   | | | | | |  | | |  | | | | | | | | | | | | | |  axu_db_mask         |
//| | |                   | | | | | |  | | |  | | | | | | | | | | | | | |  |                   |
//| | |                   | | | | | |  | | |  | | | | | | | | | | | | | |  |         111111111 |
//| | 0123                | | | | | |  | | 01 | | | | | | | | | | | | | |  0123456789012345678 |
//*TYPE*==================+====================================================================+
//| P PPPP                | S S S S S  S S SS S S S S S S S S S S S S S S  SSSSSSSSSSSSSSSSSSS |
//*TERMS*=================+====================================================================+
//| 0 ----                | 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1111111111111111111 |
//| 1 0000                | 1 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0001011110000000001 | AP Unavailable                                       0x140   7
//| 1 0001                | 0 1 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0001011110000000001 | FP Unavailable                                       0x100   7
//| 1 0010                | 0 0 1 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0001011110000000001 | Vector Unavailable                                   0x200   7
//| 1 0011                | 0 0 0 0 1  0 0 00 1 0 0 0 0 0 0 0 0 0 0 0 0 0  0001011110000000001 | Progam AP Enabled       AP                           0x0E0   100
//| 1 0100                | 0 0 0 1 0  1 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 1  0001011110000000001 | Progam FP Enabled       FP                           0x0E0   10
//| 1 0101                | 0 0 0 1 0  1 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 1  0001011110000000001 | Progam FP Enabled       FP                           0x0E0   10
//*END*===================+====================================================================+
//?TABLE END tbl_axu_exection_list;
//
//
//?TABLE tbl_async_exection_list LISTING(final) OPTIMIZE PARMS(ON-SET,DC-SET);
//*INPUTS*===========================================*OUTPUTS*=========================================================================================================================*
//|                                                  | instr_tlb_async                                                                                                                 |
//|                                                  | | pt_fault_async                                                                                                                |
//|                                                  | | | lrat_miss_async                                                                                                             |
//|                                                  | | | | tlb_inelig_async                                                                                                          |
//|                                                  | | | | | TLB_multi_async                                                                                                         |
//|                                                  | | | | | | TLB_par_async                                                                                                         |
//|                                                  | | | | | | | TLB_LRU_par_async                                                                                                   |
//|                                                  | | | | | | | | debug_icmp                                                                                                        |
//|                                                  | | | | | | | | | debug_irpt                                                                                                      |
//|                                                  | | | | | | | | | | debug_async                                                                                                   |
//|                                                  | | | | | | | | | | | mchk_ext_async                                                                                              |
//| cp3_async_int_val                                | | | | | | | | | | | | program_fp_en_async                                                                                       |
//| | cp3_async_int                                  | | | | | | | | | | | | | guest_dbell_mchk_async                                                                                  |
//| | |                                dis_mm_mchk   | | | | | | | | | | | | | | perf_async                                                                                            |
//| | |                                |             | | | | | | | | | | | | | | | UDE_input_async                                                                                     |
//| | |                                |             | | | | | | | | | | | | | | | | crit_input_async                                                                                  |
//| | |                                |             | | | | | | | | | | | | | | | | | wdog_async                                                                                      |
//| | |                                |             | | | | | | | | | | | | | | | | | | guest_wdog_async                                                                              |
//| | |                                |             | | | | | | | | | | | | | | | | | | | dbell_crit_async                                                                            |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | guest_dbell_crit_async                                                                    |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | external_async                                                                          |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | fit_async                                                                             |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | guest_fit_async                                                                     |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | dec_async                                                                         |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | guest_dec_async                                                                 |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | dbell_async                                                                   |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | guest_dbell_async                                                           |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | user_dec_async                                                            |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | dp_cp_async                                                             |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | dp_cp_async_bus_snoop                                                 |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | async_np1                                                           |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | pc_stop                                                           |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | async_n                                                         |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  FP_async                                                     |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | ST_async                                                   |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | DLK_async                                                |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  AP_async                                              |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | BO_async                                            |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | TLBI_async                                        |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | PT_async                                        |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | SPV_async                                     |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | EPID_async                                  |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | PIL_async                                 |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | PPR_async                               |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | PTR_async                             |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | | PUO_async                           |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | | | PIE_async                         |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | | | | UCT_async                       |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | | | | | DATA_async                    |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | ESR_async                   |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  crit_async               |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | mcheck_async           |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | guest_async          |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | irpt_taken_async   |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | |                  |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | |                  |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | |                  |
//| | |                                |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | |                  |
//| | |         1111111111222222222233 |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | |  | | | | | | | | | | | | | |  | | | |                  |
//| | 01234567890123456789012345678901 |             | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |  | | 01 | | | | | | | | | | | | | |  | | | |                  |
//*TYPE*=============================================+=================================================================================================================================+
//| P PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP P             | S S S S S S S S S S S S S S S S S S S S S S S S S S S S S S S S S  S S SS S S S S S S S S S S S S S S  S S S S                  |
//*TERMS*============================================+=================================================================================================================================+
//| 0 -------------------------------- -             | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0                  |
//| 1 1------------------------------- -             | 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 1                  | Instruction TLB miss            TLBLRUPER               0x000   10

//| 1 01------------------------------ 0             | 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 1 0 0                  | TLB_LRU_parity error            TLBLRUPER               0x000   10
//| 1 001----------------------------- 0             | 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 1 0 0                  | TLB parity error                TLBPER                  0x000   10
//| 1 0001---------------------------- 0             | 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 1 0 0                  | TLB multihit                    TLBMHIT                 0x000   10
//| 1 01------------------------------ 1             | 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0                  | TLB_LRU_parity error            NFLUSH(NO_MCHK, XUCR4[MMU_MCHK]=0 and CCR2[NOTLB]=0)
//| 1 001----------------------------- 1             | 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0                  | TLB parity error                NFLUSH(NO_MCHK, XUCR4[MMU_MCHK]=0 and CCR2[NOTLB]=0)
//| 1 0001---------------------------- 1             | 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0                  | TLB multihit                    NFLUSH(NO_MCHK, XUCR4[MMU_MCHK]=0 and CCR2[NOTLB]=0)

//| 1 00001--------------------------- -             | 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 1 0 0 0 0 0 0 0 0 0 1  0 0 0 1                  | IU PT Fault                                             0x080   10
//| 1 000001-------------------------- -             | 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 1 0 0 0 0 0 0 0 0 0 0 1  0 0 0 1                  | IU TLB InElig                   TLBI                    0x080   10
//| 1 0000001------------------------- -             | 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 1 0 0 0 0 0 0 0 0 0 1  0 0 0 1                  | IU LRAT Miss                                            0x340   10
//| 1 00000001------------------------ -             | 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1 0 0 0                  | Debug icmp              Crit    DBSR update             0x040   10
//| 1 000000001----------------------- -             | 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1 0 0 0                  | Debug irpt              Crit    DBSR update             0x040   10
//| 1 0000000001---------------------- -             | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0                  | mm hold req
//| 1 00000000001--------------------- -             | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0                  | mm bus snoop hold req
//| 1 000000000001-------------------- -             | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0                  | async np1
//| 1 0000000000001------------------- -             | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 0                  | pc_iu_stop
//| 1 00000000000001------------------ -             | 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1 0 0 0                  | Debug async             Crit    DBSR update             0x040   10
//| 1 000000000000001----------------- -             | 0 0 0 0 0 0 0 0 0 - 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1 0 00 0 0 0 0 0 0 0 0 0 0 1 0 0 1  0 0 0 1                  | Progam FP Enabled               FP, PIE                 0x0E0   10
//| 1 0000000000000001---------------- -             | 0 0 0 0 0 0 0 0 0 - 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 1 0 0                  | Mchk external           MCHK                            0x000   10
//| 1 00000000000000001--------------- -             | 0 0 0 0 0 0 0 0 0 - 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1 0 0 0                  | Guest DBell Mach Check  Crit                            0x2E0   19
//| 1 000000000000000001-------------- -             | 0 0 0 0 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1 0 0 0                  | UDE debug event         Crit    DBSR update             0x040   10
//| 1 0000000000000000001------------- -             | 0 0 0 0 0 0 0 0 0 - 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1 0 0 0                  | Critical Input          Crit                            0x020   21
//| 1 00000000000000000001------------ -             | 0 0 0 0 0 0 0 0 0 - 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1 0 0 0                  | Watchdog                Crit                            0x1A0   22
//| 1 000000000000000000001----------- -             | 0 0 0 0 0 0 0 0 0 - 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1 0 0 0                  | Guest Watchdog          Crit                            0x1A0   22.1
//| 1 0000000000000000000001---------- -             | 0 0 0 0 0 0 0 0 0 - 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1 0 0 0                  | Doorbell Critical       Crit                            0x2A0   23
//| 1 00000000000000000000001--------- -             | 0 0 0 0 0 0 0 0 0 - 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  1 0 0 0                  | Guest Doorbell Critical Crit                            0x2E0   24
//| 1 000000000000000000000001-------- -             | 0 0 0 0 0 0 0 0 0 - 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 1                  | External                                                0x0A0   25
//| 1 0000000000000000000000001------- -             | 0 0 0 0 0 0 0 0 0 - 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 1                  | Fixed Interval Timer    Crit                            0x180   26
//| 1 00000000000000000000000001------ -             | 0 0 0 0 0 0 0 0 0 - 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 1 1                  | Guest Fixed Int Timer   Crit                            0x180   26.1
//| 1 000000000000000000000000001----- -             | 0 0 0 0 0 0 0 0 0 - 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 1                  | Decrement                                               0x160   27
//| 1 0000000000000000000000000001---- -             | 0 0 0 0 0 0 0 0 0 - 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 1 1                  | Guest Decrement                                         0x160   27.1
//| 1 00000000000000000000000000001--- -             | 0 0 0 0 0 0 0 0 0 - 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 1                  | Doorbell                                                0x280   28
//| 1 000000000000000000000000000001-- -             | 0 0 0 0 0 0 0 0 0 - 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 1                  | Guest Doorbell                                          0x2C0   29
//| 1 0000000000000000000000000000001- -             | 0 0 0 0 0 0 0 0 0 - 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 1                  | User Decrementer                                        0x800   30
//| 1 00000000000000000000000000000001 -             | 0 0 0 0 0 0 0 0 0 - 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 00 0 0 0 0 0 0 0 0 0 0 0 0 0 0  0 0 0 1                  | Perf                                                    0x820   31
//*END*==============================================+=================================================================================================================================+
//?TABLE END tbl_async_exection_list;
//
//table_end
//
//assign_start

assign nia0_pt[1] =
    (({ i0_complete , i0_bp_pred ,
    i0_br_miss , i0_ucode[0] ,
    i0_ucode[1] , i0_ucode[2] ,
    i0_isram , i0_mtiar ,
    i0_rfi , i0_n_np1_flush
     }) === 10'b1000000000);
assign nia0_pt[2] =
    (({ i0_complete , i0_ucode[0] ,
    i0_ucode[1] , i0_ucode[2] ,
    i0_isram , i0_mtiar ,
    i0_rfi , i0_n_np1_flush
     }) === 8'b11010000);
assign nia0_pt[3] =
    (({ i0_complete , i0_ucode[0] ,
    i0_ucode[1] , i0_ucode[2] ,
    i0_mtiar , i0_rfi
     }) === 6'b101000);
assign nia0_pt[4] =
    (({ i0_complete , i0_ucode[0] ,
    i0_ucode[1] , i0_ucode[2] ,
    i0_mtiar , i0_rfi
     }) === 6'b110000);
assign nia0_pt[5] =
    (({ i0_complete , i0_bp_pred ,
    i0_br_miss , i0_isram ,
    i0_rfi }) === 5'b10100);
assign nia0_pt[6] =
    (({ i0_complete , i0_rfi
     }) === 2'b01);
assign nia0_pt[7] =
    (({ i0_complete , i0_bp_pred ,
    i0_br_miss , i0_isram ,
    i0_mtiar , i0_rfi
     }) === 6'b110000);
assign nia0_pt[8] =
    (({ i0_complete , i0_br_miss ,
    i0_isram , i0_mtiar ,
    i0_rfi }) === 5'b11000);
assign nia0_pt[9] =
    (({ i0_complete , i0_mtiar
     }) === 2'b11);
assign nia0_pt[10] =
    (({ i0_complete , i0_isram ,
    i0_mtiar }) === 3'b110);
assign i0_p1 =
    (nia0_pt[1]);
assign i0_bta =
    (nia0_pt[8] | nia0_pt[9]
    );
assign i0_bp_bta =
    (nia0_pt[7]);
assign i0_ucode_p1 =
    (nia0_pt[2]);
assign i0_reset =
    (nia0_pt[6]);
assign i0_check_next =
    (nia0_pt[1] | nia0_pt[2]
     | nia0_pt[3] | nia0_pt[4]
     | nia0_pt[7] | nia0_pt[10]
    );
assign i0_comp =
    (nia0_pt[1] | nia0_pt[2]
     | nia0_pt[5] | nia0_pt[7]
     | nia0_pt[8]);

assign nia1_pt[1] =
    (({ i1_complete , i1_bp_pred ,
    i1_br_miss , i1_ucode[0] ,
    i1_ucode[1] , i1_ucode[2] ,
    i1_isram , i1_mtiar ,
    i1_rfi , i1_n_np1_flush
     }) === 10'b1000000000);
assign nia1_pt[2] =
    (({ i1_complete , i1_ucode[0] ,
    i1_ucode[1] , i1_ucode[2] ,
    i1_isram , i1_mtiar ,
    i1_rfi , i1_n_np1_flush
     }) === 8'b11010000);
assign nia1_pt[3] =
    (({ i1_complete , i1_ucode[0] ,
    i1_ucode[1] , i1_ucode[2] ,
    i1_mtiar , i1_rfi
     }) === 6'b101000);
assign nia1_pt[4] =
    (({ i1_complete , i1_ucode[0] ,
    i1_ucode[1] , i1_ucode[2] ,
    i1_mtiar , i1_rfi
     }) === 6'b110000);
assign nia1_pt[5] =
    (({ i1_complete , i1_bp_pred ,
    i1_br_miss , i1_isram ,
    i1_rfi }) === 5'b10100);
assign nia1_pt[6] =
    (({ i1_complete , i1_rfi
     }) === 2'b01);
assign nia1_pt[7] =
    (({ i1_complete , i1_bp_pred ,
    i1_br_miss , i1_isram ,
    i1_mtiar , i1_rfi
     }) === 6'b110000);
assign nia1_pt[8] =
    (({ i1_complete , i1_br_miss ,
    i1_isram , i1_mtiar ,
    i1_rfi }) === 5'b11000);
assign nia1_pt[9] =
    (({ i1_complete , i1_mtiar
     }) === 2'b11);
assign nia1_pt[10] =
    (({ i1_complete , i1_isram ,
    i1_mtiar }) === 3'b110);
assign i1_p1 =
    (nia1_pt[1]);
assign i1_bta =
    (nia1_pt[8] | nia1_pt[9]
    );
assign i1_bp_bta =
    (nia1_pt[7]);
assign i1_ucode_p1 =
    (nia1_pt[2]);
assign i1_reset =
    (nia1_pt[6]);
assign i1_check_next =
    (nia1_pt[1] | nia1_pt[2]
     | nia1_pt[3] | nia1_pt[4]
     | nia1_pt[7] | nia1_pt[10]
    );
assign i1_comp =
    (nia1_pt[1] | nia1_pt[2]
     | nia1_pt[5] | nia1_pt[7]
     | nia1_pt[8]);

assign tbl_iu_exection_list_pt[1] =
    (({ cp3_iu_excvec_val , cp3_iu_excvec[0] ,
    cp3_iu_excvec[1] , cp3_iu_excvec[2] ,
    cp3_iu_excvec[3] , dis_mm_mchk
     }) === 6'b100100);
assign tbl_iu_exection_list_pt[2] =
    (({ cp3_iu_excvec_val , cp3_iu_excvec[0] ,
    cp3_iu_excvec[1] , cp3_iu_excvec[2] ,
    cp3_iu_excvec[3] , dis_mm_mchk
     }) === 6'b100101);
assign tbl_iu_exection_list_pt[3] =
    (({ cp3_iu_excvec_val , cp3_iu_excvec[0] ,
    cp3_iu_excvec[1] , cp3_iu_excvec[2] ,
    cp3_iu_excvec[3] , dis_mm_mchk
     }) === 6'b100000);
assign tbl_iu_exection_list_pt[4] =
    (({ cp3_iu_excvec_val , cp3_iu_excvec[0] ,
    cp3_iu_excvec[1] , cp3_iu_excvec[2] ,
    cp3_iu_excvec[3] , dis_mm_mchk
     }) === 6'b100001);
assign tbl_iu_exection_list_pt[5] =
    (({ cp3_iu_excvec_val , cp3_iu_excvec[0] ,
    cp3_iu_excvec[1] , cp3_iu_excvec[2] ,
    cp3_iu_excvec[3] }) === 5'b10101);
assign tbl_iu_exection_list_pt[6] =
    (({ cp3_iu_excvec_val , cp3_iu_excvec[0] ,
    cp3_iu_excvec[1] , cp3_iu_excvec[2] ,
    cp3_iu_excvec[3] }) === 5'b10111);
assign tbl_iu_exection_list_pt[7] =
    (({ cp3_iu_excvec_val , cp3_iu_excvec[0] ,
    cp3_iu_excvec[1] , cp3_iu_excvec[2] ,
    cp3_iu_excvec[3] }) === 5'b10110);
assign tbl_iu_exection_list_pt[8] =
    (({ cp3_iu_excvec_val , cp3_iu_excvec[0] ,
    cp3_iu_excvec[1] , cp3_iu_excvec[2] ,
    cp3_iu_excvec[3] }) === 5'b11100);
assign tbl_iu_exection_list_pt[9] =
    (({ cp3_iu_excvec_val , cp3_iu_excvec[0] ,
    cp3_iu_excvec[1] , cp3_iu_excvec[2] ,
    cp3_iu_excvec[3] }) === 5'b10001);
assign tbl_iu_exection_list_pt[10] =
    (({ cp3_iu_excvec_val , cp3_iu_excvec[0] ,
    cp3_iu_excvec[1] , cp3_iu_excvec[2] ,
    cp3_iu_excvec[3] }) === 5'b11001);
assign tbl_iu_exection_list_pt[11] =
    (({ cp3_iu_excvec_val , cp3_iu_excvec[0] ,
    cp3_iu_excvec[1] , cp3_iu_excvec[2] ,
    cp3_iu_excvec[3] }) === 5'b11000);
assign tbl_iu_exection_list_pt[12] =
    (({ cp3_iu_excvec_val , cp3_iu_excvec[0] ,
    cp3_iu_excvec[1] , cp3_iu_excvec[2] ,
    cp3_iu_excvec[3] }) === 5'b11011);
assign tbl_iu_exection_list_pt[13] =
    (({ cp3_iu_excvec_val , cp3_iu_excvec[0] ,
    cp3_iu_excvec[1] , cp3_iu_excvec[2] ,
    cp3_iu_excvec[3] }) === 5'b11010);
assign tbl_iu_exection_list_pt[14] =
    (({ cp3_iu_excvec_val }) === 1'b0);
assign mcheck_iu =
    (tbl_iu_exection_list_pt[1] | tbl_iu_exection_list_pt[3]
     | tbl_iu_exection_list_pt[9]);
assign instruction_tlb_iu =
    (tbl_iu_exection_list_pt[5]);
assign instruction_storage_iu =
    (tbl_iu_exection_list_pt[7]);
assign instruction_storage_hv_iu =
    1'b0;
assign system_call_iu =
    (tbl_iu_exection_list_pt[10]);
assign system_call_hyp_iu =
    (tbl_iu_exection_list_pt[13]);
assign program_iu =
    (tbl_iu_exection_list_pt[6] | tbl_iu_exection_list_pt[8]
     | tbl_iu_exection_list_pt[12]);
assign hyp_priv_iu =
    (tbl_iu_exection_list_pt[11]);
assign n_flush_iu =
    (tbl_iu_exection_list_pt[2] | tbl_iu_exection_list_pt[4]
    );
assign fp_iu =
    (tbl_iu_exection_list_pt[12]);
assign st_iu =
    1'b0;
assign dlk_iu[0] =
    1'b0;
assign dlk_iu[1] =
    1'b0;
assign ap_iu =
    (tbl_iu_exection_list_pt[12]);
assign bo_iu =
    1'b0;
assign tlbi_iu =
    1'b0;
assign pt_iu =
    1'b0;
assign spv_iu =
    (tbl_iu_exection_list_pt[12]);
assign epid_iu =
    1'b0;
assign pil_iu =
    (tbl_iu_exection_list_pt[8]);
assign ppr_iu =
    (tbl_iu_exection_list_pt[6]);
assign ptr_iu =
    1'b0;
assign puo_iu =
    (tbl_iu_exection_list_pt[12]);
assign pie_iu =
    1'b0;
assign uct_iu =
    1'b0;
assign data_iu =
    1'b0;
assign esr_iu =
    (tbl_iu_exection_list_pt[6] | tbl_iu_exection_list_pt[7]
     | tbl_iu_exection_list_pt[8] | tbl_iu_exection_list_pt[12]
    );
assign icache_l2_ecc_iu =
    (tbl_iu_exection_list_pt[9]);
assign ierat_multi_iu =
    (tbl_iu_exection_list_pt[1] | tbl_iu_exection_list_pt[2]
    );
assign ierat_par_iu =
    (tbl_iu_exection_list_pt[3] | tbl_iu_exection_list_pt[4]
    );
assign iu_db_mask[0] =
    (tbl_iu_exection_list_pt[14]);
assign iu_db_mask[1] =
    (tbl_iu_exection_list_pt[10] | tbl_iu_exection_list_pt[13]
     | tbl_iu_exection_list_pt[14]);
assign iu_db_mask[2] =
    (tbl_iu_exection_list_pt[14]);
assign iu_db_mask[3] =
    (tbl_iu_exection_list_pt[5] | tbl_iu_exection_list_pt[6]
     | tbl_iu_exection_list_pt[7] | tbl_iu_exection_list_pt[8]
     | tbl_iu_exection_list_pt[10] | tbl_iu_exection_list_pt[11]
     | tbl_iu_exection_list_pt[12] | tbl_iu_exection_list_pt[13]
     | tbl_iu_exection_list_pt[14]);
assign iu_db_mask[4] =
    (tbl_iu_exection_list_pt[14]);
assign iu_db_mask[5] =
    (tbl_iu_exection_list_pt[5] | tbl_iu_exection_list_pt[6]
     | tbl_iu_exection_list_pt[7] | tbl_iu_exection_list_pt[8]
     | tbl_iu_exection_list_pt[10] | tbl_iu_exection_list_pt[11]
     | tbl_iu_exection_list_pt[12] | tbl_iu_exection_list_pt[13]
     | tbl_iu_exection_list_pt[14]);
assign iu_db_mask[6] =
    (tbl_iu_exection_list_pt[5] | tbl_iu_exection_list_pt[6]
     | tbl_iu_exection_list_pt[7] | tbl_iu_exection_list_pt[8]
     | tbl_iu_exection_list_pt[10] | tbl_iu_exection_list_pt[11]
     | tbl_iu_exection_list_pt[12] | tbl_iu_exection_list_pt[13]
     | tbl_iu_exection_list_pt[14]);
assign iu_db_mask[7] =
    (tbl_iu_exection_list_pt[5] | tbl_iu_exection_list_pt[6]
     | tbl_iu_exection_list_pt[7] | tbl_iu_exection_list_pt[8]
     | tbl_iu_exection_list_pt[10] | tbl_iu_exection_list_pt[11]
     | tbl_iu_exection_list_pt[12] | tbl_iu_exection_list_pt[13]
     | tbl_iu_exection_list_pt[14]);
assign iu_db_mask[8] =
    (tbl_iu_exection_list_pt[5] | tbl_iu_exection_list_pt[6]
     | tbl_iu_exection_list_pt[7] | tbl_iu_exection_list_pt[8]
     | tbl_iu_exection_list_pt[10] | tbl_iu_exection_list_pt[11]
     | tbl_iu_exection_list_pt[12] | tbl_iu_exection_list_pt[13]
     | tbl_iu_exection_list_pt[14]);
assign iu_db_mask[9] =
    (tbl_iu_exection_list_pt[14]);
assign iu_db_mask[10] =
    (tbl_iu_exection_list_pt[14]);
assign iu_db_mask[11] =
    (tbl_iu_exection_list_pt[14]);
assign iu_db_mask[12] =
    (tbl_iu_exection_list_pt[14]);
assign iu_db_mask[13] =
    (tbl_iu_exection_list_pt[14]);
assign iu_db_mask[14] =
    (tbl_iu_exection_list_pt[14]);
assign iu_db_mask[15] =
    (tbl_iu_exection_list_pt[14]);
assign iu_db_mask[16] =
    (tbl_iu_exection_list_pt[14]);
assign iu_db_mask[17] =
    (tbl_iu_exection_list_pt[14]);
assign iu_db_mask[18] =
    (tbl_iu_exection_list_pt[5] | tbl_iu_exection_list_pt[6]
     | tbl_iu_exection_list_pt[7] | tbl_iu_exection_list_pt[8]
     | tbl_iu_exection_list_pt[10] | tbl_iu_exection_list_pt[11]
     | tbl_iu_exection_list_pt[12] | tbl_iu_exection_list_pt[13]
     | tbl_iu_exection_list_pt[14]);

assign tbl_lq_exection_list_pt[1] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1010010);
assign tbl_lq_exection_list_pt[2] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1011010);
assign tbl_lq_exection_list_pt[3] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1001101);
assign tbl_lq_exection_list_pt[4] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1001110);
assign tbl_lq_exection_list_pt[5] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1001100);
assign tbl_lq_exection_list_pt[6] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1001011);
assign tbl_lq_exection_list_pt[7] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1001001);
assign tbl_lq_exection_list_pt[8] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1001010);
assign tbl_lq_exection_list_pt[9] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1000111);
assign tbl_lq_exection_list_pt[10] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1001000);
assign tbl_lq_exection_list_pt[11] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1000110);
assign tbl_lq_exection_list_pt[12] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1000100);
assign tbl_lq_exection_list_pt[13] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1000011);
assign tbl_lq_exection_list_pt[14] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1000010);
assign tbl_lq_exection_list_pt[15] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1010111);
assign tbl_lq_exection_list_pt[16] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1010011);
assign tbl_lq_exection_list_pt[17] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1000000);
assign tbl_lq_exection_list_pt[18] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[4] , cp3_lq_excvec[5]
     }) === 6'b101010);
assign tbl_lq_exection_list_pt[19] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1000101);
assign tbl_lq_exection_list_pt[20] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1000001);
assign tbl_lq_exection_list_pt[21] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1001111);
assign tbl_lq_exection_list_pt[22] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1011000);
assign tbl_lq_exection_list_pt[23] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1010100);
assign tbl_lq_exection_list_pt[24] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1011001);
assign tbl_lq_exection_list_pt[25] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1010101);
assign tbl_lq_exection_list_pt[26] =
    (({ cp3_lq_excvec_val }) === 1'b0);
assign tbl_lq_exection_list_pt[27] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1010001);
assign tbl_lq_exection_list_pt[28] =
    (({ cp3_lq_excvec_val , cp3_lq_excvec[0] ,
    cp3_lq_excvec[1] , cp3_lq_excvec[2] ,
    cp3_lq_excvec[3] , cp3_lq_excvec[4] ,
    cp3_lq_excvec[5] }) === 7'b1010000);
assign lrat_lq =
    (tbl_lq_exection_list_pt[24]);
assign fp_unavailable_lq =
    (tbl_lq_exection_list_pt[14]);
assign ap_unavailable_lq =
    (tbl_lq_exection_list_pt[13]);
assign vec_unavailable_lq =
    (tbl_lq_exection_list_pt[12]);
assign program_lq =
    (tbl_lq_exection_list_pt[17] | tbl_lq_exection_list_pt[19]
     | tbl_lq_exection_list_pt[20]);
assign mcheck_lq =
    (tbl_lq_exection_list_pt[2] | tbl_lq_exection_list_pt[3]
     | tbl_lq_exection_list_pt[4] | tbl_lq_exection_list_pt[5]
     | tbl_lq_exection_list_pt[6] | tbl_lq_exection_list_pt[7]
     | tbl_lq_exection_list_pt[8] | tbl_lq_exection_list_pt[9]
     | tbl_lq_exection_list_pt[10]);
assign data_tlb_lq =
    (tbl_lq_exection_list_pt[21]);
assign data_storage_lq =
    (tbl_lq_exection_list_pt[15] | tbl_lq_exection_list_pt[16]
     | tbl_lq_exection_list_pt[18] | tbl_lq_exection_list_pt[25]
     | tbl_lq_exection_list_pt[28]);
assign data_storage_hv_lq =
    (tbl_lq_exection_list_pt[23] | tbl_lq_exection_list_pt[27]
    );
assign alignment_lq =
    (tbl_lq_exection_list_pt[22]);
assign hyp_priv_lq =
    (tbl_lq_exection_list_pt[11]);
assign fp_lq =
    (tbl_lq_exection_list_pt[17] | tbl_lq_exection_list_pt[19]
     | tbl_lq_exection_list_pt[20] | tbl_lq_exection_list_pt[21]
     | tbl_lq_exection_list_pt[22] | tbl_lq_exection_list_pt[23]
     | tbl_lq_exection_list_pt[24] | tbl_lq_exection_list_pt[25]
     | tbl_lq_exection_list_pt[27] | tbl_lq_exection_list_pt[28]
    );
assign st_lq =
    (tbl_lq_exection_list_pt[16] | tbl_lq_exection_list_pt[18]
     | tbl_lq_exection_list_pt[21] | tbl_lq_exection_list_pt[22]
     | tbl_lq_exection_list_pt[23] | tbl_lq_exection_list_pt[24]
     | tbl_lq_exection_list_pt[25] | tbl_lq_exection_list_pt[27]
     | tbl_lq_exection_list_pt[28]);
assign dlk_lq[0] =
    (tbl_lq_exection_list_pt[1]);
assign dlk_lq[1] =
    (tbl_lq_exection_list_pt[16]);
assign ap_lq =
    (tbl_lq_exection_list_pt[19] | tbl_lq_exection_list_pt[20]
     | tbl_lq_exection_list_pt[21] | tbl_lq_exection_list_pt[22]
     | tbl_lq_exection_list_pt[23] | tbl_lq_exection_list_pt[24]
     | tbl_lq_exection_list_pt[25] | tbl_lq_exection_list_pt[27]
     | tbl_lq_exection_list_pt[28]);
assign bo_lq =
    1'b0;
assign tlbi_lq =
    (tbl_lq_exection_list_pt[27]);
assign pt_lq =
    (tbl_lq_exection_list_pt[24] | tbl_lq_exection_list_pt[28]
    );
assign spv_lq =
    (tbl_lq_exection_list_pt[19] | tbl_lq_exection_list_pt[20]
     | tbl_lq_exection_list_pt[21] | tbl_lq_exection_list_pt[22]
     | tbl_lq_exection_list_pt[23] | tbl_lq_exection_list_pt[24]
     | tbl_lq_exection_list_pt[25] | tbl_lq_exection_list_pt[27]
     | tbl_lq_exection_list_pt[28]);
assign epid_lq =
    (tbl_lq_exection_list_pt[15] | tbl_lq_exection_list_pt[21]
     | tbl_lq_exection_list_pt[22] | tbl_lq_exection_list_pt[23]
     | tbl_lq_exection_list_pt[24] | tbl_lq_exection_list_pt[25]
     | tbl_lq_exection_list_pt[27] | tbl_lq_exection_list_pt[28]
    );
assign pil_lq =
    (tbl_lq_exection_list_pt[17]);
assign ppr_lq =
    (tbl_lq_exection_list_pt[20]);
assign ptr_lq =
    1'b0;
assign puo_lq =
    (tbl_lq_exection_list_pt[19]);
assign pie_lq =
    1'b0;
assign uct_lq =
    (tbl_lq_exection_list_pt[15]);
assign data_lq =
    (tbl_lq_exection_list_pt[24]);
assign esr_lq =
    (tbl_lq_exection_list_pt[15] | tbl_lq_exection_list_pt[16]
     | tbl_lq_exection_list_pt[17] | tbl_lq_exection_list_pt[18]
     | tbl_lq_exection_list_pt[19] | tbl_lq_exection_list_pt[20]
     | tbl_lq_exection_list_pt[21] | tbl_lq_exection_list_pt[22]
     | tbl_lq_exection_list_pt[23] | tbl_lq_exection_list_pt[24]
     | tbl_lq_exection_list_pt[25] | tbl_lq_exection_list_pt[27]
     | tbl_lq_exection_list_pt[28]);
assign dcache_dir_multi_lq =
    (tbl_lq_exection_list_pt[6]);
assign tlb_lru_par_lq =
    (tbl_lq_exection_list_pt[3]);
assign dcache_l2_ecc_lq =
    (tbl_lq_exection_list_pt[2]);
assign dcache_dir_par_lq =
    (tbl_lq_exection_list_pt[10]);
assign dcache_par_lq =
    (tbl_lq_exection_list_pt[7]);
assign derat_multi_lq =
    (tbl_lq_exection_list_pt[8]);
assign tlb_multi_lq =
    (tbl_lq_exection_list_pt[4]);
assign derat_par_lq =
    (tbl_lq_exection_list_pt[9]);
assign tlb_par_lq =
    (tbl_lq_exection_list_pt[5]);
assign lq_db_mask[0] =
    (tbl_lq_exection_list_pt[26]);
assign lq_db_mask[1] =
    (tbl_lq_exection_list_pt[26]);
assign lq_db_mask[2] =
    (tbl_lq_exection_list_pt[26]);
assign lq_db_mask[3] =
    (tbl_lq_exection_list_pt[11] | tbl_lq_exection_list_pt[12]
     | tbl_lq_exection_list_pt[13] | tbl_lq_exection_list_pt[14]
     | tbl_lq_exection_list_pt[15] | tbl_lq_exection_list_pt[16]
     | tbl_lq_exection_list_pt[17] | tbl_lq_exection_list_pt[18]
     | tbl_lq_exection_list_pt[19] | tbl_lq_exection_list_pt[20]
     | tbl_lq_exection_list_pt[21] | tbl_lq_exection_list_pt[22]
     | tbl_lq_exection_list_pt[23] | tbl_lq_exection_list_pt[24]
     | tbl_lq_exection_list_pt[25] | tbl_lq_exection_list_pt[26]
     | tbl_lq_exection_list_pt[27] | tbl_lq_exection_list_pt[28]
    );
assign lq_db_mask[4] =
    (tbl_lq_exection_list_pt[26]);
assign lq_db_mask[5] =
    (tbl_lq_exection_list_pt[2] | tbl_lq_exection_list_pt[3]
     | tbl_lq_exection_list_pt[4] | tbl_lq_exection_list_pt[5]
     | tbl_lq_exection_list_pt[6] | tbl_lq_exection_list_pt[7]
     | tbl_lq_exection_list_pt[8] | tbl_lq_exection_list_pt[9]
     | tbl_lq_exection_list_pt[10] | tbl_lq_exection_list_pt[11]
     | tbl_lq_exection_list_pt[12] | tbl_lq_exection_list_pt[13]
     | tbl_lq_exection_list_pt[14] | tbl_lq_exection_list_pt[15]
     | tbl_lq_exection_list_pt[16] | tbl_lq_exection_list_pt[17]
     | tbl_lq_exection_list_pt[18] | tbl_lq_exection_list_pt[19]
     | tbl_lq_exection_list_pt[20] | tbl_lq_exection_list_pt[21]
     | tbl_lq_exection_list_pt[22] | tbl_lq_exection_list_pt[23]
     | tbl_lq_exection_list_pt[24] | tbl_lq_exection_list_pt[25]
     | tbl_lq_exection_list_pt[26] | tbl_lq_exection_list_pt[27]
     | tbl_lq_exection_list_pt[28]);
assign lq_db_mask[6] =
    (tbl_lq_exection_list_pt[2] | tbl_lq_exection_list_pt[3]
     | tbl_lq_exection_list_pt[4] | tbl_lq_exection_list_pt[5]
     | tbl_lq_exection_list_pt[6] | tbl_lq_exection_list_pt[7]
     | tbl_lq_exection_list_pt[8] | tbl_lq_exection_list_pt[9]
     | tbl_lq_exection_list_pt[10] | tbl_lq_exection_list_pt[11]
     | tbl_lq_exection_list_pt[12] | tbl_lq_exection_list_pt[13]
     | tbl_lq_exection_list_pt[14] | tbl_lq_exection_list_pt[15]
     | tbl_lq_exection_list_pt[16] | tbl_lq_exection_list_pt[17]
     | tbl_lq_exection_list_pt[18] | tbl_lq_exection_list_pt[19]
     | tbl_lq_exection_list_pt[20] | tbl_lq_exection_list_pt[21]
     | tbl_lq_exection_list_pt[22] | tbl_lq_exection_list_pt[23]
     | tbl_lq_exection_list_pt[24] | tbl_lq_exection_list_pt[25]
     | tbl_lq_exection_list_pt[26] | tbl_lq_exection_list_pt[27]
     | tbl_lq_exection_list_pt[28]);
assign lq_db_mask[7] =
    (tbl_lq_exection_list_pt[2] | tbl_lq_exection_list_pt[3]
     | tbl_lq_exection_list_pt[4] | tbl_lq_exection_list_pt[5]
     | tbl_lq_exection_list_pt[6] | tbl_lq_exection_list_pt[7]
     | tbl_lq_exection_list_pt[8] | tbl_lq_exection_list_pt[9]
     | tbl_lq_exection_list_pt[10] | tbl_lq_exection_list_pt[11]
     | tbl_lq_exection_list_pt[12] | tbl_lq_exection_list_pt[13]
     | tbl_lq_exection_list_pt[14] | tbl_lq_exection_list_pt[15]
     | tbl_lq_exection_list_pt[16] | tbl_lq_exection_list_pt[17]
     | tbl_lq_exection_list_pt[18] | tbl_lq_exection_list_pt[19]
     | tbl_lq_exection_list_pt[20] | tbl_lq_exection_list_pt[21]
     | tbl_lq_exection_list_pt[22] | tbl_lq_exection_list_pt[23]
     | tbl_lq_exection_list_pt[24] | tbl_lq_exection_list_pt[25]
     | tbl_lq_exection_list_pt[26] | tbl_lq_exection_list_pt[27]
     | tbl_lq_exection_list_pt[28]);
assign lq_db_mask[8] =
    (tbl_lq_exection_list_pt[2] | tbl_lq_exection_list_pt[3]
     | tbl_lq_exection_list_pt[4] | tbl_lq_exection_list_pt[5]
     | tbl_lq_exection_list_pt[6] | tbl_lq_exection_list_pt[7]
     | tbl_lq_exection_list_pt[8] | tbl_lq_exection_list_pt[9]
     | tbl_lq_exection_list_pt[10] | tbl_lq_exection_list_pt[11]
     | tbl_lq_exection_list_pt[12] | tbl_lq_exection_list_pt[13]
     | tbl_lq_exection_list_pt[14] | tbl_lq_exection_list_pt[15]
     | tbl_lq_exection_list_pt[16] | tbl_lq_exection_list_pt[17]
     | tbl_lq_exection_list_pt[18] | tbl_lq_exection_list_pt[19]
     | tbl_lq_exection_list_pt[20] | tbl_lq_exection_list_pt[21]
     | tbl_lq_exection_list_pt[22] | tbl_lq_exection_list_pt[23]
     | tbl_lq_exection_list_pt[24] | tbl_lq_exection_list_pt[25]
     | tbl_lq_exection_list_pt[26] | tbl_lq_exection_list_pt[27]
     | tbl_lq_exection_list_pt[28]);
assign lq_db_mask[9] =
    (tbl_lq_exection_list_pt[26]);
assign lq_db_mask[10] =
    (tbl_lq_exection_list_pt[26]);
assign lq_db_mask[11] =
    (tbl_lq_exection_list_pt[26]);
assign lq_db_mask[12] =
    (tbl_lq_exection_list_pt[26]);
assign lq_db_mask[13] =
    (tbl_lq_exection_list_pt[26]);
assign lq_db_mask[14] =
    (tbl_lq_exection_list_pt[26]);
assign lq_db_mask[15] =
    (tbl_lq_exection_list_pt[26]);
assign lq_db_mask[16] =
    (tbl_lq_exection_list_pt[26]);
assign lq_db_mask[17] =
    (tbl_lq_exection_list_pt[26]);
assign lq_db_mask[18] =
    (tbl_lq_exection_list_pt[2] | tbl_lq_exection_list_pt[3]
     | tbl_lq_exection_list_pt[4] | tbl_lq_exection_list_pt[5]
     | tbl_lq_exection_list_pt[6] | tbl_lq_exection_list_pt[7]
     | tbl_lq_exection_list_pt[8] | tbl_lq_exection_list_pt[9]
     | tbl_lq_exection_list_pt[10] | tbl_lq_exection_list_pt[11]
     | tbl_lq_exection_list_pt[12] | tbl_lq_exection_list_pt[13]
     | tbl_lq_exection_list_pt[14] | tbl_lq_exection_list_pt[15]
     | tbl_lq_exection_list_pt[16] | tbl_lq_exection_list_pt[17]
     | tbl_lq_exection_list_pt[18] | tbl_lq_exection_list_pt[19]
     | tbl_lq_exection_list_pt[20] | tbl_lq_exection_list_pt[21]
     | tbl_lq_exection_list_pt[22] | tbl_lq_exection_list_pt[23]
     | tbl_lq_exection_list_pt[24] | tbl_lq_exection_list_pt[25]
     | tbl_lq_exection_list_pt[26] | tbl_lq_exection_list_pt[27]
     | tbl_lq_exection_list_pt[28]);

assign tbl_xu_exection_list_pt[1] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[1] , cp3_xu_excvec[2] ,
    cp3_xu_excvec[3] , cp3_xu_excvec[4]
     }) === 6'b110000);
assign tbl_xu_exection_list_pt[2] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[1] , cp3_xu_excvec[2] ,
    cp3_xu_excvec[3] , cp3_xu_excvec[4]
     }) === 6'b100011);
assign tbl_xu_exection_list_pt[3] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[1] , cp3_xu_excvec[2] ,
    cp3_xu_excvec[3] , cp3_xu_excvec[4]
     }) === 6'b100001);
assign tbl_xu_exection_list_pt[4] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[1] , cp3_xu_excvec[2] ,
    cp3_xu_excvec[4] }) === 5'b10101);
assign tbl_xu_exection_list_pt[5] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[1] , cp3_xu_excvec[2] ,
    cp3_xu_excvec[3] , cp3_xu_excvec[4]
     }) === 6'b100010);
assign tbl_xu_exection_list_pt[6] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[1] , cp3_xu_excvec[2] ,
    cp3_xu_excvec[3] , cp3_xu_excvec[4]
     }) === 6'b100111);
assign tbl_xu_exection_list_pt[7] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[1] , cp3_xu_excvec[2] ,
    cp3_xu_excvec[3] , cp3_xu_excvec[4]
     }) === 6'b100000);
assign tbl_xu_exection_list_pt[8] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[1] , cp3_xu_excvec[2] ,
    cp3_xu_excvec[3] , cp3_xu_excvec[4]
     }) === 6'b101010);
assign tbl_xu_exection_list_pt[9] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[1] , cp3_xu_excvec[2] ,
    cp3_xu_excvec[3] , cp3_xu_excvec[4]
     }) === 6'b101111);
assign tbl_xu_exection_list_pt[10] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[2] , cp3_xu_excvec[3] ,
    cp3_xu_excvec[4] }) === 5'b10101);
assign tbl_xu_exection_list_pt[11] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[1] , cp3_xu_excvec[2] ,
    cp3_xu_excvec[3] , cp3_xu_excvec[4]
     }) === 6'b100110);
assign tbl_xu_exection_list_pt[12] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[1] , cp3_xu_excvec[2] ,
    cp3_xu_excvec[3] , cp3_xu_excvec[4]
     }) === 6'b101000);
assign tbl_xu_exection_list_pt[13] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[1] , cp3_xu_excvec[2] ,
    cp3_xu_excvec[3] , cp3_xu_excvec[4]
     }) === 6'b100100);
assign tbl_xu_exection_list_pt[14] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[1] , cp3_xu_excvec[2] ,
    cp3_xu_excvec[3] , cp3_xu_excvec[4]
     }) === 6'b101110);
assign tbl_xu_exection_list_pt[15] =
    (({ cp3_xu_excvec_val , cp3_xu_excvec[0] ,
    cp3_xu_excvec[1] , cp3_xu_excvec[2] ,
    cp3_xu_excvec[3] , cp3_xu_excvec[4]
     }) === 6'b101100);
assign tbl_xu_exection_list_pt[16] =
    (({ cp3_xu_excvec_val }) === 1'b0);
assign mcheck_xu =
    (tbl_xu_exection_list_pt[1] | tbl_xu_exection_list_pt[2]
     | tbl_xu_exection_list_pt[3] | tbl_xu_exection_list_pt[5]
     | tbl_xu_exection_list_pt[7] | tbl_xu_exection_list_pt[13]
    );
assign program_xu =
    (tbl_xu_exection_list_pt[6] | tbl_xu_exection_list_pt[10]
     | tbl_xu_exection_list_pt[11] | tbl_xu_exection_list_pt[12]
     | tbl_xu_exection_list_pt[14]);
assign cp3_icmp_excep =
    (tbl_xu_exection_list_pt[8]);
assign hyp_priv_xu =
    (tbl_xu_exection_list_pt[4] | tbl_xu_exection_list_pt[8]
    );
assign data_storage_xu =
    1'b0;
assign tlb_xu =
    (tbl_xu_exection_list_pt[15]);
assign lrat_xu =
    (tbl_xu_exection_list_pt[9]);
assign fp_xu =
    (tbl_xu_exection_list_pt[9] | tbl_xu_exection_list_pt[15]
    );
assign st_xu =
    (tbl_xu_exection_list_pt[9] | tbl_xu_exection_list_pt[15]
    );
assign dlk_xu[0] =
    1'b0;
assign dlk_xu[1] =
    1'b0;
assign ap_xu =
    (tbl_xu_exection_list_pt[9] | tbl_xu_exection_list_pt[15]
    );
assign bo_xu =
    1'b0;
assign tlbi_xu =
    1'b0;
assign pt_xu =
    1'b0;
assign spv_xu =
    (tbl_xu_exection_list_pt[9] | tbl_xu_exection_list_pt[15]
    );
assign epid_xu =
    (tbl_xu_exection_list_pt[9] | tbl_xu_exection_list_pt[15]
    );
assign pil_xu =
    (tbl_xu_exection_list_pt[10] | tbl_xu_exection_list_pt[11]
    );
assign ppr_xu =
    (tbl_xu_exection_list_pt[6] | tbl_xu_exection_list_pt[12]
    );
assign ptr_xu =
    (tbl_xu_exection_list_pt[14]);
assign puo_xu =
    1'b0;
assign pie_xu =
    1'b0;
assign uct_xu =
    1'b0;
assign data_xu =
    1'b0;
assign esr_xu =
    (tbl_xu_exection_list_pt[6] | tbl_xu_exection_list_pt[9]
     | tbl_xu_exection_list_pt[10] | tbl_xu_exection_list_pt[11]
     | tbl_xu_exection_list_pt[12] | tbl_xu_exection_list_pt[14]
     | tbl_xu_exection_list_pt[15]);
assign tlb_lru_par_xu =
    (tbl_xu_exection_list_pt[3]);
assign tlb_multi_xu =
    (tbl_xu_exection_list_pt[5]);
assign ierat_par_xu =
    (tbl_xu_exection_list_pt[2]);
assign derat_par_xu =
    (tbl_xu_exection_list_pt[13]);
assign tlb_par_xu =
    (tbl_xu_exection_list_pt[7]);
assign tlb_snoop_rej_async =
    (tbl_xu_exection_list_pt[1]);
assign xu_db_mask[0] =
    (tbl_xu_exection_list_pt[16]);
assign xu_db_mask[1] =
    (tbl_xu_exection_list_pt[16]);
assign xu_db_mask[2] =
    (tbl_xu_exection_list_pt[16]);
assign xu_db_mask[3] =
    (tbl_xu_exection_list_pt[1] | tbl_xu_exection_list_pt[4]
     | tbl_xu_exection_list_pt[6] | tbl_xu_exection_list_pt[8]
     | tbl_xu_exection_list_pt[9] | tbl_xu_exection_list_pt[10]
     | tbl_xu_exection_list_pt[11] | tbl_xu_exection_list_pt[12]
     | tbl_xu_exection_list_pt[14] | tbl_xu_exection_list_pt[15]
     | tbl_xu_exection_list_pt[16]);
assign xu_db_mask[4] =
    (tbl_xu_exection_list_pt[14] | tbl_xu_exection_list_pt[16]
    );
assign xu_db_mask[5] =
    (tbl_xu_exection_list_pt[1] | tbl_xu_exection_list_pt[2]
     | tbl_xu_exection_list_pt[3] | tbl_xu_exection_list_pt[4]
     | tbl_xu_exection_list_pt[5] | tbl_xu_exection_list_pt[6]
     | tbl_xu_exection_list_pt[7] | tbl_xu_exection_list_pt[8]
     | tbl_xu_exection_list_pt[9] | tbl_xu_exection_list_pt[10]
     | tbl_xu_exection_list_pt[11] | tbl_xu_exection_list_pt[12]
     | tbl_xu_exection_list_pt[13] | tbl_xu_exection_list_pt[14]
     | tbl_xu_exection_list_pt[15] | tbl_xu_exection_list_pt[16]
    );
assign xu_db_mask[6] =
    (tbl_xu_exection_list_pt[1] | tbl_xu_exection_list_pt[2]
     | tbl_xu_exection_list_pt[3] | tbl_xu_exection_list_pt[4]
     | tbl_xu_exection_list_pt[5] | tbl_xu_exection_list_pt[6]
     | tbl_xu_exection_list_pt[7] | tbl_xu_exection_list_pt[8]
     | tbl_xu_exection_list_pt[9] | tbl_xu_exection_list_pt[10]
     | tbl_xu_exection_list_pt[11] | tbl_xu_exection_list_pt[12]
     | tbl_xu_exection_list_pt[13] | tbl_xu_exection_list_pt[14]
     | tbl_xu_exection_list_pt[15] | tbl_xu_exection_list_pt[16]
    );
assign xu_db_mask[7] =
    (tbl_xu_exection_list_pt[1] | tbl_xu_exection_list_pt[2]
     | tbl_xu_exection_list_pt[3] | tbl_xu_exection_list_pt[4]
     | tbl_xu_exection_list_pt[5] | tbl_xu_exection_list_pt[6]
     | tbl_xu_exection_list_pt[7] | tbl_xu_exection_list_pt[8]
     | tbl_xu_exection_list_pt[9] | tbl_xu_exection_list_pt[10]
     | tbl_xu_exection_list_pt[11] | tbl_xu_exection_list_pt[12]
     | tbl_xu_exection_list_pt[13] | tbl_xu_exection_list_pt[14]
     | tbl_xu_exection_list_pt[15] | tbl_xu_exection_list_pt[16]
    );
assign xu_db_mask[8] =
    (tbl_xu_exection_list_pt[1] | tbl_xu_exection_list_pt[2]
     | tbl_xu_exection_list_pt[3] | tbl_xu_exection_list_pt[4]
     | tbl_xu_exection_list_pt[5] | tbl_xu_exection_list_pt[6]
     | tbl_xu_exection_list_pt[7] | tbl_xu_exection_list_pt[8]
     | tbl_xu_exection_list_pt[9] | tbl_xu_exection_list_pt[10]
     | tbl_xu_exection_list_pt[11] | tbl_xu_exection_list_pt[12]
     | tbl_xu_exection_list_pt[13] | tbl_xu_exection_list_pt[14]
     | tbl_xu_exection_list_pt[15] | tbl_xu_exection_list_pt[16]
    );
assign xu_db_mask[9] =
    (tbl_xu_exection_list_pt[8] | tbl_xu_exection_list_pt[16]
    );
assign xu_db_mask[10] =
    (tbl_xu_exection_list_pt[16]);
assign xu_db_mask[11] =
    (tbl_xu_exection_list_pt[16]);
assign xu_db_mask[12] =
    (tbl_xu_exection_list_pt[16]);
assign xu_db_mask[13] =
    (tbl_xu_exection_list_pt[16]);
assign xu_db_mask[14] =
    (tbl_xu_exection_list_pt[16]);
assign xu_db_mask[15] =
    (tbl_xu_exection_list_pt[16]);
assign xu_db_mask[16] =
    (tbl_xu_exection_list_pt[16]);
assign xu_db_mask[17] =
    (tbl_xu_exection_list_pt[16]);
assign xu_db_mask[18] =
    (tbl_xu_exection_list_pt[1] | tbl_xu_exection_list_pt[2]
     | tbl_xu_exection_list_pt[3] | tbl_xu_exection_list_pt[4]
     | tbl_xu_exection_list_pt[5] | tbl_xu_exection_list_pt[6]
     | tbl_xu_exection_list_pt[7] | tbl_xu_exection_list_pt[8]
     | tbl_xu_exection_list_pt[9] | tbl_xu_exection_list_pt[10]
     | tbl_xu_exection_list_pt[11] | tbl_xu_exection_list_pt[12]
     | tbl_xu_exection_list_pt[13] | tbl_xu_exection_list_pt[14]
     | tbl_xu_exection_list_pt[15] | tbl_xu_exection_list_pt[16]
    );

assign tbl_axu_exection_list_pt[1] =
    (({ cp3_axu_excvec_val , cp3_axu_excvec[0] ,
    cp3_axu_excvec[1] , cp3_axu_excvec[2] ,
    cp3_axu_excvec[3] }) === 5'b10010);
assign tbl_axu_exection_list_pt[2] =
    (({ cp3_axu_excvec_val , cp3_axu_excvec[0] ,
    cp3_axu_excvec[1] , cp3_axu_excvec[2] ,
    cp3_axu_excvec[3] }) === 5'b10011);
assign tbl_axu_exection_list_pt[3] =
    (({ cp3_axu_excvec_val , cp3_axu_excvec[0] ,
    cp3_axu_excvec[1] , cp3_axu_excvec[2]
     }) === 4'b1010);
assign tbl_axu_exection_list_pt[4] =
    (({ cp3_axu_excvec_val , cp3_axu_excvec[0] ,
    cp3_axu_excvec[1] , cp3_axu_excvec[2] ,
    cp3_axu_excvec[3] }) === 5'b10000);
assign tbl_axu_exection_list_pt[5] =
    (({ cp3_axu_excvec_val , cp3_axu_excvec[0] ,
    cp3_axu_excvec[1] , cp3_axu_excvec[2] ,
    cp3_axu_excvec[3] }) === 5'b10001);
assign tbl_axu_exection_list_pt[6] =
    (({ cp3_axu_excvec_val }) === 1'b0);
assign ap_unavailable_axu =
    (tbl_axu_exection_list_pt[4]);
assign fp_unavailable_axu =
    (tbl_axu_exection_list_pt[5]);
assign vec_unavailable_axu =
    (tbl_axu_exection_list_pt[1]);
assign program_fp_axu =
    (tbl_axu_exection_list_pt[3]);
assign program_ap_axu =
    (tbl_axu_exection_list_pt[2]);
assign fp_axu =
    (tbl_axu_exection_list_pt[3]);
assign st_axu =
    1'b0;
assign dlk_axu[0] =
    1'b0;
assign dlk_axu[1] =
    1'b0;
assign ap_axu =
    (tbl_axu_exection_list_pt[2]);
assign bo_axu =
    1'b0;
assign tlbi_axu =
    1'b0;
assign pt_axu =
    1'b0;
assign spv_axu =
    1'b0;
assign epid_axu =
    1'b0;
assign pil_axu =
    1'b0;
assign ppr_axu =
    1'b0;
assign ptr_axu =
    1'b0;
assign puo_axu =
    1'b0;
assign pie_axu =
    1'b0;
assign uct_axu =
    1'b0;
assign data_axu =
    1'b0;
assign esr_axu =
    (tbl_axu_exection_list_pt[3]);
assign axu_db_mask[0] =
    (tbl_axu_exection_list_pt[6]);
assign axu_db_mask[1] =
    (tbl_axu_exection_list_pt[6]);
assign axu_db_mask[2] =
    (tbl_axu_exection_list_pt[6]);
assign axu_db_mask[3] =
    (tbl_axu_exection_list_pt[1] | tbl_axu_exection_list_pt[2]
     | tbl_axu_exection_list_pt[3] | tbl_axu_exection_list_pt[4]
     | tbl_axu_exection_list_pt[5] | tbl_axu_exection_list_pt[6]
    );
assign axu_db_mask[4] =
    (tbl_axu_exection_list_pt[6]);
assign axu_db_mask[5] =
    (tbl_axu_exection_list_pt[1] | tbl_axu_exection_list_pt[2]
     | tbl_axu_exection_list_pt[3] | tbl_axu_exection_list_pt[4]
     | tbl_axu_exection_list_pt[5] | tbl_axu_exection_list_pt[6]
    );
assign axu_db_mask[6] =
    (tbl_axu_exection_list_pt[1] | tbl_axu_exection_list_pt[2]
     | tbl_axu_exection_list_pt[3] | tbl_axu_exection_list_pt[4]
     | tbl_axu_exection_list_pt[5] | tbl_axu_exection_list_pt[6]
    );
assign axu_db_mask[7] =
    (tbl_axu_exection_list_pt[1] | tbl_axu_exection_list_pt[2]
     | tbl_axu_exection_list_pt[3] | tbl_axu_exection_list_pt[4]
     | tbl_axu_exection_list_pt[5] | tbl_axu_exection_list_pt[6]
    );
assign axu_db_mask[8] =
    (tbl_axu_exection_list_pt[1] | tbl_axu_exection_list_pt[2]
     | tbl_axu_exection_list_pt[3] | tbl_axu_exection_list_pt[4]
     | tbl_axu_exection_list_pt[5] | tbl_axu_exection_list_pt[6]
    );
assign axu_db_mask[9] =
    (tbl_axu_exection_list_pt[6]);
assign axu_db_mask[10] =
    (tbl_axu_exection_list_pt[6]);
assign axu_db_mask[11] =
    (tbl_axu_exection_list_pt[6]);
assign axu_db_mask[12] =
    (tbl_axu_exection_list_pt[6]);
assign axu_db_mask[13] =
    (tbl_axu_exection_list_pt[6]);
assign axu_db_mask[14] =
    (tbl_axu_exection_list_pt[6]);
assign axu_db_mask[15] =
    (tbl_axu_exection_list_pt[6]);
assign axu_db_mask[16] =
    (tbl_axu_exection_list_pt[6]);
assign axu_db_mask[17] =
    (tbl_axu_exection_list_pt[6]);
assign axu_db_mask[18] =
    (tbl_axu_exection_list_pt[1] | tbl_axu_exection_list_pt[2]
     | tbl_axu_exection_list_pt[3] | tbl_axu_exection_list_pt[4]
     | tbl_axu_exection_list_pt[5] | tbl_axu_exection_list_pt[6]
    );

assign tbl_async_exection_list_pt[1] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] , cp3_async_int[18] ,
    cp3_async_int[19] , cp3_async_int[20] ,
    cp3_async_int[21] , cp3_async_int[22] ,
    cp3_async_int[23] , cp3_async_int[24] ,
    cp3_async_int[25] , cp3_async_int[26] ,
    cp3_async_int[27] , cp3_async_int[28] ,
    cp3_async_int[29] , cp3_async_int[30] ,
    cp3_async_int[31] }) === 33'b100000000000000000000000000000001);
assign tbl_async_exection_list_pt[2] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] , cp3_async_int[18] ,
    cp3_async_int[19] , cp3_async_int[20] ,
    cp3_async_int[21] , cp3_async_int[22] ,
    cp3_async_int[23] , cp3_async_int[24] ,
    cp3_async_int[25] , cp3_async_int[26] ,
    cp3_async_int[27] , cp3_async_int[28] ,
    cp3_async_int[29] , cp3_async_int[30]
     }) === 32'b10000000000000000000000000000001);
assign tbl_async_exection_list_pt[3] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] , cp3_async_int[18] ,
    cp3_async_int[19] , cp3_async_int[20] ,
    cp3_async_int[21] , cp3_async_int[22] ,
    cp3_async_int[23] , cp3_async_int[24] ,
    cp3_async_int[25] , cp3_async_int[26] ,
    cp3_async_int[27] , cp3_async_int[28] ,
    cp3_async_int[29] }) === 31'b1000000000000000000000000000001);
assign tbl_async_exection_list_pt[4] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] , cp3_async_int[18] ,
    cp3_async_int[19] , cp3_async_int[20] ,
    cp3_async_int[21] , cp3_async_int[22] ,
    cp3_async_int[23] , cp3_async_int[24] ,
    cp3_async_int[25] , cp3_async_int[26] ,
    cp3_async_int[27] , cp3_async_int[28]
     }) === 30'b100000000000000000000000000001);
assign tbl_async_exection_list_pt[5] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] , cp3_async_int[18] ,
    cp3_async_int[19] , cp3_async_int[20] ,
    cp3_async_int[21] , cp3_async_int[22] ,
    cp3_async_int[23] , cp3_async_int[24] ,
    cp3_async_int[25] , cp3_async_int[26] ,
    cp3_async_int[27] }) === 29'b10000000000000000000000000001);
assign tbl_async_exection_list_pt[6] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] , cp3_async_int[18] ,
    cp3_async_int[19] , cp3_async_int[20] ,
    cp3_async_int[21] , cp3_async_int[22] ,
    cp3_async_int[23] , cp3_async_int[24] ,
    cp3_async_int[25] , cp3_async_int[26]
     }) === 28'b1000000000000000000000000001);
assign tbl_async_exection_list_pt[7] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] , cp3_async_int[18] ,
    cp3_async_int[19] , cp3_async_int[20] ,
    cp3_async_int[21] , cp3_async_int[22] ,
    cp3_async_int[23] , cp3_async_int[24] ,
    cp3_async_int[25] }) === 27'b100000000000000000000000001);
assign tbl_async_exection_list_pt[8] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] , cp3_async_int[18] ,
    cp3_async_int[19] , cp3_async_int[20] ,
    cp3_async_int[21] , cp3_async_int[22] ,
    cp3_async_int[23] , cp3_async_int[24]
     }) === 26'b10000000000000000000000001);
assign tbl_async_exection_list_pt[9] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] , cp3_async_int[18] ,
    cp3_async_int[19] , cp3_async_int[20] ,
    cp3_async_int[21] , cp3_async_int[22] ,
    cp3_async_int[23] }) === 25'b1000000000000000000000001);
assign tbl_async_exection_list_pt[10] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] , cp3_async_int[18] ,
    cp3_async_int[19] , cp3_async_int[20] ,
    cp3_async_int[21] , cp3_async_int[22]
     }) === 24'b100000000000000000000001);
assign tbl_async_exection_list_pt[11] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] , cp3_async_int[18] ,
    cp3_async_int[19] , cp3_async_int[20] ,
    cp3_async_int[21] }) === 23'b10000000000000000000001);
assign tbl_async_exection_list_pt[12] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] , cp3_async_int[18] ,
    cp3_async_int[19] , cp3_async_int[20]
     }) === 22'b1000000000000000000001);
assign tbl_async_exection_list_pt[13] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] , cp3_async_int[18] ,
    cp3_async_int[19] }) === 21'b100000000000000000001);
assign tbl_async_exection_list_pt[14] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] , cp3_async_int[18]
     }) === 20'b10000000000000000001);
assign tbl_async_exection_list_pt[15] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16] ,
    cp3_async_int[17] }) === 19'b1000000000000000001);
assign tbl_async_exection_list_pt[16] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] , cp3_async_int[16]
     }) === 18'b100000000000000001);
assign tbl_async_exection_list_pt[17] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14] ,
    cp3_async_int[15] }) === 17'b10000000000000001);
assign tbl_async_exection_list_pt[18] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] , cp3_async_int[14]
     }) === 16'b1000000000000001);
assign tbl_async_exection_list_pt[19] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12]
     }) === 14'b10000000000001);
assign tbl_async_exection_list_pt[20] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] }) === 13'b1000000000001);
assign tbl_async_exection_list_pt[21] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[9] , cp3_async_int[10] ,
    cp3_async_int[11] , cp3_async_int[12] ,
    cp3_async_int[13] }) === 13'b1000000000001);
assign tbl_async_exection_list_pt[22] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] , cp3_async_int[10]
     }) === 12'b100000000001);
assign tbl_async_exection_list_pt[23] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8] ,
    cp3_async_int[9] }) === 11'b10000000001);
assign tbl_async_exection_list_pt[24] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] , cp3_async_int[8]
     }) === 10'b1000000001);
assign tbl_async_exection_list_pt[25] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , dis_mm_mchk
     }) === 6'b100011);
assign tbl_async_exection_list_pt[26] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , dis_mm_mchk
     }) === 6'b100010);
assign tbl_async_exection_list_pt[27] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    dis_mm_mchk }) === 5'b10011);
assign tbl_async_exection_list_pt[28] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    dis_mm_mchk }) === 5'b10010);
assign tbl_async_exection_list_pt[29] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6] ,
    cp3_async_int[7] }) === 9'b100000001);
assign tbl_async_exection_list_pt[30] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , dis_mm_mchk
     }) === 4'b1011);
assign tbl_async_exection_list_pt[31] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , dis_mm_mchk
     }) === 4'b1010);
assign tbl_async_exection_list_pt[32] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] , cp3_async_int[6]
     }) === 8'b10000001);
assign tbl_async_exection_list_pt[33] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4] ,
    cp3_async_int[5] }) === 7'b1000001);
assign tbl_async_exection_list_pt[34] =
    (({ cp3_async_int_val , cp3_async_int[0] ,
    cp3_async_int[1] , cp3_async_int[2] ,
    cp3_async_int[3] , cp3_async_int[4]
     }) === 6'b100001);
assign tbl_async_exection_list_pt[35] =
    (({ cp3_async_int_val , cp3_async_int[0]
     }) === 2'b11);
assign instr_tlb_async =
    (tbl_async_exection_list_pt[35]);
assign pt_fault_async =
    (tbl_async_exection_list_pt[34]);
assign lrat_miss_async =
    (tbl_async_exection_list_pt[32]);
assign tlb_inelig_async =
    (tbl_async_exection_list_pt[33]);
assign tlb_multi_async =
    (tbl_async_exection_list_pt[25] | tbl_async_exection_list_pt[26]
    );
assign tlb_par_async =
    (tbl_async_exection_list_pt[27] | tbl_async_exection_list_pt[28]
    );
assign tlb_lru_par_async =
    (tbl_async_exection_list_pt[30] | tbl_async_exection_list_pt[31]
    );
assign debug_icmp =
    (tbl_async_exection_list_pt[29]);
assign debug_irpt =
    (tbl_async_exection_list_pt[24]);
assign debug_async =
    (tbl_async_exection_list_pt[15] | tbl_async_exection_list_pt[21]
     | tbl_async_exection_list_pt[24] | tbl_async_exection_list_pt[29]
    );
assign mchk_ext_async =
    (tbl_async_exection_list_pt[17]);
assign program_fp_en_async =
    (tbl_async_exection_list_pt[18]);
assign guest_dbell_mchk_async =
    (tbl_async_exection_list_pt[16]);
assign perf_async =
    (tbl_async_exection_list_pt[1]);
assign ude_input_async =
    (tbl_async_exection_list_pt[15]);
assign crit_input_async =
    (tbl_async_exection_list_pt[14]);
assign wdog_async =
    (tbl_async_exection_list_pt[13]);
assign guest_wdog_async =
    (tbl_async_exection_list_pt[12]);
assign dbell_crit_async =
    (tbl_async_exection_list_pt[11]);
assign guest_dbell_crit_async =
    (tbl_async_exection_list_pt[10]);
assign external_async =
    (tbl_async_exection_list_pt[9]);
assign fit_async =
    (tbl_async_exection_list_pt[8]);
assign guest_fit_async =
    (tbl_async_exection_list_pt[7]);
assign dec_async =
    (tbl_async_exection_list_pt[6]);
assign guest_dec_async =
    (tbl_async_exection_list_pt[5]);
assign dbell_async =
    (tbl_async_exection_list_pt[4]);
assign guest_dbell_async =
    (tbl_async_exection_list_pt[3]);
assign user_dec_async =
    (tbl_async_exection_list_pt[2]);
assign dp_cp_async =
    (tbl_async_exection_list_pt[23]);
assign dp_cp_async_bus_snoop =
    (tbl_async_exection_list_pt[22]);
assign async_np1 =
    (tbl_async_exection_list_pt[20]);
assign pc_stop =
    (tbl_async_exection_list_pt[19]);
assign async_n =
    (tbl_async_exection_list_pt[19] | tbl_async_exection_list_pt[25]
     | tbl_async_exection_list_pt[27] | tbl_async_exection_list_pt[30]
    );
assign fp_async =
    (tbl_async_exection_list_pt[18]);
assign st_async =
    1'b0;
assign dlk_async[0] =
    1'b0;
assign dlk_async[1] =
    1'b0;
assign ap_async =
    1'b0;
assign bo_async =
    1'b0;
assign tlbi_async =
    (tbl_async_exection_list_pt[33]);
assign pt_async =
    (tbl_async_exection_list_pt[32] | tbl_async_exection_list_pt[34]
    );
assign spv_async =
    1'b0;
assign epid_async =
    1'b0;
assign pil_async =
    1'b0;
assign ppr_async =
    1'b0;
assign ptr_async =
    1'b0;
assign puo_async =
    1'b0;
assign pie_async =
    (tbl_async_exection_list_pt[18]);
assign uct_async =
    1'b0;
assign data_async =
    1'b0;
assign esr_async =
    (tbl_async_exection_list_pt[18] | tbl_async_exection_list_pt[32]
     | tbl_async_exection_list_pt[33] | tbl_async_exection_list_pt[34]
    );
assign crit_async =
    (tbl_async_exection_list_pt[10] | tbl_async_exection_list_pt[11]
     | tbl_async_exection_list_pt[12] | tbl_async_exection_list_pt[13]
     | tbl_async_exection_list_pt[14] | tbl_async_exection_list_pt[15]
     | tbl_async_exection_list_pt[16] | tbl_async_exection_list_pt[21]
     | tbl_async_exection_list_pt[24] | tbl_async_exection_list_pt[29]
    );
assign mcheck_async =
    (tbl_async_exection_list_pt[17] | tbl_async_exection_list_pt[26]
     | tbl_async_exection_list_pt[28] | tbl_async_exection_list_pt[31]
    );
assign guest_async =
    (tbl_async_exection_list_pt[5] | tbl_async_exection_list_pt[7]
    );
assign irpt_taken_async =
    (tbl_async_exection_list_pt[1] | tbl_async_exection_list_pt[2]
     | tbl_async_exection_list_pt[3] | tbl_async_exection_list_pt[4]
     | tbl_async_exection_list_pt[5] | tbl_async_exection_list_pt[6]
     | tbl_async_exection_list_pt[7] | tbl_async_exection_list_pt[8]
     | tbl_async_exection_list_pt[9] | tbl_async_exection_list_pt[18]
     | tbl_async_exection_list_pt[32] | tbl_async_exection_list_pt[33]
     | tbl_async_exection_list_pt[34] | tbl_async_exection_list_pt[35]
    );

//assign_end


   assign select_i0_p1 = i0_p1 & ((~(i0_check_next)) | (~(i1_comp)));
   assign select_i1_p1 = i1_p1 & i0_check_next;
   assign select_i0_bta = i0_bta & ((~(i0_check_next)) | (~(i1_comp)));
   assign select_i1_bta = i1_bta & i0_check_next;
   assign select_i0_bp_bta = i0_bp_bta & ((~(i0_check_next)) | (~(i1_comp)));
   assign select_i1_bp_bta = i1_bp_bta & i0_check_next;
   assign select_ucode_p1 = (i0_ucode_p1 & ((~(i0_check_next)) | (~(i1_comp)))) | (i1_ucode_p1 & i0_check_next);
   assign select_reset = (i0_reset & ((~(i0_check_next)) | (~(i1_comp)))) | (i1_reset & i0_check_next);
   assign select_mtiar = (i0_complete & i0_mtiar) | (i1_complete & i1_mtiar & i0_check_next);
   // Temp
   assign iu_pc_i0_comp = i0_comp;
   assign iu_pc_i1_comp = i1_comp & i0_check_next;

   assign db_mask = ({19{~(cp3_async_int_val | cp3_iu_excvec_val | cp3_lq_excvec_val | cp3_xu_excvec_val | cp3_axu_excvec_val)}} & {19{1'b1}}) |
                    ({19{cp3_iu_excvec_val}} & iu_db_mask) |
                    ({19{cp3_lq_excvec_val}} & lq_db_mask) |
                    ({19{cp3_xu_excvec_val}} & xu_db_mask) |
                    ({19{cp3_axu_excvec_val}} & axu_db_mask);

   generate
     begin : xhdl0
       genvar i;
       for (i = 0; i <= (19 - 1); i = i + 1)
       begin : cp3_db_mask
         if (i == 1)
         begin : R0
           assign cp3_db_events_masked[i] = db_mask[i] & cp3_db_events[i] & ~(cp3_rfi | cp3_attn);
         end
         if (i == 3)
         begin : R1
           assign cp3_db_events_masked[i] = 1'b0;
         end
         if ((i != 1) & (i != 3))
         begin : R2
           assign cp3_db_events_masked[i] = db_mask[i] & cp3_db_events[i];
         end
       end
     end
   endgenerate

   assign cp3_db_int_events_val = dbg_int_en & cp3_db_val & |{cp3_db_events_masked[0],(cp3_db_events_masked[1] & ~cp3_icmp_block),cp3_db_events_masked[2:18]};
   assign cp3_db_events_masked_reduced = cp3_db_int_events_val;
   assign cp3_asyn_irpt_needed = (dbg_int_en & cp3_db_val & cp3_db_events[3] & db_mask[3] & ~cp3_db_events_masked[4]) | (dbg_int_en & irpt_enable & irpt_taken_async);
   assign cp3_asyn_irpt_taken = debug_irpt;
   assign cp3_asyn_icmp_needed = dbg_int_en & cp3_db_val & cp3_db_events[1] & (cp3_rfi | cp3_attn);
   assign cp3_asyn_icmp_taken = debug_icmp;
   assign debug_irpt_int_dis = (((db_mask[3] & cp3_db_events[3] & (~(dbg_int_en))) | (~dbg_int_en & irpt_enable & irpt_taken_async)) &  (~(epcr_duvd & ~guest_int)) );
   assign debug_icmp_excep = dbg_int_en & icmp_enable & cp3_db_val & cp3_icmp_excep & (~(cp3_db_int_events_val));
   assign dbsr_update = |(cp3_db_events_masked) |
                        debug_icmp |
                        debug_irpt |
                        debug_irpt_int_dis |
                        debug_icmp_excep |
                        ude_input_async;

   assign cp3_dbsr = ({19{~(debug_icmp | debug_irpt)}} & cp3_db_events_masked) |
                     ({19{debug_icmp}} & 19'b0100000000000000000) |
                     ({19{debug_irpt | debug_irpt_int_dis}} & 19'b0001000000000000000) |
                     ({19{debug_icmp_excep}} & 19'b0100000000000000000) |
                     ({19{ude_input_async}} & 19'b1000000000000000000);

   assign dear_update = (~(cp3_db_int_events_val)) & (lrat_lq | data_tlb_lq | data_storage_lq | data_storage_hv_lq | data_storage_xu | alignment_lq);
   assign esr_update = (~(cp3_db_int_events_val)) & (esr_iu | esr_lq | esr_xu | esr_axu | esr_async);
   assign cp3_exc_nia[62 - `EFF_IFAR_ARCH:51] = ((~guest_int) ? ({({32{epcr_icm}} & spr_ivpr[0:31]), spr_ivpr[32:51]}) : 0) |
                                               ((guest_int | guest_wdog_async) ? ({({32{epcr_gicm}} & spr_givpr[0:31]), spr_givpr[32:51]}) : 0);

   assign cp3_exc_nia[52:61] = ((~(cp3_db_int_events_val) & (mcheck_iu | mcheck_lq | mcheck_xu | mcheck_async)) ? 10'b0000000000 : 10'b0000000000) |
                               (cp3_db_int_events_val ? 10'b0000010000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & (instr_tlb_async | instruction_tlb_iu)) ? 10'b0001111000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & (instruction_storage_iu | pt_fault_async | tlb_inelig_async)) ? 10'b0000100000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & instruction_storage_hv_iu) ? 10'b0000100000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & system_call_iu) ? 10'b0001001000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & system_call_hyp_iu) ? 10'b0011000000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & (lrat_lq | lrat_xu | lrat_miss_async)) ? 10'b0011010000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & (fp_unavailable_lq | fp_unavailable_axu)) ? 10'b0001000000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & (ap_unavailable_lq | ap_unavailable_axu)) ? 10'b0001010000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & (vec_unavailable_lq | vec_unavailable_axu)) ? 10'b0010000000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & (program_iu | program_lq | program_xu | program_fp_axu | program_ap_axu)) ? 10'b0000111000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & (data_tlb_lq | tlb_xu)) ? 10'b0001110000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & (data_storage_lq | data_storage_xu)) ? 10'b0000011000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & data_storage_hv_lq) ? 10'b0000011000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & alignment_lq) ? 10'b0000110000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & (hyp_priv_iu | hyp_priv_lq | hyp_priv_xu)) ? 10'b0011001000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & program_fp_en_async) ? 10'b0000111000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & guest_dbell_mchk_async) ? 10'b0010111000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & debug_async) ? 10'b0000010000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & perf_async) ? 10'b1000001000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & crit_input_async) ? 10'b0000001000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & (wdog_async | guest_wdog_async)) ? 10'b0001101000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & dbell_crit_async) ? 10'b0010101000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & guest_dbell_crit_async) ? 10'b0010111000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & external_async) ? 10'b0000101000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & (fit_async | guest_fit_async)) ? 10'b0001100000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & (dec_async | guest_dec_async)) ? 10'b0001011000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & dbell_async) ? 10'b0010100000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & guest_dbell_async) ? 10'b0010110000 : 10'b0000000000) |
                               ((~(cp3_db_int_events_val) & user_dec_async) ? 10'b1000000000 : 10'b0000000000);

   assign cp3_exc_esr[0] = (~(cp3_db_int_events_val)) & (pil_iu | pil_lq | pil_xu | pil_axu | pil_async);
   assign cp3_exc_esr[1] = (~(cp3_db_int_events_val)) & (ppr_iu | ppr_lq | ppr_xu | ppr_axu | ppr_async);
   assign cp3_exc_esr[2] = (~(cp3_db_int_events_val)) & (ptr_iu | ptr_lq | ptr_xu | ptr_axu | ptr_async);
   assign cp3_exc_esr[3] = (~(cp3_db_int_events_val)) & (((fp_iu | fp_lq | fp_xu | fp_axu) & cp3_fp) | fp_async);
   assign cp3_exc_esr[4] = (~(cp3_db_int_events_val)) & ((st_iu | st_lq | st_xu | st_axu | st_async) & cp3_st);
   assign cp3_exc_esr[5:6] = ({2{~cp3_db_int_events_val}} & (dlk_iu | dlk_lq | dlk_xu | dlk_axu | dlk_async));
   assign cp3_exc_esr[7] = (~(cp3_db_int_events_val)) & ((ap_iu | ap_lq | ap_xu | ap_axu | ap_async) & cp3_ap);
   assign cp3_exc_esr[8] = (~(cp3_db_int_events_val)) & (puo_iu | puo_lq | puo_xu | puo_axu | puo_async);
   assign cp3_exc_esr[9] = (~(cp3_db_int_events_val)) & (bo_iu | bo_lq | bo_xu | bo_axu | bo_async);
   assign cp3_exc_esr[10] = (~(cp3_db_int_events_val)) & (pie_iu | pie_lq | pie_xu | pie_axu | pie_async);
   assign cp3_exc_esr[11] = (~(cp3_db_int_events_val)) & (uct_iu | uct_lq | uct_xu | uct_axu | uct_async);
   assign cp3_exc_esr[12] = (~(cp3_db_int_events_val)) & (data_iu | data_lq | data_xu | data_axu | data_async);
   assign cp3_exc_esr[13] = (~(cp3_db_int_events_val)) & (tlbi_iu | tlbi_lq | tlbi_xu | tlbi_axu | tlbi_async);
   assign cp3_exc_esr[14] = (~(cp3_db_int_events_val)) & (pt_iu | pt_lq | pt_xu | pt_axu | pt_async);
   assign cp3_exc_esr[15] = (~(cp3_db_int_events_val)) & ((spv_iu | spv_lq | spv_xu | spv_axu | spv_async) & cp3_spv);
   assign cp3_exc_esr[16] = (~(cp3_db_int_events_val)) & ((epid_iu | epid_lq | epid_xu | epid_axu | epid_async) & cp3_epid);

   assign cp3_exc_mcsr[0] = (~(cp3_db_int_events_val)) & 1'b0;
   assign cp3_exc_mcsr[1] = (~(cp3_db_int_events_val)) & dcache_dir_multi_lq;
   assign cp3_exc_mcsr[2] = (~(cp3_db_int_events_val)) & tlb_snoop_rej_async;
   assign cp3_exc_mcsr[3] = (~(cp3_db_int_events_val)) & (tlb_lru_par_async | tlb_lru_par_lq | tlb_lru_par_xu);
   assign cp3_exc_mcsr[4] = (~(cp3_db_int_events_val)) & icache_l2_ecc_iu;
   assign cp3_exc_mcsr[5] = (~(cp3_db_int_events_val)) & dcache_l2_ecc_lq;
   assign cp3_exc_mcsr[6] = (~(cp3_db_int_events_val)) & dcache_dir_par_lq;
   assign cp3_exc_mcsr[7] = (~(cp3_db_int_events_val)) & mchk_ext_async;
   assign cp3_exc_mcsr[8] = (~(cp3_db_int_events_val)) & dcache_par_lq;
   assign cp3_exc_mcsr[9] = (~(cp3_db_int_events_val)) & ierat_multi_iu;
   assign cp3_exc_mcsr[10] = (~(cp3_db_int_events_val)) & derat_multi_lq;
   assign cp3_exc_mcsr[11] = (~(cp3_db_int_events_val)) & (tlb_multi_async | tlb_multi_lq | tlb_multi_xu);
   assign cp3_exc_mcsr[12] = (~(cp3_db_int_events_val)) & (ierat_par_iu | ierat_par_xu);
   assign cp3_exc_mcsr[13] = (~(cp3_db_int_events_val)) & (derat_par_lq | derat_par_xu);
   assign cp3_exc_mcsr[14] = (~(cp3_db_int_events_val)) & (tlb_par_async | tlb_par_lq | tlb_par_xu);

   assign eheir_update = hyp_priv_iu | hyp_priv_lq | hyp_priv_xu;
   assign dp_cp_async_flush = dp_cp_async;
   assign dp_cp_async_bus_snoop_flush = dp_cp_async_bus_snoop;
   assign async_np1_flush = async_np1;
   assign async_n_flush = (async_n | n_flush_iu);
   assign mm_iu_exception = (instr_tlb_async | instr_tlb_async | pt_fault_async | lrat_miss_async | tlb_inelig_async |
                             tlb_multi_async | tlb_par_async | tlb_lru_par_async);
   assign pc_iu_stop = pc_stop;
   assign mc_int = ~cp3_db_int_events_val & (mcheck_iu | mcheck_lq | mcheck_xu | mcheck_async) & (msr_me | msr_gs);
   assign cp3_mchk_disabled = ~cp3_db_int_events_val & (mcheck_iu | mcheck_lq | mcheck_xu | mcheck_async) & ~(msr_me | msr_gs);
   assign g_int = guest_int;
   assign guest_int = (~(cp3_db_int_events_val)) &
                      (((instr_tlb_async | instruction_tlb_iu) & msr_gs & epcr_itlbgs) |
                      ((instruction_storage_iu | pt_fault_async | tlb_inelig_async) & msr_gs & epcr_isigs) |
                      ((data_tlb_lq | tlb_xu) & msr_gs & epcr_dtlbgs) |
                      ((data_storage_lq | data_storage_xu) & msr_gs & epcr_dsigs) |
                      (external_async & epcr_extgs) |
                      (system_call_iu & msr_gs) |
                       guest_async);

   assign c_int = cp3_db_int_events_val | crit_async;
   assign dbell_taken = dbell_async;
   assign cdbell_taken = dbell_crit_async;
   assign gdbell_taken = guest_dbell_async;
   assign gcdbell_taken = guest_dbell_crit_async;
   assign gmcdbell_taken = guest_dbell_mchk_async;

   //------------------------------------------------------------------------------------------------------------------
   // cp_mm except bus
   //------------------------------------------------------------------------------------------------------------------
   //				I-Side			D-Side
   //  0 	Valid
   //  1		I=0/D=1
   //
   //  2		TLB Miss		instruction_tlb_iu |		data_tlb_lq |
   //				instr_tlb_async		tlb_xu
   //
   //  3		Storage		instruction_storage_iu |  		data_storage_lq |
   //				pt_fault_async |		data_storage_xu
   //				tlb_inelig_async
   //
   //  4		LRAT Miss		lrat_miss_async		lrat_lq | lrat_xu | lrat_miss_async
   //
   //  5		Machine Check 	ierat_multi_iu |		derat_par_lq |
   //				ierat_par_iu			derat_multi_lq |
   //				ierat_par_xu			derat_par_xu |
   //				tlb_multi_async | 		tlb_lru_par_lq |
   //				tlb_par_async | 		tlb_multi_lq |
   //				tlb_lru_par_async		tlb_par_lq
   //							tlb_lru_par_xu
   //							tlb_multi_xu
   //							tlb_par_xu
   //							tlb_snoop_rej_async



   // Bit 2
   //ITLB Miss
   assign cp_mm_itlb_miss = instruction_tlb_iu | instr_tlb_async;
   // DTLB Miss
   assign cp_mm_dtlb_miss = data_tlb_lq | tlb_xu;

   // Bit 3
   // ISI
   assign cp_mm_isi = instruction_storage_iu | pt_fault_async | tlb_inelig_async;
   // DSI
   assign cp_mm_dsi = ( data_storage_xu  | // TLBI
                      (cp3_lq_excvec_val &
                      ((cp3_lq_excvec == 6'b010000) |    // PT Fault
	          (cp3_lq_excvec == 6'b010001) |    // TLBI
	          (cp3_lq_excvec == 6'b010101) |    // Virtualization Fault bit set
	          (cp3_lq_excvec == 6'b010110))));  // R/W/E Access violation

   // Bit 4
   // ILRAT Miss
   assign cp_mm_ilrat_miss = lrat_miss_async;
   // DLRAT Miss
   assign cp_mm_dlrat_miss = lrat_lq | lrat_xu;

   // Bit 5
   // I-Side Machine Checks
   assign cp_mm_imchk = ierat_multi_iu | ierat_par_iu | ierat_par_xu | tlb_multi_async | tlb_par_async | tlb_lru_par_async;
   // D-Side Machine Checks
   assign cp_mm_dmchk = (derat_par_lq   | derat_multi_lq | derat_par_xu |
                         tlb_lru_par_lq | tlb_multi_lq   | tlb_par_lq   |
                         tlb_lru_par_xu | tlb_multi_xu   | tlb_par_xu   |
                         tlb_snoop_rej_async);


endmodule
