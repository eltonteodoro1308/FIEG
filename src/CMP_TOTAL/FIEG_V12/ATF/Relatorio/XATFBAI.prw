#Include "Protheus.ch"
#Include "COLORS.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"
#Include "FILEIO.CH"
#Include "PARMTYPE.CH"

#Define IMP_SPOOL 2
#Define IMP_PDF 6
#Define NSTARTCOL 20
#Define NLIMLIN 620

/*/================================================================================================================================/*/
/*/{Protheus.doc} XATFBAI
Relatório de Baixas.

@type function
@author Thiago Rasmussen
@since 11/11/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function XATFBAI

	Local lRet        := .T.
	Local dDtLim      := CTOD("")
	Local cSession    := GetPrinterSession()
	Local cFilePrint  := "Relatório_Baixas_"+Dtos(MSDate())+StrTran(Time(),":","")+".PDF"
	Local oSetup      := NIL
	Local xPathPDF    := AllTrim(GetTempPath())
	Local xPatherver  := MsDocPath()
	Private oReport
	Private cPerg     := "XATFBAI"
	Private cAnoMes   := ""
	Private xDtHrEmis := ""
	Private xNomeUsr  := ""
	Private xNomeGrp  := ""
	Private nTmEntid  := 0
	Private nTmGrp    := 0
	//Private cPctVal   := PesqPict("SN1","N1_VLAQUIS")

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	PswOrder(2)
	IF PswSeek(__cUserID, .T. )
		xNomeUsr := PswRet()[1,4]
	ENDIF
	//Alltrim(xNomeUsr)

	xDtHrEmis := DtoS(dDatabase)
	xDtHrEmis := SUBSTR(xDtHrEmis,7,2)+"/"+SUBSTR(xDtHrEmis,5,2)+"/"+SUBSTR(xDtHrEmis,1,4)+"  "+Time()

	//CriaSX1(cPerg)

	aDEVICE := {}
	Aadd( aDevice, "DISCO" )
	Aadd( aDevice, "SPOOL" )
	Aadd( aDevice, "EMAIL" )
	Aadd( aDevice, "EXCEL" )
	Aadd( aDevice, "HTML"  )
	Aadd( aDevice, "PDF"   )

	nLocal       := 2
	nOrientation := 1
	cDevice      := "PDF"
	nPrintType   := 6

	/*
	FWMsPrinter(): New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] ) --> oPrinte
	*/
	Private nConsNeg := 0.4 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
	Private nConsTex := 0.5 // Constante para concertar o cálculo retornado pelo GetTextWidth.

	oReport := FWMSPrinter():New(cFilePrint,nPrintType,.f.,xPatherver,.T.,,,,.T.)
	oReport:SetResolution(78)
	oReport:SetLandscape()
	oReport:SetPaperSize(DMPAPER_A4)
	oReport:SetMargin(15,25,15,25)
	oReport:cPathPDF := xPathPDF // Caso seja utilizada impressão
	oReport:SetViewPDF(.T.)

	nFlags := PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEMARGIN

	IF ( !oReport:lInJob )
		oSetup := FWPrintSetup():New(nFlags, "Relação de Bens Baixados")
		oSetup:SetUserParms( {|| Pergunte( cPerg, .T. ) } )
		oSetup:SetPropert( PD_PRINTTYPE, nPrintType )
		oSetup:SetPropert( PD_ORIENTATION, 2 )
		oSetup:SetPropert( PD_DESTINATION, nLocal )
		oSetup:SetPropert( PD_MARGIN, {15,25,15,25} )
		oSetup:SetPropert( PD_PAPERSIZE, 2 )
		Pergunte( cPerg, .F. )
		IF oSetup:Activate() == PD_OK
			fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
			IF oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
				oReport:nDevice := IMP_SPOOL
				oReport:cPrinter := oSetup:aOptions[PD_VALUETYPE]
				oReport:lServer := .F.
				oReport:lViewPDF := .F.
			ELSEIF oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
				oReport:nDevice := IMP_PDF
				oReport:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
			ENDIF

			IF lRet
				Processa({|| ReportDef(oReport,oSetup,cFilePrint)},"Aguarde... Processando o relatório...!")
			ENDIF
		ELSE
			oReport:Deactivate()
		ENDIF
	ENDIF

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportDef
Sub-Rotina para gerar o detalhe do relatorio demonstrativo de valores por grupo.

