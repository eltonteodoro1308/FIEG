#Include "Protheus.ch"
#Define ENTER Chr(13)+Chr(10)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA34
Ponto de entrada com customizações do Edital da CNI.
Executa uma serie de funcoes pertinentes as regras de negocio
aplicadas sobre a manutencao de Editais na empresa CNI.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@param nTipo, Numérico, Parâmetro 1.
@param cPar1, Caractere, Parâmetro 2.
@param cPar2, Caractere, Parâmetro 3.
@param cPar3, Caractere, Parâmetro 4.
@param cPar4, Caractere, Parâmetro 5.
@param cPar5, Caractere, Parâmetro 6.
@param aPar6, Array, Parâmetro 7.
@param aPar7, Array, Parâmetro 8.
@param nPar8, Numérico, Parâmetro 9.
@param aPar9, Array, Parâmetro 10.
@param aPar10, Array, Parâmetro 11.
@param cPar11, Caractere, Parâmetro 12.
@param cPar12, Caractere, Parâmetro 13.
@param aPar13, Array, Parâmetro 14.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Indefinido, descricao.

/*/
/*/================================================================================================================================/*/

User Function SICOMA34(nTipo, cPar1, cPar2, cPar3, cPar4, cPar5, aPar6, aPar7, nPar8, aPar9, aPar10, cPar11, cPar12, aPar13)

	Local aRet, cRet
	Local uRet := Nil

	Default nTipo := 0 , cPar1 := "", cPar2 := "", cPar3 := "", cPar4 := "", ;
	cPar5 := "", aPar6 := {}, aPar7 := {}, nPar8 := 0, aPar9 := {}, aPar10 := {}, cPar11 := "", aPar13 := {}


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	if nTipo = 1    //Lista na tela de Edicao as solicitacoes ja vinculadas anteriormente ao detalhe de Edital
		uRet :=  (SqlSolVinculadas(cPar1, cPar2, cPar3, cPar4))

	elseif nTipo = 2
		aRet := aPar6
		if AllTrim(cPar1) != ''
			Aadd(aRet, .T. )
		else
			Aadd(aRet, .F. )
		EndIf

		uRet := (aRet)


	elseif nTipo = 3 //Monta Script da tela de Solicitacoes
		cRet := " AND SC1.C1_PRODUTO = '" + cPar1 + "' "
		uRet := (cRet)


	elseif nTipo = 4     //obtem lista de Qtdes Originais do Edital, antes de qualquer manutenção

		uRet :=  (MontaListaQtdesOrginais(cPar1,cPar2,cPar3))



	elseif nTipo = 5 //Confere a Qtde editada com a Qtde original do Eidtal. Caso ele tenha aumentado a qtde, criticar e impedir!
		uRet :=  (VrfErrQtde(aPar6/*Vetor com novas qtdes*/, aPar7/*Vetor com qtdes originais*/, cPar1, cPar2, aPar13))



	elseif nTipo = 6 //Confere a Qtde editada com a Qtde original do Eidtal. Caso ele tenha aumentado a qtde, criticar e impedir!

		uRet :=  (AtQtde(aPar7, nPar8))


	elseif nTipo = 7 //Confere a Qtde editada com a Qtde original do Eidtal. Caso ele tenha aumentado a qtde, criticar e impedir!
		uRet :=  AjustStatus()


	elseif nTipo = 8
		DelItemEdital (cPar1, cPar2, aPar7)
		aPar7 := DelAlterados  (aPar6, aPar7)

		uRet :=  (aPar7)


	elseif nTipo = 9   //AJUSTA CAMPO REFERENTE A QTDE ENTREGUE

		AjSC1QtEntregue(.F.,"",cPar1, cPar2, cPar3, cPar4, aPar6, aPar7, aPar13)

		uRet :=  ("")


	elseif nTipo = 10 //Sempre apos editar as solicitacoes, sobreescrever a co2_orig !!

		uRet :=  (SetItemEdital(cPar1, cPar2, cPar3, cPar4, cPar5, aPar6, aPar7, nPar8, aPar9, aPar10, cPar11))


	elseif nTipo = 11 //Sempre apos editar as solicitacoes, sobreescrever a co2_orig !!
		uRet :=  (SetLstSolicitacoes(aPar6,aPar7))

	elseif nTipo = 12 //EXCLUI
		uRet :=  (ClearSC(cPar1, cPar2, cPar3, cPar4, aPar6, aPar7, aPar13))

	elseif nTipo = 13 //MARCA ITENS EXCLUIDOS OU INCLUIDO DO GRID DO EDITAL

		if nPar8 == 1
			uRet :=  (MarcaExclInc(cPar1, aPar7, .T.) )
		Else
			uRet :=  (MarcaExclInc(cPar1, aPar7, .F.) )
		EndIf

	elseif nTipo = 14 //Verifica se o Edital passou por um processo de estorno em algum momento
		uRet :=  (NaoMarkNoEstorno(cPar1, cPar2, cPar3))

	elseif nTipo = 15 //Verifica se o Edital passou por um processo de estorno em algum momento
		uRet :=  (TemRegsNaoMarkNoEstorno(cPar1, cPar2,0))


		//else if 16   ----  NAO EXISTIRA MAIS O TOPICO "16"

	elseif nTipo = 17 //produtos mostrados na hora de "dar Andamento" e apontar fornecedores ganhadores
		uRet :=  (MostraProd())

	elseif nTipo = 18 //fornecedores mostrados na hora de "dar Andamento" e apontar fornecedores ganhadores
		uRet :=  (MostraFornec())

	elseif nTipo = 19 //fornecedores mostrados na hora de "dar Andamento" e apontar fornecedores ganhadores

		uRet :=  (FiltroSql())

	elseif nTipo = 20 //Verifica se o Edital passou por um processo de estorno em algum momento

		uRet :=  (TemRegsNaoMarkNoEstorno(cPar1, cPar2,1))

	elseif nTipo = 21 //Verifica se o Edital passou por um processo de estorno em algum momento

		uRet :=  (PgSaldo(cPar1, cPar2, cPar3))

	elseif nTipo = 22 //Verifica se o Edital passou por um processo de estorno em algum momento

		uRet :=  (SaldoCO2())

	EndIf

