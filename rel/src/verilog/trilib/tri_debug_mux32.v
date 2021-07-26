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

//********************************************************************
//*
//* TITLE: Debug Mux Component (32:1 Debug Groups; 4:1 Trigger Groups)
//*
//* NAME: tri_debug_mux32.vhdl
//*
//********************************************************************


module tri_debug_mux32(
//   vd,
//   gd,
   select_bits,
   dbg_group0,
   dbg_group1,
   dbg_group2,
   dbg_group3,
   dbg_group4,
   dbg_group5,
   dbg_group6,
   dbg_group7,
   dbg_group8,
   dbg_group9,
   dbg_group10,
   dbg_group11,
   dbg_group12,
   dbg_group13,
   dbg_group14,
   dbg_group15,
   dbg_group16,
   dbg_group17,
   dbg_group18,
   dbg_group19,
   dbg_group20,
   dbg_group21,
   dbg_group22,
   dbg_group23,
   dbg_group24,
   dbg_group25,
   dbg_group26,
   dbg_group27,
   dbg_group28,
   dbg_group29,
   dbg_group30,
   dbg_group31,
   trace_data_in,
   trace_data_out,

   // Instruction Trace (HTM) Controls
   coretrace_ctrls_in,
   coretrace_ctrls_out
);

// Include model build parameters
   parameter              DBG_WIDTH = 32;	// A2o=32; A2i=88

//=====================================================================
// Port Definitions
//=====================================================================

   input [0:10]           select_bits;
   input [0:DBG_WIDTH-1]  dbg_group0;
   input [0:DBG_WIDTH-1]  dbg_group1;
   input [0:DBG_WIDTH-1]  dbg_group2;
   input [0:DBG_WIDTH-1]  dbg_group3;
   input [0:DBG_WIDTH-1]  dbg_group4;
   input [0:DBG_WIDTH-1]  dbg_group5;
   input [0:DBG_WIDTH-1]  dbg_group6;
   input [0:DBG_WIDTH-1]  dbg_group7;
   input [0:DBG_WIDTH-1]  dbg_group8;
   input [0:DBG_WIDTH-1]  dbg_group9;
   input [0:DBG_WIDTH-1]  dbg_group10;
   input [0:DBG_WIDTH-1]  dbg_group11;
   input [0:DBG_WIDTH-1]  dbg_group12;
   input [0:DBG_WIDTH-1]  dbg_group13;
   input [0:DBG_WIDTH-1]  dbg_group14;
   input [0:DBG_WIDTH-1]  dbg_group15;
   input [0:DBG_WIDTH-1]  dbg_group16;
   input [0:DBG_WIDTH-1]  dbg_group17;
   input [0:DBG_WIDTH-1]  dbg_group18;
   input [0:DBG_WIDTH-1]  dbg_group19;
   input [0:DBG_WIDTH-1]  dbg_group20;
   input [0:DBG_WIDTH-1]  dbg_group21;
   input [0:DBG_WIDTH-1]  dbg_group22;
   input [0:DBG_WIDTH-1]  dbg_group23;
   input [0:DBG_WIDTH-1]  dbg_group24;
   input [0:DBG_WIDTH-1]  dbg_group25;
   input [0:DBG_WIDTH-1]  dbg_group26;
   input [0:DBG_WIDTH-1]  dbg_group27;
   input [0:DBG_WIDTH-1]  dbg_group28;
   input [0:DBG_WIDTH-1]  dbg_group29;
   input [0:DBG_WIDTH-1]  dbg_group30;
   input [0:DBG_WIDTH-1]  dbg_group31;
   input [0:DBG_WIDTH-1]  trace_data_in;
   output [0:DBG_WIDTH-1] trace_data_out;

// Instruction Trace (HTM) Control Signals:
//  0    - ac_an_coretrace_first_valid
//  1    - ac_an_coretrace_valid
//  2:3  - ac_an_coretrace_type[0:1]
   input  [0:3]           coretrace_ctrls_in;
   output [0:3]           coretrace_ctrls_out;

//=====================================================================
// Signal Declarations / Misc
//=====================================================================
   parameter              DBG_1FOURTH = DBG_WIDTH/4;
   parameter              DBG_2FOURTH = DBG_WIDTH/2;
   parameter              DBG_3FOURTH = 3 * DBG_WIDTH/4;

   wire [0:DBG_WIDTH-1]   debug_grp_selected;
   wire [0:DBG_WIDTH-1]   debug_grp_rotated;

// Instruction Trace controls are passed-through:
   assign coretrace_ctrls_out =  coretrace_ctrls_in ;

