#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} M103XFIN
Ponto de Entrada para verificar se os titulos com mutuo efetivado.

@type function
@author TOTVS
@since 11/11/2009
@version P12.1.23

@obs Desenvolvimento FIEG

@history 22/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return _aRet, Retorna array com verdadeiro no primeiro vetor se validações OK.
/*/
/*/================================================================================================================================/*/

User Function M103XFIN()

Local _aRet    := {.t.,ParamIXB[1],ParamIXB[2]}
Local _cArea   := GetArea()
Local _cQuery  := ""
Local _cArqTRB := CriaTrab(nil,.f.)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
_cQuery := "SELECT R_E_C_N_O_ FROM "+RetSqlName("SE2")+" WHERE E2_FILIAL = '"+xFilial("SE2")+"' AND D_E_L_E_T_= ' ' AND "
_cQuery += "E2_FORNECE = '"+SF1->F1_FORNECE+"' AND E2_LOJA = '"+SF1->F1_LOJA+"' AND E2_PREFIXO = '"+SF1->F1_PREFIXO+"' "
_cQuery += "AND E2_NUM = '"+SF1->F1_DUPL+"' AND E2_XMUTUO <> ' ' AND E2_XSTATUS = '2'"
_cQuery := ChangeQuery(_cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqTRB,.t.,.t.)

If !(_cArqTRB)->(Eof())
	Aviso("Atencao","Existem parcelas com rateio de mútuo finalizado. Verifique!",{"Voltar"})
	_aRet[1] := .F.
EndIf

(_cArqTRB)->(dbCloseArea())

FErase(_cArqTRB+GetDBExtension())
FErase(_cArqTRB+OrdBagExt())

RestArea(_cArea)

Return(_aRet)
