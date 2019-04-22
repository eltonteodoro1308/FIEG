#Include "Protheus.Ch"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SIFINA14 บ Autor ณ Microsiga          บ Data ณ  27/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Transferencia de Titulos                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function SIFINA14(cCampo,cCarteira)
Local nX 	 	   := 0
Local aAlterEnch   := {}
Local cIniCpos     := ""
Local cFieldOk     := "AllwaysTrue"
Local cSuperDel    := ""
Local cDelOk       := "AllwaysTrue"
Local nOpcX		   := 0
Local lInverte 	   := .F.
Local aMotBx	   := ReadMotBx()
Local aLineList    := {}
Local lMotBx       := .F.
Local bSet16
Local _oGetFil   
Private _cFil 	   := (SUBSTR(xFilial("SE2"),1,4) + "0001") 
Private _cFilVal   := (SUBSTR(xFilial("SE2"),1,4) + "0001")
Private cCadastro  := "Transfer๊ncia de tํtulos entre Filiais"
Private aYesFields := {}
Private aHeader    := {}
Private aCols      := {}
Private oDlg
Private oBrw
Private aTELA[0][0]
Private aGETS[0]
Private cMarca     := GetMark( )
Private cPerg
Private cList
Private oList
Private oVlrSelec
Private nVlrSelec  := 0
Private __aDados   := {}
Private oMarked	   := LoadBitmap(GetResources(),'LBOK')
Private oNoMarked  := LoadBitmap(GetResources(),'LBNO')
Private cCpos      := "E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_NATUREZ,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_VENCTO,E1_VENCREA,E1_VALOR,E1_HIST,E1_TITPAI"+;
                      "E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_NATUREZ,E2_FORNECE,E2_LOJA,E2_NOMFOR,E2_VENCTO,E2_VENCREA,E2_VALOR,E2_HIST,E2_TITPAI"
Private lRetorno   := .T.

For i:= 1 to len(aMotBx)
	If Substr(aMotBx[i],1,3)== "TEF"
		lMotBx := .t.
	EndIf
Next i

If !lMotBx
	Aviso('Aten็ใo','O motivo de baixa (TEF-Transferencia entre filiais) nใo cadastrado no protheus. Por favor cadastra-lo antes',{'OK'})
	Return(.f.)
EndIf

//-----------------------------------------------------
// Cria o Grupo de Pergunta no SX1 e Questiona usuario
//-----------------------------------------------------

_aPergs := {}
_aRet   := {}

//aAdd(_aPergs,{2,"Selecione a Carteira"   ,Nil,{"Pagar","Receber"},65,"",.F.})
aAdd(_aPergs,{2,"Selecione a Carteira"   ,Nil,{"Pagar"},65,"",.F.})
aAdd(_aPergs,{3, "Selecione a A็ใo", 1, {"Transfer๊ncia", "Consulta"},65,"",.F.,""})

If !ParamBox(_aPergs,"Transfer๊ncia de Tํtulos",@_aRet,,,,,,,,.T.,.T.)
	Return()
ELSE
	_cAlias := IIF("PAGAR"$Upper(_aRet[1]),"SE2","SE1") 
ENDIF

If (_aRet[2] == 1)
	IF _cAlias == "SE2"
		cPerg       := Padr("SIFINA14E2",10)
		//aYesFields := {"E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA","E2_VALOR","E2_NATUREZ"}
		aYesFields := {"E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_NATUREZ","E2_FORNECE","E2_LOJA","E2_NOMFOR","E2_VENCTO","E2_VENCREA","E2_VALOR","E2_HIST","E2_TITPAI"}
	ELSE
		cPerg       := Padr("SIFINA14E1",10)
		//aYesFields := {"E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_CLIENTE","E1_LOJA","E1_VALOR","E1_NATUREZ"}
		aYesFields := {"E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_NATUREZ","E1_CLIENTE","E1_LOJA","E1_NOMCLI","E1_VENCTO","E1_VENCREA","E1_VALOR","E1_HIST","E1_TITPAI"}
	ENDIF
	
	fCriaSx1()
	
	If !Pergunte(cPerg,.t.)
		return(.f.)
	EndIf  
	
	aOldAlias := SX3->(GetArea())
	
	SX3->( DbSetOrder(1) )
	SX3->( DbSeek(_cAlias) )
	
	cTitulos := ''
	cVirgula := ''
	aCampos  := {}
	
	Do While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == _cAlias
		If X3USO(SX3->X3_USADO).and.cNivel >= SX3->X3_NIVEL.and.SX3->X3_CONTEXT <> "V" .and. AllTrim(SX3->X3_CAMPO) $ cCpos
			cTitulos += cVirgula+'"'+AllTrim(SX3->X3_TITULO)+'"'
			cVirgula := ','
			aAdd(aCampos,{SX3->X3_CAMPO,SX3->X3_TITULO,SX3->X3_PICTURE,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		Endif
		SX3->(DbSkip())
	Enddo
	
	If !fQuery()
		MsgInfo("Nใo encontrado dados que satisfa็am aos paramentos informados.","Aviso")
		Return(.f.)
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Montagem da Tela de Consulta                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	oDlg := MSDIALOG():New(000,000, 500,900, cCadastro,,,,,,,,,.T.)
	
	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,025,025,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP
	
	oPanel1 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,120,120,.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_TOP
	
	oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,020,020,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_TOP
	
	oPanel3 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,030,030,.T.,.T. )
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
	
	oFolder := TFolder():New(121,2,{"Origem"},{},oPanel1,,,, .T., .T.,200,110)
	oFolder:Align := CONTROL_ALIGN_TOP
	
	oFolder1 := TFolder():New(121,2,{"Destino"},{},oPanel3,,,, .T., .T.,290,110)
	oFolder1:Align := CONTROL_ALIGN_ALLCLIENT
	
	INCLUI := .F.
	ALTERA := .T.
	nStyle := 0
	
	//For nId := 2 to len(__aDados[1])
	//     aadd(aLineList,__aDados[1,nId])
	//Next nId
	
	// Getdados Folder 1
	If _cAlias == "SE2"
		@ 000,oDlg:nLeft ListBox oList var cList Fields HEADER "  ","PREFIXO","NRO.TITULO","PARCELA","TIPO","NATUREZA","FORNCEDOR","LOJA","NOME FORNECEDOR","DT.VENCTO","DT.VENC.REAL","VALOR","HISTORICO","TITULO PAI" size 451,95 of oFolder:aDialogs[1] Pixel On DBLCLICK fMarca(oList)
	Else
		@ 000,oDlg:nLeft ListBox oList var cList Fields HEADER "  ","PREFIXO","NRO.TITULO","PARCELA","TIPO","NATUREZA","CLIENTE","LOJA","NOME CLIENTE","DT.VENCTO","DT.VENC.REAL","VALOR","HISTORICO","TITULO PAI" size 451,95  of oFolder:aDialogs[1] Pixel On DBLCLICK fMarca(oList)
	EndIF
	
	oList:SetArray(__aDados)
	oList:bLine := {|| {Iif(__aDados[oList:nAT,01],oMarked,oNoMarked),__aDados[oList:nAt,2],__aDados[oList:nAt,3],__aDados[oList:nAt,4],__aDados[oList:nAt,5],__aDados[oList:nAt,6],__aDados[oList:nAt,7],__aDados[oList:nAt,8],__aDados[oList:nAt,9],__aDados[oList:nAt,10],__aDados[oList:nAt,11],__aDados[oList:nAt,12],__aDados[oList:nAt,13],__aDados[oList:nAt,14]}}
	oList:bGotFocus := {|| oDesce:lActive := .T., oSobe:lActive := .F.}
	
	// Getdados Folder 2
	FillGetDados(3,_cAlias,1,,,,/*aNoFields*/,aYesFields,,,,.T.,aHeader,aCols,,,)
	
	oBrw := MsNewGetDados():New(1,1,1,1,nStyle,"AllwaysTrue", "AllwaysTrue",,,, 9999, cFieldOk, cSuperDel,cDelOk,oFolder1:aDialogs[1], aHeader, aCols)
	oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrw:oBrowse:blDblClick := {|| IIF(oBrw:oBrowse:nColPos == GdFieldPos("E2_NATUREZ",oBrw:aHeader) , xFIN14Nat(oBrw:oBrowse:nAt),) }
	oBrw:oBrowse:bGotFocus := {|| oDesce:lActive := .F., oSobe:lActive := .T.}
	
	@ 006,005 BTNBMP oDesce RESOURCE "PMSSETADOWN" SIZE 30,30 DESIGN ACTION xFIN14Mov(1) OF oPanel2
	@ 006,050 BTNBMP oSobe  RESOURCE "PMSSETAUP"   SIZE 30,30 DESIGN ACTION xFIN14Mov(2) OF oPanel2
	
	@ 009,005 SAY "Filial Destino:" OF oPanel PIXEL SIZE 038,006  
    @ 008,040 MSGET _oGetFil VAR _cFil VALID VldFilDest(_cFil) == .T. SIZE 30,08 F3 "SM0FIL" PIXEL OF oPanel

	// Seta foco no primeiro objeto
	// oMark:oBrowse:SetFocus()
	aBut := {{"DBG10",{|| fLocaliza() },"Pesquisar..(CTRL-P)","Procurar" }}
	bSet16 := SetKey(16,{||fLocaliza()})
	
	//aBut := {{"PESQUISA",{||xFIN14Psq(oMark,_cAlias,1,.t.)}, "Pesquisar..(CTRL-P)","Pesquisar"}}
	//bSet16 := SetKey(16,{||xFIN14Psq(oMark,_cAlias,1,.t.)})
	SetKey(16,bSet16)
	_oGetFil:SetFocus()
	
	oDlg:bInit	:= {|| EnchoiceBar(oDlg, {|| nOpcX:=1, IIf(oBrw:TudoOk() .and. U_VldNat() .and. Obrigatorio(aGets, aTela),oDlg:End(),nOpcX:=0)}, {||nOpcx := 0, oDlg:End()},,aBut)}
	
	oDlg:lCentered := .T.
	oDlg:Activate()
	
	If nOpcX == 1
		//Processa Transferencia
		Pergunte("FIN090", .F.)
		mv_par03 := 2
		
		Processa({|| xFIN14GRV() },"Efetuando Transfer๊ncia...")
		MsgInfo("Processamento concluido","Aviso")
		
		Pergunte("FIN050", .F.)
	Endif
Elseif (_aRet[2] == 2)
	IF SE2->(FieldPos("E2_XNUMTRF")) == 0 .or. SE2->(FieldPos("E2_XTPTRF")) == 0 .or. SE2->(FieldPos("E2_XFILDES")) == 0
		MsgStop("Para utilizar esta rotina ้ necessแria a cria็ใo dos campos E2_XNUMTRF, E2_XTPTRF e E2_XFILDES!")
	ELSE
		SIFIN14A()
	ENDIF
Endif

Return()
//***********************************************************************
//*
//*     validacao da Filial Destino
//*
//**********************************************************************
//
Static Function  VldFilDest(_cFilial)
lRetorno := .T.

If Substr(_cFilial,1,4) <> Substr(cFilAnt,1,4) 
	MsgInfo ("Entidade deve ser a mesma!","SIFINA14")   
	lRetorno := .F.
	Return(lRetorno)   
EndIf  

If  _cFil == cFilAnt 
	MsgInfo ("Filial de destino deve ser diferente da filial de origem!","SIFINA14")   
	lRetorno := .F.
	Return(lRetorno) 
EndIf 

If Substr(cFilAnt,5,4) <> '0001' .AND. Substr(_cFil,5,4) <> '0001'
	MsgInfo ("Esse tipo de transfer๊ncia entre filiais estแ restrita, procure o n๚cleo fiscal da GEFIN para realizar esse tipo de transfer๊ncia!","SIFINA14")   
	lRetorno := .F.
	Return(lRetorno) 
EndIf 

If ExistCpo("SM0",cEmpAnt+_cFil) == .F.    
	MsgInfo ("Filial inexistente!","SIFINA14")   
	lRetorno := .F.
	Return(lRetorno) 
EndIf  

Return(lRetorno)
//

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldNat    บ Autor ณ Microsiga          บ Data ณ  30/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gravacao dos Dados                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function VldNat()
Local _nPosNaturez := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_NATUREZ"}),aScan(aHeader,{|x| Alltrim(x[2])=="E1_NATUREZ"}))

lRet:= .T.

If aScan(oBrw:aCols,{|x| AllTrim(x[_nPosNaturez]) == ""}) > 0
	MsgStop("O campo de Natureza na aba DESTINO nao pode estar em branco.","Campo Obrigat๓rio")
	lRet:= .F.
Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ xSIPCOGRVบ Autor ณ Microsiga          บ Data ณ  30/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gravacao dos Dados                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function xFIN14GRV()
Local bCampo 	  := {|nCPO| Field(nCPO) }
Local aPergs 	  := {}
Local _cMotBx	  := "TEF"
Local _nOperac	  := 3
Local cNumTrf     := ""
Local nA		  := 0
Local _nPosPrefixo := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_PREFIXO"}),aScan(aHeader,{|x| Alltrim(x[2])=="E1_PREFIXO"}))
Local _nPosNum     := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_NUM"    }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_NUM"    }))
Local _nPosParcela := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_PARCELA"}),aScan(aHeader,{|x| Alltrim(x[2])=="E1_PARCELA"}))
Local _nPosTipo    := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_TIPO"   }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_TIPO"   }))
Local _nPosNaturez := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_NATUREZ"}),aScan(aHeader,{|x| Alltrim(x[2])=="E1_NATUREZ"}))
Local _nPosFornece := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_FORNECE"}),aScan(aHeader,{|x| Alltrim(x[2])=="E1_CLIENTE"}))
Local _nPosLoja    := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_LOJA"   }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_LOJA"   }))
Local _nPosNomeFor := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_NOMFOR" }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_NOMCLI" }))
Local _nPosVencto  := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_VENCTO" }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_VENCTO" }))
Local _nPosRealVen := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_VENCREA"}),aScan(aHeader,{|x| Alltrim(x[2])=="E1_VENCREA"}))
Local _nPosValor   := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_VALOR"  }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_VALOR"  }))
//Local _nPosSaldo   := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_SALDO"  }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_SALDO"  }))
Local _nPosHist    := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_HIST"   }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_HIST"   }))
Local _nPosPai     := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_TITPAI"   }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_TITPAI"   }))
Local _lEhImp      := .F.
Local _cEhImp      := GetNewPar("SI_IMPTRF", "")
Local nX           := 0
Local _cCtrl       := ";E2_FILIAL;E2_PREFIXO;E2_NUM;E2_PARCELA;E2_TIPO;E2_NATUREZ;E2_CONTAD;E2_CCD;E2_ITEMD;" + ;
                      "E2_CLVLDB;E2_FORNECE;E2_LOJA;E2_EMISSAO;E2_VENCTO;E2_VENCREA;E2_VENCORI;E2_EMIS1;" + ;
                      "E2_MOEDA;E2_VALOR;E2_ORIGEM;E2_HIST;E2_LA;E2_XNUMTRF;E2_XTPTRF;E2_XFILDES;E2_TITPAI;"
