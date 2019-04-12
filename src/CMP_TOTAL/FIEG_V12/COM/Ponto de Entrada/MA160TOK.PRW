#Include "Protheus.ch"
#Include "FileIo.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MA160TOK
Ponto de Entrada no final da analise cotacao.

@type function
@author Thiago Rasmussen
@since 06/11/2015
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 26/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorna Verdadeiro ou Falso para .

/*/
/*/================================================================================================================================/*/

User Function MA160TOK()

	Local aDadosCot
	LOcal aDadosCompl
	Local oDlg
	Local oRadio
	Local nOpca       := 0
	Local lPrjCni     := FindFunction("PRJCNI") .Or. GetRpoRelease("R6")
	Local sMsg01      := ""
	Local nCont01     := 0
	Local sMsg02      := ""
	Local nCont02     := 0
	Local sMsg03      := ""
	Local nCont03     := 0
	Local sMsg04      := ""
	Local nCont04     := 0
	Local sMsg        := ""
	Local nCont       := 0
	Local iC8_PRODUTO := 0
	Local iC8_NUMSC   := 0
	Local iC8_ITEMSC  := 0
	Local nC1_VUNIT   := 0
	Local lGanhador   := .F.
	Local _FILE       := "INCONSISTENCIAS_COTACAO__" + DTOS(DATE()) + "__" + SUBSTR(TIME(),1,2) + "_" + SUBSTR(TIME(),4,2) + "_" + SUBSTR(TIME(),7,2) + ".TXT"
	Local aAuditoria  := PARAMIXB[4]
	Local iX01        := 0
	Local iX02        := 0
	Local lRet        := .T.

	Private nRadio

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	For I := 1 To Len(PARAMIXB[5][1][1])
		If PARAMIXB[5][1][1][I][01] == 'C8_PRODUTO'
			iC8_PRODUTO := I
		ElseIf PARAMIXB[5][1][1][I][01] == 'C8_NUMSC'
			iC8_NUMSC := I
		ElseIf PARAMIXB[5][1][1][I][01] == 'C8_ITEMSC'
			iC8_ITEMSC := I
		EndIf

		If iC8_PRODUTO > 0 .AND. iC8_NUMSC > 0 .AND. iC8_ITEMSC > 0
			EXIT
		EndIf
	Next I

	FOR I := 1 TO Len(PARAMIXB[3])
		iX01 := 0
		iX02 := 0

		FOR J := 1 TO Len(PARAMIXB[3][I])
			// 28/10/2013 - Thiago Rasmussen - Valida se o valor unitário da proposta ganhadora não é maior que o valor unitário da SC
			If !Empty(PARAMIXB[3][I][J][1])
				lGanhador := .T.
				nC1_VUNIT := POSICIONE("SC1",1,XFILIAL("SC1")+PARAMIXB[5][I][J][iC8_NUMSC][02]+PARAMIXB[5][I][J][iC8_ITEMSC][02],"SC1->C1_VUNIT")
				If PARAMIXB[3][I][J][14] > nC1_VUNIT
					nCont01 += 1
					sMsg01 += CRLF + CRLF + STRZERO(I,3) + " / " + STRZERO(Len(PARAMIXB[3]),3) + " || " + ALLTRIM(PARAMIXB[5][I][J][iC8_PRODUTO][2]) + " - " + ALLTRIM(POSICIONE("SB1",1,xFilial("SB1")+PARAMIXB[5][I][J][iC8_PRODUTO][2],"SB1->B1_DESC")) + CRLF + "Cotação: R$ " + ALLTRIM(TRANSFORM(PARAMIXB[3][I][J][14],"@e 999,999,999.99")) + " x " + "Solicitação: " + XFILIAL("SC1") + " / " + PARAMIXB[5][I][J][iC8_NUMSC][02] + " / " + PARAMIXB[5][I][J][iC8_ITEMSC][02] + " / R$ " + ALLTRIM(TRANSFORM(nC1_VUNIT,"@e 999,999,999.99"))
				EndIf

				// 28/10/2013 - Thiago Rasmussen - Valida se informou o motivo, da troca do fornecedor ganhador da cotação
				If PARAMIXB[4][I][J][8] == 0
					If PARAMIXB[4][I][J][5] == '001' .OR. Len(ALLTRIM(PARAMIXB[4][I][J][6])) < 5
						nCont02 += 1
						sMsg02 += CRLF + CRLF + STRZERO(I,3) + " / " + STRZERO(Len(PARAMIXB[3]),3) + " || " + ALLTRIM(PARAMIXB[5][I][J][iC8_PRODUTO][2]) + " - " + ALLTRIM(POSICIONE("SB1",1,xFilial("SB1")+PARAMIXB[5][I][J][iC8_PRODUTO][2],"SB1->B1_DESC")) + " || Fornecedor: " + ALLTRIM(PARAMIXB[4][I][J][2])
					EndIf
				EndIf
			EndIf

			// 12/12/2018 - Thiago Rasmussen - Para os itens com menos de 3 propostas com valores, o critério de julgamento e o motivo devem ser informados.
			If PARAMIXB[3][I][J][6] > 0
				iX01 += 1

				If PARAMIXB[4][I][J][5] != '001' .AND. ALLTRIM(PARAMIXB[4][I][J][6]) != 'ENCERRADO AUTOMATICAMENTE' .AND. !Empty(ALLTRIM(PARAMIXB[4][I][J][6]))
					iX02 += 1
				EndIf

				If !Empty(PARAMIXB[3][I][J][1])
					sMsg := CRLF + CRLF + STRZERO(I,3) + " / " + STRZERO(Len(PARAMIXB[3]),3) + " || " + ALLTRIM(PARAMIXB[5][I][J][iC8_PRODUTO][2]) + " - " + ALLTRIM(POSICIONE("SB1",1,xFilial("SB1")+PARAMIXB[5][I][J][iC8_PRODUTO][2],"SB1->B1_DESC")) + " || Fornecedor: " + ALLTRIM(PARAMIXB[4][I][J][2])
				EndIf
			EndIf

			If J == LEN(PARAMIXB[3][I]) .AND. iX01 < 3 .AND. iX02 == 0
				nCont04 += 1
				sMsg04 += sMsg
			EndIf

			JJ := J
		Next J

		If lGanhador == .F.
			nCont03 += 1
			sMsg03 += CRLF + CRLF + STRZERO(I,3) + " / " + STRZERO(Len(PARAMIXB[3]),3) + " || " + ALLTRIM(PARAMIXB[5][I][JJ][iC8_PRODUTO][2]) + " - " + ALLTRIM(POSICIONE("SB1",1,xFilial("SB1")+PARAMIXB[5][I][JJ][iC8_PRODUTO][2],"SB1->B1_DESC"))
		EndIf
		lGanhador := .F.

	Next I

	sMsg := ""

	If !Empty(sMsg01) .AND. Empty(sMsg)
		sMsg  := "O valor unitário da cotação ganhadora não pode ultrapassar o valor unitário estimado na solicitação de compra." + sMsg01
		nCont := nCont01
	EndIf

	If !Empty(sMsg02) .AND. Empty(sMsg)
		sMsg  := "Como a cotação ganhadora de determinada proposta foi alterada, selecione o novo critério de julgamento e descreva o " + ;
		"motivo de selecionar outro ganhador, para cada um dos itens listados abaixo:" + sMsg02
		nCont := nCont02
	EndIf

	If !Empty(sMsg03) .AND. Empty(sMsg)
		sMsg  := "Para todos itens que passaram pelo processo de atualização da cotação se faz necessário informar o fornecedor ganhador, " + ;
		"informe o fornecedor ganhador para cada um dos itens listados abaixo:" + sMsg03
		nCont := nCont03
	EndIf

	If !Empty(sMsg04) .AND. Empty(sMsg)
		sMsg  := "Para todos itens da cotação com menos de 3 propostas com valor, é obrigatório informar um novo critério de julgamento e " + ;
		"descrever o motivo, para cada um dos itens listados abaixo:" + sMsg04
		nCont := nCont04
	EndIf

	If !Empty(sMsg)
		If nCont <= 5
			MsgAlert(sMsg,"MA160TOK")
		ELSE
			MsgAlert("Foram encontradas " + ALLTRIM(STR(nCont)) + " inconsistências, verifique!","MA160TOK")

			nArquivo := fcreate("C:\" + _FILE, FC_NORMAL)
			fwrite(nArquivo, sMsg)
			fclose(nArquivo)

			If ShellExecute( "Open", "notepad.exe", _FILE, "C:\", 1 ) <= 32
				MsgAlert("Foi gerado o seguinte arquivo com todas as inconsistências encontradas." + CRLF + CRLF + "C:\" + _FILE,"MA160TOK")
				MsgAlert(sMsg,"MA160TOK")
			EndIf
		EndIf

		lRet :=  .F.
	EndIf

	If lPrjCni
		aDadosCot   := PARAMIXB[3]
		aDadosCompl := PARAMIXB[5]
		If ParamIXB[1] <> 2  // Nao e visualizacao
			DEFINE MSDIALOG oDlg FROM  094,1 TO 220,293 TITLE "Gerar:" PIXEL
			@ 05,07 TO 42, 140 OF oDlg  PIXEL
			@ 10,10 Radio oRadio VAR nRadio;
			ITEMS "Pedido de Compra" + IIF(SUBSTR(SC8->C8_NPROC,1,2) == 'CP', " [Desabilitado]", ""),;
			"Contrato" + IIF(SUBSTR(SC8->C8_NPROC,1,2) == 'CP', " de Parceria", "");
			3D SIZE 120,15 OF oDlg PIXEL
			// 29/11/2016 - Thiago Rasmussen - Verificar se trata-se de uma solicitação de compra do tipo contrato de parceria
			If SUBSTR(SC8->C8_NPROC,1,2) == 'CP'
				oRadio:EnableItem(1, .F.)
				oRadio:SetOption(2)
			EndIf

			DEFINE SBUTTON FROM 45,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
			DEFINE SBUTTON FROM 45,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

			ACTIVATE MSDIALOG oDlg CENTERED

			DBSELECTAREA("SC8")
			cNum := SC8->C8_NUM

			If nOpca == 1
				Do Case
					Case nRadio == 1
					lRet :=  .T.
					Case nRadio == 2
					If !(U_CNIA100('2', cNum, aDadosCot, aDadosCompl, aAuditoria))
						lRet :=  .F.
					EndIf
					Case nRadio == 3
					If !(U_CNIA100('3', cNum, aDadosCot, aDadosCompl))
						lRet :=  .F.
					EndIf
				End Case
			Else
				lRet :=  .F.
			EndIf
		EndIf

		Pergunte("MTA160",.F.) //Restaura parametros da cotacao

	EndIf

Return lRet