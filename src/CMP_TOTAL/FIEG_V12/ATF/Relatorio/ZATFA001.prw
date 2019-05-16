#Include "Protheus.ch"
#Include "topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} ZATFA001
Cria os recursos necessários para a impressão de etiquetas modelo TLP 2844.

@type function
@author João Renes
@since 05/11/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ZATFA001()
	// criação da janela
	Local oSize      := nil
	Local oDlg       := nil

	// acessos
	private aListEmp  := {}
	Private cListFil := ""

	Private cFiliaDe := Space(TamSX3("N1_FILIAL")[1])
	Private cFiliaAt := Space(TamSX3("N1_FILIAL")[1])
	Private cGrupo   := Space(TamSX3("N1_GRUPO")[1])
	Private cLocaliz := Space(TamSX3("N1_LOCAL")[1])
	Private oAtivoDe := nil
	Private oAtivoAt := nil
	Private oDescric := nil
	private cAtivoDe := Space(TamSX3("N1_CBASE")[1])
	Private cAtivoAt := Space(TamSX3("N1_CBASE")[1])
	Private nCampOri := 0

	Private oGridEsq
	Private oGridDir
	Private cFiltro

	PRIVATE aColsEsq := {}
	Private aColsDir := {}
	Private lMarcou  := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//SetKey(K_CTRL_KEYPAD_DOWN, {||})

	// Verifica as filiais que o usuário tem acesso
	cListFil := VerAcess(@aListEmp)

	// Cria a janela principal do sistema, sobre a qual ficarão os itens.
	oSize := JanPrinc(@oDlg)

	// Cria os itens do topo da janela
	ItensTopo(oSize,oDlg)

	// Cria o grid da esquerda
	GridEsqu(oSize,oDlg)

	// Cria os botões responsáveis pelas operações entre os dois grids
	CriaBoto(oSize,oDlg)


	// Cria o Grid da direita
	GridDire(oSize,oDlg)

	// Cria os botões para "Imprimir" e "Cancelar"
	BotOpcoes(oSize,oDlg)

	oDlg:Activate()

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} VerAcess
Retorna a lista de filiais que o usuário tem permissão para acessar.

@type function
@author João Renes
@since 27/06/2018
@version P12.1.23

@param aListEmp, Array, Nome do campo de origem.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Lista de filiais que o usuário tem permissão para acessar.

/*/
/*/================================================================================================================================/*/

Static Function VerAcess(aListEmp)
	Local aAcessos := {}
	Local cListAce := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aAcessos := FWEmpLoad()

	For i :=1 to len(aAcessos)
		AAdd(aListEmp,aAcessos[i][3])
		If i <> len(aAcessos)
			cListAce += "'" + aAcessos[i][3] + "',"
		Else
			cListAce += "'" + aAcessos[i][3] + "'"
		Endif
	next i
Return cListAce


/*/================================================================================================================================/*/
/*/{Protheus.doc} JanPrinc
Retorna o objeto responsável pela criação da tela principal.

@type function
@author João Renes
@since 27/06/2018
@version P12.1.23

@param oDlg, Objeto, Objeto que representa a Dialog.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Objeto, Objeto responsável pela criação da tela principal.

/*/
/*/================================================================================================================================/*/

Static Function JanPrinc(oDlg)
	Local oSize := nil

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oSize := FwDefSize():New(.T.)
	oSize:AddObject( "CABECALHO",  100, 20, .T., .T. )
	oSize:AddObject( "GETDADOS" ,  100, 80, .T., .T. )
	oSize:lProp 	:= .T.
	oSize:aMargins 	:= { 3, 3, 3, 3 }

	oSize:Process()
	oDlg := MSDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],;
	oSize:aWindSize[4],"Impressão de Etiquetas",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

Return oSize

/*/================================================================================================================================/*/
/*/{Protheus.doc} Itenstopo
Cria os itens presentes no topo da janela.

@type function
@author João Renes
@since 27/06/2018
@version P12.1.23

