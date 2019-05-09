#INCLUDE "protheus.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SIPCOA16 บ Autor ณ Leonardo Soncin    บ Data ณ  17/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Importacao de Planilha CSV de or็amento.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function SIPCOA16()
Local oWizard
Local cArquivo
Local aAreaAK1 := AK1->(GetArea())
Local aAreaAK2 := AK2->(GetArea())
Local aAreaAK3 := AK3->(GetArea())
Local aAreaAKE := AKE->(GetArea())
Local lRet 		:= .F.
Local lParam, lBrowse:=.T.
Local aParametros := {			{ 1 ,"Filial"					,Space(LEN(AK1->AK1_FILIAL))		,"@!" 	 ,""  ,"" 	 ,".F." ,15 ,.T. },;
{ 1 ,"Planilha or็amentแria"	,Replicate(" ",LEN(AK1->AK1_CODIGO)),"@!" 	 ,""  ,"AK1" ,".F." ,65 ,.T. },;
{ 1 ,"Revisใo"					,Replicate(" ",LEN(AKE->AKE_REVISA)),"@!" 	 ,""  ,"AKE1",".F." ,65 ,.T. },;
{ 1 ,"Conta orcamentแria de"	,Replicate(" ",LEN(AK2->AK2_CO)) 	,"@!" 	 ,""  ,"AK5" ,"" ,65 ,.F. },;
{ 1 ,"Conta orcamentแria at้"	,Replicate(" ",LEN(AK2->AK2_CO)) 	,"@!" 	 ,""  ,"AK5" ,"" ,65 ,.T. },;
{ 1 ,"Centro de custo de"		,Replicate(" ",LEN(AK2->AK2_CC)) 	,"@!" 	 ,""  ,"CTT" ,"" ,65 ,.F. },;
{ 1 ,"Centro de custo at้"		,Replicate(" ",LEN(AK2->AK2_CC)) 	,"@!" 	 ,""  ,"CTT" ,"" ,65 ,.T. },;
{ 1 ,"Item contแbil de"			,Replicate(" ",LEN(AK2->AK2_ITCTB)) ,"@!" 	 ,""  ,"CTD" ,"" ,65 ,.F. },;
{ 1 ,"Item contแbil at้"		,Replicate(" ",LEN(AK2->AK2_ITCTB)) ,"@!" 	 ,""  ,"CTD" ,"" ,65 ,.T. },;
{ 1 ,"Classe de valor de"		,Replicate(" ",LEN(AK2->AK2_CLVLR)) ,"@!" 	 ,""  ,"CTH" ,"" ,65 ,.F. },;
{ 1 ,"Classe de valor at้"		,Replicate(" ",LEN(AK2->AK2_CLVLR)) ,"@!" 	 ,""  ,"CTH" ,"" ,65 ,.T. },;
{ 2 ,"Apagar itens da planilha"	,1 ,{"1=Nใo apagar itens da planilha","2=Sim. Apagar itens na faixa informada"} ,100, "", .T.},;
{ 6	,"Arquivo"					,Space(60),"",,"",90 ,.T.,"",'',GETF_LOCALHARD+GETF_LOCALFLOPPY}}

Local aConfig := {AK1->AK1_FILIAL,AK1->AK1_CODIGO,IF(Empty(AK1->AK1_VERREV), AK1->AK1_VERSAO, AK1->AK1_VERREV),Replicate(" ",LEN(AK2->AK2_CO)),Replicate("Z",LEN(AK2->AK2_CO)),Replicate(" ",LEN(AK2->AK2_CC)),Replicate("Z",LEN(AK2->AK2_CC)),Replicate(" ",LEN(AK2->AK2_ITCTB)),Replicate("Z",LEN(AK2->AK2_ITCTB)),Replicate(" ",LEN(AK2->AK2_CLVLR)),Replicate("Z",LEN(AK2->AK2_CLVLR)),"1",""}
Local aPerAux  := {}
PRIVATE aAuxCps
PRIVATE cRevisa
PRIVATE cPlanAnt := ""
PRIVATE cCtaOrc := ""
Private cPlanOri 	:= AK1->AK1_CODIGO
Private cRevOri 	:= IF(Empty(AK1->AK1_VERREV), AK1->AK1_VERSAO, AK1->AK1_VERREV)
Private cCtaOri 	:= AK3->AK3_CO
Private aPeriodo 	:= PcoRetPer()

