#Include 'Totvs.Ch'

User Function PopulaSc1()

	Local cStrFile := cGetFile( ,'Selecione o arquivo de estrutura.' )
	Local aStrFile := StrTokArr2( MemoRead( cStrFile ), CRLF, .F. )
	Local aStrSc1  := {}

	Local cTxtFile := cGetFile( ,'Selecione o arquivo de dados.' )
	Local oTxtFile := FWFileReader():New( cTxtFile )

	Local aLinha := Nil

	RpcSetEnv( '01', '01GO0001')

	For nX := 1 To Len( aStrFile )

		aAdd( aStrSc1, StrTokArr2( aStrFile[ nX ], ';', .F. ) )

	Next nX

	oTxtFile:Open()

	Do While oTxtFile:hasLine()

		aLinha := LeDados( oTxtFile:GetLine(), aStrSc1 )

		GravaLinha( aLinha )

	End Do

	oTxtFile:Close()

	RpcClearEnv()

Return

/*----------------------------------------------------------------------*/

Static Function LeDados( cLinha, aStrSc1 )

	Local aRet     := {}
	Local nX       := 0
	Local cNome    := ''
	Local cTipo    := ''
	Local nPosInic := 0
	Local nTamanho := 0
	Local xValor   := Nil
	Local cAux     := ''

	For nX := 1 To Len( aStrSc1 )

		cNome    := AllTrim( aStrSc1[ nX, 1 ] )
		cTipo    := AllTrim( aStrSc1[ nX, 2 ] )
		nPosInic := Val( aStrSc1[ nX, 5 ] )
		nTamanho := Val( aStrSc1[ nX, 3 ] )

		If cTipo # 'M'

			cAux := SubStr( cLinha, nPosInic, nTamanho )

			xValor := TrataTipo( cAux, cTipo )

			aAdd( aRet, { cNome, xValor } )

		End If

	Next nX

Return aRet

/*----------------------------------------------------------------------*/

Static Function TrataTipo( cDado, cTipo )

	Local xRet := Nil

	If cTipo == 'D'

		xRet := sTod( cDado )

	ElseIf cTipo == 'L'

		xRet := cDado == 'T'

	ElseIf cTipo == 'N'

		xRet := Val( cDado )

	Else

		xRet := cDado

	End If

Return xRet

/*----------------------------------------------------------------------*/

Static Function GravaLinha( aLinha )

	Local nX := 0

	DbSelectAre( 'SC1' )

	RecLock( 'SC1', .T. )

	For nX := 1 To Len( aLinha )

		SC1->&( aLinha[ nX, 1 ] ) := aLinha[ nX, 2 ]

	Next nX

	MsUnlock()

Return

/*----------------------------------------------------------------------*/

User Function GetStrSc1()

	Local aStrSC1 := Nil
	Local nX      := 0
	Local cLinha  := ''

	RpcSetEnv( '01', '01GO0001')

	DbSelectArea( 'SC1' )

	aStrSC1 := aClone( SC1->( DBSTRUCT() ) )

	For nX := 1 To Len( aStrSC1 )

		cLinha +=              aStrSc1[ nX, 1 ]   + ';'
		cLinha +=              aStrSc1[ nX, 2 ]   + ';'
		cLinha +=  cValTochar( aStrSc1[ nX, 3 ] ) + ';'
		cLinha +=  cValTochar( aStrSc1[ nX, 4 ] ) + CRLF

	Next nX

	//AutoGrLog( VarInfo( 'aStrSC1', aStrSC1,, .T., .F. ) )

	AutoGrLog( cLinha )

	MostraErro()

	RpcClearEnv()

return
