#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MTA103MNU
PE para inclusao de botoes na rotina de Docto de Entrada.

@type function
@author TOTVS
@since 15/02/2019
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MTA103MNU()

Local _aMutuo := {{"Visualizar","U_SICOMA27(2,'NF')",0,4}}  // Mutuo

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
aAdd(aRotina, {"Mútuo",_aMutuo,0,6}) 						// Consulta de Mutuo

Return()
