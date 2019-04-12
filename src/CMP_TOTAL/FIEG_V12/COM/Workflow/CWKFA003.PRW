#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CWKFA003
Envio de Pedido de Compras para aprovacao.

@type function
@author Thiago Rasmussen
@since 18/11/2010
@version P12.1.23

@param aParam, array, Array recebido do Schedule com os dados da empresa e filial do ambiente de execução.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CWKFA003(aParam)

	//Local lIniciaEmp := .F.
	Local _cPc       := Nil
	Local cCodEmp    := ""
	Local cCodFil    := ""
	Local lContinua  := .F.
	Local nW

	//aParam := {'01','02GO0002'} // U_CWKFA003({'',''})

	If ValType(aParam) == "A" .and. Len(aParam) >= 2
		If ValType(aParam[1]) == "C" .and. ValType(aParam[2]) == "C"
			cCodEmp := aParam[1]
			cCodFil := aParam[2]
			ConOut("CWKFA003 | " + ProcName() + " - " + cCodEmp + " / " + cCodFil + " | ==========================================================")
			IF Len(aParam) == 3 .AND. ValType(aParam[3]) == "C" .AND. aParam[3] > "000000"
				_cPC := aParam[3]
				ConOut("CWKFA003 | " + ProcName() + " - Pedido Especifico: " + _cPC)
			ENDIF
			lContinua := .T.
		Else
			lContinua := .F.
		EndIf
	Else
		lContinua := .F.
	EndIf

	If lContinua
		ConOut("CWKFA003 | " + ProcName() + " - Inicializacao do Ambiente - Workflow PC")

		IF _cPC == Nil
			WfPrepEnv(cCodEmp,cCodFil)

			//--< Log das Personalizações >-----------------------------
			U_LogCustom()

			//--< Processamento da Rotina >-----------------------------
		END

		IF XFILIAL("SC7") <> cCodFil
			ConOut(FunName() + " | " + ProcName() + " - Filial logada diferente da filial passada como parametro: " + XFILIAL("SC7") + " || " + cCodFil)
		ENDIF

		_WFSendPC(cCodFil,_cPC) // Processa a rotina para Envio do Workflow de Aprovacao do PC

		IF _cPC == Nil
			Reset Environment
		ENDIF

		ConOut(FunName() + " | " + ProcName() + " - Finalizacao do Ambiente - Workflow PC")
	Else
		ConOut(FunName() + " | " + ProcName() + " - Erro no recebimento dos parametros!!")
		ConOut("	Tipo esperado: A | Tipo Recebido: " + ValType(aParam))
		ConOut("	Tamanho esperado: 2 | Tamanho Recebido: " + LTrim(Str(Len(aParam))))
		If ValType(aParam) == "A"
			For nW := 1 to Len(aParam)
				ConOut(FunName() + " | " + ProcName() + " - Param["+LTrim(Str(nW))+"] - Tipo Recebido: " + ValType(aParam[nW]))
				ConOut(FunName() + " | " + ProcName() + " - Param["+LTrim(Str(nW))+"] - Tamanho Recebido: " + LTrim(Str(Len(aParam[nW]))))
				If ValType(aParam[nW]) ==  "C"
					ConOut(FunName() + " | " + ProcName() + " - Param["+LTrim(Str(nW))+"] - Conteudo Recebido: " + aParam[nW])
				EndIf
			Next nW
		EndIf
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} _WFSendPC
Envio de Pedido de Compras para aprovacao.

@type function
@author Thiago Rasmussen
@since 18/11/2010
@version P12.1.23

