#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} F100TOK
Ponto de entrada na tudook do movimento financeiro.

@type function
@author Carlos Henrique
@since
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação do Movimento Finaceiro.

/*/
/*/================================================================================================================================/*/

User Function F100TOK()

	Local lRet := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If !lF100Auto .AND. !IsInCallStack("U_SIFINA13")
		If TRIM(M->E5_ORIGEM) == "SIFINA13"
			MsgAlert("Este movimento não pode ser excluido, utilize a rotina Transf. Filiais\Estornar Transf!","F100TOK")
			lRet := .F. // Return .F.
		EndIf

		If lRet .And. Empty(M->E5_TIPOLAN)
			MsgAlert("Informe o Tipo do Lançamento!","F100TOK")
			lRet := .F. // Return .F.
		EndIf

		// Débito
		If lRet .And. M->E5_TIPOLAN == "D" .OR. M->E5_TIPOLAN == "X"
			If Empty(M->E5_DEBITO)
				MsgAlert("Informe a Conta de Débito!","F100TOK")
				lRet := .F. // Return .F.
			EndIf

			If lRet .And. Empty(M->E5_CCD)
				MsgAlert("Informe o Centro de Custo de Débito!","F100TOK")
				lRet := .F. // Return .F.
			EndIf
		EndIf

		// Crédito
		If lRet .And. M->E5_TIPOLAN == "C" .OR. M->E5_TIPOLAN == "X"
			If Empty(M->E5_CREDITO)
				MsgAlert("Informe a Conta de Crédito!","F100TOK")
				lRet := .F. // Return .F.
			EndIf

			If lRet .And. Empty(M->E5_CCC)
				MsgAlert("Informe o Centro de Custo de Crédito!","F100TOK")
				lRet := .F. // Return .F.
			EndIf

		EndIf

	EndIf

	If lRet .And. lF100Auto .AND. !IsInCallStack("U_SIFINA13") // Automaticamente e não foi executado através da rotina de transferência entre filiais
		// 06/05/2015 - Thiago Rasmussen - Consistir inclusão de movimentação bancária com o mesmo número de documento
		If !Empty(M->E5_DOCUMEN)
			If !Empty(POSICIONE("SE5", 10, xFilial("SE5")+M->E5_DOCUMEN, "E5_DOCUMEN"))
				Help("",1,"HELP","F100TOK","Já existe uma movimentação bancária para essa filial, com esse mesmo número de documento!" + CRLF + CRLF + "Filial: " + xFilial("SE5") + CRLF + "Documento: " + M->E5_DOCUMEN,1,0)
				lRet := .F. // Return .F.
			EndIf
		EndIf
	EndIf

Return lRet