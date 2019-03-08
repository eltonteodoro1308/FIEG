#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN100SIT
Ponto de Entrada apos alteracao da situcao do contrato.

@type function
@author Thiago Rasmussen
@since 22/11/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CN100SIT()
	Local _cLanctoCT := Alltrim(GetNewPar("SI_PCOCTSC","900051"))
	Local _cNewSit   := ParamIXB[2] // 01 - Cancelado
	Local lPrjCni    := FindFunction("ValidaCNI") .And. ValidaCNI()
	Local lExistLC   := .F.
	Local _cAreaCNB

	If _cNewSit == "01"

		_cAreaCNB := CNB->(GetArea())

		CNB->(dbSetOrder(1))

		lExistLC := PcoExistLc(_cLanctoCT,"02","1")

		If CNB->(dbSeek(XFilial("CNB")+CN9->(CN9_NUMERO+CN9_REVISA)))
			If lExistLC
				PcoIniLan(_cLanctoCT)
			EndIf

			While CNB->(!Eof()) .and. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA) == XFilial("CNB")+CN9->(CN9_NUMERO+CN9_REVISA)
				If lExistLC
					PcoDetLan(_cLanctoCT,'02','MATA110')
				EndIf

				CNB->(dbSkip())
			EndDo

			If lExistLC
				PcoFinLan(_cLanctoCT)
			EndIf
		
		EndIf

		CNB->(RestArea(_cAreaCNB))

	EndIf

Return()