Return uRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} SetItemEdital
Sempre que entrar Editando, re-setar qtde original CO2.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@param cPar1, Caractere, Parâmetro 1.
@param cPar2, Caractere, Parâmetro 2.
@param cPar3, Caractere, Parâmetro 3.
@param cPar4, Caractere, Parâmetro 4.
@param cPar5, Caractere, Parâmetro 5.
@param aPar6, Array, Parâmetro 6.
@param aPar7, Array, Parâmetro 7.
@param nPar8, Numérico, Parâmetro 8.
@param aPar9, Array, Parâmetro 9.
@param aPar10, Array, Parâmetro 10.
@param cPar11, Caractere, Parâmetro 11.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, descricao.

/*/
/*/================================================================================================================================/*/

Static Function  SetItemEdital(cPar1, cPar2, cPar3, cPar4, cPar5, aPar6, aPar7, nPar8, aPar9, aPar10, cPar11)

	Local lGrava := .F.

	Local aArea		:= GetArea()

	Local aRets := aclone(aPar7)

	Local nIndexProd := aScan(aRets, { |X| x[2] == cPar11 } )


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Select("CO2")

	CO2->(dbSetOrder(2))
	lGrava :=   CO2->(dbSeek(xFilial("CO2")+cPar1+cPar2+cPar5) )

	if lGrava  .And. nIndexProd > 0
		RecLock("CO2",.F.)
		CO2->CO2_ORIG:= nPar8

		aPar7[nIndexProd][1]:= nPar8//seta lista de qtdes usadas para criticas no final da Manutencao
		CO2->(MsUnLock())
	EndIf

	RestArea(aArea)

Return (aPar7)

/*/================================================================================================================================/*/
/*/{Protheus.doc} DelItemEdital
Se usuário zerou algum registro , limpa item do edital CO2.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@param cPar1, Caractere, Parâmetro 1.
@param cPar2, Caractere, Parâmetro 2.
@param aPar7, Array, Parâmetro 3.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function  DelItemEdital(cPar1,cPar2, aPar7)

	Local nCont,lGrava := .F.


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Select("CO2")

	for nCont := 1 to Len(aPar7)

		CO2->(dbSetOrder(1))
		lGrava := CO2->(dbSeek(xFilial("CO2")+cPar1+cPar2+aPar7[nCont][2]) )

		if lGrava .and. CO2->CO2_QUANT == 0 //se zerou qtde do detalhe apaga do sistema!

			RecLock("CO2",.F.)
			CO2->(dbDelete())
			CO2->(MsUnlock())
		EndIf

	Next

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} DelAlterados
Se na lista de controle Interno havia um produto X que gerou CO2, SC vinculados e o usuario apenas mudou o produto
no grid para Y, esta rotina marca o antigo produto X com o flag referente a exclusao. Desta forma o sistema desvincula
tudo que havia no nome do antigo X, evitando deixar lixo no SQL.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@param aPar6, Array, Parâmetro 1.
@param aPar7, Array, Parâmetro 2.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Descricao.

