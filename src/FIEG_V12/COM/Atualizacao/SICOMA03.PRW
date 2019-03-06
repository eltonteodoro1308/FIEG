#Include "Protheus.ch"
#Include "Topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA03
Funcao para Liberacao de documentos.

@type function
@author Leonardo Soncin
@since 28/11/2011
@version P12.1.23

@param _nOpcao, Numérico, Opção selecionada.
_nOpcao = 1 / Consulta
_nOpcao = 2 / Liberacao
_nOpcao = 3 / Estornar
_nOpcao = 4 / Consulta Aprovacao

@obs Projeto ELO

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.

/*/
/*/================================================================================================================================/*/
User Function SICOMA03(_nOpcao)

	// _nOpcao = 1 / Consulta
	// _nOpcao = 2 / Liberacao
	// _nOpcao = 3 / Estornar
	// _nOpcao = 4 / Consulta Aprovacao
	Local _aArea	:= {}
	Local _aAreaCR	:= {}
	Local _cDoc		:= ""
	local _nTamEdt 	:= TamSx3("CO1_CODEDT")[1] +TamSx3("CO1_NUMPRO")[1]

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If _nOpcao == 1 // Consulta

		_aArea := GetArea()
		_aAreaCR := SCR->(GetArea())
		_cDoc := Left(SCR->CR_NUM,_nTamEdt)
		CO1->(DbSetOrder(1))
		If CO1->(DbSeek(xFilial("CO1")+_cDoc))
			DbSelectArea("CO1")
			GCPA02Man("CO1",RecNo(),2)
		EndIf
		RestArea(_aAreaCR)
		RestArea(_aArea)

	ElseIf _nOpcao == 2 // Liberacao

		fLibEDT("SCR",RecNo(),_nOpcao)

	ElseIf _nOpcao == 3 // Estornar

		fEstEDT()

	ElseIf _nOpcao == 4 // Consulta Aprovacao

		_aArea := GetArea()
		_aAreaCR := SCR->(GetArea())
		fPosic("CO1",Recno(),2,"ED")
		RestArea(_aAreaCR)
		RestArea(_aArea)

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fLibEDT
Funcao para Liberacao de edital.

@type function
@author Adriano Luis Brandao
@since 20/07/2011
@version P12.1.23

@param cAlias, Caractere, Alias da Tabela .
@param nReg, Numérico, Recno do registro posicionado.
@param nOpcx, Numérico, Opção selecionada.

@obs Projeto ELO

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function fLibEDT(cAlias,nReg,nOpcx)

	Local _aArea	:= GetArea()
	Local _aAreaCO1	:= CO1->(GetArea())
	Local cCodLiber := SCR->CR_APROV
	Local cDocto    := SCR->CR_NUM
	Local cTipo     := SCR->CR_TIPO
	Local aSize		:= {290,410}
	Local cObs 		:= IIF(!Empty(SCR->CR_OBS),SCR->CR_OBS,CriaVar("CR_OBS"))
	Local ca097User := RetCodUsr()
	Local dRefer 	:= dDataBase
	Local aRetSaldo	:= {}
	Local nSaldo	:= 0
	Local CRoeda	:= ""
	Local nTotal	:= 0
	Local nSalDif	:= 0
	Local _cDoc		:= ""
	local _nTamEdt 	:= TamSx3("CO1_CODEDT")[1]+TamSx3("CO1_NUMPRO")[1]
	Local cName		:= ""
	Local nOpc		:= 0
	Local lLiberou	:= .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+--------------------------------------------------------------+
	//| Inicializa as variaveis utilizadas no Display.               |
	//+--------------------------------------------------------------+
	aRetSaldo 	:= MaSalAlc(cCodLiber,dRefer)
	nSaldo 	  	:= aRetSaldo[1]
	CRoeda 	  	:= A097Moeda(aRetSaldo[2])
	cName  	  	:= UsrRetName(ca097User)
	nTotal    	:= xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,aRetSaldo[2],SCR->CR_EMISSAO,,SCR->CR_TXMOEDA)
	nSalDif		:= nSaldo - nTotal

	Do Case
		Case SAK->AK_TIPO == "D"
		cTipoLim :=OemToAnsi("Diario")
		Case  SAK->AK_TIPO == "S"
		cTipoLim := OemToAnsi("Semanal")
		Case  SAK->AK_TIPO == "M"
		cTipoLim := OemToAnsi("Mensal")
		Case  SAK->AK_TIPO == "A"
		cTipoLim := OemToAnsi("Anual")
	EndCase

	_cDoc := Left(SCR->CR_NUM,_nTamEdt)
	CO1->(DbSetOrder(1))
	CO1->(DbSeek(xFilial("CO1")+_cDoc))

	DEFINE MSDIALOG oDlg FROM 0,0 TO aSize[1],aSize[2] TITLE OemToAnsi("Liberacao de Edital") PIXEL
	@ 0.5,01 TO 44,204 LABEL "" OF oDlg PIXEL
	@ 45,01  TO 128,204 LABEL "" OF oDlg PIXEL
	@ 07,06  Say OemToAnsi("Numero do Docto.") OF oDlg PIXEL
	@ 07,120 Say OemToAnsi("Emissao") OF oDlg SIZE 50,9 PIXEL
	@ 19,06  Say OemToAnsi("Centro de Custo") OF oDlg PIXEL
	@ 31,06  Say OemToAnsi("Aprovador") OF oDlg PIXEL SIZE 30,9
	@ 31,120 Say OemToAnsi("Data de ref. ") SIZE 60,9 OF oDlg PIXEL
	@ 53,06  Say OemToAnsi("Limite min.  ") +CRoeda OF oDlg PIXEL
	@ 53,110 Say OemToAnsi("Limite max. ")+CRoeda SIZE 60,9 OF oDlg PIXEL
	@ 65,06  Say OemToAnsi("Limite  ")+CRoeda  OF oDlg PIXEL
	@ 65,110 Say OemToAnsi("Tipo lim.") OF oDlg PIXEL
	@ 77,06  Say OemToAnsi("Saldo na data  ")+CRoeda OF oDlg PIXEL
	If SCR->CR_MOEDA == aRetSaldo[2]
		@ 89,06 Say OemToAnsi("Total do documento ")+CRoeda OF oDlg PIXEL
	Else
		@ 89,06 Say OemToAnsi("Total do documento, convertido em ")+CRoeda OF oDlg PIXEL
	EndIf
	@ 101,06 Say OemToAnsi("Saldo disponivel apos liberacao  ") +CRoeda SIZE 130,10 OF oDlg PIXEL
	@ 113,06 Say OemToAnsi("Observa‡äes ") SIZE 100,10 OF oDlg PIXEL
	@ 07,58  MSGET SCR->CR_NUM     When .F. SIZE 28 ,9 OF oDlg PIXEL
	@ 07,155 MSGET SCR->CR_EMISSAO When .F. SIZE 45 ,9 OF oDlg PIXEL
	@ 19,45  MSGET CO1->CO1_CC      When .F. SIZE 155,9 OF oDlg PIXEL
	@ 31,45  MSGET cName           When .F. SIZE 50 ,9 OF oDlg PIXEL
	@ 31,155 MSGET oDataRef VAR dRefer When .F. SIZE 45 ,9 OF oDlg PIXEL
	@ 53,50  MSGET SAK->AK_LIMMIN Picture "@E 999,999,999.99" When .F. SIZE 55,9 OF oDlg PIXEL RIGHT
	@ 53,155 MSGET SAK->AK_LIMMAX Picture "@E 999,999,999.99" When .F. SIZE 45,9 OF oDlg PIXEL RIGHT
	@ 65,50  MSGET SAK->AK_LIMITE Picture "@E 999,999,999.99" When .F. SIZE 55,9 OF oDlg PIXEL RIGHT
	@ 65,155 MSGET cTipoLim When .F. SIZE 45,9 OF oDlg PIXEL CENTERED
	@ 77,115 MSGET oSaldo VAR nSaldo Picture "@E 999,999,999.99" When .F. SIZE 85,9 OF oDlg PIXEL RIGHT
	@ 89,115 MSGET nTotal Picture "@E 999,999,999.99" When .F. SIZE 85,9 OF oDlg PIXEL RIGHT
	@ 101,115 MSGET oSaldif VAR nSalDif Picture "@E 999,999,999.99" When .F. SIZE 85,9 OF oDlg PIXEL RIGHT
	@ 113,115 MSGET cObs Picture "@!" SIZE 85,9 OF oDlg PIXEL

	@ 132, 80 BUTTON OemToAnsi("Libera Docto")   SIZE 40 ,11  FONT oDlg:oFont ACTION (nOpc:=2,oDlg:End())  OF oDlg PIXEL
	@ 132,121 BUTTON OemToAnsi("Cancela")        SIZE 40 ,11  FONT oDlg:oFont ACTION (nOpc:=1,oDlg:End())  OF oDlg PIXEL
	@ 132,162 BUTTON OemToAnsi("Bloqueia Docto") SIZE 40 ,11  FONT oDlg:oFont ACTION (nOpc:=3,oDlg:End())  OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED


	If nOpc == 2 .Or. nOpc == 3

		SCR->(dbClearFilter())
		SCR->(dbGoTo(nReg))

		_cDoc := Left(SCR->CR_NUM,_nTamEdt)
		CO1->(DbSetOrder(1))
		If CO1->(DbSeek(xFilial("CO1")+_cDoc))

			Begin Transaction

				lLiberou := MaAlcDoc({cDocto,cTipo,nTotal,cCodLiber,,CO1->CO1_XGRLIB,,,,,cObs},dRefer,If(nOpc==2,4,6))

				If lLiberou
					// Se liberou total
					CO1->(DbSetOrder(1))
					CO1->(DbSeek(xFilial("CO1")+_cDoc))
					RecLock("CO1",.F.)
					CO1->CO1_XLIBER := "L"
					CO1->(MsUnLock())
					// grava LOG - Tabela COI
					//COMA080(CO1->CO1_CODEDT,"001","COI_DTHAPR","COI_UAPR", .T.)
				EndIf

				If nOpc == 3
					// Se Bloqueou
					CO1->(DbSetOrder(1))
					CO1->(DbSeek(xFilial("CO1")+_cDoc))
					RecLock("CO1",.F.)
					CO1->CO1_XLIBER := "R"
					CO1->(MsUnLock())
				EndIf

			End Transaction

			#IFDEF TOP
			If TcSrvType() == "AS/400"
				set filter to  &(cXFiltraSCR)
			Else
				#ENDIF
				SCR->(Eval(bFilSCRBrw))
				#IFDEF TOP
			EndIf
			#ENDIF

		Else
			ApMsgStop("Edital " + _cDoc + " nao localizado !!!","Verifique")
		EndIf
	EndIf

	RestArea(_aAreaCO1)
	RestArea(_aArea)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fEstEDT
Funcao de estorno de liberacao.

@type function
@author Adriano Luis Brandao
@since 21/07/2011
@version P12.1.23

@obs Projeto ELO

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fEstEDT()

	Local _cDoc		:= ""
	local _nTamEdt 	:= TamSx3("CO1_CODEDT")[1]+TamSx3("CO1_NUMPRO")[1]

	//
	// Testar se o documento nao foi utilizado em licitação, cotação, pedido de compra ou eliminada por resíduo
	//

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------S

	If ApMsgYesNo("Confirma estorno da liberacao ??","Confirmar")
		_cDoc := Left(SCR->CR_NUM,_nTamEdt)

		/*
		// se ja foi utilizado em algum processo compras, nao pode ser estornado
		If ! fVerUso(_cDoc)
		ApMsgInfo("Este edital já foi utilizado","Aviso")
		Return
		EndIf
		*/

		CO1->(DbSetOrder(1))
		If CO1->(DbSeek(xFilial("CO1")+_cDoc))
			_nTotEDT := 999
			MaAlcDoc({CO1->CO1_CODEDT+CO1->CO1_NUMPRO,"ED",_nTotEDT,,,,,1,0,},CO1->CO1_DTABER,3)
			CO1->(DbSetOrder(1))
			IF CO1->(dbSeek(XFilial("CO1")+_cDoc)) .and. !Empty(CO1->CO1_XGRLIB)
				MaAlcDoc({_cDoc,"ED",_nTotEDT,,,CO1->CO1_XGRLIB,,1,1,CO1->CO1_DTABER},,1)
			EndIf
			SCR->(dbSetOrder(1))
			// Se gerou SCR, bloqueia solicitacao novamente.
			IF SCR->(dbSeek(XFilial("SCR")+"ED"+CO1->CO1_CODEDT+CO1->CO1_NUMPRO))
				RecLock("CO1",.F.)
				CO1->CO1_XLIBER := "B"
				CO1->(MsUnLock())
			EndIf
		Else
			ApMsgStop("Edital " + _cDoc + " nao localizada !!!","Verifique")
		EndIf
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fPosic
Consulta do status das Aprovacoes Documentos PC/AE/CP/NF.

