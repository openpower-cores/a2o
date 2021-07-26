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

`ifndef _tri_a2o_vh_
`define _tri_a2o_vh_

`include "tri.vh"

// Use this line for 1 thread.  Comment out for 2 thread design.
`define THREADS1

`define  gpr_t  3'b000
`define  cr_t  3'b001
`define  lr_t  3'b010
`define  ctr_t  3'b011
`define  xer_t  3'b100
`define  spr_t  3'b101
`define  axu0_t  3'b110
`define  axu1_t  3'b111

`ifdef THREADS1
    `define  THREADS  1
    `define  THREAD_POOL_ENC  0
    `define  THREADS_POOL_ENC  0
`else
    `define  THREADS  2
    `define  THREAD_POOL_ENC  1
    `define  THREADS_POOL_ENC  1
`endif
`define  EFF_IFAR_ARCH  62
`define  EFF_IFAR_WIDTH  20
`define  EFF_IFAR   20
`define  FPR_POOL_ENC 6
`define  REGMODE 6
`define  FPR_POOL 64
`define  REAL_IFAR_WIDTH  42
`define  EMQ_ENTRIES  4
`define  GPR_WIDTH  64
`define  ITAG_SIZE_ENC  7
`define  CPL_Q_DEPTH  32
`define  CPL_Q_DEPTH_ENC  6
`define  GPR_WIDTH_ENC 6
`define  GPR_POOL_ENC  6
`define  GPR_POOL  64
`define  GPR_UCODE_POOL  4
`define  CR_POOL_ENC  5
`define  CR_POOL  24
`define  CR_UCODE_POOL  1
`define  BR_POOL_ENC  3
`define  BR_POOL      8
`define  LR_POOL_ENC  3
`define  LR_POOL  8
`define  LR_UCODE_POOL  0
`define  CTR_POOL_ENC  3
`define  CTR_POOL  8
`define  CTR_UCODE_POOL  0
`define  XER_POOL_ENC  4
`define  XER_POOL  12
`define  XER_UCODE_POOL  0
`define  LDSTQ_ENTRIES  16
`define  LDSTQ_ENTRIES_ENC  4
`define  STQ_ENTRIES  12
`define  STQ_ENTRIES_ENC  4
`define  STQ_FWD_ENTRIES  4		// number of stq entries that can be forwarded from
`define  STQ_DATA_SIZE  64		// 64 or 128 Bit store data sizes supported
`define  DC_SIZE  15			// 14 => 16K L1D$, 15 => 32K L1D$
`define  CL_SIZE  6			// 6 => 64B CLINE, 7 => 128B CLINE
`define  LMQ_ENTRIES  8
`define  LMQ_ENTRIES_ENC  3
`define  LGQ_ENTRIES  8
`define  AXU_SPARE_ENC  3
`define  RV_FX0_ENTRIES  12
`define  RV_FX1_ENTRIES  12
`define  RV_LQ_ENTRIES  16
`define  RV_AXU0_ENTRIES  12
`define  RV_AXU1_ENTRIES  0
`define  RV_FX0_ENTRIES_ENC  4
`define  RV_FX1_ENTRIES_ENC  4
`define  RV_LQ_ENTRIES_ENC  4
`define  RV_AXU0_ENTRIES_ENC  4
`define  RV_AXU1_ENTRIES_ENC  1
`define  UCODE_ENTRIES  8
`define  UCODE_ENTRIES_ENC  3
`define  FXU1_ENABLE  1
`define  TYPE_WIDTH 3
`define  IBUFF_INSTR_WIDTH  70
`define  IBUFF_IFAR_WIDTH  20
`define  IBUFF_DEPTH  16
`define  PF_IAR_BITS  12		// number of IAR bits used by prefetch
`define  FXU0_PIPE_START 1
`define  FXU0_PIPE_END 8
`define  FXU1_PIPE_START 1
`define  FXU1_PIPE_END 5
`define  LQ_LOAD_PIPE_START 4
`define  LQ_LOAD_PIPE_END 8
`define  LQ_REL_PIPE_START 2
`define  LQ_REL_PIPE_END 4
`define  LOAD_CREDITS   8
`define  STORE_CREDITS 4
`define  IUQ_ENTRIES   4 		   // Instruction Fetch Queue Size
`define  MMQ_ENTRIES   2 		   // MMU Queue Size
`define  CR_WIDTH 4
`define  BUILD_PFETCH  1		   // 1=> include pfetch in the build, 0=> build without pfetch
`define  PF_IFAR_WIDTH  12
`define  PFETCH_INITIAL_DEPTH  0	// the initial value for the SPR that determines how many lines to prefetch
`define  PFETCH_Q_SIZE_ENC  3		// number of bits to address queue size (3 => 8 entries, 4 => 16 entries)
`define  PFETCH_Q_SIZE  8		   // number of entries
`define  INCLUDE_IERAT_BYPASS  1	// 0 => Removes IERAT Bypass logic, 1=> includes (power savings)
`define  XER_WIDTH  10
`define  INIT_BHT  1			      // 0=> array init time set to 16 clocks, 1=> increased to 512 to init BHT
`define  INIT_IUCR0  16'h00FA	   // BP enabled 
`define  INIT_MASK  2'b10
`define  RELQ_INCLUDE  0		   // Reload Queue Included

`define  G_BRANCH_LEN  `EFF_IFAR_WIDTH + 1 + 1 + `EFF_IFAR_WIDTH + 3 + 18 + 1

