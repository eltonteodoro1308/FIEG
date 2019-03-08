#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CN100GRC
Função utilizada na gravação do contrato.

@type function
@author José Fernando
@since 21/09/2016
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CN100GRC()
	Local _AREA
	Local _ANO          := ""
	Local _OK           := .F.
	Local _SQL          := ""
	Private _SEQUENCIAL := ""


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// 	PARAMIXB[1] - Opcao selecionada pelo usuario. 2 - Visualizar, 3 - Incluir, 4 - Alterar, 5- Excluir
	// 	PARAMIXB[2] - Array com os cabecalhos de planilhas
	// 	PARAMIXB[3] - Array com os itens das planilhas
	// 	PARAMIXB[4] - Array com o cabeçalho da Planilha(CNA)
	// 	PARAMIXB[5] - Array com o cabeçalho dos Itens da Planilha (CNB)

	// Caso seja uma inclusão de um contrato e o número do processo esteja vazio, gerar o número de processo
	If PARAMIXB[1] == 3 .AND. EMPTY(M->CN9_NUMPR)
		_AREA := GetArea()

		_ANO := AllTrim(Str(Year(dDataBase)))

		DbSelectArea("PA8")
		PA8->(DbSetOrder(1))
		If PA8->(DbSeek(xFilial("PA8")+AllTrim(M->CN9_XMDAQU)+_ANO))
			_SEQUENCIAL := Soma1(PA8->PA8_SEQ)
			If PA8_BLQ == "0"
				RecLock("PA8",.F.)
				PA8->PA8_BLQ := "1"
				PA8->PA8_SEQ := _SEQUENCIAL
				PA8->(MsUnlock())
			EndIf
		Else
			If PA8->(DbSeek(xFilial("PA8")+AllTrim(M->CN9_XMDAQU)))
				_SEQUENCIAL := "00001"
				RecLock("PA8",.F.)
				PA8->PA8_FILIAL := xFilial("PA8")
				PA8->PA8_BLQ 	:= "1"
				PA8->PA8_SEQ 	:= _SEQUENCIAL
				PA8->PA8_ANO 	:= AllTrim(_ANO)
				PA8->(MsUnlock())
			Else
				_SEQUENCIAL := "00001"
				RecLock("PA8",.T.)
				PA8->PA8_FILIAL := xFilial("PA8")
				PA8->PA8_MOD 	:= AllTrim(M->CN9_XMDAQU)
				PA8->PA8_BLQ 	:= "1"
				PA8->PA8_SEQ 	:= _SEQUENCIAL
				PA8->PA8_ANO 	:= AllTrim(_ANO)
				PA8->(MsUnlock())
			EndIf
		EndIf

		DbSelectArea("CN9")
		CN9->(dbCloseArea())
		DbSelectArea("CN9")
		CN9->(DbSetOrder(1))
		If CN9->(DbSeek(xFilial("CN9")+M->CN9_NUMERO+M->CN9_REVISA))
			RecLock("CN9",.F.)
			CN9->CN9_NUMPR := AllTrim(M->CN9_XMDAQU) + _SEQUENCIAL + _ANO
			CN9->(MsUnlock())
			_OK = .T.
		EndIf

		If _OK
			DbSelectArea("PA8")
			PA8->(DbSetOrder(1))
			If PA8->(DbSeek(xFilial("PA8")+AllTrim(M->CN9_XMDAQU)+AllTrim(_ANO)))
				If PA8->PA8_SEQ == _SEQUENCIAL
					RecLock("PA8",.F.)
					PA8->PA8_BLQ := "0"
					PA8->(MsUnlock())
				EndIf
			EndIf
		EndIf

		RestArea(_AREA)
	EndIf

	// 09/10/2017 - Thiago Rasmussen - Campo utilizado para o processo de revisão de contrato.
	If EMPTY(CN9->CN9_REVISA)
		_SQL := "UPDATE CNB010 SET CNB_XITEM = CNB_ITEM " +;
		"WHERE CNB_FILIAL = '" + CN9->CN9_FILIAL + "' AND " +;
		"      CNB_CONTRA = '" + CN9->CN9_NUMERO + "' AND " +;
		"      CNB_REVISA = '' AND " +;
		"      CNB_XITEM = ''"

		TCSQLExec(_SQL)
	EndIf

Return NIL