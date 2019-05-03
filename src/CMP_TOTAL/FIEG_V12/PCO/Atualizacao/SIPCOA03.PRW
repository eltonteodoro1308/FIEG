#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA03
Cadastro de layouts de exportacao de dados do PCO.

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23

@param Parametro_01, Numérico, Informe a descrição do 1º parêmtro.

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SIPCOA03()

Local aCores      := {{ "Z3_TIPO == '1'", "BR_AMARELO"},{ "Z3_TIPO == '2'", "BR_AZUL"}} // AMARELO=Importação; AZUL=Exportação

Private cCadastro := "Configurador de Layout"
Private aRotina   := { 	{"Pesquisar" ,"AxPesqui"  ,0,1},;
						{"Visualizar",'U_SIPCOA3A',0,2},;
						{"Incluir"   ,'U_SIPCOA3A',0,3},;
						{"Alterar"   ,'U_SIPCOA3A',0,4},;
						{"Legenda"   ,'BrwLegenda("Tipo de Layout","Legenda",{{"BR_AMARELO","Importação"},{"BR_AZUL","Exportação"}})',0,3},;
						{"Excluir"   ,'U_SIPCOA3A',0,5}}

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
dbSelectArea("SZ3")
SZ3->(dbSetOrder(1))

mBrowse( 6,1,22,75,"SZ3",,,,,,aCores)

Return(Nil)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA3A
Browse de manutencao na tabela.

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23

@param x, Numérico, Opção da rotina.
@param y, Numérico, Opção da rotina.
@param nOpcBrw, Numérico, Opção da rotina.

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SIPCOA3A(x,y,nOpcBrw)

Local oDlgMain     := Nil
Local oEnchoice    := Nil
Local oGetDad1     := Nil
Local oGetDad2     := Nil
Local aCoordenadas := MsAdvSize(.T.)
Local aHead1       := {}
Local aCols1       := {}
Local aHead2       := {}
Local aCols2       := {}
Local nOpcClick    := 0
Local nPosItem     := 0
Local i,j

Private aTela[0,0]
Private aGets[0]
Private oFolder    := Nil

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
dbSelectArea("SZ3")
SZ3->(RegToMemory("SZ3",nOpcBrw == 3))

//--< Monta os AHEADERS e ACOLS >---------------------------
OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
SX3TMP->(dbSetOrder(1))
SX3TMP->(dbSeek("SZ4"))
While SX3TMP->(!Eof()) .And. SX3TMP->X3_ARQUIVO == "SZ4"
	If X3Uso(SX3TMP->X3_USADO) .And. cNivel >= SX3TMP->X3_NIVEL
		Aadd(aHead1,{	Trim(X3Titulo()),SX3TMP->X3_CAMPO,SX3TMP->X3_PICTURE,SX3TMP->X3_TAMANHO,SX3TMP->X3_DECIMAL,SX3TMP->X3_VALID,;
		SX3TMP->X3_USADO,SX3TMP->X3_TIPO,SX3TMP->X3_F3,SX3TMP->X3_CONTEXT,SX3TMP->X3_CBOX,,SX3TMP->X3_WHEN,	;
		SX3TMP->X3_VISUAL,SX3TMP->X3_VLDUSER, SX3TMP->X3_PICTVAR,SX3TMP->X3_OBRIGAT	})
	EndIf
	SX3TMP->(dbSkip())
EndDo
nPosItem := AScan(aHead1,{|x| AllTrim(x[2]) == "Z4_ITEM" })

//--< Replica a estrutura dos 2 AHEADERS >------------------
aHead2 := AClone(aHead1)

//--< Busca o cadastro >------------------------------------
dbSelectArea("SZ4")
SZ4->(dbSetOrder(1))
SZ4->(dbSeek(xFilial("SZ4")+M->Z3_COD ))
While SZ4->(!Eof()) .And. SZ4->Z4_FILIAL + SZ4->Z4_COD == xFilial("SZ4")+M->Z3_COD
	If SZ4->Z4_TIPO == "1"
		AAdd(aCols1,Array(Len(aHead1)+1))
		For i := 1 To Len(aHead1)
			aCols1[Len(aCols1),i] := Iif(aHead1[i,10] <> "V",SZ4->&(aHead1[i,2]),CriaVar(aHead1[i,2]))
		Next i
		aCols1[Len(aCols1),Len(aHead1)+1] := .F.
	Else
		AAdd(aCols2,Array(Len(aHead2)+1))
		For i := 1 To Len(aHead2)
			aCols2[Len(aCols2),i] := Iif(aHead2[i,10] <> "V",SZ4->&(aHead2[i,2]),CriaVar(aHead2[i,2]))
		Next i
		aCols2[Len(aCols2),Len(aHead2)+1] := .F.
	EndIf
	SZ4->(dbSkip())
EndDo

If Len(aCols1) <= 0
	AAdd(aCols1,Array(Len(aHead1)+1))
	For i := 1 To Len(aHead1)
		If AllTrim(aHead1[i,2]) == "Z4_ITEM"
			aCols1[Len(aCols1),i] := "001"
		Else
			aCols1[Len(aCols1),i] := CriaVar(aHead1[i,2])
		EndIf
	Next i
	aCols1[Len(aCols1),Len(aHead1)+1] := .F.
EndIf

If Len(aCols2) <= 0
	AAdd(aCols2,Array(Len(aHead2)+1))
	For i := 1 To Len(aHead2)
		If AllTrim(aHead2[i,2]) == "Z4_ITEM"
			aCols2[Len(aCols2),i] := "001"
		Else
			aCols2[Len(aCols2),i] := CriaVar(aHead2[i,2])
		EndIf
	Next i
	aCols2[Len(aCols2),Len(aHead2)+1] := .F.
EndIf

//--< Desenha a tela >--------------------------------------
oDlgMain := TDialog():New(aCoordenadas[7],000,aCoordenadas[6],aCoordenadas[5],OemToAnsi("Configurador de Layouts"),,,,,,,,oMainWnd,.T.)
oEnchoice := MsMGet():New("SZ3",SZ3->(RecNo()),nOpcBrw,,,,,{014,001,oDlgMain:nClientHeight/7,oDlgMain:nClientWidth/2-5},,3,,,,,,.T.)

oFolder := TFolder():New(oDlgMain:nClientHeight/7+5,001,{"Orçamento","Movimentos"},,oDlgMain,,,,.T.,.F.,oDlgMain:nClientWidth/2-5,oDlgMain:nClientHeight/2-(oDlgMain:nClientHeight/7+5))
oGetDad1 := MsNewGetDados():New(001,001,oFolder:aDialogs[1]:nClientHeight/2-2,oFolder:aDialogs[1]:nClientWidth/2-2,Iif(nOpcBrw <> 2,GD_INSERT+GD_DELETE+GD_UPDATE,2),,,"+Z4_ITEM",,,9999,,,,oFolder:aDialogs[1],aHead1,aCols1)
oGetDad1:bLinhaOk := {|| SIPCOA3B(oGetDad1,2) }
oGetDad1:bTudoOk  := {|| SIPCOA3B(oGetDad1,1) }

oGetDad2 := MsNewGetDados():New(001,001,oFolder:aDialogs[2]:nClientHeight/2-2,oFolder:aDialogs[2]:nClientWidth/2-2,Iif(nOpcBrw <> 2,GD_INSERT+GD_DELETE+GD_UPDATE,2),,,"+Z4_ITEM",,,9999,,,,oFolder:aDialogs[2],aHead2,aCols2)
oGetDad2:bLinhaOk := {|| SIPCOA3B(oGetDad2,2) }
oGetDad2:bTudoOk  := {|| SIPCOA3B(oGetDad2,1) }

