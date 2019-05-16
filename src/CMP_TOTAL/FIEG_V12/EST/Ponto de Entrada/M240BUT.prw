#include 'protheus.ch'
#include 'parmtype.ch'

/*/================================================================================================================================/*/
/*/{Protheus.doc} M240BUT
P.E. na rotina de Movimenta��o Interna do Estoque (MATA240) para corre��o da vari�vel 'cFunc'.

@type function
@author Kley@TOTVS.com.br
@since 06/05/2019
@version P12.1.23

@obs Migra��o V12

@return Nil, Fun��o sem retorno.

@history 16/04/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.
/*/
/*/================================================================================================================================/*/

User Function M240BUT()

If Type("cFunc") == "C"
	If AllTrim(cFunc) == "STRZERO("
		cFunc := Nil
	EndIf
EndIf
	
Return Nil