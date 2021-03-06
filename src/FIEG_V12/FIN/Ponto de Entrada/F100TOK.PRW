#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} F100TOK
Ponto de entrada na tudook do movimento financeiro.

@type function
@author Carlos Henrique
@since
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso para valida��o do Movimento Finaceiro.

/*/
/*/================================================================================================================================/*/

User Function F100TOK()

	Local lRet := .T.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If !lF100Auto .AND. !IsInCallStack("U_SIFINA13")
		If TRIM(M->E5_ORIGEM) == "SIFINA13"
			MsgAlert("Este movimento n�o pode ser excluido, utilize a rotina Transf. Filiais\Estornar Transf!","F100TOK")
			lRet := .F. // Return .F.
		EndIf

		If lRet .And. Empty(M->E5_TIPOLAN)
			MsgAlert("Informe o Tipo do Lan�amento!","F100TOK")
			lRet := .F. // Return .F.
		EndIf

		// D�bito
		If lRet .And. M->E5_TIPOLAN == "D" .OR. M->E5_TIPOLAN == "X"
			If Empty(M->E5_DEBITO)
				MsgAlert("Informe a Conta de D�bito!","F100TOK")
				lRet := .F. // Return .F.
			EndIf

			If lRet .And. Empty(M->E5_CCD)
				MsgAlert("Informe o Centro de Custo de D�bito!","F100TOK")
				lRet := .F. // Return .F.
			EndIf
		EndIf

		// Cr�dito
		If lRet .And. M->E5_TIPOLAN == "C" .OR. M->E5_TIPOLAN == "X"
			If Empty(M->E5_CREDITO)
				MsgAlert("Informe a Conta de Cr�dito!","F100TOK")
				lRet := .F. // Return .F.
			EndIf

			If lRet .And. Empty(M->E5_CCC)
				MsgAlert("Informe o Centro de Custo de Cr�dito!","F100TOK")
				lRet := .F. // Return .F.
			EndIf

		EndIf

	EndIf

	If lRet .And. lF100Auto .AND. !IsInCallStack("U_SIFINA13") // Automaticamente e n�o foi executado atrav�s da rotina de transfer�ncia entre filiais
		// 06/05/2015 - Thiago Rasmussen - Consistir inclus�o de movimenta��o banc�ria com o mesmo n�mero de documento
		If !Empty(M->E5_DOCUMEN)
			If !Empty(POSICIONE("SE5", 10, xFilial("SE5")+M->E5_DOCUMEN, "E5_DOCUMEN"))
				Help("",1,"HELP","F100TOK","J� existe uma movimenta��o banc�ria para essa filial, com esse mesmo n�mero de documento!" + CRLF + CRLF + "Filial: " + xFilial("SE5") + CRLF + "Documento: " + M->E5_DOCUMEN,1,0)
				lRet := .F. // Return .F.
			EndIf
		EndIf
	EndIf

Return lRet