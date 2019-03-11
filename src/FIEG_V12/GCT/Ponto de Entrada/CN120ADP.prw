#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120ADP
Ponto de entrada para alterar a filial corrente depois do processamento da exclusão do pedido de compra.

@type function
@author Bruna Paola
@since 30/11/2012
@version P12.1.23

@obs Projeto ELO

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CN120ADP()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Type("cFilOri") == "C"
		cFilOri := CFILANT
		CFILANT := cXFil
	EndIf

Return ()