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

//  Description:  XU LSU Data Rotator
//
//*****************************************************************************

// ##########################################################################################
// VHDL Contents
// 1) 16 Byte Reload Rotator
// 2) 16 Byte Unaligned Rotator
// 3) Little Endian Support for 2,4,8,16 Byte Operations
// 4) Execution Pipe Store data rotation
// 5) Byte Enable Generation
// ##########################################################################################

`include "tri_a2o.vh"




module lq_data(
   ctl_dat_ex1_data_act,
   ctl_dat_ex2_eff_addr,
   ctl_dat_ex3_opsize,
   ctl_dat_ex3_le_ld_rotsel,
   ctl_dat_ex3_be_ld_rotsel,
   ctl_dat_ex3_algebraic,
   ctl_dat_ex3_le_alg_rotsel,
   ctl_dat_ex3_le_mode,
   ctl_dat_ex4_way_hit,
   xu_lq_spr_xucr0_dcdis,
   lsq_dat_stq1_stg_act,
   lsq_dat_stq1_val,
   lsq_dat_stq1_mftgpr_val,
   lsq_dat_stq1_store_val,
   lsq_dat_stq1_byte_en,
   lsq_dat_stq1_op_size,
   lsq_dat_stq1_le_mode,
   lsq_dat_stq1_addr,
   lsq_dat_stq2_blk_req,
   lsq_dat_stq2_store_data,
   lsq_dat_rel1_data_val,
   lsq_dat_rel1_qw,
   stq4_dcarr_wren,
   stq4_dcarr_way_en,
   ctl_dat_stq5_way_perr_inval,
   dat_ctl_dcarr_perr_way,
   dat_ctl_ex5_load_data,
   dat_ctl_stq6_axu_data,
   dat_lsq_stq4_128data,
   pc_lq_inj_dcache_parity,
   vdd,
   gnd,
   vcs,
   nclk,
   pc_lq_ccflush_dc,
   sg_2,
   fce_2,
   func_sl_thold_2,
   func_nsl_thold_2,
   clkoff_dc_b,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   g8t_clkoff_dc_b,
   g8t_d_mode_dc,
   g8t_delay_lclkr_dc,
   g8t_mpw1_dc_b,
   g8t_mpw2_dc_b,
   abst_sl_thold_2,
   time_sl_thold_2,
   ary_nsl_thold_2,
   repr_sl_thold_2,
   bolt_sl_thold_2,
   bo_enable_2,
   an_ac_scan_dis_dc_b,
   an_ac_scan_diag_dc,
   an_ac_lbist_ary_wrt_thru_dc,
   pc_lq_abist_ena_dc,
   pc_lq_abist_raw_dc_b,
   pc_lq_bo_unload,
   pc_lq_bo_repair,
   pc_lq_bo_reset,
   pc_lq_bo_shdata,
   pc_lq_bo_select,
   lq_pc_bo_fail,
   lq_pc_bo_diagout,
   pc_lq_abist_wl256_comp_ena,
   pc_lq_abist_g8t_wenb,
   pc_lq_abist_g8t1p_renb_0,
   pc_lq_abist_g8t_dcomp,
   pc_lq_abist_g8t_bw_1,
   pc_lq_abist_g8t_bw_0,
   pc_lq_abist_di_0,
   pc_lq_abist_waddr_0,
   pc_lq_abist_raddr_0,
   abst_scan_in,
   time_scan_in,
   repr_scan_in,
   func_scan_in,
   abst_scan_out,
   time_scan_out,
   repr_scan_out,
   func_scan_out
);

//-------------------------------------------------------------------
// Generics
//-------------------------------------------------------------------
//parameter                        EXPAND_TYPE = 2;		// 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
//parameter                        GPR_WIDTH_ENC = 6;		// Register Mode 5 = 32bit, 6 = 64bit
//parameter                        DC_SIZE = 15;		   // 2^15 = 32768 Bytes L1 D$

// Execution Pipe
input                            ctl_dat_ex1_data_act;
input [52:59]                    ctl_dat_ex2_eff_addr;
input [0:4]                      ctl_dat_ex3_opsize;
input [0:3]                      ctl_dat_ex3_le_ld_rotsel;
input [0:3]                      ctl_dat_ex3_be_ld_rotsel;
input                            ctl_dat_ex3_algebraic;
input [0:3]                      ctl_dat_ex3_le_alg_rotsel;
input                            ctl_dat_ex3_le_mode;
input [0:7]                      ctl_dat_ex4_way_hit;		// Way Hit

// Config Bits
input                            xu_lq_spr_xucr0_dcdis;

// RELOAD/STORE PIPE
input                            lsq_dat_stq1_stg_act;
input                            lsq_dat_stq1_val;
input                            lsq_dat_stq1_mftgpr_val;
input                            lsq_dat_stq1_store_val;
input [0:15]                     lsq_dat_stq1_byte_en;
input [0:2]                      lsq_dat_stq1_op_size;
input                            lsq_dat_stq1_le_mode;
input [52:63]                    lsq_dat_stq1_addr;
input                            lsq_dat_stq2_blk_req;
input [0:143]                    lsq_dat_stq2_store_data;
input                            lsq_dat_rel1_data_val;
input [57:59]                    lsq_dat_rel1_qw;

// L1 D$ update Enable
input                            stq4_dcarr_wren;
input [0:7]                      stq4_dcarr_way_en;
input [0:7]                      ctl_dat_stq5_way_perr_inval;

// Execution/Store Commit Pipe Outputs
output [0:7]                     dat_ctl_dcarr_perr_way;		// Load Data Way Parity Error

//Rotated Data
output [(128-`STQ_DATA_SIZE):127] dat_ctl_ex5_load_data;
output [(128-`STQ_DATA_SIZE):127] dat_ctl_stq6_axu_data;

// Debug Data Compare
output [0:127]                   dat_lsq_stq4_128data;

// Error Inject
input                            pc_lq_inj_dcache_parity;

//pervasive
inout                            vcs;
inout                            vdd;
inout                            gnd;
(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)
input [0:`NCLK_WIDTH-1]          nclk;
input                            pc_lq_ccflush_dc;
input                            sg_2;
input                            fce_2;
input                            func_sl_thold_2;
input                            func_nsl_thold_2;
input                            clkoff_dc_b;
input                            d_mode_dc;
input                            delay_lclkr_dc;
input                            mpw1_dc_b;
input                            mpw2_dc_b;
input                            g8t_clkoff_dc_b;
input                            g8t_d_mode_dc;
input [0:4]                      g8t_delay_lclkr_dc;
input [0:4]                      g8t_mpw1_dc_b;
input                            g8t_mpw2_dc_b;
input                            abst_sl_thold_2;
input                            time_sl_thold_2;
input                            ary_nsl_thold_2;
input                            repr_sl_thold_2;
input                            bolt_sl_thold_2;
input                            bo_enable_2;
input                            an_ac_scan_dis_dc_b;
input                            an_ac_scan_diag_dc;
input                            an_ac_lbist_ary_wrt_thru_dc;
input                            pc_lq_abist_ena_dc;
input                            pc_lq_abist_raw_dc_b;
input                            pc_lq_bo_unload;
input                            pc_lq_bo_repair;
input                            pc_lq_bo_reset;
input                            pc_lq_bo_shdata;
input [0:3]                      pc_lq_bo_select;
output [0:3]                     lq_pc_bo_fail;
output [0:3]                     lq_pc_bo_diagout;

// G8T ABIST Control
input                            pc_lq_abist_wl256_comp_ena;
input                            pc_lq_abist_g8t_wenb;
input                            pc_lq_abist_g8t1p_renb_0;
input [0:3]                      pc_lq_abist_g8t_dcomp;
input                            pc_lq_abist_g8t_bw_1;
input                            pc_lq_abist_g8t_bw_0;
input [0:3]                      pc_lq_abist_di_0;
input [2:9]                      pc_lq_abist_waddr_0;
input [1:8]                      pc_lq_abist_raddr_0;

// SCAN Ports
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input [0:3]                      abst_scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input                            time_scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input                            repr_scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input [0:6]                      func_scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output [0:3]                     abst_scan_out;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output                           time_scan_out;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output                           repr_scan_out;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output [0:6]                     func_scan_out;

//--------------------------
// constants
//--------------------------
parameter                        inj_dcache_parity_offset = 0;
parameter                        spr_xucr0_dcdis_offset = inj_dcache_parity_offset + 1;
parameter                        stq6_rot_data_offset = spr_xucr0_dcdis_offset + 1;
parameter                        ex2_stg_act_offset = stq6_rot_data_offset + `STQ_DATA_SIZE;
parameter                        ex3_stg_act_offset = ex2_stg_act_offset + 1;
parameter                        ex4_stg_act_offset = ex3_stg_act_offset + 1;
parameter                        stq2_stg_act_offset = ex4_stg_act_offset + 1;
parameter                        stq3_stg_act_offset = stq2_stg_act_offset + 1;
parameter                        stq4_stg_act_offset = stq3_stg_act_offset + 1;
parameter                        stq5_stg_act_offset = stq4_stg_act_offset + 1;
parameter                        stq5_rot_data_reg_offset = stq5_stg_act_offset + 1;
parameter                        scan_right = stq5_rot_data_reg_offset + `STQ_DATA_SIZE - 1;

//--------------------------
// signals
//--------------------------
wire [(128-`STQ_DATA_SIZE):127]  ex5_ld_hit_data;
wire                             spr_xucr0_dcdis_d;
wire                             spr_xucr0_dcdis_q;
wire [0:143]                     stq6_rd_data_wa;
wire [0:143]                     stq6_rd_data_wb;
wire [0:143]                     stq6_rd_data_wc;
wire [0:143]                     stq6_rd_data_wd;
wire [0:143]                     stq6_rd_data_we;
wire [0:143]                     stq6_rd_data_wf;
wire [0:143]                     stq6_rd_data_wg;
wire [0:143]                     stq6_rd_data_wh;
wire [0:3]                       stq7_byp_val_wabcd;
wire [0:3]                       stq7_byp_val_wefgh;
wire [0:143]                     stq7_byp_data_wabcd;
wire [0:143]                     stq7_byp_data_wefgh;
wire [0:143]                     stq8_byp_data_wabcd;
wire [0:143]                     stq8_byp_data_wefgh;
wire [0:3]                       stq_byp_val_wabcd;
wire [0:3]                       stq_byp_val_wefgh;
wire [(128-`STQ_DATA_SIZE):127]  stq4_rot_data;
wire [(128-`STQ_DATA_SIZE):127]  stq5_rot_data_d;
wire [(128-`STQ_DATA_SIZE):127]  stq5_rot_data_q;
wire [(128-`STQ_DATA_SIZE):127]  stq6_rot_data_d;
wire [(128-`STQ_DATA_SIZE):127]  stq6_rot_data_q;
wire [52:59]                     dcarr_rd_addr;
wire [0:1151]                    dcarr_rd_data;
wire [0:7]                       dcarr_wr_way;
wire [52:59]                     dcarr_wr_addr;
wire [0:143]                     dcarr_wr_data_wabcd;
wire [0:143]                     dcarr_wr_data_wefgh;
wire                             inj_dcache_parity_d;
wire                             inj_dcache_parity_q;
wire [0:7]                       dcarr_data_perr_way;

wire [0:7]                       dcarr_rd_stg_act;
wire [0:7]                       dcarr_wr_stg_act;
wire                             ex2_stg_act_d;
wire                             ex2_stg_act_q;
wire                             ex3_stg_act_d;
wire                             ex3_stg_act_q;
wire                             ex4_stg_act_d;
wire                             ex4_stg_act_q;
wire                             stq1_stg_act;
wire                             stq2_stg_act_d;
wire                             stq2_stg_act_q;
wire                             stq3_stg_act_d;
wire                             stq3_stg_act_q;
wire                             stq4_stg_act_d;
wire                             stq4_stg_act_q;
wire                             stq5_stg_act_d;
wire                             stq5_stg_act_q;
wire [0:3]                       abst_scan_in_q;
wire [0:3]                       abst_scan_out_int;
wire [0:3]                       abst_scan_out_q;
wire                             time_scan_in_q;
wire                             time_scan_out_int;
wire                             time_scan_out_q;
wire                             repr_scan_in_q;
wire                             repr_scan_out_int;
wire                             repr_scan_out_q;
wire [0:6]                       func_scan_in_q;
wire [0:6]                       func_scan_out_int;
wire [0:6]                       func_scan_out_q;
wire                             tiup;
wire                             tidn;
wire                             func_nsl_thold_1;
wire                             func_sl_thold_1;
wire                             sg_1;
wire                             fce_1;
wire                             func_nsl_thold_0;
wire                             func_sl_thold_0;
wire                             sg_0;
wire                             fce_0;
wire                             func_sl_force;
wire                             func_sl_thold_0_b;
wire                             func_nsl_force;
wire                             func_nsl_thold_0_b;
wire [0:scan_right]              siv;
wire [0:scan_right]              sov;
wire [0:29]                      abist_siv;
wire [0:29]                      abist_sov;
wire                             abst_sl_thold_1;
wire                             time_sl_thold_1;
wire                             ary_nsl_thold_1;
wire                             repr_sl_thold_1;
wire                             bolt_sl_thold_1;
wire                             abst_sl_thold_0;
wire                             time_sl_thold_0;
wire                             ary_nsl_thold_0;
wire                             repr_sl_thold_0;
wire                             bolt_sl_thold_0;
wire                             abst_sl_thold_0_b;
wire                             abst_sl_force;
wire                             pc_lq_abist_g8t_bw_0_q;
wire                             pc_lq_abist_g8t_bw_1_q;
wire [0:3]                       pc_lq_abist_di_0_q;
wire                             pc_lq_abist_wl256_comp_ena_q;
wire [0:3]                       pc_lq_abist_g8t_dcomp_q;
wire [2:9]                       pc_lq_abist_waddr_0_q;
wire [1:8]                       pc_lq_abist_raddr_0_q;
wire                             pc_lq_abist_g8t_wenb_q;
wire                             pc_lq_abist_g8t1p_renb_0_q;
wire                             slat_force;
wire                             abst_slat_thold_b;
wire                             abst_slat_d2clk;
wire  [0:`NCLK_WIDTH-1]          abst_slat_lclk;
wire                             time_slat_thold_b;
wire                             time_slat_d2clk;
wire  [0:`NCLK_WIDTH-1]          time_slat_lclk;
wire                             repr_slat_thold_b;
wire                             repr_slat_d2clk;
wire  [0:`NCLK_WIDTH-1]          repr_slat_lclk;
wire                             func_slat_thold_b;
wire                             func_slat_d2clk;
wire  [0:`NCLK_WIDTH-1]          func_slat_lclk;
wire [0:7]                       abst_scan_q;
wire [0:7]                       abst_scan_q_b;
wire [0:1]                       time_scan_q;
wire [0:1]                       time_scan_q_b;
wire [0:1]                       repr_scan_q;
wire [0:1]                       repr_scan_q_b;
wire [0:13]                      func_scan_q;
wire [0:13]                      func_scan_q_b;
wire [1:4]                       dat_scan_out_int;

(* analysis_not_referenced="true" *)
wire                             unused;

assign tiup = 1'b1;
assign tidn = 1'b0;
assign unused = |abst_scan_q | |abst_scan_q_b | |time_scan_q | |time_scan_q_b |
                |repr_scan_q | |repr_scan_q_b | |func_scan_q | |func_scan_q_b;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// ACT's
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign ex2_stg_act_d = ctl_dat_ex1_data_act;
assign ex3_stg_act_d = ex2_stg_act_q;
assign ex4_stg_act_d = ex3_stg_act_q;

assign stq1_stg_act = lsq_dat_stq1_stg_act;
assign stq2_stg_act_d = stq1_stg_act;
assign stq3_stg_act_d = stq2_stg_act_q & ~lsq_dat_stq2_blk_req;
assign stq4_stg_act_d = stq3_stg_act_q;
assign stq5_stg_act_d = stq4_stg_act_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Inputs
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

assign spr_xucr0_dcdis_d = xu_lq_spr_xucr0_dcdis;
assign inj_dcache_parity_d = pc_lq_inj_dcache_parity;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Reload/Store Data Rotator
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
lq_data_st  l1dcst(

   // Load Address
   .ex2_stg_act(ex2_stg_act_q),
   .ctl_dat_ex2_eff_addr(ctl_dat_ex2_eff_addr),

   // SPR
   .spr_xucr0_dcdis(spr_xucr0_dcdis_q),

   //Store/Reload path
   .lsq_dat_stq1_stg_act(lsq_dat_stq1_stg_act),
   .lsq_dat_stq1_val(lsq_dat_stq1_val),
   .lsq_dat_stq1_mftgpr_val(lsq_dat_stq1_mftgpr_val),
   .lsq_dat_stq1_store_val(lsq_dat_stq1_store_val),
   .lsq_dat_stq1_byte_en(lsq_dat_stq1_byte_en),
   .lsq_dat_stq1_op_size(lsq_dat_stq1_op_size),
   .lsq_dat_stq1_le_mode(lsq_dat_stq1_le_mode),
   .lsq_dat_stq1_addr(lsq_dat_stq1_addr),
   .lsq_dat_stq2_blk_req(lsq_dat_stq2_blk_req),
   .lsq_dat_rel1_data_val(lsq_dat_rel1_data_val),
   .lsq_dat_rel1_qw(lsq_dat_rel1_qw),
   .lsq_dat_stq2_store_data(lsq_dat_stq2_store_data),

   // Read-Modify-Write Path Read data
   .stq6_rd_data_wa(stq6_rd_data_wa),
   .stq6_rd_data_wb(stq6_rd_data_wb),
   .stq6_rd_data_wc(stq6_rd_data_wc),
   .stq6_rd_data_wd(stq6_rd_data_wd),
   .stq6_rd_data_we(stq6_rd_data_we),
   .stq6_rd_data_wf(stq6_rd_data_wf),
   .stq6_rd_data_wg(stq6_rd_data_wg),
   .stq6_rd_data_wh(stq6_rd_data_wh),

   // Rotated Data
   .stq4_rot_data(stq4_rot_data),

   // L2 Store Data
   .dat_lsq_stq4_128data(dat_lsq_stq4_128data),

   // EX4 Load Bypass Data for Read/Write Collision detected in EX2
   .stq7_byp_val_wabcd(stq7_byp_val_wabcd),
   .stq7_byp_val_wefgh(stq7_byp_val_wefgh),
   .stq7_byp_data_wabcd(stq7_byp_data_wabcd),
   .stq7_byp_data_wefgh(stq7_byp_data_wefgh),
   .stq8_byp_data_wabcd(stq8_byp_data_wabcd),
   .stq8_byp_data_wefgh(stq8_byp_data_wefgh),
   .stq_byp_val_wabcd(stq_byp_val_wabcd),
   .stq_byp_val_wefgh(stq_byp_val_wefgh),

   // D$ Array Write Control
   .stq4_dcarr_wren(stq4_dcarr_wren),
   .stq4_dcarr_way_en(stq4_dcarr_way_en),
   .ctl_dat_stq5_way_perr_inval(ctl_dat_stq5_way_perr_inval),

   // D$ Array
   .dcarr_rd_stg_act(dcarr_rd_stg_act),
   .dcarr_rd_addr(dcarr_rd_addr),
   .dcarr_wr_stg_act(dcarr_wr_stg_act),
   .dcarr_wr_way(dcarr_wr_way),
   .dcarr_wr_addr(dcarr_wr_addr),
   .dcarr_wr_data_wabcd(dcarr_wr_data_wabcd),
   .dcarr_wr_data_wefgh(dcarr_wr_data_wefgh),

   // Pervasive
   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .sg_0(sg_0),
   .func_sl_thold_0_b(func_sl_thold_0_b),
   .func_sl_force(func_sl_force),
   .func_nsl_thold_0_b(func_nsl_thold_0_b),
   .func_nsl_force(func_nsl_force),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc),
   .mpw1_dc_b(mpw1_dc_b),
   .mpw2_dc_b(mpw2_dc_b),
   .scan_in(func_scan_in_q[6]),
   .scan_out(func_scan_out_int[6])
);

