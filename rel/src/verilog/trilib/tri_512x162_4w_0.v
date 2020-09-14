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

module tri_512x162_4w_0(
   gnd,
   vdd,
   vcs,
   nclk,
   ccflush_dc,
   lcb_clkoff_dc_b,
   lcb_d_mode_dc,
   lcb_act_dis_dc,
   lcb_ary_nsl_thold_0,
   lcb_sg_1,
   lcb_abst_sl_thold_0,
   lcb_func_sl_thold_0_b,
   func_force,
   scan_diag_dc,
   scan_dis_dc_b,
   func_scan_in,
   func_scan_out,
   abst_scan_in,
   abst_scan_out,
   lcb_delay_lclkr_np_dc,
   ctrl_lcb_delay_lclkr_np_dc,
   dibw_lcb_delay_lclkr_np_dc,
   ctrl_lcb_mpw1_np_dc_b,
   dibw_lcb_mpw1_np_dc_b,
   lcb_mpw1_pp_dc_b,
   lcb_mpw1_2_pp_dc_b,
   aodo_lcb_delay_lclkr_dc,
   aodo_lcb_mpw1_dc_b,
   aodo_lcb_mpw2_dc_b,
   lcb_time_sg_0,
   lcb_time_sl_thold_0,
   time_scan_in,
   time_scan_out,
   bitw_abist,
   lcb_repr_sl_thold_0,
   lcb_repr_sg_0,
   repr_scan_in,
   repr_scan_out,
   tc_lbist_ary_wrt_thru_dc,
   abist_en_1,
   din_abist,
   abist_cmp_en,
   abist_raw_b_dc,
   data_cmp_abist,
   addr_abist,
   r_wb_abist,
   write_thru_en_dc,
   lcb_bolt_sl_thold_0,
   pc_bo_enable_2,
   pc_bo_reset,
   pc_bo_unload,
   pc_bo_repair,
   pc_bo_shdata,
   pc_bo_select,
   bo_pc_failout,
   bo_pc_diagloop,
   tri_lcb_mpw1_dc_b,
   tri_lcb_mpw2_dc_b,
   tri_lcb_delay_lclkr_dc,
   tri_lcb_clkoff_dc_b,
   tri_lcb_act_dis_dc,
   read_act,
   write_act,
   write_enable,
   write_way,
   addr,
   data_in,
   data_out
);
   parameter                                      addressable_ports = 512;	
   parameter                                      addressbus_width = 9;		
   parameter                                      port_bitwidth = 162;		
   parameter                                      ways = 4;		
   inout                                          gnd;
   inout                                          vdd;
   (* analysis_not_referenced="true" *)
   inout                                          vcs;
   input [0:`NCLK_WIDTH-1]                        nclk;
   input                                          ccflush_dc;
   input                                          lcb_clkoff_dc_b;
   input                                          lcb_d_mode_dc;
   input                                          lcb_act_dis_dc;
   input                                          lcb_ary_nsl_thold_0;
   input                                          lcb_sg_1;
   input                                          lcb_abst_sl_thold_0;
   input                                          lcb_func_sl_thold_0_b;
   input                                          func_force;
   input                                          scan_diag_dc;
   input                                          scan_dis_dc_b;
   input                                          func_scan_in;
   output                                         func_scan_out;
   input [0:1]                                    abst_scan_in;
   output [0:1]                                   abst_scan_out;
   input                                          lcb_delay_lclkr_np_dc;
   input                                          ctrl_lcb_delay_lclkr_np_dc;
   input                                          dibw_lcb_delay_lclkr_np_dc;
   input                                          ctrl_lcb_mpw1_np_dc_b;
   input                                          dibw_lcb_mpw1_np_dc_b;
   input                                          lcb_mpw1_pp_dc_b;
   input                                          lcb_mpw1_2_pp_dc_b;
   input                                          aodo_lcb_delay_lclkr_dc;
   input                                          aodo_lcb_mpw1_dc_b;
   input                                          aodo_lcb_mpw2_dc_b;
   input                                          lcb_time_sg_0;
   input                                          lcb_time_sl_thold_0;
   input                                          time_scan_in;
   output                                         time_scan_out;
   input [0:1]                                    bitw_abist;
   input                                          lcb_repr_sl_thold_0;
   input                                          lcb_repr_sg_0;
   input                                          repr_scan_in;
   output                                         repr_scan_out;
   input                                          tc_lbist_ary_wrt_thru_dc;
   input                                          abist_en_1;
   input [0:3]                                    din_abist;
   input                                          abist_cmp_en;
   input                                          abist_raw_b_dc;
   input [0:3]                                    data_cmp_abist;
   input [0:addressbus_width-1]                   addr_abist;
   input                                          r_wb_abist;
   input                                          write_thru_en_dc;
   input                                          lcb_bolt_sl_thold_0;	
   input                                          pc_bo_enable_2;	
   input                                          pc_bo_reset;		
   input                                          pc_bo_unload;
   input                                          pc_bo_repair;		
   input                                          pc_bo_shdata;		
   input [0:1]                                    pc_bo_select;		
   output [0:1]                                   bo_pc_failout;	
   output [0:1]                                   bo_pc_diagloop;
   input                                          tri_lcb_mpw1_dc_b;
   input                                          tri_lcb_mpw2_dc_b;
   input                                          tri_lcb_delay_lclkr_dc;
   input                                          tri_lcb_clkoff_dc_b;
   input                                          tri_lcb_act_dis_dc;
   input [0:1]                                    read_act;
   input [0:3]                                    write_act;
   input                                          write_enable;
   input [0:ways-1]                               write_way;
   input [0:addressbus_width-1]                   addr;
   input [0:port_bitwidth-1]                      data_in;
   output [0:port_bitwidth*ways-1]                data_out;


   parameter            ramb_base_width = 36;
   parameter            ramb_base_addr = 9;
   parameter            ramb_width_mult = (port_bitwidth - 1)/ramb_base_width + 1;	


   wire [0:ramb_base_width*ramb_width_mult-1]   ramb_data_in;
   wire [0:ramb_base_width*ramb_width_mult-1]   ramb_data_out[0:ways-1];
   wire [0:ramb_base_addr-1]                    ramb_addr;

   wire                                         rd_act_d;
   wire                                         rd_act_l2;
   wire [0:port_bitwidth*ways-1]                data_out_d;
   wire [0:port_bitwidth*ways-1]                data_out_l2;

   wire                                         lcb_sg_0;

   wire [0:ways-1]                                act;
   wire [0:ways-1]                                write;
   wire                                           tidn;
    (* analysis_not_referenced="true" *)
   wire                                           unused;
   wire [31:0]                                    dob;
   wire [3:0]                                     dopb;
   wire [0:port_bitwidth*ways-1]                  unused_scout;

   generate
   begin
     assign tidn = 1'b0;

     if (addressbus_width < ramb_base_addr)
     begin
       assign ramb_addr[0:(ramb_base_addr - addressbus_width - 1)] = {(ramb_base_addr-addressbus_width){1'b0}};
       assign ramb_addr[ramb_base_addr - addressbus_width:ramb_base_addr - 1] = addr;
     end
     if (addressbus_width >= ramb_base_addr)
     begin
       assign ramb_addr = addr[addressbus_width - ramb_base_addr:addressbus_width - 1];
     end

     genvar  i;
     for (i = 0; i < ramb_base_width*ramb_width_mult; i = i + 1)
     begin : din
       if (i < port_bitwidth)
         assign ramb_data_in[i] = data_in[i];
       if (i >= port_bitwidth)
            assign ramb_data_in[i] = 1'b0;
     end

     genvar  w;
     for (w = 0; w < ways; w = w + 1)
     begin : aw
       assign act[w] = (|(read_act)) | write_way[w];
       assign write[w] = write_enable & write_way[w];

       genvar  x;
       for (x = 0; x < ramb_width_mult; x = x + 1)
       begin : ax
         RAMB16_S36_S36
             #(.SIM_COLLISION_CHECK("NONE"))            
         arr(
               .DOA(ramb_data_out[w][x * ramb_base_width:x * ramb_base_width + 31]),
               .DOB(dob),
               .DOPA(ramb_data_out[w][x * ramb_base_width + 32:x * ramb_base_width + 35]),
               .DOPB(dopb),
               .ADDRA(ramb_addr),
               .ADDRB(ramb_addr),
               .CLKA(nclk[0]),
               .CLKB(tidn),
               .DIA(ramb_data_in[x * ramb_base_width:x * ramb_base_width + 31]),
               .DIB(ramb_data_in[x * ramb_base_width:x * ramb_base_width + 31]),
               .DIPA(ramb_data_in[x * ramb_base_width + 32:x * ramb_base_width + 35]),
               .DIPB(ramb_data_in[x * ramb_base_width + 32:x * ramb_base_width + 35]),
               .ENA(act[w]),
               .ENB(tidn),
               .SSRA(nclk[1]),
               .SSRB(tidn),
               .WEA(write[w]),
               .WEB(tidn)
            );
       end  

       assign data_out_d[w * port_bitwidth:((w + 1) * port_bitwidth) - 1] = ramb_data_out[w][0:port_bitwidth - 1];

     end  

   assign data_out = data_out_l2;

   assign rd_act_d = |(read_act);	

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(0)) rd_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(1'b1),
      .thold_b(lcb_func_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(func_force),
      .delay_lclkr(tri_lcb_delay_lclkr_dc),
      .mpw1_b(tri_lcb_mpw1_dc_b),
      .mpw2_b(tri_lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(1'b0),
      .scout(func_scan_out),
      .din(rd_act_d),
      .dout(rd_act_l2)
   );

   tri_rlmreg_p #(.WIDTH(port_bitwidth*ways), .INIT(0), .NEEDS_SRESET(0)) data_out_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(rd_act_l2),
      .thold_b(lcb_func_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(func_force),
      .delay_lclkr(tri_lcb_delay_lclkr_dc),
      .mpw1_b(tri_lcb_mpw1_dc_b),
      .mpw2_b(tri_lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin({port_bitwidth*ways{1'b0}}),
      .scout(unused_scout),
      .din(data_out_d),
      .dout(data_out_l2)
   );

   tri_plat #(.WIDTH(1)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(ccflush_dc),
      .din(lcb_sg_1),
      .q(lcb_sg_0)
   );



     assign abst_scan_out = 2'b00;
     assign time_scan_out = 1'b0;
     assign repr_scan_out = 1'b0;

     assign bo_pc_failout = 2'b00;
     assign bo_pc_diagloop = 2'b00;

     assign unused = | ({nclk[2:`NCLK_WIDTH-1], ramb_data_out[0][port_bitwidth:ramb_base_width * ramb_width_mult - 1], ramb_data_out[1][port_bitwidth:ramb_base_width * ramb_width_mult - 1], ramb_data_out[2][port_bitwidth:ramb_base_width * ramb_width_mult - 1], ramb_data_out[3][port_bitwidth:ramb_base_width * ramb_width_mult - 1], ccflush_dc, lcb_clkoff_dc_b, lcb_d_mode_dc, lcb_act_dis_dc, scan_dis_dc_b, scan_diag_dc, bitw_abist, lcb_sg_1, lcb_time_sg_0, lcb_repr_sg_0, lcb_abst_sl_thold_0, lcb_repr_sl_thold_0, lcb_time_sl_thold_0, lcb_ary_nsl_thold_0, tc_lbist_ary_wrt_thru_dc, abist_en_1, din_abist, abist_cmp_en, abist_raw_b_dc, data_cmp_abist, addr_abist, r_wb_abist, write_thru_en_dc, abst_scan_in, time_scan_in, repr_scan_in, func_scan_in, lcb_delay_lclkr_np_dc, ctrl_lcb_delay_lclkr_np_dc, dibw_lcb_delay_lclkr_np_dc, ctrl_lcb_mpw1_np_dc_b, dibw_lcb_mpw1_np_dc_b, lcb_mpw1_pp_dc_b, lcb_mpw1_2_pp_dc_b, aodo_lcb_delay_lclkr_dc, aodo_lcb_mpw1_dc_b, aodo_lcb_mpw2_dc_b, lcb_bolt_sl_thold_0, pc_bo_enable_2, pc_bo_reset, pc_bo_unload, pc_bo_repair, pc_bo_shdata, pc_bo_select, tri_lcb_mpw1_dc_b, tri_lcb_mpw2_dc_b, tri_lcb_delay_lclkr_dc, tri_lcb_clkoff_dc_b, tri_lcb_act_dis_dc, write_act, dob, dopb, unused_scout});
   end
   endgenerate
endmodule


