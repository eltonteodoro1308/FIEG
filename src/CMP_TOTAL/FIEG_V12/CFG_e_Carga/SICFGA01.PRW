#Include "Protheus.Ch"
#Include "TopConn.Ch"
#Include "ApWizard.Ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICFGA01
Rotina de Carga de Dados.

@type function
@author Thiago Rasmussen
@since 29/11/2011
@version P12.1.23

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICFGA01()
	Local Titulo      := 'INTERFACE DE CARGA DE DADOS'
	Local _cVar       := ""
	Local lSegue      := .T.
	Private _cMsgLOG  := ""
	Private aRegErr   := {}
	Private cArq      := ""
	Private _nHandTXT := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF Len(_aRot := SICFG01Rot()) == 0
		lSegue := .F.
	ENDIF

	IF lSegue .And. !MsgYesNo("Confirma processamento ?")
		MsgStop("Processo abortado!")
		lSegue := .F.
	ENDIF

	If lSegue

		SZD->(dbSetOrder(1))
		SZD->(dbSeek(XFilial("SZD")+_aRot[1]))

		Processa( { || SICFG01Atu(cArq) }, Titulo , 'Atualizando...', .F. )

		If Len( aRegErr ) > 0
			SICFG01Imp(aRegErr,SZD->ZD_TABCAB)
		Else
			ApMsgInfo( 'Processo terminado.', 'ATENÇÃO' )
		EndIf

	EndIf

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICFG01Atu
Leitura CSV e atualização dos campos.

@type function
@author Thiago Rasmussen
@since 29/11/2011
@version P12.1.23