/*/
/*/================================================================================================================================/*/

Static Function  DelAlterados(aPar6, aPar7)
	Local nCont := 1
	Local aRet := {}
	Local nIndexProd


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	for nCont := 1 to Len(aPar7)

		aRet := aPar6
		nIndexProd := aScan(aRet, { |X| x[2] == aPar7[nCont][2] } )

		if (nIndexProd == 0)
			aPar7[nCont][3] := .T.//excluir da lista
		EndIf

	Next

Return	 (aPar7)

/*/================================================================================================================================/*/
/*/{Protheus.doc} AjSC1QtEntregue
Função que atualizada campo qt entregue na Solcitacao.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@param lLimpeza, Lógico, Parâmetro 1.
@param lProdExcluido, Lógico, Parâmetro 2.
@param cPar1, Caractere, Parâmetro 3.
@param cPar2, Caractere, Parâmetro 4.
@param cPar3, Caractere, Parâmetro 5.
@param cPar4, Caractere, Parâmetro 6.
@param aPar6, Array, Parâmetro 7.
@param aPar7, Array, Parâmetro 8.
@param aPar13, Array, Parâmetro 9.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function AjSC1QtEntregue(lLimpeza, lProdExcluido,cPar1, cPar2,cPar3,cPar4, aPar6, aPar7, aPar13)

	Local cQuery, nIndexProd
	Local cTpCto        := GETMV("MV_TPSCCT")  // FSW - TIPO DE SC ADITIVO CONTRATO
	Local aRets := {}
	Local lGrava := .F.
	Local aArea		:= GetArea()
	Local nPQUANT := GDFieldPos("CO2_QUANT",aPar13)


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Select("SC1")
	cQuery := " SELECT SC1.* FROM " + RetSqlName('SC1')  + " SC1 "
	cQuery += " WHERE SC1.C1_CODED = '" + cPar1
	cQuery += "' AND SC1.C1_NUMPR = '"  + cPar2
	cQuery += "' AND SC1.C1_XTIPOSC <> '"+cTpCto+"' "

	if lLimpeza
		cQuery += " AND SC1.C1_PRODUTO = '" +lProdExcluido+ "' "
	else
		aRets := aclone(aPar6)
	EndIf

	cQuery += " AND " + RetSQLCond("SC1")
	cQuery += " ORDER BY SC1.C1_PRODUTO"

	cQuery 	:= ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB_SC1",.T.,.T.)
	dbSelectArea("TRB_SC1")

	while (TRB_SC1->(!Eof()))

		nIndexProd := aScan(aRets, { |X| x[2] == TRB_SC1->(C1_PRODUTO) } )

		if (nIndexProd > 0 .and. !lLimpeza) .or. lLimpeza //se o usuario apenas alterou a coluna PRODUTO para um código que nao havia antes, evito efetuar as consistencias abaixo

			Select("SC1")
			SC1->(dbSetOrder(1))

			lGrava := SC1->( MsSeek(TRB_SC1->(C1_FILIAL) + TRB_SC1->(C1_NUM) + TRB_SC1->(C1_ITEM)) )

			If  lGrava

				if lLimpeza
					//rotina que limpa SCs vinculadas a um item de edital que fora excluido do grid
					ExcluiSC1()
				ELSE
					//rotina que aloca qtdes e desvincula SCs sem nece ssidade de uso(caso não precisemos mais alocacoes de qtdes)
					if SCMarcada (aPar7, TRB_SC1->(C1_NUM),TRB_SC1->(C1_ITEM))

						if aPar6[nIndexProd,nPQUANT] > 0
							ModifSC1(nIndexProd, cPar1, cPar2,cPar3,cPar4,aPar6,aPar13)
						else
							ExcluiSC1()
						EndIf

					else
						ExcluiSC1()
					EndIf

				EndIf

			EndIf

		EndIf

		dbSelectArea("TRB_SC1")
		TRB_SC1->(dbSKip())

	End

	TRB_SC1->(dbCloseArea())

	if lLimpeza
		ExcluiCO2(lProdExcluido,cPar1, cPar2)
	EndIf

	RestArea(aArea)

return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ExcluiCO2
Descrição detalhada da função.

@type function
@author Thiago Rasmussen
@since
@version P12.1.23

@param lProdExcluido, Lógico, Parâmetro 1.
@param cPar1, Caractere, Parâmetro 1.
@param cPar2, Caractere, Parâmetro 2.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ExcluiCO2(lProdExcluido,cPar1,cPar2)

	Local lGrava := .F.


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Select("CO2")

	CO2->(dbSetOrder(1))
	lGrava := CO2->(dbSeek(xFilial("CO2")+cPar1+cPar2+lProdExcluido) )

	if lGrava
		RecLock("CO2",.F.)
		CO2->(dbDelete())
		CO2->(MsUnLock())
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ClearSC
Apaga vinculo entre SC e produtos excluidos do Edital(CO2).

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@param cPar1, Caractere, Parâmetro 1.
@param cPar2, Caractere, Parâmetro 2.
@param cPar3, Caractere, Parâmetro 3.
@param cPar4, Caractere, Parâmetro 4.
@param aPar6, Array, Parâmetro 5.
@param aPar7, Array, Parâmetro 6.
@param aPar13, Array, Parâmetro 7.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Fixo "".

/*/
/*/================================================================================================================================/*/

Static Function ClearSC(cPar1, cPar2, cPar3, cPar4, aPar6, aPar7, aPar13)

	Local nCont := 0


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	for nCont := 1 to len(aPar7)

		if aPar7[nCont][3] == .T.

			AjSC1QtEntregue(.T.,aPar7[nCont][2],cPar1, cPar2, cPar3, cPar4, aPar6, aPar7, aPar13)

		EndIf

	Next nCont

Return ("")

/*/================================================================================================================================/*/
/*/{Protheus.doc} SCMarcada
Descrição detalhada da função.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@param aListSC, Array, Lista de Solicitação de Compras.
@param nNumSC, Numérico, Número da Solicitação de Compras.
@param nItemSC, Numérico, Item da Solictação de Compras.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, descricao.

