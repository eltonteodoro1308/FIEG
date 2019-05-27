#Include "Protheus.ch"
#Include "TopConn.Ch"

#DEFINE ENTER	CRLF

/*/================================================================================================================================/*/
/*/{Protheus.doc} CNIA188CA
Cadastro de Criterios de Avaliacao.
Monta Tela com dois folders (solicitante, comprador) dos campos da tabela DBH.

@type function
@author Fabricio Romera
@since 21/07/2011
@version P12.1.23

@param nOpc, Numérico, Opção selecionada 3 = Inclusão / 4 = Alteração / 5 = Exclusão.

@obs Projeto ELO alterado pela FIEG

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CNIA188CA(nOpc)

	Local cTitle 	:= "Criterios de Avaliação" //Ler do SX2
	Local aCoord 	:= {}
	Local oSize     := FwDefSize():New(.T.) //Local oDlg
	Local oFld
	Local aCampos 	:= {}
	Local nX, nY  	:= 0
	Local lOk	  	:= .F.
	Local aSize	  	:= {}
	Default nOpc	:= 4
	Private aHeader := {}
	Private aCols	:= {}
	Private aCols1	:= {}
	Private aCols2	:= {}
	Private oGet1, oGet2, oTPane1, oTPane2
	Private aRotina	:= {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	aAdd( aRotina, {"Pesquisar" ,"AxPesqui"									  	,0,1} )
	aAdd( aRotina, {"Visualizar","AxVisual"									  	,0,2} )
	aAdd( aRotina, {"Incluir"   ,"U_CNIA188CA(3)"								,0,3} )
	aAdd( aRotina, {"Alterar"   ,"U_CNIA188CA(4)"								,0,4} )
	aAdd( aRotina, {"Excluir"   ,"U_CNIA188CA(5)"								,0,5} )

	//Monta aHeader
	MontaHeader(@aHeader, nOpc)

	//Carrega aCols
	CarregaCols(@aCols1, @aCols2, nOpc)

	//Faz calculo automatico das dimensoes
	aSize := MsAdvSize(,.F.,400)

	//Dimensionamento da tela
	oSize:AddObject( "LISTA", 000, 000, .T., .T. )
	oSize:Process()

	//Cria tela de cadastro
	DEFINE MSDIALOG oDlg TITLE cTitle FROM;
	oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

	oTPane2 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,16,.T.,.F.)
	oTPane2:Align := CONTROL_ALIGN_ALLCLIENT
	oTPane2:NCLRPANE := 14803406

	//Cria folder | Solicitante | Comprador |
	@ 000, 000 FOLDER oFld OF oTPane2 PROMPT "Solicitante", "Comprador" PIXEL SIZE 400, 400
	oFld:Align := CONTROL_ALIGN_ALLCLIENT
	oFld:bSetOption:={|nFolder| A188SetOption(nFolder,oFld:nOption) }

	//Folder 1
	aCols := aCols1
	oGet1 := MSGetDados():New(0, 0, 0, 0, nOpc,,,"+DBH_CODIGO",.T.,,,,,,,,"AllwaysTrue",oFld:aDialogs[1])
	oGet1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGet1:oBrowse:bDrawSelect	:= {|| U_A188Cols(1)}

	//Folder 2
	aCols := aCols2
	oGet2 := MSGetDados():New(0, 0, 0, 0, nOpc,,,"+DBH_CODIGO",.T.,,,,,,,,"AllwaysTrue",oFld:aDialogs[2])
	oGet2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGet2:oBrowse:bDrawSelect	:= {|| U_A188Cols(2)}

	aCols		:= aClone(aCols1)

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| lOk := .T., oDlg:End()},{||oDlg:End()})

	If lOk
		GravaDBH(nOpc)
		Aviso("Criterios de Avaliação"," Atualização concluída. ",{"Ok"})
	Else
		Aviso("Criterios de Avaliação"," Processo cancelado. 	",{"Ok"})
	End If

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} GravaDBH
Grava os dados da Tabela DBH.

@type function
@author Fabricio Romera
@since 25/07/2011
@version P12.1.23

@param nOpc, Numérico, Opção selecionada 3 = Inclusão / 4 = Alteração / 5 = Exclusão.

@obs Projeto ELO alterado pela FIEG

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function GravaDBH(nOpc)

	Local nX	:= 0
	Local lSeek := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	DbSelectArea("DBH")
	DBH->( DbSetOrder(1) )

	//Grava aba de solicitantes
	For nX := 1 to Len(aCols1)

		lSeek := DBH->( DbSeek( xFilial("DBH") + aCols1[nX][1] + aCols1[nX][2] ) )

		//Alteracao e Inclusao
		If !aCols1[nX][Len(aCols1[nX])] .And. !Empty(aCols1[nX][2])

			RecLock("DBH", !lSeek)
			DBH->DBH_FILIAL		:= xFilial("DBH")
			DBH->DBH_CODIGO		:= aCols1[nX][1]
			DBH->DBH_TIPO		:= aCols1[nX][2]
			DBH->DBH_DESCR		:= aCols1[nX][3]
			DBH->DBH_PESO		:= aCols1[nX][4]
			DBH->DBH_ATIVO		:= aCols1[nX][5]
			DBH->( MsUnlock() )

			//Exclusao
		ElseIf lSeek .And. !Empty(aCols1[nX][2])

			RecLock("DBH", .F., .T.)
			DBH->( DbDelete() )
			DBH->( MsUnlock() )

		End If

	Next

	DbSelectArea("DBH")
	DBH->( DbSetOrder(1) )

	//Grava aba de solicitantes
	For nX := 1 to Len(aCols2)

		lSeek := DBH->( DbSeek( xFilial("DBH") + aCols2[nX][1] + aCols2[nX][2] ) )

		//Alteracao e Inclusao
		If !aCols2[nX][Len(aCols2[nX])] .And. !Empty(aCols2[nX][2])

			RecLock("DBH", !lSeek)
			DBH->DBH_FILIAL		:= xFilial("DBH")
			DBH->DBH_CODIGO		:= aCols2[nX][1]
			DBH->DBH_TIPO		:= aCols2[nX][2]
			DBH->DBH_DESCR		:= aCols2[nX][3]
			DBH->DBH_PESO		:= aCols2[nX][4]
			DBH->DBH_ATIVO		:= aCols2[nX][5]
			DBH->( MsUnlock() )

			//Exclusao
		ElseIf lSeek .And. !Empty(aCols2[nX][2])

			RecLock("DBH", .F., .T.)
			DBH->( DbDelete() )
			DBH->( MsUnlock() )

		End If

	Next

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} CarregaCols
Carrega os aCols dos folders de Solicitantes e de Compradores.

@type function
@author Fabricio Romera
@since 25/07/2011
@version P12.1.23

@param aCols1, Array, aCols do folder de Solicitantes.
@param aCols2, Array, aCols do folder de Compradores.
@param nOpc, Numérico, Opção selecionada 3 = Inclusão / 4 = Alteração / 5 = Exclusão.
@param cAlias, Caractere, Alias da tabela correspondentes aos GetDados dos folders Solictante e Comprador.

@obs Projeto ELO alterado pela FIEG

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function CarregaCols(aCols1, aCols2, nOpc, cAlias)

	Local nUsado 	:= 0
	Local cVarTemp 	:= ""
	Local cCodigo	:= IIf( Type("DBI_CODIGO") == "C", M->DBI_CODIGO, "")
	Local cCpoCod	:= IIf( Type("DBI_CODIGO") == "C", "DBJ->DBJ_CODIGO", "''")
	Default cAlias 	:= "DBH"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	dbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(2))
	(cAlias)->(dbSeek( xFilial(cAlias) + "1" + cCodigo ))

	OpenSxs(,,,,cEmpAnt,"SX3MDI","SX3",,.F.)
	SX3MDI->(dbSeek( cAlias ))

	While !Eof() .And. (cAlias)->&(cAlias+"_FILIAL") + (cAlias)->&(cAlias+"_TIPO") + &(cCpoCod) == xFilial(cAlias) + "1" + cCodigo

		aAdd( aCols1, Array(Len(aHeader)+1))
		aCols1[Len(aCols1)][Len(aCols1[Len(aCols1)])] := .F.

		nUsado:=0
		While !EOF() .And. SX3MDI->X3_ARQUIVO == cAlias
			If X3USO(SX3MDI->X3_USADO) .AND. cNivel >= SX3MDI->X3_NIVEL
				nUsado++
				cVarTemp := cAlias+"->"+(SX3MDI->X3_CAMPO)
				If SX3MDI->X3_CONTEXT # "V"
					aCols1[Len(aCols1),nUsado] := &cVarTemp
				ElseIf SX3MDI->X3_CONTEXT == "V"
					aCols1[Len(aCols1),nUsado] := CriaVar(AllTrim(SX3MDI->X3_CAMPO))
				Endif

			Endif
			SX3MDI->(dbSkip())
		End
		dbSelectArea(cAlias)
		(cAlias)->(dbSkip())
	End

	dbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(2))
	(cAlias)->(dbSeek( xFilial(cAlias) + "2" + cCodigo))

	While !Eof() .And. (cAlias)->&(cAlias+"_FILIAL") + (cAlias)->&(cAlias+"_TIPO") + &(cCpoCod) == xFilial(cAlias) + "2" + cCodigo

		aAdd( aCOLS2, Array(Len(aHeader)+1))
		aCols2[Len(aCols2)][Len(aCols2[Len(aCols2)])] := .F.

		nUsado:=0
		SX3MDI->(DbGotop())
		SX3MDI->(dbSeek( cAlias ))
		While !EOF() .And. SX3MDI->X3_ARQUIVO == cAlias
			If X3USO(SX3MDI->X3_USADO) .AND. cNivel >= SX3MDI->X3_NIVEL
				nUsado++
				cVarTemp := cAlias+"->"+(SX3MDI->X3_CAMPO)
				If SX3MDI->X3_CONTEXT # "V"
					aCOLS2[Len(aCOLS2),nUsado] := &cVarTemp
				ElseIf SX3MDI->X3_CONTEXT == "V"
					aCOLS2[Len(aCOLS2),nUsado] := CriaVar(AllTrim(SX3MDI->X3_CAMPO))
				Endif

			Endif
			SX3MDI->(dbSkip())
		End
		dbSelectArea(cAlias)
		(cAlias)->(dbSkip())
	End

	SX3MDI->( DbCloseArea() )

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} MontaHeader
Monta o aHeader dos folders de Solicitantes e de Compradores.

@type function
@author Fabricio Romera
@since 25/07/2011
@version P12.1.23

@param aHeader, Array, aHeader do folder de Solicitantes.
@param nOpc, Numérico, Opção selecionada 3 = Inclusão / 4 = Alteração / 5 = Exclusão.
@param cAlias, Caractere, Alias da tabela correspondentes aos GetDados dos folders Solictante e Comprador.

@obs Projeto ELO alterado pela FIEG

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function MontaHeader(aHeader, nOpc, cAlias)

	Local nUsado := 0
	Default cAlias := "DBH"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	OpenSxs(,,,,cEmpAnt,"SX3MDI","SX3",,.F.)
	SX3MDI->( dbSetOrder(1) )
	SX3MDI->( dbSeek( cAlias ) )
	While !EOF() .And. SX3MDI->X3_ARQUIVO == cAlias
		If X3USO(SX3MDI->X3_USADO) .AND. cNivel >= SX3MDI->X3_NIVEL
			nUsado++
			AADD(aHeader,{ TRIM(SX3MDI->X3_TITULO) ,;
			SX3MDI->X3_CAMPO        ,;
			SX3MDI->X3_PICTURE      ,;
			SX3MDI->X3_TAMANHO      ,;
			SX3MDI->X3_DECIMAL      ,;
			SX3MDI->X3_VALID        ,;
			SX3MDI->X3_USADO        ,;
			SX3MDI->X3_TIPO         ,;
			SX3MDI->X3_ARQUIVO      ,;
			SX3MDI->X3_CONTEXT      })
		Endif
		SX3MDI->( dbSkip() )
	End

	SX3MDI->( DbCloseArea() )

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} A188Cols
Salva o conteudo da GetDados se existir.

@type function
@author Fabricio Romera
@since 25/07/2011
@version P12.1.23

@param nGetDados, Numérico, Indica o aCols a ser salvo.

@obs Projeto ELO alterado pela FIEG

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
User Function A188Cols(nGetDados)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//Salva o conteudo da GetDados se existir
	If nGetDados = 1
		aCols1			:= {}
		aCols1			:= aClone(aCols)
		aCols			:= {}
		aCols			:= aCols1
		aCols[Len(aCols)][2] := "1"
	ElseIf nGetDados = 2
		aCols2			:= {}
		aCols2			:= aClone(aCols)
		aCols			:= {}
		aCols			:= aCols2
		aCols[Len(aCols)][2] := "2"
	End If

Return .T.

/*/================================================================================================================================/*/
/*/{Protheus.doc} A188SetOption
Salva o conteudo da GetDados.

