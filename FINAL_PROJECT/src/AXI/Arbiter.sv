`include "AXI_define.svh"

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
        
	
	
	output logic [4:0]CS_R,
	output logic [4:0]CS_W,
	output logic [4:0]NS_R,
	output logic [4:0]NS_W


);


parameter IDLE                 =5'd0;

parameter ReadAddr_M1          =5'd1;
parameter ReadData_M1S0        =5'd2;
parameter ReadData_M1S1        =5'd3;
parameter ReadData_M1S2        =5'd4;
parameter ReadData_M1S3        =5'd5;
parameter ReadData_M1S4        =5'd6;
parameter ReadData_M1S5        =5'd26;

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
parameter WriteData_M1S5       =5'd27;

parameter WriteResp_S0M1       =5'd19;
parameter WriteResp_S1M1       =5'd20;
parameter WriteResp_S2M1       =5'd21;
parameter WriteResp_S3M1       =5'd22;
parameter WriteResp_S4M1       =5'd23;
parameter WriteResp_S5M1       =5'd28;

parameter WriteAddr_M0         =5'd24;
parameter Default_Slave        =5'd25;




//parameter WriteData_M0S0       =5'd8;
//parameter WriteData_M0S1       =5'd9;
//parameter WriteData_M0S2       =5'd8;
//parameter WriteData_M0S3       =5'd9;
//parameter WriteData_M0S4       =5'd8;
//parameter WriteResp_S0M0       =5'd10;
//parameter WriteResp_S1M0       =5'd11;
//parameter WriteResp_S2M0       =5'd10;
//parameter WriteResp_S3M0       =5'd11;
//parameter WriteResp_S4M0       =5'd10;

//parameter Write_Addr_Data_M1S0 =5'd14;
//parameter Write_Addr_Data_M1S1 =5'd15;
//parameter Write_Addr_Data_M1S2 =5'd14;
//parameter Write_Addr_Data_M1S3 =5'd15;
//parameter Write_Addr_Data_M1S4 =5'd14;

//-------FSM_WRITE-------//
always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) CS_W <= IDLE;
  else CS_W <= NS_W ;
end

always_comb
begin
  case(CS_W)
    IDLE :begin
	   if(AWVALID_M1) begin
         NS_W = WriteAddr_M1;
	   end
       //else if (AWVALID_M0)begin
       //  NS_W = WriteAddr_M0;
	   //end
       else begin
	     NS_W = IDLE; 
       end		 
	end
    WriteAddr_M1 :begin
	   if(AWVALID_M1 && AWREADY_M1) begin
	     if(AWADDR_M1[31:16]==16'h0000)
	       NS_W = WriteData_M1S0; 
		 else if (AWADDR_M1[31:16]==16'h0001)
	       NS_W = WriteData_M1S1; 
		 else if (AWADDR_M1[31:16]==16'h0002) 
           NS_W = WriteData_M1S2; 		
		 else if (AWADDR_M1[31:16]==16'h1000) 
           NS_W = WriteData_M1S3;   
		 else if (AWADDR_M1[31:24]==8'h20) 
           NS_W = WriteData_M1S4;
		 else if (AWADDR_M1[31:16]==16'h3000)
		   NS_W = WriteData_M1S5;
		 else NS_W = Default_Slave;
	   end
	   else if (AWADDR_M1[31:16]!=16'h0000 && AWADDR_M1[31:16]!=16'h0001 &&AWADDR_M1[31:16]!=16'h0002 &&AWADDR_M1[31:16]!=16'h1000 &&AWADDR_M1[31:24]!=8'h20 &&AWADDR_M1[31:16]!=16'h3000)
	     NS_W = Default_Slave;
	   else NS_W = WriteAddr_M1;
	end	
    WriteData_M1S0 :begin
      if(WVALID_M1 && WREADY_M1) NS_W = WriteResp_S0M1;
	  else NS_W = WriteData_M1S0;      
	end                                 
    WriteData_M1S1 :begin               
      if(WVALID_M1 && WREADY_M1) NS_W = WriteResp_S1M1;
	  else NS_W = WriteData_M1S1;      
	end		                            
    WriteData_M1S2 :begin               
      if(WVALID_M1 && WREADY_M1) NS_W = WriteResp_S2M1;
	  else NS_W = WriteData_M1S2;      
	end		                            
    WriteData_M1S3 :begin               
      if(WVALID_M1 && WREADY_M1) NS_W = WriteResp_S3M1;
	  else NS_W = WriteData_M1S3;      
	end		                            
    WriteData_M1S4 :begin               
      if(WVALID_M1 && WREADY_M1) NS_W = WriteResp_S4M1;
	  else NS_W = WriteData_M1S4;
	end		
    WriteData_M1S5 :begin               
      if(WVALID_M1 && WREADY_M1) NS_W = WriteResp_S5M1;
	  else NS_W = WriteData_M1S5;
	end			
    WriteResp_S0M1 :begin
      if(BVALID_M1 && BREADY_M1) NS_W = IDLE;
	  else NS_W = WriteResp_S0M1;
	end	
    WriteResp_S1M1 :begin
      if(BVALID_M1 && BREADY_M1) NS_W = IDLE;
	  else NS_W = WriteResp_S1M1;
	end	
    WriteResp_S2M1 :begin
      if(BVALID_M1 && BREADY_M1) NS_W = IDLE;
	  else NS_W = WriteResp_S2M1;
	end	
    WriteResp_S3M1 :begin
      if(BVALID_M1 && BREADY_M1) NS_W = IDLE;
	  else NS_W = WriteResp_S3M1;
	end		
    WriteResp_S4M1 :begin
      if(BVALID_M1 && BREADY_M1) NS_W = IDLE;
	  else NS_W = WriteResp_S4M1;
	end	
    WriteResp_S5M1 :begin
      if(BVALID_M1 && BREADY_M1) NS_W = IDLE;
	  else NS_W = WriteResp_S5M1;
	end		
    //WriteAddr_M0 :begin
	//   NS_W = IDLE;
	//end
    Default_Slave : NS_W = IDLE;	
	default : begin
	  NS_W = IDLE;
	end
  endcase
end


//-------FSM_READ-------//

always@(posedge ACLK or negedge ARESETn)
begin
  if(!ARESETn) CS_R <= IDLE;
  else CS_R <= NS_R ;
end


always_comb
begin
  case(CS_R)
    IDLE :begin
	   if(ARVALID_M1) NS_R = ReadAddr_M1;     //------------read/write at the same time and same mem ?
       else if (ARVALID_M0) NS_R = ReadAddr_M0; 	   
	   else NS_R = IDLE;                     //---------default slave?
	end
    ReadAddr_M1 :begin
	  if(ARVALID_M1 && ARREADY_M1) begin
	     if(ARADDR_M1[31:16]==16'h0000)
	       NS_R = ReadData_M1S0; 
	     else if(ARADDR_M1[31:16]==16'h0001)
	       NS_R = ReadData_M1S1; 
	     else if(ARADDR_M1[31:16]==16'h0002)
	       NS_R = ReadData_M1S2; 		   
	     else if(ARADDR_M1[31:16]==16'h1000)
	       NS_R = ReadData_M1S3; 
	     else if(ARADDR_M1[31:24]==8'h20)
	       NS_R = ReadData_M1S4; 
	     else if(ARADDR_M1[31:16]==16'h3000)
	       NS_R = ReadData_M1S5;		   
         else NS_R = Default_Slave;
	  end
	  /*else if (ARADDR_M1[31:16]!=16'h0000 && ARADDR_M1[31:16]!=16'h0001 &&ARADDR_M1[31:16]!=16'h0002 &&ARADDR_M1[31:16]!=16'h1000 &&ARADDR_M1[31:24]!=8'h20 &&ARADDR_M1[31:16]!=16'h3000)
	     NS_R = Default_Slave;*/
	  else NS_R = ReadAddr_M1;
	end
    ReadData_M1S0 :begin
	  if(RVALID_M1 && RREADY_M1) NS_R = IDLE;
	  else NS_R = ReadData_M1S0;
	end			
    ReadData_M1S1 :begin
	  if(RVALID_M1 && RREADY_M1) NS_R = IDLE;
	  else NS_R = ReadData_M1S1;
	end			
    ReadData_M1S2 :begin
	  if(RVALID_M1 && RREADY_M1) NS_R = IDLE;
	  else NS_R = ReadData_M1S2;
	end			
    ReadData_M1S3 :begin
	  if(RVALID_M1 && RREADY_M1) NS_R = IDLE;
	  else NS_R = ReadData_M1S3;
	end	
    ReadData_M1S4 :begin
	  if(RVALID_M1 && RREADY_M1) NS_R = IDLE;
	  else NS_R = ReadData_M1S4;
	end		
    ReadData_M1S5 :begin
	  if(RVALID_M1 && RREADY_M1) NS_R = IDLE;
	  else NS_R = ReadData_M1S5;
	end		
    ReadAddr_M0 :begin
	  if(ARVALID_M0 && ARREADY_M0) begin
	     if(ARADDR_M0[31:16]==16'h0000)
	       NS_R = ReadData_M0S0; 
	     else if(ARADDR_M0[31:16]==16'h0001)
	       NS_R = ReadData_M0S1; 
	     else if(ARADDR_M0[31:16]==16'h0002)
	       NS_R = ReadData_M0S2; 		   
	     else if(ARADDR_M0[31:16]==16'h1000)
	       NS_R = ReadData_M0S3; 		   		   
	     else if(ARADDR_M0[31:24]==8'h20)
	       NS_R = ReadData_M0S4; 		   		   
		 else NS_R = Default_Slave;
	  end
	  else NS_R = ReadAddr_M0;
	end
    ReadData_M0S0 :begin
	  if(RVALID_M0 && RREADY_M0) NS_R = IDLE;
	  else NS_R = ReadData_M0S0;
	end			
    ReadData_M0S1 :begin
	  if(RVALID_M0 && RREADY_M0) NS_R = IDLE;
	  else NS_R = ReadData_M0S1;
	end	
    ReadData_M0S2 :begin
	  if(RVALID_M0 && RREADY_M0) NS_R = IDLE;
	  else NS_R = ReadData_M0S2;
	end			
    ReadData_M0S3 :begin
	  if(RVALID_M0 && RREADY_M0) NS_R = IDLE;
	  else NS_R = ReadData_M0S3;
	end	
    ReadData_M0S4 :begin
	  if(RVALID_M0 && RREADY_M0) NS_R = IDLE;
	  else NS_R = ReadData_M0S4;
	end					
    Default_Slave : NS_R = IDLE;	
	default : begin
	  NS_R = IDLE;
	end
  endcase
end

endmodule


















