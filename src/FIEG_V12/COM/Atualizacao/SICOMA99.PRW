#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA99
Realizar ajustes em alguns campos, ap�s o mesmo estar bloqueado para edi��o.

@type function
@author Thiago Rasmussen
@since 01/06/2017
@version P12.1.23

@param OPCAO, , descricao

@obs Desenvolvimento FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMA99(OPCAO)
	Local oGet1     := Nil
	Local oGroup1   := Nil
	Local oSButton1 := Nil
	Local oComboBox := {"1 - Normal","2 - Licita��o"}
	Local lSegue    := .T.

	Private oDlg    := Nil
	Private cGet1
	Private _OPCAO  := OPCAO


	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If !EMPTY(SC1->C1_PEDIDO)
		MsgAlert('Solicita��o j� est� associada a um pedido de compra, portanto n�o pode ser ajustada!','SICOMA99')
		lSegue := .F. //Return NIL
	EndIf

	If lSegue .And. !EMPTY(SC1->C1_COTACAO)
		MsgAlert('Solicita��o j� est� associada a uma cota��o, portanto n�o pode ser ajustada!','SICOMA99')
		lSegue := .F. //(Return NIL
	EndIf

	If lSegue

		DO CASE
			CASE _OPCAO == 'FILIAL'
			If !SUBSTR(SC1->C1_FILIAL,1,4)$'02GO;03GO'
				MsgAlert('O processo de ajustar a filial de entrega � permitido somente para solicita��es do SESI ou SENAI.','SICOMA99')
				lSegue := .F. //Return NIL
			EndIf

			If lSegue .And. SC1->C1_FILIAL$'02GO0001;03GO0001'
				MsgAlert('O processo de ajustar a filial de entrega n�o � permitido para solicita��es da Matriz SESI ou Matriz SENAI.','SICOMA99')
				lSegue := .F. //Return NIL
			EndIf

		EndCase

		If lSegue

			DEFINE MSDIALOG oDlg TITLE 'Ajustar' FROM 000, 000  TO 102, 163 COLORS 0, 16777215 PIXEL

			DO CASE
				CASE _OPCAO == 'COMPRADOR'
				cGet1 := Space(3)
				@ 005, 005 GROUP oGroup1 TO 030, 080 PROMPT " Comprador " OF oDlg COLOR 0, 16777215 PIXEL
				@ 013, 010 MSGET oGet1 VAR cGet1 SIZE 065, 010 OF oDlg COLORS 0, 16777215 F3 "SY1" VALID Empty(cGet1) .OR. ExistCPO("SY1",cGet1) WHEN .T. PIXEL
				CASE _OPCAO == 'FILIAL'
				cGet1 := Space(8)
				@ 005, 005 GROUP oGroup1 TO 030, 080 PROMPT " Filial de Entrega " OF oDlg COLOR 0, 16777215 PIXEL
				@ 013, 010 MSGET oGet1 VAR cGet1 SIZE 065, 010 OF oDlg COLORS 0, 16777215 F3 "XSM0" VALID Empty(cGet1) .OR. ExistCPO("SM0",cEmpAnt+cGet1) WHEN .T. PIXEL
				CASE _OPCAO == 'TIPO'
				cGet1 := Space(13)
				@ 005, 005 GROUP oGroup1 TO 030, 080 PROMPT " Tipo da Solicita��o " OF oDlg COLOR 0, 16777215 PIXEL
				@ 013, 010 MSCOMBOBOX oGet1 VAR cGet1 Items oComboBox SIZE 065, 010 OF oDlg COLORS 0, 16777215 PIXEL
			ENDCASE

			@ 035, 005 BUTTON oButton1 PROMPT "Confirmar" SIZE 050, 012 OF oDlg ACTION Confirmar() PIXEL

			ACTIVATE MSDIALOG oDlg CENTERED

		End If

	End If

Return NIL