@param oSize, Objeto, Objeto que representa as dimensões da tela.
@param oDlg, Objeto, Objeto que representa a Dialog.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function Itenstopo(oSize,oDlg)
	Local cDescric   := Space(120)
	Local oFiliaDe   := nil
	Local oFiliaAt   := nil
	Local oCombo01 := nil
	Local oCombo02 := nil

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oTexto1:= TSay():New(oSize:GetDimension("CABECALHO","LININI") + 9,;
	oSize:GetDimension("CABECALHO","COLINI") + 15,;
	{||'Filial:'},oDlg,,oFont,,,,.T.,CLR_BLACK,;
	CLR_WHITE,30,20)

	oCombo01 := TComboBox():New(oSize:GetDimension("CABECALHO","LININI") + 7,;
	oSize:GetDimension("CABECALHO","COLINI") + 30,;
	{|u|if(PCount()>0,cFiliaDe:=u,cFiliaDe)},;
	aListEmp,oSize:GetDimension("CABECALHO","XSIZE")/9,;
	009,oDlg,,{||},,,,.T.,,,,,,,,,)

	oCombo01:Select(aScan(aListEmp, {|x| AllTrim(x) == alltrim(cFilAnt)}))


	oCombo01:bChange := {||oAtivoDe:cText := '          ',oAtivoAt:cText := '           '}


	oTexto2:= TSay():New(oSize:GetDimension("CABECALHO","LININI") + 9,;
	oSize:GetDimension("CABECALHO","XSIZE") /9 + 40,;
	{||'à'},oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,30,20)

	oCombo02 := TComboBox():New(oSize:GetDimension("CABECALHO","LININI") + 7,;
	oSize:GetDimension("CABECALHO","XSIZE") /9 + 50,;
	{|u|if(PCount()>0,cFiliaAt:=u,cFiliaAt)},aListEmp,;
	oSize:GetDimension("CABECALHO","XSIZE") /9,009,oDlg,,{||},,,,.T.,,,,,,,,,)

	oCombo02:Select(aScan(aListEmp, {|x| AllTrim(x) == alltrim(cFilAnt)})) // seleciona a filial corrente


	oCombo02:bChange := {|| oAtivoDe:cText := '          ',oAtivoAt:cText := '           '}  // Limpa os campos do ativo


	/*----------------------------------------------------------------------------------------\\
	||                     criação dos componentes do tipo Tget                               ||
	||----------------------------------------------------------------------------------------||
	|| ++ armazenam o intervalo de ativos que pode ser seleecionado pelo usuário              ||
	\*----------------------------------------------------------------------------------------*/

	oTexto3:= TSay():New(oSize:GetDimension("CABECALHO","LININI") + 9,;    //nX
	oSize:GetDimension("CABECALHO","XSIZE") /2.6,;  //nY
	{||'Ativo:'},oDlg,,oFont,,,,.T.,CLR_BLACK,;
	CLR_WHITE,30,20)

	oAtivoDe := TGet():New( oSize:GetDimension("CABECALHO","LININI") + 7,;   //nX
	oSize:GetDimension("CABECALHO","XSIZE") /2.6 + 15,; //nY
	{|u| if( PCount() == 0, RetAtivo(cAtivoDe,1),;
	cAtivoDe := u ) },oDlg,;
	oSize:GetDimension("CABECALHO","XSIZE")/7,009,;
	"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,;
	"U_ZATFC001(1)", cAtivoDe,,,,.T.,.F.,,)

	oTexto4:= TSay():New(oSize:GetDimension("CABECALHO","LININI") + 9,;
	oSize:GetDimension("CABECALHO","XSIZE") /2.6 +;
	oSize:GetDimension("CABECALHO","XSIZE")/7 + 20 ,;
	{||'à'},oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,30,20)

	oAtivoAt := TGet():New( oSize:GetDimension("CABECALHO","LININI") + 7,;
	oSize:GetDimension("CABECALHO","XSIZE") /2.6 +;
	oSize:GetDimension("CABECALHO","XSIZE")/7 + 30 ,;
	{|u| if( PCount() == 0, RetAtivo(cAtivoAt,2),;
	cAtivoAt := u ) },oDlg,;
	oSize:GetDimension("CABECALHO","XSIZE")/7,;
	009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,;
	"U_ZATFC001(2)",cAtivoAt,,,,.T.,.F.,,)

	oTexto5:= TSay():New(oSize:GetDimension("CABECALHO","LININI") + 9,;
	oSize:GetDimension("CABECALHO","XSIZE") /1.4 + 10,;
	{||'Grupo:'},oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,30,20)

	oGrupo := TGet():New( oSize:GetDimension("CABECALHO","LININI") + 7,;
	oSize:GetDimension("CABECALHO","XSIZE") /1.4 + 30 ,;
	{|u| if( PCount() == 0, cGrupo, cGrupo := u ) },oDlg,;
	oSize:GetDimension("CABECALHO","XSIZE")/8 - 30,;
	009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,;
	"SNG",cGrupo,,,,.T.,.F.,,)

	oTexto6:= TSay():New(oSize:GetDimension("CABECALHO","LININI") + 9,;
	oSize:GetDimension("CABECALHO","XSIZE") /1.1 - 25,;
	{||'Localização:'},oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,30,20)

	oLocaliz := TGet():New( oSize:GetDimension("CABECALHO","LININI") + 7,;
	oSize:GetDimension("CABECALHO","XSIZE") /1.1 + 10 ,;
	{|u| if( PCount() == 0, cLocaliz, cLocaliz := u ) },oDlg,;
	oSize:GetDimension("CABECALHO","XSIZE")/8 - 30,;
	009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,;
	"SNL",cLocaliz,,,,.T.,.F.,,)



	// Cria o campo de descrição, que o usuário pode usar para filtrar por determinado termo
	oTexto5:= TSay():New(oSize:GetDimension("CABECALHO","LININI") + 25,;
	oSize:GetDimension("CABECALHO","LININI"),;
	{||'Descrição:'},oDlg,,oFont,,,,.T.,CLR_BLACK,;
	CLR_WHITE,30,20)

	oDescric := TGet():New( oSize:GetDimension("CABECALHO","LININI") + 23,;
	oSize:GetDimension("CABECALHO","LININI") + 30,;
	{|u| if( PCount() == 0, cDescric,cDescric :=u)},;
	oDlg,oSize:GetDimension("CABECALHO","XSIZE")/2.3,;
	009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,,,,;
	cDescric,,,.T.,.F.,,)


	// Cria o botão de consulta, para preencher o browse situado no lado esquerdo da tela
	TButton():New( oSize:GetDimension("CABECALHO","LININI") + 42,;
	oSize:GetDimension("CABECALHO","LININI") + 30,;
	"Consultar",oDlg,{|| FWMsgRun(,{|| PesqAtiv(Alltrim(cAtivoDe),;
	alltrim(cAtivoAt),Alltrim(cDescric),oSize),;
	oGridEsq:oBrowse:Refresh(.t.) },"Processando a consulta","Aguarde..") },60,010,,,.F.,;
	.T.,.F.,,.F.,,,.F.)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} GridEsqu
Cria e exibe o grid da esquerda.

@type function
@author João Renes
@since 27/06/2018
@version P12.1.23

