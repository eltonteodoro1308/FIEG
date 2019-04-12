#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} A100DEL
Impedir deletar nota caso Titulo sofra Transferencia; Verificar tamb�m avalia��o do fornecedor.

@type function
@author TOTVS FSW
@since 23/08/12
@version P12.1.23

@obs Projeto ELO

@history 22/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return lRet, retorna verdadeiro se valida��es OK.
/*/
/*/================================================================================================================================/*/

User Function A100DEL()

Local aArea 	:= GetArea()
Local lRet 		:= .T.
Local lPrjCni 	:= FindFunction("ValidaCNI") .And. ValidaCNI()
Local cAliasNw	:= "SE2_TMP"
Local cQuery

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If lPrjCni
	//Verifica se existem AF
	DbSelectArea("DBI")
	DBI->(DbSetOrder(2))
	If DBI->( DbSeek( xFilial("DBI") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_DOC + SF1->F1_SERIE  ) )
		Aviso("Aval. Fornecedores"," Exclus�o n�o permitida. Existe registro de avalia��o de fornecedor para a nota fiscal. ",{"Ok"})
		lRet := .F.
	EndIf

	dbSelectArea('SF1')

	cQuery := "Select E2_NUM  FROM " + RetSqlName("SE2")  + " WHERE E2_NUM = '" + SF1->F1_DUPL + "' AND E2_PREFIXO = '" + SF1->F1_PREFIXO + "' AND E2_NUMSOL <> '' "
	cQuery :=  cQuery + " AND E2_FILIAL = '" + SF1->F1_FILIAL + "' AND D_E_L_E_T_ <> '*' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNw,.F.,.T.)                  

	If !(cAliasNw)->(Eof())
		Alert("O T�tulo gerado por esta Nota Fiscal se encontra em processo de Transfer�ncia! Nota n�o poder� ser excluida! ")         
		lRet := .F.
	EndIf              

	(cAliasNw)->(dbCloseArea())

EndIf

RestArea(aArea)

Return lRet
