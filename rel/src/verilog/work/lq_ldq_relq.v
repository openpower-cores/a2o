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

//
//  Description:  Reload Data Arbiter Control
//
//*****************************************************************************

`include "tri_a2o.vh"

module lq_ldq_relq(
   ldq_rel0_stg_act,
   ldq_rel1_stg_act,
   ldqe_ctrl_act,
   ldq_rel0_arb_sent,
   ldq_rel0_beat_upd,
   ldq_rel0_arr_wren,
   ldq_rel0_rdat_qw,
   ldq_rel1_cTag,
   ldq_rel1_dbeat_val,
   ldq_rel1_beats_home,
   ldq_rel2_entrySent,
   ldq_rel2_blk_req,
   ldq_rel2_sentL1,
   ldq_rel2_sentL1_blk,
   ldqe_rel_eccdet,
   ldqe_rst_eccdet,
   ldq_rel0_rdat_sel,
   arb_ldq_rel2_wrt_data,
   ldq_rel0_arb_val,
   ldq_rel0_arb_qw,
   ldq_rel0_arb_cTag,
   ldq_rel0_arb_thresh,
   ldq_rel2_rdat_perr,
   ldq_rel3_rdat_par_err,
   ldqe_rel_rdat_perr,
   ldq_arb_rel2_rdat_sel,
   ldq_arb_rel2_rd_data,
   pc_lq_inj_relq_parity,
   spr_lsucr0_lca_ovrd,
   bo_enable_2,
   clkoff_dc_b,
   g8t_clkoff_dc_b,
   g8t_d_mode_dc,
   g8t_delay_lclkr_dc,
   g8t_mpw1_dc_b,
   g8t_mpw2_dc_b,
   pc_lq_ccflush_dc,
   an_ac_scan_dis_dc_b,
   an_ac_scan_diag_dc,
   an_ac_lbist_ary_wrt_thru_dc,
   pc_lq_abist_ena_dc,
   pc_lq_abist_raw_dc_b,
   pc_lq_abist_wl64_comp_ena,
   pc_lq_abist_raddr_0,
   pc_lq_abist_g8t_wenb,
   pc_lq_abist_g8t1p_renb_0,
   pc_lq_abist_g8t_dcomp,
   pc_lq_abist_g8t_bw_1,
   pc_lq_abist_g8t_bw_0,
   pc_lq_abist_di_0,
   pc_lq_abist_waddr_0,
   pc_lq_bo_unload,
   pc_lq_bo_repair,
   pc_lq_bo_reset,
   pc_lq_bo_shdata,
   pc_lq_bo_select,
   lq_pc_bo_fail,
   lq_pc_bo_diagout,
   vcs,
   vdd,
   gnd,
   nclk,
   sg_0,
   func_sl_thold_0_b,
   func_sl_force,
   abst_sl_thold_0,
   ary_nsl_thold_0,
   time_sl_thold_0,
   repr_sl_thold_0,
   bolt_sl_thold_0,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   scan_in,
   abst_scan_in,
   time_scan_in,
   repr_scan_in,
   scan_out,
   abst_scan_out,
   time_scan_out,
   repr_scan_out
);

// ACT's
input                                                       ldq_rel0_stg_act;           // Rel0 Stage ACT
input                                                       ldq_rel1_stg_act;           // Rel0 Stage ACT
input [0:`LMQ_ENTRIES-1]                                    ldqe_ctrl_act;              // Reload Queue Entry ACT

//Reload Data Beats Control
input [0:`LMQ_ENTRIES-1]                                    ldq_rel0_arb_sent;          // Reload Arbiter Sent Request
input [0:7]                                                 ldq_rel0_beat_upd;          // 1-hot Reload Data Beat is Valid
input                                                       ldq_rel0_arr_wren;          // Reload Data Array Write Enable
input [0:2]                                                 ldq_rel0_rdat_qw;           // Reload Data Array Write Address
input [0:3]                                                 ldq_rel1_cTag;              // Reload Core Tag
input [0:`LMQ_ENTRIES-1]                                    ldq_rel1_dbeat_val;         // Reload Queue Entry Data is Valid
input [0:`LMQ_ENTRIES-1]                                    ldq_rel1_beats_home;        // All data beats have been sent by the L2
input [0:`LMQ_ENTRIES-1]                                    ldq_rel2_entrySent;         // Load Queue Entry attempted to update L1 Data Cache
input                                                       ldq_rel2_blk_req;           // Reload Attempt was blocked
input [0:`LMQ_ENTRIES-1]                                    ldq_rel2_sentL1;            // Reload Queue Entry was not restarted
input [0:`LMQ_ENTRIES-1]                                    ldq_rel2_sentL1_blk;        // Reload Queue Entry was restarted
input [0:`LMQ_ENTRIES-1]                                    ldqe_rel_eccdet;            // Load Queue Entry detected an ECC error
input [0:`LMQ_ENTRIES-1]                                    ldqe_rst_eccdet;            // Load Queue Entry reset error conditions

// Reload Data Select Valid
input                                                       ldq_rel0_rdat_sel;
input [0:143]                                               arb_ldq_rel2_wrt_data;      // Reload Interface Data

