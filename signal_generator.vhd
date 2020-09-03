LIBRARY IEEE;                                                  
USE IEEE.STD_LOGIC_1164.ALL;                     
USE IEEE.std_logic_unsigned.ALL;
                   
ENTITY signal_generator IS                                        
     PORT
     (
			--system IO
			sysclk					:in STD_LOGIC;  	--50MHz internal clock                                 
			heartbeat_led			:out STD_LOGIC;
			reset_Sw					:in STD_LOGIC; --active low
			done_PIN					:out STD_LOGIC;
			done_LED					:out STD_LOGIC;
			--generator IO
			--output toggling signals to TB
			USRGATE1          	: out  std_logic;
			USRGATE2          	: out  std_logic;
			Bm_Update         	: out  std_logic;
			TR_Gate           	: out  std_logic;
			Wvf_Cmd_Sync      	: out  std_logic;
			Last_BTI_Gat      	: out  std_logic;
			AD_Gat            	: out  std_logic;
			NBWB_Sw_Stat      	: out  std_logic;
			TD_Sw_Stat        	: out  std_logic;
			NB1_Sw_Stat       	: out  std_logic;
			NB2_Sw_Stat       	: out  std_logic;
			NB3_Sw_Stat       	: out  std_logic;
			NB4_Sw_Stat       	: out  std_logic;
			AB_Select_In      	: out  std_logic;	-- 1 = Select A,     0 = Select B
			Sum_path_select_in	: out  std_logic;	-- 1 = Narrow Band,  0 = Wide band
			out_Clk           	: out  std_logic;	
			resetF            	: out  std_logic	-- Power ON reset POR, active low, pulled HIGH
     );     
END signal_generator;



                                              
ARCHITECTURE rtl OF signal_generator IS 

----------------
--Heartbeat LED
constant	c_CNT_2HZ	:	natural := 125000000;
signal r_CNT_2HZ		:	natural	range 0 to c_CNT_2HZ;   
signal r_TOGGLE_2HZ	:	std_logic	:= '0';
----------------

--Clock Translation
--Note, 50 MHz clk is apparently okay, but in tb, clk is 80 MHz


--Global clock
constant c_TIMELINE	: natural := 63000412 + 1;--29000412+1; 
signal r_GLOBAL_CLK_CNT	: natural range 0 to c_TIMELINE-1;
signal r_DONE			:	std_logic	:= '0';

--Stim_Proc

signal clk 				: std_logic;
signal resetF_status	: std_logic; --active low
signal r2_DONE			: std_logic := '0';
                                    
BEGIN                                                                  
--System process
----------------

	-------------
	--Heartbeat
	-------------
	HEARTBEAT:PROCESS(sysclk)
	begin
		if rising_edge(sysclk) then
			if r_CNT_2HZ = c_CNT_2HZ-1 then
					r_TOGGLE_2HZ <= not r_TOGGLE_2HZ;
					r_CNT_2HZ <= 0;
			else
					r_CNT_2HZ <= r_CNT_2HZ + 1;
			end if;
		end if;
	end process HEARTBEAT;  
	
	heartbeat_led <= r_TOGGLE_2HZ and reset_SW;
	
	
	------------
	--Clock Translation
	------------
	--Note, 50 MHz clk is apparently okay, but in tb, clk is 80 MHz
	Clk <= sysclk;
	out_Clk <= clk;
	--resetF <= resetF_status and reset_SW;
	resetF <= resetF_status;
	
	------------
	--Global_clock_counter
	GLOBAL_CLK_CNT:PROCESS(clk)
	begin
		if rising_edge(clk) then
			if r_GLOBAL_CLK_CNT = c_TIMELINE-1 then
				r_GLOBAL_CLK_CNT <= 0; --reset
			else
			r_GLOBAL_CLK_CNT <= r_GLOBAL_CLK_CNT + 1;
			end if;
		end if;
	end process GLOBAL_CLK_CNT;
	done_LED <= r2_DONE; --@114500412+1 clk cycles..
	done_PIN <= r2_DONE;
----------------

