#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA07
Cadastro de Regras de Rateio.

@type function
@author Thiago Rasmussen
@since 27/04/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIPCOA07
	Local aCores      := {{"SZT->ZT_STATUS = '1'",'BR_AMARELO'},{"SZT->ZT_STATUS = '2'",'ENABLE'},{"SZT->ZT_STATUS = '3'",'DISABLE'}}
	Private cCadastro := "Regras de Rateio"
	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
	{"Visualizar","U_SIPCO07A",0,2} ,;
	{"Incluir","U_SIPCO07A",0,3} ,;
	{"Alterar","U_SIPCO07A",0,4} ,;
	{"Excluir","U_SIPCO07A",0,5} ,;
	{"Copiar","U_SIPCO07A",0,6} ,;
	{"Revisar","U_SIPCO07A",0,7} ,;
	{"Legenda","BrwLegenda('Regras','Legenda',{{'BR_AMARELO','Em Elaboração'},{'ENABLE','Vigente'},{'DISABLE','Revisado'}})",0,3}}

	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "SZT"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("SZT")
	SZT->(dbSetOrder(1))

	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString,,,,,,aCores)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO07A
Cadastro de Regras de Rateio.

@type function
@author Thiago Rasmussen
@since 02/05/2012
@version P12.1.23

@param cAlias, Caractere, Alias da tabela.
@param nReg, Numérico, RECNO do registro posicionado.
@param nOpc, Numérico, Código da opção selecionada.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIPCO07A(cAlias,nReg,nOpc)
	Local nX 	 	 := 0
	Local aAlterEnch := {}
	Local cIniCpos   := ""
	Local cFieldOk   := "AllwaysTrue"
	Local cSuperDel  := ""
	Local cDelOk     := "AllwaysTrue"
	Local nOpcX		 := 0
	Local aHeader    := {}
	Local aCols      := {}
	Private aNaoSZV  := {"ZV_ANO","ZV_REVISAO","ZV_CC","ZV_ITCTB"}
	Private aHeader1 := {}
	Private aCols1   := {}
	Private oDlg
	Private oBrw,oBrw1
	Private oEnch
	Private aTELA[0][0]
	Private aGETS[0]
	// backup das distribuicoes
	Private aBkpCols := {}
	Private aBkpHead := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF nOpc == 4 .and. SZT->ZT_STATUS$"2/3" // alteracao
		Aviso("Atenção","Regras vigentes/revisadas não podem ser alteradas. Verifique!",{"Voltar"})
		Return()
	ELSEIF nOpc == 5 .and. SZT->ZT_STATUS$"2/3" // exclusao
		Aviso("Atenção","Regras vigentes/revisadas não podem ser excluídas. Verifique!",{"Voltar"})
		Return()
	ELSEIF nOpc == 7 .and. SZT->ZT_STATUS == "1" // revisao
		Aviso("Atenção","Regras em elaboração não podem ser revisadas. Verifique!",{"Voltar"})
		Return()
	ENDIF

	// Carga inicial do vetor
	IF nOpc <> 3
		cSeek := SZT->(ZT_FILIAL+ZT_ANO+ZT_REVISAO)
		cWhile := "SZV->(ZV_FILIAL+ZV_ANO+ZV_REVISAO)"
		FillGetDados(4,"SZV",1,cSeek,{|| &cWhile },{|| .T. },aNaoSZV,/*aSimCpo*/,,,,,aBkpHead,aBkpCols)
		aEval(aBkpCols,{|x| x[GDFieldPos("ZV_NOME",aBkpHead)] := Posicione("SM0",1,cEmpAnt+x[GDFieldPos("ZV_CODEMP",aBkpHead)],"M0_NOME") })
		aHeader := {}
		aCols   := {}
	ENDIF

	RegToMemory("SZT", Iif(nOpc==3.or.nOpc==6,.T.,.F.))

	// Campos editaveis do cabecalho
	IF nOpc == 3 .or. nOpc == 6 // inclusao ou cópia
		Aadd(aAlterEnch,"ZT_ANO")
		Aadd(aAlterEnch,"ZT_STATUS")
	ELSEIF nOpc == 4 .or. nOpc == 7 // alteracao ou revisao
		Aadd(aAlterEnch,"ZT_STATUS")
	ENDIF

	If nOpc == 7
		M->ZT_REVISAO := SIPCO07Rev()
		M->ZT_STATUS  := "1"
	Endif

	// Montagem dos grupos de rateio
	aNaoSZU  := {"ZU_ANO","ZU_REVISAO"}
	IF nOpc == 3
		cSeek  := ""
		cWhile := ""
	ELSE
		cSeek := SZT->(ZT_FILIAL+ZT_ANO+ZT_REVISAO)
		cWhile := "SZU->(ZU_FILIAL+ZU_ANO+ZU_REVISAO)"
	ENDIF

	FillGetDados(IIF(nOpc==3,3,4),"SZU",1,cSeek,{|| &cWhile },{|| .T. },aNaoSZU,/*aSimCpo*/,,,,,aHeader,aCols)

	IF Empty(GdFieldGet("ZU_ITEM",1,,aHeader,aCols))
		GDFieldPut("ZU_ITEM",StrZero(1,TamSX3("ZU_ITEM")[1]),1,aHeader,aCols)
	ENDIF

	IF Empty(GdFieldGet("ZU_CLVLF",1,,aHeader,aCols))
		GDFieldPut("ZU_CLVLF",Replicate("Z",TamSX3("ZU_CLVLF")[1]),1,aHeader,aCols)
	ENDIF

	IF Empty(GdFieldGet("ZU_CONTAF",1,,aHeader,aCols))
		GDFieldPut("ZU_CONTAF",Replicate("Z",TamSX3("ZU_CONTAF")[1]),1,aHeader,aCols)
	ENDIF

	// Montagem da grade da distribuicao
	cSeek  := ""
	cWhile := ""
	FillGetDados(3,"SZV",1,cSeek,{|| &cWhile },{|| .T. },aNaoSZV,/*aSimCpo*/,,,,,aHeader1,aCols1)
	GDFieldPut("ZV_ITEM",StrZero(1,TamSX3("ZV_ITEM")[1]),1,aHeader1,aCols1)

	//+--------------------------------------------------------------+
	//| Montagem da Tela de Consulta                                 |
	//+--------------------------------------------------------------+

	aSizeAut := MsAdvSize()

	oDlg := MSDIALOG():New(aSizeAut[7],000, aSizeAut[6],aSizeAut[5], cCadastro,,,,,,,,,.T.)

	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,35,35,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP

	oPanel1 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,170,170,.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_TOP

	oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,1,1,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

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

	oEnch := MsMGet():New("SZT", nReg,nOpcEnch,,,,/*aCpoEnch*/,{0,0,0,0,0},aAlterEnch,3,,,,oPanel,.F.,.T.,.F.,"",.F.,.F.)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	oBrw := MsNewGetDados():New(1,1,1,1,nStyle,"U_SIPCO07LOK(1)", "U_SIPCO07TOK(1)", "+ZU_ITEM",,, 9999, cFieldOk, cSuperDel,cDelOk,oPanel1, aHeader, aCols)
	oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrw:oBrowse:bChange := {|| SIPCO07Emp() }

	oBrw1 := MsNewGetDados():New(1,1,1,1,nStyle,"U_SIPCO07LOK(2)", "AllwaysTrue", "+ZV_ITEM",,, 9999, cFieldOk, cSuperDel,cDelOk,oPanel2, aHeader1, aCols1)
	oBrw1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrw1:oBrowse:bChange := {|| GDFieldPut("ZV_ITEMSZU",GdFieldGet("ZU_ITEM",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols),oBrw1:oBrowse:nAt,oBrw1:aHeader,oBrw1:aCols),oBrw1:oBrowse:Refresh() }

	oDlg:bInit	:= {|| EnchoiceBar(oDlg, {|| nOpcX:=1, aBkpHead := aClone(oBrw1:aHeader), IIf(oBrw:TudoOk() .and. oBrw1:TudoOk() .and.Obrigatorio(aGets, aTela),oDlg:End(),nOpcX:=0)}, {||nOpcx := 0, oDlg:End()},,)}
	oDlg:lCentered := .T.
	oDlg:Activate()

	If nOpcX == 1 .and. !nOpc == 2
		//Gravaçao dos Dados
		xPCO07GRV(nOpc)
	Endif

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} xPCO07GRV
Gravacao dos Dados.

