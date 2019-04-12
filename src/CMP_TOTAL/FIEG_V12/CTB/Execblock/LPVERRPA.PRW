#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} LPVERRPA
Retorna valor do titulo de imposto inss patronal.

@type function
@author Carlos Henrique
@since 03/04/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Valor do titulo de imposto inss patronal.

/*/
/*/================================================================================================================================/*/

User Function LPVERRPA()
	Local aArea		:= GETAREA()
	Local aAreaSE2	:= SE2->(GETAREA())
	Local cTab		:= ""
	Local cQry		:= ""
	Local nVal		:= 0
	
	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If TRIM(SE2->E2_PREFIXO)=="RPA" .and. TRIM(SE2->E2_TIPO)=="RPA"

		cTab:= GETNEXTALIAS()

		cQry:= "SELECT COALESCE(E2_VALOR,0) AS INSPAT FROM " + RETSQLNAME("SE2")
		cQry+= " WHERE E2_FILIAL='"+SE2->E2_FILIAL+"'"
		cQry+= " AND E2_NUM='"+SE2->E2_NUM+"'"
		cQry+= " AND E2_PREFIXO='"+SE2->E2_PREFIXO+"'"
		cQry+= " AND E2_TIPO='INS'"
		cQry+= " AND E2_NATUREZ IN ('INSS')"
		cQry+= " AND E2_HIST LIKE '%PATRONAL%'"
		cQry+= " AND D_E_L_E_T_=''"

		TcQuery cQry NEW ALIAS (cTab)
		(cTab)->(dbSelectArea((cTab)))
		(cTab)->(dbGoTop())
		If (cTab)->(!EOF())
			nVal:= (cTab)->INSPAT
		EndIf

		(cTab)->(DbCloseArea())
	EndIf

	RestArea(aAreaSE2)
	RestArea(aArea)
Return nVal