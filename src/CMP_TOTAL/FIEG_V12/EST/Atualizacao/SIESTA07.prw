#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIESTA07
Ponto de Entrada para adicionar query na função A110LinOk.

@type function
@author Thiago Rasmussen
@since 01/16/12
@version P12.1.23

@obs Projeto ELO

@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Query a ser retornada.

/*/
/*/================================================================================================================================/*/

User Function SIESTA07 ()
	Local cProd  := PARAMIXB[1]  // Produto
	Local dHoje  := PARAMIXB[2]  // Data
	Local nQuant := PARAMIXB[3]  // Quantidade
	Local cQuery := ""
	Local cFilEmp := CFILANT // Empresa/Unidade/Filial - Mascara = EEUUFFFF
	Local cEmp   := SubStr(cFilEmp,1,2) // Empresa
	Local cUnid  := SubStr(cFilEmp,3,2) // Unidade
	Local cFil   := SubStr(cFilEmp,5,4) // Filial

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cQuery := " UNION "
	cQuery += " SELECT CN9.CN9_NUMERO, CNA.CNA_FORNEC, CNB.CNB_VLUNIT, CNA.CNA_SALDO "
	cQuery += " FROM "+RetSQLName("CNB")+" CNB, "+RetSQLName("CN9")+" CN9, "+RetSQLName("CNA")+" CNA, "+RetSQLName("CN1")+" CN1 , "+RetSQLName("PB1")+" PB1 , "+RetSQLName("PA9")+" PA9 "
	cQuery += " WHERE  CN9.CN9_FILIAL   <>   '"+xFilial("CN9")+"'	AND "
	cQuery += "			CNB.CNB_FILIAL  <>   '"+xFilial("CNB")+"'    AND   "
	cQuery += "			CNA.CNA_FILIAL  <>   '"+xFilial("CNA")+"'	AND   "
	cQuery += "			CN1.CN1_FILIAL  <>   '"+xFilial("CN1")+"'	AND   "
	cQuery += " 		CNB.CNB_FILIAL = CN9.CN9_FILIAL "
	cQuery += " 		AND CNB.CNB_FILIAL = CNA.CNA_FILIAL "
	cQuery += "  		AND CNB.CNB_FILIAL = CN1.CN1_FILIAL AND "
	cQuery += " 		CNB.CNB_CONTRA	=	CN9.CN9_NUMERO	AND "
	cQuery += "         CNB.CNB_REVISA	=	CN9.CN9_REVISA	AND "
	cQuery += " 		CNB.CNB_CONTRA	=	CNA.CNA_CONTRA	AND "
	cQuery += " 		CNB.CNB_REVISA	=	CNA.CNA_REVISA	AND "
	cQuery += " 		CNB.CNB_NUMERO	=	CNA.CNA_NUMERO	AND "
	cQuery += "			CN9.CN9_TPCTO	=	CN1.CN1_CODIGO	AND "
	cQuery += " 		CN1.CN1_MEDEVE	=	'1'				AND "
	cQuery += " 		CN1.CN1_ESPCTR	=	'1'				AND "
	cQuery += " 		CNB.CNB_PRODUT	= '"+cProd+"' AND "
	cQuery += "			CN9.CN9_DTFIM	>= '"+DTOS(dHoje)+"' AND "
	cQuery += "			CN9.CN9_SITUAC	=	'05'					AND "
	cQuery += "			CN9.CN9_XREGP	=	'1'			   			AND "
	cQuery += " 		CN9.CN9_FILIAL = PB1.PB1_FILCN9  AND "
	cQuery += "			CNB.CNB_VLUNIT * "+ValToSQL(nQuant)+" <= CNA.CNA_SALDO	AND "
	cQuery += "			PB1.PB1_NUMERO = CN9.CN9_NUMERO     AND "
	cQuery += "			PB1.PB1_REVISA = CN9.CN9_REVISA     AND "
	cQuery += "			PB1.PB1_EMP = '"+cEmp+"' AND "
	cQuery += " 		PB1.PB1_UNID = '"+cUnid+"' AND "
	cQuery += "			PB1.PB1_FIL = '"+cFil+"' AND "
	cQuery += " 		PA9.PA9_NUMERO = PB1.PB1_NUMERO "
	cQuery += "		    AND PA9.PA9_REVISA = PB1.PB1_REVISA "
	cQuery += "		    AND PA9.PA9_FILCN9 = PB1.PB1_FILCN9 AND"
	cQuery += "			CNB.D_E_L_E_T_ = ' ' AND "
	cQuery += "			CNA.D_E_L_E_T_ = ' ' AND "
	cQuery += "			PB1.D_E_L_E_T_ = ' ' AND "
	cQuery += "			CN9.D_E_L_E_T_ = ' ' AND "
	cQuery += "			PA9.D_E_L_E_T_ = ' ' "

	cQuery := '%' + cQuery + '%'

Return cQuery