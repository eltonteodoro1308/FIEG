#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

User Function TstMed()

	Local aCabec     := {}
	Local aItens     := {{}}
	Local oCnta121Md := Nil
	Local oCNDMaster := Nil
	Local oCXNDetail := Nil
	Local oCNEDetail := Nil
	Local nX         := 0
	Local aErro      := Nil

	If RpcSetEnv( '01', '01GO0001', 'compras', 'compras' )

		MakeArray( @aCabec, @aItens )

		oCnta121Md := FwLoadModel( 'CNTA121' )

		oCnta121Md:SetOperation( 6/*MODEL_OPERATION_INSERT*/ )

		oCnta121Md:Activate()

		oCNDMaster  := oCnta121Md:GetModel( 'CNDMASTER' )
		oCXNDetail  := oCnta121Md:GetModel( 'CXNDETAIL' )
		oCNEDetail  := oCnta121Md:GetModel( 'CNEDETAIL' )

		oCNDMaster:LoadValue( 'CND_CONTRA', aCabec[ aScan( aCabec, { | X | AllTrim( X[ 1 ] ) == 'CND_CONTRA'} ), 2 ] )
		oCNDMaster:LoadValue( 'CND_REVISA', aCabec[ aScan( aCabec, { | X | AllTrim( X[ 1 ] ) == 'CND_REVISA'} ), 2 ] )
		oCNDMaster:LoadValue( 'CND_COMPET', aCabec[ aScan( aCabec, { | X | AllTrim( X[ 1 ] ) == 'CND_COMPET'} ), 2 ] )
		oCNDMaster:LoadValue( 'CND_NUMERO', aCabec[ aScan( aCabec, { | X | AllTrim( X[ 1 ] ) == 'CND_NUMERO'} ), 2 ] )
		oCNDMaster:LoadValue( 'CND_NUMMED', aCabec[ aScan( aCabec, { | X | AllTrim( X[ 1 ] ) == 'CND_NUMMED'} ), 2 ] )
		oCNDMaster:LoadValue( 'CND_PARCEL', aCabec[ aScan( aCabec, { | X | AllTrim( X[ 1 ] ) == 'CND_PARCEL'} ), 2 ] )
		oCNDMaster:LoadValue( 'CND_OBS'   , aCabec[ aScan( aCabec, { | X | AllTrim( X[ 1 ] ) == 'CND_OBS'   } ), 2 ] )

		oCXNDetail:LoadValue( 'CXN_CHECK' , .T. )

		For nX := 1 To Len( aItens )

			oCNEDetail:LoadValue( 'CNE_ITEM'  , aItens[ nX, aScan( aItens[ nX ], { | X | AllTrim( X[ 1 ] ) == 'CNE_ITEM'  } ), 2 ] )
			oCNEDetail:LoadValue( 'CNE_PRODUT', aItens[ nX, aScan( aItens[ nX ], { | X | AllTrim( X[ 1 ] ) == 'CNE_PRODUT'} ), 2 ] )
			oCNEDetail:LoadValue( 'CNE_QUANT' , aItens[ nX, aScan( aItens[ nX ], { | X | AllTrim( X[ 1 ] ) == 'CNE_QUANT' } ), 2 ] )
			oCNEDetail:LoadValue( 'CNE_VLUNIT', aItens[ nX, aScan( aItens[ nX ], { | X | AllTrim( X[ 1 ] ) == 'CNE_VLUNIT'} ), 2 ] )

			If nX < Len( aItens )

				oCNEDetail:AddLine()

			End If

		Next nX

		If FWFormCommit( oCnta121Md,,,, {||.T.},, {||.T.})

			ApMsgInfo( 'Medição Incluída' )

		Else

			aErro := oCnta121Md:GetErrorMessage()

			AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
			AutoGrLog( "Id do campo de origem: "     + ' [' + AllToChar( aErro[2] ) + ']' )
			AutoGrLog( "Id do formulário de erro: "  + ' [' + AllToChar( aErro[3] ) + ']' )
			AutoGrLog( "Id do campo de erro: "       + ' [' + AllToChar( aErro[4] ) + ']' )
			AutoGrLog( "Id do erro: "                + ' [' + AllToChar( aErro[5] ) + ']' )
			AutoGrLog( "Mensagem do erro: "          + ' [' + AllToChar( aErro[6] ) + ']' )
			AutoGrLog( "Mensagem da solução: "       + ' [' + AllToChar( aErro[7] ) + ']' )
			AutoGrLog( "Valor atribuído: "           + ' [' + AllToChar( aErro[8] ) + ']' )
			AutoGrLog( "Valor anterior: "            + ' [' + AllToChar( aErro[9] ) + ']' )

			MostraErro()

		End If

		oCnta121Md:DeActivate()

		RpcClearEnv()

	End If

Return

Static Function MakeArray( aCabec, aItens )

	aAdd( aCabec, { 'CND_CONTRA', '000000000000177'                                                                        , Nil } )
	aAdd( aCabec, { 'CND_REVISA', '   '                                                                                    , Nil } )
	aAdd( aCabec, { 'CND_COMPET', '04/2019'                                                                                , Nil } )
	aAdd( aCabec, { 'CND_NUMERO', '000001'                                                                                 , Nil } )
	aAdd( aCabec, { 'CND_NUMMED', CN130NumMd()                                                                             , Nil } )
	aAdd( aCabec, { 'CND_PARCEL', '1'                                                                                      , Nil } )
	aAdd( aCabec, { 'CND_OBS'   , 'Medição gerada automaticamente a partir da liberação da Solicitação de Compras 190050.' , Nil } )

	aAdd( aItens[1], { 'CNE_ITEM'  , '001'     , Nil  } )
	aAdd( aItens[1], { 'CNE_PRODUT', '00000001', Nil  } )
	aAdd( aItens[1], { 'CNE_QUANT' , 100       , Nil  } )
	aAdd( aItens[1], { 'CNE_VLUNIT', 1000      , Nil  } )
	aAdd( aItens[1], { 'LINPOS'    , 'CNE_ITEM', '001'} )

Return

User Function TstEmpty()

	Local lRet := VAZIO().OR.(EXISTCPO("SX5","ZY"+M->E2_PREFIXO).AND.If(If(Type('lF050Auto')#'U',lF050Auto,.T.),.T.,!"TTX"$M->E2_PREFIXO))

	//Alert(Type('uVar'))
	//VAZIO().OR.(EXISTCPO("SX5","ZY"+M->E2_PREFIXO).AND.IIF(lF050Auto,.T.,!"TTX"$M->E2_PREFIXO))321321

Return lRet