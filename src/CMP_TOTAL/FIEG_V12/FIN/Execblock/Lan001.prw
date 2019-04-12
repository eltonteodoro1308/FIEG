#Include "Protheus.ch"
#Include "topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} LANC001
Lancamento padrao de RPA INSS.

@type function
@author Eduardo Pessoa
@since 19/02/2013
@version P12.1.23

@param cComando, Caractere, Indica o tipo de informação ser retornada.

@obs Desenvolvimento FIEG

@history 12/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Retorna o contéudo solictado conforme tipo solicitado.

/*/
/*/================================================================================================================================/*/

User Function LANC001(cComando)

	Local aSaveArea	:= GetArea()
//	Local cFilial   := xFilial("SE2")
	Local cPrefixo  := SE2->E2_PREFIXO
	Local cTitulo   := SE2->E2_NUM
	Local cFornec   := SE2->E2_FORNECE
	Local cLoja     := SE2->E2_LOJA
	Local cRet      := SA2->A2_NOME


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Do Case
		Case cComando == "HISTORICO"
		// Verifica o fornecedor do titulo principal
		dbSelectArea("SE2")
		dbSetOrder(1) // Filial+Prefixo+Numero+Parcela+Tipo+Fornecedor+Loja
		dbSeek(xFilial("SE2")+cPrefixo+cTitulo)
		While !Eof() .and. xFilial("SE2") == SE2->E2_FILIAL .and. SE2->E2_PREFIXO == cPrefixo .and. SE2->E2_NUM == cTitulo
			If SE2->E2_TIPO == "RPA"
				cFornec := SE2->E2_FORNECE
				cLoja   := SE2->E2_LOJA
				cRet := Posicione("SA2",1,xFilial("SA2")+cFornec+cLoja,"A2_NOME")
				Exit
			Endif
			dbSkip()
		End
		// Pega o fornecedor do título Principal

		Case cComando == "VALORINSS"

		Case cComando == "CONTADEB"

		Case cComando == "CONTACRE"

		Case cComando == "CCUSTODEB"

		Case cComando == "CCUSTOCRE"

		Otherwise

	EndCase

	//Restaura area
	RestArea(aSaveArea)

Return(Alltrim(cRet))
