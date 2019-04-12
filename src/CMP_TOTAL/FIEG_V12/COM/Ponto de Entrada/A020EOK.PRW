#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} A020EOK
Replica Fornecedor para Item Contábil.

@type function
@author Aderson Sousa
@since 11/11/2009
@version P12.1.23

@obs Projeto ELO

@history 22/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return lRet, retorna verdadeiro se validações OK.
/*/
/*/================================================================================================================================/*/

User Function A020EOK()
        
Local aArea 	:= GetArea()
Local cQuery	:= ""
Local cAliasTrb	:= GetNextAlias()
Local lRet 		:= .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cQuery :=  "SELECT Z6_TIPDOC "
cQuery +=  "FROM "+RetSqlName("SZ6")
cQuery +=  " WHERE Z6_FILIAL = '"+xFilial("SZ6")+"' AND "
cQuery +=  "Z6_FORNECE = '"+SA2->A2_COD+"' AND "
cQuery +=  "Z6_LOJA = '"+SA2->A2_LOJA+"' AND "
cQuery +=  "D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)

If Select(cAliasTrb) > 0
	(cAliasTrb)->(dbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.F.)

DbSelectArea(cAliasTrb)
(cAliasTrb)->(dbGotop())

If !(cAliasTrb)->(Eof())
	MsgStop("Este fornecedor possui documentos associados. Favor excluir os documentos associados.","Regularidade Fiscal")
	lRet := .F.	
Endif

RestArea(aArea)

Return(lRet)
