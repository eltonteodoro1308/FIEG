#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA13
Amarracao Edital x Documentos Necessarios.

@type function
@author Thiago Rasmussen
@since 03/11/2011
@version P12.1.23

@param cAlias, Caractere, Alias da Tabela.
@param nReg, Numérico, Recno do registro posicionado.
@param nOpc, Numérico, Numero da opção selecionada.
@param xVar, Indefinido, Compatibilidade.
@param nOper, Numérico, Numero da opção selecionada.

@obs Projeto ELO

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMA13( cAlias, nReg, nOpc, xVar, nOper )

	Local aArea        := GetArea()
	Local aPosObj      := {}
	Local aObjects     := {}
	Local aSize        := MsAdvSize( .F. )
	Local aGet         := {}
	Local aTravas      := {}
	Local aEntidade    := {}
	Local aRecSZI      := {}
	Local aChave       := {}

	Local cCodigo      := CO1->CO1_CODEDT
	Local cProcesso	   := CO1->CO1_NUMPRO

	Local lGravou      := .T.
	Local lTravas      := .T.
	Local lAchou       := .F.

	Local nCntFor      := 0
	Local nOpcA        := 0
	Local nScan        := 0
	Local nPosDsc	   := 0
	Local nPosTip	   := 0


	Local aNoFields := {"ZI_CODEDT","ZI_NUMPRO"}							// Campos que nao serao apresentados no aCols

	Local oDlg
	Local oGetD
	Local oGet
	Local oGet2

	Local	cSeek     := ""
	Local	cWhile    := ""

	Local bCond     := {|| .T.}												// Se bCond .T. executa bAction1, senao executa bAction2
	Local bAction1  := {|| FtVerSZI(@aRecSZI,@aTravas,@lTravas) }			// Retornar .T. para considerar o registro e .F. para desconsiderar
	Local bAction2  := {|| .F. }											// Retornar .T. para considerar o registro e .F. para desconsiderar

	PRIVATE aCols      := {}
	PRIVATE aHeader    := {}

	DEFAULT nOper      := 1

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+------------------------------------------------------------------------+
	//| Posiciona a entidade                                                   |
	//+------------------------------------------------------------------------+

	If nOper <> 3

		dbSelectArea("SZI")
		cSeek  := xFilial( "SZI" ) + CO1->(CO1_CODEDT+CO1_NUMPRO)
		cWhile := "SZI->ZI_FILIAL + SZI->ZI_CODEDT + SZI->ZI_NUMPRO"
		FillGetDados(nOpc,"SZI",1,cSeek,{|| &cWhile },{{bCond,bAction1,bAction2}},aNoFields,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*Inclui*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/)

		nPosDsc := aScan(aHeader,{|x| AllTrim(x[2])=='ZI_DESC'})
		nPosTip := aScan(aHeader,{|x| AllTrim(x[2])=='ZI_TIPDOC'})

		// Trata Descrição
		For nX := 1 to Len(aCols)
			aCols[nX][nPosDsc] := Iif(!Empty(aCols[nX][nPosTip]),Posicione("SZ5",1,XFILIAL("SZ5")+aCols[nX][nPosTip],"Z5_DESC"),"")
		Next nX


		If ( lTravas )

			INCLUI := .T.

			AAdd( aObjects, { 100,  44, .T., .F. } )
			AAdd( aObjects, { 100, 100, .T., .T. } )

			aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 }
			aPosObj := MsObjSize( aInfo, aObjects )

			DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL

			@ 019,005 SAY OemToAnsi("Edital") SIZE 040,009 OF oDlg PIXEL
			@ 018,050 GET oGet  VAR cCodigo SIZE 120,009 OF oDlg PIXEL WHEN .F.

			@ 032,005 SAY OemToAnsi("Processo") SIZE 040,009 OF oDlg PIXEL
			@ 031,050 GET oGet2 VAR cProcesso SIZE 120,009 OF oDlg PIXEL WHEN .F.

			oGetd:=MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpc,"AlwaysTrue","AlwaysTrue",,.T.,NIL,NIL,NIL,500)
			//oGetd:=MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpc,"FtContLOK","AlwaysTrue",,.T.,NIL,NIL,NIL,500)
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(oGetd:TudoOk(),oDlg:End(),nOpcA:=0)},{||oDlg:End()})

			If ( nOpcA == 1 )
				Begin Transaction

					_COMA13Grv(aRecSZI )
					If ( lGravou )
						EvalTrigger()
						If ( __lSx8 )
							ConfirmSx8()
						EndIf
					EndIf
				End Transaction
			EndIf
		EndIf
		If ( __lSx8 )
			RollBackSx8()
		EndIf
		For nCntFor := 1 To Len(aTravas)
			dbSelectArea(aTravas[nCntFor][1])
			(aTravas[nCntFor][1])->(dbGoto(aTravas[nCntFor][2]))
			(aTravas[nCntFor][1])->(MsUnLock())
		Next nCntFor

	Else
		_COMA13Grv( , .T. )
	EndIf


	RestArea( aArea )

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} _COMA13Grv
Gravacao dos dados.

