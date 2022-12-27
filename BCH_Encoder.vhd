--BCH Encoder For DVB-T2

Library IEEE;
Use IEEE.STD_LOGIC_1164.All;

Entity BCH_Encoder Is

	Generic(
		Kbch			:	INTEGER									:=	12432 ;
		Nbch			:	INTEGER									:=	12600 ;
		Polynomial	:	STD_LOGIC_VECTOR(192 downto 0)	:= "0000000000000000000000001010000000110001011011011111010101001100001101001101100100110001011001101001000111010001110010000011010010101001010001111111001111101011111010001000110010000010110100101"
	);
	
	Port(
		Clock					:	IN		STD_LOGIC ;
		Clock_Enable		:	IN		STD_LOGIC ;
		Synchronous_Reset	:	IN		STD_LOGIC ;
		Input_Data			:	IN		STD_LOGIC ;
		Valid_Input_Data	:	IN		STD_LOGIC ;
		Output_Data			:	OUT	STD_LOGIC ;
		Valid_Output_Data	:	OUT	STD_LOGIC
	);
		
End BCH_Encoder ;

Architecture Behavioral Of BCH_Encoder Is
	
	Signal	Clock_Enable_Register			:	STD_LOGIC										:= '0' ;
	Signal	Synchronous_Reset_Register		:	STD_LOGIC										:= '0' ;
	Signal	Input_Data_Register				:	STD_LOGIC										:= '0' ;
	Signal	Valid_Input_Data_Register		:	STD_LOGIC										:= '0' ;
	Signal	Output_Data_Register				:	STD_LOGIC										:= '0' ;
	Signal	Valid_Output_Data_Register		:	STD_LOGIC										:= '0' ;
	
--	Generator Or Divisor Or Polynomial
	Constant	Generator							:	STD_LOGIC_VECTOR(Nbch-Kbch-1 downto 0)	:= Polynomial(Nbch-Kbch-1 downto 0) ;
--	%%%%%%%%%%%%%%%%%%%%
	
--	Remainder
	Signal	Remainder							:	STD_LOGIC_VECTOR(Nbch-Kbch-1 downto 0)	:= (others=>'0') ;
--	%%%%%%%%%
	
	Signal	Valid_SRL							:	STD_LOGIC_VECTOR(Nbch-Kbch-1 downto 0)	:= (others=>'0') ;
	
Begin
	
	Process(Clock)
	Begin
		
		If Rising_Edge(Clock) Then
		
		--	Registering Input Ports	
			Input_Data_Register			<=	Input_Data ;
			Valid_Input_Data_Register	<=	Valid_Input_Data ;
			Clock_Enable_Register		<=	Clock_Enable ; 
			Synchronous_Reset_Register	<= Synchronous_Reset ;
		-- %%%%%%%%%%%%%%%%%%%%%%%	
			
		--	Reset
			If (Synchronous_Reset_Register='1') Then
			
				Valid_SRL							<=	(Others=>'0') ;
				Remainder							<=	(Others=>'0') ;
				Output_Data_Register				<= '0' ;
				Valid_Output_Data_Register		<=	'0' ;
		-- %%%%%
			
			Elsif (Clock_Enable_Register='1') Then
					
				--	Valid_SRL Is A Shift Register To Specify Valid Output Data
					Valid_SRL						<=	Valid_SRL(Nbch-Kbch-2 Downto 0) & Valid_Input_Data_Register ;
					Valid_Output_Data_Register	<=	Valid_SRL(Nbch-Kbch-1) AND (NOT Valid_Input_Data_Register) ;
				--	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				
				If Valid_Input_Data_Register = '1' Then
				
				--	Computing BCH Code
					Remainder(0)		<=	Remainder(Nbch-Kbch-1) XOR Input_Data_Register ;
					For i In 1 To (Nbch-Kbch-1) Loop
						Remainder(i)	<=	(Remainder(Nbch-Kbch-1) AND Generator(i)) XOR Remainder(i-1) ;
					End Loop ;
				--	%%%%%%%%%%%%%%%%%%
					
				Else
					
					Remainder				<=	Remainder(Nbch-Kbch-2 Downto 0) & '0' ;
					Output_Data_Register	<=	Remainder(Nbch-Kbch-1) ;
					
				End If ;
			
			End If ;
			
		End If;
		
	End Process;
	
--	Registering Output Ports
	Output_Data			<=	Output_Data_Register ;
	Valid_Output_Data	<=	Valid_Output_Data_Register ;
-- %%%%%%%%%%%%%%%%%%%%%%%%	

End Behavioral;