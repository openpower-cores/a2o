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
//* TITLE: IU Microcode Buffers
//*
//* NAME: iuq_uc_buffer.v
//*
//*********************************************************************

`include "tri_a2o.vh"


module iuq_uc_buffer(
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
   iu3_val_l2,
   iu3_ifar_l2,
   iu3_2ucode_l2,
   iu3_0_instr_l2,
   iu3_1_instr_l2,
   iu3_2_instr_l2,
   iu3_3_instr_l2,
   ic_bp_iu2_flush,
   ic_bp_iu3_flush,
   ic_bp_iu3_ecc_err,
   bp_ib_iu3_val,
   uc_ib_iu3_invalid,
   uc_ib_iu3_flush_all,
   uc_ic_hold,
   uc_iu4_flush,
   uc_iu4_flush_ifar,
   xu_iu_flush,
   uc_val,
   advance_buffers,
   br_hold_l2,
   cplbuffer_full,
   clear_ill_flush_2ucode,
   next_valid,
   next_instr,
   iu2_flush,
   flush_next,
   flush_current
);


   inout                         vdd;

   inout                         gnd;


    (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]       nclk;
   input                         pc_iu_func_sl_thold_0_b;
   input                         pc_iu_sg_0;
   input                         force_t;
   input                         d_mode;
   input                         delay_lclkr;
   input                         mpw1_b;
   input                         mpw2_b;

    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                         scan_in;

    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                        scan_out;

   input [0:3]                   iu3_val_l2;
   input [62-`EFF_IFAR_WIDTH:61] iu3_ifar_l2;
   input                         iu3_2ucode_l2;		// Only iu3_0_instr0 can ever be 2ucode because xu_iu_flush clears everything before it.

   input [0:33]                  iu3_0_instr_l2;
   input [0:33]                  iu3_1_instr_l2;
   input [0:33]                  iu3_2_instr_l2;
   input [0:33]                  iu3_3_instr_l2;

   input                         ic_bp_iu2_flush;
   input                         ic_bp_iu3_flush;
   input                         ic_bp_iu3_ecc_err;

   input [0:3]                   bp_ib_iu3_val;

   output [0:3]                  uc_ib_iu3_invalid;		// IB uses this to mask off the valids

   output                        uc_ib_iu3_flush_all;		// IB uses this to clear buffer (because not enough time to get into iu3_invalid)

   output                         uc_ic_hold;

   output                         uc_iu4_flush;
   output [62-`EFF_IFAR_WIDTH:61] uc_iu4_flush_ifar;

   input                         xu_iu_flush;

   // Internal to microcode
   input                         uc_val;
   input                         advance_buffers;
   input                         br_hold_l2;
   input                         cplbuffer_full;
   input                         clear_ill_flush_2ucode;

   output                        next_valid;		// Does not include flush
   output [0:31]                 next_instr;

   output                        iu2_flush;		// Does not include XU flush
   output                        flush_next;		// Includes XU flush
   output                        flush_current;		// Includes XU flush

   parameter                     uc_ic_hold_offset = 0;
   parameter                     uc_iu4_flush_offset = uc_ic_hold_offset + 1;
   parameter                     uc_iu4_flush_ifar_offset = uc_iu4_flush_offset + 1;
   parameter                     buffer_valid_offset = uc_iu4_flush_ifar_offset + `EFF_IFAR_WIDTH;
   parameter                     buffer1_offset = buffer_valid_offset + 4;		//buffer0_offset + 2;
   parameter                     buffer2_offset = buffer1_offset + 32;
   parameter                     buffer3_offset = buffer2_offset + 32;
   parameter                     buffer4_offset = buffer3_offset + 32;
   parameter                     scan_right = buffer4_offset + 32 - 1;		//buffer_stg_iu4_offset + 5 - 1;

   // Latches
   wire                          uc_ic_hold_d;
   wire                          uc_iu4_flush_d;
   wire [62-`EFF_IFAR_WIDTH:61]  uc_iu4_flush_ifar_d;

   wire [1:4]                    buffer_valid_d;
   wire [0:31]                   buffer1_d;
   wire [0:31]                   buffer2_d;
   wire [0:31]                   buffer3_d;
   wire [0:31]                   buffer4_d;

   wire                          uc_ic_hold_l2;
   wire                          uc_iu4_flush_l2;
   wire [62-`EFF_IFAR_WIDTH:61]  uc_iu4_flush_ifar_l2;

   wire [1:4]                    buffer_valid_l2;
   wire [0:31]                   buffer1_l2;
   wire [0:31]                   buffer2_l2;
   wire [0:31]                   buffer3_l2;
   wire [0:31]                   buffer4_l2;

   wire [0:3]                    new_ucode_in;
   wire                          uc_buffer_act;
   wire                          uc_stall;

   // Left shift incoming microcode instructions
   wire [0:3]                    ucode_and_bp_in;
   wire [0:3]                    valid_in;
   wire [0:3]                    early_val_in;
   wire [0:31]                   instr0_in;
   wire [0:31]                   instr1_in;
   wire [0:31]                   instr2_in;
   wire [0:31]                   instr3_in;
   wire [60:61]                  ic_ifar0;
   wire [60:61]                  ic_ifar1;
   wire [60:61]                  ic_ifar2;
   wire [60:61]                  ic_ifar3;
   wire [60:61]                  ifar0_in;
   wire [60:61]                  ifar1_in;
   wire [60:61]                  ifar2_in;
   wire [60:61]                  ifar3_in;

   // Flushes
   wire                          iu3_flush;

   wire [0:3]                    early_need_flush_instr_in;
   wire [0:3]                    need_flush_instr_in;
   wire [60:61]                  overflow_flush_ifar;

   wire [0:3]                    imask0_in;
   wire [0:3]                    imask1_in;
   wire [0:3]                    imask2_in;
   wire [0:3]                    imask3_in;
   wire [0:3]                    uc_iu3_flush_imask;

   // Buffer
   wire                          bp_flush_next;

   wire [0:scan_right]           siv;
   wire [0:scan_right]           sov;

   //tidn <= '0';
   //tiup <= '1';

   assign new_ucode_in[0] = iu3_val_l2[0] & ((iu3_0_instr_l2[32:33] == 2'b01) | iu3_2ucode_l2);
   assign new_ucode_in[1] = iu3_val_l2[1] & (iu3_1_instr_l2[32:33] == 2'b01);
   assign new_ucode_in[2] = iu3_val_l2[2] & (iu3_2_instr_l2[32:33] == 2'b01);
   assign new_ucode_in[3] = iu3_val_l2[3] & (iu3_3_instr_l2[32:33] == 2'b01);

   // default act signal
   assign uc_buffer_act = uc_val | buffer_valid_l2[1] | (|(new_ucode_in)) | uc_iu4_flush_l2;

   // stall if processing command in buffer0 or commands are being held off.  When current command finishes,
   // buffer0 takes next command when uc_end, but Buffers need to latch info
   // and advance next cycle because we cannot make timing (ib_uc_rdy comes late)
   // This means buffer0 can have same command as buffer1 for a cycle
   assign uc_stall = (uc_val | br_hold_l2 | cplbuffer_full) & (~advance_buffers);

   //---------------------------------------------------------------------
   // left shift incoming microcode instructions
   //---------------------------------------------------------------------
   //Detect if redirected by BP
   assign ucode_and_bp_in = new_ucode_in & bp_ib_iu3_val;

   assign valid_in[0] = |(ucode_and_bp_in);
   assign valid_in[1] = (~((  ucode_and_bp_in[0:2] == 3'b000) |
                           (({ucode_and_bp_in[0:1], ucode_and_bp_in[3]}) == 3'b000) |
                           (({ucode_and_bp_in[0], ucode_and_bp_in[2:3]}) == 3'b000) |
                           (  ucode_and_bp_in[1:3] == 3'b000)));		// not 0000,0001,0010,0100,1000

   assign valid_in[2] = ( ucode_and_bp_in[0:2] == 3'b111) |
                        ({ucode_and_bp_in[0:1], ucode_and_bp_in[3]} == 3'b111) |
                        ({ucode_and_bp_in[0], ucode_and_bp_in[2:3]} == 3'b111) |
                        ( ucode_and_bp_in[1:3] == 3'b111);		// 1111,1110,1101,1011,0111

   assign valid_in[3] = ucode_and_bp_in == 4'b1111;

   // This early signal does not include BP val, and is used for IB invalidate
   assign early_val_in[0] = |(new_ucode_in);
   assign early_val_in[1] = (~(( new_ucode_in[0:2] == 3'b000) |
                               ({new_ucode_in[0:1], new_ucode_in[3]} == 3'b000) |
                               ({new_ucode_in[0], new_ucode_in[2:3]} == 3'b000) |
                               ( new_ucode_in[1:3] == 3'b000)));		// not 0000,0001,0010,0100,1000

   assign early_val_in[2] = ( new_ucode_in[0:2] == 3'b111) |
                            ({new_ucode_in[0:1], new_ucode_in[3]} == 3'b111) |
                            ({new_ucode_in[0], new_ucode_in[2:3]} == 3'b111) |
                            ( new_ucode_in[1:3] == 3'b111);		// 1111,1110,1101,1011,0111

   assign early_val_in[3] = new_ucode_in == 4'b1111;

   assign instr0_in = (new_ucode_in[0] == 1'b1) ? iu3_0_instr_l2[0:31] : 		// 1---
                      (new_ucode_in[1] == 1'b1) ? iu3_1_instr_l2[0:31] : 		// 01--
                      (new_ucode_in[2] == 1'b1) ? iu3_2_instr_l2[0:31] : 		// 001-
                                                  iu3_3_instr_l2[0:31];

   assign instr1_in = (new_ucode_in[0:1] == 2'b11)      ? iu3_1_instr_l2[0:31] : 		// 11--
                      (((new_ucode_in[0:2] == 3'b011) |                                         // 011-
                        (new_ucode_in[0:2] == 3'b101))) ? iu3_2_instr_l2[0:31] :		// 101-
                                                          iu3_3_instr_l2[0:31];

   assign instr2_in = (new_ucode_in[0:2] == 3'b111) ? iu3_2_instr_l2[0:31] : 		// 111-
                                                      iu3_3_instr_l2[0:31];

   assign instr3_in = iu3_3_instr_l2[0:31];

   assign ic_ifar0 = iu3_ifar_l2[60:61];

   assign ic_ifar1 = (iu3_ifar_l2[60:61] == 2'b00) ? 2'b01 :
                     (iu3_ifar_l2[60:61] == 2'b01) ? 2'b10 :
                                                     2'b11;

   assign ic_ifar2 = {(~iu3_ifar_l2[60]), iu3_ifar_l2[61]};
   assign ic_ifar3 = 2'b11;

   assign ifar0_in = (new_ucode_in[0] == 1'b1) ? ic_ifar0 : 		// 1---
                     (new_ucode_in[1] == 1'b1) ? ic_ifar1 : 		// 01--
                     (new_ucode_in[2] == 1'b1) ? ic_ifar2 : 		// 001-
                                                 ic_ifar3;

   assign ifar1_in = (new_ucode_in[0:1] == 2'b11)      ? ic_ifar1 : 		// 11--
                     (((new_ucode_in[0:2] == 3'b011) |                          // 011-
                       (new_ucode_in[0:2] == 3'b101))) ? ic_ifar2 : 		// 101-
                                                         ic_ifar3;

   assign ifar2_in = (new_ucode_in[0:2] == 3'b111) ? ic_ifar2 : 		// 111-
                                                     ic_ifar3;

   assign ifar3_in = ic_ifar3;

   //---------------------------------------------------------------------
   // Flushes
   //---------------------------------------------------------------------
   // Does not include xu_iu_flush (for timing)
   assign iu3_flush = ic_bp_iu3_flush | uc_iu4_flush_l2 | ic_bp_iu3_ecc_err;
   assign iu2_flush = ic_bp_iu3_flush | uc_iu4_flush_l2 | (|(need_flush_instr_in)) | ic_bp_iu2_flush;

   // Need UC flush if overflowing buffer
   // early signal does not check BP val
   assign early_need_flush_instr_in = ((early_val_in[0] & buffer_valid_l2[4] & uc_stall) == 1'b1) ?                                          4'b1000 :
                                      ((early_val_in[1] & ((buffer_valid_l2[3] & uc_stall) | (buffer_valid_l2[4] & (~uc_stall)))) == 1'b1) ? 4'b0100 :
                                      ((early_val_in[2] & ((buffer_valid_l2[2] & uc_stall) | (buffer_valid_l2[3] & (~uc_stall)))) == 1'b1) ? 4'b0010 :
                                      ((early_val_in[3] & ((buffer_valid_l2[1] & uc_stall) | (buffer_valid_l2[2] & (~uc_stall)))) == 1'b1) ? 4'b0001 :
                                                                                                                                             4'b0000;

   assign need_flush_instr_in = early_need_flush_instr_in & valid_in;

   assign overflow_flush_ifar[60:61] = (ifar0_in & {2{need_flush_instr_in[0]}}) |
                                       (ifar1_in & {2{need_flush_instr_in[1]}}) |
                                       (ifar2_in & {2{need_flush_instr_in[2]}}) |
                                       (ifar3_in & {2{need_flush_instr_in[3]}});

   assign uc_iu4_flush_ifar_d[62 - `EFF_IFAR_WIDTH:59] = iu3_ifar_l2[62 - `EFF_IFAR_WIDTH:59];
   assign uc_iu4_flush_ifar_d[60:61] = clear_ill_flush_2ucode ? ifar0_in :
                                                                overflow_flush_ifar;

   // Which of the 4 instructions was flushed
   assign imask0_in = (new_ucode_in[0] == 1'b1) ? 4'b1111 : 		// 1---
                      (new_ucode_in[1] == 1'b1) ? 4'b0111 : 		// 01--
                      (new_ucode_in[2] == 1'b1) ? 4'b0011 : 		// 001-
                                                  4'b0001;

   assign imask1_in = (new_ucode_in[0:1] == 2'b11)      ? 4'b0111 : 		// 11--
                      (((new_ucode_in[0:2] == 3'b011) |                         // 011-
                        (new_ucode_in[0:2] == 3'b101))) ? 4'b0011 : 		// 101-
                                                          4'b0001;

   assign imask2_in = (new_ucode_in[0:2] == 3'b111) ? 4'b0011 : 		// 111-
                                                      4'b0001;

   assign imask3_in = 4'b0001;

   assign uc_iu3_flush_imask = (imask0_in & {4{early_need_flush_instr_in[0]}}) |
                               (imask1_in & {4{early_need_flush_instr_in[1]}}) |
                               (imask2_in & {4{early_need_flush_instr_in[2]}}) |
                               (imask3_in & {4{early_need_flush_instr_in[3]}});

   assign uc_ib_iu3_invalid = uc_iu3_flush_imask | {4{uc_iu4_flush_l2}};

   assign uc_iu4_flush_d = (|(need_flush_instr_in) | clear_ill_flush_2ucode) & (~iu3_flush) & (~xu_iu_flush);

   assign uc_ib_iu3_flush_all = clear_ill_flush_2ucode & (~iu3_flush);

   // Detect IB flush

   // Simpler to wait until IU4 because BP flush is IU3 & IU4
   // (old)IB flush should take precedence over UC flush in IC because we invalidated UC flushes in IU3
   // UC flush should take precedence over BP flush in IC because we checked BP valids in IU3
   assign uc_iu4_flush = uc_iu4_flush_l2;
   assign uc_iu4_flush_ifar = uc_iu4_flush_ifar_l2;

   assign uc_ic_hold_d = (buffer_valid_d[4] == 1'b0) ? 1'b0 :
                         (uc_iu4_flush_l2 == 1'b1)   ? 1'b1 :
                                                       uc_ic_hold_l2;

   assign uc_ic_hold = uc_ic_hold_l2;

   //---------------------------------------------------------------------
   // Buffers
   //---------------------------------------------------------------------
   // Buffer0 is the instruction that UC is currently working on
   assign next_instr = (buffer_valid_l2[2] == 1'b1 & advance_buffers == 1'b1) ? buffer2_l2[0:31] :
                       (buffer_valid_l2[1] == 1'b1 & advance_buffers == 1'b0) ? buffer1_l2[0:31] :
                       instr0_in;

   // Note: buffer0 could be taking buffer2 info next cycle, but we never can get an ib_flush on buffer0
   //    in that scenario

   // ??? Do I want to switch ordering so bufferX_l2 is default case? (save power/toggling)
   assign buffer1_d = (uc_stall == 1'b1 & buffer_valid_l2[1] == 1'b1) ? buffer1_l2 :
                      (uc_stall == 1'b0 & buffer_valid_l2[2] == 1'b1) ? buffer2_l2 :
                      (uc_stall == 1'b0 & buffer_valid_l2[1] == 1'b0) ? instr1_in :
                                                                        instr0_in;

   assign buffer2_d = (uc_stall == 1'b1 & buffer_valid_l2[2] == 1'b1) ? buffer2_l2 :
                      (uc_stall == 1'b0 & buffer_valid_l2[3] == 1'b1) ? buffer3_l2 :
                      (uc_stall == 1'b0 & buffer_valid_l2[1] == 1'b0) ? instr2_in :
                      (uc_stall == 1'b1 & buffer_valid_l2[1] == 1'b0) ? instr1_in :
                      (uc_stall == 1'b0 & buffer_valid_l2[2] == 1'b0) ? instr1_in :
                                                                        instr0_in;

   assign buffer3_d = (uc_stall == 1'b1 & buffer_valid_l2[3] == 1'b1) ? buffer3_l2 :
                      (uc_stall == 1'b0 & buffer_valid_l2[4] == 1'b1) ? buffer4_l2 :
                      (uc_stall == 1'b0 & buffer_valid_l2[1] == 1'b0) ? instr3_in :
                      (uc_stall == 1'b1 & buffer_valid_l2[1] == 1'b0) ? instr2_in :
                      (uc_stall == 1'b0 & buffer_valid_l2[2] == 1'b0) ? instr2_in :
                      (uc_stall == 1'b1 & buffer_valid_l2[2] == 1'b0) ? instr1_in :
                      (uc_stall == 1'b0 & buffer_valid_l2[3] == 1'b0) ? instr1_in :
                                                                        instr0_in;

   assign buffer4_d = (uc_stall == 1'b1 & buffer_valid_l2[4] == 1'b1) ? buffer4_l2 :
                      (uc_stall == 1'b1 & buffer_valid_l2[1] == 1'b0) ? instr3_in :
                      (uc_stall == 1'b0 & buffer_valid_l2[2] == 1'b0) ? instr3_in :
                      (uc_stall == 1'b1 & buffer_valid_l2[2] == 1'b0) ? instr2_in :
                      (uc_stall == 1'b0 & buffer_valid_l2[3] == 1'b0) ? instr2_in :
                      (uc_stall == 1'b1 & buffer_valid_l2[3] == 1'b0) ? instr1_in :
                      (uc_stall == 1'b0 & buffer_valid_l2[4] == 1'b0) ? instr1_in :
                                                                        instr0_in;

   // Output is never in IU4 now that we latch incoming IU2 signals

   assign bp_flush_next = (|(new_ucode_in)) & (~valid_in[0]);

   assign flush_current = xu_iu_flush;		// Current instruction flushed
   assign flush_next = ((~((buffer_valid_l2[2] & advance_buffers) | (buffer_valid_l2[1] & (~advance_buffers)))) & (iu3_flush | bp_flush_next)) | xu_iu_flush;

   assign next_valid = (buffer_valid_l2[2] &   advance_buffers)  |
                       (buffer_valid_l2[1] & (~advance_buffers)) |
                       (|(new_ucode_in));		// Does not include flush

   assign buffer_valid_d[1] = ((buffer_valid_l2[1] & uc_stall) |
                                buffer_valid_l2[2] |
                               (((valid_in[1]) |
                                 (valid_in[0] & buffer_valid_l2[1]) |
                                 (uc_stall & valid_in[0])) & (~iu3_flush)))
                           & (~xu_iu_flush);

   assign buffer_valid_d[2] = ((buffer_valid_l2[2] & uc_stall) |
                                buffer_valid_l2[3] |
                               (((valid_in[2]) |
                                 (valid_in[1] & buffer_valid_l2[1]) |
                                 (valid_in[0] & buffer_valid_l2[2]) |
                                 (uc_stall & (valid_in[1] |
                                              (valid_in[0] & buffer_valid_l2[1])))) & (~iu3_flush)))
                           & (~xu_iu_flush);

   assign buffer_valid_d[3] = ((buffer_valid_l2[3] & uc_stall) |
                               buffer_valid_l2[4] |
                               (((valid_in[3]) |
                                 (valid_in[2] & buffer_valid_l2[1]) |
                                 (valid_in[1] & buffer_valid_l2[2]) |
                                 (valid_in[0] & buffer_valid_l2[3]) |
                                 (uc_stall & (valid_in[2] |
                                              (valid_in[1] & buffer_valid_l2[1]) |
                                              (valid_in[0] & buffer_valid_l2[2])))) & (~iu3_flush)))
                           & (~xu_iu_flush);

   assign buffer_valid_d[4] = ((buffer_valid_l2[4] & uc_stall) |
                               (((valid_in[3] & buffer_valid_l2[1]) |
                                 (valid_in[2] & buffer_valid_l2[2]) |
                                 (valid_in[1] & buffer_valid_l2[3]) |
                                 (valid_in[0] & buffer_valid_l2[4]) |
                                 (uc_stall & (valid_in[3] |
                                              (valid_in[2] & buffer_valid_l2[1]) |
                                              (valid_in[1] & buffer_valid_l2[2]) |
                                              (valid_in[0] & buffer_valid_l2[3])))) & (~iu3_flush)))
                           & (~xu_iu_flush);

   //---------------------------------------------------------------------
   // Latches
   //---------------------------------------------------------------------

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) uc_ic_hold_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_buffer_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[uc_ic_hold_offset]),
      .scout(sov[uc_ic_hold_offset]),
      .din(uc_ic_hold_d),
      .dout(uc_ic_hold_l2)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) uc_iu4_flush_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_buffer_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[uc_iu4_flush_offset]),
      .scout(sov[uc_iu4_flush_offset]),
      .din(uc_iu4_flush_d),
      .dout(uc_iu4_flush_l2)
   );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(0)) uc_iu4_flush_ifar_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_iu4_flush_d),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[uc_iu4_flush_ifar_offset:uc_iu4_flush_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov[uc_iu4_flush_ifar_offset:uc_iu4_flush_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .din(uc_iu4_flush_ifar_d),
      .dout(uc_iu4_flush_ifar_l2)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) buffer_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_buffer_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[buffer_valid_offset:buffer_valid_offset + 4 - 1]),
      .scout(sov[buffer_valid_offset:buffer_valid_offset + 4 - 1]),
      .din(buffer_valid_d),
      .dout(buffer_valid_l2)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(0)) buffer1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_buffer_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[buffer1_offset:buffer1_offset + 32 - 1]),
      .scout(sov[buffer1_offset:buffer1_offset + 32 - 1]),
      .din(buffer1_d),
      .dout(buffer1_l2)
   );


   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(0)) buffer2_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_buffer_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[buffer2_offset:buffer2_offset + 32 - 1]),
      .scout(sov[buffer2_offset:buffer2_offset + 32 - 1]),
      .din(buffer2_d),
      .dout(buffer2_l2)
   );


   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(0)) buffer3_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_buffer_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[buffer3_offset:buffer3_offset + 32 - 1]),
      .scout(sov[buffer3_offset:buffer3_offset + 32 - 1]),
      .din(buffer3_d),
      .dout(buffer3_l2)
   );


   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(0)) buffer4_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(uc_buffer_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[buffer4_offset:buffer4_offset + 32 - 1]),
      .scout(sov[buffer4_offset:buffer4_offset + 32 - 1]),
      .din(buffer4_d),
      .dout(buffer4_l2)
   );

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
   assign scan_out = sov[0];

endmodule
