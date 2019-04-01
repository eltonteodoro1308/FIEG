#Include "Protheus.ch"
#Include "report.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICTBR50
Impressão da contabilizacao dos Restos a Pagar de Pedidos e Contratos.

@type function
@author Joao Carlos A. Neto
@since 02/12/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICTBR50()

	Local oReport	:= Nil
	Local cPerg		:= "SICTBR50"
	Local aPerg		:= {}
	Local aStru		:= {{"C7_NUM", "C", 06, 0}}
	Local cArqTrb	:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If TRepInUse()	// Verifica se o TReport está ativado

		Aadd(aPerg, {cPerg,"01","Pedido de?","","","MV_CH1","C",TamSx3("C7_NUM")[1],0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SC7","S","","","",""})
		Aadd(aPerg, {cPerg,"02","Pedido até?","","","MV_CH2","C",TamSx3("C7_NUM")[1],0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SC7","S","","","",""})
		Aadd(aPerg, {cPerg,"03","Fornecedor de?","","","MV_CH3","C",TamSx3("A2_COD")[1],0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA2","S","","","",""})
		Aadd(aPerg, {cPerg,"04","Fornecedor até?","","","MV_CH4","C",TamSx3("A2_COD")[1],0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SA2","S","","","",""})
		Aadd(aPerg, {cPerg,"05","Loja de?","","","MV_CH5","C",TamSx3("A2_LOJA")[1],0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
		Aadd(aPerg, {cPerg,"06","Loja ate?","","","MV_CH6","C",TamSx3("A2_LOJA")[1],0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
		Aadd(aPerg, {cPerg,"07","Emissão de?","","","MV_CH7","D",TamSx3("C7_EMISSAO")[1],0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
		Aadd(aPerg, {cPerg,"08","Emissão até?","","","MV_CH8","D",TamSx3("C7_EMISSAO")[1],0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
		Aadd(aPerg, {cPerg,"09","Filial de?","","","MV_CH9","C",TamSx3("C7_FILIAL")[1],0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SM0_01","S","","","",""})
		Aadd(aPerg, {cPerg,"10","Filial até?","","","MV_CHA","C",TamSx3("C7_FILIAL")[1],0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","SM0_01","S","","","",""})
		Aadd(aPerg, {cPerg,"11","Centro Custo de?","","","MV_CHB","C",TamSx3("CTT_CUSTO")[1],0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","","","",""})
		Aadd(aPerg, {cPerg,"12","Centro Custo até?","","","MV_CHC","C",TamSx3("CTT_CUSTO")[1],0,0,"G","","MV_PAR12","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","","","",""})
		Aadd(aPerg, {cPerg,"13","Situação","","","MV_CHD","N",1,0,0,"C","","MV_PAR13","Pendentes","Pendentes","Pendentes","","","Contabilizados","Contabilizados","Contabilizados","","","Todos","Todos","Todos","","","","","","","","","","","","","","","","",""})

		ChkPerg(aPerg)

		IF Pergunte(cPerg, .T.)

			IF Select("TBC7") > 0
				TBC7->(DbCloseArea())
			ENDIF

			cArqTrb	:= CriaTrab(aStru, .t.)
			DbUseArea(.T.,, cArqTrb, "TBC7", .T., .T.)

			oReport := ReportDef()

			oReport:PrintDialog()

			IF Select("TBC7") > 0
				TBC7->(DbCloseArea())
			ENDIF

			FErase(cArqTrb + GetDbExtension())

		ENDIF

	Else

		Alert("O relatório não será emitido: o sistema não está parametrizado para emissão deste tipo de relatório - TREPORT. Contacte o administrador do sistema")

	EndIf

Return(Nil)

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportDef
Definição da estrutura do relatório.

@type function
@author João Carlos S Hozaki
@since 22/10/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Objeto, Objeto que representa o relatório.

/*/
/*/================================================================================================================================/*/

Static Function ReportDef()

	Local oReport
	Local oSection1
	Local oSection2
	Local oSection3

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Cria o objeto de impressão
	oReport:= TReport():New("SICTBR50", " Posição de Restos a Pagar dos Pedidos",, {|oReport| PrintReport(oReport)}, ".",.t.)

	// Cria a sessão 1 para imprimir
	oSection1 := TRSection():New(oReport, " Filial ", {"TBC7"})
	oSection1:SetLineStyle() //Define a impressao da secao em linha
	oSection1:SetTotalInLine(.F.)

	TRCell():New(oSection1, "C7_FILIAL"		, "TBC7",GetSx3Cache("C7_FILIAL","X3_TITULO")	, GetSx3Cache("C7_FILIAL","X3_PICTURE")		,TamSx3("C7_FILIAL")[1]		,/*lPixel*/)

	oSection1:SetLineBreak(.f.)

	// Cria a sessão 2 para impressão dos valores
	oSection2 := TRSection():New(oSection1, " ", {"TBC7"})
	oSection2:SetTotalInLine(.F.)
	oSection2:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção
	oSection2:SetPageBreak(.t.)

	TRCell():New(oSection2, "C7_NUM"		, "TBC7",GetSx3Cache("C7_NUM","X3_TITULO")		, GetSx3Cache("C7_NUM","X3_PICTURE")		,TamSx3("C7_NUM")[1]		,/*lPixel*/, {|| nEntid02 } )
	TRCell():New(oSection2, "C7_EMISSAO"	, "TBC7",GetSx3Cache("C7_EMISSAO","X3_TITULO")	, GetSx3Cache("C7_EMISSAO","X3_PICTURE")	,TamSx3("C7_EMISSAO")[1]	,/*lPixel*/, {|| nEntid03 } )
	TRCell():New(oSection2, "C7_ITEM"		, "TBC7",GetSx3Cache("C7_ITEM","X3_TITULO")		, GetSx3Cache("C7_ITEM","X3_PICTURE")		,TamSx3("C7_ITEM")[1]		,/*lPixel*/, {|| nEntid04 } )
	TRCell():New(oSection2, "C7_PRODUTO"	, "TBC7",GetSx3Cache("C7_PRODUTO","X3_TITULO")	, GetSx3Cache("C7_PRODUTO","X3_PICTURE")	,TamSx3("C7_PRODUTO")[1]	,/*lPixel*/, {|| nEntid05 } )
	TRCell():New(oSection2, "C7_QUANT"		, "TBC7",GetSx3Cache("C7_QUANT","X3_TITULO")	, GetSx3Cache("C7_QUANT","X3_PICTURE")		,TamSx3("C7_QUANT")[1]		,/*lPixel*/, {|| nEntid06 } )
	TRCell():New(oSection2, "C7_PRECO"		, "TBC7",GetSx3Cache("C7_PRECO","X3_TITULO")	, GetSx3Cache("C7_PRECO","X3_PICTURE")		,TamSx3("C7_PRECO")[1]		,/*lPixel*/, {|| nEntid07 } )
	TRCell():New(oSection2, "C7_TOTAL"		, "TBC7",GetSx3Cache("C7_TOTAL","X3_TITULO")	, GetSx3Cache("C7_TOTAL","X3_PICTURE")		,TamSx3("C7_TOTAL")[1]		,/*lPixel*/, {|| nEntid08 } )
	TRCell():New(oSection2, "C7_QUJE"		, "TBC7",GetSx3Cache("C7_QUJE","X3_TITULO")		, GetSx3Cache("C7_QUJE","X3_PICTURE")		,TamSx3("C7_QUJE")[1]		,/*lPixel*/, {|| nEntid09 } )
	TRCell():New(oSection2, "SALDO"			, "TBC7","Valor Contabil"                  		, GetSx3Cache("C7_TOTAL","X3_PICTURE")		,TamSx3("C7_TOTAL")[1]		,/*lPixel*/, {|| nEntid10 } )
	TRCell():New(oSection2, "C7_FORNECE"	, "TBC7",GetSx3Cache("C7_FORNECE","X3_TITULO")	, GetSx3Cache("C7_FORNECE","X3_PICTURE")	,TamSx3("C7_FORNECE")[1]	,/*lPixel*/, {|| nEntid11 } )
	TRCell():New(oSection2, "C7_LOJA"		, "TBC7",GetSx3Cache("C7_LOJA","X3_TITULO")		, GetSx3Cache("C7_LOJA","X3_PICTURE")		,TamSx3("C7_LOJA")[1] 		,/*lPixel*/, {|| nEntid12 } )
	TRCell():New(oSection2, "A2_NREDUZ"		, "TBC7",GetSx3Cache("A2_NREDUZ","X3_TITULO")	, GetSx3Cache("A2_NREDUZ","X3_PICTURE")		,TamSx3("A2_NREDUZ")[1] 	,/*lPixel*/, {|| nEntid13 } )
	TRCell():New(oSection2, "C7_CONTA"		, "TBC7",GetSx3Cache("C7_CONTA","X3_TITULO")	, GetSx3Cache("C7_CONTA","X3_PICTURE")		,TamSx3("C7_CONTA")[1]		,/*lPixel*/, {|| nEntid14 } )
	TRCell():New(oSection2, "C7_CC"			, "TBC7",GetSx3Cache("C7_CC","X3_TITULO")		, GetSx3Cache("C7_CC","X3_PICTURE")			,TamSx3("C7_CC")[1]			,/*lPixel*/, {|| nEntid15 } )
	TRCell():New(oSection2, "C7_ITEMCTA"	, "TBC7",GetSx3Cache("C7_ITEMCTA","X3_TITULO")	, GetSx3Cache("C7_ITEMCTA","X3_PICTURE")	,TamSx3("C7_ITEMCTA")[1]	,/*lPixel*/, {|| nEntid16 } )
	TRCell():New(oSection2, "C7_DTLANC"		, "TBC7",GetSx3Cache("C7_DTLANC","X3_TITULO")	, GetSx3Cache("C7_DTLANC","X3_PICTURE")		,TamSx3("C7_DTLANC")[1]		,/*lPixel*/, {|| nEntid17 } )

	oSection2:SetLineBreak(.f.)

Return oReport

/*/================================================================================================================================/*/
/*/{Protheus.doc} PrintReport
Processamento da impressão.

@type function
@author João Carlos S Hozaki
@since 22/10/2013
@version P12.1.23

@param oReport, Objeto, objeto para execução do relatório.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function PrintReport(oReport)

	Local oSection1	:= oReport:Section(1)
	Local oSection2	:= oReport:Section(1):Section(1)
	Local cQuery	:= ""
	Local i			:= 0
	//Local cQuery	:= ""
	Local _cFilial	:= ""
	Local nTotCont  := 0
	Local nTotGer   := 0
	Local nTotGrp   := 0
	Local nTotFil   := 0

	Local aValores	:= {}
	Private cNomeFil      := ""
	Private nEntid01	:= ""
	Private nEntid02	:= ""
	Private nEntid03	:= ""
	Private nEntid04	:= ""
	Private nEntid05	:= ""
	Private nEntid06	:= ""
	Private nEntid07	:= ""
	Private nEntid08	:= 0
	Private nEntid09	:= 0
	Private nEntid10	:= ""
	Private nEntid11	:= ""
	Private nEntid12	:= ""
	Private nEntid13	:= ""
	Private nEntid14	:= ""
	Private nEntid15	:= ""
	Private nEntid16	:= ""
	Private nEntid17	:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oSection1:Init()

	IF Select("TBC7") > 0
		TBC7->(DbCloseArea())
	ENDIF

	// Seleciona os dados referentes aos fornecedores, produto, pedido de compra e Solicitação de Compra
	cQuery := " SELECT  "
	cQuery += "   C7_FILIAL, C7_ITEM, C7_NUM, C7_EMISSAO, C7_PRODUTO, Sum(C7_QUANT) C7_QUANT, "
	cQuery += "   Sum(C7_PRECO) C7_PRECO, Sum(C7_TOTAL) C7_TOTAL, Sum(C7_QUJE) C7_QUJE, C7_FORNECE, C7_LOJA, C7_CONTA, C7_CC, "
	cQuery += "   C7_ITEMCTA, C7_DTLANC, A2_COD, A2_NREDUZ, B1_COD, Sum(C7_PRECO*(C7_QUANT-C7_QUJE)) SALDO "
	cQuery += " FROM "+RetSqlName("SC7")+" SC7 "
	cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" SA2 "
	cQuery += " 	ON SA2.D_E_L_E_T_ = ' ' AND C7_FORNECE = A2_COD "
	cQuery += "     AND C7_LOJA = A2_LOJA "
	cQuery += "     AND A2_FILIAL = '" + xFilial("SA2")+"'"
	cQuery += "  JOIN "+RetSqlName("SB1")+" SB1 "
	cQuery += " 	ON SB1.D_E_L_E_T_ = ' ' AND C7_PRODUTO = B1_COD "
	cQuery += "   AND B1_FILIAL = '" + xFilial("SB1")+"'"
	cQuery += " WHERE SC7.D_E_L_E_T_ = ' ' "
	//cQuery += "   AND C7_FILIAL = '" + xFilial("SC7")+"'"
	cQuery += "   AND C7_FORNECE = A2_COD "
	cQuery += "   AND C7_LOJA = A2_LOJA "
	cQuery += "   AND C7_PRODUTO = B1_COD "
	cQuery += "   AND C7_RESIDUO <> 'S' "
	cQuery += "   AND Substring(C7_EMISSAO,1,4) = '"+Substring(Dtos(dDataBase),1,4)+"' "
	cQuery += "   AND C7_NUM BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
	cQuery += "   AND C7_FORNECE BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
	cQuery += "   AND C7_LOJA BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
	cQuery += "   AND C7_EMISSAO BETWEEN '"+Dtos(mv_par07)+"' AND '"+Dtos(mv_par08)+"' "
	cQuery += "   AND C7_FILIAL BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' "
	cQuery += "   AND C7_CC BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' "
	If Mv_par13 == 1
		cQuery += "   AND C7_XRESTPG = '1' "
		cQuery += "   AND C7_QUANT > C7_QUJE "
	Elseif Mv_par13 == 2
		cQuery += "   AND C7_XRESTPG = '3' "
		cQuery += "   AND C7_DTLANC <> ' ' "
	Else
		cQuery += " AND C7_XRESTPG IN ('3','1') "
	Endif
	cQuery += " GROUP BY C7_FILIAL, C7_ITEM, C7_NUM, C7_EMISSAO, C7_PRODUTO, C7_FORNECE, C7_LOJA, C7_CONTA, C7_CC, C7_ITEMCTA, C7_DTLANC, A2_COD, A2_NREDUZ, B1_COD "
	cQuery += " ORDER BY C7_FILIAL, C7_EMISSAO, C7_NUM "

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TBC7", .T., .T.)

	TcSetField("TBC7","C7_DTLANC"	,"D", 10					, 0 )
	TcSetField("TBC7","C7_EMISSAO"	,"D", 10					, 0 )

	TcSetField("TBC7","C7_QUANT"	,"N", TamSx3("C7_QUANT")[1], TamSx3("C7_QUANT")[2] )
	TcSetField("TBC7","C7_TOTAL"	,"N", TamSx3("C7_TOTAL")[1], TamSx3("C7_TOTAL")[2] )
	TcSetField("TBC7","C7_PRECO"	,"N", TamSx3("C7_PRECO")[1], TamSx3("C7_PRECO")[2] )
	TcSetField("TBC7","C7_QUJE"		,"N", TamSx3("C7_QUJE")[1] , TamSx3("C7_QUJE")[2] )

	Aadd(aValores, &("{|| nEntid02 := TBC7->C7_NUM }"))
	Aadd(aValores, &("{|| nEntid03 := TBC7->C7_EMISSAO }"))
	Aadd(aValores, &("{|| nEntid04 := TBC7->C7_ITEM }"))
	Aadd(aValores, &("{|| nEntid05 := TBC7->C7_PRODUTO }"))
	Aadd(aValores, &("{|| nEntid06 := TBC7->C7_QUANT }"))
	Aadd(aValores, &("{|| nEntid07 := TBC7->C7_PRECO }"))
	Aadd(aValores, &("{|| nEntid08 := TBC7->C7_TOTAL }"))
	Aadd(aValores, &("{|| nEntid09 := TBC7->C7_QUJE }"))
	Aadd(aValores, &("{|| nEntid10 := TBC7->SALDO }"))
	Aadd(aValores, &("{|| nEntid11 := TBC7->C7_FORNECE }"))
	Aadd(aValores, &("{|| nEntid12 := TBC7->C7_LOJA }"))
	Aadd(aValores, &("{|| nEntid13 := TBC7->A2_NREDUZ }"))
	Aadd(aValores, &("{|| nEntid14 := TBC7->C7_CONTA }"))
	Aadd(aValores, &("{|| nEntid15 := TBC7->C7_CC }"))
	Aadd(aValores, &("{|| nEntid16 := TBC7->C7_ITEMCTA }"))
	Aadd(aValores, &("{|| nEntid17 := TBC7->C7_DTLANC }"))

	oSection1:Init()
	oSection2:Init()

	cRecSM0 := SM0->(Recno())
	DbSelectArea("TBC7")
	TBC7->(DbGoTop())
	WHILE !TBC7->(Eof())

		oSection2:Init()


		IF _cFilial # TBC7->C7_FILIAL
			_cFilial := TBC7->C7_FILIAL
			cNomeFil :=  Posicione("SM0",1,cEmpAnt+TBC7->C7_FILIAL,"M0_FILIAL")
			TBC7->C7_FILIAL += "  -  " + cNomeFil
			oSection1:PrintLine()
			TBC7->C7_FILIAL := _cFilial
		ENDIF

		AEval(aValores, {|z| Eval(z)})

		nEntid00 := TBC7->SALDO

		//Valor total contabilizado
		If !Empty(nEntid17)
			nTotCont += nEntid10
		Endif
		nTotFil  += nEntid08

		oSection2:PrintLine()

		TBC7->(DbSkip())

		IF _cFilial # TBC7->C7_FILIAL
			oReport:PrintText( " " )
			oReport:PrintText( "Valor Total Contabilizado da Filial: " + _cFilial + "    "+Transform(nTotCont,"@E 999,999,999.99") )
			oReport:PrintText( "Valor Total da Filial:               " + _cFilial + "    "+Transform(nTotFil,"@E 999,999,999.99") )
			oReport:PrintText( " " )

			nTotGer += nTotCont
			nTotGrp += nTotFil
			nTotCont := 0
			nTotFil := 0
		ENDIF

	ENDDO

	oReport:PrintText( " " )
	oReport:PrintText( "Total Geral Contabilizado de todas as Filais: " + Transform(nTotGer,"@E 999,999,999.99") )
	oReport:PrintText( "Total Geral de todas as Filais: " + Transform(nTotGrp,"@E 999,999,999.99") )
	oReport:PrintText( " " )

	nTotGer  := 0
	nTotCont := 0
	nTotGrp  := 0
	nTotFil  := 0

	TBC7->(DbCloseArea())
	oSection1:Finish()
	oSection2:Finish()

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ChkPerg
Descrição detalhada da função.

@type function
@author João Carlos S Hozaki
@since 22/10/2013
@version P12.1.23

@param _aPerg, Array, Array com os dados das perguntas

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ChkPerg(_aPerg)

	Local _n		:= 0
	Local _aCampos	:= {}
	Local _nLimite	:= 0
	Local _x		:= 0
	Local _nTamPerg	:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DbSelectArea("SX1")
	SX1->(DbSetOrder(1))

	//+-----------------------------------------------------------+
	//| Armazena a estrutura do arquivo de perguntas SX1 no array |
	//+-----------------------------------------------------------+
	_aCampos	:= DbStruct()
	_nTamPerg	:= Len(SX1->X1_GRUPO)

	//+------------------------------------------------------------+
	//| Estabelece o limite para a gravação do registro pelo menor |
	//| valor obtido entre a comparação da estrutura do arquivo e  |
	//| a dimensão da linha do array enviado como parâmetro        |
	//+------------------------------------------------------------+
	_nLimite := Iif(Len(_aPerg[1]) < Len(_aCampos), Len(_aPerg[1]), Len(_aCampos))

	FOR _n:=1 TO Len(_aPerg)
		//+-----------------------------------------------------------+
		//| Verifica se o registro da pergunta já não está cadastrado |
		//+-----------------------------------------------------------+

		SX1->(DbSeek(Padr(_aPerg[_n, 1], _nTamPerg) + _aPerg[_n, 2], .f.))
		IF !Found() .OR. Alltrim(_aPerg[_n, 3]) # Alltrim(SX1->X1_PERGUNT) .OR. Alltrim(_aPerg[_n, 7]) # Alltrim(SX1->X1_TIPO) .OR. ;
		_aPerg[_n, 8] # SX1->X1_TAMANHO .OR. _aPerg[_n, 9] # SX1->X1_DECIMAL .OR. Alltrim(_aPerg[_n, 11]) # Alltrim(SX1->X1_GSC) .OR. ;
		Alltrim(_aPerg[_n, 12]) # Alltrim(SX1->X1_VALID) .OR. Alltrim(_aPerg[_n, 14]) # Alltrim(SX1->X1_DEF01) .OR. ;
		Alltrim(_aPerg[_n, 19]) # Alltrim(SX1->X1_DEF02) .OR. Alltrim(_aPerg[_n, 24]) # Alltrim(SX1->X1_DEF03) .OR. ;
		Alltrim(_aPerg[_n, 29]) # Alltrim(SX1->X1_DEF04) .OR. Alltrim(_aPerg[_n, 34]) # Alltrim(SX1->X1_DEF05) .OR. ;
		Alltrim(_aPerg[_n, 38]) # Alltrim(SX1->X1_F3)

			//+-----------------------------------------------------------+
			//| Caso não esteja cadastrado, cria registro novo e grava os |
			//| campos com base nos dados do array passado como parâmetro |
			//+-----------------------------------------------------------+
			RecLock("SX1", !Found())
			FOR _x:=1 TO _nLimite
				FieldPut(FieldPos(_aCampos[_x, 1]), _aPerg[_n, _x])
			NEXT
			SX1->(MsUnlock())
		ENDIF
	NEXT

Return(Nil)