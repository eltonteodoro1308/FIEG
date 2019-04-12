#Include "Protheus.ch"
#Include "TBICONN.CH"
#Include "COLORS.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} XUNDCCON
Gera planilha Excel com cadas dos títulos a pagar e seu rateio correpondente.

@type function
@author Thiago Rasmussen
@since 01/07/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function XUNDCCON()

	Local cQuery := ""
	Local _cAlias := GetNextAlias()
	Local temp := -1
	Local aCabec := {}
	Local aDados := {}
	Local lSegue := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If !ApOleClient("MSExcel")
		MsgAlert("Microsoft Excel não instalado!")
		lSegue := .T.
	EndIf

	If lSegue

		//GRUPO DE PERGUNTAS PARA A CONFECÇÃO DOS PARÂMETROS DO RELATÓRIO
		Pergunte("XUNDCECO", .T.)

		AAdd(aDados, {"Nº Documento De: " + mv_par01 })
		AAdd(aDados, {"Nº Documento Até: " + mv_par02 })
		AAdd(aDados, {"Dt Pagamento De: " + DTOS(mv_par03) })
		AAdd(aDados, {"Dt Pagamento Até: " + DTOS(mv_par04) })
		AAdd(aDados, {"Item Contábil De: " + mv_par05 })
		AAdd(aDados, {"Item Contábil Até: " + mv_par06 })

		AAdd(aDados, {""}) // SIMULAÇÃO DE SALTO DE LINHA
		AAdd(aDados, {""}) // SIMULAÇÃO DE SALTO DE LINHA
		AAdd(aDados, {""}) // SIMULAÇÃO DE SALTO DE LINHA
		AAdd(aDados, {""}) // SIMULAÇÃO DE SALTO DE LINHA
		AAdd(aDados, {"Lançamento", "Prefixo", "C. Custo Débito", "Descrição CCD", "Histórico / Histórico Rateio", "Cta Contábil", "Descrição Cta Contábil", "Item Cont. Débito", "Descrição Item Cont. Débito", "Banco", "Agência", "Conta", "Fornecedor", "Data Baixa", "Vl Líquido Baixa", "Valor Título / Rateio"})

		cQuery += " SELECT SE2010.R_E_C_N_O_, E2_FILIAL, E2_NUM , E2_PREFIXO, E2_CCD , RTRIM(LTRIM(E2_HIST)) AS HISTORICO, E2_CONTAD, E2_ITEMD,   "
		cQuery += "        E2_XBANCO, E2_XAGENC, E2_XNUMCON, E2_FORNECE, E2_BAIXA, E2_VALLIQ, E2_VALOR, "
		cQuery += "        CASE WHEN CV4_VALOR IS NULL THEN -1 ELSE CV4_VALOR END AS CV4_VALOR, CV4_HIST, CV4_ITEMD "
		cQuery += " FROM SE2010 WITH (NOLOCK) LEFT JOIN CV4010 WITH (NOLOCK) ON (E2_ARQRAT = CV4_FILIAL+CV4_DTSEQ+CV4_SEQUEN) "
		cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
		cQuery += "       AND E2_NUM >= '" + MV_PAR01 + "' AND E2_NUM <= '" + MV_PAR02 + "'"
		cQuery += "       AND E2_BAIXA >= '" + DTOS(MV_PAR03) + "' AND E2_BAIXA <= '" + DTOS(MV_PAR04) + "' "
		cQuery += "       AND E2_ITEMD >= '" + MV_PAR05 + "' AND E2_ITEMD <= '" + MV_PAR06 + "' "
		cQuery += " ORDER BY 2 "

		If Select(_cAlias) > 0
			dbSelectArea(_cAlias)
			(_cAlias)->(dbCloseArea())
		Endif

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cAlias,.T.,.F.)

		DbSelectArea(_cAlias)
		(_cAlias)->(dbGotop())

		While !(_cAlias)->(Eof())

			//AAdd(aDados, {""})
			If( temp <> (_cAlias)->R_E_C_N_O_ )
				AAdd(aDados, { (_cAlias)->E2_NUM, (_cAlias)->E2_PREFIXO, (_cAlias)->E2_CCD, ""+Posicione("CTT", 1, xFilial("CTT")+(_cAlias)->E2_CCD, "CTT_DESC01" ), (_cAlias)->HISTORICO, (_cAlias)->E2_CONTAD, Posicione("CT1", 1, xFilial("CT1")+(_cAlias)->E2_CONTAD, "CT1_DESC01" ), (_cAlias)->E2_ITEMD, Posicione("CTD", 1, xFilial("CTD")+(_cAlias)->E2_ITEMD,"CTD_DESC01"), (_cAlias)->E2_XBANCO, (_cAlias)->E2_XAGENC, (_cAlias)->E2_XNUMCON, (_cAlias)->E2_FORNECE, STOD((_cAlias)->E2_BAIXA), (_cAlias)->E2_VALLIQ, (_cAlias)->E2_VALOR })
				//AAdd(aDados, { (_cAlias)->E2_NUM, (_cAlias)->E2_CCD, Posicione("CTT", SUBSTR((_cAlias)->E2_FILIAL, 1, 4)+(_cAlias)->E2_CCD, "CTT_DESC01" ), (_cAlias)->HISTORICO, (_cAlias)->E2_CONTAD, Posicione("CT1", 1,SUBSTR((_cAlias)->E2_FILIAL, 1, 4)+(_cAlias)->E2_CONTAD, "CT1_DESC01" ), (_cAlias)->E2_ITEMD, "??????????", (_cAlias)->E2_XBANCO, (_cAlias)->E2_XAGENC, (_cAlias)->E2_XNUMCON, (_cAlias)->E2_FORNECE, (_cAlias)->E2_BAIXA, (_cAlias)->E2_VALLIQ, (_cAlias)->E2_VALOR, "", "" })
			EndIf
			If( (_cAlias)->CV4_VALOR >= 0  )
				AAdd(aDados, { "", "", "", "", (_cAlias)->CV4_HIST, "", "", (_cAlias)->CV4_ITEMD, Posicione("CTD", 1, xFilial("CTD")+(_cAlias)->CV4_ITEMD,"CTD_DESC01"), "", "", "", "", "", "", (_cAlias)->CV4_VALOR })
			EndIf

			temp := (_cAlias)->R_E_C_N_O_

			(_cAlias)->(dbSkip())

		End

		DlgToExcel({ {"ARRAY", "", aCabec, aDados} })

	EndIf

Return


