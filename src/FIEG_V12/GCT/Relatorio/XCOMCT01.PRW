#Include "Protheus.ch"
#Include "COLORS.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"
#Include "FILEIO.CH"
#Include "PARMTYPE.CH"

#Define IMP_SPOOL 2
#Define IMP_PDF 6
#Define NSTARTCOL 60
#Define NLIMLIN 620

/*/================================================================================================================================/*/
/*/{Protheus.doc} XCOMCT01
Impressao de Contrato Outsourcing.

@type function
@author José Fernando Castroviejo Vilela
@since 25/02/2017
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function XCOMCT01

	Local lRet        := .T.
	Local dDtLim      := CTOD("")
	Local cSession    := GetPrinterSession()
	Local cFilePrint  := "Contrato_Outsourcing_"+Dtos(MSDate())+StrTran(Time(),":","")+".PDF"
	Local oSetup      := NIL
	Local xPathPDF    := AllTrim(GetTempPath())
	Local xPatherver  := MsDocPath()
	Local lSegue      := .T.
	Private oReport
	Private cPerg     := "XCOMCT01"
	Private cAnoMes   := ""
	Private xDtHrEmis := ""
	Private xNomeUsr  := ""
	Private xNomeGrp  := ""
	Private nTmEntid  := 0
	Private nTmGrp    := 0

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

	CriaSX1(cPerg)
	Pergunte(cPerg,.F.)
	retornoPergunte := Pergunte(cPerg, .T.)

	If retornoPergunte == .F.
		lSegue := .F.
	EndIf

	If lSegue

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
		oReport:SetPortrait()
		oReport:SetPaperSize(DMPAPER_A4)
		oReport:SetMargin(70,25,15,25)
		oReport:cPathPDF := xPathPDF // Caso seja utilizada impressão
		oReport:SetViewPDF(.T.)
		nFlags := PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEMARGIN

		Processa({|| ReportDef(oReport,oSetup,cFilePrint)},"Aguarde... Processando o relatório...!")

		/*IF ( !oReport:lInJob )
		oSetup := FWPrintSetup():New(nFlags, "Impressao de Contrato Outsourcing")
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
		ENDIF */

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportDef
Sub-Rotina para gerar o detalhe do relatorio demonstrativo de valores por grupo.

@type function
@author José Fernando Castroviejo Vilela
@since 25/02/2017
@version P12.1.23

@param oReport, Objeto, Obejto que representa o relatório.
@param oSetup, Objeto, Compatibilidade.
@param cFilePrint, Caractere, Nome e local do arquivo pdf a ser gerado.

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/


