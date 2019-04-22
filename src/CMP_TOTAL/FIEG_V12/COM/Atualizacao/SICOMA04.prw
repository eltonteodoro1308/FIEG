#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Ap5mail.ch"

#Define BMP_ON "LBOK"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA04
Funcao para Liberacao de documentos.

@type function
@author Adriano Luis Brandao
@since 20/07/2011
@version P12.1.23

@param _nOpcao, Numérico, Numero da opção selecionada: 1 = Consulta / 2 = Liberacao / 3 = Estornar.

@obs Projeto ELO alterado pela FIEG

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.
@history 08/04/2019, Kley@TOTVS.com.br, Remoçao do tratamento para Edital.
/*/
/*/================================================================================================================================/*/

User Function SICOMA04(_nOpcao)

	Local _aArea	:= {}
	Local _aAreaCR	:= {}
	Local _cDoc		:= ""
	Local _Array    := {}
	Local lSegue    := .T.
	private aPeds 	:= {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	IF _nOpcao == 1 // Consulta
		// se for solicitacao de compras
		IF SCR->CR_TIPO == "SC"
			_aArea := GetArea()
			_aAreaCR := SCR->(GetArea())
			_cDoc := Left(SCR->CR_NUM,Len(SC1->C1_NUM))
			SC1->(DbSetOrder(1))
			IF SC1->(DbSeek(xFilial("SC1")+_cDoc))
				DbSelectArea("SC1")
				A110Visual("SC1",RecNo(),2)
			ENDIF
			RestArea(_aAreaCR)
			RestArea(_aArea)
		//ELSEIF SCR->CR_TIPO == "ED"						// Remoçao do tratamento para Edital, 08/04/2019, Kley@TOTVS.com.br
		//	U_SICOMA03(_nOpcao)
		ELSEIF SCR->CR_TIPO == "SA"
			U_SIESTA05(_nOpcao)
		ELSE	// visualizacao padrao
			A097Visual(,,2)
		ENDIF

	ELSEIF _nOpcao == 2 // Liberacao

		IF !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS$"03#05"
			Help(" ",1,"A097LIB")
			lSegue := .F.
		ELSEIF SCR->CR_STATUS$"01"
			Aviso("A097BLQ","Esta operação não poderá ser realizada pois este registro se encontra bloqueado pelo sistema (aguardando outros niveis)",{"Ok"})
			lSegue := .F.
		ENDIF

		If lSegue

			IF SCR->CR_TIPO == "SC"
				MsgRun("Liberando solicitação "+TRIM(SCR->CR_NUM)+", aguarde...","",{|| fLibSC()  })
				_FVERLOG(aPeds,"Pedidos gerado")
			//ELSEIF SCR->CR_TIPO == "ED"					// Remoçao do tratamento para Edital, 08/04/2019, Kley@TOTVS.com.br
			//	U_SICOMA03(_nOpcao)
			ELSEIF SCR->CR_TIPO == "SA"
				U_SIESTA05(_nOpcao)
			ELSE
				A097Libera("SCR",recno(),2)
			ENDIF

		EndIf


	ELSEIF _nOpcao == 3 // Estornar

		IF SCR->CR_STATUS$"01"
			Aviso("A097BLQ","Esta operação não poderá ser realizada pois este registro se encontra bloqueado pelo sistema (aguardando outros niveis)",{"Ok"})
			lSegue := .F.
		ENDIF

		IF lSegue .And. SCR->CR_STATUS$"02"
			Aviso("A097BLQ","Esta operação não poderá ser realizada pois este registro já foi estornado.",{"Ok"})
			lSegue := .F.
		ENDIF

		If lSegue

			IF SCR->CR_TIPO == "SC"
				// 18/05/2015 - Thiago Rasmussen - Não permitir estorno de aprovação de solicitações enviadas para GEMAT.
				_Array := GetAdvFVal("SC1", { "C1_PEDIDO", "C1_XCONTPR", "C1_XGEMAT", "C1_XCONTFI", "C1_XCONTRV" }, XFILIAL("SC1")+ALLTRIM(SCR->CR_NUM), 1, { "", "", "" })

				// 10/03/2016 - Thiago Rasmussen - Não permitir estornar uma medição de um contrato fora do período de vigência ou com situação diferente de vigente.
				IF !EMPTY(_Array[2])
					IF POSICIONE("CN9", 1, _Array[4] + _Array[2] + _Array[5], "CN9_SITUAC") <> "05"
						MsgAlert("Esta operação não poderá ser realizada pois este registro trata-se de uma solicitação de registro de preço, gerada através de um contrato que está com a situação diferente de vigente!","SICOMA04")
						lSegue := .F.
					ENDIF

					IF lSegue .And. POSICIONE("CN9", 1, _Array[4] + _Array[2] + _Array[5], "CN9_DTFIM") < DDATABASE
						MsgAlert("Esta operação não poderá ser realizada pois este registro trata-se de uma solicitação de registro de preço, gerada através de um contrato que está fora do período de vigência!","SICOMA04")
						lSegue := .F.
					ENDIF

				ENDIF

				If lSegue

					IF _Array[3] == "2"
						MsgAlert("Esta operação não poderá ser realizada pois este registro já está sobre a responsabilidade da GEMAT.","SICOMA04")
						lSegue := .F.
					ENDIF

					IF lSegue .And. !EMPTY(_Array[1]) .AND. !EMPTY(_Array[2])
						IF GetAdvFVal("SC7", "C7_CONAPRO", XFILIAL("SC7")+ALLTRIM(_Array[1]), 1, "B", .T.) != "B"
							MsgAlert("Esta operação não poderá ser realizada pois este registro trata-se de uma solicitação de registro de preço, que já encontra-se com a alçada do pedido de compra aprovada.","SICOMA04")
							lSegue := .F.
						ENDIF
					ENDIF

					If lSegue

						MsgRun("Estornando liberação da solicitação " + TRIM(SCR->CR_NUM) + ", aguarde...","",{|| fEstSC()  })
						_FVERLOG(aPeds,"Pedidos estornados")

					EndIf

				EndIf

			//ELSEIF SCR->CR_TIPO == "ED"					// Remoçao do tratamento para Edital, 08/04/2019, Kley@TOTVS.com.br
			//	U_SICOMA03(_nOpcao)
			ELSEIF SCR->CR_TIPO == "SA"
				U_SIESTA05(_nOpcao)
			ELSE
				A097Estorna("SCR",recno(),2)
			ENDIF

		ENDIF

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fLibSC
Funcao para Liberacao de solicitacao de compras.

@type function
@author Adriano Luis Brandao
@since 20/07/2011
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function fLibSC()
	Local _aArea	  := GetArea()
	Local _aAreaC1	  := SC1->(GetArea())
	Local _aAreaCR    := SCR->(GetArea())
	Local cCodLiber   := SCR->CR_APROV
	Local cDocto      := SCR->CR_NUM
	Local cTipo       := SCR->CR_TIPO
	Local aSize       := {360,410}
	Local cObs        := Alltrim(SCR->CR_OBS)
	Local ca097User   := RetCodUsr()
	Local dRefer 	  := dDataBase
	Local aRetSaldo	  := {}
	Local nSaldo	  := 0
	Local CRoeda	  := ""
	Local nTotal	  := 0
	Local nSalDif	  := 0
	Local _cDoc       := ""
	Local cName       := ""
	Local nOpc        := 0
	Local lLiberou	  := .f.
	Local _cCodUsu	  := ""
	Local cParam	  := GetMv("SI_XMED", .F.) // FSW - Alteração para o Gap097
	Local _lLancSC	  := PcoExistLc("000051","02","1") // Verifica se existe lançamento ativo
	Local _lBloqSC	  := PcoExistLc("000051","02","2") // Verifica se existe bloqueio ativo
	Local _lGeraBlq   := .f.
	Local lPrjCni 	  := FindFunction("PRJCNI") .Or. GetRpoRelease("R6")
	Local _cSCRFiltro := ""
	Local nTamOBS     := TamSX3('CR_OBS')[1]
	Local oMemo

	Private _NPERCEMP := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+--------------------------------------------------------------+
	//| Inicializa as variaveis utilizadas no Display.               |
	//+--------------------------------------------------------------+
	aRetSaldo 	:= MaSalAlc(cCodLiber,dRefer)
	nSaldo 	  	:= aRetSaldo[1]
	CRoeda 	  	:= A097Moeda(aRetSaldo[2])
	cName  	  	:= UsrFullName(ca097User)
	nTotal    	:= xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,aRetSaldo[2],SCR->CR_EMISSAO,,SCR->CR_TXMOEDA)
	nSalDif		:= nSaldo - nTotal

	DO CASE
		CASE SAK->AK_TIPO == "D"
		cTipoLim :=OemToAnsi("Diario")
		CASE  SAK->AK_TIPO == "S"
		cTipoLim := OemToAnsi("Semanal")
		CASE  SAK->AK_TIPO == "M"
		cTipoLim := OemToAnsi("Mensal")
		CASE  SAK->AK_TIPO == "A"
		cTipoLim := OemToAnsi("Anual")
	ENDCASE

	_cDoc := Left(SCR->CR_NUM,Len(SC1->C1_NUM))
	SC1->(DbSetOrder(1))
	SC1->(DbSeek(xFilial("SC1")+_cDoc))

	DEFINE MSDIALOG oDlg FROM 0,0 TO aSize[1],aSize[2] TITLE OemToAnsi("Liberacao de SC") PIXEL  //"Liberacao do PC"
	@ 0.5,01 TO 44,304 LABEL "" OF oDlg PIXEL
	@ 45,01  TO 158,304 LABEL "" OF oDlg PIXEL
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
	IF SCR->CR_MOEDA == aRetSaldo[2]
		@ 89,06 Say OemToAnsi("Total do documento ")+CRoeda OF oDlg PIXEL
	ELSE
		@ 89,06 Say OemToAnsi("Total do documento, convertido em ")+CRoeda OF oDlg PIXEL
	ENDIF
	@ 101,06 Say OemToAnsi("Saldo disponivel após liberação  ") +CRoeda SIZE 130,10 OF oDlg PIXEL
	@ 113,06 Say OemToAnsi("Observações ") SIZE 100,10 OF oDlg PIXEL
	@ 07,58  MSGET SCR->CR_NUM     When .F. SIZE 28 ,9 OF oDlg PIXEL
	@ 07,155 MSGET SCR->CR_EMISSAO When .F. SIZE 45 ,9 OF oDlg PIXEL
	@ 19,45  MSGET SC1->C1_CC      When .F. SIZE 155,9 OF oDlg PIXEL
	@ 31,45  MSGET cName           When .F. SIZE 50 ,9 OF oDlg PIXEL
	@ 31,155 MSGET oDataRef VAR dRefer When .F. SIZE 45 ,9 OF oDlg PIXEL
	@ 53,50  MSGET SAK->AK_LIMMIN Picture "@E 999,999,999.99" When .F. SIZE 55,9 OF oDlg PIXEL RIGHT
	@ 53,155 MSGET SAK->AK_LIMMAX Picture "@E 999,999,999.99" When .F. SIZE 45,9 OF oDlg PIXEL RIGHT
	@ 65,50  MSGET SAK->AK_LIMITE Picture "@E 999,999,999.99" When .F. SIZE 55,9 OF oDlg PIXEL RIGHT
	@ 65,155 MSGET cTipoLim When .F. SIZE 45,9 OF oDlg PIXEL CENTERED
	@ 77,115 MSGET oSaldo VAR nSaldo Picture "@E 999,999,999.99" When .F. SIZE 85,9 OF oDlg PIXEL RIGHT
	@ 89,115 MSGET nTotal Picture "@E 999,999,999.99" When .F. SIZE 85,9 OF oDlg PIXEL RIGHT
	@ 101,115 MSGET oSaldIF VAR nSalDIF Picture "@E 999,999,999.99" When .F. SIZE 85,9 OF oDlg PIXEL RIGHT
	@ 113,115 GET oMemo VAR cObs MEMO SIZE 85, 40 Valid Iif(Len(cObs)<=nTamOBS, .T., Eval( {|| Alert('Diminua o tamanho do texto para '+Alltrim(str(nTamOBS))),.F.} )) OF oDlg PIXEL

	@ 162, 80 BUTTON OemToAnsi("Aprovar")  SIZE 40 ,11  FONT oDlg:oFont ACTION (nOpc:=2,oDlg:End())  OF oDlg PIXEL
	@ 162,121 BUTTON OemToAnsi("Fechar")   SIZE 40 ,11  FONT oDlg:oFont ACTION (nOpc:=1,oDlg:End())  OF oDlg PIXEL
	@ 162,162 BUTTON OemToAnsi("Reprovar") SIZE 40 ,11  FONT oDlg:oFont ACTION (nOpc:=3,oDlg:End())  OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

	IF nOpc == 2 .Or. nOpc == 3
		_cDoc := Left(SCR->CR_NUM,Len(SC1->C1_NUM))
		SC1->(DbSetOrder(1))
		IF SC1->(DbSeek(xFilial("SC1")+_cDoc))

			// Guarda filtro da SCR
			IF !Empty( _cSCRFiltro := SCR->(dbFilter()) )
				SCR->(dbClearFilter())
			ENDIF

			lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,nTotal,cCodLiber,ca097User,SC1->C1_XGRPAPR,,,,,cObs},dRefer,If(nOpc==2,4,6))

			// Se liberou total, envia e-mail de liberado
			SCR->(dbSetOrder(1))
			SCR->(dbSeek(xFilial("SCR")+"SC"+_cDoc))
			WHILE SCR->(!Eof()) .and. SCR->CR_FILIAL == XFilial("SCR") .and. SCR->CR_TIPO == "SC" .and. Alltrim(SCR->CR_NUM) == Alltrim(_cDoc)
				IF (SCR->CR_STATUS $ ("03|05")) // aprovado
					_cRet := "L"
				ELSEIF SCR->CR_STATUS == "04" // reprovado
					_cRet := "B"
				ELSEIF (SCR->CR_STATUS $ ("01|02")) // em aprovacao
					_cRet := "E"
				ENDIF
				SCR->(dbSkip())
			ENDDO

			// Restaura filtro da SCR
			IF !Empty( _cSCRFiltro ) // verifica filtro
				SCR->&(_cSCRFiltro)
			ENDIF

			// Se liberou total, envia e-mail de liberado
			SC1->(DbSetOrder(1))
			IF _cRet == "L" .and. SC1->(DbSeek(xFilial("SC1")+_cDoc))

				// FSW - Alteração para o Gap087 - CNI
				IF _lLancSC .and. _lBloqSC .and. U__fBloqSC(.f.,_cDoc)
					_lGeraBlq := .t.
				ENDIF

				_cCodUsu := SC1->C1_USER
				Do WHILE ! SC1->(Eof()) .And. SC1->C1_FILIAL == xFilial("SC1") .And. SC1->C1_NUM == _cDoc
					// Atualiza status da SC
					RecLock("SC1",.F.)
					SC1->C1_APROV := IIF(_lLancSC .and. _lGeraBlq,"O","L")
					SC1->(MsUnLock())

					IF lPrjCni .and. FindFunction("RSTSCLOG")
						RSTSCLOG("APR",1,/*cUsrWF*/)
					ENDIF

					// Gera lançamentos realizados
					IF _lLancSC .and. !_lGeraBlq

						SZW->(dbSetOrder(1))
						IF SZW->(MsSeek(xFilial("SZW")+SC1->(C1_NUM+C1_ITEM)))

							_cFilBkp := cFilAnt
							WHILE SZW->(!Eof()) .and. SZW->(ZW_FILIAL+ZW_NUMSC+ZW_ITEMSC) == XFilial("SZW")+SC1->(C1_NUM+C1_ITEM)
								// Altera empresa
								cFilAnt := SZW->ZW_CODEMP

								_NPERCEMP := SZW->ZW_PERC

								MsgRun("Gerando Movimentos da SC "+SC1->C1_NUM,"",{|| CursorWait(), PcoIniLan('000051'), PcoDetLan('000051','02','MATA110'), PcoFinLan('000051'), CursorArrow()})

								// Restaura filial
								cFilAnt := _cFilBkp

								SZW->(dbSkip())
							ENDDO
						ELSE
							MsgRun("Gerando Movimentos da SC "+SC1->C1_NUM,"",{|| CursorWait(), PcoIniLan('000051'), PcoDetLan('000051','02','MATA110'), PcoFinLan('000051'), CursorArrow()})
						ENDIF
					ENDIF

					_NPERCEMP := 0

					SC1->(DbSkip())
				ENDDO

				// FSW - Alteração para o Gap097 - CNI
				// Se parametro SI_XMED for igual a 1 deve fazer a medição na liberação da solicitação de compras
				IF (cParam == "1") .and. _cRet == "L" .and. !_lGeraBlq
					_aRecSC1 := SC1->(GetArea())
					U_CNI109AL(_cDoc, cTipo, nOpc)
					RestArea(_aRecSC1)
				ENDIF

				IF nOpc == 2
					fEmail(IIF(_lGeraBlq,"B","L"),_cCodUsu,_cDoc,cObs)
				ENDIF

			ELSEIF _cRet == "E" .and. SC1->(DbSeek(xFilial("SC1")+_cDoc))
				MsgRun('Enviando workflow para aprovador. Aguarde...',, {|| U__WFSendSC(XFilial("SC1"),_cDoc) } ) // envia e-mail para o proximo aprovador
			ENDIF

			// Restaura filtro da SCR
			IF !Empty( _cSCRFiltro ) // verifica filtro
				SCR->(DbSetfilter({||&_cSCRFiltro},_cSCRFiltro))
			ENDIF

			IF nOpc == 3
				// Se Bloqueou, envia e-mail de bloqueio
				SC1->(DbSetOrder(1))
				SC1->(DbSeek(xFilial("SC1")+_cDoc))
				_cCodUsu := SC1->C1_USER
				Do WHILE ! SC1->(Eof()) .And. SC1->C1_FILIAL == xFilial("SC1") .And. SC1->C1_NUM == _cDoc
					RecLock("SC1",.F.)
					SC1->C1_APROV := "R"
					SC1->(MsUnLock())
					SC1->(DbSkip())
				ENDDO
				fEmail("R",_cCodUsu,_cDoc,cObs)
			ENDIF
		ELSE
			ApMsgStop("Solicitacao de compras" + _cDoc + " nao localizada !!!","Verifique")
		ENDIF
	ENDIF

	RestArea(_aAreaC1)
	RestArea(_aAreaCR)
	RestArea(_aArea)
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fEstSC
Funcao de estorno de liberacao.