@type function
@author Fabricio Romera
@since 25/07/2011
@version P12.1.23

@param nFolder, Numérico, Folder Selecionado.
@param nOldFolder, Numérico, Folder POosicionado.

@obs Projeto ELO alterado pela FIEG

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function A188SetOption(nFolder,nOldFolder)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//Salva o conteudo da GetDados
	If nOldFolder = 1
		aCols1		:= {}
		aCols1		:= aClone(aCols)
		oGet1:oBrowse:lDisablePaint	:= .T.
	ElseIf nOldFolder = 2
		aCols2		:= {}
		aCols2		:= aClone(aCols)
		oGet2:oBrowse:lDisablePaint	:= .T.
	EndIf

	//Restaura o conteudo da GetDados
	If nFolder = 1
		oGet1:oBrowse:lDisablePaint	:= .F.
		aCols	:= {}
		aCols	:= aCols1 //aClone(aCols1)
		n := 1
		oGet1:oBrowse:Refresh()

	ElseIf nFolder = 2
		oGet2:oBrowse:lDisablePaint	:= .F.
		aCols	:= {}
		aCols	:= aCols2 //aClone(aCols2)
		n := 1
		oGet2:oBrowse:Refresh()
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} C188AFMan
Avaliacao de Fornecedores.

@type function
@author Fabricio Romera
@since 22/08/2011
@version P12.1.23

