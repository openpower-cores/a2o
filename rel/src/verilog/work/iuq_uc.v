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
//* TITLE: IU Microcode
//*
//* NAME: iuq_uc.v
//*
//*********************************************************************

`include "tri_a2o.vh"


module iuq_uc(
   vdd,
   gnd,
   nclk,
   pc_iu_func_sl_thold_2,
   pc_iu_sg_2,
   tc_ac_ccflush_dc,
   clkoff_b,
   act_dis,
   d_mode,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   scan_in,
   scan_out,
   iu_pc_err_ucode_illegal,
   xu_iu_ucode_xer_val,
   xu_iu_ucode_xer,
   iu_flush,
   br_iu_redirect,
   cp_flush_into_uc,
   cp_uc_np1_flush,
   cp_uc_flush_ifar,
   cp_uc_credit_free,
   cp_flush,
   uc_ic_hold,
   uc_iu4_flush,
   uc_iu4_flush_ifar,
   ic_bp_iu2_val,
   ic_bp_iu2_ifar,
   ic_bp_iu2_2ucode,
   ic_bp_iu2_2ucode_type,
   ic_bp_iu2_error,
   ic_bp_iu2_flush,
   ic_bp_iu3_flush,
   ic_bp_iu3_ecc_err,
   ic_bp_iu2_0_instr,
   ic_bp_iu2_1_instr,
   ic_bp_iu2_2_instr,
   ic_bp_iu2_3_instr,
   bp_ib_iu3_val,
   ib_uc_rdy,
   uc_ib_iu3_invalid,
   uc_ib_iu3_flush_all,
   uc_ib_val,
   uc_ib_done,
   uc_ib_instr0,
   uc_ib_instr1,
   uc_ib_ifar0,
   uc_ib_ifar1,
   uc_ib_ext0,
   uc_ib_ext1
);


   inout                         vdd;

   inout                         gnd;

    (* pin_data="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]       nclk;
   input                         pc_iu_func_sl_thold_2;
   input                         pc_iu_sg_2;
   input                         tc_ac_ccflush_dc;
   input                         clkoff_b;
   input                         act_dis;
   input                         d_mode;
   input                         delay_lclkr;
   input                         mpw1_b;
   input                         mpw2_b;

    (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                         scan_in;

    (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                        scan_out;

   output                        iu_pc_err_ucode_illegal;

   input                         xu_iu_ucode_xer_val;
   input [57:63]                 xu_iu_ucode_xer;

   input                         iu_flush;
   input                         br_iu_redirect;
   input                         cp_flush_into_uc;
   input                         cp_uc_np1_flush;
   input [43:61]                 cp_uc_flush_ifar;
   input                         cp_uc_credit_free;
   input                         cp_flush;

   output                        uc_ic_hold;

   output                         uc_iu4_flush;
   output [62-`EFF_IFAR_WIDTH:61] uc_iu4_flush_ifar;

   input [0:3]                   ic_bp_iu2_val;
   input [62-`EFF_IFAR_WIDTH:61] ic_bp_iu2_ifar;
   input                         ic_bp_iu2_2ucode;
   input                         ic_bp_iu2_2ucode_type;
   input                         ic_bp_iu2_error;
   input                         ic_bp_iu2_flush;
   input                         ic_bp_iu3_flush;
   input                         ic_bp_iu3_ecc_err;

   // iu2 instruction(0:31) + predecode(32:35); (32:33) = "01" when uCode
   input [0:33]                  ic_bp_iu2_0_instr;
   input [0:33]                  ic_bp_iu2_1_instr;
   input [0:33]                  ic_bp_iu2_2_instr;
   input [0:33]                  ic_bp_iu2_3_instr;

   input [0:3]                   bp_ib_iu3_val;

   input                         ib_uc_rdy;

   output [0:3]                   uc_ib_iu3_invalid;
   output                         uc_ib_iu3_flush_all;
   output reg [0:1]               uc_ib_val;
   output reg                     uc_ib_done;
   output reg [0:31]              uc_ib_instr0;
   output reg [0:31]              uc_ib_instr1;
   output reg [62-`EFF_IFAR_WIDTH:61] uc_ib_ifar0;
   output reg [62-`EFF_IFAR_WIDTH:61] uc_ib_ifar1;
   output reg [0:3]               uc_ib_ext0;   //RT, S1, S2, S3
   output reg [0:3]               uc_ib_ext1;   //RT, S1, S2, S3

   //@@  Signal Declarations
   wire [1:78]                   get_address_pt;
   wire                          force_ep;
   wire                          fxm_type;
   wire                          late_end;
   wire [0:9]                    start_addr;
   wire                          uc_legal;
   wire                          xer_type;

   parameter                     ucode_width = 72;
   parameter                     uc_ifar = 20;

   parameter                     iu3_val_offset = 0;
   parameter                     iu3_ifar_offset = iu3_val_offset + 4;
   parameter                     iu3_2ucode_offset = iu3_ifar_offset + `EFF_IFAR_WIDTH;
   parameter                     iu3_2ucode_type_offset = iu3_2ucode_offset + 1;
   parameter                     iu3_instr_offset = iu3_2ucode_type_offset + 1;
   parameter                     iu_flush_offset = iu3_instr_offset + 136;
   parameter                     br_hold_offset = iu_flush_offset + 1;
   parameter                     flush_into_uc_offset = br_hold_offset + 1;
   parameter                     np1_flush_offset = flush_into_uc_offset + 1;
   parameter                     flush_ifar_offset = np1_flush_offset + 1;
   parameter                     cp_flush_offset = flush_ifar_offset + 19;
   parameter                     br_iu_redirect_offset = cp_flush_offset + 1;
   parameter                     iu_pc_err_ucode_illegal_offset = br_iu_redirect_offset + 1;
   parameter                     advance_buffers_offset = iu_pc_err_ucode_illegal_offset + 1;
   parameter                     romvalid_offset = advance_buffers_offset + 1;
   parameter                     rom_data_even_late_offset = romvalid_offset + 1;
   parameter                     rom_data_odd_late_offset = rom_data_even_late_offset + 32;
   parameter                     iu4_valid_offset = rom_data_odd_late_offset + 32;
   parameter                     iu4_ifar_offset = iu4_valid_offset + 2;
   parameter                     iu4_ext0_offset = iu4_ifar_offset + uc_ifar;
   parameter                     iu4_ext1_offset = iu4_ext0_offset + 4;
   parameter                     iu4_done_offset = iu4_ext1_offset + 4;
   parameter                     iu4_ov_valid_offset = iu4_done_offset + 1;
   parameter                     iu4_ov_ifar_offset = iu4_ov_valid_offset + 2;
   parameter                     iu4_ov_instr0_offset = iu4_ov_ifar_offset + uc_ifar;
   parameter                     iu4_ov_instr1_offset = iu4_ov_instr0_offset + 32;
   parameter                     iu4_ov_ext0_offset = iu4_ov_instr1_offset + 32;
   parameter                     iu4_ov_ext1_offset = iu4_ov_ext0_offset + 4;
   parameter                     iu4_ov_done_offset = iu4_ov_ext1_offset + 4;
   parameter                     scan_right = iu4_ov_done_offset + 1 - 1;

   // Latches
   wire [0:3]                    iu3_val_d;
   wire [62-`EFF_IFAR_WIDTH:61]  iu3_ifar_d;
   wire                          iu3_2ucode_d;
   wire                          iu3_2ucode_type_d;
   wire [0:33]                   iu3_0_instr_d;
   wire [0:33]                   iu3_1_instr_d;
   wire [0:33]                   iu3_2_instr_d;
   wire [0:33]                   iu3_3_instr_d;
   wire [0:3]                    iu3_val_l2;
   wire [62-`EFF_IFAR_WIDTH:61]  iu3_ifar_l2;
   wire                          iu3_2ucode_l2;
   wire                          iu3_2ucode_type_l2;
   wire [0:33]                   iu3_0_instr_l2;
   wire [0:33]                   iu3_1_instr_l2;
   wire [0:33]                   iu3_2_instr_l2;
   wire [0:33]                   iu3_3_instr_l2;

   wire                          iu_pc_err_ucode_illegal_d;
   wire                          iu_pc_err_ucode_illegal_l2;
   wire                          cp_flush_d;
   wire                          cp_flush_l2;
   wire                          br_iu_redirect_d;
   wire                          br_iu_redirect_l2;
   wire                          advance_buffers_d;
   wire                          advance_buffers_l2;
   wire                          romvalid_d;
   wire                          romvalid_l2;
   wire                          iu_flush_d;
   wire                          iu_flush_l2;
   wire                          br_hold_d;
   wire                          br_hold_l2;
   wire                          flush_into_uc_d;
   wire                          flush_into_uc_l2;
   wire                          np1_flush_d;
   wire                          np1_flush_l2;
   wire [43:61]                  flush_ifar_d;
   wire [43:61]                  flush_ifar_l2;

   reg  [0:1]                    iu4_valid_d;
   wire [62-uc_ifar:61]          iu4_ifar_d;
   wire [0:3]                    iu4_ext0_d;    //RT, S1, S2, S3
   wire [0:3]                    iu4_ext1_d;
   wire                          iu4_done_d;
   wire [0:1]                    iu4_valid_l2;
   wire [62-uc_ifar:61]          iu4_ifar_l2;
   wire [0:31]                   iu4_instr0_l2;
   wire [0:31]                   iu4_instr1_l2;
   wire [0:3]                    iu4_ext0_l2;
   wire [0:3]                    iu4_ext1_l2;
   wire                          iu4_done_l2;

   reg  [0:1]                    iu4_ov_valid_d;
   wire [62-uc_ifar:61]          iu4_ov_ifar_d;
   wire [0:31]                   iu4_ov_instr0_d;
   wire [0:31]                   iu4_ov_instr1_d;
   wire [0:3]                    iu4_ov_ext0_d;
   wire [0:3]                    iu4_ov_ext1_d;
   wire                          iu4_ov_done_d;
   wire [0:1]                    iu4_ov_valid_l2;
   wire [62-uc_ifar:61]          iu4_ov_ifar_l2;
   wire [0:31]                   iu4_ov_instr0_l2;
   wire [0:31]                   iu4_ov_instr1_l2;
   wire [0:3]                    iu4_ov_ext0_l2;
   wire [0:3]                    iu4_ov_ext1_l2;
   wire                          iu4_ov_done_l2;

   wire                          uc_val;
   wire                          uc_end;
   wire                          cplbuffer_full;
   wire                          clear_ill_flush_2ucode;
   wire                          next_valid;
   wire [0:31]                   next_instr;
   wire                          iu2_flush;
   wire                          flush_next;
   wire                          flush_next_control;
   wire                          flush_current;
   wire                          uc_iu4_flush_int;

   wire                          uc_default_act;
   wire                          uc_stall;
   wire                          new_command;
   wire                          msr_64bit;
   wire                          early_end;
   wire                          new_cond;

   wire [0:8]                    rom_ra;
   wire [62-uc_ifar:61]          ucode_ifar;
   wire [0:31]                   ucode_instr_even;
   wire [0:31]                   ucode_instr_odd;
   wire [0:3]                    ucode_ext_even;
   wire [0:3]                    ucode_ext_odd;
   wire [0:1]                    ucode_valid;

   wire                          rom_act;
   wire [0:9]                    rom_addr_even;
   wire [0:9]                    rom_addr_odd;
   wire                          iu4_stall;
   wire                          data_valid;
   wire [0:ucode_width-1]        rom_data_even;
   wire [0:ucode_width-1]        rom_data_odd;

   wire [0:31]                   rom_data_even_late_d;
   wire [0:31]                   rom_data_even_late_l2;
   wire [0:31]                   rom_data_odd_late_d;
   wire [0:31]                   rom_data_odd_late_l2;

   wire                          ra_valid;

   wire                          iu4_stage_act;
   wire                          iu4_ov_stage_act;
   reg [62-uc_ifar:61]           iu4_ifar_out;

   wire                          pc_iu_func_sl_thold_1;
   wire                          pc_iu_func_sl_thold_0;
   wire                          pc_iu_func_sl_thold_0_b;
   wire                          pc_iu_sg_1;
   wire                          pc_iu_sg_0;
   wire                          force_t;

   wire                          xu_iu_flush;

   wire [0:scan_right+4]         siv;
   wire [0:scan_right+4]         sov;

   wire                          tidn;
   wire                          tiup;

   assign tidn = 1'b0;
   assign tiup = 1'b1;

   //---------------------------------------------------------------------
   // latch inputs
   //---------------------------------------------------------------------
   assign iu3_val_d = {4{(~iu2_flush) & (~xu_iu_flush) & (~ic_bp_iu2_error)}} & ic_bp_iu2_val;
   assign iu3_ifar_d = ic_bp_iu2_ifar;
   assign iu3_2ucode_d = ic_bp_iu2_2ucode & ic_bp_iu2_val[0];
   assign iu3_2ucode_type_d = ic_bp_iu2_2ucode_type & ic_bp_iu2_val[0];
   assign iu3_0_instr_d = ic_bp_iu2_0_instr;
   assign iu3_1_instr_d = ic_bp_iu2_1_instr;
   assign iu3_2_instr_d = ic_bp_iu2_2_instr;
   assign iu3_3_instr_d = ic_bp_iu2_3_instr;

   //---------------------------------------------------------------------
   // buffers
   //---------------------------------------------------------------------

   iuq_uc_buffer  iuq_uc_buffer0(
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
      .scan_in(siv[scan_right + 4]),
      .scan_out(sov[scan_right + 4]),
      .iu3_val_l2(iu3_val_l2),
      .iu3_ifar_l2(iu3_ifar_l2),
      .iu3_2ucode_l2(iu3_2ucode_l2),
      .iu3_0_instr_l2(iu3_0_instr_l2),
      .iu3_1_instr_l2(iu3_1_instr_l2),
      .iu3_2_instr_l2(iu3_2_instr_l2),
      .iu3_3_instr_l2(iu3_3_instr_l2),
      .ic_bp_iu2_flush(ic_bp_iu2_flush),
      .ic_bp_iu3_flush(ic_bp_iu3_flush),
      .ic_bp_iu3_ecc_err(ic_bp_iu3_ecc_err),
      .bp_ib_iu3_val(bp_ib_iu3_val),
      .uc_ib_iu3_invalid(uc_ib_iu3_invalid),
      .uc_ib_iu3_flush_all(uc_ib_iu3_flush_all),
      .uc_ic_hold(uc_ic_hold),
      .uc_iu4_flush(uc_iu4_flush_int),
      .uc_iu4_flush_ifar(uc_iu4_flush_ifar),
      .xu_iu_flush(xu_iu_flush),
      .uc_val(uc_val),
      .advance_buffers(advance_buffers_l2),
      .br_hold_l2(br_hold_l2),
      .cplbuffer_full(cplbuffer_full),
      .clear_ill_flush_2ucode(clear_ill_flush_2ucode),
      .next_valid(next_valid),
      .next_instr(next_instr),
      .iu2_flush(iu2_flush),
      .flush_next(flush_next),
      .flush_current(flush_current)
   );

   assign uc_iu4_flush = uc_iu4_flush_int;

   //---------------------------------------------------------------------
   // new command
   //---------------------------------------------------------------------
   assign uc_default_act = flush_into_uc_l2 | next_valid | uc_val | iu4_valid_l2[0] | iu4_ov_valid_l2[0];

   // stall if same command in buffer0 next cycle
   assign uc_stall = (uc_val & (~uc_end)) |
                      br_hold_l2 | cplbuffer_full;   // we need this line if we use new_command to increment cplbuffer (br_hold_l2 prevents underwrap, cplbuffer_full prevents overflow)


   assign new_command = next_valid & (~uc_stall);    // Check that it can receive next command

   assign advance_buffers_d = new_command & uc_val;

   assign msr_64bit = tidn;     // Unused

   // output
   assign early_end = (~late_end);

   // If '1', will skip lines with skip_cond bit set
   assign new_cond = (~iu3_2ucode_type_l2);

   //---------------------------------------------------------------------
   // look up address
   //---------------------------------------------------------------------

/*
//table_start
?TABLE get_address LISTING(final) OPTIMIZE PARMS(ON-SET, DC-SET);
*INPUTS*============================================*OUTPUTS*====================*
|                                                   |                            |
| next_instr                                        | start_addr                 |
| |      next_instr                                 | |                          |
| |      |            iu3_2ucode_l2                 | |          xer_type        |
| |      |            | iu3_2ucode_type_l2          | |          | late_end      | # For update form, etc.
| |      |            | | msr_64bit                 | |          | | force_ep    |
| |      |            | | |                         | |          | | | fxm_type  |
| |      |            | | |                         | |          | | | | uc_legal|
| |      22222222233  | | |                         | |          | | | | |       |
| 012345 12345678901  | | |                         | 0123456789 | | | | |       |
*TYPE*==============================================+============================+
| PPPPPP PPPPPPPPPPP  P P P                         | SSSSSSSSSS S S S S S       |
*TERMS*=============================================+============================+
| 101000 ...........  . . .                         | 0000000000 0 0 0 0 1       | lhz       # Flushed 2ucode
| 011111 0100010111.  . . .                         | 0000010000 0 0 0 0 1       | lhzx
| 011111 0100011111.  . . .                         | 0000010000 0 0 1 0 1       | lhepx
| 101010 ...........  . . .                         | 0000100000 0 0 0 0 1       | lha
| 011111 0101010111.  . . .                         | 0000110000 0 0 0 0 1       | lhax
| 100000 ...........  . . .                         | 0001000000 0 0 0 0 1       | lwz
| 011111 0000010111.  . . .                         | 0001010000 0 0 0 0 1       | lwzx
| 011111 0000011111.  . . .                         | 0001010000 0 0 1 0 1       | lwepx
| 111010 .........10  . . .                         | 0001100000 0 1 0 0 1       | lwa
| 011111 0101010101.  . . .                         | 0001110000 0 0 0 0 1       | lwax
| 111010 .........00  . . .                         | 0010000000 0 0 0 0 1       | ld
| 011111 0000010101.  . . .                         | 0010010000 0 0 0 0 1       | ldx
| 011111 0000011101.  . . .                         | 0010010000 0 0 1 0 1       | ldepx

| 101100 ...........  . . .                         | 0100000000 0 0 0 0 1       | sth
| 011111 0110010111.  . . .                         | 0100010000 0 0 0 0 1       | sthx
| 011111 0110011111.  . . .                         | 0100010000 0 0 1 0 1       | sthepx
| 101101 ...........  . . .                         | 0100000000 0 1 0 0 1       | sthu
| 011111 0110110111.  . . .                         | 0100010000 0 1 0 0 1       | sthux
| 100100 ...........  . . .                         | 0101000000 0 0 0 0 1       | stw
| 011111 0010010111.  . . .                         | 0101010000 0 0 0 0 1       | stwx
| 011111 0010011111.  . . .                         | 0101010000 0 0 1 0 1       | stwepx
| 100101 ...........  . . .                         | 0101000000 0 1 0 0 1       | stwu
| 011111 0010110111.  . . .                         | 0101010000 0 1 0 0 1       | stwux
| 111110 .........00  . . .                         | 0110000000 0 0 0 0 1       | std
| 011111 0010010101.  . . .                         | 0110010000 0 0 0 0 1       | stdx
| 011111 0010011101.  . . .                         | 0110010000 0 0 1 0 1       | stdepx
| 111110 .........01  . . .                         | 0110000000 0 1 0 0 1       | stdu
| 011111 0010110101.  . . .                         | 0110010000 0 1 0 0 1       | stdux
| 011111 1100010110.  . . .                         | 0000010000 0 0 0 0 1       | lhbrx
| 011111 1000010110.  . . .                         | 0001010000 0 0 0 0 1       | lwbrx
| 011111 1000010100.  . . .                         | 0010010000 0 0 0 0 1       | ldbrx
| 011111 1110010110.  . . .                         | 0100010000 0 0 0 0 1       | sthbrx
| 011111 1010010110.  . . .                         | 0101010000 0 0 0 0 1       | stwbrx
| 011111 1010010100.  . . .                         | 0110010000 0 0 0 0 1       | stdbrx
|                                                   |                            |
| 011111 1000000000.  . . .                         | 0101100000 0 1 0 0 1       | mcrxr
| 011111 0000010011.  . . .                         | 0101110000 0 1 0 0 1       | mfcr
| 011111 0010010000.  . . .                         | 0111110000 0 1 0 1 1       | mtcrf
| 011111 0010010000.  . . .                         | 0111110000 0 1 0 1 1       | mtocrf # Flushed 2ucode
|                                                   |                            |
| 101001 ...........  1 . .                         | 0000000000 0 1 0 0 1       | lhzu # Flushed 2ucode
| 011111 0100110111.  1 . .                         | 0000010000 0 1 0 0 1       | lhzux
| 101011 ...........  1 . .                         | 0000100000 0 1 0 0 1       | lhau
| 011111 0101110111.  1 . .                         | 0000110000 0 1 0 0 1       | lhaux
| 100001 ...........  1 . .                         | 0001000000 0 1 0 0 1       | lwzu
| 011111 0000110111.  1 . .                         | 0001010000 0 1 0 0 1       | lwzux
| 011111 0101110101.  1 . .                         | 0001110000 0 1 0 0 1       | lwaux
| 111010 .........01  1 . .                         | 0010000000 0 1 0 0 1       | ldu
| 011111 0000110101.  1 . .                         | 0010010000 0 1 0 0 1       | ldux
|                                                   |                            |
| 100011 ...........  . . .                         | 1010100000 0 1 0 0 1       | lbzu # Aligned
| 011111 0001110111.  . . .                         | 1010101000 0 1 0 0 1       | lbzux
| 101001 ...........  0 . .                         | 1010110000 0 1 0 0 1       | lhzu
| 011111 0100110111.  0 . .                         | 1010111000 0 1 0 0 1       | lhzux
| 101011 ...........  0 . .                         | 1011100000 0 1 0 0 1       | lhau
| 011111 0101110111.  0 . .                         | 1011101000 0 1 0 0 1       | lhaux
| 100001 ...........  0 . .                         | 1011000000 0 1 0 0 1       | lwzu
| 011111 0000110111.  0 . .                         | 1011001000 0 1 0 0 1       | lwzux
| 011111 0101110101.  0 . .                         | 1011111000 0 1 0 0 1       | lwaux
| 111010 .........01  0 . .                         | 1011010000 0 1 0 0 1       | ldu
| 011111 0000110101.  0 . .                         | 1011011000 0 1 0 0 1       | ldux
| 101110 ...........  . . .                         | 0010100000 0 1 0 0 1       | lmw
| 011111 1001010101.  . . .                         | 0010110000 0 1 0 0 1       | lswi
| 011111 1000010101.  . . .                         | 0011010000 1 1 0 0 1       | lswx
| 101111 ...........  . . .                         | 0110100000 0 1 0 0 1       | stmw
| 011111 1011010101.  . . .                         | 0110110000 0 1 0 0 1       | stswi
| 011111 1010010101.  . . .                         | 0111010000 1 1 0 0 1       | stswx
|                                                   |                            |
| 110001 ...........  0 . .                         | 1111000000 0 1 0 0 1       | lfsu # Aligned
| 011111 1000110111.  0 . .                         | 1111001000 0 1 0 0 1       | lfsux
| 110011 ...........  0 . .                         | 1111010000 0 1 0 0 1       | lfdu
| 011111 1001110111.  0 . .                         | 1111011000 0 1 0 0 1       | lfdux
|                                                   |                            |
| 011111 1101010111.  . . .                         | 1000110000 0 1 0 0 1       | lfiwax # Flushed 2ucode
| 011111 1101110111.  . . .                         | 1001110000 0 1 0 0 1       | lfiwzx
| 110000 ...........  . . .                         | 1001000000 0 0 0 0 1       | lfs
| 011111 1000010111.  . . .                         | 1001010000 0 0 0 0 1       | lfsx
| 110001 ...........  1 . .                         | 1001000000 0 1 0 0 1       | lfsu
| 011111 1000110111.  1 . .                         | 1001010000 0 1 0 0 1       | lfsux
| 110010 ...........  . . .                         | 1010000000 0 0 0 0 1       | lfd
| 011111 1001010111.  . . .                         | 1010010000 0 0 0 0 1       | lfdx
| 011111 1001011111.  . . .                         | 1010010000 0 0 1 0 1       | lfdepx
| 110011 ...........  1 . .                         | 1010000000 0 1 0 0 1       | lfdu
| 011111 1001110111.  1 . .                         | 1010010000 0 1 0 0 1       | lfdux
|                                                   |                            |
| 011111 1111010111.  . . .                         | 1100110000 0 1 0 0 1       | stfiwx
| 110100 ...........  . . .                         | 1101000000 0 0 0 0 1       | stfs
| 011111 1010010111.  . . .                         | 1101010000 0 0 0 0 1       | stfsx
| 110101 ...........  . . .                         | 1101000000 0 1 0 0 1       | stfsu
| 011111 1010110111.  . . .                         | 1101010000 0 1 0 0 1       | stfsux
| 110110 ...........  . . .                         | 1110000000 0 0 0 0 1       | stfd
| 011111 1011010111.  . . .                         | 1110010000 0 0 0 0 1       | stfdx
| 011111 1011011111.  . . .                         | 1110010000 0 0 1 0 1       | stfdepx
| 110111 ...........  . . .                         | 1110000000 0 1 0 0 1       | stfdu
| 011111 1011110111.  . . .                         | 1110010000 0 1 0 0 1       | stfdux
|                                                   |                            |
| 000100 .....10101.  . . .                         | 1100000000 0 1 0 0 1       | qvfadd
| 000000 .....10101.  . . .                         | 1100000000 0 1 0 0 1       | qvfadds
| 000100 .....10100.  . . .                         | 1100000000 0 1 0 0 1       | qvfsub
| 000000 .....10100.  . . .                         | 1100000000 0 1 0 0 1       | qvfsubs
| 000100 .....11000.  . . .                         | 1100000000 0 1 0 0 1       | qvfre
| 000000 .....11000.  . . .                         | 1100000000 0 1 0 0 1       | qvfres
| 000100 .....11010.  . . .                         | 1100000000 0 1 0 0 1       | frsqrte
| 000000 .....11010.  . . .                         | 1100000000 0 1 0 0 1       | frsqrtes
| 000100 .....11101.  . . .                         | 1100000000 0 1 0 0 1       | qvfmadd
| 000000 .....11101.  . . .                         | 1100000000 0 1 0 0 1       | qvfmadds
| 000100 .....11100.  . . .                         | 1100000000 0 1 0 0 1       | qvfmsub
| 000000 .....11100.  . . .                         | 1100000000 0 1 0 0 1       | qvfmsubs
| 000100 .....11111.  . . .                         | 1100000000 0 1 0 0 1       | qvfnmadd
| 000000 .....11111.  . . .                         | 1100000000 0 1 0 0 1       | qvfnmadds
| 000100 .....11110.  . . .                         | 1100000000 0 1 0 0 1       | qvfnmsub
| 000000 .....11110.  . . .                         | 1100000000 0 1 0 0 1       | qvfnmsubs
| 000100 .....01001.  . . .                         | 1100000000 0 1 0 0 1       | qvfxmadd
| 000000 .....01001.  . . .                         | 1100000000 0 1 0 0 1       | qvfxmadds
| 000100 .....01011.  . . .                         | 1100000000 0 1 0 0 1       | qvfxxnpmadd
| 000000 .....01011.  . . .                         | 1100000000 0 1 0 0 1       | qvfxxnpmadds
| 000100 .....00011.  . . .                         | 1100000000 0 1 0 0 1       | qvfxxcpnmadd
| 000000 .....00011.  . . .                         | 1100000000 0 1 0 0 1       | qvfxxcpnmadds
| 000100 .....00001.  . . .                         | 1100000000 0 1 0 0 1       | qvfxxmadd
| 000000 .....00001.  . . .                         | 1100000000 0 1 0 0 1       | qvfxxmadds
| 000100 1101001110.  . . .                         | 1100010000 0 1 0 0 1       | qvfcfid - SP prenorm only
|                                                   |                            |
| 111111 .....10101.  . . .                         | 1100000000 0 1 0 0 1       | fadd
| 111011 .....10101.  . . .                         | 1100000000 0 1 0 0 1       | fadds
| 111111 0000100000.  . . .                         | 1100000000 0 1 0 0 1       | fcmpo
| 111111 0000000000.  . . .                         | 1100000000 0 1 0 0 1       | fcmpu
| 111111 .....10010.  . . .                         | 1100001000 0 1 0 0 1       | fdiv
| 111011 .....10010.  . . .                         | 1100001000 0 1 0 0 1       | fdivs
| 111111 .....11101.  . . .                         | 1100000000 0 1 0 0 1       | fmadd
| 111011 .....11101.  . . .                         | 1100000000 0 1 0 0 1       | fmadds
| 111111 .....11100.  . . .                         | 1100000000 0 1 0 0 1       | fmsub
| 111011 .....11100.  . . .                         | 1100000000 0 1 0 0 1       | fmsubs
| 111111 .....11111.  . . .                         | 1100000000 0 1 0 0 1       | fnmadd
| 111011 .....11111.  . . .                         | 1100000000 0 1 0 0 1       | fnmadds
| 111111 .....11110.  . . .                         | 1100000000 0 1 0 0 1       | fnmsub
| 111011 .....11110.  . . .                         | 1100000000 0 1 0 0 1       | fnmsubs
| 111111 .....11000.  . . .                         | 1100000000 0 1 0 0 1       | fre
| 111011 .....11000.  . . .                         | 1100000000 0 1 0 0 1       | fres
| 111111 1101001110.  . . .                         | 1100000000 0 1 0 0 1       | fcfid
| 111111 1111001110.  . . .                         | 1100000000 0 1 0 0 1       | fcfidu
| 111011 1101001110.  . . .                         | 1100000000 0 1 0 0 1       | fcfids
| 111011 1111001110.  . . .                         | 1100000000 0 1 0 0 1       | fcfidus
| 111111 .....11010.  . . .                         | 1100000000 0 1 0 0 1       | frsqrte
| 111011 .....11010.  . . .                         | 1100000000 0 1 0 0 1       | frsqrtes
| 111111 .....10100.  . . .                         | 1100000000 0 1 0 0 1       | fsub
| 111011 .....10100.  . . .                         | 1100000000 0 1 0 0 1       | fsubs
| 111111 .....10110.  . . .                         | 1100000000 0 1 0 0 1       | fsqrt
| 111011 .....10110.  . . .                         | 1100000000 0 1 0 0 1       | fsqrts
| 111111 0010000000.  . . .                         | 1100001000 0 1 0 0 1       | ftdiv
| 111111 0010100000.  . . .                         | 1100000000 0 1 0 0 1       | ftsqrt
| 111111 1011000111.  . . .                         | 1100000000 0 1 0 0 1       | mtfsf
*END*===============================================+============================+
?TABLE END get_address ;
//table_end
*/

//assign_start

assign get_address_pt[1] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 16'b0001001101001110);
assign get_address_pt[2] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 16'b1111110010000000);
assign get_address_pt[3] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 16'b0111111000000000);
assign get_address_pt[4] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 15'b011111101011111);
assign get_address_pt[5] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[30] , iu3_2ucode_l2
     }) === 16'b0111110000110110);
