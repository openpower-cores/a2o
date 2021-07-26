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

//********************************************************************
//* TITLE: Memory Management Unit Special Purpose Registers
//*********************************************************************

`timescale 1 ns / 1 ns

`include "tri_a2o.vh"
`include "mmu_a2o.vh"

module mmq_spr(

   inout                                vdd,
   inout                                gnd,
   (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]              nclk,

   input [0:`THREADS-1]                 cp_flush,
   output [0:`MM_THREADS-1]             cp_flush_p1,

   input                                tc_ccflush_dc,
   input                                tc_scan_dis_dc_b,
   input                                tc_scan_diag_dc,
   input                                tc_lbist_en_dc,

   input                                lcb_d_mode_dc,
   input                                lcb_clkoff_dc_b,
   input                                lcb_act_dis_dc,
   input [0:4]                          lcb_mpw1_dc_b,
   input                                lcb_mpw2_dc_b,
   input [0:4]                          lcb_delay_lclkr_dc,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:1]                          ac_func_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:1]                         ac_func_scan_out,
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                                ac_bcfg_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                               ac_bcfg_scan_out,

   input                                pc_sg_2,
   input                                pc_func_sl_thold_2,
   input                                pc_func_slp_sl_thold_2,
   input                                pc_func_slp_nsl_thold_2,
   input                                pc_cfg_sl_thold_2,
   input                                pc_cfg_slp_sl_thold_2,
   input                                pc_fce_2,
   input                                xu_mm_ccr2_notlb_b,
   input [5:6]                          mmucr2_act_override,
   input [29:29+`MM_THREADS-1]          tlb_delayed_act,

`ifdef WAIT_UPDATES
   // 0   - val
   // 1   - I=0/D=1
   // 2   - TLB miss
   // 3   - Storage int (TLBI/PTfault)
   // 4   - LRAT miss
   // 5   - Mcheck
   input  [0:5]              cp_mm_except_taken_t0,
`ifdef MM_THREADS2
   input  [0:5]              cp_mm_except_taken_t1,
`endif
   output [0:`MM_THREADS+5-1]           cp_mm_perf_except_taken_q,
   // 0:1 - thdid/val
   // 2   - I=0/D=1
   // 3   - TLB miss
   // 4   - Storage int (TLBI/PTfault)
   // 5   - LRAT miss
   // 6   - Mcheck
`endif


   output [0:`PID_WIDTH-1]              mm_iu_ierat_pid0,
`ifdef MM_THREADS2
   output [0:`PID_WIDTH-1]              mm_iu_ierat_pid1,
`endif
   output [0:19]                        mm_iu_ierat_mmucr0_0,
`ifdef MM_THREADS2
   output [0:19]                        mm_iu_ierat_mmucr0_1,
`endif
   input [0:17]                         iu_mm_ierat_mmucr0,
   input [0:`MM_THREADS-1]              iu_mm_ierat_mmucr0_we,
   output [0:8]                         mm_iu_ierat_mmucr1,
   input [0:3]                          iu_mm_ierat_mmucr1,
   input [0:`MM_THREADS-1]              iu_mm_ierat_mmucr1_we,

   output [0:`PID_WIDTH-1]              mm_xu_derat_pid0,
`ifdef MM_THREADS2
   output [0:`PID_WIDTH-1]              mm_xu_derat_pid1,
`endif
   output [0:19]                        mm_xu_derat_mmucr0_0,
`ifdef MM_THREADS2
   output [0:19]                        mm_xu_derat_mmucr0_1,
`endif
   input [0:17]                         xu_mm_derat_mmucr0,
   input [0:`MM_THREADS-1]              xu_mm_derat_mmucr0_we,
   output [0:9]                         mm_xu_derat_mmucr1,
   input [0:4]                          xu_mm_derat_mmucr1,
   input [0:`MM_THREADS-1]              xu_mm_derat_mmucr1_we,

   output [0:`PID_WIDTH-1]               pid0,
`ifdef MM_THREADS2
   output [0:`PID_WIDTH-1]               pid1,
`endif
   output [0:`MMUCR0_WIDTH-1]            mmucr0_0,
`ifdef MM_THREADS2
   output [0:`MMUCR0_WIDTH-1]            mmucr0_1,
`endif
   output [0:`MMUCR1_WIDTH-1]            mmucr1,
   output [0:`MMUCR2_WIDTH-1]            mmucr2,
   output [64-`MMUCR3_WIDTH:63]          mmucr3_0,
   output [1:3]                          tstmode4k_0,
`ifdef MM_THREADS2
   output [64-`MMUCR3_WIDTH:63]          mmucr3_1,
   output [1:3]                          tstmode4k_1,
`endif

   output                               mmucfg_lrat,
   output                               mmucfg_twc,
   output                               tlb0cfg_pt,
   output                               tlb0cfg_ind,
   output                               tlb0cfg_gtwe,
   output [0:`MESR1_WIDTH+`MESR2_WIDTH-1] mmq_spr_event_mux_ctrls,

   output                               mas0_0_atsel,
   output [0:2]                         mas0_0_esel,
   output                               mas0_0_hes,
   output [0:1]                         mas0_0_wq,
   output                               mas1_0_v,
   output                               mas1_0_iprot,
   output [0:13]                        mas1_0_tid,
   output                               mas1_0_ind,
   output                               mas1_0_ts,
   output [0:3]                         mas1_0_tsize,
   output [0:51]                        mas2_0_epn,
   output [0:4]                         mas2_0_wimge,
   output [32:52]                       mas3_0_rpnl,
   output [0:3]                         mas3_0_ubits,
   output [0:5]                         mas3_0_usxwr,
   output                               mas5_0_sgs,
   output [0:7]                         mas5_0_slpid,
   output [0:13]                        mas6_0_spid,
   output [0:3]                         mas6_0_isize,
   output                               mas6_0_sind,
   output                               mas6_0_sas,
   output [22:31]                       mas7_0_rpnu,
   output                               mas8_0_tgs,
   output                               mas8_0_vf,
   output [0:7]                         mas8_0_tlpid,
`ifdef MM_THREADS2
   output                               mas0_1_atsel,
   output [0:2]                         mas0_1_esel,
   output                               mas0_1_hes,
   output [0:1]                         mas0_1_wq,
   output                               mas1_1_v,
   output                               mas1_1_iprot,
   output [0:13]                        mas1_1_tid,
   output                               mas1_1_ind,
   output                               mas1_1_ts,
   output [0:3]                         mas1_1_tsize,
   output [0:51]                        mas2_1_epn,
   output [0:4]                         mas2_1_wimge,
   output [32:52]                       mas3_1_rpnl,
   output [0:3]                         mas3_1_ubits,
   output [0:5]                         mas3_1_usxwr,
   output                               mas5_1_sgs,
   output [0:7]                         mas5_1_slpid,
   output [0:13]                        mas6_1_spid,
   output [0:3]                         mas6_1_isize,
   output                               mas6_1_sind,
   output                               mas6_1_sas,
   output [22:31]                       mas7_1_rpnu,
   output                               mas8_1_tgs,
   output                               mas8_1_vf,
   output [0:7]                         mas8_1_tlpid,
`endif
   input [0:2]                          tlb_mas0_esel,
   input                                tlb_mas1_v,
   input                                tlb_mas1_iprot,
   input [0:`PID_WIDTH-1]               tlb_mas1_tid,
   input [0:`PID_WIDTH-1]               tlb_mas1_tid_error,
   input                                tlb_mas1_ind,
   input                                tlb_mas1_ts,
   input                                tlb_mas1_ts_error,
   input [0:3]                          tlb_mas1_tsize,
   input [0:`EPN_WIDTH-1]               tlb_mas2_epn,
   input [0:`EPN_WIDTH-1]               tlb_mas2_epn_error,
   input [0:4]                          tlb_mas2_wimge,
   input [32:51]                        tlb_mas3_rpnl,
   input [0:3]                          tlb_mas3_ubits,
   input [0:5]                          tlb_mas3_usxwr,
   input [22:31]                        tlb_mas7_rpnu,
   input                                tlb_mas8_tgs,
   input                                tlb_mas8_vf,
   input [0:7]                          tlb_mas8_tlpid,

   input [0:8]                          tlb_mmucr1_een,
   input                                tlb_mmucr1_we,
   input [0:`THDID_WIDTH-1]             tlb_mmucr3_thdid,
   input                                tlb_mmucr3_resvattr,
   input [0:1]                          tlb_mmucr3_wlc,
   input [0:`CLASS_WIDTH-1]             tlb_mmucr3_class,
   input [0:`EXTCLASS_WIDTH-1]          tlb_mmucr3_extclass,
   input [0:1]                          tlb_mmucr3_rc,
   input                                tlb_mmucr3_x,
   input                                tlb_mas_tlbre,
   input                                tlb_mas_tlbsx_hit,
   input                                tlb_mas_tlbsx_miss,
   input                                tlb_mas_dtlb_error,
   input                                tlb_mas_itlb_error,
   input [0:`MM_THREADS-1]              tlb_mas_thdid,

   output                               mmucsr0_tlb0fi,
   input                                mmq_inval_tlb0fi_done,

   input                                lrat_mmucr3_x,
   input [0:2]                          lrat_mas0_esel,
   input                                lrat_mas1_v,
   input [0:3]                          lrat_mas1_tsize,
   input [0:51]                         lrat_mas2_epn,
   input [32:51]                        lrat_mas3_rpnl,
   input [22:31]                        lrat_mas7_rpnu,
   input [0:`LPID_WIDTH-1]              lrat_mas8_tlpid,
   input                                lrat_mas_tlbre,
   input                                lrat_mas_tlbsx_hit,
   input                                lrat_mas_tlbsx_miss,
   input [0:`MM_THREADS-1]              lrat_mas_thdid,
   input [0:2]                          lrat_tag4_hit_entry,

   input [64-`REAL_ADDR_WIDTH:51]       tlb_lper_lpn,
   input [60:63]                        tlb_lper_lps,
   input [0:`MM_THREADS-1]              tlb_lper_we,

   output [0:`LPID_WIDTH-1]             lpidr,
   output [0:`LPID_WIDTH-1]             ac_an_lpar_id,

   output                               spr_dbg_match_64b,
   output                               spr_dbg_match_any_mmu,
   output                               spr_dbg_match_any_mas,
   output                               spr_dbg_match_pid,
   output                               spr_dbg_match_lpidr,
   output                               spr_dbg_match_mmucr0,
   output                               spr_dbg_match_mmucr1,
   output                               spr_dbg_match_mmucr2,
   output                               spr_dbg_match_mmucr3,

   output                               spr_dbg_match_mmucsr0,
   output                               spr_dbg_match_mmucfg,
   output                               spr_dbg_match_tlb0cfg,
   output                               spr_dbg_match_tlb0ps,
   output                               spr_dbg_match_lratcfg,
   output                               spr_dbg_match_lratps,
   output                               spr_dbg_match_eptcfg,
   output                               spr_dbg_match_lper,
   output                               spr_dbg_match_lperu,

   output                               spr_dbg_match_mas0,
   output                               spr_dbg_match_mas1,
   output                               spr_dbg_match_mas2,
   output                               spr_dbg_match_mas2u,
   output                               spr_dbg_match_mas3,
   output                               spr_dbg_match_mas4,
   output                               spr_dbg_match_mas5,
   output                               spr_dbg_match_mas6,
   output                               spr_dbg_match_mas7,
   output                               spr_dbg_match_mas8,
   output                               spr_dbg_match_mas01_64b,
   output                               spr_dbg_match_mas56_64b,
   output                               spr_dbg_match_mas73_64b,
   output                               spr_dbg_match_mas81_64b,

   output                               spr_dbg_slowspr_val_int,
   output                               spr_dbg_slowspr_rw_int,
   output [0:1]                         spr_dbg_slowspr_etid_int,
   output [0:9]                         spr_dbg_slowspr_addr_int,
   output                               spr_dbg_slowspr_val_out,
   output                               spr_dbg_slowspr_done_out,
   output [64-`SPR_DATA_WIDTH:63]       spr_dbg_slowspr_data_out,

   input                                xu_mm_slowspr_val,
   input                                xu_mm_slowspr_rw,
   input [0:1]                          xu_mm_slowspr_etid,
   input [0:9]                          xu_mm_slowspr_addr,
   input [64-`SPR_DATA_WIDTH:63]        xu_mm_slowspr_data,
   input                                xu_mm_slowspr_done,

   output                               mm_iu_slowspr_val,
   output                               mm_iu_slowspr_rw,
   output [0:1]                         mm_iu_slowspr_etid,
   output [0:9]                         mm_iu_slowspr_addr,
   output [64-`SPR_DATA_WIDTH:63]       mm_iu_slowspr_data,

   output                               mm_iu_slowspr_done

);

   parameter                            BCFG_MMUCR1_VALUE = 201326592;  // mmucr1 32-bits boot value, 201326592 -> bits 4:5 csinv="11"
   parameter                            BCFG_MMUCR2_VALUE = 685361;     // mmucr2 32-bits boot value, 0xa7531
   parameter                            BCFG_MMUCR3_VALUE = 15;         // mmucr2 15-bits boot value, 0x000f
   parameter                            BCFG_MMUCFG_VALUE = 3;          // mmucfg lrat|twc bits boot value
   parameter                            BCFG_TLB0CFG_VALUE = 7;         // tlb0cfg pt|ind|gtwe bits boot value
   parameter                            MMQ_SPR_CSWITCH_0TO3 = 8;       // chicken switch values: 8=disable mmucr1 read clear, 4=disable mmucr1.tlbwe_binv


      parameter [0:9]                      Spr_Addr_PID = 10'b0000110000;
      //constant Spr_Addr_LPID : std_ulogic_vector(0 to 9) :=  1001111110 ; -- dec 638
      parameter [0:9]                      Spr_Addr_LPID = 10'b0101010010;
      parameter [0:9]                      Spr_Addr_MMUCR0 = 10'b1111111100;
      parameter [0:9]                      Spr_Addr_MMUCR1 = 10'b1111111101;
      parameter [0:9]                      Spr_Addr_MMUCR2 = 10'b1111111110;
      parameter [0:9]                      Spr_Addr_MMUCR3 = 10'b1111111111;
      parameter                            Spr_RW_Write = 1'b0;
      parameter                            Spr_RW_Read = 1'b1;
      parameter [0:9]                      Spr_Addr_MESR1 = 10'b1110010100;
      parameter [0:9]                      Spr_Addr_MESR2 = 10'b1110010101;
      parameter [0:9]                      Spr_Addr_MAS0 = 10'b1001110000;
      parameter [0:9]                      Spr_Addr_MAS1 = 10'b1001110001;
      parameter [0:9]                      Spr_Addr_MAS2 = 10'b1001110010;
      parameter [0:9]                      Spr_Addr_MAS2U = 10'b1001110111;
      parameter [0:9]                      Spr_Addr_MAS3 = 10'b1001110011;
      parameter [0:9]                      Spr_Addr_MAS4 = 10'b1001110100;
      parameter [0:9]                      Spr_Addr_MAS5 = 10'b0101010011;
      parameter [0:9]                      Spr_Addr_MAS6 = 10'b1001110110;
      parameter [0:9]                      Spr_Addr_MAS7 = 10'b1110110000;
      parameter [0:9]                      Spr_Addr_MAS8 = 10'b0101010101;
      parameter [0:9]                      Spr_Addr_MAS56_64b = 10'b0101011100;
      parameter [0:9]                      Spr_Addr_MAS81_64b = 10'b0101011101;
      parameter [0:9]                      Spr_Addr_MAS73_64b = 10'b0101110100;
      parameter [0:9]                      Spr_Addr_MAS01_64b = 10'b0101110101;
      parameter [0:9]                      Spr_Addr_MMUCFG = 10'b1111110111;
      parameter [0:9]                      Spr_Addr_MMUCSR0 = 10'b1111110100;
      parameter [0:9]                      Spr_Addr_TLB0CFG = 10'b1010110000;
      parameter [0:9]                      Spr_Addr_TLB0PS = 10'b0101011000;
      parameter [0:9]                      Spr_Addr_LRATCFG = 10'b0101010110;
      parameter [0:9]                      Spr_Addr_LRATPS = 10'b0101010111;
      parameter [0:9]                      Spr_Addr_EPTCFG = 10'b0101011110;
      parameter [0:9]                      Spr_Addr_LPER = 10'b0000111000;
      parameter [0:9]                      Spr_Addr_LPERU = 10'b0000111001;
      // MMUCFG: 32:35 resv, 36:39 LPIDSIZE=0x8, 40:46 RASIZE=0x2a, 47 LRAT bcfg, 48 TWC bcfg,
      //         49:52 resv, 53:57 PIDSIZE=0xd, 58:59 resv, 60:61 NTLBS=0b00, 62:63 MAVN=0b01
      parameter [32:63]                    Spr_Data_MMUCFG = 32'b00001000010101011000001101000001;
      // TLB0CFG: 32:39 ASSOC=0x04, 40:44 resv, 45 PT bcfg, 46 IND bcfg, 47 GTWE bcfg,
      //          48 IPROT=1, 49 resv, 50 HES=1, 51 resv, 52:63 NENTRY=0x200
      parameter [32:63]                    Spr_Data_TLB0CFG = 32'b00000100000000001010001000000000;
      // TLB0PS: 32:63 PS31-PS0=0x0010_4444 (PS20, PS14, PS10, PS6, PS2 = 1, others = 0)
      parameter [32:63]                    Spr_Data_TLB0PS = 32'b00000000000100000100010001000100;
      // LRATCFG: 32:39 ASSOC=0x00, 40:46 LASIZE=0x2a, 47:49 resv, 50 LPID=1, 51 resv, 52:63 NENTRY=0x008
      parameter [32:63]                    Spr_Data_LRATCFG = 32'b00000000010101000010000000001000;
      // LRATPS: 32:63 PS31-PS0=0x5154_4400 (PS30, PS28, PS24, PS22, PS20, PS18, PS14, PS10 = 1, others = 0)
      parameter [32:63]                    Spr_Data_LRATPS = 32'b01010001010101000100010000000000;
      // EPTCFG: 32:43 resv,  44:48 PS1=0x12, 49:53 SPS1=0x06, 54:58 PS0=0x0a, 59:63 SPS0=0x02
      parameter [32:63]                    Spr_Data_EPTCFG = 32'b00000000000010010001100101000010;

      parameter [0:15]                      TSTMODE4KCONST1 = 16'b0101101001101001;  // 0x5A69
      parameter [0:11]                      TSTMODE4KCONST2 = 12'b110000111011;  // 0xC3B

      // latches scan chain constants
      parameter                            cp_flush_offset = 0;
      parameter                            cp_flush_p1_offset = cp_flush_offset + `MM_THREADS;
      parameter                            spr_ctl_in_offset = cp_flush_p1_offset + `MM_THREADS;
      parameter                            spr_etid_in_offset = spr_ctl_in_offset + `SPR_CTL_WIDTH;
      parameter                            spr_addr_in_offset = spr_etid_in_offset + `SPR_ETID_WIDTH;
      parameter                            spr_data_in_offset = spr_addr_in_offset + `SPR_ADDR_WIDTH;
      parameter                            spr_ctl_int_offset = spr_data_in_offset + `SPR_DATA_WIDTH;
      parameter                            spr_etid_int_offset = spr_ctl_int_offset + `SPR_CTL_WIDTH;
      parameter                            spr_addr_int_offset = spr_etid_int_offset + `SPR_ETID_WIDTH;
      parameter                            spr_data_int_offset = spr_addr_int_offset + `SPR_ADDR_WIDTH;
      parameter                            spr_ctl_out_offset = spr_data_int_offset + `SPR_DATA_WIDTH;
      parameter                            spr_etid_out_offset = spr_ctl_out_offset + `SPR_CTL_WIDTH;
      parameter                            spr_addr_out_offset = spr_etid_out_offset + `SPR_ETID_WIDTH;
      parameter                            spr_data_out_offset = spr_addr_out_offset + `SPR_ADDR_WIDTH;
      parameter                            spr_match_any_mmu_offset = spr_data_out_offset + `SPR_DATA_WIDTH;
      parameter                            spr_match_pid0_offset = spr_match_any_mmu_offset + 1;
`ifdef MM_THREADS2
      parameter                            spr_match_pid1_offset = spr_match_pid0_offset + 1;
      parameter                            spr_match_mmucr0_0_offset = spr_match_pid1_offset + 1;
      parameter                            spr_match_mmucr0_1_offset = spr_match_mmucr0_0_offset + 1;
      parameter                            spr_match_mmucr1_offset = spr_match_mmucr0_1_offset + 1;
`else
      parameter                            spr_match_mmucr0_0_offset = spr_match_pid0_offset + 1;
      parameter                            spr_match_mmucr1_offset = spr_match_mmucr0_0_offset + 1;
`endif
      parameter                            spr_match_mmucr2_offset = spr_match_mmucr1_offset + 1;
      parameter                            spr_match_mmucr3_0_offset = spr_match_mmucr2_offset + 1;
`ifdef MM_THREADS2
      parameter                            spr_match_mmucr3_1_offset = spr_match_mmucr3_0_offset + 1;
      parameter                            spr_match_lpidr_offset = spr_match_mmucr3_1_offset + 1;
`else
      parameter                            spr_match_lpidr_offset = spr_match_mmucr3_0_offset + 1;
`endif
      parameter                            spr_match_mesr1_offset = spr_match_lpidr_offset + 1;
      parameter                            spr_match_mesr2_offset = spr_match_mesr1_offset + 1;
      parameter                            pid0_offset = spr_match_mesr2_offset + 1;
`ifdef MM_THREADS2
      parameter                            pid1_offset = pid0_offset + `PID_WIDTH;
      parameter                            mmucr0_0_offset = pid1_offset + `PID_WIDTH;
`else
      parameter                            mmucr0_0_offset = pid0_offset + `PID_WIDTH;
`endif
`ifdef MM_THREADS2
      parameter                            mmucr0_1_offset = mmucr0_0_offset + `MMUCR0_WIDTH;
      parameter                            lpidr_offset = mmucr0_1_offset + `MMUCR0_WIDTH;
`else
      parameter                            lpidr_offset = mmucr0_0_offset + `MMUCR0_WIDTH;
`endif
      parameter                            mesr1_offset = lpidr_offset + `LPID_WIDTH;
      parameter                            mesr2_offset = mesr1_offset + `MESR1_WIDTH;
      parameter                            spare_a_offset = mesr2_offset + `MESR2_WIDTH;
      parameter                            spr_mmu_act_offset = spare_a_offset + 32;
      parameter                            spr_val_act_offset = spr_mmu_act_offset + `MM_THREADS + 1;
`ifdef WAIT_UPDATES
      parameter                            cp_mm_except_taken_t0_offset = spr_val_act_offset + 4;
      parameter                            tlb_mas_dtlb_error_pending_offset = cp_mm_except_taken_t0_offset + 6;
      parameter                            tlb_mas_itlb_error_pending_offset = tlb_mas_dtlb_error_pending_offset + `MM_THREADS;
      parameter                            tlb_lper_we_pending_offset = tlb_mas_itlb_error_pending_offset + `MM_THREADS;
      parameter                            tlb_mmucr1_we_pending_offset = tlb_lper_we_pending_offset + `MM_THREADS;
      parameter                            ierat_mmucr1_we_pending_offset = tlb_mmucr1_we_pending_offset + `MM_THREADS;
      parameter                            derat_mmucr1_we_pending_offset = ierat_mmucr1_we_pending_offset + `MM_THREADS;
      parameter                            tlb_mas1_0_ts_error_offset = derat_mmucr1_we_pending_offset + `MM_THREADS;
      parameter                            tlb_mas1_0_tid_error_offset = tlb_mas1_0_ts_error_offset + 1;
      parameter                            tlb_mas2_0_epn_error_offset = tlb_mas1_0_tid_error_offset + `PID_WIDTH;
      parameter                            tlb_lper_0_lpn_offset = tlb_mas2_0_epn_error_offset + `EPN_WIDTH;
      parameter                            tlb_lper_0_lps_offset = tlb_lper_0_lpn_offset + `REAL_ADDR_WIDTH-12;
      parameter                            tlb_mmucr1_0_een_offset = tlb_lper_0_lps_offset + 4;
      parameter                            ierat_mmucr1_0_een_offset = tlb_mmucr1_0_een_offset + 9;
      parameter                            derat_mmucr1_0_een_offset = ierat_mmucr1_0_een_offset + 4;
`ifdef MM_THREADS2
      parameter                            cp_mm_except_taken_t1_offset = derat_mmucr1_0_een_offset + 5;
      parameter                            tlb_mas1_1_ts_error_offset = cp_mm_except_taken_t1_offset + 6;
      parameter                            tlb_mas1_1_tid_error_offset = tlb_mas1_1_ts_error_offset + 1;
      parameter                            tlb_mas2_1_epn_error_offset = tlb_mas1_1_tid_error_offset + `PID_WIDTH;
      parameter                            tlb_lper_1_lpn_offset = tlb_mas2_1_epn_error_offset + `EPN_WIDTH;
      parameter                            tlb_lper_1_lps_offset = tlb_lper_1_lpn_offset + `REAL_ADDR_WIDTH-12;
      parameter                            tlb_mmucr1_1_een_offset = tlb_lper_1_lps_offset + 4;
      parameter                            ierat_mmucr1_1_een_offset = tlb_mmucr1_1_een_offset + 9;
      parameter                            derat_mmucr1_1_een_offset = ierat_mmucr1_1_een_offset + 4;
      parameter                            cswitch_offset = derat_mmucr1_1_een_offset + 5;
`else
      parameter                            cswitch_offset = derat_mmucr1_0_een_offset + 5;
`endif
`else
      parameter                            cswitch_offset = spr_val_act_offset + 4;
`endif
      parameter                            scan_right_0 = cswitch_offset + 4 - 1;


      // MAS register constants
      parameter                            spr_match_mmucsr0_offset = 0;
      parameter                            spr_match_mmucfg_offset = spr_match_mmucsr0_offset + 1;
      parameter                            spr_match_tlb0cfg_offset = spr_match_mmucfg_offset + 1;
      parameter                            spr_match_tlb0ps_offset = spr_match_tlb0cfg_offset + 1;
      parameter                            spr_match_lratcfg_offset = spr_match_tlb0ps_offset + 1;
      parameter                            spr_match_lratps_offset = spr_match_lratcfg_offset + 1;
      parameter                            spr_match_eptcfg_offset = spr_match_lratps_offset + 1;
      parameter                            spr_match_lper_0_offset = spr_match_eptcfg_offset + 1;
`ifdef MM_THREADS2
      parameter                            spr_match_lper_1_offset = spr_match_lper_0_offset + 1;
      parameter                            spr_match_lperu_0_offset = spr_match_lper_1_offset + 1;
      parameter                            spr_match_lperu_1_offset = spr_match_lperu_0_offset + 1;
      parameter                            spr_match_mas0_0_offset = spr_match_lperu_1_offset + 1;
`else
      parameter                            spr_match_lperu_0_offset = spr_match_lper_0_offset + 1;
      parameter                            spr_match_mas0_0_offset = spr_match_lperu_0_offset + 1;
`endif
      parameter                            spr_match_mas1_0_offset = spr_match_mas0_0_offset + 1;
      parameter                            spr_match_mas2_0_offset = spr_match_mas1_0_offset + 1;
      parameter                            spr_match_mas2u_0_offset = spr_match_mas2_0_offset + 1;
      parameter                            spr_match_mas3_0_offset = spr_match_mas2u_0_offset + 1;
      parameter                            spr_match_mas4_0_offset = spr_match_mas3_0_offset + 1;
      parameter                            spr_match_mas5_0_offset = spr_match_mas4_0_offset + 1;
      parameter                            spr_match_mas6_0_offset = spr_match_mas5_0_offset + 1;
      parameter                            spr_match_mas7_0_offset = spr_match_mas6_0_offset + 1;
      parameter                            spr_match_mas8_0_offset = spr_match_mas7_0_offset + 1;
      parameter                            spr_match_mas01_64b_0_offset = spr_match_mas8_0_offset + 1;
      parameter                            spr_match_mas56_64b_0_offset = spr_match_mas01_64b_0_offset + 1;
      parameter                            spr_match_mas73_64b_0_offset = spr_match_mas56_64b_0_offset + 1;
      parameter                            spr_match_mas81_64b_0_offset = spr_match_mas73_64b_0_offset + 1;
`ifdef MM_THREADS2
      parameter                            spr_match_mas0_1_offset = spr_match_mas81_64b_0_offset + 1;
      parameter                            spr_match_mas1_1_offset = spr_match_mas0_1_offset + 1;
      parameter                            spr_match_mas2_1_offset = spr_match_mas1_1_offset + 1;
      parameter                            spr_match_mas2u_1_offset = spr_match_mas2_1_offset + 1;
      parameter                            spr_match_mas3_1_offset = spr_match_mas2u_1_offset + 1;
      parameter                            spr_match_mas4_1_offset = spr_match_mas3_1_offset + 1;
      parameter                            spr_match_mas5_1_offset = spr_match_mas4_1_offset + 1;
      parameter                            spr_match_mas6_1_offset = spr_match_mas5_1_offset + 1;
      parameter                            spr_match_mas7_1_offset = spr_match_mas6_1_offset + 1;
      parameter                            spr_match_mas8_1_offset = spr_match_mas7_1_offset + 1;
      parameter                            spr_match_mas01_64b_1_offset = spr_match_mas8_1_offset + 1;
      parameter                            spr_match_mas56_64b_1_offset = spr_match_mas01_64b_1_offset + 1;
      parameter                            spr_match_mas73_64b_1_offset = spr_match_mas56_64b_1_offset + 1;
      parameter                            spr_match_mas81_64b_1_offset = spr_match_mas73_64b_1_offset + 1;
      parameter                            spr_match_64b_offset = spr_match_mas81_64b_1_offset + 1;
