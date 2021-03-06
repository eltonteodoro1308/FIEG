#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} P530EWF
PE para envio de e-mail de aprovacao/reprovacao de contingência.

@type function
@author TOTVS
@since 23/04/2012
@version P12.1.23

@obs Projeto ELO
@return Nil, Função sem retorno.

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 
@history 08/05/2019, Kley@TOTVS.com.br, Troca da função ACSendMail() por TkSendMail().
/*/
/*/================================================================================================================================/*/

User Function P530EWF()

Local i       := 0
Local _cBody  := ""
Local cAccon  := SuperGetMv("MV_RELACNT")
Local cPassw  := SuperGetMv("MV_RELAPSW")
Local cServer := SuperGetMv("MV_RELSERV")
Local cFrom	  := SuperGetMv("MV_RELFROM")
Local _aEmail := ParamIXB[2]

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
For i := 1 to Len(_aEmail)
	_cBody := "Prezado " +ALI->ALI_NOME + CRLF + CRLF
	_cBody += "Foi gerada a contingência Nr. " + ALI->ALI_CDCNTG + " para sua aprovação." + CRLF + CRLF
	_cBody += "Data da Solicitação : " + Dtoc(ALI->ALI_DTSOLI) + "  -  Hora :" + ALI->ALI_HORA + CRLF + CRLF
	_cBody += "Solicitante : " + ALI->ALI_NOMSOL
	//ACSendMail( ,,,,_aEmail[i],"Aviso de Contingencia",_cBody)
	TKSendMail(cAccon,cPassw,cServer,cFrom,_aEmail[i],"Aviso de Contingencia",_cBody)
Next

Return()
