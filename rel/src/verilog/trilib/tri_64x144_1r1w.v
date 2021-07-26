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
// *! FILENAME    : tri_64x144_1r1w.v
// *! DESCRIPTION : 64 Entry x 144 bit array, 9 bit writeable
// *!
// *!****************************************************************

`include "tri_a2o.vh"

module tri_64x144_1r1w(
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
   addr_wr,
   data_in,
   addr_rd,
   data_out
);
parameter                                      addressable_ports = 64;	// number of addressable register in this array
parameter                                      addressbus_width = 6;		// width of the bus to address all ports (2^addressbus_width >= addressable_ports)
parameter                                      port_bitwidth = 144;		// bitwidth of ports (per way)
parameter                                      bit_write_type = 9;		// gives the number of bits that shares one write-enable; must divide evenly into array
parameter                                      ways = 1;                     // number of ways

// POWER PINS
inout                                          gnd;
inout                                          vdd;
inout                                          vcs;

// CLOCK and CLOCKCONTROL ports
input [0:`NCLK_WIDTH-1]                        nclk;
input                                          rd_act;
input                                          wr_act;
input                                          sg_0;
input                                          abst_sl_thold_0;
input                                          ary_nsl_thold_0;
input                                          time_sl_thold_0;
input                                          repr_sl_thold_0;
input                                          func_sl_force;
input                                          func_sl_thold_0_b;
input                                          g8t_clkoff_dc_b;
input                                          ccflush_dc;
input                                          scan_dis_dc_b;
input                                          scan_diag_dc;
input                                          g8t_d_mode_dc;
input [0:4]                                    g8t_mpw1_dc_b;
input                                          g8t_mpw2_dc_b;
input [0:4]                                    g8t_delay_lclkr_dc;
input                                          d_mode_dc;
input                                          mpw1_dc_b;
input                                          mpw2_dc_b;
input                                          delay_lclkr_dc;

// ABIST
input                                          wr_abst_act;
input                                          rd0_abst_act;
input [0:3]                                    abist_di;
input                                          abist_bw_odd;
input                                          abist_bw_even;
input [0:addressbus_width-1]                   abist_wr_adr;
input [0:addressbus_width-1]                   abist_rd0_adr;
input                                          tc_lbist_ary_wrt_thru_dc;
input                                          abist_ena_1;
input                                          abist_g8t_rd0_comp_ena;
input                                          abist_raw_dc_b;
input [0:3]                                    obs0_abist_cmp;

// Scan
input                                          abst_scan_in;
input                                          time_scan_in;
input                                          repr_scan_in;
input                                          func_scan_in;
output                                         abst_scan_out;
output                                         time_scan_out;
output                                         repr_scan_out;
output                                         func_scan_out;

// BOLT-ON
input                                          lcb_bolt_sl_thold_0;
input                                          pc_bo_enable_2;	// general bolt-on enable
input                                          pc_bo_reset;		// reset
input                                          pc_bo_unload;		// unload sticky bits
input                                          pc_bo_repair;		// execute sticky bit decode
input                                          pc_bo_shdata;		// shift data for timing write and diag loop
input [0:1]                                    pc_bo_select;		// select for mask and hier writes
output [0:1]                                   bo_pc_failout;	// fail/no-fix reg
output [0:1]                                   bo_pc_diagloop;
input                                          tri_lcb_mpw1_dc_b;
input                                          tri_lcb_mpw2_dc_b;
input                                          tri_lcb_delay_lclkr_dc;
input                                          tri_lcb_clkoff_dc_b;
input                                          tri_lcb_act_dis_dc;

// Write Ports
input                                          write_enable;
input [0:addressbus_width-1]                   addr_wr;
input [0:port_bitwidth-1]                      data_in;

// Read Ports
input [0:addressbus_width-1]                   addr_rd;
output [0:port_bitwidth-1]                     data_out;

// tri_64x144_1r1w

// Configuration Statement for NCsim
//for all:RAMB36 use entity unisim.RAMB36;

parameter                                      data_width = ((((port_bitwidth - 1)/36) + 1) * 36) - 1;
parameter                                      rd_act_offset = 0;
parameter                                      data_out_offset = rd_act_offset + 1;
parameter                                      scan_right = data_out_offset + port_bitwidth - 1;

