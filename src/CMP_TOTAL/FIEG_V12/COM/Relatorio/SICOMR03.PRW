#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "TbiConn.ch"
#Include "Font.ch"


/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMR03
Relatório de Conferência de Mútuo. Chamado no browse da SC.

@type function
@author Thiago Rasmussen
@since 01/06/2012
@version P12.1.23

@obs Projeto ELO

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMR03()

	Local aArea  	:= GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Private oPrint
	Private nRow		:= 8000
	Private nTamForm	:= 3000 //Tamanho formulario
	Private lFirst		:= .f.
	Private aRet      	:= {}
	Private cCadastro 	:= OemToAnsi("Relatório de Conferência - DME")
	Private cAliasTmp 	:= ""
	Private nCart		:= 0
	Private lOracle		:= "ORACLE"$Upper(TCGetDB())
	Private cNumSC		:= SC1->C1_NUM

	Private oFont09		:= TFont():New("Courier",9,9,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont09b	:= TFont():New("Courier",9,9,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont18b	:= TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)

	//Parametros de TFont.New()
	//1.Nome da Fonte (Windows)
	//3.Tamanho em Pixels
	//5.Bold (T/F)

	//Chama rotina de impressao
	RptStatus({|lEnd| RotImp(@lEnd)},"Aguarde...", "Imprimindo o Relatório", .T. )

	RestArea(aArea)

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} RotImp
Rotina de impressão do relatório.

@type function
@author Thiago Rasmussen
@since 01/04/2012
@version P12.1.23

@param lEnd, Lógico, Variável que indica que o relatório foi cancelado.

