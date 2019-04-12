#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} QE030VLD
PE para validar manutencao de Unidade de Medida.

@type function
@author TOTVS
@since 21/03/2012
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function QE030VLD()

Local _lRet := .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If  !IsInCallStack("U_SIESBA01") .and.  !IsInCallStack("U_SICFGA01") /*Rotina ESB*//*Rotina CARGA*/
	SZZ->(dbSetOrder(1))
	IF SZZ->(dbSeek(XFilial("SZZ")+"QIEA030"))
		MsgRun('Enviando pacote para ESB. Aguarde...',, {|| U_SIESBA12(,IIF(INCLUI,3,IIF(ALTERA,4,5))) } )    
	EndIf
EndIf

Return(_lRet)