dbSelectArea("AK3")
dbSeek(xFilial("AK3")+cPlanOri+cRevOri+cPlanOri)

If AK1->(FieldPos("AK1_XAPROV"))>0
	If AK1->AK1_XAPROV <> "0"
		MsgStop("A planilha or็amentแria deve estar com a situa็ใo igual a '0 - Em aberto' para que possa importar dados. Verifique!","Aten็ใo")
		
		RestArea(aAreaAK1)
		RestArea(aAreaAK2)
		RestArea(aAreaAK3)
		RestArea(aAreaAKE)
		
		Return
	Endif
Endif

oWizard := APWizard():New("Aten็ใo"/*<chTitle>*/,;
"Este assistente lhe ajudara a importar os dados de um arquivo CSV para uma planilha or็amentแria."/*<chMsg>*/, "Importa็ใo para Planilha Or็amentแria"/*<cTitle>*/, ;
"Voc๊ deverแ indicar os parโmetros e ao finalizar o assistente, os dados serใo importados conforme os parโmetros solicitados."/*<cText>*/,;
{||.T.}/*<bNext>*/, ;
{||.T.}/*<bFinish>*/,;
/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

oWizard:NewPanel( "Parโmetros"/*<chTitle>*/,;
"Neste passo voc๊ deverแ informar os parโmetros para importa็ใo da planilha or็amentแria."/*<chMsg>*/, ;
{||.T.}/*<bBack>*/, ;
{||.T.}/*<bNext>*/, ;
{|| Rest_Par(aConfig),Iif(ParamOk(aParametros, aConfig), lRet := xProc(aConfig, cCtaOrc, cPlanOri, cRevOri, cPlanOri, aPeriodo, aPerAux), lRet := .F.) }/*<bFinish>*/,;
.T./*<.lPanel.>*/,;
{||Plan_Box(oWizard,@lParam, aParametros, aConfig)}/*<bExecute>*/ )

oWizard:Activate( .T./*<.lCenter.>*/,;
{||.T.}/*<bValid>*/, ;
{||.T.}/*<bInit>*/, ;
{||.T.}/*<bWhen>*/ )


RestArea(aAreaAK1)
RestArea(aAreaAK2)
RestArea(aAreaAK3)
RestArea(aAreaAKE)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA   Plan_Box บAutor  ณPaulo Carnelossi  บ Data ณ 16/05/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para escolha da planilha a ser copiada               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Plan_Box(oWizard, lParam, aParametros, aConfig)
LOCAL cLoad		:= ""						// Nome do arquivo aonde as respostas do usuแrio serใo salvas / lidas
LOCAL lCanSave	:= .T.						// Se as respostas para as perguntas podem ser salvas
LOCAL lUserSave := .T.						// Se o usuแrio pode salvar sua propria configuracao

If lParam == NIL
	ParamBox(aParametros ,"Parametros", @aConfig,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel], cLoad, lCanSave, lUserSave)
	lParam := .T.
Else
	Rest_Par(aConfig)
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ Rest_Par   บAutor  ณPaulo Carnelossi   บ Data ณ 16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para restauracao dos conteudos das variaveis MV_PAR  บฑฑ
ฑฑบ          ณna navegacao entre os paineis do assistente de copia        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Rest_Par(aParam)
Local nX
Local cVarMem