@param cArq, Caractere, Local e nome do arquivo CSV.

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function SICFG01Atu(cArq)
	Local _cArea   := GetArea()
	Local cBuffer  := ''
	Local nHandle  := -1
	Local nBtLidos := 0
	Local nCt      := 0
	Local nCnt     := 0
	Local _aDados  := {}
	Local nVlr3    := 0
	Local lSegue   := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	FT_FUSE(cArq)
	nCnt := FT_FLASTREC()
	FT_FGOTOP()

	IF Len(_aCampos := SICFG01Cpo(SZD->ZD_TABCAB,SZD->ZD_TABDET,SZD->ZD_EXECAUT=="1")) == 0
		RestArea(_cArea)
		lSegue := .F.
	ELSE

		SICFG01TXT(.t.)

		_cIndice := Alltrim(SZD->ZD_CHAVE)
		_aChave  := {}

		_nPos  := At("+",_cIndice)
		While !Empty(_cIndice) .And. _nPos > 0
			IF aScan(_aCampos, {|x| x[1] == Alltrim(Subs(_cIndice,1,_nPos-1))} ) == 0
				Aviso("ID Obrigatório","O campo "+Alltrim(Subs(_cIndice,1,_nPos-1))+" deve ser enviado no arquivo. Verifique!",{"Sair"},2)
				FT_FUSE()
				RestArea(_cArea)
				lSegue := .F.
				Exit
			ENDIF

			If lSegue

				Aadd(_aChave,Alltrim(Subs(_cIndice,1,_nPos-1)))
				_cIndice := Subs(_cIndice,_nPos+1,Len(_cIndice)-_nPos)
				_nPos  := At("+",_cIndice)
				If _nPos=0 .And. !Empty(_cIndice)
					_nPos := Len(_cIndice)+1
				Endif

			EndIf
			//Skip()
		Enddo

		IF lSegue

			If !Empty(_cIndice)
				IF aScan(_aCampos,{|x| x[1] == Alltrim(_cIndice)}) == 0
					Aviso("ID Obrigatório","O campo "+Alltrim(_cIndice)+" deve ser enviado no arquivo. Verifique!",{"Sair"},2)
					FT_FUSE()
					RestArea(_cArea)
					lSegue := .F.
				ENDIF

				If lSegue

					Aadd(_aChave,Alltrim(_cIndice))

				EndIf

			ENDIF

			If lSegue

				ProcRegua(nCnt)
				While !FT_FEof()

					_cLine := FT_FREADLN()

					IncProc("Carregando arquivo. Aguarde...")

					aadd(_aDados,Array(Len(_aCampos)))
					_nCol := 1
					_nPos := At(";",_cLine)
					While !Empty(_cLine) .And. _nPos > 0
						_aDados[Len(_aDados),aScan(_aCampos, {|x| x[3] == _nCol } )] := Subs(_cLine,1,_nPos-1)
						_cLine := Subs(_cLine,_nPos+1,Len(_cLine)-_nPos)
						_nCol++
						_nPos:=At(";",_cLine)
						If _nPos = 0 .And. !Empty(_cLine)
							_nPos:=Len(_cLine)+1
						Endif
					Enddo
					IF !Empty(_cLine) .or. _nCol <= Len(_aCampos)
						_aDados[Len(_aDados),aScan(_aCampos, {|x| x[3] == _nCol } )] := Alltrim(_cLine)
					ENDIF
					nCt++
					FT_FSKIP()
				Enddo
				FT_FUSE()

				// reinicia regua
				ProcRegua(nCnt)

				_cCampo  := ""
				_cCodAnt := ""
				_cCodAtu := ""
				aLinha   := {}
				aCab     := {}
				aItens   := {}

				For x := 1 to Len(_aDados)
					IncProc("Gerando informações. Aguarde...")

					IF !Empty(SZD->ZD_TABDET)
						_cCodAtu := ""
						For _xx := 1 to Len(_aChave)
							_cCodAtu += _aDados[x,aScan(_aCampos, {|x| x[1] == _aChave[_xx] } )]
						Next

						IF _cCodAnt <> "" .and. _cCodAnt <> _cCodAtu
							IF !SICFG01Inc(aCab,aItens,x-1)
								lSegue := .F.
								Exit
							ENDIF

							If lSegue

								aCab   := {}
								aItens := {}

							EndIf

						ENDIF
					ELSE
						aCab   := {}
						aItens := {}
					ENDIF

					If lSegue

						For y := 1 to Len(_aCampos)
							SX3->(dbSetOrder(2))
							SX3->(dbGoTop())
							SX3->(dbSeek(_aCampos[y,1]))
							IF SX3->X3_TIPO$("C/M")
								//				_cCampo := _aDados[x,y]
								_cCampo := PADR(_aDados[x,y],TamSx3(_aCampos[y,1])[1],' ')    // PADL incluido por Ana
							ELSEIF SX3->X3_TIPO == "N"
								IF Type(_aDados[x,y]) <> "N"
									Aviso("Tipo Inválido","O campo "+Alltrim(SX3->X3_CAMPO)+" da linha "+Alltrim(Str(x))+" está com tipo incorreto."+Chr(13)+Chr(10)+"O processo será abortado",{"Sair"},2)
									RestArea(_cArea)
									lSegue := .F.
									Exit
								ENDIF
								_cCampo := Val(_aDados[x,y])
							ELSEIF SX3->X3_TIPO == "D"
								_cCampo := Stod(_aDados[x,y])
							ENDIF
							IF SX3->X3_CONTEXT == "V"
								Loop
							ENDIF

							IF !Empty(SZD->ZD_TABDET)
								IF SZD->ZD_TABCAB == SX3->X3_ARQUIVO
									IF Ascan(aCab,{|x| Alltrim(x[1]) == Alltrim(_aCampos[y,1]) }) == 0 .and. _aCampos[y,1]$SZD->ZD_CHAVE
										aadd( aCab, {_aCampos[y,1],_cCampo, NIL} )
									ENDIF
									IF SZD->(ZD_TABCAB==ZD_TABDET) .and. !_aCampos[y,1]$SZD->ZD_CHAVE
										aadd( aLinha, {_aCampos[y,1],_cCampo, NIL} )
									ENDIF
								ELSE
									aadd( aLinha, {_aCampos[y,1],_cCampo, NIL} )
								ENDIF
							ELSE
								aadd( aCab, {_aCampos[y,1],_cCampo, NIL} )
							ENDIF
							If Alltrim(_aCampos[y,1]) == "N3_VORIG1"
								nVlr3 := _cCampo
							Endif
						Next

						If ! lSegue

							Exit

						Else

							//Campo obrigatório não constava no layout, por este motivo feito tratamento para inserir no cabeçalho.
							IF Ascan(aCab,{|x| Alltrim(x[1]) == Alltrim("N3_VORIG3")}) == 0 .And. SZD->ZD_TABCAB == "SN1"
								If nVlr3 > 0
									nVlr3 := nVlr3 / 0.8287  //Conversão do Valor 1 para Valor 3
								Endif
								aadd( aCab, {"N3_VORIG3",nVlr3, NIL} )
								aadd( aLinha, {"N3_VORIG3",nVlr3, NIL} )
							ENDIF

							If SZD->ZD_TABCAB == "SN2"
								aadd( aCab, {"N2_SEQ","", NIL} )
								aadd( aLinha, {"N2_SEQ","", NIL} )
							Endif

							IF !Empty(SZD->ZD_TABDET)

								aadd(aItens,aLinha)
								aLinha := {}

								_cCodAnt := ""
								For _xx := 1 to Len(_aChave)
									_cCodAnt += _aDados[x,aScan(_aCampos, {|x| x[1] == _aChave[_xx] } )]
								Next

							ELSE
								// Processa rotina automatica
								IF !SICFG01Inc(aCab,aItens,x)
									lSegue := .F.
									Exit
								ENDIF
							ENDIF

						Endif

					Endif

				Next

				If lSegue

					// Processa rotina automatica
					IF !Empty(SZD->ZD_TABDET) .and. Len(aCab) > 0
						IF !SICFG01Inc(aCab,aItens,x-1)
							lSegue := .F.
						ENDIF
					ENDIF

					If lSegue

						SICFG01TXT(.f.)

					EndIf

				EndIf

			EndIf

		EndIf

	ENDIF

	RestArea(_cArea)
Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICFG01Inc
Atualização Produto.