assign get_address_pt[6] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[25] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] , iu3_2ucode_l2
     }) === 16'b0111111001101110);
assign get_address_pt[7] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[30] , iu3_2ucode_l2
     }) === 16'b0111110101110111);
assign get_address_pt[8] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 15'b011111010110101);
assign get_address_pt[9] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30] ,
    iu3_2ucode_l2 }) === 17'b01111101001101110);
assign get_address_pt[10] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 15'b011111101101111);
assign get_address_pt[11] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[23] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 15'b011111111010111);
assign get_address_pt[12] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 14'b01111100011111);
assign get_address_pt[13] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[3] , next_instr[4] ,
    next_instr[5] , next_instr[21] ,
    next_instr[22] , next_instr[23] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 15'b111111011000111);
assign get_address_pt[14] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[30]
     }) === 14'b01111100001111);
assign get_address_pt[15] =
    (({ next_instr[1] , next_instr[2] ,
    next_instr[3] , next_instr[4] ,
    next_instr[5] , next_instr[21] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 14'b11111110010110);
assign get_address_pt[16] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[30] , iu3_2ucode_l2
     }) === 16'b0111110101110110);
assign get_address_pt[17] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[30] }) === 15'b011111010101011);
assign get_address_pt[18] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 15'b011111100010101);
assign get_address_pt[19] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 16'b0111110010010000);
assign get_address_pt[20] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 16'b0111111101110111);
assign get_address_pt[21] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 16'b0111110001110111);
assign get_address_pt[22] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 15'b011111101110111);
assign get_address_pt[23] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[22] , next_instr[24] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] , iu3_2ucode_l2
     }) === 14'b01111100101111);