// Reload Arbiter Control Outputs
output                                                      ldq_rel0_arb_val;           // Reload Arbiter is attempting to update L1 Data Cache
output [0:2]                                                ldq_rel0_arb_qw;            // Reload Arbiter quadword
output [0:3]                                                ldq_rel0_arb_cTag;          // Reload Arbiter core tag
output                                                      ldq_rel0_arb_thresh;        // Reload Arbiter threshold met
output                                                      ldq_rel2_rdat_perr;         // Reload Data Array contained a parity error
output                                                      ldq_rel3_rdat_par_err;      // Reload Data Array contained a parity error FIR report
output [0:`LMQ_ENTRIES-1]                                   ldqe_rel_rdat_perr;         // Reload Queue Entry had a reload data array parity error

// RELOAD Data Queue Control
output                                                      ldq_arb_rel2_rdat_sel;      // Reload Data Array Select Data
output [0:143]                                              ldq_arb_rel2_rd_data;       // Reload Data Array Read

// SPR
input                                                       pc_lq_inj_relq_parity;      // Inject Reload Data Array Parity Error
input [0:2]                                                 spr_lsucr0_lca_ovrd;        // LSUCR0[LCA]

// Array Pervasive Controls
input                                                       bo_enable_2;
input                                                       clkoff_dc_b;
input                                                       g8t_clkoff_dc_b;
input                                                       g8t_d_mode_dc;
input [0:4]                                                 g8t_delay_lclkr_dc;
input [0:4]                                                 g8t_mpw1_dc_b;
input                                                       g8t_mpw2_dc_b;
input                                                       pc_lq_ccflush_dc;
input                                                       an_ac_scan_dis_dc_b;
input                                                       an_ac_scan_diag_dc;
input                                                       an_ac_lbist_ary_wrt_thru_dc;
input                                                       pc_lq_abist_ena_dc;
input                                                       pc_lq_abist_raw_dc_b;
input                                                       pc_lq_abist_wl64_comp_ena;
input [3:8]                                                 pc_lq_abist_raddr_0;
input                                                       pc_lq_abist_g8t_wenb;
input                                                       pc_lq_abist_g8t1p_renb_0;
input [0:3]                                                 pc_lq_abist_g8t_dcomp;
input                                                       pc_lq_abist_g8t_bw_1;
input                                                       pc_lq_abist_g8t_bw_0;
input [0:3]                                                 pc_lq_abist_di_0;
input [4:9]                                                 pc_lq_abist_waddr_0;
input                                                       pc_lq_bo_unload;
input                                                       pc_lq_bo_repair;
input                                                       pc_lq_bo_reset;
input                                                       pc_lq_bo_shdata;
input [8:9]                                                 pc_lq_bo_select;
output [8:9]                                                lq_pc_bo_fail;
output [8:9]                                                lq_pc_bo_diagout;

// Pervasive
inout                                                       vcs;
inout                                                       vdd;
inout                                                       gnd;
(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)
input [0:`NCLK_WIDTH-1]                                     nclk;
input                                                       sg_0;
input                                                       func_sl_thold_0_b;
input                                                       func_sl_force;
input                                                       abst_sl_thold_0;
input                                                       ary_nsl_thold_0;
input                                                       time_sl_thold_0;
input                                                       repr_sl_thold_0;
input                                                       bolt_sl_thold_0;
input                                                       d_mode_dc;
input                                                       delay_lclkr_dc;
input                                                       mpw1_dc_b;
input                                                       mpw2_dc_b;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input                                                       scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input                                                       abst_scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input                                                       time_scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input                                                       repr_scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output                                                      scan_out;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output                                                      abst_scan_out;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output                                                      time_scan_out;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output                                                      repr_scan_out;

//--------------------------
// components
//--------------------------

