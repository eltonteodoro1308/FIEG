#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} A010TOK
Fun��o de valida��o para inclus�o ou altera��o do produto.

@type function
@author Thiago Rasmussen
@since 14/12/2018
@version P12.1.23

@obs Desenvolvimento FIEG - Compras

@history 22/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return lRet, retorno verdadeiro de valida��o OK.
/*/
/*/================================================================================================================================/*/

User Function A010TOK()

Local lRet	:= .T.
//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If M->B1_TIPO == 'SV' .AND. Empty(M->B1_CODISS)
	MsgAlert('Para os produtos do tipo servi�o � obrigat�rio informar o C�digo ISS!','A010TOK')
	lRet := .F.
EndIf

Return lRet