#INCLUDE "rwmake.ch"   
#INCLUDE "TopConn.ch"   
#INCLUDE "protheus.ch"
#INCLUDE "totvs.ch"

#DEFINE OPT_SELECT 1
#DEFINE OPT_FROM   2
#DEFINE OPT_WHERE  3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicao do array para controle do processamento MultThread³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE ARQUIVO		 		1
#DEFINE MARCA		 	  	2
#DEFINE QTD_REGISTROS		3
#DEFINE VAR_STATUS			4

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Flag de processamento escrito no arquivo de controle ³
//³de threads                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE OK		 		"OK"
#DEFINE ERRO		 	"ERRO"

User Function SICTBA98
/*/f/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
<Descricao> : Modulo de Contabilidade Gerencial. Processamento da contabilizacao dos Restos a Pagar de Pedidos e Contratos
<Autor> : Joao Carlos A. Neto
<Data> : 02/12/2013
<Parametros> :
<Retorno> : Nil
<Processo> : Restos a Pagar
<Rotina> : Contabilidade
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : P
<Obs> :
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

Local _aArea 	:= SaveArea1({"SX3","SC7"})
Local _aCoord 	:= FWGetDialogSize(oMainWnd)
Local _cIdP1	:= ""
Local _cIdP2	:= ""
Local _aColumns	:= {}
Local _aCampos	:= {}
Local _aCpBrw	:= {}
Local _cQuery 	:= ""
Local cQuery	:= ""
Local cFiltro	:= ""
Local _N		:= 0
Local _aFilParser:={}
Local lXRPCont	:= SuperGetMv("SI_XRPCONT",.F.,.T.)

Private _oTsay1		:= Nil
Private _oTela		:= Nil
Private _oRodap		:= Nil
Private _oFont1		:= Nil 
Private _oDlg		:= Nil
Private _oMarkBrow	:= Nil
Private cMarca		:= ""
Private cFlag 		:= "S"
Private aRotina		:= MenuDef()
Private _nVlTotal	:= 0

//--------------------------------------------------------
//-- Sera utilizada na visualizacao do pedido - MATA120
//--------------------------------------------------------
PRIVATE nTipoPed	:= 1
PRIVATE cCadastro	:= OemToAnsi("Consulta ao Pedido de Compra")
PRIVATE l120Auto	:= .F.
PRIVATE aBackSC7	:= {}  

Pergunte("SICTBA98",.F.)

SetKey(VK_F12, { || Pergunte("SICTBA98",.T.) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa marca C7_OK antes da selecao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction
cQuery := " UPDATE "+RetSqlName("SC7")+" SET C7_OK = ' ' "
cQuery += " WHERE D_E_L_E_T_ = ' ' "
cQuery += " AND Substring(C7_EMISSAO,1,4) = '"+Substring(Dtos(dDataBase),1,4)+"' "
TcSqlExec(cQuery)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza flags dos restos a pagar
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " UPDATE "+RetSqlName("SC7")+" SET C7_XNOMFOR = SUBSTRING(A2_NOME,1,30) "
cQuery += " FROM " + RetSqlName("SC7") + " SC7, " + RetSqlName("SA2") + " SA2 " 
cQuery += " WHERE SC7.D_E_L_E_T_ = ' ' "
cQuery += " AND C7_XNOMFOR = ' ' "
cQuery += " AND C7_FORNECE = A2_COD "
cQuery += " AND C7_LOJA = A2_LOJA "
cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
TcSqlExec(cQuery)
End Transaction 

DEFINE FONT _oFont1 NAME "Arial" SIZE 0, -16 BOLD

//-- Dialog do Browser
DEFINE MSDIALOG _oDlg TITLE cCadastro FROM _aCoord[1],_aCoord[2] TO _aCoord[3],_aCoord[4] Pixel STYLE nOr(WS_VISIBLE,WS_POPUP)

//-- Constroi Container 
_oTela:= FWFormContainer():New(_oDlg)
	
//-- Cria os paineis dentro do Container principal 
_cIdP1 := _oTela:CreateHorizontalBox(94)		//-- MarkBrowse
_cIdP2 := _oTela:CreateHorizontalBox(06)		//-- Rodape
	
//-- Ativa Container
_oTela:Activate(_oDlg,.T.)

//-- MarkBrowser
_oMarkBrow:= FWMarkBrowse():New()
_oMarkBrow:SetAlias("SC7")
_oMarkBrow:SetDataTable(.T.)
_oMarkBrow:SetDescription(cCadastro)
_oMarkBrow:SetFieldMark("C7_OK")
_oMarkBrow:ForceQuitButton(.T.)
_oMarkBrow:SetSeeAll(.T.)

//-- Mark
_oMarkBrow:SetCustomMarkRec({|| MarkCustom() })

//-- Marca todos registros
_oMarkBrow:SetAllMark({|| MarkAll(), _oTsay1:Refresh() })

//--------------------------------
//-- Somente os campos permitido   
//-- visualizar no Browser.
//--------------------------------
aAdd(_aCampos,"C7_FILIAL"	)
aAdd(_aCampos,"C7_ITEM"		)
aAdd(_aCampos,"C7_EMISSAO"	)
aAdd(_aCampos,"C7_PRODUTO"	)
aAdd(_aCampos,"C7_QUANT"	)
aAdd(_aCampos,"C7_PRECO"	)
aAdd(_aCampos,"C7_TOTAL"	)
aAdd(_aCampos,"C7_XVLSALD"	)
aAdd(_aCampos,"C7_QUJE"		)
aAdd(_aCampos,"C7_FORNECE"	)
aAdd(_aCampos,"C7_LOJA"		)
aAdd(_aCampos,"C7_XNOMFOR"	)
aAdd(_aCampos,"C7_DATPRF"	)
aAdd(_aCampos,"C7_CONTA"	)
aAdd(_aCampos,"C7_CC"		)
aAdd(_aCampos,"C7_ITEMCTA"	)

//--------------------------------
//-- Adicionar novas colunas no 
//-- Browser   
//--------------------------------
aAdd(_aCpBrw ,"C7_XPROCES"	)
aAdd(_aCpBrw ,"C7_DTLANC"	)
aAdd(_aCpBrw ,"C7_XRESTPG"	)
aAdd(_aCpBrw ,"C7_NUM"		)

_oMarkBrow:SetAlias("SC7")

//-----------------------------------------------------
//-- Os campos que sómente está visivel no browser
//-----------------------------------------------------
_oMarkBrow:SetOnlyFields(_aCampos)

//-----------------------------------------
//-- Campos visualizados no MarkBrowse 
//-----------------------------------------
dbSelectArea("SX3")
For _n:=1 To Len(_aCpBrw)
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek(_aCpBrw[_n]))
		aAdd(_aColumns,{SX3->(X3Titulo()),&("{||"+_aCpBrw[_n]+"}"),SX3->X3_TIPO,SX3->(X3Picture()),2,SX3->X3_TAMANHO,SX3->X3_DECIMAL })
	EndIf
Next _n

//-- Seta Colunas do Browse
_oMarkBrow:SetFields(_aColumns)

//-- Legenda
_oMarkBrow:AddLegend("C7_QUANT > C7_QUJE .And. C7_QUJE == 0 .And. C7_RESIDUO <> 'S' .And. C7_XRESTPG == ' ' .And. EMPTY(C7_CONTRA)"				,"ENABLE"	,"Pedidos em Aberto")
_oMarkBrow:AddLegend("C7_QUANT > C7_QUJE .And. C7_QUJE > 0 .And. C7_RESIDUO <> 'S' .And. C7_XRESTPG == ' ' .And. EMPTY(C7_CONTRA)"				,"BR_PINK"	,"Pedidos Parcialmente Atendido")
_oMarkBrow:AddLegend("C7_QUANT > C7_QUJE .And. C7_QUJE == 0 .And. C7_RESIDUO <> 'S' .And. C7_XRESTPG == ' ' .And. .Not. EMPTY(C7_CONTRA)"	   	,"BR_BRANCO","Contratos em Aberto")
_oMarkBrow:AddLegend("C7_QUANT > C7_QUJE .And. C7_QUJE > 0 .And. C7_RESIDUO <> 'S' .And. C7_XRESTPG == ' ' .And. .Not. EMPTY(C7_CONTRA)"		,"BR_LARANJA","Contratos Parcialmente Atendido")
_oMarkBrow:AddLegend("C7_QUANT > C7_QUJE .And. C7_RESIDUO <> 'S' .And. C7_XRESTPG = '1' .AND. EMPTY(C7_CONTRA)"									,"BR_AMARELO","Pedidos Restos Pagar")
_oMarkBrow:AddLegend("C7_QUANT > C7_QUJE .And. C7_RESIDUO <> 'S' .And. C7_XRESTPG = '1' .AND. .Not. EMPTY(C7_CONTRA)"							,"BR_AZUL"	,"Contratos Restos Pagar")
_oMarkBrow:AddLegend("C7_QUANT <= C7_QUJE .Or. C7_RESIDUO == 'S'"																				,"BR_PRETO"	,"Pedidos Atendidos")
_oMarkBrow:AddLegend("C7_QUANT > C7_QUJE .And. C7_RESIDUO <> 'S' .And. C7_XRESTPG = '3'"														,"DISABLE"	,"Restos Pagar Contabilizado")

//-----------------------------------------
//-- Filtro
//-----------------------------------------
aAdd(_aFilParser,({"C7_EMISSAO","FIELD","Data Emissão Maior Igual que '%C7_EMISSAO0%'","dToS(C7_EMISSAO) >='%C7_EMISSAO0%'","dToS(C7_EMISSAO) >='%C7_EMISSAO0%'"}))
aAdd(_aFilParser,({">=","OPERATOR"}))
aAdd(_aFilParser,({"%C7_EMISSAO0%","EXPRESSION"}))

aAdd(_aFilParser,({"C7_EMISSAO","FIELD","Data Emissão Menor Igual que'%C7_EMISSAO1%'","dToS(C7_EMISSAO) <='%C7_EMISSAO1%'","dToS(C7_EMISSAO) <='%C7_EMISSAO1%'"}))
aAdd(_aFilParser,({"<=","OPERATOR"}))
aAdd(_aFilParser,({"%C7_EMISSAO1%","EXPRESSION"}))

_oMarkBrow:AddFilter("Data Emissão"	 ,"dToS(C7_EMISSAO) >= '%C7_EMISSAO0%' .And. dToS(C7_EMISSAO) <= '%C7_EMISSAO1%'",.F.,.T.,,.T.,_aFilParser,)

_oMarkBrow:AddFilter("Ano Corrente"	 ," DtoS(C7_EMISSAO) >= '"+DtoS(FirstYDate(Date()))+"' ",.F.,.T.)

// Filtro Padrão
If lXRPCont
	cFiltro := SC7->("@C7_RESIDUO<>'S' AND C7_MEDICAO='' AND C7_QUANT > (C7_QUJE+C7_QTDACLA)")
	_oMarkBrow:SetFilterDefault(cFiltro)
EndIf

//-- Ativo MarkBrowser
_oMarkBrow:Activate(_oTela:GeTPanel(_cIdP1))

//-----------------------------------------
//-- Rodapé
//-----------------------------------------
_oRodap:= _oTela:GeTPanel(_cIdP2)

//-- Total Selecionado
TSay():New(007,003,{|| "Total Selecionado R$ " },_oRodap,,_oFont1,,,,.T.,CLR_BLUE)
_oTsay1:= TSay():New(007,080,{|| Transform(_nVlTotal,"@E 999,999,999.99") },_oRodap,,_oFont1,,,,.T.,CLR_BLUE)

//-- Ativo Dialog
_oDlg:Activate()

RestArea1(_aArea)
Return


//------------------------------------------------------------------
/*/{Protheus.doc} DesMarkTd
Função chamado pela botao no browser para desmarcar todos os 
registros marcados

