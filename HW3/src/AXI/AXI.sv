//================================================
// Auther:      Chang Wan-Yun (Claire)            
// Filename:    AXI.sv                            
// Description: Top module of AXI                  
// Version:     1.0 
//================================================
`include "AXI_define.svh"
`include "Arbiter.sv"
`include "DecoderM2S.sv"
`include "DecoderS2M.sv"
`include "MuxS2M.sv"
`include "MuxM2S.sv"
`include "DefaultSlave.sv"

module AXI(

	input ACLK,
	input ARESETn,

	//SLAVE INTERFACE FOR MASTERS////////////////////////////////
	//WRITE ADDRESS1 
	input [`AXI_ID_BITS-1:0]   AWID_M1,  
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0]  AWLEN_M1, 
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0]                AWBURST_M1,
	input                      AWVALID_M1,
	output AWREADY_M1,
	//WRITE DATA1 
	input [`AXI_DATA_BITS-1:0] WDATA_M1,  
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,  
	input                      WLAST_M1,
	input                      WVALID_M1,
	output WREADY_M1,
	//WRITE RESPONSE1
	output [`AXI_ID_BITS-1:0] BID_M1,     
	output [1:0] BRESP_M1,
	output BVALID_M1,
	input BREADY_M1,

	//READ ADDRESS0 
	input [`AXI_ID_BITS-1:0]   ARID_M0,     
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0, 
	input [`AXI_LEN_BITS-1:0]  ARLEN_M0,   
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0, 
	input [1:0]                ARBURST_M0,
	input                      ARVALID_M0,
	output ARREADY_M0,
	//READ DATA0
	output [`AXI_ID_BITS-1:0] RID_M0,
	output [`AXI_DATA_BITS-1:0] RDATA_M0,
	output [1:0] RRESP_M0,
	output RLAST_M0,
	output RVALID_M0,
	input RREADY_M0,
	//READ ADDRESS1 
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output ARREADY_M1,
	//READ DATA1 
	output [`AXI_ID_BITS-1:0] RID_M1,
	output [`AXI_DATA_BITS-1:0] RDATA_M1,
	output [1:0] RRESP_M1,
	output RLAST_M1,
	output RVALID_M1,
	input RREADY_M1,

	//MASTER INTERFACE FOR SLAVES ///////////////////////////
	//WRITE ADDRESS0
	output [`AXI_IDS_BITS-1:0]  AWID_S0,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output [`AXI_LEN_BITS-1:0]  AWLEN_S0,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output [1:0]                AWBURST_S0,
	output                      AWVALID_S0,
	input                       AWREADY_S0,
	//WRITE DATA0
	output [`AXI_DATA_BITS-1:0] WDATA_S0,
	output [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output                      WLAST_S0,
	output                      WVALID_S0,
	input  WREADY_S0,
	//WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output BREADY_S0,
	
	//WRITE ADDRESS1
	output [`AXI_IDS_BITS-1:0] AWID_S1,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output [1:0] AWBURST_S1,
	output AWVALID_S1,
	input AWREADY_S1,
	//WRITE DATA1
	output [`AXI_DATA_BITS-1:0] WDATA_S1,
	output [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output WLAST_S1,
	output WVALID_S1,
	input WREADY_S1,
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output BREADY_S1,
	
	//READ ADDRESS0
	output [`AXI_IDS_BITS-1:0]  ARID_S0,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output [`AXI_LEN_BITS-1:0]  ARLEN_S0,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output [1:0]                ARBURST_S0,
	output                      ARVALID_S0,
	input ARREADY_S0,
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output RREADY_S0,
	//READ ADDRESS1
	output [`AXI_IDS_BITS-1:0] ARID_S1,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output [1:0] ARBURST_S1,
	output ARVALID_S1,
	input ARREADY_S1,
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output RREADY_S1
	
);
    //---------- you should put your design here ----------//
logic [3:0]CS_R,CS_W,NS_R,NS_W;

