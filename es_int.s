* Inicializa el SP  y el PC
**************************
        ORG     $0
        DC.L    $8000           * Pila
       	*DC.L    INICIO          * PC

        ORG     $400

* Definici�n de equivalencias
*********************************

MR1A    EQU     $effc01       * de modo A (escritura)
MR2A    EQU     $effc01       * de modo A (2� escritura)
SRA     EQU     $effc03       * de estado A (lectura)
CSRA    EQU     $effc03       * de seleccion de reloj A (escritura)
CRA     EQU     $effc05       * de control A (escritura)
TBA     EQU     $effc07       * buffer transmision A (escritura)
RBA     EQU     $effc07       * buffer recepcion A  (lectura)
ACR	EQU	$effc09	      * de control auxiliar
IMR     EQU     $effc0B       * de mascara de interrupcion A (escritura)
ISR     EQU     $effc0B       * de estado de interrupcion A (lectura)
MR1B    EQU     $effc11       * de modo B (escritura)
MR2B    EQU     $effc11       * de modo B (2� escritura)
CRB     EQU     $effc15	      * de control A (escritura)
TBB     EQU     $effc17       * buffer transmision B (escritura)
RBB	EQU	$effc17       * buffer recepcion B (lectura)
SRB     EQU     $effc13       * de estado B (lectura)
CSRB	EQU	$effc13       * de seleccion de reloj B (escritura)
IVR	EQU	$effc19

CR	EQU	$0D	      * Carriage Return
LF	EQU	$0A	      * Line Feed
FLAGT	EQU	2	      * Flag de transmisi�n
FLAGR   EQU     0	      * Flag de recepci�n

* Variables auxiliares
COPIAIMR:	DC.B 0
		DC.B 0


**************************** INIT *************************************************************
INIT:
        MOVE.B          #%00010000,CRA      * Reinicia el puntero MR1
        MOVE.B          #%00000011,MR1A     * 8 bits por caracter.
        MOVE.B          #%00000000,MR2A     * Eco desactivado.
        MOVE.B          #%11001100,CSRA     * Velocidad = 38400 bps.
        MOVE.B          #%00000000,ACR      * Velocidad = 38400 bps.
        MOVE.B          #%00000101,CRA      * Transmision y recepcion activados.ç

	*Inicializacion linea B
        MOVE.B          #%00010000,CRB      * Reinicia el puntero MR1
        MOVE.B          #%00000011,MR1B     * 8 bits por caracter.
        MOVE.B          #%00000000,MR2B     * Eco desactivado.
        MOVE.B          #%11001100,CSRB     * Velocidad = 38400 bps.
        MOVE.B          #%00000101,CRB      * Transmision y recepcion activados 

        MOVE.B          #%00100010,COPIAIMR
        MOVE.B          COPIAIMR,IMR
        MOVE.B          #$040,IVR

	MOVE.L		#RTI,$100

        BSR             INI_BUFS
        RTS
**************************** FIN INIT *********************************************************

**************************** PRINT ************************************************************
PRINT:
	LINK		A6,#0
	MOVE.L		8(A6),A0 * Buffer
	EOR.L		D0,D0
	EOR.L		D1,D1
	EOR.L		D2,D2
	MOVE.W		12(A6),D1 * Descriptor
	MOVE.W		14(A6),D2 * Tamano
	EOR.L		D4,D4 * contador caracteres leidos

	CMP.W		#0,D1 * si es 0, hay que escribir en linea A
	BEQ		PR_A
	CMP.W		#1,D1 * si es 1, hay que escirbir en linea B
	BEQ		PR_B
	CMP.W		#0,D2 * tamano no puede ser negativo o error params
	BLT		FIN_PR_M
	BRA		FIN_PR_M

PR_A:
	MOVE.L		D4,D0
	CMP.W		#0,D2 * si tamano no es 0 seguimos
	BEQ		FIN_PR
	MOVE.B		(A0)+,D1 * char del buffer leido
	EOR.L		D0,D0
	MOVE.L		#2,D0 * transmision en linea a
	BSR		ESCCAR
        BSET            #0,COPIAIMR
        MOVE.B          COPIAIMR,IMR * interrupcion
	CMP.L		#$ffffffff,D0 * no caben mas caracteres en el buffer
	BEQ		FIN_PR
        SUB.W           #1,D2 * tamano-
	ADD.L		#1,D4
	CMP.W		D4,D2 * si tamano y el num de caracteres que hemos escrito son iguales, fin
	BEQ		FIN_PR
	BRA		FIN_PR

