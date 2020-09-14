// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.


`include "tri_a2o.vh"


module lq_spr_tspr
#(
   parameter              hvmode = 1,
   parameter              a2mode = 1
)(

   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)
   input [0:`NCLK_WIDTH-1] nclk,

   input                  d_mode_dc,
   input                  delay_lclkr_dc,
   input                  mpw1_dc_b,
   input                  mpw2_dc_b,
   input                  func_sl_force,
   input                  func_sl_thold_0_b,
   input                  sg_0,

   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                  scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                 scan_out,

   input                  slowspr_val_in,
   input                  slowspr_rw_in,
   input [0:9]            slowspr_addr_in,
   input [64-`GPR_WIDTH:63]  slowspr_data_in,

   output                 tspr_done,
   output [64-`GPR_WIDTH:63] tspr_rt,

   input                  cspr_tspr_msr_pr,
   input                  cspr_tspr_msr_gs,
   output [0:1]           tspr_cspr_dbcr2_dac1us,
   output [0:1]           tspr_cspr_dbcr2_dac1er,
   output [0:1]           tspr_cspr_dbcr2_dac2us,
   output [0:1]           tspr_cspr_dbcr2_dac2er,
   output [0:1]           tspr_cspr_dbcr3_dac3us,
   output [0:1]           tspr_cspr_dbcr3_dac3er,
   output [0:1]           tspr_cspr_dbcr3_dac4us,
   output [0:1]           tspr_cspr_dbcr3_dac4er,
   output                 tspr_cspr_dbcr2_dac12m,
   output                 tspr_cspr_dbcr3_dac34m,
   output [0:1]           tspr_cspr_dbcr2_dvc1m,
   output [0:1]           tspr_cspr_dbcr2_dvc2m,
   output [0:7]           tspr_cspr_dbcr2_dvc1be,
   output [0:7]           tspr_cspr_dbcr2_dvc2be,
   output                 spr_epsc_wr,
   output                 spr_eplc_wr,
	output [0:31]                       spr_acop_ct,
	output                              spr_dbcr3_ivc,
	output                              spr_dscr_lsd,
	output                              spr_dscr_snse,
	output                              spr_dscr_sse,
	output [0:2]                        spr_dscr_dpfd,
	output                              spr_eplc_epr,
	output                              spr_eplc_eas,
	output                              spr_eplc_egs,
	output [0:7]                        spr_eplc_elpid,
	output [0:13]                       spr_eplc_epid,
	output                              spr_epsc_epr,
	output                              spr_epsc_eas,
	output                              spr_epsc_egs,
	output [0:7]                        spr_epsc_elpid,
	output [0:13]                       spr_epsc_epid,
	output [0:31]                       spr_hacop_ct,

   inout                  vdd,
   inout                  gnd
);


wire                   eplc_we_d;
wire                   eplc_we_q;
wire                   epsc_we_d;
wire                   epsc_we_q;

	wire [32:63]                  acop_d,                   acop_q;                  
	wire [35:63]                  dbcr2_d,                  dbcr2_q;                 
	wire [54:63]                  dbcr3_d,                  dbcr3_q;                 
	wire [58:63]                  dscr_d,                   dscr_q;                  
	wire [39:63]                  eplc_d,                   eplc_q;                  
	wire [39:63]                  epsc_d,                   epsc_q;                  
	wire [32:63]                  hacop_d,                  hacop_q;                 
	localparam acop_offset                    = 0;
	localparam dbcr2_offset                   = acop_offset                    + 32*a2mode;
	localparam dbcr3_offset                   = dbcr2_offset                   + 29*a2mode;
	localparam dscr_offset                    = dbcr3_offset                   + 10;
	localparam eplc_offset                    = dscr_offset                    + 6;
	localparam epsc_offset                    = eplc_offset                    + 25*hvmode;
	localparam hacop_offset                   = epsc_offset                    + 25*hvmode;
	localparam last_reg_offset                = hacop_offset                   + 32*hvmode;