@type function
@author Thiago Rasmussen
@since 29/11/2011
@version P12.1.23

@param aCab, Array, Dados do Cabeçalho.
@param aItens, Array, Dados do Linha.
@param _nLinha, Número, Número da Linha.

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verifica se foi possível a atualização do Produto.

/*/
/*/================================================================================================================================/*/

Static Function SICFG01Inc(aCab,aItens,_nLinha)
	Local _cArea           := GetArea()
	Local _lRet            := .T.
	Local _cBkpFil         := cFilAnt  //Salva valor original da cFilAnt
	Private INCLUI         := .T.
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	_lExecAuto := SZD->ZD_EXECAUT=="1"

	// Troca de variaveis do execauto dos movimentos contábeis
	IF Alltrim(SZD->ZD_ROTINA) == "CTBA102"
		IF (_nPos := aScan(aCab,{|x| Alltrim(x[1]) == "CT2_DATA"})) > 0
			aCab[_nPos][1] := "DDATALANC"
		ENDIF
		IF (_nPos := aScan(aCab,{|x| Alltrim(x[1]) == "CT2_LOTE"})) > 0
			aCab[_nPos][1] := "CLOTE"
		ENDIF
		IF (_nPos := aScan(aCab,{|x| Alltrim(x[1]) == "CT2_SBLOTE"})) > 0
			aCab[_nPos][1] := "CSUBLOTE"
		ENDIF
		IF (_nPos := aScan(aCab,{|x| Alltrim(x[1]) == "CT2_DOC"})) > 0
			aCab[_nPos][1] := "CDOC"
		ENDIF
	ENDIF

	Begin Transaction

		If ( _nPosFil := Ascan(aCab,{|x| "_FILIAL" $ x[1] }) ) > 0 .and. !Empty(aCab[_nPosFil,2])
			_aAreaSM0 := SM0->(GetArea())
			_lFilOK := SM0->(MsSeek(cEmpAnt+aCab[_nPosFil,2]))
			RestArea(_aAreaSM0)

			IF !_lFilOK // Verifica se jogo de empresas é válido
				MsgStop("Empresa/Filial "+Alltrim(aCab[_nPosFil,2])+" inválida. Verifique!","Empresa/Filial")
				_lRet := .F.
			ELSE
				cFilAnt := aCab[_nPosFil,2] //Substitui cFilAnt pela filial do Arquivo
			ENDIF

		Endif

		IF _lRet // Processa

			IF Len(aItens) > 0 // rotinas com cabeçalho e item
				IF Alltrim(Upper(SZD->ZD_ROTINA)) == "MATA120"
					&(Alltrim(SZD->ZD_ROTINA)+"(1,aCab,aItens,3)")
				ELSE
					&(Alltrim(SZD->ZD_ROTINA)+"(aCab,aItens,3)")
				ENDIF
			ELSE
				IF _lExecAuto
					&(Alltrim(SZD->ZD_ROTINA)+"(aCab,3)")
				ELSE

					(SZD->ZD_TABCAB)->(dbSetOrder(1))
					_cIndice := (SZD->ZD_TABCAB)->(IndexKey())
					If SZD->ZD_TABCAB == "SND" .Or. SZD->ZD_TABCAB == "CT2"  .Or. SZD->ZD_TABCAB == "SC7" //	Ana, para a tabela SND o campo ND_SEQUENC nao pode constar na chave de busca,
						//pois este campo é gerado pelo sistema na inclusão do registros
						//CT2: No indice do SIX possui DTOS e precisa ser lido sem o DTOS.
						_cIndice := Alltrim(SZD->ZD_CHAVE)
					Endif
					_cChave  := ""
					_cFilial := ""

					_nPos := At("+",_cIndice)
					While !Empty(_cIndice) .And. _nPos > 0
						IF !("FILIAL"$Alltrim(Subs(_cIndice,1,_nPos-1)))
							If ValType(aCab[aScan(aCab,{|x| Upper(AllTrim(x[1])) == Upper(Subs(_cIndice,1,_nPos-1))}),2]	) == "D"
								_cChave += Dtos(aCab[aScan(aCab,{|x| Upper(AllTrim(x[1])) == Upper(Subs(_cIndice,1,_nPos-1))}),2])  //Tratamento para data no Indice.
							Else
								_cChave += aCab[aScan(aCab,{|x| Upper(AllTrim(x[1])) == Upper(Subs(_cIndice,1,_nPos-1))}),2]
							Endif
						ELSE
							_cFilial := Subs(_cIndice,1,_nPos-1)
						ENDIF
						_cIndice := Subs(_cIndice,_nPos+1,Len(_cIndice)-_nPos)
						_nPos := At("+",_cIndice)
						If _nPos = 0 .And. !Empty(_cIndice)
							_nPos := Len(_cIndice)+1
						Endif
					Enddo
					IF !Empty(_cIndice)
						_cChave := aCab[aScan(aCab,{|x| Upper(AllTrim(x[1])) == Upper(Alltrim(_cIndice))}),2]
					ENDIF

					IF (SZD->ZD_TABCAB)->(dbSeek(XFilial(SZD->ZD_TABCAB)+_cChave))
						DisarmTransaction()
						aAdd( aRegErr, {StrZero(_nLinha,5), {"Registro já cadastrado na base de dados"} } )
						Break
					ELSE
						RecLock(SZD->ZD_TABCAB,.T.)
						&((SZD->ZD_TABCAB)->(FieldName(1))) := XFilial(SZD->ZD_TABCAB)
						For i := 1 to Len(aCab)
							If 	(((SZD->ZD_TABCAB)+"->"+aCab[i,1]) == "SND->ND_SEQUENC" ) .Or. (((SZD->ZD_TABCAB)+"->"+aCab[i,1]) == "SN2->N2_SEQ" )    //Ana: Este campo é gerado pela função NextSNDSeq
								If SZD->ZD_TABCAB == "SND"
									cSequencia:=NextSNDSEQ(SND->ND_CBASE,SND->ND_ITEM)
								ElseIf 	SZD->ZD_TABCAB == "SN2"
									cSequencia:=Substr(NextSNDSEQ(SN2->N2_CBASE,SN2->N2_ITEM),4,3)
								Endif
								&((SZD->ZD_TABCAB)+"->"+aCab[i,1]) := cSequencia
							Else
								&((SZD->ZD_TABCAB)+"->"+aCab[i,1]) := IIF("_FILIAL" $ aCab[i,1],XFilial(SZD->ZD_TABCAB),aCab[i,2]) // aCab[i,2]
							Endif
						Next
						(SZD->ZD_TABCAB)->(msUnlock())
					ENDIF

				ENDIF
			ENDIF

			IF _lExecAuto
				If lMsErroAuto
					If (__lSX8)
						RollBackSX8()
					EndIf

					DisarmTransaction()

					// Tratamento da Mensagem de erro do MSExecAuto
					aLogErr  := GetAutoGRLog()
					aLogErr2 := SICFG01Log( aLogErr, "" )
					aAdd( aRegErr, {StrZero(_nLinha,5), aLogErr2 } )

					// Alimenta LOG
					//_cMsgLOG += IIF(Empty(_cMsgLOG),"",CRLF+CRLF)
					//_cMsgLOG += StrZero(_nLinha,5)+Space(3)
					FWrite(_nHandTXT, StrZero(_nLinha,5)+Space(3))
					For nI := 1 To Len( aLogErr2 )
						//_cMsgLOG += IIF(nI==1,"",Space(8))+aLogErr2[nI]+CRLF
						FWrite(_nHandTXT,IIF(nI==1,"",Space(8))+aLogErr2[nI]+CRLF)
					Next

					Break
				Else

					If (__lSX8)
						ConfirmSX8()
					EndIf

				EndIf
			ENDIF
		ENDIF

	End Transaction

	cFilAnt := _cBkpFil
	RestArea(_cArea)
Return(_lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICFG01Imp
Relatorio de Inconsistencias.

@type function
@author Thiago Rasmussen
@since 29/11/2011
@version P12.1.23

@param aRegErr, Array, Lista de inconsístências.
@param _cAlias, Caractere, Alias da tabela.

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function SICFG01Imp(aRegErr,_cAlias)
	Local lSegue      := .T.
	// Variaveis de Impressao
	Private cDesc1    := 'Atualização '+Alltrim(GetAdvFVal("SX2","X2_NOME",_cAlias,1,""))
	Private cDesc2    := ''
	Private cDesc3    := ''
	Private Cabec1      := ''
	Private Cabec2      := ''
	Private aOrd        := {}
	Private Titulo      := 'RELATORIO DE INCONSISTENCIAS'
	Private aMeses      := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ''
	Private Limite      := 132
	Private Tamanho     := 'M'
	Private NomeProg    := 'SICFG01Imp'
	Private nTipo       := 18
	Private aReturn     := { 'Zebrado', 1, 'Administracao', 2, 1, 1, '', 1}
	Private nLastKey    := 0
	Private Cbcont      := 00
	Private m_pag       := 01
	Private wnrel       := 'SICFG01Imp'

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	//+---------------------------------------------------------------------+
	//| Monta a interface padrao com o usuario...                           |
	//+---------------------------------------------------------------------+
	wnrel := SetPrint( _cAlias, NomeProg,, @Titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho,, .F. )

	If nLastKey == 27
		lSegue := .F.
	EndIf

	If lSegue

		SetDefault( aReturn, _cAlias )

		If nLastKey == 27
			lSegue := .F.
		EndIf

		If lSegue

			RptStatus( { || RunReport( aRegErr ) }, Titulo )

		EndIf

	EndIf

Return NIL

/*/================================================================================================================================/*/
/*/{Protheus.doc} RunReport
Processamento do Relatorio.

