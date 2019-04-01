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
/*/{Protheus.doc} DTATFR04
Rotina para imprimir o relatorio Guia de Barreira e Isen��o de Imposto.

@type function
@author Gerson Ricardo Soeltl
@since 28/07/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function DTATFR04

	Local lRet := .T.
	Local dDtLim := CTOD("")
	Local cSession := GetPrinterSession()
	Local cFilePrint := "DTATFR04_"+Dtos(MSDate())+StrTran(Time(),":","")+".PDF"
	Local oSetup := nil
	Local xPathPDF := ALLTRIM(GetTempPath())
	Local xPatherver := MsDocPath()
	Local lSegue := .T.
	Private oReport
	Private cPerg := "DTATFR04"
	Private cAnoMes := ""
	Private xDtHrEmis := ""
	Private xNomeUsr := ""
	Private xNomeGrp := ""
	Private nTmEntid := 0
	Private nTmGrp := 0
	Private cPctVal := PesqPict("SN1","N1_VLAQUIS")
	Private _aCols := {}
	Private _aHeader := {}
	Private _xResp := ""
	Private _aXSM := {}
	Private _nOrig := 1
	Private _nDest := 1
	Private _cMemDest := ""

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	xNomeUsr := Alltrim(UsrFullName(__cUserID)) //UsrRetName(__cUserID)
	_xResp := Padr(xNomeUsr,50)

	xF3USRNOM()

	IF !xParams(cPerg)
		lSegue := .F.
	ENDIF

	If lSegue

		xDtHrEmis := DtoS(dDatabase)
		xDtHrEmis := SUBSTR(xDtHrEmis,7,2) + "/" + SUBSTR(xDtHrEmis,5,2) + "/" + SUBSTR(xDtHrEmis,1,4) + " " + Time()

		CriaSX1(cPerg)

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
		Private nConsNeg := 0.4 // Constante para concertar o c�lculo retornado pelo GetTextWidth para fontes em negrito.
		Private nConsTex := 0.5 // Constante para concertar o c�lculo retornado pelo GetTextWidth.

		oReport := FWMSPrinter():New(cFilePrint,nPrintType,.f.,xPatherver,.T.,,,,.T.)
		oReport:SetResolution(78)
		oReport:SetPortrait()
		oReport:SetPaperSize(DMPAPER_A4)
		oReport:SetMargin(60,60,60,60)
		oReport:cPathPDF := xPathPDF // Caso seja utilizada impress�o
		oReport:SetViewPDF(.T.)

		nFlags := PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEMARGIN

		IF ( !oReport:lInJob )

			//	oSetup := FWPrintSetup():New(nFlags, "Guia de Barreira e Isen��o de Imposto")
			//oSetup:SetUserParms( {|| xParams(cPerg) } )
			//	oSetup:SetPropert( PD_PRINTTYPE, nPrintType )
			//	oSetup:SetPropert( PD_ORIENTATION, 1 )
			//	oSetup:SetPropert( PD_DESTINATION, nLocal )
			//	oSetup:SetPropert( PD_MARGIN, {60,60,60,60} )
			//	oSetup:SetPropert( PD_PAPERSIZE, 2 )

			//	IF oSetup:Activate() == PD_OK

			//		fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
			//		IF oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
			//			oReport:nDevice := IMP_SPOOL
			//			oReport:cPrinter := oSetup:aOptions[PD_VALUETYPE]
			//			oReport:lServer := .F.
			//			oReport:lViewPDF := .F.
			//		ELSEIF oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
			//			oReport:nDevice := IMP_PDF
			//			oReport:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
			//		ENDIF

			//		IF lRet
			Processa({|| ReportDef(oReport,oSetup,cFilePrint)},"Aguarde... processando o relat�rio...!")
			//		ENDIF
			//	ELSE
			//		oReport:Deactivate()
			//	ENDIF
		ENDIF

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportDef
Sub-Rotina para gerar o detalhe do relatorio demonstrativo de valores por grupo.

@type function
@author Gerson Ricardo Soeltl
@since 28/07/2015
@version P12.1.23

@param oReport, Objeto, Objeto que representa o relat�rio.
@param oSetup, Objeto, objeto que permite visualizar e imprimir relat�rio.
@param cFilePrint, Caractere, Nome do arquivo de relat�rio a ser criado.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function ReportDef(oReport,oSetup,cFilePrint)

	Local aAreaOld := GetArea()
	Local aAreaSM0 := SM0->(GetArea())
	Local cStartPath := GetSrvProfString("Startpath","")
	Local cLogo := ""
	Local cLayout := ""
	//Local cAliasQry := GetNextAlias()
	Local nCount := 0
	Local xEmissao := ALLTRIM(Str(Day(dDatabase)))+" de "+LOWER(MesExtenso(Month(dDatabase)))+" de "+ALLTRIM(Str(Year(dDatabase)))
	//Local oBrush := TBrush():New("",CLR_LIGHTGRAY)
	Local xEntidade := ""
	//Local xAjustLC := 0
	Local oFont8,oFont8N,oFont9N,oFont7
	Local nLRep := 0
	Local nLin := 0
	//Local nLin2 := 0
	Local nTotLn := 51
	Local _cTexto := ""
	Local _nTLn := 5
	//Local	xChave := ""
	Local lSegue := .T.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SM0->(DbSeek(cEmpAnt+ALLTRIM(_aXSM[_nOrig,2])))

	cLogo := cStartPath + "LGRL" + SM0->M0_CODIGO + ALLTRIM(SM0->M0_CODFIL) + ".BMP" 	// Empresa+Filial -- 300/92
	xEntidade := _aXSM[_nOrig,1]

	oFont6N  := TFontEx():New(oReport,"Lucida Console",7,7,.T.,.T.,.F.)
	//oFont6N	:= TFontEx():New(oReport,"Arial",6,6,.T.,.T.,.F.)
	oFont7	:= TFontEx():New(oReport,"Arial",8,8,.F.,.T.,.F.)
	oFont8 	:= TFontEx():New(oReport,"Arial",10,10,.F.,.T.,.F.)
	oFont11 	:= TFontEx():New(oReport,"Arial",12,12,.F.,.T.,.F.)
	oFont8N	:= TFontEx():New(oReport,"Arial",12,12,.T.,.T.,.F.)
	oFont9N	:= TFontEx():New(oReport,"Arial",16,16,.T.,.T.,.F.)

	cLayout := Trim(FWSM0Layout())
	nTmEntid := 0
	For n1 := 1 to LEN(cLayout)
		IF SUBSTR(cLayout,n1,1) $ "EU" //E - Empresa, U - UF, F - Filial
			nTmEntid++
		ENDIF

		IF SUBSTR(cLayout,n1,1) $ "E"
			nTmGrp++
		ENDIF
	Next n1

	IF !File( cLogo )
		cLogo := cStartPath + "LGRL" + cEmpAnt + ".BMP" 						// Empresa
	ENDIF

	IF LEN(_aCols)<=0
		Aviso("Aten��o","A consulta n�o retornou dados verifique os par�metros digitados!",{"OK"})
		lSegue := .F.
	ENDIF

	If lSegue

		nCount := LEN(_aCols)+20
		nPag := 0
		nLin := 0
		nPagTot := nCount/nTotLn
		IF nPagTot > Int(nPagTot)
			nPagTot := Int(nPagTot)+1
		ENDIF

		IF ((nCount - (nPagTot*nTotLn)) > 4) .or. (nTotLn == nCount)
			nPagTot +=1
		ENDIF

		IF nCount < nTotLn .and. (nCount+2)>nTotLn
			nPagTot +=1
		ENDIF

		ProcRegua(nCount)

		For nY := 1 to LEN(_aCols)
			IF (nLin+1) > nTotLn .or. nLin == 0

				IF nLin > 0
					oReport:ENDPage()
				ENDIF

				nLin := 0

				xMntCabec(@nLRep,xEntidade,oReport,oFont9N,oFont7,oFont8,oFont11,oFont8N,@nPag,nPagTot,cLogo)

				IF nPag == 1
					oReport:Box(nLRep,NSTARTCOL,nLRep+100,590,"-3")
					nLRep += 15
					_cTexto := _aXSM[_nOrig,13]+_aXSM[_nOrig,14]+_aXSM[_nOrig,15]
					_cTexto := ALLTRIM(_cTexto)
					_cTexto := CapitalAce(_cTexto)
					xRepLine(oReport,oFont11,_cTexto,_nTLn,@nLRep)
					nlRep := 197
					nLin += 9
				ENDIF

				//oReport:Fillrect( {nLRep, NSTARTCOL, nLRep+20, 590 }, oBrush, "-0")
				oReport:Line(nLRep,NSTARTCOL,nLRep,590)
				oReport:Line(nLRep,NSTARTCOL,nLRep+20,NSTARTCOL)
				oReport:Line(nLRep,590,nLRep+20,590)
				oReport:Line(nLRep+20,NSTARTCOL,nLRep+20,590)
				nLRep += 13
				oReport:Say(nLRep,NSTARTCOL+10,"Rela��o de Bens - " + cFilAnt,oFont8N:oFont)
				nLRep += 7
			ENDIF

			nLin += 1

			oReport:Line(nLRep,NSTARTCOL,nLRep+14,NSTARTCOL)
			oReport:Line(nLRep,590,nLRep+14,590)
			oReport:Line(nLRep+14,NSTARTCOL,nLRep+14,590)
			If _aCols[nY,1]!= "000000000"
				oReport:Say(nLRep+11,NSTARTCOL+10,_aCols[nY,1]+" - "+_aCols[nY,2],oFont8:oFont)
			Else
				oReport:Say(nLRep+11,NSTARTCOL+10,_aCols[nY,2],oFont7:oFont)
			EndIf
			nLRep += 14

		Next nY

		IF nPag < nPagTot
			oReport:ENDPage()
			xMntCabec(@nLRep,xEntidade,oReport,oFont9N,oFont7,oFont8,oFont11,oFont8N,@nPag,nPagTot,cLogo)
		ELSE
			nLRep += 7
		ENDIF
		// alterar nLRep da linha abaixo >> jose fernando (define a altura do retangulo
		oReport:Box(nLRep,NSTARTCOL,nLRep+180,590,"-3")
		//oReport:Fillrect( {nLRep+1, NSTARTCOL+1, nLRep+18, 589 }, oBrush, "-0")
		nLEND := nLRep+168
		nLRep += 14
		oReport:Say(nLRep,NSTARTCOL+10,"Destino",oFont8N:oFont)
		nLRep += 6
		oReport:Line(nLRep,NSTARTCOL,nLRep,590)
		nLRep += 20

		IF Empty(_cMemDest)
			_cTexto := ALLTRIM(_aXSM[_nDest,2]) + " | " +;
			ALLTRIM(_aXSM[_nDest,1]) + " | " +;
			ALLTRIM(_aXSM[_nDest,3]) + " | " +;
			"CNPJ: " + ALLTRIM(Transform(_aXSM[_nDest,9],"@R 99.999.999/9999-99")) + " - " +;
			"Inscri��o Estadual: " + ALLTRIM(_aXSM[_nDest,10]) + " - " +;
			"Endere�o: " + ALLTRIM(_aXSM[_nDest,4]) + ", " +;
			ALLTRIM(_aXSM[_nDest,5]) + ", " +;
			ALLTRIM(_aXSM[_nDest,6]) + "/" +;
			ALLTRIM(_aXSM[_nDest,7]) + ", " +;
			"CEP: " + ALLTRIM(Transform(_aXSM[_nDest,8],"@R 99.999-999")) + " | " +;
			"Respons�vel: " + ALLTRIM(_aXSM[_nDest,12]) + " - " +;
			"Fone: "+ALLTRIM(_aXSM[_nDest,11])
		ELSE
			_cTexto := StrTran(_cMemDest,(Chr(13)+Chr(10))," ")
			_cTexto := StrTran(_cTexto,(Chr(13)+Chr(10))," ")
		ENDIF

		//_cTexto := CapitalAce(_cTexto)

		xRepLine(oReport,oFont8,_cTexto,_nTLn,@nLRep)

		//oReport:Say(nLEND,NSTARTCOL+10,"Recebido em _____/_____/________",oFont8:oFont)
		//oReport:Say(nLEND,NSTARTCOL+240,"Recebido por _______________________________________",oFont8:oFont)
		oReport:Say(nLEND+20,NSTARTCOL+5,"Emiss�o: "+xEmissao,oFont7:oFont)

		// 04/12/2018 - Daniel Fl�vio
		// Imprime quadros de assinatura na pr�xima p�gina
		IF ((nPag < nPagTot) .OR. (nLEND+230 > (NLIMLIN - 30)))
			oReport:ENDPage()
			xMntCabec(@nLRep,xEntidade,oReport,oFont9N,oFont7,oFont8,oFont11,oFont8N,@nPag,nPagTot++,cLogo)
			nLEND := 50
		ELSE
			nLRep += 7
		ENDIF

		oReport:Box(nLEND,NSTARTCOL,nLEND+240,590,"-3")
		oReport:Box(nLEND,NSTARTCOL,nLEND+240,295,"-3")
		//oReport:Box(nLEND+2,NSTARTCOL+375,nLEND+14,NSTARTCOL+390,"-8")


		oReport:Say(nLEND+10,NSTARTCOL+5,"AUTORIZO RETIRAR PARA:|__|-ATIVIDADES EXTERNAS |__|-MANUTEN��O ",oFont6N:oFont)
		oReport:Say(nLEND+10,NSTARTCOL+270,"AUTORIZO TRANSFERIR PARA OUTRA UNIDADE: ",oFont6N:oFont)
		oReport:Line(nLEND+40,NSTARTCOL,nLEND+40,590)
		oReport:Say(nLEND+50,NSTARTCOL+5,"ATIVIDADES EXTERNAS(nome e telefone): ",oFont6N:oFont)
		oReport:Say(nLEND+50,NSTARTCOL+270,"ASSINATURA DA ORIGEM:  ",oFont6N:oFont)
		oReport:Line(nLEND+80,NSTARTCOL,nLEND+80,590)
		oReport:Say(nLEND+90,NSTARTCOL+5,"MANUTEN��O(nome e telefone): ",oFont6N:oFont)
		oReport:Say(nLEND+90,NSTARTCOL+270,"ASSINATURA DO DESTINO: ",oFont6N:oFont)
		oReport:Line(nLEND+120,NSTARTCOL,nLEND+120,590)
		oReport:Say(nLEND+130,NSTARTCOL+5,"RECEBIDO POR:                       DEVOLVER AT�: ___/___/____ ",oFont6N:oFont)
		oReport:Say(nLEND+150,NSTARTCOL+270,"UNID.DESTINO: Escanear a 1�via assinada e enviar por e-mail para GEMAT",oFont6N:oFont)
		oReport:Line(nLEND+160,NSTARTCOL,nLEND+160,590)
		oReport:Say(nLEND+170,NSTARTCOL+5,"DEVOLVIDO POR:  ",oFont6N:oFont)
		oReport:Say(nLEND+170,NSTARTCOL+270,"DATA: ____/____/______ ",oFont6N:oFont)
		oReport:Line(nLEND+200,NSTARTCOL,nLEND+200,590)
		oReport:Say(nLEND+210,NSTARTCOL+5,"RECEBIDO POR:                                 EM: ___/___/____ ",oFont6N:oFont)
		oReport:Say(nLEND+230,NSTARTCOL+270,"1�VIA: DESTINO  /  2�VIA: TRANSPORTADOR  /  3�VIA: ORIGEM ",oFont6N:oFont)

		//oReport:EndPage()
		//oReport:Say(nLEND+32,NSTARTCOL+10,"Devolver At�: _____/_____/_______  Devolvido em: _____/_____/_______ ",oFont8N:oFont)
		//oReport:Say(nLEND+32,NSTARTCOL+10,"AUTORIZO: _____________________",oFont8N:oFont)
		//oReport:Say(nLEND+52,NSTARTCOL+10,"Recebido por: ___________________________________ ",oFont8N:oFont)
		// Final alteracao - JF

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

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@deprecated Fun�ao PuSx1 foi descontinuada.
/*/
/*/================================================================================================================================/*/

