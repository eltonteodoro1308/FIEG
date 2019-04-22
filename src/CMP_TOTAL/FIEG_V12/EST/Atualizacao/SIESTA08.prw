#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIESTA08
MBrowse de cadastro de compartilhamento.

@type function
@author Bruna Paola
@since 01/10/2012
@version P12.1.23

@obs Projeto ELO

@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIESTA08()
	Private cCadastro := "Cadastro de Compartilhamento"
	Private aRotina := {}
	Private cDelFunc := ".T." // Validacao para a exclusao.
	Private cAlias := "PA9"  // Cadastro de compartilhamento de contratos

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// 10/03/2016 - Thiago Rasmussen
	IF /*cFilAnt*/CN9->CN9_FILIAL$"02GO0001;03GO0001"
		AADD(aRotina,{ "Pesquisa","AxPesqui" ,0,1})
		AADD(aRotina,{ "Visual" ,"U_CNIComp" ,0,2})
		AADD(aRotina,{ "Inclui" ,"U_CNIComp" ,0,3})
		AADD(aRotina,{ "Altera" ,"U_CNIComp" ,0,4})
		AADD(aRotina,{ "Exclui" ,"U_CNIComp" ,0,5})

		dbSelectArea(cAlias)
		(cAlias)->(dbSetOrder(1))

		MsFilter("PA9_FILCN9 == '" + CN9->CN9_FILIAL + "' .AND. PA9_NUMERO == '" + CN9->CN9_NUMERO + "' .AND. PA9_REVISA == '" + CN9->CN9_REVISA + "'")
		SetBrwChgAll(.F.)

		mBrowse( 6,1,22,75,cAlias)
	ELSE
		MsgAlert("Compartilhamento de contrato só pode ser realizado para a matriz do SESI ou SENAI.","SIESTA08")
	ENDIF

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} CNIComp
Modelo 3 para cadastro de compartilhamento de contrato.

@type function
@author Bruna Paola
@since 01/10/2012
@version P12.1.23

@param cAlias, Caractere, Alias da tabela.
@param nReg, Numérico, RECNO do registro posicionado.
@param nOpcx, Numérico, Código da posição selecionada.

@obs Projeto ELO

@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Indica se foi possível o comportilhamento do  contrato.

