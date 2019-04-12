#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} LP597589
Retorna a Conta Contábil, Centro de Custo ou Item Contábil conforme a opção e tipo solicitado.

@type function
@author Carlos Henrique
@since 27/03/2013
@version P12.1.23

@param nOpc, Numérico, Indica o tipo de documento 1 = PA / 2 = NF.
@param nTipo, Numérico, Indica o tipo de entidade contábil a ser retornada 1 = Conta Contábil / 2 = Centro de Custo / 3 = Item Contábil

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Conta Contábil, Centro de Custo ou Item Contábil conforme parâmetros de requisição.

/*/
/*/================================================================================================================================/*/

USER FUNCTION LP597589(nOpc,nTipo)
	LOCAL aArea		:= GETAREA()
	LOCAL aAreaSE2	:= SE2->(GETAREA())
	LOCAL xVal		:= ""
	LOCAL cChav		:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	
	IF FUNNAME()!="FINA370"

		IF SELECT("SE2") == 0
			DBSELECTAREA("SE2")
		ENDIF

		IF nTipo == 1 // PA
			SE2->(DBSETORDER(1))
			IF SE2->(DBSEEK(XFILIAL("SE2")+STRLCTPAD))
				IF TRIM(SE2->E2_TIPO) == "PA"
					DO CASE
						CASE nOpc == 1 // CONTA
						xVal:= SE2->E2_CONTAD
						CASE nOpc == 2 // CENTRO DE CUSTO
						xVal:= SE2->E2_CCD
						CASE nOpc == 3 // ITEM CONTABIL
						xVal:= SE2->E2_ITEMD
					ENDCASE
				ELSE
					// Tratamento para compensação de apenas um titulo.
					IF !EMPTY(aTitulos)
						IF TRIM(aTitulos[1][4]) == "PA"
							cChav:= PADR(aTitulos[1][1],LEN(SE2->E2_PREFIXO))+PADR(aTitulos[1][2],LEN(SE2->E2_NUM))+PADR(aTitulos[1][3],LEN(SE2->E2_PARCELA))+PADR(aTitulos[1][4],LEN(SE2->E2_TIPO))+cFornece+cLoja
						ELSE
							cChav:= aTitulos[1][6]+cFornece+cLoja
						ENDIF
						IF SE2->(DBSEEK(XFILIAL("SE2")+cChav))
							IF TRIM(SE2->E2_TIPO) == "PA"
								DO CASE
									CASE nOpc == 1 // CONTA
									xVal:= SE2->E2_CONTAD
									CASE nOpc == 2 // CENTRO DE CUSTO
									xVal:= SE2->E2_CCD
									CASE nOpc == 3 // ITEM CONTABIL
									xVal:= SE2->E2_ITEMD
								ENDCASE
							ENDIF
						ENDIF
					ENDIF
				ENDIF
			ENDIF
		ELSEIF nTipo == 2 // NF
			SE2->(DBSETORDER(1))
			IF SE2->(DBSEEK(XFILIAL("SE2")+STRLCTPAD))
				IF TRIM(SE2->E2_TIPO) == "NF"
					DO CASE
						CASE nOpc == 1 // CONTA
						xVal:= SE2->E2_CONTAD
						CASE nOpc == 2 // CENTRO DE CUSTO
						xVal:= SE2->E2_CCD
						CASE nOpc == 3 // ITEM CONTABIL
						xVal:= SE2->E2_ITEMD
					ENDCASE
				ELSE
					// Tratamento para compensação de apenas um titulo.
					IF !EMPTY(aTitulos)
						IF TRIM(aTitulos[1][4]) == "PA"
							cChav:= aTitulos[1][6]+cFornece+cLoja
						ELSE
							cChav:= PADR(aTitulos[1][1],LEN(SE2->E2_PREFIXO))+PADR(aTitulos[1][2],LEN(SE2->E2_NUM))+PADR(aTitulos[1][3],LEN(SE2->E2_PARCELA))+PADR(aTitulos[1][4],LEN(SE2->E2_TIPO))+cFornece+cLoja
						ENDIF
						IF SE2->(DBSEEK(XFILIAL("SE2")+cChav))
							IF TRIM(SE2->E2_TIPO) == "NF"
								DO CASE
									CASE nOpc == 1 // CONTA
									xVal:= SE2->E2_CONTAD
									CASE nOpc == 2 // CENTRO DE CUSTO
									xVal:= SE2->E2_CCD
									CASE nOpc == 3 // ITEM CONTABIL
									xVal:= SE2->E2_ITEMD
								ENDCASE
							ENDIF
						ENDIF
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	ENDIF

	RESTAREA(aAreaSE2)
	RESTAREA(aArea)
RETURN xVal
