#Include "Protheus.ch"
#Include "COLORS.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"
#Include "FILEIO.CH"
#Include "PARMTYPE.CH"
#Include "Topconn.ch"

#Define IMP_SPOOL 2
#Define IMP_PDF 6
#Define NSTARTCOL 13
#Define NLIMLIN 620

/*/================================================================================================================================/*/
/*/{Protheus.doc} XCOMCT02
Impressao do Contrato.

@type function
@author José Fernando Castroviejo Vilela
@since  16/08/2017
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function XCOMCT02

	Local cFilePrint     := "Contrato_"+Dtos(MSDate())+StrTran(Time(),":","")+".PDF"
	Local oSetup         := NIL
	Local xPathPDF       := AllTrim(GetTempPath())
	Local xPatherver     := MsDocPath()
	Local lSegue         := .T.
	Private oReport
	Private xDtHrEmis    := ""
	Private _FILIAL_NOME := ""
	Private _FILIAL_RESP := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF CN9->CN9_SITUAC != '05'
		MsgAlert("Posicione em um contrato vigente para realizar a impressão do mesmo, o contrato posicionado no momento não está com a situação vigente!","XCOMCT02")
		lSegue := .F.
	ENDIF

	If lSegue

		_ALIAS_TEMP := GetNextAlias()

		_SQL := "SELECT FILIAL_NOME, RESPONSAVEL FROM SIGAMAT WITH (NOLOCK) " + CRLF +;
		"WHERE FILIAL = '" + XFILIAL("CN9") + "'

		TcQuery _SQL NEW ALIAS (_ALIAS_TEMP)
		(_ALIAS_TEMP)->(dbSelectArea(_ALIAS_TEMP))
		_FILIAL_NOME := (_ALIAS_TEMP)->FILIAL_NOME
		_FILIAL_RESP := (_ALIAS_TEMP)->RESPONSAVEL
		(_ALIAS_TEMP)->(DbCloseArea())

		xDtHrEmis := DtoS(dDatabase)
		xDtHrEmis := SUBSTR(xDtHrEmis,7,2)+"/"+SUBSTR(xDtHrEmis,5,2)+"/"+SUBSTR(xDtHrEmis,1,4)+" - "+Time()

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

		Processa({|| ReportDef(oReport,oSetup,cFilePrint)},"Impressão do Contrato " + CN9->CN9_FILIAL + " / " + CN9->CN9_NUMERO)

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ReportDef
Sub-Rotina para gerar o detalhe do relatorio demonstrativo de valores por grupo.

@type function
@author José Fernando Castroviejo Vilela
@since  16/08/2017
@version P12.1.23

@param oReport, Objeto, Obejto que representa o relatório.
@param oSetup, Objeto, Compatibilidade.
@param cFilePrint, Caractere, Nome e local do arquivo pdf a ser gerado.

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ReportDef(oReport,oSetup,cFilePrint)

	//Local nCount  := 0
	//Local _SQL    := ""
	Local lSegue  := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cAlias      := ""
	_cAliasItens := ""
	xChave       := ""
	nLinha       := 0
	nLinhaB      := 0
	nInicio      := 0
	xAjustLC     := 0
	nLRep        := 0
	_AUX         := ""
	_CODIGO      := ""

	Private Fonte10N,Fonte06,Fonte06N

	Fonte16N := TFontEx():New(oReport,"Courier New",16,16,.T.,.T.,.F.)
	Fonte11N := TFontEx():New(oReport,"Courier New",11,11,.T.,.T.,.F.)
	Fonte11  := TFontEx():New(oReport,"Courier New",11,11,.F.,.T.,.F.)
	Fonte10N := TFontEx():New(oReport,"Lucida Console",10,10,.T.,.T.,.F.)
	Fonte09  := TFontEx():New(oReport,"Lucida Console",09,09,.F.,.T.,.F.)
	Fonte09N := TFontEx():New(oReport,"Lucida Console",09,09,.T.,.T.,.F.)

	IF oReport:nDevice == 6
		Fonte05  := TFontEx():New(oReport,"Lucida Console",06,06,.F.,.T.,.F.)
		Fonte05N := TFontEx():New(oReport,"Lucida Console",06,06,.T.,.T.,.F.)
		Fonte06  := TFontEx():New(oReport,"Lucida Console",07,07,.F.,.T.,.F.)
		Fonte06N := TFontEx():New(oReport,"Lucida Console",07,07,.T.,.T.,.F.)
	ELSE
		Fonte05  := TFontEx():New(oReport,"Lucida Console",05,05,.F.,.T.,.F.)
		Fonte05N := TFontEx():New(oReport,"Lucida Console",05,05,.T.,.T.,.F.)
		Fonte06  := TFontEx():New(oReport,"Lucida Console",06,06,.F.,.T.,.F.)
		Fonte06N := TFontEx():New(oReport,"Lucida Console",06,06,.T.,.T.,.F.)
		xAjustLC := 20
	ENDIF

	_cAlias := GetNextAlias()
	BEGINSQL alias _cAlias
		SELECT *
		FROM  %TABLE:CN9% AS CN9
		WHERE CN9.%notdel%
		AND CN9_FILIAL  = %Exp:CN9->CN9_FILIAL%
		AND CN9_NUMERO  = %Exp:CN9->CN9_NUMERO%
		AND CN9_REVISA  = %Exp:CN9->CN9_REVISA%
	ENDSQL

	IF (_cAlias)->(EOF())
		MsgAlert("Posicione em um contrato vigente para realizar a impressão do mesmo!","XCOMCT02")
		lSegue  := .F.
	ENDIF

	If lSegue

		IF !EMPTY((_cAlias)->CN9_NUMERO)
			DbSelectArea(_cAlias)
			(_cAlias)->(dbGoTop())
		ELSE
			(_cAlias)->(dbCloseArea())
		ENDIF

		nLn  := 1
		nPag := 1

		IF !(_cAlias)->(EOF())

			ImpMaskA(nPag)

			oReport:Say(100,25 ,"     Vigência:",Fonte11N:oFont)
			oReport:Say(100,105 , cValToChar(STOD((_cAlias)->CN9_DTINIC)) + "  à  " + cValToChar(STOD((_cAlias)->CN9_DTFIM)),Fonte11:oFont)

			oReport:Say(115,25 ,"Identificador:",Fonte11N:oFont)
			_AUX := AllTrim((_cAlias)->CN9_DESCRI)
			IF LEN(_AUX) <= 85
				oReport:Say(115,105 ,_AUX,Fonte11:oFont)
			ELSE
				oReport:Say(115,105 ,SUBSTR(_AUX,1,84) + "...",Fonte11:oFont)
			ENDIF

			_AUX := ALLTRIM(Posicione("CN1", 1, (_cAlias)->CN9_FILIAL+CN9->CN9_TPCTO, "CN1_DESCRI" ))

			oReport:Say(130,25 ,"         Tipo:",Fonte11N:oFont)
			oReport:Say(130,105,_AUX,Fonte11:oFont)

			_AUX := ALLTRIM(Posicione("SX5", 1,  "01GO    "+"TP"+SUBSTR(CN9->CN9_XMDAQU, 1, 2), "X5_DESCRI" ))

			oReport:Say(145,25 ,"   Modalidade:",Fonte11N:oFont)
			oReport:Say(145,105,_AUX,Fonte11:oFont)

			_AUX := UsrFullName((_cAlias)->CN9_XRESPO)

			oReport:Say(160,25 ,"  Responsável:",Fonte11N:oFont)
			oReport:Say(160,105 ,_AUX,Fonte11:oFont)

			oReport:Say(175,25 ,"        Valor: R$",Fonte11N:oFont)
			oReport:Say(175,125 ,ALLTRIM(Transform((_cAlias)->CN9_VLATU,PesqPict("CN9","CN9_VLATU"))),Fonte11:oFont)

			oReport:Say(190,25 ,"        Saldo: R$",Fonte11N:oFont)
			oReport:Say(190,125,ALLTRIM(Transform((_cAlias)->CN9_SALDO,PesqPict("CN9","CN9_SALDO"))),Fonte11:oFont)

			_CODIGO := ALLTRIM(Posicione("CNA", 3, (_cAlias)->CN9_FILIAL+(_cAlias)->CN9_NUMERO+(_cAlias)->CN9_REVISA, "CNA_FORNEC"))

			_AUX := Posicione("SA2", 1, XFILIAL("SA2")+_CODIGO, "A2_NOME" )
			oReport:Say(205,25 ,"   Fornecedor:",Fonte11N:oFont)
			oReport:Say(205,105 ,_CODIGO + ' - ' + _AUX,Fonte11:oFont)

			_AUX := Posicione("SA2", 1, XFILIAL("SA2")+_CODIGO, "A2_CGC")
			oReport:Say(220,25 ,"     CNPJ/CPF:",Fonte11N:oFont)
			oReport:Say(220,105,Transform(_AUX, "@R 99.999.999/9999-99"),Fonte11:oFont)



			_cAliasItens := GetNextAlias()

			BEGINSQL alias _cAliasItens
				SELECT *
				FROM  %TABLE:CNB% AS CNB
				WHERE CNB.%notdel%
				AND CNB_FILIAL = %Exp:(_cAlias)->CN9_FILIAL%
				AND CNB_CONTRA = %Exp:(_cAlias)->CN9_NUMERO%
				AND CNB_REVISA = %Exp:(_cAlias)->CN9_REVISA%
			ENDSQL

			_CC_ANT      := ""
			_ITEMCT_ANT  := ""
			_CC_ITEM_DIF := 0

			IF !(_cAliasItens)->(EOF())
				DbSelectArea(_cAliasItens)
				(_cAliasItens)->(dbGoTop())
				_CC_ANT     := (_cAliasItens)->CNB_CC
				_ITEMCT_ANT := (_cAliasItens)->CNB_ITEMCT
			ENDIF

			WHILE !(_cAliasItens)->(EOF())
				If (_cAliasItens)->CNB_CC <> _CC_ANT
					_CC_ITEM_DIF := 1
					EXIT
				ElseIf (_cAliasItens)->CNB_ITEMCT <> _ITEMCT_ANT
					_CC_ITEM_DIF := 1
					EXIT
				EndIf
				(_cAliasItens)->(dbSkip())
			END
			nLin2 := 255
			(_cAliasItens)->(dbGoTop())

			If _CC_ITEM_DIF = 0

				_AUX := ALLTRIM(Posicione("CTT", 1,  SUBSTRING((_cAliasItens)->CNB_FILIAL,1,4)+"    "+(_cAliasItens)->CNB_CC, "CTT_XFILIA" ))
				_FILIALCC := SUBSTRING(_AUX,1,4)

				_AUX := ALLTRIM(_CC_ANT)
				_AUX += " - "
				_AUX += Posicione("CTT", 1,  _FILIALCC +"    "+(_cAliasItens)->CNB_CC, "CTT_DESC01" )
				oReport:Say(235,13 ,"Centro de Custo:",Fonte11N:oFont)
				oReport:Say(235,105,_AUX,Fonte11:oFont)

				_AUX := ALLTRIM(_ITEMCT_ANT)
				_AUX += " - "
				_AUX += (ALLTRIM(Posicione("CTD", 1,  _FILIALCC +"    "+(_cAliasItens)->CNB_ITEMCT, "CTD_DESC01" )))
				oReport:Say(250,24 ,"Item Contabil:",Fonte11N:oFont)
				oReport:Say(250,105 ,_AUX,Fonte11:oFont)

				nLin2 := 285
				oReport:Say(275,240,"OBJETO DO CONTRATO",Fonte11N:oFont)
			Else
				oReport:Say(245,240,"OBJETO DO CONTRATO",Fonte11N:oFont)
			EndIf


			xChave := ""
			xChave += MSMM((_cAlias)->CN9_CODOBJ)
			nTam := MLCount((MSMM((_cAlias)->CN9_CODOBJ)),135)
			nLin := nTam


			FOR i := 1 TO nLin
				IF nLin2 >= 830
					nLin2 := 120
					oReport:EndPage()
					nPag += 1
					ImpMaskA(nPag)
				ENDIF

				nLin2 += 10
				xChave := ""
				xChave += MSMM((_cAlias)->CN9_CODOBJ,135,i)
				oReport:Say(nLin2,25,xChave,Fonte06N:oFont)

			NEXT

			nLin2 += 20

			IF !EMPTY((_cAlias)->CN9_REVISA)
				oReport:Say(nLin2,200,"JUSTIFICATIVA DA REVISÃO CONTRATUAL",Fonte11N:oFont)
				nLin2 += 10
				xChave := ""
				xChave += MSMM((_cAlias)->CN9_CODJUS)
				nTam := MLCount((MSMM((_cAlias)->CN9_CODJUS)),135)
				nLin := nTam

				FOR i := 1 TO nLin
					IF nLin2 >= 830
						nLin2 := 120
						oReport:EndPage()
						nPag += 1
						ImpMaskA(nPag)
					ENDIF

					nLin2 += 10
					xChave := ""
					xChave += MSMM((_cAlias)->CN9_CODJUS,135,i)
					oReport:Say(nLin2,25,xChave,Fonte06N:oFont)
				NEXT

				nLin2 += 20
			EndIf

			oReport:Box(nLin2,10,nLin2+15,590)
			oReport:Box(nLin2,10,nLin2+15,505)
			oReport:Box(nLin2,10,nLin2+15,440)
			oReport:Box(nLin2,10,nLin2+15,390)

			nLin2 += 10

			oReport:Say(nLin2,15,"Produto/Serviço", Fonte06N:oFont)
			oReport:Say(nLin2,420,"Qtde", Fonte06N:oFont)
			oReport:Say(nLin2,450,"VL Unitario", Fonte06N:oFont)
			oReport:Say(nLin2,535,"Valor Total", Fonte06N:oFont)

			_cAliasItens := GetNextAlias()

			BEGINSQL alias _cAliasItens
				SELECT *
				FROM  %TABLE:CNB% AS CNB
				WHERE CNB.%notdel%
				AND CNB_FILIAL = %Exp:(_cAlias)->CN9_FILIAL%
				AND CNB_CONTRA = %Exp:(_cAlias)->CN9_NUMERO%
				AND CNB_REVISA = %Exp:(_cAlias)->CN9_REVISA%
			ENDSQL

			IF !(_cAliasItens)->(EOF())
				DbSelectArea(_cAliasItens)
				(_cAliasItens)->(dbGoTop())
			ENDIF

			nLinha  := nLin2
			nLinhaB := nLin2 - 10
			WHILE !(_cAliasItens)->(EOF())

				nLinha  += 15
				nLinhaB += 15

				IF nLinha >= 840
					oReport:Box(nLinhaB,10,nLinhaB,590,"-3")
					oReport:EndPage()
					nLinha := 125
					nLinhaB := 115
					nPag += 1
					ImpMaskB(nPag)
					nLinha  += 15
					nLinhaB += 15
				ENDIF

				oReport:Box(nLinhaB,10,nLinhaB+15,590,"-3")
				oReport:Box(nLinhaB,10,nLinhaB+15,505,"-3")
				oReport:Box(nLinhaB,10,nLinhaB+15,440,"-3")
				oReport:Box(nLinhaB,10,nLinhaB+15,390,"-3")

				oReport:Say(nLinha,15 ,ALLTRIM((_cAliasItens)->CNB_PRODUT)+" - "+(_cAliasItens)->CNB_DESCRI, Fonte06:oFont)
				oReport:Say(nLinha,379,Transform((_cAliasItens)->CNB_QUANT, "@E 999,999,999.99"), Fonte06:oFont)
				oReport:Say(nLinha,440,Transform((_cAliasItens)->CNB_VLUNIT,PesqPict("CNB","CNB_VLUNIT")), Fonte06:oFont)
				oReport:Say(nLinha,520,Transform((_cAliasItens)->CNB_VLTOT,PesqPict("CNB","CNB_VLTOT")), Fonte06:oFont)

				If _CC_ITEM_DIF = 1
					nLinha  += 12
					nLinhaB += 10

					_AUX := ALLTRIM(Posicione("CTT", 1,  SUBSTRING((_cAliasItens)->CNB_FILIAL,1,4)+ "    " +(_cAliasItens)->CNB_CC, "CTT_XFILIA" ))
					_FILIALCC := SUBSTRING(_AUX,1,4)
					_ALIAS_TEMP1 := GetNextAlias()

					_SQL1 := "SELECT FILIAL, FILIAL_NOME FROM SIGAMAT WITH (NOLOCK) " + CRLF +;
					"WHERE FILIAL = '" + _AUX + "'

					TcQuery _SQL1 NEW ALIAS (_ALIAS_TEMP1)
					(_ALIAS_TEMP1)->(dbSelectArea(_ALIAS_TEMP1))
					_FILIAL_NOME1 := (_ALIAS_TEMP1)->FILIAL_NOME
					(_ALIAS_TEMP1)->(DbCloseArea())


					_NOME_CC := Posicione("CTT", 1,  _FILIALCC +"    "+(_cAliasItens)->CNB_CC, "CTT_DESC01" )
					_NOME_ITEMCT := Posicione("CTD", 1,  _FILIALCC +"    "+(_cAliasItens)->CNB_ITEMCT, "CTD_DESC01" )

					_AUX += " - " + ALLTRIM(_FILIAL_NOME1) + " | "
					_AUX += ALLTRIM((_cAliasItens)->CNB_CC) + " - "
					_AUX += ALLTRIM(_NOME_CC) + " | "
					_AUX += ALLTRIM((_cAliasItens)->CNB_ITEMCT) + " - "
					_AUX += ALLTRIM(_NOME_ITEMCT) + "."

					oReport:Say(nLinha,15 ,ALLTRIM(_AUX), Fonte05:oFont)
					nLinha  -= 2
				EndIf

				(_cAliasItens)->(dbSkip())
			END

			nLinha += 30

			IF nLinha >= 780
				oReport:EndPage()
				nLinha := 125
				nLinhaB := 115
				nPag += 1
				ImpMaskC(nPag)
			ENDIF
			oReport:Box(nLinhaB+15,10,nLinhaB+15,590,"-3")

			oReport:Say(nLinha,430," TOTAL GERAL: R$"+Transform((_cAlias)->CN9_VLATU,PesqPict("CN9","CN9_VLATU")),Fonte06N:oFont)

			nLinha += 60

			oReport:Say(nLinha,204,"_______________________________________________", Fonte06N:oFont )

			IF SUBSTR(XFILIAL("CN9"),5,4) = "0001" .OR. (_cAlias)->CN9_VLINI > 4000 .OR. SUBSTR(CN9->CN9_XMDAQU, 1, 2)$"CV|PG|CC|IN"
				DO CASE
					CASE SUBSTR(XFILIAL("CN9"),1,4) == "01GO"
					AUX_01 := "José Eduardo de Andrade Neto"
					AUX_02 := "Superintendente"
					AUX_03 := "FIEG"
					CASE SUBSTR(XFILIAL("CN9"),1,4) == "02GO"
					AUX_01 := "Paulo Vargas"
					AUX_02 := "Superintendente"
					AUX_03 := "SESI - DR - Goiás"
					CASE SUBSTR(XFILIAL("CN9"),1,4) == "03GO"
					AUX_01 := "Paulo Vargas"
					AUX_02 := "Diretor Regional"
					AUX_03 := "SENAI - DR - Goiás"
					CASE SUBSTR(XFILIAL("CN9"),1,4) == "04GO"
					AUX_01 := "Humberto Rodrigues de Oliveira"
					AUX_02 := "Superintendente"
					AUX_03 := "IEL - Goiás"
					CASE SUBSTR(XFILIAL("CN9"),1,4) == "05GO"
					AUX_01 := "Almir Yamamura Blésio"
					AUX_02 := "Superintendente"
					AUX_03 := "ICQ - Goiás"
				ENDCASE
			ELSE
				AUX_01 := ALLTRIM(_FILIAL_RESP)
				DO CASE
					CASE SUBSTR(XFILIAL("CN9"),1,4) == "01GO"
					AUX_02 := "Superintendente"
					CASE SUBSTR(XFILIAL("CN9"),1,4) == "02GO"
					AUX_02 := "Diretor(a)"
					CASE SUBSTR(XFILIAL("CN9"),1,4) == "03GO"
					AUX_02 := "Diretor(a)"
					CASE SUBSTR(XFILIAL("CN9"),1,4) == "04GO"
					AUX_02 := "Superintendente"
					CASE SUBSTR(XFILIAL("CN9"),1,4) == "05GO"
					AUX_02 := "Superintendente"
				ENDCASE
				AUX_03 := ALLTRIM(_FILIAL_NOME)
			ENDIF

			oReport:SayAlign(nLinha,1,AUX_01,Fonte11N:oFont,600,10,1,2)
			oReport:SayAlign(nLinha + 12,1,AUX_02,Fonte09N:oFont,600,10,1,2)
			oReport:SayAlign(nLinha + 22,1,AUX_03,Fonte09N:oFont,600,10,1,2)

			IF !EMPTY((_cAlias)->CN9_XUAREV)
				IF POSICIONE("ALM",2,xFILIAL("ALM") + "001" + (_cAlias)->CN9_XUAREV,"ALM_USER") == (_cAlias)->CN9_XUAREV
					oReport:SayAlign(nLinha + 42,1,"APROVADO ELETRÔNICAMENTE PELA GECON",Fonte09N:oFont,600,10,1,2)
				ENDIF
			ENDIF

			(_cAliasItens)->(DbCloseArea())
			(_cAlias)->(DbCloseArea())
		ENDIF

		oReport:EndPage()
		lPreview := .T.
		oReport:Preview()
		FreeObj(oReport)
		oReport := Nil

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ImpMaskA
Sub-Rotina para gerar o cabecalho mais o rodape do relatório.

@type function
@author José Fernando Castroviejo Vilela
@since  16/08/2017
@version P12.1.23

@param nPag, Numérico, Número da Página.

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ImpMaskA(nPag)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oReport:StartPage()

	oReport:Box(23, 08, 842, 592, '-1')
	oReport:Box(24, 09, 841, 591, '-1')
	oReport:Box(25, 10, 840, 590, '-1')
	oReport:Say(40,60,"E S P E L H O   D O   C O N T R A T O   -   P R O T H E U S",Fonte16N:oFont)
	oReport:SayAlign(43,1,NomeEmpresa(),Fonte06N:oFont,600,10,1,2)
	oReport:Box(56, 08, 56, 592, '-1')
	oReport:Box(57, 09, 57, 591, '-1')
	oReport:Box(58, 10, 58, 590, '-1')

	oReport:Say(70,25  ,"       Filial:",Fonte11N:oFont)
	oReport:Say(70,105 ,ALLTRIM(XFILIAL("CN9")) + " | " + ALLTRIM(_FILIAL_NOME),FONTE11:oFont)

	IF EMPTY((_cAlias)->CN9_REVISA)
		oReport:Say(85,25  ,"  Nº Contrato:",Fonte11N:oFont)
		oReport:Say(85,105 ,(_cAlias)->CN9_NUMERO,Fonte11:oFont)
	ELSE
		oReport:Say(85,25  ,"  Nº Contrato:",Fonte11N:oFont)
		oReport:Say(85,105 ,(_cAlias)->CN9_NUMERO+"/"+(_cAlias)->CN9_REVISA,Fonte11:oFont)
	ENDIF

	IF nInicio = 1
		oReport:Say(115,240,"OBJETO DO CONTRATO",Fonte11N:oFont)
	ENDIF

	nInicio := 1

	//Impressao do Rodape

	oReport:Say(850,NSTARTCOL+000,"Usuário: ",Fonte06N:oFont)
	oReport:Say(850,NSTARTCOL+034,UsrFullName(__cUserID),Fonte06:oFont)
	oReport:Say(850,NSTARTCOL+195,"Data/Hora: ",Fonte06N:oFont)
	oReport:Say(850,NSTARTCOL+237,xDtHrEmis,Fonte06:oFont)
	oReport:Say(850,NSTARTCOL+535,"Página: ",Fonte06N:oFont)
	oReport:Say(850,NSTARTCOL+567,AllTrim(Str(nPag)),Fonte06:oFont)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ImpMaskB
Sub-Rotina para gerar o cabecalho mais o rodape do relatório.

@type function
@author José Fernando Castroviejo Vilela
@since  16/08/2017
@version P12.1.23

@param nPag, Numérico, Número da Página.

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ImpMaskB(nPag)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oReport:StartPage()

	oReport:Box(23, 08, 842, 592, '-1')
	oReport:Box(24, 09, 841, 591, '-1')
	oReport:Box(25, 10, 840, 590, '-1')
	oReport:Say(40,60,"E S P E L H O   D O   C O N T R A T O   -   P R O T H E U S",Fonte16N:oFont)
	oReport:SayAlign(43,1,NomeEmpresa(),Fonte06N:oFont,600,10,1,2)
	oReport:Box(56, 08, 56, 592, '-1')
	oReport:Box(57, 09, 57, 591, '-1')
	oReport:Box(58, 10, 58, 590, '-1')

	oReport:Say(70,25  ,"       Filial:",Fonte11N:oFont)
	oReport:Say(70,105 ,ALLTRIM(XFILIAL("CN9")) + " | " + Upper(FWFilialName()),FONTE11:oFont)

	IF EMPTY((_cAlias)->CN9_REVISA)
		oReport:Say(85,25  ,"  Nº Contrato:",Fonte11N:oFont)
		oReport:Say(85,105 ,(_cAlias)->CN9_NUMERO,Fonte11:oFont)
	ELSE
		oReport:Say(85,25  ,"  Nº Contrato:",Fonte11N:oFont)
		oReport:Say(85,105 ,(_cAlias)->CN9_NUMERO+"/"+(_cAlias)->CN9_REVISA,Fonte11:oFont)
	ENDIF

	nLin2 := 115

	oReport:Box(nLin2,10,nLin2+15,590)
	oReport:Box(nLin2,10,nLin2+15,505)
	oReport:Box(nLin2,10,nLin2+15,440)
	oReport:Box(nLin2,10,nLin2+15,390)

	nLin2 += 10

	oReport:Say(nLin2,15,"Produto/Serviço", Fonte06N:oFont)
	oReport:Say(nLin2,420,"Qtde", Fonte06N:oFont)
	oReport:Say(nLin2,450,"VL Unitario", Fonte06N:oFont)
	oReport:Say(nLin2,535,"Valor Total", Fonte06N:oFont)

	//Impressao do Rodape

	oReport:Say(850,NSTARTCOL+000,"Usuário: ",Fonte06N:oFont)
	oReport:Say(850,NSTARTCOL+034,UsrFullName(__cUserID),Fonte06:oFont)
	oReport:Say(850,NSTARTCOL+195,"Data/Hora: ",Fonte06N:oFont)
	oReport:Say(850,NSTARTCOL+237,xDtHrEmis,Fonte06:oFont)
	oReport:Say(850,NSTARTCOL+535,"Página: ",Fonte06N:oFont)
	oReport:Say(850,NSTARTCOL+567,Alltrim(Str(nPag)),Fonte06:oFont)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ImpMaskC
Sub-Rotina para gerar o cabecalho mais o rodape do relatório.

@type function
@author José Fernando Castroviejo Vilela
@since  16/08/2017
@version P12.1.23

@param nPag, Numérico, Número da Página.

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.

/*/
/*/================================================================================================================================/*/

