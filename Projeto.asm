; *********************************************************************************
; * IST-UL
; * Cadeira:   IAC
; * Descrição: WIP - Jogo que copia o Space Invaders
;
; * Trabalho realizado por:
;
; * - Afonso Resendes ist1103972
; * - Lourenço Calhau ist1103396
; * - Pedro Gomes ist1103468
;
; *********************************************************************************
; * Constantes
; *********************************************************************************

; ----------- * Endereços * -----------

DISPLAYS			EQU 	0A000H		; endereço do display que mostra os outputs do telcado
TEC_LIN				EQU 	0C000H		; endereço das linhas do teclado (periférico POUT-2)
TEC_COL				EQU 	0E000H		; endereço das colunas do teclado (periférico PIN)

; ----------- * Constantes * -----------

LINHA_INICIAL       		EQU  	28        	; linha incial da nave (fim do ecrã)
COLUNA_INICIAL			EQU  	30        	; coluna inicial da nave (meio do ecrã)

MIN_LINHA			EQU 	0
MAX_LINHA 			EQU 	32
MIN_COLUNA			EQU  	0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA			EQU 	59        	; número da coluna mais à direita que o objeto pode ocupar

LINHA_TECLADO			EQU 	10H		; prepara a primeira linha a ser testada (Vai haver um SHR)    
MASCARA				EQU 	0FH		; isola os 4 bits de menor peso, ao ler as colunas do teclado
MASCARA_RANDOM 			EQU 	0F0H 

TECLA_ESQUERDA			EQU 	0000H		; valor da tecla 0 	
TELCA_DISPARO			EQU 	0001H		; valor da tecla 1										
TECLA_DIREITA			EQU 	0002H		; valor da tecla 2 

ALTURA 				EQU 	4
LARGURA 			EQU 	5
TECLA_START			EQU 	0001H      	; valor da tecla C com teclado parcial
TECLA_PAUSA         		EQU 	000DH      	; valor da tecla D
TECLA_TERMINA 			EQU 	000EH 		; valor da tecla E
TECLA_SPECIAL_THANKS 		EQU 	0008H 		; valor da tecla F com teclado parcial


COR_NADA			EQU  	00000H		; cor do vazio: Transparente (Estética)
COR_YLW				EQU	0FFF0H		; cor da nave: Amarelo
COR_MAG 			EQU 	0FF0FH 		; cor do missil: Magenta
COR_GRN 			EQU 	0F0F0H 		; cor do meteoro bom: Verde
COR_RED				EQU	0FF00H		; cor do meteoro mau : Vermelho
COR_GRY 			EQU 	07777H 		; cor do meteoro distante: preto transparente (cinza)
COR_CYN 			EQU 	0F0FFH  	; cor da explosão 

; -------------- * Comandos * --------------

DEFINE_LINHA    		EQU 	600AH      	; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 	600CH      	; endereço do comando para definir a coluna
SELECIONA_ECRA			EQU 	6004H      	; endereço do comando para selecionar o ecrã
MOSTRA_ECRA 			EQU 	6006H	   	; endereço do comando para mostrar ecrã selecionado
ESCONDE_ECRA			EQU 	6008H		; endereço do comando para esconder ecrã selecionado
DEFINE_PIXEL   			EQU 	6012H      	; endereço do comando para escrever um pixel
APAGA_AVISO    			EQU 	6040H      	; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU 	6002H      	; endereço do comando para apagar todos os pixels já desenhados
SC_FUNDO  			EQU 	6042H      	; endereço do comando para selecionar uma imagem de fundo	
TOCA_SOM			EQU 	605AH      	; endereço do comando para tocar um som
REPETE_SOM 			EQU 	6058H
VOLUME_SOM 			EQU 	604AH
PARA_SOM 			EQU 	6066H

; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE     	1000H
pilha:
	STACK 		100H				; espaço reservado para a pilha (100H WORDS, 200H BYTES)
SP_inicial:
	STACK 		100H 
SP_inicial_display:						; inicializa SP com o endereço do fim da pilha (1200H). 
	STACK  		100H 
SP_inicial_teclado:
	STACK  		100H 
SP_inicial_translator_hold:
	STACK  		100H 
SP_inicial_translator_press:
	STACK  		100H 
SP_inicial_esquerda:
	STACK  		100H 
SP_inicial_direita:
 	STACK  		100H 
SP_inicial_disparo:
	STACK 		100H
SP_meteoro_start:
	STACK  		100H 
SP_inicial_start:
	STACK  		100H 
SP_inicial_pausa:
	STACK  		100H 
SP_inicial_termina:
	STACK 		100H
SP_inicial_lost:

Meteoro_Hit:
	WORD 		0

Meteoro_Lock:
	LOCK 		0
Meteoro_Colunas_Ocupadas:
	WORD  		0000H



Tecla_Carregada_Lock:
	LOCK 		0
Tecla_Carregada_Word:
	WORD  		0FFH


Tecla_Esquerda_Lock:
	LOCK 		0
Tecla_Direita_Lock:
	LOCK 		0
Tecla_Disparo_Lock:
	LOCK 		0
Disparo_Lock:
	LOCK 		0
Tecla_Start_Lock:
	LOCK 		0
Tecla_Pausa_Lock:
	LOCK 		0
Tecla_Pausa_Word:
	WORD  		0
Tecla_Termina_Lock:
	LOCK 		0



Jogo_Terminado_Lock:
	LOCK 		0

Jogo_Lost_Lock:
	LOCK  		0



Disparo_Colisao:
	WORD  		0


Coluna_Disparo_Atual:
	WORD  		0FFH
Linha_Disparo_Atual:
	WORD  		0FFFH


Proximo_Display_Meteoro:
	WORD  		0

