#Include "Protheus.ch"
#Include "COLORS.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"
#Include "FILEIO.CH"
#Include "PARMTYPE.CH"

#Define IMP_SPOOL 2
#Define IMP_PDF 6
#Define NSTARTCOL 35
#Define NLIMLIN 620

/*/================================================================================================================================/*/
/*/{Protheus.doc} DTATFR02
Rotina para imprimir o relatorio demonstrativo de valores por filial.

@type function
@author Gerson Ricardo Soeltl
@since 28/07/2015
@version P12.1.2

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function DTATFR02

	Local lRet := .T.
	Local dDtLim := CTOD("")
	Local cSession := GetPrinterSession()
	Local cFilePrint := "DTATFR02_"+Dtos(MSDate())+StrTran(Time(),":","")+".PDF"
	Local oSetup := nil
	Local xPathPDF := AllTrim(GetTempPath())
	Local xPatherver := MsDocPath()
	Private oReport
	Private cPerg := "DTATFR02"
	Private cEmpini := ""   //JOSE FERNANDO
	Private cEmpfim := ""  //JOSE FERNANDO
	Private cAnoMes := ""
	Private xDtHrEmis := ""
	Private xNomeUsr := ""
	Private xNomeGrp := ""
	Private nTmEntid := 0
	Private nTmGrp := 0
	Private cPctVal := PesqPict("SN1","N1_VLAQUIS")

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	PswOrder(2)
	if PswSeek(__cUserID, .T. )
		xNomeUsr := PswRet()[1,4]
	endif
	//Alltrim(xNomeUsr)

	xDtHrEmis := DtoS(dDatabase)
	xDtHrEmis := Substr(xDtHrEmis,7,2)+"/"+Substr(xDtHrEmis,5,2)+"/"+Substr(xDtHrEmis,1,4)+"  "+Time()

	CriaSX1(cPerg)

	aDEVICE := {}
	Aadd( aDevice, "DISCO" )
	Aadd( aDevice, "SPOOL" )
	Aadd( aDevice, "EMAIL" )
	Aadd( aDevice, "EXCEL" )
	Aadd( aDevice, "HTML"  )
	Aadd( aDevice, "PDF"   )

	nLocal       	:= 2
	nOrientation 	:= 2
	cDevice     	:= "PDF"
	nPrintType      := 6

	/*
	FWMsPrinter(): New ( < cFilePrintert >, [ nDevice], [ lAdjustToLegacy], [ cPathInServer], [ lDisabeSetup ], [ lTReport], [ @oPrintSetup], [ cPrinter], [ lServer], [ lPDFAsPNG], [ lRaw], [ lViewPDF], [ nQtdCopy] ) --> oPrinte
	*/
	Private nConsNeg := 0.4 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
	Private nConsTex := 0.5 // Constante para concertar o cálculo retornado pelo GetTextWidth.

	oReport := FWMSPrinter():New(cFilePrint,nPrintType,.f.,xPatherver,.T.,,,,.T.)
	oReport:SetResolution(78)
	oReport:SetLandscape()
	oReport:SetPaperSize(DMPAPER_A4)
	oReport:SetMargin(60,60,60,60)
	oReport:cPathPDF := xPathPDF // Caso seja utilizada impressão
	oReport:SetViewPDF(.T.)

	nFlags := PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEMARGIN

	If ( !oReport:lInJob )
		oSetup := FWPrintSetup():New(nFlags, "Demonstrativo de valores por filial")
		oSetup:SetUserParms( {|| Pergunte( cPerg, .T. ) } )
		oSetup:SetPropert( PD_PRINTTYPE, nPrintType )
		oSetup:SetPropert( PD_ORIENTATION, 2 )
		oSetup:SetPropert( PD_DESTINATION, nLocal )
		oSetup:SetPropert( PD_MARGIN, {60,60,60,60} )
		oSetup:SetPropert( PD_PAPERSIZE, 2 )
		Pergunte( cPerg, .F. )
		If oSetup:Activate() == PD_OK
			Begin Sequence
				cEmpini := MV_PAR01  //JOSE FERNANDO
				cEmpfim := MV_PAR02  //JOSE FERNANDO

				Recover
				Aviso("Atenção","Período Informado é Invalido!",{"OK"})
				lRet := .F.
			End Sequence

			fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
			If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
				oReport:nDevice := IMP_SPOOL
				oReport:cPrinter := oSetup:aOptions[PD_VALUETYPE]
				oReport:lServer := .F.
				oReport:lViewPDF := .F.
			ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
				oReport:nDevice := IMP_PDF
				oReport:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
			Endif

			if lRet
				Processa({|| ReportDef(oReport,oSetup,cFilePrint)},"Aguarde... processando o relatório...!")
			endif
		else
			MsgInfo("Relatório cancelado pelo usuário!")
			oReport:Deactivate()
		endif
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
	Local cGrupoOld := ""
	Local cAliasQry := GetNextAlias()
	//Local nCount := 0
	Local cGrupoAtu := ""
	Local cSpace01 := " "
	Local oBrush := TBrush():New("",CLR_LIGHTGRAY)
	Local lSegue := .T.
	Private dPinicial := CTOD("")
	Private dPfinal := CTOD("")
	Private xEntidade := SM0->M0_NOMECOM
	Private xAjustLC := 0
	Private oFont8,oFont8N,oFont9N,oFont8NC,oFont8C
	Private nLRep := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oFont8 	  := TFontEx():New(oReport,"Arial",12,12,.F.,.T.,.F.)
	oFont7N	  := TFontEx():New(oReport,"Arial",9,9,.T.,.T.,.F.)
	oFont8N	  := TFontEx():New(oReport,"Arial",12,12,.T.,.T.,.F.)
	oFont9N	  := TFontEx():New(oReport,"Arial",16,16,.T.,.T.,.F.)
	if oReport:nDevice == 6
		oFont8NC  := TFontEx():New(oReport,"Lucida Console",12,12,.T.,.T.,.F.)
		oFont8C   := TFontEx():New(oReport,"Lucida Console",12,12,.F.,.T.,.F.)
		oFontJC   := TFontEx():New(oReport,"Lucida Console",13,13,.T.,.T.,.F.)
	else
		oFont8NC  := TFontEx():New(oReport,"Lucida Console",9,9,.T.,.T.,.F.)
		oFont8C   := TFontEx():New(oReport,"Lucida Console",9,9,.F.,.T.,.F.)
		oFontJC   := TFontEx():New(oReport,"Lucida Console",10,10,.T.,.T.,.F.)
		xAjustLC := 20
	endif

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
		N1_FILIAL AS N3_FILIAL,
		COALESCE(N3_CCONTAB,%EXP:cSpace01%) AS N3_CCONTAB,
		COALESCE(CT1_DESC01,%EXP:cSpace01%) AS CT1_DESC01,
		SUM(N1_QUANTD) AS N1_QUANTID,
		SUM(N1_VLAQUIS) AS N1_VLAQUIS,
		SUM(COALESCE(N3_VRDACM1,0)) AS N3_VRDACM1,
		SUM(COALESCE(N3_VRDMES1,0)) AS N3_VRDMES1
		FROM %table:SN1% SN1 LEFT OUTER JOIN %table:SN3% SN3 ON
		N3_FILIAL = N1_FILIAL AND
		N3_CBASE = N1_CBASE AND
		N3_ITEM = N1_ITEM AND
		SN3.%NotDel%
		LEFT OUTER JOIN %table:CT1% CT1 ON
		LEFT(CT1_FILIAL,%Exp:nTmEntid%) = LEFT(N3_FILIAL,%Exp:nTmEntid%) AND
		CT1_CONTA = N3_CCONTAB AND
		CT1.%NotDel%
		WHERE
		SN1.%NotDel% AND
		(SN1.N1_FILIAL BETWEEN %Exp:cEmpini% AND (%Exp:cEmpfim%+"01")) AND   //JOSE FERNANDO
		SN1.N1_AQUISIC BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND
		N1_QUANTD > 0 AND
		N1_STATUS <> '0'
		GROUP BY N1_FILIAL,COALESCE(N3_CCONTAB,%EXP:cSpace01%),COALESCE(CT1_DESC01,%EXP:cSpace01%)
		ORDER BY 1,2
	EndSql

	dPinicial := mv_par03
	dPfinal   := mv_par04


	if (cAliasQry)->(EOF())
		Aviso("Atenção","A consulta não retornou dados verifique os parãmetros digitados!",{"OK"})
		lSegue := .T.
	endif

	If lSegue

		aItens := {}
		cGrupoOld := ""
		aTotais := {0,0,0,0,0}
		aTotaisT := {0,0,0,0,0}
		nLn := 1
		nPagTot := 1
		While !(cAliasQry)->(EOF())


			cGrupoAtu := Alltrim((cAliasQry)->N3_FILIAL)


			if (nLn+1)>45
				If cGrupoOld <> Alltrim((cAliasQry)->N3_FILIAL)
					Aadd(aItens,{.t.,"1",(xNomeGrp+" - "+cGrupoOld),"ITENS","VLR.COMPRA","DEPRECIAÇÃO","SALDO RESIDUAL","DEPREC. MES"})
				Else
					Aadd(aItens,{.t.,"1",(xNomeGrp+" - "+cGrupoAtu),"ITENS","VLR.COMPRA","DEPRECIAÇÃO","SALDO RESIDUAL","DEPREC. MES"})
				EndIf
				nLn := 1
				nPagTot++
			endif

			if cGrupoOld <> Alltrim((cAliasQry)->N3_FILIAL)
				if !Empty(cGrupoOld)
					Aadd(aItens,{.f.,"3","",Transform(aTotais[1],cPctVal),;
					Transform(aTotais[2],cPctVal),;
					Transform(aTotais[3],cPctVal),;
					Transform(aTotais[4],cPctVal),;
					Transform(aTotais[5],cPctVal)})
					nLn += 1
				endif

				cGrupoOld := Alltrim((cAliasQry)->N3_FILIAL)
				SM0->(DbSeek(cEmpAnt+cGrupoOld))
				xNomeGrp := Alltrim(SM0->M0_NOMECOM)
				aNomgrp := STRTOKARR(xNomeGrp," ")
				xNmCom := Alltrim(SM0->M0_NOME)
				For n2:=1 to Len(aNomgrp)
					if aNomgrp[n2]$xNmCom
						xNmCom := StrTran(xNmCom,aNomgrp[n2],"",1)
					endif
				Next n2
				xNmCom := Alltrim(StrTran(xNmCom,"-","",1))
				if !Empty(xNmCom)
					xNomeGrp += ' - '+xNmCom
				endif

				aTotais := {0,0,0,0,0}
				if (nLn+1)>45
					nLn := 1
					nPagTot++
				endif
				Aadd(aItens,{nLn==1,"1",(xNomeGrp+" - "+cGrupoAtu),"ITENS","VLR.COMPRA","DEPRECIAÇÃO","SALDO RESIDUAL","DEPREC. MES"})
				nLn += 1

			endif

			(cAliasQry)->(Aadd(aItens,{.f.,"2",Alltrim((cAliasQry)->N3_CCONTAB)+Space(2)+Alltrim((cAliasQry)->CT1_DESC01),;
			Transform((cAliasQry)->N1_QUANTID,cPctVal),;
			Transform((cAliasQry)->N1_VLAQUIS,cPctVal),;
			Transform((cAliasQry)->N3_VRDACM1,cPctVal),;
			Transform((cAliasQry)->(N1_VLAQUIS-N3_VRDACM1),cPctVal),;
			Transform((cAliasQry)->N3_VRDMES1,cPctVal)}))
			nLn += 1

			aTotais[1] += (cAliasQry)->N1_QUANTID
			aTotais[2] += (cAliasQry)->N1_VLAQUIS
			aTotais[3] += (cAliasQry)->N3_VRDACM1
			aTotais[4] += (cAliasQry)->(N1_VLAQUIS-N3_VRDACM1)
			aTotais[5] += (cAliasQry)->N3_VRDMES1

			aTotaisT[1] += (cAliasQry)->N1_QUANTID
			aTotaisT[2] += (cAliasQry)->N1_VLAQUIS
			aTotaisT[3] += (cAliasQry)->N3_VRDACM1
			aTotaisT[4] += (cAliasQry)->(N1_VLAQUIS-N3_VRDACM1)
			aTotaisT[5] += (cAliasQry)->N3_VRDMES1

			(cAliasQry)->(DbSkip())

		End
		(cAliasQry)->(DbCloseArea())

		if aTotais[2] > 0 .or. aTotais[1] > 0
			if (nLn+1)>46
				Aadd(aItens,{.t.,"1",(xNomeGrp+" - "+cGrupoAtu),"ITENS","VLR.COMPRA","DEPRECIAÇÃO","SALDO RESIDUAL","DEPREC. MES"})
				nPagTot++
				nLn := 1
			endif
			Aadd(aItens,{.f.,"3","",Transform(aTotais[1],cPctVal),;
			Transform(aTotais[2],cPctVal),;
			Transform(aTotais[3],cPctVal),;
			Transform(aTotais[4],cPctVal),;
			Transform(aTotais[5],cPctVal)})

			Aadd(aItens,{.f.,"4","",Transform(aTotaisT[1],cPctVal),;
			Transform(aTotaisT[2],cPctVal),;
			Transform(aTotaisT[3],cPctVal),;
			Transform(aTotaisT[4],cPctVal),;
			Transform(aTotaisT[5],cPctVal)})
		endif

		ProcRegua(Len(aItens))
		nPag := 0
		For n1:=1 to Len(aItens)

			IncProc()

			if aItens[n1,1]
				if n1 > 1
					oReport:EndPage()
				endif
				nPag +=1
				ImpMask(cLogo,oBrush,nPagTot,nPag,aItens,n1)
			elseif aItens[n1,2] == "1"
				oReport:Fillrect( {nLRep-10, NSTARTCOL+1, nLRep, 849 }, oBrush, "-0")
				nLRep -= 1
				oReport:Say(nLRep,NSTARTCOL+5,aItens[n1,3],oFont7N:oFont)
				oReport:Say(nLRep,NSTARTCOL+370,aItens[n1,4],oFont8N:oFont)
				oReport:Say(nLRep,NSTARTCOL+435,aItens[n1,5],oFont8N:oFont)
				oReport:Say(nLRep,NSTARTCOL+530,aItens[n1,6],oFont8N:oFont)
				oReport:Say(nLRep,NSTARTCOL+615,aItens[n1,7],oFont8N:oFont)
				oReport:Say(nLRep,NSTARTCOL+735,aItens[n1,8],oFont8N:oFont)
				nLRep += 11
			elseif aItens[n1,2] == "3"
				oReport:Say(nLRep,NSTARTCOL+270+xAjustLC,aItens[n1,4],oFont8NC:oFont)
				oReport:Say(nLRep,NSTARTCOL+370+xAjustLC,aItens[n1,5],oFont8NC:oFont)
				oReport:Say(nLRep,NSTARTCOL+470+xAjustLC,aItens[n1,6],oFont8NC:oFont)
				oReport:Say(nLRep,NSTARTCOL+570+xAjustLC,aItens[n1,7],oFont8NC:oFont)
				oReport:Say(nLRep,NSTARTCOL+670+xAjustLC,aItens[n1,8],oFont8NC:oFont)
				nLRep +=13
			elseif aItens[n1,2] == "4"
				nLRep +=04
				oReport:Say(nLRep,NSTARTCOL+80,"TOTAL GERAL ::: >>>",oFontJC:oFont)
				oReport:Say(nLRep,NSTARTCOL+268+xAjustLC,aItens[n1,4],oFontJC:oFont)
				oReport:Say(nLRep,NSTARTCOL+368+xAjustLC,aItens[n1,5],oFontJC:oFont)
				oReport:Say(nLRep,NSTARTCOL+468+xAjustLC,aItens[n1,6],oFontJC:oFont)
				oReport:Say(nLRep,NSTARTCOL+568+xAjustLC,aItens[n1,7],oFontJC:oFont)
				oReport:Say(nLRep,NSTARTCOL+668+xAjustLC,aItens[n1,8],oFontJC:oFont)
				nLRep +=11
			else
				oReport:Say(nLRep,NSTARTCOL+20,aItens[n1,3],oFont8:oFont)
				oReport:Say(nLRep,NSTARTCOL+270+xAjustLC,aItens[n1,4],oFont8C:oFont)
				oReport:Say(nLRep,NSTARTCOL+370+xAjustLC,aItens[n1,5],oFont8C:oFont)
				oReport:Say(nLRep,NSTARTCOL+470+xAjustLC,aItens[n1,6],oFont8C:oFont)
				oReport:Say(nLRep,NSTARTCOL+570+xAjustLC,aItens[n1,7],oFont8C:oFont)
				oReport:Say(nLRep,NSTARTCOL+670+xAjustLC,aItens[n1,8],oFont8C:oFont)
				nLRep += 11
			endif


		Next n1

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

	Local cPeriodo := (Dtoc(MV_PAR03)+" a "+Dtoc(MV_PAR04))

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oReport:StartPage()
	nLRep := 0
	oReport:Box(000,NSTARTCOL,050,850)
	oReport:Say(030,NSTARTCOL+270,"QUADRO DEMONSTRATIVO DE VALORES - POR FILIAL", oFont9N:oFont)
	oReport:SayBitmap(002,NSTARTCOL+2,cLogo,180,47)
	nLRep += 53

	oReport:Line(nLRep,NSTARTCOL,nLRep,850)
	nLRep += 9
	oReport:Say(nLRep,NSTARTCOL,"Entidade: "+xEntidade,oFont8:oFont)
	oReport:Say(nLRep,NSTARTCOL+620,"Período: "+cPeriodo,oFont8NC:oFont)

	nLRep += 4
	oReport:Line(nLRep,NSTARTCOL,nLRep,850)
	nLRep += 3

	oReport:Box(nLRep,NSTARTCOL,650-nLRep,850)
	nLRep += 1

	oReport:Fillrect( {nLRep, NSTARTCOL+1, nLRep+11, 849 }, oBrush, "-0")
	nLRep += 9
	oReport:Say(nLRep,NSTARTCOL+5,aItens[n1,3],oFont7N:oFont)
	oReport:Say(nLRep,NSTARTCOL+370,aItens[n1,4],oFont8N:oFont)
	oReport:Say(nLRep,NSTARTCOL+435,aItens[n1,5],oFont8N:oFont)
	oReport:Say(nLRep,NSTARTCOL+530,aItens[n1,6],oFont8N:oFont)
	oReport:Say(nLRep,NSTARTCOL+615,aItens[n1,7],oFont8N:oFont)
	oReport:Say(nLRep,NSTARTCOL+735,aItens[n1,8],oFont8N:oFont)
	nLRep += 11

	//Impressao do Rodape
	oReport:Line(NLIMLIN-30,NSTARTCOL,620-30,850)
	oReport:Say(NLIMLIN-20,NSTARTCOL+5,"Emissão "+xDtHrEmis,oFont8:oFont)
	oReport:Say(NLIMLIN-20,NSTARTCOL+360,"Emitido Por: "+xNomeUsr,oFont8:oFont)
	oReport:Say(NLIMLIN-20,NSTARTCOL+745,"Pagina: "+Alltrim(Str(nPag))+"/"+Alltrim(Str(nPagTot)),oFont8:oFont)

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

	aAdd(aP,{"Filial De"   	    ,"C",8 ,0,"G","","SM0"	,"","","","",""})                            // MV_PAR01
	aAdd(aP,{"Filial Ate"  	    ,"C",8 ,0,"G","","SM0"	,"","","","",""})                            // MV_PAR02
	aAdd(aP,{"Periodo De"	    ,"D",8 ,0,"G","",""	  	,"","","","",""})                            // MV_PAR03
	aAdd(aP,{"Periodo Ate"	    ,"D",8 ,0,"G","",""	  	,"","","","",""})                            // MV_PAR04

	//-----------------------------------------------

	aAdd(aHelp,{"Informe a filial inicial."})
	aAdd(aHelp,{"Informe a filial final."})
	aAdd(aHelp,{"Informe o Período inicial."})
	aAdd(aHelp,{"Informe o Período final."})


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