#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} M105BUT
Ponto de entrada para acrescentar botao na tela de Solicitacao de Compras.

@type function
@author Thiago Rasmussen
@since 16/12/2011
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com botão.

/*/
/*/================================================================================================================================/*/

User Function M105BUT

	//+---------------------------------------------------------------------+
	//| Declaracao de Variaveis                                             |
	//+---------------------------------------------------------------------+
	Local aRot := U_SIESTA04()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

Return aRot