parameter              eplc_we_offset = last_reg_offset;
parameter              epsc_we_offset = eplc_we_offset + 1;
parameter              scan_right = epsc_we_offset + 1;
wire [0:scan_right-1]  siv;
wire [0:scan_right-1]  sov;
wire                   tiup;
wire [00:63]           tidn;
wire                   sspr_spr_we;
wire [11:20]           sspr_instr;
wire                   sspr_is_mtspr;
wire [64-`GPR_WIDTH:63]   sspr_spr_wd;
wire                   hyp_state;
	wire [0:1]                       spr_dbcr2_dac1us;
	wire [0:1]                       spr_dbcr2_dac1er;
	wire [0:1]                       spr_dbcr2_dac2us;
	wire [0:1]                       spr_dbcr2_dac2er;
	wire                             spr_dbcr2_dac12m;
	wire [0:1]                       spr_dbcr2_dvc1m;
	wire [0:1]                       spr_dbcr2_dvc2m;
	wire [0:7]                       spr_dbcr2_dvc1be;
	wire [0:7]                       spr_dbcr2_dvc2be;
	wire [0:1]                       spr_dbcr3_dac3us;
	wire [0:1]                       spr_dbcr3_dac3er;
	wire [0:1]                       spr_dbcr3_dac4us;
	wire [0:1]                       spr_dbcr3_dac4er;
	wire                             spr_dbcr3_dac34m;
	wire [32:63]                     sspr_acop_di;            
	wire [35:63]                     sspr_dbcr2_di;           
	wire [54:63]                     sspr_dbcr3_di;           
	wire [58:63]                     sspr_dscr_di;            
	wire [39:63]                     sspr_eplc_di;            
	wire [39:63]                     sspr_epsc_di;            
	wire [32:63]                     sspr_hacop_di;           
	wire 
		sspr_acop_rdec , sspr_dbcr2_rdec, sspr_dbcr3_rdec, sspr_dscr_rdec 
		, sspr_eplc_rdec , sspr_epsc_rdec , sspr_hacop_rdec;
	wire 
		sspr_acop_re   , sspr_dbcr2_re  , sspr_dbcr3_re  , sspr_dscr_re   
		, sspr_eplc_re   , sspr_epsc_re   , sspr_hacop_re  ;
	wire 
		sspr_acop_wdec , sspr_dbcr2_wdec, sspr_dbcr3_wdec, sspr_dscr_wdec 
		, sspr_eplc_wdec , sspr_epsc_wdec , sspr_hacop_wdec;
	wire 
		sspr_acop_we   , sspr_dbcr2_we  , sspr_dbcr3_we  , sspr_dscr_we   
		, sspr_eplc_we   , sspr_epsc_we   , sspr_hacop_we  ;
	wire 
		acop_act       , dbcr2_act      , dbcr3_act      , dscr_act       
		, eplc_act       , epsc_act       , hacop_act      ;
	wire [0:64]
		acop_do        , dbcr2_do       , dbcr3_do       , dscr_do        
		, eplc_do        , epsc_do        , hacop_do       ;


assign tiup = 1'b1;
assign tidn = {64{1'b0}};

assign sspr_is_mtspr = (~slowspr_rw_in);
assign sspr_instr = {slowspr_addr_in[5:9], slowspr_addr_in[0:4]};
assign sspr_spr_we = slowspr_val_in;
assign sspr_spr_wd = slowspr_data_in;

assign hyp_state = ~(cspr_tspr_msr_pr | cspr_tspr_msr_gs);

assign acop_act = sspr_acop_we;
assign acop_d = sspr_acop_di;

assign hacop_act = sspr_hacop_we;
assign hacop_d = sspr_hacop_di;

assign dbcr2_act = sspr_dbcr2_we;
assign dbcr2_d = sspr_dbcr2_di;

assign dbcr3_act = sspr_dbcr3_we;
assign dbcr3_d = sspr_dbcr3_di;

assign dscr_act = sspr_dscr_we;
assign dscr_d = sspr_dscr_di;

assign eplc_act = sspr_eplc_we;
assign eplc_we_d = sspr_eplc_we;
assign eplc_d[39:1 + 39] = sspr_eplc_di[39:1 + 39];
assign eplc_d[(2 + 39) + 9:63] = sspr_eplc_di[(2 + 39) + 9:63];

assign eplc_d[2 + 39:(2 + 39) + 8] = (hyp_state == 1'b1) ? sspr_eplc_di[2 + 39:(2 + 39) + 8] : 
                                     eplc_q[2 + 39:(2 + 39) + 8];

assign epsc_act = sspr_epsc_we;
assign epsc_we_d = sspr_epsc_we;
assign epsc_d[39:1 + 39] = sspr_epsc_di[39:1 + 39];
assign epsc_d[(2 + 39) + 9:63] = sspr_epsc_di[(2 + 39) + 9:63];

assign epsc_d[2 + 39:(2 + 39) + 8] = (hyp_state == 1'b1) ? sspr_epsc_di[2 + 39:(2 + 39) + 8] : 
                                     epsc_q[2 + 39:(2 + 39) + 8];

generate
   if (a2mode == 0 & hvmode == 0) begin : readmux_00
			assign tspr_rt =
			(dbcr3_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_dbcr3_re          }}) |
			(dscr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dscr_re           }});
   end
endgenerate
generate
   if (a2mode == 0 & hvmode == 1) begin : readmux_01
			assign tspr_rt =
			(dbcr3_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_dbcr3_re          }}) |
			(dscr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dscr_re           }}) |
			(eplc_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_eplc_re           }}) |
			(epsc_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_epsc_re           }}) |
			(hacop_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_hacop_re          }});
   end
endgenerate
generate
   if (a2mode == 1 & hvmode == 0) begin : readmux_10
			assign tspr_rt =
			(acop_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_acop_re           }}) |
			(dbcr2_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_dbcr2_re          }}) |
			(dbcr3_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_dbcr3_re          }}) |
			(dscr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dscr_re           }});
   end
endgenerate
generate
   if (a2mode == 1 & hvmode == 1) begin : readmux_11
			assign tspr_rt =
			(acop_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_acop_re           }}) |
			(dbcr2_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_dbcr2_re          }}) |
			(dbcr3_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_dbcr3_re          }}) |
			(dscr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_dscr_re           }}) |
			(eplc_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_eplc_re           }}) |
			(epsc_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{sspr_epsc_re           }}) |
			(hacop_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{sspr_hacop_re          }});
   end
endgenerate

	assign sspr_acop_rdec      = (sspr_instr[11:20] == 10'b1111100000);   
	assign sspr_dbcr2_rdec     = (sspr_instr[11:20] == 10'b1011001001);   
	assign sspr_dbcr3_rdec     = (sspr_instr[11:20] == 10'b1000011010);   
	assign sspr_dscr_rdec      = (sspr_instr[11:20] == 10'b1000100000);   
	assign sspr_eplc_rdec      = (sspr_instr[11:20] == 10'b1001111101);   
	assign sspr_epsc_rdec      = (sspr_instr[11:20] == 10'b1010011101);   
	assign sspr_hacop_rdec     = (sspr_instr[11:20] == 10'b1111101010);   
	assign sspr_acop_re        =  sspr_acop_rdec;
	assign sspr_dbcr2_re       =  sspr_dbcr2_rdec;
	assign sspr_dbcr3_re       =  sspr_dbcr3_rdec;
	assign sspr_dscr_re        =  sspr_dscr_rdec;
	assign sspr_eplc_re        =  sspr_eplc_rdec;
	assign sspr_epsc_re        =  sspr_epsc_rdec;
	assign sspr_hacop_re       =  sspr_hacop_rdec;

	assign sspr_acop_wdec      = sspr_acop_rdec;
	assign sspr_dbcr2_wdec     = sspr_dbcr2_rdec;
	assign sspr_dbcr3_wdec     = sspr_dbcr3_rdec;
	assign sspr_dscr_wdec      = sspr_dscr_rdec;
	assign sspr_eplc_wdec      = sspr_eplc_rdec;
	assign sspr_epsc_wdec      = sspr_epsc_rdec;
	assign sspr_hacop_wdec     = (sspr_instr[11:20] == 10'b1111101010);   
	assign sspr_acop_we       = sspr_spr_we & sspr_is_mtspr &  sspr_acop_wdec;
	assign sspr_dbcr2_we      = sspr_spr_we & sspr_is_mtspr &  sspr_dbcr2_wdec;
	assign sspr_dbcr3_we      = sspr_spr_we & sspr_is_mtspr &  sspr_dbcr3_wdec;
	assign sspr_dscr_we       = sspr_spr_we & sspr_is_mtspr &  sspr_dscr_wdec;
	assign sspr_eplc_we       = sspr_spr_we & sspr_is_mtspr &  sspr_eplc_wdec;
	assign sspr_epsc_we       = sspr_spr_we & sspr_is_mtspr &  sspr_epsc_wdec;
	assign sspr_hacop_we      = sspr_spr_we & sspr_is_mtspr &  sspr_hacop_wdec;

assign tspr_done = slowspr_val_in & (
                             sspr_acop_rdec       | sspr_dbcr2_rdec      | sspr_dbcr3_rdec      
                           | sspr_dscr_rdec       | sspr_eplc_rdec       | sspr_epsc_rdec       
                           | sspr_hacop_rdec      );

	assign spr_acop_ct                 = acop_q[32:63];
	assign spr_dbcr2_dac1us            = dbcr2_q[35:36];
	assign spr_dbcr2_dac1er            = dbcr2_q[37:38];
	assign spr_dbcr2_dac2us            = dbcr2_q[39:40];
	assign spr_dbcr2_dac2er            = dbcr2_q[41:42];
	assign spr_dbcr2_dac12m            = dbcr2_q[43];
	assign spr_dbcr2_dvc1m             = dbcr2_q[44:45];
	assign spr_dbcr2_dvc2m             = dbcr2_q[46:47];
	assign spr_dbcr2_dvc1be            = dbcr2_q[48:55];
	assign spr_dbcr2_dvc2be            = dbcr2_q[56:63];
	assign spr_dbcr3_dac3us            = dbcr3_q[54:55];
	assign spr_dbcr3_dac3er            = dbcr3_q[56:57];
	assign spr_dbcr3_dac4us            = dbcr3_q[58:59];
	assign spr_dbcr3_dac4er            = dbcr3_q[60:61];
	assign spr_dbcr3_dac34m            = dbcr3_q[62];
	assign spr_dbcr3_ivc               = dbcr3_q[63];
	assign spr_dscr_lsd                = dscr_q[58];
	assign spr_dscr_snse               = dscr_q[59];
	assign spr_dscr_sse                = dscr_q[60];
	assign spr_dscr_dpfd               = dscr_q[61:63];
	assign spr_eplc_epr                = eplc_q[39];
	assign spr_eplc_eas                = eplc_q[40];
	assign spr_eplc_egs                = eplc_q[41];
	assign spr_eplc_elpid              = eplc_q[42:49];
	assign spr_eplc_epid               = eplc_q[50:63];
	assign spr_epsc_epr                = epsc_q[39];
	assign spr_epsc_eas                = epsc_q[40];
	assign spr_epsc_egs                = epsc_q[41];
	assign spr_epsc_elpid              = epsc_q[42:49];
	assign spr_epsc_epid               = epsc_q[50:63];
	assign spr_hacop_ct                = hacop_q[32:63];
assign tspr_cspr_dbcr2_dac1us = spr_dbcr2_dac1us;
assign tspr_cspr_dbcr2_dac1er = spr_dbcr2_dac1er;
assign tspr_cspr_dbcr2_dac2us = spr_dbcr2_dac2us;
assign tspr_cspr_dbcr2_dac2er = spr_dbcr2_dac2er;
assign tspr_cspr_dbcr3_dac3us = spr_dbcr3_dac3us;
assign tspr_cspr_dbcr3_dac3er = spr_dbcr3_dac3er;
assign tspr_cspr_dbcr3_dac4us = spr_dbcr3_dac4us;
assign tspr_cspr_dbcr3_dac4er = spr_dbcr3_dac4er;
assign tspr_cspr_dbcr2_dac12m = spr_dbcr2_dac12m;
assign tspr_cspr_dbcr3_dac34m = spr_dbcr3_dac34m;
assign tspr_cspr_dbcr2_dvc1m = spr_dbcr2_dvc1m;
assign tspr_cspr_dbcr2_dvc2m = spr_dbcr2_dvc2m;
assign tspr_cspr_dbcr2_dvc1be = spr_dbcr2_dvc1be;
assign tspr_cspr_dbcr2_dvc2be = spr_dbcr2_dvc2be;
assign spr_epsc_wr = epsc_we_q;
assign spr_eplc_wr = eplc_we_q;


	assign sspr_acop_di    = { sspr_spr_wd[32:63]               }; 

	assign acop_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , 
                              acop_q[32:63]                    }; 
	assign sspr_dbcr2_di   = { sspr_spr_wd[32:33]               , 
                              sspr_spr_wd[34:35]               , 
                              sspr_spr_wd[36:37]               , 
                              sspr_spr_wd[38:39]               , 
                              sspr_spr_wd[41:41]               , 
                              sspr_spr_wd[44:45]               , 
                              sspr_spr_wd[46:47]               , 
                              sspr_spr_wd[48:55]               , 
                              sspr_spr_wd[56:63]               }; 

	assign dbcr2_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , 
                              dbcr2_q[35:36]                   , 
                              dbcr2_q[37:38]                   , 
                              dbcr2_q[39:40]                   , 
                              dbcr2_q[41:42]                   , 
                              tidn[40:40]                      , 
                              dbcr2_q[43:43]                   , 
                              tidn[42:43]                      , 
                              dbcr2_q[44:45]                   , 
                              dbcr2_q[46:47]                   , 
                              dbcr2_q[48:55]                   , 
                              dbcr2_q[56:63]                   }; 
	assign sspr_dbcr3_di   = { sspr_spr_wd[32:33]               , 
                              sspr_spr_wd[34:35]               , 
                              sspr_spr_wd[36:37]               , 
                              sspr_spr_wd[38:39]               , 
                              sspr_spr_wd[41:41]               , 
                              sspr_spr_wd[63:63]               }; 

	assign dbcr3_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , 
                              dbcr3_q[54:55]                   , 
                              dbcr3_q[56:57]                   , 
                              dbcr3_q[58:59]                   , 
                              dbcr3_q[60:61]                   , 
                              tidn[40:40]                      , 
                              dbcr3_q[62:62]                   , 
                              tidn[42:62]                      , 
                              dbcr3_q[63:63]                   }; 
	assign sspr_dscr_di    = { sspr_spr_wd[58:58]               , 
                              sspr_spr_wd[59:59]               , 
                              sspr_spr_wd[60:60]               , 
                              sspr_spr_wd[61:63]               }; 

	assign dscr_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , 
                              tidn[32:57]                      , 
                              dscr_q[58:58]                    , 
                              dscr_q[59:59]                    , 
                              dscr_q[60:60]                    , 
                              dscr_q[61:63]                    }; 
	assign sspr_eplc_di    = { sspr_spr_wd[32:32]               , 
                              sspr_spr_wd[33:33]               , 
                              sspr_spr_wd[34:34]               , 
                              sspr_spr_wd[40:47]               , 
                              sspr_spr_wd[50:63]               }; 

	assign eplc_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , 
                              eplc_q[39:39]                    , 
                              eplc_q[40:40]                    , 
                              eplc_q[41:41]                    , 
                              tidn[35:39]                      , 
                              eplc_q[42:49]                    , 
                              tidn[48:49]                      , 
                              eplc_q[50:63]                    }; 
	assign sspr_epsc_di    = { sspr_spr_wd[32:32]               , 
                              sspr_spr_wd[33:33]               , 
                              sspr_spr_wd[34:34]               , 
                              sspr_spr_wd[40:47]               , 
                              sspr_spr_wd[50:63]               }; 

	assign epsc_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , 
                              epsc_q[39:39]                    , 
                              epsc_q[40:40]                    , 
                              epsc_q[41:41]                    , 
                              tidn[35:39]                      , 
                              epsc_q[42:49]                    , 
                              tidn[48:49]                      , 
                              epsc_q[50:63]                    }; 
	assign sspr_hacop_di   = { sspr_spr_wd[32:63]               }; 

	assign hacop_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , 
                              hacop_q[32:63]                   }; 

	assign unused_do_bits = |{
		acop_do[0:64-`GPR_WIDTH]
		,dbcr2_do[0:64-`GPR_WIDTH]
		,dbcr3_do[0:64-`GPR_WIDTH]
		,dscr_do[0:64-`GPR_WIDTH]
		,eplc_do[0:64-`GPR_WIDTH]
		,epsc_do[0:64-`GPR_WIDTH]
		,hacop_do[0:64-`GPR_WIDTH]
		};

