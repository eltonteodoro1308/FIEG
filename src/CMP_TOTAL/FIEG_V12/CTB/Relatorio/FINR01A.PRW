#Include "Protheus.ch"
#Include "RPTDEF.CH"

#Define S1_DAT			1
#Define S1_HISTORICO	2
#Define S1_TITULO		3
#Define S1_EMISSAO		4
#Define S1_VENCIMENTO	5
#Define S1_BAIXA		6
#Define S1_DEBITO		7
#Define S1_CREDITO		8
#Define S1_SALDO_ATU	9
#Define S1_DIGITO		10

#Define S2_DESCRICAO	1
#Define S2_SD_ANTERIOR	2
#Define S2_DIG1			3
#Define S2_DEB			4
#Define S2_CRED			5
#Define S2_SD_ATUAL		6
#Define S2_DIG2			7

/*/================================================================================================================================/*/
/*/{Protheus.doc} FINR01A
Razonete de Fornecedores.

@type function
@author Daniel Tadashi Batori
@since 23/08/2006
@version P12.1.23

@obs Desenvolvimento FIEG

@history 14/09/2018, José Fernando Csatroviejo Vilela, Alterado.
@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function FINR01A()
	Local oReport
	Private cAuxFoot	:= ""
	Private lImprime	:= .F.
	Private nSaldoAtu	:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oReport := ReportDef()
	oReport :PrintDialog()

Return Nil

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportDef
Definição do layout do Relatório.

@type function
@author Daniel Batori
@since 23/08/2006
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Objeto, Objeto que representa o reltório.

/*/
/*/================================================================================================================================/*/

Static Function ReportDef()
	Local oReport
	Local oEntida
	Local oFornec
	Local oSection1
	Local oSection2
	Local nTamTit	:= 0
	Local nTamCliFor:= 0
	Local nTamVlr	:= 0
	Local cDescRel	:= ""
	Private _cPicture := "@E 999,999,999.99"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	//-- Cria Pergunta
	AjustaSX1("FINR01A")

	Pergunte("FINR01A",.T.)


	/*IF !(RTRIM(LTRIM(mv_par21)) $ "ZZZZZZZZZZZZZZZZZZZZ")
	mv_par21 := soma1(RTRIM(LTRIM(mv_par21)))
	EndIf   */

	//-- Descrição do Relatório
	cDescRel := "Este relatorio ira imprimir o razonete de Fornecedores. "
	cDescRel += "Podera ser emitida toda a movimentac-o dos mesmos, ou somente os valores originais."

	oReport := TReport():New("FINR01A","RAZONETE DE CONTAS CORRENTES DE FORNECEDOR","FINR01A", {|oReport| ReportPrint(oReport)},cDescRel)

	oReport:SetPortrait(.T.)

	nTamTit		:= TamSX3("E1_PREFIXO")[1] + TamSX3("E1_NUM")[1] + TamSX3("E1_PARCELA")[1] + 3 + TamSX3("E1_TIPO")[1]
	nTamCliFor  := TamSX3("A1_COD")[1] + TamSX3("A1_LOJA")[1] + 1
	nTamVlr		:= 16
	nTamVlrA		:= 12
	nTamVlrB		:= 19
	nTamVlrC		:= 17



	//-----------------------
	// Entidade Contábil
	//-----------------------
	oEntida := TRSection():New(oReport,"C.Custo",{"cNomeArq"},)
	TRCell():New(oEntida,"CCUSTO"		,,"","@!",18						,.F.,{||"CENTRO DE CUSTO :"})	// HEADER C.CUSTO
	TRCell():New(oEntida,"CODIGO"		,,"","@!",TamSX3("CTT_CUSTO")[1]	,.F.,) 		// CODIGO DO C.CUSTO
	TRCell():New(oEntida,"NOME"			,,"","@!",TamSX3("CTT_DESC01")[1]	,.F.,)  	// DESCRIÇÃO DO C.CUSTO
	oEntida:AutoSize()

	oEntida:lPrintHeader:=.F.
	oEntida:nLinesBefore:= 1

	//-----------------------
	// Fornecedor
	//-----------------------
	oFornec := TRSection():New(oReport,"Cliente/Fornecedor",{"cNomeArq"},)
	TRCell():New(oFornec ,"CLIFOR"		,,"","@!",13						,.F.,{||"FORNECEDOR :"})    // HEADER CLIENTE/FORNECEDOR
	TRCell():New(oFornec ,"CODIGO"		,,"","@!",nTamCliFor			,.F.,) 			 // CODIGO DO CLIENTE/FORNECEDOR
	TRCell():New(oFornec ,"NOME"		,,"","@!",100					,.F.,)  		// DESCRIÇÃO CLIENTE/FORNECEDOR
	oFornec:AutoSize()

	//-- Celula NEGRITO
	oFornec:Cell("CLIFOR"):lBold:= .T.
	oFornec:Cell("CODIGO"):lBold:= .T.
	oFornec:Cell("NOME"  ):lBold:= .T.

	oFornec:lPrintHeader:=.F.
	oFornec:nLinesBefore:= 1


	//-----------------------
	// Analítico
	//-----------------------
	oSection1 := TRSection():New(oReport,"Analítico",{"cNomeArq"},)
	TRCell():New(oSection1,"E1_EMISSAO"	,"SE1","   DATA      "	    , 			,13    ,.F.,)					// "DATA"
	TRCell():New(oSection1,"TITULO"		,	  ,"PRF NUMERO PC TIPO"	,			,nTamTit,.F.,)  	  			//"PRF NUMERO PC TIPO"
	TRCell():New(oSection1,"E1_HIST"	,"SE1","HISTORICO"			,			,76		,.F.,) 					//"HISTORICO"
	TRCell():New(oSection1,"SALDO_ANT"	,	  ,"SALDO INICIAL"		,_cPicture	,nTamVlr,.F.,,,,"RIGHT") 	    //"SALDO INICIAL"
	TRCell():New(oSection1,"DEBITO"		,	  ,"DEBITO"				,_cPicture	,nTamVlr,.F.,,,,"RIGHT") 		//"DEBITO"
	TRCell():New(oSection1,"CREDITO"	,	  ,"CREDITO"			,_cPicture	,nTamVlr,.F.,,,,"RIGHT") 		//"CREDITO"
	TRCell():New(oSection1,"SALDO"		,     ,"SALDO ATUAL"		,_cPicture	,nTamVlr,.F.,,,,"RIGHT") 		//"SALDO ATUAL"
	TRCell():New(oSection1,"DIGITO"		,	  ,"DC"					,			,1		,.F.,)
	oSection1:AutoSize()


	//-----------------------
	// Sintético
	//-----------------------
	oSection2 := TRSection():New( oReport,"Sintético", {"cNomeArq"},)
	TRCell():New(oSection2,"DESCRICAO"	,,							,			,113    ,.F.,) 					//"CLIENTE"/"FORNECEDOR"
	TRCell():New(oSection2,"TAM1"   	,,							,			,10		,.F.,)
	TRCell():New(oSection2,"TAM2"   	,,							,			,10		,.F.,)
	TRCell():New(oSection2,"TAM3"   	,,							,			,10		,.F.,)
	TRCell():New(oSection2,"SALDO_ANT"	,,"SALDO INICIAL"			,_cPicture	,nTamVlr,.F.,,,,"RIGHT") 		//"SALDO ANTERIOR"
	TRCell():New(oSection2,"DIGITO1"	,,							,			,1		,.F.,)
	TRCell():New(oSection2,"DEBITO" 	,,"DEBITO"					,_cPicture	,nTamVlrA,.F.,,,,"RIGHT") 		//"DEBITO"
	TRCell():New(oSection2,"CREDITO"	,,"CREDITO"					,_cPicture	,nTamVlrB,.F.,,,,"RIGHT") 		//"CREDITO"
	TRCell():New(oSection2,"SALDO" 		,,"SALDO ATUAL"				,_cPicture	,nTamVlrC,.F.,,,,"RIGHT") 		//"SALDO ATUAL"
	TRCell():New(oSection2,"DIGITO2"	,,"DC2"						,,1,.F.,)
	oSection2:AutoSize()

Return oReport

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportPrint
A função estática ReportDef deverá ser criada para todos os relatórios que poderão ser agendados pelo usuário.

@type function
@author Daniel Batori
@since 22/08/2006
@version P12.1.23