Static Function CriaSX1(cPerg)

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+---------------------------------------------------------------+
	//| Inclui pergunta no SX1                                        |
	//+---------------------------------------------------------------+
	//PutSx1(cGrupo,cOrdem ,cPergunt            ,cPerSpa,cPerEng,cVar     ,cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid               ,  F3    ,cGrpSxg,cPyme,cVar01     ,cDef01     ,cDefSpa1,cDefEng1,cCnt01    ,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)
	//PutSx1(cPerg   ,"01"   ,"Do C�digo do Bem ?"," "    ," "    , "mv_ch1", "C"  , 10     , 0      , 0     , "G" , 'ExistCPO("SN1")'  , "SN1"  ,      ,      , "mv_par01",""	        ,""  	,""       ,""        ,""     ,""	 ,""	  ,"","","","","","","","","",{"Informe o c�dgio de bem inicial","para o filtro." },{},{})
	//PutSx1(cPerg   ,"02"   ,"At� C�digo do Bem?"," "    ," "    , "mv_ch2", "C"  , 10     , 0      , 0     , "G" , 'ExistCPO("SN1")'  , "SN1"  ,      ,      , "mv_par02",""	        ,""	    ,""	      ,""        ,""     ,""	 ,""	  ,"","","","","","","","","",{"Informe o c�digo de bem final.","Evite utilizar um intervalo","muito grande, pois cada Bem ser�","utilizar� uma folha para impress�o!"},{},{})
	//PutSx1(cPerg   ,"03"   ,"Respons�vel?"      ," "    ," "    , "mv_ch3", "C"  , 60     , 0      , 0     , "G" , ''                 , ""     ,      ,      , "mv_par03",""	        ,""	    ,""	      ,""        ,""     ,""	 ,""	  ,"","","","","","","","","",{"Informe o respons�vel pelo bem!"},{},{})

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xMntCabec
Rotina para gerar a mascara do relatorio.

