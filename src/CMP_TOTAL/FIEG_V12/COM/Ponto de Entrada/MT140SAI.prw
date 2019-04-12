#Include "Protheus.ch"
#Include "topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT140SAI
Ponto de entrada disparado antes do retorno da rotina ao browse. Dessa forma, a tabela SF1 pode ser reposicionada antes do retorno ao browse.

@type function
@author Thiago Rasmussen
@since 15/02/2019
@version P12.1.23

@obs Desenvolvimento FIEG

@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function MT140SAI()

	Local aArea 	:= GetArea()
	Local nConfirma := PARAMIXB[7]								//Gustavo Veloso (FIRJAN) - tolerância de recebimento
	Local cHtml 	:= WFLoadFile( "\WORKFLOW\NotifTolReceb.HTML" )
	Local cMail 	:= ""
	Local cAssunto  := "Liberação de Nota fiscal"	
	Local cMensagemErro := "Aprovador não localizado."
	Local cVALPC 	:= 0
	Local cVALNF 	:= 0
	Local cNomeFor  := ""
	Local cDiverge  := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If nConfirma == 1 .AND. (INCLUI .OR. ALTERA)

		DbSelectArea("SCR")
		SCR->(DbSetOrder(1))

		If SCR->(DbSeek(cFilAnt+"NF"+(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)))
			While !SCR->(Eof()) .AND. ((SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM) == (cFilAnt+"NF"+PADR(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,TAMSX3("CR_NUM")[1])))
				PswOrder(1) 
				If (PswSeek(SCR->CR_USER, .T.))
					cMail := cMail + PswRet()[1][14]+";"
				EndIf
				SCR->(dbSkip())
			End

			If cMail <> ""
				/*Gustavo - Comentado em 03/06/16	
				c_Query := "SELECT SUM(C7_TOTAL) TOTPC, A2_NOME RAZAO, SUM(D1_TOTAL) TOTNF"
				c_Query += " FROM SC7010 a"
				c_Query += " JOIN SD1010 c ON (C7_FILENT = D1_FILIAL AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND c.D_E_L_E_T_ = '')"
				c_Query += " JOIN SA2010 b ON (D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND b.D_E_L_E_T_ = '')"
				c_Query += " WHERE a.D_E_L_E_T_ = '' AND" //C7_ENCER <> 'E' AND" //C7_QUANT <> C7_QUJE
				c_Query += " C7_FILENT = '"+cFilAnt+"' AND C7_NUM = '"+SC7->C7_NUM+"'"
				c_Query += " GROUP BY C7_FILIAL, C7_NUM, A2_NOME"
				*/
				//Mudança da query para trazer os itens envolvidos no processo
				c_Query := "SELECT D1_COD, C7_DESCRI, D1_QUANT, C7_QUANT, D1_VUNIT, C7_PRECO, D1_TOTAL, C7_TOTAL, D1_DOC, C7_NUMPR, C7_NUM, A2_NOME"
				c_Query += " FROM SD1010 a LEFT JOIN SC7010 b ON (D1_FILIAL = C7_FILENT AND D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM AND b.D_E_L_E_T_ = '')"
				c_Query += " JOIN SA2010 c ON (D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND c.D_E_L_E_T_ = '')"
				c_Query += " WHERE a.D_E_L_E_T_ = '' AND D1_FILIAL = '"+cFilAnt+"' AND D1_DOC = '"+SF1->F1_DOC+"' AND D1_PEDIDO = '"+SC7->C7_NUM+"'" 

				TcQuery c_Query New Alias "TMB"

				TMB->(DbGoTop())

				cNomeFor := TMB->A2_NOME

				//--< 1- Cabeçalho >--------------------------------------------------------
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

				//--< 2- Corpo da tabela >--------------------------------------------------
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
					cVALNF += TMB->D1_TOTAL
					TMB->(dbSkip())
				End

				cDiverge += "</table>"

				cHtml := Replace(cHtml,"%FILIAL%",cFilAnt+" - "+SM0->M0_FILIAL)
				cHtml := Replace(cHtml,"%NUMPRO%",SC7->C7_NUMPR)
				cHtml := Replace(cHtml,"%PC%",SC7->C7_NUM)
				cHtml := Replace(cHtml,"%VALPC%",AllTrim(Transform(cVALPC, '@E 9,999,999,999.99')))
				cHtml := Replace(cHtml,"%RAZAO%",cNomeFor)
				cHtml := Replace(cHtml,"%NUMNF%",SF1->F1_DOC)
				cHtml := Replace(cHtml,"%VALNF%",AllTrim(Transform(cVALNF, '@E 9,999,999,999.99')))
				cHtml := Replace(cHtml,"%TABELA%",cDiverge)

				//U_FIEnvMail("gveloso@firjan.org.br",cAssunto, cHtml, "","")
				U_FIEnvMail(cMail,cAssunto , cHtml, "","")
			Else
				Alert(cMensagemErro)
			EndIf
		EndIf

		SCR->(DbCloseArea())

		RestArea(aArea)

	EndIf

Return
