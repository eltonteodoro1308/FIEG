#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#include "protheus.ch"
#include "tbiconn.ch"

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

User Function MyCNTA120()

	Local aCabec := {}
	Local aItem  := {}
	Local cDoc   := ""
	Local cArqTrb:= ""
	Local cContra := ""
	Local cRevisa := ""
	Local dData    := date()//Data Atual
	Local dDataI   := dData-0//Data de inicio

	Private lMsHelpAuto := .T.
	PRIVATE lMsErroAuto := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Abertura do ambiente                                         |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	ConOut(Repl("-",80))
	ConOut(PadC("Rotina Automática para a Medição do Contrato de Compras e Vendas",80))

	//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "GCT"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Verificacao do ambiente para teste                           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("CN9")
	dbgoto(Recno())
	cContra := CN9->CN9_NUMERO
	cRevisa := CN9->CN9_REVISA

	ConOut("Inicio: "+Time())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Teste de Inclusao                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("CN9")
	dbSetOrder(1)

	If !dbSeek(xFilial("CN9")+cContra+cRevisa)

		ConOut("Cadastrar contrato: "+cContra)

	EndIf

	aCabec := {}
	aItens := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra parcelas de contratos automaticos ³
	//³ pendentes para a data atual              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cArqTrb	:= CriaTrab( nil, .F. )

	cQuery := "SELECT CNF.CNF_COMPET,CNF.CNF_CONTRA,CNF.CNF_REVISA,CNA.CNA_NUMERO,CNF.CNF_PARCEL,CN9.CN9_FILIAL FROM " + RetSQLName("CNF") + " CNF, " + RetSQLName("CNA") + " CNA, "+ RetSQLName("CN9") +" CN9 WHERE "
	cQuery += "CNF.CNF_FILIAL = '"+ xFilial("CNF") +"' AND "
	cQuery += "CNA.CNA_FILIAL = '"+ xFilial("CNA") +"' AND "
	cQuery += "CN9.CN9_FILIAL = '"+ xFilial("CN9") +"' AND "
	cQuery += "CN9.CN9_NUMERO = '"+cContra+"' AND "
	cQuery += "CN9.CN9_REVISA = '"+cRevisa+"' AND "
	cQuery += "CNF.CNF_NUMERO = CNA.CNA_CRONOG AND "
	cQuery += "CNF.CNF_CONTRA = CNA.CNA_CONTRA AND "
	cQuery += "CNF.CNF_REVISA = CNA.CNA_REVISA AND "
	cQuery += "CNF.CNF_CONTRA = CN9.CN9_NUMERO AND "
	cQuery += "CNF.CNF_REVISA = CN9.CN9_REVISA AND "
	cQuery += "CN9.CN9_SITUAC =  '05' AND "
	cQuery += "CNF.CNF_PRUMED >= '"+ DTOS(dDataI) +"' AND "
	cQuery += "CNF.CNF_PRUMED <= '"+ DTOS(dData) +"' AND "
	cQuery += "CNF.CNF_SALDO  > 0 AND "
	cQuery += "CNA.CNA_SALDO  > 0 AND "
	cQuery += "CNF.D_E_L_E_T_ = ' ' AND "
	cQuery += "CNA.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb, .T., .T. )

	If (cArqTrb)->(Eof())

		ConOut("Nao e possivel medir esse contrato! "+cContra)

	EndIf

	While !(cArqTrb)->(Eof())

		cDoc := CriaVar("CND_NUMMED")

		aAdd(aCabec,{"CND_CONTRA",(cArqTrb)->CNF_CONTRA,NIL})
		aAdd(aCabec,{"CND_REVISA",(cArqTrb)->CNF_REVISA,NIL})
		aAdd(aCabec,{"CND_COMPET",(cArqTrb)->CNF_COMPET,NIL})
		aAdd(aCabec,{"CND_NUMERO",(cArqTrb)->CNA_NUMERO,NIL})
		aAdd(aCabec,{"CND_NUMMED",cDoc,NIL})

		If !Empty(CND->( FieldPos( "CND_PARCEL" ) ))

			aAdd(aCabec,{"CND_PARCEL",(cArqTrb)->CNF_PARCEL,NIL})

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa rotina automatica para gerar as medicoes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		CNTA120(aCabec,aItem,3,.F.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa rotina automatica para encerrar as medicoes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		CNTA120(aCabEC,aItem,6,.F.)

		If !lMsErroAuto

			ConOut("Incluido com sucesso! "+cDoc)

		Else

			ConOut("Erro na inclusao!")

		EndIf

		(cArqTrb)->(dbSkip())

	EndDo

	(cArqTrb)->(dbCloseArea())

	//RESET ENVIRONMENT

Return(.T.)