@type function
@author Thiago Rasmussen
@since 30/04/2012
@version P12.1.23

@param nOpc, Numérico, Código da opção selecionada.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xPCO07GRV(nOpc)
	Local bCampo := {|nCPO| Field(nCPO) }

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Backup do TTS
	lSavTTsInUse := __TTSInUse

	// Ativa TTS
	__TTSInUse := .T.

	Begin Transaction

		If !nOpc == 5

			// Revisao ele altera o status do orçamento posicionado para 3 = Revisado
			IF nOpc == 7
				RecLock("SZT",.F.)
				SZT->ZT_STATUS := "3" // Revisado
				SZT->(MsUnLock())

				IF (_cNewRev := SIPCO07Rev()) <> M->ZT_REVISAO
					Aviso("Atenção","O código da revisão foi alterado para "+_cNewRev,{"Voltar"})
					M->ZT_REVISAO := _cNewRev
				ENDIF
			ENDIF

			// Atualiza ultimo item
			_nPosItSZU := GdFieldPos("ZV_ITEMSZU",oBrw1:aHeader)
			For i := 1 to Len(oBrw1:aCols)
				IF (_nPos := Ascan(aBkpCols,{|x| x[_nPosItSZU] == oBrw1:aCols[i,_nPosItSZU] })) > 0
					aDel(aBkpCols,_nPos)
					aSize(aBkpCols,Len(aBkpCols)-1)
				ENDIF
			Next

			For i := 1 to Len(oBrw1:aCols)
				IF !Empty(GDFieldGet("ZV_ITEMSZU",i,,oBrw1:aHeader,oBrw1:aCols))
					Aadd(aBkpCols,oBrw1:aCols[i])
				ENDIF
			Next

			SZT->(dbSetOrder(1))
			IF SZT->(dbSeek(xFilial("SZT")+M->(ZT_ANO+ZT_REVISAO)))
				RecLock("SZT",.F.)
			Else
				RecLock("SZT",.T.)
				SZT->ZT_FILIAL := xFilial("SZT")
			EndIf

			For nX := 1 TO SZT->(FCount())
				SZT->(FieldPut(nX,M->&(EVAL(bCampo,nX))))
			Next nX

			SZT->(MsUnLock())

			//+-------------------------------+
			//|Gravacao das Regras            |
			//+-------------------------------+
			For nX := 1 To Len(oBrw:aCols)

				_lDelete := IIF(GDDeleted(nX,oBrw:aHeader,oBrw:aCols),.t.,.f.)

				SZU->(dbSetOrder(1))
				IF !SZU->(dbSeek(XFilial("SZU")+SZT->(ZT_ANO+ZT_REVISAO)+GdFieldGet("ZU_ITEM",nX,,oBrw:aHeader,oBrw:aCols)))
					IF _lDelete
						Loop
					ENDIF
					RecLock("SZU",.T.)
					SZU->ZU_FILIAL 	:= xFilial("SZU")
					SZU->ZU_ANO 	:= SZT->ZT_ANO
					SZU->ZU_REVISAO	:= SZT->ZT_REVISAO
				ELSE
					RecLock("SZU",.F.)
					IF _lDelete
						SZU->(dbDelete())
						SZU->(msUnlock())
						Loop
					ENDIF
				ENDIF

				For nY := 1 to Len(oBrw:aHeader)
					If oBrw:aHeader[nY][10] <> "V"
						SZU->(FieldPut(FieldPos(oBrw:aHeader[nY][2]),oBrw:aCols[nX][nY]))
					EndIf
				Next nY

				SZU->(MsUnLock())

			Next nX

			//+-------------------------------+
			//|Gravacao das Distribuicoes     |
			//+-------------------------------+
			For i := 1 to Len(aBkpCols)

				_cItemZU := GdFieldGet("ZV_ITEMSZU",i,,aBkpHead,aBkpCols)
				_cItemZV := GdFieldGet("ZV_ITEM",i,,aBkpHead,aBkpCols)

				Eval( {|| SZU->(dbSetOrder(1)) , _lDeleta := !SZU->(dbSeek(XFilial("SZU")+SZT->(ZT_ANO+ZT_REVISAO)+_cItemZU)) } )

				SZV->(dbSetOrder(1))
				IF !SZV->(dbSeek(XFilial("SZV")+SZT->(ZT_ANO+ZT_REVISAO)+_cItemZU+_cItemZV))
					IF GdDeleted(i,aBkpHead,aBkpCols) .or. _lDeleta
						Loop
					ENDIF
					RecLock("SZV",.t.)
					SZV->ZV_FILIAL 	:= xFilial("SZV")
					SZV->ZV_ANO 	:= SZT->ZT_ANO
					SZV->ZV_REVISAO	:= SZT->ZT_REVISAO
				ELSE
					RecLock("SZV",.f.)
					IF GdDeleted(i,aBkpHead,aBkpCols) .or. _lDeleta
						SZV->(dbDelete())
						SZV->(msUnlock())
						Loop
					ENDIF
				ENDIF

				For x := 1 to Len(aBkpHead)
					If ( aBkpHead[x,10] <> "V" )
						SZV->(FieldPut(FieldPos(aBkpHead[x,2]),aBkpCols[i,x]))
					EndIf
				Next

				SZV->(msUnlock())
			Next

		Else

			// Exclui Regra
			SZU->(dbSetOrder(1))
			SZU->(MsSeek(xFilial("SZU")+SZT->(ZT_ANO+ZT_REVISAO)))
			While SZU->(!Eof()) .and. SZU->(ZU_FILIAL+ZU_ANO+ZU_REVISAO) == XFilial("SZU")+SZT->(ZT_ANO+ZT_REVISAO)
				Eval({|| RecLock("SZU",.f.), SZU->(dbDelete()), SZU->(MsUnLock()) })
				SZU->(dbSkip())
			EndDo

			// Exclui Distribuicao
			SZV->(dbSetOrder(1))
			IF SZV->(MsSeek(xFilial("SZV")+SZT->(ZT_ANO+ZT_REVISAO)))
				Eval({|| RecLock("SZV",.f.), SZV->(dbDelete()), SZV->(msUnLock()) })
			EndIf

			// Exclui Cabeçalho
			RecLock("SZT",.F.)
			SZT->(dbDelete())
			SZT->(msUnlock())
		Endif

	End Transaction

	// Restaura TTS
	__TTSInUse := lSavTTsInUse

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO07Emp
Atualiza GET de distribuicao.

