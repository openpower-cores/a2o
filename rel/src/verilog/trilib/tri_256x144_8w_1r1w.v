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
// *! FILENAME    : tri_256x144_8w_1r1w.v
// *! DESCRIPTION : 256 Entry x 144 bit x 8 way array, 9 bit writeable
// *!
// *!****************************************************************

`include "tri_a2o.vh"

module tri_256x144_8w_1r1w(
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
   wr_way,
   wr_addr,
   data_in0,
   data_in1,
   rd_addr,
   data_out
);
parameter                                  addressable_ports = 256;		// number of addressable register in this array
parameter                                  addressbus_width = 8;		// width of the bus to address all ports (2^addressbus_width >= addressable_ports)
parameter                                  port_bitwidth = 144;		    // bitwidth of ports (per way)
parameter                                  bit_write_type = 9;		    // gives the number of bits that shares one write-enable; must divide evenly into array
parameter                                  ways = 8;				    // number of ways

// POWER PINS
inout                                      gnd;
inout                                      vdd;
inout                                      vcs;

// CLOCK and CLOCKCONTROL ports
input [0:`NCLK_WIDTH-1]                    nclk;
input [0:7]                                rd_act;
input [0:7]                                wr_act;
input                                      sg_0;
input                                      abst_sl_thold_0;
input                                      ary_nsl_thold_0;
input                                      time_sl_thold_0;
input                                      repr_sl_thold_0;
input                                      func_sl_force;
input                                      func_sl_thold_0_b;
input                                      g8t_clkoff_dc_b;
input                                      ccflush_dc;
input                                      scan_dis_dc_b;
input                                      scan_diag_dc;
input                                      g8t_d_mode_dc;
input [0:4]                                g8t_mpw1_dc_b;
input                                      g8t_mpw2_dc_b;
input [0:4]                                g8t_delay_lclkr_dc;
input                                      d_mode_dc;
input                                      mpw1_dc_b;
input                                      mpw2_dc_b;
input                                      delay_lclkr_dc;

// ABIST
input                                      wr_abst_act;
input                                      rd0_abst_act;
input [0:3]                                abist_di;
input                                      abist_bw_odd;
input                                      abist_bw_even;
input [0:addressbus_width-1]               abist_wr_adr;
input [0:addressbus_width-1]               abist_rd0_adr;
input                                      tc_lbist_ary_wrt_thru_dc;
input                                      abist_ena_1;
input                                      abist_g8t_rd0_comp_ena;
input                                      abist_raw_dc_b;
input [0:3]                                obs0_abist_cmp;

// SCAN
input [0:3]                                abst_scan_in;
input                                      time_scan_in;
input                                      repr_scan_in;
input [0:3]                                func_scan_in;
output [0:3]                               abst_scan_out;
output                                     time_scan_out;
output                                     repr_scan_out;
output [0:3]                               func_scan_out;

// BOLT-ON
input                                      lcb_bolt_sl_thold_0;
input                                      pc_bo_enable_2;		        // general bolt-on enable
input                                      pc_bo_reset;		            // reset
input                                      pc_bo_unload;		        // unload sticky bits
input                                      pc_bo_repair;		        // execute sticky bit decode
input                                      pc_bo_shdata;		        // shift data for timing write and diag loop
input [0:3]                                pc_bo_select;		        // select for mask and hier writes
output [0:3]                               bo_pc_failout;		        // fail/no-fix reg
output [0:3]                               bo_pc_diagloop;
input                                      tri_lcb_mpw1_dc_b;
input                                      tri_lcb_mpw2_dc_b;
input                                      tri_lcb_delay_lclkr_dc;
input                                      tri_lcb_clkoff_dc_b;
input                                      tri_lcb_act_dis_dc;

// FUNCTIONAL PORTS
input [0:ways-1]                           wr_way;
input [0:(addressbus_width-1)]             wr_addr;
input [0:(port_bitwidth-1)]                data_in0;
input [0:(port_bitwidth-1)]                data_in1;
input [0:(addressbus_width-1)]             rd_addr;
output [0:(port_bitwidth*ways-1)]          data_out;

parameter                                  ramb_base_addr = 16;
parameter                                  dataWidth = ((((port_bitwidth - 1)/36) + 1) * 36) - 1;
parameter                                  numBytes = (dataWidth/9);
parameter                                  addresswidth = addressbus_width;
parameter                                  rd_act_offset = 0;
parameter                                  data_out_offset = rd_act_offset + ways;
parameter                                  scan_right = data_out_offset + (port_bitwidth*ways) - 1;