@type function
@author Thiago Rasmussen
@since 21/07/2011
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fEstSC()
	Local lEstorna	:= .f.
	Local _cDoc		:= ""
	Local lPrjCni   := FindFunction("PRJCNI") .Or. GetRpoRelease("R6")
	Local lSegue    := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//
	// Testar se o documento nao foi utilizado em licitação, cotação, pedido de compra ou eliminada por resíduo
	//
	IF ApMsgYesNo("Confirma estorno da liberação?","Confirmar")
		_cDoc := Left(SCR->CR_NUM,Len(SC1->C1_NUM))
		// se ja foi utilizado em algum processo compras, nao pode ser estornado
		IF ! fVerUso(_cDoc)
			ApMsgInfo("Esta solicitação já foi utilizada!","Aviso")
			lSegue := .T.
		ENDIF

		If lSegue

			SC1->(DbSetOrder(1))
			SC1->(DbGOTOP())
			IF SC1->(DbSeek(xFilial("SC1")+_cDoc))

				_nTotSC := fTotSC(_cDoc)
				MaAlcDoc({SC1->C1_NUM,"SC",_nTotSC,,,,,1,1,},SC1->C1_EMISSAO,3)
				SC1->(DbSetOrder(1))
				IF SC1->(dbSeek(XFilial("SC1")+_cDoc)) .and. !Empty(SC1->C1_XGRPAPR)
					MaAlcDoc({_cDoc,"SC",_nTotSC,,,SC1->C1_XGRPAPR,,1,1,SC1->C1_EMISSAO},,1)
				ENDIF
				SCR->(dbSetOrder(1))
				// Se gerou SCR, bloqueia solicitacao novamente.
				IF SCR->(dbSeek(XFilial("SCR")+"SC"+SC1->C1_NUM))

					Do WHILE ! SC1->(Eof()) .And. SC1->C1_FILIAL == xFilial("SC1") .And. SC1->C1_NUM == _cDoc
						RecLock("SC1",.F.)
						SC1->C1_APROV := "B"
						SC1->C1_WFE   := .F.
						IF !Empty(SC1->C1_XCONTPR)
							SC1->C1_COTACAO := ""
						ENDIF
						SC1->(MsUnLock())

						// Exclui os lançamentos realizados
						SZW->(dbSetOrder(1))
						IF SZW->(MsSeek(xFilial("SZW")+SC1->(C1_NUM+C1_ITEM)))

							_cFilBkp := cFilAnt
							WHILE SZW->(!Eof()) .and. SZW->(ZW_FILIAL+ZW_NUMSC+ZW_ITEMSC) == XFilial("SZW")+SC1->(C1_NUM+C1_ITEM)
								// Altera empresa
								cFilAnt := SZW->ZW_CODEMP

								MsgRun("Estornando Movimentos da SC "+SC1->C1_NUM,"",{|| PcoIniLan('000051'), PcoDetLan('000051','02','MATA110',.T.), PcoFinLan('000051') })

								// Restaura filial
								cFilAnt := _cFilBkp

								SZW->(dbSkip())
							ENDDO
						ELSE
							MsgRun("Estornando Movimentos da SC "+SC1->C1_NUM,"",{|| PcoIniLan('000051'), PcoDetLan('000051','02','MATA110',.T.), PcoFinLan('000051') })
						ENDIF

						// Exclui contingencia
						IF !Empty(SC1->C1_XCDCNTG)
							MsgRun("Estornando Contingência da SC "+SC1->C1_NUM,"",{|| U__fPCOEstCT(SC1->C1_XCDCNTG) })
							// Limpa codigo da contingencia
							RecLock("SC1",.F.)
							SC1->C1_XCDCNTG := ""
							SC1->(MsUnLock())
						ENDIF

						// Exclui LOG - Tabela COI
						U_CNIEstMe() // FSW - Gap097 - Estorno da medição e exclusão de pedido de compra
						RSTSCLOG("APR",3,IIF(!Empty(SCR->CR_APROV),SCR->CR_APROV,""))

						SC1->(DbSkip())
					ENDDO
				ENDIF
			ELSE
				ApMsgStop("Solicitação de compra " + _cDoc + " não localizada!!!","Verifique")
			ENDIF
		ENDIF
	ENDIF

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fEmail
Funcao para envio de e-mail para usuario se solicitacao foi liberada ou bloqueada.

