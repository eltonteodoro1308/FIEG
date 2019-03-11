#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN120EPE
Ponto de entrada para alterar a filial corrente antes do processamento da exclusão do pedido de compra.

@type function
@author Bruna Paola
@since 19/03/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 11/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function CN120EPE()

	//Local cProc := ""
	//Local cFunc := "U_CNIEstMe" // Se for medição e geração de pedido de compra automática permito incluir a SC


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If (SubStr(CND->CND_OBS,1,78) == "Medição gerada automaticamente a partir da liberação da Solicitação de Compras" .OR.;
	SubStr(CND->CND_OBS,1,71) =="Medição gerada automaticamente a partir da inclusão do pedido de compra")

		cFilOri := CFILANT
		CFILANT := cXFil

	EndIf

Return .T.