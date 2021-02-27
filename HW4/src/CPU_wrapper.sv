`include "AXI_define.svh"
`include "CPU.sv"
`include "def.svh"
`include "L1C_inst.sv"
`include "L1C_data.sv"

`define IDLE      3'd0
`define WriteAddr 3'd1
`define WriteData 3'd2
`define WriteResp 3'd3
`define ReadAddr  3'd4
`define ReadData  3'd5
`define Buffer    3'd6



module CPU_wrapper(
///////////////////CPU///////////////////////////
/*
output logic IM_CS,IM_OE,DM_CS,DM_OE,
output logic [3:0]IM_WEB,DM_WEB,
output logic [31:0]IM_addr,DM_addr,
output logic [31:0]DM_Data_in,
*/
input ACLK,
input ARESETn,
//input [31:0]IM_Data_out,DM_Data_out,
//////////////////M0////////////////////////////
///output logic [`AXI_IDS_BITS-1:0] AWID_M0,
///output logic [`AXI_ADDR_BITS-1:0] AWADDR_M0,
///output logic [`AXI_LEN_BITS-1:0] AWLEN_M0,
///output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M0,
///output logic [1:0] AWBURST_M0,
///output logic AWVALID_M0,
///input AWREADY_M0,
////WRITE DATA
//output logic [`AXI_DATA_BITS-1:0] WDATA_M0,
//output logic [`AXI_STRB_BITS-1:0] WSTRB_M0,
//output logic WLAST_M0,
//output logic WVALID_M0,
//input WREADY_M0,
// //WRITE RESPONSE
//input [`AXI_IDS_BITS-1:0] BID_M0,
//input [1:0] BRESP_M0,
//input BVALID_M0,
//output logic BREADY_M0,
//READ ADDRESS
output logic [`AXI_ID_BITS-1:0]  ARID_M0   ,
output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0 ,
output logic [`AXI_LEN_BITS-1:0]  ARLEN_M0  ,
output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0 ,
output logic [1:0]                ARBURST_M0,
output logic                      ARVALID_M0,
input                             ARREADY_M0,
//READ DATA
input [`AXI_ID_BITS-1:0]  RID_M0   ,
input [`AXI_DATA_BITS-1:0] RDATA_M0 ,
input [1:0]                RRESP_M0 ,
input                      RLAST_M0 ,
input                      RVALID_M0,
output logic               RREADY_M0,
//////////////////M1////////////////////////////
output logic [`AXI_ID_BITS-1:0]  AWID_M1   ,
output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1 ,
output logic [`AXI_LEN_BITS-1:0]  AWLEN_M1  ,
output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1 ,
output logic [1:0]                AWBURST_M1,
output logic                      AWVALID_M1,
input                             AWREADY_M1,
//WRITE DATA
output logic [`AXI_DATA_BITS-1:0] WDATA_M1 ,
output logic [`AXI_STRB_BITS-1:0] WSTRB_M1 ,
output logic                      WLAST_M1 ,
output logic                      WVALID_M1,
input                             WREADY_M1,
 //WRITE RESPONSE
input [`AXI_ID_BITS-1:0] BID_M1   ,
input [1:0]               BRESP_M1 ,
input                     BVALID_M1,
output logic              BREADY_M1,
//READ ADDRESS
output logic [`AXI_ID_BITS-1:0]  ARID_M1   ,
output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1 ,
output logic [`AXI_LEN_BITS-1:0]  ARLEN_M1  ,
output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1 ,
output logic [1:0]                ARBURST_M1,
output logic                      ARVALID_M1,
input                             ARREADY_M1,
//READ DATA
input [`AXI_ID_BITS-1:0]  RID_M1   ,
input [`AXI_DATA_BITS-1:0] RDATA_M1 ,
input [1:0]                RRESP_M1 ,
input                      RLAST_M1 ,
input                      RVALID_M1,
output logic               RREADY_M1,

input interrupt
);

logic [31:0]DM_Data_out,IM_Data_out;
logic IM_Read,DM_Read,IM_Write,DM_Write;
logic [2:0] CS_M0,CS_M1,NS_M0,NS_M1;
logic CPU_Ready;

logic IM_CS,IM_OE,DM_CS,DM_OE;
logic [3:0]IM_WEB,DM_WEB;
logic [31:0]IM_addr,DM_addr;
logic [31:0]DM_Data_in;
logic I_wait, D_wait;  //--------not yet
logic IM_wait, DM_wait;
logic D_req, I_req;
logic [`DATA_BITS-1:0] D_addr, I_addr;
logic D_write, I_write;
logic [`DATA_BITS-1:0] D_in, I_in;
logic [`CACHE_TYPE_BITS-1:0] D_type, I_type;  //-----not yet
logic core_req_D, core_req_I;
logic [2:0]IM_type,DM_type;
logic [31:0]RDATA_M0_buf;
logic [31:0]RDATA_M1_buf;
logic [31:0]IM_Data_out_buf,DM_Data_out_buf;
logic [31:0]D_in_buf;

//assign core_req_D = (DM_Read || DM_Write)? 1'b1 : 1'b0;
//assign core_req_I = (IM_Read || IM_Write)? 1'b1 : 1'b0;
assign I_wait = (CS_M0 == `IDLE )? 1'b0 : 1'b1;
assign D_wait = ((CS_M1 == `IDLE)||(CS_M1 == `Buffer))? 1'b0 : 1'b1;
assign CPU_Ready = (~IM_wait && ~DM_wait /*&& ~I_wait && ~D_wait*/) ? 1'b1 : 1'b0;

logic grant;
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) grant <= 1'd0;
  else begin
	  if(DM_Read && IM_Read) grant <= grant + 1'd1;
	  else grant <= 1'b0;
  end
end

//----------------------------------------------

logic a,first_M1;

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn)
	begin
		first_M1 <= 1'b0;	
		a <= 1'b0;
	end
	else
	begin
		if(CPU_Ready == 1'b0)
		begin
			if((DM_WEB != 4'b1111 || DM_OE == 1'b1) && a == 1'b0)
			begin
				first_M1 <= 1'b1;
				a <= 1'b1;
			end
			else
			begin
				first_M1 <= 1'b0;
			end		
		end
		else
		begin
			first_M1 <= 1'b0;	
			a <= 1'b0;
		end	
	end
end

logic finish_M1;
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn)
	begin
		finish_M1 <= 1'b0;		
	end
	else
	begin
		if(CPU_Ready == 1'b0)
		begin
			if((DM_WEB != 4'b1111 || DM_OE == 1'b1) && first_M1 == 1'b0)
			begin
				finish_M1 <= 1'b1;				
			end			
		end
		else
		begin
			finish_M1 <= 1'b0;			
		end	
	end
end

always_comb
begin
    if(D_req == 1'b1 && finish_M1 == 1'b1) begin
	    core_req_I = 1'b0 ;	  
	end
  else begin
       core_req_I = 1'b1 ;
  end
end

always_comb
begin
	if(CPU_Ready == 1'b0 && (DM_WEB != 4'b1111 || DM_OE != 1'b0) && finish_M1 == 1'b0)
	begin
		core_req_D = 1'b1;
	end
	else
		core_req_D = 1'b0;
end
//---------------------------------------------



/*
always_comb
begin
    if(IM_Read || IM_Write) begin
	    core_req_I = 1'b1 ;	  
	end
  else begin
    core_req_I = 1'b0 ;
  end
end

always_comb
begin
    if((DM_Write || DM_Read))	core_req_D= 1'b1 ;
	else core_req_D= 1'b0 ;
end

*/



logic core_req_D_buf;
logic DM_Write_buf  ;
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) begin
    core_req_D_buf <= 1'd0;
	DM_Write_buf <= 1'd0;
  end
  else begin
	  core_req_D_buf <= core_req_D ;
	  DM_Write_buf <= DM_Write;
  end
end




/*
always_comb
begin  
    if((DM_Read || DM_Write) && (~DM_wait))	core_req_D= 1'b1 ;
	else core_req_D= 1'b0 ;

end


*/



logic [31:0] DM_Data_in_buf;

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) DM_Data_in_buf <= 32'd0;
  else begin
    if(core_req_D)
      DM_Data_in_buf <= DM_Data_in ;
	else
	  DM_Data_in_buf <= DM_Data_in_buf ;
  end
end

logic [31:0] DM_Data_in_buf2;

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) DM_Data_in_buf2 <= 32'd0;
  else begin
    if(CPU_Ready)
      DM_Data_in_buf2 <= DM_Data_in ;
	else
	  DM_Data_in_buf2 <= DM_Data_in_buf2 ;
  end
end



CPU CPU1 (
//IM
.IM_CS(IM_CS),
.IM_OE(IM_OE),
.IM_WEB(IM_WEB),
.IM_addr(IM_addr),
.IM_Data_out(IM_Data_out),
//DM
.DM_CS(DM_CS),
.DM_OE(DM_OE),
.DM_WEB(DM_WEB),
.DM_addr(DM_addr),
.DM_Data_in(DM_Data_in),
.DM_Data_out(DM_Data_out_buf),
.CPU_Ready(CPU_Ready),
.CS_M0(CS_M0),
.CS_M1(CS_M1),
.NS_M0(NS_M0),
.NS_M1(NS_M1),
//
.clk(ACLK),
.rst(~ARESETn),
.IM_type(IM_type),  //------ not yet
.DM_type(DM_type),   //------
.interrupt(interrupt)
); 



logic [31:0] DM_addr_buf;

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) DM_addr_buf <= 32'd0;
  else begin
    if(core_req_D)
      DM_addr_buf <= DM_addr ;
	else
	  DM_addr_buf <= DM_addr_buf ;
  end
end





L1C_data L1CD (  //for DM
.clk(ACLK),
.rst(!ARESETn),
//input
.core_addr(DM_addr),
.core_req(core_req_D_buf),
.core_write(DM_Write_buf),
.core_in(DM_Data_in),
.core_type(DM_type),

.D_out(RDATA_M1_buf),
.D_wait(D_wait),
//output
.core_out(DM_Data_out),
.core_wait(DM_wait),

.D_req(D_req),
.D_addr(D_addr),
.D_write(D_write),
.D_in(D_in),
.D_type(D_type)
);

L1C_inst L1CI ( //for IM
.clk(ACLK),
.rst(!ARESETn),
//input
.core_addr(IM_addr),
.core_req(core_req_I),
.core_write(1'b0),
.core_in(32'd0),
.core_type(IM_type),

.I_out(RDATA_M0_buf),  //data from cpu wrapper
.I_wait(I_wait),
//output
.core_out(IM_Data_out),       //data to CPU
.core_wait(IM_wait),

.I_req(I_req),
.I_addr(I_addr),
.I_write(I_write),
.I_in(I_in),
.I_type(I_type)
);


assign IM_Read = IM_CS && IM_OE ;
assign IM_Write= IM_CS && (IM_WEB!=4'b1111) ;
assign DM_Read = DM_CS && DM_OE ;
assign DM_Write= DM_CS && (DM_WEB!=4'b1111) ;

logic DM_OE_buf;
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) DM_OE_buf <= 1'd0;
  else begin
	  DM_OE_buf <= DM_OE ;
  end
end

logic DM_Read_buf;
always_comb 
begin
  if((DM_CS && DM_OE) && (~DM_OE_buf))
     DM_Read_buf=1'b1;
  else 
     DM_Read_buf=1'b0;
end




always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) IM_Data_out_buf <= 32'd0;
  else begin
  /*  if(CPU_Ready)
	  IM_Data_out_buf <= IM_Data_out ;
	else */
	  IM_Data_out_buf <= IM_Data_out ;
  end
end

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) DM_Data_out_buf <= 32'd0;
  else if (DM_wait) DM_Data_out_buf <= DM_Data_out ;
  else DM_Data_out_buf <= DM_Data_out_buf ;
end


//-------FSM_M0-------//
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) CS_M0 <= 3'd0;
  else CS_M0 <= NS_M0 ;
end

always_comb
begin
  case(CS_M0)
    `IDLE :begin
	   if(I_req && (~I_write)) NS_M0 = `ReadAddr;   //IM_Read  or ARVALID ?
	   else NS_M0 = `IDLE;
	end
    `ReadAddr :begin
	  if(ARVALID_M0 && ARREADY_M0) NS_M0 = `ReadData;
	  else NS_M0 = `ReadAddr;
	end
    `ReadData :begin
	  if(RVALID_M0 && RREADY_M0) NS_M0 = `Buffer;
	  else NS_M0 = `ReadData;
	end	
    `Buffer	: NS_M0 = 3'd7;
	default : begin
	  NS_M0 = `IDLE;
	end
  endcase
end

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) ARADDR_M0 <= 32'd0    ; 
  else if(ARVALID_M0)begin
     ARADDR_M0 <= ARADDR_M0   ;
  end
  else ARADDR_M0 <=I_addr;
end


assign ARID_M0    = (ARVALID_M0)? 4'd1 : 4'd0 ;  
assign ARLEN_M0   = 4'd0 ;  
assign ARSIZE_M0  = (ARVALID_M0)? 3'd2 : 3'd0 ;  
assign ARBURST_M0 = (ARVALID_M0)? 2'd1 : 2'd0 ;  



/*
always_comb
begin
    IM_Data_out = RDATA_M0_buf   ; 
end
*/

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) RDATA_M0_buf <= 32'd0;
  else begin
	  if(RVALID_M0 && RREADY_M0) RDATA_M0_buf <= RDATA_M0;
	  else RDATA_M0_buf <= RDATA_M0_buf ;
  end
