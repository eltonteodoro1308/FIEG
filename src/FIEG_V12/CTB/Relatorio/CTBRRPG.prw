#Include "Protheus.ch"

#DEFINE TITULO_RELAT	OemToAnsi("RELATÓRIO RAZONETE RESTOS A PAGAR")
#DEFINE PERGUNTA_SX1	"CTBRRPG"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CTBRRPG
Relatório Resto a Pagar.

@type function
@author Edmar Tinti
@since 15/12/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CTBRRPG()
	Private oRep, oSec, oTit
	Private _aParam 	:= Array(10)
	Private DATA_DE		:= 01
	Private DATA_ATE	:= 02
	Private FORN_DE		:= 03
	Private FORN_ATE 	:= 04
	Private CUSTO_DE	:= 05
	Private CUSTO_ATE	:= 06
	Private FILIAL_DE	:= 07
	Private FILIAL_ATE	:= 08
	Private SALDO_ZERO	:= 09
	Private SALTA_PAG	:= 10
	Private cSA2Filter	:= ""
	Private cSC7Filter	:= ""
	Private cSD1Filter	:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DbSelectArea("CTT")
	CTT->(DbSetOrder(1))
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	If FindFunction("TRepInUse")
		If fDefPergs(PERGUNTA_SX1)
			oRep:=ReportDef()
			oRep:PrintDialog()
		EndIf
	Endif
Return(Nil)


/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportDef
Definição do Relatório - TReport.

@type function
@author Edmar Tinti
@since 15/12/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Objeto, Objeto que representa o reltório.

/*/
/*/================================================================================================================================/*/

Static Function ReportDef()
	Local oRep := Nil

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_aParam[DATA_DE		]:=	MV_PAR01
	_aParam[DATA_ATE	]:=	MV_PAR02
	_aParam[FORN_DE		]:=	MV_PAR03
	_aParam[FORN_ATE 	]:=	MV_PAR04
	_aParam[CUSTO_DE	]:=	MV_PAR05
	_aParam[CUSTO_ATE 	]:=	MV_PAR06
	_aParam[FILIAL_DE 	]:=	MV_PAR07
	_aParam[FILIAL_ATE	]:=	MV_PAR08
	_aParam[SALDO_ZERO	]:=	MV_PAR09
	_aParam[SALTA_PAG 	]:=	MV_PAR10

	oRep:=TReport():New("CTBRRPG",TITULO_RELAT,PERGUNTA_SX1,{|oRep| PrintReport()},"Imprime Razonte Restos a Pagar, Conforme Parâmetros")
	oRep:oPage:SetPaperSize(9)  // Pagina A4
	oRep:HideFooter()         	 // Não Imprime Rodapé Pagina
	oRep:HideParamPage() 		 // Não Imprime Pagina de Parametros
	oRep:nFontBody := 8			 // Tamanho do Fonte
	oRep:nLineHeight := 40      // Altura das Linhas
	oRep:SetMsgPrint("Consultando Bando de Dados...")
	oSec:=TRSection():New(oRep,"SECAO", {"SA2","SC7","SD1"}, {"PADRÃO"})
	oSec:SetLinesBefore(0)
	oSec:SetHeaderPage(.T.)
	oSec:SetHeaderSection(.T.)
	TRCell():New( oSec, "FILIAL",,		"Emp.Fil.",			"",08,Nil,Nil,"LEFT",	.F.,"LEFT")
	TRCell():New( oSec, "EMISSAO",,		"Emissão",			"",10,Nil,Nil,"LEFT",	.F.,"LEFT")
	TRCell():New( oSec, "LANCAMENTO",,	"Lançamento",		"",10,Nil,Nil,"LEFT",	.F.,"LEFT")
	TRCell():New( oSec, "TIPO",,		"TD",				"",02,Nil,Nil,"LEFT",	.F.,"LEFT")
	TRCell():New( oSec, "NUMERO",,		"Número",			"",18,Nil,Nil,"LEFT",	.F.,"LEFT")
	TRCell():New( oSec, "SALDOANT",,	"Saldo Anterior",	"",18,Nil,Nil,"RIGHT",	.F.,"RIGHT")
	TRCell():New( oSec, "DEBITO",,		"Débito",			"",16,Nil,Nil,"RIGHT",	.F.,"RIGHT")
	TRCell():New( oSec, "CREDITO",,		"Crédito",			"",16,Nil,Nil,"RIGHT",	.F.,"RIGHT")
	TRCell():New( oSec, "SALDOATU",,	"Saldo Atual",		"",18,Nil,Nil,"RIGHT",	.F.,"RIGHT")

Return(oRep)


/*/================================================================================================================================/*/
/*/{Protheus.doc} PrintReport
Imprime o relatório.

