#Include "Protheus.ch"
#Include "TBICONN.CH"
#Include "COLORS.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"
#Define CRLF Chr(13)+Chr(10)

/*/================================================================================================================================/*/
/*/{Protheus.doc} XCOMCP01
Relatório Gestão de Compras  - Contratos e compras efetivamente dentro do periodo informado (Requisitado por Paulo Vargas).

@type function
@author José Fernando
@since 01/12/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function XCOMCP01()
	Local retornoPergunte
	Local cPerg
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
		cperg := "XCOMCP01"
		CriaSX1(cPerg)
		Pergunte(cPerg,.F.)
		retornoPergunte := Pergunte(cPerg, .T.)

		If retornoPergunte == .F.
			lSegue := .T.
		EndIf

		If lSegue

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

	Local cQuery := ""
	Local contadorCotacao := 1
	Local Conta_Cotacao := 1
	Local _cAlias  := GetNextAlias()
	//Local _cAliasA := GetNextAlias()
	Local fornecedorContrato := ""
	//Local fornecedoratual := ""
	Local lojaFornecedorContrato := ""
	Local solicitacaoContrato := ""
	Local dtAssCnt := ""  //Data de Assinatura do Contrato
	Local cnpjContrato := ""
	Local dataContrato := ""
	Local valorContrato := ""
	Local valorIniContrato := ""
	Local vigenciaContrato := 0
	Local revisaoContrato := ""
	//Local comprador := ""
	Local compradorContrato := ""
	Local cotacaoContrato := ""
	Local revisaoatu  := ""
	Local modcontrato := ""
	Local tipoRevisao := ""
	Local valorDesc := 0
	Local valorTotal := 0
	Local valorPago := 0
	Local ValorPedido := 0
	Local modalok := ""

	//Local chaveant := ""

	Local numeroID := 0

	Local percentualExecucao := 0

	Local filialTemp := ""
	Local dataEdTemp := ""
	Local dataScTemp := ""
	Local dataPcTemp := ""
	Local dataCtrTemp := ""
	Local dataclassTemp := ""
	//Local temp := -1
	//Local aCabec := {}
	Local aDados   := {}
	//Local cMensagem := ""

	Local ARRAY_DADOS   :=  Array(17)
	//Local nCnt
	//Local aX[0]

	//Local filialAnt     := ""
	//Local numeroScAnt   := ""
	//Local filialPc   := ""
	Local numeroPc   := ""
	//Local filialCotAnt  := ""
	//Local numeroCotAnt  := ""
	//Local itemCotAnt    := ""
	//Local produtoPcAnt  := ""
	//Local itemPcAnt     := ""
	//Local itemProdPC    := ""

	//Local PC_ANT        := ""
	//Local PC_ATU        := ""
	Local PROC_ANT      := ""
	Local PROC_ATU      := ""

	Local DescObjeto    := ""
	//Local ContaFim      := 0
	//Local NF_NUM_COT    := ""
	//Local NF_FILIAL_COT := ""
	//Local TipoObj       := ""
	Local REG_MESTRE    := 0
	Local InicioPrograma := 0
	Local FinalizaObjeto := 0
	//Local ano_clas      := 0
	Local COD_OBJ_ANT   := ""
	Local DESCOBJ_ANT   := ""


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//Local COT_FILIAL    := ""
	//Local COT_NUM       := ""
	//Local COT_FRN       := ""
	//Local COT_LOJA      := ""
	//Local COT_SC        := ""
	//Local COT_ITEMSC    := ""
	//Local COT_FRN_ANT   := ""

	xEmpresa := SM0->M0_NOMECOM

	DATAINICIO := cValToChar(MV_PAR03)
	DATAFINAL := cValToChar(MV_PAR04)

	AAdd(aDados, {"ORDEM","Data_Referência","Filial","Número do Processo","Contrato/Pedido","Num.SC","Qtd_Itens","Valor_Contratado","Valor Entregue","Comprador","Conta_Contabil",;
	"Modalidade","Natureza_do_Objeto","Categoria_Descricao_Objeto","Razão_Social", "CNPJ",;
	"Vigência_em_Meses"})
	cQuery += "  SELECT  "
	cQuery += "   SC7.C7_FILIAL AS FILIAL_PC,    "
	cQuery += "   CASE    "
	cQuery += "         WHEN CN9.CN9_REVISA != '' THEN (CN9.CN9_NUMERO+'/'+CN9.CN9_REVISA)   "
	cQuery += "         WHEN CN9.CN9_NUMERO != '' THEN CN9.CN9_NUMERO   "
	cQuery += "         WHEN SC7.C7_NUM != '' THEN SC7.C7_NUM      "
	cQuery += "   END AS NM_CHAVE,   "
	cQuery += "   CASE    "
	cQuery += "         WHEN CN9.CN9_REVISA != '' THEN (CN9.CN9_NUMERO+'/'+CN9.CN9_REVISA)   "
	cQuery += "         WHEN CN9.CN9_NUMERO != '' THEN CN9.CN9_NUMERO   "
	cQuery += "   END AS NM_CONTRATO,   "
	cQuery += "   SC7.C7_MEDICAO AS MEDICAO_PC,   "
	cQuery += "   SC7.C7_NUM AS NUMERO_PC,   "
	cQuery += "   SC1.C1_PEDIDO AS NUMERO_PC_SC,   "
	cQuery += "   SC7.C7_PRODUTO AS PRODUTO_PC,    "
	cQuery += "   SC7.C7_ITEM AS ITEM_PC,  "
	cQuery += "   SC1.C1_FILIAL AS FILIAL_SC,   "
	cQuery += "   SC1.C1_NUM AS NUMERO_SC,   "
	cQuery += "   ISNULL(SC1.C1_EMISSAO, '') AS EMISS_SC,   "
	cQuery += "   CN9.CN9_FILIAL AS FILIAL_CNT,      "
	cQuery += "   (SC7.C7_ITEM + SC7.C7_PRODUTO) AS ITEM_PROD_PC,   "
	cQuery += "   SC1.C1_ITEM AS ITEM_SC,   "
	cQuery += "   ISNULL(SC7.C7_EMISSAO, '') AS EMISS_PC,   "
	cQuery += "   (SC1.C1_QUANT * C1_VUNIT) AS TOTAL_SC,     "
	cQuery += "   SA2.A2_CGC,      "
	cQuery += "   CASE    "
	cQuery += "         WHEN CN9.CN9_REVISA != '' THEN (CN9.CN9_NUMERO+'/'+CN9.CN9_REVISA)   "
	cQuery += "         WHEN CN9.CN9_NUMERO != '' THEN CN9.CN9_NUMERO   "
	cQuery += "         WHEN CN9.CN9_NUMPR  != '' THEN CN9.CN9_NUMPR     "
	cQuery += "         WHEN SC7.C7_NUMPR   != '' THEN SC7.C7_NUMPR     "
	cQuery += "         WHEN SC1.C1_NUMPR   != '' THEN SC1.C1_NUMPR   "
	cQuery += "         WHEN SC8.C8_NPROC   != '' THEN SC8.C8_NPROC
	cQuery += "         ELSE RTRIM(LTRIM(LTRIM(SC7.C7_FILIAL) + LTRIM(SC7.C7_NUM)))    "
	cQuery += "   END AS NUMERO_PRO,  "
	cQuery += "   CASE    "
	cQuery += "         WHEN CN9.CN9_NUMPR  != '' THEN CN9.CN9_NUMPR     "
	cQuery += "         WHEN SC7.C7_NUMPR   != '' THEN SC7.C7_NUMPR     "
	cQuery += "         WHEN SC1.C1_NUMPR   != '' THEN SC1.C1_NUMPR   "
	cQuery += "         WHEN SC8.C8_NPROC   != '' THEN SC8.C8_NPROC
	cQuery += "         ELSE RTRIM(LTRIM(LTRIM(SC7.C7_FILIAL) + LTRIM(SC7.C7_NUM)))    "
	cQuery += "   END AS PROCESSO,  "
	cQuery += "   CASE    "
	cQuery += "         WHEN CN9.CN9_NUMERO != '' THEN CN9.CN9_DTINIC   "
	cQuery += "         ELSE SC7.C7_EMISSAO    "
	cQuery += "   END AS DATA_CLASS,       "
	cQuery += "   SC7.C7_FILIAL AS FILIAL_CLASS,    "
	cQuery += "   SC7.C7_NUMPR, SC7.C7_FILIAL, SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_PRODUTO,   "
	cQuery += "   SUBSTRING(SC7.C7_EMISSAO, 0, 5) AS ANO_PC,       "
	cQuery += "   (((SC7.C7_TOTAL - SC7.C7_VLDESC) / SC7.C7_QUANT) * SC7.C7_QUJE) AS PAGO_IT_NF,    "
	cQuery += "   (SC7.C7_TOTAL - SC7.C7_VLDESC) AS VLPEDIDO,    "
	cQuery += "   (CN9.CN9_VLATU - CN9_SALDO) AS VLENTREGUE,    "
	cQuery += "   ISNULL(SC1.C1_EMISSAO, '') AS DATA_EDITAL,        "
	cQuery += "   SB1.B1_TIPO AS NAT_OBJ,    "
	cQuery += "   SB1.B1_COD AS COD_OBJ,    "
	cQuery += "   RTRIM(LTRIM(SB1.B1_CONTA)) AS B1_CONTA,   "
	cQuery += "   RTRIM(LTRIM(CT1.CT1_DESC01)) AS DESC_CONTA,   "
	cQuery += "   RTRIM(LTRIM(SB1.B1_DESC)) AS DESC_OBJ,     "
	cQuery += "   CASE    "
	cQuery += "         WHEN SC7.C7_NUMPR  != '' THEN SX5.X5_DESCRI   "
	cQuery += "         WHEN SC1.C1_NUMPR  != '' THEN SX5.X5_DESCRI      "
	cQuery += "         WHEN CN9.CN9_NUMPR != '' THEN SX5.X5_DESCRI      "
	cQuery += "         WHEN SC8.C8_NPROC  != '' THEN SX5.X5_DESCRI      "
	cQuery += "         ELSE ''    "
	cQuery += "   END AS MODALIDADE,    "
	cQuery += "   CASE    "
	cQuery += "      WHEN SC7.C7_VLDESC > 0 THEN (SC7.C7_TOTAL - SC7.C7_VLDESC)   "
	cQuery += "      ELSE SC7.C7_TOTAL    "
	cQuery += "   END AS TOTAL_PC,           "
	cQuery += "   ISNULL(SC7.C7_QUANT, '') AS QTD_ITEM_PC,   "
	cQuery += "   SC1.C1_XCODCOM,   "
	cQuery += "   SC7.C7_QUJE,   "
	cQuery += "   SC7.C7_QUANT,   "
	cQuery += "   SC7.C7_PRECO,     "
	cQuery += "   SC7.C7_CONTRA AS CONTRA_PC,   "
	cQuery += "   SC7.C7_LOJA AS PC_LOJA,    "
	cQuery += "   SC1.C1_FORNECE,   "
	cQuery += "   SC7.C7_FORNECE,   "
	cQuery += "   ISNULL(SA2.A2_NOME, '') AS NM_FORN_COT,    "
	cQuery += "   CN9.CN9_DTASSI,       "
	cQuery += "   CN9.CN9_SITUAC AS SITUACAO_CONT,    "
	cQuery += "   CN9.CN9_DTFIM,        "
	cQuery += "   CN9.CN9_VLATU,      "
	cQuery += "   CN9.CN9_VLINI,      "
	cQuery += "   CN9.CN9_REVATU,      "
	cQuery += "   CN9.CN9_REVISA,      "
	cQuery += "   CN9.CN9_TIPREV,      "
	cQuery += "   CN9.CN9_XMDAQU,      "
	cQuery += "   CN9.CN9_XCOT,                              "
	cQuery += "   CN9.CN9_UNVIGE,      "
	cQuery += "   CN9.CN9_VIGE,       "
	cQuery += "   C8_NUMSC,    "
	cQuery += "   C7_FISCORI,     "
	cQuery += "   C1_XCODCOM      "
	cQuery += " FROM SC7010 AS SC7 WITH (NOLOCK)     "
	cQuery += "  LEFT JOIN SB1010 AS SB1 WITH (NOLOCK)       "
	cQuery += "   ON (       "
	cQuery += "   SB1.D_E_L_E_T_  = ''         "
	cQuery += "   AND SC7.C7_PRODUTO = SB1.B1_COD         "
	cQuery += "   )      "
	cQuery += "  LEFT JOIN CT1010 AS CT1 WITH (NOLOCK)   "
	cQuery += "   ON (   "
	cQuery += "   CT1.D_E_L_E_T_ = ''   "
	cQuery += "   AND CT1.CT1_FILIAL = '01GO    '   "
	cQuery += "   AND CT1.CT1_CONTA = SB1.B1_CONTA    "
	cQuery += "   )    "
	cQuery += "  LEFT JOIN SC1010 AS SC1 WITH (NOLOCK)      "
	cQuery += "   ON (     "
	cQuery += "   SC1.D_E_L_E_T_  = ''      "
	cQuery += "   AND SC1.C1_NUM = SC7.C7_NUMSC      "
	cQuery += "   AND SC1.C1_ITEM = SC7.C7_ITEMSC     "
	cQuery += "   AND     "
	cQuery += "    CASE      "
	cQuery += "       WHEN SC7.C7_FISCORI != '' THEN SC7.C7_FISCORI     "
	cQuery += "       ELSE SC7.C7_FILIAL      "
	cQuery += "    END = SC1.C1_FILIAL      "
	cQuery += "   AND SC1.C1_PRODUTO  = SC7.C7_PRODUTO     "
	cQuery += "   )      "
	cQuery += "  LEFT JOIN SA2010 AS SA2 WITH (NOLOCK)      "
	cQuery += "   ON (     "
	cQuery += "   SA2.D_E_L_E_T_  = ''         "
	cQuery += "   AND SC7.C7_FORNECE = SA2.A2_COD         "
	cQuery += "   )        "
	cQuery += "  LEFT JOIN CN9010 AS CN9 WITH (NOLOCK)      "
	cQuery += "   ON (     "
	cQuery += "   CN9.D_E_L_E_T_  = ''     "
	cQuery += "   AND CASE     "
	cQuery += "        WHEN SUBSTRING(SB1.B1_DESC,1,5) = 'SRP -' THEN (SUBSTRING(SC7.C7_FILIAL, 1, 4)+'0001')   "
	cQuery += "        ELSE SC7.C7_FILIAL   "
	cQuery += "       END = CN9.CN9_FILIAL     "
	cQuery += "   AND    "
	cQuery += "    CASE      "
	cQuery += "       WHEN SC7.C7_CONTRA  != '' THEN SC7.C7_CONTRA      "
	cQuery += "       WHEN SC1.C1_XCONTPR != '' THEN SC1.C1_XCONTPR      "
	cQuery += "    END = CN9.CN9_NUMERO      "
	cQuery += "     "
	cQuery += "   AND CN9.CN9_SITUAC LIKE '0[156789]'    "
	cQuery += "   )         "
	cQuery += "  LEFT JOIN SC8010 AS SC8 WITH (NOLOCK)      "
	cQuery += "   ON (     "
	cQuery += "    SC8.D_E_L_E_T_  = ''     "
	cQuery += "    AND SC8.C8_LOJA = SC1.C1_LOJA     "
	cQuery += "    AND SC8.C8_ITEMSC = SC1.C1_ITEM     "
	cQuery += "    AND SC8.C8_PRODUTO = SC1.C1_PRODUTO     "
	cQuery += "    AND C8_FORNECE = SC1.C1_FORNECE     "
	cQuery += "    AND C8_NUMSC = SC1.C1_NUM     "
	cQuery += "    AND C8_NUM = SC1.C1_COTACAO     "
	cQuery += "    AND C8_NPROC = SC1.C1_NUMPR     "
	cQuery += "    AND C8_IDENT = SC1.C1_IDENT     "
	cQuery += "    AND C8_NUMPED = SC1.C1_PEDIDO         "
	cQuery += "   )      "
	cQuery += "  LEFT JOIN SX5010 AS SX5 WITH (NOLOCK)       "
	cQuery += "   ON (        "
	cQuery += "   SX5.D_E_L_E_T_  = ''      "
	cQuery += "  AND SX5.X5_FILIAL = '01GO    '        "
	cQuery += "   AND SX5.X5_TABELA = 'TP'       "
	cQuery += "   AND     "
	cQuery += "    CASE      "
	cQuery += "       WHEN SC7.C7_NUMPR != '' THEN SUBSTRING(SC7.C7_NUMPR, 0, 3)      "
	cQuery += "       WHEN SC1.C1_NUMPR != '' THEN SUBSTRING(SC1.C1_NUMPR, 0, 3)        "
	cQuery += "       WHEN CN9.CN9_NUMPR != '' THEN SUBSTRING(CN9.CN9_NUMPR, 0, 3)      "
	cQuery += "       WHEN SC8.C8_NPROC != '' THEN SUBSTRING(SC8.C8_NPROC, 0, 3)      "
	cQuery += "    END = SX5.X5_CHAVE      "
	cQuery += "   )      "
	cQuery += " WHERE  SC7.D_E_L_E_T_  = ''      "
	cQuery += "   AND SC7.C7_QUJE > 0  "
	cQuery += "   AND SC7.C7_FILIAL  BETWEEN  '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'    "
	cQuery += "   AND SC7.C7_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
	cQuery += " ORDER BY FILIAL_PC, NM_CHAVE, PRODUTO_PC, ITEM_PC        "

	//cQuery += "   AND CASE     "
	//cQuery += "         WHEN SUBSTRING(C7_DESCRI,1,5)= 'SRP -' THEN (SUBSTRING(SC7.C7_FILIAL, 1, 4)+'0001')   "
	//cQuery += "         WHEN CN9.CN9_XMDAQU = 'PG'  THEN (SUBSTRING(SC7.C7_FILIAL, 1, 4)+'0001')   "
	//cQuery += "         ELSE SC7.C7_FILIAL       "
	//cQuery += "      END BETWEEN  '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'    "
	//cQuery += "   AND    "
	//cQuery += "    CASE      "
	//cQuery += "       WHEN SC7.C7_CONTRA  != '' THEN CN9.CN9_DTINIC      "
	//cQuery += "       WHEN SC1.C1_XCONTPR != '' THEN CN9.CN9_DTINIC      "
	//cQuery += "       ELSE SC7.C7_EMISSAO   "
	//cQuery += "   END BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "

	If Select(_cAlias) > 0
		dbSelectArea(_cAlias)
		(_cAlias)->(DbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cAlias,.T.,.F.)

	DbSelectArea(_cAlias)
	(_cAlias)->(dbGotop())


	PROCREGUA (1100)
	While !(_cAlias)->(EOF())

		INCPROC()
		PROC_ATU := (((_cAlias)->FILIAL_PC) + ((_cAlias)->NM_CHAVE))
		PROC_ANT := PROC_ATU

		REG_MESTRE := 0
		While PROC_ATU == PROC_ANT

			IF (PROC_ATU = PROC_ANT .and. REG_MESTRE = 0) .OR. MV_PAR05 = 2
				IF  (SUBSTRING((_cAlias)->DESC_OBJ,1,5) = 'SRP -' .and. SUBSTRING((_cAlias)->FILIAL_PC,5,4)= '0001') .or. (SUBSTRING((_cAlias)->DESC_OBJ,1,5) != 'SRP -')
					If InicioPrograma == 0
						InicioPrograma := 1
					Else
						ARRAY_DADOS[8]   := valorPedido
						ARRAY_DADOS[9]   := valorPago
						ARRAY_DADOS[14]  := DescObjeto
					EndIf

					REG_MESTRE := 1
					valorContrato := 0
					filialTemp := ""
					modalok := ""
					DescObjeto := ""
					FinalizaObjeto := 0
					valorPedido := 0
					valorPago   := 0
					valorTotal  := 0
					valorDesc    := 0
					percentualExecucao   := ""
					Conta_Cotacao := 1



					AAdd(aDados, ARRAY_DADOS)

					ARRAY_DADOS   := Array(17)  //Limpeza do Array Planilha

					filialTemp := (_cAlias)->FILIAL_CLASS

					//Caso exista algum tipo de vinculo com o contrato, devemos buscar as informações referentes a este contrato.

					cnpjContrato           := (_cAlias)->A2_CGC
					fornecedorContrato     := (_cAlias)->NM_FORN_COT
					dataContrato           := (_cAlias)->CN9_DTASSI
					valorContrato          := (_cAlias)->CN9_VLATU
					valorIniContrato       := (_cAlias)->CN9_VLINI
					revisaoatu             := (_cAlias)->CN9_REVATU
					revisaoContrato        := (_cAlias)->CN9_REVISA
					tipoRevisao            := (_cAlias)->CN9_TIPREV
					modcontrato            := (_cAlias)->CN9_XMDAQU
					cotacaoContrato        := (_cAlias)->CN9_XCOT
					solicitacaoContrato    := (_cAlias)->C8_NUMSC
					compradorContrato      := (_cAlias)->C1_XCODCOM

					//Conforme exigência da CGU, a vigência do contrato deve ser na unidade  "Meses "
					If  !EMPTY((_cAlias)->NM_CONTRATO)
						IF (_cAlias)->CN9_UNVIGE = '2'
							vigenciaContrato := (_cAlias)-> CN9_VIGE
						Else
							If (_cAlias)->CN9_UNVIGE = '3'
								vigenciaContrato := ROUND((_cAlias)-> CN9_VIGE * 12, 0)
							Else
								vigenciaContrato := ROUND((_cAlias)-> CN9_VIGE / 30, 0)
							EndIf
						EndIf
					EndIf

					contadorCotacao := 1 //limpeza da variável de contador de cotação

					dataclassTemp  := Trim((_cAlias)->DATA_CLASS)
					dataScTemp  := Trim((_cAlias)->EMISS_SC)
					dataPcTemp  := Trim((_cAlias)->EMISS_PC)

					If EMPTY(dataScTemp)
						dataScTemp  := dataPcTemp
					EndIf

					If dataEdTemp <> ''
						dataEdTemp := SUBSTR(dataEdTemp,7,2)+ "/"+SUBSTR(dataEdTemp,5,2)+ "/"+SUBSTR(dataEdTemp,1,4)
					EndIf

					If dataScTemp <> ''
						dataScTemp := SUBSTR(dataScTemp,7,2)+ "/"+SUBSTR(dataScTemp,5,2)+ "/"+SUBSTR(dataScTemp,1,4)
					EndIf

					If dataPcTemp <> ''
						dataPcTemp := SUBSTR(dataPcTemp,7,2)+ "/"+SUBSTR(dataPcTemp,5,2)+ "/"+SUBSTR(dataPcTemp,1,4)
					EndIf

					If dataclassTemp <> ''
						dataclassTemp := SUBSTR(dataclassTemp,7,2)+ "/"+SUBSTR(dataclassTemp,5,2)+ "/"+SUBSTR(dataclassTemp,1,4)
					EndIf


					//MONTAGEM DO ARRAY DE DADOS (LINHA DO EXCELL)

					numeroID := (numeroID + 1)
					ARRAY_DADOS[1]  := numeroID    // Numero_Identificacao da linha na planilha
					//	     ARRAY_DADOS[1]  := ((_cAlias)->NUMERO_PC+"/"+(_cAlias)->MEDICAO_PC+" - "+(_cAlias)->SITUACAO_CONT)
					ARRAY_DADOS[2]  := dataclassTemp
					ARRAY_DADOS[3] := (_cAlias)->FILIAL_PC
					ARRAY_DADOS[4] := (chr(160)+(_cAlias)->PROCESSO)
					ARRAY_DADOS[5] := (chr(160)+(_cAlias)->NM_CHAVE)
					ARRAY_DADOS[6] := (_cAlias)->NUMERO_SC
					ARRAY_DADOS[7] := (_cAlias)->ITEM_PC
					numeroPc := (_cAlias)->NUMERO_PC

					ARRAY_DADOS[10] := compradorContrato+" - "+(Posicione("SY1", 1, SUBSTRING(filialTemp,1,4)+"    "+(SUBSTRING(compradorContrato, 1, 3)), "Y1_NOME" ))

					ARRAY_DADOS[11] := ((_cAlias)->B1_CONTA+" - "+(_cAlias)->DESC_CONTA)

					If  EMPTY((_cAlias)->NM_CONTRATO)
						valorPago := (valorPago + (_cAlias)->PAGO_IT_NF)
					Else
						valorPago := (_cAlias)->VLENTREGUE
					EndIf

					If  !EMPTY((_cAlias)->NM_CONTRATO)
						percentualExecucao := STR(ROUND(100*(valorPago / valorContrato) , 2))
					EndIf


					//Conforme acordado com o Sr. Kelson em 01/10/2013, quando não houver número de processo, deveremos informar a chave  "FILIAL+PC "
					modalok  := ((_cAlias)->MODALIDADE)



					/*        If  !EMPTY((_cAlias)->NM_CONTRATO)
					If  !EMPTY(revisaoContrato)
					ARRAY_DADOS[5] := ((chr(160)+(_cAlias)->NM_CONTRATO)+ "/"+(SUBSTRING(revisaoContrato,1,3)))
					else
					ARRAY_DADOS[5] := (chr(160)+(_cAlias)->NM_CONTRATO)
					EndIf
					Else
					ARRAY_DADOS[5]     := (chr(160)+(_cAlias)->NUMERO_PC)
					EndIf
					*/

					// TRATA MODALIDADE - FAZER POSICIONE NA SX5 COM NUMERO_PRO

					If  EMPTY(modalok)
						modalok  := Posicione("SX5", 1, '01GO    TP'+SUBSTRING((_cAlias)->NUMERO_PRO, 1, 2),  "X5_DESCRI" )
					EndIf

					If  EMPTY(modalok)
						If  !EMPTY((_cAlias)->NM_CONTRATO) .and. !EMPTY(modcontrato)
							modalok  := Posicione("SX5", 1, '01GO    TP'+modcontrato, "X5_DESCRI" )
						EndIf
					EndIf

					If  !EMPTY((_cAlias)->MODALIDADE) .and. EMPTY(modalok)
						modalok := (_cAlias)->MODALIDADE
					EndIf

					If  (SUBSTR((_cAlias)->DESC_OBJ,1,7)) ==  "LANCHE "  .and. EMPTY(modalok)
						modalok :=  "CONVITE"
					EndIf

					If  EMPTY(modalok)
						modalok  := "A CLASSIFICAR"
					EndIf

					ARRAY_DADOS[12]  := modalok


					// NATUREZA>> INFORMAR CODIGO ( 1-(MO_MAO DE OBRA) 2-(SV_SERVIÇO) 3-(AI_ATIVO IMOBILIZADO, MC_MATERIAL CONSUMO, ME_MERCADORIA) )
					//	    ARRAY_DADOS[10]   := (_cAlias)->NAT_OBJ + ' - ' + Posicione( "SX5", 1, '01GO    02'+(_cAlias)->NAT_OBJ, "X5_DESCRI")

					ARRAY_DADOS[13]   := (_cAlias)->NAT_OBJ

					DescObjeto := ALLTRIM(ALLTRIM((_cAlias)->DESC_OBJ))

					COD_OBJ_ANT := (_cAlias)->COD_OBJ
					DESCOBJ_ANT := (_cAlias)->DESC_OBJ


					//Conforme acordado com o Sr. Kelson em 01/10/2013, os campos  "RAZÃO_SOCIAL " e  "CNPJ "
					//devem trazer as informações do fornecedor do PC, ou seja, o ganhador do processo.

					dataCtrTemp  := dataContrato

					ARRAY_DADOS[15]  := (_cAlias)->NM_FORN_COT
					ARRAY_DADOS[16]  := CHR(13) + (_cAlias)->A2_CGC


					//Acumular valor pedido e manter valor contrato no final caso a chave seja igual

					If  EMPTY((_cAlias)->NM_CONTRATO)
						valorPedido := valorPedido + ((_cAlias)->VLPEDIDO)
					Else
						valorPedido := (_cAlias)->CN9_VLATU
					EndIf



					//Regra de geração do arquivo defenida com o Sr. Kelson (segundo o Sr. Thiago):
					If  !EMPTY((_cAlias)->NM_CONTRATO)
						ARRAY_DADOS[17] := vigenciaContrato
					Else
						ARRAY_DADOS[17] := 0
					Endif

					//limpeza das variáveis

					solicitacaoContrato    := ""
					compradorContrato      := ""
					modcontrato            := ""
					revisaoContrato        := ""
					revisaoatu             := ""
					tipoRevisao            := ""
					fornecedorContrato     := ""
					lojaFornecedorContrato := ""
					ataContrato            := ""
					dtAssCnt               := ""
					valorIniContrato       := ""
					vigenciaContrato       := 0
					cnpjContrato 		    := ""
					dataScTemp 			    := ""
					dataPcTemp 			    := ""
					dataCotTemp 		       := ""
				EndIf
			Else
				IF  (SUBSTRING((_cAlias)->DESC_OBJ,1,5) = 'SRP -' .and. SUBSTRING((_cAlias)->FILIAL_PC,5,4)= '0001') .or. (SUBSTRING((_cAlias)->DESC_OBJ,1,5) != 'SRP -')
					TamanhoObj = Len(DescObjeto)
					If FinalizaObjeto == 0
						If SUBSTR(DESCOBJ_ANT,1 ,30) != SUBSTR((_cAlias)->DESC_OBJ,1 ,30) .and. (len((_cAlias)->DESC_OBJ)+TamanhoObj) > 150
							DescObjeto := (ALLTRIM(ALLTRIM(DescObjeto) + ', ...'))
							FinalizaObjeto := 1
						Else
							If SUBSTR(DESCOBJ_ANT,1 ,30) != SUBSTR((_cAlias)->DESC_OBJ,1 ,30)
								If (len((_cAlias)->DESC_OBJ)+TamanhoObj) > 150
									DescObjeto := (ALLTRIM(ALLTRIM(DescObjeto) + ', ...'))
									FinalizaObjeto := 1
								Else
									DescObjeto := ALLTRIM(ALLTRIM((_cAlias)->DESC_OBJ)+ ', ' +DescObjeto)
								EndIf
							EndIf
						EndIf
					EndIf


					COD_OBJ_ANT := (_cAlias)->COD_OBJ
					DESCOBJ_ANT := (_cAlias)->DESC_OBJ

					If  EMPTY((_cAlias)->NM_CONTRATO)
						valorPago := (valorPago + (_cAlias)->PAGO_IT_NF)
					Else
						valorPago := (_cAlias)->VLENTREGUE
					EndIf

					If  EMPTY((_cAlias)->NM_CONTRATO)
						valorPedido := valorPedido + ((_cAlias)->VLPEDIDO)
					Else
						valorPedido := (_cAlias)->CN9_VLATU
					EndIf
				EndiF
			EndIf

			(_cAlias)->(dbSkip())

			PROC_ATU :=  (((_cAlias)->FILIAL_PC) + ((_cAlias)->NM_CHAVE))

		END

	END
	ARRAY_DADOS[8]   := valorPedido
	ARRAY_DADOS[9]   := valorPago
	ARRAY_DADOS[14]  := DescObjeto


	// fecha array

	AAdd(aDados, ARRAY_DADOS)

	DlgToExcel({ {"ARRAY", "CONTRATOS E PEDIDOS POR PERÍODO" + CRLF + "DE: " + DATAINICIO + " à " + DATAFINAL + "", "" , aDados} })

	(_cAlias)->(DbCloseArea())

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} CriaSx1
Cria grupo de perguntas para o relatório.

