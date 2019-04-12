#include "TbiConn.ch"
#include "TopConn.ch"
#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIESTA03
Arquivo de Controle de Processos do Workflow da Solicitação ao Armazém.

@type function
@author Thiago Rasmussen
@since 01/02/2012
@version P12.1.23

@param aParam, Array, Array com os parâmetros de processamento.
@param oProcess, Objeto, Objeto que representa o processo de WorkFlow.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIESTA03(aParam, oProcess)

	Local _cQuery, _cWfId
	Local _lProcesso	:= .F.
	Local cAliasTRB 	:= GetNextAlias()
	Local cFuncName		:= "SIESTA03"
	Local lContinua		:= .F.
	Local lSegue        := .T.

	Private _cValor		:= ""
	Private _cNomGrp	:= ""
	Private _cCodGrp	:= ""
	Private _nOpc, _cEmpresa, _cFilial

	If ValType(aParam) == "A" .and. Len(aParam) >= 3
		If ValType(aParam[1]) =="N" .and. ValType(aParam[2]) =="C" .and. ValType(aParam[3]) =="C"
			_nOpc	  := aParam[1]
			cCodEmp   := aParam[2]
			cCodFil   := aParam[3]
			U_Console("Parametros Recebidos => Empresa/Filial: "+cCodEmp+"/"+cCodFil,cFuncName)
			lContinua := .T.
		Else
			lContinua := .F.
		EndIf
	Else
		lContinua := .F.
	EndIf

	If lContinua
		U_Console("Inicializacao do ambiente - Workflow SA Empresa/Filial: "+cCodEmp+"/"+cCodFil,cFuncName)
		WfPrepEnv(cCodEmp,cCodFil)

		//--< Log das Personalizações >-----------------------------
		U_LogCustom()

		//--< Processamento da Rotina >-----------------------------

		//_WFSendSA(cCodFil,_cPC) // Processa a rotina para Envio do Workflow de Aprovacao do PC
		//Reset Environment
		U_Console("Finalizacao do ambiente - Workflow PC Empresa/Filial: "+cCodEmp+"/"+cCodFil,cFuncName)
	Else
		U_Console("ERRO no recebimento dos Paramentros (Empresa/Filial)!!",cFuncName)
		U_Console("     Tipo esperado: A |    Tipo Recebido: " + ValType(aParam),cFuncName)
		U_Console("  Tamanho esperado: 3 | Tamanho Recebido: " + LTrim(Str(Len(aParam))),cFuncName)
		If ValType(aParam) == "A"
			For nW := 1 to Len(aParam)
				U_Console("  Param["+LTrim(Str(nW))+"] -     Tipo Recebido: " + ValType(aParam[nW]),cFuncName)
				U_Console("  Param["+LTrim(Str(nW))+"] -  Tamanho Recebido: " + LTrim(Str(Len(aParam[nW]))),cFuncName)
				If ValType(aParam[nW]) ==  "C"
					U_Console("  Param["+LTrim(Str(nW))+"] - Conteudo Recebido: " + aParam[nW],cFuncName)
				ElseIf ValType(aParam[nW]) ==  "N"
					U_Console("  Param["+LTrim(Str(nW))+"] - Conteudo Recebido: " + LTrim(Str(aParam[nW])),cFuncName)
				EndIf
			Next nW
		EndIf
	EndIf

	If !lContinua
		U_Console("Processamento abortado!",cFuncName)
		lSegue := .F.
	EndIf

	If lSegue

		If _nOpc == 1		// Envio para aprovacao

			U_Console("1 - Prepara as SAs a serem enviadas para aprovacao",cFuncName)

			dbSelectArea("SB1")
			dbSelectArea("SCP")
			dbSelectArea("SCR")
			dbSelectArea("SZQ")

			_cQuery	:= "SELECT CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL, CR_USER, CR_APROV, CR_WF, CR_DATALIB, R_E_C_N_O_ AS REC"
			_cQuery	+= " FROM " + RETSQLNAME('SCR') + " SCR"
			_cQuery	+= " WHERE CR_FILIAL  = '" + XFilial("SCR") + "'"
			_cQuery	+= " AND CR_WF = ''"
			_cQuery	+= " AND CR_STATUS = '02'"
			_cQuery	+= " AND CR_TIPO = 'SA'"
			_cQuery	+= " AND SCR.D_E_L_E_T_ <> '*'"
			_cQuery	+= " ORDER BY CR_FILIAL, CR_NUM, CR_NIVEL, CR_USER"
			_cQuery := ChangeQuery(_cQuery)
			If Select(cAliasTRB) > 0
				DbSelectArea(cAliasTRB)
				(cAliasTRB)->(DbCloseArea())
			Endif
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTRB,.T.,.F.)
			DbSelectArea(cAliasTRB)
			(cAliasTRB)->(DbGoTop())

			While (cAliasTRB)->(!Eof())
				_lProcesso	:= .T.
				DbSelectarea("SCR")
				SCR->(DbSetOrder(2))
				SCR->(DbSeek((cAliasTRB)->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER)))
				DbSelectArea("SCR")
				_cValor		:= Transform(SCR->CR_TOTAL,'@E 999,999,999.99')
				_cCodGrp	:= xRetGrp(Substr(SCR->CR_NUM,1,6))
				_cNomGrp	:= Posicione("SAL", 1, XFilial("SAL") + _cCodGrp, "AL_DESC")
				_cUser2		:= (cAliasTRB)->CR_USER
				_cAprov2	:= (cAliasTRB)->CR_APROV

				_cWFId 	:= MontaEml((cAliasTRB)->CR_FILIAL, Substr((cAliasTRB)->CR_NUM,1,6), _cUser2 , _cAprov2, (cAliasTRB)->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), "1")
				DbSelectarea("SCR")
				SCR->(DbSetOrder(2))
				If SCR->(DbSeek((cAliasTRB)->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER)))
					DbSelectArea("SCR")
					Reclock("SCR",.F.)
					SCR->CR_WF		:= "1"
					SCR->CR_WFID	:= _cWFId
					SCR->(MSUnlock())
				Endif
				DbSelectArea(cAliasTRB)
				(cAliasTRB)->(DbSkip())
			End

		ElseIf _nOpc == 3 // Reenvio
			U_Console("3 - TimeOut",cFuncName)
			_lProcesso	:= .T.

			dbSelectArea("SAL")
			dbSelectArea("SAK")
			dbSelectArea("SCP")
			dbSelectArea("SCR")
			dbSelectArea("SCS")

			_cWFID		:= oProcess:aParams[1]
			_cChave		:= oProcess:aParams[2]
			_nCont		:= oProcess:aParams[3]

			U_Console("3 - ID :" + _cWFID + " Timeout:" + Alltrim(Str(_nCont)),cFuncName)
			U_Console("3 - Chave :" + _cChave,cFuncName)

			DbSelectArea("SCR")
			SCR->(DbSetOrder(2))
			SCR->(DbSeek(_cChave))
			If !Found()
				U_Console("3 - Processo nao encontrado",cFuncName)
				lSegue := .F.
			Endif
			If lSegue .And. !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS $ "03#04#05"
				U_Console("3 - Processo ja respondido anteriormente.",cFuncName)
				lSegue := .F.
			EndIf
			If lSegue .And. SCR->CR_WFID <> _cWFID
				U_Console("3 - ID do Processo nao corresponde ao SCR->CR_WFID.",cFuncName)
				lSegue := .F.
			EndIf

			If lSegue

				_cValor		:= Transform(SCR->CR_TOTAL,'@E 999,999,999.99')
				_cCodGrp	:= xRetGrp(Substr(SCR->CR_NUM,1,6))
				_cNomGrp	:= Posicione("SAL", 1, XFilial("SAL") + _cCodGrp, "AL_DESC")

				MontaEml(SCR->CR_FILIAL, Substr(SCR->CR_NUM,1,6), SCR->CR_USER , SCR->CR_APROV, SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), "3")

			Endif

		Endif

		If lSegue

			If _lProcesso
				U_Console(" Mensagem processada ",cFuncName)
			Else
				U_Console(" Nao houve processamento",cFuncName)
			Endif

			Reset Environment

		Endif

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} MontaEml
Montagem do HTML.

