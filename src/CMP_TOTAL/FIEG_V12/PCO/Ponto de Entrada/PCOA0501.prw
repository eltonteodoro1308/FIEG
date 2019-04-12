#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PCOA0501
Adiciona botoes na tela de LANCAMENTOS MANUAIS.

@type function
@author TOTVS
@since 01/07/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Funções da rotina.
/*/
/*/================================================================================================================================/*/

User Function PCOA0501()

Local _aRetorno := {}
Local _aVet := {{"Imp. Movimentos","U_SIPCOA3G",0,4},{"Exp. Movimentos","U_SIPCOA3E",0,4},{ "Relatório","U_SIPCOR04(2)",0,4}}  // Consolidacao

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
aAdd(_aRetorno,{"Consolidação",_aVet,0,6}) 					// Grupo de Consolidacao

Return(_aRetorno)
