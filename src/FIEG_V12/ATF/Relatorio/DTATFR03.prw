#Include "Protheus.ch"
#Include "COLORS.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"
#Include "FILEIO.CH"
#Include "PARMTYPE.CH"

#Define IMP_SPOOL 2
#Define IMP_PDF 6
#Define NSTARTCOL 30
#Define NLIMLIN 880

/*/================================================================================================================================/*/
/*/{Protheus.doc} DTATFR03
Rotina para imprimir o relatorio Termo de Responsabilidade individual.

@type function
@author Gerson Ricardo Soeltl
@since 28/07/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function DTATFR03

	Local lRet := .T.
	Local dDtLim := CTOD("")
	Local cSession := GetPrinterSession()
	Local cFilePrint := "DTATFR03_"+Dtos(MSDate())+StrTran(Time(),":","")+".PDF"
	Local oSetup := nil
	Local xPathPDF := AllTrim(GetTempPath())
	Local xPatherver := MsDocPath()
	Local lSegue := .T.
	Private oReport
	Private cPerg := "DTATFR03"
	Private cAnoMes := ""
	Private xDtHrEmis := ""
	Private xNomeUsr := ""
	Private xNomeGrp := ""
	Private nTmEntid := 0
	Private nTmGrp := 0
	Private cPctVal := PesqPict("SN1","N1_VLAQUIS")
	Private _aCols := {}
	Private lAvulso := .F.
	Private _aHeader := {}
	Private _xResp := ""
	PRIVATE Dataini := ""
	PRIVATE Datafim := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	PswOrder(2)
	if PswSeek(__cUserID, .T. )
		xNomeUsr := PswRet()[1,4]
	endif
	_xResp := Padr(xNomeUsr,50)

	xF3USRNOM()

	if !xParams(cPerg)
		lSegue := .T.
	endif

	If lSegue

		xDtHrEmis := DtoS(dDatabase)
		xDtHrEmis := Substr(xDtHrEmis,7,2)+"/"+Substr(xDtHrEmis,5,2)+"/"+Substr(xDtHrEmis,1,4)+"  "+Time()

		/*CriaSX1(cPerg)
		Pergunte(cPerg,.F.)
		retornoPergunte := Pergunte(cPerg, .T.)

		If retornoPergunte == .F.
		Return
		EndIf */

		aDEVICE := {}
		Aadd( aDevice, "DISCO" )
		Aadd( aDevice, "SPOOL" )
		Aadd( aDevice, "EMAIL" )
		Aadd( aDevice, "EXCEL" )
		Aadd( aDevice, "HTML"  )
		Aadd( aDevice, "PDF"   )

		nLocal := 2
		nOrientation := 2
		cDevice := "PDF"
		nPrintType := 6

		/*
		FWMsPrinter(): New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] ) --> oPrinte
		*/
		Private nConsNeg := 0.4 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
		Private nConsTex := 0.5 // Constante para concertar o cálculo retornado pelo GetTextWidth.

		oReport := FWMSPrinter():New(cFilePrint,nPrintType,.f.,xPatherver,.T.,,,,.T.)
		//oReport := FWMSPrinter():New(cFilePrint,nPrintType,.f.,,.T.,,,,.T.)
		oReport:SetResolution(78)
		oReport:SetPortrait()
		oReport:SetPaperSize(DMPAPER_A4)
		oReport:SetMargin(60,60,60,60)
		oReport:cPathPDF := xPathPDF // Caso seja utilizada impressão
		oReport:SetViewPDF(.T.)

		nFlags := PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEMARGIN

		If ( !oReport:lInJob )

			//	oSetup := FWPrintSetup():New(nFlags, "Termo de Responsabilidade Individual")
			//	oSetup:SetUserParms( {|| xParams(cPerg) } )
			//	oSetup:SetPropert( PD_PRINTTYPE, nPrintType )
			//	oSetup:SetPropert( PD_ORIENTATION, 1 )
			//	oSetup:SetPropert( PD_DESTINATION, nLocal )
			//	oSetup:SetPropert( PD_MARGIN, {60,60,60,60} )
			//	oSetup:SetPropert( PD_PAPERSIZE, 2 )

			//  	If oSetup:Activate() == PD_OK

			//		fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
			/*	If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
			oReport:nDevice := IMP_SPOOL
			oReport:cPrinter := oSetup:aOptions[PD_VALUETYPE]
			oReport:lServer := .F.
			oReport:lViewPDF := .F.
			ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
			oReport:nDevice := IMP_PDF
			oReport:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
			Endif		*/

			//  		if lRet
			Processa({|| ReportDef(oReport,oSetup,cFilePrint)},"Aguarde... processando o relatório...!")
			//  endif
			//	else
			//		oReport:Deactivate()
			//	endif
		EndIf

	EndIf

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

	Local aAreaOld := GetArea()
	Local aAreaSM0 := SM0->(GetArea())
	Local cStartPath := GetSrvProfString("Startpath","")
	Local cLogo := cStartPath + "LGRL" + SM0->M0_CODIGO + Alltrim(SM0->M0_CODFIL) + ".BMP" 	// Empresa+Filial -- 300/92
	Local cLayout := ""
	Local cAliasQry := GetNextAlias()
	Local nCount := 0
	Local xEmissao := Alltrim(Str(Day(dDatabase)))+" de "+lower(MesExtenso(Month(dDatabase)))+" de "+Alltrim(Str(Year(dDatabase)))
	Local oBrush := TBrush():New("",CLR_LIGHTGRAY)
	Local xEntidade := SM0->M0_NOMECOM
	Local xAjustLC := 0
	Local oFont8,oFont8N,oFont9N,oFont7,cFont7N
	Local nLRep := 0
	Local nLin := 0
	Local nTotLn := 7
	Local _cInCBASE := ""
	Local cSpace1 := ""
	Local _Inicio := ""
	Local lSegue := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	if Len(_aCols) > 0
		nUsado := Len(_aHeader)
		For n1 := 1 to Len(_aCols)
			if !_aCols[n1,nUsado+1]
				_cInCBASE += iif(!Empty(_cInCBASE),"','","")+_aCols[n1,1]
			endif
		Next n1
	endif

	oFont7	:= TFontEx():New(oReport,"Arial",8,8,.F.,.T.,.F.)
	oFont7N	:= TFontEx():New(oReport,"Arial",8,8,.T.,.T.,.F.)
	oFont8 	:= TFontEx():New(oReport,"Arial",12,12,.F.,.T.,.F.)
	oFont8N	:= TFontEx():New(oReport,"Arial",12,12,.T.,.T.,.F.)
	oFont9N	:= TFontEx():New(oReport,"Arial",16,16,.T.,.T.,.F.)

	cLayout := Trim(FWSM0Layout())
	nTmEntid := 0
	For n1 := 1 to Len(cLayout)
		if Substr(cLayout,n1,1) $ "EU" //E - Empresa, U - UF, F - Filial
			nTmEntid++
		endif

		if Substr(cLayout,n1,1) $ "E"
			nTmGrp++
		endif
	Next n1

	If !File( cLogo )
		cLogo := cStartPath + "LGRL" + SM0->M0_CODIGO + ".BMP" 						// Empresa
	endif

	BeginSql Alias cAliasQry
		SELECT
		N1_FILIAL,
		N1_CBASE,
		N1_DESCRIC,
		N1_XMODPR,
		N1_QUANTD,
		N1_VLAQUIS,
		N1_AQUISIC,
		N1_NSERIE,
		N1_NFISCAL,
		N1_XPROCES,
		COALESCE(A2_NOME,%Exp:cSpace1%) as A2_NOME,
		COALESCE(NG_DESCRIC,%Exp:cSpace1%) AS NG_DESCRIC,
		COALESCE(NL_DESCRIC,%Exp:cSpace1%) AS NL_DESCRIC,
		SUM(COALESCE(N3_VRDACM1,0)) AS N3_VRDACM1
		FROM %table:SN1% SN1 LEFT OUTER JOIN %table:SN3% SN3 ON
		N3_FILIAL = N1_FILIAL AND
		N3_CBASE = N1_CBASE AND
		N3_ITEM = N1_ITEM AND
		N3_DINDEPR <= %Exp:dDatabase% AND
		SN3.%NotDel%
		LEFT OUTER JOIN %table:SA2% SA2 ON
		A2_FILIAL = %xFilial:SA2% AND
		A2_COD = N1_FORNEC AND
		A2_LOJA = N1_LOJA AND
		SA2.%NotDel%
		LEFT OUTER JOIN %table:SNG% SNG ON
		LEFT(NG_FILIAL,%Exp:nTmEntid%) = LEFT(N1_FILIAL,%Exp:nTmEntid%) AND
		NG_GRUPO = N1_GRUPO AND
		SNG.%NotDel%
		LEFT OUTER JOIN %table:SNL% SNL ON
		NL_FILIAL = %xFilial:SNL% AND
		NL_CODIGO = N1_LOCAL AND
		SNL.%NotDel%
		WHERE
		LEFT(N1_FILIAL,%Exp:nTmEntid%) = LEFT(%xFilial:SN1%,%Exp:nTmEntid%) AND
		N1_CBASE IN (%Exp:_cInCBASE%) AND
		N1_BAIXA = 0 AND
		SN1.%NotDel%
		GROUP BY
		N1_FILIAL,
		N1_CBASE,
		N1_DESCRIC,
		N1_XMODPR,
		N1_QUANTD,
		N1_VLAQUIS,
		N1_AQUISIC,
		N1_NSERIE,
		N1_NFISCAL,
		N1_XPROCES,
		COALESCE(A2_NOME,%Exp:cSpace1%),
		COALESCE(NG_DESCRIC,%Exp:cSpace1%),
		COALESCE(NL_DESCRIC,%Exp:cSpace1%)
		ORDER BY 2

	EndSql


	if (cAliasQry)->(EOF()) .and. !lAvulso
		Aviso("Atenção","A consulta não retornou dados verifique os parãmetros digitados!",{"OK"})
		lSegue := .T.
	endif

	If lSegue

		(cAliasQry)->(DbEval({|| nCount++}))
		(cAliasQry)->(DbGoTop())
		nPag := 0
		nLin := 0
		nPagTot := nCount/nTotLn
		if nPagTot > Int(nPagTot)
			nPagTot := Int(nPagTot)+1
		endif

		if ((nCount - (nPagTot*nTotLn)) > 4) .or. (nTotLn == nCount)
			nPagTot +=1
		endif

		if nCount < nTotLn .and. (nCount+2)>nTotLn
			nPagTot +=1
		endif

		ProcRegua(nCount)

		While !(cAliasQry)->(EOF())
			if (nLin+1) > nTotLn .or. nLin == 0

				if nLin > 0
					oReport:EndPage()
				endif

				nLin := 0

				xMntCabec(@nLRep,xEntidade,oReport,oFont9N,oFont7,oFont8,oFont8N,@nPag,nPagTot,cLogo)

			endif

			nLin += 1

			oReport:Box(nLRep,NSTARTCOL,nLRep+100,590,"-3")
			nLRep += 15
			oReport:Say(nLRep,NSTARTCOL+10,"DESCRIÇÃO DO BEM:",oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+110,(cAliasQry)->(Alltrim(N1_CBASE)),oFont8N:oFont)
			oReport:Say(nLRep,NSTARTCOL+155,(cAliasQry)->(" - "+Alltrim(N1_DESCRIC)+iif(!empty(N1_XMODPR),": "+Alltrim(N1_XMODPR),"")),oFont7N:oFont)
			nLRep += 15
			oReport:Say(nLRep,NSTARTCOL+10,"Nº NOTA FISCAL/DATA: ",oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+110,(cAliasQry)->(Alltrim(N1_NFISCAL)+"  De  "+Substr(N1_AQUISIC,7,2)+"/"+Substr(N1_AQUISIC,5,2)+"/"+Substr(N1_AQUISIC,1,4)),oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+240,"PROCESSO:",oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+290,(cAliasQry)->N1_XPROCES,oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+390,"Nº SERIE:",oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+470,(cAliasQry)->N1_NSERIE,oFont7:oFont)
			nLRep += 15
			oReport:Say(nLRep,NSTARTCOL+10,"FORNECEDOR:",oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+110,(cAliasQry)->A2_NOME,oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+390,"DATA DA COMPRA: ",oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+470,(cAliasQry)->(Substr(N1_AQUISIC,7,2)+"/"+Substr(N1_AQUISIC,5,2)+"/"+Substr(N1_AQUISIC,1,4)),oFont7:oFont)
			nLRep += 15
			oReport:Say(nLRep,NSTARTCOL+10,"GRUPO:",oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+110,(cAliasQry)->NG_DESCRIC,oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+390,"VALOR RESIDUAL: ",oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+470,Alltrim(Transform((cAliasQry)->(N1_VLAQUIS-N3_VRDACM1),cPctVal)),oFont7:oFont)
			nLRep += 15

			SM0->(DbSeek(cEmpAnt+(cAliasQry)->(N1_FILIAL)))

			oReport:Say(nLRep,NSTARTCOL+10,"ENTIDADE:",oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+110,Alltrim(SM0->M0_NOMECOM),oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+390,"UNIDADE:",oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+470,Alltrim(SM0->M0_NOME),oFont7:oFont)
			nLRep += 15
			oReport:Say(nLRep,NSTARTCOL+10,"LOCALIZAÇÃO:",oFont7:oFont)
			oReport:Say(nLRep,NSTARTCOL+110,Alltrim((cAliasQry)->NL_DESCRIC),oFont7:oFont)
			nLRep += 17

			(cAliasQry)->(DbSkip())

		End
		(cAliasQry)->(DbCloseArea())

		//***************************************

		/*
		±---------------------------------------------------------------------------±
		± ALTERAÇÃO             ºAutor  João Renes           º Data ³  04/11/18   º ±
		±---------------------------------------------------------------------------±
		±  Desc.     ³ Corrigir o problema apontado na solicitação 418722, que tra- ±
		±            ³ ta sobre a falta de impressão do cabeçalho e rodapé do rela- ±
		±            ³ tório quando são informados apenas os itens acessórios       ±
		±---------------------------------------------------------------------------±
		±  Ação.     ³ Inclusão da validação responsável por imprimir o cabeçalho e ±
		±            ³ rodapé antes da rotina que imprime apenas os itens           ±
		±            ³ acessórios                                                    ±
		±---------------------------------------------------------------------------±
		*/

		if (nLin+1) > nTotLn .or. nLin == 0

			if nLin > 0
				oReport:EndPage()
			endif

			nLin := 0

			xMntCabec(@nLRep,xEntidade,oReport,oFont9N,oFont7,oFont8,oFont8N,@nPag,nPagTot,cLogo)

		endif

		For nY := 1 to LEN(_aCols)

			nLin += 1

			If _aCols[nY,1] = "000000000"
				If _Inicio = ""
					_Inicio := "1"
					oReport:Box(nLRep,NSTARTCOL,nLRep+15,590,"-3")
					nLRep += 13
					oReport:Say(nLRep,NSTARTCOL+10,"RELAÇÃO DE ITENS ACESSÓRIOS",oFont8N:oFont)
					nLRep += 2
				EndIf
				oReport:Box(nLRep,NSTARTCOL,nLRep+15,590,"-3")
				oReport:Say(nLRep+11,NSTARTCOL+10,"-- " + _aCols[nY,2],oFont7:oFont)
				nLRep += 15
			EndIf

		Next nY


		//***************************************

		nLRep += 20

		if nPag < nPagTot
			oReport:EndPage()
			xMntCabec(@nLRep,xEntidade,oReport,oFont9N,oFont7,oFont8,oFont8N,@nPag,nPagTot,cLogo)
		endif

		oReport:Box(nLRep,NSTARTCOL,nLRep+240,590,"-3")
		oReport:Fillrect( {nLRep+1, NSTARTCOL+1, nLRep+20, 589 }, oBrush, "-0")
		nLRep += 16
		oReport:Say(nLRep,NSTARTCOL+175,"TERMO DE RESPONSABILIDADE INDIVIDUAL",oFont8N:oFont)
		nLRep += 5
		oReport:Line(nLRep,NSTARTCOL,nLRep,590)
		nLRep += 20
		oReport:Say(nLRep,NSTARTCOL+05,"Pelo presente, eu,",oFont8:oFont)
		oReport:Say(nLRep,NSTARTCOL+93,Capital(ALLTRIM(_xResp)),oFont8N:oFont)
		oReport:Say(nLRep,NSTARTCOL+274,", declaro que a descrição supra efetuada com o(s) bem(ns)",oFont8:oFont)
		nlRep += 11
		oReport:Say(nLRep,NSTARTCOL+05,"patrimonial(ais) desta seção,que estou recebendo neste ato. Declaro assumir a resposabilidade pela  sua guarda, uso",oFont8:oFont)
		nlRep += 11
		oReport:Say(nLRep,NSTARTCOL+05,"adequado e conservação, enquanto permanecer em meu poder, Comprometo-me, ainda, a devolvê-lo(s) nas mesmas",oFont8:oFont)
		nlRep += 11
		oReport:Say(nLRep,NSTARTCOL+05,"condições em que o(s) recebo, resguardando o desgaste natural pelo tempo e uso; a responder por eventuais danos",oFont8:oFont)
		nlRep += 11
		oReport:Say(nLRep,NSTARTCOL+05,"que lhe foram causados e, em caso de desaparecimento, fazer a sua reposição, observando a mesma marca ou outra",oFont8:oFont)
		nLRep += 11
		oReport:Say(nLRep,NSTARTCOL+05,"similar.",oFont8:oFont)
		nLRep += 35
		oReport:Say(nLRep,NSTARTCOL+05,"RECEBIDO  EM _____/_____/_______",oFont8:oFont)
		oReport:Say(nLRep,NSTARTCOL+310,"________________________________________",oFont8:oFont)
		nLRep += 11
		oReport:Say(nLRep,NSTARTCOL+330,ALLTRIM(UPPER(_xResp)),oFont8:oFont)
		nLRep += 30
		oReport:Say(nLRep,NSTARTCOL+05,"DEVOLVIDO EM _____/_____/_______",oFont8:oFont)
		oReport:Say(nLRep,NSTARTCOL+310,"________________________________________",oFont8:oFont)
		nLRep += 11
		oReport:Say(nLRep,NSTARTCOL+330,"Assinatura Recebedor",oFont8:oFont)
		nLRep += 66
		oReport:Say(nLRep,NSTARTCOL+05,"EMISSÃO: "+xEmissao,oFont8:oFont)

		lPreview := .T.
		oReport:Preview()
		FreeObj(oReport)
		oReport := Nil

	EndIf

	RestArea(aAreaSM0)
	RestArea(aAreaOld)
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
	//PutSx1(cGrupo,cOrdem ,cPergunt            ,cPerSpa,cPerEng,cVar     ,cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid               ,  F3    ,cGrpSxg,cPyme,cVar01     ,cDef01     ,cDefSpa1,cDefEng1,cCnt01    ,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)
	//PutSx1(cPerg   ,"01"   ,"Do Código do Bem ?"," "    ," "    , "mv_ch1", "C"  , 10     , 0      , 0     , "G" , 'ExistCPO("SN1")'  , "SN1"  ,      ,      , "mv_par01",""	        ,""  	,""       ,""        ,""     ,""	 ,""	  ,"","","","","","","","","",{"Informe o códgio de bem inicial","para o filtro." },{},{})
	//PutSx1(cPerg   ,"02"   ,"Até Código do Bem?"," "    ," "    , "mv_ch2", "C"  , 10     , 0      , 0     , "G" , 'ExistCPO("SN1")'  , "SN1"  ,      ,      , "mv_par02",""	        ,""	    ,""	      ,""        ,""     ,""	 ,""	  ,"","","","","","","","","",{"Informe o código de bem final.","Evite utilizar um intervalo","muito grande, pois cada Bem será","utilizará uma folha para impressão!"},{},{})
	//PutSx1(cPerg   ,"03"   ,"Responsável?"      ," "    ," "    , "mv_ch3", "C"  , 60     , 0      , 0     , "G" , ''                 , ""     ,      ,      , "mv_par03",""	        ,""	    ,""	      ,""        ,""     ,""	 ,""	  ,"","","","","","","","","",{"Informe o responsável pelo bem!"},{},{})

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xMntCabec
Rotina para gerar a mascara do relatorio.

