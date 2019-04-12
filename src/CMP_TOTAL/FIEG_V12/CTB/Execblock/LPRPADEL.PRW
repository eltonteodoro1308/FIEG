#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} LPRPADEL
Retorna valor do titulo de imposto inss patronal na exclusao do titulo.

@type function
@author Wagner Soares
@since 12/08/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Valor do titulo de imposto inss patronal.

/*/
/*/================================================================================================================================/*/

User Function LPRPADEL()
	Local aArea		:= GETAREA()
	Local aAreaSE2	:= SE2->(GETAREA())
	Local cTab		:= ""
	Local cQry		:= ""
	Local nVal		:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If TRIM(SE2->E2_PREFIXO)=="RPA" .and. TRIM(SE2->E2_TIPO)=="RPA"

		cTab:= GetNextAlias()

		cQry:= "SELECT COALESCE(E2_VALOR,0) AS INSPAT FROM " + RETSQLNAME("SE2")
		cQry+= " WHERE E2_FILIAL='"+SE2->E2_FILIAL+"'"
		cQry+= " AND E2_NUM='"+SE2->E2_NUM+"'"
		cQry+= " AND E2_PREFIXO='"+SE2->E2_PREFIXO+"'"
		cQry+= " AND E2_TIPO='INS'"
		cQry+= " AND E2_NATUREZ IN ('INSS')"
		cQry+= " AND E2_HIST LIKE '%PATRONAL%'"
		cQry+= " AND D_E_L_E_T_='*'"

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

/*/================================================================================================================================/*/
/*/{Protheus.doc} LPRPADEV
Funcao para controle de versao.

@type function
@author Thiago Rasmussen
@since 02/09/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Versão.

/*/
/*/================================================================================================================================/*/

User Function LPRPADEV()

	Local cRet  := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	
	cRet := "20140902001"

Return (cRet)