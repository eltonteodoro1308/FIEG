#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIFISA07
Cadastro de Prefeitura x Aliquota Servico ( Modelo 3 ).

@type function
@author Antonio Marcos Andriani
@since 04/06/2010
@version P12.1.23

@param cAliasCab, Caractere, Alias do arquivo usado no Cabeçalho.
@param cAliasItem, Caractere, Alias Alias do arquivo usado no Item.
@param nRecNo, Numérico, Numero do registro posicionado( recno() ).
@param nOpc, Numérico, Tipo da Operacao: 1-Pesquisa / 2-Visualizar / 3-Inclusao / 4-Alteracao / 5-Exclusao.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIFISA07( cAliasCab, cAliasItem, nRecNo, nOpc )

	Local nX        := 0
	Local oDlg      := Nil
	Local lInclui	:= If( nOpc == 3, .T., .F. )
	Local lAltera	:= If( nOpc == 4, .T., .F. )
	Local lExclui	:= If( nOpc == 5, .T., .F. )
	Local lVisual	:= If( !lInclui .and. !lAltera .and. !lExclui, .T., .F. )
	Local aPosObj  	:= {}
	Local aObjects 	:= {}
	Local aSize    	:= {}
	Local aPosGet  	:= {}
	Local aInfo    	:= {}
	Local nOpcA		:= 0
	Private aTela   := {}
	Private aGets   := {}
	Private aHeader := {}
	Private aCols   := {}
	Private bCampo  := {|nField| FieldName(nField) }
	Private bWhile	:= {}
	Private cChave	:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+--------------------------------------------------------------+
	//| Cria Variaveis de Memoria da Enchoice                        |
	//+--------------------------------------------------------------+
	DBSelectArea(cAliasCab)
	For nX := 1 To FCount()
		If lInclui
			M->&(Eval(bCampo,nX)) := CriaVar(FieldName(nX),.T.)
		Else
			M->&(Eval(bCampo,nX)) := FieldGet(nX)
		Endif
	Next nX

	//+--------------------------------------------------------------+
	//| Cria aHeader conforme alias passado                          |
	//+--------------------------------------------------------------+
	aHeader := CriaHeader( cAliasItem )

	//+--------------------------------------------------------------+
	//| Monta acols conforme alias e aHeader passado                 |
	//+--------------------------------------------------------------+
	If lInclui
		aCols := CarIncCols( cAliasItem, aHeader )
	Else
		cChave	:= xFilial( "SZ9" ) + M->(Z8_ESTADO+M->Z8_COD_MUN)
		bWhile	:= { || xFilial("SZ9") == SZ9->Z9_FILIAL .and. SZ9->Z9_ESTADO == M->Z8_ESTADO .and. SZ9->Z9_COD_MUN == M->Z8_COD_MUN }
		aCols 	:= CargaCols( aHeader, cAliasItem, 1, cChave, bWhile  )
	Endif

	//+------------------------------------------------------+
	//| Faz o calculo automatico de dimensoes de objetos     |
	//+------------------------------------------------------+
	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 100, 100, .t., .t. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,;
	{{003,033,160,200,240,263}} )

	//+--------------------------------------------------------------+
	//| Carregar Tela de Prefeituras x Aliquotas de Servicos         |
	//+--------------------------------------------------------------+
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

	EnChoice( cAliasCab, nRecNo, nOpc, , , , , aPosObj[1], , 3)

	//      MsGetDados():New(          nTop,        nLeft,      nBottom,         nRight,nOpc,  [cLinhaOk],    [cTudoOk], [cIniCpos], [lDelete], [aAlter], [uPar1], [lEmpty], [nMax], [cFieldOk], [cSuperDel], [uPar2], [cDelOk], [oWnd])
	oGet := MSGetDados():New( aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],nOpc,"AllwaysTrue()", "U_SIFISA08",          ,.T.      ,         ,        ,         ,      , "U_SIFISA09" )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA:=1,If(Obrigatorio(aGets,aTela).and.U_SIFISA08(),oDlg:End(),nOpca:=0)},{||nOpca:=0,oDlg:End()})

	If nOpcA == 1

		Begin Transaction
			GravaDados( nOpc )
		End Transaction

	Endif

Return( Nil )

