#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} M030INC
PE apos inclusao de fornecedores.

@type function
@author TOTVS
@since 19/02/2012
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT20FOPOS()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") 	/*Rotina ESB*//*Rotina CARGA*/    
	SZZ->(dbSetOrder(1))
    IF SZZ->(dbSeek(XFilial("SZZ")+"MATA020"))
		MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA02(,ParamIXB[1]) } )  
    Endif

Endif   

Return()
