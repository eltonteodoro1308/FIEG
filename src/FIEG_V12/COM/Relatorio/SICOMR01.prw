#Include "Protheus.ch"
#Include "Topconn.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMR01
Função para impressão das Faturas SE1 e seus títulos amarrados.

@type function
@author Adriano Luis Brandao
@since 26/07/2011
@version P12.1.23

@obs Projeto ELO

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SICOMR01()

	Private cPerg := "XSICOMR01"
	Private cCadastro	:= "Impressao de Faturas"
	Private aSays		:= {}
	Private aButtons	:= {}
	Private nOpca 		:= 0
	Private oPrint

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	// Funcao para criacao das perguntas.
	fCriaSx1()

	// Forca o usuario a preencher as perguntas.
	If ! Pergunte(cPerg,.t.)
		Return
	EndIf

	AADD(aSays,"Este programa ira realizar a impressão das Faturas," )
	AADD(aSays,"de acordo com os parametros selecionados." )


	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. )}})
	AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch()}})
	AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

	FormBatch( cCadastro, aSays, aButtons )

	If nOpca == 1
		If ApMsgYesNo("Confirma impressao das Faturas ??","Confirmar")
			Processa({|| fimprime()})
		EndIf
	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fImprime
Função para impressao das Faturas.

@type function
@author Adriano Luis Brandao
@since 26/07/2011
@version P12.1.23

