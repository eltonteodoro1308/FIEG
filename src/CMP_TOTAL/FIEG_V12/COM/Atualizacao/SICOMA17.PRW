#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA17
Valida exclusao do tipo de documento.

@type function
@author Leonardo Soncin - TOTVS
@since 03/11/2011
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações forem OK.
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
_cQuery := "select sum(QTDE) QTDE from ( "
_cQuery += "select count(*) QTDE FROM "+RetSqlName("SZ6")+" "
_cQuery += "where D_E_L_E_T_ = ' ' and Z6_TIPDOC = '"+SZ5->Z5_CODIGO+"' "
_cQuery += "union all "
_cQuery += "select COUNT(*) QTDE FROM "+RetSqlName("SZI")+" "
_cQuery += "WHERE D_E_L_E_T_ = ' ' and ZI_TIPDOC = '"+SZ5->Z5_CODIGO+"' "
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