wire [0:dataWidth]                         data_in0_pad;
wire [0:dataWidth]                         data_in1_pad;
wire [0:dataWidth]                         data_in_swzl[0:ways-1];
wire [0:dataWidth]                         p0_data_out_pad[0:ways-1];
wire [0:dataWidth]                         p1_data_out_pad[0:ways-1];
wire [0:(dataWidth-(dataWidth)/9)-1]       p0_arr_data_in[0:ways-1];
wire [0:(dataWidth)/9]                     p0_arr_par_in[0:ways-1];
wire [0:(dataWidth-(dataWidth)/9)-1]       p1_arr_data_in[0:ways-1];
wire [0:(dataWidth)/9]                     p1_arr_par_in[0:ways-1];
wire [0:(dataWidth-(dataWidth)/9)-1]       p0_arr_data_out[0:ways-1];
wire [0:(dataWidth)/9]                     p0_arr_par_out[0:ways-1];
wire [0:(dataWidth-(dataWidth)/9)-1]       p1_arr_data_out[0:ways-1];
wire [0:(dataWidth)/9]                     p1_arr_par_out[0:ways-1];
wire [0:ramb_base_addr-1]                  ramb_rd_addr;
wire [0:ramb_base_addr-1]                  ramb_wr_addr;
wire [0:((((port_bitwidth-1)/36)+1)*4)-1]  p0_wayEn[0:ways-1];
wire [0:((((port_bitwidth-1)/36)+1)*4)-1]  p1_wayEn[0:ways-1];
wire [0:(port_bitwidth*ways-1)]            p0_data_out_swzl;
wire [0:(port_bitwidth*ways-1)]            p1_data_out_swzl;
wire [0:(port_bitwidth*ways-1)]            data_out_fix;
wire [0:((port_bitwidth-1)/36)]	           cascadeoutlata;
wire [0:((port_bitwidth-1)/36)]	           cascadeoutlatb;
wire [0:((port_bitwidth-1)/36)]	           cascadeoutrega;
wire [0:((port_bitwidth-1)/36)]	           cascadeoutregb;
wire [0:ways-1]                            rd_act_d;
wire [0:ways-1]                            rd_act_q;
wire [0:(port_bitwidth*ways)-1]            data_out_d;
wire [0:(port_bitwidth*ways)-1]            data_out_b_q;

