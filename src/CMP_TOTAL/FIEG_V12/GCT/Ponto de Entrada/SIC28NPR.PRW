#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIC28NPR
Ponto de Entrada no momento da inclusão e exclusao da contacao do SC, Usado para limpar o numero do processo.

@type function
@author Eric do Nascimento
@since 17/02/2012
@version P12.1.23

@obs Projeto ELO

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function SIC28NPR()

	Local lRet   := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If !Empty(SC1->C1_NUMPR)
		RecLock("SC1",.F.)
		SC1->C1_NUMPR := ''
		SC1->( MsUnlock() )
	EndIf

Return lRet
