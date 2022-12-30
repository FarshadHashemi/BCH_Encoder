Library IEEE ;
Use IEEE.STD_LOGIC_1164.All ;

Entity BCH_Encoder Is

	Generic(
		Kbch			:	Integer									:=	12432 ;
		Nbch			:	Integer									:=	12600 ;
		Polynomial	:	STD_Logic_Vector(192 downto 0)	:= "0000000000000000000000001010000000110001011011011111010101001100001101001101100100110001011001101001000111010001110010000011010010101001010001111111001111101011111010001000110010000010110100101"
	);
	
	Port(
		Clock					:	In		STD_Logic ;
		Clock_Enable		:	In		STD_Logic ;
		Synchronous_Reset	:	In		STD_Logic ;
		Input_Data			:	In		STD_Logic ;
		Valid_Input_Data	:	In		STD_Logic ;
		Output_Data			:	Out	STD_Logic ;
		Valid_Output_Data	:	Out	STD_Logic
	);
		
End BCH_Encoder ;

Architecture Behavioral Of BCH_Encoder Is
	
	Signal	Clock_Enable_Register			:	STD_Logic										:= '0' ;
	Signal	Synchronous_Reset_Register		:	STD_Logic										:= '0' ;
	Signal	Input_Data_Register				:	STD_Logic										:= '0' ;
	Signal	Valid_Input_Data_Register		:	STD_Logic										:= '0' ;
	Signal	Output_Data_Register				:	STD_Logic										:= '0' ;
	Signal	Valid_Output_Data_Register		:	STD_Logic										:= '0' ;
	
--	Generator Or Divisor Or Polynomial
	Constant	Generator							:	STD_Logic_Vector(Nbch-Kbch-1 Downto 0)	:= Polynomial(Nbch-Kbch-1 Downto 0) ;
--	%%%%%%%%%%%%%%%%%%%%
	
--	Remainder
	Signal	Remainder							:	STD_Logic_Vector(Nbch-Kbch-1 Downto 0)	:= (Others=>'0') ;
--	%%%%%%%%%
	
	Signal	Valid_SRL							:	STD_Logic_Vector(Nbch-Kbch-1 Downto 0)	:= (Others=>'0') ;
	
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
				
				If Valid_Input_Data_Register='1' Then
				
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
		
	End Process ;
	
--	Registering Output Ports
	Output_Data			<=	Output_Data_Register ;
	Valid_Output_Data	<=	Valid_Output_Data_Register ;
-- %%%%%%%%%%%%%%%%%%%%%%%%	

End Behavioral ;