@param cAlias, Caractere, Alias da Tabala.
@param nRecno, Numérico, Recno do registro posicionado.
@param nOpc, Numérico, Opção selecionada.

@obs Projeto ELO alterado pela FIEG

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
User Function C188AFMan(cAlias,nRecno, nOpc)

	Local nSaveSX8  := GetSX8Len()
	Local cTitle 	:= "Avaliação de Fornecedores" //Ler do SX2
	Local aCoord 	:= {}
	Local oDlg
	Local oFld
	Local aCampos 	:= {}
	Local nX, nY  	:= 0
	Local lOk	  	:= .F.
	Local aSize	  	:= {}
	Local cNomeSol  := ""
	Local cNomeCom  := ""
	Local _cBody  	:= ""
	Local lSegue    := .T.
	Default nOpc	:= 4
	Private aHeader := {}
	Private aCols	:= {}
	Private aCols1	:= {}
	Private aCols2	:= {}
	Private oGet1, oGet2, oTPane1, oTPane2, oEnchoice

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	//Carrega registro
	DBI->(dbGoTo(nRecno))
	DBI->(RegToMemory("DBI", IIf(nOpc = 3,.T.,.F.) ))

	//Verifica se pode alterar
	If  nOpc == 4 .And. M->DBI_STATUS == "4"
		Aviso("Avaliação de Fornecedores"," Avaliação já Finalizada, não pode ser Alterada. ",{"Ok"})
		lSegue := .F.
	EndIf

	//Verifica se pode Estornar
	If lSegue .And. nOpc == 8 .And. M->DBI_STATUS <> "4"
		Aviso("Avaliação de Fornecedores"," Avaliação não finalizada, não pode ser Estornada. ",{"Ok"})
		lSegue := .F.
	EndIf

	If lSegue

		//Monta aHeader
		MontaHeader(@aHeader, nOpc, "DBJ")

		//Carrega aCols
		CarregaCols(@aCols1, @aCols2, nOpc, "DBJ")

		//Faz calculo automatico das dimensoes
		aSize := MsAdvSize(,.F.,400)

		//Cria tela de cadastro
		DEFINE MSDIALOG oDlg TITLE cTitle From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

		//Cabeçalho
		oTPane1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,150,.T.,.F.)
		oTPane1:Align := CONTROL_ALIGN_TOP
		oTPane1:NCLRPANE := 14803406

		//Itens
		oTPane2 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,120,.T.,.F.)
		oTPane2:Align := CONTROL_ALIGN_BOTTOM
		oTPane2:NCLRPANE := 14803406

		//Cria folder | Solicitante | Comprador |
		@ 000, 000 FOLDER oFld OF oTPane2 PROMPT "Solicitante", "Comprador" PIXEL SIZE 400, 400
		oFld:Align := CONTROL_ALIGN_ALLCLIENT
		oFld:bSetOption:={|nFolder| A188SetOption(nFolder,oFld:nOption) }

		//Cria campos do cabecalho
		oEnchoice := MsMGet():New("DBI",,nOpc,,,,,{2,2,100,100},,,,,,oTPane1)
		oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		//Folder 1
		aCols := aCols1
		oGet1 := MSGetDados():New(0, 0, 0, 0, nOpc,,,"+DBJ_ITEM",.T.,,,,,,,,"AllwaysTrue",oFld:aDialogs[1])
		oGet1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGet1:oBrowse:bDrawSelect	:= {|| U_A188Cols(1)}

		If Empty( aCols1[Len(aCols1)][ aScan(aHeader, { |x| AllTrim(x[2]) == "DBJ_TIPO" }) ]  )
			aCols1[Len(aCols1)][ aScan(aHeader, { |x| AllTrim(x[2]) == "DBJ_TIPO" }) ]  := "1"
		End If

		//Folder 2
		aCols := aCols2
		oGet2 := MSGetDados():New(0, 0, 0, 0, nOpc,,,"+DBJ_ITEM",.T.,,,,,,,,"AllwaysTrue",oFld:aDialogs[2])
		oGet2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGet2:oBrowse:bDrawSelect	:= {|| U_A188Cols(2)}

		If Empty( aCols2[Len(aCols2)][ aScan(aHeader, { |x| AllTrim(x[2]) == "DBJ_TIPO" }) ]  )
			aCols2[Len(aCols2)][ aScan(aHeader, { |x| AllTrim(x[2]) == "DBJ_TIPO" }) ]  := "2"
		End If

		aCols		:= aClone(aCols1)

		//Bloqueia folders conforme status
		If (nOpc == 3 .Or. nOpc == 4) .And. M->DBI_STATUS == "2" //Pend. Solicitante
			oFld:aEnable(2, .F.)
		ElseIf (nOpc == 3 .Or. nOpc == 4) .And. M->DBI_STATUS == "3" //Pend. Comprador
			oFld:aEnable(1, .F.)
		End If

		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| lOk := ValidCpos(nOpc), If(lOk, oDlg:End(),)},{||oDlg:End()})

		If lOk .And. nOpc <> 7

			Begin Transaction

				//Grava registro
				If C188AFGrava(cAlias,nRecno, nOpc)

					//Confirma numeracao automatica
					While ( GetSX8Len() > nSaveSX8 )
						ConfirmSX8()
					EndDo

					Aviso("Avaliação de Fornecedores","Atualização concluída.",{"Ok"})

				Else

					//Cancela numeracao automatica
					While ( GetSX8Len() > nSaveSX8 )
						RollBackSX8()
					EndDo

				End If

			End Transaction

		Else
			//Aviso("Criterios de Avaliação"," Processo cancelado. 	",{"Ok"})
			While ( GetSX8Len() > nSaveSX8 )
				RollBackSX8()
			EndDo
		End If

	End If

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} C188AFGrava
Inclui/Altera/Exclui registro de avaliacao de fornecedores.

