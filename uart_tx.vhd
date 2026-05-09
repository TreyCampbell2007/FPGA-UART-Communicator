library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- NOTES
-- Need to create a baud counter 
-- Need to create shift register for the bits to send one at a time
-- Need to create a finite state machine for the different states of UART communication

entity uart_tx is
    Port (clk : in std_logic;
          inputs : in std_logic_vector(7 downto 0);
          tx_start : in std_logic;
          tx_busy : out std_logic; -- High while transmitting to prevent multiple button presses
          tx : out std_logic);
end uart_tx;

architecture Behavioral of uart_tx is
type t_state is (IDLE, START, DATA, STOP);
signal state : t_state := IDLE;

signal baud_rate : integer := 115200; 
signal clock_rate : integer := 100000000; -- Used to calculate the counter number
signal counter : integer;
signal shift_reg : std_logic_vector(9 downto 0) := (others => '1');
signal state_index : integer range 0 to 9 := 0;
begin

tx <= shift_reg(0); -- Takes the LSB of the shift_reg

process(clk)
begin
    if rising_edge(clk) then
        case state is
            when IDLE =>
                shift_reg <= (others => '1'); -- Keeps outputting 1 when idle
                counter <= 0;
                tx_busy <= '0';
                state_index <= 0;
                if tx_start = '1' then
                    shift_reg <= '1' & inputs(7 downto 0) & '0';
                    state <= START;
                    tx_busy <= '1'; -- Sets tx_busy so nothing can happen with other inputs
                end if;
            
            when START =>
                if counter = (clock_rate/baud_rate) - 1 then
                    counter <= 0;
                    shift_reg <= '1' & shift_reg(9 downto 1); -- shifts the register
                    state <= DATA;
                else
                    counter <= counter + 1;
                end if;
                
            when DATA =>
                if counter = (clock_rate/baud_rate) - 1 then
                    if state_index = 7 then
                        state <= STOP;
                    else
                        counter <= 0;
                        shift_reg <= '1' & shift_reg(9 downto 1); -- shifts the register
                        state_index <= state_index + 1;
                    end if;
                else
                    counter <= counter + 1;
                end if;
                    
            when STOP =>
                if counter = (clock_rate/baud_rate) - 1 then
                    counter <= 0;
                    state <= IDLE; -- Don't need to shift register since it automatically does in IDLE
                else   
                    counter <= counter + 1;
                end if;
        end case;
    end if;                  
end process;
end Behavioral;