PR_B:
	MOVE.L          D4,D0
        CMP.W           #0,D2 * si tamano no es 0 seguimos
        BEQ             FIN_PR
        MOVE.B          (A0)+,D1 * char del buffer leido
        EOR.L           D0,D0
        MOVE.L          #3,D0 * transmision en linea b
        BSR             ESCCAR
        BSET            #3,COPIAIMR
        MOVE.B          COPIAIMR,IMR * interrupcion
        CMP.L           #$ffffffff,D0 * no caben mas caracteres en el buffer
        BEQ             FIN_PR
        SUB.W           #1,D2 * tamano--
        ADD.L           #1,D4
        CMP.W           D4,D2 * si tamano y el num de caracteres que hemos escrito son iguales, fin
        BEQ             FIN_PR
        BRA             FIN_PR

FIN_PR_M:
	MOVE.L		#$ffffffff,D4

FIN_PR:	MOVE.L          D4,D0
        UNLK            A6
        RTS

**************************** FIN PRINT ********************************************************

**************************** SCAN ************************************************************
SCAN:
	LINK		A6,#0
	MOVE.L		8(A6),A0 * Buffer
        EOR.L           D0,D0
        EOR.L           D1,D1
        EOR.L           D2,D2
        MOVE.W          12(A6),D1 * Descriptor
        MOVE.W          14(A6),D2 * Tamano
        EOR.L           D4,D4 * contador caracteres leidos

	CMP.W		#0,D1 * si es 0, hay que leer de linea A
	BEQ		SC_A
	CMP.W		#1,D1 * si es 1, hay que leer de linea B
	BEQ		SC_B
	BRA		FIN_SC_M

SC_A:
	MOVE.L		D4,D0
	CMP.W		#0,D2 * si tamano no es 0 seguimos
	BEQ		FIN_SC
	MOVE.L		#0,D0 * recepcion linea A
	BSR		LEECAR
	CMP.L		#$ffffffff,D0 * buffer vacio
	BEQ		FIN_SC
	MOVE.B		D0,(A0)+ * char leido lo metemos en el buffer
	SUB.W		#1,D2 * tamano--
	ADD.L		#1,D4
	CMP.W		D4,D2 * si tamano y num de caracteres son iguales, fin
	BEQ		FIN_SC
	BRA		FIN_SC

SC_B:
        MOVE.L          D4,D0
        CMP.W           #0,D2 * si tamano no es 0 seguimos
        BEQ             FIN_SC
        MOVE.L          #1,D0 * recepcion linea B
        BSR             LEECAR
        CMP.L           #$ffffffff,D0 * buffer vacio
        BEQ             FIN_SC
        MOVE.B          D0,(A0)+ * char leido lo metemos en el buffer
        SUB.W           #1,D2 * tamano--
        ADD.L           #1,D4
        CMP.W           D4,D2 * si tamano y num de caracteres son iguales, fin
        BEQ             FIN_SC
        BRA             FIN_SC

FIN_SC_M:
	MOVE.L		#$ffffffff,D4
FIN_SC:
	MOVE.L		D4,D0
	UNLK		A6
	RTS

**************************** RTI *************************************************************

RTI:
	LINK		A6,#0
	EOR.L		D1,D1
	EOR.L		D2,D2
	MOVE.B		ISR,D1
	AND.B		COPIAIMR,D1 * algun bit de ISR a 1 y mismo bit de IMR a 1
	CMP.B		#0,D1
	BNE		FIN_RTI

	BTST		#0,D1 * si es el bit 0, transmision en A
	BNE		RTI_TRAA
	BTST		#4,D1 * si es el bit 4, transmision en B
	BNE		RTI_TRAB
	BTST		#1,D1
	BNE		RTI_RECA
	BTST		#5,D1
	BNE		RTI_RECB

RTI_TRAA:
	MOVE.L		#2,D0 * transmision por linea A
	BSR		LEECAR
	CMP.B		#$ffffffff,D0 * buffer vacio
	BEQ		FIN_T_A
	MOVE.B		D0,TBA * caracter a linea A
	BRA		RTI

FIN_T_A:
	MOVE.B		COPIAIMR,D1
	BCLR		#0,D1
	MOVE.B		D1,COPIAIMR
	MOVE.B		COPIAIMR,IMR * no hay mas que trasnmitir, desactivada transmision por A
	BRA		FIN_RTI

RTI_TRAB:
	MOVE.L		#3,D0 * transmision por linea B
	BSR		LEECAR
	CMP.B		#$ffffffff,D0
	BEQ		FIN_T_B
	MOVE.B		D0,TBB
	BRA		RTI

FIN_T_B:
	MOVE.B		COPIAIMR,D1
	BCLR		#0,D1
	MOVE.B		D1,COPIAIMR
	MOVE.B		COPIAIMR,IMR
	BRA		FIN_RTI

RTI_RECA:
	MOVE.L		#0,D0 * recepcion por linea a
	MOVE.B		RBA,D1 * caracter de linea a a D1
	BSR		ESCCAR
	CMP.B		#$ffffffff,D0 * buffer lleno
	BEQ		FIN_R_A
	BRA		RTI

