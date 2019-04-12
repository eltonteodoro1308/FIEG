#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} GCP02FIL
Filtro nas SCs conforme o comprador para rotina de edital.

@type function
@author Claudinei Ferreira
@since 21/01/2012
@version P12.1.23

@obs Projeto ELO

@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Filtro nas SCs conforme o comprador para rotina de edital.

/*/
/*/================================================================================================================================/*/

User Function GCP02FIL

	Local _aArea := GetArea()

	//+------------------------------------------------------------------+
	//|Filtrar as SCs conforme o comprador para rotina de edital		 |
	//+------------------------------------------------------------------+
	cRet:= U_SICOMA15('GCP02FIL')

	RestArea(_aArea)

Return(cRet)