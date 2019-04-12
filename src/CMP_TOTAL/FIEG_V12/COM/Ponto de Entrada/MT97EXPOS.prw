#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT97EXPOS
Descrição detalhada da função.

@type function
@author TOTVS
@since 13/10/2011
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT97EXPOS()

Local aArea := GetArea()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
RestArea(aArea)

Return