`else
      parameter                            spr_match_64b_offset = spr_match_mas81_64b_0_offset + 1;
`endif
      parameter                            spr_addr_in_clone_offset = spr_match_64b_offset + 1;
      parameter                            spr_mas_data_out_offset = spr_addr_in_clone_offset + `SPR_ADDR_WIDTH;
      parameter                            spr_match_any_mas_offset = spr_mas_data_out_offset + `SPR_DATA_WIDTH;
      parameter                            mas0_0_atsel_offset = spr_match_any_mas_offset + 1;
      parameter                            mas0_0_esel_offset = mas0_0_atsel_offset + 1;
      parameter                            mas0_0_hes_offset = mas0_0_esel_offset + 3;
      parameter                            mas0_0_wq_offset = mas0_0_hes_offset + 1;
      parameter                            mas1_0_v_offset = mas0_0_wq_offset + 2;
      parameter                            mas1_0_iprot_offset = mas1_0_v_offset + 1;
      parameter                            mas1_0_tid_offset = mas1_0_iprot_offset + 1;
      parameter                            mas1_0_ind_offset = mas1_0_tid_offset + `PID_WIDTH;
      parameter                            mas1_0_ts_offset = mas1_0_ind_offset + 1;
      parameter                            mas1_0_tsize_offset = mas1_0_ts_offset + 1;
      parameter                            mas2_0_epn_offset = mas1_0_tsize_offset + 4;
      parameter                            mas2_0_wimge_offset = mas2_0_epn_offset + `EPN_WIDTH + `SPR_DATA_WIDTH - 64;
      parameter                            mas3_0_rpnl_offset = mas2_0_wimge_offset + 5;
      parameter                            mas3_0_ubits_offset = mas3_0_rpnl_offset + 21;
      parameter                            mas3_0_usxwr_offset = mas3_0_ubits_offset + 4;
      parameter                            mas5_0_sgs_offset = mas3_0_usxwr_offset + 6;
      parameter                            mas5_0_slpid_offset = mas5_0_sgs_offset + 1;
      parameter                            mas6_0_spid_offset = mas5_0_slpid_offset + 8;
      parameter                            mas6_0_isize_offset = mas6_0_spid_offset + 14;
      parameter                            mas6_0_sind_offset = mas6_0_isize_offset + 4;
      parameter                            mas6_0_sas_offset = mas6_0_sind_offset + 1;
      parameter                            mas7_0_rpnu_offset = mas6_0_sas_offset + 1;
      parameter                            mas8_0_tgs_offset = mas7_0_rpnu_offset + 10;
      parameter                            mas8_0_vf_offset = mas8_0_tgs_offset + 1;
      parameter                            mas8_0_tlpid_offset = mas8_0_vf_offset + 1;
`ifdef MM_THREADS2
      parameter                            mas0_1_atsel_offset = mas8_0_tlpid_offset + `LPID_WIDTH;
      parameter                            mas0_1_esel_offset = mas0_1_atsel_offset + 1;
      parameter                            mas0_1_hes_offset = mas0_1_esel_offset + 3;
      parameter                            mas0_1_wq_offset = mas0_1_hes_offset + 1;
      parameter                            mas1_1_v_offset = mas0_1_wq_offset + 2;
      parameter                            mas1_1_iprot_offset = mas1_1_v_offset + 1;
      parameter                            mas1_1_tid_offset = mas1_1_iprot_offset + 1;
      parameter                            mas1_1_ind_offset = mas1_1_tid_offset + `PID_WIDTH;
      parameter                            mas1_1_ts_offset = mas1_1_ind_offset + 1;
      parameter                            mas1_1_tsize_offset = mas1_1_ts_offset + 1;
      parameter                            mas2_1_epn_offset = mas1_1_tsize_offset + 4;
      parameter                            mas2_1_wimge_offset = mas2_1_epn_offset + `EPN_WIDTH + `SPR_DATA_WIDTH - 64;
      parameter                            mas3_1_rpnl_offset = mas2_1_wimge_offset + 5;
      parameter                            mas3_1_ubits_offset = mas3_1_rpnl_offset + 21;
      parameter                            mas3_1_usxwr_offset = mas3_1_ubits_offset + 4;
      parameter                            mas5_1_sgs_offset = mas3_1_usxwr_offset + 6;
      parameter                            mas5_1_slpid_offset = mas5_1_sgs_offset + 1;
      parameter                            mas6_1_spid_offset = mas5_1_slpid_offset + 8;
      parameter                            mas6_1_isize_offset = mas6_1_spid_offset + 14;
      parameter                            mas6_1_sind_offset = mas6_1_isize_offset + 4;
      parameter                            mas6_1_sas_offset = mas6_1_sind_offset + 1;
      parameter                            mas7_1_rpnu_offset = mas6_1_sas_offset + 1;
      parameter                            mas8_1_tgs_offset = mas7_1_rpnu_offset + 10;
      parameter                            mas8_1_vf_offset = mas8_1_tgs_offset + 1;
      parameter                            mas8_1_tlpid_offset = mas8_1_vf_offset + 1;
      parameter                            mmucsr0_tlb0fi_offset = mas8_1_tlpid_offset + `LPID_WIDTH;
`else
      parameter                            mmucsr0_tlb0fi_offset = mas8_0_tlpid_offset + `LPID_WIDTH;
`endif
      parameter                            lper_0_alpn_offset = mmucsr0_tlb0fi_offset + 1;
      parameter                            lper_0_lps_offset = lper_0_alpn_offset + `REAL_ADDR_WIDTH - 12;
`ifdef MM_THREADS2
      parameter                            lper_1_alpn_offset = lper_0_lps_offset + 4;
      parameter                            lper_1_lps_offset = lper_1_alpn_offset + `REAL_ADDR_WIDTH - 12;
      parameter                            spare_b_offset = lper_1_lps_offset + 4;
`else
      parameter                            spare_b_offset = lper_0_lps_offset + 4;
`endif
      parameter                            cat_emf_act_offset = spare_b_offset + 64;
      parameter                            scan_right_1 = cat_emf_act_offset + `MM_THREADS - 1;

      // boot config scan bits
      parameter                            mmucfg_offset = 0;
      parameter                            tlb0cfg_offset = mmucfg_offset + 2;
      parameter                            mmucr1_offset = tlb0cfg_offset + 3;
      parameter                            mmucr2_offset = mmucr1_offset + `MMUCR1_WIDTH;
`ifdef MM_THREADS2
      parameter                            mmucr3_0_offset = mmucr2_offset + `MMUCR2_WIDTH;
      parameter                            tstmode4k_0_offset = mmucr3_0_offset + `MMUCR3_WIDTH;
      parameter                            mmucr3_1_offset = tstmode4k_0_offset + 4;
      parameter                            tstmode4k_1_offset = mmucr3_1_offset + `MMUCR3_WIDTH;
      parameter                            mas4_0_indd_offset = tstmode4k_1_offset + 4;
      parameter                            mas4_0_tsized_offset = mas4_0_indd_offset + 1;
      parameter                            mas4_0_wimged_offset = mas4_0_tsized_offset + 4;
      parameter                            mas4_1_indd_offset = mas4_0_wimged_offset + 5;
      parameter                            mas4_1_tsized_offset = mas4_1_indd_offset + 1;
      parameter                            mas4_1_wimged_offset = mas4_1_tsized_offset + 4;
      parameter                            bcfg_spare_offset = mas4_1_wimged_offset + 5;
      parameter                            boot_scan_right = bcfg_spare_offset + 16 - 1;
`else
      parameter                            mmucr3_0_offset = mmucr2_offset + `MMUCR2_WIDTH;
      parameter                            tstmode4k_0_offset = mmucr3_0_offset + `MMUCR3_WIDTH;
      parameter                            mas4_0_indd_offset = tstmode4k_0_offset + 4;
      parameter                            mas4_0_tsized_offset = mas4_0_indd_offset + 1;
      parameter                            mas4_0_wimged_offset = mas4_0_tsized_offset + 4;
      parameter                            bcfg_spare_offset = mas4_0_wimged_offset + 5;
      parameter                            boot_scan_right = bcfg_spare_offset + 16 - 1;
`endif

`ifdef MM_THREADS2
      parameter                      BUGSP_MM_THREADS = 2;
`else
      parameter                      BUGSP_MM_THREADS = 1;
`endif

      wire                                 spr_match_any_mmu;
      wire                                 spr_match_any_mmu_q;
      wire                                 spr_match_pid0;
      wire                                 spr_match_pid0_q;
      wire                                 spr_match_mmucr0_0;
      wire                                 spr_match_mmucr0_0_q;
      wire                                 spr_match_mmucr3_0;
      wire                                 spr_match_mmucr3_0_q;
`ifdef MM_THREADS2
      wire                                 spr_match_pid1;
      wire                                 spr_match_pid1_q;
      wire                                 spr_match_mmucr0_1;
      wire                                 spr_match_mmucr0_1_q;
      wire                                 spr_match_mmucr3_1;
      wire                                 spr_match_mmucr3_1_q;
`endif
      wire                                 spr_match_mmucr1;
      wire                                 spr_match_mmucr1_q;
      wire                                 spr_match_mmucr2;
      wire                                 spr_match_mmucr2_q;
      wire                                 spr_match_lpidr;
      wire                                 spr_match_lpidr_q;
      wire                                 spr_match_mesr1;
      wire                                 spr_match_mesr1_q;
      wire                                 spr_match_mesr2;
      wire                                 spr_match_mesr2_q;
      wire                                 spr_match_mmucsr0;
      wire                                 spr_match_mmucsr0_q;
      wire                                 spr_match_mmucfg;
      wire                                 spr_match_mmucfg_q;
      wire                                 spr_match_tlb0cfg;
      wire                                 spr_match_tlb0cfg_q;
      wire                                 spr_match_tlb0ps;
      wire                                 spr_match_tlb0ps_q;
      wire                                 spr_match_lratcfg;
      wire                                 spr_match_lratcfg_q;
      wire                                 spr_match_lratps;
      wire                                 spr_match_lratps_q;
      wire                                 spr_match_eptcfg;
      wire                                 spr_match_eptcfg_q;
      wire                                 spr_match_lper_0;
      wire                                 spr_match_lper_0_q;
      wire                                 spr_match_lperu_0;
      wire                                 spr_match_lperu_0_q;
`ifdef MM_THREADS2
      wire                                 spr_match_lper_1;
      wire                                 spr_match_lper_1_q;
      wire                                 spr_match_lperu_1;
      wire                                 spr_match_lperu_1_q;
`endif
      wire                                 spr_match_mas0_0;
      wire                                 spr_match_mas0_0_q;
      wire                                 spr_match_mas1_0;
      wire                                 spr_match_mas1_0_q;
      wire                                 spr_match_mas2_0;
      wire                                 spr_match_mas2_0_q;
      wire                                 spr_match_mas2u_0;
      wire                                 spr_match_mas2u_0_q;
      wire                                 spr_match_mas3_0;
      wire                                 spr_match_mas3_0_q;
      wire                                 spr_match_mas4_0;
      wire                                 spr_match_mas4_0_q;
      wire                                 spr_match_mas5_0;
      wire                                 spr_match_mas5_0_q;
      wire                                 spr_match_mas6_0;
      wire                                 spr_match_mas6_0_q;
      wire                                 spr_match_mas7_0;
      wire                                 spr_match_mas7_0_q;
      wire                                 spr_match_mas8_0;
      wire                                 spr_match_mas8_0_q;
      wire                                 spr_match_mas01_64b_0;
      wire                                 spr_match_mas01_64b_0_q;
      wire                                 spr_match_mas56_64b_0;
      wire                                 spr_match_mas56_64b_0_q;
      wire                                 spr_match_mas73_64b_0;
      wire                                 spr_match_mas73_64b_0_q;
      wire                                 spr_match_mas81_64b_0;
      wire                                 spr_match_mas81_64b_0_q;
`ifdef MM_THREADS2
      wire                                 spr_match_mas0_1;
      wire                                 spr_match_mas0_1_q;
      wire                                 spr_match_mas1_1;
      wire                                 spr_match_mas1_1_q;
      wire                                 spr_match_mas2_1;
      wire                                 spr_match_mas2_1_q;
      wire                                 spr_match_mas2u_1;
      wire                                 spr_match_mas2u_1_q;
      wire                                 spr_match_mas3_1;
      wire                                 spr_match_mas3_1_q;
      wire                                 spr_match_mas4_1;
      wire                                 spr_match_mas4_1_q;
      wire                                 spr_match_mas5_1;
      wire                                 spr_match_mas5_1_q;
      wire                                 spr_match_mas6_1;
      wire                                 spr_match_mas6_1_q;
      wire                                 spr_match_mas7_1;
      wire                                 spr_match_mas7_1_q;
      wire                                 spr_match_mas8_1;
      wire                                 spr_match_mas8_1_q;
      wire                                 spr_match_mas01_64b_1;
      wire                                 spr_match_mas01_64b_1_q;
      wire                                 spr_match_mas56_64b_1;
      wire                                 spr_match_mas56_64b_1_q;
      wire                                 spr_match_mas73_64b_1;
      wire                                 spr_match_mas73_64b_1_q;
      wire                                 spr_match_mas81_64b_1;
      wire                                 spr_match_mas81_64b_1_q;
`endif
      wire [64-`SPR_DATA_WIDTH:63]         spr_mas_data_out;
      wire [64-`SPR_DATA_WIDTH:63]         spr_mas_data_out_q;
      wire                                 spr_match_any_mas;
      wire                                 spr_match_any_mas_q;
      wire                                 spr_match_mas2_64b;
      wire                                 spr_match_mas01_64b;
      wire                                 spr_match_mas56_64b;
      wire                                 spr_match_mas73_64b;
      wire                                 spr_match_mas81_64b;
      wire                                 spr_match_64b;
      wire                                 spr_match_64b_q;
      // added input latches for timing with adding numerous mas regs
      wire [0:`SPR_CTL_WIDTH-1]             spr_ctl_in_d;
      wire [0:`SPR_CTL_WIDTH-1]             spr_ctl_in_q;
      wire [0:`SPR_ETID_WIDTH-1]            spr_etid_in_d;
      wire [0:`SPR_ETID_WIDTH-1]            spr_etid_in_q;
      wire [0:`SPR_ADDR_WIDTH-1]            spr_addr_in_d;
      wire [0:`SPR_ADDR_WIDTH-1]            spr_addr_in_q;
      wire [64-`SPR_DATA_WIDTH:63]          spr_data_in_d;
      wire [64-`SPR_DATA_WIDTH:63]          spr_data_in_q;
      wire [0:`SPR_ADDR_WIDTH-1]            spr_addr_in_clone_d;
      wire [0:`SPR_ADDR_WIDTH-1]            spr_addr_in_clone_q;
      wire [0:`SPR_CTL_WIDTH-1]             spr_ctl_int_d;
      wire [0:`SPR_CTL_WIDTH-1]             spr_ctl_int_q;
      wire [0:`SPR_ETID_WIDTH-1]            spr_etid_int_d;
      wire [0:`SPR_ETID_WIDTH-1]            spr_etid_int_q;
      wire [0:`SPR_ADDR_WIDTH-1]            spr_addr_int_d;
      wire [0:`SPR_ADDR_WIDTH-1]            spr_addr_int_q;
      wire [64-`SPR_DATA_WIDTH:63]          spr_data_int_d;
      wire [64-`SPR_DATA_WIDTH:63]          spr_data_int_q;
      wire [0:`SPR_CTL_WIDTH-1]             spr_ctl_out_d;
      wire [0:`SPR_CTL_WIDTH-1]             spr_ctl_out_q;
      wire [0:`SPR_ETID_WIDTH-1]            spr_etid_out_d;
      wire [0:`SPR_ETID_WIDTH-1]            spr_etid_out_q;
      wire [0:`SPR_ADDR_WIDTH-1]            spr_addr_out_d;
      wire [0:`SPR_ADDR_WIDTH-1]            spr_addr_out_q;
      wire [64-`SPR_DATA_WIDTH:63]          spr_data_out_d;
      wire [64-`SPR_DATA_WIDTH:63]          spr_data_out_q;
      wire [0:3]                           spr_etid_onehot;
      wire [0:3]                           spr_etid_in_onehot;
      wire [0:3]                           spr_etid_int_onehot;
      wire [0:3]                           spr_etid_flushed;
      wire [0:3]                           spr_etid_in_flushed;
      wire [0:3]                           spr_etid_int_flushed;
      wire                                 spr_val_flushed;
      wire                                 spr_val_in_flushed;
      wire                                 spr_val_int_flushed;
      wire [0:`PID_WIDTH-1]                 pid0_d;
      wire [0:`PID_WIDTH-1]                 pid0_q;
      wire [0:`MMUCR0_WIDTH-1]              mmucr0_0_d;
      wire [0:`MMUCR0_WIDTH-1]              mmucr0_0_q;
      wire [64-`MMUCR3_WIDTH:63]            mmucr3_0_d;
      wire [64-`MMUCR3_WIDTH:63]            mmucr3_0_q;
      wire [0:3]            tstmode4k_0_d, tstmode4k_0_q;
`ifdef MM_THREADS2
      wire [0:`PID_WIDTH-1]                 pid1_d;
      wire [0:`PID_WIDTH-1]                 pid1_q;
      wire [0:`MMUCR0_WIDTH-1]              mmucr0_1_d;
      wire [0:`MMUCR0_WIDTH-1]              mmucr0_1_q;
      wire [64-`MMUCR3_WIDTH:63]            mmucr3_1_d;
      wire [64-`MMUCR3_WIDTH:63]            mmucr3_1_q;
      wire [0:3]            tstmode4k_1_d, tstmode4k_1_q;
`endif
      wire [0:`MMUCR1_WIDTH-1]              mmucr1_d;
      wire [0:`MMUCR1_WIDTH-1]              mmucr1_q;
      wire [0:`MMUCR2_WIDTH-1]              mmucr2_d;
      wire [0:`MMUCR2_WIDTH-1]              mmucr2_q;
      wire [0:`LPID_WIDTH-1]                lpidr_d;
      wire [0:`LPID_WIDTH-1]                lpidr_q;
      wire [32:32+`MESR1_WIDTH-1]           mesr1_d;
      wire [32:32+`MESR1_WIDTH-1]           mesr1_q;
      wire [32:32+`MESR2_WIDTH-1]           mesr2_d;
      wire [32:32+`MESR2_WIDTH-1]           mesr2_q;
      wire                                 mas0_0_atsel_d;
      wire                                 mas0_0_atsel_q;
      wire [0:2]                           mas0_0_esel_d;
      wire [0:2]                           mas0_0_esel_q;
      wire                                 mas0_0_hes_d;
      wire                                 mas0_0_hes_q;
      wire [0:1]                           mas0_0_wq_d;
      wire [0:1]                           mas0_0_wq_q;
      wire                                 mas1_0_v_d;
      wire                                 mas1_0_v_q;
      wire                                 mas1_0_iprot_d;
      wire                                 mas1_0_iprot_q;
      wire [0:`PID_WIDTH-1]                mas1_0_tid_d;
      wire [0:`PID_WIDTH-1]                mas1_0_tid_q;
      wire                                 mas1_0_ind_d;
      wire                                 mas1_0_ind_q;
      wire                                 mas1_0_ts_d;
      wire                                 mas1_0_ts_q;
      wire [0:3]                           mas1_0_tsize_d;
      wire [0:3]                           mas1_0_tsize_q;
      wire [64-`SPR_DATA_WIDTH:51]          mas2_0_epn_d;
      wire [64-`SPR_DATA_WIDTH:51]          mas2_0_epn_q;
      wire [0:4]                           mas2_0_wimge_d;
      wire [0:4]                           mas2_0_wimge_q;
      wire [32:52]                         mas3_0_rpnl_d;
      wire [32:52]                         mas3_0_rpnl_q;
      wire [0:3]                           mas3_0_ubits_d;
      wire [0:3]                           mas3_0_ubits_q;
      wire [0:5]                           mas3_0_usxwr_d;
      wire [0:5]                           mas3_0_usxwr_q;
      wire                                 mas4_0_indd_d;
      wire                                 mas4_0_indd_q;
      wire [0:3]                           mas4_0_tsized_d;
      wire [0:3]                           mas4_0_tsized_q;
      wire [0:4]                           mas4_0_wimged_d;
      wire [0:4]                           mas4_0_wimged_q;
      wire                                 mas5_0_sgs_d;
      wire                                 mas5_0_sgs_q;
      wire [0:7]                           mas5_0_slpid_d;
      wire [0:7]                           mas5_0_slpid_q;
      wire [0:13]                          mas6_0_spid_d;
      wire [0:13]                          mas6_0_spid_q;
      wire [0:3]                           mas6_0_isize_d;
      wire [0:3]                           mas6_0_isize_q;
      wire                                 mas6_0_sind_d;
      wire                                 mas6_0_sind_q;
      wire                                 mas6_0_sas_d;
      wire                                 mas6_0_sas_q;
      wire [22:31]                         mas7_0_rpnu_d;
      wire [22:31]                         mas7_0_rpnu_q;
      wire                                 mas8_0_tgs_d;
      wire                                 mas8_0_tgs_q;
      wire                                 mas8_0_vf_d;
      wire                                 mas8_0_vf_q;
      wire [0:7]                           mas8_0_tlpid_d;
      wire [0:7]                           mas8_0_tlpid_q;
`ifdef MM_THREADS2
      wire                                 mas0_1_atsel_d;
      wire                                 mas0_1_atsel_q;
      wire [0:2]                           mas0_1_esel_d;
      wire [0:2]                           mas0_1_esel_q;
      wire                                 mas0_1_hes_d;
      wire                                 mas0_1_hes_q;
      wire [0:1]                           mas0_1_wq_d;
      wire [0:1]                           mas0_1_wq_q;
      wire                                 mas1_1_v_d;
      wire                                 mas1_1_v_q;
      wire                                 mas1_1_iprot_d;
      wire                                 mas1_1_iprot_q;
      wire [0:`PID_WIDTH-1]                mas1_1_tid_d;
      wire [0:`PID_WIDTH-1]                mas1_1_tid_q;
      wire                                 mas1_1_ind_d;
      wire                                 mas1_1_ind_q;
      wire                                 mas1_1_ts_d;
      wire                                 mas1_1_ts_q;
      wire [0:3]                           mas1_1_tsize_d;
      wire [0:3]                           mas1_1_tsize_q;
      wire [64-`SPR_DATA_WIDTH:51]          mas2_1_epn_d;
      wire [64-`SPR_DATA_WIDTH:51]          mas2_1_epn_q;
      wire [0:4]                           mas2_1_wimge_d;
      wire [0:4]                           mas2_1_wimge_q;
      wire [32:52]                         mas3_1_rpnl_d;
      wire [32:52]                         mas3_1_rpnl_q;
      wire [0:3]                           mas3_1_ubits_d;
      wire [0:3]                           mas3_1_ubits_q;
      wire [0:5]                           mas3_1_usxwr_d;
      wire [0:5]                           mas3_1_usxwr_q;
      wire                                 mas4_1_indd_d;
      wire                                 mas4_1_indd_q;
      wire [0:3]                           mas4_1_tsized_d;
      wire [0:3]                           mas4_1_tsized_q;
      wire [0:4]                           mas4_1_wimged_d;
      wire [0:4]                           mas4_1_wimged_q;
      wire                                 mas5_1_sgs_d;
      wire                                 mas5_1_sgs_q;
      wire [0:7]                           mas5_1_slpid_d;
      wire [0:7]                           mas5_1_slpid_q;
      wire [0:13]                          mas6_1_spid_d;
      wire [0:13]                          mas6_1_spid_q;
      wire [0:3]                           mas6_1_isize_d;
      wire [0:3]                           mas6_1_isize_q;
      wire                                 mas6_1_sind_d;
      wire                                 mas6_1_sind_q;
      wire                                 mas6_1_sas_d;
      wire                                 mas6_1_sas_q;
      wire [22:31]                         mas7_1_rpnu_d;
      wire [22:31]                         mas7_1_rpnu_q;
      wire                                 mas8_1_tgs_d;
      wire                                 mas8_1_tgs_q;
      wire                                 mas8_1_vf_d;
      wire                                 mas8_1_vf_q;
      wire [0:7]                           mas8_1_tlpid_d;
      wire [0:7]                           mas8_1_tlpid_q;
`endif

      wire                                 mmucsr0_tlb0fi_d;
      wire                                 mmucsr0_tlb0fi_q;
      wire [64-`REAL_ADDR_WIDTH:51]        lper_0_alpn_d;
      wire [64-`REAL_ADDR_WIDTH:51]        lper_0_alpn_q;
      wire [60:63]                         lper_0_lps_d;
      wire [60:63]                         lper_0_lps_q;
`ifdef MM_THREADS2
      wire [64-`REAL_ADDR_WIDTH:51]        lper_1_alpn_d;
      wire [64-`REAL_ADDR_WIDTH:51]        lper_1_alpn_q;
      wire [60:63]                         lper_1_lps_d;
      wire [60:63]                         lper_1_lps_q;
`endif
      // timing nsl's
      wire [0:17]                          iu_mm_ierat_mmucr0_q;
      wire [0:`MM_THREADS-1]               iu_mm_ierat_mmucr0_we_q;
      wire [0:17]                          xu_mm_derat_mmucr0_q;
      wire [0:`MM_THREADS-1]               xu_mm_derat_mmucr0_we_q;
      wire [0:3]                           iu_mm_ierat_mmucr1_q;
      wire [0:`MM_THREADS-1]               iu_mm_ierat_mmucr1_we_d, iu_mm_ierat_mmucr1_we_q;
      wire [0:4]                           xu_mm_derat_mmucr1_q;
      wire [0:`MM_THREADS-1]               xu_mm_derat_mmucr1_we_d, xu_mm_derat_mmucr1_we_q;

     wire [0:`MM_THREADS-1]                tlb_mas_dtlb_error_upd;
     wire [0:`MM_THREADS-1]                tlb_mas_itlb_error_upd;
     wire [0:`MM_THREADS-1]                tlb_lper_we_upd;
     wire [0:`MM_THREADS-1]                tlb_mmucr1_we_upd;
     wire [0:`MM_THREADS-1]                iu_mm_ierat_mmucr1_we_upd;
     wire [0:`MM_THREADS-1]                xu_mm_derat_mmucr1_we_upd;
     wire                                  tlb_mas1_0_ts_error_upd;
     wire [0:`PID_WIDTH-1]                 tlb_mas1_0_tid_error_upd;
     wire [0:`EPN_WIDTH-1]                 tlb_mas2_0_epn_error_upd;
     wire [64-`REAL_ADDR_WIDTH:51]         tlb_lper_0_lpn_upd;
     wire [60:63]                          tlb_lper_0_lps_upd;
     wire [0:8]                            tlb_mmucr1_0_een_upd;
     wire [0:3]                            ierat_mmucr1_0_een_upd;
     wire [0:4]                            derat_mmucr1_0_een_upd;
`ifdef MM_THREADS2
     wire                                  tlb_mas1_1_ts_error_upd;
     wire [0:`PID_WIDTH-1]                 tlb_mas1_1_tid_error_upd;
     wire [0:`EPN_WIDTH-1]                 tlb_mas2_1_epn_error_upd;
     wire [64-`REAL_ADDR_WIDTH:51]         tlb_lper_1_lpn_upd;
     wire [60:63]                          tlb_lper_1_lps_upd;
     wire [0:8]                            tlb_mmucr1_1_een_upd;
     wire [0:3]                            ierat_mmucr1_1_een_upd;
     wire [0:4]                            derat_mmucr1_1_een_upd;
`endif

`ifdef WAIT_UPDATES
     wire [0:5]                            cp_mm_except_taken_t0_d, cp_mm_except_taken_t0_q;
     wire [0:`MM_THREADS-1]                tlb_mas_dtlb_error_pending_d, tlb_mas_dtlb_error_pending_q;
     wire [0:`MM_THREADS-1]                tlb_mas_itlb_error_pending_d, tlb_mas_itlb_error_pending_q;
     wire [0:`MM_THREADS-1]                tlb_lper_we_pending_d, tlb_lper_we_pending_q;
     wire [0:`MM_THREADS-1]                tlb_mmucr1_we_pending_d, tlb_mmucr1_we_pending_q;
     wire [0:`MM_THREADS-1]                ierat_mmucr1_we_pending_d, ierat_mmucr1_we_pending_q;
     wire [0:`MM_THREADS-1]                derat_mmucr1_we_pending_d, derat_mmucr1_we_pending_q;

     wire                                  tlb_mas1_0_ts_error_d, tlb_mas1_0_ts_error_q;
     wire [0:`PID_WIDTH-1]                 tlb_mas1_0_tid_error_d, tlb_mas1_0_tid_error_q;
     wire [0:`EPN_WIDTH-1]                 tlb_mas2_0_epn_error_d, tlb_mas2_0_epn_error_q;
     wire [64-`REAL_ADDR_WIDTH:51]         tlb_lper_0_lpn_d, tlb_lper_0_lpn_q;
     wire [60:63]                          tlb_lper_0_lps_d, tlb_lper_0_lps_q;
     wire [0:8]                            tlb_mmucr1_0_een_d, tlb_mmucr1_0_een_q;
     wire [0:3]                            ierat_mmucr1_0_een_d, ierat_mmucr1_0_een_q;
     wire [0:4]                            derat_mmucr1_0_een_d, derat_mmucr1_0_een_q;
`ifdef MM_THREADS2
     wire [0:5]                            cp_mm_except_taken_t1_d, cp_mm_except_taken_t1_q;
     wire                                  tlb_mas1_1_ts_error_d, tlb_mas1_1_ts_error_q;
     wire [0:`PID_WIDTH-1]                 tlb_mas1_1_tid_error_d, tlb_mas1_1_tid_error_q;
     wire [0:`EPN_WIDTH-1]                 tlb_mas2_1_epn_error_d, tlb_mas2_1_epn_error_q;
     wire [64-`REAL_ADDR_WIDTH:51]         tlb_lper_1_lpn_d, tlb_lper_1_lpn_q;
     wire [60:63]                          tlb_lper_1_lps_d, tlb_lper_1_lps_q;
     wire [0:8]                            tlb_mmucr1_1_een_d, tlb_mmucr1_1_een_q;
     wire [0:3]                            ierat_mmucr1_1_een_d, ierat_mmucr1_1_een_q;
     wire [0:4]                            derat_mmucr1_1_een_d, derat_mmucr1_1_een_q;
`endif
`endif

      wire [0:31]                          spare_a_q;
      wire [0:63]                          spare_b_q;

      (* analysis_not_referenced="true" *)
      wire [0:13]                          unused_dc;
      (* analysis_not_referenced="true" *)
      wire [`THREADS:3]                    unused_dc_threads;
      wire [0:45+(4*`MM_THREADS)-1]        tri_regk_unused_scan;

      // Pervasive
      wire                                 pc_sg_1;
      wire                                 pc_sg_0;
      wire                                 pc_fce_1;
      wire                                 pc_fce_0;
      wire                                 pc_func_sl_thold_1;
      wire                                 pc_func_sl_thold_0;
      wire                                 pc_func_sl_thold_0_b;
      wire                                 pc_func_slp_sl_thold_1;
      wire                                 pc_func_slp_sl_thold_0;
      wire                                 pc_func_slp_sl_thold_0_b;
      wire                                 pc_func_sl_force;
      wire                                 pc_func_slp_sl_force;
      wire                                 pc_cfg_sl_thold_1;
      wire                                 pc_cfg_sl_thold_0;
      wire                                 pc_cfg_slp_sl_force;
      wire                                 pc_cfg_slp_sl_thold_1;
      wire                                 pc_cfg_slp_sl_thold_0;
      wire                                 pc_cfg_slp_sl_thold_0_b;
      wire                                 pc_func_slp_nsl_thold_1;
      wire                                 pc_func_slp_nsl_thold_0;
      wire                                 pc_func_slp_nsl_thold_0_b;
      wire                                 pc_func_slp_nsl_force;

      //signal reset_alias         : std_ulogic;
      wire [0:scan_right_0]                siv_0;
      wire [0:scan_right_0]                sov_0;
      wire [0:scan_right_1]                siv_1;
      wire [0:scan_right_1]                sov_1;
      wire [0:boot_scan_right]             bsiv;
      wire [0:boot_scan_right]             bsov;
      wire [47:48]                         mmucfg_q;
      wire [45:47]                         tlb0cfg_q;
      wire [0:15]                          bcfg_spare_q;

      wire                                 pc_cfg_sl_thold_0_b;
      wire                                 pc_cfg_sl_force;
      wire                                 lcb_dclk;
      wire [0:`NCLK_WIDTH-1]               lcb_lclk;
      wire [47:48]                         mmucfg_q_b;
      wire [45:47]                         tlb0cfg_q_b;
      wire [0:15]                          bcfg_spare_q_b;

      wire [0:`MM_THREADS-1]               cat_emf_act_d;
      wire [0:`MM_THREADS-1]               cat_emf_act_q;
      wire [0:`MM_THREADS]                 spr_mmu_act_d;
      wire [0:`MM_THREADS]                 spr_mmu_act_q;
      wire [0:3]                           spr_val_act_d;
      wire [0:3]                           spr_val_act_q;
      wire                                 spr_val_act;
      wire                                 spr_match_act;
      wire                                 spr_match_mas_act;
      wire                                 spr_mas_data_out_act;
      wire [0:`MM_THREADS-1]               mas_update_pending_act;

      wire [0:3]                           cswitch_q;
      wire [0:`MM_THREADS-1]               cp_flush_d, cp_flush_q;
      wire [0:`MM_THREADS-1]               cp_flush_p1_d, cp_flush_p1_q;

      // array of 2 bit bin values
      wire [0:1]   bin_2bit   [0:3];
      wire                                 tidn;
      wire                                 tiup;

      //## figtree_source: mmq_spr.fig;
      //!! Bugspray Include: mmq_spr;

      assign tidn = 1'b0;
      assign tiup = 1'b1;
      assign bin_2bit[0] = 2'b00;
      assign bin_2bit[1] = 2'b01;
      assign bin_2bit[2] = 2'b10;
      assign bin_2bit[3] = 2'b11;

  genvar i;
  generate
    for (i=0; i<`MM_THREADS; i=i+1)
    begin : genacts
      assign cat_emf_act_d[i] = (spr_match_any_mmu & (spr_etid_in_q == bin_2bit[i])) | mmucr2_act_override[6] | (tlb_delayed_act[29+i] & xu_mm_ccr2_notlb_b);
      assign spr_mmu_act_d[i] = (spr_match_any_mmu & (spr_etid_in_q == bin_2bit[i])) | mmucr2_act_override[5];
    end
  endgenerate

      assign spr_mmu_act_d[`MM_THREADS] = spr_match_any_mmu | mmucr2_act_override[5];
      assign spr_val_act_d[0] = xu_mm_slowspr_val;
      assign spr_val_act_d[1] = spr_val_act_q[0];
      assign spr_val_act_d[2] = spr_val_act_q[1];
      assign spr_val_act_d[3] = spr_val_act_q[2];
      assign spr_val_act = spr_val_act_q[0] | spr_val_act_q[1] | spr_val_act_q[2] | spr_val_act_q[3] | mmucr2_act_override[5];
      assign spr_match_act = spr_val_act_q[0] | spr_val_act_q[1] | mmucr2_act_override[5];
      assign spr_match_mas_act = spr_val_act_q[0] | spr_val_act_q[1] | mmucr2_act_override[6];
      assign spr_mas_data_out_act = spr_val_act_q[0] | mmucr2_act_override[6];
