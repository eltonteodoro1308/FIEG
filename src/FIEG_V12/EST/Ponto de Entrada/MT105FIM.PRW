#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT105FIM
Ponto de Entrada ao fim da gravação do Solicitação ao Almoxarifado .

@type function
@author Thiago Rasmussen
@since 02/10/2012
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function MT105FIM()
	Local _aArea := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	U_SIEST5GR() // Rotina de Gravacao e Geracao de Bloqueio - SCR

	RestArea(_aArea)
Return()