@author Allan da Silva Faria
@since 21/08/2015
@version 1.0
/*/
//------------------------------------------------------------------
Static Function DesMarkTd()

Local _aArea := SaveArea1({"SX3","SC7"}) 
Local _cTmp	 := GetNextAlias()

If !Empty(cMarca)

	If Select(_cTmp)>0
		dbSelectArea(_cTmp)
		(_cTmp)->(dbCloseArea())
	EndIf
	
	//-------------------------
	//-- Cria tabela temporaria
	//-- e filtra registros.
	//-------------------------
	BeginSQL Alias _cTmp
	
		SELECT R_E_C_N_O_
		FROM %table:SC7%
		WHERE %NotDel%
			AND C7_OK = %exp:cMarca%
	
	EndSQl
	
	dbSelectArea(_cTmp)
	(_cTmp)->(dbGoTop())
	
	//--------------------------
	//-- Laço para desmarcar 
	//-- registros 
	//--------------------------
	Do While (_cTmp)->(!EOF())
	
		SC7->(dbGoTo((_cTmp)->R_E_C_N_O_))	
		MarkRec()
		
		(_cTmp)->(dbSkip())
	EndDo
	(_cTmp)->(dbCloseArea())
	
	_oMarkBrow:Refresh()
	_oTsay1:Refresh()
EndIf

RestArea1(_aArea)
Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} MarkRec
Marca/Desmarca Fisicamente.
@author Allan da Silva Faria
@since 17/08/2015
@version 1.0
/*/
//------------------------------------------------------------------
Static Function MarkRec()

	//-- Marca usada
	If Empty(cMarca) 
		cMarca:=  _oMarkBrow:Mark()
	EndIf
	
	RecLock("SC7",.F.)
	If (SC7->C7_OK <> _oMarkBrow:Mark())
		_nVlTotal+= (SC7->C7_PRECO*(SC7->C7_QUANT-SC7->C7_QUJE))
		SC7->C7_OK := _oMarkBrow:Mark() 	
	ElseIf (SC7->C7_OK == _oMarkBrow:Mark())
		_nVlTotal-= (SC7->C7_PRECO*(SC7->C7_QUANT-SC7->C7_QUJE))
		SC7->C7_OK := Space(2)	
	EndIf
	SC7->(MsUnlock())
	