assign get_address_pt[24] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28]
     }) === 14'b01111110100101);
assign get_address_pt[25] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[23] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 14'b01111101001111);
assign get_address_pt[26] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30] ,
    iu3_2ucode_l2 }) === 15'b011111001101111);
assign get_address_pt[27] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[28] , next_instr[30]
     }) === 14'b01111100100111);
assign get_address_pt[28] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 14'b01111100001111);
assign get_address_pt[29] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 16'b0111110000010011);
assign get_address_pt[30] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[24] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[30]
     }) === 14'b01111100101011);
assign get_address_pt[31] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[25] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[30]
     }) === 14'b01111110101011);
assign get_address_pt[32] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[3] , next_instr[4] ,
    next_instr[5] , next_instr[21] ,
    next_instr[22] , next_instr[24] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 13'b1111100000000);
assign get_address_pt[33] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29]
     }) === 14'b01111110001011);
assign get_address_pt[34] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 15'b011111000110101);
assign get_address_pt[35] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 14'b01111110010110);
assign get_address_pt[36] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[23] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 14'b01111110110111);
assign get_address_pt[37] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[23] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 15'b011111010110111);
assign get_address_pt[38] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[4] ,
    next_instr[5] , next_instr[21] ,
    next_instr[22] , next_instr[24] ,
    next_instr[25] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 13'b1111111101110);
