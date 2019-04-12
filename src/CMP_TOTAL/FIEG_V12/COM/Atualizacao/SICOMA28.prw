#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA28
Programa para calcular a proxima numeração utilizado nos processos de editais,
solicitação de compras, pedido de compras, geração de cotação e gestão de contratos.

@type function
@author Cristiano Macedo
@since 27/12/2011
@version P12.1.23

@param _cMod, Caractere, Modalidade do Processo.
@param _cProc, Caractere, Tipo do Processo onde: E = Editais / C = Geração de Cotação

@obs Projeto ELO alterado pela FIEG

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Próxima numeração.

/*/
/*/================================================================================================================================/*/
User Function SICOMA28(_cMod,_cProc)
	Local aArea    := GetArea()
	Local _cAno    := ""
	Local _lOk     := .F.
	Local _lNumOK  := .F.
	Local _lMvN    := SuperGetMv("MV_XNUCLEO")
	Local _cNucleo := ""
	Local cRet     := ''
	Private _cNewSeq := ""
	Private _cSeq2   := ""


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If _lMvN

		While .T.
			_cNucleo := U_MTNucleo()
			If !Empty(_cNucleo)
				DbSelectArea("SX5")
				SX5->(DbSetOrder(1))
				If SX5->(Dbseek(xFilial("SX5")+"X1"+_cNucleo))
					_cAno := Alltrim(Str(Year(dDataBase))) + _cNucleo
					Exit
				Else
					MsgAlert("NUCLEO: "+ _cNucleo +" está INCORRETO, favor verificar!")
					_cNucleo := ""
					Exit
				EndIf

			Else
				MsgAlert("NUCLEO DE COMPRAS não informado, favor informar o NUCLEO DE COMPRAS!")
				Exit
			EndIf
		EndDo

	Else
		_cAno := Alltrim(Str(Year(dDataBase)))
	EndIf

	If _cProc == "E"
		If Empty(M->CO1_NUMPRO)
			_lNumOK := .T.
		Else
			If _cMod == SubStr( M->CO1_NUMPRO, 1, 2 ) .AND. !_lMvN
				_lNumOK := .F.
			Else
				_lNumOK := .T.
			EndIf
		EndIf
	Else
		_lNumOK := .T.
	EndIF

	If _lNumOK
		/*If _cMod == "C"*/
		If _cProc== "C"
			DbSelectArea("PA8")
			PA8->(DbSetOrder(1))
			If PA8->(DbSeek(xFilial("PA8")+_cMod+_cAno))
				_cNewSeq := Soma1(PA8->PA8_SEQ)
				If PA8_BLQ == "0"
					RecLock("PA8",.F.)
					PA8->PA8_BLQ := "1"
					PA8->PA8_SEQ := _cNewSeq
					PA8->(MsUnlock())
					_lOk := U_lProx(_cMod,Alltrim(_cAno),.F.,_cProc)
				Else
					_lOk := U_lProx(_cMod,Alltrim(_cAno),.T.,_cProc)
				EndIf
			Else
				If PA8->(DbSeek(xFilial("PA8")+_cMod))
					_cNewSeq := "00001"
					RecLock("PA8",.F.)
					PA8->PA8_FILIAL := xFilial("PA8")
					PA8->PA8_BLQ 	:= "1"
					PA8->PA8_SEQ 	:= _cNewSeq
					PA8->PA8_ANO 	:= Alltrim(_cAno)
					PA8->(MsUnlock())
					_lOk := U_lProx(_cMod,Alltrim(_cAno),.F.,_cProc)
				Else
					_cNewSeq := "00001"
					RecLock("PA8",.T.)
					PA8->PA8_FILIAL := xFilial("PA8")
					PA8->PA8_MOD 	:= _cMod
					PA8->PA8_BLQ 	:= "1"
					PA8->PA8_SEQ 	:= _cNewSeq
					PA8->PA8_ANO 	:= Alltrim(_cAno)
					PA8->(MsUnlock())
					_lOk := U_lProx(_cMod,Alltrim(_cAno),.F.,_cProc)
				EndIf
			EndIf

			If _lOk
				DbSelectArea("PA8")
				PA8->(DbSetOrder(1))
				If PA8->(DbSeek(xFilial("PA8")+_cMod+Alltrim(_cAno)))
					If PA8->PA8_SEQ == _cNewSeq
						RecLock("PA8",.F.)
						PA8->PA8_BLQ := "0"
						PA8->(MsUnlock())
					EndIf
				EndIf
			EndIf
		EndIf

		If _cProc == "E"
			DbSelectArea("PA8")
			PA8->(DbSetOrder(1))
			If PA8->(DbSeek(xFilial("PA8")+_cMod+_cAno))
				_cNewSeq := Soma1(PA8->PA8_SEQ)
			Else
				_cNewSeq := "00001"
			EndIf
			U_lProx(_cMod,Alltrim(_cAno),.F.,_cProc)
			RestArea(aArea)
			cRet := _cSeq2 //Return(_cSeq2)
		EndIf

	EndIf

	If Empty( cRet )
		RestArea(aArea)
		If FunName() == "GCPA002"
			cRet :=  M->CO1_NUMPRO// Return(M->CO1_NUMPRO)
			//Else
			//Return()
		Endif

	EndIf

