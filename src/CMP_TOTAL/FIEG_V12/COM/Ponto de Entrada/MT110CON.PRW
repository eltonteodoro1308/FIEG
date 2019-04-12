#Include "Protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT110CON
PE para validar exclusao da SC. Ponto de entrada que roda depois da gravação da SC,
feita inicialmente para envio de emails para solicitantes, distribuidores e compradores.

@type function
@author Sergio Bruno(DOIT)
@since 24/07/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function MT110CON()

	Local _aArea := GetArea()
	Local _lRet     := .T.
	Local cVlUnit
	Local cQuant
	Local cQuery   := ""
	Local cValor
	Local cSolicit := SC1->C1_NUM
	Local aUser := {}
	Local cComprad := ""
	Local cOldComp := ""
	Local nX := 0
	Local nQtdReg:= 0
	Private cTabela
	Private cValorT := 0
	Private cDataExcl := DTOC(DDATABASE)
	Private cHrExcl	:= TIME()
	Private cMailSol
	Private cNomeSol
	Private cMailComp
	Private cNomeComp
	Private cMailDist
	Private cNomeDist
	Private cForn

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If IsInCallStack("A110Deleta") .and. !empty(SC1->C1_XCOMPRA) .AND. empty(SC1->C1_FISCORI) //Roda somente se for gravação de deleção, tiver sido distribuído e não for centralizada

		PswOrder(2) // Ordem de nome

		// Efetuo a pesquisa, definindo se pesquiso usuário ou grupo
		If PswSeek(SC1->C1_SOLICIT,.T.)

			// Obtenho o resultado conforme vetor
			_aRetUser := PswRet(1)

			cMailSol   := upper(alltrim(_aRetUser[1,14]))
			cNomeSol   := upper(alltrim(_aRetUser[1,4]))

		EndIf

		PswOrder(2)
		If PswSeek(SC1->C1_CODDIST,.T.)

			// Obtenho o resultado conforme vetor
			_aRetUser := PswRet(1)

			cMailDist   := upper(alltrim(_aRetUser[1,14]))
			cNomeDist   := upper(alltrim(_aRetUser[1,4]))

		EndIf

		*/****************************************
		//Gera arquivo principal					   *
		*****************************************/

		cQuery := " SELECT C1_FILIAL, C1_NUM, C1_ITEM, C1_DESCRI, C1_UM, C1_PRODUTO, C1_QUANT, C1_VUNIT, C1_XCOMPRA "
		cQuery += " 	FROM SC1010 WHERE C1_FILIAL = '"+SC1->C1_FILIAL+"' "
		cQuery += "		AND C1_NUM = '"+SC1->C1_NUM+"' "
		cQuery += " 	AND D_E_L_E_T_ <> '*' "
		cQuery += " 	ORDER BY C1_XCOMPRA, C1_ITEM "

		If Select("TSC1") > 0
			TSC1->(DbCLoseArea())
		Endif

		TCQuery cQuery New Alias "TSC1"

		*/*********************************************************
		// Bloco de htmp do Comprador, Distribuidor e Solicitante	*
		***********************************************************/

		DbSelectArea("TSC1")  //Foca no arquivo temporário de solicitação
		COUNT TO nQtdReg
		cValorT := 0
		TSC1->(dbGoTop()) //Posiciona no topo

		cComprad := TSC1->C1_XCOMPRA	//Comprador do registro atual
		cOldComp := TSC1->C1_XCOMPRA   //Comprador do registro anterior
		nX := 0

		While !TSC1->(EOF())
			nX++

			If nX = 1 .OR. cOldComp != TSC1->C1_XCOMPRA   //Imprime o cabeçalho no início e a cada comprador

				cTabela := "<table width='100%' border='0' cellspacing='1' cellpadding='1'>" //Rodapé
				cTabela += 	"<tr class='cabec'>"
				cTabela += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>FILIAL</td>"
				cTabela += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>SOLICITACAO</td>"
				cTabela += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>ITEM SC</td>"
				cTabela += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>DESCRICAO</td>"
				cTabela += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>UM</td>"
				cTabela += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>GRUPO</td>"
				cTabela += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>QTD</td>"
				cTabela += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>VLR. UNIT.</td>"
				cTabela += 		"<td height='17' align='center' valign='middle' bgcolor='#001A33'>VLR. TOTAL</td>"
				cTabela += "</tr>


			Endif


			cValor 	:= AllTrim(Transform(TSC1->C1_QUANT * TSC1->C1_VUNIT, '@E 9,999,999,999.99'))
			cVlUnit	:= AllTrim(Transform(TSC1->C1_VUNIT, '@E 9,999,999,999.99'))
			cQuant	:= AllTrim(Transform(TSC1->C1_QUANT, '@E 9,999,999,999.99'))

			cValorT += (TSC1->C1_QUANT * TSC1->C1_VUNIT)

			cTabela += "<tr class='tit3'>"		//Corpo
			cTabela += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+TSC1->C1_FILIAL+"</td>"
			cTabela += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+TSC1->C1_NUM+"</td>"
			cTabela += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+TSC1->C1_ITEM+"</td>"
			cTabela += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+POSICIONE("SB5",1,xFilial("SB5")+TSC1->C1_PRODUTO,"B5_CEME")+"</td>"
			cTabela += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+TSC1->C1_UM+"</td>"
			cTabela += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+POSICIONE("SB1",1,xFilial("SB1")+TSC1->C1_PRODUTO,"B1_GRUPO")+"</td>"
			cTabela += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+cQuant+"</td>"
			cTabela += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+cVlUnit+"</td>"
			cTabela += "	<td align='center' height='10' valign='middle'   bgcolor='#7A9BDE'>"+cValor+"</td>"
			cTabela += "</tr>"

			cOldcomp := TSC1->C1_XCOMPRA

			//cForn	  := POSICIONE("SA2",1,xFilial("SA2")+SC1->C1_FORNECE+SC1->C1_LOJA,"A2_NOME")
			cMailComp := upper(alltrim(POSICIONE("SY1",1,xFilial("SY1")+TSC1->C1_XCOMPRA,"Y1_EMAIL")))
			cNomeComp := upper(alltrim(POSICIONE("SY1",1,xFilial("SY1")+TSC1->C1_XCOMPRA,"Y1_NOME")))
			TSC1->(DbSkip())



			If (cComprad <> TSC1->C1_XCOMPRA) .OR. nQtdReg = nX  //Imprime Rodapé caso mude o comprador


				cTabela += "<tr class='cabec'>"   //Rodapé com totalizadores
				cTabela += "	<td align='center' height='10' valign='middle'>&nbsp;</td>"
				cTabela += "	<td align='center' height='10' valign='middle'>&nbsp;</td>"
				cTabela += "	<td align='center' height='10' valign='middle'>&nbsp;</td>"
				cTabela += "	<td align='center' height='10' valign='middle'>&nbsp;</td>"
				cTabela += "	<td align='center' height='10' valign='middle'>&nbsp;</td>"
				cTabela += "	<td align='center' height='10' valign='middle'>&nbsp;</td>"
				cTabela += "	<td align='center' height='10' valign='middle'>&nbsp;</td>"
				cTabela += "	<td align='center' height='10' valign='middle'  bgcolor='#3C4379'>Total R$ </td>"
				cTabela += "	<td align='center' height='10' valign='middle'  bgcolor='#3C4379'>"+AllTrim(Transform(cValorT, '@E 9,999,999,999.99'))+"</td>"
				cTabela += "</tr>"

				cTabela += "</table>"


				//Enviar email  - Solicitante
				MailSol()
				//Enviar email  - Comprador
				MailCom()
				//Enviar email  - Profissional da DICOM, que distribuiu; e
				MailDic()
				cTabela := ""
				//Inicializa a tabela para o próximo comprador
				cValorT := 0

			EndIf
			DbSelectArea("TSC1")
			cComprad := TSC1->C1_XCOMPRA


		End
		//********Fim da Secção do Comprador ************/

		TSC1->( DbCloseArea() )

	Endif
		
	RestArea(_aArea)