Energia_Hexadecimal_Word:
	WORD  		069H
Energia_Hexadecimal_Lock:
	LOCK  		069H

Coluna_Nave_Atual:
	WORD  		30



tab:
	WORD rot_int_0			; rotina de atendimento da interrupção 0
	WORD rot_int_1			; rotina de atendimento da interrupção 1
	WORD rot_int_2			; rotina de atendimento da interrupção 2



							
DEF_NAVE:									; tabela que guarda as inf. da nave
	WORD		ALTURA 							; guarda a altura da nave								
	WORD 		LARGURA							; guarda a largura da nave
	WORD		COR_NADA, COR_NADA, COR_YLW, COR_NADA, COR_NADA		; guarda a info. da primeira linha
	WORD		COR_YLW, COR_NADA, COR_YLW, COR_NADA, COR_YLW  		; guarda a info. da segunda linha
	WORD		COR_YLW, COR_YLW, COR_YLW, COR_YLW, COR_YLW  		; guarda a info. da terceira linha
	WORD		COR_NADA, COR_YLW, COR_NADA, COR_YLW, COR_NADA  	; guarda a info. da quarta linha

DEF_DISPARO:
	WORD  		2	
	WORD  		1
	WORD   		COR_MAG
	WORD   		COR_MAG

DEF_METEORO_GERAL1:
	WORD  		1
	WORD  		1
	WORD  		COR_GRY


DEF_METEORO_GERAL2:
	WORD  		2
	WORD  		2
	WORD  		COR_GRY,COR_GRY
	WORD  		COR_GRY,COR_GRY

DEF_METEORO_MAU1:								; tabela que guarda as inf. do meteoro max
	WORD		3							; guarda a altura do meteoro
	WORD		3							; guarda a largura do meteoro
	WORD		COR_RED, COR_NADA, COR_RED				; guarda a info. da primeira linha
	WORD		COR_NADA, COR_RED, COR_NADA  				; guarda a info. da segunda linha
	WORD		COR_RED, COR_NADA, COR_RED  				; guarda a info. da quinta linha


DEF_METEORO_MAU2:								; tabela que guarda as inf. do meteoro max
	WORD		4							; guarda a altura do meteoro
	WORD		4							; guarda a largura do meteoro
	WORD		COR_RED, COR_NADA, COR_NADA, COR_RED			; guarda a info. da primeira linha
	WORD		COR_RED, COR_NADA, COR_NADA, COR_RED  			; guarda a info. da segunda linha
	WORD		COR_NADA, COR_RED, COR_RED, COR_NADA  			; guarda a info. da terceira linha
	WORD		COR_RED, COR_NADA, COR_NADA, COR_RED  			; guarda a info. da quinta linha

DEF_METEORO_MAU3:								; tabela que guarda as inf. do meteoro max
	WORD		5							; guarda a altura do meteoro
	WORD		5							; guarda a largura do meteoro
	WORD		COR_RED, COR_NADA, COR_NADA, COR_NADA, COR_RED		; guarda a info. da primeira linha
	WORD		COR_RED, COR_NADA, COR_RED, COR_NADA, COR_RED  		; guarda a info. da segunda linha
	WORD		COR_NADA, COR_RED, COR_RED, COR_RED, COR_NADA  		; guarda a info. da terceira linha
	WORD		COR_RED, COR_NADA, COR_RED, COR_NADA, COR_RED		; guarda a info. da QUARTA linha
	WORD		COR_RED, COR_NADA, COR_NADA, COR_NADA, COR_RED  	; guarda a info. da quinta linha

DEF_METEORO_BOM1:								
	WORD		3							
	WORD		3							
	WORD		COR_NADA, COR_GRN, COR_NADA				
	WORD		COR_GRN, COR_GRN, COR_GRN				
	WORD		COR_NADA, COR_GRN, COR_NADA   				 

DEF_METEORO_BOM2:								; tabela que guarda as inf. do meteoro max
	WORD		4							; guarda a altura do meteoro
	WORD		4							; guarda a largura do meteoro
	WORD		COR_NADA, COR_GRN, COR_GRN, COR_NADA			; guarda a info. da primeira linha
	WORD		COR_GRN, COR_GRN, COR_GRN, COR_GRN 			; guarda a info. da segunda linha
	WORD		COR_GRN, COR_GRN, COR_GRN, COR_GRN  			; guarda a info. da terceira linha
	WORD		COR_NADA, COR_GRN, COR_GRN, COR_NADA   			; guarda a info. da quinta linha

DEF_METEORO_BOM3:								; tabela que guarda as inf. do meteoro max
	WORD		5							; guarda a altura do meteoro
	WORD		5							; guarda a largura do meteoro
	WORD		COR_NADA, COR_GRN, COR_GRN, COR_GRN, COR_NADA		; guarda a info. da primeira linha
	WORD		COR_GRN, COR_GRN, COR_GRN, COR_GRN, COR_GRN 		; guarda a info. da segunda linha
	WORD		COR_GRN, COR_GRN, COR_GRN, COR_GRN, COR_GRN  		; guarda a info. da terceira linha
	WORD		COR_GRN, COR_GRN, COR_GRN, COR_GRN, COR_GRN 		; guarda a info. da QUARTA linha
	WORD		COR_NADA, COR_GRN, COR_GRN, COR_GRN, COR_NADA   	; guarda a info. da quinta linha



