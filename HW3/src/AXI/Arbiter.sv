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

module Arbiter (
	input ACLK,
	input ARESETn,

    input AWVALID_M0,	
    input ARVALID_M0,
	input ARREADY_M0,
	
	input AWVALID_M1,
    input AWREADY_M1,
    input WVALID_M1,
    input WREADY_M1,
    input BVALID_M1,
    input BREADY_M1,
	input ARVALID_M1,
    input ARREADY_M1,	
	
	
	input [`AXI_ADDR_BITS-1:0]AWADDR_M1,
	input [`AXI_ADDR_BITS-1:0]ARADDR_M0,
	input [`AXI_ADDR_BITS-1:0]ARADDR_M1,
	
	input RVALID_M0,
	input RVALID_M1,
    input RREADY_M0,	
	input RREADY_M1,	
        input WLAST_M1,
        
	
	
	output logic [3:0]CS_R,
	output logic [3:0]CS_W,
	output logic [3:0]NS_R,
	output logic [3:0]NS_W


);

//logic [3:0] NS_W,NS_R;
logic Grant_R,Grant_W;

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) begin
    Grant_R <= 1'b0;
    Grant_W <= 1'b0;
  end
  else begin
    if(CS_R==`ReadAddr_M1)  Grant_R <= Grant_R + 1'b1 ;
    if(CS_W==`WriteAddr_M1) Grant_W <= Grant_W + 1'b1 ;    
  end
end


//-------FSM_WRITE-------//
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) CS_W <= `IDLE;
  else CS_W <= NS_W ;
end

always_comb
begin
  case(CS_W)
    `IDLE :begin
	   if(AWVALID_M1 /* && !AWVALID_M0*/) begin
	      if(WLAST_M1)begin //-------------AW and W sim
				 if(AWADDR_M1[31:16]==16'd0)
				   NS_W = `Write_Addr_Data_M1S0; 
				 else if(AWADDR_M1[31:16]==16'd1)
				   NS_W = `Write_Addr_Data_M1S1; 
				 else NS_W = `Default_Slave;
		 end
		 else NS_W = `WriteAddr_M1;
	   end
         else if (AWVALID_M0/* && !AWVALID_M1*/) NS_W = `WriteAddr_M0; 	   
	   /*else if (AWVALID_M0 && AWVALID_M1) begin
             if(!Grant_W) begin
               NS_W = `WriteAddr_M1;


             end
             else         NS_W = `WriteAddr_M0;
           end*/
           else NS_W = `IDLE;                        
	end
    `WriteAddr_M1 :begin
	   if(AWVALID_M1 && AWREADY_M1) begin
	     if(AWADDR_M1[31:16]==16'd0)
	       NS_W = `WriteData_M1S0; 
		 else if(AWADDR_M1[31:16]==16'd1)
	       NS_W = `WriteData_M1S1; 
		 else NS_W = `Default_Slave;
	   end
           else if(WVALID_M1)begin //-------------AW and W sim
			 if(AWADDR_M1[31:16]==16'd0)
			   NS_W = `Write_Addr_Data_M1S0; 
			 else if(AWADDR_M1[31:16]==16'd1)
			   NS_W = `Write_Addr_Data_M1S1; 
			 else NS_W = `Default_Slave;
           end
	   else NS_W = `WriteAddr_M1;
	end	
    `WriteData_M1S0 :begin
      if(WVALID_M1 && WREADY_M1) NS_W = `WriteResp_S0M1;
	  else NS_W = `WriteData_M1S0;
	end
    `WriteData_M1S1 :begin
      if(WVALID_M1 && WREADY_M1) NS_W = `WriteResp_S1M1;
	  else NS_W = `WriteData_M1S1;
	end		
    `WriteResp_S0M1 :begin
      if(BVALID_M1 && BREADY_M1) NS_W = `IDLE;
	  else NS_W = `WriteResp_S0M1;
	end	
    `WriteResp_S1M1 :begin
      if(BVALID_M1 && BREADY_M1) NS_W = `IDLE;
	  else NS_W = `WriteResp_S1M1;
	end	
    `WriteAddr_M0 :begin
	   NS_W = `IDLE;
	end
    `Write_Addr_Data_M1S0 :begin
      if(WREADY_M1 && AWREADY_M1) NS_W = `WriteResp_S0M1;
	  else NS_W = `Write_Addr_Data_M1S0;
	end
    `Write_Addr_Data_M1S1 :begin
        if(WREADY_M1 && AWREADY_M1) NS_W = `WriteResp_S1M1;
	  else NS_W = `Write_Addr_Data_M1S1;
	end	
    `Default_Slave : NS_W = `IDLE;	
	default : begin
	  NS_W = `IDLE;
	end
  endcase
end


//-------FSM_READ-------//

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) CS_R <= `IDLE;
  else CS_R <= NS_R ;
end


always_comb
begin
  case(CS_R)
    `IDLE :begin
	   if(ARVALID_M1) NS_R = `ReadAddr_M1;     //------------read/write at the same time and same mem ?
       else if (ARVALID_M0) NS_R = `ReadAddr_M0; 	   
	   else NS_R = `IDLE;                     //---------default slave?
	end
    `ReadAddr_M1 :begin
	  if(ARVALID_M1 && ARREADY_M1) begin
	     if(ARADDR_M1[31:16]==16'd0)
	       NS_R = `ReadData_M1S0; 
	     else if(ARADDR_M1[31:16]==16'd1)
	       NS_R = `ReadData_M1S1; 
		 else NS_R = `Default_Slave;
	  end
	  else NS_R = `ReadAddr_M1;
	end
    `ReadData_M1S0 :begin
	  if(RVALID_M1 && RREADY_M1) NS_R = `IDLE;
	  else NS_R = `ReadData_M1S0;
	end			
    `ReadData_M1S1 :begin
	  if(RVALID_M1 && RREADY_M1) NS_R = `IDLE;
	  else NS_R = `ReadData_M1S1;
	end			
    `ReadAddr_M0 :begin
	  if(ARVALID_M0 && ARREADY_M0) begin
	     if(ARADDR_M0[16]==1'b0)
	       NS_R = `ReadData_M0S0; 
	     else if(ARADDR_M0[16]==1'b1)
	       NS_R = `ReadData_M0S1; 
		 else NS_R = `Default_Slave;
	  end
	  else NS_R = `ReadAddr_M0;
	end
    `ReadData_M0S0 :begin
	  if(RVALID_M0 && RREADY_M0) NS_R = `IDLE;
	  else NS_R = `ReadData_M0S0;
	end			
    `ReadData_M0S1 :begin
	  if(RVALID_M0 && RREADY_M0) NS_R = `IDLE;
	  else NS_R = `ReadData_M0S1;
	end	
    `Default_Slave : NS_R = `IDLE;	
	default : begin
	  NS_R = `IDLE;
	end
  endcase
end











/*
always_comb
begin
  case(CS)
    `IDLE :begin             //priority AR1 > AR0 > AW1 > AW0
	   if(ARVALID_M1)       NS = `ReadAddr_M1;   
	   else if (ARVALID_M0) NS = `ReadAddr_M0;
       else if (AWVALID_M1) NS = `WriteAddr_M1;
       else if (AWVALID_M0) NS = `WriteAddr_M0;	   
	   else NS = `IDLE;
	end
    `ReadAddr_M1 :begin
	  if(ARVALID_M1 && ARREADY_M1) begin
	     if(ARADDR_M1[16]==1'b0)
	       NS = `ReadData_M1S0; 
	     else if(ARADDR_M1[16]==1'b1)
	       NS = `ReadData_M1S1; 
		 else NS = `IDLE;
	  end
	  else NS = `ReadAddr_M1;
	end
    `ReadData_M1S0 :begin
	  if(RVALID_M1 && RREADY_M1) NS = `IDLE;
	  else NS = `ReadData_M1;
	end			
    `ReadData_M1S1 :begin
	  if(RVALID_M1 && RREADY_M1) NS = `IDLE;
	  else NS = `ReadData_M1;
	end			
    `ReadAddr_M0 :begin
	  if(ARVALID_M0 && ARREADY_M0) NS = `ReadData_M0;  /////  ARREADY_M0?
	  else NS = `ReadAddr_M0;
	end	
    `ReadData_M0 :begin
	  if(RVALID_M0 && RREADY_M0) NS = `IDLE;
	  else NS = `ReadData_M0;
	end		
	
    `WriteAddr_M1 :begin
	   if(AWVALID_M1 && AWREADY_M1) NS = `WriteData_M1; 
	   else NS = `WriteAddr_M1;
	end	
    `WriteData_M1 :begin
      if(WVALID_M1 && WREADY_M1) NS = `WriteResp_M1;
	  else NS = `WriteData_M1;
	end
    `WriteResp_M1 :begin
      if(BVALID_M1 && BREADY_M1) NS = `IDLE;
	  else NS = `WriteResp_M1;
	end	

    `WriteAddr_M0 :begin
	   if(AWVALID_M0 && AWREADY_M0) NS = `WriteData_M0; 
	   else NS = `WriteAddr_M0;
	end	
    `WriteData_M0 :begin
      if(WVALID_M0 && WREADY_M0) NS = `WriteResp_M0;
	  else NS = `WriteData_M0;
	end
    `WriteResp_M0 :begin
      if(BVALID_M0 && BREADY_M0) NS = `IDLE;
	  else NS = `WriteResp_M0;
	end		

	default : begin
	  NS = `IDLE;
	end
  endcase
end


*/
/*
//----------------AW arbit-----------------------
logic AWSEL_M0,AWSEL_M1,AWSEL_default;
logic AW_grant_M0,AW_grant_M1;
always_comb
begin
  if(AWVALID_M0 && AWVALID_M1) begin
    AWSEL_M0     = AW_grant_M0;
	AWSEL_M1     = AW_grant_M1;
	AWSEL_default= 1'b0;	
  end
  else if (AWVALID_M0 && ~AWVALID_M1) begin
    AWSEL_M0     = 1'b1;
	AWSEL_M1     = 1'b0;
	AWSEL_default= 1'b0;	  
  end
  else if (~AWVALID_M0 && AWVALID_M1) begin
    AWSEL_M0     = 1'b0;
	AWSEL_M1     = 1'b1;
	AWSEL_default= 1'b0;	  
  end
  else begin
    AWSEL_M0     = 1'b0;
	AWSEL_M1     = 1'b0;
	AWSEL_default= 1'b1;	  
  end
end

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) begin
    AW_grant_M0<=1'b1;
	AW_grant_M1<=1'b0;
  end
  else begin
    if(AWVALID)begin
      AW_grant_M0<=AW_grant_M0;
	  AW_grant_M1<=AW_grant_M1;	
	end
	else begin
		if(AWVALID_M0 && AWVALID_M1 && (AW_grant_M0==1'b1))begin
		  AW_grant_M0<=1'b0;
		  AW_grant_M1<=1'b1;	  
		end
		else if (AWVALID_M0 && AWVALID_M1 && (AW_grant_M1==1'b1))begin
		  AW_grant_M0<=1'b1;
		  AW_grant_M1<=1'b0;	
		end
	end
  end
end

//-------------------AR arbit-----------------------
logic ARSEL_M0,ARSEL_M1,ARSEL_default;
logic AR_grant_M0,AR_grant_M1;

always_comb
begin
  if(ARVALID_M0 && ARVALID_M1) begin
    ARSEL_M0=AR_grant_M0;
	ARSEL_M1=AR_grant_M1;
	ARSEL_default=1'b0;
  end 
  else if (ARVALID_M0 && ~ARVALID_M1) begin
    ARSEL_M0=1'b1;
	ARSEL_M1=1'b0;
	ARSEL_default=1'b0;  
  end
  else if (~ARVALID_M0 && ARVALID_M1) begin
    ARSEL_M0=1'b0;
	ARSEL_M1=1'b1;
	ARSEL_default=1'b0;  
  end
  else begin
    ARSEL_M0=1'b0;
	ARSEL_M1=1'b0;
	ARSEL_default=1'b1;       
  end
end

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) begin
    AR_grant_M0<=1'b1;
	AR_grant_M1<=1'b0;
  end
  else begin
    if(ARVALID) begin
		  AR_grant_M0<=AR_grant_M0;
		  AR_grant_M1<=AR_grant_M1;	  
	end
	else begin
		if(ARVALID_M0 && ARVALID_M1 && (AR_grant_M0==1'b1))begin
		  AR_grant_M0<=1'b0;
		  AR_grant_M1<=1'b1;	  
		end
		else if (ARVALID_M0 && ARVALID_M1 && (AR_grant_M1==1'b1))begin
		  AR_grant_M0<=1'b1;
		  AR_grant_M1<=1'b0;	
		end
	end
  end
end


always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) 
    AW_GrantMaster<=3'd0;
  else begin
    if(AWVALID) AW_GrantMaster<=AW_GrantMaster;
    else AW_GrantMaster<={AWSEL_M0,AWSEL_M1,AWSEL_default};
  end
end

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) 
    AR_GrantMaster<=3'd0;
  else begin
    if(ARVALID) AR_GrantMaster<=AR_GrantMaster;
    else AR_GrantMaster<={ARSEL_M0,ARSEL_M1,ARSEL_default};
  end
end



*/


endmodule


















