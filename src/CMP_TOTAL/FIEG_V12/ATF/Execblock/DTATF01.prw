#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} DTATF01
Ponto de Entrada na confirmacao de inclusao / alteracao de um ativo fixo.

@type function
@author Thiago Rasmussen
@since 11/07/2014
@version P12.1.23

@param nlOpc, Numérico, Código do tipo de Opção.
@param uParam, Indefinido, Parâmetro enviado conforme o tipo de opção.

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Indefinido, Retorno da Função.

/*/
/*/================================================================================================================================/*/

User Function DTATF01( nlOpc, uParam )

	Local uRet

	Default nlOpc		:= 0
	Default uParam	:= Nil

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Do Case

		//--------------------------------------------------
		//- Processo para atualizacao de bens desmembrados -
		//- Pre-requisito: Deve eatar posicionado na SN1   -
		//--------------------------------------------------
		Case nlOpc == 1
		uRet := f_ClassAll( uParam )

		//-------------------------------------------------------------------------------
		//- Checa na nota de compra do bem se eh um item que atualiza e desmembra ativo -
		//-------------------------------------------------------------------------------
		Case nlOpc == 2
		uRet := f_IsAtfDes( uParam )

		//---------------------------------------------------------------------------
		//- Query de todos os bens que devem ser classificados conforme o bem atual -
		//---------------------------------------------------------------------------
		Case nlOpc == 3
		uRet := f_QryClass()

	EndCase

Return uRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} f_ClassAll
Função para o processo para atualizacao de bens desmembrados.

@type function
@author Thiago Rasmussen
@since 11/07/2014
@version P12.1.23

@param alParam, Array, Parâmetro recebido pelo Função

@obs Desenvolvimento FIEG

@return Lógico, Retorno da Função.

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.
@history 08/05/2019, elton.alves@TOTVS.com.br, Seek na tabela SN1 comentado pois na versão 12.1.23 a mesma já fica posicionada.
/*/
/*/================================================================================================================================/*/
Static Function f_ClassAll( alParam )

	Local clAlias
	Local clFilial
	Local clCodProd
	Local clNota
	Local clSerie
	Local clFornec
	Local clLoja
	Local clItem
	//Local llCriaAuto
	//Local clCodAnt
	//Local llClassifi
	//Local clAlias1
	//Local llGravaOk
	Local alAreaSN1	:= {}
	Local alAreaSN3	:= {}
	Local alInfoSN1
	Local alInfoSN3
	Local clChaveSN1
	Local llRet := .F.
	Local clChaveLog := ""
	Local clCBase := ""
	Local clCBItem := ""
	//Local llAchouSN1 := .F.

	Private apFieldSN1 := {}
	Private apFieldSN3 := {}

	Default alParam	:= {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("SN1")
	alAreaSN1 := SN1->( GetArea() )
	//SN1->(dbSetOrder(1))
	//IF SN1->(dbSeek(M->N1_FILIAL + M->N1_CBASE + M->N1_ITEM))
		nlRecnoAtu := SN1->(Recno())
	//ENDIF

	dbSelectArea("SN3")
	alAreaSN3 := SN3->(GetArea())

	IF nlRecnoAtu > 0
		clFilial  := SN1->N1_FILIAL
		clCodProd := SN1->N1_PRODUTO
		clNota    := SN1->N1_NFISCAL
		clSerie   := SN1->N1_NSERIE
		clFornec  := SN1->N1_FORNEC
		clLoja    := SN1->N1_LOJA
		clItem    := SN1->N1_NFITEM
		clCBase   := SN1->N1_CBASE
		clCBItem  := SN1->N1_ITEM

		//-------------------------------------------------------------------------------------------
		//- Se a nota utilizou TES de desmembra ativo, entao classifica todos os bens desemembrados -
		//-------------------------------------------------------------------------------------------
		IF f_IsAtfDes( {clFilial, clCodProd, clNota, clSerie, clFornec, clLoja, clItem} )

			clChaveLog := "Filial: '" + clFilial + "'" +  CRLF + "Cód. Base: '" + clCBase + "'" + CRLF + "Item: '" + clCBItem + "'"

			alInfoSN1 := f_InfoSN1()
			alInfoSN3 := f_InfoSN3( clFilial+clCBase+clCBItem )

			clAlias	:= f_NextAlia()
			BEGINSQL ALIAS clAlias

				SELECT
				DISTINCT SN1.R_E_C_N_O_ RECNOSN1

				FROM
				%TABLE:SD1% SD1

				INNER JOIN
				%TABLE:SN1% SN1 ON
				SN1.%NOTDEL%
				AND N1_FILIAL = D1_FILIAL
				AND N1_NFISCAL = D1_DOC
				AND N1_NSERIE = D1_SERIE
				AND N1_FORNEC = D1_FORNECE
				AND N1_LOJA = D1_LOJA
				AND N1_PRODUTO = D1_COD
				AND N1_NFITEM = D1_ITEM

				WHERE
				SD1.%NOTDEL%
				AND D1_FILIAL = %EXP:clFilial%
				AND D1_COD = %EXP:clCodProd%
				AND D1_DOC = %EXP:clNota%
				AND D1_SERIE = %EXP:clSerie%
				AND D1_FORNECE = %EXP:clFornec%
				AND D1_LOJA = %EXP:clLoja%
				AND D1_ITEM = %EXP:clItem%
				AND N1_DTCLASS = ' '

			ENDSQL

			BEGIN TRANSACTION

				llRet := .F.

				While ( clAlias )->( !Eof() )

					IF !( ( clAlias )->RECNOSN1 == SN1->( Recno() ) ) // Nao precisa atualizar o recno atual que esta sendo classificado pelo usuario

						SN1->( MsGoTo( ( clAlias )->RECNOSN1 ) )

						IF	( clAlias )->RECNOSN1 == SN1->( Recno() );
						.And. Empty( SN1->N1_DTCLASS ) // Ainda nao foi classificado

							clChaveSN1 := SN1->( N1_FILIAL+N1_CBASE+N1_ITEM )

							f_AtuSN1( alInfoSN1 ) // Atualiza registro da tabela SN1
							f_AtuSN3( alInfoSN3, clChaveSN1 ) // Atualiza registro da tabela SN3

						ENDIF

					ENDIF

					( clAlias )->( dbSkip() )
				EndDo

				llRet := .T.

			END TRANSACTION

			( clAlias )->( dbCloseArea() )

		ELSE
			llRet := .T.
		ENDIF

	ENDIF

	RestArea( alAreaSN1 )
	RestArea( alAreaSN3 )

	IF !llRet
		llRet := Aviso(	"ATENÇÃO",;
		"Houve problemas na classificação dos bens desmembrados. Se continuar, apenas o bem atual será classificado!" + CRLF +;
		"*** Acione o suporte para a analise do problema ***" + CRLF +;
		clChaveLog;
		, {"Continuar", "Cancelar"};
		,3) == 1
	ENDIF

Return llRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} f_AtuSN1
Atualiza registro da tabela SN1.

