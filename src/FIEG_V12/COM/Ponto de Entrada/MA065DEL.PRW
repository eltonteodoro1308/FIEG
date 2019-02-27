#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA065DEL
Ponto de Entrada apos exclusao de Grupo x Fornec.

@type function
@author Thiago Rasmussen
@since 18/05/12
@version P12.1.23

@obs Projeto ELO

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function MA065DEL()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") /*Rotina ESB*//*Rotina CARGA*/

		SZZ->(dbSetOrder(1))

		IF SZZ->(dbSeek(XFilial("SZZ")+"MATA065"))

			MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA07("5") } )

		EndIf

	Endif

Return
