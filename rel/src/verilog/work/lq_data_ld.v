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

//  Description:  XU LSU Load Data Rotator Wrapper
//
//*****************************************************************************

// ##########################################################################################
// VHDL Contents
// 1) 8 16 Byte Unaligned Rotator
// 2) Little Endian Support for 2,4,8,16 Byte Operations
// 3) Contains Algebraic Sign Extension
// 4) Contains 8 Way Select
// 5) Contains Fixed Point Unit (FXU) 8 Byte Load Path
// 6) Contains Auxilary Unit (AXU) 16 Byte Load Path
// ##########################################################################################

`include "tri_a2o.vh"




module lq_data_ld(
   ex3_stg_act,
   ex4_stg_act,
   ctl_dat_ex3_opsize,
   ctl_dat_ex3_le_ld_rotsel,
   ctl_dat_ex3_be_ld_rotsel,
   ctl_dat_ex3_algebraic,
   ctl_dat_ex3_le_alg_rotsel,
   ctl_dat_ex3_le_mode,
   dcarr_rd_data,
   stq7_byp_val_wabcd,
   stq7_byp_val_wefgh,
   stq7_byp_data_wabcd,
   stq7_byp_data_wefgh,
   stq8_byp_data_wabcd,
   stq8_byp_data_wefgh,
   stq_byp_val_wabcd,
   stq_byp_val_wefgh,
   ctl_dat_ex4_way_hit,
   inj_dcache_parity,
   dcarr_data_perr_way,
   ex5_ld_hit_data,
   stq6_rd_data_wa,
   stq6_rd_data_wb,
   stq6_rd_data_wc,
   stq6_rd_data_wd,
   stq6_rd_data_we,
   stq6_rd_data_wf,
   stq6_rd_data_wg,
   stq6_rd_data_wh,
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
//parameter                        EXPAND_TYPE = 2;		// 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)

// ACT
input                            ex3_stg_act;
input                            ex4_stg_act;

// Execution Pipe Load Data Rotator Controls
input [0:4]                      ctl_dat_ex3_opsize;
input [0:3]                      ctl_dat_ex3_le_ld_rotsel;
input [0:3]                      ctl_dat_ex3_be_ld_rotsel;
input                            ctl_dat_ex3_algebraic;
input [0:3]                      ctl_dat_ex3_le_alg_rotsel;
input                            ctl_dat_ex3_le_mode;

// D$ Array Read Data
input [0:1151]                   dcarr_rd_data;

// EX4 Load Bypass Data for Read/Write Collision detected in EX2
input [0:3]                      stq7_byp_val_wabcd;
input [0:3]                      stq7_byp_val_wefgh;
input [0:143]                    stq7_byp_data_wabcd;
input [0:143]                    stq7_byp_data_wefgh;
input [0:143]                    stq8_byp_data_wabcd;
input [0:143]                    stq8_byp_data_wefgh;
input [0:3]                      stq_byp_val_wabcd;
input [0:3]                      stq_byp_val_wefgh;

// Load Control
input [0:7]                      ctl_dat_ex4_way_hit;

// Parity Error Inject
input                            inj_dcache_parity;

// Data Cache Array Parity Error Detected
output [0:7]                     dcarr_data_perr_way;

// Rotated Data
output [(128-`STQ_DATA_SIZE):127] ex5_ld_hit_data;

// Read-Modify-Write Path Read data
output [0:143]                   stq6_rd_data_wa;
output [0:143]                   stq6_rd_data_wb;
output [0:143]                   stq6_rd_data_wc;
output [0:143]                   stq6_rd_data_wd;
output [0:143]                   stq6_rd_data_we;
output [0:143]                   stq6_rd_data_wf;
output [0:143]                   stq6_rd_data_wg;
output [0:143]                   stq6_rd_data_wh;

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
input [0:4]                      scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output [0:4]                     scan_out;

