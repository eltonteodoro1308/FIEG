#Include "Protheus.ch"
#Include "TbiConn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120LEG
Ponto de entrada para incluir legenda nova no PC.

@type function
@author Alexandre Cadubitski
@since Nov/2010
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Array, Vetor com a defini��o de legendas personalizadas.
/*/
/*/================================================================================================================================/*/

User Function MT120LEG()

Local aNewLegenda := aClone(PARAMIXB[1]) // aLegenda

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
aAdd(aNewLegenda,{ "BR_PINK",  		"Recebido pelo fornecedor"		}) 
aAdd(aNewLegenda,{ "BR_VIOLETA", 	"Confirmado pelo fornecedor"	})
aAdd(aNewLegenda,{ "BR_MARRON", 	"Pedido Emitido"				})

Return (aNewLegenda)
