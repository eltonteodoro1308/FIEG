#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PadraoProtheusDoc
Valida��es espec�ficas de usu�rio, durante a inclus�o de um pedido de compra.

@type function
@author Thiago Rasmussen
@since 06/11/2013
@version P12.1.23

@obs Desenvolvimento FIEG - 02 - Compras

@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Retorna verdadeiro se valida��es OK.
/*/
/*/================================================================================================================================/*/

User Function MT120LOK()

	Local aArea		  := GetArea()
	Local _lRet		  := .T.
	Local cQuery	  := ""
	Local _C7_NUMSC   := aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "C7_NUMSC"})]
	Local _C7_ITEMSC  := aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "C7_ITEMSC"})]
	Local _C7_PRODUTO := aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})]
	Local _C7_QUANT   := aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "C7_QUANT"})]
	Local _C7_PRECO   := aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRECO"})]
	Local _QTDTOTAL   := 0
	Local _MV_XPEDSOL := SuperGetMV("MV_XPEDSOL", .F.)

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	IF Upper(Alltrim(FunName())) == "MATA121"
		//--< 01/10/2016 - Thiago Rasmussen - Consistir a inclus�o de pedido diretamente sem aprova��o da diretoria >--
		IF SC1->C1_XSTAPRO$'P;N;C'
			_lRet := .F.
			MsgStop("Verifique a aprova��o da diretoria para a solicita��o de compra " + SC1->C1_FILIAL + " / " + SC1->C1_NUM + ".","MT120LOK")
		EndIf

		//--< 01/10/2016 - Thiago Rasmussen - Consistir a inclus�o de pedido diretamente pelo mesmo usu�rio que incluiu a solicita��o >--
		IF RetCodUsr() == SC1->C1_USER
			_lRet := .F.
			MsgStop("N�o � permitido a inclus�o de pedidos de compra pelo mesmo usu�rio que incluiu a solicita��o de compra!","MT120LOK")
		EndIf

		//--< 06/11/2013 - Thiago Rasmussen - Alguns usu�rios espec�ficos v�o ter permiss�o de incluir PC diretamente associado a uma SC >--
		IF !(RetCodUsr() $(_MV_XPEDSOL))
			_lRet := .F.
			MsgStop("N�o � permitido a inclus�o de pedidos de compra diretamente associado a uma solicita��o de compra!","MT120LOK")
		EndIf

		IF _lRet .And. ! Empty(M->C7_NUMSC)
			//--< 06/11/2013 - Thiago Rasmussen - Consistir a quantidade e valor unit�rio da SC, como limite para PC >--
			cQuery := "SELECT C7_FILIAL, C7_PRODUTO, C7_NUMSC, C7_ITEMSC, SUM(C7_QUANT) AS QTDTOTAL "
			cQuery += "FROM " + RetSqlName('SC7') + " SC7 "
			cQuery += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
			cQuery += "  AND C7_NUMSC = '"  + SC1->C1_NUM + "' "
			cQuery += "  AND C7_ITEMSC = '" + SC1->C1_ITEM + "' "
			cQuery += "  AND SC7.D_E_L_E_T_ = ' ' "
			cQuery += "GROUP BY C7_FILIAL, C7_PRODUTO, C7_NUMSC, C7_ITEMSC "
			ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"QRY", .F., .T.)
			dbSelectArea("QRY")
			QRY->(dbGoTop())

			FOR i := 1 to Len(aCols)
				IF !aCols[i][Len(aHeader)+1] // Verifica se a linha n�o est� Deletada
					IF aCols[i][aScan(aHeader,{|x| AllTrim(x[2]) == "C7_NUMSC"})] == _C7_NUMSC .AND. aCols[i][aScan(aHeader,{|x| AllTrim(x[2]) == "C7_ITEMSC"})] == _C7_ITEMSC .AND. aCols[i][aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})] == _C7_PRODUTO
						_QTDTOTAL += aCols[i][aScan(aHeader,{|x| AllTrim(x[2]) == "C7_QUANT"})]
					EndIf
				EndIf
			NEXT

			_QTDTOTAL += QRY->QTDTOTAL

			IF Transform(_QTDTOTAL,"@e 999999999.99999999") > Transform(SC1->C1_QUANT,"@e 999999999.99999999")
				_lRet := .F.
				MsgStop("Foi realizada uma solicita��o de compra de " +;
				ALLTRIM(Transform(SC1->C1_QUANT,"@e 999,999,999.99")) +;
				" unidade(s) do produto/servi�o: " + ALLTRIM(SC1->C1_PRODUTO) +;
				" - " + ALLTRIM(SC1->C1_DESCRI) + CRLF + CRLF +;
				"A quantidade total de todos lan�amentos de compra desse item n�o deve ser maior que a quantidade solicitada acima." + CRLF + CRLF +;
				"Quantidade j� lan�ada: " + ALLTRIM(Transform(QRY->QTDTOTAL,"@e 999,999,999.99999999")) + " unidade(s)." + CRLF + CRLF +;
				"Saldo a ser lan�ado: " + ALLTRIM(Transform(SC1->C1_QUANT - QRY->QTDTOTAL,"@e 999,999,999.99999999")) + " unidade(s).","MT120LOK")
			EndIf

			IF _lRet
				IF _C7_PRECO > SC1->C1_VUNIT
					_lRet := .F.
					MsgStop("Foi realizada uma solicita��o de compra estimando a compra do produto/servi�o: " + ALLTRIM(SC1->C1_PRODUTO) + " - " + ALLTRIM(SC1->C1_DESCRI) + "  pelo valor unit�rio de  R$: " + ALLTRIM(Transform(SC1->C1_VUNIT,"@e 999,999,999.99")) + CRLF + CRLF + "O valor m�ximo para compra n�o deve ser maior que o valor estimado acima.","MT120LOK")
				EndIf
			EndIf
		EndIf
	EndIf

	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(_lRet)