@type function
@author Edmar Tinti
@since 15/12/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function PrintReport()
	Local oTit, cTmp, cFor, cCus, lPag, cCGC, nX
	Local aTTL := {0,0,0}
	Local aTL1 := {0,0,0}
	Local aTL2 := {0,0,0}
	Local aTL3 := {0,0,0}
	Local cFiltro := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oTit:=TRSection():New(oRep,"")
	oTit:SetHeaderSection(.F.)
	TRCell():New(oTit,"","","",,200,.T.,,"LEFT",,"LEFT",,,,,,.T.)

	//Ajusta Cabeçalho Personalizado
	oRep:SetCustomText({|| fSetCab()})

	//---------------
	//-- Filter User
	//---------------
	For nX := 1 To Len(oSec:aUserFilter)
		If .Not. Empty(oSec:aUserFilter[nX,3])
			If (AllTrim(oSec:aUserFilter[nX,1]) == "SA2")
				cSA2Filter += IIF(EMPTY(cSA2Filter),""," AND ") + "SA2."+AllTrim(oSec:aUserFilter[nX,3])
			ElseIf (AllTrim(oSec:aUserFilter[nX,1]) == "SC7")
				cSC7Filter += IIF(EMPTY(cSC7Filter),""," AND ") + "SC7."+AllTrim(oSec:aUserFilter[nX,3])
			ElseIf (AllTrim(oSec:aUserFilter[nX,1]) == "SD1")
				cSD1Filter += IIF(EMPTY(cSC7Filter),""," AND ") + "SD1."+AllTrim(oSec:aUserFilter[nX,3])
			EndIf
		Endif
	Next

	//Imprime
	oSec:Init()
	oTit:Init()
	oRep:StartPage()
	oRep:SetMeter(0)
	oRep:IncMeter()
	cTmp := fQuery(cFiltro)

	DbSelectArea("TMP")
	oRep:SetMsgPrint("Imprimindo...")
	oRep:SetMeter(LastRec())

	TMP->(DbGoTop())
	cFor := "*"
	cCus := "*"

	While TMP->(! Eof()) .And. ! oRep:Cancel()
		oRep:IncMeter()
		//Titulos
		If (cCus != TMP->CUSTO .Or. cFor != TMP->(FORNECE+LOJA))
			oRep:oFontBody:Bold := .T.

			If (cCus != TMP->CUSTO)
				cCus := TMP->CUSTO
				CTT->(DbSeek(PadR(Left(TMP->FILIAL,4),Len(FWxFilial("CTT")))+cCus))
				oTit:Cell(""):SetBlock( {|| "CC: "+Trim(cCus)+" - "+CTT->CTT_DESC01 })
				oTit:PrintLine()

				cFor := TMP->(FORNECE+LOJA)
				SA2->(DbSeek(FWxFilial("SA2")+cFor))
				cCGC := AllTrim(SA2->A2_CGC)
				cCGC := iif(Len(cCGC)==11, "CPF: "+Transform(cCGC,"@R 999.999.999-68"), "CGC/MF: "+Transform(cCGC,"@R 99.999.999/9999-99"))
				oTit:Cell(""):SetBlock( {|| "Fornecedor: "+Trim(TMP->FORNECE+" "+TMP->LOJA)+" - "+Trim(SA2->A2_NOME)+" - "+cCGC })
				oTit:PrintLine()

			EndIf

			If (cFor != TMP->(FORNECE+LOJA) .AND. cCus == TMP->CUSTO)

				cFor := TMP->(FORNECE+LOJA)
				SA2->(DbSeek(FWxFilial("SA2")+cFor))
				cCGC := AllTrim(SA2->A2_CGC)
				cCGC := iif(Len(cCGC)==11, "CPF: "+Transform(cCGC,"@R 999.999.999-68"), "CGC/MF: "+Transform(cCGC,"@R 99.999.999/9999-99"))
				oTit:Cell(""):SetBlock( {|| "Fornecedor: "+Trim(TMP->FORNECE+" "+TMP->LOJA)+" - "+Trim(SA2->A2_NOME)+" - "+cCGC })
				oTit:PrintLine()
			EndIf

			oRep:ThinLine()
		Endif
		//Linhas
		oRep:oFontBody:Bold := .F.
		oSec:Cell("FILIAL"):SetBlock( {|| TMP->FILIAL })
		oSec:Cell("EMISSAO"):SetBlock( {|| TMP->EMISSAO })
		oSec:Cell("LANCAMENTO"):SetBlock( {|| TMP->DATAMOV })
		oSec:Cell("TIPO"):SetBlock( {|| TMP->TIPO })
		oSec:Cell("SALDOANT"):SetBlock( {|| ValorCTB(TMP->SALDOANT,.T.,.F.) })

		//Totais Saldo Anterior
		aTL1[1] += TMP->SALDOANT
		aTL2[1] += TMP->SALDOANT
		aTL3[1] += TMP->SALDOANT

		If TMP->TIPO == "PC"
			oSec:Cell("NUMERO"):SetBlock( {|| TMP->PEDIDO })
		Else
			oSec:Cell("NUMERO"):SetBlock( {|| Trim(TMP->DOC)+" "+TMP->SERIE})
		Endif
		oSec:Cell("DEBITO"):SetBlock( {|| ValorCTB(TMP->DEBITO,.F.,.T.)})
		oSec:Cell("CREDITO"):SetBlock( {|| ValorCTB(TMP->CREDITO,.F.,.T.) })
		oSec:Cell("SALDOATU"):SetBlock( {|| ValorCTB(TMP->SALDOATU,.T.,.T.) })
		oSec:PrintLine()

		//Totais Debito e Credito
		aTL1[2] += TMP->DEBITO
		aTL1[3] += TMP->CREDITO
		aTL2[2] += TMP->DEBITO
		aTL2[3] += TMP->CREDITO
		aTL3[2] += TMP->DEBITO
		aTL3[3] += TMP->CREDITO

		DbSkip()
		//Ajusta Totais a cada troca de CC e/ou Fornecdor
		If cCus != TMP->CUSTO .Or. cFor != TMP->(FORNECE+LOJA)
			oRep:ThinLine()
			oRep:oFontBody:Bold := .T.
			aTTL := aClone(aTL1)
			oSec:Cell("FILIAL"):SetBlock( {|| "" })
			oSec:Cell("EMISSAO"):SetBlock( {|| "" })
			oSec:Cell("LANCAMENTO"):SetBlock( {|| "" })
			oSec:Cell("TIPO"):SetBlock( {|| "" })
			oSec:Cell("SALDOANT"):SetBlock( {|| ValorCTB(aTTL[1],.T.,.F.) })
			oSec:Cell("DEBITO"):SetBlock( {|| ValorCTB(aTTL[2],.F.,.T.)})
			oSec:Cell("CREDITO"):SetBlock( {|| ValorCTB(aTTL[3],.F.,.T.) })
			oSec:Cell("SALDOATU"):SetBlock( {|| ValorCTB(aTTL[1]+aTTL[3]-aTTL[2],.T.,.T.) })


			If (cCus != TMP->CUSTO)
				oSec:Cell("NUMERO"):SetBlock( {|| "TOTAL FORNECEDOR"})
				aTL1:= {0,0,0} //Zera Acc Fornecedor
				oSec:PrintLine() //Imprime Total Forcedor

				aTTL := aClone(aTL2)
				oSec:Cell("SALDOANT"):SetBlock( {|| "" })
				oSec:Cell("NUMERO"):SetBlock( {|| "TOTAL C.CUSTO"})
				aTL2 := {0,0,0} //Zera Acc C.Custo

			EndIf

			If (cFor != TMP->(FORNECE+LOJA) .AND. cCus == TMP->CUSTO)
				oSec:Cell("NUMERO"):SetBlock( {|| "TOTAL FORNECEDOR"})
				aTL1:= {0,0,0} //Zera Acc Fornecedor
			Endif

			oSec:PrintLine() //Imprime total
			oRep:ThinLine()
			If _aParam[SALTA_PAG] == 1 .And. cCus != TMP->CUSTO
				lPag:=.T.
			ElseIf _aParam[SALTA_PAG] == 2 .And. cFor != TMP->(FORNECE+LOJA)
				lPag:=.T.
			ElseIf _aParam[SALTA_PAG] == 3
				lPag:=.T.
			Else
				lPag:=.F.
			Endif
			If ! Eof() .And. lPag
				oRep:EndPage()
				oRep:StartPage()
			Endif
		Endif
	End
	If oRep:Cancel()
		MsgStop(cCancel)
		oRep:oFontBody:Bold := .T.
		oRep:SkipLine(1)
		oRep:PrintText("<<< "+cCancel+" >>>")
	Else
		oRep:SkipLine()
		oRep:ThinLine()
		oRep:oFontBody:Bold := .T.
		aTTL := aClone(aTL3)
		oSec:Cell("FILIAL"):SetBlock( {|| "" })
		oSec:Cell("EMISSAO"):SetBlock( {|| "" })
		oSec:Cell("TIPO"):SetBlock( {|| "" })
		oSec:Cell("LANCAMENTO"):SetBlock( {|| "" })
		oSec:Cell("NUMERO"):SetBlock( {|| "TOTAL GERAL"})
		oSec:Cell("SALDOANT"):SetBlock( {|| ValorCTB(aTTL[1],.T.,.F.) })
		oSec:Cell("DEBITO"):SetBlock( {|| ValorCTB(aTTL[2],.F.,.T.)})
		oSec:Cell("CREDITO"):SetBlock( {|| ValorCTB(aTTL[3],.F.,.T.) })
		oSec:Cell("SALDOATU"):SetBlock( {|| ValorCTB(aTTL[1]+aTTL[3]-aTTL[2],.T.,.T.) })
		oSec:PrintLine()
		oRep:ThinLine()
	Endif

	AFCloseArea({"TMP"})

	FErase(cTmp+GetDBExtension())
	FErase(cTmp+OrdBagExt())
