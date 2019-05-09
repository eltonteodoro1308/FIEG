#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} ATFA012
P.E. MVC da rotina Cadastro de Ativos (ATFA012).

@type function
@author Kley@TOTVS.com.br
@since 16/04/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@return L�gico, Indica se o model � v�lido.

@history 16/04/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.
/*/
/*/================================================================================================================================/*/

User Function ATFA012()

	Local xRet 		 := .T.
	Local oObj 		 := ""
	Local cIdPonto 	 := ""
	Local cIdModel 	 := ""
	Local aArea		 := GetArea()
	Local aAreaSN1	 := SN1->(GetArea())
	Local oModel 	 := FwModelActive()
	//Local nOperation := oModel:GetOperation()
	Local cBase      := ""


	If PARAMIXB <> NIL
		oObj       := PARAMIXB[1]								// Objeto do formul�rio ou do modelo, conforme o caso
		cIdPonto   := PARAMIXB[2]								// ID do local de execu��o do ponto de entrada
		cIdModel   := PARAMIXB[3]								// ID do formul�rio

		Do Case
			//Case cIdPonto == "FORMPRE"							// Antes da altera��o de qualquer campo do formul�rio
			//MsgInfo( "C�digo do Bem: " + oModel:GetValue("SN1MASTER", "N1_CBASE") + "/" + oModel:GetValue("SN1MASTER", "N1_ITEM") , "C�digo do Bem" )

			//Case cIdPonto == "MODELPRE"							// Antes da altera��o de qualquer campo do modelo
			//ConOut(FunName() + " MODELPRE - " + cValtoChar(nOperation))

			Case cIdPonto == "MODELPOS"							// Na valida��o total do modelo (TudoOK)

			//--< Log das Personaliza��es >-----------------------------
			//TODO U_LogCustom()

			//TODO xRet := VldCpos()

			If (INCLUI) .And. !FunName() == "ATFA240" .And. xRet

				cBase := oModel:GetValue("SN1MASTER", "N1_CBASE")
				SN1->(dbSetOrder(1))
				If SN1->(dbSeek(xFilial("SN1")+cBase))

					While !SN1->(MsSeek(xFilial("SN1")+cBase))
						cBase := Soma1(cBase)
						SN1->(dbSkip())
					EndDo

					oModel:LoadValue("SN1MASTER","N1_CBASE",cBase)	// Atribui um valor ao C�digo do Bem

					MsgInfo("O c�digo do bem foi alterado para "+cBase,"C�digo do Ativo Alterado")
				EndIf

				//--< Atualiza parametro >----------------------
				PutMV( "MV_CBASEAF", Soma1(Alltrim(cBase)) )

			EndIf

		EndCase

	EndIf

	RestArea(aArea)
	SN1->(RestArea(aAreaSN1))

Return(xRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} VldCpos
Valida a obrigatoriedade do preenchimento dos campos N1_LOCAL, N3_XTPBEM e N3_XCTAMUT
quanto da classifica��o de compra e inclus�o manual de um bem.

@type function
@author elton.alves@TOTVS.com.br
@since 08/05/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@return L�gico, Indica se o model � v�lido.

@history 08/05/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.
/*/
/*/================================================================================================================================/*/
Static Function VldCpos()

	Local lRet       := .T.
	Local nX         := 0
	Local oModel     := FwModelActive()
	Local oSn1Master := oModel:GetModel('SN1MASTER')
	Local oSn3Detail := oModel:GetModel('SN3DETAIL')

	// Verificado se � inclus�o e ou classifica��o manual do bem.
	If IsBlind()

		// Valida preenchimento do campo N1_LOCAL.
		If Empty( oSn1Master:GetValue( 'N1_LOCAL' ) )

			Help( ,, 'ATFA012_PE',, 'Campo "' + GetSx3Cache( 'N1_LOCAL', 'X3_TITULO' ) + '" (N1_LOCAL) deve ser preenchido.', 1, 0,,,,,, {'Preencha o campo antes de confirmar.'})
			lRet := .F.

		End If

		// Valida preenchimento do campo N3_XTPBEM e N3_XCTAMUT.
		For nX := 1 To oSn3Detail:GetQTDLine()

			If ! oSn3Detail:IsDeleted( nX )

				If Empty( oSn3Detail:GetValue( 'N3_XTPBEM', nX ) )

					Help( ,, 'ATFA012_PE',, 'Campo "' + GetSx3Cache( 'N3_XTPBEM', 'X3_TITULO' ) + '" (N3_XTPBEM) deve ser preenchido.', 1, 0,,,,,, {'Preencha o campo antes de confirmar.'})
					lRet := .F.
					Exit

				End If

				If Empty( oSn3Detail:GetValue( 'N3_XCTAMUT', nX ) )

					Help( ,, 'ATFA012_PE',, 'Campo "' + GetSx3Cache( 'N3_XCTAMUT', 'X3_TITULO' ) + '" (N3_XCTAMUT) deve ser preenchido.', 1, 0,,,,,, {'Preencha o campo antes de confirmar.'})
					lRet := .F.
					Exit

				End If

			End If

		Next nX

	End If

Return lRet