For nX := 1 TO Len(aParam)
	cVarMem := "MV_PAR"+AllTrim(STRZERO(nX,2,0))
	&(cVarMem) := aParam[nX]
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ Fim_Wiz    บAutor  ณPaulo Carnelossi   บ Data ณ 16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para execucao das rotinas de copias quando pressionarบฑฑ
ฑฑบ          ณo botao Finalizar do assistente de copia                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fim_Wiz(aConfig, cCtaOrc, cPlanOri, cRevOri, aPeriodo, aPerAux,lEnd,oProcess)
Local lRet 		:= .T.
Local cAliasTmp	:= GetNextAlias()
Local aEstrut	:= {}
Local aCampos	:= {}
Local aCposPer	:= {}
Local cCposPer	:= ""
Local aTxt	:= {}
Local _nValor := 0
Local aPosCampos:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Estrutura do arquivo temporario ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd( aEstrut, { "LINHA"		,"C", 5, 0 } )
aAdd( aEstrut, { "AK2_FILIAL"	,"C", TamSx3("AK2_FILIAL")[1], 0 } )
aAdd( aEstrut, { "AK2_ID"		,"C", TamSx3("AK2_ID")[1], 0 } )
aAdd( aEstrut, { "AK2_ORCAME"	,"C", TamSx3("AK2_ORCAME")[1], 0 } )
aAdd( aEstrut, { "AK2_VERSAO"	,"C", TamSx3("AK2_VERSAO")[1], 0 } )
aAdd( aEstrut, { "AK2_CO"		,"C", TamSx3("AK2_CO")[1], 0 } )
aAdd( aEstrut, { "AK2_CC"		,"C", TamSx3("AK2_CC")[1], 0 } )
aAdd( aEstrut, { "AK2_ITCTB"	,"C", TamSx3("AK2_ITCTB")[1], 0 } )
aAdd( aEstrut, { "AK2_CLVLR"	,"C", TamSx3("AK2_CLVLR")[1], 0 } )
aAdd( aEstrut, { "AK2_CLASSE"	,"C", TamSx3("AK2_CLASSE")[1], 0 } )
aAdd( aEstrut, { "AK2_OPER"		,"C", TamSx3("AK2_OPER")[1], 0 } )

// Campos de Acordo com o Periodo
For nX := 1 to Len(aPeriodo)
	aAdd( aEstrut, { "P"+StrTran(Substr(aPeriodo[nX],1,10),"/","") 	,"N", TamSx3("AK2_VALOR")[1], 2 } )
	aAdd( aCposPer, Substr(aPeriodo[nX],1,10) )
	cCposPer += Substr(aPeriodo[nX],1,10)+"|"
Next nX

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria o arquivo temporario ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cNomeArq := CriaTrab( aEstrut, .T. )
dbUseArea( .T.,,cNomeArq, cAliasTmp, .F., .F. )

IndRegua( cAliasTmp, cNomeArq, "AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+AK2_CC+AK2_ITCTB+AK2_CLVLR",,,"Criando Indice, aguarde..." )

dbClearIndex()
dbSetIndex( cNomeArq + OrdBagExt() )

// Campos para Validacao

aAdd(aCampos,"AK2_FILIAL")
aAdd(aCampos,"AK2_ID")
aAdd(aCampos,"AK2_ORCAME")
aAdd(aCampos,"AK2_VERSAO")
aAdd(aCampos,"AK2_CO")
aAdd(aCampos,"AK2_CC")
aAdd(aCampos,"AK2_ITCTB")
aAdd(aCampos,"AK2_CLVLR")
aAdd(aCampos,"AK2_CLASSE")
aAdd(aCampos,"AK2_OPER")

aEval( aCposPer,{|x| aAdd(aCampos,x) } )

//Define o valor do array conforme estrutura
aPosCampos:= Array(Len(aCampos))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Abre o arquivo a ser importado                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If (nHandle := FT_FUse(AllTrim(MV_PAR13)))== -1
	Help(" ",1,"NOFILE")
	Return
EndIf

// Valida se o Arquivo ้ CSV
If upper(Right(Alltrim(MV_PAR13),3)) <> "CSV"
	Help(" ",1, "ARQINV","Arquivo invแlido","O arquivo de importa็ใo nใo ้ um arquivo CSV.",1,0 )
	fClose(nHandle)
	Return
Endif

FT_FGOTOP()
cLinha := FT_FREADLN()
nPos	:=	0
nAt	:=	1

While nAt > 0
	nPos++
	nAt	:=	AT(";",cLinha)
	If nAt == 0
		cCampo := cLinha
	Else
		cCampo	:=	Substr(cLinha,1,nAt-1)
	Endif
	nPosCpo	:=	Ascan(aCampos,{|x| x==cCampo})
	If nPosCPO > 0
		aPosCampos[nPosCpo]:= nPos
	Endif
	cLinha	:=	Substr(cLinha,nAt+1)
Enddo

If (nPosNil:= Ascan(aPosCampos,Nil)) > 0
	Aviso("Estrutura incorreta.","O campo "+aCampos[nPosNil]+" nใo foi encontrado na estrutura do arquivo, por favor verifique.",{"Sair"})
	fClose(nHandle)
	Return .F.
