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
// *! FILENAME    : mmu_a2o.vh
// *! DESCRIPTION : Constants for a2o mmu
// *! CONTENTS    :
// *!
// *!****************************************************************

`ifndef _mmu_a2o_vh_
`define _mmu_a2o_vh_
`define  EXPAND_TYPE  2       // 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
`define  EXPAND_TLB_TYPE  2   // 0 = erat-only, 1 = tlb logic, 2 = tlb array

// Use this line for A2o core.  Comment out for A2i design.
`define A2O
// comment out this line to compile for erat-only mode
`define TLB
// uncomment this line to compile for category E.MF (Embedded.MMU Freescale)
`define CAT_EMF
// uncomment this line to compile for category E.LRAT (Embedded.Logical to Real Address Translate)
`define CAT_LRAT
// uncomment this line to compile for category E.PT (Embedded.Page Table)
`define CAT_EPT
// uncomment this line to compile for wait on completion exception taken before spr updates occur
`define WAIT_UPDATES

// Use this line for 2 mmu h/w thread.  Comment out for 1 thread design.
`define MM_THREADS2

// set this variable for internal thread-wise generates
`ifdef MM_THREADS2
    `define  MM_THREADS  2
    `define  MM_THREADS_POOL_ENC  1
`else
    `define  MM_THREADS  1
    `define  MM_THREADS_POOL_ENC  0
`endif



`define            THDID_WIDTH             4    // this is a pre-defined tag field width
`define            PID_WIDTH               14
`define            PID_WIDTH_ERAT          8
`define            LPID_WIDTH              8
`define            T_WIDTH                 3
`define            CLASS_WIDTH             2
`define            EXTCLASS_WIDTH          2
`define            TLBSEL_WIDTH            2
`define            EPN_WIDTH               52
`define            VPN_WIDTH               61
`define            ERAT_CAM_DATA_WIDTH            75
`define            ERAT_ARY_DATA_WIDTH            73
`define            ERAT_REL_DATA_WIDTH            132
`define            WS_WIDTH                2
`define            RS_IS_WIDTH             9
`define            RA_ENTRY_WIDTH          12
`define            RS_DATA_WIDTH           64
`define            DATA_OUT_WIDTH          64
`define            ERROR_WIDTH             3
`define            TLB_NUM_ENTRY                512
`define            TLB_NUM_ENTRY_LOG2           9
`define            TLB_WAYS                     4
`define            TLB_ADDR_WIDTH               7
`define            TLB_WAY_WIDTH           168
`define            TLB_WORD_WIDTH          84
`define            TLB_SEQ_WIDTH           6
`define            POR_SEQ_WIDTH           3
`define            WATERMARK_WIDTH         4
`define            EPTR_WIDTH              4
`define            LRU_WIDTH               16
`define            MMUCR0_WIDTH            20
`define            MMUCR1_WIDTH            32
`define            MMUCR2_WIDTH            32
`define            MMUCR3_WIDTH            15
`define            SPR_CTL_WIDTH           3
`define            SPR_ETID_WIDTH          2
`define            SPR_ADDR_WIDTH          10
`define            SPR_DATA_WIDTH          64
`define            DEBUG_TRIGGER_WIDTH     12
`define            PERF_EVENT_WIDTH        4   // events per thread
`define            REAL_ADDR_WIDTH         42
`define            RPN_WIDTH               30  // real_addr_WIDTH-12
`define            PTE_WIDTH               64  // page table entry
`define            CHECK_PARITY            1

