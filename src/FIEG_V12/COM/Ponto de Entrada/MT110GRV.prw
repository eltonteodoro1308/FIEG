#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT110GRV
Ponto de Entrada apos gravacao da SC.

@type function
@author Thiago Rasmussen
@since 10/05/2012
@version P12.1.23

@obs Projeto ELO

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function MT110GRV()

	Local _aArea := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+==========================================+
	//|Gravacao da justificativa de compra da SC |
	//+==========================================+
	U_SICOMA30()

	//+===============================================+
	//|Gravacao do campo C1_XCODCOMP para C1_CODCOMP  |
	//+===============================================+
	U_SICOMA16()

	RestArea(_aArea)

Return .T.
