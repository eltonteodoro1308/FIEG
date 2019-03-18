#INCLUDE "rwmake.ch"   
#INCLUDE "TopConn.ch"   
#INCLUDE "protheus.ch"

#DEFINE OPT_SELECT 1
#DEFINE OPT_FROM   2
#DEFINE OPT_WHERE  3

#DEFINE POS_CN9FIL 1
#DEFINE POS_CN9NUM 2
#DEFINE POS_CN9REV 3
#DEFINE POS_CNBNUM 4
#DEFINE POS_CNBCCU 5
#DEFINE POS_CNBCON 6
#DEFINE POS_CNBITC 7
#DEFINE POS_CN9VLA 8

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

/*/f/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
<Descricao> : Modulo de Contabilidade Gerencial. Processamento da contabilizacao dos Restos a Pagar de Contratos
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
User Function SICTBA99
	Local _aArea 	:= SaveArea1({"SX3","CN9"})
	Local _aCoord 	:= FWGetDialogSize(oMainWnd)
	Local _cIdP1	:= ""
	Local _cIdP2	:= ""
	Local _aColumns	:= {}
	Local _aCampos	:= {}
	Local _aCpBrw	:= {}
	Local _cQuery 	:= ""
	Local _n		:= 0
	Local _aFilParser:={}
	Local cXFiltro	:= SuperGetMV("SI_XPAR99A",.F.,"")
	Local nAlign	:= 0
	Local nAlignC	:= 0
	Local nAlignL	:= 1
	Local nAlignR	:= 2
	Local lXRPCont	:= SuperGetMv("SI_XRPCONT",.F.,.T.)
	Private _oTsay1		:= Nil
	Private _oTsay2		:= Nil
	Private _oTela		:= Nil
	Private _oRodap		:= Nil
	Private _oFont1		:= Nil 
	Private _oDlg		:= Nil
	Private _oMarkBrow	:= Nil
	Private cMarca		:= ""
	Private cFlag 		:= "S"
	Private aRotina		:= MenuDef()
	Private cCadastro 	:= OemToAnsi("Restos a Pagar | Contratos")
	Private _nVlTotal	:= 0
	Private nTipoPed	:= 1
	Private l120Auto	:= .F.
	Private aBackSC7	:= {}  
	Private	nQtdCont	:= 0
	Private	nValCont	:= 0
	Private	nCNBControl := 0
	Private aCNBControl	:= {}
	Private aCNBCtr2	:= {}
	Private cCN9CtrNum	:= ""
	Private cCNBCtrNum	:= "" 
	Private cCNBCtrCC	:= ""
	Private cCNBCtrCo	:= ""
	Private cCNBCtrIC	:= ""
	Private lXContErro	:= .F.
	
	// Valida se o colaborador possui permissão para acessar a rotina
	If fXAccessOK()
		
		// Inicializa Variáveis
		nQtdCont := 0
		nValCont := 0
		
		Pergunte("SICTBA98",.F.)
		
		// Seta Tecla F12
		SetKey(VK_F12, { || Pergunte("SICTBA98",.T.) } )
		
		// Limpa marca CN9_XOK antes da selecao
		MsAguarde( { || fUpdCN9OK() } , NIL , "Carregando Contratos. Aguarde..." )
		
		DEFINE FONT _oFont1 NAME "Arial" SIZE 0, -14 BOLD
		
		// Dialog do Browser
		DEFINE MSDIALOG _oDlg TITLE cCadastro FROM _aCoord[1],_aCoord[2] TO _aCoord[3],_aCoord[4] Pixel STYLE nOr(WS_VISIBLE,WS_POPUP)
		
		// Constroi Container 
		_oTela:= FWFormContainer():New(_oDlg)
			
		// Cria os paineis dentro do Container principal 
		_cIdP1 := _oTela:CreateHorizontalBox(90)		//-- MarkBrowse
		_cIdP2 := _oTela:CreateHorizontalBox(10)		//-- Rodape
			
		// Ativa Container
		_oTela:Activate(_oDlg,.T.)
		
		// MarkBrowser
		_oMarkBrow:= FWMarkBrowse():New()
		_oMarkBrow:SetAlias("CN9")
		_oMarkBrow:SetDataTable(.T.)
		_oMarkBrow:SetDescription(cCadastro)
		_oMarkBrow:SetFieldMark("CN9_XOK")
		_oMarkBrow:ForceQuitButton(.T.)
		_oMarkBrow:SetSeeAll(.T.)
		
		// Mark
		_oMarkBrow:SetCustomMarkRec({|| MarkCustom() })
		
		// Marca todos registros
		_oMarkBrow:SetAllMark({|| MarkAll(), fUpdRodape() })
		
		// Somente os campos permitido visualizar no Browser.
		_aCampos := {}
		aAdd(_aCampos,"CN9_FILIAL"	)

		// Os campos que sómente está visivel no browser
		_oMarkBrow:SetOnlyFields(_aCampos)		
		
		// Adicionar novas colunas no Browser   
		aAdd(_aCpBrw,"CN9_NUMERO"	)
		aAdd(_aCpBrw,"CN9_REVISA"	)
		aAdd(_aCpBrw,"CN9_DESCRI"	)		
		aAdd(_aCpBrw,"CN9_VLATU "	)
		aAdd(_aCpBrw,"CN9_SALDO "	)
		aAdd(_aCpBrw ,"CN9_XRESTV"	)		
		aAdd(_aCpBrw ,"CN9_XRESTP"	)				
		aAdd(_aCpBrw ,"CN9_XPROCE"	)
		aAdd(_aCpBrw ,"CN9_XDTLAN"	)

		// Campos visualizados no MarkBrowse 
		For _n := 1 to Len(_aCpBrw)
			Iif((Alltrim(_aCpBrw[_n])=="CN9_DESCRI"),nAlign:=nAlignL,nAlign:=nAlignR)
			aAdd(_aColumns,{GetSx3Cache(_aCpBrw[_n],"X3_TITULO"),&("{||"+_aCpBrw[_n]+"}"),GetSx3Cache(_aCpBrw[_n],"X3_TIPO"),GetSx3Cache(_aCpBrw[_n],"X3_PICTURE"),nAlign,GetSx3Cache(_aCpBrw[_n],"X3_TAMANHO"),GetSx3Cache(_aCpBrw[_n],"X3_DECIMAL") })
		Next
		
		// Seta Colunas do Browse
		_oMarkBrow:SetFields(_aColumns)

		// Filtro Padrão
		_oMarkBrow:SetFilterDefault("CN9_XRESTP <> ' ' .OR. (CN9_XREGP <> '1' .AND. CN9_SITUAC $ '05' .AND. CN9_SALDO > 0)"+cXFiltro) // Somente Contratos Vigentes
		
		// Legenda
		_oMarkBrow:AddLegend("CN9_SALDO > 0 .AND. Empty(CN9_XPROCE) .AND. Empty(CN9_XRESTP) ","ENABLE","Contrato Vigente")
		_oMarkBrow:AddLegend("CN9_SALDO <= 0 .AND. !Empty(CN9_XPROCE) .AND. CN9_XRESTP $ 'T' ","BR_PRETO","Cont. RP Total - Sem Saldo - CTB")
		_oMarkBrow:AddLegend("CN9_SALDO <= 0 .AND. !Empty(CN9_XPROCE) .AND. CN9_XRESTP $ 'P' ","BR_CINZA","Cont. RP Parcial - Sem Saldo - CTB")
		_oMarkBrow:AddLegend("CN9_SALDO > 0 .AND. !Empty(CN9_XPROCE) .AND. CN9_XRESTP $ 'T' ","BR_BRANCO","Cont. RP Total - CTB")
		_oMarkBrow:AddLegend("CN9_SALDO > 0 .AND. !Empty(CN9_XPROCE) .AND. CN9_XRESTP $ 'P' ","BR_AMARELO","Cont. RP Parcial - CTB")
		_oMarkBrow:AddLegend("CN9_SALDO > 0 .AND. Empty(CN9_XPROCE) .AND. CN9_XRESTP $ 'T' ","BR_VERMELHO","Cont. RP Total - Não CTB")
		_oMarkBrow:AddLegend("CN9_SALDO > 0 .AND. Empty(CN9_XPROCE) .AND. CN9_XRESTP $ 'P' ","BR_LARANJA","Cont. RP Parcial - Não CTB")

		
		// Filtro
		/*
		aAdd(_aFilParser,({"C7_EMISSAO","FIELD","Data Emissão Maior Igual que '%C7_EMISSAO0%'","dToS(C7_EMISSAO) >='%C7_EMISSAO0%'","dToS(C7_EMISSAO) >='%C7_EMISSAO0%'"}))
		aAdd(_aFilParser,({">=","OPERATOR"}))
		aAdd(_aFilParser,({"%C7_EMISSAO0%","EXPRESSION"}))
		
		aAdd(_aFilParser,({"C7_EMISSAO","FIELD","Data Emissão Menor Igual que'%C7_EMISSAO1%'","dToS(C7_EMISSAO) <='%C7_EMISSAO1%'","dToS(C7_EMISSAO) <='%C7_EMISSAO1%'"}))
		aAdd(_aFilParser,({"<=","OPERATOR"}))
		aAdd(_aFilParser,({"%C7_EMISSAO1%","EXPRESSION"}))
		
		_oMarkBrow:AddFilter("Data Emissão"	 ,"dToS(C7_EMISSAO) >= '%C7_EMISSAO0%' .And. dToS(C7_EMISSAO) <= '%C7_EMISSAO1%'",.F.,.T.,,.T.,_aFilParser,)
		
		_oMarkBrow:AddFilter("Ano Corrente"	 ,"YEAR(C7_EMISSAO) == YEAR(dDataBase)",.F.,.T.)
		*/
		
		aAdd(_aFilParser,({"CN9_FILIAL","FIELD","Filial Igual '%CN9_FILIAL0%'","CN9_FILIAL == '%CN9_FILIAL0%'","CN9_FILIAL == '%CN9_FILIAL0%'"}))
		aAdd(_aFilParser,({"==","OPERATOR"}))
		aAdd(_aFilParser,({"%CN9_FILIAL0%","EXPRESSION"}))
		
		_oMarkBrow:AddFilter("Filial"	 ,"CN9_FILIAL == '%CN9_FILIAL0%'",.F.,.T.,,.T.,_aFilParser,)
		_oMarkBrow:AddFilter("Dt Inicio Ano Corrente"	 ,' DtoS(CN9_DTINIC) >= "'+DtoS(FirstYDate(dDatabase))+'" ',.F.,.T.,"CN9")
		
		// Ativo MarkBrowser
		_oMarkBrow:Activate(_oTela:GeTPanel(_cIdP1))
		
		// Rodapé
		_oRodap:= _oTela:GeTPanel(_cIdP2)
		
		// Cria Says do Rodapé
		fUpdRodape(.T.)
				
		// Ativo Dialog
		_oDlg:Activate()
	
	Else
	
		Alert("Usuário não possui acesso ou a rotina não está habilitada. Favor verificar parâmetro [SI_XRPCONT]")
	
	EndIf
	
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
	Local _aArea := SaveArea1({"SX3","CN9"}) 
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
			FROM %table:SC9%
			WHERE %NotDel%
				AND CN9_XOK = %exp:cMarca%
		EndSQl
		
		dbSelectArea(_cTmp)
		(_cTmp)->(dbGoTop())
		
		//--------------------------
		//-- Laço para desmarcar 
		//-- registros 
		//--------------------------
		Do While (_cTmp)->(!EOF())
		
			CN9->(dbGoTo((_cTmp)->R_E_C_N_O_))	
			MarkRec()
			
			(_cTmp)->(dbSkip())
		EndDo
		(_cTmp)->(dbCloseArea())
		
		_oMarkBrow:Refresh()
		
		// Atualiza Rodapé
		nQtdCont := 0
		nValCont := 0
		fUpdRodape()
		
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
	
	RecLock("CN9",.F.)
	If (CN9->CN9_XOK <> _oMarkBrow:Mark())
		_nVlTotal+= (CN9->CN9_XRESTV)
		CN9->CN9_XOK := _oMarkBrow:Mark() 	
	ElseIf (CN9->CN9_XOK == _oMarkBrow:Mark())
		_nVlTotal-= (CN9->CN9_XRESTV)
		CN9->CN9_XOK := Space(2)	
	EndIf
	CN9->(MsUnlock())
	
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
	
	If !( CN9->C7_QUANT <= CN9->C7_QUJE .Or. CN9->C7_RESIDUO == 'S' )
		_oMarkBrow:MarkRec()
	EndIf 
		
	_oMarkBrow:GoDown(1)
