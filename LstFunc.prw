#Include 'Totvs.Ch'

user function LstFunc()

	Local cMascara := 'CNTA120'
	Local aTipo	   := {}
	Local aArquivo := {}
	Local aLinha   := {}
	Local aData    := {}
	Local aHora    := {}
	Local aFuncao  := GetFuncArray(cMascara, @aTipo, @aArquivo, @aLinha, @aData, @aHora)
	Local aRet     := {}
	Local nX       := 0

	For nX := 1 To Len( aFuncao )

		aAdd( aRet, { aFuncao[ nX ], aTipo[ nX ], aArquivo[ nX ], aLinha[ nX ], aData[ nX ] } )

	Next nX

	AutoGrLog( VarInfo( '', aRet,, .F., .F. ) )

	MostraErro()

return aRet