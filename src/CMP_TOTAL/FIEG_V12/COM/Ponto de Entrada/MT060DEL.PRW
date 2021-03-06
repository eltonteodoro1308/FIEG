#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT060DEL
Ponto de Entrada ap�s exclusao de Produtos x Fornecedores.

@type function
@author TOTVS
@since 21/03/2012
@version P12.1.23

@obs Projeto ELO

@history 26/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return Num�rico, Retorna o mesmo conte�do recebido pelo ParamIXB.
/*/
/*/================================================================================================================================/*/

User Function MT060DEL()

Local _nRet := PARAMIXB

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") 	/*Rotina ESB*//*Rotina CARGA*/    
	SZZ->(dbSetOrder(1))
    IF SZZ->(dbSeek(XFilial("SZZ")+"MATA060"))
		MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA13(,5) } )     
    Endif
	
Endif   

Return(_nRet)