Return(.T.)

//------------------------------------------------------------------
/*/{Protheus.doc} MarkAll
Marca todos o Registros filtrados
@author Allan da Silva Faria
@since 17/08/2015
@version 1.0
/*/
//------------------------------------------------------------------
Static Function MarkAll()
Local _nCurrRec := _oMarkBrow:At()
Local _nLastRec := 0
Local _nLoopRec := 0

_oMarkBrow:GoBottom(.T.)
_nLastRec := _oMarkBrow:At()
_oMarkBrow:GoTop(.T.)

Do While _nLoopRec < _nLastRec
	_nLoopRec := _oMarkBrow:At()
	
	If !( SC7->C7_QUANT <= SC7->C7_QUJE .Or. SC7->C7_RESIDUO == 'S' )
		_oMarkBrow:MarkRec()
	EndIf 
		
	_oMarkBrow:GoDown(1)
EndDo

_oMarkBrow:GoTo( _nCurrRec, .T. )

Return

User Function PED_CTB98()
/*/f/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
<Descricao> : Modulo de Contabilidade Gerencial. Processamento da contabilizacao dos Restos a Pagar de Pedidos e Contratos
<Autor> : Joao Carlos A. Neto
<Data> : 02/12/2013
<Parametros> :
<Retorno> : Nil
<Processo> : Restos a Pagar
<Rotina> : Contabilidade

<Tipo> (Menu,Trigger,Vadmin	alidacao,Ponto de Entrada,Genericas,Especificas ) : P
<Obs> :
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
If MsgYesNo("Confirme a contabilização dos pedidos de Restos a Pagar marcados, continua?")
	Processa({|| OKContab(cMarca,mv_par01,mv_par02==1,mv_par03==1,Nil,1,SC7->C7_EMISSAO,dDataBase,mv_par04,mv_par05,.F.,"SC7",.F.),"Aguarde a Contabilização"})
Endif
Return

Static Function OKContab(cMarca,dDtContab,lDigita,lAglutina,oObj,nTpCtb,dDataIni,dDataFim,cFilDe,cFilAte,lEnd,cAliasSC7,lMulti)
/*/f/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
<Descricao> : Modulo de Contabilidade Gerencial. Processamento da contabilizacao dos Restos a Pagar de Pedidos e Contratos
<Autor> : Joao Carlos A. Neto
<Data> : 02/12/2013
<Parametros> :
<Retorno> : Nil
<Processo> : Restos a Pagar
<Rotina> : Contabilidade
<Tipo> (Menu,Trigger,Vadmin	alidacao,Ponto de Entrada,Genericas,Especificas ) : P
<Obs> :
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Local aArea1     := SaveArea1({"SX3","SC7","SM0","CT2"})
Local aStruSB1   := {}
Local aStruSA2   := {}
Local aStruSC7   := {}
Local aCT5       := {}
Local aOptimize  := {}
Local aFilUser   := {}
Local dSavBase   := dDataBase
Local dDataProc  := Ctod("")
Local lLctPad52  := VerPadrao("020")	// Restos a Pagar Pedido de Compra      - SC7
Local lLctPad53  := VerPadrao("030")	// Restos a Pagar Contratos				- SN9
Local lLctPad    := .F.
Local lDetProva  := .F.
Local lHeader    := .F.
Local lContinua  := .T.
Local lValido    := .F.
Local lQuery     := .F.
Local lInterface := oObj<>Nil
Local lOptimize  := .F.
Local lFirst     := .F.
Local lRetPE     := .F.
Local lCTNFEORD  := .T.
Local cLoteCtb   := ""
Local cArqCtb    := ""
Local cAliasSB1  := "SB1"
Local cAliasSA2  := "SA2"
Local cAliasBkp  := ""
Local cFornece   := ""
Local cLoja      := ""
Local cDocumento := ""
Local c652       := Nil
Local cQuery     := ""
Local cQueryOrd  := ""
Local cString    := ""
Local cKeySC7    := "C7_FILIAL+DTOS(C7_EMISSAO)+C7_NUM"
Local cArqSC7    := ""
Local cPedido    := ""
Local cKey       := ""
Local nHdlPrv    := 0
Local nTotalCtb  := 0
Local nParcCtb	 := 0
Local nOrdSC7    := 0
Local nRecSC7    := 0
Local nX         := 0
Local nY         := 0
Local nCar       := 0

Local aFlagCTB := {}
Local lUsaFlag := GetNewPar("MV_CTBFLAG",.F.)

//Variaveis para gravação do código de correlativo
Local aDiario	:= {}
Local lSeqCorr	:= FindFunction( "UsaSeqCor" ) .And. UsaSeqCor("SC7")