EndDo

_oMarkBrow:GoTo( _nCurrRec, .T. )

Return


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
User Function CN_CTB99()

	If MsgYesNo("Confirme a contabilização dos contratos de Restos a Pagar marcados, continua?")
		
		// Chama tela de parâmetros
		U_PAR_CTB98()
		Processa({|| OKContab99(cMarca,mv_par01,mv_par02==1,mv_par03==1,Nil,1,,dDataBase,mv_par04,mv_par05,.F.,"CN9",.F.),"Aguarde a Contabilização"})
		
	Endif

Return


/*/{Protheus.doc} OKContab99
// Função para realizar contabilização dos contratos
@author danielflavio
@since 26/11/2018
@version 1.0
@return ${return}, ${return_description}
@param cMarca, characters, descricao
@param dDtContab, date, descricao
@param lDigita, logical, descricao
@param lAglutina, logical, descricao
@param oObj, object, descricao
@param nTpCtb, numeric, descricao
@param dDataIni, date, descricao
@param dDataFim, date, descricao
@param cFilDe, characters, descricao
@param cFilAte, characters, descricao
@param lEnd, logical, descricao
@param cAliasCN9, characters, descricao
@param lMulti, logical, descricao
@type static function
/*/
Static Function OKContab99(cMarca,dDtContab,lDigita,lAglutina,oObj,nTpCtb,dDataIni,dDataFim,cFilDe,cFilAte,lEnd,cAliasCN9,lMulti)
	Local aArea1     := SaveArea1({"SX3","CN9","SM0","CT2"})
	Local aStruSB1   := {}
	Local aStruSA2   := {}
	Local aStruCN9   := {}
	Local aStruCNA   := {}
	Local aStruCNB   := {}
	Local aStruCNE   := {}
	Local aCT5       := {}
	Local aOptimize  := {}
	Local aFilUser   := {}
	Local dSavBase   := dDataBase
	Local dDataProc  := Ctod("")
	Local lLctPadSI  := VerPadrao("030")	// Restos a Pagar Contratos				- CN9
	Local lLctPad    := .F.
	Local lDetProva  := .F.
	Local lHeader    := .F.
	Local lContinua  := .T.
	Local lValido    := .F.
	Local lQuery     := .F.
	Local lInterface := oObj<>Nil
	Local lFirst     := .F.
	Local lRetPE     := .F.
	Local lCTNFEORD  := .T.
	Local cLoteCtb   := ""
	Local cArqCtb    := ""
	Local cAliasSB1  := "SB1"
	Local cAliasSA2  := "SA2"
	Local cAliasCNB	 := "CNB"
	Local cAliasBkp  := ""
	Local cFornece   := ""
	Local cLoja      := ""
	Local cDocumento := ""
	Local c652       := Nil
	Local cQuery     := ""
	Local cQueryOrd  := ""
	Local cString    := ""
	Local cKeyCN9    := "CN9_FILIAL+CN9_NUMERO+CN9_REVISA"
	Local cArqCN9    := ""
	Local cPedido    := ""
	Local cKey       := ""
	Local nHdlPrv    := 0
	Local nTotalCtb  := 0
	Local nParcCtb	 := 0
	Local nOrdCN9    := 0
	Local nRecCN9    := 0
	Local nX         := 0
	Local nY         := 0
	Local nCar       := 0
	Local aFlagCTB := {}
	Local lUsaFlag := GetNewPar("MV_CTBFLAG",.F.)
	Local aXAuxArea	:= {}
	
	//Variaveis para gravação do código de correlativo
	Local aDiario	:= {}
	Local lSeqCorr	:= FindFunction( "UsaSeqCor" ) .And. UsaSeqCor("CN9")
	
	Local lTemMov    := .F.
	Local lExecLP    := .F.
	Local aSM0		 := Iif( FindFunction( "AdmAbreSM0" ) , AdmAbreSM0() , {} )
	Local nContFil	  := 0
	Local __cFilAnt  := cFilAnt
	Local nA		 := 0
	Local cContOld	 := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa parametros DEFAULT                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cProcesso	:= GetMV("SI_PROCESS")
	Default cAliasCN9	 := "CN9"
	
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
	DEFAULT dDataIni  := FirstDay(dDataBase) //CN9->C7_EMISSAO
	DEFAULT dDataFim  := LastDay(dDataBase)
	DEFAULT cFilDe    := cFilAnt
	DEFAULT cFilAte   := cFilAnt
	DEFAULT lEnd      := .F.
	DEFAULT lMulti    := .F.
	DEFAULT cAliasCN9 := "CN9"
	
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
	lLctPad  := lLctPadSI
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
	cQuery += " FROM " + RetSqlName("CN9")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND CN9_XOK = '"+cMarca+"' "
	cQuery += " AND CN9_XRESTP IN ('T','P') "
	cQuery += " AND CN9_XPROCE = ' ' "
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "QRY", .t., .t.)
	DbSelectArea("QRY")
	DbGoTop()
	nQtd1 := nQtd
	DbCloseArea()		
	
	ProcRegua(nQtd1)
	
	For nContFil := 1 to Len(aSM0)

		// 
		If Select(cAliasCN9) > 0
			(cAliasCN9)->(dbCloseArea())
		EndIf

		// Ajusta Variável
		nCNBControl := 0
		aCNBControl	:= {}
		aCNBCtr2	:= {}
		cCN9CtrNum	:= ""
		cCNBCtrNum	:= "" 
		cCNBCtrCC	:= ""
		cCNBCtrCo	:= ""
		cCNBCtrIC	:= ""	
	
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
			If lLctPadSI
				
				dbSelectArea("CN9")
				CN9->(dbSetOrder(1)) 
	
				#IFDEF TOP
					
					If lMulti // a Query já foi realizada no processamento multhread
						cAliasSB1 := cAliasCN9
						cAliasSA2 := cAliasCN9
						cAliasCNB := cAliasCN9
						lQuery := .T.
					Else
					
						If TcSrvType()<>"AS/400"
							lQuery := .T.
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Demonstra regua de processamento da query                    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lInterface
								oObj:IncRegua2("Executando query")
							EndIf
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Montagem do Array de otimizacao de Query                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aOptimize := {}
							aadd(aOptimize,{}) //SELECT
							aadd(aOptimize,{}) //FROM
							aadd(aOptimize,{})	//WHERE
							
							cAliasCN9 := "CN9_QRY"
							cAliasSB1 := "CN9_QRY"
							cAliasSA2 := "CN9_QRY"
							cAliasCNB := "CN9_QRY"
							
							aStruCN9  := CN9->(dbStruct())
							aStruCNA  := CNA->(dbStruct())
							aStruCNB  := CNB->(dbStruct())
							aStruCNE  := CNE->(dbStruct())
							aStruSB1  := SB1->(dbStruct())
							aStruSA2  := SA2->(dbStruct())
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Montagem da instrucao select                                 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							For nX := 1 To Len(aStruCN9)
								If aStruCN9[nX][1]$"CN9_FILIAL,CN9_NUMERO,CN9_REVISA,CN9_XDTLAN,CN9_XRESTP,CN9_XRESPT,CN9_XOK,CN9_DIACTB,CN9_NODIA,CN9_VLATU"
									aadd(aOptimize[OPT_SELECT],aStruCN9[nX])
								EndIf							

							Next nX

							For nX := 1 To Len(aStruCNA)
								If aStruCNA[nX][1]$"CNA_FILIAL,CNA_CONTRA,CNA_REVISA,CNA_NUMERO,CNA_FORNEC,CNA_LOJA,CNA_SALDO"
									aadd(aOptimize[OPT_SELECT],aStruCNA[nX])
								EndIf							
							Next nX

							For nX := 1 To Len(aStruCNB)
								If !(Alltrim(aStruCNB[nX][1]) == "CNB_ITEM") .AND. aStruCNB[nX][1]$"CNB_FILIAL,CNB_CONTRA,CNB_REVISA,CNB_NUMERO,CNB_ITEMCT,CNB_CONTA,CNB_CC"
									aadd(aOptimize[OPT_SELECT],aStruCNB[nX])
								EndIf							
							Next nX
							
							For nX := 1 To Len(aStruSA2)
								If aStruSA2[nX][1]$"A2_COD,A2_LOJA,A2_NOME"
									aadd(aOptimize[OPT_SELECT],aStruSA2[nX])
								EndIf
							Next nX

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Montagem da instrucao from                                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aadd(aOptimize[OPT_FROM],{RetSqlName("CN9"),"CN9"})
							aadd(aOptimize[OPT_FROM],{RetSqlName("CNA"),"CNA"})							
							aadd(aOptimize[OPT_FROM],{RetSqlName("CNB"),"CNB"})
							aadd(aOptimize[OPT_FROM],{RetSqlName("SA2"),"SA2"})

							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Montagem da instrucao where                                  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aOptimize[OPT_WHERE] := "CN9.D_E_L_E_T_=' ' 					AND	"
							aOptimize[OPT_WHERE] += "CNA.D_E_L_E_T_=' ' 					AND	"							
							aOptimize[OPT_WHERE] += "CNB.D_E_L_E_T_=' ' 					AND	"
							aOptimize[OPT_WHERE] += "SA2.D_E_L_E_T_=' ' 					AND	"							
							aOptimize[OPT_WHERE] += "CN9.CN9_FILIAL='"+FWxFilial("CN9")+"' 	AND "
							aOptimize[OPT_WHERE] += "CN9.CN9_XRESTP IN ('T','P') 			AND " 
							aOptimize[OPT_WHERE] += "CN9.CN9_XOK = '"+cMarca+"' 			AND "
							aOptimize[OPT_WHERE] += "CN9.CN9_XDTLAN = '"+Dtos(Ctod(""))+"' 	AND "
							aOptimize[OPT_WHERE] += "CNB.CNB_FILIAL=CN9.CN9_FILIAL			AND	"
							aOptimize[OPT_WHERE] += "CNB.CNB_CONTRA=CN9.CN9_NUMERO			AND	"
							aOptimize[OPT_WHERE] += "CNB.CNB_REVISA=CN9.CN9_REVISA			AND	"
							aOptimize[OPT_WHERE] += "CNB.CNB_FILIAL=CNA.CNA_FILIAL			AND	"
							aOptimize[OPT_WHERE] += "CNB.CNB_CONTRA=CNA.CNA_CONTRA			AND	"
							aOptimize[OPT_WHERE] += "CNB.CNB_REVISA=CNA.CNA_REVISA			AND	"
							aOptimize[OPT_WHERE] += "CNB.CNB_NUMERO=CNA.CNA_NUMERO			AND	"
							aOptimize[OPT_WHERE] += "CNA.CNA_FORNEC=SA2.A2_COD				AND	"
							aOptimize[OPT_WHERE] += "CNA.CNA_LJFORN=SA2.A2_LOJA					"
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Montagem da Query                                            ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cString := ""
							
							For nX := 1 To Len(aOptimize[OPT_SELECT])
								cString += ","+aOptimize[OPT_SELECT][nX][1]
							Next nX
							
							cQuery := "SELECT DISTINCT CN9.R_E_C_N_O_ CN9RECNO "+cString							
							
							cString := ""
							For nX := 1 To Len(aOptimize[OPT_FROM])
								cString += ","+aOptimize[OPT_FROM][nX][1]+" "+aOptimize[OPT_FROM][nX][2]
							Next nX
							
							cQuery += " FROM "+SubStr(cString,2)
							cQuery += " WHERE "+aOptimize[OPT_WHERE]
							
							cQuery += " ORDER BY CN9_FILIAL, CN9_NUMERO, CN9_REVISA, CNB_NUMERO,CNB_CC,CNB_CONTA,CNB_ITEMCT"
							
							cQuery := ChangeQuery(cQuery)
							
							dbSelectArea("CN9")
							dbCloseArea()
							
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCN9,.T.,.T.)
							
							For nX := 1 To Len(aOptimize[OPT_SELECT])
								If aOptimize[OPT_SELECT][nX][2]<>"C"
									TcSetField(cAliasCN9,aOptimize[OPT_SELECT][nX][1],aOptimize[OPT_SELECT][nX][2],aOptimize[OPT_SELECT][nX][3],aOptimize[OPT_SELECT][nX][4])
								EndIf
							Next nX
							
							// Preenche array auxiliar
							While (cAliasCN9)->(!Eof())
							
								Aadd(aCNBControl,{	(cAliasCN9)->CN9_FILIAL	,;
													(cAliasCN9)->CN9_NUMERO	,;
													(cAliasCN9)->CN9_REVISA	,;
													(cAliasCN9)->CNB_NUMERO	,;
													(cAliasCN9)->CNB_CC		,;
													(cAliasCN9)->CNB_CONTA	,;
													(cAliasCN9)->CNB_ITEMCT	,;
													(cAliasCN9)->CN9_VLATU	})
								(cAliasCN9)->(dbSkip())
							EndDo
							
							(cAliasCN9)->(dbGoTop())
							
						Else
						
							MsgStop("Contabilização não configurada em ambiente que não usa TOPCONNECT.")
							Return
							
						Endif
						
					Endif
				#ENDIF
				
				#IFNDEF TOP
					dbSetIndex(cArqCN9+OrdBagExt())
				#ELSE   
					DbSelectArea("CN9")
					dbSetOrder(nOrdCN9+1)
					MsSeek(xFilial("CN9")+Dtos(dDataIni),.T.)
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
					nHdlPrv:=HeadProva(cLoteCtb,"SICTBA99",Subs(cUsuario,7,6),@cArqCtb)
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
				dbSelectArea(cAliasCN9)
				(cAliasCN9)->(dbGoTop())
				
				While ( !Eof() .And. (cAliasCN9)->CN9_FILIAL == FWxFilial("CN9") .And. lContinua )

					nCNBControl ++
					cContOld := aCNBControl[nCNBControl,POS_CN9NUM] 
					
					lValido   := .T.
					lDetProva := .F.
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se a nota nao foi contabilizada                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty((cAliasCN9)->CN9_XDTLAN)
						lValido := .F.
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se esta com Flag de Restos a Pagar                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !(cAliasCN9)->CN9_XRESTP $ "T|P"
						lValido := .F.
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se esta marcado                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (cAliasCN9)->CN9_XOK <> cMarca
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

							CN9->(MsGoto((cAliasCN9)->CN9RECNO))
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Define as chaves de relacionamento SIGACTB
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lLctPadSI
								c652       := CtRelation("030",.F.,{{cAliasCN9,"CN9"},{cAliasCN9,"CN9_QRY"},{cAliasCN9,"SICTBA99"}})
							Endif
							
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ajusta a data base com a data de contabilizacao              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Do Case
							Case nTpCtb == 1 .Or. nTpCtb == 3
	//							dDataBase := IIF(dDtContab==1,(cAliasCN9)->C7_EMISSAO,dDataBase) //-- COMENTADO PELO ALLAN-J2A
							Case nTpCtb == 2
								dDataBase := dDataFim
						EndCase
						
						If lQuery
							If lUsaFlag
								aAdd(aFlagCTB,{"CN9_XDTLAN",dDataBase,"CN9",(cAliasCN9)->CN9RECNO,0,0,0})
							EndIf
							If lSeqCorr
								aAdd(aDiario, {"CN9",(cAliasCN9)->CN9RECNO,(cAliasCN9)->CN9_DIACTB,"CN9_NODIA","CN9_DIACTB"} )
							EndIf
						Else
							If lUsaFlag
								aAdd(aFlagCTB,{"CN9_XDTLAN",dDataBase,"CN9",(cAliasCN9)->(Recno()),0,0,0})
							EndIf
							If lSeqCorr
								aAdd(aDiario, {"CN9",(cAliasCN9)->(Recno()),(cAliasCN9)->CN9_DIACTB,"CN9_NODIA","CN9_DIACTB"})
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
								nHdlPrv:=HeadProva(cLoteCtb,"SICTBA99",Subs(cUsuario,7,6),@cArqCtb)
								IF nHdlPrv <= 0
									HELP(" ",1,"SEM_LANC")
									lContinua := .F.
								Else
									lHeader := .T.
								EndIf
							EndIf
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Posiciona registros vinculados ao Contrato			         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							
							If lQuery
								
								dbSelectArea("CNA")
								CNA->(dbSetOrder(1))
							 	CNA->(msSeek((cAliasCN9)->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA+CNA_NUMERO))) 
	
								dbSelectArea("CNB")
								CNB->(dbSetOrder(1))
							 	CNB->(msSeek((cAliasCN9)->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA+CNB_NUMERO)))
	
								dbSelectArea("CN9")
								CN9->(dbSetOrder(1))
							 	CN9->(msSeek((cAliasCN9)->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA)))						 	
							 	
								dbSelectArea("SA2")
								SA2->(dbSetOrder(1))
							 	SA2->(msSeek(xFilial("SA2")+(cAliasCN9)->(A2_COD+A2_LOJA))) 						 	
							 	
							EndIf
							
							// Seleciona área
							dbSelectArea(cAliasCN9)
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Executa os lancamentos contabeis ( 652 ) - Item              ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lHeader
								lDetProva := .T.
								nParcCtb 	:= DetProva(nHdlPrv,"030","SICTBA99",cLoteCtb,,,,,@c652,@aCT5,,@aFlagCTB)
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
								If !lQuery
									dbSelectArea(cAliasCN9)
									dbSkip()
									nRecCN9 := RecNo()
									dbSkip(-1)
								EndIf
								If !lUsaFlag
									RecLock("CN9")
										CN9->CN9_XDTLAN := dDataBase
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
							dbSelectArea(cAliasCN9)
							dbSkip()
							nRecCN9 := RecNo()
							dbSkip(-1)
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifico a quebra de Fornecedor                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea(cAliasCN9)
					
					If nCNBControl == Len(aCNBControl) .OR. cContOld # aCNBControl[nCNBControl+1,POS_CN9NUM]
						
						// Ajusta variável
						aCNBCtr2 := {}
						
						If nTpCtb == 1 .And. lHeader 
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Fecha os lancamentos contabeis                               ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lHeader   := .F.
							RodaProva(nHdlPrv,nTotalCtb)
							If nTotalCtb > 0
								nTotalCtb := 0
								
								If cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB,,aDiario)
									RecLock("CN9",.F.)
										CN9->CN9_XPROCE := cProcesso
									CN9->(msUnlock())
								Else
									RecLock("CN9",.F.)
										CN9->CN9_XPROCE := Space(TamSx3("CN9_XPROCE")[1])
										CN9->CN9_XDTLAN := Ctod("")
									CN9->(msUnlock())
								EndIf
								
								aDiario := {}
								aFlagCTB:= {}
								
							EndIf
						EndIf
						
						dbSelectArea(cAliasCN9)
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza a regua de processamento por periodo                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lInterface
							oObj:IncRegua2("Contrato :"+Dtoc((cAliasCN9)->(CN9_FILIAL+CN9_NUMERO)))
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
						
						If nTpCtb == 3
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
					
					EndIf
					
					(cAliasCN9)->(dbSkip())
					
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
					dbSelectArea(cAliasCN9)
					dbCloseArea()
					dbSelectArea("CN9")
				Else
					dbSelectArea("CN9")
					RetIndex("CN9")
					dbClearFilter()
					FErase(cArqCN9+OrdBagExt())
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

	// Atualiza Browse
	_oMarkBrow:Refresh()
	_oDlg:Refresh()
	fUpdCN9OK()
	nQtdCont 	:= 0
	nValCont 	:= 0
	nCNBControl := 0
	aCNBControl	:= {}
	aCNBCtr2	:= {}
	cCN9CtrNum	:= ""
	cCNBCtrNum	:= "" 
	cCNBCtrCC	:= ""
	cCNBCtrCo	:= ""
	cCNBCtrIC	:= ""
	fUpdRodape()	
	