@type function
@author Thiago Rasmussen
@since 02/05/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function SIPCO07Emp()
	Local _cItemSZU  := GdFieldGet("ZU_ITEM",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
	Local _nPosItem  := GdFieldPos("ZV_ITEM",oBrw1:aHeader)
	Local _nPosItSZU := GdFieldPos("ZV_ITEMSZU",oBrw1:aHeader)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	For i := 1 to Len(oBrw1:aCols)
		IF (_nPos := Ascan(aBkpCols,{|x| x[_nPosItSZU] == oBrw1:aCols[i,_nPosItSZU] })) > 0
			aDel(aBkpCols,_nPos)
			aSize(aBkpCols,Len(aBkpCols)-1)
		ENDIF
	Next

	For i := 1 to Len(oBrw1:aCols)
		IF !Empty(GDFieldGet("ZV_ITEMSZU",i,,oBrw1:aHeader,oBrw1:aCols))
			Aadd(aBkpCols,oBrw1:aCols[i])
		ENDIF
	Next

	oBrw1:aCols := {}

	For i := 1 to Len(aBkpCols)
		IF aBkpCols[i,_nPosItSZU] == _cItemSZU
			Aadd(oBrw1:aCols,aBkpCols[i])
		ENDIF
	Next

	IF Len(oBrw1:aCols) == 0
		// Montagem da grade da distribuicao
		aCols1   := {}
		aAdd(aCols1,Array(Len(oBrw1:aHeader)+1))
		For nX := 1 To Len(oBrw1:aHeader)
			IF !(Alltrim(oBrw1:aHeader[nX][2]) $ "ZV_REC_WT|ZV_ALI_WT" )
				aCols1[1,nX] := CriaVar(oBrw1:aHeader[nX,2])
			ENDIF
		Next nX
		aCols1[1,Len(oBrw1:aHeader)+1] := .F.
		aCols1[1,_nPosItem]  := StrZero(1,TamSX3("ZV_ITEM")[1])
		aCols1[1,_nPosItSZU] := _cItemSZU
		oBrw1:aCols := aClone(aCols1)
	ENDIF

	IF Empty(GdFieldGet("ZU_CLVLF",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols))
		GDFieldPut("ZU_CLVLF",Replicate("Z",TamSX3("ZU_CLVLF")[1]),oBrw:oBrowse:nAt,oBrw:aHeader,oBrw:aCols)
	ENDIF

	IF Empty(GdFieldGet("ZU_CONTAF",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols))
		GDFieldPut("ZU_CONTAF",Replicate("Z",TamSX3("ZU_CONTAF")[1]),oBrw:oBrowse:nAt,oBrw:aHeader,oBrw:aCols)
	ENDIF

	oBrw:oBrowse:Refresh()
	oBrw1:oBrowse:Refresh()
Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO07LOK
Validacao da linha.

@type function
@author Thiago Rasmussen
@since 01/05/2012
@version P12.1.23

@param _nOpc, Numérico, Código da opção selecionada.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação da linha.

/*/
/*/================================================================================================================================/*/

User Function SIPCO07LOK(_nOpc)
	Local _lRet := .t.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF _nOpc == 1 // Regra

		// Verifica duplidade da linha
		_nPosITEM  := GDFieldPos("ZU_ITEM")
		_nPosCC    := GDFieldPos("ZU_CC")
		_nPosITCT  := GDFieldPos("ZU_ITCTB")
		_nPosCLDE  := GDFieldPos("ZU_CLVLI")
		_nPosCLATE := GDFieldPos("ZU_CLVLF")
		_nPosCTDE  := GDFieldPos("ZU_CONTAI")
		_nPosCTATE := GDFieldPos("ZU_CONTAF")
		_cITEM    := GDFieldGet("ZU_ITEM",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
		_cCCUSTO  := GDFieldGet("ZU_CC",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
		_cITCTB   := GDFieldGet("ZU_ITCTB",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
		_cCLVLDE  := GDFieldGet("ZU_CLVLI",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
		_cCLVLATE := GDFieldGet("ZU_CLVLF",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
		_cCONTADE := GDFieldGet("ZU_CONTAI",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
		_cCONTATE := GDFieldGet("ZU_CONTAF",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)

		IF (_nPos := Ascan(oBrw:aCols,{|x| !x[Len(oBrw:aHeader)+1] .and. x[_nPosITEM] <> _cITEM .and. x[_nPosCC] == _cCCUSTO .and.;
		x[_nPosITCT] == _cITCTB .and. x[_nPosCTDE] == _cCONTADE .and. x[_nPosCTATE] == _cCONTATE .and. x[_nPosCLDE] == _cCLVLDE .and. ;
		x[_nPosCLATE] == _cCLVLATE })) > 0
			Aviso("Duplicidade","Duplicidade com o item: "+GDFieldGet("ZU_ITEM",_nPos,,oBrw:aHeader,oBrw:aCols)+". Verifique!",{"Voltar"})
			_lRet := .F.
		ENDIF

		IF _lRet
			_nTotRat := 0
			_aDuplic := {}
			_lDuplic := .F.

			For i := 1 to Len(oBrw1:aCols)

				IF GDDeleted(i,oBrw1:aHeader,oBrw1:aCols)
					Loop
				ENDIF
				_nTotRat += GdFieldGet("ZV_PERC",i,,oBrw1:aHeader,oBrw1:aCols)

				IF !_lDuplic .and. Ascan(_aDuplic,GdFieldGet("ZV_CODEMP",i,,oBrw1:aHeader,oBrw1:aCols)) == 0
					Aadd(_aDuplic,GdFieldGet("ZV_CODEMP",i,,oBrw1:aHeader,oBrw1:aCols))
				ELSE
					_lDuplic := .T.
				ENDIF
			Next

			IF _nTotRat == 0
				Aviso("Atenção","Rateio por empresa não informado. Verifique!",{"Voltar"})
				_lRet := .f.
			ELSEIF _nTotRat < 100
				Aviso("Atenção","O total do rateio deve ser igual a 100%. Verifique!",{"Voltar"})
				_lRet := .f.
			ELSEIF _nTotRat > 100
				Aviso("Atenção","O total do rateio não pode ultrapassar 100%. Verifique!",{"Voltar"})
				_lRet := .f.
			ELSEIF _lDuplic
				Aviso("Atenção","Existe(m) empresa(s) em duplicidade(s). Verifique!",{"Voltar"})
				_lRet := .f.
			ENDIF
		ENDIF

	ENDIF

Return(_lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO07LOK
Validacao TudoOk.

@type function
@author Thiago Rasmussen
@since 07/05/2012
@version P12.1.23

@param _nOpc, Numérico, Código da opção selecionada.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação de todo o cadastro.

/*/
/*/================================================================================================================================/*/

User Function SIPCO07TOK(_nOpc)
	Local _lRet := .t.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF _nOpc == 1 // Regra

		U_SIPCO07LOK(1)

		IF M->ZT_STATUS == "2"
			SZT->(dbSetOrder(2))
			IF SZT->(dbSeek(XFilial("SZT")+M->ZT_ANO+"2")) .and. SZT->(ZT_ANO+ZT_REVISAO) <> M->(ZT_ANO+ZT_REVISAO)
				Aviso("Atenção","Já existe versão vigente de regra para este ano. Verifique!",{"Voltar"})
				_lRet := .f.
			ENDIF
		ENDIF

	ELSE // Distribuicao

		U_SIPCO07LOK(2)

	ENDIF

Return(_lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO07Orc
Retorna empresas participantes do rateio de mutuo.

@type function
@author Thiago Rasmussen
@since 11/05/2012
@version P12.1.23

@param _cCC, Caractere, Código do Centro de Custo.
@param _cITCTB, Caractere, Código do Item Contábil.
@param _cCLVL, Caractere, Código da Classe de Valor.
@param _cConta, Caractere, Código do Conta Contábil.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com os dados das empresas participantes do rateio de mutuo.

/*/
/*/================================================================================================================================/*/

User Function SIPCO07Orc(_cCC,_cITCTB,_cCLVL,_cConta)
	Local _cArea    := GetArea()
	Local _cQuery   := ""
	Local _cArqPER  := CriaTrab(nil,.f.)
	Local _aRet     := {}
	Default _cCLVL  := ""
	Default _cConta := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cQuery := "SELECT ZV_CODEMP,ZV_PERC FROM "+RetSqlName("SZT")+" SZT "
	_cQuery += "INNER JOIN "+RetSqlName("SZU")+" SZU ON ZT_ANO = ZU_ANO AND ZT_REVISAO = ZU_REVISAO "
	_cQuery += "INNER JOIN "+RetSqlName("SZV")+" SZV ON ZV_ANO = ZU_ANO AND ZV_REVISAO = ZU_REVISAO AND ZV_ITEMSZU = ZU_ITEM "
	_cQuery += "WHERE SZT.D_E_L_E_T_ = ' ' AND SZU.D_E_L_E_T_ = ' ' AND SZV.D_E_L_E_T_ = ' ' "
	_cQuery += "AND ZT_FILIAL = '"+XFilial("SZT")+"' AND ZU_FILIAL = '"+XFilial("SZU")+"' AND ZV_FILIAL = '"+XFilial("SZV")+"' "
	_cQuery += "AND ZU_CC = '"+Alltrim(_cCC)+"' AND ZU_ITCTB = '"+_cITCTB+"' "
	_cQuery += "AND '"+Alltrim(_cCLVL)+"'"+" BETWEEN ZU_CLVLI AND ZU_CLVLF "
	_cQuery += "AND '"+Alltrim(_cConta)+"'"+" BETWEEN ZU_CONTAI AND ZU_CONTAF "
	_cQuery += "AND ZT_ANO = '"+Left(Dtos(Date()),4)+"' AND ZT_STATUS = '2' "
	_cQuery += "ORDER BY ZV_CODEMP"
	_cQuery := ChangeQuery(_cQuery)

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqPER,.t.,.t.)

	While (_cArqPER)->(!Eof())
		Aadd(_aRet,{(_cArqPER)->ZV_CODEMP,(_cArqPER)->ZV_PERC})
		(_cArqPER)->(dbSkip())
	Enddo

	(_cArqPER)->(dbCloseArea())
	FErase(_cArqPER+GetDBExtension())
	FErase(_cArqPER+OrdBagExt())
	RestArea(_cArea)
Return(_aRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO07Rev
Cálculo próxima revisão.

@type function
@author Thiago Rasmussen
@since 15/05/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Código da Próxima Revisão.

/*/
/*/================================================================================================================================/*/

Static Function SIPCO07Rev()
	Local _cQuery  := ""
	Local _cArqRev := CriaTrab(nil,.f.)
	Local _cArea   := GetArea()
	Local _cRet    := "01"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cQuery := "SELECT MAX(ZT_REVISAO) ZT_REVISAO FROM "+RetSqlName("SZT")+" WHERE D_E_L_E_T_ = ' ' AND ZT_ANO = '"+SZT->ZT_ANO+"'"
	_cQuery := ChangeQuery(_cQuery)

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqRev,.t.,.t.)

	IF (_cArqRev)->(!Eof())
		_cRet := Soma1((_cArqRev)->ZT_REVISAO)
	ENDIF

	(_cArqRev)->(dbCloseArea())
	FErase(_cArqRev+GetDBExtension())
	FErase(_cArqRev+OrdBagExt())
	RestArea(_cArea)
Return(_cRet)