Endif

// Inicia Importacao das Linhas
FT_FSKIP()
While !FT_FEOF()
	cLinha := FT_FREADLN()
	AADD(aTxt,{})
	nCampo := 1
	While At(";",cLinha)>0
		aAdd(aTxt[Len(aTxt)],Substr(cLinha,1,At(";",cLinha)-1))
		nCampo ++
		cLinha := StrTran(Substr(cLinha,At(";",cLinha)+1,Len(cLinha)-At(";",cLinha)),'"','')
	End
	If Len(AllTrim(cLinha)) > 0
		aAdd(aTxt[Len(aTxt)],StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
	Else
		aAdd(aTxt[Len(aTxt)],"")
	Endif
	FT_FSKIP()
End

// Gravacao dos Itens no TRB
FT_FUSE()
For nX:=1 To Len(aTxt)
	dbSelectArea(cAliasTmp)
	RecLock((cAliasTmp),.T.)
	(cAliasTmp)->LINHA 		:= Alltrim(Str(nX))
	For nY:=1 To Len(aCampos)
		If AllTrim(aCampos[nY]) $ cCposPer
			_nValor	:= val(strtran(StrTran(    aTxt[nX,aPosCampos[nY]] ,".","") ,",","." )    )  //Ana
			(cAliasTmp)->&("P"+StrTran(AllTrim(aCampos[nY]),"/","")) := _nValor
		Else
			FieldPut(FieldPos(aCampos[nY]),aTxt[nX,aPosCampos[nY]])
		Endif
	Next
	MsUnLock()
Next

dbSelectArea(cAliasTmp)
dbGotop()

xImpOrc(lEnd,oProcess,cAliasTmp,aPeriodo,cPlanOri,cRevOri,aConfig)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Apaga o TMP	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Select(cAliasTmp) != 0
	dbSelectArea(cAliasTmp)
	dbCloseArea()
	FErase(cNomeArq+GetDBExtension())
	FErase(cNomeArq+OrdBagExt())
Endif

fClose(nHandle)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIPCOA16  บAutor  ณMicrosiga           บ Data ณ  02/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta Processamento                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xProc(aConfig, cCtaOrc, cPlanOri, cRevOri, cPlanOri, aPeriodo, aPerAux)
Local oProcess

oProcess:= MsNewProcess():New({|lEnd| Fim_Wiz(aConfig, cCtaOrc, cPlanOri, cRevOri, aPeriodo, aPerAux,.F.,oProcess)})
oProcess:Activate()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ Ctb025Imp    ณ Autor ณ Felipe A. Melo    ณ Data ณ 17/09/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Exporta cadastro do plano de contas referencial            ณฑฑ
ฑฑณ          ณ se jแ foi utilizada em alguma outra rotina                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Ctb025Imp()                                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ CTBA025                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function xImpOrc(lEnd,oProcess,cAliasTmp,aPeriodo,cPlanOri,cRevOri,aConfig)
LOCAL nProcRegs	:= 0
LOCAL nTotRegs	:= 0
Local cChavPla 	:= AK1->(AK1_FILIAL+AK1_CODIGO+AK1_VERSAO)
Local cTexto 	:= ""
Local cFile  	:= IIF(upper(Right(Alltrim(MV_PAR13),3)) == "CSV",Substr(Alltrim(MV_PAR13),1,Len(Alltrim(MV_PAR13))-4),Alltrim(MV_PAR13))+".LOG"
Local lErro		:= .F.

Private _nMaxReg:= GetMV("MV_PCOLIMI")
Private _nTotReg:= 0

dbEval( {|x| nTotRegs++ },,{|| (cAliasTmp)->(!EOF())})
oProcess:SetRegua1(nTotRegs)
oProcess:IncRegua1("Iniciando processamento...")
oProcess:SetRegua2(nTotRegs)
oProcess:IncRegua2("Ordem de producao:")

cTexto += Replicate( "-", 128 ) + CRLF
ctexto += Replicate( " ", 128 ) + CRLF
ctexto += "LOG DE IMPORTACAO DA PLANILHA ORCAMENTARIA" + CRLF
ctexto += Replicate( " ", 128 ) + CRLF
ctexto += Replicate( "-", 128 ) + CRLF
ctexto += CRLF
ctexto += " Dados Ambiente" + CRLF
ctexto += " --------------------"  + CRLF
ctexto += " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt  + CRLF
ctexto += " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
ctexto += " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
ctexto += " DataBase...........: " + DtoC( dDataBase )  + CRLF
ctexto += " Data / Hora Inicio.: " + DtoC( Date() )  + " / " + Time()  + CRLF
ctexto += " Usuario TOTVS .....: " + __cUserId + " " +  cUserName + CRLF
ctexto += Replicate( "-", 128 ) + CRLF
ctexto += CRLF


dbSelectArea(cAliasTmp)
dbGotop()

WHILE (cAliasTmp)->(!EOF())
	
	nProcRegs++
	oProcess:IncRegua1("Processando item: "+CValToChar(nProcRegs)+" / "+CValToChar(nTotRegs))
	
	// Valida Registros e Gerar Log
	
	// Valida Chave da Planilha Orcamentaria
	If (cAliasTmp)->AK2_FILIAL+AK2_ORCAME+AK2_VERSAO <> cChavPla
		cTexto += "A chave da planilha or็amentแria: "+Alltrim((cAliasTmp)->AK2_FILIAL+AK2_ORCAME+AK2_VERSAO)+", informada no arquivo CSV, nใo ้ a mesma da planilha posicionada."+CRLF
		lErro := .T.
	Endif
	
	// Valida Existencia da Conta Orcamentaria
	dbSelectArea("AK5")
	dbSetOrder(1)
	If !dbSeek(xFilial("AK5")+(cAliasTmp)->AK2_CO)
		cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A conta or็amentแria: "+Alltrim((cAliasTmp)->AK2_CO )+" informada no arquivo CSV, nใo existe no sistema."+CRLF
		lErro := .T.
	ElseIf AK5->AK5_TIPO <> "2"
		cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A conta or็amentแria: "+Alltrim((cAliasTmp)->AK2_CO )+" nใo ้ analํtica."+CRLF
		lErro := .T.
	Elseif AK5->AK5_MSBLQL == "1"
		IF !(Alltrim((cAliasTmp)->AK2_CO)$cTexto)
			cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A conta or็amentแria: "+Alltrim((cAliasTmp)->AK2_CO )+" estแ bloqueada para uso."+CRLF
			lErro := .T.
		ENDIF
	Endif
	
	// Valida Existencia do Centro de Custo
	If !Empty((cAliasTmp)->AK2_CC)
		dbSelectArea("CTT")
		dbSetOrder(1)
		If !dbSeek(xFilial("CTT")+(cAliasTmp)->AK2_CC)
			cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A U.O.: "+Alltrim((cAliasTmp)->AK2_CC)+" informada no arquivo CSV, nใo existe no sistema."+CRLF
			lErro := .T.
		ElseIf CTT->CTT_CLASSE <> "2"
			cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A U.O.: "+Alltrim((cAliasTmp)->AK2_CC)+" nใo ้ analํtica."+CRLF
			lErro := .T.
		ElseIf !ValidaBloq((cAliasTmp)->AK2_CC,Date(),"CTT",.f.)
			cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A U.O.: "+Alltrim((cAliasTmp)->AK2_CC)+" estแ bloqueada para uso."+CRLF
			lErro := .T.
		Endif
	Endif
	
	// Valida Existencia do Item Contabil
	If !Empty((cAliasTmp)->AK2_ITCTB)
		dbSelectArea("CTD")
		dbSetOrder(1)
		If !dbSeek(xFilial("CTD")+(cAliasTmp)->AK2_ITCTB)
			cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - O C.R.: "+Alltrim((cAliasTmp)->AK2_ITCTB)+" informado no arquivo CSV, nใo existe no sistema."+CRLF
			lErro := .T.
		ElseIf CTD->CTD_CLASSE <> "2"
			cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - O C.R.: "+Alltrim((cAliasTmp)->AK2_ITCTB)+" nใo ้ analํtico."+CRLF
			lErro := .T.
		Elseif !ValidaBloq((cAliasTmp)->AK2_ITCTB,Date(),"CTH",.f.)
			cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - O C.R.: "+Alltrim((cAliasTmp)->AK2_ITCTB)+" estแ bloqueado para uso."+CRLF
			lErro := .T.
		Endif
	Endif
	
	// Valida Existencia da Classe de Valor
	If !Empty((cAliasTmp)->AK2_CLVLR)
		dbSelectArea("CTH")
		dbSetOrder(1)
		If !dbSeek(xFilial("CTH")+(cAliasTmp)->AK2_CLVLR)
			cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A classe de valor: "+Alltrim((cAliasTmp)->AK2_CLVLR)+", informada no arquivo CSV, nใo existe no sistema."+CRLF
			lErro := .T.
		ElseIf CTH->CTH_CLASSE <> "2"
			cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A classe de valor: "+Alltrim((cAliasTmp)->AK2_CLVLR)+", nใo ้ analํtica."+CRLF
			lErro := .T.
		ElseIf !ValidaBloq((cAliasTmp)->AK2_CLVLR,Date(),"CTH",.f.)
			cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A classe de valor: "+Alltrim((cAliasTmp)->AK2_CLVLR)+", estแ bloqueada para uso."+CRLF
			lErro := .T.
		Endif
	Endif
	
	// Valida Existencia da Classe Orcamentaria
	dbSelectArea("AK6")
	dbSetOrder(1)
	If !dbSeek(xFilial("AK6")+(cAliasTmp)->AK2_CLASSE)
		cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A classe or็แmentแria: "+Alltrim((cAliasTmp)->AK2_CLASSE)+", informada no arquivo CSV, nใo existe no sistema."+CRLF
		lErro := .T.
	Endif
	
	// Valida Existencia da Opera็ใo Or็amentaria
	//	If !Empty((cAliasTmp)->AK2_OPER)
	dbSelectArea("AKF")
	dbSetOrder(1)
	If !dbSeek(xFilial("AKF")+(cAliasTmp)->AK2_OPER)
		cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A opera็ใo or็amentแria: "+Alltrim((cAliasTmp)->AK2_OPER)+", informada no arquivo CSV, nใo existe no sistema."+CRLF
		lErro := .T.
	Endif
	//	Endif
	
	
	DbSelectArea(cAliasTmp)
	DbSkip()
	
Enddo

If lErro
	MsgStop("Ocorreram erros na valida็ใo do arquivo CSV. O processo foi abortado!"+CRLF+"Por favor, verifique o arquivo "+Alltrim(cFile)+" gerado no mesmo diret๓rio do arquivo importado para mais detalhes.","Aten็ใo")
Else
	
	If (Aviso("Importa็ใo da Planilha","Confirma a importa็ใo dos dados conforme parโmetros informados?",{"Sim","Nใo"},1)==1)
		
		//Apagar os dados ou nao
		If MV_PAR12 == "1"
			//			IF Aviso("Os itens existentes na Planilha Or็amentแria serใo MANTIDOS conforme parโmetro selecionado.",{"Continuar","Abortar"},1) <> 1
			IF Aviso("Aten็ใo","Os itens existentes na Planilha Or็amentแria serใo MANTIDOS conforme parโmetro selecionado.",{"Continuar","Abortar"},1) <> 1
				Return()
			ENDIF
		Else
			IF Aviso("Aten็ใo","Os itens existentes na Planilha Or็amentแria serใo APAGADOS conforme parโmetro selecionado.",{"Continuar","Abortar"},1) <> 1
				Return()
			ENDIF
			//Apaga os Dados
			xDelOrc()
		Endif
		
		// Processa Importacao
		DbSelectArea(cAliasTmp)
		dbGotop()
		
		PcoIniLan("000252")
		
		While !Eof(cAliasTmp)
			
			cCtaOrc := (cAliasTmp)->AK2_CO
			oProcess:IncRegua2("CO: "+cCtaOrc)
			xGeraOrc(cAliasTmp,cCtaOrc,aPeriodo,cPlanOri,cRevOri)
			
			dbSelectArea(cAliasTmp)
			dbSkip()
		EndDo
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Finaliza a gravacao dos lancamentos do SIGAPCO            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		PcoFinLan("000252")
		
	Endif
	
	cTexto += "Importa็ใo realizada com sucesso!"+CRLF
Endif

cTexto += Replicate( "-", 128 ) + CRLF
cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
cTexto += Replicate( "-", 128 ) + CRLF

MemoWrite( cFile, cTexto )

If !lErro
	Aviso("Importa็ใo de Planilha","A importa็ใo foi concluํda com ๊xito!"+CRLF+CRLF+"Por favor, verifique o arquivo "+Alltrim(cFile)+" gerado no mesmo diret๓rio do arquivo importado para mais detalhes."+CRLF+CRLF+"ษ necessแrio fechar a planilha or็amentแria e abri-la novamente para visualizar os dados importados.",{"OK"},2)
Endif

Return lErro

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  xDelOrc บ Autor ณ Leonardo Soncin    บ Data ณ  27/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Deleta dados da Pl. Orcamentaria antes da importacao do csvบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function xDelOrc()
Local cAliasDel := GetNextAlias()
Local cQuery    := ""

// Deleta AK2
cQuery := "SELECT R_E_C_N_O_ AS NREG FROM "
cQuery += RetSqlName("AK2")+" "
cQuery += " WHERE AK2_FILIAL = '"+MV_PAR01+"' AND AK2_ORCAME = '"+MV_PAR02+"'  AND AK2_VERSAO = '"+MV_PAR03+"' AND "
cQuery += " AK2_CO BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"'  AND "
cQuery += " AK2_CC BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'  AND "
cQuery += " AK2_ITCTB BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"'  AND "
cQuery += " AK2_CLVLR BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"'  AND "
cQuery += " D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)

If Select(cAliasDel) > 0
	dbSelectArea(cAliasDel)
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDel,.T.,.F.)

