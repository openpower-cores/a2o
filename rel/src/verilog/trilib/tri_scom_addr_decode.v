// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

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
