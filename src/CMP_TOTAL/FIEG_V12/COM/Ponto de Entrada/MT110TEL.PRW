#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT110TEL
Inclui no cabecalho da SC campo de justificativa de compra para gravacao em todos os itens da SC.

@type function
@author Claudinei Ferreira
@since 29/11/2011
@version P12.1.23

@obs Projeto ELO

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function MT110TEL

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+=================================================+
	//|Chamada para inclusao de campo no cabecalho da SC|
	//+=================================================+

	U_SICOMA19(PARAMIXB[1],PARAMIXB[2],PARAMIXB[3],PARAMIXB[4])

Return()