@type function
@author Thiago Rasmussen
@since 11/07/2014
@version P12.1.23

@param alInfoSN1, Array, Parâmetro recebido pelo Função

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function f_AtuSN1( alInfoSN1 )

	Local nlx

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("SN1")
	IF RecLock("SN1", .F.)
		SN1->N1_CHAPA := SN1->N1_CBASE
		FOR nlx := 1 TO LEN( alInfoSN1 )
			&( "SN1->"+alInfoSN1[nlx][1] ) := alInfoSN1[nlx][2]
		NEXT nlx

		SN1->( MsUnLock() )
	ENDIF

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} f_AtuSN3
Atualiza registro da tabela SN3.

@type function
@author Thiago Rasmussen
@since 11/07/2014
@version P12.1.23

@param alInfoSN3, Array, Parâmetro recebido pelo Função.
@param clChaveSN1, Caractere, Parâmetro recebido pelo Função.

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function f_AtuSN3( alInfoSN3, clChaveSN1 )

	Local nlx

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("SN3")
	SN3->( dbSetOrder( 1 ) ) // N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

	IF SN3->( MsSeek( clChaveSN1 ) )

		IF RecLock("SN3", .F.)

			FOR nlx := 1 TO LEN( alInfoSN3 )
				&( "SN3->"+alInfoSN3[nlx][1] ) := alInfoSN3[nlx][2]
			NEXT nlx

			SN3->( MsUnLock() )
		ENDIF

	ENDIF

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} f_IsAtfDes
Checa na nota de compra do bem se eh um item que atualiza e desmembra ativo.

@type function
@author Thiago Rasmussen
@since 11/07/2014
@version P12.1.23

@param alParam, Array, Parâmetro recebido pelo Função

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorno da Função.

