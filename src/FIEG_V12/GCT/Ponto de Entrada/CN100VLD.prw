#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN100VLD
Fun��o executado durante a inclus�o do contrato para valida��es espec�ficas, sendo elas:

Na Inclus�o:
- Alguns usu�rios espec�ficos v�o ter permiss�o de incluir contrato manualmente.
- N�o permitir incluir contrato manualmente diferente de registro de pre�o.
- N�o permitir incluir contrato manualmente do tipo contrato de parceria.
- N�o permitir incluir contrato manualmente com a modalidade contrato de parceria.

Na Altera��o:
- Caso o tipo do contrato seja contrato de parceria, a modalidade tamb�m deve ser ser contrato de parceria.

@type function
@author Thiago Rasmussen
@since 06/11/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso para as valida��es espec�ficas.

/*/
/*/================================================================================================================================/*/

User Function CN100VLD()

	Local _MV_XADMCON := NIL
	local lRet        := .T.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If UPPER(ALLTRIM(FUNNAME())) == "CNTA100"
		If INCLUI
			// 06/11/2013 - Thiago Rasmussen - Alguns usu�rios espec�ficos v�o ter permiss�o de incluir contrato manualmente.
			_MV_XADMCON := SuperGetMV("MV_XADMCON", .F.)
			If !(RetCodUsr() $(_MV_XADMCON))
				MSGALERT("N�o � permitido a inclus�o de contratos diretamente. Os contratos devem ser gerados atrav�s do processo de analise de cota��es.","CN100VLD")
				lRet := .F.
			EndIf

			// 25/07/2017 - Thiago Rasmussen - N�o permitir incluir contrato manualmente diferente de registro de pre�o.
			If lRet .And. ALLTRIM(M->CN9_XREGP) != '1'
				MSGALERT("N�o � permitido a inclus�o diretamente, de contratos diferente de registro de pre�o.","CN100VLD")
				lRet := .F.
			EndIf

			// 29/11/2016 - Thiago Rasmussen - N�o permitir incluir contrato manualmente do tipo contrato de parceria.
			If lRet .And. ALLTRIM(M->CN9_TPCTO) == '016'
				MSGALERT("N�o � permitido a inclus�o diretamente, de contratos do tipo contrato de parceria.","CN100VLD")
				lRet := .F.
			EndIf

			// 29/11/2016 - Thiago Rasmussen - N�o permitir incluir contrato manualmente com a modalidade contrato de parceria.
			If lRet .And. ALLTRIM(M->CN9_XMDAQU) == 'CP'
				MSGALERT("N�o � permitido a inclus�o diretamente, de contratos com a modalidade contrato de parceria.","CN100VLD")
				lRet := .F.
			EndIf
		ElseIf ALTERA
			// 29/11/2016 - Thiago Rasmussen - Caso o tipo do contrato seja contrato de parceria, a modalidade tamb�m deve ser ser contrato de parceria.
			If ALLTRIM(M->CN9_TPCTO) == '016' .AND. ALLTRIM(M->CN9_XMDAQU) != 'CP'
				MSGALERT("Para os contratos do tipo contrato de parceria, a modalidade tamb�m deve ser contrato de parceria.","CN100VLD")
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet