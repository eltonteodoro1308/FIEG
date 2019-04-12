#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} FA080TIT
P.E. executado antes da grava��o da baixa dos t�tulos a pagar, para valida��es espec�ficas de usu�rios.

@type function
@author Thiago Rasmussen
@since 14/08/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, Retorna verdadeiro se valida��es estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function FA080TIT()

Local lRet := .T.

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF !lF080Auto
	IF dDataBase != DBAIXA
		MsgAlert("O seguinte t�tulo abaixo, n�o poder� ser baixado com database diferente da data de pagamento " + DTOC(DBAIXA) + "." + CRLF + CRLF +; 
				 "Filial: "     + SE2->E2_FILIAL  + CRLF +; 
				 "Prefixo: "    + SE2->E2_PREFIXO + CRLF +; 
				 "T�tulo: "     + SE2->E2_NUM     + CRLF +; 
				 "Parcela: "    + SE2->E2_PARCELA + CRLF +; 
				 "Tipo: "       + SE2->E2_TIPO    + CRLF +; 
				 "Fornecedor: " + AllTrim(SE2->E2_FORNECE) + " - " + AllTrim(SE2->E2_NOMFOR),"FA080TIT")
		lRet := .F.

	ElseIf dDataBase < SE2->E2_EMIS1
		MsgAlert("O seguinte t�tulo abaixo, n�o poder� ser baixado com database menor que data de provis�o " + DtoC(SE2->E2_EMIS1) + "." + CRLF + CRLF +; 
				 "Filial: "     + SE2->E2_FILIAL  + CRLF +; 
				 "Prefixo: "    + SE2->E2_PREFIXO + CRLF +; 
				 "T�tulo: "     + SE2->E2_NUM     + CRLF +; 
				 "Parcela: "    + SE2->E2_PARCELA + CRLF +; 
				 "Tipo: "       + SE2->E2_TIPO    + CRLF +; 
				 "Fornecedor: " + AllTrim(SE2->E2_FORNECE) + " - " + AllTrim(SE2->E2_NOMFOR),"FA080TIT")
		lRet := .F.
	EndIf
EndIf
	
Return lRet
