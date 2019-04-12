#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} FA080ACES
Permite ou nao que o usuario altere os valores dos impostos da lei 10925 calculados automaticamente pelo sistema.

@type function
@author TOTVS
@since 18/07/2012
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna Falso.
/*/
/*/================================================================================================================================/*/

User Function FA080ACES()

Local _lRet := .F. 											// ( .T. - PERMITE  /  .F. - NAO PERMITE )

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------

Return(_lRet)