/*/================================================================================================================================/*/
/*/{Protheus.doc} GravaDados
Executa a gravacao das Tabelas de Cabecalho (SZ8) e Itens (SZ9) do Cadastro de Prefeitura x Aliquota servico.

@type function
@author Antonio Marcos Andriani
@since 04/06/2010
@version P12.1.23

@param nOpc, Numérico, Tipo da Operacao: 1-Pesquisa / 2-Visualizar / 3-Inclusao / 4-Alteracao / 5-Exclusao.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function GravaDados( nOpc )
	Local lInclui	:= If( nOpc == 3, .T., .F. )
	Local lAltera	:= If( nOpc == 4, .T., .F. )
	Local lExclui	:= If( nOpc == 5, .T., .F. )
	Local lVisual	:= If( !lInclui .and. !lAltera .and. !lExclui, .T., .F. )
	Local lAchou	:= .F.
	Local nx		:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If !lVisual

		If lExclui
			RecLock( "SZ8", .F. )
			DBDelete()
			SZ8->(MsUnlock())
		Else
			If lInclui
				RecLock( "SZ8", .T. )
				Z8_FILIAL	:= xFilial( "SZ8" )
				Z8_COD_MUN	:= M->Z8_COD_MUN
				Z8_ESTADO	:= M->Z8_ESTADO
				SZ8->(MsUnlock())
			Endif
			RecLock( "SZ8", .F. )
			Z8_PREFEIT	:= M->Z8_PREFEIT
			Z8_END		:= M->Z8_END
			Z8_CNPJ		:= M->Z8_CNPJ
			Z8_DTINSC	:= M->Z8_DTINSC
			SZ8->(MsUnlock())
		Endif

		//+--------------------------------------------------------------+
		//| Efetua gravacao de todos os itens da Getdados                |
		//+--------------------------------------------------------------+
		For nx := 1 to Len( aCols )

			lAchou := SZ9->( DBSeek( xFilial( "SZ9" ) + M->(Z8_ESTADO+M->Z8_COD_MUN) + aCols[ nx, aScan( aHeader, { |x| alltrim( x[2] ) == "Z9_CODSERV" } ) ] ) )

			//+--------------------------------------------------------------+
			//| Faz tratamento para exclusao                                 |
			//+--------------------------------------------------------------+
			If ( ( aCols[ nx, Len( aHeader ) +1 ] .and. lAltera ) .or. lExclui ) .and. lAchou

				RecLock( "SZ9", .F. )
				DBDelete()
				SZ9->(MsUnLock())

				//+--------------------------------------------------------------+
				//| Faz tratamento para inclusao ou alteracao                    |
				//+--------------------------------------------------------------+
			Elseif !aCols[ nx, Len( aHeader ) +1 ]

				//+--------------------------------------------------------------+
				//| Somente em caso de inclusao gravar a chave do registro       |
				//+--------------------------------------------------------------+
				If !lAchou
					RecLock( "SZ9", .T. )
					SZ9->Z9_FILIAL	:= xFilial("SZ9")
					SZ9->Z9_COD_MUN	:= M->Z8_COD_MUN
					SZ9->Z9_ESTADO	:= M->Z8_ESTADO
					SZ9->Z9_CODSERV	:= aCols[ nx, aScan( aHeader, { |x| alltrim( x[2] ) == "Z9_CODSERV" } ) ]
					SZ9->(MsUnLock())
				Endif

				//+--------------------------------------------------------------+
				//| Faz a gravacao dos demais campos tanto para inclusao quanto  |
				//| para alteracao.                                              |
				//+--------------------------------------------------------------+
				RecLock( "SZ9", .F. )
				SZ9->Z9_ALIQ	:= aCols[ nx, aScan( aHeader, { |x| alltrim( x[2] ) == "Z9_ALIQ"    } ) ]
				SZ9->(MsUnLock())

			Endif

		Next

	Endif

Return( Nil )

/*/================================================================================================================================/*/
/*/{Protheus.doc} CriaHeader
Rotina para carregar variavel array aHeader baseada no SX3 do Alias passado no parametro.

@type function
@author Antonio Marcos Andriani
@since 04/06/2010
@version P12.1.23

@param _cAlias, Caractere, Alias do arquivo a ser usado na getdados.
@param _cCpoExc, Caractere, String com os campos que não deverão aparecer na Getdados mesmo estando marcados como 'browse' no arquivo SX3.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, aHeader baseada no SX3 do Alias.

/*/
/*/================================================================================================================================/*/

Static Function CriaHeader( _cAlias, _cCpoExc )
	Local _aHeader 		:= {}
	Local _nUsado		:= 0

	Default _cCpoExc	:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DBSelectArea( "SX3" )
	SX3->(DBSeek( _cAlias ))

	While SX3->(!Eof()) .and. X3_ARQUIVO == _cAlias

		If X3USO( X3_USADO ) .and. cNivel >= X3_NIVEL .and. !( Alltrim( X3_CAMPO ) $ _cCpoExc )
			_nUsado++
			AADD( _aHeader, { 	Trim( X3Titulo() ),;
			X3_CAMPO    ,;
			X3_PICTURE  ,;
			X3_TAMANHO  ,;
			X3_DECIMAL  ,;
			X3_VALID    ,;
			X3_USADO    ,;
			X3_TIPO     ,;
			X3_ARQUIVO  ,;
			X3_CONTEXT  } )
		Endif

		SX3->(DBSkip())

	Enddo

Return( _aHeader )

/*/================================================================================================================================/*/
/*/{Protheus.doc} CarIncCols
Rotina que carrega a variavel array aCols com valores iniciais na inclusao do registro.

