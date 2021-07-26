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

//********************************************************************
//*
//* TITLE: MMU TLB Match Line Logic for Functional Model
//*
//* NAME: mmq_tlb_matchline
//*
//************ change log at end of this file ***************************
//

`timescale 1 ns / 1 ns

`include "tri_a2o.vh"
`include "mmu_a2o.vh"
`define    TLB_CMPMASK_WIDTH       5

module mmq_tlb_matchline(

   inout                     vdd,
   inout                     gnd,

   input [0:51]                  addr_in,
   input [0:8]                   addr_enable,
   input [0:3]                   comp_pgsize,
   input                          pgsize_enable,
   input [0:3]                    entry_size,
   input [0:`TLB_CMPMASK_WIDTH-1] entry_cmpmask,
   input                           entry_xbit,
   input [0:`TLB_CMPMASK_WIDTH-1] entry_xbitmask,
   input [0:51]                   entry_epn,
   input [0:1]                    comp_class,
   input [0:1]                    entry_class,
   input                          class_enable,
   input [0:1]                    comp_extclass,
   input [0:1]                    entry_extclass,
   input [0:1]                    extclass_enable,
   input [0:1]                    comp_state,
   input                          entry_gs,
   input                          entry_ts,
   input [0:1]                    state_enable,
   input [0:3]                    entry_thdid,
   input [0:3]                    comp_thdid,
   input                          thdid_enable,
   input [0:13]                   entry_pid,
   input [0:13]                   comp_pid,
   input                          pid_enable,
   input [0:7]                    entry_lpid,
   input [0:7]                    comp_lpid,
   input                          lpid_enable,
   input                          entry_ind,
   input                          comp_ind,
   input                          ind_enable,
   input                          entry_iprot,
   input                          comp_iprot,
   input                          iprot_enable,
   input                          entry_v,
   input                          comp_invalidate,

   output                         match,

   output                    dbg_addr_match,
   output                    dbg_pgsize_match,
   output                    dbg_class_match,
   output                    dbg_extclass_match,
   output                    dbg_state_match,
   output                    dbg_thdid_match,
   output                    dbg_pid_match,
   output                    dbg_lpid_match,
   output                    dbg_ind_match,

   output                    dbg_iprot_match

);