oDlgMain:Activate(,,,.T.,,,{|| EnchoiceBar(oDlgMain,{|| IIf(nOpcBrw == 5 .Or. (Obrigatorio(aGets,aTela) .And. oGetDad1:TudoOk() .And. oGetDad2:TudoOk()),(nOpcClick := 1,oDlgMain:End()),Nil )  },{|| oDlgMain:End()})  })

If nOpcClick == 1 .And. nOpcBrw <> 2
	If nOpcBrw == 3
		ConfirmSX8()
	EndIf

	//--< Cabecalho do layout >-----------------------------
	SZ3->(RecLock("SZ3",nOpcBrw == 3))
	If nOpcBrw <> 5
		SZ3->Z3_FILIAL := xFilial("SZ3")
		//--< Grava todos os campos >-----------------------
		For i := 1 To Len(oEnchoice:aGets)
			If Posicione("SX3",2,AllTrim(SubStr(oEnchoice:aGets[i],9,10)),"SX3->X3_CONTEXT") <> "V"
				SZ3->&(SubStr(oEnchoice:aGets[i],9,10)) := M->&(SubStr(oEnchoice:aGets[i],9,10))
			EndIf
		Next i
	Else
		SZ3->(dbDelete())
	EndIf
	SZ3->(MsUnlock())

	//--< Itens do Layout >---------------------------------
	For i := 1 To Len(oGetDad1:aCols)
		dbSelectArea("SZ4")
		SZ4->(dbSetOrder(1))
		If SZ4->(dbSeek(xFilial("SZ4")+M->Z3_COD+"1"+oGetDad1:aCols[i,nPosItem] ))
			SZ4->(RecLock("SZ4",.F.))
			If oGetDad1:aCols[i,Len(oGetDad1:aHeader)+1] .Or. nOpcBrw == 5
				SZ4->(dbDelete())
				SZ4->(MsUnlock())
				Loop
			EndIf
		ElseIf !oGetDad1:aCols[i,Len(oGetDad1:aHeader)+1]
			SZ4->(RecLock("SZ4",.T.))
		Else
			Loop
		EndIf

		SZ4->Z4_FILIAL	:= xFilial("SZ4")
		SZ4->Z4_COD		:= M->Z3_COD
		SZ4->Z4_TIPO	:= "1"
		For j := 1 To Len(oGetDad1:aHeader)
			If oGetDad1:aHeader[j,10] <> "V"
				SZ4->&(oGetDad1:aHeader[j,2]) := oGetDad1:aCols[i,j]
			EndIf
		Next j
		SZ4->(MsUnlock())
	Next i

	For i := 1 To Len(oGetDad2:aCols)
		dbSelectArea("SZ4")
		SZ4->(dbSetOrder(1))
		If SZ4->(dbSeek(xFilial("SZ4")+M->Z3_COD+"2"+oGetDad2:aCols[i,nPosItem] ))
			SZ4->(RecLock("SZ4",.F.))
			If oGetDad2:aCols[i,Len(oGetDad2:aHeader)+1] .Or. nOpcBrw == 5
				SZ4->(dbDelete())
				SZ4->(MsUnlock())
				Loop
			EndIf
		ElseIf !oGetDad2:aCols[i,Len(oGetDad2:aHeader)+1]
			SZ4->(RecLock("SZ4",.T.))
		Else
			Loop
		EndIf

		SZ4->Z4_FILIAL	:= xFilial("SZ4")
		SZ4->Z4_COD		:= M->Z3_COD
		SZ4->Z4_TIPO	:= "2"
		For j := 1 To Len(oGetDad2:aHeader)
			If oGetDad2:aHeader[j,10] <> "V"
				SZ4->&(oGetDad2:aHeader[j,2]) := oGetDad2:aCols[i,j]
			EndIf
		Next j
		SZ4->(MsUnlock())
	Next i
Else
	RollBackSX8()
EndIf

Return(Nil)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA3B
Validacao do LINHAOK e TUDOOK.

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23

@param oGetDados, Objeto, GetDados.
@param nTpValid, Numérico, Tipo da validação.

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

Static Function SIPCOA3B(oGetDados,nTpValid)

Local i
Local nPosCampo   := AScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z4_CAMPO"   })
Local nPosFormula := AScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z4_FORMULA" })
Local nPosTamanho := AScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == "Z4_TAMANHO" })

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Tudo OK >---------------------------------------------
If nTpValid == 1
	For i := 1 To Len(oGetDados:aCols)
		If !oGetDados:aCols[i,Len(oGetDados:aHeader)+1] .And. Empty(oGetDados:aCols[i,nPosCampo]) .And. Empty(oGetDados:aCols[i,nPosFormula])
			Help(1," ","OBRIGAT",,,3,0)
			Return(.F.)
		EndIf
	Next i

	//Linha OK
Else
	If !oGetDados:aCols[oGetDados:nAt,Len(oGetDados:aHeader)+1] .And. Empty(oGetDados:aCols[oGetDados:nAt,nPosCampo]) .And. Empty(oGetDados:aCols[oGetDados:nAt,nPosFormula])
		Help(1," ","OBRIGAT",,,3,0)
		Return(.F.)
	EndIf
EndIf

Return(.T.)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA3C
Validacao dos campos informados nos folders.

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function SIPCOA3C()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF Empty(&(ReadVar()))
	Return .t.
ENDIF

OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
SX3TMP->(dbSetOrder(2))
If !SX3TMP->(dbSeek(AllTrim(&(ReadVar()))))
	MsgAlert("Campo invalido. Não existe no dicionário.")
	Return(.F.)
EndIf

If oFolder:nOption == 1 									// Orçamento
	If !("AK2_" $ Upper(&(ReadVar())))
		MsgAlert("Informe apenas campos da tabela AK2")
		Return(.F.)
	EndIf
Else 														// Movimento
	If !("AKD_" $ Upper(&(ReadVar())))
		MsgAlert("Informe apenas campos da tabela AKD")
		Return(.F.)
	EndIf
EndIf

Return(.T.)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA3D
Exportador de PLANILHAS.

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SIPCOA3D()

Local aPerguntas := {}
Local aRetorno   := {}
Local cQuery     := ""
Local nTotReg    := 0
Local bQuery     := {|| Iif(Select("TMP") > 0, TMP->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.) , dbSelectArea("TMP"), TMP->(dbGoTop()), TMP->(dbEval({|| nTotReg++ })), TMP->(dbGoTop()) }

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If AK1->AK1_XAPROV <> "2"
	MsgAlert("Atenção, esse orçamento não foi aprovado. Não será possível exportá-lo.")
	Return(Nil)
EndIf

//--< Perguntas >-------------------------------------------
Aadd(aPerguntas,{ 1,"Layout"		,Space(TamSx3('Z3_COD')[1]),"@!","","SZ3EXP","",0,	.T.})
AAdd(aPerguntas,{ 6,"Diretorio"		,Padr("",150),"",,"", 90 ,.T.,"","",GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY})

If !ParamBox(aPerguntas,"Exportação Planilha",@aRetorno)
	Return(Nil)
EndIf

SZ3->(dbSetOrder(1))
IF !SZ3->(dbSeek(XFilial("SZ3")+aRetorno[1]))
	MsgAlert("O layout informado não foi localizado. Verifique!")
	Return(Nil)
ENDIF

IF SZ3->Z3_TIPO <> "2" 										// exportação
	MsgAlert("O layout informado não pode ser utilizado em exportações. Verifique!")
	Return(Nil)
