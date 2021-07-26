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

//
//  Description:  XU LSU L1 Data Directory Tag Array
//
//*****************************************************************************

// ##########################################################################################
// Tag Compare
// 1) Contains an Array of Tags
// 2) Updates Tag on Reload
// ##########################################################################################

`include "tri_a2o.vh"

module lq_dir_tag_arr(
   wdata,
   dir_arr_rd_data0,
   dir_arr_rd_data1,
   inj_ddir_p0_parity,
   inj_ddir_p1_parity,
   dir_arr_wr_data,
   p0_way_tag_a,
   p0_way_tag_b,
   p0_way_tag_c,
   p0_way_tag_d,
   p0_way_tag_e,
   p0_way_tag_f,
   p0_way_tag_g,
   p0_way_tag_h,
   p1_way_tag_a,
   p1_way_tag_b,
   p1_way_tag_c,
   p1_way_tag_d,
   p1_way_tag_e,
   p1_way_tag_f,
   p1_way_tag_g,
   p1_way_tag_h,
   p0_way_par_a,
   p0_way_par_b,
   p0_way_par_c,
   p0_way_par_d,
   p0_way_par_e,
   p0_way_par_f,
   p0_way_par_g,
   p0_way_par_h,
   p0_par_err_det_a,
   p0_par_err_det_b,
   p0_par_err_det_c,
   p0_par_err_det_d,
   p0_par_err_det_e,
   p0_par_err_det_f,
   p0_par_err_det_g,
   p0_par_err_det_h,
   p1_par_err_det_a,
   p1_par_err_det_b,
   p1_par_err_det_c,
   p1_par_err_det_d,
   p1_par_err_det_e,
   p1_par_err_det_f,
   p1_par_err_det_g,
   p1_par_err_det_h
);

//-------------------------------------------------------------------
// Generics
//-------------------------------------------------------------------
//parameter                                                    EXPAND_TYPE = 2;	     // 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
//parameter                                                   `DC_SIZE = 15;		     // 2^14 = 16384, 2^15 = 32768 Bytes L1 D$
//parameter                                                   `CL_SIZE = 6;		     // 2^6 = 64 Bytes CacheLines
//parameter                                                   `REAL_IFAR_WIDTH = 42;  // 42 bit real address
parameter                                                    WAYDATASIZE = 34;	    // TagSize + Parity Bits
parameter                                                    PARBITS = 4;		       // Parity Bits


// Write Path
input [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 wdata;

// Directory Array Read Data
input [0:(8*WAYDATASIZE)-1]                                 dir_arr_rd_data0;
input [0:(8*WAYDATASIZE)-1]                                 dir_arr_rd_data1;

// Parity Error Injection
input                                                       inj_ddir_p0_parity;
input                                                       inj_ddir_p1_parity;

// Directory Array Write Controls
output [64-`REAL_IFAR_WIDTH:64-`REAL_IFAR_WIDTH+WAYDATASIZE-1] dir_arr_wr_data;

// Way Tag Data
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p0_way_tag_a;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p0_way_tag_b;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p0_way_tag_c;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p0_way_tag_d;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p0_way_tag_e;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p0_way_tag_f;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p0_way_tag_g;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p0_way_tag_h;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p1_way_tag_a;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p1_way_tag_b;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p1_way_tag_c;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p1_way_tag_d;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p1_way_tag_e;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p1_way_tag_f;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p1_way_tag_g;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 p1_way_tag_h;

// Way Tag Parity
output [0:PARBITS-1]                                         p0_way_par_a;
output [0:PARBITS-1]                                         p0_way_par_b;
output [0:PARBITS-1]                                         p0_way_par_c;
output [0:PARBITS-1]                                         p0_way_par_d;
output [0:PARBITS-1]                                         p0_way_par_e;
output [0:PARBITS-1]                                         p0_way_par_f;
output [0:PARBITS-1]                                         p0_way_par_g;
output [0:PARBITS-1]                                         p0_way_par_h;

// Parity Error Detected
output                                                       p0_par_err_det_a;
output                                                       p0_par_err_det_b;
output                                                       p0_par_err_det_c;
output                                                       p0_par_err_det_d;
output                                                       p0_par_err_det_e;
output                                                       p0_par_err_det_f;
output                                                       p0_par_err_det_g;
output                                                       p0_par_err_det_h;
output                                                       p1_par_err_det_a;
output                                                       p1_par_err_det_b;
output                                                       p1_par_err_det_c;
output                                                       p1_par_err_det_d;
output                                                       p1_par_err_det_e;
output                                                       p1_par_err_det_f;
output                                                       p1_par_err_det_g;
output                                                       p1_par_err_det_h;

//--------------------------
// components
//--------------------------

//--------------------------
// constants
//--------------------------
parameter                                                    uprTagBit = 64 - `REAL_IFAR_WIDTH;
parameter                                                    lwrTagBit = 63 - (`DC_SIZE - 3);
parameter                                                    tagSize = lwrTagBit - uprTagBit + 1;
parameter                                                    numWays = 8;