/*/
/*/================================================================================================================================/*/
Static Function f_IsAtfDes( alParam )

	Local llRet := .F.
	Local nlTamParam := iif( ValType(alParam) == "A", Len( alParam ), 0)
	Local clAlias
	Local clFilial
	Local clCodProd
	Local clNota
	Local clSerie
	Local clFornec
	Local clLoja
	Local clItem

	Default alParam	:= {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	IF nlTamParam > 0
		clAlias   := f_NextAlia()
		clFilial  := IIF( nlTamParam > 0 .And. ValType( alParam[1] ) == "C", alParam[1],xFilial("SD1") )
		clCodProd := IIF( nlTamParam > 1 .And. ValType( alParam[2] ) == "C", alParam[2],"" )
		clNota    := IIF( nlTamParam > 2 .And. ValType( alParam[3] ) == "C", alParam[3],"" )
		clSerie   := IIF( nlTamParam > 3 .And. ValType( alParam[4] ) == "C", alParam[4],"" )
		clFornec  := IIF( nlTamParam > 4 .And. ValType( alParam[5] ) == "C", alParam[5],"" )
		clLoja    := IIF( nlTamParam > 5 .And. ValType( alParam[6] ) == "C", alParam[6],"" )
		clItem    := IIF( nlTamParam > 6 .And. ValType( alParam[7] ) == "C", alParam[7],"" )

		BEGINSQL ALIAS clAlias

			SELECT
			DISTINCT F4_ATUATF, F4_BENSATF

			FROM
			%TABLE:SD1% SD1

			INNER JOIN
			%TABLE:SN1% SN1 ON
			SN1.%NOTDEL%
			AND N1_FILIAL = D1_FILIAL
			AND N1_NFISCAL = D1_DOC
			AND N1_NSERIE = D1_SERIE
			AND N1_FORNEC = D1_FORNECE
			AND N1_LOJA = D1_LOJA
			AND N1_PRODUTO = D1_COD
			AND N1_NFITEM = D1_ITEM

			INNER JOIN
			%TABLE:SF4% SF4 ON
			SF4.%NOTDEL%
			AND F4_CODIGO = D1_TES

			WHERE
			SD1.%NOTDEL%
			AND D1_FILIAL = %EXP:clFilial%
			AND D1_COD = %EXP:clCodProd%
			AND D1_DOC = %EXP:clNota%
			AND D1_SERIE = %EXP:clSerie%
			AND D1_FORNECE = %EXP:clFornec%
			AND D1_LOJA = %EXP:clLoja%
			AND D1_ITEM = %EXP:clItem%

		ENDSQL

		IF ( clAlias )->( !Eof() );
		.And. ( clAlias )->F4_ATUATF == 'S'; 	// Atualiza Ativo Fixo
		.And.  ( clAlias )->F4_BENSATF == '1'	// Desmembra os bens 1 a 1

			llRet := .T.
		ENDIF

		( clAlias )->( dbCloseArea() )

	ENDIF

Return llRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} f_InfoSN1
Popula array com valores da tabela SN1 no registro posicionado.

@type function
@author Thiago Rasmussen
@since 11/07/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Retorno da Função.

/*/
/*/================================================================================================================================/*/
Static Function f_InfoSN1()

	Local alRet	:= {}
	Local nlx
	Local nlQtdFields

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//----------------------------------------
	//- Campos que não devem ser atualizados -
	//----------------------------------------
	apFieldSN1	:= {"N1_CBASE", "N1_ITEM", "N1_QUANT", "N1_CHAPA", "N1_CBASE", "N1_NFITEM"}

	dbSelectArea("SN1")
	nlQtdFields := SN1->( FCount() )

	FOR nlx := 1 TO nlQtdFields

		IF ASCAN(apFieldSN1, {|x| x == SN1->( FieldName(nlx) ) } ) == 0
			AADD( alRet, {SN1->( FieldName(nlx) ), SN1->&( FieldName(nlx) ) } )
		ENDIF

	NEXT nlx

Return alRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} f_InfoSN3
Checa na nota de compra do bem se eh um item que atualiza e desmembra ativo.

@type function
@author Thiago Rasmussen
@since 11/07/2014
@version P12.1.23

@param clChaveSN1, Caractere, Parâmetro recebido pelo Função

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Retorno da Função.

/*/
/*/================================================================================================================================/*/
Static Function f_InfoSN3( clChaveSN1 )

	Local alRet	:= {}
	Local nlx
	Local nlQtdFields

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//----------------------------------------
	//- Campos que NAO devem ser atualizados -
	//----------------------------------------
	apFieldSN3	:= {"N3_ITEM", "N3_VORIG1", "N3_VORIG2", "N3_VORIG3", "N3_VORIG4", "N3_CBASE"}

	dbSelectArea("SN3")
	nlQtdFields := SN3->( FCount() )
	SN3->( dbSetOrder( 1 ) ) // N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

	IF SN3->( MsSeek( clChaveSN1 ) )

		FOR nlx := 1 TO nlQtdFields

			IF ASCAN(apFieldSN3, {|x| x == SN3->( FieldName(nlx) ) } ) == 0
				AADD( alRet, {SN3->( FieldName(nlx) ), SN3->&( FieldName(nlx) ) } )
			ENDIF

		NEXT nlx

	ENDIF

Return alRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} f_QryClass
Query de todos os bens que devem ser classificados conforme o bem atual.

@type function
@author Thiago Rasmussen
@since 11/07/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Query de todos os bens que devem ser classificados conforme o bem atual.

/*/
/*/================================================================================================================================/*/
Static Function f_QryClass()

	Local clSQL   := ""
	//Local clAlias := f_NextAlia()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

Return clSQL

/*/================================================================================================================================/*/
/*/{Protheus.doc} f_NextAlia
Solicita o nome de um Alias disponível.

@type function
@author Thiago Rasmussen
@since 11/07/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 14/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Nome de um Alias disponível.

/*/
/*/================================================================================================================================/*/
Static Function f_NextAlia()

	Local clAlias := GetNextAlias()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	While Select( clAlias ) > 0
		clAlias	:= GetNextAlias()
	EndDo

Return clAlias