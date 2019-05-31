#INCLUDE 'TOTVS.CH'

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT160WF
Ponto de Entrada Após a gravação dos pedidos de compras e contrato pela analise da cotação.
Utilizado para popular os campos C7_XESPEC ou CNB_XESPEC com o conteúdo do campo C8_XESPEC do item da cotação de preço correspondenete.

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
	Local aAreaSC8 := SC8->( GetArea() )
	Local aAreaCNB := CNB->( GetArea() )

	DbSelectArea( 'SC8' )
	DbSetOrder( 1 )

	SC8->( DbGoTop() )

	If DbSeek( xFilial( 'SC8' ) + cNumCot )

		SetSC7( SC8->C8_NUMPED, SC8->C8_ITEMPED )

		SetCNB( SC8->C8_NUMSC, SC8->C8_ITEMSC )

		SC8->( DbSkip() )

	End If

	// Restaura as Áreas
	SC7->( RestArea( aAreaSC7 ) )
	SC8->( RestArea( aAreaSC8 ) )
	CNB->( RestArea( aAreaCNB ) )
	RestArea( aArea )

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} SetSC7
Popuala do campo C7_XESPEC com o conteúdo do campo C8_XESPEC.

@type function
@author Elton Teodoro Alves
@since 30/05/2018
@version P12.1.23

@param cNumPed, Caractere, Número do Pedido de Compra
@param cItemPed, Caractere, Item do Pedido de Compra

@obs Desenvolvimento FIEG

@history 30/05/2018, elton.alves@TOTVS.com.br, Popula do campo C7_XESPEC com o conteúdo do campo C8_XESPEC.

/*/
/*/================================================================================================================================/*/
Static Function SetSC7( cNumPed, cItemPed )

	DbSelectArea( 'SC7' )
	DbSetOrder( 1 )

	If DbSeek( xFilial( 'SC7' ) + cNumPed + cItemPed)

		RecLock( 'SC7', .F. )

		SC7->C7_XESPEC := SC8->C8_XESPEC

		SC7->( MsUnlock() )

	End If

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} SetSC7
Popula do campo CNB_XESPEC com o conteúdo do campo C8_XESPEC.

@type function
@author Elton Teodoro Alves
@since 30/05/2018
@version P12.1.23

@param cNumSc, Caractere, Número da Solicitação de Compra.
@param cItemSc, Caractere, Item da Solicitação de Compra.

@obs Desenvolvimento FIEG

@history 30/05/2018, elton.alves@TOTVS.com.br, Popula do campo CNB_XESPEC com o conteúdo do campo C8_XESPEC.

/*/
/*/================================================================================================================================/*/
Static Function SetCNB( cNumSc, cItemSc )

	DbSelectArea( 'CNB' )
	DbSetOrder( 2 )

	If DbSeek( xFilial( 'CNB' ) + cNumSc + cItemSc )

		RecLock( 'CNB', .F. )

		CNB->CNB_XESPEC := SC8->C8_XESPEC

		CNB->( MsUnlock() )

	End If

Return

