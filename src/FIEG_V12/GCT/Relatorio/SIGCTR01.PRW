#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIGCTR01
Impressao de Minuta de Contrato em HTML.

@type function
@author Thiago Rasmussen
@since 22/06/2012
@version P12.1.23

@obs Projeto ELO

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIGCTR01()
	Local _cFile := Alltrim(GetNewPar("SI_MINUTA","\dots\Minuta.htm"))
	Local oHTML
	Local lSegue := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Verifica se o arquivo existe
	IF !File(_cFile)
		Aviso("NOFILE",OemToAnsi("Arquivo modelo não localizado. Verifique"),{"Sair"})
		lSegue := .F.
	EndIf

	If lSegue

		//Dados da Contratada
		CNC->(dbSetOrder(1))
		If !CNC->(dbSeek(xFilial("CNC")+CN9->CN9_NUMERO))
			Aviso("Contrato",OemToAnsi("Contrato não encontrado."),{"Ok"})
			lSegue := .F.
		EndIf

	EndIf

	If lSegue

		SA2->(dbSetOrder(1))
		If !SA2->(dbSeek(xFilial("SA2")+CNC->(CNC_CODIGO+CNC_LOJA)))
			Aviso("Contratada",OemToAnsi("Fornededor não encontrado."),{"Ok"})
			lSegue := .F.
		EndIf

	EndIf

	IF lSegue .And. Aviso("Confirmação","Confirma impressão do contrato "+Alltrim(CN9->CN9_NUMERO)+" ?",{"Sim","Não"}) <> 1
		lSegue := .F.
	ENDIF

	If lSegue

		//Abre o HTML
		oProcess := TWFProcess():New( "CONTRATO", "Contrato" )
		oProcess:NewTask( "000001", _cFile )
		oProcess:cSubject := "Contrato " +CN9->CN9_NUMERO
		oProcess:UserSiga := __CUSERID
		oProcess:NewVersion(.T.)
		oHTML   := oProcess:oHTML

		//Dados do Contratante
		oHtml:ValByName("CN9_NUMERO",CN9->CN9_NUMERO)
		oHtml:ValByName("M0_NOMECOM",Alltrim(SM0->M0_NOMECOM))
		oHtml:ValByName("M0_ENDCOB",Alltrim(SM0->M0_ENDCOB))
		oHtml:ValByName("M0_CIDCOB",Alltrim(SM0->M0_CIDCOB))
		oHtml:ValByName("M0_ESTCOB",Alltrim(SM0->M0_ESTCOB))
		oHtml:ValByName("M0_CGC",Transform(Alltrim(SM0->M0_CGC),"@R 99.999.999/9999-99"))

		// Dados da Contratada
		oHtml:ValByName("A2_NOME",Alltrim(SA2->A2_NOME))
		oHtml:ValByName("A2_END",Alltrim(SA2->A2_END))
		oHtml:ValByName("A2_BAIRRO",Alltrim(SA2->A2_BAIRRO))
		oHtml:ValByName("A2_EST",SA2->A2_EST)
		oHtml:ValByName("A2_MUN",Alltrim(SA2->A2_MUN))
		oHtml:ValByName("A2_CEP",SA2->A2_CEP)
		oHtml:ValByName("A2_CGC",Transform(Alltrim(SA2->A2_CGC),"@R 99.999.999/9999-99"))
		oHtml:ValByName("A2_INSCR",Alltrim(SA2->A2_INSCR))
		oHtml:ValByName("A2_CONTATO",Alltrim(SA2->A2_CONTATO))

		// Preenche informacoes dos Itens
		CNB->(dbSetOrder(1))
		CNB->(dbSeek(XFilial("CNB")+CN9->(CN9_NUMERO+CN9_REVISA)))

		While CNB->(!Eof()) .and. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA) == XFilial("CNB")+CN9->(CN9_NUMERO+CN9_REVISA)

			SB5->(dbSetOrder(1))
			IF SB5->(dbSeek(XFilial("SB5")+CNB->CNB_PRODUT))
				_cDescri := Alltrim(SB5->B5_CEME)
			ELSE
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(XFilial("SB1")+CNB->CNB_PRODUT))
				_cDescri := Alltrim(SB1->B1_DESC)
			ENDIF

			AAdd( (oHtml:ValByName("CNB.CNB_ITEM")),CNB->CNB_ITEM )
			AAdd( (oHtml:ValByName("CNB.CNB_DESCRI")),Alltrim(CNB->CNB_DESCRI)+" ("+_cDescri+")")

			CNB->(dbSkip())
		Enddo

		//Prazos
		_aUNVIGE := RetSx3Box( Posicione("SX3", 2, "CN9_UNVIGE", "X3CBox()" ),,, 1 )
		_cUNVIGE := _aUNVIGE[aScan(_aUNVIGE,{|x| x[2] == CN9->CN9_UNVIGE}),3]
		oHtml:ValByName("CN9_VIGE",Alltrim(Str(CN9->CN9_VIGE)))
		oHtml:ValByName("CN9_UNVIGE",_cUNVIGE)

		//Do Valor Global
		oHtml:ValByName("CN9_VLATU",Transform(CN9->CN9_VLATU,PesqPict("CN9","CN9_VLATU")))
		oHtml:ValByName("CN9_VLREXT",AllTrim(Lower(Extenso(CN9->CN9_VLATU))))

		// Abertura
		_cAttach  := GetTempPath()+"contrato_"+CN9->(Alltrim(CN9_NUMERO)+"_Rev"+Alltrim(CN9_REVISA))+".htm"
		oHtml:SaveFile( _cAttach )   // Salva Arquivo Html
		IF File("C:\Program Files\Internet Explorer\iexplore.exe")
			WinExec("C:\Program Files\Internet Explorer\iexplore.exe "+_cAttach)
		Else
			WinExec("C:\Arquivos de programas\Internet Explorer\iexplore.exe "+_cAttach)
		Endif

	Endif

Return()
