#Include "PROTHEUS.CH"

#DEFINE ITEM			1
#DEFINE VPAGO			2

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � SIFINR05 � Autor � Leonardo Soncin       � Data � 28.08.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Relacao de Emprestimos                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe e � SIFINR05(void)                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Generico                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
User Function SIFINR05()
Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	Alert("Relat髍io n鉶 dispon韛el para R3!")
Endif

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � ReportDef� Autor � Daniel Batori         � Data � 28.08.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Definicao do layout do Relatorio			     			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � ReportDef(void)                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Generico                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function ReportDef()
Local oReport
Local oSection1

ValidPerg("SIFINR05")

oReport := TReport():New("SIFINR05","Demonstrativo de Empr閟timos","SIFINR05", {|oReport| ReportPrint(oReport)},"Este programa tem como objetivo imprimir o valor atualizado dos "+"emprestimos financeiros, conforme os parametros solicitados. ")

Pergunte("SIFINR05",.F.)

oSection1 := TRSection():New(oReport,"Detalhe",{"SE1"},)

TRCell():New(oSection1,"SEQ",,"Item",,3,.F.,)
TRCell():New(oSection1,"E1_PARCELA","SE1","Parcela",,2,.F.,)
TRCell():New(oSection1,"E1_EMISSAO","SE1","Emiss鉶",,,.F.,)
TRCell():New(oSection1,"E1_VENCREA","SE1","Vencimento",,,.F.,)
TRCell():New(oSection1,"E1_VALOR","SE1","Valor",PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1])
TRCell():New(oSection1,"VALPAGO","","   Valor Pago",PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1])
TRCell():New(oSection1,"E1_SALDO","SE1","Saldo",PesqPict("SE1","E1_SALDO"),TamSX3("E1_SALDO")[1])

oSection1:SetTotalInLine(.T.)

Return oReport

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北砅rograma  砇eportPrint� Autor 矰aniel Batori          � Data �22.08.06	潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escri噮o 矨 funcao estatica ReportDef devera ser criada para todos os  潮�
北�          硆elatorios que poderao ser agendados pelo usuario.           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   砃enhum                                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros矱xpO1: Objeto Report do Relat髍io                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北�   DATA   � Programador   矼anutencao efetuada                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北�          �               �                                             潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function ReportPrint(oReport)
Local oSection1  := oReport:Section(1)
Local aDados[2]
Local nSaldo
LOCAL cString		:="SZG"
LOCAL aCalculo := {}
LOCAL aTotal   := { 0,0,0,0 }
Local nX  := 1
Local nCol := 0
Local oBreak

oSection1:Cell("SEQ"):SetBlock( { || aDados[ITEM] })
oSection1:Cell("VALPAGO"):SetBlock( { || aDados[VPAGO] })

oBreak := TRBreak():New( oSection1, {|| SZG->ZG_NUMERO})
oBreak:SetPageBreak(.T.)

TRFunction():New(oSection1:Cell("E1_VALOR"),"","SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("VALPAGO"),"","SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("E1_SALDO"),"","SUM",oBreak,,,,.F.,.F.)


dbSelectArea("SZG")
dbSetOrder(1)
dbSeek(xFilial("SZG")+MV_PAR01,.T.)

oReport:SetPortrait()

oReport:OnPageBreak( { || xCabec( oReport) } )

oReport:SetMeter(SZG->(RecCount()))

oSection1:Init()
aFill(aDados,nil)

