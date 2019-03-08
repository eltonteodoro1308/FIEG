#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA27
Chamada do Mutuo.

@type function
@author Thiago Rasmussen
@since 14/05/2012
@version P12.1.23

@param nOpc, Numérico, descricao
@param _cOrig, Caractere, descricao

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMA27(nOpc,_cOrig)
	Local nX 	 	 := 0
	Local aAlterEnch := {}
	Local cIniCpos   := ""
	Local cFieldOk   := "AllwaysTrue"
	Local cSuperDel  := ""
	Local cDelOk     := "AllwaysTrue"
	Local nOpcX		 := 0
	Local aHeader    := {}
	Local aCols      := {}
	Local aSimSC1    := {"C1_ITEM","C1_PRODUTO","C1_DESCRI","C1_QUANT","C1_VUNIT","C1_TOTAL","C1_CC","C1_CONTA","C1_ITEMCTA","C1_CLVL"}
	Local aSimSC7    := {"C7_ITEM","C7_PRODUTO","C7_DESCRI","C7_QUANT","C7_PRECO","C7_TOTAL","C7_CC","C7_CONTA","C7_ITEMCTA","C7_CLVL","C7_NUMSC","C7_ITEMSC"}
	Local aSimSD1    := {"D1_ITEM","D1_COD","D1_QUANT","D1_VUNIT","D1_TOTAL","D1_CC","D1_CONTA","D1_ITEMCTA","D1_CLVL","D1_PEDIDO","D1_ITEMPC"}
	Local aSimSZW    := {"ZW_ITEM","ZW_CODEMP","ZW_NOMEMP","ZW_PERC","ZW_NUMSC","ZW_ITEMSC"}
	Local aButtons   := {}
	Local lSegue     := .T.
	Private _nRateio := 0
	Private aHeader1 := {}
	Private aCols1   := {}
	Private oRateio
	Private oDlg
	Private oBrw,oBrw1
	Private oEnch
	Private aTELA[0][0]
	Private aGETS[0]
	// backup das distribuicoes
	Private aBkpCols := {}
	Private aBkpHead := {}
	Private _cOrigem := _cOrig


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF nOpc == 3
		// Só aceita inclusão para status igual a BLQ
		IF SC1->C1_APROV <> "B"
			Aviso("Atenção","Status inválido para inclusão de rateios. Verifique!",{"Voltar"})
			lSegue := .F. //Return()
		ENDIF

		SZW->(dbSetOrder(1))
		IF SZW->(MsSeek(xFilial("SZW")+SC1->C1_NUM))
			Aviso("Atenção","Já existe rateio informado para esta SC. Verifique!",{"Voltar"})
			lSegue := .F. //Return()
		ENDIF
	ELSE
		SZW->(dbSetOrder(1))
		IF _cOrigem == "SC"
			IF !SZW->(MsSeek(xFilial("SZW")+SC1->C1_NUM))
				Aviso("Atenção","Não existe rateio informado para esta SC. Verifique!",{"Voltar"})
				lSegue := .F. //Return()
			ENDIF
		ELSEIF _cOrigem == "PC"
			_cNumPC   := SC7->C7_NUM
			_aAreaSC7 := SC7->(GetArea())
			_lMutuo   := .f.

			SC7->(dbSetOrder(1))
			SC7->(dbSeek(XFilial("SC7")+_cNumPC))

			While SC7->(!Eof()) .and. SC7->C7_FILIAL == XFilial("SC7") .and. SC7->C7_NUM == _cNumPC

				IF Empty(SC7->C7_NUMSC)
					SC7->(dbSkip())
					Loop
				ENDIF

				IF SZW->(MsSeek(xFilial("SZW")+SC7->C7_NUMSC))
					_lMutuo := .t.
					Exit
				ENDIF

				SC7->(dbSkip())
			Enddo
			RestArea(_aAreaSC7)

			IF !_lMutuo
				Aviso("Atenção","Não existem SC's com mútuo amarradas a este pedido. Verifique!",{"Voltar"})
				lSegue := .F. //Return()
			ENDIF

		ELSEIF _cOrigem == "NF"
			_aAreaSC7 := SC7->(GetArea())
			_aAreaSD1 := SD1->(GetArea())
			_lMutuo   := .f.

			SD1->(dbSetOrder(1))
			SD1->(dbSeek(XFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

			While SD1->(!Eof()) .and. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

				IF Empty(SD1->D1_PEDIDO)
					SD1->(dbSkip())
					Loop
				ENDIF

				SC7->(dbSetOrder(1))
				SC7->(dbSeek(XFilial("SC7")+SD1->(D1_PEDIDO+D1_ITEMPC)))

				IF SZW->(MsSeek(xFilial("SZW")+SC7->C7_NUMSC))
					_lMutuo := .t.
					Exit
				ENDIF

				SD1->(dbSkip())
			Enddo

			RestArea(_aAreaSC7)
			RestArea(_aAreaSD1)

			IF !_lMutuo
				Aviso("Atenção","Não existem SC's com mútuo amarradas a este documento fiscal. Verifique!",{"Voltar"})
				lSegue := .F. //Return()
			ENDIF

		ENDIF
	ENDIF

	If lSegue

		// Verifica se existem lançamentos orçamentários
		IF nOpc <> 2
			_cNumSC := SC1->C1_NUM
			_aAreaSC1 := SC1->(GetArea())

			SZW->(dbSetOrder(1))
			IF SZW->(MsSeek(xFilial("SZW")+SC1->(C1_NUM+C1_ITEM)))
				_cFilBkp := cFilAnt
				While SZW->(!Eof()) .and. SZW->(ZW_FILIAL+ZW_NUMSC+ZW_ITEMSC) == XFilial("SZW")+SC1->(C1_NUM+C1_ITEM)
					// Altera empresa
					cFilAnt := SZW->ZW_CODEMP

					IF !SIPCO27Mut(_cFilBkp)

						lSegue := .F. //Return()
						Exit

					ENDIF

					// Restaura filial
					cFilAnt := _cFilBkp

					SZW->(dbSkip())
				Enddo
			ELSE
				IF !SIPCO27Mut()
					lSegue := .F. //Return()
				ENDIF
			ENDIF
		ENDIF

		If lSegue

			// Carga inicial do vetor
			IF nOpc <> 3
				IF _cOrigem == "SC" // Solicitacao
					cSeek  := SC1->(C1_FILIAL+C1_NUM)
					cWhile := "SZW->(ZW_FILIAL+ZW_NUMSC)"
					FillGetDados(4,"SZW",1,cSeek,{|| &cWhile },{|| .T. },/*aNaoCpo*/,aSimSZW,,,,,aBkpHead,aBkpCols)

					aEval(aBkpCols,{|x| x[GDFieldPos("ZW_NOMEMP",aBkpHead)] := Posicione("SM0",1,cEmpAnt+x[GDFieldPos("ZW_CODEMP",aBkpHead)],"M0_NOME") })
					aHeader := {}
					aCols   := {}
				ELSEIF _cOrigem == "PC" // Pedido
					_cNumPC   := SC7->C7_NUM
					_aAreaSC7 := SC7->(GetArea())

					SC7->(dbSetOrder(1))
					SC7->(dbSeek(XFilial("SC7")+_cNumPC))

					SZW->(dbSetOrder(1))

					While SC7->(!Eof()) .and. SC7->C7_FILIAL == XFilial("SC7") .and. SC7->C7_NUM == _cNumPC

						IF Empty(SC7->C7_NUMSC) .or. !SZW->(MsSeek(xFilial("SZW")+SC7->(C7_NUMSC+C7_ITEMSC)))
							SC7->(dbSkip())
							Loop
						ENDIF

						cSeek  := XFilial("SZW")+SC7->(C7_NUMSC+C7_ITEMSC)
						cWhile := "SZW->(ZW_FILIAL+ZW_NUMSC+ZW_ITEMSC)"
						FillGetDados(4,"SZW",1,cSeek,{|| &cWhile },{|| .T. },/*aNaoCpo*/,aSimSZW,,,,,aHeader,aCols)

						IF Empty(aBkpHead)
							aBkpHead := aClone(aHeader)
						ENDIF

						// Alimenta array geral
						For i := 1 to Len(aCols)
							Aadd(aBkpCols,aCols[i])
						Next

						// Limpa arrays
						aHeader := {}
						aCols   := {}

						SC7->(dbSkip())
					Enddo

					aEval(aBkpCols,{|x| x[GDFieldPos("ZW_NOMEMP",aBkpHead)] := Posicione("SM0",1,cEmpAnt+x[GDFieldPos("ZW_CODEMP",aBkpHead)],"M0_NOME") })

					RestArea(_aAreaSC7)

				ELSEIF _cOrigem == "NF" // Documento de Entrada

					_aAreaSC7 := SC7->(GetArea())
					_aAreaSD1 := SD1->(GetArea())
					_lMutuo   := .f.

					SD1->(dbSetOrder(1))
					SD1->(dbSeek(XFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

					While SD1->(!Eof()) .and. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

						IF Empty(SD1->D1_PEDIDO)
							SD1->(dbSkip())
							Loop
						ENDIF

						SC7->(dbSetOrder(1))
						SC7->(dbSeek(XFilial("SC7")+SD1->(D1_PEDIDO+D1_ITEMPC)))

						IF !SZW->(MsSeek(xFilial("SZW")+SC7->(C7_NUMSC+C7_ITEMSC)))
							SD1->(dbSkip())
							Loop
						ENDIF

						cSeek  := XFilial("SZW")+SC7->(C7_NUMSC+C7_ITEMSC)
						cWhile := "SZW->(ZW_FILIAL+ZW_NUMSC+ZW_ITEMSC)"
						FillGetDados(4,"SZW",1,cSeek,{|| &cWhile },{|| .T. },/*aNaoCpo*/,aSimSZW,,,,,aHeader,aCols)

						IF Empty(aBkpHead)
							aBkpHead := aClone(aHeader)
						ENDIF

						// Alimenta array geral
						For i := 1 to Len(aCols)
							Aadd(aBkpCols,aCols[i])
						Next

						// Limpa arrays
						aHeader := {}
						aCols   := {}

						SD1->(dbSkip())
					Enddo

					aEval(aBkpCols,{|x| x[GDFieldPos("ZW_NOMEMP",aBkpHead)] := Posicione("SM0",1,cEmpAnt+x[GDFieldPos("ZW_CODEMP",aBkpHead)],"M0_NOME") })

					RestArea(_aAreaSC7)
					RestArea(_aAreaSD1)

				ENDIF

			ENDIF

			IF _cOrigem == "SC"
				cSeek := SC1->(C1_FILIAL+C1_NUM)
				cWhile := "SC1->(C1_FILIAL+C1_NUM)"
				FillGetDados(4,"SC1",1,cSeek,{|| &cWhile },{|| .T. },/*aNaoCpo*/,aSimSC1,,,,,aHeader,aCols)
			ELSEIF _cOrigem == "PC"
				cSeek := SC7->(C7_FILIAL+C7_NUM)
				cWhile := "SC7->(C7_FILIAL+C7_NUM)"
				FillGetDados(4,"SC7",1,cSeek,{|| &cWhile },{|| .T. },/*aNaoCpo*/,aSimSC7,,,,,aHeader,aCols)
			ELSEIF _cOrigem == "NF"
				cSeek := SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
				cWhile := "SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)"
				FillGetDados(4,"SD1",1,cSeek,{|| &cWhile },{|| .T. },/*aNaoCpo*/,aSimSD1,,,,,aHeader,aCols)
			ENDIF

			cSeek  := ""
			cWhile := ""
			FillGetDados(3,"SZW",1,cSeek,{|| &cWhile },{|| .T. },/*aNaoCpo*/,aSimSZW,,,,,aHeader1,aCols1)
			GDFieldPut("ZW_ITEM",StrZero(1,TamSX3("ZW_ITEM")[1]),1,aHeader1,aCols1)

			//+--------------------------------------------------------------+
			//| Montagem da Tela de Consulta                                 |
			//+--------------------------------------------------------------+

			aSizeAut := MsAdvSize()

			DEFINE FONT oFnt 	NAME "Arial" SIZE 0, -11 BOLD

			oDlg := MSDIALOG():New(0,0,400,800, cCadastro,,,,,,,,,.T.)

			oPanel1 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,100,100,.T.,.T. )
			oPanel1:Align := CONTROL_ALIGN_TOP

			oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,25,25,.T.,.T. )
			oPanel2:Align := CONTROL_ALIGN_BOTTOM

			oPanel3 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,1,1,.T.,.T. )
			oPanel3:Align := CONTROL_ALIGN_ALLCLIENT

			If nOpc == 3
				INCLUI := .T.
				ALTERA := .F.
				nStyle := GD_INSERT+GD_UPDATE+GD_DELETE
			ElseIf nOpc == 4
				INCLUI := .F.
				ALTERA := .T.
				nStyle := GD_INSERT+GD_UPDATE+GD_DELETE
			Else
				INCLUI := .F.
				nStyle := 0
			Endif

			oBrw := MsNewGetDados():New(1,1,1,1,GD_INSERT,"U_SIPCO27LOK(1)","U_SIPCO27TOK()",,,,Len(aCols), cFieldOk, cSuperDel,cDelOk,oPanel1, aHeader, aCols)
			oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oBrw:oBrowse:bChange := {|| SICOM27Emp() }

			oBrw1 := MsNewGetDados():New(1,1,1,1,nStyle,"U_SIPCO27LOK(2)","AllwaysTrue", "+ZW_ITEM",,, 9999, cFieldOk, cSuperDel,cDelOk,oPanel3, aHeader1, aCols1)
			oBrw1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			// Só manipula quando for SC, pois PC e NF só visualiza
			IF _cOrigem == "SC"
				oBrw1:oBrowse:bChange := {|| GDFieldPut("ZW_NUMSC",SC1->C1_NUM,oBrw1:oBrowse:nAt,oBrw1:aHeader,oBrw1:aCols), GDFieldPut("ZW_ITEMSC",GdFieldGet("C1_ITEM",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols),oBrw1:oBrowse:nAt,oBrw1:aHeader,oBrw1:aCols),oBrw1:oBrowse:Refresh() }
			ENDIF

			@ 010,005 SAY OemToAnsi("% Total Rateado: ") Of oPanel2 PIXEL	FONT oFnt
			@ 008,060 MSGET oRateio  VAR _nRateio Picture "@E 999,999,999.99" Of oPanel2 READONLY SIZE 60,10 PIXEL

			IF nOpc == 3 .or. nOpc == 4
				Aadd(aButtons,{'S4WB013N',{|| SICOM27Atu() },"Regra de Rateio","Carregar Regra"})
			ENDIF

			oDlg:bInit	:= {|| EnchoiceBar(oDlg, {|| nOpcX:=1, aBkpHead := aClone(oBrw1:aHeader), IIf(oBrw:TudoOk() .and. oBrw1:TudoOk() .and.Obrigatorio(aGets, aTela),oDlg:End(),nOpcX:=0)}, {||nOpcx := 0, oDlg:End()},,aButtons)}
			oDlg:lCentered := .T.
			oDlg:Activate()

			If nOpcX == 1 .and. !nOpc == 2
				//Gravaçao dos Dados
				xCOM27GRV(nOpc)
			Endif

		EndIf

	EndIf

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} xCOM27GRV
Gravacao dos Dados.

