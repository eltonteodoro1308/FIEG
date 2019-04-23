#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN121PED
Tratamento especifico do array de cabeçalho e itens antes da geração do pedido de compra.

@type function
@author Elton Alves
@since 23/04/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@return Array, Array de dusas posições composto pelo array do Cabeçalho na posição 1 e do array dos itens na posição 2.

/*/
/*/================================================================================================================================/*/

User Function CN121PED()

	Local aCab  := PARAMIXB[1]
	Local aItem := PARAMIXB[2]

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	MyCN120IT7( @aItem )

	MyCN120PED( @aCab, @aItem )

	MyCN120AEP()

Return {aCab,aItem}

/*/================================================================================================================================/*/
/*/{Protheus.doc} MyCN120IT7
Ponto de Entrada para acrescentar campo num sc e Item da sc no array de itens.

@type function
@author Bruna Paola
@since 03/04/2012
@version P12.1.23

@param aItem, Array, Array com itens do pedido de compra recebido por referência.

@obs Projeto ELO alterado pela FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function MyCN120IT7( aItem )

	Local aArea := GetArea()
	//Local aItem := PARAMIXB[2]
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

Return //aItem

/*/================================================================================================================================/*/
/*/{Protheus.doc} MyCN120PED
Ponto de entrada executado no momento do encerramento da medicao, quando o sistema gera o pedido.

@type function
@author Alexandre Cadubtski
@since 03/05/2010
@version P12.1.23

@param _aCab, Array, Array com cabeçalho do pedido de compra recebido por referência.
@param _aItem, Array, Array com itens do pedido de compra recebido por referência.

@obs Projeto ELO alterado pela FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function MyCN120PED( _aCab, _aItem )

	Local _aArea    := GetArea()
	Local _aAreaSC1 := {}
	Local _cTipo	:= ""
	//Local _aCab     := PARAMIXB[1]	//Cabecalho
	//Local _aItem    := PARAMIXB[2]  //Itens
	//Local cAliasCNE := ParamIXB[3]
	Local _nPosItem := 0
	Local _cItemMed := ""
	Local _nI       := 0
	Local lRet      := .T.
	Local nPos      := 0
	Local nFISCORI  := 0
	//Local lTemSC  := .F.

	Public aPC := {}


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	nPos 		:= aScan(_aCab,{|x| x[1] == "C7_NUM"})
	nPosFilEnt := aScan(_aCab,{|x| x[1] == "C7_FILENT"})//Procura no array pela primeira coluna

	If (nPos > 0)
		aAdd(aPC, {_aCab[nPos, 2]})
	Endif

	//aEval(_aArea, {|x| RestArea(x)})

	dbSelectArea("CN9")
	CN9->(dbSetOrder(1))
	CN9->(dbSeek(xFilial("CN9") + CND->CND_CONTRA + CND->CND_REVISA))

	dbSelectArea("CN1")
	CN1->(dbSetOrder(1))
	CN1->(dbSeek(xFilial("CN1") + CN9->CN9_TPCTO))
	_cTipo := CN1->CN1_ESPCTR


	//+--------------------------------------------------------------------+
	//|Atualiza os itens com as entidades contabeis da planilha do contrato|
	//+--------------------------------------------------------------------+
	/*Esse trecho foi comentado pq esse fonte foi removido nao sei o motivo. Por Cadu em 04/03/13*/
	//	If _cTipo == "1"
	//		CNB->(dbSetOrder(1))
	//		For _nI:=1 to len(_aItem)
	//
	//			_nPosItem	:= aScan(_aItem[_nI],{|x| allTrim(x[1]) == "C7_ITEMED" })
	//			_cItemMed := _aItem[_nI][_nPosItem][2]
	//
	//			If CNB->(dbSeek(xFilial("CNB")+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+_cItemMed))
	//				aAdd(_aItem[_nI],{"C7_CONTA"	,CNB->CNB_CONTA	,NIL})
	//				aAdd(_aItem[_nI],{"C7_CC"		,CNB->CNB_XCC	,NIL})
	//				aAdd(_aItem[_nI],{"C7_ITEMCTA"	,CNB->CNB_XITEMC,NIL})
	//				aAdd(_aItem[_nI],{"C7_CLVL"		,CNB->CNB_XCLVL	,NIL})
	//				aAdd(_aItem[_nI],{"C7_EC05DB"	,CNB->CNB_XEC05D,NIL})
	//				aAdd(_aItem[_nI],{"C7_EC06DB"	,CNB->CNB_XEC06D,NIL})
	//				aAdd(_aItem[_nI],{"C7_EC07DB"	,CNB->CNB_XEC07D,NIL})
	//				aAdd(_aItem[_nI],{"C7_EC08DB"	,CNB->CNB_XEC08D,NIL})
	//				aAdd(_aItem[_nI],{"C7_EC09DB"	,CNB->CNB_XEC09D,NIL})
	//			EndIf
	//		Next _nI
	//	EndIF
	/**/
	CNB->(dbSetOrder(1))

	For _nI:=1 to len(_aItem)

		_nPosItem	:= aScan(_aItem[_nI],{|x| allTrim(x[1]) == "C7_ITEMED" })
		_cItemMed := _aItem[_nI][_nPosItem][2]
		nFISCORI   := aScan(_aItem[_nI],{|x| Alltrim(x[1])  == "C7_FISCORI"})

		//Foi preciso implementar esta validação (2 IFs abaixo) para os casos em que os contratos são gerados
		//sem SC-->COTACAO/EDITAL - Este processo não consta na MIT mas foram detectadas situações na FIRJAN.
		If CNB->(MsSeek(xFilial("CNB")+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+_cItemMed))

			If !Empty(CNB->CNB_NUMSC) //Se o contrato foi gerado por SC-->COTACAO/EDITAL pega a filial de entraga da SC

				//lTemSC := .T.

				If CN9->CN9_XREGP == "2" .Or. Empty(CN9->CN9_XREGP)//SE NAO FOR REGISTRO DE PRECO

					If CN9->CN9_FILIAL <> CN9->CN9_FILORI

						If nFISCORI <> 0

							_aItem[_nI,nFISCORI,2] := CN9->CN9_FILORI

						EndIf

					Else

						If nFISCORI <> 0

							_aItem[_nI,nFISCORI,2] := CN9->CN9_FILIAL

						EndIf

					EndIf

					If nPosFilEnt <> 0

						_aAreaSC1 := SC1->(GetArea())
						SC1->(DbSetOrder(1))
						SC1->(MsSeek(CNB->(CNB_FILIAL+CNB_NUMSC+CNB_ITEMSC)))
						_aCab[nPosFilEnt,2] := SC1->C1_FILENT
						RestArea(_aAreaSC1)

					EndIf

				Else //SE FOR REGISTRO DE PRECO

					If SC1->C1_FILIAL <> SC1->C1_FILENT

						If nFISCORI <> 0

							_aItem[_nI,nFISCORI,2] := SC1->C1_FILIAL

						EndIf

					Else

						If !Empty(Alltrim(SC1->C1_FILENT)) //Nesse caso o SC1 esta posicionado

							If nFISCORI <> 0

								_aItem[_nI,nFISCORI,2] := SC1->C1_FILENT

							EndIf

						EndIf

					EndIf

					//--Grava Filial de Entrega quando for Registro de Preço
					If nPosFilEnt <> 0

						_aCab[nPosFilEnt,2] := SC1->C1_FILENT

					EndIf

				EndIf

			Else //Se o contrato foi gerado diretamente na rotina CNTA100 pega a filial de entrega igual a filial do contrato

				If CN9->CN9_XREGP == "2" .Or. Empty(CN9->CN9_XREGP)//SE NAO FOR REGISTRO DE PRECO
					//If !Empty(Alltrim(SC1->C1_FILENT)) //Nesse caso o SC1 esta posicionado
					If nFISCORI <> 0 //Se achou soma com o que ja tem

						_aItem[_nI,nFISCORI,2] := xFilial("CNB")

					EndIf

					//--Grava Filial de Entrega quando NÃO for Registro de Preço,
					//--contrato gerado direto na rotina CNTA100
					If nPosFilEnt <> 0

						_aCab[nPosFilEnt,2] := xFilial("CNB")

					EndIf

				Else	//SE FOR REGISTRO DE PRECO

					If SC1->C1_FILIAL <> SC1->C1_FILENT

						If nFISCORI <> 0

							_aItem[_nI,nFISCORI,2] := SC1->C1_FILIAL

						EndIf

					Else

						If !Empty(Alltrim(SC1->C1_FILENT)) //Nesse caso o SC1 esta posicionado

							If nFISCORI <> 0

								_aItem[_nI,nFISCORI,2] := SC1->C1_FILENT

							EndIf

						EndIf

					EndIf

					//--Grava Filial de Entrega quando for Registro de Preço
					If nPosFilEnt <> 0

						_aCab[nPosFilEnt,2] := SC1->C1_FILENT

					EndIf

				EndIf

			EndIf

		EndIf

	Next

	//Incluido o trecho abaixo para tratamento da filial de entrega vinculada a SC
	/**/
	//	If _cTipo == "1"
	//
	//		nPosFilEnt := aScan(_aCab,{|x| x[1] == "C7_FILENT"})//Procura no array pela primeira coluna
	//
	//		//Foi preciso implementar esta validação para os casos em que os contratos são gerados
	//		//sem SC-->COTACAO/EDITAL - Este processo não consta na MIT mas foram detectadas situações na FIRJAN.
	//		If lTemSC //Se o contrato foi gerado por SC-->COTACAO/EDITAL pega a filial de entraga da SC
	//
	//			If !Empty(Alltrim(SC1->C1_FILENT)) //Nesse caso o SC1 esta posicionado
	//
	//				If nPosFilEnt <> 0
	//
	//					_aCab[nPosFilEnt,2] := SC1->C1_FILENT
	//
	//				EndIf
	//
	//			EndIf
	//
	//		Else//Se o contrato foi gerado diretamente na rotina CNTA100 pega a filial de entrega igual a filial do contrato
	//
	//			If CN9->CN9_XREGP == "2" .Or. Empty(CN9->CN9_XREGP)//SE NAO FOR REGISTRO DE PRECO
	//
	//				If nPosFilEnt <> 0
	//
	//					_aCab[nPosFilEnt,2] := xFilial("CNB")
	//
	//				EndIf
	//
	//			Else	//SE FOR REGISTRO DE PRECO
	//
	//				_aCab[nPosFilEnt,2] := SC1->C1_FILENT
	//
	//			EndIf
	//
	//		EndIf
	//
	//	EndIF
	/**/
	RestArea(_aArea)

Return //{_aCab,_aItem}

/*/================================================================================================================================/*/
/*/{Protheus.doc} MyCN120AEP
Ponto de entrada para alterar a filial corrente antes do processamento da exclusão do pedido de compra.

@type function
@author Bruna Paola
@since 30/01/2012
@version P12.1.23

@obs Projeto ELO

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function MyCN120AEP()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Type("cFilOri") == "C"
		cXFil := CFILANT
		CFILANT := cFilOri
	EndIf

Return