/*/
/*/================================================================================================================================/*/

Static Function SCMarcada(aListSC, nNumSC, nItemSC)
	Local nCont := 1
	Local aArea := GetArea()
	Local lRet  := .T.


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	For nCont := 1	to Len(aListSC)

		if aListSC[nCont][1] == .F. .AND. aListSC[nCont][2] == nNumSC  .AND. aListSC[nCont][3] ==  nItemSC
			RestArea(aArea)
			lRet :=  .F.
		EndIf

	Next nCont

	RestArea(aArea)

return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} ModifSC1
Função que atualiza vinculo com a solicitacao (Qtdes).

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@param nIndexProd, Numérico, Parâmetro 1.
@param cPar1, Caractere, Parâmetro 2.
@param cPar2, Caractere, Parâmetro 3.
@param cPar3, Caractere, Parâmetro 4.
@param cPar4, Caractere, Parâmetro 5.
@param aPar6, Array, Parâmetro 6.
@param aPar13, Array, Parâmetro 7.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.

/*/
/*/================================================================================================================================/*/

Static Function ModifSC1(nIndexProd,cPar1,cPar2,cPar3,cPar4,aPar6,aPar13)

	//Local nPQUANT := GDFieldPos("CO2_QUANT",aPar13)


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	RecLock("SC1",.F.)
	SC1->(C1_CODED):= cPar1
	SC1->(C1_NUMPR):= cPar2
	SC1->(C1_MODAL):= cPar3
	SC1->(C1_TPMOD):= cPar4

	// Comentado por Carlos Queiroz em 25/09/13 decorrente de inconsistência apresentada na Manutencao e no Cancelamento do Edital
	/*
	if aPar6[nIndexProd,nPQUANT] < SC1->(C1_QUANT)
	SC1->(C1_QUJE) := aPar6[nIndexProd,nPQUANT]
	aPar6[nIndexProd,nPQUANT] := 0
	else
	SC1->(C1_QUJE) := SC1->(C1_QUANT)
	aPar6[nIndexProd,nPQUANT] := aPar6[nIndexProd,nPQUANT] - SC1->(C1_QUANT)
	EndIf

	SC1->(C1_APROV):="B"
	*/
	SC1->(MsUnLock())

	//Caio.Santos - FSW - 15/03/2012 - Geracao log ao vincular SC no Edital
	COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COI",{},"COI_DTHEDT","COI_UEDT",/*lEstorno*/,/*cUser*/,"COI_DOCEDT",cPar1)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ExcluiSC1
Função que REMOVE vinculo com a solicitacao.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ExcluiSC1()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	RecLock("SC1",.F.)
	SC1->C1_CODED:= ''
	SC1->C1_NUMPR:= ''
	SC1->C1_MODAL:= ''
	SC1->C1_TPMOD:= ''
	SC1->C1_QUJE := 0
	SC1->C1_APROV:= ''
	SC1->C1_COTACAO:= ''

	SC1->(MsUnLock())

	//Caio.Santos - FSW - 15/03/2012 - Estorno de log ao desvincular SC do edital
	COMA080(SC1->C1_NUM,SC1->C1_ITEM,"SC1",{},"COI_DTHEDT","COI_UEDT",.T.,/*cUser*/,"COI_DOCEDT")

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} VrfErrQtde
Evita que usuario aumente a qtde do Edital.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@param aPar6, Array, Parâmetro 1.
@param aPar7, Array, Parâmetro 2.
@param cPar1, Caractere, Parâmetro 3.
@param cPar2, Caractere, Parâmetro 4.
@param aPar13, Array, Parâmetro 5.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Mensagem para o usuário.

/*/
/*/================================================================================================================================/*/

Static Function	VrfErrQtde(aPar6, aPar7, cPar1, cPar2, aPar13)

	Local cRet := "", nCont, nCont2
	Local lTemItem := .F.
	Local nPITEM   := GDFieldPos("CO2_ITEM",aPar13)
	Local nPCODPRO := GDFieldPos("CO2_CODPRO",aPar13)
	Local nPQUANT  := GDFieldPos("CO2_QUANT",aPar13)


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	for nCont := 1 to  Len(aPar6)

		for nCont2 := 1 to Len(aPar7)

			IF aPar7[nCont2][3] == .F.

				if aPar6[nCont,nPQUANT] > 0
					lTemItem := .T.
				EndIf

				if aPar7[nCont2][2] == aPar6[nCont,nPCODPRO] //Os itens Nao necessariamente estao ordenados da mesma forma nestas duas arrays
					if (aPar6[nCont,nPQUANT] > aPar7[nCont2][1])
						cRet := cRet + "Item: " + (aPar6[nCont,nPITEM]) +  " (Qtde: " + AllTrim(STR(aPar6[nCont,nPQUANT])) + ") " + ;
						"é superior a Qtde Original ( " + AllTrim(STR(aPar7[nCont2][1])) + ") " + ENTER
					EndIf

					cRet := cRet + QtSuperiorAsSolicitacoes (aPar6[nCont,nPQUANT],aPar7[nCont2][2], cPar1, cPar2)
					exit
				EndIf

			EndIf
		Next
	Next

	if !lTemItem
		cRet := "Informar Item para o Edital!"
	EndIf

return(cRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} QtSuperiorAsSolicitacoes
Evita que usuário informe uma quantidade em tela , menor que a qtde original, mas maior que a somatória das solicitações apontadas pelo usuário.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@param nQtInformada, Numérico, Parâmetro 1.
@param cProd, Caractere, Parâmetro 2.
@param cPar1, Caractere, Parâmetro 3.
@param cPar2, Caractere, Parâmetro 4.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Função sem retorno.

/*/
/*/================================================================================================================================/*/

