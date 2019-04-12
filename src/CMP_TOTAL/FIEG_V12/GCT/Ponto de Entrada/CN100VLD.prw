#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN100VLD
Função executado durante a inclusão do contrato para validações específicas, sendo elas:

Na Inclusão:
- Alguns usuários específicos vão ter permissão de incluir contrato manualmente.
- Não permitir incluir contrato manualmente diferente de registro de preço.
- Não permitir incluir contrato manualmente do tipo contrato de parceria.
- Não permitir incluir contrato manualmente com a modalidade contrato de parceria.

Na Alteração:
- Caso o tipo do contrato seja contrato de parceria, a modalidade também deve ser ser contrato de parceria.

@type function
@author Thiago Rasmussen
@since 06/11/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para as validações específicas.

/*/
/*/================================================================================================================================/*/

User Function CN100VLD()

	Local _MV_XADMCON := NIL
	local lRet        := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If UPPER(ALLTRIM(FUNNAME())) == "CNTA100"
		If INCLUI
			// 06/11/2013 - Thiago Rasmussen - Alguns usuários específicos vão ter permissão de incluir contrato manualmente.
			_MV_XADMCON := SuperGetMV("MV_XADMCON", .F.)
			If !(RetCodUsr() $(_MV_XADMCON))
				MSGALERT("Não é permitido a inclusão de contratos diretamente. Os contratos devem ser gerados através do processo de analise de cotações.","CN100VLD")
				lRet := .F.
			EndIf

			// 25/07/2017 - Thiago Rasmussen - Não permitir incluir contrato manualmente diferente de registro de preço.
			If lRet .And. ALLTRIM(M->CN9_XREGP) != '1'
				MSGALERT("Não é permitido a inclusão diretamente, de contratos diferente de registro de preço.","CN100VLD")
				lRet := .F.
			EndIf

			// 29/11/2016 - Thiago Rasmussen - Não permitir incluir contrato manualmente do tipo contrato de parceria.
			If lRet .And. ALLTRIM(M->CN9_TPCTO) == '016'
				MSGALERT("Não é permitido a inclusão diretamente, de contratos do tipo contrato de parceria.","CN100VLD")
				lRet := .F.
			EndIf

			// 29/11/2016 - Thiago Rasmussen - Não permitir incluir contrato manualmente com a modalidade contrato de parceria.
			If lRet .And. ALLTRIM(M->CN9_XMDAQU) == 'CP'
				MSGALERT("Não é permitido a inclusão diretamente, de contratos com a modalidade contrato de parceria.","CN100VLD")
				lRet := .F.
			EndIf
		ElseIf ALTERA
			// 29/11/2016 - Thiago Rasmussen - Caso o tipo do contrato seja contrato de parceria, a modalidade também deve ser ser contrato de parceria.
			If ALLTRIM(M->CN9_TPCTO) == '016' .AND. ALLTRIM(M->CN9_XMDAQU) != 'CP'
				MSGALERT("Para os contratos do tipo contrato de parceria, a modalidade também deve ser contrato de parceria.","CN100VLD")
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet