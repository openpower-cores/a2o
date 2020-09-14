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

module tri_128x34_4w_1r1w(
   gnd,
   vdd,
   vcs,
   nclk,
   rd_act,
   wr_act,
   sg_0,
   abst_sl_thold_0,
   ary_nsl_thold_0,
   time_sl_thold_0,
   repr_sl_thold_0,
   func_sl_thold_0_b,
   func_force,
   clkoff_dc_b,
   ccflush_dc,
   scan_dis_dc_b,
   scan_diag_dc,
   d_mode_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   delay_lclkr_dc,
   wr_abst_act,
   rd0_abst_act,
   abist_di,
   abist_bw_odd,
   abist_bw_even,
   abist_wr_adr,
   abist_rd0_adr,
   tc_lbist_ary_wrt_thru_dc,
   abist_ena_1,
   abist_g8t_rd0_comp_ena,
   abist_raw_dc_b,
   obs0_abist_cmp,
   abst_scan_in,
   time_scan_in,
   repr_scan_in,
   func_scan_in,
   abst_scan_out,
   time_scan_out,
   repr_scan_out,
   func_scan_out,
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
   wr_way,
   wr_addr,
   data_in,
   rd_addr,
   data_out
);
   parameter                                    addressable_ports = 128;        
   parameter                                    addressbus_width = 7;		
   parameter                                    port_bitwidth = 34;		
   parameter                                    ways = 4;                       

   inout                                        gnd;
   inout                                        vdd;
   (* analysis_not_referenced="true" *)
   inout                                        vcs;
   input [0:`NCLK_WIDTH-1]                      nclk;
   input                                        rd_act;
   input                                        wr_act;
   input                                        sg_0;
   input                                        abst_sl_thold_0;
   input                                        ary_nsl_thold_0;
   input                                        time_sl_thold_0;
   input                                        repr_sl_thold_0;
   input                                        func_sl_thold_0_b;
   input                                        func_force;
   input                                        clkoff_dc_b;
   input                                        ccflush_dc;
   input                                        scan_dis_dc_b;
   input                                        scan_diag_dc;
   input                                        d_mode_dc;
   input [0:4]                                  mpw1_dc_b;
   input                                        mpw2_dc_b;
   input [0:4]                                  delay_lclkr_dc;
   input                                        wr_abst_act;
   input                                        rd0_abst_act;
   input [0:3]                                  abist_di;
   input                                        abist_bw_odd;
   input                                        abist_bw_even;
   input [0:addressbus_width-1]                 abist_wr_adr;
   input [0:addressbus_width-1]                 abist_rd0_adr;
   input                                        tc_lbist_ary_wrt_thru_dc;
   input                                        abist_ena_1;
   input                                        abist_g8t_rd0_comp_ena;
   input                                        abist_raw_dc_b;
   input [0:3]                                  obs0_abist_cmp;
   input [0:1]                                  abst_scan_in;
   input                                        time_scan_in;
   input                                        repr_scan_in;
   input                                        func_scan_in;
   output [0:1]                                 abst_scan_out;
   output                                       time_scan_out;
   output                                       repr_scan_out;
   output                                       func_scan_out;
   input                                        lcb_bolt_sl_thold_0;
   input                                        pc_bo_enable_2;		
   input                                        pc_bo_reset;		
   input                                        pc_bo_unload;		
   input                                        pc_bo_repair;		
   input                                        pc_bo_shdata;		
   input [0:1]                                  pc_bo_select;		
   output [0:1]                                 bo_pc_failout;		
   output [0:1]                                 bo_pc_diagloop;
   input                                        tri_lcb_mpw1_dc_b;
   input                                        tri_lcb_mpw2_dc_b;
   input                                        tri_lcb_delay_lclkr_dc;
   input                                        tri_lcb_clkoff_dc_b;
   input                                        tri_lcb_act_dis_dc;
   input [0:ways-1]                             wr_way;
   input [0:addressbus_width-1]                 wr_addr;
   input [0:port_bitwidth*ways-1]               data_in;
   input [0:addressbus_width-1]                 rd_addr;
   output [0:port_bitwidth*ways-1]              data_out;


   parameter                                    ramb_base_width = 36;
   parameter                                    ramb_base_addr = 9;
   parameter                                    ramb_width_mult = (port_bitwidth - 1)/ramb_base_width + 1;		



   localparam          rd_act_offset = 0;
   localparam          data_out_offset = rd_act_offset + 1;
   localparam          scan_right = data_out_offset + port_bitwidth*ways - 1;

   wire [0:(ramb_base_width*ramb_width_mult-1)] ramb_data_in[0:ways-1];
   wire [0:(ramb_base_width*ramb_width_mult-1)] ramb_data_out[0:ways-1];
   wire [0:ramb_base_addr-1]                    ramb_rd_addr;
   wire [0:ramb_base_addr-1]                    ramb_wr_addr;

   wire                                         rd_act_l2;
   wire [0:port_bitwidth*ways-1]                data_out_d;
   wire [0:port_bitwidth*ways-1]                data_out_l2;

   wire                                         tidn;
   (* analysis_not_referenced="true" *)
   wire                                         unused;
   wire [31:0]                                  dob;
   wire [3:0]                                   dopb;
   wire [0:scan_right]                          func_sov;

   generate
   begin
     assign tidn = 1'b0;

     if (addressbus_width < ramb_base_addr)
     begin
       assign ramb_rd_addr[0:(ramb_base_addr - addressbus_width - 1)] = {(ramb_base_addr-addressbus_width){1'b0}};
       assign ramb_rd_addr[ramb_base_addr - addressbus_width:ramb_base_addr - 1] = rd_addr;

       assign ramb_wr_addr[0:(ramb_base_addr - addressbus_width - 1)] = {(ramb_base_addr-addressbus_width){1'b0}};
       assign ramb_wr_addr[ramb_base_addr - addressbus_width:ramb_base_addr - 1] = wr_addr;
     end
     if (addressbus_width >= ramb_base_addr)
     begin
       assign ramb_rd_addr = rd_addr[addressbus_width - ramb_base_addr:addressbus_width - 1];
       assign ramb_wr_addr = wr_addr[addressbus_width - ramb_base_addr:addressbus_width - 1];
     end

     genvar  w;
     for (w = 0; w < ways; w = w + 1)
     begin : dw
       genvar  i;
       for (i = 0; i < (ramb_base_width * ramb_width_mult); i = i + 1)
       begin : din
         if (i < port_bitwidth)
         begin
           assign ramb_data_in[w][i] = data_in[w * port_bitwidth + i];
         end
         if (i >= port_bitwidth)
         begin
           assign ramb_data_in[w][i] = 1'b0;
         end
       end
     end

     for (w = 0; w < ways; w = w + 1)
     begin : aw
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
               .ADDRA(ramb_rd_addr),
               .ADDRB(ramb_wr_addr),
               .CLKA(nclk[0]),
               .CLKB(nclk[0]),
               .DIA(ramb_data_in[w][x * ramb_base_width:x * ramb_base_width + 31]),
               .DIB(ramb_data_in[w][x * ramb_base_width:x * ramb_base_width + 31]),
               .DIPA(ramb_data_in[w][x * ramb_base_width + 32:x * ramb_base_width + 35]),
               .DIPB(ramb_data_in[w][x * ramb_base_width + 32:x * ramb_base_width + 35]),
               .ENA(rd_act),
               .ENB(wr_act),
               .SSRA(nclk[1]),
               .SSRB(nclk[1]),
               .WEA(tidn),
               .WEB(wr_way[w])
            );
       end  
       assign data_out_d[w * port_bitwidth:((w + 1) * port_bitwidth) - 1] = ramb_data_out[w][0:port_bitwidth - 1];
     end  
   end
   endgenerate

   assign data_out = data_out_l2;

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(0)) rd_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(1'b1),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_force),
      .delay_lclkr(delay_lclkr_dc[0]),
      .mpw1_b(mpw1_dc_b[0]),
      .mpw2_b(mpw2_dc_b),
      .d_mode(d_mode_dc),
      .scin(1'b0),
      .scout(func_sov[rd_act_offset]),
      .din(rd_act),
      .dout(rd_act_l2)
   );

   tri_rlmreg_p #(.WIDTH(port_bitwidth*ways), .INIT(0), .NEEDS_SRESET(0)) data_out_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(rd_act_l2),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_force),
      .delay_lclkr(delay_lclkr_dc[0]),
      .mpw1_b(mpw1_dc_b[0]),
      .mpw2_b(mpw2_dc_b),
      .d_mode(d_mode_dc),
      .scin({port_bitwidth*ways{1'b0}}),
      .scout(func_sov[data_out_offset:data_out_offset + (port_bitwidth*ways) - 1]),
      .din(data_out_d),
      .dout(data_out_l2)
   );

   assign abst_scan_out = {tidn, tidn};
   assign time_scan_out = tidn;
   assign repr_scan_out = tidn;
   assign func_scan_out = tidn;

   assign bo_pc_failout = {tidn, tidn};
   assign bo_pc_diagloop = {tidn, tidn};

   assign unused = | ({nclk[2:`NCLK_WIDTH-1], sg_0, abst_sl_thold_0, ary_nsl_thold_0, time_sl_thold_0, repr_sl_thold_0, clkoff_dc_b, ccflush_dc, scan_dis_dc_b, scan_diag_dc, d_mode_dc, mpw1_dc_b, mpw2_dc_b, delay_lclkr_dc, wr_abst_act, rd0_abst_act, abist_di, abist_bw_odd, abist_bw_even, abist_wr_adr, abist_rd0_adr, tc_lbist_ary_wrt_thru_dc, abist_ena_1, abist_g8t_rd0_comp_ena, abist_raw_dc_b, obs0_abist_cmp, abst_scan_in, time_scan_in, repr_scan_in, func_scan_in, lcb_bolt_sl_thold_0, pc_bo_enable_2, pc_bo_reset, pc_bo_unload, pc_bo_repair, pc_bo_shdata, pc_bo_select, tri_lcb_mpw1_dc_b, tri_lcb_mpw2_dc_b, tri_lcb_delay_lclkr_dc, tri_lcb_clkoff_dc_b, tri_lcb_act_dis_dc, dob, dopb, func_sov, ramb_data_out[0][34:35], ramb_data_out[1][34:35], ramb_data_out[2][34:35], ramb_data_out[3][34:35]});

endmodule