`ifdef WAIT_UPDATES
      assign mas_update_pending_act = cat_emf_act_q | tlb_mas_dtlb_error_pending_q | tlb_mas_itlb_error_pending_q | tlb_lper_we_pending_q |
                                        tlb_mmucr1_we_pending_q | ierat_mmucr1_we_pending_q | derat_mmucr1_we_pending_q;
`else
      assign mas_update_pending_act = cat_emf_act_q;
`endif


      //---------------------------------------------------------------------
      // slow spr logic
      //---------------------------------------------------------------------
      // input latches for spr access
      assign spr_etid_onehot[0] = (xu_mm_slowspr_etid == 2'b00);
      assign spr_etid_onehot[1] = (xu_mm_slowspr_etid == 2'b01);
      assign spr_etid_onehot[2] = (xu_mm_slowspr_etid == 2'b10);
      assign spr_etid_onehot[3] = (xu_mm_slowspr_etid == 2'b11);
      assign spr_etid_in_onehot[0] = (spr_etid_in_q == 2'b00);
      assign spr_etid_in_onehot[1] = (spr_etid_in_q == 2'b01);
      assign spr_etid_in_onehot[2] = (spr_etid_in_q == 2'b10);
      assign spr_etid_in_onehot[3] = (spr_etid_in_q == 2'b11);
      assign spr_etid_int_onehot[0] = (spr_etid_int_q == 2'b00);
      assign spr_etid_int_onehot[1] = (spr_etid_int_q == 2'b01);
      assign spr_etid_int_onehot[2] = (spr_etid_int_q == 2'b10);
      assign spr_etid_int_onehot[3] = (spr_etid_int_q == 2'b11);

      generate
         begin : etid_generate
            genvar                               tid;
            for (tid = 0; tid <= 3; tid = tid + 1)
             begin : mmqsprflush
               if (tid < `THREADS)
               begin : mmqsprtidExist
                  assign spr_etid_flushed[tid] = cp_flush_q[tid] & spr_etid_onehot[tid];
                  assign spr_etid_in_flushed[tid] = cp_flush_q[tid] & spr_etid_in_onehot[tid];
                  assign spr_etid_int_flushed[tid] = cp_flush_q[tid] & spr_etid_int_onehot[tid];
               end
               if (tid >= `THREADS)
               begin : mmqsprtidNExist
                 assign spr_etid_flushed[tid] = 1'b0;
                 assign spr_etid_in_flushed[tid] = 1'b0;
                 assign spr_etid_int_flushed[tid] = 1'b0;
                 assign unused_dc_threads[tid] = spr_etid_onehot[tid] | spr_etid_in_onehot[tid] | spr_etid_int_onehot[tid];
               end
             end
         end
      endgenerate

`ifdef WAIT_UPDATES
      generate
         begin : mmq_spr_tid_generate
            genvar                                tid;
            for (tid = 0; tid <= `MM_THREADS-1; tid = tid + 1)
            begin : mmThreads
               if (tid < `THREADS)
               begin : tidExist
                  assign cp_flush_d[tid] = cp_flush[tid];
               end
               if (tid >= `THREADS)
               begin : tidNExist
                 assign cp_flush_d[tid] = tidn;
               end
            end
         end
      endgenerate
`endif

assign iu_mm_ierat_mmucr1_we_d = iu_mm_ierat_mmucr1_we;
assign xu_mm_derat_mmucr1_we_d = xu_mm_derat_mmucr1_we;

   // delay because cp_mm_except_taken bus lags cp_flush from completion by 1 cyc
      assign cp_flush_p1_d = cp_flush_q;
      assign cp_flush_p1 = cp_flush_p1_q;

   //masthdNExist : if `THDID_WIDTH >  (`MM_THREADS) generate begin
   //  masthdunused : for tid in  (`MM_THREADS) to (`THDID_WIDTH-1) generate begin
   //        unused_dc_thdid(tid)     <= lrat_mas_thdid(tid) or tlb_lper_we_upd(tid) or tlb_delayed_act(tid+29);
   //  end generate masthdunused;
   //end generate masthdNExist;
   assign spr_val_flushed = |(spr_etid_flushed);
   assign spr_val_in_flushed = |(spr_etid_in_flushed);
   assign spr_val_int_flushed = |(spr_etid_int_flushed);
   assign spr_ctl_in_d[0] = xu_mm_slowspr_val & (~(spr_val_flushed));
   assign spr_ctl_in_d[1] = xu_mm_slowspr_rw;
   assign spr_ctl_in_d[2] = xu_mm_slowspr_done;
   assign spr_etid_in_d = xu_mm_slowspr_etid;
   assign spr_addr_in_d = xu_mm_slowspr_addr;
   assign spr_addr_in_clone_d = xu_mm_slowspr_addr;
   assign spr_data_in_d = xu_mm_slowspr_data;
   // internal select latches for spr access
   assign spr_ctl_int_d[0] = spr_ctl_in_q[0] & (~(spr_val_in_flushed));
   assign spr_ctl_int_d[1:2] = spr_ctl_in_q[1:2];
   assign spr_etid_int_d = spr_etid_in_q;
   assign spr_addr_int_d = spr_addr_in_q;
   assign spr_data_int_d = spr_data_in_q;

   assign spr_match_any_mmu = ( spr_ctl_in_q[0] &
                                  ((spr_addr_in_q == Spr_Addr_PID) |
                                  (spr_addr_in_q == Spr_Addr_MMUCR0) | (spr_addr_in_q == Spr_Addr_MMUCR1) | (spr_addr_in_q == Spr_Addr_MMUCR2) | (spr_addr_in_q == Spr_Addr_MMUCR3) |
                                  (spr_addr_in_q == Spr_Addr_LPID) |
                                  (spr_addr_in_q == Spr_Addr_MESR1) | (spr_addr_in_q == Spr_Addr_MESR2) |
                                  (spr_addr_in_clone_q == Spr_Addr_MAS0) | (spr_addr_in_clone_q == Spr_Addr_MAS1) |
                                  (spr_addr_in_clone_q == Spr_Addr_MAS2) | (spr_addr_in_clone_q == Spr_Addr_MAS3) |
                                  (spr_addr_in_clone_q == Spr_Addr_MAS4) | (spr_addr_in_clone_q == Spr_Addr_MAS5) |
                                  (spr_addr_in_clone_q == Spr_Addr_MAS6) | (spr_addr_in_clone_q == Spr_Addr_MAS7) |
                                  (spr_addr_in_clone_q == Spr_Addr_MAS8) | (spr_addr_in_clone_q == Spr_Addr_MAS2U) |
                                  (spr_addr_in_clone_q == Spr_Addr_MAS01_64b) | (spr_addr_in_clone_q == Spr_Addr_MAS56_64b) |
                                  (spr_addr_in_clone_q == Spr_Addr_MAS73_64b) | (spr_addr_in_clone_q == Spr_Addr_MAS81_64b) |
                                  (spr_addr_in_clone_q == Spr_Addr_MMUCFG) | (spr_addr_in_clone_q == Spr_Addr_MMUCSR0) |
                                  (spr_addr_in_clone_q == Spr_Addr_TLB0CFG) | (spr_addr_in_clone_q == Spr_Addr_TLB0PS) |
                                  (spr_addr_in_clone_q == Spr_Addr_LRATCFG) | (spr_addr_in_clone_q == Spr_Addr_LRATPS) |
                                  (spr_addr_in_clone_q == Spr_Addr_EPTCFG) | (spr_addr_in_clone_q == Spr_Addr_LPER) |
                                  (spr_addr_in_clone_q == Spr_Addr_LPERU)) );

   assign spr_match_pid0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_q == Spr_Addr_PID));
   assign spr_match_mmucr0_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_q == Spr_Addr_MMUCR0));
   assign spr_match_mmucr3_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_q == Spr_Addr_MMUCR3));
`ifdef MM_THREADS2
   assign spr_match_pid1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_q == Spr_Addr_PID));
   assign spr_match_mmucr0_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_q == Spr_Addr_MMUCR0));
   assign spr_match_mmucr3_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_q == Spr_Addr_MMUCR3));
`endif
   assign spr_match_mmucr1 = (spr_ctl_in_q[0] & (spr_addr_in_q == Spr_Addr_MMUCR1));
   assign spr_match_mmucr2 = (spr_ctl_in_q[0] & (spr_addr_in_q == Spr_Addr_MMUCR2));
   assign spr_match_lpidr = (spr_ctl_in_q[0] & (spr_addr_in_q == Spr_Addr_LPID));
   assign spr_match_mesr1 = (spr_ctl_in_q[0] & (spr_addr_in_q == Spr_Addr_MESR1));
   assign spr_match_mesr2 = (spr_ctl_in_q[0] & (spr_addr_in_q == Spr_Addr_MESR2));
   assign spr_match_mmucsr0 = (spr_ctl_in_q[0] & (spr_addr_in_clone_q == Spr_Addr_MMUCSR0));
   assign spr_match_mmucfg = (spr_ctl_in_q[0] & (spr_addr_in_clone_q == Spr_Addr_MMUCFG));
   assign spr_match_tlb0cfg = (spr_ctl_in_q[0] & (spr_addr_in_clone_q == Spr_Addr_TLB0CFG));
   assign spr_match_tlb0ps = (spr_ctl_in_q[0] & (spr_addr_in_clone_q == Spr_Addr_TLB0PS));
   assign spr_match_lratcfg = (spr_ctl_in_q[0] & (spr_addr_in_clone_q == Spr_Addr_LRATCFG));
   assign spr_match_lratps = (spr_ctl_in_q[0] & (spr_addr_in_clone_q == Spr_Addr_LRATPS));
   assign spr_match_eptcfg = (spr_ctl_in_q[0] & (spr_addr_in_clone_q == Spr_Addr_EPTCFG));
   assign spr_match_lper_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_LPER));
   assign spr_match_lperu_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_LPERU));
`ifdef MM_THREADS2
   assign spr_match_lper_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_LPER));
   assign spr_match_lperu_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_LPERU));
`endif
   assign spr_match_any_mas = (spr_ctl_in_q[0] & ((spr_addr_in_clone_q == Spr_Addr_MAS0) | (spr_addr_in_clone_q == Spr_Addr_MAS1) | (spr_addr_in_clone_q == Spr_Addr_MAS2) | (spr_addr_in_clone_q == Spr_Addr_MAS2U) | (spr_addr_in_clone_q == Spr_Addr_MAS3) | (spr_addr_in_clone_q == Spr_Addr_MAS4) | (spr_addr_in_clone_q == Spr_Addr_MAS5) | (spr_addr_in_clone_q == Spr_Addr_MAS6) | (spr_addr_in_clone_q == Spr_Addr_MAS7) | (spr_addr_in_clone_q == Spr_Addr_MAS8) | (spr_addr_in_clone_q == Spr_Addr_MAS01_64b) | (spr_addr_in_clone_q == Spr_Addr_MAS56_64b) | (spr_addr_in_clone_q == Spr_Addr_MAS73_64b) | (spr_addr_in_clone_q == Spr_Addr_MAS81_64b)));
   assign spr_match_mas0_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_MAS0));
   assign spr_match_mas1_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_MAS1));
   assign spr_match_mas2_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_MAS2));
   assign spr_match_mas2u_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_MAS2U));
   assign spr_match_mas3_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_MAS3));
   assign spr_match_mas4_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_MAS4));
   assign spr_match_mas5_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_MAS5));
   assign spr_match_mas6_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_MAS6));
   assign spr_match_mas7_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_MAS7));
   assign spr_match_mas8_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_MAS8));
   assign spr_match_mas01_64b_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_MAS01_64b));
   assign spr_match_mas56_64b_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_MAS56_64b));
   assign spr_match_mas73_64b_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_MAS73_64b));
   assign spr_match_mas81_64b_0 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b00) & (spr_addr_in_clone_q == Spr_Addr_MAS81_64b));