ENDIF

//Processa os itens da planilha x layout indicado
//cQuery := " SELECT AK2_ID, AK2_ORCAME, AK2_VERSAO, "
cQuery := " SELECT AK2_ORCAME, AK2_VERSAO, "
cQuery += "        CASE WHEN CT1_XCTCON = '      ' THEN AK2_CO ELSE CT1_XCTCON END AK2_CO, "
cQuery += "        AK2_PERIOD, " //AK2_CC, "
If AllTrim(TCGetDB()) <> "ORACLE"
	cQuery += "        ISNULL(CASE WHEN CTD_XITCON = '      ' THEN AK2_ITCTB ELSE CTD_XITCON END,'      ') AS AK2_ITCTB, "
Else
	cQuery += "        NVL(CASE WHEN CTD_XITCON = '      ' THEN AK2_ITCTB ELSE CTD_XITCON END,'      ') AS AK2_ITCTB, "
EndIf
cQuery += "        AK2_CLVLR, AK2_CLASSE, SUM(AK2_VALOR) AS AK2_VALOR, "
cQuery += "        AK2_DESCRI, AK2_OPER, AK2_CHAVE, AK2_MOEDA, AK2_DATAF, AK2_DATAI, AK2_FORMUL "
cQuery += " FROM " + RetSQLName("AK2") + " AK2 "
cQuery += "        LEFT JOIN " + RetSQLName("CTD") + " CTD ON CTD_FILIAL = '" + xFilial("CTD") + "' AND CTD_ITEM = AK2_ITCTB AND CTD.D_E_L_E_T_ = ' ' "
cQuery += "      , " + RetSQLName("CT1") + " CT1 "
cQuery += " WHERE AK2_FILIAL = '" + xFilial("AK2") + "' AND AK2_ORCAME = '" + AK1->AK1_CODIGO + "' AND AK2_VERSAO = '"+AK1->AK1_VERSAO+"' AND AK2.D_E_L_E_T_ = ' ' AND "
cQuery += "       CT1_FILIAL = '" + xFilial("CT1") + "' AND CT1_CONTA = AK2_CO AND CT1.D_E_L_E_T_ = ' ' AND AK2_VALOR > 0 "
//cQuery += " GROUP BY AK2_ID, AK2_ORCAME, AK2_VERSAO, "
cQuery += " GROUP BY AK2_ORCAME, AK2_VERSAO, "
cQuery += "          CASE WHEN CT1_XCTCON = '      ' THEN AK2_CO ELSE CT1_XCTCON END, "
cQuery += "          AK2_PERIOD, " //AK2_CC, "
If AllTrim(TCGetDB()) <> "ORACLE"
	cQuery += "          ISNULL(CASE WHEN CTD_XITCON = '      ' THEN AK2_ITCTB ELSE CTD_XITCON END,'      '), "
Else
	cQuery += "          NVL(CASE WHEN CTD_XITCON = '      ' THEN AK2_ITCTB ELSE CTD_XITCON END,'      '), "
EndIf
cQuery += "          AK2_CLVLR, AK2_CLASSE, AK2_DESCRI, AK2_OPER, AK2_CHAVE, AK2_MOEDA, AK2_DATAF, AK2_DATAI, AK2_FORMUL "
LjMsgRun("Consultando dados da planilha...","Aguarde...",bQuery)

Processa({|| SIPCOA3DPrc(nTotReg,aRetorno) })

Return(Nil)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA3DPrc
Processamento da exportacao da planilha orcamentaria.

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23

@param nTotReg, Numérico, Numero do Registro.
@param aRetorno, Array, Retorno da rotina.

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function SIPCOA3DPrc(nTotReg,aRetorno)

Local nHdlArquivo := 0
Local cArquivo    := ""
Local cLinha      := ""
Local aLayout     := {}
Local i

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Cria o arquivo no local indicado >--------------------
dbSelectArea("SZ3")
SZ3->(dbSetOrder(1))
If !SZ3->(dbSeek(xFilial("SZ3")+aRetorno[1] ))
	MsgAlert("Layout invalido. Selecione um layout que contenha as informações de planilha orçamentária.")
	Return(Nil)
EndIf

cArquivo    := AllTrim(aRetorno[2]) + SZ3->Z3_PREFORC+SubStr(DToS(dDataBase),1,6)+"."+SZ3->Z3_EXTORC
nHdlArquivo := FCreate(cArquivo)

If nHdlArquivo <= 0
	MsgAlert("Houve uma falha na criação do arquivo. O processo será interrompido.")
	Return(Nil)
EndIf

//--< Recupera o layout >-----------------------------------
dbSelectArea("SZ4")
SZ4->(dbSetOrder(1))
SZ4->(dbSeek(xFilial("SZ4")+SZ3->Z3_COD ))
While SZ4->(!Eof()) .And. SZ4->Z4_FILIAL + SZ4->Z4_COD == xFilial("SZ4")+SZ3->Z3_COD
	If SZ4->Z4_TIPO == "1"
		Aadd(aLayout,{SZ4->Z4_CAMPO,SZ4->Z4_FORMULA,SZ4->Z4_TAMANHO})
	EndIf
	SZ4->(dbSkip())
EndDo

ProcRegua(nTotReg)											//Gera os registros

dbSelectArea("TMP")
While TMP->(!Eof())
	IncProc("Exportando...")

	cLinha := ""

	For i := 1 To Len(aLayout)
		If !Empty(aLayout[i,1])
			cLinha += FormataTexto(TMP->&(aLayOut[i,1]))
		Else
			cLinha += SubStr(FormataTexto(&(aLayOut[i,2])),1,aLayOut[i,3])
		EndIf
	Next i
	FWrite(nHdlArquivo,cLinha+Chr(13)+Chr(10))

	TMP->(dbSkip())
EndDo

FClose(nHdlArquivo)
MsgAlert("Foi gerado o arquivo " + cArquivo)

Return(Nil)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA3E
Exportador de MOVIMENTOS.

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SIPCOA3E()

