#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN100USER
Usuários responsáveis pelo contrato.

@type function
@author Thiago Rasmussen
@since 10/03/2016
@version P12.1.23

@obs Projeto ELO

@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CN100USER()

	Private cCadastro := "Gestores do Contrato"
	Private aRotina := {{"Incluir","AxInclui",0,3},;
	{"Excluir","AxDeleta",0,5}}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	/*
	Private aRotina := {{"Pesquisar","AxPesqui",0,1},;
	{"Visualizar","AxVisual",0,2},;
	{"Incluir","AxInclui",0,3},;
	{"Alterar","AxAltera",0,4},;
	{"Excluir","AxDeleta",0,5}}
	*/

	dbSelectArea("CNN")
	CNN->(dbSetOrder(1))

	MsFilter("CNN_FILIAL == '" + CN9->CN9_FILIAL + "' .AND. CNN_CONTRA == '" + CN9->CN9_NUMERO + "'")

	SetBrwChgAll(.F.)

	mBrowse(6,1,22,75,"CNN")

Return