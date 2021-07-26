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

//********************************************************************
//*
//* TITLE:
//*
//* NAME: iuq_rn_map.v
//*
//*********************************************************************

`include "tri_a2o.vh"


module iuq_rn_map #(
   parameter                                                   ARCHITECTED_REGISTER_DEPTH = 36,
   parameter                                                   REGISTER_RENAME_DEPTH = 64,
   parameter                                                   STORAGE_WIDTH = 6)
   (
   inout                                                       vdd,
   inout                                                       gnd,
   input [0:`NCLK_WIDTH-1]                                     nclk,
   input                                                       pc_iu_func_sl_thold_0_b,		// acts as reset for non-ibm types
   input                                                       pc_iu_sg_0,
   input                                                       force_t,
   input                                                       d_mode,
   input                                                       delay_lclkr,
   input                                                       mpw1_b,
   input                                                       mpw2_b,
   input                                                       func_scan_in,
   output                                                      func_scan_out,

   input                                                       take_a,
   input                                                       take_b,
   output                                                      next_reg_a_val,
   output reg [0:STORAGE_WIDTH-1]                              next_reg_a,
   output                                                      next_reg_b_val,
   output reg [0:STORAGE_WIDTH-1]                              next_reg_b,

   input [0:STORAGE_WIDTH-1]                                   src1_a,
   output reg [0:STORAGE_WIDTH-1]                              src1_p,
   output reg [0:`ITAG_SIZE_ENC-1]                             src1_itag,
   input [0:STORAGE_WIDTH-1]                                   src2_a,
   output reg [0:STORAGE_WIDTH-1]                              src2_p,
   output reg [0:`ITAG_SIZE_ENC-1]                             src2_itag,
   input [0:STORAGE_WIDTH-1]                                   src3_a,
   output reg [0:STORAGE_WIDTH-1]                              src3_p,
   output reg [0:`ITAG_SIZE_ENC-1]                             src3_itag,
   input [0:STORAGE_WIDTH-1]                                   src4_a,
   output [0:STORAGE_WIDTH-1]                                  src4_p,
   output [0:`ITAG_SIZE_ENC-1]                                 src4_itag,
   input [0:STORAGE_WIDTH-1]                                   src5_a,
   output [0:STORAGE_WIDTH-1]                                  src5_p,
   output [0:`ITAG_SIZE_ENC-1]                                 src5_itag,
   input [0:STORAGE_WIDTH-1]                                   src6_a,
   output [0:STORAGE_WIDTH-1]                                  src6_p,
   output [0:`ITAG_SIZE_ENC-1]                                 src6_itag,

   input                                                       comp_0_wr_val,
   input [0:STORAGE_WIDTH-1]                                   comp_0_wr_arc,
   input [0:STORAGE_WIDTH-1]                                   comp_0_wr_rename,
   input [0:`ITAG_SIZE_ENC-1]                                  comp_0_wr_itag,

   input                                                       comp_1_wr_val,
   input [0:STORAGE_WIDTH-1]                                   comp_1_wr_arc,
   input [0:STORAGE_WIDTH-1]                                   comp_1_wr_rename,
   input [0:`ITAG_SIZE_ENC-1]                                  comp_1_wr_itag,

   input                                                       spec_0_wr_val,
   input                                                       spec_0_wr_val_fast,
   input [0:STORAGE_WIDTH-1]                                   spec_0_wr_arc,
   input [0:STORAGE_WIDTH-1]                                   spec_0_wr_rename,
   input [0:`ITAG_SIZE_ENC-1]                                  spec_0_wr_itag,

   input                                                       spec_1_dep_hit_s1,
   input                                                       spec_1_dep_hit_s2,
   input                                                       spec_1_dep_hit_s3,
   input                                                       spec_1_wr_val,
   input                                                       spec_1_wr_val_fast,
   input [0:STORAGE_WIDTH-1]                                   spec_1_wr_arc,
   input [0:STORAGE_WIDTH-1]                                   spec_1_wr_rename,
   input [0:`ITAG_SIZE_ENC-1]                                  spec_1_wr_itag,

   input                                                       flush_map
   );

   localparam [0:31]                                           value_1 = 32'h00000001;
   localparam [0:31]                                           value_2 = 32'h00000002;

   parameter                                                   comp_map_offset = 0;
   parameter                                                   spec_map_arc_offset = comp_map_offset + STORAGE_WIDTH * ARCHITECTED_REGISTER_DEPTH;
   parameter                                                   spec_map_itag_offset = spec_map_arc_offset + STORAGE_WIDTH * ARCHITECTED_REGISTER_DEPTH;
   parameter                                                   buffer_pool_offset = spec_map_itag_offset + `ITAG_SIZE_ENC * ARCHITECTED_REGISTER_DEPTH;
   parameter                                                   read_ptr_offset = buffer_pool_offset + (REGISTER_RENAME_DEPTH - ARCHITECTED_REGISTER_DEPTH) * STORAGE_WIDTH;
   parameter                                                   write_ptr_offset = read_ptr_offset + STORAGE_WIDTH;
   parameter                                                   free_cnt_offset = write_ptr_offset + STORAGE_WIDTH;
   parameter                                                   pool_free_0_v_offset = free_cnt_offset + STORAGE_WIDTH;
   parameter                                                   pool_free_0_offset = pool_free_0_v_offset + 1;
   parameter                                                   pool_free_1_v_offset = pool_free_0_offset + STORAGE_WIDTH;
   parameter                                                   pool_free_1_offset = pool_free_1_v_offset + 1;
   parameter                                                   scan_right = pool_free_1_offset + STORAGE_WIDTH - 1;

   // scan
   wire [0:scan_right]                                         siv;
   wire [0:scan_right]                                         sov;

   wire                                                        tidn;
   wire                                                        tiup;

   wire                                                        comp_map_act;
   reg [0:STORAGE_WIDTH-1]                                     comp_map_d[0:ARCHITECTED_REGISTER_DEPTH-1];
   wire [0:STORAGE_WIDTH-1]                                    comp_map_l2[0:ARCHITECTED_REGISTER_DEPTH-1];
   wire                                                        spec_map_arc_act;
   reg [0:STORAGE_WIDTH-1]                                     spec_map_arc_d[0:ARCHITECTED_REGISTER_DEPTH-1];
   wire [0:STORAGE_WIDTH-1]                                    spec_map_arc_l2[0:ARCHITECTED_REGISTER_DEPTH-1];
   wire                                                        spec_map_itag_act;
   reg [0:`ITAG_SIZE_ENC-1]                                    spec_map_itag_d[0:ARCHITECTED_REGISTER_DEPTH-1];
   wire [0:`ITAG_SIZE_ENC-1]                                   spec_map_itag_l2[0:ARCHITECTED_REGISTER_DEPTH-1];
   reg  [0:REGISTER_RENAME_DEPTH-ARCHITECTED_REGISTER_DEPTH-1] buffer_pool_act;
   reg  [0:STORAGE_WIDTH-1]                                    buffer_pool_d[0:REGISTER_RENAME_DEPTH-ARCHITECTED_REGISTER_DEPTH-1];
   wire [0:STORAGE_WIDTH-1]                                    buffer_pool_l2[0:REGISTER_RENAME_DEPTH-ARCHITECTED_REGISTER_DEPTH-1];

   wire                                                        read_ptr_act;
   wire [0:STORAGE_WIDTH-1]                                    read_ptr_d;
   wire [0:STORAGE_WIDTH-1]                                    read_ptr_l2;
   wire [0:STORAGE_WIDTH-1]                                    read_ptr_inc;
   reg  [0:REGISTER_RENAME_DEPTH-ARCHITECTED_REGISTER_DEPTH-1] read_ptr;
   wire [0:REGISTER_RENAME_DEPTH-ARCHITECTED_REGISTER_DEPTH-1] read_ptr_p1;

   wire                                                        write_ptr_act;
   wire [0:STORAGE_WIDTH-1]                                    write_ptr_d;
   wire [0:STORAGE_WIDTH-1]                                    write_ptr_l2;
   reg  [0:REGISTER_RENAME_DEPTH-ARCHITECTED_REGISTER_DEPTH-1] write_ptr;
   wire [0:REGISTER_RENAME_DEPTH-ARCHITECTED_REGISTER_DEPTH-1] write_ptr_p1;
   wire [0:STORAGE_WIDTH-1]                                    write_ptr_value;

   wire                                                        free_cnt_act;
   reg [0:STORAGE_WIDTH-1]                                     free_cnt_d;
   wire [0:STORAGE_WIDTH-1]                                    free_cnt_l2;

   reg                                                         pool_free_0_v_d;
   wire                                                        pool_free_0_v_l2;
   reg [0:STORAGE_WIDTH-1]                                     pool_free_0_d;
   wire [0:STORAGE_WIDTH-1]                                    pool_free_0_l2;
   reg                                                         pool_free_1_v_d;
   wire                                                        pool_free_1_v_l2;
   reg [0:STORAGE_WIDTH-1]                                     pool_free_1_d;
   wire [0:STORAGE_WIDTH-1]                                    pool_free_1_l2;

   // temporary signal prior to mux select for i0->i1 bypass
   reg [0:STORAGE_WIDTH-1]                                     src4_temp_p;
   reg [0:STORAGE_WIDTH-1]                                     src5_temp_p;
   reg [0:STORAGE_WIDTH-1]                                     src6_temp_p;
   reg [0:`ITAG_SIZE_ENC-1]                                    src4_temp_itag;
   reg [0:`ITAG_SIZE_ENC-1]                                    src5_temp_itag;
   reg [0:`ITAG_SIZE_ENC-1]                                    src6_temp_itag;

   assign tidn = 1'b0;
   assign tiup = 1'b1;

   always @( * )
   begin: read_spec_map_arc_proc
   	integer i;
     	src1_p <= 0;
     	src2_p <= 0;
     	src3_p <= 0;
     	src4_temp_p <= 0;
     	src5_temp_p <= 0;
     	src6_temp_p <= 0;
     	for (i = 0; i <= ARCHITECTED_REGISTER_DEPTH - 1; i = i + 1)
     	begin
      	if (src1_a == i)
      		src1_p <= spec_map_arc_l2[i];
      	if (src2_a == i)
      		src2_p <= spec_map_arc_l2[i];
      	if (src3_a == i)
      		src3_p <= spec_map_arc_l2[i];
      	if (src4_a == i)
      		src4_temp_p <= spec_map_arc_l2[i];
      	if (src5_a == i)
      		src5_temp_p <= spec_map_arc_l2[i];
      	if (src6_a == i)
      		src6_temp_p <= spec_map_arc_l2[i];
      end
   end

   assign src4_p = spec_1_dep_hit_s1 ? spec_0_wr_rename :
                   src4_temp_p;
   assign src5_p = spec_1_dep_hit_s2 ? spec_0_wr_rename :
                   src5_temp_p;
   assign src6_p = spec_1_dep_hit_s3 ? spec_0_wr_rename :
                   src6_temp_p;

   always @( * )
   begin: read_spec_map_itag_proc
      integer i;
      src1_itag <= 0;
      src2_itag <= 0;
      src3_itag <= 0;
      src4_temp_itag <= 0;
      src5_temp_itag <= 0;
      src6_temp_itag <= 0;
      for (i = 0; i <= ARCHITECTED_REGISTER_DEPTH - 1; i = i + 1)
      begin
         if (src1_a == i)
            src1_itag <= spec_map_itag_l2[i];
         if (src2_a == i)
            src2_itag <= spec_map_itag_l2[i];
         if (src3_a == i)
            src3_itag <= spec_map_itag_l2[i];
         if (src4_a == i)
            src4_temp_itag <= spec_map_itag_l2[i];
         if (src5_a == i)
            src5_temp_itag <= spec_map_itag_l2[i];
         if (src6_a == i)
            src6_temp_itag <= spec_map_itag_l2[i];
      end
   end

   assign src4_itag = spec_1_dep_hit_s1 ? spec_0_wr_itag :
                      src4_temp_itag;
   assign src5_itag = spec_1_dep_hit_s2 ? spec_0_wr_itag :
                      src5_temp_itag;
   assign src6_itag = spec_1_dep_hit_s3 ? spec_0_wr_itag :
                      src6_temp_itag;

   assign comp_map_act = comp_0_wr_val | comp_1_wr_val;

   always @( * )
   begin: set_comp_map_proc
      integer i;
      pool_free_0_v_d <= 0;
      pool_free_0_d <= 0;
      pool_free_1_v_d <= 0;
      pool_free_1_d <= 0;

      for (i = 0; i <= ARCHITECTED_REGISTER_DEPTH - 1; i = i + 1)
      begin
      	comp_map_d[i] <= comp_map_l2[i];
         if ((comp_0_wr_val == 1'b1) & (comp_1_wr_val == 1'b1) & (comp_0_wr_arc == comp_1_wr_arc) & comp_0_wr_arc == i)
         begin
            comp_map_d[i] <= comp_1_wr_rename;
            pool_free_0_v_d <= 1'b1;
            pool_free_0_d <= comp_map_l2[i];
            pool_free_1_v_d <= 1'b1;
            pool_free_1_d <= comp_0_wr_rename;
         end
         else
         begin
            if ((comp_0_wr_val == 1'b1) & comp_0_wr_arc == i)
            begin
               comp_map_d[i] <= comp_0_wr_rename;
               pool_free_0_v_d <= 1'b1;
               pool_free_0_d <= comp_map_l2[i];
            end
            if ((comp_1_wr_val == 1'b1) & comp_1_wr_arc == i)
            begin
               comp_map_d[i] <= comp_1_wr_rename;
               pool_free_1_v_d <= 1'b1;
               pool_free_1_d <= comp_map_l2[i];
            end
         end
      end
   end

   assign spec_map_arc_act = flush_map | spec_0_wr_val_fast | spec_1_wr_val_fast;
   assign spec_map_itag_act = 1'b1;

   generate
      begin : xhdl1
         genvar i;
         for (i = 0; i <= ARCHITECTED_REGISTER_DEPTH - 1; i = i + 1)
         begin : map_set0

            always @(flush_map or spec_0_wr_val or spec_0_wr_arc or spec_0_wr_rename or spec_1_wr_val or spec_1_wr_arc or spec_1_wr_rename or spec_map_arc_l2[i] or comp_map_l2[i])
            begin: set_spec_map_arc_proc
               spec_map_arc_d[i] <= spec_map_arc_l2[i];
               if (flush_map == 1'b1)
                  spec_map_arc_d[i] <= comp_map_l2[i];
               else if ((spec_1_wr_val == 1'b1) & spec_1_wr_arc == i)
                  spec_map_arc_d[i] <= spec_1_wr_rename;
               else if ((spec_0_wr_val == 1'b1) & spec_0_wr_arc == i)
                  spec_map_arc_d[i] <= spec_0_wr_rename;
            end

            always @(flush_map or spec_0_wr_val or spec_0_wr_arc or spec_0_wr_itag or spec_1_wr_val or spec_1_wr_arc or spec_1_wr_itag or spec_map_itag_l2[i] or comp_0_wr_val or comp_0_wr_itag or comp_1_wr_val or comp_1_wr_itag)
            begin: set_spec_map_itag_proc
               spec_map_itag_d[i] <= spec_map_itag_l2[i];
               if (flush_map == 1'b1)
                  spec_map_itag_d[i] <= {`ITAG_SIZE_ENC{1'b1}};
               else if ((spec_1_wr_val == 1'b1) & spec_1_wr_arc == i)
                  spec_map_itag_d[i] <= spec_1_wr_itag;
               else if ((spec_0_wr_val == 1'b1) & spec_0_wr_arc == i)
                  spec_map_itag_d[i] <= spec_0_wr_itag;
               else
               begin
                  if ((comp_0_wr_val == 1'b1) & comp_0_wr_itag == spec_map_itag_l2[i])
                     spec_map_itag_d[i] <= {`ITAG_SIZE_ENC{1'b1}};
                  if ((comp_1_wr_val == 1'b1) & comp_1_wr_itag == spec_map_itag_l2[i])
                     spec_map_itag_d[i] <= {`ITAG_SIZE_ENC{1'b1}};
               end
            end
         end
      end
   endgenerate

   generate
   begin : write_ptr_calc
   	genvar i;
   	for(i = 0; i <= (REGISTER_RENAME_DEPTH - ARCHITECTED_REGISTER_DEPTH - 1); i = i + 1)
   	begin : write_ptr_set
   		always @( * )
   		if (write_ptr_l2 == i)
   			write_ptr[i] <= (pool_free_0_v_l2 | pool_free_1_v_l2);
   		else
   			write_ptr[i] <= 1'b0;
   		end
   	end
   endgenerate
   assign write_ptr_p1 = {REGISTER_RENAME_DEPTH - ARCHITECTED_REGISTER_DEPTH{pool_free_0_v_l2 & pool_free_1_v_l2}} &
                         ({write_ptr[REGISTER_RENAME_DEPTH-ARCHITECTED_REGISTER_DEPTH-1], write_ptr[0:REGISTER_RENAME_DEPTH-ARCHITECTED_REGISTER_DEPTH-2]});

   assign write_ptr_value = ({pool_free_0_v_l2, pool_free_1_v_l2} == 2'b01) ? pool_free_1_l2 :
                             pool_free_0_l2;
   generate
   	begin : xhdl2
   		genvar i;
         for (i = 0; i <= REGISTER_RENAME_DEPTH - ARCHITECTED_REGISTER_DEPTH - 1; i = i + 1)
         begin : buffer_pool_gen
         	always @( * )
         	begin
         		buffer_pool_act[i] <= write_ptr[i] | write_ptr_p1[i];
         		buffer_pool_d[i] <= ({STORAGE_WIDTH{write_ptr[i]}} & write_ptr_value) |
         		                    ({STORAGE_WIDTH{write_ptr_p1[i]}} & pool_free_1_l2);
            end
         end
      end
   endgenerate

	iuq_rn_map_inc #(.SIZE(STORAGE_WIDTH), .WRAP(REGISTER_RENAME_DEPTH - ARCHITECTED_REGISTER_DEPTH - 1)) read_ptr_inc0(
		.inc({take_a, take_b}),
      .i(read_ptr_l2),
      .o(read_ptr_inc)
   );

   assign read_ptr_act = take_a | take_b | flush_map;

   assign read_ptr_d = (flush_map == 1'b0) ? read_ptr_inc :
                          write_ptr_l2;
   assign write_ptr_act = pool_free_0_v_l2 | pool_free_1_v_l2;


   iuq_rn_map_inc #(.SIZE(STORAGE_WIDTH), .WRAP(REGISTER_RENAME_DEPTH - ARCHITECTED_REGISTER_DEPTH - 1)) write_ptr_inc0(
   	.inc({pool_free_0_v_l2, pool_free_1_v_l2}),
   	.i(write_ptr_l2),
      .o(write_ptr_d)
   );

   assign free_cnt_act = flush_map | take_a | take_b | pool_free_0_v_l2 | pool_free_1_v_l2;

	always @(flush_map or take_a or take_b or pool_free_0_v_l2 or pool_free_1_v_l2 or free_cnt_l2)
   begin: free_cnt_proc
   	free_cnt_d <= free_cnt_l2;

   	if (flush_map == 1'b1)
   		free_cnt_d <= REGISTER_RENAME_DEPTH - ARCHITECTED_REGISTER_DEPTH;
   	else
   	begin
   		if ((take_a == 1'b0 & (pool_free_0_v_l2 == 1'b1 ^ pool_free_1_v_l2 == 1'b1)) |
   		    (take_a == 1'b1 & take_b == 1'b0 & pool_free_0_v_l2 == 1'b1 & pool_free_1_v_l2 == 1'b1))
   			free_cnt_d <= free_cnt_l2 + value_1[32-STORAGE_WIDTH:31];
   		if (take_a == 1'b0 & pool_free_0_v_l2 == 1'b1 & pool_free_1_v_l2 == 1'b1)
   			free_cnt_d <= free_cnt_l2 + value_2[32-STORAGE_WIDTH:31];
   		if ((take_a == 1'b1 & take_b == 1'b0 & pool_free_0_v_l2 == 1'b0 & pool_free_1_v_l2 == 1'b0) |
   		    (take_a == 1'b1 & take_b == 1'b1 & (pool_free_0_v_l2 == 1'b1 ^ pool_free_1_v_l2 == 1'b1)))
   			free_cnt_d <= free_cnt_l2 - value_1[32-STORAGE_WIDTH:31];
   		if (take_a == 1'b1 & take_b == 1'b1 & pool_free_0_v_l2 == 1'b0 & pool_free_1_v_l2 == 1'b0)
   			free_cnt_d <= free_cnt_l2 - value_2[32-STORAGE_WIDTH:31];
   	end
   end

   // Creating 1 hot muxing from pointers
   generate
   begin : read_ptr_calc
   	genvar i;
   	for(i = 0; i <= (REGISTER_RENAME_DEPTH - ARCHITECTED_REGISTER_DEPTH - 1); i = i + 1)
   	begin : read_ptr_set

   		always @( * )
   		if (read_ptr_l2 == i)
   			read_ptr[i] <= 1'b1;
   		else
   			read_ptr[i] <= 1'b0;
   	end
   end
   endgenerate
   assign read_ptr_p1 = {read_ptr[REGISTER_RENAME_DEPTH - ARCHITECTED_REGISTER_DEPTH - 1], read_ptr[0:REGISTER_RENAME_DEPTH - ARCHITECTED_REGISTER_DEPTH - 2]};

   // OUTPUTS
   assign next_reg_a_val = (~(free_cnt_l2 == 0));
   assign next_reg_b_val = (~(free_cnt_l2 == 1));

   always @( * )
   begin: next_reg_proc
      integer e;
      next_reg_a <= 0;
      next_reg_b <= 0;

      for (e = 0; e <= (REGISTER_RENAME_DEPTH-ARCHITECTED_REGISTER_DEPTH-1+1) - 1; e = e + 1)
      begin
         if (read_ptr[e] == 1'b1)
            next_reg_a <= buffer_pool_l2[e];
         if (read_ptr_p1[e] == 1'b1)
            next_reg_b <= buffer_pool_l2[e];
      end
   end

   generate
	   begin : xhdl3
	   	genvar i;
	   	for (i = 0; i <= ARCHITECTED_REGISTER_DEPTH - 1; i = i + 1)
	   	begin : comp_map0

	   		tri_rlmreg_p #(.WIDTH(STORAGE_WIDTH), .INIT(i)) comp_map_latch(
            	.vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(comp_map_act),
               .force_t(force_t),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .d_mode(d_mode),
               .sg(pc_iu_sg_0),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .scin(siv[comp_map_offset + (STORAGE_WIDTH) * i:comp_map_offset + (STORAGE_WIDTH) * (i + 1) - 1]),
               .scout(sov[comp_map_offset + (STORAGE_WIDTH) * i:comp_map_offset + (STORAGE_WIDTH) * (i + 1) - 1]),
               .din(comp_map_d[i]),
               .dout(comp_map_l2[i])
            );
         end
      end
   endgenerate

   generate
      begin : xhdl4
         genvar                                                      i;
         for (i = 0; i <= ARCHITECTED_REGISTER_DEPTH - 1; i = i + 1)
         begin : spec_map0

            tri_rlmreg_p #(.WIDTH(STORAGE_WIDTH), .INIT(i)) spec_map_arc_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(spec_map_arc_act),
               .force_t(force_t),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .d_mode(d_mode),
               .sg(pc_iu_sg_0),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .scin(siv[spec_map_arc_offset + (STORAGE_WIDTH) * i:(spec_map_arc_offset + (STORAGE_WIDTH) * (i + 1)) - 1]),
               .scout(sov[spec_map_arc_offset + (STORAGE_WIDTH) * i:(spec_map_arc_offset + (STORAGE_WIDTH) * (i + 1)) - 1]),
               .din(spec_map_arc_d[i]),
               .dout(spec_map_arc_l2[i])
            );


            tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(i)) spec_map_itag_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(spec_map_itag_act),
               .force_t(force_t),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .d_mode(d_mode),
               .sg(pc_iu_sg_0),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .scin(siv[spec_map_itag_offset + (`ITAG_SIZE_ENC) * i:(spec_map_itag_offset + (`ITAG_SIZE_ENC) * (i + 1)) - 1]),
               .scout(sov[spec_map_itag_offset + (`ITAG_SIZE_ENC) * i:(spec_map_itag_offset + (`ITAG_SIZE_ENC) * (i + 1)) - 1]),
               .din(spec_map_itag_d[i]),
               .dout(spec_map_itag_l2[i])
            );
         end
      end
   endgenerate

   generate
      begin : xhdl5
         genvar                                                      i;
         for (i = 0; i <= REGISTER_RENAME_DEPTH - ARCHITECTED_REGISTER_DEPTH - 1; i = i + 1)
         begin : buffer_pool_lat

            tri_rlmreg_p #(.WIDTH(STORAGE_WIDTH), .INIT((i + ARCHITECTED_REGISTER_DEPTH))) buffer_pool_latch0(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(buffer_pool_act[i]),
               .force_t(force_t),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .d_mode(d_mode),
               .sg(pc_iu_sg_0),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .scin(siv[buffer_pool_offset + (STORAGE_WIDTH) * i:(buffer_pool_offset + (STORAGE_WIDTH) * (i + 1)) - 1]),
               .scout(sov[buffer_pool_offset + (STORAGE_WIDTH) * i:(buffer_pool_offset + (STORAGE_WIDTH) * (i + 1)) - 1]),
               .din(buffer_pool_d[i]),
               .dout(buffer_pool_l2[i])
            );
         end
      end
   endgenerate


   tri_rlmreg_p #(.WIDTH(STORAGE_WIDTH), .INIT(0)) read_ptr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(read_ptr_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[read_ptr_offset:read_ptr_offset + STORAGE_WIDTH - 1]),
      .scout(sov[read_ptr_offset:read_ptr_offset + STORAGE_WIDTH - 1]),
      .din(read_ptr_d),
      .dout(read_ptr_l2)
   );


   tri_rlmreg_p #(.WIDTH(STORAGE_WIDTH), .INIT(0)) write_ptr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(write_ptr_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[write_ptr_offset:write_ptr_offset + STORAGE_WIDTH - 1]),
      .scout(sov[write_ptr_offset:write_ptr_offset + STORAGE_WIDTH - 1]),
      .din(write_ptr_d),
      .dout(write_ptr_l2)
   );


   tri_rlmreg_p #(.WIDTH(STORAGE_WIDTH), .INIT(REGISTER_RENAME_DEPTH - ARCHITECTED_REGISTER_DEPTH)) free_cnt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(free_cnt_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[free_cnt_offset:free_cnt_offset + STORAGE_WIDTH - 1]),
      .scout(sov[free_cnt_offset:free_cnt_offset + STORAGE_WIDTH - 1]),
      .din(free_cnt_d),
      .dout(free_cnt_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) pool_free_0_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[pool_free_0_v_offset]),
      .scout(sov[pool_free_0_v_offset]),
      .din(pool_free_0_v_d),
      .dout(pool_free_0_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(STORAGE_WIDTH), .INIT(0)) pool_free_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[pool_free_0_offset:pool_free_0_offset + STORAGE_WIDTH - 1]),
      .scout(sov[pool_free_0_offset:pool_free_0_offset + STORAGE_WIDTH - 1]),
      .din(pool_free_0_d),
      .dout(pool_free_0_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) pool_free_1_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[pool_free_1_v_offset]),
      .scout(sov[pool_free_1_v_offset]),
      .din(pool_free_1_v_d),
      .dout(pool_free_1_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(STORAGE_WIDTH), .INIT(0)) pool_free_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[pool_free_1_offset:pool_free_1_offset + STORAGE_WIDTH - 1]),
      .scout(sov[pool_free_1_offset:pool_free_1_offset + STORAGE_WIDTH - 1]),
      .din(pool_free_1_d),
      .dout(pool_free_1_l2)
   );

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv[0:scan_right] = {sov[1:scan_right], func_scan_in};
   assign func_scan_out = sov[0];

endmodule
