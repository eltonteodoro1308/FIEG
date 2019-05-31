#Include "Protheus.ch"
#Include "topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120GSC
Ponto de entrada para salvar informações na SC7.

@type function
@author Bruna Paola
@since 30/01/2012
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.
@history 31/05/2019, elton.alves@TOTVS.com.br, Adiconada uma função que popula o campo C7_XESPEC e CNE_XESPEC com o conteúdo do campo CNB_XESPEC correspondenetes.

/*/
/*/================================================================================================================================/*/

User Function CN120GSC()

	Local aXAreas	:= {}
	Local lXRPCont	:= SuperGetMv("SI_XRPCONT",.F.,.T.)
	Local cXFilCont	:= ""
	Local cXCont	:= ""
	Local cXContRev	:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	/*\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\||
	||Desc.     |  lXRPCont - Customização de Restos a Pagar - Contratos	    ||
	||          |  Autor: Daniel Flavio                                         ||
	||          |  Data: 30/11/2018                                             ||
	||\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\*/
	If lXRPCont

		aXAreas := SaveArea1({"SC7","CND","CN9"})

		// Seleciona área de trabalho
		dbSelectArea("CN9")

		TRBSC7->(DbGoTop())

		// Preenche campos especificos do SIGAGCT
		While !TRBSC7->(Eof())

			SC7->(MsGoTo(TRBSC7->RECNO))

			cXFilCont	:= CN9->CN9_FILIAL
			cXCont		:= SC7->C7_CONTRA
			cXContRev	:= SC7->C7_CONTREV

			// Verifico se o contrato está setado como resto a pagar
			If !Empty(cXCont+cXContRev) .AND. U_fXResto99("IS_RP",cXFilCont,cXCont,cXContRev)

				// Verifica se grava as informações de Restos a Pagar no Pedido de Compras
				If !Empty(CND->CND_XRESTP)
					RecLock("SC7",.F.)
					SC7->C7_XRESTPG := Iif((U_fXResto99("CONTABILIZADO",cXFilCont,cXCont,cXContRev)),"3","1")
					SC7->(msUnlock())
				EndIf

			EndIf

			TRBSC7->(dbSkip())
		EndDo

		RestArea1(aXAreas)

	EndIf

	SetEspec()

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} SetEspec
Função que popula o campo C7_XESPEC e CNE_XESPEC com o conteúdo do campo CNB_XESPEC correspondenetes.

@type function
@author Bruna Paola
@since 31/05/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@history 31/05/2019, elton.alves@TOTVS.com.br, Função que popula o campo C7_XESPEC e CNE_XESPEC com o conteúdo do campo CNB_XESPEC correspondenetes.

/*/
/*/================================================================================================================================/*/
Static Function SetEspec()

	Local cAlias   := GetNextAlias()
	Local aArea    := GetArea()
	Local aAreaCNE := CNE->( GetArea() )
	Local aAreaSC7 := SC7->( GetArea() )
	Local aAreaCNB := CNB->( GetArea() )
	Local aRecnos  := {}
	Local nX       := 0
	Local cPedido  := SC7->C7_NUM

	// Cria Alias com os RECNO´s correspondentes nas tabelas
	//CNB (Itens da planilha)
	//CNE (Itens da Medição)
	//SC7 (Itens do Pedido de Compras)
	BeginSql Alias cAlias

		SELECT
		CNE.R_E_C_N_O_ CNERECNO,
		SC7.R_E_C_N_O_ SC7RECNO,
		CNB.R_E_C_N_O_ CNBRECNO

		FROM %Table:CNE% CNE

		INNER JOIN %Table:SC7% SC7
		ON  CNE.CNE_FILIAL = SC7.C7_FILIAL
		AND CNE.CNE_CONTRA = SC7.C7_CONTRA
		AND CNE.CNE_REVISA = SC7.C7_CONTREV
		AND CNE.CNE_NUMERO = SC7.C7_PLANILH
		AND CNE.CNE_NUMMED = SC7.C7_MEDICAO
		AND CNE.CNE_ITEM   = SC7.C7_ITEMED

		INNER JOIN %Table:CNB% CNB
		ON  SC7.C7_FILIAL  = CNB.CNB_FILIAL
		AND SC7.C7_CONTRA  = CNB.CNB_CONTRA
		AND SC7.C7_CONTREV = CNB.CNB_REVISA
		AND SC7.C7_PLANILH = CNB.CNB_NUMERO
		AND SC7.C7_ITEMED  = CNB.CNB_ITEM

		WHERE SC7.C7_FILIAL = %xFilial:SC7%
		AND SC7.C7_NUM = %Exp:cPedido%
		AND SC7.%NotDel%
		AND CNE.%NotDel%
		AND CNB.%NotDel%

	EndSql

	// Posiciona no primeiro registro da tabela temporária
	( cAlias )->( DbGoTop() )

	// Percorre a Tabela e popula array com os recno´s correspondentes de cada tabela
	Do While ( cAlias )->( ! Eof() )

		aAdd( aRecnos, ( cAlias )->( { CNBRECNO, CNERECNO, SC7RECNO } ) )

		( cAlias )->( DbSkip() )

	End Do

	// Fecha tabela temporária
	( cAlias )->( DbCloseArea() )

	// Percorre o array com os recno´s e popula os campos
	// C7_XESPEC e CNE_XESPEC com o conteúdo do campo CNB_XESPEC correspondenetes
	For nX := 1 To Len( aRecnos )

		// Posiciona no registro da tabela CNB
		CNB->( DbGoTo( aRecnos[ nX, 1 ] ) )

		// Verifica se posicionou no registro da tabela CNB
		If CNB->( Recno() == aRecnos[ nX, 1 ])

			// Posiciona no registro da tabela CNE
			CNE->( DbGoTo( aRecnos[ nX, 2 ] ) )

			// Verifica se posicionou no registro da tabela CNE
			If CNE->( Recno()) == aRecnos[ nX, 2 ]

				// Popula o campo CNE_XESPEC com o conteúdo do campo CNB_XESPEC
				RecLock( 'CNE', .F. )

				CNE->CNE_XESPEC := CNB->CNB_XESPEC

				CNE->( MsUnlock() )

			End If

			// Posiciona no registro da tabela SC7
			SC7->( DbGoTo( aRecnos[ nX, 3 ] ) )

			// Verifica se posicionou no registro da tabela SC7
			If SC7->( Recno()) == aRecnos[ nX, 3 ]

				// Popula o campo CNE_XESPEC com o conteúdo do campo CNB_XESPEC
				RecLock( 'SC7', .F. )

				SC7->C7_XESPEC := CNB->CNB_XESPEC

				CNE->( MsUnlock() )

			End If

		End If

	Next nX

	// Restaura as Áreas
	CNE->( RestArea( aAreaCNE ) )
	SC7->( RestArea( aAreaSC7 ) )
	CNB->( RestArea( aAreaCNB ) )
	RestArea( aArea )

Return