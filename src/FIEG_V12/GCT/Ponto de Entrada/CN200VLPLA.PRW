#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN200VLPLA
O ponto de entrada CN200VLPLA est� localizado na fun��o CN200Manut e dever� ser utilizado para valida��o do Cadastro de Planilhas.

@type function
@author Thiago Rasmussen
@since 25/07/2017
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso para valida��o do cadastro de planilhas.

/*/
/*/================================================================================================================================/*/

User Function CN200VLPLA()

	Local lRet := .T.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If PARAMIXB[4] == 3 .AND. M->CNA_NUMERO <> '000001'
		MsgAlert("Esse contrato n�o permite a inclus�o de uma nova planilha!","CN200VLPLA")
		lRet := .F.
	EndIf

	If lRet .And. PARAMIXB[4] == 5
		MsgAlert("Esse contrato n�o permite a exclus�o da planilha atual!","CN200VLPLA")
		lRet := .F.
	EndIf

Return lRet