#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"      
#INCLUDE "report.ch" 

#define ANTES_LACO   	1
#define COND_LACO 		2
#define PROC_LACO 		3
#define DEPOIS_LACO 	4
#define PROC_FILTRO 	5
#define PROC_CARGO		6
#define BLOCK_FILTRO 	7

#define LIM_PERG 11
#define QUEB_INDEX 01
#define QUEB_LACO 02
#define QUEB_SEEK 03
#define QUEB_COND 04
#define QUEB_TITSUB 05
#define QUEB_FILTRO 06
#define COL_TIT 01
#define COL_IMPR 02
#define COL_TAM 03
#define COL_ORDEM 04
#define COL_ALIGN 05
#define COL_TRUNCA 06

// Release 4
#define TAM_CO			35		// Tamanho da celula conta orcamentaria
#define TAM_CC			30		// Tamanho da celula centro de custo
#define TAM_CLASSE		30		// Tamanho da celula classe
#define TAM_ITEM		30		// Tamanho da celula operacao
#define TAM_DATA		11		// Tamanho da celula Data


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ SIPCOR02 ณ AUTOR ณ Leonardo Soncin       ณ DATA ณ 23/08/2011 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Orcado x Realizado de Periodos                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO - CMI                                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SIPCOR02()

Local aArea	:= GetArea()
Local cPerg := "PCOR02"

Local nX	:= 1		// Contador generico

If FindFunction("TRepInUse") .And. TRepInUse()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInterface de impressao                                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oReport := ReportDef( cPerg )
	
	If !Empty(oReport:uParam)
		ValidPerg(cPerg)
		Pergunte(oReport:uParam,.F.)
	EndIf
	
	oReport:PrintDialog()
	
Else
	
	//Return U_PCOR02R3()
	MsgStop("Relat๓rio nใo desenvolvido para R3.")
	Return
	
EndIf

RestArea(aArea)

Return                                                                       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ ReportDef บ Autor ณ Gustavo Henrique   บ Data ณ  03/07/06  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Definicao do objeto do relatorio personalizavel e das      บฑฑ
ฑฑบ          ณ secoes que serao utilizadas.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Grupo de perguntas do relatorio                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Planejamento e Controle Orcamentario                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef( cPerg )

Local oReport
Local oMovOrdem1
Local oTot1
Local oTot2
Local oTot3
Local oTot4
Local oTot5
Local oTot6
Local oTot7
Local oTot8
Local oMovOrdem2
Local oMovOrdem3
Local oMovOrdem4
Local nX, aTotFunc 	:= {}
Local nTamCpo   	:= TamSx3("AKD_VALOR1")[1]
Local cReport 		:= "SIPCOR02" // Nome do relatorio
Local cAliasQry		:= GetNextAlias()

Local aOrdem		:= { "Conta Or็amentแria", "Centro de Custo", "Item Contแbil", "Classe de Valor" }

// Define blocos de codigo para impressao do codigo e descricao dos campos de quebra
Local bCO  			:= { || EntidadeCTB(AllTrim( PcoRetCo(cEntidade)),0,0,20,.F.,cMascara,"",,,,,.F.)}
Local bClasse		:= { || EntidadeCTB(AllTrim( cEntidade ),0,0,20,.F.,cMascCTH,"",,,,,.F.)}
Local bItem  		:= { || EntidadeCTB(AllTrim( cEntidade ),0,0,20,.F.,cMascCTD,"",,,,,.F.)}
Local bCC 			:= { || EntidadeCTB(AllTrim( cEntidade ),0,0,20,.F.,cMascCUS,"",,,,,.F.)}
Local bDesc  		:= { || Alltrim(cDescr) }

Local bVal1 		:= { || nValP }
Local bVal2 		:= { || nValC }
Local bVPerc2 		:= { || Abs(Round(((nValc/nValp)*100),2))}
Local bVVal2 		:= { || Round((nValp - nValc),2) }

Local bSum1 		:= { || Iif(cTipo=="1",0,nValP) }
Local bSum2 		:= { || Iif(cTipo=="1",0,nValC) }
Local bSum3 		:= { || Iif(cTipo=="1",0,Round((nValp - nValc),2)) }

Local cMascara 		:= GetMv("MV_MASCARA")
Local cMascCTD 		:= GetMv("MV_MASCCTD")
Local cMascCTH 		:= GetMv("MV_MASCCTH")
Local cMascCUS 		:= GetMv("MV_MASCCUS")

Private nValC 		:= 0
Private nValp 		:= 0
Private cEntidade 	:= ""
Private cTipo	 	:= ""
Private cDescr	 	:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriacao do componente de impressao                                      ณ
//ณ                                                                        ณ
//ณTReport():New                                                           ณ
//ณExpC1 : Nome do relatorio                                               ณ
//ณExpC2 : Titulo                                                          ณ
//ณExpC3 : Pergunte                                                        ณ
//ณExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ณ
//ณExpC5 : Descricao                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oReport := TReport():New( cReport, "Comparativo de Saldos ", cPerg, { |oReport| PCOR400Prt( oReport, cAliasQry, aOrdem, aTotFunc ) }, "Este relatorio ira imprimir a compara็ใo de saldos (Or็ado x Realizado) de acordo com os parโmetros solicitados pelo usuแrio." )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a 1a. secao do relatorio - C.O.                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oMovOrdem1 := TRSection():New( oReport, "Movimentos por " /*STR0025*/+":"+ "C.O.+Data" /*STR0018*/ , { cAliasQry, "AKD","AK1","AK5","AK6","AKF","AL2","CTT","CTD","CTH"} , aOrdem )
TRCell():New( oMovOrdem1, "AKD_CO"    , "AKD", "Conta Or็amentแria" /*STR0008*/, /*Picture*/, TAM_CO		, /*lPixel*/, bCO		) 	// Conta Orcamentaria
TRCell():New( oMovOrdem1, "AK5_DESCRI", "AK5", "Descri็ใo", /*Picture*/, /*Tamanho*/, /*lPixel*/, bDesc		) 	// Conta Orcamentaria
TRCell():New( oMovOrdem1, "AKD_VALOR1", "AKD", "Saldo (01)",         "@E 999,999,999,999.99"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVal1,"RIGHT",,"RIGHT" )	// Valor
TRCell():New( oMovOrdem1, "VALPER2"	  , ""	 , "Saldo (02)",         "@E 999,999,999,999.99"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVal2 ,"RIGHT",,"RIGHT")	// Valor
TRCell():New( oMovOrdem1, "PERVPER2"  , ""	 , "Var. em % (01/02)",  "@E 999,999,999.99%"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVPerc2,"RIGHT",,"RIGHT" )	// Valor
TRCell():New( oMovOrdem1, "VALVPER2"  , ""	 , "Var. em R$ (01-02)", "@E 999,999,999,999.99"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVVal2,"RIGHT",,"RIGHT" )	// Valor