/*/
/*/================================================================================================================================/*/

User Function CNIComp(cAlias,nReg,nOpcx)

	Local cTitulo := "Cadastro de Compartilhamento"
	Local cAliasE := "PA9" // Cabeçalho do cadastro de compartilhamento
	Local cAliasG := "PB1" // Itens do cadastro de compartilhamento
	Local nUsado, nX := 0
	Local oDlg
	Local nOpcA := 0
	Local lRet := .T.

	Private aGets := {}
	Private aTela := {}
	Private aSize := {}
	Private aInfo := {}
	Private aObj := {}
	Private aPObj := {}
	Private aPGet := {} // Retorna a area util das janelas Protheus
	Private cNCont := ""
	Private oGet
	Private lRefresh := .T.
	Private aCols := {}
	Private aHeader := {}
	Private aREG := {}
	Private cXChave := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aSize := MsAdvSize() // Sera utilizado tres areas na janela
	// 1ª - Enchoice, sendo 80 pontos pixel
	// 2ª - MsGetDados, o que sobrar em pontos pixel e para este objeto
	// 3ª - Rodape que e a propria janela, sendo 15 pontos pixel
	AADD( aObj, { 100, 140, .T., .F. })
	AADD( aObj, { 100, 120, .T., .T. })

	// Cálculo automático da dimensões dos objetos (altura/largura) em pixel
	aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	aPObj := MsObjSize( aInfo, aObj )
	// Cálculo automático de dimensões dos objetos MSGET
	aPGet := MsObjGetPos( (aSize[3] - aSize[1]), 315, { {004, 024, 240, 270} } )

	//+----------------------------------------------------------+
	//| Cria variaveis M->????? da Enchoice                      |
	//+----------------------------------------------------------+
	RegToMemory("PA9",(nOpcx==3 .or. nOpcx==4 ))

	If nOpcx == 4

		// Não permite a alteração se não estiver logado na filial de origem
		If (PA9->PA9_FILCN9 <> CFILANT)
			MsgStop("Esse compartilhamento só pode ser alterado pela Filial: "+PA9->PA9_FILCN9)
			lRet := .F.
		EndIf

		If lRet

			M->PA9_FILCN9 := PA9->PA9_FILCN9
			M->PA9_NUMERO := PA9->PA9_NUMERO
			M->PA9_REVISA := PA9->PA9_REVISA

			cNCont := M->PA9_NUMERO

			cXChave := PA9->PA9_FILCN9+PA9->PA9_NUMERO+PA9->PA9_REVISA

		EndIf

	EndIf

	If lRet

		//+----------------------------------------------------------+
		//| Cria aHeader e aCols da GetDados                         |
		//+----------------------------------------------------------+
		nUsado:=0
		//dbSelectArea("SX3")
		OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
		SX3TMP->(dbSeek("PB1"))
		aHeader:={}


		Mod3aHeader()
		Mod3aCOLS( nOpcX )


		// Se for exclusão, verificar se existe SC vinculada ao contrato em alguma empresa/filial compartilhada
		If (nOpcx == 5)
			If (CNIExcComp()) // Não pode excluir o compartilhamento
				lRet := .F.
			EndIf
		EndIf

		If lRet

			DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],aSize[1] TO aSize[6],aSize[5] OF oMainWnd PIXEL
			EnChoice( cAlias, nReg, nOpcx, , , , , aPObj[1])

			oGet := MSGetDados():New(aPObj[2,1],aPObj[2,2],aPObj[2,3],aPObj[2,4],nOpcx,,,"+PB1_ITEM",.T.,,,,,"U_CNICompX")//,,,,,
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIF( Mod3TOk(nOpcx), ( nOpcA := 1, oDlg:End() ), NIL) },{|| oDlg:End() })
			// Validações necessárias
			If nOpcA == 1 .And. (nOpcx == 3 .Or. nOpcx == 4)
				U_CNIConfC (nOpcx)
				//Mod3Grv( nOpc )
				//	ConfirmSX8()
			Endif

			IF INCLUI
				MBrChgLoop(.F.)
			ENDIF

		EndIf

	EndIf

Return lRet


/*/================================================================================================================================/*/
/*/{Protheus.doc} CNIConfC
Grava os dados do compartilhamento nas tabelas PA9 e PB1.

@type function
@author Bruna Paola
@since 01/11/2012
@version P12.1.23

@param nOpcx, Numérico, Opção selcionada da rotina.

@obs Projeto ELO