Local cQuery       := ""
Local cTab         := ""
Local cParcTtx     := ""

Private _cBanco	   := PadR("TEF",TamSX3("A6_COD")[1])
Private _cAgencia  := PadR("TEF",TamSX3("A6_AGENCIA")[1])
Private _cConta	   := PadR("TEF",TamSX3("A6_NUMCON")[1])

// Backup do TTS
lSavTTsInUse := __TTSInUse

// Ativa TTS
__TTSInUse := .T.

aCols := aClone(oBrw:aCols)

If Len(aCols) > 0

	// Ajusta tamanho mแximo da r้gua
	ProcRegua(Len(aCols))
	
	/*
	lNaturera := .t.
	
	For i:= 1 to Len(aCols)
	
	If Empty(aCols[i][_nPosNaturez])
	lNaturera := .f.
	EndIf
	
	Next i
	
	If !lNaturera
	Aviso('Aten็ใo','Existe(m) titulo(s) sem naturera informada. Nใo ้ possivel executar a transferencia.',{'OK'} )
	Return(.f.)
	EndIf
	*/
	// Verifica e cria o banco de transferencia, caso nao exista.
	
	//xFin14SA6()
	
	nRecno := 0
	
	DbSelectArea("SE2")
	_aSE2 := SE2->(DbStruct())
	
	// 11/12/2018 	| Daniel Flแvio
	// 				| Alterada forma de controle de numera็ใo pois quando havia concorr๊ncia de processo a numera็ใo
	//				| ficava a mesma para transfer๊ncias distintas
	// cNumTrf := StrZero(Val(GetMv("SI_NRTRFE2")), 6)
	If Len(aCols) > 0
	
		For nA := 1 to 120
			If GetMv("SI_NRTRFOK")
				PutMv("SI_NRTRFOK",.F.)
				cNumTrf := StrZero(Val(GetMv("SI_NRTRFE2")), 6)
				PutMv("SI_NRTRFE2", StrZero(Val(GetMv("SI_NRTRFE2")) + Len(aCols), 6))
				PutMv("SI_NRTRFOK",.T.)						
				Exit
			Else
				Sleep( 500 ) // Para o processamento por 0.5 segundo
			EndIf
		Next
		
		// Considera que houve um problema com rotina
		If Empty(cNumTrf)
			cNumTrf := StrZero(Val(GetMv("SI_NRTRFE2")), 6)
			PutMv("SI_NRTRFE2", StrZero(Val(GetMv("SI_NRTRFE2")) + Len(aCols), 6))
			PutMv("SI_NRTRFOK",.T.)
		EndIf
			
	EndIf

	// Percorre array
	DbSelectArea("SE2")
	_aSE2 := SE2->(DbStruct())
	
	For i := 1 to Len(aCols)
	
		// Mostra mensagem de processamento
		IncProc( "Processando registro "+Alltrim(cValToChar(i))+" de "+Alltrim(cValToChar(Len(aCols))) )
		
		If _cAlias == "SE2"
			
			SE2->( DbSetOrder(1) )
			
			If SE2->( DbSeek(_cFil + aCols[i,_nPosPrefixo]+aCols[i,_nPosNum]+aCols[i,_nPosParcela]+	aCols[i,_nPosTipo]+	aCols[i,_nPosFornece]+aCols[i,_nPosLoja]))
				MsgStop("Transferencia do Tํtulo: " +SE2->E2_NUM+"/"+SE2->E2_PREFIXO+"/"+SE2->E2_PARCELA+"/"+SE2->E2_FORNECE +" nใo pode ser realizada. O Mesmo jแ existe na filial destino.","Erro no processamento")
				Loop
			EndIf
			
			If SE2->( DbSeek(xFilial("SE2")+aCols[i,_nPosPrefixo]+aCols[i,_nPosNum]+aCols[i,_nPosParcela]+	aCols[i,_nPosTipo]+	aCols[i,_nPosFornece]+aCols[i,_nPosLoja]))
				
				nRecno := SE2->(RECNO())
				
				_nInss    := SE2->E2_INSS
				
				SED->(dbSetOrder(1))
				IF SED->(dbSeek(XFilial("SED")+SE2->E2_NATUREZ)) .and. SED->(FieldPos("ED_DEDINSS")) > 0
					//IF SED->ED_DEDINSS == "2"  //Nao desconta o INSS do principal
					IF SED->ED_DEDINSS == "1"  //Nao desconta o INSS do principal
						_nInss := 0
					Endif
				ENDIF
				
				SA2->(dbSetOrder(1))
				SA2->(dbSeek(XFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)))
				
				//Controla o Pis Cofins e Csll na baixa
				lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
				!Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
				!Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
				!Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )
				
				// Controla IRPF na Baixa
				lIRPFBaixa := IIf( ! Empty( SA2->( FieldPos( "A2_CALCIRF" ) ) ), SA2->A2_CALCIRF == "2", .F.) .And. ;
				!Empty( SE2->( FieldPos( "E2_VRETIRF" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETIRF" ) ) ) .And. ;
				!Empty( SE5->( FieldPos( "E5_VRETIRF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETIRF" ) ) )
				
				lCalcIssBx :=	!Empty( SE5->( FieldPos( "E5_VRETISS" ) ) ) .and. !Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .and. ;
				!Empty( SE2->( FieldPos( "E2_TRETISS" ) ) ) .and. GetNewPar("MV_MRETISS","1") == "2"  //Retencao do ISS pela emissao (1) ou baixa (2)
				
				// Pessoa Fisica sempre retem na emissao
				IF SA2->A2_TIPO == "F"
					lCalcIssBx := .F.
				ENDIF
				
				//_nTotal := SE2->E2_VALOR+If(lIRPFBaixa,0,SE2->E2_IRRF)-If(lCalcIssBx,SE2->E2_ISS,0)+_nInss+SE2->(E2_RETENC+E2_SEST)+IIF(lPccBaixa,0,SE2->(E2_PIS+E2_COFINS+E2_CSLL))
				_nTotal := SE2->E2_VALOR + ;
				           If(lIRPFBaixa,SE2->E2_IRRF,0) - ;
				           If(lCalcIssBx,SE2->E2_ISS,0) + ;
				           _nInss + ;
				           SE2->(E2_RETENC+E2_SEST) + ;
				           IIF(lPccBaixa,SE2->(E2_PIS+E2_COFINS+E2_CSLL),0) + ;
				           SE2->E2_ACRESC - ;
				           SE2->E2_DECRESC
				
				
				_cHist:="Transferencia de Titulo"
				
				aStru := {}
				DbSelectArea("SE2")
				
				For nX := 1 To FCount()
				  aAdd(aStru, {FieldName(nX), SE2->&(FieldName(nX)), Nil})
				Next nX
				
				aAdd(aStru, {"AUTVLRPG"  , _nTotal              , Nil})
				aAdd(aStru, {"AUTMOTBX"  , _cMotBx              , Nil})
				aAdd(aStru, {"AUTBANCO"  , _cBanco              , Nil})
				aAdd(aStru, {"AUTAGENCIA", _cAgencia            , Nil})
				aAdd(aStru, {"AUTCONTA"  , _cConta              , Nil})
				aAdd(aStru, {"AUTDTBAIXA", dDataBase            , Nil})
				aAdd(aStru, {"AUTDTDEB"  , DataValida(dDataBase), Nil})
				aAdd(aStru, {"AUTHIST"   , _cHist               , Nil})
				
				lMsErroAuto    := .F.
				lMsHelpAuto    := .T.
				
				Begin Transaction
				
				MSExecAuto( { | x, y | FINA080( x, y ) }, aStru, _nOperac )
				
				If lMsErroAuto
					DisarmTransaction()
					MostraErro()
					MsgStop("Baixa do Tํtulo: " +SE2->E2_NUM+"/"+SE2->E2_PREFIXO+"/"+SE2->E2_PARCELA+"/"+SE2->E2_FORNECE +" nใo pode ser realizada","Erro no processamento")
					Break
				Else
					//Efetua a Inclusao na Filial Destino
					SE2->(dbGoTo(nRecno))
					
					cQuery := "SELECT" + CRLF
					cQuery += "ISNULL(CAST(MAX(E2_PARCELA) AS INTEGER), 1) [E2_PARCELA]" + CRLF
					cQuery += "FROM " + RetSQLName("SE2") + "" + CRLF
					cQuery += "WHERE E2_FILIAL = '" + _cFil + "'" + CRLF
					cQuery += "AND E2_PREFIXO = 'TTX'" + CRLF
					cQuery += "AND E2_NUM = '" + SE2->E2_NUM + "'" + CRLF
					cQuery += "AND E2_TIPO = '" + SE2->E2_TIPO + "'" + CRLF
					cQuery += "AND E2_FORNECE = '" + SE2->E2_FORNECE + "'" + CRLF
					cQuery += "AND E2_LOJA = '" + SE2->E2_LOJA + "'" + CRLF
					cQuery += "AND D_E_L_E_T_ = ''"
					
					cQuery := ChangeQuery(cQuery)
					
					cTab   := GetNextAlias()
					
					TcQUERY cQuery NEW ALIAS ((cTab))
					
					DbSelectArea((cTab))
					(cTab)->(DbGoTop())
					
					cParcTtx  := ""
					
					While ((cTab)->(!Eof()))
					  cParcTtx := Iif((cTab)->(E2_PARCELA) == 0, "001", StrZero((cTab)->(E2_PARCELA) + 1, 3))
					
					  (cTab)->(DbSkip())
					Enddo
					
					(cTab)->(DbCloseArea())
					
					_lEhImp := ";" + AllTrim(SE2->E2_TIPO) + ";" $ _cEhImp
					
					IF SE2->(FieldPos("E2_XNUMTRF")) > 0 .and. SE2->(FieldPos("E2_XTPTRF")) > 0 .and. SE2->(FieldPos("E2_XFILDES")) > 0
						RecLock("SE2", .F.)
						SE2->E2_XNUMTRF := cNumTrf
						SE2->E2_XTPTRF  := "1"
						SE2->E2_XFILDES := _cFil
						SE2->(MsUnlock())
					ENDIF
					
					_cFilBkp:= cFilAnt
					cFilAnt := _cFil
					aStru 	:= {}
					
					cHistSE2:= "TRF."+SE2->E2_HIST //"SIFINA14-Transferencia de Titulos"
					
					aStru := {}
 					DbSelectArea("SE2")
				
					For nX := 1 To FCount()
					  If (";" + FieldName(nX) + ";" $ _cCtrl)
					    If (FieldName(nX) == "E2_FILIAL")
					      aAdd(aStru, {FieldName(nX), cFilAnt, Nil})
					    Elseif (FieldName(nX) == "E2_PREFIXO")
					      aAdd(aStru, {FieldName(nX), Iif(_lEhImp, "TTX", SE2->E2_PREFIXO), Nil})
					    Elseif (FieldName(nX) == "E2_PARCELA")
					      aAdd(aStru, {FieldName(nX), Iif(_lEhImp, cParcTtx, SE2->E2_PARCELA), Nil})
					    Elseif (FieldName(nX) == "E2_NATUREZ")
					      aAdd(aStru, {FieldName(nX), aCols[i][_nPosNaturez], Nil})
					    Elseif (FieldName(nX) == "E2_VALOR")
					      aAdd(aStru, {FieldName(nX), _nTotal, Nil})
					    Elseif (FieldName(nX) == "E2_ORIGEM")
					      aAdd(aStru, {FieldName(nX), "FINA050", Nil})
					    Elseif (FieldName(nX) == "E2_HIST")
					      aAdd(aStru, {FieldName(nX), cHistSE2, Nil})
					    Elseif (FieldName(nX) == "E2_LA")
					      aAdd(aStru, {FieldName(nX), "S", Nil})
					    Elseif (FieldName(nX) == "E2_XNUMTRF")
					      aAdd(aStru, {FieldName(nX), cNumTrf, Nil})
					    Elseif (FieldName(nX) == "E2_XTPTRF")
					      aAdd(aStru, {FieldName(nX), "2", Nil})
					    Elseif (FieldName(nX) == "E2_XFILDES")
					      aAdd(aStru, {FieldName(nX), _cFilBkp, Nil})
					    Elseif (FieldName(nX) == "E2_TITPAI")
					      aAdd(aStru, {FieldName(nX), "", Nil})
					    Else
					      aAdd(aStru, {FieldName(nX), SE2->&(FieldName(nX)), Nil})
					    Endif
					  Endif
					Next nX
					
					/*aAdd(aStru    , {'E2_FILIAL ', cFilant		                       , NIL})
					aAdd(aStru    , {'E2_PREFIXO', Iif(_lEhImp, "TTX", SE2->E2_PREFIXO), NIL})
					aAdd(aStru    , {'E2_NUM    ', SE2->E2_NUM	                       , NIL})
					aAdd(aStru    , {'E2_PARCELA', SE2->E2_PARCELA                     , NIL})
					aAdd(aStru    , {'E2_TIPO   ', SE2->E2_TIPO                        , NIL})
					aAdd(aStru    , {'E2_NATUREZ', aCols[i][_nPosNaturez]              , NIL})
					AADD(aStru    , {'E2_CCD'	 , SE2->E2_CCD	                       , Nil})
					AADD(aStru    , {'E2_ITEMD'	 , SE2->E2_ITEMD                       , Nil})
					AADD(aStru    , {'E2_CLVLDB' , SE2->E2_CLVLDB                      , Nil})
					aAdd(aStru    , {'E2_FORNECE', SE2->E2_FORNECE                     , NIL})
					aAdd(aStru    , {'E2_LOJA   ', SE2->E2_LOJA                        , NIL})
					AADD(aStru    , {'E2_EMISSAO', SE2->E2_EMISSAO                     , NIL})
					AADD(aStru    , {'E2_VENCTO' , SE2->E2_VENCTO                      , NIL})
					AADD(aStru    , {'E2_VENCREA', SE2->E2_VENCREA                     , NIL})
					AADD(aStru    , {'E2_VENCORI', SE2->E2_VENCORI                     , NIL})
					AADD(aStru    , {'E2_EMIS1'  , SE2->E2_EMIS1                       , NIL})
					AADD(aStru    , {'E2_MOEDA'  ,  SE2->E2_MOEDA                      , NIL})
					AADD(aStru    , {'E2_VALOR'  ,  _nTotal	                           , NIL})
					AADD(aStru    , {'E2_ORIGEM' , "FINA050"  	                       , NIL})
					AADD(aStru    , {'E2_HIST'   , cHistSE2                            , NIL})
					AADD(aStru    , {'E2_LA'     , "S"	                               , NIL})
					IF SE2->(FieldPos("E2_XNUMTRF")) > 0
						AADD(aStru, {'E2_XNUMTRF', cNumTrf      	                   , Nil})
					ENDIF
					IF SE2->(FieldPos("E2_XTPTRF")) > 0
						AADD(aStru, {'E2_XTPTRF' , "2"		                           , Nil})
					ENDIF
					IF SE2->(FieldPos("E2_XFILDES")) > 0
						AADD(aStru, {'E2_XFILDES', _cFilBkp	                           , Nil})
					ENDIF*/
					
					lMsErroAuto    := .F.
					
					MSExecAuto({|x,y,z| Fina050(x,y,z)},aStru,3 )
					
					If lMsErroAuto
						DisarmTransaction()
						MostraErro()
						Break
					Endif
					
					cFilAnt := _cFilBkp
					
					// Incrementa variแvel
					cNumTrf := Soma1(cNumTrf)
					
				EndIf
				
				End Transaction
				
			EndIf
		EndIf
	Next
Endif
// Restaura TTS
__TTSInUse := lSavTTsInUse

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณxFIN14Nat บAutor  ณMicrosiga           บ Data ณ  28/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Selecao na natureza                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function xFIN14Nat(_nRow)

Local _cCpoNat := IIF(_cAlias == "SE2","E2_NATUREZ","E1_NATUREZ")
Local _nPosNat := GdFieldPos(_cCpoNat,oBrw:aHeader)

// Verifica se estแ posicionado na campo de natureza
IF oBrw:oBrowse:nColPos <> _nPosNat
	Return()
ENDIF

// Verifica se existe titulo
IF Empty( GdFieldGet("E2_NUM",oBrw:oBrowse:nAt,,oBrw:aHeader,oBrw:aCols) )
	Return()
ENDIF

// Backup da filial corrente
_cFilBkp := cFilAnt

// Altera para a filial destino
cFilAnt  := _cFil

// Pesquisa natureza na filial destino
ConPad1(,,,"SED",,,.F.)

// Restaura filial
cFilAnt := _cFilBkp

// Atualizacao do campo
GDFieldPut(_cCpoNat,SED->ED_CODIGO,oBrw:oBrowse:nAt,oBrw:aHeader,oBrw:aCols)
oBrw:oBrowse:Refresh()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณxFIN14Mov บAutor  ณMicrosiga           บ Data ณ  28/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Movimentacao do titulo                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xFIN14Mov(_nOper)
Local _nPosPrefixo := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_PREFIXO"}),aScan(aHeader,{|x| Alltrim(x[2])=="E1_PREFIXO"}))
Local _nPosNum     := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_NUM"    }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_NUM"    }))
Local _nPosParcela := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_PARCELA"}),aScan(aHeader,{|x| Alltrim(x[2])=="E1_PARCELA"}))
Local _nPosTipo    := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_TIPO"   }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_TIPO"   }))
Local _nPosNaturez := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_NATUREZ"}),aScan(aHeader,{|x| Alltrim(x[2])=="E1_NATUREZ"}))
Local _nPosFornece := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_FORNECE"}),aScan(aHeader,{|x| Alltrim(x[2])=="E1_CLIENTE"}))
Local _nPosLoja    := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_LOJA"   }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_LOJA"   }))
Local _nPosNomeFor := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_NOMFOR" }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_NOMCLI" }))
Local _nPosVencto  := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_VENCTO" }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_VENCTO" }))
Local _nPosRealVen := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_VENCREA"}),aScan(aHeader,{|x| Alltrim(x[2])=="E1_VENCREA"}))
Local _nPosValor   := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_VALOR"  }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_VALOR"  }))
Local _nPosHist    := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_HIST"   }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_HIST"   }))
Local _nPosPai     := Iif(_cAlias=="SE2",aScan(aHeader,{|x| Alltrim(x[2])=="E2_TITPAI" }),aScan(aHeader,{|x| Alltrim(x[2])=="E1_TITPAI" }))
Local aDelete1     := {}
Local nDelete      := 0
LOcal x            := 0

