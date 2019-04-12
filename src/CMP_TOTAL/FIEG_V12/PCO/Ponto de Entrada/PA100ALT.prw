#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PA100ALT
Validar acesso a rotina de Alteracao da Planilha.

@type function
@author Claudinei Ferreira - TOTVS
@since 26/02/2012
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function PA100ALT()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Validar chamada para rotina para alteracao do Orcamento >--
lRet := U_SIPCOA12()

Return(lRet)
