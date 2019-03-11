#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120EPM
Ponto de entrada para alterar a filial corrente antes do processamento da exclus�o do pedido de compra.

@type function
@author Bruna Paola
@since 19/03/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function CN120EPM()

	Local cProc := ""
	Local cFunc := "U_CNIEstMe" // Se for estorno da libera��o da SC
	Local lRet  := .F.
	Local nX := 0


	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	While !Empty(cProc := ProcName( nX++ )) .And. !lRet
		lRet := (Alltrim(Upper(cProc)) == cFunc)
	End

	// S� para estorno na rotina de medi��o
	If (SubStr(CND->CND_OBS,1,78) == "Medi��o gerada automaticamente a partir da libera��o da Solicita��o de Compras") .OR.;
	(SubStr(CND->CND_OBS,1,71) =="Medi��o gerada automaticamente a partir da inclus�o do pedido de compra")
		cXFil := CFILANT
		CFILANT := CND->CND_PEDFIL//Pega a filial da CND onde est� gravado o pedido de compra cFilOri

	ElseIf(lRet)
		// Posiciona na CND
		DbSelectArea("SC7")
		SC7->(DbSetOrder(1))
		SC7->(DbGoTop())

		If SC7->(DbSeek(xFilial("SC7")+SC1->C1_PEDIDO+SC1->C1_ITEMPED))
			DbSelectArea("CND")
			CND->(DbSetOrder(4))
			CND->(DbGoTop())

			If CND->(DbSeek(cFilCn9/*PA9->PA9_FILCN9*/+SC7->C7_MEDICAO))
				cXFil := CFILANT
				CFILANT := CND->CND_PEDFIL//Pega a filial da CND onde est� gravado o pedido de compra
			EndIf
		EndIf

		//	cXFil := CFILANT
		//	CFILANT := cFilOri

	EndIf

Return .T.