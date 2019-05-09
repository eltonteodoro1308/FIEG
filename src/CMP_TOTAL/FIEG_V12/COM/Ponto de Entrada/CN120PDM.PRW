
#INCLUDE "PROTHEUS.CH"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120PDM
Ponto de Entrada utilizado para posicionar no Registro do Pedido de Compra, quando utilizado
o Encerramento da Medicao via ExecAuto

@type function
@author Eduardo Dias
@since 08/05/2019
@version P12.1.23

@obs Projeto ELO alterado pela FIEG
/*/

User Function CN120PDM(lRet)

Local cNumSC7	:= ""
//Local aArea		:= GetArea() 

Default lRet	:= .T.

cNumSC7  := Criavar("C7_NUM",.T.)

//Retorna um para considerar a cNumSC7 da rotina CNTA120, ja que a cNumSC7 e varial local no CNTA120
cNumSC7 := ALLTRIM(STR(Val(cNumSC7) - 1))

dbSelectArea("SC7")
dbSetOrder(1) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
SC7->(dbSeek(xFilial("SC7")+cNumSC7))

//RestArea(aArea)

Return(lRet)