DbSelectArea(cAliasDel)
dbGotop()

If !Eof(cAliasDel)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicializa a gravacao dos lancamentos do SIGAPCO          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	PcoIniLan("000252")
	
	While !Eof(cAliasDel)
		
		dbSelectArea("AK2")
		dbGoto((cAliasDel)->NREG)
		
		PcoDetLan("000252","01","PCOA100",.T.,"00025201")
		Reclock("AK2",.F.,.T.)
		dbDelete()
		Msunlock()
		
		dbSelectArea(cAliasDel)
		dbSkip()
	Enddo
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finaliza a gravacao dos lancamentos do SIGAPCO            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	PcoFinLan("000252")
	
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  xGeraOrcบ Autor ณ Leonardo Soncin    บ Data ณ  27/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Deleta dados da Pl. Orcamentaria antes da importacao do csvบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CNI                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function xGeraOrc(cAliasTmp,cCtaOrc,aPeriodo,cPlanOri,cRevOri)
Local nX       := 0
Local cItem	   := ""
Local cNivel   := "001"
Local aRecAK3  := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa a gravacao dos lancamentos do SIGAPCO          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF _nTotReg = _nMaxReg
	_nTotReg := 0
	PcoFinLan("000252")
	PcoIniLan("000252")
ENDIF


