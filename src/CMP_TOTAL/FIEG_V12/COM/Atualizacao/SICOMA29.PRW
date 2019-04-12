#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA29
Envia Workflow para Fornecedor.

@type function
@author TOTVS
@since 20/09/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna Verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function SICOMA29()

Local lRet := .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Verifica se o pedido esta liberado >------------------
If lRet .and. SC7->C7_QUJE >= SC7->C7_QUANT
	Aviso("Atencao","Opção disponível somente para pedidos liberados. Verifique!",{"Sair"})
	lRet := .F.
EndIf

// Verifica se o PC está bloqueado
If lRet .and. SC7->C7_CONAPRO <> "L"
	Aviso("Atencao","Opção disponível somente para pedidos liberados. Verifique!",{"Sair"})
	lRet := .F.
EndIf

// Verifica se o PC está eliminado
If lRet .and. SC7->C7_RESIDUO == "S"
	Aviso("Atencao","Pedido eliminado por resíduo. Verifique!",{"Sair"})
	lRet := .F.
EndIf

// verifica se o e-mail já foi enviado
If lRet .and. SC7->C7_WFE_FOR
	If Aviso("Atencao","Este pedido já foi enviado ao fornecedor, deseja enviar novamente ?",{"Sim","Não"}) <> 1
		lRet := .F.
	EndIf
EndIf

If lRet
	MsgRun('Enviando pedido para fornecedor...',, {|| U_CWKFA005(SC7->C7_NUM,.t.) } )
EndIf

Return lRet
