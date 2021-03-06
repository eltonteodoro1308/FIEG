#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} ZCFGA010
Rotina para inclus�o de registros na tabela ZZZ.

@type function
@author Jo�o Renes
@since 23/01/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ZCFGA010()

	Local   aArea := GETAREA()
	Local   cAlias    := "ZZZ"
	Private cCadastro := "Configura��o de usu�rios"
	Private aRotina   := { { "Pesquisar"  ,"AxPesqui" ,0,1},;
	{ "Visualizar" ,"AxVisual" ,0,2},;
	{ "Incluir"    ,"AxInclui" ,0,3},;
	{ "Alterar"    ,"AxAltera",0,4},;
	{ "Excluir"    ,"AxDeleta",0,5}}

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	MBrowse(,,,,cAlias,,,,,,)

	RestArea(aArea)

Return