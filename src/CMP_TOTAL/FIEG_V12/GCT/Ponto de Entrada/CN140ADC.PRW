#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN140ADC
Customiza array dos itens a serem revisados.

@type function
@author Thiago Rasmussen
@since 09/10/2017
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array customizado dos itens revisados .

/*/
/*/================================================================================================================================/*/

USER FUNCTION CN140ADC()

	//Local ExpA1 := PARAMIXB[1] // Array com as planilhas marcadas
	//Local ExpA2 := PARAMIXB[2] // Cabeçalho dos itens das planilhas que serão revisadas
	Local ExpA3 := PARAMIXB[3] // Itens das planilhas que serão revisadas
	//Local ExpC4 := PARAMIXB[4] // Tipo da revisão do contrato que monta os itens da planilha: 1 - Aditivo | 3 - Realinhamento | 4 - Readequação

	Local I          := 0
	Local iCNB_XITEM := 0
	Local _ARRAY     := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If PARAMIXB[4] == "1"
		For I := 1 To Len(PARAMIXB[2])
			Do Case
				Case PARAMIXB[2][I][02] == "CNB_XITEM"
				iCNB_XITEM := I
			EndCase
		Next I

		I := Len(ExpA3[1])

		While 0 < I
			ExpA3[1][I][iCNB_XITEM] := SUBSTR(ExpA3[1][I][iCNB_XITEM],1,3) + " "

			If ASCAN(_ARRAY, ExpA3[1][I][iCNB_XITEM]) == 0
				aAdd(_ARRAY, ExpA3[1][I][iCNB_XITEM])
				ExpA3[1][I][iCNB_XITEM] := SUBSTR(ExpA3[1][I][iCNB_XITEM],1,3) + "*"
			EndIf

			I -= 1
		EndDo
	EndIf

	/**/
	//	LOCAL I := 0
	//	LOCAL J := LEN(ExpA3[1])
	//
	//	WHILE I < J
	//		I += 1
	//		IF ExpA3[1][I][06] <= ExpA3[1][I][11]
	//			ADEL(ExpA3[1], I)
	//			J -= 1
	//			I -= 1
	//		ENDIF
	//	ENDDO
	//
	//	IF J <> LEN(ExpA3[1])
	//		ASize(ExpA3[1], J)
	//	ENDIF
	/**/

Return ExpA3