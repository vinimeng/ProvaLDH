-- Vinícius Meng
-- 0250583

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

-- Acima toda a lógica para capturar teclado conforme visto em aula anteriormente

-- Abaixo toda a lógica para a máquina automática de vendas
-- A máquina vende 16 produtos diferentes organizados num grid 4x4
-- O teclado dá máquina também é organizado num grid 4x4, mas a quarta linha é ignorada, dessa forma ficando um grid 4x3:

-- 0  1   2   3
-- 4  5   6   7
-- 8  9 Clear Ok

-- Pessoa insere o dinheiro, máquina libera teclado para uso
-- Pessoa insere primeiro dígito, depois o segundo dígito do produto que deseja, os produtos possíveis são:

-- 00 01 02 03
-- 04 05 06 07
-- 08 09 10 11
-- 12 13 14 15

-- O produto só é confirmado quando a pessoa digita dois dígitos e pressiona Ok
-- Caso a pessoa erre o dígito, ela pode apertar em Clear, que limpa o que havia sido pressionado até o momento
-- Quando a pessoa apertar Ok com dois dígitos possíveis pressionados, um sinal para a abertura da porta de retirada de produtos será mandado
-- Além de enviar qual produto deve cair na porta de retirada

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY VendingMachine IS
    PORT (
        Clock : IN STD_LOGIC; -- clock de entrada
        MoneyRead : IN STD_LOGIC; -- entrada que indica se foi lido dinheiro, o que libera para digitar o número do produto
        Column : IN STD_LOGIC_VECTOR (3 DOWNTO 0); -- entradas que indicam qual coluna do teclado foi apertada
        SelectedItem : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- saídas que indicam qual produto foi selecionado (4 bits representando 0 até 15)
        UnlockDoor : BUFFER STD_LOGIC -- saída que indica que a porta pode ser aberta (ela fica destrancada)
    );
END VendingMachine;
ARCHITECTURE logic OF VendingMachine IS
    COMPONENT Keyboard IS -- Componente do teclado
        PORT (
            clk : IN STD_LOGIC;
            col : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            d : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            dav : OUT STD_LOGIC
        );
    END COMPONENT;
    SIGNAL KeyboardOutput : STD_LOGIC_VECTOR (3 DOWNTO 0) := "ZZZZ"; -- Sinal que armazena a saída do componente do teclado (2 bits coluna e 2 bits linha)
    SIGNAL TranslatedKeyboardOutput : STD_LOGIC_VECTOR (3 DOWNTO 0) := "ZZZZ"; -- Sinal que armazena o sinal da saída do teclado traduzido (4 bits representando um número 0 até 15)
    SIGNAL FinalKeyboardOutput : STD_LOGIC_VECTOR (7 DOWNTO 0) := "ZZZZZZZZ"; -- Sinal que armazena o output final do teclado (4 bits para o primeiro dígito (0 ou 1) e 4 bits para o segundo dígito (0 - 9))
    SIGNAL AlgorismPosition : STD_LOGIC := '0'; -- Indica qual dígito está sendo digitado (os 4 primeiro bits do output final ou os 4 últimos bits do output final)
    SIGNAL CanRead : STD_LOGIC := '0'; -- Indica se a saída do teclado pode ser lida