@type function
@author Adriano Luis Brandao
@since 21/07/2011
@version P12.1.23

@param _cAprov, Caractere, L = Liberado / B = Bloqueado / R = Reprovado.
@param _cCodUsu, Caractere, Codigo do usuario.
@param _cDoc, Caractere, Numero da solicitacao de compras.
@param cObs, Caractere, Observações.

@obs Projeto ELO alterado pela FIEG

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fEmail(_cAprov,_cCodUsu,_cDoc,cObs)

	Local cMailDest		:= UsrRetMail(_cCodUsu)
	Local lResul		:= .F.
	Local lOk			:= .F.
	Local cError		:= ""
	Local lSend			:= .F.
	Local lDisConectou	:= .F.
	Local cAssunto		:= ""
	Local cMensagem		:= ""
	Local cWFEMTST      := AllTrim(SuperGetMV("SI_WFEMTST",.F.))
	Local lSegue        := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cMensagem += "Prezado (a) " + UsrFullName(_cCodUsu) + Chr(13) + Chr(10) + Chr(13) + Chr(10)

	DO CASE
		CASE _cAprov == "L"
		cAssunto  := "Solicitação Aprovada - " + xFilial("SCR") + ' / ' + _cDoc
		cMensagem += "Informamos que sua Solicitação de Compras " + xFilial("SCR") + ' / ' + _cDoc + " foi aprovada por " + UsrFullName(RetCodUsr()) + " e encaminhada para a Gerência de Suprimentos." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
		CASE _cAprov == "B"
		cAssunto  := "Solicitação Bloqueada Por Orçamento - " + xFilial("SCR") + ' / ' + _cDoc
		cMensagem += "Informamos que sua Solicitação de Compras " + xFilial("SCR") + ' / ' + _cDoc + " foi aprovada por " + UsrFullName(RetCodUsr()) + " e encontra-se bloqueada por orçamento, solicite contingência." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
		CASE _cAprov == "R"
		cAssunto  := "Solicitação Reprovada - " + xFilial("SCR") + ' / ' + _cDoc
		cMensagem += "Informamos que sua Solicitação de Compras " + xFilial("SCR") + ' / ' + _cDoc + " foi reprovada por " + UsrFullName(RetCodUsr()) + ", verifique o motivo abaixo e providencie a correção." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	ENDCASE

	cMensagem += "Observação: " + cObs + Chr(13) + Chr(10) + Chr(13) + Chr(10) + Chr(13) + Chr(10)

	IF !Empty(cMailDest)

		CONNECT SMTP SERVER GetMv("MV_RELSERV") ACCOUNT GetMv("MV_RELACNT") PASSWORD GetMv("MV_RELPSW") RESULT lResul

		IF GetMv("MV_RELAUTH")
			//Retorna se conseguiu fazer autenticação
			lOk := MailAuth(GetMv("MV_RELACNT"),GetMv("MV_RELPSW"))

			//Atribui retorno de envio de email na variável cError
			IF !lOk
				GET MAIL ERROR cError
				Apmsginfo("Problemas na autenticacao do envio de email de aviso:"+cError)
				lSegue := .F.
			ENDIF
		ENDIF

		If lSegue

			IF !EMPTY(cWFEMTST)
				cMailDest := cWFEMTST
			ENDIF

			//Envio de email
			SEND MAIL FROM AllTrim(GetMv("MV_RELFROM")) TO AllTrim(cMailDest) SUBJECT cAssunto BODY cMensagem RESULT lSend

			IF !lSend
				GET MAIL ERROR cError
				ApMsgInfo("Problemas no envio de email de aviso: " + cError)
			ENDIF

			//Desconecta do servidor
			DISCONNECT SMTP SERVER RESULT lDisConectou

		End If

	ELSE
		ApMsgInfo("Não existe e-mail cadastrado para o usuário " + UsrFullName(_cCodUsu),"Email não enviado")
	ENDIF

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fTotSC
Funcao para totalizacao da solicitacao de compras.

