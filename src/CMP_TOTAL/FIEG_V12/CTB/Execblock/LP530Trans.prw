#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} LP530Trans
Programa para Contabilizar a Apropriacao dos impostos dos titulos de transferencia entre filiais.

@type function
@author Thiago Rasmussen
@since 25/07/13
@version P12.1.23

@param _cTipo, Caractere, Indica o tipo de valor a ser retornado.

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Valor requisitado.

/*/
/*/================================================================================================================================/*/

User Function LP530Trans(_cTipo)

	Local _nValor := 0
	Local _aAlias := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cQuery := "SELECT * "
	cQuery += "FROM " + RetSQLName('SE2') + " SE2 "
	cQuery += "WHERE SE2.D_E_L_E_T_ = ' ' "
	cQuery += "AND E2_FILIAL = '" +SE2->E2_XFILDES + "' "
	cQuery += "AND E2_PREFIXO = '" +SE2->E2_PREFIXO + "' "
	cQuery += "AND E2_NUM = '" + SE2->E2_NUM + "' "
	cQuery += "AND E2_PARCELA = '" + SE2->E2_PARCELA + "' "
	cQuery += "AND E2_TIPO = '" + SE2->E2_TIPO + "' "
	cQuery += "AND E2_FORNECE = '" + SE2->E2_FORNECE + "' "
	cQuery += "AND E2_LOJA = '" + SE2->E2_LOJA + "' "
	cQuery += "AND E2_XNUMTRF = '" + SE2->E2_XNUMTRF + "' "

	If Select("QRY") > 0
		DbSelectArea("QRY")
		QRY->(DbCloseArea())
	EndIf

	Query := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRY', .F., .T.)

	DbSelectArea("QRY")
	QRY->(DbGotop())

	If !Eof()
		If  _cTipo == "FORNEC"
			_nValor := QRY->E2_VALOR //+ QRY->E2_PIS + QRY->E2_COFINS + QRY->E2_CSLL + QRY->E2_IRRF + QRY->E2_INSS + QRY->E2_ISS -- Ajustado dia 12/09/14 a Pedido do Deuzimar para deixar os Lp´s 530/00, 531/000 e 532/00, pelo valor liquido da baixa.
		ElseIf _cTipo == "PCC"
			_nValor := QRY->E2_VRETPIS + QRY->E2_VRETCOF + QRY->E2_VRETCSL
		ElseIf _cTipo == "IRRF"
			_nValor := QRY->E2_IRRF
		ElseIf _cTipo == "INSS"
			_nValor := QRY->E2_INSS
		ElseIf _cTipo == "ISS"
			_nValor := QRY->E2_ISS
		Endif
	Endif

	QRY->(DbCloseArea())

	RestArea(_aAlias)

Return(_nValor)
