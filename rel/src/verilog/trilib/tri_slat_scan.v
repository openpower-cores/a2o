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
// *! FILENAME    : tri_slat_scan.v
// *! DESCRIPTION : n-bit scan-only latch without scan_connect
// *!
// *!****************************************************************

`include "tri_a2o.vh"

module tri_slat_scan(
   vd,
   gd,
   dclk,
   lclk,
   scan_in,
   scan_out,
   q,
   q_b
);
   parameter                      WIDTH = 1;
   parameter                      OFFSET = 0;
   parameter                      INIT = 0;
   parameter                      SYNTHCLONEDLATCH = "";
   parameter                      BTR = "c_slat_scan";
   parameter                      RESET_INVERTS_SCAN = 1'b1;

   inout                          vd;
   inout                          gd;
   input                          dclk;
   input [0:`NCLK_WIDTH-1]        lclk;
   input [OFFSET:OFFSET+WIDTH-1]  scan_in;
   output [OFFSET:OFFSET+WIDTH-1] scan_out;
   output [OFFSET:OFFSET+WIDTH-1] q;
   output [OFFSET:OFFSET+WIDTH-1] q_b;

   // tri_slat_scan

   parameter [0:WIDTH-1]          ZEROS = {WIDTH{1'b0}};
   parameter [0:WIDTH-1]          initv = INIT;

   (* analysis_not_referenced="true" *)
   wire                           unused;

   assign unused = | {vd, gd, dclk, lclk, scan_in};

   assign scan_out = ZEROS;
   assign q = initv;
   assign q_b = (~initv);
endmodule