@type function
@author Gerson Ricardo Soeltl
@since 28/07/2015
@version P12.1.23

@param oReport, Objeto, Objeto que representa o relatório.
@param oSetup, Objeto, objeto que permite visualizar e imprimir relatório.
@param cFilePrint, Caractere, Nome do arquivo de relatório a ser criado.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ReportDef(oReport,oSetup,cFilePrint)

	Local aAreaOld    := GetArea()
	Local aAreaSM0    := SM0->(GetArea())
	Local cStartPath  := GetSrvProfString("Startpath","")
	Local cLogo       := cStartPath + "LGRL" + SM0->M0_CODIGO + Alltrim(SM0->M0_CODFIL) + ".BMP" 	// Empresa+Filial -- 300/92
	Local cLayout     := ""
	Local cAliasQry   := GetNextAlias()
	//Local nCount      := 0
	Local oBrush      := TBrush():New("",CLR_LIGHTGRAY)
	Local _SQL        := ""
	Local lSegue      := .T.
	Private xEntidade := SM0->M0_NOMECOM
	Private xAjustLC  := 0
	Private nLRep     := 0
	Private Fonte10N,Fonte06,Fonte06N

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Fonte10N := TFontEx():New(oReport,"Lucida Console",10,10,.T.,.T.,.F.)
	//Fonte06  := TFontEx():New(oReport,"Arial",06,06,.F.,.T.,.F.)
	//Fonte06N := TFontEx():New(oReport,"Arial",06,06,.T.,.T.,.F.)

	IF oReport:nDevice == 6
		Fonte06  := TFontEx():New(oReport,"Lucida Console",06,06,.F.,.T.,.F.)
		Fonte06N := TFontEx():New(oReport,"Lucida Console",06,06,.T.,.T.,.F.)
	ELSE
		Fonte06  := TFontEx():New(oReport,"Lucida Console",05,05,.F.,.T.,.F.)
		Fonte06N := TFontEx():New(oReport,"Lucida Console",05,05,.T.,.T.,.F.)
		xAjustLC := 20
	ENDIF

	cLayout := TRIM(FWSM0Layout())
	nTmEntid := 0
	FOR n1 := 1 TO LEN(cLayout)
		IF SUBSTR(cLayout,n1,1) $ "EU" //E - Empresa, U - UF, F - Filial
			nTmEntid++
		ENDIF

		IF SUBSTR(cLayout,n1,1) $ "E"
			nTmGrp++
		ENDIF
	NEXT n1

	IF !File( cLogo )
		cLogo := cStartPath + "LGRL" + SM0->M0_CODIGO + ".BMP" // Empresa
	ENDIF

	_SQL += "" +;
	"SELECT " + CRLF +;
	"RTRIM(N1_FILIAL) AS N1_FILIAL, " + CRLF +;
	"RTRIM(N3_CCONTAB) AS N3_CCONTAB, " + CRLF +;
	"RTRIM(N3_CUSTBEM) AS N3_CUSTBEM, " + CRLF +;
	"RTRIM(N1_CBASE) + ' - ' + RTRIM(N1_DESCRIC) AS N1_CBASE, " + CRLF +;
	"CONVERT(VARCHAR(10),CAST(N1_AQUISIC AS DATE),103) AS N1_AQUISIC, " + CRLF +;
	"CONVERT(VARCHAR(10),CAST(N1_BAIXA AS DATE),103) AS N1_BAIXA, " + CRLF +;
	"N4_MOTIVO + ' - ' + X5_DESCRI AS N4_MOTIVO, " + CRLF +;
	"N3_VORIG1 AS N3_VORIG1, " + CRLF +;
	"N3_VRDACM1 - N3_VRDMES1 AS N3_VRDACM1, " + CRLF +;
	"N3_VORIG1 - (N3_VRDACM1 - N3_VRDMES1) AS N3_VRRESID " + CRLF +;
	"FROM SN1010 " + CRLF +;
	"LEFT JOIN SN3010 ON N3_FILIAL = N1_FILIAL AND " + CRLF +;
	"                    N3_CBASE = N1_CBASE AND " + CRLF +;
	"                    N3_ITEM = N1_ITEM AND " + CRLF +;
	"                    SN3010.D_E_L_E_T_ = '' " + CRLF +;
	"LEFT JOIN SN4010 ON N4_FILIAL = N3_FILIAL AND " + CRLF +;
	"                    N4_CBASE = N3_CBASE AND " + CRLF +;
	"                    N4_ITEM = N3_ITEM AND " + CRLF +;
	"                    N4_TIPO = N3_TIPO AND " + CRLF +;
	"                    N4_DATA = N3_DTBAIXA AND " + CRLF +;
	"                    N4_SEQ = N3_SEQ AND " + CRLF +;
	"                    N4_OCORR = '01' AND " + CRLF +;
	"                    N4_TIPOCNT = '1' AND " + CRLF +;
	"                    SN4010.D_E_L_E_T_ = '' " + CRLF +;
	"LEFT JOIN SX5010 ON X5_FILIAL = SUBSTRING(N4_FILIAL,1,4) AND " + CRLF +;
	"                    X5_TABELA = '16' AND " + CRLF +;
	"                    X5_CHAVE = N4_MOTIVO AND " + CRLF +;
	"                    SX5010.D_E_L_E_T_ = '' " + CRLF +;
	"WHERE " + CRLF +;
	"N3_BAIXA <> '0' " + CRLF +;
	"AND SN1010.D_E_L_E_T_ = '' "

	IF ALLTRIM(MV_PAR01) != ""
		_SQL += "" + CRLF + "AND N1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	ENDIF

	IF ALLTRIM(MV_PAR03) != ""
		_SQL += "" + CRLF + "AND N3_CUSTBEM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	ENDIF

	IF ALLTRIM(MV_PAR05) != ""
		_SQL += "" + CRLF + "AND N1_PRODUTO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
	ENDIF

	IF ALLTRIM(MV_PAR07) != ""
		_SQL += "" + CRLF + "AND N1_CBASE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
	ENDIF

	IF !EMPTY(MV_PAR09) .AND. !EMPTY(MV_PAR10)
		_SQL += "" + CRLF + "AND N3_DTBAIXA BETWEEN '" + DTOS(MV_PAR09) + "' AND '" + DTOS(MV_PAR10) + "' "
	ENDIF

	IF ALLTRIM(MV_PAR11) != ""
		_SQL += "" + CRLF + "AND N4_MOTIVO BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
	ENDIF

	IF ALLTRIM(MV_PAR13) != ""
		_SQL += "" + CRLF + "AND N4_MOTIVO IN (SELECT VALORES FROM dbo.FN_ARRAY_DE_PARAMETROS('" + ALLTRIM(MV_PAR13) + "',';')) "
	ENDIF

	_SQL += "" + CRLF + "ORDER BY 1,4";

	IF SELECT(cAliasQry) > 0
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbCloseArea())
	ENDIF

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_SQL),cAliasQry,.T.,.F.)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(dbGotop())

	//===========================================================================================================
	IF (cAliasQry)->(EOF())
		MsgAlert("A consulta não retornou nenhum registro, verifique os parâmetros informados!","XATFBAI")
		lSegue := .F.
	ENDIF

	If lSegue

		aItens  := {}
		aTotais := {0,0,0}
		nLn     := 1
		nPagTot := 1

		Aadd(aItens,{nLn==1,"1","Filial","Conta","Centro Custo","Ativo","Aquisição","Baixa","Motivo","Valor Original","Deprec. Acumulada","Residual"})

		WHILE !(cAliasQry)->(EOF())
			IF (nLn+1)>46
				Aadd(aItens,{.T.,"1","Filial","Conta","Centro Custo","Ativo","Aquisição","Baixa","Motivo","Valor Original","Deprec. Acumulada","Residual"})
				nLn := 1
				nPagTot++
			ENDIF

			(cAliasQry)->(Aadd(aItens,{.F.,"2",;
			AllTrim((cAliasQry)->N1_FILIAL),;
			AllTrim((cAliasQry)->N3_CCONTAB),;
			AllTrim((cAliasQry)->N3_CUSTBEM),;
			AllTrim((cAliasQry)->N1_CBASE),;
			AllTrim((cAliasQry)->N1_AQUISIC),;
			AllTrim((cAliasQry)->N1_BAIXA),;
			AllTrim((cAliasQry)->N4_MOTIVO),;
			Transform((cAliasQry)->N3_VORIG1,"@E 999,999,999.99"),;
			Transform((cAliasQry)->N3_VRDACM1,"@E 999,999,999.99"),;
			Transform((cAliasQry)->N3_VRRESID,"@E 999,999,999.99")}))

			nLn += 1

			aTotais[1] += (cAliasQry)->N3_VORIG1
			aTotais[2] += (cAliasQry)->N3_VRDACM1
			aTotais[3] += (cAliasQry)->N3_VRRESID

			(cAliasQry)->(DbSkip())

		END
		(cAliasQry)->(DbCloseArea())

		Aadd(aItens,{.F.,"3",;
		"",;
		"",;
		"",;
		"",;
		"",;
		"",;
		"",;
		Transform(aTotais[1],"@E 999,999,999.99"),;
		Transform(aTotais[2],"@E 999,999,999.99"),;
		Transform(aTotais[3],"@E 999,999,999.99")})

		ProcRegua(Len(aItens))
		nPag := 0
		FOR n1:=1 TO LEN(aItens)

			IncProc()

			IF aItens[n1,1]
				IF n1 > 1
					oReport:EndPage()
				ENDIF
				nPag +=1
				ImpMask(cLogo,oBrush,nPagTot,nPag,aItens,n1)
				//ELSEIF aItens[n1,2] == "1"
				//	oReport:Fillrect( {nLRep-10, NSTARTCOL+1, nLRep, 880 }, oBrush, "-0")
				//	nLRep -= 1
				//	oReport:Say(nLRep,NSTARTCOL+005,aItens[n1,03],Fonte06N:oFont)
				//	oReport:Say(nLRep,NSTARTCOL+045,aItens[n1,04],Fonte06N:oFont)
				//	oReport:Say(nLRep,NSTARTCOL+090,aItens[n1,05],Fonte06N:oFont)
				//	oReport:Say(nLRep,NSTARTCOL+145,aItens[n1,06],Fonte06N:oFont)
				//	oReport:Say(nLRep,NSTARTCOL+450,aItens[n1,07],Fonte06N:oFont)
				//	oReport:Say(nLRep,NSTARTCOL+490,aItens[n1,08],Fonte06N:oFont)
				//	oReport:Say(nLRep,NSTARTCOL+531,aItens[n1,09],Fonte06N:oFont)
				//	oReport:Say(nLRep,NSTARTCOL+680,aItens[n1,10],Fonte06N:oFont)
				//	oReport:Say(nLRep,NSTARTCOL+750,aItens[n1,11],Fonte06N:oFont)
				//	oReport:Say(nLRep,NSTARTCOL+808,aItens[n1,12],Fonte06N:oFont)
				//	nLRep += 11
			ELSEIF aItens[n1,2] == "3"
				oReport:Say(nLRep,NSTARTCOL+680+xAjustLC,aItens[n1,10],Fonte06N:oFont)
				oReport:Say(nLRep,NSTARTCOL+750+xAjustLC,aItens[n1,11],Fonte06N:oFont)
				oReport:Say(nLRep,NSTARTCOL+808+xAjustLC,aItens[n1,12],Fonte06N:oFont)
				nLRep +=13
			ELSE
				oReport:Say(nLRep,NSTARTCOL+005,aItens[n1,03],Fonte06:oFont)
				oReport:Say(nLRep,NSTARTCOL+040,aItens[n1,04],Fonte06:oFont)
				oReport:Say(nLRep,NSTARTCOL+090,aItens[n1,05],Fonte06:oFont)
				oReport:Say(nLRep,NSTARTCOL+145,aItens[n1,06],Fonte06:oFont)
				oReport:Say(nLRep,NSTARTCOL+450,aItens[n1,07],Fonte06:oFont)
				oReport:Say(nLRep,NSTARTCOL+490,aItens[n1,08],Fonte06:oFont)
				oReport:Say(nLRep,NSTARTCOL+531,aItens[n1,09],Fonte06:oFont)
				oReport:Say(nLRep,NSTARTCOL+680,aItens[n1,10],Fonte06:oFont)
				oReport:Say(nLRep,NSTARTCOL+750,aItens[n1,11],Fonte06:oFont)
				oReport:Say(nLRep,NSTARTCOL+808,aItens[n1,12],Fonte06:oFont)
				nLRep += 11
			ENDIF

		NEXT n1

		oReport:EndPage()
		lPreview := .T.
		oReport:Preview()
		FreeObj(oReport)
		oReport := Nil

	EndIf

	RestArea(aAreaSM0)
	RestArea(aAreaOld)
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ImpMask
Sub-Rotina para gerar o cabecalho mais o rodape do relatorio.

