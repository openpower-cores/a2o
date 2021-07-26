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

// *!****************************************************************
// *! FILENAME    : tri_64x34_8w_1r1w.vhdl
// *! DESCRIPTION : 32 entry x 35 bit x 8 way array
// *!
// *!****************************************************************

`include "tri_a2o.vh"

module tri_64x34_8w_1r1w(
   gnd,
   vdd,
   vcs,
   nclk,
   rd_act,
   wr_act,
   sg_0,
   abst_sl_thold_0,
   ary_nsl_thold_0,
   time_sl_thold_0,
   repr_sl_thold_0,
   func_sl_force,
   func_sl_thold_0_b,
   g8t_clkoff_dc_b,
   ccflush_dc,
   scan_dis_dc_b,
   scan_diag_dc,
   g8t_d_mode_dc,
   g8t_mpw1_dc_b,
   g8t_mpw2_dc_b,
   g8t_delay_lclkr_dc,
   d_mode_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   delay_lclkr_dc,
   wr_abst_act,
   rd0_abst_act,
   abist_di,
   abist_bw_odd,
   abist_bw_even,
   abist_wr_adr,
   abist_rd0_adr,
   tc_lbist_ary_wrt_thru_dc,
   abist_ena_1,
   abist_g8t_rd0_comp_ena,
   abist_raw_dc_b,
   obs0_abist_cmp,
   abst_scan_in,
   time_scan_in,
   repr_scan_in,
   func_scan_in,
   abst_scan_out,
   time_scan_out,
   repr_scan_out,
   func_scan_out,
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
   write_enable,
   way,
   addr_wr,
   data_in,
   addr_rd_01,
   addr_rd_23,
   addr_rd_45,
   addr_rd_67,
   data_out
);
parameter                         addressable_ports = 64;		// number of addressable register in this array
parameter                         addressbus_width = 6;		    // width of the bus to address all ports (2^addressbus_width >= addressable_ports)
parameter                         port_bitwidth = 34;		    // bitwidth of ports
parameter                         ways = 8;				        // number of ways
// POWER PINS
inout                             gnd;
inout                             vdd;
inout                             vcs;

// CLOCK and CLOCKCONTROL ports
input [0:`NCLK_WIDTH-1]           nclk;
input                             rd_act;
input                             wr_act;
input                             sg_0;
input                             abst_sl_thold_0;
input                             ary_nsl_thold_0;
input                             time_sl_thold_0;
input                             repr_sl_thold_0;
input                             func_sl_force;
input                             func_sl_thold_0_b;
input                             g8t_clkoff_dc_b;
input                             ccflush_dc;
input                             scan_dis_dc_b;
input                             scan_diag_dc;
input                             g8t_d_mode_dc;
input [0:4]                       g8t_mpw1_dc_b;
input                             g8t_mpw2_dc_b;
input [0:4]                       g8t_delay_lclkr_dc;
input                             d_mode_dc;
input                             mpw1_dc_b;
input                             mpw2_dc_b;
input                             delay_lclkr_dc;

// ABIST
input                             wr_abst_act;
input                             rd0_abst_act;
input [0:3]                       abist_di;
input                             abist_bw_odd;
input                             abist_bw_even;
input [0:addressbus_width-1]      abist_wr_adr;
input [0:addressbus_width-1]      abist_rd0_adr;
input                             tc_lbist_ary_wrt_thru_dc;
input                             abist_ena_1;
input                             abist_g8t_rd0_comp_ena;
input                             abist_raw_dc_b;
input [0:3]                       obs0_abist_cmp;

// SCAN
input                             abst_scan_in;
input                             time_scan_in;
input                             repr_scan_in;
input                             func_scan_in;
output                            abst_scan_out;
output                            time_scan_out;
output                            repr_scan_out;
output                            func_scan_out;

// BOLT-ON
input                             lcb_bolt_sl_thold_0;
input                             pc_bo_enable_2;		        // general bolt-on enable
input                             pc_bo_reset;		            // reset
input                             pc_bo_unload;		            // unload sticky bits
input                             pc_bo_repair;		            // execute sticky bit decode
input                             pc_bo_shdata;		            // shift data for timing write and diag loop
input [0:3]                       pc_bo_select;		            // select for mask and hier writes
output [0:3]                      bo_pc_failout;		        // fail/no-fix reg
output [0:3]                      bo_pc_diagloop;
input                             tri_lcb_mpw1_dc_b;
input                             tri_lcb_mpw2_dc_b;
input                             tri_lcb_delay_lclkr_dc;
input                             tri_lcb_clkoff_dc_b;
input                             tri_lcb_act_dis_dc;