@param oSize, Objeto, Objeto que representa as dimensões da tela.
@param oDlg, Objeto, Objeto que representa a Dialog.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function GridEsqu(oSize,oDlg)


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	// Cria o grid da esquerda e define que o evento relacionado ao duplo clique do mouse chamará a função MarkDesm()
	oGridEsq := MsNewGetDados():New( oSize:GetDimension("GETDADOS","LININI"),;
	oSize:GetDimension("GETDADOS","COLINI") + 10,;
	oSize:GetDimension("GETDADOS","LINEND") - 30,;
	oSize:GetDimension("GETDADOS","COLEND")/2.2,;
	GD_UPDATE,,,,{'CHECKBOL'},,,,,,oDlg,;
	{{'Imprimir','CHECKBOL','@BMP', 2,0,,,},;
	{"Filial"  ,"Filial"  ,"@!"  , 20,0},;
	{"Ativo"   ,"Ativo"   ,"@!"  ,30,0}}, aColsEsq,,)


	oGridEsq:oBrowse:bLDblClick := {||Iif(oGridEsq:oBrowse:nColPos == 1,;
	iif((LEN(aColsEsq) > 0 .AND. aColsEsq[1][2] <> "" ),;
	MarkLinh(),),;
	MoveSele(oGridEsq:nAt)),;
	oGridEsq:Refresh(.T.) }

	oGridEsq:oBrowse:bHeaderClick := {||Iif(len(aColsEsq) > 0 .AND. aColsEsq[1][2] <> "" ,;
	(lMarcou := !lMarcou,;
	iif(lMarcou == .F.,MarkTudo(),)),)}


Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} CriaBoto
Cria e exibe os botões de funções do centro da tela.

@type function
@author João Renes
@since 27/06/2018
@version P12.1.23

@param oSize, Objeto, Objeto que representa as dimensões da tela.
@param oDlg, Objeto, Objeto que representa a Dialog.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function CriaBoto(oSize,oDlg)


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	/*TButton():New( oSize:GetDimension("GETDADOS","LININI") + 50,;
	oSize:GetDimension("GETDADOS","COLEND")/2 - 30,;
	">",oDlg,{||MoveSele()},30,010,,,.F.,.T.,.F.,,.F.,,,.F.) */

	TButton():New( oSize:GetDimension("GETDADOS","YSIZE")/1.7,;
	oSize:GetDimension("GETDADOS","XSIZE")/2.1,;
	">>",oDlg,{||Iif( (LEN(aColsEsq) > 0 .AND. aColsEsq[1][2] <> "" );
	.AND. aScan(aColsEsq, {|x| AllTrim(Upper(x[1])) == 'LBOK'}) > 0,;
	(FWMsgRun(,{|| MoveTudo()},"Movendo para lista de impressão","Aguarde.."),oGridEsq:Refresh(.T.) ),;
	MsgInfo('É necessário selecionar pelo menos 1 registro para mover.','ZATFA001'))},;
	oSize:GetDimension("GETDADOS","XSIZE")/16,;
	010,,,.F.,.T.,.F.,,.F.,,,.F.)



	TButton():New( oSize:GetDimension("GETDADOS","YSIZE")/1.7 + 20,;
	oSize:GetDimension("GETDADOS","XSIZE")/2.1,;
	"<",oDlg,{||Iif(Len(oGridDir:aCols) > 0 .AND. ALLTRIM(oGridDir:aCols[1][1])<>"",FWMsgRun(,{|| LimpSele()},"Removendo da lista de impressão","Aguarde.."),MsgInfo('Não há registros para remover!','ZATFA001'))},;
	oSize:GetDimension("GETDADOS","XSIZE")/16,;
	010,,,.F.,.T.,.F.,,.F.,,,.F.)

	TButton():New( oSize:GetDimension("GETDADOS","YSIZE")/1.7 + 40,;
	oSize:GetDimension("GETDADOS","XSIZE")/2.1,;
	"<<",oDlg,{||Iif(Len(oGridDir:aCols) > 0 .AND. ALLTRIM(oGridDir:aCols[1][1])<>"",FWMsgRun(,{|| LimpGrid()},"Removendo da lista de impressão","Aguarde.."),MsgInfo('Não há registros para remover!','ZATFA001'))},;
	oSize:GetDimension("GETDADOS","XSIZE")/16,;
	010,,,.F.,.T.,.F.,,.F.,,,.F.)
Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} GridDire
Cria e exibe o grid da direita.

@type function
@author João Renes
@since 27/06/2018
@version P12.1.23

@param oSize, Objeto, Objeto que representa as dimensões da tela.
@param oDlg, Objeto, Objeto que representa a Dialog.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function GridDire(oSize,oDlg)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oGridDir := MsNewGetDados():New( oSize:GetDimension("GETDADOS","LININI"),;
	oSize:GetDimension("GETDADOS","XSIZE")/1.8,;
	oSize:GetDimension("GETDADOS","LINEND") - 	30,;
	oSize:GetDimension("GETDADOS","COLEND"),;
	GD_UPDATE,,,,,,,,,, oDlg,;
	{{"Filial"  ,"Filial"  ,"@!"  ,20,0},;
	{"Ativo"   ,"Ativo"   ,"@!"  ,30,0}},aColsDir,,,)

	oGridDir:oBrowse:bLDblClick := {||Iif(Len(oGridDir:aCols) > 0;
	.AND. ALLTRIM(oGridDir:aCols[1][1])<>"",;
	LimpSele(),;
	MsgInfo('Não há registros para remover!','ZATFA001')) }

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} BotOpcoes
Cria e exibe os botões "Imprimir" e "Fechar".

@type function
@author João Renes
@since 27/06/2018
@version P12.1.23

@param oSize, Objeto, Objeto que representa as dimensões da tela.
@param oDlg, Objeto, Objeto que representa a Dialog.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function BotOpcoes(oSize,oDlg)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	TButton():New( oSize:GetDimension("GETDADOS","LINEND") - 20,;
	oSize:GetDimension("GETDADOS","COLEND") - 70,;
	"Imprimir",oDlg,{||iif(Len(oGridDir:aCols) > 0;
	.AND. ALLTRIM(oGridDir:aCols[1][1]) <> "",ExecImpr(oGridDir:Acols),;
	MsgInfo('Para imprimir, é necessário mover os registros para o grid da direita!','ZATFA001'))},;
	30,010,,,.F.,.T.,.F.,,.F.,,,.F.)

	TButton():New( oSize:GetDimension("GETDADOS","LINEND") - 20,;
	oSize:GetDimension("GETDADOS","COLEND") - 30,;
	"Fechar",oDlg,{||oDlg:End()},30,010,,,.F.,.T.,;
	.F.,,.F.,,,.F.)

	oAtivoDe:SetFocus()
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} MarkTudo
Marca todos os registros do grid.

