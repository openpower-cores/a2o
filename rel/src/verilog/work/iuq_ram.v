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

// *********************************************************************
//
// This is the ENTITY for iuq_ram
//
// *********************************************************************

module iuq_ram(
   pc_iu_ram_instr,
   pc_iu_ram_instr_ext,
   pc_iu_ram_issue,
   pc_iu_ram_active,
   iu_pc_ram_done,
   cp_flush,
   ib_rm_rdy,
   rm_ib_iu3_val,
   rm_ib_iu3_instr,
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
   scan_out
);
`include "tri_a2o.vh"
//   parameter            `EXPAND_TYPE = 2;
//   parameter            `THREADS = 2;		// 0 = ibm umbra, 1 = xilinx, 2 = ibm mpg
   input [0:31]         pc_iu_ram_instr;
   input [0:3]          pc_iu_ram_instr_ext;
   input                pc_iu_ram_issue;
   input [0:`THREADS-1]  pc_iu_ram_active;

   input                iu_pc_ram_done;
   input [0:`THREADS-1]  cp_flush;

   input [0:`THREADS-1]  ib_rm_rdy;

   output [0:`THREADS-1] rm_ib_iu3_val;
   output [0:35]        rm_ib_iu3_instr;

   //pervasive
   inout                vdd;
   inout                gnd;
   (* pin_data="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]  nclk;
   input                pc_iu_sg_2;
   input                pc_iu_func_sl_thold_2;
   input                clkoff_b;
   input                act_dis;
   input                tc_ac_ccflush_dc;
   input                d_mode;
   input                delay_lclkr;
   input                mpw1_b;
   input                mpw2_b;
   input                scan_in;

   output               scan_out;

   //--------------------------
   // components
   //--------------------------

   //--------------------------
   // constants
   //--------------------------

   //scan chain
      parameter            cp_flush_offset = 0;
      parameter            ram_val_offset = cp_flush_offset + `THREADS;
      parameter            ram_act_offset = ram_val_offset + `THREADS;
      parameter            ram_instr_offset = ram_act_offset + `THREADS;
      parameter            ram_done_offset = ram_instr_offset + 36;
      parameter            scan_right = ram_done_offset + 1 - 1;

      //--------------------------
      // signals
      //--------------------------

      wire                 tiup;

      wire                 ram_valid;

      wire [0:`THREADS-1]   ram_val_d;
      wire [0:`THREADS-1]   ram_val_q;
      wire [0:`THREADS-1]   ram_act_d;
      wire [0:`THREADS-1]   ram_act_q;
      wire [0:35]          ram_instr_d;
      wire [0:35]          ram_instr_q;
      wire                 ram_done_d;
      wire                 ram_done_q;

      wire [0:`THREADS-1]   cp_flush_d;
      wire [0:`THREADS-1]   cp_flush_q;

      wire                 pc_iu_func_sl_thold_1;
      wire                 pc_iu_func_sl_thold_0;
      wire                 pc_iu_func_sl_thold_0_b;
      wire                 pc_iu_sg_1;
      wire                 pc_iu_sg_0;
      wire                 force_t;

      wire [0:scan_right]  siv;
      wire [0:scan_right]  sov;

      assign tiup = 1'b1;
      //assign tidn = 1'b0;

      //-----------------------------------------------
      // logic
      //-----------------------------------------------
      assign cp_flush_d = cp_flush;
      assign ram_done_d = iu_pc_ram_done;

      generate
         begin : xhdl1
            genvar               i;
            for (i = 0; i <= `THREADS - 1; i = i + 1)
            begin : issue_gating
               assign ram_val_d[i] = (pc_iu_ram_active[i] & pc_iu_ram_issue) | (ram_val_q[i] & (~ib_rm_rdy[i])) | (cp_flush_q[i] & ram_act_d[i]);
               assign ram_act_d[i] = (ram_done_q == 1'b1) ? 1'b0 :
                                     (ram_val_q[i] == 1'b1) ? 1'b1 :
                                     ram_act_q[i];
            end
         end
         endgenerate

         assign ram_valid = pc_iu_ram_issue;
         assign ram_instr_d = {pc_iu_ram_instr, pc_iu_ram_instr_ext};

         //-----------------------------------------------
         // outputs
         //-----------------------------------------------

         assign rm_ib_iu3_val = ram_val_q;
         assign rm_ib_iu3_instr = ram_instr_q;

         //-----------------------------------------------
         // latches
         //-----------------------------------------------


         tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) cp_flush_reg(
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
            .scin(siv[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
            .scout(sov[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
            .din(cp_flush_d),
            .dout(cp_flush_q)
         );


         tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ram_val_reg(
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
            .scin(siv[ram_val_offset:ram_val_offset + `THREADS - 1]),
            .scout(sov[ram_val_offset:ram_val_offset + `THREADS - 1]),
            .din(ram_val_d),
            .dout(ram_val_q)
         );


         tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ram_act_reg(
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
            .scin(siv[ram_act_offset:ram_act_offset + `THREADS - 1]),
            .scout(sov[ram_act_offset:ram_act_offset + `THREADS - 1]),
            .din(ram_act_d),
            .dout(ram_act_q)
         );


         tri_rlmreg_p #(.WIDTH(36), .INIT(0)) ram_instr_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ram_valid),
            .thold_b(pc_iu_func_sl_thold_0_b),
            .sg(pc_iu_sg_0),
            .force_t(force_t),
            .delay_lclkr(delay_lclkr),
            .mpw1_b(mpw1_b),
            .mpw2_b(mpw2_b),
            .d_mode(d_mode),
            .scin(siv[ram_instr_offset:ram_instr_offset + 35]),
            .scout(sov[ram_instr_offset:ram_instr_offset + 35]),
            .din(ram_instr_d[0:35]),
            .dout(ram_instr_q[0:35])
         );


         tri_rlmlatch_p #(.INIT(0)) ram_done_reg(
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
            .scin(siv[ram_done_offset]),
            .scout(sov[ram_done_offset]),
            .din(ram_done_d),
            .dout(ram_done_q)
         );

         //-----------------------------------------------
         // pervasive
         //-----------------------------------------------


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

         //-----------------------------------------------
         // scan
         //-----------------------------------------------

         assign siv[0:scan_right] = {scan_in, sov[0:scan_right - 1]};
         assign scan_out = sov[scan_right];


endmodule
