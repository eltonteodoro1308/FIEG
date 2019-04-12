#Include "Protheus.ch"
#Include "topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT103FIM
Ponto de Entrada de finalização do processo de inclusao de documento de entrada.
Chamado CSC133043 - Colocado o tratamento para o ponterar nos titulos gerados para gravar a modalidade de pagamento.

@type function
@author Leandro Ribeiro
@since 03/11/2016
@version P12.1.23

@obs Projeto ELO

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function MT103FIM()

	Local _aPA6Dados
	Local _nOpc
	Local lPrjCni    := FindFunction("PRJCNI") .Or. GetRpoRelease("R6")
	//Gustavo Veloso - tolerância de recebimento
	Local cHtml := WFLoadFile( "\WORKFLOW\NotifTolReceb.HTML" )
	Local cMail := ""
	Local cAssunto := "Liberação de Nota fiscal"
	Local cMensagemErro := "Aprovador não localizado."
	Local cVALPC := 0
	Local cNomeFor := ""
	Local cDiverge := ""
	//Inicio Pierre SDM 14.003
	Local nConfirma 	:= PARAMIXB[2]
	Local aArea 		:= GetArea()
	Local cModPagA2 	:= ""
	Local nParamTED		:= SuperGetMV("MV_VLRMTED",.F.,250)
	Local cE2FILIAL		:= SE2->E2_FILIAL
	Local cE2PREFIXO	:= SE2->E2_PREFIXO
	Local cE2NUM		:= SE2->E2_NUM
	Local cE2PARCELA	:= SE2->E2_PARCELA
	Local cE2TIPO		:= SE2->E2_TIPO
	Local cE2FORNECE	:= SE2->E2_FORNECE
	Local cE2LOJA		:= SE2->E2_LOJA
	Local _aAreaSE2     := SE2->(GetArea()) // ---- LEANDRO RIBEIRO ---- 03/11/2016

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If nConfirma == 1

		DbSelectArea("SE2")					// ---- LEANDRO RIBEIRO ---- 03/11/2016
		DbSetOrder(1)  						// ---- LEANDRO RIBEIRO ---- 03/11/2016
		DbSeek(cE2FILIAL+cE2PREFIXO+cE2NUM) // ---- LEANDRO RIBEIRO ---- 03/11/2016

		While (SE2->(! EOF())).AND. cE2FILIAL == SE2->E2_FILIAL .AND. cE2PREFIXO	== SE2->E2_PREFIXO .AND. cE2NUM == SE2->E2_NUM
			cModPagA2	:=	Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"A2_XMODPAG")
			If !(ALLTRIM(SE2->E2_TIPO) $ 'ISS,INS,TX')// titulos de impostos não deve respeitar regra de valor
				//Regra para variação entre DOC e TED de acordo com valor cadastrado no parametro
				If cModPagA2 $ '03,41'
					If cModPagA2 == '03' .AND. SE2->E2_VALOR >= nParamTED
						cModPagA2 := '41'
					Elseif cModPagA2 == '41' .AND. SE2->E2_VALOR < nParamTED
						cModPagA2 := '03'
					EndIf
				EndIf
			EndIf

			If ! Empty(cModPagA2)
				RecLock("SE2",.F.)
				SE2->E2_XMODPAG := cModPagA2
				MsUnlock()
			EndIf
			SE2->(dbSkip())
		EndDo

		SE2->(dbSeek(cE2FILIAL+cE2PREFIXO+cE2NUM+cE2PARCELA+cE2TIPO))//TESTAR SE POSICIONAMENTO FUNCIONA CORRETAMENTE

	EndIf

	RestArea(_aAreaSE2)// ---- LEANDRO RIBEIRO ---- 03/11/2016
	RestArea(aArea)
	//FIM Pierre SDM 14.003

	If lPrjCni
		_aPA6Dados := { SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA }
		_nOpc  := PARAMIXB[1]
		_lProc := PARAMIXB[2]

	EndIf

	// Lançamento dos movimentos orçamentarios - GAP091
	IF (ParamIXB[1] == 3 .or. ParamIXB[1] == 4) .and. ParamIXB[2] == 1
		MsgRun("Atualizando Movimentos da NF "+SF1->F1_DOC,"",{|| U_SICOMA07(ParamIXB) })
	ENDIF

	//Gustavo Veloso - Envio de email para tolerância de recebimento
	If nConfirma == 1 .AND. (INCLUI .OR. ALTERA)
		DbSelectArea("SCR")
		SCR->(DbSetOrder(1))

		If SCR->(DbSeek(cFilAnt+"NF"+(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)))
			While SCR->(!EOF()) .AND. ((SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM) == (cFilAnt+"NF"+PADR(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,TAMSX3("CR_NUM")[1])))
				PswOrder(1)
				If (PswSeek(SCR->CR_USER, .T.))
					cMail := cMail + PswRet()[1][14]+";"
				EndIf
				SCR->(dbSkip())
			End

			If cMail <> ""

				c_Query := "SELECT D1_COD, C7_DESCRI, D1_QUANT, C7_QUANT, D1_VUNIT, C7_PRECO, D1_TOTAL, C7_TOTAL, D1_DOC, C7_NUMPR, C7_NUM, A2_NOME"
				c_Query += " FROM SD1010 a LEFT JOIN SC7010 b ON (D1_FILIAL = C7_FILIAL AND D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM AND b.D_E_L_E_T_ = '')"
				c_Query += " JOIN SA2010 c ON (D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND c.D_E_L_E_T_ = '')"
				c_Query += " WHERE a.D_E_L_E_T_ = '' AND D1_FILIAL = '"+cFilAnt+"' AND D1_DOC = '"+SF1->F1_DOC+"' AND D1_PEDIDO = '"+SC7->C7_NUM+"'"

				TcQuery c_Query New Alias "TMB"

				TMB->(DbGoTop())

				cNomeFor := TMB->A2_NOME

				/*****************
				*	1- Cabeçalho   *
				*****************/
				cDiverge := "<table width='100%' border='0' cellspacing='1' cellpadding='1'>
				cDiverge += 	"<tr class='cabec'>"
				cDiverge += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>PRODUTO</td>"
				cDiverge += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>DESCRICAO</td>"
				cDiverge += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>QTD PC</td>"
				cDiverge += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>VLR. UNIT. PC</td>"
				cDiverge += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>TOTAL PC</td>"
				cDiverge += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>QTD NF</td>"
				cDiverge += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>VLR. UNIT. NF</td>"
				cDiverge += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>TOTAL NF</td>"
				cDiverge +=	 	"</tr>

				/********************
				*2- Corpo da tabela *
				********************/
				While TMB->(!EOF())
					If (TMB->D1_QUANT > TMB->C7_QUANT .OR. TMB->D1_VUNIT > TMB->C7_PRECO)
						cDiverge += "<tr class='tit3'>"
						cDiverge += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+TMB->D1_COD+"</td>"
						cDiverge += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+TMB->C7_DESCRI+"</td>"
						cDiverge += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+AllTrim(Transform(TMB->C7_QUANT, '@E 9,999,999,999,999.9999'))+"</td>"
						cDiverge += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+AllTrim(Transform(TMB->C7_PRECO, '@E 9,999,999,999.99'))+"</td>"
						cDiverge += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+AllTrim(Transform(TMB->C7_TOTAL, '@E 9,999,999,999.99'))+"</td>"
						cDiverge += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+AllTrim(Transform(TMB->D1_QUANT, '@E 9,999,999,999,999.9999'))+"</td>"
						cDiverge += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+AllTrim(Transform(TMB->D1_VUNIT, '@E 9,999,999,999.99'))+"</td>"
						cDiverge += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+AllTrim(Transform(TMB->D1_TOTAL, '@E 9,999,999,999.99'))+"</td>"
						cDiverge += "</tr>"
					EndIf

					cVALPC += TMB->C7_TOTAL
					TMB->(dbSkip())
				End
				cDiverge += "</table>"

				cHtml := Replace(cHtml,"%FILIAL%",cFilAnt+" - "+SM0->M0_FILIAL)
				cHtml := Replace(cHtml,"%NUMPRO%",SC7->C7_NUMPR)
				cHtml := Replace(cHtml,"%PC%",SC7->C7_NUM)
				cHtml := Replace(cHtml,"%VALPC%",AllTrim(Transform(cVALPC, '@E 9,999,999,999.99')))
				cHtml := Replace(cHtml,"%RAZAO%",cNomeFor)
				cHtml := Replace(cHtml,"%NUMNF%",SF1->F1_DOC)
				cHtml := Replace(cHtml,"%VALNF%",AllTrim(Transform(SF1->F1_VALBRUT, '@E 9,999,999,999.99')))
				cHtml := Replace(cHtml,"%TABELA%",cDiverge)

				U_FIEnvMail(cMail,cAssunto , cHtml, "","")
			Else
				Alert(cMensagemErro)
			EndIf
		EndIf

		TMB->( DbCloseArea() )
		SCR->(DbCloseArea())
		RestArea(aArea)
	EndIf
	//Fim

Return