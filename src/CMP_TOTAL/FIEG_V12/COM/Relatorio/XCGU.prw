#Include "Protheus.ch"
#Include "TBICONN.CH"
#Include "COLORS.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} XCGU
Relatório para gestão de compras.

@type function
@author Iatan Marques
@since 03/12/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function XCGU()
	Local retornoPergunte := .T.
	Local lSegue          := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	If !ApOleClient("MSExcel")
		MsgAlert("Microsoft Excel não instalado!")
		lSegue := .F.
	EndIf

	If lSegue

		//GRUPO DE PERGUNTAS PARA A CONFECÇÃO DOS PARÂMETROS DO RELATÓRIO
		retornoPergunte := Pergunte("XGSTCOM", .T.)

		If retornoPergunte == .F.
			lSegue := .F.
		EndIf

		If lSegue

			// Busca dados e monta planilha
			Processa( {|| fMontaPlan() }, "Aguarde...", "Buscando Informações...",.T.)

		EndIf

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fMontaPlan
Função para gerar a query e montar planilha.

@type function
@author Daniel Flavio
@since 07/11/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fMontaPlan()
	Local aXArea	:= GetArea()
	Local cQuery 		:= ""
	Local cQueryCotacao := ""
	Local contadorCotacao := 1
	Local nXRegs := 0
	Local nA	:= 1
	Local _cAlias := GetNextAlias()
	Local _cAliasCotacao := GetNextAlias()
	Local fornecedorContrato := ""
	Local lojaFornecedorContrato := ""
	Local dtAssCnt := ""  //Data de Assinatura do Contrato
	Local cnpjContrato := ""
	Local dataContrato := ""
	Local valorContrato := ""
	Local valorIniContrato := ""
	Local vigenciaContrato := 0
	Local revisaoContrato := ""
	lOCAL valorPago := ""
	Local percentualExecucao := ""
	Local filialTemp := ""
	Local dataScTemp := ""
	Local dataPcTemp := ""
	Local dataCotTemp := ""
	Local temp := -1
	Local aCabec := {}
	Local aDados := {}
	Local ARRAY_DADOS :=  Array(86)
	Local filialScAnt  := ""
	Local numeroScAnt  := ""
	Local filialPcAnt  := ""
	Local numeroPcAnt  := ""
	Local filialCotAnt := ""
	Local numeroCotAnt := ""
	Local itemCotAnt   := ""
	Local produtoPcAnt   := ""
	Local itemPcAnt   := ""
	Local contadorFornecedor := 1
	Local lXAchou	:= .F.
	Local lSegue    := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	// Preenche array
	AAdd(aDados, {"Ano_CGU", "Numero_Edital_licitacao_CGU", "Contratação_CGU", "Informações_Sobre_Contratação_CGU", "Data_do_Edital_CGU", "Data Edital", ;
	"Número_Processo_CGU", "Modalidade_CGU", "Natureza_do_Objeto_CGU", "Descrição_do_Objeto_CGU", "Categoria_Descricao_Objeto_CGU", ;
	"Criterio_Julgamento_CGU", "Data_da_Homologação_CGU", "Número_Contrato_CGU", "Razão_Social_CGU", "CNPJ_CGU", "Fornecedor Contrato", ;
	"CNPJ Contrato", "Data_Contrato_CGU", "Valor_Contrato_CGU", "Valor_Pago_CGU", "Vigência_em_Meses_CGU", "Aditivo_Preco_CGU", ;
	"Aditivo_Prazo_CGU", "Provocou_Alteracao_Qualidade_Objeto_CGU", "Percentual Execução", "Filial SC", "Número SC", "Data SC", "Filial Pedido", ;
	"Número Pedido", "Data Pedido", "Qtd Item PC",  "Total Item PC", "Filial Cotação", "Número Cotação", "Data Cotação", "Item Cotação", ;
	"Qtd Item Cotação", "Total Item Cotação", "Valor_Referencia_Licitação_OBRA_CGU", "Percentual_Execução_OBRA_CGU", ;
	"Obra_Foi_Financiada_Com_Recursos_Da_Granularidade_CGU", "Comprador", "Conta Contábil", "CNPJ Fornecedor Cotação - 1",;
	"Nome Fornecedor Cotação - 1", "CNPJ Fornecedor Cotação - 2", "Nome Fornecedor Cotação - 2", "CNPJ Fornecedor Cotação - 3", "Nome Fornecedor Cotação - 3", ;
	"CNPJ Fornecedor Cotação - 4", "Nome Fornecedor Cotação - 4", "CNPJ Fornecedor Cotação - 5", "Nome Fornecedor Cotação - 5", "CNPJ Fornecedor Cotação - 6", ;
	"Nome Fornecedor Cotação - 6", "CNPJ Fornecedor Cotação - 7", "Nome Fornecedor Cotação - 7", "CNPJ Fornecedor Cotação - 8", "Nome Fornecedor Cotação - 8", ;
	"CNPJ Fornecedor Cotação - 9", "Nome Fornecedor Cotação - 9", "CNPJ Fornecedor Cotação - 10", "Nome Fornecedor Cotação - 10", ;
	"CNPJ Fornecedor Cotação - 11", "Nome Fornecedor Cotação - 11", "CNPJ Fornecedor Cotação - 12", "Nome Fornecedor Cotação - 12", ;
	"CNPJ Fornecedor Cotação - 13", "Nome Fornecedor Cotação - 13", "CNPJ Fornecedor Cotação - 14", "Nome Fornecedor Cotação - 14", ;
	"CNPJ Fornecedor Cotação - 15", "Nome Fornecedor Cotação - 15", "CNPJ Fornecedor Cotação - 16", "Nome Fornecedor Cotação - 16", ;
	"CNPJ Fornecedor Cotação - 17", "Nome Fornecedor Cotação - 17", "CNPJ Fornecedor Cotação - 18", "Nome Fornecedor Cotação - 18", ;
	"CNPJ Fornecedor Cotação - 19", "Nome Fornecedor Cotação - 19", "CNPJ Fornecedor Cotação - 20", "Nome Fornecedor Cotação - 20", "Mais_de_20_Propostas_CGU"})

	// Monta Query
	cQuery += " SELECT  SUBSTRING(SC7.C7_EMISSAO, 0, 5) AS ANO_PC, "
	cQuery += " 		ISNULL(SC1.C1_EMISSAO, '') AS DATA_EDITAL, "
	cQuery += "         C1_NUMPR AS NUMERO_PROCESSO, "
	cQuery += " 	    CASE SC1.C1_NUMPR WHEN '' THEN 'LICITAÇÃO'  "
	cQuery += " 			ELSE  CASE SUBSTRING(SC1.C1_NUMPR, 0, 3)  "
	cQuery += " 					WHEN 'CD' THEN 'COMPRA DIRETA'  "
	cQuery += "  					WHEN 'PG' THEN 'PREGÃO'  "
	cQuery += "  					WHEN 'CC' THEN 'CONCORRÊNCIA'  "
	cQuery += "  					WHEN 'DL' THEN 'DISPENSA LICITAÇÃO'  "
	cQuery += "  					ELSE 'INEXIGIBILIDADE'  "
	cQuery += "  			 END  "
	cQuery += "  	   END AS MODALIDADE,  "
	cQuery += "  	   SB1.B1_TIPO AS NAT_OBJ, "
	cQuery += "  	   SB1.B1_DESC AS DESC_OBJ, "
	cQuery += "  	   RTRIM(LTRIM(ISNULL(SC7.C7_CONTRA, ''))) AS NM_CONTRATO, "
	cQuery += "  	   ISNULL(SC8.C8_QUANT, '') AS QTD_ITEM_COT, "
	cQuery += "  	   ISNULL(SC8.C8_TOTAL, '') AS TOT_IT_COT, "
	cQuery += "  	   ISNULL(SC7.C7_QUANT, '') AS QTD_ITEM_PC, "
	cQuery += "  	   ISNULL(SC7.C7_TOTAL, '') AS TOT_IT_PC, "
	cQuery += "  	   SC1.C1_XCODCOM, "
	cQuery += "  	   SC7.C7_QUJE, "
	cQuery += "  	   SC7.C7_QUANT, "
	cQuery += "  	   SC7.C7_PRECO, "
	cQuery += "  	   ISNULL(SC1.C1_FORNECE, '') AS CD_FORN_SC, "
	cQuery += "  	   ISNULL(SC8.C8_FORNECE, '') AS CD_FORN_COT, "
	cQuery += "  	   ISNULL(SC7.C7_FORNECE, '') AS CD_FORN_PC, "
	cQuery += "  	   ISNULL(SA2.A2_NOME, '') AS NM_FORN_COT, "
	cQuery += "        ISNULL(SC8.C8_ITEM, '') AS ITEM_COT,  "
	cQuery += "  	   SC1.C1_FILIAL AS FILIAL_SC, "
	cQuery += "  	   SC1.C1_NUM AS NUMERO_SC, "
	cQuery += "  	   ISNULL(SC1.C1_EMISSAO, '') AS EMISS_SC, "
	cQuery += "  	   SC7.C7_FILIAL AS FILIAL_PC, "
	cQuery += "  	   SC7.C7_NUM AS NUMERO_PC, "
	cQuery += "  	   SC7.C7_PRODUTO AS PRODUTO_PC, "
	cQuery += "  	   SC7.C7_ITEM AS ITEM_PC, "
	cQuery += "  	   ISNULL(SC7.C7_EMISSAO, '') AS EMISS_PC, "
	cQuery += "  	   SC8.C8_FILIAL AS FILIAL_COT, "
	cQuery += "  	   SC8.C8_NUM AS NUMERO_COT, "
	cQuery += "  	   ISNULL(SC8.C8_EMISSAO, '') AS EMISS_COT, "
	cQuery += "  	   SC1.C1_PEDIDO AS NUMERO_PC_SC,  "
	//cQuery += "  	   SC1.C1_COTACAO AS NUMERO_COT_SC, "
	cQuery += "        CASE WHEN (SC7.C7_FORNECE = SC8.C8_FORNECE) "
	cQuery += "        THEN 'Sim' ELSE CASE WHEN SC8.C8_NUM IS NULL THEN '' ELSE '' END "
	//cQuery += "        THEN 'Sim' ELSE CASE WHEN SC8.C8_NUM IS NULL THEN 'Sim' ELSE '' END "
	cQuery += "        END AS FORNECEDOR_GANHADOR, "
	cQuery += "        RTRIM(LTRIM(SB1.B1_CONTA)) AS B1_CONTA, "
	cQuery += "        (SC1.C1_QUANT * C1_VUNIT) AS TOTAL_SC, "
	cQuery += "        SC7.C7_TOTAL "
	cQuery += " FROM SC1010 AS SC1 WITH (NOLOCK) "
	cQuery += " 	 INNER JOIN SB1010 AS SB1 WITH (NOLOCK) "
	cQuery += " 		ON ( "
	cQuery += " 			SB1.D_E_L_E_T_ <> '*' "
	cQuery += " 		) "
	cQuery += " 	 LEFT JOIN SC7010 AS SC7 WITH (NOLOCK) "
	cQuery += " 		ON ( "
	cQuery += " 			SC7.D_E_L_E_T_ <> '*' "
	cQuery += " 			AND SC7.C7_NUM = SC1.C1_PEDIDO "
	cQuery += " 			AND SC7.C7_ITEMSC = SC1.C1_ITEM "
	cQuery += " 			AND SC1.C1_FILIAL = SC7.C7_FILIAL "
	cQuery += "             AND SB1.B1_COD = SC7.C7_PRODUTO "
	cQuery += " 		) "
	cQuery += " 	 LEFT JOIN SC8010 AS SC8 WITH (NOLOCK) "
	cQuery += " 		ON ( "
	cQuery += " 			SC8.D_E_L_E_T_ <> '*' "
	cQuery += " 			AND SC8.C8_NUM = SC7.C7_NUMCOT "
	cQuery += " 			AND SC8.C8_ITEM = SC7.C7_ITEM "
	cQuery += "             AND SC8.C8_ITEM = SC1.C1_ITEM "
	cQuery += " 			AND SC8.C8_FILIAL = SC7.C7_FILIAL "
	cQuery += "             AND SC8.C8_FILIAL = SC1.C1_FILIAL "
	cQuery += " 		) "
	cQuery += " 	LEFT JOIN SA2010 AS SA2  WITH (NOLOCK) "
	cQuery += " 		ON ( "
	cQuery += " 				SA2.D_E_L_E_T_ <> '*' "
	cQuery += " 				AND SA2.A2_COD = SC8.C8_FORNECE  "
	cQuery += " 				AND SA2.A2_LOJA = SC8.C8_LOJA "
	cQuery += " 		) "
	cQuery += " WHERE SC1.D_E_L_E_T_ <> '*' "
	cQuery += " 		AND SC7.C7_NUM IS NOT NULL "
	cQuery += " 		AND SC1.C1_FILIAL >= '" + MV_PAR01 + "' "
	cQuery += "			AND SC1.C1_FILIAL <= '" + MV_PAR02 + "' "
	cQuery += " 		AND SC1.C1_EMISSAO >= '" + DTOS(MV_PAR03) + "' "
	cQuery += " 		AND SC1.C1_EMISSAO <= '" + DTOS(MV_PAR04) + "' "
	cQuery += " ORDER BY FILIAL_SC, NUMERO_SC, FILIAL_PC, NUMERO_PC, FILIAL_COT, NUMERO_COT, ITEM_COT, PRODUTO_PC, ITEM_PC "

	If Select(_cAlias) > 0
		dbSelectArea(_cAlias)
		(_cAlias)->(dbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cAlias,.T.,.F.)

	// Conta Registros encontrados
	dbEval( {|x| nXRegs++ },,{|| (_cAlias)->(!EOF())})

	// Função auxiliar da função Processa
	ProcRegua(nXRegs)

	DbSelectArea(_cAlias)
	(_cAlias)->(dbGotop())

	While !(_cAlias)->(Eof())

		// Função auxiliar da função Processa
		IncProc("Processando registro ["+StrZero(nA,12)+" de "+StrZero(nXRegs,12)+"]")
		nA++

		// Verifica se o usuário cancelou a operação
		If lEnd
			MsgStop("Cancelado pelo usuário", "Atenção")
			(_cAlias)->(dbCloseArea())
			RestArea(aXArea)
			lSegue := .F.
		EndIf

		If ! lSegue

			Exit

		Else

			// Monta o array que irá ser a base da planilha
			If  (_cAlias)->FILIAL_SC <> filialScAnt .or. ;
			(_cAlias)->NUMERO_SC <> numeroScAnt .or. ;
			(_cAlias)->FILIAL_PC <> filialPcAnt .or. ;
			(_cAlias)->NUMERO_PC <> numeroPcAnt .or. ;
			(_cAlias)->FILIAL_COT <> filialCotAnt .or. ;
			(_cAlias)->NUMERO_COT <> numeroCotAnt .or. ;
			(_cAlias)->ITEM_COT <> itemCotAnt .or. ;
			(_cAlias)->PRODUTO_PC <> produtoPcAnt .or. ;
			(_cAlias)->ITEM_PC <> itemPcAnt

				AAdd(aDados, ARRAY_DADOS)

				ARRAY_DADOS := Array(86) //Limpeza do Array
				contadorCotacao := 1 //limpeza da variável de contador de cotação

				//Caso exista algum tipo de vinculo com o contrato, devemos buscar as informações referentes a este contrato.
				If (_cAlias)->NM_CONTRATO <> '' .and. (_cAlias)->NM_CONTRATO <> '      '
					If AT((_cAlias)->DESC_OBJ,"SRP -") > 0
						filialTemp := SUBSTR((_cAlias)->FILIAL_PC, 1, 4)+'0001'
					Else
						filialTemp := (_cAlias)->FILIAL_PC
					EndIf

					fornecedorContrato := Posicione("CNC", 1, filialTemp+(_cAlias)->NM_CONTRATO, "CNC_CODIGO" )
					lojaFornecedorContrato := Posicione("CNC", 1, filialTemp+(_cAlias)->NM_CONTRATO, "CNC_LOJA" )

					cnpjContrato := Posicione("SA2", 1, "        "+fornecedorContrato+lojaFornecedorContrato, "A2_CGC" )
					fornecedorContrato := Posicione("SA2", 1, "        "+fornecedorContrato+lojaFornecedorContrato, "A2_NOME" )

					dataContrato     := Posicione("CN9", 1, filialTemp+(_cAlias)->NM_CONTRATO, "CN9_DTASSI" )
					valorContrato    := Posicione("CN9", 1, filialTemp+(_cAlias)->NM_CONTRATO, "CN9_VLATU" )
					valorIniContrato := Posicione("CN9", 1, filialTemp+(_cAlias)->NM_CONTRATO, "CN9_VLINI" )
					valorPago        := valorContrato - Posicione("CN9", 1, filialTemp+(_cAlias)->NM_CONTRATO, "CN9_SALDO" )
					revisaoContrato  := Posicione("CN9", 1, filialTemp+(_cAlias)->NM_CONTRATO, "CN9_REVISA" )
					//Conforme exigência da CGU, a vigência do contrato deve ser na unidade "Meses"
					vigenciaContrato := (Posicione("CN9", 1, filialTemp+(_cAlias)->NM_CONTRATO, "CN9_DTFIM" ) - Posicione("CN9", 1, filialTemp+(_cAlias)->NM_CONTRATO, "CN9_DTASSI" ))/30

					percentualExecucao := STR(ROUND(100*(valorPago / valorContrato) , 2))
				EndIf

				dataScTemp  := Trim((_cAlias)->EMISS_SC)
				dataPcTemp  := Trim((_cAlias)->EMISS_PC)
				dataCotTemp := Trim((_cAlias)->EMISS_COT)

				If dataScTemp <> ''
					dataScTemp := SUBSTRING(dataScTemp,7,2)+"/"+SUBSTRING(dataScTemp,5,2)+"/"+SUBSTRING(dataScTemp,1,4)
				EndIf
				If dataPcTemp <> ''
					dataPcTemp := SUBSTRING(dataPcTemp,7,2)+"/"+SUBSTRING(dataPcTemp,5,2)+"/"+SUBSTRING(dataPcTemp,1,4)
				EndIf
				If dataCotTemp <> ''
					dataCotTemp := SUBSTRING(dataCotTemp,7,2)+"/"+SUBSTRING(dataCotTemp,5,2)+"/"+SUBSTRING(dataCotTemp,1,4)
				EndIf

				//MONTAGEM DO ARRAY DE DADOS (LINHA DO EXCELL)
				If (_cAlias)->NM_CONTRATO <> '' .and. (_cAlias)->NM_CONTRATO <> '      '
					dtAssCnt         := Posicione("CN9", 1, filialTemp+(_cAlias)->NM_CONTRATO, "CN9_DTASSI" ) // Data da Assinatura do Contrato // Ano_CGU
					ARRAY_DADOS[1]  := YEAR(dtAssCnt) // Ano da Assinatura do Contrato // Ano_CGU
				Else
					ARRAY_DADOS[1]  := (_cAlias)->ANO_PC // Ano da Emissão do Pedido
				End
				ARRAY_DADOS[2]  := "" // Numero_Edital_de_Licitação_CGU
				ARRAY_DADOS[3]  := "1" // Contratação_CGU
				ARRAY_DADOS[4]  := "" // Informações_Sobre_Contratação_CGU
				ARRAY_DADOS[5]  := "" // Data_do_Edital_CGU
				ARRAY_DADOS[6]  := dataScTemp

				//Conforme acordado com o Sr. Kelson em 01/10/2013, quando não houver número de processo, deveremos informar a chave "FILIAL+PC"
				If (_cAlias)->NUMERO_PROCESSO <> '' .and. (_cAlias)->NUMERO_PROCESSO <> '               '
					ARRAY_DADOS[7]  := (_cAlias)->NUMERO_PROCESSO
				Else
					ARRAY_DADOS[7]  := (_cAlias)->FILIAL_PC+(_cAlias)->NUMERO_PC
				End

				ARRAY_DADOS[8]  := (_cAlias)->MODALIDADE
				ARRAY_DADOS[9]  := (_cAlias)->NAT_OBJ + ' - ' + Posicione("SX5", 1, '01GO    02'+(_cAlias)->NAT_OBJ, "X5_DESCRI")
				ARRAY_DADOS[10]  := (_cAlias)->DESC_OBJ
				ARRAY_DADOS[11]  := "" // Categoria_Descricao_Objeto_CGU
				ARRAY_DADOS[12]  := "" // Criterio_Julgamento_CGU

				If (_cAlias)->NM_CONTRATO <> '' .and. (_cAlias)->NM_CONTRATO <> '      '
					dtAssCnt         := Posicione("CN9", 1, filialTemp+(_cAlias)->NM_CONTRATO, "CN9_DTASSI" ) // Data da Assinatura do Contrato
					ARRAY_DADOS[13]  := (dtAssCnt) // Data da Assinatura do Contrato
				Else
					ARRAY_DADOS[13]  := dataPcTemp // Ano da Emissão do Pedido
				End

				If (_cAlias)->NM_CONTRATO <> '' .and. (_cAlias)->NM_CONTRATO <> '      '
					ARRAY_DADOS[14]  := PADL((_cAlias)->NM_CONTRATO, 15, "0")
				Else
					ARRAY_DADOS[14]  := (_cAlias)->NM_CONTRATO
				End

				//Conforme acordado com o Sr. Kelson em 01/10/2013, os campos "RAZÃO_SOCIAL" e "CNPJ"
				//devem trazer as informações do fornecedor do PC, ou seja, o ganhador do processo.
				ARRAY_DADOS[15]  := Posicione("SA2", 1, "        "+(_cAlias)->CD_FORN_PC, "A2_NOME" )
				ARRAY_DADOS[16]  := CHR(13) + Posicione("SA2", 1, "        "+(_cAlias)->CD_FORN_PC, "A2_CGC" )

				ARRAY_DADOS[17]  := fornecedorContrato
				ARRAY_DADOS[18]  := CHR(13) + cnpjContrato
				ARRAY_DADOS[19] := dataContrato
				//Regra de geração do arquivo defenida com o Sr. Kelson (segundo o Sr. Thiago):
				If (_cAlias)->NM_CONTRATO <> '' .and. (_cAlias)->NM_CONTRATO <> '      '
					ARRAY_DADOS[20] := valorContrato
				Else
					ARRAY_DADOS[20] := (_cAlias)->TOT_IT_PC
				End

				//Regra de geração do arquivo defenida com o Sr. Kelson (segundo o Sr. Thiago):
				//O CAMPO "C7_QUJE" DEVE SER VERIFICADO AFIM DE ATENDER ÀS POSSIBILIDADES DE "ENTREGA PARCIAL"
				If (_cAlias)->NM_CONTRATO <> '' .and. (_cAlias)->NM_CONTRATO <> '      '
					ARRAY_DADOS[21] := valorPago
				Else
					If (_cAlias)->C7_QUJE <> (_cAlias)->C7_QUANT
						ARRAY_DADOS[21] := (_cAlias)->C7_QUJE * (_cAlias)->C7_PRECO
					Else
						ARRAY_DADOS[21] := (_cAlias)->TOT_IT_PC
					End
				End

				//Regra de geração do arquivo defenida com o Sr. Kelson (segundo o Sr. Thiago):
				If (_cAlias)->NM_CONTRATO <> '' .and. (_cAlias)->NM_CONTRATO <> '      '
					ARRAY_DADOS[22] := vigenciaContrato
				Else
					ARRAY_DADOS[22] := 0
				End

				If valorContrato <> valorIniContrato
					ARRAY_DADOS[23] := "1" // Houve aditivo de Preço ?   1 = Sim
				Else
					ARRAY_DADOS[23] := "2" // Houve aditivo de Preço ?    2 = Não
				End

				ARRAY_DADOS[24] := "2" // Houve aditivo de Prazo ?
				ARRAY_DADOS[25] := "2" // Provocou_Alteracao_Qualidade_Objeto_CGU
				ARRAY_DADOS[26] := percentualExecucao
				ARRAY_DADOS[27] := (_cAlias)->FILIAL_SC
				ARRAY_DADOS[28] := (_cAlias)->NUMERO_SC
				ARRAY_DADOS[29] := dataScTemp
				ARRAY_DADOS[30] := (_cAlias)->FILIAL_PC
				ARRAY_DADOS[31] := (_cAlias)->NUMERO_PC
				ARRAY_DADOS[32] := dataPcTemp
				ARRAY_DADOS[33] := (_cAlias)->QTD_ITEM_PC
				ARRAY_DADOS[34] := (_cAlias)->TOT_IT_PC

				ARRAY_DADOS[35] := (_cAlias)->FILIAL_COT
				ARRAY_DADOS[36] := (_cAlias)->NUMERO_COT
				ARRAY_DADOS[37] := dataCotTemp
				ARRAY_DADOS[38] := (_cAlias)->ITEM_COT
				ARRAY_DADOS[39] := (_cAlias)->QTD_ITEM_COT
				ARRAY_DADOS[40] := (_cAlias)->TOT_IT_COT

				//TRATAMENTO DOS CAMPOS DE "CONSTRUÇÃO EM ANDAMENTO"
				ARRAY_DADOS[41] := ""
				ARRAY_DADOS[42] := ""
				If (_cAlias)->B1_CONTA = '12030103' .or. (_cAlias)->B1_CONTA = '32010102003'
					ARRAY_DADOS[41] := (_cAlias)->TOTAL_SC
					ARRAY_DADOS[42] := STR(ROUND(100*( (_cAlias)->TOT_IT_PC / (_cAlias)->TOTAL_SC) , 2)) // PERCENTUAL DE EXECUÇÃO = VALOR PAGO / VALOR CONTRATADO
				ENDIF
				//FIM - TRATAMENTO DOS CAMPOS DE "CONSTRUÇÃO EM ANDAMENTO"

				ARRAY_DADOS[43] := ""
				ARRAY_DADOS[44] := (_cAlias)->C1_XCODCOM + " - " + Posicione("SY1", 1, SUBSTR((_cAlias)->FILIAL_SC,1,4)+"    "+(_cAlias)->C1_XCODCOM, "Y1_NOME")

				ARRAY_DADOS[45] := (_cAlias)->B1_CONTA

				ARRAY_DADOS[45+contadorCotacao] := CHR(13) + Posicione("SA2", 1, "        "+(_cAlias)->CD_FORN_COT, "A2_CGC" )
				ARRAY_DADOS[46+contadorCotacao] := (_cAlias)->NM_FORN_COT

				//limpeza das variáveis
				fornecedorContrato     := ""
				lojaFornecedorContrato := ""
				dataContrato           := ""
				dtAssCnt               := ""
				valorContrato          := ""
				valorIniContrato       := ""
				valorPago              := ""
				vigenciaContrato       := 0
				cnpjContrato 			:= ""
				percentualExecucao     := ""
				filialTemp 			:= ""
				dataScTemp 			:= ""
				dataPcTemp 			:= ""
				dataCotTemp 			:= ""
				lXAchou				:= .T.
			Else
				If contadorCotacao < 40
					ARRAY_DADOS[45+contadorCotacao] := CHR(13) + Posicione("SA2", 1, "        "+(_cAlias)->CD_FORN_COT, "A2_CGC" )
					ARRAY_DADOS[46+contadorCotacao] := (_cAlias)->NM_FORN_COT
				EndIf

				//Para casos em que existem mais de 20 participantes,
				If contadorCotacao > 40
					ARRAY_DADOS[86] := "2" // 2 = Sim
				EndIf

				contadorCotacao := contadorCotacao + 2
			EndIf

			filialScAnt  := (_cAlias)->FILIAL_SC
			numeroScAnt  := (_cAlias)->NUMERO_SC
			filialPcAnt  := (_cAlias)->FILIAL_PC
			numeroPcAnt  := (_cAlias)->NUMERO_PC
			filialCotAnt := (_cAlias)->FILIAL_COT
			numeroCotAnt := (_cAlias)->NUMERO_COT
			itemCotAnt   := (_cAlias)->ITEM_COT
			produtoPcAnt := (_cAlias)->PRODUTO_PC
			itemPcAnt    := (_cAlias)->ITEM_PC

			(_cAlias)->(dbSkip())

		EndIf
	End

	If lSegue

		AAdd(aDados, ARRAY_DADOS)

		If lXAchou
			// Mensagem da geração da planilha
			MsAguarde({|| DlgToExcel({ {"ARRAY", "", aCabec, aDados} }) },"Aguarde","Gerando Planilha...")
		Else
			Alert("Não foram encontrados registros de acordo com os parâmetros informados.")
		EndIf

		(_cAlias)->(dbCloseArea())

	EndIf

	RestArea(aXArea)

Return