assign stq5_rot_data_d = stq4_rot_data;
assign stq6_rot_data_d = stq5_rot_data_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// L1 D-Cache Array
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

generate if ((2 ** `DC_SIZE) == 32768) begin : dc32K
   // number of addressable register in this array
   // width of the bus to address all ports (2^addressbus_width >= addressable_ports)
   // bitwidth of ports (per way)
   // gives the number of bits that shares one write-enable; must divide evenly into array
   // number of ways
   tri_256x144_8w_1r1w #(.addressable_ports(256), .addressbus_width(8), .port_bitwidth(144), .bit_write_type(9), .ways(8)) tridcarr(
      // POWER PINS
      .vcs(vcs),
      .vdd(vdd),
      .gnd(gnd),

      // CLOCK AND CLOCKCONTROL PORTS
      .nclk(nclk),
      .wr_act(dcarr_wr_stg_act),
      .rd_act(dcarr_rd_stg_act),
      .sg_0(sg_0),
      .ary_nsl_thold_0(ary_nsl_thold_0),
      .abst_sl_thold_0(abst_sl_thold_0),
      .time_sl_thold_0(time_sl_thold_0),
      .repr_sl_thold_0(repr_sl_thold_0),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .g8t_clkoff_dc_b(g8t_clkoff_dc_b),
      .ccflush_dc(pc_lq_ccflush_dc),
      .scan_dis_dc_b(an_ac_scan_dis_dc_b),
      .scan_diag_dc(an_ac_scan_diag_dc),
      .g8t_d_mode_dc(g8t_d_mode_dc),
      .g8t_mpw1_dc_b(g8t_mpw1_dc_b),
      .g8t_mpw2_dc_b(g8t_mpw2_dc_b),
      .g8t_delay_lclkr_dc(g8t_delay_lclkr_dc),
      .d_mode_dc(d_mode_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .delay_lclkr_dc(delay_lclkr_dc),

      // ABIST
      .wr_abst_act(pc_lq_abist_g8t_wenb_q),
      .rd0_abst_act(pc_lq_abist_g8t1p_renb_0_q),
      .abist_di(pc_lq_abist_di_0_q),
      .abist_bw_odd(pc_lq_abist_g8t_bw_1_q),
      .abist_bw_even(pc_lq_abist_g8t_bw_0_q),
      .abist_wr_adr(pc_lq_abist_waddr_0_q),
      .abist_rd0_adr(pc_lq_abist_raddr_0_q),
      .tc_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
      .abist_ena_1(pc_lq_abist_ena_dc),
      .abist_g8t_rd0_comp_ena(pc_lq_abist_wl256_comp_ena_q),
      .abist_raw_dc_b(pc_lq_abist_raw_dc_b),
      .obs0_abist_cmp(pc_lq_abist_g8t_dcomp_q),

      // SCAN PORTS
      .abst_scan_in({abist_siv[0], abst_scan_in_q[1], abst_scan_in_q[2], abst_scan_in_q[3]}),
      .time_scan_in(time_scan_in_q),
      .repr_scan_in(repr_scan_in_q),
      .func_scan_in(func_scan_in_q[1:4]),
      .abst_scan_out({abist_sov[0], abst_scan_out_int[1], abst_scan_out_int[2], abst_scan_out_int[3]}),
      .time_scan_out(time_scan_out_int),
      .repr_scan_out(repr_scan_out_int),
      .func_scan_out(dat_scan_out_int[1:4]),

      // BOLT-ON
      .lcb_bolt_sl_thold_0(bolt_sl_thold_0),
      .pc_bo_enable_2(bo_enable_2),
      .pc_bo_reset(pc_lq_bo_reset),
      .pc_bo_unload(pc_lq_bo_unload),
      .pc_bo_repair(pc_lq_bo_repair),
      .pc_bo_shdata(pc_lq_bo_shdata),
      .pc_bo_select(pc_lq_bo_select),
      .bo_pc_failout(lq_pc_bo_fail),
      .bo_pc_diagloop(lq_pc_bo_diagout),
      .tri_lcb_mpw1_dc_b(mpw1_dc_b),
      .tri_lcb_mpw2_dc_b(mpw2_dc_b),
      .tri_lcb_delay_lclkr_dc(delay_lclkr_dc),
      .tri_lcb_clkoff_dc_b(clkoff_dc_b),
      .tri_lcb_act_dis_dc(tidn),

      // FUNCTIONAL PORTS
      .wr_way(dcarr_wr_way),
      .wr_addr(dcarr_wr_addr),
      .data_in0(dcarr_wr_data_wabcd),
      .data_in1(dcarr_wr_data_wefgh),
      .rd_addr(dcarr_rd_addr),
      .data_out(dcarr_rd_data)
   );
end
endgenerate

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Load Rotator
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
lq_data_ld  l1dcld(

   // ACT
   .ex3_stg_act(ex3_stg_act_q),
   .ex4_stg_act(ex4_stg_act_q),

   // Execution Pipe Load Data Rotator Controls
   .ctl_dat_ex3_opsize(ctl_dat_ex3_opsize),
   .ctl_dat_ex3_le_ld_rotsel(ctl_dat_ex3_le_ld_rotsel),
   .ctl_dat_ex3_be_ld_rotsel(ctl_dat_ex3_be_ld_rotsel),
   .ctl_dat_ex3_algebraic(ctl_dat_ex3_algebraic),
   .ctl_dat_ex3_le_alg_rotsel(ctl_dat_ex3_le_alg_rotsel),
   .ctl_dat_ex3_le_mode(ctl_dat_ex3_le_mode),

   // D$ Array Read Data
   .dcarr_rd_data(dcarr_rd_data),

   // EX4 Load Bypass Data for Read/Write Collision detected in EX2
   .stq7_byp_val_wabcd(stq7_byp_val_wabcd),
   .stq7_byp_val_wefgh(stq7_byp_val_wefgh),
   .stq7_byp_data_wabcd(stq7_byp_data_wabcd),
   .stq7_byp_data_wefgh(stq7_byp_data_wefgh),
   .stq8_byp_data_wabcd(stq8_byp_data_wabcd),
   .stq8_byp_data_wefgh(stq8_byp_data_wefgh),
   .stq_byp_val_wabcd(stq_byp_val_wabcd),
   .stq_byp_val_wefgh(stq_byp_val_wefgh),

   // Load Control
   .ctl_dat_ex4_way_hit(ctl_dat_ex4_way_hit),

   // Parity Error Inject
   .inj_dcache_parity(inj_dcache_parity_q),

   // Data Cache Array Parity Error Detected
   .dcarr_data_perr_way(dcarr_data_perr_way),

   // Rotated Data
   .ex5_ld_hit_data(ex5_ld_hit_data),

   // Read-Modify-Write Path Read data
   .stq6_rd_data_wa(stq6_rd_data_wa),
   .stq6_rd_data_wb(stq6_rd_data_wb),
   .stq6_rd_data_wc(stq6_rd_data_wc),
   .stq6_rd_data_wd(stq6_rd_data_wd),
   .stq6_rd_data_we(stq6_rd_data_we),
   .stq6_rd_data_wf(stq6_rd_data_wf),
   .stq6_rd_data_wg(stq6_rd_data_wg),
   .stq6_rd_data_wh(stq6_rd_data_wh),

   // Pervasive
   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .sg_0(sg_0),
   .func_sl_thold_0_b(func_sl_thold_0_b),
   .func_sl_force(func_sl_force),
   .func_nsl_thold_0_b(func_nsl_thold_0_b),
   .func_nsl_force(func_nsl_force),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc),
   .mpw1_dc_b(mpw1_dc_b),
   .mpw2_dc_b(mpw2_dc_b),
   .scan_in({func_scan_in_q[0],dat_scan_out_int[1:4]}),
   .scan_out(func_scan_out_int[0:4])
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Outputs
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// D$ Parity Error Detected
assign dat_ctl_dcarr_perr_way = dcarr_data_perr_way;

// XU data
assign dat_ctl_ex5_load_data = ex5_ld_hit_data;

// AXU Reload data
assign dat_ctl_stq6_axu_data = stq6_rot_data_q;

// SCAN OUT Gate
assign abst_scan_out = abst_scan_out_q & {4{an_ac_scan_dis_dc_b}};
assign time_scan_out = time_scan_out_q & an_ac_scan_dis_dc_b;
assign repr_scan_out = repr_scan_out_q & an_ac_scan_dis_dc_b;
assign func_scan_out = func_scan_out_q & {7{an_ac_scan_dis_dc_b}};

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Registers
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) inj_dcache_parity_reg(
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
   .scin(siv[inj_dcache_parity_offset]),
   .scout(sov[inj_dcache_parity_offset]),
   .din(inj_dcache_parity_d),
   .dout(inj_dcache_parity_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_dcdis_reg(
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
   .scin(siv[spr_xucr0_dcdis_offset]),
   .scout(sov[spr_xucr0_dcdis_offset]),
   .din(spr_xucr0_dcdis_d),
   .dout(spr_xucr0_dcdis_q)
);

tri_regk #(.WIDTH(`STQ_DATA_SIZE), .INIT(0), .NEEDS_SRESET(1)) stq5_rot_data_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq5_rot_data_reg_offset:stq5_rot_data_reg_offset + `STQ_DATA_SIZE - 1]),
   .scout(sov[stq5_rot_data_reg_offset:stq5_rot_data_reg_offset + `STQ_DATA_SIZE - 1]),
   .din(stq5_rot_data_d),
   .dout(stq5_rot_data_q)
);