Local lTemMov    := .F.
Local lExecLP    := .F.
Local aSM0		 := Iif( FindFunction( "AdmAbreSM0" ) , AdmAbreSM0() , {} )
Local nContFil	  := 0
Local __cFilAnt  := cFilAnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa parametros DEFAULT                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cProcesso	:= GetMV("SI_PROCESS")
cProcesso := Soma1(cProcesso)
RecLock("SX6",.F.)
SX6->X6_CONTEUD := cProcesso
SX6->(MsUnLock())
cProcesso	:= GetMV("SI_PROCESS")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa parametros DEFAULT                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT lDigita   := .F.
DEFAULT lAglutina := .T.
DEFAULT nTpCtb    := 1
DEFAULT dDataIni  := SC7->C7_EMISSAO
DEFAULT dDataFim  := LastDay(dDataBase)
DEFAULT cFilDe    := cFilAnt
DEFAULT cFilAte   := cFilAnt
DEFAULT lEnd      := .F.
DEFAULT cAliasSC7 := "SC7"
DEFAULT lMulti    := .F.


If !CtbInUse()				/// SIGACON NÃO FAZ A MARCAÇÃO DOS FLAGS DE CONTABILIZACAO
	lUsaFlag := .F.			/// MANTEM A MARCACAO DOS FLAGS PELA ROTINA DE CONTABILIZAÇÃO
Endif

IF Len( aSM0 ) <= 0
	Help(" ",1,"NOFILIAL")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Compatibilizacao dos lancamentos contabeis                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lLctPad  := lLctPad52
