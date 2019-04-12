#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MTA105OK
Validação da Inclusão de Solicitação de Armazém.

@type function
@author Leonardo Soncin
@since 10/02/2012
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.
@history 11/04/2019, elton.alves@TOTVS.com.br, Ajuste para popular a variável _c105CCusto da SA (linha 36).

@return Lógico, Verdadeiro ou Falso para validação da inclusão de Solicitação de Armazém.

/*/
/*/================================================================================================================================/*/

User Function MTA105OK()
	Local lRet   	:= .T.
	Local nPConta	:= aScan(aHeader,{|x| AllTrim(x[2])=="CP_CONTA"})
	Local aArea		:= GetArea()
	Local cPrefix	:= ""
	Local nX		:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	For nX := 1 to Len(aCols)

	_c105CCusto := aCols[ nX, aScan(aHeader,{|x| AllTrim(x[2])=="CP_CC"})]

		If !(GdDeleted( nX, aHeader, aCols))
			dbSelectArea("CT1")
			CT1->(dbSetOrder(1))
			CT1->(dbSeek(xFilial("CT1")+aCols[nX][nPConta]))
			cPrefix	:= CT1->CT1_PREFIX

			dbSelectArea("SZQ")
			SZQ->(dbSetOrder(1))
			If !SZQ->(dbSeek(xFilial("SZQ")+_c105CCusto+cPrefix))
				If !SZQ->(dbSeek(xFilial("SZQ")+_c105CCusto+Space(TamSX3("CT1_PREFIX")[1])))
					MsgStop("O Centro de custo "+Alltrim(_c105CCusto)+" e o prefixo "+Alltrim(cPrefix)+" não possuem grupo de aprovação cadastrado.","Atenção")
					lRet := .F.
					Exit
				ENDIF
			Endif

			If nX > 1

				dbSelectArea("CT1")
				CT1->(dbSetOrder(1))
				CT1->(dbSeek(xFilial("CT1")+aCols[1][nPConta])) // Prefixo da 1a Linha
				If CT1->CT1_PREFIX <> cPrefix
					MsgStop("Prefixo "+cPrefix+" diferente do prefixo do 1o. item da solicitação.")
					lRet := .F.
					Exit
				Endif
			Endif
		Endif
	Next

	RestArea(aArea)
Return lRet
