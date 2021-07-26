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

`timescale 1 fs / 1 fs

//*****************************************************************************
//  Description:  Tri-Lam Array Wrapper
//
//*****************************************************************************

`include "tri_a2o.vh"

module tri_64x72_1r1w(
   vdd,
   vcs,
   gnd,
   nclk,
   sg_0,
   abst_sl_thold_0,
   ary_nsl_thold_0,
   time_sl_thold_0,
   repr_sl_thold_0,
   rd0_act,
   rd0_adr,
   do0,
   wr_act,
   wr_adr,
   di,
   abst_scan_in,
   abst_scan_out,
   time_scan_in,
   time_scan_out,
   repr_scan_in,
   repr_scan_out,
   scan_dis_dc_b,
   scan_diag_dc,
   ccflush_dc,
   clkoff_dc_b,
   d_mode_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   delay_lclkr_dc,
   lcb_bolt_sl_thold_0,
   pc_bo_enable_2,
   pc_bo_reset,
   pc_bo_unload,
   pc_bo_repair,
   pc_bo_shdata,
   pc_bo_select,
   bo_pc_failout,
   bo_pc_diagloop,
   tri_lcb_mpw1_dc_b,
   tri_lcb_mpw2_dc_b,
   tri_lcb_delay_lclkr_dc,
   tri_lcb_clkoff_dc_b,
   tri_lcb_act_dis_dc,
   abist_di,
   abist_bw_odd,
   abist_bw_even,
   abist_wr_adr,
   wr_abst_act,
   abist_rd0_adr,
   rd0_abst_act,
   tc_lbist_ary_wrt_thru_dc,
   abist_ena_1,
   abist_g8t_rd0_comp_ena,
   abist_raw_dc_b,
   obs0_abist_cmp
);

   // Power
   (* analysis_not_referenced="true" *)
   inout                               vdd;
   (* analysis_not_referenced="true" *)
   inout                               vcs;
   (* analysis_not_referenced="true" *)
   inout                               gnd;

   // Clock Pervasive
   input [0:`NCLK_WIDTH-1]             nclk;
   input                               sg_0;
   input                               abst_sl_thold_0;
   input                               ary_nsl_thold_0;
   input                               time_sl_thold_0;
   input                               repr_sl_thold_0;

   // Reads
   input                               rd0_act;
   input [0:5]                         rd0_adr;
   output [64-`GPR_WIDTH:72-(64/`GPR_WIDTH)] do0;

   // Writes
   input                               wr_act;
   input [0:5]                         wr_adr;
   input [64-`GPR_WIDTH:72-(64/`GPR_WIDTH)]  di;

   // Scan
   input                               abst_scan_in;
   output                              abst_scan_out;
   input                               time_scan_in;
   output                              time_scan_out;
   input                               repr_scan_in;
   output                              repr_scan_out;

   // Misc Pervasive
   input                               scan_dis_dc_b;
   input                               scan_diag_dc;
   input                               ccflush_dc;
   input                               clkoff_dc_b;
   input                               d_mode_dc;
   input [0:4]                         mpw1_dc_b;
   input                               mpw2_dc_b;
   input [0:4]                         delay_lclkr_dc;

   // BOLT-ON
   input                               lcb_bolt_sl_thold_0;
   input                               pc_bo_enable_2;		// general bolt-on enable
   input                               pc_bo_reset;		// reset
   input                               pc_bo_unload;		// unload sticky bits
   input                               pc_bo_repair;		// execute sticky bit decode
   input                               pc_bo_shdata;		// shift data for timing write and diag loop
   input                               pc_bo_select;		// select for mask and hier writes
   output                              bo_pc_failout;		// fail/no-fix reg
   output                              bo_pc_diagloop;
   input                               tri_lcb_mpw1_dc_b;
   input                               tri_lcb_mpw2_dc_b;
   input                               tri_lcb_delay_lclkr_dc;
   input                               tri_lcb_clkoff_dc_b;
   input                               tri_lcb_act_dis_dc;

   // ABIST
   input [0:3]                         abist_di;
   input                               abist_bw_odd;
   input                               abist_bw_even;
   input [0:5]                         abist_wr_adr;
   input                               wr_abst_act;
   input [0:5]                         abist_rd0_adr;
   input                               rd0_abst_act;
   input                               tc_lbist_ary_wrt_thru_dc;
   input                               abist_ena_1;
   input                               abist_g8t_rd0_comp_ena;
   input                               abist_raw_dc_b;
   input [0:3]                         obs0_abist_cmp;

   // Configuration Statement for NCsim
   //for all:RAMB16_S36_S36 use entity unisim.RAMB16_S36_S36;

   wire                                clk;
   wire                                clk2x;
   reg [0:8]                           addra;
   reg [0:8]                           addrb;
   reg                                 wea;
   reg                                 web;
   wire [0:71]                         bdo;
   wire [0:71]                         bdi;
   wire                                sreset;
   wire [0:71]                         tidn;
   // Latches
   reg                                 reset_q;
   reg                                 gate_fq;
   wire                                gate_d;
   wire [64-`GPR_WIDTH:72-(64/`GPR_WIDTH)]   bdo_d;
   reg [64-`GPR_WIDTH:72-(64/`GPR_WIDTH)]    bdo_fq;

   wire                                toggle_d;
   reg                                 toggle_q;
   wire                                toggle2x_d;
   reg                                 toggle2x_q;

   (* analysis_not_referenced="true" *)
   wire                                unused;

   generate
   begin
     assign tidn = 72'b0;
     assign clk = nclk[0];
     assign clk2x = nclk[2];
     assign sreset = nclk[1];

     always @(posedge clk)
     begin: rlatch
       reset_q <= #10 sreset;
     end

     //
     //  NEW clk2x gate logic start
     //

     always @(posedge clk)
     begin: tlatch
       if (reset_q == 1'b1)
         toggle_q <= 1'b1;
       else
         toggle_q <= toggle_d;
     end

     always @(posedge clk2x)
     begin: flatch
       toggle2x_q <= toggle2x_d;
       gate_fq <= gate_d;
       bdo_fq <= bdo_d;
     end

     assign toggle_d = (~toggle_q);
     assign toggle2x_d = toggle_q;

     // should force gate_fq to be on during odd 2x clock (second half of 1x clock).
     //gate_d <= toggle_q xor toggle2x_q;
     // if you want the first half do the following
     assign gate_d = (~(toggle_q ^ toggle2x_q));

     //
     //  NEW clk2x gate logic end
     //

     if (`GPR_WIDTH == 32)
     begin
       assign bdi = {tidn[0:31], di[32:63], di[64:70], tidn[71]};
     end
     if (`GPR_WIDTH == 64)
     begin
       assign bdi = di[0:71];
     end

     assign bdo_d = bdo[64 - `GPR_WIDTH:72 - (64/`GPR_WIDTH)];
     assign do0 = bdo_fq;

     always @ ( * )
     begin
       wea <= #10 (wr_act & gate_fq);
       web <= #10 (wr_act & gate_fq);

       addra <= #10 ((gate_fq == 1'b1) ? {2'b00, wr_adr, 1'b0} :
                                         {2'b00, rd0_adr, 1'b0});

       addrb <= #10 ((gate_fq == 1'b1) ? {2'b00, wr_adr, 1'b1} :
                                         {2'b00, rd0_adr, 1'b1});
     end

     RAMB16_S36_S36
       #(.SIM_COLLISION_CHECK("NONE"))      // all, none, warning_only, generate_x_only
     bram0a(
         .CLKA(clk2x),
         .CLKB(clk2x),
         .SSRA(sreset),
         .SSRB(sreset),
         .ADDRA(addra),
         .ADDRB(addrb),
         .DIA(bdi[00:31]),
         .DIB(bdi[32:63]),
         .DIPA(bdi[64:67]),
         .DIPB(bdi[68:71]),
         .DOA(bdo[00:31]),
         .DOB(bdo[32:63]),
         .DOPA(bdo[64:67]),
         .DOPB(bdo[68:71]),
         .ENA(1'b1),
         .ENB(1'b1),
         .WEA(wea),
         .WEB(web)
      );

     assign abst_scan_out = abst_scan_in;
     assign time_scan_out = time_scan_in;
     assign repr_scan_out = repr_scan_in;

     assign bo_pc_failout = 1'b0;
     assign bo_pc_diagloop = 1'b0;

     assign unused = | ({nclk[3:`NCLK_WIDTH-1], sg_0, abst_sl_thold_0, ary_nsl_thold_0, time_sl_thold_0, repr_sl_thold_0, scan_dis_dc_b, scan_diag_dc, ccflush_dc, clkoff_dc_b, d_mode_dc, mpw1_dc_b, mpw2_dc_b, delay_lclkr_dc, abist_di, abist_bw_odd, abist_bw_even, abist_wr_adr, abist_rd0_adr, wr_abst_act, rd0_abst_act, tc_lbist_ary_wrt_thru_dc, abist_ena_1, abist_g8t_rd0_comp_ena, abist_raw_dc_b, obs0_abist_cmp, rd0_act, tidn, lcb_bolt_sl_thold_0, pc_bo_enable_2, pc_bo_reset, pc_bo_unload, pc_bo_repair, pc_bo_shdata, pc_bo_select, tri_lcb_mpw1_dc_b, tri_lcb_mpw2_dc_b, tri_lcb_delay_lclkr_dc, tri_lcb_clkoff_dc_b, tri_lcb_act_dis_dc});
  end
  endgenerate
endmodule