DEF_COLISAO:									; tabela que guarda as inf. do meteoro max
	WORD		5							; guarda a altura do meteoro
	WORD		5							; guarda a largura do meteoro
	WORD		COR_NADA , COR_CYN, COR_NADA, COR_CYN, COR_NADA		; guarda a info. da primeira linha
	WORD		COR_CYN, COR_NADA , COR_CYN, COR_NADA, COR_CYN		; guarda a info. da segunda linha
	WORD		COR_NADA , COR_CYN, COR_NADA, COR_CYN, COR_NADA	  	; guarda a info. da terceira linha
	WORD		COR_CYN, COR_NADA , COR_CYN, COR_NADA, COR_CYN	 	; guarda a info. da QUARTA linha
	WORD		COR_NADA , COR_CYN, COR_NADA, COR_CYN, COR_NADA	   	; guarda a info. da quinta linha



; *********************************************************************************
; *
; * -------------------------------- Código Geral --------------------------------
; *
; *********************************************************************************
	PLACE   	0               ; o código tem de começar em 0000H
inicio:
	MOV  	SP, SP_inicial		; inicializa SP
	MOV  	BTE, tab		; inicializa BTE (registo de Base da Tabela de Exceções)


    	MOV  	[APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    	MOV  	[APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
    	MOV 	R10, 0
inicio_aux:

	MOV  	R1, 0
    	MOV  	[SC_FUNDO], R1		; seleciona o cenário de fundo
    	MOV 	[TOCA_SOM], R1
    	MOV 	[REPETE_SOM], R1
    	MOV 	R1, 25
    	MOV 	[VOLUME_SOM], R1
    	MOV 	R1, 100H
    	MOV 	[DISPLAYS], R1


; PROCESSO 1 DEFAULT

ciclo:
	MOV  	R4, TEC_LIN   		; copia para R1 o endereço do periférico das linhas
	MOV  	R5, TEC_COL   		; copia para R2 o endereço do periférico das colunas
	MOV  	R6, MASCARA   		; isola os 4 bits de menor peso, ao ler as colunas do teclado
	MOV  	R7, 08H 
	MOVB 	[R4], R7     		; escreve no periférico de saída (linhas)
espera_tecla:
	
	MOVB 	R8, [R5]      		; ler do periférico de entrada (colunas)
	AND  	R8, R6       		; elimina bits para além dos bits 0-3
	MOV 	R9, TECLA_START
	CMP  	R8, R9
	JNZ  	espera_tecla


fim_ciclo:
	
	MOV 	R1, 0
	MOV 	[PARA_SOM], R1
	MOV	R1, 1			; cenário de fundo número 1
    	MOV  	[SC_FUNDO], R1		; seleciona o cenário de fundo

    	MOV 	R1, LINHA_INICIAL
    	MOV 	R2, COLUNA_INICIAL
    	MOV 	R4, DEF_NAVE
    	MOV 	R9, 0

    	CALL  	desenha_objetos
    	CALL  	escreve_display 
	CALL  	teclado
	CALL  	tecla_translator_hold
	CALL  	tecla_translator_press
	CALL  	tecla_esquerda
	CALL  	tecla_direita
	CALL  	tecla_disparo
	CALL  	meteoro 
	CALL  	meteoro 
	CALL  	meteoro 
	CALL  	meteoro 
	CALL  	pausa
	CALL  	terminado
	CALL  	lost
	EI0
	EI1
	EI2 
	EI



ciclo2:
	YIELD
	JMP 	ciclo2	

; *********************************************************************************
; *
; * ---------------------------------- Processos ----------------------------------
; *
; *********************************************************************************

;Processo 1

PROCESS SP_inicial_display

escreve_display:					; atualiza o valor no output do display

	YIELD 

	MOV 	R7, [Energia_Hexadecimal_Lock]
	MOV 	R7, [Energia_Hexadecimal_Word]
	MOV 	R8, 10
	MOV 	R9, R7
	MOV 	R10, R7

	MOD  	R10, R8 			; Unidades

	DIV 	R9, R8				; Decimas														
	MOD 	R9, R8				; Decimas

	SHL 	R9, 4 				; Junta ambos
	OR  	R9, R10 			; Junta ambos

escreve_display_aux:
	MOV 	[DISPLAYS], R9
	JMP  	escreve_display














;Processo 2 - do teclado

PROCESS SP_inicial_teclado			

teclado:				; código que deteta o input de teclas
	
	MOV  	R3, 0FFFFH         	; copia o número que representa nenhuma tecla
	MOV  	R4, TEC_LIN   		; copia para R1 o endereço do periférico das linhas
	MOV  	R5, TEC_COL   		; copia para R2 o endereço do periférico das colunas
	MOV  	R6, MASCARA   		; isola os 4 bits de menor peso, ao ler as colunas do teclado
teclado_aux1:				; prepara a linha a ser testada 
	YIELD
	MOV  	R7, LINHA_TECLADO	; copia para R4 o valor da 1ª linha antes do SHR
	; 	R8  RESULTADO	
	; 	R9  COPIA DA LINHA A SER USADA
teclado_aux2:				; vai tentar encontrar uma tecla primida
	SHR  	R7, 1 			; muda para o valor da linha seguinte 
	JZ   	teclado_aux1		; caso tenha chegado ao fim vai terminar
	MOVB 	[R4], R7     		; escreve no periférico de saída (linhas)
	MOVB 	R8, [R5]      		; ler do periférico de entrada (colunas)
	AND  	R8, R6       		; elimina bits para além dos bits 0-3
	JZ 	teclado_aux2		; volta a percorrer o loop
	MOV 	R3, 0            	; inicia R0 a 0 para servir como resultado
	MOV 	R9, R7 			; copia a linha que esta a ser usada
converte_c:            			; usa a informacao da coluna para converter R0 no resultado final 
    	SHR 	R8, 1          		; dá um SHR já que a posição 1 é na verdade 0
    	JZ  	converte_l   		; caso R5 seja 0 vai saltar para converte_l
    	ADD 	R3, 1        	  	; incrementa 1 valor no resultado (representa um salto de linhas)
    	JMP 	converte_c   		; caso R5 ainda não seja 0 vai voltar a repetir o processo
converte_l:         			; usa a informacao da linha para converter R0 no resultado final
    	SHR 	R9, 1       		; dá um SHR já que a posição 1 é na verdade 0
    	JZ 	unlock_tecla     	; caso R4 seja 0 vai saltar para ha_tecla
    	ADD 	R3, 4       		; incrementa 4 valores no resultado (representa um salto de colunas)
    	JMP 	converte_l   		; caso R4 ainda não seja 0 vai voltar a repetir o processo
unlock_tecla:
	MOV	[Tecla_Carregada_Lock], R3	; informa quem estiver bloqueado neste LOCK que uma tecla foi carregada
	MOV 	[Tecla_Carregada_Word], R3
ha_tecla:					
	YIELD				; este ciclo é potencialmente bloqueante, pelo que tem de
	
	MOVB 	[R4], R7		; escrever no periférico de saída (linhas)
	MOVB 	R8, [R5]		; ler do periférico de entrada (colunas)
	AND  	R8, R6			; elimina bits para além dos bits 0-3
	JNZ  	ha_tecla		; se ainda houver uma tecla premida, espera até não haver
	MOV 	R3, 0FFH
	MOV 	[Tecla_Carregada_Lock], R3
	MOV 	[Tecla_Carregada_Word], R3
	JMP	teclado_aux1		; esta "rotina" nunca retorna porque nunca termina
					





;Processo 3 - Testa inputs teclado

PROCESS SP_inicial_translator_hold

tecla_translator_hold:
	MOV 	R3, [Tecla_Carregada_Word]
compara_direita:
	CMP  	R3, TECLA_DIREITA
	JNZ	compara_esquerda
	MOV 	[Tecla_Direita_Lock], R3


compara_esquerda:
	CMP  	R3, TECLA_ESQUERDA
	JNZ	translator_hold_fim
	MOV 	[Tecla_Esquerda_Lock], R3


translator_hold_fim: 
	YIELD
	JMP 	tecla_translator_hold








PROCESS SP_inicial_translator_press

tecla_translator_press:
	MOV 	R3, [Tecla_Carregada_Lock]
compara_disparo:
	CMP  	R3, TELCA_DISPARO
	JNZ	compara_start
	MOV 	[Tecla_Disparo_Lock], R3
	

compara_start:
	MOV 	R4, TECLA_START
	CMP  	R3, R4
	JNZ	compara_pausa
	MOV 	[Tecla_Start_Lock], R3



compara_pausa:
	MOV 	R4, TECLA_PAUSA
	CMP  	R3, R4
	JNZ	translator_press_fim
	PUSH  	R3
	MOV  	R3, 1
    	MOV 	[Tecla_Pausa_Word], R3
	MOV 	[Tecla_Pausa_Lock], R3
	POP  	R3

translator_press_fim: 
	
	JMP 	tecla_translator_press



;Processo 4 - Testa inputs teclado

PROCESS SP_inicial_esquerda

tecla_esquerda:
	MOV 	R3, [Tecla_Esquerda_Lock]
	MOV 	R3, [Coluna_Nave_Atual]

	MOV 	R5, MIN_COLUNA
	CMP 	R3, R5
	JZ  	tecla_esquerda

	MOV 	R9, 0
	MOV 	R1, LINHA_INICIAL
	MOV 	R2, R3
	MOV 	R4, DEF_NAVE
	CALL  	apaga_objetos
	
	SUB  	R3, 1
	MOV 	[Coluna_Nave_Atual], R3
	MOV 	R2, R3
	CALL  	desenha_objetos
	PUSH  	R10 
	MOV 	R10, 080H
tecla_esquerda_atraso:
	YIELD
	SUB  	R10, 1
	JNZ  	tecla_esquerda_atraso
	POP  	R10
	JMP  	tecla_esquerda



;Processo 5 - Testa inputs teclado

PROCESS SP_inicial_direita

tecla_direita:
	MOV 	R3, [Tecla_Direita_Lock]
	MOV 	R3, [Coluna_Nave_Atual]

	MOV 	R5, MAX_COLUNA
	CMP 	R3, R5
	JZ  	tecla_direita

	MOV 	R9, 0
	MOV 	R1, LINHA_INICIAL
	MOV 	R2, R3
	MOV 	R4, DEF_NAVE
	CALL  	apaga_objetos
	
	ADD  	R3, 1
	MOV 	[Coluna_Nave_Atual], R3
	MOV 	R2, R3
	CALL  	desenha_objetos
	PUSH  	R10 
	MOV 	R10, 080H
tecla_direita_atraso:
	YIELD
	SUB  	R10, 1
	JNZ  	tecla_direita_atraso
	POP  	R10
	JMP  	tecla_direita




;Processo 6 - Testa inputs teclado

PROCESS SP_inicial_disparo

tecla_disparo:
	
	MOV 	R2, 0
	MOV 	[Disparo_Colisao], R2
	MOV 	R2, 00FFH
	MOV 	[Coluna_Disparo_Atual], R2
	YIELD
	MOV 	R3, [Tecla_Disparo_Lock]
	PUSH  	R4
	MOV  	R4, 8
	MOV  	[TOCA_SOM], R4
	POP  	R4
	MOV 	R1, LINHA_INICIAL
	SUB  	R1, 2
	MOV 	[Linha_Disparo_Atual], R1
	MOV 	R2, [Coluna_Nave_Atual]
	ADD  	R2, 2
	MOV 	[Coluna_Disparo_Atual], R2
	MOV 	R4, DEF_DISPARO
	MOV 	R5, [Energia_Hexadecimal_Word]
	SUB  	R5, 5
	MOV 	[Energia_Hexadecimal_Word], R5
	MOV 	[Energia_Hexadecimal_Lock], R5
	MOV 	R6, 14
tecla_disparo_aux:
	YIELD
	MOV 	R3, [Disparo_Lock]
	CALL 	apaga_objetos
	SUB  	R1, 1
	MOV 	[Linha_Disparo_Atual], R1
	CMP  	R1, R6
	JLE  	tecla_disparo

	MOV 	R9, [Disparo_Colisao]
	CMP  	R9, 0
	JNZ 	tecla_disparo_reset

	CALL 	desenha_objetos
	JMP 	tecla_disparo_aux

tecla_disparo_reset:
	MOV 	R5, 0
	MOV 	[Meteoro_Hit], R5
	JMP  	tecla_disparo




;Processo 8 - Pausa

PROCESS SP_inicial_pausa

pausa:	
    	MOV     R4, TEC_LIN           ; copia para R1 o endereço do periférico das linhas
    	MOV     R5, TEC_COL           ; copia para R2 o endereço do periférico das colunas
    	MOV     R6, MASCARA           ; isola os 4 bits de menor peso, ao ler as colunas do teclado
    	MOV     R7, 08H 
    	MOV  	R8, 0FH  	
pausa_aux:
	YIELD
    	MOV 	R3, [Tecla_Pausa_Lock]
    	DI
    	MOV 	R3, 0
    	MOV 	[APAGA_ECRÃ], R3
    	MOV     R1, 2
    	MOV     [PARA_SOM], R1
    	MOV    	R1, 2            	; cenário de fundo número 0
        MOV     [SC_FUNDO], R1        	; seleciona o cenário de fundo
        MOV     R1, 2
        MOV     [TOCA_SOM], R1
        MOV     R1, 0
        MOV     [REPETE_SOM], R1
        MOV     R1, 25
        MOV     [VOLUME_SOM], R1
pausa_loop:
     	MOV      R4, TEC_LIN           		; copia para R1 o endereço do periférico das linhas
    	MOV      R5, TEC_COL           		; copia para R2 o endereço do periférico das colunas
    	MOV      R6, MASCARA           		; isola os 4 bits de menor peso, ao ler as colunas do teclado
    	MOV      R7, 08H 
    	MOVB     [R4], R7             		; escreve no periférico de saída (linhas)
pausa_espera_tecla_depress:          		; neste ciclo espera-se até uma tecla ser premida
    	MOVB 	R8, [R5]      			; ler do periférico de entrada (colunas)
    	AND  	R8, R6        			; elimina bits para além dos bits 0-3
    	CMP  	R8, 0         			; há tecla premida?
    	JNZ   	pausa_espera_tecla_depress  	; se nenhuma tecla premida, repete
pausa_espera_tecla:          			; neste ciclo espera-se até uma tecla ser premida
    	MOVB 	R8, [R5]      			; ler do periférico de entrada (colunas)
    	AND  	R8, R6        			; elimina bits para além dos bits 0-3
    	CMP  	R8, 2         			; há tecla premida?
    	JZ   	pausa_ha_tecla_sai  		; se nenhuma tecla premida, repete
    	CMP  	R8, 4
    	JZ 	pausa_ha_tecla_termina 
    	JMP  	pausa_espera_tecla



pausa_ha_tecla_sai:              		; neste ciclo espera-se até NENHUMA tecla estar premida
    	MOVB 	R8, [R5]      			; ler do periférico de entrada (colunas)
    	AND  	R8, R6        			; elimina bits para além dos bits 0-3
    	CMP  	R8, 0         			; há tecla premida?
    	JNZ  	pausa_ha_tecla_sai      	; se ainda houver uma tecla premida, espera até não haver

    	MOV     R1, 2
    	MOV     [PARA_SOM], R1
	MOV	R1, 1			; cenário de fundo número 1
    	MOV  	[SC_FUNDO], R1		; seleciona o cenário de fundo

    	MOV 	R1, LINHA_INICIAL
    	MOV 	R2, [Coluna_Nave_Atual]
    	MOV 	R4, DEF_NAVE
    	MOV 	R9, 0
    	CALL  	desenha_objetos

    	JMP     pausa_aux
	

pausa_ha_tecla_termina:
	MOVB 	R8, [R5]      			; ler do periférico de entrada (colunas)
    	AND  	R8, R6        			; elimina bits para além dos bits 0-3
    	CMP  	R8, 0         			; há tecla premida?
    	JNZ  	pausa_ha_tecla_termina      	; se ainda houver uma tecla premida, espera até não haver

    	MOV     R1, 2
    	MOV     [PARA_SOM], R1
	MOV 	[Jogo_Terminado_Lock], R1    	
    	JMP     pausa_aux


;Processo 9 - Termina

PROCESS SP_inicial_termina
	

terminado:
	YIELD
    	MOV    R1, [Jogo_Terminado_Lock]
    	MOV    R1, 4                ; cenário de fundo número 1
        MOV    [SC_FUNDO], R1            ; seleciona o cenário de fundo
        MOV    R1, 3
        MOV    [TOCA_SOM], R1
        MOV    R1, 25
        MOV    [VOLUME_SOM], R1

termina_loop:
        
        JMP     termina_loop





PROCESS SP_inicial_lost
	
lost:
	YIELD
    	MOV    	R1, [Jogo_Lost_Lock]	
    	MOV  	[APAGA_ECRÃ], R1
    	MOV    	R1, 5              		; cenário de fundo número 1
        MOV    	[SC_FUNDO], R1            	; seleciona o cenário de fundo
        MOV    	R1, 3
        MOV    	[TOCA_SOM], R1
        MOV    	R1, 25
        MOV    	[VOLUME_SOM], R1

lost_loop:
        
        JMP     lost_loop






;Processo 7 - Meteoros

PROCESS SP_meteoro_start

meteoro:
	MOV 	R9, [Proximo_Display_Meteoro]
	ADD  	R9, 1
	MOV  	[Proximo_Display_Meteoro], R9
meteoro_aux:
	YIELD	
	MOV  	R3, 5
	MOV 	[TOCA_SOM], R3
    	MOV     R3, TEC_COL
    	MOV     R6, MASCARA_RANDOM
    	;       R2  RESULTADO
meteoro_coluna_teste:
	YIELD
    	MOVB    R2, [R3]           
    	AND     R2, R6
    	MOVB    R5, [R3]
    	AND     R5, R6
    	SHR     R2, 4
    	OR      R2, R5
    	MOV     R5, 4
    	DIV     R2, R5
    	MOV     R5, 59
    	CMP     R2, R5
    	JGT     meteoro_aux
desenha_meteoro_prep:
    	MOV     R1, 0
    	MOV     R5, 3
    	MOV     R4, DEF_METEORO_GERAL1
desenha_meteoro_geral1:
	YIELD
	CALL 	desenha_objetos
    	MOV     R8, [Meteoro_Lock]
    	CALL    apaga_objetos
    	ADD     R1, 1
    	CMP     R1, R5
    	JNZ 	desenha_meteoro_geral1
    	MOV     R4, DEF_METEORO_GERAL2
    	MOV 	R5, 6
desenha_meteoro_geral2:
	YIELD
	CALL 	desenha_objetos
    	MOV     R8, [Meteoro_Lock]
    	CALL    apaga_objetos
    	ADD     R1, 1
    	CMP     R1, R5
    	JNZ 	desenha_meteoro_geral2
    	MOV 	R5, 9
meteoro_teste_tipo:
	YIELD
	MOV     R4, DEF_METEORO_MAU1
    	MOVB    R8, [R3] 
    	AND     R8, R6
   	SHR     R8, 4
   	CMP     R8, 4
   	JGT     desenha_meteoro_mau1
   	MOV     R4, DEF_METEORO_BOM1
   	JLE   	desenha_meteoro_bom1


termina_processo_10:
	JMP 	meteoro_aux



desenha_meteoro_mau1:
	YIELD
	CALL 	desenha_objetos
    	MOV     R8, [Meteoro_Lock]
    	CALL    apaga_objetos
    	ADD     R1, 1
    	CMP     R1, R5
    	JNZ 	desenha_meteoro_mau1
    	MOV     R4, DEF_METEORO_MAU2
    	MOV 	R5, 12
desenha_meteoro_mau2:
	YIELD
	CALL 	desenha_objetos
    	MOV     R8, [Meteoro_Lock]
    	CALL    apaga_objetos
    	ADD     R1, 1
    	CMP     R1, R5
    	JNZ 	desenha_meteoro_mau2
    	MOV     R4, DEF_METEORO_MAU3
    	MOV 	R5, MAX_LINHA
desenha_meteoro_mau3:
	YIELD
	MOV 	R11, [Meteoro_Hit]
	CMP  	R11, 0
	JNZ 	desenha_meteoro_bom3

	CALL 	desenha_objetos

	CALL  	colisao_disparo
	CMP  	R10, 1
	JZ  	colisao_missil_mau

	CALL 	colisao_nave
	CMP  	R7, 1
	JZ  	colisao_nave_mau

    	MOV     R8, [Meteoro_Lock]
    	CALL    apaga_objetos
    	ADD     R1, 1
    	CMP     R1, R5
    	JNZ 	desenha_meteoro_mau3
    	; quando bate na terra
    	JMP 	meteoro_aux
desenha_meteoro_bom1:
	YIELD
	CALL 	desenha_objetos
    	MOV     R8, [Meteoro_Lock]
    	CALL    apaga_objetos
    	ADD     R1, 1
    	CMP     R1, R5
    	JNZ 	desenha_meteoro_bom1
    	MOV     R4, DEF_METEORO_BOM2
    	MOV 	R5, 12
desenha_meteoro_bom2:
	YIELD
	CALL 	desenha_objetos
    	MOV     R8, [Meteoro_Lock]
    	CALL    apaga_objetos
    	ADD     R1, 1
    	CMP     R1, R5
    	JNZ 	desenha_meteoro_bom2
    	MOV     R4, DEF_METEORO_BOM3
    	MOV 	R5, MAX_LINHA
desenha_meteoro_bom3:
	YIELD
	MOV 	R11, [Meteoro_Hit]
	CMP  	R11, 0
	JNZ 	desenha_meteoro_bom3
	CALL 	desenha_objetos

	CALL  	colisao_disparo
	CMP  	R10, 1
	JZ  	colisao_missil_bom

	CALL 	colisao_nave
	CMP  	R7, 1
	JZ  	colisao_nave_bom

    	MOV     R8, [Meteoro_Lock]
    	CALL    apaga_objetos
    	ADD     R1, 1
    	CMP     R1, R5
    	JNZ 	desenha_meteoro_bom3
    	; quando bate na terra
    	JMP 	meteoro_aux



colisao_missil_bom:
	MOV 	R10, 0
	MOV 	R5, 1
	MOV  	[Meteoro_Hit], R5
	PUSH  	R4 
	MOV 	R4, DEF_COLISAO
	CALL  	desenha_objetos
	MOV  	R4, 4
	MOV  	[TOCA_SOM], R4 
	POP  	R4
	PUSH  	R5 
	MOV  	R5, 0FFH 
colisao_missil_bom_delay:
	YIELD
	SUB  	R5, 1
	JNZ  	colisao_missil_bom_delay
	CALL  	apaga_objetos
	JMP  	meteoro_aux




colisao_missil_mau:
	MOV 	R10, 0
	MOV 	R5, 1
	MOV  	[Meteoro_Hit], R5
	MOV 	R5, [Energia_Hexadecimal_Word]
	ADD  	R5, 5
	MOV 	[Energia_Hexadecimal_Word], R5
	MOV 	[Energia_Hexadecimal_Lock], R5
	PUSH  	R4 
	MOV 	R4, DEF_COLISAO
	CALL  	desenha_objetos
	MOV  	R4, 7
	MOV  	[TOCA_SOM], R4
	POP  	R4
	PUSH  	R5 
	MOV  	R5, 0FFH 
colisao_missil_mau_delay:
	YIELD
	SUB  	R5, 1
	JNZ  	colisao_missil_mau_delay
	CALL  	apaga_objetos
	JMP  	meteoro_aux




colisao_nave_bom:
	MOV  	R7, 0
	MOV 	R5, [Energia_Hexadecimal_Word]
	ADD  	R5, 5
	ADD  	R5, 5
	MOV 	[Energia_Hexadecimal_Word], R5 
	MOV  	[Energia_Hexadecimal_Lock], R5
	PUSH  	R4 
	MOV 	R4, DEF_COLISAO
	CALL  	desenha_objetos
	MOV  	R4, 9
	MOV  	[TOCA_SOM], R4
	MOV  	R4, 10
	MOV  	[TOCA_SOM], R4
	POP  	R4 
	PUSH  	R5 
	MOV  	R5, 0FFH 
colisao_nave_bom_delay:
	YIELD
	SUB  	R5, 1
	JNZ  	colisao_nave_bom_delay
	CALL  	apaga_objetos
	JMP  	meteoro_aux





colisao_nave_mau:
	MOV 	R7, 0
	PUSH  	R4 
	MOV 	R4, DEF_COLISAO
	CALL  	desenha_objetos
	MOV  	R4, 6
	MOV  	[TOCA_SOM], R4
	POP  	R4
	PUSH  	R5 
	MOV  	R5, 0FFH 
colisao_nave_mau_delay:
	YIELD
	SUB  	R5, 1
	JNZ  	colisao_nave_mau_delay
	CALL  	apaga_objetos
	MOV    	[Jogo_Lost_Lock], R1
	JMP  	meteoro_aux

	





colisao_disparo:
	PUSH  	R1 
	PUSH 	R2 
	ADD  	R1, 5
	MOV  	R2, [Linha_Disparo_Atual]
	CMP  	R1, R2
	POP  	R2 
	POP  	R1 
	JGT 	colisao_disparo_coluna	
	RET  	 
colisao_disparo_coluna:
	PUSH  	R1 
	PUSH  	R2 
	PUSH  	R3
	MOV  	R3, 0
	MOV  	R1, [Coluna_Disparo_Atual]
	CMP 	R1, R2
	JLT  	colisao_disparo_coluna_aux1
	ADD  	R3, 1
colisao_disparo_coluna_aux1:
	ADD 	R2, 4
	CMP 	R1, R2	
	JGT  	colisao_disparo_coluna_aux2
	ADD 	R3, 1
 colisao_disparo_coluna_aux2:
 	CMP  	R3, 2
	POP  	R3
	POP  	R2
	POP  	R1
	JZ 	colisao_disparo_true
	RET
colisao_disparo_true:
	MOV 	R10, 1
	MOV 	[Disparo_Colisao], R10
	RET



colisao_nave:
	; R1 - Linha MET
	; R2 - Coluna MET
	PUSH 	R1 
	PUSH  	R7 
	MOV  	R7, LINHA_INICIAL
	ADD  	R1, 4
	CMP  	R1, R7
	POP  	R7
	POP  	R1
	JGE   	colisao_nave_coluna
	RET
colisao_nave_coluna:
	PUSH  	R1 
	PUSH  	R2 
	PUSH  	R3
	MOV  	R3, 0
	MOV 	R1, [Coluna_Nave_Atual]
	CMP  	R2, R1 
	JLT  	colisao_nave_coluna_aux1
	ADD  	R3, 1
colisao_nave_coluna_aux1:	
	ADD  	R1, 4
	CMP  	R2, R1 
	JGT   	colisao_nave_coluna_aux2
	ADD   	R3, 1
colisao_nave_coluna_aux2:
	CMP  	R3, 2
	POP  	R3 
	POP  	R2 
	POP  	R1 
	JZ 	colisao_nave_true
	PUSH  	R1 
	PUSH  	R2 
	PUSH  	R3
	MOV  	R3, 0
	MOV 	R1, [Coluna_Nave_Atual]
	CMP  	R1, R2
	JLT   	colisao_nave_coluna_aux3
	ADD  	R3, 1
colisao_nave_coluna_aux3:
	ADD  	R2, 4
	CMP  	R1, R2 
	JGT   	colisao_nave_coluna_aux4
	ADD   	R3, 1
colisao_nave_coluna_aux4:
	CMP  	R3, 2
	POP  	R3 
	POP  	R2 
	POP  	R1 
	JZ 	colisao_nave_true
	RET 




colisao_nave_true:

	MOV 	R7, 1
	RET 


; *********************************************************************************
; *
; * ---------------------------------- Rotinas ----------------------------------
; *
; *********************************************************************************

 
; **********************************************************************
; ROT_INT_0 -	
;
;
; **********************************************************************

rot_int_0:
	PUSH 	R11
	MOV 	R11, 1
	MOV 	[Meteoro_Lock], R11
	POP  	R11 
	RFE



; **********************************************************************
; ROT_INT_1 -	
;
;
; **********************************************************************

rot_int_1:
	PUSH 	R11
	MOV 	R11, 1
	MOV 	[Disparo_Lock], R11
	POP  	R11 
	RFE


; **********************************************************************
; ROT_INT_2 -	
;
;
; **********************************************************************

rot_int_2:
	PUSH 	R11
	MOV  	R11, [Energia_Hexadecimal_Word]
	SUB  	R11, 5
	MOV  	[Energia_Hexadecimal_Word], R11
	MOV 	[Energia_Hexadecimal_Lock], R11
	POP  	R11		
	RFE					

; **********************************************************************
; escreve_pixel - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; Retorna: NADA
; **********************************************************************

escreve_pixel:					; comandos que desenham o pixel

	MOV 	[SELECIONA_ECRA], R9 		; seleciona o ecrã 
	MOV  	[DEFINE_LINHA], R1		; seleciona a linha
	MOV  	[DEFINE_COLUNA], R2		; seleciona a coluna
	MOV  	[DEFINE_PIXEL], R3		; altera a cor do pixel na coordenada (R1,R2)
	RET                   			; retorna

; **********************************************************************
; desenha_objetos 	- Desenha objetos atraves da linha e coluna indicadas
;			    	com a forma e cor definidas na tabela indicada.
; Argumentos:   	R1 - linha
;               	R2 - coluna
;               	R4 - tabela que define o objeto
;
; **********************************************************************

desenha_objetos: 				
	PUSH 	R1				; guarda o valor do registo 1 (Linha)
	PUSH 	R3				; guarda o valor do registo 3 (Coluna)
	PUSH 	R4				; guarda o valor do registo 4 (Tabela)
	PUSH 	R5				; guarda o valor do registo 5 (Altura)
	PUSH 	R6				; guarda o valor do registo 6 (Largura)
	MOV  	R5, [R4]			; guarda a altura no registo 5
	ADD  	R4, 2				; passa para R4 o valor da largura
	MOV  	R6, [R4]			; guarda a largura no registo 6
	ADD  	R4, 2				; prepara o registo 4 para receber as cores
desenha_pixels: 				; guarda valores que serão iterados nos ciclos
	PUSH 	R2				; guarda o valor da coluna
	PUSH 	R6				; guarda o valor de colunas que faltam desenhar
desenha_pixels_aux:     			; desenha todos os pixels da nave a partir da tabela
	MOV	R3, [R4]			; guarda no R3 a cor do próximo pixel da nave
	CALL 	escreve_pixel			; escreve cada pixel da nave usando R1, R2 e R3
	ADD	R4, 2				; endereço da cor do próximo pixel 
    	ADD  	R2, 1      	       		; próxima coluna
    	SUB  	R6, 1				; menos uma coluna para tratar
    	JNZ  	desenha_pixels_aux 		; continua até percorrer toda a largura do objeto
    	ADD  	R1, 1     	      		; proxima linha para tratar
    	POP  	R6	        	 	; volta a guardar o valor da largura no R6
    	POP  	R2        			; volta a guardar o valor da coluna inicial no R2
    	SUB  	R5, 1         	    		; menos uma linha para tratar
    	JNZ  	desenha_pixels 	    		; volta a percorrer o loop até chegar a 0
	POP  	R6				; retorna o valor original do registo R6
	POP	R5				; retorna o valor original do registo R5
	POP	R4				; retorna o valor original do registo R4
	POP  	R3				; retorna o valor original do registo R3
	POP  	R1				; retorna o valor original do registo R1
	RET			 		; retorna à chamada

; **********************************************************************
; apaga_objetos 	- Apaga uma nave na linha e coluna indicadas com a 
;  					forma definida na tabela indicada.
; Argumentos:  		R1 - linha
;              		R2 - coluna
;              		R4 - tabela que define a nave
;
; Retorna: NADA
; **********************************************************************

apaga_objetos:				; prepara os registos para começar a apagar a nave
	PUSH 	R1			; guarda o valor do registo 1
	PUSH 	R3			; guarda o valor do registo 3
	PUSH 	R4            		; guarda o valor do registo 4
	PUSH 	R5			; guarda o valor do registo 5
	PUSH 	R6			; guarda o valor do registo 6
	MOV  	R3, 0 			; guarda em R3 o valor da cor do pixel (transparente)
	MOV  	R5, [R4]		; guarda a altura no registo 5
	ADD  	R4, 2			; passa para R4 o valor da largura
	MOV  	R6, [R4]		; guarda a largura no registo 6
apaga_pixels: 				; guarda valores que serão iterados nos ciclos
	PUSH 	R2			; guarda o valor da coluna
	PUSH 	R6			; guarda o valor de colunas que faltam apagar
apaga_pixels_aux:       		; apaga todos os pixels da nave a partir da tabela
	CALL 	escreve_pixel		; apaga cada pixel da nave
	ADD  	R2, 1              	; próxima coluna
    	SUB  	R6, 1			; menos uma coluna para tratar
    	JNZ  	apaga_pixels_aux  	; continua até apagar toda a largura do objeto
   	ADD  	R1, 1          		; proxima linha para tratar
    	POP  	R6       		; volta a guardar o valor da largura no R6
    	POP  	R2			; volta a guardar o valor da coluna inicial no R2
    	SUB  	R5, 1          		; menos uma linha para tratar
    	JNZ  	apaga_pixels      	; volta a percorrer o loop até chegar a 0
	POP  	R6			; retorna o valor original do registo R6
	POP	R5			; retorna o valor original do registo R5
	POP  	R4 			; retorna o valor original do registo R4
	POP  	R3			; retorna o valor original do registo R3
	POP  	R1			; retorna o valor original do registo R1
	RET		 		; retorna à chamada