For nX := 1 to Len(aPeriodo)
	
	IF (cAliasTmp)->&("P"+StrTran(Substr(aPeriodo[nx],1,10),"/","")) == 0
		Loop
	ENDIF
	
	Do Case
		Case !((cAliasTmp)->(AK2_CO) >= MV_PAR04 .and. (cAliasTmp)->(AK2_CO) <= MV_PAR05)
			Loop
		Case!((cAliasTmp)->(AK2_CC) >= MV_PAR06 .and. (cAliasTmp)->(AK2_CC) <= MV_PAR07)
			Loop
		Case !((cAliasTmp)->(AK2_ITCTB) >= MV_PAR08 .and. (cAliasTmp)->(AK2_ITCTB) <= MV_PAR09)
			Loop
		Case !((cAliasTmp)->(AK2_CLVLR) >= MV_PAR10 .and. (cAliasTmp)->(AK2_CLVLR) <= MV_PAR11)
			Loop
	EndCase
	
	
	dbSelectArea("AK2")
	dbSetOrder(1)
	dbSeek(xFilial()+cPlanOri+cRevOri+cCtaOrc+DTOS(CTOD(Substr(aPeriodo[nx],1,10)))+"ZZZZ",.T.)
	dbSkip(-1)
	
	// TRATA BUSCA
	If xFilial("AK2")+cPlanOri+cRevOri+cCtaOrc+DTOS(CTOD(Substr(aPeriodo[nx],1,10)))==;
		AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+DTOS(AK2_PERIOD)
		cItem := Soma1(AK2->AK2_ID)
		
		// TRATA ALTERACAO
	Else
		cItem := "0001"
	EndIf
	
	RecLock("AK2",.T.)
	AK2->AK2_FILIAL := xFilial("AK2")
	AK2->AK2_ORCAME := cPlanOri
	AK2->AK2_VERSAO := cRevOri
	AK2->AK2_MOEDA	:= 1
	AK2->AK2_PERIOD	:= CTOD(Substr(aPeriodo[nx],1,10))
	AK2->AK2_DATAI	:= CTOD(Substr(aPeriodo[nx],1,10))
	AK2->AK2_DATAF	:= CTOD(Substr(aPeriodo[nx],14,16))
	AK2->AK2_ID		:= cItem
	AK2->AK2_CO 	:= (cAliasTmp)->AK2_CO
	AK2->AK2_CC 	:= (cAliasTmp)->AK2_CC
	AK2->AK2_ITCTB 	:= (cAliasTmp)->AK2_ITCTB
	AK2->AK2_CLVLR 	:= (cAliasTmp)->AK2_CLVLR
	AK2->AK2_XSTS	:= "0" // status da UO
	AK2->AK2_CLASSE := (cAliasTmp)->AK2_CLASSE
	AK2->AK2_OPER	:= (cAliasTmp)->AK2_OPER
	AK2->AK2_VALOR	:= (cAliasTmp)->&("P"+StrTran(Substr(aPeriodo[nx],1,10),"/",""))
	AK2->AK2_XDTIMP := dDataBase
	
	MsUnlock()
	
	dbSelectArea("AK3")
	dbSetOrder(1)
	
	If !dbSeek(xFilial('AK3')+AK2->AK2_ORCAME+AK2->AK2_VERSAO+AK2->AK2_CO)
		cNivel := "001"
		GravaAK3(AK2->AK2_ORCAME,AK2->AK2_VERSAO,AK2->AK2_CO,aRecAK3,@cNivel)
		
		For nt := Len(aRecAK3) to 1 Step -1
			cNivel := Soma1(cNivel)
			AK3->(dbGoto(aRecAK3[nt]))
			RecLock("AK3",.F.)
			AK3->AK3_NIVEL := cNivel
			MsUnlock()
		Next nt
	EndIf
	
	dbSelectArea("AK2")
	
	PcoDetLan("000252","01","PCOA100")
	
	_nTotReg++
	
	IF _nTotReg = _nMaxReg
		_nTotReg := 0
		PcoFinLan("000252")
		PcoIniLan("000252")
	ENDIF
	