Static Function QtSuperiorAsSolicitacoes(nQtInformada, cProd, cPar1, cPar2)

	Local cQuery,  cRet := ""
	Local cTpCto        := GETMV("MV_TPSCCT")  // FSW - TIPO DE SC ADITIVO CONTRATO
	Local lProdUsouSolicitacoes := .F.


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Select("SC1")
	cQuery := " SELECT SC1.* FROM " + RetSqlName('SC1') + " SC1 "
	cQuery += " WHERE SC1.C1_CODED = '"  + cPar1
	cQuery += "' AND SC1.C1_NUMPR = '"  +  cPar2
	cQuery += "' AND SC1.C1_PRODUTO = '" + cProd + "' "
	cQuery += " AND SC1.C1_XTIPOSC <> '"+cTpCto+"' "

	cQuery += " AND " + RetSQLCond("SC1")
	cQuery += " ORDER BY SC1.C1_PRODUTO"

	cQuery 	:= ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB_SC1",.T.,.T.)
	dbSelectArea("TRB_SC1")


	while (TRB_SC1->(!Eof()))

		lProdUsouSolicitacoes := .T.
		Select("SC1")
		SC1->(dbSetOrder(1))

		If SC1->( MsSeek(TRB_SC1->(C1_FILIAL) + TRB_SC1->(C1_NUM) + TRB_SC1->(C1_ITEM)) )

			if nQtInformada > 0


				if nQtInformada < SC1->(C1_QUANT)
					nQtInformada := 0

				else
					nQtInformada := nQtInformada - SC1->(C1_QUANT)
				EndIf

			EndIf

		EndIf

		dbSelectArea("TRB_SC1")
		TRB_SC1->(dbSKip())

	End

	if lProdUsouSolicitacoes .And. nQtInformada > 0 //Se a somatória das solicitaçoes não são suficientes para atender a qtde informada em tela ...então critica
		cRet :=  "Quantidade informada superior a somatória de Solicitações Apontadas!"  + ENTER
	EndIf

	TRB_SC1->(dbCloseArea())

Return (cRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} function_method_class_name
Monta vetor com lista de qtdes originalmente pedidas no Edital.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@param cPar1, Caractere, Parâmetro 1.
@param cPar2, Caractere, Parâmetro 2.
@param cPar3, Caractere, Parâmetro 3.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Lista de qtdes originalmente pedidas no Edital.

/*/
/*/================================================================================================================================/*/

Static Function  MontaListaQtdesOrginais(cPar1, cPar2, cPar3)

	Local aRet := {}


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	CO2->(dbSetOrder(1)) //CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO
	CO2->(dbSeek(cPar1 + cPar2 + cPar3) )
	While CO2->(!EOF())

		if CO2->(CO2_CODEDT) == cPar2 .and. CO2->(CO2_NUMPRO) == cPar3
			Aadd(aRet, {CO2->(CO2_ORIG), CO2->(CO2_CODPRO), .F./*.F. <=> Item Existe no GRID da CO2*/   } )
		Else
			Exit
		EndIf

		CO2->(dbSkip())
	EndDo

Return(aRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} MontaListaQtdesOrginais
Forca listar solciitacoes ja vinculadas a um item de edital.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@param cPar1, Caractere, Parâmetro 1.
@param cPar2, Caractere, Parâmetro 2.
@param cPar3, Caractere, Parâmetro 3.
@param cPar4, Caractere, Parâmetro 4.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Query com as Solicitações vinculadas.

