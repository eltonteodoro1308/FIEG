#Include "Protheus.ch"

// Autor....: Thiago Rasmussen
// Data.....: 29/11/2016
// Modulo...: 69 - Gestão de Contratos
// Descrição: Ponto de Entrada criado com o objetivo de customizar a validação no momento em que o usuário confirma a Aprovação da Revisão do Contrato.



/*/================================================================================================================================/*/
/*/{Protheus.doc} CN150VLD
Ponto de Entrada criado com o objetivo de customizar a validação no momento em que o usuário confirma a Aprovação da Revisão do Contrato.

@type function
@author Thiago Rasmussen
@since 29/11/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação da Aprovação da Revisão do Contrato.

/*/
/*/================================================================================================================================/*/

User Function CN150VLD()

	Local lRet := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If SubStr(XFilial("CN9"),1,4)$'02GO;03GO'
		If Posicione("CN0",1,XFilial("CN0")+CN9->CN9_TIPREV,"CN0_ESPEC") != '3'
			If Empty(Posicione("ALM",2,XFilial("ALM")+"001"+RetCodUsr(),"ALM_USER"))
				MsgAlert("Usuário não possui permissão para aprovar essa espécie de revisão de contrato, a revisão deve ser aprovada pelo núcleo de orçamento da GECON.","CN150VLD")
				lRet := .F. //Return .F.
			EndIf
		EndIf

		If lRet .And. YEAR(CN9->CN9_DTINIC) != YEAR(DATE())
			If Empty(Posicione("ALM",2,XFilial("ALM")+"001"+RetCodUsr(),"ALM_USER"))
				MsgAlert("Usuário não possui permissão para aprovar contratos com vigência iniciada em ano diferente do ano corrente, a revisão deve ser aprovada pelo núcleo de orçamento da GECON.","CN150VLD")
				lRet := .F. //Return .F.
			EndIf
		EndIf
	EndIf

Return lRet