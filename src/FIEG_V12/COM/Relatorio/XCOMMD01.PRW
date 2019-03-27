#Include "Protheus.ch"
#Include "TBICONN.CH"
#Include "COLORS.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

#Define CRLF Chr(13)+Chr(10)

/*/================================================================================================================================/*/
/*/{Protheus.doc} XCOMMD01
Relatório Demonstrativo de Aquisições e Contratações - Comparativo entre periodos de Contratos e compras efetivamente dentro do periodo informado.

@type function
@author José Fernando
@since 22/12/2017
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function XCOMMD01()
	Local retornoPergunte
	Local cPerg
	Local lSegue := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	If !ApOleClient("MSExcel")
		MsgAlert("Microsoft Excel não instalado!")
		lSegue := .F.
	EndIf

	If lSegue

		//GRUPO DE PERGUNTAS PARA A CONFECÇÃO DOS PARÂMETROS DO RELATÓRIO
		cperg := "XCOMMD01"
		CriaSX1(cPerg)
		Pergunte(cPerg,.F.)
		retornoPergunte := Pergunte(cPerg, .T.)

		If retornoPergunte == .F.
			lSegue := .F.
		EndIf

		If lSegue

			SB1->(DbCloseArea())
			SC7->(DbCloseArea())
			SC1->(DbCloseArea())
			SA2->(DbCloseArea())
			CN9->(DbCloseArea())
			SC8->(DbCloseArea())
			SX5->(DbCloseArea())

			Processa({|| RELATO()},"Aguarde...")

		EndIf

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} RELATO
Função que processa o relatório.

@type function
@author José Fernando
@since 15/09/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function RELATO()

	//Local aAreaOld    := GetArea()
	//Local aAreaSM0    := SM0->(GetArea())
	//Local cStartPath  := GetSrvProfString("Startpath","")
	//Local cLogo       := cStartPath + "LGRL" + SM0->M0_CODIGO + Alltrim(SM0->M0_CODFIL) + ".BMP" 	// Empresa+Filial -- 300/92
	Local cQuery   := ""
	Local cQueryA  := ""
	Local _cAlias  := GetNextAlias()
	Local _cAliasA := GetNextAlias()
	Local Tam_ini := 0
	Local Tam_fim := 0

	Local dataIni := 0
	Local dataFim := 0

	Local dataIniAnt := 0
	Local dataFimAnt := 0

	//Local temp := -1
	//Local aCabec := {}
	Local aDados := {}
	//Local cMensagem := ""

	Local ARRAY_DADOS :=  Array(9)
	//Local nCnt
	//Local aX[0]

	Local nX := 0
	Local nY := 0

	//Local SENDO_CONTRATO := ""

	//Local PC_ANT        := ""
	//Local PC_ATU        := ""
	Local PROC_ANT      := ""
	Local PROC_ATU      := ""
	Local Ano_Atual     := ""
	Local Ano_Anterior  := ""
	Local SIGLA_ANT     := ""
	//Local COD_NAT_ANT   := ""

	Local VLRATUAL      := 0
	Local VLRATUTOTAL   := 0
	Local VLRANT        := 0
	Local VLRANTTOTAL   := 0
	Local VLRPAGOATUAL  := 0
	Local VLRPGATUTOTAL := 0
	Local VLRPAGOANT    := 0
	Local VLRPGANTTOTAL := 0

	Local VPercentual   := 0

	//Local REG_MESTRE    := 0
	//Local InicioPrograma := 0
	//Local FinalizaObjeto := 0
	Local ANOTESTE := ""
	Local Vlr_Dispensa := 0
	Local Vlr_Pg_Dispensa := 0
	Local Vlr_Licitação := 0
	Local Vlr_Pg_Licitação := 0
	Local Vlr_Inexigibilidade := 0
	Local Vlr_Pg_Inexigibilidade := 0

	Local Valor_Disp_ant := 0
	Local Vlr_Pago_Disp_ant := 0
	Local Valor_Lic_ant := 0
	Local Vlr_Pago_Lic_ant := 0
	Local Valor_Inex_ant := 0
	Local Vlr_Pago_Inex_ant := 0

	Local Vlr_Total_Modalidade := 0
	Local Vlr_Pago_Total_Modalidade := 0

	Local Valor_Total_Modal_ant := 0
	Local Val_Pago_Total_Modal_ant := 0

	Local Vlr_Oper := 0

	Local ValorPed := 0
	Local ValorPg := 0
	Local VContant := 0
	Local VContatual := 0
	Local lSegue := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	VPercentual := 0

	xEmpresa := SM0->M0_NOMECOM

	dataIni := DtoS(MV_PAR03)

	dataFim := DtoS(MV_PAR04)

	dataIniAnt := (Dtos(MV_PAR05))

	dataFimAnt := (Dtos(MV_PAR06))

	Ano_At := YEAR(MV_PAR03)
	Ano_Ant := YEAR(MV_PAR05)

	IF Ano_At = Ano_Ant
		MsgAlert("Ano Atual e Ano Anterior devem Ser Diferentes!")
		lSegue := .F.
	EndIf

	If lSegue

		Ano_Atual := cValToChar(Ano_At)
		Ano_Anterior := cValToChar(Ano_Ant)

		cQuery += "  SELECT  "
		cQuery += "   CASE    "
		cQuery += "         WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'CD' THEN '01'  "
		cQuery += "         WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'DL' THEN '01'  "
		cQuery += "         WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'CC' THEN '02'  "
		cQuery += "         WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'CV' THEN '03'  "
		cQuery += "         WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'PG' THEN '04'  "
		cQuery += "         WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'IN' THEN '05'  "
		cQuery += "         WHEN  X5_CHAVE = 'CD' THEN '01'  "
		cQuery += "         WHEN  X5_CHAVE = 'DL' THEN '01'  "
		cQuery += "         WHEN  X5_CHAVE = 'CC' THEN '02'  "
		cQuery += "         WHEN  X5_CHAVE = 'CV' THEN '03'  "
		cQuery += "         WHEN  X5_CHAVE = 'PG' THEN '04'  "
		cQuery += "         WHEN  X5_CHAVE = 'IN' THEN '05'  "
		cQuery += "   END AS SIGLA_MOD,"
		cQuery += "    C7_FILIAL AS FILIAL_PC,    "
		cQuery += "   CASE    "
		cQuery += "         WHEN  CN9_REVISA != '' THEN (CN9_NUMERO+'/'+ CN9_REVISA)   "
		cQuery += "         WHEN  CN9_NUMERO != '' THEN  CN9_NUMERO   "
		cQuery += "         WHEN  C7_NUM != '' THEN  C7_NUM      "
		cQuery += "   END AS NM_CHAVE,   "
		cQuery += "   CASE    "
		cQuery += "         WHEN  CN9_REVISA != '' THEN (CN9_NUMERO+'/'+ CN9_REVISA)   "
		cQuery += "         WHEN  CN9_NUMERO != '' THEN  CN9_NUMERO   "
		cQuery += "   END AS NM_CONTRATO,   "
		cQuery += "    C7_MEDICAO AS MEDICAO_PC,   "
		cQuery += "    C7_NUM AS NUMERO_PC,   "
		cQuery += "    C1_PEDIDO AS NUMERO_PC_SC,   "
		cQuery += "    C7_PRODUTO AS PRODUTO_PC,    "
		cQuery += "    C7_ITEM AS ITEM_PC,  "
		cQuery += "    C1_FILIAL AS FILIAL_SC,   "
		cQuery += "    C1_NUM AS NUMERO_SC,   "
		cQuery += "   ISNULL(C1_EMISSAO, '') AS EMISS_SC,   "
		cQuery += "    CN9_FILIAL AS FILIAL_CNT,      "
		cQuery += "   (C7_ITEM +  C7_PRODUTO) AS ITEM_PROD_PC,   "
		cQuery += "    C1_ITEM AS ITEM_SC,   "
		cQuery += "   ISNULL(C7_EMISSAO, '') AS EMISS_PC,   "
		cQuery += "   (C1_QUANT * C1_VUNIT) AS TOTAL_SC,     "
		cQuery += "   A2_CGC,      "
		cQuery += "   CASE    "
		cQuery += "         WHEN  CN9_REVISA != '' THEN (CN9_NUMERO+'/'+ CN9_REVISA)   "
		cQuery += "         WHEN  CN9_NUMERO != '' THEN  CN9_NUMERO   "
		cQuery += "         WHEN  CN9_NUMPR  != '' THEN  CN9_NUMPR     "
		cQuery += "         WHEN  C7_NUMPR   != '' THEN  C7_NUMPR     "
		cQuery += "         WHEN  C1_NUMPR   != '' THEN  C1_NUMPR   "
		cQuery += "         WHEN  C8_NPROC   != '' THEN  C8_NPROC   "
		cQuery += "         ELSE RTRIM(LTRIM(LTRIM(C7_FILIAL) + LTRIM(C7_NUM)))    "
		cQuery += "   END AS NUMERO_PRO,  "
		cQuery += "   CASE    "
		cQuery += "         WHEN  CN9_NUMPR  != '' THEN  CN9_NUMPR     "
		cQuery += "         WHEN  C7_NUMPR   != '' THEN  C7_NUMPR     "
		cQuery += "         WHEN  C1_NUMPR   != '' THEN  C1_NUMPR   "
		cQuery += "         WHEN  C8_NPROC   != '' THEN  C8_NPROC  "
		cQuery += "         ELSE RTRIM(LTRIM(LTRIM(C7_FILIAL) + LTRIM(C7_NUM)))    "
		cQuery += "   END AS PROCESSO,  "
		cQuery += "   CASE    "
		cQuery += "         WHEN  CN9_NUMERO != '' THEN  CN9_DTINIC   "
		cQuery += "         ELSE  C7_EMISSAO    "
		cQuery += "   END AS DATA_CLASS,       "
		cQuery += "    C7_FILIAL AS FILIAL_CLASS,    "
		cQuery += "    C7_NUMPR,  C7_FILIAL,  C7_NUM,  C7_ITEM,  C7_PRODUTO,   "
		cQuery += "   SUBSTRING(C7_EMISSAO, 0, 5) AS ANO_PC,       "
		cQuery += "   (((C7_TOTAL -  C7_VLDESC) /  C7_QUANT) *  C7_QUJE) AS PAGO_IT_NF,    "
		cQuery += "   (C7_TOTAL -  C7_VLDESC) AS VLPEDIDO,    "
		cQuery += "   (CN9_VLATU - CN9_SALDO) AS VLENTREGUE,    "
		cQuery += "   ISNULL(C1_EMISSAO, '') AS DATA_EDITAL,        "
		cQuery += "   B1_TIPO AS NAT_OBJ,    "
		cQuery += "   B1_COD AS COD_OBJ,    "
		cQuery += "   RTRIM(LTRIM(SB1.B1_CONTA)) AS B1_CONTA,   "
		cQuery += "   RTRIM(LTRIM(SB1.B1_DESC)) AS DESC_OBJ,     "
		cQuery += "   (C7_TOTAL -  C7_VLDESC)  AS TOTAL_PC,           "
		cQuery += "   ISNULL(C7_QUANT, '') AS QTD_ITEM_PC,   "
		cQuery += "    C1_XCODCOM,   "
		cQuery += "    C7_QUJE,   "
		cQuery += "    C7_QUANT,   "
		cQuery += "    C7_PRECO,     "
		cQuery += "    C7_CONTRA AS CONTRA_PC,   "
		cQuery += "    C7_LOJA AS PC_LOJA,    "
		cQuery += "    C1_FORNECE,   "
		cQuery += "    C7_FORNECE,   "
		cQuery += "   ISNULL(A2_NOME, '') AS NM_FORN_COT,    "
		cQuery += "    CN9_DTASSI,       "
		cQuery += "    CN9_SITUAC AS SITUACAO_CONT,    "
		cQuery += "    CN9_DTFIM,        "
		cQuery += "    CN9_VLATU,      "
		cQuery += "    CN9_VLINI,      "
		cQuery += "    CN9_REVATU,      "
		cQuery += "    CN9_REVISA,      "
		cQuery += "    CN9_TIPREV,      "
		cQuery += "    CN9_XMDAQU,      "
		cQuery += "    CN9_XCOT,                              "
		cQuery += "    CN9_UNVIGE,      "
		cQuery += "    CN9_VIGE,       "
		cQuery += "   C8_NUMSC,    "
		cQuery += "   C7_FISCORI,     "
		cQuery += "   X5_CHAVE AS MOD_ATUAL,    "
		cQuery += "   C1_XCODCOM      "
		cQuery += " FROM SC7010 AS C7 WITH (NOLOCK)     "
		cQuery += "  LEFT JOIN SB1010 AS SB1 WITH (NOLOCK)       "
		cQuery += "   ON (       "
		cQuery += "   SB1.D_E_L_E_T_  = ''         "
		cQuery += "   AND  C7_PRODUTO = B1_COD         "
		cQuery += "   )      "
		cQuery += "  LEFT JOIN SC1010 AS C1 WITH (NOLOCK)      "
		cQuery += "   ON (     "
		cQuery += "    C1.D_E_L_E_T_  = ''      "
		cQuery += "   AND  C1_NUM =  C7_NUMSC      "
		cQuery += "   AND  C1_ITEM =  C7_ITEMSC     "
		cQuery += "   AND     "
		cQuery += "    CASE      "
		cQuery += "       WHEN  C7_FISCORI != '' THEN  C7_FISCORI     "
		cQuery += "       ELSE  C7_FILIAL      "
		cQuery += "    END =  C1_FILIAL      "
		cQuery += "   AND  C1_PRODUTO  =  C7_PRODUTO     "
		cQuery += "   )      "
		cQuery += "  LEFT JOIN SA2010 AS A2 WITH (NOLOCK)      "
		cQuery += "   ON (     "
		cQuery += "   A2.D_E_L_E_T_  = ''         "
		cQuery += "   AND  C7_FORNECE = A2_COD         "
		cQuery += "   )        "
		cQuery += "   LEFT JOIN CN9010 AS CN9 WITH (NOLOCK)    "
		cQuery += "   ON (      "
		cQuery += "       CN9.D_E_L_E_T_  = ''         "
		cQuery += "       AND (( CASE            "
		cQuery += "               WHEN SUBSTRING(B1_DESC,1,5) = 'SRP -' THEN (SUBSTRING(C7_FILIAL, 1, 4)+'0001')          "
		cQuery += "               ELSE  C7_FILIAL          "
		cQuery += "              END =  CN9_FILIAL            "
		cQuery += "              AND           "
		cQuery += "              CASE             "
		cQuery += "               WHEN  C7_CONTRA  != '' THEN  C7_CONTRA       "
		cQuery += "               WHEN  C1_XCONTPR != '' THEN  C1_XCONTPR      "
		cQuery += "              END =  CN9_NUMERO             "
		cQuery += "              AND    CN9_SITUAC LIKE '0[156789]')       "
		cQuery += "              OR    (CN9_SITUAC = '05' AND CN9_FILIAL BETWEEN '  + MV_PAR01 +  ' AND '  + MV_PAR02 +  ' AND     "
		cQuery += "                     CASE WHEN C7_EMISSAO BETWEEN '  + DTOS(MV_PAR03) +  ' AND '  + DTOS(MV_PAR04) +  ' AND      "
		cQuery += "                              (CN9_DTINIC BETWEEN '  + DTOS(MV_PAR03) +  ' AND '  + DTOS(MV_PAR04) +  ' OR   "
		cQuery += "                               CN9_DTFIM  BETWEEN '  + DTOS(MV_PAR03) +  ' AND '  + DTOS(MV_PAR04) +  ') THEN 1 END = 1 AND   "
		cQuery += "                     CASE WHEN C7_EMISSAO BETWEEN '  + DTOS(MV_PAR05) +  ' AND '  + DTOS(MV_PAR06) +  ' AND     "
		cQuery += "                              (CN9_DTINIC BETWEEN '  + DTOS(MV_PAR05) +  ' AND '  + DTOS(MV_PAR06) +  ' OR      "
		cQuery += "                               CN9_DTFIM  BETWEEN '  + DTOS(MV_PAR05) +  ' AND '  + DTOS(MV_PAR06) +  ') THEN 1 END = 1 ))   "
		cQuery += "      )      "
		cQuery += "  LEFT JOIN SC8010 AS C8 WITH (NOLOCK)      "
		cQuery += "   ON (     "
		cQuery += "     C8.D_E_L_E_T_  = ''     "
		cQuery += "    AND  C8_LOJA =  C1_LOJA     "
		cQuery += "    AND  C8_ITEMSC =  C1_ITEM     "
		cQuery += "    AND  C8_PRODUTO =  C1_PRODUTO     "
		cQuery += "    AND C8_FORNECE =  C1_FORNECE     "
		cQuery += "    AND C8_NUMSC =  C1_NUM     "
		cQuery += "    AND C8_NUM =  C1_COTACAO     "
		cQuery += "    AND C8_NPROC =  C1_NUMPR     "
		cQuery += "    AND C8_IDENT =  C1_IDENT     "
		cQuery += "    AND C8_NUMPED =  C1_PEDIDO         "
		cQuery += "   )      "
		cQuery += "  LEFT JOIN SX5010 AS X5 WITH (NOLOCK)       "
		cQuery += "   ON (        "
		cQuery += "    X5.D_E_L_E_T_  = ''      "
		cQuery += "  AND  X5_FILIAL = '01GO    '        "
		cQuery += "   AND  X5_TABELA = 'TP'       "
		cQuery += "   AND     "
		cQuery += "    CASE      "
		cQuery += "       WHEN  C7_NUMPR != '' THEN SUBSTRING(C7_NUMPR, 0, 3)      "
		cQuery += "       WHEN  C1_NUMPR != '' THEN SUBSTRING(C1_NUMPR, 0, 3)        "
		cQuery += "       WHEN  CN9_NUMPR != '' THEN SUBSTRING(CN9_NUMPR, 0, 3)      "
		cQuery += "       WHEN  C8_NPROC != '' THEN SUBSTRING(C8_NPROC, 0, 3)      "
		cQuery += "       WHEN  CN9_XMDAQU != '' THEN SUBSTRING(CN9_XMDAQU, 0, 3)      "
		cQuery += "    END =  X5_CHAVE      "
		cQuery += "   )      "
		cQuery += " WHERE   C7.D_E_L_E_T_  = ''      "
		cQuery += "   AND C7_QUJE > 0  "
		cQuery += "   AND C7_FILIAL  BETWEEN  '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'    "
		cQuery += "   AND ((C7_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "') "
		cQuery += "   OR   (C7_EMISSAO BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "')) "
		cQuery += " ORDER BY SIGLA_MOD, FILIAL_PC, NM_CHAVE, ANO_PC, PRODUTO_PC, ITEM_PC        "

		If Select(_cAlias) > 0
			dbSelectArea(_cAlias)
			(_cAlias)->(DbCloseArea())
		Endif

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cAlias,.T.,.F.)

		DbSelectArea(_cAlias)
		(_cAlias)->(dbGotop())

		AAdd(aDados, {"VALORES POR MODALIDADE DE AQUISIÇÃO",;
		"" + Ano_Atual +    " / Vlr Contratado","" + Ano_Atual +    " / Perc.Contr.",;
		"" + Ano_Atual +    " / Vlr Pago"      ,"" + Ano_Atual +    " / Perc.Pago"  ,;
		"" + Ano_Anterior + " / Vlr Contratado","" + Ano_Anterior + " / Perc.Contr.",;
		"" + Ano_Anterior + " / Vlr Pago"      ,"" + Ano_Anterior + " / Perc.Pago"  })

		Tam_ini := (LEN(aDados))+1

		VLRATUAL := 0
		VLRATUTOTAL := 0
		VLRPAGOATUAL := 0
		VLRPGATUTOTAL := 0
		VLRANT := 0
		VLRANTTOTAL := 0
		VLRPAGOANT := 0
		VLRPGANTTOTAL := 0

		VPercentual := 0
		nX := 0
		nY := 0

		SIGLA_ANT := (_cAlias)->SIGLA_MOD

		ValorPed :=0
		ValorPg := 0

		PROCREGUA (4300)
		While !(_cAlias)->(EOF())

			INCPROC()

			PROC_ATU := ((_cAlias)->FILIAL_PC + (_cAlias)->NM_CHAVE + (_cAlias)->ANO_PC)

			IF  (_cAlias)->SIGLA_MOD <> SIGLA_ANT .AND. EMPTY(SIGLA_ANT)
				SIGLA_ANT := (_cAlias)->SIGLA_MOD
			ENDIF

			IF  (_cAlias)->SIGLA_MOD <> SIGLA_ANT .AND. !EMPTY(SIGLA_ANT)
				IF SIGLA_ANT = "01" .OR. EMPTY(SIGLA_ANT)
					ARRAY_DADOS[1] := "Dispensa "
				ELSEIF SIGLA_ANT = "02"
					ARRAY_DADOS[1] := "Concorrência "
				ELSEIF SIGLA_ANT = "03"
					ARRAY_DADOS[1] := "Convite "
				ELSEIF SIGLA_ANT = "04"
					ARRAY_DADOS[1] := "Pregão "
				ELSEIF SIGLA_ANT = "05"
					ARRAY_DADOS[1] := "Inexigibilade "
				EndIf
				SIGLA_ANT := (_cAlias)->SIGLA_MOD

				ARRAY_DADOS[2] := VLRATUAL
				ARRAY_DADOS[3] := 0
				ARRAY_DADOS[4] := VLRPAGOATUAL
				ARRAY_DADOS[5] := 0
				ARRAY_DADOS[6] := VLRANT
				ARRAY_DADOS[7] := 0
				ARRAY_DADOS[8] := VLRPAGOANT
				ARRAY_DADOS[9] := 0
				VLRATUAL := 0
				VLRPAGOATUAL := 0
				VLRANT := 0
				VLRPAGOANT := 0

				AAdd(aDados, ARRAY_DADOS)
				ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha
			ENDIF

			ValorPed := 0
			ValorPg := 0

			If  EMPTY((_cAlias)->NM_CONTRATO)
				ValorPg := (_cAlias)->PAGO_IT_NF
				ValorPed := (_cAlias)->VLPEDIDO
			ElseIF PROC_ANT <> PROC_ATU
				If ANOTESTE = Ano_Atual
					VContatual += 1
				Else
					VContant += 1
				EndIf
				ValorPg := (_cAlias)->VLENTREGUE
				ValorPed := (_cAlias)->CN9_VLATU
			EndIf

			ANOTESTE := SUBSTRING((_cAlias)->EMISS_PC,1,4)

			If  (ANOTESTE = Ano_Atual .and.  EMPTY((_cAlias)->NM_CONTRATO)) .or. ;
			(ANOTESTE = Ano_Atual .and. !EMPTY((_cAlias)->NM_CONTRATO) .and. PROC_ANT <> PROC_ATU)
				VLRATUAL += ValorPed
				VLRATUTOTAL += ValorPed
				VLRPAGOATUAL += ValorPg
				VLRPGATUTOTAL += ValorPg
				IF (_cAlias)->SIGLA_MOD = "01" .OR. EMPTY((_cAlias)->SIGLA_MOD)
					Vlr_Dispensa += ValorPed
					Vlr_Pg_Dispensa += ValorPg
				ELSEIF (_cAlias)->SIGLA_MOD = "02" .OR. (_cAlias)->SIGLA_MOD = "03" .OR. (_cAlias)->SIGLA_MOD = "04"
					Vlr_Licitação += ValorPed
					Vlr_Pg_Licitação += ValorPg
				ELSEIF (_cAlias)->SIGLA_MOD = "05"
					Vlr_Inexigibilidade += ValorPed
					Vlr_Pg_Inexigibilidade += ValorPg
				EndIf
				Vlr_Total_Modalidade := Vlr_Total_Modalidade + ValorPed
				Vlr_Pago_Total_Modalidade := Vlr_Pago_Total_Modalidade + ValorPg
			Elseif (ANOTESTE <> Ano_Atual .and.  EMPTY((_cAlias)->NM_CONTRATO)) .OR. ;
			(ANOTESTE <> Ano_Atual .and. !EMPTY((_cAlias)->NM_CONTRATO) .and. PROC_ANT <> PROC_ATU)
				VLRANT += ValorPed
				VLRANTTOTAL += ValorPed
				VLRPAGOANT += ValorPg
				VLRPGANTTOTAL += ValorPg
				IF (_cAlias)->SIGLA_MOD = "01" .OR. EMPTY((_cAlias)->SIGLA_MOD)
					Valor_Disp_ant += ValorPed
					Vlr_Pago_Disp_ant += ValorPg
				ELSEIF (_cAlias)->SIGLA_MOD = "02" .OR. (_cAlias)->SIGLA_MOD = "03" .OR. (_cAlias)->SIGLA_MOD = "04"
					Valor_Lic_ant += ValorPed
					Vlr_Pago_Lic_ant += ValorPg
				ELSEIF (_cAlias)->SIGLA_MOD = "05"
					Valor_Inex_ant += ValorPed
					Vlr_Pago_Inex_ant += ValorPg
				EndIf
				Valor_Total_Modal_ant += ValorPed
				Val_Pago_Total_Modal_ant += ValorPg
			EndIf

			//     IF (_cAlias)->NM_CONTRATO =

			IF  PROC_ANT <> PROC_ATU
				PROC_ANT := PROC_ATU
			EndIf

			(_cAlias)->(dbSkip())

		END

		//	MsgAlert("Atual >> " + cValToChar(VContatual) + " -> " + cValToChar(VLRATUTOTAL) + CRLF + "Anterior >> " + cValToChar(VContant) + " -> " + cValToChar(VLRANTTOTAL) + " " )


		IF SIGLA_ANT = "01" .OR. EMPTY(SIGLA_ANT)
			ARRAY_DADOS[1] := "Dispensa "
		ELSEIF SIGLA_ANT = "02"
			ARRAY_DADOS[1] := "Concorrência "
		ELSEIF SIGLA_ANT = "03"
			ARRAY_DADOS[1] := "Convite "
		ELSEIF SIGLA_ANT = "04"
			ARRAY_DADOS[1] := "Pregão "
		ELSEIF SIGLA_ANT = "05"
			ARRAY_DADOS[1] := "Inexigibilade "
		EndIf

		ARRAY_DADOS[2] := VLRATUAL
		ARRAY_DADOS[3] := 0
		ARRAY_DADOS[4] := VLRPAGOATUAL
		ARRAY_DADOS[5] := 0
		ARRAY_DADOS[6] := VLRANT
		ARRAY_DADOS[7] := 0
		ARRAY_DADOS[8] := VLRPAGOANT
		ARRAY_DADOS[9] := 0
		VLRATUAL := 0
		VLRPAGOATUAL := 0
		VLRANT := 0
		VLRPAGOANT := 0

		AAdd(aDados, ARRAY_DADOS)
		ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha

		Tam_fim := (LEN(aDados))

		ARRAY_DADOS[1] := " T O T A L "
		ARRAY_DADOS[2] := TRANSFORM(VLRATUTOTAL,"@E 9,999,999,999.99")
		ARRAY_DADOS[3] := 100
		ARRAY_DADOS[4] := TRANSFORM(VLRPGATUTOTAL,"@E 9,999,999,999.99")
		ARRAY_DADOS[5] := 100
		ARRAY_DADOS[6] := TRANSFORM(VLRANTTOTAL,"@E 9,999,999,999.99")
		ARRAY_DADOS[7] := 100
		ARRAY_DADOS[8] := TRANSFORM(VLRPGANTTOTAL,"@E 9,999,999,999.99")
		ARRAY_DADOS[9] := 100

		AAdd(aDados, ARRAY_DADOS)
		ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha
		nY := 2

		For nX := Tam_ini to Tam_fim
			VPercentual := 0
			VPercentual      := ((aDados[nX][nY] / VLRATUTOTAL) * 100)
			aDados[nX][nY]   := TRANSFORM(aDados[nX][nY],"@E 9,999,999,999.99")
			aDados[nX][nY+1] := TRANSFORM(VPercentual,"@E 9999.99 %")
			VPercentual := 0
			VPercentual      := ((aDados[nX][nY+2] / VLRPGATUTOTAL) * 100)
			aDados[nX][nY+2] := TRANSFORM(aDados[nX][nY+2],"@E 9,999,999,999.99")
			aDados[nX][nY+3] := TRANSFORM(VPercentual,"@E 9999.99 %")

			VPercentual := 0
			VPercentual      := ((aDados[nX][nY+4] / VLRANTTOTAL) * 100)
			aDados[nX][nY+4] := TRANSFORM(aDados[nX][nY+4],"@E 9,999,999,999.99")
			aDados[nX][nY+5] := TRANSFORM(VPercentual,"@E 9999.99 %")
			VPercentual := 0
			VPercentual      := ((aDados[nX][nY+6] / VLRPGANTTOTAL) * 100)
			aDados[nX][nY+6] := TRANSFORM(aDados[nX][nY+6],"@E 9,999,999,999.99")
			aDados[nX][nY+7] := TRANSFORM(VPercentual,"@E 9999.99 %")
		Next nX

		AAdd(aDados, ARRAY_DADOS)
		ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha

		//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

		(_cAlias)->(DbCloseArea())

		DATAINICIO := cValToChar(MV_PAR03)
		DATAFINAL := cValToChar(MV_PAR04)
		DATAANTINICIO := cValToChar(MV_PAR05)
		DATAFINALANT := cValToChar(MV_PAR06)


		//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


		cQueryA += "  SELECT  "
		cQueryA += "    C7_FILIAL AS FILIAL_PC_A,    "
		cQueryA += "   CASE    "
		cQueryA += "         WHEN  CN9_REVISA != '' THEN (CN9_NUMERO+'/'+ CN9_REVISA)   "
		cQueryA += "         WHEN  CN9_NUMERO != '' THEN  CN9_NUMERO   "
		cQueryA += "         WHEN  C7_NUM != '' THEN  C7_NUM      "
		cQueryA += "   END AS NM_CHAVE_A,   "
		cQueryA += "   CASE    "
		cQueryA += "         WHEN  CN9_REVISA != '' THEN (CN9_NUMERO+'/'+ CN9_REVISA)   "
		cQueryA += "         WHEN  CN9_NUMERO != '' THEN  CN9_NUMERO   "
		cQueryA += "   END AS NM_CONTRATO_A,   "
		cQueryA += "    C7_MEDICAO AS MEDICAO_PC_A,   "
		cQueryA += "    C7_NUM AS NUMERO_PC_A,   "
		cQueryA += "    C1_PEDIDO AS NUMERO_PC_SC_A,   "
		cQueryA += "    C7_PRODUTO AS PRODUTO_PC_A,    "
		cQueryA += "    C7_ITEM AS ITEM_PC_A,  "
		cQueryA += "    C1_FILIAL AS FILIAL_SC_A,   "
		cQueryA += "    C1_NUM AS NUMERO_SC_A,   "
		cQueryA += "   ISNULL(C1_EMISSAO, '') AS EMISS_SC_A,   "
		cQueryA += "    CN9_FILIAL AS FILIAL_CNT_A,      "
		cQueryA += "   (C7_ITEM +  C7_PRODUTO) AS ITEM_PROD_PC_A,   "
		cQueryA += "    C1_ITEM AS ITEM_SC_A,   "
		cQueryA += "   ISNULL(C7_EMISSAO, '') AS EMISS_PC_A,   "
		cQueryA += "   (C1_QUANT * C1_VUNIT) AS TOTAL_SC_A,     "
		cQueryA += "   A2_CGC,      "
		cQueryA += "   CASE    "
		cQueryA += "         WHEN  CN9_REVISA != '' THEN (CN9_NUMERO+'/'+ CN9_REVISA)   "
		cQueryA += "         WHEN  CN9_NUMERO != '' THEN  CN9_NUMERO   "
		cQueryA += "         WHEN  CN9_NUMPR  != '' THEN  CN9_NUMPR     "
		cQueryA += "         WHEN  C7_NUMPR   != '' THEN  C7_NUMPR     "
		cQueryA += "         WHEN  C1_NUMPR   != '' THEN  C1_NUMPR   "
		cQueryA += "         WHEN  C8_NPROC   != '' THEN  C8_NPROC   "
		cQueryA += "         ELSE RTRIM(LTRIM(LTRIM(C7_FILIAL) + LTRIM(C7_NUM)))    "
		cQueryA += "   END AS NUMERO_PRO_A,  "
		cQueryA += "   CASE    "
		cQueryA += "         WHEN  CN9_NUMPR  != '' THEN  CN9_NUMPR     "
		cQueryA += "         WHEN  C7_NUMPR   != '' THEN  C7_NUMPR     "
		cQueryA += "         WHEN  C1_NUMPR   != '' THEN  C1_NUMPR   "
		cQueryA += "         WHEN  C8_NPROC   != '' THEN  C8_NPROC  "
		cQueryA += "         ELSE RTRIM(LTRIM(LTRIM(C7_FILIAL) + LTRIM(C7_NUM)))    "
		cQueryA += "   END AS PROCESSO_A,  "
		cQueryA += "   CASE    "
		cQueryA += "         WHEN  CN9_NUMERO != '' THEN  CN9_DTINIC   "
		cQueryA += "         ELSE  C7_EMISSAO    "
		cQueryA += "   END AS DATA_CLASS_A,       "
		cQueryA += "    C7_FILIAL AS FILIAL_CLASS_A,    "
		cQueryA += "    C7_NUMPR,  C7_FILIAL,  C7_NUM,  C7_ITEM,  C7_PRODUTO,   "
		cQueryA += "   SUBSTRING(C7_EMISSAO, 0, 5) AS ANO_PC_A,       "
		cQueryA += "   (((C7_TOTAL -  C7_VLDESC) /  C7_QUANT) *  C7_QUJE) AS PAGO_IT_NF_A,    "
		cQueryA += "   (C7_TOTAL -  C7_VLDESC) AS VLPEDIDO_A,    "
		cQueryA += "   (CN9_VLATU - CN9_SALDO) AS VLENTREGUE_A,    "
		cQueryA += "   ISNULL(C1_EMISSAO, '') AS DATA_EDITAL_A,        "
		cQueryA += "   B1_TIPO AS NAT_OBJ_A,    "
		cQueryA += "   B1_COD AS COD_OBJ_A,    "
		cQueryA += "   RTRIM(LTRIM(SB1.B1_CONTA)) AS B1_CONTA_A,   "
		cQueryA += "   RTRIM(LTRIM(SB1.B1_DESC)) AS DESC_OBJ_A,     "
		cQueryA += "   CASE    "
		cQueryA += "         WHEN B1_CONTA = '12030103' THEN '04'  "      //OBRAS E REFORMAS
		cQueryA += "         WHEN B1_CONTA = '12030105' THEN '04'  "      //OBRAS E REFORMAS
		cQueryA += "         WHEN B1_CONTA = '32010102003' THEN '04'  "   //OBRAS E REFORMAS
		cQueryA += "         WHEN B1_CONTA = '32010102005' THEN '04'  "   //OBRAS E REFORMAS
		cQueryA += "         WHEN B1_CONTA = '11040107' THEN '05'  "      //BENS PARA REVENDA
		cQueryA += "         WHEN B1_CONTA = '32010202' THEN '05'  "      //BENS PARA REVENDA
		cQueryA += "         WHEN B1_TIPO = 'SV' THEN '01'  "             //SERVIÇOS
		cQueryA += "         WHEN B1_TIPO = 'MC' THEN '02'  "             //BENS DE CONSUMO
		cQueryA += "         WHEN B1_TIPO = 'ME' THEN '02'  "             //BENS DE CONSUMO
		cQueryA += "         WHEN B1_TIPO = 'AI' THEN '03'  "             //BENS PERMANENTES
		cQueryA += "         WHEN B1_TIPO = 'MO' THEN '04'  "             //OBRAS E REFORMAS
		cQueryA += "   END AS COD_NAT, "
		cQueryA += "   CASE    "
		cQueryA += "      WHEN  C7_VLDESC > 0 THEN (C7_TOTAL -  C7_VLDESC)   "
		cQueryA += "      ELSE  C7_TOTAL    "
		cQueryA += "   END AS TOTAL_PC_A,           "
		cQueryA += "   ISNULL(C7_QUANT, '') AS QTD_ITEM_PC_A,   "
		cQueryA += "    C1_XCODCOM,   "
		cQueryA += "    C7_QUJE,   "
		cQueryA += "    C7_QUANT,   "
		cQueryA += "    C7_PRECO,     "
		cQueryA += "    C7_CONTRA AS CONTRA_PC_A,   "
		cQueryA += "    C7_LOJA AS PC_LOJA_A,    "
		cQueryA += "    C1_FORNECE,   "
		cQueryA += "    C7_FORNECE,   "
		cQueryA += "   ISNULL(A2_NOME, '') AS NM_FORN_COT_A,    "
		cQueryA += "    CN9_DTASSI,       "
		cQueryA += "    CN9_SITUAC AS SITUACAO_CONT_A,    "
		cQueryA += "    CN9_DTFIM,        "
		cQueryA += "    CN9_VLATU,      "
		cQueryA += "    CN9_VLINI,      "
		cQueryA += "    CN9_REVATU,      "
		cQueryA += "    CN9_REVISA,      "
		cQueryA += "    CN9_TIPREV,      "
		cQueryA += "    CN9_XMDAQU,      "
		cQueryA += "    CN9_XCOT,                              "
		cQueryA += "    CN9_UNVIGE,      "
		cQueryA += "    CN9_VIGE,       "
		cQueryA += "   C8_NUMSC,    "
		cQueryA += "   C7_FISCORI,     "
		cQueryA += "   C1_XCODCOM      "
		cQueryA += " FROM SC7010 AS C7 WITH (NOLOCK)     "
		cQueryA += "  LEFT JOIN SB1010 AS SB1 WITH (NOLOCK)       "
		cQueryA += "   ON (       "
		cQueryA += "   SB1.D_E_L_E_T_  = ''         "
		cQueryA += "   AND  C7_PRODUTO = B1_COD         "
		cQueryA += "   )      "
		cQueryA += "  LEFT JOIN SC1010 AS C1 WITH (NOLOCK)      "
		cQueryA += "   ON (     "
		cQueryA += "    C1.D_E_L_E_T_  = ''      "
		cQueryA += "   AND  C1_NUM =  C7_NUMSC      "
		cQueryA += "   AND  C1_ITEM =  C7_ITEMSC     "
		cQueryA += "   AND     "
		cQueryA += "    CASE      "
		cQueryA += "       WHEN  C7_FISCORI != '' THEN  C7_FISCORI     "
		cQueryA += "       ELSE  C7_FILIAL      "
		cQueryA += "    END =  C1_FILIAL      "
		cQueryA += "   AND  C1_PRODUTO  =  C7_PRODUTO     "
		cQueryA += "   )      "
		cQueryA += "  LEFT JOIN SA2010 AS A2 WITH (NOLOCK)      "
		cQueryA += "   ON (     "
		cQueryA += "   A2.D_E_L_E_T_  = ''         "
		cQueryA += "   AND  C7_FORNECE = A2_COD         "
		cQueryA += "   )        "
		cQueryA += "   LEFT JOIN CN9010 AS CN9 WITH (NOLOCK)    "
		cQueryA += "   ON (      "
		cQueryA += "       CN9.D_E_L_E_T_  = ''         "
		cQueryA += "       AND (( CASE            "
		cQueryA += "               WHEN SUBSTRING(B1_DESC,1,5) = 'SRP -' THEN (SUBSTRING(C7_FILIAL, 1, 4)+'0001')          "
		cQueryA += "               ELSE  C7_FILIAL          "
		cQueryA += "              END =  CN9_FILIAL            "
		cQueryA += "              AND           "
		cQueryA += "              CASE             "
		cQueryA += "               WHEN  C7_CONTRA  != '' THEN  C7_CONTRA       "
		cQueryA += "               WHEN  C1_XCONTPR != '' THEN  C1_XCONTPR      "
		cQueryA += "              END =  CN9_NUMERO             "
		cQueryA += "              AND    CN9_SITUAC LIKE '0[156789]')       "
		cQueryA += "              OR    (CN9_SITUAC = '05' AND CN9_FILIAL BETWEEN '  + MV_PAR01 +  ' AND '  + MV_PAR02 +  ' AND     "
		cQueryA += "                     CASE WHEN C7_EMISSAO BETWEEN '  + DTOS(MV_PAR03) +  ' AND '  + DTOS(MV_PAR04) +  ' AND      "
		cQueryA += "                              (CN9_DTINIC BETWEEN '  + DTOS(MV_PAR03) +  ' AND '  + DTOS(MV_PAR04) +  ' OR   "
		cQueryA += "                               CN9_DTFIM  BETWEEN '  + DTOS(MV_PAR03) +  ' AND '  + DTOS(MV_PAR04) +  ') THEN 1 END = 1 AND   "
		cQueryA += "                     CASE WHEN C7_EMISSAO BETWEEN '  + DTOS(MV_PAR05) +  ' AND '  + DTOS(MV_PAR06) +  ' AND     "
		cQueryA += "                              (CN9_DTINIC BETWEEN '  + DTOS(MV_PAR05) +  ' AND '  + DTOS(MV_PAR06) +  ' OR      "
		cQueryA += "                               CN9_DTFIM  BETWEEN '  + DTOS(MV_PAR05) +  ' AND '  + DTOS(MV_PAR06) +  ') THEN 1 END = 1 ))   "
		cQueryA += "      )      "                                                                                 "
		cQueryA += "  LEFT JOIN SC8010 AS C8 WITH (NOLOCK)      "
		cQueryA += "   ON (     "
		cQueryA += "     C8.D_E_L_E_T_  = ''     "
		cQueryA += "    AND  C8_LOJA =  C1_LOJA     "
		cQueryA += "    AND  C8_ITEMSC =  C1_ITEM     "
		cQueryA += "    AND  C8_PRODUTO =  C1_PRODUTO     "
		cQueryA += "    AND C8_FORNECE =  C1_FORNECE     "
		cQueryA += "    AND C8_NUMSC =  C1_NUM     "
		cQueryA += "    AND C8_NUM =  C1_COTACAO     "
		cQueryA += "    AND C8_NPROC =  C1_NUMPR     "
		cQueryA += "    AND C8_IDENT =  C1_IDENT     "
		cQueryA += "    AND C8_NUMPED =  C1_PEDIDO         "
		cQueryA += "   )      "
		cQueryA += "  LEFT JOIN SX5010 AS X5 WITH (NOLOCK)       "
		cQueryA += "   ON (        "
		cQueryA += "    X5.D_E_L_E_T_  = ''      "
		cQueryA += "  AND  X5_FILIAL = '01GO    '        "
		cQueryA += "   AND  X5_TABELA = 'TP'       "
		cQueryA += "   AND     "
		cQueryA += "    CASE      "
		cQueryA += "       WHEN  C7_NUMPR != '' THEN SUBSTRING(C7_NUMPR, 0, 3)      "
		cQueryA += "       WHEN  C1_NUMPR != '' THEN SUBSTRING(C1_NUMPR, 0, 3)        "
		cQueryA += "       WHEN  CN9_NUMPR != '' THEN SUBSTRING(CN9_NUMPR, 0, 3)      "
		cQueryA += "       WHEN  C8_NPROC != '' THEN SUBSTRING(C8_NPROC, 0, 3)      "
		cQueryA += "       WHEN  CN9_XMDAQU != '' THEN SUBSTRING(CN9_XMDAQU, 0, 3)      "
		cQueryA += "    END =  X5_CHAVE      "
		cQueryA += "   )      "
		cQueryA += " WHERE   C7.D_E_L_E_T_  = ''      "
		cQueryA += "   AND C7_QUJE > 0  "
		cQueryA += "   AND C7_FILIAL  BETWEEN  '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'    "
		cQueryA += "   AND ((C7_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "') "
		cQueryA += "   OR   (C7_EMISSAO BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "')) "
		cQueryA += " ORDER BY FILIAL_PC_A, NM_CHAVE_A, ANO_PC_A, PRODUTO_PC_A, ITEM_PC_A   "

		If Select(_cAliasA) > 0
			dbSelectArea(_cAliasA)
			(_cAliasA)->(DbCloseArea())
		Endif

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryA),_cAliasA,.T.,.F.)

		DbSelectArea(_cAliasA)
		(_cAliasA)->(dbGotop())

		AAdd(aDados, {"VALORES POR NATUREZA DE AQUISIÇÃO",;
		"" + Ano_Atual +    " / Vlr Contratado" ,"" + Ano_Atual +    " / Perc.Contr.",;
		"" + Ano_Atual +    " / Vlr Pago"       ,"" + Ano_Atual +    " / Perc.Pago",;
		"" + Ano_Anterior + " / Vlr Contratado" ,"" + Ano_Anterior + " / Perc.Contr.",;
		"" + Ano_Anterior + " / Vlr Pago"       ,"" + Ano_Anterior + " / Perc.Pago"})

		Tam_ini := (LEN(aDados))+1

		VLRATUAL := 0
		VLRATUTOTAL := 0
		VLRPAGOATUAL := 0
		VLRPGATUTOTAL := 0
		VLRANT := 0
		VLRANTTOTAL := 0
		VLRPAGOANT := 0
		VLRPGANTTOTAL := 0

		VPercentual := 0
		nX := (LEN(aDados))
		nY := 2

		PROC_ANT := ""
		PROC_ATU := ""

		ValorPed := 0
		ValorPg := 0
		ARRAY_DADOS[1] := "Contratação de Serviços "
		ARRAY_DADOS[2] := VLRATUAL
		ARRAY_DADOS[3] := 0
		ARRAY_DADOS[4] := VLRPAGOATUAL
		ARRAY_DADOS[5] := 0
		ARRAY_DADOS[6] := VLRANT
		ARRAY_DADOS[7] := 0
		ARRAY_DADOS[8] := VLRPAGOANT
		ARRAY_DADOS[9] := 0
		AAdd(aDados, ARRAY_DADOS)
		ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha

		ARRAY_DADOS[1] := "Bens de Consumo "
		ARRAY_DADOS[2] := VLRATUAL
		ARRAY_DADOS[3] := 0
		ARRAY_DADOS[4] := VLRPAGOATUAL
		ARRAY_DADOS[5] := 0
		ARRAY_DADOS[6] := VLRANT
		ARRAY_DADOS[7] := 0
		ARRAY_DADOS[8] := VLRPAGOANT
		ARRAY_DADOS[9] := 0
		AAdd(aDados, ARRAY_DADOS)
		ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha

		ARRAY_DADOS[1] := "Bens Permanentes "
		ARRAY_DADOS[2] := VLRATUAL
		ARRAY_DADOS[3] := 0
		ARRAY_DADOS[4] := VLRPAGOATUAL
		ARRAY_DADOS[5] := 0
		ARRAY_DADOS[6] := VLRANT
		ARRAY_DADOS[7] := 0
		ARRAY_DADOS[8] := VLRPAGOANT
		ARRAY_DADOS[9] := 0
		AAdd(aDados, ARRAY_DADOS)
		ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha

		ARRAY_DADOS[1] := "Obras e Reformas "
		ARRAY_DADOS[2] := VLRATUAL
		ARRAY_DADOS[3] := 0
		ARRAY_DADOS[4] := VLRPAGOATUAL
		ARRAY_DADOS[5] := 0
		ARRAY_DADOS[6] := VLRANT
		ARRAY_DADOS[7] := 0
		ARRAY_DADOS[8] := VLRPAGOANT
		ARRAY_DADOS[9] := 0
		AAdd(aDados, ARRAY_DADOS)
		ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha

		ARRAY_DADOS[1] := "Bens para Revenda "
		ARRAY_DADOS[2] := VLRATUAL
		ARRAY_DADOS[3] := 0
		ARRAY_DADOS[4] := VLRPAGOATUAL
		ARRAY_DADOS[5] := 0
		ARRAY_DADOS[6] := VLRANT
		ARRAY_DADOS[7] := 0
		ARRAY_DADOS[8] := VLRPAGOANT
		ARRAY_DADOS[9] := 0
		AAdd(aDados, ARRAY_DADOS)
		ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha

		PROCREGUA (4300)
		While !(_cAliasA)->(EOF())
			INCPROC()

			PROC_ATU := ((_cAliasA)->FILIAL_PC_A + (_cAliasA)->NM_CHAVE_A + (_cAliasA)->ANO_PC_A)

			ValorPed := 0
			ValorPg := 0

			If  EMPTY((_cAliasA)->NM_CONTRATO_A)
				ValorPg := (_cAliasA)->PAGO_IT_NF_A
				ValorPed := (_cAliasA)->VLPEDIDO_A
			ElseIF PROC_ANT <> PROC_ATU
				ValorPg := (_cAliasA)->VLENTREGUE_A
				ValorPed := (_cAliasA)->CN9_VLATU
			EndIf

			ANOTESTE := SUBSTRING((_cAliasA)->EMISS_PC_A,1,4)

			If  (ANOTESTE = Ano_Atual .and.  EMPTY((_cAliasA)->NM_CONTRATO_A)) .or. ;
			(ANOTESTE = Ano_Atual .and. !EMPTY((_cAliasA)->NM_CONTRATO_A) .and. PROC_ANT <> PROC_ATU)
				nX := Tam_ini
				nY := 2
				If  (_cAliasA)->COD_NAT = "01"
					aDados[nX][nY] += ValorPed
					aDados[nX][nY+2] += ValorPg
				ElseIf(_cAliasA)->COD_NAT = "02"
					aDados[nX+1][nY] += ValorPed
					aDados[nX+1][nY+2] += ValorPg
				ElseIf(_cAliasA)->COD_NAT = "03"
					aDados[nX+2][nY] += ValorPed
					aDados[nX+2][nY+2] += ValorPg
				ElseIf(_cAliasA)->COD_NAT = "04"
					aDados[nX+3][nY] += ValorPed
					aDados[nX+3][nY+2] += ValorPg
				ElseIf(_cAliasA)->COD_NAT = "05"
					aDados[nX+4][nY] += ValorPed
					aDados[nX+4][nY+2] += ValorPg
				EndIf
				VLRATUTOTAL += ValorPed
				VLRPGATUTOTAL += ValorPg
			Elseif (ANOTESTE <> Ano_Atual .and.  EMPTY((_cAliasA)->NM_CONTRATO_A)) .OR. ;
			(ANOTESTE <> Ano_Atual .and. !EMPTY((_cAliasA)->NM_CONTRATO_A) .and. PROC_ANT <> PROC_ATU)
				nX := Tam_ini
				nY := 6
				If  (_cAliasA)->COD_NAT = "01"
					aDados[nX][nY] += ValorPed
					aDados[nX][nY+2] += ValorPg
				ElseIf(_cAliasA)->COD_NAT = "02"
					aDados[nX+1][nY] += ValorPed
					aDados[nX+1][nY+2] += ValorPg
				ElseIf(_cAliasA)->COD_NAT = "03"
					aDados[nX+2][nY] += ValorPed
					aDados[nX+2][nY+2] += ValorPg
				ElseIf(_cAliasA)->COD_NAT = "04"
					aDados[nX+3][nY] += ValorPed
					aDados[nX+3][nY+2] += ValorPg
				ElseIf(_cAliasA)->COD_NAT = "05"
					aDados[nX+4][nY] += ValorPed
					aDados[nX+4][nY+2] += ValorPg
				EndIf
				VLRANTTOTAL += ValorPed
				VLRPGANTTOTAL += ValorPg
			EndIf

			IF  PROC_ANT <> PROC_ATU
				PROC_ANT := PROC_ATU
			EndIf

			(_cAliasA)->(dbSkip())

		END

		Tam_fim := (LEN(aDados))

		ARRAY_DADOS[1] := " T O T A L "
		ARRAY_DADOS[2] := TRANSFORM(VLRATUTOTAL,"@E 9,999,999,999.99")
		ARRAY_DADOS[3] := 100
		ARRAY_DADOS[4] := TRANSFORM(VLRPGATUTOTAL,"@E 9,999,999,999.99")
		ARRAY_DADOS[5] := 100
		ARRAY_DADOS[6] := TRANSFORM(VLRANTTOTAL,"@E 9,999,999,999.99")
		ARRAY_DADOS[7] := 100
		ARRAY_DADOS[8] := TRANSFORM(VLRPGANTTOTAL,"@E 9,999,999,999.99")
		ARRAY_DADOS[9] := 100

		AAdd(aDados, ARRAY_DADOS)
		ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha
		nY := 2

		For nX := Tam_ini to Tam_fim
			VPercentual := 0
			VPercentual      := ((aDados[nX][nY] / VLRATUTOTAL) * 100)
			aDados[nX][nY]   := TRANSFORM(aDados[nX][nY],"@E 9,999,999,999.99")
			aDados[nX][nY+1] := TRANSFORM(VPercentual,"@E 9999.99 %")
			VPercentual := 0
			VPercentual      := ((aDados[nX][nY+2] / VLRPGATUTOTAL) * 100)
			aDados[nX][nY+2] := TRANSFORM(aDados[nX][nY+2],"@E 9,999,999,999.99")
			aDados[nX][nY+3] := TRANSFORM(VPercentual,"@E 9999.99 %")

			VPercentual := 0
			VPercentual      := ((aDados[nX][nY+4] / VLRANTTOTAL) * 100)
			aDados[nX][nY+4] := TRANSFORM(aDados[nX][nY+4],"@E 9,999,999,999.99")
			aDados[nX][nY+5] := TRANSFORM(VPercentual,"@E 9999.99 %")
			VPercentual := 0
			VPercentual      := ((aDados[nX][nY+6] / VLRPGANTTOTAL) * 100)
			aDados[nX][nY+6] := TRANSFORM(aDados[nX][nY+6],"@E 9,999,999,999.99")
			aDados[nX][nY+7] := TRANSFORM(VPercentual,"@E 9999.99 %")
		Next nX

		VLRATUTOTAL := 0
		VLRANTTOTAL := 0
		VLRPGATUTOTAL := 0
		VLRPGANTTOTAL := 0
		VPercentual := 0

		AAdd(aDados, ARRAY_DADOS)
		ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha

		//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

		AAdd(aDados, {"COMPARATIVO DISPENSA, LICITAÇÃO E INEXIGIBILIDADE",;
		"" + Ano_Atual +    " / Vlr Contratado"  , "Perc.Contratado (+/-)",;
		"" + Ano_Anterior + " / Vlr Contratado"  ,;
		"      " + Ano_Atual +    " / Vlr Pago"  , "      Perc.Pago (+/-)"  ,;
		"      " + Ano_Anterior + " / Vlr Pago"  })

		Vlr_Oper := 0
		ARRAY_DADOS[1] := "Dispensa"
		ARRAY_DADOS[2] := TRANSFORM(Vlr_Dispensa,"@E 9,999,999,999.99")
		Vlr_Oper := (((Vlr_Dispensa / Valor_Disp_ant) - 1) * 100)
		ARRAY_DADOS[3] := TRANSFORM(Vlr_Oper,"@E 9999.99 %")
		ARRAY_DADOS[4] := TRANSFORM(Valor_Disp_ant,"@E 9,999,999,999.99")

		ARRAY_DADOS[5] := TRANSFORM(Vlr_Pg_Dispensa,"@E 9,999,999,999.99")
		Vlr_Oper := (((Vlr_Pg_Dispensa / Vlr_Pago_Disp_ant) - 1) * 100)
		ARRAY_DADOS[6] := TRANSFORM(Vlr_Oper,"@E 9999.99 %")
		ARRAY_DADOS[7] := TRANSFORM(Vlr_Pago_Disp_ant,"@E 9,999,999,999.99")
		ARRAY_DADOS[8] := ""
		ARRAY_DADOS[9] := ""
		AAdd(aDados, ARRAY_DADOS)
		ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha

		Vlr_Oper := 0
		ARRAY_DADOS[1] := "Licitação"
		ARRAY_DADOS[2] := TRANSFORM(Vlr_Licitação,"@E 9,999,999,999.99")
		Vlr_Oper := (((Vlr_Licitação / Valor_Lic_ant) - 1) * 100)
		ARRAY_DADOS[3] := TRANSFORM(Vlr_Oper,"@E 9999.99 %")
		ARRAY_DADOS[4] := TRANSFORM(Valor_Lic_ant,"@E 9,999,999,999.99")

		ARRAY_DADOS[5] := TRANSFORM(Vlr_Pg_Licitação,"@E 9,999,999,999.99")
		Vlr_Oper := (((Vlr_Pg_Licitação / Vlr_Pago_Lic_ant) - 1) * 100)
		ARRAY_DADOS[6] := TRANSFORM(Vlr_Oper,"@E 9999.99 %")
		ARRAY_DADOS[7] := TRANSFORM(Vlr_Pago_Lic_ant,"@E 9,999,999,999.99")
		ARRAY_DADOS[8] := ""
		ARRAY_DADOS[9] := ""
		AAdd(aDados, ARRAY_DADOS)
		ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha

		Vlr_Oper := 0
		ARRAY_DADOS[1] := "Inexigibilidade"
		ARRAY_DADOS[2] := TRANSFORM(Vlr_Inexigibilidade,"@E 9,999,999,999.99")
		Vlr_Oper := (((Vlr_Inexigibilidade / Valor_Inex_ant) - 1) * 100)
		ARRAY_DADOS[3] := TRANSFORM(Vlr_Oper,"@E 9999.99 %")
		ARRAY_DADOS[4] := TRANSFORM(Valor_Inex_ant,"@E 9,999,999,999.99")

		ARRAY_DADOS[5] := TRANSFORM(Vlr_Pg_Inexigibilidade,"@E 9,999,999,999.99")
		Vlr_Oper := (((Vlr_Pg_Inexigibilidade / Vlr_Pago_Inex_ant) - 1) * 100)
		ARRAY_DADOS[6] := TRANSFORM(Vlr_Oper,"@E 9999.99 %")
		ARRAY_DADOS[7] := TRANSFORM(Vlr_Pago_Inex_ant,"@E 9,999,999,999.99")
		ARRAY_DADOS[8] := ""
		ARRAY_DADOS[9] := ""
		AAdd(aDados, ARRAY_DADOS)
		ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha

		ARRAY_DADOS[1] := "T O T A L"
		Vlr_Oper := 0
		Vlr_Oper := Vlr_Total_Modalidade
		ARRAY_DADOS[2] := TRANSFORM(Vlr_Oper,"@E 9,999,999,999.99")
		ARRAY_DADOS[3] := TRANSFORM((((Vlr_Total_Modalidade / Valor_Total_Modal_ant) - 1) * 100),"@E 9999.99 %")
		Vlr_Oper := 0
		Vlr_Oper := Valor_Total_Modal_ant
		ARRAY_DADOS[4] := TRANSFORM(Vlr_Oper,"@E 9,999,999,999.99")

		Vlr_Oper := 0
		Vlr_Oper := Vlr_Pago_Total_Modalidade
		ARRAY_DADOS[5] := TRANSFORM(Vlr_Oper,"@E 9,999,999,999.99")
		ARRAY_DADOS[6] := TRANSFORM((((Vlr_Pago_Total_Modalidade / Val_Pago_Total_Modal_ant) - 1) * 100),"@E 9999.99 %")
		Vlr_Oper := 0
		Vlr_Oper := Val_Pago_Total_Modal_ant
		ARRAY_DADOS[7] := TRANSFORM(Vlr_Oper,"@E 9,999,999,999.99")

		ARRAY_DADOS[8] := ""
		ARRAY_DADOS[9] := ""

		AAdd(aDados, ARRAY_DADOS)
		ARRAY_DADOS   := Array(9)  //Limpeza do Array Planilha

		//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


		DlgToExcel({ {"ARRAY", "DEMONSTRATIVO DE AQUISIÇÕES E CONTRATAÇÕES" + CRLF + "PERÍODO ATUAL DE: " + DATAINICIO + " à " + DATAFINAL + "" + CRLF +;
		"PERÍODO ANTERIOR DE: " + DATAANTINICIO + " à " + DATAFINALANT + "" , "" , aDados} })

		(_cAliasA)->(DbCloseArea())

		SB1->(DbCloseArea())
		SC7->(DbCloseArea())
		SC1->(DbCloseArea())
		SA2->(DbCloseArea())
		CN9->(DbCloseArea())
		SC8->(DbCloseArea())
		SX5->(DbCloseArea())
		SM0->(DbCloseArea())

	EndIf

Return
/*/================================================================================================================================/*/
/*/{Protheus.doc} RELATO
Função que processa o relatório.

