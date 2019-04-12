#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120BRW
Ponto de Entrada localizado no final da rotina de Pedido de Compras Manual, para inclusao da chamada de funções variadas.

@type function
@author Eduardo
@since 03/08/2016
@version P12.1.23

@param PARAMIXB, Array, [{OPERAÇÃO, NUMERO DO PEDIDO,nOpcA}].

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro.
/*/
/*/================================================================================================================================/*/

User Function MT120BRW()

Local aAux	:= aClone(aRotina)

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
//aAdd( aAux, { "Rel. de Ped. Gerados", "u_F0400303()", 0, 2, 0, NIL } )
aAdd(aAux,{"Rel. de Ped. Gerados", "u_F0400303(5)", 0, 2, 0, NIL})
aRotina	:=	aClone(aAux) 

Return .T.
