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
//* TITLE: Debug Mux Component (8:1 Debug Groups; 4:1 Trigger Groups)
//*
//* NAME: tri_debug_mux8.vhdl
//*
//********************************************************************

module tri_debug_mux8(
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

// Don't reference unused inputs:
(* analysis_not_referenced="true" *)
   wire                   unused;
   assign unused = (|select_bits[3:4]) ;

// Instruction Trace controls are passed-through:
   assign coretrace_ctrls_out =  coretrace_ctrls_in ;

//=====================================================================
// Mux Function
//=====================================================================
   // Debug Mux

   assign debug_grp_selected = (select_bits[0:2] == 3'b000) ? dbg_group0 :
                               (select_bits[0:2] == 3'b001) ? dbg_group1 :
                               (select_bits[0:2] == 3'b010) ? dbg_group2 :
                               (select_bits[0:2] == 3'b011) ? dbg_group3 :
                               (select_bits[0:2] == 3'b100) ? dbg_group4 :
                               (select_bits[0:2] == 3'b101) ? dbg_group5 :
                               (select_bits[0:2] == 3'b110) ? dbg_group6 :
                               dbg_group7;

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