@type function
@author Thiago Rasmussen
@since 17/05/2012
@version P12.1.23

@param nOpc, Numérico, Numero da opção selecionada (Inclusão, Alteração, Exclusão, Visualização).

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xCOM27GRV(nOpc)

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

			// Atualiza ultimo item
			_nPosItSC1 := GdFieldPos("ZW_ITEMSC",oBrw1:aHeader)
			For i := 1 to Len(oBrw1:aCols)
				IF (_nPos := Ascan(aBkpCols,{|x| x[_nPosItSC1] == oBrw1:aCols[i,_nPosItSC1] })) > 0
					aDel(aBkpCols,_nPos)
					aSize(aBkpCols,Len(aBkpCols)-1)
				ENDIF
			Next

			For i := 1 to Len(oBrw1:aCols)
				IF !Empty(GDFieldGet("ZW_ITEMSC",i,,oBrw1:aHeader,oBrw1:aCols))
					Aadd(aBkpCols,oBrw1:aCols[i])
				ENDIF
			Next

			//+-------------------------------+
			//|Gravacao das Distribuicoes     |
			//+-------------------------------+
			For i := 1 to Len(aBkpCols)

				// Desconsidera linhas sem empresa
				IF Empty(GdFieldGet("ZW_CODEMP",i,,aBkpHead,aBkpCols))
					Loop
				ENDIF

				_cItemSC := GdFieldGet("ZW_ITEMSC",i,,aBkpHead,aBkpCols)
				_cItemZW := GdFieldGet("ZW_ITEM",i,,aBkpHead,aBkpCols)

				SZW->(dbSetOrder(1))
				IF !SZW->(dbSeek(XFilial("SZW")+SC1->C1_NUM+_cItemSC+_cItemZW))
					IF GdDeleted(i,aBkpHead,aBkpCols)
						Loop
					ENDIF
					RecLock("SZW",.t.)
					SZW->ZW_FILIAL := xFilial("SZW")
					SZW->ZW_NUMSC  := SC1->C1_NUM
					SZW->ZW_USER   := __CUSERID
				ELSE
					RecLock("SZW",.f.)
					IF GdDeleted(i,aBkpHead,aBkpCols)
						SZW->(dbDelete())
						SZW->(msUnlock())
						Loop
					ENDIF
				ENDIF

				For x := 1 to Len(aBkpHead)
					If ( aBkpHead[x,10] <> "V" )
						SZW->(FieldPut(FieldPos(aBkpHead[x,2]),aBkpCols[i,x]))
					EndIf
				Next

				SZW->(msUnlock())
			Next

		Else

			// Exclui Regra
			SZW->(dbSetOrder(1))
			SZW->(MsSeek(xFilial("SZW")+SC1->C1_NUM))
			While SZW->(!Eof()) .and. SZW->(ZW_FILIAL+ZW_NUMSC) == XFilial("SZW")+SC1->C1_NUM
				Eval({|| RecLock("SZW",.f.), SZW->(dbDelete()), SZW->(MsUnLock()) })
				SZW->(dbSkip())
			EndDo

		Endif

	End Transaction

	// Restaura TTS
	__TTSInUse := lSavTTsInUse

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOM27Emp
Atualiza GET de distribuicao.

