#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CNIA109A
P.E. para adicionar query na fun��o CNIA109c. Gest�o de contratos

@type function
@author Bruna Paola - TOTVS
@since 01/16/2012
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Caractere, String com query.
/*/
/*/================================================================================================================================/*/

User Function CN109QC() 

Local cProd   := PARAMIXB[1]  			// Produto
Local dHoje   := PARAMIXB[2]  			// Data
Local cQuery  := ""   
Local cFilEmp := CFILANT 				// Empresa/Unidade/Filial - Mascara = EEUUFFFF
Local cEmp    := SubStr(cFilEmp,1,2) 	// Empresa
Local cUnid   := SubStr(cFilEmp,3,2) 	// Unidade
Local cFil    := SubStr(cFilEmp,5,4) 	// Filial

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
//cQuery += "			CN1.CN1_FILIAL  <>   '"+xFilial("CN1")+"'	AND   " 
//cQuery += " 		AND CNB.CNB_FILIAL = CN1.CN1_FILIAL AND"

cQuery := " union " 
cQuery += " select CN9.CN9_FILIAL, CN9.CN9_NUMERO, CN9.CN9_REVISA, CN9.CN9_DESCRI, CNA.CNA_FORNEC, CNA.CNA_LJFORN, CNB.CNB_VLUNIT, "
cQuery += "   CNB.CNB_SLDREC, CNA.CNA_NUMERO, CNB.CNB_ITEM, CNB.CNB_SLDMED "
cQuery += " from "+RetSQLName("CNB")+" CNB, "+RetSQLName("CN9")+" CN9, "+RetSQLName("CNA")+" CNA, "+RetSQLName("CN1")+" CN1 , "+RetSQLName("PB1")+" PB1 , "+RetSQLName("PA9")+" PA9 "
cQuery += " where CN9.CN9_FILIAL <> '"+xFilial("CN9")+"' "
cQuery += "	  and CNB.CNB_FILIAL <> '"+xFilial("CNB")+"' "
cQuery += "	  and CNA.CNA_FILIAL <> '"+xFilial("CNA")+"' "
cQuery += "   and CNB.CNB_FILIAL = CN9.CN9_FILIAL"
cQuery += "   and CNB.CNB_FILIAL = CNA.CNA_FILIAL "
cQuery += "   and CNB.CNB_CONTRA =	CN9.CN9_NUMERO "
cQuery += "   and CNB.CNB_REVISA =	CN9.CN9_REVISA "
cQuery += "   and CNB.CNB_CONTRA =	CNA.CNA_CONTRA "
cQuery += "   and CNB.CNB_REVISA =	CNA.CNA_REVISA " 
cQuery += "   and CNB.CNB_NUMERO =	CNA.CNA_NUMERO "
cQuery += "	  and CN9.CN9_TPCTO	 =	CN1.CN1_CODIGO "
cQuery += "   and CN1.CN1_MEDEVE =	'1'	"
cQuery += "   and CN1.CN1_ESPCTR =	'1'	"
cQuery += "   and CNB.CNB_PRODUT = '"+cProd+"' " 
cQuery += "	  and CN9.CN9_DTFIM	 >= '"+DTOS(dHoje)+"' "
cQuery += "	  and CN9.CN9_SITUAC =	'05' "
cQuery += "	  and CN9.CN9_XREGP	 =	'1' " 
cQuery += "   and CN9.CN9_FILIAL = PB1.PB1_FILCN9 "
cQuery += "	  and PB1.PB1_NUMERO = CN9.CN9_NUMERO "
cQuery += "	  and PB1.PB1_REVISA = CN9.CN9_REVISA" 
cQuery += "	  and PB1.PB1_EMP    = '"+cEmp+"' "
cQuery += "   and PB1.PB1_UNID   = '"+cUnid+"' "
cQuery += "	  and PB1.PB1_FIL    = '"+cFil+"' "  
cQuery += "	  and PA9.PA9_NUMERO = PB1.PB1_NUMERO "
cQuery += "	  and PA9.PA9_REVISA = PB1.PB1_REVISA "
cQuery += "   and PA9.PA9_FILCN9 = PB1.PB1_FILCN9 "
cQuery += "	  and CNB.D_E_L_E_T_ = ' ' "
cQuery += "	  and CNA.D_E_L_E_T_ = ' ' " 
cQuery += "   and PB1.D_E_L_E_T_ = ' ' " 
cQuery += "   and CN9.D_E_L_E_T_ = ' ' "
cQuery += "   and PA9.D_E_L_E_T_ = ' ' "
//cQuery += " 		ORDER BY CN9.CN9_NUMERO,CN9.CN9_NUMERO "

cQuery := '%' + cQuery + '%'

Return cQuery