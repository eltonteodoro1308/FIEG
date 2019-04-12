#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA14
Gravacao do campo E2_DECRESC.

@type function
@author Claudinei Ferreira
@since 09/12/2011
@version P12.1.23

@obs Projeto ELO

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMA14

	Local aArea		:= GetArea()
	Local aAreaSD1	:= SD1->(GetArea())
	Local nTotMulta	:= 0
	Local nVlMltPar	:= 0
	Local aVlDescr	:= {}
	Local nX		:= 1
	Local lAchou	:= .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SD1->(dbSetOrder(1))
	If SD1->(dbSeek(xFilial('SF1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE))
		SD1->(dbEval({|| nTotMulta += D1_XMULTA},, {|| SD1->(D1_FILIAL+D1_DOC+D1_SERIE+SD1->D1_FORNECE) == xFilial('SF1')+SF1->(F1_DOC+F1_SERIE+F1_FORNECE)}))
	Endif

	//+---------------------------------------------+
	//|Calculo do valor da multa conforme a parcela |
	//|que esta sendo gravada.                      |
	//+---------------------------------------------+
	aVlDescr:= Condicao(nTotMulta,cCondicao,0,DDataBase)

	While nX <= Len(aVlDescr) .and. !lAchou
		If aVlDescr[nX][1]==SE2->E2_VENCTO
			lAchou:=.T.
			Reclock('SE2',.F.)
			SE2->E2_DECRESC := aVlDescr[nX][2]
			SE2->E2_SDDECRE := aVlDescr[nX][2]
			SE2->( MsUnlock() )

			Reclock('SF1',.F.)
			SF1->F1_XMULTA +=aVlDescr[nX][2]
			SF1->( MsUnlock() )
		Endif
		nX++
	End

	RestArea(aAreaSD1)
	RestArea(aArea)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xDATENTPC
Calculo do campo(D1_XDATRAS)com a diferenca entre os dias de entrega do PC e recebimento da NF(D1_XDTREC).

@type function
@author Claudinei Ferreira
@since 09/12/2011
@version P12.1.23

@param cCodProd, characters, Código do Produto.
@param cNumPC, characters, Número do Pedido de Compra.
@param cItemPC, characters, Item do Pedido de Compra.
@param cDtEntrega, characters, Data de Entrega do Pedido de Compra.

@obs Projeto ELO

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Diferenca entre os dias de entrega do PC e recebimento da NF.

/*/
/*/================================================================================================================================/*/

User Function xDATENTPC(cCodProd,cNumPC,cItemPC,cDtEntrega)

	Local aArea		:= GetArea()
	Local lContinua	:= .F.
	Local nDias		:= 0


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+----------------------------+
	//|Tipo da NF deve ser Normal  |
	//+----------------------------+
	If cTipo == 'N'
		lContinua:= (!Empty(cCodProd) .and. !Empty(cNumPC) .and. !Empty(cItemPC) .and. !Empty(cDtEntrega))

		//+--------------------------------+
		//|Localiza a data de entrega no PC|
		//+--------------------------------+
		If lContinua
			dbSelectArea("SC7")
			SC7->(DbSetOrder(4))
			SC7->(DbSeek(xFilial("SC7")+cCodProd+cNumPC+cItemPC))
			nDias:= cDtEntrega - SC7->C7_DATPRF
		Endif
	Endif

	RestArea(aArea)

Return(nDias)

/*/================================================================================================================================/*/
/*/{Protheus.doc} xCalcVlmlt
Calculo do valor de multa por item do Documento de Entrada conforme campo de dias de atraso no D1_XDATRAS.

@type function
@author Claudinei Ferreira
@since 09/12/2011
@version P12.1.23

@obs Projeto ELO

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Valor de multa por item do Documento de Entrada conforme campo de dias de atraso.

/*/
/*/================================================================================================================================/*/

User Function xCalcVlmlt

	Local nPorcMlt	:= 0
	Local nPosVlTot	:= 0
	Local nVlTotIt	:= 0
	Local nVlMlt	:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If cTipo == 'N' .AND. !Empty(M->D1_XDTREC) .AND. M->D1_XDATRAS > 0

		nPosVlTot:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
		nVlTotIt := aCols[n][nPosVlTot]

		nPorcMlt := SuperGetMV("MV_XJUREC")

		//+--------------------------------------------------------+
		//|Valor Total do Item * Nr dias atraso * (% Multa Dia/100)|
		//+--------------------------------------------------------+
		nVlMlt	 := nVlTotIt*M->D1_XDATRAS*(nPorcMlt/100)

	Endif

Return(nVlMlt)