@type function
@author Gerson Ricardo Soeltl
@since 28/07/2015
@version P12.1.23

@param cLogo, Caractere, Logo do reltório.
@param oBrush, Objeto, Objeto que permite definir a cor de preenchimento do shape.
@param nPagTot, Numérico, Total de páginas.
@param nPag, Numérico, Número da página.
@param aItens, Array, Array com os nomes das colunas do cabeçalho.
@param n1, Numérico, Posição do array aItens.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function ImpMask(cLogo,oBrush,nPagTot,nPag,aItens,n1)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oReport:StartPage()
	nLRep := 0
	oReport:Box(000,NSTARTCOL,050,880)
	oReport:Say(030,NSTARTCOL+420,"Relação dos Bens Baixados", Fonte10N:oFont)
	oReport:SayBitmap(002,NSTARTCOL+2,cLogo,180,47)
	nLRep += 53

	oReport:Line(nLRep,NSTARTCOL,nLRep,880)
	nLRep += 9
	oReport:Say(nLRep,NSTARTCOL,"Entidade: "+xEntidade,Fonte06:oFont)
	nLRep += 4
	oReport:Line(nLRep,NSTARTCOL,nLRep,880)
	nLRep += 3

	oReport:Box(nLRep,NSTARTCOL,650-nLRep,880)
	nLRep += 1

	oReport:Fillrect( {nLRep, NSTARTCOL+1, nLRep+11, 879 }, oBrush, "-0")
	nLRep += 9
	oReport:Say(nLRep,NSTARTCOL+005,aItens[n1,03],Fonte06N:oFont)
	oReport:Say(nLRep,NSTARTCOL+040,aItens[n1,04],Fonte06N:oFont)
	oReport:Say(nLRep,NSTARTCOL+090,aItens[n1,05],Fonte06N:oFont)
	oReport:Say(nLRep,NSTARTCOL+145,aItens[n1,06],Fonte06N:oFont)
	oReport:Say(nLRep,NSTARTCOL+450,aItens[n1,07],Fonte06N:oFont)
	oReport:Say(nLRep,NSTARTCOL+490,aItens[n1,08],Fonte06N:oFont)
	oReport:Say(nLRep,NSTARTCOL+531,aItens[n1,09],Fonte06N:oFont)
	oReport:Say(nLRep,NSTARTCOL+680,aItens[n1,10],Fonte06N:oFont)
	oReport:Say(nLRep,NSTARTCOL+739,aItens[n1,11],Fonte06N:oFont)
	oReport:Say(nLRep,NSTARTCOL+830,aItens[n1,12],Fonte06N:oFont)
	nLRep += 11

	//Impressao do Rodape
	oReport:Line(NLIMLIN-30,NSTARTCOL,620-30,880)
	oReport:Say(NLIMLIN-20,NSTARTCOL+000,"Emissão: "+xDtHrEmis,Fonte06:oFont)
	oReport:Say(NLIMLIN-20,NSTARTCOL+120,"Emitido Por: "+xNomeUsr,Fonte06:oFont)
	oReport:Say(NLIMLIN-20,NSTARTCOL+810,"Página: "+Alltrim(Str(nPag))+"/"+Alltrim(Str(nPagTot)),Fonte06:oFont)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} CriaSX1
Rotina para gerar o pergunte.

@type function
@author Gerson Ricardo Soeltl
@since 28/07/2015
@version P12.1.23

@param cPerg, Caractere, Nome do grupo de perguntas.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@deprecated Funçao PuSx1 foi descontinuada.
/*/
/*/================================================================================================================================/*/
Static Function CriaSX1(cPerg)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+---------------------------------------------------------------+
	//| Inclui pergunta no SX1                                        |
	//+---------------------------------------------------------------+
	//PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)
	//PutSx1(cPerg, "01", "Mês ?" , " ", " ", "MV_CH1", "C", 02, 0, 0, "G", '', "", , ,"MV_PAR01", "", "", "", "", "", "", ""	, "", "", "", "", "", "", "", "", "", {"Informe o mês"},{},{})
	//PutSx1(cPerg, "02", "Ano ?" , " ", " ", "MV_CH2", "C", 04, 0, 0, "G", '', "", , ,"MV_PAR02", "", "", "", "", "", "", ""	, "", "", "", "", "", "", "", "", "", {"Informe o Ano"},{},{})
Return