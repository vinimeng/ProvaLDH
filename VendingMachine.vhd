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

                    IF (TranslatedKeyboardOutput = "1010") THEN -- Botão Clear
                        AlgorismPosition <= '0';
                        FinalKeyboardOutput <= "11111111";
                    ELSIF (AlgorismPosition = '1' AND FinalKeyboardOutput(7 DOWNTO 4) /= "1111" AND TranslatedKeyboardOutput = "1011") THEN -- Botão OK e Último Algorismo já preenchido
                        CASE FinalKeyboardOutput IS
                            WHEN "00000000" => SelectedItem <= "0000"; -- 00
                            WHEN "00000001" => SelectedItem <= "0001"; -- 01
                            WHEN "00000010" => SelectedItem <= "0010"; -- 02
                            WHEN "00000011" => SelectedItem <= "0011"; -- 03
                            WHEN "00000100" => SelectedItem <= "0100"; -- 04
                            WHEN "00000101" => SelectedItem <= "0101"; -- 05
                            WHEN "00000110" => SelectedItem <= "0110"; -- 06
                            WHEN "00000111" => SelectedItem <= "0111"; -- 07
                            WHEN "00001000" => SelectedItem <= "1000"; -- 08
                            WHEN "00001001" => SelectedItem <= "1001"; -- 09
                            WHEN "00010000" => SelectedItem <= "1010"; -- 10
                            WHEN "00010001" => SelectedItem <= "1011"; -- 11
                            WHEN "00010010" => SelectedItem <= "1100"; -- 12
                            WHEN "00010011" => SelectedItem <= "1101"; -- 13
                            WHEN "00010100" => SelectedItem <= "1110"; -- 14
                            WHEN "00010101" => SelectedItem <= "1111"; -- 15
                            WHEN OTHERS => SelectedItem <= "ZZZZ";
                        END CASE;
                        UnlockDoor <= '1';
                    ELSE
                        IF (AlgorismPosition = '0') THEN
                            CASE TranslatedKeyboardOutput IS
                                WHEN "0000" => -- 0
                                    FinalKeyboardOutput (3 DOWNTO 0) <= TranslatedKeyboardOutput;
                                    AlgorismPosition <= '1';
                                WHEN "0001" => -- 1
                                    FinalKeyboardOutput (3 DOWNTO 0) <= TranslatedKeyboardOutput;
                                    AlgorismPosition <= '1';
                                WHEN OTHERS =>
                                    FinalKeyboardOutput (3 DOWNTO 0) <= "1111";
                                    AlgorismPosition <= '0';
                            END CASE;
                        ELSE
                            CASE TranslatedKeyboardOutput IS
                                WHEN "0000" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 0 
                                WHEN "0001" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 1
                                WHEN "0010" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 2
                                WHEN "0011" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 3
                                WHEN "0100" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 4
                                WHEN "0101" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 5
                                WHEN "0110" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 6
                                WHEN "0111" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 7
                                WHEN "1000" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 8
                                WHEN "1001" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 9
                                WHEN OTHERS => FinalKeyboardOutput (7 DOWNTO 4) <= "1111";
                            END CASE;
                        END IF;
                    END IF;
                END IF;
            ELSE
                IF (AlgorismPosition = '1' AND FinalKeyboardOutput(7 DOWNTO 4) /= "1111" AND KeyboardOutput = "1011") THEN
                    UnlockDoor <= '0';
                    AlgorismPosition <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;
END logic;