//--------------------------
// signals
//--------------------------
wire [uprTagBit:lwrTagBit]                                   wr_data;
wire [uprTagBit:lwrTagBit]                                   p0_rd_way[0:numWays-1];
wire [uprTagBit:lwrTagBit]                                   p1_rd_way[0:numWays-1];
wire [0:(8*WAYDATASIZE)-1]                                   arr_rd_data0;
wire [0:(8*WAYDATASIZE)-1]                                   arr_rd_data1;
wire [0:PARBITS-1]                                           arr_parity;
wire [0:7]                                                   extra_byte_par;
wire [uprTagBit:lwrTagBit+PARBITS]                           arr_wr_data;
wire [0:PARBITS-1]                                           p0_rd_par_arr;
wire [0:PARBITS-1]                                           p1_rd_par_arr;
wire [0:PARBITS-1]                                           p0_rd_par[0:numWays-1];
wire [0:PARBITS-1]                                           p1_rd_par[0:numWays-1];
wire [0:7]                                                   p0_extra_tag_par[0:numWays-1];
wire [0:7]                                                   p1_extra_tag_par[0:numWays-1];
wire [0:PARBITS-1]                                           p0_par_err_det[0:numWays-1];
wire [0:PARBITS-1]                                           p1_par_err_det[0:numWays-1];

(* NO_MODIFICATION="TRUE" *)
wire [0:PARBITS-1]                                           p0_par_gen_1stlvla[0:numWays-1];

(* NO_MODIFICATION="TRUE" *)
wire [0:PARBITS-1]                                           p0_par_gen_1stlvlb[0:numWays-1];

(* NO_MODIFICATION="TRUE" *)
wire [0:PARBITS-1]                                           p0_par_gen_1stlvlc[0:numWays-1];

(* NO_MODIFICATION="TRUE" *)
wire [0:PARBITS-1]                                           p0_par_gen_1stlvld[0:numWays-1];

(* NO_MODIFICATION="TRUE" *)
wire [0:PARBITS-1]                                           p0_parity_gen_1b[0:numWays-1];

(* NO_MODIFICATION="TRUE" *)
wire [0:PARBITS-1]                                           p0_parity_gen_2b[0:numWays-1];

(* NO_MODIFICATION="TRUE" *)
wire [0:PARBITS-1]                                           p1_par_gen_1stlvla[0:numWays-1];

(* NO_MODIFICATION="TRUE" *)
wire [0:PARBITS-1]                                           p1_par_gen_1stlvlb[0:numWays-1];

(* NO_MODIFICATION="TRUE" *)
wire [0:PARBITS-1]                                           p1_par_gen_1stlvlc[0:numWays-1];

