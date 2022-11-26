LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY Keyboard IS
    PORT (
        clk : IN STD_LOGIC;
        col : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        d : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        dav : OUT STD_LOGIC
    );
END Keyboard;
ARCHITECTURE logic OF Keyboard IS
    SIGNAL freeze : STD_LOGIC;
    SIGNAL data : STD_LOGIC_VECTOR (3 DOWNTO 0);
BEGIN
    PROCESS (clk)
        VARIABLE ring : STD_LOGIC_VECTOR (3 DOWNTO 0);
    BEGIN
        IF (clk'EVENT AND clk = '1') THEN
            IF freeze = '0' THEN
                CASE ring IS
                    WHEN "1110" => ring := "1101";
                    WHEN "1101" => ring := "1011";
                    WHEN "1011" => ring := "0111";
                    WHEN "0111" => ring := "1110";
                    WHEN OTHERS => ring := "1110";
                END CASE;
            END IF;
            dav <= freeze;
        END IF;
        CASE ring IS
            WHEN "1110" => data(3 DOWNTO 2) <= "00";
            WHEN "1101" => data(3 DOWNTO 2) <= "01";
            WHEN "1011" => data(3 DOWNTO 2) <= "10";
            WHEN "0111" => data(3 DOWNTO 2) <= "11";
            WHEN OTHERS => data(3 DOWNTO 2) <= "00";
        END CASE;
        CASE col IS
            WHEN "1110" => data(1 DOWNTO 0) <= "00";
                freeze <= '1';
            WHEN "1101" => data(1 DOWNTO 0) <= "01";
                freeze <= '1';
            WHEN "1011" => data(1 DOWNTO 0) <= "10";
                freeze <= '1';
            WHEN "0111" => data(1 DOWNTO 0) <= "11";
                freeze <= '1';
            WHEN OTHERS => data(1 DOWNTO 0) <= "00";
                freeze <= '0';
        END CASE;
        IF freeze = '1' THEN
            d <= data;
        ELSE
            d <= "ZZZZ";
        END IF;
    END PROCESS;
END logic;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY VendingMachine IS
    PORT (
        Clock : IN STD_LOGIC;
        MoneyRead : IN STD_LOGIC;
        Column : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        SelectedItem : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        UnlockDoor : OUT STD_LOGIC
    );
END VendingMachine;
ARCHITECTURE logic OF VendingMachine IS
    COMPONENT Keyboard IS
        PORT (
            clk : IN STD_LOGIC;
            col : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            d : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            dav : OUT STD_LOGIC
        );
    END COMPONENT;
    SIGNAL KeyboardOutput : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1111";
    SIGNAL TranslatedKeyboardOutput : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1111";
    SIGNAL FinalKeyboardOutput : STD_LOGIC_VECTOR (7 DOWNTO 0) := "11111111";
    SIGNAL AlgorismPosition : STD_LOGIC := '0';
    SIGNAL CanRead : STD_LOGIC := '0';
BEGIN
    U1 : Keyboard PORT MAP(clk => Clock, col => Column, d => KeyboardOutput, dav => CanRead);

    PROCESS (Clock)
    BEGIN
        IF (Clock'EVENT AND Clock = '1') THEN
            IF (MoneyRead = '1') THEN
                IF (CanRead = '1') THEN
                    CASE KeyboardOutput IS
                        WHEN "0000" => TranslatedKeyboardOutput <= "0000"; -- 0
                        WHEN "0001" => TranslatedKeyboardOutput <= "0001"; -- 1
                        WHEN "0010" => TranslatedKeyboardOutput <= "0010"; -- 2
                        WHEN "0011" => TranslatedKeyboardOutput <= "0011"; -- 3
                        WHEN "0100" => TranslatedKeyboardOutput <= "0100"; -- 4
                        WHEN "0101" => TranslatedKeyboardOutput <= "0101"; -- 5
                        WHEN "0110" => TranslatedKeyboardOutput <= "0110"; -- 6
                        WHEN "0111" => TranslatedKeyboardOutput <= "0111"; -- 7
                        WHEN "1000" => TranslatedKeyboardOutput <= "1000"; -- 8
                        WHEN "1001" => TranslatedKeyboardOutput <= "1001"; -- 9
                        WHEN "1010" => TranslatedKeyboardOutput <= "1010"; -- Clear
                        WHEN "1011" => TranslatedKeyboardOutput <= "1011"; -- Ok
                        WHEN OTHERS => TranslatedKeyboardOutput <= "1111";
                    END CASE;

                    IF (TranslatedKeyboardOutput = "1010") THEN
                        AlgorismPosition <= '0';
                        FinalKeyboardOutput <= "11111111";
                    ELSIF (FinalKeyboardOutput(7 DOWNTO 4) /= "1111" AND TranslatedKeyboardOutput = "1011") THEN
                        UnlockDoor <= '1';
                    ELSE
                        IF (AlgorismPosition = '0') THEN
                            FinalKeyboardOutput (3 DOWN 0) <= TranslatedKeyboardOutput;
                            AlgorismPosition = '1';
                        ELSE
                            FinalKeyboardOutput (7 DOWN 4) <= TranslatedKeyboardOutput;
                        END IF;
                    END IF;

                    CanRead <= '0';
                END IF;
            ELSE
                IF (AlgorismPosition = '1' AND UnlockDoor = '1' AND KeyboardOutput = "1011") THEN
                    UnlockDoor <= '0';
                    AlgorismPosition <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;
END logic;
