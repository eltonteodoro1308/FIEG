#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} AF240CLA
Ponto de Entrada na confirmacao de inclusao / alteracao de um ativo fixo Ap�s a grava��o da classifica��o.
Classificacao de bens desmebrados

@type function
@author Thiago Rasmussen
@since 11/07/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso ( Continua ou nao a classifica��o ).

/*/
/*/================================================================================================================================/*/

User Function AF240CLA()

	Local llRet:= .T.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//-------------------------------------------------------------------------------------------------------------------
	//- Se for validacao da rotina de classificacao de compras, checa se eh necessario classificar ativos desmembrados. -
	//-------------------------------------------------------------------------------------------------------------------
	If IsInCallStack("AF240CLASS")

		//-----------------------------------------------------------------------------------------------------
		//- Checa se eh um ativo desmembrado e em caso positivo, classifica todos os mesmos produtos da mesma -
		//- nota e fornecedor para que o usuario nao tenha que classificar um a um.                           -
		//-----------------------------------------------------------------------------------------------------
		llRet := U_DTATF01(1)

	EndIf

Return llRet