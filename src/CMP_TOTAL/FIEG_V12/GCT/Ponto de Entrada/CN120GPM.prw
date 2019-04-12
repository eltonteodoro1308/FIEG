#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120GPM
Ponto de entrada para gravar o número do pedido de compra gerado na medição correspondente.

@type function
@author Bruna Paola
@since 26/01/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CN120GPM()

	Local cNum    := PARAMIXB[1]  // Numero do Pedido de Compra
	Local cNumPed := PARAMIXB[2]  // Numero do Pedido de Compra

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Empty(AllTrim(CND->(FieldPos("CND_PEDIDO"))))

		RecLock("CND",.F.)
		If (!Empty(cNumPed))
			CND->CND_PEDIDO := cNumPed
		Else
			CND->CND_PEDIDO := cNum
		EndIf
		CND->(MsUnlock())

		//+-------------------------------------------------+
		//| Atualiza o campo CNE_PEDIDO dos itens da medicao|
		//| com o codigo do pedido gerado                   |
		//+-------------------------------------------------+
		dbSelectArea("CNE")
		(cAliasCNE)->(dbGoTop())
		While !(cAliasCNE)->(Eof())
			CNE->(dbGoto((cAliasCNE)->RECNO))
			RecLock("CNE",.F.)
			If (!Empty(cNumPed))
				CNE->CNE_PEDIDO := cNumPed
			Else
				CNE->CNE_PEDIDO := cNum
			EndIf
			CNE->(MsUnlock())
			(cAliasCNE)->(dbSkip())
		EndDo
	EndIf

	// Grava no Pedido o numero da SC

Return()