//=====================================================================
// Mux Function
//=====================================================================
   // Debug Mux
   assign debug_grp_selected = (select_bits[0:4] == 5'b00000) ? dbg_group0 :
                               (select_bits[0:4] == 5'b00001) ? dbg_group1 :
                               (select_bits[0:4] == 5'b00010) ? dbg_group2 :
                               (select_bits[0:4] == 5'b00011) ? dbg_group3 :
                               (select_bits[0:4] == 5'b00100) ? dbg_group4 :
                               (select_bits[0:4] == 5'b00101) ? dbg_group5 :
                               (select_bits[0:4] == 5'b00110) ? dbg_group6 :
                               (select_bits[0:4] == 5'b00111) ? dbg_group7 :
                               (select_bits[0:4] == 5'b01000) ? dbg_group8 :
                               (select_bits[0:4] == 5'b01001) ? dbg_group9 :
                               (select_bits[0:4] == 5'b01010) ? dbg_group10 :
                               (select_bits[0:4] == 5'b01011) ? dbg_group11 :
                               (select_bits[0:4] == 5'b01100) ? dbg_group12 :
                               (select_bits[0:4] == 5'b01101) ? dbg_group13 :
                               (select_bits[0:4] == 5'b01110) ? dbg_group14 :
                               (select_bits[0:4] == 5'b01111) ? dbg_group15 :
                               (select_bits[0:4] == 5'b10000) ? dbg_group16 :
                               (select_bits[0:4] == 5'b10001) ? dbg_group17 :
                               (select_bits[0:4] == 5'b10010) ? dbg_group18 :
                               (select_bits[0:4] == 5'b10011) ? dbg_group19 :
                               (select_bits[0:4] == 5'b10100) ? dbg_group20 :
                               (select_bits[0:4] == 5'b10101) ? dbg_group21 :
                               (select_bits[0:4] == 5'b10110) ? dbg_group22 :
                               (select_bits[0:4] == 5'b10111) ? dbg_group23 :
                               (select_bits[0:4] == 5'b11000) ? dbg_group24 :
                               (select_bits[0:4] == 5'b11001) ? dbg_group25 :
                               (select_bits[0:4] == 5'b11010) ? dbg_group26 :
                               (select_bits[0:4] == 5'b11011) ? dbg_group27 :
                               (select_bits[0:4] == 5'b11100) ? dbg_group28 :
                               (select_bits[0:4] == 5'b11101) ? dbg_group29 :
                               (select_bits[0:4] == 5'b11110) ? dbg_group30 :
                               dbg_group31;

   assign debug_grp_rotated  = (select_bits[5:6] == 2'b11) ? {debug_grp_selected[DBG_1FOURTH:DBG_WIDTH - 1], debug_grp_selected[0:DBG_1FOURTH - 1]} :
                               (select_bits[5:6] == 2'b10) ? {debug_grp_selected[DBG_2FOURTH:DBG_WIDTH - 1], debug_grp_selected[0:DBG_2FOURTH - 1]} :
                               (select_bits[5:6] == 2'b01) ? {debug_grp_selected[DBG_3FOURTH:DBG_WIDTH - 1], debug_grp_selected[0:DBG_3FOURTH - 1]} :
                               debug_grp_selected[0:DBG_WIDTH - 1];


   assign trace_data_out[0:DBG_1FOURTH - 1]           = (select_bits[7] == 1'b0) ? trace_data_in[0:DBG_1FOURTH - 1] :
                                                        debug_grp_rotated[0:DBG_1FOURTH - 1];

   assign trace_data_out[DBG_1FOURTH:DBG_2FOURTH - 1] = (select_bits[8] == 1'b0) ? trace_data_in[DBG_1FOURTH:DBG_2FOURTH - 1] :
                                                        debug_grp_rotated[DBG_1FOURTH:DBG_2FOURTH - 1];

   assign trace_data_out[DBG_2FOURTH:DBG_3FOURTH - 1] = (select_bits[9] == 1'b0) ? trace_data_in[DBG_2FOURTH:DBG_3FOURTH - 1] :
                                                        debug_grp_rotated[DBG_2FOURTH:DBG_3FOURTH - 1];

   assign trace_data_out[DBG_3FOURTH:DBG_WIDTH - 1]   = (select_bits[10] == 1'b0) ? trace_data_in[DBG_3FOURTH:DBG_WIDTH - 1] :
                                                        debug_grp_rotated[DBG_3FOURTH:DBG_WIDTH - 1];


endmodule