@type function
@author Alexandre Inacio Lemes
@since 05/05/2006
@version P12.1.23

@param cAlias, Caractere, Alias do arquivo
@param nReg, Numérico, Numero do registro
@param nOpcx, Numérico, Opcao selecionada
@param cTipoDoc, Caractere, Tipo do Documento

@obs Projeto ELO

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fPosic(cAlias,nReg,nOpcx,cTipoDoc)

	Local aArea		:= GetArea()
	//Local aSavCols  := aClone(aCols)
	//Local aSavHead  := aClone(aHeader)

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

	//Local nSavN		:= N
	Local nX   		:= 0
	Local nY        := 0

	Local oDlg
	Local oGet
	Local oBold

	#IFDEF TOP
	Local cQuery   := ""
	Local aStruSCR := {}
	#ENDIF

	DEFAULT cTipoDoc := "ED"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea(cAlias)
	(cAlias)->(dbGoto(nReg))


	If !Empty(CO1->CO1_XGRLIB)
		cTitle    := OemToAnsi("Aprovacao de Edital")
		cTitDoc   := OemToAnsi("Edital")
		cHelpApv  := OemToAnsi("Este edital nao possui controle de aprovacao.")
		cNumDoc   := CO1->CO1_CODEDT+CO1->CO1_NUMPRO
		cStatus   := IIF(CO1->CO1_XLIBER=="L",OemToAnsi("EDITAL LIBERADO"),OemToAnsi("AGUARDANDO LIB."))
	EndIf

	If !Empty(cNumDoc)

		aHeader:= {}
		aCols  := {}

		//+--------------------------------------------------------------+
		//| Faz a montagem do aHeader com os campos fixos.               |
		//+--------------------------------------------------------------+
		dbSelectArea("SX3")
		SX3->(dbSetOrder(1))
		SX3->(MsSeek("SCR"))
		While !Eof() .And. (SX3->X3_ARQUIVO == "SCR")
			IF AllTrim(SX3->X3_CAMPO)$"CR_NIVEL/CR_OBS/CR_DATALIB"
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

				If AllTrim(SX3->X3_CAMPO) == "CR_NIVEL"
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
		cTipoDoc := "ED"
		cAliasSCR := GetNextAlias()
		cQuery    := "SELECT SCR.*,SCR.R_E_C_N_O_ SCRRECNO FROM "+RetSqlName("SCR")+" SCR "
		cQuery    += "WHERE SCR.CR_FILIAL='"+xFilial("SCR")+"' AND "
		cQuery    += "SCR.CR_NUM = '"+Padr(CO1->CO1_CODEDT+CO1->CO1_NUMPRO,Len(SCR->CR_NUM))+"' AND "
		cQuery    += "SCR.CR_TIPO = 'ED' AND "
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
		(cAliasSCR)->(MsSeek(xFilial("SCR")+cTipoDoc+Padr(CO1->CO1_CODEDT+CO1->CO1_NUMPRO,Len(SCR->CR_NUM))))

		#ENDIF

		dbSelectArea(cAliasSCR)

		While !Eof() .And.(cAliasSCR)->CR_FILIAL+(cAliasSCR)->CR_TIPO+Substr((cAliasSCR)->CR_NUM,1,;
		len(CO1->CO1_CODEDT+CO1->CO1_NUMPRO)) ;
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
						cSituaca := OemToAnsi("Edital Aprovado")
						Case (cAliasSCR)->CR_STATUS == "04"
						cSituaca := OemToAnsi("Edital Bloqueado")
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
		dbCloseArea()
		//aHeader := aClone(aSavHead)
		//aCols   := aClone(aSavCols)
		//N		:= nSavN
	Else
		Aviso("Atencao",cHelpApv,{"Voltar"})
	EndIf

	dbSelectArea(cAlias)
	RestArea(aArea)

Return