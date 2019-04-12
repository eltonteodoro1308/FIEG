#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MTA103OK
PE para validacao da linha na Inclusao ou alteracao do Documento de entrada no preenchimento do campo D1_XDTREC.

@type function
@author Claudinei Ferreira
@since 12/01/2012
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna o resultado da execução da rotina U_SICOMA32.
/*/
/*/================================================================================================================================/*/

User Function MTA103OK

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Chamada para validacao da linha no aCols do campo D1_XDTREC >--
lRet := U_SICOMA32()

Return (lRet)
