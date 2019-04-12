#Include 'Protheus.ch'
#Include 'TbiConn.ch'
#Include 'Ap5Mail.ch'
#Include 'TopConn.ch'
#Include 'FileIO.ch'

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA05
Envio de e-mail de cotacoes ao fornecedor.

@type function
@author Thiago Rasmussen
@since 09/09/2011
@version P12.1.23

@param aParam, array, Array recebido do Schedule com os dados da empresa e filial do ambiente de execução.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMA05(aParam)
	Local cFuncName  := "SICOMA05"
	Local cCodEmp    := ""
	Local cCodFil    := ""
	Local lContinua  := .F.

	If ValType(aParam) == "A" .and. Len(aParam) >= 2
		If ValType(aParam[1]) =="C" .and. ValType(aParam[2]) =="C"
			cCodEmp   := aParam[1]
			cCodFil   := aParam[2]
			ConOut(cFuncName+":: Parametros Recebidos => Empresa/Filial: "+cCodEmp+"/"+cCodFil)
			lContinua := .T.
		Else
			lContinua := .F.
		EndIf
	Else
		lContinua := .F.
	EndIf

	IF lContinua
		ConOut(cFuncName+":: Inicializacao do ambiente - Workflow PC Empresa/Filial: "+cCodEmp+"/"+cCodFil)
		WfPrepEnv(cCodEmp,cCodFil)

		//--< Log das Personalizações >-----------------------------
		U_LogCustom()

		//--< Processamento da Rotina >-----------------------------

		_fEnvWF() // Processa a rotina para Envio do Workflow

		Reset Environment
		ConOut(cFuncName+":: Finalizacao do ambiente - Workflow PC Empresa/Filial: "+cCodEmp+"/"+cCodFil)
	ENDIF

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} _fEnvWF
Envia aviso aos fornecedores.

@type function
@author Thiago Rasmussen
@since 07/02/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function _fEnvWF()
	Local _lEnvCOT     := GetMV("SI_ENVCOT")
	Local _cURL		   := Iif((GetMv("SI_URLFOR",.T.)),GetMv("SI_URLFOR"),SuperGetMV("SI_URLFOR",.F.,"",SUBSTR(cFilAnt,1,4)))
	Local cFuncName  := "SICOMA05"
	Private _cAliasTRB := GetNextAlias()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If _lEnvCOT

		//seleciona as cotacoes a serem enviadas
		_cQuery := "SELECT DISTINCT C8_NUM,C8_FORNECE,C8_LOJA FROM "+RetSQLName("SC8")+" WHERE C8_FILIAL = '"+xFilial("SC8")+"' AND D_E_L_E_T_ = ' ' AND C8_XENVFOR <> 'T'"
		_cQuery := ChangeQuery(_cQuery)

		dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cAliasTRB,.t.,.t.)

		(_cAliasTRB)->(dbGoTop())

		While (_cAliasTRB)->(!Eof())

			_cPara	  := Alltrim(Lower(Posicione("SA2",1,XFilial("SA2")+(_cAliasTRB)->(C8_FORNECE+C8_LOJA),"A2_EMAIL")))

			//		_cCodUser := Posicione("AI5",1,XFilial("AI5")+(_cAliasTRB)->(C8_FORNECE+C8_LOJA),"AI5_CODUSU")
			//		ConOut(cFuncName+":: Codigo Usuario "+_cCodUser  +  " " + XFilial("AI5")+(_cAliasTRB)->(C8_FORNECE+C8_LOJA))

			AI5->(dbOrderNickName("CODFOR"))
			AI5->(dbSeek(XFilial("AI5")+(_cAliasTRB)->(C8_FORNECE+C8_LOJA)))
			_cCodUser := AI5->AI5_CODUSU
			ConOut(cFuncName+":: Codigo Usuario "+_cCodUser)

			_cAssunto := "Cotação "+(_cAliasTRB)->C8_NUM
			_cUser	  := Posicione("AI3",1,XFilial("AI3")+_cCodUser,"AI3_LOGIN")
			_cPsw	  := Posicione("AI3",1,XFilial("AI3")+_cCodUser,"AI3_PSW")

			_cWFID := SendMail(_cPara,_cAssunto,_cURL,_cUser,_cPsw,(_cAliasTRB)->C8_NUM)

			If Empty(_cPara) //não ha nenhum destinatario para o e-mail
				Conout("WARNING - SICOMA05 - Processo WFID: "+AllTrim(_cWFID)+" iniciado, porém não existe um destinatário para envio do Workflow.")
			ElseIf Empty(_cURL)
				Conout("WARNING - SICOMA05 - Processo WFID: "+AllTrim(_cWFID)+" iniciado, porem parametro [SI_URLFOR] nao esta cadastrado para a filial.")
			EndIF

			//Atualiza flag como enviado
			SC8->(dbSetOrder(1))
			SC8->(dbSeek(XFilial("SC8")+(_cAliasTRB)->(C8_NUM+C8_FORNECE+C8_LOJA)))

			While SC8->(!Eof()) .and. SC8->C8_FILIAL == XFilial("SC8") .and. SC8->(C8_NUM+C8_FORNECE+C8_LOJA) == (_cAliasTRB)->(C8_NUM+C8_FORNECE+C8_LOJA)

				Reclock("SC8",.F.)
				SC8->C8_XENVFOR	:= .T.
				SC8->C8_XWFID	:= _cWFID
				SC8->(MsUnLock())

				SC8->(dbSkip())
			Enddo

			(_cAliasTRB)->(DbSkip())
		EndDo

		(_cAliasTRB)->(	dbCloseArea())
		FErase(_cAliasTRB+GetDBExtension())
		FErase(_cAliasTRB+OrdBagExt())

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} SendMail
Envia o e-mail.

@type function
@author Renato Neves
@since 09/09/2011
@version P12.1.23

@param _cTo, Caractere, E-mail Destino.
@param _cSubject, Caractere, Assunto do E-mail.
@param _cURL, Caractere, URL para o portal do fornecedor.
@param _cUser, Caractere, Usuário para o portal do fornecedor.
@param _cPsw, Caractere, Senha para o portal do fornecedor
@param _cCotacao, Caractere, Número da Cotação.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Work Flow ID.

/*/
/*/================================================================================================================================/*/

Static Function SendMail(_cTo,_cSubject,_cURL,_cUser,_cPsw,_cCotacao)
	local _oProcess
	Local _cWFID		:= ""
	Local _cArqHtml 	:= "\WORKFLOW\SICOMA05.HTM"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_oProcess := TWFProcess():New("JOBCOT", "WF de envio de cotação ao fornecedor (SICOMA05)" )

	_oProcess:NewTask('Inicio',_cArqHtml)

	_oProcess:cSubject :=_cSubject
	_oProcess:cTo := _cTo

	_oProcess:oHtml:ValByName("LINK",_cURL)
	_oProcess:oHtml:ValByName("NumCotacao",_cCotacao)
	_oProcess:oHtml:ValByName("Usuario",_cUser)
	_oProcess:oHtml:ValByName("Senha",_cPsw)

	_cWFID := _oProcess:Start()

	_oProcess:Finish()

Return _cWFID
