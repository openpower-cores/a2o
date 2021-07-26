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
//* TITLE: Microcode Completion Buffer
//*
//* NAME: iuq_uc_cplbuffer.v
//*
//*********************************************************************

`include "tri_a2o.vh"


module iuq_uc_cplbuffer(
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
   cp_uc_credit_free,
   flush,
   flush_into_uc,
   new_command,
   flush_next,
   valid_l2,
   flush_current,
   buff_instr_in,
   cplbuffer_xer_act,
   wait_for_xer_l2,
   xu_iu_ucode_xer_l2,
   cplbuffer_full,
   oldest_instr,
   oldest_xer
);


   inout                       vdd;

   inout                       gnd;

    (* pin_data="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]     nclk;
   input                       pc_iu_func_sl_thold_0_b;
   input                       pc_iu_sg_0;
   input                       force_t;
   input                       d_mode;
   input                       delay_lclkr;
   input                       mpw1_b;
   input                       mpw2_b;

    (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                       scan_in;

    (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                      scan_out;

   input                       cp_uc_credit_free;
   input                       flush;
   input                       flush_into_uc;
   input                       new_command;
   input                       flush_next;
   input                       valid_l2;
   input                       flush_current;
   input [0:31]                buff_instr_in;
   input                       cplbuffer_xer_act;
   input                       wait_for_xer_l2;
   input [57:63]               xu_iu_ucode_xer_l2;

   output                      cplbuffer_full;
   output reg [0:31]           oldest_instr;
   output reg [57:63]          oldest_xer;

   // iuq_uc_cplbuffer

   localparam [0:31]           value_1 = 32'h00000001;
   localparam [0:31]           value_2 = 32'h00000002;

   parameter                   buffer_width = 32;
   parameter                   buffer_depth = 8;		// NOTE: If this changes, change cplbuffer_full logic
   parameter                   buffer_depth_log = 3;
   parameter                   xer_width = 7;

   parameter                   buffer_count_offset = 0;
   parameter                   buffer_offset = buffer_count_offset + buffer_depth_log + 1;
   parameter                   xer_offset = buffer_offset + buffer_depth * buffer_width;
   parameter                   read_ptr_offset = xer_offset + buffer_depth * xer_width;
   parameter                   write_ptr_offset = read_ptr_offset + buffer_depth_log;
   parameter                   new_command_offset = write_ptr_offset + buffer_depth_log;
   parameter                   scan_right = new_command_offset + 1 - 1;


   wire [0:buffer_depth_log]   buffer_count_d;
   wire [0:buffer_depth_log]   buffer_count_l2;
   reg  [0:buffer_width-1]     buffer_d[0:buffer_depth-1];
   wire [0:buffer_width-1]     buffer_l2[0:buffer_depth-1];
   reg  [57:63]                xer_d[0:buffer_depth-1];
   wire [57:63]                xer_l2[0:buffer_depth-1];
   wire [0:buffer_depth_log-1] read_ptr_d;
   wire [0:buffer_depth_log-1] read_ptr_l2;
   wire [0:buffer_depth_log-1] write_ptr_d;
   wire [0:buffer_depth_log-1] write_ptr_l2;
   wire                        new_command_d;
   wire                        new_command_l2;

   wire [0:buffer_depth_log-1] xer_write_ptr;
   wire [0:1]                  buffer_act;
   wire                        ptr_act;
   wire                        cplbuffer_full_int;

   wire                        tiup;

   // scan
   wire [0:scan_right]         siv;
   wire [0:scan_right]         sov;

   assign tiup = 1'b1;
   assign new_command_d = new_command & (~(flush_next));

   assign buffer_count_d = (flush_into_uc == 1'b1) ? value_1[31-buffer_depth_log:31] :
                           (flush == 1'b1) ? {(buffer_depth_log+1){1'b0}} :		//cp_flush
                           (new_command_l2 == 1'b0 & (flush_current & valid_l2) == 1'b1 & cp_uc_credit_free == 1'b1) ? buffer_count_l2 - value_2[31-buffer_depth_log:31] :
                           (new_command_l2 == 1'b0 & (flush_current & valid_l2) == 1'b1 & cp_uc_credit_free == 1'b0) ? buffer_count_l2 - value_1[31-buffer_depth_log:31] :
                           (new_command_l2 == 1'b0 & (flush_current & valid_l2) == 1'b0 & cp_uc_credit_free == 1'b1) ? buffer_count_l2 - value_1[31-buffer_depth_log:31] :
                           (new_command_l2 == 1'b1 & (flush_current & valid_l2) == 1'b1 & cp_uc_credit_free == 1'b1) ? buffer_count_l2 - value_1[31-buffer_depth_log:31] :
                           (new_command_l2 == 1'b1 & (flush_current & valid_l2) == 1'b0 & cp_uc_credit_free == 1'b0) ? buffer_count_l2 + value_1[31-buffer_depth_log:31] :
                           buffer_count_l2;

   assign read_ptr_d = (cp_uc_credit_free == 1'b1) ? read_ptr_l2 + value_1[32-buffer_depth_log:31] :
                       read_ptr_l2;

   assign write_ptr_d = (flush_into_uc == 1'b1) ? read_ptr_l2 + value_1[32-buffer_depth_log:31] :
                        (flush == 1'b1) ? read_ptr_l2 :
                        (new_command_l2 == 1'b1 & ((flush_current & valid_l2) == 1'b0)) ? write_ptr_l2 + value_1[32-buffer_depth_log:31] :
                        (new_command_l2 == 1'b0 & ((flush_current & valid_l2) == 1'b1)) ? write_ptr_l2 - value_1[32-buffer_depth_log:31] :
                        write_ptr_l2;

   generate
   begin : gen_buff
     genvar  i;
     for (i = 0; i < buffer_depth; i = i + 1)
     begin : buff_loop
       wire [0:buffer_depth_log-1] index=i;
       always @ (write_ptr_l2 or index or buff_instr_in or buffer_l2[i] or
                 xer_write_ptr or xu_iu_ucode_xer_l2 or xer_l2[i])
       begin
         buffer_d[i] <= (write_ptr_l2 == index) ? buff_instr_in :
                                                  buffer_l2[i];
         xer_d[i] <= (xer_write_ptr == index) ? xu_iu_ucode_xer_l2 :
                                                xer_l2[i];
       end
     end
   end
   endgenerate

   always @ (*)
   begin : read_mux

      (* analysis_not_referenced="true" *)

     integer  i;
     oldest_instr <= 32'b0;
     oldest_xer   <= 7'b0;
     for (i = 0; i < buffer_depth; i = i + 1)
     begin : read_mux_loop
       if (read_ptr_l2 == i[buffer_depth_log-1:0])
       begin
         oldest_instr <= buffer_l2[i];
         oldest_xer   <= xer_l2[i];
       end
     end
   end

   assign xer_write_ptr = (wait_for_xer_l2 == 1'b1) ? write_ptr_l2 - value_1[32-buffer_depth_log:31] : 	// when xer comes after new_command
                                                      write_ptr_l2;                                     // when xer valid with new_command

   assign cplbuffer_full_int = (buffer_count_l2[1:2] == 2'b11);
   assign cplbuffer_full = cplbuffer_full_int;

   assign buffer_act[0] = new_command_l2 & (~write_ptr_l2[0]);
   assign buffer_act[1] = new_command_l2 &   write_ptr_l2[0];

   assign ptr_act = flush_into_uc | flush | new_command_l2 | cp_uc_credit_free | flush_current;

   //---------------------------------------------------------------------
   // Latches
   //---------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(buffer_depth_log+1), .INIT(0)) buffer_count_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ptr_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[buffer_count_offset:buffer_count_offset + (buffer_depth_log+1) - 1]),
      .scout(sov[buffer_count_offset:buffer_count_offset + (buffer_depth_log+1) - 1]),
      .din(buffer_count_d),
      .dout(buffer_count_l2)
   );

   generate
   begin
     genvar  i;
     for (i = 0; i < buffer_depth; i = i + 1)
     begin : gen_b
       tri_rlmreg_p #(.WIDTH(buffer_width), .INIT(0)) buffer_latch(
          .vd(vdd),
          .gd(gnd),
          .nclk(nclk),
          .act(buffer_act[i/(buffer_depth/2)]),		// only clock half of buffers at a time
          .thold_b(pc_iu_func_sl_thold_0_b),
          .sg(pc_iu_sg_0),
          .force_t(force_t),
          .delay_lclkr(delay_lclkr),
          .mpw1_b(mpw1_b),
          .mpw2_b(mpw2_b),
          .d_mode(d_mode),
          .scin(siv[buffer_offset + i * buffer_width:buffer_offset + (i + 1) * buffer_width - 1]),
          .scout(sov[buffer_offset + i * buffer_width:buffer_offset + (i + 1) * buffer_width - 1]),
          .din(buffer_d[i]),
          .dout(buffer_l2[i])
       );

       tri_rlmreg_p #(.WIDTH(xer_width), .INIT(0)) xer_latch(
          .vd(vdd),
          .gd(gnd),
          .nclk(nclk),
          .act(cplbuffer_xer_act),
          .thold_b(pc_iu_func_sl_thold_0_b),
          .sg(pc_iu_sg_0),
          .force_t(force_t),
          .delay_lclkr(delay_lclkr),
          .mpw1_b(mpw1_b),
          .mpw2_b(mpw2_b),
          .d_mode(d_mode),
          .scin(siv[xer_offset + i * xer_width:xer_offset + (i + 1) * xer_width - 1]),
          .scout(sov[xer_offset + i * xer_width:xer_offset + (i + 1) * xer_width - 1]),
          .din(xer_d[i]),
          .dout(xer_l2[i])
       );
     end
   end
   endgenerate

   tri_rlmreg_p #(.WIDTH(buffer_depth_log), .INIT(0)) read_ptr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ptr_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[read_ptr_offset:read_ptr_offset + buffer_depth_log - 1]),
      .scout(sov[read_ptr_offset:read_ptr_offset + buffer_depth_log - 1]),
      .din(read_ptr_d),
      .dout(read_ptr_l2)
   );

   tri_rlmreg_p #(.WIDTH(buffer_depth_log), .INIT(0)) write_ptr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ptr_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[write_ptr_offset:write_ptr_offset + buffer_depth_log - 1]),
      .scout(sov[write_ptr_offset:write_ptr_offset + buffer_depth_log - 1]),
      .din(write_ptr_d),
      .dout(write_ptr_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) new_command_latch(
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
      .scin(siv[new_command_offset]),
      .scout(sov[new_command_offset]),
      .din(new_command_d),
      .dout(new_command_l2)
   );

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
   assign scan_out = sov[0];

endmodule