// IERAT boot config entry values
`define  IERAT_BCFG_EPN_0TO15      0
`define  IERAT_BCFG_EPN_16TO31     0
`define  IERAT_BCFG_EPN_32TO47     (2 ** 16) - 1   // 1 for 64K, 65535 for 4G
`define  IERAT_BCFG_EPN_48TO51     (2 ** 4) - 1    // 15 for 64K or 4G
`define  IERAT_BCFG_RPN_22TO31     0               // (2 ** 10) - 1  for x3ff
`define  IERAT_BCFG_RPN_32TO47     (2 ** 16) - 1   // 1 for 64K, 8181 for 512M, 65535 for 4G
`define  IERAT_BCFG_RPN_48TO51     (2 ** 4) - 1    // 15 for 64K or 4G
`define  IERAT_BCFG_RPN2_32TO47    0               // 0 to match dd1 hardwired value; (2**16)-1 for same 64K page
`define  IERAT_BCFG_RPN2_48TO51    0               // 0 to match dd1 hardwired value;  (2**4)-2 for adjacent 4K page
`define  IERAT_BCFG_ATTR    0                      // u0-u3, endian

// DERAT boot config entry values
`define  DERAT_BCFG_EPN_0TO15      0
`define  DERAT_BCFG_EPN_16TO31     0
`define  DERAT_BCFG_EPN_32TO47     (2 ** 16) - 1   // 1 for 64K, 65535 for 4G
`define  DERAT_BCFG_EPN_48TO51     (2 ** 4) - 1    // 15 for 64K or 4G
`define  DERAT_BCFG_RPN_22TO31     0               // (2 ** 10) - 1  for x3ff
`define  DERAT_BCFG_RPN_32TO47     (2 ** 16) - 1   // 1 for 64K, 8191 for 512M, 65535 for 4G
`define  DERAT_BCFG_RPN_48TO51     (2 ** 4) - 1    // 15 for 64K or 4G
`define  DERAT_BCFG_RPN2_32TO47    0               // 0 to match dd1 hardwired value; (2**16)-1 for same 64K page
`define  DERAT_BCFG_RPN2_48TO51    0               // 0 to match dd1 hardwired value;  (2**4)-2 for adjacent 4K page
`define  DERAT_BCFG_ATTR    0                      // u0-u3, endian

// Do NOT add any defines below this line
`endif  //_tri_a2o_vh_
