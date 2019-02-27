#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA130QSC
Ponto de entrada nao aglutinar itens iguais de uma mesma SC.
Inclui códigos para quebra de solicitação de Compras.

@type function
@author Joao Carlos A. Neto
@since 11/01/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Bloco de Código, É esperado como retorno um Bloco de Código contendo códigos para quebra de solicitação de Compras.
/*/
/*/================================================================================================================================/*/

User Function MA130QSC()

RETURN {|| C1_FILIAL+C1_NUM+C1_ITEM}