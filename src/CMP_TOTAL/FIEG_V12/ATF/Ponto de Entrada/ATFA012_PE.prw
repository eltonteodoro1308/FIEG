#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} ATFA012
P.E. MVC da rotina Cadastro de Ativos (ATFA012).

@type function
@author Kley@TOTVS.com.br
@since 16/04/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@return L�gico, Fixo Verdadeiro.

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

//--< Log das Personaliza��es >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
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
			
			If (INCLUI) .And. !FunName() == "ATFA240"

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
