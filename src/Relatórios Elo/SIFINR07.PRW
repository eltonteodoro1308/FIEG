#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³ SIFINR07 º Autor ³ Wanderley Monteiro º Data ³  03/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para impressao do relatorio de                      º±±
±±º          ³ Regra de Comissão ( TREPORT )                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ C.N.I.                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SIFINR07()

Local cPerg := "SIFR07"
Private QRYSE1 := ""
Private QRYSE12 := ''

If FindFunction("TRepInUse") .And. TRepInUse()
	AjustaSX1(cPerg)
	
   // Variaveis utilizadas para parametros
//    MV_PAR01:= ctod('')  //Data de emissao De
//    MV_PAR02:= ctod('')  //Data de emissao Ate
//    MV_PAR03:= ctod('')  //Data de vencto real De
//    MV_PAR04:= ctod('')  //Data de vencto real Ate
    MV_PAR05:= space(06) //"C" , 6  Tipo de protesto De
    MV_PAR06:= space(06) //"C" , 6  Tipo de protesto Ate
//    MV_PAR07:= space(06) //"C" , 6  Cliente De
//    MV_PAR08:= space(06) //"C" , 6  Loja De
//    MV_PAR09:= space(06) //"C" , 6  Cliente Ate
//    MV_PAR10:= space(06) //"C" , 6  Loja Ate
//    MV_PAR11:= space(03) //"C" , 3  Prefixo De
//    MV_PAR12:= space(03) //"C" , 3  Prefixo Ate
//    MV_PAR13:= space(09) //"C" , 9  Titulo De
//    MV_PAR14:= space(09) //"C" , 9  Titulo Ate
//    MV_PAR15:= space(10) //"C" , 10 Natureza De
//    MV_PAR16:= space(10) //"C" , 10 Natureza Ate
//    MV_PAR17:= 1         //"N" , 1  Qual Moeda

	If Pergunte(cPerg , .T. )
		oReport := DefCell(cPerg)
		// Imprime relatorio
		oReport:PrintDialog()
	Endif
Else
	MsgBox("Esse relatório só pode ser emitido em TReport. Ative o parâmetro MV_TREPORT.")
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³ AjustaSX1º Autor ³ Wanderley Monteiro º Data ³  03/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ajusta as perguntas do SX1                                 º±±
±±º          ³ Regra de Comissão ( TREPORT )                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ C.N.I.                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1(cPerg)
Local aP := {}
Local i := 0
Local cSeq
Local cMvCh
Local cMvPar
Local aHelp := {}
Local aArea := GetArea()

/*
Característica do vetor p/ utilização da função SX1
---------------------------------------------------
[n,1] --> texto da pergunta
[n,2] --> tipo do dado
[n,3] --> tamanho
[n,4] --> decimal
[n,5] --> objeto G=get ou C=choice
[n,6] --> validacao
[n,7] --> F3
[n,8] --> definicao 1
[n,9] --> definicao 2
[n,10] -> definicao 3
[n,11] -> definicao 4
[n,12] -> definicao 5
*/