@type function
@author Thiago Rasmussen
@since 01/02/2012
@version P12.1.23

@param _cFilial, Caractere, Código da Filial.
@param _cNum, Caractere, Número da Solicitação ao Armazém.
@param _cUser, Caractere, Código do usuário.
@param _cAprov, Caractere, Código do Aprovador.
@param _cChave, Caractere, Chave do Documento a ser aprovado.
@param _cWF, Caractere, Tipo de aprovação.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Id do processo de WorkFlow.

/*/
/*/================================================================================================================================/*/

Static Function MontaEml(_cFilial, _cNum, _cUser, _cAprov, _cChave, _cWF)

	Local _cMail		:= ""
	Local _cAttachFile	:= ""
	Local _lUltNotif	:= .F.
	Local cWfDir 		:= Alltrim(GetNewPar("MV_WFDIR","workflow\") )
	Local _cWfDir2    	:= Alltrim(GetNewPar("MV_WFDIRWF","\workflow") )
	//Local cWfDHttp 		:= Alltrim(GetNewPar("MV_WFDHTTP","workflow\") )
	Local cWFEMTST   	:= Alltrim(GetNewPar("SI_WFEMTST",""))
	//Local cFuncName		:= "MontaEml"
	Local cDirHtml   	:= ""
	local nTotalGer		:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Right(RTrim(cWfDir),1) # "\"
		cWfDir := RTrim(cWfDir) + "\"
	EndIf

	DbSelectArea("SCP")
	SCP->(DbSetOrder(1))
	SCP->(DbSeek(_cFilial + _cNum))

	DbSelectArea("SAK")
	SAK->(DbSetOrder(1))
	SAK->(DbSeek(XFilial("SAK") + _cAprov))

	If _cWF == "1"		// E-mail para aprovacao
		oProcess:= TWFProcess():New( "000001", "Envio Aprovacao " + Substr(_cChave,9,2) + ": " + _cFilial + "/" +  _cNum)
		oProcess:NewTask("Envio SA: " + _cFilial + _cNum, cWfDir+"\AprovacaoSA.htm")
		oProcess:bReturn  := "U_SIESTA3R"
		//oProcess:bReturn  := "U_SIESTA03(2)"
		_nCont	:= 0
		_cSubject	:= "Aprovacao " + Substr(_cChave,9,2) + ": " + _cFilial + "/" +  _cNum

		//AKI
		//If SAK->AK_REENVIO > 0
		//_aPeriodo	:= U_ConsisteData("60")
		//aAdd(oProcess:bTimeOut, {"U_SIESTA03(3)", _aPeriodo[1], _aPeriodo[2], _aPeriodo[3]})
		//Endif

		DbSelectarea("SCR")
		SCR->(DbSetOrder(2))
		SCR->(DbSeek(_cChave))
		AADD(oProcess:aParams, oProcess:fProcessId)
		AADD(oProcess:aParams, _cChave)
		AADD(oProcess:aParams, _nCont)
	ElseIf _cWF == "3"		// TimeOut
		_nCont		:= _nCont + 1
		If _nCont <= SAK->AK_REENVIO
			oProcess:NewTask("Envio " + Substr(_cChave,9,2) + ": " + _cFilial + _cNum, cWfDir+"\AprovacaoSA.htm", .T.)
			oProcess:bReturn  	:= "U_SIESTA03(2)"
			oProcess:aParams[3]	:= _nCont
			_aPeriodo	:= U_ConsisteData(SAK->AK_TIMEOUT)
			aAdd(oProcess:bTimeOut, {"U_SIESTA03(3)", _aPeriodo[1], _aPeriodo[2], _aPeriodo[3]})
			_cSubject	:= "Aprovacao " + Substr(_cChave,9,2) + ": " + _cFilial + "/" +  _cNum + " Reenvio - " + Alltrim(Str(_nCont))
		Else
			_lUltNotif	:= .T.
			oProcess	:= TWFProcess():New( "000001", "Envio Notificacao Timeout Aprovacao " + Substr(_cChave,9,2) + ": " + _cFilial + "/" +  _cNum)
			oProcess:NewTask("Envio Notificacao " + Substr(_cChave,9,2) + ": " + _cFilial + _cNum, cWfDir+"\AprovacaoSA.htm")
			_cSubject	:= "Aprovacao " + Substr(_cChave,9,2) + ": " + _cFilial + "/" +  _cNum + " Nao Respondida"
			_cUser		:= ""//SC7->C7_USER
		Endif
	ElseIf _cWF == "5"
		oProcess	:= TWFProcess():New( "000001", "Envio Notificacao " + Substr(_cChave,9,2) + ": " + _cFilial + "/" +  _cNum + " Aprovado")
		oProcess:NewTask("Envio Notificacao " + Substr(_cChave,9,2) + ": " + _cFilial + _cNum, cWfDir+"\AprovacaoSA.htm")
		_cSubject	:= "Solicitação ao Armazém " + _cFilial + "/" +  _cNum + " Aprovada"
		_cUser		:= ""//SC7->C7_USER
		_cMail		:= UsrRetMail(SCR->CR_PREAPRO) + "; "
	ElseIf _cWF == "7"
		oProcess	:= TWFProcess():New( "000001", "Envio Notificacao " + Substr(_cChave,9,2) + ": " + _cFilial + "/" +  _cNum + " Reprovado")
		oProcess:NewTask("Envio Notificacao " + Substr(_cChave,9,2) + ": " + _cFilial + _cNum, cWfDir+"\AprovacaoSA.htm")
		_cSubject	:= "Solicitação ao Armazém " + _cFilial + "/" +  _cNum + " Reprovada"
		_cUser		:= ""//SC7->C7_USER
		_cMail		:= UsrRetMail(SCR->CR_PREAPRO) + "; "
	Endif

	oProcess:cSubject 	:= _cSubject

	IF !EMPTY(cWFEMTST)
		oProcess:cTo := cWFEMTST
	ELSE
		oProcess:cTo := UsrRetMail(_cUser)
	ENDIF

	_cWFID	:= oProcess:fProcessId

	If _cWF != "3" .Or. _lUltNotif
		oProcess:NewVersion(.T.)
		oProcess:oHtml:ValByName("CSOLICIT"		, SCP->CP_NUM )
		oProcess:oHtml:ValByName("FILIAL"		, SCP->CP_FILIAL )
		oProcess:oHtml:ValByName("SOLICIT"		, SCP->CP_SOLICIT)
		oProcess:oHtml:ValByName("CP_EMISSAO"	, SCP->CP_EMISSAO )
		oProcess:oHtml:ValByName("CP_ITEMCTA"	, SCP->CP_ITEMCTA )
		oProcess:oHtml:ValByName("ITEMCTA_DESC"	, POSICIONE("CTD",1,XFILIAL("CTD")+SCP->CP_ITEMCTA,"CTD_DESC01") )
		oProcess:oHtml:ValByName("CAPROV"		, _cAprov )
		oProcess:oHtml:ValByName("APROVADOR"	, Posicione("SAK",1,xFilial("SAK")+_cAprov,"AK_NOME") )
		oProcess:oHtml:ValByName("OBS" 			, "" )

		While !SCP->(EOF()) .AND. SCP->CP_FILIAL == _cFilial .AND. SCP->CP_NUM == _cNum

			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1") + SCP->CP_PRODUTO))

			AAdd(oProcess:oHtml:ValByName("prod.cItem")		, SCP->CP_ITEM)
			AAdd(oProcess:oHtml:ValByName("prod.cCod")		, SCP->CP_PRODUTO)
			AAdd(oProcess:oHtml:ValByName("prod.cDesc")		, SB1->B1_DESC)
			AAdd(oProcess:oHtml:ValByName("prod.cUM")		, SB1->B1_UM)
			AAdd(oProcess:oHtml:ValByName("prod.nQuant")	, Transform(SCP->CP_QUANT,'@E 99,999,999.99'))
			AAdd(oProcess:oHtml:ValByName("prod.nVrUnit")	, Transform(SCP->CP_XVUNIT,'@E 999,999,999.99'))
			AAdd(oProcess:oHtml:ValByName("prod.nVrTotal")	, Transform(SCP->CP_XVLRTOT,'@E 999,999,999.99'))
			AAdd(oProcess:oHtml:ValByName("prod.dEntrega")	, SCP->CP_DATPRF)
			AAdd(oProcess:oHtml:ValByName("prod.cObs")		, SCP->CP_OBS)

			nTotalGer+=SCP->CP_XVLRTOT

			DbSelectArea("SCP")
			SB1->(DbSkip())
		EndDo

		oProcess:oHtml:ValByName( "totgeral" , TRANSFORM( nTotalGer ,'@E 999,999,999.99' ) )

		DbSelectArea("SCR")
		SCR->(DbSetOrder(1))
		SCR->(DbSeek(Left(_cCHAVE,60)))
		While !SCR->(Eof()) .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == Left(_cCHAVE,60)
			cSituaca := ""
			Do Case
				Case SCR->CR_STATUS == "01"
				cSituaca := "Aguardando"
				Case SCR->CR_STATUS == "02"
				cSituaca := "Em Aprovacao"
				Case SCR->CR_STATUS == "03"
				cSituaca := "Aprovado"
				Case SCR->CR_STATUS == "04"
				cSituaca := "Bloqueado"
				Case SCR->CR_STATUS == "05"
				cSituaca := "Nivel Liberado"
			EndCase

			AAdd( (oProcess:oHtml:ValByName("proc.nivel")	), SCR->CR_NIVEL)
			AAdd( (oProcess:oHtml:ValByName("proc.cApov")	), UsrFullName(SCR->CR_USER))
			AAdd( (oProcess:oHtml:ValByName("proc.cSit")	), cSituaca)
			AAdd( (oProcess:oHtml:ValByName("proc.dDtLib")	), DTOC(SCR->CR_DATALIB))
			AAdd( (oProcess:oHtml:ValByName("proc.cObs")	), Iif(Empty(SCR->CR_OBS),"", SCR->CR_OBS))

			DbSelectArea("SCR")
			SCR->(DbSkip())
		End
	Endif
	If _cWF == "1" .Or. (_cWF == "3" .And. !_lUltNotif)

		//	Gravo os destinatarios definidos pelo programa original	e os troco para um endereco invalido
		cOldTo  := oProcess:cTo
		oProcess:cTo  := "HTML"

		cDirHtml   := "emp"+cEmpAnt+"\html\"

		//cMailId    := oProcess:Start()  // Crio o processo e gravo o ID do processo de Workflow
		cMailID    := oProcess:Start(_cWfDir2+cDirHtml)
		cHtmlFile  := cMailId + ".htm"

		cMailto    := "mailto:" + AllTrim( GetMV('MV_WFMAIL') )
		//chtmltexto := wfloadfile(cWfDir+"emp"+cEmpAnt+"\temp\" + chtmlfile)
		chtmltexto := wfloadfile(_cWfDir2+cDirHtml+cHtmlFile)
		cHtmlTexto := strtran( chtmltexto, cmailto, "WFHTTPRET.APL" )
		//cHtmlTexto := strtran( chtmltexto, "WFHTTPRET.APW", "WFHTTPRET.APL" )
		//wfsavefile(cWfDir+"\messenger\emp"+cEmpAnt+"\html\"+chtmlfile, chtmltexto)  // grava novamente com as alteracoes necessarias.

		wfsavefile(_cWfDir2+cDirHtml+cHtmlFile, cHtmlTexto)  // grava novamente com as alteracoes necessarias.

		//	A funcao abaixo faz a criacao e envio do link para resposta
		U_EnviaLink(chtmlfile,cOldTo,_cSubject, _cAttachFile,_cNum,UsrFullName(SCR->CR_USER))  // Funcao que faz o envio do email com link para acesso ao processo de workflow
	Else
		oProcess:Start()
	Endif

Return(_cWFId)

/*/================================================================================================================================/*/
/*/{Protheus.doc} GravAprov
Faz o tratamento das aprovações/reprovações.