tri_rlmreg_p #(.WIDTH(`STQ_DATA_SIZE), .INIT(0), .NEEDS_SRESET(1)) stq6_rot_data_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_rot_data_offset:stq6_rot_data_offset + `STQ_DATA_SIZE - 1]),
   .scout(sov[stq6_rot_data_offset:stq6_rot_data_offset + `STQ_DATA_SIZE - 1]),
   .din(stq6_rot_data_d),
   .dout(stq6_rot_data_q)
);

//---------------------------------------------------------------------
// ACT's
//---------------------------------------------------------------------

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_stg_act_reg(
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
   .scin(siv[ex2_stg_act_offset]),
   .scout(sov[ex2_stg_act_offset]),
   .din(ex2_stg_act_d),
   .dout(ex2_stg_act_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_stg_act_reg(
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
   .scin(siv[ex3_stg_act_offset]),
   .scout(sov[ex3_stg_act_offset]),
   .din(ex3_stg_act_d),
   .dout(ex3_stg_act_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_stg_act_reg(
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
   .scin(siv[ex4_stg_act_offset]),
   .scout(sov[ex4_stg_act_offset]),
   .din(ex4_stg_act_d),
   .dout(ex4_stg_act_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_stg_act_reg(
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
   .scin(siv[stq2_stg_act_offset]),
   .scout(sov[stq2_stg_act_offset]),
   .din(stq2_stg_act_d),
   .dout(stq2_stg_act_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq3_stg_act_reg(
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
   .scin(siv[stq3_stg_act_offset]),
   .scout(sov[stq3_stg_act_offset]),
   .din(stq3_stg_act_d),
   .dout(stq3_stg_act_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_stg_act_reg(
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
   .scin(siv[stq4_stg_act_offset]),
   .scout(sov[stq4_stg_act_offset]),
   .din(stq4_stg_act_d),
   .dout(stq4_stg_act_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq5_stg_act_reg(
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
   .scin(siv[stq5_stg_act_offset]),
   .scout(sov[stq5_stg_act_offset]),
   .din(stq5_stg_act_d),
   .dout(stq5_stg_act_q)
);

//---------------------------------------------------------------------
// abist latches
//---------------------------------------------------------------------
tri_rlmreg_p #(.INIT(0), .WIDTH(29), .NEEDS_SRESET(1)) abist0_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(pc_lq_abist_ena_dc),
   .thold_b(abst_sl_thold_0_b),
   .sg(sg_0),
   .force_t(abst_sl_force),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .d_mode(d_mode_dc),
   .scin(abist_siv[1:29]),
   .scout(abist_sov[1:29]),
   .din({pc_lq_abist_g8t_bw_0,
         pc_lq_abist_g8t_bw_1,
         pc_lq_abist_di_0,
         pc_lq_abist_wl256_comp_ena,
         pc_lq_abist_g8t_dcomp,
         pc_lq_abist_raddr_0,
         pc_lq_abist_waddr_0,
         pc_lq_abist_g8t_wenb,
         pc_lq_abist_g8t1p_renb_0}),
   .dout({pc_lq_abist_g8t_bw_0_q,
          pc_lq_abist_g8t_bw_1_q,
          pc_lq_abist_di_0_q,
          pc_lq_abist_wl256_comp_ena_q,
          pc_lq_abist_g8t_dcomp_q,
          pc_lq_abist_raddr_0_q,
          pc_lq_abist_waddr_0_q,
          pc_lq_abist_g8t_wenb_q,
          pc_lq_abist_g8t1p_renb_0_q})
);

//-----------------------------------------------
// Pervasive
//-----------------------------------------------

tri_plat #(.WIDTH(9)) perv_2to1_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .flush(pc_lq_ccflush_dc),
   .din({func_nsl_thold_2,
         func_sl_thold_2,
         ary_nsl_thold_2,
         abst_sl_thold_2,
         time_sl_thold_2,
         repr_sl_thold_2,
         bolt_sl_thold_2,
         sg_2,
         fce_2}),
   .q({func_nsl_thold_1,
       func_sl_thold_1,
       ary_nsl_thold_1,
       abst_sl_thold_1,
       time_sl_thold_1,
       repr_sl_thold_1,
       bolt_sl_thold_1,
       sg_1,
       fce_1})
);


tri_plat #(.WIDTH(9)) perv_1to0_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .flush(pc_lq_ccflush_dc),
   .din({func_nsl_thold_1,
         func_sl_thold_1,
         ary_nsl_thold_1,
         abst_sl_thold_1,
         time_sl_thold_1,
         repr_sl_thold_1,
         bolt_sl_thold_1,
         sg_1,
         fce_1}),
   .q({func_nsl_thold_0,
       func_sl_thold_0,
       ary_nsl_thold_0,
       abst_sl_thold_0,
       time_sl_thold_0,
       repr_sl_thold_0,
       bolt_sl_thold_0,
       sg_0,
       fce_0})
);


tri_lcbor  perv_lcbor_func_sl(
   .clkoff_b(clkoff_dc_b),
   .thold(func_sl_thold_0),
   .sg(sg_0),
   .act_dis(tidn),
   .force_t(func_sl_force),
   .thold_b(func_sl_thold_0_b)
);


tri_lcbor  perv_lcbor_func_nsl(
   .clkoff_b(clkoff_dc_b),
   .thold(func_nsl_thold_0),
   .sg(fce_0),
   .act_dis(tidn),
   .force_t(func_nsl_force),
   .thold_b(func_nsl_thold_0_b)
);


tri_lcbor  perv_lcbor_abst_sl(
   .clkoff_b(clkoff_dc_b),
   .thold(abst_sl_thold_0),
   .sg(sg_0),
   .act_dis(tidn),
   .force_t(abst_sl_force),
   .thold_b(abst_sl_thold_0_b)
);

// LCBs for scan only staging latches
assign slat_force = sg_0;
assign abst_slat_thold_b = (~abst_sl_thold_0);
assign time_slat_thold_b = (~time_sl_thold_0);
assign repr_slat_thold_b = (~repr_sl_thold_0);
assign func_slat_thold_b = (~func_sl_thold_0);


tri_lcbs  perv_lcbs_abst(
   .vd(vdd),
   .gd(gnd),
   .delay_lclkr(delay_lclkr_dc),
   .nclk(nclk),
   .force_t(slat_force),
   .thold_b(abst_slat_thold_b),
   .dclk(abst_slat_d2clk),
   .lclk(abst_slat_lclk)
);


tri_slat_scan #(.WIDTH(8), .INIT(8'b00000000)) perv_abst_stg(
   .vd(vdd),
   .gd(gnd),
   .dclk(abst_slat_d2clk),
   .lclk(abst_slat_lclk),
   .scan_in({abst_scan_in, abst_scan_out_int}),
   .scan_out({abst_scan_in_q, abst_scan_out_q}),
   .q(abst_scan_q),
   .q_b(abst_scan_q_b)
);


tri_lcbs  perv_lcbs_time(
   .vd(vdd),
   .gd(gnd),
   .delay_lclkr(delay_lclkr_dc),
   .nclk(nclk),
   .force_t(slat_force),
   .thold_b(time_slat_thold_b),
   .dclk(time_slat_d2clk),
   .lclk(time_slat_lclk)
);


tri_slat_scan #(.WIDTH(2), .INIT(2'b00)) perv_time_stg(
   .vd(vdd),
   .gd(gnd),
   .dclk(time_slat_d2clk),
   .lclk(time_slat_lclk),
   .scan_in({time_scan_in, time_scan_out_int}),
   .scan_out({time_scan_in_q, time_scan_out_q}),
   .q(time_scan_q),
   .q_b(time_scan_q_b)
);


tri_lcbs  perv_lcbs_repr(
   .vd(vdd),
   .gd(gnd),
   .delay_lclkr(delay_lclkr_dc),
   .nclk(nclk),
   .force_t(slat_force),
   .thold_b(repr_slat_thold_b),
   .dclk(repr_slat_d2clk),
   .lclk(repr_slat_lclk)
);


tri_slat_scan #(.WIDTH(2), .INIT(2'b00)) perv_repr_stg(
   .vd(vdd),
   .gd(gnd),
   .dclk(repr_slat_d2clk),
   .lclk(repr_slat_lclk),
   .scan_in({repr_scan_in, repr_scan_out_int}),
   .scan_out({repr_scan_in_q, repr_scan_out_q}),
   .q(repr_scan_q),
   .q_b(repr_scan_q_b)
);


tri_lcbs  perv_lcbs_func(
   .vd(vdd),
   .gd(gnd),
   .delay_lclkr(delay_lclkr_dc),
   .nclk(nclk),
   .force_t(slat_force),
   .thold_b(func_slat_thold_b),
   .dclk(func_slat_d2clk),
   .lclk(func_slat_lclk)
);


tri_slat_scan #(.WIDTH(14), .INIT(14'b00000000000000)) perv_func_stg(
   .vd(vdd),
   .gd(gnd),
   .dclk(func_slat_d2clk),
   .lclk(func_slat_lclk),
   .scan_in({func_scan_in[0],
             func_scan_in[1],
             func_scan_in[2],
             func_scan_in[3],
             func_scan_in[4],
             func_scan_in[5],
             func_scan_in[6],
             func_scan_out_int[0],
             func_scan_out_int[1],
             func_scan_out_int[2],
             func_scan_out_int[3],
             func_scan_out_int[4],
             func_scan_out_int[5],
             func_scan_out_int[6]}),
   .scan_out({func_scan_in_q[0],
              func_scan_in_q[1],
              func_scan_in_q[2],
              func_scan_in_q[3],
              func_scan_in_q[4],
              func_scan_in_q[5],
              func_scan_in_q[6],
              func_scan_out_q[0],
              func_scan_out_q[1],
              func_scan_out_q[2],
              func_scan_out_q[3],
              func_scan_out_q[4],
              func_scan_out_q[5],
              func_scan_out_q[6]}),
   .q(func_scan_q),
   .q_b(func_scan_q_b)
);

assign siv[0:scan_right] = {sov[1:scan_right], func_scan_in_q[5]};
assign func_scan_out_int[5] = sov[0];

assign abist_siv = {abist_sov[1:29], abst_scan_in_q[0]};
assign abst_scan_out_int[0] = abist_sov[0];

endmodule
