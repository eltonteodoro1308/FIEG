#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} FA290
Tela para o usuario inserir a Conta e o Centro de Custos na inclusao de uma Fatura a Pagar.

@type function
@author João Carlos
@since 02/12/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function FA290()

	Local oDlg
	Local nOpca    := 0
	Local _lFechar := .F.
	Local cConta   := Space(TamSx3("CT1_CONTA")[1])
	Local cCCusto  := Space(TamSx3("CTT_CUSTO")[1])
	Local cItemCtb := Space(TamSx3("CTD_ITEM")[1])


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	DEFINE MSDIALOG oDlg FROM 10, 10 TO 24, 60 TITLE "Entidades Contábeis"

	@	0.3,1 TO 6 ,23.9 OF oDlg
	@	1.0,2 	Say "Conta Contabil: "
	@	1.0,8	MSGET cConta F3 "CT1" Picture "@!"  Valid CTB105CTA(cConta) HASBUTTON

	@	2.3,2 	Say "Centro de Custo: "
	@	2.3,8	MSGET cCCusto F3 "CTT" Picture "@!"  Valid CTB105CC(cCCusto) HASBUTTON

	@	3.6,2 	Say "Item Contabil: "
	@	3.6,8	MSGET cItemCtb F3 "CTD" Picture "@!"  When .F.

	DEFINE SBUTTON FROM 086,160	TYPE 1 ACTION (nOpca := 1, _lFechar := .T., IIF(!Empty(cConta) .AND. CTB105CTA(cConta) .AND. !Empty(cCCusto) .AND. CTB105CC(cCCusto), oDlg:End(),_lFechar := .F.)) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED VALID _lFechar

	RecLock("SE2",.F.)
	SE2->E2_CONTAD := cConta
	SE2->E2_CCD    := cCCusto
	SE2->E2_ITEMD  := cItemCtb
	SE2->(MsUnLock())

Return