@type function
@author Fabricio Romera
@since 22/08/2011
@version P12.1.23

@param cAlias, Caractere, Alias da Tabala.
@param nRecno, Numérico, Recno do registro posicionado.
@param nOpc, Numérico, Opção selecionada.

@obs Projeto ELO alterado pela FIEG

@return Lógico, Fixo Verdadeiro.

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.
@history 08/05/2019, Kley@TOTVS.com.br, Troca da função ACSendMail() por TkSendMail().
/*/
/*/================================================================================================================================/*/

Static Function C188AFGrava(cAlias, nRecno, nOpc)

	Local lRet 		:= .T.
	Local nX		:= 0
	Local lSeek 	:= .F.
	Local lFinal	:= .F.
	Local cStatus   := ""
	Local _cEMail 	:= ""
	Local lSegue    := .T.
	Local _cBody  := ""
	Local cAccon  := SuperGetMv("MV_RELACNT")
	Local cPassw  := SuperGetMv("MV_RELAPSW")
	Local cServer := SuperGetMv("MV_RELSERV")
	Local cFrom	  := SuperGetMv("MV_RELFROM")

	Private cNomeUser := Alltrim(UsrRetName(__cUserID))

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//Verifica se deve passar para proxima etapa/finalizar
	If (nOpc == 4 .or. nOpc == 3) .And. nOpc <> 8
		If Aviso("Avaliação de Fornecedores","Deseja finalizar a etapa atual da avaliação?",{"Sim", "Não"})  == 1
			lFinal := .T.
		EndIf
	Else
		If nOpc == 8
			If Aviso("Avaliação de Fornecedores","Confirma estorno da avaliação?",{"Sim", "Não"})  == 1
				lFinal := .T.
			Else
				lSegue := lFinal
			EndIf
		EndIf
	EndIf

	If lSegue

		//-------------------------------------------------------------------------------------------------------------------------------
		//	Itens
		//-------------------------------------------------------------------------------------------------------------------------------
		DbSelectArea("DBJ")
		DBJ->( DbSetOrder(1) )

		//Grava aba de solicitantes
		For nX := 1 to Len(aCols1)

			lSeek := DBJ->( DbSeek( xFilial("DBJ") + aCols1[nX][1] + aCols1[nX][2] + aCols1[nX][3]) ) //DBJ_FILIAL+DBJ_CODIGO+DBJ_TIPO+DBJ_ITEM

			//Alteracao e Inclusao
			If !aCols1[nX][Len(aCols1[nX])] .And. !Empty(aCols1[nX][2]) .And. !Empty(aCols1[nX][4])

				RecLock("DBJ", !lSeek)
				DBJ->DBJ_FILIAL		:= xFilial("DBJ")
				DBJ->DBJ_CODIGO		:= aCols1[nX][1]
				DBJ->DBJ_TIPO  		:= aCols1[nX][2]
				DBJ->DBJ_ITEM  		:= aCols1[nX][3]
				DBJ->DBJ_CRITER		:= aCols1[nX][4]
				DBJ->DBJ_CRIDES		:= aCols1[nX][5]
				DBJ->DBJ_PESO  		:= aCols1[nX][6]
				DBJ->DBJ_NOTA  		:= aCols1[nX][7]
				DBJ->DBJ_PONTUA		:= aCols1[nX][8]
				DBJ->( MsUnlock() )

				//Exclusao
			ElseIf lSeek .And. !Empty(aCols1[nX][2])

				RecLock("DBJ", .F., .T.)
				DBJ->( DbDelete() )
				DBJ->( MsUnlock() )

			End If

		Next

		DbSelectArea("DBJ")
		DBJ->( DbSetOrder(1) )

		//Grava aba de solicitantes
		For nX := 1 to Len(aCols2)

			lSeek := DBJ->( DbSeek( xFilial("DBJ") + aCols2[nX][1] + aCols2[nX][2] + aCols2[nX][3] ) ) //DBJ_FILIAL+DBJ_CODIGO+DBJ_TIPO+DBJ_ITEM

			//Alteracao e Inclusao
			If !aCols2[nX][Len(aCols2[nX])] .And. !Empty(aCols2[nX][2])

				RecLock("DBJ", !lSeek)
				DBJ->DBJ_FILIAL		:= xFilial("DBJ")
				DBJ->DBJ_CODIGO		:= aCols2[nX][1]
				DBJ->DBJ_TIPO  		:= aCols2[nX][2]
				DBJ->DBJ_ITEM  		:= aCols2[nX][3]
				DBJ->DBJ_CRITER		:= aCols2[nX][4]
				DBJ->DBJ_CRIDES		:= aCols2[nX][5]
				DBJ->DBJ_PESO  		:= aCols2[nX][6]
				DBJ->DBJ_NOTA  		:= aCols2[nX][7]
				DBJ->DBJ_PONTUA		:= aCols2[nX][8]
				DBJ->( MsUnlock() )

				//Exclusao
			ElseIf lSeek .And. !Empty(aCols2[nX][2])

				RecLock("DBJ", .F., .T.)
				DBJ->( DbDelete() )
				DBJ->( MsUnlock() )

			End If

		Next

		//-------------------------------------------------------------------------------------------------------------------------------
		//	Cabecalho
		//-------------------------------------------------------------------------------------------------------------------------------
		DbSelectArea("DBI")
		DBI->( DbSetOrder(1) )
		lSeek := DBI->( DbSeek( xFilial("DBI")+ M->DBI_CODIGO) ) //DBI_FILIAL+DBI_CODIGO+DBI_FORNEC

		If nOpc = 5
			RecLock("DBI", .F., .T.)
			DBI->( DbDelete() )
			DBI->( MsUnlock() )
		Else

			//Verifica Alteracao de Status
			If !lFinal .Or. (M->DBI_STATUS == "4" .And. nOpc <> 8)	//Verifica Alteracao de Status
				cStatus := M->DBI_STATUS
			Else
				If nOpc <> 8
					cStatus := AllTrim(Str( Val(M->DBI_STATUS) + 1 ) )
				Else
					if __cUserID == AllTrim(DBI->(DBI_CODSOL))
						cStatus := "3"
						M->DBI_ORIGEM := "1"
					Else
						cStatus := "2"
						M->DBI_ORIGEM := "1"
					EndIf
				EndIf
			EndIf

			RecLock("DBI", !lSeek)

			DBI->DBI_FILIAL		:= xFILIAL("DBI")
			DBI->DBI_CODIGO		:= M->DBI_CODIGO
			DBI->DBI_DATA  		:= M->DBI_DATA
			DBI->DBI_FORNEC		:= M->DBI_FORNEC
			DBI->DBI_LOJA  		:= M->DBI_LOJA
			DBI->DBI_DOC   		:= M->DBI_DOC
			DBI->DBI_SERIE 		:= M->DBI_SERIE
			DBI->DBI_PONTUA		:= IIf( cStatus == "4", U_CA188ClcPnt(), 0 )
			DBI->DBI_CODSOL		:= M->DBI_CODSOL
			DBI->DBI_CODCOM		:= M->DBI_CODCOM
			DBI->DBI_CC    		:= M->DBI_CC
			DBI->DBI_ORIGEM		:= M->DBI_ORIGEM
			DBI->DBI_STATUS		:= cStatus
			DBI->DBI_NOME  		:= M->DBI_NOME
			DBI->DBI_NOMSOL		:= M->DBI_NOMSOL
			DBI->DBI_NOMCOM		:= M->DBI_NOMCOM
			DBI->DBI_CCDESC		:= M->DBI_CCDESC
			DBI->( MsUnlock() )

			//Envia e-mail de aviso de conclusao de etapa/processo
			If lFinal .And. cStatus = "3" .And. M->DBI_ORIGEM <> "1" .And. nOpc <> 8

				//Envia email ao comprador
				_cEMail := Alltrim(UsrRetMail( M->DBI_CODCOM ) )
				_cBody  := "Prezado(a) Comprador(a),"+CRLF+CRLF
				_cBody  += "Informamos que o solicitante finalizou sua etapa do processo de avaliação de fornecedor "
				_cBody  += "referente a Nota Fiscal de Entrada Nr. "+M->DBI_DOC+"/"+M->DBI_SERIE+"."+CRLF+CRLF
				_cBody  += "Codigo do Processo:"+M->DBI_CODIGO+CRLF+CRLF
				_cBody  += "Fornecedor:"+M->DBI_FORNEC+"\"+M->DBI_LOJA+CRLF	+CRLF
				_cBody  += CRLF+CRLF
				//ACSendMail( ,,,,_cEMail,"Conclusão de Etapa - Processo de Aval. de Fornecedor. NF."+M->DBI_DOC+"/"+M->DBI_SERIE,_cBody)
				TKSendMail(cAccon,cPassw,cServer,cFrom,_cEMail,"Conclusão de Etapa - Processo de Aval. de Fornecedor. NF."+M->DBI_DOC+"/"+M->DBI_SERIE,_cBody)

			Else
				If lFinal .And. cStatus = "4" .And. M->DBI_ORIGEM <> "1" .And. nOpc <> 8

					//Envia email ao SUPERVISOR
					_cEMail := Alltrim(UsrRetMail( SuperGetMV("MV_XAVALIA") ) )
					_cBody  := "Prezado(a),"+CRLF+CRLF
					_cBody  += "Informamos que o processo de avaliação de fornecedor "
					_cBody  += "referente a Nota Fiscal de Entrada Nr. "+M->DBI_DOC+"/"+M->DBI_SERIE+"."+CRLF
					_cBody  += "foi finalizado."
					_cBody  += "Codigo do Processo:"+M->DBI_CODIGO+CRLF+CRLF
					_cBody  += "Fornecedor:"+M->DBI_FORNEC+"\"+M->DBI_LOJA+CRLF	+CRLF
					_cBody  += CRLF+CRLF
					//ACSendMail( ,,,,_cEMail,"Conclusão do Processo de Aval. de Fornecedor. NF."+M->DBI_DOC+"/"+M->DBI_SERIE,_cBody)
					TKSendMail(cAccon,cPassw,cServer,cFrom,_cEMail,"Conclusão do Processo de Aval. de Fornecedor. NF."+M->DBI_DOC+"/"+M->DBI_SERIE,_cBody)
				Else
					If lFinal .And. nOpc == 8

						//Envia email ao SUPERVISOR
						_cEMail := Alltrim(UsrRetMail( SuperGetMV("MV_XAVALIA") ) )
						_cBody  := "Prezado(a)"+Alltrim(UsrRetName( SuperGetMV("MV_XAVALIA")))+CRLF+CRLF
						_cBody  += "Informamos que o processo de avaliação de fornecedor  "
						_cBody  += "referente a Nota Fiscal de Entrada Nr. "+M->DBI_DOC+"/"+M->DBI_SERIE+"."+CRLF
						_cBody  += "que encontrava-se Finalizado, foi ESTORNADO pelo usuario "+cNomeUser+CRLF+CRLF
						_cBody  += "Codigo do Processo:"+M->DBI_CODIGO+CRLF+CRLF
						_cBody  += "Fornecedor:"+M->DBI_FORNEC+"\"+M->DBI_LOJA+CRLF	+CRLF
						_cBody  += CRLF+CRLF
						//ACSendMail( ,,,,_cEMail,"Estorno do Processo de Avaliação de Fornecedor já Finalizado. NF."+M->DBI_DOC+"/"+M->DBI_SERIE,_cBody)
						TKSendMail(cAccon,cPassw,cServer,cFrom,_cEMail,"Estorno do Processo de Avaliação de Fornecedor já Finalizado. NF."+M->DBI_DOC+"/"+M->DBI_SERIE,_cBody)
					EndIf
				EndIf
			EndIf
		EndIf

	EndIf

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} CNIA188AF
Avaliacao de Fornecedores.

@type function
@author Fabricio Romera
@since 22/08/2011
@version P12.1.23

@param lConsulta, Lógico, Define se á apenas consulta e eenibe as rotinas de inclusão/alteração/esclusão/relatório.
@param cFiltro, Caractere, Define o Filtro do mBrowse.

@obs Projeto ELO alterado pela FIEG

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
User Function CNIA188AF(lConsulta, cFiltro)

	Local	aCores	   := {}
	Local   lSegue     := .T.

	Default lConsulta  := .F.
	Default cFiltro    := ""

	Private nUsado     := 0
	Private cCadastro  := "Avaliação de Fornecedores"
	Private cAlias1    := "DBI"
	Private cAlias2    := "DBJ"
	Private aRotina    := {}
	Private aPos       := {15, 1, 70, 315}
	Private oCliente   := Nil
	Private oTotal     := Nil
	Private cCliente   := ""
	Private nTotal     := 0

	Private aSize    := {}
	Private aObjects := {}
	Private aInfo    := {}
	Private aPosObj  := {}
	Private aPosGet  := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aSize := MsAdvSize()
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

	aAdd(aObjects,{100,080,.T.,.F.})
	aAdd(aObjects,{100,100,.T.,.T.})
	aAdd(aObjects,{100,015,.T.,.F.})

	aPosObj := MsObjSize(aInfo,aObjects)
	aPosGet := MsObjGetPos((aSize[3]-aSize[1]),315,{{004,024,240,270}} )

	aAdd( aRotina ,{"Pesquisar" ,"AxPesqui"    ,0,1})
	aAdd( aRotina ,{"Visualizar",'u_C188AFMan' ,0,2})
	If !lConsulta
		aAdd( aRotina ,{"Incluir"   ,'u_C188AFMan' ,0,3})
		aAdd( aRotina ,{"Alterar"   ,'u_C188AFMan' ,0,4})
		aAdd( aRotina ,{"Excluir"   ,'u_C188AFMan' ,0,5})
		aAdd( aRotina, {"Relatorio"   ,"U_CNIR188"	,0,6})
	EndIf
	aAdd( aRotina, {"Legenda"   ,'U_CA188Leg'  ,0,7,0,.F.})
	aAdd( aRotina ,{"Estorna Avaliação",'u_C188AFMan' ,0,8})

	aAdd(aCores,{'DBI_STATUS = "1"'	,'BR_PRETO'		})	//Avaliação Manual
	aAdd(aCores,{'DBI_STATUS = "2"'	,'BR_LARANJA'	})	//Pendente Solicitante
	aAdd(aCores,{'DBI_STATUS = "3"'	,'BR_AMARELO'	})	//Pendente Comprador
	aAdd(aCores,{'DBI_STATUS = "4"'	,'ENABLE'		})	//Avaliação Finalizada
	//aAdd(aCores,{'DBI_ORIGEM = "1"'	,'BR_PRETO'		})	//Avaliação Manual

	If Empty(Posicione("SX3",1,cAlias1,"X3_ARQUIVO"))
		Help("",1,"","NOX3X2IX","NÃO É POSSÍVEL EXECUTAR, FALTA"+ENTER+"X3, X2, IX E X7",1,0)
		lSegue := .F.
	Endif

	If lSegue

		dbSelectArea(cAlias2)
		dbSetOrder(1)

		dbSelectArea(cAlias1)
		dbSetOrder(1)

		mBrowse(,,,,cAlias1,,,,,,aCores,,,,,,,,cFiltro)

	End If

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} CA188GetSF1
Carrega campos a partir de la nota selecionada.

@type function
@author Fabricio Romera
@since 24/08/2011
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/
User Function CA188GetSF1()

	Local aArea := GetArea()
	Local lRet  := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//Posiciona SD1
	DbSelectArea("SD1")
	SD1->( DbSetOrder(1) )
	If ! SD1->( DbSeek( xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) ) )
		//lRet := .T.
	End If

	//Posiciona SC7
	DbSelectArea("SC7")
	SC7->( DbSetOrder(1) )
	If ! SC7->( DbSeek(xFilial("SC7")+SD1->D1_PEDIDO) )
		//lRet := .T.
	End If

	//Posiciona SC1
	DbSelectArea("SC1")
	SC1->( DbSetOrder(1) )
	If ! SC1->( DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC) )
		//lRet := .T.
	End If

	//Carrega campos DBI
	M->DBI_CODSOL 	:= Iif(Empty(SC1->C1_XSOL), SC7->C7_USER, SC1->C1_XSOL)
	M->DBI_NOMSOL 	:= UsrRetName(Iif(Empty(SC1->C1_XSOL), SC7->C7_USER, SC1->C1_XSOL))
	M->DBI_CODCOM 	:= SC7->C7_USER 			 //SC1->C1_CODCOMP
	M->DBI_NOMCOM 	:= UsrRetName(SC7->C7_USER) //Posicione( "SY1", 1, xFilial("SY1")+SC7->C7_USER, "Y1_NOME" )
	M->DBI_CC		:= SD1->D1_CC //SC1->C1_CC
	M->DBI_CCDESC	:= Posicione( "CTT", 1, xFilial("CTT")+SD1->D1_CC, "CTT_DESC01" ) //Posicione( "CTT", 1, xFilial("CTT")+SC1->C1_CC, "CTT_DESC01" )

	RestArea(aArea)

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} CA188ClcPnt
Calcula pontuacao final da avaliacao.

@type function
@author Fabricio Romera
@since 09/01/2011
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Pontuacao final da avaliacao.

/*/
/*/================================================================================================================================/*/
User Function CA188ClcPnt()

	Local nPontua   := 0
	Local nPeso		:= 0
	Local nX		:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//Soma pesos e pontuacao parcial - Solicitante
	For nX := 1 to Len(aCols1)
		nPeso 	+= aCols1[nX][6] //Peso
		nPontua += aCols1[nX][8] //Pontua
	Next

	//Soma pesos e pontuacao parcial - Comprador
	For nX := 1 to Len(aCols2)
		nPeso 	+= aCols2[nX][6] //Peso
		nPontua += aCols2[nX][8] //Pontua
	Next

	//Obtem media ponderada
	nPontua := nPontua / nPeso

	M->DBI_PONTUA := nPontua

