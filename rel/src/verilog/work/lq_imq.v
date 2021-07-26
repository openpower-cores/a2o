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
//  Description:  XU LSU Store Data Rotator Wrapper
//
//*****************************************************************************

// ##########################################################################################
// VHDL Contents
// 1) Load Queue
// 2) Store Queue
// 3) Load/Store Queue Control
// ##########################################################################################

`include "tri_a2o.vh"

//   parameter                          EXPAND_TYPE = 2;		// 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
//   parameter                          THREADS = 2;		// Number of Threads
// `define                               IUQ_ENTRIES   4 		// Instruction Fetch Queue Size
// `define                               MMQ_ENTRIES   2 		// MMU Queue Size
//   parameter                          REAL_IFAR_WIDTH = 42;		// real addressing bits

module lq_imq(
   iu_lq_request,
   iu_lq_cTag,
   iu_lq_ra,
   iu_lq_wimge,
   iu_lq_userdef,
   mm_lq_lsu_req,
   mm_lq_lsu_ttype,
   mm_lq_lsu_wimge,
   mm_lq_lsu_u,
   mm_lq_lsu_addr,
   mm_lq_lsu_lpid,
   mm_lq_lsu_gs,
   mm_lq_lsu_ind,
   mm_lq_lsu_lbit,
   lq_mm_lsu_token,
   arb_imq_iuq_unit_sel,
   arb_imq_mmq_unit_sel,
   imq_arb_iuq_ld_req_avail,
   imq_arb_iuq_tid,
   imq_arb_iuq_usr_def,
   imq_arb_iuq_wimge,
   imq_arb_iuq_p_addr,
   imq_arb_iuq_ttype,
   imq_arb_iuq_opSize,
   imq_arb_iuq_cTag,
   imq_arb_mmq_ld_req_avail,
   imq_arb_mmq_st_req_avail,
   imq_arb_mmq_tid,
   imq_arb_mmq_usr_def,
   imq_arb_mmq_wimge,
   imq_arb_mmq_p_addr,
   imq_arb_mmq_ttype,
   imq_arb_mmq_opSize,
   imq_arb_mmq_cTag,
   imq_arb_mmq_st_data,
   vdd,
   gnd,
   nclk,
   sg_0,
   func_sl_thold_0_b,
   func_sl_force,
   func_slp_sl_thold_0_b,
   func_slp_sl_force,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   scan_in,
   scan_out
);

   // Instruction Fetches
   input [0:`THREADS-1]               iu_lq_request;
   input [0:1]                        iu_lq_cTag;
   input [64-`REAL_IFAR_WIDTH:59]     iu_lq_ra;
   input [0:4]                        iu_lq_wimge;
   input [0:3]                        iu_lq_userdef;

   // MMU instruction interface
   input [0:`THREADS-1]               mm_lq_lsu_req;		// will only pulse when mm has at least 1 token (1 bit per thread)
   input [0:1]                        mm_lq_lsu_ttype;		// 0=TLBIVAX; 1=TLBI_COMPLETE; 2=LOAD (tag=01100); 3=LOAD (tag=01101)
   input [0:4]                        mm_lq_lsu_wimge;
   input [0:3]                        mm_lq_lsu_u;		    // user defined bits
   input [64-`REAL_IFAR_WIDTH:63]     mm_lq_lsu_addr;		// address for TLBI (or loads; maybe);
   // TLBI_COMPLETE is addressless
   input [0:7]                        mm_lq_lsu_lpid;		// muxed LPID for the thread of the mmu command
   input                              mm_lq_lsu_gs;
   input                              mm_lq_lsu_ind;
   input                              mm_lq_lsu_lbit;		// "L" bit; for large vs. small
   output                             lq_mm_lsu_token;		// MMU Request has been sent

   // IUQ Request Sent
   input                              arb_imq_iuq_unit_sel;
   input                              arb_imq_mmq_unit_sel;

   // IUQ Request to the L2
   output                             imq_arb_iuq_ld_req_avail;
   output reg [0:1]                   imq_arb_iuq_tid;
   output reg [0:3]                   imq_arb_iuq_usr_def;
   output reg [0:4]                   imq_arb_iuq_wimge;
   output reg [64-`REAL_IFAR_WIDTH:63] imq_arb_iuq_p_addr;
   output [0:5]                       imq_arb_iuq_ttype;
   output [0:2]                       imq_arb_iuq_opSize;
   output reg [0:4]                   imq_arb_iuq_cTag;

   // MMQ Request to the L2
   output                             imq_arb_mmq_ld_req_avail;
   output                             imq_arb_mmq_st_req_avail;
   output reg [0:1]                   imq_arb_mmq_tid;
   output reg [0:3]                   imq_arb_mmq_usr_def;
   output reg [0:4]                   imq_arb_mmq_wimge;
   output reg [64-`REAL_IFAR_WIDTH:63] imq_arb_mmq_p_addr;
   output [0:5]                       imq_arb_mmq_ttype;
   output [0:2]                       imq_arb_mmq_opSize;
   output [0:4]                       imq_arb_mmq_cTag;
   output [0:15]                      imq_arb_mmq_st_data;

   // Pervasive


   inout                              vdd;


   inout                              gnd;

   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

   input [0:`NCLK_WIDTH-1]            nclk;
   input                              sg_0;
   input                              func_sl_thold_0_b;
   input                              func_sl_force;
   input                              func_slp_sl_thold_0_b;
   input                              func_slp_sl_force;
   input                              d_mode_dc;
   input                              delay_lclkr_dc;
   input                              mpw1_dc_b;
   input                              mpw2_dc_b;

   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

   input                              scan_in;

   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

   output                             scan_out;

   //--------------------------
   // signals
   //--------------------------
   wire [0:`IUQ_ENTRIES-1]            iuq_entry_wrt_ptr;
   wire [0:`IUQ_ENTRIES-1]            entry_iuq_set_val;
   wire [0:`IUQ_ENTRIES-1]            entry_iuq_clr_val;
   wire [0:`IUQ_ENTRIES-1]            iuq_entry_val_d;
   wire [0:`IUQ_ENTRIES-1]            iuq_entry_val_q;
   wire [64-`REAL_IFAR_WIDTH:59]      iuq_entry_p_addr_d[0:`IUQ_ENTRIES-1];
   wire [64-`REAL_IFAR_WIDTH:59]      iuq_entry_p_addr_q[0:`IUQ_ENTRIES-1];
   wire [0:1]                         iuq_entry_cTag_d[0:`IUQ_ENTRIES-1];
   wire [0:1]                         iuq_entry_cTag_q[0:`IUQ_ENTRIES-1];
   wire [0:4]                         iuq_entry_wimge_d[0:`IUQ_ENTRIES-1];
   wire [0:4]                         iuq_entry_wimge_q[0:`IUQ_ENTRIES-1];
   wire [0:3]                         iuq_entry_usr_def_d[0:`IUQ_ENTRIES-1];
   wire [0:3]                         iuq_entry_usr_def_q[0:`IUQ_ENTRIES-1];
   wire [0:1]                         iuq_entry_tid_d[0:`IUQ_ENTRIES-1];
   wire [0:1]                         iuq_entry_tid_q[0:`IUQ_ENTRIES-1];
   wire [0:2]                         iuq_entry_seq_d[0:`IUQ_ENTRIES-1];
   wire [0:2]                         iuq_entry_seq_q[0:`IUQ_ENTRIES-1];
   wire [0:2]                         iuq_seq_d;
   wire [0:2]                         iuq_seq_q;
   wire [0:2]                         iuq_seq_incr;
   wire                               iu_req_val;
   reg [0:1]                          iu_req_tid;
   wire [0:2]                         iuq_seq_rd_d;
   wire [0:2]                         iuq_seq_rd_q;
   wire [0:2]                         iuq_seq_rd_incr;
   wire [0:`IUQ_ENTRIES-1]            iuq_entry_sel;
   wire [0:`MMQ_ENTRIES-1]            mmq_entry_wrt_ptr;
   wire [0:`MMQ_ENTRIES-1]            entry_mmq_set_val;
   wire [0:`MMQ_ENTRIES-1]            entry_mmq_clr_val;
   wire [0:`MMQ_ENTRIES-1]            mmq_entry_val_d;
   wire [0:`MMQ_ENTRIES-1]            mmq_entry_val_q;
   wire [64-`REAL_IFAR_WIDTH:63]      mmq_entry_p_addr_d[0:`MMQ_ENTRIES-1];
   wire [64-`REAL_IFAR_WIDTH:63]      mmq_entry_p_addr_q[0:`MMQ_ENTRIES-1];
   wire [0:1]                         mmq_entry_ttype_d[0:`MMQ_ENTRIES-1];
   wire [0:1]                         mmq_entry_ttype_q[0:`MMQ_ENTRIES-1];
   wire [0:4]                         mmq_entry_wimge_d[0:`MMQ_ENTRIES-1];
   wire [0:4]                         mmq_entry_wimge_q[0:`MMQ_ENTRIES-1];
   wire [0:3]                         mmq_entry_usr_def_d[0:`MMQ_ENTRIES-1];
   wire [0:3]                         mmq_entry_usr_def_q[0:`MMQ_ENTRIES-1];
   wire [0:1]                         mmq_entry_tid_d[0:`MMQ_ENTRIES-1];
   wire [0:1]                         mmq_entry_tid_q[0:`MMQ_ENTRIES-1];
   wire [0:2]                         mmq_entry_seq_d[0:`MMQ_ENTRIES-1];
   wire [0:2]                         mmq_entry_seq_q[0:`MMQ_ENTRIES-1];
   wire [0:7]                         mmq_entry_lpid_d[0:`MMQ_ENTRIES-1];
   wire [0:7]                         mmq_entry_lpid_q[0:`MMQ_ENTRIES-1];
   wire [0:`MMQ_ENTRIES-1]            mmq_entry_ind_d;
   wire [0:`MMQ_ENTRIES-1]            mmq_entry_ind_q;
   wire [0:`MMQ_ENTRIES-1]            mmq_entry_gs_d;
   wire [0:`MMQ_ENTRIES-1]            mmq_entry_gs_q;
   wire [0:`MMQ_ENTRIES-1]            mmq_entry_lbit_d;
   wire [0:`MMQ_ENTRIES-1]            mmq_entry_lbit_q;
   wire                               mmq_ret_token_d;
   wire                               mmq_ret_token_q;
   wire [0:2]                         mmq_seq_d;
   wire [0:2]                         mmq_seq_q;
   wire                               mm_req_val;
   reg [0:1]                          mm_req_tid;
   wire                               mmq_req_sent;
   wire [0:2]                         mmq_seq_incr;
   wire [0:2]                         mmq_seq_rd_d;
   wire [0:2]                         mmq_seq_rd_q;
   wire [0:2]                         mmq_seq_rd_incr;
   wire [0:`MMQ_ENTRIES-1]            mmq_entry_sel;
   reg [0:1]                          mmq_ttype_enc;
   reg [0:7]                          mmq_lpid;
   reg                                mmq_ind;
   reg                                mmq_gs;
   reg                                mmq_lbit;
   wire                               iu_lq_int_act;
   wire [0:`THREADS-1]                iu_lq_request_d;
   wire [0:`THREADS-1]                iu_lq_request_q;
   wire [0:1]                         iu_lq_cTag_d;
   wire [0:1]                         iu_lq_cTag_q;
   wire [64-`REAL_IFAR_WIDTH:59]      iu_lq_ra_d;
   wire [64-`REAL_IFAR_WIDTH:59]      iu_lq_ra_q;
   wire [0:4]                         iu_lq_wimge_d;
   wire [0:4]                         iu_lq_wimge_q;
   wire [0:3]                         iu_lq_userdef_d;
   wire [0:3]                         iu_lq_userdef_q;
   wire                               mm_lq_int_act;
   wire [0:`THREADS-1]                mm_lq_lsu_req_d;
   wire [0:`THREADS-1]                mm_lq_lsu_req_q;
   wire [0:1]                         mm_lq_lsu_ttype_d;
   wire [0:1]                         mm_lq_lsu_ttype_q;
   wire [0:4]                         mm_lq_lsu_wimge_d;
   wire [0:4]                         mm_lq_lsu_wimge_q;
   wire [0:3]                         mm_lq_lsu_u_d;
   wire [0:3]                         mm_lq_lsu_u_q;
   wire [64-`REAL_IFAR_WIDTH:63]      mm_lq_lsu_addr_d;
   wire [64-`REAL_IFAR_WIDTH:63]      mm_lq_lsu_addr_q;
   wire [0:7]                         mm_lq_lsu_lpid_d;
   wire [0:7]                         mm_lq_lsu_lpid_q;
   wire                               mm_lq_lsu_gs_d;
   wire                               mm_lq_lsu_gs_q;
   wire                               mm_lq_lsu_ind_d;
   wire                               mm_lq_lsu_ind_q;
   wire                               mm_lq_lsu_lbit_d;
   wire                               mm_lq_lsu_lbit_q;

   //--------------------------
   // constants
   //--------------------------

   parameter                          iu_lq_request_offset = 0;
   parameter                          iu_lq_cTag_offset = iu_lq_request_offset + `THREADS;
   parameter                          iu_lq_ra_offset = iu_lq_cTag_offset + 2;
   parameter                          iu_lq_wimge_offset = iu_lq_ra_offset + (`REAL_IFAR_WIDTH-4);
   parameter                          iu_lq_userdef_offset = iu_lq_wimge_offset + 5;
   parameter                          mm_lq_lsu_req_offset = iu_lq_userdef_offset + 4;
   parameter                          mm_lq_lsu_ttype_offset = mm_lq_lsu_req_offset + `THREADS;
   parameter                          mm_lq_lsu_addr_offset = mm_lq_lsu_ttype_offset + 2;
   parameter                          mm_lq_lsu_wimge_offset = mm_lq_lsu_addr_offset + `REAL_IFAR_WIDTH;
   parameter                          mm_lq_lsu_u_offset = mm_lq_lsu_wimge_offset + 5;
   parameter                          mm_lq_lsu_lpid_offset = mm_lq_lsu_u_offset + 4;
   parameter                          mm_lq_lsu_gs_offset = mm_lq_lsu_lpid_offset + 8;
   parameter                          mm_lq_lsu_ind_offset = mm_lq_lsu_gs_offset + 1;
   parameter                          mm_lq_lsu_lbit_offset = mm_lq_lsu_ind_offset + 1;
   parameter                          iuq_entry_val_offset = mm_lq_lsu_lbit_offset + 1;
   parameter                          iuq_entry_p_addr_offset = iuq_entry_val_offset + `IUQ_ENTRIES;
   parameter                          iuq_entry_cTag_offset = iuq_entry_p_addr_offset + (`REAL_IFAR_WIDTH - 4) * `IUQ_ENTRIES;
   parameter                          iuq_entry_wimge_offset = iuq_entry_cTag_offset + 2 * `IUQ_ENTRIES;
   parameter                          iuq_entry_usr_def_offset = iuq_entry_wimge_offset + 5 * `IUQ_ENTRIES;
   parameter                          iuq_entry_tid_offset = iuq_entry_usr_def_offset + 4 * `IUQ_ENTRIES;
   parameter                          iuq_entry_seq_offset = iuq_entry_tid_offset + (`IUQ_ENTRIES) * (2);
   parameter                          iuq_seq_offset = iuq_entry_seq_offset + 3 * `IUQ_ENTRIES;
   parameter                          iuq_seq_rd_offset = iuq_seq_offset + 3;
   parameter                          mmq_entry_val_offset = iuq_seq_rd_offset + 3;
   parameter                          mmq_entry_p_addr_offset = mmq_entry_val_offset + `MMQ_ENTRIES;
   parameter                          mmq_entry_ttype_offset = mmq_entry_p_addr_offset + `REAL_IFAR_WIDTH * `MMQ_ENTRIES;
   parameter                          mmq_entry_wimge_offset = mmq_entry_ttype_offset + 2 * `MMQ_ENTRIES;
   parameter                          mmq_entry_usr_def_offset = mmq_entry_wimge_offset + 5 * `MMQ_ENTRIES;
   parameter                          mmq_entry_tid_offset = mmq_entry_usr_def_offset + 4 * `MMQ_ENTRIES;
   parameter                          mmq_entry_seq_offset = mmq_entry_tid_offset + (`MMQ_ENTRIES) * (2);
   parameter                          mmq_entry_lpid_offset = mmq_entry_seq_offset + 3 * `MMQ_ENTRIES;
   parameter                          mmq_entry_ind_offset = mmq_entry_lpid_offset + 8 * `MMQ_ENTRIES;
   parameter                          mmq_entry_gs_offset = mmq_entry_ind_offset + `MMQ_ENTRIES;
   parameter                          mmq_entry_lbit_offset = mmq_entry_gs_offset + `MMQ_ENTRIES;
   parameter                          mmq_ret_token_offset = mmq_entry_lbit_offset + `MMQ_ENTRIES;
   parameter                          mmq_seq_offset = mmq_ret_token_offset + 1;
   parameter                          mmq_seq_rd_offset = mmq_seq_offset + 3;
   parameter                          scan_right = mmq_seq_rd_offset + 3 - 1;

   wire                               tiup;
   wire                               tidn;
   wire [0:scan_right]                siv;
   wire [0:scan_right]                sov;

   //!! Bugspray Include: lq_imq

   assign tiup = 1'b1;
   assign tidn = 1'b0;

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // INPUTS LATCHED
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   assign iu_lq_int_act     = |(iu_lq_request);
   assign iu_lq_request_d   = iu_lq_request;
   assign iu_lq_cTag_d      = iu_lq_cTag;
   assign iu_lq_ra_d        = iu_lq_ra;
   assign iu_lq_wimge_d     = iu_lq_wimge;
   assign iu_lq_userdef_d   = iu_lq_userdef;
   assign mm_lq_int_act     = |(mm_lq_lsu_req);
   assign mm_lq_lsu_req_d   = mm_lq_lsu_req;
   assign mm_lq_lsu_ttype_d = mm_lq_lsu_ttype;
   assign mm_lq_lsu_wimge_d = mm_lq_lsu_wimge;
   assign mm_lq_lsu_u_d     = mm_lq_lsu_u;
   assign mm_lq_lsu_addr_d  = mm_lq_lsu_addr;
   assign mm_lq_lsu_lpid_d  = mm_lq_lsu_lpid;
   assign mm_lq_lsu_gs_d    = mm_lq_lsu_gs;
   assign mm_lq_lsu_ind_d   = mm_lq_lsu_ind;
   assign mm_lq_lsu_lbit_d  = mm_lq_lsu_lbit;

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // `THREADS ENCODE
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   always @(*) begin: tidMulti
      reg [0:1]                          iuTid;
      reg [0:1]                          mmTid;
      integer                            tid;
      iuTid = {2{1'b0}};
      mmTid = {2{1'b0}};
      for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
      begin
         iuTid = (tid & {2{iu_lq_request_q[tid]}}) | iuTid;
         mmTid = (tid & {2{mm_lq_lsu_req_q[tid]}}) | mmTid;
      end
      iu_req_tid <= iuTid;
      mm_req_tid <= mmTid;
   end

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // INSTRUCTION FETCH QUEUE LOGIC
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   // Sequence number for IUQ Requests
   assign iuq_seq_incr = iuq_seq_q + 3'b001;
   assign iu_req_val   = |(iu_lq_request_q);

   assign iuq_seq_d = (iu_req_val == 1'b1) ? iuq_seq_incr :
                                             iuq_seq_q;

   // Pointer to next IUQ request to be sent to the L2
   assign iuq_seq_rd_incr = iuq_seq_rd_q + 3'b001;

   assign iuq_seq_rd_d = (arb_imq_iuq_unit_sel == 1'b1) ? iuq_seq_rd_incr :
                                                          iuq_seq_rd_q;

   // Update Logic
   assign iuq_entry_wrt_ptr[0] = (~iuq_entry_val_q[0]);
   generate begin : IuPriWrt
     genvar iuq;
     for (iuq = 1; iuq <= `IUQ_ENTRIES - 1; iuq = iuq + 1) begin : IuPriWrt
        assign iuq_entry_wrt_ptr[iuq] = &(iuq_entry_val_q[0:iuq - 1]) & (~iuq_entry_val_q[iuq]);
     end
   end
   endgenerate

   generate begin : InstrQ
     genvar iuq;
     for (iuq = 0; iuq <= `IUQ_ENTRIES - 1; iuq = iuq + 1) begin : InstrQ
        assign entry_iuq_set_val[iuq] = iu_req_val & iuq_entry_wrt_ptr[iuq];
        assign entry_iuq_clr_val[iuq] = arb_imq_iuq_unit_sel & iuq_entry_sel[iuq];

        assign iuq_entry_val_d[iuq] = ({entry_iuq_set_val[iuq], entry_iuq_clr_val[iuq]} == 2'b10) ? 1'b1 :
                                      ({entry_iuq_set_val[iuq], entry_iuq_clr_val[iuq]} == 2'b01) ? 1'b0 :
                                                                                                    iuq_entry_val_q[iuq];

        assign iuq_entry_p_addr_d[iuq] = (entry_iuq_set_val[iuq] == 1'b1) ? iu_lq_ra_q :
                                                                            iuq_entry_p_addr_q[iuq];

        assign iuq_entry_cTag_d[iuq] = (entry_iuq_set_val[iuq] == 1'b1) ? iu_lq_cTag_q :
                                                                          iuq_entry_cTag_q[iuq];

        assign iuq_entry_wimge_d[iuq] = (entry_iuq_set_val[iuq] == 1'b1) ? iu_lq_wimge_q :
                                                                           iuq_entry_wimge_q[iuq];

        assign iuq_entry_usr_def_d[iuq] = (entry_iuq_set_val[iuq] == 1'b1) ? iu_lq_userdef_q :
                                                                             iuq_entry_usr_def_q[iuq];

        assign iuq_entry_tid_d[iuq] = (entry_iuq_set_val[iuq] == 1'b1) ? iu_req_tid :
                                                                         iuq_entry_tid_q[iuq];

        assign iuq_entry_seq_d[iuq] = (entry_iuq_set_val[iuq] == 1'b1) ? iuq_seq_q :
                                                                         iuq_entry_seq_q[iuq];
     end
   end
   endgenerate

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   // INSTRUCTION FETCH REQUEST ARBITRATION
   // ##############################################

   // Instruction Fetches contain a sequence number that indicates an order
   // They are sent to the L2 in the order recieved

   generate begin : IQSel
     genvar iuq;
     for (iuq = 0; iuq <= `IUQ_ENTRIES - 1; iuq = iuq + 1) begin : IQSel
        assign iuq_entry_sel[iuq] = (iuq_seq_rd_q == iuq_entry_seq_q[iuq]) & iuq_entry_val_q[iuq];
     end
   end
   endgenerate

   // Mux Load Queue Entry between Groups

   always @(*) begin: IqMux
      reg [0:3]                          usrDef;
      reg [0:4]                          wimge;
      reg [64-`REAL_IFAR_WIDTH:59]        pAddr;
      reg [0:1]                          cTag;
      reg [0:1]                          tid;
      integer                            iuq;
      usrDef = {4{1'b0}};
      wimge  = {5{1'b0}};
      pAddr  = {`REAL_IFAR_WIDTH-4{1'b0}};
      cTag   = {2{1'b0}};
      tid    = {2{1'b0}};
      for (iuq = 0; iuq <= `IUQ_ENTRIES - 1; iuq = iuq + 1)
      begin
         usrDef = (iuq_entry_usr_def_q[iuq] & {4{iuq_entry_sel[iuq]}}) | usrDef;
         wimge  = (iuq_entry_wimge_q[iuq]   & {5{iuq_entry_sel[iuq]}}) | wimge;
         pAddr  = (iuq_entry_p_addr_q[iuq]  & {`REAL_IFAR_WIDTH-4{iuq_entry_sel[iuq]}}) | pAddr;
         cTag   = (iuq_entry_cTag_q[iuq]    & {2{iuq_entry_sel[iuq]}}) | cTag;
         tid    = (iuq_entry_tid_q[iuq]     & {2{iuq_entry_sel[iuq]}}) | tid;
      end
      imq_arb_iuq_usr_def <= usrDef;
      imq_arb_iuq_wimge <= wimge;
      imq_arb_iuq_p_addr <= {pAddr, 4'b0000};
      imq_arb_iuq_cTag <= {3'b010, cTag};
      imq_arb_iuq_tid <= tid;
   end

   assign imq_arb_iuq_ttype = {6{1'b0}};
   assign imq_arb_iuq_opSize = 3'b110;

   assign imq_arb_iuq_ld_req_avail = |(iuq_entry_val_q);

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // MMU QUEUE
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   // MMQ Request Has been Sent
   assign mmq_req_sent    = arb_imq_mmq_unit_sel;
   assign mmq_ret_token_d = mmq_req_sent;

   // Sequence number for MMQ Requests
   assign mmq_seq_incr = mmq_seq_q + 3'b001;
   assign mm_req_val   = |(mm_lq_lsu_req_q);

   assign mmq_seq_d = (mm_req_val == 1'b1) ? mmq_seq_incr :
                                             mmq_seq_q;

   // Pointer to next MMQ request to be sent to the L2
   assign mmq_seq_rd_incr = mmq_seq_rd_q + 3'b001;

   assign mmq_seq_rd_d = (mmq_req_sent == 1'b1) ? mmq_seq_rd_incr :
                                                  mmq_seq_rd_q;

   // Update Logic
   assign mmq_entry_wrt_ptr[0] = (~mmq_entry_val_q[0]);

   generate begin : MmuPriWrt
     genvar mmq;
     for (mmq = 1; mmq <= `MMQ_ENTRIES - 1; mmq = mmq + 1) begin : MmuPriWrt
        assign mmq_entry_wrt_ptr[mmq] = &(mmq_entry_val_q[0:mmq - 1]) & (~mmq_entry_val_q[mmq]);
     end
   end
   endgenerate

   generate begin : mmuQ
     genvar mmq;
     for (mmq = 0; mmq <= `MMQ_ENTRIES - 1; mmq = mmq + 1) begin : mmuQ
        assign entry_mmq_set_val[mmq] = mm_req_val & mmq_entry_wrt_ptr[mmq];
        assign entry_mmq_clr_val[mmq] = mmq_req_sent & mmq_entry_sel[mmq];
        assign mmq_entry_val_d[mmq] = ({entry_mmq_set_val[mmq], entry_mmq_clr_val[mmq]} == 2'b10) ? 1'b1 :
                                      ({entry_mmq_set_val[mmq], entry_mmq_clr_val[mmq]} == 2'b01) ? 1'b0 :
                                                                                                    mmq_entry_val_q[mmq];

        assign mmq_entry_p_addr_d[mmq]  = (entry_mmq_set_val[mmq] == 1'b1) ? mm_lq_lsu_addr_q :
                                                                             mmq_entry_p_addr_q[mmq];

        assign mmq_entry_ttype_d[mmq]   = (entry_mmq_set_val[mmq] == 1'b1) ? mm_lq_lsu_ttype_q :
                                                                             mmq_entry_ttype_q[mmq];

        assign mmq_entry_wimge_d[mmq]   = (entry_mmq_set_val[mmq] == 1'b1) ? mm_lq_lsu_wimge_q :
                                                                             mmq_entry_wimge_q[mmq];

        assign mmq_entry_usr_def_d[mmq] = (entry_mmq_set_val[mmq] == 1'b1) ? mm_lq_lsu_u_q :
                                                                             mmq_entry_usr_def_q[mmq];

        assign mmq_entry_tid_d[mmq]     = (entry_mmq_set_val[mmq] == 1'b1) ? mm_req_tid :
                                                                             mmq_entry_tid_q[mmq];

        assign mmq_entry_seq_d[mmq]     = (entry_mmq_set_val[mmq] == 1'b1) ? mmq_seq_q :
                                                                             mmq_entry_seq_q[mmq];

        assign mmq_entry_lpid_d[mmq]    = (entry_mmq_set_val[mmq] == 1'b1) ? mm_lq_lsu_lpid_q :
                                                                             mmq_entry_lpid_q[mmq];

        assign mmq_entry_ind_d[mmq]     = (entry_mmq_set_val[mmq] == 1'b1) ? mm_lq_lsu_ind_q :
                                                                             mmq_entry_ind_q[mmq];

        assign mmq_entry_gs_d[mmq]      = (entry_mmq_set_val[mmq] == 1'b1) ? mm_lq_lsu_gs_q :
                                                                             mmq_entry_gs_q[mmq];

        assign mmq_entry_lbit_d[mmq]    = (entry_mmq_set_val[mmq] == 1'b1) ? mm_lq_lsu_lbit_q :
                                                                             mmq_entry_lbit_q[mmq];
     end
   end
   endgenerate

   // MMU REQUEST ARBITRATION
   // ##############################################

   // MMU Requests contain a sequence number that indicates an order
   // They are sent to the L2 in the order recieved

   generate begin : MQSel
     genvar mmq;
     for (mmq = 0; mmq <= `MMQ_ENTRIES - 1; mmq = mmq + 1) begin : MQSel
        assign mmq_entry_sel[mmq] = (mmq_seq_rd_q == mmq_entry_seq_q[mmq]) & mmq_entry_val_q[mmq];
     end
   end
   endgenerate

   // Mux Load Queue Entry between Groups
   always @(*) begin: MqMux
      reg [0:3]                          usrDef;
      reg [0:4]                          wimge;
      reg [64-`REAL_IFAR_WIDTH:63]        pAddr;
      reg [0:1]                          ttype;
      reg [0:7]                          lpid;
      reg                                ind;
      reg                                gs;
      reg                                lbit;
      reg [0:1]                          tid;
      integer                            mmq;
      usrDef = {4{1'b0}};
      wimge  = {5{1'b0}};
      pAddr  = {`REAL_IFAR_WIDTH{1'b0}};
      ttype  = {2{1'b0}};
      lpid   = {8{1'b0}};
      ind    = 1'b0;
      gs     = 1'b0;
      lbit   = 1'b0;
      tid    = {2{1'b0}};
      for (mmq = 0; mmq <= `MMQ_ENTRIES - 1; mmq = mmq + 1)
      begin
         usrDef = (mmq_entry_usr_def_q[mmq] & {4{mmq_entry_sel[mmq]}}) | usrDef;
         wimge  = (mmq_entry_wimge_q[mmq]   & {5{mmq_entry_sel[mmq]}}) | wimge;
         pAddr  = (mmq_entry_p_addr_q[mmq]  & {`REAL_IFAR_WIDTH{mmq_entry_sel[mmq]}}) | pAddr;
         ttype  = (mmq_entry_ttype_q[mmq]   & {2{mmq_entry_sel[mmq]}}) | ttype;
         lpid   = (mmq_entry_lpid_q[mmq]    & {8{mmq_entry_sel[mmq]}}) | lpid;
         ind    = (mmq_entry_ind_q[mmq]     & mmq_entry_sel[mmq]) | ind;
         gs     = (mmq_entry_gs_q[mmq]      & mmq_entry_sel[mmq]) | gs;
         lbit   = (mmq_entry_lbit_q[mmq]    & mmq_entry_sel[mmq]) | lbit;
         tid    = (mmq_entry_tid_q[mmq]     & {2{mmq_entry_sel[mmq]}}) | tid;
      end
      imq_arb_mmq_usr_def <= usrDef;
      imq_arb_mmq_wimge <= wimge;
      imq_arb_mmq_p_addr <= pAddr;
      mmq_ttype_enc <= ttype;
      mmq_lpid <= lpid;
      mmq_ind <= ind;
      mmq_gs <= gs;
      mmq_lbit <= lbit;
      imq_arb_mmq_tid <= tid;
   end

   assign imq_arb_mmq_ttype = (mmq_ttype_enc == 2'b00) ? 6'b111100 : 		// TLBIVAX
                              (mmq_ttype_enc == 2'b01) ? 6'b111011 : 		// TLBI COMPLETE
                                                         6'b000010;		// MMU LOAD

   assign imq_arb_mmq_cTag = (mmq_ttype_enc == 2'b10) ? 5'b01100 : 		// MMU Load TAG=0
                             (mmq_ttype_enc == 2'b11) ? 5'b01101 : 		// MMU Load TAG=1
                                                        5'b00000;		// TLB STORE TYPE

   assign imq_arb_mmq_opSize = {3{1'b0}};
   assign imq_arb_mmq_ld_req_avail = |(mmq_entry_val_q) & mmq_ttype_enc[0];
   assign imq_arb_mmq_st_req_avail = |(mmq_entry_val_q) & (~mmq_ttype_enc[0]);
   assign imq_arb_mmq_st_data = {mmq_lpid, 5'b00000, mmq_ind, mmq_gs, mmq_lbit};
   assign lq_mm_lsu_token = mmq_ret_token_q;
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // REGISTERS
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) iu_lq_request_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_lq_request_offset:iu_lq_request_offset + `THREADS - 1]),
      .scout(sov[iu_lq_request_offset:iu_lq_request_offset + `THREADS - 1]),
      .din(iu_lq_request_d),
      .dout(iu_lq_request_q)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) iu_lq_cTag_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu_lq_int_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_lq_cTag_offset:iu_lq_cTag_offset + 2 - 1]),
      .scout(sov[iu_lq_cTag_offset:iu_lq_cTag_offset + 2 - 1]),
      .din(iu_lq_cTag_d),
      .dout(iu_lq_cTag_q)
   );


   tri_rlmreg_p #(.WIDTH((`REAL_IFAR_WIDTH-4)), .INIT(0), .NEEDS_SRESET(1)) iu_lq_ra_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu_lq_int_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_lq_ra_offset:iu_lq_ra_offset + (`REAL_IFAR_WIDTH-4) - 1]),
      .scout(sov[iu_lq_ra_offset:iu_lq_ra_offset + (`REAL_IFAR_WIDTH-4) - 1]),
      .din(iu_lq_ra_d),
      .dout(iu_lq_ra_q)
   );


   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) iu_lq_wimge_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu_lq_int_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_lq_wimge_offset:iu_lq_wimge_offset + 5 - 1]),
      .scout(sov[iu_lq_wimge_offset:iu_lq_wimge_offset + 5 - 1]),
      .din(iu_lq_wimge_d),
      .dout(iu_lq_wimge_q)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) iu_lq_userdef_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu_lq_int_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_lq_userdef_offset:iu_lq_userdef_offset + 4 - 1]),
      .scout(sov[iu_lq_userdef_offset:iu_lq_userdef_offset + 4 - 1]),
      .din(iu_lq_userdef_d),
      .dout(iu_lq_userdef_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) mm_lq_lsu_req_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mm_lq_lsu_req_offset:mm_lq_lsu_req_offset + `THREADS - 1]),
      .scout(sov[mm_lq_lsu_req_offset:mm_lq_lsu_req_offset + `THREADS - 1]),
      .din(mm_lq_lsu_req_d),
      .dout(mm_lq_lsu_req_q)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) mm_lq_lsu_ttype_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mm_lq_int_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mm_lq_lsu_ttype_offset:mm_lq_lsu_ttype_offset + 2 - 1]),
      .scout(sov[mm_lq_lsu_ttype_offset:mm_lq_lsu_ttype_offset + 2 - 1]),
      .din(mm_lq_lsu_ttype_d),
      .dout(mm_lq_lsu_ttype_q)
   );


   tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) mm_lq_lsu_addr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mm_lq_int_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mm_lq_lsu_addr_offset:mm_lq_lsu_addr_offset + `REAL_IFAR_WIDTH - 1]),
      .scout(sov[mm_lq_lsu_addr_offset:mm_lq_lsu_addr_offset + `REAL_IFAR_WIDTH - 1]),
      .din(mm_lq_lsu_addr_d),
      .dout(mm_lq_lsu_addr_q)
   );


   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) mm_lq_lsu_wimge_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mm_lq_int_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mm_lq_lsu_wimge_offset:mm_lq_lsu_wimge_offset + 5 - 1]),
      .scout(sov[mm_lq_lsu_wimge_offset:mm_lq_lsu_wimge_offset + 5 - 1]),
      .din(mm_lq_lsu_wimge_d),
      .dout(mm_lq_lsu_wimge_q)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) mm_lq_lsu_u_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mm_lq_int_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mm_lq_lsu_u_offset:mm_lq_lsu_u_offset + 4 - 1]),
      .scout(sov[mm_lq_lsu_u_offset:mm_lq_lsu_u_offset + 4 - 1]),
      .din(mm_lq_lsu_u_d),
      .dout(mm_lq_lsu_u_q)
   );


   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) mm_lq_lsu_lpid_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mm_lq_int_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mm_lq_lsu_lpid_offset:mm_lq_lsu_lpid_offset + 8 - 1]),
      .scout(sov[mm_lq_lsu_lpid_offset:mm_lq_lsu_lpid_offset + 8 - 1]),
      .din(mm_lq_lsu_lpid_d),
      .dout(mm_lq_lsu_lpid_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mm_lq_lsu_gs_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mm_lq_int_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mm_lq_lsu_gs_offset]),
      .scout(sov[mm_lq_lsu_gs_offset]),
      .din(mm_lq_lsu_gs_d),
      .dout(mm_lq_lsu_gs_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mm_lq_lsu_ind_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mm_lq_int_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mm_lq_lsu_ind_offset]),
      .scout(sov[mm_lq_lsu_ind_offset]),
      .din(mm_lq_lsu_ind_d),
      .dout(mm_lq_lsu_ind_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mm_lq_lsu_lbit_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mm_lq_int_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mm_lq_lsu_lbit_offset]),
      .scout(sov[mm_lq_lsu_lbit_offset]),
      .din(mm_lq_lsu_lbit_d),
      .dout(mm_lq_lsu_lbit_q)
   );


   tri_rlmreg_p #(.WIDTH(`IUQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) iuq_entry_val_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iuq_entry_val_offset:iuq_entry_val_offset + `IUQ_ENTRIES - 1]),
      .scout(sov[iuq_entry_val_offset:iuq_entry_val_offset + `IUQ_ENTRIES - 1]),
      .din(iuq_entry_val_d),
      .dout(iuq_entry_val_q)
   );

   generate begin : iuq_entry_p_addr
     genvar                             iuq;
     for (iuq = 0; iuq <= `IUQ_ENTRIES - 1; iuq = iuq + 1) begin : iuq_entry_p_addr

        tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH - 4), .INIT(0), .NEEDS_SRESET(1)) iuq_entry_p_addr_reg(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(entry_iuq_set_val[iuq]),
           .force_t(func_sl_force),
           .d_mode(d_mode_dc),
           .delay_lclkr(delay_lclkr_dc),
           .mpw1_b(mpw1_dc_b),
           .mpw2_b(mpw2_dc_b),
           .thold_b(func_sl_thold_0_b),
           .sg(sg_0),
           .scin(siv[iuq_entry_p_addr_offset + ((`REAL_IFAR_WIDTH - 4) * iuq):iuq_entry_p_addr_offset + ((`REAL_IFAR_WIDTH - 4) * (iuq + 1)) - 1]),
           .scout(sov[iuq_entry_p_addr_offset + ((`REAL_IFAR_WIDTH - 4) * iuq):iuq_entry_p_addr_offset + ((`REAL_IFAR_WIDTH - 4) * (iuq + 1)) - 1]),
           .din(iuq_entry_p_addr_d[iuq]),
           .dout(iuq_entry_p_addr_q[iuq])
        );
     end
   end
   endgenerate

   generate begin : iuq_entry_cTag
     genvar                             iuq;
     for (iuq = 0; iuq <= `IUQ_ENTRIES - 1; iuq = iuq + 1) begin : iuq_entry_cTag

        tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) iuq_entry_cTag_reg(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(entry_iuq_set_val[iuq]),
           .force_t(func_sl_force),
           .d_mode(d_mode_dc),
           .delay_lclkr(delay_lclkr_dc),
           .mpw1_b(mpw1_dc_b),
           .mpw2_b(mpw2_dc_b),
           .thold_b(func_sl_thold_0_b),
           .sg(sg_0),
           .scin(siv[iuq_entry_cTag_offset + (2 * iuq):iuq_entry_cTag_offset + (2 * (iuq + 1)) - 1]),
           .scout(sov[iuq_entry_cTag_offset + (2 * iuq):iuq_entry_cTag_offset + (2 * (iuq + 1)) - 1]),
           .din(iuq_entry_cTag_d[iuq]),
           .dout(iuq_entry_cTag_q[iuq])
        );
     end
   end
   endgenerate

   generate begin : iuq_entry_wimge
     genvar                             iuq;
     for (iuq = 0; iuq <= `IUQ_ENTRIES - 1; iuq = iuq + 1) begin : iuq_entry_wimge

        tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) iuq_entry_wimge_reg(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(entry_iuq_set_val[iuq]),
           .force_t(func_sl_force),
           .d_mode(d_mode_dc),
           .delay_lclkr(delay_lclkr_dc),
           .mpw1_b(mpw1_dc_b),
           .mpw2_b(mpw2_dc_b),
           .thold_b(func_sl_thold_0_b),
           .sg(sg_0),
           .scin(siv[iuq_entry_wimge_offset + (5 * iuq):iuq_entry_wimge_offset + (5 * (iuq + 1)) - 1]),
           .scout(sov[iuq_entry_wimge_offset + (5 * iuq):iuq_entry_wimge_offset + (5 * (iuq + 1)) - 1]),
           .din(iuq_entry_wimge_d[iuq]),
           .dout(iuq_entry_wimge_q[iuq])
        );
     end
   end
   endgenerate

   generate begin : iuq_entry_usr_def
     genvar                             iuq;
     for (iuq = 0; iuq <= `IUQ_ENTRIES - 1; iuq = iuq + 1) begin : iuq_entry_usr_def

        tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) iuq_entry_usr_def_reg(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(entry_iuq_set_val[iuq]),
           .force_t(func_sl_force),
           .d_mode(d_mode_dc),
           .delay_lclkr(delay_lclkr_dc),
           .mpw1_b(mpw1_dc_b),
           .mpw2_b(mpw2_dc_b),
           .thold_b(func_sl_thold_0_b),
           .sg(sg_0),
           .scin(siv[iuq_entry_usr_def_offset + (4 * iuq):iuq_entry_usr_def_offset + (4 * (iuq + 1)) - 1]),
           .scout(sov[iuq_entry_usr_def_offset + (4 * iuq):iuq_entry_usr_def_offset + (4 * (iuq + 1)) - 1]),
           .din(iuq_entry_usr_def_d[iuq]),
           .dout(iuq_entry_usr_def_q[iuq])
        );
     end
   end
   endgenerate

   generate begin : iuq_entry_tid
     genvar                             iuq;
     for (iuq = 0; iuq <= `IUQ_ENTRIES - 1; iuq = iuq + 1) begin : iuq_entry_tid

        tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) iuq_entry_tid_reg(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(entry_iuq_set_val[iuq]),
           .force_t(func_sl_force),
           .d_mode(d_mode_dc),
           .delay_lclkr(delay_lclkr_dc),
           .mpw1_b(mpw1_dc_b),
           .mpw2_b(mpw2_dc_b),
           .thold_b(func_sl_thold_0_b),
           .sg(sg_0),
           .scin(siv[iuq_entry_tid_offset + (2 * iuq):iuq_entry_tid_offset + (2 * (iuq + 1)) - 1]),
           .scout(sov[iuq_entry_tid_offset + (2 * iuq):iuq_entry_tid_offset + (2 * (iuq + 1)) - 1]),
           .din(iuq_entry_tid_d[iuq]),
           .dout(iuq_entry_tid_q[iuq])
        );
     end
   end
   endgenerate

   generate begin : iuq_entry_seq
     genvar                             iuq;
     for (iuq = 0; iuq <= `IUQ_ENTRIES - 1; iuq = iuq + 1) begin : iuq_entry_seq

        tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) iuq_entry_seq_reg(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(entry_iuq_set_val[iuq]),
           .force_t(func_sl_force),
           .d_mode(d_mode_dc),
           .delay_lclkr(delay_lclkr_dc),
           .mpw1_b(mpw1_dc_b),
           .mpw2_b(mpw2_dc_b),
           .thold_b(func_sl_thold_0_b),
           .sg(sg_0),
           .scin(siv[iuq_entry_seq_offset + (3 * iuq):iuq_entry_seq_offset + (3 * (iuq + 1)) - 1]),
           .scout(sov[iuq_entry_seq_offset + (3 * iuq):iuq_entry_seq_offset + (3 * (iuq + 1)) - 1]),
           .din(iuq_entry_seq_d[iuq]),
           .dout(iuq_entry_seq_q[iuq])
        );
     end
   end
   endgenerate


   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) iuq_seq_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iuq_seq_offset:iuq_seq_offset + 3 - 1]),
      .scout(sov[iuq_seq_offset:iuq_seq_offset + 3 - 1]),
      .din(iuq_seq_d),
      .dout(iuq_seq_q)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) iuq_seq_rd_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iuq_seq_rd_offset:iuq_seq_rd_offset + 3 - 1]),
      .scout(sov[iuq_seq_rd_offset:iuq_seq_rd_offset + 3 - 1]),
      .din(iuq_seq_rd_d),
      .dout(iuq_seq_rd_q)
   );


   tri_rlmreg_p #(.WIDTH(`MMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) mmq_entry_val_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mmq_entry_val_offset:mmq_entry_val_offset + `MMQ_ENTRIES - 1]),
      .scout(sov[mmq_entry_val_offset:mmq_entry_val_offset + `MMQ_ENTRIES - 1]),
      .din(mmq_entry_val_d),
      .dout(mmq_entry_val_q)
   );

   generate begin : mmq_entry_p_addr
     genvar                             mmq;
     for (mmq = 0; mmq <= `MMQ_ENTRIES - 1; mmq = mmq + 1) begin : mmq_entry_p_addr

        tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) mmq_entry_p_addr_reg(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(entry_mmq_set_val[mmq]),
           .force_t(func_slp_sl_force),
           .d_mode(d_mode_dc),
           .delay_lclkr(delay_lclkr_dc),
           .mpw1_b(mpw1_dc_b),
           .mpw2_b(mpw2_dc_b),
           .thold_b(func_slp_sl_thold_0_b),
           .sg(sg_0),
           .scin(siv[mmq_entry_p_addr_offset + (`REAL_IFAR_WIDTH * mmq):mmq_entry_p_addr_offset + (`REAL_IFAR_WIDTH * (mmq + 1)) - 1]),
           .scout(sov[mmq_entry_p_addr_offset + (`REAL_IFAR_WIDTH * mmq):mmq_entry_p_addr_offset + (`REAL_IFAR_WIDTH * (mmq + 1)) - 1]),
           .din(mmq_entry_p_addr_d[mmq]),
           .dout(mmq_entry_p_addr_q[mmq])
        );
     end
   end
   endgenerate

   generate begin : mmq_entry_ttype
     genvar                             mmq;
     for (mmq = 0; mmq <= `MMQ_ENTRIES - 1; mmq = mmq + 1) begin : mmq_entry_ttype

        tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) mmq_entry_ttype_reg(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(entry_mmq_set_val[mmq]),
           .force_t(func_slp_sl_force),
           .d_mode(d_mode_dc),
           .delay_lclkr(delay_lclkr_dc),
           .mpw1_b(mpw1_dc_b),
           .mpw2_b(mpw2_dc_b),
           .thold_b(func_slp_sl_thold_0_b),
           .sg(sg_0),
           .scin(siv[mmq_entry_ttype_offset + (2 * mmq):mmq_entry_ttype_offset + (2 * (mmq + 1)) - 1]),
           .scout(sov[mmq_entry_ttype_offset + (2 * mmq):mmq_entry_ttype_offset + (2 * (mmq + 1)) - 1]),
           .din(mmq_entry_ttype_d[mmq]),
           .dout(mmq_entry_ttype_q[mmq])
        );
     end
   end
   endgenerate

   generate begin : mmq_entry_wimge
     genvar                             mmq;
     for (mmq = 0; mmq <= `MMQ_ENTRIES - 1; mmq = mmq + 1) begin : mmq_entry_wimge

        tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) mmq_entry_wimge_reg(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(entry_mmq_set_val[mmq]),
           .force_t(func_slp_sl_force),
           .d_mode(d_mode_dc),
           .delay_lclkr(delay_lclkr_dc),
           .mpw1_b(mpw1_dc_b),
           .mpw2_b(mpw2_dc_b),
           .thold_b(func_slp_sl_thold_0_b),
           .sg(sg_0),
           .scin(siv[mmq_entry_wimge_offset + (5 * mmq):mmq_entry_wimge_offset + (5 * (mmq + 1)) - 1]),
           .scout(sov[mmq_entry_wimge_offset + (5 * mmq):mmq_entry_wimge_offset + (5 * (mmq + 1)) - 1]),
           .din(mmq_entry_wimge_d[mmq]),
           .dout(mmq_entry_wimge_q[mmq])
        );
     end
   end
   endgenerate

   generate begin : mmq_entry_usr_def
     genvar                             mmq;
     for (mmq = 0; mmq <= `MMQ_ENTRIES - 1; mmq = mmq + 1) begin : mmq_entry_usr_def

        tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) mmq_entry_usr_def_reg(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(entry_mmq_set_val[mmq]),
           .force_t(func_slp_sl_force),
           .d_mode(d_mode_dc),
           .delay_lclkr(delay_lclkr_dc),
           .mpw1_b(mpw1_dc_b),
           .mpw2_b(mpw2_dc_b),
           .thold_b(func_slp_sl_thold_0_b),
           .sg(sg_0),
           .scin(siv[mmq_entry_usr_def_offset + (4 * mmq):mmq_entry_usr_def_offset + (4 * (mmq + 1)) - 1]),
           .scout(sov[mmq_entry_usr_def_offset + (4 * mmq):mmq_entry_usr_def_offset + (4 * (mmq + 1)) - 1]),
           .din(mmq_entry_usr_def_d[mmq]),
           .dout(mmq_entry_usr_def_q[mmq])
        );
     end
   end
   endgenerate

   generate begin : mmq_entry_tid
     genvar                             mmq;
     for (mmq = 0; mmq <= `MMQ_ENTRIES - 1; mmq = mmq + 1) begin : mmq_entry_tid

        tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) mmq_entry_tid_reg(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(entry_mmq_set_val[mmq]),
           .force_t(func_slp_sl_force),
           .d_mode(d_mode_dc),
           .delay_lclkr(delay_lclkr_dc),
           .mpw1_b(mpw1_dc_b),
           .mpw2_b(mpw2_dc_b),
           .thold_b(func_slp_sl_thold_0_b),
           .sg(sg_0),
           .scin(siv[mmq_entry_tid_offset + (2 * mmq):mmq_entry_tid_offset + (2 * (mmq + 1)) - 1]),
           .scout(sov[mmq_entry_tid_offset + (2 * mmq):mmq_entry_tid_offset + (2 * (mmq + 1)) - 1]),
           .din(mmq_entry_tid_d[mmq]),
           .dout(mmq_entry_tid_q[mmq])
        );
     end
   end
   endgenerate

   generate begin : mmq_entry_seq
     genvar                             mmq;
     for (mmq = 0; mmq <= `MMQ_ENTRIES - 1; mmq = mmq + 1) begin : mmq_entry_seq

        tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) mmq_entry_seq_reg(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(entry_mmq_set_val[mmq]),
           .force_t(func_slp_sl_force),
           .d_mode(d_mode_dc),
           .delay_lclkr(delay_lclkr_dc),
           .mpw1_b(mpw1_dc_b),
           .mpw2_b(mpw2_dc_b),
           .thold_b(func_slp_sl_thold_0_b),
           .sg(sg_0),
           .scin(siv[mmq_entry_seq_offset + (3 * mmq):mmq_entry_seq_offset + (3 * (mmq + 1)) - 1]),
           .scout(sov[mmq_entry_seq_offset + (3 * mmq):mmq_entry_seq_offset + (3 * (mmq + 1)) - 1]),
           .din(mmq_entry_seq_d[mmq]),
           .dout(mmq_entry_seq_q[mmq])
        );
     end
   end
   endgenerate

   generate begin : mmq_entry_lpid
     genvar                             mmq;
     for (mmq = 0; mmq <= `MMQ_ENTRIES - 1; mmq = mmq + 1) begin : mmq_entry_lpid

        tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) mmq_entry_lpid_reg(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(entry_mmq_set_val[mmq]),
           .force_t(func_slp_sl_force),
           .d_mode(d_mode_dc),
           .delay_lclkr(delay_lclkr_dc),
           .mpw1_b(mpw1_dc_b),
           .mpw2_b(mpw2_dc_b),
           .thold_b(func_slp_sl_thold_0_b),
           .sg(sg_0),
           .scin(siv[mmq_entry_lpid_offset + (8 * mmq):mmq_entry_lpid_offset + (8 * (mmq + 1)) - 1]),
           .scout(sov[mmq_entry_lpid_offset + (8 * mmq):mmq_entry_lpid_offset + (8 * (mmq + 1)) - 1]),
           .din(mmq_entry_lpid_d[mmq]),
           .dout(mmq_entry_lpid_q[mmq])
        );
     end
   end
   endgenerate


   tri_rlmreg_p #(.WIDTH(`MMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) mmq_entry_ind_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mmq_entry_ind_offset:mmq_entry_ind_offset + `MMQ_ENTRIES - 1]),
      .scout(sov[mmq_entry_ind_offset:mmq_entry_ind_offset + `MMQ_ENTRIES - 1]),
      .din(mmq_entry_ind_d),
      .dout(mmq_entry_ind_q)
   );


   tri_rlmreg_p #(.WIDTH(`MMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) mmq_entry_gs_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mmq_entry_gs_offset:mmq_entry_gs_offset + `MMQ_ENTRIES - 1]),
      .scout(sov[mmq_entry_gs_offset:mmq_entry_gs_offset + `MMQ_ENTRIES - 1]),
      .din(mmq_entry_gs_d),
      .dout(mmq_entry_gs_q)
   );


   tri_rlmreg_p #(.WIDTH(`MMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) mmq_entry_lbit_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mmq_entry_lbit_offset:mmq_entry_lbit_offset + `MMQ_ENTRIES - 1]),
      .scout(sov[mmq_entry_lbit_offset:mmq_entry_lbit_offset + `MMQ_ENTRIES - 1]),
      .din(mmq_entry_lbit_d),
      .dout(mmq_entry_lbit_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mmq_ret_token_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mmq_ret_token_offset]),
      .scout(sov[mmq_ret_token_offset]),
      .din(mmq_ret_token_d),
      .dout(mmq_ret_token_q)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) mmq_seq_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mmq_seq_offset:mmq_seq_offset + 3 - 1]),
      .scout(sov[mmq_seq_offset:mmq_seq_offset + 3 - 1]),
      .din(mmq_seq_d),
      .dout(mmq_seq_q)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) mmq_seq_rd_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mmq_seq_rd_offset:mmq_seq_rd_offset + 3 - 1]),
      .scout(sov[mmq_seq_rd_offset:mmq_seq_rd_offset + 3 - 1]),
      .din(mmq_seq_rd_d),
      .dout(mmq_seq_rd_q)
   );

   assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
   assign scan_out = sov[0];

endmodule
