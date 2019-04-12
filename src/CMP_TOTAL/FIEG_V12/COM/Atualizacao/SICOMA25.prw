#Include "Protheus.ch"
#Include "msmgadd.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA25
Manutencao de Lotes.

@type function
@author Caio Santos - TOTVS
@since 12/01/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SICOMA25()

Local aArea 	:= GetArea()
Local aAreaCO2 	:= CO2->(GetArea())
Local lFinal 	:= .F.
Local cQry		:= ""
Local nOpc		:= 1
Local lLte		:= .F. 										//Edital sem lotes -> Inclusao
Local aLte		:= {} 										//Array com lotes pre-existentes no edital
Local aPerg		:= {} 										//Array com as perguntas da ParamBox
Local aRetLte	:= {} 										//Array com a selecao do lote p/ manutencao
Local cLteMan	:= "" 										//Numero do lote selecionado p/ manutencao
Local nReg 		:= 0

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Filtra dados CO2 >------------------------------------
cQry := " CO2_FILIAL = '" + xFilial("CO2") + "' AND"
cQry += " CO2_CODEDT = '" + CO1->CO1_CODEDT + "' AND"
cQry += " CO2_NUMPRO = '" + CO1->CO1_NUMPRO + "'"
cQry := "%"+cQry+"%"

BeginSQL Alias "LOTES"
	SELECT CO2_XNUMLO AS CO2_LTE
	FROM %Table:CO2% CO2
	WHERE %Exp:cQry% AND CO2.%NotDel% 
	GROUP BY CO2_XNUMLO
EndSQL

LOTES->(dbGoTop())

//--< Define operacao >-------------------------------------
While !LOTES->(EOF())

	If !Empty(LOTES->CO2_LTE)
		lLte := .T. 										//Edital c/ lotes -> Usuario escolhe operacao
		aAdd(aLte, LOTES->CO2_LTE)
	EndIf
	           
	nReg ++
	LOTES->(dbSkip())
	
EndDo

If lLte

	PutSx1("XSICOMA25","01","Opera?o?","","","mv_ch01","N",1,0,1,"C",,,,,"mv_par01","Inclus?",,,,"Manuten?o")

	If Pergunte("XSICOMA25",.T.,"Defina a Opera?o")
	
		nOpc := mv_par01
		aAdd(aPerg,{3,"Lote",1,aLte,50,".T.",.T.})	
		
		If nOpc == 2
			If ParamBox(aPerg,"Selecione o Lote",aRetLte)
				cLteMan := aLte[aRetLte[1]]
			Else
				lFinal := .T.
			EndIf
		ElseIf nOpc == 1 .And. nReg == Len(aLte)
			Aviso("Aten??o","N?o ? poss?vel incluir mais lotes neste edital. Todos os itens do edital j?fazem parte de algum lote.",{"Voltar"},1)
			lFinal := .T.
		EndIf
		
	Else
		lFinal := .T.
	EndIf
EndIf

If !lFinal
	fXTELALOTE(nOpc,cLteMan,aLte) 							//Tela de manutencao de lotes
EndIf

LOTES->(dbCloseArea())

RestArea(aArea)

CO2->(RestArea(aAreaCO2))

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} fXTELALOTE
Monta tela de manutancao de lotes, usado no Manutencao de Lotes (SICOMA25).

@type function
@author Caio Santos - TOTVS
@since 12/01/2012
@version P12.1.23

@param nOpc	  , Numérico , Número da Opção da Rotina.
@param cLteMan, Caractere, Lote.
@param aLte   , Array    , Lote.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function fXTELALOTE(nOpc,cLteMan,aLte)

Local cQry 	  := ""
Local cExp 	  := "" 										//Expressao da query que diferenciara o filtro da CO2 p/ inclusao e manutencao
//--< Variaveis MsDialog >----------------------------------
Local oDlg 	  := Nil
//--< Variaveis TGet >--------------------------------------
Local oGetFil := Nil
Local oGetEdt := Nil
Local oGetNpr := Nil
Local oGetEtp := Nil
Local oGetLte := Nil
Local oGetVlm := Nil
Local cFil 	  := CO1->CO1_FILIAL
Local cEdt 	  := CO1->CO1_CODEDT
Local cNpr 	  := CO1->CO1_NUMPRO
Local cEtp 	  := CO1->CO1_ETAPA
Local cLte 	  := Space(6)
Local nVlm 	  := 0
//--< Definicoes de tamanho, posicao e conteudo dos objetos >-
Local aTam 	  := MsAdvSize(.T.)
Local aObj 	  := {{100,25,.T.,.T.},{100,75,.T.,.T.}}
Local aPos 	  := MsObjSize({aTam[1],aTam[2],aTam[3],aTam[4],0,0,0,0},aObj,.T.)
//Local aObjGet := {{100,100,.T.,.F.,.F.},{300,100,.T.,.F.,.F.},{300,100,.T.,.F.,.F.},{100,100,.T.,.F.,.F.},{200,100,.T.,.F.,.F.},{300,100,.T.,.F.,.F.}}
//Local aPosGet := MsObjSize({aPos[1][1],aPos[1][2],aPos[1][3],aPos[1][4],10,10,0,0},aObjGet,.T.,.T.)
Local oTela   := Nil
Local oPanel1 := Nil
Local oPanel2 := Nil
Local aBut 	  := {}

