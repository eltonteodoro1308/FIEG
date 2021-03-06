#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT103CWH
Permite alterar o WHEN dos campos da Pr�-Nota e NFE.

@type function
@author Thiago Rasmussen
@since 23/06/2017
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro para valida When e Falso para n�o Valida When.

/*/
/*/================================================================================================================================/*/

User Function MT103CWH

	Local lRetorno := .T.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If !Empty(GetSx3Cache(PARAMIXB[1], 'X3_WHEN'))

		lRetorno := &(GetSx3Cache(PARAMIXB[1], 'X3_WHEN'))

	EndIf

Return lRetorno