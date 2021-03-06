#Include "Protheus.ch"
#Include "Topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIESTA05
Funcao para Liberacao de documentos.

@type function
@author Leonardo Soncin
@since 28/11/2011
@version P12.1.23

@param _nOpcao, Num�rico, 1 = Consulta / 2 = Liberacao / 3 = Estornar / 4 = Consulta Aprovacao

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIESTA05(_nOpcao)

	Local _aArea	:= {}
	Local _aAreaCR	:= {}
	Local _cDoc		:= ""
	Local _nTamDoc 	:= TamSx3("CP_NUM")[1]
	Private lCopia 	:= .F.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If _nOpcao == 1 // Consulta

		_aArea := GetArea()
		_aAreaCR := SCR->(GetArea())
		_cDoc := Left(SCR->CR_NUM,_nTamDoc)
		SCP->(DbSetOrder(1))
		If SCP->(DbSeek(xFilial("SCP")+_cDoc))
			DbSelectArea("SCP")
			A105Visual("SCP",RecNo(),2)
		EndIf
		RestArea(_aAreaCR)
		RestArea(_aArea)

	ElseIf _nOpcao == 2 // Liberacao

		fLibSA("SCR",RecNo(),_nOpcao)

	ElseIf _nOpcao == 3 // Estornar

		fEstSA()

	ElseIf _nOpcao == 4 // Consulta Aprovacao

		_aArea := GetArea()
		_aAreaCR := SCR->(GetArea())
		fPosic("SCP",Recno(),2,"SA")
		RestArea(_aAreaCR)
		RestArea(_aArea)

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fLibSA
Funcao para Liberacao de edital.

@type function
@author Adriano Luis Brandao
@since 20/07/2011
@version P12.1.23

@param cAlias, Caractere, Alias da tabela.
@param nReg, Num�rico, RECNO do registro posicionado.
@param nOpcx, Num�rico, N�mero da op��o.

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fLibSA(cAlias,nReg,nOpcx)

	Local _aArea	:= GetArea()
	Local _aAreaSCP	:= SCP->(GetArea())
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
	local _nTamDoc 	:= TamSx3("CP_NUM")[1]
	Local cName		:= ""
	Local nOpc		:= 0
	Local lLiberou	:= .F.
	Local cGrupo	:= ""

	//--< Log das Personaliza��es >-----------------------------
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

	_cDoc := Left(SCR->CR_NUM,_nTamDoc)
	SCP->(DbSetOrder(1))
	SCP->(DbSeek(xFilial("SCP")+_cDoc))

	DEFINE MSDIALOG oDlg FROM 0,0 TO aSize[1],aSize[2] TITLE OemToAnsi("Liberacao de SA") PIXEL
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
	@ 113,06 Say OemToAnsi("Observa�-es ") SIZE 100,10 OF oDlg PIXEL
	@ 07,58  MSGET SCR->CR_NUM     When .F. SIZE 28 ,9 OF oDlg PIXEL
	@ 07,155 MSGET SCR->CR_EMISSAO When .F. SIZE 45 ,9 OF oDlg PIXEL
	@ 19,45  MSGET SCP->CP_CC      When .F. SIZE 155,9 OF oDlg PIXEL
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

		_cDoc := Left(SCR->CR_NUM,_nTamDoc)
		SCP->(DbSetOrder(1))
		If SCP->(DbSeek(xFilial("SCP")+_cDoc))

			dbSelectArea("CT1")
			CT1->(dbSetOrder(1))
			CT1->(dbSeek(xFilial("CT1")+SCP->CP_CONTA))

			dbSelectArea("SZQ")
			SZQ->(dbSetOrder(1))
			SZQ->(dbSeek(xFilial("SZQ")+SCP->CP_CC+CT1->CT1_PREFIX))
			cGrupo := SZQ->ZQ_COD

			dbSelectArea("SCP")

			Begin Transaction

				lLiberou := MaAlcDoc({cDocto,cTipo,nTotal,cCodLiber,,cGrupo,,,,,cObs},dRefer,If(nOpc==2,4,6))

				If lLiberou
					// Se liberou total
					SCP->(DbSetOrder(1))
					SCP->(DbSeek(xFilial("SCP")+_cDoc))
					While SCP->(!Eof()) .and. SCP->CP_NUM == _cDoc
						RecLock("SCP",.F.)
						SCP->CP_STATSA := "L"
						SCP->(MsUnLock())
						SCP->(dbSkip())
					Enddo
				EndIf

				If nOpc == 3
					// Se Bloqueou
					SCP->(DbSetOrder(1))
					SCP->(DbSeek(xFilial("SCP")+_cDoc))
					While SCP->(!Eof()) .and. SCP->CP_NUM == _cDoc
						RecLock("SCP",.F.)
						SCP->CP_STATSA := "B"
						SCP->(MsUnLock())
						SCP->(dbSkip())
					EndDo
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
			ApMsgStop("SA " + _cDoc + " nao localizado !!!","Verifique")
		EndIf
	EndIf

	RestArea(_aAreaSCP)
	RestArea(_aArea)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fEstSA