//Variaveis MsSelect
Local aStru := {}
Local cArq := ""
Local aSel := {}
Private oMrk := Nil
Private cMrk := GetMark()

Private cCadastro := "Manuten??o de Lotes"

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
//MsDialog>
//oDlg := MsDialog():New(aTam[7],aTam[2],aTam[6],aTam[5],cCadastro,,,,,,,,,.T.)
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aTam[7],00 TO aTam[6],aTam[5] PIXEL
//<MsDialog
   
//Paineis>
oTela := FWFormContainer():New(oDlg)
oTela:Activate(oDlg,.F.)
oPanel1 := oTela:GetPanel(oTela:CreateHorizontalBox(25))
oPanel2 := oTela:GetPanel(oTela:CreateHorizontalBox(75))
//<Paineis

//TGets>

@ /*aPosGet[1][1]+15,aPosGet[1][2]*/15,10 SAY "Filial" OF oPanel1 PIXEL SIZE 30,10
oGetFil := TGet():New(/*aPosGet[1][1]+22*/22,/*aPosGet[1][2]*/10,{||cFil},oPanel1,/*aPosGet[1][4]-aPosGet[1][2]*/50,10,PesqPict("CO1","CO1_FILIAL"),;
/*bValid*/,/*nClrFore*/,/*nClrBack*/,/*oFont*/,,,.T./*lPixel*/,,,;
{||.F.}/*bWhen*/,,,/*bChange*/,/*lReadOnly*/,/*lPassword*/,,/*cReadVar*/,,,,;
/*lHasButton*/,/*lNoButton*/)

@ /*aPosGet[2][1]+15,aPosGet[2][2]*/15,70 SAY "Cod. Edital" OF oPanel1 PIXEL SIZE 30,10
oGetEdt := TGet():New(/*aPosGet[2][1]+22*/22,/*aPosGet[2][2]*/70,{||cEdt},oPanel1,/*aPosGet[2][4]-aPosGet[2][2]*/100,10,PesqPict("CO1","CO1_CODEDT"),;
/*bValid*/,/*nClrFore*/,/*nClrBack*/,/*oFont*/,,,.T./*lPixel*/,,,;
{||.F.}/*bWhen*/,,,/*bChange*/,/*lReadOnly*/,/*lPassword*/,,/*cReadVar*/,,,,;
/*lHasButton*/,/*lNoButton*/)

@ /*aPosGet[3][1]+15,aPosGet[3][2]*/15,180 SAY "Nr. Processo" OF oPanel1 PIXEL SIZE 30,10
oGetNpr := TGet():New(/*aPosGet[3][1]+22*/22,/*aPosGet[3][2]*/180,{||cNpr},oPanel1,/*aPosGet[3][4]-aPosGet[3][2]*/100,10,PesqPict("CO1","CO1_NUMPRO"),;
/*bValid*/,/*nClrFore*/,/*nClrBack*/,/*oFont*/,,,.T./*lPixel*/,,,;
{||.F.}/*bWhen*/,,,/*bChange*/,/*lReadOnly*/,/*lPassword*/,,/*cReadVar*/,,,,;
/*lHasButton*/,/*lNoButton*/)

@ /*aPosGet[4][1]+15,aPosGet[4][2]*/15,290 SAY "Etapa Edital" OF oPanel1 PIXEL SIZE 30,10
oGetEtp := TGet():New(/*aPosGet[4][1]+22*/22,/*aPosGet[4][2]*/290,{||cEtp},oPanel1,/*aPosGet[4][4]-aPosGet[4][2]*/20,10,PesqPict("CO1","CO1_ETAPA"),;
/*bValid*/,/*nClrFore*/,/*nClrBack*/,/*oFont*/,,,.T./*lPixel*/,,,;
{||.F.}/*bWhen*/,,,/*bChange*/,/*lReadOnly*/,/*lPassword*/,,/*cReadVar*/,,,,;
/*lHasButton*/,/*lNoButton*/)

