#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} LPVERBRT
Retorna valor bruto do titulo.

@type function
@author Carlos Henrique
@since 27/03/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Valor Bruto do Título.

/*/
/*/================================================================================================================================/*/

User Function LPVERBRT()
	Local aAreaSE2	:= SE2->(GetArea())
	Local nVal		:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	
	If Empty(SE2->E2_XNUMTRF) .OR. (!EMPTY(SE2->E2_XNUMTRF) .AND. SE2->E2_PREFIXO == 'TTX')

		If Trim(SE2->E2_NATUREZ)=="PLANO"
			nVal:= SE2->E2_VALOR + SE2->E2_ISS + SE2->E2_IRRF
		ElseIf  SE2->E2_BASEIRF > 0
			If SED->ED_BASEIRF > 0
				nVal:= NoRound(((M->E2_VALOR * 100) / SED->ED_BASEIRF),2)
			Else
				nVal:= SE2->E2_BASEIRF
			EndIf
		ElseIf SE2->E2_BASEPIS > 0
			If SED->ED_BASEPIS > 0
				nVal:= NoRound(((M->E2_VALOR * 100) / SED->ED_BASEPIS),2)
			Else
				nVal:= SE2->E2_BASEPIS
			EndIf
		ElseIf SE2->E2_BASEISS > 0
			If SED->ED_BASEISS > 0
				nVal:= NoRound(((M->E2_VALOR * 100) / SED->ED_BASEISS),2)
			Else
				nVal:= SE2->E2_BASEISS
			EndIf
		ElseIf SE2->E2_BASEINS > 0
			If SED->ED_BASEINS > 0
				nVal:= NoRound(((M->E2_VALOR * 100) / SED->ED_BASEINS),2)
			Else
				nVal:= SE2->E2_BASEINS
			EndIf
		Else
			nVal:= SE2->E2_VALOR
		EndIf
	EndIf
	RestArea(aAreaSE2)
Return nVal
