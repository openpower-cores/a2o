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
// *! FILENAME    : tri_nlat.v
// *! DESCRIPTION : Basic n-bit latch w/ internal scan
// *!****************************************************************

`include "tri_a2o.vh"

module tri_nlat(
   vd,
   gd,
   d1clk,
   d2clk,
   lclk,
   scan_in,
   din,
   q,
   q_b,
   scan_out
);
   parameter                      OFFSET = 0;
   parameter                      SCAN = 0;                     //SCAN = normal;
                                                                //0=normal,1=interleaved,2=reversed,3=reverse_interleaved
   parameter                      RESET_INVERTS_SCAN = 1'b1;
   parameter                      WIDTH = 1;
   parameter                      INIT = 0;
   parameter                      L2_LATCH_TYPE = 2;            //L2_LATCH_TYPE = slave_latch;
                                                                //0=master_latch,1=L1,2=slave_latch,3=L2,4=flush_latch,5=L4
   parameter                      SYNTHCLONEDLATCH = "";
   parameter                      NEEDS_SRESET = 1;		// for inferred latches
   parameter                      DOMAIN_CROSSING = 0;		// 0 - Internal Flop, 1 - Domain Crossing Input Flop (requires extra logic for ASICs)

   inout                          vd;
   inout                          gd;
   input                          d1clk;
   input                          d2clk;
   input [0:`NCLK_WIDTH-1]        lclk;
   input                          scan_in;
   input [OFFSET:OFFSET+WIDTH-1]  din;
   output [OFFSET:OFFSET+WIDTH-1] q;
   output [OFFSET:OFFSET+WIDTH-1] q_b;
   output                         scan_out;

   // tri_nlat

   parameter [0:WIDTH-1]          init_v = INIT;

   generate
   begin
      wire                          sreset;
      wire [0:WIDTH-1]              int_din;
      reg [0:WIDTH-1]               int_dout;
      wire [0:WIDTH-1]              vact;
      wire [0:WIDTH-1]              vact_b;
      wire [0:WIDTH-1]              vsreset;
      wire [0:WIDTH-1]              vsreset_b;
      wire [0:WIDTH-1]              vthold;
      wire [0:WIDTH-1]              vthold_b;
       (* analysis_not_referenced="true" *)
      wire                          unused;

      if (NEEDS_SRESET == 1)
      begin : rst
        assign sreset = lclk[1];
      end
      if (NEEDS_SRESET != 1)
      begin : no_rst
        assign sreset = 1'b0;
      end

      assign vsreset = {WIDTH{sreset}};
      assign vsreset_b = {WIDTH{~sreset}};
      assign int_din = (vsreset_b & din) | (vsreset & init_v);

      assign vact = {WIDTH{d1clk}};
      assign vact_b = {WIDTH{~d1clk}};

      assign vthold_b = {WIDTH{d2clk}};
      assign vthold = {WIDTH{~d2clk}};


      always @(posedge lclk[0])
      begin: l
        int_dout <= (((vact & vthold_b) | vsreset) & int_din) | (((vact_b | vthold) & vsreset_b) & int_dout);
      end
      assign q = int_dout;
      assign q_b = (~int_dout);
      assign scan_out = 1'b0;

      assign unused = | {vd, gd, lclk, scan_in};
   end
   endgenerate
endmodule
