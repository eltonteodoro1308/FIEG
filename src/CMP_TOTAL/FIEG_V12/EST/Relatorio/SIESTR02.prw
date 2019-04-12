#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIESTR02
Listagem dos itens inventariados.

@type function
@author Leonardo Soncin
@since 06/12/2011
@version P12.1.23

@obs Projeto ELO

@history 28/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIESTR02()

	Local oReport

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If FindFunction("TRepInUse") .And. TRepInUse()
		//+------------------------------------------------------------------------+
		//|Interface de impressao                                                  |
		//+------------------------------------------------------------------------+
		oReport:= ReportDef()
		oReport:PrintDialog()
	Else
		Alert("Relatório não disponivel para R3.")
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportDef
A função estática ReportDef deverá ser criada para todos os relatórios que poderão ser agendados pelo usuário.

@type function
@author Marcos V. Ferreira
@since 20/06/2006
@version P12.1.23

@obs Projeto ELO

@history 28/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Objeto, Objeto Report do Relatorio.

/*/
/*/================================================================================================================================/*/

Static Function ReportDef()

	Local aOrdem    := {OemToAnsi(' Por Codigo    '),OemToAnsi(' Por Tipo      '),OemToAnsi(' Por Grupo   '),OemToAnsi(' Por Descricao '),OemToAnsi(' Por Local     ')}
	Local cPictQFim := PesqPict("SB2",'B2_QFIM' )
	Local cPictQtd  := PesqPict("SZL",'ZL_QUANT')
	Local cPictVFim := PesqPict("SB2",'B2_VFIM1')
	Local cTamQFim  := TamSX3('B2_QFIM' )[1]
	Local cTamQtd   := TamSX3('ZL_QUANT')[1]
	Local cTamVFim  := TamSX3('B2_VFIM1')[1]
	Local cAliasSB1 := GetNextAlias()
	Local cAliasSB2 := cAliasSB1
	Local cAliasSZL := cAliasSB1
	Local oSection1
	Local cPerg := "SIER02"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+------------------------------------------------------------------------+
	//|Criacao do componente de impressao                                      |
	//|                                                                        |
	//|TReport():New                                                           |
	//|ExpC1 : Nome do relatorio                                               |
	//|ExpC2 : Titulo                                                          |
	//|ExpC3 : Pergunte                                                        |
	//|ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  |
	//|ExpC5 : Descricao                                                       |
	//|                                                                        |
	//+------------------------------------------------------------------------+
	oReport:= TReport():New("SIESTR02","Listagem dos Itens Inventariados",cPerg, {|oReport| ReportPrint(oReport,aOrdem,cAliasSB1,cAliasSB2,cAliasSZL)},"Emite uma relacao que mostra o saldo em estoque e todas as"+" "+"contagens efetuadas no inventario. Baseado nestas duas in-"+" "+"formacoes ele calcula a diferenca encontrada.")
	oReport:DisableOrientation()
	oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.

	//+--------------------------------------------------------------+
	//| Ajusta o Grupo de Perguntas SIER02                           |
	//+--------------------------------------------------------------+
	AjustaSX1(cPerg)

	//+--------------------------------------------------------------+
	//| Verifica as perguntas selecionadas                           |
	//+--------------------------------------------------------------+
	//+--------------------------------------------------------------+
	//| Variaveis utilizadas para parametros                         |
	//| mv_par01             // Nr Documento                         |
	//+--------------------------------------------------------------+
	Pergunte(oReport:uParam,.F.)

	//+------------------------------------------------------------------------+
	//|Criacao da secao utilizada pelo relatorio                               |
	//|                                                                        |
	//|TRSection():New                                                         |
	//|ExpO1 : Objeto TReport que a secao pertence                             |
	//|ExpC2 : Descricao da secao                                              |
	//|ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   |
	//|        sera considerada como principal para a secao.                   |
	//|ExpA4 : Array com as Ordens do relatorio                                |
	//|ExpL5 : Carrega campos do SX3 como celulas                              |
	//|        Default : False                                                 |
	//|ExpL6 : Carrega ordens do Sindex                                        |
	//|        Default : False                                                 |
	//+------------------------------------------------------------------------+

	//+--------------------------------------------------------------+
	//| Criacao da Sessao 1                                          |
	//+--------------------------------------------------------------+
	oSection1:= TRSection():New(oReport, "Lancamentos para Inventario",{"SB1","SZL","SB2"},aOrdem)
	oSection1:SetTotalInLine(.F.)
	oSection1:SetNoFilter("SZL")
	oSection1:SetNoFilter("SB2")

	TRCell():New(oSection1,'B1_COD'		,cAliasSB1	,"CODIGO"				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'B1_DESC'	,cAliasSB1	,"DESCRIÇÃO"				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'ZL_LOTECTL'	,cAliasSZL	,"LOTE"				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'ZL_NUMLOTE'	,cAliasSZL	,"SUB"+CRLF+"LOTE"	,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'B1_TIPO'	,cAliasSB1	,"TP"				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'B1_GRUPO'	,cAliasSB1	,"GRUPO"				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'B1_UM'		,cAliasSB1	,"UM"				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'B2_LOCAL'	,cAliasSB2	,"AMZ"				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'ZL_DOC'		,cAliasSZL	,"DOCUMENTO"				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'ZL_QUANT'	,cAliasSZL	,"QUANTIDADE"+CRLF+"INVENTARIADA"	,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection1,'QUANTDATA'	,'   '		,"QTD NA DATA"+CRLF+"DO INVENTARIO"	,cPictQFim	,cTamQFim	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection1,'DIFQUANT'	,'   '		,"DIFERENÇA"+CRLF+"QUANTIDADE"	,cPictQtd	,cTamQtd	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection1,'DIFVALOR'	,'   '		,"DIFERENÇA"+CRLF+"VALOR"	,cPictVFim	,cTamVFim	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

	oSection1:SetHeaderPage()
	oSection1:SetTotalText( "T o t a l  G e r a l :")

Return(oReport)

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportPrint
A função estática ReportPrint deverá ser criada para todos os relatórios que poderão ser agendados pelo usuário.

@type function
@author Marcos V. Ferreira
@since 20/06/2006
@version P12.1.23

@param oReport, Objeto, Objeto Report do Relatório.
@param aOrdem, Array, Array com a ordem do relatório.
@param cAliasSB1, Carctere, Alias da tabela SB1.
@param cAliasSB2, Carctere, Alias da tabela SB2.
@param cAliasSZL, Carctere, Alias da tabela SZL.

@obs Projeto ELO

@history 28/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ReportPrint(oReport,aOrdem,cAliasSB1,cAliasSB2,cAliasSZL)

	Local oSection1	:= oReport:Section(1)
	Local nOrdem   	:= oSection1:GetOrder()
	Local cSeek    	:= ''
	Local cCompara 	:= ''
	Local cLoteCtl 	:= ''
	Local cNumLote 	:= ''
	Local cProduto 	:= ''
	Local cLocal   	:= ''
	Local dData   	:= Ctod("  /  /  ")
	Local cTipo     := ''
	Local cGrupo    := ''
	Local cWhere   	:= ''
	Local cOrderBy 	:= ''
	Local cFiltro  	:= ''
	Local cNomArq	:= ''
	Local cOrdem	:= ''
	Local nSZLCnt  	:= 0
	Local nTotal   	:= 0
	Local nX       	:= 0
	Local nTotRegs  := 0
	Local nCellTot	:= 11
	Local aSaldo   	:= {}
	Local aSalQtd  	:= {}
	Local aCM      	:= {}
	Local aRegInv   := {}
	Local lImprime  := .T.
	Local oBreak
	Local oBreak01

	//+--------------------------------------------------------------+
	//| Variaveis utilizadas qdo almoxarifado do CQ                  |
	//+--------------------------------------------------------------+
	Local   cLocCQ  := GetMV("MV_CQ")
	Private	lLocCQ  :=.T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+------------------------------------------------------------+
	//| Adiciona a ordem escolhida ao titulo do relatorio          |
	//+------------------------------------------------------------+
	oReport:SetTitle(oReport:Title()+' (' + AllTrim(aOrdem[nOrdem]) + ')')

	//+--------------------------------------------------------------+
	//| Definicao da linha de SubTotal                               |
	//+--------------------------------------------------------------+
	oBreak01 := TRBreak():New(oSection1,oSection1:Cell("B1_COD"),"T o t a l :",.F.)
	TRFunction():New(oSection1:Cell('ZL_QUANT'	),NIL,"SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
	TRFunction():New(oSection1:Cell('QUANTDATA'	),NIL,"SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
	TRFunction():New(oSection1:Cell('DIFQUANT'	),NIL,"SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
	TRFunction():New(oSection1:Cell('DIFVALOR'	),NIL,"SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)

	If nOrdem == 2 .Or. nOrdem == 3 .Or. nOrdem == 5
		If nOrdem == 2
			//-- SubtTotal por Tipo
			oBreak := TRBreak():New(oSection1,oSection1:Cell("B1_TIPO"),"SubTotal do Tipo : ",.F.)
		ElseIf nOrdem == 3
			//-- SubtTotal por Grupo
			oBreak := TRBreak():New(oSection1,oSection1:Cell("B1_GRUPO"),"SubTotal do Grupo : ",.F.)
		ElseIf nOrdem == 5
			//-- SubtTotal por Armazem
			oBreak := TRBreak():New(oSection1,oSection1:Cell("B2_LOCAL"),"SubTotal do Armazem : ",.F.)
		EndIf
		TRFunction():New(oSection1:Cell('ZL_QUANT'	),NIL,"SUM",oBreak,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
		TRFunction():New(oSection1:Cell('QUANTDATA'	),NIL,"SUM",oBreak,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
		TRFunction():New(oSection1:Cell('DIFQUANT'	),NIL,"SUM",oBreak,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
		TRFunction():New(oSection1:Cell('DIFVALOR'	),NIL,"SUM",oBreak,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
	EndIf

	//+--------------------------------------------------------------+
	//| Definicao do Total Geral do Relatorio                        |
	//+--------------------------------------------------------------+
	TRFunction():New(oSection1:Cell('ZL_QUANT'	),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)
	TRFunction():New(oSection1:Cell('QUANTDATA'	),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)
	TRFunction():New(oSection1:Cell('DIFQUANT'	),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)
	TRFunction():New(oSection1:Cell('DIFVALOR'	),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)


	//oSection1:Cell('ZL_LOTECTL'	):Disable()
	//oSection1:Cell('ZL_NUMLOTE'	):Disable()
	//nCellTot-= 2

	dbSelectArea('SB2')
	SB2->(dbSetOrder(1))

	dbSelectArea('SZL')
	SZL->(dbSetOrder(1))

	dbSelectArea('SB1')
	SB1->(dbSetOrder(1))

	nTotRegs += SB2->(LastRec())
	nTotRegs += SZL->(LastRec())

	//+--------------------------------------------------------------+
	//| ORDER BY - Adicional                                         |
	//+--------------------------------------------------------------+
	cOrderBy := "%"
	If nOrdem == 1 //-- Por Codigo
		cOrderBy += " B1_FILIAL, B1_COD "
	ElseIf nOrdem == 2 //-- Por Tipo
		cOrderBy += " B1_FILIAL, B1_TIPO, B1_COD "
	ElseIf nOrdem == 3 //-- Por Grupo
		cOrderBy += " B1_FILIAL, B1_GRUPO, B1_COD "
		cOrderBy += ", B2_LOCAL"
	ElseIf nOrdem == 4 //-- Por Descricao
		cOrderBy += "B1_FILIAL, B1_DESC, B1_COD"
	ElseIf nOrdem == 5 //-- Por Local
		cOrderBy += " B1_FILIAL, B2_LOCAL, B1_COD"
	EndIf
	cOrderBy += "%"

	//+------------------------------------------------------------------------+
	//|Inicio da Query do relatorio                                            |
	//+------------------------------------------------------------------------+
	oSection1:BeginQuery()

	//+------------------------------------------------------------------------+
	//|Transforma parametros Range em expressao SQL                            |
	//+------------------------------------------------------------------------+
	MakeSqlExpr(oReport:uParam)

	//+------------------------------------------------------------------------+
	//|Inicio do Embedded SQL                                                  |
	//+------------------------------------------------------------------------+
	BeginSql Alias cAliasSB1

		SELECT 	SB1.R_E_C_N_O_ SB1REC , SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_LOCPAD, SB1.B1_TIPO,
		SB1.B1_GRUPO, SB1.B1_DESC, SB1.B1_UM, SB2.R_E_C_N_O_ SB2REC,
		SB2.B2_FILIAL, SB2.B2_COD, SB2.B2_LOCAL, SB2.B2_DINVENT, SZL.R_E_C_N_O_ SZLREC,
		SZL.ZL_LOCAL, SZL.ZL_LOTECTL, SZL.ZL_NUMLOTE, SZL.ZL_QUANT,
		SZL.ZL_FILIAL, SZL.ZL_DOC, SZL.ZL_COD

		FROM %table:SB1% SB1,%table:SB2% SB2, %table:SZL% SZL

		WHERE SZL.ZL_FILIAL =  %xFilial:SZL%	AND SZL.ZL_DOC = %Exp:mv_par01%	AND
		SZL.%NotDel% AND
		SB1.B1_FILIAL =  %xFilial:SB1%	AND SB1.B1_COD = SZL.ZL_COD AND
		SB1.%NotDel% AND
		SB2.B2_FILIAL =  %xFilial:SB2%	AND SB2.B2_COD = SB1.B1_COD	AND
		SB2.B2_LOCAL  =  SZL.ZL_LOCAL
		AND SB2.%NotDel%

		ORDER BY %Exp:cOrderBy%

	EndSql

	oSection1:EndQuery()

	//+--------------------------------------------------------+
	//| Abertura do Arquivo de Trabalho                        |
	//+--------------------------------------------------------+
	dbSelectArea(cAliasSB1)
	oReport:SetMeter(nTotRegs)

	//+--------------------------------------------------------+
	//| Processamento do Relatorio                             |
	//+--------------------------------------------------------+
	oSection1:Init(.F.)
	While !oReport:Cancel() .And. (cAliasSB1)->(!Eof())

		oReport:IncMeter()

		nTotal   := 0
		nSZLCnt  := 0
		lImprime := .T.
		aRegInv  := {}
		cSeek    := xFilial('SZL')+(cAliasSZL)->ZL_COD+(cAliasSZL)->ZL_LOCAL+(cAliasSZL)->ZL_LOTECTL+(cAliasSZL)->ZL_NUMLOTE
		cCompara := "ZL_FILIAL+ZL_COD+ZL_LOCAL+ZL_LOTECTL+ZL_NUMLOTE"
		cProduto := (cAliasSB2)->B2_COD
		cLocal   := (cAliasSB2)->B2_LOCAL
		cLoteCtl := (cAliasSZL)->ZL_LOTECTL
		cNumLote := (cAliasSZL)->ZL_NUMLOTE
		cTipo    :=	(cAliasSB1)->B1_TIPO
		cGrupo   :=	(cAliasSB1)->B1_GRUPO
		dData 	 := Posicione("SZK",1,xFilial("SZK")+(cAliasSZL)->ZL_DOC,"ZK_DATA")

		While !oReport:Cancel() .And. !(cAliasSZL)->(Eof()) .And. cSeek == (cAliasSZL)->&(cCompara)

			oReport:IncMeter()

			nSZLCnt++

			aAdd(aRegInv,{	cProduto					,; // B2_COD
			(cAliasSB1)->B1_DESC		,; // B1_DESC
			(cAliasSZL)->ZL_LOTECTL		,; // B7_LOTECTL
			(cAliasSZL)->ZL_NUMLOTE		,; // B7_NUMLOTE
			""							,; // B7_LOCALIZ
			""							,; // B7_NUMSERI
			(cAliasSB1)->B1_TIPO		,; // B1_TIPO
			(cAliasSB1)->B1_GRUPO		,; // B1_GRUPO
			(cAliasSB1)->B1_UM 			,; // B1_UM
			(cAliasSB2)->B2_LOCAL		,; // B2_LOCAL
			(cAliasSZL)->ZL_DOC			,; // B7_DOC
			(cAliasSZL)->ZL_QUANT 		}) // B7_QUANT

			nTotal += (cAliasSZL)->ZL_QUANT

			dbSelectArea(cAliasSZL)
			(cAliasSZL)->(dbSkip())

		EndDo

		If nSZLCnt > 0

			//+------------------------------------------------------------------------+
			//|Verifica a Quantidade Disponivel/Custo Medio                            |
			//+------------------------------------------------------------------------+
			If (Rastro(cProduto) .And. !Empty(cLotectl+cNumLote))
				aSalQtd   := CalcEstL(cProduto,cLocal,dData+1,cLoteCtl,cNumLote)
				aSaldo    := CalcEst(cProduto,cLocal,dData+1)
				aSaldo[2] := (aSaldo[2] / aSaldo[1]) * aSalQtd[1]
				aSaldo[3] := (aSaldo[3] / aSaldo[1]) * aSalQtd[1]
				aSaldo[4] := (aSaldo[4] / aSaldo[1]) * aSalQtd[1]
				aSaldo[5] := (aSaldo[5] / aSaldo[1]) * aSalQtd[1]
				aSaldo[6] := (aSaldo[6] / aSaldo[1]) * aSalQtd[1]
				aSaldo[7] := aSalQtd[7]
				aSaldo[1] := aSalQtd[1]
			Else
				If cLocCQ == cLocal
					aSalQtd	  := A340QtdCQ(cProduto,cLocal,dData+1,"")
					aSaldo	  := CalcEst(cProduto,cLocal,dData+1)
					aSaldo[2] := (aSaldo[2] / aSaldo[1]) * aSalQtd[1]
					aSaldo[3] := (aSaldo[3] / aSaldo[1]) * aSalQtd[1]
					aSaldo[4] := (aSaldo[4] / aSaldo[1]) * aSalQtd[1]
					aSaldo[5] := (aSaldo[5] / aSaldo[1]) * aSalQtd[1]
					aSaldo[6] := (aSaldo[6] / aSaldo[1]) * aSalQtd[1]
					aSaldo[7] := aSalQtd[7]
					aSaldo[1] := aSalQtd[1]
				Else
					aSaldo := CalcEst(cProduto,cLocal,dData+1)
				EndIf
			EndIf
			//If mv_par12 == 1
			aCM:={}
			If QtdComp(aSaldo[1]) > QtdComp(0)
				For nX:=2 to Len(aSaldo)
					aAdd(aCM,aSaldo[nX]/aSaldo[1])
				Next nX
			Else
				aCM := PegaCmAtu(cProduto,cLocal)
			EndIf
			//Else
			//aCM := PegaCMFim(cProduto,cLocal)
			//EndIf

			//+------------------------------------------------------------------+
			//| lImprime - Variavel utilizada para verificar se o usuario deseja |
			//| Listar Produto: 1-Com Diferencas / 2-Sem Diferencas / 3-Todos    |                              |
			//+------------------------------------------------------------------+
			If nTotal-aSaldo[1] == 0
				If mv_par02 == 1
					lImprime := .F.
					nCellTot-= 1
				EndIf
			Else
				If mv_par02 == 2
					lImprime := .F.
					nCellTot-= 1
				EndIf
			EndIf

			//+--------------------------------------------------------------+
			//| Impressao do Inventario                                      |
			//+--------------------------------------------------------------+
			If lImprime .Or. mv_par02 == 3

				For nX:=1 to Len(aRegInv)

					If nX == 1
						oSection1:Cell('B1_COD'	 	):Show()
						oSection1:Cell('B1_TIPO'	):Show()
						oSection1:Cell('B1_DESC'	):Show()
						oSection1:Cell('B1_GRUPO'	):Show()
						oSection1:Cell('B1_UM'		):Show()
						oSection1:Cell('B2_LOCAL'	):Show()
						oSection1:Cell('ZL_LOTECTL'	):Show()
						oSection1:Cell('ZL_NUMLOTE'	):Show()
						//oSection1:Cell('B7_LOCALIZ'	):Show()
						//oSection1:Cell('B7_NUMSERI'	):Show()
						oSection1:Cell('QUANTDATA'	):Hide()
						oSection1:Cell('DIFQUANT'	):Hide()
						oSection1:Cell('DIFVALOR'	):Hide()
						oSection1:Cell('QUANTDATA'	):SetValue(aSaldo[1])
						oSection1:Cell('DIFQUANT'	):SetValue(nTotal-aSaldo[1])
						oSection1:Cell('DIFVALOR'	):SetValue((nTotal-aSaldo[1])*aCM[1])
					Else
						oSection1:Cell('B1_COD'		):Hide()
						oSection1:Cell('B1_TIPO'  	):Hide()
						oSection1:Cell('B1_DESC'  	):Hide()
						oSection1:Cell('B1_GRUPO' 	):Hide()
						oSection1:Cell('B1_UM'    	):Hide()
						oSection1:Cell('B2_LOCAL' 	):Hide()
						oSection1:Cell('ZL_LOTECTL'	):Hide()
						oSection1:Cell('ZL_NUMLOTE'	):Hide()
						//oSection1:Cell('B7_LOCALIZ'	):Hide()
						//oSection1:Cell('B7_NUMSERI'	):Hide()
						oSection1:Cell('QUANTDATA'	):SetValue(0)
						oSection1:Cell('DIFQUANT'	):SetValue(0)
						oSection1:Cell('DIFVALOR'	):SetValue(0)
					EndIf

					If Len(aRegInv) == 1
						oSection1:Cell('QUANTDATA'	):Show()
						oSection1:Cell('DIFQUANT'	):Show()
						oSection1:Cell('DIFVALOR'	):Show()
					EndIf

					oSection1:Cell('B1_COD'		):SetValue(aRegInv[nX,01])
					oSection1:Cell('B1_DESC'	):SetValue(aRegInv[nX,02])
					oSection1:Cell('ZL_LOTECTL'	):SetValue(aRegInv[nX,03])
					oSection1:Cell('ZL_NUMLOTE'	):SetValue(aRegInv[nX,04])
					//oSection1:Cell('B7_LOCALIZ'	):SetValue(aRegInv[nX,05])
					//oSection1:Cell('B7_NUMSERI'	):SetValue(aRegInv[nX,06])
					oSection1:Cell('B1_TIPO'	):SetValue(aRegInv[nX,07])
					oSection1:Cell('B1_GRUPO'	):SetValue(aRegInv[nX,08])
					oSection1:Cell('B1_UM'		):SetValue(aRegInv[nX,09])
					oSection1:Cell('B2_LOCAL'	):SetValue(aRegInv[nX,10])
					oSection1:Cell('ZL_DOC'		):SetValue(aRegInv[nX,11])
					oSection1:Cell('ZL_QUANT'	):SetValue(aRegInv[nX,12])

					oSection1:PrintLine()

				Next nX

			EndIf
		Else
			dbSelectArea(cAliasSB2)
			(cAliasSB2)->(dbSkip())
			Loop
		EndIf

	EndDo

	oSection1:Finish()

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} AjustaSX1
Ajusta o grupo de perguntas.

@type function
@author Marcos V. Ferreira
@since 21/06/2006
@version P12.1.23

@param cPerg, Caractere, Grupo de perguntas.

@obs Projeto ELO

@history 28/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function AjustaSX1(cPerg)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//PutSX1(cPerg,"01","Documento?","Documento?","Documento?","mv_ch1","C",9,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{"Numero do documento a ser considerado na","filtragem do cadastro de saldos (SB2)."},{"Consider the product with zeroed balance","in filtering the balances file (SB2)."},{"Considera el producto con saldo cero en","el filtro del archivo de saldos (SB2)."})
	//PutSx1(cPerg,'02' ,'Listar Produtos ', 'Muestra Productos ', 'Show Products ',	'mv_ch2', 'N', 1, 0, 3, 'C', '', '', '', '', 'mv_par02','Com Diferenças',;
	//		'Com Diferencias','With Differences', '','Sem Diferenças','Sin Diferencias','Without Differences','Todos','Todos','All','','','','','','')

Return