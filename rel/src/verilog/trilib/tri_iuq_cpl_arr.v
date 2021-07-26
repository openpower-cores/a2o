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

`timescale 1 fs / 1 fs

// *!****************************************************************
// *! FILENAME    : tri_iuq_cpl_arr.v
// *! DESCRIPTION : iuq completion array (fpga model)
// *!****************************************************************

`include "tri_a2o.vh"

module tri_iuq_cpl_arr(gnd, vdd, nclk, delay_lclkr_dc, mpw1_dc_b, mpw2_dc_b, force_t, thold_0_b, sg_0, scan_in, scan_out, re0, ra0, do0, re1, ra1, do1, we0, wa0, di0, we1, wa1, di1, perr);
   parameter                    ADDRESSABLE_PORTS = 64;         // number of addressable register in this array
   parameter                    ADDRESSBUS_WIDTH = 6;		// width of the bus to address all ports (2^ADDRESSBUS_WIDTH >= addressable_ports)
   parameter                    PORT_BITWIDTH = 64;		// bitwidth of ports
   parameter                    LATCHED_READ = 1'b1;
   parameter                    LATCHED_READ_DATA = 1'b1;
   parameter                    LATCHED_WRITE = 1'b1;

   // POWER PINS
   (* ground_pin=1 *)
   inout                        gnd;
   (* power_pin=1 *)
   inout                        vdd;

   input [0:`NCLK_WIDTH-1]      nclk;

   //-------------------------------------------------------------------
   // Pervasive
   //-------------------------------------------------------------------
   input                        delay_lclkr_dc;
   input                        mpw1_dc_b;
   input                        mpw2_dc_b;
   input                        force_t;
   input                        thold_0_b;
   input                        sg_0;
   input                        scan_in;
   output                       scan_out;

   //-------------------------------------------------------------------
   // Functional
   //-------------------------------------------------------------------
   input                        re0;
   input [0:ADDRESSBUS_WIDTH-1] ra0;
   output [0:PORT_BITWIDTH-1]   do0;

   input                        re1;
   input [0:ADDRESSBUS_WIDTH-1] ra1;
   output [0:PORT_BITWIDTH-1]   do1;

   input                        we0;
   input [0:ADDRESSBUS_WIDTH-1] wa0;
   input [0:PORT_BITWIDTH-1]    di0;

   input                        we1;
   input [0:ADDRESSBUS_WIDTH-1] wa1;
   input [0:PORT_BITWIDTH-1]    di1;

   output                       perr;

   reg                          re0_q;
   reg                          we0_q;
   reg  [0:ADDRESSBUS_WIDTH-1]  ra0_q;
   reg  [0:ADDRESSBUS_WIDTH-1]  wa0_q;
   reg  [0:PORT_BITWIDTH-1]     do0_q;
   wire [0:PORT_BITWIDTH-1]     do0_d;
   reg  [0:PORT_BITWIDTH-1]     di0_q;

   reg                          re1_q;
   reg                          we1_q;
   reg  [0:ADDRESSBUS_WIDTH-1]  ra1_q;
   reg  [0:ADDRESSBUS_WIDTH-1]  wa1_q;
   reg  [0:PORT_BITWIDTH-1]     do1_q;
   wire [0:PORT_BITWIDTH-1]     do1_d;
   reg  [0:PORT_BITWIDTH-1]     di1_q;

   wire                         correct_clk;
   wire                         reset;
   wire                         reset_hi;
   reg                          reset_q;

   wire [0:PORT_BITWIDTH-1]     dout0;		//std
   wire                         wen0;		//std
   wire [0:ADDRESSBUS_WIDTH-1]  addr_w0;        //std
   wire [0:ADDRESSBUS_WIDTH-1]  addr_r0;	//std
   wire [0:PORT_BITWIDTH-1]     din0;		//std

   wire [0:PORT_BITWIDTH-1]     dout1;		//std
   wire                         wen1;		//std
   wire [0:ADDRESSBUS_WIDTH-1]  addr_w1;	//std
   wire [0:ADDRESSBUS_WIDTH-1]  addr_r1;	//std
   wire [0:PORT_BITWIDTH-1]     din1;		//std

   reg                          we1_latch_q;
   reg [0:ADDRESSBUS_WIDTH-1]   wa1_latch_q;
   reg [0:PORT_BITWIDTH-1]      di1_latch_q;


   (* analysis_not_referenced="true" *)
   wire 								  unused_SPO_0;
   (* analysis_not_referenced="true" *)
   wire 								  unused_SPO_1;


   generate
      assign reset = nclk[1];
      assign correct_clk = nclk[0];

      assign reset_hi = reset;


      // Slow Latches (nclk)

      always @(posedge correct_clk or posedge reset)
      begin: slatch
         begin
            if (reset == 1'b1)
               we1_latch_q <= 1'b0;
            else
            begin
               we1_latch_q <= we1_q;
               wa1_latch_q <= wa1_q;
               di1_latch_q <= di1_q;
            end
         end
      end


      // repower latches for resets
      always @(posedge correct_clk)
      begin: rlatch
         reset_q <= reset_hi;
      end

      // need to select which array to write based on the lowest order bit of the address which will indicate odd or even itag
      // when both we0 and we1 are both asserted it is assumed that the low order bit of wa0 will not be equal to the low order
      // bit of wa1
      assign addr_w0 = (wa0_q[ADDRESSBUS_WIDTH-1]) ? {wa1_q[0:ADDRESSBUS_WIDTH-2], 1'b0 } : {wa0_q[0:ADDRESSBUS_WIDTH-2], 1'b0 };
      assign wen0    = (wa0_q[ADDRESSBUS_WIDTH-1]) ?  we1_q  : we0_q;
      assign din0    = (wa0_q[ADDRESSBUS_WIDTH-1]) ?  di1_q  : di0_q;
      assign addr_r0 = (ra0_q[ADDRESSBUS_WIDTH-1]) ? {ra1_q[0:ADDRESSBUS_WIDTH-2], 1'b0 } : {ra0_q[0:ADDRESSBUS_WIDTH-2], 1'b0 };

      assign addr_w1 = (wa1_q[ADDRESSBUS_WIDTH-1]) ? {wa1_q[0:ADDRESSBUS_WIDTH-2], 1'b0 } : {wa0_q[0:ADDRESSBUS_WIDTH-2], 1'b0 };
      assign wen1    = (wa1_q[ADDRESSBUS_WIDTH-1]) ?  we1_q  : we0_q;
      assign din1    = (wa1_q[ADDRESSBUS_WIDTH-1]) ?  di1_q  : di0_q;
      assign addr_r1 = (ra1_q[ADDRESSBUS_WIDTH-1]) ? {ra1_q[0:ADDRESSBUS_WIDTH-2], 1'b0 } : {ra0_q[0:ADDRESSBUS_WIDTH-2], 1'b0 };

      assign perr = 1'b0;

      begin : xhdl0
         genvar i;
         for (i = 0; i <= PORT_BITWIDTH - 1; i = i + 1)
         begin : array_gen0
            RAM64X1D #(.INIT(64'h0000000000000000)) RAM64X1D0(
               .DPO(dout0[i]),
               .SPO(unused_SPO_0),

               .A0(addr_w0[0]),
               .A1(addr_w0[1]),
               .A2(addr_w0[2]),
               .A3(addr_w0[3]),
               .A4(addr_w0[4]),
               .A5(addr_w0[5]),
               .D(din0[i]),
               .DPRA0(addr_r0[0]),
               .DPRA1(addr_r0[1]),
               .DPRA2(addr_r0[2]),
               .DPRA3(addr_r0[3]),
               .DPRA4(addr_r0[4]),
               .DPRA5(addr_r0[5]),
               .WCLK(correct_clk),
               .WE(wen0)
            );

            RAM64X1D #(.INIT(64'h0000000000000000)) RAM64X1D1(
               .DPO(dout1[i]),
               .SPO(unused_SPO_1),

               .A0(addr_w1[0]),
               .A1(addr_w1[1]),
               .A2(addr_w1[2]),
               .A3(addr_w1[3]),
               .A4(addr_w1[4]),
               .A5(addr_w1[5]),
               .D(din1[i]),
               .DPRA0(addr_r1[0]),
               .DPRA1(addr_r1[1]),
               .DPRA2(addr_r1[2]),
               .DPRA3(addr_r1[3]),
               .DPRA4(addr_r1[4]),
               .DPRA5(addr_r1[5]),
               .WCLK(correct_clk),
               .WE(wen1)
            );


         end
      end

      assign do0_d = (ra0_q[ADDRESSBUS_WIDTH-1]) ? dout1 : dout0;
      assign do1_d = (ra1_q[ADDRESSBUS_WIDTH-1]) ? dout1 : dout0;
      assign do0 = do0_q;
      assign do1 = do1_q;

      if (LATCHED_READ == 1'b0)
      begin : read_latched_false
         always @(*)
         begin
            re0_q <= re0;
            ra0_q <= ra0;
            re1_q <= re1;
            ra1_q <= ra1;
         end
      end
      if (LATCHED_READ == 1'b1)
      begin : read_latched_true
         always @(posedge correct_clk)
         begin: read_latches
            if (correct_clk == 1'b1)
            begin
               if (reset_q == 1'b1)
               begin
                  re0_q <= 1'b0;
                  ra0_q <= {ADDRESSBUS_WIDTH{1'b0}};
                  re1_q <= 1'b0;
                  ra1_q <= {ADDRESSBUS_WIDTH{1'b0}};
               end
               else
               begin
                  re0_q <= re0;
                  ra0_q <= ra0;
                  re1_q <= re1;
                  ra1_q <= ra1;
               end
            end
         end
      end

      if (LATCHED_WRITE == 1'b0)
      begin : write_latched_false
         always @(*)
         begin
            we0_q <= we0;
            wa0_q <= wa0;
            di0_q <= di0;
            we1_q <= we1;
            wa1_q <= wa1;
            di1_q <= di1;
         end
      end
      if (LATCHED_WRITE == 1'b1)
      begin : write_latched_true
         always @(posedge correct_clk)
         begin: write_latches
            if (correct_clk == 1'b1)
            begin
               if (reset_q == 1'b1)
               begin
                  we0_q <= 1'b0;
                  wa0_q <= {ADDRESSBUS_WIDTH{1'b0}};
                  di0_q <= {PORT_BITWIDTH{1'b0}};
                  we1_q <= 1'b0;
                  wa1_q <= {ADDRESSBUS_WIDTH{1'b0}};
                  di1_q <= {PORT_BITWIDTH{1'b0}};
               end
               else
               begin
                  we0_q <= we0;
                  wa0_q <= wa0;
                  di0_q <= di0;
                  we1_q <= we1;
                  wa1_q <= wa1;
                  di1_q <= di1;
               end
            end
         end
      end

      if (LATCHED_READ_DATA == 1'b0)
      begin : read_data_latched_false
         always @(*)
         begin
            do0_q <= do0_d;
            do1_q <= do1_d;
         end
      end
      if (LATCHED_READ_DATA == 1'b1)
      begin : read_data_latched_true
         always @(posedge correct_clk)
         begin: read_data_latches
            if (correct_clk == 1'b1)
            begin
               if (reset_q == 1'b1)
               begin
                  do0_q <= {PORT_BITWIDTH{1'b0}};
                  do1_q <= {PORT_BITWIDTH{1'b0}};
               end
               else
               begin
                  do0_q <= do0_d;
                  do1_q <= do1_d;
               end
            end
         end
      end
   endgenerate
endmodule