While ( !Eof() .And. SZG->ZG_FILIAL == xFilial("SZG") .AND. SZG->ZG_NUMERO <= MV_PAR02)
	
	If ( SZG->ZG_EMISSAO >= MV_PAR03 .And. SZG->ZG_EMISSAO <= MV_PAR04 ) .And. (SZG->ZG_TOMADOR >= MV_PAR05 .And. SZG->ZG_TOMADOR <= MV_PAR06) .AND.;
		(SZG->ZG_TOMLOJA >= MV_PAR07 .AND. SZG->ZG_TOMLOJA <= MV_PAR08) .And. (SZG->ZG_CC >= MV_PAR09 .AND. SZG->ZG_CC <= MV_PAR10) .AND.;
		(SZG->ZG_ITEM >= MV_PAR11 .AND. SZG->ZG_ITEM <= MV_PAR12) .AND. (SZG->ZG_CLVL >= MV_PAR13 .AND. SZG->ZG_CLVL <= MV_PAR14)
		
		dbSelectArea("SE1")
		dbOrderNickName("SISE101")
		dbSeek(xFilial("SE1")+SZG->ZG_NUMERO)
		While !eof() .and. SE1->E1_FILIAL == xFilial("SE1").and.E1_XEMP==SZG->ZG_NUMERO
			
			aDados[ITEM] := Alltrim(Str(nX))
			aDados[VPAGO] := SE1->E1_VALOR - SE1->E1_SALDO
			
			nX++
			oSection1:PrintLine()
			
			dbSelectArea("SE1")
			dbSkip()
		EndDo
		
		nX := 1
		
		aFill(aDados,nil)
		
	EndIf
	
	dbSelectArea("SZG")
	dbSkip()
	
	oReport:IncMeter()
	
EndDo

oSection1:Finish()


dbSelectArea("SZG")
dbSetOrder(1)
dbClearFilter()

Return( .T. )