Funcao de estorno de liberacao.

@type function
@author Adriano Luis Brandao
@since 21/07/2011
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fEstSA()
	Local lEstorna	:= .f.
	Local _cDoc		:= ""
	local _nTamDoc 	:= TamSx3("CP_NUM")[1]
	Local cGrupo 	:= ""
	Local nTot		:= 0
	Local dEmissao
	Local nReg		:= SCR->(Recno())

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//
	// Testar se o documento nao foi utilizado em licita��o, cota��o, pedido de compra ou eliminada por res�duo
	//

	If ApMsgYesNo("Confirma estorno da libera��o?","Confirmar")
		_cDoc := Left(SCR->CR_NUM,_nTamDoc)

		SCP->(DbSetOrder(1))
		If SCP->(DbSeek(xFilial("SCP")+_cDoc))

			dEmissao	:= SCR->CR_EMISSAO

			dbSelectArea("CT1")
			CT1->(dbSetOrder(1))
			CT1->(dbSeek(xFilial("CT1")+SCP->CP_CONTA))

			dbSelectArea("SZQ")
			SZQ->(dbSetOrder(1))
			IF SZQ->(dbSeek(xFilial("SZQ")+SCP->CP_CC+CT1->CT1_PREFIX))
				cGrupo := SZQ->ZQ_COD
			ELSEIF SZQ->(dbSeek(xFilial("SZQ")+SCP->CP_CC))
				cGrupo := SZQ->ZQ_COD
			ENDIF

			dbSelectArea("SCP")
			While SCP->(!Eof()) .and. SCP->CP_NUM == _cDoc
				nTot += SCP->CP_XVLRTOT
				SCP->(dbSkip())
			Enddo

			SCR->(dbClearFilter())
			SCR->(dbGoTo(nReg))

			MaAlcDoc({_cDoc,"SA",nTot,,,,,1,0,},dEmissao,3)

			SCP->(DbSetOrder(1))
			IF SCP->(dbSeek(XFilial("SCP")+_cDoc)) .and. !Empty(cGrupo)
				MaAlcDoc({_cDoc,"SA",nTot,,,cGrupo,,1,1,dEmissao},,1)
			EndIf
			SCR->(dbSetOrder(1))

			// Se gerou SCR, bloqueia solicitacao novamente.
			IF SCR->(dbSeek(xFilial("SCR")+"SA"+_cDoc))
				dbSelectArea("SCP")
				While SCP->(!Eof()) .and. CP_FILIAL == xFilial("SCP") .and. CP_NUM == _cDoc
					RecLock("SCP",.F.)
					SCP->CP_STATSA := "E"
					SCP->(MsUnLock())
					SCP->(dbSkip())
				Enddo
			EndIf
		Else
			ApMsgStop("SA " + _cDoc + " nao localizada!","Verifique")
		EndIf
	EndIf

	#IFDEF TOP
	If TcSrvType() == "AS/400"
		set filter to  &(cXFiltraSCR)
	Else
		#ENDIF
		SCR->(Eval(bFilSCRBrw))
		#IFDEF TOP
	EndIf
	#ENDIF

Retur

