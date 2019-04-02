#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT100LOK
Ponto de entrada no linhaok do documento de entrada.

@type function
@author Carlos Henrique
@since 14/02/2012
@version P12.1.23

@obs Desenvolvimento FIEG

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso para valida��o da linha.

/*/
/*/================================================================================================================================/*/

User Function MT100LOK()
	Local lRet:= .T.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If INCLUI .OR. ALTERA
		lRet:= U_SIESTA11(.F.)
	EndIf

Return lRet