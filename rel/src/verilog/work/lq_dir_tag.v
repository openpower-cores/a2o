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

//  Description:  XU LSU L1 Data Directory Tag Wrapper
//*****************************************************************************

// ##########################################################################################
// Tag Compare
// 1) Contains an Array of Tags
// 2) Updates Tag on Reload
// 3) Contains Hit Logic
// 4) Outputs Way Hit indicators
// ##########################################################################################

`include "tri_a2o.vh"


module lq_dir_tag(
   dcc_dir_binv3_ex3_stg_act,
   dcc_dir_stq1_stg_act,
   dcc_dir_stq2_stg_act,
   dcc_dir_stq3_stg_act,
   rel_way_upd_a,
   rel_way_upd_b,
   rel_way_upd_c,
   rel_way_upd_d,
   rel_way_upd_e,
   rel_way_upd_f,
   rel_way_upd_g,
   rel_way_upd_h,
   dcc_dir_ex2_binv_val,
   spr_xucr0_dcdis,
   dcc_dir_ex4_p_addr,
   dcc_dir_ex3_ddir_acc,
   lsq_ctl_stq1_addr,
   stq2_ddir_acc,
   pc_lq_inj_dcachedir_ldp_parity,
   pc_lq_inj_dcachedir_stp_parity,
   dir_arr_rd_data0,
   dir_arr_rd_data1,
   dir_arr_wr_way,
   dir_arr_wr_addr,
   dir_arr_wr_data,
   ex4_way_cmp_a,
   ex4_way_cmp_b,
   ex4_way_cmp_c,
   ex4_way_cmp_d,
   ex4_way_cmp_e,
   ex4_way_cmp_f,
   ex4_way_cmp_g,
   ex4_way_cmp_h,
   ex4_tag_perr_way,
   dir_dcc_ex4_way_tag_a,
   dir_dcc_ex4_way_tag_b,
   dir_dcc_ex4_way_tag_c,
   dir_dcc_ex4_way_tag_d,
   dir_dcc_ex4_way_tag_e,
   dir_dcc_ex4_way_tag_f,
   dir_dcc_ex4_way_tag_g,
   dir_dcc_ex4_way_tag_h,
   dir_dcc_ex4_way_par_a,
   dir_dcc_ex4_way_par_b,
   dir_dcc_ex4_way_par_c,
   dir_dcc_ex4_way_par_d,
   dir_dcc_ex4_way_par_e,
   dir_dcc_ex4_way_par_f,
   dir_dcc_ex4_way_par_g,
   dir_dcc_ex4_way_par_h,
   stq3_way_cmp_a,
   stq3_way_cmp_b,
   stq3_way_cmp_c,
   stq3_way_cmp_d,
   stq3_way_cmp_e,
   stq3_way_cmp_f,
   stq3_way_cmp_g,
   stq3_way_cmp_h,
   stq3_tag_way_perr,
   vdd,
   gnd,
   nclk,
   sg_0,
   func_sl_thold_0_b,
   func_sl_force,
   func_slp_sl_thold_0_b,
   func_slp_sl_force,
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
//parameter                                                      EXPAND_TYPE = 2;
//parameter                                                      `DC_SIZE = 15;
//parameter                                                      `CL_SIZE = 6;
//parameter                                                      `REAL_IFAR_WIDTH = 42;
parameter                                                      WAYDATASIZE = 34;		// TagSize + Parity Bits
parameter                                                      PARBITS = 4;

// Stage ACT Signals
input                                                          dcc_dir_binv3_ex3_stg_act;
input                                                          dcc_dir_stq1_stg_act;
input                                                          dcc_dir_stq2_stg_act;
input                                                          dcc_dir_stq3_stg_act;

// Reload Update Directory
input                                                          rel_way_upd_a;
input                                                          rel_way_upd_b;
input                                                          rel_way_upd_c;
input                                                          rel_way_upd_d;
input                                                          rel_way_upd_e;
input                                                          rel_way_upd_f;
input                                                          rel_way_upd_g;
input                                                          rel_way_upd_h;

