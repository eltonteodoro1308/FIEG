#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA06
Orcamento das Areas Compartilhadas.

@type function
@author TOTVS
@since 27/04/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SIPCOA06()

Local aCores            := {{"SZR->ZR_STATUS = '1'",'BR_AMARELO'}, ;
                            {"SZR->ZR_STATUS = '2'",'ENABLE'}, ;
					        {"SZR->ZR_STATUS = '3'",'DISABLE'}}
Private cCadastro       := "Orçamento Compartilhado"
Private aRotina         := {{"Pesquisar"       ,"AxPesqui"  ,0 ,1},;
                            {"Visualizar"      ,"U_SIPCO06A",0 ,2},;
                            {"Incluir"         ,"U_SIPCO06A",0 ,3},;
                            {"Alterar"         ,"U_SIPCO06A",0 ,4},;
                            {"Excluir"         ,"U_SIPCO06A",0 ,5},;
                            {"Copiar"          ,"U_SIPCO06A",0 ,6},;
                            {"Revisar"         ,"U_SIPCO06A",0 ,7},;
                            {"Geração de Saldo","U_SIPCO06A",0 ,8},;
                            {"Resumo do Rateio","U_SIPCOR05",0 ,4},;
                            {"Legenda"         ,"BrwLegenda('Orçamento','Legenda',{{'BR_AMARELO','Em Elaboração'},{'ENABLE','Vigente'},{'DISABLE','Revisado'}})",0,3}}

Private cDelFunc        := ".T." 							// Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString         := "SZR"

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
dbSelectArea(cString)
(cString)->(dbSetOrder(1))

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString,,,,,,aCores)

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06A
Orcamento das Areas Compartilhadas.

@type function
@author TOTVS
@since 27/04/2012
@version P12.1.23

@param cAlias, Caractere, Alias da Tabela.
@param nReg, Numérico, Número do registro
@param nOpc, Numérico, Opção da rotina.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SIPCO06A(cAlias,nReg,nOpc)

Local nX 	 	:= 0
Local aAlterEnch:= {}
Local cIniCpos  := ""
Local cFieldOk  := "AllwaysTrue"
Local cSuperDel := ""
Local cDelOk    := "AllwaysTrue"
Local aHeader   := {}
Local aCols     := {}
Local nOpcX		:= 0
Private bRateio := {|| SetKey( VK_F7, NIL ) , SIPCO06Rat() }
Private oDlg
Private oBrw
Private oEnch
Private aTELA[0][0]
Private aGETS[0]

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF nOpc == 4 .and. SZR->ZR_STATUS$"2/3" 					// alteracao
	Aviso("Atenção","Orçamentos vigentes/revisados não podem ser alterados. Verifique!",{"Voltar"})
	Return()
ELSEIF nOpc == 5 .and. SZR->ZR_STATUS$"2/3" 				// exclusao
	Aviso("Atenção","Orçamentos vigentes/revisados não podem ser excluídos. Verifique!",{"Voltar"})
	Return()
ELSEIF nOpc == 7 .and. SZR->ZR_STATUS == "1" 				// revisao
	Aviso("Atenção","Orçamentos em elaboração não podem ser revisados. Verifique!",{"Voltar"})
	Return()
ELSEIF nOpc == 8 											// Geracao de Orçamento
	IF SZR->ZR_STATUS == "1" 								// em elaboracao
		Aviso("Atenção","Orçamentos em elaboração não podem gerar saldos. Verifique!",{"Voltar"})
	ELSE
		SIPCO06Sld()
	ENDIF
	Return()
ENDIF

RegToMemory("SZR", Iif(nOpc==3.or.nOpc==6,.T.,.F.))

//--< Campos editaveis do cabecalho >-----------------------
IF nOpc == 3 .or. nOpc == 6 								// inclusao ou cópia
	Aadd(aAlterEnch,"ZR_ANO")
	Aadd(aAlterEnch,"ZR_STATUS")
ELSEIF nOpc == 4 .or. nOpc == 7 							// alteracao ou revisao
	Aadd(aAlterEnch,"ZR_STATUS")
ENDIF

If nOpc == 7
	M->ZR_REVISAO := SIPCO06Rev()
	M->ZR_STATUS  := "1"
Endif

aNaoSZS  := {"ZS_ANO","ZS_REVISAO"}
IF nOpc == 3
	cSeek  := ""
	cWhile := ""
ELSE
	cSeek := SZR->(ZR_FILIAL+ZR_ANO+ZR_REVISAO)
	cWhile := "SZS->(ZS_FILIAL+ZS_ANO+ZS_REVISAO)"
ENDIF

FillGetDados(IIF(nOpc==3,3,4),"SZS",1,cSeek,{|| &cWhile },{|| .T. },aNaoSZS,/*aSimCpo*/,,,,,aHeader,aCols)

IF Empty(GdFieldGet("ZS_ITEM",1,,aHeader,aCols))
	GDFieldPut("ZS_ITEM",StrZero(1,TamSX3("ZS_ITEM")[1]),1,aHeader,aCols)
ENDIF

//--< Montagem da Tela de Consulta >------------------------
aSizeAut := MsAdvSize()

oDlg := MSDIALOG():New(aSizeAut[7],000, aSizeAut[6],aSizeAut[5], cCadastro,,,,,,,,,.T.)

oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,35,35,.T.,.T. )
oPanel:Align := CONTROL_ALIGN_TOP

If nOpc == 3 .or. nOpc == 6
	INCLUI := .T.
	ALTERA := .F.
	nStyle := GD_INSERT+GD_UPDATE+GD_DELETE
ElseIf nOpc == 4 .or. nOpc == 7
	INCLUI := .F.
	ALTERA := .T.
	nStyle := GD_INSERT+GD_UPDATE+GD_DELETE
Else
	INCLUI := .F.
	nStyle := 0
Endif

nOpcEnch := IIF(nOpc==7,4,nOpc)

oEnch := MsMGet():New("SZR", nReg,nOpcEnch,,,,/*aCpoEnch*/,{0,0,0,0,0},aAlterEnch,3,,,,oPanel,.F.,.T.,.F.,"",.F.,.F.)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

oBrw := MsNewGetDados():New(1,1,1,1,nStyle,"U_SIPCO06LOK","U_SIPCO06TOK(1)", "+ZS_ITEM",,, 9999, cFieldOk, cSuperDel,cDelOk,oDlg, aHeader, aCols)
oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

aButtons := {}
IF INCLUI .or. ALTERA
	SetKey( VK_F7, bRateio )
	Aadd(aButtons,{"BUDGET",{ || SIPCO06Rat() }                                                    , "Rateio"      , "Rateio de Valores nos Periodos <F7>"})
	Aadd(aButtons,{"BUDGET",{ || oBrw:aCols := SIPCOCSV(oBrw:aCols, aHeader, 19), oBrw:Refresh()}, "Importar CSV", "Importar CSV"})
ENDIF

oDlg:bInit	:= {|| EnchoiceBar(oDlg, {|| aCols := aClone(oBrw:aCols), nOpcX:=1,IIf(oBrw:TudoOk().and.Obrigatorio(aGets, aTela),oDlg:End(),nOpcX:=0)}, {||nOpcx := 0, oDlg:End()},,aButtons)}
oDlg:lCentered := .T.
oDlg:Activate()

If nOpcX == 1 .and. !nOpc == 2
	xPCO06GRV(aHeader,aCols,nOpc)							//Gravaçao dos Dados
Endif

SetKey(VK_F7, {|| NIL })

Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} xPCO06GRV
Gravacao dos Dados.

@type function
@author TOTVS
@since 30/04/2012
@version P12.1.23

@param aHeader, Array, Alias da Tabela.
@param aCols, Array, Número do registro
@param nOpc, Numérico, Opção da rotina.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function xPCO06GRV(aHeader,aCols,nOpc)

Local bCampo := {|nCPO| Field(nCPO) }

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
lSavTTsInUse := __TTSInUse									// Backup do TTS

__TTSInUse := .T.											// Ativa TTS

Begin Transaction

If !nOpc == 5
	
	//--< Revisao ele altera o status do orçamento posicionado para 3 = Revisado >--
	IF nOpc == 7
		RecLock("SZR",.F.)
		SZR->ZR_STATUS := "3" 								// Revisado
		SZR->(MsUnLock())
		
		IF (_cNewRev := SIPCO06Rev()) <> M->ZR_REVISAO
			Aviso("Atenção","O código da revisão foi alterado para "+_cNewRev,{"Voltar"})
			M->ZR_REVISAO := _cNewRev
		ENDIF
	ENDIF
	
	SZR->(dbSetOrder(1))
	IF SZR->(dbSeek(xFilial("SZR")+M->(ZR_ANO+ZR_REVISAO)))
		RecLock("SZR",.F.)
	Else
		RecLock("SZR",.T.)
		SZR->ZR_FILIAL := xFilial("SZR")
	EndIf
	
	For nX := 1 TO SZR->(FCount())
		SZR->(FieldPut(nX,M->&(EVAL(bCampo,nX))))
	Next nX
	
	SZR->(MsUnLock())
	
	//--< Grava os itens - Orcamento >----------------------
	
	For nX := 1 To Len(aCols)
		
		_lDelete := IIF(GDDeleted(nX,aHeader,aCols),.t.,.f.)
		
		SZS->(dbSetOrder(1))
		IF !SZS->(dbSeek(XFilial("SZS")+SZR->(ZR_ANO+ZR_REVISAO)+GdFieldGet("ZS_ITEM",nX,,aHeader,aCols)))
			IF _lDelete
				Loop
			ENDIF
			RecLock("SZS",.T.)
			SZS->ZS_FILIAL 	:= xFilial("SZS")
			SZS->ZS_ANO 	:= M->ZR_ANO
			SZS->ZS_REVISAO	:= M->ZR_REVISAO
		ELSE
			RecLock("SZS",.F.)
			IF _lDelete
				SZS->(dbDelete())
				SZS->(msUnlock())
				Loop
			ENDIF
		ENDIF
		
		For nY := 1 to Len(aHeader)
			If aHeader[nY][10] <> "V"
				SZS->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
			EndIf
		Next nY
		
		SZS->(MsUnLock())
	Next nX
	
Else
	
	//--< Exclui linhas do orçamento >----------------------
	SZS->(dbSetOrder(1))
	SZS->(MsSeek(xFilial("SZS")+M->(ZR_ANO+ZR_REVISAO)))
	While SZS->(!Eof()) .and. SZS->(ZS_FILIAL+ZS_ANO+ZS_REVISAO) == XFilial("SZS")+M->(ZR_ANO+ZR_REVISAO)
		Eval({|| RecLock("SZS",.f.), SZS->(dbDelete()), SZS->(MsUnLock()) })
		SZS->(dbSkip())
	EndDo
	
	//--< Exclui cabeçalho >--------------------------------
	SZR->(dbSetOrder(1))
	IF SZR->(MsSeek(xFilial("SZR")+M->(ZR_ANO+ZR_REVISAO)))
		Eval({|| RecLock("SZR",.f.), SZR->(dbDelete()), SZR->(msUnLock()) })
	EndIf