Return


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
User Function EX_CTB99()
	Local cProcesso := Iif((Type("CN9->CN9_XPROCE")=="C".AND.!Empty(CN9->CN9_XPROCE)),CN9->CN9_XPROCE,Space(6))
	Local _lFechar  := .T.
	Local nOpca     := 0
	Local nPosProc	:= 0
	Local nStatus	:= 0
	Local cQuery	:= ""
	
	If MsgYesNo("Confirme reversão dos lançamentos contábeis dos pedidos de Restos a Pagar marcados. "+CHR(10)+CHR(13)+;
				"Caso tenha contabilizado pela DataBase, ajuste a mesma para a data dos lançamentos contábeis que se deseja excluir" , "Continua?")
	
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
			
			// Valida se data está bloqueada ou não na contabilidade
			If CtbValiDt(,dDataBase)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exclusão dos Lançamentos Contábeis                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery := " UPDATE CT2 																						"
				cQuery += " 	SET CT2.D_E_L_E_T_ = '*', 																	"
				cQuery += " 	CT2.R_E_C_D_E_L_ = CT2.R_E_C_N_O_ 															"
				cQuery += " FROM "+RetSqlName("CT2")+" CT2 																	"
				cQuery += " WHERE EXISTS	( 	SELECT RECNO FROM 	(	SELECT CT2A.R_E_C_N_O_ AS RECNO  					"
				cQuery += " 										FROM "+RetSqlName("CT2")+" CT2A  						"
				cQuery += " 										WHERE CT2A.D_E_L_E_T_ = ' '   							"
				cQuery += " 										AND CT2A.CT2_ROTINA = 'SICTBA99'   						"
				cQuery += " 										AND CT2A.CT2_LP = '030'   								"
				cQuery += "											AND LTRIM(RTRIM(CT2A.CT2_KEY)) = 'P"+cProcesso+"'		"
				cQuery += " 										UNION ALL   											"
				cQuery += " 										SELECT CT2B.R_E_C_N_O_ AS RECNO  						"
				cQuery += " 										FROM "+RetSqlName("CT2")+" CT2B   						"
				cQuery += " 										WHERE CT2B.D_E_L_E_T_ = ' '   							"
				cQuery += " 										AND CT2B.CT2_ROTINA = 'SICTBA99'   						"
				cQuery += " 										AND CT2B.CT2_LP = '030'   								"
				cQuery += " 										AND CT2B.CT2_KEY  = ' '   								"
				cQuery += " 										AND EXISTS 	( 	SELECT CT2C.R_E_C_N_O_ 					" 
				cQuery += "															FROM "+RetSqlName("CT2")+" CT2C 		" 
				cQuery += "															WHERE CT2C.D_E_L_E_T_ = ' ' 			" 
				cQuery += "															AND CT2C.CT2_ROTINA = CT2B.CT2_ROTINA 	"  
				cQuery += "															AND CT2C.CT2_LP = CT2B.CT2_LP 			"
				cQuery += "															AND CT2C.CT2_DATA=CT2B.CT2_DATA			" 
				cQuery += "															AND CT2C.CT2_SEQUEN=CT2B.CT2_SEQUEN 	" 
				cQuery += "															AND LTRIM(RTRIM(CT2C.CT2_KEY)) = 'P"+cProcesso+"'	"
				cQuery += "														) 											"
				cQuery += "										) AS REGISTROS_INTEGRADOS 									"
				cQuery += "						WHERE REGISTROS_INTEGRADOS.RECNO = CT2.R_E_C_N_O_ 							"
				cQuery += "						AND	CT2.CT2_DATA = '"+DtoS(dDataBase)+"'									"
				cQuery += "					)  		
			
				nStatus := TcSqlExec(cQuery)
				
				
				// Atualização do modo de exclusão da contabilização
				cQuery := " UPDATE CT2 "
				cQuery += " 	SET CT2.D_E_L_E_T_ = '*', " 
				cQuery += " 	CT2.R_E_C_D_E_L_ = CT2.R_E_C_N_O_ "
				cQuery += " FROM "+RetSqlName("CT2")+"	CT2 "
				cQuery += " WHERE EXISTS	( 	SELECT RECNO FROM 	(	SELECT CT2A.R_E_C_N_O_ AS RECNO "
				cQuery += " 											FROM "+RetSqlName("CT2")+" CT2A "
				cQuery += " 											WHERE CT2A.D_E_L_E_T_ = ' ' "
				cQuery += " 											AND CT2A.CT2_ROTINA = 'SICTBA99' "
				cQuery += " 											AND CT2A.CT2_LP = '030' "
				cQuery += " 											AND LTRIM(RTRIM(CT2A.CT2_ORIGEM)) LIKE ('030-%_PROC"+cProcesso+"') "
				cQuery += " 										) AS REGISTROS_INTEGRADOS"
				cQuery += " 					WHERE REGISTROS_INTEGRADOS.RECNO = CT2.R_E_C_N_O_"
				cQuery += " 					AND	CT2.CT2_DATA = '"+DtoS(dDataBase)+"'
				cQuery += " 				) "
				
				nStatus := TcSqlExec(cQuery)
			
			Else
			
				nStatus := -1
				
			EndIf
			
		End Transaction
		
		// Verifica o update foi realizado com sucesso
		If nStatus >= 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estorno da contabilizacoa dos pedidos SC7                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := " UPDATE "+RetSqlName("CN9")+" SET CN9_XDTLAN = ' ', CN9_XPROCE = ' ' "
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND CN9_XPROCE = '"+cProcesso+"' "
			cQuery += " AND CN9_XRESTP IN ('T','P') "
			TcSqlExec(cQuery)
			
			MsgInfo("Exclusão da contabilização realizada com sucesso.","FIEG | "+FunName())		
		Else
			Alert("Não foi possível realizar a exclusão da contabilização. Verifique a data base do sistema e se o período está aberto contabilmente.")
		EndIf
		
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
	Local aXArea := GetArea()
	Local _nCurrRec := _oMarkBrow:At()
	Local _lMark	:= _oMarkBrow:IsMark()
	Local _cTmp		:= GetNextAlias()
	Local cTpResto	:= ""
	Local nValResto	:= 0
	
	//-- Marca usada
	If Empty(cMarca) 
		cMarca:=  _oMarkBrow:Mark()
	EndIf	
	
	If IsInCallStack("MarkAll")
	
		MarkRec()
		
	Else

		// Ainda não foi marcado
		If (CN9->CN9_XOK <> _oMarkBrow:Mark())
		
			If (Empty(CN9->CN9_XPROCE))
				
				// Ajusta Variáveis
				nValResto  := CN9->CN9_XRESTV
				
				If Empty(CN9->CN9_XRESTP)
				
					If fXTela(@cTpResto,@nValResto,CN9->CN9_SALDO)
						
						nQtdCont++
						nValCont := nValCont + nValResto
						
						RecLock("CN9",.F.)
							CN9->CN9_XOK 	:= _oMarkBrow:Mark()
							CN9->CN9_XRESTP := cTpResto
							CN9->CN9_XRESTV := nValResto
						CN9->(MsUnLock())
						
					EndIf
				
				Else
				
					nQtdCont++
					nValCont := nValCont + CN9->CN9_XRESTV
					
					RecLock("CN9",.F.)
						CN9->CN9_XOK 	:= _oMarkBrow:Mark()
					CN9->(MsUnLock())
				
				EndIf
			
			Else
			
				Alert("Não é possível selecionar um contrato já contabilizado.")
				
			EndIf
			
		ElseIf (CN9->CN9_XOK == _oMarkBrow:Mark())
			
			If nQtdCont > 0
			
				nQtdCont := nQtdCont - 1
				nValCont := nValCont - CN9->CN9_XRESTV
				
				RecLock("CN9",.F.)
					CN9->CN9_XOK := Space(2)
					CN9->CN9_XRESTP := cTpResto
					CN9->CN9_XRESTV := nValResto
				CN9->(MsUnLock())
				
				Iif((nValCont<0),nValCont:=0,NIL)
				
			EndIf
		
		EndIf
		
	EndIf
	
	// Refresh nos objetos
	fUpdRodape()
		
	RestArea(aXArea)            
