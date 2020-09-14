// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.






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
   
   parameter				ADDR_SIZE      = 64;
   parameter				SATID_NOBITS   = 5; 	

   parameter [0:ADDR_SIZE-1]        	USE_ADDR       = 64'b1000000000000000000000000000000000000000000000000000000000000000;
   parameter [0:ADDR_SIZE-1]        	ADDR_IS_RDABLE = 64'b1000000000000000000000000000000000000000000000000000000000000000;
   parameter [0:ADDR_SIZE-1]        	ADDR_IS_WRABLE = 64'b1000000000000000000000000000000000000000000000000000000000000000;

   input  [0:11-SATID_NOBITS-1]		sc_addr;	
   output [0:ADDR_SIZE-1]      		scaddr_dec;	
   
   input                       		sc_req;		
   input                       		sc_r_nw;	
   output                      		scaddr_nvld;	
   output                      		sc_wr_nvld;	
   output                      		sc_rd_nvld;	
 
   inout                       		vd;
   inout                       		gd;



   wire   [0:ADDR_SIZE-1]       	address;
  

(* analysis_not_referenced="true" *)  
   wire                   		unused;
   assign unused = vd | gd;


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


