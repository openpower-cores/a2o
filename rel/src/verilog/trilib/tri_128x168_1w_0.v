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

// *!****************************************************************
// *! FILENAME    : tri_128x168_1w_0.v
// *! DESCRIPTION : 128 Entry x 168 bit x 1 way array
// *!
// *!****************************************************************

`include "tri_a2o.vh"

module tri_128x168_1w_0(
   gnd,
   vdd,
   vcs,
   nclk,
   act,
   ccflush_dc,
   scan_dis_dc_b,
   scan_diag_dc,
   abst_scan_in,
   repr_scan_in,
   time_scan_in,
   abst_scan_out,
   repr_scan_out,
   time_scan_out,
   lcb_d_mode_dc,
   lcb_clkoff_dc_b,
   lcb_act_dis_dc,
   lcb_mpw1_dc_b,
   lcb_mpw2_dc_b,
   lcb_delay_lclkr_dc,
   lcb_sg_1,
   lcb_time_sg_0,
   lcb_repr_sg_0,
   lcb_abst_sl_thold_0,
   lcb_repr_sl_thold_0,
   lcb_time_sl_thold_0,
   lcb_ary_nsl_thold_0,
   lcb_bolt_sl_thold_0,
   tc_lbist_ary_wrt_thru_dc,
   abist_en_1,
   din_abist,
   abist_cmp_en,
   abist_raw_b_dc,
   data_cmp_abist,
   addr_abist,
   r_wb_abist,
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
   write_enable,
   addr,
   data_in,
   data_out
);
   parameter                                    addressable_ports = 128;	// number of addressable register in this array
   parameter                                    addressbus_width = 7;		// width of the bus to address all ports (2^addressbus_width >= addressable_ports)
   parameter                                    port_bitwidth = 168;		// bitwidth of ports
   parameter                                    ways = 1;                       // number of ways

   // POWER PINS
   inout                                        gnd;
   inout                                        vdd;
   inout                                        vcs;

   // CLOCK and CLOCKCONTROL ports
   input [0:`NCLK_WIDTH-1]                      nclk;
   input                                        act;
   input                                        ccflush_dc;
   input                                        scan_dis_dc_b;
   input                                        scan_diag_dc;

   input                                        abst_scan_in;
   input                                        repr_scan_in;
   input                                        time_scan_in;
   output                                       abst_scan_out;
   output                                       repr_scan_out;
   output                                       time_scan_out;

   input                                        lcb_d_mode_dc;
   input                                        lcb_clkoff_dc_b;
   input                                        lcb_act_dis_dc;
   input [0:4]                                  lcb_mpw1_dc_b;
   input                                        lcb_mpw2_dc_b;
   input [0:4]                                  lcb_delay_lclkr_dc;

   input                                        lcb_sg_1;
   input                                        lcb_time_sg_0;
   input                                        lcb_repr_sg_0;

   input                                        lcb_abst_sl_thold_0;
   input                                        lcb_repr_sl_thold_0;
   input                                        lcb_time_sl_thold_0;
   input                                        lcb_ary_nsl_thold_0;
   input                                        lcb_bolt_sl_thold_0;		// thold for any regs inside backend

   input                                        tc_lbist_ary_wrt_thru_dc;
   input                                        abist_en_1;
   input [0:3]                                  din_abist;
   input                                        abist_cmp_en;
   input                                        abist_raw_b_dc;
   input [0:3]                                  data_cmp_abist;
   input [0:6]                                  addr_abist;
   input                                        r_wb_abist;

   // BOLT-ON
   input                                        pc_bo_enable_2;		// general bolt-on enable, probably DC
   input                                        pc_bo_reset;		// execute sticky bit decode
   input                                        pc_bo_unload;
   input                                        pc_bo_repair;		// load repair reg
   input                                        pc_bo_shdata;		// shift data for timing write
   input                                        pc_bo_select;		// select for mask and hier writes
   output                                       bo_pc_failout;		// fail/no-fix reg
   output                                       bo_pc_diagloop;
   input                                        tri_lcb_mpw1_dc_b;
   input                                        tri_lcb_mpw2_dc_b;
   input                                        tri_lcb_delay_lclkr_dc;
   input                                        tri_lcb_clkoff_dc_b;
   input                                        tri_lcb_act_dis_dc;

   // PORTS
   input                                        write_enable;
   input [0:addressbus_width-1]                 addr;
   input [0:port_bitwidth-1]                    data_in;
   output [0:port_bitwidth-1]                   data_out;

   // tri_128x168_1w_0

   parameter                                    ramb_base_width = 36;
   parameter                                    ramb_base_addr = 9;
   parameter                                    ramb_width_mult = (port_bitwidth - 1)/ramb_base_width + 1;		// # of RAMB's per way


   // Configuration Statement for NCsim
   //for all:RAMB16_S36_S36 use entity unisim.RAMB16_S36_S36;

   wire [0:(ramb_base_width*ramb_width_mult-1)] ramb_data_in;
   wire [0:(ramb_base_width*ramb_width_mult-1)] ramb_data_out[0:ways-1];
   wire [0:ramb_base_addr-1]                    ramb_addr;

   wire [0:ways-1]                              write;
   wire                                         tidn;
   (* analysis_not_referenced="true" *)
   wire                                         unused;
   wire [0:(ramb_base_width*ramb_width_mult-1)] unused_dob;


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
     for (i = 0; i < (ramb_base_width * ramb_width_mult); i = i + 1)
     begin : din
       if (i < port_bitwidth)
       begin
         assign ramb_data_in[i] = data_in[i];
       end
       if (i >= port_bitwidth)
       begin
         assign ramb_data_in[i] = 1'b0;
       end
     end

     genvar  w;
     for (w = 0; w < ways; w = w + 1)
     begin : aw
       assign write[w] = write_enable;

       genvar  x;
       for (x = 0; x < ramb_width_mult; x = x + 1)
       begin : ax

         RAMB16_S36_S36
            #(.SIM_COLLISION_CHECK("NONE"))     // all, none, warning_only, generate_x_only
         ram(
               .DOA(ramb_data_out[w][x * ramb_base_width:x * ramb_base_width + 31]),
               .DOB(unused_dob[x * ramb_base_width:x * ramb_base_width + 31]),
               .DOPA(ramb_data_out[w][x * ramb_base_width + 32:x * ramb_base_width + 35]),
               .DOPB(unused_dob[x * ramb_base_width + 32:x * ramb_base_width + 35]),
               .ADDRA(ramb_addr),
               .ADDRB(ramb_addr),
               .CLKA(nclk[0]),
               .CLKB(tidn),
               .DIA(ramb_data_in[x * ramb_base_width:x * ramb_base_width + 31]),
               .DIB(ramb_data_in[x * ramb_base_width:x * ramb_base_width + 31]),
               .DIPA(ramb_data_in[x * ramb_base_width + 32:x * ramb_base_width + 35]),
               .DIPB(ramb_data_in[x * ramb_base_width + 32:x * ramb_base_width + 35]),
               .ENA(act),
               .ENB(tidn),
               .SSRA(nclk[1]),
               .SSRB(tidn),
               .WEA(write[w]),
               .WEB(tidn)
            );
       end  //ax
       assign data_out[w * port_bitwidth:((w + 1) * port_bitwidth) - 1] = ramb_data_out[w][0:port_bitwidth - 1];
     end  //aw
   end
   endgenerate

   assign abst_scan_out = abst_scan_in;
   assign repr_scan_out = repr_scan_in;
   assign time_scan_out = time_scan_in;

   assign bo_pc_failout = 1'b0;
   assign bo_pc_diagloop = 1'b0;

   assign unused = |({ramb_data_out[0][port_bitwidth:ramb_base_width * ramb_width_mult - 1], ccflush_dc, scan_dis_dc_b, scan_diag_dc, lcb_d_mode_dc, lcb_clkoff_dc_b, lcb_act_dis_dc, lcb_mpw1_dc_b, lcb_mpw2_dc_b, lcb_delay_lclkr_dc, lcb_sg_1, lcb_time_sg_0, lcb_repr_sg_0, lcb_abst_sl_thold_0, lcb_repr_sl_thold_0, lcb_time_sl_thold_0, lcb_ary_nsl_thold_0, lcb_bolt_sl_thold_0, tc_lbist_ary_wrt_thru_dc, abist_en_1, din_abist, abist_cmp_en, abist_raw_b_dc, data_cmp_abist, addr_abist, r_wb_abist, pc_bo_enable_2, pc_bo_reset, pc_bo_unload, pc_bo_repair, pc_bo_shdata, pc_bo_select, tri_lcb_mpw1_dc_b, tri_lcb_mpw2_dc_b, tri_lcb_delay_lclkr_dc, tri_lcb_clkoff_dc_b, tri_lcb_act_dis_dc, gnd, vdd, vcs, nclk, unused_dob});
endmodule
