#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120ISC
Atualizacao do preço unitário e total do PC conforme SC.

@type function
@author TOTVS
@since 05/08/2011
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT120ISC()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Considera somente Solicitação de Compra >-------------
If nTipoPed !=	2
	GDFieldPut("C7_PRECO",SC1->C1_VUNIT,n)
	GDFieldPut("C7_TOTAL",SC1->(C1_VUNIT*C1_QUANT),n)
EndIf

Return()