Return nPontua

/*/================================================================================================================================/*/
/*/{Protheus.doc} CA188Leg
Monsta a Tela de Lengendas.

@type function
@author Thiago Rasmussen
@since 01/03/2019
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
User Function CA188Leg()

	Local aCores     := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	aAdd(aCores,{"BR_PRETO"		,"Avaliação Manual"		})
	aAdd(aCores,{"BR_LARANJA"	,"Pendente Solicitante"	})
	aAdd(aCores,{"BR_AMARELO"	,"Pendente Comprador"	})
	aAdd(aCores,{"ENABLE"		,"Avaliação Finalizada"	})

	BrwLegenda("Avaliação de Fornecedores","",aCores)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} CA188IncA
Rotina para inclusao automatica de avaliacoes.

@type function
@author Fabricio Romera
@since 09/01/2011
@version P12.1.23

@param aDados, Array, Array com os dados do Fornecedro e Documento.

@obs Projeto ELO alterado pela FIEG

@return Lógico, Retorna Falso quando: Se houver produtos criticos, se ja existe avaliacao para o dcto, caso docto nao esteja vinculado a S.C.

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.
@history 08/05/2019, Kley@TOTVS.com.br, Troca da função ACSendMail() por TkSendMail().
/*/
/*/================================================================================================================================/*/

