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

//*****************************************************************************
//  Description:  Tri-Lam Array Wrapper
//
//*****************************************************************************

`include "tri_a2o.vh"

module tri_144x78_2r4w(
   // Inputs
   // Power
   inout                    vdd,
   inout                    gnd,
   // Clock & Scan
   input [0:`NCLK_WIDTH-1]  nclk,

   //-------------------------------------------------------------------
   // Pervasive
   //-------------------------------------------------------------------
   input                    delay_lclkr_dc,
   input                    mpw1_dc_b,
   input                    mpw2_dc_b,
   input                    func_sl_force,
   input                    func_sl_thold_0_b,
   input                    func_slp_sl_force,
   input                    func_slp_sl_thold_0_b,
   input                    sg_0,
   input                    scan_in,
   output                   scan_out,

   //-------------------------------------------------------------------
   // Read Port
   //-------------------------------------------------------------------
   input                     r_late_en_1,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1] r_addr_in_1,
   output [64-`GPR_WIDTH:77] r_data_out_1,
   input                     r_late_en_2,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1] r_addr_in_2,
   output [64-`GPR_WIDTH:77] r_data_out_2,

   //-------------------------------------------------------------------
   // Write Port
   //-------------------------------------------------------------------
   input                     w_late_en_1,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1] w_addr_in_1,
   input [64-`GPR_WIDTH:77]  w_data_in_1,
   input                     w_late_en_2,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1] w_addr_in_2,
   input [64-`GPR_WIDTH:77]  w_data_in_2,
   input                     w_late_en_3,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1] w_addr_in_3,
   input [64-`GPR_WIDTH:77]  w_data_in_3,
   input                     w_late_en_4,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1] w_addr_in_4,
   input [64-`GPR_WIDTH:77]  w_data_in_4
);

   // Configuration Statement for NCsim
   //for all:RAM64X1D use entity unisim.RAM64X1D;

   parameter                tiup = 1'b1;
   parameter                tidn = 1'b0;

   //-------------------------------------------------------------------
   // Signals
   //-------------------------------------------------------------------
   reg                       write_en;
   reg [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]   write_addr;
   reg [64-`GPR_WIDTH:77]    write_data;
   wire [0:(`GPR_POOL*`THREADS-1)/64] write_en_arr;
   wire [0:5]                write_addr_arr;
   wire [0:1]                wr_mux_ctrl;

   //-------------------------------------------------------------------
   // Latch Signals
   //-------------------------------------------------------------------
   wire                      w1e_q;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  w1a_q;
   wire [64-`GPR_WIDTH:77]   w1d_q;
   wire                      w2e_q;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  w2a_q;
   wire [64-`GPR_WIDTH:77]   w2d_q;
   wire                      w3e_q;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  w3a_q;
   wire [64-`GPR_WIDTH:77]   w3d_q;
   wire                      w4e_q;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  w4a_q;
   wire [64-`GPR_WIDTH:77]   w4d_q;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  r1a_q;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  r2a_q;
   wire [0:5]                read1_addr_arr;
   wire [0:5]                read2_addr_arr;
   wire [0:(`GPR_POOL*`THREADS-1)/64] read1_en_arr;
   wire [0:(`GPR_POOL*`THREADS-1)/64] read2_en_arr;
   reg [64-`GPR_WIDTH:77]    read1_data;
   reg [64-`GPR_WIDTH:77]    read2_data;
   wire [64-`GPR_WIDTH:77]   r1d_array[0:(`GPR_POOL*`THREADS-1)/64];
   wire [64-`GPR_WIDTH:77]   r2d_array[0:(`GPR_POOL*`THREADS-1)/64];
   wire [64-`GPR_WIDTH:77]   r1d_d;
   wire [64-`GPR_WIDTH:77]   r2d_d;
   wire [64-`GPR_WIDTH:77]   r1d_q;
   wire [64-`GPR_WIDTH:77]   r2d_q;

    (* analysis_not_referenced="true" *)
   wire                      unused;
   wire [64-`GPR_WIDTH:77]   unused_port;
   wire [64-`GPR_WIDTH:77]   unused_port2;

   //-------------------------------------------------------------------
   // Scanchain
   //-------------------------------------------------------------------
   parameter                w1e_offset = 0;
   parameter                w1a_offset = w1e_offset + 1;
   parameter                w1d_offset = w1a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC;
   parameter                w2e_offset = w1d_offset + (`GPR_WIDTH+14);
   parameter                w2a_offset = w2e_offset + 1;
   parameter                w2d_offset = w2a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC;
   parameter                w3e_offset = w2d_offset + (`GPR_WIDTH+14);
   parameter                w3a_offset = w3e_offset + 1;
   parameter                w3d_offset = w3a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC;
   parameter                w4e_offset = w3d_offset + (`GPR_WIDTH+14);
   parameter                w4a_offset = w4e_offset + 1;
   parameter                w4d_offset = w4a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC;
   parameter                r1a_offset = w4d_offset + (`GPR_WIDTH+14);
   parameter                r2a_offset = r1a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC;
   parameter                r1d_offset = r2a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC;
   parameter                r2d_offset = r1d_offset + (`GPR_WIDTH+14);
   parameter                scan_right = r2d_offset + (`GPR_WIDTH+14);
   wire [0:scan_right-1]    siv;
   wire [0:scan_right-1]    sov;

   generate
   begin

     // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
     // Read Control
     // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
     // BYPASS

     assign r1d_d = read1_data;

     assign r2d_d = read2_data;

     assign r_data_out_1 = r1d_q;
     assign r_data_out_2 = r2d_q;

     // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
     // Write Control
     // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
     assign wr_mux_ctrl = {nclk[0], nclk[2]};

     always @ ( * )
     begin
       write_addr <= #10 ((wr_mux_ctrl == 2'b00) ? w_addr_in_1 :
                        (wr_mux_ctrl == 2'b01) ? w_addr_in_2 :
                        (wr_mux_ctrl == 2'b10) ? w_addr_in_3 :
                                                 w_addr_in_4);

       write_en <= #10 ((wr_mux_ctrl == 2'b00) ? w_late_en_1 :
                      (wr_mux_ctrl == 2'b01) ? w_late_en_2 :
                      (wr_mux_ctrl == 2'b10) ? w_late_en_3 :
                                               w_late_en_4);

       // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
       // Depth Control
       // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

       write_data <= #10 ((wr_mux_ctrl == 2'b00) ? w_data_in_1 :
                        (wr_mux_ctrl == 2'b01) ? w_data_in_2 :
                        (wr_mux_ctrl == 2'b10) ? w_data_in_3 :
                                                 w_data_in_4);
     end

     if (((`GPR_POOL*`THREADS - 1)/64) == 0)
     begin : depth1
       if (`GPR_POOL_ENC+`THREADS_POOL_ENC < 6)
       begin
         assign write_addr_arr[0:(6 - `GPR_POOL_ENC+`THREADS_POOL_ENC) - 1] = {6-`GPR_POOL_ENC+`THREADS_POOL_ENC{1'b0}};
         assign read1_addr_arr[0:(6 - `GPR_POOL_ENC+`THREADS_POOL_ENC) - 1] = {6-`GPR_POOL_ENC+`THREADS_POOL_ENC{1'b0}};
         assign read2_addr_arr[0:(6 - `GPR_POOL_ENC+`THREADS_POOL_ENC) - 1] = {6-`GPR_POOL_ENC+`THREADS_POOL_ENC{1'b0}};
       end

       assign write_addr_arr[6 - `GPR_POOL_ENC+`THREADS_POOL_ENC:5] = write_addr;
       assign read1_addr_arr[6 - `GPR_POOL_ENC+`THREADS_POOL_ENC:5] = r1a_q;
       assign read2_addr_arr[6 - `GPR_POOL_ENC+`THREADS_POOL_ENC:5] = r2a_q;
       assign write_en_arr[0] = write_en;
       assign read1_en_arr[0] = 1'b1;
       assign read2_en_arr[0] = 1'b1;
     end

     if (((`GPR_POOL*`THREADS - 1)/64) != 0)
     begin : depthMulti
       assign write_addr_arr = write_addr[`GPR_POOL_ENC+`THREADS_POOL_ENC - 6:`GPR_POOL_ENC+`THREADS_POOL_ENC - 1];
       assign read1_addr_arr = r1a_q[`GPR_POOL_ENC+`THREADS_POOL_ENC - 6:`GPR_POOL_ENC+`THREADS_POOL_ENC - 1];
       assign read2_addr_arr = r2a_q[`GPR_POOL_ENC+`THREADS_POOL_ENC - 6:`GPR_POOL_ENC+`THREADS_POOL_ENC - 1];

       genvar  wen;
       for (wen = 0; wen <= ((`GPR_POOL*`THREADS - 1)/64); wen = wen + 1)
       begin : wrenGen
         wire wen_match = wen;
         assign write_en_arr[wen] = write_en & (write_addr[0:(`GPR_POOL_ENC+`THREADS_POOL_ENC - 6) - 1] == wen_match);
         assign read1_en_arr[wen] = r1a_q[0:(`GPR_POOL_ENC+`THREADS_POOL_ENC - 6) - 1] == wen_match;
         assign read2_en_arr[wen] = r2a_q[0:(`GPR_POOL_ENC+`THREADS_POOL_ENC - 6) - 1] == wen_match;
       end
     end

     always @( * )
     begin: rdDataMux
       reg [64-`GPR_WIDTH:77]      rd1_data;
       reg [64-`GPR_WIDTH:77]      rd2_data;
       (* analysis_not_referenced="true" *)
       integer                     rdArr;
       rd1_data = {`GPR_WIDTH+14{1'b0}};
       rd2_data = {`GPR_WIDTH+14{1'b0}};

       for (rdArr = 0; rdArr <= ((`GPR_POOL*`THREADS - 1)/64); rdArr = rdArr + 1)
       begin
         rd1_data = (r1d_array[rdArr] & {`GPR_WIDTH+14{read1_en_arr[rdArr]}}) | rd1_data;
         rd2_data = (r2d_array[rdArr] & {`GPR_WIDTH+14{read2_en_arr[rdArr]}}) | rd2_data;
       end
       read1_data <= rd1_data;
       read2_data <= rd2_data;
     end

     genvar  depth;
     for (depth = 0; depth <= ((`GPR_POOL*`THREADS - 1)/64); depth = depth + 1)
     begin : depth_loop
       genvar  i;
       for (i = 64 - `GPR_WIDTH; i < 78; i = i + 1)
       begin : r1
         RAM64X1D #(.INIT(64'h0000000000000000)) RAM64X1D_1(
                  .SPO(unused_port[i]),
                  .DPO(r1d_array[depth][i]),		// Port A 1-bit data output
                  .A0(write_addr_arr[5]),		// Port A - Write Address (A0-A5)
                  .A1(write_addr_arr[4]),
                  .A2(write_addr_arr[3]),
                  .A3(write_addr_arr[2]),
                  .A4(write_addr_arr[1]),
                  .A5(write_addr_arr[0]),
                  .D(write_data[i]),                    // Port A 1-bit data input
                  .DPRA0(read1_addr_arr[5]),		// Port B - Read Address (DPRA0-DPRA5)
                  .DPRA1(read1_addr_arr[4]),
                  .DPRA2(read1_addr_arr[3]),
                  .DPRA3(read1_addr_arr[2]),
                  .DPRA4(read1_addr_arr[1]),
                  .DPRA5(read1_addr_arr[0]),
                  .WCLK(nclk[3]),                       // Port A write clock input : clk4x
                  .WE(write_en_arr[depth])		// Port A write enable input
               );
       end

       //genvar  i;
       for (i = 64 - `GPR_WIDTH; i < 78; i = i + 1)
       begin : r2
         RAM64X1D #(.INIT(64'h0000000000000000)) RAM64X1D_2(
                  .SPO(unused_port2[i]),
                  .DPO(r2d_array[depth][i]),		// Port A 1-bit data output
                  .A0(write_addr_arr[5]),		// Port A - Write Address (A0-A5)
                  .A1(write_addr_arr[4]),
                  .A2(write_addr_arr[3]),
                  .A3(write_addr_arr[2]),
                  .A4(write_addr_arr[1]),
                  .A5(write_addr_arr[0]),
                  .D(write_data[i]),		// Port A 1-bit data input
                  .DPRA0(read2_addr_arr[5]),		// Port B - Read Address (DPRA0-DPRA5)
                  .DPRA1(read2_addr_arr[4]),
                  .DPRA2(read2_addr_arr[3]),
                  .DPRA3(read2_addr_arr[2]),
                  .DPRA4(read2_addr_arr[1]),
                  .DPRA5(read2_addr_arr[0]),
                  .WCLK(nclk[3]),		// Port A write clock input : clk4x
                  .WE(write_en_arr[depth])		// Port A write enable input
               );
       end
     end
   end
   endgenerate

   //----------------------------------------------------------------------------------------------------------------------------------------
   // Latches
   //----------------------------------------------------------------------------------------------------------------------------------------

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) w1e_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[w1e_offset]),
      .scout(sov[w1e_offset]),
      .din(w_late_en_1),
      .dout(w1e_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC+`THREADS_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) w1a_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[w1a_offset:w1a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC - 1]),
      .scout(sov[w1a_offset:w1a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC - 1]),
      .din(w_addr_in_1),
      .dout(w1a_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH+14), .INIT(0), .NEEDS_SRESET(1)) w1d_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[w1d_offset:w1d_offset + `GPR_WIDTH+14 - 1]),
      .scout(sov[w1d_offset:w1d_offset + `GPR_WIDTH+14 - 1]),
      .din(w_data_in_1[64 - `GPR_WIDTH:77]),
      .dout(w1d_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) w2e_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[w2e_offset]),
      .scout(sov[w2e_offset]),
      .din(w_late_en_2),
      .dout(w2e_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC+`THREADS_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) w2a_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[w2a_offset:w2a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC - 1]),
      .scout(sov[w2a_offset:w2a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC - 1]),
      .din(w_addr_in_2),
      .dout(w2a_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH+14), .INIT(0), .NEEDS_SRESET(1)) w2d_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[w2d_offset:w2d_offset + `GPR_WIDTH+14 - 1]),
      .scout(sov[w2d_offset:w2d_offset + `GPR_WIDTH+14 - 1]),
      .din(w_data_in_2[64 - `GPR_WIDTH:77]),
      .dout(w2d_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) w3e_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[w3e_offset]),
      .scout(sov[w3e_offset]),
      .din(w_late_en_3),
      .dout(w3e_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC+`THREADS_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) w3a_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[w3a_offset:w3a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC - 1]),
      .scout(sov[w3a_offset:w3a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC - 1]),
      .din(w_addr_in_3),
      .dout(w3a_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH+14), .INIT(0), .NEEDS_SRESET(1)) w3d_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[w3d_offset:w3d_offset + `GPR_WIDTH+14 - 1]),
      .scout(sov[w3d_offset:w3d_offset + `GPR_WIDTH+14 - 1]),
      .din(w_data_in_3[64 - `GPR_WIDTH:77]),
      .dout(w3d_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) w4e_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[w4e_offset]),
      .scout(sov[w4e_offset]),
      .din(w_late_en_4),
      .dout(w4e_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC+`THREADS_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) w4a_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[w4a_offset:w4a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC - 1]),
      .scout(sov[w4a_offset:w4a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC - 1]),
      .din(w_addr_in_4),
      .dout(w4a_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH+14), .INIT(0), .NEEDS_SRESET(1)) w4d_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[w4d_offset:w4d_offset + `GPR_WIDTH+14 - 1]),
      .scout(sov[w4d_offset:w4d_offset + `GPR_WIDTH+14 - 1]),
      .din(w_data_in_4[64 - `GPR_WIDTH:77]),
      .dout(w4d_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC+`THREADS_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) r1a_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[r1a_offset:r1a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC - 1]),
      .scout(sov[r1a_offset:r1a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC - 1]),
      .din(r_addr_in_1),
      .dout(r1a_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC+`THREADS_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) r2a_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[r2a_offset:r2a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC - 1]),
      .scout(sov[r2a_offset:r2a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC - 1]),
      .din(r_addr_in_2),
      .dout(r2a_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH+14), .INIT(0), .NEEDS_SRESET(1)) r1d_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[r1d_offset:r1d_offset + `GPR_WIDTH+14 - 1]),
      .scout(sov[r1d_offset:r1d_offset + `GPR_WIDTH+14 - 1]),
      .din(r1d_d),
      .dout(r1d_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH+14), .INIT(0), .NEEDS_SRESET(1)) r2d_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .d_mode(1'b0),
      .sg(sg_0),
      .scin(siv[r2d_offset:r2d_offset + `GPR_WIDTH+14 - 1]),
      .scout(sov[r2d_offset:r2d_offset + `GPR_WIDTH+14 - 1]),
      .din(r2d_d),
      .dout(r2d_q)
   );

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];

   assign unused = | {unused_port, unused_port2, func_slp_sl_force, func_slp_sl_thold_0_b};
endmodule