@type function
@author Adriano Luis Brandao
@since 22/07/2011
@version P12.1.23

@param _cDoc, Caractere, Número da Solictação de Compras.

@obs Projeto ELO alterado pela FIEG

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Totalizacao da solicitacao de compras.

/*/
/*/================================================================================================================================/*/

Static Function fTotSC(_cDoc)

	Local _cQuery := ""
	Local _nRet	  := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cQuery := "SELECT SUM(C1_QUANT*C1_VUNIT) TOTAL FROM "+RetSqlName("SC1")+" WHERE D_E_L_E_T_ = ' ' AND C1_FILIAL = '"+xFilial("SC1")+"' "
	_cQuery += "AND C1_NUM = '"+_cDoc+"'"

	TcQuery _cQuery New Alias "_QR1"

	_nRet := _QR1->TOTAL

	_QR1->(DbCloseArea())

Return(_nRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} fVerUso
Funcao para verificacao se solicitacao foi utilizada em processo de cotacao ou pedido de compras.

@type function
@author Adriano Luis Brandao
@since 22/07/2011
@version P12.1.23

@param _cDoc, Caractere, Número da Solictação de Compras.

@obs Projeto ELO alterado pela FIEG

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Indica se solicitacao foi utilizada em processo de cotacao ou pedido de compras.

/*/
/*/================================================================================================================================/*/