If _nOper == 1
	
	If len(__aDados) < 1
		Aviso('Aten็ใo','Nใo hแ titulo para ser transferido.',{'OK'})
		return(.f.)
	EndIf
	
	
	If !Empty(_cFil)
		
		If Aviso("Aten็ใo","Confirma transfer๊ncia do(s) tํtulo(s) selecionado(s) ?",{"Sim","Nใo"}) <> 1
			Return()
		EndIf
		
		aCols := {}
		nId:= 1
		
		Do While nId <= Len(__aDados)
			
			If __aDados[nId][1] <> .f.
				
				(_cAlias)->( dbGoTo(__aDados[nId][len(__aDados[nId])]) )
				
				aAdd(aCols,Array(Len(aHeader)+1))
				nLen:= Len(aCols)
				
				_cNatTRF := Space(Len(SE2->E2_NATUREZ))
				IF SED->(FieldPos("ED_XNATTRF")) > 0
					SED->(dbSetOrder(1))
					IF SED->(dbSeek(XFilial("SED")+IIF(_cAlias == "SE2",SE2->E2_NATUREZ,SE1->E1_NATUREZ)))
						_cNatTRF := SED->ED_XNATTRF
					ENDIF
				ENDIF
				
				If _cAlias == "SE2"
					aCols[nLen,_nPosPrefixo] := SE2->E2_PREFIXO
					aCols[nLen,_nPosNum]     := SE2->E2_NUM
					aCols[nLen,_nPosParcela] := SE2->E2_PARCELA
					aCols[nLen,_nPosTipo]    := SE2->E2_TIPO
					aCols[nLen,_nPosNaturez] := _cNatTRF
					aCols[nLen,_nPosFornece] := SE2->E2_FORNECE
					aCols[nLen,_nPosLoja]    := SE2->E2_LOJA
					aCols[nLen,_nPosNomeFor] := SE2->E2_NOMFOR
					aCols[nLen,_nPosVencto]  := SE2->E2_VENCTO
					aCols[nLen,_nPosRealVen] := SE2->E2_VENCREA
					aCols[nLen,_nPosValor]   := SE2->E2_VALOR
					aCols[nLen,_nPosHist]    := SE2->E2_HIST
					aCols[nLen,_nPosPai]     := SE2->E2_TITPAI
				Else
					aCols[nLen,_nPosPrefixo] := SE1->E1_PREFIXO
					aCols[nLen,_nPosNum]     := SE1->E1_NUM
					aCols[nLen,_nPosParcela] := SE1->E1_PARCELA
					aCols[nLen,_nPosTipo]    := SE1->E1_TIPO
					aCols[nLen,_nPosNaturez] := _cNatTRF
					aCols[nLen,_nPosFornece] := SE1->E1_CLIENTE
					aCols[nLen,_nPosLoja]    := SE1->E1_LOJA
					aCols[nLen,_nPosNomeFor] := SE1->E1_NOMCLI
					aCols[nLen,_nPosVencto]  := SE1->E1_VENCTO
					aCols[nLen,_nPosRealVen] := SE1->E1_VENCREA
					aCols[nLen,_nPosValor]   := SE1->E1_VALOR
					aCols[nLen,_nPosHist]    := SE1->E1_HIST
					aCols[nLen,_nPosPai]     := SE1->E1_TITPAI
				EndIf
				
				aCols[nLen,Len(aHeader)] := __aDados[nId][len(__aDados[nId])]
				
				aCols[Len(aCols),Len(aHeader)+1] := .F.
				
				aLinha := aClone(aCols[len(aCols)])
				oBrw:oBrowse:nAt := 1
				If len(oBrw:aCols) > 0 .and.Empty(oBrw:aCols[1][_nPosNum])
					oBrw:aCols[1]:= aclone(aLinha)
				ElseIf len(oBrw:aCols) > 0
					aColsBk := aClone(oBrw:aCols)
					aadd(aColsBk,aClone(aLinha))
					oBrw:aCols:= aclone(aColsBk)
				Else
					aColsBk := {}
					aadd(aColsBk,array(Len(aHeader)+1))
					aColsBk[1] := aclone(aLinha)
					oBrw:aCols := aclone(aColsBk)
				EndIf
				oBrw:oBrowse:Refresh()
			EndIf
			
			nId++
			
		EndDo
		
		nId:= Len(__aDados)
		
		Do While nId > 0
			If __aDados[nId][1] <> .f.
				
				If (oList:nAT >= Len(__aDados))
					oList:nAt := Len(__aDados) - 1
				Endif
				
				aDel(__aDados,nId)
				aSize(__aDados,Len(__aDados)-1)
				oList:SetArray(__aDados)
				oList:bLine := {|| {Iif(__aDados[oList:nAT,01],oMarked,oNoMarked),__aDados[oList:nAt,2],__aDados[oList:nAt,3],__aDados[oList:nAt,4],__aDados[oList:nAt,5],__aDados[oList:nAt,6],__aDados[oList:nAt,7],__aDados[oList:nAt,8],__aDados[oList:nAt,9],__aDados[oList:nAt,10],__aDados[oList:nAt,11],__aDados[oList:nAt,12],__aDados[oList:nAt,13],__aDados[oList:nAt,14]}}
				oList:Refresh()
				
			EndIf
			nId--
		EndDo
		
	Else
		MsgStop("Selecione a Filial de destino!","Opera็ใo nใo permitida")
	Endif
	
