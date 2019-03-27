#Include "Protheus.ch"
#Include "TBICONN.CH"
#Include "COLORS.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"


/*/================================================================================================================================/*/
/*/{Protheus.doc} XPRENOTA
Função para retornar as justificativas de uma solicitação de compra.

@type function
@author Iatan Santos
@since 16/02/2016
@version P12.1.23

@param filial, Caractere, Filial da nota em questão
@param nota, Caractere, Nº da nota
@param serie, Caractere, Serie da nota em questão
@param emissao, Caractere, Data de emissão da nota em questão
@param fornecedor, Caractere, Fornecedor da nota em questão

@obs Desenvolvimento FIEG

@history 27/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Justificativas de uma solicitação de compra.

/*/
/*/================================================================================================================================/*/

User Function XPRENOTA(filial, nota, serie, emissao, fornecedor)

	Local justificativa := ''+CRLF+''+CRLF
	Local tempJustificativa := ''
	Local _cQuery := ""
	Local cAliasTMP1 := GetNextAlias()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	//CONSULTA PARA LISTAR TODAS AS SOLICITAÇÕES DE COMPRA VINCULADAS À PRE-NOTA SELECIONADA PARA A IMPRESSÃO
	_cQuery +=  "SELECT DISTINCT C1_FILIAL, C1_NUM, CAST(CAST(C1_XJUSTIF AS VARBINARY(8000))AS VARCHAR(8000)) AS C1_XJUSTIF "
	_cQuery +=  "FROM "+RetSqlName("SC1") + " WITH (NOLOCK) "
	_cQuery +=  "WHERE C1_FILIAL + C1_NUM IN (SELECT DISTINCT CASE WHEN RTRIM(C7_FISCORI) <> '' THEN C7_FISCORI ELSE C7_FILIAL END + C7_NUMSC "
	_cQuery +=  "                             FROM " + RetSqlName("SC7") + " WITH (NOLOCK) "
	_cQuery +=  "                             WHERE C7_FILIAL = '" + ALLTRIM(filial) + "' AND "
	_cQuery +=  "                                   C7_NUM + C7_CC IN (SELECT DISTINCT D1_PEDIDO + D1_CC "
	_cQuery +=  "                                                      FROM " + RetSqlName("SD1") + " WITH (NOLOCK) "
	_cQuery +=  "                                                      WHERE D1_FILIAL = '" + ALLTRIM(filial) + "' " + " AND "
	_cQuery +=  "                                                            D1_DOC = '" + nota + "' AND "
	_cQuery +=  "                                                            D1_SERIE = '" + serie + "' AND "
	_cQuery +=  "                                                            D1_FORNECE = '" + fornecedor + "' " + " AND "
	_cQuery +=  "                                                            D1_EMISSAO = '" + DTOS(emissao) + "' " + " AND "
	_cQuery +=  "                                                            D_E_L_E_T_ <> '*') AND "
	_cQuery +=  "                                   D_E_L_E_T_ <> '*') AND "
	_cQuery +=  "      D_E_L_E_T_ <> '*' "
	_cQuery +=  "ORDER BY 1, 2 "

	//NÃO É POSSÍVEL UTILIZAR O COMANDO "ChangeQuery()" NESTE CASO
	//POIS O COMANDO SQL "WITH (NOLOCK)" É ESPECÍFICO DO SQL SERVER.
	//_cQuery := ChangeQuery(_cQuery)

	IF Select(cAliasTMP1) > 0
		dbSelectArea(cAliasTMP1)
		(cAliasTMP1)->(dbCloseArea())
	ENDIF

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP1,.T.,.F.)

	DbSelectArea(cAliasTMP1)
	(cAliasTMP1)->(dbGotop())

	DO WHILE (cAliasTMP1)->(!EOF())
		justificativa += "Filial: " + ALLTRIM((cAliasTMP1)->C1_FILIAL) + " - " + "Solicitação: " + ALLTRIM((cAliasTMP1)->C1_NUM) + CRLF
		justificativa += "Justificativa: " + IIF(ALLTRIM(tempJustificativa) == ALLTRIM((cAliasTMP1)->C1_XJUSTIF), "Idem", ALLTRIM((cAliasTMP1)->C1_XJUSTIF)) + CRLF

		tempJustificativa := ALLTRIM((cAliasTMP1)->C1_XJUSTIF)
		(cAliasTMP1)->( DbSkip() )
	ENDDO

	(cAliasTMP1)->(dbCloseArea())

Return (justificativa)