#INCLUDE "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SIFINR13  ºAutor  ³Totvs..             º Data ³  Abr/2012   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Reltorio de Conferencia de Mutuo.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1: Cateira (1=CP / 2=CR)                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Req 316 a 320 (Mutuo)                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SIFINR13(nCar)

Local aArea  	:= GetArea()
Local aPar	:= {}

Private oPrint
Private nRow			:= 8000
Private nTamForm		:= 3000 //Tamanho formulario
Private lFirst		:= .f.
Private aRet      	:= {}
Private cCadastro 	:= OemToAnsi("Relatório de Conferência - DME")
Private cAliasTmp 	:= ""
Private nCart			:= 0
Private lOracle		:= "ORACLE"$Upper(TCGetDB())

Private oFont09	:= TFont():New("Courier",9,9,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont09b	:= TFont():New("Courier",9,9,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont18b	:= TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)

//Carrega as variaveis a ser utilizado no relatorio
Private cCarteira 	:= ""							//Indica a carteira
Private cMutuo 		:= Criavar("E2_XMUTUO",.F.) 	//Numero Processo Mutuo
Private cStatus 	:= Criavar("E2_XSTATUS",.F.)	//Status do Mutuo onde: 0=Nao Utiliza;1=Em Aberto;2=Finalizado
Private cCliFor 	:= Criavar("E2_FORNECE",.F.)	//Codigo do cliente ou fornecedor
Private cLoja		:= Criavar("E2_LOJA",.F.)		//Loja do cliente ou fornecedor
Private cNome       := Criavar("A2_NOME",.F.)		//Nome do cliente ou fornecedor
Private cPrefixo 	:= Criavar("E2_PREFIXO",.F.)	//Prefixo do Titulo
Private cNumero 	:= Criavar("E2_NUM",.F.)		//Numer do titulo
Private cParcela 	:= Criavar("E2_PARCELA",.F.)	//Parcela do Titulo
Private cTipo 		:= Criavar("E2_TIPO",.F.)		//Tipo do Titulo
Private dEmissao 	:= Criavar("E2_EMISSAO",.F.)	//Data de emissao do titulo
Private dVenc		:= Criavar("E2_VENCREA",.F.)	//Data de vencimento real do titulo
Private nVlrTit 	:= Criavar("E2_VALOR",.F.)		//Valor do titulo
Private nVlrPgto 	:= Criavar("E2_VALOR",.F.)		//Valor Pago (e2_valor-Somatorio zx_valor)
Private nRateio 	:= 0							//Percentual de rateio (h/g)
Private cRatCTB 	:= "Não"						//Indica se o titulo principal existe rateio contabil, somente no CP
Private cPerg		:= "SIFINR13"

DEFAULT nCar		:= 0

nCart := nCar


If nCart == 0 //Chamada do Menu e nao de rotina especifica
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                     ³
	//³ mv_par01            // Carteira (1=CP / 2=CR)             ³
	//³ mv_par02            // Mutuo de                          ³
	//³ mv_par03            // Mutuo Ate                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	AjustaSX1(cPerg)
	Pergunte(cPerg,.T.)	
	
EndIf

//Chama rotina de impressao
RptStatus({|lEnd| RotImp(@lEnd)},"Aguarde...", "Imprimindo o Relatório", .T. )

//RotImp(@lEnd)

RestArea(aArea)

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RotImp   ³ Autor ³ Totvs..               ³ Data ³ Abr/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de impressao do relatorio                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RotImp(lEnd)

Local cAliTrb 	:= "" //Alias de trabalho
Local cIniCpo 	:= "" //Compoe parte do nome do campo E1_ OU E2_
Local cAtualiza 	:=	"" //Variavel de apoio para macrosubstituicao
Local nCont 		:= 1000

oPrint:= TMSPrinter():New(cCadastro)

// Este comando configura a saida do TMSPRINTER e eh importante te-lo pois o Servidor ASP nao tem impressora instalada
oPrint:Setup()
oPrint:SetPortrait()	//SetLandscape()
oPrint:StartPage()	// Inicia uma nova página

SetRegua(nCont)

If nCart == 0 //Chamada do Menu de Relatorios direto e nao de rotina especifica
	
	If Mv_par01 == 2  //Contas a Receber
		cAliTrb := "SE1"
		cCarteira := "R"
	Else //Contas a Pagar
		cAliTrb := "SE2"
		cCarteira := "P"
	EndIf
	
	cIniCpo := SubStr(cAliTrb,2,2)+"_"
	
	//Monta select para selecao dos registros
	cAliasTmp 	:= GetNextAlias()
	
	_cFrom	:= "% "+RetSqlName(cAliTrb)+" %"
	_cFil 	:= "%"+cIniCpo+"FILIAL = '"+xFilial(cAliTrb)+"'%"
	_cMutuo := "%"+cIniCpo+"XMUTUO BETWEEN '"+Mv_par02+"' AND '"+Mv_par03+"'%"
	//_cStatus:= "%"+cIniCpo+"XSTATUS = '2'%" //0=Nao Utiliza;1=Em Aberto;2=Finalizado
	If cCarteira == "P"
		_cOrigem:= "%"+cIniCpo+"XORIGEM = '1'%" //1=Contas a Pagar;2=Contas a Receber;3=Agregado
	Else
		_cOrigem:= "%"+cIniCpo+"XORIGEM = '2'%" //1=Contas a Pagar;2=Contas a Receber;3=Agregado
	EndIf
	_cOrder := "%"+cIniCpo+"XMUTUO%"
	
	BeginSQL Alias cAliasTmp
		
		SELECT *
		FROM %exp:_cFrom%
		WHERE %exp:_cFil%
		AND %NotDel%
		AND %exp:_cMutuo%
		AND %exp:_cOrigem%
		ORDER BY %exp:_cOrder%
		
	EndSQL
	
	//MemoWrite("\SYSTEM\FINR13A.SQL",GetLastQuery()[2])
	
	dbSelectArea((cAliasTmp))
	
	IF Select((cAliasTmp)) > 0
		
		While !EOF()
			
			//Carrega as variaveis a ser utilizado no relatorio
			cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"XMUTUO"
			cMutuo 		:= &cAtualiza//Numero Processo Mutuo
			cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"XSTATUS"
			cStatus	:= &cAtualiza//Status do mutuo onde 0=Nao Utiliza;1=Em Aberto;2=Finalizado
			cAtualiza 	:= cAliasTmp+"->"+cIniCpo+Iif(cCarteira=="P","FORNECE","CLIENTE")
			cCliFor 	:= &cAtualiza//Codigo do cliente ou fornecedor
			cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"LOJA"
			cLoja		:= &cAtualiza//Loja do cliente ou fornecedor
			cAtualiza 	:= cAliasTmp+"->"+cIniCpo+Iif(cCarteira=="P","NOMFOR","NOMCLI")
			cNome       := &cAtualiza//Nome do cliente ou fornecedor
			cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"PREFIXO"
			cPrefixo 	:= &cAtualiza//Prefixo do Titulo
			cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"NUM"
			cNumero 	:= &cAtualiza//Numero do Titulo
			cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"PARCELA"
			cParcela 	:= &cAtualiza//Parcela do Titulo
			cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"TIPO"
			cTipo 		:= &cAtualiza//Tipo do Titulo
			cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"EMISSAO"
			dEmissao 	:= sTod(&cAtualiza)//Data de emissao do titulo
			cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"VENCREA"
			dVenc		:= sTod(&cAtualiza)//Data de vencimento real do titulo
			cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"VALOR"
			nVlrTit 	:= &cAtualiza//Valor do titulo
			
			nVlrPgto 	:= nVlrTit-VlrMutuo(cMutuo)//Valor a Pagar (e2_valor-Somatorio zx_valor)
			
			nRateio 	:= (nVlrPgto/nVlrTit)*100 //Percentual de rateio (h/g)
			
			If cCarteira == "P"
				cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"RATEIO"
				cRatCTB 	:= &cAtualiza //Indica se o titulo principal existe rateio contabil, somente no CP
				cRatCTB		:= Iif(cRatCTB=="S","Sim","Não")
			EndIf
			
			//Chama a impressao
			ImpReg()
			
			dbSelectArea((cAliasTmp))
			DbSkip()
		EndDo
		
		DbSelectArea((cAliasTmp))
		DbCloseArea()
		
	EndIf
	
Else //Chamada de funcao especifica onde o registro do SE1 ou SE2 esta posicionado
	
	If nCart == 1 //CP
		cAliasTmp := "SE2"
		cCarteira := "P"
	Else //CR
		cAliasTmp := "SE1"
		cCarteira := "R"
	EndIf
	
	cIniCpo := SubStr(cAliasTmp,2,2)+"_"
	
	//Carrega as variaveis a ser utilizado no relatorio
	cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"XMUTUO"
	cMutuo 		:= &cAtualiza//Numero Processo Mutuo
	cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"XSTATUS"
	cStatus	:= &cAtualiza//Status do mutuo onde 0=Nao Utiliza;1=Em Aberto;2=Finalizado
	cAtualiza 	:= cAliasTmp+"->"+cIniCpo+Iif(cCarteira=="P","FORNECE","CLIENTE")
	cCliFor 	:= &cAtualiza//Codigo do cliente ou fornecedor
	cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"LOJA"
	cLoja		:= &cAtualiza//Loja do cliente ou fornecedor
	cAtualiza 	:= cAliasTmp+"->"+cIniCpo+Iif(cCarteira=="P","NOMFOR","NOMCLI")
	cNome       := &cAtualiza//Nome do cliente ou fornecedor
	cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"PREFIXO"
	cPrefixo 	:= &cAtualiza//Prefixo do Titulo
	cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"NUM"
	cNumero 	:= &cAtualiza//Numero do Titulo
	cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"PARCELA"
	cParcela 	:= &cAtualiza//Parcela do Titulo
	cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"TIPO"
	cTipo 		:= &cAtualiza//Tipo do Titulo
	cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"EMISSAO"
	dEmissao 	:= &cAtualiza//Data de emissao do titulo
	cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"VENCREA"
	dVenc		:= &cAtualiza//Data de vencimento real do titulo
	cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"VALOR"
	nVlrTit 	:= &cAtualiza//Valor do titulo
	
	nVlrPgto 	:= nVlrTit-VlrMutuo(cMutuo)//Valor a Pagar (e2_valor-Somatorio zx_valor)
	
	nRateio 	:= (nVlrPgto/nVlrTit)*100 //Percentual de rateio (h/g)
	
	If cCarteira == "P"
		cAtualiza 	:= cAliasTmp+"->"+cIniCpo+"RATEIO"
		cRatCTB 	:= &cAtualiza //Indica se o titulo principal existe rateio contabil, somente no CP
		cRatCTB		:= Iif(cRatCTB=="S","Sim","Não")
	EndIf
	
	//Chama a impressao
	ImpReg()
	
EndIf

oPrint:Preview()
oPrint:End()

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VlrMutuo ³ Autor ³ Totvs..               ³ Data ³ Abr/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o somatorio dos registro de mutuo.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VlrMutuo(cMutuo)

Local nRet 		:= 0
Local cAliasSZX	:= GetNextAlias()
Local _cSelect 	:= ""

_cSelect	:= 	Iif(lOracle,"%NVL(SUM(ZX_VALOR),0) AS VALOR %","% ISNULL(SUM(ZX_VALOR),0) AS VALOR %")

BeginSQL Alias cAliasSZX
	
	SELECT %Exp:_cSelect%
	FROM %table:SZX%
	WHERE ZX_FILIAL = %xFilial:SZX%
	AND %NotDel%
	AND ZX_RATEIO = %Exp:cMutuo%
	
EndSQL

//MemoWrite("\SYSTEM\FINR13B.SQL",GetLastQuery()[2])

dbSelectArea((cAliasSZX))

IF Select((cAliasSZX)) > 0
	nRet := (cAliasSZX)->VALOR
	DbSelectArea((cAliasSZX))
	DbCloseArea()
ENDIF

Return(nRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ImpReg   ³ Autor ³ Totvs..               ³ Data ³ Abr/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de impressao dos registros                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpReg()

Local aAreaA := GetArea()
Local cTeste := GetMv("MV_ESTNEG") //So criei essa linha p/ funcionar o GetAdvFVal, se nao da erro.

//oPrint:SayBitmap(330 ,1900, "\System\LOGO.BMP",0180 ,130)	 //Tem que estar abaixo do RootPath Logotipo

If nRow >= nTamForm
	If lFirst //Para fazer o controle da primeira impressao.
		oPrint:EndPage()
		oPrint:StartPage()
	EndIf
	ImpCabe()
	lFirst := .t.
EndIf

//nRow:=nRow+220
cMut := "Número Processo Mútuo a "+Iif(cCarteira == "R",'Receber: ','Pagar: ')
oPrint:Say(nRow,0055,cMut,oFont09b)	//Texto
oPrint:Say(nRow,0690,cMutuo,oFont09)	//Variavel

If cCarteira == "R"
	cStat := U_RetCombo("E1_XSTATUS",Alltrim(cStatus))
Else
	cStat := U_RetCombo("E2_XSTATUS",Alltrim(cStatus))
EndIf
oPrint:Say(nRow,1000,"Status:",oFont09b)	//Texto
oPrint:Say(nRow,1200,cStat,oFont09)	//Variavel

nRow:=nRow+50
_cEmp := cFilAnt+" - "+ Alltrim(SM0->M0_NOMECOM)
oPrint:Say(nRow,0055,"Origem: ",oFont09b)	//Texto
oPrint:Say(nRow,0210,_cEmp,oFont09)	//Variavel

nRow:=nRow+50
If cCarteira == "R"
	cNome := GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+cCliFor+cLoja,1,0)
Else
	cNome := GetAdvFVal("SA2","A2_NOME",xFilial("SA2")+cCliFor+cLoja,1,0)
EndIf
cTP := Iif(cCarteira == "R",'Cliente: ','Fornecedor: ')
cClFo := Alltrim(cCliFor)+"/"+Alltrim(cLoja)+" - "+Alltrim(cNome)
oPrint:Say(nRow,0055,cTP,oFont09b)	//Texto
oPrint:Say(nRow,0290,cClFo,oFont09)	//Variavel

//Inicia a impressao do titulo principal
//Texto
nRow:=nRow+100
oPrint:Say(nRow,0055,"Pref",oFont09b)
oPrint:Say(nRow,0200,"Número",oFont09b)
oPrint:Say(nRow,0460,"Parc",oFont09b)
oPrint:Say(nRow,0600,"Tipo",oFont09b)
oPrint:Say(nRow,0720,"Dt. Emissão",oFont09b)
oPrint:Say(nRow,1000,"Dt. Vencto",oFont09b)
oPrint:Say(nRow,1290,"Valor do Título",oFont09b)
cTxVlr := Iif(cCarteira == "R",'Valor a Receber','Valor a Pagar')
oPrint:Say(nRow,1670,cTxVlr,oFont09b)
oPrint:Say(nRow,2000,"%Rateio",oFont09b)
oPrint:Say(nRow,2200,"Rateio CTB",oFont09b)

//Variaveis do Texto
nRow:=nRow+50
oPrint:Say(nRow,0055,cPrefixo,oFont09)
oPrint:Say(nRow,0200,cNumero,oFont09)
oPrint:Say(nRow,0460,cParcela,oFont09)
oPrint:Say(nRow,0620,cTipo,oFont09)
oPrint:Say(nRow,0725,dToc(dEmissao),oFont09)
oPrint:Say(nRow,1000,dToc(dVenc),oFont09)
oPrint:Say(nRow,1310,Transform(nVlrTit, "@E 999,999,999.99"),oFont09)
oPrint:Say(nRow,1670,Transform(nVlrPgto,"@E 99,999,999.99"),oFont09)
oPrint:Say(nRow,2000,Transform(nRateio, "@E 999.99"),oFont09)
oPrint:Say(nRow,2270,cRatCTB,oFont09)

nRow:=nRow+50
oPrint:Line(nRow,0055,nRow,2400)

//Inicia a impressao do rateio mutuo
nRow:=nRow+50
oPrint:Say(nRow,0055,"Distribuição:",oFont09b)

nRow:=nRow+50
oPrint:Say(nRow,0055,"Empresa",oFont09b)
oPrint:Say(nRow,0280,"Nome",oFont09b)
cTxVlr := Iif(cCarteira == "R",'Valor a Receber','Valor a Pagar')
oPrint:Say(nRow,1670,cTxVlr,oFont09b)
oPrint:Say(nRow,2000,"%Rateio",oFont09b)
oPrint:Say(nRow,2200,"Rateio CTB",oFont09b)

If nRow >= nTamForm
	oPrint:EndPage()
	oPrint:StartPage()
	ImpCabe()
EndIf

//Crio o proximo alias para gerar arquivo de mutuo
cAliasTmp2	:= GetNextAlias()

//Chama funcao para identificar a distribuicao do mutuo
VerDist()

IF Select((cAliasTmp2)) > 0
	
	nTotVlRat  := 0 //Usada para somar o valor de rateio entre as entidades distribuidas
	nTotRat	:= 0 //Usada para somar os percentuais de rateio entre as entidades distribuidas
	
	nRow:=nRow+50
	
	While !EOF()
		
		If nRow >= nTamForm
			oPrint:EndPage()
			oPrint:StartPage()
			ImpCabe()
		EndIf
		
		_NomFil := "" 		//Usada para carregar o nome de filial que recebeu o rateio
		cRatSN := "Não" 	//Usada para indicar se o rateio de mutuo tem rateio contabil
		
		oPrint:Say(nRow,0055,(cAliasTmp2)->ZX_CODEMP,oFont09) //Codigo da filial
		_NomFil := GetAdvFVal("SM0","M0_NOMECOM",cEmpAnt+(cAliasTmp2)->ZX_CODEMP,1,0)
		_NomFil := SubStr(Alltrim(_NomFil),1,56)
		oPrint:Say(nRow,0280,_NomFil,oFont09) //Nome da Filial
		oPrint:Say(nRow,1650,Transform((nVlrTit*(cAliasTmp2)->ZX_PERC)/100, "@E 999,999,999.99"),oFont09) //Valor a pagar/recever
		oPrint:Say(nRow,2000,Transform((cAliasTmp2)->ZX_PERC, "@E 999.99"),oFont09)	 //Percentual de rateio
		
		//Chama funcao para verificar se o registro em questao possui rateio contabil do mutuo
		cRatSN := VerRatCont( (cAliasTmp2)->ZX_RATEIO,(cAliasTmp2)->ZX_ITEM )
		oPrint:Say(nRow,2280,cRatSN,oFont09) //Se tem ou nao rateio contabil
		
		nTotVlRat	+= (nVlrTit*(cAliasTmp2)->ZX_PERC)/100
		nTotRat 	+= (cAliasTmp2)->ZX_PERC
		
		nRow:=nRow+50
		
		dbSelectArea((cAliasTmp2))
		dbSkip()
	EndDo
	
	DbCloseArea()
ENDIF

RestArea(aAreaA)

nRow:=nRow+125
oPrint:Say(nRow,1290,"Total Geral>>",oFont09b)
oPrint:Say(nRow,1670,Transform(nTotVlRat+nVlrPgto,"@E 99,999,999.99"),oFont09) //Somatorio do valor total dos rateio mais o valor referente ao titulo principal
oPrint:Say(nRow,2000,Transform(nTotRat+nRateio, "@E 999.99"),oFont09)	  //Somatorio do % de rateio total mais % de rateio referente ao titulo principal

nRow:=nRow+100
oPrint:Line(nRow,0055,nRow,2400)
nRow:=nRow+25
oPrint:Line(nRow,0055,nRow,2400)
nRow:=nRow+50

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VerDist  ³ Autor ³ Totvs..               ³ Data ³ Abr/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para identificar a distribuicao do mutuo            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VerDist()

BeginSQL Alias cAliasTmp2
	
	SELECT ZX_FILIAL, ZX_RATEIO, ZX_ITEM, ZX_CODEMP, ZX_PERC
	FROM %table:SZX%
	WHERE ZX_FILIAL = %xFilial:SZX%
	AND %NotDel%
	AND ZX_RATEIO = %Exp:cMutuo%
	
EndSQL

//MemoWrite("\SYSTEM\FINR13C.SQL",GetLastQuery()[2])

dbSelectArea((cAliasTmp2))

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VerDist  ³ Autor ³ Totvs..               ³ Data ³ Abr/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para identificar a distribuicao do mutuo            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VerRatCont(cNumMut,cItMut)

Local aAreaB		:= GetArea()
Local cRet 		:= "Não"
Local cAliasTmp3	:= GetNextAlias()

BeginSQL Alias cAliasTmp3
	
	SELECT *
	FROM %table:SZY%
	WHERE ZY_FILIAL = %xFilial:SZY%
	AND %NotDel%
	AND ZY_RATEIO = %Exp:cNumMut%
	AND ZY_ITEMRAT = %Exp:cItMut%
	
EndSQL

DbSelectArea((cAliasTmp3))

IF Select((cAliasTmp3)) > 0
	If !Empty((cAliasTmp3)->ZY_RATEIO)
		cRet := "Sim"
	EndIf
	DbCloseArea()
ENDIF

RestArea(aAreaB)

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ImpCabe  ³ Autor ³ Totvs..               ³ Data ³ Abr/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime cabecalho e trata quebra de pagina.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpCabe()

//oPrint:SayBitmap(330 ,1900, "\System\LOGO.BMP",0180 ,130)	 //Tem que estar abaixo do RootPath Logotipo
nRow := 100

//Informacao da empresa
oPrint:Box(nRow,0050,0320,2400 )
nRow:=nRow+80
oPrint:Say(nRow,0720,cCadastro,oFont18b)

nRow:=nRow+220

If lFirst //Para fazer o controle da primeira impressao.
	nRow+=150
EndIf

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AjustaSX1 ³ Autor ³ Marcos V. Ferreira    ³ Data ³ 21.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta o grupo de perguntas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR285                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AjustaSX1(cPerg)
	PutSx1( cPerg, "01",'Carteira?', 'Carteira?', 'Carteira?',	'mv_ch1', 'N',1 ,0,1,'C','','','','','mv_par01','Pagar','Pagar','Pagar', '','Receber','Receber','Receber','','','','','','','','','',{"Seleção da Carteira a ser impressa."},{"Seleção da Carteira a ser impressa."},{"Seleção da Carteira a ser impressa."})
	PutSx1( cPerg, "02",'Mutuo de ',  'Mutuo de', 'Mutuo de',   "mv_ch2","C" ,6	,0,0,"G","","","","","mv_par02",''		,''	   ,''     , '',''		 ,""		,  ""	 ,'','','','','','','','','',{"Faixa inicio do Código do Rateio"},{"Faixa inicio do Código do Rateio"},{"Faixa inicio do Código do Rateio"})			
	PutSx1( cPerg, "03","Mutuo Ate ",'Mutuo Ate', 'Mutuo Ate'  ,"mv_ch3","C", 6 ,0,0,"G","naovazio()",""		,"","","mv_par03","","ZZZZZZ","","","","","","","","","","","","","","",{"Faixa fim do Código do Rateio"},{"Faixa fim do Código do Rateio"},{"Faixa fim do Código do Rateio"})			
Return
