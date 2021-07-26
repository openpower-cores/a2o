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

//  Description:  Register File Array
//
//*****************************************************************************
`include "tri_a2o.vh"
module xu_rf
#(
   parameter             PAR_WIDTH = 1,
   parameter             WIDTH = 8,
   parameter             POOL_ENC = 5,
   parameter             POOL = 24,
   parameter             RD_PORTS = 1,
   parameter             WR_PORTS = 1,
   parameter             BYPASS = 1
)
(
   //-------------------------------------------------------------------
   // Clocks & Power
   //-------------------------------------------------------------------
   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) // nclk
   input [0:`NCLK_WIDTH-1] nclk,
   inout                  vdd,
   inout                  gnd,

   //-------------------------------------------------------------------
   // Pervasive
   //-------------------------------------------------------------------
   input                 d_mode_dc,
   input                 delay_lclkr_dc,
   input                 mpw1_dc_b,
   input                 mpw2_dc_b,
   input                 func_sl_force,
   input                 func_sl_thold_0_b,
   input                 func_nsl_force,
   input                 func_nsl_thold_0_b,
   input                 sg_0,
   input                 scan_in,
   output                scan_out,

   //-------------------------------------------------------------------
   // Read Ports
   //-------------------------------------------------------------------
   input                 r0e_e,
   input                 r0e,
   input [0:POOL_ENC-1]  r0a,
   output [0:WIDTH-1]    r0d,

   input                 r1e_e,
   input                 r1e,
   input [0:POOL_ENC-1]  r1a,
   output [0:WIDTH-1]    r1d,

   input                 r2e_e,
   input                 r2e,
   input [0:POOL_ENC-1]  r2a,
   output [0:WIDTH-1]    r2d,

   input                 r3e_e,
   input                 r3e,
   input [0:POOL_ENC-1]  r3a,
   output [0:WIDTH-1]    r3d,

   input                 r4e_e,
   input                 r4e,
   input [0:POOL_ENC-1]  r4a,
   output [0:WIDTH-1]    r4d,

   //-------------------------------------------------------------------
   // Write ports
   //-------------------------------------------------------------------
   input                 w0e_e,
   input                 w0e,
   input [0:POOL_ENC-1]  w0a,
   input [0:WIDTH-1]     w0d,

   input                 w1e_e,
   input                 w1e,
   input [0:POOL_ENC-1]  w1a,
   input [0:WIDTH-1]     w1d,

   input                 w2e_e,
   input                 w2e,
   input [0:POOL_ENC-1]  w2a,
   input [0:WIDTH-1]     w2d,

   input                 w3e_e,
   input                 w3e,
   input [0:POOL_ENC-1]  w3a,
   input [0:WIDTH-1]     w3d,

   input                 w4e_e,
   input                 w4e,
   input [0:POOL_ENC-1]  w4a,

   input [0:WIDTH-1]     w4d
);

   localparam             USE_R0 = {31'b0,(RD_PORTS > 0)};
   localparam             USE_R1 = {31'b0,(RD_PORTS > 1)};
   localparam             USE_R2 = {31'b0,(RD_PORTS > 2)};
   localparam             USE_R3 = {31'b0,(RD_PORTS > 3)};
   localparam             USE_R4 = {31'b0,(RD_PORTS > 4)};
   localparam             USE_W0 = {31'b0,(WR_PORTS > 0)};
   localparam             USE_W1 = {31'b0,(WR_PORTS > 1)};
   localparam             USE_W2 = {31'b0,(WR_PORTS > 2)};
   localparam             USE_W3 = {31'b0,(WR_PORTS > 3)};
   localparam             USE_W4 = {31'b0,(WR_PORTS > 4)};

   wire [0:WIDTH-1]              reg_q[0:POOL-1];

   reg [0:WIDTH-1]               reg_d[0:POOL-1]                                       ; // input=>par_d[r]   ,act=>reg_act[r]
	wire                          r0e_q                                                 ; //  input=>r0e     ,act=>1'b1
	wire [0:POOL_ENC-1]           r0a_q                                                 ; //  input=>r0a     ,act=>r0e_e
	wire [0:WIDTH-1]              r0d_q,                     r0d_d                      ; //  input=>r0d     ,act=>r0e_q
	wire                          r1e_q                                                 ; //  input=>r1e     ,act=>1'b1
	wire [0:POOL_ENC-1]           r1a_q                                                 ; //  input=>r1a     ,act=>r1e_e
	wire [0:WIDTH-1]              r1d_q,                     r1d_d                      ; //  input=>r1d     ,act=>r1e_q
	wire                          r2e_q                                                 ; //  input=>r2e     ,act=>1'b1
	wire [0:POOL_ENC-1]           r2a_q                                                 ; //  input=>r2a     ,act=>r2e_e
	wire [0:WIDTH-1]              r2d_q,                     r2d_d                      ; //  input=>r2d     ,act=>r2e_q
	wire                          r3e_q                                                 ; //  input=>r3e     ,act=>1'b1
	wire [0:POOL_ENC-1]           r3a_q                                                 ; //  input=>r3a     ,act=>r3e_e
	wire [0:WIDTH-1]              r3d_q,                     r3d_d                      ; //  input=>r3d     ,act=>r3e_q
	wire                          r4e_q                                                 ; //  input=>r4e     ,act=>1'b1
	wire [0:POOL_ENC-1]           r4a_q                                                 ; //  input=>r4a     ,act=>r4e_e
	wire [0:WIDTH-1]              r4d_q,                     r4d_d                      ; //  input=>r4d     ,act=>r4e_q
	wire                          w0e_q                                                 ; //  input=>w0e     ,act=>1'b1
	wire [0:POOL_ENC-1]           w0a_q                                                 ; //  input=>w0a     ,act=>w0e_e
	wire [0:WIDTH-1]              w0d_q                                                 ; //  input=>w0d     ,act=>w0e_e
	wire                          w1e_q                                                 ; //  input=>w1e     ,act=>1'b1
	wire [0:POOL_ENC-1]           w1a_q                                                 ; //  input=>w1a     ,act=>w1e_e
	wire [0:WIDTH-1]              w1d_q                                                 ; //  input=>w1d     ,act=>w1e_e
	wire                          w2e_q                                                 ; //  input=>w2e     ,act=>1'b1
	wire [0:POOL_ENC-1]           w2a_q                                                 ; //  input=>w2a     ,act=>w2e_e
	wire [0:WIDTH-1]              w2d_q                                                 ; //  input=>w2d     ,act=>w2e_e
	wire                          w3e_q                                                 ; //  input=>w3e     ,act=>1'b1
	wire [0:POOL_ENC-1]           w3a_q                                                 ; //  input=>w3a     ,act=>w3e_e
	wire [0:WIDTH-1]              w3d_q                                                 ; //  input=>w3d     ,act=>w3e_e
	wire                          w4e_q                                                 ; //  input=>w4e     ,act=>1'b1
	wire [0:POOL_ENC-1]           w4a_q                                                 ; //  input=>w4a     ,act=>w4e_e
	wire [0:WIDTH-1]              w4d_q                                                 ; //  input=>w4d     ,act=>w4e_e
   // Scanchain
   localparam             reg_offset = 0;
   localparam             r0e_offset = reg_offset + WIDTH*POOL;
   localparam             r0a_offset = r0e_offset + 1 * USE_R0;
   localparam             r0d_offset = r0a_offset + POOL_ENC * USE_R0;
   localparam             r1e_offset = r0d_offset + WIDTH * USE_R0;
   localparam             r1a_offset = r1e_offset + 1 * USE_R1;
   localparam             r1d_offset = r1a_offset + POOL_ENC * USE_R1;
   localparam             r2e_offset = r1d_offset + WIDTH * USE_R1;
   localparam             r2a_offset = r2e_offset + 1 * USE_R2;
   localparam             r2d_offset = r2a_offset + POOL_ENC * USE_R2;
   localparam             r3e_offset = r2d_offset + WIDTH * USE_R2;
   localparam             r3a_offset = r3e_offset + 1 * USE_R3;
   localparam             r3d_offset = r3a_offset + POOL_ENC * USE_R3;
   localparam             r4e_offset = r3d_offset + WIDTH * USE_R3;
   localparam             r4a_offset = r4e_offset + 1 * USE_R4;
   localparam             r4d_offset = r4a_offset + POOL_ENC * USE_R4;
   localparam             w0e_offset = r4d_offset + WIDTH * USE_R4;
   localparam             w0a_offset = w0e_offset + 1 * USE_W0;
   localparam             w0d_offset = w0a_offset + POOL_ENC * USE_W0;
   localparam             w1e_offset = w0d_offset + WIDTH * USE_W0;
   localparam             w1a_offset = w1e_offset + 1 * USE_W1;
   localparam             w1d_offset = w1a_offset + POOL_ENC * USE_W1;
   localparam             w2e_offset = w1d_offset + WIDTH * USE_W1;
   localparam             w2a_offset = w2e_offset + 1 * USE_W2;
   localparam             w2d_offset = w2a_offset + POOL_ENC * USE_W2;
   localparam             w3e_offset = w2d_offset + WIDTH * USE_W2;
   localparam             w3a_offset = w3e_offset + 1 * USE_W3;
   localparam             w3d_offset = w3a_offset + POOL_ENC * USE_W3;
   localparam             w4e_offset = w3d_offset + WIDTH * USE_W3;
   localparam             w4a_offset = w4e_offset + 1 * USE_W4;
   localparam             w4d_offset = w4a_offset + POOL_ENC * USE_W4;
   localparam             scan_right = w4d_offset + WIDTH * USE_W4;
   wire [0:scan_right-1] siv;
   wire [0:scan_right-1] sov;
   // Signals
   reg [0:POOL-1]        reg_act;
   reg [0:WIDTH-1]       r0d_array;
   reg [0:WIDTH-1]       r1d_array;
   reg [0:WIDTH-1]       r2d_array;
   reg [0:WIDTH-1]       r3d_array;
   reg [0:WIDTH-1]       r4d_array;

   (* analysis_not_assigned="true" *)
   (* analysis_not_referenced="true" *)
   wire [0:7] unused;

   //!! Bugspray Include: xu_rf;

always @*
begin: write
    // synopsys translate_off
    (* analysis_not_referenced="true" *)
    // synopsys translate_on
   integer               i;
   reg_act  <= 0;

   for (i=0;i<=POOL-1;i=i+1)
   begin
      reg_d[i]       <= reg_q[i];

      if (w0e_q == 1'b1 & {{32-POOL_ENC{1'b0}},w0a_q} == i)
      begin
         reg_act[i]  <= 1'b1;
         reg_d[i]    <= w0d_q;
      end

      if (w1e_q == 1'b1 & {{32-POOL_ENC{1'b0}},w1a_q} == i)
      begin
         reg_act[i]  <= 1'b1;
         reg_d[i]    <= w1d_q;
      end

      if (w2e_q == 1'b1 & {{32-POOL_ENC{1'b0}},w2a_q} == i)
      begin
         reg_act[i]  <= 1'b1;
         reg_d[i]    <= w2d_q;
      end

      if (w3e_q == 1'b1 & {{32-POOL_ENC{1'b0}},w3a_q} == i)
      begin
         reg_act[i]  <= 1'b1;
         reg_d[i]    <= w3d_q;
      end

      if (w4e_q == 1'b1 & {{32-POOL_ENC{1'b0}},w4a_q} == i)
      begin
         reg_act[i]  <= 1'b1;
         reg_d[i]    <= w4d_q;
      end
   end

