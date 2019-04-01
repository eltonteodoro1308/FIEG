#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIESTR01
Listagem do pré - inventário.

@type function
@author Leonardo Soncin
@since 06/12/2011
@version P12.1.23

@obs Projeto ELO

@history 28/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIESTR01()

	Local oReport
	Private cAliasSB1 := "SB1"
	Private cAliasSB2 := "SB2"
	Private cAliasSZL := "SZL"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If FindFunction("TRepInUse") .And. TRepInUse()
		//+------------------------------------------------------------------------+
		//|Interface de impressao                                                  |
		//+------------------------------------------------------------------------+
		oReport := ReportDef()
		oReport:PrintDialog()
	Else
		Alert("Relatório não disponível para R3!")
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportDef
A função estática ReportDef deverá ser criada para todos os relatórios que poderão ser agendados pelo usuário.

@type function
@author Ricardo Berti
@since 20/06/2006
@version P12.1.23

@obs Projeto ELO

@history 28/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Objeto, Objeto do relatório.

/*/
/*/================================================================================================================================/*/

Static Function ReportDef()

	Local aOrdem	:= {}
	Local cPerg		:= "SIER01"
	Local oReport
	Local oCell
	Local oSection1
	Local oSection2

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aOrdem := {' Por Codigo         ',' Por Tipo           ',' Por Descricao    ',' Por Grupo        '}

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

	oReport := TReport():New("SIESTR01", 'Listagem para Inventario',cPerg, {|oReport| ReportPrint(oReport)},'Este programa emite um relatorio que facilita a digitacao'+" "+'das quantidades inventariadas.'+" "+"Ele e' emitido de acordo com os parametros informados.")
	oReport:SetLandScape()

	//+--------------------------------------------------------------+
	//| Ajusta Grupo de Perguntas                                    |
	//+--------------------------------------------------------------+
	AjustaSX1(cPerg)

	//+--------------------------------------------------------------+
	//| Variaveis utilizadas para parametros                         |
	//| mv_par01     // Documento                                    |
	//| mv_par02     // Imprime Lote/Sub-Lote e N£mero de S‚rie ?    |
	//| mv_par03     // Lista Prod. C/ Sld Zerado ? (Sim/Nao)        |
	//+--------------------------------------------------------------+
	Pergunte(cPerg,.F.)

	//+------------------------------------------------------------------------+
	//|Criacao da secao utilizada pelo relatorio                               |
	//|                                                                        |
	//|TRSection():New                                                         |
	//|ExpO1 : Objeto TReport que a secao pertence                             |
	//|ExpC2 : Descricao da seçao                                              |
	//|ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   |
	//|        sera considerada como principal para a seção.                   |
	//|ExpA4 : Array com as Ordens do relatório                                |
	//|ExpL5 : Carrega campos do SX3 como celulas                              |
	//|        Default : False                                                 |
	//|ExpL6 : Carrega ordens do Sindex                                        |
	//|        Default : False                                                 |
	//+------------------------------------------------------------------------+
	//+------------------------------------------------------------------------+
	//|Criacao das celulas da secao do relatorio                               |
	//|                                                                        |
	//|TRCell():New                                                            |
	//|ExpO1 : Objeto TSection que a secao pertence                            |
	//|ExpC2 : Nome da celula do relatório. O SX3 será consultado              |
	//|ExpC3 : Nome da tabela de referencia da celula                          |
	//|ExpC4 : Titulo da celula                                                |
	//|        Default : X3Titulo()                                            |
	//|ExpC5 : Picture                                                         |
	//|        Default : X3_PICTURE                                            |
	//|ExpC6 : Tamanho                                                         |
	//|        Default : X3_TAMANHO                                            |
	//|ExpL7 : Informe se o tamanho esta em pixel                              |
	//|        Default : False                                                 |
	//|ExpB8 : Bloco de código para impressao.                                 |
	//|        Default : ExpC2                                                 |
	//+------------------------------------------------------------------------+

	oSection1 := TRSection():New(oReport,"Produtos",{"SB1","SB2","SZL"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)

	TRCell():New(oSection1,"B1_COD","SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"B1_TIPO","SB1")
	TRCell():New(oSection1,"B1_GRUPO","SB1")
	TRCell():New(oSection1,"B1_DESC","SB1")
	TRCell():New(oSection1,"B1_UM","SB1")
	TRCell():New(oSection1,"B2_LOCAL","SB2")
	//TRCell():New(oSection1,"B2_LOCALIZ","SB2")

	/*
	oCell := TRCell():New(oSection1,"LOCALIZ","")
	oCell:GetFieldInfo("BF_LOCALIZ")
	*/

	oCell := TRCell():New(oSection1,"LOTECTL","")
	oCell:GetFieldInfo("BF_LOTECTL")
	oCell := TRCell():New(oSection1,"NUMLOTE","")
	oCell:GetFieldInfo("BF_NUMLOTE")

	/*
	If !__lPyme
	oCell := TRCell():New(oSection1,"NUMSERI","")
	oCell:GetFieldInfo("BF_NUMSERI")
	oCell:SetSize(14)
	EndIf
	*/

	TRCell():New(oSection1,"QTD1",""," _______1a."+CRLF+"Quantidade",,11,,{|| "[         ]" })
	TRCell():New(oSection1,"ETQ1","","Contagem"+CRLF+"Etiqueta",, 8,,{|| "[      ]" }) //###
	TRCell():New(oSection1,"QTD2",""," _______2a."+CRLF+"Quantidade",,11,,{|| "[         ]" }) //###
	TRCell():New(oSection1,"ETQ2","","Contagem"+CRLF+"Etiqueta",, 8,,{|| "[      ]" }) //###
	TRCell():New(oSection1,"QTD3",""," _______3a."+CRLF+"Quantidade",,11,,{|| "[         ]" }) //###
	TRCell():New(oSection1,"ETQ3","","Contagem"+CRLF+"Etiqueta",, 8,,{|| "[      ]" }) //"Contagem"###"Etiqueta"

	// Secao para a ordem por ENDERECO (muda o arq.base)
	/*
	If !__lPyme

	oSection2 := TRSection():New(oReport,"Saldos por Endereço",{"SBE","SB1","SB2"})

	oCell:=TRCell():New(oSection2,"B1COD","SB1",,,,,{|| (cAliasSB1)->B1_COD})
	oCell:GetFieldInfo("B1_COD")
	oCell:=TRCell():New(oSection2,"B1TIPO","SB1",,,,,{|| (cAliasSB1)->B1_TIPO})
	oCell:GetFieldInfo("B1_TIPO")
	oCell:=TRCell():New(oSection2,"B1GRUPO","SB1",,,,,{|| (cAliasSB1)->B1_GRUPO})
	oCell:GetFieldInfo("B1_GRUPO")
	oCell:=TRCell():New(oSection2,"B1DESC","SB1",,,,,{|| (cAliasSB1)->B1_DESC})
	oCell:GetFieldInfo("B1_DESC")
	oCell:=TRCell():New(oSection2,"B1UM","SB1",,,,,{|| (cAliasSB1)->B1_UM})
	oCell:GetFieldInfo("B1_UM")
	oCell:=TRCell():New(oSection2,"B2LOCAL","SB2",,,,,{|| (cAliasSB2)->B2_LOCAL})
	oCell:GetFieldInfo("B2_LOCAL")
	oCell:=TRCell():New(oSection2,"B2LOCALIZ","SB2",,,,,{|| (cAliasSB2)->B2_LOCALIZ})
	oCell:GetFieldInfo("B2_LOCALIZ")

	oCell := TRCell():New(oSection2,"LOCALIZ2","")
	oCell:GetFieldInfo("BF_LOCALIZ")
	oCell := TRCell():New(oSection2,"LOTECTL2","")
	oCell:GetFieldInfo("BF_LOTECTL")
	oCell := TRCell():New(oSection2,"NUMLOTE2","")
	oCell:GetFieldInfo("BF_NUMLOTE")
	oCell := TRCell():New(oSection2,"NUMSERI2","")
	oCell:GetFieldInfo("BF_NUMSERI")
	oCell:SetSize(14)
	TRCell():New(oSection2,"QTD1_2",""," _______1a."+CRLF+"Quantidade",,11,,{|| "[         ]" })
	TRCell():New(oSection2,"ETQ1_2","","Contagem"+CRLF+"Etiqueta",, 8,,{|| "[      ]" }) //###
	TRCell():New(oSection2,"QTD2_2",""," _______2a."+CRLF+"Quantidade",,11,,{|| "[         ]" }) //###"Quantidade"
	TRCell():New(oSection2,"ETQ2_2","","Contagem"+CRLF+"Etiqueta",, 8,,{|| "[      ]" }) //###"Etiqueta"
	TRCell():New(oSection2,"QTD3_2",""," _______3a."+CRLF+"Quantidade",,11,,{|| "[         ]" }) //###"Quantidade"
	TRCell():New(oSection2,"ETQ3_2","","Contagem"+CRLF+"Etiqueta",, 8,,{|| "[      ]" }) //"Contagem"###"Etiqueta"

	EndIf
	*/

