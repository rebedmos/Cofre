mov R1, #04D2h                  ;carrega senha padrao
 mov R2, #05h                    ;carrega numero de tentativas para troca de senha
 mov R3, #03h                    ;carrega numero de tentativas para senha correta
 mov R4, #tempo_bloqueio         ;carrega tempo de bloqueio
                                 ;Acende LED Verde
                                 ;Apaga LED Vermelho
                                 ;Apaga LED Amarelo
 
 ;verifica se o usuario deseja alterar a senha
 
 ;se sim, Acende LED Amarelo e inicia rotina:
 Rotina 1[    ;solicita senha atual
     ;verifica se a senha esta correta
     
     ;se estiver correta solicita nova senha ao usuário
 mov R1, #nova senha  ; Atualiza registrador com nova senha
         ;Apaga LED Amarelo e vai para instrução onde aguarda o cofre ser trancado
         
 subb R2,#01h    ;se estiver incorreta diminui uma chance do usuario
                 ;verifica se o numero de chances chegou em zero
                         ;se as chances chegaram em zero o programa é bloqueado e aguarda o tempo de R4
                         ;quando o tempo acaba, retorna para o inicio do programa
                 ;se o usuario possuir chances, o programa retorna para instrução de entrar senha atual ]Fim da Rotina 1
                 
 ;se o usuario não deseja alterar a senha, o programa aguarda o cofre ser trancado
 
     ;Botão de trava foi pressionado?
     ;Não: Programa fica parado
     
     ;Sim: Acende o LED Vermelho e programa solicita senha ao usuario
         
         ;Verifica se senha esta correta
         
         ;Sim: Apaga LED Vermelho e Acende o LED Verde, liberando o Cofre 
 
 
 
 ;----------------------------------------------------------------------------------------------------------------------------------------
 ;Projeto: Cofre Digital
 ;Realizado por: Salomão Victor, Matheus Lippai, Renato Ramos e Vinicius Henrique
 ;Data: __/__/____
 ;----------------------------------------------------------------------------------------------------------------------------------------
 $include(REG51.inc); Inclui um arquivo a este arquivo com os registradores de funções especiais SFR.
 ;----------------------------------------------------------------------------------------------------------------------------------------
 ; Programa Principal
 code at 0 ; Define ljmp INICIO no endereço 0000h da memória de programa
 ljmp INICIO ; para saltar para o programa principal após o resete do ucontrol.
 code
 ;----------------------------------------------------------------------------------------------------------------------------------------
 code at 000Bh   ; endereco da sub-rotina de interrupcao de atendimento ao T0
 ljmp TEMPORIZADOR  ; salta para a TEMPORIZADOR
 code
 ;---------------------------------------------------------------------------------------------------------------------------------------
 code at 001Bh   ; endereco da sub-rotina de interrupcao de atendimento ao T1
 ljmp TEMPORIZADOR_1  ; salta para a TEMPORIZADOR_1
 code
 ;---------------------------------------------------------------------------------------------------------------------------------------
 code at 0050h
 TEMPORIZADOR:   ; Sub-rotina de atendimento da inter. T0
 mov TH0,#5Dh   ; reprograma T0 programado p/ gerar 50 ms entre interrupções
 mov TL0,#3Dh   ;fosc=fcrist/12=10MHz/12=833,33KHz;Tosc=1,2us;50ms/1,2us=41667 cont.
 inc r0        ; incrementa contador R0 (contador de 50 ms)
 clr c        ; zera carry-bit para nao afetar a operacao de subtração
 mov a,r0       ; copia r7 para acumulador
 subb a,#3Ch        ; foram geradas 60 interrupcoes de 0,5 segundo?
 jc SALTA       ; Se ainda nao foi gerado um segundo, salta
 mov r0,#00h       ; zera contador de 50 ms
 mov a,p3.7       ; copia p1 p/ o acumulador
 cpl a        ; complementa de um do acumulador
 mov p3.7,a       ; copia o valor do acumulador para p1
 SALTA: reti      ;
 code
 ;----------------------------------------------------------------------------------------------
 code at 0060h
 TEMPORIZADOR_1:  ; Sub-rotina de atendimento da inter. T1
 mov TH1,#5Dh   ; reprograma T0 programado p/ gerar 50 ms entre interrupções
 mov TL1,#3Dh   ;fosc=fcrist/12=10MHz/12=833,33KHz;Tosc=1,2us;50ms/1,2us=41667 cont.
 inc 0CH       ; incrementa contador 0c (contador de 50 ms)
                      ;mov R6,a ; Salva o valor que estava no acumulador antes da interrupção
                      ;mov p3.5,c ; Salva o valor que estava no acumulador antes da interrupção
                      ;mov r5,b ; Saçva o valor que estava no acumulador antes da interrupção
                      ;clr c ; zera carry-bit para nao afetar a operacao de subtração
 mov a,0CH   ; copia r0 para acumulador
 subb a,#0C8h       ; foram geradas 200 interrupcoes (10 segundos)?
 jc SALTA   ; Se ainda nao foi gerado um segundo, salta
 SETB p3.7   ; Aciona LED Amarelo
 SALTA: reti   ;mov a,R6; Retorna o valor de a
                      ;mov b,R5; Retorna o valor de b
                      ;mov c,p3.5; Retorna o valor de c
                      ;reti
 code
 
 ;------------------------------------------------------------------------------------------------------
 code at 0100h
 CONFIG_HARD:   ; Inicialização do Hardware do 8051
 mov p0,#37h   ; Programa as portas P0.0, P0.1, P0.2, P0.3, P0.4 como entrada e o restante como saída.
 mov p1,#0FFh   ; Programa a porta 1 (P1) como entrada.
 mov p2,#00h   ; Programa a porta 2 (P2) como saida.
 mov p3,#00h   ; Programa a porta 3 (P3) como saida.
 ret
 ;------------------------------------------------------------------------------------------------------
 PROGT0:       ; Sub-rotina que programa o T0
 mov TMOD,#01h   ; T0 no modo 1 (16 bits de contagem)
 mov TH0,#5Dh   ; T0 programado p/ gerar 50 ms entre interrupções
 mov TL0,#3Dh
 mov IE,#82h   ; habilita apenas T0 para gerar interrupções
                     ; mov TCON,#10h   ; liga apenas o T0 para gerar interrupções
 ret
 ;----------------------------------------------------------------------------------
 PROGT1:       ; Sub-rotina que programa o T1
 mov TMOD,#10h   ; T1 no modo 1 (16 bits de contagem)
 mov TH1,#5Dh   ; T1 programado p/ gerar 50 ms entre interrupções
 mov TL1,#3Dh
 mov IE,#88h   ; habilita apenas T1 para gerar interrupções
                     ; mov TCON,#80h   ; liga apenas o T0 para gerar interrupções
 ret
 ;----------------------------------------------------------------
 SETUP:     ; Configura padrão do cofre
 mov R1, #05h                    ;carrega numero de tentativas para troca de senha
 mov R2, #03h                    ;carrega numero de tentativas para senha correta
 mov R4, #01h                    ;carrega digito 1 senha padrao
 mov R5, #02h                    ;carrega digito 2 senha padrao
 mov R6, #04h                   ;carrega digito 3 senha padrao
 mov R7, #08h                    ;carrega digito 4 senha padrao
 clr P3.5                       ;Acende LED Verde
 setb P3.6                        ;Apaga LED Vermelho
 setb P3.7                        ;Apaga LED Amarelo
 ret
 ;----------------------------------------------------------------
 SENHA:        ; Rotina para verificação da senha
 JB P0.1, ALTERAR_SENHA
 lcall TIMER
 JB P0.2, Finaliza_senha
 lcall TIMER
 SJMP SENHA
 ret
 ;-----------------------------------------------------------------
 ALTERAR_SENHA:
 
 mov TCON,#10h           ;acionando o T0
 
 DIGITO1:
 JZ P1,DIGITO1              ;Verifica se não é 00h
 mov 08h,P1
 lcall TIMER
 mov a,08h                       
 lcall Display
 
 Digito2: 
 JZ P1,Digito2               ;Verifica se não é 00h
 mov 09h, P1
 lcall TIMER
 mov a,09h                       
 lcall Display
 
 Digito3: 
 JZ P1,Digito3               ;Verifica se não é 00h
 mov 0Ah, P1
 lcall TIMER
 mov a,0ah                       
 lcall Display
 
 Digito4: 
 JZ P1,Digito4               ;Verifica se não é 00h
 mov 0Bh,P1
 lcall TIMER
 mov a,0bh                       
 lcall Display
 
 
 CJNE 08H,R4,ERRO
 CJNE 09H,R5,ERRO
 CJNE 0AH,R6,ERRO
 CJNE 0BH,R7,ERRO
 
 
 NOVA_SENHA:
 NDIGITO1:
 JZ P1,NDIGITO1              ;Verifica se não é 00h
 mov 08h,P1
 lcall TIMER
 mov R4,08h
 mov a,08h                       
 lcall Display
 
 NDigito2: 
 JZ P1,NDigito2               ;Verifica se não é 00h
 mov 09h, P1
 lcall TIMER
 mov R5,09h
 mov a,09h                       
 lcall Display
 
 NDigito3: 
 JZ P1,NDigito3               ;Verifica se não é 00h
 mov 0Ah, P1
 lcall TIMER
 mov R6,0ah
 mov a,0ah                       
 lcall Display
 
 NDigito4: 
 JZ P1,NDigito4               ;Verifica se não é 00h
 mov 0Bh,P1
 lcall TIMER
 mov R4,0bh
 mov a,0bh                       
 lcall Display
 
 ;-------------------------------------------------------------------
 Finaliza_senha:
 JNB P0.2,Finaliza_senha:
 mov TCON,#00h 
 RET
 
 ;-------------------------------------------------------------------
 ERRO:
 dec R1
 DJNZ R1, ALTERAR_SENHA
 lcall BLOQUEIO
 
 ret
 ;----------------------------------------------------------------------
 
 ERROI:
 DEC R2
 DJNZ,INSERIRSENHA
 lcall BLOQUEIO
 ret
 
 ;----------------------------------------------------------------------
 AGUARDA_TRAVA:
 JNB P0.0,INICIO
 lcall TIMER
 lcall INSERIRSENHA
 
 
 ;----------------------------------------------------------------------
 INSERIRSENHA:
 
 JZ P1,INSERIRSENHA:      ;Verifica se não é 00h
 mov 08h,P1
 lcall TIMER
 mov a,08h                       
 lcall Display
 
 IDigito2: 
 JZ P1,IDigito2               ;Verifica se não é 00h
 mov 09h, P1
 lcall TIMER
 mov a,09h                       
 lcall Display
 
 IDigito3: 
 JZ P1,IDigito3               ;Verifica se não é 00h
 mov 0Ah, P1
 lcall TIMER
 mov a,0ah                       
 lcall Display
 
 IDigito4: 
 JZ P1,IDigito4               ;Verifica se não é 00h
 mov 0Bh,P1
 lcall TIMER
 mov a,0bh                       
 lcall Display
 
 
 CJNE 08H,R4,ERROI
 CJNE 09H,R5,ERROI
 CJNE 0AH,R6,ERROI
 CJNE 0BH,R7,ERROI
 
 setb P3.5
 setb P3.7
 clr P3.6
 
 AJMP $
 
 ;----------------------------------------------------------------------
 TIMER:            ; Chama o temporizador (0.5s) para impedir leitura sequencial
 mov psw,#08h            ; selecionando o segundo banco de registradores
 mov R2,#04h       ; Rotina de tempo: inicializa R2 para gerar 0.5s
 ADR2: mov R3,#00h      ; inicializa R3 para gerar 0.5s
 ADR1: mov R4,#00h      ; inicializa R4 para gerar 0.5s
 djnz R4,$           ; decrementa R4
 djnz R3,ADR1       ; decrementa R3
 djnz R2,ADR2       ; decrementa R2
 mov psw,#00h            ; voltando ao primeiro banco de registradores
 ret            ;
 
 TIMER2:
 mov psw,#08h            ; selecionando o segundo banco de registradores
 mov R2,#50h       ; Rotina de tempo: inicializa R2 para gerar 0.5s
 ADR2: mov R3,#00h      ; inicializa R3 para gerar 0.5s
 ADR1: mov R4,#00h      ; inicializa R4 para gerar 0.5s
 djnz R4,$           ; decrementa R4
 djnz R3,ADR1       ; decrementa R3
 djnz R2,ADR2       ; decrementa R2
 mov psw,#00h            ; voltando ao primeiro banco de registradores
 ret
 ;-----------------------------------------------------------------------------------------------
 Display:
 mov 20h,a
 CJNE 20h,#01h,dois
 mov P2,#60h
 ret
 
 dois:
 CJNE 20h,#02h,tres
 mov P2,#0EAh
 ret
 
 tres:
 CJNE 20h,#04h,quatro
 mov P2,#0F2h
 ret
 
 quatro:
 CJNE 20h,#08h,cinco
 mov P2,#66h
 ret
 
 cinco:
 CJNE 20h,#10h,seis
 mov P2,#0B6h
 ret
 
 seis:
 CJNE 20h,#20h,sete
 mov P2,#3Eh
 ret
 
 sete:
 CJNE 20h,#40h,oito
 mov P2,#0E0h
 ret
 
 oito:
 mov P2,#0FEh
 ret
 ;-----------------------------------------------------------------------------------------------
 BLOQUEIO:
 clr P3.7
 lcall TIMER2
 setb P3.7
 ljmp INICIO
 ret
 
 
 
 ;-----------------------------------------------------------------------------------------------
 code at 0200h
 INICIO:
 mov SP,#70h        ; Inicializa o regi ponteiro de pilha com o valor 70h (end. ;inicial da pilha)
 lcall CONFIG_HARD       ; Chama sub-rotina INIC_HARD para programar as portas
 lcall PROGT0        ; Configura Temporizador
 lcall SETUP        ; Chama rotina de padrão do cofre
 lcall SENHA        ; Chama rotina para verificar se o usuario quer alterar a senha
 lcall AGUARDA_TRAVA      ;Chama rotina para aguardar trava do cofre
 end            ; Fim do programa principal code
 
 
 
 
 
 
 
 
 
 
 
 
