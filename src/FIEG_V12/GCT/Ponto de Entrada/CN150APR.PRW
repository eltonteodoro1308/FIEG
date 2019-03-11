#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN150APR
Descrição detalhada da função.

@type function
@author José Fernando
@since 22/02/2018
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CN150APR()

	Local _aArea := GetArea()
	Local ExpC1  := PARAMIXB[1] // Número Contrato
	Local ExpC2  := PARAMIXB[2] // Revisão Atual do Contrato
	//Local ExpC3  := PARAMIXB[3] // Revisão Anterior do Contrato
	//Local ExpL1  := PARAMIXB[4] // Contrato com Medição Eventual?
	//Local ExpL2  := PARAMIXB[5] // Contrato Físico?

	dbSelectArea("CN9")
	CN9->(dbSetOrder(1))
	CN9->(dbSeek(xFilial("CN9") + ExpC1 + ExpC2))
	RecLock("CN9",.F.)
	CN9->CN9_XUAREV = RetCodUsr()
	CN9->(MsUnLock())
	RestArea(_aArea)

Return NIL