@type function
@author Gerson Ricardo Soeltl
@since 06/08/2014
@version P12.1.23

@param nLRep, Numérico, Linha posicionada recebida por referência.
@param xEntidade, Indefinido, Nome da Filial.
@param oReport, objeto, Objeto que representa o relatório.
@param oFont9N, objeto, Objeto que representa uma fonte.
@param oFont7, objeto, Objeto que representa uma fonte.
@param oFont8, objeto, Objeto que representa uma fonte.
@param oFont8N, objeto, Objeto que representa uma fonte.
@param nPag, Numércico, Número da página.
@param nPagTot, Numércico, Total de páginas.
@param cLogo, Caractere, Logo do relatório.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xMntCabec(nLRep,xEntidade,oReport,oFont9N,oFont7,oFont8,oFont8N,nPag,nPagTot,cLogo)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oReport:StartPage()
	nLRep := 0
	oReport:Box(000,NSTARTCOL,050,590,"-3")
	oReport:Say(030,NSTARTCOL+200,"TERMO DE RESPONSABILIDADE INDIVIDUAL", oFont9N:oFont)
	oReport:SayBitmap(002,NSTARTCOL+2,cLogo,180,47)
	nLRep += 62
	oReport:Say(nLRep,NSTARTCOL,"Entidade: ",oFont8:oFont)
	oReport:Say(nLRep,NSTARTCOL+55,xEntidade,oFont8N:oFont)
	nLRep += 6

	oReport:Box(nLRep,NSTARTCOL,nLRep+15,590,"-3")
	nLRep += 12
	oReport:Say(nLRep,NSTARTCOL+10,"Responsável: ",oFont8:oFont)
	oReport:Say(nLRep,NSTARTCOL+85,ALLTRIM(UPPER(_xResp)),oFont7N:oFont)
	oReport:Say(nLRep,NSTARTCOL+250,"Período de Permanencia: ",oFont8:oFont)
	oReport:Say(nLRep,NSTARTCOL+375,(Substr(Dataini,7,2)+"/"+Substr(Dataini,5,2)+"/"+Substr(Dataini,1,4)),oFont8N:oFont)
	oReport:Say(nLRep,NSTARTCOL+435,"À",oFont8:oFont)
	oReport:Say(nLRep,NSTARTCOL+450,(Substr(Datafim,7,2)+"/"+Substr(Datafim,5,2)+"/"+Substr(Datafim,1,4)),oFont8N:oFont)
	nLRep += 10

	nPag++

	//Impressão do rodape
	oReport:Line(NLIMLIN-30,NSTARTCOL,NLIMLIN-30,590,0,"-3")
	oReport:Say(NLIMLIN-20,NSTARTCOL+5,"Emissão "+xDtHrEmis,oFont7:oFont)
	oReport:Say(NLIMLIN-20,NSTARTCOL+250,"Emitido Por: "+xNomeUsr,oFont7:oFont)
	oReport:Say(NLIMLIN-20,NSTARTCOL+510,"Pagina: "+Alltrim(Str(nPag))+"/"+Alltrim(Str(nPagTot)),oFont7:oFont)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xParams
