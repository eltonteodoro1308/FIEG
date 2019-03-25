#Include 'Protheus.Ch'
#Include 'Ap5Mail.Ch'

/*/================================================================================================================================/*/
/*/{Protheus.doc} AfterLogin
Este ponto de entrada é executado após as aberturas dos SXs(dicionário de dados).
Ao acessar pelo SIGAMDI, este ponto de entrada é chamado ao entrar na rotina.
Pelo modo SIGAADV, a abertura dos SXs é executado após o login.

@type function
@author Thiago Rasmussen
@since 16/02/2017
@version P12.1.23

@obs Desenvolvimento FIEG

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function AfterLogin()
	Local _CodigoUsuario := ParamIXB[1]
	Local _NomeUsuario   := ParamIXB[2]

	cMensagem := 'Usuário...: ' + _CodigoUsuario + ' - ' + AllTrim(_NomeUsuario) + '<br>'
	cMensagem += 'Computador: ' + GetComputerName() + '<br>'
	cMensagem += 'IP........: ' + GetClientIP() + '<br>'
	cMensagem += 'Usuário SO: ' + LogUserName() + '<br>'
	cMensagem += 'Servidor..: ' + GetServerIP() + '<br>'
	cMensagem += 'Ambiente..: ' + GetEnvServer() + '<br>'
	cMensagem += 'Data......: ' + DTOC(Date()) + '<br>'
	cMensagem += 'Hora......: ' + Time() + '<br>'

	cMensagem := '<FONT FACE="Courier New" COLOR="RED" SIZE="3">' + cMensagem + '</FONT>'

	IF 'SDBPRD'$GetEnvServer() .AND. GetClientIP() != '10.21.6.123' .AND. _CodigoUsuario == '000000'
		SendMail('thiagorasmussen@sistemafieg.org.br', 'Login com Administrador', cMensagem)
	ENDIF

Return .T.

/*/================================================================================================================================/*/
/*/{Protheus.doc} SendMail
Envio de e-mail.

@type function
@author Thiago Rasmussen
@since 16/02/2017
@version P12.1.23

@param cPara, Caractere, Endereço de e-mail.
@param cAssunto, Caractere, Assunto do e-mail.
@param cMensagem, Caractere, Mensagem do e-mail.

@obs Desenvolvimento FIEG

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function SendMail(cPara, cAssunto, cMensagem)
	Local lResul := .F.
	Local cError := ""
	Local lSegue := .T.

	CONNECT SMTP SERVER 'smtp.fieg.org.br' ACCOUNT 'protheus.fieg@fieg.org.br' PASSWORD 'Protheus01Fieg' RESULT lResul

	IF .F.
		//Retorna se conseguiu fazer autenticação
		lResul := MailAuth('protheus.fieg@fieg.org.br','Protheus01Fieg')

		IF !lResul
			GET MAIL ERROR cError
			Conout("AfterLogin - Problemas na autenticacao do envio de email de aviso:"+cError)
			lSegue := .F.
		ENDIF
	ENDIF

	If lSegue

		cAssunto += ' | ' + GetEnvServer()

		SEND MAIL FROM 'protheus.fieg@fieg.org.br' TO cPara SUBJECT cAssunto BODY cMensagem RESULT lResul

		IF !lResul
			GET MAIL ERROR cError
			Conout("AfterLogin - Problemas no envio de email de aviso:"+cError)
		ENDIF

		DISCONNECT SMTP SERVER RESULT lResul

	EndIf

Return