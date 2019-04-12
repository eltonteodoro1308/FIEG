#Include "Protheus.ch"
#Include "TBICONN.ch"
#Include "COLORS.ch"
#Include "RPTDEF.ch"
#Include "FWPrintSetup.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} XSLDPCO
Relatório em Excel.

@type function
@author Thiago Rasmussen
@since 11/11/2013
@version P12.1.23

@obs Projeto Desenvolvimento FIEG

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function XSLDPCO()

	Local cQuery  := ""  
	Local _cAlias := GetNextAlias()
	Local aCabec  := {}
	Local aDados  := {}  
	Local retornoPergunte
	Local resultadoCombo

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If !ApOleClient("MSExcel")
		MsgAlert("Microsoft Excel não instalado!")
		Return
	EndIf

	//--< GRUPO DE PERGUNTAS PARA A CONFECÇÃO DOS PARÂMETROS DO RELATÓRIO >--
	retornoPergunte := Pergunte("XSLDPCO", .T.)

	If retornoPergunte == .F.
		Return	
	EndIf

	resultadoCombo := mv_par01 

	If resultadoCombo == 1
		resultadoCombo := "O1"
	Else
		If resultadoCombo == 2
			resultadoCombo := "O2"
		Else
			If resultadoCombo == 3
				resultadoCombo := "O3"
			Else
				If resultadoCombo == 4
					resultadoCombo := "O4"
				EndIf
			EndIf
		EndIf
	EndIf

	//--< VALIDAÇÃO PARA FAZER COM QUE TODOS OS CAMPOS SEJAM OBRIGATÓRIOS >--
	If Trim(mv_par02) == '' .or. Trim(mv_par03) == '' .or. Trim(mv_par04) == '' .or. Trim(mv_par05) == '' .or. Trim(mv_par06) == '' .or. Trim(mv_par07) == ''
		If Trim(mv_par02) == ''
			MsgAlert("Nenhum Campo poderá estar vazio."+CRLF+"PREENCHA O CAMPO 'CC DE:' !")   
		EndIf
		If Trim(mv_par03) == ''
			MsgAlert("Nenhum Campo poderá estar vazio."+CRLF+"PREENCHA O CAMPO 'CC ATE:' !")   
		EndIf
		If Trim(mv_par04) == ''
			MsgAlert("Nenhum Campo poderá estar vazio."+CRLF+"PREENCHA O CAMPO 'CO DE:' !")   
		EndIf
		If Trim(mv_par05) == ''
			MsgAlert("Nenhum Campo poderá estar vazio."+CRLF+"PREENCHA O CAMPO 'CO ATE:' !")   
		EndIf
		If Trim(mv_par06) == ''
			MsgAlert("Nenhum Campo poderá estar vazio."+CRLF+"PREENCHA O CAMPO 'ITEM CONTABIL DE:' !")   
		EndIf
		If Trim(mv_par07) == ''
			MsgAlert("Nenhum Campo poderá estar vazio."+CRLF+"PREENCHA O CAMPO 'ITEM CONTABIL ATE:' !")   
		EndIf
		U_XSLDPCO()
		Return
	EndIf

	/*
	AAdd(aDados, {"Saldo (O1, O2, O3 ou O4): " + resultadoCombo })
	AAdd(aDados, {"CC De: " + mv_par02 })
	AAdd(aDados, {"CC Até: " + mv_par03 })
	AAdd(aDados, {"CO De: " + mv_par04 })
	AAdd(aDados, {"CO Até: " + mv_par05 })
	AAdd(aDados, {"Item Contábil De: " + mv_par06 })
	AAdd(aDados, {"Item Contábil Até: " + mv_par07 })
	AAdd(aDados, {"Data De: " + DTOC(mv_par08) })
	AAdd(aDados, {"Data Até: " + DTOC(mv_par09) })

	AAdd(aDados, {""}) // SIMULAÇÃO DE SALTO DE LINHA
	AAdd(aDados, {""}) // SIMULAÇÃO DE SALTO DE LINHA
	AAdd(aDados, {""}) // SIMULAÇÃO DE SALTO DE LINHA
	AAdd(aDados, {""}) // SIMULAÇÃO DE SALTO DE LINHA
	*/

	AAdd(aDados, {"Filial", "CC", "Descrição CC", "Ítem Contábil", "Descrição Ítem Contábil", "CO", "Descrição CO", "R$ ORÇADO", "R$ SC", "R$ PE", "R$ RC", "R$ EMPENHADO", "R$ DISPONÍVEL"}) 

	cQuery += " SELECT AKD_FILIAL, AKD_CC, AKD_ITCTB, AKD_CO, SUM(ISNULL(SOMA_ORCADO, 0)) AS SOMA_ORCADO, SUM(ISNULL(SOMA_SC, 0)) AS SOMA_SC, "
	cQuery += "        SUM(ISNULL(SOMA_PE, 0)) AS SOMA_PE, SUM(ISNULL(SOMA_RC, 0)) AS SOMA_RC, SUM(ISNULL(EMPENHADO,0)) AS EMPENHADO, "
	cQuery += "        SUM((ISNULL(SOMA_ORCADO,0) - ISNULL(EMPENHADO,0))) AS SALDO_DISPONIVEL  "
	cQuery += " FROM ( "
	cQuery += " SELECT AKD_FILIAL, AKD_CC, AKD_ITCTB, AKD_CO,  " 
	cQuery += "       CASE WHEN AKD_TPSALD IN ('O1','O2','O3','O4') THEN SUM(CASE WHEN AKD_TIPO = '2' THEN AKD_VALOR1*-1 ELSE AKD_VALOR1 END) END AS SOMA_ORCADO, "
	cQuery += "       CASE WHEN AKD_TPSALD IN ('SC') THEN SUM(CASE WHEN AKD_TIPO = '2' THEN AKD_VALOR1*-1 ELSE AKD_VALOR1 END) END AS SOMA_SC, "
	cQuery += "       CASE WHEN AKD_TPSALD IN ('PE') THEN SUM(CASE WHEN AKD_TIPO = '2' THEN AKD_VALOR1*-1 ELSE AKD_VALOR1 END) END AS SOMA_PE, "
	cQuery += "       CASE WHEN AKD_TPSALD IN ('RC') THEN SUM(CASE WHEN AKD_TIPO = '2' THEN AKD_VALOR1*-1 ELSE AKD_VALOR1 END) END AS SOMA_RC, "
	cQuery += "       CASE WHEN AKD_TPSALD IN ('SC','PE','RC') THEN SUM(CASE WHEN AKD_TIPO = '2' THEN AKD_VALOR1*-1 ELSE AKD_VALOR1 END) END AS EMPENHADO "
	cQuery += " FROM AKD010 WITH (NOLOCK) "
	cQuery += " WHERE AKD_FILIAL = '" + xFilial("AKD") + "'  "
	cQuery += "       AND AKD_TPSALD IN ('" + resultadoCombo + "', 'SC', 'PE', 'RC') "
	cQuery += "       AND AKD_CC >= '" + MV_PAR02 + "' AND AKD_CC <= '" + MV_PAR03 + "'   "
	cQuery += "       AND AKD_CO >= '" + MV_PAR04 + "' AND AKD_CO <= '" + MV_PAR05 + "'   "
	cQuery += "       AND AKD_ITCTB >= '" + MV_PAR06 + "' AND AKD_ITCTB <= '" + MV_PAR07 + "'   "
	cQuery += "       AND AKD_DATA >= '" + DTOS(MV_PAR08) + "'"
	cQuery += "       AND AKD_DATA <= '" + DTOS(MV_PAR09) + "'"
	cQuery += "       AND AKD_STATUS = '1' " 
	cQuery += "       AND AKD_CC <> '' "
	cQuery += "       AND AKD_ITCTB <> '' "
	cQuery += "       AND D_E_L_E_T_ <> '*' "
	cQuery += " GROUP BY AKD_FILIAL, AKD_CC, AKD_ITCTB, AKD_CO, AKD_TPSALD  "
	cQuery += " ) AS CONSULTA  "
	// 11/11/2013 - Thiago Rasmussen - O código abaixo foi comentado, para trazer os valores negativos, conforme o relatório de Cubos
	//cQuery += " WHERE ( SOMA_ORCADO > 0 OR SOMA_SC > 0 OR SOMA_PE > 0 OR SOMA_RC > 0 OR EMPENHADO > 0 )  "
	cQuery += " GROUP BY AKD_FILIAL, AKD_CC, AKD_ITCTB, AKD_CO  "
	cQuery += " ORDER BY AKD_FILIAL, AKD_CC, AKD_ITCTB, AKD_CO  "

	/*
	ATENÇÃO.: O FILTRO --> AND AKD_STATUS = '1' <-- FOI INCERIDO PARA
	LISTAR SOMENTE OS ORÇAMENTOS COM O STATUS "APROVADO"

	*/

	If Select(_cAlias) > 0
		dbSelectArea(_cAlias)
		dbCloseArea()
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cAlias,.T.,.F.)

	DbSelectArea(_cAlias)
	dbGotop()

	While !(_cAlias)->(Eof())   
		AAdd(aDados, { (_cAlias)->AKD_FILIAL, (_cAlias)->AKD_CC, Posicione("CTT", 1, xFilial("CTT")+(_cAlias)->AKD_CC, "CTT_DESC01" ), (_cAlias)->AKD_ITCTB, Posicione("CTD", 1, xFilial("CTD")+(_cAlias)->AKD_ITCTB,"CTD_DESC01"), (_cAlias)->AKD_CO, Posicione("CT1", 1, xFilial("CT1")+(_cAlias)->AKD_CO, "CT1_DESC01" ), (_cAlias)->SOMA_ORCADO, (_cAlias)->SOMA_SC, (_cAlias)->SOMA_PE, (_cAlias)->SOMA_RC, (_cAlias)->EMPENHADO, (_cAlias)->SOMA_ORCADO-(_cAlias)->EMPENHADO  })
		(_cAlias)->(dbSkip())
	End

	DlgToExcel({ {"ARRAY", "", aCabec, aDados} })

	(_cAlias)->(dbCloseArea())

Return