--Output processes
----------------
--	clk_80m_process: process	--12.5/2 = 6.25
--	begin
--		  clk_80M <= '1';
--		  wait for 6.25 ns;
--		  clk_80M <= '0';
--		  wait for 6.25 ns;
--	end process;
--	
--	
--	 nb_wb_status_process: process (clk, resetf_status)
--	 begin                       	
--		 if (resetf_status = '0') then 
--			  --nb_wb_status  <= '0';  --TODO
--		 elsif (clk 'event and  clk = '1') then  --rising edge
--			  if (nbwb_sw_slct1 = '1') then    
--				  nb_wb_status  <= '0';   -- SW in position controled by select1 
--			 elsif (nbwb_sw_slct2 = '1')then	 
--				  nb_wb_status  <= '1';	  -- SW in position controled by select2  
--			 end if;            
--		 end if;                      
--	 end process ;       
	
	
--	 td_status_process: process (clk, resetf_status)
--	 begin                       	
--		 if (resetf_status = '0') then 
--			  td_status  <= '0';  
--		 elsif (clk 'event and  clk = '1') then  
--			  if (td_sw_slct1 = '1') then    
--				  td_status  <= '0';   -- SW in position controled by select1 
--			 elsif (td_sw_slct2 = '1')then	 
--				  td_status  <= '1';	 -- SW in position controled by select2  
--			 end if;            
--		 end if;                      
--	 end process ;             
	
	
--	nb1_status_process: process (clk, resetf_status)
--	begin
--		if (resetf_status = '0') then
--			 nb1_status  <= '0';						
--		elsif (clk 'event and clk = '1') then 
--			  if (NB1_Sw_Slct1 = '1') then 
--				 nb1_status  <= '0';   -- SW in position controled by select1
--			 elsif (NB1_Sw_Slct2 = '1')then			
--				 nb1_status  <= '1';	 -- SW in position controled by select2 	      
--			 end if;
--		end if;              
--	end process ;   
--	
--	nb2_status_process: process (clk, resetf_status)
--	begin
--		if (resetf_status = '0') then
--			 nb2_status  <= '0';						
--		elsif (clk 'event and clk = '1') then 
--			  if (NB2_Sw_Slct1 = '1')then 
--				 nb2_status  <= '0';   -- SW in position controled by select1
--			 elsif (NB2_Sw_Slct2 = '1')then			
--				 nb2_status  <= '1';	 -- SW in position controled by select2 	      
--			 end if;
--		end if;              
--	end process ;   
	
--	nb3_status_process: process (clk, resetf_status)
--	begin
--		if (resetf_status = '0') then
--			 nb3_status  <= '0';						
--		elsif (clk_80m 'event and clk = '1') then 
--			  if (NB3_Sw_Slct1 = '1')then 
--				 nb3_status  <= '0';   -- SW in position controled by select1
--			 elsif (NB3_Sw_Slct2 = '1')then			
--				 nb3_status  <= '1';	  -- SW in position controled by select2 	      
--			 end if;
--		end if;              
--	end process ;   
	
--	nb4_status_process: process (clk, resetf_status)
--	begin
--		if (resetf_status = '0') then
--			 nb4_status  <= '0';						
--		elsif (clk 'event and clk = '1') then 
--			  if (NB4_Sw_Slct1 = '1')then 
--				 nb4_status  <= '0';   -- SW in position controled by select1
--			 elsif (NB4_Sw_Slct2 = '1')then			
--				 nb4_status  <= '1';	  -- SW in position controled by select12 	      
--			 end if;
--		end if;              
--	end process ;   
----------------

----------------
	STIM_PROC:PROCESS(sysclk)
	begin
		if r_GLOBAL_CLK_CNT >= 0 then
			USRGATE1        <= '0';
			USRGATE2        <= '0';
			Bm_Update       <= '0';
			TR_Gate         <= '0';
			Wvf_Cmd_Sync    <= '0';
			Last_Bti_Gat    <= '0';
			AD_Gat          <= '0';
			AB_Select_In    <= '1';    -- low to high, and high at power up will cause SW select 1 outputs to high (20 ms pulse
			Sum_path_select_in <= '0'; -- high to low, and low at power up will cause NB/WB SW select 1 output to high
			resetf_status <= '0';	--active low	
			
			--wait for clk_period*10;	--10 clock cycles (10) --wait for reset to de-assert
			if r_GLOBAL_CLK_CNT >= 10 then
			
				--clock period = 2x10^-8s -> 2x10^-5ms 
				
				r2_DONE <= '1';
				resetf_status <= '1';	
				
				--wait for 140 ms;     --7e6 clock cycles later (7000010)    -- watch the CPLD initialize with SW control outputs 
				--wait for clk_period*100;	--100 clock cycles	(7000110)
				if r_GLOBAL_CLK_CNT >= 7000110 then 
					usrgate1        <= '1';
					usrgate2        <= '1';
					bm_update       <= '1';
					tr_gate         <= '1';
					wvf_cmd_sync    <= '1';
					last_bti_gat    <= '1';
					ad_gat          <= '1';                                    
																															
					AB_Select_In    <= '0';        -- high to low transition  	  
					Sum_path_select_in <= '0';     -- low to high transition       
					
					--wait for 130 ms; --130/(2e-5) -> 65e5 clock cycles later  (13500110)
					--wait until (rising_edge(clk_80M));	--one clock cycle			(13500111)					 
					--wait for clk_period * 20;	   --20 clock cycles (13500131)
					
					if r_GLOBAL_CLK_CNT >= 13500131 then
						usrgate1        <= '0';
						usrgate2        <= '0';
						bm_update       <= '0';
						tr_gate         <= '0';
						wvf_cmd_sync    <= '0';
						last_bti_gat    <= '0';
						ad_gat          <= '0';
						
						--wait for 5 ms;  --5/2e-5 -> 25e4 clock cycles later (13750131)               		    
						--wait for clk_period * 20;	   --20 clock cycles (13750151)
						if r_GLOBAL_CLK_CNT >= 13750151 then
							usrgate1        <= '1';
							usrgate2        <= '1';
							bm_update       <= '1';
							tr_gate         <= '1';
							wvf_cmd_sync    <= '1';
							last_bti_gat    <= '1';
							ad_gat          <= '1';
												 
							--wait for 5 ms;  --5/2e-5 -> 25e4 clock cycles later (14000151)
							--wait for clk_period * 20;	   --20 clock cycles		(14000171)
							if r_GLOBAL_CLK_CNT >= 14000171 then
								usrgate1        <= '0';
								usrgate2        <= '0';
								bm_update       <= '0';
								tr_gate         <= '0';
								wvf_cmd_sync    <= '0';
								last_bti_gat    <= '0';
								ad_gat          <= '0';
								
								--wait for 5 ms;    --5/2e-5 -> 25e4 clock cycles later  (14250171)
								--wait for clk_period * 200;	   --200 clock cycles		(14250371)
								if r_GLOBAL_CLK_CNT >= 14250371 then
									usrgate1        <= '1';
									usrgate2        <= '1';
									bm_update       <= '1';
									tr_gate         <= '1';
									wvf_cmd_sync    <= '1';
									last_bti_gat    <= '1';
									ad_gat          <= '1';
									
									--wait for 5 ms;        --5/2e-5 -> 25e4 clock cycles later  (14500371)                    
									--wait for clk_period * 20;	   --20 clock cycles (14500391)
									if r_GLOBAL_CLK_CNT >= 14500391 then
										AB_Select_In    <= '1';    -- low to high, and high at power up will cause SW select 1 outputs to high (20 ms pulse
										Sum_path_select_in <= '0'; -- high to low, and low at power up will cause NB/WB SW select 1 output to high        
										--wait for clk_period * 20;	     --20 clock cycles  (14500411) 
										if r_GLOBAL_CLK_CNT >= 14500411 then
											Sum_path_select_in <= '0';         -- high to low transition  
											if r_GLOBAL_CLK_CNT >= 14500412 then
												r2_DONE <= '0';
		--										--light on for one second
												if r_GLOBAL_CLK_CNT >=29000412 then
													r2_DONE <= '0';
--													
--													--wait for 290 ms
													if r_GLOBAL_CLK_CNT >= 58000412 then
														sum_path_select_in <= '1';
														
														--wait for 50 ms
														if r_GLOBAL_CLK_CNT >= 60500412 then
															AB_Select_In    <= '0';
															
															--wait for 50 ms
															if r_GLOBAL_CLK_CNT >= 63000412 then
																AB_Select_In    <= '0';
															end if;
														end if;
													end if;
												end if;
											end if;
										end if;
									end if;
								end if;
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process STIM_PROC;
----------------
               
END rtl;