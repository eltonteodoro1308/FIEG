#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CTA40DEL
Ponto de Entrada apos exclusao de Item Contabil.

@type function
@author Thiago Rasmussen
@since 21/03/2012
@version P12.1.23

@obs Projeto ELO

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Verdadeiro ou Falso para validação da exclusão do Item Contábil.

/*/
/*/================================================================================================================================/*/

User Function CTA40DEL()
	Local _lRet := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01")
		SZZ->(dbSetOrder(1))
		IF SZZ->(dbSeek(XFilial("SZZ")+"CTBA040"))
			MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA15(,5) } )
		ENDIF
	Endif

Return(_lRet)
