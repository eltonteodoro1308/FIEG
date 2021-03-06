#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CTA030TOK
Ponto de Entrada ap�s inclus�o de Centro de Custo.

@type function
@author Thiago Rasmussen
@since 21/03/2012
@version P12.1.23

@obs Projeto ELO

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso para a valida��o da inclus�o do Centro de Custo.

/*/
/*/================================================================================================================================/*/

User Function CTA030TOK()
	Local _lRet := .F.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") /*Rotina ESB*//*Rotina CARGA*/
		SZZ->(dbSetOrder(1))
		IF SZZ->(dbSeek(XFilial("SZZ")+"CTBA030"))
			MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA14(,ParamIXB) } )
		ENDIF
	Endif

Return(_lRet)
