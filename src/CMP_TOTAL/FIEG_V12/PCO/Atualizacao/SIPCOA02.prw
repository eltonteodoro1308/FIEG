#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA02
Cadastro de itens contabeis de consolidacao.

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SIPCOA02()

Private cCadastro 	:= "Cadastro de Contas Itens Contabeis de Consolidacao"
Private aRotina 	:= { 	{"Pesquisar","AxPesqui",0,1} ,;
             				{"Visualizar","AxVisual",0,2} ,;
             				{"Incluir","AxInclui",0,3} ,;
             				{"Alterar","AxAltera",0,4} ,;
             				{"Excluir","AxDeleta",0,5} }

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
dbSelectArea("SZ2")
SZ2->(dbSetOrder(1))

mBrowse( 6,1,22,75,"SZ2") 

Return(Nil)
