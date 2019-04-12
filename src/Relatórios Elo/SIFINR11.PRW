#Include "PROTHEUS.CH"

Static lFWCodFil := FindFunction("FWCodFil")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ SIFINR11 ณ Autor ณ Leonardo Soncin       ณ Data ณ 07.11.11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Relacao de Borderos Consolidados                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe e ณ SIFINR11(void)                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SIFINR11()
Local oReport
Local nOpcA := 0
Local cPerg := ""

nOpcA := Aviso( "Borderos Consolidados", "Deseja imprimir o relat๓rio no modelo Normal ou Banco?", { "Normal", "Banco", "Cancelar" }, 1, "Modelo do Relat๓rio" )

If nOpca == 1 // Normal
	cPerg := "SIFR02"
ElseIf nOpca == 2 // Banco
	cPerg := "SIFR2B"
Else
	Return
Endif

If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef(cPerg,nOpca)
	oReport:PrintDialog()
Else
	Alert("Relat๓rio nใo disponํvel para R3!")
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ ReportDefณ Autor ณ Daniel Batori         ณ Data ณ 28.08.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Definicao do layout do Relatorio			     			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ReportDef(void)                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef(cPerg,nOpca)
Local oReport
Local oSection1     

ValidPerg(cPerg)

oReport := TReport():New("SIFINR11","Relat๓rio de Border๔s Consolidados",cPerg, {|oReport| ReportPrint(oReport,nOpca)},"Este programa tem como objetivo imprimir os border๔s de pagamentos consolidado.")
oReport:HideHeader()	//Oculta o cabecalho do relatorio
oReport:SetPortrait()	//Imprime o relatorio no formato retrato
oReport:HideFooter()	//Oculta o rodape do relatorio
oReport:SetTotalInLine(.F.)

