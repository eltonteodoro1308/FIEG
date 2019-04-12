#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT103INC
Ponto de entrada para validar a classificacao da nota.

@type function
@author Bruna Paola
@since 10/06/2011
@version P12.1.23

@obs Projeto ELO

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógica, Verdadeiro ou Falso para classificação da Nota.

/*/
/*/================================================================================================================================/*/

User Function MT103INC()

	Local lClass := PARAMIXB
	Local lRet    := .T.
	Local lAtesto := GETMV("MV_XATESTO")

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	//Se for classificacao
	If lAtesto .And.  lClass .And. (AllTrim(SF1->F1_XATESTO) == '1')

		lRet := .F.
		MsgAlert("Nota fiscal aguardando atesto do solicitante.","ATENCAO")

	EndIf

Return lRet