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

//*****************************************************************************
//  Description:  Tri Array Wrapper
//
//*****************************************************************************

`include "tri_a2o.vh"

module tri_128x16_1r1w_1(
   vdd,
   vcs,
   gnd,
   nclk,
   rd_act,
   wr_act,
   lcb_d_mode_dc,
   lcb_clkoff_dc_b,
   lcb_mpw1_dc_b,
   lcb_mpw2_dc_b,
   lcb_delay_lclkr_dc,
   ccflush_dc,
   scan_dis_dc_b,
   scan_diag_dc,
   func_scan_in,
   func_scan_out,
   lcb_sg_0,
   lcb_sl_thold_0_b,
   lcb_time_sl_thold_0,
   lcb_abst_sl_thold_0,
   lcb_ary_nsl_thold_0,
   lcb_repr_sl_thold_0,
   time_scan_in,
   time_scan_out,
   abst_scan_in,
   abst_scan_out,
   repr_scan_in,
   repr_scan_out,
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
   obs0_abist_cmp,
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
   bw,
   wr_adr,
   rd_adr,
   di,
   do
);
   parameter                                      addressable_ports = 128;	// number of addressable register in this array
   parameter                                      addressbus_width = 7;		// width of the bus to address all ports (2^addressbus_width >= addressable_ports)
   parameter                                      port_bitwidth = 16;		// bitwidth of ports
   parameter                                      ways = 1;                     // number of ways

   // POWER PINS
   inout                                          vdd;
   inout                                          vcs;
   inout                                          gnd;

   input [0:`NCLK_WIDTH-1]                        nclk;

   input                                          rd_act;
   input                                          wr_act;

   // DC TEST PINS
   input                                          lcb_d_mode_dc;
   input                                          lcb_clkoff_dc_b;
   input [0:4]                                    lcb_mpw1_dc_b;
   input                                          lcb_mpw2_dc_b;
   input [0:4]                                    lcb_delay_lclkr_dc;

   input                                          ccflush_dc;
   input                                          scan_dis_dc_b;
   input                                          scan_diag_dc;
   input                                          func_scan_in;
   output                                         func_scan_out;

   input                                          lcb_sg_0;
   input                                          lcb_sl_thold_0_b;
   input                                          lcb_time_sl_thold_0;
   input                                          lcb_abst_sl_thold_0;
   input                                          lcb_ary_nsl_thold_0;
   input                                          lcb_repr_sl_thold_0;
   input                                          time_scan_in;
   output                                         time_scan_out;
   input                                          abst_scan_in;
   output                                         abst_scan_out;
   input                                          repr_scan_in;
   output                                         repr_scan_out;

   input [0:3]                                    abist_di;
   input                                          abist_bw_odd;
   input                                          abist_bw_even;
   input [0:6]                                    abist_wr_adr;
   input                                          wr_abst_act;
   input [0:6]                                    abist_rd0_adr;
   input                                          rd0_abst_act;
   input                                          tc_lbist_ary_wrt_thru_dc;
   input                                          abist_ena_1;
   input                                          abist_g8t_rd0_comp_ena;
   input                                          abist_raw_dc_b;
   input [0:3]                                    obs0_abist_cmp;

   // BOLT-ON
   input                                          lcb_bolt_sl_thold_0;
   input                                          pc_bo_enable_2;	// general bolt-on enable
   input                                          pc_bo_reset;		// reset
   input                                          pc_bo_unload;		// unload sticky bits
   input                                          pc_bo_repair;		// execute sticky bit decode
   input                                          pc_bo_shdata;		// shift data for timing write and diag loop
   input                                          pc_bo_select;		// select for mask and hier writes
   output                                         bo_pc_failout;	// fail/no-fix reg
   output                                         bo_pc_diagloop;
   input                                          tri_lcb_mpw1_dc_b;
   input                                          tri_lcb_mpw2_dc_b;
   input                                          tri_lcb_delay_lclkr_dc;
   input                                          tri_lcb_clkoff_dc_b;
   input                                          tri_lcb_act_dis_dc;

   input [0:15]                                   bw;
   input [0:6]                                    wr_adr;
   input [0:6]                                    rd_adr;
   input [0:15]                                   di;

   output [0:15]                                  do;

   // tri_128x16_1r1w_1

   // Configuration Statement for NCsim
   //for all:ramb16_s36_s36 use entity unisim.RAMB16_S36_S36;

   wire                                           clk;
   wire                                           clk2x;
   wire [0:8]                                     b0addra;
   wire [0:8]                                     b0addrb;
   wire                                           wea;
   wire                                           web;
   wire                                           wren_a;
   // Latches
   reg                                            reset_q;
   reg                                            gate_fq;
   wire                                           gate_d;
   wire [0:35]                                    r_data_out_1_d;
   reg [0:35]                                     r_data_out_1_fq;
   wire [0:35]                                    w_data_in_0;

   wire [0:35]                                    r_data_out_0_bram;
   wire [0:35]                                    r_data_out_1_bram;

   wire                                           toggle_d;
   reg                                            toggle_q;
   wire                                           toggle2x_d;
   reg                                            toggle2x_q;

   (* analysis_not_referenced="true" *)
   wire                                           unused;

     assign clk = nclk[0];
     assign clk2x = nclk[2];


     always @(posedge clk)
     begin: rlatch
       reset_q <= nclk[1];
     end

     //
     //  NEW clk2x gate logic start
     //

     always @(posedge nclk[0])
     begin: tlatch
       if (reset_q == 1'b1)
         toggle_q <= 1'b1;
       else
         toggle_q <= toggle_d;
     end


     always @(posedge nclk[2])
     begin: flatch
       toggle2x_q <= toggle2x_d;
       gate_fq <= gate_d;
       r_data_out_1_fq <= r_data_out_1_d;
     end

     assign toggle_d = (~toggle_q);
     assign toggle2x_d = toggle_q;

     // should force gate_fq to be on during odd 2x clock (second half of 1x clock).
     //gate_d <= toggle_q xor toggle2x_q;
     // if you want the first half do the following
     assign gate_d = (~(toggle_q ^ toggle2x_q));

     assign b0addra[2:8] = wr_adr;
     assign b0addrb[2:8] = rd_adr;

     // Unused Address Bits
     assign b0addra[0:1] = 2'b00;
     assign b0addrb[0:1] = 2'b00;

     // port a is a read-modify-write port
     assign wren_a = ((bw != 16'b0000000000000000 & wr_act == 1'b1)) ? 1'b1 :
                     1'b0;
     assign wea = wren_a & (~(gate_fq));		// write in 2nd half of nclk
     assign web = 1'b0;
     assign w_data_in_0[0] = (bw[0] == 1'b1) ? di[0] :
                             r_data_out_0_bram[0];
     assign w_data_in_0[1] = (bw[1] == 1'b1) ? di[1] :
                             r_data_out_0_bram[1];
     assign w_data_in_0[2] = (bw[2] == 1'b1) ? di[2] :
                             r_data_out_0_bram[2];
     assign w_data_in_0[3] = (bw[3] == 1'b1) ? di[3] :
                             r_data_out_0_bram[3];
     assign w_data_in_0[4] = (bw[4] == 1'b1) ? di[4] :
                             r_data_out_0_bram[4];
     assign w_data_in_0[5] = (bw[5] == 1'b1) ? di[5] :
                             r_data_out_0_bram[5];
     assign w_data_in_0[6] = (bw[6] == 1'b1) ? di[6] :
                             r_data_out_0_bram[6];
     assign w_data_in_0[7] = (bw[7] == 1'b1) ? di[7] :
                             r_data_out_0_bram[7];
     assign w_data_in_0[8] = (bw[8] == 1'b1) ? di[8] :
                             r_data_out_0_bram[8];
     assign w_data_in_0[9] = (bw[9] == 1'b1) ? di[9] :
                             r_data_out_0_bram[9];
     assign w_data_in_0[10] = (bw[10] == 1'b1) ? di[10] :
                             r_data_out_0_bram[10];
     assign w_data_in_0[11] = (bw[11] == 1'b1) ? di[11] :
                             r_data_out_0_bram[11];
     assign w_data_in_0[12] = (bw[12] == 1'b1) ? di[12] :
                             r_data_out_0_bram[12];
     assign w_data_in_0[13] = (bw[13] == 1'b1) ? di[13] :
                             r_data_out_0_bram[13];
     assign w_data_in_0[14] = (bw[14] == 1'b1) ? di[14] :
                             r_data_out_0_bram[14];
     assign w_data_in_0[15] = (bw[15] == 1'b1) ? di[15] :
                             r_data_out_0_bram[15];
     assign w_data_in_0[16:35] = {20{1'b0}};

     assign r_data_out_1_d = r_data_out_1_bram;



     RAMB16_S36_S36
                #(.SIM_COLLISION_CHECK("NONE"))            // all, none, warning_only, generate_x_only
     bram0a(
               .CLKA(clk2x),
               .CLKB(clk2x),
               .SSRA(reset_q),
               .SSRB(reset_q),
               .ADDRA(b0addra),
               .ADDRB(b0addrb),
               .DIA(w_data_in_0[0:31]),
               .DIB({32{1'b0}}),
               .DOA(r_data_out_0_bram[0:31]),
               .DOB(r_data_out_1_bram[0:31]),
               .DOPA(r_data_out_0_bram[32:35]),
               .DOPB(r_data_out_1_bram[32:35]),
               .DIPA(w_data_in_0[32:35]),
               .DIPB(4'b0000),
               .ENA(1'b1),
               .ENB(1'b1),
               .WEA(wea),
               .WEB(web)
            );

     assign do = r_data_out_1_fq[0:15];

     assign func_scan_out = func_scan_in;
     assign time_scan_out = time_scan_in;
     assign abst_scan_out = abst_scan_in;
     assign repr_scan_out = repr_scan_in;

     assign bo_pc_failout = 1'b0;
     assign bo_pc_diagloop = 1'b0;

     assign unused = |{vdd, vcs, gnd, nclk, lcb_d_mode_dc, lcb_clkoff_dc_b, lcb_mpw1_dc_b, lcb_mpw2_dc_b,
                       lcb_delay_lclkr_dc, ccflush_dc, scan_dis_dc_b, scan_diag_dc, lcb_sg_0, lcb_sl_thold_0_b,
                       lcb_time_sl_thold_0, lcb_abst_sl_thold_0, lcb_ary_nsl_thold_0, lcb_repr_sl_thold_0,
                       abist_di, abist_bw_odd, abist_bw_even, abist_wr_adr, wr_abst_act, abist_rd0_adr, rd0_abst_act,
                       tc_lbist_ary_wrt_thru_dc, abist_ena_1, abist_g8t_rd0_comp_ena, abist_raw_dc_b, obs0_abist_cmp,
                       lcb_bolt_sl_thold_0, pc_bo_enable_2, pc_bo_reset, pc_bo_unload, pc_bo_repair, pc_bo_shdata,
                       pc_bo_select, tri_lcb_mpw1_dc_b, tri_lcb_mpw2_dc_b, tri_lcb_delay_lclkr_dc, tri_lcb_clkoff_dc_b,
                       tri_lcb_act_dis_dc, rd_act, r_data_out_0_bram[16:35], r_data_out_1_bram[16:35], r_data_out_1_fq[16:35]};
endmodule
