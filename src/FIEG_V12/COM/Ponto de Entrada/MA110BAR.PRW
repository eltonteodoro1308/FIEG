#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA110BAR
Ponto de entrada para acrescentar botao na tela de Solicitacao de Compras.

@type function
@author Thiago Rasmussen
@since 16/12/2011
@version P12.1.23

@obs Projeto ELO

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com lista de botões a serem acrescentados.

/*/
/*/================================================================================================================================/*/

User Function MA110BAR

	Local aRot := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	aadd(aRot,{"S4WB005N",{|| U_SICOMA26() },"Consulta de Compras","Consulta de Compras" })

	IF INCLUI .or. ALTERA
		aadd(aRot,{"S4WB005N",{|| U_SICOMA26() },"Mútuo","Informar regra de rateio de mútuo" })
	ENDIF

	IF !Inclui
		aadd(aRot,{"BUDGET",   {|| _A110Posic()},"Consulta Aprovação","Consulta histórico de aprovação da SC" })
	ENDIF

	IF !INCLUI .AND. !ALTERA
		AADD(aRot,{"S4WB011N",  {|| VERESPEC("C1_XESPEC",aCols[n][aScan(aHeader,{|x| Trim(x[2])=="C1_XESPEC"})]) }, "Especificação do produto", "Especificação do produto" })
	ENDIF

Return aRot

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA110BAR
Tela dos aprovadores.

@type function
@author Thiago Rasmussen
@since 28/10/2010
@version P12.1.23

@obs Projeto ELO

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function _A110Posic()

	Local aArea		:= GetArea()
	Local aSavCols  := {}
	Local aSavHead  := {}
	Local cHelpApv  := OemToAnsi("Este documento nao possui controle de aprovacao.")
	Local cAliasSCR := "TMP"
	Local cSolicit := ""
	Local cSituaca  := ""
	Local cNumDoc   := ""
	Local cStatus   := ""
	Local cTitle    := ""
	Local cTitDoc   := ""
	Local cAddHeader:= ""
	Local lBloq     := .F.
	Local lQuery    := .F.
	Local nSavN		:= 0
	Local nX   		:= 0
	Local nY        := 0
	Local oDlg
	Local oGet
	Local oBold

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	aSavCols  := aClone(aCols)
	aSavHead  := aClone(aHeader)
	nSavN     := N

	If !Empty(SC1->C1_XGRPAPR)
		cTitle    := "Aprovacao da Solicitação de Compra"
		cTitDoc   := "Solicitação"
		cHelpApv  := "Esta solicitação nao possui controle de aprovacao."
		cNumDoc   := SC1->C1_NUM
		cSolicit  := UsrRetName(SC1->C1_USER)
		cStatus   := IIF(SC1->C1_APROV=="L",OemToAnsi("LIBERADO"),OemToAnsi("AGUARDANDO LIB."))
	EndIf

	aHeader:= {}
	aCols  := {}

	//+--------------------------------------------------------------+
	//| Faz a montagem do aHeader com os campos fixos.               |
	//+--------------------------------------------------------------+
	OpenSxs(,,,,cEmpAnt,'SX3MDI','SX3',,.F.)
	SX3MDI->(DbSetOrder(1))
	SX3MDI->(MsSeek("SCR"))
	While !Eof() .And. (SX3MDI->X3_ARQUIVO == "SCR")
		IF AllTrim(X3_CAMPO)$"CR_NIVEL/CR_OBS/CR_DATALIB/" + cAddHeader
			AADD(aHeader,{	TRIM(X3Titulo()),;
			SX3MDI->X3_CAMPO,;
			SX3MDI->X3_PICTURE,;
			SX3MDI->X3_TAMANHO,;
			SX3MDI->X3_DECIMAL,;
			SX3MDI->X3_VALID,;
			SX3MDI->X3_USADO,;
			SX3MDI->X3_TIPO,;
			SX3MDI->X3_ARQUIVO,;
			SX3MDI->X3_CONTEXT } )

			If AllTrim(SX3MDI->X3_CAMPO) == "CR_NIVEL"
				AADD(aHeader,{ OemToAnsi("Usuario"),"bCR_NOME",   "",15,0,"","","C","",""} )
				AADD(aHeader,{ OemToAnsi("Situacao"),"bCR_SITUACA","",20,0,"","","C","",""} )
				AADD(aHeader,{ OemToAnsi("Usuario Lib."),"bCR_NOMELIB","",15,0,"","","C","",""} )
			EndIf

		Endif

		dbSkip()

	EndDo

	ADHeadRec("SCR",aHeader)

	aStruSCR := SCR->(dbStruct())
	cAliasSCR := GetNextAlias()
	cQuery    := "SELECT SCR.*,SCR.R_E_C_N_O_ SCRRECNO FROM "+RetSqlName("SCR")+" SCR "
	cQuery    += "WHERE SCR.CR_FILIAL='"+xFilial("SCR")+"' AND "
	cQuery    += "SCR.CR_NUM = '"+Padr(SC1->C1_NUM,Len(SCR->CR_NUM))+"' AND "
	cQuery    += "SCR.CR_TIPO = 'SC' AND "
	cQuery    += "SCR.D_E_L_E_T_=' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)

	For nX := 1 To Len(aStruSCR)
		If aStruSCR[nX][2]<>"C"
			TcSetField(cAliasSCR,aStruSCR[nX][1],aStruSCR[nX][2],aStruSCR[nX][3],aStruSCR[nX][4])
		EndIf
	Next nX

	dbSelectArea(cAliasSCR)

	While !Eof() .And.(cAliasSCR)->CR_FILIAL+(cAliasSCR)->CR_TIPO+Substr((cAliasSCR)->CR_NUM,1,Len(SC1->C1_NUM)) == xFilial("SCR") + "SC" + cNumDoc
		aadd(aCols,Array(Len(aHeader)+1))
		nY++
		For nX := 1 to Len(aHeader)
			If IsHeadRec(aHeader[nX][2])
				aCols[nY][nX] := IIf(lQuery , (cAliasSCR)->SCRRECNO , SCR->(Recno())  )
			ElseIf IsHeadAlias(aHeader[nX][2])
				aCols[nY][nX] := "SCR"
			ElseIf aHeader[nX][02] == "bCR_NOME"
				aCols[nY][nX] := UsrRetName((cAliasSCR)->CR_USER)
			ElseIf aHeader[nX][02] == "bCR_SITUACA"
				Do Case
					Case (cAliasSCR)->CR_STATUS == "01"
					cSituaca := OemToAnsi("Aguardando")
					Case (cAliasSCR)->CR_STATUS == "02"
					cSituaca := OemToAnsi("Em Aprovacao")
					Case (cAliasSCR)->CR_STATUS == "03"
					cSituaca := "Solicitação Aprovada"
					Case (cAliasSCR)->CR_STATUS == "04"
					cSituaca := "Solicitação Bloqueada"
					lBloq := .T.
					Case (cAliasSCR)->CR_STATUS == "05"
					cSituaca := OemToAnsi("Nivel Liberado ")
				EndCase
				aCols[nY][nX] := cSituaca
			ElseIf aHeader[nX][02] == "bCR_NOMELIB"
				aCols[nY][nX] := UsrRetName((cAliasSCR)->CR_USERLIB)
			ElseIf ( aHeader[nX][10] != "V")
				aCols[nY][nX] := FieldGet(FieldPos(aHeader[nX][2]))
			EndIf
		Next nX
		aCols[nY][Len(aHeader)+1] := .F.
		dbSkip()
	EndDo

	If !Empty(aCols)
		If lBloq
			cStatus := "SOLICITAÇÃO BLOQUEADA"
		EndIf
		n:=	 IIF(n > Len(aCols), Len(aCols), n)  // Feito isto p/evitar erro fatal(Array out of Bounds). Gilson-Localizações
		DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
		DEFINE MSDIALOG oDlg TITLE cTitle From 109,095 To 400,600 OF oMainWnd PIXEL
		@ 005,003 TO 032,250 LABEL "" OF oDlg PIXEL
		@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009
		@ 014,041 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 050,009 OF oDlg FONT oBold
		@ 015,103 SAY OemToAnsi("Solicitante") OF oDlg PIXEL SIZE 033,009 FONT oBold
		@ 014,138 MSGET cSolicit PICTURE "" WHEN .F. of oDlg PIXEL SIZE 103,009 FONT oBold
		@ 132,008 SAY "Situacao :" OF oDlg PIXEL SIZE 052,009 //'Situacao :'
		@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold
		@ 132,205 BUTTON "Fechar" SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL  //'Fechar'
		oGet:= MSGetDados():New(038,003,120,250,2,,,"")
		oGet:Refresh()
		@ 126,002 TO 127,250 LABEL "" OF oDlg PIXEL
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		Aviso("Atencao","Esta solicitação não possui controle de aprovação",{"Voltar"})
	EndIf

	(cAliasSCR)->(dbCloseArea())

	aHeader := aClone(aSavHead)
	aCols   := aClone(aSavCols)
	N		:= nSavN

	dbSelectArea("SC1")
	RestArea(aArea)
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} VerEspec
Exibe a tela com a descrição especifica.

@type function
@author Thiago Rasmussen
@since 03/03/13
@version P12.1.23

@param cCamp, Caractere, Nome do campo que contèm a especificação do produto.
@param cEspec, Caractere, Especificação do produto.

@obs Projeto ELO

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

STATIC FUNCTION VerEspec(cCamp,cEspec)

	Local aArea	:= GETAREA()
	Local oFont	:= NIL
	Local oMemo := NIL
	Local oDlg	:= NIL

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	Define Font oFont Name "Mono AS" Size 5, 12
	Define MsDialog oDlg Title GetSx3Cache( cCamp, 'X3_TITULO' ) From 3, 0 to 340, 417 Pixel
	@ 5, 5 Get oMemo Var cEspec Memo Size 200, 145 Of oDlg Pixel
	oMemo:bRClicked := { || AllwaysTrue() }
	oMemo:oFont     := oFont
	Define SButton From 153, 175 Type 1 Action oDlg:End() Enable Of oDlg Pixel
	Define SButton From 153, 145 Type 2 Action oDlg:End() Enable Of oDlg Pixel
	Activate MsDialog oDlg Center

	RestArea(aArea)

Return