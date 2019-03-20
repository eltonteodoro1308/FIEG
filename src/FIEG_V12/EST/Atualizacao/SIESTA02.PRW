#Include "Protheus.ch"
#INCLUDE "topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIESTA02
Tratamendo de filtro por número do documento no bloqueio do Inventário.

@type function
@author Thiago Rasmussen
@since
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando se filtra número do documento no bloqueio do Inventário.

/*/
/*/================================================================================================================================/*/

User Function SIESTA02

	//+---------------------------------------------------------------------+
	//| Declaracao de Variaveis                                             |
	//+---------------------------------------------------------------------+

	Local lRet 	:= .T.
	Local aArea := GetArea()
	// Grupo de Perguntas alterado: MTA271

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("SZL")
	dbSetOrder(1)
	If !SZL->(dbSeek(xFilial("SZL")+MV_PAR15+SB2->B2_COD+SB2->B2_LOCAL))
		lRet := .F.
	Endif

	RestArea(aArea)
Return lRet