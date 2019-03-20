#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SF2460I
Função para gravacao das entidades no Financeiro e tambem nos itens da Nota Fiscal.

@type function
@author Thiago Rasmussen
@since
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SF2460I()

	Local _aArea	:= GetArea()
	Local _aAreaD2	:= SD2->(GetArea())
	Local _aAreaC6	:= SC6->(GetArea())
	Local _aAreaE1	:= SE1->(GetArea())
	Local _cConta 	:= ""
	Local _cCusto	:= ""
	Local _cItemCC	:= ""
	Local _cCLVL	:= ""
	Local _cEC05DB	:= ""
	Local _cEC06DB	:= ""
	Local _cEC07DB	:= ""
	Local _cEC08DB	:= ""
	Local _cEC09DB	:= ""
	Local _lExist	:= .t.
	Local _lPrim	:= .t.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SC6->(DbSetOrder(1))
	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	SE1->(DbSetOrder(2))
	// E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SD2->(DbSetOrder(3))
	// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	SD2->(Dbseek(xfilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

	// Checa se todos os campos existem - desabilitado, agora eh feito campo a campo.
	//_lExist := xfCheck()

	If _lExist
		Do While ! SD2->(Eof()).And. SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_DOC==SF2->F2_DOC .and. SD2->D2_SERIE==SF2->F2_SERIE .and. ;
		SD2->D2_CLIENTE==SF2->F2_CLIENTE .and. SD2->D2_LOJA==SF2->F2_LOJA

			If SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD))
				RecLock("SD2",.F.)
				If SD2->(FieldPos("D2_CONTA")) > 0 .And. SC6->(FieldPos("C6_XCONTA")) > 0
					SD2->D2_CONTA	:= SC6->C6_XCONTA
				EndIf
				If SD2->(FieldPos("D2_CCUSTO")) > 0 .And. SC6->(FieldPos("C6_XCC")) > 0
					SD2->D2_CCUSTO	:= SC6->C6_XCC
				EndIf
				If SD2->(FieldPos("D2_ITEMCC")) > 0 .And. SC6->(FieldPos("C6_XITEMC")) > 0
					SD2->D2_ITEMCC	:= SC6->C6_XITEMC
				EndIf
				If SD2->(FieldPos("D2_CLVL")) > 0 .And. SC6->(FieldPos("C6_XCLVL")) > 0
					SD2->D2_CLVL	:= SC6->C6_XCLVL
				EndIf
				If SD2->(FieldPos("D2_EC05DB")) > 0 .And. SC6->(FieldPos("C6_XEC05D")) > 0
					SD2->D2_EC05DB	:= SC6->C6_XEC05D
				EndIf
				If SD2->(FieldPos("D2_EC06DB")) > 0 .And. SC6->(FieldPos("C6_XEC06D")) > 0
					SD2->D2_EC06DB	:= SC6->C6_XEC06D
				EndIf
				If SD2->(FieldPos("D2_EC07DB")) > 0 .And. SC6->(FieldPos("C6_XEC07D")) > 0
					SD2->D2_EC07DB	:= SC6->C6_XEC07D
				EndIf
				If SD2->(FieldPos("D2_EC08DB")) > 0 .And. SC6->(FieldPos("C6_XEC08D")) > 0
					SD2->D2_EC08DB	:= SC6->C6_XEC08D
				EndIf
				If SD2->(FieldPos("D2_EC09DB")) > 0 .And. SC6->(FieldPos("C6_XEC09D")) > 0
					SD2->D2_EC09DB	:= SC6->C6_XEC09D
				EndIf

				SD2->(MsUnlock())
				// Variaveis com as informacoes das entidades para serem gravadas nas duplicatas.
				If _lPrim
					If SC6->(FieldPos("C6_XCONTA")) > 0
						_cConta := SC6->C6_XCONTA
					EndIf
					If SC6->(FieldPos("C6_XCC")) > 0
						_cCusto	:= SC6->C6_XCC
					EndIf
					If SC6->(FieldPos("C6_XITEMC")) > 0
						_cItemCC:= SC6->C6_XITEMC
					EndIf
					If SC6->(FieldPos("C6_XCLVL")) > 0
						_cCLVL	:= SC6->C6_XCLVL
					EndIf
					If SC6->(FieldPos("C6_XEC05D")) > 0
						_cEC05DB:= SC6->C6_XEC05D
					EndIf
					If SC6->(FieldPos("C6_XEC06D")) > 0
						_cEC06DB:= SC6->C6_XEC06D
					EndIf
					If SC6->(FieldPos("C6_XEC07D")) > 0
						_cEC07DB:= SC6->C6_XEC07D
					EndIf
					If SC6->(FieldPos("C6_XEC08D")) > 0
						_cEC08DB:= SC6->C6_XEC08D
					EndIf
					If SC6->(FieldPos("C6_XEC09D")) > 0
						_cEC09DB:= SC6->C6_XEC09D
					EndIf
					_lPrim := .f.
				EndIf

			EndIf

			SD2->(DBSKIP())

		EndDo

		SE1->(DbSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DUPL))

		Do While ! SE1->(Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. ;
		SE1->E1_CLIENTE == SF2->F2_CLIENTE .And. SE1->E1_LOJA == SF2->F2_LOJA .And. SF2->F2_SERIE == SE1->E1_PREFIXO .And. ;
		SF2->F2_DUPL == SE1->E1_NUM

			RecLock("SE1",.f.)
			If SE1->(FieldPos("E1_CREDIT")) > 0
				SE1->E1_CREDIT	:= _cConta
			EndIf
			If SE1->(FieldPos("E1_CCC")) > 0
				SE1->E1_CCC		:= _cCusto
			EndIf
			If SE1->(FieldPos("E1_ITEMC")) > 0
				SE1->E1_ITEMC	:= _cItemCC
			EndIf
			If SE1->(FieldPos("E1_CLVLCR")) > 0
				SE1->E1_CLVLCR	:= _cCLVL
			EndIf
			If SE1->(FieldPos("E1_EC05CR")) > 0
				SE1->E1_EC05CR	:= _cEC05DB
			EndIf
			If SE1->(FieldPos("E1_EC06CR")) > 0
				SE1->E1_EC06CR	:= _cEC06DB
			EndIf
			If SE1->(FieldPos("E1_EC07CR")) > 0
				SE1->E1_EC07CR	:= _cEC07DB
			EndIf
			If SE1->(FieldPos("E1_EC08CR")) > 0
				SE1->E1_EC08CR	:= _cEC08DB
			EndIf
			If SE1->(FieldPos("E1_EC09CR")) > 0
				SE1->E1_EC09CR	:= _cEC09DB
			EndIf
			SE1->(MsUnLock())

			SE1->(DbSkip())
		EndDo
	EndIf

	RestArea(_aAreaD2)
	RestArea(_aAreaC6)
	RestArea(_aAreaE1)
	RestArea(_aArea)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xfCheck
Função para checagem se todos os campos existem para gravacao.

@type function
@author Thiago Rasmussen
@since
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando se todos os campos existem para gravacao.s

/*/
/*/================================================================================================================================/*/

Static Function xfCheck()

	Local aCampos	:= {}
	Local _lRet		:= .t.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aAdd(aCampos,{"SE1","E1_CREDIT"})
	aAdd(aCampos,{"SE1","E1_CCC"})
	aAdd(aCampos,{"SE1","E1_ITEMC"})
	aAdd(aCampos,{"SE1","E1_CLVLCR"})
	aAdd(aCampos,{"SE1","E1_EC05CR"})
	aAdd(aCampos,{"SE1","E1_EC06CR"})
	aAdd(aCampos,{"SE1","E1_EC07CR"})
	aAdd(aCampos,{"SE1","E1_EC08CR"})
	aAdd(aCampos,{"SE1","E1_EC09CR"})

	aAdd(aCampos,{"SC6","C6_XCONTA"})
	aAdd(aCampos,{"SC6","C6_XCC"})
	aAdd(aCampos,{"SC6","C6_XITEMC"})
	aAdd(aCampos,{"SC6","C6_XCLVL"})
	aAdd(aCampos,{"SC6","C6_XEC05D"})
	aAdd(aCampos,{"SC6","C6_XEC06D"})
	aAdd(aCampos,{"SC6","C6_XEC07D"})
	aAdd(aCampos,{"SC6","C6_XEC08D"})
	aAdd(aCampos,{"SC6","C6_XEC09D"})

	aAdd(aCampos,{"SD2","D2_CONTA"})
	aAdd(aCampos,{"SD2","D2_CCUSTO"})
	aAdd(aCampos,{"SD2","D2_ITEMCC"})
	aAdd(aCampos,{"SD2","D2_CLVL"})
	aAdd(aCampos,{"SD2","D2_EC05DB"})
	aAdd(aCampos,{"SD2","D2_EC06DB"})
	aAdd(aCampos,{"SD2","D2_EC07DB"})
	aAdd(aCampos,{"SD2","D2_EC08DB"})
	aAdd(aCampos,{"SD2","D2_EC09DB"})

	For _nY := 1 To Len(aCampos)
		_cAlias := aCampos[_nY,1]
		_cCampo := aCampos[_nY,2]
		// Caso campo nao exista retorna .f.
		If (_cAlias)->(FieldPos(Alltrim(_cCampo))) == 0
			_lRet := .f.
		EndIf
	Next _nY

Return(_lRet)
