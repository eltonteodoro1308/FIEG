#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PadraoProtheusDoc
Ponto de Entrada para validar a grava��o da rotina MATA150.

@type function
@author Wanderley Monteiro - TOTVS
@since 13/01/2012
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, Retorna conte�do da rotina U_xIsForHab()
/*/
/*/================================================================================================================================/*/

User Function MT150Ok()

Local aArea := GetArea()
Local lRet:= U_xIsForHab(cA150forn, cA150loj)

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
RestArea(aArea)

Return lRet