@type function
@author Gerson Ricardo Soeltl
@since 06/08/2014
@version P12.1.23

@param nLRep, Num�rico, Linha posicionada recebida por refer�ncia.
@param xEntidade, Indefinido, Nome da Filial.
@param oReport, objeto, Objeto que representa o relat�rio.
@param oFont9N, objeto, Objeto que representa uma fonte.
@param oFont7, objeto, Objeto que representa uma fonte.
@param oFont8, objeto, Objeto que representa uma fonte.
@param oFont8N, objeto, Objeto que representa uma fonte.
@param nPag, Num�rcico, N�mero da p�gina.
@param nPagTot, Num�rcico, Total de p�ginas.
@param cLogo, Caractere, Logo do relat�rio.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function xMntCabec(nLRep,xEntidade,oReport,oFont9N,oFont7,oFont8,oFont11,oFont8N,nPag,nPagTot,cLogo)

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oReport:StartPage()
	nLRep := 0
	oReport:Box(000,NSTARTCOL,050,590,"-3")
	oReport:Say(030,NSTARTCOL+200,"Guia de Barreira e Isen��o de Impostos", oFont9N:oFont)
	oReport:SayBitmap(002,NSTARTCOL+2,cLogo,180,47)
	nLRep += 62
	oReport:Say(nLRep,NSTARTCOL,"Entidade: " + xEntidade,oFont7:oFont)
	nLRep += 6

	oReport:Box(nLRep,NSTARTCOL,nLRep+15,590,"-3")
	nLRep += 12
	oReport:Say(nLRep,NSTARTCOL+10,"Respons�vel: " + _xResp,oFont8N:oFont)
	nLRep += 10

	nPag++

	//Impress�o do rodape
	oReport:Line(NLIMLIN-30,NSTARTCOL,NLIMLIN-30,590,0,"-3")
	oReport:Say(NLIMLIN-20,NSTARTCOL+5,"Emitido em: " + xDtHrEmis + " - " + "Emitido por: " + xNomeUsr, oFont7:oFont)
	//oReport:Say(NLIMLIN-20,NSTARTCOL+510,"P�gina: " + ALLTRIM(Str(nPag)) + "/" + ALLTRIM(Str(nPagTot)),oFont7:oFont)
	oReport:Say(NLIMLIN-20,NSTARTCOL+510,"P�gina: " + StrZero(nPag,2),oFont7:oFont)

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

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Retornando Verdadeiro ou Falso.

