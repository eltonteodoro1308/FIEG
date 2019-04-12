#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PadraoProtheusDoc
Programa executado na revisão de contratos para auxiliar para validar campo CNB_VLUNIT.

@type function
@author Daniel Flávio
@since 23/01/2019
@version P12.1.23

@param cXCall, Caractere, Alias ativo antes de chamar a rotina.

@obs Desenvolvimento FIEG

@history 20/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro.
/*/
/*/================================================================================================================================/*/

User Function ZGCTM001(cXCall)

	Local lXRet		:= .T.
	Local nA		:= 0
	Local nPosQuant	:= 0
	Local nPosXItem	:= 0
	Local nPosProd	:= 0
	Local nPosVlUnit:= 0
	Local nPosDel	:= 0
	Local lXFind	:= .F.
	Default cXCall 	:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If Upper(cXCall) == "SX3"
	
		//--< Rotina Revisão de Contratos >---------------------
		If FunName() == "CNTA140"
			/*
				[cTipoCtr] 	- Tipo de Revisão 		- [1-Aditivo,2-Reajuste,3-Realinhamento,4-Readequação,5-Paralisação...]
				[cEspec]	- Espécie de Revisão 	- [1-Quantidade,2-Preço,3-Prazo,4-Quantidade/Prazo]
			*/
			If Type("N")#"U" .AND. ValType(cTipoCtr)=='C' .AND. cTipoCtr == '1' .AND. ValType(cEspec)=='C' .AND. cEspec == '1'

				If Type("aCols")#"U" .AND. Type("aHeader")#"U"
				
					nPosDel		:= Len(aHeader)+1
					nPosProd 	:= aScan(aHeader,{|x| AllTrim(x[2])=="CNB_PRODUT"	})
					nPosQuant	:= aScan(aHeader,{|x| AllTrim(x[2])=="CNB_QUANT"	})
					nPosXItem	:= aScan(aHeader,{|x| AllTrim(x[2])=="CNB_XITEM"	})
					nPosVlUnit	:= aScan(aHeader,{|x| AllTrim(x[2])=="CNB_VLUNIT"	})
					
					If Empty(aCols[N,nPosXItem])
						For nA := 1 To Len(aCols)
							If SubStr(aCols[nA,nPosXItem],4,1)=='*' .AND. aCols[nA,nPosProd]==aCols[N,nPosProd] .AND. aCols[nA,nPosVlUnit]==M->CNB_VLUNIT .AND. nA # N
								If !aCols[nA,nPosDel] 
									lXFind := .T.
									Exit
								EndIf
							EndIf
						Next
						
						If !lXFind	
							aCols[N,nPosVlUnit] := 0
							M->CNB_VLUNIT		:= 0
							
							If Type("oGetDad1")#"U"
								oGetDad1:oBrowse:Refresh()
							EndIf
							
							MsgStop("Os campos [produto] e [valor unitário] devem ser preenchidos com os mesmos dados de algum item da planilha que já foi inserido anteriormente.","ZGCTM001")
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
Return lXRet