Else // Estorna
	
	If oBrw:oBrowse:nAt < 1 .or. Empty(oBrw:aCols[1,_nPosNum])
		Aviso('Aten็ใo','Nใo hแ titulo para ser estornado.',{'OK'})
		return(.f.)
	EndIf
	
	If Aviso("Atencao","Confirma estorno do tํtulo posicionado ?",{"Sim","Nใo"}) == 1
		
		aLinha := {}
		aadd(aLinha,.f.)
		
		If _cAlias == "SE2"
			
			SE2->( dbGoTo(oBrw:aCols[oBrw:oBrowse:nAt,Len(aHeader)]) )
			
			//(_cAlias)->( DbSetOrder(1) )
			
			//If (_cAlias)->( DbSeek(xFilial(_cAlias) +;
			///	oBrw:aCols[oBrw:oBrowse:nAt,_nPosPrefixo]+;
			//	oBrw:aCols[oBrw:oBrowse:nAt,_nPosNum]+;
			//	oBrw:aCols[oBrw:oBrowse:nAt,_nPosParcela]+;
			//	oBrw:aCols[oBrw:oBrowse:nAt,_nPosTipo]+;
			//	oBrw:aCols[oBrw:oBrowse:nAt,_nPosFornece]+;
			//	oBrw:aCols[oBrw:oBrowse:nAt,_nPosLoja]))
			
			
			aadd(aLinha,SE2->E2_PREFIXO) // 02
			aadd(aLinha,SE2->E2_NUM)     // 03
			aadd(aLinha,SE2->E2_PARCELA) // 04
			aadd(aLinha,SE2->E2_TIPO)    // 05
			aadd(aLinha,SE2->E2_NATUREZ) // 06
			aadd(aLinha,SE2->E2_FORNECE) // 07
			aadd(aLinha,SE2->E2_LOJA)    // 08
			aadd(aLinha,SE2->E2_NOMFOR)  // 09
			aadd(aLinha,SE2->E2_VENCTO)  // 10
			aadd(aLinha,SE2->E2_VENCREA) // 11
			aadd(aLinha,SE2->E2_VALOR)   // 12
			//				aadd(aLinha,SE2->E2_SALDO)
			aadd(aLinha,SE2->E2_HIST)    // 13
			aadd(aLinha,SE2->E2_TITPAI)    // 14
			aadd(aLinha,oBrw:aCols[oBrw:oBrowse:nAt,Len(aHeader)])
			
			aadd(__aDados,aLinha)
			
			If (oList:nAT <= 0)
				oList:nAt := 1
			Endif
			
			oList:SetArray(__aDados)
			oList:bLine := {|| {Iif(__aDados[oList:nAT,01],oMarked,oNoMarked),__aDados[oList:nAt,2],__aDados[oList:nAt,3],__aDados[oList:nAt,4],__aDados[oList:nAt,5],__aDados[oList:nAt,6],__aDados[oList:nAt,7],__aDados[oList:nAt,8],__aDados[oList:nAt,9],__aDados[oList:nAt,10],__aDados[oList:nAt,11],__aDados[oList:nAt,12],__aDados[oList:nAt,13],__aDados[oList:nAt,14]}}
			oList:Refresh()
			
			aDel(oBrw:aCols,oBrw:oBrowse:nAt)
			aSize(oBrw:aCols,Len(oBrw:aCols)-1)
			
			//EndIf
			
		Else
			
			SE2->( dbGoTo(oBrw:aCols[oBrw:oBrowse:nAt,Len(aHeader)]) )
			//(_cAlias)->( DbSetOrder(1) )
			
			//If (_cAlias)->( DbSeek(xFilial(_cAlias) +;
			//	oBrw:aCols[oBrw:oBrowse:nAt,_nPosPrefixo]+;
			//	oBrw:aCols[oBrw:oBrowse:nAt,_nPosNum]+;
			//	oBrw:aCols[oBrw:oBrowse:nAt,_nPosParcela]+;
			//	oBrw:aCols[oBrw:oBrowse:nAt,_nPosTipo]))
			
			
			aadd(aLinha,SE1->E1_PREFIXO)      // 02
			aadd(aLinha,SE1->E1_NUM)          // 03
			aadd(aLinha,SE1->E1_PARCELA)      // 04
			aadd(aLinha,SE1->E1_TIPO)         // 05
			aadd(aLinha,SE1->E1_NATUREZ)      // 06
			aadd(aLinha,SE1->E1_CLIENTE)      // 07
			aadd(aLinha,SE1->E1_LOJA)         // 08
			aadd(aLinha,SE1->E1_NOMCLI)       // 09
			aadd(aLinha,SE1->E1_VENCTO)       // 10
			aadd(aLinha,SE1->E1_VENCREA)      // 11
			aadd(aLinha,SE1->E1_VALOR)        // 12
			//				aadd(aLinha,SE1->E1_SALDO)         //
			aadd(aLinha,SE1->E1_HIST)         // 13
			aadd(aLinha,SE1->E1_TITPAI)       // 14
			aadd(aLinha,oBrw:aCols[oBrw:oBrowse:nAt,Len(aHeader)])//14
			
			aadd(__aDados,aLinha)
			oList:SetArray(__aDados)
			oList:bLine := {|| {Iif(__aDados[oList:nAT,01],oMarked,oNoMarked),__aDados[oList:nAt,2],__aDados[oList:nAt,3],__aDados[oList:nAt,4],__aDados[oList:nAt,5],__aDados[oList:nAt,6],__aDados[oList:nAt,7],__aDados[oList:nAt,8],__aDados[oList:nAt,9],__aDados[oList:nAt,10],__aDados[oList:nAt,11],__aDados[oList:nAt,12],__aDados[oList:nAt,13],__aDados[oList:nAt,14]}}
			oList:Refresh()
			
			aDel(oBrw:aCols,oBrw:oBrowse:nAt)
			aSize(oBrw:aCols,Len(oBrw:aCols)-1)
			
			//EndIf
			
		EndIf
	EndIf
