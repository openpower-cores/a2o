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
// *! FILENAME    : tri_scom_addr_decode.vhdl
// *! TITLE       :
// *! DESCRIPTION : Generic SCOM address decoder
// *!****************************************************************


module tri_scom_addr_decode(
   sc_addr,
   scaddr_dec,
   sc_req,
   sc_r_nw,
   scaddr_nvld,
   sc_wr_nvld,
   sc_rd_nvld,
   vd,
   gd
);

//=====================================================================
// I/O and Signal Declarations
//=====================================================================
   parameter				ADDR_SIZE      = 64;
   parameter				SATID_NOBITS   = 5; 	// should not be set by user

//  Set the USE_ADDR, ADDR_IS_RDABLE, ADDR_IS_WRABLE vectors to generate a SCOM address
//                                  	HEX  >>>>>          "0000000000000000111111111111111122222222222222223333333333333333"
//                                  	ADDR >>>>>          "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
//
//                                  	DEC  >>>>>          "0000000000111111111122222222223333333333444444444455555555556666"
//                                  	ADDR >>>>>          "0123456789012345678901234567890123456789012345678901234567890123"
   parameter [0:ADDR_SIZE-1]        	USE_ADDR       = 64'b1000000000000000000000000000000000000000000000000000000000000000;
   parameter [0:ADDR_SIZE-1]        	ADDR_IS_RDABLE = 64'b1000000000000000000000000000000000000000000000000000000000000000;
   parameter [0:ADDR_SIZE-1]        	ADDR_IS_WRABLE = 64'b1000000000000000000000000000000000000000000000000000000000000000;

   input  [0:11-SATID_NOBITS-1]		sc_addr;	// binary coded scom address
   output [0:ADDR_SIZE-1]      		scaddr_dec;	// one hot coded scom address; not latched

   input                       		sc_req;		// scom request
   input                       		sc_r_nw;	// read / not write bit
   output                      		scaddr_nvld;	// scom address not valid; not latched
   output                      		sc_wr_nvld;	// scom write not allowed; not latched
   output                      		sc_rd_nvld;	// scom read  not allowed; not latched

   inout                       		vd;
   inout                       		gd;



//=====================================================================
   wire   [0:ADDR_SIZE-1]       	address;


// Don't reference unused inputs:
(* analysis_not_referenced="true" *)
   wire                   		unused;
   assign unused = vd | gd;


//=====================================================================
   generate
     begin : decode_it
	 genvar    i;
	 for (i=0; i<ADDR_SIZE; i=i+1)
	 begin : decode_it
            assign address[i] = ({{32-SATID_NOBITS{1'b0}},sc_addr} == i) & USE_ADDR[i];
    	 end
     end
   endgenerate

      assign scaddr_dec  = address;
      assign scaddr_nvld = sc_req & (~|address);
      assign sc_wr_nvld  = (~(|(address & ADDR_IS_WRABLE)) & sc_req & (~sc_r_nw));
      assign sc_rd_nvld  = (~(|(address & ADDR_IS_RDABLE)) & sc_req &   sc_r_nw );

endmodule
