#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SF1140I
Ponto de Entrada apos gravacao da pre-nota.

@type function
@author TOTVS
@since 12/09/2011
@version P12.1.23

@obs Projeto ELO

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SF1140I

Local lAtesto   := GETMV("MV_XATESTO")

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
dbSelectArea("SF1")

If (lAtesto == .T.)
	Reclock("SF1",.F.)
		SF1->F1_XATESTO := '1'
	SF1->(MsUnlock())
Else
	Reclock("SF1",.F.)
		SF1->F1_XATESTO := '3'
	SF1->(MsUnlock())
EndIf

//--< Alteracao dos dados bancarios >-----------------------
If ExistBlock("SICOMA10")
	U_SICOMA10()
EndIf

Return Nil
