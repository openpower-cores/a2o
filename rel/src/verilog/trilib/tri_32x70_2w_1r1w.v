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
// *! FILENAME    : tri_32x70_2w_1r1w.v
// *! DESCRIPTION : 32 entry x 70 bit x 2 way array,
// *!               1 read & 1 write port
// *!
// *!****************************************************************

`include "tri_a2o.vh"

module tri_32x70_2w_1r1w(
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
   data_in,
   rd_addr,
   data_out
);
parameter                         addressable_ports = 32;		// number of addressable register in this array
parameter                         addressbus_width = 5;		// width of the bus to address all ports (2^addressbus_width >= addressable_ports)
parameter                         port_bitwidth = 70;		// bitwidth of ports
parameter                         ways = 2;		// number of ways

// POWER PINS
inout                             gnd;
inout                             vdd;
inout                             vcs;
// CLOCK and CLOCKCONTROL ports
input [0:`NCLK_WIDTH-1]           nclk;
input [0:1]                       rd_act;
input [0:1]                       wr_act;
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

// Scan
input [0:1]                       abst_scan_in;
input                             time_scan_in;
input                             repr_scan_in;
input                             func_scan_in;
output [0:1]                      abst_scan_out;
output                            time_scan_out;
output                            repr_scan_out;
output                            func_scan_out;

// BOLT-ON
input                             lcb_bolt_sl_thold_0;
input                             pc_bo_enable_2;		// general bolt-on enable
input                             pc_bo_reset;		// reset
input                             pc_bo_unload;		// unload sticky bits
input                             pc_bo_repair;		// execute sticky bit decode
input                             pc_bo_shdata;		// shift data for timing write and diag loop
input [0:1]                       pc_bo_select;		// select for mask and hier writes
output [0:1]                      bo_pc_failout;		// fail/no-fix reg
output [0:1]                      bo_pc_diagloop;
input                             tri_lcb_mpw1_dc_b;
input                             tri_lcb_mpw2_dc_b;
input                             tri_lcb_delay_lclkr_dc;
input                             tri_lcb_clkoff_dc_b;
input                             tri_lcb_act_dis_dc;

// Write Ports
input [0:ways-1]                  wr_way;
input [0:addressbus_width-1]      wr_addr;
input [0:port_bitwidth-1]         data_in;

// Read Ports
input [0:addressbus_width-1]      rd_addr;
output [0:port_bitwidth*ways-1]   data_out;

// tri_32x70_2w_1r1w

parameter                         ramb_base_width = 36;
parameter                         ramb_base_addr = 9;

// Configuration Statement for NCsim
//for all:RAMB16_S36_S36 use entity unisim.RAMB16_S36_S36;
parameter                          rd_act_offset = 0;
parameter                          data_out0_offset = rd_act_offset + 2;
parameter                          data_out1_offset = data_out0_offset + port_bitwidth - 1;
parameter                          scan_right = data_out1_offset + port_bitwidth - 1;

wire [0:port_bitwidth-1]          array_wr_data;
wire [0:35]                       ramb_data_in_l;
wire [0:35]                       ramb_data_in_r;
wire [0:35]                       ramb_data_p0_outA;
wire [0:35]                       ramb_data_p0_outB;
wire [0:35]                       ramb_data_p0_outC;
wire [0:35]                       ramb_data_p0_outD;
wire [0:35]                       ramb_data_p1_outA;
wire [0:35]                       ramb_data_p1_outB;
wire [0:35]                       ramb_data_p1_outC;
wire [0:35]                       ramb_data_p1_outD;
wire [0:ramb_base_addr-1]         ramb_addr_rd1;
wire [0:ramb_base_addr-1]         ramb_addr_wr_rd0;

wire [0:ramb_base_addr-1]         rd_addr0;
wire [0:ramb_base_addr-1]         wr_addr1;
wire                              write_enable_AB;
wire                              write_enable_CD;
wire                              tiup;
wire [0:35]                       tidn;
wire [0:1]                        act;
wire                              ary_nsl_thold_0_b;
wire [0:addressable_ports-1]      arrA_bit0_scanout;
wire [0:addressable_ports-1]      arrC_bit0_scanout;
wire [0:addressable_ports-1]      arrA_bit0_d;
wire [0:addressable_ports-1]      arrA_bit0_q;
wire [0:addressable_ports-1]      arrC_bit0_d;
wire [0:addressable_ports-1]      arrC_bit0_q;
wire [0:addressable_ports-1]      arrA_bit0_wen;
wire [0:addressable_ports-1]      arrC_bit0_wen;
reg                               arrA_bit0_out_d;
reg                               arrC_bit0_out_d;
wire                              arrA_bit0_out_q;
wire                              arrC_bit0_out_q;
wire                              arrA_bit0_out_scanout;
wire                              arrC_bit0_out_scanout;
wire [0:port_bitwidth*ways-1]     data_out_d;
wire [0:port_bitwidth*ways-1]     data_out_q;
wire [0:1]                        rd_act_d;
wire [0:1]                        rd_act_q;
wire [0:scan_right]               siv;
wire [0:scan_right]               sov;

