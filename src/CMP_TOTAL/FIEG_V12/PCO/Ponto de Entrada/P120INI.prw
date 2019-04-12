#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} P120INI
Definir o status da planilha e itens como Aberto (0) no nicio da Revisao.

@type function
@author Claudinei Ferreira - TOTVS
@since 24/02/2012
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, Retorno verdadeiro
/*/
/*/================================================================================================================================/*/

User Function P120INI()

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Chamada da rotina para ajuste do status da planilha e itens >--

aRet:= U_SIPCOA14()

Return(.t.)