Return .T.

Static Function AjustaSX1()
/*/f/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
<Descricao> : Modulo de Contabilidade Gerencial. Processamento da contabilizacao dos Restos a Pagar de Contratos
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
Local cPerg	   := "SICTBA99"

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
Static Function MenuDef()
	Local aRotina	:= {}
	
	aRotina :=	{	{"Contabilizar"			,"U_CN_CTB99"						,0,4,0,.F.},;
					{"Pesquisar"			,"AxPesqui"  						,0,2,0,.F.},;
					{"Visualizar"			,"FWMsgRun(, {|| StaticCall(CNTA100,CN100Manut,'CN9',CN9->(Recno()),2,.F.,.F.) }, NIL, 'Acessando Contrato...')"  	,0,2,0,.F.},;
					{"Imprimir"				,"U_SICTBR50"   					,0,2,0,.T.},;
					{"Excluir Contab."		,"FWMsgRun(, {|| U_EX_CTB99() }, NIL, 'Excluindo Contabilizações...')",0,6,0,.T.},;
					{"Parametros	"		,"U_PAR_CTB98"  					,0,7,0,.T.},;
					{"Legenda		"		,"StaticCall(SICTBA99,fLegenda)"	,0,8,0,.T.}}

Return(aRotina)


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
User Function PA_CTB99()

	AjustaSX1()
	Pergunte("SICTBA98",.T.)

Return


/*/{Protheus.doc} fXAccessOK
// Função para validações gerais de acesso
@author danielflavio
@since 23/11/2018
@version 1.0
@return boolean, Verifica se tem permissão ou não
@type static function
/*/
Static Function fXAccessOK()
	Local lXRPCont	:= SuperGetMv("SI_XRPCONT",.F.,.T.)
Return lXRPCont


/*/{Protheus.doc} fXTela
// Tela pra digitar valores de resto a pagar
@author danielflavio
@since 26/11/2018
@version 1.0
@type function
/*/
Static Function fXTela(cTpCont,nValor,nValMax)
	Local aXArea	:= GetArea()
	Local lRet		:= .T.
	Local lOk		:= .F.
	Local oButtonOK
	Local oButtonCan
	Local oGetValor
	Local oRadMenu1
	Local nRadMenu1 := 1
	Local nGetValor := 0
	Local oDlg
	Local oSay1
	Local oSay4
	Local oFontAr12  := TFont():New("Arial", ,12,,.F.)
	Local oFontAr12B := TFont():New("Arial", ,12,,.T.)
	Local oFontAr14  := TFont():New("Arial", ,14,,.F.)
	Local oFontAr14B := TFont():New("Arial", ,14,,.T.)
	Local cMsgTpRes	:= OemToAnsi("Selecione o tipo de resto a pagar")
	Default cTpCont := ""
	Default nValor 	:= 0
	Default nValMax := 0
	
	
	// Ajusta variáveis
	nGetValor := nValor
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000, 000  TO 200, 400 COLORS 0, 16777215 PIXEL FONT oFontAr14B
	
		@ 002, 013 SAY oSay1 PROMPT cMsgTpRes SIZE 167, 011 OF oDlg COLORS 0, 16777215 PIXEL CENTER FONT oFontAr14B
		@ 015, 013 SAY oSay2 PROMPT "Saldo do Contrato  R$ "+Alltrim(Transform(nValMax,GetSx3Cache("CN9_SALDO","X3_PICTURE")))  SIZE 167, 011 OF oDlg COLORS 0, 16777215 PIXEL FONT oFontAr14
    	@ 030, 030 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Total","Parcial" SIZE 040, 024 OF oDlg COLOR 0, 16777215 PIXEL 
		@ 058, 030 SAY oSay4 PROMPT "Valor" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL FONT oFontAr14
		@ 055, 068 MSGET oGetValor VAR nGetValor PICTURE GetSx3Cache("CN9_SALDO","X3_PICTURE") SIZE 075, 013 OF oDlg COLORS 0, 16777215 PIXEL  FONT oFontAr14 VALID Iif((nRadMenu1 = 2),(nGetValor > 0,nGetValor <= nValMax),.T.) HASBUTTON 
		@ 077, 033 BUTTON oButtonOK PROMPT "OK" SIZE 040, 012 OF oDlg PIXEL ACTION (lOk:=.T.,oDlg:End()) FONT oFontAr14
		@ 077, 120 BUTTON oButtonCan PROMPT "Cancelar" SIZE 040, 012 OF oDlg PIXEL ACTION (lOk:=.F.,oDlg:End()) FONT oFontAr14

		// Ajusta visualização do objeto Valor
		Iif((nRadMenu1 = 1),(nGetValor := 0,oSay2:Hide(),oSay4:Hide(),oGetValor:Hide()),(oSay2:Show(),oSay4:Show(),oGetValor:Show()))

		// Mudança no objeto Radio Button
		oRadMenu1:bchange := {|| Iif((nRadMenu1 = 1),(nGetValor := 0,oSay2:Hide(),oSay4:Hide(),oGetValor:Hide()),(oSay2:Show(),oSay4:Show(),oGetValor:Show())) }
		
		// Foco no botão de OK
		oButtonOK:SetFocus()

	ACTIVATE MSDIALOG oDlg CENTERED

	// Clicou em OK
	If lOk
	
		If nRadMenu1 = 1
			cTpCont := "T"
			nValor	:= nValMax
		ElseIf nRadMenu1 = 2
			cTpCont := "P"
			nValor	:= nGetValor
		EndIf
	
	Else
	
		lRet := .F.
	
	EndIf

	RestArea(aXArea)
Return lRet


/*/{Protheus.doc} fUpdateRod
// Função para atualizar informações do Rodapé
@author danielflavio
@since 26/11/2018
@version 1.0
@type static function
/*/
Static Function fUpdRodape(lXMake)
	Default lXMake := .F.
	
	If lXMake
		
		// Ajusta variáveis
		nQtdCont := 0
		nValCont := 0
		
		//-- Total Selecionado
		TSay():New(005,003,{|| "Quantidade Selecionada :" },_oRodap,,_oFont1,,,,.T.,CLR_BLUE)
		_oTsay1:= TSay():New(005,100,{|| Alltrim(cValToChar(nQtdCont))},_oRodap,,_oFont1,,,,.T.,CLR_BLUE)
		
		TSay():New(020,003,{|| "Total Selecionado :" },_oRodap,,_oFont1,,,,.T.,CLR_BLUE)
		_oTsay2:= TSay():New(020,100,{|| "R$ "+AllTrim(Transform(nValCont,GetSx3Cache("CN9_SALDO","X3_PICTURE"))) },_oRodap,,_oFont1,,,,.T.,CLR_BLUE)
			
	Else
	
		_oTsay1:Refresh()
		_oTsay2:Refresh()
		
	EndIf
	
Return


/*/{Protheus.doc} fUpdCN9OK
// Função para atualizar os registros da tabela CN9
@author danielflavio
@since 26/11/2018
@version 1.0
@type function
/*/
Static Function fUpdCN9OK()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa marca CN9_XOK antes da selecao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction
		cQuery := " UPDATE "+RetSqlName("CN9")+" SET CN9_XOK = ' ' 		"
		cQuery += " WHERE D_E_L_E_T_ = ' ' 								"
		cQuery += " AND CN9_XOK <> ' ' 									"
		cQuery += " AND (CN9_XRESTP <> ' ' OR CN9_SITUAC IN ('05')) 	"
		TcSqlExec(cQuery)
	End Transaction 
	
Return


/*/{Protheus.doc} fLegenda
// Função para geração de Legenda
@author danielflavio
@since 27/11/2018
@version 1.0
@type static function
/*/
Static Function fLegenda()
Local aLegenda	:= {}

	Aadd(aLegenda,{"ENABLE","Contrato Vigente"						})
	Aadd(aLegenda,{"BR_PRETO","Cont. RP Total - Sem Saldo - CTB"	})
	Aadd(aLegenda,{"BR_CINZA","Cont. RP Parcial - Sem Saldo - CTB"	})
	Aadd(aLegenda,{"BR_BRANCO","Cont. RP Total - CTB"				})
	Aadd(aLegenda,{"BR_AMARELO","Cont. RP Parcial - CTB"			})
	Aadd(aLegenda,{"BR_VERMELHO","Cont. RP Total - Não CTB"			})
	Aadd(aLegenda,{"BR_LARANJA","Cont. RP Parcial - Não CTB"		})
							
	BrwLegenda("Legenda", "Legenda", aLegenda)

Return


/*/{Protheus.doc} fAuxCT5
// Função auxiliar para contabilização
@author danielflavio
@since 28/11/2018
@version 1.0
@return xRet, Tipo é definido em execução
@param cXCampo, characters, Campo da CT5
@type static function
/*/
Static Function fAuxCT5(cXLanPad,cXCampo)
	Local aXArea	:= GetArea()
	Local aXAreaCNA	:= Iif((Select("CNA")>0),CNA->(GetArea()),GetArea())
	Local aXAreaCNB	:= Iif((Select("CNB")>0),CNB->(GetArea()),GetArea())
	Local aXAreaCN9	:= Iif((Select("CN9")>0),CN9->(GetArea()),GetArea())
	Local aXAreaSA2	:= Iif((Select("SA2")>0),SA2->(GetArea()),GetArea())
	Local aXAreaCND	:= {}
	Local lXRPCont	:= SuperGetMv("SI_XRPCONT",.F.,.T.)	
	Local xRet 		:= NIL
	Local cAuxNumCon:= ""
	Local nAux		:= 0
	Local nAuxTotCon:= 0
	Local nAuxTotPro:= 0
	Local nA		:= 0
	Local nB		:= 0
	Local cXCont	:= ""
	Local cXContRev	:= ""		
	Local nXProp	:= 0
	Local nXValDef	:= 0
	Local nXValJaLan:= 0
	Default cXCampo := ""
	Default cXLanPad:= ""
	
	If cXLanPad == "030001" .AND. cXCampo $ "CT5_CCC"
	
		xRet := " "
		xRet := u_xLPObterCC(CN9->CN9_FILIAL,CNB->CNB_CC,FunName())

	ElseIf cXLanPad == "030002" .AND. cXCampo == "CT5_DEBITO"
	
		xRet := aCNBControl[nCNBControl,POS_CNBCON]
		
	ElseIf cXLanPad == "030002" .AND. cXCampo == "CT5_ITEMD"
	
		xRet := aCNBControl[nCNBControl,POS_CNBITC]
	
	ElseIf cXLanPad == "030002" .AND. cXCampo == "CT5_CCD"		
		
		xRet := aCNBControl[nCNBControl,POS_CNBCCU]
		
	ElseIf cXLanPad == "030001" .AND. cXCampo == "CT5_VLR01"
		
		If cCN9CtrNum # aCNBControl[nCNBControl,POS_CN9NUM]
			xRet := CN9->CN9_XRESTV
			cCN9CtrNum := aCNBControl[nCNBControl,POS_CN9NUM]
		Else
			xRet := 0
		EndIf
	
	ElseIf cXLanPad == "030002" .AND. cXCampo == "CT5_VLR01"

		xRet 	:= 0
		nXProp	:= Round(CN9->CN9_XRESTV * (fCNBProp() / aCNBControl[nCNBControl,POS_CN9VLA]),2)
		
		// Armazena informações do contrato atual
		Aadd(aCNBCtr2,{aCNBControl[nCNBControl,POS_CN9NUM],fCNBProp(),nXProp})
		
		// Percorre array somando o valor da medição
		For nA := 1 to Len(aCNBCtr2)
			If cCN9CtrNum == aCNBControl[nCNBControl,POS_CN9NUM]
				nAuxTotCon := nAuxTotCon + aCNBCtr2[nA,2]
			EndIf
		Next
		
		// Tratativa para tentar acertar o valor exato
		If (aCNBControl[nCNBControl,POS_CN9VLA] - nAuxTotCon) == 0
		
			// Percorre array somando o valor da medição
			For nB := 1 to Len(aCNBCtr2)
				If cCN9CtrNum == aCNBControl[nCNBControl,POS_CN9NUM]
					nAuxTotPro := nAuxTotPro + aCNBCtr2[nB,3]
				EndIf
			Next		
			
			// Valor Total Proporcionalizado
			If nAuxTotPro == CN9->CN9_XRESTV
				xRet := nXProp
			Else
				If nAuxTotPro > CN9->CN9_XRESTV
					xRet := nXProp - (CN9->CN9_XRESTV - nAuxTotPro)
				ElseIf nAuxTotPro < CN9->CN9_XRESTV
					xRet := nXProp + (CN9->CN9_XRESTV - nAuxTotPro)
				Else // ???
					xRet := xProp
				EndIf
			EndIf
		
		// Redundante. Mesma validação acima.
		// Adicionei essa validação extra para casos que dê problema com arredondamento de casas decimais
		// Não peguei nenhum contrato que entre nessa condição... 
		ElseIf (aCNBControl[nCNBControl,POS_CN9VLA] - nAuxTotCon) >= -1 .AND. (aCNBControl[nCNBControl,POS_CN9VLA] - nAuxTotCon) <= 1

			// Percorre array somando o valor da medição
			For nB := 1 to Len(aCNBCtr2)
				If cCN9CtrNum == aCNBControl[nCNBControl,POS_CN9NUM]
					nAuxTotPro := nAuxTotPro + aCNBCtr2[nB,3]
				EndIf
			Next				 
		
			// Valor Total Proporcionalizado
			If nAuxTotPro == CN9->CN9_XRESTV
				xRet := nXProp
			Else
				If nAuxTotPro > CN9->CN9_XRESTV
					xRet := nXProp - (CN9->CN9_XRESTV - nAuxTotPro)
				ElseIf nAuxTotPro < CN9->CN9_XRESTV
					xRet := nXProp + (CN9->CN9_XRESTV - nAuxTotPro)
				Else // ???
					xRet := xProp
				EndIf
			EndIf
		
		Else
		
			xRet := nXProp
			
		EndIf
	
	ElseIf cXLanPad == "030001" .AND.cXCampo == "CT5_HIST"
	
		xRet := "RP-"+aCNBControl[nCNBControl,POS_CN9NUM]
	
	ElseIf cXLanPad == "030002" .AND.cXCampo == "CT5_HIST"
		
		cAuxNumCon := Alltrim(cValtoChar(Val(aCNBControl[nCNBControl,POS_CN9NUM])))
		xRet := "RP-"+Alltrim(SubStr(SA2->A2_NOME,1,TamSx3("CT2_HIST")[1] - (Len(cAuxNumCon)+4)))+"-"+cAuxNumCon
	
	ElseIf cXLanPad == "650010" .AND. cXCampo == "CT5_VLR01"
	
		/*
		 Utilização das variáveis do Protheus
		 MV_PAR57 - "C" - Filial + Número do Contrato + Revisao + Medicao
		 MV_PAR58 - "N" - Saldo Medição
		 MV_PAR59 - "N" - Valor que será gravado no LP 650011
		 MV_PAR60 - "L" - Define se o LP 650011 será utilizado ou não
		*/
		
		// Ajustas os MV_PARs que serão utilizados para auxiliar na contabilização 
		fXAjustaMV()
	
		xRet := 0
		
		If lXRPCont
			
			If (SD1->D1_CUSTO > 0 .AND. !Empty(SD1->D1_PEDIDO))
				
				// Busca dados do Contrato
				If fDadosCont(SD1->D1_FILIAL,SD1->D1_PEDIDO,SD1->D1_ITEMPC,@cXCont,@cXContRev)
					
					// Verifica se contrato está setado como restos a pagar
					If U_fXResto99("IS_RP",SD1->D1_FILIAL,cXCont,cXContRev)
					
						// Verifica se contrato é parcial e possui saldo
						If U_fXResto99("IS_PARCIAL",SD1->D1_FILIAL,cXCont,cXContRev)
						
							// Posiciona na Medição
							dbSelectArea("CND")
							aXAreaCND := CND->(GetArea())
							
							// Verifica se medição está flagada como restos a pagar
							If fXIsCNDRP(SD1->D1_FILIAL,cXCont,cXContRev,SD1->D1_PEDIDO)
							
								If MV_PAR57 # CND->(CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMMED)
									MV_PAR57 := CND->(CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMMED) 	// Chave
									MV_PAR58 := CND->CND_XRESTV										// Saldo
								EndIf
								
								If MV_PAR58 = 0
									
									// Nesse caso, o valor será gravado integralmente como nota normal
									xRet 		:= 0
									MV_PAR59	:= SD1->D1_CUSTO
									MV_PAR60	:= .T.								
								
								ElseIf SD1->D1_CUSTO <= MV_PAR58
								
									xRet 		:= SD1->D1_CUSTO
									MV_PAR58	-= SD1->D1_CUSTO
									MV_PAR59 	:= 0
									MV_PAR60 	:= .F.
								
								Else
								
									// Nesse caso, será gravada parte em parcial e outra parte como nota normal
									xRet 		:= MV_PAR58
									MV_PAR58	:= 0
									MV_PAR59 	:= SD1->D1_CUSTO - xRet
									MV_PAR60 	:= .T.								
								
								EndIf
								
							
							Else
								// Será contabilizado como nota normal
								MV_PAR59	:= SD1->D1_CUSTO
								MV_PAR60 	:= .T.							
							EndIf
							
							RestArea(aXAreaCND)
						
						Else

							// Continua normalmente
							xRet 		:= SD1->D1_CUSTO
							MV_PAR60 	:= .F.						
						
						EndIf
					
					Else
					
						// Continua normalmente
						xRet 		:= SD1->D1_CUSTO
						MV_PAR60 	:= .F.
					
					EndIf

				Else
					// Continua normalmente
					xRet 		:= SD1->D1_CUSTO
					MV_PAR60 	:= .F.
				EndIf
				
			EndIf
		
		Else
		
			// Continua normalmente
			xRet := SD1->D1_CUSTO
			MV_PAR60 	:= .F.
		
		EndIf
	
	
	ElseIf cXLanPad == "650011" .AND. cXCampo == "CT5_VLR01"
	
		// Ajustas os MV_PARs que serão utilizados para auxiliar na contabilização 
		fXAjustaMV()	

		xRet := 0
		
		If lXRPCont
			
			If MV_PAR60
				
				If MV_PAR59 > 0
					
					xRet := MV_PAR59
				
					MV_PAR59 := NIL
					MV_PAR60 := NIL
					
				EndIf
				
			EndIf
			
		EndIf

	ElseIf cXLanPad == "650010" .AND. cXCampo $ "CT5_CCC|CT5_CCD"
	
		xRet := " "
		xRet := u_xLPObterCC(SD1->D1_FILIAL,SD1->D1_CC,FunName())

	ElseIf cXLanPad == "650011" .AND. cXCampo $ "CT5_CCC|CT5_CCD"
	
		xRet := " "
		xRet := u_xLPObterCC(SD1->D1_FILIAL,SD1->D1_CC,FunName())		

	ElseIf cXLanPad == "655020" .AND. cXCampo == "CT5_VLR01"
	
		/*
		 Utilização das variáveis do Protheus
		 MV_PAR57 - "C" - Filial + Número do Contrato + Revisao + Medicao
		 MV_PAR58 - "N" - Saldo Medição
		 MV_PAR59 - "N" - Valor que será gravado no LP 650011
		 MV_PAR60 - "L" - Define se o LP 650011 será utilizado ou não
		*/
		xRet := 0
		
		If lXRPCont
			// Ajustas os MV_PARs que serão utilizados para auxiliar na contabilização 
			fXAjustaMV()
			
			// Verifica se tem valor contabilizado
			nXValJaLan := fValLanc(SD1->(Recno()))
			
			If SD1->D1_CUSTO = nXValJaLan
				
				xRet := SD1->D1_CUSTO
				MV_PAR59 := 0
				MV_PAR60 := .F. 
				
			ElseIf nXValJaLan > 0 .AND. SD1->D1_CUSTO > nXValJaLan
			
				xRet 	 := nXValJaLan
				MV_PAR59 := SD1->D1_CUSTO - nXValJaLan
				MV_PAR60 := .T. 
			
			Else
				
				MV_PAR59 := SD1->D1_CUSTO
				MV_PAR60 := .T.
			
			EndIf

		EndIf
		
	ElseIf cXLanPad == "655021" .AND. cXCampo == "CT5_VLR01"

		// Ajustas os MV_PARs que serão utilizados para auxiliar na contabilização 
		fXAjustaMV()	

		xRet := 0
		
		If lXRPCont
			
			If MV_PAR60
				
				If MV_PAR59 > 0
					
					xRet := MV_PAR59
				
					MV_PAR59 := NIL
					MV_PAR60 := NIL
					
				EndIf
				
			EndIf
			
		EndIf	
	
	ElseIf GetSx3Cache(cXCampo,"X3_TIPO") == "N"
	
		xRet := 0
	
	ElseIf GetSx3Cache(cXCampo,"X3_TIPO") == "C"
	
		xRet := ""
	
	ElseIf GetSx3Cache(cXCampo,"X3_TIPO") == "D"
	
		xRet := cToD("")
		
	ElseIf GetSx3Cache(cXCampo,"X3_TIPO") == "L"
	
		xRet := .F.
	
	EndIf 

	RestArea(aXArea)
	RestArea(aXAreaCNA)
	RestArea(aXAreaCNB)
	RestArea(aXAreaCN9)
	RestArea(aXAreaSA2)
