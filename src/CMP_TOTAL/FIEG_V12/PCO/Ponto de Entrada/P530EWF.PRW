#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} P530EWF
PE para envio de e-mail de aprovacao/reprovacao de conting�ncia.

@type function
@author TOTVS
@since 23/04/2012
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Nil, Fun��o sem retorno.
/*/
/*/================================================================================================================================/*/

User Function P530EWF()

Local _aEmail := ParamIXB[2]

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
For i := 1 to Len(_aEmail)
	_cBody := "Prezado " +ALI->ALI_NOME + CRLF + CRLF
	_cBody += "Foi gerada a conting�ncia Nr. " + ALI->ALI_CDCNTG + " para sua aprova��o." + CRLF + CRLF
	_cBody += "Data da Solicita��o : " + Dtoc(ALI->ALI_DTSOLI) + "  -  Hora :" + ALI->ALI_HORA + CRLF + CRLF
	_cBody += "Solicitante : " + ALI->ALI_NOMSOL
	ACSendMail( ,,,,_aEmail[i],"Aviso de Contingencia",_cBody)
Next

Return()