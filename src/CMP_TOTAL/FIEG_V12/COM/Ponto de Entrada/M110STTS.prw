#Include "Protheus.ch"
#Include "Topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} M110STTS
Ponto de entrada para enviar solicitação para aprovação.

@type function
@author TOTVS
@since 06/14/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 22/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function M110STTS() 

//Local cNum   := PARAMIXB[1]
//Local nOpc   := PARAMIXB[2] 								// Não utilizado.
Local lCopia := PARAMIXB[3]
Local _lBlq  := PARAMIXB[4] 								//Envio de WF na copia ou bloqueio da SC

Local lPrjCni := FindFunction("PRJCNI")

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Envia solicitação para aprovação >--------------------
If lPrjCni   
	If !l110Auto 
		If INCLUI .OR. lCopia .OR. ALTERA
			If _lBlq = .F. .AND. ALTERA
				TCSPEXEC('SP_ALCADA_APROVACAO', SC1->C1_FILIAL, SC1->C1_NUM, 'SC')
			EndIf

			If SC1->C1_WFE == .F.
				If MsgYesNo('Caso a solicitação já esteja concluída para iniciar a aprovação, a mesma vai ser enviada para o e-mail dos usuários da alçada de aprovação.' + CRLF + CRLF + 'Deseja realmente enviar para iniciar a aprovação?','M110STTS')
					MsgRun('Enviando solicitação para aprovação...',, {|| U_CWKFA001(,XFilial("SC1"),SC1->C1_NUM) })
				EndIf
			EndIf
				
			RecLock("SC1",.F.) 
				SC1->C1_XMODOC := '0'
			SC1->(MsUnlock())           
		EndIf
	EndIf
EndIf

Return Nil