Rotina para solicitar os parametros de filtro.

@type function
@author Gerson Ricardo Soeltl
@since 06/08/2014
@version P12.1.23

@param cPerg, Caractere, Nome do grupo de perguntas.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retornando Verdadeiro ou Falso.

/*/
/*/================================================================================================================================/*/

Static function xParams(cPerg)

	Local oDlgPar
	Local nOpcA := 0
	Local _aCposAlt := {}
	Local lRet := .F.
	Private oGetD
	Private nUsado := 0
	Private cMsgErros := ""
	PRIVATE _dDtiniPerm := Date()
	PRIVATE _dDtfimPerm := Date()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	/*
	Aadd(aHeader,{Trim(X3Titulo()),;	//01
	SX3->X3_CAMPO,;		//02
	SX3->X3_PICTURE,;		//03
	SX3->X3_TAMANHO,;		//04
	SX3->X3_DECIMAL,;		//05
	SX3->X3_VALID,;		//06
	SX3->X3_USADO,;		//07
	SX3->X3_TIPO,;		//08
	SX3->X3_F3,;			//09
	SX3->X3_CONTEXT,;		//10
	SX3->X3_CBOX,;		//11
	SX3->X3_RELACAO})		//12
	*/
	IF LEN(_aHeader)==0
		Aadd(_aHeader,{"Código do Bem"   ,"N1CBASE"  ,"@!",08,0,'U_DTATFR4V(M->N1CBASE,"N1CBASE")',"€€€€€€€€€€€€€€ ","C","SN1","","",""})
		//	Aadd(_aHeader,{"Descriçao do Bem","N1DESCRIC","@!",TAMSX3("N1_DESCRIC")[1],0,'U_DTATFR4V(M->N1DESCRIC,"N1DESCRIC")',"€€€€€€€€€€€€€€ ","C",""," "," ",""})  --> JF
		Aadd(_aHeader,{"Descriçao do Bem","N1DESCRIC","@!",100,0,'U_DTATFR4V(M->N1DESCRIC,"N1DESCRIC")',"€€€€€€€€€€€€€€ ","C",""," "," ",""})
		nUsado := LEN(_aHeader)
		Aadd(_aCols,Array(nUsado+1))
		_aCols[1,nUsado+1] := .F.
		For nI := 1 To nUsado
			IF _aHeader[nI,8] == "C"
				IF !Empty(_aHeader[nI,12])
					_aCols[1][nI] := &(_aHeader[nI,12])
				ELSE
					_aCols[1][nI] := Space(_aHeader[nI,4])
				ENDIF
			ENDIF
		Next nI
	ENDIF

	_aCposAlt:= {"N1CBASE","N1DESCRIC"}

	DEFINE MSDIALOG oDlgPar TITLE "Parametros de impressão" FROM 44,5 to 410,645 OF oMainWnd PIXEL
	@ 001, 001 MSPANEL oPanTop SIZE 322, 045 OF oDlgPar //RAISED
	@ 006, 010 SAY "Responsável:" PIXEL OF oPanTop
	@ 004, 050 MSGET _xResp SIZE 140, 010 F3 "USRNOM" PIXEL OF oPanTop VALID !EMPTY(_xResp)

	@ 025,010 SAY "Periodo de Permanência:" PIXEL OF oPanTop
	@ 025,130 SAY "À" PIXEL OF oPanTop
	@ 025,080 MsGet _dDtiniPerm of oDlgPar Picture "99/99/9999" Pixel VALID !EMPTY(_dDtiniPerm)
	@ 025,150 MsGet _dDtfimPerm of oDlgPar Picture "99/99/9999" Pixel VALID !EMPTY(_dDtfimPerm)

	oGetD := MsNewGetDados():New(046, 001, 161, 322, GD_INSERT + GD_UPDATE + GD_DELETE,,, "", _aCposAlt,, 200,,,, oDlgPar, _aHeader, _aCols)
	@ 162, 001 MSPANEL oPanBotton SIZE 322, 020 OF oDlgPar //RAISED
	@ 005 ,(322-100) BUTTON oBImp PROMPT "Confirmar" SIZE 40 ,11  ACTION xVldPars(@nOpcA,@oDlgPar) OF oPanBotton PIXEL
	@ 005 ,(322-50) BUTTON oBImp PROMPT "Cancelar" SIZE 40 ,11  ACTION oDlgPar:End() OF oPanBotton PIXEL
	ACTIVATE MSDIALOG oDlgPar CENTERED

	Dataini := Dtos(_dDtiniPerm)
	Datafim := Dtos(_dDtfimPerm)

	if nOpcA == 1
		lRet := .T.
	endif

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} DTATFR3V
Rotina para validação da getdados da tela de parâmtros.