Return cRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} lProx
Gera o próximo Número do Processo.

@type function
@author Thiago Rasmussen
@since 19/08/2012
@version P12.1.23

@param _cMod, Caractere, Modalidade do Processo.
@param _cAno, Caractere, Ano da Data Base.
@param _lProx, Lógico, Indica se gera o próximo Número do Processo.
@param _cProc, Caractere, Tipo do Processo onde: E = Editais / C = Geração de Cotação

@obs Projeto ELO alterado pela FIEG

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, .

/*/
/*/================================================================================================================================/*/

User Function lProx(_cMod,_cAno,_lProx,_cProc)

	Local aXAreaSC1	:= Iif((Select("SC1")>0),SC1->(GetArea()),GetArea())
	Local aXAreaSC8	:= Iif((Select("SC8")>0),SC8->(GetArea()),GetArea())
	Local _lOk     := .F.
	Local _cNumSC8 := ""
	Local _aSC8    := {}
	Local _nSeek   := 0
	Local nX       := 0


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If !_lProx
		Do Case
			Case _cProc == "E"   //Editais
			//M->CO1_NUMPRO := _cMod + _cNewSeq + _cAno
			//_cSeq2 := _cMod + _cNewSeq + _cAno
			/*If _cMod $ "PE,PP"
			M->CO1_MODALI := "PG"
			Else
			M->CO1_MODALI := _cMod
			EndIf*/
			If IsInCallStack("GCPA02SCM")

				If Alltrim(MV_PAR01) $ "PG"

					M->CO1_NUMPRO := Alltrim(MV_PAR02) + _cNewSeq + _cAno
					_cSeq2 := _cMod + _cNewSeq + _cAno

				Else

					M->CO1_NUMPRO := _cMod + _cNewSeq + _cAno
					_cSeq2 := _cMod + _cNewSeq + _cAno

				EndIf

				M->CO1_MODALI := _cMod

			Else

				M->CO1_NUMPRO := _cMod + _cNewSeq + _cAno
				_cSeq2 := _cMod + _cNewSeq + _cAno

			EndIf
			//If Empty(M->CO1_XMODAL)
			//M->CO1_XMODAL:= _cMod
			//EndIf
			Case _cProc == "C"   //Geração de Cotação
			_cNumSC8 := PARAMIXB[1]
			DbSelectArea("SC8")
			SC8->( dbCloseArea() )
			DbSelectArea("SC8")
			SC8->( DbSetOrder(1) )
			If SC8->(DbSeek(xFilial("SC8")+_cNumSC8))
				While !SC8->(Eof()) .And. SC8->C8_NUM == _cNumSC8
					RecLock("SC8",.F.)
					SC8->C8_NPROC := _cMod + _cNewSeq + _cAno
					SC8->(MsUnLock())
					_nSeek:=ASCan(_aSC8,{|x|x[1]+x[2]==SC8->C8_NUMSC+SC8->C8_ITEMSC})
					If _nSeek==0
						AAdd(_aSC8,{SC8->C8_NUMSC,SC8->C8_ITEMSC})
					EndIf
					DbSelectArea("SC8")
					SC8->(DBSKIP())
				EndDo
			EndIf
			For nX := 1 to Len(_aSC8)
				DbSelectArea("SC1")
				SC1->(dbCloseArea())
				DbSelectArea("SC1")
				SC1->( DbSetOrder(1) )
				If DbSeek(xFilial("SC1") + _aSC8[nX][1]+_aSC8[nX][2])
					RecLock("SC1",.F.)
					SC1->C1_NUMPR := _cMod + _cNewSeq + _cAno
					SC1->(MsUnlock())
				EndIf
			Next nX
		EndCase
		_lOk := .T.
	Else
		While !_lOk
			DbSelectArea("PA8")
			PA8->(DbSetOrder(1))
			If DbSeek(xFilial("PA8")+_cMod+_cAno)
				If PA8_BLQ == "0"
					_cNew := Soma1(PA8->PA8_SEQ)
					RecLock("PA8",.F.)
					PA8->PA8_BLQ := "1"
					PA8->PA8_SEQ := _cNewSeq
					PA8->(MsUnlock())
					_cNumSC8 := PARAMIXB[1]
					DbSelectArea("SC8")
					SC8->(dbCloseArea())
					DbSelectArea("SC8")
					DbSetOrder(1)
					If DbSeek(xFilial("SC8")+_cNumSC8)
						While !SC8->(Eof()) .And. SC8->C8_NUM == _cNumSC8
							RecLock("SC8",.F.)
							SC8->C8_NPROC := _cMod + _cNewSeq + _cAno
							SC8->(MsUnLock())
							_nSeek:=ASCan(_aSC8,{|x|x[1]+x[2]==SC8->C8_NUMSC+SC8->C8_ITEMSC})
							If _nSeek==0
								AAdd(_aSC8,{SC8->C8_NUMSC,SC8->C8_ITEMSC})
							EndIf
							DbSelectArea("SC8")
							SC8->(DBSKIP())
						EndDo
					EndIf
					For nX := 1 to Len(_aSC8)
						DbSelectArea("SC1")
						SC1->(dbCloseArea())
						DbSelectArea("SC1")
						DbSetOrder(1)
						If DbSeek(xFilial("SC1") + _aSC8[nX][1]+_aSC8[nX][2])
							RecLock("SC1",.F.)
							SC1->C1_NUMPR := _cMod + _cNewSeq + _cAno
							SC1->(MsUnlock())
						EndIf
					Next nX
					_lOk := .T.
				EndIf
			EndIf
		EndDo
	EndIf

	RestArea(aXAreaSC1)
	RestArea(aXAreaSC8)
Return(_lOk)

/*/================================================================================================================================/*/
/*/{Protheus.doc} MTNucleo
Selecao do Nucleo.

@type function
@author Thiago Rasmussen
@since 19/08/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Código do Núcleo Selecionado.

/*/
/*/================================================================================================================================/*/

User Function MTNucleo()

	Local oGet1     := Nil
	Local cGet1     := Space(3)
	Local oSay1     := Nil
	Local oSButton1 := Nil
	Local oSButton2 := Nil
	Local cQuery    := ""
	Local oDlg    := Nil


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DEFINE MSDIALOG oDlg TITLE "Parametros" FROM 000, 000  TO 090, 200 COLORS 0, 16777215 PIXEL

	@ 012, 012 SAY oSay1 PROMPT "Nucleo de Compras" SIZE 053, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 010, 065 MSGET oGet1 VAR cGet1 SIZE 022, 010 OF oDlg COLORS 0, 16777215 F3 "X1" PIXEL
	DEFINE SBUTTON oSButton1 FROM 030, 040 TYPE 01 OF oDlg ENABLE ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED

Return(cGet1)
