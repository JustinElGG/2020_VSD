`include "AXI_define.svh"


module MuxM2S(
    input ACLK,ARESETn,
	input [4:0]CS_R,
	input [4:0]CS_W, 
	input [4:0]NS_R,
	input [4:0]NS_W,              
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
	output logic[`AXI_ID_BITS-1:0]   AWID    ,  
	output logic[`AXI_ADDR_BITS-1:0] AWADDR  ,
	output logic[`AXI_LEN_BITS-1:0]  AWLEN   , 
	output logic[`AXI_SIZE_BITS-1:0] AWSIZE  ,
	output logic[1:0]                AWBURST ,
	output logic                     AWVALID , 	
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

parameter IDLE                 =5'd0;

parameter ReadAddr_M1          =5'd1;
parameter ReadData_M1S0        =5'd2;
parameter ReadData_M1S1        =5'd3;
parameter ReadData_M1S2        =5'd4;
parameter ReadData_M1S3        =5'd5;
parameter ReadData_M1S4        =5'd6;

parameter ReadAddr_M0          =5'd7;
parameter ReadData_M0S0        =5'd8;
parameter ReadData_M0S1        =5'd9;
parameter ReadData_M0S2        =5'd10;
parameter ReadData_M0S3        =5'd11;
parameter ReadData_M0S4        =5'd12;

parameter WriteAddr_M1         =5'd13;
parameter WriteData_M1S0       =5'd14;
parameter WriteData_M1S1       =5'd15;
parameter WriteData_M1S2       =5'd16;
parameter WriteData_M1S3       =5'd17;
parameter WriteData_M1S4       =5'd18;
parameter WriteResp_S0M1       =5'd19;
parameter WriteResp_S1M1       =5'd20;
parameter WriteResp_S2M1       =5'd21;
parameter WriteResp_S3M1       =5'd22;
parameter WriteResp_S4M1       =5'd23;

parameter WriteAddr_M0         =5'd24;
parameter Default_Slave        =5'd25;



//----AW----//
always_comb
begin
		  case(CS_W)
		    WriteAddr_M0:begin
				  AWID      =    AWID_M0     ;
				  AWADDR    =    AWADDR_M0   ;
				  AWLEN     =    AWLEN_M0    ;
				  AWSIZE    =    AWSIZE_M0   ;
				  AWBURST   =    AWBURST_M0  ;
				  AWVALID   =    AWVALID_M0  ;

			end
			WriteAddr_M1:begin
				  AWID      =    AWID_M1     ;
				  AWADDR    =    AWADDR_M1   ;
				  AWLEN     =    AWLEN_M1    ;
				  AWSIZE    =    AWSIZE_M1   ;
				  AWBURST   =    AWBURST_M1  ;
				  AWVALID   =    AWVALID_M1  ;	
			end
			default:begin
				  AWID      =    4'd0        ;
				  AWADDR    =    32'd0       ;
				  AWLEN     =    4'd0        ;
				  AWSIZE    =    3'd0        ;
				  AWBURST   =    2'd0        ;
				  AWVALID   =    1'd0        ;	  
			end
		  endcase

end

//----W----//
always_comb
begin
		  case(CS_W)
		    WriteData_M1S0 :begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                         
			end
		    WriteData_M1S1 :begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                         
			end	
		    WriteData_M1S2 :begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                         
			end
		    WriteData_M1S3 :begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                         
			end
		    WriteData_M1S4 :begin
			  WDATA    =  WDATA_M1       ;
			  WSTRB    =  WSTRB_M1       ;
			  WLAST    =  WLAST_M1       ;
			  WVALID   =  WVALID_M1      ;                         
			end			
			default:begin
			  WDATA    =  32'd0          ;
			  WSTRB    =  4'hf           ;
			  WLAST    =  1'd0           ;
			  WVALID   =  1'd0           ;
			end
		  endcase
end

//----AR----//
always_comb
begin	 
		  case(CS_R)
		    ReadAddr_M0:begin 
			  ARID     =  ARID_M0         ;
			  ARADDR   =  ARADDR_M0       ;
			  ARLEN    =  ARLEN_M0        ;
			  ARSIZE   =  ARSIZE_M0       ;
			  ARBURST  =  ARBURST_M0      ;
			  ARVALID  =  ARVALID_M0      ;
			  end
			ReadAddr_M1:begin
			  ARID     =  ARID_M1         ;
			  ARADDR   =  ARADDR_M1       ;
			  ARLEN    =  ARLEN_M1        ;
			  ARSIZE   =  ARSIZE_M1       ;
			  ARBURST  =  ARBURST_M1      ;
			  ARVALID  =  ARVALID_M1      ;
			  end			  
			default:begin
			  ARID     =  4'd0            ;
			  ARADDR   =  32'd0           ;
			  ARLEN    =  4'd0            ;
			  ARSIZE   =  3'd0            ;
			  ARBURST  =  2'd0            ;
			  ARVALID  =  1'd0            ;
			end
		  endcase
end


//----RREADY----//
always_comb
begin
  case(CS_R)
    ReadData_M0S0 :begin                  
      RREADY = RREADY_M0 ;
	end
    ReadData_M0S1:begin                  
      RREADY = RREADY_M0 ;
	end	
    ReadData_M0S2 :begin                  
      RREADY = RREADY_M0 ;
	end
    ReadData_M0S3:begin                  
      RREADY = RREADY_M0 ;
	end		
    ReadData_M0S4:begin                  
      RREADY = RREADY_M0 ;
	end		
	ReadData_M1S0 :begin
      RREADY = RREADY_M1 ;
	end
	ReadData_M1S1:begin
      RREADY = RREADY_M1 ;
	end	
	ReadData_M1S2 :begin
      RREADY = RREADY_M1 ;
	end
	ReadData_M1S3:begin
      RREADY = RREADY_M1 ;
	end		
	ReadData_M1S4:begin
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
    WriteResp_S0M1:begin                  
      BREADY = BREADY_M1 ;
	end
    WriteResp_S1M1:begin                  
      BREADY = BREADY_M1 ;
	end	
    WriteResp_S2M1:begin                  
      BREADY = BREADY_M1 ;
	end
    WriteResp_S3M1:begin                  
      BREADY = BREADY_M1 ;
	end	
    WriteResp_S4M1:begin                  
      BREADY = BREADY_M1 ;
	end		
	default:begin
      BREADY = 1'd0 ;
	end
  endcase
end
endmodule


