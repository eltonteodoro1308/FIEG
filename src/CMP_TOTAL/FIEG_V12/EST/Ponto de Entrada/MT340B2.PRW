#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT340B2
Ponto de entrada para atualizar status do inventário para 3 após geração do ajuste de inventário.

@type function
@author Leonardo Soncin
@since 06/12/2011
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.
@history 08/05/2019, kley@TOTVS.com.br       , Inclusão de query para pesquisa do registro da SB7; antes fazia referência a um ALIAS padrão que foi descontinuado na V12.
/*/
/*/================================================================================================================================/*/

User Function MT340B2

//--< Declaracao de Variaveis >-----------------------------
Local aArea 	:= GetArea()
Local cAliasSQL	:= GetNextAlias()							// "SB7SQL"
Local cQuery	:= ""
Local cOrigem	:= "SIESTA01"

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cQuery := "select SB7.B7_COD, SB7.B7_LOCAL, SB7.B7_DOC"
cQuery +=  " from "+RetSqlName("SB7")+" SB7"
cQuery += " inner join "+RetSqlName("SB1")+" SB1"
cQuery +=    " on SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
cQuery +=   " and SB7.B7_FILIAL = '"+xFilial("SB7")+"'" 	// Junta a filial que está no relacionamento para melhora de desempenho do select
cQuery +=   " and SB1.B1_COD    = SB7.B7_COD"
cQuery +=   " and SB1.B1_GRUPO >= '"+mv_par09+"' and SB1.B1_GRUPO <= '"+mv_par10+"'"
cQuery +=   " and SB1.D_E_L_E_T_= ' '"
cQuery += " where SB7.B7_FILIAL = '"+xFilial("SB7")+"'"
cQuery +=   " and SB7.B7_DATA   = '"+DTOS(mv_par01)+"'"
cQuery +=   " and SB7.B7_COD   >= '"+mv_par05+"' and SB7.B7_COD   <= '"+mv_par06+"'"
cQuery +=   " and SB7.B7_LOCAL >= '"+mv_par07+"' and SB7.B7_LOCAL <= '"+mv_par08+"'"
cQuery +=   " and SB7.B7_DOC   >= '"+mv_par11+"' and SB7.B7_DOC   <= '"+mv_par12+"'"
cQuery +=   " and SB7.D_E_L_E_T_= ' '"
cQuery +=   " and SB7.B7_XORIGEM = '" + cOrigem + "'"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSQL,.F.,.T.)

(cAliasSQL)->(DbGoTop())

While !(cAliasSQL)->(Eof())

	dbSelectArea("SZK")
	dbSetOrder(1)
	If dbSeek(xFilial("SZK")+(cAliasSQL)->B7_DOC)
		If SZK->ZK_STATUS <> '3'
			RecLock("SZK",.F.)
				SZK->ZK_STATUS := "3"
			SZK->(MsUnLock())
		Endif
	Endif

	(cAliasSQL)->(dbSkip())

Enddo

If Select(cAliasSQL) > 0
	(cAliasSQL)->(dbCloseArea())
EndIf

RestArea(aArea)      

Return