(* analysis_not_referenced="true" *)
wire                              unused;

assign unused = | {ramb_data_p1_outA[0], ramb_data_p1_outA[35], ramb_data_p1_outB[35], ramb_data_p1_outC[0], ramb_data_p1_outC[35], ramb_data_p1_outD[35],
                   ramb_data_p0_outA, ramb_data_p0_outB, ramb_data_p0_outC, ramb_data_p0_outD, gnd, vdd, vcs,
                   sg_0, abst_sl_thold_0, ary_nsl_thold_0, time_sl_thold_0, repr_sl_thold_0, g8t_clkoff_dc_b, ccflush_dc, scan_dis_dc_b,
                   scan_diag_dc, g8t_d_mode_dc, g8t_mpw1_dc_b, g8t_mpw2_dc_b, g8t_delay_lclkr_dc, wr_abst_act, rd0_abst_act, abist_di, abist_bw_odd,
                   abist_bw_even, abist_wr_adr, abist_rd0_adr, tc_lbist_ary_wrt_thru_dc, abist_ena_1, abist_g8t_rd0_comp_ena, abist_raw_dc_b,
                   obs0_abist_cmp, abst_scan_in, time_scan_in, repr_scan_in, lcb_bolt_sl_thold_0, pc_bo_enable_2, pc_bo_reset, pc_bo_unload,
                   pc_bo_repair, pc_bo_shdata, pc_bo_select, tri_lcb_mpw1_dc_b, tri_lcb_mpw2_dc_b, tri_lcb_delay_lclkr_dc, tri_lcb_clkoff_dc_b,
                   tri_lcb_act_dis_dc, arrA_bit0_scanout, arrC_bit0_scanout, arrA_bit0_out_scanout, arrC_bit0_out_scanout};

assign tiup = 1'b1;
assign tidn = 36'b0;
assign act = rd_act | wr_act;
assign rd_act_d = rd_act;

// Data Generate
assign array_wr_data = data_in;

