#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT103SEL
Ponto de entrada para validar item de pedido de compra.
Utilizado para efetuar validações específicas no item selecionado permitindo ou não a sua utilização no documento de entrada.

@type function
@author Bruna Paola
@since 09/06/2011
@version P12.1.23

@obs Projeto ELO

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, 0 = Não carrega o item no documento de entrada / 1 = Carrega o item no documento de entrada..

/*/
/*/================================================================================================================================/*/

User Function MT103SEL()

	Local nRecno    := PARAMIXB[1]
	Local aArea     := GetArea()
	Local nRet      := 0
	Local lAtesto   := GETMV("MV_XATESTO")
	Local cSolic    := ""
	Local cxVer     := ""
	Local lProb		:= .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	dbSelectArea('SC7')
	SC7->(dbGoto(nRecno))

	nRet  := 1
	lProb := .F.

	//A rotina so sera executada quando for pre-nota
	If ( lAtesto .And. FWIsInCallStack("A140NFISCAL") )

		If Empty(SC7->C7_NUMSC) .And. Empty(SC7->C7_CONTRA) // Nao tem amarracao com solicitacao de compras e nao tem contrato
			MsgAlert("Existe pedidos sem amarração com solicitação.","ATENCAO")
			lProb := .T.
		Else
			DbSelectArea("SC1")
			SC1->(DbSetOrder(1))//C1_FILIAL+C1_NUM
			SC1->(DbGoTop())

			cSolic := xFilEnt(xFilial("SC1")) + SC7->C7_NUMSC
			SC1->(dbSeek(cSolic))

			cxVer := SC1->C1_XSOL // Requisitante da Solicitacao

			If (AllTrim(cxVer) == '') // Primeira vez que entrar, guarda o requisitante
				MsgAlert("Item sem requisitante.","ATENCAO")
				lProb := .T.
			EndIf

			If (U_COM120VL(cxVer) == .T.)
				lProb := .T.
			EndIf

		EndIf

		If (lProb == .T.)
			nRet := 0
		EndIf

	EndIf

	RestArea(aArea)

Return nRet