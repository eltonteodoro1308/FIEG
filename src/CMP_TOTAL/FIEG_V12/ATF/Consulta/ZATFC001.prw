#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} ZATFC001
Fun��o criada para ser usada na consulta espec�fica SN1FIL.
Necess�ria para o fonte ZATFA001.prw, usado na impress�o de etiquetas TLP 2844.

@type function
@author Jo�o Renes
@since 05/11/2018
@version P12.1.23

@param nCampOri, Num�rico, Campo de Origem.

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ZATFC001(nCampOri)
	Local aArea    := GetArea()
	Local cComboBo1   := ""
	Local oButton1    := nil
	Local oButton2    := nil
	Local oComboBo1   := nil
	Local oDescr      := nil

	Local oSize := nil

	Private cDescr    := Space(53)
	private lRet      := .F.
	private oDlg      := nil
	private oBrowSN1  := nil

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oSize := FwDefSize():New(.T.)
	oSize:AddObject( "TELA",  100, 20, .T., .T. )
	oSize:lProp 	:= .T.
	oSize:aMargins 	:= { 3, 3, 3, 3 }
	oSize:Process()
	oDlg := MSDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3]/1.2,;
	oSize:aWindSize[4]/1.6,"Consulta Espec�fica - Ativos",,,,,CLR_BLACK,CLR_WHITE,,,.T.)


	// Cria o combo que serve para filtrar pela descri��o ou pelo c�digo
	oComboBo1 := TComboBox():New(oSize:GetDimension("TELA","LININI"),oSize:GetDimension("TELA","COLINI"),{|u| if(PCount() == 0,cComboBo1,cComboBo1 := u )},;
	{'C�digo','Descri��o'},186,010,oDlg,,{||},,,,.T.,,,,,,,,,,)

	// Cria o campo de descri��o que o usu�rio poder� usar para filtrar os ativos
	oDescr := TGet():New( oSize:GetDimension("TELA","LININI") + 15,oSize:GetDimension("TELA","COLINI"), {|u| if( PCount() == 0, cDescr, cDescr := u ) },;
	oDlg,186,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,,,,;
	cDescr,,,.T.,.F.,,"",2)

	/*----------------------------------------------------------------------------------------\\
	||    cria��o dos componentes do tipo Tbutton                                             ||
	\\----------------------------------------------------------------------------------------*/

	TButton():New( oSize:GetDimension("TELA","LININI"),oSize:GetDimension("TELA","COLINI") + 190,"Pesquisar",oDlg,{||FilBusca(Alltrim(cDescr),cComboBo1,oBrowSN1 )},;
	037,012,,,.F.,.T.,.F.,,.F.,,,.F.)

	TButton():New( oSize:GetDimension("TELA","YSIZE")/1.3 + 15,006,"OK",oDlg,{||RetAtiv(oBrowSN1:nAt)},037,012,,,.F.,.T.,.F.,,.F.,,,.F.)

	TButton():New( oSize:GetDimension("TELA","YSIZE")/1.3 + 15,052,"Cancelar",oDlg,{||oDlg:End()},037,012,,,.F.,.T.,.F.,,.F.,,,.F.)


	If (Select("SN1") <> 0)
		dbSelectArea("SN1")
		SN1->(DbGoTop())
	Endif


	//Mostra a janela criada. Ela � similar �s janelas criadas na consulta padr�o
	MostJane(@oSize)

	ACTIVATE MSDIALOG oDlg CENTERED

	RestArea(aArea)
Return  nil

