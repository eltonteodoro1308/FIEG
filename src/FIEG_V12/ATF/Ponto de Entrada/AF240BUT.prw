#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} AF240BUT
Adiciona novos bot�es a rotina de classifica��o de compras do ativo.

@type function
@author Allan da Silva Faria
@since 03/02/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Array, Array com bot�es..

/*/
/*/================================================================================================================================/*/

User Function AF240BUT()

	Private aRotina := ParamIXB

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//-- Novo bot�o adicionado
	aAdd(aRotina, { "Excluir", "AF010Delet", 0, 5, 44 } )

Return(aRotina)