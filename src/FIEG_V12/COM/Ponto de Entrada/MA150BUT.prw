#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA150BUT
Inclus�o de um bot�o na ToolBar da Conta��o.

@type function
@author Thiago Rasmussen
@since 19/04/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Array, Array com a lista de bot�es a ser inclu�da.

/*/
/*/================================================================================================================================/*/

User Function MA150BUT()

	Local aButtons := {}

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	aadd(aButtons, {'Replicar Informa��o', {|| REPLICAR()}, 'Replicar Informa��o'})

Return (aButtons)


/*/================================================================================================================================/*/
/*/{Protheus.doc} REPLICAR
Replicar a informa��o do primeiro registro e das seguintes colunas abaixo, para os demais registros.

@type function
@author Thiago Rasmussen
@since 19/04/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function REPLICAR()

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	_C8_PRAZO := GDFieldGet("C8_PRAZO",n)

	aEval(aCols,{|x| x[GDFieldPos("C8_PRAZO")] := _C8_PRAZO })

Return