EndIf
oBrw:oBrowse:Refresh()
oList:Refresh()
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFINA14  บAutor  ณMicrosiga           บ Data ณ  12/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xFIN14Psq(oMark,cAliasSE2,nIndice)
Local nRecno		:= 0
Local aPesqui		:={}
Local cOrdSix		:= "123456789ABCDEFGHIJKLMNOPQRSTUVXWYZ"
Local cIndice		:= Substr(cOrdSix,nIndice,1)
Local cSeek 		:= ""
Local cAliasAnt		:= Alias()
Local nOrdInd		:= IndexOrd()
Local cRecSE2 	 	:= ""
Local lAchou 		:= .F.
lOCAL cRecSE2Tmp

dbSelectArea(cAliasSE2)
nRecno  := Recno()
cCampos := (cAliasSE2)->(IndexKey())

//Verifico se a filial estแ contida na chave
If "_FILIAL" $ cCampos
	cSeek := xFilial("SE2")
Endif

SIX->(DbSeek("SE2"+cIndice))
aAdd(aPesqui,{SIX->DESCRICAO,0})

// Obtem os campos de pesquisa de cAlias, para pesquisar no TRB, pois
// os indice do TRB eh unico (FILIAL+PREFIXO+NUMERO+PARCELA+TIPO) e em
// AxPesqui, o usuario pode escolher a chave desejada.
cCampos := "(" + cAliasSE2 + ")->(" + cCampos + ")"

WndxPesqui(oMark:oBrowse,aPesqui,cSeek,.F.)

SE2->( DbSetOrder(1))
SE2->( DbSeek(xFilial('SE2')+cSeek))

oMark:oBrowse:Refresh(.T.)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณxFIN14SA6 บAutor  ณMicrosiga           บ Data ณ  02/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica existencia do banco                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11 - SISTEMA INDUSTRIA                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xFIN14SA6()

Local _cArea    := GetArea()
Local _cAreaSA6 := SA6->(GetArea())

SA6->(dbSetOrder(1))

IF !SA6->(dbSeek(XFilial("SA6")+_cBanco+_cAgencia+_cConta))
	// Inclui banco automaticamente
	
	RecLock("SA6",.t.)
	
	SA6->A6_FILIAL := XFilial("SA6")
	SA6->A6_COD    :=_cBanco
	SA6->A6_AGENCIA	:= _cAgencia
	SA6->A6_NUMCON	:= _cConta
	SA6->(msUnlock())
	
ENDIF

RestArea(_cArea)
RestArea(_cAreaSA6)

Return()

Static function fVal(cMarca,oMark)

Local x
Local lRet := .t.

SE2->( RecLock(.f.))

If SE2->E2_OK == cMarca
	SE2->E2_OK := ''
Else
	SE2->E2_OK := cMarca
EndIf

SE2->( MsUnLock() )

Return(lRet)
//-----------------------------------------------------------
// Grupo de Perguntas
//-----------------------------------------------------------
Static Function fCriaSx1()

Local nId      := 0
Local aPerg    := {}
Local cCarteira:= iif(_cAlias == "SE2","P","R")

SX1->( DbSetOrder(1) )
                                                           
