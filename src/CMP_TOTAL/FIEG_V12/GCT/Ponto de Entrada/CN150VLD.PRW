#Include "Protheus.ch"

// Autor....: Thiago Rasmussen
// Data.....: 29/11/2016
// Modulo...: 69 - Gest�o de Contratos
// Descri��o: Ponto de Entrada criado com o objetivo de customizar a valida��o no momento em que o usu�rio confirma a Aprova��o da Revis�o do Contrato.



/*/================================================================================================================================/*/
/*/{Protheus.doc} CN150VLD
Ponto de Entrada criado com o objetivo de customizar a valida��o no momento em que o usu�rio confirma a Aprova��o da Revis�o do Contrato.

@type function
@author Thiago Rasmussen
@since 29/11/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso para valida��o da Aprova��o da Revis�o do Contrato.

/*/
/*/================================================================================================================================/*/

User Function CN150VLD()

	Local lRet := .T.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If SubStr(XFilial("CN9"),1,4)$'02GO;03GO'
		If Posicione("CN0",1,XFilial("CN0")+CN9->CN9_TIPREV,"CN0_ESPEC") != '3'
			If Empty(Posicione("ALM",2,XFilial("ALM")+"001"+RetCodUsr(),"ALM_USER"))
				MsgAlert("Usu�rio n�o possui permiss�o para aprovar essa esp�cie de revis�o de contrato, a revis�o deve ser aprovada pelo n�cleo de or�amento da GECON.","CN150VLD")
				lRet := .F. //Return .F.
			EndIf
		EndIf

		If lRet .And. YEAR(CN9->CN9_DTINIC) != YEAR(DATE())
			If Empty(Posicione("ALM",2,XFilial("ALM")+"001"+RetCodUsr(),"ALM_USER"))
				MsgAlert("Usu�rio n�o possui permiss�o para aprovar contratos com vig�ncia iniciada em ano diferente do ano corrente, a revis�o deve ser aprovada pelo n�cleo de or�amento da GECON.","CN150VLD")
				lRet := .F. //Return .F.
			EndIf
		EndIf
	EndIf

Return lRet