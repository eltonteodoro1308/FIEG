#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA150BUT
Inclusão de um botão na ToolBar da Contação.

@type function
@author Thiago Rasmussen
@since 19/04/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com a lista de botões a ser incluída.

/*/
/*/================================================================================================================================/*/

User Function MA150BUT()

	Local aButtons := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	aadd(aButtons, {'Replicar Informação', {|| REPLICAR()}, 'Replicar Informação'})

Return (aButtons)


/*/================================================================================================================================/*/
/*/{Protheus.doc} REPLICAR
Replicar a informação do primeiro registro e das seguintes colunas abaixo, para os demais registros.

@type function
@author Thiago Rasmussen
@since 19/04/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function REPLICAR()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	_C8_PRAZO := GDFieldGet("C8_PRAZO",n)

	aEval(aCols,{|x| x[GDFieldPos("C8_PRAZO")] := _C8_PRAZO })

Return