#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SD1100I
PE apos identificacao dos itens com mutuo.

@type function
@author TOTVS
@since 17/08/2012
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SD1100I()

Local _aAreaSC1 := SC1->(GetArea())
Local _aAreaSC7 := SC7->(GetArea())
Local _aAreaSD1 := SD1->(GetArea())

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Atualiza flag para itens com rateio >----------------
If SD1->(FieldPos("D1_XMUTUO")) > 0
	SC7->(dbSetOrder(1))
	IF SC7->(dbSeek(XFilial("SC7")+SD1->(D1_PEDIDO+D1_ITEMPC)))
		SC1->(dbSetOrder(1))
		IF SC1->(dbSeek(XFilial("SC1")+SC7->(C7_NUMSC+C7_ITEMSC)))
			SZW->(dbSetOrder(1))
			IF SZW->(dbSeek(XFilial("SZW")+SC1->(C1_NUM+C1_ITEM)))
				RecLock("SD1",.f.)
					SD1->D1_XMUTUO := "1" // Sim
				SD1->(msUnlock())
			EndIf
		EndIf
	EndIf
EndIf

SC7->(dbSetOrder(1))
IF SC7->(dbSeek(XFilial("SC7")+SD1->(D1_PEDIDO+D1_ITEMPC)))
	RecLock("SD1",.F.)
		SD1->D1_XRESTPG := SC7->C7_XRESTPG
	SD1->(msUnlock())
Endif

RestArea(_aAreaSC1)
RestArea(_aAreaSC7)   
RestArea(_aAreaSD1)

Return()
