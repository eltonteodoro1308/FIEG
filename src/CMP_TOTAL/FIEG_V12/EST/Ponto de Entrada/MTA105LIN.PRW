#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MTA105LIN
Validacao da Linha da Solicita��o de Armaz�m.

@type function
@author Leonardo Soncin
@since 10/02/2012
@version P12.1.23

@obs Projeto ELO

@history 20/03/2019, elton.alves@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23.

@return L�gico, Verdadeiro ou Falso para valida��o da Linha da Solicta��o de Armaz�m.

/*/
/*/================================================================================================================================/*/

User Function MTA105LIN()
	Local lRet   	:= .T.
	Local nPConta	:= aScan(aHeader,{|x| AllTrim(x[2])=="CP_CONTA"})
	Local aArea		:= GetArea()
	Local cPrefix	:= ""

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If n > 1
		dbSelectArea("CT1")
		CT1->(dbSetOrder(1))
		CT1->(dbSeek(xFilial("CT1")+aCols[n][nPConta]))
		cPrefix	:= CT1->CT1_PREFIX

		dbSelectArea("CT1")
		CT1->(dbSetOrder(1))
		CT1->(dbSeek(xFilial("CT1")+aCols[1][nPConta])) // Prefixo da 1a Linha
		If CT1->CT1_PREFIX <> cPrefix
			MsgStop("Prefixo "+cPrefix+" diferente do prefixo do 1o. item da solicita��o.")
			lRet := .F.
		Endif
	Endif

	RestArea(aArea)
Return lRet