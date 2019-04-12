#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN200VLPLA
O ponto de entrada CN200VLPLA está localizado na função CN200Manut e deverá ser utilizado para validação do Cadastro de Planilhas.

@type function
@author Thiago Rasmussen
@since 25/07/2017
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação do cadastro de planilhas.

/*/
/*/================================================================================================================================/*/

User Function CN200VLPLA()

	Local lRet := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If PARAMIXB[4] == 3 .AND. M->CNA_NUMERO <> '000001'
		MsgAlert("Esse contrato não permite a inclusão de uma nova planilha!","CN200VLPLA")
		lRet := .F.
	EndIf

	If lRet .And. PARAMIXB[4] == 5
		MsgAlert("Esse contrato não permite a exclusão da planilha atual!","CN200VLPLA")
		lRet := .F.
	EndIf

Return lRet