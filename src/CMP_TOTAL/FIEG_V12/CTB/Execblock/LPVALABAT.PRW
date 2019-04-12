#Include "Protheus.ch"
#Include "TopConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} LPVALABAT
Retornar o valor do titulo de AB- para contablização.

@type function
@author Wagner Soares
@since 13/08/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Valor do titulo de Abatimento.

/*/
/*/================================================================================================================================/*/

User Function LPVALABAT()
	Local aArea		:= GETAREA()
	Local aAreaSE2	:= SE2->(GETAREA())
	Local cTab		:= ""
	Local cQry		:= ""
	Local nVal		:= 0
	
	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cTab:= GetNextAlias()

	cQry:= "SELECT COALESCE(E2_VALOR,0) AS VALABAT FROM " + RETSQLNAME("SE2")
	cQry+= " WHERE E2_FILIAL='"+SE2->E2_FILIAL+"'"
	cQry+= " AND E2_NUM='"+SE2->E2_NUM+"'"
	cQry+= " AND E2_PREFIXO='"+SE2->E2_PREFIXO+"'"
	cQry+= " AND E2_TIPO='AB-'"
	cQry+= " AND D_E_L_E_T_=''"

	TcQuery cQry NEW ALIAS (cTab)
	(cTab)->(dbSelectArea((cTab)))
	(cTab)->(dbGoTop())
	If (cTab)->(!EOF())
		nVal:= (cTab)->VALABAT
	EndIf

	(cTab)->(DbCloseArea())


	RestArea(aAreaSE2)
	RestArea(aArea)
Return nVal

/*/================================================================================================================================/*/
/*/{Protheus.doc} LPVALABV
Descrição detalhada da função.

@type function
@author Thiago Rasmussen
@since 02/09/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Versão.

/*/
/*/================================================================================================================================/*/

User Function LPVALABV()

	Local cRet  := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cRet := "20140902001"

Return (cRet)