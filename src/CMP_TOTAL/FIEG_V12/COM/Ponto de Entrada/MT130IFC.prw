#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT130IFC
Ponto de entrada incluir filtro de contrato de registro de preço.

@type function
@author Bruna Paola - TOTVS
@since 30/01/2012
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 01/10/2016, Thiago Rasmussen, Não permitir que o mesmo usuário que solicita, também gere a cotação e que caso esteja na aprovação da diretoria, esteja aprovado.
@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Expressão de Filtro em AdvPL e SQL.
/*/
/*/================================================================================================================================/*/

User Function MT130IFC()  

Local cFil := ""
Local cQuery := ""
Local aRet := {}  
                
//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< 01/10/2016 - Thiago Rasmussen >-----------------------
cFil    := ".AND. EMPTY(C1_XCONTPR) .AND. C1_USER != '" + RetCodUsr() + "' .AND. !C1_XSTAPRO$'P;N;C' "      // FSW - NÃO SER VINCULADO AO CONTRATO DE REGISTRO DE PREÇO
cQuery  := "AND C1_XCONTPR = ' ' AND C1_USER <> '" + RetCodUsr() + "' AND C1_XSTAPRO NOT IN ('P','N','C') " // FSW - NÃO SER VINCULADO AO CONTRATO DE REGISTRO DE PREÇO

aAdd(aRet,cFil)
aAdd(aRet,cQuery)		
	
Return aRet