lContinua := lLctPad

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da primeira regua por filiais                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lInterface
	oObj:SetRegua1(Len(aSM0))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna as Filiais do usuário corrente  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFilUser := MatFilCalc(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o log de processamento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogAtu("INICIO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Regua
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT Count(*) nQtd "
cQuery += " FROM " + RetSqlName("SC7") 
cQuery += " WHERE D_E_L_E_T_ = ' ' "
cQuery += " AND C7_OK = '"+cMarca+"' "
cQuery += " AND C7_XRESTPG = '1' "
DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "QRY", .t., .t.)
DbSelectArea("QRY")
DbGoTop()
nQtd1 := nQtd
DbCloseArea()		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza flags dos restos a pagar
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction
cQuery := " UPDATE "+RetSqlName("SC7")+" SET C7_XPROCES = '"+cProcesso+"', C7_XRESTPG = '3' "
cQuery += " WHERE D_E_L_E_T_ = ' ' "
cQuery += " AND C7_OK = '"+cMarca+"' "
cQuery += " AND C7_XRESTPG = '1' "
TcSqlExec(cQuery)
End Transaction 

ProcRegua(nQtd1)

For nContFil := 1 to Len(aSM0)
	
	If aSM0[nContFil][2] < cFilDe .Or. aSM0[nContFil][2] > cFilAte .Or. aSM0[nContFil][1] != cEmpAnt
		Loop
	EndIf
	
	If !lContinua
		Exit
	EndIf
	
	cFilAnt := aSM0[nContFil][2]
	If aScan(aFilUser,{|x| ALLTRIM(x[2]) ==  ALLTRIM(cFilAnt)}) >0 .Or. !lInterface
		
		IncProc()
		
		aCT5    := {}
		c652    := Nil
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza a regua de processamento de filiais                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lInterface
			oObj:IncRegua1("Contabilizando"+": "+aSM0[nContFil][2]+"/"+aSM0[nContFil][7])
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Contabilizando Pedido de Compra                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lLctPad52
			
			dbSelectArea("SC7")
			SC7->(dbSetOrder(3)) 

			#IFDEF TOP
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o parametro de otimizacao                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If GetNewPar("MV_OPTNFE",.F.)
					lOptimize := .T.
				EndIf
				
				If lMulti // a Query já foi realizada no processamento multhread
					cAliasSB1 := cAliasSC7
					cAliasSA2 := cAliasSC7
					lQuery := .T.
				Else
					If TcSrvType()<>"AS/400"
						lQuery := .T.
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Demonstra regua de processamento da query                    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lInterface
							If lOptimize
								oObj:IncRegua2("Executando processo de otimizacao com query")
							Else
								oObj:IncRegua2("Executando query")
							EndIf
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Montagem do Array de otimizacao de Query                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aOptimize := {}
						aadd(aOptimize,{}) //SELECT
						aadd(aOptimize,{}) //FROM
						aadd(aOptimize,{})	//WHERE
						
						If lOptimize
							cAliasSC7 := "CTBANFE"
							cAliasSB1 := "CTBANFE"
							cAliasSA2 := "CTBANFE"
						Else
							cAliasSC7 := "SC7_QRY"
							cAliasSB1 := "SC7_QRY"
							cAliasSA2 := "SC7_QRY"
						EndIf
						
						aStruSC7  := SC7->(dbStruct())
						aStruSB1  := SB1->(dbStruct())
						aStruSA2  := SA2->(dbStruct())
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Montagem da instrucao select                                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nX := 1 To Len(aStruSC7)
							aadd(aOptimize[OPT_SELECT],aStruSC7[nX])
						Next nX
						If lOptimize
							For nX := 1 To Len(aStruSA2)
								If aStruSA2[nX][1]$"A2_FILIAL,A2_COD,A2_LOJA,A2_CONTA,A2_NOME,A2_NREDUZ"
									aadd(aOptimize[OPT_SELECT],aStruSA2[nX])
								EndIf
							Next nX
							For nX := 1 To Len(aStruSB1)
								If aStruSB1[nX][1]$"B1_FILIAL,B1_COD,B1_CONTA"
									aadd(aOptimize[OPT_SELECT],aStruSB1[nX])
								EndIf
							Next nX
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Montagem da instrucao from                                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aadd(aOptimize[OPT_FROM],{RetSqlName("SC7"),"SC7"})
						aadd(aOptimize[OPT_FROM],{RetSqlName("SB1"),"SB1"})
						aadd(aOptimize[OPT_FROM],{RetSqlName("SA2"),"SA2"})
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Montagem da instrucao where                                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aOptimize[OPT_WHERE] := "SC7.C7_FILIAL='"+FWxFilial("SC7")+"' AND "
						aOptimize[OPT_WHERE] += "SUBSTRING(SC7.C7_EMISSAO,1,4) = '"+SUBSTRING(Dtos(dDataBase),1,4)+"' AND "
						aOptimize[OPT_WHERE] += "SC7.C7_XRESTPG = '3' AND " 
						aOptimize[OPT_WHERE] += "SC7.C7_OK = '"+cMarca+"' AND "
						aOptimize[OPT_WHERE] += "SC7.C7_DTLANC = '"+Dtos(Ctod(""))+"' AND "
						aOptimize[OPT_WHERE] += "SC7.D_E_L_E_T_=' ' AND "
						aOptimize[OPT_WHERE] += "SB1.B1_FILIAL='"+FWxFilial("SB1")+"' AND "
						aOptimize[OPT_WHERE] += "SB1.B1_COD=SC7.C7_PRODUTO AND "
						aOptimize[OPT_WHERE] += "SB1.D_E_L_E_T_=' ' AND "
						aOptimize[OPT_WHERE] += "SA2.A2_FILIAL='"+FWxFilial("SA2")+"' AND "
						aOptimize[OPT_WHERE] += "SA2.A2_COD = SC7.C7_FORNECE AND "
						aOptimize[OPT_WHERE] += "SA2.A2_LOJA = SC7.C7_LOJA AND "
						aOptimize[OPT_WHERE] += "SA2.D_E_L_E_T_=' ' "
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Montagem da Query                                            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cString := ""
						For nX := 1 To Len(aOptimize[OPT_SELECT])
							cString += ","+aOptimize[OPT_SELECT][nX][1]
						Next nX
						If lOptimize
							cQuery := "SELECT SC7.R_E_C_N_O_ SC7RECNO"+cString
						Else
							cQuery := "SELECT SC7.R_E_C_N_O_ SC7RECNO,"
							cQuery += "SA2.R_E_C_N_O_ SA2RECNO,"
							cQuery += "SB1.R_E_C_N_O_ SB1RECNO"+cString
						EndIf
						cString := ""
						For nX := 1 To Len(aOptimize[OPT_FROM])
							cString += ","+aOptimize[OPT_FROM][nX][1]+" "+aOptimize[OPT_FROM][nX][2]
						Next nX
						cQuery += " FROM "+SubStr(cString,2)
						cQuery += " WHERE "+aOptimize[OPT_WHERE]
						
						cQuery += " ORDER BY "+SqlOrder(SC7->(IndexKey()))+",C7_EMISSAO"
						
						cQuery := ChangeQuery(cQuery)
						
						If !lOptimize
							dbSelectArea("SC7")
							dbCloseArea()
						EndIf
						
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)
						
						For nX := 1 To Len(aOptimize[OPT_SELECT])
							If aOptimize[OPT_SELECT][nX][2]<>"C"
								TcSetField(cAliasSC7,aOptimize[OPT_SELECT][nX][1],aOptimize[OPT_SELECT][nX][2],aOptimize[OPT_SELECT][nX][3],aOptimize[OPT_SELECT][nX][4])
							EndIf
						Next nX
					Else
						dbSelectArea(cAliasSC7)
						cArqSC7 := CriaTrab(,.F.)
						cQuery  := "C7_FILIAL=='"+xFilial("SC7")+"' .AND. "
						cQuery  += "Subs(DTOS(C7_EMISSAO),1,4) = '"+Subs(Dtos(dDataBase),1,4)+"' .AND. "
						cQuery  += "C7_XRESTPG == '3' .AND. "
						cQuery  += "DTOS(C7_DTLANC) == '"+Dtos(Ctod(""))+"' "
						IndRegua("SC7",cArqSC7,cKeySC7,,cQuery)
						nOrdSC7 := RetIndex("SC7")
					Endif
				Endif
			#ENDIF
			
			#IFNDEF TOP
				dbSetIndex(cArqSC7+OrdBagExt())
			#ELSE   
				DbSelectArea("SC7")
				dbSetOrder(nOrdSC7+1)
				MsSeek(xFilial("SC7")+Dtos(dDataIni),.T.)
			#ENDIF
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Preparacao da contabilizacao por periodo                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nTpCtb == 2
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o numero do lote contabil                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SX5")
				dbSetOrder(1)
				If MsSeek(xFilial()+"09COM")
					cLoteCtb := AllTrim(X5Descri())
				Else
					cLoteCtb := "COM "
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa um execblock                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If At(UPPER("EXEC"),X5Descri()) > 0
					cLoteCtb := &(X5Descri())
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializa o arquivo de contabilizacao                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nHdlPrv:=HeadProva(cLoteCtb,"SICTBA98",Subs(cUsuario,7,6),@cArqCtb)
				IF nHdlPrv <= 0
					HELP(" ",1,"SEM_LANC")
					lContinua := .F.
				Else
					lHeader := .T.
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da segunda regua por periodo                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lInterface
				oObj:SetRegua2(dDataFim+1-dDataIni)
			EndIf
			
			dDataProc := dDataIni
			dbSelectArea(cAliasSC7)
			(cAliasSC7)->(dbGoTop())
			While ( !Eof() .And. (cAliasSC7)->C7_FILIAL == FWxFilial("SC7") .And.;
				(cAliasSC7)->C7_EMISSAO <= dDataFim .And. lContinua)
				
				lValido   := .T.
				lDetProva := .F.
				cForLj	  := (cAliasSC7)->C7_FORNECE + (cAliasSC7)->C7_LOJA
				dDtEmissao:= (cAliasSC7)->C7_EMISSAO
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se a nota nao foi contabilizada                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty((cAliasSC7)->C7_DTLANC)
					lValido := .F.
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se esta com Flag de Restos a Pagar                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cAliasSC7)->C7_XRESTPG <> '3'
					lValido := .F.
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se esta marcado                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cAliasSC7)->C7_OK <> cMarca
					lValido := .F.
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicia a contabilizacao deste documento de saida             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lValido
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona no Cabecalho do documento de saida                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lQuery
						If !lOptimize
							SC7->(MsGoto((cAliasSC7)->SC7RECNO))
						Else
							nRecSC7 := (cAliasSC7)->SC7RECNO
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Define as chaves de relacionamento SIGACTB
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lLctPad52
							c652       := CtRelation("020",.F.,{{cAliasSC7,"SC7"},{cAliasSC7,"SC7_QRY"},{cAliasSC7,"SICTBA98"}})
						Endif
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ajusta a data base com a data de contabilizacao              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Do Case
						Case nTpCtb == 1 .Or. nTpCtb == 3