`ifdef MM_THREADS2
   assign spr_match_mas0_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_MAS0));
   assign spr_match_mas1_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_MAS1));
   assign spr_match_mas2_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_MAS2));
   assign spr_match_mas2u_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_MAS2U));
   assign spr_match_mas3_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_MAS3));
   assign spr_match_mas4_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_MAS4));
   assign spr_match_mas5_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_MAS5));
   assign spr_match_mas6_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_MAS6));
   assign spr_match_mas7_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_MAS7));
   assign spr_match_mas8_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_MAS8));
   assign spr_match_mas01_64b_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_MAS01_64b));
   assign spr_match_mas56_64b_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_MAS56_64b));
   assign spr_match_mas73_64b_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_MAS73_64b));
   assign spr_match_mas81_64b_1 = (spr_ctl_in_q[0] & (spr_etid_in_q == 2'b01) & (spr_addr_in_clone_q == Spr_Addr_MAS81_64b));
`endif
   assign spr_match_mas2_64b = (spr_ctl_in_q[0] & (spr_addr_in_clone_q == Spr_Addr_MAS2));
   assign spr_match_mas01_64b = (spr_ctl_in_q[0] & (spr_addr_in_clone_q == Spr_Addr_MAS01_64b));
   assign spr_match_mas56_64b = (spr_ctl_in_q[0] & (spr_addr_in_clone_q == Spr_Addr_MAS56_64b));
   assign spr_match_mas73_64b = (spr_ctl_in_q[0] & (spr_addr_in_clone_q == Spr_Addr_MAS73_64b));
   assign spr_match_mas81_64b = (spr_ctl_in_q[0] & (spr_addr_in_clone_q == Spr_Addr_MAS81_64b));
   assign spr_match_64b = spr_match_mas2_64b | spr_match_mas01_64b | spr_match_mas56_64b | spr_match_mas73_64b | spr_match_mas81_64b;


   assign pid0_d = ((spr_match_pid0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[64 - `PID_WIDTH:63] :
                   pid0_q;
`ifdef MM_THREADS2
   assign pid1_d = ((spr_match_pid1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[64 - `PID_WIDTH:63] :
                   pid1_q;
`endif
   // mmucr0: 0-ExtClass, 1-TID_NZ, 2:3-GS/TS, 4:5-TLBSel, 6:19-TID
   assign mmucr0_0_d = ((spr_match_mmucr0_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? {spr_data_int_q[32], |(spr_data_int_q[50:63]), spr_data_int_q[34:37], spr_data_int_q[50:63]} :
                       (xu_mm_derat_mmucr0_we_q[0] == 1'b1 & mmucr1_q[14:15] == 2'b01) ? {xu_mm_derat_mmucr0_q[0:3], 2'b11, mmucr0_0_q[6:7], xu_mm_derat_mmucr0_q[6:17]} :
                       (xu_mm_derat_mmucr0_we_q[0] == 1'b1 & mmucr1_q[14:15] == 2'b10) ? {xu_mm_derat_mmucr0_q[0:3], 2'b11, xu_mm_derat_mmucr0_q[4:5], mmucr0_0_q[8:11], xu_mm_derat_mmucr0_q[10:17]} :
                       (xu_mm_derat_mmucr0_we_q[0] == 1'b1 & mmucr1_q[14:15] == 2'b11) ? {xu_mm_derat_mmucr0_q[0:3], 2'b11, xu_mm_derat_mmucr0_q[4:17]} :
                       (xu_mm_derat_mmucr0_we_q[0] == 1'b1) ? {xu_mm_derat_mmucr0_q[0:3], 2'b11, mmucr0_0_q[6:11], xu_mm_derat_mmucr0_q[10:17]} :
                       (iu_mm_ierat_mmucr0_we_q[0] == 1'b1 & mmucr1_q[12:13] == 2'b01) ? {iu_mm_ierat_mmucr0_q[0:3], 2'b11, mmucr0_0_q[6:7], iu_mm_ierat_mmucr0_q[6:17]} :
                       (iu_mm_ierat_mmucr0_we_q[0] == 1'b1 & mmucr1_q[12:13] == 2'b10) ? {iu_mm_ierat_mmucr0_q[0:3], 2'b11, iu_mm_ierat_mmucr0_q[4:5], mmucr0_0_q[8:11], iu_mm_ierat_mmucr0_q[10:17]} :
                       (iu_mm_ierat_mmucr0_we_q[0] == 1'b1 & mmucr1_q[12:13] == 2'b11) ? {iu_mm_ierat_mmucr0_q[0:3], 2'b11, iu_mm_ierat_mmucr0_q[4:17]} :
                       (iu_mm_ierat_mmucr0_we_q[0] == 1'b1) ? {iu_mm_ierat_mmucr0_q[0:3], 2'b10, mmucr0_0_q[6:11], iu_mm_ierat_mmucr0_q[10:17]} :
                       mmucr0_0_q;
`ifdef MM_THREADS2
   assign mmucr0_1_d = ((spr_match_mmucr0_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? {spr_data_int_q[32], |(spr_data_int_q[50:63]), spr_data_int_q[34:37], spr_data_int_q[50:63]} :
                       (xu_mm_derat_mmucr0_we_q[1] == 1'b1 & mmucr1_q[14:15] == 2'b01) ? {xu_mm_derat_mmucr0_q[0:3], 2'b11, mmucr0_1_q[6:7], xu_mm_derat_mmucr0_q[6:17]} :
                       (xu_mm_derat_mmucr0_we_q[1] == 1'b1 & mmucr1_q[14:15] == 2'b10) ? {xu_mm_derat_mmucr0_q[0:3], 2'b11, xu_mm_derat_mmucr0_q[4:5], mmucr0_1_q[8:11], xu_mm_derat_mmucr0_q[10:17]} :
                       (xu_mm_derat_mmucr0_we_q[1] == 1'b1 & mmucr1_q[14:15] == 2'b11) ? {xu_mm_derat_mmucr0_q[0:3], 2'b11, xu_mm_derat_mmucr0_q[4:17]} :
                       (xu_mm_derat_mmucr0_we_q[1] == 1'b1) ? {xu_mm_derat_mmucr0_q[0:3], 2'b11, mmucr0_1_q[6:11], xu_mm_derat_mmucr0_q[10:17]} :
                       (iu_mm_ierat_mmucr0_we_q[1] == 1'b1 & mmucr1_q[12:13] == 2'b01) ? {iu_mm_ierat_mmucr0_q[0:3], 2'b11, mmucr0_1_q[6:7], iu_mm_ierat_mmucr0_q[6:17]} :
                       (iu_mm_ierat_mmucr0_we_q[1] == 1'b1 & mmucr1_q[12:13] == 2'b10) ? {iu_mm_ierat_mmucr0_q[0:3], 2'b11, iu_mm_ierat_mmucr0_q[4:5], mmucr0_1_q[8:11], iu_mm_ierat_mmucr0_q[10:17]} :
                       (iu_mm_ierat_mmucr0_we_q[1] == 1'b1 & mmucr1_q[12:13] == 2'b11) ? {iu_mm_ierat_mmucr0_q[0:3], 2'b11, iu_mm_ierat_mmucr0_q[4:17]} :
                       (iu_mm_ierat_mmucr0_we_q[1] == 1'b1) ? {iu_mm_ierat_mmucr0_q[0:3], 2'b10, mmucr0_1_q[6:11], iu_mm_ierat_mmucr0_q[10:17]} :
                       mmucr0_1_q;
`endif

   // mmucr1: 0-IRRE, 1-DRRE, 2-REE, 3-CEE,
   //         4-Disable any context sync inst from invalidating extclass=0 erat entries,
   //         5-Disable isync inst from invalidating extclass=0 erat entries,
   //         6:7-IPEI, 8:9-DPEI, 10:11-TPEI, 12:13-ICTID/ITTID, 14:15-DCTID/DTTID,
   //         16-DCCD, 17-TLBWE_BINV, 18-TLBI_MSB, 19-TLBI_REJ,
   //         20-IERRDET, 21-DERRDET, 22-TERRDET, 23:31-EEN
   //    2) mmucr1: merge EEN bits into single field, seperate I/D/T ERRDET bits
   //    3) mmucr1: add ICTID, ITTID, DCTID, DTTID, TLBI_REJ, and TLBI_MSB bits
   assign mmucr1_d[0:16] = ((spr_match_mmucr1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32:48] :
                           mmucr1_q[0:16];
   assign mmucr1_d[17] = ((spr_match_mmucr1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? (spr_data_int_q[49] & (~cswitch_q[1])) :
                         mmucr1_q[17];
   assign mmucr1_d[18:19] = ((spr_match_mmucr1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[50:51] :
                            mmucr1_q[18:19];
   // added cswitch0 to prevent side effect of clearing on read
   assign mmucr1_d[20] = ((spr_match_mmucr1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Read & cswitch_q[0] == 1'b0)) ? 1'b0 :
                         ((spr_match_mmucr1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write & cswitch_q[0] == 1'b1)) ? spr_data_int_q[52] :
                         ((|(iu_mm_ierat_mmucr1_we_upd) == 1'b1 & |(xu_mm_derat_mmucr1_we_upd) == 1'b0 & |(tlb_mmucr1_we_upd) == 1'b0 & mmucr1_q[20:22] == 3'b000)) ? 1'b1 :
                         mmucr1_q[20];
   assign mmucr1_d[21] = ((spr_match_mmucr1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Read & cswitch_q[0] == 1'b0)) ? 1'b0 :
                         ((spr_match_mmucr1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write & cswitch_q[0] == 1'b1)) ? spr_data_int_q[53] :
                         ((|(xu_mm_derat_mmucr1_we_upd) == 1'b1 & |(tlb_mmucr1_we_upd) == 1'b0 & mmucr1_q[20:22] == 3'b000)) ? 1'b1 :
                         mmucr1_q[21];
   assign mmucr1_d[22] = ((spr_match_mmucr1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Read & cswitch_q[0] == 1'b0)) ? 1'b0 :
                         ((spr_match_mmucr1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write & cswitch_q[0] == 1'b1)) ? spr_data_int_q[54] :
                         ((|(tlb_mmucr1_we_upd) == 1'b1 & mmucr1_q[20:22] == 3'b000)) ? 1'b1 :
                         mmucr1_q[22];
   assign mmucr1_d[23:31] = ((spr_match_mmucr1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Read & cswitch_q[0] == 1'b0)) ? {9{1'b0}} :
                            ((spr_match_mmucr1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write & cswitch_q[0] == 1'b1)) ? spr_data_int_q[55:63] :
                            ((tlb_mmucr1_we_upd[0] == 1'b1 & mmucr1_q[20:22] == 3'b000)) ? tlb_mmucr1_0_een_upd :
`ifdef MM_THREADS2
                            ((tlb_mmucr1_we_upd[1] == 1'b1 & mmucr1_q[20:22] == 3'b000)) ? tlb_mmucr1_1_een_upd :
`endif
                            ((xu_mm_derat_mmucr1_we_upd[0] == 1'b1 & mmucr1_q[20:22] == 3'b000)) ? {4'b0000, derat_mmucr1_0_een_upd} :
`ifdef MM_THREADS2
                            ((xu_mm_derat_mmucr1_we_upd[1] == 1'b1 & mmucr1_q[20:22] == 3'b000)) ? {4'b0000, derat_mmucr1_1_een_upd} :
`endif
                            ((iu_mm_ierat_mmucr1_we_upd[0] == 1'b1 & mmucr1_q[20:22] == 3'b000)) ? {5'b00000, ierat_mmucr1_0_een_upd} :
`ifdef MM_THREADS2
                            ((iu_mm_ierat_mmucr1_we_upd[1] == 1'b1 & mmucr1_q[20:22] == 3'b000)) ? {5'b00000, ierat_mmucr1_1_een_upd} :
`endif
                            mmucr1_q[23:31];

   // mmucr2:
   assign mmucr2_d[0:31] = ((spr_match_mmucr2_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32:63] :
                           mmucr2_q[0:31];

   // mmucr3:
   assign mmucr3_0_d = ((spr_match_mmucr3_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? { spr_data_int_q[64 - `MMUCR3_WIDTH:59+`MM_THREADS], {`THDID_WIDTH-`MM_THREADS{1'b0}} } :
                       (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? { tlb_mmucr3_x, tlb_mmucr3_rc, tlb_mmucr3_extclass, tlb_mmucr3_class, tlb_mmucr3_wlc, tlb_mmucr3_resvattr, 1'b0, tlb_mmucr3_thdid[0:`MM_THREADS-1], {`THDID_WIDTH-`MM_THREADS{1'b0}} } :
                       (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? { lrat_mmucr3_x, 2'b00, 1'b0, 1'b0, 2'b00, 2'b00, 1'b0, 1'b0, {`MM_THREADS{1'b1}}, {`THDID_WIDTH-`MM_THREADS{1'b0}} } :
                       mmucr3_0_q;

   assign tstmode4k_0_d[0] = ((spr_match_mmucr3_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write & spr_data_int_q[32:47] == TSTMODE4KCONST1 )) ? 1'b1 :
                               ((spr_match_mmucr3_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write )) ? 1'b0 :
                       tstmode4k_0_q[0];

   assign tstmode4k_0_d[1] = ((spr_match_mmucr3_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write & tstmode4k_0_q[0] == 1'b1 & spr_data_int_q[32:43] == TSTMODE4KCONST2 )) ? 1'b1 :
                               ((spr_match_mmucr3_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write )) ? 1'b0 :
                       tstmode4k_0_q[1];

   assign tstmode4k_0_d[2:3] = ((spr_match_mmucr3_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write & tstmode4k_0_q[0] == 1'b1 & spr_data_int_q[32:43] == TSTMODE4KCONST2 )) ?  spr_data_int_q[46:47]:
                                 ((spr_match_mmucr3_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write )) ? 2'b00 :
                       tstmode4k_0_q[2:3];


`ifdef MM_THREADS2
   assign mmucr3_1_d = ((spr_match_mmucr3_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? { spr_data_int_q[64 - `MMUCR3_WIDTH:59+`MM_THREADS], {`THDID_WIDTH-`MM_THREADS{1'b0}} } :
                       (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? { tlb_mmucr3_x, tlb_mmucr3_rc, tlb_mmucr3_extclass, tlb_mmucr3_class, tlb_mmucr3_wlc, tlb_mmucr3_resvattr, 1'b0, tlb_mmucr3_thdid[0:`MM_THREADS-1], {`THDID_WIDTH-`MM_THREADS{1'b0}} } :
                       (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? { lrat_mmucr3_x, 2'b00, 1'b0, 1'b0, 2'b00, 2'b00, 1'b0, 1'b0, {`MM_THREADS{1'b1}}, {`THDID_WIDTH-`MM_THREADS{1'b0}} } :
                       mmucr3_1_q;

   assign tstmode4k_1_d[0] = ((spr_match_mmucr3_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write & spr_data_int_q[32:47] == TSTMODE4KCONST1 )) ? 1'b1 :
                               ((spr_match_mmucr3_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write )) ? 1'b0 :
                       tstmode4k_1_q[0];

   assign tstmode4k_1_d[1] = ((spr_match_mmucr3_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write & tstmode4k_1_q[0] == 1'b1 & spr_data_int_q[32:43] == TSTMODE4KCONST2 )) ? 1'b1 :
                               ((spr_match_mmucr3_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write )) ? 1'b0 :
                       tstmode4k_1_q[1];

   assign tstmode4k_1_d[2:3] = ((spr_match_mmucr3_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write & tstmode4k_1_q[0] == 1'b1 & spr_data_int_q[32:43] == TSTMODE4KCONST2 )) ?  spr_data_int_q[46:47]:
                                 ((spr_match_mmucr3_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write )) ? 2'b00 :
                       tstmode4k_1_q[2:3];

 `endif

   assign lpidr_d = ((spr_match_lpidr_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[64 - `LPID_WIDTH:63] :
                    lpidr_q;

   // Perf event select registers
   // Each field controls selection of 1 of 64 events per event bus bit
   // mesr1:  32:37 - MUXSELEB0,
   //         38:43 - MUXSELEB1,
   //         44:49 - MUXSELEB2,
   //         50:55 - MUXSELEB3
   // mesr2:  32:37 - MUXSELEB4,
   //         38:43 - MUXSELEB5,
   //         44:49 - MUXSELEB6,
   //         50:55 - MUXSELEB7
   assign mesr1_d[32:32 + `MESR1_WIDTH - 1] = ((spr_match_mesr1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32:32 + `MESR1_WIDTH - 1] :
                                             mesr1_q[32:32 + `MESR1_WIDTH - 1];
   assign mesr2_d[32:32 + `MESR2_WIDTH - 1] = ((spr_match_mesr2_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32:32 + `MESR2_WIDTH - 1] :
                                             mesr2_q[32:32 + `MESR2_WIDTH - 1];

   assign mmucsr0_tlb0fi_d = ((mmucsr0_tlb0fi_q == 1'b0 & spr_match_mmucsr0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write & spr_data_int_q[61] == 1'b1)) ? 1'b1 :
                             (mmq_inval_tlb0fi_done == 1'b1) ? 1'b0 :
                             mmucsr0_tlb0fi_q;


`ifdef WAIT_UPDATES
   // cp_mm_except_taken_t0_q
   // 0   - val
   // 1   - I=0/D=1
   // 2   - TLB miss
   // 3   - Storage int (TLBI/PTfault)
   // 4   - LRAT miss
   // 5   - Mcheck

     assign cp_mm_except_taken_t0_d = cp_mm_except_taken_t0;

     assign tlb_mas_dtlb_error_upd[0]    = tlb_mas_dtlb_error_pending_q[0] & cp_mm_except_taken_t0_q[0] & {1{cp_mm_except_taken_t0_q[1:5] == 5'b11000}}; // dtlb miss except taken
     assign tlb_mas_itlb_error_upd[0]    = tlb_mas_itlb_error_pending_q[0] & cp_mm_except_taken_t0_q[0] & {1{cp_mm_except_taken_t0_q[1:5] == 5'b01000}}; // itlb miss except taken
     assign tlb_lper_we_upd[0]           = tlb_lper_we_pending_q[0] & cp_mm_except_taken_t0_q[0] & {1{cp_mm_except_taken_t0_q[2:5] == 4'b0010}};       // lrat error except taken
     assign tlb_mmucr1_we_upd[0]         = tlb_mmucr1_we_pending_q[0] & cp_mm_except_taken_t0_q[0] & {1{cp_mm_except_taken_t0_q[2:5] == 4'b0001}};     // tlb mcheck except taken
     assign iu_mm_ierat_mmucr1_we_upd[0] = ierat_mmucr1_we_pending_q[0] & cp_mm_except_taken_t0_q[0] & {1{cp_mm_except_taken_t0_q[2:5] == 4'b0001}};   // ierat mcheck except taken
     assign xu_mm_derat_mmucr1_we_upd[0] = derat_mmucr1_we_pending_q[0] & cp_mm_except_taken_t0_q[0] & {1{cp_mm_except_taken_t0_q[2:5] == 4'b0001}};   // derat mcheck except taken

     assign tlb_mas_dtlb_error_pending_d[0] = (tlb_mas_dtlb_error_pending_q[0] == 1'b1 & cp_mm_except_taken_t0_q[0] == 1'b1 & cp_mm_except_taken_t0_q[1:5] == 5'b11000  ) ? 1'b0 :
                                                (tlb_mas_dtlb_error_pending_q[0] == 1'b1 & cp_flush_p1_q[0] == 1'b1) ? 1'b0 :
                                                (tlb_mas_dtlb_error_pending_q[0] == 1'b0 & tlb_mas_dtlb_error == 1'b1 & tlb_mas_thdid[0] == 1'b1) ? 1'b1 :
                                                    tlb_mas_dtlb_error_pending_q[0];

     assign tlb_mas_itlb_error_pending_d[0] = (tlb_mas_itlb_error_pending_q[0] == 1'b1 & cp_mm_except_taken_t0_q[0] == 1'b1 & cp_mm_except_taken_t0_q[1:5] == 5'b01000  ) ? 1'b0 :
                                                (tlb_mas_itlb_error_pending_q[0] == 1'b1 & cp_flush_p1_q[0] == 1'b1) ? 1'b0 :
                                                (tlb_mas_itlb_error_pending_q[0] == 1'b0 & tlb_mas_itlb_error == 1'b1 & tlb_mas_thdid[0] == 1'b1) ? 1'b1 :
                                                    tlb_mas_itlb_error_pending_q[0];

     assign tlb_lper_we_pending_d[0] = (tlb_lper_we_pending_q[0] == 1'b1 & cp_mm_except_taken_t0_q[0] == 1'b1 & cp_mm_except_taken_t0_q[2:5] == 4'b0010  ) ? 1'b0 :
                                                (tlb_lper_we_pending_q[0] == 1'b1 & cp_flush_p1_q[0] == 1'b1) ? 1'b0 :
                                                (tlb_lper_we_pending_q[0] == 1'b0 & tlb_lper_we[0] == 1'b1) ? 1'b1 :
                                                    tlb_lper_we_pending_q[0];

     assign tlb_mmucr1_we_pending_d[0] = (tlb_mmucr1_we_pending_q[0] == 1'b1 & cp_mm_except_taken_t0_q[0] == 1'b1 & cp_mm_except_taken_t0_q[2:5] == 4'b0001  ) ? 1'b0 :
                                                (tlb_mmucr1_we_pending_q[0] == 1'b1 & cp_flush_p1_q[0] == 1'b1) ? 1'b0 :
                                                (tlb_mmucr1_we_pending_q[0] == 1'b0 & tlb_mmucr1_we == 1'b1 & tlb_mas_thdid[0] == 1'b1) ? 1'b1 :
                                                    tlb_mmucr1_we_pending_q[0];

     assign ierat_mmucr1_we_pending_d[0] = (ierat_mmucr1_we_pending_q[0] == 1'b1 & cp_mm_except_taken_t0_q[0] == 1'b1 & cp_mm_except_taken_t0_q[2:5] == 4'b0001  ) ? 1'b0 :
                                                     (ierat_mmucr1_we_pending_q[0] == 1'b1 & cp_flush_p1_q[0] == 1'b1) ? 1'b0 :
                                                     (ierat_mmucr1_we_pending_q[0] == 1'b0 & iu_mm_ierat_mmucr1_we_q[0] == 1'b1) ? 1'b1 :
                                                       ierat_mmucr1_we_pending_q[0];

     assign derat_mmucr1_we_pending_d[0] = (derat_mmucr1_we_pending_q[0] == 1'b1 & cp_mm_except_taken_t0_q[0] == 1'b1 & cp_mm_except_taken_t0_q[2:5] == 4'b0001  ) ? 1'b0 :
                                                     (derat_mmucr1_we_pending_q[0] == 1'b1 & cp_flush_p1_q[0] == 1'b1) ? 1'b0 :
                                                     (derat_mmucr1_we_pending_q[0] == 1'b0 & xu_mm_derat_mmucr1_we_q[0] == 1'b1) ? 1'b1 :
                                                       derat_mmucr1_we_pending_q[0];


     assign tlb_mas1_0_ts_error_d = ((tlb_mas_dtlb_error == 1'b1 | tlb_mas_itlb_error == 1'b1) & tlb_mas_thdid[0] == 1'b1) ? tlb_mas1_ts_error :
                                         tlb_mas1_0_ts_error_q;
     assign tlb_mas1_0_tid_error_d = ((tlb_mas_dtlb_error == 1'b1 | tlb_mas_itlb_error == 1'b1) & tlb_mas_thdid[0] == 1'b1) ? tlb_mas1_tid_error :
                                         tlb_mas1_0_tid_error_q;
     assign tlb_mas2_0_epn_error_d = ((tlb_mas_dtlb_error == 1'b1 | tlb_mas_itlb_error == 1'b1) & tlb_mas_thdid[0] == 1'b1) ? tlb_mas2_epn_error :
                                         tlb_mas2_0_epn_error_q;
     assign tlb_lper_0_lpn_d = (tlb_lper_we[0] == 1'b1) ? tlb_lper_lpn :
                                     tlb_lper_0_lpn_q;
     assign tlb_lper_0_lps_d = (tlb_lper_we[0] == 1'b1) ? tlb_lper_lps :
                                     tlb_lper_0_lps_q;

     assign tlb_mmucr1_0_een_d = (tlb_mmucr1_we_pending_q[0] == 1'b0 & tlb_mmucr1_we == 1'b1 & tlb_mas_thdid[0] == 1'b1) ? tlb_mmucr1_een :
                                     tlb_mmucr1_0_een_q;

     assign ierat_mmucr1_0_een_d = (ierat_mmucr1_we_pending_q[0] == 1'b0 & iu_mm_ierat_mmucr1_we_q[0] == 1'b1) ? iu_mm_ierat_mmucr1_q :
                                       ierat_mmucr1_0_een_q;

     assign derat_mmucr1_0_een_d = (derat_mmucr1_we_pending_q[0] == 1'b0 & xu_mm_derat_mmucr1_we_q[0] == 1'b1) ? xu_mm_derat_mmucr1_q :
                                       derat_mmucr1_0_een_q;


     assign tlb_mas1_0_ts_error_upd = tlb_mas1_0_ts_error_q;
     assign tlb_mas1_0_tid_error_upd = tlb_mas1_0_tid_error_q;
     assign tlb_mas2_0_epn_error_upd = tlb_mas2_0_epn_error_q;
     assign tlb_lper_0_lpn_upd = tlb_lper_0_lpn_q;
     assign tlb_lper_0_lps_upd = tlb_lper_0_lps_q;
     assign tlb_mmucr1_0_een_upd = tlb_mmucr1_0_een_q;
     assign ierat_mmucr1_0_een_upd = ierat_mmucr1_0_een_q;
     assign derat_mmucr1_0_een_upd = derat_mmucr1_0_een_q;

`ifdef MM_THREADS2
   // cp_mm_except_taken_t1_q
   // 0   - val
   // 1   - I=0/D=1
   // 2   - TLB miss
   // 3   - Storage int (TLBI/PTfault)
   // 4   - LRAT miss
   // 5   - Mcheck
     assign cp_mm_except_taken_t1_d = cp_mm_except_taken_t1;

     assign tlb_mas_dtlb_error_upd[1]    = tlb_mas_dtlb_error_pending_q[1] & cp_mm_except_taken_t1_q[0] & {1{cp_mm_except_taken_t1_q[1:5] == 5'b11000}}; // dtlb miss except taken
     assign tlb_mas_itlb_error_upd[1]    = tlb_mas_itlb_error_pending_q[1] & cp_mm_except_taken_t1_q[0] & {1{cp_mm_except_taken_t1_q[1:5] == 5'b01000}}; // itlb miss except taken
     assign tlb_lper_we_upd[1]           = tlb_lper_we_pending_q[1] & cp_mm_except_taken_t1_q[0] & {1{cp_mm_except_taken_t1_q[2:5] == 4'b0010}};       // lrat error except taken
     assign tlb_mmucr1_we_upd[1]         = tlb_mmucr1_we_pending_q[1] & cp_mm_except_taken_t1_q[0] & {1{cp_mm_except_taken_t1_q[2:5] == 4'b0001}};     // tlb mcheck except taken
     assign iu_mm_ierat_mmucr1_we_upd[1] = ierat_mmucr1_we_pending_q[1] & cp_mm_except_taken_t1_q[0] & {1{cp_mm_except_taken_t1_q[2:5] == 4'b0001}};   // ierat mcheck except taken
     assign xu_mm_derat_mmucr1_we_upd[1] = derat_mmucr1_we_pending_q[1] & cp_mm_except_taken_t1_q[0] & {1{cp_mm_except_taken_t1_q[2:5] == 4'b0001}};   // derat mcheck except taken

      assign tlb_mas_dtlb_error_pending_d[1] = (tlb_mas_dtlb_error_pending_q[1] == 1'b1 & cp_mm_except_taken_t1_q[0] == 1'b1 & cp_mm_except_taken_t1_q[1:5] == 5'b11000  ) ? 1'b0 :
                                                (tlb_mas_dtlb_error_pending_q[1] == 1'b1 & cp_flush_p1_q[1] == 1'b1) ? 1'b0 :
                                                (tlb_mas_dtlb_error_pending_q[1] == 1'b0 & tlb_mas_dtlb_error == 1'b1 & tlb_mas_thdid[1] == 1'b1) ? 1'b1 :
                                                    tlb_mas_dtlb_error_pending_q[1];

     assign tlb_mas_itlb_error_pending_d[1] = (tlb_mas_itlb_error_pending_q[1] == 1'b1 & cp_mm_except_taken_t1_q[0] == 1'b1 & cp_mm_except_taken_t1_q[1:5] == 5'b01000  ) ? 1'b0 :
                                                (tlb_mas_itlb_error_pending_q[1] == 1'b1 & cp_flush_p1_q[1] == 1'b1) ? 1'b0 :
                                                (tlb_mas_itlb_error_pending_q[1] == 1'b0 & tlb_mas_itlb_error == 1'b1 & tlb_mas_thdid[1] == 1'b1) ? 1'b1 :
                                                    tlb_mas_itlb_error_pending_q[1];

     assign tlb_lper_we_pending_d[1] = (tlb_lper_we_pending_q[1] == 1'b1 & cp_mm_except_taken_t1_q[0] == 1'b1 & cp_mm_except_taken_t1_q[2:5] == 4'b0010  ) ? 1'b0 :
                                                (tlb_lper_we_pending_q[1] == 1'b1 & cp_flush_p1_q[1] == 1'b1) ? 1'b0 :
                                                (tlb_lper_we_pending_q[1] == 1'b0 & tlb_lper_we[1] == 1'b1) ? 1'b1 :
                                                    tlb_lper_we_pending_q[1];

     assign tlb_mmucr1_we_pending_d[1] = (tlb_mmucr1_we_pending_q[1] == 1'b1 & cp_mm_except_taken_t1_q[0] == 1'b1 & cp_mm_except_taken_t1_q[2:5] == 4'b0001  ) ? 1'b0 :
                                                (tlb_mmucr1_we_pending_q[1] == 1'b1 & cp_flush_p1_q[1] == 1'b1) ? 1'b0 :
                                                (tlb_mmucr1_we_pending_q[1] == 1'b0 & tlb_mmucr1_we == 1'b1 & tlb_mas_thdid[1] == 1'b1) ? 1'b1 :
                                                    tlb_mmucr1_we_pending_q[1];

     assign ierat_mmucr1_we_pending_d[1] = (ierat_mmucr1_we_pending_q[1] == 1'b1 & cp_mm_except_taken_t1_q[0] == 1'b1 & cp_mm_except_taken_t1_q[2:5] == 4'b0001  ) ? 1'b0 :
                                                     (ierat_mmucr1_we_pending_q[1] == 1'b1 & cp_flush_p1_q[1] == 1'b1) ? 1'b0 :
                                                     (ierat_mmucr1_we_pending_q[1] == 1'b0 & iu_mm_ierat_mmucr1_we_q[1] == 1'b1) ? 1'b1 :
                                                       ierat_mmucr1_we_pending_q[1];

     assign derat_mmucr1_we_pending_d[1] = (derat_mmucr1_we_pending_q[1] == 1'b1 & cp_mm_except_taken_t1_q[1] == 1'b1 & cp_mm_except_taken_t1_q[2:5] == 4'b0001  ) ? 1'b0 :
                                                     (derat_mmucr1_we_pending_q[1] == 1'b1 & cp_flush_p1_q[1] == 1'b1) ? 1'b0 :
                                                     (derat_mmucr1_we_pending_q[1] == 1'b0 & xu_mm_derat_mmucr1_we_q[1] == 1'b1) ? 1'b1 :
                                                       derat_mmucr1_we_pending_q[1];

     assign tlb_mas1_1_ts_error_d = ((tlb_mas_dtlb_error == 1'b1 | tlb_mas_itlb_error == 1'b1) & tlb_mas_thdid[1] == 1'b1) ? tlb_mas1_ts_error :
                                         tlb_mas1_1_ts_error_q;
     assign tlb_mas1_1_tid_error_d = ((tlb_mas_dtlb_error == 1'b1 | tlb_mas_itlb_error == 1'b1) & tlb_mas_thdid[1] == 1'b1) ? tlb_mas1_tid_error :
                                         tlb_mas1_1_tid_error_q;
     assign tlb_mas2_1_epn_error_d = ((tlb_mas_dtlb_error == 1'b1 | tlb_mas_itlb_error == 1'b1) & tlb_mas_thdid[1] == 1'b1) ? tlb_mas2_epn_error :
                                         tlb_mas2_1_epn_error_q;
     assign tlb_lper_1_lpn_d = (tlb_lper_we[1] == 1'b1) ? tlb_lper_lpn :
                                     tlb_lper_1_lpn_q;
     assign tlb_lper_1_lps_d = (tlb_lper_we[1] == 1'b1) ? tlb_lper_lps :
                                     tlb_lper_1_lps_q;

     assign tlb_mmucr1_1_een_d = (tlb_mmucr1_we_pending_q[1] == 1'b0 & tlb_mmucr1_we == 1'b1 & tlb_mas_thdid[1] == 1'b1) ? tlb_mmucr1_een :
                                     tlb_mmucr1_1_een_q;

     assign ierat_mmucr1_1_een_d = (ierat_mmucr1_we_pending_q[1] == 1'b0 & iu_mm_ierat_mmucr1_we_q[1] == 1'b1) ? iu_mm_ierat_mmucr1_q :
                                       ierat_mmucr1_1_een_q;

     assign derat_mmucr1_1_een_d = (derat_mmucr1_we_pending_q[1] == 1'b0 & xu_mm_derat_mmucr1_we_q[1] == 1'b1) ? xu_mm_derat_mmucr1_q :
                                       derat_mmucr1_1_een_q;


     assign tlb_mas1_1_ts_error_upd = tlb_mas1_1_ts_error_q;
     assign tlb_mas1_1_tid_error_upd = tlb_mas1_1_tid_error_q;
     assign tlb_mas2_1_epn_error_upd = tlb_mas2_1_epn_error_q;
     assign tlb_lper_1_lpn_upd = tlb_lper_1_lpn_q;
     assign tlb_lper_1_lps_upd = tlb_lper_1_lps_q;
     assign tlb_mmucr1_1_een_upd = tlb_mmucr1_1_een_q;
     assign ierat_mmucr1_1_een_upd = ierat_mmucr1_1_een_q;
     assign derat_mmucr1_1_een_upd = derat_mmucr1_1_een_q;
`endif
`else
     assign tlb_mas_dtlb_error_upd = tlb_mas_thdid & {`MM_THREADS{tlb_mas_dtlb_error}};
     assign tlb_mas_itlb_error_upd = tlb_mas_thdid & {`MM_THREADS{tlb_mas_itlb_error}};
     assign tlb_lper_we_upd = tlb_lper_we;

     assign tlb_mmucr1_we_upd = {`MM_THREADS{tlb_mmucr1_we}} & tlb_mas_thdid[0:`MM_THREADS-1];
     assign iu_mm_ierat_mmucr1_we_upd = iu_mm_ierat_mmucr1_we_q;
     assign xu_mm_derat_mmucr1_we_upd = xu_mm_derat_mmucr1_we_q;

     assign tlb_mas1_0_ts_error_upd = tlb_mas1_ts_error;
     assign tlb_mas1_0_tid_error_upd = tlb_mas1_tid_error;
     assign tlb_mas2_0_epn_error_upd = tlb_mas2_epn_error;
     assign tlb_lper_0_lpn_upd = tlb_lper_lpn;
     assign tlb_lper_0_lps_upd = tlb_lper_lps;
     assign tlb_mmucr1_0_een_upd = tlb_mmucr1_een;
     assign ierat_mmucr1_0_een_upd = iu_mm_ierat_mmucr1_q;
     assign derat_mmucr1_0_een_upd = xu_mm_derat_mmucr1_q;
`ifdef MM_THREADS2
     assign tlb_mas1_1_ts_error_upd = tlb_mas1_ts_error;
     assign tlb_mas1_1_tid_error_upd = tlb_mas1_tid_error;
     assign tlb_mas2_1_epn_error_upd = tlb_mas2_epn_error;
     assign tlb_lper_1_lpn_upd = tlb_lper_lpn;
     assign tlb_lper_1_lps_upd = tlb_lper_lps;
     assign tlb_mmucr1_1_een_upd = tlb_mmucr1_een;
     assign ierat_mmucr1_1_een_upd = iu_mm_ierat_mmucr1_q;
     assign derat_mmucr1_1_een_upd = xu_mm_derat_mmucr1_q;
`endif
`endif


   assign lper_0_alpn_d[32:51] = ((spr_match_lper_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32:51] :
                                 (tlb_lper_we_upd[0] == 1'b1) ? tlb_lper_0_lpn_upd[32:51] :
                                 lper_0_alpn_q[32:51];
   generate
      if (`SPR_DATA_WIDTH == 64)
      begin : gen64_lper_0_alpn
         assign lper_0_alpn_d[64 - `REAL_ADDR_WIDTH:31] = ((spr_match_lper_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[64 - `REAL_ADDR_WIDTH:31] :
                                                         ((spr_match_lperu_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[64 - `REAL_ADDR_WIDTH + 32:63] :
                                                         (tlb_lper_we_upd[0] == 1'b1) ? tlb_lper_0_lpn_upd[64 - `REAL_ADDR_WIDTH:31] :
                                                         lper_0_alpn_q[64 - `REAL_ADDR_WIDTH:31];
      end
   endgenerate

   generate
      if (`SPR_DATA_WIDTH == 32)
      begin : gen32_lper_0_alpn
         assign lper_0_alpn_d[64 - `REAL_ADDR_WIDTH:31] = ((spr_match_lperu_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[64 - `REAL_ADDR_WIDTH + 32:63] :
                                                         (tlb_lper_we_upd[0] == 1'b1) ? tlb_lper_0_lpn_upd[64 - `REAL_ADDR_WIDTH:31] :
                                                         lper_0_alpn_q[64 - `REAL_ADDR_WIDTH:31];
      end
   endgenerate

   assign lper_0_lps_d = ((spr_match_lper_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[60:63] :
                         (tlb_lper_we_upd[0] == 1'b1) ? tlb_lper_0_lps_upd[60:63] :
                         lper_0_lps_q;

`ifdef MM_THREADS2
   assign lper_1_alpn_d[32:51] = ((spr_match_lper_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32:51] :
                                 (tlb_lper_we_upd[1] == 1'b1) ? tlb_lper_1_lpn_upd[32:51] :
                                 lper_1_alpn_q[32:51];
   generate
      if (`SPR_DATA_WIDTH == 64)
      begin : gen64_lper_1_alpn
         assign lper_1_alpn_d[64 - `REAL_ADDR_WIDTH:31] = ((spr_match_lper_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[64 - `REAL_ADDR_WIDTH:31] :
                                                         ((spr_match_lperu_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[64 - `REAL_ADDR_WIDTH + 32:63] :
                                                         (tlb_lper_we_upd[1] == 1'b1) ? tlb_lper_1_lpn_upd[64 - `REAL_ADDR_WIDTH:31] :
                                                         lper_1_alpn_q[64 - `REAL_ADDR_WIDTH:31];
      end
   endgenerate

   generate
      if (`SPR_DATA_WIDTH == 32)
      begin : gen32_lper_1_alpn
         assign lper_1_alpn_d[64 - `REAL_ADDR_WIDTH:31] = ((spr_match_lperu_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[64 - `REAL_ADDR_WIDTH + 32:63] :
                                                         (tlb_lper_we_upd[1] == 1'b1) ? tlb_lper_1_lpn_upd[64 - `REAL_ADDR_WIDTH:31] :
                                                         lper_1_alpn_q[64 - `REAL_ADDR_WIDTH:31];
      end
   endgenerate

   assign lper_1_lps_d = ((spr_match_lper_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[60:63] :
                         (tlb_lper_we_upd[1] == 1'b1) ? tlb_lper_1_lps_upd[60:63] :
                         lper_1_lps_q;
`endif



   assign mas1_0_v_d = (((spr_match_mas1_0_q == 1'b1 | spr_match_mas01_64b_0_q == 1'b1 | spr_match_mas81_64b_0_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32] :
                       ((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[0] == 1'b1)) ? 1'b0 :
                       ((tlb_mas_tlbsx_hit == 1'b1 & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1) ? 1'b1 :
                       ((tlb_mas_tlbre == 1'b1 & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas1_v :
                       ((lrat_mas_tlbsx_miss == 1'b1 & lrat_mas_thdid[0] == 1'b1)) ? 1'b0 :
                       ((lrat_mas_tlbsx_hit == 1'b1 & lrat_mas_thdid[0] == 1'b1)) ? 1'b1 :
                       ((lrat_mas_tlbre == 1'b1 & lrat_mas_thdid[0] == 1'b1)) ? lrat_mas1_v :
                       mas1_0_v_q;
   assign mas1_0_iprot_d = (((spr_match_mas1_0_q == 1'b1 | spr_match_mas01_64b_0_q == 1'b1 | spr_match_mas81_64b_0_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[33] :
                           ((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1) ? 1'b0 :
                           (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas1_iprot :
                           (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? 1'b0 :
                           mas1_0_iprot_q;
   assign mas1_0_tid_d = (((spr_match_mas1_0_q == 1'b1 | spr_match_mas01_64b_0_q == 1'b1 | spr_match_mas81_64b_0_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[34:47] :
                         ((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[0] == 1'b1)) ? mas6_0_spid_q :
                         ((tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? tlb_mas1_0_tid_error_upd :
                         (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas1_tid :
                         (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? {`PID_WIDTH{1'b0}} :
                         mas1_0_tid_q;
   assign mas1_0_ind_d = (((spr_match_mas1_0_q == 1'b1 | spr_match_mas01_64b_0_q == 1'b1 | spr_match_mas81_64b_0_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[50] :
                         ((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1) ? mas4_0_indd_q :
                         (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas1_ind :
                         (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? 1'b0 :
                         mas1_0_ind_q;
   assign mas1_0_ts_d = (((spr_match_mas1_0_q == 1'b1 | spr_match_mas01_64b_0_q == 1'b1 | spr_match_mas81_64b_0_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[51] :
                        ((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[0] == 1'b1)) ? mas6_0_sas_q :
                        ((tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? tlb_mas1_0_ts_error_upd :
                        (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas1_ts :
                        (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? 1'b0 :
                        mas1_0_ts_q;
   assign mas1_0_tsize_d = (((spr_match_mas1_0_q == 1'b1 | spr_match_mas01_64b_0_q == 1'b1 | spr_match_mas81_64b_0_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[52:55] :
                           (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? mas4_0_tsized_q :
                           (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas1_tsize :
                           (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? lrat_mas1_tsize :
                           mas1_0_tsize_q;

   assign mas2_0_epn_d[32:51] = ((spr_match_mas2_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32:51] :
                                ((tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? tlb_mas2_0_epn_error_upd[32:51] :
                                (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas2_epn[32:51] :
                                (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? lrat_mas2_epn[32:51] :
                                mas2_0_epn_q[32:51];
   assign mas2_0_wimge_d = ((spr_match_mas2_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[59:63] :
                           (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? mas4_0_wimged_q :
                           (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas2_wimge :
                           (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? 5'b0 :
                           mas2_0_wimge_q;

   assign mas3_0_rpnl_d = (((spr_match_mas3_0_q == 1'b1 | spr_match_mas73_64b_0_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32:52] :
                          (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? {21{1'b0}} :
                          (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? {tlb_mas3_rpnl, (tlb_mas3_usxwr[5] & tlb_mas1_ind)} :
                          (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? {lrat_mas3_rpnl, 1'b0} :
                          mas3_0_rpnl_q;
   assign mas3_0_ubits_d = (((spr_match_mas3_0_q == 1'b1 | spr_match_mas73_64b_0_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[54:57] :
                           (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? 4'b0 :
                           (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas3_ubits :
                           (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? 4'b0 :
                           mas3_0_ubits_q;
   assign mas3_0_usxwr_d = (((spr_match_mas3_0_q == 1'b1 | spr_match_mas73_64b_0_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[58:63] :
                           (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? 6'b0 :
                           (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? ({tlb_mas3_usxwr[0:4], (tlb_mas3_usxwr[5] & (~tlb_mas1_ind))}) :
                           (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? 6'b0 :
                           mas3_0_usxwr_q;

   // no h/w updates to mas4
   assign mas4_0_indd_d = ((spr_match_mas4_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[48] :
                          mas4_0_indd_q;
   assign mas4_0_tsized_d = ((spr_match_mas4_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[52:55] :
                            mas4_0_tsized_q;
   assign mas4_0_wimged_d = ((spr_match_mas4_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[59:63] :
                            mas4_0_wimged_q;

   assign mas6_0_spid_d = (((spr_match_mas6_0_q == 1'b1 | spr_match_mas56_64b_0_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[34:47] :
                          ((tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? tlb_mas1_0_tid_error_upd :
                          mas6_0_spid_q;
   assign mas6_0_isize_d = (((spr_match_mas6_0_q == 1'b1 | spr_match_mas56_64b_0_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[52:55] :
                           ((tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? mas4_0_tsized_q :
                           mas6_0_isize_q;
   assign mas6_0_sind_d = (((spr_match_mas6_0_q == 1'b1 | spr_match_mas56_64b_0_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[62] :
                          ((tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? mas4_0_indd_q :
                          mas6_0_sind_q;
   assign mas6_0_sas_d = (((spr_match_mas6_0_q == 1'b1 | spr_match_mas56_64b_0_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[63] :
                         ((tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? tlb_mas1_0_ts_error_upd :
                         mas6_0_sas_q;

`ifdef MM_THREADS2
   assign mas1_1_v_d = (((spr_match_mas1_1_q == 1'b1 | spr_match_mas01_64b_1_q == 1'b1 | spr_match_mas81_64b_1_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32] :
                       ((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[1] == 1'b1)) ? 1'b0 :
                       ((tlb_mas_tlbsx_hit == 1'b1 & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1) ? 1'b1 :
                       ((tlb_mas_tlbre == 1'b1 & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas1_v :
                       ((lrat_mas_tlbsx_miss == 1'b1 & lrat_mas_thdid[1] == 1'b1)) ? 1'b0 :
                       ((lrat_mas_tlbsx_hit == 1'b1 & lrat_mas_thdid[1] == 1'b1)) ? 1'b1 :
                       ((lrat_mas_tlbre == 1'b1 & lrat_mas_thdid[1] == 1'b1)) ? lrat_mas1_v :
                       mas1_1_v_q;
   assign mas1_1_iprot_d = (((spr_match_mas1_1_q == 1'b1 | spr_match_mas01_64b_1_q == 1'b1 | spr_match_mas81_64b_1_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[33] :
                           (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1)) ? 1'b0 :
                           (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas1_iprot :
                           (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? 1'b0 :
                           mas1_1_iprot_q;
   assign mas1_1_tid_d = (((spr_match_mas1_1_q == 1'b1 | spr_match_mas01_64b_1_q == 1'b1 | spr_match_mas81_64b_1_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[34:47] :
                         ((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[1] == 1'b1)) ? mas6_1_spid_q :
                         (((tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1))) ? tlb_mas1_1_tid_error_upd :
                         (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas1_tid :
                         (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? {`PID_WIDTH{1'b0}} :
                         mas1_1_tid_q;
   assign mas1_1_ind_d = (((spr_match_mas1_1_q == 1'b1 | spr_match_mas01_64b_1_q == 1'b1 | spr_match_mas81_64b_1_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[50] :
                         (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1)) ? mas4_1_indd_q :
                         (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas1_ind :
                         (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? 1'b0 :
                         mas1_1_ind_q;
   assign mas1_1_ts_d = (((spr_match_mas1_1_q == 1'b1 | spr_match_mas01_64b_1_q == 1'b1 | spr_match_mas81_64b_1_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[51] :
                        ((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[1] == 1'b1)) ? mas6_1_sas_q :
                        (((tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1))) ? tlb_mas1_1_ts_error_upd :
                        (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas1_ts :
                        (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? 1'b0 :
                        mas1_1_ts_q;
   assign mas1_1_tsize_d = (((spr_match_mas1_1_q == 1'b1 | spr_match_mas01_64b_1_q == 1'b1 | spr_match_mas81_64b_1_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[52:55] :
                           (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1)) ? mas4_1_tsized_q :
                           (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas1_tsize :
                           (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? lrat_mas1_tsize :
                           mas1_1_tsize_q;

   assign mas2_1_epn_d[32:51] = ((spr_match_mas2_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32:51] :
                                (((tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1))) ? tlb_mas2_1_epn_error_upd[32:51] :
                                (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas2_epn[32:51] :
                                (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? lrat_mas2_epn[32:51] :
                                mas2_1_epn_q[32:51];
   assign mas2_1_wimge_d = ((spr_match_mas2_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[59:63] :
                           (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1)) ? mas4_1_wimged_q :
                           (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas2_wimge :
                           (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? 5'b0 :
                           mas2_1_wimge_q;

   assign mas3_1_rpnl_d = (((spr_match_mas3_1_q == 1'b1 | spr_match_mas73_64b_1_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32:52] :
                          (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1)) ? 21'b0 :
                          (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? {tlb_mas3_rpnl, (tlb_mas3_usxwr[5] & tlb_mas1_ind)} :
                          (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? {lrat_mas3_rpnl, 1'b0} :
                          mas3_1_rpnl_q;
   assign mas3_1_ubits_d = (((spr_match_mas3_1_q == 1'b1 | spr_match_mas73_64b_1_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[54:57] :
                           (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1)) ? 4'b0 :
                           (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas3_ubits :
                           (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? 4'b0 :
                           mas3_1_ubits_q;
   assign mas3_1_usxwr_d = (((spr_match_mas3_1_q == 1'b1 | spr_match_mas73_64b_1_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[58:63] :
                           (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1)) ? 6'b0 :
                           (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? ({tlb_mas3_usxwr[0:4], (tlb_mas3_usxwr[5] & (~tlb_mas1_ind))}) :
                           (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? 6'b0 :
                           mas3_1_usxwr_q;

   // no h/w updates to mas4
   assign mas4_1_indd_d = ((spr_match_mas4_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[48] :
                          mas4_1_indd_q;
   assign mas4_1_tsized_d = ((spr_match_mas4_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[52:55] :
                            mas4_1_tsized_q;
   assign mas4_1_wimged_d = ((spr_match_mas4_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[59:63] :
                            mas4_1_wimged_q;

   assign mas6_1_spid_d = (((spr_match_mas6_1_q == 1'b1 | spr_match_mas56_64b_1_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[34:47] :
                          (((tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1))) ? tlb_mas1_1_tid_error_upd :
                          mas6_1_spid_q;
   assign mas6_1_isize_d = (((spr_match_mas6_1_q == 1'b1 | spr_match_mas56_64b_1_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[52:55] :
                           (((tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1))) ? mas4_1_tsized_q :
                           mas6_1_isize_q;
   assign mas6_1_sind_d = (((spr_match_mas6_1_q == 1'b1 | spr_match_mas56_64b_1_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[62] :
                          (((tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1))) ? mas4_1_indd_q :
                          mas6_1_sind_q;
   assign mas6_1_sas_d = (((spr_match_mas6_1_q == 1'b1 | spr_match_mas56_64b_1_q == 1'b1) & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[63] :
                         (((tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1))) ? tlb_mas1_1_ts_error_upd :
                         mas6_1_sas_q;
`endif

   generate
      if (`SPR_DATA_WIDTH == 32)
      begin : gen32_mas_d
         assign mas0_0_atsel_d = ((spr_match_mas0_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32] :
                                 (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbsx_miss == 1'b1) & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1) ? 1'b0 :
                                 (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbsx_miss == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? 1'b1 :
                                 mas0_0_atsel_q;
         assign mas0_0_esel_d = ((spr_match_mas0_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[45:47] :
                                (((tlb_mas_tlbsx_hit == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas0_esel :
                                (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? 3'b0 :
                                (((lrat_mas_tlbsx_hit == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? lrat_mas0_esel :
                                mas0_0_esel_q;
         assign mas0_0_hes_d = ((spr_match_mas0_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[49] :
                               (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbsx_miss == 1'b1) & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1) ? 1'b1 :
                               mas0_0_hes_q;
         assign mas0_0_wq_d = ((spr_match_mas0_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[50:51] :
                              (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbsx_miss == 1'b1) & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1) ? 2'b01 :
                              (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbsx_miss == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? 2'b00 :
                              mas0_0_wq_q;

         assign mas5_0_sgs_d = ((spr_match_mas5_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32] :
                               mas5_0_sgs_q;
         assign mas5_0_slpid_d = ((spr_match_mas5_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[56:63] :
                                 mas5_0_slpid_q;

         assign mas7_0_rpnu_d = ((spr_match_mas7_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[54:63] :
                                (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? {`REAL_ADDR_WIDTH-32{1'b0}} :
                                (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas7_rpnu :
                                (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? lrat_mas7_rpnu :
                                mas7_0_rpnu_q;

         assign mas8_0_tgs_d = ((spr_match_mas8_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32] :
                               (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas8_tgs :
                               (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? 1'b0 :
                               mas8_0_tgs_q;
         assign mas8_0_vf_d = ((spr_match_mas8_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[33] :
                              (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas8_vf :
                              (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? 1'b0 :
                              mas8_0_vf_q;
         assign mas8_0_tlpid_d = ((spr_match_mas8_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[56:63] :
                                 (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas8_tlpid :
                                 (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? lrat_mas8_tlpid :
                                 mas8_0_tlpid_q;

`ifdef MM_THREADS2
         assign mas0_1_atsel_d = ((spr_match_mas0_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32] :
                                 (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbsx_miss == 1'b1) & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1) ? 1'b0 :
                                 (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbsx_miss == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? 1'b1 :
                                 mas0_1_atsel_q;
         assign mas0_1_esel_d = ((spr_match_mas0_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[45:47] :
                                (((tlb_mas_tlbsx_hit == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas0_esel :
                                (((tlb_mas_tlbsx_miss == 1'b1) & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1) ? 3'b0 :
                                (((lrat_mas_tlbsx_hit == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? lrat_mas0_esel :
                                mas0_1_esel_q;
         assign mas0_1_hes_d = ((spr_match_mas0_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[49] :
                               (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbsx_miss == 1'b1) & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1) ? 1'b1 :
                               mas0_1_hes_q;
         assign mas0_1_wq_d = ((spr_match_mas0_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[50:51] :
                              (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbsx_miss == 1'b1) & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1) ? 2'b01 :
                              (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbsx_miss == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? 2'b00 :
                              mas0_1_wq_q;

         assign mas5_1_sgs_d = ((spr_match_mas5_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32] :
                               mas5_1_sgs_q;
         assign mas5_1_slpid_d = ((spr_match_mas5_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[56:63] :
                                 mas5_1_slpid_q;

         assign mas7_1_rpnu_d = ((spr_match_mas7_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[54:63] :
                                (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1)) ? {`REAL_ADDR_WIDTH-32{1'b0}} :
                                (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas7_rpnu :
                                (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? lrat_mas7_rpnu :
                                mas7_1_rpnu_q;

         assign mas8_1_tgs_d = ((spr_match_mas8_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32] :
                               (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas8_tgs :
                               (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? 1'b0 :
                               mas8_1_tgs_q;
         assign mas8_1_vf_d = ((spr_match_mas8_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[33] :
                              (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas8_vf :
                              (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? 1'b0 :
                              mas8_1_vf_q;
         assign mas8_1_tlpid_d = ((spr_match_mas8_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[56:63] :
                                 (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas8_tlpid :
                                 (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? lrat_mas8_tlpid :
                                 mas8_1_tlpid_q;
`endif
      end
   endgenerate

   generate
      if (`SPR_DATA_WIDTH == 64)
      begin : gen64_mas_d
         assign mas0_0_atsel_d = ((spr_match_mas0_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32] :
                                 ((spr_match_mas01_64b_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[0] :
                                 (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbsx_miss == 1'b1) & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1) ? 1'b0 :
                                 (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbsx_miss == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? 1'b1 :
                                 mas0_0_atsel_q;
         assign mas0_0_esel_d = ((spr_match_mas0_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[45:47] :
                                ((spr_match_mas01_64b_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[13:15] :
                                (((tlb_mas_tlbsx_hit == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas0_esel :
                                (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? 3'b0 :
                                (((lrat_mas_tlbsx_hit == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? lrat_mas0_esel :
                                mas0_0_esel_q;
         assign mas0_0_hes_d = ((spr_match_mas0_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[49] :
                               ((spr_match_mas01_64b_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[17] :
                               (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbsx_miss == 1'b1) & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1) ? 1'b1 :
                               mas0_0_hes_q;
         assign mas0_0_wq_d = ((spr_match_mas0_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[50:51] :
                              ((spr_match_mas01_64b_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[18:19] :
                              (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbsx_miss == 1'b1) & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1) ? 2'b01 :
                              (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbsx_miss == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? 2'b00 :
                              mas0_0_wq_q;

         assign mas2_0_epn_d[0:31] = ((spr_match_mas2u_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32:63] :
                                     ((spr_match_mas2_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[0:31] :
                                     (((tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1))) ? tlb_mas2_0_epn_error_upd[0:31] :
                                     (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas2_epn[0:31] :
                                     (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? lrat_mas2_epn[0:31] :
                                     mas2_0_epn_q[0:31];

         assign mas5_0_sgs_d = ((spr_match_mas5_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32] :
                               ((spr_match_mas56_64b_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[0] :
                               mas5_0_sgs_q;
         assign mas5_0_slpid_d = ((spr_match_mas5_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[56:63] :
                                 ((spr_match_mas56_64b_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[24:31] :
                                 mas5_0_slpid_q;

         assign mas7_0_rpnu_d = ((spr_match_mas7_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[54:63] :
                                (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[0] == 1'b1) | tlb_mas_dtlb_error_upd[0] == 1'b1 | tlb_mas_itlb_error_upd[0] == 1'b1)) ? {`REAL_ADDR_WIDTH-32{1'b0}} :
                                ((spr_match_mas73_64b_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[22:31] :
                                (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas7_rpnu :
                                (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? lrat_mas7_rpnu :
                                mas7_0_rpnu_q;

         assign mas8_0_tgs_d = ((spr_match_mas8_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32] :
                               ((spr_match_mas81_64b_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[0] :
                               (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas8_tgs :
                               (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? 1'b0 :
                               mas8_0_tgs_q;
         assign mas8_0_vf_d = ((spr_match_mas8_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[33] :
                              ((spr_match_mas81_64b_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[1] :
                              (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas8_vf :
                              (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? 1'b0 :
                              mas8_0_vf_q;
         assign mas8_0_tlpid_d = ((spr_match_mas8_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[56:63] :
                                 ((spr_match_mas81_64b_0_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[24:31] :
                                 (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[0] == 1'b1)) ? tlb_mas8_tlpid :
                                 (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[0] == 1'b1)) ? lrat_mas8_tlpid :
                                 mas8_0_tlpid_q;

`ifdef MM_THREADS2
         assign mas0_1_atsel_d = ((spr_match_mas0_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32] :
                                 ((spr_match_mas01_64b_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[0] :
                                 (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbsx_miss == 1'b1) & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1) ? 1'b0 :
                                 (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbsx_miss == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? 1'b1 :
                                 mas0_1_atsel_q;
         assign mas0_1_esel_d = ((spr_match_mas0_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[45:47] :
                                ((spr_match_mas01_64b_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[13:15] :
                                (((tlb_mas_tlbsx_hit == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas0_esel :
                                (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1)) ? 3'b0 :
                                (((lrat_mas_tlbsx_hit == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? lrat_mas0_esel :
                                mas0_1_esel_q;
         assign mas0_1_hes_d = ((spr_match_mas0_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[49] :
                               ((spr_match_mas01_64b_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[17] :
                               (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbsx_miss == 1'b1) & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1) ? 1'b1 :
                               mas0_1_hes_q;
         assign mas0_1_wq_d = ((spr_match_mas0_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[50:51] :
                              ((spr_match_mas01_64b_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[18:19] :
                              (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbsx_miss == 1'b1) & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1) ? 2'b01 :
                              (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbsx_miss == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? 2'b00 :
                              mas0_1_wq_q;

         assign mas2_1_epn_d[0:31] = ((spr_match_mas2u_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32:63] :
                                     ((spr_match_mas2_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[0:31] :
                                     (((tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1))) ? tlb_mas2_1_epn_error_upd[0:31] :
                                     (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas2_epn[0:31] :
                                     (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? lrat_mas2_epn[0:31] :
                                     mas2_1_epn_q[0:31];

         assign mas5_1_sgs_d = ((spr_match_mas5_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32] :
                               ((spr_match_mas56_64b_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[0] :
                               mas5_1_sgs_q;
         assign mas5_1_slpid_d = ((spr_match_mas5_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[56:63] :
                                 ((spr_match_mas56_64b_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[24:31] :
                                 mas5_1_slpid_q;

         assign mas7_1_rpnu_d = ((spr_match_mas7_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[54:63] :
                                (((tlb_mas_tlbsx_miss == 1'b1 & tlb_mas_thdid[1] == 1'b1) | tlb_mas_dtlb_error_upd[1] == 1'b1 | tlb_mas_itlb_error_upd[1] == 1'b1)) ? {`REAL_ADDR_WIDTH-32{1'b0}} :
                                ((spr_match_mas73_64b_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[22:31] :
                                (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas7_rpnu :
                                (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? lrat_mas7_rpnu :
                                mas7_1_rpnu_q;

         assign mas8_1_tgs_d = ((spr_match_mas8_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[32] :
                               ((spr_match_mas81_64b_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[0] :
                               (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas8_tgs :
                               (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? 1'b0 :
                               mas8_1_tgs_q;
         assign mas8_1_vf_d = ((spr_match_mas8_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[33] :
                              ((spr_match_mas81_64b_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[1] :
                              (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas8_vf :
                              (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? 1'b0 :
                              mas8_1_vf_q;
         assign mas8_1_tlpid_d = ((spr_match_mas8_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[56:63] :
                                 ((spr_match_mas81_64b_1_q == 1'b1 & spr_ctl_int_q[1] == Spr_RW_Write)) ? spr_data_int_q[24:31] :
                                 (((tlb_mas_tlbsx_hit == 1'b1 | tlb_mas_tlbre == 1'b1) & tlb_mas_thdid[1] == 1'b1)) ? tlb_mas8_tlpid :
                                 (((lrat_mas_tlbsx_hit == 1'b1 | lrat_mas_tlbre == 1'b1) & lrat_mas_thdid[1] == 1'b1)) ? lrat_mas8_tlpid :
                                 mas8_1_tlpid_q;
`endif
      end
   endgenerate

   // 0: val, 1: rw, 2: done
   assign spr_ctl_out_d[0] = spr_ctl_int_q[0] & (~(spr_val_int_flushed));
   assign spr_ctl_out_d[1] = spr_ctl_int_q[1];
   assign spr_ctl_out_d[2] = (spr_ctl_int_q[2] | spr_match_any_mmu_q) & (~(spr_val_int_flushed));
   assign spr_etid_out_d = spr_etid_int_q;
   assign spr_addr_out_d = spr_addr_int_q;
   //constant Spr_RW_Write : std_ulogic := '0'; -- write value for rw signal
   //constant Spr_RW_Read : std_ulogic := '1'; -- read value for rw signal

   assign spr_data_out_d[32:63] = ( {{32-`LPID_WIDTH{1'b0}}, lpidr_q} & {32{(spr_match_lpidr_q & spr_ctl_int_q[1])}} ) |
                                    ( {{32-`PID_WIDTH{1'b0}}, pid0_q} & {32{(spr_match_pid0_q & spr_ctl_int_q[1])}} ) |
                                    ( {mmucr0_0_q[0:5], 12'b0, mmucr0_0_q[6:19]} & {32{(spr_match_mmucr0_0_q & spr_ctl_int_q[1])}} ) |
                                    (  mmucr1_q & {32{(spr_match_mmucr1_q & spr_ctl_int_q[1])}} ) |
                                    (  mmucr2_q & {32{(spr_match_mmucr2_q & spr_ctl_int_q[1])}} ) |
                                    ( {{32-`MMUCR3_WIDTH{1'b0}}, mmucr3_0_q[64 - `MMUCR3_WIDTH:58], 1'b0, mmucr3_0_q[60:59+`MM_THREADS], {`THDID_WIDTH-`MM_THREADS{1'b0}} } & {32{(spr_match_mmucr3_0_q & spr_ctl_int_q[1])}} ) |
                                    ( {mesr1_q[32:32 + `MESR1_WIDTH - 1], {32-`MESR1_WIDTH{1'b0}}} & {32{(spr_match_mesr1_q & spr_ctl_int_q[1])}} ) |
                                    ( {mesr2_q[32:32 + `MESR2_WIDTH - 1], {32-`MESR2_WIDTH{1'b0}}} & {32{(spr_match_mesr2_q & spr_ctl_int_q[1])}} ) |
                                    ( {29'b0, mmucsr0_tlb0fi_q, 2'b00} & {32{(spr_match_mmucsr0_q & spr_ctl_int_q[1])}} ) |
                                    ( {Spr_Data_MMUCFG[32:46], mmucfg_q[47:48], Spr_Data_MMUCFG[49:63]} & {32{(spr_match_mmucfg_q & spr_ctl_int_q[1])}} ) |
                                    ( {Spr_Data_TLB0CFG[32:44], tlb0cfg_q[45:47], Spr_Data_TLB0CFG[48:63]} & {32{(spr_match_tlb0cfg_q & spr_ctl_int_q[1])}} ) |
                                    (  Spr_Data_TLB0PS  & {32{(spr_match_tlb0ps_q & spr_ctl_int_q[1])}} ) |
                                    (  Spr_Data_LRATCFG & {32{(spr_match_lratcfg_q & spr_ctl_int_q[1])}} ) |
                                    (  Spr_Data_LRATPS & {32{(spr_match_lratps_q & spr_ctl_int_q[1])}} ) |
                                    (  Spr_Data_EPTCFG & {32{(spr_match_eptcfg_q & spr_ctl_int_q[1])}} ) |
                                    ( {lper_0_alpn_q[32:51], 8'b0, lper_0_lps_q[60:63]} & {32{(spr_match_lper_0_q & spr_ctl_int_q[1])}} ) |
                                    ( {{64-`REAL_ADDR_WIDTH{1'b0}}, lper_0_alpn_q[64 - `REAL_ADDR_WIDTH:31]} & {32{(spr_match_lperu_0_q & spr_ctl_int_q[1])}} ) |
`ifdef MM_THREADS2
                                    ( {{32-`PID_WIDTH{1'b0}}, pid1_q} & {32{(spr_match_pid1_q & spr_ctl_int_q[1])}} ) |
                                    ( {mmucr0_1_q[0:5], 12'b0, mmucr0_1_q[6:19]} & {32{(spr_match_mmucr0_1_q & spr_ctl_int_q[1])}} ) |
                                    ( {{32-`MMUCR3_WIDTH{1'b0}}, mmucr3_1_q[64 - `MMUCR3_WIDTH:58], 1'b0, mmucr3_1_q[60:59+`MM_THREADS], {`THDID_WIDTH-`MM_THREADS{1'b0}} } & {32{(spr_match_mmucr3_1_q & spr_ctl_int_q[1])}} ) |
                                    ( {lper_1_alpn_q[32:51], 8'b0, lper_1_lps_q[60:63]} & {32{(spr_match_lper_1_q & spr_ctl_int_q[1])}} ) |
                                    ( {{64-`REAL_ADDR_WIDTH{1'b0}}, lper_1_alpn_q[64 - `REAL_ADDR_WIDTH:31]} & {32{(spr_match_lperu_1_q & spr_ctl_int_q[1])}} ) |
`endif
                                    ( (spr_mas_data_out_q[32:63]) & {32{(spr_match_any_mas_q & spr_ctl_int_q[1])}} ) |
                                    ( spr_data_int_q[32:63] & {32{(~spr_match_any_mmu_q)}} );

   assign spr_mas_data_out[32:63] = ( {mas0_0_atsel_q, 12'b0, mas0_0_esel_q, 1'b0, mas0_0_hes_q, mas0_0_wq_q, 12'b0} & {32{spr_match_mas0_0}} ) |
                                      ( {mas1_0_v_q, mas1_0_iprot_q, mas1_0_tid_q, 2'b00, mas1_0_ind_q, mas1_0_ts_q, mas1_0_tsize_q, 8'b00000000} & {32{(spr_match_mas1_0 | spr_match_mas01_64b_0 | spr_match_mas81_64b_0)}} ) |
                                      ( {mas2_0_epn_q[32:51], 7'b0000000, mas2_0_wimge_q} & {32{spr_match_mas2_0}} ) |
                                      ( {mas2_0_epn_q[0:31]} & {32{spr_match_mas2u_0}} ) |
                                      ( {mas3_0_rpnl_q, 1'b0, mas3_0_ubits_q, mas3_0_usxwr_q} & {32{(spr_match_mas3_0 | spr_match_mas73_64b_0)}} ) |
                                      ( {16'b0, mas4_0_indd_q, 3'b000, mas4_0_tsized_q, 3'b000, mas4_0_wimged_q} & {32{spr_match_mas4_0}} ) |
                                      ( {mas5_0_sgs_q, 23'b0, mas5_0_slpid_q} & {32{spr_match_mas5_0}} ) |
                                      ( {2'b00, mas6_0_spid_q, 4'b0000, mas6_0_isize_q, 6'b000000, mas6_0_sind_q, mas6_0_sas_q} & {32{(spr_match_mas6_0 | spr_match_mas56_64b_0)}} ) |
                                      ( {22'b0, mas7_0_rpnu_q} & {32{spr_match_mas7_0}} ) |
`ifdef MM_THREADS2
                                      ( {mas8_0_tgs_q, mas8_0_vf_q, 22'b0, mas8_0_tlpid_q} & {32{spr_match_mas8_0}} ) |
                                      ( {mas0_1_atsel_q, 12'b0, mas0_1_esel_q, 1'b0, mas0_1_hes_q, mas0_1_wq_q, 12'b0} & {32{spr_match_mas0_1}} ) |
                                      ( {mas1_1_v_q, mas1_1_iprot_q, mas1_1_tid_q, 2'b00, mas1_1_ind_q, mas1_1_ts_q, mas1_1_tsize_q, 8'b00000000} & {32{(spr_match_mas1_1 | spr_match_mas01_64b_1 | spr_match_mas81_64b_1)}} ) |
                                      ( {mas2_1_epn_q[32:51], 7'b0000000, mas2_1_wimge_q} & {32{spr_match_mas2_1}} ) |
                                      ( {mas2_1_epn_q[0:31]} & {32{spr_match_mas2u_1}} ) |
                                      ( {mas3_1_rpnl_q, 1'b0, mas3_1_ubits_q, mas3_1_usxwr_q} & {32{(spr_match_mas3_1 | spr_match_mas73_64b_1)}} ) |
                                      ( {16'b0, mas4_1_indd_q, 3'b000, mas4_1_tsized_q, 3'b000, mas4_1_wimged_q}  & {32{spr_match_mas4_1}} ) |
                                      ( {mas5_1_sgs_q, 23'b0, mas5_1_slpid_q} & {32{spr_match_mas5_1}} ) |
                                      ( {2'b00, mas6_1_spid_q, 4'b0000, mas6_1_isize_q, 6'b000000, mas6_1_sind_q, mas6_1_sas_q} & {32{(spr_match_mas6_1 | spr_match_mas56_64b_1)}} ) |
                                      ( {22'b0, mas7_1_rpnu_q} & {32{spr_match_mas7_1}} ) |
                                      ( {mas8_1_tgs_q, mas8_1_vf_q, 22'b0, mas8_1_tlpid_q} & {32{spr_match_mas8_1}} );
`else
                                      ( {mas8_0_tgs_q, mas8_0_vf_q, 22'b0, mas8_0_tlpid_q} & {32{spr_match_mas8_0}} );
`endif

   generate
      if (`SPR_DATA_WIDTH == 64)
      begin : gen64_spr_data
         assign spr_mas_data_out[0:31] = ( mas2_0_epn_q[0:31] & {32{spr_match_mas2_0}} ) |
                                     ( {mas0_0_atsel_q, 12'b0, mas0_0_esel_q, 1'b0, mas0_0_hes_q, mas0_0_wq_q, 12'b0} & {32{spr_match_mas01_64b_0}} ) |
                                     ( {mas5_0_sgs_q, 23'b0, mas5_0_slpid_q} & {32{spr_match_mas56_64b_0}} ) |
                                     ( {22'b0, mas7_0_rpnu_q} & {32{spr_match_mas73_64b_0}} ) |
`ifdef MM_THREADS2
                                     ( {mas8_0_tgs_q, mas8_0_vf_q, 22'b0, mas8_0_tlpid_q} & {32{spr_match_mas81_64b_0}} ) |
                                     ( {mas2_1_epn_q[0:31]} & {32{spr_match_mas2_1}} ) |
                                     ( {mas0_1_atsel_q, 12'b0, mas0_1_esel_q, 1'b0, mas0_1_hes_q, mas0_1_wq_q, 12'b0} & {32{spr_match_mas01_64b_1}} ) |
                                     ( {mas5_1_sgs_q, 23'b0, mas5_1_slpid_q} & {32{spr_match_mas56_64b_1}} ) |
                                     ( {22'b0, mas7_1_rpnu_q} & {32{spr_match_mas73_64b_1}} ) |
                                     ( {mas8_1_tgs_q, mas8_1_vf_q, 22'b0, mas8_1_tlpid_q} & {32{spr_match_mas81_64b_1}} );
`else
                                     ( {mas8_0_tgs_q, mas8_0_vf_q, 22'b0, mas8_0_tlpid_q} & {32{spr_match_mas81_64b_0}} );
`endif

         //constant Spr_RW_Write : std_ulogic := '0'; -- write value for rw signal
         //constant Spr_RW_Read : std_ulogic := '1'; -- read value for rw signal
         assign spr_data_out_d[0:31] = ( {{64-`REAL_ADDR_WIDTH{1'b0}}, lper_0_alpn_q[64 - `REAL_ADDR_WIDTH:31]} & {32{(spr_match_lper_0_q & spr_ctl_int_q[1])}} ) |
`ifdef MM_THREADS2
                                         ( {{64-`REAL_ADDR_WIDTH{1'b0}}, lper_1_alpn_q[64 - `REAL_ADDR_WIDTH:31]} & {32{(spr_match_lper_1_q & spr_ctl_int_q[1])}} ) |
`endif
                                         ( {spr_mas_data_out_q[0:31]} & {32{(spr_match_any_mas_q & spr_ctl_int_q[1])}} ) |
                                         ( {spr_data_int_q[0:31]} & {32{((~(spr_match_any_mmu_q)) | (~(spr_ctl_int_q[1])))}} );
      end
   endgenerate

   assign mm_iu_slowspr_val = spr_ctl_out_q[0];
   assign mm_iu_slowspr_rw = spr_ctl_out_q[1];
   assign mm_iu_slowspr_etid = spr_etid_out_q;
   assign mm_iu_slowspr_addr = spr_addr_out_q;
   assign mm_iu_slowspr_data = spr_data_out_q;
   assign mm_iu_slowspr_done = spr_ctl_out_q[2];

   assign mm_iu_ierat_pid0 = pid0_q;
   assign mm_iu_ierat_mmucr0_0 = mmucr0_0_q;
   assign mm_iu_ierat_mmucr1 = {mmucr1_q[0], mmucr1_q[2:5], mmucr1_q[6:7], mmucr1_q[12:13]};
   assign mm_xu_derat_pid0 = pid0_q;
   assign mm_xu_derat_mmucr0_0 = mmucr0_0_q;
   assign mm_xu_derat_mmucr1 = {mmucr1_q[1], mmucr1_q[2:5], mmucr1_q[8:9], mmucr1_q[14:16]};
`ifdef MM_THREADS2
   assign mm_iu_ierat_pid1 = pid1_q;
   assign mm_iu_ierat_mmucr0_1 = mmucr0_1_q;
   assign mm_xu_derat_pid1 = pid1_q;
   assign mm_xu_derat_mmucr0_1 = mmucr0_1_q;
`endif

   // mmucr1: 0-IRRE, 1-DRRE, 2-REE, 3-CEE,
   //         4-Disable any context sync inst from invalidating extclass=0 erat entries,
   //         5-Disable isync inst from invalidating extclass=0 erat entries,
   //         6:7-IPEI, 8:9-DPEI, 10:11-TPEI, 12:13-ICTID/ITTID, 14:15-DCTID/DTTID,
   //         16-DCCD, 17-TLBWE_BINV, 18-TLBI_MSB, 19-TLBI_REJ,
   //         20-IERRDET, 21-DERRDET, 22-TERRDET, 23:31-EEN
   assign pid0 = pid0_q;
   assign mmucr0_0 = mmucr0_0_q;
   assign mmucr1 = mmucr1_q;
   assign mmucr2 = mmucr2_q;
   assign mmucr3_0 = mmucr3_0_q;
   assign tstmode4k_0 = tstmode4k_0_q[1:3];
`ifdef MM_THREADS2
   assign pid1 = pid1_q;
   assign mmucr0_1 = mmucr0_1_q;
   assign mmucr3_1 = mmucr3_1_q;
   assign tstmode4k_1 = tstmode4k_1_q[1:3];
`endif
   assign lpidr = lpidr_q;
   assign ac_an_lpar_id = lpidr_q;
   assign mmucfg_lrat = mmucfg_q[47];
   assign mmucfg_twc = mmucfg_q[48];
   assign tlb0cfg_pt = tlb0cfg_q[45];
   assign tlb0cfg_ind = tlb0cfg_q[46];
   assign tlb0cfg_gtwe = tlb0cfg_q[47];
   assign mmq_spr_event_mux_ctrls = {mesr1_q, mesr2_q};
   assign mas0_0_atsel = mas0_0_atsel_q;
   assign mas0_0_esel = mas0_0_esel_q;
   assign mas0_0_hes = mas0_0_hes_q;
   assign mas0_0_wq = mas0_0_wq_q;
   assign mas1_0_v = mas1_0_v_q;
   assign mas1_0_iprot = mas1_0_iprot_q;
   assign mas1_0_tid = mas1_0_tid_q;
   assign mas1_0_ind = mas1_0_ind_q;
   assign mas1_0_ts = mas1_0_ts_q;
   assign mas1_0_tsize = mas1_0_tsize_q;

   generate
      if (`SPR_DATA_WIDTH == 32)
      begin : gen32_mas2_0_epn
         assign mas2_0_epn[0:31] = {32{1'b0}};
         assign mas2_0_epn[32:51] = mas2_0_epn_q[32:51];
      end
   endgenerate
   generate
      if (`SPR_DATA_WIDTH == 64)
      begin : gen64_mas2_0_epn
         assign mas2_0_epn = mas2_0_epn_q;
      end
   endgenerate

   assign mas2_0_wimge = mas2_0_wimge_q;
   assign mas3_0_rpnl = mas3_0_rpnl_q;
   assign mas3_0_ubits = mas3_0_ubits_q;
   assign mas3_0_usxwr = mas3_0_usxwr_q;
   assign mas5_0_sgs = mas5_0_sgs_q;
   assign mas5_0_slpid = mas5_0_slpid_q;
   assign mas6_0_spid = mas6_0_spid_q;
   assign mas6_0_isize = mas6_0_isize_q;
   assign mas6_0_sind = mas6_0_sind_q;
   assign mas6_0_sas = mas6_0_sas_q;
   assign mas7_0_rpnu = mas7_0_rpnu_q;
   assign mas8_0_tgs = mas8_0_tgs_q;
   assign mas8_0_vf = mas8_0_vf_q;
   assign mas8_0_tlpid = mas8_0_tlpid_q;
`ifdef MM_THREADS2
   assign mas0_1_atsel = mas0_1_atsel_q;
   assign mas0_1_esel = mas0_1_esel_q;
   assign mas0_1_hes = mas0_1_hes_q;
   assign mas0_1_wq = mas0_1_wq_q;
   assign mas1_1_v = mas1_1_v_q;
   assign mas1_1_iprot = mas1_1_iprot_q;
   assign mas1_1_tid = mas1_1_tid_q;
   assign mas1_1_ind = mas1_1_ind_q;
   assign mas1_1_ts = mas1_1_ts_q;
   assign mas1_1_tsize = mas1_1_tsize_q;

   generate
      if (`SPR_DATA_WIDTH == 32)
      begin : gen32_mas2_1_epn
         assign mas2_1_epn[0:31] = {32{1'b0}};
         assign mas2_1_epn[32:51] = mas2_1_epn_q[32:51];
      end
   endgenerate
   generate
      if (`SPR_DATA_WIDTH == 64)
      begin : gen64_mas2_1_epn
         assign mas2_1_epn = mas2_1_epn_q;
      end
   endgenerate

   assign mas2_1_wimge = mas2_1_wimge_q;
   assign mas3_1_rpnl = mas3_1_rpnl_q;
   assign mas3_1_ubits = mas3_1_ubits_q;
   assign mas3_1_usxwr = mas3_1_usxwr_q;
   assign mas5_1_sgs = mas5_1_sgs_q;
   assign mas5_1_slpid = mas5_1_slpid_q;
   assign mas6_1_spid = mas6_1_spid_q;
   assign mas6_1_isize = mas6_1_isize_q;
   assign mas6_1_sind = mas6_1_sind_q;
   assign mas6_1_sas = mas6_1_sas_q;
   assign mas7_1_rpnu = mas7_1_rpnu_q;
   assign mas8_1_tgs = mas8_1_tgs_q;
   assign mas8_1_vf = mas8_1_vf_q;
   assign mas8_1_tlpid = mas8_1_tlpid_q;
`endif

   assign mmucsr0_tlb0fi = mmucsr0_tlb0fi_q;

`ifdef WAIT_UPDATES
`ifdef MM_THREADS2
   assign cp_mm_perf_except_taken_q[0] = cp_mm_except_taken_t0_q[0];
   assign cp_mm_perf_except_taken_q[1] = cp_mm_except_taken_t1_q[0];
   assign cp_mm_perf_except_taken_q[2:6] = (cp_mm_except_taken_t0_q[1:5] | cp_mm_except_taken_t1_q[1:5]);
`else
   assign cp_mm_perf_except_taken_q = cp_mm_except_taken_t0_q;
`endif
`endif


   // debug output formation
   //spr_dbg_slowspr_val_in          <= spr_ctl_in_q(0);  -- 0: val, 1: rw, 2: done
   //spr_dbg_slowspr_rw_in           <= spr_ctl_in_q(1);
   //spr_dbg_slowspr_etid_in         <= spr_etid_in_q;
   //spr_dbg_slowspr_addr_in         <= spr_addr_in_q;
   assign spr_dbg_slowspr_val_int = spr_ctl_int_q[0];
   assign spr_dbg_slowspr_rw_int = spr_ctl_int_q[1];
   assign spr_dbg_slowspr_etid_int = spr_etid_int_q;
   assign spr_dbg_slowspr_addr_int = spr_addr_int_q;
   assign spr_dbg_slowspr_val_out = spr_ctl_out_q[0];
   assign spr_dbg_slowspr_done_out = spr_ctl_out_q[2];
   assign spr_dbg_slowspr_data_out = spr_data_out_q;
   assign spr_dbg_match_64b = spr_match_64b_q;
   assign spr_dbg_match_any_mmu = spr_match_any_mmu_q;
   assign spr_dbg_match_any_mas = spr_match_any_mas_q;
   assign spr_dbg_match_mmucr1 = spr_match_mmucr1_q;
   assign spr_dbg_match_mmucr2 = spr_match_mmucr2_q;
   assign spr_dbg_match_lpidr = spr_match_lpidr_q;
   assign spr_dbg_match_mmucsr0 = spr_match_mmucsr0_q;
   assign spr_dbg_match_mmucfg = spr_match_mmucfg_q;
   assign spr_dbg_match_tlb0cfg = spr_match_tlb0cfg_q;
   assign spr_dbg_match_tlb0ps = spr_match_tlb0ps_q;
   assign spr_dbg_match_lratcfg = spr_match_lratcfg;
   assign spr_dbg_match_lratps = spr_match_lratps_q;
   assign spr_dbg_match_eptcfg = spr_match_eptcfg_q;
`ifdef MM_THREADS2
   assign spr_dbg_match_pid = spr_match_pid0_q | spr_match_pid1_q;
   assign spr_dbg_match_mmucr0 = spr_match_mmucr0_0_q | spr_match_mmucr0_1_q;
   assign spr_dbg_match_mmucr3 = spr_match_mmucr3_0_q | spr_match_mmucr3_1_q;
   assign spr_dbg_match_lper = spr_match_lper_0_q | spr_match_lper_1_q;
   assign spr_dbg_match_lperu = spr_match_lperu_0_q | spr_match_lperu_1_q;
   assign spr_dbg_match_mas0 = spr_match_mas0_0_q | spr_match_mas0_1_q;
   assign spr_dbg_match_mas1 = spr_match_mas1_0_q | spr_match_mas1_1_q;
   assign spr_dbg_match_mas2 = spr_match_mas2_0_q | spr_match_mas2_1_q;
   assign spr_dbg_match_mas2u = spr_match_mas2u_0_q | spr_match_mas2u_1_q;
   assign spr_dbg_match_mas3 = spr_match_mas3_0_q | spr_match_mas3_1_q;
   assign spr_dbg_match_mas4 = spr_match_mas4_0_q | spr_match_mas4_1_q;
   assign spr_dbg_match_mas5 = spr_match_mas5_0_q | spr_match_mas5_1_q;
   assign spr_dbg_match_mas6 = spr_match_mas6_0_q | spr_match_mas6_1_q;
   assign spr_dbg_match_mas7 = spr_match_mas7_0_q | spr_match_mas7_1_q;
   assign spr_dbg_match_mas8 = spr_match_mas8_0_q | spr_match_mas8_1_q;
   assign spr_dbg_match_mas01_64b = spr_match_mas01_64b_0_q | spr_match_mas01_64b_1_q;
   assign spr_dbg_match_mas56_64b = spr_match_mas56_64b_0_q | spr_match_mas56_64b_1_q;
   assign spr_dbg_match_mas73_64b = spr_match_mas73_64b_0_q | spr_match_mas73_64b_1_q;
   assign spr_dbg_match_mas81_64b = spr_match_mas81_64b_0_q | spr_match_mas81_64b_1_q;
`else
   assign spr_dbg_match_pid = spr_match_pid0_q;
   assign spr_dbg_match_mmucr0 = spr_match_mmucr0_0_q;
   assign spr_dbg_match_mmucr3 = spr_match_mmucr3_0_q;
   assign spr_dbg_match_lper = spr_match_lper_0_q;
   assign spr_dbg_match_lperu = spr_match_lperu_0_q;
   assign spr_dbg_match_mas0 = spr_match_mas0_0_q;
   assign spr_dbg_match_mas1 = spr_match_mas1_0_q;
   assign spr_dbg_match_mas2 = spr_match_mas2_0_q;
   assign spr_dbg_match_mas2u = spr_match_mas2u_0_q;
   assign spr_dbg_match_mas3 = spr_match_mas3_0_q;
   assign spr_dbg_match_mas4 = spr_match_mas4_0_q;
   assign spr_dbg_match_mas5 = spr_match_mas5_0_q;
   assign spr_dbg_match_mas6 = spr_match_mas6_0_q;
   assign spr_dbg_match_mas7 = spr_match_mas7_0_q;
   assign spr_dbg_match_mas8 = spr_match_mas8_0_q;
   assign spr_dbg_match_mas01_64b = spr_match_mas01_64b_0_q;
   assign spr_dbg_match_mas56_64b = spr_match_mas56_64b_0_q;
   assign spr_dbg_match_mas73_64b = spr_match_mas73_64b_0_q;
   assign spr_dbg_match_mas81_64b = spr_match_mas81_64b_0_q;
`endif

   // unused spare signal assignments
   assign unused_dc[0] = |(lcb_delay_lclkr_dc[1:4]);
   assign unused_dc[1] = |(lcb_mpw1_dc_b[1:4]);
   assign unused_dc[2] = pc_func_sl_force;
   assign unused_dc[3] = pc_func_sl_thold_0_b;
   assign unused_dc[4] = tc_scan_dis_dc_b;
   assign unused_dc[5] = tc_scan_diag_dc;
   assign unused_dc[6] = tc_lbist_en_dc;

generate
 if (`EXPAND_TYPE != 1)
  begin
   assign unused_dc[7] = |(mmucfg_q_b);
   assign unused_dc[8] = |(tlb0cfg_q_b);
   assign unused_dc[13] = |(bcfg_spare_q_b);
  end
  else
  begin
   assign unused_dc[7] = 1'b0;
   assign unused_dc[8] = 1'b0;
   assign unused_dc[13] = pc_cfg_sl_thold_0;
  end
endgenerate

   assign unused_dc[9]  = 1'b0;
   assign unused_dc[10] = 1'b0;
   assign unused_dc[11] = |(lrat_tag4_hit_entry);
   assign unused_dc[12] = |(bcfg_spare_q);

   //------------------------------------------------
   // latches
   //------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[cp_flush_offset:cp_flush_offset + `MM_THREADS - 1]),
      .scout(sov_0[cp_flush_offset:cp_flush_offset + `MM_THREADS - 1]),
      .din(cp_flush_d[0:`MM_THREADS - 1]),
      .dout(cp_flush_q[0:`MM_THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush_p1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[cp_flush_p1_offset:cp_flush_p1_offset + `MM_THREADS - 1]),
      .scout(sov_0[cp_flush_p1_offset:cp_flush_p1_offset + `MM_THREADS - 1]),
      .din(cp_flush_p1_d[0:`MM_THREADS - 1]),
      .dout(cp_flush_p1_q[0:`MM_THREADS - 1])
   );

   // slow spr daisy-chain latches

   tri_rlmreg_p #(.WIDTH(`SPR_CTL_WIDTH), .INIT(0), .NEEDS_SRESET(1)) spr_ctl_in_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_ctl_in_offset:spr_ctl_in_offset + `SPR_CTL_WIDTH - 1]),
      .scout(sov_0[spr_ctl_in_offset:spr_ctl_in_offset + `SPR_CTL_WIDTH - 1]),
      .din(spr_ctl_in_d[0:`SPR_CTL_WIDTH - 1]),
      .dout(spr_ctl_in_q[0:`SPR_CTL_WIDTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`SPR_ETID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) spr_etid_in_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_etid_in_offset:spr_etid_in_offset + `SPR_ETID_WIDTH - 1]),
      .scout(sov_0[spr_etid_in_offset:spr_etid_in_offset + `SPR_ETID_WIDTH - 1]),
      .din(spr_etid_in_d[0:`SPR_ETID_WIDTH - 1]),
      .dout(spr_etid_in_q[0:`SPR_ETID_WIDTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`SPR_ADDR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) spr_addr_in_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_addr_in_offset:spr_addr_in_offset + `SPR_ADDR_WIDTH - 1]),
      .scout(sov_0[spr_addr_in_offset:spr_addr_in_offset + `SPR_ADDR_WIDTH - 1]),
      .din(spr_addr_in_d[0:`SPR_ADDR_WIDTH - 1]),
      .dout(spr_addr_in_q[0:`SPR_ADDR_WIDTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`SPR_ADDR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) spr_addr_in_clone_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_addr_in_clone_offset:spr_addr_in_clone_offset + `SPR_ADDR_WIDTH - 1]),
      .scout(sov_1[spr_addr_in_clone_offset:spr_addr_in_clone_offset + `SPR_ADDR_WIDTH - 1]),
      .din(spr_addr_in_clone_d[0:`SPR_ADDR_WIDTH - 1]),
      .dout(spr_addr_in_clone_q[0:`SPR_ADDR_WIDTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`SPR_DATA_WIDTH), .INIT(0), .NEEDS_SRESET(1)) spr_data_in_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_data_in_offset:spr_data_in_offset + `SPR_DATA_WIDTH - 1]),
      .scout(sov_0[spr_data_in_offset:spr_data_in_offset + `SPR_DATA_WIDTH - 1]),
      .din(spr_data_in_d[64 - `SPR_DATA_WIDTH:63]),
      .dout(spr_data_in_q[64 - `SPR_DATA_WIDTH:63])
   );
   // these are the spr internal select stage latches below

   tri_rlmreg_p #(.WIDTH(`SPR_CTL_WIDTH), .INIT(0), .NEEDS_SRESET(1)) spr_ctl_int_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_val_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_ctl_int_offset:spr_ctl_int_offset + `SPR_CTL_WIDTH - 1]),
      .scout(sov_0[spr_ctl_int_offset:spr_ctl_int_offset + `SPR_CTL_WIDTH - 1]),
      .din(spr_ctl_int_d[0:`SPR_CTL_WIDTH - 1]),
      .dout(spr_ctl_int_q[0:`SPR_CTL_WIDTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`SPR_ETID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) spr_etid_int_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_val_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_etid_int_offset:spr_etid_int_offset + `SPR_ETID_WIDTH - 1]),
      .scout(sov_0[spr_etid_int_offset:spr_etid_int_offset + `SPR_ETID_WIDTH - 1]),
      .din(spr_etid_int_d[0:`SPR_ETID_WIDTH - 1]),
      .dout(spr_etid_int_q[0:`SPR_ETID_WIDTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`SPR_ADDR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) spr_addr_int_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_val_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_addr_int_offset:spr_addr_int_offset + `SPR_ADDR_WIDTH - 1]),
      .scout(sov_0[spr_addr_int_offset:spr_addr_int_offset + `SPR_ADDR_WIDTH - 1]),
      .din(spr_addr_int_d[0:`SPR_ADDR_WIDTH - 1]),
      .dout(spr_addr_int_q[0:`SPR_ADDR_WIDTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`SPR_DATA_WIDTH), .INIT(0), .NEEDS_SRESET(1)) spr_data_int_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_val_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_data_int_offset:spr_data_int_offset + `SPR_DATA_WIDTH - 1]),
      .scout(sov_0[spr_data_int_offset:spr_data_int_offset + `SPR_DATA_WIDTH - 1]),
      .din(spr_data_int_d[64 - `SPR_DATA_WIDTH:63]),
      .dout(spr_data_int_q[64 - `SPR_DATA_WIDTH:63])
   );
   // these are the spr out latches below

   tri_rlmreg_p #(.WIDTH(`SPR_CTL_WIDTH), .INIT(0), .NEEDS_SRESET(1)) spr_ctl_out_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_val_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_ctl_out_offset:spr_ctl_out_offset + `SPR_CTL_WIDTH - 1]),
      .scout(sov_0[spr_ctl_out_offset:spr_ctl_out_offset + `SPR_CTL_WIDTH - 1]),
      .din(spr_ctl_out_d[0:`SPR_CTL_WIDTH - 1]),
      .dout(spr_ctl_out_q[0:`SPR_CTL_WIDTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`SPR_ETID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) spr_etid_out_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_val_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_etid_out_offset:spr_etid_out_offset + `SPR_ETID_WIDTH - 1]),
      .scout(sov_0[spr_etid_out_offset:spr_etid_out_offset + `SPR_ETID_WIDTH - 1]),
      .din(spr_etid_out_d[0:`SPR_ETID_WIDTH - 1]),
      .dout(spr_etid_out_q[0:`SPR_ETID_WIDTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`SPR_ADDR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) spr_addr_out_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_val_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_addr_out_offset:spr_addr_out_offset + `SPR_ADDR_WIDTH - 1]),
      .scout(sov_0[spr_addr_out_offset:spr_addr_out_offset + `SPR_ADDR_WIDTH - 1]),
      .din(spr_addr_out_d[0:`SPR_ADDR_WIDTH - 1]),
      .dout(spr_addr_out_q[0:`SPR_ADDR_WIDTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`SPR_DATA_WIDTH), .INIT(0), .NEEDS_SRESET(1)) spr_data_out_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_val_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_data_out_offset:spr_data_out_offset + `SPR_DATA_WIDTH - 1]),
      .scout(sov_0[spr_data_out_offset:spr_data_out_offset + `SPR_DATA_WIDTH - 1]),
      .din(spr_data_out_d[64 - `SPR_DATA_WIDTH:63]),
      .dout(spr_data_out_q[64 - `SPR_DATA_WIDTH:63])
   );
   // spr decode match latches for timing

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_any_mmu_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_match_any_mmu_offset]),
      .scout(sov_0[spr_match_any_mmu_offset]),
      .din(spr_match_any_mmu),
      .dout(spr_match_any_mmu_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_pid0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_match_pid0_offset]),
      .scout(sov_0[spr_match_pid0_offset]),
      .din(spr_match_pid0),
      .dout(spr_match_pid0_q)
   );

`ifdef MM_THREADS2
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_pid1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_match_pid1_offset]),
      .scout(sov_0[spr_match_pid1_offset]),
      .din(spr_match_pid1),
      .dout(spr_match_pid1_q)
   );
`endif

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mmucr0_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_match_mmucr0_0_offset]),
      .scout(sov_0[spr_match_mmucr0_0_offset]),
      .din(spr_match_mmucr0_0),
      .dout(spr_match_mmucr0_0_q)
   );

`ifdef MM_THREADS2
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mmucr0_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_match_mmucr0_1_offset]),
      .scout(sov_0[spr_match_mmucr0_1_offset]),
      .din(spr_match_mmucr0_1),
      .dout(spr_match_mmucr0_1_q)
   );
`endif

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mmucr1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_match_mmucr1_offset]),
      .scout(sov_0[spr_match_mmucr1_offset]),
      .din(spr_match_mmucr1),
      .dout(spr_match_mmucr1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mmucr2_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_match_mmucr2_offset]),
      .scout(sov_0[spr_match_mmucr2_offset]),
      .din(spr_match_mmucr2),
      .dout(spr_match_mmucr2_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mmucr3_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_match_mmucr3_0_offset]),
      .scout(sov_0[spr_match_mmucr3_0_offset]),
      .din(spr_match_mmucr3_0),
      .dout(spr_match_mmucr3_0_q)
   );

`ifdef MM_THREADS2
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mmucr3_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_match_mmucr3_1_offset]),
      .scout(sov_0[spr_match_mmucr3_1_offset]),
      .din(spr_match_mmucr3_1),
      .dout(spr_match_mmucr3_1_q)
   );
`endif

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_lpidr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_match_lpidr_offset]),
      .scout(sov_0[spr_match_lpidr_offset]),
      .din(spr_match_lpidr),
      .dout(spr_match_lpidr_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mesr1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_match_mesr1_offset]),
      .scout(sov_0[spr_match_mesr1_offset]),
      .din(spr_match_mesr1),
      .dout(spr_match_mesr1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mesr2_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_match_mesr2_offset]),
      .scout(sov_0[spr_match_mesr2_offset]),
      .din(spr_match_mesr2),
      .dout(spr_match_mesr2_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mmucsr0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mmucsr0_offset]),
      .scout(sov_1[spr_match_mmucsr0_offset]),
      .din(spr_match_mmucsr0),
      .dout(spr_match_mmucsr0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mmucfg_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mmucfg_offset]),
      .scout(sov_1[spr_match_mmucfg_offset]),
      .din(spr_match_mmucfg),
      .dout(spr_match_mmucfg_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_tlb0cfg_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_tlb0cfg_offset]),
      .scout(sov_1[spr_match_tlb0cfg_offset]),
      .din(spr_match_tlb0cfg),
      .dout(spr_match_tlb0cfg_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_tlb0ps_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_tlb0ps_offset]),
      .scout(sov_1[spr_match_tlb0ps_offset]),
      .din(spr_match_tlb0ps),
      .dout(spr_match_tlb0ps_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_lratcfg_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_lratcfg_offset]),
      .scout(sov_1[spr_match_lratcfg_offset]),
      .din(spr_match_lratcfg),
      .dout(spr_match_lratcfg_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_lratps_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_lratps_offset]),
      .scout(sov_1[spr_match_lratps_offset]),
      .din(spr_match_lratps),
      .dout(spr_match_lratps_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_eptcfg_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_eptcfg_offset]),
      .scout(sov_1[spr_match_eptcfg_offset]),
      .din(spr_match_eptcfg),
      .dout(spr_match_eptcfg_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_lper_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_lper_0_offset]),
      .scout(sov_1[spr_match_lper_0_offset]),
      .din(spr_match_lper_0),
      .dout(spr_match_lper_0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_lperu_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_lperu_0_offset]),
      .scout(sov_1[spr_match_lperu_0_offset]),
      .din(spr_match_lperu_0),
      .dout(spr_match_lperu_0_q)
   );

`ifdef MM_THREADS2
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_lper_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_lper_1_offset]),
      .scout(sov_1[spr_match_lper_1_offset]),
      .din(spr_match_lper_1),
      .dout(spr_match_lper_1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_lperu_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_lperu_1_offset]),
      .scout(sov_1[spr_match_lperu_1_offset]),
      .din(spr_match_lperu_1),
      .dout(spr_match_lperu_1_q)
   );
`endif

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas0_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas0_0_offset]),
      .scout(sov_1[spr_match_mas0_0_offset]),
      .din(spr_match_mas0_0),
      .dout(spr_match_mas0_0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas1_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas1_0_offset]),
      .scout(sov_1[spr_match_mas1_0_offset]),
      .din(spr_match_mas1_0),
      .dout(spr_match_mas1_0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas2_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas2_0_offset]),
      .scout(sov_1[spr_match_mas2_0_offset]),
      .din(spr_match_mas2_0),
      .dout(spr_match_mas2_0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas3_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas3_0_offset]),
      .scout(sov_1[spr_match_mas3_0_offset]),
      .din(spr_match_mas3_0),
      .dout(spr_match_mas3_0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas4_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas4_0_offset]),
      .scout(sov_1[spr_match_mas4_0_offset]),
      .din(spr_match_mas4_0),
      .dout(spr_match_mas4_0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas5_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas5_0_offset]),
      .scout(sov_1[spr_match_mas5_0_offset]),
      .din(spr_match_mas5_0),
      .dout(spr_match_mas5_0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas6_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas6_0_offset]),
      .scout(sov_1[spr_match_mas6_0_offset]),
      .din(spr_match_mas6_0),
      .dout(spr_match_mas6_0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas7_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas7_0_offset]),
      .scout(sov_1[spr_match_mas7_0_offset]),
      .din(spr_match_mas7_0),
      .dout(spr_match_mas7_0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas8_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas8_0_offset]),
      .scout(sov_1[spr_match_mas8_0_offset]),
      .din(spr_match_mas8_0),
      .dout(spr_match_mas8_0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas2u_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas2u_0_offset]),
      .scout(sov_1[spr_match_mas2u_0_offset]),
      .din(spr_match_mas2u_0),
      .dout(spr_match_mas2u_0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas01_64b_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas01_64b_0_offset]),
      .scout(sov_1[spr_match_mas01_64b_0_offset]),
      .din(spr_match_mas01_64b_0),
      .dout(spr_match_mas01_64b_0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas56_64b_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas56_64b_0_offset]),
      .scout(sov_1[spr_match_mas56_64b_0_offset]),
      .din(spr_match_mas56_64b_0),
      .dout(spr_match_mas56_64b_0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas73_64b_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas73_64b_0_offset]),
      .scout(sov_1[spr_match_mas73_64b_0_offset]),
      .din(spr_match_mas73_64b_0),
      .dout(spr_match_mas73_64b_0_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas81_64b_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas81_64b_0_offset]),
      .scout(sov_1[spr_match_mas81_64b_0_offset]),
      .din(spr_match_mas81_64b_0),
      .dout(spr_match_mas81_64b_0_q)
   );

`ifdef MM_THREADS2
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas0_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas0_1_offset]),
      .scout(sov_1[spr_match_mas0_1_offset]),
      .din(spr_match_mas0_1),
      .dout(spr_match_mas0_1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas1_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas1_1_offset]),
      .scout(sov_1[spr_match_mas1_1_offset]),
      .din(spr_match_mas1_1),
      .dout(spr_match_mas1_1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas2_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas2_1_offset]),
      .scout(sov_1[spr_match_mas2_1_offset]),
      .din(spr_match_mas2_1),
      .dout(spr_match_mas2_1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas3_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas3_1_offset]),
      .scout(sov_1[spr_match_mas3_1_offset]),
      .din(spr_match_mas3_1),
      .dout(spr_match_mas3_1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas4_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas4_1_offset]),
      .scout(sov_1[spr_match_mas4_1_offset]),
      .din(spr_match_mas4_1),
      .dout(spr_match_mas4_1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas5_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas5_1_offset]),
      .scout(sov_1[spr_match_mas5_1_offset]),
      .din(spr_match_mas5_1),
      .dout(spr_match_mas5_1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas6_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas6_1_offset]),
      .scout(sov_1[spr_match_mas6_1_offset]),
      .din(spr_match_mas6_1),
      .dout(spr_match_mas6_1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas7_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas7_1_offset]),
      .scout(sov_1[spr_match_mas7_1_offset]),
      .din(spr_match_mas7_1),
      .dout(spr_match_mas7_1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas8_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas8_1_offset]),
      .scout(sov_1[spr_match_mas8_1_offset]),
      .din(spr_match_mas8_1),
      .dout(spr_match_mas8_1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas2u_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas2u_1_offset]),
      .scout(sov_1[spr_match_mas2u_1_offset]),
      .din(spr_match_mas2u_1),
      .dout(spr_match_mas2u_1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas01_64b_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas01_64b_1_offset]),
      .scout(sov_1[spr_match_mas01_64b_1_offset]),
      .din(spr_match_mas01_64b_1),
      .dout(spr_match_mas01_64b_1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas56_64b_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas56_64b_1_offset]),
      .scout(sov_1[spr_match_mas56_64b_1_offset]),
      .din(spr_match_mas56_64b_1),
      .dout(spr_match_mas56_64b_1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas73_64b_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas73_64b_1_offset]),
      .scout(sov_1[spr_match_mas73_64b_1_offset]),
      .din(spr_match_mas73_64b_1),
      .dout(spr_match_mas73_64b_1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_mas81_64b_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_mas81_64b_1_offset]),
      .scout(sov_1[spr_match_mas81_64b_1_offset]),
      .din(spr_match_mas81_64b_1),
      .dout(spr_match_mas81_64b_1_q)
   );
`endif

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_64b_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_64b_offset]),
      .scout(sov_1[spr_match_64b_offset]),
      .din(spr_match_64b),
      .dout(spr_match_64b_q)
   );
   // internal mas data output register

   tri_rlmreg_p #(.WIDTH(`SPR_DATA_WIDTH), .INIT(0), .NEEDS_SRESET(1)) spr_mas_data_out_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_mas_data_out_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_mas_data_out_offset:spr_mas_data_out_offset + `SPR_DATA_WIDTH - 1]),
      .scout(sov_1[spr_mas_data_out_offset:spr_mas_data_out_offset + `SPR_DATA_WIDTH - 1]),
      .din(spr_mas_data_out[64 - `SPR_DATA_WIDTH:63]),
      .dout(spr_mas_data_out_q[64 - `SPR_DATA_WIDTH:63])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_match_any_mas_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_match_mas_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spr_match_any_mas_offset]),
      .scout(sov_1[spr_match_any_mas_offset]),
      .din(spr_match_any_mas),
      .dout(spr_match_any_mas_q)
   );
   // pid spr's

   tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) pid0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_mmu_act_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[pid0_offset:pid0_offset + `PID_WIDTH - 1]),
      .scout(sov_0[pid0_offset:pid0_offset + `PID_WIDTH - 1]),
      .din(pid0_d[0:`PID_WIDTH - 1]),
      .dout(pid0_q[0:`PID_WIDTH - 1])
   );

`ifdef MM_THREADS2
   tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) pid1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_mmu_act_q[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[pid1_offset:pid1_offset + `PID_WIDTH - 1]),
      .scout(sov_0[pid1_offset:pid1_offset + `PID_WIDTH - 1]),
      .din(pid1_d[0:`PID_WIDTH - 1]),
      .dout(pid1_q[0:`PID_WIDTH - 1])
   );
`endif

   tri_rlmreg_p #(.WIDTH(`MMUCR0_WIDTH), .INIT(0), .NEEDS_SRESET(1)) mmucr0_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[mmucr0_0_offset:mmucr0_0_offset + `MMUCR0_WIDTH - 1]),
      .scout(sov_0[mmucr0_0_offset:mmucr0_0_offset + `MMUCR0_WIDTH - 1]),
      .din(mmucr0_0_d[0:`MMUCR0_WIDTH - 1]),
      .dout(mmucr0_0_q[0:`MMUCR0_WIDTH - 1])
   );

`ifdef MM_THREADS2
   tri_rlmreg_p #(.WIDTH(`MMUCR0_WIDTH), .INIT(0), .NEEDS_SRESET(1)) mmucr0_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[mmucr0_1_offset:mmucr0_1_offset + `MMUCR0_WIDTH - 1]),
      .scout(sov_0[mmucr0_1_offset:mmucr0_1_offset + `MMUCR0_WIDTH - 1]),
      .din(mmucr0_1_d[0:`MMUCR0_WIDTH - 1]),
      .dout(mmucr0_1_q[0:`MMUCR0_WIDTH - 1])
   );
`endif

   tri_rlmreg_p #(.WIDTH(`MMUCR1_WIDTH), .INIT(BCFG_MMUCR1_VALUE), .NEEDS_SRESET(1)) mmucr1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_cfg_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_cfg_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(bsiv[mmucr1_offset:mmucr1_offset + `MMUCR1_WIDTH - 1]),
      .scout(bsov[mmucr1_offset:mmucr1_offset + `MMUCR1_WIDTH - 1]),
      .din(mmucr1_d[0:`MMUCR1_WIDTH - 1]),
      .dout(mmucr1_q[0:`MMUCR1_WIDTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`MMUCR2_WIDTH), .INIT(BCFG_MMUCR2_VALUE), .NEEDS_SRESET(1)) mmucr2_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_cfg_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_cfg_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(bsiv[mmucr2_offset:mmucr2_offset + `MMUCR2_WIDTH - 1]),
      .scout(bsov[mmucr2_offset:mmucr2_offset + `MMUCR2_WIDTH - 1]),
      .din(mmucr2_d[0:`MMUCR2_WIDTH - 1]),
      .dout(mmucr2_q[0:`MMUCR2_WIDTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`MMUCR3_WIDTH), .INIT(BCFG_MMUCR3_VALUE), .NEEDS_SRESET(1)) mmucr3_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_cfg_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_cfg_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(bsiv[mmucr3_0_offset:mmucr3_0_offset + `MMUCR3_WIDTH - 1]),
      .scout(bsov[mmucr3_0_offset:mmucr3_0_offset + `MMUCR3_WIDTH - 1]),
      .din(mmucr3_0_d[64 - `MMUCR3_WIDTH:63]),
      .dout(mmucr3_0_q[64 - `MMUCR3_WIDTH:63])
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) tstmode4k_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_cfg_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_cfg_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(bsiv[tstmode4k_0_offset:tstmode4k_0_offset + 3]),
      .scout(bsov[tstmode4k_0_offset:tstmode4k_0_offset + 3]),
      .din(tstmode4k_0_d),
      .dout(tstmode4k_0_q)
   );

`ifdef MM_THREADS2
   tri_rlmreg_p #(.WIDTH(`MMUCR3_WIDTH), .INIT(BCFG_MMUCR3_VALUE), .NEEDS_SRESET(1)) mmucr3_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_cfg_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_cfg_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(bsiv[mmucr3_1_offset:mmucr3_1_offset + `MMUCR3_WIDTH - 1]),
      .scout(bsov[mmucr3_1_offset:mmucr3_1_offset + `MMUCR3_WIDTH - 1]),
      .din(mmucr3_1_d[64 - `MMUCR3_WIDTH:63]),
      .dout(mmucr3_1_q[64 - `MMUCR3_WIDTH:63])
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) tstmode4k_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_cfg_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_cfg_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(bsiv[tstmode4k_1_offset:tstmode4k_1_offset + 3]),
      .scout(bsov[tstmode4k_1_offset:tstmode4k_1_offset + 3]),
      .din(tstmode4k_1_d),
      .dout(tstmode4k_1_q)
   );

`endif

   tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lpidr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_mmu_act_q[`MM_THREADS]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[lpidr_offset:lpidr_offset + `LPID_WIDTH - 1]),
      .scout(sov_0[lpidr_offset:lpidr_offset + `LPID_WIDTH - 1]),
      .din(lpidr_d[0:`LPID_WIDTH - 1]),
      .dout(lpidr_q[0:`LPID_WIDTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`MESR1_WIDTH), .INIT(0), .NEEDS_SRESET(1)) mesr1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_mmu_act_q[`MM_THREADS]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[mesr1_offset:mesr1_offset + `MESR1_WIDTH - 1]),
      .scout(sov_0[mesr1_offset:mesr1_offset + `MESR1_WIDTH - 1]),
      .din(mesr1_d),
      .dout(mesr1_q)
   );

   tri_rlmreg_p #(.WIDTH(`MESR2_WIDTH), .INIT(0), .NEEDS_SRESET(1)) mesr2_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(spr_mmu_act_q[`MM_THREADS]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[mesr2_offset:mesr2_offset + `MESR2_WIDTH - 1]),
      .scout(sov_0[mesr2_offset:mesr2_offset + `MESR2_WIDTH - 1]),
      .din(mesr2_d),
      .dout(mesr2_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas0_0_atsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas0_0_atsel_offset]),
      .scout(sov_1[mas0_0_atsel_offset]),
      .din(mas0_0_atsel_d),
      .dout(mas0_0_atsel_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) mas0_0_esel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas0_0_esel_offset:mas0_0_esel_offset + 3 - 1]),
      .scout(sov_1[mas0_0_esel_offset:mas0_0_esel_offset + 3 - 1]),
      .din(mas0_0_esel_d[0:3 - 1]),
      .dout(mas0_0_esel_q[0:3 - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas0_0_hes_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas0_0_hes_offset]),
      .scout(sov_1[mas0_0_hes_offset]),
      .din(mas0_0_hes_d),
      .dout(mas0_0_hes_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) mas0_0_wq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas0_0_wq_offset:mas0_0_wq_offset + 2 - 1]),
      .scout(sov_1[mas0_0_wq_offset:mas0_0_wq_offset + 2 - 1]),
      .din(mas0_0_wq_d[0:2 - 1]),
      .dout(mas0_0_wq_q[0:2 - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas1_0_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas1_0_v_offset]),
      .scout(sov_1[mas1_0_v_offset]),
      .din(mas1_0_v_d),
      .dout(mas1_0_v_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas1_0_iprot_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas1_0_iprot_offset]),
      .scout(sov_1[mas1_0_iprot_offset]),
      .din(mas1_0_iprot_d),
      .dout(mas1_0_iprot_q)
   );

   tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) mas1_0_tid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas1_0_tid_offset:mas1_0_tid_offset + 14 - 1]),
      .scout(sov_1[mas1_0_tid_offset:mas1_0_tid_offset + 14 - 1]),
      .din(mas1_0_tid_d[0:`PID_WIDTH - 1]),
      .dout(mas1_0_tid_q[0:`PID_WIDTH - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas1_0_ind_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas1_0_ind_offset]),
      .scout(sov_1[mas1_0_ind_offset]),
      .din(mas1_0_ind_d),
      .dout(mas1_0_ind_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas1_0_ts_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas1_0_ts_offset]),
      .scout(sov_1[mas1_0_ts_offset]),
      .din(mas1_0_ts_d),
      .dout(mas1_0_ts_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) mas1_0_tsize_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas1_0_tsize_offset:mas1_0_tsize_offset + 4 - 1]),
      .scout(sov_1[mas1_0_tsize_offset:mas1_0_tsize_offset + 4 - 1]),
      .din(mas1_0_tsize_d[0:4 - 1]),
      .dout(mas1_0_tsize_q[0:4 - 1])
   );

   tri_rlmreg_p #(.WIDTH(52-(64-`SPR_DATA_WIDTH)), .INIT(0), .NEEDS_SRESET(1)) mas2_0_epn_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas2_0_epn_offset:mas2_0_epn_offset + (52-(64-`SPR_DATA_WIDTH)) - 1]),
      .scout(sov_1[mas2_0_epn_offset:mas2_0_epn_offset + (52-(64-`SPR_DATA_WIDTH)) - 1]),
      .din(mas2_0_epn_d[(64-`SPR_DATA_WIDTH):51]),
      .dout(mas2_0_epn_q[(64-`SPR_DATA_WIDTH):51])
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) mas2_0_wimge_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas2_0_wimge_offset:mas2_0_wimge_offset + 5 - 1]),
      .scout(sov_1[mas2_0_wimge_offset:mas2_0_wimge_offset + 5 - 1]),
      .din(mas2_0_wimge_d[0:5 - 1]),
      .dout(mas2_0_wimge_q[0:5 - 1])
   );

   tri_rlmreg_p #(.WIDTH(21), .INIT(0), .NEEDS_SRESET(1)) mas3_0_rpnl_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas3_0_rpnl_offset:mas3_0_rpnl_offset + 21 - 1]),
      .scout(sov_1[mas3_0_rpnl_offset:mas3_0_rpnl_offset + 21 - 1]),
      .din(mas3_0_rpnl_d[32:32 + 21 - 1]),
      .dout(mas3_0_rpnl_q[32:32 + 21 - 1])
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) mas3_0_ubits_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas3_0_ubits_offset:mas3_0_ubits_offset + 4 - 1]),
      .scout(sov_1[mas3_0_ubits_offset:mas3_0_ubits_offset + 4 - 1]),
      .din(mas3_0_ubits_d[0:4 - 1]),
      .dout(mas3_0_ubits_q[0:4 - 1])
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) mas3_0_usxwr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas3_0_usxwr_offset:mas3_0_usxwr_offset + 6 - 1]),
      .scout(sov_1[mas3_0_usxwr_offset:mas3_0_usxwr_offset + 6 - 1]),
      .din(mas3_0_usxwr_d[0:6 - 1]),
      .dout(mas3_0_usxwr_q[0:6 - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas4_0_indd_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_cfg_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_cfg_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(bsiv[mas4_0_indd_offset]),
      .scout(bsov[mas4_0_indd_offset]),
      .din(mas4_0_indd_d),
      .dout(mas4_0_indd_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(1), .NEEDS_SRESET(1)) mas4_0_tsized_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_cfg_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_cfg_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(bsiv[mas4_0_tsized_offset:mas4_0_tsized_offset + 4 - 1]),
      .scout(bsov[mas4_0_tsized_offset:mas4_0_tsized_offset + 4 - 1]),
      .din(mas4_0_tsized_d[0:4 - 1]),
      .dout(mas4_0_tsized_q[0:4 - 1])
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) mas4_0_wimged_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_cfg_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_cfg_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(bsiv[mas4_0_wimged_offset:mas4_0_wimged_offset + 5 - 1]),
      .scout(bsov[mas4_0_wimged_offset:mas4_0_wimged_offset + 5 - 1]),
      .din(mas4_0_wimged_d[0:5 - 1]),
      .dout(mas4_0_wimged_q[0:5 - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas5_0_sgs_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas5_0_sgs_offset]),
      .scout(sov_1[mas5_0_sgs_offset]),
      .din(mas5_0_sgs_d),
      .dout(mas5_0_sgs_q)
   );

   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) mas5_0_slpid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas5_0_slpid_offset:mas5_0_slpid_offset + 8 - 1]),
      .scout(sov_1[mas5_0_slpid_offset:mas5_0_slpid_offset + 8 - 1]),
      .din(mas5_0_slpid_d[0:8 - 1]),
      .dout(mas5_0_slpid_q[0:8 - 1])
   );

   tri_rlmreg_p #(.WIDTH(14), .INIT(0), .NEEDS_SRESET(1)) mas6_0_spid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas6_0_spid_offset:mas6_0_spid_offset + 14 - 1]),
      .scout(sov_1[mas6_0_spid_offset:mas6_0_spid_offset + 14 - 1]),
      .din(mas6_0_spid_d[0:14 - 1]),
      .dout(mas6_0_spid_q[0:14 - 1])
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) mas6_0_isize_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas6_0_isize_offset:mas6_0_isize_offset + 4 - 1]),
      .scout(sov_1[mas6_0_isize_offset:mas6_0_isize_offset + 4 - 1]),
      .din(mas6_0_isize_d[0:4 - 1]),
      .dout(mas6_0_isize_q[0:4 - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas6_0_sind_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas6_0_sind_offset]),
      .scout(sov_1[mas6_0_sind_offset]),
      .din(mas6_0_sind_d),
      .dout(mas6_0_sind_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas6_0_sas_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas6_0_sas_offset]),
      .scout(sov_1[mas6_0_sas_offset]),
      .din(mas6_0_sas_d),
      .dout(mas6_0_sas_q)
   );

   tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) mas7_0_rpnu_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas7_0_rpnu_offset:mas7_0_rpnu_offset + 10 - 1]),
      .scout(sov_1[mas7_0_rpnu_offset:mas7_0_rpnu_offset + 10 - 1]),
      .din(mas7_0_rpnu_d[22:22 + 10 - 1]),
      .dout(mas7_0_rpnu_q[22:22 + 10 - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas8_0_tgs_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas8_0_tgs_offset]),
      .scout(sov_1[mas8_0_tgs_offset]),
      .din(mas8_0_tgs_d),
      .dout(mas8_0_tgs_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas8_0_vf_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas8_0_vf_offset]),
      .scout(sov_1[mas8_0_vf_offset]),
      .din(mas8_0_vf_d),
      .dout(mas8_0_vf_q)
   );

   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) mas8_0_tlpid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas8_0_tlpid_offset:mas8_0_tlpid_offset + 8 - 1]),
      .scout(sov_1[mas8_0_tlpid_offset:mas8_0_tlpid_offset + 8 - 1]),
      .din(mas8_0_tlpid_d[0:8 - 1]),
      .dout(mas8_0_tlpid_q[0:8 - 1])
   );

`ifdef MM_THREADS2
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas0_1_atsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas0_1_atsel_offset]),
      .scout(sov_1[mas0_1_atsel_offset]),
      .din(mas0_1_atsel_d),
      .dout(mas0_1_atsel_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) mas0_1_esel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas0_1_esel_offset:mas0_1_esel_offset + 3 - 1]),
      .scout(sov_1[mas0_1_esel_offset:mas0_1_esel_offset + 3 - 1]),
      .din(mas0_1_esel_d[0:3 - 1]),
      .dout(mas0_1_esel_q[0:3 - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas0_1_hes_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas0_1_hes_offset]),
      .scout(sov_1[mas0_1_hes_offset]),
      .din(mas0_1_hes_d),
      .dout(mas0_1_hes_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) mas0_1_wq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas0_1_wq_offset:mas0_1_wq_offset + 2 - 1]),
      .scout(sov_1[mas0_1_wq_offset:mas0_1_wq_offset + 2 - 1]),
      .din(mas0_1_wq_d[0:2 - 1]),
      .dout(mas0_1_wq_q[0:2 - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas1_1_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas1_1_v_offset]),
      .scout(sov_1[mas1_1_v_offset]),
      .din(mas1_1_v_d),
      .dout(mas1_1_v_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas1_1_iprot_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas1_1_iprot_offset]),
      .scout(sov_1[mas1_1_iprot_offset]),
      .din(mas1_1_iprot_d),
      .dout(mas1_1_iprot_q)
   );

   tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) mas1_1_tid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas1_1_tid_offset:mas1_1_tid_offset + 14 - 1]),
      .scout(sov_1[mas1_1_tid_offset:mas1_1_tid_offset + 14 - 1]),
      .din(mas1_1_tid_d[0:`PID_WIDTH - 1]),
      .dout(mas1_1_tid_q[0:`PID_WIDTH - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas1_1_ind_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas1_1_ind_offset]),
      .scout(sov_1[mas1_1_ind_offset]),
      .din(mas1_1_ind_d),
      .dout(mas1_1_ind_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas1_1_ts_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas1_1_ts_offset]),
      .scout(sov_1[mas1_1_ts_offset]),
      .din(mas1_1_ts_d),
      .dout(mas1_1_ts_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) mas1_1_tsize_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas1_1_tsize_offset:mas1_1_tsize_offset + 4 - 1]),
      .scout(sov_1[mas1_1_tsize_offset:mas1_1_tsize_offset + 4 - 1]),
      .din(mas1_1_tsize_d[0:4 - 1]),
      .dout(mas1_1_tsize_q[0:4 - 1])
   );

   tri_rlmreg_p #(.WIDTH(52-(64-`SPR_DATA_WIDTH)), .INIT(0), .NEEDS_SRESET(1)) mas2_1_epn_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas2_1_epn_offset:mas2_1_epn_offset + (52-(64-`SPR_DATA_WIDTH)) - 1]),
      .scout(sov_1[mas2_1_epn_offset:mas2_1_epn_offset + (52-(64-`SPR_DATA_WIDTH)) - 1]),
      .din(mas2_1_epn_d[(64-`SPR_DATA_WIDTH):51]),
      .dout(mas2_1_epn_q[(64-`SPR_DATA_WIDTH):51])
   );


   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) mas2_1_wimge_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas2_1_wimge_offset:mas2_1_wimge_offset + 5 - 1]),
      .scout(sov_1[mas2_1_wimge_offset:mas2_1_wimge_offset + 5 - 1]),
      .din(mas2_1_wimge_d[0:5 - 1]),
      .dout(mas2_1_wimge_q[0:5 - 1])
   );

   tri_rlmreg_p #(.WIDTH(21), .INIT(0), .NEEDS_SRESET(1)) mas3_1_rpnl_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas3_1_rpnl_offset:mas3_1_rpnl_offset + 21 - 1]),
      .scout(sov_1[mas3_1_rpnl_offset:mas3_1_rpnl_offset + 21 - 1]),
      .din(mas3_1_rpnl_d[32:32 + 21 - 1]),
      .dout(mas3_1_rpnl_q[32:32 + 21 - 1])
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) mas3_1_ubits_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas3_1_ubits_offset:mas3_1_ubits_offset + 4 - 1]),
      .scout(sov_1[mas3_1_ubits_offset:mas3_1_ubits_offset + 4 - 1]),
      .din(mas3_1_ubits_d[0:4 - 1]),
      .dout(mas3_1_ubits_q[0:4 - 1])
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) mas3_1_usxwr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas3_1_usxwr_offset:mas3_1_usxwr_offset + 6 - 1]),
      .scout(sov_1[mas3_1_usxwr_offset:mas3_1_usxwr_offset + 6 - 1]),
      .din(mas3_1_usxwr_d[0:6 - 1]),
      .dout(mas3_1_usxwr_q[0:6 - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas4_1_indd_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_cfg_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_cfg_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(bsiv[mas4_1_indd_offset]),
      .scout(bsov[mas4_1_indd_offset]),
      .din(mas4_1_indd_d),
      .dout(mas4_1_indd_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(1), .NEEDS_SRESET(1)) mas4_1_tsized_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_cfg_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_cfg_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(bsiv[mas4_1_tsized_offset:mas4_1_tsized_offset + 4 - 1]),
      .scout(bsov[mas4_1_tsized_offset:mas4_1_tsized_offset + 4 - 1]),
      .din(mas4_1_tsized_d[0:4 - 1]),
      .dout(mas4_1_tsized_q[0:4 - 1])
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) mas4_1_wimged_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_cfg_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_cfg_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(bsiv[mas4_1_wimged_offset:mas4_1_wimged_offset + 5 - 1]),
      .scout(bsov[mas4_1_wimged_offset:mas4_1_wimged_offset + 5 - 1]),
      .din(mas4_1_wimged_d[0:5 - 1]),
      .dout(mas4_1_wimged_q[0:5 - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas5_1_sgs_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas5_1_sgs_offset]),
      .scout(sov_1[mas5_1_sgs_offset]),
      .din(mas5_1_sgs_d),
      .dout(mas5_1_sgs_q)
   );

   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) mas5_1_slpid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas5_1_slpid_offset:mas5_1_slpid_offset + 8 - 1]),
      .scout(sov_1[mas5_1_slpid_offset:mas5_1_slpid_offset + 8 - 1]),
      .din(mas5_1_slpid_d[0:8 - 1]),
      .dout(mas5_1_slpid_q[0:8 - 1])
   );

   tri_rlmreg_p #(.WIDTH(14), .INIT(0), .NEEDS_SRESET(1)) mas6_1_spid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas6_1_spid_offset:mas6_1_spid_offset + 14 - 1]),
      .scout(sov_1[mas6_1_spid_offset:mas6_1_spid_offset + 14 - 1]),
      .din(mas6_1_spid_d[0:14 - 1]),
      .dout(mas6_1_spid_q[0:14 - 1])
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) mas6_1_isize_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas6_1_isize_offset:mas6_1_isize_offset + 4 - 1]),
      .scout(sov_1[mas6_1_isize_offset:mas6_1_isize_offset + 4 - 1]),
      .din(mas6_1_isize_d[0:4 - 1]),
      .dout(mas6_1_isize_q[0:4 - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas6_1_sind_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas6_1_sind_offset]),
      .scout(sov_1[mas6_1_sind_offset]),
      .din(mas6_1_sind_d),
      .dout(mas6_1_sind_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas6_1_sas_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas6_1_sas_offset]),
      .scout(sov_1[mas6_1_sas_offset]),
      .din(mas6_1_sas_d),
      .dout(mas6_1_sas_q)
   );

   tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) mas7_1_rpnu_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas7_1_rpnu_offset:mas7_1_rpnu_offset + 10 - 1]),
      .scout(sov_1[mas7_1_rpnu_offset:mas7_1_rpnu_offset + 10 - 1]),
      .din(mas7_1_rpnu_d[22:22 + 10 - 1]),
      .dout(mas7_1_rpnu_q[22:22 + 10 - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas8_1_tgs_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas8_1_tgs_offset]),
      .scout(sov_1[mas8_1_tgs_offset]),
      .din(mas8_1_tgs_d),
      .dout(mas8_1_tgs_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mas8_1_vf_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas8_1_vf_offset]),
      .scout(sov_1[mas8_1_vf_offset]),
      .din(mas8_1_vf_d),
      .dout(mas8_1_vf_q)
   );

   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) mas8_1_tlpid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mas8_1_tlpid_offset:mas8_1_tlpid_offset + 8 - 1]),
      .scout(sov_1[mas8_1_tlpid_offset:mas8_1_tlpid_offset + 8 - 1]),
      .din(mas8_1_tlpid_d[0:8 - 1]),
      .dout(mas8_1_tlpid_q[0:8 - 1])
   );
`endif

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mmucsr0_tlb0fi_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mmucsr0_tlb0fi_offset]),
      .scout(sov_1[mmucsr0_tlb0fi_offset]),
      .din(mmucsr0_tlb0fi_d),
      .dout(mmucsr0_tlb0fi_q)
   );

   tri_rlmreg_p #(.WIDTH(52-(64-`REAL_ADDR_WIDTH)), .INIT(0), .NEEDS_SRESET(1)) lper_0_alpn_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[lper_0_alpn_offset:lper_0_alpn_offset + (52 -(64-`REAL_ADDR_WIDTH)) - 1]),
      .scout(sov_1[lper_0_alpn_offset:lper_0_alpn_offset + (52 -(64-`REAL_ADDR_WIDTH)) - 1]),
      .din(lper_0_alpn_d),
      .dout(lper_0_alpn_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lper_0_lps_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[lper_0_lps_offset:lper_0_lps_offset + 4 - 1]),
      .scout(sov_1[lper_0_lps_offset:lper_0_lps_offset + 4 - 1]),
      .din(lper_0_lps_d),
      .dout(lper_0_lps_q)
   );

`ifdef MM_THREADS2
   tri_rlmreg_p #(.WIDTH(52 -(64-`REAL_ADDR_WIDTH)), .INIT(0), .NEEDS_SRESET(1)) lper_1_alpn_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[lper_1_alpn_offset:lper_1_alpn_offset + (52 -(64-`REAL_ADDR_WIDTH)) - 1]),
      .scout(sov_1[lper_1_alpn_offset:lper_1_alpn_offset + (52 -(64-`REAL_ADDR_WIDTH)) - 1]),
      .din(lper_1_alpn_d),
      .dout(lper_1_alpn_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lper_1_lps_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mas_update_pending_act[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[lper_1_lps_offset:lper_1_lps_offset + 4 - 1]),
      .scout(sov_1[lper_1_lps_offset:lper_1_lps_offset + 4 - 1]),
      .din(lper_1_lps_d),
      .dout(lper_1_lps_q)
   );
`endif

   tri_rlmreg_p #(.WIDTH(`MM_THREADS+1), .INIT(0), .NEEDS_SRESET(1)) spr_mmu_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_mmu_act_offset:spr_mmu_act_offset + `MM_THREADS+1 - 1]),
      .scout(sov_0[spr_mmu_act_offset:spr_mmu_act_offset + `MM_THREADS+1 - 1]),
      .din(spr_mmu_act_d),
      .dout(spr_mmu_act_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) spr_val_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spr_val_act_offset:spr_val_act_offset + 4 - 1]),
      .scout(sov_0[spr_val_act_offset:spr_val_act_offset + 4 - 1]),
      .din(spr_val_act_d),
      .dout(spr_val_act_q)
   );

`ifdef WAIT_UPDATES
   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) cp_mm_except_taken_t0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[cp_mm_except_taken_t0_offset:cp_mm_except_taken_t0_offset + 6 - 1]),
      .scout(sov_0[cp_mm_except_taken_t0_offset:cp_mm_except_taken_t0_offset + 6 - 1]),
      .din(cp_mm_except_taken_t0_d),
      .dout(cp_mm_except_taken_t0_q)
   );
   // cp_mm_except_taken
   // 0   - thdid/val
   // 1   - I=0/D=1
   // 2   - TLB miss
   // 3   - Storage int (TLBI/PTfault)
   // 4   - LRAT miss
   // 5   - Mcheck

   tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_mas_dtlb_error_pending_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
       .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_mas_dtlb_error_pending_offset:tlb_mas_dtlb_error_pending_offset + `MM_THREADS - 1]),
      .scout(sov_0[tlb_mas_dtlb_error_pending_offset:tlb_mas_dtlb_error_pending_offset + `MM_THREADS - 1]),
      .din(tlb_mas_dtlb_error_pending_d),
      .dout(tlb_mas_dtlb_error_pending_q)
   );

   tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_mas_itlb_error_pending_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_mas_itlb_error_pending_offset:tlb_mas_itlb_error_pending_offset + `MM_THREADS - 1]),
      .scout(sov_0[tlb_mas_itlb_error_pending_offset:tlb_mas_itlb_error_pending_offset + `MM_THREADS - 1]),
      .din(tlb_mas_itlb_error_pending_d),
      .dout(tlb_mas_itlb_error_pending_q)
   );

   tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_lper_we_pending_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_lper_we_pending_offset:tlb_lper_we_pending_offset + `MM_THREADS - 1]),
      .scout(sov_0[tlb_lper_we_pending_offset:tlb_lper_we_pending_offset + `MM_THREADS - 1]),
      .din(tlb_lper_we_pending_d),
      .dout(tlb_lper_we_pending_q)
   );

   tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_mmucr1_we_pending_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_mmucr1_we_pending_offset:tlb_mmucr1_we_pending_offset + `MM_THREADS - 1]),
      .scout(sov_0[tlb_mmucr1_we_pending_offset:tlb_mmucr1_we_pending_offset + `MM_THREADS - 1]),
      .din(tlb_mmucr1_we_pending_d),
      .dout(tlb_mmucr1_we_pending_q)
   );

   tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ierat_mmucr1_we_pending_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ierat_mmucr1_we_pending_offset:ierat_mmucr1_we_pending_offset + `MM_THREADS - 1]),
      .scout(sov_0[ierat_mmucr1_we_pending_offset:ierat_mmucr1_we_pending_offset + `MM_THREADS - 1]),
      .din(ierat_mmucr1_we_pending_d),
      .dout(ierat_mmucr1_we_pending_q)
   );

   tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) derat_mmucr1_we_pending_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[derat_mmucr1_we_pending_offset:derat_mmucr1_we_pending_offset + `MM_THREADS - 1]),
      .scout(sov_0[derat_mmucr1_we_pending_offset:derat_mmucr1_we_pending_offset + `MM_THREADS - 1]),
      .din(derat_mmucr1_we_pending_d),
      .dout(derat_mmucr1_we_pending_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_mas1_0_ts_error_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_mas1_0_ts_error_offset]),
      .scout(sov_0[tlb_mas1_0_ts_error_offset]),
      .din(tlb_mas1_0_ts_error_d),
      .dout(tlb_mas1_0_ts_error_q)
   );

   tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_mas1_0_tid_error_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_mas1_0_tid_error_offset:tlb_mas1_0_tid_error_offset + `PID_WIDTH - 1]),
      .scout(sov_0[tlb_mas1_0_tid_error_offset:tlb_mas1_0_tid_error_offset + `PID_WIDTH - 1]),
      .din(tlb_mas1_0_tid_error_d),
      .dout(tlb_mas1_0_tid_error_q)
   );

   tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_mas2_0_epn_error_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_mas2_0_epn_error_offset:tlb_mas2_0_epn_error_offset + `EPN_WIDTH - 1]),
      .scout(sov_0[tlb_mas2_0_epn_error_offset:tlb_mas2_0_epn_error_offset + `EPN_WIDTH - 1]),
      .din(tlb_mas2_0_epn_error_d),
      .dout(tlb_mas2_0_epn_error_q)
   );

   tri_rlmreg_p #(.WIDTH(`REAL_ADDR_WIDTH-12), .INIT(0), .NEEDS_SRESET(1)) tlb_lper_0_lpn_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_lper_0_lpn_offset:tlb_lper_0_lpn_offset + `REAL_ADDR_WIDTH-12 - 1]),
      .scout(sov_0[tlb_lper_0_lpn_offset:tlb_lper_0_lpn_offset + `REAL_ADDR_WIDTH-12 - 1]),
      .din(tlb_lper_0_lpn_d),
      .dout(tlb_lper_0_lpn_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) tlb_lper_0_lps_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_lper_0_lps_offset:tlb_lper_0_lps_offset + 4 - 1]),
      .scout(sov_0[tlb_lper_0_lps_offset:tlb_lper_0_lps_offset + 4 - 1]),
      .din(tlb_lper_0_lps_d),
      .dout(tlb_lper_0_lps_q)
   );

   tri_rlmreg_p #(.WIDTH(9), .INIT(0), .NEEDS_SRESET(1)) tlb_mmucr1_0_een_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_mmucr1_0_een_offset:tlb_mmucr1_0_een_offset + 9 - 1]),
      .scout(sov_0[tlb_mmucr1_0_een_offset:tlb_mmucr1_0_een_offset + 9 - 1]),
      .din(tlb_mmucr1_0_een_d),
      .dout(tlb_mmucr1_0_een_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ierat_mmucr1_0_een_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu_mm_ierat_mmucr1_we_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ierat_mmucr1_0_een_offset:ierat_mmucr1_0_een_offset + 4 - 1]),
      .scout(sov_0[ierat_mmucr1_0_een_offset:ierat_mmucr1_0_een_offset + 4 - 1]),
      .din(ierat_mmucr1_0_een_d),
      .dout(ierat_mmucr1_0_een_q)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) derat_mmucr1_0_een_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(xu_mm_derat_mmucr1_we_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[derat_mmucr1_0_een_offset:derat_mmucr1_0_een_offset + 5 - 1]),
      .scout(sov_0[derat_mmucr1_0_een_offset:derat_mmucr1_0_een_offset + 5 - 1]),
      .din(derat_mmucr1_0_een_d),
      .dout(derat_mmucr1_0_een_q)
   );


`ifdef MM_THREADS2
   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) cp_mm_except_taken_t1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[cp_mm_except_taken_t1_offset:cp_mm_except_taken_t1_offset + 6 - 1]),
      .scout(sov_0[cp_mm_except_taken_t1_offset:cp_mm_except_taken_t1_offset + 6 - 1]),
      .din(cp_mm_except_taken_t1_d),
      .dout(cp_mm_except_taken_t1_q)
   );
   // cp_mm_except_taken
   // 0   - thdid/val
   // 1   - I=0/D=1
   // 2   - TLB miss
   // 3   - Storage int (TLBI/PTfault)
   // 4   - LRAT miss
   // 5   - Mcheck

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_mas1_1_ts_error_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_mas1_1_ts_error_offset]),
      .scout(sov_0[tlb_mas1_1_ts_error_offset]),
      .din(tlb_mas1_1_ts_error_d),
      .dout(tlb_mas1_1_ts_error_q)
   );

   tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_mas1_1_tid_error_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_mas1_1_tid_error_offset:tlb_mas1_1_tid_error_offset + `PID_WIDTH - 1]),
      .scout(sov_0[tlb_mas1_1_tid_error_offset:tlb_mas1_1_tid_error_offset + `PID_WIDTH - 1]),
      .din(tlb_mas1_1_tid_error_d),
      .dout(tlb_mas1_1_tid_error_q)
   );

   tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_mas2_1_epn_error_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_mas2_1_epn_error_offset:tlb_mas2_1_epn_error_offset + `EPN_WIDTH - 1]),
      .scout(sov_0[tlb_mas2_1_epn_error_offset:tlb_mas2_1_epn_error_offset + `EPN_WIDTH - 1]),
      .din(tlb_mas2_1_epn_error_d),
      .dout(tlb_mas2_1_epn_error_q)
   );

   tri_rlmreg_p #(.WIDTH(`REAL_ADDR_WIDTH-12), .INIT(0), .NEEDS_SRESET(1)) tlb_lper_1_lpn_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_lper_1_lpn_offset:tlb_lper_1_lpn_offset + `REAL_ADDR_WIDTH-12 - 1]),
      .scout(sov_0[tlb_lper_1_lpn_offset:tlb_lper_1_lpn_offset + `REAL_ADDR_WIDTH-12 - 1]),
      .din(tlb_lper_1_lpn_d),
      .dout(tlb_lper_1_lpn_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) tlb_lper_1_lps_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_lper_1_lps_offset:tlb_lper_1_lps_offset + 4 - 1]),
      .scout(sov_0[tlb_lper_1_lps_offset:tlb_lper_1_lps_offset + 4 - 1]),
      .din(tlb_lper_1_lps_d),
      .dout(tlb_lper_1_lps_q)
   );

   tri_rlmreg_p #(.WIDTH(9), .INIT(0), .NEEDS_SRESET(1)) tlb_mmucr1_1_een_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cat_emf_act_q[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_mmucr1_1_een_offset:tlb_mmucr1_1_een_offset + 9 - 1]),
      .scout(sov_0[tlb_mmucr1_1_een_offset:tlb_mmucr1_1_een_offset + 9 - 1]),
      .din(tlb_mmucr1_1_een_d),
      .dout(tlb_mmucr1_1_een_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ierat_mmucr1_1_een_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu_mm_ierat_mmucr1_we_q[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ierat_mmucr1_1_een_offset:ierat_mmucr1_1_een_offset + 4 - 1]),
      .scout(sov_0[ierat_mmucr1_1_een_offset:ierat_mmucr1_1_een_offset + 4 - 1]),
      .din(ierat_mmucr1_1_een_d),
      .dout(ierat_mmucr1_1_een_q)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) derat_mmucr1_1_een_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(xu_mm_derat_mmucr1_we_q[1]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[derat_mmucr1_1_een_offset:derat_mmucr1_1_een_offset + 5 - 1]),
      .scout(sov_0[derat_mmucr1_1_een_offset:derat_mmucr1_1_een_offset + 5 - 1]),
      .din(derat_mmucr1_1_een_d),
      .dout(derat_mmucr1_1_een_q)
   );

`endif
`endif

   tri_rlmreg_p #(.WIDTH(4), .INIT(MMQ_SPR_CSWITCH_0TO3), .NEEDS_SRESET(1)) cswitch_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[cswitch_offset:cswitch_offset + 4 - 1]),
      .scout(sov_0[cswitch_offset:cswitch_offset + 4 - 1]),
      .din(cswitch_q),
      .dout(cswitch_q)
   );
   // cswitch0: 1=disable side affect of clearing I/D/TERRDET and EEN when reading mmucr1
   // cswitch1: 1=disable mmucr1.tlbwe_binv bit (make it look like it is reserved per dd1)
   // cswitch2: reserved
   // cswitch3: reserved

   tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) cat_emf_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[cat_emf_act_offset:cat_emf_act_offset + `MM_THREADS - 1]),
      .scout(sov_1[cat_emf_act_offset:cat_emf_act_offset + `MM_THREADS - 1]),
      .din(cat_emf_act_d),
      .dout(cat_emf_act_q)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) spare_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[spare_a_offset:spare_a_offset + 32 - 1]),
      .scout(sov_0[spare_a_offset:spare_a_offset + 32 - 1]),
      .din(spare_a_q),
      .dout(spare_a_q)
   );

   tri_rlmreg_p #(.WIDTH(64), .INIT(0), .NEEDS_SRESET(1)) spare_b_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spare_b_offset:spare_b_offset + 64 - 1]),
      .scout(sov_1[spare_b_offset:spare_b_offset + 64 - 1]),
      .din(spare_b_q),
      .dout(spare_b_q)
   );

   // non-scannable timing latches
   tri_regk #(.WIDTH(18), .INIT(0), .NEEDS_SRESET(0)) iu_mm_ierat_mmucr0_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_nsl_force),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_nsl_thold_0_b),
      .scin(tri_regk_unused_scan[0:17]),
      .scout(tri_regk_unused_scan[0:17]),
      .din(iu_mm_ierat_mmucr0),
      .dout(iu_mm_ierat_mmucr0_q)
   );

   tri_regk #(.WIDTH(18), .INIT(0), .NEEDS_SRESET(0)) xu_mm_derat_mmucr0_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_nsl_force),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_nsl_thold_0_b),
      .scin(tri_regk_unused_scan[18:35]),
      .scout(tri_regk_unused_scan[18:35]),
      .din(xu_mm_derat_mmucr0),
      .dout(xu_mm_derat_mmucr0_q)
   );

   tri_regk #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(0)) iu_mm_ierat_mmucr1_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_nsl_force),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_nsl_thold_0_b),
      .scin(tri_regk_unused_scan[36:39]),
      .scout(tri_regk_unused_scan[36:39]),
      .din(iu_mm_ierat_mmucr1),
      .dout(iu_mm_ierat_mmucr1_q)
   );

   tri_regk #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(0)) xu_mm_derat_mmucr1_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_nsl_force),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_nsl_thold_0_b),
      .scin(tri_regk_unused_scan[40:44]),
      .scout(tri_regk_unused_scan[40:44]),
      .din(xu_mm_derat_mmucr1),
      .dout(xu_mm_derat_mmucr1_q)
   );

   tri_regk #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(0)) iu_mm_ierat_mmucr1_we_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_nsl_force),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_nsl_thold_0_b),
      .scin(tri_regk_unused_scan[45:45+`MM_THREADS-1]),
      .scout(tri_regk_unused_scan[45:45+`MM_THREADS-1]),
      .din(iu_mm_ierat_mmucr1_we_d),
      .dout(iu_mm_ierat_mmucr1_we_q)
   );

   tri_regk #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(0)) xu_mm_derat_mmucr1_we_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_nsl_force),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_nsl_thold_0_b),
      .scin(tri_regk_unused_scan[45+`MM_THREADS:45+(2*`MM_THREADS)-1]),
      .scout(tri_regk_unused_scan[45+`MM_THREADS:45+(2*`MM_THREADS)-1]),
      .din(xu_mm_derat_mmucr1_we_d),
      .dout(xu_mm_derat_mmucr1_we_q)
   );

   tri_regk #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(0)) iu_mm_ierat_mmucr0_we_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_nsl_force),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_nsl_thold_0_b),
      .scin(tri_regk_unused_scan[45+(2*`MM_THREADS):45+(3*`MM_THREADS)-1]),
      .scout(tri_regk_unused_scan[45+(2*`MM_THREADS):45+(3*`MM_THREADS)-1]),
      .din(iu_mm_ierat_mmucr0_we),
      .dout(iu_mm_ierat_mmucr0_we_q)
   );

   tri_regk #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(0)) xu_mm_derat_mmucr0_we_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_nsl_force),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_nsl_thold_0_b),
      .scin(tri_regk_unused_scan[45+(3*`MM_THREADS):45+(4*`MM_THREADS)-1]),
      .scout(tri_regk_unused_scan[45+(3*`MM_THREADS):45+(4*`MM_THREADS)-1]),
      .din(xu_mm_derat_mmucr0_we),
      .dout(xu_mm_derat_mmucr0_we_q)
   );

   //------------------------------------------------
   // scan only latches for boot config
   //  mmucr1, mmucr2, and mmucr3 also in boot config
   //------------------------------------------------
   generate
      if (`EXPAND_TYPE != 1)
      begin : mpg_bcfg_gen

         tri_slat_scan #(.WIDTH(2), .INIT(BCFG_MMUCFG_VALUE), .RESET_INVERTS_SCAN(1'b1)) mmucfg_47to48_latch(
            .vd(vdd),
            .gd(gnd),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk),
            .scan_in(bsiv[mmucfg_offset:mmucfg_offset + 1]),
            .scan_out(bsov[mmucfg_offset:mmucfg_offset + 1]),
            .q(mmucfg_q[47:48]),
            .q_b(mmucfg_q_b[47:48])
         );

         tri_slat_scan #(.WIDTH(3), .INIT(BCFG_TLB0CFG_VALUE), .RESET_INVERTS_SCAN(1'b1)) tlb0cfg_45to47_latch(
            .vd(vdd),
            .gd(gnd),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk),
            .scan_in(bsiv[tlb0cfg_offset:tlb0cfg_offset + 2]),
            .scan_out(bsov[tlb0cfg_offset:tlb0cfg_offset + 2]),
            .q(tlb0cfg_q[45:47]),
            .q_b(tlb0cfg_q_b[45:47])
         );

         tri_slat_scan #(.WIDTH(16), .INIT(0), .RESET_INVERTS_SCAN(1'b1)) bcfg_spare_latch(
            .vd(vdd),
            .gd(gnd),
            .dclk(lcb_dclk),
            .lclk(lcb_lclk),
            .scan_in(bsiv[bcfg_spare_offset:bcfg_spare_offset + 16 - 1]),
            .scan_out(bsov[bcfg_spare_offset:bcfg_spare_offset + 16 - 1]),
            .q(bcfg_spare_q),
            .q_b(bcfg_spare_q_b)
         );

      // these terms in the absence of another lcbor component
      //  that drives the thold_b and force into the bcfg_lcb for slat's
      assign pc_cfg_sl_thold_0_b = (~pc_cfg_sl_thold_0);
      assign pc_cfg_sl_force = pc_sg_0;

      //------------------------------------------------
      // local clock buffer for boot config
      //------------------------------------------------

      tri_lcbs  bcfg_lcb(
         .vd(vdd),
         .gd(gnd),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .nclk(nclk),
         .force_t(pc_cfg_sl_force),
         .thold_b(pc_cfg_sl_thold_0_b),
         .dclk(lcb_dclk),
         .lclk(lcb_lclk)
      );

      end
   endgenerate

   generate
      if (`EXPAND_TYPE == 1)
      begin : fpga_bcfg_gen

         tri_rlmreg_p #(.WIDTH(2), .INIT(BCFG_MMUCFG_VALUE), .NEEDS_SRESET(1)) mmucfg_47to48_latch(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(tiup),
            .thold_b(pc_cfg_slp_sl_thold_0_b),
            .sg(pc_sg_0),
            .force_t(pc_cfg_slp_sl_force),
            .delay_lclkr(lcb_delay_lclkr_dc[0]),
            .mpw1_b(lcb_mpw1_dc_b[0]),
            .mpw2_b(lcb_mpw2_dc_b),
            .d_mode(lcb_d_mode_dc),
            .scin(bsiv[mmucfg_offset:mmucfg_offset + 1]),
            .scout(bsov[mmucfg_offset:mmucfg_offset + 1]),
            .din(mmucfg_q[47:48]),
            .dout(mmucfg_q[47:48])
         );

         tri_rlmreg_p #(.WIDTH(3), .INIT(BCFG_TLB0CFG_VALUE), .NEEDS_SRESET(1)) tlb0cfg_45to47_latch(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(tiup),
            .thold_b(pc_cfg_slp_sl_thold_0_b),
            .sg(pc_sg_0),
            .force_t(pc_cfg_slp_sl_force),
            .delay_lclkr(lcb_delay_lclkr_dc[0]),
            .mpw1_b(lcb_mpw1_dc_b[0]),
            .mpw2_b(lcb_mpw2_dc_b),
            .d_mode(lcb_d_mode_dc),
            .scin(bsiv[tlb0cfg_offset:tlb0cfg_offset + 2]),
            .scout(bsov[tlb0cfg_offset:tlb0cfg_offset + 2]),
            .din(tlb0cfg_q[45:47]),
            .dout(tlb0cfg_q[45:47])
         );

         tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) bcfg_spare_latch(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(tiup),
            .thold_b(pc_cfg_slp_sl_thold_0_b),
            .sg(pc_sg_0),
            .force_t(pc_cfg_slp_sl_force),
            .delay_lclkr(lcb_delay_lclkr_dc[0]),
            .mpw1_b(lcb_mpw1_dc_b[0]),
            .mpw2_b(lcb_mpw2_dc_b),
            .d_mode(lcb_d_mode_dc),
            .scin(bsiv[bcfg_spare_offset:bcfg_spare_offset + 16 - 1]),
            .scout(bsov[bcfg_spare_offset:bcfg_spare_offset + 16 - 1]),
            .din(bcfg_spare_q),
            .dout(bcfg_spare_q)
         );
      end
   endgenerate

   // Latch counts
   // 3319
   // spr_ctl_in_q   3
   // spr_etid_in_q  2
   // spr_addr_in_q  10
   // spr_data_in_q  64          79
   // spr_ctl_int_q   3
   // spr_etid_int_q  2
   // spr_addr_int_q  10
   // spr_data_int_q  64         79
   // spr_ctl_out_q   3
   // spr_etid_out_q  2
   // spr_addr_out_q  10
   // spr_data_out_q  64         79
   // lper_ 0:3 _alpn_q  30 x 4
   // lper_ 0:3 _lps_q    4 x 4  136
   // pid 0:3 _q       14 x 4
   // mmucr0_ 0:3 _q   20 x 4
   // mmucr1_q         32
   // mmucr2_q         32
   // mmucr3_ 0:3 _q   15 x 4
   // lpidr_q          8
   // mmucsr0_tlb0fi_q 1        269
   // mas0_<t>_atsel_q  1 x 4         : std_ulogic;
   // mas0_<t>_esel_q   3 x 4         : std_ulogic_vector(0 to 2);
   // mas0_<t>_hes_q    1 x 4             : std_ulogic;
   // mas0_<t>_wq_q     2 x 4               : std_ulogic_vector(0 to 1);
   // mas1_<t>_v_q      1 x 4                 : std_ulogic;
   // mas1_<t>_iprot_q  1 x 4       : std_ulogic;
   // mas1_<t>_tid_q   14 x 4             : std_ulogic_vector(0 to 13);
   // mas1_<t>_ind_q    1 x 4             : std_ulogic;
   // mas1_<t>_ts_q     1 x 4          : std_ulogic;
   // mas1_<t>_tsize_q  4 x 4         : std_ulogic_vector(0 to 3);
   // mas2_<t>_epn_q   52 x 4          : std_ulogic_vector(64-`SPR_DATA_WIDTH to 51);
   // mas2_<t>_wimge_q  5 x 4       : std_ulogic_vector(0 to 4);
   // mas3_<t>_rpnl_q  21 x 4         : std_ulogic_vector(32 to 52);
   // mas3_<t>_ubits_q  4 x 4       : std_ulogic_vector(0 to 3);
   // mas3_<t>_usxwr_q  6 x 4         : std_ulogic_vector(0 to 5);
   // mas4_<t>_indd_q   1 x 4           : std_ulogic;
   // mas4_<t>_tsized_q 4 x 4       : std_ulogic_vector(0 to 3);
   // mas4_<t>_wimged_q 5 x 4     : std_ulogic_vector(0 to 4);
   // mas5_<t>_sgs_q    1 x 4         : std_ulogic;
   // mas5_<t>_slpid_q  8 x 4       : std_ulogic_vector(0 to 7);
   // mas6_<t>_spid_q  14 x 4         : std_ulogic_vector(0 to 13);
   // mas6_<t>_isize_q  4 x 4       : std_ulogic_vector(0 to 3);
   // mas6_<t>_sind_q   1 x 4          : std_ulogic;
   // mas6_<t>_sas_q    1 x 4         : std_ulogic;
   // mas7_<t>_rpnu_q  10 x 4        : std_ulogic_vector(22 to 31);
   // mas8_<t>_tgs_q    1 x 4         : std_ulogic;
   // mas8_<t>_vf_q     1 x 4          : std_ulogic;
   // mas8_<t>_tlpid_q  8 x 4       : std_ulogic_vector(0 to 7);
   //       subtotal  176 x 4 = 704
   //--------------------------------------------------------------
   // total                    1346
   //------------------------------------------------
   //------------------------------------------------
   // thold/sg latches
   //------------------------------------------------

   tri_plat #(.WIDTH(7)) perv_2to1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ccflush_dc),
      .din( {pc_func_sl_thold_2, pc_func_slp_sl_thold_2, pc_cfg_sl_thold_2, pc_cfg_slp_sl_thold_2, pc_func_slp_nsl_thold_2, pc_sg_2, pc_fce_2} ),
      .q( {pc_func_sl_thold_1, pc_func_slp_sl_thold_1, pc_cfg_sl_thold_1, pc_cfg_slp_sl_thold_1, pc_func_slp_nsl_thold_1, pc_sg_1, pc_fce_1} )
   );

   tri_plat #(.WIDTH(7)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ccflush_dc),
      .din( {pc_func_sl_thold_1, pc_func_slp_sl_thold_1, pc_cfg_sl_thold_1, pc_cfg_slp_sl_thold_1, pc_func_slp_nsl_thold_1, pc_sg_1, pc_fce_1} ),
      .q( {pc_func_sl_thold_0, pc_func_slp_sl_thold_0, pc_cfg_sl_thold_0, pc_cfg_slp_sl_thold_0, pc_func_slp_nsl_thold_0, pc_sg_0, pc_fce_0} )
   );

   tri_lcbor perv_lcbor_func_sl(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(pc_func_sl_thold_0),
      .sg(pc_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(pc_func_sl_force),
      .thold_b(pc_func_sl_thold_0_b)
   );

   tri_lcbor perv_lcbor_func_slp_sl(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(pc_func_slp_sl_thold_0),
      .sg(pc_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(pc_func_slp_sl_force),
      .thold_b(pc_func_slp_sl_thold_0_b)
   );

   tri_lcbor perv_lcbor_cfg_slp_sl(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(pc_cfg_slp_sl_thold_0),
      .sg(pc_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(pc_cfg_slp_sl_force),
      .thold_b(pc_cfg_slp_sl_thold_0_b)
   );

   tri_lcbor perv_lcbor_func_slp_nsl(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(pc_func_slp_nsl_thold_0),
      .sg(pc_fce_0),
      .act_dis(tidn),
      .force_t(pc_func_slp_nsl_force),
      .thold_b(pc_func_slp_nsl_thold_0_b)
   );

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv_0[0:scan_right_0] = {sov_0[1:scan_right_0], ac_func_scan_in[0]};
   assign ac_func_scan_out[0] = sov_0[0];
   assign siv_1[0:scan_right_1] = {sov_1[1:scan_right_1], ac_func_scan_in[1]};
   assign ac_func_scan_out[1] = sov_1[0];
   assign bsiv[0:boot_scan_right] = {bsov[1:boot_scan_right], ac_bcfg_scan_in};
   assign ac_bcfg_scan_out = bsov[0];

      function Eq;
        input  a, b;
        reg  result;
          begin
            if (a == b)
            begin
              result = 1'b1;
            end
            else
            begin
               result = 1'b0;
            end
            Eq = result;
          end
       endfunction

endmodule
