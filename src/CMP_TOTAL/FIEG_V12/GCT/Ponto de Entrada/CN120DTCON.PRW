#Include "Totvs.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120DTCON
Ponto de Entrada executado no momento de informar o número do contrato, na rotina de inclusão de uma medição de contrato,
retorna Falso nas seguintes situações:
- Medição não pode ser realizada manualmente para um contrato do tipo registro de preço.
- Medição não pode ser realizada manualmente para um contrato compartilhado entre filiais.
- Medição não pode ser realizada por esse usuário devido o mesmo não compor o grupo de gestores do contrato.

@type function
@author Thiago Rasmussen
@since 19/03/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para as validações definidas.

/*/
/*/================================================================================================================================/*/

User Function CN120DTCON()

	Local lRet := .T.


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF SuperGetMV("SI_XCRP") == 'N'

		IF CN9->CN9_XREGP == "1"
			Help(,, "CN120DTCON",, "Medição não pode ser realizada manualmente para um contrato do tipo registro de preço.",1,0,,,,,,{""} )//MsgAlert("Medição não pode ser realizada manualmente para um contrato do tipo registro de preço.","CN120DTCON")
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
				Help(,, "CN120DTCON",, "Medição não pode ser realizada manualmente para um contrato compartilhado entre filiais.",1,0,,,,,,{""} )//MsgAlert("Medição não pode ser realizada manualmente para um contrato compartilhado entre filiais.","CN120DTCON")
				//QRY->(dbCloseArea())
				lRet := .F. //RETURN .F.
			EndIf

			QRY->(dbCloseArea())

			If lRet

				cQuery := "SELECT R_E_C_N_O_ FROM " + RetSqlName('CNN') + " CNN " + CRLF +;
				"WHERE CNN_FILIAL = '" + xFilial("CNN") + "' AND " + CRLF +;
				"      CNN_CONTRA = '" + SC1->C1_XCONTPR + "' AND " + CRLF +;//"      CNN_CONTRA = '" + CN9->CN9_NUMERO + "' AND " + CRLF +;
				"      CNN_USRCOD = '" + RetCodUsr() + "' AND " + CRLF +;
				"      D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"QRY", .F., .T.)

				If QRY->(EOF())
					Help(,, "CN120DTCON",, "Medição não pode ser realizada por esse usuário devido o mesmo não compor o grupo de gestores do contrato.",1,0,,,,,,{""} )//MsgAlert("Medição não pode ser realizada por esse usuário devido o mesmo não compor o grupo de gestores do contrato.","CN120DTCON")
					//QRY->(dbCloseArea())
					lRet := .F. //RETURN .F.
				EndIf

				QRY->(dbCloseArea())

			EndIf

		EndIf

	EndIf

Return lRet