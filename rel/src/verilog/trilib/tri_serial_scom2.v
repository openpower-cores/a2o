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

// *!****************************************************************
// *! FILENAME    : tri_serial_scom2.v
// *! DESCRIPTION : SCOM Satellite
// *!               Only supports 1:1 ratio
// *!
// *!****************************************************************

`include "tri_a2o.vh"

module tri_serial_scom2(
   nclk,
   vdd,
   gnd,
   scom_func_thold,
   sg,
   act_dis_dc,
   clkoff_dc_b,
   mpw1_dc_b,
   mpw2_dc_b,
   d_mode_dc,
   delay_lclkr_dc,
   func_scan_in,
   func_scan_out,
   dcfg_scan_dclk,
   dcfg_scan_lclk,
   dcfg_d1clk,
   dcfg_d2clk,
   dcfg_lclk,
   dcfg_scan_in,
   dcfg_scan_out,
   scom_local_act,
   sat_id,
   scom_dch_in,
   scom_cch_in,
   scom_dch_out,
   scom_cch_out,
   sc_req,
   sc_ack,
   sc_ack_info,
   sc_r_nw,
   sc_addr,
   addr_v,
   sc_rdata,
   sc_wdata,
   sc_wparity,
   scom_err,
   fsm_reset
);


//=====================================================================
// I/O Definition
//=====================================================================
   parameter         	  WIDTH = 64;		      // 64 is the maximum allowed
   parameter         	  INTERNAL_ADDR_DECODE = 1'b0;
   // Made these parameters local (they don't play nice with vhdl wrapper)
   //parameter [0:WIDTH-1]  USE_ADDR	  = 64'b1000000000000000000000000000000000000000000000000000000000000000;
   //parameter [0:WIDTH-1]  ADDR_IS_RDABLE  = 64'b1000000000000000000000000000000000000000000000000000000000000000;
   //parameter [0:WIDTH-1]  ADDR_IS_WRABLE  = 64'b1000000000000000000000000000000000000000000000000000000000000000;
   //parameter [0:WIDTH-1]  PIPELINE_ADDR_V = 64'b0000000000000000000000000000000000000000000000000000000000000000;
   parameter         	  PIPELINE_PARITYCHK = 1'b0;  // pipeline parcheck for timing
   parameter         	  SATID_NOBITS = 4;	      // should not be set by user
   parameter         	  REGID_NOBITS = 6;
   parameter         	  RINGID_NOBITS = 3;

   // clock, scan and misc interfaces
   input  [0:`NCLK_WIDTH-1]               		     nclk;
   inout                            			     vdd;
   inout                               			     gnd;
   input                               			     scom_func_thold;
   input                             			     sg;
   input                            			     act_dis_dc;
   input                              			     clkoff_dc_b;
   input                             			     mpw1_dc_b;
   input                              			     mpw2_dc_b;
   input                             			     d_mode_dc;
   input                           			     delay_lclkr_dc;

   //lcb_align_0          : in  std_ulogic;

   //! scan chain should evaluate to 0:176 for WIDTH=64 and 6 REGID_NOBITS (=64 SCOM addresses)
   //! scan chain vector is longer than number of latches being used due to
   //! vhdl generics formulation and shortings
   input  [0:WIDTH+2*((WIDTH-1)/16+1)+(2**REGID_NOBITS)+40] func_scan_in;
   output [0:WIDTH+2*((WIDTH-1)/16+1)+(2**REGID_NOBITS)+40] func_scan_out;

   // for mask slat inside of c_err_rpt
   input                                                    dcfg_scan_dclk;
   input  [0:`NCLK_WIDTH-1]                                 dcfg_scan_lclk;

   //! for nlats inside of c_err_rpt
   input                                                    dcfg_d1clk;	// needed for one bit only, always or scom_local_act clocked dcfg
   input                                                    dcfg_d2clk;	// needed for one bit only, always or scom_local_act clocked dcfg
   input  [0:`NCLK_WIDTH-1]                                 dcfg_lclk;	// needed for one bit only, always or scom_local_act clocked dcfg

   // contains mask slat and hold nlat of c_err_rpt
   input  [0:1]                                             dcfg_scan_in;
   output [0:1]                                             dcfg_scan_out;

   // denotes SCOM sat active if set to '1', can be used for local clock gating
   output                                                   scom_local_act;

   //---------------------------------------------------------------------
   // SCOM Interface
   //---------------------------------------------------------------------
   // SCOM satellite ID tied to a specific pattern
   input  [0:SATID_NOBITS-1]                                sat_id;

   // SCOM Data Channel input (carry both address and data)
   input                                                    scom_dch_in;

   // SCOM Control Channel input
   input                                                    scom_cch_in;

   // SCOM Data Channel output
   output                                                   scom_dch_out;

   // SCOM Control Channel output
   output                                                   scom_cch_out;

   //---------------------------------------------------------------------
   // Interface between SCOM satellite and internal macro logic
   //---------------------------------------------------------------------
   // denotes a request if asserted to '1', level
   output                                                   sc_req;

   // acknowledge a pending request with sc_ack_info+sc_rdata+sc_rparity
   // being valid
   input                                                    sc_ack;

   // acknowledge information
   // 0: '1' if access violation, otherwise '0'
   // 1: '1' if register address invalid
   input  [0:1]                                             sc_ack_info;

   // '1' if read access, '0' write access
   output                                                   sc_r_nw;

   // Register address, default 6 bits for up to 64 register addresses
   output [0:REGID_NOBITS-1]                                sc_addr;

   // one-hot address, valid only if INTERNAL_ADDR_DECODE=TRUE, else zeros
   output [0:WIDTH-1]                                       addr_v;

   // Read data delivered by macro logic as response to a read request
   input  [0:WIDTH-1]                                       sc_rdata;

   // Write data delivered from SCOM satellite for a write request
   output [0:WIDTH-1]                                       sc_wdata;

   // Write data parity bit over sc_wdata, optional usage
   output                                                   sc_wparity;

   //---------------------------------------------------------------------
   // parity error of fsm state vector, wire to next local fir
   output                                                   scom_err;

   // reset fsm (optional), tie to '0' if unused
   input                                                    fsm_reset;


