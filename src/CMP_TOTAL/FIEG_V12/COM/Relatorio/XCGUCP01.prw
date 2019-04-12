#Include "Protheus.ch"
#Include "TbiConn.CH"
#Include "COLORS.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

#Define CRLF Chr(13) + Chr(10)

/*/================================================================================================================================/*/
/*/{Protheus.doc} XCGUCP01
Relatório Gestão de Compras.

@type function
@author José Fernando
@since 15/09/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function XCGUCP01()
	Local retornoPergunte
	Local cPerg
	Local lSegue := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	If !ApOleClient("MSExcel")
		MsgAlert("Microsoft Excel não instalado!")
		lSegue := .F.
	EndIf

	If lSegue

		//GRUPO DE PERGUNTAS PARA A CONFECÇÃO DOS PARÂMETROS DO RELATÓRIO
		cperg := "XCGUCP01"
		CriaSX1(cPerg)
		Pergunte(cPerg,.F.)
		retornoPergunte := Pergunte(cPerg, .T.)

		If retornoPergunte == .F.
			lSegue := .F.
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
	Local _cAliasA := GetNextAlias()
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
	//Local Testelinha := 0

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
	Local aCabec := {}
	Local aDados   := {}
	//Local cMensagem := ""

	Local ARRAY_DADOS   :=  Array(76)
	//Local nCnt
	//Local aX[0]

	//Local filialAnt     := ""
	//Local numeroScAnt   := ""
	//Local filialPcAnt   := ""
	//Local numeroPcAnt   := ""
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
	Local TipoObj       := ""
	Local REG_MESTRE    := 0
	Local InicioPrograma := 0
	Local FinalizaObjeto := 0
	//Local ano_clas      := 0
	Local COD_OBJ_ANT   := ""
	Local DESCOBJ_ANT   := ""
	Local COT_FILIAL    := ""
	Local COT_NUM       := ""
	Local COT_FRN       := ""
	Local COT_LOJA      := ""
	Local COT_SC        := ""
	Local COT_ITEMSC    := ""
	Local COT_FRN_ANT   := ""
	Local cXDesc		:= ""
	//LOCAL ANOBAIXA      := SUBSTRING(DTOC(MV_PAR04),5,4)


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	AAdd(aDados, {"NUMERO_ID","DATA REFERENCIA","PROCESSO_PC", "FILIAL PC", "NúMERO PC", "PRODUTO_PC", "ITEM_PC", "TOTAL_ITEM_PC", "COMPRADOR", "CONTA_CONTABIL",;
	"Ano_CGU", "Num_Edital", "Compra_Compartilhada", "Inf_Sobre_Compra_Compartilhada","Data_do_Edital", "Número_Processo_CGU", "Modalidade_CGU", "Natureza_do_Objeto_CGU",;
	"Descrição_do_Objeto_CGU", "Categoria_Descricao_Objeto_CGU", "Criterio_Julgamento_CGU", "Data_da_Homologação_CGU", "Número_Contrato_CGU", "Razão_Social_CGU", "CNPJ_CGU",;
	"Data_Contrato_CGU", "Valor_Contrato_CGU", "Valor_Pago_CGU", "Vigência_em_Meses_CGU", "Aditivo_Preco_CGU", "Aditivo_Prazo_CGU", "Provocou_Alteracao_Qualidade_Objeto_CGU",;
	"Valor_Referencia_Licitação_OBRA_CGU","Percentual_Fase_Atual_Obra", "Obra_Foi_Financiada_Com_Recursos_Da_Granularidade_CGU",;
	"Nome Fornecedor Cotação - 1",  "CNPJ Fornecedor Cotação - 1",  "Nome Fornecedor Cotação - 2",  "CNPJ Fornecedor Cotação - 2",  "Nome Fornecedor Cotação - 3",  "CNPJ Fornecedor Cotação - 3",   ;
	"Nome Fornecedor Cotação - 4",  "CNPJ Fornecedor Cotação - 4",  "Nome Fornecedor Cotação - 5",  "CNPJ Fornecedor Cotação - 5",  "Nome Fornecedor Cotação - 6",  "CNPJ Fornecedor Cotação - 6",   ;
	"Nome Fornecedor Cotação - 7",  "CNPJ Fornecedor Cotação - 7",  "Nome Fornecedor Cotação - 8",  "CNPJ Fornecedor Cotação - 8",  "Nome Fornecedor Cotação - 9",  "CNPJ Fornecedor Cotação - 9",   ;
	"Nome Fornecedor Cotação - 10", "CNPJ Fornecedor Cotação - 10", "Nome Fornecedor Cotação - 11", "CNPJ Fornecedor Cotação - 11", "Nome Fornecedor Cotação - 12", "CNPJ Fornecedor Cotação - 12",  ;
	"Nome Fornecedor Cotação - 13", "CNPJ Fornecedor Cotação - 13", "Nome Fornecedor Cotação - 14", "CNPJ Fornecedor Cotação - 14", "Nome Fornecedor Cotação - 15", "CNPJ Fornecedor Cotação - 15",  ;
	"Nome Fornecedor Cotação - 16", "CNPJ Fornecedor Cotação - 16", "Nome Fornecedor Cotação - 17", "CNPJ Fornecedor Cotação - 17", "Nome Fornecedor Cotação - 18", "CNPJ Fornecedor Cotação - 18",  ;
	"Nome Fornecedor Cotação - 19", "CNPJ Fornecedor Cotação - 19", "Nome Fornecedor Cotação - 20", "CNPJ Fornecedor Cotação - 20", "Mais_de_20_Propostas_CGU"    , "OBSERVAÇÕES DE COMPRAS CENTRALIZADAS" })

	cQuery += " SELECT "
	cQuery += "  CASE  "
	cQuery += "        WHEN CN9_REVISA != '' THEN (CN9_NUMERO+'/'+CN9_REVISA) "
	cQuery += "        WHEN CN9_NUMERO != '' THEN CN9_NUMERO "
	cQuery += "        WHEN CN9_NUMPR  != '' THEN (CN9_NUMPR+'-'+C7_NUM) "
	cQuery += "        WHEN C7_NUMPR   != '' THEN (C7_NUMPR+'-'+C7_NUM) "
	cQuery += "        WHEN C1_NUMPR   != '' THEN (C1_NUMPR+'-'+C7_NUM) "
	cQuery += "        WHEN C8_NPROC   != '' THEN (C8_NPROC+'-'+C7_NUM) "
	cQuery += "        ELSE RTRIM(LTRIM(LTRIM(C7_FILIAL) + LTRIM(C7_NUM))) "
	cQuery += "  END AS NUMERO_PRO,   "
	cQuery += "  CASE  "
	cQuery += "        WHEN CN9_NUMERO != '' THEN CN9_NUMERO "
	cQuery += "        ELSE ''  "
	cQuery += "  END AS NM_CONTRATO,  "
	cQuery += "  CASE  "
	cQuery += "        WHEN CN9_NUMERO != '' THEN CN9_FILIAL "
	cQuery += "        ELSE C7_FILIAL  "
	cQuery += "  END AS FILIAL_CLASS,  "
	cQuery += "  C7_NUMPR, C7_FILIAL, C7_NUM, C7_ITEM, C7_PRODUTO,  "
	cQuery += "  SUBSTRING(C7_EMISSAO, 0, 5) AS ANO_PC,    "
	cQuery += "  (D1_TOTAL - D1_VALDESC) AS PAGO_IT_NF,  "
	cQuery += "  (C7_TOTAL - C7_VLDESC) AS TOTAL_PC,  "
	cQuery += "  (D1_QUANT * D1_VUNIT) AS TOTAL_ITEM_PC, "
	cQuery += "  ISNULL(C1_EMISSAO, '') AS DATA_EDITAL,   "
	IF  MV_PAR06 = 2
		cQuery += "  ISNULL(D1_DTDIGIT, '') AS DATA_CLASS,  "
	ELSE
		cQuery += "  ISNULL(D1_EMISSAO, '') AS DATA_CLASS,  "
	ENDIF
	cQuery += "  B1_TIPO AS NAT_OBJ,  "
	cQuery += "  B1_COD AS COD_OBJ,  "
	cQuery += "  C8_NUM AS NUM_COT,  "
	cQuery += "  C8_FORNECE,  "
	cQuery += "  RTRIM(LTRIM(B1_CONTA)) AS B1_CONTA, "
	cQuery += "  RTRIM(LTRIM(CT1_DESC01)) AS DESC_CONTA, "
	cQuery += "  RTRIM(LTRIM(B1_DESC)) AS DESC_OBJ,   "
	cQuery += "  CASE  "
	/*
	cQuery += "        WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'CD' THEN 'COMPRA DIRETA'  "
	cQuery += "        WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'DL' THEN 'DISPENSA DE LICITACAO'  "
	cQuery += "        WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'CC' THEN 'CONCORRENCIA'  "
	cQuery += "        WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'CV' THEN 'CONVITE'  "
	cQuery += "        WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'PG' THEN 'PREGAO'  "
	cQuery += "        WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'IN' THEN 'INEXIGIBILIDADE'  "
	*/
	cQuery += "        WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'CD' THEN 'COMPRA DIRETA'  "
	cQuery += "        WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'DL' THEN 'Dispensa com base no Art.9,I'  "
	cQuery += "        WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'CC' THEN 'CONCORRENCIA'  "
	cQuery += "        WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'CV' THEN 'Convite'  "
	cQuery += "        WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'PG' THEN 'PREGAO'  "
	cQuery += "        WHEN SUBSTRING(CN9_XMDAQU, 1, 2)  = 'IN' THEN 'Inexigibilidade com base no Art. 10,I'  "

	cQuery += "        WHEN X5_CHAVE != '' THEN X5_DESCRI    "
	cQuery += "        ELSE 'DISPENSA DE LICITACAO'  "
	cQuery += "  END AS MODALIDADE,  "
	cQuery += "  CASE  "
	cQuery += "       WHEN (C1_COTACAO != '' AND C1_COTACAO != 'XXXXXX') THEN C1_COTACAO "
	cQuery += "       WHEN C7_NUMCOT != '' THEN C7_NUMCOT "
	cQuery += "       WHEN CN9_XCOT != '' THEN CN9_XCOT "
	cQuery += "       WHEN C8_NUM     != '' THEN C8_NUM "
	cQuery += "       ELSE '' "
	cQuery += "  END AS NUMCOTACAO, "
	cQuery += "  ISNULL(D1_TOTAL, '') AS TOT_ITEM_NF, "
	cQuery += "  ISNULL(D1_DESC, '') AS PERC_LIQ_NF, "
	cQuery += "  ISNULL(D1_VALDESC, '') AS TOT_LIQ_NF, "
	cQuery += "  ISNULL(C7_QUANT, '') AS QTD_ITEM_PC, "
	cQuery += "  C1_XCODCOM, "
	cQuery += "  C7_QUJE, "
	cQuery += "  C7_QUANT, "
	cQuery += "  C7_PRECO, "
	cQuery += "  C7_LOJA AS PC_LOJA, "
	cQuery += "  C1_FORNECE, "
	cQuery += "  C7_FORNECE, "
	cQuery += "  ISNULL(A2_NOME, '') AS NM_FORN_COT, "
	cQuery += "  C1_FILIAL AS FILIAL_SC, "
	cQuery += "  C1_NUM AS NUMERO_SC, "
	cQuery += "  ISNULL(C1_EMISSAO, '') AS EMISS_SC, "
	cQuery += "  CN9_FILIAL AS FILIAL_CNT, "
	cQuery += "  D1_FILIAL AS FILIAL_NF, "
	cQuery += "  D1_DOC AS DOC_NF, "
	cQuery += "  D1_SERIE AS SERIE_NF, "
	cQuery += "  D1_FORNECE AS FORNECE_NF, "
	cQuery += "  D1_LOJA AS LOJA_NF, "
	cQuery += "  D1_TIPO AS TIPO_NF, "
	cQuery += "  C7_FILIAL AS FILIAL_PC, "
	cQuery += "  C7_NUM AS NUMERO_PC, "
	cQuery += "  C7_PRODUTO AS PRODUTO_PC, "
	cQuery += "  D1_COD AS PRODUTO_SD, "
	cQuery += "  C7_ITEM AS ITEM_PC, "
	cQuery += "  (C7_ITEM + C7_PRODUTO) AS ITEM_PROD_PC, "
	cQuery += "  C1_ITEM AS ITEM_SC, "
	cQuery += "  D1_ITEM AS ITEM_SD, "
	cQuery += "  ISNULL(C7_EMISSAO, '') AS EMISS_PC, "
	cQuery += "  C1_PEDIDO AS NUMERO_PC_SC, "
	cQuery += "  (C1_QUANT * C1_VUNIT) AS TOTAL_SC, "
	cQuery += "  A2_CGC, "
	cQuery += "  CN9_DTASSI, "
	cQuery += "  CN9_DTFIM, "
	cQuery += "  CN9_VLATU, "
	cQuery += "  CN9_VLINI, "
	cQuery += "  CN9_REVATU, "
	cQuery += "  CN9_REVISA, "
	cQuery += "  CN9_TIPREV, "
	cQuery += "  CN9_XMDAQU, "
	cQuery += "  CN9_XCOT, "
	cQuery += "  CN9_UNVIGE, "
	cQuery += "  CN9_VIGE, "
	cQuery += "  C8_NUMSC, "
	cQuery += "  C7_FISCORI, "
	cQuery += "  C1_XCODCOM "
	cQuery += "FROM SD1010 AS D1 WITH (NOLOCK)   "
	cQuery += " INNER JOIN SC7010 AS C7 WITH (NOLOCK)   "
	cQuery += "  ON ( "
	cQuery += "  C7.D_E_L_E_T_  = ''   "
	cQuery += "  AND C7_NUM = D1_PEDIDO      "
	cQuery += "  AND C7_FILIAL = D1_FILIAL    "
	cQuery += "  AND C7_PRODUTO = D1_COD  "
	cQuery += "  AND C7_ITEM = D1_ITEMPC  "
	cQuery += "  ) "
	cQuery += " LEFT JOIN SB1010 AS B1 WITH (NOLOCK)   "
	cQuery += "  ON (   "
	cQuery += "  B1.D_E_L_E_T_  = ''     "
	cQuery += "  AND C7_PRODUTO = B1_COD     "
	cQuery += "  ) "
	cQuery += " LEFT JOIN CT1010 AS CT1 WITH (NOLOCK) "
	cQuery += "  ON ( "
	cQuery += "  CT1.D_E_L_E_T_ = '' "
	cQuery += "  AND CT1_FILIAL = '01GO    ' "
	cQuery += "  AND CT1_CONTA = B1_CONTA  "
	cQuery += "  )  "
	cQuery += " LEFT JOIN SC1010 AS C1 WITH (NOLOCK)  "
	cQuery += "  ON ( "
	cQuery += "  C1.D_E_L_E_T_  = ''  "
	cQuery += "  AND C1_NUM = C7_NUMSC  "
	cQuery += "  AND C1_ITEM = C7_ITEMSC  "
	cQuery += "  AND "
	cQuery += "   CASE  "
	cQuery += "      WHEN C7_FISCORI != '' THEN C7_FISCORI "
	cQuery += "      ELSE C7_FILIAL  "
	cQuery += "   END = C1_FILIAL "
	cQuery += "  AND C1_PRODUTO  = C7_PRODUTO "
	cQuery += "  )  "
	cQuery += " LEFT JOIN SA2010 AS A2 WITH (NOLOCK)  "
	cQuery += "  ON ( "
	cQuery += "  A2.D_E_L_E_T_  = ''     "
	cQuery += "  AND C7_FORNECE = A2_COD     "
	cQuery += "  )    "
	cQuery += " LEFT JOIN CN9010 AS CN9 WITH (NOLOCK)  "
	cQuery += "  ON ( "
	cQuery += "  CN9.D_E_L_E_T_  = '' "
	cQuery += "  AND CN9_SITUAC LIKE '0[156789]'       "
	cQuery += "  AND CN9_REVATU=''       			   "
	cQuery += "  AND CASE  "
	cQuery += "       WHEN SUBSTRING(B1_DESC,1,5) = 'SRP -' THEN (SUBSTRING(C7_FILIAL, 1, 4)+'0001') "
	cQuery += "       ELSE C7_FILIAL "
	cQuery += "      END = CN9_FILIAL "
	cQuery += "  AND  "
	cQuery += "   CASE  "
	cQuery += "      WHEN C7_CONTRA  != '' THEN C7_CONTRA  "
	cQuery += "      WHEN C1_XCONTPR != '' THEN C1_XCONTPR  "
	cQuery += "   END = CN9_NUMERO  "
	cQuery += "  ) "
	cQuery += " LEFT JOIN CNC010 AS CNC WITH (NOLOCK)  "
	cQuery += "  ON (    "
	cQuery += "  CNC.D_E_L_E_T_  = ''  "
	cQuery += "  AND "
	cQuery += "   CASE  "
	cQuery += "      WHEN CN9_NUMERO != '' THEN CN9_FILIAL  "
	cQuery += "      WHEN C7_CONTRA  != '' THEN C7_FILIAL  "
	cQuery += "      WHEN C1_XCONTPR != '' THEN C1_FILIAL "
	cQuery += "   END = CNC_FILIAL  "
	cQuery += "  AND   "
	cQuery += "   CASE  "
	cQuery += "      WHEN CN9_NUMERO != '' THEN CN9_NUMERO  "
	cQuery += "      WHEN C7_CONTRA  != '' THEN C7_CONTRA  "
	cQuery += "      WHEN C1_XCONTPR != '' THEN C1_XCONTPR "
	cQuery += "   END = CNC_NUMERO  "
	cQuery += "  ) "
	cQuery += " LEFT JOIN SC8010 AS C8 WITH (NOLOCK)  "
	cQuery += "  ON ( "
	cQuery += "   C8.D_E_L_E_T_  = '' "
	cQuery += "   AND C8_LOJA = C1_LOJA  "
	cQuery += "   AND C8_ITEMSC = C1_ITEM  "
	cQuery += "   AND C8_PRODUTO = C1_PRODUTO  "
	cQuery += "   AND C8_FORNECE = C1_FORNECE  "
	cQuery += "   AND C8_NUMSC = C1_NUM  "
	cQuery += "   AND C8_NUM = C1_COTACAO  "
	cQuery += "   AND C8_NPROC = C1_NUMPR  "
	cQuery += "   AND C8_IDENT = C1_IDENT  "
	cQuery += "   AND C8_NUMPED = C1_PEDIDO  "
	cQuery += "  )  "
	cQuery += " LEFT JOIN SX5010 AS X5 WITH (NOLOCK)   "
	cQuery += "  ON (    "
	cQuery += "  X5.D_E_L_E_T_  = ''  "
	cQuery += "  AND X5_FILIAL = '01GO    '    "
	cQuery += "  AND X5_TABELA = 'TP'   "
	cQuery += "  AND "
	cQuery += "   CASE  "
	cQuery += "       WHEN  C7_NUMPR != '' THEN SUBSTRING(C7_NUMPR, 0, 3)      "
	cQuery += "       WHEN  C1_NUMPR != '' THEN SUBSTRING(C1_NUMPR, 0, 3)        "
	cQuery += "       WHEN  CN9_NUMPR != '' THEN SUBSTRING(CN9_NUMPR, 0, 3)      "
	cQuery += "       WHEN  C8_NPROC != '' THEN SUBSTRING(C8_NPROC, 0, 3)      "
	cQuery += "       WHEN  CN9_XMDAQU != '' THEN SUBSTRING(CN9_XMDAQU, 0, 3)      "
	cQuery += "    END =  X5_CHAVE      "
	cQuery += "  )  "
	cQuery += " LEFT JOIN SE2010 AS E2 WITH (NOLOCK)   "
	cQuery += "  ON (   "
	cQuery += "  CASE WHEN E2_XFILDES != '' THEN E2_XFILDES ELSE E2_FILIAL END = D1_FILIAL "
	cQuery += "  AND E2_EMISSAO = D1_EMISSAO "
	cQuery += "  AND (E2_XTPTRF = '2' OR E2_XTPTRF = '') "
	cQuery += "  AND E2.D_E_L_E_T_ = ''   "
	cQuery += "  AND E2_PREFIXO = SUBSTRING(D1_FILIAL,6,3) "
	cQuery += "  AND E2_NUM = D1_DOC "
	cQuery += "  AND (E2_PARCELA = '' OR E2_PARCELA = '001') "
	cQuery += "  AND (E2_TIPO = 'NF' OR E2_TIPO = 'NFS')  "
	cQuery += "  AND E2_FORNECE = D1_FORNECE "
	cQuery += "  AND E2_LOJA = D1_LOJA "
	//cQuery += "  AND E2_BAIXA BETWEEN '" + DTOS(MV_PAR07) + "' AND '" + DTOS(MV_PAR08) + "' "
	//cQuery += "  AND E2_EMIS1 = D1_DTDIGIT  "
	cQuery += "  )  "
	cQuery += "  WHERE D1.D_E_L_E_T_  = ''     "
	cQuery += "  AND D1_FILIAL BETWEEN  '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	IF  MV_PAR06 = 2
		cQuery += "  AND D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
	Else
		cQuery += "  AND D1_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
	EndIf
	cQuery += "  AND E2_BAIXA BETWEEN '" + DTOS(MV_PAR07) + "' AND '" + DTOS(MV_PAR08) + "' "
	cQuery += "  AND D1_TES <> ''  "
	cQuery += "  ORDER BY FILIAL_CLASS, NUMERO_PRO, C7_PRODUTO, C7_NUM, C7_ITEM  "

	MemoWrite("C:\spool\xcgucp01",cQuery)

	If Select(_cAlias) > 0
		dbSelectArea(_cAlias)
		(_cAlias)->(DbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cAlias,.T.,.F.)

	DbSelectArea(_cAlias)
	(_cAlias)->(dbGotop())


	PROCREGUA (8500)
	While !(_cAlias)->(EOF())

		INCPROC()
		PROC_ATU := (((_cAlias)->FILIAL_CLASS) + ((_cAlias)->NUMERO_PRO))
		PROC_ANT := PROC_ATU

		REG_MESTRE := 0

		While PROC_ATU == PROC_ANT
			//      dataclassTemp  := Trim((_cAlias)->DATA_CLASS)
			//      IncProc("GERANDO INFORMAÇÕES PARA CGU, ANO: "+SUBSTR(dataclassTemp,1,4) )

			IF (PROC_ATU = PROC_ANT .and. REG_MESTRE = 0) .OR. MV_PAR05 = 2

				If InicioPrograma == 0
					InicioPrograma := 1
				Else
					ARRAY_DADOS[19]   := DescObjeto
					ARRAY_DADOS[27]   := valorContrato
					ARRAY_DADOS[28]   := valorPago
					ARRAY_DADOS[8]    := valorPago
					AAdd(aDados, ARRAY_DADOS)
				EndIf

				REG_MESTRE := 1
				valorContrato := 0
				filialTemp := ""
				modalok := ""
				DescObjeto := ""
				FinalizaObjeto := 0
				valorPedido := 0
				valorContrato := 0
				valorPago   := 0
				valorTotal  := 0
				valorDesc    := 0
				percentualExecucao   := ""
				Conta_Cotacao := 1

				ARRAY_DADOS   := Array(76)  //Limpeza do Array Planilha

				valorPago += (_cAlias)->PAGO_IT_NF
				valorPedido += (_cAlias)->TOTAL_PC

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

				if !EMPTY(solicitacaoContrato) .and. EMPTY(dataScTemp)
					Trim(dataScTemp) := Posicione("SC1", 1, (_cAlias)->FILIAL_CLASS+solicitacaoContrato+((_cAlias)->ITEM_PC), "C1_EMISSAO")
				EndIf

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
				ARRAY_DADOS[2]  := dataclassTemp
				ARRAY_DADOS[4]  := (_cAlias)->FILIAL_PC
				ARRAY_DADOS[5]  := (_cAlias)->NUMERO_PC
				ARRAY_DADOS[6]  := (_cAlias)->COD_OBJ
				ARRAY_DADOS[7]  := (_cAlias)->ITEM_PC


				ARRAY_DADOS[9] := compradorContrato+" - "+(Posicione("SY1", 1, SUBSTRING(filialTemp,1,4)+"    "+(SUBSTRING(compradorContrato, 1, 3)), "Y1_NOME" ))


				/*		  If EMPTY(compradorContrato)
				solicitacaoContrato    := Posicione("SC8", 1, (_cAlias)->FILIAL_PC+cotacaoContrato+(_cAlias)->C7_FORNECE+'0001', "C8_NUMSC")
				compradorContrato      := Posicione("SC1", 1, (_cAlias)->FILIAL_PC+solicitacaoContrato+(_cAlias)->ITEM_PC, "C1_XCODCOM")
				ARRAY_DADOS[9] := compradorContrato+" - "+(Posicione("SY1", 1, SUBSTRING((_cAlias)->FILIAL_CLASS,1,4)+"    "+(SUBSTRING(compradorContrato, 1, 3)), "Y1_NOME" ))
				Else
				ARRAY_DADOS[9] := compradorContrato+" - "+(Posicione("SY1", 1, SUBSTRING(filialTemp,1,4)+"    "+(SUBSTRING(compradorContrato, 1, 3)), "Y1_NOME" ))
				EndIf
				If EMPTY(compradorContrato)
				ARRAY_DADOS[9] := "999 - Comprador GEMAT"
				EndIf */

				ARRAY_DADOS[10] := (_cAlias)->B1_CONTA
				If  !EMPTY((_cAlias)->NM_CONTRATO)
					percentualExecucao := STR(ROUND(100*(valorPago / valorContrato) , 2))
				EndIf

				If  !EMPTY((_cAlias)->NM_CONTRATO)
					dtAssCnt        := Posicione("CN9", 1, (_cAlias)->FILIAL_CLASS+(_cAlias)->NM_CONTRATO, "CN9_DTASSI" ) // Data da Assinatura do Contrato // Ano_CGU
					ARRAY_DADOS[11]  := YEAR(dtAssCnt) // Ano da Assinatura do Contrato // Ano_CGU
					ano_class       := YEAR(dtAssCnt)
				Else
					ARRAY_DADOS[11]  := (_cAlias)->ANO_PC // Ano da Emissão do Pedido
					ano_class  := (_cAlias)->ANO_PC
				Endif


				/*
				COMPRA COMPARTILHADA::::::
				1-Não
				2-Sim, por percentual
				3-Sim, por valor
				4-Sim, outros motivos
				*/
				ARRAY_DADOS[13]  := "1-Não" // Contratação_CGU
				ARRAY_DADOS[14]  := "" // Informações_Sobre_Contratação_CGU


				//Conforme acordado com o Sr. Kelson em 01/10/2013, quando não houver número de processo, deveremos informar a chave  "FILIAL+PC "

				If  !EMPTY((_cAlias)->NM_CONTRATO)
					If  !EMPTY(revisaoContrato)
						ARRAY_DADOS[16] := ((chr(160)+(_cAlias)->NM_CONTRATO)+ "/"+(SUBSTRING(revisaoContrato,1,3)))
					Else
						ARRAY_DADOS[16] := (chr(160)+(_cAlias)->NM_CONTRATO)
					EndIf
				Else
					ARRAY_DADOS[16]     := (chr(160)+(_cAlias)->NUMERO_PRO)
				EndIf


				/*        If !Empty((_cAlias)->C7_NUMPR)
				ARRAY_DADOS[3]  := (chr(160)+(_cAlias)->C7_NUMPR)
				Else
				ARRAY_DADOS[3]  := (chr(160)+(_cAlias)->NUMERO_PRO)
				EndIf  */

				ARRAY_DADOS[3]  := (chr(160)+(_cAlias)->NUMERO_PRO)

				// TRATA MODALIDADE - FAZER POSICIONE NA SX5 COM NUMERO_PRO


				If !EMPTY((_cAlias)->MODALIDADE) .and. EMPTY(modalok)
					modalok := (_cAlias)->MODALIDADE
				ElseIf (SUBSTR((_cAlias)->DESC_OBJ,1,7)) ==  "LANCHE "  .and. EMPTY(modalok)
					modalok :=  "CONVITE"
				ElseIf EMPTY(modalok)
					modalok  := "SEM CLASSIFICACAO"
				EndIf

				ARRAY_DADOS[17]  := modalok

				/*
				MODALIDADES:::::::
				Concorrência com Registro de Preço
				Concorrência sem Registro de Preço
				Concurso
				Conve
				Leilão
				Pregão com Registro de Preço
				Pregão sem Registro de Preço
				Tomada de Preços com Registro de Preço
				*/


				// NATUREZA>> INFORMAR CODIGO ( 1-(MO_MAO DE OBRA) 2-(SV_SERVIÇO) 3-(AI_ATIVO IMOBILIZADO, MC_MATERIAL CONSUMO, ME_MERCADORIA) )
				//	    ARRAY_DADOS[9]   := (_cAlias)->NAT_OBJ + ' - ' + Posicione( "SX5", 1, '01GO    02'+(_cAlias)->NAT_OBJ, "X5_DESCRI")

				If (_cAlias)->NAT_OBJ = 'MO'
					TipoObj := '1-Obra'
				ElseIf (_cAlias)->NAT_OBJ = 'SV'
					TipoObj := '2-Serviço'
				ElseIf ((_cAlias)->NAT_OBJ = 'ME' .or. (_cAlias)->NAT_OBJ = 'MC' .or. (_cAlias)->NAT_OBJ = 'AI')
					TipoObj := '3-Compra'
				ElseIf (_cAlias)->NAT_OBJ = 'AL'
					TipoObj := '4-Aluguel'
				Else
					TipoObj := '5-Outro'
				EndIf

				ARRAY_DADOS[18]   := TipoObj

				DescObjeto := ALLTRIM(ALLTRIM((_cAlias)->DESC_OBJ))

				COD_OBJ_ANT := (_cAlias)->COD_OBJ
				DESCOBJ_ANT := (_cAlias)->DESC_OBJ
				/*
				ARRAY_DADOS[20]  := (_cAlias)->DESC_CONTA // Categoria_Descricao_Objeto_CGU
				*/

				cXDesc := Alltrim((_cAlias)->DESC_CONTA)

				Do Case

					Case At("ALIMENTICIO",cXDesc) > 0
					If "ALMOCO" $ DescObjeto
						ARRAY_DADOS[20]  := "28-Serviços de eventos e buffets"
					Else
						ARRAY_DADOS[20]  := "10-Compra de gêneros alimentícios e bebidas"
					EndIf
					Case At("EXPEDIENTE",cXDesc) > 0
					ARRAY_DADOS[20]  := "15-Compra de materiais de expediente"
					Case At("CONSTRUCOES EM ANDAMENTO",cXDesc) > 0
					ARRAY_DADOS[20]  := "31-Serviços de obras\reformas\demolição"
					Case At("PERIODICOS",cXDesc) > 0
					ARRAY_DADOS[20]  := "21-Compra\serviços\assinaturas de editoriais e revistas e livros"
					Case At("ESTUDANTES",cXDesc) > 0
					ARRAY_DADOS[20]  := "35-Serviços de treinamento e qualificação"
					Case At("TECNICOS ESPECIALIZADOS",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("SEGURO DE VEICULOS",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("ENCOMENDAS",cXDesc) > 0
					ARRAY_DADOS[20]  := "39-Serviços transporte de materiais e pessoas"
					Case At("HOSPEDAGENS",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("LICENCA DE USO SOFTWARE",cXDesc) > 0
					ARRAY_DADOS[20]  := "20-Compra\ servios de desenvolvimento de sistemas e aplicativos e softwares"
					Case At("REPAROS DE BENS MOVEIS",cXDesc) > 0
					If "PREDIAL" $ DescObjeto
						ARRAY_DADOS[20]  := "31-Serviços de obras\reformas\demolição"
					ElseIf "DISJUNTOR" $ DescObjeto .OR. "REATOR " $ DescObjeto .OR. "SENSOR PRESENCA" $ DescObjeto .OR. "TOMADA " $ DescObjeto .OR. "TOMADA/REGUA" $ DescObjeto
						ARRAY_DADOS[20]  := "13-Compra de materiais de elétricos"
					ElseIf "," $ DescObjeto
						ARRAY_DADOS[20]  := "12-Compra de materiais de construção"
					Else
						ARRAY_DADOS[20]  := "40-Outros"
					EndIf
					Case At("SERVICOS GRAFICOS",cXDesc) > 0
					ARRAY_DADOS[20]  := "37-Serviços gráficos"
					Case At("OUTROS SEGUROS",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("OUTROS SERVICOS DE TERCEIROS",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("CONSULTORIA",cXDesc) > 0
					ARRAY_DADOS[20]  := "26-Serviços de consultoria"
					Case At("ALUGUEL DE EQUIPAMENTOS DE TI",cXDesc) > 0
					ARRAY_DADOS[20]  := "03-Aluguel de equipamentos telefonia, telecomunicações e informática"
					Case At("DESPESAS DE ALIMENTACAO",cXDesc) > 0
					ARRAY_DADOS[20]  := "28-Serviços de eventos e buffets"
					Case At("AUDITORIA",cXDesc) > 0
					ARRAY_DADOS[20]  := "25-Serviços de auditoria"
					Case At("SERVICOS DE LIMPEZA",cXDesc) > 0
					ARRAY_DADOS[20]  := "38-Serviços limpeza e conservação"
					Case At("LOCACAO DE IMOVEIS",cXDesc) > 0
					ARRAY_DADOS[20]  := "04-Aluguel de imóveis"
					Case At("SEGURO",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("LOCACAO DE MAQUINAS",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("LABORATORIAIS",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("EVENTOS,",cXDesc) > 0
					ARRAY_DADOS[20]  := "28-Serviços de eventos e buffets"
					Case At("PUBLICIDADE",cXDesc) > 0
					ARRAY_DADOS[20]  := "32-Serviços de publicidade e propaganda"
					Case At("SEGURANCA E VIGILANCIA",cXDesc) > 0
					ARRAY_DADOS[20]  := "36-Serviços de vigilância e segurança"
					Case At("EDUCACAO PROFISSIONAL",cXDesc) > 0
					ARRAY_DADOS[20]  := "35-Serviços de treinamento e qualificação"
					Case At("MATERIAL DE LIMPEZA",cXDesc) > 0
					ARRAY_DADOS[20]  := "17-Compra de materias de limpeza e conservação"
					Case At("MATERIAL DE TELECOMUNICACAO",cXDesc) > 0
					ARRAY_DADOS[20]  := "06-Compra bens e serviços de telefonia"
					Case At("MATERIAL DE COMPUTACAO",cXDesc) > 0
					ARRAY_DADOS[20]  := "08-Compra de bens,suprimentos e serviços de informática"
					Case At("AQUISICAO DE MERCADORIAS REVENDA",cXDesc) > 0
					If "APOSTILA" $ DescObjeto
						ARRAY_DADOS[20]  := "21-Compra\serviços\assinaturas de editoriais e revistas e livros"
					EndIf
					Case At("VESTUARIO",cXDesc) > 0
					ARRAY_DADOS[20]  := "19-Compra de roupas,blusas, camisas"
					Case At("MOBILIARIO EM GERAL",cXDesc) > 0
					ARRAY_DADOS[20]  := "18-Compra de móveis"
					Case At("ENERGIA ELETRICA",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("MATERIAL DIDATICO",cXDesc) > 0
					ARRAY_DADOS[20]  := "21-Compra\serviços\assinaturas de editoriais e revistas e livros"
					Case At("COMUNICACAO EM GERAL",cXDesc) > 0
					ARRAY_DADOS[20]  := "24-Serviços de assinatura de TV, internet e telefonia"
					Case At("TRANSPORTE ENCOMENDAS",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("TAXAS",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("PREMIOS, BRINDES",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("DESENV.SOFTWARES",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("COMBUST., LUBRIFICANTE",cXDesc) > 0
					ARRAY_DADOS[20]  := "09-Compra de combustíveis"
					Case At("EQUIPAMENTOS DE INFORMATICA",cXDesc) > 0
					ARRAY_DADOS[20]  := "08-Compra de bens,suprimentos e serviços de informática"
					Case At("MATERIAL ESPORTIVO E DE RECREACAO",cXDesc) > 0
					ARRAY_DADOS[20]  := "15-Compra de materiais de expediente"
					Case At("TRANSPORTES URBANOS",cXDesc) > 0
					ARRAY_DADOS[20]  := "39-Serviços transporte de materiais e pessoas"
					Case At("MATERIAL MEDICO",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("PLANO DE SAUDE A",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("MAQUINAS E EQUIPAMENTOS EM GERAL",cXDesc) > 0
					ARRAY_DADOS[20]  := "40-Outros"
					Case At("LOCACAO DE VEICULOS",cXDesc) > 0
					ARRAY_DADOS[20]  := "02-Aluguel de automóveis"
					OtherWise
					ARRAY_DADOS[20]  := cXDesc
				EndCase

				If Empty(ARRAY_DADOS[20])
					ARRAY_DADOS[20]  := cXDesc
				EndIf
				/*
				CATEGORIAS::::::::
				01-Mais de uma categoria
				02-Aluguel de automóveis
				03-Aluguel de equipamentos telefonia, telecomunicações e informática
				04-Aluguel de imóveis
				05-Aluguel de móveis
				06-Compra bens e serviços de telefonia
				07-Compra de automóveis
				08-Compra de bens,suprimentos e serviços de informática
				09-Compra de combustíveis
				10-Compra de gêneros alimentícios e bebidas
				11-Compra de imóveis
				12-Compra de materiais de construção
				13-Compra de materiais de elétricos
				14-Compra de materiais de estoque
				15-Compra de materiais de expediente
				16-Compra de materiais para treinamento e qualificação
				17-Compra de materias de limpeza e conservação
				18-Compra de móveis
				19-Compra de roupas,blusas, camisas
				20-Compra\ servios de desenvolvimento de sistemas e aplicativos e softwares
				21-Compra\serviços\assinaturas de editoriais e revistas e livros
				22-Serviços de advocacia
				23-Serviços de agendamento de viagens
				24-Serviços de assinatura de TV, internet e telefonia
				25-Serviços de auditoria
				26-Serviços de consultoria
				27-Serviços de desintetização, desratização,descupinização
				28-Serviços de eventos e buffets
				29-Serviços de filmagem, vídeo, áudio
				30-Serviços de manuntenção\revisão de automóveis
				31-Serviços de obras\reformas\demolição
				32-Serviços de publicidade e propaganda
				33-Serviços de teatro
				34-Serviços de tradução
				35-Serviços de treinamento e qualificação
				36-Serviços de vigilância e segurança
				37-Serviços gráficos
				38-Serviços limpeza e conservação
				39-Serviços transporte de materiais e pessoas
				40-Outros
				*/

				If  EMPTY((_cAlias)->NM_CONTRATO)
					ARRAY_DADOS[21]  := "" // Criterio_Julgamento_CGU
				Else
					ARRAY_DADOS[21]  := "1-Menor Preço" // Criterio_Julgamento_CGU
				EndIf

				If  !EMPTY((_cAlias)->NM_CONTRATO)
					dtAssCnt         := Posicione("CN9", 1, (_cAlias)->FILIAL_CLASS+(_cAlias)->NM_CONTRATO, "CN9_DTASSI" ) // Data da Assinatura do Contrato
					ARRAY_DADOS[22]  := dtAssCnt  // Data da Assinatura do Contrato
				Else
					ARRAY_DADOS[22]  := dataPcTemp  // Data da Emissão do Pedido
				Endif

				If  !EMPTY((_cAlias)->NM_CONTRATO)
					If  !EMPTY(revisaoContrato)
						ARRAY_DADOS[23] := ((chr(160)+(_cAlias)->NM_CONTRATO)+ "/"+(SUBSTRING(revisaoContrato,1,3)))
					Else
						ARRAY_DADOS[23] := (chr(160)+(_cAlias)->NM_CONTRATO)
					EndIf
				Else
					ARRAY_DADOS[23] := ""
				EndIf

				//Conforme acordado com o Sr. Kelson em 01/10/2013, os campos  "RAZÃO_SOCIAL " e  "CNPJ "
				//devem trazer as informações do fornecedor do PC, ou seja, o ganhador do processo.

				If Empty(dataContrato)
					dataCtrTemp := (_cAlias)->EMISS_PC
				Else
					dataCtrTemp := dataContrato
				EndIf

				dataCtrTemp := SUBSTR(dataCtrTemp,7,2)+ "/"+SUBSTR(dataCtrTemp,5,2)+ "/"+SUBSTR(dataCtrTemp,1,4)
				// dados do edital (numero e data)
				ARRAY_DADOS[12]  := ""
				ARRAY_DADOS[15]  := dataCtrTemp // >> pega data do contrato e traz como data do edital >> dataCtrTemp
				// -------
				ARRAY_DADOS[24]  := (_cAlias)->NM_FORN_COT
				ARRAY_DADOS[25]  := CHR(13) + (_cAlias)->A2_CGC

				// DATA DO CONTRATO
				If  EMPTY(dataCtrTemp)
					ARRAY_DADOS[26]  := ""
				Else
					ARRAY_DADOS[26]  := dataCtrTemp
				Endif

				//Acumular valor pedido e manter valor contrato no final caso a chave seja igual

				//     valorPedido += ((_cAlias)->TOTAL_PC)

				If  EMPTY((_cAlias)->NM_CONTRATO)
					valorContrato := valorPago
				Else
					valorContrato := (_cAlias)->CN9_VLATU
				EndIf


				//Regra de geração do arquivo defenida com o Sr. Kelson (segundo o Sr. Thiago):
				If  !EMPTY((_cAlias)->NM_CONTRATO)
					ARRAY_DADOS[29] := vigenciaContrato
				Else
					ARRAY_DADOS[29] := 0
				Endif

				If  tipoRevisao == "008" .or. tipoRevisao == "018"
					ARRAY_DADOS[30] := "1-Sim" // Houve aditivo de Preço ?   1 = Sim
				Else
					ARRAY_DADOS[30] := "2-Não" // Houve aditivo de Preço ?   2 = Não
				Endif

				If tipoRevisao == "017"
					ARRAY_DADOS[31] := "1-Sim" // Houve aditivo de Prazo ?    1 = Sim
				Else
					ARRAY_DADOS[31] := "2-Não" // Houve aditivo de Prazo ?    2 = Não
				Endif

				ARRAY_DADOS[32] := "2-Não" // Provocou_Alteracao_Qualidade_Objeto_CGU

				ARRAY_DADOS[33] := valorContrato  // Valor Referencia licitacao da Obra

				//ARRAY_DADOS[34] := CHR(13) + percentualExecucao
				ARRAY_DADOS[34] := Val(percentualExecucao)

				If (_cAlias)->B1_CONTA == '12030103' .or. (_cAlias)->B1_CONTA == '32010102003'
					ARRAY_DADOS[33] := valorContrato
					percentualExecucao := STR(ROUND(100*( valorPago / valorContrato) , 2)) // PERCENTUAL DE EXECUÇÃO = VALOR PAGO / VALOR CONTRATADO OBRAS
					//ARRAY_DADOS[34] := CHR(13) + percentualExecucao
					ARRAY_DADOS[34] := Val(percentualExecucao)
				Endif

				//ARRAY_DADOS[34] := Iif(Val(percentualExecucao)>=100,"Paralisada","Em execução")  // Fase Atual da Obra [Em execução / Paralisada]



				/*
				OBSERVAÇÕES::::::::
				SE COMPRA CENTRALIZADA = 1 ou 4
				SE 1 - COMPRA EFETIVADA POR PROPRIA UNIDADE(FILIAL)
				SE 4 - COMPRA CENTRALIZADA COM VALOR INDIVIDUAL CONFORME ITENS REQUISITADOS POR UNIDADE(FILIAL)
				*/


				//FIM - TRATAMENTO DOS CAMPOS DE  "CONSTRUÇÃO EM ANDAMENTO "

				// TRATAMENTO DE FORNECEDORES DE COTAÇÕES.

				COT_FILIAL    := ""
				COT_NUM       := ""
				COT_FRN       := ""
				COT_LOJA      := ""
				COT_PEDIDO    := ""
				COT_ITEMPC    := ""
				COT_FRN_ANT   := ""

				If  EMPTY((_cAlias)->NM_CONTRATO)
					COT_FILIAL := (_cAlias)->FILIAL_PC
				Else
					COT_FILIAL := (_cAlias)->FILIAL_CLASS
				EndIf

				COT_LOJA   := (_cAlias)->PC_LOJA
				COT_SC     := (_cAlias)->NUMERO_SC
				COT_ITEMSC := (_cAlias)->ITEM_SC

				_cAliasA := GetNextAlias()
				BEGINSQL alias _cAliasA
					SELECT  *
					FROM  %TABLE:SC8% AS C8
					WHERE C8.%notdel%
					AND C8_FILIAL   = %Exp:COT_FILIAL%
					AND C8_NUMSC    = %Exp:COT_SC%
					AND C8_ITEM     = "0001"
					ORDER BY C8_FILIAL, C8_NUM, C8_NUMSC
				ENDSQL

				(_cAliasA)->(dbGoTop())

				If (_cAliasA)->(Eof()) .OR. EMPTY((_cAlias)->NUM_COT)
					ARRAY_DADOS[35+contadorCotacao]  := (_cAlias)->NM_FORN_COT
					ARRAY_DADOS[36+contadorCotacao]  := CHR(13) + (_cAlias)->A2_CGC
					contadorCotacao := contadorCotacao + 2
				EndIf

				If (_cAliasA)->(!Eof())
					COT_NUM := (_cAliasA)->C8_NUM
				EndIf

				If !EMPTY((_cAlias)->NUM_COT)

					DbSelectArea(_cAliasA)
					(_cAliasA)->(dbGoTop())

					COT_FRN := (_cAliasA)->C8_FORNECE

					While (_cAliasA)->(!Eof())

						If  COT_FRN_ANT != COT_FRN
							COT_FRN_ANT := COT_FRN
							ARRAY_DADOS[35+contadorCotacao]  := Posicione("SA2", 1,xFilial("SA2")+(_cAliasA)->C8_FORNECE, "A2_NOME" )
							ARRAY_DADOS[36+contadorCotacao]  := CHR(13) + Posicione("SA2", 1,xFilial("SA2")+(_cAliasA)->C8_FORNECE, "A2_CGC" )
						EndIf

						//Para casos em que existem mais de 20 participantes,
						If  contadorCotacao > 38
							ARRAY_DADOS[76] := "2-Sim" // 2 = Sim
						Else
							ARRAY_DADOS[76] := "1-Não" // 1 = Sim
						EndIf

						If  contadorCotacao < 38
							contadorCotacao := contadorCotacao + 2
						EndIf

						//Para casos em que existem mais de 20 participantes,

						(_cAliasA)->(dbSkip())
						If (_cAliasA)->(!Eof())
							COT_FRN := (_cAliasA)->C8_FORNECE
						EndIf

					End
				EndIf

				(_cAliasA)->(DbCloseArea())

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
				cnpjContrato 		   := ""
				dataScTemp 			   := ""
				dataPcTemp 			   := ""
				dataCotTemp 		   := ""
				dataCtrTemp 		   := ""

			Else

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

				valorPago += (_cAlias)->PAGO_IT_NF
				valorPedido += (_cAlias)->TOTAL_PC


				COD_OBJ_ANT := (_cAlias)->COD_OBJ
				DESCOBJ_ANT := (_cAlias)->DESC_OBJ

				If  EMPTY((_cAlias)->NM_CONTRATO)
					valorContrato := valorPago
				Else
					valorContrato := (_cAlias)->CN9_VLATU
				EndIf

			EndIf

			If Empty(ARRAY_DADOS[76])
				ARRAY_DADOS[76] := "1-Não"
			EndIf

			(_cAlias)->(dbSkip())

			PROC_ATU := (((_cAlias)->FILIAL_CLASS) + ((_cAlias)->NUMERO_PRO))

		END

	END

	ARRAY_DADOS[19]   := DescObjeto
	ARRAY_DADOS[27]   := valorContrato
	ARRAY_DADOS[28]   := valorPago
	ARRAY_DADOS[8]    := valorPago




	// fecha array

	AAdd(aDados, ARRAY_DADOS)

	DlgToExcel({ {"ARRAY", "", aCabec, aDados} })

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


	aAdd(aP,{"Filial De"   	    ,"C",8 ,0,"G","","SM0"	,"","","","",""})                          // MV_PAR01
	aAdd(aP,{"Filial Ate"  	    ,"C",8 ,0,"G","","SM0"	,"","","","",""})                          // MV_PAR02
	aAdd(aP,{"Periodo De"	    ,"D",8 ,0,"G","",""	  	,"","","","",""})                          // MV_PAR03
	aAdd(aP,{"Periodo Ate"	    ,"D",8 ,0,"G","",""	  	,"","","","",""})                          // MV_PAR04
	aAdd(aP,{"Emitir Relatório" ,"C",1 ,0,"C","",""	  	,"Sintetico","Analitico","","",""})        // MV_PAR05
	aAdd(aP,{"Data Referência:"  ,"C",1 ,0,"C","",""	,"Emitido","Classificado","","",""})       // MV_PAR06
	aAdd(aP,{"Baixa Financeira De"  ,"D",8 ,0,"G","",""	  	,"","","","",""})                      // MV_PAR07
	aAdd(aP,{"Baixa Financeira Ate"	,"D",8 ,0,"G","",""	  	,"","","","",""})                      // MV_PAR08

	//-----------------------------------------------

	aAdd(aHelp,{"Informe a filial inicial."})
	aAdd(aHelp,{"Informe a filial final."})
	aAdd(aHelp,{"Informe o Período inicial."})
	aAdd(aHelp,{"Informe o Período final."})
	aAdd(aHelp,{"Informe Se Relatório será 'Sintético'", " ou 'Analítico'"})
	aAdd(aHelp,{"Data Referência é 'Data Emissão' ou", " 'Data Classificação'"})
	aAdd(aHelp,{"Periodo Inicial Baixa Fianceira."})
	aAdd(aHelp,{"Periodo Final Baixa Fianceira."})

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