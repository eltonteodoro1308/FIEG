#Include 'Totvs.ch'

User Function FIEnvMail(cMailTo, cAssunto, cBody, cAttach, cCCopy)

	/*####################################################################
	## Obejtivo: Enviar email para outros usuários somente se não       ##
	## estiver nas bases de desenvolvimento, ou seja, param. MV_XENVMAI ##
	####################################################################*/
	/*/ Verifica se serao utilizados os valores padrao. /*/

	Local oServer, oMessage
	Local xRet
	Local lErro
	Local nX
	Local cServer    := AllTrim(GetMV('MV_RELSERV'))
	Local cAccount   := AllTrim(GetMV('MV_RELACNT'))
	Local cPassword  := AllTrim(GetMV('MV_RELPSW'))
	Local nTimeOut   := GetMv('MV_RELTIME',, 120)    /*/ Tempo de Espera antes de abortar a Conexao /*/
	Local lAutentica := GetMv('MV_RELAUTH',, .F.)    /*/ Determina se o Servidor de Email necessita de Autenticacao              /*/
	Local cUserAut   := AllTrim(GetMv('MV_RELAUSR')) /*/ Usuario para Autentica??o no Servidor de Email /*/
	Local cPassAut   := AllTrim(GetMv('MV_RELAPSW')) /*/ Senha para Autentica??o no Servidor de Email /*/
	Local cSendSrv   := ''
	Local cMsg       := ''
	Local nSendPort  := 0, nSendSec := 0
	Local cAmbDev    := StrTran(AllTrim(GetMV('MV_XENVMAI')), ';', '|')
	Local cFrom      := AllTrim(GetMV('MV_RELFROM'))
	Local aInfoUsu   := {}
	Local aAnexos    := {}
	Local aSepara    := {}
	Local cAneSrvc   := ""
	Local lRet       := .T.
	Public cSended   := .F.

	cMailTo  := IIf((cMailTo  == Nil), '',                cMailTo )
	cAssunto := IIf((cAssunto == Nil), 'E-Mail PROTHEUS', cAssunto)
	cAttach  := IIf((cAttach  == Nil), '',                cAttach )
	cCCopy   := IIf((cCCopy   == Nil), '',                cCCopy  )
	aAnexos  := ACLONE(StrTokArr (cAttach, ";" ))

	If (Upper(AllTrim(GetEnvServer())) $ cAmbDev)

		PswOrder(1)

		If (PswSeek(AllTrim(__cUserId), .T.))

			aInfoUsu := PswRet(1)

			If ISEMAIL(cMailTo)

				cMailTo := AllTrim(aInfoUsu[1, 14])

			Else

				aSepara := Separa(cMailTo, ';', .T.)

				cMailTo := ""

				For xA := 1 To Len(aSepara)

					If Vazio(cMailTo)

						cMailTo += AllTrim(aInfoUsu[1, 14])

					Else

						cMailTo += ";" + AllTrim(aInfoUsu[1, 14])

					EndIf

				Next xA

			EndIf

		EndIf

		If !Vazio(cCCopy)

			aSepara := Separa(cCCopy, ';', .T.)

			cCCopy := ""

			For xB := 1 To Len(aSepara)

				If Vazio(cCCopy)

					cCCopy += AllTrim(aInfoUsu[1, 14])

				Else

					cCCopy += ";" + AllTrim(aInfoUsu[1, 14])

				EndIf

			Next xB

		EndIf

	EndIf

	If Len(aInfoUsu) != 0

		If Empty(cMailTo)

			MsgAlert('Nao e POSSIVEL enviar o e-mail!' + Chr(13) +;
			'Usuario: ' + AllTrim(aInfoUsu[1, 2]) + '.' + Chr(13) +;
			'Nao possui E-MAIL cadastrado!', 'Atencao!')

			lRet := .F.

			Return lRet

		EndIf

	Else

		If Empty(cMailTo)

			MsgAlert('Nao é POSSIVEL enviar o e-mail!' + Chr(13) +;
			'Campo E-MAIL não preenchido!', 'Atenção!')

			lRet := .F.

			Return lRet

		EndIf

	EndIf

	oServer := TMailManager():New()
	oServer:SetUseSSL(.F.)
	oServer:SetUseTLS(.F.)

	If (nSendSec == 0)

		nSendPort := 25 //default port for SMTP protocol

	ElseIf (nSendSec == 1)

		nSendPort := 465 //default port for SMTP protocol with SSL

		oServer:SetUseSSL(.T.)

	ElseIf (nSendSec == 2)

		nSendPort := 587 //default port for SMTPS protocol with TLS

		oServer:SetUseTLS(.T.)

	EndIf

	// once it will only send messages, the receiver server will be passed as ''
	// and the receive port number won't be passed, once it is optional

	xRet := oServer:Init('', cServer, cAccount, cPassword,, nSendPort)

	If (xRet != 0)

		cMsg := 'Nao foi possivel inicializar o servidor SMTP: ' + oServer:GetErrorString(xRet)

		ConOut(cMsg)

		lRet := .F.

		Return lRet

	EndIf

	// the method set the timout for the SMTP server

	xRet := oServer:SetSMTPTimeout(nTimeout)

	If (xRet != 0)

		cMsg := 'Nao foi possivel configurar o TIMEOUT em: ' + cValToChar(nTimeout) + ' segundos.'

		ConOut(cMsg)

		lRet := .F.

		Return lRet

	EndIf

	// estabilish the connection with the SMTP server

	xRet := oServer:SMTPConnect()

	If (xRet != 0)

		cMsg := 'Nao foi possivel conectar no servidor SMTP: ' + oServer:GetErrorString(xRet)

		ConOut(cMsg)

		lRet := .F.

		Return lRet

	EndIf

	// authenticate on the SMTP server (if needed)

	If lAutentica

		xRet := oServer:SMTPAuth(cUserAut, cPassAut)

		If (xRet != 0)

			cMsg := 'Nao foi possivel fazer autenticacao no servidor SMTP: ' + oServer:GetErrorString(xRet)

			ConOut(cMsg)

			oServer:SMTPDisconnect()

			lRet := .F.

			Return lRet

		EndIf

	EndIf

	oMessage := TMailMessage():New()
	oMessage:Clear()

	If !EXISTDIR("\FileMail\")

		MakeDir("\FileMail\")

	EndIf

	For nX := 1 to Len(aAnexos)

		CpyT2S( aAnexos[nX], "\FileMail\", .T. )
		cAneSrvc := "\FileMail\"+SubStr(aAnexos[nX],RAT( "\", aAnexos[nX] )+1,Len(aAnexos[nX]))
		lErro := oMessage:AttachFile(cAneSrvc)

		If lErro < 0

			Alert("O arquivo não pode ser anexado "+SubStr(aAnexos[nX],RAT( "\", aAnexos[nX] )+1,Len(aAnexos[nX]))+".")

			lRet := .F.

			Return lRet

		EndIf

	Next nX

	oMessage:cDate    := cValToChar(Date())
	oMessage:cFrom    := cFrom
	oMessage:cTo      := cMailTo
	oMessage:cSubject := cAssunto
	oMessage:cBody    := cBody

	// André Carlos - 21/12/2015

	If !Vazio(cCCopy)

		oMessage:cCC := cCCopy

	EndIf

	xRet := oMessage:Send(oServer)

	If (xRet != 0)

		cMsg := 'Nao foi possivel enviar a menssagem: ' + oServer:GetErrorString(xRet)

		ConOut(cMsg)

		lRet := .F.

		Return lRet

	Else

		cSended := .T.

	EndIf

	xRet := oServer:SMTPDisconnect()

	If (xRet != 0)

		cMsg := 'Nao foi possivel desconectar do servidor SMTP: ' + oServer:GetErrorString(xRet)

		ConOut(cMsg)

		lRet := .F.

		Return lRet

	EndIf

	For nX := 1 to Len(aAnexos)

		IF FERASE("\FileMail\"+SubStr(aAnexos[nX],RAT( "\", aAnexos[nX] )+1,Len(aAnexos[nX]))) == -1

			Conout('Falha na deleção do Arquivo '+SubStr(aAnexos[nX],RAT( "\", aAnexos[nX] )+1,Len(aAnexos[nX])))

		EndIf

	Next nX

Return