(* NO_MODIFICATION="TRUE" *)
wire [0:PARBITS-1]                                           p1_par_gen_1stlvld[0:numWays-1];

(* NO_MODIFICATION="TRUE" *)
wire [0:PARBITS-1]                                           p1_parity_gen_1b[0:numWays-1];

(* NO_MODIFICATION="TRUE" *)
wire [0:PARBITS-1]                                           p1_parity_gen_2b[0:numWays-1];

// ####################################################
// Inputs
// ####################################################

assign arr_rd_data0 = dir_arr_rd_data0;
assign arr_rd_data1 = dir_arr_rd_data1;
assign wr_data = wdata;

// ####################################################
// Array Parity Generation
// ####################################################

generate begin : extra_byte
      genvar                                                       t;
      for (t = 0; t <= 7; t = t + 1) begin : extra_byte
         if (t < (tagSize % 8)) begin : R0
            assign extra_byte_par[t] = wr_data[uprTagBit+(8*(tagSize/8)) + t];
         end
         if (t >= (tagSize % 8)) begin : R1
            assign extra_byte_par[t] = 1'b0;
         end
      end
   end
endgenerate

generate begin : par_gen
      genvar                                                       i;
      for (i = 0; i <= (tagSize/8) - 1; i = i + 1) begin : par_gen
         assign arr_parity[i] = ^(wr_data[8*i+uprTagBit:8*i+uprTagBit+7]);
      end
   end
endgenerate

generate
   if ((tagSize % 8) != 0) begin : par_gen_x
      assign arr_parity[tagSize/8] = ^(extra_byte_par);
   end
endgenerate

assign arr_wr_data = {wr_data, arr_parity};

// ####################################################
// Tag Array Read
// ####################################################

generate begin : tagRead
     genvar                                                       way;
     for (way=0; way<numWays; way=way+1) begin : tagRead
        assign p0_rd_way[way] = arr_rd_data0[(way*WAYDATASIZE):(way*WAYDATASIZE) + tagSize - 1];
        assign p1_rd_way[way] = arr_rd_data1[(way*WAYDATASIZE):(way*WAYDATASIZE) + tagSize - 1];
        if (way == 0) begin :injErr
           assign p0_rd_par_arr  = arr_rd_data0[(way*WAYDATASIZE) + tagSize:(way*WAYDATASIZE) + tagSize + PARBITS - 1];
           assign p0_rd_par[way] = {(p0_rd_par_arr[0] ^ inj_ddir_p0_parity), p0_rd_par_arr[1:PARBITS - 1]};
           assign p1_rd_par_arr  = arr_rd_data1[(way*WAYDATASIZE) + tagSize:(way*WAYDATASIZE) + tagSize + PARBITS - 1];
           assign p1_rd_par[way] = {(p1_rd_par_arr[0] ^ inj_ddir_p1_parity), p1_rd_par_arr[1:PARBITS - 1]};
        end
        if (way != 0) begin :noErr
           assign p0_rd_par[way] = arr_rd_data0[(way*WAYDATASIZE) + tagSize:(way*WAYDATASIZE) + tagSize + PARBITS - 1];
           assign p1_rd_par[way] = arr_rd_data1[(way*WAYDATASIZE) + tagSize:(way*WAYDATASIZE) + tagSize + PARBITS - 1];
        end
     end
   end
endgenerate

// ####################################################
// Tag Parity Generation
// ####################################################

generate begin : rdExtraByte
      genvar way;
      for (way=0; way<numWays; way=way+1) begin : rdExtraByte
         genvar                                                       t;
         for (t=0; t<8; t=t+1) begin : rdExtraByte
            if (t < (tagSize % 8)) begin : R0
               assign p0_extra_tag_par[way][t] = p0_rd_way[way][uprTagBit + (8 * (tagSize/8)) + t];
               assign p1_extra_tag_par[way][t] = p1_rd_way[way][uprTagBit + (8 * (tagSize/8)) + t];
            end
            if (t >= (tagSize % 8)) begin : R1
               assign p0_extra_tag_par[way][t] = 1'b0;
               assign p1_extra_tag_par[way][t] = 1'b0;
            end
         end
      end
   end