@type function
@author Thiago Rasmussen
@since 29/11/2011
@version P12.1.23

@param aRegErr, Array, Lista de inconsístências.

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function RunReport( aRegErr )
	Local nI := 0
	Local nJ := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	SetPrc( 80, 1 )

	For nI := 1 To Len( aRegErr )

		Cabec1 := 'Linha  Erro'

		If PRow() > 55
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
		Endif

		@ PRow()+1, 0 PSay ''
		@ PRow(),000 PSay aRegErr[nI][1]

		nPrxCol := 7

		For nJ := 1 To Len( aRegErr[nI][2] )

			If PRow() > 56
				Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
			Endif

			If nJ > 1
				@PRow()+1, 0 PSay ''
			EndIf

			@PRow(), nPrxCol PSay aRegErr[nI][2][nJ]
		Next
		@PRow()+1, 0 PSay ''
	Next

	If PRow() <> 80
		Roda( cbcont, cbtxt, Tamanho )
	EndIf

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool( wnrel )
	Endif

	MS_FLUSH()

Return NIL

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICFG01Cpo
Captura os campos informados no arquivo.

@type function
@author Thiago Rasmussen
@since 29/11/2011
@version P12.1.23

@param _cAliasH, Caractere, Alias do Cabeçalho.
@param _cAliasD, Caractere, Alias do Detalhe.
@param _lExecAuto, Lógico, Indica se é execauto.

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Campos informados no arquivo.