Return xRet


/*/{Protheus.doc} fCNBProp
// Função para proporcionalizar CNB
@author danielflavio
@since 28/11/2018
@version 1.0
@return nXValor,Valor Proporcionalizado
@type static function
/*/
Static Function fCNBProp()
	Local aXArea	:= GetArea()
	Local cQuery 	:= ""
	Local nXValor	:= 0
	Local cTmp		:= GetNextAlias()

	cQuery := "   SELECT ISNULL(SUM(CNB_VLTOT),0) TOT_MED FROM "+RetSqlName("CNB")+" CNB   		"
	cQuery += "   WHERE CNB.D_E_L_E_T_=' '   													"
	cQuery += "   AND CNB.CNB_FILIAL='"+aCNBControl[nCNBControl,POS_CN9FIL]+"'   				"
	cQuery += "   AND CNB.CNB_CONTRA='"+aCNBControl[nCNBControl,POS_CN9NUM]+"'   				"
	cQuery += "   AND CNB.CNB_NUMERO='"+aCNBControl[nCNBControl,POS_CNBNUM]+"'   				"
	cQuery += "   AND CNB.CNB_REVISA='"+aCNBControl[nCNBControl,POS_CN9REV]+"'   				"	
	cQuery += "   AND CNB.CNB_CC='"+aCNBControl[nCNBControl,POS_CNBCCU]+"'   					"
	cQuery += "   AND CNB.CNB_CONTA='"+aCNBControl[nCNBControl,POS_CNBCON]+"'   				"
	cQuery += "   AND CNB.CNB_ITEMCT='"+aCNBControl[nCNBControl,POS_CNBITC]+"'   				"	
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
	
	nXValor := (cTmp)->TOT_MED
	
	(cTmp)->(dbCloseArea())

	RestArea(aXArea)
