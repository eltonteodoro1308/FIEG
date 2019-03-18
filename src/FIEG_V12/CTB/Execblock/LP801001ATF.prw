#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} LP801001ATF
Retorno Valor líquido do Item da Nota Fiscal.

@type function
@author Thiago Rasmussen
@since 07/11/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Valor líquido do Item da Nota Fiscal.

/*/
/*/================================================================================================================================/*/

User Function LP801001ATF

	Local _RETORNO := 0
	Local _ALIAS   := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	
	cQuery := "SELECT (D1_QUANT * D1_VUNIT) - D1_VALDESC AS TOTAL FROM " + RetSQLName('SD1') + " SD1 WITH (NOLOCK) " +;
	"WHERE D1_FILIAL = '" + SN1->N1_FILIAL + "' AND " +;
	"      RTRIM(LTRIM(D1_DOC)) = '" + ALLTRIM(SN1->N1_NFISCAL) + "' AND " +;
	"      RTRIM(LTRIM(D1_SERIE)) = '" + ALLTRIM(SN1->N1_NSERIE) + "' AND " +;
	"      D1_FORNECE = '" + SN1->N1_FORNEC + "' AND " +;
	"      D1_LOJA = '" + SN1->N1_LOJA + "' AND " +;
	"      D1_ITEM = '" + SN1->N1_NFITEM + "' AND " +;
	"      D1_COD = '" + SN1->N1_PRODUTO + "' AND " +;
	"      D_E_L_E_T_ = ' ' ";

	IF Select("QRY") > 0
		QRY->(DbSelectArea("QRY"))
		QRY->(DbCloseArea())
	ENDIF

	Query := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRY', .F., .T.)

	DbSelectArea("QRY")
	QRY->(DbGotop())

	IF !EOF()
		_RETORNO := QRY->TOTAL
	ENDIF

	QRY->(DbCloseArea())

	RestArea(_ALIAS)

Return(_RETORNO)