/*/
/*/================================================================================================================================/*/
Static Function  SqlSolVinculadas(cPar1, cPar2, cPar3, cPar4)

	Local cRet := ""


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cRet := "  SELECT SC1.* "
	cRet += " FROM " + RetSqlTab("SC1")
	cRet += " WHERE      SC1.C1_CODED = '" + cPar1 + "' "
	cRet += " AND       SC1.C1_NUMPR = '"   + cPar2 + "' "
	cRet += " AND     SC1.C1_PRODUTO = '" + cPar3 + "' "
	cRet += " AND     SC1.C1_XTIPOSC <> '"+ cPar4 + "' "
	cRet += " AND " + RetSQLCond("SC1")
	cRet += " UNION ALL "

Return(cRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} AjustStatus
Funcao que habilita a rotina de acordo com o status do Edital.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function AjustStatus()

	Local cParam :=  ''
	public __lGCPCNI1 := .F.


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Select("CO1")

	cParam := SuperGetMV('MV_EDTPCO', .F., '  ', xFIlial("CO1"))

	//PB -> PE ->ED ->PC ->PM ->HO ->TP ->AD ->AC

	Do Case

		Case cParam == 'AC'

		if (CO1->CO1_ETAPA == 'AC' .or. CO1->CO1_ETAPA == 'AD' .or. CO1->CO1_ETAPA == 'TP' .or. CO1->CO1_ETAPA == 'HO' .or. ;
		CO1->CO1_ETAPA == 'PM' .or. CO1->CO1_ETAPA == 'PC' .or. CO1->CO1_ETAPA == 'ED' .or. CO1->CO1_ETAPA == 'PE' .or. ;
		CO1->CO1_ETAPA == 'PB' )
			__lGCPCNI1 := .T.
		Else
			__lGCPCNI1 :=  .F.
		EndIf

		Case cParam == 'AD'

		if (CO1->CO1_ETAPA == 'AD' .or. CO1->CO1_ETAPA == 'TP' .or. CO1->CO1_ETAPA == 'HO' .or. ;
		CO1->CO1_ETAPA == 'PM' .or. CO1->CO1_ETAPA == 'PC' .or. CO1->CO1_ETAPA == 'ED' .or. CO1->CO1_ETAPA == 'PE' .or.  ;
		CO1->CO1_ETAPA == 'PB' )
			__lGCPCNI1 :=  .T.
		Else
			__lGCPCNI1 :=  .F.
		EndIf

		Case cParam == 'TP'

		if (CO1->CO1_ETAPA == 'TP' .or. CO1->CO1_ETAPA == 'HO' .or. ;
		CO1->CO1_ETAPA == 'PM' .or. CO1->CO1_ETAPA == 'PC' .or. CO1->CO1_ETAPA == 'ED' .or. CO1->CO1_ETAPA == 'PE' .or.   ;
		CO1->CO1_ETAPA == 'PB' )
			__lGCPCNI1 :=  .T.
		Else
			__lGCPCNI1 :=  .F.
		EndIf

		Case cParam == 'HO'

		if (CO1->CO1_ETAPA == 'HO' .or. ;
		CO1->CO1_ETAPA == 'PM' .or. CO1->CO1_ETAPA == 'PC' .or. CO1->CO1_ETAPA == 'ED' .or. CO1->CO1_ETAPA == 'PE' .or.    ;
		CO1->CO1_ETAPA == 'PB' )
			__lGCPCNI1 :=  .T.
		Else
			__lGCPCNI1 :=  .F.
		EndIf

		Case cParam == 'PM'

		if (CO1->CO1_ETAPA == 'PM' .or. CO1->CO1_ETAPA == 'PC' .or. CO1->CO1_ETAPA == 'ED' .or. CO1->CO1_ETAPA == 'PE' .or.     ;
		CO1->CO1_ETAPA == 'PB' )
			__lGCPCNI1 :=  .T.
		Else
			__lGCPCNI1 :=  .F.
		EndIf

		Case cParam == 'PC'

		if (CO1->CO1_ETAPA == 'PC' .or. CO1->CO1_ETAPA == 'ED' .or. CO1->CO1_ETAPA == 'PE' .or.        ;
		CO1->CO1_ETAPA == 'PB' )
			__lGCPCNI1 :=  .T.
		Else
			__lGCPCNI1 :=  .F.
		EndIf

		Case cParam == 'ED'

		if (CO1->CO1_ETAPA == 'ED' .or. CO1->CO1_ETAPA == 'PE' .or.    ;
		CO1->CO1_ETAPA == 'PB' )
			__lGCPCNI1 :=  .T.
		Else
			__lGCPCNI1 :=  .F.
		EndIf

		Case cParam == 'PE'

		if (CO1->CO1_ETAPA == 'PE' .or.  CO1->CO1_ETAPA == 'PB' )
			__lGCPCNI1 :=  .T.
		Else
			__lGCPCNI1 :=  .F.
		EndIf

		Case cParam == 'PB'

		if (CO1->CO1_ETAPA == 'PB' )
			__lGCPCNI1 :=  .T.
		Else
			__lGCPCNI1 :=  .F.
		EndIf

	EndCase

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} MarcaExclInc
Marca o Item do Edital como Excluido do Grid pelo usuário ou Re-incluido no Grid.

@type function
@author Thiago Rasmussen
@since 24/01/2012
@version P12.1.23

@param cPar1, Caractere, Parâmetro 1.
@param aPar7, Array, Parâmetro 2.
@param lExcluindo, Lógico, Parâmetro 3.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Conteúdo do parâmetro aPar7 para marcação.

/*/
/*/================================================================================================================================/*/

