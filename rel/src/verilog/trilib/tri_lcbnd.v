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
// *! FILENAME    : tri_lcbnd.v
// *! DESCRIPTION : Wrapper for nlat LCB - will not run in pulsed mode
// *!****************************************************************

`include "tri_a2o.vh"

module tri_lcbnd(
   vd,
   gd,
   act,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   nclk,
   force_t,
   sg,
   thold_b,
   d1clk,
   d2clk,
   lclk
);
   parameter                      DOMAIN_CROSSING = 0;

   inout      vd;
   inout      gd;
   input      act;
   input      delay_lclkr;
   input      mpw1_b;
   input      mpw2_b;
   input[0:`NCLK_WIDTH-1]  nclk;
   input      force_t;
   input      sg;
   input      thold_b;
   output     d1clk;
   output     d2clk;
   output[0:`NCLK_WIDTH-1]  lclk;

   // tri_lcbnd
   wire       gate_b;
    (* analysis_not_referenced="true" *)
   wire       unused;

   assign unused = vd | gd | delay_lclkr | mpw1_b | mpw2_b | sg;

   assign gate_b = force_t | act;

   assign d1clk = gate_b;
   assign d2clk = thold_b;
   assign lclk = nclk;
endmodule