/*/
/*/================================================================================================================================/*/

Static Function SICFG01Cpo(_cAliasH,_cAliasD,_lExecAuto)
	Local _aRet  := {}
	Local _cMens := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	_cLine := FT_FREADLN()
	_nPos  := At(";",_cLine)
	SX3->(dbSetOrder(2))
	While !Empty(_cLine)  .And. _nPos > 0

		SX3->(dbGoTop())
		IF SX3->(dbSeek(Alltrim(Upper(Subs(_cLine,1,_nPos-1))))) .and. Alltrim(SX3->X3_CAMPO) == Alltrim(Upper(Subs(_cLine,1,_nPos-1)))
			IF !(SX3->X3_ARQUIVO$_cAliasH) .and. !(SX3->X3_ARQUIVO$_cAliasD)
				_cMens += Alltrim(SX3->X3_CAMPO)+Chr(13)+Chr(10)
			ELSE
				Aadd(_aRet,{Alltrim(SX3->X3_CAMPO),SX3->X3_ORDEM,Len(_aRet)+1})
			ENDIF
		ELSE
			_cMens += Alltrim(Subs(_cLine,1,_nPos-1))+Chr(13)+Chr(10)
		ENDIF
		_cLine := Subs(_cLine,_nPos+1,Len(_cLine)-_nPos)
		_nPos  := At(";",_cLine)
		If _nPos = 0 .And. !Empty(_cLine)
			_nPos := Len(_cLine)+1
		Endif
		//Skip()
	Enddo
	IF !Empty(_cLine)
		SX3->(dbGoTop())
		IF SX3->(dbSeek(Alltrim(_cLine))) .and. Alltrim(SX3->X3_CAMPO) == Alltrim(Upper(_cLine))
			IF !(SX3->X3_ARQUIVO$_cAliasH) .and. !(SX3->X3_ARQUIVO$_cAliasD)
				_cMens += Alltrim(SX3->X3_CAMPO)+Chr(13)+Chr(10)
			ELSE
				Aadd(_aRet,{Alltrim(SX3->X3_CAMPO),SX3->X3_ORDEM,Len(_aRet)+1})
			ENDIF
		ELSE
			//Os campos abaixo não estão no layout porem são necessarios.
			If _cAliasH == "SN1"
				SX3->(dbSeek(Alltrim("N3_VORIG3"))) //.and. Alltrim(SX3->X3_CAMPO) == Alltrim(Upper("N3_VORIG3"))
				Aadd(_aRet,{Alltrim(SX3->X3_CAMPO),SX3->X3_ORDEM,Len(_aRet)+1})
			Endif
			If _cAliasH == "SN2"
				SX3->(dbSeek(Alltrim("N2_SEQ"))) //.and. Alltrim(SX3->X3_CAMPO) == Alltrim(Upper("N2_SEQ"))
				Aadd(_aRet,{Alltrim(SX3->X3_CAMPO),SX3->X3_ORDEM,Len(_aRet)+1})
			Endif

			_cMens += Alltrim(_cLine)+Chr(13)+Chr(10)
		ENDIF
	ENDIF

	// ordena campos conforme dicionario
	ASORT(_aRet,,, { |x, y| x[2] < y[2] })

	IF !Empty(_cMens)
		Aviso("Campos Inválidos","Os campos abaixo não existem no dicionário de dados ou não pertencem ao cadastro selecionado."+Chr(13)+Chr(10)+_cMens,{"Sair"},3)
		_aRet := {}
	ELSE
		// Alias do Header
		SX3->(dbSetOrder(1))
		SX3->(dbSeek(_cAliasH))
		While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == _cAliasH
			IF X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. X3OBRIGAT(Alltrim(SX3->X3_CAMPO)) .and. IIF(_lExecAuto,.f.,!Empty(SX3->X3_RELACAO)) .and. aScan(_aRet, {|x| x[1] == Alltrim(SX3->X3_CAMPO)}) == 0
				_cMens += Alltrim(SX3->X3_CAMPO)+Chr(13)+Chr(10)
			ENDIF
			SX3->(dbSkip())
		Enddo

		// Alias do Detail, quando existir
		IF !Empty(_cAliasD)
			SX3->(dbGoTop())
			SX3->(dbSetOrder(1))
			SX3->(dbSeek(_cAliasD))
			While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == _cAliasD
				IF X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .and. X3OBRIGAT(Alltrim(SX3->X3_CAMPO)) .and. IIF(_lExecAuto,.f.,!Empty(SX3->X3_RELACAO)) .and. aScan(_aRet, {|x| x[1] == Alltrim(SX3->X3_CAMPO)} ) == 0
					_cMens += Alltrim(SX3->X3_CAMPO)+Chr(13)+Chr(10)
				ENDIF
				SX3->(dbSkip())
			Enddo
		ENDIF

		IF !Empty(_cMens)
			Aviso("Campos Obrigatórios","Os campos abaixo são obrigatórios e não foram localizados no arquivo."+Chr(13)+Chr(10)+_cMens,{"Sair"},3)
			_aRet := {}
		ENDIF
	ENDIF

	FT_FSKIP()
Return(_aRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICFG01Log
Tratamento da mensagem de erro.

@type function
@author Thiago Rasmussen
@since 29/11/2011
@version P12.1.23

@param aErr, Array, Lista de erros do Execauto.
@param cLit, Caractere, Compatibiliade.

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Mensagem de erro tratada.

/*/
/*/================================================================================================================================/*/

