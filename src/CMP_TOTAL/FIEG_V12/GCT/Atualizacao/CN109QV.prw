#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN109QV
P.E. para adicionar query na função CNIA109v - Gestão de contratos.

@type function
@author Bruna Paola - TOTVS
@since 01/16/2012
@version P12.1.23

@param Parametro_01, Numérico, Informe a descrição do 1º parêmtro.

@obs Projeto ELO Alterado pela FIEG

@history 20/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, String com query.
/*/
/*/================================================================================================================================/*/

User Function CN109QV()

Local cProd   := PARAMIXB[1]  		 // Produto
Local dHoje   := PARAMIXB[2]  		 // Data
Local nQuant  := PARAMIXB[3]  		 // Quantidade
Local cQuery  := ""
Local cFilEmp := CFILANT 			 // Empresa/Unidade/Filial - Mascara = EEUUFFFF
Local cEmp    := SubStr(cFilEmp,1,2) // Empresa
Local cUnid   := SubStr(cFilEmp,3,2) // Unidade
Local cFil    := SubStr(cFilEmp,5,4) // Filial

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cQuery := " UNION "
cQuery += " SELECT CNB.CNB_SLDMED, CN9.CN9_NUMERO, CNA.CNA_FORNEC, CNB.CNB_VLUNIT, CNA.CNA_SALDO, CN9.CN9_FILIAL, CN9.CN9_REVISA, CNA.CNA_NUMERO, CNB.CNB_ITEM, CN9.CN9_DESCRI, CNA.CNA_LJFORN "
//cQuery += " SELECT CN9.CN9_NUMERO, CNA.CNA_FORNEC, CNB.CNB_VLUNIT, CNA.CNA_SALDO "
cQuery += " FROM "+RetSQLName("CNB")+" CNB, "+RetSQLName("CN9")+" CN9, "+RetSQLName("CNA")+" CNA, "+RetSQLName("CN1")+" CN1 , "+RetSQLName("PB1")+" PB1 , "+RetSQLName("PA9")+" PA9 "
cQuery += " WHERE CN9.CN9_FILIAL <> '"+xFilial("CN9")+"' "
cQuery += "	  and CNB.CNB_FILIAL <> '"+xFilial("CNB")+"' "
cQuery += "	  and CNA.CNA_FILIAL <> '"+xFilial("CNA")+"' "
cQuery += "	  and CN1.CN1_FILIAL <> '"+xFilial("CN1")+"' "
cQuery += "	  and CNB.CNB_FILIAL = CN9.CN9_FILIAL "
cQuery += "	  and CNB.CNB_FILIAL = CNA.CNA_FILIAL "
cQuery += "	  and CNB.CNB_CONTRA =	CN9.CN9_NUMERO "
cQuery += "	  and CNB.CNB_REVISA =	CN9.CN9_REVISA "
cQuery += "	  and CNB.CNB_CONTRA =	CNA.CNA_CONTRA  "
cQuery += "	  and CNB.CNB_REVISA =	CNA.CNA_REVISA "
cQuery += "	  and CNB.CNB_NUMERO =	CNA.CNA_NUMERO "
cQuery += "	  and CN9.CN9_TPCTO	 =	CN1.CN1_CODIGO "
cQuery += "	  and CN1.CN1_MEDEVE =	'1' "
cQuery += "	  and CN1.CN1_ESPCTR =	'1' "
cQuery += "	  and CNB.CNB_PRODUT = '"+cProd+"' "
cQuery += "	  and CN9.CN9_DTFIM	 >= '"+DTOS(dHoje)+"' "
cQuery += "	  and CN9.CN9_SITUAC =	'05' "
cQuery += "	  and CN9.CN9_XREGP	 =	'1' "
cQuery += "	  and CN9.CN9_FILIAL = PB1.PB1_FILCN9 "
cQuery += "	  and CN9.CN9_NUMERO =	'"+M->C1_XCONTPR+"'	"
cQuery += "	  and CNB.CNB_VLUNIT * "+ValToSQL(nQuant)+" <= CNA.CNA_SALDO "
cQuery += "	  and PB1.PB1_NUMERO = CN9.CN9_NUMERO "
cQuery += "	  and PB1.PB1_REVISA = CN9.CN9_REVISA "
cQuery += "	  and PB1.PB1_EMP    = '"+cEmp+"' "
cQuery += "	  and PB1.PB1_UNID   = '"+cUnid+"' "
cQuery += "	  and PB1.PB1_FIL    = '"+cFil+"' "
cQuery += "	  and PA9.PA9_NUMERO = PB1.PB1_NUMERO "
cQuery += "	  and PA9.PA9_REVISA = PB1.PB1_REVISA "
cQuery += "	  and PA9.PA9_FILCN9 = PB1.PB1_FILCN9 "
cQuery += "	  and CNB.D_E_L_E_T_ = ' ' "
cQuery += "	  and CNA.D_E_L_E_T_ = ' ' "
cQuery += "	  and PB1.D_E_L_E_T_ = ' ' "
cQuery += "	  and CN9.D_E_L_E_T_ = ' ' "
cQuery += "	  and PA9.D_E_L_E_T_ = ' ' "
//cQuery += "			ORDER BY CN9.CN9_NUMERO "

cQuery := '%' + cQuery + '%'

Return cQuery