Pergunte(cPerg,.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                                                                        ณ
//ณ                      Definicao das Secoes                              ณ
//ณ                                                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Secao 01                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New(oReport, "BORDERO" , {"SEA","SA6","SEF","SA2","SE2"})

TRCell():New(oSection1, "CC"     , ""   , "Conta Corrente p/ D้bito" , PesqPict("SA2","A2_NOME")   , 33,/*lPixel*/,/*CodeBlock*/)
TRCell():New(oSection1, "BENEF"     , ""   , "Credor" , PesqPict("SA2","A2_NOME")   , 33,/*lPixel*/,/*CodeBlock*/)
TRCell():New(oSection1, "A2_CGC"  	, "SA2", "CNPJ/CPF" , "@R 99999999/9999999"       , 20,/*lPixel*/,/*CodeBlock*/)
TRCell():New(oSection1, "A2_BANCO"  , "SA2", "Banco" , PesqPict("SA2","A2_BANCO")  , TamSX3("A2_BANCO")[1]  ,/*lPixel*/,/*CodeBlock*/)
TRCell():New(oSection1, "A2_AGENCIA", "SA2", "Ag๊ncia" , PesqPict("SA2","A2_AGENCIA"), TamSX3("A2_AGENCIA")[1],/*lPixel*/,/*CodeBlock*/)
TRCell():New(oSection1, "A2_NUMCON" , "SA2", "Conta Corrente" , PesqPict("SA2","A2_NUMCON") , TamSX3("A2_NUMCON")[1] ,/*lPixel*/,/*CodeBlock*/)
TRCell():New(oSection1, "E2_VENCREA" ,"SE2", "Vencimento" , PesqPict("SE2","E2_VENCREA") , TamSX3("E2_VENCREA")[1] ,/*lPixel*/,/*CodeBlock*/)
TRCell():New(oSection1, "VALORPAGAR", ""   , "Valor" , TM(0,17), 17,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"RIGHT",,,.F.  )

oSection1:SetPageBreak(.F.)		//Salta a pagina na quebra da secao
oSection1:SetTotalInLine(.F.) 	//O totalizador da secao sera impresso em linha
oSection1:SetHeaderBreak(.T.)   //Imprime o cabecalho das celulas apos a quebra

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณReportPrintณ Autor ณDaniel Batori          ณ Data ณ22.08.06	ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณA funcao estatica ReportDef devera ser criada para todos os  ณฑฑ
ฑฑณ          ณrelatorios que poderao ser agendados pelo usuario.           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpO1: Objeto Report do Relat๓rio                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportPrint(oReport,nOpca)
Local oSection1 	:= oReport:Section(1)
Local oBreak1
Local oBreak2
Local oFunction1
Local oFunction2
Local oFunction4
Local cChave      	:= ""
Local cFiltro     	:= ""
Local cAliasSea		:= "SEA"
Local cJoin 		:= ""
Local lBaixa		:= .F.
Local lCheque    	:= .F.
Local lAbatimento 	:= .F.
Local cLoja  		:= ""
Local nVlrPagar		:= 0
Local cModelo   	:= CriaVar("EA_MODELO")
Local cNumConta		:= CriaVar("EA_NUMCON")
Local lSeaEof     	:= .F.
Local nValTot := 0

Private nJuros := 0
Private dBaixa := CriaVar("E2_BAIXA")          

cChave := SEA->(IndexKey())

#IFDEF TOP
	
	cAliasSea 		:= GetNextAlias()
	
	cChave 	:= "%"+SqlOrder(cChave)+"%"
	
	oSection1:BeginQuery()
	
	BeginSql Alias cAliasSea
		SELECT 	SEA.EA_FILIAL, SEA.EA_FILORIG, SEA.EA_NUMBOR, SEA.EA_NUMCON, SEA.EA_CART, SEA.EA_FILORIG, SEA.EA_PREFIXO, SEA.EA_NUM,
		SEA.EA_PARCELA, SEA.EA_TIPO, SEA.EA_FORNECE, SEA.EA_LOJA, SEA.EA_MODELO , SEA.EA_PORTADO, SEA.EA_AGEDEP,
		SEA.EA_DATABOR, SEA.EA_XFILE, SA2.A2_NOME
		FROM
		%table:SEA% SEA, %table:SA2% SA2
		WHERE
		SEA.EA_FORNECE = SA2.A2_COD AND
		SEA.EA_LOJA = SA2.A2_LOJA AND
		SEA.EA_FILIAL = %xfilial:SEA% AND
		SEA.EA_NUMBOR >= %Exp:mv_par01% AND
		SEA.EA_NUMBOR <= %Exp:mv_par02% AND
		SEA.EA_DATABOR >= %Exp:mv_par03% AND
		SEA.EA_DATABOR <= %Exp:mv_par04% AND
		SEA.EA_PORTADO = %Exp:mv_par05% AND
		SEA.EA_AGEDEP = %Exp:mv_par06% AND
		SEA.EA_NUMCON >= %Exp:mv_par07% AND
		SEA.EA_NUMCON <= %Exp:mv_par08% AND
		SEA.EA_CART = 'P' AND
		SA2.%notDel% AND
		SEA.%notDel%
		ORDER BY SEA.EA_NUMCON, SA2.A2_NOME
	EndSql
	oSection1:EndQuery()
	
#ELSE
	
	cFiltro := "EA_FILIAL == '" + xFilial("SEA") + "' .And. "
	cFiltro += "EA_NUMBOR >= '" + mv_par01 + "' .And. "
	cFiltro += "EA_NUMBOR <= '" + mv_par02 + "' .And. "
	cFiltro += "EA_DATABOR >= '" + Dtos(mv_par03) + "' .And. "
	cFiltro += "EA_DATABOR <= '" + Dtos(mv_par04) + "' .And. "
	cFiltro := "EA_PORTADO == '" + mv_par05 + "' .And. "
	cFiltro := "EA_AGEDEP == '" +  mv_par06 + "' .And. "
	cFiltro += "EA_NUMCON >= '" + mv_par07 + "' .And. "
	cFiltro += "EA_NUMCON <= '" + mv_par08 + "' .And. "
	cFiltro += "EA_CART = 'P'"
	
	TRPosition():New(oSection1,"SE2",1,{|| If( Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(xFilial("SE2")),;
	xFilial("SE2")+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+AllTrim((cAliasSea)->EA_LOJA),;
	(cAliasSea)->EA_FILORIG+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+AllTrim((cAliasSea)->EA_LOJA)) } )
    
	oSection1:SetFilter(cFiltro,cChave)
	
#ENDIF

If nOpca == 1 // Banco
	oSection1:SetLineCondition( { ||	 u_FR710Chk(cAliasSea) } )
Endif              
    
TRPosition():New(oSection1,"SE2",1,{|| If( Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(xFilial("SE2")),;
xFilial("SE2")+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+AllTrim((cAliasSea)->EA_LOJA),;
(cAliasSea)->EA_FILORIG+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+AllTrim((cAliasSea)->EA_LOJA)) } )

oSection1:OnPrintLine( { || lBaixa := Fr710BxVL(cAliasSea, IIf (Empty((cAliasSea)->EA_LOJA), "", (cAliasSea)->EA_LOJA)), If(!lBaixa, lBaixa := Fr710BxBA(cAliasSea), Nil ),;
lCheque := (!Empty(SE5->E5_NUMCHEQ) .And. SEF->(MsSeek(xFilial("SEF")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+SE5->E5_NUMCHEQ))),;
Fr710Config(cAliasSea, oSection1,nOpca), .T. } )

nValTot := xTot(cAliasSea) 

oBreak1 := TRBreak():New(oSection1, { ||(cAliasSea)->EA_NUMCON })
oBreak1:OnBreak( {|cNumConta| oBreak1:SetTitle(SPACE(110)+"Total Conta Corrente " + Alltrim(cNumConta) + ":") } )
oFunction1 := TRFunction():New(oSection1:Cell("VALORPAGAR"),,"SUM", oBreak1,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

oSection1:Cell("CC"):SetBlock( { ||  Alltrim((cAliasSea)->EA_NUMCON) +' - ' + IIF (SA6->(MsSeek(xFilial("SA6")+(cAliasSea)->(EA_PORTADO+EA_AGEDEP+EA_NUMCON))),Alltrim(SA6->A6_DVCTA),)} )
oSection1:Cell("BENEF"):SetBlock( { || Fr710Benef(cAliasSea, lBaixa, lCheque, lAbatimento) } )
oSection1:Cell("A2_CGC" ):SetBlock( { || Transform(SA2->A2_CGC, IIF(Len(Alltrim(SA2->A2_CGC))>11,"@R 99999999/9999-99","@R 999999999-99")) } )
oSection1:Cell("A2_BANCO" ):SetBlock( { || Iif(!Empty(SE2->E2_XBANCO),SE2->E2_XBANCO,SA2->A2_BANCO) } )
oSection1:Cell("A2_AGENCIA" ):SetBlock( { || Iif(!Empty(SE2->E2_XAGENC),SE2->E2_XAGENC,SA2->A2_AGENCIA) } )
oSection1:Cell("A2_NUMCON" ):SetBlock( { || Iif(!Empty(SE2->E2_XNUMCON),SE2->E2_XNUMCON,SA2->A2_NUMCON) } )
oSection1:Cell("VALORPAGAR"):SetBlock( { || Fr710VPagar(cAliasSea, lBaixa, lCheque, lAbatimento ) } )
 
oReport:OnPageBreak( { || ReportCabec(oReport, cModelo := (cAliasSea)->EA_MODELO, cAliasSea, lBaixa, lSeaEof,nOpca,nValTot) } )

// Total Geral
oBreak2 := TRBreak():New(oSection1, { || (cAliasSea)->EA_FILIAL })
oFunction2:= TRFunction():New(oSection1:Cell("VALORPAGAR"),,"SUM",,""/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
oFunction2:Disable()

If nOpca == 2
	oReport:SetPageFooter( 12 , {||  ReportTxtAut(oReport,oFunction2:GetLastValue(),cAliasSea,nValTot)  } )
Endif

TRFunction():New(oSection1:Cell("VALORPAGAR"),,"SUM",,""/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicia a impressao.						 								  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oSection1:Print()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ ValidPergณ Autor ณ Wagner Gomes          ณ Data ณ 10/12/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria as Perguntas para Fatura para locacao de Bens Moveis  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Especifico Construtora OAS Ltda                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValidPerg(cPerg)

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Bordero de: "				,"mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Bordero at้: "				,"mv_ch2","C",06,0,0,"G","naovazio()","mv_par02","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Emissใo de:  "				,"mv_ch3","D",08,0,0,"G","naovazio()","mv_par03","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Emissใo at้: "				,"mv_ch4","D",08,0,0,"G","naovazio() .and. mv_par04>=mv_par03","mv_par04","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Banco: "					,"mv_ch5","C",03,0,0,"G","naovazio()","mv_par05","","","","","","","","","","","","","","","SA6",""})
aAdd(aRegs,{cPerg,"06","Agencia: "					,"mv_ch6","C",05,0,0,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Conta de: "					,"mv_ch7","C",10,0,0,"G","NaoVazio()","mv_par07","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Conta at้: "				,"mv_ch8","C",10,0,0,"G","NaoVazio()","mv_par08","","","","","","","","","","","","","","","",""})

If !(Alltrim(cPerg) == "SIFR2B")
	aAdd(aRegs,{cPerg,"09","Outras moedas:"				,"mv_ch9","N",01,0,0,"C","","mv_par09","Converter","","","Nใo Imprimir","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Data de pagamento:"			,"mv_chA","D",08,0,0,"G","NaoVazio()","mv_par10","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"11","Numero:"					,"mv_chB","C",15,0,0,"G","NaoVazio()","mv_par11","","","","","","","","","","","","","","","",""})
Endif

For i := 1 to Len(aRegs)
	PutSX1(aRegs[i,1],aRegs[i,2],aRegs[i,3],aRegs[i,3],aRegs[i,3],aRegs[i,4],aRegs[i,5],aRegs[i,6],aRegs[i,7],;
	aRegs[i,8],aRegs[i,9],aRegs[i,10],iif(len(aRegs[i])>=26,aRegs[i,26],""),aRegs[i,27],"",aRegs[i,11],aRegs[i,12],;
	aRegs[i,12],aRegs[i,12],aRegs[i,13],aRegs[i,15],aRegs[i,15],aRegs[i,15],aRegs[i,18],aRegs[i,18],aRegs[i,18],;
	aRegs[i,21],aRegs[i,21],aRegs[i,21],aRegs[i,24],aRegs[i,24],aRegs[i,24])
	
Next i

dbSelectArea(_sAlias)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFr710BxVL บAutor  ณ Marcio Menon       บ Data ณ  28/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existe movimenta็ใo bancaria ou baixas que     บฑฑ
ฑฑบ          ณ movimentam banco.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 	                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fr710BxVL(cAliasSea, cLoja, lBaixa)
Local sFilial
Local cChave := ""

// Borderos gerados em versao anterior
IF Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(xFilial("SE2"))
	cChave := xFilial("SE2")+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+cLoja
Else //Borderos gerados a partir da versao 7.10
	cChave := (cAliasSea)->EA_FILORIG+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+cLoja
Endif
DbSelectArea("SE2")
dbSetOrder(1)
MsSeek(cChave)

If ( !Empty( xFilial("SE2") ) .and. !Empty( xFilial("SE5") )) .or. (Empty( xFilial("SE2") ) .and. !Empty( xFilial("SE5") ))
	sFilial := SE2->E2_FILIAL
Else
	sFilial := xFilial("SE5")
EndIf

dbSelectArea("SE5")
dbSetOrder(2)
SE5->(MsSeek(sFilial+"VL"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+DtoS(SE2->E2_BAIXA)+SE2->E2_FORNECE+SE2->E2_LOJA ))

While SE5->(!Eof()) .and. ;
	SE5->E5_FILIAL		== sFilial	 .and. ;
	SE5->E5_TIPODOC	== "VL"            .and. ;
	SE5->E5_PREFIXO	== SE2->E2_PREFIXO .and. ;
	SE5->E5_NUMERO		== SE2->E2_NUM 	 .and. ;
	SE5->E5_PARCELA	== SE2->E2_PARCELA .and. ;
	SE5->E5_TIPO		== SE2->E2_TIPO	 .and. ;
	SE5->E5_DATA		== SE2->E2_BAIXA	 .and. ;
	SE5->E5_CLIFOR		== SE2->E2_FORNECE .and. ;
	SE5->E5_LOJA		== cLoja
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Sข considera baixas que nao possuem estorno   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
		If SubStr( SE5->E5_DOCUMEN,1,6 ) == (cAliasSea)->EA_NUMBOR .And. SE5->E5_MOTBX != "PCC"
			lBaixa := .T.
			Exit
		Endif
	EndIf
	SE5->(dbSkip())
Enddo

Return lBaixa

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFr710BxBA บAutor  ณ Marcio Menon       บ Data ณ  28/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existe baixa automatica ou baixa que nao tenha บฑฑ
ฑฑบ          ณ movimentacao bancaria.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 	                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Fr710BxBA(cAliasSea, lBaixa)
Local sFilial
Local cChave := ""

// Borderos gerados em versao anterior
IF Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(xFilial("SE2"))
	cChave := xFilial("SE2")+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+(cAliasSea)->EA_LOJA
Else //Borderos gerados a partir da versao 7.10
	cChave := (cAliasSea)->EA_FILORIG+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+(cAliasSea)->EA_LOJA
Endif

DbSelectArea("SE2")
dbSetOrder(1)
MsSeek(cChave)

If ( !Empty( xFilial("SE2") ) .and. !Empty( xFilial("SE5") )) .or. (Empty( xFilial("SE2") ) .and. !Empty( xFilial("SE5") ))
	sFilial := SE2->E2_FILIAL
Else
	sFilial := xFilial("SE5")
EndIf

dbSelectArea("SE5")
dbSetOrder(2)

If (SE5->(MsSeek( sFilial +"BA"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+DtoS(SE2->E2_BAIXA)+SE2->E2_FORNECE+SE2->E2_LOJA)))
	While SE5->(!Eof()) .and. ;
		SE5->E5_FILIAL		== sFilial	 .and. ;
		SE5->E5_TIPODOC	== "BA"            .and. ;
		SE5->E5_PREFIXO	== SE2->E2_PREFIXO .and. ;
		SE5->E5_NUMERO		== SE2->E2_NUM 	 .and. ;
		SE5->E5_PARCELA	== SE2->E2_PARCELA .and. ;
		SE5->E5_TIPO		== SE2->E2_TIPO	 .and. ;
		SE5->E5_DATA		== SE2->E2_BAIXA	 .and. ;
		SE5->E5_CLIFOR		== SE2->E2_FORNECE .and. ;
		SE5->E5_LOJA		== SE2->E2_LOJA
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Sข considera baixas que nao possuem estorno   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
			If SubStr( SE5->E5_DOCUMEN,1,6 ) == (cAliasSea)->EA_NUMBOR .And. SE5->E5_MOTBX != "PCC"
				lBaixa := .T.
				Exit
			Endif
		EndIf
		SE5->(dbSkip())
	Enddo
Endif

Return lBaixa

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFr710BenefบAutor  ณ  Marcio Menon      บ Data ณ  28/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o campo Beneficiario conforme o modelo do          บฑฑ
ฑฑบ          ณ bordero.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fr710Benef(cAliasSea, lBaixa, lCheque, lAbatimento)

Local cBenef 		:= ""
Local cChave      := ""

// Localiza o fornecedor do titulo que esta no bordero
// Borderos gerados em versao anterior
IF Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(xFilial("SA2"))
	cChave := xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA
Else //Borderos gerados a partir da versao 7.10
	If !Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(xFilial("SA2"))
		cChave := (cAliasSea)->EA_FILORIG+SE2->E2_FORNECE+SE2->E2_LOJA
	Else
		cChave := xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA
	Endif
Endif

SA2->(MsSeek(cChave))

If (cAliasSea)->EA_MODELO $ "CH/02"
	If !lAbatimento
		If lCheque
			cBenef := SEF->EF_BENEF
		ElseIf lBaixa
			cBenef := SE5->E5_BENEF
		Else
			cBenef := SA2->A2_NOME
		Endif
	EndIf
Else
	cBenef := SA2->A2_NOME
Endif

Return cBenef

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFr710VPagar บAutor  ณ Marcio Menon       บ Data ณ  28/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz os calculos dos valores a pagar dos titulos.		       บฑฑ
ฑฑบ          ณ 						                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 	                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fr710VPagar(cAliasSea, lBaixa, lCheque, lAbatimento)

Local nAbat  		:= 0
Local nVlrPagar	:= 0

If lAbatimento
	nAbat 	:= SE2->E2_SALDO
Else
	nAbat := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA, SE2->E2_FILIAL)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Efetua calculo dos juros do titulo posicionado ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
fa080Juros(1)
If lBaixa
	If ! lAbatimento
		nVlrPagar := Round(NoRound(xMoeda(SE5->E5_VALOR,SE2->E2_MOEDA,1,dDataBase,MsDecimais(1)+1),MsDecimais(1)+1),MsDecimais(1))
		nAbat := 0
	EndIf
Else
	If ! lAbatimento
		nVlrPagar := Round(NoRound(xMoeda(SE2->E2_SALDO-SE2->E2_SDDECRE+SE2->E2_SDACRES-nAbat+nJuros,SE2->E2_MOEDA,1,dDataBase,MsDecimais(1)+1),MsDecimais(1)+1),MsDecimais(1))
	Endif
Endif

Return nVlrPagar

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportCabec บAutor  ณ Marcio Menon       บ Data ณ  28/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o cabecalho do relatorio.								       บฑฑ
ฑฑบ          ณ 						                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 	                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportCabec(oReport, cModelo, cAliasSea, lBaixa, lSeaEof,nOpca,nValTot)

Local cStartPath	:= GetSrvProfString("Startpath","")
Local cLogo			:= ""
Local lHlpNoTab 	:= .F.

If lBaixa
	SA6->(MsSeek(xFilial("SA6")+SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA)))
Else
	SA6->(MsSeek(xFilial("SA6")+(cAliasSea)->(EA_PORTADO+EA_AGEDEP+EA_NUMCON)))
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o cabecalho.									  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oReport:ThinLine()

cLogo := cStartPath + "LGRL" + SM0->M0_CODIGO + IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) + ".BMP" 	// Empresa+Filial

If !File( cLogo )
	cLogo := cStartPath + "LGRL" + SM0->M0_CODIGO + ".BMP" 						// Empresa
endif

oReport:SkipLine()
oReport:SayBitmap (oReport:Row(),005,cLogo,291,057)
oReport:SkipLine()
oReport:SkipLine()
oReport:SkipLine()
oReport:ThinLine()
oReport:SkipLine()
oReport:SkipLine()

//Texto do tipo de bordero
oReport:PrintText(SM0->M0_NOME + PadC(OemToAnsi("Autoriza็ใo Para Pagamento De Compromissos"),100) + OemToAnsi("Emissใo : ")+DtoC(dDataBase))
oReport:SkipLine()
oReport:SkipLine()


//Dados do Banco
oReport:PrintText(Pad(OemToAnsi("Ao "),100))
oReport:PrintText(Alltrim(Pad(SA6->A6_NOME,100)) + Iif(nOpca == 2," - Ag๊ncia: "+MV_PAR06,""))
oReport:SkipLine()
oReport:SkipLine()

If nOpca == 1
	oReport:PrintText(Pad(OemToAnsi("N๚mero : ") + MV_PAR11 ,100))
	oReport:SkipLine()
	oReport:PrintText("Solicitamos provid๊ncias de V.Sa., no sentido de que seja levada a d้bito da(s) conta(s) corrente(s) abaixo, da")
//	oReport:PrintText(Alltrim(SM0->M0_NOMECOM)+", nessa ag๊ncia, a quantia de "+Alltrim(Str(nValTot))+ " ("+Extenso(nValTot,.F.,1)+" )," )       
	oReport:PrintText(Alltrim(SM0->M0_NOMECOM)+", nessa ag๊ncia, a quantia de R$ "+Alltrim(Transform(nValTot,"@E 999,999,999.99"))+ " ("+Extenso(nValTot,.F.,1)+" )," )
	oReport:PrintText("em "+ dToc(mv_par10) + ", correspondente ao(s) pagamento(s) abaixo relacionado(s): " )
	oReport:SkipLine()
Endif

Return ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFr710Config บAutor  ณ Marcio Menon       บ Data ณ  01/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe ou oculta as colunas do relatorio, conforme o modelo   บฑฑ
ฑฑบ          ณ do bordero.			                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 	                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fr710Config(cAliasSea, oSection1,nOpca)

Do Case
	
	Case nOpca == 1
		oSection1:Cell("E2_VENCREA"    ):Disable()
		oSection1:Cell("BENEF"):SetTitle("Credor")
	Case nOpca == 2
		oSection1:Cell("E2_VENCREA"    ):Enable()
		oSection1:Cell("BENEF"):SetTitle("Nome")
EndCase

Return

/*    
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportTxtAutบAutor  ณ Marcio Menon       บ Data ณ  01/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime o Total Geral por extenso e as mensagens de	       บฑฑ
ฑฑบ          ณ autorizacao, conforme o modelo do bordero.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 	                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportTxtAut(oReport, nVlrSecao,cAliasSea,nValTot)
Local aArea := GetArea(cAliasSea)
Local nCount
Local cArqs := ""
Local cNomArq := ""

//cArqs := xArqs(cAliasSea)

oReport:SkipLine()
oReport:PrintText("Valor total do documento: R$ "+Alltrim(Transform(nValTot,"@E 999,999,999.99"))+" ("+Extenso(nValTot)+").")
oReport:SkipLine()  
oReport:SkipLine()

dbSelectArea(cAliasSea)
dbgotop()

While !Eof()
	               
	cNomArq := Alltrim((cAliasSea)->(EA_XFILE))
	cNomArq := SiFin11File(cNomArq)
  	If(!Alltrim(cNomArq) $ cArqs) .AND. (!Empty(Alltrim(cNomArq))) 
		cArqs += Alltrim(cNomArq)+", "
	Endif	
	
	dbSelectArea(cAliasSea)
	dbSkip()
	
EndDo

RestArea(aArea)

oReport:PrintText("Autoriza็ใo para libera็ใo de cr้ditos dos arquivos: "+Substr(cArqs,1,Len(cArqs)-2)+".")

For nCount := 1 to 5
	oReport:SkipLine()
Next
/*
oReport:PrintText("-----------------------------------",oReport:Row())
oReport:PrintText("-----------------------------------",,900)
oReport:PrintText("Coordenador Financeiro",oReport:Row())
oReport:PrintText("Diretor Financeiro",,900)
oReport:SkipLine()
*/
Return ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFR170Chk  บAutor  ณPedro Pereira Lima  บ Data ณ  14/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica quais titulos tem amarracao com o bordero e faz as บฑฑ
ฑฑบ          ณdevidas validacoes.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFINR710                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function FR710Chk(cAliasQuery)
Local aArea    := GetArea()
Local aAreaQry := (cAliasQuery)->(GetArea())
Local lRetorno := .T.

dbSelectArea("SE2")
SE2->(dbSetOrder(1))
SE2->(dbSeek(xFilial("SE2")+(cAliasQuery)->(EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_PARCELA)))

While !SE2->(Eof()) .And. xFilial("SE2")+(cAliasQuery)->(EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA) ==;
	SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
	lRetorno :=	(MV_PAR09 == 1 .Or. SE2->E2_MOEDA == 1)
	
	SE2->(dbSkip())
	
EndDo

RestArea(aAreaQry)
RestArea(aArea)

Return lRetorno

Static Function xTot(cAliasSea)

Local lAbatimento 	:= .F.
Local lCheque := .F.
Local lBaixa	:= .F.
Local nRet := 0
Local aArea := GetArea(cAliasSea)

dbSelectArea(cAliasSea)
dbgotop()

While !Eof()
	
	lBaixa := (Fr710BxVL(cAliasSea, IIf (Empty((cAliasSea)->EA_LOJA), "", (cAliasSea)->EA_LOJA)), If(!lBaixa, lBaixa := Fr710BxBA(cAliasSea), Nil ))
	lCheque := (!Empty(SE5->E5_NUMCHEQ) .And. SEF->(MsSeek(xFilial("SEF")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+SE5->E5_NUMCHEQ)))
	
	nRet += Fr710VPagar(cAliasSea, lBaixa, lCheque, lAbatimento)
	
	dbSelectArea(cAliasSea)
	dbSkip()
	
EndDo

RestArea(aArea)
Return nRet

Static Function xArqs(cAliasSea)

Local aArea := GetArea(cAliasSea)
Local cArqs := ""

dbSelectArea(cAliasSea)
dbgotop()

While !Eof()
	
	cArqs += Iif(!Alltrim((cAliasSea)->(EA_XFILE)) $ cArqs .AND. !Empty(Alltrim((cAliasSea)->(EA_XFILE))) ,Alltrim((cAliasSea)->(EA_XFILE))+", ","")
	
	dbSelectArea(cAliasSea)
	dbSkip()
	
EndDo

cArqs := Substr(cArqs,1,Len(cArqs)-2)+"."

RestArea(aArea)
Return cArqs                       

      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFIR11File  บAutor  ณAlcinei          บ Data ณ  06/14/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SiFin11File(cNomArq)
Local _cRet := ""           

For i := Len(AllTrim(cNomArq)) To 1 Step -1
	 If SubStr(AllTrim(cNomArq),i,1) == "\"
 		 _cRet := SubStr(AllTrim(cNomArq),i+1)
  		Exit
  	Endif
Next 
Return(_cRet)

  		