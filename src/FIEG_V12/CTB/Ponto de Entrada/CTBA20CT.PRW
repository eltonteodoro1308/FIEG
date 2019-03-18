#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CTBA20CT
Ponto de Entrada após manutencao (inclusão,alteração,exclusão) de Conta.

@type function
@author Thiago Rasmussen
@since 21/03/2012
@version P12.1.23

@obs Projeto ELO

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CTBA20CT()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//IF !lCTB020AUT
	//	MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA17(,ParamIXB) } )
	//EndIf

	If  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") /*Rotina ESB*//*Rotina CARGA*/
		SZZ->(dbSetOrder(1))
		If SZZ->(dbSeek(XFilial("SZZ")+"CTBA020"))
			MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA17(,ParamIXB) } )
		EndIf
	EndIf

Return()