@ /*aPosGet[5][1]+15,aPosGet[5][2]*/37,10 SAY "Lote" OF oPanel1 PIXEL SIZE 50,10
oGetLte := TGet():New(/*aPosGet[5][1]+22*/44,/*aPosGet[5][2]*/10,{|u| If(Pcount()>0,cLte:=u,cLte)},oPanel1,/*aPosGet[5][4]-aPosGet[5][2]*/50,10,PesqPict("CO2","CO2_XNUMLO"),;
{||XLTEVLD(cLte,aLte)}/*bValid*/,/*nClrFore*/,/*nClrBack*/,/*oFont*/,,,.T./*lPixel*/,,,;
{|| If(nOpc==1,.T.,.F.)}/*bWhen*/,,,/*bChange*/,/*lReadOnly*/,/*lPassword*/,,"cLte"/*cReadVar*/,,,,;
/*lHasButton*/,/*lNoButton*/)

@ /*aPosGet[6][1]+15,aPosGet[6][2]*/37,70 SAY "Valor Minimo" OF oPanel1 PIXEL SIZE 50,10
oGetVlm := TGet():New(/*aPosGet[6][1]+22*/44,/*aPosGet[6][2]*/70,{|u| If(Pcount()>0,nVlm:=u,nVlm)},oPanel1,/*aPosGet[6][4]-aPosGet[6][2]*/90,10,PesqPict("CO2","CO2_XVLMIN"),;
{||NaoVazio(nVlm)}/*bValid*/,/*nClrFore*/,/*nClrBack*/,/*oFont*/,,,.T./*lPixel*/,,,;
{|| If(nOpc==1,.T.,.F.)}/*bWhen*/,,,/*bChange*/,/*lReadOnly*/,/*lPassword*/,,"nVlm"/*cReadVar*/,,,,;
/*lHasButton*/,/*lNoButton*/)

//<TGets

//MsSelect>
//Estrutura dos campos
aSel := { 	{"CO2_MRK",,""					,"@!"},;
			{"CO2_ITM",,"Item"				,"@!"},;
			{"CO2_COD",,"Cod. Produto"   	,"@!"},;
			{"SB1_DSC",,"Desc. Produto"		,"@!"},;
			{"CO2_QTD",,"Quantidade"		,"@E999,999,999.99"},;
			{"SB1_UNM",,"Cod. Produto"   	,"@!"}	}

//Area de trabalho temporaria
AADD(aStru,{"MRK","C",2,0})
AADD(aStru,{"CO2_ITM","C",6,0})
AADD(aStru,{"CO2_COD","C",30,0})
AADD(aStru,{"SB1_DSC","C",30,0})
AADD(aStru,{"CO2_QTD","N",12,2})
AADD(aStru,{"SB1_UNM","C",2,0})
cArq := Criatrab(aStru,.T.)
DbUseArea(.T.,,cArq,"MRKTMP")
      
//Filtra dados CO2
If nOpc == 1
	cExp := " CO2_XNUMLO = ''"
ElseIf nOpc == 2
	cExp := " (CO2_XNUMLO = '' OR CO2_XNUMLO = '" + cLteMan + "')"
EndIf
cQry := " CO2_FILIAL = '" + xFilial("CO2") + "' AND"
cQry += " B1_FILIAL = '" + xFilial("SB1") + "' AND"
cQry += " CO2_CODEDT = '" + CO1->CO1_CODEDT + "' AND"
cQry += " CO2_NUMPRO = '" + CO1->CO1_NUMPRO + "' AND"
cQry += cExp
cQry := "%"+cQry+"%"

BeginSQL Alias "DADOS"
	SELECT CO2_ITEM AS CO2_ITM, CO2_CODPRO AS CO2_COD, CO2_QUANT AS CO2_QTD, CO2_XNUMLO AS CO2_LTE, CO2_XVLMIN AS CO2_VLM, B1_DESC AS SB1_DSC, B1_UM AS SB1_UNM
	FROM %Table:CO2% CO2 INNER JOIN %Table:SB1% SB1
	ON CO2_CODPRO=B1_COD
	WHERE %Exp:cQry% AND CO2.%NotDel% AND SB1.%NotDel%
	ORDER BY CO2_XNUMLO DESC
EndSQL

DADOS->(dbGoTop())
     
//Conteudo das Gets
If nOpc == 2
	cLte := DADOS->CO2_LTE
	nVlm := DADOS->CO2_VLM
EndIf

While !DADOS->(EOF())

	RecLock("MRKTMP",.T.)
		If (nOpc == 2) .And. (DADOS->CO2_LTE == cLteMan)
			MRKTMP->MRK := cMrk
		EndIf
		MRKTMP->CO2_ITM := DADOS->CO2_ITM
		MRKTMP->CO2_COD := DADOS->CO2_COD
		MRKTMP->SB1_DSC := DADOS->SB1_DSC
		MRKTMP->CO2_QTD := DADOS->CO2_QTD
		MRKTMP->SB1_UNM	:= DADOS->SB1_UNM
	MRKTMP->(MsunLock())
	
	DADOS->(dbSkip())
	
