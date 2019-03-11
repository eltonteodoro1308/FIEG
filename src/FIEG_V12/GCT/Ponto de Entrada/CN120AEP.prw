#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120AEP
Ponto de entrada para alterar a filial corrente antes do processamento da exclusão do pedido de compra.

@type function
@author Bruna Paola
@since 30/01/2012
@version P12.1.23

@obs Projeto ELO

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function CN120AEP()


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Type("cFilOri") == "C"
		cXFil := CFILANT
		CFILANT := cFilOri
	EndIf

Return .T.