@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function CNIConfC (nOpcx)

	Local nX := 1
	Local cNc := '01'

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Grava dados da enchoice na tabela PA9
	If nOpcx == 3 // Inclui
		RecLock("PA9", .T.)
		PA9->PA9_FILCN9 := CFILANT
		PA9->PA9_NUMERO := M->PA9_NUMERO
		PA9->PA9_REVISA := M->PA9_REVISA
		PA9->(MsUnLock())

		// Grava dados da aCols na tabela PB1
		For nX := 1 To Len(aCols)
			// Não gravar linha da aCols que foi deletada
			If (aCols[nX,Len(aHeader)+1] == .F.)
				RecLock("PB1", .T.)
				PB1->PB1_FILCN9 := PA9->PA9_FILCN9
				PB1->PB1_NUMERO := M->PA9_NUMERO
				PB1->PB1_REVISA := M->PA9_REVISA
				PB1->PB1_ITEM := cNc //aCols[nX,1]
				PB1->PB1_FILEMP := aCols[nX,2]
				PB1->PB1_EMP := aCols[nX,3]
				PB1->PB1_UNID := aCols[nX,4]
				PB1->PB1_FIL := aCols[nX,5]
				PB1->PB1_FILNOM := aCols[nX,6]
				PB1->(MsUnLock())
				cNc := Soma1(cNc)
			EndIf
		Next nX
	ElseIf nOpcx == 4 // Altera

		DbSelectArea("PA9")
		PA9->(DbSetOrder(1))
		PA9->(DbGoTop())

		// Procura na tabela PA9 o registro que deve ser alterado
		If PA9->(DbSeek(xFilial("PA9")+cXChave))
			RecLock("PA9", .F.)
			PA9->PA9_FILCN9 := CFILANT
			PA9->PA9_NUMERO := M->PA9_NUMERO
			PA9->PA9_REVISA := M->PA9_REVISA
			PA9->(MsUnLock())

			DbSelectArea("PB1")
			PB1->(DbSetOrder(2))
			PB1->(DbGoTop())

			If PB1->(DbSeek(xFilial("PB1")+PA9->PA9_FILCN9+PA9->PA9_NUMERO+PA9->PA9_REVISA))
				// Grava dados da aCols na tabela PB1
				For nX := 1 To Len(aCols)
					// Se já existir o cadastro do item só atualiza
					If (PB1->PB1_ITEM == aCols[nX,1])
						//	 só gravar as linhas do aCols quando a linha não foi deletada
						If (aCols[nX,Len(aHeader)+1] == .F.)
							RecLock("PB1", .F.)
							PB1->PB1_FILCN9 := M->PA9_FILCN9
							PB1->PB1_NUMERO := M->PA9_NUMERO
							PB1->PB1_REVISA := M->PA9_REVISA
							PB1->PB1_ITEM := cNc //aCols[nX,1]
							PB1->PB1_FILEMP := aCols[nX,2]
							PB1->PB1_EMP := aCols[nX,3]
							PB1->PB1_UNID := aCols[nX,4]
							PB1->PB1_FIL := aCols[nX,5]
							PB1->PB1_FILNOM := aCols[nX,6]
							PB1->(MsUnLock())
							cNc := Soma1(cNc)
						Else
							RecLock("PB1")
							dbDelete()
							PB1->(MsUnLock())
						Endif
					Else // Cria um novo item na PB1
						//	 só gravar as linhas do aCols quando a linha não foi deletada
						If (aCols[nX,Len(aHeader)+1] == .F.)
							RecLock("PB1", .T.)
							PB1->PB1_FILCN9 := M->PA9_FILCN9
							PB1->PB1_NUMERO := M->PA9_NUMERO
							PB1->PB1_REVISA := M->PA9_REVISA
							PB1->PB1_ITEM := cNc //aCols[nX,1]
							PB1->PB1_FILEMP := aCols[nX,2]
							PB1->PB1_EMP := aCols[nX,3]
							PB1->PB1_UNID := aCols[nX,4]
							PB1->PB1_FIL := aCols[nX,5]
							PB1->PB1_FILNOM := aCols[nX,6]
							PB1->(MsUnLock())
							cNc := Soma1(cNc)
						EndIf
					EndIf
					PB1->(DbSkip())
				Next
			EndIf
		EndIf // fecha if se achaou o registro na PA9
	EndIf

Return .T.


/*/================================================================================================================================/*/
/*/{Protheus.doc} Mod3TOk
Validação dos campos.

@type function
@author Bruna Paola
@since 01/12/2012
@version P12.1.23

@param nOpc, Numérico, Opção selcionada da rotina.

@obs Projeto ELO

@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeito ou falso na validação do campo.

/*/
/*/================================================================================================================================/*/

Static Function Mod3TOk (nOpc)
	Local lRet := .T.
	Local nCont := 1
	Local nX    := 1

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DbSelectArea("PA9")
	PA9->(DbSetOrder(1))
	PA9->(DbGoTop())

	// Não permitir cadastrar um contrato que já esteja cadastrado para a essa filial de origem
	If (nOpc == 3 .And. PA9->(DbSeek(xFilial("PA9")+M->PA9_FILCN9+M->PA9_NUMERO+M->PA9_REVISA)))
		lRet := .F.
		MsgStop("Já existe cadastro para esse contrato.","Atenção")
	Endif

	// Não permite a alteração do número do contrao, somente do aCols e aHeader
	If (nOpc == 4 .And. cNCont <> M->PA9_NUMERO)
		lRet := .F.
		MsgStop("O número do contrato não pode ser alterado.","Atenção")
	EndIf

	If (lRet)
		// Não permitir gravar se alguma linha do aCols estiver em branco
		For nCont := 1 To Len(aCols)
			If (Empty(AllTrim(aCols[nCont,GdFieldPos("PB1_FILEMP")])))
				lRet := .F.
				MsgStop("Preencha as filiais que receberão o compartilhamento.", "Atenção")
				Exit
			EndIf
		Next nCont
	EndIf

	If (lRet)
		// Não permitir gravar se todas as linhas do Acols estiverem deletadas
		For nCont := 1 To Len(aCols)
			If (aCols[nCont,GdFieldPos("PB1_FILNOM")+1] == .T.)
				nX++
			EndIf
		Next nCont

		// Se todas as linhas estiverem deletadas
		If (nX == nCont)
			lRet := .F.
			MsgStop("Preencha as filiais que receberão o compartilhamento.", "Atenção")
		EndIf
	EndIf

