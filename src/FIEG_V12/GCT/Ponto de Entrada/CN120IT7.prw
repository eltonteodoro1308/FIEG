#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120IT7
Ponto de Entrada para acrescentar campo num sc e Item da sc no array de itens.

@type function
@author Bruna Paola
@since 03/04/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com os campos adicionados.

/*/
/*/================================================================================================================================/*/

User Function CN120IT7()

	Local aArea := GetArea()
	Local aItem := PARAMIXB[1]
	Local lRet 	:= IsInCallStack("U_CNI109AL")
	Local nPos	:= 0


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If lRet // Tratamento para geração de pedido na liberação da SC
		If Type("aXItSC") == "A"
			If (nPos:= ASCAN(aXItSC,{|x| VAL(x[1])==VAL(CNE->CNE_ITEM) }) ) > 0
				aAdd(aItem[Len(aItem)],{"C7_NUMSC",  aXItSC[nPos][2], NIL})
				aAdd(aItem[Len(aItem)],{"C7_ITEMSC", aXItSC[nPos][3], NIL})
			EndIf
		EndIf
		aAdd(aItem[Len(aItem)],{"C7_XESPEC",  CNE->CNE_XESPEC, NIL})
		aAdd(aItem[Len(aItem)],{"C7_CONTRA",  CN9->CN9_NUMERO, NIL})
		aAdd(aItem[Len(aItem)],{"C7_XFILCOM", CN9->CN9_FILIAL, NIL})
		If (nPos:= ASCAN(aItem[Len(aItem)],{|x| UPPER(ALLTRIM(x[1]))=="C7_FISCORI" }) ) > 0
			aItem[Len(aItem)][nPos][2]:= cFilOri
		EndIf
	Else
		aAdd(aItem[Len(aItem)],{"C7_XESPEC", CNE->CNE_XESPEC, NIL})

		// 20/02/2018 - Thiago Rasmussen - Verificar se existe diferença entre o total do item da medição e o total do pedido
		If (nPos := aScan(aItem[Len(aItem)],{|x| ALLTRIM(x[1])=="C7_TOTAL"})) > 0
			If aItem[Len(aItem)][nPos][2] <> CNE->CNE_VLTOT
				aItem[Len(aItem)][nPos][2] := CNE->CNE_VLTOT
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return aItem