/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  � ValidPerg� Autor � Wagner Gomes          � Data � 10/12/09 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Cria as Perguntas para Fatura para locacao de Bens Moveis  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Especifico Construtora OAS Ltda                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function ValidPerg(cPerg)

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Empr閟timo de:  "				,"mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Empr閟timo at�: "				,"mv_ch2","C",06,0,0,"G","naovazio()","mv_par02","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Emiss鉶 de:  "					,"mv_ch3","D",08,0,0,"G","naovazio()","mv_par03","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Emiss鉶 at�: "					,"mv_ch4","D",08,0,0,"G","naovazio() .and. mv_par04>=mv_par03","mv_par04","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Tomador de: "					,"mv_ch5","C",TamSX3("A2_COD")[1],0,0,"G","","mv_par05","","","","","","","","","","","","","","","SA2",""})
aAdd(aRegs,{cPerg,"06","Tomador at�: "					,"mv_ch6","C",TamSX3("A2_COD")[1],0,0,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","SA2",""})
aAdd(aRegs,{cPerg,"07","Loja de:"						,"mv_ch7","C",TamSX3("A2_LOJA")[1],0,0,"G","","mv_par07","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Loja at�:"						,"mv_ch8","C",TamSX3("A2_LOJA")[1],0,0,"G","","mv_par08","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Centro de custo de:"			,"mv_ch9","C",TamSX3("CTT_CUSTO")[1],0,0,"G","Vazio().or.ExistCpo('CTT')","mv_par09","","","","","","","","","","","","","","","CTT","004"})
aAdd(aRegs,{cPerg,"10","Centro de custo at�:"			,"mv_chA","C",TamSX3("CTT_CUSTO")[1],0,0,"G","NaoVazio()","mv_par10","","","","","","","","","","","","","","","CTT","004"})
aAdd(aRegs,{cPerg,"11","Item cont醔il de:"				,"mv_chB","C",TamSX3("CTD_ITEM")[1],0,0,"G","Vazio().or.ExistCpo('CTD')","mv_par11","","","","","","","","","","","","","","","CTD","005"})
aAdd(aRegs,{cPerg,"12","Item cont醔il at�:"				,"mv_chC","C",TamSX3("CTD_ITEM")[1],0,0,"G","NaoVazio()","mv_par12","","","","","","","","","","","","","","","CTD","005"})
aAdd(aRegs,{cPerg,"13","Classe de valor de:"			,"mv_chD","C",TamSX3("CTH_CLVL")[1],0,0,"G","Vazio().or.ExistCpo('CTH')","mv_par13","","","","","","","","","","","","","","","CTH","006"})
aAdd(aRegs,{cPerg,"14","Classe de valor at�:"			,"mv_chE","C",TamSX3("CTH_CLVL")[1],0,0,"G","NaoVazio()","mv_par14","","","","","","","","","","","","","","","CTH","006"})

For i := 1 to Len(aRegs)
	PutSX1(aRegs[i,1],aRegs[i,2],aRegs[i,3],aRegs[i,3],aRegs[i,3],aRegs[i,4],aRegs[i,5],aRegs[i,6],aRegs[i,7],;
	aRegs[i,8],aRegs[i,9],aRegs[i,10],iif(len(aRegs[i])>=26,aRegs[i,26],""),aRegs[i,27],"",aRegs[i,11],aRegs[i,12],;
	aRegs[i,12],aRegs[i,12],aRegs[i,13],aRegs[i,15],aRegs[i,15],aRegs[i,15],aRegs[i,18],aRegs[i,18],aRegs[i,18],;
	aRegs[i,21],aRegs[i,21],aRegs[i,21],aRegs[i,24],aRegs[i,24],aRegs[i,24])
	
Next i

dbSelectArea(_sAlias)

Return

Static Function xCabec(oReport)

Local cMascara 		:= GetMv("MV_MASCARA")
Local cMascCTD 		:= GetMv("MV_MASCCTD")
Local cMascCUS 		:= GetMv("MV_MASCCUS")
Local cCC			:= EntidadeCTB(SZG->ZG_CC,0,0,20,.F.,cMascCUS,,,,,,.F.)
Local cConta		:= EntidadeCTB(SZG->ZG_CONTA,0,0,20,.F.,cMascara,,,,,,.F.)
Local cItem			:= EntidadeCTB(SZG->ZG_ITEM,0,0,20,.F.,cMascCTD,,,,,,.F.)
Local cObs			:= SZG->ZG_OBS
Local cMemo			:= ""  

cMemo     := cObs//MSMM(SZG->ZG_OBS)
nMemCount := MlCount( cMemo, 10 )

oReport:PrintText(" ")
oReport:PrintText("N鷐ero            : "+SZG->ZG_NUMERO)
oReport:PrintText("Tomador           : "+SZG->(ZG_TOMADOR+"/"+ZG_TOMLOJA)+" - "+Posicione("SA2",1,xFilial("SA2")+SZG->(ZG_TOMADOR+ZG_TOMLOJA),"A2_NOME"))
oReport:PrintText("Unidade           : "+Alltrim(cCC)+" - "+Posicione("CTT",1,xFilial("CTT")+SZG->ZG_CC,"CTT_DESC01"))
oReport:PrintText("Centro Respons    : "+Alltrim(cItem)+" - "+Posicione("CTD",1,xFilial("CTD")+SZG->ZG_ITEM,"CTD_DESC01"))
oReport:PrintText("Conta Cont醔il    : "+Alltrim(cCOnta)+" - "+Posicione("CT1",1,xFilial("CT1")+SZG->ZG_CONTA,"CT1_DESC01"),oReport:Row(),oReport:Col())
nCol := oReport:Col()+10
oReport:PrintText("Data emiss鉶 : "+Dtoc(SZG->ZG_EMISSAO),,nCol)
oReport:PrintText("Vr. Empr閟timo    : "+Alltrim(Transform(SZG->ZG_VALOR,PesqPict("SZG","ZG_VALOR"))),oReport:Row(),oReport:Col())
oReport:PrintText("Cond. Pagto. : "+Alltrim(SZG->ZG_COND)+" - "+Posicione("SE4",1,xFilial("SE4")+SZG->ZG_COND,"E4_DESCRI"),,nCol)
oReport:PrintText("Parcelas Car阯cia : "+Alltrim(Str(SZG->ZG_CARENC)),oReport:Row(),oReport:Col())
oReport:PrintText("Taxa Aplicada: "+Alltrim(Transform(SZG->ZG_TAXA,PesqPict("SZG","ZG_TAXA"))),,nCol)
oReport:PrintText("Observa珲es       : "+cObs)

If !Empty( nMemCount )
	For nLoop := 2 To nMemCount
		cObs := MemoLine( cMemo, 80, nLoop )  
		oReport:PrintText("                    "+cObs)
	Next nLoop	
EndIf

oReport:SkipLine( 1 )

Return
