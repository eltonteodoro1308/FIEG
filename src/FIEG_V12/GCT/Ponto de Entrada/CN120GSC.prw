#Include "Protheus.ch"
#Include "topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120GSC
Ponto de entrada para salvar informações na SC7.

@type function
@author Bruna Paola
@since 30/01/2012
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CN120GSC()

	Local aXAreas	:= {}
	Local lXRPCont	:= SuperGetMv("SI_XRPCONT",.F.,.T.)
	Local cXFilCont	:= ""
	Local cXCont	:= ""
	Local cXContRev	:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	/*\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\||
	||Desc.     |  lXRPCont - Customização de Restos a Pagar - Contratos	    ||
	||          |  Autor: Daniel Flavio                                         ||
	||          |  Data: 30/11/2018                                             ||
	||\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\|//|\\*/
	If lXRPCont

		aXAreas := SaveArea1({"SC7","CND","CN9"})

		// Seleciona área de trabalho
		dbSelectArea("CN9")

		TRBSC7->(DbGoTop())

		// Preenche campos especificos do SIGAGCT
		While !TRBSC7->(Eof())

			SC7->(MsGoTo(TRBSC7->RECNO))

			cXFilCont	:= CN9->CN9_FILIAL
			cXCont		:= SC7->C7_CONTRA
			cXContRev	:= SC7->C7_CONTREV

			// Verifico se o contrato está setado como resto a pagar
			If !Empty(cXCont+cXContRev) .AND. U_fXResto99("IS_RP",cXFilCont,cXCont,cXContRev)

				// Verifica se grava as informações de Restos a Pagar no Pedido de Compras
				If !Empty(CND->CND_XRESTP)
					RecLock("SC7",.F.)
					SC7->C7_XRESTPG := Iif((U_fXResto99("CONTABILIZADO",cXFilCont,cXCont,cXContRev)),"3","1")
					SC7->(msUnlock())
				EndIf

			EndIf

			TRBSC7->(dbSkip())
		EndDo

		RestArea1(aXAreas)

	EndIf

Return


