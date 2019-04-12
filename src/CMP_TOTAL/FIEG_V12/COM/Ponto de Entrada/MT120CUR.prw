#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120CUR
Ponto de entrada para procurar código do usuário logado quando está rodando por WF.

@type function
@author Bruna Paola - TOTVS
@since 26/03/2012
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, Código do Usuário Aprovador.
/*/
/*/================================================================================================================================/*/

User Function MT120CUR() 

Local cXU := ""

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cXU := cXApUsr

Return cXU