// Back-Invalidate
input                                                          dcc_dir_ex2_binv_val;

// SPR Bits
input                                                          spr_xucr0_dcdis;

// LQ Pipe
input [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                    dcc_dir_ex4_p_addr;
input                                                          dcc_dir_ex3_ddir_acc;

// Commit Pipe
input [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                        lsq_ctl_stq1_addr;
input                                                          stq2_ddir_acc;

// Error Inject
input                                                          pc_lq_inj_dcachedir_ldp_parity;
input                                                          pc_lq_inj_dcachedir_stp_parity;

// L1 Directory Read Interface
input [0:(8*WAYDATASIZE)-1]                                    dir_arr_rd_data0;
input [0:(8*WAYDATASIZE)-1]                                    dir_arr_rd_data1;

// L1 Directory Write Interface
output [0:7]                                                   dir_arr_wr_way;
output [64-(`DC_SIZE-3):63-`CL_SIZE]                           dir_arr_wr_addr;
output [64-`REAL_IFAR_WIDTH:64-`REAL_IFAR_WIDTH+WAYDATASIZE-1] dir_arr_wr_data;

// LQ Pipe
output                                                         ex4_way_cmp_a;
output                                                         ex4_way_cmp_b;
output                                                         ex4_way_cmp_c;
output                                                         ex4_way_cmp_d;
output                                                         ex4_way_cmp_e;
output                                                         ex4_way_cmp_f;
output                                                         ex4_way_cmp_g;
output                                                         ex4_way_cmp_h;
output [0:7]                                                   ex4_tag_perr_way;

// L1 Directory Contents
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_a;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_b;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_c;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_d;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_e;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_f;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_g;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_h;
output [0:PARBITS-1]                                           dir_dcc_ex4_way_par_a;
output [0:PARBITS-1]                                           dir_dcc_ex4_way_par_b;
output [0:PARBITS-1]                                           dir_dcc_ex4_way_par_c;
output [0:PARBITS-1]                                           dir_dcc_ex4_way_par_d;
output [0:PARBITS-1]                                           dir_dcc_ex4_way_par_e;
output [0:PARBITS-1]                                           dir_dcc_ex4_way_par_f;
output [0:PARBITS-1]                                           dir_dcc_ex4_way_par_g;
output [0:PARBITS-1]                                           dir_dcc_ex4_way_par_h;

// Commit Pipe
output                                                         stq3_way_cmp_a;
output                                                         stq3_way_cmp_b;
output                                                         stq3_way_cmp_c;
output                                                         stq3_way_cmp_d;
output                                                         stq3_way_cmp_e;
output                                                         stq3_way_cmp_f;
output                                                         stq3_way_cmp_g;
output                                                         stq3_way_cmp_h;
output [0:7]                                                   stq3_tag_way_perr;



inout                                                          vdd;


inout                                                          gnd;

(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

input [0:`NCLK_WIDTH-1]                                        nclk;
input                                                          sg_0;
input                                                          func_sl_thold_0_b;
input                                                          func_sl_force;
input                                                          func_slp_sl_thold_0_b;
input                                                          func_slp_sl_force;
input                                                          d_mode_dc;
input                                                          delay_lclkr_dc;
input                                                          mpw1_dc_b;
input                                                          mpw2_dc_b;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input                                                          scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output                                                         scan_out;

//--------------------------
// components
//--------------------------

//--------------------------
// signals
//--------------------------
parameter                                                      uprTagBit = 64 - `REAL_IFAR_WIDTH;
parameter                                                      lwrTagBit = 63 - (`DC_SIZE - 3);
parameter                                                      tagSize = lwrTagBit - uprTagBit + 1;
parameter                                                      parExtCalc = 8 - (tagSize % 8);
parameter                                                      uprCClassBit = 64 - (`DC_SIZE - 3);
parameter                                                      lwrCClassBit = 63 - `CL_SIZE;

wire [uprCClassBit:lwrCClassBit]                               arr_wr_addr;
wire [uprTagBit:lwrTagBit]                                     arr_wr_data;
wire                                                           p0_way_cmp_a;
wire                                                           p0_way_cmp_b;
wire                                                           p0_way_cmp_c;
wire                                                           p0_way_cmp_d;
wire                                                           p0_way_cmp_e;
wire                                                           p0_way_cmp_f;
wire                                                           p0_way_cmp_g;
wire                                                           p0_way_cmp_h;
wire                                                           p1_way_cmp_a;
wire                                                           p1_way_cmp_b;
wire                                                           p1_way_cmp_c;
wire                                                           p1_way_cmp_d;
wire                                                           p1_way_cmp_e;
wire                                                           p1_way_cmp_f;
wire                                                           p1_way_cmp_g;
wire                                                           p1_way_cmp_h;
wire                                                           ex3_binv_val_d;
wire                                                           ex3_binv_val_q;
wire [uprTagBit:lwrTagBit]                                     p0_way_tag_a;
wire [uprTagBit:lwrTagBit]                                     p0_way_tag_b;
wire [uprTagBit:lwrTagBit]                                     p0_way_tag_c;
wire [uprTagBit:lwrTagBit]                                     p0_way_tag_d;
wire [uprTagBit:lwrTagBit]                                     p0_way_tag_e;
wire [uprTagBit:lwrTagBit]                                     p0_way_tag_f;
wire [uprTagBit:lwrTagBit]                                     p0_way_tag_g;
wire [uprTagBit:lwrTagBit]                                     p0_way_tag_h;
wire [uprTagBit:lwrTagBit]                                     p1_way_tag_a;
wire [uprTagBit:lwrTagBit]                                     p1_way_tag_b;
wire [uprTagBit:lwrTagBit]                                     p1_way_tag_c;
wire [uprTagBit:lwrTagBit]                                     p1_way_tag_d;
wire [uprTagBit:lwrTagBit]                                     p1_way_tag_e;
wire [uprTagBit:lwrTagBit]                                     p1_way_tag_f;
wire [uprTagBit:lwrTagBit]                                     p1_way_tag_g;
wire [uprTagBit:lwrTagBit]                                     p1_way_tag_h;
wire                                                           inj_ddir_ldp_parity_d;
wire                                                           inj_ddir_ldp_parity_q;
wire                                                           inj_ddir_stp_parity_d;
wire                                                           inj_ddir_stp_parity_q;
wire [uprTagBit:lwrCClassBit]                                  stq2_addr_d;
wire [uprTagBit:lwrCClassBit]                                  stq2_addr_q;
wire [uprTagBit:lwrCClassBit]                                  stq3_addr_d;
wire [uprTagBit:lwrCClassBit]                                  stq3_addr_q;
wire [uprTagBit:lwrCClassBit]                                  stq4_addr_d;
wire [uprTagBit:lwrCClassBit]                                  stq4_addr_q;
wire                                                           p0_par_err_det_a;
wire                                                           p0_par_err_det_b;
wire                                                           p0_par_err_det_c;
wire                                                           p0_par_err_det_d;
wire                                                           p0_par_err_det_e;
wire                                                           p0_par_err_det_f;
wire                                                           p0_par_err_det_g;
wire                                                           p0_par_err_det_h;
wire                                                           p1_par_err_det_a;
wire                                                           p1_par_err_det_b;
wire                                                           p1_par_err_det_c;
wire                                                           p1_par_err_det_d;
wire                                                           p1_par_err_det_e;
wire                                                           p1_par_err_det_f;
wire                                                           p1_par_err_det_g;
wire                                                           p1_par_err_det_h;
wire [0:PARBITS-1]                                             p0_way_par_a;
wire [0:PARBITS-1]                                             p0_way_par_b;
wire [0:PARBITS-1]                                             p0_way_par_c;
wire [0:PARBITS-1]                                             p0_way_par_d;
wire [0:PARBITS-1]                                             p0_way_par_e;
wire [0:PARBITS-1]                                             p0_way_par_f;
wire [0:PARBITS-1]                                             p0_way_par_g;
wire [0:PARBITS-1]                                             p0_way_par_h;
wire [0:7]                                                     ex4_en_par_chk_d;
wire [0:7]                                                     ex4_en_par_chk_q;
wire                                                           ex4_perr_det_a;
wire                                                           ex4_perr_det_b;
wire                                                           ex4_perr_det_c;
wire                                                           ex4_perr_det_d;
wire                                                           ex4_perr_det_e;
wire                                                           ex4_perr_det_f;
wire                                                           ex4_perr_det_g;
wire                                                           ex4_perr_det_h;
wire [0:7]                                                     stq3_en_par_chk_d;
wire [0:7]                                                     stq3_en_par_chk_q;
wire                                                           stq3_perr_det_a;
wire                                                           stq3_perr_det_b;
wire                                                           stq3_perr_det_c;
wire                                                           stq3_perr_det_d;
wire                                                           stq3_perr_det_e;
wire                                                           stq3_perr_det_f;
wire                                                           stq3_perr_det_g;
wire                                                           stq3_perr_det_h;

//--------------------------
// constants
//--------------------------
parameter                                                      ex3_binv_val_offset = 0;
parameter                                                      inj_ddir_ldp_parity_offset = ex3_binv_val_offset + 1;
parameter                                                      inj_ddir_stp_parity_offset = inj_ddir_ldp_parity_offset + 1;
parameter                                                      stq2_addr_offset = inj_ddir_stp_parity_offset + 1;
parameter                                                      stq3_addr_offset = stq2_addr_offset + (lwrCClassBit - uprTagBit) + 1;
parameter                                                      stq4_addr_offset = stq3_addr_offset + (lwrCClassBit - uprTagBit) + 1;
parameter                                                      ex4_en_par_chk_offset = stq4_addr_offset + (lwrCClassBit - uprTagBit) + 1;
parameter                                                      stq3_en_par_chk_offset = ex4_en_par_chk_offset + 8;
parameter                                                      scan_right = stq3_en_par_chk_offset + 8 - 1;

wire                                                           tiup;
wire [0:scan_right]                                            siv;
wire [0:scan_right]                                            sov;

// ####################################################
// Inputs
// ####################################################
assign tiup = 1'b1;

assign stq2_addr_d = lsq_ctl_stq1_addr;
assign stq3_addr_d = stq2_addr_q;
assign stq4_addr_d = stq3_addr_q;
assign ex3_binv_val_d = dcc_dir_ex2_binv_val;

assign inj_ddir_ldp_parity_d = pc_lq_inj_dcachedir_ldp_parity;
assign inj_ddir_stp_parity_d = pc_lq_inj_dcachedir_stp_parity;

// ####################################################
// Dcache Number of Cachelines Configurations
// ####################################################
assign arr_wr_addr = stq4_addr_q[uprCClassBit:lwrCClassBit];

// ####################################################
// LQ Pipe
// ####################################################

// ####################################################
// Directory Update
// ####################################################

// Directory Congruence Class Write Address
assign arr_wr_data[uprTagBit:lwrTagBit] = stq4_addr_q[uprTagBit:lwrTagBit];

// ####################################################
// Tag Array Access
// 1) Contains the Array of Tags
// ####################################################


lq_dir_tag_arr #(.WAYDATASIZE(WAYDATASIZE), .PARBITS(PARBITS)) l1dcta(

   .wdata(arr_wr_data),

   .dir_arr_rd_data0(dir_arr_rd_data0),
   .dir_arr_rd_data1(dir_arr_rd_data1),

   .inj_ddir_p0_parity(inj_ddir_ldp_parity_q),
   .inj_ddir_p1_parity(inj_ddir_stp_parity_q),

   .dir_arr_wr_data(dir_arr_wr_data),

   .p0_way_tag_a(p0_way_tag_a),
   .p0_way_tag_b(p0_way_tag_b),
   .p0_way_tag_c(p0_way_tag_c),
   .p0_way_tag_d(p0_way_tag_d),
   .p0_way_tag_e(p0_way_tag_e),
   .p0_way_tag_f(p0_way_tag_f),
   .p0_way_tag_g(p0_way_tag_g),
   .p0_way_tag_h(p0_way_tag_h),
   .p1_way_tag_a(p1_way_tag_a),
   .p1_way_tag_b(p1_way_tag_b),
   .p1_way_tag_c(p1_way_tag_c),
   .p1_way_tag_d(p1_way_tag_d),
   .p1_way_tag_e(p1_way_tag_e),
   .p1_way_tag_f(p1_way_tag_f),
   .p1_way_tag_g(p1_way_tag_g),
   .p1_way_tag_h(p1_way_tag_h),

   .p0_way_par_a(p0_way_par_a),
   .p0_way_par_b(p0_way_par_b),
   .p0_way_par_c(p0_way_par_c),
   .p0_way_par_d(p0_way_par_d),
   .p0_way_par_e(p0_way_par_e),
   .p0_way_par_f(p0_way_par_f),
   .p0_way_par_g(p0_way_par_g),
   .p0_way_par_h(p0_way_par_h),

   .p0_par_err_det_a(p0_par_err_det_a),
   .p0_par_err_det_b(p0_par_err_det_b),
   .p0_par_err_det_c(p0_par_err_det_c),
   .p0_par_err_det_d(p0_par_err_det_d),
   .p0_par_err_det_e(p0_par_err_det_e),
   .p0_par_err_det_f(p0_par_err_det_f),
   .p0_par_err_det_g(p0_par_err_det_g),
   .p0_par_err_det_h(p0_par_err_det_h),
   .p1_par_err_det_a(p1_par_err_det_a),
   .p1_par_err_det_b(p1_par_err_det_b),
   .p1_par_err_det_c(p1_par_err_det_c),
   .p1_par_err_det_d(p1_par_err_det_d),
   .p1_par_err_det_e(p1_par_err_det_e),
   .p1_par_err_det_f(p1_par_err_det_f),
   .p1_par_err_det_g(p1_par_err_det_g),
   .p1_par_err_det_h(p1_par_err_det_h)
);

// ####################################################
// Parity Reporting for Load Pipe and Back-Invalidate Pipe
// ####################################################

// Parity Check Enable
assign ex4_en_par_chk_d[0] = (dcc_dir_ex3_ddir_acc | ex3_binv_val_q) & (~spr_xucr0_dcdis);
assign ex4_en_par_chk_d[1] = (dcc_dir_ex3_ddir_acc | ex3_binv_val_q) & (~spr_xucr0_dcdis);
assign ex4_en_par_chk_d[2] = (dcc_dir_ex3_ddir_acc | ex3_binv_val_q) & (~spr_xucr0_dcdis);
assign ex4_en_par_chk_d[3] = (dcc_dir_ex3_ddir_acc | ex3_binv_val_q) & (~spr_xucr0_dcdis);
assign ex4_en_par_chk_d[4] = (dcc_dir_ex3_ddir_acc | ex3_binv_val_q) & (~spr_xucr0_dcdis);
assign ex4_en_par_chk_d[5] = (dcc_dir_ex3_ddir_acc | ex3_binv_val_q) & (~spr_xucr0_dcdis);
assign ex4_en_par_chk_d[6] = (dcc_dir_ex3_ddir_acc | ex3_binv_val_q) & (~spr_xucr0_dcdis);
assign ex4_en_par_chk_d[7] = (dcc_dir_ex3_ddir_acc | ex3_binv_val_q) & (~spr_xucr0_dcdis);

// Parity Error Detected
assign ex4_perr_det_a = p0_par_err_det_a & ex4_en_par_chk_q[0];
assign ex4_perr_det_b = p0_par_err_det_b & ex4_en_par_chk_q[1];
assign ex4_perr_det_c = p0_par_err_det_c & ex4_en_par_chk_q[2];
assign ex4_perr_det_d = p0_par_err_det_d & ex4_en_par_chk_q[3];
assign ex4_perr_det_e = p0_par_err_det_e & ex4_en_par_chk_q[4];
assign ex4_perr_det_f = p0_par_err_det_f & ex4_en_par_chk_q[5];
assign ex4_perr_det_g = p0_par_err_det_g & ex4_en_par_chk_q[6];
assign ex4_perr_det_h = p0_par_err_det_h & ex4_en_par_chk_q[7];

// ####################################################
// Parity Reporting for Store Commit Pipe
// ####################################################

// Parity Check Enable for Store Commit Pipe
assign stq3_en_par_chk_d[0] = stq2_ddir_acc & (~spr_xucr0_dcdis);
assign stq3_en_par_chk_d[1] = stq2_ddir_acc & (~spr_xucr0_dcdis);
assign stq3_en_par_chk_d[2] = stq2_ddir_acc & (~spr_xucr0_dcdis);
assign stq3_en_par_chk_d[3] = stq2_ddir_acc & (~spr_xucr0_dcdis);
assign stq3_en_par_chk_d[4] = stq2_ddir_acc & (~spr_xucr0_dcdis);
assign stq3_en_par_chk_d[5] = stq2_ddir_acc & (~spr_xucr0_dcdis);
assign stq3_en_par_chk_d[6] = stq2_ddir_acc & (~spr_xucr0_dcdis);
assign stq3_en_par_chk_d[7] = stq2_ddir_acc & (~spr_xucr0_dcdis);

// Parity Error Detected
assign stq3_perr_det_a = p1_par_err_det_a & stq3_en_par_chk_q[0];
assign stq3_perr_det_b = p1_par_err_det_b & stq3_en_par_chk_q[1];
assign stq3_perr_det_c = p1_par_err_det_c & stq3_en_par_chk_q[2];
assign stq3_perr_det_d = p1_par_err_det_d & stq3_en_par_chk_q[3];
assign stq3_perr_det_e = p1_par_err_det_e & stq3_en_par_chk_q[4];
assign stq3_perr_det_f = p1_par_err_det_f & stq3_en_par_chk_q[5];
assign stq3_perr_det_g = p1_par_err_det_g & stq3_en_par_chk_q[6];
assign stq3_perr_det_h = p1_par_err_det_h & stq3_en_par_chk_q[7];

// ####################################################
// Hit Logic
// ####################################################
assign p0_way_cmp_a = (p0_way_tag_a[uprTagBit:lwrTagBit] == dcc_dir_ex4_p_addr[uprTagBit:lwrTagBit]);
assign p0_way_cmp_b = (p0_way_tag_b[uprTagBit:lwrTagBit] == dcc_dir_ex4_p_addr[uprTagBit:lwrTagBit]);
assign p0_way_cmp_c = (p0_way_tag_c[uprTagBit:lwrTagBit] == dcc_dir_ex4_p_addr[uprTagBit:lwrTagBit]);
assign p0_way_cmp_d = (p0_way_tag_d[uprTagBit:lwrTagBit] == dcc_dir_ex4_p_addr[uprTagBit:lwrTagBit]);
assign p0_way_cmp_e = (p0_way_tag_e[uprTagBit:lwrTagBit] == dcc_dir_ex4_p_addr[uprTagBit:lwrTagBit]);
assign p0_way_cmp_f = (p0_way_tag_f[uprTagBit:lwrTagBit] == dcc_dir_ex4_p_addr[uprTagBit:lwrTagBit]);
assign p0_way_cmp_g = (p0_way_tag_g[uprTagBit:lwrTagBit] == dcc_dir_ex4_p_addr[uprTagBit:lwrTagBit]);
assign p0_way_cmp_h = (p0_way_tag_h[uprTagBit:lwrTagBit] == dcc_dir_ex4_p_addr[uprTagBit:lwrTagBit]);
assign p1_way_cmp_a = (p1_way_tag_a[uprTagBit:lwrTagBit] == stq3_addr_q[uprTagBit:lwrTagBit]);
assign p1_way_cmp_b = (p1_way_tag_b[uprTagBit:lwrTagBit] == stq3_addr_q[uprTagBit:lwrTagBit]);
assign p1_way_cmp_c = (p1_way_tag_c[uprTagBit:lwrTagBit] == stq3_addr_q[uprTagBit:lwrTagBit]);
assign p1_way_cmp_d = (p1_way_tag_d[uprTagBit:lwrTagBit] == stq3_addr_q[uprTagBit:lwrTagBit]);
assign p1_way_cmp_e = (p1_way_tag_e[uprTagBit:lwrTagBit] == stq3_addr_q[uprTagBit:lwrTagBit]);
assign p1_way_cmp_f = (p1_way_tag_f[uprTagBit:lwrTagBit] == stq3_addr_q[uprTagBit:lwrTagBit]);
assign p1_way_cmp_g = (p1_way_tag_g[uprTagBit:lwrTagBit] == stq3_addr_q[uprTagBit:lwrTagBit]);
assign p1_way_cmp_h = (p1_way_tag_h[uprTagBit:lwrTagBit] == stq3_addr_q[uprTagBit:lwrTagBit]);

// ####################################################
// Outputs
// ####################################################

// Directory Way Write Enables
assign dir_arr_wr_way = {rel_way_upd_a, rel_way_upd_b, rel_way_upd_c, rel_way_upd_d,
                         rel_way_upd_e, rel_way_upd_f, rel_way_upd_g, rel_way_upd_h};
assign dir_arr_wr_addr = arr_wr_addr;

assign ex4_way_cmp_a = p0_way_cmp_a;
assign ex4_way_cmp_b = p0_way_cmp_b;
assign ex4_way_cmp_c = p0_way_cmp_c;
assign ex4_way_cmp_d = p0_way_cmp_d;
assign ex4_way_cmp_e = p0_way_cmp_e;
assign ex4_way_cmp_f = p0_way_cmp_f;
assign ex4_way_cmp_g = p0_way_cmp_g;
assign ex4_way_cmp_h = p0_way_cmp_h;
assign ex4_tag_perr_way = {ex4_perr_det_a, ex4_perr_det_b, ex4_perr_det_c, ex4_perr_det_d,
                           ex4_perr_det_e, ex4_perr_det_f, ex4_perr_det_g, ex4_perr_det_h};

assign dir_dcc_ex4_way_tag_a = p0_way_tag_a;
assign dir_dcc_ex4_way_tag_b = p0_way_tag_b;
assign dir_dcc_ex4_way_tag_c = p0_way_tag_c;
assign dir_dcc_ex4_way_tag_d = p0_way_tag_d;
assign dir_dcc_ex4_way_tag_e = p0_way_tag_e;
assign dir_dcc_ex4_way_tag_f = p0_way_tag_f;
assign dir_dcc_ex4_way_tag_g = p0_way_tag_g;
assign dir_dcc_ex4_way_tag_h = p0_way_tag_h;

assign dir_dcc_ex4_way_par_a = p0_way_par_a;
assign dir_dcc_ex4_way_par_b = p0_way_par_b;
assign dir_dcc_ex4_way_par_c = p0_way_par_c;
assign dir_dcc_ex4_way_par_d = p0_way_par_d;
assign dir_dcc_ex4_way_par_e = p0_way_par_e;
assign dir_dcc_ex4_way_par_f = p0_way_par_f;
assign dir_dcc_ex4_way_par_g = p0_way_par_g;
assign dir_dcc_ex4_way_par_h = p0_way_par_h;

assign stq3_way_cmp_a = p1_way_cmp_a;
assign stq3_way_cmp_b = p1_way_cmp_b;
assign stq3_way_cmp_c = p1_way_cmp_c;
assign stq3_way_cmp_d = p1_way_cmp_d;
assign stq3_way_cmp_e = p1_way_cmp_e;
assign stq3_way_cmp_f = p1_way_cmp_f;
assign stq3_way_cmp_g = p1_way_cmp_g;
assign stq3_way_cmp_h = p1_way_cmp_h;
assign stq3_tag_way_perr = {stq3_perr_det_a, stq3_perr_det_b, stq3_perr_det_c, stq3_perr_det_d,
                            stq3_perr_det_e, stq3_perr_det_f, stq3_perr_det_g, stq3_perr_det_h};

// ####################################################
// Back Invalidate Registers
// ####################################################


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_binv_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_binv_val_offset]),
   .scout(sov[ex3_binv_val_offset]),
   .din(ex3_binv_val_d),
   .dout(ex3_binv_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) inj_ddir_ldp_parity_reg(
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
   .scin(siv[inj_ddir_ldp_parity_offset]),
   .scout(sov[inj_ddir_ldp_parity_offset]),
   .din(inj_ddir_ldp_parity_d),
   .dout(inj_ddir_ldp_parity_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) inj_ddir_stp_parity_reg(
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
   .scin(siv[inj_ddir_stp_parity_offset]),
   .scout(sov[inj_ddir_stp_parity_offset]),
   .din(inj_ddir_stp_parity_d),
   .dout(inj_ddir_stp_parity_q)
);

tri_rlmreg_p #(.WIDTH((lwrCClassBit - uprTagBit) + 1), .INIT(0), .NEEDS_SRESET(1)) stq2_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_addr_offset:stq2_addr_offset + (lwrCClassBit-uprTagBit+1) - 1]),
   .scout(sov[stq2_addr_offset:stq2_addr_offset + (lwrCClassBit-uprTagBit+1) - 1]),
   .din(stq2_addr_d),
   .dout(stq2_addr_q)
);


tri_rlmreg_p #(.WIDTH((lwrCClassBit - uprTagBit) + 1), .INIT(0), .NEEDS_SRESET(1)) stq3_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_addr_offset:stq3_addr_offset + (lwrCClassBit-uprTagBit+1) - 1]),
   .scout(sov[stq3_addr_offset:stq3_addr_offset + (lwrCClassBit-uprTagBit+1) - 1]),
   .din(stq3_addr_d),
   .dout(stq3_addr_q)
);


tri_rlmreg_p #(.WIDTH((lwrCClassBit - uprTagBit) + 1), .INIT(0), .NEEDS_SRESET(1)) stq4_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq3_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_addr_offset:stq4_addr_offset + (lwrCClassBit-uprTagBit+1) - 1]),
   .scout(sov[stq4_addr_offset:stq4_addr_offset + (lwrCClassBit-uprTagBit+1) - 1]),
   .din(stq4_addr_d),
   .dout(stq4_addr_q)
);

tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex4_en_par_chk_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_en_par_chk_offset:ex4_en_par_chk_offset + 8 - 1]),
   .scout(sov[ex4_en_par_chk_offset:ex4_en_par_chk_offset + 8 - 1]),
   .din(ex4_en_par_chk_d),
   .dout(ex4_en_par_chk_q)
);


tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) stq3_en_par_chk_reg(
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
   .scin(siv[stq3_en_par_chk_offset:stq3_en_par_chk_offset + 8 - 1]),
   .scout(sov[stq3_en_par_chk_offset:stq3_en_par_chk_offset + 8 - 1]),
   .din(stq3_en_par_chk_d),
   .dout(stq3_en_par_chk_q)
);

assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
assign scan_out = sov[0];

endmodule
