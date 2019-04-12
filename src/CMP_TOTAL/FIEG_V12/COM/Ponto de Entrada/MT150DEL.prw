#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT150DEL
Descrição detalhada da função.

@type function
@author TOTVS
@since 13/10/2011
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT150DEL()

	Local aArea 	:= GetArea()
	Local cSQL 		:= ""
	Local lPrjCni	:= FindFunction("PRJCNI") .Or. GetRpoRelease("R6")

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If lPrjCni
		Public __lDelCot

		If __lDelCot != .T. 

			//--< Lucas Riva - CSA - 03/09/2013 - Ao excluir a cotação, seja por fornecedor/produto/cotação (sistema ja posiciona correto no SC1), >--
			//--< A SC precisa ter o numero de processo zerado para que possa ser reutilizada em um edital >--
			If !Empty(SC1->C1_NUMPR)
				RecLock("SC1",.F.)      
				SC1->C1_NUMPR := ""			
				SC1->(MsUnlock())			
			EndIf 

			cSQL += "C1_FILIAL = '" + xFilial("SC1") + "' "
			cSQL += "AND C1_COTACAO = '" + SC8->C8_NUM + "'"
			cSQL := "%" + cSQL + "%"

			//--< Caio.Santos - FSW - 06/02/2012 - Correcao estorno log exclusao cotacao >--
			//--< Filtra tabela com as SCs participantes da cotacao sendo excluida >--
			BeginSQL Alias "SC1COT"			//Esta tabela temporaria sera fechada no ponto de entrada posterior a exclusao de cotacao MT150END
				SELECT C1_NUM, C1_ITEM
				FROM %TABLE:SC1% SC1
				WHERE %Exp:cSQL% AND SC1.%NotDel%
			EndSQL

		EndIf
		__lDelCot := .T.
	EndIf

	RestArea(aArea)

Return
