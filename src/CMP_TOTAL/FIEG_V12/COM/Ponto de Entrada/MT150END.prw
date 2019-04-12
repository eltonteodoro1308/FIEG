#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT150END
Descrição detalhada da função.

@type function
@author TOTVS
@since 13/10/2011
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT150END()

	Local aArea 	:= GetArea()
	Local lPrjCni   := FindFunction("PRJCNI") .Or. GetRpoRelease("R6")

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If lPrjCni
		If l150Deleta

			//--< Caio.Santos - FSW - 06/02/2012 - Correcao estorno log exclusao cotacao >--
			If Select("SC1COT") > 0
				While !SC1COT->(EOF())

					If SC1->(dbSeek(xFilial("SC1")+SC1COT->C1_NUM+SC1COT->C1_ITEM))

						If Empty(SC1->C1_COTACAO)

							//--< Caio.Santos - 11/01/13 - Req.72 (Retirado) >--
							//COMA080(SC1COT->C1_NUM,SC1COT->C1_ITEM,"COI_DTHCOT","COI_UCOT",.T.,/*cUser*/,"COI_DOCCOT")
							//COMA080(SC1COT->C1_NUM,SC1COT->C1_ITEM,"COI_DTHATL","COI_UATL",.T.,/*cUser*/,"COI_DOCATL")  

							//--< Autor: Eric do Nascimento Data:17/02/12 >--
							//--< GAP: 104 Desc.: Limpa campo C1_NUMPR na >--
							//--< solicitacao de compra(SC1) >---------------
							U_SIC28NPR()

						EndIf
					EndIf

					SC1COT->(dbSkip())

				EndDo
				SC1COT->(dbCloseArea())						//Tabela criada no ponto de entrada anterior a exclusao da cotcacao MT150DEL
			EndIf
			__lDelCot := .F.

		Else
			//COMA080(SC8->C8_NUMSC,SC8->C8_ITEMSC,"COI_DTHATL","COI_UATL",/*lEstorno*/,/*cUser*/,"COI_DOCATL",SC8->C8_NUM)
		EndIf

	EndIf

	RestArea(aArea)

Return