Return(Nil)

/*/================================================================================================================================/*/
/*/{Protheus.doc} fSetCab
Ajusta Cabeçalho.

@type function
@author Edmar Tinti
@since 15/12/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Cabeçalho.

/*/
/*/================================================================================================================================/*/

Static Function fSetCab()
	Local aCab := {}
	Local cSpc := Space(8)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aCab := {"__LOGOEMP__",;
	"FIEG" + Chr(160) + cSpc + oRep:Title() + cSpc + Chr(160) + "Folha: " + LTrim(Transform(oRep:Page(),'@E 9,999')),;
	"J2A/"+FunName()+"/v.1"  + Chr(160) + cSpc                       + Chr(160) + DTOC(DDATABASE)}
Return(aCab)

/*/================================================================================================================================/*/
/*/{Protheus.doc} ValorCTB
Ajusta Valor Contábil.

@type function
@author Edmar Tinti
@since 15/12/2015
@version P12.1.23

@param nSaldo, numeric, Valor contábil a ser ajustado.
@param lSinal, logical, Indica se utiliza sinal -/+ ou D/C.
@param lZero, logical,  Indica se retorna saldo Zero como "".

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Valor Contábil ajustado.

/*/
/*/================================================================================================================================/*/

Static Function ValorCTB(nSaldo, lSinal, lZero)
	Local cSaldo, cSinal

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If lSinal
		If nSaldo < 0
			cSinal := "D"
		ElseIf nSaldo > 0
			cSinal := "C"
		Else
			cSinal := " "
		Endif
		cSaldo := Transform(Abs(nSaldo), "@E 9,999,999,999.99") + " " + cSinal
	Else
		cSaldo := Transform(nSaldo, "@E 9,999,999,999.99") + "  "
	Endif
	If ! lZero .And. nSaldo == 0
		cSaldo := ""
	Endif
