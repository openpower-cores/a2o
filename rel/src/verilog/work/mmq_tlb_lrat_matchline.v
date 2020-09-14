// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.




`timescale 1 ns / 1 ns

`include "tri_a2o.vh"
`include "mmu_a2o.vh"
`define   LRAT_MAXSIZE_LOG2  40		
`define   LRAT_MINSIZE_LOG2  20		
`define   LRAT_CMPMASK_WIDTH      7


module mmq_tlb_lrat_matchline(

   inout                                                       vdd,
   inout                                                       gnd,

   input [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1]         addr_in,
   input                                                       addr_enable,
   input [0:3]                                                 entry_size,
   input [0:`LRAT_CMPMASK_WIDTH-1]                             entry_cmpmask,
   input                                                       entry_xbit,
   input [0:`LRAT_CMPMASK_WIDTH-1]                             entry_xbitmask,
   input [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1]         entry_lpn,
   input [0:`LPID_WIDTH-1]                                     entry_lpid,
   
   input [0:`LPID_WIDTH-1]                                     comp_lpid,
   input                                                       lpid_enable,
   input                                                       entry_v,
   
   output                                                      match,
   output                                                      dbg_addr_match,
   output                                                      dbg_lpid_match
   
);

parameter    HAVE_XBIT          = 1;
parameter    NUM_PGSIZES        = 8;
parameter    HAVE_CMPMASK       = 1;

   
   
   
      wire [64-`LRAT_MAXSIZE_LOG2:64-`LRAT_MINSIZE_LOG2-1]          entry_lpn_b;
      wire                                                        function_24_43;
      wire                                                        function_26_43;
      wire                                                        function_30_43;
      wire                                                        function_32_43;
      wire                                                        function_34_43;
      wire                                                        function_36_43;
      wire                                                        function_40_43;
      wire                                                        pgsize_eq_16M;		
      wire                                                        pgsize_eq_256M;		
      wire                                                        pgsize_eq_1G;		
      wire                                                        pgsize_eq_4G;		
      wire                                                        pgsize_eq_16G;		
      wire                                                        pgsize_eq_256G;		
      wire                                                        pgsize_eq_1T;		
      wire                                                        pgsize_gte_16M;		
      wire                                                        pgsize_gte_256M;		
      wire                                                        pgsize_gte_1G;		
      wire                                                        pgsize_gte_4G;		
      wire                                                        pgsize_gte_16G;		
      wire                                                        pgsize_gte_256G;		
      wire                                                        pgsize_gte_1T;		
      
      wire                                                        comp_or_24_25;
      wire                                                        comp_or_26_29;
      wire                                                        comp_or_30_31;
      wire                                                        comp_or_32_33;
      wire                                                        comp_or_34_35;
      wire                                                        comp_or_36_39;
      wire                                                        comp_or_40_43;
      
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2+`LPID_WIDTH-1] match_line;
      wire                                                        addr_match;
      wire                                                        lpid_match;
      
      (* analysis_not_referenced="true" *)  
      wire [0:2]                                                  unused_dc;
      
      assign match_line[64-`REAL_ADDR_WIDTH : 64-`LRAT_MINSIZE_LOG2+`LPID_WIDTH-1] = 
                                      (~ (({entry_lpn[64-`REAL_ADDR_WIDTH : 64-`LRAT_MINSIZE_LOG2-1], entry_lpid[0:`LPID_WIDTH-1]}) ^ 
                                          ({  addr_in[64-`REAL_ADDR_WIDTH : 64-`LRAT_MINSIZE_LOG2-1], comp_lpid[0:`LPID_WIDTH-1]})) );
      
      generate
         if (NUM_PGSIZES == 8)
         begin : numpgsz8
            assign entry_lpn_b[64 - `LRAT_MAXSIZE_LOG2:64 - `LRAT_MINSIZE_LOG2 - 1] = (~(entry_lpn[64 - `LRAT_MAXSIZE_LOG2:64 - `LRAT_MINSIZE_LOG2 - 1]));
            
            if (HAVE_CMPMASK == 0)		
            begin : gen_nocmpmask80
               assign pgsize_eq_16M = ((entry_size == 4'b0111)) ? 1'b1 : 
                                      1'b0;
               assign pgsize_eq_256M = ((entry_size == 4'b1001)) ? 1'b1 : 		
                                       1'b0;
               assign pgsize_eq_1G = ((entry_size == 4'b1010)) ? 1'b1 : 		
                                     1'b0;
               assign pgsize_eq_4G = ((entry_size == 4'b1011)) ? 1'b1 : 		
                                     1'b0;
               assign pgsize_eq_16G = ((entry_size == 4'b1100)) ? 1'b1 : 		
                                      1'b0;
               assign pgsize_eq_256G = ((entry_size == 4'b1110)) ? 1'b1 : 		
                                       1'b0;
               assign pgsize_eq_1T = ((entry_size == 4'b1111)) ? 1'b1 : 		
                                     1'b0;
               
               assign pgsize_gte_16M = ((entry_size == 4'b0111 | pgsize_gte_256M == 1'b1)) ? 1'b1 : 		
                                       1'b0;
               assign pgsize_gte_256M = ((entry_size == 4'b1001 | pgsize_gte_1G == 1'b1)) ? 1'b1 : 		
                                        1'b0;
               assign pgsize_gte_1G = ((entry_size == 4'b1010 | pgsize_gte_4G == 1'b1)) ? 1'b1 : 		
                                      1'b0;
               assign pgsize_gte_4G = ((entry_size == 4'b1011 | pgsize_gte_16G == 1'b1)) ? 1'b1 : 		
                                      1'b0;
               assign pgsize_gte_16G = ((entry_size == 4'b1100 | pgsize_gte_256G == 1'b1)) ? 1'b1 : 		
                                       1'b0;
               assign pgsize_gte_256G = ((entry_size == 4'b1110 | pgsize_gte_1T == 1'b1)) ? 1'b1 : 		
                                        1'b0;
               assign pgsize_gte_1T = ((entry_size == 4'b1111)) ? 1'b1 : 		
                                      1'b0;
            end
         
         if (HAVE_CMPMASK == 1)
         begin : gen_cmpmask80
            assign pgsize_gte_1T = entry_cmpmask[0];
            assign pgsize_gte_256G = entry_cmpmask[1];
            assign pgsize_gte_16G = entry_cmpmask[2];
            assign pgsize_gte_4G = entry_cmpmask[3];
            assign pgsize_gte_1G = entry_cmpmask[4];
            assign pgsize_gte_256M = entry_cmpmask[5];
            assign pgsize_gte_16M = entry_cmpmask[6];
            
            assign pgsize_eq_1T   = entry_xbitmask[0];
            assign pgsize_eq_256G = entry_xbitmask[1];
            assign pgsize_eq_16G  = entry_xbitmask[2];
            assign pgsize_eq_4G   = entry_xbitmask[3];
            assign pgsize_eq_1G   = entry_xbitmask[4];
            assign pgsize_eq_256M = entry_xbitmask[5];
            assign pgsize_eq_16M  = entry_xbitmask[6];
         end
      
      if (HAVE_XBIT == 0)
      begin : gen_noxbit80
         assign function_24_43 = 1'b0;
         assign function_26_43 = 1'b0;
         assign function_30_43 = 1'b0;
         assign function_32_43 = 1'b0;
         assign function_34_43 = 1'b0;
         assign function_36_43 = 1'b0;
         assign function_40_43 = 1'b0;
      end
   
   if (HAVE_XBIT != 0 & `REAL_ADDR_WIDTH == 42)
   begin : gen_xbit80
      assign function_24_43 = (~(entry_xbit)) | (~(pgsize_eq_1T))   | |(entry_lpn_b[24:43] & addr_in[24:43]);
      assign function_26_43 = (~(entry_xbit)) | (~(pgsize_eq_256G)) | |(entry_lpn_b[26:43] & addr_in[26:43]);
      assign function_30_43 = (~(entry_xbit)) | (~(pgsize_eq_16G))  | |(entry_lpn_b[30:43] & addr_in[30:43]);
      assign function_32_43 = (~(entry_xbit)) | (~(pgsize_eq_4G))   | |(entry_lpn_b[32:43] & addr_in[32:43]);
      assign function_34_43 = (~(entry_xbit)) | (~(pgsize_eq_1G))   | |(entry_lpn_b[34:43] & addr_in[34:43]);
      assign function_36_43 = (~(entry_xbit)) | (~(pgsize_eq_256M)) | |(entry_lpn_b[36:43] & addr_in[36:43]);
      assign function_40_43 = (~(entry_xbit)) | (~(pgsize_eq_16M))  | |(entry_lpn_b[40:43] & addr_in[40:43]);
   end

if (HAVE_XBIT != 0 & `REAL_ADDR_WIDTH == 32)
begin : gen_xbit81
   assign function_24_43 = 1'b1;
   assign function_26_43 = 1'b1;
   assign function_30_43 = 1'b1;
   assign function_32_43 = 1'b1;
   assign function_34_43 = (~(entry_xbit)) | (~(pgsize_eq_1G))   | |(entry_lpn_b[34:43] & addr_in[34:43]);
   assign function_36_43 = (~(entry_xbit)) | (~(pgsize_eq_256M)) | |(entry_lpn_b[36:43] & addr_in[36:43]);
   assign function_40_43 = (~(entry_xbit)) | (~(pgsize_eq_16M))  | |(entry_lpn_b[40:43] & addr_in[40:43]);
end

if (`REAL_ADDR_WIDTH == 42)
begin : gen_comp80
assign comp_or_24_25 = &(match_line[24:25]) | pgsize_gte_1T;
assign comp_or_26_29 = &(match_line[26:29]) | pgsize_gte_256G;
assign comp_or_30_31 = &(match_line[30:31]) | pgsize_gte_16G;
assign comp_or_32_33 = &(match_line[32:33]) | pgsize_gte_4G;
assign comp_or_34_35 = &(match_line[34:35]) | pgsize_gte_1G;
assign comp_or_36_39 = &(match_line[36:39]) | pgsize_gte_256M;
assign comp_or_40_43 = &(match_line[40:43]) | pgsize_gte_16M;
end

if (`REAL_ADDR_WIDTH == 32)
begin : gen_comp81
assign comp_or_24_25 = 1'b1;
assign comp_or_26_29 = 1'b1;
assign comp_or_30_31 = 1'b1;
assign comp_or_32_33 = 1'b1;
assign comp_or_34_35 = &(match_line[34:35]) | pgsize_gte_1G;
assign comp_or_36_39 = &(match_line[36:39]) | pgsize_gte_256M;
assign comp_or_40_43 = &(match_line[40:43]) | pgsize_gte_16M;
end

if (HAVE_XBIT == 0 & `REAL_ADDR_WIDTH == 42)
begin : gen_noxbit81
assign addr_match = ( &(match_line[22:23]) & 
                         comp_or_24_25 & 
                         comp_or_26_29 & 
                         comp_or_30_31 & 
                         comp_or_32_33 & 
                         comp_or_34_35 & 
                         comp_or_36_39 & 
                         comp_or_40_43 ) | (~(addr_enable));		
end

if (HAVE_XBIT == 0 & `REAL_ADDR_WIDTH == 32)
begin : gen_noxbit82
assign addr_match = ( &(match_line[32:33]) & 
                         comp_or_34_35 & 
                         comp_or_36_39 & 
                         comp_or_40_43 ) | (~(addr_enable));		
end

if (HAVE_XBIT != 0 & `REAL_ADDR_WIDTH == 42)
begin : gen_xbit82
assign addr_match = ( &(match_line[22:23]) & 
                         comp_or_24_25 & 
                         comp_or_26_29 & 
                         comp_or_30_31 & 
                         comp_or_32_33 & 
                         comp_or_34_35 & 
                         comp_or_36_39 & 
                         comp_or_40_43 & 
                         function_24_43 & 
                         function_26_43 & 
                         function_30_43 & 
                         function_32_43 & 
                         function_34_43 & 
                         function_36_43 & 
                         function_40_43 ) | (~(addr_enable));		
end

if (HAVE_XBIT != 0 & `REAL_ADDR_WIDTH == 32)
begin : gen_xbit83
assign addr_match = ( &(match_line[32:33]) & 
                         comp_or_34_35 & 
                         comp_or_36_39 & 
                         comp_or_40_43 & 
                         function_34_43 & 
                         function_36_43 & 
                         function_40_43 ) | (~(addr_enable));		
end
end
endgenerate




assign lpid_match = &(match_line[64 - `LRAT_MINSIZE_LOG2:64 - `LRAT_MINSIZE_LOG2 + `LPID_WIDTH - 1]) | (~(|(entry_lpid[0:7]))) | (~(lpid_enable));

assign match = addr_match & lpid_match & entry_v;		

assign dbg_addr_match = addr_match;		
assign dbg_lpid_match = lpid_match;		

generate
if (HAVE_CMPMASK == 0)
begin : gen_unused0
assign unused_dc[0] = 1'b0;
assign unused_dc[1] = vdd;
assign unused_dc[2] = gnd;
end
endgenerate

generate
if (HAVE_CMPMASK == 1)
begin : gen_unused1
assign unused_dc[0] = |(entry_size);
assign unused_dc[1] = vdd;
assign unused_dc[2] = gnd;
end
endgenerate

endmodule

