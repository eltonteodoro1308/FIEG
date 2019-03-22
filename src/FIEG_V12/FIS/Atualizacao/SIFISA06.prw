#Include "protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIFISA06
Browse principal do Cadastro de Prefeituras x Aliquotas Servico (Mod 3).

@type function
@author Thiago Rasmussen
@since 04/06/2010
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIFISA06()
	Private cAliasCabec	:= "SZ8"
	Private cAliasItens	:= "SZ9"
	Private cCadastro	:= "Prefeituras x Aliquotas Serviços"
	Private aRotina 	:= {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+--------------------------------------------------------------+
	//| Adiciona itens no menu do Browse                             |
	//+--------------------------------------------------------------+
	aAdd( aRotina, { "Pesquisar"  ,"AxPesqui"   , 0 , 1} )
	aAdd( aRotina, { "Visualizar" ,"U_SIFISA07( cAliasCabec, cAliasItens, (cAliasCabec)->( RecNo() ), 2 )", 0, 2 } )
	aAdd( aRotina, { "Incluir"    ,"U_SIFISA07( cAliasCabec, cAliasItens, (cAliasCabec)->( RecNo() ), 3 )", 0, 3 } )
	aAdd( aRotina, { "Alterar"    ,"U_SIFISA07( cAliasCabec, cAliasItens, (cAliasCabec)->( RecNo() ), 4 )", 0, 4 } )
	aAdd( aRotina, { "Excluir"    ,"U_SIFISA07( cAliasCabec, cAliasItens, (cAliasCabec)->( Recno() ), 5 )", 0, 5 } )

	//+--------------------------------------------------------------+
	//| Seleciona tabela principal a ser usada no Browse             |
	//+--------------------------------------------------------------+
	DBSelectArea( cAliasCabec )
	( cAliasCabec )->(DBSetOrder( 1 ))

	//+--------------------------------------------------------------+
	//| Executa browse                                               |
	//+--------------------------------------------------------------+
	MBrowse( 6, 1, 22, 75, cAliasCabec )

Return( Nil )