@type function
@author Thiago Rasmussen
@since 01/02/2012
@version P12.1.23

@param _cAprov, Caractere, Código do Aprovador.
@param _cChave, Caractere, Chave do documento em aprovação.
@param _cGrpAprov, Caractere, Código do Grupo de Aprovação.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function GravAprov(_cAprov,_cChave,_cGrpAprov)

	Local _cAuxNivel	:= SCR->CR_NIVEL
	Local _cAprovador	:= SCR->CR_APROV
	//Local _cUsuario		:= SCR->CR_USER
	//Local _nValDcto		:= SCR->CR_TOTAL
	//Local _nMoeDcto		:= SCR->CR_MOEDA
	Local _cNextNiv 	:= ""
	Local _lAchou		:= .F.
	Local _lLiberou		:= .T.
	Local _lBloqueou	:= .F.
	Local cFuncName		:= "GravAprov"
	//Local nRecnoSCR		:= SCR->(Recno())

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If _cAprov == "S"
		U_Console("2 - Processo aprovado.",cFuncName)
	Else
		U_Console("2 - Processo reprovado.",cFuncName)
	Endif

	DbSelectArea("SCR")
	Reclock("SCR",.F.)
	SCR->CR_WF := "2"	//	Status 2 - respondido
	SCR->(MSUnlock())

	// Verifica o saldo de alcada para aprovacao. Se valor do pedido estiver dentro do limite maximo e minimo
	// do aprovador , utiliza o controle de saldos, caso contrario nao faz o tratamento como vistador.
	DbSelectArea("SAL")
	SAL->(DbSetOrder(3))
	SAL->(DbSeek(xFilial("SAL") + SC7->C7_APROV + SCR->CR_APROV))
	If SAL->AL_LIBAPR == "A" .AND. MaAlcLim(SCR->CR_APROV,SCR->CR_TOTAL,SCR->CR_MOEDA,SCR->CR_TXMOEDA)// .And. Empty(SCR->CR_WF)
		_aSaldo	 	:= MaSalAlc(SCR->CR_APROV,dDataBase)  // Funcao do protheus
		_nSaldo	 	:= _aSaldo[1]
		_nTotal   	:= xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,_aSaldo[2],SCR->CR_EMISSAO,,SCR->CR_TXMOEDA)
		_nSalDif	:= _nSaldo - _nTotal
		If (_nSalDif) < 0
			U_Console("2 - Saldo insuficiente do Aprovador.",cFuncName)
			Reclock("SCR",.F.)
			SCR->CR_WF	:= "3" // Status 3 - rejeitado por saldo
			SCR->(MsUnlock())
			//Exit
		EndIf
	EndIf

	_aSaldo		:= MaSalAlc(SCR->CR_APROV, dDataBase, .T.)
	_nSaldo 	:= _aSaldo[1]
	_dDataRef	:= _aSaldo[3]

	DbSelectArea("SCR")
	RecLock("SCR",.F.)
	CR_STATUS	:= Iif(_cAprov == "S", "03", "04")
	CR_OBS		:= _cObs
	CR_DATALIB	:= dDataBase
	CR_USERLIB	:= SAK->AK_USER
	CR_LIBAPRO	:= SAK->AK_COD
	CR_VALLIB	:= SCR->CR_TOTAL
	CR_TIPOLIM	:= SAK->AK_TIPO
	SCR->(MsUnlock())

	DbSetOrder(1)
	SCR->(DbGoTop())
	SCR->(DbSeek(Left(_cChave,60) + _cAuxNivel))
	_nRec := RecNo()
	While SCR->(!Eof()) .And. SCR->(CR_FILIAL + CR_TIPO + CR_NUM) == Left(_cChave,60)
		If _cAprov == "S"
			DbSelectArea("SAL")
			SAL->(DbSetOrder(3))
			SAL->(DbSeek(xFilial("SAL") + _cGrpAprov + SCR->CR_APROV))
			If Found()
			EndIf

			DbSelectArea("SCR")
			U_Console("2 - Aprovacao - LOOP SCR " + CR_FILIAL + CR_TIPO + CR_NUM + CR_NIVEL + CR_STATUS,cFuncName)
			If _cAuxNivel == CR_NIVEL .And. CR_STATUS != "03" .And. SAL->AL_TPLIBER$"U "
				Exit
			EndIf
			If _cAuxNivel == CR_NIVEL .And. CR_STATUS != "03" .And. SAL->AL_TPLIBER$"NP"
				Reclock("SCR",.F.)
				CR_STATUS	:= "05"
				CR_DATALIB	:= dDataBase
				CR_USERLIB	:= SAK->AK_USER
				CR_APROV	:= _cAprovador
				SCR->(MsUnlock())
			EndIf
			If CR_NIVEL > _cAuxNivel .And. CR_STATUS != "03" .And. !_lAchou
				_lAchou := .T.
				_cNextNiv := CR_NIVEL
			EndIf
			If _lAchou .And. CR_NIVEL == _cNextNiv .And. CR_STATUS != "03"
				Reclock("SCR",.F.)
				CR_STATUS := If(SAL->AL_TPLIBER=="P","05","02")
				SCR->(MsUnlock())
			Endif
		Else
			_lBloqueou	:= .T.
			U_Console("2 - Bloqueio - LOOP SCR " + CR_FILIAL + CR_TIPO + CR_NUM + CR_NIVEL + CR_STATUS,cFuncName)
			If (CR_NIVEL >= _cAuxNivel .And. CR_STATUS != "04" )
				Reclock("SCR",.F.)
				CR_STATUS	:= "04"
				CR_DATALIB	:= dDataBase
				CR_USERLIB	:= SAK->AK_USER
				CR_OBS		:= "Reprovado por " + ALLTRIM(UsrFullName(SAK->AK_USER))
				SCR->(MsUnlock())
			Endif
		Endif
		SCR->(DbSkip())
	End

	//+--------------------------------------------------------------+
	//| Reposiciona e verifica se ja esta totalmente liberado.       |
	//+--------------------------------------------------------------+
	DbSelectArea("SCR")
	SCR->(DbSetOrder(1))
	SCR->(DbGoTo(_nRec))
	While SCR->(!Eof()) .And. SCR->(CR_FILIAL + CR_TIPO + CR_NUM) == Left(_cChave,60)
		ConOut("** SCR Status: " + SCR->CR_STATUS)
		If !(SCR->CR_STATUS $ ("03|05"))
			_lLiberou := .F.
		EndIf
		SCR->(DbSkip())
	End

	DbSelectArea("SCR")
	SCR->(DbSetOrder(2))
	SCR->(DbSeek(_cChave))

	If _lLiberou
		U_Console("2 - Processo completamente aprovado. SA aprovada.",cFuncName)
		DbSelectArea("SCP")
		SCP->(DbSetOrder(1))
		SCP->(DbSeek(xFilial("SCP") + Left(SCR->CR_NUM,6)))
		While SCP->(!Eof()) .And. SCP->CP_FILIAL + SCP->CP_NUM == xFilial("SCP") + Left(SCR->CR_NUM,6)
			U_Console("Solicitacao ao Armazem (Filial+Num+Item): " + SCP->(CP_FILIAL+CP_NUM+CP_ITEM),cFuncName)
			RecLock("SCP",.F.)
			SCP->CP_STATSA := "L"
			SCP->(MsUnlock())
			SCP->(DbSkip())
		End

		DbSelectArea("SCR")
		SCR->(DbSetOrder(2))
		SCR->(DbSeek(_cChave))
		//MontaEml(SCR->CR_FILIAL, Substr(SCR->CR_NUM,1,6), SCR->CR_USER , SCR->CR_APROV, SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), "5")
	ElseIf _lBloqueou
		U_Console("2 - Processo completamente bloqueado. SA bloqueada.",cFuncName)
		DbSelectArea("SCP")
		SCP->(DbSetOrder(1))
		SCP->(DbSeek(xFilial("SCP") + Left(SCR->CR_NUM,6)))
		While SCP->(!Eof()) .And. SCP->CP_FILIAL + SCP->CP_NUM == xFilial("SCP") + Left(SCR->CR_NUM,6)
			U_Console("Solicitacao ao Armazem (Filial+Num+Item): " + SCP->(CP_FILIAL+CP_NUM+CP_ITEM),cFuncName)
			RecLock("SCP",.F.)
			SCP->CP_STATSA := "B"
			SCP->(MsUnlock())
			SCP->(DbSkip())
		End
		DbSelectArea("SCR")
		SCR->(DbSetOrder(2))
		SCR->(DbSeek(_cChave))
		//MontaEml(SCR->CR_FILIAL, Substr(SCR->CR_NUM,1,6), SCR->CR_USER , SCR->CR_APROV, SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), "7")
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} EnviaLink
Envio de link com o processo de workflow a ser respondido.