RTI_RECB:
	MOVE.L		#1,D0
	MOVE.B		RBB,D1
	BSR		ESCCAR
	CMP.B		#$ffffffff,D0 * buffer lleno
	BEQ		FIN_R_B

FIN_R_A:
FIN_R_B:
FIN_RTI:
	UNLK		A6
	RTE

**************************** FIN RTI *********************************************************

**************************** FIN PROGRAMA PRINCIPAL ******************************************

**************************** PROGRAMA PRINCIPAL **********************************************
*TAMANO EQU 1

* INICIO: BSR             INIT                * Inicia el controlador
* OTRO:   MOVE.W  	#TAMANO,-(A7)
* 	MOVE.L          #$5000,-(A7)        * Prepara la direcci�n del buffer
*        BSR             SCAN                * Recibe la linea
*        ADD.L           #6,A7               * Restaura la pila
* 	MOVE.W  	#TAMANO,-(A7)
*         MOVE.L          #$5000,-(A7)        * Prepara la direcci�n del buffer
*         BSR             PRINT               * Imprime l�nea
*         ADD.L           #6,A7               * Restaura la pila
* 	BRA		OTRO

*        BREAK

BUFFER: DS.B 2100 * Buffer para lectura y escritura de caracteres
PARDIR: DC.L 0 * Direcci ́on que se pasa como par ́ametro
PARTAM: DC.W 0 * Tama~no que se pasa como par ́ametro
CONTC: DC.W 0 * Contador de caracteres a imprimir
DESA: EQU 0 * Descriptor l ́ınea A
DESB: EQU 1 * Descriptor l ́ınea B
TAMBS: EQU 30 * Tama~no de bloque para SCAN
TAMBP: EQU 7 * Tama~no de bloque para PRINT

* Manejadores de excepciones
INICIO: 
	MOVE.L #BUS_ERROR,8 * Bus error handler
	MOVE.L #ADDRESS_ER,12 * Address error handler
	MOVE.L #ILLEGAL_IN,16 * Illegal instruction handler
	MOVE.L #PRIV_VIOLT,32 * Privilege violation handler
	MOVE.L #ILLEGAL_IN,40 * Illegal instruction handler
	MOVE.L #ILLEGAL_IN,44 * Illegal instruction handler
	BSR INIT
	MOVE.W #$2000,SR * Permite interrupciones

BUCPR:
	MOVE.W #TAMBS,PARTAM * Inicializa par ́ametro de tama~no
	MOVE.L #BUFFER,PARDIR * Par ́ametro BUFFER = comienzo del buffer
OTRAL: 
	MOVE.W PARTAM,-(A7) * Tama~no de bloque
	MOVE.W #DESA,-(A7) * Puerto A
	MOVE.L PARDIR,-(A7) * Direcci ́on de lectura
ESPL:
	BSR SCAN
	ADD.L #8,A7 * Restablece la pila
	ADD.L D0,PARDIR * Calcula la nueva direcci ́on de lectura
	SUB.W D0,PARTAM * Actualiza el n ́umero de caracteres le ́ıdos
	BNE OTRAL * Si no se han le ́ıdo todas los caracteres del bloque se vuelve a leer
	MOVE.W #TAMBS,CONTC * Inicializa contador de caracteres a imprimir
	MOVE.L #BUFFER,PARDIR * Par ́ametro BUFFER = comienzo del buffer
OTRAE:
	MOVE.W #TAMBP,PARTAM * Tama~no de escritura = Tama~no de bloque
ESPE:
	MOVE.W PARTAM,-(A7) * Tama~no de escritura
	MOVE.W #DESB,-(A7) * Puerto B
	MOVE.L PARDIR,-(A7) * Direcci ́on de escritura
	BSR PRINT
	ADD.L #8,A7 * Restablece la pila
	ADD.L D0,PARDIR * Calcula la nueva direcci ́on del buffer
	SUB.W D0,CONTC * Actualiza el contador de caracteres
	BEQ SALIR * Si no quedan caracteres se acaba
	SUB.W D0,PARTAM * Actualiza el tama~no de escritura
	BNE ESPE * Si no se ha escrito todo el bloque se insiste
	CMP.W #TAMBP,CONTC * Si el no de caracteres que quedan es menor que el tama~no establecido se imprime ese n ́umero
	BHI OTRAE * Siguiente bloque
	MOVE.W CONTC,PARTAM
	BRA ESPE * Siguiente bloque
SALIR:
	BRA BUCPR
BUS_ERROR: 
	BREAK * Bus error handler
	NOP
ADDRESS_ER:
	BREAK * Address error handler
	NOP
ILLEGAL_IN:
	BREAK * Illegal instruction handler
	NOP
PRIV_VIOLT:
	BREAK * Privilege violation handler
	NOP





**************************** FIN PROGRAMA PRINCIPAL ******************************************

INCLUDE bib_aux.s
