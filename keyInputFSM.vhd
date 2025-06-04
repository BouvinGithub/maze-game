	library IEEE;
	use IEEE.std_logic_1164.all;

	entity keyInputFSM is 
		port(key, reset, CLOCK_50: in std_logic;
				press: out std_logic);
	end entity;

	architecture keyInputFSM_arch of keyInputFSM is 
		
		type statetype is (sInit, sWait, sPress, sHold);
		signal current_state, next_state : statetype; 
		
	begin

		NextStateLogic : process (current_state, key)
		begin
			case current_state is 
				when sInit => 
					next_state <= sWait;
				when sWait =>
					if (x='0') then
						next_state <= sTrip;
					else 
						next_state <= sWait;
					end if;
				when sTrip =>
					if (x='1') then
						next_state <= sInc;
					else
						next_state <= sTrip;
					end if;
				when sInc =>
					if (CNTeq50 = '0') then
						next_state <= sWait;
					elsif (CNTeq50 = '1') then 
						next_state <= sFull;
					else 
						next_state <= sInit;
					end if;
				when sFull =>
					next_state <= sFull;
				when others =>
					next_state <= sInit;
			end case;
		end process;
		
		StateMemory : process (CLOCK_50, rst)
		begin
			if (rst = '0') then 
				current_state <= sInit;
			elsif (rising_edge(CLOCK_50)) then
				current_state <= next_state;
			end if;
		end process;
		
		OutputLogic : process (current_state)
		begin
			case current_state is
				when sInit => 
					state_vec <= "00001";
					Reset_D <= '0';
					Full <= '0';
				when sWait =>
					state_vec <= "00010";
					Reset_D <= '1';
					ld_Occ <= '1';
					ld_CNT <= '0';
				when sTrip =>
					state_vec<= "00100";
				when sInc =>
					state_vec<= "01000"; 
					ld_Occ <= '0';
					ld_CNT <= '1';
				when sFull =>
					state_vec <= "10000";
					Full <= '1';
				when others => null;
			end case;
		end process;

	end architecture;

