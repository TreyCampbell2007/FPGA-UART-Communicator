library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Need to allow the user to change input via switches
-- Need to allow the user to start the output using buttons
entity Top is
    Port(CLK100MHZ : in std_logic;  
         SW : in std_logic_vector(7 downto 0);
         start : in std_logic; -- Map to button
         tx : out std_logic);
end entity;   
    
architecture Behavioral of Top is

component uart_tx is
    Port (clk : in std_logic;
          inputs : in std_logic_vector(7 downto 0);
          tx_start : in std_logic;
          tx_busy : out std_logic; 
          tx : out std_logic);
end component;

signal debounce_counter : integer := 0;
signal counting : std_logic := '0';
signal start_prev : std_logic := '0';
signal tx_start : std_logic := '0';
signal busy : std_logic;
begin
-- Component Instantiation
    uart_transfer : uart_tx
        port map(
            clk => CLK100MHZ,
            inputs => SW,
            tx_start => tx_start,
            tx_busy => busy,
            tx => tx
        );    

process(CLK100MHZ)
begin
-- Debouncer
if rising_edge(CLK100MHZ) then
    start_prev <= start;
        if counting = '1' then
            if debounce_counter = 20000000 and busy = '0' then
                counting <= '0';
                tx_start <= '1';
            else
                tx_start <= '0';
                debounce_counter <= debounce_counter + 1;
            end if;
        elsif start = '1' and start_prev = '0' then -- Starts the counting
            counting <= '1';
            debounce_counter <= debounce_counter + 1;
        elsif start = '0' then -- Only transitions back when its zero
            tx_start <= '0';
            debounce_counter <= 0;
        end if;
end if;
end process;      
end architecture;