User Function CA188IncA(aDados)

	Local aArea   := GetArea()
	Local lRet	  := .T.
	Local nX	  := 0
	Local lCrit   := .F.
	Local _cEMail := ""
	Local _cBody  := ""
	Local cAccon  := SuperGetMv("MV_RELACNT")
	Local cPassw  := SuperGetMv("MV_RELAPSW")
	Local cServer := SuperGetMv("MV_RELSERV")
	Local cFrom	  := SuperGetMv("MV_RELFROM")

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DbSelectArea("SBZ")
	SBZ->(DbSetOrder(1))

	//Verifica se ha produtos criticos
	For nX := 1 to Len(aCols)
		If !lCrit
			If SBZ->( DbSeek(xFilial("SBZ") + aCols[nX][2]) )
				If SBZ->(BZ_XCRITIC) = "1"
					lCrit := .T.
				End If
			End If
		End If
	Next

	If !lCrit
		RestArea(aArea)
		lRet :=  .F.
	End If

	DbSelectArea("DBI")
	DBI->(DbSetOrder(2))

	//Verifica se ja existe avaliacao para o dcto.
	If lRet .And. DBI->( DbSeek( xFilial("DBI")+aDados[3]+aDados[4]+aDados[1]+aDados[2] ) )
		RestArea(aArea)
		lRet := .F.
	End If

	DBI->(RegToMemory("DBI", .T.))

	//Retorna .F. caso docto nao esteja vinculado a S.C.
	If lRet .And. !U_CA188GetSF1()
		RestArea(aArea)
		lRet :=  .F.
	End If

	If lRet

		RecLock("DBI", .T.)
		DBI->DBI_FILIAL		:= xFilial("DBI")
		DBI->DBI_CODIGO		:= M->DBI_CODIGO
		DBI->DBI_DATA  		:= M->DBI_DATA
		DBI->DBI_FORNEC		:= aDados[3] //M->DBI_FORNEC
		DBI->DBI_LOJA  		:= aDados[4] //M->DBI_LOJA
		DBI->DBI_DOC   		:= aDados[1] //M->DBI_DOC
		DBI->DBI_SERIE 		:= aDados[2] //M->DBI_SERIE
		DBI->DBI_PONTUA		:= 0
		DBI->DBI_CODSOL		:= M->DBI_CODSOL
		DBI->DBI_CODCOM		:= M->DBI_CODCOM
		DBI->DBI_CC    		:= M->DBI_CC
		DBI->DBI_ORIGEM		:= "2"
		DBI->DBI_STATUS		:= "2"
		DBI->DBI_NOME  		:= Posicione( "SA2", 1, xFilial("SA2")+DBI->DBI_FORNEC+DBI->DBI_LOJA, "A2_NOME" )
		DBI->DBI_NOMSOL		:= M->DBI_NOMSOL
		DBI->DBI_NOMCOM		:= M->DBI_NOMCOM
		DBI->DBI_CCDESC		:= M->DBI_CCDESC


		DBI->( MsUnlock() )

		ConfirmSX8()

		//Envia email ao solicitante
		_cEMail := Alltrim(UsrRetMail( M->DBI_CODSOL ) )
		_cBody  := "Prezado(a) Solicitante(a),"+CRLF+CRLF
		_cBody  += "Informamos que foi aberto o processo de avaliação de fornecedor referente a Nota Fiscal de Entrada Nr. "+aDados[1]+"/"+aDados[2]+"."+CRLF+CRLF
		_cBody  += "Codigo do Processo:"+M->DBI_CODIGO+CRLF+CRLF
		_cBody  += "Fornecedor:"+aDados[3]+"\"+aDados[4]+CRLF+CRLF
		_cBody  += CRLF+CRLF+CRLF
		//ACSendMail( ,,,,_cEMail,"Abertura de Processo de Aval. de Fornecedor. NF."+aDados[1]+"/"+aDados[2],_cBody)
		TKSendMail(cAccon,cPassw,cServer,cFrom,_cEMail,"Abertura de Processo de Aval. de Fornecedor. NF."+aDados[1]+"/"+aDados[2],_cBody)

		Aviso("Avaliação de Fornecedores", " Foi gerado registro de avaliação de fornecedor para esta nota fiscal. ",{"Ok"})

	EndIf

	RestArea(aArea)

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} CA188VldCC
Verifica se existe avaliação pendente para um centro custo.

