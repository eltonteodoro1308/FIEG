#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT010EXC
Ponto de Entrada após exclusão de produtos. 

@type function
@author TOTVS
@since 19/02/2012
@version P12.1.23

@obs Projeto ELO

@history 26/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT010EXC()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
SZZ->(dbSetOrder(1))
If SZZ->(dbSeek(xFilial("SZZ")+"MATA010"))
	MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA10() } )
Endif

Return()
