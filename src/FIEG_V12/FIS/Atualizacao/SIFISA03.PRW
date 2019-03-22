#Include "Protheus.ch"
#Include 'FwMvcDef.ch'

#Define ID_FIELD "MASTER"
#Define ID_GRID	 "DETAIL"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIFISA03
Função para cadastro de Layout de Guia de Recolhimento.

@type function
@author Renato Lucena Neves
@since 18/08/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIFISA03()

	Local _oBrowse 	:= FWMBrowse():New()
	Local _cAlias	:= "SZA"
	Local _cDescri	:= GetAdvFVal("SX2","X2_NOME",_cAlias,1,"")

	Private aRotina := MenuDef()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_oBrowse:SetAlias(_cAlias)
	_oBrowse:SetDescription(_cDescri)


	// Ativação da Classe
	_oBrowse:Activate()

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ModelDef
Define as regras de negócio (objeto modelo de dados).

@type function
@author Renato Lucena Neves
@since 18/08/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Objeto, objeto Modelo de Dados.

/*/
/*/================================================================================================================================/*/

Static Function ModelDef()
	// Cria as estruturas a serem usadas no Modelo de Dados
	Local _oStruSZA := FWFormStruct( 1, 'SZA' )
	Local _oStruSZB := FWFormStruct( 1, 'SZB' )
	Local _oModel // Modelo de dados construído

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_oModel := MPFormModel():New( 'MODEL_SIFISA03' )

	_oModel:AddFields( ID_FIELD, /*cOwner*/, _oStruSZA )
	_oModel:AddGrid( ID_GRID, ID_FIELD, _oStruSZB )

	_oModel:SetRelation( ID_GRID , { { 'ZB_FILIAL', 'xFilial( "SZB" )' }, { 'ZB_LAYOUT', 'ZA_COD' } }, SZB->( IndexKey( 1 ) ) )
	_oModel:GetModel( ID_GRID ):SetUniqueLine( { 'ZB_LAYOUT', 'ZB_ITEM' } )

	_oModel:SetDescription( 'Layout de Guia' )

	_oModel:GetModel( ID_FIELD ):SetDescription( 'Cabecalho' )
	_oModel:GetModel( ID_GRID ):SetDescription( 'Itens' )

	_oModel:SetPrimaryKey({ 'ZA_FILIAL','ZA_COD'})

Return _oModel

/*/================================================================================================================================/*/
/*/{Protheus.doc} ViewDef
Define a camada de Vizualização do programa (objeto VIEW).

@type function
@author Renato Lucena Neves
@since 18/08/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Objeto, objeto VIEW.

/*/
/*/================================================================================================================================/*/

Static Function ViewDef()

	Local _oModel 	:= ModelDef()//FWLoadModel( 'SIFISA03' )
	Local _oStruSZA := FWFormStruct( 2, 'SZA' )
	Local _oStruSZB := FWFormStruct( 2, 'SZB' )
	Local _oView 	:= FWFormView():New()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_oView:SetModel( _oModel )

	_oView:AddField('VIEW_SZA', _oStruSZA, ID_FIELD )
	_oView:AddGrid( 'VIEW_SZB', _oStruSZB, ID_GRID )


	_oView:AddIncrementField( 'VIEW_SZB', 'ZB_ITEM' )

	_oView:CreateHorizontalBox( 'SUPERIOR', 25 )
	_oView:CreateHorizontalBox( 'INFERIOR', 75 )

	_oView:SetOwnerView( 'VIEW_SZA', 'SUPERIOR' )
	_oView:SetOwnerView( 'VIEW_SZB', 'INFERIOR' )


Return _oView

/*/================================================================================================================================/*/
/*/{Protheus.doc} MenuDef
Monta o menu do browse.

@type function
@author Renato Lucena Neves
@since 18/08/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, aRotina com menu do browse.

/*/
/*/================================================================================================================================/*/

Static Function MenuDef()

	Local aRotina := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.SIFISA03' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir' Action 'VIEWDEF.SIFISA03' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar' Action 'VIEWDEF.SIFISA03' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir' Action 'VIEWDEF.SIFISA03' OPERATION 5 ACCESS 0

Return aRotina