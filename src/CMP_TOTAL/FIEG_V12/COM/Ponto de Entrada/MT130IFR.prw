#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT130IFR
Ponto de entrada incluir filtro de contrato de registro de preço.

@type function
@author Bruna Paola - TOTVS
@since 30/01/2012
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Expressão de Filtro em AdvPL e SQL.
/*/
/*/================================================================================================================================/*/

User Function MT130IFR()  

Local cFil := ""
Local cQuery := ""
Local aRet := {}  

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cFil    := ".And. C1_XCONTPR = ' ' " 	// FSW - NÃO SER VINCULADO AO CONTRATO DE REGISTRO DE PREÇO
cQuery  := " AND C1_XCONTPR = ' ' " 	// FSW - NÃO SER VINCULADO AO CONTRATO DE REGISTRO DE PREÇO

aAdd(aRet,cFil)
aAdd(aRet,cQuery)		
	
Return aRet