Return _lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} MailSol
Subrotina de envio de email ao solicitante.

@type function
@author Sergio Bruno
@since 28/07/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function MailSol()

	local cHtml := WFLoadFile( "\WORKFLOW\NotifExcSCSol.HTML" )
	Local cAssunto := "Divisão de Compras – Exclusão de Solicitação de Compra"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If Empty(cMailSol)

		Alert("Solicitante sem email cadastrado no sistema.")

	Else

		cHtml := Replace(cHtml,"%SOLICITANTE%",cNomeSol)
		cHtml := Replace(cHtml,"%DTEXCL%",cDataExcl)
		cHtml := Replace(cHtml,"%HREXCL%",cHrExcl)
		cHtml := Replace(cHtml,"%FORNECEDOR%",cNomeComp)
		cHtml := Replace(cHtml,"%MAILDIST%",cMailComp)
		cHtml := Replace(cHtml,"%VALOR%",AllTrim(Transform(cValorT, '@E 9,999,999,999.99')))
		cHtml := Replace(cHtml,"%TABELA%",cTabela)

		U_FIEnvMail(cMailSol,cAssunto , cHtml, "")

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} MailCom
Subrotina de envio de email ao Comprador.

@type function
@author Sergio Bruno
@since 28/07/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function MailCom()

	local cHtml := WFLoadFile( "\WORKFLOW\NotifExcSCCom.HTML" )
	Local cAssunto := "Divisão de Compras – Exclusão de Solicitação de Compra"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If Empty( cMailComp )

		Alert("Comprador sem email cadastrado no sistema.")

	Else

		cHtml := Replace(cHtml,"%COMPRADOR%",cNomeComp)
		cHtml := Replace(cHtml,"%DTEXCL%",cDataExcl)
		cHtml := Replace(cHtml,"%HREXCL%",cHrExcl)
		cHtml := Replace(cHtml,"%VALOR%",AllTrim(Transform(cValorT, '@E 9,999,999,999.99')))
		cHtml := Replace(cHtml,"%TABELA%",cTabela)

		U_FIEnvMail(cMailComp,cAssunto , cHtml, "")

	Endif

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} MailDic
Subrotina de envio de email ao distribuidor.

@type function
@author Sergio Bruno
@since 28/07/2015
@version P12.1.23

@obs Desenvolvimento FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/
Static Function MailDic()

	local cHtml := WFLoadFile( "\WORKFLOW\NotifExcSCDICOM.HTML" )
	Local cAssunto := "Divisão de Compras – Exclusão de Solicitação de Compra"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If Empty(cMailDist)

		Alert("Distribuidor sem email cadastrado no sistema.")

	Else

		cNome := cNomeDist
		cHtml := Replace(cHtml,"%DTEXCL%",cDataExcl)
		cHtml := Replace(cHtml,"%HREXCL%",cHrExcl)
		cHtml := Replace(cHtml,"%DISTRIBUIDOR%",cNome)
		cHtml := Replace(cHtml,"%MAILDIST%",cMailDist)
		cHtml := Replace(cHtml,"%VALOR%",AllTrim(Transform(cValorT, '@E 9,999,999,999.99')))
		cHtml := Replace(cHtml,"%TABELA%",cTabela)
		cHtml := Replace(cHtml,"%COMPRADOR%",cNomeComp)

		U_FIEnvMail(cMailDist,cAssunto , cHtml, "")

	EndIf

Return