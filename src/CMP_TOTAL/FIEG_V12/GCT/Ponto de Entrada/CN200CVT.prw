#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN200CVT
Este ponto de entrada realiza validações específicas durante a confirmação da Planilha do Contrato, sendo:
Caso a modalidade do contrato seja "Contrato de Parceria", o tipo da planilha também deve ser "Contrato de Parceria"
Caso a modalidade do contrato não seja "Contrato de Parceria", o tipo da planilha não deve ser "Contrato de Parceria"
Não permitir inclusão/exclusão de itens na planilha.

@type function
@author Thiago Rasmussen
@since 29/11/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para as validações específicas na confiamção da Planilha do Contrato.

/*/
/*/================================================================================================================================/*/

User Function CN200CVT()
	// PARAMIXB[1] - Itens da Planilha
	// PARAMIXB[2] - Cabeçalho da Planilha
	// PARAMIXB[3] - Vetor Contendo os Itens de Rateio

	Local lRet := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// 29/11/2016 - Thiago Rasmussen - Caso a modalidade do contrato seja "Contrato de Parceria", o tipo da planilha também deve ser "Contrato de Parceria"
	If AllTrim(M->CN9_XMDAQU) == 'CP' .AND. AllTrim(M->CNA_TIPPLA) != '005'
		MsgAlert("Como se trata de um contrato de parceria, o tipo da planilha também deve ser contrato de parceria.","CN200CVT")
		lRet := .F.
	EndIf

	// 29/11/2016 - Thiago Rasmussen - Caso a modalidade do contrato não seja "Contrato de Parceria", o tipo da planilha não deve ser "Contrato de Parceria"
	If lRet .And. AllTrim(M->CN9_XMDAQU) != 'CP' .AND. AllTrim(M->CNA_TIPPLA) == '005'
		MsgAlert("Como não se trata de um contrato de parceria, o tipo da planilha não deve ser contrato de parceria.","CN200CVT")
		lRet := .F.
	EndIf

	// 25/07/2017 - Thiago Rasmussen - Não permitir inclusão/exclusão de itens na planilha.
	If lRet .And. M->CN9_XREGP <> '1'
		For I := 1 To Len(aCols)
			If aCols[I][Len(aHeader)+1] == .T.
				MsgAlert("Esse contrato não permite a exclusão de algum item da planilha atual!","CN200CVT")
				lRet := .F.
			EndIf
		Next
	EndIf

Return lRet