#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA120BUT
Ponto de entrada para adicionar botões na tela de pedidos.

@type function
@author Carlos Henrique
@since 19/02/2012
@version P12.1.23

@obs Desenvolvimento FIEG

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com a lista de botões a serem adcionados.

/*/
/*/================================================================================================================================/*/

User Function MA120BUT()

	Local aBut	:={}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	IF !INCLUI .AND. !ALTERA
		AADD(aBut,{"S4WB011N",  {|| VerEspec("C7_XESPEC",aCols[n][aScan(aHeader,{|x| Trim(x[2])=="C7_XESPEC"})]) }, "Especificação do produto", "Especificação do produto" })
	ENDIF

Return aBut

#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} VerEspec
Exibe a Especificação do produto.

@type function
@author Carlos Henrique
@since
@version P12.1.23

@param cCamp, Caractere, Nome do campo que contèm a especificação do produto.
@param cEspec, Caractere, Especificação do produto.

@obs Desenvolvimento FIEG

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function VerEspec(cCamp,cEspec)
	LOCAL aArea	:= GETAREA()
	LOCAL oFont	:= NIL
	LOCAL oMemo := NIL
	LOCAL oDlg	:= NIL

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	OpenSxs(,,,,cEmpAnt,'SX3MDI','SX3',,.F.)
	SX3MDI->(DbSetOrder(2))
	If SX3MDI->(DBSEEK(cCamp))
		Define Font oFont Name "Mono AS" Size 5, 12
		Define MsDialog oDlg Title SX3MDI->X3_TITULO From 3, 0 to 340, 417 Pixel
		@ 5, 5 Get oMemo Var cEspec Memo Size 200, 145 Of oDlg Pixel
		oMemo:bRClicked := { || AllwaysTrue() }
		oMemo:oFont     := oFont
		Define SButton From 153, 175 Type 1 Action oDlg:End() Enable Of oDlg Pixel
		Define SButton From 153, 145 Type 2 Action oDlg:End() Enable Of oDlg Pixel
		Activate MsDialog oDlg Center
	EndIf

	RestArea(aArea)

	SX3MDI->(DbCloseArea())

Return