Static Function MarcaExclInc(cPar1, aPar7, lExcluindo)

	Local nIndexProd := 0, nCont := 0
	Local cStr     := " "
	nIndexProd := aScan(aPar7 , { | X | x[2] == cPar1 } )


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	if nIndexProd > 0
		if lExcluindo
			aPar7[nIndexProd][3] := .T. //usuario excluiu item do grid
		Else
			aPar7[nIndexProd][3] := .F. //usuario excluiu item do grid
		EndIf
	else
		if !lExcluindo
			Select("CO2")
			CO2->CO2_ORIG:= CO2->(CO2_QUANT)

			Aadd(aPar7, {CO2->(CO2_QUANT), ; //ao incluir item pelo grid este nasce com qtd.original = qtde editada pelo usuario no grid de CO2!!!
			cPar1, .F./*.F. <=> Item Existe no GRID da CO2*/   } )

		EndIf

	EndIf

Return aPar7

/*/================================================================================================================================/*/
/*/{Protheus.doc} SetLstSolicitacoes
Cria lista de solicitacoes de Compra Editadas durante a Manutenção a fim de destinguir quais devem ser consideradas ou nao.

@type function
@author Thiago Rasmussen
@since 24/01/2012
@version P12.1.23

@param aPar6, Array, Parâmetro 1.
@param aPar7, Array, Parâmetro 2.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Lista de solicitacoes de Compra Editadas.

/*/
/*/================================================================================================================================/*/

Static Function SetLstSolicitacoes(aPar6, aPar7)
	Local nIndexProd := 0, nCont := 0


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	for nCont := 1 to len(aPar7)//aDados
		nIndexProd := aScan(aPar6 , { | X | x[2] == aPar7[nCont][2] } )

		if nIndexProd > 0
			aPar6[nIndexProd][1] := aPar7[nCont][1]//indica se SC está marcada
			aPar6[nIndexProd][2] := aPar7[nCont][2]//nro da SC
			aPar6[nIndexProd][3] := aPar7[nCont][3]//Index item da SC
		else
			aadd (aPar6, {aPar7[nCont][1],aPar7[nCont][2],aPar7[nCont][3]})
		EndIf
	Next

Return aPar6

/*/================================================================================================================================/*/
/*/{Protheus.doc} AtQtde
Cria lista de solicitacoes de Compra Editadas durante a Manutenção a fim de destinguir quais devem ser consideradas ou nao.

@type function
@author Thiago Rasmussen
@since 24/01/2012
@version P12.1.23

@param aPar7, Array, Parâmetro 1.
@param nPar8, Array, Parâmetro 2.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Lista de solicitacoes de Compra Editadas.
/*/
/*/================================================================================================================================/*/
Static Function AtQtde(aPar7, nPar8)

	Local nIndexProd := 0, nCont := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Select("CO2")
	CO2->CO2_ORIG := nPar8

	nIndexProd := aScan(aPar7 , { | X | x[2] == CO2->CO2_CODPRO } )

	if nIndexProd > 0
		aPar7[nIndexProd][1] := nPar8
	EndIf

Return aPar7

/*/================================================================================================================================/*/
/*/{Protheus.doc} SetQtOrig
Ajusta a coluna referente a qtde orginal no grid CO2.

@type function
@author Oswaldo Leite
@since 25/01/12
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Retorno da Função.

/*/
/*/================================================================================================================================/*/

//Static Function	SetQtOrig()		//Sem uso provisoriamente
//	Local nCont, nCont2
//
//	//1 = array
//	//2 = grid
//
//
//	//--< Log das Personalizações >-----------------------------
//	U_LogCustom()
//
//	//--< Processamento da Rotina >-----------------------------
//
//	for nCont := 1 to Len(PARAMIXB[2])
//
//		for nCont2 := 1 to Len(PARAMIXB[1])
//
//			IF PARAMIXB[1][nCont2][3] == .F.
//
//				if PARAMIXB[1][nCont2][2] == PARAMIXB[2][nCont][2] //Os itens Nao necessariamente estao ordenados da mesma forma nestas duas arrays
//					PARAMIXB[2][nCont][7] = PARAMIXB[1][nCont2][1]
//				EndIf
//			EndIf
//
//		Next
//
//	Next
//
//return(PARAMIXB[2])

/*/================================================================================================================================/*/
/*/{Protheus.doc} TemRegsNaoMarkNoEstorno
Define detalhes de edital que sofrerão estorno
1 - edital passou p/estorno mas este Item nao fora estornado
2 - edital passou por estorno E este Item foi estornado
0 - edital nao passou por estorno.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@param cPar1, Caractere, Parâmetro 1.
@param cPar2, Caractere, Parâmetro 2.
@param nIgnoraItem, Numérico, Parâmetro 3.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorno da Função.

/*/
/*/================================================================================================================================/*/

