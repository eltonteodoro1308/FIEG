#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} A010TOK
Função de validação para inclusão ou alteração do produto.

@type function
@author Thiago Rasmussen
@since 14/12/2018
@version P12.1.23

@obs Desenvolvimento FIEG - Compras

@history 22/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return lRet, retorno verdadeiro de validação OK.
/*/
/*/================================================================================================================================/*/

User Function A010TOK()

Local lRet	:= .T.
//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If M->B1_TIPO == 'SV' .AND. Empty(M->B1_CODISS)
	MsgAlert('Para os produtos do tipo serviço é obrigatório informar o Código ISS!','A010TOK')
	lRet := .F.
EndIf

Return lRet