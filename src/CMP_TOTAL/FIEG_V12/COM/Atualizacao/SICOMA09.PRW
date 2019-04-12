#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA09
Validacao de Fornecedor no Edital.

@type function
@author Leonardo Soncin
@since 14/10/2011
@version P12.1.23

@obs Projeto ELO

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function SICOMA09()
	Local aArea := GetArea()
	Local cAliasTrb	:= GetNextAlias()
	Local lRet := .T.
	Local cFor  := GDFieldGet('CO3_CODIGO')
	Local cLoja := M->CO3_LOJA //GDFieldGet('CO3_LOJA')
	Local cTipo := GDFieldGet('CO3_TIPO')
	Local cEdital := M->CO1_CODEDT
	Local _cQuery := ""

	Local aList := {}
	Local oDlg
	Local oLbx
	Local cTitulo := "Regularidade Fiscal - Documentos pendentes"


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If cTipo == "2"

		/*
		_cQuery :=  "SELECT Z6_TIPDOC, Z6_DTVALID"
		_cQuery +=  " FROM "+RetSqlName("SZ6")
		_cQuery +=  " WHERE Z6_FILIAL = '"+xFilial("SZ6")+"' AND Z6_FORNECE = '"+cFor+"' AND D_E_L_E_T_ = ''"
		_cQuery +=  " AND (Z6_DTVALID < '"+DTOS(DDATABASE)+"' OR Z6_OBRIGAT = '1') "
		_cQuery := ChangeQuery(_cQuery)
		*/

		_cQuery := "SELECT DISTINCT ZI_TIPDOC,Z6_DTVALID FROM "+RetSqlName("CO1")+" CO1 "
		_cQuery += "INNER JOIN "+RetSqlName("SZI")+" SZI ON ZI_CODEDT = '"+cEdital+"' AND ZI_NUMPRO = CO1_NUMPRO "
		_cQuery += "LEFT OUTER JOIN "+RetSqlName("SZ6")+" SZ6 ON Z6_FORNECE = '"+cFor+"' AND Z6_TIPDOC = ZI_TIPDOC "
		_cQuery += "WHERE CO1.D_E_L_E_T_ = ' ' AND SZI.D_E_L_E_T_ = ' ' AND (SZ6.D_E_L_E_T_ = ' ' OR SZ6.D_E_L_E_T_ IS NULL) "
		_cQuery += "AND  ((Z6_DTVALID < '"+Dtos(dDataBase)+"' AND Z6_OBRIGAT = '1') OR (Z6_DTVALID IS NULL AND Z6_OBRIGAT IS NULL) ) "

		If Select(cAliasTrb) > 0
			dbSelectArea(cAliasTrb)
			dbCloseArea()
		Endif

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTrb,.T.,.F.)

		DbSelectArea(cAliasTrb)
		(cAliasTrb)->(dbGotop())

		// Carrega o vetor conforme a condicao.
		While (cAliasTrb)->(!Eof())
			aAdd( aList, (cAliasTrb)->( { ZI_TIPDOC, Posicione("SZ5",1,xFilial("SZ5")+ZI_TIPDOC,"Z5_DESC") ,Stod(Z6_DTVALID)} ) )
			(cAliasTrb)->(dbSkip())
		End

		If !Len( aList ) == 0

			DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL

			@ 10,10 LISTBOX oLbx FIELDS HEADER ;
			"Documento", "Descrição", "Vencimento" ;
			SIZE 230,95 OF oDlg PIXEL

			oLbx:SetArray( aList )
			oLbx:bLine := {|| {aList[oLbx:nAt,1],;
			aList[oLbx:nAt,2],;
			aList[oLbx:nAt,3]}}

			DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg CENTER

		Endif

	Endif

	(cAliasTrb)->(DbCloseArea())

	RestArea(aArea)

Return(lRet)