Static Function ImpMaskC(nPag)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oReport:StartPage()

	oReport:Box(23, 08, 842, 592, '-1')
	oReport:Box(24, 09, 841, 591, '-1')
	oReport:Box(25, 10, 840, 590, '-1')
	oReport:Say(40,60,"E S P E L H O   D O   C O N T R A T O   -   P R O T H E U S",Fonte16N:oFont)
	oReport:SayAlign(43,1,NomeEmpresa(),Fonte06N:oFont,600,10,1,2)
	oReport:Box(56, 08, 56, 592, '-1')
	oReport:Box(57, 09, 57, 591, '-1')
	oReport:Box(58, 10, 58, 590, '-1')

	oReport:Say(70,25  ,"       Filial:",Fonte11N:oFont)
	oReport:Say(70,105 ,ALLTRIM(XFILIAL("CN9")) + " | " + Upper(FWFilialName()),FONTE11:oFont)

	IF EMPTY((_cAlias)->CN9_REVISA)
		oReport:Say(85,25  ,"  Nº Contrato:",Fonte11N:oFont)
		oReport:Say(85,105 ,(_cAlias)->CN9_NUMERO,Fonte11:oFont)
	ELSE
		oReport:Say(85,25  ,"  Nº Contrato:",Fonte11N:oFont)
		oReport:Say(85,105 ,(_cAlias)->CN9_NUMERO+"/"+(_cAlias)->CN9_REVISA,Fonte11:oFont)
	ENDIF

	nLin2 := 115

	//Impressao do Rodape

	oReport:Say(850,NSTARTCOL+000,"Usuário: ",Fonte06N:oFont)
	oReport:Say(850,NSTARTCOL+034,UsrFullName(__cUserID),Fonte06:oFont)
	oReport:Say(850,NSTARTCOL+195,"Data/Hora: ",Fonte06N:oFont)
	oReport:Say(850,NSTARTCOL+237,xDtHrEmis,Fonte06:oFont)
	oReport:Say(850,NSTARTCOL+535,"Página: ",Fonte06N:oFont)
	oReport:Say(850,NSTARTCOL+567,Alltrim(Str(nPag)),Fonte06:oFont)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} NomeEmpresa
Retorna o Nome da Filial Logada.

@type function
@author José Fernando Castroviejo Vilela
@since  16/08/2017
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Nome da Filial Logada.

/*/
/*/================================================================================================================================/*/

Static Function NomeEmpresa()

	Local lRet := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DO CASE
		CASE SUBSTR(XFILIAL("CN9"),1,4) == "01GO"
		lRet := "FIEG - Federação das Industrias do Estado de Goiás"
		CASE SUBSTR(XFILIAL("CN9"),1,4) == "02GO"
		lRet := "SESI - Serviço Social da Indústria"
		CASE SUBSTR(XFILIAL("CN9"),1,4) == "03GO"
		lRet := "SENAI - Serviço Nacional de Aprendizagem Indústrial"
		CASE SUBSTR(XFILIAL("CN9"),1,4) == "04GO"
		lRet := "IEL - Instituto Euvaldo Lodi"
		CASE SUBSTR(XFILIAL("CN9"),1,4) == "05GO"
		lRet := "ICQ BRASIL - Instituto de Certificação Qualidade Brasil"
	ENDCASE

Return lRet