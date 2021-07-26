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
//* TITLE: I-ERAT CAM Match Line Logic for Functional Model
//*
//* NAME: tri_cam_16x143_1r1w1c_matchline
//*
//*********************************************************************

module tri_cam_16x143_1r1w1c_matchline(
   addr_in,
   addr_enable,
   comp_pgsize,
   pgsize_enable,
   entry_size,
   entry_cmpmask,
   entry_xbit,
   entry_xbitmask,
   entry_epn,
   comp_class,
   entry_class,
   class_enable,
   comp_extclass,
   entry_extclass,
   extclass_enable,
   comp_state,
   entry_hv,
   entry_ds,
   state_enable,
   entry_thdid,
   comp_thdid,
   thdid_enable,
   entry_pid,
   comp_pid,
   pid_enable,
   entry_v,
   comp_invalidate,
   match
);
   parameter                 HAVE_XBIT = 1;
   parameter                 NUM_PGSIZES = 5;
   parameter                 HAVE_CMPMASK = 1;
   parameter                 CMPMASK_WIDTH = 4;

   // @{default:nclk}@
   input [0:51]              addr_in;
   input [0:1]               addr_enable;
   input [0:2]               comp_pgsize;
   input                     pgsize_enable;
   input [0:2]               entry_size;
   input [0:CMPMASK_WIDTH-1] entry_cmpmask;
   input                     entry_xbit;
   input [0:CMPMASK_WIDTH-1] entry_xbitmask;
   input [0:51]              entry_epn;
   input [0:1]               comp_class;
   input [0:1]               entry_class;
   input [0:2]               class_enable;
   input [0:1]               comp_extclass;
   input [0:1]               entry_extclass;
   input [0:1]               extclass_enable;
   input [0:1]               comp_state;
   input                     entry_hv;
   input                     entry_ds;
   input [0:1]               state_enable;
   input [0:3]               entry_thdid;
   input [0:3]               comp_thdid;
   input [0:1]               thdid_enable;
   input [0:7]               entry_pid;
   input [0:7]               comp_pid;
   input                     pid_enable;
   input                     entry_v;
   input                     comp_invalidate;

   output                    match;

   // tri_cam_16x143_1r1w1c_matchline

   //----------------------------------------------------------------------
   // Signals
   //----------------------------------------------------------------------

   wire [34:51]              entry_epn_b;
   wire                      function_50_51;
   wire                      function_48_51;
   wire                      function_46_51;
   wire                      function_44_51;
   wire                      function_40_51;
   wire                      function_36_51;
   wire                      function_34_51;
   wire                      pgsize_eq_16K;
   wire                      pgsize_eq_64K;
   wire                      pgsize_eq_256K;
   wire                      pgsize_eq_1M;
   wire                      pgsize_eq_16M;
   wire                      pgsize_eq_256M;
   wire                      pgsize_eq_1G;
   wire                      pgsize_gte_16K;
   wire                      pgsize_gte_64K;
   wire                      pgsize_gte_256K;
   wire                      pgsize_gte_1M;
   wire                      pgsize_gte_16M;
   wire                      pgsize_gte_256M;
   wire                      pgsize_gte_1G;
   wire                      comp_or_34_35;
   wire                      comp_or_34_39;
   wire                      comp_or_36_39;
   wire                      comp_or_40_43;
   wire                      comp_or_44_45;
   wire                      comp_or_44_47;
   wire                      comp_or_46_47;
   wire                      comp_or_48_49;
   wire                      comp_or_48_51;
   wire                      comp_or_50_51;
   wire [0:72]               match_line;
   wire                      pgsize_match;
   wire                      addr_match;
   wire                      class_match;
   wire                      extclass_match;
   wire                      state_match;
   wire                      thdid_match;
   wire                      pid_match;
    (* analysis_not_referenced="true" *)
   wire [0:2]                unused;

   assign match_line[0:72] = (~({entry_epn[0:51], entry_size[0:2], entry_class[0:1], entry_extclass[0:1], entry_hv, entry_ds, entry_pid[0:7], entry_thdid[0:3]} ^
                                {addr_in[0:51], comp_pgsize[0:2], comp_class[0:1], comp_extclass[0:1], comp_state[0:1], comp_pid[0:7], comp_thdid[0:3]}));

   generate
   begin
     if (NUM_PGSIZES == 8)
     begin : numpgsz8
       // tie off unused signals
       assign comp_or_34_39 = 1'b0;
       assign comp_or_44_47 = 1'b0;
       assign comp_or_48_51 = 1'b0;
       assign unused[0] = |{comp_or_34_39, comp_or_44_47, comp_or_48_51};

       assign entry_epn_b[34:51] = (~(entry_epn[34:51]));

       if (HAVE_CMPMASK == 0)
       begin
         assign pgsize_eq_1G   = (   entry_size[0]   &    entry_size[1]   &    entry_size[2]);
         assign pgsize_eq_256M = (   entry_size[0]   &    entry_size[1]   & (~(entry_size[2])));
         assign pgsize_eq_16M  = (   entry_size[0]   & (~(entry_size[1])) &    entry_size[2]);
         assign pgsize_eq_1M   = (   entry_size[0]   & (~(entry_size[1])) & (~(entry_size[2])));
         assign pgsize_eq_256K = ((~(entry_size[0])) &    entry_size[1]   &    entry_size[2]);
         assign pgsize_eq_64K  = ((~(entry_size[0])) &    entry_size[1]   & (~(entry_size[2])));
         assign pgsize_eq_16K  = ((~(entry_size[0])) & (~(entry_size[1])) &    entry_size[2]);

         assign pgsize_gte_1G   = (   entry_size[0]   &    entry_size[1]   &    entry_size[2]);
         assign pgsize_gte_256M = (   entry_size[0]   &    entry_size[1]   & (~(entry_size[2]))) | pgsize_gte_1G;
         assign pgsize_gte_16M  = (   entry_size[0]   & (~(entry_size[1])) &    entry_size[2])   | pgsize_gte_256M;
         assign pgsize_gte_1M   = (   entry_size[0]   & (~(entry_size[1])) & (~(entry_size[2]))) | pgsize_gte_16M;
         assign pgsize_gte_256K = ((~(entry_size[0])) &    entry_size[1]   &    entry_size[2])   | pgsize_gte_1M;
         assign pgsize_gte_64K  = ((~(entry_size[0])) &    entry_size[1]   & (~(entry_size[2]))) | pgsize_gte_256K;
         assign pgsize_gte_16K  = ((~(entry_size[0])) & (~(entry_size[1])) &    entry_size[2])   | pgsize_gte_64K;

         assign unused[1] = |{entry_cmpmask, entry_xbitmask};
       end

       if (HAVE_CMPMASK == 1)
       begin
         //  size           entry_cmpmask: 0123456
         //    1GB                         0000000
         //  256MB                         1000000
         //   16MB                         1100000
         //    1MB                         1110000
         //  256KB                         1111000
         //   64KB                         1111100
         //   16KB                         1111110
         //    4KB                         1111111
         assign pgsize_gte_1G   = (~entry_cmpmask[0]);
         assign pgsize_gte_256M = (~entry_cmpmask[1]);
         assign pgsize_gte_16M  = (~entry_cmpmask[2]);
         assign pgsize_gte_1M   = (~entry_cmpmask[3]);
         assign pgsize_gte_256K = (~entry_cmpmask[4]);
         assign pgsize_gte_64K  = (~entry_cmpmask[5]);
         assign pgsize_gte_16K  = (~entry_cmpmask[6]);

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

         assign unused[1] = 1'b0;
       end

       if (HAVE_XBIT == 0)
       begin
         assign function_34_51 = 1'b0;
         assign function_36_51 = 1'b0;
         assign function_40_51 = 1'b0;
         assign function_44_51 = 1'b0;
         assign function_46_51 = 1'b0;
         assign function_48_51 = 1'b0;
         assign function_50_51 = 1'b0;
	 assign unused[2] = |{function_34_51, function_36_51, function_40_51, function_44_51,
                              function_46_51, function_48_51, function_50_51, entry_xbit,
                              entry_epn_b, pgsize_eq_1G, pgsize_eq_256M, pgsize_eq_16M,
                              pgsize_eq_1M, pgsize_eq_256K, pgsize_eq_64K, pgsize_eq_16K};
       end

       if (HAVE_XBIT != 0)
       begin
         assign function_34_51 = (~(entry_xbit)) | (~(pgsize_eq_1G))   | (|(entry_epn_b[34:51] & addr_in[34:51]));
         assign function_36_51 = (~(entry_xbit)) | (~(pgsize_eq_256M)) | (|(entry_epn_b[36:51] & addr_in[36:51]));
         assign function_40_51 = (~(entry_xbit)) | (~(pgsize_eq_16M))  | (|(entry_epn_b[40:51] & addr_in[40:51]));
         assign function_44_51 = (~(entry_xbit)) | (~(pgsize_eq_1M))   | (|(entry_epn_b[44:51] & addr_in[44:51]));
         assign function_46_51 = (~(entry_xbit)) | (~(pgsize_eq_256K)) | (|(entry_epn_b[46:51] & addr_in[46:51]));
         assign function_48_51 = (~(entry_xbit)) | (~(pgsize_eq_64K))  | (|(entry_epn_b[48:51] & addr_in[48:51]));
         assign function_50_51 = (~(entry_xbit)) | (~(pgsize_eq_16K))  | (|(entry_epn_b[50:51] & addr_in[50:51]));
         assign unused[2] = 1'b0;
       end

       assign comp_or_50_51 = (&(match_line[50:51])) | pgsize_gte_16K;
       assign comp_or_48_49 = (&(match_line[48:49])) | pgsize_gte_64K;
       assign comp_or_46_47 = (&(match_line[46:47])) | pgsize_gte_256K;
       assign comp_or_44_45 = (&(match_line[44:45])) | pgsize_gte_1M;
       assign comp_or_40_43 = (&(match_line[40:43])) | pgsize_gte_16M;
       assign comp_or_36_39 = (&(match_line[36:39])) | pgsize_gte_256M;
       assign comp_or_34_35 = (&(match_line[34:35])) | pgsize_gte_1G;

       if (HAVE_XBIT == 0)
       begin
         assign addr_match = (comp_or_34_35 &		//  Ignore functions based on page size
                              comp_or_36_39 &
                              comp_or_40_43 &
                              comp_or_44_45 &
                              comp_or_46_47 &
                              comp_or_48_49 &
                              comp_or_50_51 &
                              (&(match_line[31:33])) &		//  Regular compare largest page size
                              ((&(match_line[0:30])) | (~(addr_enable[1])))) |         // ignored part of epn
                            (~(addr_enable[0]));       //  Include address as part of compare,
                                                       //  should never ignore for regular compare/read.
                                                       //  Could ignore for compare/invalidate
       end

       if (HAVE_XBIT != 0)
       begin
         assign addr_match = (function_50_51 &		//  Exclusion functions
                              function_48_51 &
                              function_46_51 &
                              function_44_51 &
                              function_40_51 &
                              function_36_51 &
                              function_34_51 &
                              comp_or_34_35 &		//  Ignore functions based on page size
                              comp_or_36_39 &
                              comp_or_40_43 &
                              comp_or_44_45 &
                              comp_or_46_47 &
                              comp_or_48_49 &
                              comp_or_50_51 &
                              (&(match_line[31:33])) &         //  Regular compare largest page size
                              (&(match_line[0:30]) | (~(addr_enable[1])))) |         // ignored part of epn
                            (~(addr_enable[0]));           //  Include address as part of compare,
                                                           //  should never ignore for regular compare/read.
                                                           //  Could ignore for compare/invalidate
       end
     end  // numpgsz8: NUM_PGSIZES = 8


     if (NUM_PGSIZES == 5)
     begin : numpgsz5
       // tie off unused signals
       assign function_50_51 = 1'b0;
       assign function_46_51 = 1'b0;
       assign function_36_51 = 1'b0;
       assign pgsize_eq_16K = 1'b0;
       assign pgsize_eq_256K = 1'b0;
       assign pgsize_eq_256M = 1'b0;
       assign pgsize_gte_16K = 1'b0;
       assign pgsize_gte_256K = 1'b0;
       assign pgsize_gte_256M = 1'b0;
       assign comp_or_34_35 = 1'b0;
       assign comp_or_36_39 = 1'b0;
       assign comp_or_44_45 = 1'b0;
       assign comp_or_46_47 = 1'b0;
       assign comp_or_48_49 = 1'b0;
       assign comp_or_50_51 = 1'b0;
       assign unused[0] = |{function_50_51, function_46_51, function_36_51,
                            pgsize_eq_16K, pgsize_eq_256K, pgsize_eq_256M,
                            pgsize_gte_16K, pgsize_gte_256K, pgsize_gte_256M,
                            comp_or_34_35, comp_or_36_39, comp_or_44_45,
                            comp_or_46_47, comp_or_48_49, comp_or_50_51};

       assign entry_epn_b[34:51] = (~(entry_epn[34:51]));

       if (HAVE_CMPMASK == 0)
       begin
         // 110
         assign pgsize_eq_1G  = (   entry_size[0]   &    entry_size[1]   & (~(entry_size[2])));
         // 111
         assign pgsize_eq_16M = (   entry_size[0]   &    entry_size[1]   &    entry_size[2]);
         // 101
         assign pgsize_eq_1M  = (   entry_size[0]   & (~(entry_size[1])) &    entry_size[2]);
         // 011
         assign pgsize_eq_64K = ((~(entry_size[0])) &    entry_size[1]   &    entry_size[2]);

         assign pgsize_gte_1G  = (   entry_size[0]   &    entry_size[1]   & (~(entry_size[2])));
         assign pgsize_gte_16M = (   entry_size[0]   &    entry_size[1]   & entry_size[2]) | pgsize_gte_1G;
         assign pgsize_gte_1M  = (   entry_size[0]   & (~(entry_size[1])) & entry_size[2]) | pgsize_gte_16M;
         assign pgsize_gte_64K = ((~(entry_size[0])) &    entry_size[1]   & entry_size[2]) | pgsize_gte_1M;

         assign unused[1] = |{entry_cmpmask, entry_xbitmask};
       end

       if (HAVE_CMPMASK == 1)
       begin
         //  size           entry_cmpmask: 0123
         //    1GB                         0000
         //   16MB                         1000
         //    1MB                         1100
         //   64KB                         1110
         //    4KB                         1111
         assign pgsize_gte_1G  = (~entry_cmpmask[0]);
         assign pgsize_gte_16M = (~entry_cmpmask[1]);
         assign pgsize_gte_1M  = (~entry_cmpmask[2]);
         assign pgsize_gte_64K = (~entry_cmpmask[3]);

         //  size          entry_xbitmask: 0123
         //    1GB                         1000
         //   16MB                         0100
         //    1MB                         0010
         //   64KB                         0001
         //    4KB                         0000
         assign pgsize_eq_1G  = entry_xbitmask[0];
         assign pgsize_eq_16M = entry_xbitmask[1];
         assign pgsize_eq_1M  = entry_xbitmask[2];
         assign pgsize_eq_64K = entry_xbitmask[3];

         assign unused[1] = 1'b0;
       end

       if (HAVE_XBIT == 0)
       begin
         assign function_34_51 = 1'b0;
         assign function_40_51 = 1'b0;
         assign function_44_51 = 1'b0;
         assign function_48_51 = 1'b0;
	 assign unused[2] = |{function_34_51, function_40_51, function_44_51,
                              function_48_51, entry_xbit, entry_epn_b,
                              pgsize_eq_1G, pgsize_eq_16M, pgsize_eq_1M, pgsize_eq_64K};
       end

       if (HAVE_XBIT != 0)
       begin
         // 1G
         assign function_34_51 = (~(entry_xbit)) | (~(pgsize_eq_1G))  | (|(entry_epn_b[34:51] & addr_in[34:51]));
         // 16M
         assign function_40_51 = (~(entry_xbit)) | (~(pgsize_eq_16M)) | (|(entry_epn_b[40:51] & addr_in[40:51]));
         // 1M
         assign function_44_51 = (~(entry_xbit)) | (~(pgsize_eq_1M))  | (|(entry_epn_b[44:51] & addr_in[44:51]));
         // 64K
         assign function_48_51 = (~(entry_xbit)) | (~(pgsize_eq_64K)) | (|(entry_epn_b[48:51] & addr_in[48:51]));
         assign unused[2] = 1'b0;
       end

       assign comp_or_48_51 = (&(match_line[48:51])) | pgsize_gte_64K;
       assign comp_or_44_47 = (&(match_line[44:47])) | pgsize_gte_1M;
       assign comp_or_40_43 = (&(match_line[40:43])) | pgsize_gte_16M;
       assign comp_or_34_39 = (&(match_line[34:39])) | pgsize_gte_1G;

       if (HAVE_XBIT == 0)
       begin
         assign addr_match = (comp_or_34_39 &		//  Ignore functions based on page size
                              comp_or_40_43 &
                              comp_or_44_47 &
                              comp_or_48_51 &
                              (&(match_line[31:33])) &		//  Regular compare largest page size
                              ((&(match_line[0:30])) | (~(addr_enable[1])))) |         // ignored part of epn
                            (~(addr_enable[0]));       //  Include address as part of compare,
                                                       //  should never ignore for regular compare/read.
                                                       //  Could ignore for compare/invalidate
       end

       if (HAVE_XBIT != 0)
       begin
         assign addr_match = (function_48_51 &
                              function_44_51 &
                              function_40_51 &
                              function_34_51 &
                              comp_or_34_39 &		//  Ignore functions based on page size
                              comp_or_40_43 &
                              comp_or_44_47 &
                              comp_or_48_51 &
                              (&(match_line[31:33])) &         //  Regular compare largest page size
                              ((&(match_line[0:30])) | (~(addr_enable[1])))) |         // ignored part of epn
                            (~(addr_enable[0]));             //  Include address as part of compare,
                                                             //  should never ignore for regular compare/read.
                                                             //  Could ignore for compare/invalidate
       end
     end // numpgsz5: NUM_PGSIZES = 5


     assign pgsize_match = (&(match_line[52:54])) | (~(pgsize_enable));

     assign class_match = (match_line[55] | (~(class_enable[0]))) &
                          (match_line[56] | (~(class_enable[1]))) &
                          ((&(match_line[55:56])) | (~(class_enable[2])) |
                           ((~(entry_extclass[1])) & (~comp_invalidate)));		// pid_nz bit

     assign extclass_match = (match_line[57] | (~(extclass_enable[0]))) &               // iprot bit
                             (match_line[58] | (~(extclass_enable[1])));		// pid_nz bit

     assign state_match = (match_line[59] | (~(state_enable[0]))) &
                          (match_line[60] | (~(state_enable[1])));

     assign thdid_match = (|(entry_thdid[0:3] & comp_thdid[0:3]) | (~(thdid_enable[0]))) &
                          (&(match_line[69:72]) | (~(thdid_enable[1])) |
                           ((~(entry_extclass[1])) & (~comp_invalidate)));		// pid_nz bit

     assign pid_match = (&(match_line[61:68])) |
                        // entry_pid=0 ignores pid match for compares,
                        //  but not for invalidates.
                        ((~(entry_extclass[1])) & (~comp_invalidate)) |		// pid_nz bit
                        (~(pid_enable));

     assign match = addr_match &        //  Address compare
                    pgsize_match &      //  Size compare
                    class_match &       //  Class compare
                    extclass_match &    //  ExtClass compare
                    state_match &       //  State compare
                    thdid_match &       //  ThdID compare
                    pid_match &         //  PID compare
                    entry_v;            //  Valid
   end
   endgenerate
endmodule
