#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA065TOK
Ponto de Entrada de confirmação de inclusao/alteracao de Grupo x Fornec.

@type function
@author Thiago Rasmussen
@since
@version P12.1.23

@obs Projeto ELO

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo sempre retorno Verdadeiro.
/*/
/*/================================================================================================================================/*/

User Function MA065TOK()

	Local lRet := .T.
	Local cOpc := IIF(INCLUI,"3","4")

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") /*Rotina ESB*//*Rotina CARGA*/

		SZZ->(dbSetOrder(1))

		IF SZZ->(dbSeek(XFilial("SZZ")+"MATA065"))

			MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA07(cOpc) } )

		Endif

	Endif

Return lRet
