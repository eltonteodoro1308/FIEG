#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} M020ALT
Replica Fornecedor para Item Contábil.

@type function
@author Aderson Sousa - TOTVS
@since 11/11/2009
@version P12.1.23

@obs Desenvolvimento FIEG

@history 22/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function M020ALT()
        
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cAliasTrb	:= GetNextAlias()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cQuery :=  "SELECT Z6_TIPDOC "
cQuery +=  "FROM "+RetSqlName("SZ6")
cQuery +=  " WHERE Z6_FILIAL = '"+xFilial("SZ6")+"' AND "
cQuery +=  "Z6_FORNECE = '"+SA2->A2_COD+"' AND "
cQuery +=  "Z6_LOJA = '"+SA2->A2_LOJA+"' AND "
cQuery +=  "Z6_DTVALID < '"+Dtos(dDataBase)+"' AND "
cQuery +=  "D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)

If Select(cAliasTrb) > 0
	(cAliasTrb)->(dbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.F.)

(cAliasTrb)->(dbGotop())

If !(cAliasTrb)->(Eof())
	MsgStop("Existem documentos fiscais com prazo vencido para este fornecedor. Por favor verifique.", "Regularidade Fiscal")
Endif

RestArea(aArea)

Return()