BEGIN
    U1 : Keyboard PORT MAP(clk => Clock, col => Column, d => KeyboardOutput, dav => CanRead); -- Mapea os sinais para o componente do teclado

    PROCESS (Clock) -- Processa a entrada do clock
    BEGIN
        IF (Clock'EVENT AND Clock = '1') THEN -- Quando for a borda de subida do clock
            IF (MoneyRead = '1') THEN -- Quando o dinheiro tiver sido lido
                IF (CanRead = '1') THEN -- Quando a saída do teclado pode ser lida
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
                        WHEN OTHERS => TranslatedKeyboardOutput <= "ZZZZ";
                    END CASE; -- Traduz a saída coluna-linha do teclado para um número

                    IF (TranslatedKeyboardOutput = "1010") THEN -- Se for apertado o botão Clear
                        AlgorismPosition <= '0'; -- Posição do dígito volta para o ínicio
                        FinalKeyboardOutput <= "ZZZZZZZZ"; -- Limpa o output final
                    ELSIF (AlgorismPosition = '1' AND FinalKeyboardOutput(7 DOWNTO 4) /= "ZZZZ" AND TranslatedKeyboardOutput = "1011") THEN -- Se botão OK for apertado, estiver no último dígito e último digito tiver sido preenchido com algo
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
                        END CASE; -- Coloca na saída o número do produto que foi selecionado
                        UnlockDoor <= '1'; -- Coloca o sinal de saída indicando para abrir a porta
                    ELSE
                        IF (AlgorismPosition = '0') THEN -- Se a posição do dígito for o dígito de ínicio
                            CASE TranslatedKeyboardOutput IS
                                WHEN "0000" => -- 0
                                    FinalKeyboardOutput (3 DOWNTO 0) <= TranslatedKeyboardOutput; -- Coloca o output do traduzido do teclado para os 4 primeiros bits do output final
                                    AlgorismPosition <= '1';
                                WHEN "0001" => -- 1
                                    FinalKeyboardOutput (3 DOWNTO 0) <= TranslatedKeyboardOutput; -- Coloca o output do traduzido do teclado para os 4 primeiros bits do output final
                                    AlgorismPosition <= '1';
                                WHEN OTHERS => 
                                    FinalKeyboardOutput (3 DOWNTO 0) <= "ZZZZ";
                                    AlgorismPosition <= '0';
                            END CASE; -- O dígito inicial só pode ser 0 ou 1, se for outros dígitos, ignora
                        ELSE -- Se a posição do dígito for o dígito final
                            IF (FinalKeyboardOutput (3 DOWNTO 0) = "0000") THEN -- Se o primeiro dígito for 0
                                CASE TranslatedKeyboardOutput IS
                                    WHEN "0000" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 0  Coloca o output do traduzido do teclado para os 4 últimos bits do output final
                                    WHEN "0001" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 1  Coloca o output do traduzido do teclado para os 4 últimos bits do output final
                                    WHEN "0010" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 2  Coloca o output do traduzido do teclado para os 4 últimos bits do output final
                                    WHEN "0011" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 3  Coloca o output do traduzido do teclado para os 4 últimos bits do output final
                                    WHEN "0100" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 4  Coloca o output do traduzido do teclado para os 4 últimos bits do output final
                                    WHEN "0101" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 5  Coloca o output do traduzido do teclado para os 4 últimos bits do output final
                                    WHEN "0110" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 6  Coloca o output do traduzido do teclado para os 4 últimos bits do output final
                                    WHEN "0111" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 7  Coloca o output do traduzido do teclado para os 4 últimos bits do output final
                                    WHEN "1000" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 8  Coloca o output do traduzido do teclado para os 4 últimos bits do output final
                                    WHEN "1001" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 9  Coloca o output do traduzido do teclado para os 4 últimos bits do output final
                                    WHEN OTHERS => FinalKeyboardOutput (7 DOWNTO 4) <= "ZZZZ";
                                END CASE; -- Como o primeiro dígito é zero, permite que o segundo dígito seja apenas do 0 até 9, o resto ignora
                            ELSE -- Se o primeiro dígito for 1
                                CASE TranslatedKeyboardOutput IS
                                    WHEN "0000" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 0 
                                    WHEN "0001" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 1
                                    WHEN "0010" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 2
                                    WHEN "0011" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 3
                                    WHEN "0100" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 4
                                    WHEN "0101" => FinalKeyboardOutput (7 DOWNTO 4) <= TranslatedKeyboardOutput; -- 5
                                    WHEN OTHERS => FinalKeyboardOutput (7 DOWNTO 4) <= "ZZZZ";
                                END CASE; -- Como o primeiro dígito é 1, permite que o segundo dígito seja apenas do 0 até 5, o resto ignora
                            END IF;
                        END IF;
                    END IF;
                END IF;
            ELSE -- Se não tiver lido dinheiro
                IF (UnlockDoor = '1' AND TranslatedKeyboardOutput = "1011") THEN -- Se a porta está aberta e o último botão apertado foi o Ok
                    SelectedItem <= "ZZZZ"; -- Limpa item selecionado
                    UnlockDoor <= '0'; -- Tranca a porta
                END IF;
            END IF;
        END IF;
    END PROCESS;
END logic;
