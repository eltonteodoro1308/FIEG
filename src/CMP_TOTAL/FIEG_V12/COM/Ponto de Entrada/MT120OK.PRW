#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120OK
Ponto de entrada para valida o tudook do pedido de compras.

@type function
@author Carlos Henrique
@since 22/04/2013
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro.
/*/
/*/================================================================================================================================/*/

User Function  MT120OK()

Local aArea 	:= GetArea()
Local lAltPed   := If(SuperGetMv("MV_ALTPEDC")=="S",.T.,.F.)
Local lRet 		:= .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If ALTERA .and. !lAltPed
	Help(" ",1,"A120ALT")
	lRet := .F.
EndIf	
	  
RestArea(aArea)	

Return lRet