Local aPerguntas := {}
Local aRetorno   := {}
Local cQuery     := ""
Local nTotReg    := 0
Local bQuery     := {|| Iif(Select("TMP") > 0, TMP->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.) , dbSelectArea("TMP"), TMP->(dbGoTop()), TMP->(dbEval({|| nTotReg++ })), TMP->(dbGoTop()) }

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Perguntas >-------------------------------------------
Aadd(aPerguntas,{ 1,"Periodo De"	   	,CToD("  /  /  "),"@D","NaoVazio()" 	, "","",40,	.T.})
Aadd(aPerguntas,{ 1,"Periodo Ate"   	,CToD("  /  /  "),"@D","NaoVazio()" 	, "","",40,.T.})
Aadd(aPerguntas,{ 1,"Conta Orc. De"	    ,Space( TamSX3("AK2_CO")[1] )			, "@!"	, ""	 , "CT1", "", 40, .F.})
Aadd(aPerguntas,{ 1,"Conta Orc. Ate"	,Replicate("Z",TamSX3("AK2_CO")[1])		, "@!"	, ""	 , "CT1", "", 40, .F.})
Aadd(aPerguntas,{ 1,"Classe De"	    	,Space( TamSX3("AK6_CODIGO")[1] )		, "@!"	, ""	 , "AK6", "", 40, .F.})
Aadd(aPerguntas,{ 1,"Classe Ate"		,Replicate("Z",TamSX3("AK6_CODIGO")[1]) , "@!"	, ""	 , "AK6", "", 40, .F.})
Aadd(aPerguntas,{ 1,"Operacao De"	    ,Space( TamSX3("AKF_CODIGO")[1] )		, "@!"	, ""	 , "AKF", "", 40, .F.})
Aadd(aPerguntas,{ 1,"Operacao Ate"		,Replicate("Z",TamSX3("AKF_CODIGO")[1])	, "@!"	, ""	 , "AKF", "", 40, .F.})
Aadd(aPerguntas,{ 1,"Centro Custo De"	,Space( TamSX3("CTT_CUSTO")[1] )		, "@!"	, ""	 , "CTT", "", 40, .F.})
Aadd(aPerguntas,{ 1,"Centro Custo Ate"	,Replicate("Z",TamSX3("CTT_CUSTO")[1])	, "@!"	, ""	 , "CTT", "", 40, .F.})
Aadd(aPerguntas,{ 1,"Item Contab. De"	,Space( TamSX3("CTD_ITEM")[1] )			, "@!"	, ""	 , "CTD", "", 40, .F.})
Aadd(aPerguntas,{ 1,"Item Contab. Ate"	,Replicate("Z",TamSX3("CTD_ITEM")[1])	, "@!"	, ""	 , "CTD", "", 40, .F.})
Aadd(aPerguntas,{ 1,"Classe Vlr. De"	,Space( TamSX3("CTH_CLVL")[1] )			, "@!"	, ""	 , "CTH", "", 40, .F.})
Aadd(aPerguntas,{ 1,"Classe Vlr Ate"	,Replicate("Z",TamSX3("CTH_CLVL")[1])	, "@!"	, ""	 , "CTH", "", 40, .F.})
Aadd(aPerguntas,{ 1,"Tipo Saldo De"	    ,Space( TamSX3("AL2_TPSALD")[1] )		, "@!"	, ""	 , "AL2A", "", 40, .T.})
Aadd(aPerguntas,{ 1,"Tipo Saldo Ate"	,Space( TamSX3("AL2_TPSALD")[1] )		, "@!"	, ""	 , "AL2A", "", 40, .T.})
Aadd(aPerguntas,{ 1,"Layout"			,Space(TamSx3('Z3_COD')[1])				,"@!","","SZ3EXP","",0,	.T.})
AAdd(aPerguntas,{ 6,"Diretorio"	   		,Padr("",150),"","","", 90 ,.T.,"","",GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY})

If !ParamBox(aPerguntas,"Exportação de Movimentos",@aRetorno)
	Return(Nil)
EndIf

IF Left(Dtos(aRetorno[1]),4) <> Left(Dtos(aRetorno[2]),4)
	MsgAlert("O período de exportação deve ser sempre para o mesmo ano. Verifique!")
	Return(Nil)
ENDIF

SZ3->(dbSetOrder(1))
IF !SZ3->(dbSeek(XFilial("SZ3")+aRetorno[17]))
	MsgAlert("O layout informado não foi localizado. Verifique!")
	Return(Nil)
ENDIF

IF SZ3->Z3_TIPO <> "2" 										// exportação
	MsgAlert("O layout informado não pode ser utilizado em exportações. Verifique!")
	Return(Nil)
ENDIF

//Processa os itens da planilha x layout indicado
cQuery := " select AKD.R_E_C_N_O_ AS REGNO "
cQuery += " from " + RetSQLName("AKD")  + " AKD "
//cQuery += " where AKD_FILIAL = '"       + xFilial("AKD")    + "' AND AKD_STATUS = '1' AND AKD.D_E_L_E_T_ = ' ' "
cQuery += " where AKD_STATUS = '1' AND AKD.D_E_L_E_T_ = ' ' "
cQuery += "   and AKD_DATA BETWEEN '"   + DToS(aRetorno[1]) + "' AND '" + DToS(aRetorno[2]) + "' "
cQuery += "   and AKD_CO BETWEEN '"     + aRetorno[3] 		+ "' AND '" + aRetorno[4] + "' "
cQuery += "   and AKD_CLASSE BETWEEN '" + aRetorno[5] 		+ "' AND '" + aRetorno[6] + "' "
cQuery += "   and AKD_OPER BETWEEN '"   + aRetorno[7] 		+ "' AND '" + aRetorno[8] + "' "
cQuery += "   and AKD_CC BETWEEN '"     + aRetorno[9] 		+ "' AND '" + aRetorno[10] + "' "
cQuery += "   and AKD_ITCTB BETWEEN '"  + aRetorno[11] 		+ "' AND '" + aRetorno[12] + "' "
cQuery += "   and AKD_CLVLR BETWEEN '"  + aRetorno[13] 		+ "' AND '" + aRetorno[14] + "' "
cQuery += "   and AKD_TPSALD BETWEEN '" + aRetorno[15] 		+ "' AND '" + aRetorno[16] + "' "

LjMsgRun("Consultando lançamentos...","Aguarde...",bQuery)

Processa({|| SIPCOA3EPrc(nTotReg,aRetorno) })

Return(Nil)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA3EPrc
Processamento da exportacao dos lancamentos.

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23

@param nTotReg, Numérico, Numero do Registro.
@param aRetorno, Array, Retorno da rotina.

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function SIPCOA3EPrc(nTotReg,aRetorno)

Local nHdlArquivo := 0
Local cArquivo    := ""
Local cLinha      := ""
Local aLayout     := {}
Local i

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Cria o arquivo no local indicado >--------------------
dbSelectArea("SZ3")
SZ3->(dbSetOrder(1))
If !SZ3->(dbSeek(xFilial("SZ3")+aRetorno[17] ))
	MsgAlert("Layout invalido. Selecione um layout que contenha as informações de movimentos.")
	Return(Nil)
EndIf

cArquivo    := AllTrim(aRetorno[18]) + SZ3->Z3_PREFMOV+SubStr(DToS(aRetorno[1]),1,6)+"."+SZ3->Z3_EXTMOV
nHdlArquivo := FCreate(cArquivo)

If nHdlArquivo <= 0
	MsgAlert("Houve uma falha na criação do arquivo. O processo será interrompido.")
	Return(Nil)
EndIf

//--< Recupera o layout >-----------------------------------
dbSelectArea("SZ4")
SZ4->(dbSetOrder(1))
SZ4->(dbSeek(xFilial("SZ4")+SZ3->Z3_COD ))
While SZ4->(!Eof()) .And. SZ4->Z4_FILIAL + SZ4->Z4_COD == xFilial("SZ4")+SZ3->Z3_COD
	If SZ4->Z4_TIPO == "2"
		Aadd(aLayout,{SZ4->Z4_CAMPO,SZ4->Z4_FORMULA,SZ4->Z4_TAMANHO})
	EndIf
	SZ4->(dbSkip())
EndDo

//--< Gera os registros >------------------------------------
ProcRegua(nTotReg)
While TMP->(!Eof())
	IncProc("Exportando...")

	dbSelectArea("AKD")
	AKD->(dbGoTo(TMP->REGNO))
	cLinha := ""

	For i := 1 To Len(aLayout)
		If !Empty(aLayout[i,1])
			cLinha += FormataTexto(AKD->&(aLayOut[i,1]))
		Else
			cLinha += SubStr(FormataTexto(&(aLayOut[i,2])),1,aLayOut[i,3])
		EndIf
	Next i
	FWrite(nHdlArquivo,cLinha+Chr(13)+Chr(10))

	TMP->(dbSkip())
EndDo

FClose(nHdlArquivo)
MsgAlert("Foi gerado o arquivo " + cArquivo)

Return(Nil)


/*/================================================================================================================================/*/
/*/{Protheus.doc} FormataTexto
Funcao de formatacao do conteudo para TEXTO

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23

@param uConteudo, Indefinido, Conteúdo a ser formatado.
@param aRetorno, Array, Retorno da rotina.

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return cRetorno, Conteúdo formatado.
/*/
/*/================================================================================================================================/*/