@type function
@author Fabricio Romera
@since 09/01/2011
@version P12.1.23

@param aDados, cCC, Caractere, Centro de Custo.

@obs Projeto ELO alterado pela FIEG

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorna falso caso haja Avaliação pendente para o fornecedor.

/*/
/*/================================================================================================================================/*/

User Function CA188VldCC(cCC)

	Local aArea := GetArea()
	Local lRet := .T.
	Local lSegue  := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If Empty(cCC)
		RestArea(aArea)
		lSegue  := .F.
	End If

	If lSegue

		DbSelectArea("DBI")
		DbSetOrder(3) // Filial + Status + Centro Custo
		If DbSeek(xFilial("DBI")+"2"+cCC)
			Aviso("Validação", "Por favor, verifique a Avaliação de Fornecedor pendente para este Centro de Custo!", {"Ok"}, 3)
			lRet := .F.
		ElseIf DbSeek(xFilial("DBI")+"3"+cCC)
			Aviso("Validação", "Por favor, verifique a Avaliação de Fornecedor pendente para este Centro de Custo!", {"Ok"}, 3)
			lRet := .F.
		End If

	EndIf

	RestArea(aArea)

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} CA188VldCC
Valida Criterio.

@type function
@author Fabricio Romera
@since 09/01/2011
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorna Verdadeiro ou falso para critério válido ou não.

/*/
/*/================================================================================================================================/*/
User Function CA188VlCr()

	Local lRet := .T.
	Local nX

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	DbSelectArea("DBH")
	DBH->( DbSetOrder(2) )
	If DBH->( !DbSeek( xFilial("DBH") + aCols[n][2] + M->DBJ_CRITER ) )
		lRet := .F.
		Aviso("Código Inválido"," Não existe registro com código informado.",{"Ok"})
	End If

	For nX := 1 to Len(aCols)
		If nX <> n .And. aCols[nX][4] = M->DBJ_CRITER
			lRet := .F.

			M->DBJ_CRITER := Space( TAMSX3("DBJ_CRITER")[1] )
			aCols[n][4]   := Space( TAMSX3("DBJ_CRITER")[1] )
			aCols[n][5]   := Space( TAMSX3("DBJ_CRIDES")[1] )
			aCols[n][6]   := 00

			Aviso("Código Inválido"," Critério já cadastrado.",{"Ok"})
		End If
	Next

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} ValidCpos
Valida campos obrigatorios para inclusão/alteracao.