/*/
/*/================================================================================================================================/*/
Static function xParams(cPerg)

	Local nOpcA := 0
	Local _aCposAlt := {}
	Local cAliasQry := GetNextAlias()
	Local aCBOri := {}
	Local aCBDes := {}
	Local cCBOri := Space(40)
	Local cCBDes := Space(40)
	Local cQuery := ""
	Local lRet := .F.
	Private oDlgPar,oCBOri,oCBDes,oMemDest
	Private oGetD
	Private nUsado := 0
	Private cMsgErros := ""

	//--< Log das Personaliza��es >-----------------------------
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
		Aadd(_aHeader,{"C�digo do Bem"   ,"N1CBASE"  ,"@!",08,0,'U_DTATFR4V(M->N1CBASE,"N1CBASE")',"���������������","C","SN1","","",""})
		//	Aadd(_aHeader,{"Descri�ao do Bem","N1DESCRIC","@!",TAMSX3("N1_DESCRIC")[1],0,'U_DTATFR4V(M->N1DESCRIC,"N1DESCRIC")',"���������������","C",""," "," ",""})  --> JF
		Aadd(_aHeader,{"Descri�ao do Bem","N1DESCRIC","@!",100,0,'U_DTATFR4V(M->N1DESCRIC,"N1DESCRIC")',"���������������","C",""," "," ",""})
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

	cQuery := "SELECT "
	cQuery += "EMPRESA,"
	cQuery += "FILIAL,"
	cQuery += "DESCRI��O AS DESCRIC,"
	cQuery += "ENDERECO,"
	cQuery += "BAIRRO,"
	cQuery += "CIDADE,"
	cQuery += "ESTADO,"
	cQuery += "CEP,"
	cQuery += "CNPJ,"
	cQuery += "INSC_ESTADUAL AS INSCEST,"
	cQuery += "TELEFONE,"
	cQuery += "RESPONSAVEL AS RESP,"
	cQuery += "CONVERT(VARCHAR(254),SUBSTRING(GUIA_BARREIRA,1,254)) AS GUIABAR1,"
	cQuery += "CONVERT(VARCHAR(254),SUBSTRING(GUIA_BARREIRA,255,254)) AS GUIABAR2,"
	cQuery += "CONVERT(VARCHAR(254),SUBSTRING(GUIA_BARREIRA,509,254)) AS GUIABAR3 "
	cQuery += "FROM SIGAMAT " // Espec�fico do Cliente
	cQuery += "WHERE "
	cQuery += "D_E_L_E_T_='' AND LEFT(FILIAL,4)='"+LEFT(cFilAnt,4)+"'"
	cQuery += "ORDER BY 2"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.f.,.t.)
	(cAliasQry)->(DbEval({|| Aadd(_aXSM,{EMPRESA,;	//01
	FILIAL,;	//02
	DESCRIC,;	//03
	ENDERECO,;	//04
	BAIRRO,;	//05
	CIDADE,;	//06
	ESTADO,;	//07
	CEP,;		//08
	CNPJ,;		//09
	INSCEST,;	//10
	TELEFONE,;	//11
	RESP,;		//12
	GUIABAR1,;	//13
	GUIABAR2,;	//14
	GUIABAR3})},,{|| !EOF()}))
	(cAliasQry)->(DbCloseArea())
	AEval(_aXSM,{|x| Aadd(aCBOri,ALLTRIM(x[2]) + " - " + ALLTRIM(x[3])+ " - " + ALLTRIM(x[6]))})
	aCBDes := aClone(aCBOri)

	DEFINE MSDIALOG oDlgPar TITLE "Parametros de Impress�o" FROM 44,5 to 510,645 OF oMainWnd PIXEL
	@ 001, 001 MSPANEL oPanTop SIZE 322, 075 OF oDlgPar //RAISED
	@ 006, 010 SAY "Respons�vel:" PIXEL OF oPanTop
	@ 004, 070 MSGET _xResp SIZE 140, 010 F3 "USRNOM" PIXEL OF oPanTop VALID !EMPTY(_xResp)
	@ 018, 010 SAY "Unidade de Origem:" PIXEL OF oPanTop
	@ 018, 070 MSCOMBOBOX oCBOri VAR cCBOri ITEMS aCBOri SIZE 140,010 PIXEL OF oPanTop ON CHANGE(_nOrig := oCBOri:nAt)
	@ 030, 010 SAY "Unidade de Destino:" PIXEL OF oPanTop
	@ 030, 070 MSCOMBOBOX oCBDes VAR cCBDes ITEMS aCBDes SIZE 140,010 PIXEL OF oPanTop WHEN Empty(_cMemDest) ON CHANGE(_nDest := oCBDes:nAt)
	@ 042, 010 SAY "Outro Destino:" PIXEL OF oPanTop
	@ 042, 070 GET oMemDest VAR _cMemDest MEMO SIZE 240, 30 PIXEL OF oPanTop
	oGetD := MsNewGetDados():New(076, 001, 210, 322, GD_INSERT+ GD_UPDATE  + GD_DELETE,,, "", _aCposAlt,, 200,,,, oDlgPar, _aHeader, _aCols)
	@ 211, 001 MSPANEL oPanBotton SIZE 322, 020 OF oDlgPar //RAISED
	@ 005 ,(322-100) BUTTON oBImp PROMPT "Confirmar" SIZE 40 ,11  ACTION xVldPars(@nOpcA,@oDlgPar) OF oPanBotton PIXEL
	@ 005 ,(322-50) BUTTON oBImp PROMPT "Cancelar" SIZE 40 ,11  ACTION oDlgPar:END() OF oPanBotton PIXEL

	oCBOri:nAt := ASCAN(aCBOri,{|x| SUBSTR(x,1,8) == cFilAnt})
	oCBDes:nAt := ASCAN(aCBOri,{|x| SUBSTR(x,1,8) == cFilAnt})

	ACTIVATE MSDIALOG oDlgPar CENTERED

	IF nOpcA == 1
		lRet := .T.
	ENDIF

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} DTATFR4V
Rotina para valida��o da getdados da tela de par�mtros.

@type function
@author Gerson Ricardo Soeltl
@since 06/08/2014
@version P12.1.23

@param _cVal, Caractere, C�digo do Bem.
@param _cCpo, Caractere, Nome do campo.
@param lTodos, L�gico, Indica se considera todas as linhas na valida��o.
@param nY, Num�rico, Indica a linha posicionada.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso do valida��o da getdados da tela de par�mtros.

/*/
/*/================================================================================================================================/*/
User Function DTATFR4V(_cVal,_cCpo,lTodos,nY)

	Local lRet := .T.
	//Local nPosC := 0
	Local cCodOut := "000000000"
	Default lTodos := .F.
	Default nY := n

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF Upper(ALLTRIM(_cCpo)) == "N1CBASE" .or. lTodos

		IF lTodos
			_cVal := oGetD:aCols[nY,1]
		ENDIF

		IF Empty(_cVal)
			xMsgInfo(lTodos,"C�digo de bem n�o informado (linha: "+StrZero(nY,3)+")!")
			lRet := .F.
		ELSEIF ALLTRIM(_cVal) == cCodOut
			lRet := .T.
		ELSE
			SN1->(DBSETORDER(1))
			IF !SN1->(DBSEEK(XFILIAL("SN1")+_cVal))
				xMsgInfo(lTodos,"C�digo de bem ("+ALLTRIM(_cVal)+") n�o encontrado (linha: "+StrZero(nY,3)+")!")
				lRet := .F.
			ELSEIF !lTodos
				oGetD:aCols[nY,2] := Alltrim(SN1->N1_DESCRIC)+" - "+SN1->N1_XMODPR
				oGetD:oBrowse:Refresh()
			ELSE
				IF !EMPTY(SN1->N1_BAIXA)
					xMsgInfo(lTodos,"Bem("+ALLTRIM(_cVal)+") (linha: "+StrZero(nY,3)+") est� baixado. Favor selecionar outro!")
					lRet := .F.
				ENDIF
			ENDIF
		ENDIF

		IF lRet //.and. ALLTRIM(_cVal) == cCodOut
			For n1:= 1 to LEN(oGetD:aCols)
				IF n1 <> nY .and. !oGetD:aCols[n1,nUsado+1] .and. Upper(ALLTRIM(oGetD:aCols[n1,1]))==Upper(ALLTRIM(_cVal)) .and. oGetD:aCols[nY,1] <> cCodOut
					xMsgInfo(lTodos,"J� existe o c�digo de bem ("+ALLTRIM(_cVal)+") informado na linha: "+StrZero(n1,3)+"!")
					lRet := .F.
					Exit
				ENDIF
			Next n1
		ENDIF

	ENDIF

	IF Upper(ALLTRIM(_cCpo)) == "N1DESCRIC" .or. lTodos

		IF lTodos
			_cVal := oGetD:aCols[nY,2]
		ENDIF

		IF Empty(_cVal)
			xMsgInfo(lTodos,"Descri��o do bem n�o informada (linha: "+StrZero(nY,3)+")!")
			lRet := .F.
		ENDIF

		IF lRet

			IF Empty(oGetD:aCols[nY,1]) .and. !Empty(_cVal)
				oGetD:aCols[nY,1] := cCodOut
				oGetD:oBrowse:Refresh()
			ENDIF

			IF ALLTRIM(oGetD:aCols[nY,1]) == cCodOut
				For n1:= 1 to LEN(oGetD:aCols)
					IF n1 <> nY .and. !oGetD:aCols[n1,nUsado+1] .and. Upper(ALLTRIM(oGetD:aCols[n1,2]))==Upper(ALLTRIM(_cVal)) .and. ALLTRIM(oGetD:aCols[n1,1]) == cCodOut
						xMsgInfo(lTodos,"J� existe o descri��o de bem ("+ALLTRIM(_cVal)+") informada na linha: "+StrZero(n1,3)+"!")
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
Rotina para valida��o dos campos da tela de par�metros.