Static Function FormataTexto(uConteudo)

Local cRetorno := ""

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If ValType(uConteudo) == "C"
	cRetorno := uConteudo
ElseIf ValType(uConteudo) == "D"
	cRetorno := DToS(uConteudo)
ElseIf ValType(uConteudo) == "N"
	cRetorno := AllTrim(Str(uConteudo))
EndIf

Return(cRetorno)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA3F
Importacao de PLANILHAS ORCAMENTARIAS.

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23
@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SIPCOA3F()

Local aPerguntas := {}
Local aRetorno   := {}

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If AK1->(FieldPos("AK1_XAPROV"))>0
	If AK1->AK1_XAPROV <> "0"
		MsgStop("A planilha orçamentária deve estar com a situação igual a '0 - Em aberto' para que possa importar dados. Verifique!","Atenção")
		Return
	Endif
Endif

//Perguntas
Aadd(aPerguntas,{ 1,"Layout"		,Space(TamSx3('Z3_COD')[1]),"@!","","SZ3IMP","",0,	.T.})
AAdd(aPerguntas,{ 6,"Arquivo"		,Padr("",150),"",,"", 90 ,.T.,"","",GETF_LOCALHARD+GETF_NETWORKDRIVE})

If !ParamBox(aPerguntas,"Importação Planilha",@aRetorno)
	Return(Nil)
EndIf

SZ3->(dbSetOrder(1))
IF !SZ3->(dbSeek(XFilial("SZ3")+aRetorno[1]))
	MsgAlert("O layout informado não foi localizado. Verifique!")
	Return(Nil)
ENDIF

IF SZ3->Z3_TIPO <> "1" 										// importação
	MsgAlert("O layout informado não pode ser utilizado em importações. Verifique!")
	Return(Nil)
ENDIF

If !File(aRetorno[2])
	MsgAlert("Arquivo informado não foi localizado.")
	Return(Nil)
EndIf

Processa({|| SIPCOA3FPrc(aRetorno) })

Return(Nil)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA3EPrc
Processamento da importacao de planilhas.

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23

@param aRetorno, Array, Retorno da rotina.

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function SIPCOA3FPrc(aRetorno)

Local cLinha   := ""
Local nPosCO   := 0
Local nPosPer  := 0
Local nPosID   := 0
Local _cFile   := _PCO03File(aRetorno[2])
Local _cID     := ""
Local _lProces := .t.
Local i
Local _nTamLin := 0
Local aLayout  := {}
Local aDados   := {}

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Valida se o arquivo ja foi importado >----------------
dbSelectArea("AK2")
AK2->(dbOrderNickName("SIAK201"))
If AK2->(dbSeek(xFilial("AK2")+AllTrim(Upper(_cFile)) ))
	IF !MsgYesNo("Esse arquivo já foi importado anteriormente. Deseja reimportar e atualizar as informações ?")
		Return(Nil)
	ENDIF
ENDIF

//--< Recupera o layout >-----------------------------------
dbSelectArea("SZ4")
SZ4->(dbSetOrder(1))
SZ4->(dbSeek(xFilial("SZ4")+aRetorno[1] ))
While SZ4->(!Eof()) .And. SZ4->Z4_FILIAL + SZ4->Z4_COD == xFilial("SZ4")+aRetorno[1]
	If SZ4->Z4_TIPO == "1"
		Aadd(aLayout,{	SZ4->Z4_CAMPO,;
		Posicione("SX3",2,Upper(AllTrim(SZ4->Z4_CAMPO)),"SX3->X3_TIPO"),;
		Posicione("SX3",2,Upper(AllTrim(SZ4->Z4_CAMPO)),"SX3->X3_TAMANHO"),;
		Posicione("SX3",2,Upper(AllTrim(SZ4->Z4_CAMPO)),"SX3->X3_DECIMAL")})
		_nTamLin += Posicione("SX3",2,Upper(AllTrim(SZ4->Z4_CAMPO)),"SX3->X3_TAMANHO")
	EndIf
	SZ4->(dbSkip())
EndDo

If Len(aLayout) <= 0
	MsgAlert("Informe um layout válido para importação.")
	Return(Nil)
EndIf

IF (nPosCO := AScan(aLayout,{|x| AllTrim(x[1]) == "AK2_CO" })) == 0
	MsgAlert("O campo Conta Orçamentária (AK2_CO) não foi encontrado no layout.")
	Return(Nil)
ENDIF
IF (nPosPer := AScan(aLayout,{|x| AllTrim(x[1]) == "AK2_PERIOD" })) == 0
	MsgAlert("O campo Período (AK2_PERIOD) não foi encontrado no layout.")
	Return(Nil)
ENDIF
IF (nPosClasse := AScan(aLayout,{|x| AllTrim(x[1]) == "AK2_CLASSE" })) == 0
	MsgAlert("O campo Classe Orçamentária (AK2_CLASSE) não foi encontrado no layout.")
	Return(Nil)
ENDIF
IF (nPosItem := AScan(aLayout,{|x| AllTrim(x[1]) == "AK2_ITCTB" })) == 0
	MsgAlert("O campo Item Contábil (AK2_ITCTB) não foi encontrado no layout.")
	Return(Nil)
ENDIF
IF (nPosOper := AScan(aLayout,{|x| AllTrim(x[1]) == "AK2_OPER" })) == 0
	MsgAlert("O campo Operação (AK2_OPER) não foi encontrado no layout.")
	Return(Nil)
ENDIF
IF (nPosValor := AScan(aLayout,{|x| AllTrim(x[1]) == "AK2_VALOR" })) == 0
	MsgAlert("O campo Valor (AK2_VALOR) não foi encontrado no layout.")
	Return(Nil)
ENDIF
IF (nPosMoeda := AScan(aLayout,{|x| AllTrim(x[1]) == "AK2_MOEDA" })) == 0
	MsgAlert("O campo Moeda (AK2_MOEDA) não foi encontrado no layout.")
	Return(Nil)
ENDIF

Processa({|| _lProces := _PCO03Rel(aRetorno[2],aLayout,1,_nTamLin,nPosCO,nPosClasse,nPosItem,nPosOper) })	// Verifica se existem criticas no arquivo

IF !_lProces
	Return
ENDIF

FT_FUse(aRetorno[2])										//Abre o arquivo
ProcRegua(FT_FLastRec())
FT_FGoTop()

//Begin Transaction

