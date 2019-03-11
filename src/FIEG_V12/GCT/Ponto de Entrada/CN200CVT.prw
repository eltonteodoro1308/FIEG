#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN200CVT
Este ponto de entrada realiza valida��es espec�ficas durante a confirma��o da Planilha do Contrato, sendo:
Caso a modalidade do contrato seja "Contrato de Parceria", o tipo da planilha tamb�m deve ser "Contrato de Parceria"
Caso a modalidade do contrato n�o seja "Contrato de Parceria", o tipo da planilha n�o deve ser "Contrato de Parceria"
N�o permitir inclus�o/exclus�o de itens na planilha.

@type function
@author Thiago Rasmussen
@since 29/11/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso para as valida��es espec�ficas na confiam��o da Planilha do Contrato.

/*/
/*/================================================================================================================================/*/

User Function CN200CVT()
	// PARAMIXB[1] - Itens da Planilha
	// PARAMIXB[2] - Cabe�alho da Planilha
	// PARAMIXB[3] - Vetor Contendo os Itens de Rateio

	Local lRet := .T.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// 29/11/2016 - Thiago Rasmussen - Caso a modalidade do contrato seja "Contrato de Parceria", o tipo da planilha tamb�m deve ser "Contrato de Parceria"
	If AllTrim(M->CN9_XMDAQU) == 'CP' .AND. AllTrim(M->CNA_TIPPLA) != '005'
		MsgAlert("Como se trata de um contrato de parceria, o tipo da planilha tamb�m deve ser contrato de parceria.","CN200CVT")
		lRet := .F.
	EndIf

	// 29/11/2016 - Thiago Rasmussen - Caso a modalidade do contrato n�o seja "Contrato de Parceria", o tipo da planilha n�o deve ser "Contrato de Parceria"
	If lRet .And. AllTrim(M->CN9_XMDAQU) != 'CP' .AND. AllTrim(M->CNA_TIPPLA) == '005'
		MsgAlert("Como n�o se trata de um contrato de parceria, o tipo da planilha n�o deve ser contrato de parceria.","CN200CVT")
		lRet := .F.
	EndIf

	// 25/07/2017 - Thiago Rasmussen - N�o permitir inclus�o/exclus�o de itens na planilha.
	If lRet .And. M->CN9_XREGP <> '1'
		For I := 1 To Len(aCols)
			If aCols[I][Len(aHeader)+1] == .T.
				MsgAlert("Esse contrato n�o permite a exclus�o de algum item da planilha atual!","CN200CVT")
				lRet := .F.
			EndIf
		Next
	EndIf

Return lRet