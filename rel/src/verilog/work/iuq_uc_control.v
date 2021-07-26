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
//*
//* TITLE: Microcode Control
//*
//* NAME: iuq_uc_control.v
//*
//*********************************************************************

`include "tri_a2o.vh"


module iuq_uc_control(
   vdd,
   gnd,
   nclk,
   pc_iu_func_sl_thold_0_b,
   pc_iu_sg_0,
   force_t,
   d_mode,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   scan_in,
   scan_out,
   xu_iu_ucode_xer_val,
   xu_iu_ucode_xer,
   br_hold,
   flush_next,
   flush,
   flush_into_uc,
   np1_flush,
   flush_ifar,
   cp_uc_credit_free,
   cp_flush,
   uc_default_act,
   next_valid,
   new_command,
   new_instr,
   start_addr,
   xer_type,
   early_end,
   force_ep,
   fxm_type,
   new_cond,
   ra_valid,
   rom_ra,
   rom_act,
   data_valid,
   rom_data_even,
   rom_data_odd,
   rom_data_even_late,
   rom_data_odd_late,
   uc_val,
   uc_end,
   cplbuffer_full,
   ucode_valid,
   ucode_ifar_even,
   ucode_instr_even,
   ucode_instr_odd,
   ucode_ext_even,
   ucode_ext_odd
);
   //parameter                ucode_width = 72;


   inout                    vdd;

   inout                    gnd;

    (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]  nclk;
   input                    pc_iu_func_sl_thold_0_b;
   input                    pc_iu_sg_0;
   input                    force_t;
   input                    d_mode;
   input                    delay_lclkr;
   input                    mpw1_b;
   input                    mpw2_b;

    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                    scan_in;

    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                   scan_out;

   input                    xu_iu_ucode_xer_val;
   input [57:63]            xu_iu_ucode_xer;
   input                    br_hold;		// br_redirect requires hold on xer_type's
   input                    flush_next;		// Flush new instruction
   input                    flush;		// Flush current instruction
   input                    flush_into_uc;	// Flush back into the middle of uCode sequence
   input                    np1_flush;		// Skip flushed instruction and go to next
   input [43:61]            flush_ifar;		// ucode-style address & state to flush to
   input                    cp_uc_credit_free;
   input                    cp_flush;
   input                    uc_default_act;
   input                    next_valid;		// early signal for act
   input                    new_command;
   input [0:31]             new_instr;
   input [0:8]              start_addr;		// bit (9) is unused - always '0'
   input                    xer_type;		// instruction uses XER:  need to wait until XER guaranteed valid
   input                    early_end;
   input                    force_ep;
   input                    fxm_type;
   input                    new_cond;		// If '1', will skip lines with skip_cond bit set

   output                   ra_valid;
   output [0:8]             rom_ra;		// read address
   output                   rom_act;

   input                    data_valid;
   input [32:71]            rom_data_even;
   input [32:71]            rom_data_odd;
   input [0:31]             rom_data_even_late;
   input [0:31]             rom_data_odd_late;

   output                   uc_val;		// to uc_buffer
   output                   uc_end;		// to uc_buffer
   output                   cplbuffer_full;		// to uc_buffer

   output [0:1]             ucode_valid;
   output [42:61]           ucode_ifar_even;		// old: EFF_IFAR
   output [0:31]            ucode_instr_even;
   output [0:31]            ucode_instr_odd;
   output [0:3]             ucode_ext_even;		// RT, S1, S2, S3
   output [0:3]             ucode_ext_odd;		// RT, S1, S2, S3

   parameter                xu_iu_ucode_xer_offset = 0;
   parameter                xu_iu_ucode_xer_val_offset = xu_iu_ucode_xer_offset + 7;
   parameter                wait_for_xer_offset = xu_iu_ucode_xer_val_offset + 1;
   parameter                xer_val_occurred_offset = wait_for_xer_offset + 1;
   parameter                valid_offset = xer_val_occurred_offset + 1;
   parameter                instr_offset = valid_offset + 1;
   parameter                instr_even_late_offset = instr_offset + 32;
   parameter                instr_odd_late_offset = instr_even_late_offset + 32;
   parameter                sel_even_late_offset = instr_odd_late_offset + 32;
   parameter                sel_odd_late_offset = sel_even_late_offset + 12;
   parameter                early_end_offset = sel_odd_late_offset + 11;
   parameter                cond_offset = early_end_offset + 1;
   parameter                rom_addr_offset = cond_offset + 1;
   parameter                flush_to_odd_offset = rom_addr_offset + 9;
   parameter                inloop_offset = flush_to_odd_offset + 1;
   parameter                count_offset = inloop_offset + 1;
   parameter                skip_zero_offset = count_offset + 5;
   parameter                skip_to_np1_offset = skip_zero_offset + 1;
   parameter                force_ep_offset = skip_to_np1_offset + 1;
   parameter                fxm_type_offset = force_ep_offset + 1;
   parameter                ep_force_even_late_offset = fxm_type_offset + 1;
   parameter                ep_force_odd_late_offset = ep_force_even_late_offset + 1;
   parameter                scan_right = ep_force_odd_late_offset + 1 - 1;

   // Latches
   wire [57:63]             xu_iu_ucode_xer_d;
   wire                     xu_iu_ucode_xer_val_d;
   wire                     wait_for_xer_d;
   wire                     xer_val_occurred_d;
   wire                     valid_d;
   wire [0:31]              instr_d;
   wire                     early_end_d;
   wire                     cond_d;
   wire [0:8]               rom_addr_d;
   wire                     flush_to_odd_d;
   wire                     inLoop_d;
   wire [0:4]               count_d;
   wire                     skip_zero_d;
   wire                     skip_to_np1_d;

   wire [57:63]             xu_iu_ucode_xer_l2;
   wire                     xu_iu_ucode_xer_val_l2;
   wire                     wait_for_xer_l2;
   wire                     xer_val_occurred_l2;
   wire                     valid_l2;
   wire [0:31]              instr_l2;
   wire                     early_end_l2;
   wire                     cond_l2;
   wire [0:8]               rom_addr_l2;
   wire                     flush_to_odd_l2;
   wire                     inLoop_l2;
   wire [0:4]               count_l2;
   wire                     skip_zero_l2;
   wire                     skip_to_np1_l2;

   wire                     force_ep_d;
   wire                     force_ep_l2;
   wire                     fxm_type_d;
   wire                     fxm_type_l2;

   wire                     shift_fxm;

   //
   // Even
   wire [0:31]              template_code_even;
   wire                     uc_end_even;
   wire                     uc_end_early_even;
   wire                     loop_begin_even;
   wire                     loop_end_even;
   wire [0:2]               count_src_even;
   wire [0:3]               ext_even;
   wire                     sel0_5_even;
   wire [0:1]               sel6_10_even;
   wire [0:1]               sel11_15_even;
   wire [0:1]               sel16_20_even;
   wire [0:1]               sel21_25_even;
   wire                     sel26_30_even;
   wire                     sel31_even;
   wire                     cr_bf2fxm_even;		// for mtocrf
   wire                     skip_cond_even;
   wire                     skip_zero_even;
   wire                     skip_nop_even;
   wire [0:9]               loop_addr_even;
   wire [0:2]               loop_init_even;
   wire                     ep_instr_even;

   wire                     ucode_end_even;
   wire [0:7]               fxm;
   wire [0:31]              nop;
   wire [0:3]               nop_ext;
   wire                     use_nop_even;
   wire [0:31]              uc_instruction_even;

   //timing fixes
   wire                     sel0_5_even_late;
   wire [0:1]               sel6_10_even_late;
   wire [0:1]               sel11_15_even_late;
   wire [0:1]               sel16_20_even_late;
   wire [0:1]               sel21_25_even_late;
   wire                     sel26_30_even_late;
   wire                     sel31_even_late;
   wire                     use_nop_even_late;

   wire [0:11]              sel_even_late_d;
   wire [0:11]              sel_even_late_l2;
   wire                     ep_force_even_late_d;
   wire                     ep_force_even_late_l2;
   wire [0:31]              instr_even_late_d;
   wire [0:31]              instr_even_late_l2;

   //
   // Odd
   wire [0:31]              template_code_odd;
   wire                     uc_end_odd;
   wire                     uc_end_early_odd;
   wire                     loop_begin_odd;
   wire                     loop_end_odd;
   wire [0:2]               count_src_odd;
   wire [0:3]               ext_odd;
   wire                     sel0_5_odd;
   wire [0:1]               sel6_10_odd;
   wire [0:1]               sel11_15_odd;
   wire [0:1]               sel16_20_odd;
   wire [0:1]               sel21_25_odd;
   wire                     sel26_30_odd;
   wire                     sel31_odd;
   wire                     cr_bf2fxm_odd;		// for mtocrf
   wire                     skip_cond_odd;
   wire                     skip_zero_odd;
   wire                     skip_nop_odd;
   wire [0:9]               loop_addr_odd;
   wire [0:2]               loop_init_odd;
   wire                     ep_instr_odd;

   wire                     ucode_end_odd;
   wire [0:31]              uc_instruction_odd;

   //timing fixes
   wire                     sel0_5_odd_late;
   wire [0:1]               sel6_10_odd_late;
   wire [0:1]               sel11_15_odd_late;
   wire [0:1]               sel16_20_odd_late;
   wire [0:1]               sel21_25_odd_late;
   wire                     sel26_30_odd_late;
   wire                     sel31_odd_late;

   wire [0:10]              sel_odd_late_d;
   wire [0:10]              sel_odd_late_l2;
   wire                     ep_force_odd_late_d;
   wire                     ep_force_odd_late_l2;
   wire [0:31]              instr_odd_late_d;
   wire [0:31]              instr_odd_late_l2;

   //
   // Combined
   wire                     loop_begin;
   wire                     loop_end;
   wire [0:2]               count_src;
   wire                     skip_zero;
   wire [0:8]               loop_addr;		// bit (9) is unused (always '0')
   wire [0:2]               loop_init;

   wire                     ucode_end;

   // control
   wire                     last_loop;
   wire                     last_loop_fast;
   wire                     loopback;
   wire                     inc_RT;

   wire                     xer_act;
   wire [0:4]               NB_dec;
   wire [0:1]               NB_comp;
   wire [0:6]               XER_dec_z;
   wire [0:2]               XER_low;
   wire [0:1]               XER_comp;
   wire [0:4]               count_init;
   wire                     skip_even;
   wire                     skip_odd;

   wire [0:31]              buff_instr_in;
   wire                     cplbuffer_xer_act;
   wire                     cplbuffer_full_int;
   wire [0:31]              oldest_instr;
   wire [57:63]             oldest_xer;

   wire                     uc_control_act;

   wire                     tiup;

   wire [0:scan_right]      siv;
   wire [0:scan_right]      sov;
   wire                     buff_scan_in;
   wire                     buff_scan_out;


    (* analysis_not_referenced="true" *)

   wire [0:16]              unused;

   //tidn <= '0';
   assign tiup = 1'b1;

   //---------------------------------------------------------------------
   // load new command
   //---------------------------------------------------------------------

   //???? Add act once new_command timing is ok (everything except xu_iu_ucode_xer_val)
   //???? uc_act <= new_command or valid_l2;
   assign uc_control_act = flush_into_uc | next_valid | data_valid;
   assign rom_act = uc_control_act;

   // Wait for 1 cycle after getting new command to allow IU to flush

   assign valid_d = ((new_command & (~flush_next)) | (valid_l2 & (~(ucode_end & data_valid)) & (~flush))) | flush_into_uc;

   assign uc_val = valid_l2;

   // Don't need br_hold anymore because new_command checks this
   assign wait_for_xer_d = (flush == 1'b1) ? 1'b0 : 		//flush_into_uc = '1'
                           (new_command == 1'b1) ? (xer_type & (~(xu_iu_ucode_xer_val_l2 | xer_val_occurred_l2)) ) :
                           ((xu_iu_ucode_xer_val_l2 | xer_val_occurred_l2) == 1'b1) ? 1'b0 :
                           wait_for_xer_l2;

   // Set if xer_val comes before wait_for_xer (preissue sent, but valid is held off in uc_buffer)
   // Clear when new_command (and don't set wait_for_xer hold), or clear on flush or br_hold
   assign xer_val_occurred_d = (xu_iu_ucode_xer_val_l2 | xer_val_occurred_l2) & (~wait_for_xer_l2) & (~new_command) & (~flush) & (~br_hold);

   assign instr_d[0:5] = (flush_into_uc == 1'b1) ? oldest_instr[0:5] :
                         (new_command == 1'b1)   ? new_instr[0:5] :
                                                   instr_l2[0:5];

   assign instr_d[6:10] = (flush_into_uc == 1'b1) ? flush_ifar[49:53] :
                          (new_command == 1'b1)   ? new_instr[6:10] :
                          (inc_RT == 1'b1)        ? instr_l2[6:10] + 5'b00001 :
                                                    instr_l2[6:10];

   assign instr_d[11] = (flush_into_uc == 1'b1) ? oldest_instr[11] :
                        (new_command == 1'b1)   ? new_instr[11] :
                                                  instr_l2[11];

   // Note: we must never flush_into_uc for a fxm_type instruction because we don't keep that info
   assign instr_d[12:19] = (flush_into_uc == 1'b1) ? oldest_instr[12:19] :
                           (new_command == 1'b1)   ? new_instr[12:19] :
                           (shift_fxm == 1'b1)     ? {instr_l2[14:19], instr_l2[12:13]} :
                                                     instr_l2[12:19];

   assign instr_d[20:31] = (flush_into_uc == 1'b1) ? oldest_instr[20:31] :
                           (new_command == 1'b1)   ? new_instr[20:31] :
                                                     instr_l2[20:31];

   assign early_end_d = (flush_into_uc == 1'b1) ? oldest_instr[6] :
                        (new_command == 1'b1)   ? early_end :
                                                  early_end_l2;

   assign cond_d = (flush_into_uc == 1'b1) ? oldest_instr[7] :
                   (new_command == 1'b1)   ? new_cond :
                                             cond_l2;

   assign force_ep_d = (flush_into_uc == 1'b1) ? oldest_instr[8] :
                       (new_command == 1'b1)   ? force_ep :
                                                 force_ep_l2;

   // Note: we must never flush_into_uc for a fxm_type instruction because we don't keep latest instr(12:19)
   assign fxm_type_d = (flush_into_uc == 1'b1) ? 1'b0 :
                       (new_command == 1'b1)   ? fxm_type : 		// for mtcrf
                                                 fxm_type_l2;

   assign shift_fxm = fxm_type_l2 & data_valid;

   // uCode sequence cannot cross 256-instr address boundary
   // Read 2 instructions at a time, so only need 9 bits
   assign rom_addr_d = (flush_into_uc == 1'b1) ? {oldest_instr[9:10], flush_ifar[54:60]} :
                       (new_command == 1'b1)   ? start_addr :
                       (loopback == 1'b1)      ? loop_addr :
                       (data_valid == 1'b1)    ? (rom_addr_l2[0:8] + 9'b000000001) :
                                                  rom_addr_l2;

   assign rom_ra = rom_addr_d;

   assign ra_valid = valid_d & (~wait_for_xer_d) & (~br_hold) & (~cplbuffer_full_int);		// ???? should I change to just check next cycle, or leave as is in case we add other threads?

   // If flushing to second half of pair, throw no-op into first position to keep things balanced.
   assign flush_to_odd_d = (flush_into_uc == 1'b1) ? flush_ifar[61] :
                           (new_command == 1'b1)   ? 1'b0 :
                           (data_valid == 1'b1)    ? 1'b0 :
                                                     flush_to_odd_l2;

   //---------------------------------------------------------------------
   // create output instruction - even
   //---------------------------------------------------------------------
   assign uc_end_even       = rom_data_even[32];
   assign uc_end_early_even = rom_data_even[33];
   assign loop_begin_even   = rom_data_even[34];
   assign loop_end_even     = rom_data_even[35] & (inLoop_l2 | loop_begin_even);
   assign count_src_even    = rom_data_even[36:38];	// 00: NB(3:4), 01: "000" & 2's comp NB(3:4), 10: mult of 4 & XER(62:63), 11: 2's comp XER(62:63), 100: RT(inverted), 101: NB(0:2) - word mode, 110: XER(57:61) - word mode, 111: loop_init
   assign ext_even[0]       = rom_data_even[39];	// RT   -- ??? Can we incorporate into mux selects?
   assign ext_even[1]       = rom_data_even[40];	// S1
   assign ext_even[2]       = rom_data_even[41];	// S2
   assign ext_even[3]       = rom_data_even[42];	// S3
   assign sel0_5_even       = rom_data_even[43];
   assign sel6_10_even      = rom_data_even[44:45];
   assign sel11_15_even     = rom_data_even[46:47];
   assign sel16_20_even     = rom_data_even[48:49];
   assign sel21_25_even     = rom_data_even[50:51];
   assign sel26_30_even     = rom_data_even[52];
   assign sel31_even        = rom_data_even[53];
   assign cr_bf2fxm_even    = rom_data_even[54];
   assign skip_cond_even    = rom_data_even[55];
   assign skip_zero_even    = rom_data_even[56];	// For when XER = 0 & to help with NB coding
   assign skip_nop_even     = rom_data_even[57];
   assign loop_addr_even    = rom_data_even[58:67];	// ??? In product, can latch loop_begin address instead of keeping in ROM
   assign loop_init_even    = rom_data_even[68:70];
   assign ep_instr_even     = rom_data_even[71];

   assign template_code_even[0:26]  = rom_data_even_late[0:26];
   assign template_code_even[27]    = rom_data_even_late[27] | ep_force_even_late_l2;
   assign template_code_even[28:31] = rom_data_even_late[28:31];

   assign sel_even_late_d[0]   = sel0_5_even;
   assign sel_even_late_d[1:2] = sel6_10_even;
   assign sel_even_late_d[3:4] = sel11_15_even;
   assign sel_even_late_d[5:6] = sel16_20_even;
   assign sel_even_late_d[7:8] = sel21_25_even;
   assign sel_even_late_d[9]   = sel26_30_even;
   assign sel_even_late_d[10]  = sel31_even;
   assign sel_even_late_d[11]  = use_nop_even;

   assign sel0_5_even_late     = sel_even_late_l2[0];
   assign sel6_10_even_late    = sel_even_late_l2[1:2];
   assign sel11_15_even_late   = sel_even_late_l2[3:4];
   assign sel16_20_even_late   = sel_even_late_l2[5:6];
   assign sel21_25_even_late   = sel_even_late_l2[7:8];
   assign sel26_30_even_late   = sel_even_late_l2[9];
   assign sel31_even_late      = sel_even_late_l2[10];
   assign use_nop_even_late    = sel_even_late_l2[11];

   assign ep_force_even_late_d = ep_instr_even & force_ep_l2;

   assign ucode_end_even = (uc_end_even | (uc_end_early_even & early_end_l2)) & (~(loop_end_even & (~last_loop_fast)));

   assign fxm = (instr_l2[6:8] == 3'b000) ? 8'b10000000 :
                (instr_l2[6:8] == 3'b001) ? 8'b01000000 :
                (instr_l2[6:8] == 3'b010) ? 8'b00100000 :
                (instr_l2[6:8] == 3'b011) ? 8'b00010000 :
                (instr_l2[6:8] == 3'b100) ? 8'b00001000 :
                (instr_l2[6:8] == 3'b101) ? 8'b00000100 :
                (instr_l2[6:8] == 3'b110) ? 8'b00000010 :
                                            8'b00000001;

   assign instr_even_late_d[0:10]  = instr_l2[0:10];
   assign instr_even_late_d[11:20] = (cr_bf2fxm_even == 1'b0) ? instr_l2[11:20] :
                                     {1'b1, fxm[0:7], 1'b0};
   assign instr_even_late_d[21:31] = instr_l2[21:31];

   assign uc_instruction_even[0:5] = (sel0_5_even_late == 1'b0) ? template_code_even[0:5] :
                                                                  instr_even_late_l2[0:5];

   assign uc_instruction_even[6:10] = (sel6_10_even_late == 2'b00) ? template_code_even[6:10] :
                                      (sel6_10_even_late == 2'b01) ? instr_even_late_l2[6:10] :
                                      (sel6_10_even_late == 2'b10) ? instr_even_late_l2[11:15] :
                                                                     instr_even_late_l2[16:20];

   assign uc_instruction_even[11:15] = (sel11_15_even_late == 2'b00) ? template_code_even[11:15] :
                                       (sel11_15_even_late == 2'b01) ? instr_even_late_l2[11:15] :
                                       (sel11_15_even_late == 2'b10) ? instr_even_late_l2[16:20] :
                                                                       instr_even_late_l2[6:10];

   assign uc_instruction_even[16:20] = (sel16_20_even_late == 2'b00) ? template_code_even[16:20] :
                                       (sel16_20_even_late == 2'b01) ? instr_even_late_l2[16:20] :
                                       (sel16_20_even_late == 2'b10) ? instr_even_late_l2[6:10] :
                                                                       instr_even_late_l2[11:15];

   assign uc_instruction_even[21:25] = (sel21_25_even_late == 2'b00) ? template_code_even[21:25] :
                                       (sel21_25_even_late == 2'b01) ? instr_even_late_l2[21:25] :
                                                                       instr_even_late_l2[16:20];

   assign uc_instruction_even[26:30] = (sel26_30_even_late == 1'b0) ? template_code_even[26:30] :
                                                                      instr_even_late_l2[26:30];

   assign uc_instruction_even[31] = (sel31_even_late == 1'b0) ? template_code_even[31] :
                                                                instr_even_late_l2[31];

   assign nop = 32'b01100000000000000000000000000000;
   assign nop_ext = 4'b0000;

   assign use_nop_even = skip_even;

   assign ucode_instr_even = (use_nop_even_late == 1'b1) ? nop :
                             uc_instruction_even;

   assign ucode_ext_even = (use_nop_even == 1'b1) ? nop_ext :
                           ext_even;

   assign ucode_valid[0] = data_valid & (~flush) & (~(skip_even & skip_odd & (~ucode_end)));
   // Removed ucode_end_odd term from skip_odd.  When we skip on ucode_end_odd (e.g. mtcrf,FXM(7)=0), we still end up with a nop or something on even side.  Since uc_ib_done is only 1 bit, it assumes even side was the end.
   assign ucode_valid[1] = data_valid & (~flush) & (~skip_odd) & (~ucode_end_even) & (~(loop_end_even & (~last_loop)));		// Handles loops with odd # of lines

   assign ucode_ifar_even[42:61] = {rom_addr_l2[1], count_l2, inLoop_l2, instr_l2[6:10], rom_addr_l2[2:8], 1'b0};

   assign unused[0] = skip_nop_even;
   assign unused[1:10] = loop_addr_even;

   //---------------------------------------------------------------------
   // create output instruction - odd
   //---------------------------------------------------------------------
   assign uc_end_odd        = rom_data_odd[32];
   assign uc_end_early_odd  = rom_data_odd[33];
   assign loop_begin_odd    = rom_data_odd[34];
   assign loop_end_odd      = rom_data_odd[35] & (inLoop_l2 | loop_begin_even);
   assign count_src_odd     = rom_data_odd[36:38];	// 00: NB(3:4), 01: "000" & 2's comp NB(3:4), 10: mult of 4 & XER(62:63), 11: 2's comp XER(62:63), 100: RT(inverted), 101: NB(0:2) - word mode, 110: XER(57:61) - word mode, 111: loop_init
   assign ext_odd[0]        = rom_data_odd[39];	// RT   -- ??? Can we incorporate into mux selects?
   assign ext_odd[1]        = rom_data_odd[40];	// S1
   assign ext_odd[2]        = rom_data_odd[41];	// S2
   assign ext_odd[3]        = rom_data_odd[42];	// S3
   assign sel0_5_odd        = rom_data_odd[43];
   assign sel6_10_odd       = rom_data_odd[44:45];
   assign sel11_15_odd      = rom_data_odd[46:47];
   assign sel16_20_odd      = rom_data_odd[48:49];
   assign sel21_25_odd      = rom_data_odd[50:51];
   assign sel26_30_odd      = rom_data_odd[52];
   assign sel31_odd         = rom_data_odd[53];
   assign cr_bf2fxm_odd     = rom_data_odd[54];
   assign skip_cond_odd     = rom_data_odd[55];
   assign skip_zero_odd     = rom_data_odd[56];	// For when XER = 0 & to help with NB coding
   assign skip_nop_odd      = rom_data_odd[57];
   assign loop_addr_odd     = rom_data_odd[58:67];	// ??? In product, can latch loop_begin address instead of keeping in ROM
   assign loop_init_odd     = rom_data_odd[68:70];
   assign ep_instr_odd      = rom_data_odd[71];

   assign template_code_odd[0:26]  = rom_data_odd_late[0:26];
   assign template_code_odd[27]    = rom_data_odd_late[27] | ep_force_odd_late_l2;
   assign template_code_odd[28:31] = rom_data_odd_late[28:31];

   assign sel_odd_late_d[0]   = sel0_5_odd;
   assign sel_odd_late_d[1:2] = sel6_10_odd;
   assign sel_odd_late_d[3:4] = sel11_15_odd;
   assign sel_odd_late_d[5:6] = sel16_20_odd;
   assign sel_odd_late_d[7:8] = sel21_25_odd;
   assign sel_odd_late_d[9]   = sel26_30_odd;
   assign sel_odd_late_d[10]  = sel31_odd;

   assign sel0_5_odd_late     = sel_odd_late_l2[0];
   assign sel6_10_odd_late    = sel_odd_late_l2[1:2];
   assign sel11_15_odd_late   = sel_odd_late_l2[3:4];
   assign sel16_20_odd_late   = sel_odd_late_l2[5:6];
   assign sel21_25_odd_late   = sel_odd_late_l2[7:8];
   assign sel26_30_odd_late   = sel_odd_late_l2[9];
   assign sel31_odd_late      = sel_odd_late_l2[10];

   assign ep_force_odd_late_d = ep_instr_odd & force_ep_l2;

   assign ucode_end_odd = (uc_end_odd | (uc_end_early_odd & early_end_l2)) &
                          (~((loop_end_odd | loop_end_even) & (~last_loop_fast)));

   assign instr_odd_late_d[0:10]  = instr_l2[0:10];
   assign instr_odd_late_d[11:20] = (cr_bf2fxm_odd == 1'b0) ? instr_l2[11:20] :
                                    {1'b1, fxm[0:7], 1'b0};
   assign instr_odd_late_d[21:31] = instr_l2[21:31];

   assign uc_instruction_odd[0:5] = (sel0_5_odd_late == 1'b0) ? template_code_odd[0:5] :
                                                                instr_odd_late_l2[0:5];

   assign uc_instruction_odd[6:10] = (sel6_10_odd_late == 2'b00) ? template_code_odd[6:10] :
                                     (sel6_10_odd_late == 2'b01) ? instr_odd_late_l2[6:10] :
                                     (sel6_10_odd_late == 2'b10) ? instr_odd_late_l2[11:15] :
                                                                   instr_odd_late_l2[16:20];

   assign uc_instruction_odd[11:15] = (sel11_15_odd_late == 2'b00) ? template_code_odd[11:15] :
                                      (sel11_15_odd_late == 2'b01) ? instr_odd_late_l2[11:15] :
                                      (sel11_15_odd_late == 2'b10) ? instr_odd_late_l2[16:20] :
                                                                     instr_odd_late_l2[6:10];

   assign uc_instruction_odd[16:20] = (sel16_20_odd_late == 2'b00) ? template_code_odd[16:20] :
                                      (sel16_20_odd_late == 2'b01) ? instr_odd_late_l2[16:20] :
                                      (sel16_20_odd_late == 2'b10) ? instr_odd_late_l2[6:10] :
                                                                     instr_odd_late_l2[11:15];

   assign uc_instruction_odd[21:25] = (sel21_25_odd_late == 2'b00) ? template_code_odd[21:25] :
                                      (sel21_25_odd_late == 2'b01) ? instr_odd_late_l2[21:25] :
                                                                     instr_odd_late_l2[16:20];

   assign uc_instruction_odd[26:30] = (sel26_30_odd_late == 1'b0) ? template_code_odd[26:30] :
                                                                    instr_odd_late_l2[26:30];

   assign uc_instruction_odd[31] = (sel31_odd_late == 1'b0) ? template_code_odd[31] :
                                                              instr_odd_late_l2[31];

   assign ucode_instr_odd = uc_instruction_odd;

   assign ucode_ext_odd = ext_odd;

   assign unused[11] = loop_begin_odd;
   assign unused[12] = skip_zero_odd;
   assign unused[13:15] = loop_init_odd;
   assign unused[16] = loop_addr_odd[9];

   //---------------------------------------------------------------------
   // combine even & odd info
   //---------------------------------------------------------------------
   assign loop_begin = loop_begin_even;
   assign loop_end = loop_end_odd | loop_end_even;
   assign count_src = (inLoop_l2 == 1'b1) ? count_src_odd :
                                            count_src_even;
   assign skip_zero = skip_zero_even;
   assign loop_addr = loop_addr_odd[0:8];
   assign loop_init = loop_init_even;

   assign ucode_end = ucode_end_even | ucode_end_odd;
   assign uc_end = ucode_end & data_valid;

   //---------------------------------------------------------------------
   // control, state machines
   //---------------------------------------------------------------------
   // Old Assumptions:
   // ??? No Nested Loops
   // ??? All Loops must have at least 2 instructions??
   // ??? New ucode instructions will be held off until XU flushes IU (to next instruction) on this thread
   // ??? If loop_end is skip_c, the instruction before loop_end must also be skip_c
   //
   // New Assumptions:
   // ??? No Nested Loops
   // ??? Loops can have only 1 instruction
   // ??? uCode cannot end in the same row as loop_begin
   // ??? If loop_end is skip_c, the instruction before loop_end must also be skip_c
   // ??? Loops must begin on an even address
   // ??? Loops can end on an even address, but loop_address must be written in the odd side (loop_address_odd)
   // ??? We can skip nop lines.  They must be in the odd side, and marked skip_nop
   assign inLoop_d = (flush_into_uc == 1'b1) ? flush_ifar[48] :
                     (new_command == 1'b1)   ? 1'b0 : 		// clear when beginning
                         (((data_valid & loop_begin) | inLoop_l2) & (~((data_valid & loop_end) & last_loop)) & valid_l2);

   assign last_loop = (count_l2 == 5'b00000 & inLoop_l2) |
                      (loop_begin & count_init == 5'b00000) |
                      (skip_zero & loop_begin & count_init == 5'b00001) |
                      (skip_zero_l2 & count_l2 == 5'b00001) |
                      (skip_cond_odd & loop_end_odd & cond_l2) |
                      (skip_cond_even & loop_end_even & cond_l2);	// ??? Could remove this line if timing bad

   // only for uc_end: never have loop_begin & uc_end in same rom line
   assign last_loop_fast = (count_l2 == 5'b00000 & inLoop_l2) |
                           (skip_zero_l2 & count_l2 == 5'b00001) |
                           (skip_cond_odd & loop_end_odd & cond_l2) |
                           (skip_cond_even & loop_end_even & cond_l2);

   assign loopback = data_valid & loop_end & (~last_loop);

   assign inc_RT = data_valid & loop_end & (~(skip_zero_l2 & count_l2 == 5'b00000 & (~loop_begin))) &
                   (~(skip_zero & loop_begin & count_init == 5'b00000)) &
                   count_src[0] & (~(count_src == 3'b111));	// load/store multiple & string op word loops

   assign NB_dec = instr_l2[16:20] - 5'b00001;
   // when NB(3:4) = 00 -> 00, 01 -> 11, 10 -> 10, 11 -> 01
   assign NB_comp[0] = instr_l2[19] ^ instr_l2[20];
   assign NB_comp[1] = instr_l2[20];

   assign xer_act = flush_into_uc | xu_iu_ucode_xer_val;
   assign xu_iu_ucode_xer_d = (flush_into_uc == 1'b1) ? oldest_xer :
                                                        xu_iu_ucode_xer;
   assign xu_iu_ucode_xer_val_d = xu_iu_ucode_xer_val & (~flush) & (~br_hold);	// flush term avoids problems with cplbuffer

   assign XER_dec_z = (xu_iu_ucode_xer_l2[57:63] == 7'b0) ? 7'b0000000 :
                       xu_iu_ucode_xer_l2[57:63] - 7'b0000001;
   assign XER_low = (XER_dec_z[5:6] == 2'b11) ? 3'b100 :
                    {1'b0, xu_iu_ucode_xer_l2[62:63]};
   assign XER_comp[0] = xu_iu_ucode_xer_l2[62] ^ xu_iu_ucode_xer_l2[63];
   assign XER_comp[1] = xu_iu_ucode_xer_l2[63];

   assign count_init = (count_src == 3'b000) ? {3'b000, NB_dec[3:4]} :
                       (count_src == 3'b001) ? {3'b000, NB_comp[0:1]} :
                       (count_src == 3'b010) ? {2'b00, XER_low} :
                       (count_src == 3'b011) ? {3'b000, XER_comp[0:1]} :
                       (count_src == 3'b100) ? (~(instr_l2[6:10])) : 	// RT
                       (count_src == 3'b101) ? {2'b00, NB_dec[0:2]} :
                       (count_src == 3'b110) ? XER_dec_z[0:4] :
                                               {2'b00, loop_init};

   assign count_d = (flush_into_uc == 1'b1) ? flush_ifar[43:47] :
                    ((data_valid & loop_begin & (~inLoop_l2) & loop_end) == 1'b1) ? count_init - 5'b00001 :
                    ((data_valid & loop_begin & (~inLoop_l2)) == 1'b1) ? count_init :
                    ((data_valid & loop_end) == 1'b1) ? count_l2 - 5'b00001 :
                    count_l2;

   assign skip_zero_d = (((data_valid & loop_end & last_loop) | new_command | flush_into_uc) == 1'b1) ? 1'b0 : 	// added last_loop to handle 2 instruction loops in lswi,lswx
                        ((data_valid & loop_begin) == 1'b1) ? skip_zero :
                        skip_zero_l2;

   // ??? If we always read each cycle, could we just do: skip_to_np1_d <- flush_into_uc and np1_flush?
   assign skip_to_np1_d = (flush == 1'b1) ? flush_into_uc & np1_flush :
                          (data_valid == 1'b1) ? 1'b0 :
                          skip_to_np1_l2;

   assign skip_even = (((skip_zero & loop_begin) | skip_zero_l2) & (count_l2 == 5'b00000) & inLoop_l2) |
                      ( (skip_zero & loop_begin) & count_init == 5'b00000 & (~inLoop_l2)) |
                      (skip_cond_even & cond_l2) |
                      (fxm_type_l2 & instr_l2[12] == 1'b0) |
                      flush_to_odd_l2 |
                      skip_to_np1_l2;

   assign skip_odd = (((skip_zero & loop_begin) | skip_zero_l2) & (count_l2 == 5'b00000) & inLoop_l2) |
                     ( (skip_zero & loop_begin) & count_init == 5'b00000 & (~inLoop_l2)) |
                     (skip_cond_odd & cond_l2) |
                     (fxm_type_l2 & instr_l2[13] == 1'b0) |
                     skip_nop_odd |
                     (flush_to_odd_l2 & skip_to_np1_l2);

   //---------------------------------------------------------------------
   // Buffer old instructions until they complete
   //---------------------------------------------------------------------
   assign buff_instr_in = {instr_l2[0:5], early_end_l2, cond_l2, force_ep_l2, rom_addr_l2[0:1], instr_l2[11:31]};

   assign cplbuffer_xer_act = (  wait_for_xer_l2 & xu_iu_ucode_xer_val_l2) |
                              ((~wait_for_xer_l2) & new_command & xer_type & (xer_val_occurred_l2 | xu_iu_ucode_xer_val_l2));

   // Flush_into_uc requirements:
   // -- signal active for only 1 cycle
   // -- flush_into_uc can only occur if we have a non-completed uCode instruction
   // -- flush_into_uc must not occur on fxm_type instr (we don't keep around instr_l2(12:19) in ifar)
   iuq_uc_cplbuffer  iuq_uc_cplbuffer0(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .pc_iu_func_sl_thold_0_b(pc_iu_func_sl_thold_0_b),
      .pc_iu_sg_0(pc_iu_sg_0),
      .force_t(force_t),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scan_in(buff_scan_in),
      .scan_out(buff_scan_out),
      .cp_uc_credit_free(cp_uc_credit_free),
      .flush(cp_flush),
      .flush_into_uc(flush_into_uc),
      .new_command(new_command),
      .flush_next(flush_next),
      .valid_l2(valid_l2),
      .flush_current(flush),
      .buff_instr_in(buff_instr_in),
      .cplbuffer_xer_act(cplbuffer_xer_act),
      .wait_for_xer_l2(wait_for_xer_l2),
      .xu_iu_ucode_xer_l2(xu_iu_ucode_xer_l2),
      .cplbuffer_full(cplbuffer_full_int),
      .oldest_instr(oldest_instr),
      .oldest_xer(oldest_xer)
   );

   assign cplbuffer_full = cplbuffer_full_int;

   //---------------------------------------------------------------------
   // Latches
   //---------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(0)) xu_iu_ucode_xer_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(xer_act),		// ??? If change, make sure xer bugspray is still accurate
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[xu_iu_ucode_xer_offset:xu_iu_ucode_xer_offset + 7 - 1]),
      .scout(sov[xu_iu_ucode_xer_offset:xu_iu_ucode_xer_offset + 7 - 1]),
      .din(xu_iu_ucode_xer_d),
      .dout(xu_iu_ucode_xer_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(0)) xu_iu_ucode_xer_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_default_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[xu_iu_ucode_xer_val_offset]),
      .scout(sov[xu_iu_ucode_xer_val_offset]),
      .din(xu_iu_ucode_xer_val_d),
      .dout(xu_iu_ucode_xer_val_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(0)) wait_for_xer_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_default_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[wait_for_xer_offset]),
      .scout(sov[wait_for_xer_offset]),
      .din(wait_for_xer_d),
      .dout(wait_for_xer_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(0)) xer_val_occurred_latch(
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
      .scin(siv[xer_val_occurred_offset]),
      .scout(sov[xer_val_occurred_offset]),
      .din(xer_val_occurred_d),
      .dout(xer_val_occurred_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_default_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[valid_offset]),
      .scout(sov[valid_offset]),
      .din(valid_d),
      .dout(valid_l2)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(0)) instr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_control_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[instr_offset:instr_offset + 32 - 1]),
      .scout(sov[instr_offset:instr_offset + 32 - 1]),
      .din(instr_d),
      .dout(instr_l2)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(0)) instr_even_late_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(data_valid),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[instr_even_late_offset:instr_even_late_offset + 32 - 1]),
      .scout(sov[instr_even_late_offset:instr_even_late_offset + 32 - 1]),
      .din(instr_even_late_d),
      .dout(instr_even_late_l2)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(0)) instr_odd_late_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(data_valid),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[instr_odd_late_offset:instr_odd_late_offset + 32 - 1]),
      .scout(sov[instr_odd_late_offset:instr_odd_late_offset + 32 - 1]),
      .din(instr_odd_late_d),
      .dout(instr_odd_late_l2)
   );

   tri_rlmreg_p #(.WIDTH(12), .INIT(0), .NEEDS_SRESET(0)) sel_even_late_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(data_valid),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[sel_even_late_offset:sel_even_late_offset + 12 - 1]),
      .scout(sov[sel_even_late_offset:sel_even_late_offset + 12 - 1]),
      .din(sel_even_late_d),
      .dout(sel_even_late_l2)
   );

   tri_rlmreg_p #(.WIDTH(11), .INIT(0), .NEEDS_SRESET(0)) sel_odd_late_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(data_valid),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[sel_odd_late_offset:sel_odd_late_offset + 11 - 1]),
      .scout(sov[sel_odd_late_offset:sel_odd_late_offset + 11 - 1]),
      .din(sel_odd_late_d),
      .dout(sel_odd_late_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) early_end_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_control_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[early_end_offset]),
      .scout(sov[early_end_offset]),
      .din(early_end_d),
      .dout(early_end_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cond_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_control_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[cond_offset]),
      .scout(sov[cond_offset]),
      .din(cond_d),
      .dout(cond_l2)
   );

   tri_rlmreg_p #(.WIDTH(9), .INIT(0), .NEEDS_SRESET(0)) rom_addr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_control_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[rom_addr_offset:rom_addr_offset + 9 - 1]),
      .scout(sov[rom_addr_offset:rom_addr_offset + 9 - 1]),
      .din(rom_addr_d),
      .dout(rom_addr_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) flush_to_odd_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_control_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[flush_to_odd_offset]),
      .scout(sov[flush_to_odd_offset]),
      .din(flush_to_odd_d),
      .dout(flush_to_odd_l2)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(0)) count_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_control_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[count_offset:count_offset + 5 - 1]),
      .scout(sov[count_offset:count_offset + 5 - 1]),
      .din(count_d),
      .dout(count_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) inloop_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_control_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[inloop_offset]),
      .scout(sov[inloop_offset]),
      .din(inLoop_d),
      .dout(inLoop_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) skip_zero_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_control_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[skip_zero_offset]),
      .scout(sov[skip_zero_offset]),
      .din(skip_zero_d),
      .dout(skip_zero_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) skip_to_np1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_control_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[skip_to_np1_offset]),
      .scout(sov[skip_to_np1_offset]),
      .din(skip_to_np1_d),
      .dout(skip_to_np1_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) force_ep_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_control_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[force_ep_offset]),
      .scout(sov[force_ep_offset]),
      .din(force_ep_d),
      .dout(force_ep_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) fxm_type_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_control_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[fxm_type_offset]),
      .scout(sov[fxm_type_offset]),
      .din(fxm_type_d),
      .dout(fxm_type_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ep_force_even_late_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(data_valid),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[ep_force_even_late_offset]),
      .scout(sov[ep_force_even_late_offset]),
      .din(ep_force_even_late_d),
      .dout(ep_force_even_late_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ep_force_odd_late_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(data_valid),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[ep_force_odd_late_offset]),
      .scout(sov[ep_force_odd_late_offset]),
      .din(ep_force_odd_late_d),
      .dout(ep_force_odd_late_l2)
   );

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
   assign buff_scan_in = sov[0];
   assign scan_out = buff_scan_out;

endmodule