@type function
@author João Renes
@since 10/05/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function MarkTudo()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	For i := 1 to Len(aColsEsq)
		If aColsEsq[i][1] =='LBNO'
			aColsEsq[i][1] := 'LBOK'
		Else
			aColsEsq[i][1] := 'LBNO'
		Endif

	Next i

	oGridEsq:oBrowse:SetArray( aColsEsq,.F. )
	oGridEsq:aCols := aColsEsq
	oGridEsq:Refresh(.T.)

Return nil

/*/================================================================================================================================/*/
/*/{Protheus.doc} MarkLinh
Marca ou desmarca cada checkbox.

@type function
@author João Renes
@since 10/05/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function MarkLinh()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If aColsEsq[oGridEsq:nAt][1] == 'LBOK'
		aColsEsq[oGridEsq:nAt][1] := 'LBNO'
	Else
		aColsEsq[oGridEsq:nAt][1] := 'LBOK'
	Endif

	oGridEsq:oBrowse:SetArray( aColsEsq,.F. )
	oGridEsq:aCols := aColsEsq


Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} RetAtivo
Retorna o ativo para a criação do objeto Tget.
Criei essa rotina apenas para setar a variável que diferencia  o campo que chamou a consulta específica de ativos.

@type function
@author João Renes
@since 08/05/2018
@version P12.1.23

@param cAtivo, Caractere, Recebe o nome do campo de origem.
@param nValor, Numérico, Campo AtivoDe = 1 / Campo Ativo At =2.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Nome do campo de origem..

/*/
/*/================================================================================================================================/*/

Static Function RetAtivo(cAtivo,nValor)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	nCampOri := nValor
Return cAtivo

