#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} A140Exc
Ponto de entrada para validar exclus�o de pr�-nota.

@type function
@author Bruna Paola
@since 17/06/2011
@version P12.1.23

@obs Projeto ELO

@history 22/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return ExpL1, Retorna verdadeiro se valida��es OK.
/*/
/*/================================================================================================================================/*/

User Function A140Exc()

Local ExpL1 := .T.

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If (AllTrim(SF1->F1_XATESTO) == "2")
	MsgAlert("Essa pr�-nota j� foi atestada e n�o pode ser excluida.","ATENCAO")
	ExpL1 := .F.
EndIf

Return ExpL1
