#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CalcVal
Funcao para tratamento do Valor com Acrescimo e Decrescimos para geracao do CNAB.

@type function
@author Wagner Farias
@since 20/11/2009
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Numérico, Valor com Acrescimo e Decrescimos.

/*/
/*/================================================================================================================================/*/

User Function CalcVal()

	//+------------------------------------------+
	//|     Declaração de Variaveis Locais       |
	//+------------------------------------------+
	Local aArea		:= SE1->(GetArea())
	Local nVlrAbat	:= 0
	Local nAcresc	:= 0
	Local nDecres	:= 0
	Local nValorT	:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+------------------------------------------+
	//|     Atribuição de Valores                |
	//+------------------------------------------+
	nValor	:= SE1->E1_SALDO
	nVlrAbat:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	nAcresc	:= SE1->E1_ACRESC
	nDecres := SE1->E1_DECRESC

	//+------------------------------------------+
	//|     Processamento                        |
	//+------------------------------------------+
	nValorT := nValor - nVlrAbat + nAcresc - nDecres

	//+------------------------------------------+
	//|     Restaura Area                        |
	//+------------------------------------------+
	RestArea(aArea)

	//+------------------------------------------+
	//|     Retorno da Função                    |
	//+------------------------------------------+

Return (nValorT)

