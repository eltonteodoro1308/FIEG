#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} M106FIL
Filtro na tela de geracao da pre-requisicao para desconsiderar SA com status = E (Em Aprovacao. Feito pelo GAP115)                                                  .

@type function
@author Thiago Rasmussen
@since 01/04/2012
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, String com Filtro.

/*/
/*/================================================================================================================================/*/

User Function M106FIL()

	Local _cRetFil := "CP_STATSA <> 'E'"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

Return(_cRetFil)