Return nXValor


/*/{Protheus.doc} fDadosCont
// Função para buscar dados do contrato
@author danielflavio
@since 04/12/2018
@version 1.0
@return lRet, 
@param cXFil, characters, Filial
@param cXPed, characters, Número do Pedido de Compras
@param cXCont, characters, Receberá o número do contrato
@param cXContRev, characters, Receberá o número da revisão do contrato
@type static function
/*/
Static Function fDadosCont(cXFil,cXPed,cXItemPed,cXCont,cXContRev)
	Local aXArea 	:= GetArea()
	Local aXAreaSC7 := {}
	Local lRet		:= .F.
	
	dbSelectArea("SC7")
	aXAreaSC7 := SC7->(GetArea())
	SC7->(dbSetOrder(1))
	
	
	If SC7->(dbSeek(cXFil+cXPed+cXItemPed))
	
		If !Empty(SC7->C7_CONTRA)
			lRet := .T.
			cXCont 		:= SC7->C7_CONTRA
			cXContRev	:= SC7->C7_CONTREV
		EndIf
		
	EndIf

	RestArea(aXArea)
	RestArea(aXAreaSC7)
Return lRet


/*/{Protheus.doc} fXResto99
// Função auxiliar para contabilização
@author danielflavio
@since 05/12/2018
@version 1.0
@return xRet, Retorno dinâmico
@param cXOpc, characters, descricao
@param cXFil, characters, descricao
@param cXCont, characters, descricao
@param cXRev, characters, descricao
@param nXVal, numeric, descricao
@type user function
/*/
User Function fXResto99(cXOpc,cXFil,cXCont,cXRev,nXVal)
	Local aXAreas		:= SaveArea1({"SC7","CN9"})
	Local xRet			:= NIL
	Local cQuery		:= ""
	Local cTmp			:= GetNextAlias()
	Default cXOpc		:= ""
	Default	cXFil		:= cFilAnt
	Default cXCont		:= ""
	Default cXRev		:= ""
	Default nXVal		:= 0

	
	// Seleciona áreas
	dbSelectArea("CN9")
	CN9->(dbSetOrder(1))
	
	If cXOpc == "IS_RP"
		
		xRet := .F.
		xRet := !Empty(Posicione("CN9",1,cXFil+cXCont+cXRev,"CN9_XRESTP"))

	ElseIf cXOpc == "CONTABILIZADO"
	
		xRet := .F.
		xRet := !Empty(Posicione("CN9",1,cXFil+cXCont+cXRev,"CN9_XDTLAN"))		
	
	ElseIf cXOpc == "IS_TOTAL"
		
		xRet := .F.
		xRet := Posicione("CN9",1,cXFil+cXCont+cXRev,"CN9_XRESTP")=="T"
		
	ElseIf cXOpc == "IS_PARCIAL"

		xRet := .F.
		xRet := Posicione("CN9",1,cXFil+cXCont+cXRev,"CN9_XRESTP")=="P"
	
	ElseIf cXOpc == "VALOR"

		xRet := 0
		
		If U_fXResto99("IS_RP",cXFil,cXCont,cXRev)
			xRet := Posicione("CN9",1,cXFil+cXCont+cXRev,"CN9_XRESTV")
		EndIf	
		
	ElseIf cXOpc == "VALOR_JA_LANCADO"
	
		xRet := 0
		
		cQuery := "   SELECT ISNULL(SUM(CND_VLTOT),0) TOTAL FROM "+RetSqlName("CND")+" CND   	"
		cQuery += "   INNER JOIN "+RetSqlName("CN9")+" CN9   									"
		cQuery += "   ON CND.CND_FILIAL=CN9.CN9_FILIAL   										"
		cQuery += "   AND CND.CND_CONTRA=CN9.CN9_NUMERO  	 									"
		cQuery += "   WHERE CND.D_E_L_E_T_=' '   												"
		cQuery += "   AND CN9.D_E_L_E_T_=' '   													"
		cQuery += "   AND CND_FILIAL = '"+cXFil+"'   											"
		cQuery += "   AND CND_CONTRA = '"+cXCont+"'   											"
		cQuery += "   AND (CN9.CN9_XRESTP <> ' ' OR CN9.CN9_SITUAC IN ('05')) 					"

		If (Type("SC7->C7_NUM") <> "U" .AND. !Empty(SC7->C7_NUM))
			cQuery += "   AND CND_PEDIDO <> '"+SC7->C7_NUM+"'   								"
		EndIf
		
		cQuery += "   AND CND_XRESTP IN ('T','P','1')   										"	
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cTmp, .F., .T.)	
		
		xRet := (cTmp)->TOTAL
		
		(cTmp)->(dbCloseArea())

	ElseIf cXOpc == "MEDICOES_RESTOS_PAGAR_LANCADAS"
	
		xRet := 0
		
		cQuery := "   SELECT ISNULL(SUM(CND_XRESTV),0) TOTAL FROM "+RetSqlName("CND")+" CND   	"
		cQuery += "   INNER JOIN "+RetSqlName("CN9")+" CN9   									"
		cQuery += "   ON CND.CND_FILIAL=CN9.CN9_FILIAL   										"
		cQuery += "   AND CND.CND_CONTRA=CN9.CN9_NUMERO  	 									"
