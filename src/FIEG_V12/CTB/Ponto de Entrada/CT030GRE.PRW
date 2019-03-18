#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CT030GRE
Ponto de Entrada para validação de exclusão de Centro de Custo.

@type function
@author Thiago Rasmussen
@since 21/03/2012
@version P12.1.23

@obs Projeto ELO

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CT030GRE()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") /*Rotina ESB*//*Rotina CARGA*/
		SZZ->(dbSetOrder(1))
		IF SZZ->(dbSeek(XFilial("SZZ")+"CTBA030"))
			MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA14(,5) } )
		ENDIF

	Endif

Return()
