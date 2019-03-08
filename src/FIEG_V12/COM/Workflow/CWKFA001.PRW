#Include "Protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CWKFA001
Envio de Solicitação de Compras para aprovação  .

@type function
@author Thiago Rasmussen
@since 18/11/2010
@version P12.1.23

@param _aParam, Array, Array recebido do Schedule com os dados da empresa e filial do ambinete de execução.
@param _cFil, Caractere, Codigo da Filial.
@param _cSC, Caractere, Número de Solictação de Compra.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CWKFA001(_aParam,_cFil,_cSC)
	Local lIniciaEmp := .F.
	Local cCodEmp    := ""
	Local cCodFil    := ""


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If ValType(_aParam) == "A" .and. Len(_aParam) == 2
		cCodEmp := _aParam[1]
		cCodFil := _aParam[2]
	EndIf

	ConOut("CWKFA001 | " + ProcName() + " -  Parâmetros recebidos: " + cCodEmp + " / " + cCodFil + " / " + _cFil + " / " + _cSC)

	IF _aParam # nil
		ConOut(FunName() + " | " + ProcName() + " - Inicialização do ambiente - Workflow SC: " + cCodEmp + " / " + cCodFil)
		WfPrepEnv(cCodEmp,cCodFil)
		lIniciaEmp := .T.
	EndIf

	U__WFSendSC(_cFil,_cSC) // Envia email para aprovacao

	If lIniciaEmp
		Reset Environment
		ConOut(FunName() + " | " + ProcName() + " - Finalização do ambiente - Workflow SC: " + cCodEmp + " / " + cCodFil)
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} _WFSendSC
Envio dos solicitações para aprovação.

@type function
@author Thiago Rasmussen
@since 18/11/2010
@version P12.1.23

