#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT060GRV
Ponto de Entrada após inclusao/alteracao de Produtos x Fornecedores.

@type function
@author TOTVS
@since 21/03/2012
@version P12.1.23

@obs Projeto ELO

@history 26/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/


User Function MT060GRV()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") 	/*Rotina ESB*//*Rotina CARGA*/   
	SZZ->(dbSetOrder(1))
    IF SZZ->(dbSeek(XFilial("SZZ")+"MATA060"))
		MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA13(,IIF(INCLUI,3,4) ) } )
    Endif
Endif   

Return()