/*/================================================================================================================================/*/
/*/{Protheus.doc} PesqAtiv
Realiza a busca dos ativos baseada nos parâmetros informados.
O resultado será mostrado no grid da esquerda.

@type function
@author João Renes
@since 02/05/2018
@version P12.1.23

@param cAtivoDe, Caractere, Primeiro ativo do intervalo.
@param cAtivoAt, Caractere, Último ativo do intervalo.
@param cDescric, Caractere, Termo de busca.
@param oSize, Objeto, Objeto que representa as dimensões da tela.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function PesqAtiv(cAtivoDe,cAtivoAt,cDescric,oSize)
	Local aArea    := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	DbSelectArea("SN1")
	SN1->(DbGoTop())

	SN1->(DBClearFilter())

	If cFiliaDe > cFiliaAt
		MsgInfo('Verifique a ordem das filiais!','ZATFA001')
	ElseIf (cAtivoDe == "" .AND. cAtivoAt == "" .AND. cDescric == "" .AND. ALLTRIM(cGrupo) == "" .AND. ALLTRIM(cLocaliz) == "")
		MsgInfo('Informe ao menos um dos parâmetros de filtro: ativo, grupo, localização ou descrição!','ZATFA001')
	Else

		cFiltro := "SN1->N1_FILIAL >= '" + cFiliaDe + "' .AND. SN1->N1_FILIAL <= '" + cFiliaAt +;
		"' .AND. SN1->N1_QUANTD > 0 .AND. SN1->N1_STATUS <> '0'" +;
		"  .AND. SN1->N1_FILIAL$cListFil"

		If cAtivoDe <> "" .AND. cAtivoAt <> ""
			cFiltro +=  " .AND. SN1->N1_CBASE >= '"  + cAtivoDe + "' .AND. SN1->N1_CBASE <= '" + cAtivoAt + "'"
		Elseif cAtivoDe <> "" .AND. cAtivoAt == ""
			cFiltro +=  " .AND. SN1->N1_CBASE = '" +  cAtivoDe + "'"
		Elseif cAtivoDe == "" .AND. cAtivoAt <> ""
			cFiltro +=  " .AND. SN1->N1_CBASE = '" + cAtivoAt + "'"
		Endif

		If ALLTRIM(cGrupo) <> ""
			cFiltro += " .AND. SN1->N1_GRUPO = '" + cGrupo + "'"
		Endif

		If ALLTRIM(cLocaliz) <> ""
			cFiltro += " .AND. SN1->N1_LOCAL = '" + cLocaliz + "'"
		Endif

		If cDescric <> ""
			cFiltro += " .AND. '" + ALLTRIM(cDescric) + "'$SN1->N1_DESCRIC"
		Endif


		SET FILTER TO  &cFiltro

		aColsEsq := {}
		aSize(aColsEsq,0)

		SN1->(DbGotop())

		While !SN1->(EOF())
			aadd(aColsEsq,{'LBOK',ALLTRIM(SN1->N1_FILIAL), ALLTRIM(SN1->N1_CBASE) + ' - ' + ALLTRIM(SN1->N1_DESCRIC), ALLTRIM(SN1->N1_XMODPR), .F.})
			SN1->(DbSkip())
		Enddo

		IF Len(aColsEsq) > 0
			oGridEsq:oBrowse:SetArray( aColsEsq,.F. )
			oGridEsq:aCols := aColsEsq
			oGridEsq:Refresh(.T.)
		Else
			AADD(aColsEsq,{"","","","",.F.})
			oGridEsq:oBrowse:SetArray( aColsEsq,.F. )
			oGridEsq:aCols := aColsEsq
		Endif

	Endif

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ExecImpr
Executa a impressão.

@type function
@author João Renes
@since 02/05/2018
@version P12.1.23

@param aDados, Array, array com os itens presentes na grid da direita.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ExecImpr(aDados)
	Local lPosicao := .T.
	Local nTotal   := LEN(aDados)
	Local lSegue   := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF !IsPrinter2("LPT1",,1 )
		MsgInfo('A impressora não está disponível!','ZATFA001')
		lSegue := .F.
	ENDIF

	IF lSegue .And. nTotal > 0
		IF nTotal > 1 .AND. !MsgYesNo( 'Confirma a impressão das etiquetas relativas aos ' + cValToChar(nTotal) + ' ativos selecionados a direita?', 'ZATFA001')
			lSegue := .F.
		ELSE
			IF nTotal == 1 .AND.;
			Aviso( "Selecione a coluna a ser impressa:",;
			"Selecione uma das opções abaixo, para determinar em que coluna deve ser impressa a etiqueta.",;
			{ "1.Esquerda", "2.Direita"},1, "",, '', .F. ) == 1

				lPosicao := .T.
			ELSE
				lPosicao := .F.
			ENDIF
		ENDIF

		If lSegue

			aSort(aColsDir, , , {|x, y| x[2] < y[2]})
			aSort(aDados, , , {|x, y| x[2] < y[2]})

			FWMsgRun(,{|| GeraLog(aDados)},"Processando LOG da Impressão","Aguarde..")

			FWMsgRun(,{|| PrepImpr(aDados,lPosicao)},"Processando Impressão","Aguarde..")

		EndIf

	ELSEIf lSegue
		MsgInfo('Não há registros para imprimir!','ZATFA001')
	ENDIF

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} PrepImpr
Recebe um array com os itens presentes na grid da direita.

@type function
@author João Renes
@since 23/04/2018
@version P12.1.23

@param aDados, array, Array com os itens presentes na grid da direita.
@param lPosic01, logical, Indica a coluna a ser impressao.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function PrepImpr(aDados,lPosic01)
	Local cPorta   :=  "LPT1"      // endereço: \\AF-GETIN-DSIXC1\tlp2844 **OBS: NET USE LPT1 \\AF-GETIN-DSIXC1\tlp2844
	Local nX       := 0            // posição no eixo x
	Local nY       := 02           // posição no eixo y
	Local cModImpr :=  "TLP 2844"  // Modelo da impressora
	Local nTotal   := LEN(aDados)
	Local cFilia01 := ""
	Local cFilia02 := ""
	Local cEntida1 := ""          // dados para a etiqueta esquerda
	Local cAtivo01 := ""
	Local cNumPat1 := ""         // dados para a etiqueta direita
	Local cEntida2 := ""
	Local cAtivo02 := ""
	Local cNumPat2 := ""
	//Local nHandle  := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	For I := nTotal to 1 step -2

		// Verifica se é possível imprimir de 2 em 2
		IF I >= 2

			cFilia01 := aDados[I][1]
			cEntida1 := FormEntid(SUBSTR(cFilia01,0,2))
			cAtivo01 := FormPalav(SUBSTR(aDados[I][2],11, LEN(aDados[I][2]) - 10))
			cNumPat1 := SUBSTR(aDados[I][2],0,8)

			cFilia02 := aDados[I - 1][1]
			cEntida2 := FormEntid(SUBSTR(cFilia02,0,2))
			cAtivo02 := FormPalav(SUBSTR(aDados[I - 1][2],11, LEN(aDados[I - 1][2]) - 10))
			cNumPat2 :=SUBSTR(aDados[I - 1][2],0,8)

			// Imprime nas duas colunas
			nX := 13
			ImprEtiq(cModImpr,cPorta,nX,nY,;
			cFilia01,;
			cEntida1,;
			cValToChar(cAtivo01),;
			alltrim(SUBSTR(aDados[I][2],11,LEN(aDados[I][2]) - 8)),cValToChar(cNumPat1),;
			cFilia02,;
			cEntida2,;
			cValToChar(cAtivo02),;
			ALLTRIM(alltrim(SUBSTR(aDados[I - 1][2],11,LEN(aDados[I - 1][2]) - 8))),;
			cValToChar(cNumPat2))

			nY += 220
		ELSE

			IF lPosic01 == .T.
				// imprime na coluna 1
				cFilia01 := aDados[i][1]
				cEntida1 := FormEntid(SUBSTR(cFilia01,0,2))
				cAtivo01 := FormPalav(SUBSTR(aDados[I][2],11, LEN(aDados[I][2]) - 10))
				cNumPat1 := SUBSTR(aDados[I][2],0,8)

				nX := 13
				ImprEtiq(cModImpr,cPorta,nX,nY,;
				cFilia01,;
				cEntida1,;
				cValToChar(cAtivo01),;
				alltrim(SUBSTR(aDados[I][2],11,LEN(aDados[I][2]) - 8)),;
				cValToChar(cNumPat1),;
				"","","","")
			ELSE
				// imprime na coluna 2
				cFilia02 := aDados[I][1]
				cEntida2 := FormEntid(SUBSTR(cFilia02,0,2))
				cAtivo02 := FormPalav(SUBSTR(aDados[I][2],11, LEN(aDados[I][2]) - 10))
				cNumPat2 := SUBSTR(aDados[I][2],0,8)

				nX := 577
				ImprEtiq(cModImpr,cPorta,nX,nY,;
				"","","","","",;
				cFilia02,;
				cEntida2,;
				cValToChar(cAtivo02),;
				ALLTRIM(SUBSTR(aDados[I][2],11,LEN(aDados[I][2]) - 8)),;
				cValToChar(cNumPat2))
			ENDIF

			lPosic01 := !lPosic01
		ENDIF

	NEXT I

	MSCBCLOSEPRINTER()

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} FormEntid
Formata a entidade.

@type function
@author João Renes
@since 02/05/2018
@version P12.1.23

@param cParam, Caracterer, Código da entidade.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Entidade.

/*/
/*/================================================================================================================================/*/

Static Function FormEntid(cParam)
	Local cEntida := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If cParam  == "01"
		cEntida := "F I E G"
	Elseif cParam  == "02"
		cEntida := "S E S I - DR G O"
	Elseif cParam  == "03"
		cEntida := "S E N A I - DR G O"
	Elseif cParam  == "04"
		cEntida := "I E L"
	Elseif cParam  == "05"
		cEntida := "ICQ - B R A S I L"
	Endif

Return cEntida