@type function
@author Gerson Ricardo Soeltl
@since 06/08/2014
@version P12.1.23

@param nOpcA, N�merico, Op��o da rotina.
@param oDlgPar, Objeto, Objeto que representa o di�logo.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso para valida��o dos campos da tela de par�metros.

/*/
/*/================================================================================================================================/*/
Static function xVldPars(nOpcA,oDlgPar)

	Local lRet := .t.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cMsgErros := ""

	IF LEN(oGetD:aCols) == 0
		MsgInfo("Pelo menos um bem deve ser informado!")
		lRet := .F.
	ENDIF

	IF Empty(_xResp)
		MsgInfo("Respons�vel n�o informado!")
		lRet := .F.
	ENDIF

	IF lRet
		For nY := 1 to LEN(oGetD:aCols)
			IF !oGetD:aCols[nY,nUsado+1]
				lRet := U_DTATFR4V("","",.t.,nY)
				IF !lRet
					Aviso("Aten��o",cMsgErros,{"OK"},3)
					Exit
				ENDIF
			ENDIF
		Next nY
	ENDIF

	IF lRet
		_aCols := aClone(oGetD:aCols)
		oDlgPar:END()
		nOpcA := 1
	ENDIF

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} xMsgInfo
Rotina para exibir a mensagem de erro.

@type function
@author Gerson Ricardo Soeltl
@since 06/08/2014
@version P12.1.23

@param lTodos, L�gico, Indica se considera todas as linhas na valida��o.
@param cMsg, Caractere, Mensagem de erro a ser exibida.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static function xMsgInfo(lTodos,cMsg)

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF lTodos
		cMsgErros += cMsg+CRLF
	ELSE
		MsgInfo(cMsg)
	ENDIF
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xRepLine
Repete uma linha.

@type function
@author Gerson Ricardo Soeltl
@since 06/08/2014
@version P12.1.23

@param oReport, Objeto, Objeto que representa o relat�rio.
@param oFont11, Objeto, Obejto que representa uma fonte.
@param _cTexto, Carcactere, Texto a ser repetir.
@param _nTLn, Num�rico, Qunatidade de repeti��es.
@param nLRep, Num�rico, Eapa�o entre a linhas.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static function xRepLine(oReport,oFont11,_cTexto,_nTLn,nLRep)
	Local _cTexto1 := ""
	Local _nStart := 1
	Local _nRat := 0
	Local _nLnT := 0
	Local _nTmP := 0

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	While _nLnT <= _nTLn

		_nTmP := 115
		_cTexto1 := ALLTRIM(SUBSTR(_cTexto,_nStart,_nTmP))

		IF (LEN(_cTexto)-_nStart) <= _nTmP
			_nRat := 0
		ELSE
			_nRat := Rat(" ",_cTexto1)
			IF _nRat > 0
				_cTexto1 := SUBSTR(_cTexto1,1,_nRat-1)
			ENDIF
		ENDIF

		IF _nRat > 0
			oReport:Say(nLRep,NSTARTCOL+10,_cTexto1,oFont11:oFont)
			nLRep += 11
			_nStart += _nRat
			_nLnT+=1
		ELSE
			IF _nStart < LEN(_cTexto)
				oReport:Say(nLRep,NSTARTCOL+10,_cTexto1,oFont11:oFont)
				nLRep += 11
			ENDIF
			Exit
		ENDIF
	END

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xF3USRNOM
Rotina para criar o SXB USRNOM - Caso nao esteja.

@type function
@author Gerson Ricardo Soeltl
@since 06/08/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static function xF3USRNOM()

	//Local aOldArea := GetArea()

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SXB->(DBSETORDER(1))
	IF !SXB->(DBSEEK("USRNOM"))
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
	ENDIF

Return