//--------------------------
// signals
//--------------------------
parameter                                                   numGrps = ((((`LMQ_ENTRIES-1)/4)+1)*4);

wire [0:7]                                                  ldqe_rel_datSet[0:`LMQ_ENTRIES-1];
wire [0:7]                                                  ldqe_rel_datClr[0:`LMQ_ENTRIES-1];
wire [0:7]                                                  ldqe_rel_datRet_d[0:`LMQ_ENTRIES-1];
wire [0:7]                                                  ldqe_rel_datRet_q[0:`LMQ_ENTRIES-1];
wire [0:7]                                                  ldq_rel1_beat_upd_d;
wire [0:7]                                                  ldq_rel1_beat_upd_q;
wire [0:7]                                                  ldq_rel2_beat_upd_d;
wire [0:7]                                                  ldq_rel2_beat_upd_q;
wire [0:1]                                                  ldqe_relAttempts_ctrl[0:`LMQ_ENTRIES-1];
wire [0:2]                                                  ldqe_relAttempts_decr[0:`LMQ_ENTRIES-1];
wire [0:2]                                                  ldqe_relAttempts_d[0:`LMQ_ENTRIES-1];
wire [0:2]                                                  ldqe_relAttempts_q[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_relAttempts_done;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_relThreshold_met;
wire [0:7]                                                  ldq_rel0_arb_beats[0:`LMQ_ENTRIES-1];
wire [0:7]                                                  ldq_rel1_arb_beats[0:`LMQ_ENTRIES-1];
wire [0:7]                                                  ldq_rel2_arb_beats[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_relBeats_val;
wire [0:7]                                                  ldqe_relBeats_avail[0:`LMQ_ENTRIES-1];
wire [0:7]                                                  ldqe_relBeats_nxt[0:`LMQ_ENTRIES-1];
reg [0:2]                                                   ldqe_relBeats[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel1_arb_sent_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel1_arb_sent_q;
wire                                                        ldq_rel0_arb_val_d;
wire                                                        ldq_rel0_arb_val_q;
wire [0:numGrps-1]                                          ldq_rel_arb_entry;
reg [0:2]                                                   ldq_rel0_arb_qw_d;
wire [0:2]                                                  ldq_rel0_arb_qw_q;
reg [0:3]                                                   ldq_rel0_arb_cTag_d;
wire [0:3]                                                  ldq_rel0_arb_cTag_q;
reg                                                         ldq_rel0_arb_thresh_d;
wire                                                        ldq_rel0_arb_thresh_q;
wire [0:3]                                                  rel_grpEntry_val[0:(`LMQ_ENTRIES-1)/4];
wire [0:3]                                                  rel_grpEntry_sel[0:(`LMQ_ENTRIES-1)/4];
wire [0:(`LMQ_ENTRIES-1)/4]                                 rel_grpEntry_sent;
wire [0:3]                                                  rel_grpEntry_last_sel_d[0:(`LMQ_ENTRIES-1)/4];
wire [0:3]                                                  rel_grpEntry_last_sel_q[0:(`LMQ_ENTRIES-1)/4];
reg [0:2]                                                   rel_grpEntry_qw[0:(`LMQ_ENTRIES-1)/4];
reg [0:(`LMQ_ENTRIES-1)/4]                                  rel_grpEntry_thresh;
wire [0:3]                                                  rel_group_val;
wire [0:3]                                                  rel_group_sel;
wire                                                        rel_arb_sentL1;
wire [0:3]                                                  rel_group_last_sel_d;
wire [0:3]                                                  rel_group_last_sel_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel_sel;
wire                                                        ldq_rel1_rdat_sel_d;
wire                                                        ldq_rel1_rdat_sel_q;
wire                                                        ldq_rel2_rdat_sel_d;
wire                                                        ldq_rel2_rdat_sel_q;
wire                                                        ldq_rel2_rdat_par_err;
wire                                                        ldq_rel3_rdat_par_err_d;
wire                                                        ldq_rel3_rdat_par_err_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_arb_sent;
wire [0:1]                                                  ldqe_rel_rdat_perr_sel[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel_rdat_perr_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel_rdat_perr_q;
wire [0:2]                                                  ldq_rel1_rdat_qw_d;
wire [0:2]                                                  ldq_rel1_rdat_qw_q;
wire                                                        ldq_rel1_arr_wren_d;
wire                                                        ldq_rel1_arr_wren_q;
wire                                                        ldq_rel2_arr_wren_d;
wire                                                        ldq_rel2_arr_wren_q;
wire                                                        ldq_rel2_arr_wren;
wire [0:6]                                                  ldq_rel2_arr_waddr;
wire [0:6]                                                  ldq_rel2_arr_waddr_d;
wire [0:6]                                                  ldq_rel2_arr_waddr_q;
wire                                                        ldq_rel0_arr_rd_act;
wire [0:6]                                                  ldq_rel0_arr_raddr;
wire [0:143]                                                rdat_rel2_rd_data;
wire [0:143]                                                rel2_rd_data;
wire [0:15]                                                 rel2_rdat_par_byte;
wire                                                        rel2_rdat_par_err;
wire                                                        inj_relq_parity_d;
wire                                                        inj_relq_parity_q;

//--------------------------
// constants
//--------------------------
parameter                                                  ldqe_rel_datRet_offset = 0;
parameter                                                  ldq_rel1_beat_upd_offset = ldqe_rel_datRet_offset + 8 * `LMQ_ENTRIES;
parameter                                                  ldq_rel2_beat_upd_offset = ldq_rel1_beat_upd_offset + 8;
parameter                                                  ldqe_relAttempts_offset = ldq_rel2_beat_upd_offset + 8;
parameter                                                  ldq_rel1_arb_sent_offset = ldqe_relAttempts_offset + 3 * `LMQ_ENTRIES;
parameter                                                  ldq_rel0_arb_val_offset = ldq_rel1_arb_sent_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel0_arb_qw_offset = ldq_rel0_arb_val_offset + 1;
parameter                                                  ldq_rel0_arb_thresh_offset = ldq_rel0_arb_qw_offset + 3;
parameter                                                  ldq_rel0_arb_cTag_offset = ldq_rel0_arb_thresh_offset + 1;
parameter                                                  rel_grpEntry_last_sel_offset = ldq_rel0_arb_cTag_offset + 4;
parameter                                                  rel_group_last_sel_offset = rel_grpEntry_last_sel_offset + 4 * (((`LMQ_ENTRIES - 1)/4) + 1);
parameter                                                  ldq_rel1_rdat_sel_offset = rel_group_last_sel_offset + 4;
parameter                                                  ldq_rel2_rdat_sel_offset = ldq_rel1_rdat_sel_offset + 1;
parameter                                                  ldq_rel3_rdat_par_err_offset = ldq_rel2_rdat_sel_offset + 1;
parameter                                                  ldqe_rel_rdat_perr_offset = ldq_rel3_rdat_par_err_offset + 1;
parameter                                                  ldq_rel1_arr_wren_offset = ldqe_rel_rdat_perr_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel2_arr_wren_offset = ldq_rel1_arr_wren_offset + 1;
parameter                                                  ldq_rel2_arr_waddr_offset = ldq_rel2_arr_wren_offset + 1;
parameter                                                  ldq_rel1_rdat_qw_offset = ldq_rel2_arr_waddr_offset + 7;
parameter                                                  inj_relq_parity_offset = ldq_rel1_rdat_qw_offset + 3;
parameter                                                  scan_right = inj_relq_parity_offset + 1 - 1;

wire                                                       tiup;
wire                                                       tidn;
wire [0:scan_right]                                        siv;
wire [0:scan_right]                                        sov;
wire                                                       rdat_scan_in;
wire                                                       rdat_scan_out;

(* analysis_not_referenced="true" *)
wire                                                       unused;

assign tiup = 1'b1;
assign tidn = 1'b0;
assign unused = tidn | ldq_rel2_arr_waddr[0] | ldq_rel0_arr_raddr[0];

// Load Queue Reload Handling
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// Reload Quadword Beat that is trying to update
assign ldq_rel1_beat_upd_d = ldq_rel0_beat_upd;
assign ldq_rel2_beat_upd_d = ldq_rel1_beat_upd_q;

// One of the Loadmiss Queues has data available to be sent to the L1
assign ldq_rel0_arb_val_d = |(ldqe_relBeats_val & ~ldqe_rel_eccdet);

// Reload Data Queue Control
assign ldq_rel1_rdat_sel_d = ldq_rel0_rdat_sel;
assign ldq_rel2_rdat_sel_d = ldq_rel1_rdat_sel_q;

generate begin : relQ
   genvar                                                  ldq;
   for (ldq=0; ldq<`LMQ_ENTRIES; ldq=ldq+1) begin : relQ

      // Reload Data Beat Home
      assign ldqe_rel_datSet[ldq] = ldq_rel1_beat_upd_q & {8{ldq_rel1_dbeat_val[ldq]}};

      begin : relDatRetQ
         genvar                                                  beat;
         for (beat=0; beat<8; beat=beat+1) begin : relDatRetQ
            assign ldqe_rel_datClr[ldq][beat]   = (ldq_rel2_beat_upd_q[beat] & ldq_rel2_entrySent[ldq] & ~ldq_rel2_blk_req) | ldqe_rel_eccdet[ldq];
            assign ldqe_rel_datRet_d[ldq][beat] = ldqe_rel_datSet[ldq][beat] | (ldqe_rel_datRet_q[ldq][beat] & (~ldqe_rel_datClr[ldq][beat]));
         end
      end

      // Reload Attempts from Arbiter
      assign ldqe_relAttempts_ctrl[ldq] = {ldq_rel2_sentL1[ldq], (ldq_rel2_sentL1_blk[ldq] & (~ldqe_relAttempts_done[ldq]))};
      assign ldqe_relAttempts_decr[ldq] = ldqe_relAttempts_q[ldq] - 3'b001;

      assign ldqe_relAttempts_d[ldq] = (ldqe_relAttempts_ctrl[ldq] == 2'b00) ? ldqe_relAttempts_q[ldq] :
                                       (ldqe_relAttempts_ctrl[ldq] == 2'b01) ? ldqe_relAttempts_decr[ldq] :
                                       spr_lsucr0_lca_ovrd;

      // Reload Update L1D$ attempts threshold met
      // need to HOLD RV until reload is complete
      assign ldqe_relAttempts_done[ldq] = ~(|ldqe_relAttempts_q[ldq]);
      assign ldqe_relThreshold_met[ldq] = ldqe_relAttempts_done[ldq] & ldqe_relBeats_val[ldq] & ldq_rel1_beats_home[ldq];

      // Reload Arbiter sent reload for reload queue entry
      assign ldq_rel1_arb_sent_d[ldq] = ldq_rel0_arb_sent[ldq];

      // Beats Available in Reload Arbiters to be sent to L1
      assign ldq_rel0_arb_beats[ldq]  = ldq_rel0_beat_upd   & {8{ldq_rel0_arb_sent[ldq]}};
      assign ldq_rel1_arb_beats[ldq]  = ldq_rel1_beat_upd_q & {8{ldq_rel1_arb_sent_q[ldq]}};
      assign ldq_rel2_arb_beats[ldq]  = ldq_rel2_beat_upd_q & {8{ldq_rel2_entrySent[ldq]}};		// Merged results of Reload and Arbiter
      assign ldqe_relBeats_avail[ldq] = ldqe_rel_datRet_q[ldq] & (~(ldq_rel0_arb_beats[ldq] | ldq_rel1_arb_beats[ldq] | ldq_rel2_arb_beats[ldq]));
      assign ldqe_relBeats_val[ldq]   = |(ldqe_relBeats_avail[ldq]);

      // Select Beat from Available beats in Reload Arbiters
      assign ldqe_relBeats_nxt[ldq][0] = ldqe_relBeats_avail[ldq][0];

      begin : relSel genvar                                                  beat;
         for (beat=1; beat<8; beat=beat+1) begin : relSel
            assign ldqe_relBeats_nxt[ldq][beat] = &(~ldqe_relBeats_avail[ldq][0:beat-1]) & ldqe_relBeats_avail[ldq][beat];
         end
      end

      // Convert Beat Selected into an Array Index
      always @(*) begin: relBeatEntry
         reg [0:2]                                               entry;

         (* analysis_not_referenced="true" *)

         integer                                              beat;
         entry = 3'b000;
         for (beat=0; beat<8; beat=beat+1)
            entry = (beat[2:0] & {3{ldqe_relBeats_nxt[ldq][beat]}}) | entry;
         ldqe_relBeats[ldq] <= entry;
      end

      // Reload Data Queue Parity Error
      // REL2 Entry Sent is from the Reload Data Queue Arbiter
      assign ldq_rel2_arb_sent[ldq]      = ldq_rel2_entrySent[ldq] & ldq_rel2_rdat_sel_q;
      assign ldqe_rel_rdat_perr_sel[ldq] = {ldq_rel2_arb_sent[ldq], ldqe_rst_eccdet[ldq]};

      assign ldqe_rel_rdat_perr_d[ldq] = (ldqe_rel_rdat_perr_sel[ldq] == 2'b10) ? (ldqe_rel_rdat_perr_q[ldq] | ldq_rel2_rdat_par_err) :
                                         (ldqe_rel_rdat_perr_sel[ldq] == 2'b00) ? ldqe_rel_rdat_perr_q[ldq] :
                                         1'b0;
   end
end
endgenerate

// Reload Data Array Arbiter
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Doing a Round Robin Scheme within each 4 entries (called Groups)
// followed by a Round Robin Scheme within each Group

// Expand LDQ to max supported
generate begin : relExp
   genvar                                                grp;
   genvar                                                bit;
   for (grp=0; grp<=(`LMQ_ENTRIES-1)/4; grp=grp+1) begin : relExp
      for (bit=0; bit<=3; bit=bit+1) begin : bit_wtf
         if ((grp*4)+bit < `LMQ_ENTRIES) begin : ldqExst
            assign ldq_rel_arb_entry[(grp*4)+bit] = ldqe_relBeats_val[(grp*4)+bit];
         end
         if ((grp*4)+bit >= `LMQ_ENTRIES) begin : ldqNExst
            assign ldq_rel_arb_entry[(grp*4)+bit] = 1'b0;
         end
      end
   end
end
endgenerate

// Entry Select within Group
// Round Robin Scheme within each 4 entries in a Group
generate begin : relGrpEntry
   genvar                                                  grp;
   for (grp=0; grp<=(`LMQ_ENTRIES-1)/4; grp=grp+1) begin : relGrpEntry
      assign rel_grpEntry_val[grp]    = {ldq_rel_arb_entry[4*grp+0], ldq_rel_arb_entry[4*grp+1], ldq_rel_arb_entry[4*grp+2], ldq_rel_arb_entry[4*grp+3]};
      assign rel_grpEntry_sel[grp][0] = (rel_grpEntry_last_sel_q[grp][0] & ~(|rel_grpEntry_val[grp][1:3]) & rel_grpEntry_val[grp][0]) |
                                        (rel_grpEntry_last_sel_q[grp][1] & ~(|rel_grpEntry_val[grp][2:3]) & rel_grpEntry_val[grp][0]) |
                                        (rel_grpEntry_last_sel_q[grp][2] &   ~rel_grpEntry_val[grp][3]    & rel_grpEntry_val[grp][0]) |
                                        (rel_grpEntry_last_sel_q[grp][3] &                                  rel_grpEntry_val[grp][0]);

      assign rel_grpEntry_sel[grp][1] = (rel_grpEntry_last_sel_q[grp][0] &                                                               rel_grpEntry_val[grp][1]) |
                                        (rel_grpEntry_last_sel_q[grp][1] & ~(|{rel_grpEntry_val[grp][0], rel_grpEntry_val[grp][2:3]})  & rel_grpEntry_val[grp][1]) |
                                        (rel_grpEntry_last_sel_q[grp][2] & ~(|{rel_grpEntry_val[grp][0], rel_grpEntry_val[grp][3]})    & rel_grpEntry_val[grp][1]) |
                                        (rel_grpEntry_last_sel_q[grp][3] &    ~rel_grpEntry_val[grp][0]                                & rel_grpEntry_val[grp][1]);

      assign rel_grpEntry_sel[grp][2] = (rel_grpEntry_last_sel_q[grp][0] &    ~rel_grpEntry_val[grp][1]                               & rel_grpEntry_val[grp][2]) |
                                        (rel_grpEntry_last_sel_q[grp][1] &                                                              rel_grpEntry_val[grp][2]) |
                                        (rel_grpEntry_last_sel_q[grp][2] & ~(|{rel_grpEntry_val[grp][0:1], rel_grpEntry_val[grp][3]}) & rel_grpEntry_val[grp][2]) |
                                        (rel_grpEntry_last_sel_q[grp][3] &  ~(|rel_grpEntry_val[grp][0:1])                            & rel_grpEntry_val[grp][2]);

      assign rel_grpEntry_sel[grp][3] = (rel_grpEntry_last_sel_q[grp][0] & ~(|rel_grpEntry_val[grp][1:2]) & rel_grpEntry_val[grp][3]) |
                                        (rel_grpEntry_last_sel_q[grp][1] &    ~rel_grpEntry_val[grp][2]   & rel_grpEntry_val[grp][3]) |
                                        (rel_grpEntry_last_sel_q[grp][2] &                                  rel_grpEntry_val[grp][3]) |
                                        (rel_grpEntry_last_sel_q[grp][3] & ~(|rel_grpEntry_val[grp][0:2]) & rel_grpEntry_val[grp][3]);

      // Load Queue Group Selected
      assign rel_grpEntry_sent[grp]       = rel_group_sel[grp] & ldq_rel0_arb_val_d;
      assign rel_grpEntry_last_sel_d[grp] = rel_grpEntry_sent[grp] ? rel_grpEntry_sel[grp] : rel_grpEntry_last_sel_q[grp];

      // Mux Load Queue Entry within a Group
      always @(*) begin: relMux
         reg [0:2]                                               qw;
         reg                                                     thresh;
         (* analysis_not_referenced="true" *)
         integer                                                 ldq;

         qw     = {3{1'b0}};
         thresh = 1'b0;
         for (ldq=0; ldq<=3; ldq=ldq+1) begin : ldqExst
            if ((grp*4)+ldq < `LMQ_ENTRIES) begin : ldqExst
               qw     = (ldqe_relBeats[(grp*4)+ldq]         & {3{rel_grpEntry_sel[grp][ldq]}}) | qw;
               thresh = (ldqe_relThreshold_met[(grp*4)+ldq] &    rel_grpEntry_sel[grp][ldq])   | thresh;
             end
         end
         rel_grpEntry_qw[grp]     <= qw;
         rel_grpEntry_thresh[grp] <= thresh;
      end
   end
end
endgenerate

// Group Select Between all Groups
// Round Robin Scheme within Groups
generate begin : relGrp
   genvar                                                  grp;
   for (grp=0; grp<=3; grp=grp+1) begin : relGrp
      if (grp <= (`LMQ_ENTRIES - 1)/4) begin : grpExst
         assign rel_group_val[grp] = |(rel_grpEntry_val[grp]);
      end
      if (grp > (`LMQ_ENTRIES - 1)/4) begin : grpNExst
         assign rel_group_val[grp] = 1'b0;
      end
   end
end
endgenerate

assign rel_group_sel[0] = (rel_group_last_sel_q[0] & ~(|rel_group_val[1:3]) & rel_group_val[0]) |
                          (rel_group_last_sel_q[1] & ~(|rel_group_val[2:3]) & rel_group_val[0]) |
                          (rel_group_last_sel_q[2] &   ~rel_group_val[3]    & rel_group_val[0]) |
                          (rel_group_last_sel_q[3] &                          rel_group_val[0]);

assign rel_group_sel[1] = (rel_group_last_sel_q[0] &                                              rel_group_val[1]) |
                          (rel_group_last_sel_q[1] & ~(|{rel_group_val[0], rel_group_val[2:3]}) & rel_group_val[1]) |
                          (rel_group_last_sel_q[2] & ~(|{rel_group_val[0], rel_group_val[3]})   & rel_group_val[1]) |
                          (rel_group_last_sel_q[3] &    ~rel_group_val[0]                       & rel_group_val[1]);

assign rel_group_sel[2] = (rel_group_last_sel_q[0] &   (~rel_group_val[1])                      & rel_group_val[2]) |
                          (rel_group_last_sel_q[1] &                                              rel_group_val[2]) |
                          (rel_group_last_sel_q[2] & ~(|{rel_group_val[0:1], rel_group_val[3]}) & rel_group_val[2]) |
                          (rel_group_last_sel_q[3] &  ~(|rel_group_val[0:1])                    & rel_group_val[2]);

assign rel_group_sel[3] = (rel_group_last_sel_q[0] & ~(|rel_group_val[1:2]) & rel_group_val[3]) |
                          (rel_group_last_sel_q[1] &   ~rel_group_val[2]    & rel_group_val[3]) |
                          (rel_group_last_sel_q[2] &                          rel_group_val[3]) |
                          (rel_group_last_sel_q[3] & ~(|rel_group_val[0:2]) & rel_group_val[3]);

// Reload Queue Entry Sent
generate begin : relSent
   genvar                                                  grp;
   for (grp=0; grp<=(`LMQ_ENTRIES-1)/4; grp=grp+1) begin : relSent
      genvar                                            ldq;
      for (ldq=0; ldq<=3; ldq=ldq+1) begin : ldqEntry
         assign ldqe_rel_sel[ldq+(grp*4)] = rel_grpEntry_sel[grp][ldq] & rel_group_sel[grp] & ldq_rel0_arb_val_d;
      end
   end
end
endgenerate

assign rel_arb_sentL1       = |(ldqe_rel_sel);
assign rel_group_last_sel_d = rel_arb_sentL1 ? rel_group_sel : rel_group_last_sel_q;

// Mux Load Queue Entry between Groups
always @(*) begin: relGrpLqMux
   reg [0:2]                                               qw;
   reg                                                     thresh;

   (* analysis_not_referenced="true" *)
   integer                                                 grp;

   qw     = {3{1'b0}};
   thresh = 1'b0;
   for (grp=0; grp<=3; grp=grp+1) begin : relGrpLqMux
      if (grp <= (`LMQ_ENTRIES-1)/4) begin : GrpExst
         qw     = (rel_grpEntry_qw[grp]     & {3{rel_group_sel[grp]}}) | qw;
         thresh = (rel_grpEntry_thresh[grp] &    rel_group_sel[grp])   | thresh;
      end
   end
   ldq_rel0_arb_qw_d     <= qw;
   ldq_rel0_arb_thresh_d <= thresh;
end

// Generate Reload Core Tag
always @(*) begin: relcTag
   reg [0:3]                                               cTag;

   (* analysis_not_referenced="true" *)
   integer                                              ldq;

   cTag = 4'b0000;
   for (ldq=0; ldq<`LMQ_ENTRIES; ldq=ldq+1)
      cTag = (ldq[2:0] & {4{ldqe_rel_sel[ldq]}}) | cTag;
   ldq_rel0_arb_cTag_d <= cTag;
end

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Reload Data Array
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
generate begin : relq
   genvar byte;
   if (`RELQ_INCLUDE == 1) begin
      tri_64x144_1r1w  rdat(

         // POWER PINS
         .vcs(vcs),
         .vdd(vdd),
         .gnd(gnd),

         // CLOCK AND CLOCKCONTROL PORTS
         .nclk(nclk),
         .rd_act(ldq_rel0_arr_rd_act),
         .wr_act(ldq_rel2_arr_wren),
         .sg_0(sg_0),
         .abst_sl_thold_0(abst_sl_thold_0),
         .ary_nsl_thold_0(ary_nsl_thold_0),
         .time_sl_thold_0(time_sl_thold_0),
         .repr_sl_thold_0(repr_sl_thold_0),
         .func_sl_force(func_sl_force),
         .func_sl_thold_0_b(func_sl_thold_0_b),
         .g8t_clkoff_dc_b(g8t_clkoff_dc_b),
         .ccflush_dc(pc_lq_ccflush_dc),
         .scan_dis_dc_b(an_ac_scan_dis_dc_b),
         .scan_diag_dc(an_ac_scan_diag_dc),
         .g8t_d_mode_dc(g8t_d_mode_dc),
         .g8t_mpw1_dc_b(g8t_mpw1_dc_b),
         .g8t_mpw2_dc_b(g8t_mpw2_dc_b),
         .g8t_delay_lclkr_dc(g8t_delay_lclkr_dc),
         .d_mode_dc(d_mode_dc),
         .mpw1_dc_b(mpw1_dc_b),
         .mpw2_dc_b(mpw2_dc_b),
         .delay_lclkr_dc(delay_lclkr_dc),

         // ABIST
         .wr_abst_act(pc_lq_abist_g8t_wenb),
         .rd0_abst_act(pc_lq_abist_g8t1p_renb_0),
         .abist_di(pc_lq_abist_di_0),
         .abist_bw_odd(pc_lq_abist_g8t_bw_1),
         .abist_bw_even(pc_lq_abist_g8t_bw_0),
         .abist_wr_adr(pc_lq_abist_waddr_0),
         .abist_rd0_adr(pc_lq_abist_raddr_0),
         .tc_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
         .abist_ena_1(pc_lq_abist_ena_dc),
         .abist_g8t_rd0_comp_ena(pc_lq_abist_wl64_comp_ena),
         .abist_raw_dc_b(pc_lq_abist_raw_dc_b),
         .obs0_abist_cmp(pc_lq_abist_g8t_dcomp),

         // SCAN PORTS
         .abst_scan_in(abst_scan_in),
         .time_scan_in(time_scan_in),
         .repr_scan_in(repr_scan_in),
         .func_scan_in(rdat_scan_in),
         .abst_scan_out(abst_scan_out),
         .time_scan_out(time_scan_out),
         .repr_scan_out(repr_scan_out),
         .func_scan_out(rdat_scan_out),

         // BOLT-ON
         .lcb_bolt_sl_thold_0(bolt_sl_thold_0),
         .pc_bo_enable_2(bo_enable_2),
         .pc_bo_reset(pc_lq_bo_reset),
         .pc_bo_unload(pc_lq_bo_unload),
         .pc_bo_repair(pc_lq_bo_repair),
         .pc_bo_shdata(pc_lq_bo_shdata),
         .pc_bo_select(pc_lq_bo_select[8:9]),
         .bo_pc_failout(lq_pc_bo_fail[8:9]),
         .bo_pc_diagloop(lq_pc_bo_diagout[8:9]),
         .tri_lcb_mpw1_dc_b(mpw1_dc_b),
         .tri_lcb_mpw2_dc_b(mpw2_dc_b),
         .tri_lcb_delay_lclkr_dc(delay_lclkr_dc),
         .tri_lcb_clkoff_dc_b(clkoff_dc_b),
         .tri_lcb_act_dis_dc(tidn),

         // Write Ports
         .write_enable(ldq_rel2_arr_wren),
         .addr_wr(ldq_rel2_arr_waddr[1:6]),
         .data_in(arb_ldq_rel2_wrt_data),

         // Read Ports
         .addr_rd(ldq_rel0_arr_raddr[1:6]),
         .data_out(rdat_rel2_rd_data)
      );

      // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      // Reload Queue Parity Error Detection
      // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      // Inject a Parity Error on the Reload Data Queue Access
      assign inj_relq_parity_d = pc_lq_inj_relq_parity;
      assign rel2_rd_data      = {(rdat_rel2_rd_data[0] ^ inj_relq_parity_q), rdat_rel2_rd_data[1:143]};

      for (byte=0;byte<16;byte=byte+1) begin : relData
          assign rel2_rdat_par_byte[byte] = ^({rel2_rd_data[byte*8:(byte*8)+7], rel2_rd_data[128+byte]});
      end

      assign rel2_rdat_par_err = |(rel2_rdat_par_byte);

      // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      // Reload Queue Control
      // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      // Update Reload Array
      assign ldq_rel1_rdat_qw_d   = ldq_rel0_rdat_qw;
      assign ldq_rel1_arr_wren_d  = ldq_rel0_arr_wren;
      assign ldq_rel2_arr_wren_d  = ldq_rel1_arr_wren_q;
      assign ldq_rel2_arr_waddr_d = {ldq_rel1_cTag, ldq_rel1_rdat_qw_q};

      assign ldq_rel0_arr_rd_act = ldq_rel0_rdat_sel;
      assign ldq_rel0_arr_raddr  = {ldq_rel0_arb_cTag_q, ldq_rel0_arb_qw_q};
      assign ldq_rel2_arr_wren   = ldq_rel2_arr_wren_q & ldq_rel2_blk_req;
      assign ldq_rel2_arr_waddr  = ldq_rel2_arr_waddr_q;

      // Reload Data Queue Parity Error
      assign ldq_rel2_rdat_par_err   = rel2_rdat_par_err & ldq_rel2_rdat_sel_q & ~ldq_rel2_blk_req;
      assign ldq_rel3_rdat_par_err_d = ldq_rel2_rdat_par_err;
   end else begin
      // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      // Reload Queue Parity Error Detection
      // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      // Inject a Parity Error on the Reload Data Queue Access
      assign inj_relq_parity_d = pc_lq_inj_relq_parity;
      assign rdat_rel2_rd_data = 144'b0;
      assign rel2_rd_data      = {(rdat_rel2_rd_data[0] ^ inj_relq_parity_q), rdat_rel2_rd_data[1:143]};

      for (byte=0;byte<16;byte=byte+1) begin : relData
          assign rel2_rdat_par_byte[byte] = ^({rel2_rd_data[byte*8:(byte*8)+7], rel2_rd_data[128+byte]});
      end

      assign rel2_rdat_par_err = 1'b0;

      // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      // Reload Queue Control
      // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      // Update Reload Array
      assign ldq_rel1_rdat_qw_d   = 3'b0;
      assign ldq_rel1_arr_wren_d  = 1'b0;
      assign ldq_rel2_arr_wren_d  = ldq_rel1_arr_wren_q;
      assign ldq_rel2_arr_waddr_d = 7'b0;

      assign ldq_rel0_arr_rd_act = 1'b0;
      assign ldq_rel0_arr_raddr  = 7'b0;
      assign ldq_rel2_arr_wren   = 1'b0;
      assign ldq_rel2_arr_waddr  = ldq_rel2_arr_waddr_q;

      // Reload Data Queue Parity Error
      assign ldq_rel2_rdat_par_err   = 1'b0;
      assign ldq_rel3_rdat_par_err_d = ldq_rel2_rdat_par_err;

      assign abst_scan_out = abst_scan_in;
      assign time_scan_out = time_scan_in;
      assign repr_scan_out = repr_scan_in;
      assign rdat_scan_out = rdat_scan_in;
      assign lq_pc_bo_fail = 2'b0;
      assign lq_pc_bo_diagout = 2'b0;
   end
end endgenerate

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// OUTPUTS
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// Reload Data Arbiter Control
assign ldq_rel0_arb_val      = ldq_rel0_arb_val_q;
assign ldq_rel0_arb_qw       = ldq_rel0_arb_qw_q;
assign ldq_rel0_arb_cTag     = ldq_rel0_arb_cTag_q;
assign ldq_rel0_arb_thresh   = ldq_rel0_arb_thresh_q;
assign ldq_rel2_rdat_perr    = |(ldqe_rel_rdat_perr_q & ldq_rel2_entrySent) | ldq_rel2_rdat_par_err;
assign ldq_rel3_rdat_par_err = ldq_rel3_rdat_par_err_q;
assign ldqe_rel_rdat_perr    = ldqe_rel_rdat_perr_q;

// Reload Data Array Control
assign ldq_arb_rel2_rdat_sel = ldq_rel2_rdat_sel_q;
assign ldq_arb_rel2_rd_data  = rel2_rd_data;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// REGISTERS
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
generate begin : ldqe_rel_datRet
   genvar                                                  ldq;
   for (ldq=0; ldq<`LMQ_ENTRIES; ldq=ldq+1) begin : ldqe_rel_datRet
      tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ldqe_rel_datRet_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(ldqe_ctrl_act[ldq]),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ldqe_rel_datRet_offset + (8 * ldq):ldqe_rel_datRet_offset + (8 * (ldq + 1)) - 1]),
         .scout(sov[ldqe_rel_datRet_offset + (8 * ldq):ldqe_rel_datRet_offset + (8 * (ldq + 1)) - 1]),
         .din(ldqe_rel_datRet_d[ldq]),
         .dout(ldqe_rel_datRet_q[ldq])
      );
   end
end
endgenerate

tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_beat_upd_reg(
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
   .scin(siv[ldq_rel1_beat_upd_offset:ldq_rel1_beat_upd_offset + 8 - 1]),
   .scout(sov[ldq_rel1_beat_upd_offset:ldq_rel1_beat_upd_offset + 8 - 1]),
   .din(ldq_rel1_beat_upd_d),
   .dout(ldq_rel1_beat_upd_q)
);

tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ldq_rel2_beat_upd_reg(
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
   .scin(siv[ldq_rel2_beat_upd_offset:ldq_rel2_beat_upd_offset + 8 - 1]),
   .scout(sov[ldq_rel2_beat_upd_offset:ldq_rel2_beat_upd_offset + 8 - 1]),
   .din(ldq_rel2_beat_upd_d),
   .dout(ldq_rel2_beat_upd_q)
);

generate begin : ldqe_relAttempts
   genvar                                                  ldq;
   for (ldq=0; ldq<`LMQ_ENTRIES; ldq=ldq+1) begin : ldqe_relAttempts
      tri_rlmreg_p #(.WIDTH(3), .INIT(7), .NEEDS_SRESET(1)) ldqe_relAttempts_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(ldqe_ctrl_act[ldq]),
         .force_t(func_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .scin(siv[ldqe_relAttempts_offset + (3 * ldq):ldqe_relAttempts_offset + (3 * (ldq + 1)) - 1]),
         .scout(sov[ldqe_relAttempts_offset + (3 * ldq):ldqe_relAttempts_offset + (3 * (ldq + 1)) - 1]),
         .din(ldqe_relAttempts_d[ldq]),
         .dout(ldqe_relAttempts_q[ldq])
      );
   end
end
endgenerate

tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_arb_sent_reg(
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
   .scin(siv[ldq_rel1_arb_sent_offset:ldq_rel1_arb_sent_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel1_arb_sent_offset:ldq_rel1_arb_sent_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel1_arb_sent_d),
   .dout(ldq_rel1_arb_sent_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel0_arb_val_reg(
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
   .scin(siv[ldq_rel0_arb_val_offset]),
   .scout(sov[ldq_rel0_arb_val_offset]),
   .din(ldq_rel0_arb_val_d),
   .dout(ldq_rel0_arb_val_q)
);

tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ldq_rel0_arb_qw_reg(
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
   .scin(siv[ldq_rel0_arb_qw_offset:ldq_rel0_arb_qw_offset + 3 - 1]),
   .scout(sov[ldq_rel0_arb_qw_offset:ldq_rel0_arb_qw_offset + 3 - 1]),
   .din(ldq_rel0_arb_qw_d),
   .dout(ldq_rel0_arb_qw_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel0_arb_thresh_reg(
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
   .scin(siv[ldq_rel0_arb_thresh_offset]),
   .scout(sov[ldq_rel0_arb_thresh_offset]),
   .din(ldq_rel0_arb_thresh_d),
   .dout(ldq_rel0_arb_thresh_q)
);

tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ldq_rel0_arb_cTag_reg(
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
   .scin(siv[ldq_rel0_arb_cTag_offset:ldq_rel0_arb_cTag_offset + 4 - 1]),
   .scout(sov[ldq_rel0_arb_cTag_offset:ldq_rel0_arb_cTag_offset + 4 - 1]),
   .din(ldq_rel0_arb_cTag_d),
   .dout(ldq_rel0_arb_cTag_q)
);

generate begin : rel_grpEntry_last_sel
   genvar                                                  grp;
   for (grp=0; grp<=(`LMQ_ENTRIES-1)/4; grp=grp+1) begin : rel_grpEntry_last_sel
      tri_rlmreg_p #(.WIDTH(4), .INIT(8), .NEEDS_SRESET(1)) rel_grpEntry_last_sel_reg(
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
         .scin(siv[rel_grpEntry_last_sel_offset + (4 * grp):rel_grpEntry_last_sel_offset + (4 * (grp + 1)) - 1]),
         .scout(sov[rel_grpEntry_last_sel_offset + (4 * grp):rel_grpEntry_last_sel_offset + (4 * (grp + 1)) - 1]),
         .din(rel_grpEntry_last_sel_d[grp]),
         .dout(rel_grpEntry_last_sel_q[grp])
      );
   end
end
endgenerate

tri_rlmreg_p #(.WIDTH(4), .INIT(8), .NEEDS_SRESET(1)) rel_group_last_sel_reg(
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
   .scin(siv[rel_group_last_sel_offset:rel_group_last_sel_offset + 4 - 1]),
   .scout(sov[rel_group_last_sel_offset:rel_group_last_sel_offset + 4 - 1]),
   .din(rel_group_last_sel_d),
   .dout(rel_group_last_sel_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel1_rdat_sel_reg(
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
   .scin(siv[ldq_rel1_rdat_sel_offset]),
   .scout(sov[ldq_rel1_rdat_sel_offset]),
   .din(ldq_rel1_rdat_sel_d),
   .dout(ldq_rel1_rdat_sel_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel2_rdat_sel_reg(
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
   .scin(siv[ldq_rel2_rdat_sel_offset]),
   .scout(sov[ldq_rel2_rdat_sel_offset]),
   .din(ldq_rel2_rdat_sel_d),
   .dout(ldq_rel2_rdat_sel_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel3_rdat_par_err_reg(
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
   .scin(siv[ldq_rel3_rdat_par_err_offset]),
   .scout(sov[ldq_rel3_rdat_par_err_offset]),
   .din(ldq_rel3_rdat_par_err_d),
   .dout(ldq_rel3_rdat_par_err_q)
);

tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_rel_rdat_perr_reg(
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
   .scin(siv[ldqe_rel_rdat_perr_offset:ldqe_rel_rdat_perr_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_rel_rdat_perr_offset:ldqe_rel_rdat_perr_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_rel_rdat_perr_d),
   .dout(ldqe_rel_rdat_perr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel1_arr_wren_reg(
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
   .scin(siv[ldq_rel1_arr_wren_offset]),
   .scout(sov[ldq_rel1_arr_wren_offset]),
   .din(ldq_rel1_arr_wren_d),
   .dout(ldq_rel1_arr_wren_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel2_arr_wren_reg(
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
   .scin(siv[ldq_rel2_arr_wren_offset]),
   .scout(sov[ldq_rel2_arr_wren_offset]),
   .din(ldq_rel2_arr_wren_d),
   .dout(ldq_rel2_arr_wren_q)
);

tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) ldq_rel2_arr_waddr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ldq_rel1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel2_arr_waddr_offset:ldq_rel2_arr_waddr_offset + 7 - 1]),
   .scout(sov[ldq_rel2_arr_waddr_offset:ldq_rel2_arr_waddr_offset + 7 - 1]),
   .din(ldq_rel2_arr_waddr_d),
   .dout(ldq_rel2_arr_waddr_q)
);

tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_rdat_qw_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ldq_rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_rdat_qw_offset:ldq_rel1_rdat_qw_offset + 3 - 1]),
   .scout(sov[ldq_rel1_rdat_qw_offset:ldq_rel1_rdat_qw_offset + 3 - 1]),
   .din(ldq_rel1_rdat_qw_d),
   .dout(ldq_rel1_rdat_qw_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) inj_relq_parity_reg(
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
   .scin(siv[inj_relq_parity_offset]),
   .scout(sov[inj_relq_parity_offset]),
   .din(inj_relq_parity_d),
   .dout(inj_relq_parity_q)
);

assign rdat_scan_in      = scan_in;
assign siv[0:scan_right] = {sov[1:scan_right], rdat_scan_out};
assign scan_out = sov[0];

endmodule
