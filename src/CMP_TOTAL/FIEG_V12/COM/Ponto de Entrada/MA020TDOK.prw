#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA020TDOK
Valida��o das consist�ncias ap�s a digita��o da tela de Fornecedores.

@type function
@author Thiago Rasmussen
@since 22/04/2013
@version P12.1.23

@obs Desenvolvimento FIEG - Compras

@history 25/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, retorna verdadeiro se valida��es OK.
/*/
/*/================================================================================================================================/*/
                             
User Function MA020TDOK()

Local lRet	:= .T.

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If lRet .and. M->A2_TIPO != "X" .AND. EMPTY(M->A2_CGC)
	MsgAlert("O campo CNPJ/CPF para esse fornecedor � obrigat�rio.","MA020TDOK")     	
	lRet	:= .F.
EndIf

If lRet .and. M->A2_TIPO == "J" .AND. LEN(ALLTRIM(M->A2_CGC)) != 14
	MsgAlert("Verifique o CNPJ informado.","MA020TDOK")     	
	lRet	:= .F.
EndIf

If lRet .and. M->A2_TIPO == "F" .AND. LEN(ALLTRIM(M->A2_CGC)) != 11
	MsgAlert("Verifique o CPF informado.","MA020TDOK")     	
	lRet	:= .F.
EndIf

If lRet .and. M->A2_TIPO == "F" .AND. EMPTY(M->A2_NIT)
	MsgAlert("O campo NIT/PIS para esse fornecedor � obrigat�rio.","MA020TDOK")     	
	lRet	:= .F.
EndIf

Return lRet