aAdd(aP,{"Data de emissao De"     , "D" , 8  , 0 , "G" , "" , ""    , ""       ,""        , ""      , "" , "" }) // MV_PAR01
aAdd(aP,{"Data de emissao Ate"    , "D" , 8  , 0 , "G" , "" , ""    , ""       ,""        , ""      , "" , "" }) // MV_PAR02
aAdd(aP,{"Data de vencto real De" , "D" , 8  , 0 , "G" , "" , "" 	  , ""       ,""        , ""      , "" , "" }) // MV_PAR03
aAdd(aP,{"Data de vencto real Ate", "D" , 8  , 0 , "G" , "" , ""    , ""       ,""        , ""      , "" , "" }) // MV_PAR04
aAdd(aP,{"Tipo de protesto De"    , "C" , 6  , 0 , "G" , "" , "P2"  , ""       ,""        , ""      , "" , "" }) // MV_PAR05
aAdd(aP,{"Tipo de protesto Ate"   , "C" , 6  , 0 , "G" , "" , "P2"  , ""       ,""        , ""      , "" , "" }) // MV_PAR06
aAdd(aP,{"Cliente De"             , "C" , 6  , 0 , "G" , "" , "SA1" , ""       ,""        , ""      , "" , "" }) // MV_PAR07
aAdd(aP,{"Loja De"                , "C" , 6  , 0 , "G" , "" , ""    , ""       ,""        , ""      , "" , "" }) // MV_PAR08
aAdd(aP,{"Cliente Ate"            , "C" , 6  , 0 , "G" , "" , "SA1" , ""       ,""        , ""      , "" , "" }) // MV_PAR09
aAdd(aP,{"Loja Ate"               , "C" , 6  , 0 , "G" , "" , ""    , ""       ,""        , ""      , "" , "" }) // MV_PAR10
aAdd(aP,{"Prefixo De"             , "C" , 3  , 0 , "G" , "" , ""    , ""       ,""        , ""      , "" , "" }) // MV_PAR11
aAdd(aP,{"Prefixo Ate"            , "C" , 3  , 0 , "G" , "" , ""    , ""       ,""        , ""      , "" , "" }) // MV_PAR12
aAdd(aP,{"Titulo De"              , "C" , 9  , 0 , "G" , "" , ""    , ""       ,""        , ""      , "" , "" }) // MV_PAR13
aAdd(aP,{"Titulo Ate"             , "C" , 9  , 0 , "G" , "" , ""    , ""       ,""        , ""      , "" , "" }) // MV_PAR14
aAdd(aP,{"Natureza De"            , "C" , 10 , 0 , "G" , "" , "SED" , ""       ,""        , ""      , "" , "" }) // MV_PAR15
aAdd(aP,{"Natureza Ate"           , "C" , 10 , 0 , "G" , "" , "SED" , ""       ,""        , ""      , "" , "" }) // MV_PAR16
aAdd(aP,{"Qual Moeda"             , "N" , 1  , 0 , "C" , "" , ""    , "Moeda 1","Moeda 2","Moeda 3","Moeda 4","Moeda 5" }) // MV_PAR17

//-----------------------------------------------

aAdd(aHelp,{"Informe a data de emissao inicial."})
aAdd(aHelp,{"Informe a data de emissao final."})
aAdd(aHelp,{"Informe o vencimento real inicial."})
aAdd(aHelp,{"Informe o vencimento real final."})
aAdd(aHelp,{"Informe o tipo de protesto inicial."})
aAdd(aHelp,{"Informe o tipo de protesto final."})
aAdd(aHelp,{"Informe o cliente inicial."})
aAdd(aHelp,{"Informe a loja inicial."})
aAdd(aHelp,{"Informe o cliente final."})
aAdd(aHelp,{"Informe a loja final."})
aAdd(aHelp,{"Informe o Prefixo inicial."})
aAdd(aHelp,{"Informe o Prefixo final."})
aAdd(aHelp,{"Informe o Titulo inicial."})
aAdd(aHelp,{"Informe o Titulo final."})
aAdd(aHelp,{"Informe a Natureza inicial."})
aAdd(aHelp,{"Informe a Natureza final."})
aAdd(aHelp,{"Informe a Moeda."})


For i := 1 To Len(aP)
	cSeq   := StrZero(i,2,0)
	cMvPar := "mv_par"+cSeq
	cMvCh  := "mv_ch"+IIF(i<=9,Chr(i+48),Chr(i+87))
	
	PutSx1(cPerg,;
	cSeq,;
	aP[i,1],aP[i,1],aP[i,1],;
	cMvCh,;
	aP[i,2],;
	aP[i,3],;
	aP[i,4],;
	0,;
	aP[i,5],;
	aP[i,6],;
	aP[i,7],;
	"",;
	"",;
	cMvPar,;
	aP[i,8],aP[i,8],aP[i,8],;
	"",;
	aP[i,9],aP[i,9],aP[i,9],;
	aP[i,10],aP[i,10],aP[i,10],;
	aP[i,11],aP[i,11],aP[i,11],;
	aP[i,12],aP[i,12],aP[i,12],;
	aHelp[i],;
	{},;
	{},;
	"")
	
