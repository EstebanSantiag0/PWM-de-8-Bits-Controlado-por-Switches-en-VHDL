----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:15:06 03/24/2026 
-- Design Name: 
-- Module Name:    EightBitPWM - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EightBitPWM is
    Port ( 
      clk : in  STD_LOGIC;
      switches : in STD_LOGIC_VECTOR(7 downto 0);
      led: out STD_LOGIC
      );
end EightBitPWM;

architecture Behavioral of EightBitPWM is
begin
   process (clk)
      variable rf: integer range 0 to 2000 := 0;
      variable flag: integer:=0;
      variable cnt: unsigned(7 downto 0):="00000000";
      variable reverse_cnt: unsigned(7 downto 0):= "11111111";
   begin
      if rising_edge(clk) then
         if rf = 2000 then
            rf :=0 ;
 
            if cnt = "11111111" and flag = 0 then
               flag := 1;
               led <= '0';
            end if;
            if cnt = "00000000" and flag = 1 then
               flag := 0;
               led <= '0';
            end if;
            
            if flag = 0 then
               if switches = std_logic_vector(cnt) then
                  led <= '1';
               end if;
               cnt := cnt + 1;
            else
               if switches = std_logic_vector(reverse_cnt - cnt) then
                  led <= '1';
               end if;
               cnt := cnt - 1;
            end if;
         else
            rf := rf + 1;
         end if;
      end if;
   end process;
end Behavioral;