Next nX

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ xIncConta บAutor ณ Leonardo Soncin     บ Data ณ 21/11/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณInclui as contas orcamentarias ref a tab (AK3)   posicionadoบฑฑ
ฑฑบ          ณutiliza recursividade ao chamar a funcao A200Nivel() para   บฑฑ
ฑฑบ          ณchamar novamente xIncConta para as contas pai     	      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GravaAK3(cOrcame,cVersao,cCO,aRecAK3,cNivel)
Local aArea := GetArea()
dbSelectArea("AK5")
dbSetOrder(1)
If MsSeek(xFilial()+cCO)
	PmsNewRec("AK3")
	AK3->AK3_FILIAL 	:= xFilial("AK3")
	AK3->AK3_ORCAME		:= cOrcame
	AK3->AK3_VERSAO		:= cVersao
	AK3->AK3_CO			:= cCO
	AK3->AK3_PAI		:= If(Empty(AK5->AK5_COSUP),cOrcame,AK5->AK5_COSUP)
	AK3->AK3_TIPO		:= AK5->AK5_TIPO
	AK3->AK3_DESCRI		:= AK5->AK5_DESCRI
	MsUnlock()
	aAdd(aRecAK3,AK3->(RecNo()))
	dbSelectArea("AK3")
	dbSetOrder(1)
	If !Empty(AK5->AK5_COSUP)
		If !dbSeek(xFilial('AK3')+cOrcame+cVersao+AK5->AK5_COSUP)
			GravaAK3(AK2->AK2_ORCAME,AK2->AK2_VERSAO,AK5->AK5_COSUP,aRecAK3,@cNivel)
		Else
			cNivel := AK3->AK3_NIVEL
		EndIf
	EndIf
EndIf
RestArea(aArea)
Return