/*/================================================================================================================================/*/
/*/{Protheus.doc} fPosic
Consulta do status das Aprovacoes Documentos PC/AE/CP/NF.

@type function
@author Alexandre Inacio Lemes
@since 05/05/2006
@version P12.1.23

@param cAlias, Caractere, Alias do arquivo.
@param nReg, Num�rico, N�mero do registro.
@param nOpcx, Num�rico, Op��o selecionada.
@param cTipoDoc, Caractere, Tipo do Documento.

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

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

	DEFAULT cTipoDoc := "SA"

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

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
					AADD(aHeader,{ OemToAnsi("Usu�rio"),"bCR_NOME",   "",15,0,"","","C","",""} )
					AADD(aHeader,{ OemToAnsi("Situa��o"),"bCR_SITUACA","",20,0,"","","C","",""} )
					AADD(aHeader,{ OemToAnsi("Usu�rio Lib."),"bCR_NOMELIB","",15,0,"","","C","",""} )
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
						cSituaca := OemToAnsi("Aguarando Libera��o")
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
			//n:=	 IIF(n > Len(aCols), Len(aCols), n)  // Feito isto p/evitar erro fatal(Array out of Bounds). Gilson-Localiza��es
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
		//aHeader := aClone(aSavHead)
		//aCols   := aClone(aSavCols)
		//N		:= nSavN
	Else
		Aviso("Atencao",cHelpApv,{"Voltar"})
	EndIf

	dbSelectArea(cAlias)
	RestArea(aArea)
return

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIEST5GR
Funcao para Liberacao de documentos.

@type function
@author Leonardo Soncin
@since 28/11/2011
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIEST5GR()
	Local cGrupo  := ""
	Local cPrefix := ""
	Local cDoc	  := SCP->CP_NUM
	Local nPTot	  := aScan(aHeader,{|x| AllTrim(x[2])=="CP_XVLRTOT"})
	Local nPItem  := aScan(aHeader,{|x| AllTrim(x[2])=="CP_ITEM"})
	Local _nTot   := 0
	Local nY
	Local lEstorna := .T.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	For nY := 1 to Len(aCols)
		If !(GdDeleted( nY, aHeader, aCols))

			dbSelectArea("CT1")
			CT1->(dbSetOrder(1))
			CT1->(dbSeek(xFilial("CT1")+SCP->CP_CONTA))
			cPrefix	:= CT1->CT1_PREFIX

			dbSelectArea("SZQ")
			SZQ->(dbSetOrder(1))
			IF SZQ->(dbSeek(xFilial("SZQ")+_c105CCusto+cPrefix))
				cGrupo	:= SZQ->ZQ_COD
			ELSEIF SZQ->(dbSeek(xFilial("SZQ")+_c105CCusto+Space(TamSX3("CT1_PREFIX")[1])))
				cGrupo	:= SZQ->ZQ_COD
			ENDIF

			dbSelectArea("SCP")

			If INCLUI .or. ALTERA
				SCP->(dbSeek(xFilial("SCR")+cA105Num+aCols[nY][nPItem]))
				RecLock("SCP",.F.)
				SCP->CP_CC := _c105CCusto
				If !Empty(cGrupo)
					SCP->CP_STATSA := "E"
					SCP->CP_XAPROV := cGrupo
				Endif
				SCP->(MsUnlock())
			ENDIF

			_nTot += aCols[nY][nPTot]
		Endif
	Next nY

	SCR->(dbSetOrder(1))

	// Se gerou SCR, estorna.
	If !INCLUI
		IF SCR->(dbSeek(xFilial("SCR")+"SA"+cDoc))
			If ALTERA
				IF SCR->CR_TOTAL >= _nTot
					lEstorna := .F.
				Endif
			Endif
			If lEstorna
				MaAlcDoc({cDoc,"SA",_nTot,,,,,1,0,},SCP->CP_EMISSAO,3)
			Else
				//Atualiza valor da alcada
				While SCR->(!Eof()) .and. SCR->CR_FILIAL == XFilial("SCR") .and. Alltrim(SCR->CR_NUM) == Alltrim(cDoc) .and. SCR->CR_TIPO == "SA"
					RecLock("SCR",.F.)
					SCR->CR_TOTAL := _nTot
					SCR->(msUnlock())
					SCR->(dbSkip())
				Enddo
			Endif
			_cStatus := _fVerifSA(cDoc) // Verificar se estava aprovado
			// altera flag
			For nY := 1 to Len(aCols)
				If !(GdDeleted( nY, aHeader, aCols))
					IF SCP->(dbSeek(xFilial("SCR")+cA105Num+aCols[nY][nPItem]))
						RecLock("SCP",.F.)
						SCP->CP_STATSA := _cStatus
						SCP->(MsUnlock())
					EndIf
				Endif
			Next nY
		EndIf
	Endif

	If INCLUI .or. ALTERA
		// Gravar Alcada SCR
		IF !SCR->(dbSeek(xFilial("SCR")+"SA"+cDoc))
			MaAlcDoc({cDoc,"SA",_nTot,,,cGrupo,,1,1,SCP->CP_EMISSAO},,1)
		Endif
	Endif

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} _fVerifSA
Verifica status da Solicita��o de Armaz�m.

@type function
@author Thiago Rasmussen
@since 27/03/2012
@version P12.1.23

@param cDoc, Caractere, N�mero da Solicita��o de Armaz�m.

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Caractere, Status da Solicita��o.

/*/
/*/================================================================================================================================/*/

Static Function _fVerifSA(cDoc)
	Local _cRet := "E"

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SCR->(dbSetOrder(1))
	SCR->(dbSeek(xFilial("SCR")+"SA"+cDoc))
	While SCR->(!Eof()) .and. SCR->CR_FILIAL == XFilial("SCR") .and. SCR->CR_TIPO == "SA" .and. Alltrim(SCR->CR_NUM) == Alltrim(cDoc)
		If (SCR->CR_STATUS $ ("03|05")) // aprovado
			_cRet := "L"
		ElseIf SCR->CR_STATUS == "04" // reprovado
			_cRet := "B"
		ElseIf SCR->CR_STATUS == "02" // em aprovacao
			_cRet := "E"
		EndIf
		SCR->(dbSkip())
	Enddo

Return(_cRet)
