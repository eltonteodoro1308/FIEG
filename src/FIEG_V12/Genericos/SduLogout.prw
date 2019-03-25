#Include 'Protheus.ch'
#include 'Ap5Mail.ch'

 /*/================================================================================================================================/*/
 /*/{Protheus.doc} SduLogout
Ponto de entrada executado ap�s a confirma��o de saida do APSDU. Permite ao usu�rio executar algum procedimento relacionado ao evento de sa�da do m�dulo.

 @type function
 @author Thiago Rasmussen
 @since 16/02/2017
 @version P12.1.23

 @obs Desenvolvimento FIEG

 @history 25/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

 @return L�gico, Fixo Verdadeiro.

 /*/
 /*/================================================================================================================================/*/

User Function SduLogout()
	Local cUser := ParamIXB[1]

	cMensagem := 'Usu�rio...: ' + cUser + '<br>'
	cMensagem += 'Computador: ' + GetComputerName() + '<br>'
	cMensagem += 'IP........: ' + GetClientIP() + '<br>'
	cMensagem += 'Usu�rio SO: ' + LogUserName() + '<br>'
	cMensagem += 'Servidor..: ' + GetServerIP() + '<br>'
	cMensagem += 'Ambiente..: ' + GetEnvServer() + '<br>'
	cMensagem += 'Data......: ' + DTOC(Date()) + '<br>'
	cMensagem += 'Hora......: ' + Time() + '<br>'

	cMensagem := '<FONT FACE="Courier New" COLOR="RED" SIZE="3">' + cMensagem + '</FONT>'

	IF 'SDBPRD'$GetEnvServer()
		SendMail('thiagorasmussen@sistemafieg.org.br', 'APSDU', cMensagem)
	ENDIF

Return .T.

/*/================================================================================================================================/*/
/*/{Protheus.doc} SendMail
Envio de e-mail.

@type function
@author Thiago Rasmussen
@since 16/02/2017
@version P12.1.23

@param cPara, Caractere, Endere�o de e-mail.
@param cAssunto, Caractere, Assunto do e-mail.
@param cMensagem, Caractere, Mensagem do e-mail.

@obs Desenvolvimento FIEG

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function SendMail(cPara, cAssunto, cMensagem)
	Local lResul := .F.
	Local cError := ""

	CONNECT SMTP SERVER 'smtp.fieg.org.br' ACCOUNT 'protheus.fieg@fieg.org.br' PASSWORD 'Protheus01Fieg' RESULT lResul

	IF .F.
		//Retorna se conseguiu fazer autentica��o
		lResul := MailAuth('protheus.fieg@fieg.org.br','Protheus01Fieg')

		IF !lResul
			GET MAIL ERROR cError
			Conout("SduLogout - Problemas na autenticacao do envio de email de aviso: " + cError)
			Return
		ENDIF
	ENDIF

	cAssunto += ' | ' + GetEnvServer() + ' || Logout'

	SEND MAIL FROM 'protheus.fieg@fieg.org.br' TO cPara SUBJECT cAssunto BODY cMensagem RESULT lResul

	IF !lResul
		GET MAIL ERROR cError
		Conout("SduLogout - Problemas no envio de email de aviso: " + cError)
	ENDIF

	DISCONNECT SMTP SERVER RESULT lResul

Return