@type function
@author Thiago Rasmussen
@since 02/05/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function SICOM27Emp()

	Local _nPosItem  := GdFieldPos("ZW_ITEM",oBrw1:aHeader)
	Local _nPosNrSC1 := GdFieldPos("ZW_NUMSC",oBrw1:aHeader)
	Local _nPosItSC1 := GdFieldPos("ZW_ITEMSC",oBrw1:aHeader)


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF _cOrigem == "SC" // Solicitacao de Compra
		_cNumSC1  := SC1->C1_NUM
		_cItemSC1 := GdFieldGet("C1_ITEM",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
	ELSEIF _cOrigem == "PC" // Pedido de Compra
		_cNumSC1 := GdFieldGet("C7_NUMSC",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
		_cItemSC1 := GdFieldGet("C7_ITEMSC",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
	ELSE // Documento de Entrada
		_cNumPC  := GdFieldGet("D1_PEDIDO",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
		_cItemPC := GdFieldGet("D1_ITEMPC",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
		SC7->(dbSetOrder(1))
		IF SC7->(dbSeek(XFilial("SC7")+_cNumPC+_cItemPC))
			_cNumSC1  := SC7->C7_NUMSC
			_cItemSC1 := SC7->C7_ITEMSC
		ELSE
			_cNumSC1  := ""
			_cItemSC1 := ""
		ENDIF
	ENDIF

	For i := 1 to Len(oBrw1:aCols)
		IF (_nPos := Ascan(aBkpCols,{|x| x[_nPosItSC1] == oBrw1:aCols[i,_nPosItSC1] .and. x[_nPosNrSC1] == oBrw1:aCols[i,_nPosNrSC1] })) > 0
			aDel(aBkpCols,_nPos)
			aSize(aBkpCols,Len(aBkpCols)-1)
		ENDIF
	Next

	For i := 1 to Len(oBrw1:aCols)
		IF !Empty(GDFieldGet("ZW_ITEMSC",i,,oBrw1:aHeader,oBrw1:aCols))
			Aadd(aBkpCols,oBrw1:aCols[i])
		ENDIF
	Next

	oBrw1:aCols := {}

	For i := 1 to Len(aBkpCols)
		IF aBkpCols[i,_nPosItSC1] == _cItemSC1 .and. aBkpCols[i,_nPosNrSC1] == _cNumSC1
			Aadd(oBrw1:aCols,aBkpCols[i])
		ENDIF
	Next

	IF Len(oBrw1:aCols) == 0
		// Montagem da grade da distribuicao
		aCols1   := {}
		aAdd(aCols1,Array(Len(oBrw1:aHeader)+1))
		For nX := 1 To Len(oBrw1:aHeader)
			IF !(Alltrim(oBrw1:aHeader[nX][2]) $ "ZW_REC_WT|ZW_ALI_WT" )
				aCols1[1,nX] := CriaVar(oBrw1:aHeader[nX,2])
			ENDIF
		Next nX
		aCols1[1,Len(oBrw1:aHeader)+1] := .F.
		aCols1[1,_nPosItem]  := StrZero(1,TamSX3("ZW_ITEM")[1])
		aCols1[1,_nPosNrSC1] := _cNumSC1
		aCols1[1,_nPosItSC1] := _cItemSC1
		oBrw1:aCols := aClone(aCols1)
	ENDIF

	_nRateio := 0

	For i := 1 to Len(oBrw1:aCols)
		IF !GDDeleted(i,oBrw1:aHeader,oBrw1:aCols)
			_nRateio += NoRound(GDFieldGet("ZW_PERC",i,,oBrw1:aHeader,oBrw1:aCols),2)
		ENDIF
	Next

	oRateio:Refresh()

	oBrw:oBrowse:Refresh()
	oBrw1:oBrowse:Refresh()

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOM27Atu
Atualiza regra de rateio conforme orcamento.

@type function
@author Thiago Rasmussen
@since 16/05/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function SICOM27Atu()

	Local lSegue := .T.


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cCC	:= GdFieldGet("C1_CC",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
	_cITCTB	:= GdFieldGet("C1_ITEMCTA",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
	_cCLVL	:= GdFieldGet("C1_CLVL",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)
	_cConta	:= GdFieldGet("C1_CONTA",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols)

	IF Len( _aRegra := U_SIPCO07Orc(_cCC,_cITCTB,_cCLVL,_cConta) ) == 0
		Aviso("Atenção","Não existe regra cadastrada para as entidades contábeis deste título.",{"Voltar"})
		lSegue := .F. //Return()
	ENDIF

	IF lSegue .And. Aviso("Confirmação","Confirma importação da regra de rateio ?",{"Sim","Não"}) <> 1
		lSegue := .F. //Return()
	ENDIF

	If lSegue

		aCols1 := aClone(oBrw1:aCols)
		For i := 1 to Len(_aRegra)
			IF GdDeleted(Len(aCols1),aHeader1,aCols1) .or. !Empty(GdFieldGet("ZW_CODEMP",Len(aCols1),,aHeader1,aCols1))
				aAdd(aCols1,Array(Len(aHeader1)+1))
				For nX := 1 To Len(aHeader1)
					IF !(Alltrim(aHeader1[nX][2]) $ "ZW_REC_WT|ZW_ALI_WT" )
						aCols1[Len(aCols1),nX] := CriaVar(aHeader1[nX,2])
					ENDIF
				Next nX
				aCols1[Len(aCols1),Len(aHeader1)+1] := .F.
				aCols1[Len(aCols1),1]  := StrZero(Len(aCols1),TamSX3("ZW_ITEM")[1])
			ENDIF

			GDFieldPut("ZW_CODEMP",_aRegra[i,1],Len(aCols1),aHeader1,aCols1)
			GDFieldPut("ZW_NOMEMP",Posicione("SM0",1,cEmpAnt+_aRegra[i,1],"M0_NOME"),Len(aCols1),aHeader1,aCols1)
			GDFieldPut("ZW_PERC"  ,_aRegra[i,2],Len(aCols1),aHeader1,aCols1)
			GDFieldPut("ZW_NUMSC",SC1->C1_NUM,Len(aCols1),aHeader1,aCols1)
			GDFieldPut("ZW_ITEMSC",GdFieldGet("C1_ITEM",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols),Len(aCols1),aHeader1,aCols1)

		Next

		_nRateio := 0

		For i := 1 to Len(aCols1)
			IF !GDDeleted(i,aHeader1,aCols1)
				_nRateio += NoRound(GDFieldGet("ZW_PERC",i,,aHeader1,aCols1),2)
			ENDIF
		Next

		oRateio:Refresh()

		oBrw1:aCols := aClone(aCols1)
		oBrw1:oBrowse:Refresh()

	EndIf

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO27LOK
Validacao da linha.

@type function
@author Thiago Rasmussen
@since 06/05/2012
@version P12.1.23

@param _nOpc, Numérico, Numero da opção selecionada (Inclusão, Alteração, Exclusão, Visualização).

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação da Linha.

/*/
/*/================================================================================================================================/*/

User Function SIPCO27LOK(_nOpc)

	Local _lRet := .t.


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF _nOpc == 1 // Linha da SC

		_nTotRat := 0
		_aDuplic := {}
		_lDuplic := .F.

		For i := 1 to Len(oBrw1:aCols)

			IF GDDeleted(i,oBrw1:aHeader,oBrw1:aCols)
				Loop
			ENDIF
			_nTotRat += GdFieldGet("ZW_PERC",i,,oBrw1:aHeader,oBrw1:aCols)

			IF !_lDuplic .and. Ascan(_aDuplic,GdFieldGet("ZW_CODEMP",i,,oBrw1:aHeader,oBrw1:aCols)) == 0
				Aadd(_aDuplic,GdFieldGet("ZW_CODEMP",i,,oBrw1:aHeader,oBrw1:aCols))
			ELSE
				_lDuplic := .T.
			ENDIF
		Next

		IF _nTotRat > 0 .and. _nTotRat < 100
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

	IF _lRet
		_nRateio := 0

		For i := 1 to Len(oBrw1:aCols)
			IF !GDDeleted(i,oBrw1:aHeader,oBrw1:aCols)
				_nRateio += NoRound(GDFieldGet("ZW_PERC",i,,oBrw1:aHeader,oBrw1:aCols),2)
			ENDIF
		Next

		oRateio:Refresh()
	ENDIF

Return(_lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO27TOK
Validacao TudoOk.

@type function
@author Thiago Rasmussen
@since 16/05/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação TudoOk.

/*/
/*/================================================================================================================================/*/

User Function SIPCO27TOK()
	Local _lRet := U_SIPCO27lOK()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

Return(_lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO27Mut
Validacao para manutencao do mutuo.

@type function
@author Thiago Rasmussen
@since 14/06/2012
@version P12.1.23

@param _cFilOrig, Caractere, Filial de Origem.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação da manutenção do Mutuo.

/*/
/*/================================================================================================================================/*/

Static Function SIPCO27Mut(_cFilOrig)
	Local _lRet       := .t.
	Default _cFilOrig := cFilAnt


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	AKD->(dbSetOrder(10))
	IF AKD->(dbSeek(XFilial("AKD")+"SC1"+SC1->(C1_FILIAL+C1_NUM)))
		MsgStop("Esta SC possui movimentos orçamentários gerados"+IIF(_cFilOrig == cFilAnt,""," (Empresa "+cFilAnt+")")+". Verifique!")
		_lRet := .f.
	ENDIF

	// Verifica se existe contingencia
	ALI->(dbOrderNickName("SIALI01"))
	IF ALI->(dbSeek(xFilial("ALI")+SC1->C1_NUM))
		MsgStop("Esta SC possui contingências. Verifique!")
		_lRet := .f.
	ENDIF

Return(_lRet)
