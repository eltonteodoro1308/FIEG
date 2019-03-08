#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA17
Valida exclusao do tipo de documento.

@type function
@author Leonardo Soncin
@since 03/11/2011
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para se é permitido excluir tipo de documento.

/*/
/*/================================================================================================================================/*/

User Function SICOMA17()

	Local _lRet    := .t.
	Local _cQuery  := ""
	Local _cArea   := GetArea()
	Local _cArqTRB := CriaTrab(nil,.f.)


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cQuery := "SELECT SUM(QTDE) QTDE FROM ( "
	_cQuery += "SELECT COUNT(*) QTDE FROM "+RetSqlName("SZ6")+" "
	_cQuery += "WHERE D_E_L_E_T_ = ' ' AND Z6_TIPDOC = '"+SZ5->Z5_CODIGO+"' "
	_cQuery += "UNION ALL "
	_cQuery += "SELECT COUNT(*) QTDE FROM "+RetSqlName("SZI")+" "
	_cQuery += "WHERE D_E_L_E_T_ = ' ' AND ZI_TIPDOC = '"+SZ5->Z5_CODIGO+"' "
	_cQuery += ") BASE"
	_cQuery := ChangeQuery(_cQuery)

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqTRB,.t.,.t.)

	IF (_cArqTRB)->QTDE > 0
		Aviso("ATENÇÃO","Este registro possui amarração com outros cadastros. Verifique!",{"OK"})
		_lRet := .f.
	ENDIF

	(_cArqTRB)->(dbCloseArea())

	RestArea(_cArea)

Return(_lRet)
