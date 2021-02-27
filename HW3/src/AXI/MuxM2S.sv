`include "AXI_define.svh"
`define IDLE              4'b0000
`define ReadAddr_M1       4'b0001
`define ReadData_M1S0     4'b0010
`define ReadData_M1S1     4'b0011
`define ReadAddr_M0       4'b0100
`define ReadData_M0S0     4'b0101
`define ReadData_M0S1     4'b0110
`define WriteAddr_M1      4'b0111
`define WriteData_M1S0    4'b1000
`define WriteData_M1S1    4'b1001
`define WriteResp_S0M1    4'b1010
`define WriteResp_S1M1    4'b1011
`define WriteAddr_M0      4'b1100
`define Default_Slave     4'b1101
`define Write_Addr_Data_M1S0 4'b1110
`define Write_Addr_Data_M1S1 4'b1111

module MuxM2S(
    input ACLK,ARESETn,
	input [3:0]CS_R,
	input [3:0]CS_W, 
	input [3:0]NS_R,
	input [3:0]NS_W,              
    //----AW----//
	input [`AXI_ID_BITS-1:0]   AWID_M0   ,  
	input [`AXI_ADDR_BITS-1:0] AWADDR_M0 ,
	input [`AXI_LEN_BITS-1:0]  AWLEN_M0  , 
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M0 ,
	input [1:0]                AWBURST_M0,
	input                      AWVALID_M0,  
	input [`AXI_ID_BITS-1:0]   AWID_M1   ,  
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1 ,
	input [`AXI_LEN_BITS-1:0]  AWLEN_M1  , 
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1 ,
	input [1:0]                AWBURST_M1,
	input                      AWVALID_M1,  
    //----W----//
	input [`AXI_DATA_BITS-1:0] WDATA_M0  ,  
	input [`AXI_STRB_BITS-1:0] WSTRB_M0  ,  
	input                      WLAST_M0  ,
	input                      WVALID_M0 ,		
	input [`AXI_DATA_BITS-1:0] WDATA_M1  ,  
	input [`AXI_STRB_BITS-1:0] WSTRB_M1  ,  
	input                      WLAST_M1  ,
	input                      WVALID_M1  ,	
    //----AR----//   	
	input [`AXI_ID_BITS-1:0]   ARID_M0   ,     
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0 , 
	input [`AXI_LEN_BITS-1:0]  ARLEN_M0  ,   
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0 , 
	input [1:0]                ARBURST_M0,
	input                      ARVALID_M0,	
	input [`AXI_ID_BITS-1:0]   ARID_M1   ,     
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1 , 
	input [`AXI_LEN_BITS-1:0]  ARLEN_M1  ,   
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1 , 
	input [1:0]                ARBURST_M1,
	input                      ARVALID_M1,
    //----RREADY/BREADY----//
    input RREADY_M0,
	input RREADY_M1,
    input BREADY_M0,
	input BREADY_M1,
    input ARREADY,
    input AWREADY,
	//-----------output-----------//
	//----AW----//
	output logic[`AXI_ID_BITS-1:0]   AWID   ,  
	output logic[`AXI_ADDR_BITS-1:0] AWADDR ,
	output logic[`AXI_LEN_BITS-1:0]  AWLEN  , 
	output logic[`AXI_SIZE_BITS-1:0] AWSIZE ,
	output logic[1:0]                AWBURST,
	output logic                     AWVALID, 	
    //----W----//
	output logic[`AXI_DATA_BITS-1:0] WDATA   ,  
	output logic[`AXI_STRB_BITS-1:0] WSTRB   ,  
	output logic                     WLAST   ,
	output logic                     WVALID  ,	
    //----AR----//   	
	output logic[`AXI_ID_BITS-1:0]   ARID    ,     
	output logic[`AXI_ADDR_BITS-1:0] ARADDR  , 
	output logic[`AXI_LEN_BITS-1:0]  ARLEN   ,   
	output logic[`AXI_SIZE_BITS-1:0] ARSIZE  , 
	output logic[1:0]                ARBURST ,
	output logic                     ARVALID ,
	output logic RREADY,
    output logic BREADY	
);
//----AW----//
always_comb
begin
		  case(CS_W)
		    `WriteAddr_M0:begin
				  AWID      =    AWID_M0     ;
				  AWADDR    =    AWADDR_M0   ;
				  AWLEN     =    AWLEN_M0    ;
				  AWSIZE    =    AWSIZE_M0   ;
				  AWBURST   =    AWBURST_M0  ;
				  AWVALID   =    AWVALID_M0  ;

			end
			`WriteAddr_M1:begin
				  AWID      =    AWID_M1     ;
				  AWADDR    =    AWADDR_M1   ;
				  AWLEN     =    AWLEN_M1    ;
				  AWSIZE    =    AWSIZE_M1   ;
				  AWBURST   =    AWBURST_M1  ;
				  AWVALID   =    AWVALID_M1  ;	
			end
                  `Write_Addr_Data_M1S0 :begin
				  AWID      =    AWID_M1     ;
				  AWADDR    =    AWADDR_M1   ;
				  AWLEN     =    AWLEN_M1    ;
				  AWSIZE    =    AWSIZE_M1   ;
				  AWBURST   =    AWBURST_M1  ;
				  AWVALID   =    AWVALID_M1  ;
                  end
                  `Write_Addr_Data_M1S1 :begin
				  AWID      =    AWID_M1     ;
				  AWADDR    =    AWADDR_M1   ;
				  AWLEN     =    AWLEN_M1    ;
				  AWSIZE    =    AWSIZE_M1   ;
				  AWBURST   =    AWBURST_M1  ;
				  AWVALID   =    AWVALID_M1  ;
                  end
			/*
			`WriteData_M1S0 || `WriteData_M1S1:begin
				  AWID      <=    AWID     ;
				  AWADDR    <=    AWADDR   ;
				  AWLEN     <=    AWLEN    ;
				  AWSIZE    <=    AWSIZE   ;
				  AWBURST   <=    AWBURST  ;
				  AWVALID   <=    AWVALID  ;					
			end
			*/
			default:begin
			  AWID      =    4'd0            ;
			  AWADDR    =    32'd0           ;
			  AWLEN     =    4'd0            ;
			  AWSIZE    =    3'd0            ;
			  AWBURST   =    2'd0            ;
			  AWVALID   =    1'd0            ;	  
			end
		  endcase

