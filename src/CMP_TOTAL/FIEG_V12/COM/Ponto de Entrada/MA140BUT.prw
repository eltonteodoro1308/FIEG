#Include "Protheus.ch"
#include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA140BUT
Inclusão de botões no recebimento.

@type function
@author Daniel Flavio
@since  09/11/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com a lista de botões a serem incluídos.
/*/
/*/================================================================================================================================/*/

User Function MA140BUT()

	Local aBut		:= {}
	Local lVerEspIt :=SuperGetMv("MV_XXITESP",.F.,.T.)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If lVerEspIt
		If Type("aCols") == "A"
			Aadd(aBut,{"S4WB011N",  {|| fVerEspec() }, "Especificação do produto", "Especificação do produto" })
		EndIf
	EndIf

Return aBut

/*/================================================================================================================================/*/
/*/{Protheus.doc} fVerEspec
Mostra uma tela com informações de um campo MEMO.

@type function
@author Daniel Flavio
@since  09/11/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fVerEspec()

	Local aArea		:= GetArea()
	Local aAreaSC7	:= Iif(Select("SC7")>0,SC7->(GetArea()),GetArea())
	Local aAreaSC1	:= Iif(Select("SC1")>0,SC1->(GetArea()),GetArea())
	Local aAreaCNE	:= Iif(Select("CNE")>0,CNE->(GetArea()),GetArea())
	Local aAreaSF1	:= Iif(Select("SF1")>0,SF1->(GetArea()),GetArea())
	Local aAreaSD1	:= Iif(Select("SD1")>0,SD1->(GetArea()),GetArea())
	Local cEspec	:= ""
	Local oFont		:= NIL
	Local oMemo 	:= NIL
	Local oDlg		:= NIL
	Local nPosPed 	:= aScan(aHeader,{|x| Alltrim(x[2])=="D1_PEDIDO"})
	Local nPosItPed := aScan(aHeader,{|x| Alltrim(x[2])=="D1_ITEMPC"})

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If( Type("cA100For") == "C" .AND. !Empty(cA100For) .AND. !Empty(cLoja) .AND. ; 				// Cabeçalho
	nPosPed > 0 .AND. nPosItPed > 0 .AND. ;													// Existe no aHeader
	!Empty(aCols[n,nPosPed]) .AND. !Empty(aCols[n,nPosItPed]) )								// Itens


		dbSelectArea("SC7")

		// Verifica o Pedido de Compras
		If SC7->(dbSeek( xFilial("SD1") + aCols[n,nPosPed] + aCols[n,nPosItPed] ))

			// Verifica informação no Pedido de Compra
			If !Empty(SC7->C7_XESPEC)
				cEspec := SC7->C7_XESPEC
			EndIf

			// Verifica informação na cotação
			If Empty(cEspec)

				dbSelectArea("SC1")

				If !Empty(SC7->C7_NUMSC) .AND. SC1->(dbSeek( xFilial("SD1") + SC7->(C7_NUMSC+C7_ITEMSC) ))
					cEspec := SC1->C1_XESPEC
				EndIf

			EndIf

			// Verifica informação na medição se houver
			If Empty(cEspec)

				dbSelectArea("CNE")

				If CNE->(dbSeek( xFilial("SD1") + SC7->C7_CONTRA + SC7->C7_CONTREV + "000001" + SC7->C7_MEDICAO + SC7->C7_ITEMED ))
					cEspec := CNE->CNE_XESPEC
				EndIf

			EndIf

		EndIf

		// Se retornou algo
		If !Empty(Alltrim(cEspec))

			Define Font oFont Name "Mono AS" Size 8, 12
			Define MsDialog oDlg Title GetSx3Cache("C7_XESPEC","X3_TITULO") From 3, 0 to 340, 417 Pixel
			@ 5, 5 Get oMemo Var cEspec Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont
			Define SButton From 153, 175 Type 1 Action oDlg:End() Enable Of oDlg Pixel
			Define SButton From 153, 145 Type 2 Action oDlg:End() Enable Of oDlg Pixel
			Activate MsDialog oDlg Center

		EndIf

	EndIf

	RestArea(aArea)
	RestArea(aAreaSC7)
	RestArea(aAreaSC1)
	RestArea(aAreaSF1)
	RestArea(aAreaSD1)

Return