assign get_address_pt[39] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29]
     }) === 14'b01111110001010);
assign get_address_pt[40] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 15'b011111101010101);
assign get_address_pt[41] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 14'b01111100001101);
assign get_address_pt[42] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 15'b011111111010111);
assign get_address_pt[43] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[22] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 14'b01111100110111);
assign get_address_pt[44] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[24] , next_instr[25] ,
    next_instr[26] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 14'b01111110101111);
assign get_address_pt[45] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[24] ,
    next_instr[25] , next_instr[26] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 13'b0111110001111);
assign get_address_pt[46] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[30] , next_instr[31] ,
    iu3_2ucode_l2 }) === 9'b111010010);
assign get_address_pt[47] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[21] , next_instr[22] ,
    next_instr[26] , next_instr[27] ,
    next_instr[28] , next_instr[29] ,
    next_instr[30] }) === 13'b0111111010111);
assign get_address_pt[48] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[4] ,
    next_instr[5] , next_instr[26] ,
    next_instr[28] , next_instr[30]
     }) === 8'b00000001);
assign get_address_pt[49] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[4] ,
    next_instr[5] , next_instr[26] ,
    next_instr[27] , next_instr[30]
     }) === 8'b00000110);
assign get_address_pt[50] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[4] ,
    next_instr[5] , next_instr[26] ,
    next_instr[27] , next_instr[28]
     }) === 8'b00000111);