//--------------------------
// constants
//--------------------------
parameter                        ex5_ld_hit_data_reg_offset = 0;
parameter                        scan_right = ex5_ld_hit_data_reg_offset + `STQ_DATA_SIZE - 1;

//--------------------------
// signals
//--------------------------
wire                             inj_dcache_parity_b;
wire                             arr_rd_data32_b;
wire                             stickbit32;
wire [0:127]                     dcarr_rd_data_wa;
wire [0:127]                     dcarr_rd_data_wb;
wire [0:127]                     dcarr_rd_data_wc;
wire [0:127]                     dcarr_rd_data_wd;
wire [0:127]                     dcarr_rd_data_we;
wire [0:127]                     dcarr_rd_data_wf;
wire [0:127]                     dcarr_rd_data_wg;
wire [0:127]                     dcarr_rd_data_wh;
wire [0:15]                      dcarr_rd_parity_wa;
wire [0:15]                      dcarr_rd_parity_wb;
wire [0:15]                      dcarr_rd_parity_wc;
wire [0:15]                      dcarr_rd_parity_wd;
wire [0:15]                      dcarr_rd_parity_we;
wire [0:15]                      dcarr_rd_parity_wf;
wire [0:15]                      dcarr_rd_parity_wg;
wire [0:15]                      dcarr_rd_parity_wh;
wire [0:127]                     dcarr_buf_data_wa;
wire [0:127]                     dcarr_buf_data_wb;
wire [0:127]                     dcarr_buf_data_wc;
wire [0:127]                     dcarr_buf_data_wd;
wire [0:127]                     dcarr_buf_data_we;
wire [0:127]                     dcarr_buf_data_wf;
wire [0:127]                     dcarr_buf_data_wg;
wire [0:127]                     dcarr_buf_data_wh;
wire [0:127]                     ex4_ld_data_rot_wa;
wire [0:127]                     ex4_ld_data_rot_wb;
wire [0:127]                     ex4_ld_data_rot_wc;
wire [0:127]                     ex4_ld_data_rot_wd;
wire [0:127]                     ex4_ld_data_rot_we;
wire [0:127]                     ex4_ld_data_rot_wf;
wire [0:127]                     ex4_ld_data_rot_wg;
wire [0:127]                     ex4_ld_data_rot_wh;
wire [0:5]                       ex4_ld_alg_bit_wa;
wire [0:5]                       ex4_ld_alg_bit_wb;
wire [0:5]                       ex4_ld_alg_bit_wc;
wire [0:5]                       ex4_ld_alg_bit_wd;
wire [0:5]                       ex4_ld_alg_bit_we;
wire [0:5]                       ex4_ld_alg_bit_wf;
wire [0:5]                       ex4_ld_alg_bit_wg;
wire [0:5]                       ex4_ld_alg_bit_wh;
wire [0:127]                     ex4_ld_data_swzl_wa;
wire [0:127]                     ex4_ld_data_swzl_wb;
wire [0:127]                     ex4_ld_data_swzl_wc;
wire [0:127]                     ex4_ld_data_swzl_wd;
wire [0:127]                     ex4_ld_data_swzl_we;
wire [0:127]                     ex4_ld_data_swzl_wf;
wire [0:127]                     ex4_ld_data_swzl_wg;
wire [0:127]                     ex4_ld_data_swzl_wh;
wire [0:128]                     ex4_ld_data_wa;
wire [0:128]                     ex4_ld_data_wb;
wire [0:128]                     ex4_ld_data_wc;
wire [0:128]                     ex4_ld_data_wd;
wire [0:128]                     ex4_ld_data_we;
wire [0:128]                     ex4_ld_data_wf;
wire [0:128]                     ex4_ld_data_wg;
wire [0:128]                     ex4_ld_data_wh;
wire [0:15]                      dcarr_perr_byte_wa;
wire [0:15]                      dcarr_perr_byte_wb;
wire [0:15]                      dcarr_perr_byte_wc;
wire [0:15]                      dcarr_perr_byte_wd;
wire [0:15]                      dcarr_perr_byte_we;
wire [0:15]                      dcarr_perr_byte_wf;
wire [0:15]                      dcarr_perr_byte_wg;
wire [0:15]                      dcarr_perr_byte_wh;
wire                             dcarr_perr_det_wa;
wire                             dcarr_perr_det_wb;
wire                             dcarr_perr_det_wc;
wire                             dcarr_perr_det_wd;
wire                             dcarr_perr_det_we;
wire                             dcarr_perr_det_wf;
wire                             dcarr_perr_det_wg;
wire                             dcarr_perr_det_wh;
wire [(128-`STQ_DATA_SIZE):127]  ex5_ld_hit_data_d;
wire [(128-`STQ_DATA_SIZE):127]  ex5_ld_hit_data_q;
wire [0:7]                       rot_wa_scan_in;
wire [0:7]                       rot_wa_scan_out;
wire [0:7]                       rot_wb_scan_in;
wire [0:7]                       rot_wb_scan_out;
wire [0:7]                       rot_wc_scan_in;
wire [0:7]                       rot_wc_scan_out;
wire [0:7]                       rot_wd_scan_in;
wire [0:7]                       rot_wd_scan_out;
wire [0:7]                       rot_we_scan_in;
wire [0:7]                       rot_we_scan_out;
wire [0:7]                       rot_wf_scan_in;
wire [0:7]                       rot_wf_scan_out;
wire [0:7]                       rot_wg_scan_in;
wire [0:7]                       rot_wg_scan_out;
wire [0:7]                       rot_wh_scan_in;
wire [0:7]                       rot_wh_scan_out;

wire                             tiup;
wire [0:scan_right]              siv;
wire [0:scan_right]              sov;

(* analysis_not_referenced="true" *)
wire                             unused;

assign tiup = 1'b1;
assign unused = (|(ex4_ld_data_wa[0:128-`STQ_DATA_SIZE])) | (|(ex4_ld_data_wb[0:128-`STQ_DATA_SIZE])) |
                (|(ex4_ld_data_wc[0:128-`STQ_DATA_SIZE])) | (|(ex4_ld_data_wd[0:128-`STQ_DATA_SIZE])) |
                (|(ex4_ld_data_we[0:128-`STQ_DATA_SIZE])) | (|(ex4_ld_data_wf[0:128-`STQ_DATA_SIZE])) |
                (|(ex4_ld_data_wg[0:128-`STQ_DATA_SIZE])) | (|(ex4_ld_data_wh[0:128-`STQ_DATA_SIZE]));
// #############################################################################################

// #############################################################################################
// Inject Data Cache Error
// #############################################################################################

// Sticking bit32 of the array when Data Cache Parity Error Inject is on
// Bit32 will be stuck to 1
// Bit32 refers to bit2 of byte0 of WayA
assign inj_dcache_parity_b = (~inj_dcache_parity);
assign arr_rd_data32_b = (~dcarr_rd_data[32]);
assign stickbit32 = (~(arr_rd_data32_b & inj_dcache_parity_b));
// #############################################################################################

// #############################################################################################
// Separate Data
// #############################################################################################
// Data Bits
assign dcarr_rd_data_wa = {dcarr_rd_data[0:31], stickbit32, dcarr_rd_data[33:127]};
assign dcarr_rd_data_wb = dcarr_rd_data[144:271];
assign dcarr_rd_data_wc = dcarr_rd_data[288:415];
assign dcarr_rd_data_wd = dcarr_rd_data[432:559];
assign dcarr_rd_data_we = dcarr_rd_data[576:703];
assign dcarr_rd_data_wf = dcarr_rd_data[720:847];
assign dcarr_rd_data_wg = dcarr_rd_data[864:991];
assign dcarr_rd_data_wh = dcarr_rd_data[1008:1135];

// Parity Bits
assign dcarr_rd_parity_wa = dcarr_rd_data[128:143];
assign dcarr_rd_parity_wb = dcarr_rd_data[272:287];
assign dcarr_rd_parity_wc = dcarr_rd_data[416:431];
assign dcarr_rd_parity_wd = dcarr_rd_data[560:575];
assign dcarr_rd_parity_we = dcarr_rd_data[704:719];
assign dcarr_rd_parity_wf = dcarr_rd_data[848:863];
assign dcarr_rd_parity_wg = dcarr_rd_data[992:1007];
assign dcarr_rd_parity_wh = dcarr_rd_data[1136:1151];
// #############################################################################################

// #############################################################################################
// Way A 16 Byte Rotator
// #############################################################################################
generate begin : l1dcrotrWA
   genvar bit;
   for (bit = 0; bit <= 7; bit = bit + 1) begin : l1dcrotrWA
      if (bit == 0) begin : sgrp
         tri_rot16s_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),
            .algebraic(ctl_dat_ex3_algebraic),
            .le_algebraic_sel(ctl_dat_ex3_le_alg_rotsel),
            .be_algebraic_sel(ctl_dat_ex3_le_ld_rotsel),

            .arr_data(dcarr_rd_data_wa[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wabcd[0]),
            .stq_byp_val(stq_byp_val_wabcd[0]),
            .stq7_rmw_data(stq7_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_wa[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_wa[bit * 16:(bit * 16) + 15]),
            .algebraic_bit(ex4_ld_alg_bit_wa),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_wa_scan_in[bit]),
            .scan_out(rot_wa_scan_out[bit])
         );
      end
      if (bit != 0) begin : grp
         tri_rot16_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),

            .arr_data(dcarr_rd_data_wa[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wabcd[0]),
            .stq_byp_val(stq_byp_val_wabcd[0]),
            .stq7_rmw_data(stq7_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_wa[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_wa[bit * 16:(bit * 16) + 15]),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_wa_scan_in[bit]),
            .scan_out(rot_wa_scan_out[bit])
         );
      end
   end
end
endgenerate
// #############################################################################################

// #############################################################################################
// Way B 16 Byte Rotator
// #############################################################################################
generate begin : l1dcrotrWB
   genvar bit;
   for (bit = 0; bit <= 7; bit = bit + 1) begin : l1dcrotrWB
      if (bit == 0) begin : sgrp
         tri_rot16s_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),
            .algebraic(ctl_dat_ex3_algebraic),
            .le_algebraic_sel(ctl_dat_ex3_le_alg_rotsel),
            .be_algebraic_sel(ctl_dat_ex3_le_ld_rotsel),

            .arr_data(dcarr_rd_data_wb[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wabcd[1]),
            .stq_byp_val(stq_byp_val_wabcd[1]),
            .stq7_rmw_data(stq7_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_wb[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_wb[bit * 16:(bit * 16) + 15]),
            .algebraic_bit(ex4_ld_alg_bit_wb),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_wb_scan_in[bit]),
            .scan_out(rot_wb_scan_out[bit])
         );
      end
      if (bit != 0) begin : grp
         tri_rot16_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),

            .arr_data(dcarr_rd_data_wb[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wabcd[1]),
            .stq_byp_val(stq_byp_val_wabcd[1]),
            .stq7_rmw_data(stq7_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_wb[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_wb[bit * 16:(bit * 16) + 15]),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_wb_scan_in[bit]),
            .scan_out(rot_wb_scan_out[bit])
         );
      end
   end
end
endgenerate
// #############################################################################################

// #############################################################################################
// Way C 16 Byte Rotator
// #############################################################################################
generate begin : l1dcrotrWC
   genvar bit;
   for (bit = 0; bit <= 7; bit = bit + 1) begin : l1dcrotrWC
      if (bit == 0) begin : sgrp
         tri_rot16s_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),
            .algebraic(ctl_dat_ex3_algebraic),
            .le_algebraic_sel(ctl_dat_ex3_le_alg_rotsel),
            .be_algebraic_sel(ctl_dat_ex3_le_ld_rotsel),

            .arr_data(dcarr_rd_data_wc[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wabcd[2]),
            .stq_byp_val(stq_byp_val_wabcd[2]),
            .stq7_rmw_data(stq7_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_wc[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_wc[bit * 16:(bit * 16) + 15]),
            .algebraic_bit(ex4_ld_alg_bit_wc),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_wc_scan_in[bit]),
            .scan_out(rot_wc_scan_out[bit])
         );
      end
      if (bit != 0) begin : grp
         tri_rot16_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),

            .arr_data(dcarr_rd_data_wc[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wabcd[2]),
            .stq_byp_val(stq_byp_val_wabcd[2]),
            .stq7_rmw_data(stq7_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_wc[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_wc[bit * 16:(bit * 16) + 15]),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_wc_scan_in[bit]),
            .scan_out(rot_wc_scan_out[bit])
         );
      end
   end
end
endgenerate
// #############################################################################################

// #############################################################################################
// Way D 16 Byte Rotator
// #############################################################################################
generate begin : l1dcrotrWD
   genvar bit;
   for (bit = 0; bit <= 7; bit = bit + 1) begin : l1dcrotrWD
      if (bit == 0) begin : sgrp
         tri_rot16s_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),
            .algebraic(ctl_dat_ex3_algebraic),
            .le_algebraic_sel(ctl_dat_ex3_le_alg_rotsel),
            .be_algebraic_sel(ctl_dat_ex3_le_ld_rotsel),

            .arr_data(dcarr_rd_data_wd[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wabcd[3]),
            .stq_byp_val(stq_byp_val_wabcd[3]),
            .stq7_rmw_data(stq7_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_wd[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_wd[bit * 16:(bit * 16) + 15]),
            .algebraic_bit(ex4_ld_alg_bit_wd),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_wd_scan_in[bit]),
            .scan_out(rot_wd_scan_out[bit])
         );
      end
      if (bit != 0) begin : grp
         tri_rot16_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),

            .arr_data(dcarr_rd_data_wd[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wabcd[3]),
            .stq_byp_val(stq_byp_val_wabcd[3]),
            .stq7_rmw_data(stq7_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wabcd[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_wd[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_wd[bit * 16:(bit * 16) + 15]),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_wd_scan_in[bit]),
            .scan_out(rot_wd_scan_out[bit])
         );
      end
   end
end
endgenerate
// #############################################################################################

// #############################################################################################
// Way E 16 Byte Rotator
// #############################################################################################
generate begin : l1dcrotrWE
   genvar bit;
   for (bit = 0; bit <= 7; bit = bit + 1) begin : l1dcrotrWE
      if (bit == 0) begin : sgrp
         tri_rot16s_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),
            .algebraic(ctl_dat_ex3_algebraic),
            .le_algebraic_sel(ctl_dat_ex3_le_alg_rotsel),
            .be_algebraic_sel(ctl_dat_ex3_le_ld_rotsel),

            .arr_data(dcarr_rd_data_we[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wefgh[0]),
            .stq_byp_val(stq_byp_val_wefgh[0]),
            .stq7_rmw_data(stq7_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_we[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_we[bit * 16:(bit * 16) + 15]),
            .algebraic_bit(ex4_ld_alg_bit_we),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_we_scan_in[bit]),
            .scan_out(rot_we_scan_out[bit])
         );
      end
      if (bit != 0) begin : grp
         tri_rot16_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),

            .arr_data(dcarr_rd_data_we[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wefgh[0]),
            .stq_byp_val(stq_byp_val_wefgh[0]),
            .stq7_rmw_data(stq7_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_we[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_we[bit * 16:(bit * 16) + 15]),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_we_scan_in[bit]),
            .scan_out(rot_we_scan_out[bit])
         );
      end
   end
end
endgenerate
// #############################################################################################

// #############################################################################################
// Way F 16 Byte Rotator
// #############################################################################################
generate begin : l1dcrotrWF
   genvar bit;
   for (bit = 0; bit <= 7; bit = bit + 1) begin : l1dcrotrWF
      if (bit == 0) begin : sgrp
         tri_rot16s_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),
            .algebraic(ctl_dat_ex3_algebraic),
            .le_algebraic_sel(ctl_dat_ex3_le_alg_rotsel),
            .be_algebraic_sel(ctl_dat_ex3_le_ld_rotsel),

            .arr_data(dcarr_rd_data_wf[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wefgh[1]),
            .stq_byp_val(stq_byp_val_wefgh[1]),
            .stq7_rmw_data(stq7_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_wf[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_wf[bit * 16:(bit * 16) + 15]),
            .algebraic_bit(ex4_ld_alg_bit_wf),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_wf_scan_in[bit]),
            .scan_out(rot_wf_scan_out[bit])
         );
      end
      if (bit != 0) begin : grp
         tri_rot16_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),

            .arr_data(dcarr_rd_data_wf[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wefgh[1]),
            .stq_byp_val(stq_byp_val_wefgh[1]),
            .stq7_rmw_data(stq7_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_wf[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_wf[bit * 16:(bit * 16) + 15]),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_wf_scan_in[bit]),
            .scan_out(rot_wf_scan_out[bit])
         );
      end
   end
end
endgenerate
// #############################################################################################

// #############################################################################################
// Way G 16 Byte Rotator
// #############################################################################################
generate begin : l1dcrotrWG
   genvar bit;
   for (bit = 0; bit <= 7; bit = bit + 1) begin : l1dcrotrWG
      if (bit == 0) begin : sgrp
         tri_rot16s_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),
            .algebraic(ctl_dat_ex3_algebraic),
            .le_algebraic_sel(ctl_dat_ex3_le_alg_rotsel),
            .be_algebraic_sel(ctl_dat_ex3_le_ld_rotsel),

            .arr_data(dcarr_rd_data_wg[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wefgh[2]),
            .stq_byp_val(stq_byp_val_wefgh[2]),
            .stq7_rmw_data(stq7_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_wg[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_wg[bit * 16:(bit * 16) + 15]),
            .algebraic_bit(ex4_ld_alg_bit_wg),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_wg_scan_in[bit]),
            .scan_out(rot_wg_scan_out[bit])
         );
      end
      if (bit != 0) begin : grp
         tri_rot16_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),

            .arr_data(dcarr_rd_data_wg[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wefgh[2]),
            .stq_byp_val(stq_byp_val_wefgh[2]),
            .stq7_rmw_data(stq7_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_wg[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_wg[bit * 16:(bit * 16) + 15]),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_wg_scan_in[bit]),
            .scan_out(rot_wg_scan_out[bit])
         );
      end
   end
end
endgenerate
// #############################################################################################

// #############################################################################################
// Way H 16 Byte Rotator
// #############################################################################################
generate begin : l1dcrotrWH
   genvar bit;
   for (bit = 0; bit <= 7; bit = bit + 1) begin : l1dcrotrWH
      if (bit == 0) begin : sgrp
         tri_rot16s_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),
            .algebraic(ctl_dat_ex3_algebraic),
            .le_algebraic_sel(ctl_dat_ex3_le_alg_rotsel),
            .be_algebraic_sel(ctl_dat_ex3_le_ld_rotsel),

            .arr_data(dcarr_rd_data_wh[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wefgh[3]),
            .stq_byp_val(stq_byp_val_wefgh[3]),
            .stq7_rmw_data(stq7_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_wh[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_wh[bit * 16:(bit * 16) + 15]),
            .algebraic_bit(ex4_ld_alg_bit_wh),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_wh_scan_in[bit]),
            .scan_out(rot_wh_scan_out[bit])
         );
      end
      if (bit != 0) begin : grp
         tri_rot16_ru  bits(
            .opsize(ctl_dat_ex3_opsize),
            .le(ctl_dat_ex3_le_mode),
            .le_rotate_sel(ctl_dat_ex3_le_ld_rotsel),
            .be_rotate_sel(ctl_dat_ex3_be_ld_rotsel),

            .arr_data(dcarr_rd_data_wh[bit * 16:(bit * 16) + 15]),
            .stq7_byp_val(stq7_byp_val_wefgh[3]),
            .stq_byp_val(stq_byp_val_wefgh[3]),
            .stq7_rmw_data(stq7_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .stq8_rmw_data(stq8_byp_data_wefgh[bit * 16:(bit * 16) + 15]),
            .data_latched(dcarr_buf_data_wh[bit * 16:(bit * 16) + 15]),
            .data_rot(ex4_ld_data_rot_wh[bit * 16:(bit * 16) + 15]),

            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .act(ex3_stg_act),
            .func_sl_force(func_sl_force),
            .delay_lclkr_dc(delay_lclkr_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .func_sl_thold_0_b(func_sl_thold_0_b),
            .sg_0(sg_0),
            .scan_in(rot_wh_scan_in[bit]),
            .scan_out(rot_wh_scan_out[bit])
         );
      end
   end
end
endgenerate
// #############################################################################################

// #############################################################################################
// Parity Check
// #############################################################################################
generate begin : parBdet
   genvar bit;
   for (bit = 0; bit <= 15; bit = bit + 1) begin : parBdet
      assign dcarr_perr_byte_wa[bit] = dcarr_buf_data_wa[bit + 0]  ^ dcarr_buf_data_wa[bit + 16] ^
                                       dcarr_buf_data_wa[bit + 32] ^ dcarr_buf_data_wa[bit + 48] ^
                                       dcarr_buf_data_wa[bit + 64] ^ dcarr_buf_data_wa[bit + 80] ^
                                       dcarr_buf_data_wa[bit + 96] ^ dcarr_buf_data_wa[bit + 112] ^
                                       dcarr_rd_parity_wa[bit];

      assign dcarr_perr_byte_wb[bit] = dcarr_buf_data_wb[bit + 0]  ^ dcarr_buf_data_wb[bit + 16] ^
                                       dcarr_buf_data_wb[bit + 32] ^ dcarr_buf_data_wb[bit + 48] ^
                                       dcarr_buf_data_wb[bit + 64] ^ dcarr_buf_data_wb[bit + 80] ^
                                       dcarr_buf_data_wb[bit + 96] ^ dcarr_buf_data_wb[bit + 112] ^
                                       dcarr_rd_parity_wb[bit];

      assign dcarr_perr_byte_wc[bit] = dcarr_buf_data_wc[bit + 0]  ^ dcarr_buf_data_wc[bit + 16] ^
                                       dcarr_buf_data_wc[bit + 32] ^ dcarr_buf_data_wc[bit + 48] ^
                                       dcarr_buf_data_wc[bit + 64] ^ dcarr_buf_data_wc[bit + 80] ^
                                       dcarr_buf_data_wc[bit + 96] ^ dcarr_buf_data_wc[bit + 112] ^
                                       dcarr_rd_parity_wc[bit];

      assign dcarr_perr_byte_wd[bit] = dcarr_buf_data_wd[bit + 0]  ^ dcarr_buf_data_wd[bit + 16] ^
                                       dcarr_buf_data_wd[bit + 32] ^ dcarr_buf_data_wd[bit + 48] ^
                                       dcarr_buf_data_wd[bit + 64] ^ dcarr_buf_data_wd[bit + 80] ^
                                       dcarr_buf_data_wd[bit + 96] ^ dcarr_buf_data_wd[bit + 112] ^
                                       dcarr_rd_parity_wd[bit];

      assign dcarr_perr_byte_we[bit] = dcarr_buf_data_we[bit + 0]  ^ dcarr_buf_data_we[bit + 16] ^
                                       dcarr_buf_data_we[bit + 32] ^ dcarr_buf_data_we[bit + 48] ^
                                       dcarr_buf_data_we[bit + 64] ^ dcarr_buf_data_we[bit + 80] ^
                                       dcarr_buf_data_we[bit + 96] ^ dcarr_buf_data_we[bit + 112] ^
                                       dcarr_rd_parity_we[bit];

      assign dcarr_perr_byte_wf[bit] = dcarr_buf_data_wf[bit + 0]  ^ dcarr_buf_data_wf[bit + 16] ^
                                       dcarr_buf_data_wf[bit + 32] ^ dcarr_buf_data_wf[bit + 48] ^
                                       dcarr_buf_data_wf[bit + 64] ^ dcarr_buf_data_wf[bit + 80] ^
                                       dcarr_buf_data_wf[bit + 96] ^ dcarr_buf_data_wf[bit + 112] ^
                                       dcarr_rd_parity_wf[bit];

      assign dcarr_perr_byte_wg[bit] = dcarr_buf_data_wg[bit + 0]  ^ dcarr_buf_data_wg[bit + 16] ^
                                       dcarr_buf_data_wg[bit + 32] ^ dcarr_buf_data_wg[bit + 48] ^
                                       dcarr_buf_data_wg[bit + 64] ^ dcarr_buf_data_wg[bit + 80] ^
                                       dcarr_buf_data_wg[bit + 96] ^ dcarr_buf_data_wg[bit + 112] ^
                                       dcarr_rd_parity_wg[bit];

      assign dcarr_perr_byte_wh[bit] = dcarr_buf_data_wh[bit + 0]  ^ dcarr_buf_data_wh[bit + 16] ^
                                       dcarr_buf_data_wh[bit + 32] ^ dcarr_buf_data_wh[bit + 48] ^
                                       dcarr_buf_data_wh[bit + 64] ^ dcarr_buf_data_wh[bit + 80] ^
                                       dcarr_buf_data_wh[bit + 96] ^ dcarr_buf_data_wh[bit + 112] ^
                                       dcarr_rd_parity_wh[bit];
   end
end
endgenerate

// Report a Parity error if the data is not being bypassed due to a store to the same address
assign dcarr_perr_det_wa = |(dcarr_perr_byte_wa) & ~stq_byp_val_wabcd[0];
assign dcarr_perr_det_wb = |(dcarr_perr_byte_wb) & ~stq_byp_val_wabcd[1];
assign dcarr_perr_det_wc = |(dcarr_perr_byte_wc) & ~stq_byp_val_wabcd[2];
assign dcarr_perr_det_wd = |(dcarr_perr_byte_wd) & ~stq_byp_val_wabcd[3];
assign dcarr_perr_det_we = |(dcarr_perr_byte_we) & ~stq_byp_val_wefgh[0];
assign dcarr_perr_det_wf = |(dcarr_perr_byte_wf) & ~stq_byp_val_wefgh[1];
assign dcarr_perr_det_wg = |(dcarr_perr_byte_wg) & ~stq_byp_val_wefgh[2];
assign dcarr_perr_det_wh = |(dcarr_perr_byte_wh) & ~stq_byp_val_wefgh[3];

// EX4/STQ6 Data Cache Array Parity Error Detected
assign dcarr_data_perr_way = {dcarr_perr_det_wa, dcarr_perr_det_wb, dcarr_perr_det_wc, dcarr_perr_det_wd,
                              dcarr_perr_det_we, dcarr_perr_det_wf, dcarr_perr_det_wg, dcarr_perr_det_wh};

// #############################################################################################

// #############################################################################################
// Algebraic Sign Extension
// #############################################################################################

// Data Fixup
generate begin : ldData
   genvar byte;
   for (byte = 0; byte <= 15; byte = byte + 1) begin : ldData
      assign ex4_ld_data_swzl_wa[byte * 8:(byte * 8) + 7] = {ex4_ld_data_rot_wa[byte + 0],
                                                             ex4_ld_data_rot_wa[byte + 16],
                                                             ex4_ld_data_rot_wa[byte + 32],
                                                             ex4_ld_data_rot_wa[byte + 48],
                                                             ex4_ld_data_rot_wa[byte + 64],
                                                             ex4_ld_data_rot_wa[byte + 80],
                                                             ex4_ld_data_rot_wa[byte + 96],
                                                             ex4_ld_data_rot_wa[byte + 112]};

      assign ex4_ld_data_swzl_wb[byte * 8:(byte * 8) + 7] = {ex4_ld_data_rot_wb[byte + 0],
                                                             ex4_ld_data_rot_wb[byte + 16],
                                                             ex4_ld_data_rot_wb[byte + 32],
                                                             ex4_ld_data_rot_wb[byte + 48],
                                                             ex4_ld_data_rot_wb[byte + 64],
                                                             ex4_ld_data_rot_wb[byte + 80],
                                                             ex4_ld_data_rot_wb[byte + 96],
                                                             ex4_ld_data_rot_wb[byte + 112]};

      assign ex4_ld_data_swzl_wc[byte * 8:(byte * 8) + 7] = {ex4_ld_data_rot_wc[byte + 0],
                                                             ex4_ld_data_rot_wc[byte + 16],
                                                             ex4_ld_data_rot_wc[byte + 32],
                                                             ex4_ld_data_rot_wc[byte + 48],
                                                             ex4_ld_data_rot_wc[byte + 64],
                                                             ex4_ld_data_rot_wc[byte + 80],
                                                             ex4_ld_data_rot_wc[byte + 96],
                                                             ex4_ld_data_rot_wc[byte + 112]};

      assign ex4_ld_data_swzl_wd[byte * 8:(byte * 8) + 7] = {ex4_ld_data_rot_wd[byte + 0],
                                                             ex4_ld_data_rot_wd[byte + 16],
                                                             ex4_ld_data_rot_wd[byte + 32],
                                                             ex4_ld_data_rot_wd[byte + 48],
                                                             ex4_ld_data_rot_wd[byte + 64],
                                                             ex4_ld_data_rot_wd[byte + 80],
                                                             ex4_ld_data_rot_wd[byte + 96],
                                                             ex4_ld_data_rot_wd[byte + 112]};

      assign ex4_ld_data_swzl_we[byte * 8:(byte * 8) + 7] = {ex4_ld_data_rot_we[byte + 0],
                                                             ex4_ld_data_rot_we[byte + 16],
                                                             ex4_ld_data_rot_we[byte + 32],
                                                             ex4_ld_data_rot_we[byte + 48],
                                                             ex4_ld_data_rot_we[byte + 64],
                                                             ex4_ld_data_rot_we[byte + 80],
                                                             ex4_ld_data_rot_we[byte + 96],
                                                             ex4_ld_data_rot_we[byte + 112]};

      assign ex4_ld_data_swzl_wf[byte * 8:(byte * 8) + 7] = {ex4_ld_data_rot_wf[byte + 0],
                                                             ex4_ld_data_rot_wf[byte + 16],
                                                             ex4_ld_data_rot_wf[byte + 32],
                                                             ex4_ld_data_rot_wf[byte + 48],
                                                             ex4_ld_data_rot_wf[byte + 64],
                                                             ex4_ld_data_rot_wf[byte + 80],
                                                             ex4_ld_data_rot_wf[byte + 96],
                                                             ex4_ld_data_rot_wf[byte + 112]};

      assign ex4_ld_data_swzl_wg[byte * 8:(byte * 8) + 7] = {ex4_ld_data_rot_wg[byte + 0],
                                                             ex4_ld_data_rot_wg[byte + 16],
                                                             ex4_ld_data_rot_wg[byte + 32],
                                                             ex4_ld_data_rot_wg[byte + 48],
                                                             ex4_ld_data_rot_wg[byte + 64],
                                                             ex4_ld_data_rot_wg[byte + 80],
                                                             ex4_ld_data_rot_wg[byte + 96],
                                                             ex4_ld_data_rot_wg[byte + 112]};

      assign ex4_ld_data_swzl_wh[byte * 8:(byte * 8) + 7] = {ex4_ld_data_rot_wh[byte + 0],
                                                             ex4_ld_data_rot_wh[byte + 16],
                                                             ex4_ld_data_rot_wh[byte + 32],
                                                             ex4_ld_data_rot_wh[byte + 48],
                                                             ex4_ld_data_rot_wh[byte + 64],
                                                             ex4_ld_data_rot_wh[byte + 80],
                                                             ex4_ld_data_rot_wh[byte + 96],
                                                             ex4_ld_data_rot_wh[byte + 112]};
   end
end
endgenerate

// Non-Sign Extension
assign ex4_ld_data_wa[0:64] = {1'b0, ex4_ld_data_swzl_wa[0:63]};
assign ex4_ld_data_wb[0:64] = {1'b0, ex4_ld_data_swzl_wb[0:63]};
assign ex4_ld_data_wc[0:64] = {1'b0, ex4_ld_data_swzl_wc[0:63]};
assign ex4_ld_data_wd[0:64] = {1'b0, ex4_ld_data_swzl_wd[0:63]};
assign ex4_ld_data_we[0:64] = {1'b0, ex4_ld_data_swzl_we[0:63]};
assign ex4_ld_data_wf[0:64] = {1'b0, ex4_ld_data_swzl_wf[0:63]};
assign ex4_ld_data_wg[0:64] = {1'b0, ex4_ld_data_swzl_wg[0:63]};
assign ex4_ld_data_wh[0:64] = {1'b0, ex4_ld_data_swzl_wh[0:63]};
assign ex4_ld_data_wa[113:128] = ex4_ld_data_swzl_wa[112:127];
assign ex4_ld_data_wb[113:128] = ex4_ld_data_swzl_wb[112:127];
assign ex4_ld_data_wc[113:128] = ex4_ld_data_swzl_wc[112:127];
assign ex4_ld_data_wd[113:128] = ex4_ld_data_swzl_wd[112:127];
assign ex4_ld_data_we[113:128] = ex4_ld_data_swzl_we[112:127];
assign ex4_ld_data_wf[113:128] = ex4_ld_data_swzl_wf[112:127];
assign ex4_ld_data_wg[113:128] = ex4_ld_data_swzl_wg[112:127];
assign ex4_ld_data_wh[113:128] = ex4_ld_data_swzl_wh[112:127];

// Sign Extension
generate begin : algExt
   genvar bit;
   for (bit = 0; bit <= 47; bit = bit + 1) begin : algExt
      assign ex4_ld_data_wa[65 + bit] = ex4_ld_data_swzl_wa[64 + bit] | ex4_ld_alg_bit_wa[bit/8];
      assign ex4_ld_data_wb[65 + bit] = ex4_ld_data_swzl_wb[64 + bit] | ex4_ld_alg_bit_wb[bit/8];
      assign ex4_ld_data_wc[65 + bit] = ex4_ld_data_swzl_wc[64 + bit] | ex4_ld_alg_bit_wc[bit/8];
      assign ex4_ld_data_wd[65 + bit] = ex4_ld_data_swzl_wd[64 + bit] | ex4_ld_alg_bit_wd[bit/8];
      assign ex4_ld_data_we[65 + bit] = ex4_ld_data_swzl_we[64 + bit] | ex4_ld_alg_bit_we[bit/8];
      assign ex4_ld_data_wf[65 + bit] = ex4_ld_data_swzl_wf[64 + bit] | ex4_ld_alg_bit_wf[bit/8];
      assign ex4_ld_data_wg[65 + bit] = ex4_ld_data_swzl_wg[64 + bit] | ex4_ld_alg_bit_wg[bit/8];
      assign ex4_ld_data_wh[65 + bit] = ex4_ld_data_swzl_wh[64 + bit] | ex4_ld_alg_bit_wh[bit/8];
   end
end
endgenerate
// #############################################################################################

// #############################################################################################
// 8 Way Mux Select
// #############################################################################################
assign ex5_ld_hit_data_d = (ex4_ld_data_wa[(129 - `STQ_DATA_SIZE):128] & {`STQ_DATA_SIZE{ctl_dat_ex4_way_hit[0]}}) |
                           (ex4_ld_data_wb[(129 - `STQ_DATA_SIZE):128] & {`STQ_DATA_SIZE{ctl_dat_ex4_way_hit[1]}}) |
                           (ex4_ld_data_wc[(129 - `STQ_DATA_SIZE):128] & {`STQ_DATA_SIZE{ctl_dat_ex4_way_hit[2]}}) |
                           (ex4_ld_data_wd[(129 - `STQ_DATA_SIZE):128] & {`STQ_DATA_SIZE{ctl_dat_ex4_way_hit[3]}}) |
                           (ex4_ld_data_we[(129 - `STQ_DATA_SIZE):128] & {`STQ_DATA_SIZE{ctl_dat_ex4_way_hit[4]}}) |
                           (ex4_ld_data_wf[(129 - `STQ_DATA_SIZE):128] & {`STQ_DATA_SIZE{ctl_dat_ex4_way_hit[5]}}) |
                           (ex4_ld_data_wg[(129 - `STQ_DATA_SIZE):128] & {`STQ_DATA_SIZE{ctl_dat_ex4_way_hit[6]}}) |
                           (ex4_ld_data_wh[(129 - `STQ_DATA_SIZE):128] & {`STQ_DATA_SIZE{ctl_dat_ex4_way_hit[7]}});
// #############################################################################################

// #############################################################################################
// Outputs
// #############################################################################################
assign ex5_ld_hit_data = ex5_ld_hit_data_q;

// Read-Modify-Write Path
assign stq6_rd_data_wa = {dcarr_rd_data_wa, dcarr_rd_parity_wa};
assign stq6_rd_data_wb = {dcarr_rd_data_wb, dcarr_rd_parity_wb};
assign stq6_rd_data_wc = {dcarr_rd_data_wc, dcarr_rd_parity_wc};
assign stq6_rd_data_wd = {dcarr_rd_data_wd, dcarr_rd_parity_wd};
assign stq6_rd_data_we = {dcarr_rd_data_we, dcarr_rd_parity_we};
assign stq6_rd_data_wf = {dcarr_rd_data_wf, dcarr_rd_parity_wf};
assign stq6_rd_data_wg = {dcarr_rd_data_wg, dcarr_rd_parity_wg};
assign stq6_rd_data_wh = {dcarr_rd_data_wh, dcarr_rd_parity_wh};

// #############################################################################################

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Registers
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

tri_regk #(.WIDTH(`STQ_DATA_SIZE), .INIT(0), .NEEDS_SRESET(1)) ex5_ld_hit_data_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_ld_hit_data_reg_offset:ex5_ld_hit_data_reg_offset + `STQ_DATA_SIZE - 1]),
   .scout(sov[ex5_ld_hit_data_reg_offset:ex5_ld_hit_data_reg_offset + `STQ_DATA_SIZE - 1]),
   .din(ex5_ld_hit_data_d),
   .dout(ex5_ld_hit_data_q)
);

