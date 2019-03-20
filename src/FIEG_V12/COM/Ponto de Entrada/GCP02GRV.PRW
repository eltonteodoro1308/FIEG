#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Ap5mail.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} GCP02GRV
Inclusao de rotinas customizadas no Browse da tela de orcamentos.

@type function
@author Thiago Rasmussen
@since 24/11/2011
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function GCP02GRV()
	Local aArea 	:= GetArea()
	Local cGrupo 	:= M->CO1_XGRLIB
	Local cDoc 		:= M->CO1_CODEDT+M->CO1_NUMPRO
	Local cDocC 	:= Alltrim(M->CO1_CODEDT)+"/"+Alltrim(M->CO1_NUMPRO)
	Local _nTotEDT 	:= 999

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SCR->(dbSetOrder(1))
	// Se gerou SCR, bloqueia solicitacao novamente.
	IF SCR->(dbSeek(xFilial("SCR")+"ED"+M->CO1_CODEDT+M->CO1_NUMPRO))
		MaAlcDoc({M->CO1_CODEDT+M->CO1_NUMPRO,"ED",_nTotEDT,,,,,1,0,},M->CO1_DTABER,3)
		RecLock("CO1",.F.)
		CO1->CO1_XLIBER := "B"
		CO1->(MsUnLock())
	EndIf

	If !Empty(M->CO1_XGRLIB)
		// Gravar Alcada SCR
		MaAlcDoc({cDoc,"ED",_nTotEDT,,,cGrupo,,1,1,M->CO1_DTABER},,1)
	EndIf

	// Envio de E-mails para os aprovadores
	dbSelectArea("SAL")
	SAL->(dbSetOrder(1))
	SAL->(dbSeek(xFilial("SAL")+cGrupo))
	While !SAL->(Eof() .and. SAL->AL_FILIAL == xFilial("SAL") .AND. SAL->AL_COD == cGrupo)

		fEmail("B",SAL->AL_USER,cDocC)

		dbSelectArea("SAL")
		SAL->(dbSkip())
	EndDo

	RestArea(aArea)
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fEmail
Funcao para envio de e-mail para usuario se solicitacao foi liberada ou bloqueada.

@type function
@author Adriano Luis Brandao
@since 21/07/2011
@version P12.1.23

@param _cAprov, Caractere, L = Liberado / R = Reprovado.
@param _cCodUsu, Caractere, Codigo do usuario.
@param _cDoc, Caractere, Numero da solicitacao de compras.

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fEmail(_cAprov,_cCodUsu,_cDoc)

	//Local cHtm			:= ""
	Local cMailDest		:= UsrRetMail(_cCodUsu)
	Local lResul		:= .F.
	Local lOk			:= .F.
	Local cError		:= ""
	Local lSend			:= .F.
	Local lDisConectou	:= .F.
	Local cAssunto		:= ""
	Local cMensagem		:= ""
	Local cEol			:= Chr(13) + Chr(10)
	Local lSegue        := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cMensagem += "Prezado(a) aprovador(a), " + UsrRetName(_cCodUsu)
	cMensagem += cEol + cEol

	cAssunto	:= "Edital/Processo Nr. " + _cDoc

	cMensagem	+= "Informamos que o edital/processo Nr." + _cDoc + " foi incluído e está disponível para análise e liberação."

	cMensagem += cEol

	If ! Empty(cMailDest)

		CONNECT SMTP SERVER GetMv("MV_RELSERV") ACCOUNT GetMv("MV_RELACNT") PASSWORD GetMv("MV_RELPSW") RESULT lResul

		If GetMv("MV_RELAUTH")
			//Retorna se conseguiu fazer autenticação
			lOk := MailAuth(GetMv("MV_RELACNT"),GetMv("MV_RELPSW"))

			//Atribui retorno de envio de email na variável cError
			If !lOk
				GET MAIL ERROR cError
				Apmsginfo("Problemas na autenticacao do envio de email de aviso:"+cError)
				lSegue := .F. //Return
			EndIf
		EndIf

		If lSegue

			//Envio de email
			SEND MAIL FROM GetMv("MV_RELACNT") TO AllTrim(cMailDest) SUBJECT cAssunto BODY cMensagem RESULT lSend

			If !lSend
				GET MAIL ERROR cError
				ApMsgInfo("Problemas no envio de email de aviso:"+cError)
			EndIf

			//Desconecta do servidor
			DISCONNECT SMTP SERVER RESULT lDisConectou

		EndIf

	Else
		ApMsgInfo("Não existe e-mail cadastrado para o usuario " + UsrRetName(_cCodUsu),"Email nao enviado")
	EndIf

Return
