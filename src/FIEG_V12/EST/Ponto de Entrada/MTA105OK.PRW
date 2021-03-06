#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MTA105OK
Valida��o da Inclus�o de Solicita��o de Armaz�m.

@type function
@author Leonardo Soncin
@since 10/02/2012
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso para valida��o da inclus�o de Solicita��o de Armaz�m.

/*/
/*/================================================================================================================================/*/

User Function MTA105OK()
	Local lRet   	:= .T.
	Local nPConta	:= aScan(aHeader,{|x| AllTrim(x[2])=="CP_CONTA"})
	Local aArea		:= GetArea()
	Local cPrefix	:= ""
	Local nX		:= 0

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	For nX := 1 to Len(aCols)

		If !(GdDeleted( nX, aHeader, aCols))
			dbSelectArea("CT1")
			CT1->(dbSetOrder(1))
			CT1->(dbSeek(xFilial("CT1")+aCols[nX][nPConta]))
			cPrefix	:= CT1->CT1_PREFIX

			dbSelectArea("SZQ")
			CT1->(dbSetOrder(1))
			If !CT1->(dbSeek(xFilial("SZQ")+_c105CCusto+cPrefix))
				If !CT1->(dbSeek(xFilial("SZQ")+_c105CCusto+Space(TamSX3("CT1_PREFIX")[1])))
					MsgStop("O Centro de custo "+Alltrim(_c105CCusto)+" e o prefixo "+Alltrim(cPrefix)+" n�o possuem grupo de aprova��o cadastrado.","Aten��o")
					lRet := .F.
					Exit
				ENDIF
			Endif

			If nX > 1

				dbSelectArea("CT1")
				CT1->(dbSetOrder(1))
				CT1->(dbSeek(xFilial("CT1")+aCols[1][nPConta])) // Prefixo da 1a Linha
				If CT1->CT1_PREFIX <> cPrefix
					MsgStop("Prefixo "+cPrefix+" diferente do prefixo do 1o. item da solicita��o.")
					lRet := .F.
					Exit
				Endif
			Endif
		Endif
	Next

	RestArea(aArea)
Return lRet