//		cQuery += "   AND CND.CND_REVISA=CN9.CN9_REVISA   										"
		cQuery += "   WHERE CND.D_E_L_E_T_=' '   												"
		cQuery += "   AND CN9.D_E_L_E_T_=' '   													"
		cQuery += "   AND CND_FILIAL = '"+cXFil+"'   											"
		cQuery += "   AND CND_CONTRA = '"+cXCont+"'   											"
//		cQuery += "   AND CND_REVISA = '"+cXRev+"'   											"
		cQuery += "   AND (CN9.CN9_XRESTP <> ' ' OR CN9.CN9_SITUAC IN ('05')) 					"
		
		If IsInCallStack("U_CN130PGRV")
			cQuery += "   AND CND_NUMMED <> '"+CND->CND_NUMMED+"'   							"
		EndIf
		
		cQuery += "   AND CND_XRESTP IN ('T','P','1')   										"	
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cTmp, .F., .T.)	
		
		xRet := (cTmp)->TOTAL
		
		(cTmp)->(dbCloseArea())
	
	EndIf
	
	// Ajuste de variável
	If xRet = NIL
		xRet := ""
	EndIf
	
	RestArea1(aXAreas)
Return xRet


/*/{Protheus.doc} fXIsCNDRP
// Função que verifica se Medição está flagada ou não como restos a pagar
@author danielflavio
@since 05/12/2018
@version 1.0
@return lRet, Medição está flagada ou não como restos a pagar
@param cXFil, characters, Filial do Contrato
@param cXCont, characters, Número do Contrato
@param cXContRev, characters, Revisão do Contrato
@param cXPed, characters, Número do Pedido de Compras
@type static function
/*/
Static Function fXIsCNDRP(cXFil,cXCont,cXContRev,cXPed)
	Local aXAreaSC7 := SC7->(GetArea())
	Local lRet 		:= .F.
	Local cXNumMed	:= ""
	Local cXPlanilh	:= ""
	
	// Seleciona área de trabalho
	dbSelectArea("SC7")
	SC7->(dbSetOrder(1))
	
	If SC7->(dbSeek(cXFil+cXPed))
	
		cXNumMed := SC7->C7_MEDICAO
		cXPlanilh:= SC7->C7_PLANILH
		
		If !Empty(cXNumMed)

			dbSelectArea("CND")
			CND->(dbSetOrder(1))
			
			If CND->(dbSeek(cXFil+cXCont+cXContRev+cXPlanilh+cXNumMed))
			
				If !Empty(CND->CND_XRESTP)
					lRet := .T.
				EndIf
			
			EndIf
		
		EndIf
	
	EndIf
	
	RestArea(aXAreaSC7)
