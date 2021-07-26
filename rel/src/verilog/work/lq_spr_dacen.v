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

//  Description:  XU SPR - DAC Enable Component
//
//*****************************************************************************

`include "tri_a2o.vh"

module lq_spr_dacen(
   spr_msr_pr,
   spr_msr_ds,
   spr_dbcr0_dac,
   spr_dbcr_dac_us,
   spr_dbcr_dac_er,
   val,
   load,
   store,
   dacr_en,
   dacw_en
);

//-------------------------------------------------------------------
// Generics
//-------------------------------------------------------------------
//parameter            `THREADS = 4;

input [0:`THREADS-1]  spr_msr_pr;
input [0:`THREADS-1]  spr_msr_ds;

input [0:2*`THREADS-1]  spr_dbcr0_dac;
input [0:2*`THREADS-1]  spr_dbcr_dac_us;
input [0:2*`THREADS-1]  spr_dbcr_dac_er;

input [0:`THREADS-1]  val;
input                 load;
input                 store;

output [0:`THREADS-1] dacr_en;
output [0:`THREADS-1] dacw_en;

// Signals
wire [0:1]            spr_dbcr0_dac_tid[0:`THREADS-1];
wire [0:1]            spr_dbcr_dac_us_tid[0:`THREADS-1];
wire [0:1]            spr_dbcr_dac_er_tid[0:`THREADS-1];
wire [0:`THREADS-1]   dac_ld_en;
wire [0:`THREADS-1]   dac_st_en;
wire [0:`THREADS-1]   dac_us_en;
wire [0:`THREADS-1]   dac_er_en;

generate begin : sprTid
   genvar tid;
   for (tid=0; tid<`THREADS; tid=tid+1) begin : sprTid
      assign spr_dbcr0_dac_tid[tid]   = spr_dbcr0_dac[tid*2:tid*2+1];
      assign spr_dbcr_dac_us_tid[tid] = spr_dbcr_dac_us[tid*2:tid*2+1];
      assign spr_dbcr_dac_er_tid[tid] = spr_dbcr_dac_er[tid*2:tid*2+1];
   end
end
endgenerate

generate begin : dacen_gen
      genvar               t;
      for (t = 0; t <= `THREADS - 1; t = t + 1) begin : dacen_gen
         assign dac_ld_en[t] = spr_dbcr0_dac_tid[t][0] & load;
         assign dac_st_en[t] = spr_dbcr0_dac_tid[t][1] & store;

         assign dac_us_en[t] = ((~spr_dbcr_dac_us_tid[t][0]) & (~spr_dbcr_dac_us_tid[t][1])) | (spr_dbcr_dac_us_tid[t][0] & (spr_dbcr_dac_us_tid[t][1] ~^ spr_msr_pr[t]));

         assign dac_er_en[t] = ((~spr_dbcr_dac_er_tid[t][0]) & (~spr_dbcr_dac_er_tid[t][1])) | (spr_dbcr_dac_er_tid[t][0] & (spr_dbcr_dac_er_tid[t][1] ~^ spr_msr_ds[t]));
         assign dacr_en[t] = val[t] & dac_ld_en[t] & dac_us_en[t] & dac_er_en[t];
         assign dacw_en[t] = val[t] & dac_st_en[t] & dac_us_en[t] & dac_er_en[t];
      end
   end
endgenerate

endmodule

