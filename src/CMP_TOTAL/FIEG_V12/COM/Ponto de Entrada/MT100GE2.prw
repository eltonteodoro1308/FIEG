#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT100GE2
Ponto de Entrada na geracao do titulo a pagar.

@type function
@author Leonardo Soncin - TOTVS
@since 12/09/2011
@version P12.1.23

@obs Projeto ELO

@history 26/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT100GE2()

Local aArea := GetArea()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If Type("__cBanco") <> "U"
	SE2->E2_XBANCO  := __cBanco
	SE2->E2_XAGENC 	:= __cAgencia
	SE2->E2_XDVAGE	:= __cDVAge
	SE2->E2_XNUMCON := __cConta
	SE2->E2_XDVCTA	:= __cDVCta
	
	dbSelectArea("SF1")
	RecLock("SF1",.F.)
		SF1->F1_XBANCO 	:= __cBanco
		SF1->F1_XAGENC 	:= __cAgencia
		SF1->F1_XDVAGE 	:= __cDVAge
		SF1->F1_XNUMCON := __cConta
		SF1->F1_XDVCTA 	:= __cDVCta
	SF1->(MsUnlock())
EndIf

//--< Grava os dados contabeis no titulo. >-----------------
SD1->(dbSetOrder(1))
If SD1->(dbSeek(xFilial('SF1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE))
	If SF1->F1_TIPO == "N"	
		SE2->E2_CONTAD	:= SD1->D1_CONTA
		SE2->E2_CCD		:= SD1->D1_CC
		SE2->E2_ITEMD	:= SD1->D1_ITEMCTA
		SE2->E2_CLVLDB	:= SD1->D1_CLVL
		SE2->E2_EC05DB	:= SD1->D1_EC05DB
		SE2->E2_EC06DB	:= SD1->D1_EC06DB
		SE2->E2_EC07DB	:= SD1->D1_EC07DB
		SE2->E2_EC08DB	:= SD1->D1_EC08DB
		SE2->E2_EC09DB	:= SD1->D1_EC09DB
		SE2->E2_XRESTPG	:= SD1->D1_XRESTPG
	EndIf
EndIf

//--< Chamada para rotina de gravacao do campo E2_DECRESC e F1_XMULTA >--
MsgRun('Atualizando informações de acréscimo e multa. Aguarde...',, {|| U_SICOMA14() } )

//--< Transferencia do mutuo da NFE para Financeiro . GAP091 >-----------
MsgRun('Transferindo rateio para Financeiro. Aguarde...',, {|| U_SICOMA06() } )

RestArea(aArea)

Return()
