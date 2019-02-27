#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA130KEY
Ponto de entrada nao aglutinar itens iguais de uma mesma SC.
Ordena Arquivos de trabalho.

@type function
@author Joao Carlos A. Neto
@since 11/01/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, É esperado como retorno uma String contendo a nova chave de ordenação.
/*/
/*/================================================================================================================================/*/

User Function MA130KEY()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

Return 'C1_FILIAL+C1_NUM+C1_ITEM'