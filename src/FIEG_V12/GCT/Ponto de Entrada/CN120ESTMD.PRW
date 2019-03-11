#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120ESTMD
A finalidade desse ponto de entrada é o processamento de rotinas específicas após o estorno das medições.

@type function
@author Thiago Rasmussen
@since 01/10/2016
@version P12.1.23

@obs Desenvolvimento FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CN120ESTMD()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// cNumPed

	// Ao estornar a medição, retornar o status da mesma para bloqueada
	RecLock("CND",.F.)
	CND->CND_ALCAPR := 'B'
	CND->(msUnlock())

Return NIL