@type function
@author Thiago Rasmussen
@since 01/10/2004
@version P12.1.23

@param cHtmlFile, Caracteres, Link do Html Externo.
@param cOldTo, Caracteres, E-mail Destino.
@param cSubject, Caracteres, Título do E-mail.
@param cAttachFile, Caracteres, Arquivo a ser anexado ao e-mail.
@param _cNum, Caracteres, Número da Solicitação ao Armazém.
@param cNomAprov, Caracteres, Nome do Aprovador.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function EnviaLink(cHtmlFile,cOldTo,cSubject, cAttachFile,_cNum,cNomAprov)

	Local cWfDir	:= Alltrim(GetNewPar("MV_WFDIR","\workflow"))
	Local cWfHttp	:= Alltrim(GetNewPar("MV_WFHTTP","http://localhost:8080/wf/messenger/emp"+cEmpAnt+"/html/"))
	//Local cFuncName	:= "EnviaLink"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oProcess:NewTask("Link de Processos Workflow", cWfDir+"\LinkSA.htm")  // Html com link para envio
	If !Empty(cAttachFile)
		oProcess:AttachFile(Alltrim(cAttachFile))
	EndIf

	oProcess:oHtml:valbyname("cAprovador", cNomAprov)
	oProcess:oHtml:valbyname("cSolicit"	 , _cNum )
	oProcess:oHtml:valbyname("proc_link" , cWFHttp + cHtmlFile ) // envia o link onde esta o arquivo html (externo)

	oProcess:cTo  		:= cOldTo
	oProcess:csubject 	:= cSubject

	oProcess:Start()

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} Console
Gera uma mensagem no console do server do Protheus.