Next i
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DefCell   ºAutor  ³Wanderley Monteiro  º Data ³  11/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que define as celular a serem exibidas no relatorio  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNI                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DefCell(cPerg)
Local oReport	:= NIL
Local oSection1	:= NIL
Local oSection2	:= NIL

Local cTitulo := "Reletorio de títulos a receber protestados por tipo de protestos"

Local cAlias1 	:= GetNextAlias()	// Sugestao da Lista	- Alias do Select para Secao 1 - Fornecedores
Local cAlias2 	:= GetNextAlias()	// Categoria			- Alias do Select para Secao 2 - Produtos

Local lPageBreak := .F.
Local aOrd := {}//Vetor com os tipos de ordenacao

//Define o Relatorio - TReport
oReport:=TReport():New("RelTitProt",cTitulo,cPerg,{|oReport| DefPrint(oReport,cPerg,cAlias1,cAlias2)},;
"Este relatório irá imprimir informações referentes aos titulos protestados classificados pelo tipo do protesto.")

oReport:SetLandscape()			// Escolhe o padrao de Impressao como Paisagem
oReport:nFontBody  := 9			// Tamanho da fonte inicial do Reltorio
oReport:nLineHeight:= 25		// Largura da Linha

oSection1:=TRSection():New( oReport,"Tipo Protesto",{"SX5"},,,,,,,,,,1 )
oSection1:PageBreak (lPageBreak)
oSection1:SetLineStyle()

TRCell():New(oSection1,"X5_CHAVE"	,"SX5","Cod Protesto "	,,06,,,,,,,,,,,.T.)
TRCell():New(oSection1,"X5_DESCRI"	,"SX5",""   			,,40,,,,,,,,,,,.T.)

oSection2 := TRSection():New(oSection1,"Títulos",{"SE1"},,,,,,,,,,3)
oSection2:SetLineStyle()

//TRCell():New(oSection2,"E1_PREFIXO"     ,"SE1" ,"",,LEN(("SE1")->(E1_PREFIXO)),,,,,,,,,,,)
//TRCell():New(oSection2,"E1_NUM"         ,"SE1" ,"",,LEN(("SE1")->(E1_NUM    )),,,,,,,,,,,)
//TRCell():New(oSection2,"E1_PARCELA"     ,"SE1" ,"",,LEN(("SE1")->(E1_PARCELA)),,,,,,,,,,,)
//TRCell():New(oSection2,"E1_CLIENTE"     ,"SE1" ,"",,LEN(("SE1")->(E1_CLIENTE)),,,,,,,,,,,)
//TRCell():New(oSection2,"E1_LOJA"        ,"SE1" ,"",,LEN(("SE1")->(E1_LOJA   )),,,,,,,,,,,)
//TRCell():New(oSection2,"A1_NOME"        ,"SA1" ,"",,LEN(("SA1")->(A1_NOME   )),,,,,,,,,,,)
//TRCell():New(oSection2,"E1_EMISSAO"     ,"SE1" ,"",,LEN(("SE1")->(E1_EMISSAO)),,,,,,,,,,,)
//TRCell():New(oSection2,"E1_VENCTO"      ,"SE1" ,"",,LEN(("SE1")->(E1_VENCTO )),,,,,,,,,,,)
//TRCell():New(oSection2,"E1_VENCREA"     ,"SE1" ,"",,LEN(("SE1")->(E1_VENCREA)),,,,,,,,,,,)
//TRCell():New(oSection2,"E1_VALOR"       ,"SE1" ,"",,LEN(("SE1")->(E1_VALOR  )),,,,,,,,,,,)
//TRCell():New(oSection2,"E1_SALDO"       ,"SE1" ,"",,LEN(("SE1")->(E1_SALDO  )),,,,,,,,,,,)
//TRCell():New(oSection2,"E1_NATUREZ"      ,"SE1" ,"",,LEN(("SE1")->(E1_NATUREZ)),,,,,,,,,,,)
                                                       