While !FT_FEof()
	IncProc()

	cLinha := FT_FReadLn()

	aDados := {}
	nUltPos:= 1
	nTam   := 0

	//--< Faz a inclusao dos dados na tabela AK2 >----------
	For i := 1 To Len(aLayout)
		nTam 		  := aLayout[i,3]
		uConteudo := SubStr(cLinha,nUltPos,aLayout[i,3])
		nUltPos 	+= nTam

		If aLayout[i,2] == "N"
			uConteudo := Val(uConteudo)/IIF(aLayout[i,4]==0,1,100)
		ElseIf aLayout[i,2] == "D"
			uConteudo := SToD(uConteudo)
		EndIf

		Aadd(aDados,{aLayout[i,1],uConteudo})
	Next i

	dbSelectArea("AK2")
	AK2->(dbOrderNickName("SIAK202"))

	If AK2->(dbSeek(xFilial("AK2")+AK1->(AK1_CODIGO+AK1_VERSAO)+aDados[nPosClasse,2]+aDados[nPosOper,2]+aDados[nPosCO,2]+aDados[nPosItem,2]))
		_cID := AK2->AK2_ID
	ENDIF

	PcoIniLan("000252")

	If !AK2->(dbSeek(xFilial("AK2")+AK1->(AK1_CODIGO+AK1_VERSAO)+aDados[nPosClasse,2]+aDados[nPosOper,2]+aDados[nPosCO,2]+aDados[nPosItem,2]+DToS(aDados[nPosPer,2])))
		AK2->(RecLock("AK2",.T.))
		AK2->AK2_FILIAL := xFilial("AK2")
		AK2->AK2_ORCAME := AK1->AK1_CODIGO
		AK2->AK2_VERSAO := AK1->AK1_VERSAO
		AK2->AK2_XSTS	:= "0" 								// status da UO
		IF Empty(_cID)
			AK2->AK2_ID := _PCO03ID(AK1->AK1_CODIGO,AK1->AK1_VERSAO,aDados[nPosClasse,2],aDados[nPosOper,2],aDados[nPosCO,2],aDados[nPosItem,2],aDados[nPosPer,2]) //_cNextID
		ELSE
			AK2->AK2_ID := _cID
		ENDIF
	Else
		AK2->(RecLock("AK2",.F.))
	EndIf

	//--< dados do arquivo de importacao >------------------
	AK2->AK2_XFILE	:= Upper(_cFile)
	AK2->AK2_XDTIMP	:= dDataBase
	AK2->AK2_XUSER	:= __CUSERID

	For i := 1 To Len(aDados)
		AK2->&(aDados[i,1]) := aDados[i,2]
	Next i
	AK2->(MsUnlock())

	PcoDetLan("000252","01","PCOA100")

	PcoFinLan("000252")

	//Valida se existe o registro para essa conta orcamentaria na tabela AK3
	dbSelectArea("AK3")
	AK3->(dbSetOrder(1))
	If !AK3->(dbSeek(xFilial("AK3")+AK1->(AK1_CODIGO+AK1_VERSAO)+AK2->AK2_CO ))
		_aContas := _PCO03SUP(AK2->AK2_CO)
		aSort(_aContas,,,{| x,y | x[1] < y[1]})
		_cNivel := StrZero(2,TamSX3("AK3_NIVEL")[1])
		For i := 1 to Len(_aContas)
			IF AK3->(dbSeek(xFilial("AK3")+AK1->(AK1_CODIGO+AK1_VERSAO)+_aContas[i,1] ))
				_cNivel := Soma1(AK3->AK3_NIVEL)
			ELSE
				AK3->(RecLock("AK3",.T.))
				AK3->AK3_FILIAL	:= xFilial("AK3")
				AK3->AK3_ORCAME	:= AK1->AK1_CODIGO
				AK3->AK3_VERSAO	:= AK1->AK1_VERSAO
				AK3->AK3_CO		  := _aContas[i,1]
				AK3->AK3_PAI	  := IIF(!Empty(_aContas[i,2]),_aContas[i,2],AK1->AK1_CODIGO)
				AK3->AK3_TIPO	  := _aContas[i,3]
				AK3->AK3_NIVEL	:= _cNivel
				AK3->AK3_DESCRI	:= _aContas[i,4]
				AK3->(MsUnlock())
				_cNivel := Soma1(_cNivel)
			ENDIF
		Next
	EndIf

	_cID := ""

	FT_FSkip()
EndDo

FT_FUSE()

//End Transaction

MsgAlert("Importação da planilha realizada com sucesso.")

Return(Nil)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA3G
Importacao de LANCAMENTOS ORCAMENTARIOS.

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SIPCOA3G()

Local aPerguntas := {}
Local aRetorno   := {}

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Perguntas >-------------------------------------------
Aadd(aPerguntas,{ 1,"Layout"		,Space(TamSx3('Z3_COD')[1]),"@!","","SZ3IMP","",0,	.T.})
AAdd(aPerguntas,{ 6,"Arquivo"		,Padr("",150),"",,"", 90 ,.T.,"","",GETF_LOCALHARD+GETF_NETWORKDRIVE})

If !ParamBox(aPerguntas,"Importação de Lancamentos",@aRetorno)
	Return(Nil)
EndIf

SZ3->(dbSetOrder(1))
IF !SZ3->(dbSeek(XFilial("SZ3")+aRetorno[1]))
	MsgAlert("O layout informado não foi localizado. Verifique!")
	Return(Nil)
ENDIF

IF SZ3->Z3_TIPO <> "1" 										// exportação
	MsgAlert("O layout informado não pode ser utilizado em importações. Verifique!")
	Return(Nil)
ENDIF

If !File(aRetorno[2])
	MsgAlert("Arquivo informado não foi localizado.")
	Return(Nil)
EndIf

Processa({|| SIPCOA3GPrc(aRetorno) })

Return(Nil)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA3GPrc
Processamento da importacao de lancamentos.

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23

@param aRetorno, Array, Retorno da rotina.

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function SIPCOA3GPrc(aRetorno)

Local aLayout    := {}
Local aDados     := {}
Local aAKD       := {}
Local aLotes     := {}
Local aEstrutura := {}
Local cLinha     := ""
Local _cFile     := _PCO03File(aRetorno[2])
Local cArqTMP    := ""
Local _cCodLanc  := GetNewPar("SI_XCODPCO","900001")
Local _cNumLote  := GetMV("SI_XCHVIMP")
Local _nTamLin   := 0
Local _aRecno    := {}
Local _lProces   := .t.
Local _nLinha    := 1
Local i

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
AK8->(dbSetOrder(1))
IF !AK8->(dbSeek(XFilial("AK8")+_cCodLanc))
	MsgAlert("O código de lançamento "+_cCodLanc+" informado no parâmetro (SI_XCODPCO) não está cadastrado.")
	Return(Nil)
ENDIF

//--< verifica se o numero do lote esta valido >------------
AKD->(dbSetOrder(10))
IF AKD->(dbSeek(XFilial("AKD")+"IMP"+_cNumLote))
	MsgAlert("O parâmetro SI_XCHVIMP (Lotes de Importação) está com conteúdo inválido. Verifique!")
	Return(Nil)
ENDIF

//--< Recupera o layout >-----------------------------------
dbSelectArea("SZ4")
SZ4->(dbSetOrder(1))
SZ4->(dbSeek(xFilial("SZ4")+aRetorno[1] ))
While SZ4->(!Eof()) .And. SZ4->Z4_FILIAL + SZ4->Z4_COD == xFilial("SZ4")+aRetorno[1]
	If SZ4->Z4_TIPO == "2"
		Aadd(aLayout,{	SZ4->Z4_CAMPO,;
		Posicione("SX3",2,Upper(AllTrim(SZ4->Z4_CAMPO)),"SX3->X3_TIPO"),;
		Posicione("SX3",2,Upper(AllTrim(SZ4->Z4_CAMPO)),"SX3->X3_TAMANHO"),;
		Posicione("SX3",2,Upper(AllTrim(SZ4->Z4_CAMPO)),"SX3->X3_DECIMAL")})
		_nTamLin += Posicione("SX3",2,Upper(AllTrim(SZ4->Z4_CAMPO)),"SX3->X3_TAMANHO")

	EndIf
	SZ4->(dbSkip())
EndDo

If Len(aLayout) <= 0
	MsgAlert("Informe um layout válido para importação.")
	Return(Nil)
EndIf

// cria campo para tratamento da AKD_CHAVE
Aadd(aLayout,{	"AKD_CHAVE",Posicione("SX3",2,"AKD_CHAVE","SX3->X3_TIPO"),Posicione("SX3",2,"AKD_CHAVE","SX3->X3_TAMANHO"),Posicione("SX3",2,"AKD_CHAVE","SX3->X3_DECIMAL")})

