#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120EPE
Ponto de entrada para alterar a filial corrente antes do processamento da exclus�o do pedido de compra.

@type function
@author Bruna Paola
@since 19/03/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function CN120EPE()

	//Local cProc := ""
	//Local cFunc := "U_CNIEstMe" // Se for medi��o e gera��o de pedido de compra autom�tica permito incluir a SC


	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If (SubStr(CND->CND_OBS,1,78) == "Medi��o gerada automaticamente a partir da libera��o da Solicita��o de Compras" .OR.;
	SubStr(CND->CND_OBS,1,71) =="Medi��o gerada automaticamente a partir da inclus�o do pedido de compra")

		cFilOri := CFILANT
		CFILANT := cXFil

	EndIf

Return .T.