assign get_address_pt[51] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[4] ,
    next_instr[5] , next_instr[26] ,
    next_instr[28] , next_instr[29]
     }) === 8'b00000110);
assign get_address_pt[52] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    iu3_2ucode_l2 }) === 7'b1100110);
assign get_address_pt[53] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[4] ,
    next_instr[5] , next_instr[30] ,
    next_instr[31] }) === 7'b1111001);
assign get_address_pt[54] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    iu3_2ucode_l2 }) === 7'b1010010);
assign get_address_pt[55] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    next_instr[30] , next_instr[31]
     }) === 8'b11101010);
assign get_address_pt[56] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5] ,
    iu3_2ucode_l2 }) === 7'b1010110);
assign get_address_pt[57] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[4] ,
    next_instr[5] , next_instr[26] ,
    next_instr[27] , next_instr[28] ,
    next_instr[29] , next_instr[30]
     }) === 10'b1111110010);
assign get_address_pt[58] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[5] , iu3_2ucode_l2
     }) === 6'b110010);
assign get_address_pt[59] =
    (({ next_instr[0] , next_instr[2] ,
    next_instr[3] , next_instr[5] ,
    iu3_2ucode_l2 }) === 5'b10010);
assign get_address_pt[60] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[3] , next_instr[4] ,
    next_instr[5] , next_instr[30]
     }) === 6'b111100);
assign get_address_pt[61] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] , next_instr[5]
     }) === 6'b100011);
assign get_address_pt[62] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[3] , next_instr[4]
     }) === 4'b1010);
assign get_address_pt[63] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[3] , next_instr[5]
     }) === 4'b1001);
assign get_address_pt[64] =
    (({ next_instr[0] , next_instr[2] ,
    next_instr[4] , next_instr[5]
     }) === 4'b1001);
assign get_address_pt[65] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[4] , next_instr[5] ,
    next_instr[30] }) === 5'b11100);
assign get_address_pt[66] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[4] ,
    next_instr[5] , next_instr[26] ,
    next_instr[27] , next_instr[30]
     }) === 8'b11111110);
assign get_address_pt[67] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[4]
     }) === 4'b1011);
assign get_address_pt[68] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3]
     }) === 4'b1101);
assign get_address_pt[69] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[4] }) === 5'b10111);
assign get_address_pt[70] =
    (({ next_instr[0] , next_instr[2] ,
    next_instr[4] }) === 3'b100);
assign get_address_pt[71] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[4] ,
    next_instr[5] , next_instr[26] ,
    next_instr[27] , next_instr[28]
     }) === 8'b11111111);
assign get_address_pt[72] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[4] ,
    next_instr[5] , next_instr[26] ,
    next_instr[28] , next_instr[29]
     }) === 8'b11111110);
assign get_address_pt[73] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[3] ,
    next_instr[5] }) === 5'b10111);
assign get_address_pt[74] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[5]
     }) === 4'b1101);
assign get_address_pt[75] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[4] ,
    next_instr[5] , next_instr[26] ,
    next_instr[28] , next_instr[30]
     }) === 8'b11111110);