generate
	if (a2mode == 1) begin : acop_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) acop_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(acop_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[acop_offset:acop_offset + 32 - 1]),
        .scout(sov[acop_offset:acop_offset + 32 - 1]),
        .din(acop_d),
        .dout(acop_q)
     );
	end
	if (a2mode == 0) begin : acop_latch_tie
		assign acop_q          = {32{1'b0}};
	end
endgenerate
generate
	if (a2mode == 1) begin : dbcr2_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(29), .INIT(0), .NEEDS_SRESET(1)) dbcr2_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dbcr2_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[dbcr2_offset:dbcr2_offset + 29 - 1]),
        .scout(sov[dbcr2_offset:dbcr2_offset + 29 - 1]),
        .din(dbcr2_d),
        .dout(dbcr2_q)
     );
	end
	if (a2mode == 0) begin : dbcr2_latch_tie
		assign dbcr2_q         = {29{1'b0}};
	end
endgenerate
     tri_ser_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) dbcr3_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dbcr3_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[dbcr3_offset:dbcr3_offset + 10 - 1]),
        .scout(sov[dbcr3_offset:dbcr3_offset + 10 - 1]),
        .din(dbcr3_d),
        .dout(dbcr3_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(6), .INIT(32), .NEEDS_SRESET(1)) dscr_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dscr_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[dscr_offset:dscr_offset + 6 - 1]),
        .scout(sov[dscr_offset:dscr_offset + 6 - 1]),
        .din(dscr_d),
        .dout(dscr_q)
     );