/*/================================================================================================================================/*/
/*/{Protheus.doc} ImprEtiq
Imprime as etiquetas.

@type function
@author João Renes
@since 23/04/2018
@version P12.1.23

@param cModImpr, Recebe uma string com o modelo da impressora.
@param cPorta, Caractere, Recebe uma string a porta da impressora.
@param nX, Numérico, Recebe o valor da referência inicial no eixo x.
@param nY, Numérico, Recebe o valor da referência inicial no eixo y.
@param cFilia01, Caractere, Código da Filial.
@param cNomUn01, Caractere, Recebe o nome da entidade - lado esquerdo.
@param cDescr01, Caractere, Recebe o nome do ativo - lado esquerdo.
@param cDesCmp1, Caractere, Descrição do Campo.
@param cNumP01, Caractere, Recebe o código do ativo - lado esquerdo.
@param cFilia02, Caractere, Código da Filial.
@param cNomUn02, Caractere, Recebe o nome da entidade - lado direito.
@param cDescr02, Caractere, Recebe o nome do ativo - lado direito.
@param cDesCmp2, Caractere, Descrição do Campo.
@param cNumP02, Caractere, Recebe o código do ativo - lado direito.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ImprEtiq(cModImpr,cPorta,nX,nY,cFilia01,cNomUn01,cDescr01,cDesCmp1,cNumP01,cFilia02,cNomUn02,cDescr02,cDesCmp2,cNumP02)
	Local nDiff1    := Int((18 - Len(alltrim(cDescr01)))/2)
	Local nDiff2    := Int((18 - Len(alltrim(cDescr02)))/2)
	Local nXy       := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If nDiff1 < 2
		nDiff1 := 1
	Else
		nDiff1 += 3
	Endif

	If nDiff2 < 2
		nDiff2 := 1
	Else
		nDiff2 += 3
	Endif

	MSCBPRINTER(cModImpr,cPorta, , , .F., , , , ,,.f. , )

	MSCBFORM(.F.)//Resolvido problema na impressao da TLP 2844

	MSCBCHKSTATUS(.F.)

	MSCBBEGIN(1,6)


	// verifica se existem informações que devem ser impressas na coluna 1
	if cNomUn01 <> "" .AND. cDescr01 <> "" .AND. cNumP01 <> ""
		nX := 13
		nY := 02
		// Garante o posicionamento correto do nome da entidade
		If cNomUn01 == "F I E G"
			MSCBSAY(nX + 10,nY,cNomUn01,"N","4","1,1")
		Elseif cNomUn01 == "S E S I - DR G O"
			MSCBSAY(nX + 2,nY,cNomUn01,"N","4","1,1")
		Elseif cNomUn01 == "I E L"
			MSCBSAY(nX + 12,nY,cNomUn01,"N","4","1,1")
		Else
			MSCBSAY(nX,nY,cNomUn01,"N","4","1,1")
		Endif
		nY += 03
		MSCBSAYBAR(nX + 1,nY,cNumP01 + MSCB128B(),'N','1B',10,.F.,.F.,.F.,,2,7,,,,)
		nY += 11
		MSCBSAY(nX + nDiff1,nY,cDescr01,"N","3","0,1")
		nY += 04
		MSCBSAY(nX + 8,nY,cNumP01,"N","4","1,1")
	endif

	// verifica se existem informações que devem ser impressas na coluna 2
	if cNomUn02 <> "" .AND. cDescr02 <> "" .AND. cNumP02 <> ""
		nXy := 577
		nY := 02

		// Garante o posicionamento correto do nome da entidade
		If cNomUn02 == "F I E G"
			MSCBSAY(nXy + 10,nY,cNomUn02,"N","4","1,1")
		Elseif cNomUn02 == "S E S I - DR G O"
			MSCBSAY(nXy + 2,nY,cNomUn02,"N","4","1,1")
		Elseif cNomUn02 == "I E L"
			MSCBSAY(nXy + 12,nY,cNomUn02,"N","4","1,1")
		Else
			MSCBSAY(nXy,nY,cNomUn02,"N","4","1,1")
		Endif

		nY += 03
		MSCBSAYBAR(nXy+1,nY, cNumP02 + MSCB128B(),'N','1B',10,.F.,.F.,.F.,,2,7,,,,)
		nY += 11
		MSCBSAY(nXy + nDiff2,nY,cDescr02,"N","3","0,1")
		nY += 04
		MSCBSAY(nXy + 8,nY,cNumP02,"N","4","1,1")
	Endif

	// envia o trabalho de impressão para a impressora
	MSCBEND()

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} FormPalav
Faz os devidos ajustes para obter a descrição do patrimônio com até 18 caracteres.

@type function
@author João Renes
@since 03/05/2018
@version P12.1.23

@param cWord, characters, Nome do ativo que deverá ser ajustado.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Nome do ativo ajustado.

/*/
/*/================================================================================================================================/*/

Static Function FormPalav(cWord)
	Local nDiferen := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Garante que a string tenha no máximo 18 caracteres
	If len(cWord) > 18
		if substr(cWord,19,1) == " "
			cWord := substr(cWord,0,18)
		Elseif At(" ",cWord) > 0 .AND. At(" ",cWord) < 19
			cWord := Substr(Substr(cWord,0,18),0,Rat(" ",Substr(cWord,0,18)))
		Else
			cWord := Substr(cWord,0,18)
		Endif
	Endif

	// Centraliza a string dentro do espaço relativo aos 18 caracteres
	// ROTINA PRATICAMENTE SEM UTILIDADE! no decorrer dos teste, verifiquei;
	// que a impressora imprime na origem (x,y) independentemente da string conter espaços em branco no início
	nDiferen := 22 - len(alltrim(cWord))
	cWord := alltrim(cWord)

	If len(cWord) < 21
		while nDiferen > 1
			if mod(nDiferen,2) == 0
				cWord := Padl(cWord,22 - (nDiferen / 2), ' ')
				cWord := Padr(cWord,22, ' ')
			Else
				cWord := ' ' + cWord
			Endif

			nDiferen := 22 - len(cWord)

		Enddo
	Elseif len(cWord) == 21
		cWord := ' ' + cWord
	Endif