wire [0:ways-1]                            my_d1clk;
wire [0:ways-1]                            my_d2clk;
wire [0:`NCLK_WIDTH-1]                     my_lclk[0:ways-1];
wire                                       tiup;
wire [0:scan_right]                        siv;
wire [0:scan_right]                        sov;

(* analysis_not_referenced="true" *)
wire                                       unused;

generate begin
  // Read/Write Port Address Generate
  assign ramb_rd_addr[11:15] = 5'b0;
  assign ramb_wr_addr[11:15] = 5'b0;
  assign rd_act_d = rd_act;
  assign tiup     = 1'b1;

  genvar  byte;
  genvar  way;
  genvar  bit;
  for (byte = 0; byte <= numBytes; byte = byte + 1) begin : swzl
    for (way = 0; way < ways; way = way + 1) begin : perWay
      if (way < (ways/2)) begin : fhalf
        assign data_in_swzl[way][(byte * 8) + byte:(((byte * 8) + 7) + byte)] = {data_in0_pad[byte + (0 * (numBytes + 1))], data_in0_pad[byte + (1 * (numBytes + 1))],
                                                                                 data_in0_pad[byte + (2 * (numBytes + 1))], data_in0_pad[byte + (3 * (numBytes + 1))],
                                                                                 data_in0_pad[byte + (4 * (numBytes + 1))], data_in0_pad[byte + (5 * (numBytes + 1))],
                                                                                 data_in0_pad[byte + (6 * (numBytes + 1))], data_in0_pad[byte + (7 * (numBytes + 1))]};
        assign data_in_swzl[way][(((byte * 8) + byte) + 8)] = data_in0_pad[byte + (8 * (numBytes + 1))];
      end
      if (way >= (ways/2)) begin : shalf
        assign data_in_swzl[way][(byte * 8) + byte:(((byte * 8) + 7) + byte)] = {data_in1_pad[byte + (0 * (numBytes + 1))], data_in1_pad[byte + (1 * (numBytes + 1))],
                                                                                 data_in1_pad[byte + (2 * (numBytes + 1))], data_in1_pad[byte + (3 * (numBytes + 1))],
                                                                                 data_in1_pad[byte + (4 * (numBytes + 1))], data_in1_pad[byte + (5 * (numBytes + 1))],
                                                                                 data_in1_pad[byte + (6 * (numBytes + 1))], data_in1_pad[byte + (7 * (numBytes + 1))]};
        assign data_in_swzl[way][(((byte * 8) + byte) + 8)] = data_in1_pad[byte + (8 * (numBytes + 1))];
      end
    end
  end

  genvar  t;
  for (t = 0; t < 11; t = t + 1) begin : rambAddrCalc
    if (t < (11-addresswidth)) begin
      assign ramb_rd_addr[t] = 1'b0;
      assign ramb_wr_addr[t] = 1'b0;
    end
    if (t >= (11-addresswidth)) begin
      assign ramb_rd_addr[t] = rd_addr[t - (11 - addresswidth)];
      assign ramb_wr_addr[t] = wr_addr[t - (11 - addresswidth)];
    end
  end

    for (bit = 0; bit <= dataWidth; bit = bit + 1) begin : dFixUp
      if (bit < port_bitwidth) begin
        assign data_in0_pad[bit] = data_in0[bit];
        assign data_in1_pad[bit] = data_in1[bit];
      end
      if (bit >= port_bitwidth) begin
        assign data_in0_pad[bit] = 1'b0;
        assign data_in1_pad[bit] = 1'b0;
      end
    end

  //genvar  way;
  for (way = 0; way < ways; way = way + 1) begin : NwayDatInFix
    //genvar  byte;
    for (byte = 0; byte <= (dataWidth)/9; byte = byte + 1) begin : dFixUp
      assign p0_arr_data_in[way][byte * 8:(byte * 8) + 7] = 8'h00;
      assign p0_arr_par_in[way][byte] = 1'b0;
      assign p1_arr_data_in[way][byte * 8:(byte * 8) + 7] = data_in_swzl[way][(byte * 8) + byte:(((byte * 8) + 7) + byte)];
      assign p1_arr_par_in[way][byte] = data_in_swzl[way][(((byte * 8) + byte) + 8)];
    end
  end

  //genvar  way;
  for (way = 0; way < ways; way = way + 1) begin : NwayDatOutFix
    //genvar  byte;
    for (byte = 0; byte <= (dataWidth)/9; byte = byte + 1) begin : dFixUp
      assign p0_data_out_pad[way][(byte * 8) + byte:(((byte * 8) + 7) + byte)] = p0_arr_data_out[way][byte * 8:(byte * 8) + 7];
      assign p0_data_out_pad[way][(((byte * 8) + byte) + 8)] = p0_arr_par_out[way][byte];
      assign p1_data_out_pad[way][(byte * 8) + byte:(((byte * 8) + 7) + byte)] = p1_arr_data_out[way][byte * 8:(byte * 8) + 7];
      assign p1_data_out_pad[way][(((byte * 8) + byte) + 8)] = p1_arr_par_out[way][byte];
    end
  end

  //genvar  way;
  for (way = 0; way < ways; way = way + 1) begin : NwayDatOut
    assign p0_data_out_swzl[way * port_bitwidth:(way * port_bitwidth) + port_bitwidth - 1] = p0_data_out_pad[way][0:port_bitwidth - 1];
    assign p1_data_out_swzl[way * port_bitwidth:(way * port_bitwidth) + port_bitwidth - 1] = p1_data_out_pad[way][0:port_bitwidth - 1];

    //genvar  byte;
    for (byte = 0; byte <= numBytes; byte = byte + 1) begin : swzl
      assign data_out_fix[(way * port_bitwidth) + (0 * (numBytes + 1)) + byte] = p0_data_out_swzl[(way * port_bitwidth) + ((byte * 8) + byte) + 0];
      assign data_out_fix[(way * port_bitwidth) + (1 * (numBytes + 1)) + byte] = p0_data_out_swzl[(way * port_bitwidth) + ((byte * 8) + byte) + 1];
      assign data_out_fix[(way * port_bitwidth) + (2 * (numBytes + 1)) + byte] = p0_data_out_swzl[(way * port_bitwidth) + ((byte * 8) + byte) + 2];
      assign data_out_fix[(way * port_bitwidth) + (3 * (numBytes + 1)) + byte] = p0_data_out_swzl[(way * port_bitwidth) + ((byte * 8) + byte) + 3];
      assign data_out_fix[(way * port_bitwidth) + (4 * (numBytes + 1)) + byte] = p0_data_out_swzl[(way * port_bitwidth) + ((byte * 8) + byte) + 4];
      assign data_out_fix[(way * port_bitwidth) + (5 * (numBytes + 1)) + byte] = p0_data_out_swzl[(way * port_bitwidth) + ((byte * 8) + byte) + 5];
      assign data_out_fix[(way * port_bitwidth) + (6 * (numBytes + 1)) + byte] = p0_data_out_swzl[(way * port_bitwidth) + ((byte * 8) + byte) + 6];
      assign data_out_fix[(way * port_bitwidth) + (7 * (numBytes + 1)) + byte] = p0_data_out_swzl[(way * port_bitwidth) + ((byte * 8) + byte) + 7];
      assign data_out_fix[(way * port_bitwidth) + (8 * (numBytes + 1)) + byte] = p0_data_out_swzl[(way * port_bitwidth) + ((byte * 8) + byte) + 8];
    end
  end
  assign data_out_d = data_out_fix;

  assign data_out = ~data_out_b_q;

  //genvar  way;
  for (way = 0; way < ways; way = way + 1) begin : Nways
    //genvar  byte;
    for (byte = 0; byte < ((((port_bitwidth - 1)/36) + 1) * 4); byte = byte + 1) begin : BEn
      if (byte <= (port_bitwidth - 1)/9) begin
        assign p0_wayEn[way][byte] = 1'b0;
        assign p1_wayEn[way][byte] = wr_way[way];
      end
      if (byte > (port_bitwidth - 1)/9) begin
        assign p0_wayEn[way][byte] = 1'b0;
        assign p1_wayEn[way][byte] = 1'b0;
      end
    end

    // Port A => Read Port
    // Port B => Write Port
    genvar  arr;
    for (arr = 0; arr <= ((port_bitwidth - 1)/36); arr = arr + 1) begin : Narrs
      RAMB36 #(.SIM_COLLISION_CHECK("NONE"), .READ_WIDTH_A(36), .READ_WIDTH_B(36), .WRITE_WIDTH_A(36), .WRITE_WIDTH_B(36), .WRITE_MODE_A("READ_FIRST"), .WRITE_MODE_B("READ_FIRST")) wayArr(
         .CASCADEOUTLATA(cascadeoutlata[arr]),
         .CASCADEOUTLATB(cascadeoutlatb[arr]),
         .CASCADEOUTREGA(cascadeoutrega[arr]),
         .CASCADEOUTREGB(cascadeoutregb[arr]),
         .DOA(p0_arr_data_out[way][(arr * 32) + 0:(arr * 32) + 31]),
         .DOB(p1_arr_data_out[way][(arr * 32) + 0:(arr * 32) + 31]),
         .DOPA(p0_arr_par_out[way][(arr * 4) + 0:(arr * 4) + 3]),
         .DOPB(p1_arr_par_out[way][(arr * 4) + 0:(arr * 4) + 3]),
         .ADDRA(ramb_rd_addr),
         .ADDRB(ramb_wr_addr),
         .CASCADEINLATA(1'b0),
         .CASCADEINLATB(1'b0),
         .CASCADEINREGA(1'b0),
         .CASCADEINREGB(1'b0),
         .CLKA(nclk[0]),
         .CLKB(nclk[0]),
         .DIA(p0_arr_data_in[way][(arr * 32) + 0:(arr * 32) + 31]),
         .DIB(p1_arr_data_in[way][(arr * 32) + 0:(arr * 32) + 31]),
         .DIPA(p0_arr_par_in[way][(arr * 4) + 0:(arr * 4) + 3]),
         .DIPB(p1_arr_par_in[way][(arr * 4) + 0:(arr * 4) + 3]),
         .ENA(rd_act[way]),
         .ENB(wr_act[way]),
         .REGCEA(1'b0),
         .REGCEB(1'b0),
         .SSRA(nclk[1]),   //sreset
         .SSRB(nclk[1]),   //sreset
         .WEA(p0_wayEn[way][(arr * 4) + 0:(arr * 4) + 3]),
         .WEB(p1_wayEn[way][(arr * 4) + 0:(arr * 4) + 3])
       );
    end
  end  //Nways

  assign abst_scan_out = 4'b0;
  assign time_scan_out = 1'b0;
  assign repr_scan_out = 1'b0;
  assign bo_pc_failout = 4'h0;
  assign bo_pc_diagloop = 4'h0;
end
endgenerate

assign unused = |({
    cascadeoutlata ,
    cascadeoutlatb ,
    cascadeoutrega ,
    cascadeoutregb ,
    nclk[0:`NCLK_WIDTH-1] ,
    gnd ,
    vdd ,
    vcs ,
    sg_0 ,
    ary_nsl_thold_0 ,
    abst_sl_thold_0 ,
    time_sl_thold_0 ,
    repr_sl_thold_0 ,
    g8t_clkoff_dc_b,
    ccflush_dc,
    scan_dis_dc_b,
    scan_diag_dc,
    g8t_d_mode_dc,
    g8t_mpw1_dc_b,
    g8t_mpw2_dc_b,
    g8t_delay_lclkr_dc,
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
    lcb_bolt_sl_thold_0,
    pc_bo_enable_2,
    pc_bo_reset,
    pc_bo_unload,
    pc_bo_repair,
    pc_bo_shdata,
    pc_bo_select,
    tri_lcb_mpw1_dc_b,
    tri_lcb_mpw2_dc_b,
    tri_lcb_delay_lclkr_dc,
    tri_lcb_clkoff_dc_b,
    tri_lcb_act_dis_dc,
    p1_data_out_swzl});