Return(oReport)

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportPrint
A função estática ReportDef deverá ser criada para todos os relatórios que poderão ser agendados pelo usuário.

@type function
@author Ricardo Berti
@since 20/06/2006
@version P12.1.23

@param oReport, Objeto,  Objeto Report do Relatorio.

@obs Projeto ELO

@history 28/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ReportPrint(oReport)

	Local cAliasQRY := ""
	Local cAliasSBF := 'SBF'
	Local cCondicao1:= ""
	Local cLoteAnt	:= ""
	Local cOrdem    := ""
	Local cProduto  := ""
	Local cWhile	:= ""
	Local lImpLote	:= .T.//If(mv_par13==1,.T.,.F.)
	Local nOrdem    := oReport:Section(1):GetOrder()
	Local lFirst	:= .T.
	Local lRastro	:= .F.
	Local lRastroS	:= .F.
	Local lCLocal	:= .F.
	Local oSection1	:= oReport:Section(1)
	Local oSection2	:= oReport:Section(2)
	#IFNDEF TOP
	Local cCondicao := ""
	#ELSE
	Local cOrderBy  := ""
	Local cWhere    :=  ''
	#ENDIF

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If nOrdem == 1
		cOrdem := ' Por Codigo         '
	ElseIf nOrdem == 2
		cOrdem := ' Por Tipo           '
	ElseIf nOrdem == 3
		cOrdem := ' Por Descricao    '
	ElseIf nOrdem == 4
		cOrdem := ' Por Grupo        '
	EndIf

	//+--------------------------------------------------------------+
	//| Inicializa os Arquivos e Ordens a serem utilizados           |
	//+--------------------------------------------------------------+
	oSection1:SetHeaderPage()

	oReport:SetTitle(oReport:Title()+" ("+AllTrim(cOrdem)+")" )

	dbSelectArea('SB2')
	SB2->(dbSetOrder(1))

	dbSelectArea('SB8')
	SB2->(dbSetOrder(3))

	dbSelectArea('SBF')
	SB2->(dbSetOrder(2))

	dbSelectArea('SB1')
	SB2->(dbSetOrder(nOrdem))

	//+------------------------------------------------------------------------+
	//|Filtragem do relatorio                                                  |
	//+------------------------------------------------------------------------+
	//+------------------------------------------------------------------------+
	//|Transforma parametros Range em expressao SQL                            |
	//+------------------------------------------------------------------------+
	MakeSqlExpr(oReport:uParam)
	//+------------------------------------------------------------------------+
	//|Query do relatorio da secao 1                                           |
	//+------------------------------------------------------------------------+
	cAliasQRY := GetNextAlias()
	cAliasSB1 := cAliasQRY
	cAliasSB2 := cAliasQRY
	cAliasSZL := cAliasQRY

	cWhere := "%"

	//If mv_par14 == 2
	//cWhere += " AND B2_QATU <> 0 "
	//EndIf

	cWhere += "%"

	oSection1:BeginQuery()

	BeginSql Alias cAliasQRY
		SELECT B2_FILIAL, B2_COD, B1_FILIAL,ZL_COD, ZL_LOCAL ,B1_COD,B1_TIPO,B1_GRUPO,B1_DESC,B1_UM,B1_PERINV,B2_LOCALIZ,B2_DINVENT, B2_LOCAL, ZL_LOTECTL, ZL_NUMLOTE

		FROM %table:SB1% SB1, %table:SZL% SZL

		JOIN %table:SB2% SB2
		ON	B2_FILIAL  = %xFilial:SB2% AND
		B2_COD     = ZL_COD AND
		B2_LOCAL   = ZL_LOCAL AND
		SB2.%NotDel%

		WHERE	ZL_FILIAL  = %xFilial:SZL% AND
		ZL_DOC    = %Exp:mv_par01% AND
		B1_COD    = ZL_COD AND
		SB1.%NotDel% AND
		SZL.%NotDel%
		%Exp:cWhere%

		ORDER BY B2_COD, B2_LOCAL, B1_TIPO, ZL_LOTECTL //%Order:SB1%

	EndSql
	oSection1:EndQuery(/*Array com os parametros do tipo Range*/)

	//+------------------------------------------------------------------------+
	//|Metodo EndQuery ( Classe TRSection )                                    |
	//|                                                                        |
	//|Prepara o relatório para executar o Embedded SQL.                       |
	//|                                                                        |
	//|ExpA1 : Array com os parametros do tipo Range                           |
	//+------------------------------------------------------------------------+

	//oReport:Section(2):SetParentQuery()

	//+---------------------------------------+
	//|Inicio da impressao do relatorio		  |
	//+---------------------------------------+
	dbSelectArea(cAliasQRY)

	If ! lImpLote
		/*
		If !__lPyme
		oSection1:Cell("LOCALIZ"):Disable()
		EndIf
		*/

		oSection1:Cell("LOTECTL"):Disable()
		oSection1:Cell("NUMLOTE"):Disable()
		/*
		If !__lPyme
		oSection1:Cell("NUMSERI"):Disable()
		EndIf
		*/

	Else
		/*
		If !__lPyme
		oSection1:Cell("LOCALIZ"):Enable()
		EndIf
		*/
		oSection1:Cell("LOTECTL"):Enable()
		oSection1:Cell("NUMLOTE"):Enable()
		/*
		If !__lPyme
		oSection1:Cell("NUMSERI"):Enable()
		EndIf
		*/

	EndIf


	oReport:SetMeter(SB1->(LastRec()))
	cWhile := '(cAliasQRY)->(!Eof())'

	oSection1:Init()

	Do While !oReport:Cancel() .And. &(cWhile)
		If oReport:Cancel()
			Exit
		EndIf
		oReport:IncMeter()

		Do While  !oReport:Cancel() .And. !(cAliasSB2)->(Eof()) .And. ;
		(cAliasSB2)->B2_FILIAL + (cAliasSB2)->B2_COD == xFilial('SB2') + (cAliasQRY)->B1_COD

			/*
			If (!Empty((cAliasSB2)->B2_DINVENT) .And. ;
			((((cAliasSB2)->B2_DINVENT + (cAliasQRY)->B1_PERINV) < mv_par11) .Or. ;
			(((cAliasSB2)->B2_DINVENT + (cAliasQRY)->B1_PERINV) > mv_par12)))
			(cAliasSB2)->(dbSkip())
			Loop
			EndIf
			*/

			lRastro	  := Rastro((cAliasQRY)->B1_COD)
			lRastroS  := Rastro((cAliasQRY)->B1_COD, 'S')
			lCLocal	  := Localiza((cAliasQRY)->B1_COD)
			lFirst := .T.

			If lCLocal .And. lImpLote .And.;
			SBF->(dbSeek(xFilial('SBF') + (cAliasQRY)->B1_COD + (cAliasSB2)->B2_LOCAL, .F.))
				Do While !oReport:Cancel() .And. !SBF->(Eof()) .And. ;
				xFilial('SBF') + (cAliasQRY)->B1_COD + (cAliasSB2)->B2_LOCAL == SBF->BF_FILIAL + SBF->BF_PRODUTO + SBF->BF_LOCAL

					If lFirst
						oSection1:Cell("B1_COD"):Show()
						oSection1:Cell("B1_TIPO"):Show()
						oSection1:Cell("B1_GRUPO"):Show()
						oSection1:Cell("B1_DESC"):Show()
						oSection1:Cell("B1_UM"):Show()
						oSection1:Cell("B2_LOCAL"):Show()

						/*
						If !__lPyme
						oSection1:Cell("B2_LOCALIZ"):Show()
						EndIf
						*/
						lFirst := .F.
					Else
						oSection1:Cell("B1_COD"):Hide()
						oSection1:Cell("B1_TIPO"):Hide()
						oSection1:Cell("B1_GRUPO"):Hide()
						oSection1:Cell("B1_DESC"):Hide()
						oSection1:Cell("B1_UM"):Hide()
						oSection1:Cell("B2_LOCAL"):Hide()

						//If !__lPyme
						//oSection1:Cell("B2_LOCALIZ"):Hide()
						//EndIf
					EndIf
					//If !__lPyme
					//oSection1:Cell("LOCALIZ"):SetValue(SBF->BF_LOCALIZ)
					//EndIf
					oSection1:Cell("LOTECTL"):SetValue(SBF->BF_LOTECTL)
					oSection1:Cell("NUMLOTE"):SetValue(SBF->BF_NUMLOTE)
					//If !__lPyme
					//oSection1:Cell("NUMSERI"):SetValue(SBF->BF_NUMSERI)
					//EndIf
					oSection1:PrintLine()
					SBF->(dbSkip())
				EndDo

			ElseIf lRastro .And. lImpLote .And.;
			SB8->(dbSeek(xFilial('SB8') + (cAliasQRY)->B1_COD + (cAliasSB2)->B2_LOCAL, .F.))

				/*
				SB8->(dbSeek(xFilial('SB8') + (cAliasQRY)->B1_COD + (cAliasSB2)->B2_LOCAL, .F.))
				cLoteAnt   := ""
				cCondicao1 := 'SB8->B8_FILIAL + SB8->B8_PRODUTO + SB8->B8_LOCAL + SB8->B8_LOTECTL ' + If(lRastroS,'+ SB8->B8_NUMLOTE','')
				Do While !oReport:Cancel() .And. !SB8->(Eof()) .And. ;
				xFilial('SB8') + (cAliasQRY)->B1_COD + (cAliasSB2)->B2_LOCAL + SB8->B8_LOTECTL + If(lRastroS,SB8->B8_NUMLOTE,'') == &(cCondicao1)
				//+--------------------------------------------------------------+
				//| Verifica se o saldo esta' zerado (mv_par14 == 2 (Nao))       |
				//+--------------------------------------------------------------+
				//If mv_par14 == 2 .And. SB8->B8_SALDO == 0
				//SB8->(dbSkip())
				//Loop
				//EndIf
				If !(cLoteAnt==SB8->B8_LOTECTL) .Or. lRastroS
				If lFirst
				oSection1:Cell("B1_COD"):Show()
				oSection1:Cell("B1_TIPO"):Show()
				oSection1:Cell("B1_GRUPO"):Show()
				oSection1:Cell("B1_DESC"):Show()
				oSection1:Cell("B1_UM"):Show()
				oSection1:Cell("B2_LOCAL"):Show()
				If !__lPyme
				oSection1:Cell("B2_LOCALIZ"):Show()
				EndIf
				lFirst := .F.
				Else
				oSection1:Cell("B1_COD"):Hide()
				oSection1:Cell("B1_TIPO"):Hide()
				oSection1:Cell("B1_GRUPO"):Hide()
				oSection1:Cell("B1_DESC"):Hide()
				oSection1:Cell("B1_UM"):Hide()
				oSection1:Cell("B2_LOCAL"):Hide()
				If !__lPyme
				oSection1:Cell("B2_LOCALIZ"):Hide()
				EndIf
				EndIf
				If !__lPyme
				oSection1:Cell("LOCALIZ"):SetValue("")
				EndIf
				oSection1:Cell("LOTECTL"):SetValue(SB8->B8_LOTECTL)
				oSection1:Cell("NUMLOTE"):SetValue(If(lRastroS,SB8->B8_NUMLOTE,""))
				If !__lPyme
				oSection1:Cell("NUMSERI"):SetValue("")
				EndIf
				cLoteAnt := SB8->B8_LOTECTL

				oSection1:PrintLine()
				Endif
				SB8->(dbSkip())
				EndDo
				*/

				//If !__lPyme
				//oSection1:Cell("LOCALIZ"):SetValue("")
				//EndIf
				oSection1:Cell("LOTECTL"):SetValue((cAliasSZL)->ZL_LOTECTL)
				oSection1:Cell("NUMLOTE"):SetValue(If(lRastroS,(cAliasSZL)->ZL_NUMLOTE,""))
				//If !__lPyme
				//oSection1:Cell("NUMSERI"):SetValue("")
				//EndIf

				oSection1:PrintLine()
			Else
				oSection1:Cell("B1_COD"):Show()
				oSection1:Cell("B1_TIPO"):Show()
				oSection1:Cell("B1_GRUPO"):Show()
				oSection1:Cell("B1_DESC"):Show()
				oSection1:Cell("B1_UM"):Show()
				oSection1:Cell("B2_LOCAL"):Show()

				//If !__lPyme
				//oSection1:Cell("B2_LOCALIZ"):Show()
				//oSection1:Cell("LOCALIZ"):SetValue("")
				//EndIf
				oSection1:Cell("LOTECTL"):SetValue("")
				oSection1:Cell("NUMLOTE"):SetValue("")
				//If !__lPyme
				//oSection1:Cell("NUMSERI"):SetValue("")
				//EndIf

				oSection1:PrintLine()
			EndIf

			(cAliasSB2)->(dbSkip())
		EndDo

	EndDo
	oSection1:Finish()


	//+--------------------------------------------------------------+
	//| Devolve a condicao original do arquivo principal             |
	//+--------------------------------------------------------------+

	SB1->(dbSetOrder(1))
	SB2->(dbSetOrder(1))
	SB8->(dbSetOrder(1))
	SBF->(dbSetOrder(1))