@type function
@author Fabricio Romera
@since 09/01/2011
@version P12.1.23

@param nOpc, Numérico, Opção selecionada.

@obs Projeto ELO alterado pela FIEG

@history 01/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorna Verdadeiro ou falso para validação do campo.

/*/
/*/================================================================================================================================/*/

Static Function ValidCpos(nOpc)

	Local aArea := GetArea()
	Local lRet  := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If nOpc == 3 .or. nOpc == 4

		If Empty(M->DBI_FORNEC) .Or. Empty(M->DBI_LOJA)

			Aviso("Fornecedor","Existe(m) campo(s) obrigatório(s) não preenchidos.",{"Ok"})
			lRet := .F.

		ElseIf Empty(M->DBI_DOC) //.Or. Empty(M->DBI_SERIE)

			Aviso("Documento de Entrada","Existe(m) campo(s) obrigatório(s) não preenchidos.",{"Ok"})
			lRet := .F.

			//Verifica se já existe avaliacao para esta nota
		ElseIf nOpc == 3

			DbSelectArea("DBI")
			DBI->( DbSetOrder(2) )
			If DBI->( DbSeek( xFilial("DBI")+M->DBI_FORNEC+M->DBI_LOJA+M->DBI_DOC+M->DBI_SERIE ))
				Aviso("Avaliação Inválida","Já existe avaliação referente ao fornecedor e documento fiscal informados.",{"Ok"})
				lRet := .F.
			End If
		End If

	End If

	RestArea(aArea)

Return lRet