@param _cFil, Caractere, Codigo da Filial.
@param _cSC, Caractere, Número de Solictação de Compra.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function _WFSendSC(_cFil,_cSC)
	Local _nTotal    := 0
	Local _cWfDir    := Alltrim(GetNewPar("MV_WFDIRWF","\workflow") )
	Local i		     := 0
	Local cAlias     := GetNextAlias()
	Local cHtmlModel := ""
	Local cDirHtml   := ""
	Local cWFHTTP    := GetNewPar("MV_XWFHTTP","http://192.168.1.100:8089/workflow")
	Local cWFEMTST   := AllTrim(SuperGetMV("SI_WFEMTST",.F.))
	Local cDescProd  := ""
	Local _aAreaSC1  := SC1->(GetArea())
	Local _aAreaSCR  := SCR->(GetArea())
	Local nTotalGer  := 0
	Private oHTML
	Private cItem,cCod,cDesc,cUM,nQtde,nUprc,nTot,nToler,cUComp,dEnt,cCC,cCCDesc
	Private lProcesso := .f.


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	ConOut(FunName() + " | " + ProcName() + " - Envio das solicitações para aprovação. Parâmetros: " + _cFil + " / " + _cSC)

	dbCloseArea()

	If Select(cAlias) > 0
		TSC1->(dbCloseArea())
	Endif

	_cQrySC1:= " SELECT DISTINCT C1_FILIAL,C1_NUM "
	_cQrySC1+= " FROM "+RetSqlName("SC1")+" "
	_cQrySC1+= " WHERE C1_FILIAL = '"+XFILIAL("SC1")+"' "
	// condicao para identificar se trata-se de envio para primeiro ou proximo nivel
	IF _cFil == nil // primeiro nivel
		_cQrySC1+= "AND C1_WFE = 'F' "
	ELSE // chamada da funcao para envio para o proximo nivel de aprovacao
		_cQrySC1+= "AND C1_FILIAL = '"+_cFil+"' AND C1_NUM = '"+_cSC+"' "
	ENDIF
	_cQrySC1+= " AND D_E_L_E_T_ = ' ' AND C1_APROV IN ('B','R') "
	_cQrySC1+= " ORDER BY C1_NUM "

	_cQrySC1 := ChangeQuery(_cQrySC1)

	TCQUERY _cQrySC1 NEW ALIAS &(cAlias) //VIA "TOPCONN"

	(cAlias)->(dbGoTop())

	While (cAlias)->(!Eof())

		lProcesso := .t.

		SCR->(dbSetOrder(1))
		SCR->(dbSeek(XFilial("SCR")+"SC"+(cAlias)->C1_NUM))

		_aLogApr  := {}

		While SCR->(!Eof()) .and. SCR->CR_FILIAL == XFilial("SCR") .and. Alltrim(SCR->CR_NUM) == Alltrim((cAlias)->C1_NUM) .and. SCR->CR_TIPO == "SC"

			_cSituaca := ""
			IF SCR->CR_STATUS == "01"
				_cSituaca := OemToAnsi("Aguardando")
			ELSEIF SCR->CR_STATUS == "02"
				_cSituaca := OemToAnsi("Em Aprovacao")
			ELSEIF SCR->CR_STATUS == "03"
				_cSituaca := "Solicitação Aprovada"
			ELSEIF SCR->CR_STATUS == "04"
				_cSituaca := "Solicitação Bloqueada"
			ELSEIF SCR->CR_STATUS == "05"
				_cSituaca := OemToAnsi("Nivel Liberado ")
			ENDIF

			Aadd(_aLogApr,{SCR->CR_NIVEL,UsrFullName(SCR->CR_USER),_cSituaca,Dtoc(SCR->CR_DATALIB),SCR->CR_OBS})

			SCR->(dbSkip())
		Enddo

		SCR->(dbSeek(XFilial("SCR")+"SC"+(cAlias)->C1_NUM))

		While SCR->(!Eof()) .and. SCR->CR_FILIAL == XFilial("SCR") .and. Alltrim(SCR->CR_NUM) == Alltrim((cAlias)->C1_NUM) .and. SCR->CR_TIPO == "SC"

			IF SCR->CR_STATUS <> "02" // nivel 02 indica proxima que recebe e-mail
				SCR->(dbSkip())
				Loop
			ENDIF

			nTotalGer:= 0

			SC1->(dbSetOrder(1))
			SC1->(dbSeek(xFilial("SC1")+Alltrim((cAlias)->C1_NUM)))

			If Right(RTrim(_cWfDir),1) # "\"
				_cWfDir := RTrim(_cWfDir) + "\"
			EndIf

			ConOut(FunName() + " | " + ProcName() + " - Processando solicitação: " + SC1->C1_FILIAL + " / " + SC1->C1_NUM)
			//Abre o HTML
			oProcess := TWFProcess():New( "SOLICIT", "Solicitação de Compras" )
			oProcess:NewTask( "000001", _cWfDir+"AprovacaoSC.htm" )
			oProcess:cSubject := "Aprovação da Solicitação de Compra: " +(cAlias)->C1_NUM
			oProcess:bReturn  := "U__fWFRetSC()"
			oProcess:UserSiga := SC1->C1_USER //- Alterado FSW
			oProcess:NewVersion(.T.)
			oHTML   := oProcess:oHTML

			oHtml:ValByName( "FILIAL"    	, SC1->C1_FILIAL )
			//oHtml:ValByName( "DESCFIL"   	, FWFilialName('01', SC1->C1_FILIAL))
			oHtml:ValByName( "NUMSC"     	, SC1->C1_NUM )
			oHtml:ValByName( "CAPROV"    	, SCR->CR_USER )
			oHtml:ValByName( "APROVADOR" 	, UsrFullName(SCR->CR_USER)) //UsrRetname(SCR->CR_USER)  ) - Alterado FSW
			//oHtml:ValByName( "SOLICIT"		, SC1->C1_SOLICIT )
			oHtml:ValByName( "NOMSOLICIT"	, GET_NAME_USER(SC1->C1_SOLICIT))
			oHtml:ValByName( "C1_EMISSAO"	, Dtoc(SC1->C1_EMISSAO) )
			oHtml:ValByName( "C1_ITEMCTA"	, SC1->C1_ITEMCTA )
			oHtml:ValByName( "ITEMCTA_DESC"	, POSICIONE("CTD",1,XFILIAL("CTD")+SC1->C1_ITEMCTA,"CTD_DESC01") )
			oHtml:ValByName( "CC"        	, SC1->C1_CC )
			oHtml:ValByName( "DESCCC"    	, Posicione("CTT", 1, xFilial("CTT") + SC1->C1_CC, "CTT_DESC01") )
			oHtml:ValByName( "C1_JUSTIFI"	, SC1->C1_XJUSTIF )

			While !SC1->(Eof()) .and. SC1->C1_FILIAL == XFilial("SC1") .and. SC1->C1_NUM == Alltrim((cAlias)->C1_NUM)

				ConOut(FunName() + " | " + ProcName() + " - Processando Item da solicitação: " + SC1->C1_FILIAL + " / " + SC1->C1_NUM + " / " + SC1->C1_ITEM)
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(XFilial("SB1")+SC1->C1_PRODUTO))

				cDescProd := Posicione("SB5",1,xFilial("SB5")+SB1->B1_COD,"B5_CEME")
				DbSelectArea("SB1")

				AAdd( (oHtml:ValByName( "prod.cItem"    )),SC1->C1_ITEM )
				AAdd( (oHtml:ValByName( "prod.cCod"     )),SC1->C1_PRODUTO + ' - ' + STRTRAN(IIF(Empty(cDescProd),SB1->B1_DESC,cDescProd) + IIF(Empty(SC1->C1_XESPEC),'',' | ' + SC1->C1_XESPEC) + IIF(ALLTRIM(SCR->CR_USER) == '001382' .AND. ALLTRIM(SB1->B1_CODISS) != '', '<font color=red> || CÓDIGO ISS: ' + SB1->B1_CODISS + '</font>',''),'"','') )
				AAdd( (oHtml:ValByName( "prod.nQuant"   )),TRANSFORM( SC1->C1_QUANT,'@E 999,999,999.99' ) )
				AAdd( (oHtml:ValByName( "prod.nVrUnit"  )),'R$ ' + TRANSFORM( SC1->C1_VUNIT,'@E 999,999,999.99' ) )
				AAdd( (oHtml:ValByName( "prod.nVrTotal" )),'R$ ' + TRANSFORM( SC1->(C1_QUANT*C1_VUNIT),'@E 999,999,999.99' ) )
				AAdd( (oHtml:ValByName( "prod.cConta"   )),SC1->C1_CONTA + ' - ' + Posicione("CT1", 1, xFilial("CT1") + SC1->C1_CONTA, "CT1_DESC01") )
				WFSalvaID('SC1','SC1->C1_WFE', .T.)

				nTotalGer+= SC1->(C1_QUANT*C1_VUNIT)

				SC1->(DbSkip())
			Enddo

			oHtml:ValByName( "totgeral" , 'R$ ' + TRANSFORM( nTotalGer ,'@E 999,999,999.99' ) )

			For i := 1 to Len(_aLogApr)
				AAdd( (oHtml:ValByName( "proc.nivel"   )),_aLogApr[i,1] )
				AAdd( (oHtml:ValByName( "proc.cApov"   )),_aLogApr[i,2] )
				AAdd( (oHtml:ValByName( "proc.cSit"    )),_aLogApr[i,3] )
				AAdd( (oHtml:ValByName( "proc.dDtLib"  )),_aLogApr[i,4] )
				AAdd( (oHtml:ValByName( "proc.cObs"    )),_aLogApr[i,5] )
			Next

			//oProcess:cTo := UsrRetMail(SCR->CR_USER) //"APROVSC"
			oProcess:cTo := Nil
			cDirHtml   := "emp"+cEmpAnt+"\html\"
			cMailID    := oProcess:Start(_cWfDir+cDirHtml)

			If File(_cWfDir+cDirHtml+cMailID+".htm")
				ConOut(FunName() + " | " + ProcName() + " - Arquivo HTML copiado com sucesso: "+_cWfDir+cDirHtml+cMailID+".htm" )
				Reclock("SCR",.F.)
				SCR->CR_WF		:= "1"  //--Enviado
				SCR->CR_WFID	:= cMailID   //--Campo CR_WFID deve estar com tamanho 20
				SCR->(MSUnlock())
			Else
				ConOut(FunName() + " | " + ProcName() + " - ATENCAO! Arquivo HTML não copiado: "+_cWfDir+cDirHtml+cMailID+".htm")
			EndIf

			cHtmlModel := _cWfDir+"LinkSC.htm"
			cAssunto   := "Solicitação de Compra - " + (cAlias)->C1_FILIAL + " / " + (cAlias)->C1_NUM

			oProcess:NewTask(cAssunto, cHtmlModel)
			ConOut(FunName() + " | " + ProcName() + " - (INICIO|WFLINK)Processo: " + oProcess:fProcessID + " / Task: " + oProcess:fTaskID )
			oProcess:cSubject := cAssunto

			IF !EMPTY(cWFEMTST)
				oProcess:cTo := cWFEMTST
			ELSE
				oProcess:cTo := Alltrim(UsrRetMail( SCR->CR_USER ))
			ENDIF

			oProcess:ohtml:ValByName("CAPROVADOR",UsrFullName(SCR->CR_USER))
			oProcess:ohtml:ValByName("CFILIAL",(cAlias)->C1_FILIAL)
			oProcess:ohtml:ValByName("CSOLICIT",(cAlias)->C1_NUM)

			If Right(RTrim(cWFHTTP),1) # "/"
				cWFHTTP := RTrim(cWFHTTP) + "/"
			EndIf

			oProcess:ohtml:ValByName("proc_link",StrTran(cWFHTTP+cDirHtml+cMailID+".htm","\","/"))
			oProcess:Start()

			_nTotal := 0 // zera variavel p/ próximos pedidos

			SCR->(dbSkip())
		Enddo
		(cAlias)->(dbSkip())
	Enddo

	(cAlias)->(dbCloseArea())

	If !lProcesso
		ConOut(FunName() + " | " + ProcName() + " - Não houve processamento (Envio).")
	Else
		ConOut(FunName() + " | " + ProcName() + " - Processamento (Envio) finalizado.")
	EndIf

	RestArea(_aAreaSC1)
	RestArea(_aAreaSCR)
Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} _fWFRetSC
Retorno da Solicitação.

@type function
@author Thiago Rasmussen
@since 18/11/2010
@version P12.1.23

@param oProcess, Objeto, Objeto que representa o processo do Work Flow para execução do retorno da solicitação

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function _fWFRetSC(oProcess)
	Local cIDWF := oProcess:fProcessid
	Local lLiberou  := .F.
	Local nRec		:= 0
	Local lAwaitApp := .F.
	Local aAreaSC1  := SC1->(GetArea())
	Local aAreaSCR  := SCR->(GetArea())
	Local cWFEMTST  := AllTrim(SuperGetMV("SI_WFEMTST",.F.))
	Local lSegue    := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cFilial  := AllTrim(oProcess:oHtml:RetByName("FILIAL"))
	_cFilial  := IIF(AllTrim(_cFilial)=="",Xfilial("SC1"),_cFilial)
	_cNumSC	  := AllTrim(oProcess:oHtml:RetByName("NUMSC"))
	_cObs     := AllTrim(oProcess:oHtml:RetByName("OBS"))
	_cAprov	  := AllTrim(oProcess:oHtml:RetByName("CAPROV"))
	cOpc	  := AllTrim(oProcess:oHtml:RetByName("OPC"))
	_ID_USER  := SUBSTR(AllTrim(oProcess:oHtml:RetByName("WFIDUSER")),1,6)

	_cFilial := SUBSTR(AllTrim(_cFilial),1,8)

	oProcess:Finish() // FINALIZA O PROCESSO

	SC1->(dbSetOrder(1))
	SC1->(dbSeek(_cFilial+_cNumSC))

	SCR->(dbSetOrder(2))
	IF SCR->(dbSeek(XFilial("SCR")+"SC"+_cNumSC+SPACE(TamSx3("CR_NUM")[1]-LEN(_cNumSC))+_cAprov)) .AND. SubString(SCR->CR_WFID,1,8)==SubString(cIDWF,1,8)

		IF Empty(SCR->CR_DATALIB) .And. !(SCR->CR_STATUS $ "03#04#05")

			IF !EMPTY(_ID_USER) .AND. _ID_USER <> SCR->CR_USER .AND. POSICIONE("SAK",1,XFILIAL("SAK")+SCR->CR_APROV,"AK_XDETALH") == 'SC - ALÇADA TÉCNICA GECON'
				_cAprov := _ID_USER

				IF POSICIONE("SAK",2,XFILIAL("SAK")+_ID_USER,"AK_XDETALH") <> 'APROVADOR SC - GECON'
					ConOut(FunName() + " | " + ProcName() + " - Alçada não encontrada!!! Processo WF: " + cIDWF + " Solicitação: " + SCR->CR_FILIAL + " / " + _cNumSC + " / " + UsrFullName(ALLTRIM(_ID_USER)) + " / APROVADOR SC - GECON")

					SC1->(RestArea(aAreaSC1))
					SCR->(RestArea(aAreaSCR))

					lSegue := .F. //Return()

				ENDIF

				If lSegue

					Reclock("SCR",.F.)
					SCR->CR_USER  := _ID_USER
					SCR->CR_APROV := POSICIONE("SAK",2,XFILIAL("SAK")+_ID_USER,"AK_COD")
					SCR->CR_WF    := "2" //	Status 2 - respondido
					SCR->(MSUnlock())

					ConOut(FunName() + " | " + ProcName() + " - Alçada encontrada: " + ALLTRIM(SCR->CR_FILIAL) + " / " + ALLTRIM(SCR->CR_TIPO) + " / " + ALLTRIM(SCR->CR_NUM) + " / " + UsrFullName(ALLTRIM(SCR->CR_USER)) + " / SC - ALÇADA TÉCNICA GECON")

				End If
			ELSE
				Reclock("SCR",.F.)
				SCR->CR_WF := "2"	//	Status 2 - respondido
				SCR->(MSUnlock())

				ConOut(FunName() + " | " + ProcName() + " - Alçada encontrada: " + ALLTRIM(SCR->CR_FILIAL) + " / " + ALLTRIM(SCR->CR_TIPO) + " / " + ALLTRIM(SCR->CR_NUM) + " / " + UsrFullName(ALLTRIM(SCR->CR_USER)))
			ENDIF

			If lSegue

				nRec := SCR->(RecNo())

				IF !(lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV,SCR->CR_USER,SC1->C1_XGRPAPR,,,,,;
				_cObs},dDataBase,IIF(cOpc == "APROVAR",4,6)))

					// Reposiciona e verifica se ja esta totalmente liberado.
					SCR->(dbSetOrder(1))
					WHILE !SCR->(Eof()) .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == xFilial("SCR")+"SC"+_cNumSC+SPACE(TamSx3("CR_NUM")[1]-LEN(_cNumSC))
						IF SCR->CR_STATUS != "03" .And. SCR->CR_STATUS != "05" .And. SCR->CR_STATUS != "04"
							lAwaitApp := .T.
						ENDIF
						SCR->(dbSkip())
					ENDDO
					SCR->(dbSetOrder(2))
					SCR->(dbGoto(nRec))
					IF lAwaitApp
						ConOut(FunName() + " | " + ProcName() + " - Solicitação aguardando próxima aprovação: " + ALLTRIM(_cFilial) + " / " + ALLTRIM(_cNumSC))
					ELSE
						ConOut(FunName() + " | " + ProcName() + " - Solicitação não liberada:: " + ALLTRIM(_cFilial) + " / " + ALLTRIM(_cNumSC))
					ENDIF
				ENDIF

				IF cOpc == "APROVAR" .and. (lLiberou .or. lAwaitApp)
					_fVerifSC(_cFilial,_cNumSC,_cObs,,_cAprov)
				ELSEIF cOpc == "REPROVAR"
					Reclock("SCR",.F.)
					SCR->CR_WF := "2"
					SCR->(MSUnlock())

					Reclock("SC1",.F.)
					SC1->C1_APROV := "R"
					MSUnlock()

					ConOut(FunName() + " | " + ProcName() + " - Ação não realizada : Opção="+cOpc+IIF(lLiberou,' Liberou ',' Nao Liberou ')+IIF(lAwaitApp,' lAwaitApp ',' Nao lAwaitApp '))

					SC1->(dbSetOrder(1))
					SC1->(dbSeek(_cFilial+_cNumSC))

					_cEMail := Alltrim(UsrRetMail(SC1->C1_USER))
					_cBody  := "Prezado(a) " + Alltrim(UsrFullName(SC1->C1_USER)) + Chr(13)+Chr(10)+Chr(13)+Chr(10)
					_cBody  += "Informamos que sua Solicitação de Compra " + SC1->C1_FILIAL + " / " + SC1->C1_NUM + " foi reprovada por " + UsrFullName(_cAprov) + ", verifique o motivo abaixo e providencie a correção."
					_cBody  += Chr(13)+Chr(10)+Chr(13)+Chr(10)
					_cBody  += "Observação: "+_cObs

					IF !EMPTY(cWFEMTST)
						_cEMail := cWFEMTST
					ENDIF

					ACSendMail(,,,,_cEMail,"Solicitacao Reprovada - " + SC1->C1_FILIAL + " / " + SC1->C1_NUM,_cBody)
				ENDIF

			End If

		ELSE
			ConOut(FunName() + " | " + ProcName() + " - Aprovação/Reprovação da solicitação: " + SC1->C1_FILIAL + " / " + _cNumSC + " já efetuada anteriormente. Processo não será executado!")
		ENDIF
	ELSE
		ConOut(FunName() + " | " + ProcName() + " - Alçada não encontrada!!! Processo WF: " + cIDWF + " Solicitação: " + SC1->C1_FILIAL + " / " + _cNumSC)
	ENDIF

	SC1->(RestArea(aAreaSC1))
	SCR->(RestArea(aAreaSCR))

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} _fVerifSC
Verifica liberação da solicitação.