end

//-------FSM_M1-------//
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) CS_M1 <= 3'b0;
  else CS_M1 <= NS_M1 ;
end

always_comb
begin
  case(CS_M1)
    `IDLE :begin
	   if(D_req && (~D_write)) NS_M1 = `ReadAddr;   //DM_Read  or ARVALID ?
	   else if (D_req && D_write) NS_M1 = `WriteAddr;
	   else NS_M1 = `IDLE;
	end
    `WriteAddr :begin
	   if(AWVALID_M1 && AWREADY_M1) NS_M1 = `WriteData; 
	   else NS_M1 = `WriteAddr;
	end	
    `WriteData :begin
      if(WVALID_M1 && WREADY_M1) NS_M1 = `WriteResp;
	  else NS_M1 = `WriteData;
	end
    `WriteResp :begin
      if(BVALID_M1 && BREADY_M1) NS_M1 = `Buffer;
	  else NS_M1 = `WriteResp;
	end	
    `ReadAddr :begin
	  if(ARVALID_M1 && ARREADY_M1) NS_M1 = `ReadData;
	  else NS_M1 = `ReadAddr;
	end
    `ReadData :begin
	  if(RVALID_M1 && RREADY_M1) NS_M1 = `IDLE;
	  else NS_M1 = `ReadData;
	end		
	`Buffer	: begin
	 /* if(D_write) NS_M1 = `Buffer;
	  else*/ NS_M1 = 3'd7;
	end
	default : begin
	  NS_M1 = `IDLE;
	end
  endcase
end


always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) ARADDR_M1 <= 32'd0    ; 
  else if(ARVALID_M1)begin
     ARADDR_M1 <= ARADDR_M1   ;
  end
  else ARADDR_M1 <=D_addr;
end

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) AWADDR_M1 <= 32'd0    ; 
  else if(AWVALID_M1)begin
     AWADDR_M1 <= AWADDR_M1   ;
  end
  else AWADDR_M1 <=D_addr;
end

assign ARID_M1    = (ARVALID_M1)? 4'd1 : 4'd0 ;  
assign ARLEN_M1   = 4'd0 ;  
assign ARSIZE_M1  = (ARVALID_M1)? 3'd2 : 3'd0 ;  
assign ARBURST_M1 = (ARVALID_M1)? 2'd1 : 2'd0 ;  

assign AWID_M1    = (AWVALID_M1)? 4'd1 : 4'd0 ;  
assign AWLEN_M1   = 4'd0 ;  
assign AWSIZE_M1  = (AWVALID_M1)? 3'd2 : 3'd0 ;  
assign AWBURST_M1 = (AWVALID_M1)? 2'd1 : 2'd0 ;  


always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) D_in_buf <= 32'd0;
  else if (CS_M1==`IDLE) D_in_buf <= D_in ;
  else D_in_buf <= D_in_buf ;
