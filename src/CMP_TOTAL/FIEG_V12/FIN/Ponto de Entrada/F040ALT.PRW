#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} function_method_class_name
Ponto de Entrada após alteracao do título a receber.

@type function
@author Thiago Rasmussen
@since 29/05/2012
@version P12.1.23

@obs Projeto ELO

@history 12/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function F040ALT()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF !IsInCallStack("U_SICFGA01") /*Rotina CARGA*/
		SZZ->(dbSetOrder(1))
		IF SZZ->(dbSeek(XFilial("SZZ")+"FINA040"))
			IF SE1->(FieldPos("E1_XIDESB")) > 0 .and. !Empty(SE1->E1_XIDESB)
				MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA05(,"4") } )
			ENDIF
		ENDIF

	ENDIF

Return()
