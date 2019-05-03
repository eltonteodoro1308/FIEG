#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} ATFA012
P.E. MVC da rotina Cadastro de Ativos (ATFA012).

@type function
@author Kley@TOTVS.com.br
@since 16/04/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@return Lógico, Fixo Verdadeiro.

@history 16/04/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.
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

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If PARAMIXB <> NIL
	oObj       := PARAMIXB[1]								// Objeto do formulário ou do modelo, conforme o caso
	cIdPonto   := PARAMIXB[2]								// ID do local de execução do ponto de entrada
	cIdModel   := PARAMIXB[3]								// ID do formulário

	Do Case
		//Case cIdPonto == "FORMPRE"							// Antes da alteração de qualquer campo do formulário
			//MsgInfo( "Código do Bem: " + oModel:GetValue("SN1MASTER", "N1_CBASE") + "/" + oModel:GetValue("SN1MASTER", "N1_ITEM") , "Código do Bem" )

		//Case cIdPonto == "MODELPRE"							// Antes da alteração de qualquer campo do modelo
			//ConOut(FunName() + " MODELPRE - " + cValtoChar(nOperation))

		Case cIdPonto == "MODELPOS"							// Na validação total do modelo (TudoOK)
			
			If (INCLUI) .And. !FunName() == "ATFA240"

				cBase := oModel:GetValue("SN1MASTER", "N1_CBASE")
				SN1->(dbSetOrder(1))
				If SN1->(dbSeek(xFilial("SN1")+cBase))

					While !SN1->(MsSeek(xFilial("SN1")+cBase))
						cBase := Soma1(cBase)
						SN1->(dbSkip())
					EndDo
				
					oModel:LoadValue("SN1MASTER","N1_CBASE",cBase)	// Atribui um valor ao Código do Bem

					MsgInfo("O código do bem foi alterado para "+cBase,"Código do Ativo Alterado")
				EndIf
				
				//--< Atualiza parametro >----------------------
				PutMV( "MV_CBASEAF", Soma1(Alltrim(cBase)) )

			EndIf
			
	EndCase

EndIf

RestArea(aArea)
SN1->(RestArea(aAreaSN1))
	
Return(xRet)
