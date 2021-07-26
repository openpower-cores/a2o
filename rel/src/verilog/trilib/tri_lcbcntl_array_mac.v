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
// *! FILENAME    : tri_lcbcntl_array_mac.v
// *! DESCRIPTION : Used to generate control signals for LCBs
// *!****************************************************************

`include "tri_a2o.vh"

module tri_lcbcntl_array_mac(
   vdd,
   gnd,
   sg,
   nclk,
   scan_in,
   scan_diag_dc,
   thold,
   clkoff_dc_b,
   delay_lclkr_dc,
   act_dis_dc,
   d_mode_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   scan_out
);
   inout        vdd;
   inout        gnd;
   input        sg;
   input [0:`NCLK_WIDTH-1] nclk;
   input        scan_in;
   input        scan_diag_dc;
   input        thold;
   output       clkoff_dc_b;
   output [0:4] delay_lclkr_dc;
   output       act_dis_dc;
   output       d_mode_dc;
   output [0:4] mpw1_dc_b;
   output       mpw2_dc_b;
   output       scan_out;

   // tri_lcbcntl_array_mac

    (* analysis_not_referenced="true" *)
   wire         unused;

   assign clkoff_dc_b = 1'b1;
   assign delay_lclkr_dc = 5'b00000;
   assign act_dis_dc = 1'b0;
   assign d_mode_dc = 1'b0;
   assign mpw1_dc_b = 5'b11111;
   assign mpw2_dc_b = 1'b1;
   assign scan_out = 1'b0;

   assign unused = vdd | gnd | sg | (|nclk) | scan_in | scan_diag_dc | thold;
endmodule
