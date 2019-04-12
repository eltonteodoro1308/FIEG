#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} GCP02PA8
Tratamento do Numero do Processo.

@type function
@author Thiago Rasmussen
@since 19/08/2012
@version P12.1.23

@obs Projeto ELO

@history 12/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function GCP02PA8()
	Local _cMod    := SubStr(PARAMIXB[1],1,2)
	Local _cSeque  := SubStr(PARAMIXB[1],3,5)
	Local _cAno    := SubStr(PARAMIXB[1],8)
	Local nOpc 	   := PARAMIXB[2]
	Local _lOk     := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If nOpc==5 .Or. nOpc==3  //Gerar Edital ou Incluir
		_lOk := .T.

		// Atualiza parâmetro de numeração
		CO1->(dbSetOrder(1))
		IF CO1->(DbSeek(xFilial("CO1")+M->CO1_CODEDT))
			_cNum := Soma1(M->CO1_CODEDT)
			_aAreaCO1 := CO1->(GetArea())

			While CO1->(DbSeek(xFilial("CO1")+_cNum))

				// Incrementa numeracao
				_cNum := Soma1(_cNum)

				CO1->(dbSkip())
			Enddo

			// Atualiza numeração
			M->CO1_CODEDT := _cNum

			Aviso("Aviso","O número do edital foi alterado para : "+_cNum,{"Ok"})

			RestArea(_aAreaCO1)
		ENDIF

		// Atualiza parâmetro de numeração
		PutMV("SI_NUMEDT",Soma1(M->CO1_CODEDT))
	Endif

	While _lOk
		DbSelectArea("PA8")
		PA8->(DbSetOrder(1))
		If PA8->(DbSeek(xFilial("PA8")+_cMod+_cAno))
			If PA8->PA8_BLQ == "0"
				RecLock("PA8",.F.)
				/*PA8->PA8_BLQ == "1"*/
				PA8->PA8_BLQ := "1"
				PA8->(MsUnlock())
				If PA8->PA8_SEQ == _cSeque .OR. PA8->PA8_SEQ > _cSeque
					_cSeque := Soma1(PA8->PA8_SEQ)
					RecLock("PA8",.F.)
					PA8->PA8_BLQ := "0"
					PA8->PA8_SEQ := _cSeque
					PA8->(MsUnlock())
					MsgAlert("O Numero do Processo Mudou para: "+ _cMod + _cSeque + "/" + _cAno )
					M->CO1_NUMPRO := _cMod + _cSeque + _cAno
					_lOk := .F.

				Else
					If PA8->PA8_SEQ < _cSeque
						RecLock("PA8",.F.)
						PA8->PA8_BLQ := "0"
						PA8->PA8_SEQ := _cSeque
						PA8->(MsUnlock())
						_lOk := .F.
					EndIf
				EndIf

			EndIf
		Else
			If PA8->(DbSeek(xFilial("PA8")+_cMod))
				RecLock("PA8",.F.)
				PA8->PA8_FILIAL := xFilial("PA8")
				PA8->PA8_BLQ 	:= "0"
				PA8->PA8_SEQ 	:= _cSeque
				PA8->PA8_ANO 	:= _cAno
				PA8->(MsUnlock())
			Else
				RecLock("PA8",.T.)
				PA8->PA8_FILIAL := xFilial("PA8")
				PA8->PA8_MOD 	:= _cMod
				PA8->PA8_BLQ 	:= "0"
				PA8->PA8_SEQ 	:= _cSeque
				PA8->PA8_ANO 	:= _cAno
				PA8->(MsUnlock())
			EndIf
			_lOk := .F.
		EndIf
	EndDo

Return()
