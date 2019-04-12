#Include "Protheus.ch"
#include "Topconn.ch"
#include "Ap5Mail.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICTBA04
Cadastro de De/Para das Entidades Contábeis.

@type function
@author Joao Carlos A. Neto
@since 09/12/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICTBA04()

	Local oDlg
	Local oRadio
	Local nOpca := 1
	Private nRadio

	Static nEntid

	Private cCadastro := "Cadastro de De/Para das entidades"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	While nOpca == 1

		DEFINE MSDIALOG oDlg FROM  94,1 TO 273,293 TITLE OemToAnsi(cCadastro) PIXEL

		@ 10,17 Say OemToAnsi("Entidades") SIZE 150,7 OF oDlg PIXEL

		@ 27,07 TO 73, 140 OF oDlg  PIXEL

		@ 34,10 Radio 	oRadio VAR nRadio;
		ITEMS RetTitle("CT1_CONTA"),;	// "Conta"
		RetTitle("CTT_CUSTO"),;	// "C Custo"
		RetTitle("CTD_ITEM"),;	// "Item"
		RetTitle("CTH_CLVL");	// "Classe Valor"
		3D SIZE 100,10 OF oDlg PIXEL

		DEFINE SBUTTON FROM 75,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
		DEFINE SBUTTON FROM 75,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)	// Zero nOpca caso
		//	para saida com ESC
		If nOpca == 1
			If nRadio == 1
				CTBA04SX3(1)
			ElseIf nRadio == 2
				CTBA04SX3(2)
			ElseIf nRadio == 3
				CTBA04SX3(3)
			ElseIf nRadio == 4
				CTBA04SX3(4)
			EndIf
		Else
			Exit
		EndIf

		DbSelectArea("ZZ0")
		ZZ0->(DbSetOrder(1))

		aRotina   := {	{"Pesquisar"  ,"AxPesqui"  	,0,1},;
		{"Visualizar" ,"AxVisual"  	,0,2},;
		{"Incluir"    ,"U_CTBA04I()"	,0,3},;
		{"Alterar"    ,"U_CTBA04A()"	,0,4},;
		{"Excluir"	  ,"AxDeleta"		,0,5},;
		{"Imprimir"	  ,"U_SICTBR03()" ,0,6} }

		ZZ0->(MsFilter('ZZ0_ENTID == Alltrim(Str(nRadio))'))
		mBrowse(06,01,22,75,"ZZ0")
	End
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} CTBA04I
Cadastro de De/Para das Entidades Contábeis.

@type function
@author Joao Carlos A. Neto
@since 09/12/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@Return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/
User Function CTBA04I()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	AxInclui("ZZ0", Recno(), 3)
Return .T.

/*/================================================================================================================================/*/
/*/{Protheus.doc} CTBA04A
Cadastro de De/Para das Entidades Contábeis.

@type function
@author Joao Carlos A. Neto
@since 09/12/2013
@version P12.1.23

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@Return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/
User Function CTBA04A()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	AxAltera("ZZ0", Recno(), 3)
Return .T.

/*/================================================================================================================================/*/
/*/{Protheus.doc} CTBA04SX3
Cadastro de De/Para das Entidades Contábeis.

@type function
@author Joao Carlos A. Neto
@since 09/12/2013
@version P12.1.23

@param nOpc, Numérico, Código do Opção selecionada no RadioMenu.

@obs Desenvolvimento FIEG

@history 18/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function CTBA04SX3(nOpc)

	Local nEntid    := nOpc
	Local cF3       := ""
	Local cValid    := ""
	Local cRelac    := ""
	Local aAlias    := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If nEntid == 1
		cF3 	:= "CT1"
		cValid 	:= "Vazio() .Or. Ctb105Cta()"
		cRelac  := "'1'"
	ElseIf nEntid == 2
		cF3 := "CTT"
		cValid 	:= "Vazio().or. CTB105CC()"
		cRelac  := "'2'"
	ElseIf nEntid == 3
		cF3 := "CTD"
		cValid 	:= "Vazio() .Or. Ctb105Item()"
		cRelac  := "'3'"
	ElseIf nEntid == 4
		cF3 := "CTH"
		cValid 	:= "Vazio() .Or. CTB105CLVL()"
		cRelac  := "'4'"
	Endif

	DbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	SX3->(DbSeek("ZZ0_EN_ATU"))
	RecLock("SX3",.F.)
	SX3->X3_VLDUSER := ""
	SX3->X3_F3      := cF3
	SX3->(MsUnLock())

	SX3->(DbSeek("ZZ0_EN_NEW"))
	RecLock("SX3",.F.)
	SX3->X3_VLDUSER := cValid
	SX3->X3_F3      := cF3
	SX3->(MsUnLock())

	SX3->(DbSeek("ZZ0_ENTID"))
	RecLock("SX3",.F.)
	SX3->X3_RELACAO := cRelac
	SX3->(MsUnLock())

	RestArea(aAlias)

Return