@obs Projeto ELO

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function RotImp(lEnd)

	//Local cTeste 	:= GetMv("MV_ESTNEG") //So criei essa linha p/ funcionar o GetAdvFVal, se nao da erro.
	Local nCont 	:= 1000
	Local cAliTrb 	:= "" //Alias de trabalho

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oPrint:= TMSPrinter():New(cCadastro)

	// Este comando configura a saida do TMSPRINTER e eh importante te-lo pois o Servidor ASP nao tem impressora instalada
	oPrint:Setup()
	oPrint:SetPortrait()	//SetLandscape()
	oPrint:StartPage()	// Inicia uma nova página

	SetRegua(nCont)

	//oPrint:SayBitmap(330 ,1900, "\System\LOGO.BMP",0180 ,130)	 //Tem que estar abaixo do RootPath Logotipo

	If nRow >= nTamForm
		If lFirst //Para fazer o controle da primeira impressao.
			oPrint:EndPage()
			oPrint:StartPage()
		EndIf
		ImpCabe()
		lFirst := .t.
	EndIf

	cAliTrb := GetNextAlias()
	//Seleciona os registros a serem impressos conforme SC posicionada.
	BeginSQL Alias cAliTrb

		SELECT ZW_FILIAL,ZW_ITEM,ZW_CODEMP,ZW_PERC,ZW_NUMSC,ZW_ITEMSC,C1_PRODUTO,C1_DESCRI,(C1_QUANT*C1_VUNIT) AS TOTAL,C1_CC,C1_ITEMCTA,C1_CONTA,C1_CLVL
		FROM %table:SZW% SZW
		LEFT OUTER JOIN %table:SC1% SC1 ON
		C1_FILIAL = %xFilial:SC1%
		AND SC1.%NotDel%
		AND C1_NUM = ZW_NUMSC
		AND C1_ITEM = ZW_ITEMSC
		WHERE ZW_FILIAL = %xFilial:SZW%
		AND ZW_NUMSC = %Exp:cNumSC%
		AND SZW.%NotDel%
		ORDER BY ZW_FILIAL,ZW_NUMSC,ZW_ITEMSC,ZW_CODEMP

	EndSQL
	//MemoWrite("\SYSTEM\COMR03B.SQL",GetLastQuery()[2])

	dbSelectArea((cAliTrb))

	IF Select((cAliTrb)) > 0

		While (cAliTrb)->(!EOF())

			cItemSC := (cAliTrb)->ZW_ITEMSC

			//Imprime cabecalho
			oPrint:Say(nRow,0055,"Solicitação de Compra/Item:",oFont09b)	//Texto
			oPrint:Say(nRow,0620,Alltrim((cAliTrb)->ZW_NUMSC)+"/"+Alltrim((cAliTrb)->ZW_ITEMSC),oFont09)	//Variavel

			oPrint:Say(nRow,1100,"Produto:",oFont09b)	//Texto
			oPrint:Say(nRow,1300,Alltrim((cAliTrb)->C1_PRODUTO)+"-"+Alltrim((cAliTrb)->C1_DESCRI),oFont09)	//Variavel


			nRow:=nRow+50
			oPrint:Say(nRow,0055,"U.O.: ",oFont09b)	//Texto
			cCC := Alltrim((cAliTrb)->C1_CC)
			cCC += Iif(!Empty(cCC),"-"+GetAdvFVal("CTT","CTT_DESC01",xFilial("CTT")+cCC,1,0),"")
			cCC := SubStr(cCC,1,40)
			oPrint:Say(nRow,0210,cCC,oFont09)	//Variavel

			oPrint:Say(nRow,1100,"C.R.: ",oFont09b)	//Texto
			cCR := Alltrim((cAliTrb)->C1_ITEMCTA)
			cCR += Iif(!Empty(cCR),"-"+GetAdvFVal("CTD","CTD_DESC01",xFilial("CTD")+cCR,1,0),"")
			cCR := SubStr(cCR,1,40)
			oPrint:Say(nRow,1300,cCR,oFont09)	//Variavel

			nRow:=nRow+50
			oPrint:Say(nRow,0055,"CONTA: ",oFont09b)	//Texto
			cConta := Alltrim((cAliTrb)->C1_CONTA)
			cConta += Iif(!Empty(cConta),"-"+GetAdvFVal("CT1","CT1_DESC01",xFilial("CT1")+cConta,1,0),"")
			cConta := SubStr(cConta,1,40)
			oPrint:Say(nRow,0210,cConta,oFont09)	//Variavel

			oPrint:Say(nRow,1100,"CL.VALOR: ",oFont09b)	//Texto
			cClVl := Alltrim((cAliTrb)->C1_CLVL)
			cClVl += Iif(!Empty(cClVl),"-"+GetAdvFVal("CTH","CTH_DESC01",xFilial("CTH")+cClVl,1,0),"")
			cClVl := SubStr(cClVl,1,40)
			oPrint:Say(nRow,1300,cClVl,oFont09)	//Variavel

			nRow:=nRow+50
			oPrint:Line(nRow,0055,nRow,2400)

			//Impressao dos rateio do item
			nRow:=nRow+50
			oPrint:Say(nRow,0055,"Rateio:",oFont09b)

			nRow:=nRow+50
			oPrint:Say(nRow,0055,"Empresa",oFont09b)
			oPrint:Say(nRow,0280,"Nome",oFont09b)
			oPrint:Say(nRow,2000,"%Rateio",oFont09b)

			If nRow >= nTamForm
				oPrint:EndPage()
				oPrint:StartPage()
				ImpCabe()
			EndIf

			nRow:=nRow+50

			//Imprimo todos os rateio de um item da SC
			While (cAliTrb)->(!EOF()) .AND. (cAliTrb)->ZW_ITEMSC == cItemSC

				If nRow >= nTamForm
					oPrint:EndPage()
					oPrint:StartPage()
					ImpCabe()
				EndIf

				_NomFil := "" 		//Usada para carregar o nome de filial que recebeu o rateio

				oPrint:Say(nRow,0055,(cAliTrb)->ZW_CODEMP,oFont09) //Codigo da filial

				_NomFil := GetAdvFVal("SM0","M0_NOMECOM",cEmpAnt+(cAliTrb)->ZW_CODEMP,1,0)
				_NomFil := SubStr(Alltrim(_NomFil),1,60)
				oPrint:Say(nRow,0280,_NomFil,oFont09) //Nome da Filial

				oPrint:Say(nRow,2000,Transform((cAliTrb)->ZW_PERC, "@E 999.99"),oFont09)	 //Percentual de rateio

				nRow:=nRow+50

				dbSelectArea((cAliTrb))
				(cAliTrb)->(dbSkip())
			EndDo

			//nRow:=nRow+125
			//oPrint:Say(nRow,1290,"Total Geral>>",oFont09b)
			//oPrint:Say(nRow,1670,Transform(nTotVlRat+nVlrPgto,"@E 99,999,999.99"),oFont09) //Somatorio do valor total dos rateio mais o valor referente ao titulo principal

			nRow:=nRow+100
			oPrint:Line(nRow,0055,nRow,2400)
			nRow:=nRow+25
			oPrint:Line(nRow,0055,nRow,2400)
			nRow:=nRow+50

			dbSelectArea((cAliTrb))
			//dbSkip()
		EndDo

		DbSelectArea((cAliTrb))
		(cAliTrb)->(DbCloseArea())
	Else
		oPrint:Say(nRow,0055,"Não existe registro para o item selecionado",oFont09b)	//Texto
	ENDIF

	oPrint:Preview()
	oPrint:End()

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} ImpCabe
Imprime cabeçalho e trata quebra de página.

@type function
@author Thiago Rasmussen
@since 01/04/2012
@version P12.1.23

@obs Projeto ELO

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ImpCabe()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------


	//oPrint:SayBitmap(330 ,1900, "\System\LOGO.BMP",0180 ,130)	 //Tem que estar abaixo do RootPath Logotipo
	nRow := 100

	//Informacao da empresa
	oPrint:Box(nRow,0050,0320,2400 )
	nRow:=nRow+80
	oPrint:Say(nRow,0720,cCadastro,oFont18b)

	nRow:=nRow+180

	If lFirst //Para fazer o controle da primeira impressao.
		nRow+=150
	EndIf

Return()