TRCell():New(oSection2,"E1_PREFIXO"     ,"SE1" ,"",,,,,,,,,,,,,)
TRCell():New(oSection2,"E1_NUM"         ,"SE1" ,"",,,,,,,,,,,,,)
TRCell():New(oSection2,"E1_PARCELA"     ,"SE1" ,"",,,,,,,,,,,,,)
TRCell():New(oSection2,"E1_CLIENTE"     ,"SE1" ,"",,,,,,,,,,,,,)
TRCell():New(oSection2,"E1_LOJA"        ,"SE1" ,"",,,,,,,,,,,,,)
TRCell():New(oSection2,"A1_NOME"        ,"SA1" ,"",,12,,,,,,,,,,,)
TRCell():New(oSection2,"E1_EMISSAO"     ,"SE1" ,"",,,,,,,,,,,,,)
TRCell():New(oSection2,"E1_VENCTO"      ,"SE1" ,"",,,,,,,,,,,,,)
TRCell():New(oSection2,"E1_VENCREA"     ,"SE1" ,"",,,,,,,,,,,,,)
TRCell():New(oSection2,"E1_VALOR"       ,"SE1" ,"",,15,,,,,,,,,,,)
TRCell():New(oSection2,"E1_SALDO"       ,"SE1" ,"",,15,,,,,,,,,,,)
TRCell():New(oSection2,"E1_NATUREZ"     ,"SE1" ,"",,10,,,,,,,,,,,)

Return( oReport )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DefPrint  ºAutor  ³Wanderley Monteiro  º Data ³  11/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel por imprimir o relatorio                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNI                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                             
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DefPrint(oReport,cPerg,cAlias1,cAlias2)
Local oSection1	:= oReport:Section(1)               // Secao do Fornecedor
Local oSection2	:= oReport:Section(1):Section(1)		/// Secao dos Produtos
Local lFooter  	:= .T.
Local nRow												// Variavel para pular a pagina na quebra da secao 1
Local cOrder 	:= ""

Local cAntTPrt	:= " "
Local cAntNTit  := " "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query com os resultados a serem exibidos³
//³na Secao 1                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN REPORT QUERY oSection1
		BeginSQL alias cAlias1

			SELECT DISTINCT X5_CHAVE, X5_DESCRI
			FROM 	%Table:SX5% SX5
			WHERE X5_TABELA = 'P2' AND
    			   X5_CHAVE	BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%

			ORDER BY SX5.X5_CHAVE

		EndSQL

	END REPORT QUERY oSection1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query com os resultados a serem exibidos³