Static Function fVerUso(_cDoc)

	Local lRet := .t.
	Local _cQuery := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cQuery := "SELECT C1_NUM, C1_XCONTPR "
	_cQuery += "       FROM "+ RetSqlName("SC1")
	_cQuery += "       WHERE C1_FILIAL = '"+xFilial("SC1")+"' AND C1_NUM = '"+ _cDoc +"' "
	_cQuery += "       AND D_E_L_E_T_ = '' "
	_cQuery += "       AND ( C1_COTACAO <> ' ' OR C1_PEDIDO <> ' ' OR C1_RESIDUO <> ' ' OR C1_XCONTPR <> ' ')

	TcQuery _cQuery New Alias "_QR1"

	// se foi utilizado
	IF ! Empty(_QR1->C1_NUM)
		// FSW - Alteração para o Gap097
		// Se for SC vinculada a contrato de preço pode deixar estornar e o estorno será realizado da medição e exclusão do pedido de compra
		IF (!Empty(AllTrim(_QR1->C1_XCONTPR)))
			lRet := .T.
		ELSE
			lRet := .f.
		ENDIF
	ENDIF

	_QR1->(DbCloseArea())

Return(lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} _fPCOEstCT
Exclusao de contingencia.

@type function
@author Thiago Rasmussen
@since 26/04/2012
@version P12.1.23

