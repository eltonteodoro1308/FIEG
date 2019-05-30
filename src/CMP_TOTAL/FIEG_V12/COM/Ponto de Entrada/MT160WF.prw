#INCLUDE 'TOTVS.CH'

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT160WF
Ponto de Entrada Após a gravação dos pedidos de compras e contrato pela analise da cotação.
Utilizado para popular os campos C7_XESPEC ou CNB_XESPEC com o conteúdo do campo C1_XESPEC do item da solicitação de compras correspondenete.

@type function
@author Elton Teodoro Alves
@since 30/05/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 30/05/2018, elton.alves@TOTVS.com.br, PE implementado porque na versão 11.5 este processo funcionava conforme descrito e na 12.1.23 parou de funcionar.

/*/
/*/================================================================================================================================/*/
User Function MT160WF()

	Local cNumCot  := PARAMIXB[1]
	Local aArea    := GetArea()
	Local aAreaSC7 := SC7->( GetArea() )
	Local aAreaCNB := CNB->( GetArea() )
	Local cNumPed  := SC8->C8_NUMPED
	Local cNumCon  := SC8->C8_NUMCON
	Local cSolNum  := ''
	Local cSolItem := ''

	If !Empty( cNumPed )

		DbSelectArea( 'SC7' )
		DbSetOrder( 1 )

		If DbSeek( xFilial( 'SC7' ) + cNumPed )

			Do While SC7->( ! Eof() ) .And. SC7->C7_NUM == cNumPed

				cSolNum  := SC7->C7_NUMSC
				cSolItem := SC7->C7_ITEMSC

				RecLock( 'SC7', .F. )

				SC7->C7_XESPEC := GetXEspec( cSolNum, cSolItem )

				MsUnlock()

				SC7->( DbSkip() )

			End Do

		End If

	ElseIf !Empty( cNumCon )

		DbSelectArea( 'CNB' )
		DbSetOrder( 1 )

		If DbSeek( xFilial( 'CNB' ) + cNumCon )

			Do While CNB->( ! Eof() ) .And. CNB->CNB_CONTRA == cNumCon

				cSolNum  := CNB->CNB_NUMSC
				cSolItem := CNB->CNB_ITEMSC

				RecLock( 'SC7', .F. )

				CNB->CNB_XESPEC := GetXEspec( cSolNum, cSolItem )

				MsUnlock()

				CNB->( DbSkip() )

			End Do

		End If

	End If

	// Restaura as Áreas
	SC7->( RestArea( aAreaSC7 ) )
	CNB->( RestArea( aAreaCNB ) )
	RestArea( aArea )

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} GetXEspec
Retorna o conteúdo do campo C1_XESPEC do item de suma solicitação de compras.

@type function
@author Elton Teodoro Alves
@since 30/05/2018
@version P12.1.23

@param cSolNum,  Caractere, Número da Solicitação de Compras
@param cSolItem, Caractere, Item da Solicitação de Compras

@obs Desenvolvimento FIEG

@history 30/05/2018, elton.alves@TOTVS.com.br, .

/*/
/*/================================================================================================================================/*/
Static Function GetXEspec( cSolNum, cSolItem )

	Local cRet     := ''
	Local aArea    := GetArea()
	Local aAreaSC1 := SC1->( GetArea() ) 

	DbSelectArea( 'SC1' )
	DbSetOrder( 1 )

	If DbSeek( xFilial( 'SC1' ) + cSolNum + cSolItem )

		cRet := SC1->C1_XESPEC

	End If

	// Restaura as Áreas
	SC1->( RestArea( aAreaSC1 ) )
	RestArea( aArea )

Return cRet