assign ramb_data_in_l = {array_wr_data[0:34], 1'b0};
assign ramb_data_in_r = {array_wr_data[35:69], 1'b0};

assign write_enable_AB = wr_act[0] & wr_way[0];
assign write_enable_CD = wr_act[1] & wr_way[1];

// Read/Write Port Address Generate
generate
begin
  genvar  t;
  for (t = 0; t < ramb_base_addr; t = t + 1)
  begin : rambAddrCalc
    if (t < ramb_base_addr - addressbus_width)
    begin
      assign rd_addr0[t] = 1'b0;
      assign wr_addr1[t] = 1'b0;
    end
    if (t >= ramb_base_addr - addressbus_width)
    begin
      assign rd_addr0[t] = rd_addr[t - (ramb_base_addr - addressbus_width)];
      assign wr_addr1[t] = wr_addr[t - (ramb_base_addr - addressbus_width)];
    end
  end
end
endgenerate

// Writing on PortA
// Reading on PortB
assign ramb_addr_rd1 = rd_addr0;
assign ramb_addr_wr_rd0 = wr_addr1;

assign data_out_d = {arrA_bit0_out_q, ramb_data_p1_outA[1:34], ramb_data_p1_outB[0:34], arrC_bit0_out_q, ramb_data_p1_outC[1:34], ramb_data_p1_outD[0:34]};
assign data_out   = data_out_q;

generate
   begin : arr_bit0
      genvar                                    i;
      for (i = 0; i <= addressable_ports - 1; i = i + 1)
        begin : arr_bit0
           wire [0:addressbus_width-1]         iDummy=i;
           assign arrA_bit0_wen[i] = write_enable_AB & (wr_addr == iDummy);
           assign arrC_bit0_wen[i] = write_enable_CD & (wr_addr == iDummy);
           assign arrA_bit0_d[i] = (arrA_bit0_wen[i] == 1'b1) ? array_wr_data[0] :
           	                                                   arrA_bit0_q[i];
           assign arrC_bit0_d[i] = (arrC_bit0_wen[i] == 1'b1) ? array_wr_data[0] :
           	                                                   arrC_bit0_q[i];
        end
   end
endgenerate

always @(*)
  begin: bit0_read_proc
     reg                                      rd_arrA_bit0;
     reg                                      rd_arrC_bit0;
     (* analysis_not_referenced="true" *)
     reg [0:31]                                i;
     rd_arrA_bit0     = 1'b0;
     rd_arrC_bit0     = 1'b0;
     for (i = 0; i <= addressable_ports - 1; i = i + 1)
       begin
          rd_arrA_bit0 = ((rd_addr == i[32-addressbus_width:31]) & arrA_bit0_q[i])   | rd_arrA_bit0;
          rd_arrC_bit0 = ((rd_addr == i[32-addressbus_width:31]) & arrC_bit0_q[i])   | rd_arrC_bit0;
       end
     arrA_bit0_out_d <= rd_arrA_bit0;
     arrC_bit0_out_d <= rd_arrC_bit0;
  end


assign ary_nsl_thold_0_b = ~ ary_nsl_thold_0;

tri_regk #(.WIDTH(addressable_ports), .INIT(0), .NEEDS_SRESET(1)) arrA_bit0_latch(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(write_enable_AB),
   .force_t(tidn[0]),
   .d_mode(tidn[0]),
   .delay_lclkr(tidn[0]),
   .mpw1_b(tidn[0]),
   .mpw2_b(tidn[0]),
   .thold_b(ary_nsl_thold_0_b),
   .sg(tidn[0]),
   .scin({addressable_ports{tidn[0]}}),
   .scout(arrA_bit0_scanout),
   .din(arrA_bit0_d),
   .dout(arrA_bit0_q)
);

tri_regk #(.WIDTH(addressable_ports), .INIT(0), .NEEDS_SRESET(1)) arrC_bit0_latch(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(write_enable_CD),
   .force_t(tidn[0]),
   .d_mode(tidn[0]),
   .delay_lclkr(tidn[0]),
   .mpw1_b(tidn[0]),
   .mpw2_b(tidn[0]),
   .thold_b(ary_nsl_thold_0_b),
   .sg(tidn[0]),
   .scin({addressable_ports{tidn[0]}}),
   .scout(arrC_bit0_scanout),
   .din(arrC_bit0_d),
   .dout(arrC_bit0_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) arrA_bit0_out_latch(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(tidn[0]),
   .d_mode(tidn[0]),
   .delay_lclkr(tidn[0]),
   .mpw1_b(tidn[0]),
   .mpw2_b(tidn[0]),
   .thold_b(ary_nsl_thold_0_b),
   .sg(tidn[0]),
   .scin(tidn[0]),
   .scout(arrA_bit0_out_scanout),
   .din(arrA_bit0_out_d),
   .dout(arrA_bit0_out_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) arrC_bit0_out_latch(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(tidn[0]),
   .d_mode(tidn[0]),
   .delay_lclkr(tidn[0]),
   .mpw1_b(tidn[0]),
   .mpw2_b(tidn[0]),
   .thold_b(ary_nsl_thold_0_b),
   .sg(tidn[0]),
   .scin(tidn[0]),
   .scout(arrC_bit0_out_scanout),
   .din(arrC_bit0_out_d),
   .dout(arrC_bit0_out_q)
);


RAMB16_S36_S36
    #(.SIM_COLLISION_CHECK("NONE"))   // all, none, warning_only, generate_x_only
arr0_A(
   .DOA(ramb_data_p0_outA[0:31]),
   .DOB(ramb_data_p1_outA[0:31]),
   .DOPA(ramb_data_p0_outA[32:35]),
   .DOPB(ramb_data_p1_outA[32:35]),
   .ADDRA(ramb_addr_wr_rd0),
   .ADDRB(ramb_addr_rd1),
   .CLKA(nclk[0]),
   .CLKB(nclk[0]),
   .DIA(ramb_data_in_l[0:31]),
   .DIB(tidn[0:31]),
   .DIPA(ramb_data_in_l[32:35]),
   .DIPB(tidn[32:35]),
   .ENA(act[0]),
   .ENB(act[0]),
   .SSRA(nclk[1]),   //sreset
   .SSRB(nclk[1]),   //sreset
   .WEA(write_enable_AB),
   .WEB(tidn[0])
);

RAMB16_S36_S36
    #(.SIM_COLLISION_CHECK("NONE"))   // all, none, warning_only, generate_x_only
arr1_B(
   .DOA(ramb_data_p0_outB[0:31]),
   .DOB(ramb_data_p1_outB[0:31]),
   .DOPA(ramb_data_p0_outB[32:35]),
   .DOPB(ramb_data_p1_outB[32:35]),
   .ADDRA(ramb_addr_wr_rd0),
   .ADDRB(ramb_addr_rd1),
   .CLKA(nclk[0]),
   .CLKB(nclk[0]),
   .DIA(ramb_data_in_r[0:31]),
   .DIB(tidn[0:31]),
   .DIPA(ramb_data_in_r[32:35]),
   .DIPB(tidn[32:35]),
   .ENA(act[0]),
   .ENB(act[0]),
   .SSRA(nclk[1]),
   .SSRB(nclk[1]),
   .WEA(write_enable_AB),
   .WEB(tidn[0])
);

RAMB16_S36_S36
    #(.SIM_COLLISION_CHECK("NONE"))   // all, none, warning_only, generate_x_only
arr2_C(
   .DOA(ramb_data_p0_outC[0:31]),
   .DOB(ramb_data_p1_outC[0:31]),
   .DOPA(ramb_data_p0_outC[32:35]),
   .DOPB(ramb_data_p1_outC[32:35]),
   .ADDRA(ramb_addr_wr_rd0),
   .ADDRB(ramb_addr_rd1),
   .CLKA(nclk[0]),
   .CLKB(nclk[0]),
   .DIA(ramb_data_in_l[0:31]),
   .DIB(tidn[0:31]),
   .DIPA(ramb_data_in_l[32:35]),
   .DIPB(tidn[32:35]),
   .ENA(act[1]),
   .ENB(act[1]),
   .SSRA(nclk[1]),
   .SSRB(nclk[1]),
   .WEA(write_enable_CD),
   .WEB(tidn[0])
);

RAMB16_S36_S36
    #(.SIM_COLLISION_CHECK("NONE"))   // all, none, warning_only, generate_x_only
arr3_D(
   .DOA(ramb_data_p0_outD[0:31]),
   .DOB(ramb_data_p1_outD[0:31]),
   .DOPA(ramb_data_p0_outD[32:35]),
   .DOPB(ramb_data_p1_outD[32:35]),
   .ADDRA(ramb_addr_wr_rd0),
   .ADDRB(ramb_addr_rd1),
   .CLKA(nclk[0]),
   .CLKB(nclk[0]),
   .DIA(ramb_data_in_r[0:31]),
   .DIB(tidn[0:31]),
   .DIPA(ramb_data_in_r[32:35]),
   .DIPB(tidn[32:35]),
   .ENA(act[1]),
   .ENB(act[1]),
   .SSRA(nclk[1]),
   .SSRB(nclk[1]),
   .WEA(write_enable_CD),
   .WEB(tidn[0])
);

// ####################################################
// Registers
// ####################################################

tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) rd_act_reg(
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
   .scin(siv[rd_act_offset:rd_act_offset + 2 - 1]),
   .scout(sov[rd_act_offset:rd_act_offset + 2 - 1]),
   .din(rd_act_d),
   .dout(rd_act_q)
);

tri_rlmreg_p #(.WIDTH(port_bitwidth), .INIT(0), .NEEDS_SRESET(1)) data_out0_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rd_act_q[0]),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[data_out0_offset:data_out0_offset + port_bitwidth - 1]),
   .scout(sov[data_out0_offset:data_out0_offset + port_bitwidth - 1]),
   .din(data_out_d[0:port_bitwidth - 1]),
   .dout(data_out_q[0:port_bitwidth - 1])
);

tri_rlmreg_p #(.WIDTH(port_bitwidth), .INIT(0), .NEEDS_SRESET(1)) data_out1_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rd_act_q[1]),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[data_out1_offset:data_out1_offset + port_bitwidth - 1]),
   .scout(sov[data_out1_offset:data_out1_offset + port_bitwidth - 1]),
   .din(data_out_d[port_bitwidth:2 * port_bitwidth - 1]),
   .dout(data_out_q[port_bitwidth:2 * port_bitwidth - 1])
);

assign siv[0:scan_right] = {sov[1:scan_right], func_scan_in};
assign func_scan_out = sov[0];

assign abst_scan_out = tidn[0:1];
assign time_scan_out = tidn[0];
assign repr_scan_out = tidn[0];
assign bo_pc_failout = tidn[0:1];
assign bo_pc_diagloop = tidn[0:1];
endmodule