@type function
@author Thiago Rasmussen
@since 09/08/2011
@version P12.1.23

@param cPerg, Caractere, Nome da Pergunta.

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


	aAdd(aP,{"Filial De"   	    ,"C",8 ,0,"G","","SM0"	,"","","","",""})                            // MV_PAR01
	aAdd(aP,{"Filial Ate"  	    ,"C",8 ,0,"G","","SM0"	,"","","","",""})                            // MV_PAR02
	aAdd(aP,{"Periodo De"	    ,"D",8 ,0,"G","",""	  	,"","","","",""})                            // MV_PAR03
	aAdd(aP,{"Periodo Ate"	    ,"D",8 ,0,"G","",""	  	,"","","","",""})                            // MV_PAR04
	aAdd(aP,{"Emitir Relatório" ,"C",1 ,0,"C","",""	  	,"Sintetico","Analitico","","",""})          // MV_PAR05

	//-----------------------------------------------

	aAdd(aHelp,{"Informe a filial inicial."})
	aAdd(aHelp,{"Informe a filial final."})
	aAdd(aHelp,{"Informe o Período inicial."})
	aAdd(aHelp,{"Informe o Período final."})
	aAdd(aHelp,{"Informe Se Relatório será 'Sintético'", " ou 'Analítico'"})

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