#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} M030EXC
Ponto de Entrada após exclusão de clientes.

@type function
@author Thiago Rasmussen
@since 19/02/2012
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function M030EXC()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") /*Rotina ESB*//*Rotina CARGA*/
		SZZ->(dbSetOrder(1))
		IF SZZ->(dbSeek(XFilial("SZZ")+"MATA030"))
			MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA01() } )
		ENDIF

	ENDIF


Return()
