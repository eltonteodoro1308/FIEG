#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA130QSC
Ponto de entrada nao aglutinar itens iguais de uma mesma SC.
Inclui c�digos para quebra de solicita��o de Compras.

@type function
@author Joao Carlos A. Neto
@since 11/01/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Bloco de C�digo, � esperado como retorno um Bloco de C�digo contendo c�digos para quebra de solicita��o de Compras.
/*/
/*/================================================================================================================================/*/

User Function MA130QSC()

RETURN {|| C1_FILIAL+C1_NUM+C1_ITEM}