Return lRet


/*/================================================================================================================================/*/
/*/{Protheus.doc} CNIExcComp
Verifica a exclusão do compartilhamento.

@type function
@author Bruna Paola
@since 01/12/2012
@version P12.1.23

@obs Projeto ELO

@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro indicando que não permite a exclusão compartilhamento.

/*/
/*/================================================================================================================================/*/

Static Function CNIExcComp()
	Local lRet := .F.
	Local cFil := PA9->PA9_FILCN9
	Local cCont := PA9->PA9_NUMERO
	Local cRev := PA9->PA9_REVISA

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DbSelectArea("PB1")
	PB1->(DbSetOrder(2))
	PB1->(DbGoTop())

	// Procurar na tabela PB1 o contrato
	PB1->(DbSeek(xFilial("PB1")+PA9->PA9_FILCN9+PA9->PA9_NUMERO+PA9->PA9_REVISA))

	Do While (PB1->(!EOF()) .And. cFil == PB1->PB1_FILCN9 .And. cCont == PB1->PB1_NUMERO .And. cRev == PB1->PB1_REVISA .And. lRet == .F.)

		// Procurar na tabela SC1 (Solicitações de Compra) pela filial e contrato de preço
		// Case encontre um registro que utilize o contrato, o mesmo não poderá ser excluido
		DbSelectArea("SC1")
		SC1->(DbSetOrder(10))
		SC1->(DbGoTop())

		// Procura pela empresa/unidade/filial que contem no cadastro de compartilhamento + Numero do contrato e revisão
		// Se encontrar deve retornar .T. para não deixar excluir o compartilhamento
		If SC1->(DbSeek(AllTrim(PB1->PB1_EMP)+AllTrim(PB1->PB1_UNID)+AllTrim(PB1->PB1_FIL)+AllTrim(PB1->PB1_NUMERO)+AllTrim(PB1->PB1_REVISA)))
			lRet := .T.
		EndIf

		PB1->(DbSkip())
	EndDo

	//Pode excluir o compartilhamento
	If (lRet == .F.)

		DbSelectArea("PB1")
		PB1->(DbSetOrder(2))
		PB1->(DbGoTop())

		PB1->(DbSeek(xFilial("PB1")+PA9->PA9_FILCN9+PA9->PA9_NUMERO+PA9->PA9_REVISA))

		// Exclui registro da tabela de itens de compartilhamento
		Do While (PB1->(!EOF()) .And. PA9->PA9_FILCN9 == PB1->PB1_FILCN9 .And. PA9->PA9_NUMERO == PB1->PB1_NUMERO .And. PA9->PA9_REVISA == PB1->PB1_REVISA)
			RecLock("PB1")
			dbDelete()
			PB1->(MsUnLock())

			PB1->(DbSkip())
		EndDo

		// Exclui registro do cabeçalho do compartilhamento
		RecLock("PA9")
		dbDelete()
		PA9->(MsUnLock())

	Else// Se não puder excluir o registro de compartilhamento
		MsgStop("Esse compartilhamento não pode ser excluido, contrato relacionado em solicitações de compra.","Atenção")
	EndIf

Return lRet


/*/================================================================================================================================/*/
/*/{Protheus.doc} CNICompX
Função para gatilhar os campos visuais do aCols.

@type function
@author Thiago Rasmussen
@since 02/06/2012
@version P12.1.23

@obs Projeto ELO

@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Valida o compartilhamento do contrato.

/*/
/*/================================================================================================================================/*/

