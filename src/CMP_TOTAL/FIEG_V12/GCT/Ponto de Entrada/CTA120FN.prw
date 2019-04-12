#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CTA120FN
Ponto de entrada para alterar a filial corrente antes de gerar o n�mero do pedido de compra.

@type function
@author Bruna Paola
@since 29/03/2012
@version P12.1.23

@obs Projeto ELO

@history 12/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Fixo verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function CTA120FN()


	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Type("cFilOri") == "C"
		cXFil := CFILANT
		CFILANT := cFilOri
	EndIf

Return .T.