@type function
@author Antonio Marcos Andriani
@since 04/06/2010
@version P12.1.23

@param _cAlias, Caractere, Alias do arquivo a ser usado na Getdados.
@param _aHeader, Array, Variavel array com o Header do Alias a ser usado.
@param _cCpoItem, Caractere, Variavel opcional caso exista um campo que precise ser numerado sequencialmente, informar nessa variavel o nome.
@param _nTamCpoItem, Numérico, Tamanho do campo sequencial item ( ExpC3 ). O Default e 3.
@param _cCpoExc, Caractere, String com os campos que nao deverao aparecer na Getdados mesmo estando marcados como 'browse' no arquivo SX3.

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, aCols com valores iniciais.

/*/
/*/================================================================================================================================/*/

Static Function CarIncCols( _cAlias, _aHeader, _cCpoItem, _nTamCpoItem, _cCpoExc )
	Local _aArea			:= GetArea()
	Local _nUsado			:= 0
	Local _aCols			:= {}

	Default _cCpoItem		:= ""
	Default _nTamCpoItem	:= 3
	Default _cCpoExc		:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DBSelectArea( "SX3" )
	SX3->(DBSeek( _cAlias ))
	aAdd( _aCols, Array( Len( _aHeader ) +1 ) )

	Do While SX3->(!Eof()) .and. X3_ARQUIVO == _cAlias

		If X3USO( X3_USADO ) .and. cNivel >= X3_NIVEL .and. !( Alltrim(X3_CAMPO) $ _cCpoExc )

			_nUsado++
			If X3_TIPO == "C"
				If Trim(aHeader[_nUsado][2]) == _cCpoItem
					_aCols[ 1, _nUsado ] := StrZero( 1, _nTamCpoItem )
				Else
					_aCols[ 1, _nUsado ] := Space( X3_TAMANHO )
				Endif
			Elseif X3_TIPO == "N"
				_aCols[ 1, _nUsado ] := 0
			Elseif X3_TIPO == "D"
				_aCols[ 1, _nUsado ] := dDataBase
			Elseif X3_TIPO == "M"
				_aCols[ 1, _nUsado ] := CriaVar( AllTrim( X3_CAMPO ) )
			Else
				_aCols[ 1, _nUsado ] := .F.
			Endif
			If X3_CONTEXT == "V"
				_aCols[ 1, _nUsado ] := CriaVar( AllTrim( X3_CAMPO ) )
			Endif

		Endif

		SX3->(DBSkip())

	Enddo

	_aCols[ 1, _nUsado +1 ] := .F.

	RestArea( _aArea )

Return( _aCols )

/*/================================================================================================================================/*/
/*/{Protheus.doc} CargaCols
Rotina para carregar os dados de um determinado alias ( baseado no Header ) para a Getdados usada ( alteracao, exclusao, visual ).

@type function
@author Antonio Marcos Andriani
@since 11/12/2009
@version P12.1.23

@param _aHeader, , descricao
@param _cAlias, , descricao
@param _nIndice, , descricao
@param _cChave, , descricao
@param _bWhile, , descricao
@param _cCpoExc, , descricao

@obs Projeto ELO

@history 21/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, aCols populado.

/*/
/*/================================================================================================================================/*/

Static Function CargaCols( _aHeader, _cAlias, _nIndice, _cChave, _bWhile, _cCpoExc  )
	Local _aArea		:= GetArea()
	Local _nUsado		:= 0
	Local _nCnt			:= 0
	Local _aCols		:= {}

	Default _cCpoExc	:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DBSelectArea( _cAlias )
	( _cAlias )->(DBSetOrder( _nIndice ))
	( _cAlias )->(DBSeek( _cChave ))

	Do While Eval( _bWhile )

		aAdd( _aCols, Array( Len( _aHeader ) +1 ) )
		_nCnt++
		_nUsado := 0
		DBSelectArea( "SX3" )
		SX3->(DBSeek( _cAlias ))

		Do While SX3->(!Eof()) .and. X3_ARQUIVO == _cAlias

			If X3USO( X3_USADO ) .and. cNivel >= X3_NIVEL .and. !( Alltrim(X3_CAMPO) $ _cCpoExc )
				_nUsado++
				_cVarTemp := _cAlias + "->" + ( X3_CAMPO )
				If X3_CONTEXT # "V"
					_aCols[ _nCnt, _nUsado ] := &_cVarTemp
				Elseif X3_CONTEXT == "V"
					_aCols[ _nCnt, _nUsado ] := CriaVar( AllTrim( X3_CAMPO ) )
				Endif
			Endif

			SX3->(DBSkip())

		Enddo

		_aCols[ _nCnt, _nUsado + 1 ] := .F.
		DBSelectArea( _cAlias )
		( _cAlias )->(DBSkip())

	Enddo

	RestArea( _aArea )

Return( _aCols )