generate
	if (hvmode == 1) begin : eplc_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(25), .INIT(0), .NEEDS_SRESET(1)) eplc_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(eplc_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[eplc_offset:eplc_offset + 25 - 1]),
        .scout(sov[eplc_offset:eplc_offset + 25 - 1]),
        .din(eplc_d),
        .dout(eplc_q)
     );
	end
	if (hvmode == 0) begin : eplc_latch_tie
		assign eplc_q          = {25{1'b0}};
	end
endgenerate
generate
	if (hvmode == 1) begin : epsc_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(25), .INIT(0), .NEEDS_SRESET(1)) epsc_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(epsc_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[epsc_offset:epsc_offset + 25 - 1]),
        .scout(sov[epsc_offset:epsc_offset + 25 - 1]),
        .din(epsc_d),
        .dout(epsc_q)
     );
	end
	if (hvmode == 0) begin : epsc_latch_tie
		assign epsc_q          = {25{1'b0}};
	end
endgenerate
generate
	if (hvmode == 1) begin : hacop_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) hacop_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(hacop_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc),
        .mpw1_b(mpw1_dc_b),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[hacop_offset:hacop_offset + 32 - 1]),
        .scout(sov[hacop_offset:hacop_offset + 32 - 1]),
        .din(hacop_d),
        .dout(hacop_q)
     );
	end
	if (hvmode == 0) begin : hacop_latch_tie
		assign hacop_q         = {32{1'b0}};
	end
endgenerate



tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) eplc_we_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[eplc_we_offset]),
   .scout(sov[eplc_we_offset]),
   .din(eplc_we_d),
   .dout(eplc_we_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) epsc_we_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[epsc_we_offset]),
   .scout(sov[epsc_we_offset]),
   .din(epsc_we_d),
   .dout(epsc_we_q)
);

assign siv[0:scan_right - 1] = {sov[1:scan_right - 1], scan_in};
assign scan_out = sov[0];
   
endmodule
