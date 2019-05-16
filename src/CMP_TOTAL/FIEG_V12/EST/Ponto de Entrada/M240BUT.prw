#include 'protheus.ch'
#include 'parmtype.ch'

/*/================================================================================================================================/*/
/*/{Protheus.doc} M240BUT
P.E. na rotina de Movimentação Interna do Estoque (MATA240) para correção da variável 'cFunc'.

@type function
@author Kley@TOTVS.com.br
@since 06/05/2019
@version P12.1.23

@obs Migração V12

@return Nil, Função sem retorno.

@history 16/04/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.
/*/
/*/================================================================================================================================/*/

User Function M240BUT()

If Type("cFunc") == "C"
	If AllTrim(cFunc) == "STRZERO("
		cFunc := Nil
	EndIf
EndIf
	
Return Nil