end

logic [2:0]D_type_buf ;
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) D_type_buf <= 3'd0;
  else if (CS_M1==`IDLE) D_type_buf <= D_type ;
  else D_type_buf <= D_type_buf ;
end

always_comb
begin
  if(CS_M1==`WriteData) 
    begin
      WVALID_M1 = 1'b1;
      WDATA_M1  = D_in_buf ;
      WSTRB_M1  = DM_WEB ;
      WLAST_M1  = 1'b1 ;		
	end
  else begin
    WVALID_M1 = 1'b0;
    WDATA_M1  = 32'd0; 
    WSTRB_M1  = 4'b1111 ;
    WLAST_M1  = 1'b0 ;	
  end
end



/*
always_comb
begin
    DM_Data_out = RDATA_M1_buf   ; 
end
*/

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) RDATA_M1_buf <= 0;
  else begin
	  if(RVALID_M1 && RREADY_M1) RDATA_M1_buf <= RDATA_M1;
	  else RDATA_M1_buf <= RDATA_M1_buf ;
  end
end


//--------------M0------------------//
//read ARVALID_M0

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) ARVALID_M0 <= 1'b0;
  else if (ARREADY_M0 && ARVALID_M0) ARVALID_M0 <= 1'b0;
  else if ((IM_Read && I_req) && (CS_M0==`IDLE)) ARVALID_M0 <= 1'b1;
  
end

//read RREADY_M0
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) RREADY_M0 <= 1'b0;
  else if (RREADY_M0) RREADY_M0 <= 1'b0;  
  else if (RVALID_M0 && ~RREADY_M0) RREADY_M0 <= 1'b1;
  
end

//--------------M1-----------------//


//write AWVALID_M1 
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) AWVALID_M1 <= 1'b0;

  else if (AWREADY_M1 && AWVALID_M1) AWVALID_M1 <= 1'b0;
  else if (D_req && (CS_M1==`IDLE) && (D_write)) AWVALID_M1 <= 1'b1;
  
end

//read ARVALID_M1
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) ARVALID_M1 <= 1'b0;
  else begin
      if (ARREADY_M1 && ARVALID_M1) ARVALID_M1 <= 1'b0;
      else if ((D_req) && (CS_M1==`IDLE) && (!D_write)) ARVALID_M1 <= 1'b1; 
  end
end

//read RREADY_M1
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) RREADY_M1 <= 1'b0;
  else if (RREADY_M1) RREADY_M1 <= 1'b0;
  else if (RVALID_M1 && ~RREADY_M1) RREADY_M1 <= 1'b1;
 

end

//write BREADY_M1
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) BREADY_M1 <= 1'b0;
  else if (BVALID_M1 && ~BREADY_M1) BREADY_M1 <= 1'b1;
  else if (BREADY_M1) BREADY_M1 <= 1'b0; 
end


/*
always_comb
begin
 if((CS_M0==`IDLE) && (CS_M1==`IDLE) || (CS_M0==`IDLE) && (CS_M1==`WriteResp))
   CPU_Ready = 1'b1 ;
 else 
   CPU_Ready = 1'b0 ;
end
*/

endmodule

//----------------------------------------


