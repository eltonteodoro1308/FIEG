#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PCOA1002
Adiciona botoes BUTTONBAR da tela de PLANILHA ORCAMENTARIA.

@type function
@author Bruno Daniel Borges
@since 01/07/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Opções da rotina.
/*/
/*/================================================================================================================================/*/

User Function PCOA1003()

Local aBut := {}

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
AAdd(aBut,{"Importar Planilha", {||U_SIPCOA02() },"GRAF2D","Importar Planilha"} )
AAdd(aBut,{"Titulo"			  , {||U_SIPCOA10() }, "BPMSDOC","Finaliza Digit." })

Return aBut