@type function
@author Gerson Ricardo Soeltl
@since 06/08/2014
@version P12.1.23

@param _cVal, Caractere, Código do Bem.
@param _cCpo, Caractere, Nome do campo.
@param lTodos, Lógico, Indica se considera todas as linhas na validação.
@param nY, Numérico, Indica a linha posicionada.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso do validação da getdados da tela de parâmtros.

/*/
/*/================================================================================================================================/*/

User Function DTATFR3V(_cVal,_cCpo,lTodos,nY)

	Local lRet := .T.
	//Local nPosC := 0
	Local cCodOut := "000000000"
	Default lTodos := .F.
	Default nY := n
	Default lAvulso := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	if Upper(Alltrim(_cCpo)) == "N1CBASE" .or. lTodos

		if lTodos
			_cVal := oGetD:aCols[nY,1]
		endif

		if Empty(_cVal)
			xMsgInfo(lTodos,"Código de bem não informado (linha: "+StrZero(nY,3)+")!")
			lRet := .F.
		ELSEIF ALLTRIM(_cVal) == cCodOut
			lRet := .T.
		ELSE
			SN1->(DBSETORDER(1))
			if !SN1->(DBSEEK(XFILIAL("SN1")+_cVal))
				xMsgInfo(lTodos,"Código de bem ("+Alltrim(_cVal)+") não encontrado (linha: "+StrZero(nY,3)+")!")
				lRet := .F.
			elseif !lTodos
				oGetD:aCols[nY,2] := Alltrim(SN1->N1_DESCRIC)+" - "+SN1->N1_XMODPR
				oGetD:oBrowse:Refresh()
			elseif !EMPTY(SN1->N1_BAIXA)
				xMsgInfo(lTodos,"Bem("+ALLTRIM(_cVal)+") (linha: "+StrZero(nY,3)+") está baixado. Favor selecionar outro!")
				lRet := .F.
			endif
		endif

		if lRet //.and. ALLTRIM(_cVal) == cCodOut
			For n1:= 1 to Len(oGetD:aCols)
				if n1 <> nY .and. !oGetD:aCols[n1,nUsado+1] .and. Upper(ALLTRIM(oGetD:aCols[n1,1]))==Upper(ALLTRIM(_cVal)) .and. oGetD:aCols[nY,1] <> cCodOut
					xMsgInfo(lTodos,"Já existe o código de bem ("+Alltrim(_cVal)+") informado na linha: "+StrZero(n1,3)+"!")
					lRet := .F.
					Exit
				endif
			Next n1
		endif

	endif

	IF Upper(ALLTRIM(_cCpo)) == "N1DESCRIC" .or. lTodos

		IF lTodos
			_cVal := oGetD:aCols[nY,2]
		ENDIF

		IF Empty(_cVal)
			xMsgInfo(lTodos,"Descrição do bem não informada (linha: "+StrZero(nY,3)+")!")
			lRet := .F.
		ENDIF

		IF lRet

			IF !Empty(_cVal)
				lAvulso := .T.
			EndIf

			IF Empty(oGetD:aCols[nY,1]) .and. !Empty(_cVal)
				oGetD:aCols[nY,1] := cCodOut
				oGetD:oBrowse:Refresh()
			ENDIF

			IF ALLTRIM(oGetD:aCols[nY,1]) == cCodOut
				For n1:= 1 to LEN(oGetD:aCols)
					IF n1 <> nY .and. !oGetD:aCols[n1,nUsado+1] .and. Upper(ALLTRIM(oGetD:aCols[n1,2]))==Upper(ALLTRIM(_cVal)) .and. ALLTRIM(oGetD:aCols[n1,1]) == cCodOut
						xMsgInfo(lTodos,"Já existe o descrição de bem ("+ALLTRIM(_cVal)+") informada na linha: "+StrZero(n1,3)+"!")
						lRet := .F.
						Exit
					ENDIF
				Next n1
			ENDIF
		ENDIF
	ENDIF

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} xVldPars
Rotina para validação dos campos da tela de parâmetros.

@type function
@author Gerson Ricardo Soeltl
@since 06/08/2014
@version P12.1.23

@param nOpcA, Númerico, Opção da rotina.
@param oDlgPar, Objeto, Objeto que representa o diálogo.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação dos campos da tela de parâmetros.

/*/
/*/================================================================================================================================/*/