If  _cAlias == "SE2"
	aadd(aPerg,{"01","Prefixo de          ","mv_ch1","C",TAMSX3("E2_PREFIXO")[1]	,TAMSX3("E2_PREFIXO")[2]	,00,"G","","mv_par01","ZY", "", "", ""})
	aadd(aPerg,{"02","Prefixo at้         ","mv_ch2","C",TAMSX3("E2_PREFIXO")[1]	,TAMSX3("E2_PREFIXO")[2]	,00,"G","","mv_par02","ZY", "", "", ""})
	aadd(aPerg,{"03","Nro titulo de       ","mv_ch3","C",TAMSX3("E2_NUM")[1]		,TAMSX3("E2_NUM")[2]		,00,"G","","mv_par03","SE2", "", "", ""})
	aadd(aPerg,{"04","Nro titulo at้      ","mv_ch4","C",TAMSX3("E2_NUM")[1]		,TAMSX3("E2_NUM")[2]		,00,"G","","mv_par04","SE2", "", "", ""})
	aadd(aPerg,{"05","Parcela de          ","mv_ch5","C",TAMSX3("E2_PARCELA")[1]	,TAMSX3("E2_PARCELA")[2]	,00,"G","","mv_par05","", "", "", ""})
	aadd(aPerg,{"06","Parcela at้         ","mv_ch6","C",TAMSX3("E2_PARCELA")[1]	,TAMSX3("E2_PARCELA")[2]	,00,"G","","mv_par06","", "", "", ""})
	aadd(aPerg,{"07","Tipo de             ","mv_ch7","C",TAMSX3("E2_TIPO")[1]		,TAMSX3("E2_TIPO")[2]		,00,"G","","mv_par07","05", "", "", ""})
	aadd(aPerg,{"08","Tipo at้            ","mv_ch8","C",TAMSX3("E2_TIPO")[1]		,TAMSX3("E2_TIPO")[2]		,00,"G","","mv_par08","05", "", "", ""})
	aadd(aPerg,{"09","Fornecedor de       ","mv_ch9","C",TAMSX3("E2_FORNECE")[1]	,TAMSX3("E2_FORNECE")[2]	,00,"G","","mv_par09","SA2", "", "", ""})
	aadd(aPerg,{"10","Fornecedor at้      ","mv_chA","C",TAMSX3("E2_FORNECE")[1]	,TAMSX3("E2_FORNECE")[2]	,00,"G","","mv_par10","SA2", "", "", ""})
	aadd(aPerg,{"11","Loja de             ","mv_chB","C",TAMSX3("E2_LOJA")[1]		,TAMSX3("E2_LOJA")[2]		,00,"G","","mv_par11","SA2", "", "", ""})
	aadd(aPerg,{"12","Loja at้            ","mv_chC","C",TAMSX3("E2_LOJA")[1]		,TAMSX3("E2_LOJA")[2]		,00,"G","","mv_par12","SA2", "", "", ""})
	aadd(aPerg,{"13","Valor de            ","mv_chE","N",TAMSX3("E2_VALOR")[1]		,TAMSX3("E2_VALOR")[2]		,00,"G","","mv_par13",""   , "", "", ""})
	aadd(aPerg,{"14","Valor at้           ","mv_chF","N",TAMSX3("E2_VALOR")[1]		,TAMSX3("E2_VALOR")[2]		,00,"G","","mv_par14",""   , "", "", ""})
	aadd(aPerg,{"15","Natureza de         ","mv_chG","C",TAMSX3("E2_NATUREZ")[1]	,TAMSX3("E2_NATUREZ")[2]	,00,"G","","mv_par15","SB1", "", "", ""})
	aadd(aPerg,{"16","Natureza at้        ","mv_chH","C",TAMSX3("E2_NATUREZ")[1]	,TAMSX3("E2_NATUREZ")[2]	,00,"G","","mv_par16","SED", "", "", ""})
	aadd(aPerg,{"17","Vencimento de       ","mv_chI","D",TAMSX3("E2_VENCTO")[1]	,TAMSX3("E2_VENCTO")[2]		,00,"G","","mv_par17",""   , "", "", ""})
	aadd(aPerg,{"18","Vencimento at้      ","mv_chJ","D",TAMSX3("E2_VENCTO")[1]	,TAMSX3("E2_VENCTO")[2]		,00,"G","","mv_par18",""   , "", "", ""})	
Else
	aadd(aPerg,{"01","Prefixo de          ","mv_ch1","C",TAMSX3("E1_PREFIXO")[1]	,TAMSX3("E1_PREFIXO")[2]	,00,"G","","mv_par01","", "", "", ""})
	aadd(aPerg,{"02","Prefixo at้         ","mv_ch2","C",TAMSX3("E1_PREFIXO")[1]	,TAMSX3("E1_PREFIXO")[2]	,00,"G","","mv_par02","", "", "", ""})
	aadd(aPerg,{"03","Nro titulo de       ","mv_ch3","C",TAMSX3("E1_NUM")[1]		,TAMSX3("E1_NUM")[2]		,00,"G","","mv_par03","SE1", "", "", ""})
	aadd(aPerg,{"04","Nro titulo at้      ","mv_ch4","C",TAMSX3("E1_NUM")[1]		,TAMSX3("E1_NUM")[2]		,00,"G","","mv_par04","SE1", "", "", ""})
	aadd(aPerg,{"05","Parcela de          ","mv_ch5","C",TAMSX3("E1_PARCELA")[1]	,TAMSX3("E1_PARCELA")[2]	,00,"G","","mv_par05","", "", "", ""})
	aadd(aPerg,{"06","Parcela at้         ","mv_ch6","C",TAMSX3("E1_PARCELA")[1]	,TAMSX3("E1_PARCELA")[2]	,00,"G","","mv_par06","", "", "", ""})
	aadd(aPerg,{"07","Tipo de             ","mv_ch7","C",TAMSX3("E1_TIPO")[1]		,TAMSX3("E1_TIPO")[2]		,00,"G","","mv_par07","05", "", "", ""})
	aadd(aPerg,{"08","Tipo at้            ","mv_ch8","C",TAMSX3("E1_TIPO")[1]		,TAMSX3("E1_TIPO")[2]		,00,"G","","mv_par08","05", "", "", ""})
	aadd(aPerg,{"09","Cliente de	       ","mv_ch9","C",TAMSX3("E1_FORNECE")[1]	,TAMSX3("E1_FORNECE")[2]	,00,"G","","mv_par09","SA1", "", "", ""})
	aadd(aPerg,{"10","Cliente at้	      ","mv_chA","C",TAMSX3("E1_FORNECE")[1]	,TAMSX3("E1_FORNECE")[2]	,00,"G","","mv_par10","SA1", "", "", ""})
	aadd(aPerg,{"11","Loja de             ","mv_chB","C",TAMSX3("E1_LOJA")[1]		,TAMSX3("E1_LOJA")[2]		,00,"G","","mv_par11","SA1", "", "", ""})
	aadd(aPerg,{"12","Loja at้            ","mv_chC","C",TAMSX3("E1_LOJA")[1]		,TAMSX3("E1_LOJA")[2]		,00,"G","","mv_par12","SA1", "", "", ""})
	aadd(aPerg,{"13","Valor de            ","mv_chE","N",TAMSX3("E1_VALOR")[1]		,TAMSX3("E1_VALOR")[2]		,00,"G","","mv_par13",""   , "", "", ""})
	aadd(aPerg,{"14","Valor at้           ","mv_chF","N",TAMSX3("E1_VALOR")[1]		,TAMSX3("E1_VALOR")[2]		,00,"G","","mv_par14",""   , "", "", ""})
	aadd(aPerg,{"15","Natureza de         ","mv_chG","C",TAMSX3("E1_NATUREZ")[1]	,TAMSX3("E1_NATUREZ")[2]	,00,"G","","mv_par15","SB1", "", "", ""})
	aadd(aPerg,{"16","Natureza at้        ","mv_chH","C",TAMSX3("E1_NATUREZ")[1]	,TAMSX3("E1_NATUREZ")[2]	,00,"G","","mv_par16","SED", "", "", ""})
	aadd(aPerg,{"17","Vencimento de       ","mv_chI","D",TAMSX3("E1_VENCTO")[1]	,TAMSX3("E1_VENCTO")[2]		,00,"G","","mv_par17",""   , "", "", ""})
	aadd(aPerg,{"18","Vencimento at้      ","mv_chJ","D",TAMSX3("E1_VENCTO")[1]	,TAMSX3("E1_VENCTO")[2]		,00,"G","","mv_par18",""   , "", "", ""})	
EndIf


For nId := 01 to len(aPerg)
	
	If SX1->(!DbSeek(cPerg + aPerg[nId][01] , .t.) )
		
		SX1->( Reclock("SX1",.t.) )
		
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := aPerg[nId][01]
		SX1->X1_PERGUNT := aPerg[nId][02]
		SX1->X1_VARIAVL := aPerg[nId][03]
		SX1->X1_TIPO    := aPerg[nId][04]
		SX1->X1_TAMANHO := aPerg[nId][05]
		SX1->X1_DECIMAL := aPerg[nId][06]
		SX1->X1_PRESEL  := aPerg[nId][07]
		SX1->X1_GSC     := aPerg[nId][08]
		SX1->X1_VALID   := aPerg[nId][09]
		SX1->X1_VAR01   := aPerg[nId][10]
		SX1->X1_F3		:= aPerg[nId][11]
		SX1->X1_DEF01   := aPerg[nId][12]
		SX1->X1_DEF02   := aPerg[nId][13]
		SX1->X1_DEF03   := aPerg[nId][14]
		
		SX1->( MsUnLock() )
		
	EndIf
	
Next nId
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFINA14  บAutor  ณMicrosiga           บ Data ณ  01/22/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static function fQuery()

