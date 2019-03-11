#include "protheus.ch"
#Include "Ap5mail.ch"
/*/================================================================================================================================/*/
/*/{Protheus.doc} CN100VST
Ponto de entrada executado na alteração da situação do contrato.

@type function
@author Thiago Rasmussen
@since 29/08/2017
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando se a alteração foi possível.

/*/
/*/================================================================================================================================/*/

User Function CN100VST()

	Local _MV_XGRUPCO := SuperGetMV("MV_XGRUPCO", .F.)
	Local lRet         := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If PARAMIXB[1] == '02'
		If CN9->CN9_SALDO < CN9->CN9_VLATU
			MsgAlert("A situação do contrato não por ser alterado para elaboração porque já existe medição para esse contrato!","CN100VST")
			lRet := .F.
		EndIf

		If lRet .And. CN9->CN9_DTFIM < DDATABASE
			MsgAlert("A situação do contrato não por ser alterado para elaboração porque esse contrato não está vigente!","CN100VST")
			lRet := .F.
		EndIf
	EndIf

	If lRet

		Do Case
			Case PARAMIXB[1] == '01'
			_CN9_SITUAC := 'Cancelado'
			Case PARAMIXB[1] == '02'
			_CN9_SITUAC := 'Elaboração'
			Case PARAMIXB[1] == '03'
			_CN9_SITUAC := 'Emitido'
			Case PARAMIXB[1] == '04'
			_CN9_SITUAC := 'Aprovado'
			Case PARAMIXB[1] == '05'
			_CN9_SITUAC := 'Vigente'
			Case PARAMIXB[1] == '06'
			_CN9_SITUAC := 'Paralizado'
			Case PARAMIXB[1] == '07'
			_CN9_SITUAC := 'Solicitado Finalização'
			Case PARAMIXB[1] == '08'
			_CN9_SITUAC := 'Finalizado'
			Case PARAMIXB[1] == '09'
			_CN9_SITUAC := 'Revisão'
			Case PARAMIXB[1] == '10'
			_CN9_SITUAC := 'Revisado'
		EndCase

		_cBody := 'Informamos que o seguinte contrato abaixo teve sua situação alterada para ' + _CN9_SITUAC + '.'
		_cBody += Chr(13)+Chr(10)+Chr(13)+Chr(10)
		_cBody += 'Filial.....: ' + CN9->CN9_FILIAL +Chr(13)+Chr(10)
		_cBody += 'Contrato...: ' + CN9->CN9_NUMERO + IIf(EMPTY(CN9->CN9_REVISA),'','/' + CN9->CN9_REVISA) +Chr(13)+Chr(10)
		_cBody += 'Descrição..: ' + ALLTRIM(CN9->CN9_DESCRI) +Chr(13)+Chr(10)
		_cBody += 'Vigencia...: ' + cValToChar(CN9->CN9_DTINIC) + '  à  ' + cValToChar(CN9->CN9_DTFIM) +Chr(13)+Chr(10)
		_cBody += 'Valor Atual: R$' + ALLTRIM(Transform(CN9->CN9_VLATU,PesqPict("CN9","CN9_VLATU"))) +Chr(13)+Chr(10)
		_cBody += 'Valor Saldo: R$' + ALLTRIM(Transform(CN9->CN9_SALDO,PesqPict("CN9","CN9_SALDO"))) +Chr(13)+Chr(10)
		_cBody += Chr(13)+Chr(10)
		_cBody += 'Usuário responsável pela alteração: ' + UsrFullName(RetCodUsr())

		_cBody := '<FONT FACE="Courier New" COLOR="RED" SIZE="3">' + _cBody + '</FONT>'

		If 'SDBPRD'$GetEnvServer()
			If PARAMIXB[1]$'01;07'
				U_SendMail(_MV_XGRUPCO, 'Contrato Alterado Situação - ' + CN9->CN9_FILIAL + ' | ' + CN9->CN9_NUMERO + IIf(EMPTY(CN9->CN9_REVISA),'','/' + CN9->CN9_REVISA) + ' | ' + _CN9_SITUAC, _cBody)
			EndIf
		EndIf

	EndIf

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} SendMail
Envia email indicando contrato alterado.

@type function
@author Thiago Rasmussen
@since
@version P12.1.23

@param cPara, Caractere, Endereço de E-Mail do destinatário do E-Mail.
@param cAssunto, Caractere, Assunto do E-Mail.
@param cMensagem, Caractere, Mensagemd o corpo do E-Mail.

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SendMail(cPara, cAssunto, cMensagem)
	Local lResul      := .F.
	Local cError      := ""
	Local _WF7_REMETE := ALLTRIM(POSICIONE("WF7", 1,xFilial("WF7"), "WF7_REMETE"))
	Local _WF7_SMTPSR := ALLTRIM(POSICIONE("WF7", 1,xFilial("WF7"), "WF7_SMTPSR"))
	Local _WF7_CONTA  := ALLTRIM(POSICIONE("WF7", 1,xFilial("WF7"), "WF7_CONTA"))
	Local _WF7_SENHA  := ALLTRIM(POSICIONE("WF7", 1,xFilial("WF7"), "WF7_SENHA"))
	Local lSegue      := .T.


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	CONNECT SMTP SERVER _WF7_SMTPSR ACCOUNT _WF7_CONTA PASSWORD _WF7_SENHA RESULT lResul

	If .F.
		//Retorna se conseguiu fazer autenticação
		lResul := MailAuth(_WF7_CONTA, _WF7_SENHA)

		If !lResul
			GET MAIL ERROR cError
			ApMsgInfo("Problemas na autenticacao do envio de email de aviso:"+cError)
			lSegue := .F.
		EndIf
	EndIf

	If lSegue

		SEND MAIL FROM _WF7_REMETE TO cPara SUBJECT cAssunto BODY cMensagem RESULT lResul

		If !lResul
			GET MAIL ERROR cError
			ApMsgInfo("Problemas no envio de email de aviso:"+cError)
		EndIf

		DISCONNECT SMTP SERVER RESULT lResul

	EndIf

Return