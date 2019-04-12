#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT130IFC
Ponto de entrada incluir filtro de contrato de registro de pre�o.

@type function
@author Bruna Paola - TOTVS
@since 30/01/2012
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 01/10/2016, Thiago Rasmussen, N�o permitir que o mesmo usu�rio que solicita, tamb�m gere a cota��o e que caso esteja na aprova��o da diretoria, esteja aprovado.
@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Array, Express�o de Filtro em AdvPL e SQL.
/*/
/*/================================================================================================================================/*/

User Function MT130IFC()  

Local cFil := ""
Local cQuery := ""
Local aRet := {}  
                
//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< 01/10/2016 - Thiago Rasmussen >-----------------------
cFil    := ".AND. EMPTY(C1_XCONTPR) .AND. C1_USER != '" + RetCodUsr() + "' .AND. !C1_XSTAPRO$'P;N;C' "      // FSW - N�O SER VINCULADO AO CONTRATO DE REGISTRO DE PRE�O
cQuery  := "AND C1_XCONTPR = ' ' AND C1_USER <> '" + RetCodUsr() + "' AND C1_XSTAPRO NOT IN ('P','N','C') " // FSW - N�O SER VINCULADO AO CONTRATO DE REGISTRO DE PRE�O

aAdd(aRet,cFil)
aAdd(aRet,cQuery)		
	
Return aRet