@type function
@author Thiago Rasmussen
@since 11/03/2011
@version P12.1.23

@param aRecSZI, Array, Lista de Recno´s de registros da tabela SZI.
@param lExclui, lExclui, Indica se efetua a exclusão dos registros.

@obs Projeto ELO

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function _COMA13Grv(aRecSZI, lExclui )

	Local cSeek  := ""
	Local lGravou   := .F.

	Local nLoop     := 0
	Local nLoop2    := 0

	DEFAULT lExclui := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If lExclui

		cSeek := xFilial( "SZI" ) + CO1->(CO1_CODEDT+CO1_NUMPRO)
		SZI->( dbSetOrder( 1 ) )
		If SZI->( MsSeek( cSeek ) )
			lGravou := .T.
			While !SZI->( Eof() ) .And. cSeek == SZI->ZI_FILIAL + SZI->(ZI_CODEDT+ZI_NUMPRO)
				RecLock( "SZI", .F. )
				SZI->( dbDelete() )
				SZI->( MsUnLock() )
				SZI->( dbSkip() )
			EndDo
		EndIf
	Else

		For nLoop := 1 To Len( aCols )
			lGravou := .T.
			If GDDeleted( nLoop )
				If nLoop <= Len( aRecSZI )
					SZI->( MsGoto( aRecSZI[ nLoop ] ) )
					RecLock( "SZI", .F. )
					SZI->( dbDelete() )
					SZI->( MsUnlock() )
				EndIf
			Else
				If nLoop <= Len( aRecSZI )
					SZI->( MsGoto( aRecSZI[ nLoop ] ) )
					RecLock( "SZI", .F. )
				Else
					//+------------------------------------------------------------------------+
					//| Inclui e grava os campos chave                                         |
					//+------------------------------------------------------------------------+
					RecLock( "SZI", .T. )
					SZI->ZI_FILIAL := xFilial( "SZI" )
					SZI->ZI_CODEDT := CO1->CO1_CODEDT
					SZI->ZI_NUMPRO := CO1->CO1_NUMPRO
				EndIf

				//+------------------------------------------------------------------------+
				//| Grava os demais campos                                                 |
				//+------------------------------------------------------------------------+
				For nLoop2 := 1 To Len( aHeader )
					If ( aHeader[nLoop2,10] <> "V" ) .And. !( AllTrim( aHeader[nLoop2,2] ) $ "ZI_CODEDT|CO1_NUMPRO" )
						SZI->(FieldPut(FieldPos(aHeader[nLoop2,2]),aCols[nLoop,nLoop2]))
					EndIf
				Next nLoop2

				SZI->( MsUnlock() )

			EndIf

		Next nLoop

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} FtVerSZI
Funcao disparada para validar cada registro da tabela
SZI, adicionar recno no array aRecSZI utilizado na gravacao
da tabela SZI e verificar se conseguiu travar SZI.
Se retornar .T. considera o registro.

@type function
@author Marco Bianchi
@since 02/01/2007
@version P12.1.23

@param aRecSZI, Array, Array com numero dos registros da tabela SZI.
@param aTravas, Array, Array com registros travados do SZI.
@param lTravas, Logical, .T. se conseguiu travar SZI.

@obs Projeto ELO

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

Static Function FtVerSZI(aRecSZI,aTravas,lTravas)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If ( SoftLock("SZI" ) )
		AAdd(aTravas,{ Alias() , RecNo() })
		AAdd(aRecSZI, SZI->( Recno() ) )
	Else
		lTravas := .F.
	EndIf

Return(.T.)