//³na Secao 2                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BEGIN REPORT QUERY oSection2
		BeginSQL alias cAlias2

			Column DTEMIS 	AS date

         SELECT SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_CLIENTE, SE1.E1_LOJA, SA1.A1_NOME,
                SE1.E1_EMISSAO, SE1.E1_VENCTO, SE1.E1_VENCREA, SE1.E1_MOEDA, SE1.E1_VALOR, SE1.E1_SALDO, SE1.E1_NATUREZ, 
                SE1.E1_XCODPRT, SE1.E1_XDESCPR
         FROM 	%Table:SE1% SE1, %Table:SA1% SA1

			WHERE SE1.E1_FILIAL	= %xFILIAL:SE1%                           AND
               SE1.E1_CLIENTE	= SA1.A1_COD 		                      AND
               SE1.E1_LOJA      = SA1.A1_LOJA                             AND
			      SE1.E1_MOEDA  	= %Exp:mv_par17% 	                  AND
               SE1.E1_XCODPRT	= %report_param:(cAlias1)->X5_CHAVE%	  AND
               SE1.E1_EMISSAO	BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
 			      SE1.E1_VENCREA	BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND
			      SE1.E1_CLIENTE   BETWEEN %Exp:mv_par07% AND %Exp:mv_par09% AND
			      SE1.E1_LOJA      BETWEEN %Exp:mv_par08% AND %Exp:mv_par10% AND
			      SE1.E1_PREFIXO	BETWEEN %Exp:mv_par11% AND %Exp:mv_par12% AND
			      SE1.E1_NUM		BETWEEN %Exp:mv_par13% AND %Exp:mv_par14% AND
			      SE1.E1_NATUREZ	BETWEEN %Exp:mv_par15% AND %Exp:mv_par16% AND
			      
			      (SE1.E1_SALDO<>SE1.E1_VALOR OR SE1.E1_BAIXA = '          ') AND 
			      
			      SE1.%NotDel%

			ORDER BY SE1.E1_EMISSAO, SE1.E1_NUM

	EndSQL
END REPORT QUERY oSection2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Loop de impressao das linhas do relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !oReport:Cancel() .AND. (cAlias1)->(!Eof())   //Regra de impressao
	oSection1:Init()
	/// Executa a query da secao 2
	oSection2:ExecSql()

	If  !(cAlias2)->(Eof()) //imprime cabecalho (Secao 1)
		oSection1:PrintLine()

		//IMPRESSAO SECAO 2
		nRow := oReport:Row()//LINHA ATUAL

      oReport:PrintText('      PRFX'           ,nRow,oSection2:Cell("E1_PREFIXO" ):ColPos()   )
      oReport:PrintText('      NRO TIT'        ,nRow,oSection2:Cell("E1_NUM"     ):ColPos()   )
      oReport:PrintText('      PARC'            ,nRow,oSection2:Cell("E1_PARCELA" ):ColPos()   )
      oReport:PrintText('      CODIGO'         ,nRow,oSection2:Cell("E1_CLIENTE" ):ColPos()   )
      oReport:PrintText('     LOJA'           ,nRow,oSection2:Cell("E1_LOJA"    ):ColPos()   )
      oReport:PrintText('     NOME CLIENTE'   ,nRow,oSection2:Cell("A1_NOME"    ):ColPos()   )
      oReport:PrintText('     DT EMISS'        ,nRow,oSection2:Cell("E1_EMISSAO" ):ColPos()   )
      oReport:PrintText('     DT VENC'         ,nRow,oSection2:Cell("E1_VENCTO"  ):ColPos()   )
      oReport:PrintText('     D VNC REAL'      ,nRow,oSection2:Cell("E1_VENCREA" ):ColPos()   )
      oReport:PrintText('           VL ORIG'   ,nRow,oSection2:Cell("E1_VALOR"   ):ColPos()   )
      oReport:PrintText('               SALDO' ,nRow,oSection2:Cell("E1_SALDO"   ):ColPos()   )
      oReport:PrintText('    NATUR'            ,nRow,oSection2:Cell("E1_NATUREZ"  ):ColPos()   )


		oReport:SkipLine()

		While !oReport:Cancel() .And. !(cAlias2)->(Eof())

   			If !(cAntTPrt == (cAlias2)->E1_XCODPRT .And. cAntNTit == (cAlias2)->E1_NUM)

	   			cAntTPrt := (cAlias2)->E1_XCODPRT
		   		cAntNTit := (cAlias2)->E1_NUM

				oSection2:Init()
				oSection2:PrintLine()

			EndIf

			(cAlias2)->(DbSkip())
		End


		oReport:SkipLine()//Pula uma linha
		oReport:FatLine() //Desenha uma Linha

	EndIf
     oSection2:Finish()
	(cAlias1)->(DbSkip())
End
oSection1:Finish()
Return