wire [0:data_width-(data_width/9)-1]           ramb_data_in;
wire [0:data_width/9]                          ramb_par_in;
wire [0:data_width-(data_width/9)-1]           ramb_data_out;
wire [0:data_width/9]                          ramb_par_out;
wire [0:data_width-(data_width/9)-1]           ramb_data_dummy;
wire [0:data_width/9]                          ramb_par_dummy;
wire [0:15]                                    ramb_wr_addr;
wire [0:15]                                    ramb_rd_addr;
wire [0:data_width]                            data_in_pad;
wire [0:data_width]                            data_out_pad;
wire [0:((port_bitwidth-1)/36)]	               cascadeoutlata;
wire [0:((port_bitwidth-1)/36)]	               cascadeoutlatb;
wire [0:((port_bitwidth-1)/36)]	               cascadeoutrega;
wire [0:((port_bitwidth-1)/36)]	               cascadeoutregb;
wire                                           rd_act_d;
wire                                           rd_act_q;
wire [0:port_bitwidth-1]                       data_out_d;
wire [0:port_bitwidth-1]                       data_out_q;

wire                                           tiup;
wire                                           tidn;
wire [0:(((((port_bitwidth-1)/36)+1)*36)/9)-1] wrt_en;
wire                                           act;
wire [0:scan_right]                            siv;
wire [0:scan_right]                            sov;

(* analysis_not_referenced="true" *)
wire						 unused;

