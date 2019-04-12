#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CTB040GR
Ponto de Entrada após inclusao/alteração de Item Contabil.

@type function
@author Thiago Rasmussen
@since 21/03/2012
@version P12.1.23

@obs Projeto ELO

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CTB040GR()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01")
		SZZ->(dbSetOrder(1))
		If SZZ->(dbSeek(XFilial("SZZ")+"CTBA040"))
			MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA15(,ParamIXB[1]) } )
		Endif
	Endif

Return()