aAdd(aTotFunc, oTot1:=TRFunction():New( oMovOrdem1:Cell("AKD_VALOR1"),/*cId*/, "SUM", ,/*cTitle*/,/*cPicture*/, bSum1/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )
aAdd(aTotFunc, oTot2:=TRFunction():New( oMovOrdem1:Cell("VALPER2"),/*cId*/, "SUM", ,/*cTitle*/,/*cPicture*/,bSum2/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem1:Cell("VALVPER2"),/*cId*/, "SUM", ,/*cTitle*/,/*cPicture*/, bSum3/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem1:Cell("PERVPER2"),/*cId*/, "ONPRINT", ,/*cTitle*/,/*cPicture*/, { || Abs(Round(((oTot2:GetValue()/oTot1:GetValue())*100),2))} /*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a 2a. secao do relatorio - Centro de Custo              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oMovOrdem2 := TRSection():New( oReport, "Movimentos por " /*STR0025*/+":"+"C.O.+Classe+Opera็ใo"/*STR0019*/, { cAliasQry, "AKD","AK1","AK5","AK6","AKF","AL2","CTT","CTD","CTH" } )
TRCell():New( oMovOrdem2, "AKD_CC"    	, "AKD", "Centro de Custo", /*Picture*/, TAM_CC		, /*lPixel*/, bCC    	)	// Centro de Custo
TRCell():New( oMovOrdem2, "CTT_DESC01"  , "CTT", "Descri็ใo", /*Picture*/, /*Tamanho*/, /*lPixel*/, bDesc		) // Centro de Custo
TRCell():New( oMovOrdem2, "AKD_VALOR1"	, "AKD", "Saldo (01)", "@E 999,999,999,999.99"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVal1,"RIGHT",,"RIGHT" )	// Valor
TRCell():New( oMovOrdem2, "VALPER2"	  	, ""   , "Saldo (02)", "@E 999,999,999,999.99"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVal2,"RIGHT",,"RIGHT" )	// Valor
TRCell():New( oMovOrdem2, "PERVPER2"  	, ""   , "Var. em % (01/02)", "@E 999,999,999.99%"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVPerc2,"RIGHT",,"RIGHT" )	// Valor
TRCell():New( oMovOrdem2, "VALVPER2"  	, ""   , "Var. em R$ (01-02)", "@E 999,999,999,999.99"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVVal2,"RIGHT",,"RIGHT" )	// Valor

aAdd(aTotFunc, oTot3:=TRFunction():New( oMovOrdem2:Cell("AKD_VALOR1"),/*cId*/, "SUM", ,/*cTitle*/,/*cPicture*/, bSum1/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )
aAdd(aTotFunc, oTot4:=TRFunction():New( oMovOrdem2:Cell("VALPER2"),/*cId*/, "SUM", ,/*cTitle*/,/*cPicture*/, bSum2/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem2:Cell("VALVPER2"),/*cId*/, "SUM", ,/*cTitle*/,/*cPicture*/, bSum3/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem2:Cell("PERVPER2"),/*cId*/, "ONPRINT", ,/*cTitle*/,/*cPicture*/,{ || Abs(Round(((oTot4:GetValue()/oTot3:GetValue())*100),2))}/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a 3a. secao do relatorio - Item Contabil                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oMovOrdem3 := TRSection():New( oReport, "Movimentos por " /*STR0025*/+":"+"C.O.+Classe+Opera็ใo"/*STR0019*/, { cAliasQry, "AKD","AK1","AK5","AK6","AKF","AL2","CTT","CTD","CTH" } )
TRCell():New( oMovOrdem3, "AKD_ITCTB"  	, "AKD", "Item Contแbil", /*Picture*/, TAM_ITEM		, /*lPixel*/, bItem 	)	// Item
TRCell():New( oMovOrdem3, "CTD_DESC01"  , "CTD", "Descri็ใo", /*Picture*/, /*Tamanho*/, /*lPixel*/, bDesc 	)	// Item
TRCell():New( oMovOrdem3, "AKD_VALOR1"	, "AKD", "Saldo (01)", "@E 999,999,999,999.99"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVal1,"RIGHT",,"RIGHT" )	// Valor
TRCell():New( oMovOrdem3, "VALPER2"	  	, ""   , "Saldo (02)", "@E 999,999,999,999.99"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVal2,"RIGHT",,"RIGHT" )	// Valor
TRCell():New( oMovOrdem3, "PERVPER2"  	, ""   , "Var. em % (01/02)", "@E 999,999,999.99%"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVPerc2,"RIGHT",,"RIGHT" )	// Valor
TRCell():New( oMovOrdem3, "VALVPER2"  	, ""   , "Var. em R$ (01-02)", "@E 999,999,999,999.99"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVVal2,"RIGHT",,"RIGHT" )	// Valor

aAdd(aTotFunc, oTot5:=TRFunction():New( oMovOrdem3:Cell("AKD_VALOR1"),/*cId*/, "SUM", ,/*cTitle*/,/*cPicture*/, bSum1/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )
aAdd(aTotFunc, oTot6:=TRFunction():New( oMovOrdem3:Cell("VALPER2"),/*cId*/, "SUM", ,/*cTitle*/,/*cPicture*/, bSum2/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem3:Cell("VALVPER2"),/*cId*/, "SUM", ,/*cTitle*/,/*cPicture*/, bSum3/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem3:Cell("PERVPER2"),/*cId*/, "ONPRINT", ,/*cTitle*/,/*cPicture*/,{ || Abs(Round(((oTot6:GetValue()/oTot5:GetValue())*100),2))}/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a 4a. secao do relatorio - Classe de Valor              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oMovOrdem4 := TRSection():New( oReport, "Movimentos por " /*STR0025*/+":"+"Classe+Opera็ใo" /*STR0020*/, { cAliasQry, "AKD","AK1","AK5","AK6","AKF","AL2","CTT","CTD","CTH" } )
TRCell():New( oMovOrdem4, "AKD_CLVLR"	, "AKD", "Classe de Valor", /*Picture*/, TAM_CLASSE, /*lPixel*/, bClasse	)	// Classe
TRCell():New( oMovOrdem4, "CTH_DESC01"	, "CTH", "Descri็ใo", /*Picture*/, /*Tamanho*/, /*lPixel*/, bDesc )	// Classe
TRCell():New( oMovOrdem4, "AKD_VALOR1"	, "AKD", "Saldo (01)", "@E 999,999,999,999.99"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVal1,"RIGHT",,"RIGHT" )	// Valor
TRCell():New( oMovOrdem4, "VALPER2"	  	, ""   , "Saldo (02)", "@E 999,999,999,999.99"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVal2,"RIGHT",,"RIGHT" )	// Valor
TRCell():New( oMovOrdem4, "PERVPER2"  	, ""   , "Var. em % (01/02)", "@E 999,999,999.99%"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVPerc2,"RIGHT",,"RIGHT" )	// Valor
TRCell():New( oMovOrdem4, "VALVPER2"  	, ""   , "Var. em R$ (01-02)", "@E 999,999,999,999.99"/*Picture*/, nTamCpo+2/*Tamanho*/, /*lPixel*/, bVVal2,"RIGHT",,"RIGHT" )	// Valor

aAdd(aTotFunc, oTot7:=TRFunction():New( oMovOrdem4:Cell("AKD_VALOR1")	,/*cId*/, "SUM", ,/*cTitle*/,/*cPicture*/, bSum1/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )
aAdd(aTotFunc, oTot8:=TRFunction():New( oMovOrdem4:Cell("VALPER2")		,/*cId*/, "SUM", ,/*cTitle*/,/*cPicture*/, bSum2/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem4:Cell("VALVPER2")	,/*cId*/, "SUM", ,/*cTitle*/,/*cPicture*/, bSum3/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem4:Cell("PERVPER2")	,/*cId*/, "ONPRINT", ,/*cTitle*/,/*cPicture*/,{ || Abs(Round(((oTot8:GetValue()/oTot7:GetValue())*100),2))}/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/) )

oReport:SetTotalInLine( .F. )		// Configura total geral para impressao em colunas
oReport:SetTotalText("TOTAIS DO PERอODO:")

For nX := 1 TO Len(aTotFunc)
	aTotFunc[nX]:disable()
Next

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PCOR400Prt บAutor ณ Gustavo Henrique  บ Data ณ  03/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Executa query de consulta na tabela de movimentos (AKD) e  บฑฑ
ฑฑบ          ณ imprime o objeto oReport definido na funcao ReportDef.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPO1 - Objeto tReport com a definicao das secoes e celulasบฑฑ
ฑฑบ          ณ para impressao do relatorio.                               บฑฑ
ฑฑบ          ณ EXPC2 - Alias da query do relatorio                        บฑฑ
ฑฑบ          ณ EXPA3 - Array com as ordens do relatorio                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Planejamento e Controle Orcamentario                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOR400Prt( oReport, cAliasQry, aOrdem, aTotFunc )

Local oSection1

Local nOrdem	:= oReport:Section(1):GetOrder()
Local cOrdem	:= ""
Local nX		:= 1					// Contador generico
Local nCont		:= 1					// Contador generico

Local aQuebras	:= {}					// Array com as condicoes de quebra do relatorio

Local cSqlExp	:= ""					// Expressao SQL de filtros do relatorio
Local cSqlSel	:= ""					// Expressao SQL de filtros do relatorio
Local cCO		:= ""					// Codigo da Conta orcamentaria
Local cClasse	:= ""					// Codigo da Classe
Local cItem		:= ""					// Codigo da Operaca
Local cCC		:= ""					// Codigo da Operacao
//Local dData		:= CToD( "  /  /  " )	// Data do lancamento
Local aEstrut 	:= {}
Local cNomeArq	:= ""
Private cAliasTRB := GetNextAlias()


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Estrutura do arquivo temporario ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd( aEstrut, { "ENTIDADE"		,"C", TamSx3("CT1_CONTA")[1], 0 } )
aAdd( aEstrut, { "DESCR"		,"C", 50, 0 } )
aAdd( aEstrut, { "AKD_VALOR1" 	,"N", TamSx3("AKD_VALOR1")[1], 2 } )
aAdd( aEstrut, { "AKD_VALOR2" 	,"N", TamSx3("AKD_VALOR1")[1], 2 } )
aAdd( aEstrut, { "TIPO"		 	,"C", 01, 0 } )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria o arquivo temporario ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cNomeArq := CriaTrab( aEstrut, .T. )
dbUseArea( .T.,,cNomeArq, cAliasTRB, .F., .F. )

IndRegua( cAliasTRB, cNomeArq, "ENTIDADE",,,"Criando Indice, aguarde..." )
dbClearIndex()
dbSetIndex( cNomeArq + OrdBagExt() )


MakeSqlExp( oReport:uParam )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta expressao de filtro da query com os parametros informados                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

cSqlExp += " AND AKD_DATA	BETWEEN '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02) + "'"
cSqlExp += " AND AKD_CO		BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'"
cSqlExp += " AND AKD_CC		BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"
cSqlExp += " AND AKD_ITCTB	BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "'"
cSqlExp += " AND AKD_CLVLR	BETWEEN '" + mv_par13 + "' AND '" + mv_par14 + "'"
cSqlExp += " AND AKD_CLASSE	BETWEEN '" + mv_par15 + "' AND '" + mv_par16 + "'"

If !Empty(mv_par05)
	cSqlExp += " AND AKD_TPSALD = '" + mv_par05 + "'"
Else
	Aviso("Aten็ใo" /*STR0023*/,"Tipo de Saldo nao Informado. Verifique."/*STR0026*/, {"Ok"})  //"Atencao"##"Tipo de Saldo nao Informado. Verifique."
	oReport:CancelPrint()
	Return
EndIf

//nao considera os lancamentos estornados
cSqlExp += " AND AKD_STATUS = '1' "

cSqlExp := "%" + cSqlExp + "%"


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria objetos de quebra e totalizacao de acordo com a ordem escolhida no relatorio      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOrdem == 1			// C.O.
	
	oSection1 := oReport:Section(nOrdem)
	
	AAdd( aQuebras, { { || cCO   <> (cAliasQry)->ENTIDADE   }, "AKD_CO"  , { || cCO   := (cAliasQry)->ENTIDADE   }, .F. } )
	aTotFunc[1]:Enable()
	aTotFunc[2]:Enable()
	aTotFunc[3]:Enable()
	aTotFunc[4]:Enable()
	
	cOrder 	:= "%" + " AKD_CO, AK5_DESCRI " + "%"
	cSqlSel := "%" + " Sum(AKD_VALOR1 * (CASE WHEN AKD_TIPO = '1' THEN 1 WHEN AKD_TIPO = '2' THEN -1 END)) AS AKD_VALOR1, AKD_CO AS ENTIDADE, AK5_DESCRI AS DESCR " + "%"
	cSqlJoin:= "%" + " LEFT OUTER JOIN "+RetSqlName("AK5")+" AK5 ON AK5.AK5_FILIAL = '"+xFilial("AK5")+"' AND AK5_CODIGO = AKD_CO	AND AK5.D_E_L_E_T_ = '' " + "%"
	cOrdem 	:= "Conta Or็amentแria"
	
ElseIf nOrdem == 2		// Centro de Custo
	
	oSection1 := oReport:Section(nOrdem)
	
	AAdd( aQuebras, { { || cCC   <> (cAliasQry)->ENTIDADE   }, "AKD_CC"  , { || cCC   := (cAliasQry)->ENTIDADE   }, .F. } )
	aTotFunc[5]:Enable()
	aTotFunc[6]:Enable()
	aTotFunc[7]:Enable()
	aTotFunc[8]:Enable()
	
	cOrder  := "%" + " AKD_CC, CTT_DESC01 " + "%"
	cSqlSel := "%" + " Sum(AKD_VALOR1 * (CASE WHEN AKD_TIPO = '1' THEN 1 WHEN AKD_TIPO = '2' THEN -1 END)) AS AKD_VALOR1, AKD_CC AS ENTIDADE, CTT_DESC01 AS DESCR " + "%"
	cSqlJoin:= "%" + " LEFT OUTER JOIN "+RetSqlName("CTT")+" CTT ON  CTT.CTT_FILIAL = '"+xFilial("CTT")+"'	AND CTT_CUSTO  = AKD_CC	AND CTT.D_E_L_E_T_ = '' " + "%"
	cOrdem 	:= CtbSayApro("CTT")
	
ElseIf nOrdem == 3		// Item Contabil
	
	oSection1 := oReport:Section(nOrdem)
	
	AAdd( aQuebras, { { || cItem   <> (cAliasQry)->ENTIDADE   }, "AKD_ITCTB"  , { || cItem   := (cAliasQry)->ENTIDADE   }, .F. } )
	aTotFunc[9]:Enable()
	aTotFunc[10]:Enable()
	aTotFunc[11]:Enable()
	aTotFunc[12]:Enable()
	
	cOrder  := "%" + " AKD_ITCTB, CTD_DESC01 " + "%"
	cSqlSel := "%" + " Sum(AKD_VALOR1 * (CASE WHEN AKD_TIPO = '1' THEN 1 WHEN AKD_TIPO = '2' THEN -1 END)) AS AKD_VALOR1, AKD_ITCTB AS ENTIDADE, CTD_DESC01 AS DESCR " + "%"
	cSqlJoin:= "%" + " LEFT OUTER JOIN "+RetSqlName("CTD")+" CTD ON  CTD.CTD_FILIAL = '"+xFilial("CTD")+"'	AND CTD_ITEM  = AKD_ITCTB	AND CTD.D_E_L_E_T_ = '' " + "%"
	cOrdem 	:= CtbSayApro("CTD")
	
ElseIf nOrdem == 4		// Classe de Valor
	
	oSection1 := oReport:Section(nOrdem)
	
	AAdd( aQuebras, { { || cClasse <> (cAliasQry)->ENTIDADE }, "AKD_CLVLR", { || cClasse := (cAliasQry)->ENTIDADE }, .F. } )
	aTotFunc[13]:Enable()
	aTotFunc[14]:Enable()
	aTotFunc[15]:Enable()
	aTotFunc[16]:Enable()
	
	cOrder  := "%" + " AKD_CLVLR, CTH_DESC01" + "%"
	cSqlSel := "%" + " Sum(AKD_VALOR1 * (CASE WHEN AKD_TIPO = '1' THEN 1 WHEN AKD_TIPO = '2' THEN -1 END)) AS AKD_VALOR1, AKD_CLVLR AS ENTIDADE, CTH_DESC01 AS DESCR " + "%"
	cSqlJoin:= "%" + " LEFT OUTER JOIN "+RetSqlName("CTH")+" CTH ON  CTH.CTH_FILIAL = '"+xFilial("CTH")+"' AND CTH_CLVL  = AKD_CLVLR	AND CTH.D_E_L_E_T_ = '' "  + "%"
	cOrdem 	:= CtbSayApro("CTH")
	
EndIf

oReport:SetTitle( oReport:Title() + " entre: "+DtoC(mv_par01)+" - "+DtoC(mv_par02)+" e "+DtoC(mv_par03)+" - "+DtoC(mv_par04)+" por - "+cOrdem)

nLenQuebra := Len( aQuebras )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta Query do relatorio para a secao 1                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1:BeginQuery()

BeginSql Alias cAliasQry
	
	SELECT
	%exp:cSqlSel%
	FROM
	%table:AKD% AKD
	
	%exp:cSqlJoin%
	
	WHERE
	AKD.AKD_FILIAL = %xfilial:AKD%
	AND AKD.%notDel%
	%exp:cSqlExp%
	GROUP BY %exp:cOrder%
	ORDER BY %exp:cOrder%
	
EndSql

oSection1:EndQuery()

oSection1:SetHeaderPage()			// Configura cabecalho para impressao no inicio de cada pagina

oReport:SetMeter( AKD->( RecCount() ) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicia impressao do relatorio                                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
(cAliasQry)->( dbGoTop() )



dbSelectArea(cAliasQry)

Do While (cAliasQry)->( ! EoF() )
	
	If nOrdem == 1 // Conta Orcamentaria
		dbSelectArea("AK5")
		dbSetOrder(1)
		dbSeek(xFilial("AK5")+(cAliasQry)->ENTIDADE )
		If MV_PAR17 == 1
			Pco_PopSup("AK5","AK5_FILIAL == xFilial()","AK5_CODIGO","AK5_COSUP"," ! Empty(AK5_COSUP)","AK5_FILIAL+AK5_CODIGO","AK5_TIPO == '2'",(cAliasQry)->AKD_VALOR1,0,(cAliasQry)->DESCR,"AK5_DESCRI")
		Else
			Pco_InsereTabela((cAliasQry)->ENTIDADE, "", (cAliasQry)->DESCR,(cAliasQry)->AKD_VALOR1,0,"",.T.)
		Endif
	Elseif nOrdem == 2
		dbSelectArea("CTT")
		dbSetOrder(1)
		dbSeek(xFilial("CTT")+(cAliasQry)->ENTIDADE )
		If MV_PAR17 == 1
			Pco_PopSup("CTT","CTT_FILIAL == xFilial()","CTT_CUSTO","CTT_CCSUP"," ! Empty(CTT_CCSUP)","CTT_FILIAL+CTT_CUSTO","CTT_CLASSE == '2' ",(cAliasQry)->AKD_VALOR1, 0,(cAliasQry)->DESCR,"CTT_DESC01" )
		Else
			Pco_InsereTabela((cAliasQry)->ENTIDADE, "", (cAliasQry)->DESCR, (cAliasQry)->AKD_VALOR1,0,"",.T.)
		Endif
	ElseIf nOrdem == 3
		dbSelectArea("CTD")
		dbSetOrder(1)
		dbSeek(xFilial("CTD")+(cAliasQry)->ENTIDADE )
		If MV_PAR17 == 1
			Pco_PopSup("CTD","CTD_FILIAL == xFilial()","CTD_ITEM","CTD_ITSUP"," ! Empty(CTD_ITSUP)","CTD_FILIAL+CTD_ITEM","CTD_CLASSE == '2' ",(cAliasQry)->AKD_VALOR1, 0,(cAliasQry)->DESCR,"CTD_DESC01" )
		Else
			Pco_InsereTabela((cAliasQry)->ENTIDADE, "", (cAliasQry)->DESCR, (cAliasQry)->AKD_VALOR1,0,"",.T.)
		Endif
	Else
		dbSelectArea("CTH")
		dbSetOrder(1)
		dbSeek(xFilial("CTH")+(cAliasQry)->ENTIDADE )
		If MV_PAR17 == 1
			Pco_PopSup("CTH","CTH_FILIAL == xFilial()","CTH_CLVL","CTH_CLSUP"," ! Empty(CTH_CLSUP)","CTH_FILIAL+CTH_CLVL","CTH_CLASSE == '2' ",(cAliasQry)->AKD_VALOR1, 0,(cAliasQry)->DESCR,"CTH_DESC01" )
		Else
			Pco_InsereTabela((cAliasQry)->ENTIDADE, "", (cAliasQry)->DESCR, (cAliasQry)->AKD_VALOR1,0,"",.T.)
		Endif
	Endif
	
	(cAliasQry)->( dbSkip() )
Enddo

// Busca Valores da Segunda Consulta
xGetSld(nOrdem)

// Imprimir do TRB
cAliasQry := cAliasTRB

If (cAliasQry)->( Eof() )
	
	Aviso( "Aten็ใo" /*STR0023*/, "Nใo existem dados para os parโmetros especificados." /*STR0024*/, {"Ok"} )	// "Aten็ใo" ### "Nใo existem dados para os parโmetros especificados."
	
	oReport:CancelPrint()
	
Endif

oSection1:Init()

dbSelectArea(cAliasQry)
dbGotop()

Do While (cAliasQry)->( ! EoF() ) .And. !oReport:Cancel()
	
	If oReport:Cancel()
		Exit
	EndIf
	
	oReport:IncMeter()
	
	cEntidade 	:= (cAliasQry)->ENTIDADE
	cDescr 		:= (cAliasQry)->DESCR
	nValP 		:= (cAliasQry)->AKD_VALOR1
	nValC 		:= (cAliasQry)->AKD_VALOR2
	cTipo 		:= (cAliasQry)->TIPO
	
	oSection1:Cell("AKD_VALOR1"):SetTitle("Saldo "+MV_PAR05)
	oSection1:Cell("VALPER2"):SetTitle("Saldo "+MV_PAR06)
	oSection1:Cell("PERVPER2"):SetTitle("Var. em % ("+MV_PAR06+"/"+MV_PAR05+")")
	oSection1:Cell("VALVPER2"):SetTitle("Var. em R$ ("+MV_PAR05+"-"+MV_PAR06+")")
	
	For nX := 1 To nLenQuebra
		If Eval( aQuebras[ nX, 1 ] ) .Or. ( nX > 1 .And. aQuebras[ nX-1, 4 ] )
			oSection1:Cell( aQuebras[ nX, 2 ] ):Show()
			Eval( aQuebras[ nX, 3 ] )
			aQuebras[ nX, 4 ] := .T.
		EndIf
	Next nX
	
	oSection1:PrintLine()
	
	For nX := 1 To nLenQuebra
		If aQuebras[ nX, 4 ]
			oSection1:Cell( aQuebras[ nX, 2 ] ):Hide()
			aQuebras[ nX, 4 ] := .F.
		EndIf
	Next nX
	
	(cAliasQry)->( dbSkip() )
	
EndDo

oSection1:Finish()


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Apaga o TRB	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea( cAliasTRB )
DbCloseArea()
FErase( cNomeArq + ".DBF" )
FErase( cNomeArq + OrdBagExt() )

Return ()

/*
------------------------------------------------------------- RELEASE 3 --------------------------------------------------------
*/



/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOR02R3 ณ AUTOR ณ Leonardo Soncin       ณ DATA ณ 22/08/2011 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa de impressao dos movimentos (tabela AKD)            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function PCOR02R3()
Local aArea		:= GetArea()
Local lOk		:= .F.
Local nX, cPerg := "PCOR02"
Private nLin	:= 200
Private cTitulo := "Comparativo saldo or็ado x realizado" //"Relacao dos Movimentos"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ habilita sempre as perguntas de ordem e linha de total ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//For nX := 12 To 16
//AjustaSXR4( PadR(cPerg, Len(SX1->X1_GRUPO)) + AllTrim( Str(nX) ), "C" )
//Next nX

oPrint := PcoPrtIni(cTitulo,.T.,2,,@lOk,"PCOR02")

If lOk
	RptStatus( {|lEnd| PCOR400Imp(@lEnd,oPrint)})
EndIf

PcoPrtEnd(oPrint)

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPCOR400Impณ Autor ณ Paulo Carnelossi      ณ Data ณ09/03/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de impressao dos movimentos (tabela AKD).            ณฑฑ
ฑฑณ          ณDefinicao do array com as quebras e com as colunas          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณPCOR400Imp(lEnd)                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ lEnd - Variavel para cancelamento da impressao pelo usuarioณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PCOR400Imp(lEnd,oPrint)
Local nX, lAlinDir := .T.

Private aColPos := {}
Private aQuebra, aColuna, nOrdem := 1 // MV_PAR12
Private aCondRel
Private aTitQueb
Private aValQueb, aImprTot

//acerta mv_par para nao dar conflito com base de dados
//porem sx1 deve ser acertado caso cliente modifique os tamanhos padroes
mv_par05 := PadR(mv_par05, Len(AKD->AKD_CO))
mv_par06 := PadR(mv_par06, Len(AKD->AKD_CO))
mv_par07 := PadR(mv_par07, Len(AKD->AKD_TPSALD))
mv_par08 := PadR(mv_par08, Len(AKD->AKD_TPSALD))

If Empty(mv_par07) .or. Empty(mv_par08)
	Aviso("Aten็ใo" /*STR0023*/,"Tipo de Saldo nao Informado. Verifique."/*STR0026*/, {"Ok"})//"Atencao"##"Tipo de Saldo nao Informado. Verifique."
	Return
EndIf

/*
If nOrdem == 0
Aviso(STR0023,STR0027, {"Ok"})//"Atencao"##"Ordem nao informada. Verifique!"
Return
EndIf
*/

//acerta titulo principal do relatorio
cTitCab := cTitulo
cTitCab += " - Perํodo de: " /*STR0009*/+DtoC(mv_par01)+" a " /*STR0010*/+DtoC(mv_par02) //" - Periodo de: "###" a "
//cTitCab += STR0002+mv_par09+" - " //"   - Tipo de Saldo: "
//cTitCab += Alltrim(Posicione("AL2", 1, xFilial("AL2")+mv_par09,"AL2_DESCRI"))

//DEFINICAO DAS QUEBRAS DO RELATORIO / INDICE / SEEK INICIAL

//1o. Elemento - Indice	da tabela AKD
//2o. Elemento - Array com CodeBlock das quebras
//3o. Elemento - dbSeek com sotseek para inicio
//4o. Elemento - Condicao Loop principal
//5o. Elemento - Array com titulos para Sub-total
//6o. Elemento - array Filtros para quebras
 
// edu
aQuebra := 	{;
{ 2, ;   // indice
{ {||AKD->AKD_CO}, {||DTOS(AKD->AKD_DATA)} }, ; //quebras
{||dbSeek(xFilial("AKD")+mv_par03, .T.) }, ;  //softseek inicio
{||AKD_CO <= mv_par04 }, ; //cond loop principal
{"* Total da Conta Or็amentแria *" /*STR0003*/, "* Total da Data *" /*STR0004*/}, ;  //titulo SubTotal //"* Total da Conta Orcamentaria *"###"* Total da Data *"
{R400MontaFiltro({3,4}), R400MontaFiltro({1,2})};  //filtros
},;
{ 6, ;
{ {||AKD->AKD_CO}, {||AKD->AKD_CLASSE}, {||AKD->AKD_OPER} }, ;
{||dbSeek(xFilial("AKD")+mv_par03, .T.)}, ;
{||AKD_CO <= mv_par04 }, ;
{"* Total da Conta Or็amentแria *" /*STR0003*/, "* Total da Classe *" /*STR0005*/, "* Total Opera็ใo *" /*STR0006*/}, ; //"* Total da Conta Orcamentaria *"###"* Total da Classe *"###"* Total Operacao *"
{R400MontaFiltro({3,4}), R400MontaFiltro({5,6}), R400MontaFiltro({7,8}) };
},;
{ 7, ;
{ {||AKD->AKD_CLASSE}, {||AKD->AKD_OPER} }, ;
{||dbSeek(xFilial("AKD")+mv_par05, .T.)}, ;
{||AKD_CLASSE <= mv_par06 }, ;
{"* Total da Classe Or็amentแria *" /*STR0007*/, "* Total Opera็ใo *" /*STR0006*/}, ; //"* Total da Classe Orcamentaria *"###"* Total Operacao *"
{R400MontaFiltro({5,6}), R400MontaFiltro({7,8})};
},;
{ 8, ;
{ {||AKD->AKD_OPER} } , ;
{||dbSeek(xFilial("AKD")+mv_par07, .T.)}, ;
{||AKD_OPER <= mv_par08 }, ;
{"* Total Opera็ใo *" /*STR0006*/}, ; //"* Total Operacao *"
{R400MontaFiltro({7,8})};
},;
{ 9, ;
{ {||DTOS(AKD->AKD_DATA)}, {||AKD->AKD_CO}, {||AKD->AKD_CLASSE}, {||AKD->AKD_OPER}  }, ;
{||dbSeek(xFilial("AKD")+DTOS(mv_par01), .T.)}, ;
{||DTOS(AKD_DATA) <= DTOS(mv_par02) }, ;
{"* Total da Data *" /*STR0004*/, "* Total da Conta Or็amentแria *" /*STR0003*/, "* Total da Classe Or็amentแria *" /*STR0007*/, "* Total Opera็ใo *" /*STR0006*/}, ; //"* Total da Data *"###"* Total da Conta Orcamentaria *"###"* Total da Classe Orcamentaria *"###"* Total Operacao *"
{R400MontaFiltro({1,2}), R400MontaFiltro({3,4}), R400MontaFiltro({5,6}), R400MontaFiltro({7,8})};
};
}


/// ess


//DEFINICAO DAS COLUNAS DO RELATORIO

//1o. Elemento - Titulo da Coluna
//2o. Elemento - CodeBlock para impressao da linha detalhe
//3o. Elemento - Tamanho da Coluna (impressao grafica)
//4o. Elemento - Array com posicao da coluna de acordo ordem do relatorio
aColuna := {;
{"Conta Or็amentแria" /*STR0008*/, ; //"Conta Orcamentaria"
{||PcoRetCo(AKD->AKD_CO)+"-"+PadR(Posicione("AK5", 1, xFilial("AK5")+AKD->AKD_CO, "AK5_DESCRI"), 40) },;
700, ;
{1, 1, 3, 2, 2 }, !lAlinDir, .F. },;
{"Dt.Movim." /*STR0011*/,; //"Dt.Movim."
{||DTOC(AKD->AKD_DATA)},;
180, ;
{2, 4, 4, 3, 1 }, !lAlinDir, .F. },;
{"Classe" /*STR0012*/,; //"Classe"
{||AKD->AKD_CLASSE+"-"+PadR(Posicione("AK6", 1, xFilial("AK6")+AKD->AKD_CLASSE,"AK6_DESCRI"),30)},;
600, ;
{3, 2, 1, 4, 3 }, !lAlinDir, .T. },;
{"Opera็ใo" /*STR0013*/,; //"Operacao"
{||AKD->AKD_OPER+"-"+PadR(Posicione("AKF", 1, xFilial("AKF")+AKD->AKD_OPER,"AKF_DESCRI"),30)},;
400, ;
{4, 3, 2, 1, 4 }, !lAlinDir, .T. },;
{"Hist๓rico" /*STR0014*/,; //"Historico"
{||AKD->AKD_HIST},;
700, ;
{5, 5, 5, 5, 5 }, !lAlinDir, .F. },;
{"Proc." /*STR0015*/,; //"Proc."
{||AKD->AKD_PROCES},;
180, ;
{6, 6, 6, 6, 6 }, !lAlinDir, .F. },;
{"Valor" /*STR0016*/,; //"Valor"
{|| Transform(AKD->AKD_VALOR1*IIf(AKD->AKD_TIPO=="1",1,-1), "@E 999,999,999.99")},;
400, ;
{7, 7, 7, 7, 7 }, lAlinDir, .F. };
}

//chamada da funcao de impressao do relatorio
R400DetRel(aQuebra, aColuna, cTitCab, nOrdem)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR400DetRel  บAutor  ณPaulo Carnelossi  บ Data ณ  15/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao do relatorio - monta as quebras e filtros e execu-บฑฑ
ฑฑบ          ณta funcao que imprimira o relatorio                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400DetRel(aQuebra, aColuna, cTitCab, nOrdem)
Local bProcto, bExecNotFilter, nCondRel
Local nX

dbSelectArea("AKD")
dbSetOrder(aQuebra[nOrdem][QUEB_INDEX])
Eval(aQuebra[nOrdem][QUEB_SEEK])

ASORT(aColuna,,, { |x, y| x[COL_ORDEM][nOrdem] < y[COL_ORDEM][nOrdem] })

//bloco de codigo para impressao do detalhe do relatorio
//nao pode esquecer dbskip -- senao sistema entra em loop
bProcto := {|nNivel|R400ImpDet(aColuna, cTitCab, nNivel),;
aValQueb[nNivel] += (AKD->AKD_VALOR1*IIf(AKD->AKD_TIPO=="1",1,-1)),;
AKD->(dbSkip())}

//bloco de codigo para execucao quando filtro nao satisfaz a condicao
//tradicionalmente e colocado if <condicao> -- dbskip -- loop -- endif
//funciona da mesma forma - nao pode esquecer dbskip -- senao sistema entra em loop
bExecNotFilter :=  {|nNivel| AKD->(dbSkip())}

//array que contera as quebras e blocos de codigos a ser executado em cada nivel
//para ser utilizado na funcao DetalheRel()
aCondRel := {}
nCondRel := Len(aQuebra[nOrdem][QUEB_LACO])

For nX := 1 TO nCondRel
	aAuxCond := {,,,,,,}
	If nX == 1   //no caso deste relatorio nivel 1 e definido aqui
		aAuxCond[ANTES_LACO] := {||Eval(aQuebra[nOrdem][QUEB_LACO][1])}
		aAuxCond[COND_LACO] := aQuebra[nOrdem][QUEB_COND]
		If nCondRel == nX  //quando ha somente um nivel o detalhe e no proprio nivel
			aAuxCond[PROC_LACO] := {|nNivel|R400ChkQuebra(nNivel, aColuna), R400TitQuebra(nNivel, aColuna), Eval(bProcto, nNivel)}
		Else
			aAuxCond[PROC_LACO] := {|nNivel|R400ChkQuebra(nNivel, aColuna), R400TitQuebra(nNivel, aColuna)}
		EndIf
		aAuxCond[DEPOIS_LACO] := {|nNivel|R400ImpSubTot(aQuebra[nOrdem][QUEB_TITSUB][nNivel], nNivel, aValQueb[nNivel], Len(aColuna))}
		aAuxCond[PROC_FILTRO] := aQuebra[nOrdem][QUEB_FILTRO][nX]
	Else
		//demais niveis monta a chave e a condicao do laco de cada nivel
		aAuxCond[ANTES_LACO] := R400Chave(aClone(aQuebra[nOrdem][QUEB_LACO]), nX)
		aAuxCond[COND_LACO] := R400CondLaco(aClone(aQuebra[nOrdem][QUEB_LACO]), nX)
		aAuxCond[PROC_LACO] := If(Len(aQuebra[nOrdem][QUEB_LACO])==nX, bProcto, {|nNivel|R400TitQuebra(nNivel, aColuna)})
		aAuxCond[DEPOIS_LACO] := {|nNivel|aValQueb[nNivel-1] += aValQueb[nNivel],R400ImpSubTot(aQuebra[nOrdem][QUEB_TITSUB][nNivel], nNivel, aValQueb[nNivel], Len(aColuna))}
		aAuxCond[PROC_FILTRO] := aQuebra[nOrdem][QUEB_FILTRO][nX]
	EndIf
	aAuxCond[PROC_CARGO] := ""
	aAuxCond[BLOCK_FILTRO] := bExecNotFilter
	aAdd(aCondRel, aClone(aAuxCond))
Next

//imprime o cabecalho
R400Cab(aColuna, aColPos, cTitCab)

//array para checkar se mudou a quebra e se imprime total de cada quebra
aTitQueb := {"","","",""}   //inicializado pois relatorio so tem 04 quebras no maximo
aValQueb := {0,0,0,0}   //inicializado pois relatorio so tem 04 quebras no maximo
aImprTot := {MV_PAR13==1,MV_PAR14==1,MV_PAR17==1,MV_PAR16==1}   //inicializado pois relatorio so tem 04 quebras no maximo

//imprime o relatorio  -- passado array aCondicao - nNivel Inicio - ALIAS
DetalheRel(aCondRel, 1, "AKD")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR400ImpDet  บAutor  ณPaulo Carnelossi  บ Data ณ  15/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao da linha detalhe do relatorio                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400ImpDet(aColuna, cTitCab, nNivel)
Local nX

If PcoPrtLim(nLin)
	nLin := 200
	R400Cab(aColuna, aColPos, cTitCab)
EndIf

//impressao da coluna na posicao nNivel
R400TitQuebra(nNivel, aColuna)

//impressao do detalhe  - sempre imprime nNivel + 1 por que nNivel foi impresso acima
For nX := nNivel+1 TO Len(aColuna)
	R400LinImpr(nX, aColuna)
Next

nLin+=60

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณR400LinImpr  บAutor  ณPaulo Carnelossi  บ Data ณ 15/03/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณImprime conteudo do array aColuna na posicao nCol           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400LinImpr(nCol, aColuna)
Local cSay 		:= Alltrim(Eval(aColuna[nCol][COL_IMPR]))
Local nTamCol 	:= PcoPrtTam(nCol)
Local nTamSay
Local lTrunca := aColuna[nCol][COL_TRUNCA]

If lTrunca
	nTamSay := PcoPrtSize(cSay,2/*nFonte*/)
	
	If nTamCol > 0 .And. nTamSay+3 > nTamCol
		While nTamSay > nTamCol
			cSay 	:= PadR(cSay, Len(cSay)-1)
			nTamSay := PcoPrtSize(cSay,2/*nFonte*/)
		End
		cSay += "..."
	EndIf
EndIf

PcoPrtCell(PcoPrtPos(nCol),nLin,nTamCol,60,cSay,oPrint,1,2,/*RgbColor*/,"",aColuna[nCol][COL_ALIGN])

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณR400TitQuebraบAutor  ณPaulo Carnelossi  บ Data ณ 15/03/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณImprime conteudo do array aColuna na posicao nNivel sempre  บฑฑ
ฑฑบ          ณ na entrada pois servira como titulo ate a proxima quebra   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400TitQuebra(nNivel, aColuna)
Local cChave := ""
Local aAux := aClone(aQuebra[nOrdem][QUEB_LACO])
AEVAL(aAux,;
{|cX, nX| cChave+=AKD->(Eval(aAux[nX], nX)) } ,  1,  nNivel)

If aTitQueb[nNivel] != cChave
	R400LinImpr(nNivel, aColuna)
	aTitQueb[nNivel] := cChave
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR400Cab   บAutor  ณPaulo Carnelossi    บ Data ณ  15/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime Cabecalho de acordo com array aColuna que contem as บฑฑ
ฑฑบ          ณdefinicoes das colunas a serem impressas                    บฑฑ
ฑฑบ          ณe array aColPos que contem as posicoes das colunas          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400Cab(aColuna, aColPos, cTitCab)
Local nColIni := 20
Local nX

PcoPrtCab(oPrint)

//se receber vazio popula de acordo com array acoluna
If Empty(aColPos)
	For nX := 1 TO Len(aColuna)
		aAdd(aColPos, nColIni)
		nColIni += aColuna[nX][COL_TAM]
	Next
EndIf

If cTitCab != NIL
	PcoPrtCol({20, 1000})
	PcoPrtCell(PcoPrtPos(2),nLin,,60,cTitCab,oPrint,5,3)
	nLin+=60
EndIf

PcoPrtCol(aColPos)
//impressao do cabecalho
For nX := 1 TO Len(aColuna)
	PcoPrtCell(PcoPrtPos(nX),nLin,PcoPrtTam(nX),60,aColuna[nX][COL_TIT],oPrint,4,2,/*RgbColor*/,)
Next
nLin+=60

Return(aColPos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณR400MontaFiltro บAutor ณPaulo Carnelossi บ Data ณ15/03/2005 บฑฑ
ฑฑฬออออออออออุออออออออออออออออสออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณMonta bloco de codigo que executara os code blocks de filtroบฑฑ
ฑฑบ          ณde acordo a parametrizacao do relatorio                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400MontaFiltro(aExc_MvPar)
Local aMvpar := {}, nPosCol
Local nX, cFiltro, bFilter
Local aExcMvPar := {}

DEFAULT aExc_MvPar := {}

For nX := 1 TO Len(aExc_MvPar)
	aAdd( aExcMvPar, "mv_par"+StrZero(aExc_MvPar[nX], 2) )
Next

For nX := 1 TO LIM_PERG
	aAdd( aMvPar, {"mv_par"+StrZero(nX,2), NIL, NIL})
Next

aMvPar[01][03] := "DTOS(AKD->AKD_DATA)"
aMvPar[02][03] := "DTOS(AKD->AKD_DATA)"
aMvPar[03][03] := "AKD->AKD_CO"
aMvPar[04][03] := "AKD->AKD_CO"
aMvPar[05][03] := "AKD->AKD_CLASSE"
aMvPar[06][03] := "AKD->AKD_CLASSE"
aMvPar[07][03] := "AKD->AKD_OPER"
aMvPar[08][03] := "AKD->AKD_OPER"
aMvPar[09][03] := "AKD->AKD_TPSALD"
aMvPar[10][03] := "AKD->AKD_PROCES"
aMvPar[11][03] := "AKD->AKD_PROCES"

aMvPar[01][02] := " >= "
aMvPar[02][02] := " <= "
aMvPar[03][02] := " >= "
aMvPar[04][02] := " <= "
aMvPar[05][02] := " >= "
aMvPar[06][02] := " <= "
aMvPar[07][02] := " >= "
aMvPar[08][02] := " <= "
aMvPar[09][02] := " == "
aMvPar[10][02] := " >= "
aMvPar[11][02] := " <= "


//agora monta a expressao

cFiltro := "{||"
cFiltro += "( "
For nX := 1 TO LIM_PERG
	If Empty(aExcMvPar) .OR. (nPosCol := aScan(aExcMvPar,{|x| AllTrim(lower(x))==AllTrim(lower(aMvPar[nX][1]))})) == 0
		xParam := aMvPar[nX][01]
		xParam := &xParam
		If Valtype(xParam) == "D"   //somente caracter e data
			xParam := DTOS(xParam)
		EndIf
		cFiltro += "PadR("+aMvPar[nX][03]+", Len("+aMvPar[nX][03] +"))"+aMvPar[nX][02]+"'"+xParam+"'"
		If nX < LIM_PERG
			cFiltro += " .And. "
		EndIf
	EndIf
Next
If Right(cFiltro,7)==" .And. "
	cFiltro := Subs(cFiltro, 1, Len(cFiltro)-7)
EndIf
//nao considera os lanctos estornados no relatorio
cFiltro += " .And. AKD->AKD_STATUS != '3' "
//fecha o bloco de codigo
cFiltro += " )"
cFiltro += " }"

//monta o bloco para filtro
bFilter := MontaBlock(cFiltro)

Return(bFilter)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR400Chave    บAutor  ณPaulo Carnelossi บ Data ณ 15/03/2005  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta bloco de codigo que executa os code blocks das quebrasบฑฑ
ฑฑบ          ณpara utilizacao na condicao do laco (While)                 บฑฑ
ฑฑบ          ณ**Nao utilizado os defines pois e montado via macro substit.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400Chave(aQuebra, nNivel)
Local bChave, cBlock, nX
cBlock := "{||"

For nX := 1 TO Len(aQuebra)
	If nX > nNivel
		Exit
	EndIf
	cBlock += "Eval(aQuebra[nOrdem][2]["+StrZero(nX,2)+"])+"
Next

If Right(cBlock, 1) == "+"
	cBlock := Subs(cBlock, 1, Len(cBlock)-1)+"}
EndIf

bChave := MontaBlock(cBlock)

Return bChave

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR400CondLaco บAutor  ณPaulo Carnelossi บ Data ณ 15/03/2005  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta bloco de codigo com condicao do laco (while......End) บฑฑ
ฑฑบ          ณpara os niveis abaixo do primeiro                           บฑฑ
ฑฑบ          ณ**Nao utilizado os defines pois e montado via macro substit.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400CondLaco(aQuebra, nNivel)
Local bCondic, cBlock, nX
cBlock := "{|nNivel|"

For nX := 1 TO Len(aQuebra)
	If nX > nNivel
		Exit
	EndIf
	cBlock += "Eval(aQuebra[nOrdem][2]["+StrZero(nX,2)+"])+"
Next

If Right(cBlock, 1) == "+"
	cBlock := Subs(cBlock, 1, Len(cBlock)-1)+"==aCondRel[nNivel][6]}"
EndIf

bCondic := MontaBlock(cBlock)

Return bCondic

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR400ImpSubTotบAutor  ณPaulo Carnelossi บ Data ณ 15/03/2005  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime subtotal apos a quebra no nivel respectivo          บฑฑ
ฑฑบ          ณde acordo com parametros imprime subtotal nivel 1...4       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400ImpSubTot(cTitle, nNivel, nxValor, nColImpr)

If aImprTot[nNivel]
	PcoPrtLine(PcoPrtPos(nNivel), nLin)
	PcoPrtCell(PcoPrtPos(nNivel),nLin,PcoPrtTam(nNivel),60,Alltrim(cTitle)+Space(3)+Replicate(">", nNivel),oPrint,1,2,/*RgbColor*/,"",.F.)
	PcoPrtCell(PcoPrtPos(nColImpr),nLin,PcoPrtTam(nColImpr),60, Transform(nxValor, "@E 99,999,999,999.99"),oPrint,1,2,/*RgbColor*/,"",.T.)
	nLin+=60
	
	If nNivel == 1
		PcoPrtLine(PcoPrtPos(nNivel), nLin)
	EndIf
EndIf

aValQueb[nNivel] := 0

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR400ChkQuebraบAutor  ณPaulo Carnelossi บ Data ณ 15/03/2005  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChecka se ha quebra no primeiro nivel e caso exista imprime บฑฑ
ฑฑบ          ณSubTotal                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400ChkQuebra(nNivel, aColuna)
Local cChave := ""
Local aAux

If nNivel == 1 .And. !Empty(aTitQueb[nNivel])  //para nao checkar na 1a. vez
	
	aAux := aClone(aQuebra[nOrdem][QUEB_LACO])
	
	AEVAL(aAux,;
	{|cX, nX| cChave+=AKD->(Eval(aAux[nX], nX)) } ,  1,  nNivel)
	
	If aTitQueb[nNivel] != cChave
		R400ImpSubTot(aQuebra[nOrdem][QUEB_TITSUB][nNivel], nNivel, aValQueb[nNivel], Len(aColuna))
	EndIf
	
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDetalheRel บAutor ณPaulo Carnelossi    บ Data ณ  15/03/2005 บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime detalhe do relatorio quando existir agrupamentos    บฑฑ
ฑฑบ          ณde acordo com aCondicao (array contendo blocos de codigos)  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DetalheRel(aCondicao, nNivel, cAlias)
AEVAL(aCondicao,;
{|cX, nX| (cAlias)->(Eval(aCondicao[nX][ANTES_LACO],nX)) } ,  1,  nNivel)

aCondicao[nNivel][PROC_CARGO] := Eval(aCondicao[nNivel][ANTES_LACO])

While (cAlias)->( ! Eof() .And. AvaliaCondicao(aCondicao, nNivel, cAlias) )
	
	If .Not. (cAlias)->(Eval(aCondicao[nNivel][PROC_FILTRO], nNivel))
		(cAlias)->(Eval(aCondicao[nNivel][BLOCK_FILTRO], nNivel))
	Else
		(cAlias)->(Eval(aCondicao[nNivel][PROC_LACO], nNivel))
		
		If nNivel < Len(aCondicao)  // avanca para proximo nivel
			DetalheRel(aCondicao, nNivel+1, cAlias)
		EndIf
	EndIf
	
End

(cAlias)->(Eval(aCondicao[nNivel][DEPOIS_LACO],nNivel))

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณAvaliaCondicaoบAutor ณPaulo Carnelossi    บ Data ณ 23/09/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณavalia condicao while (auxiliar a funcao DetalheRel()       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AvaliaCondicao(aCondicao, nNivel, cAlias)
Local aAux := {}, lCond := .T., lRet := .T., nY

AEVAL(aCondicao,;
{|cX, nX| aAdd(aAux,lCond:=(cAlias)->(Eval(aCondicao[nX][COND_LACO], nX))) } ,  1,  nNivel)

For nY := 1 TO Len(aAux)
	If ! aAux[nY]
		lRet := .F.
		Exit
	EndIf
Next

Return(lRet)


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
aAdd(aRegs,{cPerg,"01","Perํodo 01 de:  "				,"mv_ch1","D",08,0,0,"G","naovazio()","mv_par01","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Perํodo 01 at้: "				,"mv_ch2","D",08,0,0,"G","naovazio() .and. mv_par02>=mv_par01","mv_par02","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Perํodo 02 de:  "				,"mv_ch3","D",08,0,0,"G","naovazio() .and. mv_par03>=mv_par01","mv_par03","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Perํodo 02 at้: "				,"mv_ch4","D",08,0,0,"G","naovazio() .and. mv_par04>=mv_par03","mv_par04","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Saldo 01: "						,"mv_ch5","C",02,0,0,"G","ExistCpo('AL2').AND.NaoVazio()","mv_par05","","","","","","","","","","","","","","","AL2A",""})
aAdd(aRegs,{cPerg,"06","Saldo 02: "						,"mv_ch6","C",02,0,0,"G","ExistCpo('AL2').AND.NaoVazio()","mv_par06","","","","","","","","","","","","","","","AL2A",""})
aAdd(aRegs,{cPerg,"07","Conta or็amentแria de:"			,"mv_ch7","C",TamSX3("AK5_CODIGO")[1],0,0,"G","Vazio().or.ExistCpo('AK5')","mv_par07","","","","","","","","","","","","","","","AK5","013"})
aAdd(aRegs,{cPerg,"08","Conta or็amentแria at้:"		,"mv_ch8","C",TamSX3("AK5_CODIGO")[1],0,0,"G","ExistCpo('AK5').AND.NaoVazio()","mv_par08","","","","","","","","","","","","","","","AK5","013"})
aAdd(aRegs,{cPerg,"09","Centro de custo de:"			,"mv_ch9","C",TamSX3("CTT_CUSTO")[1],0,0,"G","Vazio().or.ExistCpo('CTT')","mv_par09","","","","","","","","","","","","","","","CTT","004"})
aAdd(aRegs,{cPerg,"10","Centro de custo at้:"			,"mv_chA","C",TamSX3("CTT_CUSTO")[1],0,0,"G","ExistCpo('CTT').AND.NaoVazio()","mv_par10","","","","","","","","","","","","","","","CTT","004"})
aAdd(aRegs,{cPerg,"11","Item contแbil de:"				,"mv_chB","C",TamSX3("CTD_ITEM")[1],0,0,"G","Vazio().or.ExistCpo('CTD')","mv_par11","","","","","","","","","","","","","","","CTD","005"})
aAdd(aRegs,{cPerg,"12","Item contแbil at้:"				,"mv_chC","C",TamSX3("CTD_ITEM")[1],0,0,"G","ExistCpo('CTD').AND.NaoVazio()","mv_par12","","","","","","","","","","","","","","","CTD","005"})
aAdd(aRegs,{cPerg,"13","Classe de valor de:"			,"mv_chD","C",TamSX3("CTH_CLVL")[1],0,0,"G","Vazio().or.ExistCpo('CTH')","mv_par13","","","","","","","","","","","","","","","CTH","006"})
aAdd(aRegs,{cPerg,"14","Classe de valor at้:"			,"mv_chE","C",TamSX3("CTH_CLVL")[1],0,0,"G","ExistCpo('CTH').AND.NaoVazio()","mv_par14","","","","","","","","","","","","","","","CTH","006"})
aAdd(aRegs,{cPerg,"15","Classe Or็amentแria de:"		,"mv_chF","C",06,0,0,"G","Vazio().or.ExistCpo('AK6')","mv_par15","","","","","","","","","","","","","","","AK6",""})
aAdd(aRegs,{cPerg,"16","Classe Or็amentแria ate:"		,"mv_chG","C",06,0,0,"G","Vazio().or.ExistCpo('AK6')","mv_par16","","","","","","","","","","","","","","","AK6",""})
aAdd(aRegs,{cPerg,"17","Imprime entidades?"				,"mv_chH","N",01,0,0,"C","","mv_par17","Todas","","","Analiticas","","","","","","","","","","","",""})

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
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณPco_AK5PopSup บAutor  ณPaulo Carnelossi  บ Data ณ 13/06/08  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que popula tabela temporaria no banco com conteudo   บฑฑ
ฑฑบ          ณCAMPOS - ANALITICA || SUPERIOR                              บฑฑ
ฑฑบ          ณPadrao para as entidades 	AK5 - Contas Orcamentarias      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA300                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pco_PopSup(cXAlias,cXWhile,cXAtual,cXSuperior,cXCondRec,cXLeftWhile,cXCond,nVal1,nVal2,cDescrA,cDescrS)
Local cAlias 		:= cXAlias
Local nOrdem 		:= 1
Local bSeek 		:= {|| dbSeek(xFilial()) }
Local bWhile        := {|| &cXWhile }
Local bAtual 		:= {|| &cXAtual }
Local bSuperior 	:= {|| &cXSuperior }
Local bCondRecursiv	:= {|| &cXCondRec }
Local bLeftWhile 	:= {|| &cXLeftWhile }
Local bExecute 		:= {| t,u,v,w,x,y,z| Pco_InsereTabela(t,u,v,w,x,y,z) }
Local bCond 		:= {|| &cXCond}
Local bDescrS 		:= {|| &cDescrS}

Pco_Superiores( cAlias, nOrdem, Eval(bAtual), Eval(bSuperior), bSuperior, bLeftWhile, bCondRecursiv, bExecute,nVal1,nVal2,cDescrA,bDescrS,.T.)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณPco_PrimSup  บAutor  ณPaulo Carnelossi   บ Data ณ 13/06/08  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que popula tabela temporaria no banco com conteudo   บฑฑ
ฑฑบ          ณCAMPOS - ANALITICA || SUPERIOR                              บฑฑ
ฑฑบ          ณPadrao para as entidades                                    บฑฑ
ฑฑบ          ณRecursiva para chegar ao topo da entidade superior          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA300                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pco_Superiores( cAlias, nOrdem, cAtual, cSuperior, bSuperior, bLeftWhile, bCondRecursiv, bExecute,nVal1,nVal2,cDescrA,bDescrS,lSup)
Local aArea := GetArea()

dbSelectArea(cAlias)
dbSetOrder(nOrdem)

If MsSeek(xFilial()+cSuperior)
	
	While (cAlias)->( ! Eof() .And. Eval(bLeftWhile) == xFilial()+cSuperior )
		
		Eval(bExecute, cAtual, cSuperior, cDescrA, nVal1, nVal2,Eval(bDescrS),lSup)
		
		If Eval(bCondRecursiv)
			lSup := .F.
			Pco_Superiores( cAlias, nOrdem, cAtual, Eval(bSuperior), bSuperior, bLeftWhile, bCondRecursiv, bExecute,nVal1,nVal2,cDescrA,bDescrS,lSup)
		Else
			Exit  //chegou ao topo
		EndIf
		
		dbSelectArea(cAlias)
		dbSkip()
		
	End
Else
	Pco_InsereTabela(cAtual,"", cDescrA,nVal1,nVal2,"",.T.) // aki
Endif

RestArea(aArea)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหออออออัอออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณPco_InsereTabela บAutor ณPaulo Carnelossi บ Data ณ 13/06/08 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสออออออฯอออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que popula tabela temporaria no banco com conteudo   บฑฑ
ฑฑบ          ณCAMPOS - ANALITICA || SUPERIOR                              บฑฑ
ฑฑบ          ณPadrao para as entidades                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA300                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pco_InsereTabela(cAtual, cSuperior, cDescrA, nVal1, nVal2,cDescrS,lSup)
Local aArea := GetArea()

dbSelectArea(cAliasTRB)
dbGotop()
dbSetOrder(1)

// desconsidera contas sem saldo zerado
IF nVal1+nVal2 == 0
	RestArea(aArea)
	Return()
ENDIF

If lSup
	If !dbSeek(cAtual)
		RecLock(cAliasTRB, .T.)
		(cAliasTRB)->ENTIDADE 	:= cAtual
		(cAliasTRB)->DESCR 		:= Iif(Empty(cDescrA),"LANวAMENTOS COM A ENTIDADE EM BRANCO",cDescrA)
		(cAliasTRB)->AKD_VALOR1 := nVal1
		(cAliasTRB)->AKD_VALOR2 := nVal2
		(cAliasTRB)->TIPO 		:= "2"
	Else
		RecLock(cAliasTRB, .F.)
		(cAliasTRB)->AKD_VALOR1 += nVal1
		(cAliasTRB)->AKD_VALOR2 += nVal2
	Endif
	lSup :=.F.
Endif

If !Empty(cSuperior)
	dbGotop()
	If dbSeek(cSuperior)
		RecLock(cAliasTRB, .F.)
		(cAliasTRB)->AKD_VALOR1 += nVal1
		(cAliasTRB)->AKD_VALOR2 += nVal2
	Else
		RecLock(cAliasTRB, .T.)
		(cAliasTRB)->ENTIDADE 	:= cSuperior
		(cAliasTRB)->DESCR 		:= cDescrS
		(cAliasTRB)->AKD_VALOR1 := nVal1
		(cAliasTRB)->AKD_VALOR2 := nVal2
		(cAliasTRB)->TIPO 		:= "1"
	Endif
Endif

MsUnLock()

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหออออออัอออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณPco_InsereTabela บAutor ณPaulo Carnelossi บ Data ณ 13/06/08 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสออออออฯอออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que popula tabela temporaria no banco com conteudo   บฑฑ
ฑฑบ          ณCAMPOS - ANALITICA || SUPERIOR                              บฑฑ
ฑฑบ          ณPadrao para as entidades                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA300                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function xGetSld(nOrdem)

Local cSqlExp2	:= ""					// Expressao SQL de filtros do relatorio
Local aArea 	:= GetArea()
Local cAliasTMP	:= GetNextAlias()

cSqlExp2 :=  "SELECT Sum(AKD_VALOR1 * (CASE WHEN AKD_TIPO = '1' THEN 1 WHEN AKD_TIPO = '2' THEN -1 END)) AS AKD_VALOR1 "

If nOrdem == 1
	cSqlExp2 += ", AKD_CO AS ENTIDADE "
ElseIf nOrdem == 2
	cSqlExp2 += ", AKD_CC AS ENTIDADE "
ElseIf nOrdem == 3
	cSqlExp2 += ", AKD_ITCTB AS ENTIDADE "
Else
	cSqlExp2 += ", AKD_CLVLR AS ENTIDADE "
Endif

cSqlExp2 +=  "FROM "+RetSqlName("AKD")
cSqlExp2 += " WHERE AKD_CO		BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'"
cSqlExp2 += " AND AKD_CC		BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'"
cSqlExp2 += " AND AKD_ITCTB		BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "'"
cSqlExp2 += " AND AKD_CLVLR		BETWEEN '" + mv_par13 + "' AND '" + mv_par14 + "'"
cSqlExp2 += " AND AKD_CLASSE	BETWEEN '" + mv_par15 + "' AND '" + mv_par16 + "'"
cSqlExp2 += " AND AKD_DATA		BETWEEN '" + DtoS(mv_par03) + "' AND '" + DtoS(mv_par04) + "'"
cSqlExp2 += " AND AKD_STATUS = '1' "
cSqlExp2 += " AND AKD_TPSALD = '"+MV_PAR06+"' "
cSqlExp2 += " AND AKD_FILIAL = '"+xFilial("AKD")+"' "
cSqlExp2 += " AND D_E_L_E_T_ = '' "

If nOrdem == 1
	cSqlExp2 += " GROUP BY AKD_CO "
	cSqlExp2 += " ORDER BY AKD_CO "
ElseIf nOrdem == 2
	cSqlExp2 += " GROUP BY AKD_CC "
	cSqlExp2 += " ORDER BY AKD_CC "
ElseIf nOrdem == 3
	cSqlExp2 += " GROUP BY AKD_ITCTB "
	cSqlExp2 += " ORDER BY AKD_ITCTB "
Else
	cSqlExp2 += " GROUP BY AKD_CLVLR "
	cSqlExp2 += " ORDER BY AKD_CLVLR "
Endif

cSqlExp2 := ChangeQuery(cSqlExp2)

If Select(cAliasTMP) > 0
	dbSelectArea(cAliasTMP)
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlExp2),cAliasTMP,.T.,.F.)

DbSelectArea(cAliasTMP)
DbGoTop()

dbGotop()
While !Eof(cAliasTMP)
	
	If nOrdem == 1 // Conta Orcamentaria
		dbSelectArea("AK5")
		dbSetOrder(1)
		dbSeek(xFilial("AK5")+(cAliasTMP)->ENTIDADE )
		If MV_PAR17 == 1
			Pco_PopSup("AK5","AK5_FILIAL == xFilial()","AK5_CODIGO","AK5_COSUP"," ! Empty(AK5_COSUP)","AK5_FILIAL+AK5_CODIGO","AK5_TIPO == '2'",0,(cAliasTMP)->AKD_VALOR1,AK5->AK5_DESCRI,"AK5_DESCRI")
		Else
			Pco_InsereTabela((cAliasTMP)->ENTIDADE, "", AK5->AK5_DESCRI,0,(cAliasTMP)->AKD_VALOR1,"",.T.)
		Endif
	Elseif nOrdem == 2
		dbSelectArea("CTT")
		dbSetOrder(1)
		dbSeek(xFilial("CTT")+(cAliasTMP)->ENTIDADE )
		If MV_PAR17 == 1
			Pco_PopSup("CTT","CTT_FILIAL == xFilial()","CTT_CUSTO","CTT_CCSUP"," ! Empty(CTT_CCSUP)","CTT_FILIAL+CTT_CUSTO","CTT_CLASSE == '2' ",0, (cAliasTMP)->AKD_VALOR1,CTT->CTT_DESC01,"CTT_DESC01" )
		Else
			Pco_InsereTabela((cAliasTMP)->ENTIDADE, "", CTT->CTT_DESC01,0,(cAliasTMP)->AKD_VALOR1,"",.T.)
		Endif
	ElseIf nOrdem == 3
		dbSelectArea("CTD")
		dbSetOrder(1)
		dbSeek(xFilial("CTD")+(cAliasTMP)->ENTIDADE )
		If MV_PAR17 == 1
			Pco_PopSup("CTD","CTD_FILIAL == xFilial()","CTD_ITEM","CTD_ITSUP"," ! Empty(CTD_ITSUP)","CTD_FILIAL+CTD_ITEM","CTD_CLASSE == '2' ",0, (cAliasTMP)->AKD_VALOR1,CTD->CTD_DESC01,"CTD_DESC01" )
		Else
			Pco_InsereTabela((cAliasTMP)->ENTIDADE, "", CTD->CTD_DESC01,0,(cAliasTMP)->AKD_VALOR1,"",.T.)
		Endif
	Else
		dbSelectArea("CTH")
		dbSetOrder(1)
		dbSeek(xFilial("CTH")+(cAliasTMP)->ENTIDADE )
		If MV_PAR17 == 1
			Pco_PopSup("CTH","CTH_FILIAL == xFilial()","CTH_CLVL","CTH_CLSUP"," ! Empty(CTH_CLSUP)","CTH_FILIAL+CTH_CLVL","CTH_CLASSE == '2' ",0,(cAliasTMP)->AKD_VALOR1,CTH->CTH_DESC01,"CTH_DESC01" )
		Else
			Pco_InsereTabela((cAliasTMP)->ENTIDADE, "", CTH->CTH_DESC01,0,(cAliasTMP)->AKD_VALOR1,"",.T.)
		Endif
	Endif
	
	dbSelectArea(cAliasTMP)
	dbSkip()
EndDo

RestArea(aArea)

Return()