//							dDataBase := IIF(dDtContab==1,(cAliasSC7)->C7_EMISSAO,dDataBase) //-- COMENTADO PELO ALLAN-J2A
						Case nTpCtb == 2
							dDataBase := dDataFim
					EndCase
					
					If lQuery
						If lUsaFlag
							aAdd(aFlagCTB,{"C7_DTLANC",dDataBase,"SC7",(cAliasSC7)->SC7RECNO,0,0,0})
						EndIf
						If lSeqCorr
							aAdd(aDiario, {"SC7",(cAliasSC7)->SC7RECNO,(cAliasSC7)->C7_DIACTB,"C7_NODIA","C7_DIACTB"} )
						EndIf
					Else
						If lUsaFlag
							aAdd(aFlagCTB,{"C7_DTLANC",dDataBase,"SC7",(cAliasSC7)->(Recno()),0,0,0})
						EndIf
						If lSeqCorr
							aAdd(aDiario, {"SC7",(cAliasSC7)->(Recno()),(cAliasSC7)->C7_DIACTB,"C7_NODIA","C7_DIACTB"})
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Preparacao da contabilizacao por documento                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Begin Transaction
					
					If 	!lHeader
			
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica o numero do lote contabil                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("SX5")
						dbSetOrder(1)
						If MsSeek(xFilial()+"09COM")
							cLoteCtb := AllTrim(X5Descri())
						Else
							cLoteCtb := "COM "
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Executa um execblock                                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If At("EXEC",Upper(X5Descri())) > 0
							cLoteCtb := &(X5Descri())
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Inicializa o arquivo de contabilizacao                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nHdlPrv:=HeadProva(cLoteCtb,"SICTBA98",Subs(cUsuario,7,6),@cArqCtb)
						IF nHdlPrv <= 0
							HELP(" ",1,"SEM_LANC")
							lContinua := .F.
						Else
							lHeader := .T.
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona registros vinculados ao Pedido de compra           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SA2")
					dbSetOrder(1)
					If lQuery .And. !lOptimize
						SA2->(MsGoto((cAliasSA2)->SA2RECNO))
					EndIf
					If !lQuery
						MsSeek(xFilial("SA2")+(cAliasSC7)->C7_FORNECE+(cAliasSC7)->C7_LOJA)
					Else
						dbSelectArea(cAliasSC7)
					EndIf
					dbSelectArea("SB1")
					dbSetOrder(1)
					If !lQuery
						MsSeek(xFilial("SB1")+(cAliasSC7)->C7_PRODUTO)
					Else
						If !lOptimize
							SB1->(MsGoto((cAliasSB1)->SB1RECNO))
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa os lancamentos contabeis ( 652 ) - Item              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lHeader
						lDetProva := .T.
						nParcCtb 	:= DetProva(nHdlPrv,"020","SICTBA98",cLoteCtb,,,,,@c652,@aCT5,,@aFlagCTB )
						If nParcCtb > 0
							nTotalCtb 	+= nParcCtb
						ElseIf Len(aFlagCTB) > 0
							aDel (aFlagCTB,Len(aFlagCTB))
							aSize(aFlagCTB,Len(aFlagCTB)-1)
						EndIf
							
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza a data de lancamento contabil para nao refaze-lo    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lDetProva .And. lHeader
						If lQuery .And. lOptimize
							SC7->(MsGoto(nRecSC7))
						EndIf
						If !lQuery
							dbSelectArea(cAliasSC7)
							dbSkip()
							nRecSC7 := RecNo()
							dbSkip(-1)
						EndIf
						If !lUsaFlag
							RecLock("SC7")
							SC7->C7_DTLANC := dDataBase
							MsUnlock()
						EndIf

						//--------------------------------
						//- Desmarca registros do Browser
						//--------------------------------
						MarkRec()

					EndIf
					End Transaction
				Else
					If !lQuery
						dbSelectArea(cAliasSC7)
						dbSkip()
						nRecSC7 := RecNo()
						dbSkip(-1)
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifico a quebra de Fornecedor                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(cAliasSC7)
				If lQuery
					dbSkip()
				Else
					MsGoto(nRecSC7)
				EndIf
				If nTpCtb == 1 .And. lHeader .And. cForLj <> (cAliasSC7)->C7_FORNECE + (cAliasSC7)->C7_LOJA					//cPedido <> (cAliasSC7)->C7_NUM
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Fecha os lancamentos contabeis                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lHeader   := .F.
					RodaProva(nHdlPrv,nTotalCtb)
					If nTotalCtb > 0
						nTotalCtb := 0
						cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB,,aDiario)
						aDiario := {}
						aFlagCTB:= {}
					EndIf
				EndIf
				dbSelectArea(cAliasSC7)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza a regua de processamento por periodo                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If dDataProc<>(cAliasSC7)->C7_EMISSAO
					While dDataProc<=(cAliasSC7)->C7_EMISSAO
						If lInterface
							oObj:IncRegua2("Pedido de Compra :"+Dtoc((cAliasSC7)->C7_EMISSAO))
						EndIf
						dDataProc++
					EndDo
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se a contabilizacao foi abortada                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lInterface .And. lEnd
					oObj:IncRegua2("Aguarde abortando execucao")
				EndIf
				
				If lEnd
					Exit
				EndIf
				
				If nTpCtb == 3 .And. (cAliasSC7)->C7_EMISSAO <> dDtEmissao //-- Contabiliza por Dia
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Fecha os lancamentos contabeis                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lHeader   := .F.
					RodaProva(nHdlPrv,nTotalCtb)
					If nTotalCtb > 0
						nTotalCtb := 0
						cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB)
					EndIf
				EndIf
				
			EndDo
			If nTpCtb == 2 .And. lHeader
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Fecha os lancamentos contabeis                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lHeader   := .F.
				RodaProva(nHdlPrv,nTotalCtb)
				If nTotalCtb > 0
					nTotalCtb := 0
					cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB)
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Retorna a situacao inicial                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lQuery
				dbSelectArea(cAliasSC7)
				dbCloseArea()
				If !lOptimize
					ChkFile("SC7")
				Else
					dbSelectArea("SC7")
				EndIf
			Else
				dbSelectArea("SC7")
				RetIndex("SC7")
				dbClearFilter()
				FErase(cArqSC7+OrdBagExt())
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a contabilizacao foi abortada                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEnd
			Exit
		EndIf
	Endif