logic[`AXI_ID_BITS-1:0]   AWID    ;
logic[`AXI_ADDR_BITS-1:0] AWADDR  ;
logic[`AXI_LEN_BITS-1:0]  AWLEN   ;
logic[`AXI_SIZE_BITS-1:0] AWSIZE  ;
logic[1:0]                AWBURST ;
logic                     AWVALID ;
								  
logic[`AXI_DATA_BITS-1:0] WDATA   ;
logic[`AXI_STRB_BITS-1:0] WSTRB   ;
logic                     WLAST   ;
logic                     WVALID  ;
								  
logic[`AXI_ID_BITS-1:0]   ARID    ;
logic[`AXI_ADDR_BITS-1:0] ARADDR  ;
logic[`AXI_LEN_BITS-1:0]  ARLEN   ;
logic[`AXI_SIZE_BITS-1:0] ARSIZE  ;
logic[1:0]                ARBURST ;
logic                     ARVALID ;
logic                     RREADY  ;
logic                     BREADY  ;

logic[`AXI_IDS_BITS-1:0]  RID    ;
logic[`AXI_DATA_BITS-1:0] RDATA  ;
logic[1:0]                RRESP  ;
logic                     RLAST  ;
logic                     RVALID ;
logic[`AXI_IDS_BITS-1:0]  BID    ;
logic[1:0]                BRESP  ;
logic                     BVALID ;
logic                     AWREADY;
logic                     WREADY ;
logic                     ARREADY;

logic [2:0]AWsel_slave,ARsel_slave;
logic [2:0]AWsel_slave_delay1,ARsel_slave_delay1;
logic [1:0] RRESP_default,BRESP_default;

logic [`AXI_ID_BITS-1:0] BID_M0;
logic [1:0] BRESP_M0;