Return cWord

/*/================================================================================================================================/*/
/*/{Protheus.doc} MoveSele
Copia o item selecionado para o segundo grid.

@type function
@author João Renes
@since 03/05/2018
@version P12.1.23

@param nPosic, Numérico, Posição da linha na aCols.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function MoveSele(nPosic)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Len(aColsEsq) > 0 .AND. aColsEsq[1][1] <> ""
		If Len(aColsDir) == 1 .and. aColsDir[1][1] == ""
			ADEL(aColsDir,1)
			Asize(aColsDir, len(aColsDir) - 1)
		Endif

		If  aScan(aColsDir, {|x| AllTrim(Upper(x[2])) == aColsEsq[nPosic][3]}) == 0
			aadd(aColsDir,{aColsEsq[nPosic][2], aColsEsq[nPosic][3],aColsEsq[nPosic][4], .F.})
			oGridDir:oBrowse:SetArray( aColsDir,.F. )
			oGridDir:aCols := aColsDir
			oGridDir:Refresh(.t.)
		Else
			MsgInfo('O registro já existe na listagem para impressão!','ZATFA001')
		Endif

	Endif

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} LimpSele
Remove o item selecionado do segundo grid.

@type function
@author João Renes
@since 03/05/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function LimpSele()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If len(aColsDir) > 1
		ADEL(aColsDir, oGridDir:nAt)
		Asize(aColsDir, len(aColsDir) - 1)
		oGridDir:oBrowse:SetArray( aColsDir,.F. )
		oGridDir:aCols := aColsDir

	Else
		aColsDir := {}
		CriaLinha()

	Endif

	oGridDir:Refresh(.t.)

Return nil

/*/================================================================================================================================/*/
/*/{Protheus.doc} LimpGrid
Remove todos os itens do segundo grid.

@type function
@author João Renes
@since 03/05/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function LimpGrid()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If len(aColsDir) > 0
		aColsDir := {}
		CriaLinha()
		oGridDir:Refresh(.t.)

	Else
		MsgInfo('Não há registros para remover!','ZATFA001')
	Endif

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} MoveTudo
Insere no segundo grid todos os itens selecionados  no primeiro.

@type function
@author João Renes
@since 03/05/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function MoveTudo()
	Local nQtdEnc  := 0
	Local nQtd     := 0
	Local nQtdAnt  := 0
	Local aVazios  := {}
	Local nCont    := 0
	Local aAnteri  := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//Verifica se existe uma linha em branco
	If Len(aColsDir) > 0 .AND. aColsDir[1][1] == ""
		ADEL(aColsDir,1)
		Asize(aColsDir, Len(aColsDir) - 1)
	Endif

	// Busca a quantidade de itens desmarcados
	nQtdEnc := aScan(aColsEsq, {|x| AllTrim(Upper(x[1])) == 'LBNO'})

	// Caso não exista pelo menos 1 registro desmarcado, faz a cópia do array inteiro
	IF nQtdEnc == 0  .AND. Len(aColsDir) == 0
		aColsDir := aClone(aColsEsq)

		For j := 1 to Len(aColsDir)
			ADEL(aColsDir[j],1)
			Asize(aColsDir[j], Len(aColsDir[j]) - 1)
		Next j

		// Caso	exista pelo menos 1 registro desmarcado, segue 2 caminhos possíveis:
		//  1. Se Qtd registros desmarcados <  metade do array --> copia o array inteiro e remove apenas os desmarcados
		//  2. Se Qtd registros desmarcados >= metado do array --> percorre todo o array e faz a comparação registro por registro
	Else
		If nQtdEnc > 0
			While aScan(aColsEsq, {|x| AllTrim(Upper(x[1])) == 'LBNO'},nQtdEnc)   <> 0
				AADD(aVazios,{aScan(aColsEsq, {|x| AllTrim(Upper(x[1])) == 'LBNO'},nQtdEnc),.F.})
				nQtdEnc := aScan(aColsEsq, {|x| AllTrim(Upper(x[1])) == 'LBNO'},nQtdEnc) + 1
				DbSkip()
			Enddo

			If len(aVazios) < Len(aColsEsq)/2
				If Len(aColsDir) > 0
					For m := 1 to Len(aColsDir)
						AADD(aAnteri,{"",aColsDir[m][1],aColsDir[m][2],.F.})
					Next m

					aColsDir := aClone(aColsEsq)

					For z := 1 to Len(aAnteri)
						If aScan(aColsDir, {|x| AllTrim(Upper(x[3])) == aAnteri[z][3]}) == 0;
						.OR. (aScan(aColsDir, {|x| AllTrim(Upper(x[3])) == aAnteri[z][3]}) <> 0;
						.AND. aColsDir[aScan(aColsDir, {|x| AllTrim(Upper(x[3])) == aAnteri[z][3]})][1] == 'LBNO')

							AADD(aColsDir,{aAnteri[z][1],aAnteri[z][2],aAnteri[z][3],aAnteri[z][4],.F.})
						Endif
					Next z

				Else
					aColsDir := aClone(aColsEsq)
				Endif

				// Remove o campo de marcação do array que será exibido no browse da esquerda
				For k := 1 to Len(aColsDir)
					ADEL(aColsDir[k],1)
					Asize(aColsDir[k], Len(aColsDir[k]) - 1)
				Next j

				For j := 1 to len(aVazios)
					If j > 1
						ADEL(aColsDir,aVazios[j][1] - nCont)
					Else
						ADEL(aColsDir,aVazios[j][1])
					Endif
					Asize(aColsDir, Len(aColsDir) - 1)
					nCont += 1
				Next j

			Else
				For c := 1 to Len(aColsEsq)
					IF aColsEsq[c][1] == 'LBOK' .AND. aScan(aColsDir, {|x| AllTrim(Upper(x[2])) == aColsEsq[c][3]}) == 0
						AADD(aColsDir,{ALLTRIM(aColsEsq[c][2]), ALLTRIM(aColsEsq[c][3]),ALLTRIM(aColsEsq[c][4]), .F.})
					Endif
				Next c
			Endif
		Else
			For c := 1 to Len(aColsEsq)
				IF aColsEsq[c][1] == 'LBOK' .AND. aScan(aColsDir, {|x| AllTrim(Upper(x[2])) == aColsEsq[c][3]}) == 0
					AADD(aColsDir,{ALLTRIM(aColsEsq[c][2]), ALLTRIM(aColsEsq[c][3]),ALLTRIM(aColsEsq[c][4]), .F.})
				Endif
			Next c
		Endif
	Endif

	oGridDir:oBrowse:SetArray( aColsDir,.F. )
	oGridDir:aCols := aColsDir
	oGridDir:Refresh(.t.)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} CriaLinha