end


always @*
begin: read
    // synopsys translate_off
    (* analysis_not_referenced="true" *)
    // synopsys translate_on
   integer               i;
   r0d_array <= 0;
   r1d_array <= 0;
   r2d_array <= 0;
   r3d_array <= 0;
   r4d_array <= 0;

   for (i=0;i<=POOL-1;i=i+1)
   begin
      if (USE_R0 == 1 & {{32-POOL_ENC{1'b0}},r0a_q} == i)
      begin
         r0d_array <= reg_q[i];
      end
      if (USE_R1 == 1 & {{32-POOL_ENC{1'b0}},r1a_q} == i)
      begin
         r1d_array <= reg_q[i];
      end
      if (USE_R2 == 1 & {{32-POOL_ENC{1'b0}},r2a_q} == i)
      begin
         r2d_array <= reg_q[i];
      end
      if (USE_R3 == 1 & {{32-POOL_ENC{1'b0}},r3a_q} == i)
      begin
         r3d_array <= reg_q[i];
      end
      if (USE_R4 == 1 & {{32-POOL_ENC{1'b0}},r4a_q} == i)
      begin
         r4d_array <= reg_q[i];
      end
   end
end

// BYPASS

generate
   if (BYPASS == 1)
   begin : read_bypass
      wire [0:10]            r0_byp_sel;
      wire [0:10]            r1_byp_sel;
      wire [0:10]            r2_byp_sel;
      wire [0:10]            r3_byp_sel;
      wire [0:10]            r4_byp_sel;
      assign r0_byp_sel[0] = w0e_q & (w0a_q == r0a_q);
      assign r0_byp_sel[1] = w1e_q & (w1a_q == r0a_q);
      assign r0_byp_sel[2] = w2e_q & (w2a_q == r0a_q);
      assign r0_byp_sel[3] = w3e_q & (w3a_q == r0a_q);
      assign r0_byp_sel[4] = w4e_q & (w4a_q == r0a_q);
      assign r0_byp_sel[5] = w0e & (w0a == r0a_q);
      assign r0_byp_sel[6] = w1e & (w1a == r0a_q);
      assign r0_byp_sel[7] = w2e & (w2a == r0a_q);
      assign r0_byp_sel[8] = w3e & (w3a == r0a_q);
      assign r0_byp_sel[9] = w4e & (w4a == r0a_q);
      assign r0_byp_sel[10] = (~|(r0_byp_sel[0:9]));

      assign r0d_d = (w0d_q      & {WIDTH{r0_byp_sel[0]}}) |
                     (w1d_q      & {WIDTH{r0_byp_sel[1]}}) |
                     (w2d_q      & {WIDTH{r0_byp_sel[2]}}) |
                     (w3d_q      & {WIDTH{r0_byp_sel[3]}}) |
                     (w4d_q      & {WIDTH{r0_byp_sel[4]}}) |
                     (w0d        & {WIDTH{r0_byp_sel[5]}}) |
                     (w1d        & {WIDTH{r0_byp_sel[6]}}) |
                     (w2d        & {WIDTH{r0_byp_sel[7]}}) |
                     (w3d        & {WIDTH{r0_byp_sel[8]}}) |
                     (w4d        & {WIDTH{r0_byp_sel[9]}}) |
                     (r0d_array  & {WIDTH{r0_byp_sel[10]}});

      assign r1_byp_sel[0] = w0e_q & (w0a_q == r1a_q);
      assign r1_byp_sel[1] = w1e_q & (w1a_q == r1a_q);
      assign r1_byp_sel[2] = w2e_q & (w2a_q == r1a_q);
      assign r1_byp_sel[3] = w3e_q & (w3a_q == r1a_q);
      assign r1_byp_sel[4] = w4e_q & (w4a_q == r1a_q);
      assign r1_byp_sel[5] = w0e & (w0a == r1a_q);
      assign r1_byp_sel[6] = w1e & (w1a == r1a_q);
      assign r1_byp_sel[7] = w2e & (w2a == r1a_q);
      assign r1_byp_sel[8] = w3e & (w3a == r1a_q);
      assign r1_byp_sel[9] = w4e & (w4a == r1a_q);
      assign r1_byp_sel[10] = (~|(r1_byp_sel[0:9]));

      assign r1d_d = (w0d_q      & {WIDTH{r1_byp_sel[0]}}) |
                     (w1d_q      & {WIDTH{r1_byp_sel[1]}}) |
                     (w2d_q      & {WIDTH{r1_byp_sel[2]}}) |
                     (w3d_q      & {WIDTH{r1_byp_sel[3]}}) |
                     (w4d_q      & {WIDTH{r1_byp_sel[4]}}) |
                     (w0d        & {WIDTH{r1_byp_sel[5]}}) |
                     (w1d        & {WIDTH{r1_byp_sel[6]}}) |
                     (w2d        & {WIDTH{r1_byp_sel[7]}}) |
                     (w3d        & {WIDTH{r1_byp_sel[8]}}) |
                     (w4d        & {WIDTH{r1_byp_sel[9]}}) |
                     (r1d_array  & {WIDTH{r1_byp_sel[10]}});

      assign r2_byp_sel[0] = w0e_q & (w0a_q == r2a_q);
      assign r2_byp_sel[1] = w1e_q & (w1a_q == r2a_q);
      assign r2_byp_sel[2] = w2e_q & (w2a_q == r2a_q);
      assign r2_byp_sel[3] = w3e_q & (w3a_q == r2a_q);
      assign r2_byp_sel[4] = w4e_q & (w4a_q == r2a_q);
      assign r2_byp_sel[5] = w0e & (w0a == r2a_q);
      assign r2_byp_sel[6] = w1e & (w1a == r2a_q);
      assign r2_byp_sel[7] = w2e & (w2a == r2a_q);
      assign r2_byp_sel[8] = w3e & (w3a == r2a_q);
      assign r2_byp_sel[9] = w4e & (w4a == r2a_q);
      assign r2_byp_sel[10] = (~|(r2_byp_sel[0:9]));

      assign r2d_d = (w0d_q      & {WIDTH{r2_byp_sel[0]}}) |
                     (w1d_q      & {WIDTH{r2_byp_sel[1]}}) |
                     (w2d_q      & {WIDTH{r2_byp_sel[2]}}) |
                     (w3d_q      & {WIDTH{r2_byp_sel[3]}}) |
                     (w4d_q      & {WIDTH{r2_byp_sel[4]}}) |
                     (w0d        & {WIDTH{r2_byp_sel[5]}}) |
                     (w1d        & {WIDTH{r2_byp_sel[6]}}) |
                     (w2d        & {WIDTH{r2_byp_sel[7]}}) |
                     (w3d        & {WIDTH{r2_byp_sel[8]}}) |
                     (w4d        & {WIDTH{r2_byp_sel[9]}}) |
                     (r2d_array  & {WIDTH{r2_byp_sel[10]}});

      assign r3_byp_sel[0] = w0e_q & (w0a_q == r3a_q);
      assign r3_byp_sel[1] = w1e_q & (w1a_q == r3a_q);
      assign r3_byp_sel[2] = w2e_q & (w2a_q == r3a_q);
      assign r3_byp_sel[3] = w3e_q & (w3a_q == r3a_q);
      assign r3_byp_sel[4] = w4e_q & (w4a_q == r3a_q);
      assign r3_byp_sel[5] = w0e & (w0a == r3a_q);
      assign r3_byp_sel[6] = w1e & (w1a == r3a_q);
      assign r3_byp_sel[7] = w2e & (w2a == r3a_q);
      assign r3_byp_sel[8] = w3e & (w3a == r3a_q);
      assign r3_byp_sel[9] = w4e & (w4a == r3a_q);
      assign r3_byp_sel[10] = (~|(r3_byp_sel[0:9]));

      assign r3d_d = (w0d_q      & {WIDTH{r3_byp_sel[0]}}) |
                     (w1d_q      & {WIDTH{r3_byp_sel[1]}}) |
                     (w2d_q      & {WIDTH{r3_byp_sel[2]}}) |
                     (w3d_q      & {WIDTH{r3_byp_sel[3]}}) |
                     (w4d_q      & {WIDTH{r3_byp_sel[4]}}) |
                     (w0d        & {WIDTH{r3_byp_sel[5]}}) |
                     (w1d        & {WIDTH{r3_byp_sel[6]}}) |
                     (w2d        & {WIDTH{r3_byp_sel[7]}}) |
                     (w3d        & {WIDTH{r3_byp_sel[8]}}) |
                     (w4d        & {WIDTH{r3_byp_sel[9]}}) |
                     (r3d_array  & {WIDTH{r3_byp_sel[10]}});

      assign r4_byp_sel[0] = w0e_q & (w0a_q == r4a_q);
      assign r4_byp_sel[1] = w1e_q & (w1a_q == r4a_q);
      assign r4_byp_sel[2] = w2e_q & (w2a_q == r4a_q);
      assign r4_byp_sel[3] = w3e_q & (w3a_q == r4a_q);
      assign r4_byp_sel[4] = w4e_q & (w4a_q == r4a_q);
      assign r4_byp_sel[5] = w0e & (w0a == r4a_q);
      assign r4_byp_sel[6] = w1e & (w1a == r4a_q);
      assign r4_byp_sel[7] = w2e & (w2a == r4a_q);
      assign r4_byp_sel[8] = w3e & (w3a == r4a_q);
      assign r4_byp_sel[9] = w4e & (w4a == r4a_q);
      assign r4_byp_sel[10] = (~|(r4_byp_sel[0:9]));

      assign r4d_d = (w0d_q      & {WIDTH{r4_byp_sel[0]}}) |
                     (w1d_q      & {WIDTH{r4_byp_sel[1]}}) |
                     (w2d_q      & {WIDTH{r4_byp_sel[2]}}) |
                     (w3d_q      & {WIDTH{r4_byp_sel[3]}}) |
                     (w4d_q      & {WIDTH{r4_byp_sel[4]}}) |
                     (w0d        & {WIDTH{r4_byp_sel[5]}}) |
                     (w1d        & {WIDTH{r4_byp_sel[6]}}) |
                     (w2d        & {WIDTH{r4_byp_sel[7]}}) |
                     (w3d        & {WIDTH{r4_byp_sel[8]}}) |
                     (w4d        & {WIDTH{r4_byp_sel[9]}}) |
                     (r4d_array  & {WIDTH{r4_byp_sel[10]}});

   end
endgenerate

generate
   if (BYPASS == 0)
   begin : read_nobypass
      assign r0d_d = r0d_array;
      assign r1d_d = r1d_array;
      assign r2d_d = r2d_array;
      assign r3d_d = r3d_array;
      assign r4d_d = r4d_array;
   end
endgenerate

assign r0d = r0d_q;
assign r1d = r1d_q;
assign r2d = r2d_q;
assign r3d = r3d_q;
assign r4d = r4d_q;

generate
   genvar                r;
   for (r=0;r<=POOL-1;r=r+1)
   begin : entry
      tri_regk #(.WIDTH(WIDTH), .INIT(0), .NEEDS_SRESET(1)) reg_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(reg_act[r]),
         .force_t(func_nsl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_nsl_thold_0_b),
         .sg(sg_0),
         .scin(siv[reg_offset+r*WIDTH:reg_offset+(r+1)*WIDTH-1]),
         .scout(sov[reg_offset+r*WIDTH:reg_offset+(r+1)*WIDTH-1]),
         .din(reg_d[r]),
         .dout(reg_q[r])
      );
   end
endgenerate


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) r0e_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[r0e_offset]),
      .scout(sov[r0e_offset]),
      .din(r0e),
      .dout(r0e_q)
   );

   tri_rlmreg_p #(.WIDTH(POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) r0a_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(r0e_e),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[r0a_offset:r0a_offset + POOL_ENC - 1]),
      .scout(sov[r0a_offset:r0a_offset + POOL_ENC - 1]),
      .din(r0a),
      .dout(r0a_q)
   );

   tri_rlmreg_p #(.WIDTH(WIDTH), .INIT(0), .NEEDS_SRESET(1)) r0d_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(r0e_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[r0d_offset:r0d_offset + WIDTH - 1]),
      .scout(sov[r0d_offset:r0d_offset + WIDTH - 1]),
      .din(r0d_d),
      .dout(r0d_q)
   );

   generate
      if (RD_PORTS > 1)
      begin : r1_gen1

         tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) r1e_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(1'b1),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[r1e_offset]),
            .scout(sov[r1e_offset]),
            .din(r1e),
            .dout(r1e_q)
         );

         tri_rlmreg_p #(.WIDTH(POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) r1a_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(r1e_e),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[r1a_offset:r1a_offset + POOL_ENC - 1]),
            .scout(sov[r1a_offset:r1a_offset + POOL_ENC - 1]),
            .din(r1a),
            .dout(r1a_q)
         );

         tri_rlmreg_p #(.WIDTH(WIDTH), .INIT(0), .NEEDS_SRESET(1)) r1d_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(r1e_q),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[r1d_offset:r1d_offset + WIDTH - 1]),
            .scout(sov[r1d_offset:r1d_offset + WIDTH - 1]),
            .din(r1d_d),
            .dout(r1d_q)
         );
      end
   endgenerate
   generate
      if (RD_PORTS > 2)
      begin : r2_gen1

         tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) r2e_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(1'b1),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[r2e_offset]),
            .scout(sov[r2e_offset]),
            .din(r2e),
            .dout(r2e_q)
         );

         tri_rlmreg_p #(.WIDTH(POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) r2a_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(r2e_e),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[r2a_offset:r2a_offset + POOL_ENC - 1]),
            .scout(sov[r2a_offset:r2a_offset + POOL_ENC - 1]),
            .din(r2a),
            .dout(r2a_q)
         );

         tri_rlmreg_p #(.WIDTH(WIDTH), .INIT(0), .NEEDS_SRESET(1)) r2d_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(r2e_q),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[r2d_offset:r2d_offset + WIDTH - 1]),
            .scout(sov[r2d_offset:r2d_offset + WIDTH - 1]),
            .din(r2d_d),
            .dout(r2d_q)
         );
      end
   endgenerate
   generate
      if (RD_PORTS > 3)
      begin : r3_gen1

         tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) r3e_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(1'b1),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[r3e_offset]),
            .scout(sov[r3e_offset]),
            .din(r3e),
            .dout(r3e_q)
         );

         tri_rlmreg_p #(.WIDTH(POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) r3a_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(r3e_e),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[r3a_offset:r3a_offset + POOL_ENC - 1]),
            .scout(sov[r3a_offset:r3a_offset + POOL_ENC - 1]),
            .din(r3a),
            .dout(r3a_q)
         );

         tri_rlmreg_p #(.WIDTH(WIDTH), .INIT(0), .NEEDS_SRESET(1)) r3d_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(r3e_q),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[r3d_offset:r3d_offset + WIDTH - 1]),
            .scout(sov[r3d_offset:r3d_offset + WIDTH - 1]),
            .din(r3d_d),
            .dout(r3d_q)
         );
      end
   endgenerate
   generate
      if (RD_PORTS > 4)
      begin : r4_gen1

         tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) r4e_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(1'b1),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[r4e_offset]),
            .scout(sov[r4e_offset]),
            .din(r4e),
            .dout(r4e_q)
         );

         tri_rlmreg_p #(.WIDTH(POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) r4a_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(r4e_e),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[r4a_offset:r4a_offset + POOL_ENC - 1]),
            .scout(sov[r4a_offset:r4a_offset + POOL_ENC - 1]),
            .din(r4a),
            .dout(r4a_q)
         );

         tri_rlmreg_p #(.WIDTH(WIDTH), .INIT(0), .NEEDS_SRESET(1)) r4d_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(r4e_q),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[r4d_offset:r4d_offset + WIDTH - 1]),
            .scout(sov[r4d_offset:r4d_offset + WIDTH - 1]),
            .din(r4d_d),
            .dout(r4d_q)
         );
      end
   endgenerate

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) w0e_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[w0e_offset]),
      .scout(sov[w0e_offset]),
      .din(w0e),
      .dout(w0e_q)
   );

   tri_rlmreg_p #(.WIDTH(POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) w0a_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(w0e_e),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[w0a_offset:w0a_offset + POOL_ENC - 1]),
      .scout(sov[w0a_offset:w0a_offset + POOL_ENC - 1]),
      .din(w0a),
      .dout(w0a_q)
   );

   tri_rlmreg_p #(.WIDTH(WIDTH), .INIT(0), .NEEDS_SRESET(1)) w0d_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(w0e_e),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[w0d_offset:w0d_offset + WIDTH - 1]),
      .scout(sov[w0d_offset:w0d_offset + WIDTH - 1]),
      .din(w0d),
      .dout(w0d_q)
   );
   generate
      if (WR_PORTS > 1)
      begin : w1_gen1

         tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) w1e_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(1'b1),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[w1e_offset]),
            .scout(sov[w1e_offset]),
            .din(w1e),
            .dout(w1e_q)
         );

         tri_rlmreg_p #(.WIDTH(POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) w1a_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(w1e_e),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[w1a_offset:w1a_offset + POOL_ENC - 1]),
            .scout(sov[w1a_offset:w1a_offset + POOL_ENC - 1]),
            .din(w1a),
            .dout(w1a_q)
         );

         tri_rlmreg_p #(.WIDTH(WIDTH), .INIT(0), .NEEDS_SRESET(1)) w1d_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(w1e_e),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[w1d_offset:w1d_offset + WIDTH - 1]),
            .scout(sov[w1d_offset:w1d_offset + WIDTH - 1]),
            .din(w1d),
            .dout(w1d_q)
         );
      end
   endgenerate
   generate
      if (WR_PORTS > 2)
      begin : w2_gen1

         tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) w2e_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(1'b1),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[w2e_offset]),
            .scout(sov[w2e_offset]),
            .din(w2e),
            .dout(w2e_q)
         );

         tri_rlmreg_p #(.WIDTH(POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) w2a_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(w2e_e),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[w2a_offset:w2a_offset + POOL_ENC - 1]),
            .scout(sov[w2a_offset:w2a_offset + POOL_ENC - 1]),
            .din(w2a),
            .dout(w2a_q)
         );

         tri_rlmreg_p #(.WIDTH(WIDTH), .INIT(0), .NEEDS_SRESET(1)) w2d_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(w2e_e),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[w2d_offset:w2d_offset + WIDTH - 1]),
            .scout(sov[w2d_offset:w2d_offset + WIDTH - 1]),
            .din(w2d),
            .dout(w2d_q)
         );
      end
   endgenerate
   generate
      if (WR_PORTS > 3)
      begin : w3_gen1

         tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) w3e_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(1'b1),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[w3e_offset]),
            .scout(sov[w3e_offset]),
            .din(w3e),
            .dout(w3e_q)
         );

         tri_rlmreg_p #(.WIDTH(POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) w3a_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(w3e_e),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[w3a_offset:w3a_offset + POOL_ENC - 1]),
            .scout(sov[w3a_offset:w3a_offset + POOL_ENC - 1]),
            .din(w3a),
            .dout(w3a_q)
         );

         tri_rlmreg_p #(.WIDTH(WIDTH), .INIT(0), .NEEDS_SRESET(1)) w3d_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(w3e_e),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[w3d_offset:w3d_offset + WIDTH - 1]),
            .scout(sov[w3d_offset:w3d_offset + WIDTH - 1]),
            .din(w3d),
            .dout(w3d_q)
         );
      end
   endgenerate
   generate
      if (WR_PORTS > 4)
      begin : w4_gen1

         tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) w4e_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(1'b1),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[w4e_offset]),
            .scout(sov[w4e_offset]),
            .din(w4e),
            .dout(w4e_q)
         );

         tri_rlmreg_p #(.WIDTH(POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) w4a_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(w4e_e),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[w4a_offset:w4a_offset + POOL_ENC - 1]),
            .scout(sov[w4a_offset:w4a_offset + POOL_ENC - 1]),
            .din(w4a),
            .dout(w4a_q)
         );

         tri_rlmreg_p #(.WIDTH(WIDTH), .INIT(0), .NEEDS_SRESET(1)) w4d_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(w4e_e),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[w4d_offset:w4d_offset + WIDTH - 1]),
            .scout(sov[w4d_offset:w4d_offset + WIDTH - 1]),
            .din(w4d),
            .dout(w4d_q)
         );
      end
   endgenerate

   generate
      if (RD_PORTS <= 1)
      begin : r1_gen0
         assign r1e_q = 0;
         assign r1a_q = 0;
         assign r1d_q = 0;
         assign unused[0] = (|r1d_d) | (|r1e) | (|r1a) | (|r1e_e) | (|r1e_q);
         end
   endgenerate
   generate
      if (RD_PORTS <= 2)
      begin : r2_gen0
         assign r2e_q = 0;
         assign r2a_q = 0;
         assign r2d_q = 0;
         assign unused[1] = (|r2d_d) | (|r2e) | (|r2a) | (|r2e_e) | (|r2e_q);
         end
   endgenerate
   generate
      if (RD_PORTS <= 3)
      begin : r3_gen0
         assign r3e_q = 0;
         assign r3a_q = 0;
         assign r3d_q = 0;
         assign unused[2] = (|r3d_d) | (|r3e) | (|r3a) | (|r3e_e) | (|r3e_q);
         end
   endgenerate
   generate
      if (RD_PORTS <= 4)
      begin : r4_gen0
         assign r4e_q = 0;
         assign r4a_q = 0;
         assign r4d_q = 0;
         assign unused[3] = (|r4d_d) | (|r4e) | (|r4a) | (|r4e_e) | (|r4e_q);
         end
      endgenerate

   generate
      if (WR_PORTS <= 1)
      begin : w1_gen0
         assign w1e_q = 0;
         assign w1a_q = 0;
         assign w1d_q = 0;
         assign unused[4]  = |w1e_e;
         end
   endgenerate
   generate
      if (WR_PORTS <= 2)
      begin : w2_gen0
         assign w2e_q = 0;
         assign w2a_q = 0;
         assign w2d_q = 0;
         assign unused[5]  = |w2e_e;
         end
   endgenerate
   generate
      if (WR_PORTS <= 3)
      begin : w3_gen0
         assign w3e_q = 0;
         assign w3a_q = 0;
         assign w3d_q = 0;
         assign unused[6]  = |w3e_e;
         end
   endgenerate
   generate
      if (WR_PORTS <= 4)
      begin : w4_gen0
         assign w4e_q = 0;
         assign w4a_q = 0;
         assign w4d_q = 0;
         assign unused[7]  = |w4e_e;
         end
   endgenerate

assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
assign scan_out = sov[0];

endmodule
