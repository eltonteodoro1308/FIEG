#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA01
Cadastro de Tipo de Documento (SZ5).

@type function
@author Leonardo Soncin
@since 12/09/2011
@version P12.1.23

@obs Projeto ELO

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMA01

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Private cCadastro := "Cadastro de Tipo de Documento"
	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
	{"Visualizar","AxVisual",0,2} ,;
	{"Incluir","AxInclui",0,3} ,;
	{"Alterar","AxAltera",0,4} ,;
	{"Excluir","AxDeleta",0,5} }

	Private cDelFunc := "U_SICOMA17()" // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "SZ5"

	dbSelectArea("SZ5")
	SZ5->( dbSetOrder(1) )

	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString)

Return