assign siv[0:scan_right] = {sov[1:scan_right], scan_in[0]};
assign scan_out[0] = sov[0];

assign rot_wa_scan_in[0:7] = {rot_wa_scan_out[1:7], scan_in[1]};
assign rot_wb_scan_in[0:7] = {rot_wb_scan_out[1:7], rot_wa_scan_out[0]};
assign scan_out[1] = rot_wb_scan_out[0];

assign rot_wc_scan_in[0:7] = {rot_wc_scan_out[1:7], scan_in[2]};
assign rot_wd_scan_in[0:7] = {rot_wd_scan_out[1:7], rot_wc_scan_out[0]};
assign scan_out[2] = rot_wd_scan_out[0];

assign rot_we_scan_in[0:7] = {rot_we_scan_out[1:7], scan_in[3]};
assign rot_wf_scan_in[0:7] = {rot_wf_scan_out[1:7], rot_we_scan_out[0]};
assign scan_out[3] = rot_wf_scan_out[0];

assign rot_wg_scan_in[0:7] = {rot_wg_scan_out[1:7], scan_in[4]};
assign rot_wh_scan_in[0:7] = {rot_wh_scan_out[1:7], rot_wg_scan_out[0]};
assign scan_out[4] = rot_wh_scan_out[0];

endmodule
