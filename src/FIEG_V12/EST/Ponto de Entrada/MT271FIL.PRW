#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT271FIL
Ponto de entrada para tratar filtro na geracao do bloqueio do Inventario.

@type function
@author Leonardo Soncin
@since 06/12/11
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso indicando se bloqueia produto para invent�rio.

/*/
/*/================================================================================================================================/*/

User Function MT271FIL

	//+---------------------------------------------------------------------+
	//| Declaracao de Variaveis                                             |
	//+---------------------------------------------------------------------+

	Local lRet := U_SIESTA02()

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

Return lRet