#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA235PC
Fun��o executada antes de processar uma elimina��o de res�duos.

@type function
@author Thiago Rasmussen
@since 07/11/2013
@version P12.1.23

@obs Desenvolvimento FIEG - 02 Compras

@history 26/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, retorna verdadeiro se valida��es OK.
/*/
/*/================================================================================================================================/*/

User Function MA235PC()  

Local lRet		  := .T.
Local _ALIAS      := GetNextAlias()
Local _QUERY      := "" 
Local _FORNECEDOR := ""
Local _MENSAGEM   := ""

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Evitar que o processo de elimina��o de res�duos seja executado em faixa de registros. Exemplo: De 000001 � 999999 >--
IF RetCodUsr() != '000046' .OR. EMPTY(MV_PAR05)
	MV_PAR05 := MV_PAR04	
ENDIF

IF MV_PAR04 != MV_PAR05	
	_MENSAGEM := "O processo de elimina��o de res�duos � irrevers�vel, confirma sua execu��o?" + CRLF + CRLF + "Filial: " + cFILANT + " - " + FWFILIALNAME() + CRLF + IIF(MV_PAR08==1,"Pedido de Compra: ","Solicita��o de Compra: ") + MV_PAR04 + " � " + MV_PAR05
	MsgAlert("Foi informado um intervalo de registros para executar o processo de elimina��o de res�duos!!!","A T E N � � O")
ELSE
	_MENSAGEM := "O processo de elimina��o de res�duos � irrevers�vel, confirma sua execu��o?" + CRLF + CRLF + "Filial: " + cFILANT + " - " + FWFILIALNAME() + CRLF + IIF(MV_PAR08==1,"Pedido de Compra: ","Solicita��o de Compra: ") + MV_PAR04	
               
	//--< 11/11/2016 - Jos� Fernando - Caso o pedido de compra esteja relacionado a uma NF pendente de classifica��o, impedir a elimina��o de res�duo do pedido >--
	IF MV_PAR08 = 1 
		_FORNECEDOR := Posicione("SC7", 1, cFILANT+MV_PAR04, "C7_FORNECE") 
	
		_QUERY  = " SELECT D1_FILIAL, D1_DOC, D1_SERIE, D1_EMISSAO, D1_FORNECE, A2_NOME"
		_QUERY += " FROM SD1010 AS SD1 WITH (NOLOCK)"
		_QUERY += " LEFT JOIN SA2010 AS SA2 WITH (NOLOCK) ON SA2.D_E_L_E_T_ = ' '"
		_QUERY += "   AND A2_FILIAL = '" + xFilial("SA2") + "'"
		_QUERY += "   AND A2_COD    = D1_FORNECE "
		_QUERY += " WHERE SD1.D_E_L_E_T_ = ' '"
		_QUERY += "   AND SD1.D1_FILIAL  = '" + cFILANT + "'"
		_QUERY += "   AND SD1.D1_PEDIDO  = '" + MV_PAR04 + "'"
		_QUERY += "   AND SD1.D1_FORNECE = '" + _FORNECEDOR + "'"
		_QUERY += "   AND SD1.D1_LOJA    = '0001'"  
		_QUERY += "   AND SD1.D1_TES     = '' " 
		
		If Select(_ALIAS) > 0
			(_ALIAS)->(dbCloseArea())
		EndIf
		 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_QUERY),_ALIAS,.T.,.F.)
		                                                                      
		(_ALIAS)->(dbGotop())
	                                       
		While !(_ALIAS)->(Eof())
			MsgStop("O processamento foi abortado pois existe pr�-nota para este pedido de compra aguardando classifica��o fiscal." + CRLF + CRLF +; 
			        "Filial: " + (_ALIAS)->D1_FILIAL + CRLF +; 
			        "Nota Fiscal: " + ALLTRIM((_ALIAS)->D1_DOC) + " / " + ALLTRIM((_ALIAS)->D1_SERIE) + CRLF +;
			        "Fornecedor: " + ALLTRIM((_ALIAS)->D1_FORNECE) + " - " + ALLTRIM((_ALIAS)->A2_NOME) + CRLF +; 
			        "Data: " + DTOC(STOD((_ALIAS)->D1_EMISSAO)) +  "","MA235PC")
			lRet := .F.
		End
	Endif         
EndIf	

If lRet .and. !MSGYESNO(_MENSAGEM, "MA235PC")
	lRet := .F.
EndIf

If Select(_ALIAS) > 0
	(_ALIAS)->(dbCloseArea())
EndIf

Return lRet