Local lRet   := .t.
Local cQuery := ""
Local cFiltroSE1:= Alltrim(SuperGetMv("SI_NRTRSE1",.F.,""))
Local cFiltroSE2:= Alltrim(SuperGetMv("SI_NRTRSE2",.F.,""))


If _cAlias == "SE2"
	cQuery += " Select E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_NATUREZ,E2_FORNECE,E2_LOJA,E2_NOMFOR,E2_VENCTO,E2_VENCREA,E2_VALOR,E2_SALDO,E2_HIST,E2_TITPAI,R_E_C_N_O_ "
	cQuery += "   From "+RetSqlName('SE2')+" SE2 "
	cQuery += "  Where E2_FILIAL = '"+xFilial('SE2')+"' "
	cQuery += "    and E2_PREFIXO between '"+MV_PAR01+"' and '"+MV_PAR02+"' "
	cQuery += "    and E2_NUM between '"+MV_PAR03+"' and '"+MV_PAR04+"' "
	cQuery += "    and E2_PARCELA between '"+MV_PAR05+"' and '"+MV_PAR06+"' "
	cQuery += "    and E2_TIPO between '"+MV_PAR07+"' and '"+MV_PAR08+"' "
	cQuery += "    and E2_FORNECE+E2_LOJA between '"+MV_PAR09+MV_PAR11+"' and '"+MV_PAR10+MV_PAR12+"' "
	cQuery += "    and E2_VALOR between "+str(MV_PAR13)+" and "+str(MV_PAR14)+" "
	cQuery += "    and E2_NATUREZ between '"+MV_PAR15+"' and '"+MV_PAR16+"' "
	cQuery += "    and E2_SALDO = E2_VALOR "
	cQuery += "    and E2_VENCTO between '"+Dtos(MV_PAR17)+"' and '"+Dtos(MV_PAR18)+"' "
	cQuery += "    and SE2.D_E_L_E_T_ <> '*' "
	cQuery += cFiltroSE2
Else
	cQuery += " Select E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_NATUREZ,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_VENCTO,E1_VENCREA,E1_VALOR,E1_SALDO,E1_HIST,E1_TITPAI,R_E_C_N_O_ "
	cQuery += "   From "+RetSqlName('SE2')+" SE1 "
	cQuery += "  Where E1_FILIAL = '"+xFilial('SE1')+"' "
	cQuery += "    and E1_PREFIXO between '"+MV_PAR01+"' and '"+MV_PAR02+"' "
	cQuery += "    and E1_NUM between '"+MV_PAR03+"' and '"+MV_PAR04+"' "
	cQuery += "    and E1_PARCELA between '"+MV_PAR05+"' and '"+MV_PAR06+"' "
	cQuery += "    and E1_TIPO between '"+MV_PAR07+"' and '"+MV_PAR08+"' "
	cQuery += "    and E1_CLIENTE+E1_LOJA between '"+MV_PAR09+MV_PAR11+"' and '"+MV_PAR10+MV_PAR12+"' "
	cQuery += "    and E1_VALOR between "+str(MV_PAR13)+" and "+str(MV_PAR14)+" "
	cQuery += "    and E1_NATUREZ between '"+MV_PAR15+"' and '"+MV_PAR16+"' "
	cQuery += "    and E1_SALDO = E1_VALOR "
	cQuery += "    and E1_VENCTO between '"+Dtos(MV_PAR17)+"' and '"+Dtos(MV_PAR18)+"' "
	cQuery += "    and SE1.D_E_L_E_T_ <> '*' "
	cQuery += cFiltroSE1
EndIf

If Select('QRYS') > 0
	QRYS->( DbCloseArea() )
EndIf

TcQuery cQuery New Alias "QRYS"

Count to nQtdRegs

For nId := 1 to len(aCampos)
	If aCampos[nId][4] $ "DN"
		TcSetField("QRYS",aCampos[nId][1],aCampos[nId][4],aCampos[nId][5],aCampos[nId][6])
	EndIf
Next

TcSetField("QRYS","R_E_C_N_O_","N",10,00)

__aDados := {}

lRet := !QRYS->( BOF().and.EOF() )
//--------------------------------------------------------
// Monta as colunas do Browse no array __aDados com as
// Informacoes lidas pela Query.
//--------------------------------------------------------
QRYS->( DbGoTop() )

aLinha := {.f.}

Do While QRYS->( !EOF() )
	
	aLinha := {.f.}
	
	For nId := 1 to len(aCampos)
		
		cCpoLido := aCampos[nId][1]
		cPicLido := aCampos[nId][3]
		
		If aCampos[nId][4] $ "N"
			QRYS->( aAdd(aLinha,Transform(&cCpoLido,cPicLido)) )
		Else
			QRYS->(aAdd(aLinha,&cCpoLido))
		EndIf
		
	Next nId
	
	QRYS->( aAdd(aLinha,R_E_C_N_O_) )
	
	aAdd(__aDados,aLinha)
	
	QRYS->( DbSkip() )
	
EndDo

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMarca(X,Y)บAutor ณMicrosiga           บ Data ณ 22/12/2009  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Usada para fazer a inversao das marcacoes.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fMarca()

Local i := 1
Local aAlias := (_cAlias)->(GetArea())
Local nOpcao := 0

(_cAlias)->( DbSetOrder(1) )

If (_cAlias)->( DbSeek(_cFil +;
	__aDados[oList:nAt][2]+;
	__aDados[oList:nAt][3]+;
	__aDados[oList:nAt][4]+;
	__aDados[oList:nAt][5]+;
	__aDados[oList:nAt][6]+;
	__aDados[oList:nAt][7]))
	
	nOpcao := Aviso('Aten็ใo','Este titulo jแ existe na filial destino. Nใo poderแ ser transferido.',{'OK'})
Else
	__aDados[oList:nAT,1] := !__aDados[oList:nAT,1]

	nOpcao := 2
	If __aDados[oList:nAT,1] .and. !__aDados[oList:nAT,5] $ "ISS,IRF,INS,PIS,COF,CSL,TX ,TXA"
		If Aviso('Aten็ใo','Caso existam tํtulos de impostos, os mesmos deverใo ser marcados para transfer๊ncia?',{'Sim','Nao'}) == 1
			_cTitPai := __aDados[oList:nAt][2]+__aDados[oList:nAt][3]+__aDados[oList:nAt][4]+__aDados[oList:nAt][5]+__aDados[oList:nAt][7]+__aDados[oList:nAt][8]
			For nId := 1 to Len(__aDados)
				If Alltrim(__aDados[nId][14]) == Alltrim(_cTitPai)
					If __aDados[nId,5] <> "ISS"
						__aDados[nId,1] := !__aDados[nId,1]
					Endif	
  	    		Endif
			Next
		Endif
	Else 
		_cTitPai := __aDados[oList:nAt][2]+__aDados[oList:nAt][3]+__aDados[oList:nAt][4]+__aDados[oList:nAt][5]+__aDados[oList:nAt][7]+__aDados[oList:nAt][8]
		For nId := 1 to Len(__aDados)
			If Alltrim(__aDados[nId][14]) == Alltrim(_cTitPai)
				__aDados[nId,1] := .f.
    		Endif
		Next
	Endif	
	oList:Refresh()