@type function
@author Thiago Rasmussen
@since 15/08/2002
@version P12.1.23

@param _cTxt, Caractere, Mensagem a ser exibida no Console.
@param _cFunName, Caractere, Nome da Função executada.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function Console(_cTxt,_cFunName)

	Local lSegue := .T.

	//--< Log das Personalizações >-----------------------------
	//U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If _cTxt == Nil .and. _cFunName == Nil
		lSegue := .F.
	ElseIf _cTxt == Nil
		_cTxt := "Unknown Text"
	ElseIf _cFunName == Nil
		_cFunName := "Unknown_Function"
	EndIf

	If lSegue

		nHdl	:= FOpen("\workflow\conout.log",2)
		Iif(nHdl > 0,,nHdl := MSFCREATE("\workflow\conout.log",0))
		FSeek(nHdl,0,2)

		_cLogBody := Dtoc(Date()) +" @ "+ Time() +" "+ _cTxt + chr(13) + chr(10)
		Fwrite(nHdl, _cLogBody, Len(_cLogBody))

		_cLogBody := Replicate('-',80) + chr(13) + chr(10)

		FWrite(nHdl,_cLogBody,Len(_cLogBody))

		FClose(nHdl)

		ConOut("[" + DtoC(Date()) + " " + Time()+ "] [" + _cFunName + "] " + _cTxt)

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ConsisteData
Calcula o horario de Timeout, considerando hora util.

