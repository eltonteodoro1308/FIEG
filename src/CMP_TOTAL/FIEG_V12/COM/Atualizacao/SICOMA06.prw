#Include "Protheus.Ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA06
Rotina de transferencia do mutuo da NFE para Financeiro.

@type function
@author Thiago Rasmussen
@since 10/05/2012
@version P12.1.23

@obs Projeto ELO

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMA06()
	Local _cQuery  := ""
	Local _cArqTRB := CriaTrab(nil,.f.)
	Local _cArea   := GetArea()
	Local _lMutuo  := .f.
	/*
	_cQuery := "SELECT ZW_CODEMP,SUM(D1_TOTAL * (ZW_PERC/100)) VALOR "
	_cQuery += "FROM "+RetSqlName("SD1")+" SD1 INNER JOIN "+RetSqlName("SC7")+" SC7 ON C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC "
	_cQuery += "INNER JOIN "+RetSqlName("SC1")+" SC1 ON C1_NUM = C7_NUMSC AND C1_ITEM = C7_ITEMSC "
	_cQuery += "INNER JOIN "+RetSqlName("SZW")+" SZW ON ZW_NUMSC = C1_NUM AND ZW_ITEMSC = C1_ITEM "
	_cQuery += "WHERE D1_DOC = '"+SF1->F1_DOC+"' AND D1_SERIE = '"+SF1->F1_SERIE+"' AND D1_FORNECE = '"+SF1->F1_FORNECE+"' AND D1_LOJA = '"+SF1->F1_LOJA+"' "
	_cQuery += "AND SD1.D_E_L_E_T_ = ' ' AND SC7.D_E_L_E_T_ = ' ' AND SC1.D_E_L_E_T_ = ' ' AND SZW.D_E_L_E_T_ = ' ' "
	_cQuery += "AND D1_FILIAL = '"+XFilial("SD1")+"' AND C7_FILIAL = '"+XFilial("SC7")+"' AND C1_FILIAL = '"+XFilial("SC1")+"' "
	_cQuery += "AND ZW_FILIAL = '"+XFilial("SZW")+"' AND ZW_CODEMP <> '"+cFilAnt+"' "
	_cQuery += "GROUP BY ZW_CODEMP "
	_cQuery += "ORDER BY 1"
	_cQuery := ChangeQuery(_cQuery)
	*/

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	_cQuery := "select ZW_CODEMP, sum(D1_TOTAL * (ZW_PERC/100)) VALOR "
	_cQuery += " from "+RetSqlName("SD1")+" SD1  "
	_cQuery += "inner join "+RetSqlName("SC7")+" SC7 on SC7.D_E_L_E_T_ = ' ' and C7_FILIAL = '"+xFilial("SC7")+"' and C7_NUM   = D1_PEDIDO and C7_ITEM =  D1_ITEMPC "
	_cQuery += "inner join "+RetSqlName("SC1")+" SC1 on SC1.D_E_L_E_T_ = ' ' and C1_FILIAL = '"+xFilial("SC1")+"' and C1_NUM   = C7_NUMSC  and C1_ITEM =  C7_ITEMSC "
	_cQuery += "inner join "+RetSqlName("SZW")+" SZW on SZW.D_E_L_E_T_ = ' ' and ZW_FILIAL = '"+xFilial("SZW")+"' and ZW_NUMSC = C1_NUM    and ZW_ITEMSC = C1_ITEM "
	_cQuery += "where SD1.D_E_L_E_T_ = ' ' and D1_FILIAL = '"+xFilial("SD1")+"' "
	_cQuery += "  and D1_DOC = '"+SF1->F1_DOC+"' and D1_SERIE = '"+SF1->F1_SERIE+"' and D1_FORNECE = '"+SF1->F1_FORNECE+"' and D1_LOJA = '"+SF1->F1_LOJA+"' "
	_cQuery += "group by ZW_CODEMP "
	_cQuery += "order by ZW_CODEMP "
	_cQuery := ChangeQuery(_cQuery)

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqTRB,.t.,.t.)

	IF (_cArqTRB)->(!Eof())
		_lMutuo := .t.
		_cItem := StrZero(1,TamSX3("ZX_ITEM")[1])
		_cNumRat := U_SIFIN11Num()

		AcessaPerg("FIN050",.F.) // Posiciona grupo de perguntas do contas a pagar

		_nTipoRat := mv_par06 // 1 = Bruto; 2 = Liquido

		Pergunte("MTA103",.F.) // Restaura grupo de perguntas do compras

		_nInss    := SE2->E2_INSS

		SED->(dbSetOrder(1))
		IF SED->(dbSeek(XFilial("SED")+SE2->E2_NATUREZ)) .and. SED->(FieldPos("ED_DEDINSS")) > 0
			IF SED->ED_DEDINSS == "2"  //Nao desconta o INSS do principal
				_nInss := 0
			Endif
		ENDIF

		SA2->(dbSetOrder(1))
		SA2->(dbSeek(XFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)))

		//Controla o Pis Cofins e Csll na baixa
		lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
		!Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
		!Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
		!Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )

		// Controla IRPF na Baixa
		lIRPFBaixa := IIf( ! Empty( SA2->( FieldPos( "A2_CALCIRF" ) ) ), SA2->A2_CALCIRF == "2", .F.) .And. ;
		!Empty( SE2->( FieldPos( "E2_VRETIRF" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETIRF" ) ) ) .And. ;
		!Empty( SE5->( FieldPos( "E5_VRETIRF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETIRF" ) ) )

		lCalcIssBx :=	!Empty( SE5->( FieldPos( "E5_VRETISS" ) ) ) .and. !Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .and. ;
		!Empty( SE2->( FieldPos( "E2_TRETISS" ) ) ) .and. GetNewPar("MV_MRETISS","1") == "2"  //Retencao do ISS pela emissao (1) ou baixa (2)

		_nTotal   := Iif(_nTipoRat == 1,SE2->E2_VALOR+If(lIRPFBaixa,0,SE2->E2_IRRF)+If(!lCalcIssBx,SE2->E2_ISS,0)+_nInss+SE2->(E2_RETENC+E2_SEST)+IIF(lPccBaixa,0,SE2->(E2_PIS+E2_COFINS+E2_CSLL)),SE2->E2_VALOR)

	ENDIF

	While (_cArqTRB)->(!Eof()) .and. _lMutuo
		RecLock("SZX",.T.)
		SZX->ZX_FILIAL  := XFilial("SZX")
		SZX->ZX_RATEIO	:= _cNumRat
		SZX->ZX_ITEM	:= _cItem
		SZX->ZX_CODEMP	:= (_cArqTRB)->ZW_CODEMP
		SZX->ZX_PERC	:= ((_cArqTRB)->VALOR / SF1->F1_VALMERC) * 100
		SZX->ZX_VALOR	:= _nTotal * (SZX->ZX_PERC/100)

		// Atualiza dados de fornecedore e loja
		SZE->(dbSetOrder(2))
		// Atualiza cliente - variavel
		IF SZE->(dbSeek(XFilial("SZE")+(_cArqTRB)->ZW_CODEMP))
			SZX->ZX_CODCLI	:= SZE->ZE_CODCLI
			SZX->ZX_LOJCLI	:= SZE->ZE_LOJCLI
		ENDIF
		// Atualiza fornecedor - fixo
		IF SZE->(dbSeek(XFilial("SZE")+cFilAnt))
			SZX->ZX_CODFOR	:= SZE->ZE_CODFOR
			SZX->ZX_LOJFOR	:= SZE->ZE_LOJFOR
		ENDIF
		SZX->(MsUnlock())

		_cItem := Soma1(_cItem)
		(_cArqTRB)->(dbSkip())
	Enddo

	// Atualiza tabela do financeiro
	IF _lMutuo
		RecLock("SE2",.f.)
		SE2->E2_XMUTUO  := _cNumRat
		SE2->E2_XSTATUS := "1"
		SE2->E2_XORIGEM := "1"
		SE2->(msUnlock())
	ENDIF

	(_cArqTRB)->(dbCloseArea())
	FErase(_cArqTRB+GetDBExtension())
	FErase(_cArqTRB+OrdBagExt())
	RestArea(_cArea)
Return()