/*/================================================================================================================================/*/
/*/{Protheus.doc} MostJane
Mostra a janela com a consulta espec�fica.

@type function
@author Jo�o Renes
@since 08/05/2018
@version P12.1.23

@param oSize, Objeto, Objeto com as dimens�es da janela.

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function MostJane(oSize)
	Local cAlias    := "SN1"

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Limpa os filtros aplicados, caso existam
	DBClearFilter()


	DbSelectArea(cAlias)
	(cAlias)->(DbSetOrder(1))


	// posiciona no topo
	(cAlias)->(DBGOTOP())

	// Filtra pelo intervalo informado e que o usu�rio tenha acesso
	SET FILTER TO  (cAlias)->N1_FILIAL >= M->cFiliaDe .AND. (cAlias)->N1_FILIAL <= M->cFiliaAt .AND. (cAlias)->N1_FILIAL$cListFil .AND. (cAlias)->N1_QUANTD > 0 .AND. (cAlias)->N1_STATUS <> '0'

	(cAlias)->(DBSEEK(M->cFiliaDe))

	/*----------------------------------------------------------------------------------------\\
	||    Cria o browse que mostra os ativos da consulta espec�fica                           ||
	\\----------------------------------------------------------------------------------------*/
	oBrowSN1 := TCBrowse():New( oSize:GetDimension("TELA","LININI") + 30,oSize:GetDimension("TELA","COLINI"),oSize:GetDimension("TELA","XSIZE")/1.6,oSize:GetDimension("TELA","YSIZE")/1.5 + 5,,,,oDlg,,,,,{||},;
	,,,,,,.F.,(cAlias),.T.,,.F.,,, )

	// Cria 2 colunas
	oBrowSN1:AddColumn(TCColumn():New('Filial',{||(cAlias)->N1_FILIAL };
	,,,,'LEFT',,.F.,.F.,,,,.F.,))

	oBrowSN1:AddColumn(TCColumn():New('Ativo',{||Alltrim((cAlias)->N1_CBASE) + ' - ' +;
	Alltrim((cAlias)->N1_DESCRIC)},,,,'LEFT',,.F.,.F.;
	,,,,.F.,))

	oBrowSN1:Refresh(.T.)


	// Duplo clique: seleciona a linha atual
	oBrowSN1:bLDblClick  := {||RetAtiv(oBrowSN1:nAt)}

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} RetAtiv
Retorna para o campo de consulta(f3) da tela anterior (fonte (ZATFA001.prw) o registro selecionado pelo usu�rio.

@type function
@author Jo�o Renes
@since 09/05/2018
@version P12.1.23

@param nLinha, Num�rico, linha do grid que o usu�rio selecionou

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function RetAtiv(nLinha)

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	if nCampOri == 1
		oAtivoDe:cText(ALLTRIM(SN1->N1_CBASE))
		oAtivoAt:SetFocus()
	Elseif nCampOri == 2
		if Alltrim(M->cAtivoDe) <> "" .AND. ALLTRIM(SN1->N1_CBASE) == cFiliaDe .and. ALLTRIM(SN1->N1_CBASE) < M->cAtivoDe
			Alert("O c�digo do segundo ativo deve ser maior ou igual ao primeiro!")
			M->cAtivoAt := ""
			oAtivoAt:SetFocus()
		Else
			oAtivoAt:cText(ALLTRIM(SN1->N1_CBASE))
			oDescric:SetFocus()
		Endif
	Endif

	lRet := .T.
	oDlg:Refresh()
	oDlg:End()
Return



/*/================================================================================================================================/*/
/*/{Protheus.doc} FilBusca
Filta os ativos pelo c�digo ou pela descri��o.

@type function
@author Jo�o Renes
@since 09/05/2018
@version P12.1.23

@param cTermo, Caractere, recebe o termo digitado pelo usu�rio.
@param cTipo, Caractere, recebe o tipo: c�digo/descri��o.
@param oBrowse, Objeto, Objeto que representa o Browse.

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function FilBusca(cTermo,cTipo,oBrowse)

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SN1->(DBClearFilter())


	If cTermo == ""

		SET FILTER TO SN1->N1_FILIAL >= M->cFiliaDe .AND. SN1->N1_FILIAL <= M->cFiliaAt .AND. SN1->N1_FILIAL$cListFil

	Else

		If cTipo == 'C�digo'
			SET FILTER TO SN1->N1_FILIAL >= M->cFiliaDe .AND. SN1->N1_FILIAL <= M->cFiliaAt .AND. cTermo$SN1->N1_CBASE  .AND. SN1->N1_FILIAL$cListFil
		Elseif cTipo == 'Descri��o'
			SET FILTER TO SN1->N1_FILIAL >= M->cFiliaDe .AND. SN1->N1_FILIAL <= M->cFiliaAt .AND. cTermo$SN1->N1_DESCRIC .AND. SN1->N1_FILIAL$cListFil
		Endif


	Endif

	SN1->(DBGOTOP())
	SN1->(DBSEEK(cFiliaDe))
	oBrowSN1:GoTop()
	oBrowSN1:Refresh(.T.)
Return nil