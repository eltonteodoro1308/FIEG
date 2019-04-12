#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PCOA5304
PE apos gravacao da ALI - Contingencia.

@type function
@author TOTVS
@since 03/05/2012
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function PCOA5304()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Grava numero da SC >----------------------------------
If ALI->(FieldPos("ALI_XNUMSC")) > 0
	RecLock("ALI",.F.)
	ALI->ALI_XNUMSC := SC1->C1_NUM
	ALI->(msUnlock())
EndIf

Return