endgenerate

generate begin : rdParGen
      genvar way;
      for (way=0; way<numWays; way=way+1) begin : rdParGen
         genvar                                                       i;
         for (i = 0; i <= (tagSize/8) - 1; i = i + 1) begin : rdParGen
            // Port 0
            //assign p0_par_gen_1stlvla[way][i] = (~(p0_rd_way[way][8 * i + uprTagBit + 0] ^ p0_rd_way[way][8 * i + uprTagBit + 1]));
            tri_xnor2 p0_par_gen_1stlvla_0 (.y(p0_par_gen_1stlvla[way][i]), .a(p0_rd_way[way][8*i + uprTagBit+0]), .b(p0_rd_way[way][8*i + uprTagBit+1]));

            //assign p0_par_gen_1stlvlb[way][i] = (~(p0_rd_way[way][8 * i + uprTagBit + 2] ^ p0_rd_way[way][8 * i + uprTagBit + 3]));
            tri_xnor2 p0_par_gen_1stlvlb_0 (.y(p0_par_gen_1stlvlb[way][i]), .a(p0_rd_way[way][8*i + uprTagBit+2]), .b(p0_rd_way[way][8*i + uprTagBit+3]));

            //assign p0_par_gen_1stlvlc[way][i] = (~(p0_rd_way[way][8 * i + uprTagBit + 4] ^ p0_rd_way[way][8 * i + uprTagBit + 5]));
            tri_xnor2 p0_par_gen_1stlvlc_0 (.y(p0_par_gen_1stlvlc[way][i]), .a(p0_rd_way[way][8*i + uprTagBit+4]), .b(p0_rd_way[way][8*i + uprTagBit+5]));

            //assign p0_par_gen_1stlvld[way][i] = (~(p0_rd_way[way][8 * i + uprTagBit + 6] ^ p0_rd_way[way][8 * i + uprTagBit + 7]));
            tri_xnor2 p0_par_gen_1stlvld_0 (.y(p0_par_gen_1stlvld[way][i]), .a(p0_rd_way[way][8*i + uprTagBit+6]), .b(p0_rd_way[way][8*i + uprTagBit+7]));

            //assign p0_parity_gen_1b[way][i]   = (~(p0_par_gen_1stlvla[way][i] ^ p0_par_gen_1stlvlb[way][i]));
            tri_xnor2 p0_parity_gen_1b_0 (.y(p0_parity_gen_1b[way][i]), .a(p0_par_gen_1stlvla[way][i]), .b(p0_par_gen_1stlvlb[way][i]));

            //assign p0_parity_gen_2b[way][i]   = (~(p0_par_gen_1stlvlc[way][i] ^ p0_par_gen_1stlvld[way][i]));
            tri_xnor2 p0_parity_gen_2b_0 (.y(p0_parity_gen_2b[way][i]), .a(p0_par_gen_1stlvlc[way][i]), .b(p0_par_gen_1stlvld[way][i]));

            // Port 1
            //assign p1_par_gen_1stlvla[way][i] = (~(p1_rd_way[way][8 * i + uprTagBit + 0] ^ p1_rd_way[way][8 * i + uprTagBit + 1]));
            tri_xnor2 p1_par_gen_1stlvla_0 (.y(p1_par_gen_1stlvla[way][i]), .a(p1_rd_way[way][8*i + uprTagBit+0]), .b(p1_rd_way[way][8*i + uprTagBit+1]));

            //assign p1_par_gen_1stlvlb[way][i] = (~(p1_rd_way[way][8 * i + uprTagBit + 2] ^ p1_rd_way[way][8 * i + uprTagBit + 3]));
            tri_xnor2 p1_par_gen_1stlvlb_0 (.y(p1_par_gen_1stlvlb[way][i]), .a(p1_rd_way[way][8*i + uprTagBit+2]), .b(p1_rd_way[way][8*i + uprTagBit+3]));

            //assign p1_par_gen_1stlvlc[way][i] = (~(p1_rd_way[way][8 * i + uprTagBit + 4] ^ p1_rd_way[way][8 * i + uprTagBit + 5]));
            tri_xnor2 p1_par_gen_1stlvlc_0 (.y(p1_par_gen_1stlvlc[way][i]), .a(p1_rd_way[way][8*i + uprTagBit+4]), .b(p1_rd_way[way][8*i + uprTagBit+5]));

            //assign p1_par_gen_1stlvld[way][i] = (~(p1_rd_way[way][8 * i + uprTagBit + 6] ^ p1_rd_way[way][8 * i + uprTagBit + 7]));
            tri_xnor2 p1_par_gen_1stlvld_0 (.y(p1_par_gen_1stlvld[way][i]), .a(p1_rd_way[way][8*i + uprTagBit+6]), .b(p1_rd_way[way][8*i + uprTagBit+7]));

            //assign p1_parity_gen_1b[way][i]   = (~(p1_par_gen_1stlvla[way][i] ^ p1_par_gen_1stlvlb[way][i]));
            tri_xnor2 p1_parity_gen_1b_0 (.y(p1_parity_gen_1b[way][i]), .a(p1_par_gen_1stlvla[way][i]), .b(p1_par_gen_1stlvlb[way][i]));

            //assign p1_parity_gen_2b[way][i]   = (~(p1_par_gen_1stlvlc[way][i] ^ p1_par_gen_1stlvld[way][i]));
            tri_xnor2 p1_parity_gen_2b_0 (.y(p1_parity_gen_2b[way][i]), .a(p1_par_gen_1stlvlc[way][i]), .b(p1_par_gen_1stlvld[way][i]));
         end
      end
   end