@type function
@author Thiago Rasmussen
@since 01/01/2000
@version P12.1.23

@param periodo, Caractere, Período de processamento.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com dias, horas e minutos com o timeout.

/*/
/*/================================================================================================================================/*/

User Function ConsisteData(periodo)
	Local saldo := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Nowdata := ddatabase
	periodo := Val(Left(periodo,2)) + Val(Substr(periodo,4,2))/60
	nowhora := Val(Left(Time(),2)) + Val(Substr(Time(),4,2))/60

	pi := Val(Left(GetNewPar("MV_WFHINI", "09:00"),2)) + Val(Right(GetNewPar("MV_WFHINI", "09:00"),2))/60
	pf := Val(Left(GetNewPar("MV_WFHFIM", "23:59"),2)) + Val(Right(GetNewPar("MV_WFHFIM", "23:59"),2))/60

	horasuteis := pf - pi
	horasinuteis :=   24 - (pf - pi)

	_dDay   :=  DataValida(nowdata, .T.)
	While _dDay  <>  nowdata
		nowdata := nowdata + 1
		_dDay   :=  DataValida(nowdata, .T.)
		if nowhora > pi
			saldo := saldo + (( 24 - nowhora ) + pi)
		elseif nowhora < pi
			saldo := saldo + (pi - nowhora) + 24
		else
			saldo := saldo + 24
		endif
		nowhora := pi
	enddo

	if nowhora <= Pf
		if nowhora < pi
			Saldo   := saldo + (pi - nowhora)
			nowhora := pi
		endif
	else
		saldo   := saldo + (24 - nowhora) + pi
		nowhora := pi
		nowdata := nowdata + 1
		_dDay   := nowdata
		nowdata := DataValida(nowdata, .T.)
		if _dDay  <>  nowdata
			saldo := saldo + ( 24 * (nowdata-_dDay))
		endif
	endif

	horafinal := nowhora + periodo

	if horafinal <= pf
		saldo   := saldo + periodo
	else
		saldo   := saldo + (pf - nowhora)
		periodo := periodo - (pf -nowhora)
		saldo   := saldo + horasinuteis
		nowdata := nowdata + 1
		_dDay   :=  nowdata
		nowdata := DataValida(nowdata, .T.)
		if _dDay  <>  nowdata
			saldo    := saldo + ( 24 * (nowdata - _dDay) )
		endif

		while periodo > horasuteis
			saldo    := saldo + 24
			nowdata  := nowdata + 1
			_dDay   :=  nowdata
			nowdata := DataValida(nowdata, .T.)
			if _dDay  <>  nowdata
				saldo    := saldo + ( 24 * ( nowdata-_dDay))
			endif
			periodo := periodo - horasuteis
		enddo
		saldo := saldo + periodo
	endif

	_nDias    := Int(saldo  /24)
	_nHoras   := mod(int(saldo),24)

	_nsaldo   := int(saldo)
	if _nSaldo > saldo
		_nSaldo := _nSaldo - 1
	endif

	_nMinutos := round((saldo-int(saldo))*60,0)

Return{_nDias, _nHoras, _nMinutos}

/*/================================================================================================================================/*/
/*/{Protheus.doc} xRetGrp
Retorna o Grupo de Aprovacao da Solicitacao ao Armazem.