//=====================================================================
// Signal Declarations
//=====================================================================
   parameter [0:WIDTH-1]  USE_ADDR	  = 64'b1000000000000000000000000000000000000000000000000000000000000000;
   parameter [0:WIDTH-1]  ADDR_IS_RDABLE  = 64'b1000000000000000000000000000000000000000000000000000000000000000;
   parameter [0:WIDTH-1]  ADDR_IS_WRABLE  = 64'b1000000000000000000000000000000000000000000000000000000000000000;
   parameter [0:WIDTH-1]  PIPELINE_ADDR_V = 64'b0000000000000000000000000000000000000000000000000000000000000000;

   parameter                                                STATE_WIDTH = 5;
   parameter                                                PAR_NOBITS = (WIDTH - 1)/16 + 1;
   parameter                                                REG_NOBITS = REGID_NOBITS;
   parameter                                                SATID_REGID_NOBITS = SATID_NOBITS + REGID_NOBITS;
   parameter                                                RW_BIT_INDEX = SATID_REGID_NOBITS + 1;
   parameter                                                PARBIT_INDEX = RW_BIT_INDEX + 1;
   parameter                                                HEAD_WIDTH = PARBIT_INDEX + 1;
   parameter [0:HEAD_WIDTH-1]                               HEAD_INIT = 13'b0000000000000;

   									//   0123Parity
   parameter [0:STATE_WIDTH-1]                              IDLE 	= 5'b00000;	// 0  = x00
   parameter [0:STATE_WIDTH-1]                              REC_HEAD 	= 5'b00011;	// 1  = x03
   parameter [0:STATE_WIDTH-1]                              CHECK_BEFORE= 5'b00101;	// 2  = x05
   parameter [0:STATE_WIDTH-1]                              REC_WDATA 	= 5'b00110;	// 3  = x06
   parameter [0:STATE_WIDTH-1]                              REC_WPAR 	= 5'b01001;	// 4  = x09
   parameter [0:STATE_WIDTH-1]                              EXE_CMD 	= 5'b01010;	// 5  = x0A
   parameter [0:STATE_WIDTH-1]                              FILLER0 	= 5'b01100;	// 6  = x0C
   parameter [0:STATE_WIDTH-1]                              FILLER1 	= 5'b01111;	// 7  = x0F
   parameter [0:STATE_WIDTH-1]                              GEN_ULINFO 	= 5'b10001;	// 8  = x11
   parameter [0:STATE_WIDTH-1]                              SEND_ULINFO = 5'b10010;	// 9  = x12
   parameter [0:STATE_WIDTH-1]                              SEND_RDATA 	= 5'b10100;	// 10 = x14
   parameter [0:STATE_WIDTH-1]                              SEND_0 	= 5'b10111;	// 11 = x17
   parameter [0:STATE_WIDTH-1]                              SEND_1 	= 5'b11000;	// 12 = x18
   parameter [0:STATE_WIDTH-1]                              CHECK_WPAR 	= 5'b11011;	// 13 = x1B
                                                                                        // 14 = x1D
   parameter [0:STATE_WIDTH-1]                              NOT_SELECTED= 5'b11110;	// 15 = x1E

   parameter                                                EOF_WDATA = PARBIT_INDEX - 1 + 64;	// here max width, it is 64
   parameter                                                EOF_WPAR = EOF_WDATA + 4;

   parameter                                                EOF_WDATA_N = PARBIT_INDEX - 1 + WIDTH;
   parameter                                                EOF_WPAR_M = EOF_WDATA + PAR_NOBITS;

   parameter						    CNT_SIZE = 7;

   wire                                                     is_idle;
   wire                                                     is_rec_head;
   wire                                                     is_check_before;
   wire                                                     is_rec_wdata;
   wire                                                     is_rec_wpar;
   wire                                                     is_exe_cmd;
   wire                                                     is_gen_ulinfo;
   wire                                                     is_send_ulinfo;
   wire                                                     is_send_rdata;
   wire                                                     is_send_0;
   wire                                                     is_send_1;
   wire                                                     is_filler_0;
   wire                                                     is_filler_1;

   reg  [0:STATE_WIDTH-1]                                   next_state;
   wire [0:STATE_WIDTH-1]                                   state_in;
   wire [0:STATE_WIDTH-1]                                   state_lt;

   wire                                                     dch_lt;
   wire [0:1]                                               cch_in;
   wire [0:1]                                               cch_lt;

   wire                                                     reset;
   wire                                                     got_head;
   wire                                                     gor_eofwdata;
   wire                                                     got_eofwpar;
   wire                                                     sent_rdata;
   wire                                                     got_ulhead;
   wire                                                     do_send_par;
   wire                                                     cntgtheadpluswidth;
   wire                                                     cntgteofwdataplusparity;
   wire                                                     p0_err;
   wire                                                     any_ack_error;
   wire                                                     match;
   wire                                                     do_write;
   wire                                                     do_read;
   wire [0:CNT_SIZE-1]                                      cnt_in;
   wire [0:CNT_SIZE-1]                                      cnt_lt;
   wire [0:HEAD_WIDTH-1]                                    head_in;
   wire [0:HEAD_WIDTH-1]                                    head_lt;
   wire [0:4]                                               tail_in;
   wire [0:4]                                               tail_lt;

   wire [0:1]                                               sc_ack_info_in;
   wire [0:1]                                               sc_ack_info_lt;
   wire                                                     head_mux;

   wire [0:WIDTH-1]                                         data_shifter_in;
   wire [0:WIDTH-1]                                         data_shifter_lt;
   wire [0:63]                                              data_shifter_lt_tmp;
   wire [0:PAR_NOBITS-1]                                    datapar_shifter_in;
   wire [0:PAR_NOBITS-1]                                    datapar_shifter_lt;
   wire                                                     data_mux;
   wire                                                     par_mux;
   wire                                                     dch_out_internal_in;
   wire                                                     dch_out_internal_lt;
   wire                                                     parity_satid_regaddr;

   wire                                                     func_force;
   wire                                                     func_thold_b;
   wire                                                     d1clk;
   wire                                                     d2clk;
   wire [0:`NCLK_WIDTH-1]                                   lclk;
   wire                                                     local_act;
   wire                                                     local_act_int;
   wire                                                     scom_err_in;
   wire                                                     scom_err_lt;
   wire                                                     scom_local_act_in;
   wire                                                     scom_local_act_lt;

   wire                                                     wpar_err;
   wire [0:PAR_NOBITS-1]                                    par_data_in;
   wire [0:PAR_NOBITS-1]                                    par_data_lt;
   wire [0:PAR_NOBITS-1]                                    sc_rparity;

   wire                                                     read_valid;
   wire                                                     write_valid;
   wire [0:WIDTH-1]                                         dec_addr_in;
   wire [0:WIDTH-1]                                         dec_addr_q;
   wire                                                     addr_nvld;
   wire                                                     write_nvld;
   wire                                                     read_nvld;
   wire                                                     state_par_error;
   wire [0:SATID_NOBITS-1]                                  sat_id_net;

   wire                                                     spare_latch1_in;
   wire                                                     spare_latch1_lt;
   wire                                                     spare_latch2_in;
   wire                                                     spare_latch2_lt;
// Don't reference unused inputs:
(* analysis_not_referenced="true" *)
   wire [0:1]                                               unused;
(* analysis_not_referenced="true" *)
   wire                                                     unused_signals;

   tri_lcbor lcbor_func(
      .clkoff_b(clkoff_dc_b),
      .thold(scom_func_thold),
      .sg(sg),
      .act_dis(act_dis_dc),
      .force_t(func_force),
      .thold_b(func_thold_b)
   );

   tri_lcbnd  lcb_func(
      .vd(vdd),
      .gd(gnd),
      .act(local_act_int),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .nclk(nclk),
      .force_t(func_force),
      .sg(sg),
      .thold_b(func_thold_b),
      //--------------------------
      .d1clk(d1clk),
      .d2clk(d2clk),
      .lclk(lclk)
   );

   //-----------------------------------------------------------------------------
   tri_err_rpt #(.WIDTH(1), 			// use to bundle error reporting checkers of the same exact type
   		 .INLINE(1'b0), 		// make hold latch be inline
		 .MASK_RESET_VALUE(1'b0), 	// do not report address and data parity errors by default
		 .NEEDS_SRESET(1)		// since already reported to PCB through error reply
		) parity_err(
      .vd(vdd),
      .gd(gnd),
      .err_d1clk(dcfg_d1clk),
      .err_d2clk(dcfg_d2clk),
      .err_lclk(dcfg_lclk),
      .err_scan_in(dcfg_scan_in[0:0]),
      .err_scan_out(dcfg_scan_out[0:0]),
      .mode_dclk(dcfg_scan_dclk),
      .mode_lclk(dcfg_scan_lclk),
      .mode_scan_in(dcfg_scan_in[1:1]),
      .mode_scan_out(dcfg_scan_out[1:1]),
      //--------------------------
      .err_in(state_par_error),
      .err_out(scom_err_in)
   );

   assign scom_err = scom_err_lt;		// drive this output with a latch / 1.35

   //-----------------------------------------------------------------------------
   // fill spares of scan vector
   assign func_scan_out[STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+22+(2**REGID_NOBITS):WIDTH+(2*((WIDTH-1)/16+1))+(2**REGID_NOBITS)+40] =
          func_scan_in[ STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+22+(2**REGID_NOBITS):WIDTH+(2*((WIDTH-1)/16+1))+(2**REGID_NOBITS)+40];

   //-----------------------------------------------------------------------------
   assign sat_id_net = sat_id;

   assign cch_in = {scom_cch_in, cch_lt[0]};

   assign reset = (cch_lt[0] & (~scom_cch_in)) 	| 	 // with falling edge of scom_cch_in
   		   fsm_reset 			| 	 // or with fsm_reset
		   scom_err_lt;				 // MP timing fix -- or state_par_error;

   assign local_act = (|{scom_cch_in, cch_lt});		 // active with scom_cch_in and as long as cch_lt

   assign local_act_int = local_act | scom_local_act_lt; // MP... and scom_local_act_lt is cleared

   assign scom_local_act_in = local_act;		 // drive this output with a latch / 1.35
   assign scom_local_act = scom_local_act_lt;

   assign scom_cch_out = cch_lt[0];

   assign dch_out_internal_in = (is_send_ulinfo == 1'b1) 		   ? head_lt[0] :
                                (is_send_0 == 1'b1) 			   ? 1'b0 :
                                (is_send_1 == 1'b1) 			   ? 1'b1 :
                                ((is_send_rdata & (~do_send_par)) == 1'b1) ? data_shifter_lt[0] :
                                ((is_send_rdata & do_send_par) == 1'b1)    ? datapar_shifter_lt[0] :
                                dch_lt;
   assign scom_dch_out = dch_out_internal_lt;

   assign sc_req = is_exe_cmd;
   assign sc_addr = head_lt[SATID_NOBITS + 1:SATID_REGID_NOBITS];
   assign sc_r_nw = head_lt[RW_BIT_INDEX];
   assign sc_wdata = data_shifter_lt;
   assign sc_wparity = (^datapar_shifter_lt);

   //-----------------------------------------------------------------------------
   // FSM: serial => parallel => serial state machine
   //
   always @(state_lt or got_head or gor_eofwdata or got_eofwpar or got_ulhead or sent_rdata or
   	    p0_err or any_ack_error or match or do_write or do_read or cch_lt[0] or dch_lt  or
	    sc_ack or wpar_err or read_nvld)

   begin: fsm_transition
     next_state <= state_lt;

     case (state_lt)
       IDLE :
          if (dch_lt == 1'b1)
            next_state <= REC_HEAD;

       REC_HEAD :
          if ((got_head) == 1'b1)
            next_state <= CHECK_BEFORE;

       CHECK_BEFORE :
          if (match == 1'b0)
            next_state <= NOT_SELECTED;
          else if (((read_nvld | p0_err) & do_read) == 1'b1)
            next_state <= FILLER0;
          else if (((~p0_err) & (~read_nvld) & do_read) == 1'b1)
            next_state <= EXE_CMD;
          else
            next_state <= REC_WDATA;

       REC_WDATA :
          if (gor_eofwdata == 1'b1)
            next_state <= REC_WPAR;

       REC_WPAR :
          if ((got_eofwpar & (~p0_err)) == 1'b1)
            // next_state <= EXE_CMD;
            next_state <= CHECK_WPAR;
          else if ((got_eofwpar & p0_err) == 1'b1)
            next_state <= FILLER0;

       CHECK_WPAR :
          if (wpar_err == 1'b0)
            next_state <= EXE_CMD;
          else
            next_state <= FILLER1;

       EXE_CMD :
          if (sc_ack == 1'b1)
            next_state <= FILLER1;

       FILLER0 :
          next_state <= FILLER1;

       FILLER1 :
          next_state <= GEN_ULINFO;

       GEN_ULINFO :
          next_state <= SEND_ULINFO;

       SEND_ULINFO :
          if ((got_ulhead & (do_write | (do_read & any_ack_error))) == 1'b1)
            next_state <= SEND_0;
          else if ((got_ulhead & do_read & (~any_ack_error)) == 1'b1)
            next_state <= SEND_RDATA;

       SEND_RDATA :
          if (sent_rdata == 1'b1)
            next_state <= SEND_0;

       SEND_0 :
          next_state <= SEND_1;

       SEND_1 :
          next_state <= IDLE;

       NOT_SELECTED :
          if (cch_lt[0] == 1'b0)
            next_state <= IDLE;

       default :
          next_state <= IDLE;
     endcase
   end

   assign state_in = (local_act == 1'b0) ? state_lt :
                     (reset == 1'b1) 	 ? IDLE :
                     next_state;

   assign state_par_error = (^state_lt);

   //-----------------------------------------------------------------------------
   assign is_idle 	    = (state_lt == IDLE);
   assign is_rec_head 	    = (state_lt == REC_HEAD);
   assign is_check_before   = (state_lt == CHECK_BEFORE);
   assign is_rec_wdata 	    = (state_lt == REC_WDATA);
   assign is_rec_wpar 	    = (state_lt == REC_WPAR);
   assign is_exe_cmd 	    = (state_lt == EXE_CMD);
   assign is_gen_ulinfo     = (state_lt == GEN_ULINFO);
   assign is_send_ulinfo    = (state_lt == SEND_ULINFO);
   assign is_send_rdata     = (state_lt == SEND_RDATA);
   assign is_send_0 	    = (state_lt == SEND_0);
   assign is_send_1 	    = (state_lt == SEND_1);
   assign is_filler_0 	    = (state_lt == FILLER0);
   assign is_filler_1 	    = (state_lt == FILLER1);

   //-----------------------------------------------------------------------------
   assign cnt_in = ((is_idle | is_gen_ulinfo) == 1'b1) 			? 7'b0000000 :
                   ((is_rec_head | is_check_before | is_rec_wdata |
		     is_rec_wpar | is_send_ulinfo | is_send_rdata |
		     is_send_0   | is_send_1) == 1'b1) 			? cnt_lt + 7'b0000001 :
                   							  cnt_lt;

   // downlink head (command) has been received when start bit, satellite id and register id have been received
   assign got_head = ({{32-CNT_SIZE{1'b0}},cnt_lt} == (1 + SATID_NOBITS + REGID_NOBITS));

   // uplink head (response) has been received when start bit, satellite id, register id and 4 ack bits have been received
   assign got_ulhead = ({{32-CNT_SIZE{1'b0}},cnt_lt} == (1 + SATID_NOBITS + REGID_NOBITS + 4));

   assign gor_eofwdata = ({{32-CNT_SIZE{1'b0}},cnt_lt} == EOF_WDATA);
   assign got_eofwpar  = ({{32-CNT_SIZE{1'b0}},cnt_lt} == EOF_WPAR);

   // for sent_rdata: 1 start, 10 sat_id + reg, 4 ack, 1 p, 64 data = 84, but count from 0 is 1st bit => 83 is end
   assign sent_rdata   = (cnt_lt == 7'd83);

   assign cntgtheadpluswidth      = ({{32-CNT_SIZE{1'b0}},cnt_lt} > EOF_WDATA_N);
   assign cntgteofwdataplusparity = ({{32-CNT_SIZE{1'b0}},cnt_lt} > EOF_WPAR_M);

   assign do_send_par = ({{32-CNT_SIZE{1'b0}},cnt_lt} > 79);	 // 78 bits=15 ulhead + 64 data

   //-----------------------------------------------------------------------------
   // shift downlink command (for this or any subsequent satellite) or uplink response (from previous satellite)
   assign head_in[HEAD_WIDTH-2:HEAD_WIDTH-1] = ((is_rec_head | (is_idle & dch_lt)) == 1'b1) ? {head_lt[HEAD_WIDTH-1], dch_lt} :
                                                                                               head_lt[HEAD_WIDTH-2:HEAD_WIDTH-1];

   assign head_in[0:SATID_REGID_NOBITS] = ((is_rec_head | is_send_ulinfo) == 1'b1) ? {head_lt[1:SATID_REGID_NOBITS], head_mux} :
                                                                                      head_lt[0:SATID_REGID_NOBITS];

   assign head_mux = (is_rec_head == 1'b1) ? head_lt[RW_BIT_INDEX] :
                                             tail_lt[0];

   // calculate parity P0 of uplink frame
   assign tail_in[4] = (is_gen_ulinfo == 1'b1 & (INTERNAL_ADDR_DECODE == 1'b0)) ? (^({parity_satid_regaddr, tail_lt[0], (wpar_err & do_write), sc_ack_info_lt[0:1]})) :
                       (is_gen_ulinfo == 1'b1 & (INTERNAL_ADDR_DECODE == 1'b1)) ? (^({parity_satid_regaddr, tail_lt[0], (wpar_err & do_write), (write_nvld | read_nvld), addr_nvld})) :
                                                                                  tail_lt[4];

   // copy sampled ack_info coming from logic
   assign tail_in[2:3] = (is_gen_ulinfo == 1'b1 & INTERNAL_ADDR_DECODE == 1'b0) ? sc_ack_info_lt[0:1] :
                         (is_gen_ulinfo == 1'b1 & INTERNAL_ADDR_DECODE == 1'b1) ? {(write_nvld | read_nvld), addr_nvld} :
                                                       (is_send_ulinfo == 1'b1) ? tail_lt[3:4] : 		// shift out
                                                                                  tail_lt[2:3];

   // Write Data Parity error
   assign tail_in[1] = (is_gen_ulinfo == 1'b1) ? (wpar_err & do_write) : // parity error on write operation
                      (is_send_ulinfo == 1'b1) ? tail_lt[2] : 		 // shift out
                                                 tail_lt[1];

   // parity check of of downlink P0 yields error
   assign tail_in[0] = (is_check_before == 1'b1) ? (~p0_err) : 		 // set to '1' if a downlink parity error is detected by satellite, otherwise '0'
                        (is_send_ulinfo == 1'b1) ? tail_lt[1] :          // shift out
                                                   tail_lt[0];

   // sample and hold ack_info, one spare bit
   assign sc_ack_info_in = ((is_exe_cmd & sc_ack) == 1'b1) ? sc_ack_info :
                                         (is_idle == 1'b1) ? 2'b00 :
                                                             sc_ack_info_lt;

   //-----------------------------------------------------------------------------
   assign do_write = (~do_read);
   assign do_read = head_lt[RW_BIT_INDEX];
   assign match = (head_lt[1:SATID_NOBITS] == sat_id_net);

   // if downlink parity error then set p0_err
   assign p0_err = (is_check_before & (^(head_lt[1:PARBIT_INDEX])));
   // why constant 11 here: ???
   // first part sat id; second part reg address (curr. 6 bits) => 10 instead of 11
   // now new constant SATID_REGID_NOBITS
   assign parity_satid_regaddr = (^{sat_id_net, head_lt[SATID_NOBITS+1:SATID_REGID_NOBITS]});

   assign any_ack_error = (|sc_ack_info_lt);

   //-----------------------------------------------------------------------------
   assign data_mux = ((is_check_before | is_rec_wdata) == 1'b1) ? dch_lt : 1'b0;

   assign data_shifter_in = ((is_check_before | (is_rec_wdata & (~cntgtheadpluswidth)) | is_send_rdata) == 1'b1) ? {data_shifter_lt[1:WIDTH-1], data_mux} :
                            ((is_exe_cmd & sc_ack & do_read) == 1'b1) ? sc_rdata :
                            data_shifter_lt;

   //-----------------------------------------------------------------------------
   // parity handling
   assign par_mux = ((is_rec_wpar) == 1'b1) ? dch_lt :  1'b0;

   // receiving parity: shift when receiving write data parity
   // sending parity of read data: shift when sending read data parity
   // latch generated parity of read data when read data is accepted
   assign datapar_shifter_in = (((is_rec_wpar & (~cntgteofwdataplusparity)) | (is_send_rdata & do_send_par)) == 1'b1) ? {datapar_shifter_lt[1:PAR_NOBITS-1], par_mux} :
                               ((is_filler_1 == 1'b1)) 				? sc_rparity :
                               datapar_shifter_lt;

   //----------------------------------------------------------------------------
   assign data_shifter_lt_tmp[0:WIDTH-1] = data_shifter_lt;

   generate
   if (WIDTH < 64)
   begin : data_shifter_padding
     assign data_shifter_lt_tmp[WIDTH:63] = {64-WIDTH {1'b0}};
   end
   endgenerate

   generate
   begin : xhdl0
     genvar    i;
     for (i=0; i<=PAR_NOBITS-1; i=i+1)
     begin : wdata_par_check
       assign par_data_in[i] = (^data_shifter_lt_tmp[16*i:16*(i+1)-1]);
     end
   end
   endgenerate

   generate
   if (PIPELINE_PARITYCHK == 1'b1)
   begin : wdata_par_check_pipe
     tri_nlat_scan #(.WIDTH(PAR_NOBITS), .NEEDS_SRESET(1)) state(
        .d1clk(d1clk),
        .vd(vdd),
        .gd(gnd),
        .lclk(lclk),
        .d2clk(d2clk),
        .scan_in(func_scan_in[  STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+22:STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+21]),
        .scan_out(func_scan_out[STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+22:STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+21]),
        .din(par_data_in),
        .q(par_data_lt)
     );
   end
   endgenerate

   generate
   if (PIPELINE_PARITYCHK == 1'b0)
   begin : wdata_par_check_nopipe
     assign par_data_lt = par_data_in;
     assign func_scan_out[STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+22:STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+21] =
            func_scan_in[ STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+22:STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+21];
   end
   endgenerate

   assign wpar_err = (^{par_data_lt, datapar_shifter_lt});

   //-----------------------------------------------------------------------------
   generate
   begin : xhdl1
      genvar    i;
      for (i=0; i<=PAR_NOBITS-1; i=i+1)
      begin : rdata_parity_gen
         assign sc_rparity[i] = (^data_shifter_lt_tmp[16*i:16*(i+1)-1]);
      end
   end
   endgenerate
   //-----------------------------------------------------------------------------

   //-----------------------------------------------------------------
   // address decoding section
   // Generate onehot Address (binary to one-hot)
   //-----------------------------------------------------------------
   //-----------------------------------------------------------------------------
   generate
   if (INTERNAL_ADDR_DECODE == 1'b1)
   begin : internal_addr_decoding
   //-----------------------------------------------------------------------------
     genvar    i;
     for (i=0; i<WIDTH; i=i+1)
     begin : foralladdresses
       if ( USE_ADDR[i] == 1'b1)
       begin : addr_bit_set
         assign dec_addr_in[i] = (head_lt[SATID_NOBITS+1:SATID_REGID_NOBITS] == i);

         // generate latch to hold addr_v only if required
         if ( PIPELINE_ADDR_V[i] == 1'b1)
         begin : latch_for_onehot
           tri_nlat #(.WIDTH(1), .NEEDS_SRESET(1)) dec_addr(
              .d1clk(d1clk),
              .vd(vdd),
              .gd(gnd),
              .d2clk(d2clk),
              .lclk(lclk),
              .scan_in(func_scan_in[  STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+22 +i]),
              .scan_out(func_scan_out[STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+22 +i]),
              .din(dec_addr_in[i]),
              .q(dec_addr_q[i])
           );
         end

         // otherwise no latch
         if ( PIPELINE_ADDR_V[i] == 1'b0)
         begin : no_latch_for_onehot
           assign func_scan_out[STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+22 +i] =
	          func_scan_in[ STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+22 +i];
           assign dec_addr_q[i] = dec_addr_in[i];
         end
       end

       //----------------------------------------------------------------------
       if ( USE_ADDR[i] != 1'b1)		// do not generate hardware for unused addresses
       begin : addr_bit_notset
         assign func_scan_out[STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+22 +i] =
	        func_scan_in[ STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+22 +i];
         assign dec_addr_in[i] = 1'b0;
         assign dec_addr_q[i] = dec_addr_in[i];
       end
     end
     //------------------------------------------------------------------------
     // check writable and/or readable
     assign read_valid  = (|(dec_addr_q & ADDR_IS_RDABLE));
     assign write_valid = (|(dec_addr_q & ADDR_IS_WRABLE));
     assign addr_nvld   = (~(|dec_addr_q));
     assign write_nvld  = ((~write_valid) & (~addr_nvld)) & do_write;
     assign read_nvld   = ((~read_valid)  & (~addr_nvld)) & do_read;

     assign unused = 2'b00;
   end
   endgenerate

   generate
   if (INTERNAL_ADDR_DECODE == 1'b0)
   begin : external_addr_decoding
     genvar    i;
     for (i=0; i<WIDTH ; i=i+1)
     begin : foralladdresses
       assign func_scan_out[STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+22 +i] =
              func_scan_in[ STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+22 +i];
       assign dec_addr_in[i] = 1'b0;
       assign dec_addr_q[i]  = dec_addr_in[i];
     end
     assign read_valid  = 1'b1;		// suppressing wrong error generation
     assign write_valid = 1'b1;		// suppressing wrong error generation
     assign addr_nvld   = 1'b0;
     assign write_nvld  = 1'b0;
     assign read_nvld   = 1'b0;

     assign unused = {write_valid, read_valid};
   end
   endgenerate

   // This was for unused addresses if USE_ADDR was smaller than the 64 bit width.
   // From VHDL: short_unused_addr_range: for i in use_addr'high+1 to 63 generate
   // Shouldn't be needed for A2, since we always define 64 SCOM addresses.
   generate
   begin : xhdl4
    genvar  i;
     for (i=WIDTH; i<64; i=i+1)
     begin : short_unused_addr_range
       assign func_scan_out[STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+22 +i] =
              func_scan_in[ STATE_WIDTH+WIDTH+(2*PAR_NOBITS)+HEAD_WIDTH+22 +i];
     end
   end
   endgenerate

   assign addr_v = dec_addr_q[0:WIDTH-1];

//-----------------------------------------------------------------------------


   tri_nlat_scan #(.WIDTH(STATE_WIDTH), .INIT(IDLE), .NEEDS_SRESET(1)) state(
      .d1clk(d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(lclk),
      .d2clk(d2clk),
      .scan_in(func_scan_in[  0:STATE_WIDTH-1]),
      .scan_out(func_scan_out[0:STATE_WIDTH-1]),
      .din(state_in),
      .q(state_lt)
   );


   tri_nlat_scan #(.WIDTH(7), .INIT(7'b0000000), .NEEDS_SRESET(1)) counter(
      .d1clk(d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(lclk),
      .d2clk(d2clk),
      .scan_in(func_scan_in[  STATE_WIDTH:STATE_WIDTH+6]),
      .scan_out(func_scan_out[STATE_WIDTH:STATE_WIDTH+6]),
      .din(cnt_in),
      .q(cnt_lt)
   );


   tri_nlat_scan #(.WIDTH(WIDTH), .NEEDS_SRESET(1)) data_shifter(
      .d1clk(d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(lclk),
      .d2clk(d2clk),
      .scan_in(func_scan_in[  STATE_WIDTH+7:STATE_WIDTH+WIDTH+6]),
      .scan_out(func_scan_out[STATE_WIDTH+7:STATE_WIDTH+WIDTH+6]),
      .din(data_shifter_in),
      .q(data_shifter_lt)
   );


   tri_nlat_scan #(.WIDTH(PAR_NOBITS), .NEEDS_SRESET(1)) datapar_shifter(
      .d1clk(d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(lclk),
      .d2clk(d2clk),
      .scan_in(func_scan_in[  STATE_WIDTH+WIDTH+7:STATE_WIDTH+WIDTH+PAR_NOBITS+6]),
      .scan_out(func_scan_out[STATE_WIDTH+WIDTH+7:STATE_WIDTH+WIDTH+PAR_NOBITS+6]),
      .din(datapar_shifter_in),
      .q(datapar_shifter_lt)
   );


   tri_nlat_scan #(.WIDTH(HEAD_WIDTH), .INIT(HEAD_INIT), .NEEDS_SRESET(1)) head_lat(
      .d1clk(d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(lclk),
      .d2clk(d2clk),
      .scan_in(func_scan_in[  STATE_WIDTH+WIDTH+PAR_NOBITS+7:STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+6]),
      .scan_out(func_scan_out[STATE_WIDTH+WIDTH+PAR_NOBITS+7:STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+6]),
      .din(head_in),
      .q(head_lt)
   );


   tri_nlat_scan #(.WIDTH(5), .INIT(5'b00000), .NEEDS_SRESET(1)) tail_lat(
      .d1clk(d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(lclk),
      .d2clk(d2clk),
      .scan_in(func_scan_in[  STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+7:STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+11]),
      .scan_out(func_scan_out[STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+7:STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+11]),
      .din(tail_in),
      .q(tail_lt)
   );


   tri_nlat #(.WIDTH(1), .NEEDS_SRESET(1)) dch_inlatch(
      .d1clk(d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(lclk),
      .d2clk(d2clk),
      .scan_in(func_scan_in[  STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+12]),
      .scan_out(func_scan_out[STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+12]),
      .din(scom_dch_in),
      .q(dch_lt)
   );


   tri_nlat_scan #(.WIDTH(2), .NEEDS_SRESET(1)) ack_info(
      .d1clk(d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(lclk),
      .d2clk(d2clk),
      .scan_in(func_scan_in[  STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+13:STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+14]),
      .scan_out(func_scan_out[STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+13:STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+14]),
      .din(sc_ack_info_in),
      .q(sc_ack_info_lt)
   );


   tri_nlat #(.WIDTH(1), .NEEDS_SRESET(1)) dch_outlatch(
      .d1clk(d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(lclk),
      .d2clk(d2clk),
      .scan_in(func_scan_in[  STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+15]),
      .scan_out(func_scan_out[STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+15]),
      .din(dch_out_internal_in),
      .q(dch_out_internal_lt)
   );


   tri_nlat_scan #(.WIDTH(2), .NEEDS_SRESET(1)) cch_latches(
      .d1clk(d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(lclk),
      .d2clk(d2clk),
      .scan_in(func_scan_in[  STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+16:STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+17]),
      .scan_out(func_scan_out[STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+16:STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+17]),
      .din(cch_in),
      .q(cch_lt)
   );


   tri_nlat #(.WIDTH(1), .NEEDS_SRESET(1)) scom_err_latch(
      .d1clk(d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(lclk),
      .d2clk(d2clk),
      .scan_in(func_scan_in[  STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+18]),
      .scan_out(func_scan_out[STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+18]),
      .din(scom_err_in),
      .q(scom_err_lt)
   );


   tri_nlat #(.WIDTH(1), .NEEDS_SRESET(1)) scom_local_act_latch(
      .d1clk(d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(lclk),
      .d2clk(d2clk),
      .scan_in(func_scan_in[  STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+19]),
      .scan_out(func_scan_out[STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+19]),
      .din(scom_local_act_in),
      .q(scom_local_act_lt)
   );


   tri_nlat #(.WIDTH(1), .NEEDS_SRESET(1)) spare_latch1(
      .d1clk(d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(lclk),
      .d2clk(d2clk),
      .scan_in(func_scan_in[  STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+20]),
      .scan_out(func_scan_out[STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+20]),
      .din(spare_latch1_in),
      .q(spare_latch1_lt)
   );


   tri_nlat #(.WIDTH(1), .NEEDS_SRESET(1)) spare_latch2(
      .d1clk(d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(lclk),
      .d2clk(d2clk),
      .scan_in(func_scan_in[  STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+21]),
      .scan_out(func_scan_out[STATE_WIDTH+WIDTH+PAR_NOBITS+HEAD_WIDTH+21]),
      .din(spare_latch2_in),
      .q(spare_latch2_lt)
   );

//-----------------------------------------------------------------------------
   assign unused_signals = |({is_filler_0, is_filler_1, spare_latch1_lt, spare_latch2_lt, d_mode_dc});

   assign spare_latch1_in = 1'b0;
   assign spare_latch2_in = 1'b0;

endmodule
