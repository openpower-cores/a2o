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

//  Description:  Service Error Rate Latch Instance
//       Constant feedback to L1, should improve the error rate of the latch
//
//*****************************************************************************

`include "tri_a2o.vh"

module tri_ser_rlmreg_p(
   vd,
   gd,
   nclk,
   act,
   force_t,
   thold_b,
   d_mode,
   sg,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   scin,
   din,
   scout,
   dout
);
   parameter                      WIDTH = 1;
   parameter                      OFFSET = 0;
   parameter                      INIT = 0;
   parameter                      IBUF = 1'b0;
   parameter                      DUALSCAN = "";
   parameter                      NEEDS_SRESET = 1;
   parameter                      DOMAIN_CROSSING = 0;

   inout                          vd;
   inout                          gd;
   input [0:`NCLK_WIDTH-1]        nclk;
   input                          act;
   input                          force_t;
   input                          thold_b;
   input                          d_mode;
   input                          sg;
   input                          delay_lclkr;
   input                          mpw1_b;
   input                          mpw2_b;
   input [OFFSET:OFFSET+WIDTH-1]  scin;
   input [OFFSET:OFFSET+WIDTH-1]  din;
   output [OFFSET:OFFSET+WIDTH-1] scout;
   output [OFFSET:OFFSET+WIDTH-1] dout;

   // tri_ser_rlmreg_p

   wire [OFFSET:OFFSET+WIDTH-1]   dout_b;
   wire [OFFSET:OFFSET+WIDTH-1]   act_buf;
   wire [OFFSET:OFFSET+WIDTH-1]   act_buf_b;
   wire [OFFSET:OFFSET+WIDTH-1]   dout_buf;

   assign act_buf = {WIDTH{act}};
   assign act_buf_b = {WIDTH{~(act)}};
   assign dout_buf = (~dout_b);
   assign dout = dout_buf;

   tri_aoi22_nlats_wlcb #(.WIDTH(WIDTH), .OFFSET(OFFSET), .INIT(INIT), .IBUF(IBUF), .DUALSCAN(DUALSCAN), .NEEDS_SRESET(NEEDS_SRESET)) tri_ser_rlmreg_p(
         .nclk(nclk),
         .vd(vd),
         .gd(gd),
         .act(act),
         .force_t(force_t),
         .d_mode(d_mode),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .thold_b(thold_b),
         .sg(sg),
         .scin(scin),
         .scout(scout),
         .a1(din),
         .a2(act_buf),
         .b1(dout_buf),
         .b2(act_buf_b),
         .qb(dout_b)
   );
endmodule
