#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MTA103MNU
PE para inclusao de botoes na rotina de Docto de Entrada.

@type function
@author TOTVS
@since 15/02/2019
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Nil, Fun��o sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MTA103MNU()

Local _aMutuo := {{"Visualizar","U_SICOMA27(2,'NF')",0,4}}  // Mutuo

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
aAdd(aRotina, {"M�tuo",_aMutuo,0,6}) 						// Consulta de Mutuo

Return()