parameter    HAVE_XBIT          = 1;
parameter    NUM_PGSIZES        = 5;
parameter    HAVE_CMPMASK       = 1;


   //----------------------------------------------------------------------
   // Components
   //----------------------------------------------------------------------

   //----------------------------------------------------------------------
   // Signals
   //----------------------------------------------------------------------


      wire [30:51]              entry_epn_b;
      wire                      function_50_51;
      wire                      function_48_51;
      wire                      function_46_51;
      wire                      function_44_51;
      wire                      function_40_51;
      wire                      function_36_51;
      wire                      function_34_51;
      wire                      pgsize_gte_16K;
      wire                      pgsize_gte_64K;
      wire                      pgsize_gte_256K;
      wire                      pgsize_gte_1M;
      wire                      pgsize_gte_16M;
      wire                      pgsize_gte_256M;
      wire                      pgsize_gte_1G;
      wire                      pgsize_eq_16K;
      wire                      pgsize_eq_64K;
      wire                      pgsize_eq_256K;
      wire                      pgsize_eq_1M;
      wire                      pgsize_eq_16M;
      wire                      pgsize_eq_256M;
      wire                      pgsize_eq_1G;
      wire                      comp_or_34_35;
      wire                      comp_or_36_39;
      wire                      comp_or_40_43;
      wire                      comp_or_44_45;
      wire                      comp_or_44_47;
      wire                      comp_or_46_47;
      wire                      comp_or_48_49;
      wire                      comp_or_48_51;
      wire                      comp_or_50_51;
      wire [0:85]               match_line;
      wire                      pgsize_match;
      wire                      addr_match;
      wire                      class_match;
      wire                      extclass_match;
      wire                      state_match;
      wire                      thdid_match;
      wire                      pid_match;
      wire                      lpid_match;
      wire                      ind_match;
      wire                      iprot_match;
      wire                      addr_match_xbit_contrib;
      wire                      addr_match_lsb_contrib;
      wire                      addr_match_msb_contrib;

      (* analysis_not_referenced="true" *)
      wire [0:6]                unused_dc;

      assign match_line[0:85] = ( ~(({entry_epn[0:51], entry_size[0:3], entry_class[0:1], entry_extclass[0:1], entry_gs, entry_ts, entry_pid[0:13],
                                        entry_lpid[0:7], entry_ind, entry_iprot}) ^ ({addr_in[0:51], comp_pgsize[0:3], comp_class[0:1],
                                        comp_extclass[0:1], comp_state[0:1], comp_pid[0:13], comp_lpid[0:7], comp_ind, comp_iprot})) );

      generate
         if (NUM_PGSIZES == 8)
         begin : numpgsz8
            assign entry_epn_b[30:51] = (~(entry_epn[30:51]));

            assign unused_dc[0:4] = {5{1'b0}};
            assign unused_dc[5] = vdd;
            assign unused_dc[6] = gnd;

            if (HAVE_CMPMASK == 0)
            begin : gen_nocmpmask80
               assign pgsize_gte_1G   = (entry_size[0] & (~(entry_size[1])) & entry_size[2] & (~(entry_size[3])));
               assign pgsize_gte_256M = (entry_size[0] & (~(entry_size[1])) & (~(entry_size[2])) & entry_size[3]) | pgsize_gte_1G;
               assign pgsize_gte_16M  = ((~(entry_size[0])) & entry_size[1] & entry_size[2] & entry_size[3]) | pgsize_gte_256M;
               assign pgsize_gte_1M   = ((~(entry_size[0])) & entry_size[1] & (~(entry_size[2])) & entry_size[3]) | pgsize_gte_16M;
               assign pgsize_gte_256K = ((~(entry_size[0])) & entry_size[1] & (~(entry_size[2])) & (~(entry_size[3]))) | pgsize_gte_1M;
               assign pgsize_gte_64K  = ((~(entry_size[0])) & (~(entry_size[1])) & entry_size[2] & entry_size[3]) | pgsize_gte_256K;
               assign pgsize_gte_16K  = ((~(entry_size[0])) & (~(entry_size[1])) & entry_size[2] & (~(entry_size[3]))) | pgsize_gte_64K;
            end

         //  size           entry_cmpmask: 0123456
         //    1GB                         1111111
         //  256MB                         0111111
         //   16MB                         0011111
         //    1MB                         0001111
         //  256KB                         0000111
         //   64KB                         0000011
         //   16KB                         0000001
         //    4KB                         0000000
         if (HAVE_CMPMASK == 1)
         begin : gen_cmpmask80
            assign pgsize_gte_1G   = entry_cmpmask[0];
            assign pgsize_gte_256M = entry_cmpmask[1];
            assign pgsize_gte_16M  = entry_cmpmask[2];
            assign pgsize_gte_1M   = entry_cmpmask[3];
            assign pgsize_gte_256K = entry_cmpmask[4];
            assign pgsize_gte_64K  = entry_cmpmask[5];
            assign pgsize_gte_16K  = entry_cmpmask[6];

            //  size          entry_xbitmask: 0123456
            //    1GB                         1000000
            //  256MB                         0100000
            //   16MB                         0010000
            //    1MB                         0001000
            //  256KB                         0000100
            //   64KB                         0000010
            //   16KB                         0000001
            //    4KB                         0000000
            assign pgsize_eq_1G   = entry_xbitmask[0];
            assign pgsize_eq_256M = entry_xbitmask[1];
            assign pgsize_eq_16M  = entry_xbitmask[2];
            assign pgsize_eq_1M   = entry_xbitmask[3];
            assign pgsize_eq_256K = entry_xbitmask[4];
            assign pgsize_eq_64K  = entry_xbitmask[5];
            assign pgsize_eq_16K  = entry_xbitmask[6];
         end

      //function_30_51 <= '0';
      if (HAVE_XBIT == 0)
      begin : gen_noxbit80
         assign function_34_51 = 1'b0;
         assign function_36_51 = 1'b0;
         assign function_40_51 = 1'b0;
         assign function_44_51 = 1'b0;
         assign function_46_51 = 1'b0;
         assign function_48_51 = 1'b0;
         assign function_50_51 = 1'b0;
      end

   // 1G
   if (HAVE_XBIT != 0)
   begin : gen_xbit80
      assign function_34_51 = (~(entry_xbit)) | (~(pgsize_eq_1G))   | |(entry_epn_b[34:51] & addr_in[34:51]);
      assign function_36_51 = (~(entry_xbit)) | (~(pgsize_eq_256M)) | |(entry_epn_b[36:51] & addr_in[36:51]);
      assign function_40_51 = (~(entry_xbit)) | (~(pgsize_eq_16M))  | |(entry_epn_b[40:51] & addr_in[40:51]);
      assign function_44_51 = (~(entry_xbit)) | (~(pgsize_eq_1M))   | |(entry_epn_b[44:51] & addr_in[44:51]);
      assign function_46_51 = (~(entry_xbit)) | (~(pgsize_eq_256K)) | |(entry_epn_b[46:51] & addr_in[46:51]);
      assign function_48_51 = (~(entry_xbit)) | (~(pgsize_eq_64K))  | |(entry_epn_b[48:51] & addr_in[48:51]);
      assign function_50_51 = (~(entry_xbit)) | (~(pgsize_eq_16K))  | |(entry_epn_b[50:51] & addr_in[50:51]);
   end

assign comp_or_50_51 = &(match_line[50:51]) | pgsize_gte_16K;
assign comp_or_48_49 = &(match_line[48:49]) | pgsize_gte_64K;
assign comp_or_46_47 = &(match_line[46:47]) | pgsize_gte_256K;
assign comp_or_44_45 = &(match_line[44:45]) | pgsize_gte_1M;
assign comp_or_40_43 = &(match_line[40:43]) | pgsize_gte_16M;
assign comp_or_36_39 = &(match_line[36:39]) | pgsize_gte_256M;
assign comp_or_34_35 = &(match_line[34:35]) | pgsize_gte_1G;

if (HAVE_XBIT == 0)		//  Ignore functions based on page size
begin : gen_noxbit81
   assign addr_match = ( comp_or_34_35 &
                           comp_or_36_39 &
                           comp_or_40_43 &
                           comp_or_44_45 &
                           comp_or_46_47 &
                           comp_or_48_49 &
                           (&(match_line[0:12])  | (~(addr_enable[0]))) &
                           (&(match_line[13:14]) | (~(addr_enable[1]))) &
                           (&(match_line[15:16]) | (~(addr_enable[2]))) &
                           (&(match_line[17:18]) | (~(addr_enable[3]))) &
                           (&(match_line[19:22]) | (~(addr_enable[4]))) &
                           (&(match_line[23:26]) | (~(addr_enable[5]))) &
                           (&(match_line[27:30]) | (~(addr_enable[6]))) &
                           (&(match_line[31:33]) | (~(addr_enable[7]))) ) //  Regular compare largest page size
                       | (~(addr_enable[8]));                            //  Include address as part of compare,
                                                                         //  should never ignore for regular compare/read.
                                                                        // Could ignore for compare/invalidate
   assign addr_match_xbit_contrib = 1'b0;

   assign addr_match_lsb_contrib = (comp_or_34_35 &
                                      comp_or_36_39 &
                                      comp_or_40_43 &
                                      comp_or_44_45 &
                                      comp_or_46_47 &
                                      comp_or_48_49 &
                                      comp_or_50_51);		//  Ignore functions based on page size

   assign addr_match_msb_contrib = (&(match_line[0:12])  | (~(addr_enable[0]))) &
                                     (&(match_line[13:14]) | (~(addr_enable[1]))) &
                                     (&(match_line[15:16]) | (~(addr_enable[2]))) &
                                     (&(match_line[17:18]) | (~(addr_enable[3]))) &
                                     (&(match_line[19:22]) | (~(addr_enable[4]))) &
                                     (&(match_line[23:26]) | (~(addr_enable[5]))) &
                                     (&(match_line[27:30]) | (~(addr_enable[6]))) &
                                     (&(match_line[31:33]) | (~(addr_enable[7])));
end

if (HAVE_XBIT != 0)		//  Exclusion functions
begin : gen_xbit81
//  Regular compare largest page size
assign addr_match = ( function_50_51 &
                         function_48_51 &
                         function_46_51 &
                         function_44_51 &
                         function_40_51 &
                         function_36_51 &
                         function_34_51 &
                         comp_or_34_35 &
                         comp_or_36_39 &
                         comp_or_40_43 &
                         comp_or_44_45 &
                         comp_or_46_47 &
                         comp_or_48_49 &
                         comp_or_50_51 &
                         (&(match_line[0:12]) | (~(addr_enable[0]))) &
                         (&(match_line[13:14]) | (~(addr_enable[1]))) &
                         (&(match_line[15:16]) | (~(addr_enable[2]))) &
                         (&(match_line[17:18]) | (~(addr_enable[3]))) &
                         (&(match_line[19:22]) | (~(addr_enable[4]))) &
                         (&(match_line[23:26]) | (~(addr_enable[5]))) &
                         (&(match_line[27:30]) | (~(addr_enable[6]))) &
                         (&(match_line[31:33]) | (~(addr_enable[7]))) )    //  Ignore functions based on page size
                     | (~(addr_enable[8]));                               //  Include address as part of compare,
                                                                          //  should never ignore for regular compare/read.
                                                                          // Could ignore for compare/invalidate

assign addr_match_xbit_contrib = (function_50_51 &
                                    function_48_51 &
                                    function_46_51 &
                                    function_44_51 &
                                    function_40_51 &
                                    function_36_51 &
                                    function_34_51);		//  Exclusion functions

assign addr_match_lsb_contrib = (comp_or_34_35 &
                                   comp_or_36_39 &
                                   comp_or_40_43 &
                                   comp_or_44_45 &
                                   comp_or_46_47 &
                                   comp_or_48_49 &
                                   comp_or_50_51);		//  Ignore functions based on page size

assign addr_match_msb_contrib = (&(match_line[0:12]) | (~(addr_enable[0]))) &
                                  (&(match_line[13:14]) | (~(addr_enable[1]))) &
                                  (&(match_line[15:16]) | (~(addr_enable[2]))) &
                                  (&(match_line[17:18]) | (~(addr_enable[3]))) &
                                  (&(match_line[19:22]) | (~(addr_enable[4]))) &
                                  (&(match_line[23:26]) | (~(addr_enable[5]))) &
                                  (&(match_line[27:30]) | (~(addr_enable[6]))) &
                                  (&(match_line[31:33]) | (~(addr_enable[7])));
end
end
endgenerate

// numpgsz8: NUM_PGSIZES = 8

// tie off unused signals
generate
if (NUM_PGSIZES == 5)
begin : numpgsz5
assign function_50_51 = 1'b0;
assign function_46_51 = 1'b0;
assign pgsize_gte_16K = 1'b0;
assign pgsize_gte_256K = 1'b0;
assign pgsize_eq_16K = 1'b0;
assign pgsize_eq_256K = 1'b0;
assign comp_or_44_45 = 1'b0;
assign comp_or_46_47 = 1'b0;
assign comp_or_48_49 = 1'b0;
assign comp_or_50_51 = 1'b0;

assign entry_epn_b[30:51] = (~(entry_epn[30:51]));

assign unused_dc[0] = (pgsize_gte_16K & pgsize_gte_256K & pgsize_eq_16K & pgsize_eq_256K);
assign unused_dc[1] = (function_50_51 & function_46_51);
assign unused_dc[2] = (comp_or_44_45 & comp_or_46_47 & comp_or_48_49 & comp_or_50_51);
assign unused_dc[3] = |(entry_epn_b[30:33]);
assign unused_dc[4] = addr_match_xbit_contrib & addr_match_lsb_contrib & addr_match_msb_contrib;
assign unused_dc[5] = vdd;
assign unused_dc[6] = gnd;

// 1010
if (HAVE_CMPMASK == 0)
begin : gen_nocmpmask50
assign pgsize_gte_1G   = (entry_size[0] & (~(entry_size[1])) & entry_size[2] & (~(entry_size[3])));

// 1001, large indirect entry size
assign pgsize_gte_256M = (entry_size[0] & (~(entry_size[1])) & (~(entry_size[2])) & entry_size[3]) | pgsize_gte_1G;
// 0111
assign pgsize_gte_16M  = ((~(entry_size[0])) & entry_size[1] & entry_size[2] & entry_size[3]) | pgsize_gte_256M;
// 0101
assign pgsize_gte_1M   = ((~(entry_size[0])) & entry_size[1] & (~(entry_size[2])) & entry_size[3]) | pgsize_gte_16M;
// 0011
assign pgsize_gte_64K  = ((~(entry_size[0])) & (~(entry_size[1])) & entry_size[2] & entry_size[3]) | pgsize_gte_1M;

// 1010
assign pgsize_eq_1G   = (entry_size[0] & (~(entry_size[1])) & entry_size[2] & (~(entry_size[3])));
// 1001, large indirect entry size
assign pgsize_eq_256M = (entry_size[0] & (~(entry_size[1])) & (~(entry_size[2])) & entry_size[3]);
// 0111
assign pgsize_eq_16M  = ((~(entry_size[0])) & entry_size[1] & entry_size[2] & entry_size[3]);
// 0101
assign pgsize_eq_1M   = ((~(entry_size[0])) & entry_size[1] & (~(entry_size[2])) & entry_size[3]);
// 0011
assign pgsize_eq_64K  = ((~(entry_size[0])) & (~(entry_size[1])) & entry_size[2] & entry_size[3]);
end

//  size           entry_cmpmask: 01234
//    1GB                         11111
//  256MB                         01111
//   16MB                         00111
//    1MB                         00011
//   64KB                         00001
//    4KB                         00000
if (HAVE_CMPMASK == 1)
begin : gen_cmpmask50
assign pgsize_gte_1G = entry_cmpmask[0];
assign pgsize_gte_256M = entry_cmpmask[1];
assign pgsize_gte_16M = entry_cmpmask[2];
assign pgsize_gte_1M = entry_cmpmask[3];
assign pgsize_gte_64K = entry_cmpmask[4];

//  size          entry_xbitmask: 01234
//    1GB                         10000
//  256MB                         01000
//   16MB                         00100
//    1MB                         00010
//   64KB                         00001
//    4KB                         00000
assign pgsize_eq_1G = entry_xbitmask[0];
assign pgsize_eq_256M = entry_xbitmask[1];
assign pgsize_eq_16M = entry_xbitmask[2];
assign pgsize_eq_1M = entry_xbitmask[3];
assign pgsize_eq_64K = entry_xbitmask[4];
end

if (HAVE_XBIT == 0)
begin : gen_noxbit50
assign function_34_51 = 1'b0;
assign function_36_51 = 1'b0;
assign function_40_51 = 1'b0;
assign function_44_51 = 1'b0;
assign function_48_51 = 1'b0;
end

// 1G
if (HAVE_XBIT != 0)
begin : gen_xbit50
assign function_34_51 = (~(entry_xbit)) | (~(pgsize_eq_1G))   | |(entry_epn_b[34:51] & addr_in[34:51]);
// 256M
assign function_36_51 = (~(entry_xbit)) | (~(pgsize_eq_256M)) | |(entry_epn_b[36:51] & addr_in[36:51]);
// 16M
assign function_40_51 = (~(entry_xbit)) | (~(pgsize_eq_16M))  | |(entry_epn_b[40:51] & addr_in[40:51]);
// 1M
assign function_44_51 = (~(entry_xbit)) | (~(pgsize_eq_1M))   | |(entry_epn_b[44:51] & addr_in[44:51]);
// 64K
assign function_48_51 = (~(entry_xbit)) | (~(pgsize_eq_64K))  | |(entry_epn_b[48:51] & addr_in[48:51]);
end

assign comp_or_48_51 = &(match_line[48:51]) | pgsize_gte_64K;
assign comp_or_44_47 = &(match_line[44:47]) | pgsize_gte_1M;
assign comp_or_40_43 = &(match_line[40:43]) | pgsize_gte_16M;
assign comp_or_36_39 = &(match_line[36:39]) | pgsize_gte_256M;
assign comp_or_34_35 = &(match_line[34:35]) | pgsize_gte_1G;		// glorp

if (HAVE_XBIT == 0)		//  Ignore functions based on page size
begin : gen_noxbit51
assign addr_match = (comp_or_34_35 &
                        comp_or_36_39 &
                        comp_or_40_43 &
                        comp_or_44_47 &
                        comp_or_48_51 &
                        (&(match_line[0:12])  | (~(addr_enable[0]))) &
                        (&(match_line[13:14]) | (~(addr_enable[1]))) &
                        (&(match_line[15:16]) | (~(addr_enable[2]))) &
                        (&(match_line[17:18]) | (~(addr_enable[3]))) &
                        (&(match_line[19:22]) | (~(addr_enable[4]))) &
                        (&(match_line[23:26]) | (~(addr_enable[5]))) &
                        (&(match_line[27:30]) | (~(addr_enable[6]))) &
                        (&(match_line[31:33]) | (~(addr_enable[7])))) 	//  Regular compare largest page size
                     | (~(addr_enable[8]));	                      //  Include address as part of compare,
                                                                     //  should never ignore for regular compare/read.
                                                                    // Could ignore for compare/invalidate
assign addr_match_xbit_contrib = 1'b0;

assign addr_match_lsb_contrib = (comp_or_34_35 &
                                   comp_or_36_39 &
                                   comp_or_40_43 &
                                   comp_or_44_47 &
                                   comp_or_48_51);		//  Ignore functions based on page size

assign addr_match_msb_contrib = (&(match_line[0:12])  | (~(addr_enable[0]))) &
                                  (&(match_line[13:14]) | (~(addr_enable[1]))) &
                                  (&(match_line[15:16]) | (~(addr_enable[2]))) &
                                  (&(match_line[17:18]) | (~(addr_enable[3]))) &
                                  (&(match_line[19:22]) | (~(addr_enable[4]))) &
                                  (&(match_line[23:26]) | (~(addr_enable[5]))) &
                                  (&(match_line[27:30]) | (~(addr_enable[6]))) &
                                  (&(match_line[31:33]) | (~(addr_enable[7])));
end

if (HAVE_XBIT != 0)
begin : gen_xbit51
//  Regular compare largest page size
assign addr_match = (function_48_51 &
                       function_44_51 &
                       function_40_51 &
                       function_36_51 &
                       function_34_51 &
                       comp_or_34_35 &
                       comp_or_36_39 &
                       comp_or_40_43 &
                       comp_or_44_47 &
                       comp_or_48_51 &
                       (&(match_line[0:12])  | (~(addr_enable[0]))) &
                       (&(match_line[13:14]) | (~(addr_enable[1]))) &
                       (&(match_line[15:16]) | (~(addr_enable[2]))) &
                       (&(match_line[17:18]) | (~(addr_enable[3]))) &
                       (&(match_line[19:22]) | (~(addr_enable[4]))) &
                       (&(match_line[23:26]) | (~(addr_enable[5]))) &
                       (&(match_line[27:30]) | (~(addr_enable[6]))) &
                       (&(match_line[31:33]) | (~(addr_enable[7])))) 	//  Ignore functions based on page size
                   | (~(addr_enable[8]));	                       //  Include address as part of compare,
                                                                       //  should never ignore for regular compare/read.
                                                                      // Could ignore for compare/invalidate

assign addr_match_xbit_contrib = (function_48_51 &
                                    function_44_51 &
                                    function_40_51 &
                                    function_36_51 &
                                    function_34_51);		//  Exclusion functions

assign addr_match_lsb_contrib = (comp_or_34_35 &
                                   comp_or_36_39 &
                                   comp_or_40_43 &
                                   comp_or_44_47 &
                                   comp_or_48_51);		//  Ignore functions based on page size

assign addr_match_msb_contrib = (&(match_line[0:12])  | (~(addr_enable[0]))) &
                                  (&(match_line[13:14]) | (~(addr_enable[1]))) &
                                  (&(match_line[15:16]) | (~(addr_enable[2]))) &
                                  (&(match_line[17:18]) | (~(addr_enable[3]))) &
                                  (&(match_line[19:22]) | (~(addr_enable[4]))) &
                                  (&(match_line[23:26]) | (~(addr_enable[5]))) &
                                  (&(match_line[27:30]) | (~(addr_enable[6]))) &
                                  (&(match_line[31:33]) | (~(addr_enable[7])));
end
end
endgenerate

// numpgsz5: NUM_PGSIZES = 5

assign pgsize_match = &(match_line[52:55]) | (~(pgsize_enable));

assign class_match = &(match_line[56:57]) | (~(class_enable));

assign extclass_match = (match_line[58] | (~(extclass_enable[0]))) & (match_line[59] | (~(extclass_enable[1])));

assign state_match = (match_line[60] | (~(state_enable[0]))) & (match_line[61] | (~(state_enable[1])));

assign thdid_match = |(entry_thdid[0:3] & comp_thdid[0:3]) | (~(thdid_enable));

// entry_pid=0 ignores pid match for translation, not invalidation
assign pid_match = &(match_line[62:75]) | ((~(|(entry_pid[0:13]))) & (~comp_invalidate)) | (~(pid_enable));

// entry_lpid=0 ignores lpid match for translation, not invalidation
assign lpid_match = &(match_line[76:83]) | ((~(|(entry_lpid[0:7]))) & (~comp_invalidate)) | (~(lpid_enable));

assign ind_match = match_line[84] | (~(ind_enable));

assign iprot_match = match_line[85] | (~(iprot_enable));

//  Address compare
//  PgSize compare
//  Class compare
//  ExtClass compare
//  State compare
//  ThdID compare
//  PID compare
//  LPID compare
//  indirect compare
//  inval prot compare
//  Valid
assign match = addr_match &
                 pgsize_match &
                 class_match &
                 extclass_match &
                 state_match &
                 thdid_match &
                 pid_match &
                 lpid_match &
                 ind_match &
                 iprot_match &
                 entry_v;

// debug outputs
assign dbg_addr_match = addr_match;
assign dbg_pgsize_match = pgsize_match;
assign dbg_class_match = class_match;
assign dbg_extclass_match = extclass_match;
assign dbg_state_match = state_match;
assign dbg_thdid_match = thdid_match;
assign dbg_pid_match = pid_match;
assign dbg_lpid_match = lpid_match;
assign dbg_ind_match = ind_match;
assign dbg_iprot_match = iprot_match;

endmodule