IF (nPosCO := AScan(aLayout,{|x| AllTrim(x[1]) == "AKD_CO" })) == 0
	MsgAlert("O campo Conta Orçamentária (AKD_CO) não foi encontrado no layout.")
	Return(Nil)
ENDIF
IF (nPosClasse := AScan(aLayout,{|x| AllTrim(x[1]) == "AKD_CLASSE" })) == 0
	MsgAlert("O campo Classe Orçamentária (AKD_CLASSE) não foi encontrado no layout.")
	Return(Nil)
ENDIF
IF (nPosItem := AScan(aLayout,{|x| AllTrim(x[1]) == "AKD_ITCTB" })) == 0
	MsgAlert("O campo Item Contábil (AKD_ITCTB) não foi encontrado no layout.")
	Return(Nil)
ENDIF
IF (nPosOper := AScan(aLayout,{|x| AllTrim(x[1]) == "AKD_OPER" })) == 0
	MsgAlert("O campo Operação (AKD_OPER) não foi encontrado no layout.")
	Return(Nil)
ENDIF
IF (nPosPer := AScan(aLayout,{|x| AllTrim(x[1]) == "AKD_DATA" })) == 0
	MsgAlert("O campo Data (AKD_DATA) não foi encontrado no layout.")
	Return(Nil)
ENDIF
IF (nPosValor := AScan(aLayout,{|x| AllTrim(x[1]) == "AKD_VALOR1" })) == 0
	MsgAlert("O campo Valor (AKD_VALOR1) não foi encontrado no layout.")
	Return(Nil)
ENDIF

//--< Verifica se existem criticas no arquivo >-------------
Processa({|| _lProces := _PCO03Rel(aRetorno[2],aLayout,2,_nTamLin,nPosCO,nPosClasse,nPosItem,nPosOper) })

IF !_lProces
	Return
ENDIF

//--< Estrutura do arquivo temporario usado para importacao dos lancamentos >--
If Select("TMPPCO") > 0
	TMPPCO->(dbCloseArea())
EndIf

cArqTMP := CriaTrab(aLayout,.T.)
dbUseArea(.T.,__LocalDriver,cArqTMP,"TMPPCO",.T.)
dbSelectArea("TMPPCO")

//--< Valida se o arquivo ja foi importado >----------------
dbSelectArea("AKD")
AKD->(dbOrderNickName("SIAKD01"))
If AKD->(dbSeek(xFilial("AKD")+AllTrim(Upper(_cFile)) ))
	If !MsgYesNo("Esse arquivo já foi importado anteriormente. Você deseja reimportar as informações contidas no arquivo ?")
		Return(Nil)
	Else
		//--< Apaga os lancamentos >------------------------
		dbSelectArea("AKD")
		While AKD->(!Eof()) .And. AKD->AKD_FILIAL + Upper(AllTrim(AKD->AKD_XFILE)) == xFilial("AKD")+AllTrim(Upper(_cFile))
			nPosLote :=	ASCAN(aLotes, {|x| x[1] == AKD->AKD_LOTE})
			If nPosLote == 0
				aAdd(aLotes, {AKD->AKD_LOTE,{AKD->(RecNo())}})
			Else
				AAdd(aLotes[nPosLote][2],AKD->(RecNo()))
			EndIf
			Aadd(_aRecno,AKD->(RecNo()))
			AKD->(dbSkip())
		EndDo

		For _nI := 1 To Len(_aRecno)
			AKD->(DbGoto(_aRecno[_nI]))
			If AKD->AKD_STATUS=="1"
				PcoAtuSld(If(AKD->AKD_TIPO=="1","C","D"),"AKD",{-AKD->AKD_VALOR1,-AKD->AKD_VALOR2,-AKD->AKD_VALOR3,-AKD->AKD_VALOR4,-AKD->AKD_VALOR5},AKD->AKD_DATA)
			EndIf
			Reclock("AKD",.F.)
			AKD->(DbDelete())
			AKD->(MsUnLock())
		Next

	EndIf
EndIf

FT_FUse(aRetorno[2])										//Abre o arquivo
ProcRegua(FT_FLastRec())
FT_FGoTop()

While !FT_FEof()
	IncProc()

	cLinha := FT_FReadLn()

	aDados := {}
	nUltPos:= 1
	nTam   := 0

	//--< Faz a inclusao dos dados na tabela AK2 >----------
	TMPPCO->(RecLock("TMPPCO",.T.))
	For i := 1 To Len(aLayout)
		nTam 	  := aLayout[i,3]
		uConteudo := SubStr(cLinha,nUltPos,aLayout[i,3])
		nUltPos   += nTam

		If aLayout[i,2] == "N"
			uConteudo := Val(uConteudo)/IIF(aLayout[i,4]==0,1,100) //Val(uConteudo)
		ElseIf aLayout[i,2] == "D"
			uConteudo := SToD(uConteudo)
		EndIf
		TMPPCO->&(aLayout[i,1]) := uConteudo
	Next i
	TMPPCO->AKD_CHAVE := "IMP"+_cNumLote+StrZero(_nLinha,TamSX3("AKD_ID")[1])
	TMPPCO->(MsUnlock())

	_nLinha++

	FT_FSkip()
EndDo

FT_FUSE()

Begin Transaction
TMPPCO->(dbGoTop())
PCOIniLan(_cCodLanc)
While TMPPCO->(!Eof())
	PCODetLan(_cCodLanc,"01","SIPCOA03",.F.)
	TMPPCO->(dbSkip())
EndDo
PCOFinLan(_cCodLanc)
End Transaction

_cAreaAKD := AKD->(GetArea())
TMPPCO->(dbGoTop())
While TMPPCO->(!Eof())

	AKD->(dbSetOrder(10))
	IF AKD->(dbSeek(XFilial("AKD")+TMPPCO->AKD_CHAVE))
		RecLock("AKD",.f.)
		//--< dados do arquivo de importacao >--------------
		AKD->AKD_XFILE	:= Upper(_cFile)
		AKD->AKD_XDTIMP	:= dDataBase
		AKD->AKD_XUSER	:= __CUSERID
		AKD->(msUnlock())
	ENDIF

	TMPPCO->(dbSkip())
EndDo
RestArea(_cAreaAKD)

//--< incrementa parametro de lote >------------------------
PutMV("SI_XCHVIMP",Soma1(_cNumLote))

MsgAlert("Importação dos lancamentos realizada com sucesso.")

Return(Nil)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCO03Get
Processamento da importacao de lancamentos.

@type function
@author Bruno Daniel Borges - TOTVS
@since 01/01/2011
@version P12.1.23

@param _cCampo, Caractere, Campo a ser pesquisado.

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Retorna a campo pesquisado.
/*/
/*/================================================================================================================================/*/

User Function SIPCO03Get(_cCampo)

IF TMPPCO->(FieldPos(_cCampo)) == 0
	_uRet := ""
ELSE
	_uRet := TMPPCO->(&_cCampo)
ENDIF

Return(_uRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} _PCO03ID
Processamento da importacao de lancamentos.

@type function
@author TOTVS
@since 01/01/2011
@version P12.1.23

@param _cPlan, Caractere, Planilha Orçamentário.
@param _cVersao, Caractere, Versão da Planilha.
@param _cClasse, Caractere, Classe Orçamentária.
@param _cOper, Caractere, Operação.
@param _cCO, Caractere, Conta Orçamentária.
@param _cItem, Caractere, Item Orçamentário.
@param _dPeriodo, Data, Período da Planilha.

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Retorna o AK2_ID da Planilha.
/*/
/*/================================================================================================================================/*/

