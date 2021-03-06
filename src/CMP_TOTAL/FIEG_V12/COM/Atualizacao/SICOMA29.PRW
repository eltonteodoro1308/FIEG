#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA29
Envia Workflow para Fornecedor.

@type function
@author TOTVS
@since 20/09/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, Retorna Verdadeiro se valida��es estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function SICOMA29()

Local lRet := .T.

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Verifica se o pedido esta liberado >------------------
If lRet .and. SC7->C7_QUJE >= SC7->C7_QUANT
	Aviso("Atencao","Op��o dispon�vel somente para pedidos liberados. Verifique!",{"Sair"})
	lRet := .F.
EndIf

// Verifica se o PC est� bloqueado
If lRet .and. SC7->C7_CONAPRO <> "L"
	Aviso("Atencao","Op��o dispon�vel somente para pedidos liberados. Verifique!",{"Sair"})
	lRet := .F.
EndIf

// Verifica se o PC est� eliminado
If lRet .and. SC7->C7_RESIDUO == "S"
	Aviso("Atencao","Pedido eliminado por res�duo. Verifique!",{"Sair"})
	lRet := .F.
EndIf

// verifica se o e-mail j� foi enviado
If lRet .and. SC7->C7_WFE_FOR
	If Aviso("Atencao","Este pedido j� foi enviado ao fornecedor, deseja enviar novamente ?",{"Sim","N�o"}) <> 1
		lRet := .F.
	EndIf
EndIf

If lRet
	MsgRun('Enviando pedido para fornecedor...',, {|| U_CWKFA005(SC7->C7_NUM,.t.) } )
EndIf

Return lRet
