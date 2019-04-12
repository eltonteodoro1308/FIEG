#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} AF030CAN
Apaga o registro do processo no campo N1_XPROCES e data no campo N1_XDTPROC na rotina de Cancelamento de Baixa de ativo ATFA030.

@type function
@author Tiago Alexandrino
@since 18/07/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function AF030CAN()

	Local aArea    := GetArea()
	Local aAreaSN1 := SN1->(GetArea())


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Atualiza processo
	RecLock("SN1",.F.)
	SN1->N1_XPROCES := ""
	SN1->N1_XDTPROC := CTOD("")
	SN1->(MsUnlock())

	//Restaura as areas
	RestArea(aAreaSN1)
	RestArea(aArea)

Return Nil