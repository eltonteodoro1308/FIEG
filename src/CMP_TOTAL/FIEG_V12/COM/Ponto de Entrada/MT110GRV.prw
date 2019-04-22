#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT110GRV
Ponto de Entrada apos gravacao da SC.

@type function
@author Thiago Rasmussen
@since 10/05/2012
@version P12.1.23

@obs Desenvolvimento FIEG
@obs Projeto ELO
@obs Projeto ELO alterado pela FIEG

@return Lógico, Fixo Verdadeiro.

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.
@history 08/04/2019, Kley@TOTVS.com.br, Remoção da chamada à função U_SICOMA16().
/*/
/*/================================================================================================================================/*/

User Function MT110GRV()

Local _aArea := GetArea()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Gravacao da justificativa de compra da SC >-----------
U_SICOMA30()

//--< Gravacao do campo C1_XCODCOMP para C1_CODCOMP >-------
//U_SICOMA16()												// Remoção da chamada à função, 08/04/2019, Kley@TOTVS.com.br

RestArea(_aArea)

Return .T.
