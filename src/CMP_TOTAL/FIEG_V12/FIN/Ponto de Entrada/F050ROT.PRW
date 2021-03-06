#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} F050ROT
Ponto de Entrada para inclus�o de op��es no aRotina do Contas a Pagar.

@type function
@author Thiago Rasmussen
@since 09/04/2012
@version P12.1.23

@obs Projeto ELO

@history 12/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Array, Array com op��es a serem inclu�das no aRotina.

/*/
/*/================================================================================================================================/*/

User Function F050ROT()
	Local _aRet := ParamIXB
	Local _aVet := {{"Incluir","U_SIFINA11(1)",0,4},{"Alterar","U_SIFINA11(2)",0,4},{"Excluir","U_SIFINA11(3)",0,4},;
	{"Visualizar","U_SIFINA11(4)",0,4},{ "Efetivar","U_SIFINA11(5)",0,4},{ "Estornar","U_SIFINA11(6)",0,4},{ "Relat�rio","U_SIFINR13(1)",0,4}}  // Mutuo

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aAdd(_aRet,{"M�tuo",_aVet,0,6}) // Rateio do Mutuo

Return(_aRet)
