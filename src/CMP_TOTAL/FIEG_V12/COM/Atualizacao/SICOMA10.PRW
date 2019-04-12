#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA10
Ponto de Entrada para manipulacao dos dados bancarios da nota fiscal de entrada.

@type function
@author Thiago Rasmussen
@since 20/10/2011
@version P12.1.23

@obs Projeto ELO

@history 06/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMA10()

	Local lAltBco	:= GetNewPar("SI_ALTBCO",.T.)
	//Local oDlg 		:= Nil
	//Local oBanco	:= Nil
	//Local oAgencia	:= Nil
	//Local oDVAge	:= Nil
	//Local oConta	:= Nil
	//Local oDVCta	:= Nil

	Private cBanco   := SA2->A2_BANCO //Criavar("E2_XBANCO")
	Private cAgencia := SA2->A2_AGENCIA//Criavar("E2_XAGENC")
	Private cConta   := SA2->A2_NUMCON//Criavar("E2_XNUMCON")
	Private cDVAge	  := SA2->A2_XDVAGE
	Private cDVCta	  := SA2->A2_XDVCTA
	Private __cFornec := SA2->A2_COD   //Jalles Araujo - 09/10/14
	Private __cLjForn := SA2->A2_LOJA  //Jalles Araujo - 09/10/14

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If lAltBco .and. INCLUI
		/* Retirada a opção de exibição dos dados bancários (Financeiro 10/10/14)
		DEFINE MSDIALOG oDlg FROM 0,0 TO 90,670 PIXEL TITLE "Dados Bancários"

		@ 001,003 TO 040,330 LABEL "" OF oDlg PIXEL

		@ 10, 10 SAY "Banco:" SIZE 45,8 PIXEL OF oDlg
		@ 10, 30 MSGET oBanco VAR cBanco PICTURE PesqPict("SE2","E2_FORBCO") Valid Existcpo("FIL",__cFornec+__cLjForn+cBanco,2) F3 "FILDOC" SIZE 30,10 PIXEL OF oDlg

		@ 10, 70  SAY "Agencia:" SIZE 45,8 PIXEL OF oDlg
		@ 10, 95 MSGET oAgencia VAR cAgencia PICTURE PesqPict("SE2","E2_FORAGE") F3 CpoRetF3('E2_FORAGE') SIZE 35,10 PIXEL OF oDlg When .F.

		@ 10, 140  SAY "DV Agencia:" SIZE 45,8 PIXEL OF oDlg
		@ 10, 175 MSGET oDVAge VAR cDVAge PICTURE PesqPict("SE2","E2_FAGEDV") SIZE 15,10 PIXEL OF oDlg When .F.

		@ 10, 200 SAY "Conta:" SIZE 45,8 PIXEL OF oDlg
		@ 10, 220 MSGET oConta VAR cConta PICTURE PesqPict("SE2","E2_FORCTA") F3 CpoRetF3('E2_FORCTA') SIZE 35,10 PIXEL OF oDlg When .F.

		@ 10, 270 SAY "DV Conta:" SIZE 45,8 PIXEL OF oDlg
		@ 10, 300 MSGET oDVCta VAR cDVCta PICTURE PesqPict("SE2","E2_FCTADV") SIZE 15,10 PIXEL OF oDlg When .F.

		DEFINE SBUTTON FROM 025,290 TYPE 1 OF oDlg ENABLE ONSTOP "OK" ACTION (oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTER
		*/
		dbSelectArea("SF1")
		RecLock("SF1",.F.)
		SF1->F1_XBANCO  := cBanco
		SF1->F1_XAGENC  := cAgencia
		SF1->F1_XDVAGE  := cDVAge
		SF1->F1_XNUMCON := cConta
		SF1->F1_XDVCTA  := cDVCta
		SF1->(MsUnLock())

	EndIf

Return