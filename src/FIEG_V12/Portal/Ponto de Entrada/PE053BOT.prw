#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PE053BOT
Ponto de entrada para tratar bot�o de confirma��o e recebimento de pedidos - Customiza��o CNI.

@type function
@author Thiago Rasmussen
@since 07/21/2011
@version P12.1.23

@obs Projeto ELO

@history 25/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return Caractere, Trecho Html com a altera��o para tratar bot�o de confirma��o e recebimento de pedidos.

/*/
/*/================================================================================================================================/*/

User Function PE053BOT()
	Local cHtml
	Local cStatus
	Local cPedido
	Local oObj
	Local lPrjCni    := FindFunction("ValidaCNI") .And. ValidaCNI()

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If lPrjCni
		cStatus := "1"
		cPedido := substr(HttpSession->PWSF053APH[1],16,6)
		oObj  := WSWSCNIESTAT():NEW()
		oObj:GetStatusBut(cPedido)
		cStatus := oObj:cGetStatusButResult

		//nao enviado
		If cStatus = "1"
			cHtml:=	'	<input name="Btn" id="onbot" type="button"  value="Pedido Recebido"   class="Botoes" onclick="fFun(this)" disabled="true" >'
			//emitido
		Elseif cStatus = "2"
			cHtml:='	<input name="Btn" id="onbot" type="button"  value="Pedido Recebido"   class="Botoes" onclick="fFun(this)"				  >'
			//recebido
		Elseif cStatus = "3"
			cHtml:='	<input name="Btn" id="onbot" type="button"  value="Pedido Confirmado" class="Botoes" onclick="fFun(this)"				  >'
			//confirmado
		Elseif cStatus = "4"
			cHtml:='	<input name="Btn" id="onbot" type="button"  value="Pedido Confirmado" class="Botoes" onclick="fFun(this)" disabled="true" >'
		Else
			cHtml:=	'	<input name="Btn" id="onbot" type="button"  value="Pedido Recebido"   class="Botoes" onclick="fFun(this)" disabled="true" >'
		Endif
	EndIf

Return cHtml

