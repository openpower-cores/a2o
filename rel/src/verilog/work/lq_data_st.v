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

//  Description:  XU LSU Store Data Rotator Wrapper
//
//*****************************************************************************

// ##########################################################################################
// VHDL Contents
// 1) 16 Byte Unaligned Rotator
// 2) Little Endian Support for 2,4,8,16 Byte Operations
// 3) Byte Enable Generation
// ##########################################################################################

`include "tri_a2o.vh"


module lq_data_st(
   ex2_stg_act,
   ctl_dat_ex2_eff_addr,
   spr_xucr0_dcdis,
   lsq_dat_stq1_stg_act,
   lsq_dat_stq1_val,
   lsq_dat_stq1_mftgpr_val,
   lsq_dat_stq1_store_val,
   lsq_dat_stq1_byte_en,
   lsq_dat_stq1_op_size,
   lsq_dat_stq1_le_mode,
   lsq_dat_stq1_addr,
   lsq_dat_stq2_blk_req,
   lsq_dat_rel1_data_val,
   lsq_dat_rel1_qw,
   lsq_dat_stq2_store_data,
   stq6_rd_data_wa,
   stq6_rd_data_wb,
   stq6_rd_data_wc,
   stq6_rd_data_wd,
   stq6_rd_data_we,
   stq6_rd_data_wf,
   stq6_rd_data_wg,
   stq6_rd_data_wh,
   stq4_rot_data,
   dat_lsq_stq4_128data,
   stq7_byp_val_wabcd,
   stq7_byp_val_wefgh,
   stq7_byp_data_wabcd,
   stq7_byp_data_wefgh,
   stq8_byp_data_wabcd,
   stq8_byp_data_wefgh,
   stq_byp_val_wabcd,
   stq_byp_val_wefgh,
   stq4_dcarr_wren,
   stq4_dcarr_way_en,
   ctl_dat_stq5_way_perr_inval,
   dcarr_rd_stg_act,
   dcarr_rd_addr,
   dcarr_wr_stg_act,
   dcarr_wr_way,
   dcarr_wr_addr,
   dcarr_wr_data_wabcd,
   dcarr_wr_data_wefgh,
   vdd,
   gnd,
   nclk,
   sg_0,
   func_sl_thold_0_b,
   func_sl_force,
   func_nsl_thold_0_b,
   func_nsl_force,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   scan_in,
   scan_out
);

//-------------------------------------------------------------------
// Generics
//-------------------------------------------------------------------
//parameter                        EXPAND_TYPE = 2;		    // 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
//parameter                        GPR_WIDTH_ENC = 6;		   // Register Mode 5 = 32bit, 6 = 64bit

// Load Address
input                            ex2_stg_act;
input [52:59]                    ctl_dat_ex2_eff_addr;

// SPR
input                            spr_xucr0_dcdis;

//Store/Reload path
input                            lsq_dat_stq1_stg_act;
input                            lsq_dat_stq1_val;
input                            lsq_dat_stq1_mftgpr_val;
input                            lsq_dat_stq1_store_val;
input [0:15]                     lsq_dat_stq1_byte_en;
input [0:2]                      lsq_dat_stq1_op_size;
input                            lsq_dat_stq1_le_mode;
input [52:63]                    lsq_dat_stq1_addr;
input                            lsq_dat_stq2_blk_req;
input                            lsq_dat_rel1_data_val;
input [57:59]                    lsq_dat_rel1_qw;
input [0:143]                    lsq_dat_stq2_store_data;

// Read-Modify-Write Path Read data
input [0:143]                    stq6_rd_data_wa;
input [0:143]                    stq6_rd_data_wb;
input [0:143]                    stq6_rd_data_wc;
input [0:143]                    stq6_rd_data_wd;
input [0:143]                    stq6_rd_data_we;
input [0:143]                    stq6_rd_data_wf;
input [0:143]                    stq6_rd_data_wg;
input [0:143]                    stq6_rd_data_wh;

// Rotated Data
output [(128-`STQ_DATA_SIZE):127] stq4_rot_data;

// L2 Store Data
output [0:127]                   dat_lsq_stq4_128data;

// EX4 Load Bypass Data for Read/Write Collision detected in EX2
output [0:3]                     stq7_byp_val_wabcd;
output [0:3]                     stq7_byp_val_wefgh;
output [0:143]                   stq7_byp_data_wabcd;
output [0:143]                   stq7_byp_data_wefgh;
output [0:143]                   stq8_byp_data_wabcd;
output [0:143]                   stq8_byp_data_wefgh;
output [0:3]                     stq_byp_val_wabcd;
output [0:3]                     stq_byp_val_wefgh;

