#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA30
Gravar justificativa de compra (C1_XJUSTIF) em todos os itens da SC.

@type function
@author Claudinei Ferreira - TOTVS
@since 29/11/2011
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro.
/*/
/*/================================================================================================================================/*/

User Function SICOMA30()

Local _aArea := GetArea()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If (INCLUI .or. ALTERA)
	_cNumSC := SC1->C1_NUM
	
	SC1->(dbSetOrder(1))
	SC1->(dbSeek(XFilial("SC1")+_cNumSC))
	
	While SC1->(!Eof()) .and. SC1->C1_FILIAL == XFilial("SC1") .and. SC1->C1_NUM == _cNumSC
		
		//Grava os campo criado no cabecalho da SC pelo PE MT110TEL
		If SC1->(FieldPos("C1_XJUSTIF")) > 0
			Reclock("SC1",.F.)
			SC1->C1_XJUSTIF := cJustCom
			SC1->(MsUnlock())
		EndIf
		
		If SC1->(FieldPos("C1_ITEMCTA")) > 0
			Reclock("SC1",.F.)
			SC1->C1_ITEMCTA := _cItCta
			SC1->(MsUnlock())
		EndIf
		
		SC1->(dbSkip())
	Enddo
Endif

RestArea(_aArea)

Return(.T.)