User Function CNICompX()
	Local aSM0 := SM0->(GetArea())
	Local nX   := 1
	Local lRet := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Validar a aCols verificando se já existe a filial no compartilhamento
	// se já existir não pode adicionar na aCols
	For nX := 1 To Len(aCols)
		If (aCols[nX,2] == M->PB1_FILEMP)
			lRet := .F.
			MsgStop("Já existe compartilhamento desse contrato para essa filial.", "Atenção")
		EndIf
	Next nX

	If (lRet == .T.)
		DbSelectArea("SM0")
		SM0->(DbSetOrder(1))


		// Procura pelo nome da filial
		If SM0->(DbSeek(cEmpAnt+M->PB1_FILEMP))
			aCols[n,6] := SM0->M0_FILIAL

		EndIf

		DbSelectArea("XX8")
		XX8->(DbSetOrder(4))

		// Preenche os campos do aCols do cadastro (Gatilho)
		//  GRUPO EMPRESA / EMPRESA/ UNIDADE / CODIGO / TIPO
		If XX8->(DbSeek(cEmpAnt+Space(10)+SubStr(M->PB1_FILEMP,1,2)+Space(10)+SubStr(M->PB1_FILEMP,3,2)+Space(10)+SubStr(M->PB1_FILEMP,5,4)+Space(8)))
			aCols[n,3] := XX8->XX8_EMPR
			aCols[n,4] := XX8->XX8_UNID
			aCols[n,5] := XX8->XX8_CODIGO
		EndIf
	EndIf

	RestArea(aSM0)

Return lRet


/*/================================================================================================================================/*/
/*/{Protheus.doc} Mod3aHeader
Monstar o Header.

@type function
@author Thiago Rasmussen
@since 02/06/2012
@version P12.1.23

@obs Projeto ELO

@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function Mod3aHeader()
	Local aArea := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	//dbSelectArea("SX3")
	OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
	SX3TMP->(dbSetOrder(1))
	SX3TMP->(dbSeek("PB1"))
	While SX3TMP->(!EOF()) .And. X3_ARQUIVO == "PB1"
		If X3Uso(X3_USADO) .And. cNivel >= X3_NIVEL
			AADD( aHeader, { Trim( X3Titulo() ),;
			X3_CAMPO,;
			X3_PICTURE,;
			X3_TAMANHO,;
			X3_DECIMAL,;
			X3_VALID,;
			X3_USADO,;
			X3_TIPO,;
			X3_ARQUIVO,;
			X3_CONTEXT})
		Endif
		dbSkip()
	End
	RestArea(aArea)
Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} Mod3aCOLS
Criar aCols.

@type function
@author Thiago Rasmussen
@since 02/06/2012
@version P12.1.23

@param nOpc, Numérico, Código da opção selecionada do rotina.

@obs Projeto ELO

@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function Mod3aCOLS( nOpc )
	Local aArea := GetArea()
	Local cChave := ""
	Local cAlias := "PB1"
	Local nI := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If nOpc <> 3
		cChave := PA9->PA9_NUMERO + PA9->PA9_REVISA
		dbSelectArea( cAlias )
		( cAlias )->(dbSetOrder(2))
		( cAlias )->(dbSeek( xFilial( cAlias ) + PA9->PA9_FILCN9 + cChave ))
		While ( cAlias )->(!EOF()) .And. PB1->( PB1_FILCN9 + PB1_NUMERO + PB1_REVISA) == PA9->PA9_FILCN9 + cChave
			AADD( aREG, PB1->( RecNo() ) )
			AADD( aCOLS, Array( Len( aHeader ) + 1 ) )
			For nI := 1 To Len( aHeader )
				If aHeader[nI,10] == "V"
					aCOLS[Len(aCOLS),nI] := CriaVar(aHeader[nI,2],.T.)
				Else
					aCOLS[Len(aCOLS),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				Endif
			Next nI
			aCOLS[Len(aCOLS),Len(aHeader)+1] := .F.
			dbSkip()
		End
	Else
		AADD( aCOLS, Array( Len( aHeader ) + 1 ) )
		For nI := 1 To Len( aHeader )
			aCOLS[1, nI] := CriaVar( aHeader[nI, 2], .T. )
		Next nI
		aCOLS[1, GdFieldPos("PB1_ITEM")] := "01"
		aCOLS[1, Len( aHeader )+1 ] := .F.
	Endif
	Restarea( aArea )
Return