@param _cCodCtg, Numérico, Código da Contigência.

@obs Projeto ELO alterado pela FIEG

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function _fPCOEstCT(_cCodCtg)

	Local _cArea := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	ALJ->(dbSetOrder(1))
	ALJ->(dbSeek(XFilial("ALJ")+_cCodCtg))

	PcoIniLan("000356")
	WHILE ALJ->(!Eof()) .and. ALJ->ALJ_FILIAL == XFilial("ALJ") .and. ALJ->ALJ_CDCNTG == _cCodCtg
		PcoDetLan("000356","01","PCOA530",.T.) // Deleta Empenho caso exista
		PcoDetLan("000356","02","PCOA530",.T.) // Deleta Empenho caso exista
		Reclock("ALJ",.F.)
		ALJ->(dbDelete())
		ALJ->(MsUnlock())
		ALJ->(dbSkip())
	ENDDO
	PcoFinLan("000356")

	cFilterAux := ALI->(dbFilter())
	ALI->( dbClearFilter() )

	ALI->(dbSetOrder(1))
	ALI->(dbSeek(XFilial("ALI")+_cCodCtg))

	WHILE ALI->(!Eof()) .and. xFilial("ALI")+ALI->ALI_CDCNTG == xFilial("ALI")+_cCodCtg
		Reclock("ALI",.F.)
		ALI->(dbDelete())
		ALI->(MsUnlock())

		// Matando o processo de WorkFlow se registro for apagado
		IF (Alltrim(ALI->ALI_PROCWF)<>"")
			WFKillProcess( ALI->ALI_PROCWF )
		ENDIF

		ALI->(dbSkip())
	ENDDO

	ALI->(dbSetFilter({||&(cFilterAux)},cFilterAux))

	RestArea(_cArea)

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} _FVERLOG
Exibe os pedidos gerados.

@type function
@author Carlos Henrique
@since 17/04/2013
@version P12.1.23

@param aDados, Numérico, Conteúdo da mensagem.
@param cTitulo, Numérico, Título da Tela Exibida.

@obs Projeto ELO alterado pela FIEG

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

STATIC FUNCTION _FVERLOG(aDados,cTitulo)

	LOCAL oFont := TFont():New('Courier new',,-14,.T.)
	LOCAL oMemo := NIL
	LOCAL cMemo := ""
	LOCAL oDlg	:= NIL

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	IF !EMPTY(aDados)
		AEVAL(aDados,{|x| cMemo+= x + CRLF })
		Define MsDialog oDlg Title cTitulo From 3, 0 to 340, 417 Pixel
		@ 5, 5 Get oMemo Var cMemo Memo Size 200, 145 Of oDlg Pixel
		oMemo:bRClicked := { || AllwaysTrue() }
		oMemo:oFont     := oFont
		Define SButton From 153, 175 Type 1 Action oDlg:End() Enable Of oDlg Pixel
		Define SButton From 153, 145 Type 2 Action oDlg:End() Enable Of oDlg Pixel
		Activate MsDialog oDlg Center
	ENDIF

RETURN