Next nContFil 

cFilAnt := __cFilAnt
dDataBase := dSavBase
RestArea1(aArea1)
//----------------------
//-- Atualiza Browse
//----------------------
_oMarkBrow:Refresh()
_oDlg:Refresh()
Return


User Function STA_CTB98()
/*/f/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
<Descricao> : Modulo de Contabilidade Gerencial. Processamento da contabilizacao dos Restos a Pagar de Pedidos e Contratos
<Autor> : Joao Carlos A. Neto
<Data> : 02/12/2013
<Parametros> :
<Retorno> : Nil
<Processo> : Restos a Pagar
<Rotina> : Contabilidade
<Tipo> (Menu,Trigger,Vadmin	alidacao,Ponto de Entrada,Genericas,Especificas ) : P
<Obs> :
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
If MsgYesNo("Confirme a alteração do Status dos pedidos de Restos a Pagar marcados, continua?")
	If !Empty(cMarca)
		Begin Transaction
		cQuery := " UPDATE "+RetSqlName("SC7")+" SET C7_XRESTPG = CASE WHEN C7_XRESTPG = ' ' THEN '1' ELSE ' ' END "
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += " AND Substring(C7_EMISSAO,1,4) = '"+Substring(Dtos(dDataBase),1,4)+"' "
		cQuery += " AND C7_XRESTPG IN (' ','1') "
		cQuery += " AND C7_OK = '"+cMarca+"' "
		cQuery += " AND C7_QUANT > C7_QUJE "
		cQuery += " AND C7_RESIDUO <> 'S' "
		cQuery += " AND C7_DTLANC = ' ' "
		TcSqlExec(cQuery)
		End Transaction
		MsgInfo("Alteração efetuada com sucesso!!!")
		StaticCall(SICTBA98,DESMARKTD)
	Else
		MsgInfo("Não foi feito nem uma alteração!!!")
	EndIf
Endif
Return

User Function EXC_CTB98()
/*/f/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
<Descricao> : Modulo de Contabilidade Gerencial. Processamento da contabilizacao dos Restos a Pagar de Pedidos e Contratos
<Autor> : Joao Carlos A. Neto
<Data> : 02/12/2013
<Parametros> :
<Retorno> : Nil
<Processo> : Restos a Pagar
<Rotina> : Contabilidade
<Tipo> (Menu,Trigger,Vadmin	alidacao,Ponto de Entrada,Genericas,Especificas ) : P
<Obs> :   	
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Local cProcesso := Space(6)
Local _lFechar  := .T.
Local nOpca     := 0

