#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA12
Amarracao Fornecedor x Tipo de Documentos.

@type function
@author Leonardo Soncin
@since 12/09/2011
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

User Function SICOMA12( cAlias, nReg, nOpc, xVar, nOper )

	Local aArea        := GetArea()
	Local aPosObj      := {}
	Local aObjects     := {}
	Local aSize        := MsAdvSize( .F. )
	Local aGet         := {}
	Local aTravas      := {}
	Local aEntidade    := {}
	Local aRecSZ6      := {}
	Local aChave       := {}

	Local cCodigo      := SA2->A2_COD+"-"+SA2->A2_LOJA
	Local cNome  	   := SA2->A2_NOME

	Local lGravou      := .T.
	Local lTravas      := .T.
	Local lAchou       := .F.

	Local nCntFor      := 0
	Local nOpcA        := 0
	Local nScan        := 0
	Local nPosDsc	   := 0
	Local nPosTip	   := 0


	Local aNoFields := {"Z6_FORNECE","Z6_LOJA"}							// Campos que nao serao apresentados no aCols

	Local oDlg
	Local oGetD
	Local oGet
	Local oGet2

	Local	cSeek     := ""
	Local	cWhile    := ""

	Local bCond     := {|| .T.}												// Se bCond .T. executa bAction1, senao executa bAction2
	Local bAction1  := {|| FtVerSZ6(@aRecSZ6,@aTravas,@lTravas) }			// Retornar .T. para considerar o registro e .F. para desconsiderar
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

		dbSelectArea("SZ6")
		cSeek  := xFilial( "SZ6" ) + SA2->A2_COD + SA2->A2_LOJA
		cWhile := "SZ6->Z6_FILIAL + SZ6->Z6_FORNECE + SZ6->Z6_LOJA"
		FillGetDados(nOpc,"SZ6",1,cSeek,{|| &cWhile },{{bCond,bAction1,bAction2}},aNoFields,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*Inclui*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/)

		nPosDsc := aScan(aHeader,{|x| AllTrim(x[2])=='Z6_DESC'})
		nPosTip := aScan(aHeader,{|x| AllTrim(x[2])=='Z6_TIPDOC'})

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

			@ 019,005 SAY OemToAnsi("Fornecedor") SIZE 040,009 OF oDlg PIXEL
			@ 018,050 GET oGet  VAR cCodigo SIZE 120,009 OF oDlg PIXEL WHEN .F.

			@ 032,005 SAY OemToAnsi("Descrição") SIZE 040,009 OF oDlg PIXEL
			@ 031,050 GET oGet2 VAR cNome SIZE 120,009 OF oDlg PIXEL WHEN .F.

			oGetd:=MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpc,"AlwaysTrue","AlwaysTrue",,.T.,NIL,NIL,NIL,500)
			//oGetd:=MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], nOpc,"FtContLOK","AlwaysTrue",,.T.,NIL,NIL,NIL,500)
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(oGetd:TudoOk(),oDlg:End(),nOpcA:=0)},{||oDlg:End()})

			If ( nOpcA == 1 )
				Begin Transaction
					xSZ6GRV(aRecSZ6 )
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
			dbGoto(aTravas[nCntFor][2])
			MsUnLock()
		Next nCntFor

	Else
		xSZ6GRV( , .T. )
	EndIf

	RestArea( aArea )

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xSZ6GRV
Descrição detalhada da função.

@type function
@author Thiago Rasmussen
@since 12/09/2011
@version P12.1.23

@param aRecSZ6, Array, Lista de Recno´s de registros da tabela SZ6.
@param lExclui, lExclui, Indica se efetua a exclusão dos registros.

@obs Projeto ELO

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xSZ6GRV(aRecSZ6, lExclui )

	Local cSeek  := ""
	Local lGravou   := .F.

	Local nLoop     := 0
	Local nLoop2    := 0

	DEFAULT lExclui := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If lExclui

		cSeek := xFilial( "SZ6" ) + SA2->A2_COD+SA2->A2_LOJA
		SZ6->( dbSetOrder( 1 ) )
		If SZ6->( MsSeek( cSeek ) )
			lGravou := .T.
			While !SZ6->( Eof() ) .And. cSeek == SZ6->Z6_FILIAL + SZ6->Z6_FORNECE + ;
			SZ6->Z68_LOJA
				RecLock( "SZ6", .F. )
				SZ6->( dbDelete() )
				SZ6->( MsUnLock() )
				SZ6->( dbSkip() )
			EndDo
		EndIf
	Else

		For nLoop := 1 To Len( aCols )
			lGravou := .T.
			If GDDeleted( nLoop )
				If nLoop <= Len( aRecSZ6 )
					SZ6->( MsGoto( aRecSZ6[ nLoop ] ) )
					RecLock( "SZ6", .F. )
					SZ6->( dbDelete() )
					SZ6->( MsUnlock() )
				EndIf
			Else
				If nLoop <= Len( aRecSZ6 )
					SZ6->( MsGoto( aRecSZ6[ nLoop ] ) )
					RecLock( "SZ6", .F. )
				Else
					//+------------------------------------------------------------------------+
					//| Inclui e grava os campos chave                                         |
					//+------------------------------------------------------------------------+
					RecLock( "SZ6", .T. )
					SZ6->Z6_FILIAL := xFilial( "SZ6" )
					SZ6->Z6_FORNECE:= SA2->A2_COD
					SZ6->Z6_LOJA   := SA2->A2_LOJA
				EndIf

				//+------------------------------------------------------------------------+
				//| Grava os demais campos                                                 |
				//+------------------------------------------------------------------------+
				For nLoop2 := 1 To Len( aHeader )
					If ( aHeader[nLoop2,10] <> "V" ) .And. !( AllTrim( aHeader[nLoop2,2] ) $ "Z6_FORNECE|Z6_LOJA" )
						SZ6->(FieldPut(FieldPos(aHeader[nLoop2,2]),aCols[nLoop,nLoop2]))
					EndIf
				Next nLoop2

				SZ6->( MsUnlock() )

			EndIf

		Next nLoop

	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FtVerSZ6  ³ Autor ³ Marco Bianchi         ³ Data ³02/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao disparada para validar cada registro da tabela      ³±±
±±³          ³ SZ6, adicionar recno no array aRecSZ6 utilizado na gravacao³±±
±±³          ³ cao da tabela SZ6 e verificar se conseguiu travar SZ6.     ³±±
±±³          ³ Se retornar .T. considera o registro.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array com numero dos registros da tabela SZ6         ³±±
±±³          ³ExpA2: Array coim registros travados do SZ6                 ³±±
±±³          ³ExpL3: .T. se conseguiu travar SZ6                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*/================================================================================================================================/*/
/*/{Protheus.doc} FtVerSZ6
Funcao disparada para validar cada registro da tabela SZ6, adicionar recno no array aRecSZ6
utilizado na gravacao da tabela SZ6 e verificar se conseguiu travar SZ6.
Se retornar .T. considera o registro.

@type function
@author Marco Bianchi
@since 02/01/2007
@version P12.1.23

@param aRecSZ6, Array, Array com numero dos registros da tabela SZ6.
@param aTravas, Array, Array coim registros travados do SZ6.
@param aTravas, Array, .T. se conseguiu travar SZ6.

@obs Projeto ELO

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

Static Function FtVerSZ6(aRecSZ6,aTravas,aTravas)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If ( SoftLock("SZ6" ) )
		AAdd(aTravas,{ Alias() , RecNo() })
		AAdd(aRecSZ6, SZ6->( Recno() ) )
	Else
		lTravas := .F.
	EndIf

Return(.T.)