// ###############################################################
// ## Latches
// ###############################################################
tri_rlmreg_p #(.WIDTH(ways), .INIT(0), .NEEDS_SRESET(1)) rd_act_reg(
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
   .scin(siv[rd_act_offset:rd_act_offset + ways - 1]),
   .scout(sov[rd_act_offset:rd_act_offset + ways - 1]),
   .din(rd_act_d),
   .dout(rd_act_q)
);

generate begin : wayReg
  genvar way;
  for (way=0; way<ways; way=way+1) begin : wayReg
    // ###############################################################
    // ## LCB
    // ###############################################################
    tri_lcbnd  my_lcb(
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .force_t(func_sl_force),
       .nclk(nclk),
       .vd(vdd),
       .gd(gnd),
       .act(rd_act_q[way]),
       .sg(sg_0),
       .thold_b(func_sl_thold_0_b),
       .d1clk(my_d1clk[way]),
       .d2clk(my_d2clk[way]),
       .lclk(my_lclk[way])
    );

    // ###############################################################
    // ## Placed Latch
    // ###############################################################
    tri_inv_nlats #(.WIDTH(port_bitwidth), .INIT(0), .BTR("NLI0001_X4_A12TH"), .NEEDS_SRESET(0)) data_out_reg(
       .vd(vdd),
       .gd(gnd),
       .lclk(my_lclk[way]),
       .d1clk(my_d1clk[way]),
       .d2clk(my_d2clk[way]),
       .scanin(siv[data_out_offset + (port_bitwidth*way):data_out_offset + (port_bitwidth*(way+1)) - 1]),
       .scanout(sov[data_out_offset + (port_bitwidth*way):data_out_offset + (port_bitwidth*(way+1)) - 1]),
       .d(data_out_d[(way*port_bitwidth):((way+1)*port_bitwidth)-1]),
       .qb(data_out_b_q[(way*port_bitwidth):((way+1)*port_bitwidth)-1])
    );
  end
end
endgenerate

assign siv[0:(2*port_bitwidth)-1]                 = {sov[1:(2*port_bitwidth)-1], func_scan_in[0]};
assign func_scan_out[0]                           =  sov[0];
assign siv[(2*port_bitwidth):(4*port_bitwidth)-1] = {sov[(2*port_bitwidth)+1:(4*port_bitwidth)-1], func_scan_in[1]};
assign func_scan_out[1]                           =  sov[(2*port_bitwidth)];
assign siv[(4*port_bitwidth):(6*port_bitwidth)-1] = {sov[(4*port_bitwidth)+1:(6*port_bitwidth)-1], func_scan_in[3]};
assign func_scan_out[2]                           =  sov[(4*port_bitwidth)];
assign siv[(6*port_bitwidth):scan_right]          = {sov[(6*port_bitwidth)+1:scan_right], func_scan_in[3]};
assign func_scan_out[3]                           =  sov[(6*port_bitwidth)];

endmodule
