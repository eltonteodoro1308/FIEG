#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "TBICONN.CH"
#define CMD_OPENWORKBOOK			1
#define CMD_CLOSEWORKBOOK			2
#define CMD_ACTIVEWORKSHEET			3
#define CMD_READCELL				4

/*/================================================================================================================================/*/
/*/{Protheus.doc} AbreArq
Rotina de selecao e abertura do arquivos.

@type function
@author Thiago Rasmussen
@since 01/04/2009
@version P12.1.23

@param cTipo, Caractere, Tipo de extensao do arquivo a ser aberto.

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Arquivo selecionado.

/*/
/*/================================================================================================================================/*/

User Function AbreArq(cTipo)

	//+---------------------------------------------------------------------+
	//| Declaracao de Variaveis                                             |
	//+---------------------------------------------------------------------+
	//Local cTipo := Iif(cTipo==Nil ,"*",cTipo)
	Local cType	:= "Arquivos "+cTipo+"|*."+cTipo+"|Todos os Arquivos|*.*"
	Local cArq	:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cTipo := Iif(cTipo==Nil ,"*",cTipo)
	//+---------------------------------------------------------------------+
	//| Seleciona o arquivo                                                 |
	//+---------------------------------------------------------------------+
	cArq := cGetFile(cType, OemToAnsi("Selecione o arquivo."),0,"SERVIDOR\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

Return(cArq)

/*/================================================================================================================================/*/
/*/{Protheus.doc} RetCombo
Retorna o conteúdo do combo de um campo.

@type function
@author Thiago Rasmussen
@since
@version P12.1.23

@param cCampo, Caractere, Campo que contém o combo.
@param cChave, Caractere, Conteúdo do campo a ser retornado.

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Descrição do combo.

/*/
/*/================================================================================================================================/*/

User Function RetCombo(cCampo, cChave)

	Local aSx3Box	:= RetSx3Box( Posicione("SX3", 2, cCampo, "X3CBox()" ),,, 1 )

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

Return AllTrim( aSx3Box[aScan( aSx3Box, { |aBox| aBox[2] = cChave } )][3] )

/*/================================================================================================================================/*/
/*/{Protheus.doc} _SICFGCpo
Captura os campos informados no arquivo.

@type function
@author Thiago Rasmussen
@since 29/11/2011
@version P12.1.23

@param _cAlias, Caractere, Alias do Arquivo.

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Lista de Campos.

/*/
/*/================================================================================================================================/*/

User Function _SICFGCpo(_cAlias)
	Local _aRet  := {}
	Local _cMens := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cLine := FT_FREADLN()

	SX3->(dbSetOrder(2))
	While (_nPos  := At(";",_cLine)) > 0
		SX3->(dbGoTop())
		IF SX3->(dbSeek(Alltrim(Subs(_cLine,1,_nPos-1))))
			IF SX3->X3_ARQUIVO <> _cAlias
				_cMens += Alltrim(SX3->X3_CAMPO)+Chr(13)+Chr(10)
			ELSE
				Aadd(_aRet,Alltrim(SX3->X3_CAMPO))
			ENDIF
		ELSE
			_cMens += Alltrim(Subs(_cLine,1,_nPos-1))+Chr(13)+Chr(10)
		ENDIF
		_cLine := Subs(_cLine,_nPos+1,Len(_cLine)-_nPos)
		Skip()
	Enddo
	IF !Empty(_cLine)
		SX3->(dbGoTop())
		IF SX3->(dbSeek(Alltrim(_cLine)))
			IF SX3->X3_ARQUIVO <> _cAlias
				_cMens += Alltrim(SX3->X3_CAMPO)+Chr(13)+Chr(10)
			ELSE
				Aadd(_aRet,Alltrim(SX3->X3_CAMPO))
			ENDIF
		ELSE
			_cMens += Alltrim(_cLine)+Chr(13)+Chr(10)
		ENDIF
	ENDIF

	IF !Empty(_cMens)
		Aviso("Campos Inválidos","Os campos abaixo não existem no dicionário de dados ou não pertencem à tabela de "+Alltrim(GetAdvFVal("SX2","X2_NOME",_cAlias,1,""))+Chr(13)+Chr(10)+_cMens,{"Sair"},3)
		_aRet := {}
	ENDIF

	FT_FSKIP()
Return(_aRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} _SICFGLOG
Tratamento da mensagem de erro.

@type function
@author Thiago Rasmussen
@since 29/11/2011
@version P12.1.23

@param aErr, Array, Lista das mensagens de erro.
@param cLit, Caractere, descricao

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Lista de erros tratada.

/*/
/*/================================================================================================================================/*/

User Function _SICFGLOG( aErr, cLit )
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