Static Function _PCO03ID(_cPlan,_cVersao,_cClasse,_cOper,_cCO,_cItem,_dPeriodo)
//Static Function _PCO03ID(_cPlan,_cVersao)

Local _cQuery  := ""
Local _cArqTRB := CriaTrab(nil,.f.)
Local _cRet    := StrZero(1,TamSX3("AK2_ID")[1])
Local _cArea   := GetArea()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
_cQuery := "SELECT MAX(AK2_ID) ID FROM "+RetSqlName("AK2")+" WHERE D_E_L_E_T_ = '' AND AK2_FILIAL = '"+XFilial("AK2")+"' "
_cQuery += "AND AK2_ORCAME = '"+_cPlan+"' AND AK2_VERSAO = '"+_cVersao+"' "
//_cQuery += "AND AK2_CLASSE = '"+_cClasse+"' AND AK2_OPER = '"+_cOper+"' "
_cQuery += "AND AK2_CO = '"+_cCO+"' "
//_cQuery += "AND AK2_ITCTB = '"+_cItem+"'"
_cQuery := ChangeQuery(_cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqTRB,.t.,.t.)

_cRet := Soma1((_cArqTRB)->ID)

(_cArqTRB)->(dbCloseArea())

RestArea(_cArea)

Return(_cRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} _PCO03ID
Processamento da importacao de lancamentos.

@type function
@author TOTVS
@since 01/01/2011
@version P12.1.23

@param _cConta, Caractere, Conta Orçamentária.

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Chave da AK5.
/*/
/*/================================================================================================================================/*/


Static Function _PCO03SUP(_cConta)
Local _aRet      := {}
Local _cArea     := GetArea()
Local _lContinua := .t.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
AK5->(dbSetOrder(1))
AK5->(MsSeek(xFilial("AK5")+_cConta))

Aadd(_aRet,{AK5->AK5_CODIGO,AK5->AK5_COSUP,AK5->AK5_TIPO,AK5->AK5_DESCRI})

IF Empty(_cCtaSup := AK5->AK5_COSUP)
	Return(_aRet)
ENDIF

While _lContinua
	IF AK5->(MsSeek(xFilial("AK5")+_cCtaSup))
		_cCtaSup := AK5->AK5_COSUP
		Aadd(_aRet,{AK5->AK5_CODIGO,AK5->AK5_COSUP,AK5->AK5_TIPO,AK5->AK5_DESCRI})
	ELSE
		_lContinua := .f.
	ENDIF
	Skip()
End

RestArea(_cArea)

Return(_aRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} _PCO03File
Retorna o nome do arquivo.

@type function
@author TOTVS
@since 01/01/2011
@version P12.1.23

@param _cConta, Caractere, Conta Orçamentária.

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Nome do arquivo.
/*/
/*/================================================================================================================================/*/

Static Function _PCO03File(_cArq)

Local _cRet := ""

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
For i := Len(AllTrim(_cArq)) To 1 Step -1
	If SubStr(AllTrim(_cArq),i,1) == "\"
		_cRet := SubStr(AllTrim(_cArq),i+1)
		Exit
	EndIf
Next i

Return(_cRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} _PCO03Rel
Retorna o nome do arquivo.

@type function
@author TOTVS
@since 27/09/2011
@version P12.1.23

@param _cFile, Caractere, Arquivo.
@param aLayout, Array, Layout do arquivo.
@param _lTipo, Lógico, Tipo da Operação.
@param _nTamLin, Numérico, Tamanho da Linha.
@param nPosCO, Numérico, Posição da Conta Orçamentária.
@param nPosClasse, Numérico, Posição da Classe Orçamentária.
@param nPosItem, Numérico, Posição do Item.
@param nPosOper, Numérico, Posição da Operação.

@obs Projeto ELO Alterado pela FIEG

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

Static Function _PCO03Rel(_cFile,aLayout,_lTipo,_nTamLin,nPosCO,nPosClasse,nPosItem,nPosOper)

Local _aCritica := {}
Local _nLinha   := 1

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Abre o arquivo >--------------------------------------
FT_FUse(_cFile)
ProcRegua(FT_FLastRec())
FT_FGoTop()

While !FT_FEof()
	IncProc("Validando registros...")

	IF Len(cLinha := FT_FReadLn()) <> _nTamLin
		MsgAlert("A estrutura do arquivo não é compatível com o layout cadastrado. Verifique!")
		FT_FUSE()
		Return .f.
	ENDIF

	aDados := {}
	nUltPos:= 1
	nTam   := 0

	//--< Faz a inclusao dos dados na tabela AK2 >----------
	For i := 1 To Len(aLayout)
		nTam 		  := aLayout[i,3]
		uConteudo := SubStr(cLinha,nUltPos,aLayout[i,3])
		nUltPos 	+= nTam

		If aLayout[i,2] == "N"
			uConteudo := Val(uConteudo)/IIF(aLayout[i,4]==0,1,100)
		ElseIf aLayout[i,2] == "D"
			uConteudo := SToD(uConteudo)
		EndIf

		Aadd(aDados,{aLayout[i,1],uConteudo})
	Next i

	//--< Criticas - Classe Orcamentaria >------------------
	AK6->(dbSetOrder(1))
	IF !Empty(aDados[nPosClasse,2]) .and. !AK6->(dbSeek(XFilial("AK6")+aDados[nPosClasse,2]))
		Aadd(_aCritica,{_nLinha,IIF(_lTipo==1,"AK2_CLASSE","AKD_CLASSE"),aDados[nPosClasse,2],"Classe não localizada"})
	ENDIF

	//--< Criticas - Operacao >-----------------------------
	AKF->(dbSetOrder(1))
	IF !Empty(aDados[nPosOper,2]) .and. !AKF->(dbSeek(XFilial("AKF")+aDados[nPosOper,2]))
		Aadd(_aCritica,{_nLinha,IIF(_lTipo==1,"AK2_OPER","AKD_OPER"),aDados[nPosOper,2],"Operação não localizada"})
	ENDIF

	//--< Criticas - Conta Orcamentaria >-------------------
	AK5->(dbSetOrder(1))
	IF !Empty(aDados[nPosCO,2]) .and. !AK5->(dbSeek(XFilial("AK5")+aDados[nPosCO,2]))
		Aadd(_aCritica,{_nLinha,IIF(_lTipo==1,"AK2_CO","AKD_CO"),aDados[nPosCO,2],"Conta Orçamentária não localizada"})
	ENDIF

	//--< Criticas - Conta Orcamentaria >-------------------
	CTD->(dbSetOrder(1))
	IF !Empty(aDados[nPosItem,2]) .and. !CTD->(dbSeek(XFilial("CTD")+aDados[nPosItem,2]))
		Aadd(_aCritica,{_nLinha,IIF(_lTipo==1,"AK2_ITCTB","AKD_ITCTB"),aDados[nPosItem,2],"Item Contábil não localizado"})
	ENDIF

	_nLinha++

	FT_FSkip()
EndDo

FT_FUSE()

//--< Chamada do Relatorio de Criticas >--------------------
IF Len(_aCritica) > 0
	IF Aviso("Atencao","Foram encontradas inconsistências no arquivo importado e o processo foi abortado."+Chr(13)+Chr(10)+"Deseja imprimir relatório ?",{"Sim","Não"}) == 1
		U_SIPCOR03(_aCritica,_cFile)
	ENDIF
ENDIF

Return(Len(_aCritica)==0)