@param _cFil, Caractere, Código da Filial.
@param _cPC, Caractere, Número do Pedido de Compra.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function _WFSendPC(_cFil,_cPC)

	Local _cQrySC7    := ""
	Local _nTotal     := 0
	Local _nTotICM    := 0
	Local _nTotIPI    := 0
	Local _nTotFRE    := 0
	Local _nTotDSP    := 0
	Local _nTotSEG    := 0
	Local _cWfDir     := IIF ( Right(RTrim(GetNewPar("MV_WFDIRWF","workflow\")),1)=="\",;
	GetNewPar("MV_WFDIRWF","workflow\"),;
	GetNewPar("MV_WFDIRWF","workflow\") + "\" )
	Local cHtmlModel  := ""
	Local cWFHTTP     := IIF ( Right(RTrim(GetNewPar("MV_XWFHTTP","http://192.168.1.100:8089/workflow/")),1)=="/",;
	GetNewPar("MV_XWFHTTP","http://192.168.1.100:8089/workflow/"),;
	GetNewPar("MV_XWFHTTP","http://192.168.1.100:8089/workflow/") + "/" )
	Local cWFEMTST    := AllTrim(SuperGetMV("SI_WFEMTST",.F.))
	Local aDirHtml    := {}
	Local cDirHtml    := "html\"
	Local cDirPasta   := "aprovpc\"
	Local cDescProd   := ""
	Local nCntCota	  := 0
	Local i
	Local _MV_XBLQALC := SuperGetMV("MV_XBLQALC", .F.)
	Local _CONTRATO   := .T.

	Private oHTML
	Private cItem,cCod,cDesc,cUM,nQtde,nUprc,nTot,nToler,cUComp,dEnt,cCC,cCCDesc
	Private lProcesso := .f.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Select("TSC7") > 0
		TSC7->(dbCloseArea())
	Endif

	_cQrySC7 := " SELECT DISTINCT C7_FILIAL, C7_NUM, C7_XFILCOM, C7_CONTRA, C7_CONTREV, C7_MEDICAO "
	_cQrySC7 += " FROM "+RetSqlName("SC7")+" "
	_cQrySC7 += " WHERE "
	//_cQrySC7 += " WHERE C7_FILIAL = '"+XFILIAL("SC7")+"' "
	// condicao para identificar se trata-se de envio para primeiro ou proximo nivel
	If _cPC == Nil	// primeiro nivel executado pelo Scheduler Protheus nao passa Num. do PC
		_cQrySC7 += "C7_FILIAL = '" + _cFil + "' AND C7_WFE = 'F' "
	Else			// proximos niveis executados via retorno
		_cQrySC7 += "C7_FILIAL = '" + _cFil + "' AND C7_NUM = '" + _cPC + "' "
	EndIf

	_cQrySC7 += " AND D_E_L_E_T_ = ' ' AND C7_CONAPRO = 'B' "
	_cQrySC7 += " ORDER BY C7_NUM "
	TCQUERY _cQrySC7 NEW ALIAS "TSC7"

	TSC7->(dbGoTop())

	While TSC7->(!Eof())

		lProcesso := .t.

		SCR->(dbSetOrder(1))
		SCR->(dbSeek(XFilial("SCR")+"PC"+TSC7->C7_NUM))

		_aLogApr  := {}

		While SCR->(!Eof()) .and. SCR->CR_FILIAL == XFilial("SCR") .and. Alltrim(SCR->CR_NUM) == Alltrim(TSC7->C7_NUM) .and. SCR->CR_TIPO == "PC"

			_cSituaca := ""
			IF SCR->CR_STATUS == "01"
				_cSituaca := OemToAnsi("Aguardando")
			ELSEIF SCR->CR_STATUS == "02"
				_cSituaca := OemToAnsi("Em Aprovacao")
			ELSEIF SCR->CR_STATUS == "03"
				_cSituaca := "Pedido Aprovado"
			ELSEIF SCR->CR_STATUS == "04"
				_cSituaca := "Pedido Bloqueado"
			ELSEIF SCR->CR_STATUS == "05"
				_cSituaca := OemToAnsi("Nivel Liberado ")
			ENDIF

			Aadd(_aLogApr,{SCR->CR_NIVEL,UsrFullName(SCR->CR_USER),_cSituaca,Dtoc(SCR->CR_DATALIB),SCR->CR_OBS})

			SCR->(dbSkip())
		Enddo

		SCR->(DbGoTop())
		SCR->(dbSetOrder(1))
		SCR->(dbSeek(XFilial("SCR")+"PC"+TSC7->C7_NUM))

		While SCR->(!Eof()) .and. SCR->CR_FILIAL == XFilial("SCR") .and. Alltrim(SCR->CR_NUM) == Alltrim(TSC7->C7_NUM) .and. SCR->CR_TIPO == "PC"

			IF SCR->CR_STATUS <> "02" // nivel 02 indica proxima que recebe e-mail
				SCR->(dbSkip())
				Loop
			ENDIF

			SC7->(dbSetOrder(1))
			SC7->(dbSeek(xFilial("SC7")+Alltrim(TSC7->C7_NUM)))

			SA2->(dbSetOrder(1))
			SA2->(dbSeek(XFilial("SA2")+SC7->(C7_FORNECE+C7_LOJA)))

			SE4->(dbSetOrder(1))
			SE4->(dbSeek(XFilial("SE4")+SC7->C7_COND))

			ConOut(FunName() + " | " + ProcName() + " - Processando: " + SC7->C7_FILIAL + " / " + SC7->C7_NUM + " / " + UsrFullName(SCR->CR_USER))
			//Abre o HTML
			oProcess := TWFProcess():New( "PEDIDO", "Pedido de Compras" )
			oProcess:NewTask( "000001", _cWfDir+"AprovacaoPC.htm" )
			oProcess:cSubject := "Aprovação do Pedido de Compra Nr. " +TSC7->C7_NUM
			oProcess:bReturn  := "U__fWFRetPC()"
			oProcess:UserSiga := SC7->C7_USER
			oProcess:NewVersion(.T.)
			oHTML   := oProcess:oHTML

			oHtml:ValByName( "FILIAL"     , SC7->C7_FILIAL )
			oHtml:ValByName( "NUMPC"      , SC7->C7_NUM )
			oHtml:ValByName( "c7_emissao" , Dtoc(SC7->C7_EMISSAO) )
			oHtml:ValByName( "a2_nome"    , SA2->A2_NOME )
			oHtml:ValByName( "a2_end"     , SA2->A2_END	)
			oHtml:ValByName( "a2_bairro"  , SA2->A2_BAIRRO )
			oHtml:ValByName( "a2_mun"     , SA2->A2_MUN )
			oHtml:ValByName( "a2_est"     , SA2->A2_EST )
			oHtml:ValByName( "c7_filial"  , SC7->C7_FILIAL + " - " + FWFilialName('01', SC7->C7_FILIAL))
			oHtml:ValByName( "c7_user"    , UsrFullName(SC7->C7_USER) )
			oHtml:ValByName( "cc"         , SC7->C7_CC )
			oHtml:ValByName( "desccc"     , Posicione("CTT", 1, xFilial("CTT") + SC7->C7_CC, "CTT_DESC01") )
			oHtml:ValByName( "CAPROV"     , SCR->CR_USER )
			oHtml:ValByName( "APROVADOR"  , UsrFullName(SCR->CR_USER) )
			oHtml:ValByName( "c7_contato" , SC7->C7_CONTATO )
			oHtml:ValByName( "e4_descri"  , SE4->E4_DESCRI )
			oHtml:ValByName( "c7_numpr" , SC7->C7_NUMPR )

			_nSubTot := 0
			_nFrete  := 0
			_nTotal  := 0
			nCntCota := 0

			While !SC7->(Eof()) .and. SC7->C7_FILIAL == XFilial("SC7") .and. SC7->C7_NUM == Alltrim(TSC7->C7_NUM)

				ConOut(FunName() + " | " + ProcName() + " - Processando: " + SC7->C7_FILIAL + " / " + SC7->C7_NUM + " / " + SC7->C7_ITEM)
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(XFilial("SB1")+SC7->C7_PRODUTO))

				cDescProd  := Posicione("SB5",1,xFilial("SB5")+SB1->B1_COD,"B5_CEME")
				DbSelectArea("SB1")

				AAdd( (oHtml:ValByName( "prod.cItem"    )),SC7->C7_ITEM )
				AAdd( (oHtml:ValByName( "prod.cCod"     )),ALLTRIM(SC7->C7_PRODUTO) + ' - ' + ALLTRIM(SB1->B1_DESC) + IIF(EMPTY(SC7->C7_XESPEC), '', ' | ' + ALLTRIM(SC7->C7_XESPEC)))
				AAdd( (oHtml:ValByName( "prod.cUM"      )),SC7->C7_UM )
				AAdd( (oHtml:ValByName( "prod.dEntrega" )),Dtoc(SC7->C7_DATPRF) )
				AAdd( (oHtml:ValByName( "prod.nQuant"   )),TRANSFORM( SC7->C7_QUANT,'@E 999,999,999.99' ) )
				AAdd( (oHtml:ValByName( "prod.nVrUnit"  )),'R$ ' + ALLTRIM(TRANSFORM(SC7->C7_PRECO,'@E 999,999,999.99' ) ) )
				AAdd( (oHtml:ValByName( "prod.nVrTotal" )),'R$ ' + ALLTRIM(TRANSFORM(SC7->C7_TOTAL,'@E 999,999,999.99' ) ) )
				WFSalvaID('SC7','SC7->C7_WFE', .T.)

				_nSubTot += SC7->C7_TOTAL
				_nFrete  += SC7->C7_VALFRE
				_nTotal  += SC7->(C7_TOTAL+C7_VALFRE)

				SC7->(DbSkip())
			EndDo

			oHtml:ValByName( "vlrtotal" , 'R$ ' + ALLTRIM(TRANSFORM( _nSubTot,'@E 999,999,999.99' ) ) )
			oHtml:ValByName( "vlrfrete" , 'R$ ' + ALLTRIM(TRANSFORM( _nFrete ,'@E 999,999,999.99' ) ) )
			oHtml:ValByName( "totgeral" , 'R$ ' + ALLTRIM(TRANSFORM( _nTotal ,'@E 999,999,999.99' ) ) )

			For i := 1 to Len(_aLogApr)
				AAdd( (oHtml:ValByName( "proc.nivel"   )),_aLogApr[i,1] )
				AAdd( (oHtml:ValByName( "proc.cApov"   )),_aLogApr[i,2] )
				AAdd( (oHtml:ValByName( "proc.cSit"    )),_aLogApr[i,3] )
				AAdd( (oHtml:ValByName( "proc.dDtLib"  )),_aLogApr[i,4] )
				AAdd( (oHtml:ValByName( "proc.cObs"    )),_aLogApr[i,5] )
			Next

			//oProcess:cTo := "APROVPC"
			oProcess:cTo := Nil

			// Verifica e cria, se necessario, o diretorio para gravacao do HTML
			aDirHtml   := Directory(_cWfDir+"emp"+cEmpAnt+"\*.*", "D",Nil,.T.)
			If aScan( aDirHtml, {|aDir| aDir[1] == Upper( Iif(Right(cDirHtml,1)=="\", Left(cDirHtml,Len(cDirHtml)-1), cDirHtml) ) } ) == 0
				If MakeDir(_cWfDir+"emp"+cEmpAnt+"\"+cDirHtml)	 == 0
					ConOut(FunName() + " | " + ProcName() + " - Diretorio dos HTML's criado com sucesso: " + _cWfDir + "emp" + cEmpAnt + "\" + cDirHtml)
				Else
					ConOut(FunName() + " | " + ProcName() + " - Erro na criacao do diretorio dos HTML's: " + _cWfDir + "emp" + cEmpAnt + "\" + cDirHtml)
					cDirHtml := "temp\"
				EndIf
			EndIf

			// Verifica e cria, se necessario, a pasta especifica do Workflow para gravacao do HTML
			aDirHtml   := Directory(_cWfDir+"emp"+cEmpAnt+"\"+cDirHtml+"*.*", "D",Nil,.T.)
			If aScan( aDirHtml, {|aDir| aDir[1] == Upper(Iif(Right(cDirPasta,1)=="\", Left(cDirPasta,Len(cDirPasta)-1), cDirPasta) ) } ) == 0
				If MakeDir(_cWfDir+"emp"+cEmpAnt+"\"+cDirHtml+cDirPasta) == 0
					ConOut(FunName() + " | " + ProcName() + " - Diretorio de pasta dos HTML's criado com sucesso: " + _cWfDir + "emp" + cEmpAnt + "\" + cDirHtml+cDirPasta)
				Else
					ConOut(FunName() + " | " + ProcName() + " - Erro na criacao do diretorio dos HTML's: " + _cWfDir + "emp" + cEmpAnt + "\" + cDirHtml+cDirPasta)
					cDirPasta := ""
				EndIf
			EndIf

			cDirHtml2  := "emp"+cEmpAnt+"\" + cDirHtml + cDirPasta
			cMailID    := oProcess:Start(_cWfDir+cDirHtml2,.T.)

			If File(_cWfDir+cDirHtml2+cMailID+".htm")
				ConOut(FunName() + " | " + ProcName() + " - Arquivo HTML copiado com sucesso: " +_cWfDir + cDirHtml2 + cMailID + ".htm")
				// 04/07/2016 - Thiago Rasmussen
				Reclock("SCR",.F.)
				SCR->CR_WF   := "1"     // Enviado
				SCR->CR_WFID := cMailID // Campo CR_WFID deve estar com tamanho 20
				SCR->(MSUnlock())
			Else
				ConOut(FunName() + " | " + ProcName() + " - ATENCAO! Arquivo HTML nao copiado: " + _cWfDir + cDirHtml2 + cMailID + ".htm")
			EndIf

			cHtmlModel := _cWfDir+"LinkPC.htm"
			cAssunto   := "Pedido de Compra - " + TSC7->C7_FILIAL + " / " + TSC7->C7_NUM

			oProcess:NewTask(cAssunto, cHtmlModel)
			ConOut(FunName() + " | " + ProcName() + " - (INICIO|WFLINK)Processo: " + oProcess:fProcessID + " / Task: " + oProcess:fTaskID )
			oProcess:cSubject := cAssunto

			IF !EMPTY(cWFEMTST)
				oProcess:cTo := cWFEMTST
			ELSE
				oProcess:cTo := Alltrim(UsrRetMail(SCR->CR_USER))
			ENDIF

			IF !EMPTY(TSC7->C7_CONTRA) .AND. !EMPTY(TSC7->C7_MEDICAO)
				_CONTRATO := POSICIONE("CN9", 1, IIF(EMPTY(TSC7->C7_XFILCOM), TSC7->C7_FILIAL, TSC7->C7_XFILCOM) + TSC7->C7_CONTRA + TSC7->C7_CONTREV, "CN9_XREGP") == "1"
			ENDIF

			// 10/05/2017 - Thiago Rasmussen - Não enviar email de workflow para o grupo de aprovação de pedidos , o mesmo vai realizar aprovação pelo SE Suíte.
			IF !(_CONTRATO .AND. SCR->CR_USER$(_MV_XBLQALC) .AND. SCR->CR_TOTAL > 4000.00)
				oProcess:ohtml:ValByName("CAPROVADOR",UsrFullName(SCR->CR_USER))
				oProcess:ohtml:ValByName("CNUMPC",TSC7->C7_NUM)

				oProcess:ohtml:ValByName("proc_link",StrTran(cWFHTTP+cDirHtml2+cMailID+".htm","\","/"))
				oProcess:Start()
			ENDIF

			SCR->(dbSkip())
		Enddo
		TSC7->(dbSkip())
	Enddo

	TSC7->(dbCloseArea())

	If !lProcesso
		ConOut(FunName() + " | " + ProcName() + " - Nao Houve Processamento (Envio)")
	Else
		ConOut(FunName() + " | " + ProcName() + " - Processamento (Envio) finalizado")
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} _fWFRetPC
Retorno da Solicitação.

@type function
@author Thiago Rasmussen
@since 18/10/2010
@version P12.1.23

@param oProcess, Objeto, Objeto que representa o processo do Work Flow para execução do retorno da solicitação.
@param aParam, array, Array recebido do Schedule com os dados da empresa e filial do ambiente de execução.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function _fWFRetPC(oProcess,aParam)
	Local lWFlow   := (Valtype(oProcess) == 'O')
	Local cWFEMTST := AllTrim(SuperGetMV("SI_WFEMTST",.F.))
	Local lSegue   := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If lWFlow
		_cFilial  := AllTrim(oProcess:oHtml:RetByName("FILIAL"))
		_cFilial  := IIF(AllTrim(_cFilial)=="",Xfilial("SC7"),_cFilial)
		_cNumPC	  := AllTrim(oProcess:oHtml:RetByName("NUMPC"))
		_cObs     := AllTrim(oProcess:oHtml:RetByName("OBS"))
		_cAprov	  := AllTrim(oProcess:oHtml:RetByName("CAPROV"))
		cOpc	  := AllTrim(oProcess:oHtml:RetByName("OPC"))

		oProcess:Finish() // FINALIZA O PROCESSO
	Else
		_cFilial  := aParam[4]
		_cNumPC	  := Left(aParam[1], TamSX3('C7_NUM')[1])
		_cAprov	  := RetCodUsr()
		cOpc	  := IIF(aParam[3]==2,'APROVAR','REPROVAR')
		_cObs     := aParam[6]
	End

	lLiberou := .F.

	SC7->(dbSetOrder(1))
	SC7->(dbSeek(_cFilial+_cNumPC))

	IF lWFlow
		SCR->(dbSetOrder(2))
		IF SCR->(dbSeek(XFilial("SCR")+"PC"+_cNumPC+Space(TamSx3("CR_NUM")[1]-Len(_cNumPC))+_cAprov))
			IF SCR->CR_STATUS != "02" // SOLICITAÇÃO APROVADA NO SISTEMA
				ConOut(FunName() + " | " + ProcName() + ' - Aprovação efetuada anteriormente')
				_cEMail := AllTrim(UsrRetMail(SCR->CR_USER))
				_cBody  := "Prezado(a) " + UsrFullName(SCR->CR_USER) + Chr(13)+Chr(10)+Chr(13)+Chr(10)
				_cBody  += "Informamos que o Pedido de Compra: " + _cFilial + " / " + _cNumPC + " já tinha sido aprovado/reprovado anteriormente!"
				_cBody  += Chr(13)+Chr(10)+Chr(13)+Chr(10)
				_cBody  += "Observação: " + _cObs

				IF !EMPTY(cWFEMTST)
					_cEMail := cWFEMTST
				ENDIF

				ACSendMail( ,,,,_cEMail,"Pedido Aprovado/Reprovado Anteriormente - " + _cFilial + " / " + _cNumPC,_cBody)
				lSegue := .F. //Return()
			ELSE
				lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,,SC7->C7_APROV,,,,,_cObs},dDataBase,IIF(cOpc == "APROVAR",4,6))
			ENDIF
		ELSE
			ConOut(FunName() + " | " + ProcName() + ' - Alçada não encontrada: ' + XFilial("SCR") + ' / ' + _cNumPC + ' / ' + _cAprov)
			_cEMail := AllTrim(UsrRetMail(_cAprov)) + ';thiagorasmussen@sistemafieg.org.br'
			_cBody  := "Prezado(a) " + UsrFullName(_cAprov) + Chr(13)+Chr(10)+Chr(13)+Chr(10)
			_cBody  += "Informamos que o Pedido de Compra: " + _cFilial + " / " + _cNumPC + " não foi aprovado/reprovado devido a alçada do mesmo não ter sido encontrada!"
			_cBody  += Chr(13)+Chr(10)+Chr(13)+Chr(10)
			_cBody  += "Observação: " + _cObs

			IF !EMPTY(cWFEMTST)
				_cEMail := cWFEMTST
			ENDIF

			ACSendMail( ,,,,_cEMail,"Pedido nao Aprovado/Reprovado - " + _cFilial + " / " + _cNumPC,_cBody)
			lSegue := .F. //Return()
		ENDIF
	ENDIF

	If lSegue

		IF cOpc == "APROVAR"
			_fVerifPC(_cFilial,_cNumPC,_cObs,,_cAprov)
		ELSE
			_cEMail := AllTrim(UsrRetMail( SC7->C7_USER ))
			_cBody  := "Prezado(a) " + UsrFullName(SC7->C7_USER) + Chr(13)+Chr(10)+Chr(13)+Chr(10)
			_cBody  += "Informamos que seu Pedido de Compra: " + _cFilial + " / " + _cNumPC + " foi reprovado por " + UsrFullName(_cAprov) + ", verifique o motivo abaixo e providencie a correção."
			_cBody  += Chr(13)+Chr(10)+Chr(13)+Chr(10)
			_cBody  += "Observação: " + _cObs

			IF !EMPTY(cWFEMTST)
				_cEMail := cWFEMTST
			ENDIF

			ACSendMail( ,,,,_cEMail,"Pedido Reprovado - " + _cFilial + " / " + _cNumPC,_cBody)

			While !SC7->(Eof()) .and. SC7->C7_FILIAL == XFilial("SC7") .and. SC7->C7_NUM == Alltrim(_cNumPC)
				WFSalvaID('SC7','SC7->C7_WFE', .F.)
				SC7->(dbSkip())
			EndDo

		ENDIF

	ENDIF

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³_fVerifPC ºAutor  ³Microsiga           º Data ³  18/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica liberação do pedido                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 11 - PROJETO CNI                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*/================================================================================================================================/*/
/*/{Protheus.doc} _fVerifPC
Verifica liberação do pedido.

@type function
@author Thiago Rasmussen
@since 18/11/2010
@version P12.1.23

@param _cFil, Caractere, Código do Filial.
@param _cNumPC, Caractere, Número do Pedido de Compra.
@param _cObs, Caractere, Observação da Liberação do Pedido de Compra.
@param _cNiv, Caractere, Nível de Aprovação.
@param _cAprov, Caractere, Código do usuário do aprovador.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function _fVerifPC(_cFil,_cNumPC,_cObs,_cNiv,_cAprov)
	Local _cQuery  := ""
	Local _cArqSCR := CriaTrab(nil,.f.)
	Local aArea    := {}
	Local cWFEMTST := AllTrim(SuperGetMV("SI_WFEMTST",.F.))

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// verifica se o pedido foi totalmente liberado
	_cQuery := "SELECT * FROM "+RetSqlName("SCR")+" "
	_cQuery += "WHERE D_E_L_E_T_ = ' ' AND CR_FILIAL = '"+XFilial("SCR")+"' AND CR_NUM = '"+_cNumPC+"' AND CR_STATUS NOT IN ('03','05') AND CR_TIPO = 'PC' "
	_cQuery := ChangeQuery(_cQuery)

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqSCR,.t.,.t.)

	IF (_cArqSCR)->(Eof())

		SC7->(dbSetOrder(1))
		SC7->(dbSeek(_cFil+_cNumPC))

		// envia email ao solicitante
		_cEMail := AllTrim(UsrRetMail( SC7->C7_USER ))
		_cBody  := "Prezado(a) " + UsrFullName(SC7->C7_USER) + Chr(13)+Chr(10)+Chr(13)+Chr(10)
		_cBody  += "Informamos que seu Pedido de Compra: " + _cFil + " / " + _cNumPC + " foi aprovado por " + UsrFullName(_cAprov) + "."
		_cBody  += Chr(13)+Chr(10)+Chr(13)+Chr(10)
		_cBody  += "Observação: " + _cObs

		IF !EMPTY(cWFEMTST)
			_cEMail := cWFEMTST
		ENDIF

		ACSendMail( ,,,,_cEMail,"Pedido Aprovado - " + _cFil + " / " + _cNumPC,_cBody)

		While SC7->(!Eof()) .and. SC7->(C7_FILIAL+C7_NUM) == _cFil+_cNumPC
			RecLock("SC7",.F.)
			SC7->C7_CONAPRO	:= "L"
			SC7->(msUnlock())

			aArea := SC7->(GetArea())
			aComa080 := {SC7->C7_FORNECE,SC7->C7_LOJA}
			COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COI",{},"COI_DTHLIB","COI_ULIB",/*lEstorno*/,UsrRetName(_cAprov),"COI_DOCLIB",SC7->C7_NUM) //Caio.Santos - FSW - 06/02/2012 - Geracao de log aprovacao PC via WF
			COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COK",aComa080,"COK_DTHLIB","COK_ULIB",/*lEstorno*/,UsrRetName(_cAprov),"COK_DOCLIB",SC7->C7_NUM)
			RestArea(aArea)

			SC7->(dbSkip())
		EndDo
	ELSE
		_WFSendPC(_cFil,_cNumPC) // envia e-mail para o proximo aprovador
	ENDIF

Return