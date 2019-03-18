#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} AF010TOK
Descrição detalhada da função.

@type function
@author Thiago Rasmussen
@since 02/09/2011
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function AF010TOK()
	Local _lRet     := .t.
	Local _cBase    := M->N1_CBASE
	Local _cItem    := M->N1_ITEM
	Local _cArea    := GetArea()
	Local _cAreaSX6 := SX6->(GetArea())
	
	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SN1->(dbSetOrder(1))
	IF INCLUI .and. SN1->(dbSeek(XFilial("SN1")+_cBase+_cItem)) .And. !FunName() == "ATFA240"

		While !SN1->(MsSeek(xFilial("SN1")+_cBase))
			_cBase := Soma1(_cBase)
			SN1->(dbSkip())
		EndDo

		M->N1_CBASE := _cBase
		Aviso("Atenção","O código do bem foi alterado para "+_cBase,{"Continuar"})
	ENDIF

	If (INCLUI) .And. !FunName() == "ATFA240"
		// Atualiza parametro

		GetMv("MV_CBASEAF")
		RecLock("SX6",.F.)
		FieldPut( FieldPos('X6_CONTEUD'), '"'+Soma1(Alltrim(_cBase))+'"' )
		FieldPut( FieldPos('X6_CONTSPA'), '"'+Soma1(Alltrim(_cBase))+'"' )
		FieldPut( FieldPos('X6_CONTENG'), '"'+Soma1(Alltrim(_cBase))+'"' )
		SX6->(MsUnLock())
	Endif

	RestArea(_cAreaSX6)
	RestArea(_cArea)
Return(_lRet)