Static function xVldPars(nOpcA,oDlgPar)

	Local lRet := .t.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cMsgErros := ""

	if len(oGetD:aCols) == 0
		MsgInfo("Pelo menos um bem deve ser informado!")
		lRet := .F.
		//endif

	Elseif Empty(_xResp)
		MsgInfo("Responsável não informado!")
		lRet := .F.
		//endif

	Elseif Empty(_dDtiniPerm)
		MsgInfo("Data Inicio Permanência não informada!")
		lRet := .F.
		//endif

	Elseif Empty(_dDtfimPerm)
		MsgInfo("Data Final Permanência não informada!")
		lRet := .F.
		//endif

	Elseif lRet
		For nY := 1 to Len(oGetD:aCols)
			if !oGetD:aCols[nY,nUsado+1]
				lRet := U_DTATFR3V("","",.t.,nY)
				if !lRet
					Aviso("Atenção",cMsgErros,{"OK"},3)
					Exit
				endif
			endif
		Next nY
	endif

	if lRet
		_aCols := aClone(oGetD:aCols)
		oDlgPar:End()
		nOpcA := 1
	endif

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} xMsgInfo
Rotina para exibir a mensagem de erro.

@type function
@author Gerson Ricardo Soeltl
@since 06/08/2014
@version P12.1.23