Endif

End Transaction

__TTSInUse := lSavTTsInUse									// Restaura TTS

Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06LOK
Validacao da linha.

@type function
@author TOTVS
@since 01/05/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function SIPCO06LOK()

Local _lRet     := .t.
Local _nPosITEM := GDFieldPos("ZS_ITEM")
Local _nPosCC   := GDFieldPos("ZS_CC")
Local _nPosITCT := GDFieldPos("ZS_ITCTB")
Local _nPosCTA  := GDFieldPos("ZS_CONTA")
Local _nPosCLVL := GDFieldPos("ZS_CLASSE")
Local _cITEM    := GDFieldGet("ZS_ITEM",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
Local _cCCUSTO  := GDFieldGet("ZS_CC",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
Local _cITCTB   := GDFieldGet("ZS_ITCTB",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
Local _cCONTA   := GDFieldGet("ZS_CONTA",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
Local _cCLVL    := GDFieldGet("ZS_CLASSE",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF (_nPos := Ascan(aCols,{|x| !x[Len(aHeader)+1] .and. x[_nPosITEM] <> _cITEM .and. x[_nPosCC] == _cCCUSTO .and. x[_nPosITCT] == _cITCTB .and. x[_nPosCTA] == _cCONTA .and. x[_nPosCLVL] == _cCLVL })) > 0
	_cMens := "Centro de Custo >>"+Chr(9)+_cCCUSTO + Chr(13)+Chr(10)
	_cMens += "Item Contábil >>"   +Chr(9)+Chr(9)+_cITCTB + Chr(13)+Chr(10)
	_cMens += "Conta Contábil >>"  +Chr(9)+Chr(9)+_cCONTA + Chr(13)+Chr(10)
	_cMens += "Classe de Valor >>" +Chr(9)+Chr(9)+_cCLVL
	Aviso("Duplicidade Item: "+GDFieldGet("ZS_ITEM",_nPos,,oBrw:aHeader,oBrw:aCols),_cMens,{"Voltar"})
	_lRet := .F.
ENDIF

Return(_lRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06TOK
Validacao do TudoOk.

@type function
@author TOTVS
@since 01/05/2012
@version P12.1.23

@param _nOpc, Numérico, Opção da rotina.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function SIPCO06TOK(_nOpc)

Local _lRet     := .T.
Local _cArea    := GetArea()
Local _cAreaAK2 := AK2->(GetArea())
Local _cMens    := ""
Local _cDuplic  := ""

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF _nOpc == 1 												// Orcamento
	IF M->ZR_STATUS == "2"
		SZR->(dbSetOrder(2))
		IF SZR->(dbSeek(XFilial("SZR")+M->ZR_ANO+"2")) .and. SZR->(ZR_ANO+ZR_REVISAO) <> M->(ZR_ANO+ZR_REVISAO)
			Aviso("Atenção","Já existe versão vigente de orçamento para este ano. Verifique!",{"Voltar"})
			_lRet := .f.
		ENDIF
	ENDIF
ELSE 														// Geracao de Saldos
	
	_cFilBkp  := cFilAnt
	_nQtde    := 0
	_lOk      := .t.
	_aAreaTMP := TMP->(GetArea())
	TMP->(dbGoTop())
	
	While TMP->(!Eof())
		IF !Empty(TMP->AK1_CODIGO)
			
			cFilAnt := TMP->AK1_FILIAL
			
			AK1->(dbSetOrder(1))
			AK1->(dbSeek(XFilial("AK1")+TMP->(AK1_CODIGO+AK1_VERSAO)))
			
			_cMens += IIF(!Empty(_cMens),CRLF,"")+"Empresa: "+TMP->AK1_FILIAL+" - "+TMP->(Alltrim(AK1_CODIGO)+"/"+AK1_VERSAO)
			_cMens += CRLF
			
			IF AK1->AK1_XAPROV == '1' 						// finalizado
				_cMens += Chr(9)+"Orçamento Finalizado"+CRLF
				_lRet := .F.
				_lOk  := .F.
			ENDIF
			
			If AK1->(FieldPos("AK1_XAPROV"))>0
				If AK1->AK1_XAPROV <> "0"
					_cMens += Chr(9)+"A planilha orçamentária deve estar com a situação igual a '0 - Em aberto' para que possa importar dados. Verifique!"+CRLF
					_lRet := .F.
					_lOk  := .F.
				Endif
			Endif
			
			IF AK1->AK1_XAPROV == '2' 						// aprovado
				_cMens += Chr(9)+"Orçamento Aprovado"+CRLF
				_lRet := .F.
				_lOk  := .F.
			ENDIF
			
			IF Empty(TMP->AKD_CLASSE) .or. Empty(TMP->AKD_OPER)
				_cMens += Chr(9)+"A classe e/ou operação orçamentária não informados"+CRLF
				_lRet := .F.
				_lOk  := .F.
			ENDIF
			
			IF !Empty( _cBloq := SIPCO06Blq(SZR->ZR_ANO,SZR->ZR_REVISAO,TMP->AK1_FILIAL) )
				_cMens += _cBloq
				_lRet := .F.
				_lOk  := .F.
			ENDIF
			
			// Trava desabilitada, pois existem UO's que não trabalham para todas as empresas.
			/*
			IF !SIPCO06Reg(SZR->ZR_ANO,SZR->ZR_REVISAO,TMP->AK1_FILIAL,.f.)
			_cMens += Chr(9)+"Entidade(s) sem regra de rateio (Vide Rel. Inconsistências)"+CRLF
			_lRet := .F.
			_lOk  := .F.
			ENDIF
			*/
			
			IF _lRet
				AK2->(dbSetOrder(1))
				AK2->(dbSeek(xFilial('AK2')+AK1->(AK1_CODIGO+AK1_VERSAO)))
				
				While !Eof() .and. AK2->(AK2_FILIAL+AK2_ORCAME+AK2_VERSAO) = AK1->(AK1_FILIAL+AK1_CODIGO+AK1_VERSAO) .AND. _lRet
					
					If AK2->(AK2_XSTS)	== '1'
						_cMens += Chr(9)+"Existe(m) UO(s) finalizada(s)"+CRLF
						_lRet := .F.
						_lOk  := .F.
					Endif
					
					AK2->(dbSkip())
				Enddo
				
			ENDIF
			
			dbSelectArea("AK2")
			AK2->(dbOrderNickName("SIAK205"))
			
			IF AK2->(dbSeek(xFilial("AK2")+TMP->(AK1_CODIGO+AK1_VERSAO)+SZR->(ZR_ANO+ZR_REVISAO)))
				_cDuplic += TMP->(Alltrim(AK1_CODIGO)+"/"+AK1_VERSAO)+Chr(13)+Chr(10)
			ENDIF
			
			IF _lOk
				_cMens += Chr(9)+"Ok."+CRLF
			ENDIF
			
			_lOk  := .T.
			
			_nQtde++
		ENDIF
		TMP->(dbSkip())
	Enddo
	
	IF _nQtde == 0
		Aviso("Atenção","Nenhum empresa foi selecionada. Verifique",{"Voltar"})
		_lRet := .f.
	ELSE
		IF !_lRet
			Aviso("Inconsistências",_cMens,{"Voltar"},3)
		ELSEIF !Empty(_cDuplic) .and. Aviso("ATENÇÃO","Deseja sobrepor os dados das planilhas abaixo ?"+Chr(13)+Chr(10)+_cDuplic,{"Sim","Não"},3) <> 1
			_lRet := .f.
		ENDIF
	ENDIF
	
	cFilAnt := _cFilBkp
	RestArea(_aAreaTMP)
	
ENDIF

RestArea(_cArea)
AK2->(RestArea(_cAreaAK2))

Return(_lRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06Rat
Rateio de valores.

@type function
@author TOTVS
@since 08/05/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function SIPCO06Rat()

Local oWizard
Local lRet := .F.
Local lParam, lBrowse:=.T., lParam2, lParam3, lParam4
Local aParametros := {{3,"Parametros para o Rateio",1,{"Todos os Periodos","Informar o Periodo"},160,,.F.},;
					  {3,"Ratear percentuais diferenciados"	, 1,{"Sim", "Nao"},160,,.F.},{4,"",.T.,"Sugerir percentuais para os periodos",165,.F.,.F.},;
					  {4,"",.F.,"Sugerir valor Informado para os periodos",165,.F.,.F.} }

Local aConfig :=  { 1, 1, .T., .F.}

Local aParam2 := {{1,"Data inicial",CtoD(Space(8)),"@D","","","lAllPeriod",65,.T.},{1,"Data final",CtoD(Space(8)),"@D","","","lAllPeriod",65,.T.},;
				  { 1 ,"Valor a ser rateado", 0 ,"@E 999,999,999.99" 	 ,""  ,"" ,"" ,65 ,.T. } }
Local aConfig2 := {CtoD(Space(8)), CtoD(Space(8)), 0}

Local aParam3  := {}
Local aConfig3 := {}

Local aParam4  := {}
Local aConfig4 := {}
Private lAllPeriod := .F.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
aPeriodo := PcoRetPer(Stod(M->ZR_ANO+"0101"),Stod(M->ZR_ANO+"1231"))

CTT->(dbSetOrder(1))
CTT->(dbSeek(XFilial("CTT")+GDFieldGet("ZS_CC",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)))

CTD->(dbSetOrder(1))
CTD->(dbSeek(XFilial("CTD")+GDFieldGet("ZS_ITCTB",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)))

AK5->(dbSetOrder(1))
AK5->(dbSeek(XFilial("AK5")+GDFieldGet("ZS_CONTA",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)))

oWizard := APWizard():New("Atencao"/*<chTitle>*/,;
			"Este assistente lhe ajudara a ratear um determinado valor para os periodos da planilha atual."/*<chMsg>*/, "Rateio de Valores para o Orçamento"/*<cTitle>*/,;
			"Voce devera escolher a forma do rateio e ao finalizar o assistente, este valor será rateado conforme os parametros solicitados."+;
			CRLF+CRLF+"Orçamento : "+M->(ZR_ANO+ZR_REVISAO)+;
			CRLF+CRLF+"UO : "+ CTT->(Alltrim(CTT_CUSTO)+" - "+CTT->CTT_DESC01)+;
			CRLF+CRLF+"CR : "+ CTD->(Alltrim(CTD_ITEM)+" - "+CTD->CTD_DESC01)+;
			CRLF+CRLF+"Conta : "+AK5->(Alltrim(AK5_CODIGO)+" - "+AK5->AK5_DESCRI),;
			{||.T.}/*<bNext>*/, ;
			{|| .T.}/*<bFinish>*/,;
			/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

oWizard:NewPanel( "Rateio de valor"/*<chTitle>*/,;
		"Neste passo voce deverá informar a forma do rateio para a planilha orcamentaria."/*<chMsg>*/, ;
		{||.T.}/*<bBack>*/, ;
		{||lAllPeriod := (aConfig[1]==2), aConfig2 := {Stod(M->ZR_ANO+"0101"), Stod(M->ZR_ANO+"1231"), 0},.T.}/*<bNext>*/, ;
		{||.T.}/*<bFinish>*/,;
		.T./*<.lPanel.>*/,;
		{||SIPCOPar1(oWizard,@lParam, aParametros, aConfig)}/*<bExecute>*/ )

oWizard:NewPanel( "Periodo para o rateio"/*<chTitle>*/,;  //
		"Neste momento deverá ser informado o periodo a ser considerado e o valor a ser rateado."/*<chMsg>*/,;
		{||.T.}/*<bBack>*/, ;
		{||SIPCO06Per(aConfig2, aPeriodo).And.aConfig2[3]>0}/*<bNext>*/, ;
		{||.T.}/*<bFinish>*/,;
		.T./*<.lPanel.>*/, ;
		{||SIPCOPar2(oWizard, lParam2, aParam2, aConfig2)}/*<bExecute>*/ )

oWizard:NewPanel( "Percentuais para os periodos "/*<chTitle>*/,; //
		"Neste passo voce deverá informar os percentuais referente ao valor a serem considerado para o rateio."/*<chMsg>*/, ;
		{||.T.}/*<bBack>*/, ;
		{||SIPCO06Val(aConfig, aConfig3, aPeriodo)}/*<bNext>*/, ;
		{||.T.}/*<bFinish>*/, ;
		.T./*<.lPanel.>*/, ;
		{||SIPCOPar3(oWizard, lParam3, aParam3, aConfig3, aPeriodo, aConfig, aConfig2)}/*<bExecute>*/ )

oWizard:NewPanel( "Confirme os valores que serao rateados para os periodos. "/*<chTitle>*/,;
		"Observacao: os Valores zerados nao serao repassados para os periodos."/*<chMsg>*/, ;
		{||.T.}/*<bBack>*/, ;
		{||.T.}/*<bNext>*/, ;
		{|| lRet := .T.}/*<bFinish>*/, ;
		.T./*<.lPanel.>*/, ;
		{||SIPCOPar4(oWizard, lParam4, aParam4, aConfig4, aPeriodo, aConfig, aConfig2, aConfig3)}/*<bExecute>*/ )

oWizard:Activate( .T./*<.lCenter.>*/,;
		{||.T.}/*<bValid>*/, ;
		{||.T.}/*<bInit>*/, ;
		{||.T.}/*<bWhen>*/ )

IF lRet
	aValores := aClone(aConfig4)
	For i := 1 to Len(aValores)
		IF aValores[i] <> 0
			GDFieldPut("ZS_MES"+StrZero(i,2),aValores[i],oBrw:oBrowse:nAt,oBrw:aHeader,oBrw:aCols)
		ENDIF
	Next
ENDIF

SetKey( VK_F7, bRateio )
oBrw:oBrowse:Refresh()

Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOPar1
Funcao para escolha da forma do rateio .

@type function
@author TOTVS
@since 09/05/2012 
@version P12.1.23

@param oWizard, Objeto, Objeto da janela.
@param lParam, Lógico, Verdadeiro se os parâmetros já foram definidos.
@param aParametros, Array, Parâmetros da rotina.
@param aConfig, Array, Configuração dos parâmetros.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function SIPCOPar1(oWizard, lParam, aParametros, aConfig)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If lParam == NIL
	ParamBox(aParametros ,"Parametros", aConfig,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])
	lParam := .T.
EndIf

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOPar2
Funcao para parametrizar o periodo e o valor a ser rateado.

@type function
@author TOTVS
@since 09/05/2012 
@version P12.1.23

@param oWizard, Objeto, Objeto da janela.
@param lParam2, Lógico, Verdadeiro se os parâmetros já foram definidos.
@param aParam2, Array, Parâmetros da rotina.
@param aConfig2, Array, Configuração dos parâmetros.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function SIPCOPar2(oWizard, lParam2, aParam2, aConfig2)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If lParam2 == NIL
	ParamBox(aParam2 ,"Parametros", aConfig2,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])
	lParam2 := .T.
EndIf

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06Per
Valida o periodo informado no Wizard.

@type function
@author TOTVS
@since 09/05/2012 
@version P12.1.23

@param aConfig2, Array, Configuração dos parâmetros.
@param aPeriodo, Array, Período a ser validado.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

Static Function SIPCO06Per(aConfig2, aPeriodo)

Local lRet
Local nPosDtFim

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If Len(aPeriodo) == 0
	lRet := .F.
Else
	lRet := .T.
	nPosDtFim := At("-", aPeriodo[Len(aPeriodo)]) + 1
EndIf

If lRet
	lRet := ( aConfig2[1] >= CtoD( Subs(aPeriodo[1], 1, 10) ))
EndIf

If lRet
	lRet := ( aConfig2[2] >= CtoD(Subs(aPeriodo[1], 1, 10) ))
EndIf

If lRet
	lRet := ( aConfig2[2] <= CtoD(Alltrim( Subs( aPeriodo[Len(aPeriodo)], nPosDtFim ) )))
EndIf

If !lRet
	Aviso("Data Invalida","As datas informadas nao sao validas para o periodo da planilha. Verifique.",{"Ok"})
EndIf

Return(lRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOPar3
Funcao para parametrizar os percentuais nos periodos.

@type function
@author TOTVS
@since 09/05/2012 
@version P12.1.23

@param oWizard, Array, Configuração dos parâmetros.
@param lParam3, Lógico, Verdadeiro se os parâmetros já foram definidos.
@param aParam3, Array, Período a ser validado.
@param aConfig3, Array, Configuração dos parâmetros.
@param aPeriodo, Array, Período a ser validado.
@param aConfig, Array, Configuração dos parâmetros.
@param aConfig2, Array, Configuração dos parâmetros.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

Static Function SIPCOPar3(oWizard, lParam3, aParam3, aConfig3, aPeriodo, aConfig, aConfig2)

Local nX, nPercDef, aRetPer, dAuxIni, dAuxFim
Local lPeriodo

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
aParam3 := {}
aConfig3 := {}

If aConfig[1] == 1 //todos os periodos
	If aConfig[3] .OR. aConfig[4]
		If aConfig[4]
			nPercDef := 100
		Else
			nPercDef := 100/Len(aPeriodo)
		EndIf
	Else
		nPercDef := 0
	EndIf
	aAdd(aParam3, {4,"Informar Percentuais",aConfig[3],"  ",165,.F.,.F.})
	aAdd(aConfig3, aConfig[3])
	For nX := 1 TO Len(aPeriodo)
		aAdd(aParam3,{ 1 ,aPeriodo[nX], nPercDef ,"@E 999.9999 %" 	 ,""  ,"" ,"",65 ,.T. })
		aAdd(aConfig3, nPercDef)
	Next
Else
	dAuxIni := aConfig2[1]
	dAuxFim := aConfig2[2]
	
	aRetPer := SIPCO06Det(dAuxIni, dAuxFim, aPeriodo)
	nPeriodo := (aRetPer[2]-aRetPer[1])+1
	
	If aConfig[3] .OR. aConfig[4]
		If aConfig[4]
			nPercDef := 100
		Else
			nPercDef := 100/nPeriodo
		EndIf
	Else
		nPercDef := 0
	EndIf
	
	aAdd(aParam3, {4,"Informar Percentuais",(aConfig[2]==1),"  ",165,.F.,.T.})
	aAdd(aConfig3, (aConfig[2]==1))
	For nX := 1 TO Len(aPeriodo)
		lPeriodo := (nX >=aRetPer[1].And.nX<=aRetPer[2])
		aAdd(aParam3,{ 1 ,aPeriodo[nX], If(lPeriodo, nPercDef, 0) ,"@E 999.9999 %" 	 ,""  ,"" ,If(lPeriodo.And.aConfig[2]==1 , "", ".F.") ,65 ,.T. })
		aAdd(aConfig3, If(lPeriodo, nPercDef, 0))
	Next
EndIf

If lParam3 == NIL
	ParamBox(aParam3 ,"Parametros", aConfig3,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])
	lParam3 := .T.
EndIf

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOPar4
Funcao para parametrizar os percentuais nos periodos.

@type function
@author TOTVS
@since 09/05/2012 
@version P12.1.23

@param oWizard, Array, Configuração dos parâmetros.
@param lParam4, Lógico, Verdadeiro se os parâmetros já foram definidos.
@param aParam4, Array, Período a ser validado.
@param aConfig4, Array, Configuração dos parâmetros.
@param aPeriodo, Array, Período a ser validado.
@param aConfig, Array, Configuração dos parâmetros.
@param aConfig2, Array, Configuração dos parâmetros.
@param aConfig3, Array, Configuração dos parâmetros.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

Static Function SIPCOPar4(oWizard, lParam4, aParam4, aConfig4, aPeriodo, aConfig, aConfig2, aConfig3)

Local nX
Local nUltArray := 0
Local nTotVal	:= 0

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
aParam4 := {}
aConfig4 := {}

For nX := 2 TO Len(aPeriodo)+1
	If aConfig3[nX] > 0
		nValorRat := Round(aConfig2[3]*(aConfig3[nX]/100),TamSX3("AK2_VALOR")[2])
		aAdd(aParam4,{ 1 ,aPeriodo[nX-1], nValorRat ,"@E 999,999,999.99" 	 ,""  ,"" , ".F.",65 ,.T. })
		aAdd(aConfig4, nValorRat)
		nTotVal += nValorRat
		nUltArray := nX
	Else
		aAdd(aParam4,{ 1 ,aPeriodo[nX-1], 0 ,"@E 999,999,999.99" 	 ,""  ,"" , ".F.",65 ,.T. })
		aAdd(aConfig4, 0)
	EndIf
Next

If nUltArray == Len(aPeriodo)+1 							//O tamanho da variável está maior que o tamanho total do array?
	nUltArray--
EndIf

If (aConfig2[3] - nTotVal) > 0 								//Tem diferenca de valor
	aConfig4[nUltArray] += (aConfig2[3] - nTotVal)
	aParam4[nUltArray][3] += (aConfig2[3] - nTotVal)
EndIf

If lParam4 == NIL
	ParamBox(aParam4 ,"Parametros", aConfig4,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])
	lParam4 := .T.
EndIf

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06Det
Funcao para parametrizar os percentuais nos periodos.

@type function
@author TOTVS
@since 09/05/2012 
@version P12.1.23

@param dAvalIni, Data, Configuração dos parâmetros.
@param dAvalFim, Data, Verdadeiro se os parâmetros já foram definidos.
@param aPeriodo, Array, Período a ser validado.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Data Inicial e Final.
/*/
/*/================================================================================================================================/*/

Static Function SIPCO06Det(dAvalIni, dAvalFim, aPeriodo)

Local aRetPer := { CtoD(Space(8)), CtoD(Space(8)) }
Local nX, dIni, dFim

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
For nX := 1 TO Len(aPeriodo)
	dIni := CTOD(Subs(aPeriodo[nX], 1, 10))
	dFim := CTOD(Alltrim(Subs(aPeriodo[nX], 14)))
	If dAvalIni >= dIni .And. dAvalIni <= dFim
		aRetPer[1] := nX
		Exit
	EndIf
Next

For nX := 1 TO Len(aPeriodo)
	dIni := CTOD(Subs(aPeriodo[nX], 1, 10))
	dFim := CTOD(Alltrim(Subs(aPeriodo[nX], 14)))
	If dAvalFim >= dIni .And. dAvalFim <= dFim
		aRetPer[2] := nX
		Exit
	EndIf
Next

Return aRetPer


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06Val
Valida percentuais informados para atingir 100% (exceto em caso de sugestao de valor para o periodo).

@type function
@author TOTVS
@since 09/05/2012 
@version P12.1.23

@param aConfig, Array, Configuração dos parâmetros.
@param aConfig3, Array, Configuração dos parâmetros.
@param aPeriodo, Array, Período a ser validado.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

Static Function SIPCO06Val(aConfig, aConfig3, aPeriodo)

Local nX, lRet := .F.
Local nSum := 0
Local nDif := 0

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
For nX := 2 TO Len(aPeriodo)+1
	nSum += aConfig3[nX]
Next

If aConfig[4]
	lRet := .T.   											//nao valida se valor fixo para os periodos
Else
	If aConfig[2]==2
		nDif := 100.00-Round(nSum,4)
		If nDif != 0
			aConfig3[Len(aConfig3)] := aConfig3[Len(aConfig3)]+nDif
		EndIf
		lRet := .T.
	Else
		lRet := (Round(nSum,4)==100.00)
		If !lRet
			Aviso("Percentual Invalido","Os percentuais informados devem atingir somente 100%. Verifique."+CRLF+CRLF+"Percentual Atingido: "+Str(nSum,12,4)+" %",{"Ok"})
		EndIf
	EndIf
EndIf

Return(lRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06Sld
Geracao de movimentos e saldos na planilhas.

@type function
@author TOTVS
@since 09/05/2012 
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

Static Function SIPCO06Sld()

Local _cFilBkp   := cFilAnt
Local _cArea     := GetArea()
Local _bAtuPlan  := {|| RecLock("TMP",.f.), TMP->AK1_CODIGO := AK1->AK1_CODIGO,TMP->AK1_VERSAO := AK1->AK1_VERSAO,TMP->AK1_DESCRI := AK1->AK1_DESCRI, TMP->(msUnlock()) }
Local _bPlanilha := { || SetKey( VK_F7, NIL ), _aAreaAtu := GetArea(), cFilAnt := TMP->AK1_FILIAL, _lRet := ConPad1(,,,"AK1",,,.F.),IIF(_lRet,Eval(_bAtuPlan),), cFilAnt := _cFilBkp, _aAreaAtu := GetArea(), SetKey( VK_F7, _bPlanilha ) }
Local aButton    := {{"NOTE", {|| SIPCO06Reg(SZR->ZR_ANO,SZR->ZR_REVISAO,TMP->AK1_FILIAL,.t.) } ,"Rel. Inconsistências"},{"PESQUISA", _bPlanilha ,"Selecionar Planilha <F7>"},{"LBNO", {|| RecLock("TMP",.f.), TMP->AK1_CODIGO := "",TMP->AK1_VERSAO := "",TMP->AK1_DESCRI := "", TMP->AKD_CLASSE := "",TMP->AKD_OPER := "",TMP->(msUnlock()) } ,"Desmarcar Planilha <F8>"}}
Local _lContinua := .t.
Local lOk        := .f.
Private aCols    := {}
Private n        := 1
Private _nTotLin := 0
Private aHeader  := {}
Private aAltera  := {}
Private _cArqTMP := ""
Private _aPercs  := {}

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF SZR->ZR_STATUS <> '2'
	Aviso("Atenção","Apenas orçamentos vigentes podem gerar saldos. Verifique!",{"Voltar"})
	Return()
ENDIF

IF !SIPCO06Cpo()
	Aviso("Atenção","Não existem regras de rateio cadastradas. Verifique!",{"Sair"})
	_lContinua := .f.
ENDIF

IF _lContinua
	
	SetKey( VK_F7, _bPlanilha )
	SetKey( VK_F8, {|| RecLock("TMP",.f.), TMP->AK1_CODIGO := "",TMP->AK1_VERSAO := "",TMP->AK1_DESCRI := "", TMP->AKD_CLASSE := "",TMP->AKD_OPER := "",TMP->(msUnlock()) } )
	
	DEFINE FONT oFnt 	NAME "Arial" SIZE 0, -15 BOLD
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 to 300,800 OF oMainWnd PIXEL
	
	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,25,25,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_BOTTOM
	
	@ 004,005 SAY OemToAnsi("F7 = Selecionar Planilha") Of oPanel PIXEL	FONT oFnt
	@ 014,005 SAY OemToAnsi("F8 = Desmarcar Planilha")  Of oPanel PIXEL	FONT oFnt
	
	oGetDB := 	MSGetDB():New( 034, 005, 226, 415, 3,"AllwaysTrue", "AllwaysTrue", "",.t.,aAltera,,.t., _nTotLin,"TMP",,,,oDlg,,,)
	oGetDB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| IIF(U_SIPCO06TOK(2) .and. MsgYesNo("Confirma processamento ?"),Eval({|| oDlg:End(),lOk := .T. }),) },{|| lOk := .F.,oDlg:End()},,aButton)
	
	IF lOk 													// Confirmou
		
		TMP->(dbGoTop())
		
		Begin Transaction
		
		While TMP->(!Eof())
			IF !Empty(TMP->AK1_CODIGO)
				cFilAnt := TMP->AK1_FILIAL
				
				AK1->(dbSetOrder(1))
				AK1->(dbSeek(XFilial("AK1")+TMP->(AK1_CODIGO+AK1_VERSAO)))
				
				dbSelectArea("AK2")
				AK2->(dbOrderNickName("SIAK205"))
				
				IF AK2->(dbSeek(xFilial("AK2")+TMP->(AK1_CODIGO+AK1_VERSAO)+SZR->(ZR_ANO+ZR_REVISAO)))
					MsgRun('Excluindo lançamentos da empresa '+TMP->AK1_FILIAL+'. Aguarde...',, {|| SIPCO06Del() } )
				ENDIF
				
				MsgRun('Gerando dados na empresa '+TMP->AK1_FILIAL+'. Aguarde...',, {|| SIPCO06Run() } )
				
			ENDIF
			TMP->(dbSkip())
		Enddo
		
		End Transaction
		
		cFilAnt := _cFilBkp
	ENDIF
	
ENDIF

TMP->(dbCloseArea())
FErase("TMP"+GetDBExtension())
FErase("TMP"+OrdBagExt())
RestArea(_cArea)

Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06Cpo
Carrega os cabeçalho para geracao da planilha.

@type function
@author TOTVS
@since 09/05/2012 
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

Static Function SIPCO06Cpo()

Local _aAreaSX3 := SX3->(GetArea())
Local _aCampos	:= {}
Local _cQuery   := ""
Local _cArqEMP  := CriaTrab(nil,.f.)
Local _lRet     := .t.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Montagem da matriz aHeader >--------------------------
SX3->(dbSetOrder(2))
IF SX3->(dbSeek("AK1_FILIAL"))
	Aadd(aHeader,{"Empresa",SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,"SM0EMP",SX3->X3_CONTEXT} )
	Aadd( _aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
ENDIF

IF SX3->(dbSeek("AK1_CODIGO"))
	Aadd(aHeader,{TRIM(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,"",SX3->X3_CONTEXT} )
	Aadd( _aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
ENDIF

IF SX3->(dbSeek("AK1_VERSAO"))
	Aadd(aHeader,{TRIM(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,"",SX3->X3_CONTEXT} )
	Aadd( _aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
ENDIF

IF SX3->(dbSeek("AK1_DESCRI"))
	Aadd(aHeader,{TRIM(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,50,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,"",SX3->X3_CONTEXT} )
	Aadd( _aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
ENDIF

IF SX3->(dbSeek("AKD_CLASSE"))
	Aadd(aHeader,{TRIM(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,"",SX3->X3_CONTEXT} )
	Aadd( _aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	Aadd(aAltera,SX3->X3_CAMPO)
ENDIF

IF SX3->(dbSeek("AKD_OPER"))
	Aadd(aHeader,{TRIM(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,"",SX3->X3_CONTEXT} )
	Aadd(_aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	Aadd(aAltera,SX3->X3_CAMPO)
ENDIF

_cArqTMP := CriaTrab( _aCampos, .t. )
dbUseArea( .t., ,_cArqTMP, "TMP", .f., .f. )
TMP->(__dbZap())

_cQuery := "SELECT DISTINCT ZV_CODEMP FROM "+RetSqlname("SZT")+" SZT "
_cQuery += "INNER JOIN "+RetSqlname("SZU")+" SZU ON ZT_ANO = ZU_ANO AND ZT_REVISAO = ZU_REVISAO "
_cQuery += "INNER JOIN "+RetSqlname("SZV")+" SZV ON ZV_ANO = ZU_ANO AND ZV_REVISAO = ZU_REVISAO AND ZV_ITEMSZU = ZU_ITEM "
_cQuery += "WHERE SZT.D_E_L_E_T_ = ' ' AND SZU.D_E_L_E_T_ = ' ' AND SZV.D_E_L_E_T_ = ' ' "
_cQuery += "AND ZT_FILIAL = '"+XFilial("SZT")+"' AND ZU_FILIAL = '"+XFilial("SZU")+"' AND ZV_FILIAL = '"+XFilial("SZV")+"' "
_cQuery += "AND ZT_ANO = '"+SZR->ZR_ANO+"' AND ZT_STATUS = '2' "
_cQuery += "ORDER BY 1"
_cQuery := ChangeQuery(_cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqEMP,.t.,.t.)

IF (_cArqEMP)->(Eof())
	_lRet := .f.
ELSE
	While (_cArqEMP)->(!Eof())
		RecLock("TMP",.t.)
		TMP->AK1_FILIAL := (_cArqEMP)->ZV_CODEMP
		TMP->(msUnlock())
		_nTotLin++
		(_cArqEMP)->(dbSkip())
	Enddo
ENDIF

(_cArqEMP)->(dbCloseArea())
FErase(_cArqEMP+GetDBExtension())
FErase(_cArqEMP+OrdBagExt())
RestArea(_aAreaSX3)

Return(_lRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06Del
Exclusao de movimentos da planilha.

@type function
@author TOTVS
@since 09/05/2012 
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function SIPCO06Del()

Local _cID := ""

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
PcoIniLan('000252')
While AK2->(!Eof()) .and. AK2->AK2_FILIAL == XFilial("AK2") .and. AK2->(AK2_ORCAME+AK2_VERSAO+AK2_XORCTO) == TMP->(AK1_CODIGO+AK1_VERSAO)+SZR->(ZR_ANO+ZR_REVISAO)
	
	IF !Empty(_cID) .and. AK2->AK2_ID <> _cID
		PcoDetLan("000252","01","PCOA100", .T. )
	ENDIF
	
	RecLock("AK2",.F.)
	AK2->(dbDelete())
	AK2->(MsUnlock())
	
	_cID := AK2->AK2_ID
	
	AK2->(dbSkip())
Enddo
PcoFinLan('000252')

Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06Run
Processamento dos movimentos orcamentarios.

@type function
@author TOTVS
@since 11/05/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function SIPCO06Run()

Local _cArea := GetArea()

Private _nMaxReg := GetMV("MV_PCOLIMI")
Private _nTotReg := 0

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
SZS->(dbSetOrder(1))
SZS->(dbSeek(XFilial("SZS")+SZR->(ZR_ANO+ZR_REVISAO)))

//--< Inicializa a gravacao dos lancamentos do SIGAPCO >----
PcoIniLan("000252")

While SZS->(!Eof()) .and. SZS->ZS_FILIAL == XFilial("SZS") .and. SZS->(ZS_ANO+ZS_REVISAO) == SZR->(ZR_ANO+ZR_REVISAO)
	
	_nPos := aScan(_aPercs,{|x| x[1]+x[2]+x[3]+x[4]+x[5] == TMP->AK1_FILIAL+SZS->(ZS_CC+ZS_ITCTB+ZS_CLASSE+ZS_CONTA) } )
	
	IF _nPos > 0
		_nPerc := _aPercs[_nPos,6]
	ELSE
		_nPerc := _SIPCOPerc(TMP->AK1_FILIAL,SZS->ZS_CC,SZS->ZS_ITCTB,SZS->ZS_CLASSE,SZS->ZS_CONTA)
	ENDIF
	
	IF _nPerc == 0
		SZS->(dbSkip())
		Loop
	ENDIF
	
	SIPCO06Orc(_nPerc)
	
	SZS->(dbSkip())
Enddo

//--< Finaliza a gravacao dos lancamentos do SIGAPCO >------
PcoFinLan("000252")

RestArea(_cArea)

Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} _SIPCOPerc
Calcula Percentual da empresa.

@type function
@author TOTVS
@since 11/05/2012
@version P12.1.23

@param _cEmpresa, Caractere, Código da Empresa.
@param _cCC, Caractere, Código do Centro de Custo.
@param _cITCTB, Caractere, Código do Item Contábil.
@param _cCLVL, Caractere, Código da Classe de Valor.
@param _cConta, Caractere, Código da Conta Orçamentária.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Numérico, Percentual.
/*/
/*/================================================================================================================================/*/

Static Function _SIPCOPerc(_cEmpresa,_cCC,_cITCTB,_cCLVL,_cConta)

Local _cArea   := GetArea()
Local _cQuery  := ""
Local _cArqPER := CriaTrab(nil,.f.)
Local _nRet    := 0

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
_cQuery := "SELECT ZV_PERC FROM "+RetSqlName("SZT")+" SZT "
_cQuery += "INNER JOIN "+RetSqlName("SZU")+" SZU ON ZT_ANO = ZU_ANO AND ZT_REVISAO = ZU_REVISAO "
_cQuery += "INNER JOIN "+RetSqlName("SZV")+" SZV ON ZV_ANO = ZU_ANO AND ZV_REVISAO = ZU_REVISAO AND ZV_ITEMSZU = ZU_ITEM "
_cQuery += "WHERE SZT.D_E_L_E_T_ = ' ' AND SZU.D_E_L_E_T_ = ' ' AND SZV.D_E_L_E_T_ = ' ' "
_cQuery += "AND ZT_FILIAL = '"+XFilial("SZT")+"' AND ZU_FILIAL = '"+XFilial("SZU")+"' AND ZV_FILIAL = '"+XFilial("SZV")+"' "
_cQuery += "AND ZV_CODEMP = '"+_cEmpresa+"' "
_cQuery += "AND ZU_CC = '"+Alltrim(_cCC)+"' AND ZU_ITCTB = '"+_cITCTB+"' "
_cQuery += "AND '"+Alltrim(_cCLVL)+"'"+" BETWEEN ZU_CLVLI AND ZU_CLVLF "
_cQuery += "AND '"+Alltrim(_cConta)+"'"+" BETWEEN ZU_CONTAI AND ZU_CONTAF "
_cQuery += "AND ZT_ANO = '"+SZR->ZR_ANO+"' AND ZT_STATUS = '2' "
_cQuery += "ORDER BY ZT_REVISAO DESC"
_cQuery := ChangeQuery(_cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqPER,.t.,.t.)

IF (_cArqPER)->(!Eof())
	Aadd(_aPercs,{_cEmpresa,_cCC,_cITCTB,_cCLVL,_cConta,(_cArqPER)->ZV_PERC})
	_nRet := (_cArqPER)->ZV_PERC
ENDIF

(_cArqPER)->(dbCloseArea())
FErase(_cArqPER+GetDBExtension())
FErase(_cArqPER+OrdBagExt())
RestArea(_cArea)

Return(_nRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06ID
Calcula ID da AK2.

@type function
@author TOTVS
@since 11/05/2012
@version P12.1.23

@param _cPlan, Caractere, Código da Planilha Orçamentária.
@param _cVersao, Caractere, Versão da Planilha.
@param _cConta, Caractere, Código da Conta Orçamentária.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, Próximo AK2_ID.
/*/
/*/================================================================================================================================/*/

Static Function SIPCO06ID(_cPlan,_cVersao,_cConta)

Local _cRet     := StrZero(0,TamSX3("AK2_ID")[1])
Local _cAreaAK2 := AK2->(GetArea())

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
AK2->(dbSetOrder(5))
AK2->(dbSeek(xFilial("AK2") + _cPlan+_cVersao+_cConta ))

While AK2->(!Eof()) .and. AK2->(AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO)  == xFilial("AK2") + _cPlan+_cVersao+_cConta
	_cRet := AK2->AK2_ID
	AK2->(dbSkip())
End

RestArea(_cAreaAK2)

Return(Soma1(_cRet))


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06Orc
Rotina de geracao de Orcamento.

@type function
@author TOTVS
@since 11/05/2012
@version P12.1.23

@param _nPerc, Numérico, Percentual.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function SIPCO06Orc(_nPerc)

Local nX := 0
Local cNivel   := "001"
Local aRecAK3  := {}
Local aPeriodo := PcoRetPer()
Local cPlanOri := AK1->AK1_CODIGO
Local cRevOri  := IF(Empty(AK1->AK1_VERREV), AK1->AK1_VERSAO, AK1->AK1_VERREV)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
_cNextID := SIPCO06ID(cPlanOri,cRevOri,SZS->ZS_CONTA)

For nX := 1 to Len(aPeriodo)
	
	IF SZS->&("ZS_MES"+Substr(aPeriodo[nx],4,2)) == 0
		Loop
	ENDIF
	
	RecLock("AK2",.T.)
	AK2->AK2_FILIAL := xFilial("AK2")
	AK2->AK2_ORCAME := cPlanOri
	AK2->AK2_VERSAO := cRevOri
	AK2->AK2_MOEDA	:= 1
	AK2->AK2_PERIOD	:= CTOD(Substr(aPeriodo[nx],1,10))
	AK2->AK2_DATAI	:= CTOD(Substr(aPeriodo[nx],1,10))
	AK2->AK2_DATAF	:= CTOD(Substr(aPeriodo[nx],14,16))
	AK2->AK2_ID		:= _cNextID
	AK2->AK2_XORCTO	:= SZR->(ZR_ANO+ZR_REVISAO)
	AK2->AK2_OPER	:= TMP->AKD_OPER
	AK2->AK2_XSTS	:= "0" // status da UO
	AK2->AK2_CO 	:= SZS->ZS_CONTA
	AK2->AK2_CC 	:= SZS->ZS_CC
	AK2->AK2_ITCTB 	:= SZS->ZS_ITCTB
	AK2->AK2_CLVLR  := SZS->ZS_CLASSE
	AK2->AK2_CLASSE := TMP->AKD_CLASSE
	AK2->AK2_VALOR	:= SZS->&("ZS_MES"+Substr(aPeriodo[nx],4,2)) * (_nPerc/100)
	AK2->(MsUnlock())
	
	dbSelectArea("AK3")
	dbSetOrder(1)
	
	If !AK3->(dbSeek(xFilial('AK3')+AK2->AK2_ORCAME+AK2->AK2_VERSAO+AK2->AK2_CO))
		cNivel := "001"
		GravaAK3(AK2->AK2_ORCAME,AK2->AK2_VERSAO,AK2->AK2_CO,aRecAK3,@cNivel)
		
		For nt := Len(aRecAK3) to 1 Step -1
			cNivel := Soma1(cNivel)
			AK3->(dbGoto(aRecAK3[nt]))
			RecLock("AK3",.F.)
			AK3->AK3_NIVEL := cNivel
			AK3->(MsUnlock())
		Next nt
	EndIf
	
	dbSelectArea("AK2")
	
	PcoDetLan("000252","01","SIPCOA06")
	
	_nTotReg++
	
	IF _nTotReg >= _nMaxReg
		_nTotReg := 0
		PcoFinLan("000252")
		PcoIniLan("000252")
	ENDIF
	
Next nX

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} GravaAK3
Inclui as contas orcamentarias ref a tab (AK3) posicionado utiliza recursividade ao chamar a funcao A200Nivel() para chamar novamente xIncConta para as contas pai.

@type function
@author TOTVS
@since 21/11/2011
@version P12.1.23

@param cOrcame, Caractere, Planilha Orçamentária.
@param cVersao, Caractere, Versão da Planilha.
@param cCO, Caractere, Conta Orçamentária.
@param aRecAK3, Array, Recno do AK3.
@param cNivel, Caractere, Nível.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function GravaAK3(cOrcame,cVersao,cCO,aRecAK3,cNivel)

Local aArea := GetArea()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
dbSelectArea("AK5")
dbSetOrder(1)
If MsSeek(xFilial()+cCO)
	PmsNewRec("AK3")
	AK3->AK3_FILIAL 	:= xFilial("AK3")
	AK3->AK3_ORCAME		:= cOrcame
	AK3->AK3_VERSAO		:= cVersao
	AK3->AK3_CO			:= cCO
	AK3->AK3_PAI		:= If(Empty(AK5->AK5_COSUP),cOrcame,AK5->AK5_COSUP)
	AK3->AK3_TIPO		:= AK5->AK5_TIPO
	AK3->AK3_DESCRI		:= AK5->AK5_DESCRI
	MsUnlock()
	aAdd(aRecAK3,AK3->(RecNo()))
	dbSelectArea("AK3")
	dbSetOrder(1)
	If !Empty(AK5->AK5_COSUP)
		If !dbSeek(xFilial('AK3')+cOrcame+cVersao+AK5->AK5_COSUP)
			GravaAK3(AK2->AK2_ORCAME,AK2->AK2_VERSAO,AK5->AK5_COSUP,aRecAK3,@cNivel)
		Else
			cNivel := AK3->AK3_NIVEL
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06Rev
Calculo proxima revisao.

@type function
@author TOTVS
@since 15/05/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, Próximo número da Revisão (ZR_REVISAO).
/*/
/*/================================================================================================================================/*/


Static Function SIPCO06Rev()

Local _cQuery  := ""
Local _cArqRev := CriaTrab(nil,.f.)
Local _cArea   := GetArea()
Local _cRet    := "01"

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
_cQuery := "SELECT MAX(ZR_REVISAO) ZR_REVISAO FROM "+RetSqlName("SZR")+" WHERE D_E_L_E_T_ = ' ' AND ZR_ANO = '"+SZR->ZR_ANO+"'"
_cQuery := ChangeQuery(_cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqRev,.t.,.t.)

IF (_cArqRev)->(!Eof())
	_cRet := Soma1((_cArqRev)->ZR_REVISAO)
ENDIF

(_cArqRev)->(dbCloseArea())
FErase(_cArqRev+GetDBExtension())
FErase(_cArqRev+OrdBagExt())
RestArea(_cArea)

Return(_cRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06Reg
Verifica se existe regra de rateio para as entidades.

@type function
@author TOTVS
@since 15/05/2012
@version P12.1.23

@param _cAno, Caractere, Ano.
@param _cRev, Caractere, Revisão.
@param _cEmpresa, Caractere, Empresa.
@param _lRel, Lógico, Verdadeiro se Lista Relatório.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna falso se não retornar dados.
/*/
/*/================================================================================================================================/*/

Static Function SIPCO06Reg(_cAno,_cRev,_cEmpresa,_lRel)

Local _cQuery  := ""
Local _cArqReg := CriaTrab(nil,.f.)
Local _cArea   := GetArea()
Local _lRet    := .t.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
_cQuery := "SELECT ZS_CC,ZS_ITCTB,ZS_CONTA,ZS_CLASSE FROM "+RetSqlName("SZS")+" WHERE D_E_L_E_T_ = ' ' AND ZS_ANO = '"+_cAno+"' AND ZS_REVISAO = '"+_cRev+"' "
_cQuery += "AND NOT EXISTS(SELECT ZV_PERC FROM "+RetSqlName("SZT")+" SZT "
_cQuery += "INNER JOIN "+RetSqlName("SZU")+" SZU ON ZT_ANO = ZU_ANO AND ZT_REVISAO = ZU_REVISAO "
_cQuery += "INNER JOIN "+RetSqlName("SZV")+" SZV ON ZV_ANO = ZU_ANO AND ZV_REVISAO = ZU_REVISAO AND ZV_ITEMSZU = ZU_ITEM "
_cQuery += "WHERE SZT.D_E_L_E_T_ = ' ' AND SZU.D_E_L_E_T_ = ' ' AND SZV.D_E_L_E_T_ = ' ' "
_cQuery += "AND ZV_CODEMP = '"+_cEmpresa+"' "
_cQuery += "AND ZU_CC = ZS_CC AND ZU_ITCTB = ZS_ITCTB "
_cQuery += "AND ZS_CLASSE BETWEEN ZU_CLVLI AND ZU_CLVLF "
_cQuery += "AND ZS_CONTA BETWEEN ZU_CONTAI AND ZU_CONTAF "
_cQuery += "AND ZT_ANO = ZS_ANO AND ZT_STATUS = '2')"
_cQuery := ChangeQuery(_cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqReg,.t.,.t.)

IF (_cArqReg)->(!Eof())
	_lRet := .f.
ENDIF

IF _lRel 													// Lista Relatório
	_aDados := {}
	While (_cArqReg)->(!Eof())
		Aadd(_aDados,{(_cArqReg)->ZS_CC,(_cArqReg)->ZS_ITCTB,(_cArqReg)->ZS_CONTA,(_cArqReg)->ZS_CLASSE})
		(_cArqReg)->(dbSkip())
	Enddo
	SIPCO06Rel(_aDados,_cEmpresa)
ENDIF

(_cArqReg)->(dbCloseArea())
FErase(_cArqReg+GetDBExtension())
FErase(_cArqReg+OrdBagExt())
RestArea(_cArea)

Return(_lRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06Blq
Verifica se existem entidades bloqueadas.

@type function
@author TOTVS
@since 15/05/2012
@version P12.1.23

@param _cAno, Caractere, Ano.
@param _cRev, Caractere, Revisão.
@param _cEmpresa, Caractere, Empresa.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, Retorna a mensagem de validação.
/*/
/*/================================================================================================================================/*/

Static Function SIPCO06Blq(_cAno,_cRev,_cEmpresa)

Local _cQuery  := ""
Local _cArqReg := CriaTrab(nil,.f.)
Local _cArea   := GetArea()
Local _cRet    := ""
// Backup da filial
Local _cBkpFil := cFilAnt

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
_cQuery := "SELECT ZS_CC,ZS_ITCTB,ZS_CONTA,ZS_CLASSE FROM "+RetSqlName("SZS")+" WHERE D_E_L_E_T_ = ' ' AND ZS_ANO = '"+_cAno+"' AND ZS_REVISAO = '"+_cRev+"' "
_cQuery += "AND EXISTS(SELECT ZV_PERC FROM "+RetSqlName("SZT")+" SZT "
_cQuery += "INNER JOIN "+RetSqlName("SZU")+" SZU ON ZT_ANO = ZU_ANO AND ZT_REVISAO = ZU_REVISAO "
_cQuery += "INNER JOIN "+RetSqlName("SZV")+" SZV ON ZV_ANO = ZU_ANO AND ZV_REVISAO = ZU_REVISAO AND ZV_ITEMSZU = ZU_ITEM "
_cQuery += "WHERE SZT.D_E_L_E_T_ = ' ' AND SZU.D_E_L_E_T_ = ' ' AND SZV.D_E_L_E_T_ = ' ' "
_cQuery += "AND ZV_CODEMP = '"+_cEmpresa+"' "
_cQuery += "AND ZU_CC = ZS_CC AND ZU_ITCTB = ZS_ITCTB "
_cQuery += "AND ZS_CLASSE BETWEEN ZU_CLVLI AND ZU_CLVLF "
_cQuery += "AND ZS_CONTA BETWEEN ZU_CONTAI AND ZU_CONTAF "
_cQuery += "AND ZT_ANO = ZS_ANO AND ZT_STATUS = '2')"
_cQuery := ChangeQuery(_cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqReg,.t.,.t.)

While (_cArqReg)->(!Eof())
	//--< Posiciona filial destino >-------------------------
	IF cFilAnt <> _cEmpresa
		cFilAnt := _cEmpresa
	ENDIF
	
	//--< Valida bloqueio da conta contábil >---------------
	AK5->(dbSetOrder(1))
	IF AK5->(dbSeek(XFilial("AK5")+(_cArqReg)->ZS_CONTA)) .and. AK5->AK5_MSBLQL == "1"
		IF !(Alltrim((_cArqReg)->ZS_CONTA)$_cRet)
			_cRet += Chr(9)+"Conta Orçamentária "+Alltrim((_cArqReg)->ZS_CONTA)+" bloqueada para uso"+CRLF
		ENDIF
	ENDIF
	
	//--< Valida bloqueio do item contábil >----------------
	IF !ValidaBloq((_cArqReg)->ZS_ITCTB,Date(),"CTD",.f.)
		IF !(Alltrim((_cArqReg)->ZS_ITCTB)$_cRet)
			_cRet += Chr(9)+"Item contábil "+Alltrim((_cArqReg)->ZS_ITCTB)+" bloqueado para uso"+CRLF
		ENDIF
	ENDIF
	
	//--< Valida bloqueio do centro de custo >--------------
	IF !ValidaBloq((_cArqReg)->ZS_CC,Date(),"CTT",.f.)
		IF !(Alltrim((_cArqReg)->ZS_CC)$_cRet)
			_cRet += Chr(9)+"Centro de Custo "+Alltrim((_cArqReg)->ZS_CC)+" bloqueada para uso"+CRLF
		ENDIF
	ENDIF
	
	//--< Valida bloqueio da classe de valor >--------------
	IF !ValidaBloq((_cArqReg)->ZS_CLASSE,Date(),"CTH",.f.)
		IF !(Alltrim((_cArqReg)->ZS_CLASSE)$_cRet)
			_cRet += Chr(9)+"Classe de valor "+Alltrim((_cArqReg)->ZS_CLASSE)+" bloqueada para uso"+CRLF
		ENDIF
	ENDIF
	
	(_cArqReg)->(dbSkip())
Enddo

cFilAnt := _cBkpFil											// Restaura filial

(_cArqReg)->(dbCloseArea())
FErase(_cArqReg+GetDBExtension())
FErase(_cArqReg+OrdBagExt())
RestArea(_cArea)

Return(_cRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO06Rel
Relatorio de Inconsistências.

@type function
@author TOTVS
@since 15/05/2012
@version P12.1.23

@param _aDados, Array, Dados do Relatório.
@param _cEmpresa, Caractere, Empresa.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function SIPCO06Rel(_aDados,_cEmpresa)

Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := "Relatório de Inconsistências"
Local cPict         := ""
Local titulo        := "Relatório de Inconsistências ( "+_cEmpresa+" )"
Local nLin          := 80
Local Cabec1        := "UO                    Descrição                       CR                    Descrição                       Conta                 Descrição                       Classe Valor          Descrição"
Local Cabec2        := ""
Local imprime       := .T.
Local aOrd          := {}
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 232
Private tamanho     := "G"
Private nomeprog    := "SIPCOA06"
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "SIPCOA06"
Private cString     := "SZR"

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Monta a interface padrao com o usuario >--------------
wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//--< Processamento. RPTSTATUS monta janela com a regua de processamento. >--

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin,_aDados) },Titulo)

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} RunReport
Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.

@type function
@author TOTVS
@since 27/09/2011
@version P12.1.23

@param Cabec1, Array, Dados do Cabeçalho.
@param Cabec2, Array, Dados do Cabeçalho.
@param Titulo, Caractere, Empresa.
@param nLin, Numérico, Número da Linha.
@param _aDados, Array, Dados do Relatório.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,_aDados)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Impressao do cabecalho do relatorio >-----------------
If nLin > 55 												// Salto de Página. Neste caso o formulario tem 55 linhas...
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
Endif

For i := 1 to Len(_aDados)
	
	@nLin,000 PSAY _aDados[i,1]
	@nLin,022 PSAY Left(Posicione("CTT",1,XFilial("CTT")+_aDados[i,1],"CTT_DESC01"),30)
	@nLin,054 PSAY _aDados[i,2]
	@nLin,076 PSAY Left(Posicione("CTD",1,XFilial("CTD")+_aDados[i,2],"CTD_DESC01"),30)
	@nLin,108 PSAY _aDados[i,3]
	@nLin,130 PSAY Left(Posicione("AK5",1,XFilial("AK5")+_aDados[i,3],"AK5_DESCRI"),30)
	@nLin,162 PSAY _aDados[i,4]
	@nLin,184 PSAY Left(Posicione("CTH",1,XFilial("CTH")+_aDados[i,4],"CTH_DESC01"),30)
	
	nLin++
	
	If nLin > 55 											// Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	
Next

//--< Finaliza a execucao do relatorio >--------------------
SET DEVICE TO SCREEN

//--< Se impressao em disco, chama o gerenciador de impressao >-
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOCSV
Carrega arquivo CSV.

@type function
@author Felipe Alves - TOTVS
@since 06/02/2013
@version P12.1.23

@param aCols1, Array, Dados das colunas.
@param aHeader1, Array, Cabeçalho.
@param nUSado1, Caractere, Usado.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Dados das colunas ordenado.
/*/
/*/================================================================================================================================/*/

Static Function SIPCOCSV(aCols1,aHeader1,nUSado1)

//--< Declaracao de Variaveis >-----------------------------
Local oProcess  := NIL
Local cPathIni := "C:\"

Private cFile := ""

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If (M->ZR_STATUS <> "1")
	Alert("Orçamento Compartilhado não está 'Em Elaboração'. Verifique!")
	Return aClone(aCols1)
Endif

cFile := cGetFile( "Arquivo CSV | *.csv" , "Selecione o arquivo CSV" ,/*<nMascpadrao>*/ , cPathIni , .T. , GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE , /*<lArvore>*/ , /*<lKeepCase>*/ )

If !Empty(cFile)
	IF !File(cFile)
		Alert("Arquivo não localizado. Verifique!")
		Return aClone(aCols1)
	ENDIF
	
	oProcess := MsNewProcess():New( { | lEnd | aCols1 := xImpCSV(@lEnd, oProcess, aCols1, aHeader1, nUSado1) }, 'Processando', 'Aguarde, processando...', .F. )
	oProcess:Activate()
Endif

Return aSort(aClone(aCols1), , , {|x,y| x > y})


/*/================================================================================================================================/*/
/*/{Protheus.doc} xImpCSV
Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.

@type function
@author TOTVS
@since 06/02/2013
@version P12.1.23

@param lEnd, Lógico, Resultado do processamento do relatório.
@param oProcess, Objeto, Processo.
@param aCols1, Array, Dados das colunas
@param aHeader1, Array, Cabeçalho.
@param nUsado1, Numérico, Usado.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Dados das colunas ordenado.
/*/
/*/================================================================================================================================/*/

Static Function xImpCSV(lEnd,oProcess,aCols1,aHeader1,nUsado1)

Local nX,nY
Local cLin		 :=	""
Local aCampo	 := {}
Local aEstrut	 := {}
Local aTXT		 := {}
Local aPosCampos := {}
Local cAliasTrb  := GetNextAlias()
Local cArqTrb	 := ""
Local cChave	 := ""
Local cAno 		 :=  M->ZR_ANO
Local nPosCc	 := Ascan(aHeader1, {|e| Alltrim(e[2]) = "ZS_CC"} )
Local nPosItem	 := Ascan(aHeader1, {|e| Alltrim(e[2]) = "ZS_ITCTB"} )
Local nPosClasse := Ascan(aHeader1, {|e| Alltrim(e[2]) = "ZS_CLASSE"} )
Local nPosConta	 := Ascan(aHeader1, {|e| Alltrim(e[2]) = "ZS_CONTA"} )
Local aEstErro	 := {}
Local cAliasTmp  := GetNextAlias()
Local cArqTmp	 := ""
Local cChaveErr	 := ""
Local lErro		 := .F.
Local cPeriodos  := "JAN/FEV/MAR/ABR/MAI/JUN/JUL/AGO/SET/OUT/NOV/DEZ" //cAno+"0101/"+cAno+"0201/"+cAno+"0301/"+cAno+"0401/"+cAno+"0501/"+cAno+"0601/"+cAno+"0701/"+cAno+"0801/"+cAno+"0901/"+cAno+"1001/"+cAno+"1101/"+cAno+"1201"

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
aEstErro :={	{ "NOME" 	, "C", 	 20, 0 },;
				{ "LINHA"		, "C",  5, 0 },;
				{ "CAMPO"		, "C",  10, 0 },;
				{ "CONTEUDO"	, "C",  30, 0 },;
				{ "MSG"			, "C",  70, 0 }}

cArqTmp := CriaTrab(aEstErro, .T.)
dbUseArea( .T.,, cArqTmp, cAliasTmp, .F., .F. )

//--< Cria Indice Temporario do Arquivo de Trabalho. >------
cChaveErr   := "NOME+LINHA"

IndRegua(cAliasTmp,cArqTmp,cChaveErr,,,"Criando Arquivo Temporário...")
dbSelectArea(cAliasTmp)
dbSetIndex(cArqTmp+OrdBagExt())
dbSetOrder(1)

aEstrut :={	{ "ZS_ITEM" 		, "C", 	 TamSx3("ZN_ITEM")[1], 0 },;
			{ "ZS_CC" 		, "C", 	 TamSx3("ZN_CC")[1], 0 },;
			{ "ZS_ITCTB"		, "C",   TamSx3("ZS_ITCTB")[1], 0 },;
			{ "ZS_CONTA"	, "C",   TamSx3("ZS_CONTA")[1], 0 },;
			{ "ZS_CLASSE"	, "C",   TamSx3("ZS_CLASSE")[1], 0 },;
			{ "ZS_MES01"	, "N",   17, 2 },;
			{ "ZS_MES02"	, "N",   17, 2 },;
			{ "ZS_MES03"	, "N",   17, 2 },;
			{ "ZS_MES04"	, "N",   17, 2 },;
			{ "ZS_MES05"	, "N",   17, 2 },;
			{ "ZS_MES06"	, "N",   17, 2 },;
			{ "ZS_MES07"	, "N",   17, 2 },;
			{ "ZS_MES08"	, "N",   17, 2 },;
			{ "ZS_MES09"	, "N",   17, 2 },;
			{ "ZS_MES10"	, "N",   17, 2 },;
			{ "ZS_MES11"	, "N",   17, 2 },;
			{ "ZS_MES12"	, "N",   17, 2 }}

cArqTrb := CriaTrab(aEstrut, .T.)
dbUseArea( .T.,, cArqTrb, cAliasTrb, .F., .F. )

//--< Cria Indice Temporario do Arquivo de Trabalho 1. >----
cChave   := "ZS_CC+ZS_ITCTB+ZS_CONTA+ZS_CLASSE"

IndRegua(cAliasTrb,cArqTrb,cChave,,,"Selecionando Registros...")
dbSelectArea(cAliasTrb)
dbSetIndex(cArqTrb+OrdBagExt())
dbSetOrder(1)

//--< ESTRUTURA DO ARQUIVO TEXTO >--------------------------
aAdd(aCampo,"ITEM")
aAdd(aCampo,"UO")
aAdd(aCampo,"CR")
aAdd(aCampo,"CONTA")
aAdd(aCampo,"CLASSE")
aAdd(aCampo,"JAN")
aAdd(aCampo,"FEV")
aAdd(aCampo,"MAR")
aAdd(aCampo,"ABR")
aAdd(aCampo,"MAI")
aAdd(aCampo,"JUN")
aAdd(aCampo,"JUL")
aAdd(aCampo,"AGO")
aAdd(aCampo,"SET")
aAdd(aCampo,"OUT")
aAdd(aCampo,"NOV")
aAdd(aCampo,"DEZ")

//-< Define o valor do array conforme estrutura >-----------
aPosCampos:= Array(Len(aCampo))

If (nHandle := FT_FUse(AllTrim(cFile)))== -1
	Help(" ",1,"NOFILEIMPOR")
	Return
EndIf

//--< Verifica Estrutura do Arquivo >-----------------------
FT_FGOTOP()
cLinha := FT_FREADLN()
nPos	:=	0
nAt	:=	1

While nAt > 0
	nPos++
	nAt	:=	AT(";",cLinha)
	If nAt == 0
		cCampo := cLinha
	Else
		cCampo	:=	Substr(cLinha,1,nAt-1)
	Endif
	nPosCpo	:=	Ascan(aCampo,{|x| x==cCampo})
	If nPosCPO > 0
		aPosCampos[nPosCpo]:= nPos
	Endif
	cLinha	:=	Substr(cLinha,nAt+1)
Enddo

If (nPosNil:= Ascan(aPosCampos,Nil)) > 0
	Aviso("Estrutura de arquivo inválido.","O campo "+aCampo[nPosNil]+" nao foi encontrado na estrutura, verifique.",{"Sair"})
	Return aCols1
Endif

//--< Inicia Importacao das Linhas >------------------------
FT_FSKIP()
While !FT_FEOF()
	cLinha := FT_FREADLN()
	AADD(aTxt,{})
	nCampo := 1
	While At(";",cLinha)>0
		aAdd(aTxt[Len(aTxt)],Substr(cLinha,1,At(";",cLinha)-1))
		nCampo ++
		cLinha := StrTran(Substr(cLinha,At(";",cLinha)+1,Len(cLinha)-At(";",cLinha)),'"','')
	End
	If Len(AllTrim(cLinha)) > 0
		aAdd(aTxt[Len(aTxt)],StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
	Else
		aAdd(aTxt[Len(aTxt)],"")
	Endif
	
	IF Len(aTxt[Len(aTxt)]) <> Len(aCampo)
		Aviso("LINHA "+Alltrim(Str(Len(aTxt))),"Estrutura de arquivo inválida (qtde de registros). Verifique.",{"Sair"})
		Return aCols1
	ENDIF
	
	FT_FSKIP()
End

//--< Gravacao dos Itens (TRB) >----------------------------
FT_FUSE()
For nX:=1 To Len(aTxt)
	
	dbSelectArea(cAliasTrb)
	dbGotop()
	If !dbSeek(aTxt[nX,2]+Space(TamSx3("ZS_CC")[1]-Len(aTxt[nX,2]))+aTxt[nX,3]+Space(TamSx3("ZS_ITCTB")[1]-Len(aTxt[nX,3]))+aTxt[nX,4]+Space(TamSx3("ZS_CONTA")[1]-Len(aTxt[nX,4]))+aTxt[nX,5]+Space(TamSx3("ZS_CLASSE")[1]-Len(aTxt[nX,5])))
		
		//--< Valida Linha Duplicada >----------------------
		If nPosCc > 0
			//--< Pesquisa por item ja cadastrado >---------
			For nZ := 1 To Len(aCols1)
				//--< Se encontrou um item igual ao ja cadastrado, avisa e nao permite continuar >--
				If !(GdDeleted( nZ, aHeader1, aCols1)) .And.;
					Alltrim(aCols1[nZ][nPosCc])+Alltrim(aCols1[nZ][nPosItem])+Alltrim(aCols1[nZ][nPosConta])+Alltrim(aCols1[nZ][nPosClasse]) == ;
					Alltrim(aTxt[nX,2])+Alltrim(aTxt[nX,3])+Alltrim(aTxt[nX,4])+Alltrim(aTxt[nX,5])
					lErro := .T.
					dbSelectArea(cAliasTmp)
					RecLock(cAliasTmp,.T.)
					(cAliasTmp)->NOME 		:= cFile
					(cAliasTmp)->LINHA 		:= Alltrim(Str(nX))
					(cAliasTmp)->CAMPO		:= "DUPL"
					(cAliasTmp)->CONTEUDO 	:= Alltrim(aCols1[nZ][nPosCc])+Alltrim(aCols1[nZ][nPosItem])+Alltrim(aCols1[nZ][nPosConta])+Alltrim(aCols1[nZ][nPosClasse])
					(cAliasTmp)->MSG	 	:= "Existem duplicidades para o UO: "+Alltrim(aCols1[nZ][nPosCC])+", CR "+Alltrim(aCols1[nZ][nPosItem])+", CONT "+Alltrim(aCols1[nZ][nPosConta])+" e Classe "+Alltrim(aCols1[nZ][nPosClasse])+"."
					MsUnlock()
				Endif
			Next
		Endif
		
		RecLock(cAliasTrb,.T.)
		For nY:=1 To Len(aCampo)
			
			//--< Valida CC >-------------------------------
			If AllTrim(aCampo[nY]) $ "UO"
				dbSelectArea("CTT")
				dbSetOrder(1)
				If !dbSeek(xFilial("CTT")+aTxt[nX,nY])
					lErro 	:= .T.
					dbSelectArea(cAliasTmp)
					RecLock(cAliasTmp,.T.)
					(cAliasTmp)->NOME 		:= cFile
					(cAliasTmp)->LINHA 		:= Alltrim(Str(nX))
					(cAliasTmp)->CAMPO		:= "UO"
					(cAliasTmp)->CONTEUDO 	:= aTxt[nX,nY]
					(cAliasTmp)->MSG	 	:= "Centro de Custo "+Alltrim(aTxt[nX,nY])+" não localizado na base de dados."
					MsUnlock()
				Endif
			Endif
			
			//--< Valida Item >-----------------------------
			If AllTrim(aCampo[nY]) $ "CR"
				dbSelectArea("CTD")
				dbSetOrder(1)
				If !dbSeek(xFilial("CTD")+aTxt[nX,nY])
					lErro 	:= .T.
					dbSelectArea(cAliasTmp)
					RecLock(cAliasTmp,.T.)
					(cAliasTmp)->NOME 		:= cFile
					(cAliasTmp)->LINHA 		:= Alltrim(Str(nX))
					(cAliasTmp)->CAMPO		:= "CR"
					(cAliasTmp)->CONTEUDO 	:= aTxt[nX,nY]
					(cAliasTmp)->MSG	 	:= "Item Contábil "+Alltrim(aTxt[nX,nY])+" não localizado na base de dados."
					MsUnlock()
				Endif
			Endif
			
			//--< Valida Conta >----------------------------
			If AllTrim(aCampo[nY]) $ "CONTA"
				dbSelectArea("AK5")
				dbSetOrder(1)
				If !dbSeek(xFilial("AK5")+aTxt[nX,nY])
					lErro 	:= .T.
					dbSelectArea(cAliasTmp)
					RecLock(cAliasTmp,.T.)
					(cAliasTmp)->NOME 		:= cFile
					(cAliasTmp)->LINHA 		:= Alltrim(Str(nX))
					(cAliasTmp)->CAMPO		:= "CONTA"
					(cAliasTmp)->CONTEUDO 	:= aTxt[nX,nY]
					(cAliasTmp)->MSG	 	:= "Conta Orçamentária "+Alltrim(aTxt[nX,nY])+" não localizado na base de dados."
					MsUnlock()
				Endif
			Endif
			
			//--< Valida Classe >---------------------------
			If AllTrim(aCampo[nY]) $ "CLASSE"
				dbSelectArea("CTH")
				dbSetOrder(1)
				If !dbSeek(xFilial("CTH")+aTxt[nX,nY])
					lErro 	:= .T.
					dbSelectArea(cAliasTmp)
					RecLock(cAliasTmp,.T.)
					(cAliasTmp)->NOME 		:= cFile
					(cAliasTmp)->LINHA 		:= Alltrim(Str(nX))
					(cAliasTmp)->CAMPO		:= "CLASSE"
					(cAliasTmp)->CONTEUDO 	:= aTxt[nX,nY]
					(cAliasTmp)->MSG	 	:= "Classe de Valor "+Alltrim(aTxt[nX,nY])+" não localizado na base de dados."
					MsUnlock()
				Endif
			Endif
			
			dbSelectArea(cAliasTrb)
			
			If AllTrim(aCampo[nY]) $ cPeriodos
				_nValor	:= Val(StrTran(aTxt[nX,nY],",","."))
				FieldPut(nY,_nValor)
			Else
				FieldPut(nY,aTxt[nX,nY])
			Endif
			
		Next
		MsUnLock()
	Else
		
		lErro 	:= .T.
		dbSelectArea(cAliasTmp)
		RecLock(cAliasTmp,.T.)
		(cAliasTmp)->NOME 		:= cFile
		(cAliasTmp)->LINHA 		:= Alltrim(Str(nX))
		(cAliasTmp)->CAMPO		:= "DUPL"
		(cAliasTmp)->CONTEUDO 	:= Alltrim(aTxt[nX,1])+Alltrim(aTxt[nX,2])+Alltrim(aTxt[nX,3])+Alltrim(aTxt[nX,4])
		(cAliasTmp)->MSG	 	:= "Existem duplicidades para o UO: "+Alltrim(aTxt[nX,1])+", CR "+Alltrim(aTxt[nX,2])+", CONT "+Alltrim(aTxt[nX,3])+" e Classe "+Alltrim(aTxt[nX,4])+"."
		MsUnlock()
		
	Endif
Next

If lErro
	//--< Chama Impressao do Relatorio de Inconsistencias >-
	If ApMsgYesNo("Ocorreram inconsistências durante a importação dos dados, deseja imprimir o log?","Log de Inconsistências")
		xRelInc(cAliasTmp,"Inconsistências da Importação")
	Endif
Else
	dbSelectArea(cAliasTrb)
	dbGotop()
	
	//--< Inicia Gravacao no Sistema - aCols1,aHeader1 >----
	While !(cAliasTrb)->(Eof())
		
		If !Empty(aCols1[Len(aCols1),nPosCC]+aCols1[Len(aCols1),nPosItem]+aCols1[Len(aCols1),nPosConta]+aCols1[Len(aCols1),nPosClasse])
			AADD(aCols1,Array(nUsado1+1))
		Endif
		For nX := 1 to Len(aEstrut)
			aCols1[Len(aCols1),nX]:=FieldGet(nX)
			aCols1[Len(aCols1),nUsado1+1]:=.F.
		Next nX
		
		dbSelectArea(cAliasTrb)
		dbSkip()
	EndDo
Endif

If Select(cAliasTrb) != 0
	dbSelectArea(cAliasTrb)
	dbCloseArea()
	FErase(cArqTrb+GetDBExtension())
	FErase(cArqTrb+OrdBagExt())
Endif

If Select(cAliasTmp) != 0
	dbSelectArea(cAliasTmp)
	dbCloseArea()
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
Endif

Return aCols1


/*/================================================================================================================================/*/
/*/{Protheus.doc} xImpCSV
Impressão do Relatório de Áreas Compartilhadas.

@type function
@author TOTVS
@since 06/02/2013
@version P12.1.23

@param _cAlias, Caractere, Alias
@param _cTitulo, Caractere, Título do Relatório.

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function xRelInc(_cAlias,_cTitulo)

//--< Declaracao de Variaveis >-----------------------------
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := _cTitulo
Local cPict       	:= ""
Local titulo       	:= _cTitulo
Local nLin         	:= 80
Local Cabec1       	:= "Nome Arquivo            Linha     Campo     Conteudo                       Mensagem"
//1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789123456789123456789123456789
//0        1         2         3         4         5         6         7         8         9         1
Local Cabec2       	:= ""
Local imprime      	:= .T.
Local aOrd 			:= {}
Private lEnd      	:= .F.
Private lAbortPrint	:= .F.
Private limite   	:= 132
Private tamanho  	:= "M"
Private nomeprog 	:= "SIPCOA17"
Private nTipo     	:= 18
Private aReturn  	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey	:= 0
Private cbtxt      	:= Space(10)
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= "SIPCOA17"
Private cString		:= _cAlias

dbSelectArea(cString)
dbSetOrder(1)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Monta a interface padrao com o usuario >--------------
wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//--< Processamento. RPTSTATUS monta janela com a regua de processamento >--
RptStatus({|| RunReportC(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return



/*/================================================================================================================================/*/
/*/{Protheus.doc} RunReportC
Execução do Relatório de Áreas Compartilhadas.

@type function
@author TOTVS
@since 06/02/2013
@version P12.1.23

@param Cabec1, Caractere, Alias
@param Cabec2, Caractere, Título do Relatório.
@param Titulo, Caractere, Título do Relatório.
@param nLin, Numérico, Linha do Relatório

@obs Projeto ELO

@history 22/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function RunReportC(Cabec1,Cabec2,Titulo,nLin)

dbSelectArea(cString)
dbSetOrder(1)

//--< SETREGUA -> Indica quantos registros serao processados para a regua >--
SetRegua(RecCount())

dbGoTop()
While !EOF()
	
	//--< Verifica o cancelamento pelo usuario >------------
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//--< Impressao do cabecalho do relatorio >-------------
	If nLin > 55 											// Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	
	@nLin,000 PSAY (cString)->NOME
	@nLin,025 PSAY (cString)->LINHA
	@nLin,035 PSAY (cString)->CAMPO
	@nLin,045 PSAY (cString)->CONTEUDO
	@nLin,076 PSAY (cString)->MSG
	
	nLin := nLin + 1 										// Avanca a linha de impressao
	
	IncRegua()
	dbSkip() 												// Avanca o ponteiro do registro no arquivo
EndDo

//--< Finaliza a execucao do relatorio >--------------------
SET DEVICE TO SCREEN

//--< Se impressao em disco, chama o gerenciador de impressao >--
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return