Cria um linha em branco. Esse procedimento foi necessário devido ao erro que estava ocorrendo ao limpar o array e setá-lo no browse.

@type function
@author João Renes
@since 17/07/2018
@version P12.1.23



@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function CriaLinha()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	AADD(aColsDir,{"","",.F.})
	oGridDir:oBrowse:SetArray( aColsDir,.F. )
	oGridDir:aCols := aColsDir
Return

/*==========================================================================|\
|| FUNÇÃO: GeraLog()          AUTOR: João Renes           Data: 09/08/2018  ||
||                                                                          ||
|| DESCRIÇAO:                                                               ||
||            Insere as informações do contexto da impressão na tabela de   ||
||            logs (ZZ6).                                                   ||
||_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _  _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _||
\===========================================================================*/


/*/================================================================================================================================/*/
/*/{Protheus.doc} GeraLog
Insere as informações do contexto da impressão na tabela de logs (ZZ6).

@type function
@author João Renes
@since 09/08/2018
@version P12.1.23

@param aDadosLOG, Array, Array com dados do log.

@obs Desenvolvimento FIEG

@history 01/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function GeraLog(aDadosLOG)
	Local _FILE            := ""
	Local _DATE            := DATE()
	Local _TIME            := TIME()
	Local _GetEnvServer    := GetEnvServer()
	Local _GetComputerName := GetComputerName()
	Local aArea := GetArea()
	Local lSegue := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DbSelectArea("ZZ6")

	Private oExcel := FWMSEXCEL():New()

	IF !ExistDir("C:\TEMP")
		IF MakeDir("C:\TEMP",NIL,.F.) != 0
			MsgStop('Erro ao tentar criar a pasta C:\TEMP no computador: ' + cValToChar(FError()), "ZATFA001")
			lSegue := .F.
		ENDIF
	ENDIF

	If lSegue

		_FILE := "ZATFA001__" + DTOS(DATE()) + "__" + SUBSTR(_TIME,1,2) + "_" + SUBSTR(_TIME,4,2) + "_" + SUBSTR(_TIME,7,2) + ".XML"

		oExcel:AddworkSheet("Etiquetas Impressas")
		oExcel:AddTable ("Etiquetas Impressas","Etiquetas Impressas")
		oExcel:AddColumn("Etiquetas Impressas","Etiquetas Impressas","Filial",1,1,.F.)
		oExcel:AddColumn("Etiquetas Impressas","Etiquetas Impressas","Ativo",1,1,.F.)
		oExcel:AddColumn("Etiquetas Impressas","Etiquetas Impressas","Modelo",1,1,.F.)

		FOR I := 1 TO LEN(aDadosLOG)
			IF RecLock('ZZ6', .T.)
				ZZ6->ZZ6_FILATI := aDadosLOG[I][1]
				ZZ6->ZZ6_CODATI := SUBSTR(aDadosLOG[I][2],1,8)
				ZZ6->ZZ6_DESATI := SUBSTR(aDadosLOG[I][2],11,LEN(aDadosLOG[I][2]) - 10)
				ZZ6->ZZ6_MODATI := aDadosLog[I][3]
				ZZ6->ZZ6_USULOG := __CUSERID
				ZZ6->ZZ6_DATLOG := _DATE
				ZZ6->ZZ6_HORLOG := _TIME
				ZZ6->ZZ6_AMBLOG := _GetEnvServer
				ZZ6->ZZ6_COMLOG := _GetComputerName


				ZZ6->(MsUnlock())
			ENDIF

			oExcel:AddRow("Etiquetas Impressas","Etiquetas Impressas",{ ;
			aDadosLOG[I][1],;
			aDadosLOG[I][2],;
			aDadosLOG[I][3];
			})
		NEXT I

		oExcel:AddworkSheet("Parâmetros da Impressão")
		oExcel:AddTable ("Parâmetros da Impressão","Parâmetros da Impressão")
		oExcel:AddColumn("Parâmetros da Impressão","Parâmetros da Impressão","L O G",1,1,.F.)
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Usuário: " + UsrFullName(__cUserID)})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Impressão: " + DTOC(_DATE) + " - " + _TIME})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Computador: " + GetComputerName()})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"IP: " + GetClientIP()})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Usuário Sistema Operacional: " + LogUserName()})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Servidor: " + GetServerIP()})
		oExcel:AddRow("Parâmetros da Impressão","Parâmetros da Impressão",{"Ambiente: " + GetEnvServer()})

		oExcel:SetFontSize(11)
		oExcel:SetFont("Times New Roman")
		oExcel:Activate()

		FWMsgRun(, {|| oExcel:GetXMLFile("C:\TEMP\" + _FILE)},"Gerando Relatório", "Aguarde..")

		IF ShellExecute("Open", "Excel", _FILE, "C:\TEMP\", 1 ) <= 32
			MsgAlert("Microsoft Excel não instalado, arquivo foi gerado no seguinte diretório: " + CRLF + CRLF + "C:\TEMP\" + _FILE,"ZATFA001")
		ENDIF

	EndIf

	RestArea(aArea)

RETURN