// D$ Array Write Control
input                            stq4_dcarr_wren;     // D$ Array Write Enable
input [0:7]                      stq4_dcarr_way_en;   // D$ Array Way Enable
input [0:7]                      ctl_dat_stq5_way_perr_inval;

// D$ Array
output [0:7]                     dcarr_rd_stg_act;    // D$ Array Read ACT
output [52:59]                   dcarr_rd_addr;		   // D$ Array Read Address
output [0:7]                     dcarr_wr_stg_act;    // D$ Array Write ACT
output [0:7]                     dcarr_wr_way;        // D$ Array Write Way Write Enable
output [52:59]                   dcarr_wr_addr;		   // D$ Array Write Address
output [0:143]                   dcarr_wr_data_wabcd;	// D$ Array Write Data for Way A,B,C,D
output [0:143]                   dcarr_wr_data_wefgh;	// D$ Array Write Data for Way E,F,G,H

// Pervasive
inout                            vdd;
inout                            gnd;
(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)
input [0:`NCLK_WIDTH-1]          nclk;
input                            sg_0;
input                            func_sl_thold_0_b;
input                            func_sl_force;
input                            func_nsl_thold_0_b;
input                            func_nsl_force;
input                            d_mode_dc;
input                            delay_lclkr_dc;
input                            mpw1_dc_b;
input                            mpw2_dc_b;
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input                            scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output                           scan_out;

//--------------------------
// constants
//--------------------------
parameter                        stq2_opsize_offset = 0;
parameter                        stq3_opsize_offset = stq2_opsize_offset + 5;
parameter                        stq4_rot_data_offset = stq3_opsize_offset + 5;
parameter                        stq2_le_mode_offset = stq4_rot_data_offset + `STQ_DATA_SIZE;
parameter                        stq2_mftgpr_val_offset = stq2_le_mode_offset + 1;
parameter                        stq2_upd_val_offset = stq2_mftgpr_val_offset + 1;
parameter                        stq3_upd_val_offset = stq2_upd_val_offset + 1;
parameter                        stq4_upd_val_offset = stq3_upd_val_offset + 1;
parameter                        stq5_arr_wren_offset = stq4_upd_val_offset + 1;
parameter                        stq3_blk_req_offset = stq5_arr_wren_offset + 1;
parameter                        stq2_rot_addr_offset = stq3_blk_req_offset + 1;
parameter                        stq2_addr_offset = stq2_rot_addr_offset + 5;
parameter                        stq4_addr_offset = stq2_addr_offset + 8;
parameter                        rel2_data_val_offset = stq4_addr_offset + 8;
parameter                        stq4_dcarr_data_offset = rel2_data_val_offset + 1;
parameter                        stq4_dcarr_par_offset = stq4_dcarr_data_offset + 128;
parameter                        stq2_byte_en_offset = stq4_dcarr_par_offset + 16;
parameter                        stq4_byte_en_offset = stq2_byte_en_offset + 16;
parameter                        stq2_stg_act_offset = stq4_byte_en_offset + 16;
parameter                        stq3_stg_act_offset = stq2_stg_act_offset + 1;
parameter                        stq4_stg_act_offset = stq3_stg_act_offset + 1;
parameter                        stq5_stg_act_offset = stq4_stg_act_offset + 1;

// start non-scan
parameter                        stq5_arr_way_en_offset = stq5_stg_act_offset + 1;
parameter                        stq3_rot_sel1_offset = stq5_arr_way_en_offset + 8;
parameter                        stq3_rot_sel2_offset = stq3_rot_sel1_offset + 8;
parameter                        stq3_rot_sel3_offset = stq3_rot_sel2_offset + 8;
parameter                        stq3_addr_offset = stq3_rot_sel3_offset + 8;
parameter                        stq5_addr_offset = stq3_addr_offset + 8;
parameter                        stq5_dcarr_wrt_data_offset = stq5_addr_offset + 8;
parameter                        stq3_store_rel_data_offset = stq5_dcarr_wrt_data_offset + 144;
parameter                        stq3_store_rel_par_offset = stq3_store_rel_data_offset + 128;
parameter                        stq3_byte_en_offset = stq3_store_rel_par_offset + 16;
parameter                        stq5_byte_en_offset = stq3_byte_en_offset + 16;
parameter                        scan_right = stq5_byte_en_offset + 16 - 1;

parameter [0:4]                  rot_max_size = 5'b10000;

//--------------------------
// signals
//--------------------------
wire [0:127]                     stq3_rot_data;
wire [0:4]                       stq2_opsize_d;
wire [0:4]                       stq2_opsize_q;
wire [0:4]                       stq3_opsize_d;
wire [0:4]                       stq3_opsize_q;
wire [0:127]                     stq3_optype_mask;
wire [0:127]                     stq3_msk_data;
wire [0:127]                     stq3_swzl_data;
wire [0:1]                       rotate_sel1;
wire [0:3]                       rotate_sel2;
wire [0:3]                       rotate_sel3;
wire [0:7]                       stq3_rot_sel1_d;
wire [0:7]                       stq3_rot_sel1_q;
wire [0:7]                       stq3_rot_sel2_d;
wire [0:7]                       stq3_rot_sel2_q;
wire [0:7]                       stq3_rot_sel3_d;
wire [0:7]                       stq3_rot_sel3_q;
wire                             lvl1_sel;
wire [0:1]                       lvl2_sel;
wire [0:1]                       lvl3_sel;
wire [52:59]                     ex2_stq4_rd_addr;
wire                             ex2_stq4_rd_stg_act;
wire [59:63]                     stq2_rot_addr_d;
wire [59:63]                     stq2_rot_addr_q;
wire [52:59]                     stq2_addr_d;
wire [52:59]                     stq2_addr_q;
wire [52:59]                     stq3_addr_d;
wire [52:59]                     stq3_addr_q;
wire [52:59]                     stq4_addr_d;
wire [52:59]                     stq4_addr_q;
wire [52:59]                     stq5_addr_d;
wire [52:59]                     stq5_addr_q;
wire [(128-`STQ_DATA_SIZE):127]  stq4_rot_data_d;
wire [(128-`STQ_DATA_SIZE):127]  stq4_rot_data_q;
wire [0:4]                       rot_size;
wire [0:4]                       rot_max_size_le;
wire [0:4]                       rot_sel_le;
wire [0:4]                       rot_sel_non_le;
wire [0:3]                       st_rot_sel;
wire                             rel2_data_val_d;
wire                             rel2_data_val_q;
wire [0:4]                       stq1_op_size;
wire [0:15]                      stq3_rot_parity;
wire [0:127]                     stq4_dcarr_data_d;
wire [0:127]                     stq4_dcarr_data_q;
wire [0:15]                      stq4_dcarr_par_d;
wire [0:15]                      stq4_dcarr_par_q;
wire [0:143]                     stq4_dcarr_wrt_data;
wire [0:143]                     stq5_dcarr_wrt_data_d;
wire [0:143]                     stq5_dcarr_wrt_data_q;
wire [0:127]                     stq4_128data;
wire                             stq2_le_mode_d;
wire                             stq2_le_mode_q;
wire                             stq2_mftgpr_val_d;
wire                             stq2_mftgpr_val_q;
wire                             stq2_upd_val_d;
wire                             stq2_upd_val_q;
wire                             stq3_upd_val_d;
wire                             stq3_upd_val_q;
wire                             stq4_upd_val_d;
wire                             stq4_upd_val_q;
wire                             stq5_arr_wren_d;
wire                             stq5_arr_wren_q;
wire [0:7]                       stq5_arr_way_en;
wire [0:7]                       stq5_arr_way_en_d;
wire [0:7]                       stq5_arr_way_en_q;
wire                             stq3_blk_req_d;
wire                             stq3_blk_req_q;
wire [0:127]                     stq3_store_rel_data_d;
wire [0:127]                     stq3_store_rel_data_q;
wire [0:15]                      stq3_store_rel_par_d;
wire [0:15]                      stq3_store_rel_par_q;
wire [0:15]                      stq2_byte_en_d;
wire [0:15]                      stq2_byte_en_q;
wire [0:15]                      stq3_byte_en_d;
wire [0:15]                      stq3_byte_en_q;
wire [0:15]                      stq4_byte_en_d;
wire [0:15]                      stq4_byte_en_q;
wire [0:15]                      stq5_byte_en_d;
wire [0:15]                      stq5_byte_en_q;
wire [0:15]                      bittype_mask;
wire                             stq1_stg_act;
wire                             stq2_stg_act_d;
wire                             stq2_stg_act_q;
wire                             stq3_stg_act_d;
wire                             stq3_stg_act_q;
wire                             stq4_stg_act_d;
wire                             stq4_stg_act_q;
wire                             stq5_stg_act_d;
wire                             stq5_stg_act_q;
wire                             rmw_scan_in;
wire                             rmw_scan_out;

wire                             tiup;
wire [0:scan_right]              siv;
wire [0:scan_right]              sov;
(* analysis_not_referenced="true" *)
wire                             unused;

assign unused = rot_sel_le[0] | rot_sel_non_le[0] | |stq3_swzl_data[0:63];

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// ACT's
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

assign stq1_stg_act = lsq_dat_stq1_stg_act;
assign stq2_stg_act_d = stq1_stg_act;
assign stq3_stg_act_d = stq2_stg_act_q;
assign stq4_stg_act_d = stq3_stg_act_q;
assign stq5_stg_act_d = stq4_stg_act_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Inputs
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign tiup = 1'b1;

// This signals are not muxed latched, need to latch them only
assign stq1_op_size = (lsq_dat_stq1_op_size == 3'b110) ? 5'b10000 : 		// 16Bytes
                      (lsq_dat_stq1_op_size == 3'b101) ? 5'b01000 : 		// 8Bytes
                      (lsq_dat_stq1_op_size == 3'b100) ? 5'b00100 : 		// 4Bytes
                      (lsq_dat_stq1_op_size == 3'b010) ? 5'b00010 : 		// 2Bytes
                      (lsq_dat_stq1_op_size == 3'b001) ? 5'b00001 : 		// 1Bytes
                                                         5'b00000;

assign stq2_opsize_d = stq1_op_size;
assign stq3_opsize_d = stq2_opsize_q;
assign stq2_addr_d[52:56] = lsq_dat_stq1_addr[52:56];

assign stq2_addr_d[57:59] = (lsq_dat_rel1_data_val == 1'b1) ? lsq_dat_rel1_qw : lsq_dat_stq1_addr[57:59];

assign stq2_rot_addr_d = lsq_dat_stq1_addr[59:63];
assign stq3_addr_d = stq2_addr_q;
assign stq4_addr_d = stq3_addr_q;
assign stq5_addr_d = stq4_addr_q;
assign stq2_le_mode_d = lsq_dat_stq1_le_mode;
assign stq2_mftgpr_val_d = lsq_dat_stq1_mftgpr_val & lsq_dat_stq1_val;
assign stq2_upd_val_d = (lsq_dat_stq1_store_val & lsq_dat_stq1_val);
assign stq3_upd_val_d = stq2_upd_val_q;
assign stq4_upd_val_d = stq3_upd_val_q & (~stq3_blk_req_q);
assign stq5_arr_wren_d = stq4_dcarr_wren & ~spr_xucr0_dcdis;
assign stq5_arr_way_en_d = stq4_dcarr_way_en;
assign stq5_arr_way_en   = stq5_arr_way_en_q & ~ctl_dat_stq5_way_perr_inval;
assign stq2_byte_en_d = lsq_dat_stq1_byte_en;
assign stq3_byte_en_d = stq2_byte_en_q | {16{rel2_data_val_q}};
assign stq4_byte_en_d = stq3_byte_en_q;
assign stq5_byte_en_d = stq4_byte_en_q;
assign stq3_blk_req_d = lsq_dat_stq2_blk_req;
assign rel2_data_val_d = lsq_dat_rel1_data_val;

// #############################################################################################
// Select between different Operations
// #############################################################################################
assign ex2_stq4_rd_addr    = ~stq4_upd_val_q ? ctl_dat_ex2_eff_addr : stq4_addr_q;
assign ex2_stq4_rd_stg_act = (ex2_stg_act | stq4_upd_val_q) & ~spr_xucr0_dcdis;

// #############################################################################################
// Create Rotate Select
// #############################################################################################

// Store/Reload Pipe Rotator Control Calculations
assign rot_size = stq2_rot_addr_q + stq2_opsize_q;
assign rot_max_size_le = rot_max_size | stq2_opsize_q;
assign rot_sel_le = rot_max_size_le - rot_size;
assign rot_sel_non_le = rot_max_size - rot_size;

// STORE PATH LITTLE ENDIAN ROTATOR SELECT CALCULATION
// st_rot_size = rot_addr + op_size
// st_rot_sel = (rot_max_size or le_op_size) - rot_size

// Little Endian Support Store Data Rotate Select
assign st_rot_sel = (stq2_le_mode_q == 1'b1) ? rot_sel_le[1:4] :
                                               rot_sel_non_le[1:4];

// #############################################################################################
// 1-hot Rotate Select
// #############################################################################################

assign lvl1_sel = stq2_le_mode_q & (~(stq2_mftgpr_val_q | rel2_data_val_q));
assign lvl2_sel = st_rot_sel[0:1] & {2{~(stq2_mftgpr_val_q | rel2_data_val_q)}};
assign lvl3_sel = st_rot_sel[2:3] & {2{~(stq2_mftgpr_val_q | rel2_data_val_q)}};

assign rotate_sel1 = (lvl1_sel == 1'b0) ? 2'b10 :
                                          2'b01;

assign rotate_sel2 = (lvl2_sel == 2'b00) ? 4'b1000 :
                     (lvl2_sel == 2'b01) ? 4'b0100 :
                     (lvl2_sel == 2'b10) ? 4'b0010 :
                                           4'b0001;

assign rotate_sel3 = (lvl3_sel == 2'b00) ? 4'b1000 :
                     (lvl3_sel == 2'b01) ? 4'b0100 :
                     (lvl3_sel == 2'b10) ? 4'b0010 :
                                           4'b0001;

assign stq3_rot_sel1_d = {rotate_sel1, rotate_sel1, rotate_sel1, rotate_sel1};
assign stq3_rot_sel2_d = {rotate_sel2, rotate_sel2};
assign stq3_rot_sel3_d = {rotate_sel3, rotate_sel3};

// #############################################################################################
// Select Between Reload Critical Quadword and Store Data Path
// #############################################################################################

// Parity Bits
assign stq3_store_rel_par_d = lsq_dat_stq2_store_data[128:143];

// Swizzle Rotate Data
generate begin : swzlSTData
  genvar                           t;
  for (t = 0; t <= 7; t = t + 1) begin : swzlSTData
     assign stq3_store_rel_data_d[t * 16:(t * 16) + 15] = {lsq_dat_stq2_store_data[t + 0],
                                                           lsq_dat_stq2_store_data[t + 8],
                                                           lsq_dat_stq2_store_data[t + 16],
                                                           lsq_dat_stq2_store_data[t + 24],
                                                           lsq_dat_stq2_store_data[t + 32],
                                                           lsq_dat_stq2_store_data[t + 40],
                                                           lsq_dat_stq2_store_data[t + 48],
                                                           lsq_dat_stq2_store_data[t + 56],
                                                           lsq_dat_stq2_store_data[t + 64],
                                                           lsq_dat_stq2_store_data[t + 72],
                                                           lsq_dat_stq2_store_data[t + 80],
                                                           lsq_dat_stq2_store_data[t + 88],
                                                           lsq_dat_stq2_store_data[t + 96],
                                                           lsq_dat_stq2_store_data[t + 104],
                                                           lsq_dat_stq2_store_data[t + 112],
                                                           lsq_dat_stq2_store_data[t + 120]};
  end
end
endgenerate

// #############################################################################################
// 16 Byte Store Rotator
// #############################################################################################

// Store Data Rotate
generate begin : l1dcrotl
   genvar bit;
   for (bit = 0; bit <= 7; bit = bit + 1) begin : l1dcrotl
      tri_rot16_lu drotl(

         // Rotator Controls and Data
         .rot_sel1(stq3_rot_sel1_q),
         .rot_sel2(stq3_rot_sel2_q),
         .rot_sel3(stq3_rot_sel3_q),
         .rot_data(stq3_store_rel_data_q[bit * 16:(bit * 16) + 15]),

         // Rotated Data
         .data_rot(stq3_rot_data[bit * 16:(bit * 16) + 15]),

         // Pervasive
         .vdd(vdd),
         .gnd(gnd)
      );
   end
end
endgenerate

// Parity Rotate

tri_rot16_lu protl(

   // Rotator Controls and Data
   .rot_sel1(stq3_rot_sel1_q),
   .rot_sel2(stq3_rot_sel2_q),
   .rot_sel3(stq3_rot_sel3_q),
   .rot_data(stq3_store_rel_par_q),

   // Rotated Data
   .data_rot(stq3_rot_parity),

   // Pervasive
   .vdd(vdd),
   .gnd(gnd)
);

// Mux removed since we are gating the rotator controls when operation is a reload
// this causes the data to be passed through
// Data written to D$ Array
assign stq4_dcarr_data_d = stq3_rot_data;
assign stq4_dcarr_par_d = stq3_rot_parity;
assign stq4_dcarr_wrt_data = {stq4_dcarr_data_q, stq4_dcarr_par_q};
assign stq5_dcarr_wrt_data_d = stq4_dcarr_wrt_data;

// #############################################################################################
// Read Modify Write
// #############################################################################################
tri_lq_rmw rmw(
   .ex2_stq4_rd_stg_act(ex2_stq4_rd_stg_act),
   .ex2_stq4_rd_addr(ex2_stq4_rd_addr),
   .stq6_rd_data_wa(stq6_rd_data_wa),
   .stq6_rd_data_wb(stq6_rd_data_wb),
   .stq6_rd_data_wc(stq6_rd_data_wc),
   .stq6_rd_data_wd(stq6_rd_data_wd),
   .stq6_rd_data_we(stq6_rd_data_we),
   .stq6_rd_data_wf(stq6_rd_data_wf),
   .stq6_rd_data_wg(stq6_rd_data_wg),
   .stq6_rd_data_wh(stq6_rd_data_wh),
   .stq5_stg_act(stq5_stg_act_q),
   .stq5_arr_wren(stq5_arr_wren_q),
   .stq5_arr_wr_way(stq5_arr_way_en),
   .stq5_arr_wr_addr(stq5_addr_q),
   .stq5_arr_wr_bytew(stq5_byte_en_q),
   .stq5_arr_wr_data(stq5_dcarr_wrt_data_q),
   .stq7_byp_val_wabcd(stq7_byp_val_wabcd),
   .stq7_byp_val_wefgh(stq7_byp_val_wefgh),
   .stq7_byp_data_wabcd(stq7_byp_data_wabcd),
   .stq7_byp_data_wefgh(stq7_byp_data_wefgh),
   .stq8_byp_data_wabcd(stq8_byp_data_wabcd),
   .stq8_byp_data_wefgh(stq8_byp_data_wefgh),
   .stq_byp_val_wabcd(stq_byp_val_wabcd),
   .stq_byp_val_wefgh(stq_byp_val_wefgh),
   .dcarr_rd_stg_act(dcarr_rd_stg_act),
   .dcarr_wr_stg_act(dcarr_wr_stg_act),
   .dcarr_wr_way(dcarr_wr_way),
   .dcarr_wr_addr(dcarr_wr_addr),
   .dcarr_wr_data_wabcd(dcarr_wr_data_wabcd),
   .dcarr_wr_data_wefgh(dcarr_wr_data_wefgh),
   .nclk(nclk),
   .vdd(vdd),
   .gnd(gnd),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc),
   .mpw1_dc_b(mpw1_dc_b),
   .mpw2_dc_b(mpw2_dc_b),
   .func_sl_force(func_sl_force),
   .func_sl_thold_0_b(func_sl_thold_0_b),
   .sg_0(sg_0),
   .scan_in(rmw_scan_in),
   .scan_out(rmw_scan_out)
);

// #############################################################################################
// Op Size Mask Generation for Reloads
// #############################################################################################

// STQ Bit Mask Generation
assign bittype_mask = (16'h0001 & {16{stq3_opsize_q[4]}}) | (16'h0003 & {16{stq3_opsize_q[3]}}) |
                      (16'h000F & {16{stq3_opsize_q[2]}}) | (16'h00FF & {16{stq3_opsize_q[1]}}) |
                      (16'hFFFF & {16{stq3_opsize_q[0]}});

generate begin : maskGen
   genvar bit;
   for (bit = 0; bit <= 7; bit = bit + 1)
   begin : maskGen
      assign stq3_optype_mask[bit * 16:(bit * 16) + 15] = bittype_mask;
   end
end
endgenerate

assign stq3_msk_data = stq3_rot_data & stq3_optype_mask;

// Swizzle Data to a proper format
generate begin : swzlData
  genvar t;
  for (t = 0; t <= 15; t = t + 1)
  begin : swzlData
     assign stq3_swzl_data[t * 8:(t * 8) + 7] = {stq3_msk_data[t],
                                                 stq3_msk_data[t + 16],
                                                 stq3_msk_data[t + 32],
                                                 stq3_msk_data[t + 48],
                                                 stq3_msk_data[t + 64],
                                                 stq3_msk_data[t + 80],
                                                 stq3_msk_data[t + 96],
                                                 stq3_msk_data[t + 112]};

     assign stq4_128data[t * 8:(t * 8) + 7] = {stq4_dcarr_data_q[t],
                                               stq4_dcarr_data_q[t + 16],
                                               stq4_dcarr_data_q[t + 32],
                                               stq4_dcarr_data_q[t + 48],
                                               stq4_dcarr_data_q[t + 64],
                                               stq4_dcarr_data_q[t + 80],
                                               stq4_dcarr_data_q[t + 96],
                                               stq4_dcarr_data_q[t + 112]};
  end
end
endgenerate

assign stq4_rot_data_d = stq3_swzl_data[(128 - `STQ_DATA_SIZE):127];

// #############################################################################################
// Outputs
// #############################################################################################

assign dcarr_rd_addr = ex2_stq4_rd_addr;
assign dat_lsq_stq4_128data = stq4_128data;
assign stq4_rot_data = stq4_rot_data_q;

// #############################################################################################
// Registers
// #############################################################################################
tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) stq2_opsize_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_opsize_offset:stq2_opsize_offset + 5 - 1]),
   .scout(sov[stq2_opsize_offset:stq2_opsize_offset + 5 - 1]),
   .din(stq2_opsize_d),
   .dout(stq2_opsize_q)
);

tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) stq3_opsize_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq2_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_opsize_offset:stq3_opsize_offset + 5 - 1]),
   .scout(sov[stq3_opsize_offset:stq3_opsize_offset + 5 - 1]),
   .din(stq3_opsize_d),
   .dout(stq3_opsize_q)
);

tri_rlmreg_p #(.WIDTH(`STQ_DATA_SIZE), .INIT(0), .NEEDS_SRESET(1)) stq4_rot_data_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_rot_data_offset:stq4_rot_data_offset + `STQ_DATA_SIZE - 1]),
   .scout(sov[stq4_rot_data_offset:stq4_rot_data_offset + `STQ_DATA_SIZE - 1]),
   .din(stq4_rot_data_d),
   .dout(stq4_rot_data_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_le_mode_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_le_mode_offset]),
   .scout(sov[stq2_le_mode_offset]),
   .din(stq2_le_mode_d),
   .dout(stq2_le_mode_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_mftgpr_val_reg(
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
   .scin(siv[stq2_mftgpr_val_offset]),
   .scout(sov[stq2_mftgpr_val_offset]),
   .din(stq2_mftgpr_val_d),
   .dout(stq2_mftgpr_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_upd_val_reg(
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
   .scin(siv[stq2_upd_val_offset]),
   .scout(sov[stq2_upd_val_offset]),
   .din(stq2_upd_val_d),
   .dout(stq2_upd_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq3_upd_val_reg(
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
   .scin(siv[stq3_upd_val_offset]),
   .scout(sov[stq3_upd_val_offset]),
   .din(stq3_upd_val_d),
   .dout(stq3_upd_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_upd_val_reg(
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
   .scin(siv[stq4_upd_val_offset]),
   .scout(sov[stq4_upd_val_offset]),
   .din(stq4_upd_val_d),
   .dout(stq4_upd_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq5_arr_wren_reg(
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
   .scin(siv[stq5_arr_wren_offset]),
   .scout(sov[stq5_arr_wren_offset]),
   .din(stq5_arr_wren_d),
   .dout(stq5_arr_wren_q)
);

tri_regk #(.WIDTH(8), .INIT(170), .NEEDS_SRESET(1)) stq5_arr_way_en_reg(
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
   .scin(siv[stq5_arr_way_en_offset:stq5_arr_way_en_offset+8-1]),
   .scout(sov[stq5_arr_way_en_offset:stq5_arr_way_en_offset+8-1]),
   .din(stq5_arr_way_en_d),
   .dout(stq5_arr_way_en_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq3_blk_req_reg(
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
   .scin(siv[stq3_blk_req_offset]),
   .scout(sov[stq3_blk_req_offset]),
   .din(stq3_blk_req_d),
   .dout(stq3_blk_req_q)
);

tri_regk #(.WIDTH(8), .INIT(170), .NEEDS_SRESET(1)) stq3_rot_sel1_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_rot_sel1_offset:stq3_rot_sel1_offset+8-1]),
   .scout(sov[stq3_rot_sel1_offset:stq3_rot_sel1_offset+8-1]),
   .din(stq3_rot_sel1_d),
   .dout(stq3_rot_sel1_q)
);

tri_regk #(.WIDTH(8), .INIT(136), .NEEDS_SRESET(1)) stq3_rot_sel2_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_rot_sel2_offset:stq3_rot_sel2_offset+8-1]),
   .scout(sov[stq3_rot_sel2_offset:stq3_rot_sel2_offset+8-1]),
   .din(stq3_rot_sel2_d),
   .dout(stq3_rot_sel2_q)
);

tri_regk #(.WIDTH(8), .INIT(136), .NEEDS_SRESET(1)) stq3_rot_sel3_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_rot_sel3_offset:stq3_rot_sel3_offset+8-1]),
   .scout(sov[stq3_rot_sel3_offset:stq3_rot_sel3_offset+8-1]),
   .din(stq3_rot_sel3_d),
   .dout(stq3_rot_sel3_q)
);

tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) stq2_rot_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_rot_addr_offset:stq2_rot_addr_offset + 5 - 1]),
   .scout(sov[stq2_rot_addr_offset:stq2_rot_addr_offset + 5 - 1]),
   .din(stq2_rot_addr_d),
   .dout(stq2_rot_addr_q)
);

tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) stq2_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_addr_offset:stq2_addr_offset + 8 - 1]),
   .scout(sov[stq2_addr_offset:stq2_addr_offset + 8 - 1]),
   .din(stq2_addr_d),
   .dout(stq2_addr_q)
);

tri_regk #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) stq3_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_addr_offset:stq3_addr_offset+8-1]),
   .scout(sov[stq3_addr_offset:stq3_addr_offset+8-1]),
   .din(stq3_addr_d),
   .dout(stq3_addr_q)
);

tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) stq4_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_addr_offset:stq4_addr_offset + 8 - 1]),
   .scout(sov[stq4_addr_offset:stq4_addr_offset + 8 - 1]),
   .din(stq4_addr_d),
   .dout(stq4_addr_q)
);

tri_regk #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) stq5_addr_reg(
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
   .scin(siv[stq5_addr_offset:stq5_addr_offset+8-1]),
   .scout(sov[stq5_addr_offset:stq5_addr_offset+8-1]),
   .din(stq5_addr_d),
   .dout(stq5_addr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel2_data_val_reg(
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
   .scin(siv[rel2_data_val_offset]),
   .scout(sov[rel2_data_val_offset]),
   .din(rel2_data_val_d),
   .dout(rel2_data_val_q)
);

tri_rlmreg_p #(.WIDTH(128), .INIT(0), .NEEDS_SRESET(1)) stq4_dcarr_data_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_dcarr_data_offset:stq4_dcarr_data_offset + 128 - 1]),
   .scout(sov[stq4_dcarr_data_offset:stq4_dcarr_data_offset + 128 - 1]),
   .din(stq4_dcarr_data_d),
   .dout(stq4_dcarr_data_q)
);

tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) stq4_dcarr_par_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_dcarr_par_offset:stq4_dcarr_par_offset + 16 - 1]),
   .scout(sov[stq4_dcarr_par_offset:stq4_dcarr_par_offset + 16 - 1]),
   .din(stq4_dcarr_par_d),
   .dout(stq4_dcarr_par_q)
);

tri_regk #(.WIDTH(144), .INIT(0), .NEEDS_SRESET(1)) stq5_dcarr_wrt_data_reg(
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
   .scin(siv[stq5_dcarr_wrt_data_offset:stq5_dcarr_wrt_data_offset+144-1]),
   .scout(sov[stq5_dcarr_wrt_data_offset:stq5_dcarr_wrt_data_offset+144-1]),
   .din(stq5_dcarr_wrt_data_d),
   .dout(stq5_dcarr_wrt_data_q)
);

tri_regk #(.WIDTH(128), .INIT(0), .NEEDS_SRESET(1)) stq3_store_rel_data_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_store_rel_data_offset:stq3_store_rel_data_offset+128-1]),
   .scout(sov[stq3_store_rel_data_offset:stq3_store_rel_data_offset+128-1]),
   .din(stq3_store_rel_data_d),
   .dout(stq3_store_rel_data_q)
);