If MsgYesNo("Confirme reversão dos lançamentos contábeis dos pedidos de Restos a Pagar marcados. "+CHR(10)+CHR(13)+;
			"Caso tenha contabilizado pela DataBase, ajuste a mesma para a data dos lançamentos contábeis que se deseja excluir" , "continua?")

	DEFINE MSDIALOG oDlg FROM 10, 10 TO 18, 60 TITLE "Número do Processo Contábil"

	@	0.3,1 TO 3 ,23.9 OF oDlg
	@	1.0,2 	Say "Nro Processo: "
	@	1.0,8	MSGET cProcesso Picture "@!"   HASBUTTON

	DEFINE SBUTTON FROM 046,120	TYPE 1 ACTION (nOpca := 1, _lFechar := .T., IIf(!Empty(cProcesso), oDlg:End(),_lFechar := .F.)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 046,160	TYPE 2 ACTION (nOpca := 0, oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED VALID _lFechar

	If nOpca == 0
		Return
	Endif	

	Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estorno da contabilizacoa dos pedidos SC7                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " UPDATE "+RetSqlName("SC7")+" SET C7_XRESTPG = '1', C7_DTLANC = ' ', C7_XPROCES = ' ' "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND Substring(C7_EMISSAO,1,4) = '"+Substring(Dtos(dDataBase),1,4)+"' "
	cQuery += " AND C7_XPROCES = '"+cProcesso+"' "
	cQuery += " AND C7_XRESTPG = '3' "
	cQuery += " AND C7_DTLANC <> ' ' "
	TcSqlExec(cQuery)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclusão dos Lançamentos Contábeis                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " UPDATE "+RetSqlName("CT2")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND CT2_ROTINA = 'SICTBA98' "
	cQuery += " AND CT2_LP = '020' "
	cQuery += " AND CT2_ATIVDE = '"+cProcesso+"' "
	TcSqlExec(cQuery)
	End Transaction
	
	MsgInfo("Alteração efetuada com sucesso!!!")
	
Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkCustom
Função tem a finalidade de marcar/desmarcar itens do mesmo pedido.

@author Allan da Silva Faria
@since 12/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MarkCustom()
Local _aAliasC7 := GetArea()
Local _nCurrRec := _oMarkBrow:At()
Local _lMark	:= _oMarkBrow:IsMark()
Local _cTmp		:= GetNextAlias()

If IsInCallStack("MarkAll")
	MarkRec()
Else
	If ( SC7->C7_QUANT <= SC7->C7_QUJE .Or. SC7->C7_RESIDUO == 'S' )
		Alert("Itens sem saldo ou foi eliminado residuo!")
		Return Nil
	EndIf
	
	//----------------------------------
	//-- Fecha Area de trabalho
	//----------------------------------
	If Select(_cTmp)>0
		dbSelectArea(_cTmp)
		(_cTmp)->(dbCloseArea())
	EndIf
	
	//-------------------------------------------------
	//-- Consulta a quantidade de itens do pedido
	//-------------------------------------------------
	BeginSQL Alias _cTmp
		SELECT COUNT(*) AS QTD
		FROM %table:SC7% 
		WHERE %notDel%
			AND C7_FILIAL = %exp:SC7->C7_FILIAL%
			AND C7_NUM = %exp:SC7->C7_NUM%
			AND C7_XRESTPG = %exp:SC7->C7_XRESTPG%
			AND C7_RESIDUO <> 'S'
			AND C7_QUANT > C7_QUJE
	EndSql
	
	dbSelectArea(_cTmp)
	
	//-------------------------------------------------
	//-- Se existe mais de um item no pedido
	//-------------------------------------------------
	If ( (_cTmp)->QTD > 1 )
	
		//-------------------------------------------------
		//-- Pergunta para o usuário se marca todos os 
		//-- itens do pedido
		//-------------------------------------------------
		If ( Aviso("Atenção",IIF(!_lMark,"Marcar","Desmarcar")+" Todos os Itens do Pedido?",{"Sim","Não"}) == 1 )
	
			cChaveSc7 := SC7->C7_FILIAL+SC7->C7_NUM
			SC7->(dbSetOrder(1))
			SC7->(dbSeek(cChaveSc7))       
			Do While ( SC7->(!Eof()) .and. SC7->C7_FILIAL+SC7->C7_NUM == cChaveSc7 )
				//----------------------------------------------
				//-- Checa se itens se existe saldos e 
				//-- não foi eliminado residuo
				//----------------------------------------------
				If !( SC7->C7_QUANT <= SC7->C7_QUJE .Or. SC7->C7_RESIDUO == 'S' )
					
					If (!_lMark .AND. SC7->C7_OK <> _oMarkBrow:Mark())  
						MarkRec()
					ElseIf (_lMark .AND. SC7->C7_OK == _oMarkBrow:Mark())
						MarkRec()
					EndIf
					
				EndIf
				SC7->(dbSkip())
			EndDo	
		_oMarkBrow:GoTo( _nCurrRec, .T. ) 
		Else
			MarkRec()	
		EndIf
	Else
		MarkRec()
	EndIf
	(_cTmp)->(dbCloseArea())	
EndIF

RestArea(_aAliasC7)            
Return .T.

Static Function AjustaSX1()
/*/f/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
<Descricao> : Modulo de Contabilidade Gerencial. Processamento da contabilizacao dos Restos a Pagar de Pedidos e Contratos
<Autor> : Joao Carlos A. Neto
<Data> : 02/12/2013
<Parametros> :
<Retorno> : Nil
<Processo> : Restos a Pagar
<Rotina> : Contabilidade
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : P
<Obs> :
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Local aAreaAnt := GetArea()
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}
Local cPerg	   := "SICTBA98"

//---------------------------------------MV_PAR01--------------------------------------------------
aHelpPor := {"Data da geração dos lançamentos contábeis"}
aHelpEng := {"Data da geração dos lançamentos contábeis"}
aHelpSpa := {"Data da geração dos lançamentos contábeis"}
PutSX1(cPerg,"01","Contabiliza","Contabiliza","Contabiliza","mv_ch1","N",1,0,1,"C","","","","N","mv_par01","Emissao","Emissao","Emissao","","DataBase","DataBase","DataBase","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//---------------------------------------MV_PAR02--------------------------------------------------
aHelpPor := {"Mostra lançamento Contábil?"}
aHelpEng := {"Mostra lançamento Contábil?"}
aHelpSpa := {"Mostra lançamento Contábil?"}
PutSX1(cPerg,"02","Mostra Lançamento?","Mostra Lançamento?","Mostra Lançamento?","mv_ch2","N",1,0,1,"C","","","","N","mv_par02","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//---------------------------------------MV_PAR03--------------------------------------------------
aHelpPor := {"Aglutina Lançamentos Contábeis?"}
aHelpEng := {"Aglutina Lançamentos Contábeis?"}
aHelpSpa := {"Aglutina Lançamentos Contábeis?"}
PutSX1(cPerg,"03","Aglut Lanc Contabil?","Aglut Lanc Contabil?","Aglut Lanc Contabil?","mv_ch3","N",1,0,1,"C","","","","N","mv_par03","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//---------------------------------------MV_PAR04--------------------------------------------------
aHelpPor := {"Filial inicial a ser considerada na","geracao dos lançamentos contábeis"}
aHelpEng := {"Filial inicial a ser considerada na","geracao dos lançamentos contábeis"}
aHelpSpa := {"Filial inicial a ser considerada na","geracao dos lançamentos contábeis"}
PutSX1(cPerg,"04","Da Filial","Da Filial","Da Filial","mv_ch4","C",8,0,0,"G","","","","N","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SM0_01","","033",aHelpPor,aHelpEng,aHelpSpa)

//---------------------------------------MV_PAR05--------------------------------------------------
aHelpPor := {"Filial final a ser considerada na","geracao dos lançamentos contábeis"}
aHelpEng := {"Filial final a ser considerada na","geracao dos lançamentos contábeis"}
aHelpSpa := {"Filial final a ser considerada na","geracao dos lançamentos contábeis"}
PutSX1(cPerg,"05","Ate a Filial","Ate a Filial","Ate a Filial","mv_ch5","C",8,0,0,"G","","","","N","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SM0_01","","033",aHelpPor,aHelpEng,aHelpSpa)

RestArea(aAreaAnt)
Return

Static Function MenuDef()
/*/f/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
<Descricao> : Modulo de Contabilidade Gerencial. Processamento da contabilizacao dos Restos a Pagar de Pedidos e Contratos
<Autor> : Joao Carlos A. Neto
<Data> : 02/12/2013
<Parametros> :
<Retorno> : Nil
<Processo> : Restos a Pagar
<Rotina> : Contabilidade
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : P
<Obs> :
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

aRotina :=	{	{"Contabilizar"			,"U_PED_CTB98"	,0,4,0,.F.},;
				{"Desmarcar Todos"		,"StaticCall(SICTBA98,DESMARKTD)"  	,0,4,0,.F.},;
				{"Pesquisar"			,"AxPesqui"  	,0,2,0,.F.},;
				{"Visualizar"			,"A120Pedido"  	,0,2,0,.F.},;
				{"Imprimir"				,"U_SICTBR50"   ,0,2,0,.T.},;
				{"Altera Status"		,"U_STA_CTB98"  ,0,5,0,.T.},;
				{"Excluir Contabil"		,"U_EXC_CTB98"  ,0,6,0,.T.},;
				{"Parametros	"		,"U_PAR_CTB98"  ,0,7,0,.T.}}

Return(aRotina)


User Function PAR_CTB98()
/*/f/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
<Descricao> : Modulo de Contabilidade Gerencial. Processamento da contabilizacao dos Restos a Pagar de Pedidos e Contratos
<Autor> : Joao Carlos A. Neto
<Data> : 02/12/2013
<Parametros> :
<Retorno> : Nil
<Processo> : Restos a Pagar
<Rotina> : Contabilidade
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : P
<Obs> :
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
AjustaSX1()

Pergunte("SICTBA98",.T.)

Return()