@param oReport, Objeto, Objeto Report do Relatório.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ReportPrint(oReport)

	Local oEntida	:= oReport:Section(1)
	Local oFornec	:= oReport:Section(2)
	Local oSection1 := oReport:Section(3)
	Local oSection2 := oReport:Section(4)
	Local oTFont1 	:= TFont():New(oReport:oFontBody:Name,0,(oReport:nFontBody+3),,.T.,,,,,.F.,.F.)
	Local aSec1[11]
	Local aSec2[7]
	Local cTexto
	LOCAL cString:="SE1"
	Local cTitulo
	LOCAL CbCont,CbTxt
	LOCAL nQuebra:=0,lImprAnt := .F.
	LOCAL cNome,nTotDeb:=0,nTotCrd:=0,nTotDebG:=0,nTotCrdG:=0,nSalAtuG:=0,nSalAntG:=0
	LOCAL dEmissao:=CTOD(""),dVencto:=CTOD("")
	LOCAL nRec,nPrim,cPrefixo,cNumero,cParcela,cTipo,cNaturez,nValliq
	LOCAL nAnterior:=0,cAnterior,cFornece,dDtDigit,cRecPag,cSeq
	LOCAL cCodigo, cLoja
	LOCAL lNoSkip := .F.
	LOCAL lFlag := .F.
	LOCAL nSaldoFinal:=0
	LOCAL aCampos:={},aTam:={}
	LOCAL aInd:={}
	LOCAL cIndE1 :=cIndE2 :=cIndE5 :=cIndA1 :=cIndA2 :=" "
	LOCAL nRegAtu
	Local bBlockDC := {| nNum | if(int(nNum*100)=0," ",if(nNum>0,"C","D")) }
	Local nX := 0
	Local nValor := 0

	Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
	!Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
	!Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
	!Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )
	//Controla o Pis Cofins e Csll na RA (1 = Controla retenção de impostos no RA; ou 2 = Não controla retenção de impostos no RA(default))
	Local lRaRtImp  := If (FindFunction("FRaRtImp"),FRaRtImp(),.F.)
	Local aStru 	:= {}
	Local nTamNro	 := TamSx3("E1_NUM")[1]
	Local nTamParc 	 := TamSx3("E1_PARCELA")[1]
	Local nTamTipo 	 := TamSx3("E1_TIPO")[1]
	Local nTamTitulo := TamSx3("E1_PREFIXO")[1] + nTamNro + nTamParc + 3 + nTamTipo
	Local nI
	Local aDados 	:= Array(If(lPccBaixa .OR. lRaRtImp,20,14))
	Local aDadosInicial := Array(If(lPccBaixa .OR. lRaRtImp,20,14))
	Local aImp10925	:= {}
	Local aDadosAbat:= {}
	Local nLinReport:= 8
	Local nLinPag	:= 0
	Local nSaldoTra := 0
	//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default))
	Local lPccBxCr	:= If (FindFunction("FPccBxCr"),FPccBxCr(),.F.)

	Local cCtContAnt:= ""
	Local nBuffer	:= 0
	Local cConta := ""
	Local cCusto 	:= ""
	Local lImpCCust := .F.
	Local lImpTotCC := .F.

	Local nSalAtuCc := 0
	Local nTotDebCc := 0
	Local nTotCrdCc := 0

	Local nResArred := 0.1
	Local nValorAbs := 0

	Local MVPREFDD := ''

	Local _bFilDes:= {||}

	Local cFrn := ''
	Local nContFrn := 0
	Local cFrnAtual := ""
	Local cFrnAnt := ""

	If !Empty(mv_par17)
		nLinPag 	:= IIf(mv_par17>=99,99,mv_par17)
	Else
		nLinPag 	:= 99
	EndIf

	lImprime := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//-----------------------
	// Entidade Contábil
	//-----------------------
	oEntida:Cell("CODIGO"	):SetBlock( { || cCusto 	} )
	oEntida:Cell("NOME"		):SetBlock( { || Posicione("CTT",1,FR01AFil("CTT",cNomeArq->FILIAL)+cCusto,"CTT_DESC01") } )

	//-- Define fonte da celula
	oEntida:Cell("CCUSTO"	):oFontBody:= oTFont1
	oEntida:Cell("CODIGO"	):oFontBody:= oTFont1
	oEntida:Cell("NOME" 	):oFontBody:= oTFont1

	//-----------------------
	// Fornecedor
	//-----------------------
	oFornec:Cell("CODIGO"	):SetBlock( { || cCodigo + "/" + cLoja	} )
	oFornec:Cell("NOME"		):SetBlock( { || cNome 					} )

	//-----------------------
	// Analítico
	//-----------------------
	//	oSection1:Cell("E1_EMISSAO"	):SetBlock(	{ || Iif( Empty( aSec1[S1_DAT] )	, CtoD( "  /  /    " ), aSec1[S1_DAT] ) })
	oSection1:Cell("E1_EMISSAO"	):SetBlock(	{ || Iif( Empty( aSec1[S1_DAT] )	, CtoD( "" ), aSec1[S1_DAT] ) })
	oSection1:Cell("E1_HIST"	):SetBlock( { || aSec1[S1_HISTORICO] })
	oSection1:Cell("TITULO"		):SetBlock( { || aSec1[S1_TITULO] })
	oSection1:Cell("DEBITO"		):SetBlock(	{ || Iif( Empty( aSec1[S1_DEBITO] )		, 0, aSec1[S1_DEBITO] ) })
	oSection1:Cell("CREDITO"	):SetBlock(	{ || Iif( Empty( aSec1[S1_CREDITO] )	, 0, aSec1[S1_CREDITO] ) })
	oSection1:Cell("SALDO"		):SetBlock( { || aSec1[S1_SALDO_ATU] })
	oSection1:Cell("DIGITO"		):SetBlock( { || aSec1[S1_DIGITO] })
	oSection1:Cell("DIGITO"		):HideHeader()
	oSection1:Cell("SALDO_ANT"	):Hide()


	//-----------------------
	// Sintético
	//-----------------------
	oSection2:Cell("DESCRICAO"	):SetBlock( { || aSec2[S2_DESCRICAO] 			})
	oSection2:Cell("DESCRICAO"	):SetTitle(	"FORNECEDOR"						 )
	oSection2:Cell("SALDO_ANT"	):SetBlock( { || aSec2[S2_SD_ANTERIOR] 			})
	oSection2:Cell("DIGITO1"	):SetBlock( { || aSec2[S2_DIG1] })
	oSection2:Cell("DIGITO1"	):HideHeader()
	oSection2:Cell("DEBITO"		):SetBlock( { || aSec2[S2_DEB]					})
	oSection2:Cell("CREDITO"	):SetBlock( { || aSec2[S2_CRED]					})
	oSection2:Cell("SALDO"		):SetBlock( { || aSec2[S2_SD_ATUAL] 			})
	oSection2:Cell("DIGITO2"	):SetBlock( { || aSec2[S2_DIG2] 				})
	oSection2:Cell("DIGITO2"	):HideHeader()

	If oReport:GetOrientation() == 2
		oSection2:Cell("DESCRICAO"):SetSize(125)
	EndIf

	If oReport:nDevice == IMP_EXCEL
		oSection2:Cell("TAM1"):Enable()
		oSection2:Cell("TAM2"):Enable()
		oSection2:Cell("TAM3"):Enable()
	Else
		oSection2:Cell("TAM1"):Disable()
		oSection2:Cell("TAM2"):Disable()
		oSection2:Cell("TAM3"):Disable()
	EndIf

	//	If mv_par10 == 1  // Analitico
	oSection1:SetHeaderPage()
	oSection2:SetHeaderSection(.F.)
	oSection1:OnPrintLine({|| F550LinPag(nLinPag,@nLinReport,oReport,@nSaldoTra)})
	//	Else
	//		oSection1:SetHeaderSection(.F.)
	//		oSection2:OnPrintLine({|| F550LinPag(nLinPag,@nLinReport,oReport,@nSaldoTra)})
	//	EndIf

	//Impressao do numero de pagina conforme pergunta 16 e 17
	oReport:SetPageNumber(MV_PAR11)
	oReport:OnPageBreak({||	If ( oReport:Page() > MV_PAR12, oReport:SetPageNumber(2), "") })

	oReport:SetPageFooter( 5 , {|| IIF((lImprime .Or. (nSaldoAtu != 0)),;
	F550Rodape(oReport,nSaldoTra,Eval(bBlockDC,nSaldoTra),aSec1), nil) } )


	//+-----------------------------------------------------------------------+
	//|Alimenta vetor com os impostos que devem gerar movimentos de historico |
	//+-----------------------------------------------------------------------+
	aadd(aImp10925,{"SE2->E2_VRETPIS","Pis"})
	aadd(aImp10925,{"SE2->E2_VRETCOF","Cofins"})
	aadd(aImp10925,{"SE2->E2_VRETCSL","Csll"})

	//+--------------------------------------------------------------+
	//| For‡a ser por filial quando exista somente 1 filial,indepen- |
	//| dente da resposta                                            |
	//+--------------------------------------------------------------+
	mv_par07 := If(SM0->(Reccount())==1,1,mv_par07) // Lista Por 1 - Filial     2 -Empresa

	//+--------------------------------------------------------------+
	//| Gera arquivo de Trabalho                                     |
	//+--------------------------------------------------------------+

	aTam:=TamSX3("E1_FILIAL")
	aAdd(aCampos,{"FILIAL" ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_CLIENTE")
	aAdd(aCampos,{"CODIGO" ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_LOJA")
	aAdd(aCampos,{"LOJA"   ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_EMISSAO")
	aAdd(aCampos,{"DATAEM"   ,"D",aTam[1],aTam[2]})
	aAdd(aCampos,{"NUMERO" ,"C",nTamTitulo,0})
	aTam:=TamSX3("E1_TIPO")
	aAdd(aCampos,{"TIPO"   ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_PORTADO")
	aAdd(aCampos,{"BANCO"  ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_EMISSAO")
	aAdd(aCampos,{"EMISSAO","D",aTam[1],aTam[2]})
	aAdd(aCampos,{"BAIXA"  ,"D",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_VENCREA")
	aAdd(aCampos,{"VENCTO" ,"D",aTam[1],aTam[2]})
	aAdd(aCampos,{"VALOR"  ,"N",18,2})
	aAdd(aCampos,{"HISTOR" ,"C",40,0})
	aAdd(aCampos,{"DC"     ,"C", 1,0})
	aAdd(aCampos,{"MOEDA"  ,"N", TamSX3("E1_MOEDA")[1],0}) // Utilizada para saldo contabil
	aAdd(aCampos,{"CONTA"	,"C", TamSX3("A2_CONTA")[1],0})	//Incluido este campo para a aglutinacao por loja
	aTam:=TamSX3("E1_PREFIXO")
	aAdd(aCampos,{"PREFIXO" ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_PARCELA")
	aAdd(aCampos,{"PARCELA"   ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_CCC")
	aAdd(aCampos,{"CCUSTO"   ,"C",aTam[1],aTam[2]})
	cNomeArq := CriaTrab(aCampos)
	dbUseArea( .T., __cRDDNTTS, cNomeArq, "cNomeArq", if(.F. .Or. .F., !.F., NIL), .F. )


	//*********************** SELECIONA FORNECEDORES CONFORME PARAMETROS     ***************************//

	//+--------------------------------------------------------------+
	//| Localiza e grava titulos a pagar dentro dos parametros       |
	//+--------------------------------------------------------------+

	dbSelectArea("SEF")
	SEF->(dbSetOrder (6))

	cQuery := "SELECT * FROM " + RetSqlName("SE2") + " SEF WHERE"
	If mv_par07 == 1
		cQuery += " SEF.E2_FILIAL = '" + FWxFilial("SE2") + "' AND "
	else
		cQuery += " (SEF.E2_FILIAL BETWEEN '" + mv_par22 + "' AND '" + mv_par23 + "') AND"
	endif
	cQuery += " (SEF.E2_FORNECE BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "')"
	//	cQuery += " AND SEF.E2_EMIS1 >= '" + DTOS(mv_par01)  + "'"
	cQuery += " AND SEF.E2_EMIS1 <= '" + DTOS(mv_par02)  + "'"
	cQuery += " AND (SEF.E2_CCD  BETWEEN " + ValToSql(mv_par20) + " AND " + ValToSql(soma1(RTRIM(LTRIM(mv_par21)))) + ")"
	cQuery += " AND SEF.E2_TIPO NOT LIKE '"+MVPROVIS+"'"
	cQuery += " AND (SEF.E2_NATUREZ BETWEEN '" + mv_par08 + "' AND '" + mv_par09 + "')"
	cQuery += " AND SEF.D_E_L_E_T_ <> '*'"
	cQuery += " AND CASE "
	cQuery += "       WHEN SEF.E2_XTPTRF <> '' THEN SEF.E2_XTPTRF  "
	cQuery += "       ELSE '2' "
	cQuery += "      END = '2' "

	//+--------------------------------------------------------------+
	//| Verifica quais serao impressos                               |
	//+--------------------------------------------------------------+
	If mv_par06 == 2 // So'Normais
		cQuery += " And SEF.E2_TIPO NOT IN " + FORMATIN(MVPAGANT,"/")
	Endif

	If mv_par06 == 3 // So'Adiantamentos
		cQuery += " And SEF.E2_TIPO IN " + FORMATIN(MVPAGANT,"/")
	EndIf

	If !Empty(mv_par24)
		cQuery += " And SEF.E2_PREFIXO NOT IN " + FORMATIN(mv_par24,";")
	EndIf

	cQuery += " And SEF.E2_TIPO NOT IN " + FORMATIN(MVPROVIS,";")
	If mv_par13 == 1 		// Seleciona fornecedor por conta contabil
		cFilial := FWxFilial()
		cQuery += " AND SEF.E2_FORNECE IN ("
		cQuery += "SELECT AA2.A2_COD FROM " + RetSqlName("SA2") + " AA2 "
		cQuery += "WHERE AA2.A2_FILIAL = '' AND AA2.A2_COD = SEF.E2_FORNECE AND AA2.A2_LOJA = SEF.E2_LOJA AND "
		cQuery += "(AA2.A2_CONTA BETWEEN '" + mv_par14 + "' AND '" + mv_par15 + "') AND AA2.D_E_L_E_T_ <> '*')"
	Endif
	cQuery += " ORDER BY  SEF.E2_FORNECE, SEF.E2_LOJA"
	cQuery := ChangeQuery(cQuery)
	MemoWrite('D:\LOGSQLFINR01A_365.txt',cQuery)

	If Select("SEF") > 0
		dbSelectArea("SEF")
		SEF->(dbCloseArea())
	EndIf

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SEF', .F., .T.)

	//+-----------------------------------------------------+
	//|Posicionamento do SE5 neste ponto que servira para   |
	//|pesquisa de descarte de registros geradores de       |
	//|desdobramento                                        |
	//+-----------------------------------------------------+
	DbSelectArea("SEF")
	SEF->(dbGotop())

	dbSelectArea("SE5")
	SE5->(dbSetOrder(7))	//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ

	While !SEF->(Eof())

		If SE5->(dbSeek(FWxFilial("SEF") + SEF->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))

			If AllTrim(SE5->E5_TIPODOC) == "BA" .AND. AllTrim(SE5->E5_MOTBX) == "DSD"
				SEF->(dbSkip())
				Loop
			Endif
		Endif


		//--------------------------------------------------------------
		// Verifica Centro de Custo do Títulos
		//--------------------------------------------------------------
		If SEF->E2_CCD < mv_par20 .OR. SEF->E2_CCD > mv_par21
			dbSelectArea("SEF")
			SEF->(dbSkip())
			Loop
		EndIf


		//+--------------------------------------------------------------+
		//| Verifica quais serao impressos                               |
		//+--------------------------------------------------------------+
		If mv_par06 == 2 .and. SEF->E2_TIPO $ MVPAGANT // So'Normais
			SEF->(dbSkip())
			Loop
		Endif

		If mv_par06 == 3 .and. !SEF->E2_TIPO $ MVPAGANT //So'Adiantamentos
			SEF->(dbSkip())
			Loop
		Endif

		//+-------------------------------------------------------------------------+
		//| Armazena Fornecedores em Variavel a ser trabalhada com Formatin         |
		//+-------------------------------------------------------------------------+

		nContFrn = nContFrn + 1
		If  nContFrn = 1
			cFrnAtual := cFrnAnt :=  LTRIM(RTRIM(SEF->E2_FORNECE))
			cfrn += LTRIM(RTRIM(SEF->E2_FORNECE))
		EndIf

		If  cFrnAtual <> cFrnAnt
			cFrnAnt := LTRIM(RTRIM(SEF->E2_FORNECE))
			cfrn += LTRIM(RTRIM(SEF->E2_FORNECE))
		EndIf

		dbSelectArea("SEF")
		SEF->(dbSkip())

		//Inclui separador na variavel que guarda os codigos de fornecedores

		cFrnAtual := LTRIM(RTRIM(SEF->E2_FORNECE))
		If  !SEF->(Eof()) .and. cFrnAtual <> cFrnANT
			cfrn += "/"
		EndIf


	Enddo

	DBSelectArea("SEF")
	SEF->(DbCloseArea())
	ChkFile("SEF")



	//***********************


	//+--------------------------------------------------------------+
	//| Localiza e grava titulos a pagar dentro dos parametros       |
	//+--------------------------------------------------------------+
	dbSelectArea("SE2")
	SE2->(dbSetOrder (6))

	If TcSrvType() != "AS/400"
		aStru:= SE2->(dbStruct())

		cQuery := "SELECT * FROM " + RetSqlName("SE2") + " WHERE"
		cIndE2	:=IndexKey()
		If mv_par07 == 1
			cQuery += " E2_FILIAL = '" + FWxFilial("SE2") + "' AND "
		else
			cQuery += " (E2_FILIAL BETWEEN '" + mv_par22 + "' AND '" + mv_par23 + "') AND"
			cIndE2 :=Right(cIndE2,Len(cIndE2)-10)
		endif
		cIndE2 := SqlOrder(cIndE2)

		dbSelectArea("SE2")
		SE2->(dbCloseArea())
		dbSelectArea("SA1")
		cQuery += " E2_FORNECE IN " + FORMATIN(cFrn,"/")
		cQuery += " AND E2_EMIS1 <= '" + DTOS(mv_par02)  + "'"
		cQuery += " AND E2_EMIS1 <= '" + DTOS(dDataBase) + "'"
		cQuery += " AND (E2_CCD  BETWEEN " + ValToSql(mv_par20) + " AND " + ValToSql(soma1(RTRIM(LTRIM(mv_par21)))) + ")"
		cQuery += " AND E2_TIPO NOT LIKE '"+MVPROVIS+"'"
		cQuery += " AND (E2_NATUREZ BETWEEN '" + mv_par08 + "' AND '" + mv_par09 + "')"
		cQuery += " AND D_E_L_E_T_ <> '*'"
		cQuery += " AND CASE "
		cQuery += "       WHEN E2_XTPTRF <> '' THEN E2_XTPTRF  "
		cQuery += "       ELSE '2' "
		cQuery += "      END = '2' "

		//+--------------------------------------------------------------+
		//| Verifica quais serao impressos                               |
		//+--------------------------------------------------------------+
		If mv_par06 == 2 // So'Normais
			cQuery += " And E2_TIPO NOT IN " + FORMATIN(MVPAGANT,"/")
		Endif

		If mv_par06 == 3 // So'Adiantamentos
			cQuery += " And E2_TIPO IN " + FORMATIN(MVPAGANT,"/")
		EndIf

		If !Empty(mv_par24)
			cQuery += " And E2_PREFIXO NOT IN " + FORMATIN(mv_par24,";")
		EndIf

		cQuery += " And E2_TIPO NOT IN " + FORMATIN(MVPROVIS,";")


		//+--------------------------------------------------------------+
		//| Verifica Fornecedores validos do intervalo de datas          |
		//+--------------------------------------------------------------+
		cQuery += "    AND E2_FORNECE IN (SELECT E2A.E2_FORNECE FROM " + RetSqlName("SE2") + " E2A "
		cQuery += "	           			  WHERE E2A.E2_FILIAL = E2_FILIAL AND "
		cQuery += "			  			   E2A.E2_PREFIXO = E2_PREFIXO AND "
		cQuery += "			 			   E2A.E2_NUM = E2_NUM AND   "
		cQuery += "		   				   E2A.E2_PARCELA = E2_PARCELA AND  "
		cQuery += "		  				   E2A.E2_TIPO = E2_TIPO AND    "
		cQuery += "				  		   E2A.E2_FORNECE = E2_FORNECE AND  "
		cQuery += "	   					   E2A.D_E_L_E_T_ <> '*' AND   "
		cQuery += "	   					   E2A.E2_LOJA = E2_LOJA AND   "
		cQuery += "	  					   E2A.R_E_C_N_O_ = R_E_C_N_O_  AND "
		cQuery += "	 					   E2A.E2_FORNECE IN (SELECT AA2.A2_COD FROM " + RetSqlName("SA2") + " AA2 "
		cQuery += "						                      WHERE AA2.A2_FILIAL = '' AND AA2.A2_COD = E2A.E2_FORNECE AND AA2.A2_LOJA = E2A.E2_LOJA AND "
		cQuery += "								              (AA2.A2_CONTA BETWEEN " + ValToSql(mv_par14) + " AND " + ValToSql(mv_par15) + ")   AND AA2.D_E_L_E_T_ <> '*'))"
		//+--------------------------------------------------------------+
		//| Le registros com data anterior a data inicial (para compor   |
		//| os saldos anteriores) ate a data final.                      |
		//+--------------------------------------------------------------+

		If mv_par13 == 1 	// Seleciona fornecedor por conta contabil
			cFilial := FWxFilial()
			cQuery += " AND E2_FORNECE IN ("
			cQuery += "SELECT SA2.A2_COD FROM " + RetSqlName("SA2") + " SA2 "
			cQuery += "WHERE SA2.A2_FILIAL = '' AND SA2.A2_COD = E2_FORNECE AND SA2.A2_LOJA = E2_LOJA AND "
			cQuery += "(SA2.A2_CONTA BETWEEN '" + mv_par14 + "' AND '" + mv_par15 + "') AND SA2.D_E_L_E_T_ <> '*')"
		Endif
		cQuery += " ORDER BY  E2_CCD, E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO"   // ORDEM CLASSIFICACAO ORIGINAL
		//		cQuery += " ORDER BY  E2_FORNECE, E2_LOJA, E2_CCD, E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO"
		cQuery := ChangeQuery(cQuery)
		MemoWrite('D:\LOGSQLFINR01A_465.txt',cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE2', .F., .T.)

		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField('SE2', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next

	EndIf

	//+-----------------------------------------------------+
	//|Posicionamento do SE5 neste ponto que servira para   |
	//|pesquisa de descarte de registros geradores de       |
	//|desdobramento                                        |
	//+-----------------------------------------------------+
	DbSelectArea("SE2")
	SE2->(dbGotop())

	dbSelectArea("SE5")
	SE5->(dbSetOrder(7))	//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ

	While !SE2->(Eof())

		If SE5->(dbSeek(FWxFilial("SE2") + SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))

			If AllTrim(SE5->E5_TIPODOC) == "BA" .AND. AllTrim(SE5->E5_MOTBX) == "DSD"
				SE2->(dbSkip())
				Loop
			Endif
		Endif

		If mv_par13 == 1 .And. !(TcGetDb() $ "MSSQL/MSSQL7/ORACLE")		// Seleciona fornecedores por conta contabil
			dbSelectArea("SA2")
			SA2->(MsSeek(""+SE2->E2_FORNECE+SE2->E2_LOJA))
			If SA2->A2_CONTA < mv_par14 .or. SA2->A2_CONTA > mv_par15
				dbSelectArea("SE2")
				SE2->(dbSkip())
				Loop
			Endif
		Endif

		//--------------------------------------------------------------
		// Verifica Centro de Custo do Títulos
		//--------------------------------------------------------------
		If SE2->E2_CCD < mv_par20 .OR. SE2->E2_CCD > mv_par21
			dbSelectArea("SE2")
			SE2->(dbSkip())
			Loop
		EndIf


		//+--------------------------------------------------------------+
		//| Verifica quais serao impressos                               |
		//+--------------------------------------------------------------+
		If mv_par06 == 2 .and. SE2->E2_TIPO $ MVPAGANT // So'Normais
			SE2->(dbSkip())
			Loop
		Endif

		If mv_par06 == 3 .and. !SE2->E2_TIPO $ MVPAGANT //So'Adiantamentos
			SE2->(dbSkip())
			Loop
		Endif

		//+--------------------------------------------------------------+
		//| Le registros com data anterior a data inicial (para compor   |
		//| os saldos anteriores) ate a data final                       |
		//| Verificar se a data de contabilizacao eh menor que o de      |
		//| emissao, caso seja considerar o de emissao                   |
		//+--------------------------------------------------------------+

		If IIf(SE2->E2_EMIS1 < SE2->E2_EMISSAO, SE2->E2_EMISSAO, SE2->E2_EMIS1) > mv_par02
			SE2->(dbSkip())
			Loop
		EndIf

		//+--------------------------------------------------------------+
		//| Grava debito no arquivo de trabalho                          |
		//+--------------------------------------------------------------+
		Reclock("cNomeArq",.t.)

		Replace FILIAL 	    With SE2->E2_FILIAL
		Replace CODIGO  	With SE2->E2_FORNECE
		Replace LOJA    	With SE2->E2_LOJA
		Replace DATAEM   	With IIf(SE2->E2_EMIS1 < SE2->E2_EMISSAO, SE2->E2_EMISSAO, SE2->E2_EMIS1)
		Replace NUMERO		With SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
		Replace TIPO    	With SE2->E2_TIPO
		Replace BANCO   	With SE2->E2_PORTADO
		Replace EMISSAO 	With SE2->E2_EMISSAO
		Replace VENCTO  	With SE2->E2_VENCREA

		//+--------------------------------------------------------------+
		//| Alterado por: Jonas Nascimento J2A - 27/10/2015			   	 |
		//| Motivo: Tratar títulos c/ retenções de impostos na baixa ou  |
		//| 		na emissão do título. A FIEG mudou a forma de reter  |
		//|			os impostos, antes era na baixa, porém agora é na    |
		//| 		emissão.				   							 |
		//+--------------------------------------------------------------+
		//Replace VALOR   	With SE2->E2_VLCRUZ
		nValliq := 	SE2->E2_VALOR

		Replace VALOR   	With nValliq - SE5->E5_VRETISS
		//FIM Jonas Nascimento J2A

		Replace MOEDA   	With SE2->E2_MOEDA
		Replace CCUSTO 		With SE2->E2_CCD

		Replace HISTOR  	With IIF(Empty(SE2->E2_HIST),OemToAnsi("Pela Emissao do Titulo"),SE2->E2_HIST)  //"Pela Emissao do Titulo"

		IF SE2->E2_TIPO$ MVPAGANT+"/"+MVABATIM+"/"+MV_CPNEG
			Replace DC     With "D"
		Else
			Replace DC     With "C"     //Abatimentos
		Endif

		If mv_par13 == 2
			If mv_par07 == 1
				Replace CONTA With GetAdvfVal("SA2","A2_CONTA",""+ SE2->(E2_FORNECE + E2_LOJA),1)
			Else
				Replace CONTA With FR550RetCF(SE2->E2_FORNECE, SE2->E2_LOJA, "A2_CONTA")
			Endif
		Endif
		cNomeArq->(MsUnlock())

		//Abatimentos que fizeram parte da fatura
		IF SE2->E2_TIPO $ MVABATIM .AND. !Empty(SE2->E2_FATURA) .AND. ;
		SE2->E2_FATURA != "NOTFAT" .AND. SE2->E2_DTFATUR <= mv_par02

			nValliq := 	SE2->E2_VALOR

			Reclock("cNomeArq",.t.)
			Replace FILIAL  With SE2->E2_FILIAL
			Replace CODIGO  With SE2->E2_FORNECE
			Replace LOJA    With SE2->E2_LOJA
			Replace DATAEM  With IIf(SE2->E2_EMIS1 < SE2->E2_EMISSAO, SE2->E2_EMISSAO, SE2->E2_EMIS1)
			Replace NUMERO  With SE2->E2_PREFIXO+SE2->E2_NUM+SE2->(E2_PARCELA+E2_TIPO)
			Replace TIPO    With SE2->E2_TIPO
			Replace BANCO   With SE2->E2_PORTADO
			Replace EMISSAO With SE2->E2_EMISSAO
			Replace VENCTO  With SE2->E2_VENCREA

			Replace VALOR   With nValliq

			Replace BAIXA   With SE2->E2_DTFATUR
			Replace HISTOR  With OemToAnsi("BX EMIS FAT ")+SE2->E2_FATURA  //"BX EMIS FAT "
			Replace DC      With "C"     //Baixa de Abatimento por emissao de fatura
			Replace CCUSTO 	With SE2->E2_CCD


			If mv_par13 == 2
				If mv_par07 == 1
					Replace CONTA With GetAdvfVal("SA2","A2_CONTA",xFilial("SA2") + SE2->(E2_FORNECE + E2_LOJA),1)
				Else
					Replace CONTA With FR550RetCF(SE2->E2_FORNECE, SE2->E2_LOJA, "A2_CONTA")
				Endif
			Endif
			cNomeArq->(MsUnlock())
		Endif

		//Gera movimentos de histórico em casos de retenção de pis, cofins e csll
		If lPCCBaixa .And. SE2->E2_TIPO $ MVPAGANT  //Verifico se eh PA para exibir tx's na emissao
			For nX:= 1 To Len(aImp10925)
				If &(aImp10925[nX][1]) > 0

					nValliq := &(aImp10925[nX][1])
					nValliq -=	(E2_JUROS + E2_MULTA + E5_CORREC - E5_DESCONT)

					Reclock("cNomeArq",.T.)
					Replace FILIAL 	    With SE2->E2_FILIAL
					Replace CODIGO 		With SE2->E2_FORNECE
					Replace LOJA		With SE2->E2_LOJA
					Replace DATAEM		With IIf(SE2->E2_EMIS1 < SE2->E2_EMISSAO, SE2->E2_EMISSAO, SE2->E2_EMIS1)
					Replace NUMERO 		With SE2->E2_PREFIXO+SE2->E2_NUM+SE2->(E2_PARCELA+E2_TIPO)
					Replace EMISSAO		With SE2->E2_EMISSAO

					Replace VALOR		With nValliq
					Replace HISTOR 		With "Desc.Imposto" + " - " + aImp10925[nX][2]
					Replace VENCTO		With SE2->E2_VENCREA
					Replace DC	  		With "D"
					Replace CCUSTO 		With SE2->E2_CCD

					If mv_par13 == 2
						If mv_par07 == 1
							Replace CONTA With GetAdvfVal("SA2","A2_CONTA","" + SE2->(E2_FORNECE + E2_LOJA),1)
						Else
							Replace CONTA With FR550RetCF(SE2->E2_FORNECE, SE2->E2_LOJA, "A2_CONTA")
						Endif
					Endif
					cNomeArq->(MsUnlock())
				Endif
			Next
		Endif

		dbSelectArea("SE2")
		SE2->(dbSkip())
	Enddo

	If TcSrvType() != "AS/400"
		DBSelectArea("SE2")
		SE2->(DbCloseArea())
		ChkFile("SE2")
	Endif

	//Ordeno Array de abatimentos de C.Receber
	If Len(aDadosAbat) > 0
		aSort(aDadosAbat,,,{|x,y| x[1]+x[2]+x[4] > y[1]+y[2]+y[4]})
	Endif

	//+--------------------------------------------------------------+
	//| Localiza na movimentacao bancaria, os titulos do periodo     |
	//+--------------------------------------------------------------+
	dbSelectArea("SE5")
	ChkFile("SE5",.F.,"NEWSE5")
	dbSelectArea("SE5")
	SE5->(dbSetOrder(7))

	If TcSrvType() != "AS/400"

		aStru := SE5->(dbStruct())

		cQuery := "SELECT * FROM ( "
		cQuery += "SELECT *,'XXXXX' AS TPMV FROM " + RetSqlName("SE5") + " WHERE"
		cIndE5	:=IndexKey()
		If mv_par07 == 1
			cQuery += " E5_FILIAL = '" + FWxFilial("SE5") + "' AND "
		else
			cQuery += " E5_FILIAL BETWEEN " + ValToSql(ValToSql(mv_par22)) + " AND " +ValToSql(ValToSql(mv_par23)) + " AND"
			cIndE5 :=Right(cIndE5,Len(cIndE5)-10)
		endif
		cIndE5 := SqlOrder(cIndE5)

		dbSelectArea("SE5")
		SE5->(dbCloseArea())
		dbSelectArea("SA1")

		cQuery += " E5_DTDIGIT <= '" + DTOS(mv_par02) + "'"
		cQuery += " AND E5_NUMERO <> '" +Space(TamSX3("E5_NUMERO")[1])+"'"
		cQuery += " AND E5_SITUACA    <> 'C'"
		cQuery += " AND E5_SITUACA    <> 'X'"
		cQuery += " AND E5_DTDIGIT    <= '"+DTOS(dDataBase)+ "'"
		//		cQuery += " AND (E5_CLIFOR BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "')"
		cQuery += " AND E5_CLIFOR IN " + FORMATIN(cFrn,"/")
		//		cQuery += " AND (E5_NATUREZ BETWEEN '" + mv_par08 + "' AND '" + mv_par09 + "')"
		cQuery += " AND E5_TIPODOC IN ('VL','VM','BA','CP','LJ','V2','ES','RA')"
		cQuery += " AND D_E_L_E_T_ <> '*'"

		cQuery += " AND ((E5_RECPAG = 'P' AND E5_TIPODOC <> 'ES')"

		cQuery += " OR  (E5_TIPODOC = 'ES' AND E5_RECPAG = 'R')"
		cQuery += " OR (E5_TIPO IN (" + FR550VldVar(MV_CPNEG) + ",'"+MVPAGANT+"')))"


		// Tratamento para restringir os registros da query do SE5 aos que possuam seus respectivos SE1 ou SE2
		If TcGetDb() $ "MSSQL/MSSQL7/ORACLE"

			cQuery += "AND EXISTS ("

			cQuery += " SELECT SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA FROM "+RetSqlName("SE1")+" SE1, "+RetSqlName("SE5")+" SE5 WHERE "
			cQuery += " SE1.E1_FILIAL = SE5.E5_FILIAL AND "
			cQuery += " SE1.E1_PREFIXO = SE5.E5_PREFIXO AND "
			cQuery += " SE1.E1_NUM = SE5.E5_NUMERO AND "
			cQuery += " SE1.E1_PARCELA = SE5.E5_PARCELA AND "
			cQuery += " SE1.E1_TIPO	= SE5.E5_TIPO AND "
			cQuery += " SE1.E1_CLIENTE = SE5.E5_CLIFOR AND "
			cQuery += " SE1.E1_LOJA = SE5.E5_LOJA "
			cQuery += " UNION "
			cQuery += " SELECT SE2.E2_FILIAL, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA, SE2.E2_TIPO, SE2.E2_FORNECE, SE2.E2_LOJA FROM "+RetSqlName("SE2")+" SE2, "+RetSqlName("SE5")+" SE5 WHERE "
			cQuery += " SE2.E2_FILIAL = SE5.E5_FILIAL AND "
			cQuery += " SE2.E2_PREFIXO = SE5.E5_PREFIXO AND "
			cQuery += " SE2.E2_NUM = SE5.E5_NUMERO AND "
			cQuery += " SE2.E2_PARCELA = SE5.E5_PARCELA AND "
			cQuery += " SE2.E2_TIPO	= SE5.E5_TIPO AND "
			cQuery += "	SE2.E2_XTPTRF = '' AND   "
			cQuery += " SE2.E2_FORNECE = SE5.E5_CLIFOR AND "
			cQuery += " SE2.E2_LOJA	= SE5.E5_LOJA"

			cQuery += ") "

		Endif

		If .NOT. Empty(mv_par24)
			cQuery += " AND E5_PREFIXO NOT IN " + FORMATIN(mv_par24,";")
		EndIf

		cQuery += ") TP "
		//		cQuery += " ORDER BY  E5_FORNECE, E5_LOJA, E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO"
		cQuery += " ORDER BY " + cIndE5

		cQuery := ChangeQuery(cQuery)
		MemoWrite('D:\LOGSQLFINR01A_775.txt',cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE5', .F., .T.)

		For ni := 1 to Len(aStru)
			If aStru[ni,2] != 'C'
				TCSetField('SE5', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
			Endif
		Next
	EndIf

	If mv_par07 == 2
		dbSelectArea("SE2")
		SE2->(dbSetOrder(1))
		cArqTrab :=CriaTrab(NIL,.F.)
		aAdd(aInd,cArqTrab)
		cIndE2   :=IndexKey()
		cIndE2   :=Right(cIndE2,Len(cIndE2)-10)
		IndRegua("SE2",cArqTrab,cIndE2,,,OemToAnsi("Selecionando Registros..."))  //"Selecionando Registros..."
		dbCommit()
		nIndexSE2:=RetIndex("SE2")
		dbSelectArea("SE2")
		SE2->(dbSetOrder(nIndexSE2+1))
		SE2->(dbGotop())
	EndIf

	dbSelectArea("SE5")

	While !SE5->(Eof())

		// Tratamento das consistencias dos registros do SE5 quando o mesmo
		// não for tratado por Query

		If !ValidSE5()
			SE5->(dbSkip())
			Loop
		Endif

		dbSelectArea("SE5")

		If SE5->E5_RECPAG == "P"
			//+--------------------------------------------------------------+
			//| Verifica quais serao impressos                               |
			//+--------------------------------------------------------------+
			If mv_par06 == 2 .and. E5_TIPO $ MVPAGANT  // So'Normais
				SE5->(DbSkip())
				Loop
			Endif

			If mv_par06 == 3 .and. !E5_TIPO $ MVPAGANT // So'Adiantamentos
				SE5->(DbSkip())
				Loop
			Endif

			//+--------------------------------------------------------------+
			//| Ignora PA's pagos com Junta de Cheque                        |
			//+--------------------------------------------------------------+
			If E5_TIPO $ MVPAGANT .and. E5_TIPODOC == "BA" .And. !E5_MOTBX $ "CMP"
				SE5->(DbSkip())
				Loop
			Endif
		Endif

		IF SE5->E5_RECPAG != "P"
			If (!( SE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG ) .AND. SE5->E5_TIPODOC !="ES") .or.;   //Baixa de PA
			(SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG .AND. SE5->E5_TIPODOC =="ES") .or. ; //Estorno da Baixa de RA
			(( SE5->E5_TIPO $ MVPAGANT) .AND. mv_par06 == 2).or. ;
			(!(SE5->E5_TIPO $ MVPAGANT) .AND. mv_par06 == 3)
				SE5->(dbSkip())
				Loop
			Endif
		Endif

		//+-----------------------------------------------------------+
		//| Retirar registros "VL" gerados pelo Loja , e podem gerar
		//  duplicidade de baixa no relatorio                         |
		//+-----------------------------------------------------------+
		If SubStr(SE5->E5_HISTOR,1,3) == "LOJ" .AND. AllTrim(SE5->E5_TIPODOC) == "VL"
			SE5->(dbSkip())
			Loop
		EndIf

		//-------------------------------------------------------------------------------
		//-- Desconsiderar baixa desdobramento e transferencia de título entre filial
		//-------------------------------------------------------------------------------
		//		If AllTrim(SE5->E5_TIPODOC) == "BA" .AND. AllTrim(SE5->E5_MOTBX) $ "DSD/TEF"
		If AllTrim(SE5->E5_TIPODOC) == "BA" .AND. (AllTrim(SE5->E5_MOTBX) == "DSD" .OR. AllTrim(SE5->E5_MOTBX) == "TEF")
			SE5->(dbSkip())
			Loop
		Endif

		//-- Se for baixa de adiantamentos
		If SE5->E5_RECPAG == "P" .and. SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG .AND. SE5->E5_TIPODOC $ "VL/BA/DC/D2/MT/JR/J2/M2/CM/C2/CX"
			SE5->(dbSkip())
			Loop
		EndIf


		//+------------------------------------------------------------+
		//| Não considera registro de estorno de compensação de cheques|
		//+------------------------------------------------------------+
		If SE5->E5_TIPODOC = "ES" .And. SE5->E5_RECPAG = "P"
			aAreaSE5 := SE5->(GetArea())
			dbSelectArea("NEWSE5")
			NEWSE5->(dbSetOrder(2))
			If NEWSE5->(MsSeek(xFilial("SE5")+"CH"+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)))
				SE5->(dbSkip())
				Loop
			EndIf
			RestArea(aAreaSE5)
		EndIf

		//+-----------------------------------------------------------+
		//| Localiza o cliente ou fornecedor                          |
		//+-----------------------------------------------------------+
		cCarteira := SE5->E5_RECPAG
		If SE5->E5_RECPAG == "R"
			If ((SE5->E5_TIPO$MVPAGANT+"/"+MV_CPNEG));
			.OR. ((!SE5->E5_TIPO$MVRECANT+"/"+MV_CRNEG+"/"+MVPAGANT+"/"+MV_CPNEG) .And. SE5->E5_TIPODOC =="ES")
				cCarteira := "P"        //Baixa de adiantamento (inverte)
			Endif
		Endif

		If SE5->E5_RECPAG == "P"
			If ((SE5->E5_TIPO$MVRECANT+"/"+MV_CRNEG));
			.OR. ((!SE5->E5_TIPO$MVRECANT+"/"+MV_CRNEG+"/"+MVPAGANT+"/"+MV_CPNEG) .And. SE5->E5_TIPODOC =="ES")
				cCarteira := "R"        //Baixa de adiantamento (inverte)
			Endif
		Endif

		IF cCarteira == "R"
			dbSelectArea("SE1")
			If mv_par07 = 1
				SE1->(dbSetOrder(1))
				SE1->(dbSeek(xFilial()+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO))
			Else
				SE1->(dbSetOrder(nIndexSE1+1))
				SE1->(dbSeek(SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO))
			EndIf
			//Caso nÆo ache o registro no SE1, nÆo considero os movimentos
			If !Found()
				dbSelectArea("SE5")
				SE5->(dbSkip())
				Loop
			Else
				If mv_par13 == 1		// Seleciona clientes por conta contabil
					dbSelectArea("SA1")
					SA1->(MsSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA))
					If SA1->A1_CONTA < mv_par14 .or. SA1->A1_CONTA > mv_par15
						dbSelectArea("SE5")
						SE5->(dbSkip())
						Loop
					Endif
				Endif

				//--------------------------------------------------------------
				// Verifica Centro de Custo do Títulos
				//--------------------------------------------------------------
				If SE2->E2_CCD < mv_par20 .OR. SE2->E2_CCD > mv_par21
					dbSelectArea("SE5")
					SE5->(dbSkip())
					Loop
				EndIf

			Endif
		Else
			dbSelectArea("SE2")
			If  (mv_par07 == 1  .OR. SE5->TPMV == 'BXTRF')
				SE2->(dbSetOrder(1))
				SE2->(dbSeek(SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA))

				//			dbSeek(FWxFilial("SE5")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA)

			Else
				SE2->(dbSetOrder(nIndexSE2+1))
				SE2->(dbSeek(SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA))
			Endif
			//Caso nÆo ache o registro no SE2, nÆo considero os movimentosa
			If !Found()
				dbSelectArea("SE5")
				SE5->(dbSkip())
				Loop
			Else
				If mv_par13 == 1		// Seleciona fornecedores por conta contabil
					dbSelectArea("SA2")
					SA2->(MsSeek(xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA))
					If SA2->A2_CONTA < mv_par14 .or. SA2->A2_CONTA > mv_par15
						dbSelectArea("SE5")
						SE5->(dbSkip())
						Loop
					Endif
				Endif

				//--------------------------------------------------------------
				//--
				//--------------------------------------------------------------
				If (SE5->TPMV == 'BXTRF')
					If mv_par07 == 1
						_bFilDes:= {|| FWxFilial("SE2") # SE2->E2_XFILDES }
					Else
						_bFilDes:= {|| SE2->E2_XFILDES < mv_par22  .OR.  SE2->E2_XFILDES > mv_par23 }
					Endif

					If Eval(_bFilDes)
						dbSelectArea("SE5")
						SE5->(dbSkip())
						Loop
					EndIf
				EndIf

				//--------------------------------------------------------------
				// Verifica Centro de Custo do Títulos
				//--------------------------------------------------------------
				If SE2->E2_CCD < mv_par20 .OR. SE2->E2_CCD > mv_par21
					dbSelectArea("SE5")
					SE5->(dbSkip())
					Loop
				EndIf

			Endif
		Endif
		dbSelectArea("SE5")

		nValliq := 	E5_VALOR
		nValliq -=	(E5_VLJUROS + E5_VLMULTA + E5_VLCORRE - E5_VLDESCO)


		IF cCarteira == "R"
			dEmissao := SE1->E1_EMISSAO
			dVencto  := SE1->E1_VENCREA
		Else
			dEmissao := SE2->E2_EMISSAO
			dVencto  := SE2->E2_VENCREA
		Endif

		aDados[1] := E5_CLIFOR
		aDados[2] := E5_LOJA
		aDados[3] := E5_DTDIGIT
		aDados[4] := E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO
		aDados[5] := E5_BANCO
		aDados[6] := E5_DATA
		aDados[7] := E5_HISTOR
		aDados[8] := E5_RECPAG
		aDados[9] := E5_TIPO
		aDados[10]:= E5_TIPODOC
		aDados[11]:= nValliq

		IF cCarteira == "R"
			aDados[12]:= SE1->E1_CCC
			aDados[14]:= Posicione("SA1",1,FR01AFil("SA1",E5_FILIAL)+E5_CLIFOR+E5_LOJA,"A1_CONTA")
		Else
			aDados[12]:= SE2->E2_CCD
			aDados[14]:= Posicione("SA2",1,FR01AFil("SA2",E5_FILIAL)+E5_CLIFOR+E5_LOJA,"A2_CONTA")
		EndIF

		aDados[13]:= (SUBSTRING(SE2->E2_FILIAL,1,4)+'0001') // EMPRESA

		If (lPccBaixa )
			aDados[15]:= E5_PRETPIS
			aDados[16]:= E5_PRETCOF
			aDados[17]:= E5_PRETCSL

			aDados[18]:= E5_VRETPIS
			aDados[19]:= E5_VRETCOF
			aDados[20]:= E5_VRETCSL
		Endif

		nValliq := 	E5_VALOR
		nValliq -=	(E5_VLJUROS + E5_VLMULTA + E5_VLCORRE - E5_VLDESCO)

		If E5_TIPODOC == "VM" // Correcao Monetaria

			If nValliq > 0
				cTipo  := "C"
			Else
				If E5_TIPO $ MVRECANT+"/"+MV_CRNEG+"/"+MVPAGANT+"/"+MV_CPNEG
					cTipo  := "D"
				Else
					cTipo  := "C"
				Endif
			Endif

			GravaTrab(cTipo,dEmissao,dVencto,nValliq,aDados,aDadosAbat,,.T., @nBuffer)  // Registro principal
		Else
			// 31/10/2016 - Thiago Rasmussen - Incluir o saldo inicial do fornecedor.
			IF aDadosInicial[1] != E5_CLIFOR
				nValor := Posicione("ZZ2",1,aDados[13]+aDados[1]+aDados[12],"ZZ2_VALOR")
				IF nValor <> 0.00
					aDadosInicial[01] := aDados[1]
					aDadosInicial[02] := aDados[2]
					aDadosInicial[03] := CTOD('31/12/2012')
					aDadosInicial[04] := ''
					aDadosInicial[05] := ''
					aDadosInicial[06] := CTOD('31/12/2012')
					aDadosInicial[07] := 'Ajuste de Saldo'
					aDadosInicial[08] := IIF(nValor > 0.00, 'R', 'P')
					aDadosInicial[09] := ''
					aDadosInicial[10] := ''
					aDadosInicial[11] := ABS(nValor)
					aDadosInicial[12] := aDados[12]
					aDadosInicial[13] := aDados[13]
					aDadosInicial[14] := aDados[14]
					GravaTrab("B",CTOD('31/12/2012'),CTOD('31/12/2012'),ABS(nValor),aDadosInicial,aDadosAbat,.T.,, @nBuffer)  // Registro principal
				ENDIF
			ENDIF

			GravaTrab("B",dEmissao,dVencto,nValliq,aDados,aDadosAbat,.T.,, @nBuffer)  // Registro principal
		Endif
		If mv_par05 == 1  // Imprime valor financeiro
			For nX := 1 to 4
				DO CASE
					CASE nX == 1
					cCampo := "E5_VLJUROS"
					cTipo  := "J"
					aDados[7] := "Juros s/ Baixa"
					CASE nX == 2
					cCampo := "E5_VLMULTA"
					cTipo  := "M"
					aDados[7] := "Multa s/ Baixa"
					CASE nX == 3
					cCampo := "E5_VLDESCO"
					cTipo  := "D"
					aDados[7] := "Desconto s/ Baixa"
					CASE nX == 4
					cCampo := "E5_VLCORRE"
					If &(cCampo) > 0
						cTipo  := "C"
					Else
						cTipo  := "D"
					Endif
					aDados[7] := "C.Monetaria s/ Baixa" //"C.Monetaria s/ Baixa"
				ENDCASE
				If &(cCampo) > 0 .or. (cCampo == "E5_VLCORRE" .and. &(cCampo) != 0)  //Correcao pode ter valor negativo
					GravaTrab(cTipo,dEmissao,dVencto,&(cCampo),aDados,aDadosAbat,,(cCampo == "E5_VLCORRE"),@nBuffer)  // Registro principal
				Endif
			Next
		Endif
		dbSelectArea("SE5")
		SE5->(dbSkip())
	End

	If TcSrvType() != "AS/400"
		DBSelectArea("SE5")
		SE5->(DbCloseArea())
		ChkFile("SE5")
	EndIf

	//+--------------------------------------------------------------+
	//| Inicia rotina de impressao                                   |
	//+--------------------------------------------------------------+
	oEntida:Init()
	oFornec:Init()
	oSection1:Init()
	oSection2:Init()

	aFill(aSec1,nil)
	aFill(aSec2,nil)

	dbSelectArea("cNomeArq")
	If mv_par19 == 2 .OR. mv_par13 == 1	//Se usa filtro por conta ou nao aglutina por loja
		IndRegua("cNomeArq",cNomeArq,"CCUSTO+CODIGO+LOJA+Dtos(DATAEM)+Numero",,,OemToAnsi("Selecionando Registros..."))  		//"Selecionando Registros..."
	Else
		If mv_par19 = 1
			IndRegua("cNomeArq",cNomeArq,"CCUSTO+CODIGO+Dtos(DATAEM)+Numero",,,OemToAnsi("Selecionando Registros..."))
		Else
			IndRegua("cNomeArq",cNomeArq,"CCUSTO+CODIGO+LOJA+Dtos(DATAEM)+Numero",,,OemToAnsi("Selecionando Registros..."))
		EndIf
	Endif

	cNomeArq->(dbGoTop())
	nTotDebG := 0
	nTotCrdG := 0
	nSalAtuG := 0
	cCusto   := ""

	While cNomeArq->(!Eof())

		//Se o parametro de filtro por conta contabil estiver marcado como SIM, a opcao de aglutinar por loja sera desconsiderado
		If mv_par19 == 2 .OR. mv_par13 == 1
			cCodigo	:= CODIGO
			cLoja	:= LOJA
			nSaldoAtu:= 0
			nTotDeb	:= 0
			nTotCrd	:= 0

			nRegAtu := Recno()
			lImprime := .F.

			While cNomeArq->CODIGO == cCodigo .And. cNomeArq->LOJA == cLoja .And. cNomeArq->(! Eof())
				If DATAEM >= mv_par01     	// Procura titulos no intervalo e
					lImprime := .T.     	// se houver, deverá imprimir
					Exit
				EndIf
				cNomeArq->(dbSkip())
			EndDo

			cNomeArq->(dbGoto(nRegAtu))
			cConta := ""

			If Empty(cCusto) .AND. .Not. Empty(cNomeArq->CCUSTO)
				cCusto:= cNomeArq->CCUSTO
				lImpCCust := .T.
			ElseIf cCusto # cNomeArq->CCUSTO
				lImpTotCC := .T.
				lImpCCust := .T.
				cCusto:= cNomeArq->CCUSTO
			EndIf

			While cCusto == cNomeArq->CCUSTO .And. cNomeArq->CODIGO == cCodigo .And. cNomeArq->LOJA == cLoja .And. cNomeArq->(! Eof())

				//+--------------------------------------------------------------+
				//| Loop para calculo do saldo anterior                          |
				//+--------------------------------------------------------------+
				While cNomeArq->CODIGO == cCodigo .And. cNomeArq->LOJA == cLoja .And.;
				cNomeArq->DATAEM < mv_par01 .And. cNomeArq->(!Eof()) .And. (mv_par16 == 1 .or. lImprime)
					nValorAbs := ABS(cNomeArq->VALOR)

					If DC == "C"
						nSaldoAtu += nValorAbs
					Else
						nSaldoAtu -= nValorAbs
					EndIf
					cNomeArq->(dbSkip())
					If cNomearq->CODIGO != ccodigo .Or. cNomeArq->LOJA != cLoja
						lNoSkip := .T.
					Endif
				Enddo

				If lImprime .Or. nSaldoAtu != 0
					If cAuxFoot = "A TRANSPORTAR"

						If nQuebra == 1

							FR01ASA(cNomeArq->CODIGO,cNomeArq->LOJA,, @cNome, @cConta)


							If mv_par10 == 1   // Analitico

								//---------------------------
								//-- Fornecedor
								//---------------------------
								oFornec:PrintLine()
								oReport:SkipLine()

								dbSelectArea("cNomeArq")
								aSec1[S1_HISTORICO]	:= "DE TRANSPORTE : "
								aSec1[S1_SALDO_ATU]	:= Abs(nSaldoAtu)
								aSec1[S1_DIGITO]		:= Eval(bBlockDC,nSaldoAtu)
								F550Print(oReport,If(Len(Trim(HISTOR))>20,.T.,.F.),aSec1)
								aFill(aSec1,nil)
							EndIf
						EndIf
						cAuxFoot = "X"
					Endif
				EndIf

				If nQuebra == 0 .and. (lImprime .Or. nSaldoAtu != 0 )
					nQuebra  := 1
					lImprAnt := .F.

					If lImpTotCC
						If (Abs(nSalAtuCc)+Abs(nTotDebCc)+Abs(nTotCrdCc))>0
							//-------------------------------------
							//-- Total por C. Custo
							//-------------------------------------
							aSec2[S2_DESCRICAO] := "T o t a l  p o r  C e n t r o  d e  C u s t o"

							aSec2[S2_SD_ANTERIOR]:= (Abs(nSalAtuCc)-Abs(nTotCrdCc)+Abs(nTotDebCc))
							aSec2[S2_DIG1] := Eval(bBlockDC,(Abs(nSalAtuCc)-Abs(nTotCrdCc)+Abs(nTotDebCc)))
							aSec2[S2_DEB]  := nTotDebCc
							aSec2[S2_CRED] := nTotCrdCc
							aSec2[S2_SD_ATUAL] := Abs(nSalAtuCc)
							aSec2[S2_DIG2] := Eval(bBlockDC,nSalAtuCc)
							If mv_par10 == 1 .or. (mv_par25 == 2 .and. nSalAtuCc != 0 .and. (nTotDebCc != 0 .or. nTotCrdCc != 0)) .or. mv_par25 == 1
								oSection2:PrintLine()
								oReport:ThinLine()
								oReport:SkipLine()
							EndIf
							aFill(aSec2,nil)
							nSalAtuCc:=nTotCrdCc:=nTotDebCc:=0
						EndIf
						lImpTotCC:= .F.
					EndIf

					//-------------------------------------
					//-- Imp. C.custo.
					//-------------------------------------
					If lImpCCust
						oEntida:PrintLine()
						oReport:SkipLine()
						lImpCCust:= .F.
					EndIf

					//		FR01ASA(cNomeArq->CODIGO, cNomeArq->LOJA,, @cNome, @cConta)
					FR01ASA(ccodigo,cLoja,, @cNome, @cConta)

					If mv_par10 == 1  // Analitico

						//---------------------------
						//-- Fornecedor
						//---------------------------
						oFornec:PrintLine()
						oReport:SkipLine()

						dbSelectArea("cNomeArq")
						aSec1[S1_HISTORICO] := " ******* SALDO ANTERIOR ******* "
						aSec1[S1_SALDO_ATU] := Abs(nSaldoAtu)
						aSec1[S1_DIGITO]	:= Eval(bBlockDC,nSaldoAtu)
						F550Print(oReport,If(Len(Trim(HISTOR))>20,.T.,.F.),aSec1)
						aFill(aSec1,nil)

						nSalAntG += nSaldoAtu
						nSalAtuCc+= nSaldoAtu
					Else
						aSec2[S2_DESCRICAO]		:= Substr(cCodigo + "/" + cLoja + " " + cNome,1,125)
						aSec2[S2_SD_ANTERIOR] 	:= Abs(nSaldoAtu)
						aSec2[S2_DIG1] 			:= Eval(bBlockDC,nSaldoAtu)
						nSalAntG += nSaldoAtu
						nSalAtuCc+= nSaldoAtu
					Endif
				EndIf

				dbSelectArea("cNomeArq")

				If cNomeArq->DATAEM >= mv_par01 .And. !lNoSkip
					If FR550TOT()
						nValorAbs := ABS(cNomeArq->VALOR)
						If DC == "D"
							nSaldoAtu -= nValorAbs
							nTotDeb   += nValorAbs
							nTotDebG  += nValorAbs
							nSalAtuG  -= nValorAbs

							//-- C.Custo
							nTotDebCc += nValorAbs
							nSalAtuCc -= nValorAbs
						Else
							nSaldoAtu += nValorAbs
							nTotCrd   += nValorAbs
							nTotCrdG  += nValorAbs
							nSalAtuG  += nValorAbs

							//-- C.Custo
							nTotCrdCc += nValorAbs
							nSalAtuCc += nValorAbs
						End
					EndIf
					If mv_par10 == 1  // Analitico

						aSec1[S1_DAT] := cNomeArq->DATAEM
						If OemToAnsi("Recibo")$ cNomeArq->HISTOR  //"Recibo"/"Receipt"
							aSec1[S1_HISTORICO] := If(mv_par18=1,Substr(cNomeArq->HISTOR, At(OemToAnsi("Recibo"),cNomeArq->HISTOR),20),HISTOR)
						Else
							aSec1[S1_HISTORICO] := If(mv_par18=1,SubStr(cNomeArq->HISTOR,1,20),cNomeArq->HISTOR)
						EndIf
						aSec1[S1_TITULO] := SubStr(NUMERO, 1,3) + " " + SubStr(cNomeArq->NUMERO, 4,nTamNro) + " " + SubStr(cNomeArq->NUMERO,nTamNro+4,nTamParc) + " " +  SubStr(cNomeArq->NUMERO,nTamNro+nTamParc+4,nTamTipo)
						aSec1[S1_EMISSAO] := cNomeArq->EMISSAO
						aSec1[S1_VENCIMENTO] := cNomeArq->VENCTO
						IF !Empty(BAIXA)
							aSec1[S1_BAIXA] := cNomeArq->BAIXA
						EndIf
						nValorAbs := ABS(cNomeArq->VALOR)
						If DC=="D"
							aSec1[S1_DEBITO] := nValorAbs
						Else
							aSec1[S1_CREDITO] := nValorAbs
						EndIf
						aSec1[S1_SALDO_ATU] := Abs(nSaldoAtu)
						aSec1[S1_DIGITO] := Eval(bBlockDC,nSaldoAtu)
						F550Print(oReport,If(Len(Trim(HISTOR))>20,.T.,.F.),aSec1)
						aFill(aSec1,nil)
					Endif
				EndIf
				lFlag := .T.
				If ! lNoSkip
					cNomeArq->(dbSkip())
				EndIf
				lNoSkip := .F.

			End
		Endif

		If lImprime .Or. nSaldoAtu != 0
			If mv_par10 == 1		// Analitico
				//				oReport:SkipLine()
				aSec2[S2_DESCRICAO] := "T o t a l  p o r  F o r n e c e d o r"
			Endif

			aSec2[S2_SD_ANTERIOR]:= (Abs(nSaldoAtu)-Abs(nTotCrd)+Abs(nTotDeb))
			aSec2[S2_DIG1] := Eval(bBlockDC,(Abs(nSaldoAtu)-Abs(nTotCrd)+Abs(nTotDeb)))
			aSec2[S2_DEB] 	:= nTotDeb
			aSec2[S2_CRED] := nTotCrd
			aSec2[S2_SD_ATUAL] := Abs(nSaldoAtu)
			aSec2[S2_DIG2] := Eval(bBlockDC,nSaldoAtu)
			If mv_par10 == 1 .or. (mv_par25 == 2 .and. nSaldoAtu != 0 .and. (nTotDeb != 0 .or. nTotCrd != 0)) .or. mv_par25 == 1
				oSection2:PrintLine()
				oReport:ThinLine()
			EndIf
			aFill(aSec2,nil)

		Endif
		nQuebra:=0
	EndDo


	If (Abs(nSalAtuCc)+Abs(nTotDebCc)+Abs(nTotCrdCc))>0
		//-------------------------------------
		//-- Total por C. Custo
		//-------------------------------------
		aSec2[S2_DESCRICAO] := "T o t a l  p o r  C e n t r o  d e  C u s t o"

		aSec2[S2_SD_ANTERIOR]:= (Abs(nSalAtuCc)-Abs(nTotCrdCc)+Abs(nTotDebCc))
		aSec2[S2_DIG1] := Eval(bBlockDC,(Abs(nSalAtuCc)-Abs(nTotCrdCc)+Abs(nTotDebCc)))
		aSec2[S2_DEB]  := nTotDebCc
		aSec2[S2_CRED] := nTotCrdCc
		aSec2[S2_SD_ATUAL] := Abs(nSalAtuCc)
		aSec2[S2_DIG2] := Eval(bBlockDC,nSalAtuCc)
		If mv_par10 == 1 .or. (mv_par25 == 2 .and. nSalAtuCc != 0 .and. (nTotDebCc != 0 .or. nTotCrdCc != 0)) .or. mv_par25 == 1
			oSection2:PrintLine()
			oReport:ThinLine()
		EndIf
		aFill(aSec2,nil)
		nSalAtuCc:=nTotCrdCc:=nTotDebCc:=0
	EndIf

	If lFlag
		oReport:SkipLine()
		oReport:ThinLine()
		nSaldoFinal := (nSalAntG-nTotDebG+nTotCrdG)
		aSec2[S2_DESCRICAO] := "T o t a l  G e r a l  F o r n e c e d o r e s"
		aSec2[S2_SD_ANTERIOR] := nSalAntG
		aSec2[S2_DIG1] := Eval(bBlockDC,nSalAntG)
		aSec2[S2_DEB] := nTotDebG
		aSec2[S2_CRED] := nTotCrdG
		aSec2[S2_SD_ATUAL] := Abs(nSaldoFinal)
		aSec2[S2_DIG2] := Eval(bBlockDC,nSaldoFinal)
		oSection2:PrintLine()
		aFill(aSec2,nil)

		nSaldoFinal := (nSalAntG-nTotDebG+nTotCrdG)

		oReport:ThinLine()
		aSec2[S2_DESCRICAO] := 	"S a l d o  F i n a l  d o  R e l a t o r i o"
		aSec2[S2_SD_ATUAL] := Abs(nSaldoFinal)
		aSec2[S2_DIG2] := Eval(bBlockDC,nSaldoFinal)
		oSection2:PrintLine()
		aFill(aSec2,nil)
		oReport:ThinLine()
	End


	oEntida:Finish()
	oFornec:Finish()
	oSection1:Finish()
	oSection2:Finish()


	dbSelectArea("cNomeArq")
	Use
	Ferase(cNomeArq+GetDBExtension())	// Elimina arquivos de Trabalho
	Ferase(cNomeArq+OrdBagExt())    // Elimina arquivos de Trabalho

	dbSelectArea("SA1")
	RetIndex("SA1")
	SA1->(dbSetOrder(1))
	Set Filter To

	dbSelectArea("SA2")
	RetIndex("SA2")
	SA2->(dbSetOrder(1))
	Set Filter To


	If TcSrvType() != "AS/400"
		dbSelectArea("SE1")
		SE1->(dbCloseArea())
		ChKFile("SE1")
		dbSelectArea("SE1")
		SE1->(dbSetOrder(1))

		dbSelectArea("SE2")
		SE2->(dbCloseArea())
		ChKFile("SE2")
		dbSelectArea("SE2")
		SE2->(dbSetOrder(1))

		dbSelectArea("SE5")
		SE5->(dbCloseArea())
		ChKFile("SE5")
		dbSelectArea("SE5")
		SE5->(dbSetOrder(1))

		dbSelectArea("SEF")
		SEF->(dbCloseArea())
		ChKFile("SEF")
		dbSelectArea("SEF")
		SEF->(dbSetOrder(1))
	EndIF

	NEWSE5->(dbCloseArea())

	For nI := 1 to Len(aInd)
		If Select(aInd[nI]) # 0
			dbSelectArea(aInd[nI])
			(aInd[nI])->(dbCloseArea())
			If File(aInd[nI] + OrdBagExt())
				fErase(aInd[nI] + OrdBagExt())
				fErase(aInd[nI] + GetDbExtension())
			Endif
		Endif
	Next

	DBUNLOCKALL()

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} F550Rodape
Rotina de impressao dos totais na quebra da pagina R4.

@type function
@author Daniel Tadashi Batori
@since 24/08/2006
@version P12.1.23

@param oReport, Objeto, Objeto que representa o relatório.
@param nSaldoTra, Numérico, Compatibilidade.
@param cDigito, Caractere, Compatibilidade.
@param aSec1, Array, Compatibilidade.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function F550Rodape(oReport,nSaldoTra,cDigito,aSec1)

	//Local oSection1 := oReport:Section(3)
	//	oReport:SkipLine()
	//	oReport:PrintText("A TRANSPORTAR: "+Transform(Abs(nSaldoTra),tm(Abs(nSaldoTra),14))+" "+cDigito,,oSection1:Cell("CREDITO"):ColPos())

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} F550Print
Impressao da secao um, respeitando parametro mv_par18.

@type function
@author Marcel Borges Ferreira
@since 07/11/2006
@version P12.1.23

@param oReport, Objeto, Objeto que representa o relatório.
@param lQuebra, Lógico, Indica se há quebra.
@param aSec1, Array, Array com os dados da seção.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function F550Print(oReport,lQuebra,aSec1)

	Local oSection1 := oReport:Section(3)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If mv_par18 == 2 .And. lQuebra

		oSection1:PrintLine()

	Else

		// Faz tratamento para celulas com conteudo em branco - impressao em planilha Excel.
		F550ValExcel( oSection1, "E1_EMISSAO"	, aSec1[S1_EMISSAO]		, .F. )
		F550ValExcel( oSection1, "DEBITO"		, aSec1[S1_DEBITO]		, .F. )
		F550ValExcel( oSection1, "CREDITO"		, aSec1[S1_CREDITO]		, .F. )

		oSection1:PrintLine()

		F550ValExcel( oSection1, "E1_EMISSAO"	, aSec1[S1_EMISSAO]		, .T. )
		F550ValExcel( oSection1, "DEBITO"		, aSec1[S1_DEBITO]		, .T. )
		F550ValExcel( oSection1, "CREDITO"		, aSec1[S1_CREDITO]		, .T. )

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} F550LinPag
Faz a quebra de pagina de acordo com o parametro "Linhas por Pagina?" (mv_par17).

@type function
@author Marcio Menon
@since 30/04/2008
@version P12.1.23

@param nLinPag, Numérico, N+mero maximo de linhas definido no relatorio.
@param nLinReport, Numérico, Contador de linhas impressas no relatorio.
@param oReport, Objeto, Objeto que representa o reltório.
@param nSaldoTra, Numérico, Saldo.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.

/*/
/*/================================================================================================================================/*/

Static Function F550LinPag(nLinPag,nLinReport,oReport,nSaldoTra)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	nLinReport++

	If nLinReport > (nLinPag + 9)
		oReport:EndPage()
		nLinReport := 8
	Else
		nSaldoTra := nSaldoAtu
	EndIf

Return Nil


/*/================================================================================================================================/*/
/*/{Protheus.doc} F550ValExcel
Faz tratamento para impressao de celulas tipo data e numero quando selecionada impressao em planilha Excel.

@type function
@author Gustavo Henrique
@since 31/05/2011
@version P12.1.23

@param oSection1, Objeto, Objeto que representa a seção.
@param cNomeCel, Caractere, Nome da célula da seção.
@param xConteudo, Indefinido, Conte+do.
@param lShow, Lógico, Indica se exibo ou não.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function F550ValExcel( oSection1, cNomeCel, xConteudo, lShow )

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Empty( xConteudo )
		If lShow
			oSection1:Cell( cNomeCel ):Show()
		Else
			oSection1:Cell( cNomeCel ):Hide()
		EndIf
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} GravaTrab
Grava um registro no arquivo de trabalho para impressao do Razonete.

@type function
@author Wagner Xavier
@since 25/02/1992
@version P12.1.23

@param cTipo, Caractere, Tipo de registro.
@param dEmissao, Data, Data de Emissão.
@param dVencto, Data, Data de vencimento.
@param nValor, Numérico, Valor.
@param arrayDados, Array, Array de dados.
@param aDadosAbat, Array, Array de dados de Abatimento.
@param lPrincipal, Lógica, Compatibilidade.
@param lCm, Lógica, Compatibilidade.
@param nBuffer, Numérica, Buffer.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function GravaTrab( cTipo,dEmissao,dVencto,nValor,arrayDados,aDadosAbat,lPrincipal,lCm, nBuffer)
	Local cDCR,cDCP,cAlias:=Alias()
	Local nX := 0
	//Local nY := {}
	//Local nPos := 0

	//Controla o Pis Cofins e Csll na baixa CP
	Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
	!Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
	!Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
	!Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )

	//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default))
	//Local lPccBxCr			:= If (FindFunction("FPccBxCr"),FPccBxCr(),.F.)

	//Controla o Pis Cofins e Csll na RA (1 = Controla retenção de impostos no RA; ou 2 = Não controla retenção de impostos no RA(default))
	//Local lRaRtImp  := If (FindFunction("FRaRtImp"),FRaRtImp(),.F.)


	DEFAULT aDadosAbat := {}
	DEFAULT lPrincipal := .F.
	DEFAULT lCm 		 := .F.
	DEFAULT nBuffer    := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	nValor := Iif(nValor = Nil,arrayDados[11],nValor )

	If cTipo $ "B#D" .And.  (lCm .Or. nValor >= 0)
		cDCR="C"
		cDCP="D"
	Else
		cDCR="D"
		cDCP="C"
	EndIf

	//+--------------------------------------------------------------+
	//| Grava registro no arquivo de trabalho                        |
	//+--------------------------------------------------------------+
	Reclock("cNomeArq",.t.)
	Replace FILIAL  With arrayDados[13]
	Replace CODIGO  With arrayDados[1]	//CLIFOR
	Replace LOJA    With arrayDados[2]	//LOJA
	Replace DATAEM  With arrayDados[3]	//DTDIGIT
	Replace NUMERO  With arrayDados[4]	//PREFIXO+NUMERO+PARCELA
	Replace BANCO   With arrayDados[5]	//BANCO
	Replace BAIXA   With arrayDados[6]	//DATA
	Replace VALOR   With nValor
	Replace EMISSAO With dEmissao
	Replace VENCTO  With dVencto
	Replace HISTOR  With Iif(Empty(arrayDados[7]) .Or.;
	Upper(arrayDados[7]) = Upper(OemToAnsi("Valor recebido s/ Titulo")),;  // "Valor recebido s/ Titulo"
	OemtoAnsi("Baixa de Titulo"), arrayDados[7]) // "Baixa de Titulo"

	If arrayDados[8] == "R"				// SE5->E5_RECPAG
		Replace DC With Iif((!(arrayDados[9] $ MVRECANT+"/"+MV_CRNEG) .or.;      //TIPO
		arrayDados[10]=="ES" ) .and. (!(arrayDados[9] $ MVPAGANT+"/"+MV_CPNEG .and. SE5->E5_MOTBX = "CMP" .and. arrayDados[10]=="ES")) ;  //Estorno de compensacao do adiantamento
		.and. arrayDados[11] >= 0 ,cDCR,cDCP)      //TIPODOC  VALOR
	Else
		Replace DC With Iif((!( arrayDados[9] $ MVPAGANT+"/"+MV_CPNEG) .or. ;
		arrayDados[10]=="ES" ) .and. (!( arrayDados[9] $ MVRECANT+"/"+MV_CRNEG .and. SE5->E5_MOTBX = "CMP" .and. arrayDados[10]=="ES")) ;   //Estorno de compensacao do adiantamento
		.and. arrayDados[11] >= 0 ,cDCP,cDCR)
	EndIf
	Replace CCUSTO With arrayDados[12]
	Replace CONTA  With arrayDados[14]

	nBuffer++

	If nBuffer >= 9000
		cNomeArq->( MsUnlockAll() )
		nBuffer := 0
	EndIf

	If lPCCBaixa .and. !(cTipo $ 'M|J|D') //.and. mv_par03 == 2  .OR. (lRaRtImp .AND. mv_par03 == 1) //Apenas PCC Carteira a Pagar
		//Gera movimentos de histórico em casos de retenção de pis, cofins e csll
		For nX := 1 To 3
			If Empty(arrayDados[11+nX])
				If arrayDados[14+nX] > 0
					Reclock("cNomeArq",.t.)
					Replace FILIAL  With arrayDados[13]
					Replace CODIGO  With arrayDados[1]
					Replace LOJA    With arrayDados[2]
					Replace DATAEM  With arrayDados[3]
					Replace NUMERO  With arrayDados[4]
					Replace BANCO   With arrayDados[5]
					Replace EMISSAO With dEmissao
					Replace VENCTO  With dVencto
					Replace VALOR   With arrayDados[14+nX]
					Replace BAIXA   With arrayDados[6]
					Replace HISTOR  With "Desc.Imposto" + " - " + If(nX=1,"Pis",If(nX=2,"Cofins","Csll")) //Desc.Imposto
					Replace DC      With IIf(arrayDados[8]=="R","C","D") //Verifico se o titulo eh a pagar ou a receber
					Replace CCUSTO  With arrayDados[12]
					Replace CONTA   With arrayDados[14]
					nBuffer++

					If nBuffer >= 9000
						cNomeArq->( MsUnlockAll() )
						nBuffer := 0
					EndIf

				Endif
			Endif
		Next
	Endif

	dbSelectArea(cAlias)
Return Nil

/*/================================================================================================================================/*/
/*/{Protheus.doc} ValidSE5
Validar o conte+do do SE5 nao tratados pela Query.

@type function
@author Thiago Rasmussen
@since 25/03/2002
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação do conte+do do SE5 nao tratados pela Query..

/*/
/*/================================================================================================================================/*/

Static Function ValidSE5()

	Local lRet := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If 	lRet .And. ( Empty(SE5->E5_NUMERO) .Or. SE5->E5_SITUACA $ "CX" )
		lRet := .F.
	EndIf

	IF 	lRet .And. ( SE5->E5_DTDIGIT > mv_par02 )
		lRet := .F.
	Endif

	IF 	lRet .And. ( SE5->E5_CLIFOR < mv_par03 .Or. SE5->E5_CLIFOR > mv_par04 )
		lRet := .F.
	EndIF

	//	If	!SE5->E5_TIPODOC $ "VLüVLüBAüCPüV2üLJüESüVMüCX"
	If	lRet .And. ( !SE5->E5_TIPODOC $ "BA/VL/CP/V2/LJ/ES/VM/CX" )
		lRet := .F.
	EndIf

	If	lRet .And. ( SE5->E5_NATUREZ < mv_par08 .Or. SE5->E5_NATUREZ > mv_par09 )
		lRet := .F.
	EndIf


	If lRet .And. ( SE5->E5_RECPAG == "P" .and. SE5->E5_TIPODOC == "ES" .and. !(SE5->E5_TIPO $ MVPAGANT) )
		lRet := .F.
	Endif

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} FR550VldVar
Valida variáveis globais criadas pelo sistema cliente/fornecedor.

@type function
@author Andrea Verissimo
@since 23/02/2012
@version P12.1.23

@param cTexto, Caractere, Conte+do da variavel que vai ser utilizada no SQL.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Conte+do ajustado da variavel que vai ser utilizada no SQL.

/*/
/*/================================================================================================================================/*/

Static Function FR550VldVar( cTexto )

	Local cRet			:= ""
	Local nA				:=	0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Len(cTexto) > 0
		cRet	:=	"'"	// Inserindo aspas e virgulas para o select da query.
		For nA:=1 To Len(cTexto)
			If Subst(cTexto,nA,1) $ ";,-_|./"
				cRet+="','"
			Else
				cRet+=Subst(cTexto,nA,1)
			Endif
		Next
		cRet	:=	Alltrim(cRet)
		cRet	+=	"'"
	Endif

Return cRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} FR550RetCF
Retorna campos desejados do SA1 e SA2 para consultas sem o emprego da filial.

@type function
@author Pablo S.G.Carreras
@since 10/12/2009
@version P12.1.23

@param cCod, Caractere, Codigo da conta contabil.
@param cLoja, Caractere, Codigo do cliente/fornecedor.
@param cCMP, Caractere, Codigo da loja.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Campos desejados do SA1 e SA2 para consultas sem o emprego da filial.

/*/
/*/================================================================================================================================/*/

Static Function FR550RetCF(cCod, cLoja, cCMP)

	Local aArea		:= GetArea()
	Local cRet		:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Select("SA2TMP")>0
		dbSelectArea("SA2TMP")
		SA2TMP->(dbCloseArea())
	EndIf

	BeginSql Alias "SA2TMP"

		SELECT *
		FROM %table:SA2% SA2
		WHERE SA2.%notDel%
		AND SA2.A2_COD = %exp:cCod%
		AND SA2.A2_LOJA = %exp:cLoja%
		ORDER BY SA2.A2_COD,SA2.A2_LOJA

	EndSql

	dbSelectArea("SA2TMP")

	If ( GetSX3Cache(cCMP,"X3_TIPO") # "C" )
		TCSetField("SA2TMP",cCMP,GetSX3Cache(cCMP,"X3_TIPO"),TamSX3(cCMP)[1],TamSX3(cCMP)[2])
	EndIf

	If SA2TMP->(!EOF())
		cRet := SA2TMP->(&cCMP)
	EndIF


	If Select("SA2TMP")>0
		dbSelectArea("SA2TMP")
		SA2TMP->(dbCloseArea())
	EndIf
	RestArea(aArea)

Return (cRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} FR01AVldAgCF
Valida a selecao para aglutinacao de lojas de fornecedor.

@type function
@author Pablo S.G.Carreras
@since 11/12/2009
@version P12.1.23

@param nOpc, Numérico, Código da opção da rotina.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function FR01AVldAgCF(nOpc)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If mv_par13 == 1 .AND. mv_par19 == 1
		Do Case
			Case nOpc == 1		//mv_par13
			mv_par13 := 2
			MsgAlert(OemToAnsi("A aglutinação de lojas não funciona com o filtro de contas contábeis. Filtro desativado!"))
			Otherwise
			mv_par19 := 2
			MsgAlert(OemToAnsi("A aglutinação de lojas não funciona com o filtro de contas contábeis. Aglutinação desativada!"))
		EndCase
	Endif

Return Nil

/*/================================================================================================================================/*/
/*/{Protheus.doc} FR01AVldIni
Valida a selecao para filial inicial fornecedor.

@type function
@author Pablo S.G.Carreras
@since 11/12/2009
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

@deprecated Função não utilizada no fonte
/*/
/*/================================================================================================================================/*/

Static Function FR01AVldIni()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If !EMPTY(mv_par22)
		If SUBSTR(mv_par22,1,4) <> SUBSTR(FWxFilial("SE2"),1,4)
			mv_par22 :=  SUBSTR(FWxFilial("SE2"),1,4) + SUBSTR(mv_par22,5,4)
			MsgAlert(OemToAnsi("A Filial Inicial deve corresponder + empresa Atual. Ajuste Feito!"))
		EndIf
	EndIf

Return .T.

/*/================================================================================================================================/*/
/*/{Protheus.doc} FR01AVldFim
Valida a selecao para Filial Final fornecedor.

@type function
@author Pablo S.G.Carreras
@since 11/12/2009
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

@deprecated Função não utilizada no fonte
/*/
/*/================================================================================================================================/*/

Static Function FR01AVldFim()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If !EMPTY(mv_par23)
		If SUBSTR(mv_par23,1,4) <> SUBSTR(FWxFilial("SE2"),1,4)
			mv_par23 :=  SUBSTR(FWxFilial("SE2"),1,4) + SUBSTR(mv_par23,5,4)
			MsgAlert(OemToAnsi("A Filial Final deve corresponder + empresa Atual. Ajuste Feito!"))
		EndIf
	EndIf

Return .T.

/*/================================================================================================================================/*/
/*/{Protheus.doc} AjustaSX1
Ajusta o arquivo de perguntas.

@type function
@author Allan da Silva Faria
@since 22/01/2015
@version P12.1.23

@param cPerg, Caractere, Nome do grupo de pergunta.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@deprecated Função PutSx1 foi descontinuada.
/*/
/*/================================================================================================================================/*/

Static Function AjustaSX1(cPerg)

	Local aAreaSX1	:= SX1->(GetArea())
	Local nTam		:= 0
	lOCAL aHelp 	:= {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//Pesquisando se a pergunta de aglutinacao de lojas de cliente/fornecedores consta no X1 do usuario
	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	nTam := SX1->(dbStruct())[1][3] //X1_GRUPO

	cPerg:= PADR(cPerg,nTam)

	aAdd(aHelp , "Informe a data inicial do intervalo de     " )
	aAdd(aHelp , "datas de emissão, para que se obtenha o    " )
	aAdd(aHelp , "resultado desejado.                        " )

	//PutSx1(cPerg,"01","A partir de ?"	,"","","mv_ch1","D",8,0,,"G","","","","S","mv_par01","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},".FINR01A01.")

	aHelp:= {}
	aAdd(aHelp , "Informe a data final do intervalo de       " )
	aAdd(aHelp , "datas de emissão, para que se obtenha o    " )
	aAdd(aHelp , "resultado desejado.                        " )

	//PutSx1(cPerg,"02","Até a Data ?"	,"","","mv_ch2","D",8,0,,"G","","","","S","mv_par02","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},".FINR01A02.")

	aHelp:= {}
	aAdd(aHelp , "Informe o código inicial do intervalo      " )
	aAdd(aHelp , "de fornecedores a serem considerados       " )
	aAdd(aHelp , "no relatório.                              " )

	//PutSx1(cPerg,"03","Do Código ?"		,"","","mv_ch3","C",TamSX3("E2_FORNECE")[1],0,,"C","","SA2","","S","mv_par03","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A03.")

	aHelp:= {}
	aAdd(aHelp , "Informe o código final do intervalo        " )
	aAdd(aHelp , "de fornecedores a serem considerados       " )
	aAdd(aHelp , "no relatório.                              " )

	//PutSx1(cPerg,"04","Até o Código?"	,"","","mv_ch4","C",TamSX3("E2_FORNECE")[1],0,,"C","","SA2","","S","mv_par04","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A04.")

	aHelp:= {}
	aAdd(aHelp , "Selecione a opção 'Sim' para que o         " )
	aAdd(aHelp , "valor financeiro seja impresso no          " )
	aAdd(aHelp , "razonete ou 'Não', caso contrário.         " )

	//PutSx1(cPerg,"05","Impr.Vlr.Financeiro?","","","mv_ch5","N",1,0,2,"C","","","","S","mv_par05","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A05.")

	aHelp:= {}
	aAdd(aHelp , "Selecione se o razonete será impresso      " )
	aAdd(aHelp , "com os tipos de títulos 'Todos',           " )
	aAdd(aHelp , "'Normais' ou só 'Adiantamentos'.           " )

	//PutSx1(cPerg,"06","Imprime ?		","","","mv_ch6","N",1,0,1,"C","","","","S","mv_par06","Todos","Todos","Todos","","Normais","Normais","Normais","Adiantamentos","Adiantamentos","Adiantamentos","","","","","","",aHelp,{{}},{{}},	".FINR01A06.")

	aHelp:= {}
	aAdd(aHelp , "Selecione se o diário será listado         " )
	aAdd(aHelp , "considerando a 'Filial' filial atual,      " )
	aAdd(aHelp , "ou 'Por Empresa', todas as filiais.         " )

	//PutSx1(cPerg,"07","Lista Por: ?"	,"","","mv_ch7","N",1,0,2,"C","","","","S","mv_par07","Filial","Filial","Filial","","Empresa","Empresa","Empresa","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A07.")

	aHelp:= {}
	aAdd(aHelp , "Selecione o código inicial do intervalo    " )
	aAdd(aHelp , "de códigos de naturezas a serem            " )
	aAdd(aHelp , "consideras na geração do relatório.        " )
	aAdd(aHelp , "Tecla [F3] disponível para consultar o     " )
	aAdd(aHelp , "Cadastro de Naturezas.                     " )

	//PutSx1(cPerg,"08","Natureza de  ?"	,"","","mv_ch8","C",TamSX3("E2_NATUREZ")[1],0,,"C","","SED","","S","mv_par08","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A08.")

	aHelp:= {}
	aAdd(aHelp , "Selecione o código final do intervalo      " )
	aAdd(aHelp , "de códigos de naturezas a serem            " )
	aAdd(aHelp , "consideras na geração do relatório.        " )
	aAdd(aHelp , "Tecla [F3] disponível para consultar o     " )
	aAdd(aHelp , "Cadastro de Naturezas.                     " )

	//PutSx1(cPerg,"09","Natureza ate ?"	,"","","mv_ch9","C",TamSX3("E2_NATUREZ")[1],0,,"C","","SED","","S","mv_par09","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A09.")

	aHelp:= {}
	aAdd(aHelp , "Selecione se o relatório será impresso     " )
	aAdd(aHelp , "'Analítico', exibindos as informações      " )
	aAdd(aHelp , "dos movimentos que compoem os saldos       " )
	aAdd(aHelp , "dos clientes ou fornecedores ou,           " )
	aAdd(aHelp , "'Sintético' exibindo apenas os totais por   " )
	aAdd(aHelp , "cliente ou fornecedor conforme a carteira   " )
	aAdd(aHelp , "escolhida. 								 " )

	//PutSx1(cPerg,"10","Imprime Relatório?"	,"","","mv_cha","N",1,0,1,"C","","","","S","mv_par10","Analitico","Analitico","Analitico","","Sintetico","Sintetico","Sintetico","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A10.")

	aHelp:= {}
	aAdd(aHelp , "Informe o n+mero da página inicial que     " )
	aAdd(aHelp , "será impressa na primeira folha do         " )
	aAdd(aHelp , "relatório                                  " )

	//PutSx1(cPerg,"11","Folha De ?"		,"","","mv_chb","N",3,0,,"G","","","","S","mv_par11","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A11.")

	aHelp:= {}
	aAdd(aHelp , "Informe o n+mero da página final que       " )
	aAdd(aHelp , "será impressa na +ltima folha do           " )
	aAdd(aHelp , "relatório                                  " )

	//PutSx1(cPerg,"12","Folha Ate ?"		,"","","mv_chc","N",3,0,,"G","","","","S","mv_par12","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A12.")

	aHelp:= {}
	aAdd(aHelp , "Selecione 'Sim' se deseja filtrar as       " )
	aAdd(aHelp , "ontas contábeis informadas no cadastro     " )
	aAdd(aHelp , "do fornecedor.                             " )

	//PutSx1(cPerg,"13","Filtra Contas Contab ?"	,"","","mv_chd","N",1,0,2,"C","U_FR01AVldAgCF(1)","","","S","mv_par13","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A13.")

	aHelp:= {}
	aAdd(aHelp , "Informe a conta inicial do intervalo de    " )
	aAdd(aHelp , "contas contábeis, informadas no		     " )
	aAdd(aHelp , "cadastro do fornecedor, que deseja         " )
	aAdd(aHelp , "filtrar caso a pergunta anterior           " )
	aAdd(aHelp , "seja igual a 'Sim'.           			 " )

	//PutSx1(cPerg,"14","Conta Inicial ?"	,"","","mv_che","C",TamSX3("A2_CONTA")[1],0,,"G","","CT1","","S","mv_par14","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A14.")

	aHelp:= {}
	aAdd(aHelp , "Informe a conta final do intervalo de      " )
	aAdd(aHelp , "contas contábeis, informadas no		     " )
	aAdd(aHelp , "cadastro do fornecedor, que deseja         " )
	aAdd(aHelp , "filtrar caso a pergunta anterior           " )
	aAdd(aHelp , "seja igual a 'Sim'.           			 " )

	//PutSx1(cPerg,"15","Conta Final ?"	,"","","mv_chf","C",TamSX3("A2_CONTA")[1],0,,"G","","CT1","","S","mv_par15","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A15.")

	aHelp:= {}
	aAdd(aHelp , "Selecione 'Sim' para que sejam             " )
	aAdd(aHelp , "considerados no relatorio, os              " )
	aAdd(aHelp , "fornecedores que possuem saldo    		 " )
	aAdd(aHelp , "anterior mas nao possuem movimentacao      " )
	aAdd(aHelp , "financeira no periodo informado, ou        " )
	aAdd(aHelp , "'Nao' em caso contrario.                   " )

	//PutSx1(cPerg,"16","Impr. Fornec s/ Movim.?","","","mv_chg","N",1,0,2,"C","","","","S","mv_par16","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A16.")

	aHelp:= {}
	aAdd(aHelp , "Informe o n+mero de linhas que serão       " )
	aAdd(aHelp , "impressas. Caso não seja informado, o      " )
	aAdd(aHelp , "sistema irá considerar 30 linhas no        " )
	aAdd(aHelp , "modoretrato e 20 linhas no modo            " )
	aAdd(aHelp , "paisagem.                                  " )

	//PutSx1(cPerg,"17","Linhas por Página ?","","","mv_chj","N",2,0,,"G","","","","S","mv_par17","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A17.")

	aHelp:= {}
	aAdd(aHelp , "Selecione total para exibir o histórico	 " )
	aAdd(aHelp , "em uma nova linha. Selecione parcial       " )
	aAdd(aHelp , "para exibir o histórico na linha   		 " )
	aAdd(aHelp , "corrente do registro, sendo limitado em    " )
	aAdd(aHelp , "20 caracteres.                             " )

	//PutSx1(cPerg,"18","Historico ?"		,"","","mv_chk","N",1,0,2,"C","","","","S","mv_par18","Parcial","Parcial","Parcial","","Total","Total","Total","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A18.")

	aHelp:= {}
	aAdd(aHelp , "Seleciona se deseja agrupar loja de    	 " )
	aAdd(aHelp , "fornecedor ou não.                         " )

	//PutSx1(cPerg,"19","Aglutinar lojas ?","","","mv_chl","N",1,0,2,"C","U_FR01AVldAgCF(2)","","","S","mv_par19","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A19.")

	aHelp:= {}
	aAdd(aHelp , "Informe a centro de custo inicial do       " )
	aAdd(aHelp , "intervalo de centro de custo, informadas no" )
	aAdd(aHelp , "título.                                    " )

	//PutSx1(cPerg,"20","Do C.Custo ?"	,"","","mv_chm","C",TamSX3("E2_CCD")[1],0,,"G","","CTT","","S","mv_par20","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A20.")

	aHelp:= {}
	aAdd(aHelp , "Informe a centro de custo final do         " )
	aAdd(aHelp , "intervalo de centro de custo, informadas no" )
	aAdd(aHelp , "título.                                    " )

	//PutSx1(cPerg,"21","Até C.Custo ?"	,"","","mv_chn","C",TamSX3("E2_CCD")[1],0,,"G","","CTT","","S","mv_par21","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A21.")

	aHelp:= {}
	aAdd(aHelp , "Informe filial Ínicial        			 " )
	aAdd(aHelp , "Parâmetros só será considerado se          " )
	aAdd(aHelp , "parâmetros 'Listar Por ?' for igual        " )
	aAdd(aHelp , "'Empresa'.                                 " )

	//PutSx1(cPerg,"22","Da Filial ?"	,"","","mv_cho","C",FWSizeFilial(),0,,"G","StaticCall(FINR01A,FR01AVldIni)","SM0_01","","S","mv_par22","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A22.")


	aHelp:= {}
	aAdd(aHelp , "Informe filial Final	        			 " )
	aAdd(aHelp , "Parâmetros só será considerado se          " )
	aAdd(aHelp , "parâmetros 'Listar Por ?' for igual        " )
	aAdd(aHelp , "“Empresa”.                                 " )

	//PutSx1(cPerg,"23","Até Filial ?"	,"","","mv_chp","C",FWSizeFilial(),0,,"G","StaticCall(FINR01A,FR01AVldFim)","SM0_01","","S","mv_par23","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A23.")

	aHelp:= {}
	aAdd(aHelp , "Informar prefixo de títulos de despesa	 " )
	aAdd(aHelp , "direta, esses títulos serão desconsiderados" )
	aAdd(aHelp , "no relatório.                              " )
	aAdd(aHelp , "Se for informar mais de um prefixo deve    " )
	aAdd(aHelp , "separar por ponto e virgular.              " )
	aAdd(aHelp , "Exemplo: DD ;DE ;DR                        " )

	//PutSx1(cPerg,"24","Pref.Despesa Direta"	,"","","mv_chq","C",16,0,,"G","StaticCall(FINR01A,FR01Pref)","","","S","mv_par24","","","","","","","","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A24.")

	aHelp:= {}
	aAdd(aHelp , "Selecione 'Sim' para que sejam considerados    " )
	aAdd(aHelp , "no relatorio os fornecedores com saldo zerado,   " )
	aAdd(aHelp , "ou 'Não' em caso contrario.     " )
	aAdd(aHelp , "(Somente opção Sintético!!!) " )

	//PutSx1(cPerg,"25","Imprime Saldo Zerado?","","","mv_chr","N",1,0,2,"C","","","","S","mv_par25","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelp,{{}},{{}},	".FINR01A25.")


	RestArea(aAreaSX1)

Return Nil

/*/================================================================================================================================/*/
/*/{Protheus.doc} FR550TOT
Não definido.

@type function
@author Pedro Pereira Lima
@since 03/08/2012
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso.

/*/
/*/================================================================================================================================/*/

Static Function FR550TOT()
	Local aArea	 	:= GetArea()
	Local aAreaSE1	:= SE1->(GetArea())
	Local cAlias 	:= GetNextAlias()
	Local cWhere 	:= ""
	Local cMotBx 	:= ""
	Local nVal	 	:= 0
	Local lRet   	:= .T.
	Local lSegue    := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If !cNomeArq->TIPO $ MVABATIM
		lSegue := .F.
	EndIf

	If lSegue

		cWhere := "%SE5.E5_TIPO NOT IN ('" + StrTran(MVABATIM,"|","','") + "')%"

		BeginSql Alias cAlias
			SELECT SE5.E5_VALOR VALOR, SE5.E5_MOTBX MOTBX, SE5.R_E_C_N_O_ NROREC FROM %Table:SE5% SE5
			WHERE
			SE5.E5_FILIAL = %Exp:xFilial("SE5")% AND
			SE5.E5_PREFIXO = %Exp:cNomeArq->PREFIXO% AND
			SE5.E5_NUMERO = %Exp:SubSTR(cNomeArq->NUMERO,TamSX3("E1_PREFIXO")[1]+1,TamSX3("E1_NUM")[1])% AND
			SE5.E5_PARCELA = %Exp:cNomeArq->PARCELA% AND
			SE5.E5_CLIFOR = %Exp:cNomeArq->CODIGO% AND
			SE5.E5_LOJA = %Exp:cNomeArq->LOJA% AND
			%Exp:cWhere% AND
			SE5.%NotDel%
			ORDER BY
			SE5.E5_SEQ
		EndSQL

		While !(cAlias)->(Eof())
			cMotBx := (cAlias)->MOTBX
			nVal	 += (cAlias)->VALOR
			(cAlias)->(dbSkip())
		EndDo

		dbSelectArea("SE1")
		SE1->(dbSetOrder(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If SE1->(dbSeek(xFilial("SE1")+cNomeArq->CODIGO+cNomeArq->LOJA+cNomeArq->PREFIXO+SubSTR(cNomeArq->NUMERO,TamSX3("E1_PREFIXO")[1]+1,TamSX3("E1_NUM")[1])+cNomeArq->PARCELA))
			While !SE1->(EOF())
				If AllTrim(cMotBx) == "CMP" .And. SE1->E1_SALDO == 0 .And. (!SE1->E1_TIPO $ MV_CRNEG .Or. !SE1->E1_TIPO $ MVABATIM)
					lRet := .F.
				EndIf
				SE1->(dbSkip())
			EndDo
		EndIf

	EndIf

	(cAlias)->(dbCloseArea())

	RestArea(aAreaSE1)
	RestArea(aArea)
Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} FR01AFil
Trata código de filial confirme o compartilhamento da tabela.

@type function
@author Allan da Silva Faria
@since 26/01/2015
@version P12.1.23

@param _cAlias, Caractere, Alias da Tabela.
@param _cFilial, Caractere, Código da Filial.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caracter, Código da filial confirma compartilhamento da tabela.

/*/
/*/================================================================================================================================/*/

Static Function FR01AFil(_cAlias,_cFilial)

	Local cRet := ""
	Local aPosLayOut := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// -----------------
	// -- Empresa
	// -----------------
	If FWModeAccess(_cAlias,1) == "C"
		cRet := Space(LayoutEmp("E")[4])
	ElseIf FWModeAccess(_cAlias,1) == "E"
		aPosLayOut := LayoutEmp("E")
		cRet := SubStr(_cFilial,aPosLayOut[1],aPosLayOut[2])

		// ---------------------
		//-- Unidade de Negocio
		// ---------------------
		If FWModeAccess(_cAlias,2) == "C"
			cRet += Space(LayoutEmp("U")[4])
		ElseIf FWModeAccess(_cAlias,2) == "E"
			aPosLayOut := LayoutEmp("U")
			cRet += SubStr(_cFilial,aPosLayOut[1],aPosLayOut[2])

			// -----------------
			//-- Filial
			// -----------------
			If FWModeAccess(_cAlias,3) == "C"
				cRet += Space(LayoutEmp("F")[4])
			ElseIf FWModeAccess(_cAlias,3) == "E"
				aPosLayOut := LayoutEmp("F")
				cRet += SubStr(_cFilial,aPosLayOut[1],aPosLayOut[2])
			EndIf
		EndIf
	EndIf

Return cRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} LayoutEmp
Retorna array com informações do layout da unidade passada por parâmetros.

@type function
@author Allan da Silva Faria
@since 26/01/2015
@version P12.1.23

@param cTipo, characters, Unidade.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, [1] = Posicição inicial da unidade no layout, [2] = Posicição final da unidade no layout, [3] = Quantidade de posições do unidade dentro do layout, [4] = Quantodade de posições restante do final da unidade até o final do layout.

/*/
/*/================================================================================================================================/*/

Static Function LayoutEmp(cTipo)

	Local cLayOut := AllTrim(FWSM0Layout()) //-- LayOut do Gestão de Empresa
	Local aRet 	  := Array(4)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aRet[1] := At(cTipo,cLayOut)
	aRet[2] := (Rat(cTipo,cLayOut) - aRet[1]) +1
	aRet[3] := Len(SubStr(cLayOut,aRet[1],aRet[2]))
	aRet[4] := Len(SubStr(cLayOut,aRet[1]))

Return aRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} FR01ASA
Retorna dados.

@type function
@author Allan da Silva Faria
@since 27/01/2015
@version P12.1.23

@param cCodigo, Caractere, Codigo de fornecedor.
@param LOJA, Caractere, Loja do fornecedor.
@param cCtContAnt, Caractere, Compatibilidade.
@param cNome, Caractere, Nome do fornecedor (refencia).
@param cConta, Caractere, Conta do fornecedor (refencia).

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function FR01ASA(cCodigo, LOJA, cCtContAnt, cNome, cConta)

	Local cAliasTmp 		:= GetNextAlias()
	Local cQry				:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	cQry := "SELECT A2_FILIAL, A2_COD, A2_LOJA, A2_NOME, A2_CGC, A2_CONTA "
	cQry +=  " FROM " + RetSqlName("SA2") + " SA2 "
	cQry +=  " WHERE "
	cQry +=  " SA2.A2_COD = '" + cCodigo + "' "
	cQry +=  " AND SA2.A2_LOJA = '" + LOJA + "' "
	cQry +=  " AND SA2.D_E_L_E_T_ = '' "
	cQry +=  " ORDER BY SA2.A2_FILIAL, SA2.A2_COD, SA2.A2_LOJA, SA2.A2_CONTA "

	cQry := ChangeQuery(cQry)

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasTmp, .F., .T. )

	If mv_par10 == 1  // Analitico
		cNome :=              (cAliasTmp)->A2_NOME+" "+Transform(AllTrim((cAliasTmp)->A2_CGC),IIF(len(AllTrim((cAliasTmp)->A2_CGC))==11,"@R 999.999.999-99","@R 99.999.999/9999-99"))+" - Conta Contábil: "+(cAliasTmp)->A2_CONTA
	Else
		cNome := Substr((cAliasTmp)->A2_NOME,1,33)+" "+IIF(mv_par13 == 1,(cAliasTmp)->A2_CONTA,Transform(AllTrim((cAliasTmp)->A2_CGC),IIF(len(AllTrim((cAliasTmp)->A2_CGC))==11,"@R 999.999.999-99","@R 99.999.999/9999-99")))
	Endif

	cConta := (cAliasTmp)->A2_CONTA

	(cAliasTmp)->( DbCloseArea() )

Return Nil

/*/================================================================================================================================/*/
/*/{Protheus.doc} FR01Pref
Retorno dos códigos das empresas selecionados.

@type function
@author Allan da Silva Faria
@since 27/01/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

@deprecated Função não utilizada no fonte
/*/
/*/================================================================================================================================/*/

Static Function FR01Pref()

	Local _cRet 	:= ""              	// Retorno dos códigos das empresas selecionados Exemplo: 01*04*06*
	Local _aPref	:= FWGetSX5("Z1")
	Local _aPrefTrab:= Array(0)        	// Array com os dados já selecionados
	Local _aPrefSel	:= Array(0)
	Local _ntam		:= 20
	Local _n		:= 0 				// Variavel de controle de laç
	Local _cReadVar := Alltrim(ReadVar())

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//---  Monta Array Prefixo
	For _n := 1 To Len(_aPref)
		If Empty(_aPrefTrab) .OR. (AsCan(_aPrefTrab,{|X| _aPref[_n,3]== SubStr(X,1,TamSX3("E2_PREFIXO")[1])})==0)
			aAdd(_aPrefTrab,_aPref[_n,3]+" - "+_aPref[_n,4])
		EndIf
	Next _n

	//--- Ordena array
	aSort(_aPrefTrab,,,{|x,y| x < y })

	//--- **********************************************************************
	//---  Função que Monta a Tela de interação
	//--- **********************************************************************
	If F_Opcoes(@_aPrefSel,;                       // aRetorn
	"Selecione os Prefixos!",;			//cTitulo
	@_aPrefTrab,;						//aOpcoes
	"",;								//cOpcoes
	,;									//nLin1
	,;									//nCol1
	.f.,;								//l1Elem
	_nTam,; 							//nTam
	Len(_aPrefTrab),;					//nElemRet
	.T.,;								//lMultSelect
	.F.,;								//lComboBox
	,;									//cCampo
	.T.,;								//lNotOrdena
	.F.,;		   						//NotPesq
	.T.,;								//ForceRetArr
	.F.)								//F3


		aEval(_aPrefSel,{|X| _cRet+=SubStr(X,1,TamSX3("E2_PREFIXO")[1])+";"})

		&_cReadVar:= Left(AllTrim(_cRet),RAT(";",AllTrim(_cRet))-1)
	EndIf


Return .T.
