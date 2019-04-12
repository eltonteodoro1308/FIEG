#Include "Protheus.ch"
#Include "TopConn.ch"
#include "TbiConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PadraoProtheusDoc
Ponto de Entrada na rotina de Eliminacao de Residuo, antes de executar a eliminacao as Solicitacoes de Compra (SC1).

@type function
@author Kley@TOTVS.com.br
@since 13/10/2011
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se processamento ocorreu com sucesso.
/*/
/*/================================================================================================================================/*/

User Function MT235G2()

Local oFont1
Local lExecuta  := GetMv("SI_SCRESID",.F.,.F.)
Local oDlg      := Nil
Local cObsSC    := ""
Local oObsSC
Local nOpca     := 0
Local bOk       := {|| nOpca:=1, oDlg:End() }
Local bCancel   := {|| nOpca:=0, oDlg:End() }
Local nPerc     := MV_PAR01
Local nRes      := 0
Local cAlias    := ParamIXB[1]
Local nTipo     := ParamIXB[2]
Local nOrdemSC1 := (cAlias)->(IndexOrd())
Local nRecnoSC1 := (cAlias)->(Recno())

Static _xlOk
Static _xcObsSC
Static _xcObsSC2
Static _xlCancela

Define Font oFont1 Name "Consolas" Size 07,17

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If lExecuta .and. _xlOk == Nil .and. (nTipo == 3 .or. nTipo == 1)
	_xlOk := .F.
ElseIf !lExecuta .and. _xlOk == Nil .and. (nTipo # 3 .and. nTipo # 1)
	_xlOk := .T.
EndIf

Do While lExecuta .and. _xlCancela # .T. .and. Empty(_xcObsSC) .and. (nTipo == 3 .or. nTipo == 1)

	Define MsDialog oDlg Title "Eliminacao de Residuo" From 0,0 To 190,532 Of oDlg Pixel
	
	@ 06,06 To 60,261 LABEL " Informe o Motivo da Eliminacao do Residuo " OF oDlg PIXEL
	@ 20,15 Get oObsSC     Var cObsSC Multiline Text Font oFont1 Size 240,30 Pixel Of oDlg
	
	@ 70,225 Button "&Ok"       Size 36,16 Pixel Action Eval(bOk)
	@ 70,179 Button "&Cancela"  Size 36,16 Pixel Action Eval(bCancel)
	
	Activate MsDialog oDlg Center

	_xcObsSC   := ""
	_xlOk        := .F.

   	If nOpca == 0
   		MsgStop("O processamento foi abortado.","Motivo da Eliminação")
   		_xlCancela := .T.
   	Else
   		_xcObsSC2 := AllTrim(StrTran(cObsSC,CRLF," "))

	   	If Empty(_xcObsSC2)
			MsgAlert("O Motivo da Eliminação deve ser informado." +CRLF+CRLF+ "Se necessario abortar clique em 'Cancelar'.","Motivo da Eliminação")				
	   	ElseIf Len(_xcObsSC2) < 5
			MsgAlert("O Motivo informado é muito curto.","Motivo da Eliminação")				
	   	ElseIf Len(_xcObsSC2) > 203
			MsgAlert("O Motivo é muito extenso. Deve conter no máximo 200 caracteres." +CRLF+CRLF+;
			         "Você informou " + LTrim(Str(Len(_xcObsSC2))) + " caracteres.","Motivo da Eliminação")
		Else
			_xcObsSC   := _xcObsSC2
			_xlOk        := .T.
		EndIf	
	EndIf

	Loop	
EndDo

If lExecuta .and. _xlCancela # .T. .and. !Empty(_xcObsSC) .and. _xlOk .and. nTipo == 3
	// Calcular o Residuo maximo da Compra
	nRes := ((cAlias)->C1_QUANT * nPerc)/100		
	// Verifica se a Solicitacao deve ser Encerrada
	If ((cAlias)->C1_QUANT - (cAlias)->C1_QUJE <= nRes .And. (cAlias)->C1_QUANT > (cAlias)->C1_QUJE)
		Begin Transaction
			dbSelectArea("SC1")
			dbGoto((cAlias)->(SC1RECNO))
			If SimpleLock("SC1")
				RecLock("SC1",.F.)                                  	
					Replace C1_XRESMOT WITH _xcObsSC
					Replace C1_XRESUSR WITH __cUserID
					Replace C1_XRESDTA WITH dDatabase
					Replace C1_XRESHOR WITH Left(Time(),5)
				SC1->(MsUnlock())
			EndIf
		End Transaction
	Endif
EndIf
	    
If lExecuta .and. _xlCancela # .T. .and. !Empty(_xcObsSC) .and. _xlOk .and. nTipo == 1
	// Calcular o Residuo maximo da Compra
	nRes := ((cAlias)->C7_QUANT * nPerc)/100		
	// Verifica se a Solicitacao deve ser Encerrada
	If ((cAlias)->C7_QUANT - (cAlias)->C7_QUJE <= nRes .And. (cAlias)->C7_QUANT > (cAlias)->C7_QUJE)
		Begin Transaction
			dbSelectArea("SC7")
			SC7->(dbGoto((cAlias)->(SC7RECNO)))
			If SimpleLock("SC7")
				RecLock("SC7",.F.)
					Replace C7_XRESMOT WITH _xcObsSC
					Replace C7_XRESUSR WITH __cUserID
					Replace C7_XRESDTA WITH dDatabase
					Replace C7_XRESHOR WITH Left(Time(),5)
				SC7->(MsUnlock())
			EndIf
		End Transaction
	Endif
EndIf 

(cAlias)->(DbSetOrder(nOrdemSC1))                                     
(cAlias)->(DbGoto(nRecnoSC1))

Return _xlOk