endgenerate

generate
   if ((tagSize % 8) != 0) begin : rdParGenx
      genvar            way;
      for (way=0; way<numWays; way=way+1) begin : rdParGenx

         // Port 0
         assign p0_par_gen_1stlvla[way][PARBITS - 1] = (~(p0_extra_tag_par[way][0] ^ p0_extra_tag_par[way][1]));
         assign p0_par_gen_1stlvlb[way][PARBITS - 1] = (~(p0_extra_tag_par[way][2] ^ p0_extra_tag_par[way][3]));
         assign p0_par_gen_1stlvlc[way][PARBITS - 1] = (~(p0_extra_tag_par[way][4] ^ p0_extra_tag_par[way][5]));
         assign p0_par_gen_1stlvld[way][PARBITS - 1] = (~(p0_extra_tag_par[way][6] ^ p0_extra_tag_par[way][7]));
         assign p0_parity_gen_1b[way][PARBITS - 1]   = (~(p0_par_gen_1stlvla[way][PARBITS - 1] ^ p0_par_gen_1stlvlb[way][PARBITS - 1]));
         assign p0_parity_gen_2b[way][PARBITS - 1]   = (~(p0_par_gen_1stlvlc[way][PARBITS - 1] ^ p0_par_gen_1stlvld[way][PARBITS - 1]));

         // Port 1
         assign p1_par_gen_1stlvla[way][PARBITS - 1] = (~(p1_extra_tag_par[way][0] ^ p1_extra_tag_par[way][1]));
         assign p1_par_gen_1stlvlb[way][PARBITS - 1] = (~(p1_extra_tag_par[way][2] ^ p1_extra_tag_par[way][3]));
         assign p1_par_gen_1stlvlc[way][PARBITS - 1] = (~(p1_extra_tag_par[way][4] ^ p1_extra_tag_par[way][5]));
         assign p1_par_gen_1stlvld[way][PARBITS - 1] = (~(p1_extra_tag_par[way][6] ^ p1_extra_tag_par[way][7]));
         assign p1_parity_gen_1b[way][PARBITS - 1]   = (~(p1_par_gen_1stlvla[way][PARBITS - 1] ^ p1_par_gen_1stlvlb[way][PARBITS - 1]));
         assign p1_parity_gen_2b[way][PARBITS - 1]   = (~(p1_par_gen_1stlvlc[way][PARBITS - 1] ^ p1_par_gen_1stlvld[way][PARBITS - 1]));
       end
   end