Arbiter arbiter (
//input
.ACLK        (ACLK      ),
.ARESETn     (ARESETn   ),
             
.AWVALID_M0  (1'd0),	
.ARVALID_M0  (ARVALID_M0),
.ARREADY_M0  (ARREADY_M0),
            
.AWVALID_M1  (AWVALID_M1),
.AWREADY_M1  (AWREADY_M1),
.WVALID_M1   (WVALID_M1 ),
.WREADY_M1   (WREADY_M1 ),
.BVALID_M1   (BVALID_M1 ),
.BREADY_M1   (BREADY_M1 ),
.ARVALID_M1  (ARVALID_M1),
.ARREADY_M1  (ARREADY_M1),	

.AWADDR_M1(AWADDR_M1),
.ARADDR_M0(ARADDR_M0),
.ARADDR_M1(ARADDR_M1),

.RVALID_M0(RVALID_M0),
.RVALID_M1(RVALID_M1),
.RREADY_M0(RREADY_M0),	
.RREADY_M1(RREADY_M1),
.WLAST_M1(WLAST_M1),


	          	
.CS_R        (CS_R      ),
.CS_W        (CS_W      ),
.NS_R        (NS_R      ),
.NS_W        (NS_W      )

);	

	
MuxM2S muxM2S(
//input
.ACLK               (ACLK)            ,
.ARESETn            (ARESETn)         ,
.CS_R        (CS_R      ),
.CS_W        (CS_W      ),
.NS_R(NS_R),
.NS_W(NS_W),  
								  
.AWID_M0          (`AXI_ID_BITS'd0)       ,
.AWADDR_M0        (`AXI_ADDR_BITS'd0)     ,
.AWLEN_M0         (`AXI_LEN_BITS'd0)      ,
.AWSIZE_M0        (`AXI_SIZE_BITS'd0)     ,
.AWBURST_M0       (2'd0)    ,
.AWVALID_M0       (1'd0)    ,
.AWID_M1          (AWID_M1)       ,
.AWADDR_M1        (AWADDR_M1)     ,
.AWLEN_M1         (AWLEN_M1)      ,
.AWSIZE_M1        (AWSIZE_M1)     ,
.AWBURST_M1       (AWBURST_M1)    ,
.AWVALID_M1       (AWVALID_M1)    ,
								  
.WDATA_M0         (`AXI_DATA_BITS'd0)   ,
.WSTRB_M0         (`AXI_STRB_BITS'd0)   ,// 0000 ffff ?
.WLAST_M0         (1'd0)     ,
.WVALID_M0        (1'd0)     ,
.WDATA_M1         (WDATA_M1)      ,
.WSTRB_M1         (WSTRB_M1)      ,
.WLAST_M1 	      (WLAST_M1)      ,
.WVALID_M1	      (WVALID_M1)     ,
								  
.ARID_M0   	      (ARID_M0)       ,
.ARADDR_M0 	      (ARADDR_M0)     ,
.ARLEN_M0  	      (ARLEN_M0)      ,
.ARSIZE_M0 	      (ARSIZE_M0 )    ,
.ARBURST_M0	      (ARBURST_M0)    ,
.ARVALID_M0	      (ARVALID_M0)    ,
.ARID_M1   	      (ARID_M1   )    ,
.ARADDR_M1 	      (ARADDR_M1 )    ,
.ARLEN_M1  	      (ARLEN_M1  )    ,
.ARSIZE_M1 	      (ARSIZE_M1 )    ,
.ARBURST_M1	      (ARBURST_M1)    ,
.ARVALID_M1		  (ARVALID_M1)    ,

.RREADY_M0        (RREADY_M0)     ,
.RREADY_M1        (RREADY_M1)     ,
.BREADY_M0        (1'd0)          ,
.BREADY_M1        (BREADY_M1)     ,
.ARREADY(ARREADY),
.AWREADY(AWREADY),
//output	                      
.AWID             (AWID   )       ,
.AWADDR           (AWADDR )       ,
.AWLEN            (AWLEN  )       ,
.AWSIZE           (AWSIZE )       ,
.AWBURST          (AWBURST)       ,
.AWVALID          (AWVALID)       ,
								  
.WDATA            (WDATA  )       ,
.WSTRB            (WSTRB  )       ,
.WLAST            (WLAST  )       ,
.WVALID           (WVALID )       ,
								  
.ARID             (ARID    )      ,
.ARADDR           (ARADDR  )      ,
.ARLEN            (ARLEN   )      ,
.ARSIZE           (ARSIZE  )      ,
.ARBURST          (ARBURST )      ,
.ARVALID          (ARVALID )      ,

.RREADY           (RREADY )       ,
.BREADY           (BREADY )
);		

/*
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) begin
	    AWID_stay <= 0;
	    AWADDR_stay <= 0;
	    AWLEN_stay <= 0;
	    AWSIZE_stay <= 0;
	    AWBURST_stay <= 0;
	    AWVALID_stay <= 0;
  end
  else begin
    if(AWVALID)begin
	     AWID_stay <= AWID_stay;
	     AWADDR_stay <= AWADDR_stay;
	     AWLEN_stay <= AWLEN_stay;
	     AWSIZE_stay <= AWSIZE_stay;
	     AWBURST_stay <= AWBURST_stay;
	     AWVALID_stay <= AWVALID_stay;      
    end
    else begin
	     AWID_stay <= AWID;
	     AWADDR_stay <= AWADDR;
	     AWLEN_stay <= AWLEN;
	     AWSIZE_stay <= AWSIZE;
	     AWBURST_stay <= AWBURST;
	     AWVALID_stay <= AWVALID;        
    end

  end
end

logic [1:0]cs,ns;
logic WVALID_in,WREADY_in;

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) cs<=0;
  else cs<=ns; 
end

always_comb
begin
  case(cs)
    2'b00:begin
       if(AWVALID && AWREADY) ns=2'b01;
    end
    2'b01:begin
       if(WVALID && WREADY) ns=2'b10;
    end
    2'b10:begin
      if(BVALID && BREADY) ns=2'b00;
    end  
    2'b11:begin
      ns=2'b00;
    end  
  endcase
end

always_comb
begin
  if(cs==2'b01)begin
    WVALID_in=WVALID;
    WREADY_in=WREADY;
  end
  else begin
    WVALID_in=0;
    WREADY_in=0;
  end
end

*/





DecoderM2S decoderM2S(
//input 
.ACLK               (ACLK)            ,
.ARESETn            (ARESETn)         ,
.CS_R        (CS_R      ),
.CS_W        (CS_W      ),
.NS_R(NS_R),
.NS_W(NS_W),
.AWID                       (AWID   )     ,
.AWADDR                     (AWADDR )     ,
.AWLEN                      (AWLEN  )     ,
.AWSIZE                     (AWSIZE )     ,
.AWBURST                    (AWBURST)     ,
.AWVALID                    (AWVALID)     ,
.WDATA                      (WDATA  )     ,
.WSTRB                      (WSTRB  )     ,
.WLAST                      (WLAST  )     ,
.WVALID                     (WVALID/*_in*/ )     ,
.ARID                       (ARID   )     ,
.ARADDR                     (ARADDR )     ,
.ARLEN                      (ARLEN  )     ,
.ARSIZE                     (ARSIZE )     ,
.ARBURST                    (ARBURST)     ,
.ARVALID                    (ARVALID)     ,
.RREADY                     (RREADY )     ,
.BREADY                     (BREADY )     ,
//output                                 
.AWID_S0                    (AWID_S0   )  ,
.AWADDR_S0                  (AWADDR_S0 )  ,
.AWLEN_S0                   (AWLEN_S0  )  ,
.AWSIZE_S0                  (AWSIZE_S0 )  ,
.AWBURST_S0                 (AWBURST_S0)  ,
.AWVALID_S0                 (AWVALID_S0)  ,
.AWID_S1                    (AWID_S1   )  ,
.AWADDR_S1                  (AWADDR_S1 )  ,
.AWLEN_S1                   (AWLEN_S1  )  ,
.AWSIZE_S1                  (AWSIZE_S1 )  ,
.AWBURST_S1                 (AWBURST_S1)  ,
.AWVALID_S1                 (AWVALID_S1)  ,
										 
.WDATA_S0                   (WDATA_S0 )   ,
.WSTRB_S0                   (WSTRB_S0 )   ,
.WLAST_S0                   (WLAST_S0 )   ,
.WVALID_S0                  (WVALID_S0)   ,
.WDATA_S1                   (WDATA_S1 )   ,
.WSTRB_S1                   (WSTRB_S1 )   ,
.WLAST_S1                   (WLAST_S1 )   ,
.WVALID_S1                  (WVALID_S1)   ,
										 
.ARID_S0                    (ARID_S0   )  ,
.ARADDR_S0                  (ARADDR_S0 )  ,
.ARLEN_S0                   (ARLEN_S0  )  ,
.ARSIZE_S0                  (ARSIZE_S0 )  ,
.ARBURST_S0                 (ARBURST_S0)  ,
.ARVALID_S0                 (ARVALID_S0)  ,
.ARID_S1                    (ARID_S1   )  ,
.ARADDR_S1                  (ARADDR_S1 )  ,
.ARLEN_S1                   (ARLEN_S1  )  ,
.ARSIZE_S1                  (ARSIZE_S1 )  ,
.ARBURST_S1	               (ARBURST_S1)  ,
.ARVALID_S1	               (ARVALID_S1)  ,

.RREADY_S0                  (RREADY_S0) ,
.BREADY_S0                  (BREADY_S0) ,
.RREADY_S1                  (RREADY_S1) ,
.BREADY_S1                  (BREADY_S1) 
);	







MuxS2M muxS2M (
//input 
.ACLK               (ACLK)            ,
.ARESETn            (ARESETn)         ,
.CS_R        (CS_R      ),
.CS_W        (CS_W      ),
.NS_R(NS_R),
.NS_W(NS_W),
.RID_S0           (RID_S0   )      ,
.RDATA_S0         (RDATA_S0 )      ,
.RRESP_S0         (RRESP_S0 )      ,
.RLAST_S0         (RLAST_S0 )      ,
.RVALID_S0        (RVALID_S0)      ,
.RID_S1           (RID_S1   )      ,
.RDATA_S1         (RDATA_S1 )      ,
.RRESP_S1         (RRESP_S1 )      ,
.RLAST_S1         (RLAST_S1 )      ,
.RVALID_S1        (RVALID_S1)      ,
.BID_S0           (BID_S0   )      ,
.BRESP_S0         (BRESP_S0 )      ,
.BVALID_S0        (BVALID_S0)      ,
.BID_S1           (BID_S1   )      ,
.BRESP_S1         (BRESP_S1 )      ,
.BVALID_S1        (BVALID_S1)      ,
.AWREADY_S0       (AWREADY_S0)     ,
.AWREADY_S1       (AWREADY_S1)     ,
.ARREADY_S0       (ARREADY_S0)     ,
.ARREADY_S1       (ARREADY_S1)     ,
.WREADY_S0        (WREADY_S0 )     ,
.WREADY_S1        (WREADY_S1 )     ,
.RRESP_default    (RRESP_default)  ,
.BRESP_default    (BRESP_default)  ,
.ARVALID(ARVALID),
.ARADDR_M0(ARADDR_M0),
.AWADDR_M1(AWADDR_M1),
.ARADDR_M1(ARADDR_M1),
//output                           
.RID              (RID    )        ,
.RDATA            (RDATA  )        ,
.RRESP            (RRESP  )        ,
.RLAST            (RLAST  )        ,
.RVALID           (RVALID )        ,
.BID              (BID    )        ,
.BRESP            (BRESP  )        ,
.BVALID           (BVALID )        ,
.AWREADY          (AWREADY)        ,
.WREADY           (WREADY)         ,
.ARREADY          (ARREADY)        
);	                               

DecoderS2M decoderS2M (
//input
.ACLK               (ACLK)            ,
.ARESETn            (ARESETn)         ,
.CS_R        (CS_R      ),
.CS_W        (CS_W      ),
.NS_R(NS_R),
.NS_W(NS_W),
.RID         (RID   )     ,
.RDATA       (RDATA )     ,
.RRESP       (RRESP )     ,
.RLAST       (RLAST )     ,
.RVALID      (RVALID)     ,
.BID         (BID   )     ,
.BRESP       (BRESP )     ,
.BVALID      (BVALID)     ,
.AWREADY     (AWREADY)    ,
.WREADY      (WREADY)    ,
.ARREADY     (ARREADY)    ,
//output     
.RID_M0      (RID_M0   )  ,
.RDATA_M0    (RDATA_M0 )  ,
.RRESP_M0    (RRESP_M0 )  ,
.RLAST_M0    (RLAST_M0 )  ,
.RVALID_M0   (RVALID_M0)  ,
.RID_M1      (RID_M1   )  ,
.RDATA_M1    (RDATA_M1 )  ,
.RRESP_M1    (RRESP_M1 )  ,
.RLAST_M1    (RLAST_M1 )  ,
.RVALID_M1   (RVALID_M1)  ,
.BID_M0      (BID_M0   )  ,
.BRESP_M0    (BRESP_M0 )  ,
.BVALID_M0   (BVALID_M0)  ,
.BID_M1      (BID_M1   )  ,
.BRESP_M1    (BRESP_M1 )  ,
.BVALID_M1   (BVALID_M1)  ,
.AWREADY_M0  (AWREADY_M0) ,
.WREADY_M0   (WREADY_M0 ) ,
.ARREADY_M0  (ARREADY_M0) ,
.AWREADY_M1  (AWREADY_M1) ,
.WREADY_M1   (WREADY_M1 ) ,
.ARREADY_M1  (ARREADY_M1) 
);	


DefaultSlave defaultSlave (
//input
.ACLK            (ACLK       )    ,
.ARESETn         (ARESETn    )    ,
.CS_R        (CS_R      ),
.CS_W        (CS_W      ),
.NS_R(NS_R),
.NS_W(NS_W),
//output                          
.RRESP_default   (RRESP_default)  ,
.BRESP_default   (BRESP_default)  
);	
	
	

endmodule
