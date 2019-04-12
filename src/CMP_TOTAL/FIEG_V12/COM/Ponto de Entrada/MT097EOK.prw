#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT097EOK
Ponto de Entrada localizado no início da função de estorno das liberações dos documentos do Compras. É executado no momento em que o usuário clicar em "Estornar" (Executado somente para estorno de aprovação de pedido).

@type function
@author Thiago Rasmussen
@since 15/08/2016
@version P12.1.23

@obs Desenvolvimento FIEG - 02 - Compras

@history 26/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, retorna verdadeiro se validações OK.
/*/
/*/================================================================================================================================/*/

User Function MT097EOK()

Local lRet	 := .T.
Local _ALIAS := GetNextAlias()
Local _QUERY := ""

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If FUNNAME() == "MATA097"  
	IF SCR->CR_TIPO == 'PC'
		_QUERY := "select distinct D1_FILIAL, D1_DOC, D1_SERIE, rtrim(D1_FORNECE) + ' - ' + rtrim(isnull(A2_NOME,'')) AS D1_FORNECE " + CRLF +;
		          "from "      + RETSQLNAME("SD1") + " SD1 with (nolock) " + CRLF +;
		          "left join " + RETSQLNAME("SA2") + " SA2 with (nolock) on SA2.D_E_L_E_T_ = ' ' " + CRLF +;
				  "  and A2_FILIAL = '" + xFilial('SA2') + "' "+ CRLF +;
				  "  and A2_COD    = D1_FORNECE " + CRLF +;
				  "  and A2_LOJA   = D1_LOJA "	  + CRLF +;
		          "where SD1.D_E_L_E_T_ = ' ' "   + CRLF +;
				  "  and D1_FILIAL = '" + SCR->CR_FILIAL + "' " + CRLF +;
		          "	 and D1_PEDIDO = '" + SCR->CR_NUM    + "' "
		
		TcQuery _QUERY NEW ALIAS (_ALIAS)	                                                   
		(_ALIAS)->(DbGoTop())
		
		If !(_ALIAS)->(Eof())
			MsgInfo("Estorno não pode ser realizado devido a existência de uma nota fiscal já relacionada a esse pedido de compra!" + CRLF + CRLF + ;
			        "Filial: "      + (_ALIAS)->D1_FILIAL + CRLF + ;
			        "Nota Fiscal: " + (_ALIAS)->D1_DOC    + CRLF + ;
			        "Serie: "       + (_ALIAS)->D1_Serie  + CRLF + ;
			        "Fornecedor: "  + (_ALIAS)->D1_FORNECE, "MT097EOK") 
			(_ALIAS)->(DbCloseArea())                  
			lRet := .F.
		EndIf
	EndIf                   
EndIf

If Select(_ALIAS) > 0
	(_ALIAS)->(dbCloseArea())
EndIf

Return lRet
