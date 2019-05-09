#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SF1100E
Ponto de Entrada após exclusao de Documento de Entrada.

@type function
@author Thiago Rasmussen
@since 13/10/2011
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SF1100E()
	Local aArea     := GetArea()
	Local _cAreaSD1 := SD1->(GetArea())
	Local _cAreaSF1 := SF1->(GetArea())
	Local nX	    := 0
	Local cNumSC    := ""
	Local cItemSC   := ""
	Local lPrjCni   := FindFunction("PRJCNI") .Or. GetRpoRelease("R6")
	Local nPos01    := GDFieldPos( 'D1_PEDIDO',  aHeader )
	Local nPos02    := GDFieldPos( 'D1_ITEMPC', aHeader  )

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If lPrjCni
		//Exclui Log do Processo -> Inclusao Pre Nota
		For nX := 1 to Len(aCols)
			//C7_FILIAL+C7_NUM+C7_ITEM
			//cNumSC  := Posicione( "SC7", 1, xFilial("SC7")+aCols[nX][27]+aCols[nX][28], "C7_NUMSC"  )
			//cItemSC := Posicione( "SC7", 1, xFilial("SC7")+aCols[nX][27]+aCols[nX][28], "C7_ITEMSC" )

			cNumSC  := Posicione( "SC7", 1, xFilial("SC7")+aCols[nX][nPos01]+aCols[nX][nPos02], "C7_NUMSC"  )
			cItemSC := Posicione( "SC7", 1, xFilial("SC7")+aCols[nX][nPos01]+aCols[nX][nPos02], "C7_ITEMSC" )

			//COMA080(cNumSC,cItemSC,"COI_PNCHAV","COI_UCLS", .T.,/*cUser*/,"COI_PNCHAV")
			//COMA080(cNumSC,cItemSC,"COI_DTHLPN","COI_ULPN", .T.,/*cUser*/,"COI_PNCHAV")
			//COMA080(cNumSC,cItemSC,"COI_DTHATS","COI_UATS", .T.,/*cUser*/,"COI_PNCHAV")
			//COMA080(cNumSC,cItemSC,"COI_DTHCLS","COI_UCLS", .T.,/*cUser*/,"COI_PNCHAV")

		Next
	EndIf

	If  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") /*Rotina ESB*//*Rotina CARGA*/
		SZZ->(dbSetOrder(1))
		IF SZZ->(dbSeek(XFilial("SZZ")+"MATA103"))
			MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA24(5) } )
		EndIf

	EndIf

	// Exclusão de ativos
	U_SICOMA37()

	RestArea(aArea)
	RestArea(_cAreaSD1)
	RestArea(_cAreaSF1)

Return