`ifdef A2O
`define            DEBUG_TRACE_WIDTH       32
`define            ITAG_SIZE_ENC            7
`define            EMQ_ENTRIES              4
`define            TLB_TAG_WIDTH            122
`define            MESR1_WIDTH     24   // 4 x 6 bits, 1 of 64 events
`define            MESR2_WIDTH     24
`define            PERF_MUX_WIDTH  64   // events per bus bit
`else
`define            DEBUG_TRACE_WIDTH       88
`define            TLB_TAG_WIDTH            110
`define            MESR1_WIDTH     20   // 4 x 5 bits, 1 of 32 events
`define            MESR2_WIDTH     20
`define            PERF_MUX_WIDTH  32   // events per bus bit
`endif

//tlb_tagx_d <= ([0:51]  epn &
//               [52:65] pid &
//               [66:67] IS &
//               [68:69] Class &
//               [70:73] state (pr,gs,as,cm) &
//               [74:77] thdid &
//               [78:81] size &
//               [82:83] derat_miss/ierat_miss &
//               [84:85] tlbsx/tlbsrx &
//               [86:87] inval_snoop/tlbre &
//               [88:89] tlbwe/ptereload &
//               [90:97] lpid &
//               [98] indirect
//               [99] atsel &
//               [100:102] esel &
//               [103:105] hes/wq(0:1) &
//               [106:107] lrat/pt &
//               [108] record form
//               [109] endflag
`define   tagpos_epn        0
`define   tagpos_pid        52 // 14 bits
`define   tagpos_is         66
`define   tagpos_class      68
`define   tagpos_state      70 // state: 0:pr 1:gs 2:as 3:cm
`define   tagpos_thdid      74
`define   tagpos_size       78
`define   tagpos_type       82 // derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
`define   tagpos_lpid       90
`define   tagpos_ind        98
`define   tagpos_atsel      99
`define   tagpos_esel       100
`define   tagpos_hes        103
`define   tagpos_wq         104
`define   tagpos_lrat       106
`define   tagpos_pt         107
`define   tagpos_recform    108
`define   tagpos_endflag    109
`ifdef A2O
`define   tagpos_itag       110
`define   tagpos_nonspec    117
`define   tagpos_emq        118
`endif

// derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
`define   tagpos_type_derat       `tagpos_type
`define   tagpos_type_ierat       `tagpos_type+1
`define   tagpos_type_tlbsx       `tagpos_type+2
`define   tagpos_type_tlbsrx      `tagpos_type+3
`define   tagpos_type_snoop       `tagpos_type+4
`define   tagpos_type_tlbre       `tagpos_type+5
`define   tagpos_type_tlbwe       `tagpos_type+6
`define   tagpos_type_ptereload   `tagpos_type+7
// state: 0:pr 1:gs 2:as 3:cm
`define   tagpos_pr               `tagpos_state
`define   tagpos_gs               `tagpos_state+1
`define   tagpos_as               `tagpos_state+2
`define   tagpos_cm               `tagpos_state+3

`define   waypos_epn        0
`define   waypos_size       52
`define   waypos_thdid      56
`define   waypos_class      60
`define   waypos_extclass   62
`define   waypos_lpid       66
`define   waypos_xbit       84
`define   waypos_tstmode4k  85
`define   waypos_rpn        88
`define   waypos_rc         118
`define   waypos_wlc        120
`define   waypos_resvattr   122
`define   waypos_vf         123
`define   waypos_ind        124
`define   waypos_ubits      125
`define   waypos_wimge      129
`define   waypos_usxwr      134
`define   waypos_gs         140
`define   waypos_ts         141
`define   waypos_tid        144   // 14 bits

`define   eratpos_epn        0
`define   eratpos_x          52
`define   eratpos_size       53
`define   eratpos_v          56
`define   eratpos_thdid      57
`define   eratpos_class      61
`define   eratpos_extclass   63
`define   eratpos_wren       65
`define   eratpos_rpnrsvd    66
`define   eratpos_rpn        70
`define   eratpos_r          100
`define   eratpos_c          101
`define   eratpos_relsoon    102
`define   eratpos_wlc        103
`define   eratpos_resvattr   105
`define   eratpos_vf         106
`define   eratpos_ubits      107
`define   eratpos_wimge      111
`define   eratpos_usxwr      116
`define   eratpos_gs         122
`define   eratpos_ts         123
`define   eratpos_tid        124   // 8 bits

`define   ptepos_rpn        0
`define   ptepos_wimge      40
`define   ptepos_r          45
`define   ptepos_ubits      46
`define   ptepos_sw0        50
`define   ptepos_c          51
`define   ptepos_size       52
`define   ptepos_usxwr      56
`define   ptepos_sw1        62
`define   ptepos_valid      63


// Do NOT add any defines below this line
`endif  //_mmu_a2o_vh_