Static Function  TemRegsNaoMarkNoEstorno (cPar1, cPar2, nIgnoraItem)

	Local lRet := .F.
	Local cQuery
	Local aArea		:= GetArea()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cQuery := " SELECT CO2.* FROM " + RetSqlName('CO2')  + " CO2 "
	cQuery += " WHERE CO2.CO2_CODEDT = '"  + cPar1
	cQuery += "'  AND CO2.CO2_NUMPRO = '"  + cPar2

	if nIgnoraItem == 0
		cQuery += "' AND (CO2.CO2_ESTORN = '1' )  "
	else
		cQuery += "' AND (CO2.CO2_ESTORN = '1' or CO2.CO2_ESTORN = '2' )  "
	EndIf

	cQuery += " AND " + RetSQLCond("CO2")
	cQuery 	:= ChangeQuery(cQuery)


	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB_CO2",.T.,.T.)
	dbSelectArea("TRB_CO2")


	if (TRB_CO2->(!Eof()))

		lRet := .T.
		if nIgnoraItem == 0
			MsgInfo("Edital foi submetido ao processo de Estorno. Para 'Cancelar' será necessário apontar todos os Participantes envolvidos na próxima operação de Estorno.","Estorno")
		EndIf
	End


	TRB_CO2->(dbCloseArea())

	RestArea(aArea)

Return (lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} NaoMarkNoEstorno
Indica se marca ou não estorno.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@param cPar1, Caractere, Parâmetro 1.
@param cPar2, Caractere, Parâmetro 2.
@param cPar3, Caractere, Parâmetro 3.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Indica se marca ou não estorno.

/*/
/*/================================================================================================================================/*/

Static Function  NaoMarkNoEstorno (cPar1, cPar2, cPar3)
	Local lRet := .F.
	Local cQuery
	Local aArea		:= GetArea()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cQuery := " SELECT CO2.* FROM " + RetSqlName('CO2')  + " CO2 "
	cQuery += " WHERE CO2.CO2_CODEDT = '"  + cPar1
	cQuery += "'  AND CO2.CO2_NUMPRO = '"  + cPar2
	cQuery += "'  AND CO2.CO2_ITEM = '"  + cPar3
	cQuery += "' AND CO2.CO2_ESTORN = '1'   "
	cQuery += " AND " + RetSQLCond("CO2")
	cQuery 	:= ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB_CO2",.T.,.T.)
	dbSelectArea("TRB_CO2")

	if (TRB_CO2->(!Eof()))
		lRet := .T.
	End

	TRB_CO2->(dbCloseArea())

	RestArea(aArea)

Return (lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} MostraProd
0 edital que nao passou por estorno
1 fornecedor do respectivo item nao apontado p/estorno
2 fornecedor do respectivo item apontado p/estorno.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorno da Função.

/*/
/*/================================================================================================================================/*/
Static Function  MostraProd ()
	Local lRet := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Select("CO2")

	if CO2->CO2_ESTORN != "1"
		lRet := .T.
	EndIf

Return (lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} MostraFornec
Fornec estornado deixa de ser exibidos em um novo Andamento (obs:mas se usuario criou novo item,apos o estorno,
este pode sim ter o fornec cancelado vinculado a este novo item.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorno da Função.

/*/
/*/================================================================================================================================/*/

Static Function  MostraFornec ()

	Local lRet := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Select("CO3")

	if CO3->CO3_XSTATU != "1"//fornec cancelado no momento do estorno
		lRet := .T.
	EndIf

Return (lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} FiltroSql
Nao lista fornecedores cancelados.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com filtro SQL.

/*/
/*/================================================================================================================================/*/

Static Function  FiltroSql ()
	Local aRet := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Aadd(aRet," ,CO2.CO2_SLDEST SLDEST ")
	Aadd(aRet," AND CO3.CO3_XSTATU <> '1' AND CO2.CO2_ESTORN <> '1' ")


	//Evita Itens de Edital que não foram estornados
	//Evita fornecedors que foram cancelados
Return (aRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} PgSaldo
Apos o estorno, re-abre o Edital com o saldo restante.

@type function
@author Oswaldo Leite
@since 15/01/12
@version P12.1.23

@param cPar1, Caractere, Parâmetro 1.
@param cPar2, Caractere, Parâmetro 2.
@param cPar3, Caractere, Parâmetro 3.

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Saldo Estorno.

/*/
/*/================================================================================================================================/*/

Static Function  PgSaldo (cPar1, cPar2, cPar3 )
	Local nRet := 0
	Local cQuery
	Local aArea		:= GetArea()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cQuery := " SELECT CO2.CO2_SLDEST FROM " + RetSqlName('CO2')  + " CO2 "
	cQuery += " WHERE CO2.CO2_CODEDT = '"  + cPar1
	cQuery += "'  AND CO2.CO2_NUMPRO = '"  + cPar2
	cQuery += "'  AND CO2.CO2_CODPRO = '"  + cPar3 + "' "
	cQuery += " AND " + RetSQLCond("CO2")
	cQuery 	:= ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCO2",.T.,.T.)
	dbSelectArea("TRBCO2")

	if (TRBCO2->(!Eof()))
		nRet := TRBCO2->(CO2_SLDEST)
	End

	TRBCO2->(dbCloseArea())

	RestArea(aArea)
Return (nRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SaldoCO2
Apos o estorno, re-abre o Edital ocm o saldo restante.

@type function
@author Oswaldo Leite
@since 15/01/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Saldo Estorno.

/*/
/*/================================================================================================================================/*/

Static Function  SaldoCO2 ()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Select("CO2")

return (CO2->CO2_SLDEST)

