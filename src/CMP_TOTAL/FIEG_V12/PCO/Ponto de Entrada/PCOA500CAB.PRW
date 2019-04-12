#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PCOA500CAB
PE para incluir campos na tela de liberacao de contingencia.

@type function
@author TOTVS
@since 03/05/2012
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Opções da rotina.
/*/
/*/================================================================================================================================/*/

User Function PCOA500CAB()

Local _aRet := nil

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF ALI->(FieldPos("ALI_XNUMSC")) > 0 .and. !Empty(ALI->ALI_XNUMSC)
	_aRet := {}
	Aadd(_aRet,"ALI_XNUMSC")
ENDIF

Return(_aRet)
