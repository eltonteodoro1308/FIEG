#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT100GRV
 Ponto de entrada na inclusao do documento de entrada ou classificacao.

@type function
@author Leonardo Soncin
@since 12/09/2011
@version P12.1.23

@obs Projeto ELO

@history 14/09/2011, alecadu@totvs.com.br, Alterado por Cadu para nao validar o banco/agencia/conta.
@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function MT100GRV


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Despesa de Importacao
	If IsInCallStack("MATA119")

		DadosBanco()

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} DadosBanco
Exibe tela para preencher com dados bancários.

@type function
@author Leonardo Soncin
@since 12/09/2011
@version P12.1.23

@obs Projeto ELO

@history 14/09/2011, alecadu@totvs.com.br, Alterado por Cadu para nao validar o banco/agencia/conta.
@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function DadosBanco()

	Local oDlg 		:= Nil
	Local oBanco	:= Nil
	Local oAgencia	:= Nil
	Local oConta	:= Nil
	Local lAltBco	:= GetNewPar("SI_ALTBCO",.T.)
	Local nPosTes	:= aScan(aHeader,{|x| AllTrim(x[2])=='D1_TES'})
	Local nX		:= 0
	Local lDup		:= .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	Public __cBanco   := Criavar("E2_XBANCO")
	Public __cAgencia := Criavar("E2_XAGENC")
	Public __cDVAge   := Criavar("E2_XDVAGE")
	Public __cConta   := Criavar("E2_XNUMCON")
	Public __cDVCta   := Criavar("E2_XDVCTA")

	If  l103Class
		__cBanco   := SF1->F1_XBANCO
		__cAgencia := SF1->F1_XAGENC
		__cDVAge   := SF1->F1_XDVAGE
		__cConta   := SF1->F1_XNUMCON
		__cDVCta   := SF1->F1_XDVCTA
	EndIf

	If Empty(__cBanco)
		__cBanco   := SA2->A2_BANCO
		__cAgencia := SA2->A2_AGENCIA
		__cDVAge   := SA2->A2_XDVAGE
		__cConta   := SA2->A2_NUMCON
		__cDVCta   := SA2->A2_XDVCTA
	EndIf

	For nX := 1 to Len(aCols)

		dbSelectArea("SF4")
		SF4->(dbSetOrder(1))
		If SF4->(dbSeek(xFilial("SF4")+aCols[nX][nPosTES]))
			If SF4->F4_DUPLIC == "S"
				lDup := .T.
				Exit
			EndIf

		EndIf

	Next nX

	If lAltBco .and. lDup .and. inclui

		DEFINE MSDIALOG oDlg FROM 0,0 TO 90,670 PIXEL TITLE "Dados Bancários"

		@ 001,003 TO 040,330 LABEL "" OF oDlg PIXEL

		@ 10, 10 SAY "Banco:" SIZE 45,8 PIXEL OF oDlg
		@ 10, 30 MSGET oBanco VAR __cBanco PICTURE PesqPict("SE2","E2_XBANCO") F3 CpoRetF3('E2_XBANCO') SIZE 30,10 PIXEL OF oDlg

		@ 10, 70  SAY "Agencia:" SIZE 45,8 PIXEL OF oDlg
		@ 10, 95 MSGET oAgencia VAR __cAgencia PICTURE PesqPict("SE2","E2_XAGENC") F3 CpoRetF3('E2_XAGENC') SIZE 35,10 PIXEL OF oDlg

		@ 10, 140  SAY "DV Agencia:" SIZE 45,8 PIXEL OF oDlg
		@ 10, 175 MSGET oDVAge VAR __cDVAge PICTURE PesqPict("SE2","E2_XDVAGE") SIZE 15,10 PIXEL OF oDlg

		@ 10, 200 SAY "Conta:" SIZE 45,8 PIXEL OF oDlg
		@ 10, 220 MSGET oConta VAR __cConta PICTURE PesqPict("SE2","E2_XNUMCON") F3 CpoRetF3('E2_XNUMCON') SIZE 35,10 PIXEL OF oDlg

		@ 10, 270 SAY "DV Conta:" SIZE 45,8 PIXEL OF oDlg
		@ 10, 300 MSGET oDVCta VAR __cDVCta PICTURE PesqPict("SE2","E2_XDVCTA") SIZE 15,10 PIXEL OF oDlg

		DEFINE SBUTTON FROM 025,290 TYPE 1 OF oDlg ENABLE ONSTOP "OK" ACTION (oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTER

	EndIf

Return