end

//----W----//
always_comb
begin
		  case(CS_W)
		    `WriteData_M1S0 :begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
                          //if(!WLAST)
			  WVALID   =  WVALID_M1      ;
                         // else 
			  //WVALID   =  0      ;                           
			end
		    `WriteData_M1S1:begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
                         // if(!WLAST)
			  WVALID   =  WVALID_M1      ;
                          //else 
			 // WVALID   =  0      ;                           
			end
		    `Write_Addr_Data_M1S0:begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
                         // if(!WLAST)
			  WVALID   =  WVALID_M1      ;
                          //else 
			 // WVALID   =  0      ;                           
			end
		    `Write_Addr_Data_M1S1:begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
                         // if(!WLAST)
			  WVALID   =  WVALID_M1      ;
                          //else 
			 // WVALID   =  0      ;                           
			end

			
			default:begin
			  WDATA    =  32'd0             ;
			  WSTRB    =  4'hf              ;
			  WLAST    =  1'd0              ;
			  WVALID   =  1'd0              ;
			end
		  endcase
end

//----AR----//
always_comb
begin	 
		  case(CS_R)
		    `ReadAddr_M0:begin 
			  ARID     =  ARID_M0         ;
			  ARADDR   =  ARADDR_M0       ;
			  ARLEN    =  ARLEN_M0        ;
			  ARSIZE   =  ARSIZE_M0       ;
			  ARBURST  =  ARBURST_M0      ;
			  ARVALID  =  ARVALID_M0      ;
			  end
			`ReadAddr_M1:begin
			  ARID     =  ARID_M1         ;
			  ARADDR   =  ARADDR_M1       ;
			  ARLEN    =  ARLEN_M1        ;
			  ARSIZE   =  ARSIZE_M1       ;
			  ARBURST  =  ARBURST_M1      ;
			  ARVALID  =  ARVALID_M1      ;
			  end			  
			default:begin
			  ARID     =  4'd0               ;
			  ARADDR   =  32'd0              ;
			  ARLEN    =  4'd0               ;
			  ARSIZE   =  3'd0               ;
			  ARBURST  =  2'd0               ;
			  ARVALID  =  1'd0               ;
			end
		  endcase
end


//----RREADY----//
always_comb
begin
  case(CS_R)
    `ReadData_M0S0 :begin                  
      RREADY = RREADY_M0 ;
	end
    `ReadData_M0S1:begin                  
      RREADY = RREADY_M0 ;
	end	
	`ReadData_M1S0 :begin
      RREADY = RREADY_M1 ;
	end
	`ReadData_M1S1:begin
      RREADY = RREADY_M1 ;
	end	
	default:begin
      RREADY = 1'd0 ;
	end
  endcase
end

//----BREADY----//
always_comb
begin
  case(CS_W)
    `WriteResp_S0M1:begin                  
      BREADY = BREADY_M1 ;
	end
    `WriteResp_S1M1:begin                  
      BREADY = BREADY_M1 ;
	end	
	default:begin
      BREADY = 1'd0 ;
	end
  endcase
end
endmodule



















