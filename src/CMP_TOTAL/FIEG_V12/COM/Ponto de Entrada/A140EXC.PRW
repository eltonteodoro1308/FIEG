#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} A140Exc
Ponto de entrada para validar exclusão de pré-nota.

@type function
@author Bruna Paola
@since 17/06/2011
@version P12.1.23

@obs Projeto ELO

@history 22/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return ExpL1, Retorna verdadeiro se validações OK.
/*/
/*/================================================================================================================================/*/

User Function A140Exc()

Local ExpL1 := .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If (AllTrim(SF1->F1_XATESTO) == "2")
	MsgAlert("Essa pré-nota já foi atestada e não pode ser excluida.","ATENCAO")
	ExpL1 := .F.
EndIf

Return ExpL1