@type function
@author José Fernando
@since 15/09/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function CriaSx1( cPerg )
	Local aP := {}
	//Local i := 0
	//Local cSeq
	//Local cMvCh
	//Local cMvPar
	Local aHelp := {}
	Local aArea := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	xEmpresa := SM0->M0_NOME

	aAdd(aP,{"Filial De"   	        ,"C",8 ,0,"G","","SM0"	,"","","","",""})                            // MV_PAR01
	aAdd(aP,{"Filial Ate"  	        ,"C",8 ,0,"G","","SM0"	,"","","","",""})                            // MV_PAR02
	aAdd(aP,{"Período Atual De "    ,"D",8 ,0,"G","",""	  	,"","","","",""})                            // MV_PAR03
	aAdd(aP,{"Período Atual Até"	  ,"D",8 ,0,"G","",""	  	,"","","","",""})                            // MV_PAR04
	aAdd(aP,{"Período Anterior De"  ,"D",8 ,0,"G","",""	  	,"","","","",""})                            // MV_PAR05
	aAdd(aP,{"Período Anterior Até" ,"D",8 ,0,"G","",""	  	,"","","","",""})                            // MV_PAR06
	//-----------------------------------------------

	aAdd(aHelp,{"Informe a filial Inicial."})
	aAdd(aHelp,{"Informe a Filial Final."})
	aAdd(aHelp,{"Informe a data Inicial do Período Atual."})
	aAdd(aHelp,{"Informe a data Final do Período Atual."})
	aAdd(aHelp,{"Informe a data Inicial do Periodo Anterior."})
	aAdd(aHelp,{"Informe a data Final do Período Atual."})


//	For i:=1 To Len(aP)
//		cSeq   := StrZero(i,2,0)
//		cMvPar := "mv_par"+cSeq
//		cMvCh  := "mv_ch"+IIF(i<=9,Chr(i+48),Chr(i+87))
//
//
//		PutSx1(cPerg,;
//		cSeq,;
//		aP[i,1],aP[i,1],aP[i,1],;
//		cMvCh,;
//		aP[i,2],;
//		aP[i,3],;
//		aP[i,4],;
//		0,;
//		aP[i,5],;
//		aP[i,6],;
//		aP[i,7],;
//		"",;
//		"",;
//		cMvPar,;
//		aP[i,8],aP[i,8],aP[i,8],;
//		"",;
//		aP[i,9],aP[i,9],aP[i,9],;
//		aP[i,10],aP[i,10],aP[i,10],;
//		aP[i,11],aP[i,11],aP[i,11],;
//		aP[i,12],aP[i,12],aP[i,12],;
//		aHelp[i],;
//		{},;
//		{},;
//		"")
//	Next i
	RestArea(aArea)
Return