Static Function ReportDef(oReport,oSetup,cFilePrint)

	Local aAreaOld    := GetArea()
	Local aAreaSM0    := SM0->(GetArea())
	Local cStartPath  := GetSrvProfString("Startpath","")
	Local cLogo       := cStartPath + "LGRL" + SM0->M0_CODIGO + Alltrim(SM0->M0_CODFIL) + ".BMP" 	// Empresa+Filial -- 300/92
	Local cLayout     := ""
	//Local nCount      := 0
	Local oBrush      := TBrush():New("",CLR_LIGHTGRAY)
	//Local _SQL        := ""

	Local _cAlias  := GetNextAlias()
	//Local _cAliasA := GetNextAlias()
	Local _cAliasB := GetNextAlias()
	Local cRevisao := ""
	Local dtinicio := ""
	Local dtfinal  := ""
	//Local Valor := ""
	Local Fornecedor := ""
	Local CNPJ := ""
	Local Nome_for := ""
	//Local xEntidade := SM0->M0_NOMECOM
	Local xCGC := SM0->M0_CGC
	Local xFilial := SM0->M0_CODFIL
	Local xChave := ""
	Local xFilcont := ""
	Local nLinha := 0
	Local nLinhaB := 0
	Local lSegue := .T.


	Private xEntidade := SM0->M0_NOMECOM
	Private xAjustLC  := 0
	Private nLRep     := 0
	Private Fonte10N,Fonte06,Fonte06N

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Fonte10N := TFontEx():New(oReport,"Lucida Console",10,10,.T.,.T.,.F.)

	IF oReport:nDevice == 6
		Fonte06  := TFontEx():New(oReport,"Lucida Console",07,07,.F.,.T.,.F.)
		Fonte06N := TFontEx():New(oReport,"Lucida Console",07,07,.T.,.T.,.F.)
	ELSE
		Fonte06  := TFontEx():New(oReport,"Lucida Console",06,06,.F.,.T.,.F.)
		Fonte06N := TFontEx():New(oReport,"Lucida Console",06,06,.T.,.T.,.F.)
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



	cRevisao := Posicione("CN9",1,FWxFilial("CN9")+MV_PAR01,"CN9_REVATU")

	_cAlias := GetNextAlias()
	BEGINSQL alias _cAlias
		SELECT TOP 1 *
		FROM  %TABLE:CN9% AS CN9
		WHERE CN9.%notdel%
		AND CN9_FILIAL  = %Exp:FWxFilial("CN9")%
		AND CN9_NUMERO  = %Exp:MV_PAR01%
		AND CN9_REVISA  = %Exp:cRevisao%
	ENDSQL

	If (_cAlias)->(EOF())
		MsgAlert("Contrato Inexistente na Filial Corrente!")
		lSegue := .F.
	EndIF

	If lSegue

		If !EMPTY((_cAlias)->CN9_NUMERO)
			DbSelectArea(_cAlias)
			(_cAlias)->(dbGoTop())
		Else
			(_cAlias)->(dbCloseArea())
		Endif

		nLn     := 1
		nPagTot := 1
		nPag    := 1

		If !(_cAlias)->(EOF())

			//	ImpMask(cLogo,oBrush,nPagTot,nPag)

			oReport:StartPage()

			oReport:Box(43, 58, 802, 532, '-1')
			oReport:Box(44, 59, 801, 531, '-1')
			oReport:Box(45, 60, 800, 530, '-1')
			oReport:Fillrect( {46, 61, 62, 529 }, oBrush, "-1")
			oReport:Say(56,250,"CONTRATO / PEDIDO",Fonte10N:oFont)

			//	oReport:Box(79,191, 93, 270)
			If EMPTY(cRevisao)
				oReport:Say(90,80  ,"               NºContrato:",Fonte06N:oFont)
				oReport:Say(90,190 ,(_cAlias)->CN9_NUMERO,FONTE06:oFont)
			Else
				oReport:Say(90,80  ,"               NºContrato:",Fonte06N:oFont)
				oReport:Say(90,190 ,(_cAlias)->CN9_NUMERO+"/"+ALLTRIM(ALLTRIM(cRevisao)),Fonte06:oFont)
			Endif

			dtinicio   := Trim((_cAlias)->CN9_DTINIC)
			dtfinal    := Trim((_cAlias)->CN9_DTFIM)
			dtinicio   := SUBSTR(dtinicio,7,2)+ "/"+SUBSTR(dtinicio,5,2)+ "/"+SUBSTR(dtinicio,1,4)
			dtfinal    := SUBSTR(dtfinal,7,2)+ "/"+SUBSTR(dtfinal,5,2)+ "/"+SUBSTR(dtfinal,1,4)

			oReport:Say(90,280 ,"Vigência do Contrato:",Fonte06N:oFont)
			oReport:Say(90,370 ,dtinicio+"  à  "+dtfinal,Fonte06:oFont)

			oReport:Say(110,80 ,"Identificador do Contrato:",Fonte06N:oFont)
			oReport:Say(110,190 ,(_cAlias)->CN9_DESCRI,Fonte06:oFont)

			oReport:Say(130,80 ,"        Valor do Contrato: R$",Fonte06N:oFont)
			oReport:Say(130,206,ALLTRIM(ALLTRIM(Transform((_cAlias)->CN9_VLATU,PesqPict("CN9","CN9_VLATU")))),Fonte06:oFont)

			oReport:Say(130,330,"Saldo: R$",Fonte06N:oFont)
			oReport:Say(130,375,ALLTRIM(ALLTRIM(Transform((_cAlias)->CN9_SALDO,PesqPict("CN9","CN9_SALDO")))),Fonte06:oFont)

			Fornecedor := posicione("CNA", 3, (_cAlias)->CN9_FILIAL+(_cAlias)->CN9_NUMERO+(_cAlias)->CN9_REVISA, "CNA_FORNEC")
			Nome_for := Posicione("SA2", 1,  "        "+ALLTRIM(ALLTRIM(Fornecedor)), "A2_NOME" )
			CNPJ := Posicione("SA2", 1,  "        "+ALLTRIM(ALLTRIM(Fornecedor)), "A2_CGC")

			oReport:Say(150,80 ,"CONTRATADA:",Fonte06N:oFont)
			oReport:Say(160,80 ,"             Razão Social: ",Fonte06N:oFont)
			oReport:Say(160,190,Nome_for,Fonte06:oFont)
			oReport:Say(170,80 ,"                     CNPJ: ",Fonte06N:oFont)
			oReport:Say(170,190,Transform(CNPJ, "@R 99.999.999/9999-99"),Fonte06:oFont)

			oReport:Say(190,80 ,"CONTRATANTE:",Fonte06N:oFont)
			oReport:Say(200,80 ,"             Razão Social: ",Fonte06N:oFont)
			oReport:Say(200,190,ALLTRIM(ALLTRIM(xFilial))+" - "+xEntidade,Fonte06:oFont)
			oReport:Say(210,80 ,"                     CNPJ: ",Fonte06N:oFont)
			oReport:Say(210,190,Transform(xCGC,  "@R 99.999.999/9999-99"),Fonte06:oFont)

			xChave := ""
			xChave += MSMM((_cAlias)->CN9_CODOBJ)
			nTam := MLCount((MSMM((_cAlias)->CN9_CODOBJ)),105)      // 	nTam := MLCount((MSMM((_cAlias)->CN9_CODOBJ)),80)
			nLin := nTam
			nLin2 := 235
			nTam += 240

			oReport:Say(230,80 ,"OBJETO DO CONTRATO:",Fonte06N:oFont)

			for i := 1 to nlin

				nLin2 += 10
				xChave := ""
				xChave += MSMM((_cAlias)->CN9_CODOBJ,105,i)
				oReport:Say(nLin2,90,xChave,Fonte06:oFont)

			Next

			oReport:Box(340,60,355,530)
			oReport:Box(340,60,355,475)
			oReport:Box(340,60,355,420)
			oReport:Box(340,60,355,370)
			oReport:Box(340,60,355,110)

			oReport:Say(350,70,"Código", Fonte06N:oFont)
			oReport:Say(350,115,"Descrição", Fonte06N:oFont)
			oReport:Say(350,390,"Qtde", Fonte06N:oFont)
			oReport:Say(350,425,"VL Unitario", Fonte06N:oFont)
			oReport:Say(350,480,"Valor Total", Fonte06N:oFont)

			xChave := ALLTRIM(ALLTRIM((_cAlias)->CN9_NUMERO))
			xFilcont := (_cAlias)->CN9_FILIAL
			_cAliasB := GetNextAlias()
			BEGINSQL alias _cAliasB
				SELECT *
				FROM  %TABLE:CNB% AS CNB
				WHERE CNB.%notdel%
				AND CNB_CONTRA = %Exp:xChave%
				AND CNB_FILIAL = %Exp:xFilcont%
				AND CNB_REVISA = %Exp:cRevisao%
			ENDSQL


			IF !(_cAliasB)->(EOF())
				DbSelectArea(_cAliasB)
				(_cAliasB)->(dbGoTop())
			Endif
			nLinha  := 350
			nLinhaB := 340
			While !(_cAliasB)->(EOF())
				nLinha  += 15
				nLinhaB += 15

				oReport:Box(nLinhaB,60,nLinhaB+15,530,"-3")
				oReport:Box(nLinhaB,60,nLinhaB+15,475,"-3")
				oReport:Box(nLinhaB,60,nLinhaB+15,420,"-3")
				oReport:Box(nLinhaB,60,nLinhaB+15,370,"-3")
				oReport:Box(nLinhaB,60,nLinhaB+15,110,"-3")

				oReport:Say(nLinha,65 ,(_cAliasB)->CNB_PRODUT, Fonte06:oFont)
				oReport:Say(nLinha,115,(_cAliasB)->CNB_DESCRI, Fonte06:oFont)
				oReport:Say(nLinha,360,Transform((_cAliasB)->CNB_QUANT,PesqPict("CNB","CNB_QUANT")), Fonte06:oFont)
				oReport:Say(nLinha,415,Transform((_cAliasB)->CNB_VLUNIT,PesqPict("CNB","CNB_VLUNIT")), Fonte06:oFont)
				oReport:Say(nLinha,465,Transform((_cAliasB)->CNB_VLTOT,PesqPict("CNB","CNB_VLTOT")), Fonte06:oFont)

				(_cAliasB)->(dbSkip())
			End
			nLinha += 30
			oReport:Say(nLinha,375," TOTAL GERAL: R$"+Transform((_cAlias)->CN9_VLATU,PesqPict("CN9","CN9_VLATU")),Fonte06N:oFont)

			(_cAliasB)->(DbCloseArea())
			(_cAlias)->(DbCloseArea())

			nLinha += 30

			oReport:Say(nlinha,90,"CONDIÇÕES GERAIS PARA FORNECIMENTO:", Fonte06N:oFont )
			nLinha += 10
			oReport:Say(nlinha,130,"Observar todas condições do Pregão Presencial Conjunto Nº 010/2016", Fonte06:oFont)

		Endif

		oReport:EndPage()
		lPreview := .T.
		oReport:Preview()
		FreeObj(oReport)
		oReport := Nil

	Endif

	RestArea(aAreaSM0)
	RestArea(aAreaOld)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ImpMask