// Write Ports
input [0:3]                       write_enable;
input [0:ways-1]                  way;
input [0:addressbus_width-1]      addr_wr;
input [0:port_bitwidth-1]         data_in;

// Read Ports
input [0:addressbus_width-1]      addr_rd_01;
input [0:addressbus_width-1]      addr_rd_23;
input [0:addressbus_width-1]      addr_rd_45;
input [0:addressbus_width-1]      addr_rd_67;
output [0:port_bitwidth*ways-1]   data_out;

// tri_64x34_8w_1r1w
parameter                           ramb_base_addr = 16;
parameter                           dataWidth = ((((port_bitwidth - 1)/36) + 1) * 36) - 1;
parameter                           numBytes = (dataWidth/9);

// Configuration Statement for NCsim
//for all:RAMB16_S36_S36 use entity unisim.RAMB16_S36_S36;
parameter                           rd_act_offset = 0;
parameter                           data_out_offset = rd_act_offset + 1;
parameter                           scan_right = data_out_offset + (ways*port_bitwidth) - 1;

wire [0:35]                         ramb_data_in;
wire [0:35]                         ramb_data_p0_out[0:ways-1];
wire [0:(dataWidth+1)*ways-1]       ramb_data_p0_concat;
wire [0:ramb_base_addr-1]           ramb_addr_rd1;
wire [0:ramb_base_addr-1]           ramb_addr_wr_rd0;

wire [0:ramb_base_addr-1]           rd_addr0;
wire [0:ramb_base_addr-1]           wr_addr;
wire                                write_en;
wire [0:3]                          write_enable_way[0:ways-1];
wire [0:(dataWidth-numBytes)-1]     arr_data_in;
wire [0:numBytes]                   arr_par_in;
wire [0:(dataWidth-numBytes)-1]     arr_data_out[0:ways-1];
wire [0:numBytes]                   arr_par_out[0:ways-1];
wire [0:dataWidth]                  arr_data_out_pad[0:ways-1];
wire [0:(dataWidth+1)*ways-1]       arr_data_concat;
wire [0:port_bitwidth*ways-1]       data_out_d;
wire [0:port_bitwidth*ways-1]       data_out_q;
wire [0:ways-1]			            cascadeoutlata;
wire [0:ways-1]			            cascadeoutlatb;
wire [0:ways-1]			            cascadeoutrega;
wire [0:ways-1]			            cascadeoutregb;
wire                                rd_act_d;
wire                                rd_act_q;

(* analysis_not_referenced="true" *)
wire				                unused;
wire                                tiup;
wire [0:35]                         tidn;
wire [0:scan_right]                 siv;
wire [0:scan_right]                 sov;

generate begin

  assign tiup = 1'b1;
  assign tidn = 36'b0;

  // Data Generate
  genvar  t;
  for (t = 0; t < 36; t = t + 1)
  begin : addr_calc
    if (t < 35 - (port_bitwidth - 1))
    begin
      assign ramb_data_in[t] = 1'b0;
    end
    if (t >= 35 - (port_bitwidth - 1))
    begin
      assign ramb_data_in[t] = data_in[t - (35 - (port_bitwidth - 1))];
    end
  end

  genvar  byte;
  for (byte = 0; byte <= numBytes; byte = byte + 1)  begin : dFixUp
    assign arr_data_in[byte*8:(byte*8)+7] = ramb_data_in[(byte * 8)+byte:(((byte*8)+7)+byte)];
    assign arr_par_in[byte]		          = ramb_data_in[(((byte*8)+byte)+8)];
    genvar numWays;
    for (numWays=0; numWays<ways; numWays=numWays+1) begin : wayRd
      assign arr_data_out_pad[numWays][(byte * 8) + byte:(((byte * 8) + 7) + byte)] = arr_data_out[numWays][byte * 8:(byte * 8) + 7];
      assign arr_data_out_pad[numWays][(((byte * 8) + byte) + 8)]		            = arr_par_out[numWays][byte];
    end
  end

  // Read/Write Port Address Generate
  assign rd_addr0[1] = 1'b0;
  assign rd_addr0[0] = 1'b0;
  assign rd_addr0[11:15] = 5'b0;
  assign wr_addr[1] = 1'b0;
  assign wr_addr[0] = 1'b0;
  assign wr_addr[11:15] = 5'b0;

  for (t = 0; t < 9; t = t + 1) begin : rambAddrCalc
    if (t < 9 - addressbus_width) begin
      assign rd_addr0[t+2] = 1'b0;
      assign wr_addr[t+2] = 1'b0;
    end
    if (t >= 9 - addressbus_width) begin
      assign rd_addr0[t+2] = addr_rd_01[t - (9 - addressbus_width)];
      assign wr_addr[t+2] = addr_wr[t - (9 - addressbus_width)];
    end
  end

  genvar numWays;
  for (numWays=0; numWays<ways; numWays=numWays+1) begin : dOut
    assign data_out_d[(numWays*port_bitwidth):(numWays*port_bitwidth)+port_bitwidth-1] = arr_data_out_pad[numWays][(35 - (port_bitwidth - 1)):35];
    assign arr_data_concat[(numWays*(dataWidth+1)):(numWays*(dataWidth+1))+(dataWidth+1)-1]     = arr_data_out_pad[numWays];
    assign ramb_data_p0_concat[(numWays*(dataWidth+1)):(numWays*(dataWidth+1))+(dataWidth+1)-1] = ramb_data_p0_out[numWays];
    assign write_enable_way[numWays] = {4{write_enable[numWays/2] & way[numWays]}};
  end