Return NIL

/*/================================================================================================================================/*/
/*/{Protheus.doc} AjustaSX1
Cria perguntas no SX1 para o grupo.

@type function
@author Ricardo Berti
@since 20/06/2006
@version P12.1.23

@param cPerg, Caractere, Grupo do pergunte.

@obs Projeto ELO

@history 28/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function AjustaSX1(cPerg)

	//+---------------------------------------------------------------+
	//| Inclui pergunta no SX1                                        |
	//+---------------------------------------------------------------+
	//PutSX1(cPerg,"01","Documento?","Documento?","Documento?","mv_ch1","C",9,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{"Numero do documento a ser considerado na","filtragem do cadastro de saldos (SB2)."},{"Consider the product with zeroed balance","in filtering the balances file (SB2)."},{"Considera el producto con saldo cero en","el filtro del archivo de saldos (SB2)."})

	//PutSX1(cPerg,"14","Lista Prod. Com Saldo Zerado ?","Lista Prod. Con Saldo Nulo ?  ","Cons. Prod. With Stock Zero ? ","mv_che","N",1,0,0,"C","","","","","mv_par14","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",{"Considera o produto com saldo zerado na","filtragem do cadastro de saldos (SB2)."},{"Consider the product with zeroed balance","in filtering the balances file (SB2)."},{"Considera el producto con saldo cero en","el filtro del archivo de saldos (SB2)."})

Return Nil
