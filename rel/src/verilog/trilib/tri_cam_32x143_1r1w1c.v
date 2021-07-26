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

// VHDL 1076 Macro Expander C version 07/11/00
// job was run on Mon Nov  8 10:36:46 2010

//********************************************************************
//* TITLE: I-ERAT CAM Tri-Library Model
//* NAME: tri_cam_32x143_1r1w1c
//********************************************************************

`include "tri_a2o.vh"

module tri_cam_32x143_1r1w1c(
   gnd,
   vdd,
   vcs,
   nclk,
   tc_ccflush_dc,
   tc_scan_dis_dc_b,
   tc_scan_diag_dc,
   tc_lbist_en_dc,
   an_ac_atpg_en_dc,
   lcb_d_mode_dc,
   lcb_clkoff_dc_b,
   lcb_act_dis_dc,
   lcb_mpw1_dc_b,
   lcb_mpw2_dc_b,
   lcb_delay_lclkr_dc,
   pc_sg_2,
   pc_func_slp_sl_thold_2,
   pc_func_slp_nsl_thold_2,
   pc_regf_slp_sl_thold_2,
   pc_time_sl_thold_2,
   pc_fce_2,
   func_scan_in,
   func_scan_out,
   regfile_scan_in,
   regfile_scan_out,
   time_scan_in,
   time_scan_out,
   rd_val,
   rd_val_late,
   rw_entry,
   wr_array_data,
   wr_cam_data,
   wr_array_val,
   wr_cam_val,
   wr_val_early,
   comp_request,
   comp_addr,
   addr_enable,
   comp_pgsize,
   pgsize_enable,
   comp_class,
   class_enable,
   comp_extclass,
   extclass_enable,
   comp_state,
   state_enable,
   comp_thdid,
   thdid_enable,
   comp_pid,
   pid_enable,
   comp_invalidate,
   flash_invalidate,
   array_cmp_data,
   rd_array_data,
   cam_cmp_data,
   cam_hit,
   cam_hit_entry,
   entry_match,
   entry_valid,
   rd_cam_data,
   bypass_mux_enab_np1,
   bypass_attr_np1,
   attr_np2,
   rpn_np2
);
   parameter                     CAM_DATA_WIDTH = 84;
   parameter                     ARRAY_DATA_WIDTH = 68;
   parameter                     RPN_WIDTH = 30;
   parameter                     NUM_ENTRY = 32;
   parameter                     NUM_ENTRY_LOG2 = 5;

   // Power Pins
   inout                         gnd;
   inout                         vdd;
   inout                         vcs;

   // Clocks and Scan Cntls
   input [0:`NCLK_WIDTH-1]       nclk;
   input                         tc_ccflush_dc;
   input                         tc_scan_dis_dc_b;
   input                         tc_scan_diag_dc;
   input                         tc_lbist_en_dc;
   input                         an_ac_atpg_en_dc;

   input                         lcb_d_mode_dc;
   input                         lcb_clkoff_dc_b;
   input                         lcb_act_dis_dc;
   input [0:3]                   lcb_mpw1_dc_b;
   input                         lcb_mpw2_dc_b;
   input [0:3]                   lcb_delay_lclkr_dc;

   input                         pc_sg_2;
   input                         pc_func_slp_sl_thold_2;
   input                         pc_func_slp_nsl_thold_2;
   input                         pc_regf_slp_sl_thold_2;
   input                         pc_time_sl_thold_2;
   input                         pc_fce_2;

   input                         func_scan_in;
   output                        func_scan_out;
   input [0:6]                   regfile_scan_in;       // 0:2 -> CAM, 3:6 -> RAM
   output [0:6]                  regfile_scan_out;
   input                         time_scan_in;
   output                        time_scan_out;

   // Read Port
   input                         rd_val;
   input                         rd_val_late;
   input [0:NUM_ENTRY_LOG2-1]    rw_entry;

   // Write Port
   input [0:ARRAY_DATA_WIDTH-1]  wr_array_data;
   input [0:CAM_DATA_WIDTH-1]    wr_cam_data;
   input [0:1]                   wr_array_val;
   input [0:1]                   wr_cam_val;
   input                         wr_val_early;

   // CAM Port
   input                         comp_request;
   input [0:51]                  comp_addr;
   input [0:1]                   addr_enable;
   input [0:2]                   comp_pgsize;
   input                         pgsize_enable;
   input [0:1]                   comp_class;
   input [0:2]                   class_enable;
   input [0:1]                   comp_extclass;
   input [0:1]                   extclass_enable;
   input [0:1]                   comp_state;
   input [0:1]                   state_enable;
   input [0:3]                   comp_thdid;
   input [0:1]                   thdid_enable;
   input [0:7]                   comp_pid;
   input                         pid_enable;
   input                         comp_invalidate;
   input                         flash_invalidate;

   // Outputs
   // Data Out
   output [0:ARRAY_DATA_WIDTH-1] array_cmp_data;
   output [0:ARRAY_DATA_WIDTH-1] rd_array_data;

   // CAM Output
   output [0:CAM_DATA_WIDTH-1]   cam_cmp_data;
   output                        cam_hit;
   output [0:NUM_ENTRY_LOG2-1]   cam_hit_entry;
   output [0:NUM_ENTRY-1]        entry_match;
   output [0:NUM_ENTRY-1]        entry_valid;
   output [0:CAM_DATA_WIDTH-1]   rd_cam_data;

   //--- new ports for IO plus -----------------------
   input                         bypass_mux_enab_np1;
   input [0:20]                  bypass_attr_np1;
   output [0:20]                 attr_np2;

   output [22:51]                rpn_np2;

   // tri_cam_32x143_1r1w1c

   // Configuration Statement for NCsim
   //for all:RAMB16_S9_S9 use entity unisim.RAMB16_S9_S9;
   //for all:RAMB16_S18_S18 use entity unisim.RAMB16_S18_S18;
   //for all:RAMB16_S36_S36 use entity unisim.RAMB16_S36_S36;

   wire                          clk;
   wire                          clk2x;
   wire [0:8]                    bram0_addra;
   wire [0:8]                    bram0_addrb;
   wire [0:10]                   bram1_addra;
   wire [0:10]                   bram1_addrb;
   wire [0:9]                    bram2_addra;
   wire [0:9]                    bram2_addrb;
   wire                          bram0_wea;
   wire                          bram1_wea;
   wire                          bram2_wea;
   wire [0:55]                   array_cmp_data_bram;
   wire [66:72]                  array_cmp_data_bramp;

   // Latches
   reg                           sreset_q;
   reg                           gate_fq;
   wire                          gate_d;
   wire [52-RPN_WIDTH:51]        comp_addr_np1_d;
   reg [52-RPN_WIDTH:51]         comp_addr_np1_q;  // the internal latched np1 phase epn(22:51) from com_addr input
   wire [52-RPN_WIDTH:51]        rpn_np2_d;
   reg [52-RPN_WIDTH:51]         rpn_np2_q;
   wire [0:20]                   attr_np2_d;
   reg [0:20]                    attr_np2_q;

   // CAM entry signals
   wire [0:51]                   entry0_epn_d;
   reg [0:51]                    entry0_epn_q;
   wire                          entry0_xbit_d;
   reg                           entry0_xbit_q;
   wire [0:2]                    entry0_size_d;
   reg [0:2]                     entry0_size_q;
   wire                          entry0_v_d;
   reg                           entry0_v_q;
   wire [0:3]                    entry0_thdid_d;
   reg [0:3]                     entry0_thdid_q;
   wire [0:1]                    entry0_class_d;
   reg [0:1]                     entry0_class_q;
   wire [0:1]                    entry0_extclass_d;
   reg [0:1]                     entry0_extclass_q;
   wire                          entry0_hv_d;
   reg                           entry0_hv_q;
   wire                          entry0_ds_d;
   reg                           entry0_ds_q;
   wire [0:7]                    entry0_pid_d;
   reg [0:7]                     entry0_pid_q;
   wire [0:8]                    entry0_cmpmask_d;
   reg [0:8]                     entry0_cmpmask_q;
   wire [0:9]                    entry0_parity_d;
   reg [0:9]                     entry0_parity_q;
   wire [0:1]                    wr_entry0_sel;
   wire                          entry0_inval;
   wire [0:1]                    entry0_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry0_cam_vec;
   wire [0:51]                   entry1_epn_d;
   reg [0:51]                    entry1_epn_q;
   wire                          entry1_xbit_d;
   reg                           entry1_xbit_q;
   wire [0:2]                    entry1_size_d;
   reg [0:2]                     entry1_size_q;
   wire                          entry1_v_d;
   reg                           entry1_v_q;
   wire [0:3]                    entry1_thdid_d;
   reg [0:3]                     entry1_thdid_q;
   wire [0:1]                    entry1_class_d;
   reg [0:1]                     entry1_class_q;
   wire [0:1]                    entry1_extclass_d;
   reg [0:1]                     entry1_extclass_q;
   wire                          entry1_hv_d;
   reg                           entry1_hv_q;
   wire                          entry1_ds_d;
   reg                           entry1_ds_q;
   wire [0:7]                    entry1_pid_d;
   reg [0:7]                     entry1_pid_q;
   wire [0:8]                    entry1_cmpmask_d;
   reg [0:8]                     entry1_cmpmask_q;
   wire [0:9]                    entry1_parity_d;
   reg [0:9]                     entry1_parity_q;
   wire [0:1]                    wr_entry1_sel;
   wire                          entry1_inval;
   wire [0:1]                    entry1_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry1_cam_vec;
   wire [0:51]                   entry2_epn_d;
   reg [0:51]                    entry2_epn_q;
   wire                          entry2_xbit_d;
   reg                           entry2_xbit_q;
   wire [0:2]                    entry2_size_d;
   reg [0:2]                     entry2_size_q;
   wire                          entry2_v_d;
   reg                           entry2_v_q;
   wire [0:3]                    entry2_thdid_d;
   reg [0:3]                     entry2_thdid_q;
   wire [0:1]                    entry2_class_d;
   reg [0:1]                     entry2_class_q;
   wire [0:1]                    entry2_extclass_d;
   reg [0:1]                     entry2_extclass_q;
   wire                          entry2_hv_d;
   reg                           entry2_hv_q;
   wire                          entry2_ds_d;
   reg                           entry2_ds_q;
   wire [0:7]                    entry2_pid_d;
   reg [0:7]                     entry2_pid_q;
   wire [0:8]                    entry2_cmpmask_d;
   reg [0:8]                     entry2_cmpmask_q;
   wire [0:9]                    entry2_parity_d;
   reg [0:9]                     entry2_parity_q;
   wire [0:1]                    wr_entry2_sel;
   wire                          entry2_inval;
   wire [0:1]                    entry2_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry2_cam_vec;
   wire [0:51]                   entry3_epn_d;
   reg [0:51]                    entry3_epn_q;
   wire                          entry3_xbit_d;
   reg                           entry3_xbit_q;
   wire [0:2]                    entry3_size_d;
   reg [0:2]                     entry3_size_q;
   wire                          entry3_v_d;
   reg                           entry3_v_q;
   wire [0:3]                    entry3_thdid_d;
   reg [0:3]                     entry3_thdid_q;
   wire [0:1]                    entry3_class_d;
   reg [0:1]                     entry3_class_q;
   wire [0:1]                    entry3_extclass_d;
   reg [0:1]                     entry3_extclass_q;
   wire                          entry3_hv_d;
   reg                           entry3_hv_q;
   wire                          entry3_ds_d;
   reg                           entry3_ds_q;
   wire [0:7]                    entry3_pid_d;
   reg [0:7]                     entry3_pid_q;
   wire [0:8]                    entry3_cmpmask_d;
   reg [0:8]                     entry3_cmpmask_q;
   wire [0:9]                    entry3_parity_d;
   reg [0:9]                     entry3_parity_q;
   wire [0:1]                    wr_entry3_sel;
   wire                          entry3_inval;
   wire [0:1]                    entry3_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry3_cam_vec;
   wire [0:51]                   entry4_epn_d;
   reg [0:51]                    entry4_epn_q;
   wire                          entry4_xbit_d;
   reg                           entry4_xbit_q;
   wire [0:2]                    entry4_size_d;
   reg [0:2]                     entry4_size_q;
   wire                          entry4_v_d;
   reg                           entry4_v_q;
   wire [0:3]                    entry4_thdid_d;
   reg [0:3]                     entry4_thdid_q;
   wire [0:1]                    entry4_class_d;
   reg [0:1]                     entry4_class_q;
   wire [0:1]                    entry4_extclass_d;
   reg [0:1]                     entry4_extclass_q;
   wire                          entry4_hv_d;
   reg                           entry4_hv_q;
   wire                          entry4_ds_d;
   reg                           entry4_ds_q;
   wire [0:7]                    entry4_pid_d;
   reg [0:7]                     entry4_pid_q;
   wire [0:8]                    entry4_cmpmask_d;
   reg [0:8]                     entry4_cmpmask_q;
   wire [0:9]                    entry4_parity_d;
   reg [0:9]                     entry4_parity_q;
   wire [0:1]                    wr_entry4_sel;
   wire                          entry4_inval;
   wire [0:1]                    entry4_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry4_cam_vec;
   wire [0:51]                   entry5_epn_d;
   reg [0:51]                    entry5_epn_q;
   wire                          entry5_xbit_d;
   reg                           entry5_xbit_q;
   wire [0:2]                    entry5_size_d;
   reg [0:2]                     entry5_size_q;
   wire                          entry5_v_d;
   reg                           entry5_v_q;
   wire [0:3]                    entry5_thdid_d;
   reg [0:3]                     entry5_thdid_q;
   wire [0:1]                    entry5_class_d;
   reg [0:1]                     entry5_class_q;
   wire [0:1]                    entry5_extclass_d;
   reg [0:1]                     entry5_extclass_q;
   wire                          entry5_hv_d;
   reg                           entry5_hv_q;
   wire                          entry5_ds_d;
   reg                           entry5_ds_q;
   wire [0:7]                    entry5_pid_d;
   reg [0:7]                     entry5_pid_q;
   wire [0:8]                    entry5_cmpmask_d;
   reg [0:8]                     entry5_cmpmask_q;
   wire [0:9]                    entry5_parity_d;
   reg [0:9]                     entry5_parity_q;
   wire [0:1]                    wr_entry5_sel;
   wire                          entry5_inval;
   wire [0:1]                    entry5_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry5_cam_vec;
   wire [0:51]                   entry6_epn_d;
   reg [0:51]                    entry6_epn_q;
   wire                          entry6_xbit_d;
   reg                           entry6_xbit_q;
   wire [0:2]                    entry6_size_d;
   reg [0:2]                     entry6_size_q;
   wire                          entry6_v_d;
   reg                           entry6_v_q;
   wire [0:3]                    entry6_thdid_d;
   reg [0:3]                     entry6_thdid_q;
   wire [0:1]                    entry6_class_d;
   reg [0:1]                     entry6_class_q;
   wire [0:1]                    entry6_extclass_d;
   reg [0:1]                     entry6_extclass_q;
   wire                          entry6_hv_d;
   reg                           entry6_hv_q;
   wire                          entry6_ds_d;
   reg                           entry6_ds_q;
   wire [0:7]                    entry6_pid_d;
   reg [0:7]                     entry6_pid_q;
   wire [0:8]                    entry6_cmpmask_d;
   reg [0:8]                     entry6_cmpmask_q;
   wire [0:9]                    entry6_parity_d;
   reg [0:9]                     entry6_parity_q;
   wire [0:1]                    wr_entry6_sel;
   wire                          entry6_inval;
   wire [0:1]                    entry6_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry6_cam_vec;
   wire [0:51]                   entry7_epn_d;
   reg [0:51]                    entry7_epn_q;
   wire                          entry7_xbit_d;
   reg                           entry7_xbit_q;
   wire [0:2]                    entry7_size_d;
   reg [0:2]                     entry7_size_q;
   wire                          entry7_v_d;
   reg                           entry7_v_q;
   wire [0:3]                    entry7_thdid_d;
   reg [0:3]                     entry7_thdid_q;
   wire [0:1]                    entry7_class_d;
   reg [0:1]                     entry7_class_q;
   wire [0:1]                    entry7_extclass_d;
   reg [0:1]                     entry7_extclass_q;
   wire                          entry7_hv_d;
   reg                           entry7_hv_q;
   wire                          entry7_ds_d;
   reg                           entry7_ds_q;
   wire [0:7]                    entry7_pid_d;
   reg [0:7]                     entry7_pid_q;
   wire [0:8]                    entry7_cmpmask_d;
   reg [0:8]                     entry7_cmpmask_q;
   wire [0:9]                    entry7_parity_d;
   reg [0:9]                     entry7_parity_q;
   wire [0:1]                    wr_entry7_sel;
   wire                          entry7_inval;
   wire [0:1]                    entry7_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry7_cam_vec;
   wire [0:51]                   entry8_epn_d;
   reg [0:51]                    entry8_epn_q;
   wire                          entry8_xbit_d;
   reg                           entry8_xbit_q;
   wire [0:2]                    entry8_size_d;
   reg [0:2]                     entry8_size_q;
   wire                          entry8_v_d;
   reg                           entry8_v_q;
   wire [0:3]                    entry8_thdid_d;
   reg [0:3]                     entry8_thdid_q;
   wire [0:1]                    entry8_class_d;
   reg [0:1]                     entry8_class_q;
   wire [0:1]                    entry8_extclass_d;
   reg [0:1]                     entry8_extclass_q;
   wire                          entry8_hv_d;
   reg                           entry8_hv_q;
   wire                          entry8_ds_d;
   reg                           entry8_ds_q;
   wire [0:7]                    entry8_pid_d;
   reg [0:7]                     entry8_pid_q;
   wire [0:8]                    entry8_cmpmask_d;
   reg [0:8]                     entry8_cmpmask_q;
   wire [0:9]                    entry8_parity_d;
   reg [0:9]                     entry8_parity_q;
   wire [0:1]                    wr_entry8_sel;
   wire                          entry8_inval;
   wire [0:1]                    entry8_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry8_cam_vec;
   wire [0:51]                   entry9_epn_d;
   reg [0:51]                    entry9_epn_q;
   wire                          entry9_xbit_d;
   reg                           entry9_xbit_q;
   wire [0:2]                    entry9_size_d;
   reg [0:2]                     entry9_size_q;
   wire                          entry9_v_d;
   reg                           entry9_v_q;
   wire [0:3]                    entry9_thdid_d;
   reg [0:3]                     entry9_thdid_q;
   wire [0:1]                    entry9_class_d;
   reg [0:1]                     entry9_class_q;
   wire [0:1]                    entry9_extclass_d;
   reg [0:1]                     entry9_extclass_q;
   wire                          entry9_hv_d;
   reg                           entry9_hv_q;
   wire                          entry9_ds_d;
   reg                           entry9_ds_q;
   wire [0:7]                    entry9_pid_d;
   reg [0:7]                     entry9_pid_q;
   wire [0:8]                    entry9_cmpmask_d;
   reg [0:8]                     entry9_cmpmask_q;
   wire [0:9]                    entry9_parity_d;
   reg [0:9]                     entry9_parity_q;
   wire [0:1]                    wr_entry9_sel;
   wire                          entry9_inval;
   wire [0:1]                    entry9_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry9_cam_vec;
   wire [0:51]                   entry10_epn_d;
   reg [0:51]                    entry10_epn_q;
   wire                          entry10_xbit_d;
   reg                           entry10_xbit_q;
   wire [0:2]                    entry10_size_d;
   reg [0:2]                     entry10_size_q;
   wire                          entry10_v_d;
   reg                           entry10_v_q;
   wire [0:3]                    entry10_thdid_d;
   reg [0:3]                     entry10_thdid_q;
   wire [0:1]                    entry10_class_d;
   reg [0:1]                     entry10_class_q;
   wire [0:1]                    entry10_extclass_d;
   reg [0:1]                     entry10_extclass_q;
   wire                          entry10_hv_d;
   reg                           entry10_hv_q;
   wire                          entry10_ds_d;
   reg                           entry10_ds_q;
   wire [0:7]                    entry10_pid_d;
   reg [0:7]                     entry10_pid_q;
   wire [0:8]                    entry10_cmpmask_d;
   reg [0:8]                     entry10_cmpmask_q;
   wire [0:9]                    entry10_parity_d;
   reg [0:9]                     entry10_parity_q;
   wire [0:1]                    wr_entry10_sel;
   wire                          entry10_inval;
   wire [0:1]                    entry10_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry10_cam_vec;
   wire [0:51]                   entry11_epn_d;
   reg [0:51]                    entry11_epn_q;
   wire                          entry11_xbit_d;
   reg                           entry11_xbit_q;
   wire [0:2]                    entry11_size_d;
   reg [0:2]                     entry11_size_q;
   wire                          entry11_v_d;
   reg                           entry11_v_q;
   wire [0:3]                    entry11_thdid_d;
   reg [0:3]                     entry11_thdid_q;
   wire [0:1]                    entry11_class_d;
   reg [0:1]                     entry11_class_q;
   wire [0:1]                    entry11_extclass_d;
   reg [0:1]                     entry11_extclass_q;
   wire                          entry11_hv_d;
   reg                           entry11_hv_q;
   wire                          entry11_ds_d;
   reg                           entry11_ds_q;
   wire [0:7]                    entry11_pid_d;
   reg [0:7]                     entry11_pid_q;
   wire [0:8]                    entry11_cmpmask_d;
   reg [0:8]                     entry11_cmpmask_q;
   wire [0:9]                    entry11_parity_d;
   reg [0:9]                     entry11_parity_q;
   wire [0:1]                    wr_entry11_sel;
   wire                          entry11_inval;
   wire [0:1]                    entry11_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry11_cam_vec;
   wire [0:51]                   entry12_epn_d;
   reg [0:51]                    entry12_epn_q;
   wire                          entry12_xbit_d;
   reg                           entry12_xbit_q;
   wire [0:2]                    entry12_size_d;
   reg [0:2]                     entry12_size_q;
   wire                          entry12_v_d;
   reg                           entry12_v_q;
   wire [0:3]                    entry12_thdid_d;
   reg [0:3]                     entry12_thdid_q;
   wire [0:1]                    entry12_class_d;
   reg [0:1]                     entry12_class_q;
   wire [0:1]                    entry12_extclass_d;
   reg [0:1]                     entry12_extclass_q;
   wire                          entry12_hv_d;
   reg                           entry12_hv_q;
   wire                          entry12_ds_d;
   reg                           entry12_ds_q;
   wire [0:7]                    entry12_pid_d;
   reg [0:7]                     entry12_pid_q;
   wire [0:8]                    entry12_cmpmask_d;
   reg [0:8]                     entry12_cmpmask_q;
   wire [0:9]                    entry12_parity_d;
   reg [0:9]                     entry12_parity_q;
   wire [0:1]                    wr_entry12_sel;
   wire                          entry12_inval;
   wire [0:1]                    entry12_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry12_cam_vec;
   wire [0:51]                   entry13_epn_d;
   reg [0:51]                    entry13_epn_q;
   wire                          entry13_xbit_d;
   reg                           entry13_xbit_q;
   wire [0:2]                    entry13_size_d;
   reg [0:2]                     entry13_size_q;
   wire                          entry13_v_d;
   reg                           entry13_v_q;
   wire [0:3]                    entry13_thdid_d;
   reg [0:3]                     entry13_thdid_q;
   wire [0:1]                    entry13_class_d;
   reg [0:1]                     entry13_class_q;
   wire [0:1]                    entry13_extclass_d;
   reg [0:1]                     entry13_extclass_q;
   wire                          entry13_hv_d;
   reg                           entry13_hv_q;
   wire                          entry13_ds_d;
   reg                           entry13_ds_q;
   wire [0:7]                    entry13_pid_d;
   reg [0:7]                     entry13_pid_q;
   wire [0:8]                    entry13_cmpmask_d;
   reg [0:8]                     entry13_cmpmask_q;
   wire [0:9]                    entry13_parity_d;
   reg [0:9]                     entry13_parity_q;
   wire [0:1]                    wr_entry13_sel;
   wire                          entry13_inval;
   wire [0:1]                    entry13_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry13_cam_vec;
   wire [0:51]                   entry14_epn_d;
   reg [0:51]                    entry14_epn_q;
   wire                          entry14_xbit_d;
   reg                           entry14_xbit_q;
   wire [0:2]                    entry14_size_d;
   reg [0:2]                     entry14_size_q;
   wire                          entry14_v_d;
   reg                           entry14_v_q;
   wire [0:3]                    entry14_thdid_d;
   reg [0:3]                     entry14_thdid_q;
   wire [0:1]                    entry14_class_d;
   reg [0:1]                     entry14_class_q;
   wire [0:1]                    entry14_extclass_d;
   reg [0:1]                     entry14_extclass_q;
   wire                          entry14_hv_d;
   reg                           entry14_hv_q;
   wire                          entry14_ds_d;
   reg                           entry14_ds_q;
   wire [0:7]                    entry14_pid_d;
   reg [0:7]                     entry14_pid_q;
   wire [0:8]                    entry14_cmpmask_d;
   reg [0:8]                     entry14_cmpmask_q;
   wire [0:9]                    entry14_parity_d;
   reg [0:9]                     entry14_parity_q;
   wire [0:1]                    wr_entry14_sel;
   wire                          entry14_inval;
   wire [0:1]                    entry14_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry14_cam_vec;
   wire [0:51]                   entry15_epn_d;
   reg [0:51]                    entry15_epn_q;
   wire                          entry15_xbit_d;
   reg                           entry15_xbit_q;
   wire [0:2]                    entry15_size_d;
   reg [0:2]                     entry15_size_q;
   wire                          entry15_v_d;
   reg                           entry15_v_q;
   wire [0:3]                    entry15_thdid_d;
   reg [0:3]                     entry15_thdid_q;
   wire [0:1]                    entry15_class_d;
   reg [0:1]                     entry15_class_q;
   wire [0:1]                    entry15_extclass_d;
   reg [0:1]                     entry15_extclass_q;
   wire                          entry15_hv_d;
   reg                           entry15_hv_q;
   wire                          entry15_ds_d;
   reg                           entry15_ds_q;
   wire [0:7]                    entry15_pid_d;
   reg [0:7]                     entry15_pid_q;
   wire [0:8]                    entry15_cmpmask_d;
   reg [0:8]                     entry15_cmpmask_q;
   wire [0:9]                    entry15_parity_d;
   reg [0:9]                     entry15_parity_q;
   wire [0:1]                    wr_entry15_sel;
   wire                          entry15_inval;
   wire [0:1]                    entry15_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry15_cam_vec;
   wire [0:51]                   entry16_epn_d;
   reg [0:51]                    entry16_epn_q;
   wire                          entry16_xbit_d;
   reg                           entry16_xbit_q;
   wire [0:2]                    entry16_size_d;
   reg [0:2]                     entry16_size_q;
   wire                          entry16_v_d;
   reg                           entry16_v_q;
   wire [0:3]                    entry16_thdid_d;
   reg [0:3]                     entry16_thdid_q;
   wire [0:1]                    entry16_class_d;
   reg [0:1]                     entry16_class_q;
   wire [0:1]                    entry16_extclass_d;
   reg [0:1]                     entry16_extclass_q;
   wire                          entry16_hv_d;
   reg                           entry16_hv_q;
   wire                          entry16_ds_d;
   reg                           entry16_ds_q;
   wire [0:7]                    entry16_pid_d;
   reg [0:7]                     entry16_pid_q;
   wire [0:8]                    entry16_cmpmask_d;
   reg [0:8]                     entry16_cmpmask_q;
   wire [0:9]                    entry16_parity_d;
   reg [0:9]                     entry16_parity_q;
   wire [0:1]                    wr_entry16_sel;
   wire                          entry16_inval;
   wire [0:1]                    entry16_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry16_cam_vec;
   wire [0:51]                   entry17_epn_d;
   reg [0:51]                    entry17_epn_q;
   wire                          entry17_xbit_d;
   reg                           entry17_xbit_q;
   wire [0:2]                    entry17_size_d;
   reg [0:2]                     entry17_size_q;
   wire                          entry17_v_d;
   reg                           entry17_v_q;
   wire [0:3]                    entry17_thdid_d;
   reg [0:3]                     entry17_thdid_q;
   wire [0:1]                    entry17_class_d;
   reg [0:1]                     entry17_class_q;
   wire [0:1]                    entry17_extclass_d;
   reg [0:1]                     entry17_extclass_q;
   wire                          entry17_hv_d;
   reg                           entry17_hv_q;
   wire                          entry17_ds_d;
   reg                           entry17_ds_q;
   wire [0:7]                    entry17_pid_d;
   reg [0:7]                     entry17_pid_q;
   wire [0:8]                    entry17_cmpmask_d;
   reg [0:8]                     entry17_cmpmask_q;
   wire [0:9]                    entry17_parity_d;
   reg [0:9]                     entry17_parity_q;
   wire [0:1]                    wr_entry17_sel;
   wire                          entry17_inval;
   wire [0:1]                    entry17_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry17_cam_vec;
   wire [0:51]                   entry18_epn_d;
   reg [0:51]                    entry18_epn_q;
   wire                          entry18_xbit_d;
   reg                           entry18_xbit_q;
   wire [0:2]                    entry18_size_d;
   reg [0:2]                     entry18_size_q;
   wire                          entry18_v_d;
   reg                           entry18_v_q;
   wire [0:3]                    entry18_thdid_d;
   reg [0:3]                     entry18_thdid_q;
   wire [0:1]                    entry18_class_d;
   reg [0:1]                     entry18_class_q;
   wire [0:1]                    entry18_extclass_d;
   reg [0:1]                     entry18_extclass_q;
   wire                          entry18_hv_d;
   reg                           entry18_hv_q;
   wire                          entry18_ds_d;
   reg                           entry18_ds_q;
   wire [0:7]                    entry18_pid_d;
   reg [0:7]                     entry18_pid_q;
   wire [0:8]                    entry18_cmpmask_d;
   reg [0:8]                     entry18_cmpmask_q;
   wire [0:9]                    entry18_parity_d;
   reg [0:9]                     entry18_parity_q;
   wire [0:1]                    wr_entry18_sel;
   wire                          entry18_inval;
   wire [0:1]                    entry18_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry18_cam_vec;
   wire [0:51]                   entry19_epn_d;
   reg [0:51]                    entry19_epn_q;
   wire                          entry19_xbit_d;
   reg                           entry19_xbit_q;
   wire [0:2]                    entry19_size_d;
   reg [0:2]                     entry19_size_q;
   wire                          entry19_v_d;
   reg                           entry19_v_q;
   wire [0:3]                    entry19_thdid_d;
   reg [0:3]                     entry19_thdid_q;
   wire [0:1]                    entry19_class_d;
   reg [0:1]                     entry19_class_q;
   wire [0:1]                    entry19_extclass_d;
   reg [0:1]                     entry19_extclass_q;
   wire                          entry19_hv_d;
   reg                           entry19_hv_q;
   wire                          entry19_ds_d;
   reg                           entry19_ds_q;
   wire [0:7]                    entry19_pid_d;
   reg [0:7]                     entry19_pid_q;
   wire [0:8]                    entry19_cmpmask_d;
   reg [0:8]                     entry19_cmpmask_q;
   wire [0:9]                    entry19_parity_d;
   reg [0:9]                     entry19_parity_q;
   wire [0:1]                    wr_entry19_sel;
   wire                          entry19_inval;
   wire [0:1]                    entry19_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry19_cam_vec;
   wire [0:51]                   entry20_epn_d;
   reg [0:51]                    entry20_epn_q;
   wire                          entry20_xbit_d;
   reg                           entry20_xbit_q;
   wire [0:2]                    entry20_size_d;
   reg [0:2]                     entry20_size_q;
   wire                          entry20_v_d;
   reg                           entry20_v_q;
   wire [0:3]                    entry20_thdid_d;
   reg [0:3]                     entry20_thdid_q;
   wire [0:1]                    entry20_class_d;
   reg [0:1]                     entry20_class_q;
   wire [0:1]                    entry20_extclass_d;
   reg [0:1]                     entry20_extclass_q;
   wire                          entry20_hv_d;
   reg                           entry20_hv_q;
   wire                          entry20_ds_d;
   reg                           entry20_ds_q;
   wire [0:7]                    entry20_pid_d;
   reg [0:7]                     entry20_pid_q;
   wire [0:8]                    entry20_cmpmask_d;
   reg [0:8]                     entry20_cmpmask_q;
   wire [0:9]                    entry20_parity_d;
   reg [0:9]                     entry20_parity_q;
   wire [0:1]                    wr_entry20_sel;
   wire                          entry20_inval;
   wire [0:1]                    entry20_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry20_cam_vec;
   wire [0:51]                   entry21_epn_d;
   reg [0:51]                    entry21_epn_q;
   wire                          entry21_xbit_d;
   reg                           entry21_xbit_q;
   wire [0:2]                    entry21_size_d;
   reg [0:2]                     entry21_size_q;
   wire                          entry21_v_d;
   reg                           entry21_v_q;
   wire [0:3]                    entry21_thdid_d;
   reg [0:3]                     entry21_thdid_q;
   wire [0:1]                    entry21_class_d;
   reg [0:1]                     entry21_class_q;
   wire [0:1]                    entry21_extclass_d;
   reg [0:1]                     entry21_extclass_q;
   wire                          entry21_hv_d;
   reg                           entry21_hv_q;
   wire                          entry21_ds_d;
   reg                           entry21_ds_q;
   wire [0:7]                    entry21_pid_d;
   reg [0:7]                     entry21_pid_q;
   wire [0:8]                    entry21_cmpmask_d;
   reg [0:8]                     entry21_cmpmask_q;
   wire [0:9]                    entry21_parity_d;
   reg [0:9]                     entry21_parity_q;
   wire [0:1]                    wr_entry21_sel;
   wire                          entry21_inval;
   wire [0:1]                    entry21_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry21_cam_vec;
   wire [0:51]                   entry22_epn_d;
   reg [0:51]                    entry22_epn_q;
   wire                          entry22_xbit_d;
   reg                           entry22_xbit_q;
   wire [0:2]                    entry22_size_d;
   reg [0:2]                     entry22_size_q;
   wire                          entry22_v_d;
   reg                           entry22_v_q;
   wire [0:3]                    entry22_thdid_d;
   reg [0:3]                     entry22_thdid_q;
   wire [0:1]                    entry22_class_d;
   reg [0:1]                     entry22_class_q;
   wire [0:1]                    entry22_extclass_d;
   reg [0:1]                     entry22_extclass_q;
   wire                          entry22_hv_d;
   reg                           entry22_hv_q;
   wire                          entry22_ds_d;
   reg                           entry22_ds_q;
   wire [0:7]                    entry22_pid_d;
   reg [0:7]                     entry22_pid_q;
   wire [0:8]                    entry22_cmpmask_d;
   reg [0:8]                     entry22_cmpmask_q;
   wire [0:9]                    entry22_parity_d;
   reg [0:9]                     entry22_parity_q;
   wire [0:1]                    wr_entry22_sel;
   wire                          entry22_inval;
   wire [0:1]                    entry22_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry22_cam_vec;
   wire [0:51]                   entry23_epn_d;
   reg [0:51]                    entry23_epn_q;
   wire                          entry23_xbit_d;
   reg                           entry23_xbit_q;
   wire [0:2]                    entry23_size_d;
   reg [0:2]                     entry23_size_q;
   wire                          entry23_v_d;
   reg                           entry23_v_q;
   wire [0:3]                    entry23_thdid_d;
   reg [0:3]                     entry23_thdid_q;
   wire [0:1]                    entry23_class_d;
   reg [0:1]                     entry23_class_q;
   wire [0:1]                    entry23_extclass_d;
   reg [0:1]                     entry23_extclass_q;
   wire                          entry23_hv_d;
   reg                           entry23_hv_q;
   wire                          entry23_ds_d;
   reg                           entry23_ds_q;
   wire [0:7]                    entry23_pid_d;
   reg [0:7]                     entry23_pid_q;
   wire [0:8]                    entry23_cmpmask_d;
   reg [0:8]                     entry23_cmpmask_q;
   wire [0:9]                    entry23_parity_d;
   reg [0:9]                     entry23_parity_q;
   wire [0:1]                    wr_entry23_sel;
   wire                          entry23_inval;
   wire [0:1]                    entry23_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry23_cam_vec;
   wire [0:51]                   entry24_epn_d;
   reg [0:51]                    entry24_epn_q;
   wire                          entry24_xbit_d;
   reg                           entry24_xbit_q;
   wire [0:2]                    entry24_size_d;
   reg [0:2]                     entry24_size_q;
   wire                          entry24_v_d;
   reg                           entry24_v_q;
   wire [0:3]                    entry24_thdid_d;
   reg [0:3]                     entry24_thdid_q;
   wire [0:1]                    entry24_class_d;
   reg [0:1]                     entry24_class_q;
   wire [0:1]                    entry24_extclass_d;
   reg [0:1]                     entry24_extclass_q;
   wire                          entry24_hv_d;
   reg                           entry24_hv_q;
   wire                          entry24_ds_d;
   reg                           entry24_ds_q;
   wire [0:7]                    entry24_pid_d;
   reg [0:7]                     entry24_pid_q;
   wire [0:8]                    entry24_cmpmask_d;
   reg [0:8]                     entry24_cmpmask_q;
   wire [0:9]                    entry24_parity_d;
   reg [0:9]                     entry24_parity_q;
   wire [0:1]                    wr_entry24_sel;
   wire                          entry24_inval;
   wire [0:1]                    entry24_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry24_cam_vec;
   wire [0:51]                   entry25_epn_d;
   reg [0:51]                    entry25_epn_q;
   wire                          entry25_xbit_d;
   reg                           entry25_xbit_q;
   wire [0:2]                    entry25_size_d;
   reg [0:2]                     entry25_size_q;
   wire                          entry25_v_d;
   reg                           entry25_v_q;
   wire [0:3]                    entry25_thdid_d;
   reg [0:3]                     entry25_thdid_q;
   wire [0:1]                    entry25_class_d;
   reg [0:1]                     entry25_class_q;
   wire [0:1]                    entry25_extclass_d;
   reg [0:1]                     entry25_extclass_q;
   wire                          entry25_hv_d;
   reg                           entry25_hv_q;
   wire                          entry25_ds_d;
   reg                           entry25_ds_q;
   wire [0:7]                    entry25_pid_d;
   reg [0:7]                     entry25_pid_q;
   wire [0:8]                    entry25_cmpmask_d;
   reg [0:8]                     entry25_cmpmask_q;
   wire [0:9]                    entry25_parity_d;
   reg [0:9]                     entry25_parity_q;
   wire [0:1]                    wr_entry25_sel;
   wire                          entry25_inval;
   wire [0:1]                    entry25_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry25_cam_vec;
   wire [0:51]                   entry26_epn_d;
   reg [0:51]                    entry26_epn_q;
   wire                          entry26_xbit_d;
   reg                           entry26_xbit_q;
   wire [0:2]                    entry26_size_d;
   reg [0:2]                     entry26_size_q;
   wire                          entry26_v_d;
   reg                           entry26_v_q;
   wire [0:3]                    entry26_thdid_d;
   reg [0:3]                     entry26_thdid_q;
   wire [0:1]                    entry26_class_d;
   reg [0:1]                     entry26_class_q;
   wire [0:1]                    entry26_extclass_d;
   reg [0:1]                     entry26_extclass_q;
   wire                          entry26_hv_d;
   reg                           entry26_hv_q;
   wire                          entry26_ds_d;
   reg                           entry26_ds_q;
   wire [0:7]                    entry26_pid_d;
   reg [0:7]                     entry26_pid_q;
   wire [0:8]                    entry26_cmpmask_d;
   reg [0:8]                     entry26_cmpmask_q;
   wire [0:9]                    entry26_parity_d;
   reg [0:9]                     entry26_parity_q;
   wire [0:1]                    wr_entry26_sel;
   wire                          entry26_inval;
   wire [0:1]                    entry26_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry26_cam_vec;
   wire [0:51]                   entry27_epn_d;
   reg [0:51]                    entry27_epn_q;
   wire                          entry27_xbit_d;
   reg                           entry27_xbit_q;
   wire [0:2]                    entry27_size_d;
   reg [0:2]                     entry27_size_q;
   wire                          entry27_v_d;
   reg                           entry27_v_q;
   wire [0:3]                    entry27_thdid_d;
   reg [0:3]                     entry27_thdid_q;
   wire [0:1]                    entry27_class_d;
   reg [0:1]                     entry27_class_q;
   wire [0:1]                    entry27_extclass_d;
   reg [0:1]                     entry27_extclass_q;
   wire                          entry27_hv_d;
   reg                           entry27_hv_q;
   wire                          entry27_ds_d;
   reg                           entry27_ds_q;
   wire [0:7]                    entry27_pid_d;
   reg [0:7]                     entry27_pid_q;
   wire [0:8]                    entry27_cmpmask_d;
   reg [0:8]                     entry27_cmpmask_q;
   wire [0:9]                    entry27_parity_d;
   reg [0:9]                     entry27_parity_q;
   wire [0:1]                    wr_entry27_sel;
   wire                          entry27_inval;
   wire [0:1]                    entry27_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry27_cam_vec;
   wire [0:51]                   entry28_epn_d;
   reg [0:51]                    entry28_epn_q;
   wire                          entry28_xbit_d;
   reg                           entry28_xbit_q;
   wire [0:2]                    entry28_size_d;
   reg [0:2]                     entry28_size_q;
   wire                          entry28_v_d;
   reg                           entry28_v_q;
   wire [0:3]                    entry28_thdid_d;
   reg [0:3]                     entry28_thdid_q;
   wire [0:1]                    entry28_class_d;
   reg [0:1]                     entry28_class_q;
   wire [0:1]                    entry28_extclass_d;
   reg [0:1]                     entry28_extclass_q;
   wire                          entry28_hv_d;
   reg                           entry28_hv_q;
   wire                          entry28_ds_d;
   reg                           entry28_ds_q;
   wire [0:7]                    entry28_pid_d;
   reg [0:7]                     entry28_pid_q;
   wire [0:8]                    entry28_cmpmask_d;
   reg [0:8]                     entry28_cmpmask_q;
   wire [0:9]                    entry28_parity_d;
   reg [0:9]                     entry28_parity_q;
   wire [0:1]                    wr_entry28_sel;
   wire                          entry28_inval;
   wire [0:1]                    entry28_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry28_cam_vec;
   wire [0:51]                   entry29_epn_d;
   reg [0:51]                    entry29_epn_q;
   wire                          entry29_xbit_d;
   reg                           entry29_xbit_q;
   wire [0:2]                    entry29_size_d;
   reg [0:2]                     entry29_size_q;
   wire                          entry29_v_d;
   reg                           entry29_v_q;
   wire [0:3]                    entry29_thdid_d;
   reg [0:3]                     entry29_thdid_q;
   wire [0:1]                    entry29_class_d;
   reg [0:1]                     entry29_class_q;
   wire [0:1]                    entry29_extclass_d;
   reg [0:1]                     entry29_extclass_q;
   wire                          entry29_hv_d;
   reg                           entry29_hv_q;
   wire                          entry29_ds_d;
   reg                           entry29_ds_q;
   wire [0:7]                    entry29_pid_d;
   reg [0:7]                     entry29_pid_q;
   wire [0:8]                    entry29_cmpmask_d;
   reg [0:8]                     entry29_cmpmask_q;
   wire [0:9]                    entry29_parity_d;
   reg [0:9]                     entry29_parity_q;
   wire [0:1]                    wr_entry29_sel;
   wire                          entry29_inval;
   wire [0:1]                    entry29_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry29_cam_vec;
   wire [0:51]                   entry30_epn_d;
   reg [0:51]                    entry30_epn_q;
   wire                          entry30_xbit_d;
   reg                           entry30_xbit_q;
   wire [0:2]                    entry30_size_d;
   reg [0:2]                     entry30_size_q;
   wire                          entry30_v_d;
   reg                           entry30_v_q;
   wire [0:3]                    entry30_thdid_d;
   reg [0:3]                     entry30_thdid_q;
   wire [0:1]                    entry30_class_d;
   reg [0:1]                     entry30_class_q;
   wire [0:1]                    entry30_extclass_d;
   reg [0:1]                     entry30_extclass_q;
   wire                          entry30_hv_d;
   reg                           entry30_hv_q;
   wire                          entry30_ds_d;
   reg                           entry30_ds_q;
   wire [0:7]                    entry30_pid_d;
   reg [0:7]                     entry30_pid_q;
   wire [0:8]                    entry30_cmpmask_d;
   reg [0:8]                     entry30_cmpmask_q;
   wire [0:9]                    entry30_parity_d;
   reg [0:9]                     entry30_parity_q;
   wire [0:1]                    wr_entry30_sel;
   wire                          entry30_inval;
   wire [0:1]                    entry30_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry30_cam_vec;
   wire [0:51]                   entry31_epn_d;
   reg [0:51]                    entry31_epn_q;
   wire                          entry31_xbit_d;
   reg                           entry31_xbit_q;
   wire [0:2]                    entry31_size_d;
   reg [0:2]                     entry31_size_q;
   wire                          entry31_v_d;
   reg                           entry31_v_q;
   wire [0:3]                    entry31_thdid_d;
   reg [0:3]                     entry31_thdid_q;
   wire [0:1]                    entry31_class_d;
   reg [0:1]                     entry31_class_q;
   wire [0:1]                    entry31_extclass_d;
   reg [0:1]                     entry31_extclass_q;
   wire                          entry31_hv_d;
   reg                           entry31_hv_q;
   wire                          entry31_ds_d;
   reg                           entry31_ds_q;
   wire [0:7]                    entry31_pid_d;
   reg [0:7]                     entry31_pid_q;
   wire [0:8]                    entry31_cmpmask_d;
   reg [0:8]                     entry31_cmpmask_q;
   wire [0:9]                    entry31_parity_d;
   reg [0:9]                     entry31_parity_q;
   wire [0:1]                    wr_entry31_sel;
   wire                          entry31_inval;
   wire [0:1]                    entry31_v_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     entry31_cam_vec;
   wire [0:5]                    cam_cmp_data_muxsel;
   wire [0:5]                    rd_cam_data_muxsel;
   wire [0:CAM_DATA_WIDTH-1]     cam_cmp_data_np1;
   wire [0:ARRAY_DATA_WIDTH-1]   array_cmp_data_np1;
   wire [0:72]                   wr_array_data_bram;
   wire [0:72]                   rd_array_data_d_std;
   wire [0:55]                   array_cmp_data_bram_std;
   wire [66:72]                  array_cmp_data_bramp_std;

   // latch signals
   wire [0:ARRAY_DATA_WIDTH-1]   rd_array_data_d;
   reg [0:ARRAY_DATA_WIDTH-1]    rd_array_data_q;
   wire [0:CAM_DATA_WIDTH-1]     cam_cmp_data_d;
   reg [0:CAM_DATA_WIDTH-1]      cam_cmp_data_q;
   wire [0:9]                    cam_cmp_parity_d;
   reg [0:9]                     cam_cmp_parity_q;
   wire [0:CAM_DATA_WIDTH-1]     rd_cam_data_d;
   reg [0:CAM_DATA_WIDTH-1]      rd_cam_data_q;
   wire [0:NUM_ENTRY-1]          entry_match_d;
   reg [0:NUM_ENTRY-1]           entry_match_q;
   wire [0:NUM_ENTRY-1]          match_vec;
   wire [0:NUM_ENTRY_LOG2-1]     cam_hit_entry_d;
   reg [0:NUM_ENTRY_LOG2-1]      cam_hit_entry_q;
   wire                          cam_hit_d;
   reg                           cam_hit_q;
   wire                          toggle_d;
   reg                           toggle_q;
   wire                          toggle2x_d;
   reg                           toggle2x_q;
    (* analysis_not_referenced="true" *)
   wire                          unused;



   assign clk = (~nclk[0]);
   assign clk2x = nclk[2];

   always @(posedge clk)
   begin: rlatch
     sreset_q <= nclk[1];
   end

   //
   //  NEW clk2x gate logic start
   //

   always @(posedge nclk[0])
   begin: tlatch
     if (sreset_q == 1'b1)
       toggle_q <= 1'b1;
     else
       toggle_q <= toggle_d;
   end

   always @(posedge nclk[2])
   begin: flatch
     toggle2x_q <= toggle2x_d;
     gate_fq <= gate_d;
   end

   assign toggle_d = (~toggle_q);
   assign toggle2x_d = toggle_q;

   // should force gate_fq to be on during odd 2x clock (second half of 1x clock).
   assign gate_d = toggle_q ^ toggle2x_q;
   // if you want the first half do the following
   //assign gate_d <= ~(toggle_q ^ toggle2x_q);

   //
   //  NEW clk2x gate logic end
   //

   // Slow Latches (nclk)
   always @(posedge nclk[0])
   begin: slatch
     if (sreset_q == 1'b1)
     begin
       cam_cmp_data_q <= {CAM_DATA_WIDTH{1'b0}};
       cam_cmp_parity_q <= 10'b0;
       rd_cam_data_q <= {CAM_DATA_WIDTH{1'b0}};
       rd_array_data_q <= {ARRAY_DATA_WIDTH{1'b0}};
       entry_match_q <= {NUM_ENTRY{1'b0}};
       cam_hit_entry_q <= {NUM_ENTRY_LOG2{1'b0}};
       cam_hit_q <= 1'b0;
       comp_addr_np1_q <= {RPN_WIDTH{1'b0}};
       rpn_np2_q <= {RPN_WIDTH{1'b0}};
       attr_np2_q <= 21'b0;
       entry0_size_q <= 3'b0;
       entry0_xbit_q <= 1'b0;
       entry0_epn_q <= 52'b0;
       entry0_class_q <= 2'b0;
       entry0_extclass_q <= 2'b0;
       entry0_hv_q <= 1'b0;
       entry0_ds_q <= 1'b0;
       entry0_thdid_q <= 4'b0;
       entry0_pid_q <= 8'b0;
       entry0_v_q <= 1'b0;
       entry0_parity_q <= 10'b0;
       entry0_cmpmask_q <= 9'b0;
       entry1_size_q <= 3'b0;
       entry1_xbit_q <= 1'b0;
       entry1_epn_q <= 52'b0;
       entry1_class_q <= 2'b0;
       entry1_extclass_q <= 2'b0;
       entry1_hv_q <= 1'b0;
       entry1_ds_q <= 1'b0;
       entry1_thdid_q <= 4'b0;
       entry1_pid_q <= 8'b0;
       entry1_v_q <= 1'b0;
       entry1_parity_q <= 10'b0;
       entry1_cmpmask_q <= 9'b0;
       entry2_size_q <= 3'b0;
       entry2_xbit_q <= 1'b0;
       entry2_epn_q <= 52'b0;
       entry2_class_q <= 2'b0;
       entry2_extclass_q <= 2'b0;
       entry2_hv_q <= 1'b0;
       entry2_ds_q <= 1'b0;
       entry2_thdid_q <= 4'b0;
       entry2_pid_q <= 8'b0;
       entry2_v_q <= 1'b0;
       entry2_parity_q <= 10'b0;
       entry2_cmpmask_q <= 9'b0;
       entry3_size_q <= 3'b0;
       entry3_xbit_q <= 1'b0;
       entry3_epn_q <= 52'b0;
       entry3_class_q <= 2'b0;
       entry3_extclass_q <= 2'b0;
       entry3_hv_q <= 1'b0;
       entry3_ds_q <= 1'b0;
       entry3_thdid_q <= 4'b0;
       entry3_pid_q <= 8'b0;
       entry3_v_q <= 1'b0;
       entry3_parity_q <= 10'b0;
       entry3_cmpmask_q <= 9'b0;
       entry4_size_q <= 3'b0;
       entry4_xbit_q <= 1'b0;
       entry4_epn_q <= 52'b0;
       entry4_class_q <= 2'b0;
       entry4_extclass_q <= 2'b0;
       entry4_hv_q <= 1'b0;
       entry4_ds_q <= 1'b0;
       entry4_thdid_q <= 4'b0;
       entry4_pid_q <= 8'b0;
       entry4_v_q <= 1'b0;
       entry4_parity_q <= 10'b0;
       entry4_cmpmask_q <= 9'b0;
       entry5_size_q <= 3'b0;
       entry5_xbit_q <= 1'b0;
       entry5_epn_q <= 52'b0;
       entry5_class_q <= 2'b0;
       entry5_extclass_q <= 2'b0;
       entry5_hv_q <= 1'b0;
       entry5_ds_q <= 1'b0;
       entry5_thdid_q <= 4'b0;
       entry5_pid_q <= 8'b0;
       entry5_v_q <= 1'b0;
       entry5_parity_q <= 10'b0;
       entry5_cmpmask_q <= 9'b0;
       entry6_size_q <= 3'b0;
       entry6_xbit_q <= 1'b0;
       entry6_epn_q <= 52'b0;
       entry6_class_q <= 2'b0;
       entry6_extclass_q <= 2'b0;
       entry6_hv_q <= 1'b0;
       entry6_ds_q <= 1'b0;
       entry6_thdid_q <= 4'b0;
       entry6_pid_q <= 8'b0;
       entry6_v_q <= 1'b0;
       entry6_parity_q <= 10'b0;
       entry6_cmpmask_q <= 9'b0;
       entry7_size_q <= 3'b0;
       entry7_xbit_q <= 1'b0;
       entry7_epn_q <= 52'b0;
       entry7_class_q <= 2'b0;
       entry7_extclass_q <= 2'b0;
       entry7_hv_q <= 1'b0;
       entry7_ds_q <= 1'b0;
       entry7_thdid_q <= 4'b0;
       entry7_pid_q <= 8'b0;
       entry7_v_q <= 1'b0;
       entry7_parity_q <= 10'b0;
       entry7_cmpmask_q <= 9'b0;
       entry8_size_q <= 3'b0;
       entry8_xbit_q <= 1'b0;
       entry8_epn_q <= 52'b0;
       entry8_class_q <= 2'b0;
       entry8_extclass_q <= 2'b0;
       entry8_hv_q <= 1'b0;
       entry8_ds_q <= 1'b0;
       entry8_thdid_q <= 4'b0;
       entry8_pid_q <= 8'b0;
       entry8_v_q <= 1'b0;
       entry8_parity_q <= 10'b0;
       entry8_cmpmask_q <= 9'b0;
       entry9_size_q <= 3'b0;
       entry9_xbit_q <= 1'b0;
       entry9_epn_q <= 52'b0;
       entry9_class_q <= 2'b0;
       entry9_extclass_q <= 2'b0;
       entry9_hv_q <= 1'b0;
       entry9_ds_q <= 1'b0;
       entry9_thdid_q <= 4'b0;
       entry9_pid_q <= 8'b0;
       entry9_v_q <= 1'b0;
       entry9_parity_q <= 10'b0;
       entry9_cmpmask_q <= 9'b0;
       entry10_size_q <= 3'b0;
       entry10_xbit_q <= 1'b0;
       entry10_epn_q <= 52'b0;
       entry10_class_q <= 2'b0;
       entry10_extclass_q <= 2'b0;
       entry10_hv_q <= 1'b0;
       entry10_ds_q <= 1'b0;
       entry10_thdid_q <= 4'b0;
       entry10_pid_q <= 8'b0;
       entry10_v_q <= 1'b0;
       entry10_parity_q <= 10'b0;
       entry10_cmpmask_q <= 9'b0;
       entry11_size_q <= 3'b0;
       entry11_xbit_q <= 1'b0;
       entry11_epn_q <= 52'b0;
       entry11_class_q <= 2'b0;
       entry11_extclass_q <= 2'b0;
       entry11_hv_q <= 1'b0;
       entry11_ds_q <= 1'b0;
       entry11_thdid_q <= 4'b0;
       entry11_pid_q <= 8'b0;
       entry11_v_q <= 1'b0;
       entry11_parity_q <= 10'b0;
       entry11_cmpmask_q <= 9'b0;
       entry12_size_q <= 3'b0;
       entry12_xbit_q <= 1'b0;
       entry12_epn_q <= 52'b0;
       entry12_class_q <= 2'b0;
       entry12_extclass_q <= 2'b0;
       entry12_hv_q <= 1'b0;
       entry12_ds_q <= 1'b0;
       entry12_thdid_q <= 4'b0;
       entry12_pid_q <= 8'b0;
       entry12_v_q <= 1'b0;
       entry12_parity_q <= 10'b0;
       entry12_cmpmask_q <= 9'b0;
       entry13_size_q <= 3'b0;
       entry13_xbit_q <= 1'b0;
       entry13_epn_q <= 52'b0;
       entry13_class_q <= 2'b0;
       entry13_extclass_q <= 2'b0;
       entry13_hv_q <= 1'b0;
       entry13_ds_q <= 1'b0;
       entry13_thdid_q <= 4'b0;
       entry13_pid_q <= 8'b0;
       entry13_v_q <= 1'b0;
       entry13_parity_q <= 10'b0;
       entry13_cmpmask_q <= 9'b0;
       entry14_size_q <= 3'b0;
       entry14_xbit_q <= 1'b0;
       entry14_epn_q <= 52'b0;
       entry14_class_q <= 2'b0;
       entry14_extclass_q <= 2'b0;
       entry14_hv_q <= 1'b0;
       entry14_ds_q <= 1'b0;
       entry14_thdid_q <= 4'b0;
       entry14_pid_q <= 8'b0;
       entry14_v_q <= 1'b0;
       entry14_parity_q <= 10'b0;
       entry14_cmpmask_q <= 9'b0;
       entry15_size_q <= 3'b0;
       entry15_xbit_q <= 1'b0;
       entry15_epn_q <= 52'b0;
       entry15_class_q <= 2'b0;
       entry15_extclass_q <= 2'b0;
       entry15_hv_q <= 1'b0;
       entry15_ds_q <= 1'b0;
       entry15_thdid_q <= 4'b0;
       entry15_pid_q <= 8'b0;
       entry15_v_q <= 1'b0;
       entry15_parity_q <= 10'b0;
       entry15_cmpmask_q <= 9'b0;
       entry16_size_q <= 3'b0;
       entry16_xbit_q <= 1'b0;
       entry16_epn_q <= 52'b0;
       entry16_class_q <= 2'b0;
       entry16_extclass_q <= 2'b0;
       entry16_hv_q <= 1'b0;
       entry16_ds_q <= 1'b0;
       entry16_thdid_q <= 4'b0;
       entry16_pid_q <= 8'b0;
       entry16_v_q <= 1'b0;
       entry16_parity_q <= 10'b0;
       entry16_cmpmask_q <= 9'b0;
       entry17_size_q <= 3'b0;
       entry17_xbit_q <= 1'b0;
       entry17_epn_q <= 52'b0;
       entry17_class_q <= 2'b0;
       entry17_extclass_q <= 2'b0;
       entry17_hv_q <= 1'b0;
       entry17_ds_q <= 1'b0;
       entry17_thdid_q <= 4'b0;
       entry17_pid_q <= 8'b0;
       entry17_v_q <= 1'b0;
       entry17_parity_q <= 10'b0;
       entry17_cmpmask_q <= 9'b0;
       entry18_size_q <= 3'b0;
       entry18_xbit_q <= 1'b0;
       entry18_epn_q <= 52'b0;
       entry18_class_q <= 2'b0;
       entry18_extclass_q <= 2'b0;
       entry18_hv_q <= 1'b0;
       entry18_ds_q <= 1'b0;
       entry18_thdid_q <= 4'b0;
       entry18_pid_q <= 8'b0;
       entry18_v_q <= 1'b0;
       entry18_parity_q <= 10'b0;
       entry18_cmpmask_q <= 9'b0;
       entry19_size_q <= 3'b0;
       entry19_xbit_q <= 1'b0;
       entry19_epn_q <= 52'b0;
       entry19_class_q <= 2'b0;
       entry19_extclass_q <= 2'b0;
       entry19_hv_q <= 1'b0;
       entry19_ds_q <= 1'b0;
       entry19_thdid_q <= 4'b0;
       entry19_pid_q <= 8'b0;
       entry19_v_q <= 1'b0;
       entry19_parity_q <= 10'b0;
       entry19_cmpmask_q <= 9'b0;
       entry20_size_q <= 3'b0;
       entry20_xbit_q <= 1'b0;
       entry20_epn_q <= 52'b0;
       entry20_class_q <= 2'b0;
       entry20_extclass_q <= 2'b0;
       entry20_hv_q <= 1'b0;
       entry20_ds_q <= 1'b0;
       entry20_thdid_q <= 4'b0;
       entry20_pid_q <= 8'b0;
       entry20_v_q <= 1'b0;
       entry20_parity_q <= 10'b0;
       entry20_cmpmask_q <= 9'b0;
       entry21_size_q <= 3'b0;
       entry21_xbit_q <= 1'b0;
       entry21_epn_q <= 52'b0;
       entry21_class_q <= 2'b0;
       entry21_extclass_q <= 2'b0;
       entry21_hv_q <= 1'b0;
       entry21_ds_q <= 1'b0;
       entry21_thdid_q <= 4'b0;
       entry21_pid_q <= 8'b0;
       entry21_v_q <= 1'b0;
       entry21_parity_q <= 10'b0;
       entry21_cmpmask_q <= 9'b0;
       entry22_size_q <= 3'b0;
       entry22_xbit_q <= 1'b0;
       entry22_epn_q <= 52'b0;
       entry22_class_q <= 2'b0;
       entry22_extclass_q <= 2'b0;
       entry22_hv_q <= 1'b0;
       entry22_ds_q <= 1'b0;
       entry22_thdid_q <= 4'b0;
       entry22_pid_q <= 8'b0;
       entry22_v_q <= 1'b0;
       entry22_parity_q <= 10'b0;
       entry22_cmpmask_q <= 9'b0;
       entry23_size_q <= 3'b0;
       entry23_xbit_q <= 1'b0;
       entry23_epn_q <= 52'b0;
       entry23_class_q <= 2'b0;
       entry23_extclass_q <= 2'b0;
       entry23_hv_q <= 1'b0;
       entry23_ds_q <= 1'b0;
       entry23_thdid_q <= 4'b0;
       entry23_pid_q <= 8'b0;
       entry23_v_q <= 1'b0;
       entry23_parity_q <= 10'b0;
       entry23_cmpmask_q <= 9'b0;
       entry24_size_q <= 3'b0;
       entry24_xbit_q <= 1'b0;
       entry24_epn_q <= 52'b0;
       entry24_class_q <= 2'b0;
       entry24_extclass_q <= 2'b0;
       entry24_hv_q <= 1'b0;
       entry24_ds_q <= 1'b0;
       entry24_thdid_q <= 4'b0;
       entry24_pid_q <= 8'b0;
       entry24_v_q <= 1'b0;
       entry24_parity_q <= 10'b0;
       entry24_cmpmask_q <= 9'b0;
       entry25_size_q <= 3'b0;
       entry25_xbit_q <= 1'b0;
       entry25_epn_q <= 52'b0;
       entry25_class_q <= 2'b0;
       entry25_extclass_q <= 2'b0;
       entry25_hv_q <= 1'b0;
       entry25_ds_q <= 1'b0;
       entry25_thdid_q <= 4'b0;
       entry25_pid_q <= 8'b0;
       entry25_v_q <= 1'b0;
       entry25_parity_q <= 10'b0;
       entry25_cmpmask_q <= 9'b0;
       entry26_size_q <= 3'b0;
       entry26_xbit_q <= 1'b0;
       entry26_epn_q <= 52'b0;
       entry26_class_q <= 2'b0;
       entry26_extclass_q <= 2'b0;
       entry26_hv_q <= 1'b0;
       entry26_ds_q <= 1'b0;
       entry26_thdid_q <= 4'b0;
       entry26_pid_q <= 8'b0;
       entry26_v_q <= 1'b0;
       entry26_parity_q <= 10'b0;
       entry26_cmpmask_q <= 9'b0;
       entry27_size_q <= 3'b0;
       entry27_xbit_q <= 1'b0;
       entry27_epn_q <= 52'b0;
       entry27_class_q <= 2'b0;
       entry27_extclass_q <= 2'b0;
       entry27_hv_q <= 1'b0;
       entry27_ds_q <= 1'b0;
       entry27_thdid_q <= 4'b0;
       entry27_pid_q <= 8'b0;
       entry27_v_q <= 1'b0;
       entry27_parity_q <= 10'b0;
       entry27_cmpmask_q <= 9'b0;
       entry28_size_q <= 3'b0;
       entry28_xbit_q <= 1'b0;
       entry28_epn_q <= 52'b0;
       entry28_class_q <= 2'b0;
       entry28_extclass_q <= 2'b0;
       entry28_hv_q <= 1'b0;
       entry28_ds_q <= 1'b0;
       entry28_thdid_q <= 4'b0;
       entry28_pid_q <= 8'b0;
       entry28_v_q <= 1'b0;
       entry28_parity_q <= 10'b0;
       entry28_cmpmask_q <= 9'b0;
       entry29_size_q <= 3'b0;
       entry29_xbit_q <= 1'b0;
       entry29_epn_q <= 52'b0;
       entry29_class_q <= 2'b0;
       entry29_extclass_q <= 2'b0;
       entry29_hv_q <= 1'b0;
       entry29_ds_q <= 1'b0;
       entry29_thdid_q <= 4'b0;
       entry29_pid_q <= 8'b0;
       entry29_v_q <= 1'b0;
       entry29_parity_q <= 10'b0;
       entry29_cmpmask_q <= 9'b0;
       entry30_size_q <= 3'b0;
       entry30_xbit_q <= 1'b0;
       entry30_epn_q <= 52'b0;
       entry30_class_q <= 2'b0;
       entry30_extclass_q <= 2'b0;
       entry30_hv_q <= 1'b0;
       entry30_ds_q <= 1'b0;
       entry30_thdid_q <= 4'b0;
       entry30_pid_q <= 8'b0;
       entry30_v_q <= 1'b0;
       entry30_parity_q <= 10'b0;
       entry30_cmpmask_q <= 9'b0;
       entry31_size_q <= 3'b0;
       entry31_xbit_q <= 1'b0;
       entry31_epn_q <= 52'b0;
       entry31_class_q <= 2'b0;
       entry31_extclass_q <= 2'b0;
       entry31_hv_q <= 1'b0;
       entry31_ds_q <= 1'b0;
       entry31_thdid_q <= 4'b0;
       entry31_pid_q <= 8'b0;
       entry31_v_q <= 1'b0;
       entry31_parity_q <= 10'b0;
       entry31_cmpmask_q <= 9'b0;
     end
     else
     begin
       cam_cmp_data_q <= cam_cmp_data_d;
       rd_cam_data_q <= rd_cam_data_d;
       rd_array_data_q <= rd_array_data_d;
       entry_match_q <= entry_match_d;
       cam_hit_entry_q <= cam_hit_entry_d;
       cam_hit_q <= cam_hit_d;
       cam_cmp_parity_q <= cam_cmp_parity_d;
       comp_addr_np1_q <= comp_addr_np1_d;
       rpn_np2_q <= rpn_np2_d;
       attr_np2_q <= attr_np2_d;
       entry0_size_q <= entry0_size_d;
       entry0_xbit_q <= entry0_xbit_d;
       entry0_epn_q <= entry0_epn_d;
       entry0_class_q <= entry0_class_d;
       entry0_extclass_q <= entry0_extclass_d;
       entry0_hv_q <= entry0_hv_d;
       entry0_ds_q <= entry0_ds_d;
       entry0_thdid_q <= entry0_thdid_d;
       entry0_pid_q <= entry0_pid_d;
       entry0_v_q <= entry0_v_d;
       entry0_parity_q <= entry0_parity_d;
       entry0_cmpmask_q <= entry0_cmpmask_d;
       entry1_size_q <= entry1_size_d;
       entry1_xbit_q <= entry1_xbit_d;
       entry1_epn_q <= entry1_epn_d;
       entry1_class_q <= entry1_class_d;
       entry1_extclass_q <= entry1_extclass_d;
       entry1_hv_q <= entry1_hv_d;
       entry1_ds_q <= entry1_ds_d;
       entry1_thdid_q <= entry1_thdid_d;
       entry1_pid_q <= entry1_pid_d;
       entry1_v_q <= entry1_v_d;
       entry1_parity_q <= entry1_parity_d;
       entry1_cmpmask_q <= entry1_cmpmask_d;
       entry2_size_q <= entry2_size_d;
       entry2_xbit_q <= entry2_xbit_d;
       entry2_epn_q <= entry2_epn_d;
       entry2_class_q <= entry2_class_d;
       entry2_extclass_q <= entry2_extclass_d;
       entry2_hv_q <= entry2_hv_d;
       entry2_ds_q <= entry2_ds_d;
       entry2_thdid_q <= entry2_thdid_d;
       entry2_pid_q <= entry2_pid_d;
       entry2_v_q <= entry2_v_d;
       entry2_parity_q <= entry2_parity_d;
       entry2_cmpmask_q <= entry2_cmpmask_d;
       entry3_size_q <= entry3_size_d;
       entry3_xbit_q <= entry3_xbit_d;
       entry3_epn_q <= entry3_epn_d;
       entry3_class_q <= entry3_class_d;
       entry3_extclass_q <= entry3_extclass_d;
       entry3_hv_q <= entry3_hv_d;
       entry3_ds_q <= entry3_ds_d;
       entry3_thdid_q <= entry3_thdid_d;
       entry3_pid_q <= entry3_pid_d;
       entry3_v_q <= entry3_v_d;
       entry3_parity_q <= entry3_parity_d;
       entry3_cmpmask_q <= entry3_cmpmask_d;
       entry4_size_q <= entry4_size_d;
       entry4_xbit_q <= entry4_xbit_d;
       entry4_epn_q <= entry4_epn_d;
       entry4_class_q <= entry4_class_d;
       entry4_extclass_q <= entry4_extclass_d;
       entry4_hv_q <= entry4_hv_d;
       entry4_ds_q <= entry4_ds_d;
       entry4_thdid_q <= entry4_thdid_d;
       entry4_pid_q <= entry4_pid_d;
       entry4_v_q <= entry4_v_d;
       entry4_parity_q <= entry4_parity_d;
       entry4_cmpmask_q <= entry4_cmpmask_d;
       entry5_size_q <= entry5_size_d;
       entry5_xbit_q <= entry5_xbit_d;
       entry5_epn_q <= entry5_epn_d;
       entry5_class_q <= entry5_class_d;
       entry5_extclass_q <= entry5_extclass_d;
       entry5_hv_q <= entry5_hv_d;
       entry5_ds_q <= entry5_ds_d;
       entry5_thdid_q <= entry5_thdid_d;
       entry5_pid_q <= entry5_pid_d;
       entry5_v_q <= entry5_v_d;
       entry5_parity_q <= entry5_parity_d;
       entry5_cmpmask_q <= entry5_cmpmask_d;
       entry6_size_q <= entry6_size_d;
       entry6_xbit_q <= entry6_xbit_d;
       entry6_epn_q <= entry6_epn_d;
       entry6_class_q <= entry6_class_d;
       entry6_extclass_q <= entry6_extclass_d;
       entry6_hv_q <= entry6_hv_d;
       entry6_ds_q <= entry6_ds_d;
       entry6_thdid_q <= entry6_thdid_d;
       entry6_pid_q <= entry6_pid_d;
       entry6_v_q <= entry6_v_d;
       entry6_parity_q <= entry6_parity_d;
       entry6_cmpmask_q <= entry6_cmpmask_d;
       entry7_size_q <= entry7_size_d;
       entry7_xbit_q <= entry7_xbit_d;
       entry7_epn_q <= entry7_epn_d;
       entry7_class_q <= entry7_class_d;
       entry7_extclass_q <= entry7_extclass_d;
       entry7_hv_q <= entry7_hv_d;
       entry7_ds_q <= entry7_ds_d;
       entry7_thdid_q <= entry7_thdid_d;
       entry7_pid_q <= entry7_pid_d;
       entry7_v_q <= entry7_v_d;
       entry7_parity_q <= entry7_parity_d;
       entry7_cmpmask_q <= entry7_cmpmask_d;
       entry8_size_q <= entry8_size_d;
       entry8_xbit_q <= entry8_xbit_d;
       entry8_epn_q <= entry8_epn_d;
       entry8_class_q <= entry8_class_d;
       entry8_extclass_q <= entry8_extclass_d;
       entry8_hv_q <= entry8_hv_d;
       entry8_ds_q <= entry8_ds_d;
       entry8_thdid_q <= entry8_thdid_d;
       entry8_pid_q <= entry8_pid_d;
       entry8_v_q <= entry8_v_d;
       entry8_parity_q <= entry8_parity_d;
       entry8_cmpmask_q <= entry8_cmpmask_d;
       entry9_size_q <= entry9_size_d;
       entry9_xbit_q <= entry9_xbit_d;
       entry9_epn_q <= entry9_epn_d;
       entry9_class_q <= entry9_class_d;
       entry9_extclass_q <= entry9_extclass_d;
       entry9_hv_q <= entry9_hv_d;
       entry9_ds_q <= entry9_ds_d;
       entry9_thdid_q <= entry9_thdid_d;
       entry9_pid_q <= entry9_pid_d;
       entry9_v_q <= entry9_v_d;
       entry9_parity_q <= entry9_parity_d;
       entry9_cmpmask_q <= entry9_cmpmask_d;
       entry10_size_q <= entry10_size_d;
       entry10_xbit_q <= entry10_xbit_d;
       entry10_epn_q <= entry10_epn_d;
       entry10_class_q <= entry10_class_d;
       entry10_extclass_q <= entry10_extclass_d;
       entry10_hv_q <= entry10_hv_d;
       entry10_ds_q <= entry10_ds_d;
       entry10_thdid_q <= entry10_thdid_d;
       entry10_pid_q <= entry10_pid_d;
       entry10_v_q <= entry10_v_d;
       entry10_parity_q <= entry10_parity_d;
       entry10_cmpmask_q <= entry10_cmpmask_d;
       entry11_size_q <= entry11_size_d;
       entry11_xbit_q <= entry11_xbit_d;
       entry11_epn_q <= entry11_epn_d;
       entry11_class_q <= entry11_class_d;
       entry11_extclass_q <= entry11_extclass_d;
       entry11_hv_q <= entry11_hv_d;
       entry11_ds_q <= entry11_ds_d;
       entry11_thdid_q <= entry11_thdid_d;
       entry11_pid_q <= entry11_pid_d;
       entry11_v_q <= entry11_v_d;
       entry11_parity_q <= entry11_parity_d;
       entry11_cmpmask_q <= entry11_cmpmask_d;
       entry12_size_q <= entry12_size_d;
       entry12_xbit_q <= entry12_xbit_d;
       entry12_epn_q <= entry12_epn_d;
       entry12_class_q <= entry12_class_d;
       entry12_extclass_q <= entry12_extclass_d;
       entry12_hv_q <= entry12_hv_d;
       entry12_ds_q <= entry12_ds_d;
       entry12_thdid_q <= entry12_thdid_d;
       entry12_pid_q <= entry12_pid_d;
       entry12_v_q <= entry12_v_d;
       entry12_parity_q <= entry12_parity_d;
       entry12_cmpmask_q <= entry12_cmpmask_d;
       entry13_size_q <= entry13_size_d;
       entry13_xbit_q <= entry13_xbit_d;
       entry13_epn_q <= entry13_epn_d;
       entry13_class_q <= entry13_class_d;
       entry13_extclass_q <= entry13_extclass_d;
       entry13_hv_q <= entry13_hv_d;
       entry13_ds_q <= entry13_ds_d;
       entry13_thdid_q <= entry13_thdid_d;
       entry13_pid_q <= entry13_pid_d;
       entry13_v_q <= entry13_v_d;
       entry13_parity_q <= entry13_parity_d;
       entry13_cmpmask_q <= entry13_cmpmask_d;
       entry14_size_q <= entry14_size_d;
       entry14_xbit_q <= entry14_xbit_d;
       entry14_epn_q <= entry14_epn_d;
       entry14_class_q <= entry14_class_d;
       entry14_extclass_q <= entry14_extclass_d;
       entry14_hv_q <= entry14_hv_d;
       entry14_ds_q <= entry14_ds_d;
       entry14_thdid_q <= entry14_thdid_d;
       entry14_pid_q <= entry14_pid_d;
       entry14_v_q <= entry14_v_d;
       entry14_parity_q <= entry14_parity_d;
       entry14_cmpmask_q <= entry14_cmpmask_d;
       entry15_size_q <= entry15_size_d;
       entry15_xbit_q <= entry15_xbit_d;
       entry15_epn_q <= entry15_epn_d;
       entry15_class_q <= entry15_class_d;
       entry15_extclass_q <= entry15_extclass_d;
       entry15_hv_q <= entry15_hv_d;
       entry15_ds_q <= entry15_ds_d;
       entry15_thdid_q <= entry15_thdid_d;
       entry15_pid_q <= entry15_pid_d;
       entry15_v_q <= entry15_v_d;
       entry15_parity_q <= entry15_parity_d;
       entry15_cmpmask_q <= entry15_cmpmask_d;
       entry16_size_q <= entry16_size_d;
       entry16_xbit_q <= entry16_xbit_d;
       entry16_epn_q <= entry16_epn_d;
       entry16_class_q <= entry16_class_d;
       entry16_extclass_q <= entry16_extclass_d;
       entry16_hv_q <= entry16_hv_d;
       entry16_ds_q <= entry16_ds_d;
       entry16_thdid_q <= entry16_thdid_d;
       entry16_pid_q <= entry16_pid_d;
       entry16_v_q <= entry16_v_d;
       entry16_parity_q <= entry16_parity_d;
       entry16_cmpmask_q <= entry16_cmpmask_d;
       entry17_size_q <= entry17_size_d;
       entry17_xbit_q <= entry17_xbit_d;
       entry17_epn_q <= entry17_epn_d;
       entry17_class_q <= entry17_class_d;
       entry17_extclass_q <= entry17_extclass_d;
       entry17_hv_q <= entry17_hv_d;
       entry17_ds_q <= entry17_ds_d;
       entry17_thdid_q <= entry17_thdid_d;
       entry17_pid_q <= entry17_pid_d;
       entry17_v_q <= entry17_v_d;
       entry17_parity_q <= entry17_parity_d;
       entry17_cmpmask_q <= entry17_cmpmask_d;
       entry18_size_q <= entry18_size_d;
       entry18_xbit_q <= entry18_xbit_d;
       entry18_epn_q <= entry18_epn_d;
       entry18_class_q <= entry18_class_d;
       entry18_extclass_q <= entry18_extclass_d;
       entry18_hv_q <= entry18_hv_d;
       entry18_ds_q <= entry18_ds_d;
       entry18_thdid_q <= entry18_thdid_d;
       entry18_pid_q <= entry18_pid_d;
       entry18_v_q <= entry18_v_d;
       entry18_parity_q <= entry18_parity_d;
       entry18_cmpmask_q <= entry18_cmpmask_d;
       entry19_size_q <= entry19_size_d;
       entry19_xbit_q <= entry19_xbit_d;
       entry19_epn_q <= entry19_epn_d;
       entry19_class_q <= entry19_class_d;
       entry19_extclass_q <= entry19_extclass_d;
       entry19_hv_q <= entry19_hv_d;
       entry19_ds_q <= entry19_ds_d;
       entry19_thdid_q <= entry19_thdid_d;
       entry19_pid_q <= entry19_pid_d;
       entry19_v_q <= entry19_v_d;
       entry19_parity_q <= entry19_parity_d;
       entry19_cmpmask_q <= entry19_cmpmask_d;
       entry20_size_q <= entry20_size_d;
       entry20_xbit_q <= entry20_xbit_d;
       entry20_epn_q <= entry20_epn_d;
       entry20_class_q <= entry20_class_d;
       entry20_extclass_q <= entry20_extclass_d;
       entry20_hv_q <= entry20_hv_d;
       entry20_ds_q <= entry20_ds_d;
       entry20_thdid_q <= entry20_thdid_d;
       entry20_pid_q <= entry20_pid_d;
       entry20_v_q <= entry20_v_d;
       entry20_parity_q <= entry20_parity_d;
       entry20_cmpmask_q <= entry20_cmpmask_d;
       entry21_size_q <= entry21_size_d;
       entry21_xbit_q <= entry21_xbit_d;
       entry21_epn_q <= entry21_epn_d;
       entry21_class_q <= entry21_class_d;
       entry21_extclass_q <= entry21_extclass_d;
       entry21_hv_q <= entry21_hv_d;
       entry21_ds_q <= entry21_ds_d;
       entry21_thdid_q <= entry21_thdid_d;
       entry21_pid_q <= entry21_pid_d;
       entry21_v_q <= entry21_v_d;
       entry21_parity_q <= entry21_parity_d;
       entry21_cmpmask_q <= entry21_cmpmask_d;
       entry22_size_q <= entry22_size_d;
       entry22_xbit_q <= entry22_xbit_d;
       entry22_epn_q <= entry22_epn_d;
       entry22_class_q <= entry22_class_d;
       entry22_extclass_q <= entry22_extclass_d;
       entry22_hv_q <= entry22_hv_d;
       entry22_ds_q <= entry22_ds_d;
       entry22_thdid_q <= entry22_thdid_d;
       entry22_pid_q <= entry22_pid_d;
       entry22_v_q <= entry22_v_d;
       entry22_parity_q <= entry22_parity_d;
       entry22_cmpmask_q <= entry22_cmpmask_d;
       entry23_size_q <= entry23_size_d;
       entry23_xbit_q <= entry23_xbit_d;
       entry23_epn_q <= entry23_epn_d;
       entry23_class_q <= entry23_class_d;
       entry23_extclass_q <= entry23_extclass_d;
       entry23_hv_q <= entry23_hv_d;
       entry23_ds_q <= entry23_ds_d;
       entry23_thdid_q <= entry23_thdid_d;
       entry23_pid_q <= entry23_pid_d;
       entry23_v_q <= entry23_v_d;
       entry23_parity_q <= entry23_parity_d;
       entry23_cmpmask_q <= entry23_cmpmask_d;
       entry24_size_q <= entry24_size_d;
       entry24_xbit_q <= entry24_xbit_d;
       entry24_epn_q <= entry24_epn_d;
       entry24_class_q <= entry24_class_d;
       entry24_extclass_q <= entry24_extclass_d;
       entry24_hv_q <= entry24_hv_d;
       entry24_ds_q <= entry24_ds_d;
       entry24_thdid_q <= entry24_thdid_d;
       entry24_pid_q <= entry24_pid_d;
       entry24_v_q <= entry24_v_d;
       entry24_parity_q <= entry24_parity_d;
       entry24_cmpmask_q <= entry24_cmpmask_d;
       entry25_size_q <= entry25_size_d;
       entry25_xbit_q <= entry25_xbit_d;
       entry25_epn_q <= entry25_epn_d;
       entry25_class_q <= entry25_class_d;
       entry25_extclass_q <= entry25_extclass_d;
       entry25_hv_q <= entry25_hv_d;
       entry25_ds_q <= entry25_ds_d;
       entry25_thdid_q <= entry25_thdid_d;
       entry25_pid_q <= entry25_pid_d;
       entry25_v_q <= entry25_v_d;
       entry25_parity_q <= entry25_parity_d;
       entry25_cmpmask_q <= entry25_cmpmask_d;
       entry26_size_q <= entry26_size_d;
       entry26_xbit_q <= entry26_xbit_d;
       entry26_epn_q <= entry26_epn_d;
       entry26_class_q <= entry26_class_d;
       entry26_extclass_q <= entry26_extclass_d;
       entry26_hv_q <= entry26_hv_d;
       entry26_ds_q <= entry26_ds_d;
       entry26_thdid_q <= entry26_thdid_d;
       entry26_pid_q <= entry26_pid_d;
       entry26_v_q <= entry26_v_d;
       entry26_parity_q <= entry26_parity_d;
       entry26_cmpmask_q <= entry26_cmpmask_d;
       entry27_size_q <= entry27_size_d;
       entry27_xbit_q <= entry27_xbit_d;
       entry27_epn_q <= entry27_epn_d;
       entry27_class_q <= entry27_class_d;
       entry27_extclass_q <= entry27_extclass_d;
       entry27_hv_q <= entry27_hv_d;
       entry27_ds_q <= entry27_ds_d;
       entry27_thdid_q <= entry27_thdid_d;
       entry27_pid_q <= entry27_pid_d;
       entry27_v_q <= entry27_v_d;
       entry27_parity_q <= entry27_parity_d;
       entry27_cmpmask_q <= entry27_cmpmask_d;
       entry28_size_q <= entry28_size_d;
       entry28_xbit_q <= entry28_xbit_d;
       entry28_epn_q <= entry28_epn_d;
       entry28_class_q <= entry28_class_d;
       entry28_extclass_q <= entry28_extclass_d;
       entry28_hv_q <= entry28_hv_d;
       entry28_ds_q <= entry28_ds_d;
       entry28_thdid_q <= entry28_thdid_d;
       entry28_pid_q <= entry28_pid_d;
       entry28_v_q <= entry28_v_d;
       entry28_parity_q <= entry28_parity_d;
       entry28_cmpmask_q <= entry28_cmpmask_d;
       entry29_size_q <= entry29_size_d;
       entry29_xbit_q <= entry29_xbit_d;
       entry29_epn_q <= entry29_epn_d;
       entry29_class_q <= entry29_class_d;
       entry29_extclass_q <= entry29_extclass_d;
       entry29_hv_q <= entry29_hv_d;
       entry29_ds_q <= entry29_ds_d;
       entry29_thdid_q <= entry29_thdid_d;
       entry29_pid_q <= entry29_pid_d;
       entry29_v_q <= entry29_v_d;
       entry29_parity_q <= entry29_parity_d;
       entry29_cmpmask_q <= entry29_cmpmask_d;
       entry30_size_q <= entry30_size_d;
       entry30_xbit_q <= entry30_xbit_d;
       entry30_epn_q <= entry30_epn_d;
       entry30_class_q <= entry30_class_d;
       entry30_extclass_q <= entry30_extclass_d;
       entry30_hv_q <= entry30_hv_d;
       entry30_ds_q <= entry30_ds_d;
       entry30_thdid_q <= entry30_thdid_d;
       entry30_pid_q <= entry30_pid_d;
       entry30_v_q <= entry30_v_d;
       entry30_parity_q <= entry30_parity_d;
       entry30_cmpmask_q <= entry30_cmpmask_d;
       entry31_size_q <= entry31_size_d;
       entry31_xbit_q <= entry31_xbit_d;
       entry31_epn_q <= entry31_epn_d;
       entry31_class_q <= entry31_class_d;
       entry31_extclass_q <= entry31_extclass_d;
       entry31_hv_q <= entry31_hv_d;
       entry31_ds_q <= entry31_ds_d;
       entry31_thdid_q <= entry31_thdid_d;
       entry31_pid_q <= entry31_pid_d;
       entry31_v_q <= entry31_v_d;
       entry31_parity_q <= entry31_parity_d;
       entry31_cmpmask_q <= entry31_cmpmask_d;
     end
   end

   //---------------------------------------------------------------------
   // latch input logic
   //---------------------------------------------------------------------
   assign comp_addr_np1_d = comp_addr[52 - RPN_WIDTH:51];

   assign cam_hit_d = ((match_vec != 32'b00000000000000000000000000000000) & (comp_request == 1'b1)) ? 1'b1 :
                      1'b0;

   assign cam_hit_entry_d = (match_vec[0:1]  == 2'b01) ? 5'b00001 :
                            (match_vec[0:2]  == 3'b001) ? 5'b00010 :
                            (match_vec[0:3]  == 4'b0001) ? 5'b00011 :
                            (match_vec[0:4]  == 5'b00001) ? 5'b00100 :
                            (match_vec[0:5]  == 6'b000001) ? 5'b00101 :
                            (match_vec[0:6]  == 7'b0000001) ? 5'b00110 :
                            (match_vec[0:7]  == 8'b00000001) ? 5'b00111 :
                            (match_vec[0:8]  == 9'b000000001) ? 5'b01000 :
                            (match_vec[0:9]  == 10'b0000000001) ? 5'b01001 :
                            (match_vec[0:10] == 11'b00000000001) ? 5'b01010 :
                            (match_vec[0:11] == 12'b000000000001) ? 5'b01011 :
                            (match_vec[0:12] == 13'b0000000000001) ? 5'b01100 :
                            (match_vec[0:13] == 14'b00000000000001) ? 5'b01101 :
                            (match_vec[0:14] == 15'b000000000000001) ? 5'b01110 :
                            (match_vec[0:15] == 16'b0000000000000001) ? 5'b01111 :
                            (match_vec[0:16] == 17'b00000000000000001) ? 5'b10000 :
                            (match_vec[0:17] == 18'b000000000000000001) ? 5'b10001 :
                            (match_vec[0:18] == 19'b0000000000000000001) ? 5'b10010 :
                            (match_vec[0:19] == 20'b00000000000000000001) ? 5'b10011 :
                            (match_vec[0:20] == 21'b000000000000000000001) ? 5'b10100 :
                            (match_vec[0:21] == 22'b0000000000000000000001) ? 5'b10101 :
                            (match_vec[0:22] == 23'b00000000000000000000001) ? 5'b10110 :
                            (match_vec[0:23] == 24'b000000000000000000000001) ? 5'b10111 :
                            (match_vec[0:24] == 25'b0000000000000000000000001) ? 5'b11000 :
                            (match_vec[0:25] == 26'b00000000000000000000000001) ? 5'b11001 :
                            (match_vec[0:26] == 27'b000000000000000000000000001) ? 5'b11010 :
                            (match_vec[0:27] == 28'b0000000000000000000000000001) ? 5'b11011 :
                            (match_vec[0:28] == 29'b00000000000000000000000000001) ? 5'b11100 :
                            (match_vec[0:29] == 30'b000000000000000000000000000001) ? 5'b11101 :
                            (match_vec[0:30] == 31'b0000000000000000000000000000001) ? 5'b11110 :
                            (match_vec[0:31] == 32'b00000000000000000000000000000001) ? 5'b11111 :
                            5'b00000;

   assign entry_match_d = ((comp_request == 1'b1)) ? match_vec :
                          {NUM_ENTRY{1'b0}};

   // entry write next state logic
   assign wr_entry0_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b00000)) ? 1'b1 :
                             1'b0;
   assign wr_entry0_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b00000)) ? 1'b1 :
                             1'b0;
   assign entry0_epn_d[0:31] = (wr_entry0_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                               entry0_epn_q[0:31];
   assign entry0_epn_d[32:51] = (wr_entry0_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                entry0_epn_q[32:51];
   assign entry0_xbit_d = (wr_entry0_sel[0] == 1'b1) ? wr_cam_data[52] :
                          entry0_xbit_q;
   assign entry0_size_d = (wr_entry0_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                          entry0_size_q[0:2];
   assign entry0_class_d = (wr_entry0_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                           entry0_class_q[0:1];
   assign entry0_extclass_d = (wr_entry0_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                              entry0_extclass_q[0:1];
   assign entry0_hv_d = (wr_entry0_sel[1] == 1'b1) ? wr_cam_data[65] :
                        entry0_hv_q;
   assign entry0_ds_d = (wr_entry0_sel[1] == 1'b1) ? wr_cam_data[66] :
                        entry0_ds_q;
   assign entry0_pid_d = (wr_entry0_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                         entry0_pid_q[0:7];
   assign entry0_cmpmask_d = (wr_entry0_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                             entry0_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry0_parity_d[0:3] = (wr_entry0_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                 entry0_parity_q[0:3];
   assign entry0_parity_d[4:6] = (wr_entry0_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                 entry0_parity_q[4:6];
   assign entry0_parity_d[7] = (wr_entry0_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                               entry0_parity_q[7];
   assign entry0_parity_d[8] = (wr_entry0_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                               entry0_parity_q[8];
   assign entry0_parity_d[9] = (wr_entry0_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                               entry0_parity_q[9];
   assign wr_entry1_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b00001)) ? 1'b1 :
                             1'b0;
   assign wr_entry1_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b00001)) ? 1'b1 :
                             1'b0;
   assign entry1_epn_d[0:31] = (wr_entry1_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                               entry1_epn_q[0:31];
   assign entry1_epn_d[32:51] = (wr_entry1_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                entry1_epn_q[32:51];
   assign entry1_xbit_d = (wr_entry1_sel[0] == 1'b1) ? wr_cam_data[52] :
                          entry1_xbit_q;
   assign entry1_size_d = (wr_entry1_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                          entry1_size_q[0:2];
   assign entry1_class_d = (wr_entry1_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                           entry1_class_q[0:1];
   assign entry1_extclass_d = (wr_entry1_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                              entry1_extclass_q[0:1];
   assign entry1_hv_d = (wr_entry1_sel[1] == 1'b1) ? wr_cam_data[65] :
                        entry1_hv_q;
   assign entry1_ds_d = (wr_entry1_sel[1] == 1'b1) ? wr_cam_data[66] :
                        entry1_ds_q;
   assign entry1_pid_d = (wr_entry1_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                         entry1_pid_q[0:7];
   assign entry1_cmpmask_d = (wr_entry1_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                             entry1_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry1_parity_d[0:3] = (wr_entry1_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                 entry1_parity_q[0:3];
   assign entry1_parity_d[4:6] = (wr_entry1_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                 entry1_parity_q[4:6];
   assign entry1_parity_d[7] = (wr_entry1_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                               entry1_parity_q[7];
   assign entry1_parity_d[8] = (wr_entry1_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                               entry1_parity_q[8];
   assign entry1_parity_d[9] = (wr_entry1_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                               entry1_parity_q[9];
   assign wr_entry2_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b00010)) ? 1'b1 :
                             1'b0;
   assign wr_entry2_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b00010)) ? 1'b1 :
                             1'b0;
   assign entry2_epn_d[0:31] = (wr_entry2_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                               entry2_epn_q[0:31];
   assign entry2_epn_d[32:51] = (wr_entry2_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                entry2_epn_q[32:51];
   assign entry2_xbit_d = (wr_entry2_sel[0] == 1'b1) ? wr_cam_data[52] :
                          entry2_xbit_q;
   assign entry2_size_d = (wr_entry2_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                          entry2_size_q[0:2];
   assign entry2_class_d = (wr_entry2_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                           entry2_class_q[0:1];
   assign entry2_extclass_d = (wr_entry2_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                              entry2_extclass_q[0:1];
   assign entry2_hv_d = (wr_entry2_sel[1] == 1'b1) ? wr_cam_data[65] :
                        entry2_hv_q;
   assign entry2_ds_d = (wr_entry2_sel[1] == 1'b1) ? wr_cam_data[66] :
                        entry2_ds_q;
   assign entry2_pid_d = (wr_entry2_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                         entry2_pid_q[0:7];
   assign entry2_cmpmask_d = (wr_entry2_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                             entry2_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry2_parity_d[0:3] = (wr_entry2_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                 entry2_parity_q[0:3];
   assign entry2_parity_d[4:6] = (wr_entry2_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                 entry2_parity_q[4:6];
   assign entry2_parity_d[7] = (wr_entry2_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                               entry2_parity_q[7];
   assign entry2_parity_d[8] = (wr_entry2_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                               entry2_parity_q[8];
   assign entry2_parity_d[9] = (wr_entry2_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                               entry2_parity_q[9];
   assign wr_entry3_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b00011)) ? 1'b1 :
                             1'b0;
   assign wr_entry3_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b00011)) ? 1'b1 :
                             1'b0;
   assign entry3_epn_d[0:31] = (wr_entry3_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                               entry3_epn_q[0:31];
   assign entry3_epn_d[32:51] = (wr_entry3_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                entry3_epn_q[32:51];
   assign entry3_xbit_d = (wr_entry3_sel[0] == 1'b1) ? wr_cam_data[52] :
                          entry3_xbit_q;
   assign entry3_size_d = (wr_entry3_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                          entry3_size_q[0:2];
   assign entry3_class_d = (wr_entry3_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                           entry3_class_q[0:1];
   assign entry3_extclass_d = (wr_entry3_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                              entry3_extclass_q[0:1];
   assign entry3_hv_d = (wr_entry3_sel[1] == 1'b1) ? wr_cam_data[65] :
                        entry3_hv_q;
   assign entry3_ds_d = (wr_entry3_sel[1] == 1'b1) ? wr_cam_data[66] :
                        entry3_ds_q;
   assign entry3_pid_d = (wr_entry3_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                         entry3_pid_q[0:7];
   assign entry3_cmpmask_d = (wr_entry3_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                             entry3_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry3_parity_d[0:3] = (wr_entry3_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                 entry3_parity_q[0:3];
   assign entry3_parity_d[4:6] = (wr_entry3_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                 entry3_parity_q[4:6];
   assign entry3_parity_d[7] = (wr_entry3_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                               entry3_parity_q[7];
   assign entry3_parity_d[8] = (wr_entry3_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                               entry3_parity_q[8];
   assign entry3_parity_d[9] = (wr_entry3_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                               entry3_parity_q[9];
   assign wr_entry4_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b00100)) ? 1'b1 :
                             1'b0;
   assign wr_entry4_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b00100)) ? 1'b1 :
                             1'b0;
   assign entry4_epn_d[0:31] = (wr_entry4_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                               entry4_epn_q[0:31];
   assign entry4_epn_d[32:51] = (wr_entry4_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                entry4_epn_q[32:51];
   assign entry4_xbit_d = (wr_entry4_sel[0] == 1'b1) ? wr_cam_data[52] :
                          entry4_xbit_q;
   assign entry4_size_d = (wr_entry4_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                          entry4_size_q[0:2];
   assign entry4_class_d = (wr_entry4_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                           entry4_class_q[0:1];
   assign entry4_extclass_d = (wr_entry4_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                              entry4_extclass_q[0:1];
   assign entry4_hv_d = (wr_entry4_sel[1] == 1'b1) ? wr_cam_data[65] :
                        entry4_hv_q;
   assign entry4_ds_d = (wr_entry4_sel[1] == 1'b1) ? wr_cam_data[66] :
                        entry4_ds_q;
   assign entry4_pid_d = (wr_entry4_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                         entry4_pid_q[0:7];
   assign entry4_cmpmask_d = (wr_entry4_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                             entry4_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry4_parity_d[0:3] = (wr_entry4_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                 entry4_parity_q[0:3];
   assign entry4_parity_d[4:6] = (wr_entry4_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                 entry4_parity_q[4:6];
   assign entry4_parity_d[7] = (wr_entry4_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                               entry4_parity_q[7];
   assign entry4_parity_d[8] = (wr_entry4_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                               entry4_parity_q[8];
   assign entry4_parity_d[9] = (wr_entry4_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                               entry4_parity_q[9];
   assign wr_entry5_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b00101)) ? 1'b1 :
                             1'b0;
   assign wr_entry5_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b00101)) ? 1'b1 :
                             1'b0;
   assign entry5_epn_d[0:31] = (wr_entry5_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                               entry5_epn_q[0:31];
   assign entry5_epn_d[32:51] = (wr_entry5_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                entry5_epn_q[32:51];
   assign entry5_xbit_d = (wr_entry5_sel[0] == 1'b1) ? wr_cam_data[52] :
                          entry5_xbit_q;
   assign entry5_size_d = (wr_entry5_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                          entry5_size_q[0:2];
   assign entry5_class_d = (wr_entry5_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                           entry5_class_q[0:1];
   assign entry5_extclass_d = (wr_entry5_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                              entry5_extclass_q[0:1];
   assign entry5_hv_d = (wr_entry5_sel[1] == 1'b1) ? wr_cam_data[65] :
                        entry5_hv_q;
   assign entry5_ds_d = (wr_entry5_sel[1] == 1'b1) ? wr_cam_data[66] :
                        entry5_ds_q;
   assign entry5_pid_d = (wr_entry5_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                         entry5_pid_q[0:7];
   assign entry5_cmpmask_d = (wr_entry5_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                             entry5_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry5_parity_d[0:3] = (wr_entry5_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                 entry5_parity_q[0:3];
   assign entry5_parity_d[4:6] = (wr_entry5_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                 entry5_parity_q[4:6];
   assign entry5_parity_d[7] = (wr_entry5_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                               entry5_parity_q[7];
   assign entry5_parity_d[8] = (wr_entry5_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                               entry5_parity_q[8];
   assign entry5_parity_d[9] = (wr_entry5_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                               entry5_parity_q[9];
   assign wr_entry6_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b00110)) ? 1'b1 :
                             1'b0;
   assign wr_entry6_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b00110)) ? 1'b1 :
                             1'b0;
   assign entry6_epn_d[0:31] = (wr_entry6_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                               entry6_epn_q[0:31];
   assign entry6_epn_d[32:51] = (wr_entry6_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                entry6_epn_q[32:51];
   assign entry6_xbit_d = (wr_entry6_sel[0] == 1'b1) ? wr_cam_data[52] :
                          entry6_xbit_q;
   assign entry6_size_d = (wr_entry6_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                          entry6_size_q[0:2];
   assign entry6_class_d = (wr_entry6_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                           entry6_class_q[0:1];
   assign entry6_extclass_d = (wr_entry6_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                              entry6_extclass_q[0:1];
   assign entry6_hv_d = (wr_entry6_sel[1] == 1'b1) ? wr_cam_data[65] :
                        entry6_hv_q;
   assign entry6_ds_d = (wr_entry6_sel[1] == 1'b1) ? wr_cam_data[66] :
                        entry6_ds_q;
   assign entry6_pid_d = (wr_entry6_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                         entry6_pid_q[0:7];
   assign entry6_cmpmask_d = (wr_entry6_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                             entry6_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry6_parity_d[0:3] = (wr_entry6_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                 entry6_parity_q[0:3];
   assign entry6_parity_d[4:6] = (wr_entry6_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                 entry6_parity_q[4:6];
   assign entry6_parity_d[7] = (wr_entry6_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                               entry6_parity_q[7];
   assign entry6_parity_d[8] = (wr_entry6_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                               entry6_parity_q[8];
   assign entry6_parity_d[9] = (wr_entry6_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                               entry6_parity_q[9];
   assign wr_entry7_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b00111)) ? 1'b1 :
                             1'b0;
   assign wr_entry7_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b00111)) ? 1'b1 :
                             1'b0;
   assign entry7_epn_d[0:31] = (wr_entry7_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                               entry7_epn_q[0:31];
   assign entry7_epn_d[32:51] = (wr_entry7_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                entry7_epn_q[32:51];
   assign entry7_xbit_d = (wr_entry7_sel[0] == 1'b1) ? wr_cam_data[52] :
                          entry7_xbit_q;
   assign entry7_size_d = (wr_entry7_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                          entry7_size_q[0:2];
   assign entry7_class_d = (wr_entry7_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                           entry7_class_q[0:1];
   assign entry7_extclass_d = (wr_entry7_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                              entry7_extclass_q[0:1];
   assign entry7_hv_d = (wr_entry7_sel[1] == 1'b1) ? wr_cam_data[65] :
                        entry7_hv_q;
   assign entry7_ds_d = (wr_entry7_sel[1] == 1'b1) ? wr_cam_data[66] :
                        entry7_ds_q;
   assign entry7_pid_d = (wr_entry7_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                         entry7_pid_q[0:7];
   assign entry7_cmpmask_d = (wr_entry7_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                             entry7_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry7_parity_d[0:3] = (wr_entry7_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                 entry7_parity_q[0:3];
   assign entry7_parity_d[4:6] = (wr_entry7_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                 entry7_parity_q[4:6];
   assign entry7_parity_d[7] = (wr_entry7_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                               entry7_parity_q[7];
   assign entry7_parity_d[8] = (wr_entry7_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                               entry7_parity_q[8];
   assign entry7_parity_d[9] = (wr_entry7_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                               entry7_parity_q[9];
   assign wr_entry8_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b01000)) ? 1'b1 :
                             1'b0;
   assign wr_entry8_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b01000)) ? 1'b1 :
                             1'b0;
   assign entry8_epn_d[0:31] = (wr_entry8_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                               entry8_epn_q[0:31];
   assign entry8_epn_d[32:51] = (wr_entry8_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                entry8_epn_q[32:51];
   assign entry8_xbit_d = (wr_entry8_sel[0] == 1'b1) ? wr_cam_data[52] :
                          entry8_xbit_q;
   assign entry8_size_d = (wr_entry8_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                          entry8_size_q[0:2];
   assign entry8_class_d = (wr_entry8_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                           entry8_class_q[0:1];
   assign entry8_extclass_d = (wr_entry8_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                              entry8_extclass_q[0:1];
   assign entry8_hv_d = (wr_entry8_sel[1] == 1'b1) ? wr_cam_data[65] :
                        entry8_hv_q;
   assign entry8_ds_d = (wr_entry8_sel[1] == 1'b1) ? wr_cam_data[66] :
                        entry8_ds_q;
   assign entry8_pid_d = (wr_entry8_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                         entry8_pid_q[0:7];
   assign entry8_cmpmask_d = (wr_entry8_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                             entry8_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry8_parity_d[0:3] = (wr_entry8_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                 entry8_parity_q[0:3];
   assign entry8_parity_d[4:6] = (wr_entry8_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                 entry8_parity_q[4:6];
   assign entry8_parity_d[7] = (wr_entry8_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                               entry8_parity_q[7];
   assign entry8_parity_d[8] = (wr_entry8_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                               entry8_parity_q[8];
   assign entry8_parity_d[9] = (wr_entry8_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                               entry8_parity_q[9];
   assign wr_entry9_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b01001)) ? 1'b1 :
                             1'b0;
   assign wr_entry9_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b01001)) ? 1'b1 :
                             1'b0;
   assign entry9_epn_d[0:31] = (wr_entry9_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                               entry9_epn_q[0:31];
   assign entry9_epn_d[32:51] = (wr_entry9_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                entry9_epn_q[32:51];
   assign entry9_xbit_d = (wr_entry9_sel[0] == 1'b1) ? wr_cam_data[52] :
                          entry9_xbit_q;
   assign entry9_size_d = (wr_entry9_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                          entry9_size_q[0:2];
   assign entry9_class_d = (wr_entry9_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                           entry9_class_q[0:1];
   assign entry9_extclass_d = (wr_entry9_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                              entry9_extclass_q[0:1];
   assign entry9_hv_d = (wr_entry9_sel[1] == 1'b1) ? wr_cam_data[65] :
                        entry9_hv_q;
   assign entry9_ds_d = (wr_entry9_sel[1] == 1'b1) ? wr_cam_data[66] :
                        entry9_ds_q;
   assign entry9_pid_d = (wr_entry9_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                         entry9_pid_q[0:7];
   assign entry9_cmpmask_d = (wr_entry9_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                             entry9_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry9_parity_d[0:3] = (wr_entry9_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                 entry9_parity_q[0:3];
   assign entry9_parity_d[4:6] = (wr_entry9_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                 entry9_parity_q[4:6];
   assign entry9_parity_d[7] = (wr_entry9_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                               entry9_parity_q[7];
   assign entry9_parity_d[8] = (wr_entry9_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                               entry9_parity_q[8];
   assign entry9_parity_d[9] = (wr_entry9_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                               entry9_parity_q[9];
   assign wr_entry10_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b01010)) ? 1'b1 :
                              1'b0;
   assign wr_entry10_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b01010)) ? 1'b1 :
                              1'b0;
   assign entry10_epn_d[0:31] = (wr_entry10_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry10_epn_q[0:31];
   assign entry10_epn_d[32:51] = (wr_entry10_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry10_epn_q[32:51];
   assign entry10_xbit_d = (wr_entry10_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry10_xbit_q;
   assign entry10_size_d = (wr_entry10_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry10_size_q[0:2];
   assign entry10_class_d = (wr_entry10_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry10_class_q[0:1];
   assign entry10_extclass_d = (wr_entry10_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry10_extclass_q[0:1];
   assign entry10_hv_d = (wr_entry10_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry10_hv_q;
   assign entry10_ds_d = (wr_entry10_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry10_ds_q;
   assign entry10_pid_d = (wr_entry10_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry10_pid_q[0:7];
   assign entry10_cmpmask_d = (wr_entry10_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry10_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry10_parity_d[0:3] = (wr_entry10_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry10_parity_q[0:3];
   assign entry10_parity_d[4:6] = (wr_entry10_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry10_parity_q[4:6];
   assign entry10_parity_d[7] = (wr_entry10_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry10_parity_q[7];
   assign entry10_parity_d[8] = (wr_entry10_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry10_parity_q[8];
   assign entry10_parity_d[9] = (wr_entry10_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry10_parity_q[9];
   assign wr_entry11_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b01011)) ? 1'b1 :
                              1'b0;
   assign wr_entry11_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b01011)) ? 1'b1 :
                              1'b0;
   assign entry11_epn_d[0:31] = (wr_entry11_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry11_epn_q[0:31];
   assign entry11_epn_d[32:51] = (wr_entry11_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry11_epn_q[32:51];
   assign entry11_xbit_d = (wr_entry11_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry11_xbit_q;
   assign entry11_size_d = (wr_entry11_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry11_size_q[0:2];
   assign entry11_class_d = (wr_entry11_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry11_class_q[0:1];
   assign entry11_extclass_d = (wr_entry11_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry11_extclass_q[0:1];
   assign entry11_hv_d = (wr_entry11_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry11_hv_q;
   assign entry11_ds_d = (wr_entry11_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry11_ds_q;
   assign entry11_pid_d = (wr_entry11_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry11_pid_q[0:7];
   assign entry11_cmpmask_d = (wr_entry11_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry11_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry11_parity_d[0:3] = (wr_entry11_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry11_parity_q[0:3];
   assign entry11_parity_d[4:6] = (wr_entry11_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry11_parity_q[4:6];
   assign entry11_parity_d[7] = (wr_entry11_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry11_parity_q[7];
   assign entry11_parity_d[8] = (wr_entry11_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry11_parity_q[8];
   assign entry11_parity_d[9] = (wr_entry11_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry11_parity_q[9];
   assign wr_entry12_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b01100)) ? 1'b1 :
                              1'b0;
   assign wr_entry12_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b01100)) ? 1'b1 :
                              1'b0;
   assign entry12_epn_d[0:31] = (wr_entry12_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry12_epn_q[0:31];
   assign entry12_epn_d[32:51] = (wr_entry12_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry12_epn_q[32:51];
   assign entry12_xbit_d = (wr_entry12_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry12_xbit_q;
   assign entry12_size_d = (wr_entry12_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry12_size_q[0:2];
   assign entry12_class_d = (wr_entry12_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry12_class_q[0:1];
   assign entry12_extclass_d = (wr_entry12_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry12_extclass_q[0:1];
   assign entry12_hv_d = (wr_entry12_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry12_hv_q;
   assign entry12_ds_d = (wr_entry12_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry12_ds_q;
   assign entry12_pid_d = (wr_entry12_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry12_pid_q[0:7];
   assign entry12_cmpmask_d = (wr_entry12_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry12_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry12_parity_d[0:3] = (wr_entry12_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry12_parity_q[0:3];
   assign entry12_parity_d[4:6] = (wr_entry12_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry12_parity_q[4:6];
   assign entry12_parity_d[7] = (wr_entry12_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry12_parity_q[7];
   assign entry12_parity_d[8] = (wr_entry12_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry12_parity_q[8];
   assign entry12_parity_d[9] = (wr_entry12_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry12_parity_q[9];
   assign wr_entry13_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b01101)) ? 1'b1 :
                              1'b0;
   assign wr_entry13_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b01101)) ? 1'b1 :
                              1'b0;
   assign entry13_epn_d[0:31] = (wr_entry13_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry13_epn_q[0:31];
   assign entry13_epn_d[32:51] = (wr_entry13_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry13_epn_q[32:51];
   assign entry13_xbit_d = (wr_entry13_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry13_xbit_q;
   assign entry13_size_d = (wr_entry13_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry13_size_q[0:2];
   assign entry13_class_d = (wr_entry13_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry13_class_q[0:1];
   assign entry13_extclass_d = (wr_entry13_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry13_extclass_q[0:1];
   assign entry13_hv_d = (wr_entry13_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry13_hv_q;
   assign entry13_ds_d = (wr_entry13_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry13_ds_q;
   assign entry13_pid_d = (wr_entry13_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry13_pid_q[0:7];
   assign entry13_cmpmask_d = (wr_entry13_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry13_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry13_parity_d[0:3] = (wr_entry13_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry13_parity_q[0:3];
   assign entry13_parity_d[4:6] = (wr_entry13_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry13_parity_q[4:6];
   assign entry13_parity_d[7] = (wr_entry13_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry13_parity_q[7];
   assign entry13_parity_d[8] = (wr_entry13_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry13_parity_q[8];
   assign entry13_parity_d[9] = (wr_entry13_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry13_parity_q[9];
   assign wr_entry14_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b01110)) ? 1'b1 :
                              1'b0;
   assign wr_entry14_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b01110)) ? 1'b1 :
                              1'b0;
   assign entry14_epn_d[0:31] = (wr_entry14_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry14_epn_q[0:31];
   assign entry14_epn_d[32:51] = (wr_entry14_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry14_epn_q[32:51];
   assign entry14_xbit_d = (wr_entry14_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry14_xbit_q;
   assign entry14_size_d = (wr_entry14_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry14_size_q[0:2];
   assign entry14_class_d = (wr_entry14_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry14_class_q[0:1];
   assign entry14_extclass_d = (wr_entry14_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry14_extclass_q[0:1];
   assign entry14_hv_d = (wr_entry14_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry14_hv_q;
   assign entry14_ds_d = (wr_entry14_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry14_ds_q;
   assign entry14_pid_d = (wr_entry14_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry14_pid_q[0:7];
   assign entry14_cmpmask_d = (wr_entry14_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry14_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry14_parity_d[0:3] = (wr_entry14_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry14_parity_q[0:3];
   assign entry14_parity_d[4:6] = (wr_entry14_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry14_parity_q[4:6];
   assign entry14_parity_d[7] = (wr_entry14_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry14_parity_q[7];
   assign entry14_parity_d[8] = (wr_entry14_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry14_parity_q[8];
   assign entry14_parity_d[9] = (wr_entry14_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry14_parity_q[9];
   assign wr_entry15_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b01111)) ? 1'b1 :
                              1'b0;
   assign wr_entry15_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b01111)) ? 1'b1 :
                              1'b0;
   assign entry15_epn_d[0:31] = (wr_entry15_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry15_epn_q[0:31];
   assign entry15_epn_d[32:51] = (wr_entry15_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry15_epn_q[32:51];
   assign entry15_xbit_d = (wr_entry15_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry15_xbit_q;
   assign entry15_size_d = (wr_entry15_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry15_size_q[0:2];
   assign entry15_class_d = (wr_entry15_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry15_class_q[0:1];
   assign entry15_extclass_d = (wr_entry15_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry15_extclass_q[0:1];
   assign entry15_hv_d = (wr_entry15_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry15_hv_q;
   assign entry15_ds_d = (wr_entry15_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry15_ds_q;
   assign entry15_pid_d = (wr_entry15_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry15_pid_q[0:7];
   assign entry15_cmpmask_d = (wr_entry15_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry15_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry15_parity_d[0:3] = (wr_entry15_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry15_parity_q[0:3];
   assign entry15_parity_d[4:6] = (wr_entry15_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry15_parity_q[4:6];
   assign entry15_parity_d[7] = (wr_entry15_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry15_parity_q[7];
   assign entry15_parity_d[8] = (wr_entry15_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry15_parity_q[8];
   assign entry15_parity_d[9] = (wr_entry15_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry15_parity_q[9];
   assign wr_entry16_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b10000)) ? 1'b1 :
                              1'b0;
   assign wr_entry16_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b10000)) ? 1'b1 :
                              1'b0;
   assign entry16_epn_d[0:31] = (wr_entry16_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry16_epn_q[0:31];
   assign entry16_epn_d[32:51] = (wr_entry16_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry16_epn_q[32:51];
   assign entry16_xbit_d = (wr_entry16_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry16_xbit_q;
   assign entry16_size_d = (wr_entry16_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry16_size_q[0:2];
   assign entry16_class_d = (wr_entry16_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry16_class_q[0:1];
   assign entry16_extclass_d = (wr_entry16_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry16_extclass_q[0:1];
   assign entry16_hv_d = (wr_entry16_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry16_hv_q;
   assign entry16_ds_d = (wr_entry16_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry16_ds_q;
   assign entry16_pid_d = (wr_entry16_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry16_pid_q[0:7];
   assign entry16_cmpmask_d = (wr_entry16_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry16_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry16_parity_d[0:3] = (wr_entry16_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry16_parity_q[0:3];
   assign entry16_parity_d[4:6] = (wr_entry16_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry16_parity_q[4:6];
   assign entry16_parity_d[7] = (wr_entry16_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry16_parity_q[7];
   assign entry16_parity_d[8] = (wr_entry16_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry16_parity_q[8];
   assign entry16_parity_d[9] = (wr_entry16_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry16_parity_q[9];
   assign wr_entry17_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b10001)) ? 1'b1 :
                              1'b0;
   assign wr_entry17_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b10001)) ? 1'b1 :
                              1'b0;
   assign entry17_epn_d[0:31] = (wr_entry17_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry17_epn_q[0:31];
   assign entry17_epn_d[32:51] = (wr_entry17_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry17_epn_q[32:51];
   assign entry17_xbit_d = (wr_entry17_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry17_xbit_q;
   assign entry17_size_d = (wr_entry17_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry17_size_q[0:2];
   assign entry17_class_d = (wr_entry17_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry17_class_q[0:1];
   assign entry17_extclass_d = (wr_entry17_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry17_extclass_q[0:1];
   assign entry17_hv_d = (wr_entry17_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry17_hv_q;
   assign entry17_ds_d = (wr_entry17_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry17_ds_q;
   assign entry17_pid_d = (wr_entry17_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry17_pid_q[0:7];
   assign entry17_cmpmask_d = (wr_entry17_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry17_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry17_parity_d[0:3] = (wr_entry17_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry17_parity_q[0:3];
   assign entry17_parity_d[4:6] = (wr_entry17_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry17_parity_q[4:6];
   assign entry17_parity_d[7] = (wr_entry17_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry17_parity_q[7];
   assign entry17_parity_d[8] = (wr_entry17_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry17_parity_q[8];
   assign entry17_parity_d[9] = (wr_entry17_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry17_parity_q[9];
   assign wr_entry18_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b10010)) ? 1'b1 :
                              1'b0;
   assign wr_entry18_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b10010)) ? 1'b1 :
                              1'b0;
   assign entry18_epn_d[0:31] = (wr_entry18_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry18_epn_q[0:31];
   assign entry18_epn_d[32:51] = (wr_entry18_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry18_epn_q[32:51];
   assign entry18_xbit_d = (wr_entry18_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry18_xbit_q;
   assign entry18_size_d = (wr_entry18_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry18_size_q[0:2];
   assign entry18_class_d = (wr_entry18_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry18_class_q[0:1];
   assign entry18_extclass_d = (wr_entry18_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry18_extclass_q[0:1];
   assign entry18_hv_d = (wr_entry18_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry18_hv_q;
   assign entry18_ds_d = (wr_entry18_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry18_ds_q;
   assign entry18_pid_d = (wr_entry18_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry18_pid_q[0:7];
   assign entry18_cmpmask_d = (wr_entry18_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry18_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry18_parity_d[0:3] = (wr_entry18_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry18_parity_q[0:3];
   assign entry18_parity_d[4:6] = (wr_entry18_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry18_parity_q[4:6];
   assign entry18_parity_d[7] = (wr_entry18_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry18_parity_q[7];
   assign entry18_parity_d[8] = (wr_entry18_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry18_parity_q[8];
   assign entry18_parity_d[9] = (wr_entry18_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry18_parity_q[9];
   assign wr_entry19_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b10011)) ? 1'b1 :
                              1'b0;
   assign wr_entry19_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b10011)) ? 1'b1 :
                              1'b0;
   assign entry19_epn_d[0:31] = (wr_entry19_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry19_epn_q[0:31];
   assign entry19_epn_d[32:51] = (wr_entry19_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry19_epn_q[32:51];
   assign entry19_xbit_d = (wr_entry19_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry19_xbit_q;
   assign entry19_size_d = (wr_entry19_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry19_size_q[0:2];
   assign entry19_class_d = (wr_entry19_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry19_class_q[0:1];
   assign entry19_extclass_d = (wr_entry19_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry19_extclass_q[0:1];
   assign entry19_hv_d = (wr_entry19_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry19_hv_q;
   assign entry19_ds_d = (wr_entry19_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry19_ds_q;
   assign entry19_pid_d = (wr_entry19_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry19_pid_q[0:7];
   assign entry19_cmpmask_d = (wr_entry19_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry19_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry19_parity_d[0:3] = (wr_entry19_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry19_parity_q[0:3];
   assign entry19_parity_d[4:6] = (wr_entry19_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry19_parity_q[4:6];
   assign entry19_parity_d[7] = (wr_entry19_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry19_parity_q[7];
   assign entry19_parity_d[8] = (wr_entry19_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry19_parity_q[8];
   assign entry19_parity_d[9] = (wr_entry19_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry19_parity_q[9];
   assign wr_entry20_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b10100)) ? 1'b1 :
                              1'b0;
   assign wr_entry20_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b10100)) ? 1'b1 :
                              1'b0;
   assign entry20_epn_d[0:31] = (wr_entry20_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry20_epn_q[0:31];
   assign entry20_epn_d[32:51] = (wr_entry20_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry20_epn_q[32:51];
   assign entry20_xbit_d = (wr_entry20_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry20_xbit_q;
   assign entry20_size_d = (wr_entry20_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry20_size_q[0:2];
   assign entry20_class_d = (wr_entry20_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry20_class_q[0:1];
   assign entry20_extclass_d = (wr_entry20_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry20_extclass_q[0:1];
   assign entry20_hv_d = (wr_entry20_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry20_hv_q;
   assign entry20_ds_d = (wr_entry20_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry20_ds_q;
   assign entry20_pid_d = (wr_entry20_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry20_pid_q[0:7];
   assign entry20_cmpmask_d = (wr_entry20_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry20_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry20_parity_d[0:3] = (wr_entry20_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry20_parity_q[0:3];
   assign entry20_parity_d[4:6] = (wr_entry20_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry20_parity_q[4:6];
   assign entry20_parity_d[7] = (wr_entry20_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry20_parity_q[7];
   assign entry20_parity_d[8] = (wr_entry20_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry20_parity_q[8];
   assign entry20_parity_d[9] = (wr_entry20_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry20_parity_q[9];
   assign wr_entry21_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b10101)) ? 1'b1 :
                              1'b0;
   assign wr_entry21_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b10101)) ? 1'b1 :
                              1'b0;
   assign entry21_epn_d[0:31] = (wr_entry21_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry21_epn_q[0:31];
   assign entry21_epn_d[32:51] = (wr_entry21_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry21_epn_q[32:51];
   assign entry21_xbit_d = (wr_entry21_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry21_xbit_q;
   assign entry21_size_d = (wr_entry21_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry21_size_q[0:2];
   assign entry21_class_d = (wr_entry21_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry21_class_q[0:1];
   assign entry21_extclass_d = (wr_entry21_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry21_extclass_q[0:1];
   assign entry21_hv_d = (wr_entry21_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry21_hv_q;
   assign entry21_ds_d = (wr_entry21_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry21_ds_q;
   assign entry21_pid_d = (wr_entry21_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry21_pid_q[0:7];
   assign entry21_cmpmask_d = (wr_entry21_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry21_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry21_parity_d[0:3] = (wr_entry21_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry21_parity_q[0:3];
   assign entry21_parity_d[4:6] = (wr_entry21_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry21_parity_q[4:6];
   assign entry21_parity_d[7] = (wr_entry21_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry21_parity_q[7];
   assign entry21_parity_d[8] = (wr_entry21_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry21_parity_q[8];
   assign entry21_parity_d[9] = (wr_entry21_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry21_parity_q[9];
   assign wr_entry22_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b10110)) ? 1'b1 :
                              1'b0;
   assign wr_entry22_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b10110)) ? 1'b1 :
                              1'b0;
   assign entry22_epn_d[0:31] = (wr_entry22_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry22_epn_q[0:31];
   assign entry22_epn_d[32:51] = (wr_entry22_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry22_epn_q[32:51];
   assign entry22_xbit_d = (wr_entry22_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry22_xbit_q;
   assign entry22_size_d = (wr_entry22_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry22_size_q[0:2];
   assign entry22_class_d = (wr_entry22_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry22_class_q[0:1];
   assign entry22_extclass_d = (wr_entry22_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry22_extclass_q[0:1];
   assign entry22_hv_d = (wr_entry22_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry22_hv_q;
   assign entry22_ds_d = (wr_entry22_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry22_ds_q;
   assign entry22_pid_d = (wr_entry22_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry22_pid_q[0:7];
   assign entry22_cmpmask_d = (wr_entry22_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry22_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry22_parity_d[0:3] = (wr_entry22_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry22_parity_q[0:3];
   assign entry22_parity_d[4:6] = (wr_entry22_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry22_parity_q[4:6];
   assign entry22_parity_d[7] = (wr_entry22_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry22_parity_q[7];
   assign entry22_parity_d[8] = (wr_entry22_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry22_parity_q[8];
   assign entry22_parity_d[9] = (wr_entry22_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry22_parity_q[9];
   assign wr_entry23_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b10111)) ? 1'b1 :
                              1'b0;
   assign wr_entry23_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b10111)) ? 1'b1 :
                              1'b0;
   assign entry23_epn_d[0:31] = (wr_entry23_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry23_epn_q[0:31];
   assign entry23_epn_d[32:51] = (wr_entry23_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry23_epn_q[32:51];
   assign entry23_xbit_d = (wr_entry23_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry23_xbit_q;
   assign entry23_size_d = (wr_entry23_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry23_size_q[0:2];
   assign entry23_class_d = (wr_entry23_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry23_class_q[0:1];
   assign entry23_extclass_d = (wr_entry23_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry23_extclass_q[0:1];
   assign entry23_hv_d = (wr_entry23_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry23_hv_q;
   assign entry23_ds_d = (wr_entry23_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry23_ds_q;
   assign entry23_pid_d = (wr_entry23_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry23_pid_q[0:7];
   assign entry23_cmpmask_d = (wr_entry23_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry23_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry23_parity_d[0:3] = (wr_entry23_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry23_parity_q[0:3];
   assign entry23_parity_d[4:6] = (wr_entry23_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry23_parity_q[4:6];
   assign entry23_parity_d[7] = (wr_entry23_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry23_parity_q[7];
   assign entry23_parity_d[8] = (wr_entry23_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry23_parity_q[8];
   assign entry23_parity_d[9] = (wr_entry23_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry23_parity_q[9];
   assign wr_entry24_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b11000)) ? 1'b1 :
                              1'b0;
   assign wr_entry24_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b11000)) ? 1'b1 :
                              1'b0;
   assign entry24_epn_d[0:31] = (wr_entry24_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry24_epn_q[0:31];
   assign entry24_epn_d[32:51] = (wr_entry24_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry24_epn_q[32:51];
   assign entry24_xbit_d = (wr_entry24_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry24_xbit_q;
   assign entry24_size_d = (wr_entry24_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry24_size_q[0:2];
   assign entry24_class_d = (wr_entry24_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry24_class_q[0:1];
   assign entry24_extclass_d = (wr_entry24_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry24_extclass_q[0:1];
   assign entry24_hv_d = (wr_entry24_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry24_hv_q;
   assign entry24_ds_d = (wr_entry24_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry24_ds_q;
   assign entry24_pid_d = (wr_entry24_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry24_pid_q[0:7];
   assign entry24_cmpmask_d = (wr_entry24_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry24_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry24_parity_d[0:3] = (wr_entry24_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry24_parity_q[0:3];
   assign entry24_parity_d[4:6] = (wr_entry24_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry24_parity_q[4:6];
   assign entry24_parity_d[7] = (wr_entry24_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry24_parity_q[7];
   assign entry24_parity_d[8] = (wr_entry24_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry24_parity_q[8];
   assign entry24_parity_d[9] = (wr_entry24_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry24_parity_q[9];
   assign wr_entry25_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b11001)) ? 1'b1 :
                              1'b0;
   assign wr_entry25_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b11001)) ? 1'b1 :
                              1'b0;
   assign entry25_epn_d[0:31] = (wr_entry25_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry25_epn_q[0:31];
   assign entry25_epn_d[32:51] = (wr_entry25_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry25_epn_q[32:51];
   assign entry25_xbit_d = (wr_entry25_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry25_xbit_q;
   assign entry25_size_d = (wr_entry25_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry25_size_q[0:2];
   assign entry25_class_d = (wr_entry25_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry25_class_q[0:1];
   assign entry25_extclass_d = (wr_entry25_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry25_extclass_q[0:1];
   assign entry25_hv_d = (wr_entry25_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry25_hv_q;
   assign entry25_ds_d = (wr_entry25_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry25_ds_q;
   assign entry25_pid_d = (wr_entry25_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry25_pid_q[0:7];
   assign entry25_cmpmask_d = (wr_entry25_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry25_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry25_parity_d[0:3] = (wr_entry25_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry25_parity_q[0:3];
   assign entry25_parity_d[4:6] = (wr_entry25_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry25_parity_q[4:6];
   assign entry25_parity_d[7] = (wr_entry25_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry25_parity_q[7];
   assign entry25_parity_d[8] = (wr_entry25_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry25_parity_q[8];
   assign entry25_parity_d[9] = (wr_entry25_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry25_parity_q[9];
   assign wr_entry26_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b11010)) ? 1'b1 :
                              1'b0;
   assign wr_entry26_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b11010)) ? 1'b1 :
                              1'b0;
   assign entry26_epn_d[0:31] = (wr_entry26_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry26_epn_q[0:31];
   assign entry26_epn_d[32:51] = (wr_entry26_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry26_epn_q[32:51];
   assign entry26_xbit_d = (wr_entry26_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry26_xbit_q;
   assign entry26_size_d = (wr_entry26_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry26_size_q[0:2];
   assign entry26_class_d = (wr_entry26_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry26_class_q[0:1];
   assign entry26_extclass_d = (wr_entry26_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry26_extclass_q[0:1];
   assign entry26_hv_d = (wr_entry26_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry26_hv_q;
   assign entry26_ds_d = (wr_entry26_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry26_ds_q;
   assign entry26_pid_d = (wr_entry26_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry26_pid_q[0:7];
   assign entry26_cmpmask_d = (wr_entry26_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry26_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry26_parity_d[0:3] = (wr_entry26_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry26_parity_q[0:3];
   assign entry26_parity_d[4:6] = (wr_entry26_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry26_parity_q[4:6];
   assign entry26_parity_d[7] = (wr_entry26_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry26_parity_q[7];
   assign entry26_parity_d[8] = (wr_entry26_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry26_parity_q[8];
   assign entry26_parity_d[9] = (wr_entry26_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry26_parity_q[9];
   assign wr_entry27_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b11011)) ? 1'b1 :
                              1'b0;
   assign wr_entry27_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b11011)) ? 1'b1 :
                              1'b0;
   assign entry27_epn_d[0:31] = (wr_entry27_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry27_epn_q[0:31];
   assign entry27_epn_d[32:51] = (wr_entry27_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry27_epn_q[32:51];
   assign entry27_xbit_d = (wr_entry27_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry27_xbit_q;
   assign entry27_size_d = (wr_entry27_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry27_size_q[0:2];
   assign entry27_class_d = (wr_entry27_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry27_class_q[0:1];
   assign entry27_extclass_d = (wr_entry27_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry27_extclass_q[0:1];
   assign entry27_hv_d = (wr_entry27_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry27_hv_q;
   assign entry27_ds_d = (wr_entry27_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry27_ds_q;
   assign entry27_pid_d = (wr_entry27_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry27_pid_q[0:7];
   assign entry27_cmpmask_d = (wr_entry27_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry27_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry27_parity_d[0:3] = (wr_entry27_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry27_parity_q[0:3];
   assign entry27_parity_d[4:6] = (wr_entry27_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry27_parity_q[4:6];
   assign entry27_parity_d[7] = (wr_entry27_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry27_parity_q[7];
   assign entry27_parity_d[8] = (wr_entry27_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry27_parity_q[8];
   assign entry27_parity_d[9] = (wr_entry27_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry27_parity_q[9];
   assign wr_entry28_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b11100)) ? 1'b1 :
                              1'b0;
   assign wr_entry28_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b11100)) ? 1'b1 :
                              1'b0;
   assign entry28_epn_d[0:31] = (wr_entry28_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry28_epn_q[0:31];
   assign entry28_epn_d[32:51] = (wr_entry28_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry28_epn_q[32:51];
   assign entry28_xbit_d = (wr_entry28_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry28_xbit_q;
   assign entry28_size_d = (wr_entry28_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry28_size_q[0:2];
   assign entry28_class_d = (wr_entry28_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry28_class_q[0:1];
   assign entry28_extclass_d = (wr_entry28_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry28_extclass_q[0:1];
   assign entry28_hv_d = (wr_entry28_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry28_hv_q;
   assign entry28_ds_d = (wr_entry28_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry28_ds_q;
   assign entry28_pid_d = (wr_entry28_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry28_pid_q[0:7];
   assign entry28_cmpmask_d = (wr_entry28_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry28_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry28_parity_d[0:3] = (wr_entry28_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry28_parity_q[0:3];
   assign entry28_parity_d[4:6] = (wr_entry28_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry28_parity_q[4:6];
   assign entry28_parity_d[7] = (wr_entry28_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry28_parity_q[7];
   assign entry28_parity_d[8] = (wr_entry28_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry28_parity_q[8];
   assign entry28_parity_d[9] = (wr_entry28_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry28_parity_q[9];
   assign wr_entry29_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b11101)) ? 1'b1 :
                              1'b0;
   assign wr_entry29_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b11101)) ? 1'b1 :
                              1'b0;
   assign entry29_epn_d[0:31] = (wr_entry29_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry29_epn_q[0:31];
   assign entry29_epn_d[32:51] = (wr_entry29_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry29_epn_q[32:51];
   assign entry29_xbit_d = (wr_entry29_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry29_xbit_q;
   assign entry29_size_d = (wr_entry29_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry29_size_q[0:2];
   assign entry29_class_d = (wr_entry29_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry29_class_q[0:1];
   assign entry29_extclass_d = (wr_entry29_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry29_extclass_q[0:1];
   assign entry29_hv_d = (wr_entry29_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry29_hv_q;
   assign entry29_ds_d = (wr_entry29_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry29_ds_q;
   assign entry29_pid_d = (wr_entry29_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry29_pid_q[0:7];
   assign entry29_cmpmask_d = (wr_entry29_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry29_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry29_parity_d[0:3] = (wr_entry29_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry29_parity_q[0:3];
   assign entry29_parity_d[4:6] = (wr_entry29_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry29_parity_q[4:6];
   assign entry29_parity_d[7] = (wr_entry29_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry29_parity_q[7];
   assign entry29_parity_d[8] = (wr_entry29_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry29_parity_q[8];
   assign entry29_parity_d[9] = (wr_entry29_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry29_parity_q[9];
   assign wr_entry30_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b11110)) ? 1'b1 :
                              1'b0;
   assign wr_entry30_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b11110)) ? 1'b1 :
                              1'b0;
   assign entry30_epn_d[0:31] = (wr_entry30_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry30_epn_q[0:31];
   assign entry30_epn_d[32:51] = (wr_entry30_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry30_epn_q[32:51];
   assign entry30_xbit_d = (wr_entry30_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry30_xbit_q;
   assign entry30_size_d = (wr_entry30_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry30_size_q[0:2];
   assign entry30_class_d = (wr_entry30_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry30_class_q[0:1];
   assign entry30_extclass_d = (wr_entry30_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry30_extclass_q[0:1];
   assign entry30_hv_d = (wr_entry30_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry30_hv_q;
   assign entry30_ds_d = (wr_entry30_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry30_ds_q;
   assign entry30_pid_d = (wr_entry30_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry30_pid_q[0:7];
   assign entry30_cmpmask_d = (wr_entry30_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry30_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry30_parity_d[0:3] = (wr_entry30_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry30_parity_q[0:3];
   assign entry30_parity_d[4:6] = (wr_entry30_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry30_parity_q[4:6];
   assign entry30_parity_d[7] = (wr_entry30_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry30_parity_q[7];
   assign entry30_parity_d[8] = (wr_entry30_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry30_parity_q[8];
   assign entry30_parity_d[9] = (wr_entry30_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry30_parity_q[9];
   assign wr_entry31_sel[0] = ((wr_cam_val[0] == 1'b1) & (rw_entry == 5'b11111)) ? 1'b1 :
                              1'b0;
   assign wr_entry31_sel[1] = ((wr_cam_val[1] == 1'b1) & (rw_entry == 5'b11111)) ? 1'b1 :
                              1'b0;
   assign entry31_epn_d[0:31] = (wr_entry31_sel[0] == 1'b1) ? wr_cam_data[0:31] :
                                entry31_epn_q[0:31];
   assign entry31_epn_d[32:51] = (wr_entry31_sel[0] == 1'b1) ? wr_cam_data[32:51] :
                                 entry31_epn_q[32:51];
   assign entry31_xbit_d = (wr_entry31_sel[0] == 1'b1) ? wr_cam_data[52] :
                           entry31_xbit_q;
   assign entry31_size_d = (wr_entry31_sel[0] == 1'b1) ? wr_cam_data[53:55] :
                           entry31_size_q[0:2];
   assign entry31_class_d = (wr_entry31_sel[0] == 1'b1) ? wr_cam_data[61:62] :
                            entry31_class_q[0:1];
   assign entry31_extclass_d = (wr_entry31_sel[1] == 1'b1) ? wr_cam_data[63:64] :
                               entry31_extclass_q[0:1];
   assign entry31_hv_d = (wr_entry31_sel[1] == 1'b1) ? wr_cam_data[65] :
                         entry31_hv_q;
   assign entry31_ds_d = (wr_entry31_sel[1] == 1'b1) ? wr_cam_data[66] :
                         entry31_ds_q;
   assign entry31_pid_d = (wr_entry31_sel[1] == 1'b1) ? wr_cam_data[67:74] :
                          entry31_pid_q[0:7];
   assign entry31_cmpmask_d = (wr_entry31_sel[0] == 1'b1) ? wr_cam_data[75:83] :
                              entry31_cmpmask_q;
   // the cam parity bits.. some wr_array_data bits contain parity for cam
   assign entry31_parity_d[0:3] = (wr_entry31_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 21:RPN_WIDTH + 24] :
                                  entry31_parity_q[0:3];
   assign entry31_parity_d[4:6] = (wr_entry31_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 25:RPN_WIDTH + 27] :
                                  entry31_parity_q[4:6];
   assign entry31_parity_d[7] = (wr_entry31_sel[0] == 1'b1) ? wr_array_data[RPN_WIDTH + 28] :
                                entry31_parity_q[7];
   assign entry31_parity_d[8] = (wr_entry31_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 29] :
                                entry31_parity_q[8];
   assign entry31_parity_d[9] = (wr_entry31_sel[1] == 1'b1) ? wr_array_data[RPN_WIDTH + 30] :
                                entry31_parity_q[9];


   // entry valid and thdid next state logic
   assign entry0_inval = (comp_invalidate & match_vec[0]) | flash_invalidate;
   assign entry0_v_muxsel[0:1] = ({entry0_inval, wr_entry0_sel[0]});
   assign entry0_v_d = (entry0_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                       (entry0_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                       (entry0_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                       entry0_v_q;
   assign entry0_thdid_d[0:3] = (wr_entry0_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                entry0_thdid_q[0:3];
   assign entry1_inval = (comp_invalidate & match_vec[1]) | flash_invalidate;
   assign entry1_v_muxsel[0:1] = ({entry1_inval, wr_entry1_sel[0]});
   assign entry1_v_d = (entry1_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                       (entry1_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                       (entry1_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                       entry1_v_q;
   assign entry1_thdid_d[0:3] = (wr_entry1_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                entry1_thdid_q[0:3];
   assign entry2_inval = (comp_invalidate & match_vec[2]) | flash_invalidate;
   assign entry2_v_muxsel[0:1] = ({entry2_inval, wr_entry2_sel[0]});
   assign entry2_v_d = (entry2_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                       (entry2_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                       (entry2_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                       entry2_v_q;
   assign entry2_thdid_d[0:3] = (wr_entry2_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                entry2_thdid_q[0:3];
   assign entry3_inval = (comp_invalidate & match_vec[3]) | flash_invalidate;
   assign entry3_v_muxsel[0:1] = ({entry3_inval, wr_entry3_sel[0]});
   assign entry3_v_d = (entry3_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                       (entry3_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                       (entry3_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                       entry3_v_q;
   assign entry3_thdid_d[0:3] = (wr_entry3_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                entry3_thdid_q[0:3];
   assign entry4_inval = (comp_invalidate & match_vec[4]) | flash_invalidate;
   assign entry4_v_muxsel[0:1] = ({entry4_inval, wr_entry4_sel[0]});
   assign entry4_v_d = (entry4_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                       (entry4_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                       (entry4_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                       entry4_v_q;
   assign entry4_thdid_d[0:3] = (wr_entry4_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                entry4_thdid_q[0:3];
   assign entry5_inval = (comp_invalidate & match_vec[5]) | flash_invalidate;
   assign entry5_v_muxsel[0:1] = ({entry5_inval, wr_entry5_sel[0]});
   assign entry5_v_d = (entry5_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                       (entry5_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                       (entry5_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                       entry5_v_q;
   assign entry5_thdid_d[0:3] = (wr_entry5_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                entry5_thdid_q[0:3];
   assign entry6_inval = (comp_invalidate & match_vec[6]) | flash_invalidate;
   assign entry6_v_muxsel[0:1] = ({entry6_inval, wr_entry6_sel[0]});
   assign entry6_v_d = (entry6_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                       (entry6_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                       (entry6_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                       entry6_v_q;
   assign entry6_thdid_d[0:3] = (wr_entry6_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                entry6_thdid_q[0:3];
   assign entry7_inval = (comp_invalidate & match_vec[7]) | flash_invalidate;
   assign entry7_v_muxsel[0:1] = ({entry7_inval, wr_entry7_sel[0]});
   assign entry7_v_d = (entry7_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                       (entry7_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                       (entry7_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                       entry7_v_q;
   assign entry7_thdid_d[0:3] = (wr_entry7_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                entry7_thdid_q[0:3];
   assign entry8_inval = (comp_invalidate & match_vec[8]) | flash_invalidate;
   assign entry8_v_muxsel[0:1] = ({entry8_inval, wr_entry8_sel[0]});
   assign entry8_v_d = (entry8_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                       (entry8_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                       (entry8_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                       entry8_v_q;
   assign entry8_thdid_d[0:3] = (wr_entry8_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                entry8_thdid_q[0:3];
   assign entry9_inval = (comp_invalidate & match_vec[9]) | flash_invalidate;
   assign entry9_v_muxsel[0:1] = ({entry9_inval, wr_entry9_sel[0]});
   assign entry9_v_d = (entry9_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                       (entry9_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                       (entry9_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                       entry9_v_q;
   assign entry9_thdid_d[0:3] = (wr_entry9_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                entry9_thdid_q[0:3];
   assign entry10_inval = (comp_invalidate & match_vec[10]) | flash_invalidate;
   assign entry10_v_muxsel[0:1] = ({entry10_inval, wr_entry10_sel[0]});
   assign entry10_v_d = (entry10_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry10_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry10_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry10_v_q;
   assign entry10_thdid_d[0:3] = (wr_entry10_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry10_thdid_q[0:3];
   assign entry11_inval = (comp_invalidate & match_vec[11]) | flash_invalidate;
   assign entry11_v_muxsel[0:1] = ({entry11_inval, wr_entry11_sel[0]});
   assign entry11_v_d = (entry11_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry11_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry11_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry11_v_q;
   assign entry11_thdid_d[0:3] = (wr_entry11_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry11_thdid_q[0:3];
   assign entry12_inval = (comp_invalidate & match_vec[12]) | flash_invalidate;
   assign entry12_v_muxsel[0:1] = ({entry12_inval, wr_entry12_sel[0]});
   assign entry12_v_d = (entry12_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry12_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry12_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry12_v_q;
   assign entry12_thdid_d[0:3] = (wr_entry12_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry12_thdid_q[0:3];
   assign entry13_inval = (comp_invalidate & match_vec[13]) | flash_invalidate;
   assign entry13_v_muxsel[0:1] = ({entry13_inval, wr_entry13_sel[0]});
   assign entry13_v_d = (entry13_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry13_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry13_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry13_v_q;
   assign entry13_thdid_d[0:3] = (wr_entry13_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry13_thdid_q[0:3];
   assign entry14_inval = (comp_invalidate & match_vec[14]) | flash_invalidate;
   assign entry14_v_muxsel[0:1] = ({entry14_inval, wr_entry14_sel[0]});
   assign entry14_v_d = (entry14_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry14_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry14_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry14_v_q;
   assign entry14_thdid_d[0:3] = (wr_entry14_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry14_thdid_q[0:3];
   assign entry15_inval = (comp_invalidate & match_vec[15]) | flash_invalidate;
   assign entry15_v_muxsel[0:1] = ({entry15_inval, wr_entry15_sel[0]});
   assign entry15_v_d = (entry15_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry15_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry15_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry15_v_q;
   assign entry15_thdid_d[0:3] = (wr_entry15_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry15_thdid_q[0:3];
   assign entry16_inval = (comp_invalidate & match_vec[16]) | flash_invalidate;
   assign entry16_v_muxsel[0:1] = ({entry16_inval, wr_entry16_sel[0]});
   assign entry16_v_d = (entry16_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry16_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry16_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry16_v_q;
   assign entry16_thdid_d[0:3] = (wr_entry16_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry16_thdid_q[0:3];
   assign entry17_inval = (comp_invalidate & match_vec[17]) | flash_invalidate;
   assign entry17_v_muxsel[0:1] = ({entry17_inval, wr_entry17_sel[0]});
   assign entry17_v_d = (entry17_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry17_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry17_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry17_v_q;
   assign entry17_thdid_d[0:3] = (wr_entry17_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry17_thdid_q[0:3];
   assign entry18_inval = (comp_invalidate & match_vec[18]) | flash_invalidate;
   assign entry18_v_muxsel[0:1] = ({entry18_inval, wr_entry18_sel[0]});
   assign entry18_v_d = (entry18_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry18_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry18_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry18_v_q;
   assign entry18_thdid_d[0:3] = (wr_entry18_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry18_thdid_q[0:3];
   assign entry19_inval = (comp_invalidate & match_vec[19]) | flash_invalidate;
   assign entry19_v_muxsel[0:1] = ({entry19_inval, wr_entry19_sel[0]});
   assign entry19_v_d = (entry19_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry19_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry19_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry19_v_q;
   assign entry19_thdid_d[0:3] = (wr_entry19_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry19_thdid_q[0:3];
   assign entry20_inval = (comp_invalidate & match_vec[20]) | flash_invalidate;
   assign entry20_v_muxsel[0:1] = ({entry20_inval, wr_entry20_sel[0]});
   assign entry20_v_d = (entry20_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry20_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry20_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry20_v_q;
   assign entry20_thdid_d[0:3] = (wr_entry20_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry20_thdid_q[0:3];
   assign entry21_inval = (comp_invalidate & match_vec[21]) | flash_invalidate;
   assign entry21_v_muxsel[0:1] = ({entry21_inval, wr_entry21_sel[0]});
   assign entry21_v_d = (entry21_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry21_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry21_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry21_v_q;
   assign entry21_thdid_d[0:3] = (wr_entry21_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry21_thdid_q[0:3];
   assign entry22_inval = (comp_invalidate & match_vec[22]) | flash_invalidate;
   assign entry22_v_muxsel[0:1] = ({entry22_inval, wr_entry22_sel[0]});
   assign entry22_v_d = (entry22_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry22_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry22_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry22_v_q;
   assign entry22_thdid_d[0:3] = (wr_entry22_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry22_thdid_q[0:3];
   assign entry23_inval = (comp_invalidate & match_vec[23]) | flash_invalidate;
   assign entry23_v_muxsel[0:1] = ({entry23_inval, wr_entry23_sel[0]});
   assign entry23_v_d = (entry23_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry23_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry23_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry23_v_q;
   assign entry23_thdid_d[0:3] = (wr_entry23_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry23_thdid_q[0:3];
   assign entry24_inval = (comp_invalidate & match_vec[24]) | flash_invalidate;
   assign entry24_v_muxsel[0:1] = ({entry24_inval, wr_entry24_sel[0]});
   assign entry24_v_d = (entry24_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry24_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry24_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry24_v_q;
   assign entry24_thdid_d[0:3] = (wr_entry24_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry24_thdid_q[0:3];
   assign entry25_inval = (comp_invalidate & match_vec[25]) | flash_invalidate;
   assign entry25_v_muxsel[0:1] = ({entry25_inval, wr_entry25_sel[0]});
   assign entry25_v_d = (entry25_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry25_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry25_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry25_v_q;
   assign entry25_thdid_d[0:3] = (wr_entry25_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry25_thdid_q[0:3];
   assign entry26_inval = (comp_invalidate & match_vec[26]) | flash_invalidate;
   assign entry26_v_muxsel[0:1] = ({entry26_inval, wr_entry26_sel[0]});
   assign entry26_v_d = (entry26_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry26_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry26_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry26_v_q;
   assign entry26_thdid_d[0:3] = (wr_entry26_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry26_thdid_q[0:3];
   assign entry27_inval = (comp_invalidate & match_vec[27]) | flash_invalidate;
   assign entry27_v_muxsel[0:1] = ({entry27_inval, wr_entry27_sel[0]});
   assign entry27_v_d = (entry27_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry27_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry27_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry27_v_q;
   assign entry27_thdid_d[0:3] = (wr_entry27_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry27_thdid_q[0:3];
   assign entry28_inval = (comp_invalidate & match_vec[28]) | flash_invalidate;
   assign entry28_v_muxsel[0:1] = ({entry28_inval, wr_entry28_sel[0]});
   assign entry28_v_d = (entry28_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry28_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry28_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry28_v_q;
   assign entry28_thdid_d[0:3] = (wr_entry28_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry28_thdid_q[0:3];
   assign entry29_inval = (comp_invalidate & match_vec[29]) | flash_invalidate;
   assign entry29_v_muxsel[0:1] = ({entry29_inval, wr_entry29_sel[0]});
   assign entry29_v_d = (entry29_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry29_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry29_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry29_v_q;
   assign entry29_thdid_d[0:3] = (wr_entry29_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry29_thdid_q[0:3];
   assign entry30_inval = (comp_invalidate & match_vec[30]) | flash_invalidate;
   assign entry30_v_muxsel[0:1] = ({entry30_inval, wr_entry30_sel[0]});
   assign entry30_v_d = (entry30_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry30_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry30_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry30_v_q;
   assign entry30_thdid_d[0:3] = (wr_entry30_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry30_thdid_q[0:3];
   assign entry31_inval = (comp_invalidate & match_vec[31]) | flash_invalidate;
   assign entry31_v_muxsel[0:1] = ({entry31_inval, wr_entry31_sel[0]});
   assign entry31_v_d = (entry31_v_muxsel[0:1] == 2'b10) ? 1'b0 :
                        (entry31_v_muxsel[0:1] == 2'b11) ? 1'b0 :
                        (entry31_v_muxsel[0:1] == 2'b01) ? wr_cam_data[56] :
                        entry31_v_q;
   assign entry31_thdid_d[0:3] = (wr_entry31_sel[0] == 1'b1) ? wr_cam_data[57:60] :
                                 entry31_thdid_q[0:3];


   // CAM compare data out mux
   assign entry0_cam_vec = {entry0_epn_q, entry0_xbit_q, entry0_size_q, entry0_v_q, entry0_thdid_q, entry0_class_q, entry0_extclass_q, entry0_hv_q, entry0_ds_q, entry0_pid_q, entry0_cmpmask_q};
   assign entry1_cam_vec = {entry1_epn_q, entry1_xbit_q, entry1_size_q, entry1_v_q, entry1_thdid_q, entry1_class_q, entry1_extclass_q, entry1_hv_q, entry1_ds_q, entry1_pid_q, entry1_cmpmask_q};
   assign entry2_cam_vec = {entry2_epn_q, entry2_xbit_q, entry2_size_q, entry2_v_q, entry2_thdid_q, entry2_class_q, entry2_extclass_q, entry2_hv_q, entry2_ds_q, entry2_pid_q, entry2_cmpmask_q};
   assign entry3_cam_vec = {entry3_epn_q, entry3_xbit_q, entry3_size_q, entry3_v_q, entry3_thdid_q, entry3_class_q, entry3_extclass_q, entry3_hv_q, entry3_ds_q, entry3_pid_q, entry3_cmpmask_q};
   assign entry4_cam_vec = {entry4_epn_q, entry4_xbit_q, entry4_size_q, entry4_v_q, entry4_thdid_q, entry4_class_q, entry4_extclass_q, entry4_hv_q, entry4_ds_q, entry4_pid_q, entry4_cmpmask_q};
   assign entry5_cam_vec = {entry5_epn_q, entry5_xbit_q, entry5_size_q, entry5_v_q, entry5_thdid_q, entry5_class_q, entry5_extclass_q, entry5_hv_q, entry5_ds_q, entry5_pid_q, entry5_cmpmask_q};
   assign entry6_cam_vec = {entry6_epn_q, entry6_xbit_q, entry6_size_q, entry6_v_q, entry6_thdid_q, entry6_class_q, entry6_extclass_q, entry6_hv_q, entry6_ds_q, entry6_pid_q, entry6_cmpmask_q};
   assign entry7_cam_vec = {entry7_epn_q, entry7_xbit_q, entry7_size_q, entry7_v_q, entry7_thdid_q, entry7_class_q, entry7_extclass_q, entry7_hv_q, entry7_ds_q, entry7_pid_q, entry7_cmpmask_q};
   assign entry8_cam_vec = {entry8_epn_q, entry8_xbit_q, entry8_size_q, entry8_v_q, entry8_thdid_q, entry8_class_q, entry8_extclass_q, entry8_hv_q, entry8_ds_q, entry8_pid_q, entry8_cmpmask_q};
   assign entry9_cam_vec = {entry9_epn_q, entry9_xbit_q, entry9_size_q, entry9_v_q, entry9_thdid_q, entry9_class_q, entry9_extclass_q, entry9_hv_q, entry9_ds_q, entry9_pid_q, entry9_cmpmask_q};
   assign entry10_cam_vec = {entry10_epn_q, entry10_xbit_q, entry10_size_q, entry10_v_q, entry10_thdid_q, entry10_class_q, entry10_extclass_q, entry10_hv_q, entry10_ds_q, entry10_pid_q, entry10_cmpmask_q};
   assign entry11_cam_vec = {entry11_epn_q, entry11_xbit_q, entry11_size_q, entry11_v_q, entry11_thdid_q, entry11_class_q, entry11_extclass_q, entry11_hv_q, entry11_ds_q, entry11_pid_q, entry11_cmpmask_q};
   assign entry12_cam_vec = {entry12_epn_q, entry12_xbit_q, entry12_size_q, entry12_v_q, entry12_thdid_q, entry12_class_q, entry12_extclass_q, entry12_hv_q, entry12_ds_q, entry12_pid_q, entry12_cmpmask_q};
   assign entry13_cam_vec = {entry13_epn_q, entry13_xbit_q, entry13_size_q, entry13_v_q, entry13_thdid_q, entry13_class_q, entry13_extclass_q, entry13_hv_q, entry13_ds_q, entry13_pid_q, entry13_cmpmask_q};
   assign entry14_cam_vec = {entry14_epn_q, entry14_xbit_q, entry14_size_q, entry14_v_q, entry14_thdid_q, entry14_class_q, entry14_extclass_q, entry14_hv_q, entry14_ds_q, entry14_pid_q, entry14_cmpmask_q};
   assign entry15_cam_vec = {entry15_epn_q, entry15_xbit_q, entry15_size_q, entry15_v_q, entry15_thdid_q, entry15_class_q, entry15_extclass_q, entry15_hv_q, entry15_ds_q, entry15_pid_q, entry15_cmpmask_q};
   assign entry16_cam_vec = {entry16_epn_q, entry16_xbit_q, entry16_size_q, entry16_v_q, entry16_thdid_q, entry16_class_q, entry16_extclass_q, entry16_hv_q, entry16_ds_q, entry16_pid_q, entry16_cmpmask_q};
   assign entry17_cam_vec = {entry17_epn_q, entry17_xbit_q, entry17_size_q, entry17_v_q, entry17_thdid_q, entry17_class_q, entry17_extclass_q, entry17_hv_q, entry17_ds_q, entry17_pid_q, entry17_cmpmask_q};
   assign entry18_cam_vec = {entry18_epn_q, entry18_xbit_q, entry18_size_q, entry18_v_q, entry18_thdid_q, entry18_class_q, entry18_extclass_q, entry18_hv_q, entry18_ds_q, entry18_pid_q, entry18_cmpmask_q};
   assign entry19_cam_vec = {entry19_epn_q, entry19_xbit_q, entry19_size_q, entry19_v_q, entry19_thdid_q, entry19_class_q, entry19_extclass_q, entry19_hv_q, entry19_ds_q, entry19_pid_q, entry19_cmpmask_q};
   assign entry20_cam_vec = {entry20_epn_q, entry20_xbit_q, entry20_size_q, entry20_v_q, entry20_thdid_q, entry20_class_q, entry20_extclass_q, entry20_hv_q, entry20_ds_q, entry20_pid_q, entry20_cmpmask_q};
   assign entry21_cam_vec = {entry21_epn_q, entry21_xbit_q, entry21_size_q, entry21_v_q, entry21_thdid_q, entry21_class_q, entry21_extclass_q, entry21_hv_q, entry21_ds_q, entry21_pid_q, entry21_cmpmask_q};
   assign entry22_cam_vec = {entry22_epn_q, entry22_xbit_q, entry22_size_q, entry22_v_q, entry22_thdid_q, entry22_class_q, entry22_extclass_q, entry22_hv_q, entry22_ds_q, entry22_pid_q, entry22_cmpmask_q};
   assign entry23_cam_vec = {entry23_epn_q, entry23_xbit_q, entry23_size_q, entry23_v_q, entry23_thdid_q, entry23_class_q, entry23_extclass_q, entry23_hv_q, entry23_ds_q, entry23_pid_q, entry23_cmpmask_q};
   assign entry24_cam_vec = {entry24_epn_q, entry24_xbit_q, entry24_size_q, entry24_v_q, entry24_thdid_q, entry24_class_q, entry24_extclass_q, entry24_hv_q, entry24_ds_q, entry24_pid_q, entry24_cmpmask_q};
   assign entry25_cam_vec = {entry25_epn_q, entry25_xbit_q, entry25_size_q, entry25_v_q, entry25_thdid_q, entry25_class_q, entry25_extclass_q, entry25_hv_q, entry25_ds_q, entry25_pid_q, entry25_cmpmask_q};
   assign entry26_cam_vec = {entry26_epn_q, entry26_xbit_q, entry26_size_q, entry26_v_q, entry26_thdid_q, entry26_class_q, entry26_extclass_q, entry26_hv_q, entry26_ds_q, entry26_pid_q, entry26_cmpmask_q};
   assign entry27_cam_vec = {entry27_epn_q, entry27_xbit_q, entry27_size_q, entry27_v_q, entry27_thdid_q, entry27_class_q, entry27_extclass_q, entry27_hv_q, entry27_ds_q, entry27_pid_q, entry27_cmpmask_q};
   assign entry28_cam_vec = {entry28_epn_q, entry28_xbit_q, entry28_size_q, entry28_v_q, entry28_thdid_q, entry28_class_q, entry28_extclass_q, entry28_hv_q, entry28_ds_q, entry28_pid_q, entry28_cmpmask_q};
   assign entry29_cam_vec = {entry29_epn_q, entry29_xbit_q, entry29_size_q, entry29_v_q, entry29_thdid_q, entry29_class_q, entry29_extclass_q, entry29_hv_q, entry29_ds_q, entry29_pid_q, entry29_cmpmask_q};
   assign entry30_cam_vec = {entry30_epn_q, entry30_xbit_q, entry30_size_q, entry30_v_q, entry30_thdid_q, entry30_class_q, entry30_extclass_q, entry30_hv_q, entry30_ds_q, entry30_pid_q, entry30_cmpmask_q};
   assign entry31_cam_vec = {entry31_epn_q, entry31_xbit_q, entry31_size_q, entry31_v_q, entry31_thdid_q, entry31_class_q, entry31_extclass_q, entry31_hv_q, entry31_ds_q, entry31_pid_q, entry31_cmpmask_q};


   assign cam_cmp_data_muxsel = {(~(comp_request)), cam_hit_entry_d};
   assign cam_cmp_data_d = (cam_cmp_data_muxsel == 6'b000000) ? entry0_cam_vec :
                           (cam_cmp_data_muxsel == 6'b000001) ? entry1_cam_vec :
                           (cam_cmp_data_muxsel == 6'b000010) ? entry2_cam_vec :
                           (cam_cmp_data_muxsel == 6'b000011) ? entry3_cam_vec :
                           (cam_cmp_data_muxsel == 6'b000100) ? entry4_cam_vec :
                           (cam_cmp_data_muxsel == 6'b000101) ? entry5_cam_vec :
                           (cam_cmp_data_muxsel == 6'b000110) ? entry6_cam_vec :
                           (cam_cmp_data_muxsel == 6'b000111) ? entry7_cam_vec :
                           (cam_cmp_data_muxsel == 6'b001000) ? entry8_cam_vec :
                           (cam_cmp_data_muxsel == 6'b001001) ? entry9_cam_vec :
                           (cam_cmp_data_muxsel == 6'b001010) ? entry10_cam_vec :
                           (cam_cmp_data_muxsel == 6'b001011) ? entry11_cam_vec :
                           (cam_cmp_data_muxsel == 6'b001100) ? entry12_cam_vec :
                           (cam_cmp_data_muxsel == 6'b001101) ? entry13_cam_vec :
                           (cam_cmp_data_muxsel == 6'b001110) ? entry14_cam_vec :
                           (cam_cmp_data_muxsel == 6'b001111) ? entry15_cam_vec :
                           (cam_cmp_data_muxsel == 6'b010000) ? entry16_cam_vec :
                           (cam_cmp_data_muxsel == 6'b010001) ? entry17_cam_vec :
                           (cam_cmp_data_muxsel == 6'b010010) ? entry18_cam_vec :
                           (cam_cmp_data_muxsel == 6'b010011) ? entry19_cam_vec :
                           (cam_cmp_data_muxsel == 6'b010100) ? entry20_cam_vec :
                           (cam_cmp_data_muxsel == 6'b010101) ? entry21_cam_vec :
                           (cam_cmp_data_muxsel == 6'b010110) ? entry22_cam_vec :
                           (cam_cmp_data_muxsel == 6'b010111) ? entry23_cam_vec :
                           (cam_cmp_data_muxsel == 6'b011000) ? entry24_cam_vec :
                           (cam_cmp_data_muxsel == 6'b011001) ? entry25_cam_vec :
                           (cam_cmp_data_muxsel == 6'b011010) ? entry26_cam_vec :
                           (cam_cmp_data_muxsel == 6'b011011) ? entry27_cam_vec :
                           (cam_cmp_data_muxsel == 6'b011100) ? entry28_cam_vec :
                           (cam_cmp_data_muxsel == 6'b011101) ? entry29_cam_vec :
                           (cam_cmp_data_muxsel == 6'b011110) ? entry30_cam_vec :
                           (cam_cmp_data_muxsel == 6'b011111) ? entry31_cam_vec :
                           cam_cmp_data_q;

   assign cam_cmp_data_np1 = cam_cmp_data_q;

   // CAM read data out mux
   assign rd_cam_data_muxsel = {(~(rd_val)), rw_entry};

   assign rd_cam_data_d = (rd_cam_data_muxsel == 6'b000000) ? entry0_cam_vec :
                          (rd_cam_data_muxsel == 6'b000001) ? entry1_cam_vec :
                          (rd_cam_data_muxsel == 6'b000010) ? entry2_cam_vec :
                          (rd_cam_data_muxsel == 6'b000011) ? entry3_cam_vec :
                          (rd_cam_data_muxsel == 6'b000100) ? entry4_cam_vec :
                          (rd_cam_data_muxsel == 6'b000101) ? entry5_cam_vec :
                          (rd_cam_data_muxsel == 6'b000110) ? entry6_cam_vec :
                          (rd_cam_data_muxsel == 6'b000111) ? entry7_cam_vec :
                          (rd_cam_data_muxsel == 6'b001000) ? entry8_cam_vec :
                          (rd_cam_data_muxsel == 6'b001001) ? entry9_cam_vec :
                          (rd_cam_data_muxsel == 6'b001010) ? entry10_cam_vec :
                          (rd_cam_data_muxsel == 6'b001011) ? entry11_cam_vec :
                          (rd_cam_data_muxsel == 6'b001100) ? entry12_cam_vec :
                          (rd_cam_data_muxsel == 6'b001101) ? entry13_cam_vec :
                          (rd_cam_data_muxsel == 6'b001110) ? entry14_cam_vec :
                          (rd_cam_data_muxsel == 6'b001111) ? entry15_cam_vec :
                          (rd_cam_data_muxsel == 6'b010000) ? entry16_cam_vec :
                          (rd_cam_data_muxsel == 6'b010001) ? entry17_cam_vec :
                          (rd_cam_data_muxsel == 6'b010010) ? entry18_cam_vec :
                          (rd_cam_data_muxsel == 6'b010011) ? entry19_cam_vec :
                          (rd_cam_data_muxsel == 6'b010100) ? entry20_cam_vec :
                          (rd_cam_data_muxsel == 6'b010101) ? entry21_cam_vec :
                          (rd_cam_data_muxsel == 6'b010110) ? entry22_cam_vec :
                          (rd_cam_data_muxsel == 6'b010111) ? entry23_cam_vec :
                          (rd_cam_data_muxsel == 6'b011000) ? entry24_cam_vec :
                          (rd_cam_data_muxsel == 6'b011001) ? entry25_cam_vec :
                          (rd_cam_data_muxsel == 6'b011010) ? entry26_cam_vec :
                          (rd_cam_data_muxsel == 6'b011011) ? entry27_cam_vec :
                          (rd_cam_data_muxsel == 6'b011100) ? entry28_cam_vec :
                          (rd_cam_data_muxsel == 6'b011101) ? entry29_cam_vec :
                          (rd_cam_data_muxsel == 6'b011110) ? entry30_cam_vec :
                          (rd_cam_data_muxsel == 6'b011111) ? entry31_cam_vec :
                          rd_cam_data_q;

   // CAM compare parity out mux
   assign cam_cmp_parity_d = (cam_cmp_data_muxsel == 6'b000000) ? entry0_parity_q :
                             (cam_cmp_data_muxsel == 6'b000001) ? entry1_parity_q :
                             (cam_cmp_data_muxsel == 6'b000010) ? entry2_parity_q :
                             (cam_cmp_data_muxsel == 6'b000011) ? entry3_parity_q :
                             (cam_cmp_data_muxsel == 6'b000100) ? entry4_parity_q :
                             (cam_cmp_data_muxsel == 6'b000101) ? entry5_parity_q :
                             (cam_cmp_data_muxsel == 6'b000110) ? entry6_parity_q :
                             (cam_cmp_data_muxsel == 6'b000111) ? entry7_parity_q :
                             (cam_cmp_data_muxsel == 6'b001000) ? entry8_parity_q :
                             (cam_cmp_data_muxsel == 6'b001001) ? entry9_parity_q :
                             (cam_cmp_data_muxsel == 6'b001010) ? entry10_parity_q :
                             (cam_cmp_data_muxsel == 6'b001011) ? entry11_parity_q :
                             (cam_cmp_data_muxsel == 6'b001100) ? entry12_parity_q :
                             (cam_cmp_data_muxsel == 6'b001101) ? entry13_parity_q :
                             (cam_cmp_data_muxsel == 6'b001110) ? entry14_parity_q :
                             (cam_cmp_data_muxsel == 6'b001111) ? entry15_parity_q :
                             (cam_cmp_data_muxsel == 6'b010000) ? entry16_parity_q :
                             (cam_cmp_data_muxsel == 6'b010001) ? entry17_parity_q :
                             (cam_cmp_data_muxsel == 6'b010010) ? entry18_parity_q :
                             (cam_cmp_data_muxsel == 6'b010011) ? entry19_parity_q :
                             (cam_cmp_data_muxsel == 6'b010100) ? entry20_parity_q :
                             (cam_cmp_data_muxsel == 6'b010101) ? entry21_parity_q :
                             (cam_cmp_data_muxsel == 6'b010110) ? entry22_parity_q :
                             (cam_cmp_data_muxsel == 6'b010111) ? entry23_parity_q :
                             (cam_cmp_data_muxsel == 6'b011000) ? entry24_parity_q :
                             (cam_cmp_data_muxsel == 6'b011001) ? entry25_parity_q :
                             (cam_cmp_data_muxsel == 6'b011010) ? entry26_parity_q :
                             (cam_cmp_data_muxsel == 6'b011011) ? entry27_parity_q :
                             (cam_cmp_data_muxsel == 6'b011100) ? entry28_parity_q :
                             (cam_cmp_data_muxsel == 6'b011101) ? entry29_parity_q :
                             (cam_cmp_data_muxsel == 6'b011110) ? entry30_parity_q :
                             (cam_cmp_data_muxsel == 6'b011111) ? entry31_parity_q :
                             cam_cmp_parity_q;

   assign array_cmp_data_np1[0:50] = {array_cmp_data_bram[2:31], array_cmp_data_bram[34:39], array_cmp_data_bram[41:55]};
   assign array_cmp_data_np1[51:60] = cam_cmp_parity_q;
   assign array_cmp_data_np1[61:67] = array_cmp_data_bramp[66:72];

   assign array_cmp_data = array_cmp_data_np1;

   // CAM read parity out mux
   assign rd_array_data_d[51:60] = (rd_cam_data_muxsel == 6'b000000) ? entry0_parity_q :
                                   (rd_cam_data_muxsel == 6'b000001) ? entry1_parity_q :
                                   (rd_cam_data_muxsel == 6'b000010) ? entry2_parity_q :
                                   (rd_cam_data_muxsel == 6'b000011) ? entry3_parity_q :
                                   (rd_cam_data_muxsel == 6'b000100) ? entry4_parity_q :
                                   (rd_cam_data_muxsel == 6'b000101) ? entry5_parity_q :
                                   (rd_cam_data_muxsel == 6'b000110) ? entry6_parity_q :
                                   (rd_cam_data_muxsel == 6'b000111) ? entry7_parity_q :
                                   (rd_cam_data_muxsel == 6'b001000) ? entry8_parity_q :
                                   (rd_cam_data_muxsel == 6'b001001) ? entry9_parity_q :
                                   (rd_cam_data_muxsel == 6'b001010) ? entry10_parity_q :
                                   (rd_cam_data_muxsel == 6'b001011) ? entry11_parity_q :
                                   (rd_cam_data_muxsel == 6'b001100) ? entry12_parity_q :
                                   (rd_cam_data_muxsel == 6'b001101) ? entry13_parity_q :
                                   (rd_cam_data_muxsel == 6'b001110) ? entry14_parity_q :
                                   (rd_cam_data_muxsel == 6'b001111) ? entry15_parity_q :
                                   (rd_cam_data_muxsel == 6'b010000) ? entry16_parity_q :
                                   (rd_cam_data_muxsel == 6'b010001) ? entry17_parity_q :
                                   (rd_cam_data_muxsel == 6'b010010) ? entry18_parity_q :
                                   (rd_cam_data_muxsel == 6'b010011) ? entry19_parity_q :
                                   (rd_cam_data_muxsel == 6'b010100) ? entry20_parity_q :
                                   (rd_cam_data_muxsel == 6'b010101) ? entry21_parity_q :
                                   (rd_cam_data_muxsel == 6'b010110) ? entry22_parity_q :
                                   (rd_cam_data_muxsel == 6'b010111) ? entry23_parity_q :
                                   (rd_cam_data_muxsel == 6'b011000) ? entry24_parity_q :
                                   (rd_cam_data_muxsel == 6'b011001) ? entry25_parity_q :
                                   (rd_cam_data_muxsel == 6'b011010) ? entry26_parity_q :
                                   (rd_cam_data_muxsel == 6'b011011) ? entry27_parity_q :
                                   (rd_cam_data_muxsel == 6'b011100) ? entry28_parity_q :
                                   (rd_cam_data_muxsel == 6'b011101) ? entry29_parity_q :
                                   (rd_cam_data_muxsel == 6'b011110) ? entry30_parity_q :
                                   (rd_cam_data_muxsel == 6'b011111) ? entry31_parity_q :
                                   rd_array_data_q[51:60];

   // internal bypass latch input for rpn
   // using cam_cmp_data(75:78) cmpmask bits for mux selects
   assign rpn_np2_d[22:33] = (comp_addr_np1_q[22:33] & {12{bypass_mux_enab_np1}}) |
                             (array_cmp_data_np1[0:11] & {12{~(bypass_mux_enab_np1)}});   // real page from cam-array

   //CAM_PgSize_1GB
   assign rpn_np2_d[34:39] = (comp_addr_np1_q[34:39] & {6{(~(cam_cmp_data_np1[75])) | bypass_mux_enab_np1}}) |
                             (array_cmp_data_np1[12:17] & {6{cam_cmp_data_np1[75] & (~bypass_mux_enab_np1)}});

   //CAM_PgSize_1GB or CAM_PgSize_16MB
   assign rpn_np2_d[40:43] = (comp_addr_np1_q[40:43] & {4{(~(cam_cmp_data_np1[76])) | bypass_mux_enab_np1}}) |
                             (array_cmp_data_np1[18:21] & {4{cam_cmp_data_np1[76] & (~bypass_mux_enab_np1)}});

   //CAM_PgSize_1GB or CAM_PgSize_16MB or CAM_PgSize_1MB
   assign rpn_np2_d[44:47] = (comp_addr_np1_q[44:47] & {4{(~(cam_cmp_data_np1[77])) | bypass_mux_enab_np1}}) |
                             (array_cmp_data_np1[22:25] & {4{cam_cmp_data_np1[77] & (~bypass_mux_enab_np1)}});

   //CAM_PgSize_Larger_than_4K
   assign rpn_np2_d[48:51] = (comp_addr_np1_q[48:51] & {4{(~(cam_cmp_data_np1[78])) | bypass_mux_enab_np1}}) |
                             (array_cmp_data_np1[26:29] & {4{cam_cmp_data_np1[78] & (~bypass_mux_enab_np1)}});

   // internal bypass latch input for attributes
   assign attr_np2_d[0:20] = (bypass_attr_np1[0:20] & {21{bypass_mux_enab_np1}}) |
                             (array_cmp_data_np1[30:50] & {21{~bypass_mux_enab_np1}});

   // new port output assignments
   assign rpn_np2[22:51] = rpn_np2_q[22:51];
   assign attr_np2[0:20] = attr_np2_q[0:20];

   //---------------------------------------------------------------------
   // matchline component instantiations
   //---------------------------------------------------------------------

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb0(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry0_size_q),
      .entry_cmpmask(entry0_cmpmask_q[0:3]),
      .entry_xbit(entry0_xbit_q),
      .entry_xbitmask(entry0_cmpmask_q[4:7]),
      .entry_epn(entry0_epn_q),
      .comp_class(comp_class),
      .entry_class(entry0_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry0_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry0_hv_q),
      .entry_ds(entry0_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry0_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry0_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry0_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[0])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb1(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry1_size_q),
      .entry_cmpmask(entry1_cmpmask_q[0:3]),
      .entry_xbit(entry1_xbit_q),
      .entry_xbitmask(entry1_cmpmask_q[4:7]),
      .entry_epn(entry1_epn_q),
      .comp_class(comp_class),
      .entry_class(entry1_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry1_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry1_hv_q),
      .entry_ds(entry1_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry1_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry1_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry1_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[1])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb2(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry2_size_q),
      .entry_cmpmask(entry2_cmpmask_q[0:3]),
      .entry_xbit(entry2_xbit_q),
      .entry_xbitmask(entry2_cmpmask_q[4:7]),
      .entry_epn(entry2_epn_q),
      .comp_class(comp_class),
      .entry_class(entry2_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry2_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry2_hv_q),
      .entry_ds(entry2_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry2_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry2_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry2_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[2])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb3(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry3_size_q),
      .entry_cmpmask(entry3_cmpmask_q[0:3]),
      .entry_xbit(entry3_xbit_q),
      .entry_xbitmask(entry3_cmpmask_q[4:7]),
      .entry_epn(entry3_epn_q),
      .comp_class(comp_class),
      .entry_class(entry3_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry3_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry3_hv_q),
      .entry_ds(entry3_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry3_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry3_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry3_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[3])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb4(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry4_size_q),
      .entry_cmpmask(entry4_cmpmask_q[0:3]),
      .entry_xbit(entry4_xbit_q),
      .entry_xbitmask(entry4_cmpmask_q[4:7]),
      .entry_epn(entry4_epn_q),
      .comp_class(comp_class),
      .entry_class(entry4_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry4_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry4_hv_q),
      .entry_ds(entry4_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry4_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry4_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry4_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[4])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb5(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry5_size_q),
      .entry_cmpmask(entry5_cmpmask_q[0:3]),
      .entry_xbit(entry5_xbit_q),
      .entry_xbitmask(entry5_cmpmask_q[4:7]),
      .entry_epn(entry5_epn_q),
      .comp_class(comp_class),
      .entry_class(entry5_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry5_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry5_hv_q),
      .entry_ds(entry5_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry5_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry5_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry5_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[5])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb6(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry6_size_q),
      .entry_cmpmask(entry6_cmpmask_q[0:3]),
      .entry_xbit(entry6_xbit_q),
      .entry_xbitmask(entry6_cmpmask_q[4:7]),
      .entry_epn(entry6_epn_q),
      .comp_class(comp_class),
      .entry_class(entry6_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry6_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry6_hv_q),
      .entry_ds(entry6_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry6_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry6_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry6_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[6])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb7(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry7_size_q),
      .entry_cmpmask(entry7_cmpmask_q[0:3]),
      .entry_xbit(entry7_xbit_q),
      .entry_xbitmask(entry7_cmpmask_q[4:7]),
      .entry_epn(entry7_epn_q),
      .comp_class(comp_class),
      .entry_class(entry7_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry7_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry7_hv_q),
      .entry_ds(entry7_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry7_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry7_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry7_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[7])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb8(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry8_size_q),
      .entry_cmpmask(entry8_cmpmask_q[0:3]),
      .entry_xbit(entry8_xbit_q),
      .entry_xbitmask(entry8_cmpmask_q[4:7]),
      .entry_epn(entry8_epn_q),
      .comp_class(comp_class),
      .entry_class(entry8_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry8_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry8_hv_q),
      .entry_ds(entry8_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry8_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry8_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry8_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[8])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb9(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry9_size_q),
      .entry_cmpmask(entry9_cmpmask_q[0:3]),
      .entry_xbit(entry9_xbit_q),
      .entry_xbitmask(entry9_cmpmask_q[4:7]),
      .entry_epn(entry9_epn_q),
      .comp_class(comp_class),
      .entry_class(entry9_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry9_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry9_hv_q),
      .entry_ds(entry9_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry9_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry9_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry9_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[9])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb10(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry10_size_q),
      .entry_cmpmask(entry10_cmpmask_q[0:3]),
      .entry_xbit(entry10_xbit_q),
      .entry_xbitmask(entry10_cmpmask_q[4:7]),
      .entry_epn(entry10_epn_q),
      .comp_class(comp_class),
      .entry_class(entry10_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry10_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry10_hv_q),
      .entry_ds(entry10_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry10_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry10_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry10_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[10])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb11(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry11_size_q),
      .entry_cmpmask(entry11_cmpmask_q[0:3]),
      .entry_xbit(entry11_xbit_q),
      .entry_xbitmask(entry11_cmpmask_q[4:7]),
      .entry_epn(entry11_epn_q),
      .comp_class(comp_class),
      .entry_class(entry11_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry11_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry11_hv_q),
      .entry_ds(entry11_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry11_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry11_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry11_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[11])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb12(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry12_size_q),
      .entry_cmpmask(entry12_cmpmask_q[0:3]),
      .entry_xbit(entry12_xbit_q),
      .entry_xbitmask(entry12_cmpmask_q[4:7]),
      .entry_epn(entry12_epn_q),
      .comp_class(comp_class),
      .entry_class(entry12_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry12_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry12_hv_q),
      .entry_ds(entry12_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry12_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry12_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry12_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[12])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb13(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry13_size_q),
      .entry_cmpmask(entry13_cmpmask_q[0:3]),
      .entry_xbit(entry13_xbit_q),
      .entry_xbitmask(entry13_cmpmask_q[4:7]),
      .entry_epn(entry13_epn_q),
      .comp_class(comp_class),
      .entry_class(entry13_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry13_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry13_hv_q),
      .entry_ds(entry13_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry13_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry13_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry13_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[13])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb14(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry14_size_q),
      .entry_cmpmask(entry14_cmpmask_q[0:3]),
      .entry_xbit(entry14_xbit_q),
      .entry_xbitmask(entry14_cmpmask_q[4:7]),
      .entry_epn(entry14_epn_q),
      .comp_class(comp_class),
      .entry_class(entry14_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry14_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry14_hv_q),
      .entry_ds(entry14_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry14_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry14_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry14_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[14])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb15(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry15_size_q),
      .entry_cmpmask(entry15_cmpmask_q[0:3]),
      .entry_xbit(entry15_xbit_q),
      .entry_xbitmask(entry15_cmpmask_q[4:7]),
      .entry_epn(entry15_epn_q),
      .comp_class(comp_class),
      .entry_class(entry15_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry15_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry15_hv_q),
      .entry_ds(entry15_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry15_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry15_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry15_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[15])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb16(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry16_size_q),
      .entry_cmpmask(entry16_cmpmask_q[0:3]),
      .entry_xbit(entry16_xbit_q),
      .entry_xbitmask(entry16_cmpmask_q[4:7]),
      .entry_epn(entry16_epn_q),
      .comp_class(comp_class),
      .entry_class(entry16_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry16_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry16_hv_q),
      .entry_ds(entry16_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry16_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry16_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry16_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[16])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb17(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry17_size_q),
      .entry_cmpmask(entry17_cmpmask_q[0:3]),
      .entry_xbit(entry17_xbit_q),
      .entry_xbitmask(entry17_cmpmask_q[4:7]),
      .entry_epn(entry17_epn_q),
      .comp_class(comp_class),
      .entry_class(entry17_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry17_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry17_hv_q),
      .entry_ds(entry17_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry17_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry17_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry17_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[17])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb18(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry18_size_q),
      .entry_cmpmask(entry18_cmpmask_q[0:3]),
      .entry_xbit(entry18_xbit_q),
      .entry_xbitmask(entry18_cmpmask_q[4:7]),
      .entry_epn(entry18_epn_q),
      .comp_class(comp_class),
      .entry_class(entry18_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry18_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry18_hv_q),
      .entry_ds(entry18_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry18_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry18_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry18_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[18])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb19(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry19_size_q),
      .entry_cmpmask(entry19_cmpmask_q[0:3]),
      .entry_xbit(entry19_xbit_q),
      .entry_xbitmask(entry19_cmpmask_q[4:7]),
      .entry_epn(entry19_epn_q),
      .comp_class(comp_class),
      .entry_class(entry19_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry19_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry19_hv_q),
      .entry_ds(entry19_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry19_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry19_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry19_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[19])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb20(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry20_size_q),
      .entry_cmpmask(entry20_cmpmask_q[0:3]),
      .entry_xbit(entry20_xbit_q),
      .entry_xbitmask(entry20_cmpmask_q[4:7]),
      .entry_epn(entry20_epn_q),
      .comp_class(comp_class),
      .entry_class(entry20_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry20_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry20_hv_q),
      .entry_ds(entry20_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry20_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry20_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry20_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[20])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb21(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry21_size_q),
      .entry_cmpmask(entry21_cmpmask_q[0:3]),
      .entry_xbit(entry21_xbit_q),
      .entry_xbitmask(entry21_cmpmask_q[4:7]),
      .entry_epn(entry21_epn_q),
      .comp_class(comp_class),
      .entry_class(entry21_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry21_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry21_hv_q),
      .entry_ds(entry21_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry21_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry21_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry21_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[21])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb22(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry22_size_q),
      .entry_cmpmask(entry22_cmpmask_q[0:3]),
      .entry_xbit(entry22_xbit_q),
      .entry_xbitmask(entry22_cmpmask_q[4:7]),
      .entry_epn(entry22_epn_q),
      .comp_class(comp_class),
      .entry_class(entry22_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry22_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry22_hv_q),
      .entry_ds(entry22_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry22_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry22_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry22_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[22])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb23(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry23_size_q),
      .entry_cmpmask(entry23_cmpmask_q[0:3]),
      .entry_xbit(entry23_xbit_q),
      .entry_xbitmask(entry23_cmpmask_q[4:7]),
      .entry_epn(entry23_epn_q),
      .comp_class(comp_class),
      .entry_class(entry23_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry23_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry23_hv_q),
      .entry_ds(entry23_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry23_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry23_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry23_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[23])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb24(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry24_size_q),
      .entry_cmpmask(entry24_cmpmask_q[0:3]),
      .entry_xbit(entry24_xbit_q),
      .entry_xbitmask(entry24_cmpmask_q[4:7]),
      .entry_epn(entry24_epn_q),
      .comp_class(comp_class),
      .entry_class(entry24_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry24_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry24_hv_q),
      .entry_ds(entry24_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry24_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry24_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry24_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[24])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb25(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry25_size_q),
      .entry_cmpmask(entry25_cmpmask_q[0:3]),
      .entry_xbit(entry25_xbit_q),
      .entry_xbitmask(entry25_cmpmask_q[4:7]),
      .entry_epn(entry25_epn_q),
      .comp_class(comp_class),
      .entry_class(entry25_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry25_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry25_hv_q),
      .entry_ds(entry25_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry25_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry25_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry25_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[25])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb26(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry26_size_q),
      .entry_cmpmask(entry26_cmpmask_q[0:3]),
      .entry_xbit(entry26_xbit_q),
      .entry_xbitmask(entry26_cmpmask_q[4:7]),
      .entry_epn(entry26_epn_q),
      .comp_class(comp_class),
      .entry_class(entry26_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry26_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry26_hv_q),
      .entry_ds(entry26_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry26_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry26_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry26_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[26])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb27(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry27_size_q),
      .entry_cmpmask(entry27_cmpmask_q[0:3]),
      .entry_xbit(entry27_xbit_q),
      .entry_xbitmask(entry27_cmpmask_q[4:7]),
      .entry_epn(entry27_epn_q),
      .comp_class(comp_class),
      .entry_class(entry27_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry27_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry27_hv_q),
      .entry_ds(entry27_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry27_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry27_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry27_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[27])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb28(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry28_size_q),
      .entry_cmpmask(entry28_cmpmask_q[0:3]),
      .entry_xbit(entry28_xbit_q),
      .entry_xbitmask(entry28_cmpmask_q[4:7]),
      .entry_epn(entry28_epn_q),
      .comp_class(comp_class),
      .entry_class(entry28_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry28_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry28_hv_q),
      .entry_ds(entry28_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry28_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry28_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry28_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[28])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb29(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry29_size_q),
      .entry_cmpmask(entry29_cmpmask_q[0:3]),
      .entry_xbit(entry29_xbit_q),
      .entry_xbitmask(entry29_cmpmask_q[4:7]),
      .entry_epn(entry29_epn_q),
      .comp_class(comp_class),
      .entry_class(entry29_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry29_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry29_hv_q),
      .entry_ds(entry29_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry29_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry29_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry29_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[29])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb30(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry30_size_q),
      .entry_cmpmask(entry30_cmpmask_q[0:3]),
      .entry_xbit(entry30_xbit_q),
      .entry_xbitmask(entry30_cmpmask_q[4:7]),
      .entry_epn(entry30_epn_q),
      .comp_class(comp_class),
      .entry_class(entry30_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry30_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry30_hv_q),
      .entry_ds(entry30_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry30_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry30_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry30_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[30])
   );

   tri_cam_32x143_1r1w1c_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1), .CMPMASK_WIDTH(4)) matchline_comb31(
      .addr_in(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .entry_size(entry31_size_q),
      .entry_cmpmask(entry31_cmpmask_q[0:3]),
      .entry_xbit(entry31_xbit_q),
      .entry_xbitmask(entry31_cmpmask_q[4:7]),
      .entry_epn(entry31_epn_q),
      .comp_class(comp_class),
      .entry_class(entry31_class_q),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .entry_extclass(entry31_extclass_q),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .entry_hv(entry31_hv_q),
      .entry_ds(entry31_ds_q),
      .state_enable(state_enable),
      .entry_thdid(entry31_thdid_q),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .entry_pid(entry31_pid_q),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .entry_v(entry31_v_q),
      .comp_invalidate(comp_invalidate),

      .match(match_vec[31])
   );


   //---------------------------------------------------------------------
   // BRAM signal assignments
   //---------------------------------------------------------------------
   assign bram0_wea = wr_array_val[0] & gate_fq;
   assign bram1_wea = wr_array_val[1] & gate_fq;
   assign bram2_wea = wr_array_val[1] & gate_fq;

   assign bram0_addra[9 - NUM_ENTRY_LOG2:8]   = rw_entry[0:NUM_ENTRY_LOG2 - 1];
   assign bram1_addra[11 - NUM_ENTRY_LOG2:10] = rw_entry[0:NUM_ENTRY_LOG2 - 1];
   assign bram2_addra[10 - NUM_ENTRY_LOG2:9]  = rw_entry[0:NUM_ENTRY_LOG2 - 1];

   assign bram0_addrb[9 - NUM_ENTRY_LOG2:8]   = cam_hit_entry_q;
   assign bram1_addrb[11 - NUM_ENTRY_LOG2:10] = cam_hit_entry_q;
   assign bram2_addrb[10 - NUM_ENTRY_LOG2:9]  = cam_hit_entry_q;

   // Unused Address Bits
   assign bram0_addra[0:8 - NUM_ENTRY_LOG2] = {9-NUM_ENTRY_LOG2{1'b0}};
   assign bram0_addrb[0:8 - NUM_ENTRY_LOG2] = {9-NUM_ENTRY_LOG2{1'b0}};
   assign bram1_addra[0:10 - NUM_ENTRY_LOG2] = {11-NUM_ENTRY_LOG2{1'b0}};
   assign bram1_addrb[0:10 - NUM_ENTRY_LOG2] = {11-NUM_ENTRY_LOG2{1'b0}};
   assign bram2_addra[0:9 - NUM_ENTRY_LOG2] = {10-NUM_ENTRY_LOG2{1'b0}};
   assign bram2_addrb[0:9 - NUM_ENTRY_LOG2] = {10-NUM_ENTRY_LOG2{1'b0}};

   // This ram houses the RPN(20:51) bits, wr_array_data_bram(0:31)
   //   uses wr_array_val(0), parity is wr_array_data_bram(66:69)
   RAMB16_S36_S36
       #(.SIM_COLLISION_CHECK("NONE"))   // all, none, warning_only, generate_x_only
   bram0(
      .CLKA(clk2x),
      .CLKB(clk2x),
      .SSRA(sreset_q),
      .SSRB(sreset_q),
      .ADDRA(bram0_addra),
      .ADDRB(bram0_addrb),
      .DIA(wr_array_data_bram[0:31]),
      .DIB(32'b0),
      .DOA(rd_array_data_d_std[0:31]),
      .DOB(array_cmp_data_bram_std[0:31]),
      .DOPA(rd_array_data_d_std[66:69]),
      .DOPB(array_cmp_data_bramp_std[66:69]),
      .DIPA(wr_array_data_bram[66:69]),
      .DIPB(4'b0),
      .ENA(1'b1),
      .ENB(1'b1),
      .WEA(bram0_wea),
      .WEB(1'b0)
   );

   // This ram houses the RPN(18:19),R,C,4xResv bits, wr_array_data_bram(32:39)
   //   uses wr_array_val(1), parity is wr_array_data_bram(70)
   RAMB16_S9_S9
       #(.SIM_COLLISION_CHECK("NONE"))   // all, none, warning_only, generate_x_only
   bram1(
      .CLKA(clk2x),
      .CLKB(clk2x),
      .SSRA(sreset_q),
      .SSRB(sreset_q),
      .ADDRA(bram1_addra),
      .ADDRB(bram1_addrb),
      .DIA(wr_array_data_bram[32:39]),
      .DIB(8'b0),
      .DOA(rd_array_data_d_std[32:39]),
      .DOB(array_cmp_data_bram_std[32:39]),
      .DOPA(rd_array_data_d_std[70:70]),
      .DOPB(array_cmp_data_bramp_std[70:70]),
      .DIPA(wr_array_data_bram[70:70]),
      .DIPB(1'b0),
      .ENA(1'b1),
      .ENB(1'b1),
      .WEA(bram1_wea),
      .WEB(1'b0)
   );

   // This ram houses the 1xResv,U0-U3,WIMGE,UX,UW,UR,SX,SW,SR bits, wr_array_data_bram(40:55)
   //   uses wr_array_val(2), parity is wr_array_data_bram(71:72)
   RAMB16_S18_S18
       #(.SIM_COLLISION_CHECK("NONE"))   // all, none, warning_only, generate_x_only
   bram2(
      .CLKA(clk2x),
      .CLKB(clk2x),
      .SSRA(sreset_q),
      .SSRB(sreset_q),
      .ADDRA(bram2_addra),
      .ADDRB(bram2_addrb),
      .DIA(wr_array_data_bram[40:55]),
      .DIB(16'b0),
      .DOA(rd_array_data_d_std[40:55]),
      .DOB(array_cmp_data_bram_std[40:55]),
      .DOPA(rd_array_data_d_std[71:72]),
      .DOPB(array_cmp_data_bramp_std[71:72]),
      .DIPA(wr_array_data_bram[71:72]),
      .DIPB(2'b0),
      .ENA(1'b1),
      .ENB(1'b1),
      .WEA(bram2_wea),
      .WEB(1'b0)
   );

   // array write data swizzle -> convert 68-bit data to 73-bit bram data
   // 32x143 version, 42b RA
   // wr_array_data
   //  0:29  - RPN
   //  30:31  - R,C
   //  32:35  - ResvAttr
   //  36:39  - U0-U3
   //  40:44  - WIMGE
   //  45:47  - UX,UW,UR
   //  48:50  - SX,SW,SR
   //  51:60  - CAM parity
   //  61:67  - Array parity
   //
   // RTX layout in A2_AvpEratHelper.C
   //  ram0(0:31):  00  & RPN(0:29)
   //  ram1(0:7) :  00  & R,C,ResvAttr(0:3)
   //  ram2(0:15): '0' & U(0:3),WIMGE,UX,UW,UR,SX,SW,SR
   assign wr_array_data_bram[0:72] = {2'b00, wr_array_data[0:29], 2'b00, wr_array_data[30:35], 1'b0, wr_array_data[36:50], wr_array_data[51:60], wr_array_data[61:67]};

   assign rd_array_data_d_std[56:65] = 10'b0;  // tie off unused bits

   assign rd_array_data_d[0:29]  = rd_array_data_d_std[2:31];
   assign rd_array_data_d[30:35] = rd_array_data_d_std[34:39];
   assign rd_array_data_d[36:50] = rd_array_data_d_std[41:55];
   assign rd_array_data_d[61:67] = rd_array_data_d_std[66:72];
   assign array_cmp_data_bram = array_cmp_data_bram_std;
   assign array_cmp_data_bramp = array_cmp_data_bramp_std;

   //---------------------------------------------------------------------
   // entity output assignments
   //---------------------------------------------------------------------
   assign rd_array_data = rd_array_data_q;
   assign cam_cmp_data = cam_cmp_data_q;
   assign rd_cam_data = rd_cam_data_q;

   assign entry_valid[0] = entry0_v_q;
   assign entry_valid[1] = entry1_v_q;
   assign entry_valid[2] = entry2_v_q;
   assign entry_valid[3] = entry3_v_q;
   assign entry_valid[4] = entry4_v_q;
   assign entry_valid[5] = entry5_v_q;
   assign entry_valid[6] = entry6_v_q;
   assign entry_valid[7] = entry7_v_q;
   assign entry_valid[8] = entry8_v_q;
   assign entry_valid[9] = entry9_v_q;
   assign entry_valid[10] = entry10_v_q;
   assign entry_valid[11] = entry11_v_q;
   assign entry_valid[12] = entry12_v_q;
   assign entry_valid[13] = entry13_v_q;
   assign entry_valid[14] = entry14_v_q;
   assign entry_valid[15] = entry15_v_q;
   assign entry_valid[16] = entry16_v_q;
   assign entry_valid[17] = entry17_v_q;
   assign entry_valid[18] = entry18_v_q;
   assign entry_valid[19] = entry19_v_q;
   assign entry_valid[20] = entry20_v_q;
   assign entry_valid[21] = entry21_v_q;
   assign entry_valid[22] = entry22_v_q;
   assign entry_valid[23] = entry23_v_q;
   assign entry_valid[24] = entry24_v_q;
   assign entry_valid[25] = entry25_v_q;
   assign entry_valid[26] = entry26_v_q;
   assign entry_valid[27] = entry27_v_q;
   assign entry_valid[28] = entry28_v_q;
   assign entry_valid[29] = entry29_v_q;
   assign entry_valid[30] = entry30_v_q;
   assign entry_valid[31] = entry31_v_q;

   assign entry_match = entry_match_q;

   assign cam_hit_entry = cam_hit_entry_q;
   assign cam_hit = cam_hit_q;

   assign func_scan_out = func_scan_in;
   assign regfile_scan_out = regfile_scan_in;
   assign time_scan_out = time_scan_in;

   assign unused = |{gnd, vdd, vcs, nclk, tc_ccflush_dc, tc_scan_dis_dc_b, tc_scan_diag_dc,
                     tc_lbist_en_dc, an_ac_atpg_en_dc, lcb_d_mode_dc, lcb_clkoff_dc_b,
                     lcb_act_dis_dc, lcb_mpw1_dc_b, lcb_mpw2_dc_b, lcb_delay_lclkr_dc,
                     pc_sg_2, pc_func_slp_sl_thold_2, pc_func_slp_nsl_thold_2, pc_regf_slp_sl_thold_2,
                     pc_time_sl_thold_2, pc_fce_2, array_cmp_data_bram[0:1], array_cmp_data_bram[32:33],
                     array_cmp_data_bram[40], wr_array_data_bram[56:65],
                     cam_cmp_data_np1[0:74], cam_cmp_data_np1[79:CAM_DATA_WIDTH-1],
                     rd_array_data_d_std[0:1], rd_array_data_d_std[32:33],
                     rd_array_data_d_std[40], rd_array_data_d_std[56:65], rd_val_late, wr_val_early};
endmodule
