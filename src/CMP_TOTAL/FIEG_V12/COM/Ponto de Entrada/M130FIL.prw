#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} M130FIL
Ponto de Entrada para Filtrar as Scs conforme rotina SICOMA15.

@type function
@author Claudinei Ferreira - TOTVS
@since 16/01/2012
@version P12.1.23

@obs Projeto ELO - Especifico CNI (GAP127)

@history 22/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function M130FIL

Local _aArea := GetArea()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Filtrar as SCs conforme o comprador >-----------------
cRet:= U_SICOMA15('M130FIL')

RestArea(_aArea)

Return(cRet)