Return lRet


/*/{Protheus.doc} fXAjustaMV
// Função para ajustar as variáveis do Protheus
@author danielflavio
@since 05/12/2018
@version 1.0
@type static function
/*/
Static Function fXAjustaMV()

	If Type("MV_PAR57") # "C"
		MV_PAR57 := NIL 
		MV_PAR57 := ""
	EndIf
	
	If Type("MV_PAR58") # "N"
		MV_PAR58 := NIL
		MV_PAR58 := 0
	EndIf
	
	If Type("MV_PAR59") # "N"
		MV_PAR59 := NIL		
		MV_PAR59 := 0
	EndIf
	
	If Type("MV_PAR60") # "L"
		MV_PAR60 := NIL
		MV_PAR60 := .F.
	EndIf
			
Return


/*/{Protheus.doc} fValLanc
// Função que busca o último valor lançado de um item da NF em restos a pagar
@author danielflavio
@since 14/12/2018
@version 1.0
@param nXRecno, numeric, Recno da SD1
@type function
/*/
Static Function fValLanc(nXRecno)
	Local aXArea	:= GetArea()
	Local nXRet		:= 0
	Local cQuery	:= ""
	Local cTmp		:= GetNextAlias()

	cQuery := "   SELECT ISNULL(CT2.CT2_VALOR,0) VALOR FROM "+RetSqlName("CT2")+" CT2  "
	cQuery += "   WHERE CT2.R_E_C_N_O_ = (   "
	cQuery += "   	SELECT ISNULL(MAX(CT2B.R_E_C_N_O_),0) VALOR FROM "+RetSqlName("CT2")+" CT2B, "+RetSqlName("CTK")+" CTK   "
	cQuery += "   	WHERE CT2B.D_E_L_E_T_=' '   "
	cQuery += "   	AND CTK.D_E_L_E_T_=' '   "
	cQuery += "   	AND CT2B.CT2_FILIAL=CTK.CTK_FILIAL   "
	cQuery += "   	AND CT2B.CT2_DATA=CTK.CTK_DATA   "
	cQuery += "   	AND CT2B.CT2_KEY=CTK.CTK_KEY   "
	cQuery += "   	AND CT2B.CT2_SEQUEN=CTK.CTK_SEQUEN   "
	cQuery += "   	AND CT2B.CT2_DEBITO=CTK.CTK_DEBITO   "
	cQuery += "   	AND CT2B.CT2_DC = 1   "
	cQuery += "   	AND CT2B.CT2_VALOR > 0   "
	cQuery += "   	AND CT2B.CT2_DEBITO='21011301'   "
	cQuery += "   	AND CTK.CTK_TABORI = 'SD1'   "
	cQuery += "   	AND CTK.CTK_RECORI="+cValToChar(nXRecno)+" )"
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cTmp, .F., .T.)	
	
	If (cTmp)->(!Eof())
		nXRet := (cTmp)->VALOR
	EndIf
		
	(cTmp)->(dbCloseArea())
		
Return nXRet