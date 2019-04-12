#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT100TOK
Ponto de entrada no tudook do documento de entrada.

@type function
@author Carlos Henrique
@since 18/03/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação do Documento de Entrada.

/*/
/*/================================================================================================================================/*/

User Function MT100TOK()
	Local lRet		:= .T.
	Local cNat		:= MaFisRet(,"NF_NATUREZA")
	Local nValIrr	:= MaFisRet(,"NF_VALIRR")

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If EMPTY(cNat)
		lRet:=.F.
		Alert("Obrigatório o preenchimento da natureza!")
	EndIf

	If nValIrr > 0 .and. Empty(cCodRet)
		lRet:=.F.
		Alert("Obrigatório o preenchimento do Código de Retenção do IRRF na aba 'Impostos'")
	EndIf

Return lRet