generate begin
  assign tiup = 1'b1;
  assign tidn = 1'b0;
  assign wrt_en = {(((((port_bitwidth-1)/36)+1)*36)/9){write_enable}};
  assign act = rd_act | wr_act;
  assign rd_act_d = rd_act;

  assign ramb_wr_addr[0] = 1'b0;
  assign ramb_wr_addr[11:15] = 5'b0;
  assign ramb_rd_addr[0] = 1'b0;
  assign ramb_rd_addr[11:15] = 5'b0;

  genvar  addr;
  for (addr = 0; addr < 10; addr = addr + 1) begin : padA0
    if (addr < 10 - addressbus_width)
    begin
      assign ramb_wr_addr[addr + 1] = 1'b0;
      assign ramb_rd_addr[addr + 1] = 1'b0;
    end
    if (addr >= 10 - addressbus_width)
    begin
      assign ramb_wr_addr[addr + 1] = addr_wr[addr - (10 - addressbus_width)];
      assign ramb_rd_addr[addr + 1] = addr_rd[addr - (10 - addressbus_width)];
    end
  end

  // PORTA => Used for Writing
  // PORTB => Used for Reading
  genvar  arr;
  for (arr = 0; arr <= (port_bitwidth - 1)/36; arr = arr + 1)
  begin : padD0
    genvar  bit;
    for (bit = 0; bit < 36; bit = bit + 1)
    begin : numBit
      if ((arr * 36) + bit < port_bitwidth)
      begin
        assign data_in_pad[(arr * 36) + bit] = data_in[(arr * 36) + bit];
      end
      if ((arr * 36) + bit >= port_bitwidth)
      begin
        assign data_in_pad[(arr * 36) + bit] = 1'b0;
      end
    end
  end

  genvar  byte;
  for (byte = 0; byte <= (data_width)/9; byte = byte + 1)
  begin : dInFixUp
    assign ramb_data_in[byte * 8:(byte * 8) + 7] = data_in_pad[(byte * 8) + byte:(byte * 8) + 7 + byte];
    assign ramb_par_in[byte] = data_in_pad[(byte * 8) + byte + 8];
  end

  //genvar  byte;
  for (byte = 0; byte <= (data_width)/9; byte = byte + 1)
  begin : dOutFixUp
    assign data_out_pad[(byte * 8) + byte:(byte * 8) + 7 + byte] = ramb_data_out[byte * 8:(byte * 8) + 7];
    assign data_out_pad[(byte * 8) + byte + 8] = ramb_par_out[byte];
  end

  genvar  anum;
  for (anum = 0; anum <= (port_bitwidth - 1)/36; anum = anum + 1)
  begin : arrNum

   RAMB36 #(.SIM_COLLISION_CHECK("NONE"), .READ_WIDTH_A(36), .READ_WIDTH_B(36), .WRITE_WIDTH_A(36), .WRITE_WIDTH_B(36), .WRITE_MODE_A("READ_FIRST"), .WRITE_MODE_B("READ_FIRST")) ARR(
      .CASCADEOUTLATA(cascadeoutlata[anum]),
      .CASCADEOUTLATB(cascadeoutlatb[anum]),
      .CASCADEOUTREGA(cascadeoutrega[anum]),
      .CASCADEOUTREGB(cascadeoutregb[anum]),
      .DOA(ramb_data_dummy[(32 * anum):31 + (32 * anum)]),
      .DOB(ramb_data_out[(32 * anum):31 + (32 * anum)]),
      .DOPA(ramb_par_dummy[(4 * anum):3 + (4 * anum)]),
      .DOPB(ramb_par_out[(4 * anum):3 + (4 * anum)]),
      .ADDRA(ramb_wr_addr),
      .ADDRB(ramb_rd_addr),
      .CASCADEINLATA(1'b0),
      .CASCADEINLATB(1'b0),
      .CASCADEINREGA(1'b0),
      .CASCADEINREGB(1'b0),
      .CLKA(nclk[0]),
      .CLKB(nclk[0]),
      .DIA(ramb_data_in[(32 * anum):31 + (32 * anum)]),
      .DIB(32'b0),
      .DIPA(ramb_par_in[(4 * anum):3 + (4 * anum)]),
      .DIPB(4'b0),
      .ENA(act),
      .ENB(act),
      .REGCEA(1'b0),
      .REGCEB(1'b0),
      .SSRA(nclk[1]),        //sreset
      .SSRB(nclk[1]),
      .WEA(wrt_en[anum * 4:anum * 4 + 3]),
      .WEB(4'b0)	//'
   );
  end
  assign data_out_d = data_out_pad[0:port_bitwidth - 1];
  assign data_out   = data_out_q;

  assign abst_scan_out = tidn;
  assign time_scan_out = tidn;
  assign repr_scan_out = tidn;
  assign bo_pc_failout = 2'b00;
  assign bo_pc_diagloop = 2'b00;
end
endgenerate

assign unused = | {
  cascadeoutlata ,
  cascadeoutlatb ,
  cascadeoutrega ,
  cascadeoutregb ,
  ramb_data_dummy ,
  ramb_par_dummy ,
  nclk[2:`NCLK_WIDTH-1] ,
  gnd ,
  vdd ,
  vcs ,
  sg_0 ,
  abst_sl_thold_0 ,
  ary_nsl_thold_0 ,
  time_sl_thold_0 ,
  repr_sl_thold_0 ,
  g8t_clkoff_dc_b ,
  ccflush_dc ,
  scan_dis_dc_b ,
  scan_diag_dc ,
  g8t_d_mode_dc ,
  g8t_mpw1_dc_b ,
  g8t_mpw2_dc_b ,
  g8t_delay_lclkr_dc ,
  wr_abst_act ,
  rd0_abst_act ,
  abist_di ,
  abist_bw_odd ,
  abist_bw_even ,
  abist_wr_adr ,
  abist_rd0_adr ,
  tc_lbist_ary_wrt_thru_dc ,
  abist_ena_1 ,
  abist_g8t_rd0_comp_ena ,
  abist_raw_dc_b ,
  obs0_abist_cmp ,
  abst_scan_in ,
  time_scan_in ,
  repr_scan_in ,
  lcb_bolt_sl_thold_0 ,
  pc_bo_enable_2 ,
  pc_bo_reset ,
  pc_bo_unload ,
  pc_bo_repair ,
  pc_bo_shdata ,
  pc_bo_select ,
  tri_lcb_mpw1_dc_b ,
  tri_lcb_mpw2_dc_b ,
  tri_lcb_delay_lclkr_dc ,
  tri_lcb_clkoff_dc_b ,
  tri_lcb_act_dis_dc };

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

tri_rlmreg_p #(.WIDTH(port_bitwidth), .INIT(0), .NEEDS_SRESET(1)) data_out_reg(
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
   .scin(siv[data_out_offset:data_out_offset + port_bitwidth - 1]),
   .scout(sov[data_out_offset:data_out_offset + port_bitwidth - 1]),
   .din(data_out_d),
   .dout(data_out_q)
);

assign siv[0:scan_right] = {sov[1:scan_right], func_scan_in};
assign func_scan_out = sov[0];

endmodule