@param lTodos, Lógico, Indica se considera todas as linhas na validação.
@param cMsg, Caractere, Mensagem de erro a ser exibida.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static function xMsgInfo(lTodos,cMsg)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	if lTodos
		cMsgErros += cMsg+CRLF
	else
		MsgInfo(cMsg)
	endif
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xF3USRNOM
Rotina para criar o SXB USRNOM - Caso nao esteja.

@type function
@author Gerson Ricardo Soeltl
@since 06/08/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static function xF3USRNOM()

	//Local aOldArea := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SXB->(DBSETORDER(1))
	if !SXB->(DBSEEK("USRNOM"))
		RECLOCK("SXB",.T.)
		SXB->XB_ALIAS := "USRNOM"
		SXB->XB_TIPO := "1"
		SXB->XB_SEQ := "01"
		SXB->XB_COLUNA := "US"
		SXB->XB_DESCRI := "Usuarios"
		SXB->XB_DESCSPA := "Usuarios"
		SXB->XB_DESCENG := "Usuarios"
		SXB->(MSUNLOCK())

		RECLOCK("SXB",.T.)
		SXB->XB_ALIAS := "USRNOM"
		SXB->XB_TIPO := "5"
		SXB->XB_SEQ := "01"
		SXB->XB_CONTEM := "FULLNAME"
		SXB->(MSUNLOCK())
	endif

Return