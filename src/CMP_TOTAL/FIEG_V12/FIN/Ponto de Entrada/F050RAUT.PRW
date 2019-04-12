#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} F050RAUT
Ponto de Entrada tratamento do rateio em rotina automatica.

@type function
@author Thiago Rasmussen
@since 11/04/2012
@version P12.1.23

@obs Projeto ELO

@history 12/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com os valores a serem gravados na tabela de rateio CV4.

/*/
/*/================================================================================================================================/*/

User function F050RAUT()

	Local _aRet := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Aadd(_aRet,2)
	Aadd(_aRet,"000001")
	Aadd(_aRet,"")
	Aadd(_aRet,"")
	Aadd(_aRet,"")

Return(_aRet)