@type function
@author Thiago Rasmussen
@since 18/11/2010
@version P12.1.23

@param _cFil, Caractere, Código da Filial.
@param _cSolicit, Caractere, Número da Solicitação de Compra.
@param _cObs, Caractere, Observação da Liberação da Solicitação de Compra.
@param _cNiv, Caractere, Nível de aprovação.
@param _cAprov, Caractere, Código do usuáriodo aprovador.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function _fVerifSC(_cFil,_cSolicit,_cObs,_cNiv,_cAprov)
	Local _cQuery   := ""
	Local _cArqSCR  := CriaTrab(nil,.f.)
	Local cParam    := GetMv("SI_XMED", .F.)
	Local _cNome    := ""
	Local cTipo	    := "SC"
	Local nOpc      := 2
	Local _lLancSC	:= PcoExistLc("000051","02","1") // Verifica se existe lançamento ativo
	Local _lBloqSC	:= PcoExistLc("000051","02","2") // Verifica se existe bloqueio ativo
	Local _lGeraBlq := .f.
	Local aAreaSC1  := SC1->(GetArea())
	Local cWFEMTST  := AllTrim(SuperGetMV("SI_WFEMTST",.F.))

	Default _cAprov := "" //Caio.Santos - FSW - 10/02/2012 - Correcao na gravacao usuario workflow


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cNome := UsrRetname(_cAprov)

	// verifica se a solicitação foi totalmente liberada
	_cQuery := "SELECT * FROM "+RetSqlName("SCR")+" "
	_cQuery += "WHERE D_E_L_E_T_ = ' ' AND CR_FILIAL = '"+XFilial("SCR")+"' AND CR_NUM = '"+_cSolicit+"' AND CR_STATUS NOT IN ('03','05') AND CR_TIPO = 'SC' "
	_cQuery := ChangeQuery(_cQuery)

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqSCR,.t.,.t.)

	IF (_cArqSCR)->(Eof())

		SC1->(dbSetOrder(1))
		SC1->(dbSeek(_cFil+_cSolicit))

		// FSW - Alteração para o Gap087 - CNI
		IF _lLancSC .and. _lBloqSC .and. U__fBloqSC(.f.,SC1->C1_NUM)
			_lGeraBlq := .t.

			_cEMail := Alltrim(UsrRetMail(SC1->C1_USER))
			_cBody  := "Prezado(a) " + Alltrim(UsrFullName(SC1->C1_USER)) + Chr(13)+Chr(10)+Chr(13)+Chr(10)
			_cBody  += "Informamos que sua Solicitação de Compra " + SC1->C1_FILIAL + " / " + SC1->C1_NUM + " foi aprovada por " + UsrFullName(_cAprov) + " e encontra-se bloqueada por orçamento, solicite contingência."
			_cBody  += Chr(13)+Chr(10)+Chr(13)+Chr(10)
			_cBody  += "Observação: "+_cObs

			IF !EMPTY(cWFEMTST)
				_cEMail := cWFEMTST
			ENDIF

			ACSendMail(,,,,_cEMail,"Solicitacao Bloqueada Por Orcamento - " + SC1->C1_FILIAL + " / " + SC1->C1_NUM,_cBody)
		ELSE
			_cEMail := Alltrim(UsrRetMail(SC1->C1_USER))
			_cBody  := "Prezado(a) " + Alltrim(UsrFullName(SC1->C1_USER)) + Chr(13)+Chr(10)+Chr(13)+Chr(10)
			_cBody  += "Informamos que sua Solicitação de Compra " + SC1->C1_FILIAL + " / " + SC1->C1_NUM + " foi aprovada por " + UsrFullName(_cAprov) + " e encaminhada para a Gerência de Suprimentos."
			_cBody  += Chr(13)+Chr(10)+Chr(13)+Chr(10)
			_cBody  += "Observação: "+_cObs

			IF !EMPTY(cWFEMTST)
				_cEMail := cWFEMTST
			ENDIF

			ACSendMail(,,,,_cEMail,"Solicitacao Aprovada - " + SC1->C1_FILIAL + " / " + SC1->C1_NUM,_cBody)
		ENDIF

		While SC1->(!Eof()) .and. SC1->(C1_FILIAL+C1_NUM) == _cFil+_cSolicit

			//Caio.Santos - 11/01/13 - Req.72
			RSTSCLOG("APR",1,_cNome)

			// Atualiza status da SC
			RecLock("SC1",.F.)
			SC1->C1_APROV	:= IIF(_lLancSC .and. _lGeraBlq,"O","L")
			SC1->(msUnlock())

			// Inclui os lançamentos realizados
			IF _lLancSC .and. !_lGeraBlq
				PcoIniLan('000051')
				PcoDetLan('000051','02','MATA110')
				PcoFinLan('000051')
			ENDIF

			SC1->(dbSkip())

		EndDo

		// FSW - Alteração para o Gap097 - CNI
		// Se parametro SI_XMED for igual a 1 deve fazer a medição na liberação da solicitação de compras
		If (cParam == "1") .and. !_lGeraBlq
			U_CNI109AL(_cSolicit, cTipo, nOpc,_cAprov)
		EndIf
	ELSE
		U__WFSendSC(_cFil,_cSolicit) // envia e-mail para o proximo aprovador
	ENDIF

	SC1->(RestArea(aAreaSC1))

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} GET_NAME_USER
Busca o nome de um usuário com o código recebido por parâmetro.

@type function
@author Thiago Rasmussen
@since
@version P12.1.23

@param LoginUsuario, Caractere, Código do usuário.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Nome do Usuário.
/*/
/*/================================================================================================================================/*/

Static Function GET_NAME_USER(LoginUsuario)

	Local cNomeUsuario := ''
	Local aUsuario     := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	PswOrder(2)
	IF PswSeek(LoginUsuario)
		aUsuario     := PswRet()
		cNomeUsuario := PswRet(1)[1][4]
	ENDIF

Return(cNomeUsuario)
