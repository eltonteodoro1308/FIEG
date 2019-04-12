#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} FA040Inc
Obrigatoriedade para os campos Centro de Custo, Item e Conta.

@type function
@author TOTVS
@since 20/06/2012
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function FA040INC()

Local _lRet	:= .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If !lF040Auto .and. M->E1_MULTNAT == "2"
	If Empty(CT1->CT1_CONTA) 
		Posicione("CT1",1,XFilial("CT1")+M->E1_CREDIT,"CT1_CONTA")
	Endif	

	If CT1->CT1_ITOBRG == "1" .And. Empty(M->E1_ITEMC)
		MsgAlert("Item Contábil obrigatório para esta Conta Contábil.", "Atenção")
		_lRet := .F.
	ElseIf CTT->CTT_ITOBRG == "1" .And. Empty(M->E1_ITEMC)
		MsgAlert("Item Contábil obrigatório para este Centro de Custo.", "Atenção")
		_lRet := .F.
	ElseIf CT1->CT1_ACITEM == "2" .And. !Empty(M->E1_ITEMC)
		MsgAlert("Conta Contábil não aceita Item Contábil.", "Atenção")
		_lRet := .F.
	ElseIf CTT->CTT_ACITEM == "2" .And. !Empty(M->E1_ITEMC)
		MsgAlert("Centro de Custo não aceita Item Contábil.", "Atenção")
		_lRet := .F.
	Endif
Endif

Return(_lRet)