endgenerate

// ####################################################
// Parity Error Detect
// ####################################################

generate begin : parDet
     genvar                                                       way;
     for (way=0; way<numWays; way=way+1) begin : parDet
        assign p0_par_err_det[way] = p0_parity_gen_1b[way] ^ p0_parity_gen_2b[way] ^ p0_rd_par[way];
        assign p1_par_err_det[way] = p1_parity_gen_1b[way] ^ p1_parity_gen_2b[way] ^ p1_rd_par[way];
     end
   end
endgenerate

// ####################################################
// Outputs
// ####################################################

// Directory Array Write Data
assign dir_arr_wr_data = arr_wr_data;

// Directory Array Read Tags
assign p0_way_tag_a = p0_rd_way[0];
assign p0_way_tag_b = p0_rd_way[1];
assign p0_way_tag_c = p0_rd_way[2];
assign p0_way_tag_d = p0_rd_way[3];
assign p0_way_tag_e = p0_rd_way[4];
assign p0_way_tag_f = p0_rd_way[5];
assign p0_way_tag_g = p0_rd_way[6];
assign p0_way_tag_h = p0_rd_way[7];
assign p1_way_tag_a = p1_rd_way[0];
assign p1_way_tag_b = p1_rd_way[1];
assign p1_way_tag_c = p1_rd_way[2];
assign p1_way_tag_d = p1_rd_way[3];
assign p1_way_tag_e = p1_rd_way[4];
assign p1_way_tag_f = p1_rd_way[5];
assign p1_way_tag_g = p1_rd_way[6];
assign p1_way_tag_h = p1_rd_way[7];

// Directory Array Read Parity
assign p0_way_par_a = p0_rd_par[0];
assign p0_way_par_b = p0_rd_par[1];
assign p0_way_par_c = p0_rd_par[2];
assign p0_way_par_d = p0_rd_par[3];
assign p0_way_par_e = p0_rd_par[4];
assign p0_way_par_f = p0_rd_par[5];
assign p0_way_par_g = p0_rd_par[6];
assign p0_way_par_h = p0_rd_par[7];

// Directory Parity Error Detected
assign p0_par_err_det_a = |(p0_par_err_det[0]);
assign p0_par_err_det_b = |(p0_par_err_det[1]);
assign p0_par_err_det_c = |(p0_par_err_det[2]);
assign p0_par_err_det_d = |(p0_par_err_det[3]);
assign p0_par_err_det_e = |(p0_par_err_det[4]);
assign p0_par_err_det_f = |(p0_par_err_det[5]);
assign p0_par_err_det_g = |(p0_par_err_det[6]);
assign p0_par_err_det_h = |(p0_par_err_det[7]);
assign p1_par_err_det_a = |(p1_par_err_det[0]);
assign p1_par_err_det_b = |(p1_par_err_det[1]);
assign p1_par_err_det_c = |(p1_par_err_det[2]);
assign p1_par_err_det_d = |(p1_par_err_det[3]);
assign p1_par_err_det_e = |(p1_par_err_det[4]);
assign p1_par_err_det_f = |(p1_par_err_det[5]);
assign p1_par_err_det_g = |(p1_par_err_det[6]);
assign p1_par_err_det_h = |(p1_par_err_det[7]);

endmodule
