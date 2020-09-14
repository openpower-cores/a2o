// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.


`define THREADS1
`include "tri_a2o.vh"

module c_wrapper(
   clk,
   clk2x,
   clk4x,
   reset,
   an_ac_coreid,
   an_ac_pm_thread_stop,
   an_ac_ext_interrupt,
   an_ac_crit_interrupt,
   an_ac_perf_interrupt,
   an_ac_external_mchk,
   an_ac_flh2l2_gate,
   an_ac_reservation_vld,
   ac_an_debug_trigger,
   an_ac_debug_stop,
   an_ac_tb_update_enable,
   an_ac_tb_update_pulse,
   an_ac_hang_pulse,
   ac_an_pm_thread_running,
   ac_an_machine_check,
   ac_an_recov_err,
   ac_an_checkstop,
   ac_an_local_checkstop,

   an_ac_stcx_complete,
   an_ac_stcx_pass,

   an_ac_reld_data_vld,
   an_ac_reld_core_tag,
   an_ac_reld_data,
   an_ac_reld_qw,
   an_ac_reld_ecc_err,
   an_ac_reld_ecc_err_ue,
   an_ac_reld_data_coming,
   
   an_ac_reld_crit_qw,
   an_ac_reld_l1_dump,

   
   an_ac_req_ld_pop,
   an_ac_req_st_pop,
   an_ac_req_st_gather,
   an_ac_sync_ack,





   
   

   ac_an_req_pwr_token,
   ac_an_req,
   ac_an_req_ra,
   ac_an_req_ttype,
   ac_an_req_thread,
   ac_an_req_wimg_w,
   ac_an_req_wimg_i,
   ac_an_req_wimg_m,
   ac_an_req_wimg_g,
   ac_an_req_user_defined,
   ac_an_req_ld_core_tag,
   ac_an_req_ld_xfr_len,
   ac_an_st_byte_enbl,
   ac_an_st_data,
   ac_an_req_endian,
   ac_an_st_data_pwr_token
);


           input clk;
        input clk2x;
        input clk4x;
        input reset;
        input [0:7]    an_ac_coreid;
        input [0:3]    an_ac_pm_thread_stop;
        input [0:3]    an_ac_ext_interrupt;
        input [0:3]    an_ac_crit_interrupt;
        input [0:3]    an_ac_perf_interrupt;
        input [0:3]    an_ac_external_mchk;
        input          an_ac_flh2l2_gate;      
        input [0:3]    an_ac_reservation_vld;
        output [0:3]    ac_an_debug_trigger;
        input          an_ac_debug_stop;
        input          an_ac_tb_update_enable;
        input          an_ac_tb_update_pulse;
        input  [0:3]    an_ac_hang_pulse;
        output [0:3]   ac_an_pm_thread_running;
        output [0:3]   ac_an_machine_check;
        output [0:2]   ac_an_recov_err;
        output [0:2]   ac_an_checkstop;
        output [0:2]   ac_an_local_checkstop;

   wire         scan_in;
   wire         scan_out;
   
   wire          an_ac_rtim_sl_thold_8;
   wire          an_ac_func_sl_thold_8;
   wire          an_ac_func_nsl_thold_8;
   wire          an_ac_ary_nsl_thold_8;
   wire          an_ac_sg_8;
   wire          an_ac_fce_8;
   wire [0:7]    an_ac_abst_scan_in;
   
   input [0:3]    an_ac_stcx_complete;
   input [0:3]    an_ac_stcx_pass;
   
   wire          an_ac_icbi_ack;
   wire [0:1]    an_ac_icbi_ack_thread;
   
   wire          an_ac_back_inv;
   wire [22:63]  an_ac_back_inv_addr;
   wire [0:4]    an_ac_back_inv_target;     
   wire          an_ac_back_inv_local;
   wire          an_ac_back_inv_lbit;
   wire          an_ac_back_inv_gs;
   wire          an_ac_back_inv_ind;
   wire [0:7]    an_ac_back_inv_lpar_id;
   wire         ac_an_back_inv_reject;
   wire [0:7]   ac_an_lpar_id;
   
   input          an_ac_reld_data_vld;    
   input [0:4]    an_ac_reld_core_tag;    
   input [0:127]  an_ac_reld_data;     
   input [57:59]  an_ac_reld_qw;    
   input          an_ac_reld_ecc_err;     
   input          an_ac_reld_ecc_err_ue;     
   input          an_ac_reld_data_coming;
   wire          an_ac_reld_ditc;
   input          an_ac_reld_crit_qw;
   input          an_ac_reld_l1_dump;
   wire [0:3]    an_ac_req_spare_ctrl_a1;      
   
   input          an_ac_req_ld_pop;    
   input          an_ac_req_st_pop;    
   input          an_ac_req_st_gather;    
   input [0:3]    an_ac_sync_ack;
   
   wire [0:3]    an_ac_scom_sat_id;
   wire          an_ac_scom_dch;
   wire          an_ac_scom_cch;
   wire         ac_an_scom_dch;
   wire         ac_an_scom_cch;
   
   wire [0:0]   ac_an_special_attn;
   wire         ac_an_trace_error;
   wire     ac_an_livelock_active;
   wire          an_ac_checkstop;
      
   wire [0:3]   ac_an_event_bus0;
   wire [0:3]   ac_an_event_bus1;
   
   wire          an_ac_reset_1_complete;
   wire          an_ac_reset_2_complete;
   wire          an_ac_reset_3_complete;
   wire          an_ac_reset_wd_complete;
   
   wire [0:0]    an_ac_pm_fetch_halt;
   wire         ac_an_power_managed;
   wire         ac_an_rvwinkle_mode;
   
   wire          an_ac_gsd_test_enable_dc;
   wire          an_ac_gsd_test_acmode_dc;
   wire          an_ac_ccflush_dc;
   wire          an_ac_ccenable_dc;
   wire          an_ac_lbist_en_dc;
   wire          an_ac_lbist_ip_dc;
   wire          an_ac_lbist_ac_mode_dc;
   wire          an_ac_scan_diag_dc;
   wire          an_ac_scan_dis_dc_b;
   
   wire [0:8]    an_ac_scan_type_dc;
   
   wire         ac_an_reset_1_request;
   wire         ac_an_reset_2_request;
   wire         ac_an_reset_3_request;
   wire         ac_an_reset_wd_request;
   wire          an_ac_lbist_ary_wrt_thru_dc;
   wire [0:0]    an_ac_sleep_en;
   wire [0:3]    an_ac_chipid_dc;
   wire [0:0]    an_ac_uncond_dbg_event;
   wire [0:31]  ac_an_debug_bus;
   wire         ac_an_coretrace_first_valid;  
   wire     ac_an_coretrace_valid;   
   wire [0:1]     ac_an_coretrace_type;    
  
   output         ac_an_req_pwr_token;    
   output         ac_an_req;     
   output [22:63] ac_an_req_ra;     
   output [0:5]   ac_an_req_ttype;     
   output [0:2]   ac_an_req_thread;    
   output         ac_an_req_wimg_w;    
   output         ac_an_req_wimg_i;    
   output         ac_an_req_wimg_m;    
   output         ac_an_req_wimg_g;    
   output [0:3]   ac_an_req_user_defined;    
   wire [0:3]   ac_an_req_spare_ctrl_a0;      
   output [0:4]   ac_an_req_ld_core_tag;     
   output [0:2]   ac_an_req_ld_xfr_len;      
   output [0:31]  ac_an_st_byte_enbl;     
   output [0:255] ac_an_st_data;    
   output         ac_an_req_endian;    
   output         ac_an_st_data_pwr_token;      
   
   
   
   wire           clk_reset;
   wire [0:15]    rate;
   wire [0:3]     div2;
   wire [0:3]     div3;
   wire [0:`NCLK_WIDTH-1]          nclk;
   wire [1:3]     osc;
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   assign rate = 16'b0000000100000000;
   assign div2 = 4'b0010;
   assign div3 = 4'b0100;
   assign clk_reset = 1'b1;

   assign an_ac_ccflush_dc = 1'b0;
    assign an_ac_rtim_sl_thold_8= 1'b0;
    assign an_ac_func_sl_thold_8= 1'b0;
    assign an_ac_func_nsl_thold_8= 1'b0;
    assign an_ac_ary_nsl_thold_8= 1'b0;
    assign an_ac_sg_8= 1'b0;
    assign an_ac_fce_8= 1'b0;
   assign scan_in = 'b0;
   assign an_ac_abst_scan_in = 'b0;
   assign an_ac_icbi_ack = 'b0;
   assign an_ac_icbi_ack_thread = 'b0;
   assign an_ac_back_inv = 'b0;
   assign an_ac_back_inv_addr = 'b0;
   assign an_ac_back_inv_target = 'b0;
   assign an_ac_back_inv_local = 'b0;
   assign an_ac_back_inv_lbit = 'b0;
   assign an_ac_back_inv_gs = 'b0;
   assign an_ac_back_inv_ind = 'b0;
   assign an_ac_back_inv_lpar_id = 'b0;
   assign an_ac_reld_ditc = 'b0;
   assign an_ac_req_spare_ctrl_a1 = 'b0;
   assign an_ac_scom_sat_id = 'b0;
   assign an_ac_scom_dch = 'b0;
   assign an_ac_scom_cch = 'b0;
   assign an_ac_checkstop = 'b0;
   assign an_ac_reset_1_complete = 'b0;
   assign an_ac_reset_2_complete = 'b0;
   assign an_ac_reset_3_complete = 'b0;
   assign an_ac_reset_wd_complete = 'b0;
   assign an_ac_pm_fetch_halt = 'b0;
   assign an_ac_gsd_test_enable_dc = 'b0;
   assign an_ac_gsd_test_acmode_dc = 'b0;
   assign an_ac_ccflush_dc = 'b0;
   assign an_ac_ccenable_dc = 'b0;
   assign an_ac_lbist_en_dc = 'b0;
   assign an_ac_lbist_ip_dc = 'b0;
   assign an_ac_lbist_ac_mode_dc = 'b0;
   assign an_ac_scan_diag_dc = 'b0;
   assign an_ac_scan_dis_dc_b = 'b0;
   assign an_ac_scan_type_dc = 'b0;
   assign an_ac_lbist_ary_wrt_thru_dc = 'b0;
   assign an_ac_sleep_en = 'b0;
   assign an_ac_chipid_dc = 'b0;
   assign an_ac_uncond_dbg_event = 'b0;
   
   assign nclk[0] = clk;
   assign nclk[1] = reset;
   assign nclk[2] = clk2x;
   assign nclk[3] = clk4x;
   assign nclk[4] = 'b0;
   assign nclk[5] = 'b0;
   


   
(*dont_touch = "true" *)   c c0(
      .nclk(nclk),
      .scan_in(scan_in),
      .scan_out(scan_out),
      
      .an_ac_rtim_sl_thold_8(an_ac_rtim_sl_thold_8),
      .an_ac_func_sl_thold_8(an_ac_func_sl_thold_8),
      .an_ac_func_nsl_thold_8(an_ac_func_nsl_thold_8),
      .an_ac_ary_nsl_thold_8(an_ac_ary_nsl_thold_8),
      .an_ac_sg_8(an_ac_sg_8),
      .an_ac_fce_8(an_ac_fce_8),
      .an_ac_abst_scan_in(an_ac_abst_scan_in),
      
      .an_ac_stcx_complete(an_ac_stcx_complete[0:`THREADS-1]),
      .an_ac_stcx_pass(an_ac_stcx_pass[0:`THREADS-1]),
      
      .an_ac_icbi_ack(an_ac_icbi_ack),
      .an_ac_icbi_ack_thread(an_ac_icbi_ack_thread),
      
      .an_ac_back_inv(an_ac_back_inv),
      .an_ac_back_inv_addr(an_ac_back_inv_addr),
      .an_ac_back_inv_target(an_ac_back_inv_target),
      .an_ac_back_inv_local(an_ac_back_inv_local),
      .an_ac_back_inv_lbit(an_ac_back_inv_lbit),
      .an_ac_back_inv_gs(an_ac_back_inv_gs),
      .an_ac_back_inv_ind(an_ac_back_inv_ind),
      .an_ac_back_inv_lpar_id(an_ac_back_inv_lpar_id),
      .ac_an_back_inv_reject(ac_an_back_inv_reject),
      .ac_an_lpar_id(ac_an_lpar_id),
      
      .an_ac_reld_data_vld(an_ac_reld_data_vld),
      .an_ac_reld_core_tag(an_ac_reld_core_tag),
      .an_ac_reld_data(an_ac_reld_data),
      .an_ac_reld_qw(an_ac_reld_qw[58:59]),
      .an_ac_reld_ecc_err(an_ac_reld_ecc_err),
      .an_ac_reld_ecc_err_ue(an_ac_reld_ecc_err_ue),
      .an_ac_reld_data_coming(an_ac_reld_data_coming),
      .an_ac_reld_ditc(an_ac_reld_ditc),
      .an_ac_reld_crit_qw(an_ac_reld_crit_qw),
      .an_ac_reld_l1_dump(an_ac_reld_l1_dump),
      .an_ac_req_spare_ctrl_a1(an_ac_req_spare_ctrl_a1),
      
      .an_ac_flh2l2_gate(an_ac_flh2l2_gate),
      .an_ac_req_ld_pop(an_ac_req_ld_pop),
      .an_ac_req_st_pop(an_ac_req_st_pop),
      .an_ac_req_st_gather(an_ac_req_st_gather),
      .an_ac_sync_ack(an_ac_sync_ack[0:`THREADS-1]),
      
      .an_ac_scom_sat_id(an_ac_scom_sat_id),
      .an_ac_scom_dch(an_ac_scom_dch),
      .an_ac_scom_cch(an_ac_scom_cch),
      .ac_an_scom_dch(ac_an_scom_dch),
      .ac_an_scom_cch(ac_an_scom_cch),
      
      .ac_an_special_attn(ac_an_special_attn),
      .ac_an_checkstop(ac_an_checkstop),
      .ac_an_local_checkstop(ac_an_local_checkstop),
      .ac_an_recov_err(ac_an_recov_err),
      .ac_an_trace_error(ac_an_trace_error),
      .ac_an_livelock_active(ac_an_livelock_active),
      .an_ac_checkstop(an_ac_checkstop),
      .an_ac_external_mchk(an_ac_external_mchk[0:`THREADS-1]),
      
      .ac_an_event_bus0(ac_an_event_bus0),
      .ac_an_event_bus1(ac_an_event_bus1),
      
      .an_ac_reset_1_complete(an_ac_reset_1_complete),
      .an_ac_reset_2_complete(an_ac_reset_2_complete),
      .an_ac_reset_3_complete(an_ac_reset_3_complete),
      .an_ac_reset_wd_complete(an_ac_reset_wd_complete),
      
      .ac_an_pm_thread_running(ac_an_pm_thread_running[0:`THREADS-1]),
      .an_ac_pm_thread_stop(an_ac_pm_thread_stop[0:`THREADS-1]),
      .an_ac_pm_fetch_halt(an_ac_pm_fetch_halt),
      .ac_an_power_managed(ac_an_power_managed),
      .ac_an_rvwinkle_mode(ac_an_rvwinkle_mode),
      
      .an_ac_gsd_test_enable_dc(an_ac_gsd_test_enable_dc),
      .an_ac_gsd_test_acmode_dc(an_ac_gsd_test_acmode_dc),
      .an_ac_ccflush_dc(an_ac_ccflush_dc),
      .an_ac_ccenable_dc(an_ac_ccenable_dc),
      .an_ac_lbist_en_dc(an_ac_lbist_en_dc),
      .an_ac_lbist_ip_dc(an_ac_lbist_ip_dc),
      .an_ac_lbist_ac_mode_dc(an_ac_lbist_ac_mode_dc),
      .an_ac_scan_diag_dc(an_ac_scan_diag_dc),
      .an_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
      
      .an_ac_scan_type_dc(an_ac_scan_type_dc),
      
      .ac_an_reset_1_request(ac_an_reset_1_request),
      .ac_an_reset_2_request(ac_an_reset_2_request),
      .ac_an_reset_3_request(ac_an_reset_3_request),
      .ac_an_reset_wd_request(ac_an_reset_wd_request),
      .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
      .an_ac_reservation_vld(an_ac_reservation_vld[0:`THREADS-1]),
      .an_ac_sleep_en(an_ac_sleep_en),
      .an_ac_ext_interrupt(an_ac_ext_interrupt[0:`THREADS-1]),
      .an_ac_crit_interrupt(an_ac_crit_interrupt[0:`THREADS-1]),
      .an_ac_perf_interrupt(an_ac_perf_interrupt[0:`THREADS-1]),
      .an_ac_hang_pulse(an_ac_hang_pulse[0:`THREADS-1]),
      .an_ac_tb_update_enable(an_ac_tb_update_enable),
      .an_ac_tb_update_pulse(an_ac_tb_update_pulse),
      .an_ac_chipid_dc(an_ac_chipid_dc),
      .an_ac_coreid(an_ac_coreid),
      .ac_an_machine_check(ac_an_machine_check[0:`THREADS-1]),
      .an_ac_debug_stop(an_ac_debug_stop),
      .ac_an_debug_trigger(ac_an_debug_trigger[0:`THREADS-1]),
      .an_ac_uncond_dbg_event(an_ac_uncond_dbg_event),
      .ac_an_debug_bus(ac_an_debug_bus),
      .ac_an_coretrace_first_valid(ac_an_coretrace_first_valid),  
      .ac_an_coretrace_valid(ac_an_coretrace_valid),  
      .ac_an_coretrace_type(ac_an_coretrace_type),  
      
      .ac_an_req_pwr_token(ac_an_req_pwr_token),
      .ac_an_req(ac_an_req),
      .ac_an_req_ra(ac_an_req_ra),
      .ac_an_req_ttype(ac_an_req_ttype),
      .ac_an_req_thread(ac_an_req_thread),
      .ac_an_req_wimg_w(ac_an_req_wimg_w),
      .ac_an_req_wimg_i(ac_an_req_wimg_i),
      .ac_an_req_wimg_m(ac_an_req_wimg_m),
      .ac_an_req_wimg_g(ac_an_req_wimg_g),
      .ac_an_req_user_defined(ac_an_req_user_defined),
      .ac_an_req_spare_ctrl_a0(ac_an_req_spare_ctrl_a0),
      .ac_an_req_ld_core_tag(ac_an_req_ld_core_tag),
      .ac_an_req_ld_xfr_len(ac_an_req_ld_xfr_len),
      .ac_an_st_byte_enbl(ac_an_st_byte_enbl),
      .ac_an_st_data(ac_an_st_data),
      .ac_an_req_endian(ac_an_req_endian),
      .ac_an_st_data_pwr_token(ac_an_st_data_pwr_token)
   );
   
endmodule