EndIf
(_cAlias)->(RestArea(aAlias))
Return( Nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMarcAll()บAutor  ณMicrosiga           บ Data ณ 23/12/2009  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fMarcAll()

Local nId
Local cMarcaT := !__aDados[oList:nAT,1]

For nId :=1 to len(__aDados)
	
	__aDados[nId,1] := lMarcAll
	
	If lMarcAll
		
	EndIf
	
Next nId

oList:Refresh()

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfLocaliza()บAutor ณMicrosiga           บ Data ณ 30/12/2009  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao desenvolvida para localizar CTRC na tela de selecao  บฑฑ
ฑฑบ          ณpara gerar Nota Fiscal de Entrada.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFAT - Dipromed                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLocaliza()

Local oDlg
Local nOpc    := 0
Local nPos    := 0
Local lRet    := .T.
Local bCancel := {|| nOpc:=1,oDlg:End()}
Local bOk     := {|| nOpc:=2,oDlg:End()}
Local oPrefixo
Local oNum
Local oParcela
Local oTipo
Local oNaturez
Local oFornece
Local oLoja

Local cF3_For
Local cF3_Nat := 'SED'
Local cF3_Tip := '05'

If _cAlias == "SE2"
	
	Private cPrefixo := Criavar("E2_PREFIXO")
	Private cNum     := Criavar("E2_NUM")
	Private cParcela := Criavar("E2_PARCELA")
	Private cTipo    := Criavar("E2_TIPO")
	Private cNaturez := Criavar("E2_NATUREZ")
	Private cFornece := Criavar("E2_FORNECE")
	Private cLoja    := Criavar("E2_LOJA")
	
	cF3_for := 'SA2'
	
Else
	
	Private cPrefixo := Criavar("E1_PREFIXO")
	Private cNum     := Criavar("E1_NUM")
	Private cParcela := Criavar("E1_PARCELA")
	Private cTipo    := Criavar("E1_TIPO")
	Private cNaturez := Criavar("E1_NATUREZ")
	Private cFornece := Criavar("E1_CLIENTE")
	Private cLoja    := Criavar("E1_LOJA")
	
	cF3_for := 'SA1'
	
EndIf

Define MsDialog oDlg Title "Pesquisando Titulo" from 0,0 to 200,350 of oMainWnd pixel

@ 002,003 to 098,125 Of oDlg Pixel

@ 010,005 say "Prefixo"    size 40,08 of oDlg pixel
@ 022,005 say "Nro Titulo" size 40,08 of oDlg pixel
@ 034,005 say "Parcela"    size 40,08 of oDlg pixel
@ 046,005 say "Tipo"       size 40,08 of oDlg pixel
@ 058,005 say "Naturez"    size 40,08 of oDlg pixel
@ 070,005 say "Fornece"    size 40,08 of oDlg pixel
@ 082,005 say "Loja"       size 40,08 of oDlg pixel

@ 010,070 msget oPrefixo var cPrefixo size 30,08 of oDlg pixel
@ 022,070 msget oNum     var cNum     size 40,08 of oDlg pixel
@ 034,070 msget oParcela var cParcela size 20,08 of oDlg pixel
@ 046,070 msget oTipo    var cTipo    F3 "05"  size 20,08 of oDlg pixel
@ 058,070 msget oNaturez var cNaturez F3 "SED" size 30,08 of oDlg pixel
@ 070,070 msget oFornece var cFornece F3 cF3_for size 30,08 of oDlg pixel
@ 082,070 msget oLoja    var cLoja    size 20,08 of oDlg pixel

@ 022,130 Button OemToAnsi("Localizar") size 40,15 pixel of oDlg action eval(bOk)
@ 058,130 Button OemToAnsi("Fechar")    size 40,15 pixel of oDlg action eval(bCancel)

Activate MsDialog oDlg Centered

Begin Sequence

If nOpc <> 2
	Break
EndIf

If _cAlias == "SE2"
	nPos := ascan(__aDados,{|x| Iif(!Empty(cPrefixo),x[2]==cPrefixo,.t.) .and.;
	Iif(!Empty(cNum)    ,x[3]==cNum    ,.t.) .and.;
	Iif(!Empty(cParcela),x[4]==cParcela,.t.) .and.;
	Iif(!Empty(cTipo)   ,x[5]==cTipo   ,.t.) .and.;
	Iif(!Empty(cNaturez),x[6]==cNaturez,.t.) .and.;
	Iif(!Empty(cFornece),x[7]==cFornece,.t.) .and.;
	Iif(!Empty(cLoja)   ,x[8]==cLoja   ,.t.)})
Else
	nPos := ascan(__aDados,{|x| Iif(!Empty(cPrefixo),x[2]==cPrefixo,.t.) .and.;
	Iif(!Empty(cNum)    ,x[3]==cNum    ,.t.) .and.;
	Iif(!Empty(cParcela),x[4]==cParcela,.t.) .and.;
	Iif(!Empty(cTipo)   ,x[5]==cTipo   ,.t.) .and.;
	Iif(!Empty(cNaturez),x[6]==cNaturez,.t.) .and.;
	Iif(!Empty(cFornece),x[7]==cFornece,.t.) .and.;
	Iif(!Empty(cLoja)   ,x[8]==cLoja   ,.t.)})
EndIf

If nPos > 0
	oList:nAt:=nPos
	oList:Refresh()
Else
	Aviso('Aten็ใo','Titulo Nใo encontrado na listagem',{'Ok'})
	lRet := .F.
EndIf

End Sequence

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFIN14A  บAutor  ณFelipe Alves        บ Data ณ  18/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela que exibe registros de Transfer๊ncia de Tํtulos        บฑฑ
ฑฑบ          ณentre Filiais.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SIFIN14A()
Local lRet        := .T.
Local cAlias      := "SE2"
Local cFiltro     := "E2_XNUMTRF != '' AND E2_XTPTRF = '1' AND E2_BAIXA != ''"

Private cCadastro := "Consulta de Transfer๊ncia de tํtulos entre Filiais"
Private aRotina   := {{"Visualizar", "AxVisual", 0, 2}, ;
{"Estornar", ;
"MsgRun('Realizando estornos, aguarde...', 'Transfer๊ncia de tํtulos entre Filiais', {|| CursorWait(), U_SIFIN14B(SE2->E2_XNUMTRF, SE2->E2_XFILDES), CursorArrow()})", ;
0, 2}}

DbSelectArea(cAlias)
(cAlias)->(DbSetOrder(19))
mBrowse(6, 1, 22, 75, cAlias, , , , , , , , , , , , , , cFiltro)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIFIN14B  บAutor  ณFelipe Alves        บ Data ณ  18/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina que realiza estorno de Transfer๊ncia de Tํtulos      บฑฑ
ฑฑบ          ณentre Filiais.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SIFIN14B(cTransf, cFilDes)
Local aArea           := GetArea()
Local lRet            := .T.
Local cQuery          := ""
Local cTab            := ""
Local cFilOri         := SE2->E2_FILIAL
Local cPreTit         := SE2->E2_PREFIXO
Local cNumTit         := SE2->E2_NUM
Local cParTit         := SE2->E2_PARCELA
Local cTipTit         := SE2->E2_TIPO
Local cForTit         := SE2->E2_FORNECE
Local cLojaTit        := SE2->E2_LOJA
Local aStru           := {}

Private lMsErroAuto   := .F.

BEGIN TRANSACTION

aAdd(aStru, {"E2_FILIAL" , cFilAnt , Nil}) 
aAdd(aStru, {"E2_XNUMTRF", cTransf , Nil})
aAdd(aStru, {"E2_PREFIXO", cPreTit , Nil})
aAdd(aStru, {"E2_NUM"    , cNumTit , Nil})
aAdd(aStru, {"E2_PARCELA", cParTit , Nil})
aAdd(aStru, {"E2_TIPO"   , cTipTit , Nil}) 
aAdd(aStru, {"E2_FORNECE", cForTit , Nil})
aAdd(aStru, {"E2_LOJA"   , cLojaTit, Nil})  

lMsErroAuto           := .F.

MsExecAuto({|x,y,z| FINA080(x,y,z)}, aStru, 5)

If (lMsErroAuto)
	lRet                := .F.
	DisarmTransaction()
	MostraErro()
Endif 

//************************ Inicio da Altera็ใo de Jos้ Fernando *********************   
aStru	:= {}
aAdd(aStru, {"E2_FILIAL" , cFilOri , Nil}) 
aAdd(aStru, {"E2_XNUMTRF", "" , Nil}) 
aAdd(aStru, {"E2_PREFIXO", cPreTit , Nil})
aAdd(aStru, {"E2_NUM"    , cNumTit , Nil})
aAdd(aStru, {"E2_PARCELA", cParTit , Nil})
aAdd(aStru, {"E2_TIPO"   , cTipTit , Nil}) 
aAdd(aStru, {"E2_FORNECE", cForTit , Nil})
aAdd(aStru, {"E2_LOJA"   , cLojaTit, Nil}) 
aAdd(aStru, {"E2_XTPTRF" , "" , Nil}) 
aAdd(aStru, {"E2_XFILDES", "" , Nil})   

lMsErroAuto           := .F.

aStru := fChkCpos(aStru)  

MsExecAuto({|x,y,z| FINA050(x,y,z)}, aStru,,4)

If (lMsErroAuto)
	lRet                := .F.
	DisarmTransaction()
	MostraErro()
Endif 

//******************************** fim da altera็ใo do Jos้ Fernando *********************

If (lRet)
	aStru               := {}
	
	cFilAnt             := cFilDes
	
	DbSelectArea("SE2")
	SE2->(DbSetOrder(19))
	
	If (SE2->(DbSeek(cFilAnt + cTransf)))
        cPreTit         := SE2->E2_PREFIXO
        cNumTit         := SE2->E2_NUM
        cParTit         := SE2->E2_PARCELA
        cTipTit         := SE2->E2_TIPO
        cForTit         := SE2->E2_FORNECE
        cLojaTit        := SE2->E2_LOJA
        
		aAdd(aStru, {"E2_FILIAL" , cFilDes , Nil}) 
		aAdd(aStru, {"E2_PREFIXO", cPreTit , Nil})
		aAdd(aStru, {"E2_NUM"    , cNumTit , Nil})
		aAdd(aStru, {"E2_PARCELA", cParTit , Nil})
		aAdd(aStru, {"E2_TIPO"   , cTipTit , Nil})
		aAdd(aStru, {"E2_FORNECE", cForTit , Nil})
		aAdd(aStru, {"E2_LOJA"   , cLojaTit, Nil})
	Endif
	
	lMsErroAuto         := .F.
	
	MsExecAuto({|x,y,z| FINA050(x,y,z)}, aStru, , 5)
	
	If (lMsErroAuto)
		lRet        := .F.
		DisarmTransaction()
		MostraErro()
	Endif

	If (lRet)
		Aviso("Estorno", "Estorno realizado com sucesso.", {"OK"}, 3)
	Endif
	
Endif

END TRANSACTION

RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
<Descricao> : Funcao para controle de versao
<Autor> : Doit Sistemas
<Data> : 02/09/2014
<Parametros> :
<Retorno> : Nil
<Processo> :  
<Rotina> :  
<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : E
<Obs> :
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/

User Function SIFIN14V() 

Local cRet  := ""                         

cRet := "20171117001" 
        
Return (cRet) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fChkCpos บAutor  ณ Vinํcius Moreira   บ Data ณ 26/03/2015  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Checa ordem dos campos para execu็ใo do MsExecAuto.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fChkCpos(aCpos)

Local aCposAux := {}
Local aRet     := {}
Local nCpo     := 0
Local nTamCpo  := Len(SX3->X3_CAMPO)

dbSelectArea("SX3")
SX3->(dbSetOrder(2))//X3_CAMPO

For nCpo := 1 to Len(aCpos)
	If SX3->(dbSeek(PadR(aCpos[nCpo, 1], nTamCpo, " ")))
		aAdd(aCposAux, {SX3->X3_ORDEM, aCpos[nCpo]})
	Else
		aAdd(aCposAux, {"999", aCpos[nCpo]})
	EndIf
Next nCpo
ASort(aCposAux,,,{|x,y| x[1] < y[1] })
For nCpo := 1 to Len(aCposAux)
	aAdd(aRet, aCposAux[nCpo,2])
Next nCpo

Return aRet