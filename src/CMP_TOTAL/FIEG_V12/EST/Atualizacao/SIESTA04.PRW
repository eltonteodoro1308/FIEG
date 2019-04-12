#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIESTA04
Adiciona ao menu rotina de Consulta de Aprovação.

@type function
@author Leonardo Soncin
@since 10/02/2012
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com rotina a ser acrestada no menu.

/*/
/*/================================================================================================================================/*/

User Function SIESTA04

	//+---------------------------------------------------------------------+
	//| Declaracao de Variaveis                                             |
	//+---------------------------------------------------------------------+
	Local aRot := {}

	aadd(aRot,{"S4WB005N",{|| fPosic("SCP",Recno(),2,"SA") },"Consulta Aprovação","Consulta Aprovação" })

Return aRot

/*/================================================================================================================================/*/
/*/{Protheus.doc} fPosic
Consulta do status das Aprovacoes Documentos PC/AE/CP/NF.

@type function
@author Alexandre Inacio Lemes
@since 05/05/2006
@version P12.1.23

@param cAlias, Caractere, Alias do arquivo.
@param nReg, Numérico, Numero do registro.
@param nOpcx, Numérico, Opção selecionada.
@param cTipoDoc, Caractere, Tipo do Documento.

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fPosic(cAlias,nReg,nOpcx,cTipoDoc)

	Local aSavCols  := aClone(aCols)
	Local aSavHead  := aClone(aHeader)
	Local aArea		:= GetArea()
	Local cHelpApv  := OemToAnsi("Este documento nao possui controle de aprovacao.")
	Local cAliasSCR := "TMP"
	Local cComprador:= ""
	Local cSituaca  := ""
	Local cNumDoc   := ""
	Local cStatus   := ""
	Local cTitle    := ""
	Local cTitDoc   := ""

	Local lBloq     := .F.
	Local lQuery    := .F.

	Local nSavN		:= N
	Local nX   		:= 0
	Local nY        := 0

	Local oDlg
	Local oGet
	Local oBold

	#IFDEF TOP
	Local cQuery   := ""
	Local aStruSCR := {}
	#ENDIF

	DEFAULT cTipoDoc := "SA"

	dbSelectArea(cAlias)
	(cAlias)->(dbGoto(nReg))


	//If !Empty(CO1->CO1_XGRLIB)
	cTitle    := OemToAnsi("Aprovacao de SA")
	cTitDoc   := OemToAnsi("SA")
	cHelpApv  := OemToAnsi("Esta SA nao possui controle de aprovacao.")
	cNumDoc   := SCP->CP_NUM
	cStatus   := IIF(SCP->CP_STATSA=="L",OemToAnsi("SA LIBERADA"),OemToAnsi("AGUARDANDO LIB."))
	//EndIf

	If !Empty(cNumDoc)

		aHeader:= {}
		aCols  := {}

		//+--------------------------------------------------------------+
		//| Faz a montagem do aHeader com os campos fixos.               |
		//+--------------------------------------------------------------+
		dbSelectArea("SX3")
		SX3->(dbSetOrder(1))
		SX3->(MsSeek("SCR"))
		While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == "SCR")
			IF AllTrim(X3_CAMPO)$"CR_NIVEL/CR_OBS/CR_DATALIB"
				AADD(aHeader,{	TRIM(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )

				If AllTrim(x3_campo) == "CR_NIVEL"
					AADD(aHeader,{ OemToAnsi("Usuário"),"bCR_NOME",   "",15,0,"","","C","",""} )
					AADD(aHeader,{ OemToAnsi("Situação"),"bCR_SITUACA","",20,0,"","","C","",""} )
					AADD(aHeader,{ OemToAnsi("Usuário Lib."),"bCR_NOMELIB","",15,0,"","","C","",""} )
				EndIf

			Endif

			dbSelectArea("SX3")
			SX3->(dbSkip())
		EndDo

		ADHeadRec("SCR",aHeader)

		#IFDEF TOP
		lQuery     := .T.


		aStruSCR := SCR->(dbStruct())
		cTipoDoc := "SA"
		cAliasSCR := GetNextAlias()
		cQuery    := "SELECT SCR.*,SCR.R_E_C_N_O_ SCRRECNO FROM "+RetSqlName("SCR")+" SCR "
		cQuery    += "WHERE SCR.CR_FILIAL='"+xFilial("SCR")+"' AND "
		cQuery    += "SCR.CR_NUM = '"+Padr(SCP->CP_NUM,Len(SCR->CR_NUM))+"' AND "
		cQuery    += "SCR.CR_TIPO = 'SA' AND "
		cQuery    += "SCR.D_E_L_E_T_=' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)

		For nX := 1 To Len(aStruSCR)
			If aStruSCR[nX][2]<>"C"
				TcSetField(cAliasSCR,aStruSCR[nX][1],aStruSCR[nX][2],aStruSCR[nX][3],aStruSCR[nX][4])
			EndIf
		Next nX
		#ELSE
		//+-----------------------------------+
		//| Abre o arquivo SCR sem filtros    |
		//+-----------------------------------+
		ChkFile("SCR",.F.,"TMP")

		dbSelectArea(cAliasSCR)
		(cAliasSCR)->(dbSetOrder(1))
		(cAliasSCR)->(MsSeek(xFilial("SCR")+cTipoDoc+Padr(SCP->CP_NUM,Len(SCR->CR_NUM))))

		#ENDIF

		dbSelectArea(cAliasSCR)

		While (cAliasSCR)->(!Eof()) .And.(cAliasSCR)->CR_FILIAL+(cAliasSCR)->CR_TIPO+Substr((cAliasSCR)->CR_NUM,1,;
		len(SCP->CP_NUM)) ;
		== xFilial("SCR") + cTipoDoc + cNumDoc

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
						cSituaca := OemToAnsi("Nivel Bloqueado")
						Case (cAliasSCR)->CR_STATUS == "02"
						cSituaca := OemToAnsi("Aguarando Liberação")
						Case (cAliasSCR)->CR_STATUS == "03"
						cSituaca := OemToAnsi("SA Aprovada")
						Case (cAliasSCR)->CR_STATUS == "04"
						cSituaca := OemToAnsi("SA Bloqueada")
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
			(cAliasSCR)->(dbSkip())
		EndDo

		If !Empty(aCols)
			If lBloq
				cStatus := OemToAnsi("BLOQUEADO")
			EndIf
			//n:=	 IIF(n > Len(aCols), Len(aCols), n)  // Feito isto p/evitar erro fatal(Array out of Bounds). Gilson-Localizações
			DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
			DEFINE MSDIALOG oDlg TITLE cTitle From 109,095 To 400,600 OF oMainWnd PIXEL	 //"Aprovacao do Pedido de Compra // Contrato"
			@ 005,003 TO 032,250 LABEL "" OF oDlg PIXEL
			@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009 // "Pedido" / "Contrato" / "Nota Fiscal"
			@ 014,041 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 050,009 OF oDlg FONT oBold
			@ 132,008 SAY "Situacao :" OF oDlg PIXEL SIZE 052,009 //'Situacao :'
			@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold
			@ 132,205 BUTTON "Fechar" SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL  //'Fechar'
			oGet:= MSGetDados():New(038,003,120,250,nOpcx,,,"")
			oGet:Refresh()
			@ 126,002 TO 127,250 LABEL "" OF oDlg PIXEL
			ACTIVATE MSDIALOG oDlg CENTERED
		Else
			Aviso("Atencao",cHelpApv,{"Voltar"})
		EndIf

		dbSelectArea(cAliasSCR)
		(cAliasSCR)->(dbCloseArea())
		aHeader := aClone(aSavHead)
		aCols   := aClone(aSavCols)
		N		:= nSavN
	Else
		Aviso("Atencao",cHelpApv,{"Voltar"})
	EndIf

	dbSelectArea(cAlias)
	RestArea(aArea)

Return