end
endgenerate

// Writing on PortA
// Reading on PortB
assign ramb_addr_rd1 = rd_addr0;
assign write_en = |(write_enable);
assign ramb_addr_wr_rd0 = wr_addr;
assign rd_act_d = rd_act;
assign data_out = data_out_q;

// all, none, warning_only, generate_x_only
RAMB36 #(.SIM_COLLISION_CHECK("NONE"), .READ_WIDTH_A(36), .READ_WIDTH_B(36), .WRITE_WIDTH_A(36), .WRITE_WIDTH_B(36), .WRITE_MODE_A("READ_FIRST"), .WRITE_MODE_B("READ_FIRST")) arr0_A(
   .CASCADEOUTLATA(cascadeoutlata[0]),
   .CASCADEOUTLATB(cascadeoutlatb[0]),
   .CASCADEOUTREGA(cascadeoutrega[0]),
   .CASCADEOUTREGB(cascadeoutregb[0]),
   .DOA(ramb_data_p0_out[0][0:31]),
   .DOB(arr_data_out[0]),
   .DOPA(ramb_data_p0_out[0][32:35]),
   .DOPB(arr_par_out[0]),
   .ADDRA(ramb_addr_wr_rd0),
   .ADDRB(ramb_addr_rd1),
   .CASCADEINLATA(1'b0),
   .CASCADEINLATB(1'b0),
   .CASCADEINREGA(1'b0),
   .CASCADEINREGB(1'b0),
   .CLKA(nclk[0]),
   .CLKB(nclk[0]),
   .DIA(arr_data_in),
   .DIB(tidn[0:31]),
   .DIPA(arr_par_in),
   .DIPB(tidn[32:35]),
   .ENA(write_en),
   .ENB(rd_act),
   .REGCEA(1'b0),
   .REGCEB(1'b0),
   .SSRA(nclk[1]),   //sreset
   .SSRB(nclk[1]),   //sreset
   .WEA(write_enable_way[0]),
   .WEB(tidn[0:3])
);

// all, none, warning_only, generate_x_only
RAMB36 #(.SIM_COLLISION_CHECK("NONE"), .READ_WIDTH_A(36), .READ_WIDTH_B(36), .WRITE_WIDTH_A(36), .WRITE_WIDTH_B(36), .WRITE_MODE_A("READ_FIRST"), .WRITE_MODE_B("READ_FIRST")) arr1_B(
   .CASCADEOUTLATA(cascadeoutlata[1]),
   .CASCADEOUTLATB(cascadeoutlatb[1]),
   .CASCADEOUTREGA(cascadeoutrega[1]),
   .CASCADEOUTREGB(cascadeoutregb[1]),
   .DOA(ramb_data_p0_out[1][0:31]),
   .DOB(arr_data_out[1]),
   .DOPA(ramb_data_p0_out[1][32:35]),
   .DOPB(arr_par_out[1]),
   .ADDRA(ramb_addr_wr_rd0),
   .ADDRB(ramb_addr_rd1),
   .CASCADEINLATA(1'b0),
   .CASCADEINLATB(1'b0),
   .CASCADEINREGA(1'b0),
   .CASCADEINREGB(1'b0),
   .CLKA(nclk[0]),
   .CLKB(nclk[0]),
   .DIA(arr_data_in),
   .DIB(tidn[0:31]),
   .DIPA(arr_par_in),
   .DIPB(tidn[32:35]),
   .ENA(write_en),
   .ENB(rd_act),
   .REGCEA(1'b0),
   .REGCEB(1'b0),
   .SSRA(nclk[1]),
   .SSRB(nclk[1]),
   .WEA(write_enable_way[1]),
   .WEB(tidn[0:3])
);

// all, none, warning_only, generate_x_only
RAMB36 #(.SIM_COLLISION_CHECK("NONE"), .READ_WIDTH_A(36), .READ_WIDTH_B(36), .WRITE_WIDTH_A(36), .WRITE_WIDTH_B(36), .WRITE_MODE_A("READ_FIRST"), .WRITE_MODE_B("READ_FIRST")) arr2_C(
   .CASCADEOUTLATA(cascadeoutlata[2]),
   .CASCADEOUTLATB(cascadeoutlatb[2]),
   .CASCADEOUTREGA(cascadeoutrega[2]),
   .CASCADEOUTREGB(cascadeoutregb[2]),
   .DOA(ramb_data_p0_out[2][0:31]),
   .DOB(arr_data_out[2]),
   .DOPA(ramb_data_p0_out[2][32:35]),
   .DOPB(arr_par_out[2]),
   .ADDRA(ramb_addr_wr_rd0),
   .ADDRB(ramb_addr_rd1),
   .CASCADEINLATA(1'b0),
   .CASCADEINLATB(1'b0),
   .CASCADEINREGA(1'b0),
   .CASCADEINREGB(1'b0),
   .CLKA(nclk[0]),
   .CLKB(nclk[0]),
   .DIA(arr_data_in),
   .DIB(tidn[0:31]),
   .DIPA(arr_par_in),
   .DIPB(tidn[32:35]),
   .ENA(write_en),
   .ENB(rd_act),
   .REGCEA(1'b0),
   .REGCEB(1'b0),
   .SSRA(nclk[1]),
   .SSRB(nclk[1]),
   .WEA(write_enable_way[2]),
   .WEB(tidn[0:3])
);

// all, none, warning_only, generate_x_only
RAMB36 #(.SIM_COLLISION_CHECK("NONE"), .READ_WIDTH_A(36), .READ_WIDTH_B(36), .WRITE_WIDTH_A(36), .WRITE_WIDTH_B(36), .WRITE_MODE_A("READ_FIRST"), .WRITE_MODE_B("READ_FIRST")) arr3_D(
   .CASCADEOUTLATA(cascadeoutlata[3]),
   .CASCADEOUTLATB(cascadeoutlatb[3]),
   .CASCADEOUTREGA(cascadeoutrega[3]),
   .CASCADEOUTREGB(cascadeoutregb[3]),
   .DOA(ramb_data_p0_out[3][0:31]),
   .DOB(arr_data_out[3]),
   .DOPA(ramb_data_p0_out[3][32:35]),
   .DOPB(arr_par_out[3]),
   .ADDRA(ramb_addr_wr_rd0),
   .ADDRB(ramb_addr_rd1),
   .CASCADEINLATA(1'b0),
   .CASCADEINLATB(1'b0),
   .CASCADEINREGA(1'b0),
   .CASCADEINREGB(1'b0),
   .CLKA(nclk[0]),
   .CLKB(nclk[0]),
   .DIA(arr_data_in),
   .DIB(tidn[0:31]),
   .DIPA(arr_par_in),
   .DIPB(tidn[32:35]),
   .ENA(write_en),
   .ENB(rd_act),
   .REGCEA(1'b0),
   .REGCEB(1'b0),
   .SSRA(nclk[1]),
   .SSRB(nclk[1]),
   .WEA(write_enable_way[3]),
   .WEB(tidn[0:3])
);

// all, none, warning_only, generate_x_only
RAMB36 #(.SIM_COLLISION_CHECK("NONE"), .READ_WIDTH_A(36), .READ_WIDTH_B(36), .WRITE_WIDTH_A(36), .WRITE_WIDTH_B(36), .WRITE_MODE_A("READ_FIRST"), .WRITE_MODE_B("READ_FIRST")) arr4_E(
   .CASCADEOUTLATA(cascadeoutlata[4]),
   .CASCADEOUTLATB(cascadeoutlatb[4]),
   .CASCADEOUTREGA(cascadeoutrega[4]),
   .CASCADEOUTREGB(cascadeoutregb[4]),
   .DOA(ramb_data_p0_out[4][0:31]),
   .DOB(arr_data_out[4]),
   .DOPA(ramb_data_p0_out[4][32:35]),
   .DOPB(arr_par_out[4]),
   .ADDRA(ramb_addr_wr_rd0),
   .ADDRB(ramb_addr_rd1),
   .CASCADEINLATA(1'b0),
   .CASCADEINLATB(1'b0),
   .CASCADEINREGA(1'b0),
   .CASCADEINREGB(1'b0),
   .CLKA(nclk[0]),
   .CLKB(nclk[0]),
   .DIA(arr_data_in),
   .DIB(tidn[0:31]),
   .DIPA(arr_par_in),
   .DIPB(tidn[32:35]),
   .ENA(write_en),
   .ENB(rd_act),
   .REGCEA(1'b0),
   .REGCEB(1'b0),
   .SSRA(nclk[1]),
   .SSRB(nclk[1]),
   .WEA(write_enable_way[4]),
   .WEB(tidn[0:3])
);

// all, none, warning_only, generate_x_only
RAMB36 #(.SIM_COLLISION_CHECK("NONE"), .READ_WIDTH_A(36), .READ_WIDTH_B(36), .WRITE_WIDTH_A(36), .WRITE_WIDTH_B(36), .WRITE_MODE_A("READ_FIRST"), .WRITE_MODE_B("READ_FIRST")) arr5_F(
   .CASCADEOUTLATA(cascadeoutlata[5]),
   .CASCADEOUTLATB(cascadeoutlatb[5]),
   .CASCADEOUTREGA(cascadeoutrega[5]),
   .CASCADEOUTREGB(cascadeoutregb[5]),
   .DOA(ramb_data_p0_out[5][0:31]),
   .DOB(arr_data_out[5]),
   .DOPA(ramb_data_p0_out[5][32:35]),
   .DOPB(arr_par_out[5]),
   .ADDRA(ramb_addr_wr_rd0),
   .ADDRB(ramb_addr_rd1),
   .CASCADEINLATA(1'b0),
   .CASCADEINLATB(1'b0),
   .CASCADEINREGA(1'b0),
   .CASCADEINREGB(1'b0),
   .CLKA(nclk[0]),
   .CLKB(nclk[0]),
   .DIA(arr_data_in),
   .DIB(tidn[0:31]),
   .DIPA(arr_par_in),
   .DIPB(tidn[32:35]),
   .ENA(write_en),
   .ENB(rd_act),
   .REGCEA(1'b0),
   .REGCEB(1'b0),
   .SSRA(nclk[1]),
   .SSRB(nclk[1]),
   .WEA(write_enable_way[5]),
   .WEB(tidn[0:3])
);

// all, none, warning_only, generate_x_only
RAMB36 #(.SIM_COLLISION_CHECK("NONE"), .READ_WIDTH_A(36), .READ_WIDTH_B(36), .WRITE_WIDTH_A(36), .WRITE_WIDTH_B(36), .WRITE_MODE_A("READ_FIRST"), .WRITE_MODE_B("READ_FIRST")) arr6_G(
   .CASCADEOUTLATA(cascadeoutlata[6]),
   .CASCADEOUTLATB(cascadeoutlatb[6]),
   .CASCADEOUTREGA(cascadeoutrega[6]),
   .CASCADEOUTREGB(cascadeoutregb[6]),
   .DOA(ramb_data_p0_out[6][0:31]),
   .DOB(arr_data_out[6]),
   .DOPA(ramb_data_p0_out[6][32:35]),
   .DOPB(arr_par_out[6]),
   .ADDRA(ramb_addr_wr_rd0),
   .ADDRB(ramb_addr_rd1),
   .CASCADEINLATA(1'b0),
   .CASCADEINLATB(1'b0),
   .CASCADEINREGA(1'b0),
   .CASCADEINREGB(1'b0),
   .CLKA(nclk[0]),
   .CLKB(nclk[0]),
   .DIA(arr_data_in),
   .DIB(tidn[0:31]),
   .DIPA(arr_par_in),
   .DIPB(tidn[32:35]),
   .ENA(write_en),
   .ENB(rd_act),
   .REGCEA(1'b0),
   .REGCEB(1'b0),
   .SSRA(nclk[1]),
   .SSRB(nclk[1]),
   .WEA(write_enable_way[6]),
   .WEB(tidn[0:3])
);

// all, none, warning_only, generate_x_only
RAMB36 #(.SIM_COLLISION_CHECK("NONE"), .READ_WIDTH_A(36), .READ_WIDTH_B(36), .WRITE_WIDTH_A(36), .WRITE_WIDTH_B(36), .WRITE_MODE_A("READ_FIRST"), .WRITE_MODE_B("READ_FIRST")) arr7_H(
   .CASCADEOUTLATA(cascadeoutlata[7]),
   .CASCADEOUTLATB(cascadeoutlatb[7]),
   .CASCADEOUTREGA(cascadeoutrega[7]),
   .CASCADEOUTREGB(cascadeoutregb[7]),
   .DOA(ramb_data_p0_out[7][0:31]),
   .DOB(arr_data_out[7]),
   .DOPA(ramb_data_p0_out[7][32:35]),
   .DOPB(arr_par_out[7]),
   .ADDRA(ramb_addr_wr_rd0),
   .ADDRB(ramb_addr_rd1),
   .CASCADEINLATA(1'b0),
   .CASCADEINLATB(1'b0),
   .CASCADEINREGA(1'b0),
   .CASCADEINREGB(1'b0),
   .CLKA(nclk[0]),
   .CLKB(nclk[0]),
   .DIA(arr_data_in),
   .DIB(tidn[0:31]),
   .DIPA(arr_par_in),
   .DIPB(tidn[32:35]),
   .ENA(write_en),
   .ENB(rd_act),
   .REGCEA(1'b0),
   .REGCEB(1'b0),
   .SSRA(nclk[1]),
   .SSRB(nclk[1]),
   .WEA(write_enable_way[7]),
   .WEB(tidn[0:3])
);

assign abst_scan_out = tidn[0];
assign time_scan_out = tidn[0];
assign repr_scan_out = tidn[0];
assign bo_pc_failout = tidn[0:3];
assign bo_pc_diagloop = tidn[0:3];

assign unused = |({cascadeoutlata, cascadeoutlatb, cascadeoutrega, cascadeoutregb, tiup, wr_act,
                   ramb_data_p0_concat, nclk[2:`NCLK_WIDTH-1], gnd, vdd, vcs, sg_0, abst_sl_thold_0, ary_nsl_thold_0,
                   time_sl_thold_0, repr_sl_thold_0, g8t_clkoff_dc_b, ccflush_dc, scan_dis_dc_b, scan_diag_dc,
                   g8t_d_mode_dc, g8t_mpw1_dc_b, g8t_mpw2_dc_b, g8t_delay_lclkr_dc, wr_abst_act, rd0_abst_act, abist_di,
                   abist_bw_odd, abist_bw_even, abist_wr_adr, abist_rd0_adr, tc_lbist_ary_wrt_thru_dc, abist_ena_1,
                   abist_g8t_rd0_comp_ena, abist_raw_dc_b, obs0_abist_cmp, abst_scan_in, time_scan_in, repr_scan_in,
                   lcb_bolt_sl_thold_0, pc_bo_enable_2, pc_bo_reset, pc_bo_unload, pc_bo_repair, pc_bo_shdata,
                   pc_bo_select, tri_lcb_mpw1_dc_b, tri_lcb_mpw2_dc_b, tri_lcb_delay_lclkr_dc, tri_lcb_clkoff_dc_b,
                   tri_lcb_act_dis_dc, addr_rd_23, addr_rd_45, addr_rd_67, arr_data_concat});

// ####################################################
// Registers
// ####################################################

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rd_act_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rd_act_offset]),
   .scout(sov[rd_act_offset]),
   .din(rd_act_d),
   .dout(rd_act_q)
);

tri_rlmreg_p #(.WIDTH((ways*port_bitwidth)), .INIT(0), .NEEDS_SRESET(1)) data_out_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rd_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[data_out_offset:data_out_offset + (ways*port_bitwidth) - 1]),
   .scout(sov[data_out_offset:data_out_offset + (ways*port_bitwidth) - 1]),
   .din(data_out_d),
   .dout(data_out_q)
);

assign siv[0:scan_right] = {sov[1:scan_right], func_scan_in};
assign func_scan_out = sov[0];

endmodule
