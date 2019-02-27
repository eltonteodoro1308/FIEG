#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA035ALT
Ponto de Entrada após alteração de grupos de produto.

@type function
@author Thiago Rasmussen
@since 18/05/2012
@version P12.1.23

@obs Projeto ELO

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function MA035ALT()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If ! IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") /*Rotina ESB*//*Rotina CARGA*/

		SZZ->(dbSetOrder(1))

		IF SZZ->(dbSeek(XFilial("SZZ")+"MATA035"))

			MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA11("4") } )

		Endif

	Endif

Return