Sub-Rotina para gerar o cabecalho mais o rodape do relatorio.

@type function
@author José Fernando Castroviejo Vilela
@since 25/02/2017
@version P12.1.23

@param cLogo, Caractere, Logo do Relatório.
@param oBrush, Objeto, objeto que permite definir a cor de preenchimento do shape.
@param nPagTot, Numérico, Número Total de Páginas.
@param nPag, Numérico, Número da Página.

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@deprecated Função não utilizada
/*/
/*/================================================================================================================================/*/

Static Function ImpMask(cLogo,oBrush,nPagTot,nPag)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//oReport:StartPage()
	//nLRep := 0
	//oReport:SayBitmap(000,NSTARTCOL,cLogo,218,43)
	//nLRep += 53



	//Impressao do Rodape
	//oReport:Line(820,50,820,540)
	//oReport:Say(830,NSTARTCOL+000,"Emissão: "+xDtHrEmis,Fonte06:oFont)
	//oReport:Say(830,NSTARTCOL+200,"Emitido Por: "+xNomeUsr,Fonte06:oFont)
	//oReport:Say(830,NSTARTCOL+430,"Página: "+Alltrim(Str(nPag))+"/"+Alltrim(Str(nPagTot)),Fonte06:oFont)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} CriaSx1
Cria grupo de perguntas para o relatório.

@type function
@author Thiago Rasmussen
@since 25/02/2017
@version P12.1.23

@param cPerg, Caracteres, Nome da pergunta.

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.

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

	aAdd(aP,{"Numero Contrato: ", "C",15 ,0,"G","","CN9"	,"","","","",""})                            // MV_PAR01

	//-----------------------------------------------

	aAdd(aHelp,{"Informe o Numero Contrato (Filial Logada)!"})

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