/*/================================================================================================================================/*/
/*/{Protheus.doc} Confirmar
Fun��o executada pelo bot�o confirmar da tela se ajustes.

@type function
@author Thiago Rasmussen
@since
@version P12.1.23

@obs Desenvolvimento FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

STATIC FUNCTION Confirmar()
	Local _CHAVE    := XFilial("SC1")+SC1->C1_NUM
	Local _MENSAGEM := ''
	Local lSegue    := .T.

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If EMPTY(cGet1)
		MsgAlert('Informe o campo acima que voc� deseja ajustar.','SICOMA99')
		lSegue := .F. //Return .F.
	EndIf

	If lSegue

		DO CASE

			CASE _OPCAO == 'COMPRADOR'

			If SC1->C1_CODCOMP == cGet1
				MsgAlert('N�o � necess�rio ajustar do comprador "' + ALLTRIM(POSICIONE("SY1",1,xFILIAL("SY1") + SC1->C1_CODCOMP,"Y1_NOME")) + '" para "' + ALLTRIM(POSICIONE("SY1",1,xFILIAL("SY1") + cGet1,"Y1_NOME")) + '". Trata-se da mesma informa��o!','SICOMA99')
				lSegue := .F. //Return .F.
			EndIf

			_MENSAGEM := 'Confirma o ajuste do comprador "' + ALLTRIM(POSICIONE("SY1",1,xFILIAL("SY1") + SC1->C1_CODCOMP,"Y1_NOME")) + '" para "' + ALLTRIM(POSICIONE("SY1",1,xFILIAL("SY1") + cGet1,"Y1_NOME")) + '", da solicita��o de compra ' + SC1->C1_FILIAL + ' - ' + SC1->C1_NUM + '?'

			CASE _OPCAO == 'FILIAL'

			If SC1->C1_FILENT == cGet1
				MsgAlert('N�o � necess�rio ajustar da filial de entrega "' + SC1->C1_FILENT + '" para "' + cGet1 + '". Trata-se da mesma informa��o!','SICOMA99')
				lSegue := .F. //Return .F.
			EndIf

			If lSegue .And. SUBSTR(SC1->C1_FILIAL,1,4) <> SUBSTR(cGet1,1,4)
				MsgAlert('N�o � permitido ajustar da entidade "' + SUBSTR(SC1->C1_FILENT,1,4) + '" para "' + SUBSTR(cGet1,1,4) + '".','SICOMA99')
				lSegue := .F. //Return .F.
			EndIf

			If lSegue .And. SUBSTR(SC1->C1_FILENT,3,6) == 'GO0001' .AND. cGet1 <> SC1->C1_FILIAL
				MsgAlert('N�o � permitido ajustar para outra filial de entrega diferente de "' + SC1->C1_FILIAL + '".','SICOMA99')
				lSegue := .F. //Return .F.
			EndIf

			If lSegue .And. SUBSTR(SC1->C1_FILENT,3,6) <> 'GO0001' .AND. !cGet1$'02GO0001;03GO0001'
				MsgAlert('N�o � permitido ajustar para outra filial de entrega diferente da Matriz do SESI ou Matriz do SENAI.','SICOMA99')
				lSegue := .F. //Return .F.
			EndIf

			_MENSAGEM := 'Confirma o ajuste da filial de entrega "' + SC1->C1_FILENT + '" para "' + cGet1 + '", da solicita��o de compra ' + SC1->C1_FILIAL + ' - ' + SC1->C1_NUM + '?'

			CASE _OPCAO == 'TIPO'

			If SC1->C1_TPSC == SUBSTR(cGet1,1,1)
				MsgAlert('N�o � necess�rio ajustar o tipo da solicita��o de "' + IIf(SC1->C1_TPSC == '1','1 - Normal','2 - Licita��o') + '" para "' + cGet1 + '". Trata-se da mesma informa��o!','SICOMA99')
				lSegue := .F. //Return .F.
			EndIf

			_MENSAGEM := 'Confirma o ajuste do tipo da solicita��o "' + IIf(SC1->C1_TPSC == '1','1 - Normal','2 - Licita��o') + '" para "' + cGet1 + '", da solicita��o de compra ' + SC1->C1_FILIAL + ' - ' + SC1->C1_NUM + '?'

		EndCase

		If lSegue

			If MsgYesNo(_MENSAGEM,"Aten��o")
				SC1->(dbSetOrder(1))
				SC1->(MsSeek(XFilial("SC1")+SC1->C1_NUM))

				BEGIN Transaction

					WHILE SC1->(!EOF()) .AND. XFilial("SC1")+SC1->C1_NUM == _CHAVE
						RecLock("SC1",.F.)

						DO CASE
							CASE _OPCAO == 'COMPRADOR'
							SC1->C1_XCODCOM := cGet1
							SC1->C1_CODCOMP := cGet1
							CASE _OPCAO == 'FILIAL'
							SC1->C1_FILENT := cGet1
							CASE _OPCAO == 'TIPO'
							SC1->C1_TPSC := cGet1
						ENDCASE

						SC1->(msUnlock())

						SC1->(dbSkip())
					ENDDO

				END Transaction

				oDlg:End()
			EndIf

		EndIf

	End If

Return NIL