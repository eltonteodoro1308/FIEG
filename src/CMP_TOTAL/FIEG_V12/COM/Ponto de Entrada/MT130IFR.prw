#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT130IFR
Ponto de entrada incluir filtro de contrato de registro de pre�o.

@type function
@author Bruna Paola - TOTVS
@since 30/01/2012
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Array, Express�o de Filtro em AdvPL e SQL.
/*/
/*/================================================================================================================================/*/

User Function MT130IFR()  

Local cFil := ""
Local cQuery := ""
Local aRet := {}  

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cFil    := ".And. C1_XCONTPR = ' ' " 	// FSW - N�O SER VINCULADO AO CONTRATO DE REGISTRO DE PRE�O
cQuery  := " AND C1_XCONTPR = ' ' " 	// FSW - N�O SER VINCULADO AO CONTRATO DE REGISTRO DE PRE�O

aAdd(aRet,cFil)
aAdd(aRet,cQuery)		
	
Return aRet
