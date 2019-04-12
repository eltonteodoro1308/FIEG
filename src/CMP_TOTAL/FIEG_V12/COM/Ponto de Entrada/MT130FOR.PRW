#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT130FOR
Ponto de Entrada para inserir filtro na consulta de fornecedores.

@type function
@author Wanderley Monteiro - TOTVS
@since 13/01/2012
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Retorna o parâmetro da rotina SICOMA33.
/*/
/*/================================================================================================================================/*/

User Function MT130FOR()

Local aArea := GetArea()
Local aRet:= U_SICOMA33(PARAMIXB)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
RestArea(aArea)

Return aRet