@obs Projeto ELO

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fImprime()

	Local _cQuery	:= ""
	Local _nVias	:= iif(MV_PAR09==0,1,MV_PAR09)
	Local _nZ		:= 0

	Private _aItem	:= {}
	Private oCour08N 	:= TFont():New("Courier New",08,08,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oCour09N 	:= TFont():New("Courier New",09,09,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oCour10N 	:= TFont():New("Courier New",10,10,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oCour12N 	:= TFont():New("Courier New",12,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oCour14N 	:= TFont():New("Courier New",14,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont8		:= TFont():New("Arial",08,08,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oArial08N	:= TFont():New("Arial",08,08,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oArial10N	:= TFont():New("Arial",10,10,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oArial12N	:= TFont():New("Arial",10,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oArial14N	:= TFont():New("Arial",13,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oArial16N	:= TFont():New("Arial",14,16,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oArial20N	:= TFont():New("Arial",18,20,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oArial21N	:= TFont():New("Arial",19,21,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oTime08N	:= TFont():New("Time New Roman",08,08,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oTime09N	:= TFont():New("Time New Roman",09,09,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oTime10N	:= TFont():New("Time New Roman",10,10,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oTime12N	:= TFont():New("Time New Roman",12,12,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oTime14N	:= TFont():New("Time New Roman",14,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oTime16N	:= TFont():New("Time New Roman",16,16,.T.,.T.,5,.T.,5,.T.,.F.)
	Private nRowIni := 010
	Private nColIni := 050
	Private nColFim := 2300
	Private nRowFim := 3250
	Private nRowAtu := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	nRowAtu := nRowIni


	_cQuery := "SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_CLIENTE, E1_LOJA, E1_VALOR, E1_ORIGEM, E1_VENCTO "
	_cQuery += "FROM " + RetSqlName("SE1") + " E1 "
	_cQuery += "WHERE E1_FILIAL = '" + xFilial("SE1") + "' "
	_cQuery += "      AND E1_PREFIXO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	_cQuery += "      AND E1_NUM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	_cQuery += "      AND E1_CLIENTE || E1_LOJA BETWEEN '" + MV_PAR05 + MV_PAR06 + "' AND '" + MV_PAR07 + MV_PAR08 + "' "
	_cQuery += "      AND E1_ORIGEM = 'FINA280' "
	_cQuery += "      AND E1.D_E_L_E_T_ = ' ' "

	_cQuery := ChangeQuery(_cQuery)

	_calias := GetNextAlias()

	TcQuery _cQuery New Alias (_cAlias) // "QRYR01"

	TcSetField(_cAlias,"E1_EMISSAO","D",08,00)
	TcSetField(_cAlias,"E1_VALOR","N",TamSx3("E1_VALOR")[1],TamSx3("E1_VALOR")[2])
	TcSetField(_cAlias,"E1_VENCTO","D",08,00)

	(_cAlias)->(DbGoTop())

	_lPrimeiro := .t.

	SA1->(DbSetOrder(1))

	_cCli := (_cAlias)->E1_CLIENTE+(_cAlias)->E1_LOJA

	Do While ! (_cAlias)->(Eof())
		If _lPrimeiro
			oPrint:= TMSPrinter():New( "Relatorio de faturas" )
			oPrint:SetPortrait()
			oPrint:StartPage()
			_lPrimeiro := .f.
		EndIf

		// Funcao para carregar os titulos de origem da Fatura.
		_aItem := fCarTit()

		If _cCli <> ((_cAlias)->E1_CLIENTE+(_cAlias)->E1_LOJA)
			nRowAtu := nRowIni
			oPrint:EndPage()
			oPrint:StartPage()
		EndIf

		SA1->(DbSeek(xFilial("SA1")+(_cAlias)->E1_CLIENTE+(_cAlias)->E1_LOJA))
		For _nZ := 1 To _nVias
			// Checagem do final do relatorio se estoura o tamanho da pagina.
			// numero linhas de um documento + numero de linhas ja utilizado + (numero de itens * salto item)
			nLinPrev := 1265+nRowAtu+(Len(_aItem)*40)
			// se estoura o previsto o limite salta pagina.
			If nLinPrev > nRowFim
				nRowAtu := nRowIni
				oPrint:EndPage()
				oPrint:StartPage()
			EndIf
			fForm(_aItem)

			_cCli := ((_cAlias)->E1_CLIENTE+(_cAlias)->E1_LOJA)
		Next _nZ

		(_cAlias)->(DbSkip())
	EndDo

	If ! _lPrimeiro
		oPrint:EndPage()
		oPrint:Preview()     // Visualiza antes de imprimir
	EndIf

	(_cAlias)->(DbCloseArea())



Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fCriaSx1
Funcao para criação das perguntas.

@type function
@author Adriano Luis Brandao
@since 26/07/2011
@version P12.1.23

@obs Projeto ELO

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@deprecated Função PutSx1 não tem mais efeito.
/*/
/*/================================================================================================================================/*/

Static Function fCriaSx1()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+----------------------------+
	//|MV_PAR01  Prefixo de        |
	//|MV_PAR02  Prefixo ate       |
	//|MV_PAR03  Fatura de         |
	//|MV_PAR04  Fatura ate        |
	//|MV_PAR05  Cliente de        |
	//|MV_PAR06  Loja de           |
	//|MV_PAR07  Cliente ate       |
	//|MV_PAR08  Loja ate          |
	//|MV_PAR09  Quantidade de vias|
	//+----------------------------+

	//	PutSx1( cPerg, "01","Prefixo De    ","","","mv_ch1","C",TamSX3("E1_PREFIXO")[1]	,0,0,"G","",""		,"","","mv_par01","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1( cPerg, "02","Prefixo Ate   ","","","mv_ch2","C",TamSX3("E1_PREFIXO")[1]	,0,0,"G","",""		,"","","mv_par02","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1( cPerg, "03","Fatura De     ","","","mv_ch3","C",TamSX3("E1_NUM")[1]		,0,0,"G","",""		,"","","mv_par03","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1( cPerg, "04","Fatura Ate    ","","","mv_ch4","C",TamSX3("E1_NUM")[1]		,0,0,"G","",""		,"","","mv_par04","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1( cPerg, "05","Cliente de    ","","","mv_ch5","C",TamSX3("E1_CLIENTE")[1]	,0,0,"G","","SA1"	,"","","mv_par05","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1( cPerg, "06","Loja de       ","","","mv_ch6","C",TamSX3("E1_LOJA")[1]		,0,0,"G","",""		,"","","mv_par06","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1( cPerg, "07","Cliente ate   ","","","mv_ch7","C",TamSX3("E1_CLIENTE")[1]	,0,0,"G","","SA1"	,"","","mv_par07","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1( cPerg, "08","Loja ate      ","","","mv_ch8","C",TamSX3("E1_LOJA")[1]		,0,0,"G","",""		,"","","mv_par08","","","","","","","","","","","","","","","","",{},{},{})
	//	PutSx1( cPerg, "09","Qtde. de Vias ","","","mv_ch9","N",02                  		,0,0,"G","",""		,"","","mv_par09","","","","","","","","","","","","","","","","",{},{},{})

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} fCarTit
Função para carregar os títulos que compõem a Fatura principal.

@type function
@author Adriano Luis Brandao
@since 26/07/2011
@version P12.1.23

@obs Projeto ELO

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com os títulos que compõem a Fatura principal.

/*/
/*/================================================================================================================================/*/

Static Function fCarTit()

	Local _aItens := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SE1->(DbSetOrder(10))
	// E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_FATPREF, E1_FATURA

	SE1->(DbSeek(xFilial("SE1")+(_cAlias)->E1_CLIENTE+(_cAlias)->E1_LOJA+(_cAlias)->E1_PREFIXO+(_cAlias)->E1_NUM))

	Do While ! SE1->(Eof())	 .And. (SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_FATPREF+SE1->E1_FATURA) ==;
	(xFilial("SE1")+(_cAlias)->E1_CLIENTE+(_cAlias)->E1_LOJA+(_cAlias)->E1_PREFIXO+(_cAlias)->E1_NUM)

		aAdd(_aItens,{SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_EMISSAO,SE1->E1_VENCTO,SE1->E1_VENCREA,SE1->E1_VALOR})

		SE1->(DbSkip())
	EndDo

Return(_aItens)

/*/================================================================================================================================/*/
/*/{Protheus.doc} fForm
Função para montagem do formulário.

@type function
@author Adriano Luis Brandão
@since 27/07/2011
@version P12.1.23

@param _aItens, Array, Array com os títulos que compõem a Fatura principal.

@obs Projeto ELO

@history 26/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function fForm(_aItens)

	Local _cExtenso := ""
	Local _cExtenso2:= ""
	//Local _cMens	:= ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oPrint:Box(nRowAtu,nColIni,nRowAtu+200,nColFim)
	oPrint:Box(nRowAtu+200,nColIni,nRowAtu+1075,nColFim)
	oPrint:Say(nRowAtu+0005,nColIni+0010,SM0->M0_NOMECOM,oArial10N)
	oPrint:Say(nRowAtu+0050,nColIni+0010,SM0->M0_ENDCOB,oArial10N)
	oPrint:Say(nRowAtu+0100,nColIni+0010,SM0->M0_CIDCOB+" - "+SM0->M0_ESTCOB,oArial10N)
	oPrint:Say(nRowAtu+0100,nColIni+0010,SM0->M0_CIDCOB,oArial10N)
	oPrint:Say(nRowAtu+0150,nColIni+0010,"CEP:"+SM0->M0_CEPCOB,oArial10N)
	oPrint:Line(nRowAtu,nColIni+1300,nRowAtu+200,nColIni+1300)
	oPrint:Say(nRowAtu+0050,nColIni+1350,"C.G.C(MF) nr."+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),oArial10N)
	oPrint:Say(nRowAtu+0100,nColIni+1350,"C.C.M. Nr." + SM0->M0_INSC,oArial10N)
	oPrint:Say(nRowAtu+0150,nColIni+1350,"DATA DE EMISSAO:" + DTOC((_cAlias)->E1_EMISSAO),oArial10N)
	oPrint:Say(nRowAtu+0005,nColIni+1900,"FATURA",oTime12N)
	nRowAtu+=205
	oPrint:Box(nRowAtu,nColIni+0020,nRowAtu+250,nColFim-0020)
	oPrint:Box(nRowAtu,nColIni+0020,nRowAtu+150,nColIni+1600)
	oPrint:Box(nRowAtu+150,nColIni+0020,nRowAtu+250,nColIni+1600)
	oPrint:Line(nRowAtu+0050,nColIni+0020,nRowAtu+0050,nColIni+1600)
	oPrint:Say(nRowAtu+0005,nColIni+0030,"NF.FATURA Nr.",oArial08N)
	oPrint:Say(nRowAtu+0005,nColIni+0300,"NF-FATF/Duplicata-Valor",oArial08N)
	oPrint:Say(nRowAtu+0005,nColIni+0800,"Duplicata - nr.Ordem",oArial08N)
	oPrint:Say(nRowAtu+0005,nColIni+1200,"Vencimento",oArial08N)
	oPrint:Line(nRowAtu,nColIni+0270,nRowAtu+150,nColIni+0270)
	oPrint:Line(nRowAtu,nColIni+0780,nRowAtu+150,nColIni+0780)
	oPrint:Line(nRowAtu,nColIni+1180,nRowAtu+150,nColIni+1180)
	oPrint:Say(nRowAtu+0075,nColIni+0030,(_cAlias)->E1_NUM,oCour10N)
	oPrint:Say(nRowAtu+0075,nColIni+0275,Transform((_cAlias)->E1_VALOR,PesqPict("SE1","E1_VALOR")),oCour10N)
	oPrint:Say(nRowAtu+0075,nColIni+0785,(_cAlias)->(Alltrim(E1_NUM)+"-"+Alltrim(E1_PARCELA)+"-"+E1_TIPO),oCour10N)
	oPrint:Say(nRowAtu+0075,nColIni+1185,DTOC((_cAlias)->E1_VENCTO),oCour10N)
	oPrint:Say(nRowAtu+0155,nColIni+0030,"Desconto de         % sobre                ate",oCour08N)
	oPrint:Say(nRowAtu+0205,nColIni+0030,"Condições Especiais",oCour08N)
	oPrint:Say(nRowAtu+0005,nColIni+1610,"PARA USO DA",oCour08N)
	oPrint:Say(nRowAtu+0045,nColIni+1610,"INSTITUIÇÃO FINANCEIRA",oCour08N)
	nRowAtu+=250
	oPrint:Box(nRowAtu,nColIni+0020,nRowAtu+0240,nColFim-0020)
	oPrint:Say(nRowAtu+0005,nColIni+0030,"Nome do Sacado:",oArial08N)
	oPrint:Say(nRowAtu+0005,nColIni+0330,SA1->A1_NOME,oCour10N)
	oPrint:Say(nRowAtu+0045,nColIni+0030,"Endereço:",oArial08N)
	oPrint:Say(nRowAtu+0045,nColIni+0330,SA1->A1_END+"  "+SA1->A1_BAIRRO,oCour10N)
	oPrint:Say(nRowAtu+0085,nColIni+0030,"CEP/Município:",oArial08N)
	oPrint:Say(nRowAtu+0085,nColIni+0330,Transform(SA1->A1_CEP,"@R 99999-999") + "  " + SA1->A1_MUN,oCour10N)
	oPrint:Say(nRowAtu+0125,nColIni+0030,"Praça de pagamento:",oArial08N)
	oPrint:Say(nRowAtu+0125,nColIni+0330,SA1->A1_ENDCOB+"  "+SA1->A1_BAIRROC,oCour10N)
	oPrint:Say(nRowAtu+0165,nColIni+0030,"CEP/Município:",oArial08N)
	oPrint:Say(nRowAtu+0165,nColIni+0330,Transform(SA1->A1_CEPC,"@R 99999-999") + "  " + SA1->A1_MUNC,oCour10N)
	oPrint:Say(nRowAtu+0205,nColIni+0030,"I.C.G.C.(MF) No.:",oArial08N)
	oPrint:Say(nRowAtu+0205,nColIni+0330,iif(Len(Alltrim(SA1->A1_CGC))>11,Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),Transform(SA1->A1_CGC,"@e 999.999.999-99")),oCour10N)
	oPrint:Say(nRowAtu+0085,nColIni+1600,"Estado:",oArial08N)
	oPrint:Say(nRowAtu+0085,nColIni+1700,SA1->A1_EST,oCour10N)
	oPrint:Say(nRowAtu+0165,nColIni+1600,"Estado:",oArial08N)
	oPrint:Say(nRowAtu+0165,nColIni+1700,SA1->A1_ESTC,oCour10N)
	oPrint:Say(nRowAtu+0205,nColIni+1600,"Insc.Est.Nr.",oArial08N)
	oPrint:Say(nRowAtu+0205,nColIni+1750,SA1->A1_INSCR,oCour10N)

	nRowAtu+=0240
	_cExtenso := Extenso((_cAlias)->E1_VALOR,.F.,,,,.T.,,)
	_cExtenso2:= ""

	If Len(_cExtenso) > 108
		_cExtenso2 := Substr(_cExtenso,109,Len(_cExtenso)-108)
		_cExtenso2 += Replicate("*",109-Len(_cExtenso2))
		_cExtenso  := Left(_cExtenso,108)
	Else
		_cExtenso  := _cExtenso + Replicate("*",110-Len(_cExtenso))
	EndIf
	oPrint:Box(nRowAtu,nColIni+0020,nRowAtu+0100,nColFim-0020)
	oPrint:Say(nRowAtu+0005,nColIni+0030,"Valor por",oArial08N)
	oPrint:Say(nRowAtu+0045,nColIni+0030,"extenso",oArial08N)
	oPrint:Say(nRowAtu+0005,nColIni+0310,_cExtenso,oCour08N)
	oPrint:Say(nRowAtu+0045,nColIni+0310,_cExtenso2,oCour08N)
	oPrint:Line(nRowAtu,nColIni+0300,nRowAtu+0100,nColIni+0300)
	nRowAtu+=0100
	oPrint:Say(nRowAtu+0005,nColIni+0030,"Reconhecemos a exatidão desta Duplicata de Prestação de Serviços, na importância acima que pagaremos + ",oCour08N)
	oPrint:Say(nRowAtu+0045,nColIni+0030,Alltrim(SM0->M0_NOMECOM)+" ou + sua ordem, na praça e vencimento indicados.",oCour08N)
	oPrint:Say(nRowAtu+0125,nColIni+0050,"Em _____/_____/_____.",oCour08N)
	oPrint:Say(nRowAtu+0165,nColIni+0050,"  (Data do aceite)",oCour08N)
	oPrint:Box(nRowAtu+0080,nColIni+1600,nRowAtu+0260,nColFim-0020)
	oPrint:Say(nRowAtu+0090,nColIni+1610,"Confederação Nacional da Ind+stria.",oCour08N)
	oPrint:Line(nRowAtu+0220,nColIni+1610,nRowAtu+0220,nColFim-0040)
	oPrint:Say(nRowAtu+0230,nColIni+1610,"     Assinatura do Emitente",oCour08N)
	nRowAtu+=0280


	nRowAtu+=40

	oPrint:Say(nRowAtu,nColIni+0020,"PRF N+mero     Parcela      Emissão     Venc.Original Vencimento Real      Valor Título",oCour10N)
	nRowAtu+=40
	oPrint:Line(nRowAtu,nColIni,nRowAtu,nColFim)
	nRowAtu+=10

	For _nY := 1 To len(_aItens)
		If nRowAtu > nRowFim
			nRowAtu := nRowIni
			oPrint:EndPage()
			oPrint:StartPage()
		EndIf

		oPrint:Say(nRowAtu,nColIni+0020,_aItens[_nY,1],oCour10N)			// Prefixo
		oPrint:Say(nRowAtu,nColIni+0100,_aItens[_nY,2],oCour10N)   		// Numero
		oPrint:Say(nRowAtu,nColIni+0400,_aItens[_nY,3],oCour10N)   		// Parcela
		oPrint:Say(nRowAtu,nColIni+0600,Dtoc(_aItens[_nY,4]),oCour10N)		// Emissao
		oPrint:Say(nRowAtu,nColIni+0900,Dtoc(_aItens[_nY,5]),oCour10N)		// Vencimento Original
		oPrint:Say(nRowAtu,nColIni+1200,Dtoc(_aItens[_nY,6]),oCour10N)		// Vencimento Real
		oPrint:Say(nRowAtu,nColIni+1500,Transform(_aItens[_nY,7],Pesqpict("SE1","E1_VALOR")),oCour10N)
		nRowAtu+=40
	Next _nY
	nRowAtu+=0040
	oPrint:Line(nRowAtu,nColIni,nRowAtu,nColFim)
	nRowAtu+=0050

Return