Return(cSaldo)

/*/================================================================================================================================/*/
/*/{Protheus.doc} fDefPergs
Definição das Perguntas.

@type function
@author Edmar Tinti
@since 15/12/2015
@version P12.1.23

@param cPerg, Caractere, Nome do grupo de perguntas.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Indica se foi clicado o botão cancelar ou ok da pergunta.

/*/
/*/================================================================================================================================/*/
Static Function fDefPergs(cPerg)
	Local lRet 	 := .F.
	Local aPergs := {}
	Local aHelp  := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DbSelectArea("SX1")
	SX1->(DbSetOrder(1))
	If ! DbSeek(cPerg)
		aHelp := SepS2A("Informe a data inicial de emissão dos pedidos de compras")
		aAdd(aPergs,{"Data De ?"				,"Data De ?"					,"Data De ?"				,"mv_ch1","D",8,0,0,"G",""								,"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","   ","","S",aHelp,aHelp,aHelp})
		aHelp := SepS2A("Informe a data final de emissão dos pedidos de compras")
		aAdd(aPergs,{"Data De ?"				,"Data Até ?"					,"Data Até ?"				,"mv_ch2","D",8,0,0,"G",""								,"MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","   ","","S",aHelp,aHelp,aHelp})
		aHelp := SepS2A("Informe o forncedor incial, F3 para consulta")
		aAdd(aPergs,{"Fornecedor De ?"			,"Fornecdor De ?"				,"Fornecdor De ?"			,"mv_ch3","C",TamSX3("A2_COD")[1],0,0,"G",""		,"MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA2","","S",aHelp,aHelp,aHelp})
		aHelp := SepS2A("Informe o forncedor final, F3 para consulta")
		aAdd(aPergs,{"Fornecedor Até ?"		,"Fornecdor Até ?"			,"Fornecdor Até ?"		,"mv_ch4","C",TamSX3("A2_COD")[1],0,0,"G",""		,"MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SA2","","S",aHelp,aHelp,aHelp})
		aHelp := SepS2A("Informe o centro de custo incial, F3 para consulta")
		aAdd(aPergs,{"C.Custo De ?"			,"C.Custo De ?"				,"C.Custo De ?"			,"mv_ch5","C",TamSX3("CTT_CUSTO")[1],0,0,"G",""	,"MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","CTT","","S",aHelp,aHelp,aHelp})
		aHelp := SepS2A("Informe o centro de custo final, F3 para consulta")
		aAdd(aPergs,{"C.Custo Até ?"			,"C.Custo Até ?"				,"C.Custo Até ?"			,"mv_ch6","C",TamSX3("CTT_CUSTO")[1],0,0,"G",""	,"MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","CTT","","S",aHelp,aHelp,aHelp})
		aHelp := SepS2A("Informe a filial inicio, F3 para consulta")
		aAdd(aPergs,{"Filial De ?"				,"Filial De ?"					,"Filial De ?"				,"mv_ch7","C",TamSX3("C7_FILIAL")[1],0,0,"G",""	,"MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","S",aHelp,aHelp,aHelp})
		aHelp := SepS2A("Informe a filial final, F3 para consulta")
		aAdd(aPergs,{"Filial Até ?"			,"Filial Até ?"				,"Filial Até ?"			,"mv_ch8","C",TamSX3("C7_FILIAL")[1],0,0,"G",""	,"MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","S",aHelp,aHelp,aHelp})
		aHelp := SepS2A("Informe se considera fornecedores com Saldo Zerado")
		aAdd(aPergs,{"Saldo Zero ?" 			,"Saldo Zero ?"				,"Saldo Zero ?" 			,"mv_ch9","N",1,0,2,"C",""								,"MV_PAR09","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","","","","","S",aHelp,aHelp,aHelp})
		aHelp := SepS2A("Informe se salta pagina a cada troca de C.Custo, Fornecedor, ambos ou não salta pagina")
		aAdd(aPergs,{"Salto de Página ?" 	,"Salto de Página ?"			,"Salto de Página ?" 	,"mv_cha","N",1,0,2,"C",""								,"MV_PAR10","C.Custo","C.Custo","C.Custo","","","Fornecedor","Fornecedor","Fornecedor","","","Ambos","Ambos","Ambos","","","Não Salta","Não Salta","Não Salta","","","","","","","","","S",aHelp,aHelp,aHelp})
		AjustaSx1(cPerg, aPergs)
	Endif
	lRet := Pergunte(cPerg, .T.)
