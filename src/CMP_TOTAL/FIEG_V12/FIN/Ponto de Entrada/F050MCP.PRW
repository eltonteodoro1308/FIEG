#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} F050MCP
Ponto de Entrada para manipulacao dos campos alteraveis.

@type function
@author Thiago Rasmussen
@since 11/04/2012
@version P12.1.23

@obs Projeto ELO

@history 12/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com lista de cmapos que poderaão ser alterados.

/*/
/*/================================================================================================================================/*/

User function F050MCP()
	Local _aRet := ParamIXB


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If !Empty(SE2->E2_XMUTUO) .and. (_nPos := Ascan(_aRet,"E2_VALOR")) > 0
		aDel(_aRet,_nPos)
		aSize(_aRet,Len(_aRet)-1)
	EndIf

Return(_aRet)