Static Function SICFG01Log( aErr, cLit )
	Local lHelp   := .F.
	Local lTabela := .F.
	Local cLinha  := ""
	Local aRet    := {}
	Local nI      := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	For nI := 1 to LEN( aErr)
		cLinha  := UPPER( aErr[nI] )
		cLinha  := STRTRAN( cLinha,CHR(13), " " )
		cLinha  := STRTRAN( cLinha,CHR(10), " " )

		If SUBS( cLinha, 1, 4 ) == 'HELP'
			lHelp := .T.
		EndIf

		If SUBS( cLinha, 1, 6 ) == 'TABELA'
			lHelp   := .F.
			lTabela := .T.
		EndIf

		If  lHelp .or. ( lTabela .AND. '< -- INVALIDO' $  cLinha )
			aAdd( aRet,  cLinha )
		EndIf

	Next

Return aRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICFG01Rot
Lista de rotinas.

@type function
@author Thiago Rasmussen
@since 29/11/2011
@version P12.1.23

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Rotina selecionada.

/*/
/*/================================================================================================================================/*/

Static Function SICFG01Rot()
	Local cExt      := "Arquivo CSV | *.CSV"
	Local cPath     := "Selecione diretório"
	Local _aRotinas := {}
	Local _aRet     := ""
	Local nOpc      := 0
	Local lSegue    := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	SZD->(dbSetOrder(1))
	SZD->(dbGoTop())

	While !SZD->(Eof()) .and. SZD->ZD_FILIAL == XFilial("SZD")
		Aadd(_aRotinas,{SZD->ZD_ROTINA,IIF(SZD->ZD_EXECAUT=="1","Sim","Não"),SZD->ZD_DESC})
		SZD->(dbSkip())
	Enddo

	IF Len(_aRotinas) == 0
		ApMsgInfo( 'Não existem rotinas cadastradas para carga de dados.', 'ATENÇÃO' )
		lSegue := .F.
	ELSE
		DEFINE MSDIALOG oDlg TITLE "Selecione a Rotina" From 001,001 To 020,070 OF oMainWnd
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_BOTTOM

		DEFINE SBUTTON FROM 004,200 TYPE 1 ACTION (_aRet := {_aRotinas[oQual:nAt,1],_aRotinas[oQual:nAt,2]},nOpc := 1,oDlg:End()) ENABLE OF oPanel
		DEFINE SBUTTON FROM 004,240 TYPE 2 ACTION (oDlg:End()) ENABLE OF oPanel PIXEL

		@ .5,.80 LISTBOX oQual VAR _cVar Fields HEADER OemToAnsi("Rotina"),OemToAnsi("ExecAuto"),OemToAnsi("Descrição") SIZE 130,42  NOSCROLL
		oQual:SetArray(_aRotinas)
		oQual:bLine := { || {_aRotinas[oQual:nAT,1],_aRotinas[oQual:nAT,2],_aRotinas[oQual:nAT,3]}}

		oQual:Align := CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oDlg CENTERED
	ENDIF

	If lSegue .And. nOpc <> 1
		lSegue := .F.
	EndIf

	IF lSegue .And. Empty(cArq:=cGetFile(cExt,cExt))
		MsgStop("Arquivo não informado. Verifique!")
		lSegue := .F.
	ENDIF

	IF lSegue .And. At(Space(1),Alltrim(cArq)) <> 0
		Alert("Nome do arquivo inválido. Retire os espaços do nome do arquivo/diretório!")
		lSegue := .F.
	ENDIF

	IF lSegue .And. !File(cArq)
		Alert("O arquivo informado não existe. Verifique!")
		lSegue := .F.
	ENDIF

Return(_aRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICFG01TXT
Gravacao de LOG de processamento.

@type function
@author Thiago Rasmussen
@since 08/08/2012
@version P12.1.23

@param _lCabec, Lógico, Indica se é cabeçalho.

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function SICFG01TXT(_lCabec)
	Local _cDir    := "C:\TEMP\"
	Local _cFile   := "carga"+Dtos(Date())+StrTran(Time(),":","")+".log"
	Local _cMsgLOG := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	IF _lCabec
		IF !lIsDir( _cDir )
			//Cria diretorio
			IF !MontaDir( _cDir ) // Verifica se criou o diretorio
				Count("CARGA --> Erro na criação do diretorio "+_cDir+". Consulte ADM do Sistema!")
				Return()
			ENDIF
		ENDIF

		_nHandTXT := FCreate(_cDir + _cFile)

		If _nHandTXT == -1
			MsgStop("Erro na criacao do arquivo na estacao local. Contate o administrador do sistema")
			Return
		EndIf

		_cMsgLOG += Replicate( "-", 128 ) + CRLF
		_cMsgLOG += Replicate( " ", 128 ) + CRLF
		_cMsgLOG += "LOG DE IMPORTACAO "+Alltrim(SZD->ZD_DESC) + CRLF
		_cMsgLOG += Replicate( " ", 128 ) + CRLF
		_cMsgLOG += Replicate( "-", 128 ) + CRLF
		_cMsgLOG += CRLF
		_cMsgLOG += " Dados Ambiente" + CRLF
		_cMsgLOG += " --------------------"  + CRLF
		_cMsgLOG += " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt  + CRLF
		_cMsgLOG += " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
		_cMsgLOG += " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
		_cMsgLOG += " DataBase...........: " + DtoC( dDataBase )  + CRLF
		_cMsgLOG += " Data / Hora Inicio.: " + DtoC( Date() )  + " / " + Time()  + CRLF
		_cMsgLOG += " Usuario TOTVS .....: " + __cUserId + " " +  cUserName + CRLF
		_cMsgLOG += Replicate( "-", 128 ) + CRLF
		_cMsgLOG += CRLF
		_cMsgLOG += 'Linha   Erro'

		FWrite(_nHandTXT, _cMsgLOG)
	ELSE
		IF Len( aRegErr ) == 0
			_cMsgLOG += CRLF
			_cMsgLOG += " *** Não foram encontradas inconsistências *** "
			_cMsgLOG += CRLF
		ENDIF
		_cMsgLOG += CRLF
		_cMsgLOG += Replicate( "-", 128 ) + CRLF
		_cMsgLOG += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
		_cMsgLOG += Replicate( "-", 128 ) + CRLF

		FWrite(_nHandTXT, _cMsgLOG)

		FClose(_nHandTXT)

		//	MemoWrite( _cDir+_cFile, _cMsgLOG )
	ENDIF

Return()