assign get_address_pt[76] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] }) === 3'b110);
assign get_address_pt[77] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] }) === 3'b101);
assign get_address_pt[78] =
    (({ next_instr[0] , next_instr[1] ,
    next_instr[2] , next_instr[4]
     }) === 4'b1101);
assign start_addr[0] =
    (get_address_pt[1] | get_address_pt[5]
     | get_address_pt[9] | get_address_pt[13]
     | get_address_pt[16] | get_address_pt[20]
     | get_address_pt[21] | get_address_pt[32]
     | get_address_pt[38] | get_address_pt[42]
     | get_address_pt[44] | get_address_pt[46]
     | get_address_pt[47] | get_address_pt[48]
     | get_address_pt[49] | get_address_pt[50]
     | get_address_pt[51] | get_address_pt[54]
     | get_address_pt[56] | get_address_pt[57]
     | get_address_pt[59] | get_address_pt[61]
     | get_address_pt[66] | get_address_pt[71]
     | get_address_pt[72] | get_address_pt[75]
     | get_address_pt[76]);
assign start_addr[1] =
    (get_address_pt[1] | get_address_pt[3]
     | get_address_pt[6] | get_address_pt[10]
     | get_address_pt[11] | get_address_pt[13]
     | get_address_pt[15] | get_address_pt[19]
     | get_address_pt[24] | get_address_pt[25]
     | get_address_pt[27] | get_address_pt[29]
     | get_address_pt[30] | get_address_pt[31]
     | get_address_pt[32] | get_address_pt[36]
     | get_address_pt[37] | get_address_pt[38]
     | get_address_pt[48] | get_address_pt[49]
     | get_address_pt[50] | get_address_pt[51]
     | get_address_pt[57] | get_address_pt[58]
     | get_address_pt[60] | get_address_pt[62]
     | get_address_pt[66] | get_address_pt[68]
     | get_address_pt[71] | get_address_pt[72]
     | get_address_pt[73] | get_address_pt[75]
    );
assign start_addr[2] =
    (get_address_pt[5] | get_address_pt[6]
     | get_address_pt[9] | get_address_pt[16]
     | get_address_pt[19] | get_address_pt[21]
     | get_address_pt[22] | get_address_pt[34]
     | get_address_pt[39] | get_address_pt[40]
     | get_address_pt[41] | get_address_pt[44]
     | get_address_pt[54] | get_address_pt[56]
     | get_address_pt[59] | get_address_pt[61]
     | get_address_pt[65] | get_address_pt[69]
     | get_address_pt[78]);
assign start_addr[3] =
    (get_address_pt[3] | get_address_pt[5]
     | get_address_pt[6] | get_address_pt[8]
     | get_address_pt[16] | get_address_pt[18]
     | get_address_pt[19] | get_address_pt[20]
     | get_address_pt[28] | get_address_pt[29]
     | get_address_pt[33] | get_address_pt[43]
     | get_address_pt[46] | get_address_pt[55]
     | get_address_pt[56] | get_address_pt[58]
     | get_address_pt[70]);
assign start_addr[4] =
    (get_address_pt[3] | get_address_pt[7]
     | get_address_pt[9] | get_address_pt[16]
     | get_address_pt[17] | get_address_pt[19]
     | get_address_pt[20] | get_address_pt[21]
     | get_address_pt[29] | get_address_pt[40]
     | get_address_pt[42] | get_address_pt[54]
     | get_address_pt[55] | get_address_pt[61]
     | get_address_pt[67]);
assign start_addr[5] =
    (get_address_pt[1] | get_address_pt[7]
     | get_address_pt[8] | get_address_pt[9]
     | get_address_pt[17] | get_address_pt[19]
     | get_address_pt[20] | get_address_pt[22]
     | get_address_pt[23] | get_address_pt[26]
     | get_address_pt[29] | get_address_pt[33]
     | get_address_pt[34] | get_address_pt[35]
     | get_address_pt[36] | get_address_pt[37]
     | get_address_pt[39] | get_address_pt[40]
     | get_address_pt[41] | get_address_pt[42]
     | get_address_pt[44] | get_address_pt[45]
     | get_address_pt[46] | get_address_pt[52]
     | get_address_pt[54]);
assign start_addr[6] =
    (get_address_pt[2] | get_address_pt[5]
     | get_address_pt[6] | get_address_pt[9]
     | get_address_pt[16] | get_address_pt[21]
     | get_address_pt[57]);
assign start_addr[7] =
    1'b0;
assign start_addr[8] =
    1'b0;
assign start_addr[9] =
    1'b0;
assign xer_type =
    (get_address_pt[18]);
assign late_end =
    (get_address_pt[1] | get_address_pt[3]
     | get_address_pt[7] | get_address_pt[9]
     | get_address_pt[13] | get_address_pt[16]
     | get_address_pt[18] | get_address_pt[19]
     | get_address_pt[20] | get_address_pt[21]
     | get_address_pt[22] | get_address_pt[26]
     | get_address_pt[29] | get_address_pt[32]
     | get_address_pt[34] | get_address_pt[37]
     | get_address_pt[38] | get_address_pt[40]
     | get_address_pt[42] | get_address_pt[43]
     | get_address_pt[48] | get_address_pt[49]
     | get_address_pt[50] | get_address_pt[51]
     | get_address_pt[53] | get_address_pt[55]
     | get_address_pt[57] | get_address_pt[63]
     | get_address_pt[64] | get_address_pt[66]
     | get_address_pt[69] | get_address_pt[71]
     | get_address_pt[72] | get_address_pt[73]
     | get_address_pt[74] | get_address_pt[75]
    );
assign force_ep =
    (get_address_pt[4] | get_address_pt[12]
     | get_address_pt[14]);
assign fxm_type =
    (get_address_pt[19]);
assign uc_legal =
    (get_address_pt[1] | get_address_pt[3]
     | get_address_pt[7] | get_address_pt[9]
     | get_address_pt[13] | get_address_pt[16]
     | get_address_pt[17] | get_address_pt[19]
     | get_address_pt[20] | get_address_pt[21]
     | get_address_pt[26] | get_address_pt[29]
     | get_address_pt[32] | get_address_pt[34]
     | get_address_pt[35] | get_address_pt[37]
     | get_address_pt[38] | get_address_pt[39]
     | get_address_pt[40] | get_address_pt[41]
     | get_address_pt[42] | get_address_pt[43]
     | get_address_pt[44] | get_address_pt[45]
     | get_address_pt[47] | get_address_pt[48]
     | get_address_pt[49] | get_address_pt[50]
     | get_address_pt[51] | get_address_pt[55]
     | get_address_pt[57] | get_address_pt[61]
     | get_address_pt[65] | get_address_pt[66]
     | get_address_pt[70] | get_address_pt[71]
     | get_address_pt[72] | get_address_pt[75]
     | get_address_pt[77] | get_address_pt[78]
    );

//assign_end

   //---------------------------------------------------------------------
   // illegal op
   //---------------------------------------------------------------------

   // Need to handle the cmodx case where load/store gets flushed to uCode,
   // then that instruction is changed to some non-uCode instruction.
   // Solution: Any time an instruction was flushed_2ucode and doesn't hit
   // in table, flush instruction to clear flush_2ucode bit.  Instruction
   // will then re-fetch as regular instruction.
   assign clear_ill_flush_2ucode = new_command & (~uc_legal) & iu3_2ucode_l2;

   assign flush_next_control = flush_next | clear_ill_flush_2ucode;

   assign iu_pc_err_ucode_illegal_d = new_command & (~uc_legal) & (~iu3_2ucode_l2) & (~flush_next);

   tri_direct_err_rpt #(.WIDTH(1)) err_ucode_illegal(
      .vd(vdd),
      .gd(gnd),
      .err_in(iu_pc_err_ucode_illegal_l2),
      .err_out(iu_pc_err_ucode_illegal)
   );

   //---------------------------------------------------------------------
   // create instruction
   //---------------------------------------------------------------------
   assign xu_iu_flush = iu_flush_l2 | br_iu_redirect_l2;
   assign iu_flush_d = iu_flush;
   assign cp_flush_d = cp_flush;
   assign br_iu_redirect_d = br_iu_redirect & (~(cp_flush_l2 | iu_flush_l2));

   // When br_iu_redirect happens, hold off uCode commands until cp_flush
   // otherwise weird things happen
   assign br_hold_d = (cp_flush_l2 == 1'b1) ? 1'b0 :
                      (br_iu_redirect_l2 == 1'b1) ? 1'b1 :
                      br_hold_l2;

   assign flush_into_uc_d = iu_flush & cp_flush_into_uc;
   assign np1_flush_d = cp_uc_np1_flush;
   assign flush_ifar_d = cp_uc_flush_ifar;

   iuq_uc_control  uc_control(
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
      .scan_in(siv[scan_right + 1]),
      .scan_out(sov[scan_right + 1]),
      .xu_iu_ucode_xer_val(xu_iu_ucode_xer_val),
      .xu_iu_ucode_xer(xu_iu_ucode_xer),
      .br_hold(br_hold_l2),
      .flush_next(flush_next_control),
      .flush(flush_current),
      .flush_into_uc(flush_into_uc_l2),
      .np1_flush(np1_flush_l2),
      .flush_ifar(flush_ifar_l2),
      .cp_uc_credit_free(cp_uc_credit_free),
      .cp_flush(cp_flush_l2),
      .uc_default_act(uc_default_act),
      .next_valid(next_valid),
      .new_command(new_command),
      .new_instr(next_instr),
      .start_addr(start_addr[0:8]),  // bit (9) is unused - always even
      .xer_type(xer_type),
      .early_end(early_end),
      .force_ep(force_ep),
      .fxm_type(fxm_type),
      .new_cond(new_cond),
      .ra_valid(ra_valid),
      .rom_ra(rom_ra),
      .rom_act(rom_act),
      .data_valid(data_valid),
      .rom_data_even(rom_data_even[32:ucode_width - 1]),
      .rom_data_odd(rom_data_odd[32:ucode_width - 1]),
      .rom_data_even_late(rom_data_even_late_l2),
      .rom_data_odd_late(rom_data_odd_late_l2),
      .uc_val(uc_val),
      .uc_end(uc_end),
      .cplbuffer_full(cplbuffer_full),
      .ucode_valid(ucode_valid),
      .ucode_ifar_even(ucode_ifar),
      .ucode_instr_even(ucode_instr_even),
      .ucode_instr_odd(ucode_instr_odd),
      .ucode_ext_even(ucode_ext_even),
      .ucode_ext_odd(ucode_ext_odd)
   );

   //---------------------------------------------------------------------
   // ROM
   //---------------------------------------------------------------------

   assign romvalid_d = ra_valid;

   assign rom_addr_even = {rom_ra[0:8], 1'b0};
   assign rom_addr_odd = {rom_ra[0:8], 1'b1};

   assign iu4_stall = iu4_valid_l2[0] & iu4_ov_valid_l2[0];        // ??? Need to check vector if ever switch to only i1 being valid

   assign data_valid = romvalid_l2 & (~iu4_stall);

   //---------------------------------------------------------------------
   // ROM Lookup
   //---------------------------------------------------------------------

   iuq_uc_rom_even  uc_rom_even(
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
      .scan_in(siv[scan_right + 2]),
      .scan_out(sov[scan_right + 2]),
      .rom_act(rom_act),
      .rom_addr(rom_addr_even),
      .rom_data(rom_data_even)
   );
   assign rom_data_even_late_d = rom_data_even[0:31];

   iuq_uc_rom_odd  uc_rom_odd(
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
      .scan_in(siv[scan_right + 3]),
      .scan_out(sov[scan_right + 3]),
      .rom_act(rom_act),
      .rom_addr(rom_addr_odd),
      .rom_data(rom_data_odd)
   );
   assign rom_data_odd_late_d = rom_data_odd[0:31];

   //---------------------------------------------------------------------
   // Staging latches
   //---------------------------------------------------------------------
   assign iu4_stage_act = data_valid;  // ??? Removed "not flush and not skip" from act.  Do we want to add in some form of skip check?

   generate
   begin : xhdl1
     genvar  i;
     for (i = 0; i <= 1; i = i + 1)
     begin : gen_iu4_val
       always @(*) iu4_valid_d[i] <= ((ucode_valid[i] & (~iu4_stall)) |
                                      (iu4_valid_l2[i] & iu4_stall)) &
                     (~(iu_flush_l2 | br_iu_redirect_l2));     // clear on flush
     end
   end
   endgenerate

   assign iu4_ifar_d = ucode_ifar;
   assign iu4_ext0_d = ucode_ext_even;
   assign iu4_ext1_d = ucode_ext_odd;

   //late data
   assign iu4_instr0_l2 = ucode_instr_even;
   assign iu4_instr1_l2 = ucode_instr_odd;

   assign iu4_done_d = uc_end;

   // Overflow latches
   assign iu4_ov_stage_act = iu4_valid_l2[0] & (~iu4_ov_valid_l2[0]);
   generate
   begin : xhdl2
     genvar  i;
     for (i = 0; i <= 1; i = i + 1)
     begin : gen_ov_valid
       always @(*) iu4_ov_valid_d[i] <= (iu4_ov_valid_l2[i] | (iu4_valid_l2[i] & (~iu4_ov_valid_l2[0]))) & (~ib_uc_rdy) & (~(iu_flush_l2 | br_iu_redirect_l2));
     end
   end
   endgenerate

   assign iu4_ov_ifar_d = iu4_ifar_l2;
   assign iu4_ov_ext0_d = iu4_ext0_l2;
   assign iu4_ov_ext1_d = iu4_ext1_l2;
   assign iu4_ov_instr0_d = iu4_instr0_l2;
   assign iu4_ov_instr1_d = iu4_instr1_l2;
   assign iu4_ov_done_d = iu4_done_l2;

   // If uc_ifar > `EFF_IFAR_WIDTH, we
   //     need to change uc_control so uc_ifar is not bigger than EFF_IFAR_WIDTH
   //     so that we don't lose part of ifar on flush

   generate
   begin
     if (uc_ifar >= `EFF_IFAR_WIDTH)
     begin : ifara
       always @(*) uc_ib_ifar0 <= iu4_ifar_out[62 - `EFF_IFAR_WIDTH:61];
       always @(*) uc_ib_ifar1 <= {iu4_ifar_out[62 - `EFF_IFAR_WIDTH:60], 1'b1};
     end
     if (uc_ifar < `EFF_IFAR_WIDTH)
     begin : ifarb
       always @(*)
       begin
         uc_ib_ifar0[62 - `EFF_IFAR_WIDTH:62 - uc_ifar - 1] <= {`EFF_IFAR_WIDTH-uc_ifar{1'b0}};
         uc_ib_ifar1[62 - `EFF_IFAR_WIDTH:62 - uc_ifar - 1] <= {`EFF_IFAR_WIDTH-uc_ifar{1'b0}};

         uc_ib_ifar0[62 - uc_ifar:61] <= iu4_ifar_out;
         uc_ib_ifar1[62 - uc_ifar:61] <= {iu4_ifar_out[62 - uc_ifar:60], 1'b1};
       end
     end
   end
   endgenerate

   always @(iu4_ov_valid_l2 or iu4_ifar_l2 or iu4_instr0_l2 or iu4_instr1_l2 or iu4_valid_l2 or iu4_ext0_l2 or iu4_ext1_l2 or iu4_done_l2 or iu4_ov_ifar_l2 or iu4_ov_instr0_l2 or iu4_ov_instr1_l2 or iu4_ov_ext0_l2 or iu4_ov_ext1_l2 or iu4_ov_done_l2)
   begin: ib_proc
      uc_ib_val <= iu4_valid_l2;
      iu4_ifar_out <= iu4_ifar_l2;
      uc_ib_instr0 <= iu4_instr0_l2;
      uc_ib_instr1 <= iu4_instr1_l2;
      uc_ib_ext0 <= iu4_ext0_l2;
      uc_ib_ext1 <= iu4_ext1_l2;
      uc_ib_done <= iu4_done_l2;

      if (iu4_ov_valid_l2[0] == 1'b1)
      begin
         uc_ib_val <= iu4_ov_valid_l2;
         iu4_ifar_out <= iu4_ov_ifar_l2;
         uc_ib_instr0 <= iu4_ov_instr0_l2;
         uc_ib_instr1 <= iu4_ov_instr1_l2;
         uc_ib_ext0 <= iu4_ov_ext0_l2;
         uc_ib_ext1 <= iu4_ov_ext1_l2;
         uc_ib_done <= iu4_ov_done_l2;
      end
   end

   //---------------------------------------------------------------------
   // Latches
   //---------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) iu3_val_latch(
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
      .scin(siv[iu3_val_offset:iu3_val_offset + 4 - 1]),
      .scout(sov[iu3_val_offset:iu3_val_offset + 4 - 1]),
      .din(iu3_val_d),
      .dout(iu3_val_l2)
   );

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(0)) iu3_ifar_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ic_bp_iu2_val[0]),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu3_ifar_offset:iu3_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov[iu3_ifar_offset:iu3_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .din(iu3_ifar_d),
      .dout(iu3_ifar_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(0)) iu3_2ucode_latch(
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
      .scin(siv[iu3_2ucode_offset]),
      .scout(sov[iu3_2ucode_offset]),
      .din(iu3_2ucode_d),
      .dout(iu3_2ucode_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(0)) iu3_2ucode_type_latch(
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
      .scin(siv[iu3_2ucode_type_offset]),
      .scout(sov[iu3_2ucode_type_offset]),
      .din(iu3_2ucode_type_d),
      .dout(iu3_2ucode_type_l2)
   );

   tri_rlmreg_p #(.WIDTH(34 * 4), .INIT(0), .NEEDS_SRESET(0)) iu3_instr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ic_bp_iu2_val[0]),    // ??? Could create act for 0:31 when buffers full?
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu3_instr_offset:iu3_instr_offset + (34 * 4) - 1]),
      .scout(sov[iu3_instr_offset:iu3_instr_offset + (34 * 4) - 1]),
      .din({iu3_0_instr_d, iu3_1_instr_d, iu3_2_instr_d, iu3_3_instr_d}),
      .dout({iu3_0_instr_l2, iu3_1_instr_l2, iu3_2_instr_l2, iu3_3_instr_l2})
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(0)) iu_pc_err_ucode_illegal_latch(
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
      .scin(siv[iu_pc_err_ucode_illegal_offset]),
      .scout(sov[iu_pc_err_ucode_illegal_offset]),
      .din(iu_pc_err_ucode_illegal_d),
      .dout(iu_pc_err_ucode_illegal_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(0)) iu_flush_latch(
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
      .scin(siv[iu_flush_offset]),
      .scout(sov[iu_flush_offset]),
      .din(iu_flush_d),
      .dout(iu_flush_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) br_hold_latch(
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
      .scin(siv[br_hold_offset]),
      .scout(sov[br_hold_offset]),
      .din(br_hold_d),
      .dout(br_hold_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) flush_into_uc_latch(
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
      .scin(siv[flush_into_uc_offset]),
      .scout(sov[flush_into_uc_offset]),
      .din(flush_into_uc_d),
      .dout(flush_into_uc_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) np1_flush_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cp_flush_into_uc),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[np1_flush_offset]),
      .scout(sov[np1_flush_offset]),
      .din(np1_flush_d),
      .dout(np1_flush_l2)
   );

   tri_rlmreg_p #(.WIDTH(19), .INIT(0), .NEEDS_SRESET(0)) flush_ifar_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cp_flush_into_uc),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[flush_ifar_offset:flush_ifar_offset + 19 - 1]),
      .scout(sov[flush_ifar_offset:flush_ifar_offset + 19 - 1]),
      .din(flush_ifar_d),
      .dout(flush_ifar_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp_flush_latch(
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
      .dout(cp_flush_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) br_iu_redirect_latch(
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
      .scin(siv[br_iu_redirect_offset]),
      .scout(sov[br_iu_redirect_offset]),
      .din(br_iu_redirect_d),
      .dout(br_iu_redirect_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) advance_buffers_latch(
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
      .scin(siv[advance_buffers_offset]),
      .scout(sov[advance_buffers_offset]),
      .din(advance_buffers_d),
      .dout(advance_buffers_l2)
   );

   // ROM
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) romvalid_latch(
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
      .scin(siv[romvalid_offset]),
      .scout(sov[romvalid_offset]),
      .din(romvalid_d),
      .dout(romvalid_l2)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(0)) rom_data_even_late_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu4_stage_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[rom_data_even_late_offset:rom_data_even_late_offset + 32 - 1]),
      .scout(sov[rom_data_even_late_offset:rom_data_even_late_offset + 32 - 1]),
      .din(rom_data_even_late_d),
      .dout(rom_data_even_late_l2)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(0)) rom_data_odd_late_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu4_stage_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[rom_data_odd_late_offset:rom_data_odd_late_offset + 32 - 1]),
      .scout(sov[rom_data_odd_late_offset:rom_data_odd_late_offset + 32 - 1]),
      .din(rom_data_odd_late_d),
      .dout(rom_data_odd_late_l2)
   );

   // Staging latches
   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) iu4_valid_latch(
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
      .scin(siv[iu4_valid_offset:iu4_valid_offset + 2 - 1]),
      .scout(sov[iu4_valid_offset:iu4_valid_offset + 2 - 1]),
      .din(iu4_valid_d),
      .dout(iu4_valid_l2)
   );

   tri_rlmreg_p #(.WIDTH(uc_ifar), .INIT(0), .NEEDS_SRESET(0)) iu4_ifar_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu4_stage_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu4_ifar_offset:iu4_ifar_offset + uc_ifar - 1]),
      .scout(sov[iu4_ifar_offset:iu4_ifar_offset + uc_ifar - 1]),
      .din(iu4_ifar_d),
      .dout(iu4_ifar_l2)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(0)) iu4_ext0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu4_stage_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu4_ext0_offset:iu4_ext0_offset + 4 - 1]),
      .scout(sov[iu4_ext0_offset:iu4_ext0_offset + 4 - 1]),
      .din(iu4_ext0_d),
      .dout(iu4_ext0_l2)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(0)) iu4_ext1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu4_stage_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu4_ext1_offset:iu4_ext1_offset + 4 - 1]),
      .scout(sov[iu4_ext1_offset:iu4_ext1_offset + 4 - 1]),
      .din(iu4_ext1_d),
      .dout(iu4_ext1_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(0)) iu4_done_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu4_stage_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu4_done_offset]),
      .scout(sov[iu4_done_offset]),
      .din(iu4_done_d),
      .dout(iu4_done_l2)
   );

   // Overflow Staging latches
   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) iu4_ov_valid_latch(
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
      .scin(siv[iu4_ov_valid_offset:iu4_ov_valid_offset + 2 - 1]),
      .scout(sov[iu4_ov_valid_offset:iu4_ov_valid_offset + 2 - 1]),
      .din(iu4_ov_valid_d),
      .dout(iu4_ov_valid_l2)
   );

   tri_rlmreg_p #(.WIDTH(uc_ifar), .INIT(0), .NEEDS_SRESET(0)) iu4_ov_ifar_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu4_ov_stage_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu4_ov_ifar_offset:iu4_ov_ifar_offset + uc_ifar - 1]),
      .scout(sov[iu4_ov_ifar_offset:iu4_ov_ifar_offset + uc_ifar - 1]),
      .din(iu4_ov_ifar_d),
      .dout(iu4_ov_ifar_l2)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(0)) iu4_ov_instr0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu4_ov_stage_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu4_ov_instr0_offset:iu4_ov_instr0_offset + 32 - 1]),
      .scout(sov[iu4_ov_instr0_offset:iu4_ov_instr0_offset + 32 - 1]),
      .din(iu4_ov_instr0_d),
      .dout(iu4_ov_instr0_l2)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(0)) iu4_ov_instr1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu4_ov_stage_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu4_ov_instr1_offset:iu4_ov_instr1_offset + 32 - 1]),
      .scout(sov[iu4_ov_instr1_offset:iu4_ov_instr1_offset + 32 - 1]),
      .din(iu4_ov_instr1_d),
      .dout(iu4_ov_instr1_l2)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(0)) u4_ov_ext0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu4_ov_stage_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu4_ov_ext0_offset:iu4_ov_ext0_offset + 4 - 1]),
      .scout(sov[iu4_ov_ext0_offset:iu4_ov_ext0_offset + 4 - 1]),
      .din(iu4_ov_ext0_d),
      .dout(iu4_ov_ext0_l2)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(0)) iu4_ov_ext1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu4_ov_stage_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu4_ov_ext1_offset:iu4_ov_ext1_offset + 4 - 1]),
      .scout(sov[iu4_ov_ext1_offset:iu4_ov_ext1_offset + 4 - 1]),
      .din(iu4_ov_ext1_d),
      .dout(iu4_ov_ext1_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(0)) iu4_ov_done_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu4_ov_stage_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu4_ov_done_offset]),
      .scout(sov[iu4_ov_done_offset]),
      .din(iu4_ov_done_d),
      .dout(iu4_ov_done_l2)
   );

   //---------------------------------------------------------------------
   // pervasive thold/sg latches
   //---------------------------------------------------------------------

   tri_plat #(.WIDTH(2)) perv_2to1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({pc_iu_func_sl_thold_2, pc_iu_sg_2}),
      .q(  {pc_iu_func_sl_thold_1, pc_iu_sg_1})
   );

   tri_plat #(.WIDTH(2)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({pc_iu_func_sl_thold_1, pc_iu_sg_1}),
      .q(  {pc_iu_func_sl_thold_0, pc_iu_sg_0})
   );

   tri_lcbor  perv_lcbor(
      .clkoff_b(clkoff_b),
      .thold(pc_iu_func_sl_thold_0),
      .sg(pc_iu_sg_0),
      .act_dis(act_dis),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b)
   );

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv[0:scan_right + 4] = {sov[1:scan_right + 4], scan_in};
   assign scan_out = sov[0];

endmodule
