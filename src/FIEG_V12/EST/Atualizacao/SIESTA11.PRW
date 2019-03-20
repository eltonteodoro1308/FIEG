#Include "Protheus.ch"
#Include "TopConn.Ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIESTA11
Valida o valor total digitado com o pedido de compras.

@type function
@author Thiago Rasmussen
@since
@version P12.1.23

@param lPre, Lógico, .T. = Pre nota / .F. = Documento de entrada

@obs Projeto ELO alterado pela FIEG

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação do valor total digitado com o pedido de compras.

/*/
/*/================================================================================================================================/*/

User Function SIESTA11(lPre)

	Local aAreaSC7	 := SC7->(GETAREA())
	Local aAreaSD1	 := SD1->(GETAREA())
	Local pD1_ITEM   := ASCAN(aHeader,{|x| TRIM(x[2])=="D1_ITEM" })
	Local pD1_PEDIDO := ASCAN(aHeader,{|x| TRIM(x[2])=="D1_PEDIDO" })
	Local pD1_ITEMPC := ASCAN(aHeader,{|x| TRIM(x[2])=="D1_ITEMPC" })
	Local pD1_TOTAL	 := ASCAN(aHeader,{|x| TRIM(x[2])=="D1_TOTAL" })
	Local pD1_QUANT	 := ASCAN(aHeader,{|x| TRIM(x[2])=="D1_QUANT" })
	Local cPict		 := PESQPICT("SD1","D1_TOTAL")
	Local SALDO_PC	 := 0
	Local TOTAL_NF	 := 0
	Local cTab		 := ""
	Local cQry		 := ""
	Local lRESULTADO := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If pD1_ITEM > 0 .And. pD1_PEDIDO > 0 .And. pD1_ITEMPC > 0 .And. pD1_TOTAL > 0
		// Verifica Pré-Notas já lançadas
		cTab := GetNextAlias()
		cQry := "SELECT ISNULL(SUM(D1_QUANT),0) AS D1_QUANT FROM " + RETSQLNAME("SD1") + " SD1 WITH (NOLOCK) " + CRLF +;
		"WHERE D1_FILIAL = '" + XFILIAL("SD1") + "' AND " + CRLF +;
		"      D1_PEDIDO = '" + acols[n][pD1_PEDIDO] + "' AND " + CRLF +;
		"      D1_ITEMPC = '" + acols[n][pD1_ITEMPC] + "' AND " + CRLF +;
		"      LTRIM(RTRIM(D1_DOC)) + LTRIM(RTRIM(D1_SERIE)) <> '" + ALLTRIM(CNFISCAL) + ALLTRIM(CSERIE) + "' AND " + CRLF +;
		"      SD1.D_E_L_E_T_ = ''"
		TcQuery cQry NEW ALIAS (cTab)
		(cTab)->(dbSelectArea((cTab)))
		(cTab)->(dbGoTop())
		TOTAL_NF := (cTab)->D1_QUANT
		(cTab)->(DbCloseArea())

		DbSelectArea("SC7")
		SC7->(DBGOTOP())
		SC7->(DBSETORDER(1))
		If SC7->(DBSEEK(XFILIAL("SC7") + acols[n][pD1_PEDIDO] + acols[n][pD1_ITEMPC]))
			SALDO_PC := (SC7->C7_QUANT - (TOTAL_NF + acols[n][pD1_QUANT])) * SC7->C7_PRECO

			If 0.00 > NOROUND(SALDO_PC,2)
				MsgAlert("Atenção, verifique o saldo em aberto do item " + acols[n][pD1_ITEM] + CRLF + CRLF +;
				"Total do Item: " + ALLTRIM(TRANSFORM(SC7->C7_QUANT * SC7->C7_PRECO, cPict)) + CRLF +;
				"Saldo do Item: " + ALLTRIM(TRANSFORM((SC7->C7_QUANT - TOTAL_NF) * SC7->C7_PRECO, cPict)) + CRLF +;
				"Total Informado: " + ALLTRIM(TRANSFORM(acols[n][pD1_TOTAL], cPict)), 'SIESTA11')
				lRESULTADO := .F.
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSC7)
	RestArea(aAreaSD1)

Return lRESULTADO