Return(lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SepS2A
Separar o Texto do Help das Perguntas.

@type function
@author Edmar Tinti
@since 15/12/2015
@version P12.1.23

@param cStr, Caractere, Texto do Help das Perguntas.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com Texto do Help das Perguntas.

/*/
/*/================================================================================================================================/*/

Static Function SepS2A(cStr) // --> A
	Local aRet := StrToArray(cStr, " ")
	Local nMax := 39
	Local nCnt := 0
	Local nLen := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cStr := ""
	For nCnt := 1 To Len(aRet)
		If Len(cStr) + Len(aRet[nCnt]) > nMax + nLen
			cStr += Chr(13)
			nLen := Len(cStr)
		Endif
		cStr += AllTrim(aRet[nCnt])+" "
	Next nCnt
	aRet := StrToArray(cStr, Chr(13))
Return(aRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} fQuery
Gerar arquivo de trabalho.

@type function
@author Edmar Tinti
@since 15/12/2015
@version P12.1.23

@param cFiltro, Caractere, Filtro (Compatibilidade).

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Nome da área de trabalho.

/*/
/*/================================================================================================================================/*/

Static Function fQuery(cFiltro)
	Local cTmp		:= ""
	Local cQry		:= ""
	Local aSdoZero	:= {}
	Local nSdo		:= 0
	Local nSdoAt	:= 0
	Local cFor		:= ""
	Local cCC		:= ""
	Local lSldAnt	:= .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	AFCloseArea({"TMP","QRY","PED","FAT"})

	aCpo := {{ "FILIAL", 	"C", TamSx3("C7_FILIAL")[1], 0 },;
	{ "CUSTO", 		"C", TamSx3("CTT_CUSTO")[1], 0 },;
	{ "FORNECE",	"C", TamSx3("A2_COD")[1], 0 },;
	{ "LOJA",		"C", TamSx3("A2_LOJA")[1], 0 },;
	{ "PEDIDO", 	"C", TamSx3("C7_NUM")[1], 0 },;
	{ "DOC", 		"C", TamSx3("D1_DOC")[1], 0 },;
	{ "SERIE", 		"C", TamSx3("D1_SERIE")[1], 0 },;
	{ "EMISSAO", 	"D", 08, 0 },;
	{ "DATAMOV", 	"D", 08, 0 },;
	{ "TIPO", 		"C", 02, 0 },;
	{ "SALDOANT", 	"N", 14, 2 },;
	{ "DEBITO", 	"N", 14, 2 },;
	{ "CREDITO", 	"N", 14, 2 },;
	{ "SALDOATU", 	"N", 14, 2 }}
	cTmp := CriaTrab(aCpo,.T.)
	dbUseArea(.T.,,cTmp,"TMP",.F.,.F.)
	IndRegua("TMP",cTmp,"FILIAL+CUSTO+FORNECE+LOJA+DTOS(DATAMOV)+PEDIDO",Nil,Nil,"Ordenando C.Custo...",.F.)
	TMP->(DbSetOrder(1))

	//------------------------------------------------------------
	//-- Filtra Pedido de Compras e Nota Fiscal de entrada e
	//-- gerar arquivo de trabalho - QRY.
	//------------------------------------------------------------

	//---------------
	//-- Filter User
	//---------------
	cSA2Filter := IIF(Empty(cSA2Filter),"% 1=1 %","%"+cSA2Filter+"%")
	cSC7Filter := IIF(Empty(cSC7Filter),"% 1=1 %","%"+cSC7Filter+"%")
	cSD1Filter := IIF(Empty(cSD1Filter),"% 1=1 %","%"+cSD1Filter+"%")

	BeginSQL ALIAS "QRY"

		SELECT *
		FROM
		(SELECT 'PC'			AS TIPO,
		SC7.C7_FILIAL	AS FILIAL,
		SC7.C7_FORNECE	AS FORNECE,
		SC7.C7_LOJA		AS LOJA,
		SC7.C7_CC		AS CUSTO,
		SC7.C7_EMISSAO	AS EMISSAO,
		SC7.C7_DTLANC	AS DTLANC,
		SC7.C7_NUM		AS PEDIDO,
		''				AS DOC,
		''				AS SERIE,
		SUM(SC7.C7_QUANT*SC7.C7_PRECO) AS TOTAL
		FROM %table:SC7% SC7
		INNER JOIN %table:SA2% SA2
		ON SA2.%NotDel% AND SA2.A2_COD = SC7.C7_FORNECE AND SA2.A2_LOJA = SC7.C7_LOJA
		WHERE SC7.%NotDel%
		AND %exp:cSC7Filter%
		AND %exp:cSA2Filter%
		AND SC7.C7_XRESTPG = '3'
		AND SC7.C7_FILIAL 	BETWEEN %exp:_aParam[FILIAL_DE]% 		AND %exp:_aParam[FILIAL_ATE]%
		AND SC7.C7_DTLANC 	BETWEEN %exp:DTOS(_aParam[DATA_DE])% 	AND %exp:DTOS(_aParam[DATA_ATE])%
		AND SC7.C7_FORNECE 	BETWEEN %exp:_aParam[FORN_DE]% 			AND %exp:_aParam[FORN_ATE]%
		AND SC7.C7_CC 		BETWEEN %exp:_aParam[CUSTO_DE]% 		AND %exp:_aParam[CUSTO_ATE]%
		GROUP BY SC7.C7_FILIAL, SC7.C7_FORNECE, SC7.C7_LOJA, SC7.C7_CC, SC7.C7_EMISSAO, SC7.C7_DTLANC, SC7.C7_NUM

		UNION ALL

		SELECT 'NF'				AS TIPO,
		SD1.D1_FILIAL	AS FILIAL,
		SD1.D1_FORNECE	AS FORNECE,
		SD1.D1_LOJA		AS LOJA,
		SD1.D1_CC		AS CUSTO,
		SD1.D1_EMISSAO	AS EMISSAO,
		SD1.D1_DTDIGIT	AS DTLANC,
		SD1.D1_PEDIDO	AS PEDIDO,
		SD1.D1_DOC		AS DOC,
		SD1.D1_SERIE	AS SERIE,
		SUM(SD1.D1_CUSTO)AS TOTAL
		FROM %table:SD1% SD1
		INNER JOIN %table:SA2% SA2
		ON SA2.%NotDel% AND SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA
		WHERE SD1.%NotDel%
		AND %exp:cSD1Filter%
		AND %exp:cSA2Filter%
		AND SD1.D1_XRESTPG = '3'
		AND SD1.D1_FILIAL 	BETWEEN %exp:_aParam[FILIAL_DE]% 		AND %exp:_aParam[FILIAL_ATE]%
		AND SD1.D1_FORNECE 	BETWEEN %exp:_aParam[FORN_DE]% 			AND %exp:_aParam[FORN_ATE]%
		AND SD1.D1_DTDIGIT 	BETWEEN %exp:DTOS(_aParam[DATA_DE])% 	AND %exp:DTOS(_aParam[DATA_ATE])%
		AND SD1.D1_CC		BETWEEN %exp:_aParam[CUSTO_DE]% 		AND %exp:_aParam[CUSTO_ATE]%
		GROUP BY SD1.D1_FILIAL, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_CC, SD1.D1_EMISSAO, SD1.D1_DTDIGIT, SD1.D1_PEDIDO, SD1.D1_DOC, SD1.D1_SERIE)
		AS PCNF
		ORDER BY FILIAL, CUSTO, FORNECE, LOJA, EMISSAO, DTLANC, PEDIDO, DOC, SERIE, TIPO

	EndSQL

	dbSelectArea("QRY")

	nSdo := 0
	dBEval({|| nSdo += 1})
	oRep:SetMsgPrint("Processando Debito e Crédito...")
	oRep:SetMeter(0)
	oRep:IncMeter()
	oRep:SetMeter(nSdo)
	QRY->(DbGoTop())
	Do While .T.

		If QRY->(Eof())
			If (.Not. Empty(cFor) .And. nSdoAt == 0)
				aAdd(aSdoZero,cFor)
			EndIf
			Exit
		EndIf

		oRep:IncMeter()
		If oRep:Cancel()
			Exit
		Endif

		If (cFor != QRY->(FORNECE+LOJA) .OR. cCC != QRY->CUSTO)

			If (.Not. Empty(cFor) .And. nSdoAt == 0)
				aAdd(aSdoZero,cFor)
			EndIf

			cFor := QRY->(FORNECE+LOJA)
			cCC  := QRY->CUSTO
			nSdo := SaldoAnt(QRY->FILIAL,QRY->FORNECE,QRY->LOJA,_aParam[DATA_DE],TMP->CUSTO)
			nSdoAt := nSdo
			lSldAnt :=.T.
		Else
			lSldAnt:= .F.
		Endif

		TMP->(DbAppend())
		TMP->FILIAL 	:= QRY->FILIAL
		TMP->CUSTO 		:= QRY->CUSTO
		TMP->FORNECE 	:= QRY->FORNECE
		TMP->LOJA 		:= QRY->LOJA
		TMP->EMISSAO	:= STOD(QRY->EMISSAO)
		TMP->DATAMOV	:= STOD(QRY->DTLANC)
		TMP->PEDIDO 	:= QRY->PEDIDO
		TMP->DOC 		:= QRY->DOC
		TMP->SERIE 		:= QRY->SERIE
		TMP->SALDOANT	:= IIF(lSldAnt,nSdo,0)
		If QRY->TIPO == "PC"
			TMP->CREDITO:= SaldoPC(QRY->FILIAL,QRY->PEDIDO,QRY->FORNECE,QRY->LOJA,SToD(QRY->DTLANC),QRY->CUSTO)
			nSdoAt		+= TMP->CREDITO
		Else
			TMP->DEBITO := QRY->TOTAL
			nSdoAt		-= TMP->DEBITO
		EndIf
		TMP->TIPO 		:= QRY->TIPO
		TMP->SALDOATU	:= nSdoAt

		QRY->(DbSkip())
	EndDo

	AFCloseArea({"QRY"})

	//------------------------------------------------------------
	//-- Exclui do arquivo TMP os movimentos de fornecedores
	//-- que o saldo atual é zero.
	//------------------------------------------------------------
	DbSelectArea("TMP")
	If .Not. oRep:Cancel() .And. _aParam[SALDO_ZERO] == 2 .And. ! Empty(aSdoZero)
		oRep:SetMsgPrint("Atualizando Saldos Zerados...")
		oRep:SetMeter(0)
		oRep:IncMeter()
		oRep:SetMeter(RecCount())
		TMP->(DbGoTop())
		While TMP->(! Eof())
			oRep:IncMeter()
			If oRep:Cancel()
				ZAP
				Exit
			Endif
			If aScan(aSdoZero, {|x| x == TMP->(FORNECE+LOJA)}) != 0
				DbDelete()
			Endif
			TMP->(DbSkip())
		End
		Pack
	Endif
	DbClearIndex()
	TMP->(DbGoTop())

Return(cTmp)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SaldoAnt
Retorna saldo anterior de restos a pagar conforme os parâmetros.

@type function
@author Allan da Silva Faria
@since 14/03/2016
@version P12.1.23

@param _cFilial, Caractere, Código da Filial.
@param _cFor, Caractere, Código do fornecedor.
@param _cLjFor, Caractere, Loja do fornecedor.
@param _dDtRefr, Data, Data referencia.
@param _cCC, Caractere, Centro de Custo.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Valor do Saldo Anteior.

/*/
/*/================================================================================================================================/*/

Static Function SaldoAnt(_cFilial,_cFor,_cLjFor,_dDtRefr,_cCC)
	Local nSdo := SaldoRP(_cFilial,,_cFor,_cLjFor,_dDtRefr,_cCC,.T.)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

Return(nSdo)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SaldoPC
Retorna Saldo do Pedido de Compras conforme parâmetros.

@type function
@author Allan da Silva Faria
@since 14/03/2016
@version P12.1.23

@param _cFilial, Caracter, Código da Filial.
@param _cPedido, Caracter, Numero do Pedido de Compra.
@param _cFor, Caracter, Código do fornecedor.
@param _cLjFor, Caracter, Loja do fornecedor.
@param _dDtRefr, Date, Data referencia.
@param _cCC, Caracter, Centro de Custo.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Saldo do Pedido de compras.

/*/
/*/================================================================================================================================/*/

Static Function SaldoPC(_cFilial,_cPedido,_cFor,_cLjFor,_dDtRefr,_cCC)
	Local nSdo := SaldoRP(_cFilial,_cPedido,_cFor,_cLjFor,_dDtRefr,_cCC)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

Return(nSdo)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SaldoRP
Retorna saldo do restos a pagar, conforme os parâmetros retorna saldo anterior ou saldo do pedido de compras.

@type function
@author Allan da Silva Faria
@since 09/03/2016
@version P12.1.23

@param _cFilial, Caracter, Código da Filial.
@param _cPedido, Caracter, Numero do Pedido de Compra.
@param _cFor, Caracter, Código do fornecedor.
@param _cLjFor, Caracter, Loja do fornecedor.
@param _dDtRefr, Data, Data referencia.
@param _cCC, Caracter, Centro de Custo.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Valor do Saldo do Pedido ou Anterior.

/*/
/*/================================================================================================================================/*/

Static Function SaldoRP(_cFilial,_cPedido,_cFor,_cLjFor,_dDtRefr,_cCC,_lASldAnt)

	Local cQry 		:= ""
	Local nSdo 		:= 0

	DEFAULT _cFilial  := ""
	DEFAULT _cPedido  := ""
	DEFAULT _cFor	  := ""
	DEFAULT _cLjFor	  := ""
	DEFAULT _cCC	  := ""
	DEFAULT _lASldAnt := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	AFCloseArea({"PC","NF"})

	//------------------------------
	//-- Saldo Pedido de Compras
	//------------------------------
	cQry := " SELECT SC7.C7_NUM, SC7.C7_ITEM, SUM(SC7.C7_QUANT*SC7.C7_PRECO) AS CREDITO"
	cQry += " FROM "+RetSqlName("SC7")+" SC7"
	cQry += " WHERE SC7.D_E_L_E_T_ = ' '"
	cQry += " AND SC7.C7_XRESTPG = '3'"
	If .Not. Empty(_cFilial)
		cQry += " AND SC7.C7_FILIAL = "+ValToSql(_cFilial)
	EndIf
	If .Not. Empty(_cFor)
		cQry += " AND SC7.C7_FORNECE = "+ValToSql(_cFor)
	EndIf
	If .Not. Empty(_cLjFor)
		cQry += " AND SC7.C7_LOJA = "+ValToSql(_cLjFor)
	EndIF
	If .Not. Empty(_cCC)
		cQry += " AND SC7.C7_CC = "+ValToSql(_cCC)
	EndIf
	If .Not. Empty(_cPedido)
		cQry += " AND SC7.C7_NUM = "+ValToSql(_cPedido)
	EndIf
	If _lASldAnt
		cQry += " AND SC7.C7_DTLANC < "+ValToSql(_dDtRefr)
	Else
		cQry += " AND SC7.C7_DTLANC = "+ValToSql(_dDtRefr)
	EndIf
	cQry += " GROUP BY SC7.C7_NUM, SC7.C7_ITEM"
	cQry += " ORDER BY SC7.C7_NUM, SC7.C7_ITEM"
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"PC",.T.,.F.)

	dbEval({|| nSdo += PC->CREDITO})

	PC->(DbGoTop())

	//------------------------------
	//-- Nota Fiscal Compras
	//------------------------------
	While PC->(! Eof())
		cQry := " SELECT SUM(SD1.D1_CUSTO) AS DEBITO"
		cQry += " FROM "+RetSqlName("SD1")+" SD1"
		cQry += " WHERE SD1.D_E_L_E_T_ = ' '"
		If .Not. Empty(_cPedido)
			cQry += " AND SD1.D1_FILIAL = "+ValToSql(_cFilial)
		EndIF
		If .Not. Empty(_cFor)
			cQry += " AND SD1.D1_FORNECE = "+ValToSql(_cFor)
		EndIf
		If .Not. Empty(_cLjFor)
			cQry += " AND SD1.D1_LOJA = "+ValToSql(_cLjFor)
		EndIf
		cQry += " AND SD1.D1_PEDIDO = "+ValToSql(PC->C7_NUM)
		cQry += " AND SD1.D1_ITEMPC = "+ValToSql(PC->C7_ITEM)
		If _lASldAnt
			cQry += " AND SD1.D1_DTDIGIT < "+ValToSql(_dDtRefr)
		Else
			cQry += " AND SD1.D1_DTDIGIT <= "+ValToSql(_dDtRefr)
		EndIf
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"NF",.T.,.F.)

		nSdo -= NF->DEBITO

		PC->(DbSkip())
	EndDo

	AFCloseArea({"PC","NF"})

Return(nSdo)

/*/================================================================================================================================/*/
/*/{Protheus.doc} AFCloseArea
Fecha Alias.

@type function
@author Allan da Silva Faria
@since 14/03/2016
@version P12.1.23

@param _aAlias, Array, Alias que será fechado.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function AFCloseArea(_aAlias)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	For _n:=1 To Len(_aAlias)
		If Select(_aAlias[_n]) > 0
			dbSelectArea(_aAlias[_n])
			(_aAlias[_n])->(DbCloseArea())
		Endif
	Next _n

Return Nil