tri_regk #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) stq3_store_rel_par_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_store_rel_par_offset:stq3_store_rel_par_offset+16-1]),
   .scout(sov[stq3_store_rel_par_offset:stq3_store_rel_par_offset+16-1]),
   .din(stq3_store_rel_par_d),
   .dout(stq3_store_rel_par_q)
);

tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) stq2_byte_en_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_byte_en_offset:stq2_byte_en_offset + 16 - 1]),
   .scout(sov[stq2_byte_en_offset:stq2_byte_en_offset + 16 - 1]),
   .din(stq2_byte_en_d),
   .dout(stq2_byte_en_q)
);

tri_regk #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) stq3_byte_en_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_byte_en_offset:stq3_byte_en_offset+16-1]),
   .scout(sov[stq3_byte_en_offset:stq3_byte_en_offset+16-1]),
   .din(stq3_byte_en_d),
   .dout(stq3_byte_en_q)
);

tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) stq4_byte_en_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_byte_en_offset:stq4_byte_en_offset + 16 - 1]),
   .scout(sov[stq4_byte_en_offset:stq4_byte_en_offset + 16 - 1]),
   .din(stq4_byte_en_d),
   .dout(stq4_byte_en_q)
);

tri_regk #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) stq5_byte_en_reg(
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
   .scin(siv[stq5_byte_en_offset:stq5_byte_en_offset+16-1]),
   .scout(sov[stq5_byte_en_offset:stq5_byte_en_offset+16-1]),
   .din(stq5_byte_en_d),
   .dout(stq5_byte_en_q)
);

//------------------------------------
//              ACTs
//------------------------------------


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_stg_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
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


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq3_stg_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
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

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_stg_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
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

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq5_stg_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
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

assign rmw_scan_in = scan_in;
assign siv[0:scan_right] = {sov[1:scan_right], rmw_scan_out};
assign scan_out = sov[0];

endmodule