@type function
@author Thiago Rasmussen
@since 01/01/2000
@version P12.1.23

@param cNum, Caractere, Número da Solictação de Armazém.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Grupo de Aprovacao da Solicitacao ao Armazem.

/*/
/*/================================================================================================================================/*/

Static Function xRetGrp(cNum)

	Local cRet := ""
	Local aArea	:= GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("SCP")
	SCP->(dbSetOrder(1))
	SCP->(dbSeek(xFilial("SCP")+cNum))

	dbSelectArea("CT1")
	CT1->(dbSetOrder(1))
	CT1->(dbSeek(xFilial("CT1")+SCP->CP_CONTA))

	dbSelectArea("SZQ")
	SZQ->(dbSetOrder(1))
	If SZQ->(dbSeek(xFilial("SZQ")+SCP->CP_CC+CT1->CT1_PREFIX))
		cRet := SZQ->ZQ_COD
	Endif

	RestArea(aArea)
Return cRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIESTA3R
Arquivo de Controle de Processos do Workflow da Solicitação ao Armazém.

@type function
@author Thiago Rasmussen
@since 01/02/2012
@version P12.1.23

@param oProcess, Objeto, Objeto que representa o processo de WorkFlow.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIESTA3R(oProcess)

	Local cFuncName	:= "SIESTA03"
	Local lContinua := .T.
	Local lSegue    := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	U_Console("2 - Processa o Retorno do email",cFuncName)

	dbSelectArea("SAL")
	dbSelectArea("SAK")
	dbSelectArea("SCP")
	dbSelectArea("SCR")
	dbSelectArea("SCS")
	dbSelectArea("SM2")

	_cAprov		:= Alltrim(oProcess:oHtml:RetByName("OPC"))
	_cObs		:= Alltrim(oProcess:oHtml:RetByName("OBS"))
	_cWFID		:= oProcess:aParams[1]
	_cChave		:= oProcess:aParams[2]

	_cAprov 	:= Iif(_cAprov=='APROVAR',"S","N")

	oProcess:Finish()
	U_Console("2 - Chave: " + _cChave,cFuncName)
	U_Console("2 - Opc  : " + _cAprov,cFuncName)
	U_Console("2 - WFid : " + _cWFID,cFuncName)

	If !(_cAprov $ "S|N")  // Aprovacao S-Sim N-Nao
		U_Console("2 - Resposta invalida",cFuncName)
		lSegue := .F.
	Endif

	If lSegue

		DbSelectArea("SCR")
		SCR->(DbSetOrder(2))
		SCR->(DbSeek(_cChave))

		If !Found() .Or. Alltrim(SCR->CR_WFID) <> Alltrim(_cWFID)
			U_Console("2 - Processo nao encontrado",cFuncName)
			lContinua := .F.
		Endif
		If !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS $ "03#04#05"
			U_Console("2 - Processo ja aprovado anteriormente. Registro aprovado.",cFuncName)
			lContinua := .F.
		EndIf

		If lContinua
			_cValor		:= Transform(SCR->CR_TOTAL,'@E 999,999,999.99')
			_cCodGrp	:= xRetGrp(Left(SCR->CR_NUM,6))		//Busca o Grupo de Aprovacao da Solicitacao ao Armazem
			_cNomGrp	:= Posicione("SAL", 1, XFilial("SAL") + _cCodGrp, "AL_DESC")

			DbSelectArea("SCP")
			SCP->(DbSetOrder(1))
			SCP->(DbSeek(xFilial("SCP") + Left(SCR->CR_NUM,6)))
			If SCP->CP_STATSA == "L"		//	Verifica se a Solicitacao ao Armazem esta aprovada. Se estiver, finaliza o processo.
				U_Console("2 - Processo ja aprovado. Solicitacao ao Armazem aprovado.",cFuncName)
			Else
				//GravAprov(_cAprov,_cChave,SCP->CP_XAPROV)
				GravAprov(_cAprov,_cChave,_cCodGrp)
				U_Console("Mensagem processada ",cFuncName)
			Endif

		EndIf

	EndIf

Return