#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT035EXC
Ponto de Entrada ap�s exclusao de grupos de produto

@type function
@author TOTVS
@since 18/05/2012
@version P12.1.23

@obs Projeto ELO

@history 26/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, Retorna sempre verdadeiro.
/*/
/*/================================================================================================================================/*/

User Function MT035EXC()

Local _lRet := .T.

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") 	/*Rotina ESB*//*Rotina CARGA*/
  	SZZ->(dbSetOrder(1))
    IF SZZ->(dbSeek(XFilial("SZZ")+"MATA035"))
		MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA11("5") } )                          
    Endif
Endif   

Return(_lRet)