EndDo

MRKTMP->(dbGoTop())

oMrk := MsSelect():New("MRKTMP","MRK","",aSel,,@cMrk,{aPos[2][1],aPos[2][2],aPos[2][3],aPos[2][4]},,,oPanel2/*oDlg*/)
oMrk:bMark := {|| fXMARK()}
oMrk:oBrowse:Align := CONTROL_ALIGN_CENTER
//<MsSelect

//oDlg:bInit := EnchoiceBar(oDlg,{|| fXCONFLOT(nOpc,cEdt,cNpr,cLte,nVlm), oDlg:End()},{|| oDlg:End()},,aBut)
//oDlg:lCentered := .T.
//oDlg:Activate()
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| fXCONFLOT(nOpc,cEdt,cNpr,cLte,nVlm), oDlg:End()},{|| oDlg:End()})

DADOS->(dbCloseArea())

MRKTMP->(dbCloseArea())

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} fXCONFLOT
Funcao para tratar confirmacao na tela de manutencao de Lotes, usado no Manutencao de Lotes (SICOMA25).

@type function
@author Caio Santos - TOTVS
@since 12/01/2012
@version P12.1.23

@param nOpc	  , Numérico , Número da Opção da Rotina.
@param cEdt	  , Caractere, Código do Edital
@param cNpr   , Caractere, Código do Processo.
@param cLte   , Caractere, Lote.
@param nVlm   , Numérico , Valor Mínimo.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibiliza??o para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function fXCONFLOT(nOpc,cEdt,cNpr,cLte,nVlm)
        
Local nI := 0

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
MRKTMP->(dbGoTop())
CO2->(dbSetOrder(2))

While !MRKTMP->(EOF())

	If !Empty(MRKTMP->MRK)
	
		//Atualiza GetDados		        
		For nI := 1 To Len(oGetEdt:aCols)
			If AllTrim(oGetEdt:aCols[nI][1]) == AllTrim(MRKTMP->CO2_ITM)
				oGetEdt:aCols[nI][7] := cLte
				oGetEdt:aCols[nI][8] := nVlm
			EndIf
		Next nI            
		
		//Grava dados na tabela
		If(CO2->(dbSeek(AllTrim(xFilial("CO2")+cEdt+cNpr+MRKTMP->CO2_ITM))))
			RecLock("CO2",.F.)
				CO2->CO2_XNUMLO := cLte
				CO2->CO2_XVLMIN := nVlm
			MsUnlock()
		EndIf
		
	ElseIf Empty(MRKTMP->MRK) .And. nOpc == 2
	
		//Atualiza GetDados
		For nI := 1 To Len(oGetEdt:aCols)
			If AllTrim(oGetEdt:aCols[nI][1]) == AllTrim(MRKTMP->CO2_ITM)
				oGetEdt:aCols[nI][7] := ""
				oGetEdt:aCols[nI][8] := 0
			EndIf
		Next nI
		
		//Grava dados na tabela
		If(CO2->(dbSeek(AllTrim(xFilial("CO2")+cEdt+cNpr+MRKTMP->CO2_ITM))))
			RecLock("CO2",.F.)
				CO2->CO2_XNUMLO := ""
				CO2->CO2_XVLMIN := 0
			MsUnlock()
		EndIf
		
	EndIf
	
	MRKTMP->(dbSkip())
	
EndDo

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} fXMARK
Funcao para tratar marcacao do MsSelect, usado no Manutencao de Lotes (SICOMA25).

@type function
@author Caio Santos - TOTVS
@since 12/01/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibiliza??o para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function fXMARK()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
RecLock("MRKTMP",.F.)
	If Marked("MRK")
		MRKTMP->MRK := cMrk
	Else
		MRKTMP->MRK := ""
	EndIf
MRKTMP->(MsUnlock())

oMrk:oBrowse:Refresh()

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} XLTEVLD
Funcao para tratar confirmacao na tela de manutencao de Lotes, usado no Manutencao de Lotes (SICOMA25).

@type function
@author Caio Santos - TOTVS
@since 12/01/2012
@version P12.1.23

@param cLte   , Caractere, Lote.
@param aLte   , Array	 , Lote.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

Static Function XLTEVLD(cLte,aLte)

Local nI := 0
Local lVld := .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
For nI := 1 To Len(aLte)
	If (cLte == aLte[nI])
		lVld := .F.
	EndIf
Next nI

If !lVld
	Aviso("Atenção","Já existe um lote com este Número no Processo do Edital.",{"Voltar"},1)
EndIf

If Empty(cLte)
	NaoVazio(cLte)
	lVld := .F.
EndIf

Return lVld
