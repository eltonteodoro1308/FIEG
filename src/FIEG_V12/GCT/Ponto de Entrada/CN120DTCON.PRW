#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120DTCON
Ponto de Entrada executado no momento de informar o n�mero do contrato, na rotina de inclus�o de uma medi��o de contrato,
retorna Falso nas seguintes situa��es:
- Medi��o n�o pode ser realizada manualmente para um contrato do tipo registro de pre�o.
- Medi��o n�o pode ser realizada manualmente para um contrato compartilhado entre filiais.
- Medi��o n�o pode ser realizada por esse usu�rio devido o mesmo n�o compor o grupo de gestores do contrato.

@type function
@author Thiago Rasmussen
@since 19/03/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso para as valida��es definidas.

/*/
/*/================================================================================================================================/*/

User Function CN120DTCON()

	Local lRet := .T.


	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF SuperGetMV("SI_XCRP") == 'N'

		IF CN9->CN9_XREGP == "1"
			MsgAlert("Medi��o n�o pode ser realizada manualmente para um contrato do tipo registro de pre�o.","CN120DTCON")
			lRet := .F. //RETURN .F.
		ENDIF

		If lRet

			cQuery := "SELECT COUNT(PB1_NUMERO) AS QUANTIDADE FROM " + RetSqlName('PB1') + " PB1 " + CRLF +;
			"WHERE PB1_FILCN9 = '" + xFilial("CN9") + "' AND " + CRLF +;
			"      PB1_NUMERO = '" + CN9->CN9_NUMERO + "' AND " + CRLF +;
			"      PB1_REVISA = '" + CN9->CN9_REVISA + "' AND " + CRLF +;
			"      D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"QRY", .F., .T.)

			If QRY->QUANTIDADE > 0
				MsgAlert("Medi��o n�o pode ser realizada manualmente para um contrato compartilhado entre filiais.","CN120DTCON")
				//QRY->(dbCloseArea())
				lRet := .F. //RETURN .F.
			EndIf

			QRY->(dbCloseArea())

			If lRet

				cQuery := "SELECT R_E_C_N_O_ FROM " + RetSqlName('CNN') + " CNN " + CRLF +;
				"WHERE CNN_FILIAL = '" + xFilial("CNN") + "' AND " + CRLF +;
				"      CNN_CONTRA = '" + CN9->CN9_NUMERO + "' AND " + CRLF +;
				"      CNN_USRCOD = '" + RetCodUsr() + "' AND " + CRLF +;
				"      D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"QRY", .F., .T.)

				If QRY->(EOF())
					MsgAlert("Medi��o n�o pode ser realizada por esse usu�rio devido o mesmo n�o compor o grupo de gestores do contrato.","CN120DTCON")
					//QRY->(dbCloseArea())
					lRet := .F. //RETURN .F.
				EndIf

				QRY->(dbCloseArea())

			EndIf

		EndIf

	EndIf

Return lRet