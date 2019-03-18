#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CT060INC
Ponto de Entrada apos inclusao de Classe Valor.

@type function
@author Thiago Rasmussen
@since 21/03/2012
@version P12.1.23

@obs Projeto ELO

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CT060INC()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") /*Rotina ESB*//*Rotina CARGA*/
		SZZ->(dbSetOrder(1))
		IF SZZ->(dbSeek(XFilial("SZZ")+"CTBA060"))
			MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA16(,3) } )
		ENDIF
	Endif

Return()
