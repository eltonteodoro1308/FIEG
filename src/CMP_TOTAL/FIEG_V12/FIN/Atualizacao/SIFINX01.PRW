#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIFINX01
Amarracao Empresa/Filial x Cliente x Fornecedor.

@type function
@author TOTVS
@since 24/07/2012
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

STATIC _LSAIR := .F.

User Function SIFINX01()

Private cCadastro := "Amarração Entidade x Cliente x Fornecedor"
Private aRotina   := { {"Pesquisar" ,"AxPesqui"       ,0,1} ,;
					   {"Visualizar","U__FINX01Man(2)",0,2} ,;
					   {"Manutenção","U__FINX01Man(3)",0,3} ,;
					   {"Excluir"   ,"U__FINX01Man(5)",0,5} }
Private cString   := "SZE"

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
dbSelectArea(cString)
(cString)->(dbSetOrder(1))

mBrowse( 6,1,22,75,cString)

Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} _FINX01Man
Tela de Manutenção da Amarracao Empresa/Filial x Cliente x Fornecedor.

@type function
@author TOTVS
@since 24/07/2012
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function _FINX01Man(nOpc)

Local nX 	 	 := 0
Local aAlterEnch := {}
Local cIniCpos   := ""
Local cFieldOk   := "AllwaysTrue"
Local cLinhaOk   := "U_FINX01LOK()"
Local cTudoOk    := "AllwaysTrue"
Local cSuperDel  := ""
Local cDelOk     := "AllwaysTrue"
Local nOpcX		 := 0
Local aButtons   := {}

Private aHeader  := {}
Private aCols    := {}
Private oDlg
Private oBrw
Private oEnch
Private aTELA[0][0]
Private aGETS[0]

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF _LSAIR
	_LSAIR := .F.
	Return()
EndIf

cSeek  := SZE->ZE_FILIAL
cWhile := "SZE->ZE_FILIAL"
FillGetDados(4,"SZE",1,cSeek,{|| &cWhile },{|| .T. },/*aNaoCpo*/,/*aSimCpo*/,,,,,aHeader,aCols)

//--< Atualiza o item da primeira linha >-------------------
IF Empty(GdFieldGet("ZE_ITEM",1,,aHeader,aCols))
	GDFieldPut("ZE_ITEM",StrZero(1,TamSX3("ZE_ITEM")[1]),1,aHeader,aCols)
EndIf

aEval(aCols,{|x| x[GDFieldPos("ZE_NOMEMP",aHeader)] := Posicione("SM0",1,cEmpAnt+x[GDFieldPos("ZE_CODEMP",aHeader)],"M0_NOME") })
aEval(aCols,{|x| x[GDFieldPos("ZE_NOMCLI",aHeader)] := Posicione("SA1",1,XFilial("SA1")+x[GDFieldPos("ZE_CODCLI",aHeader)]+x[GDFieldPos("ZE_LOJCLI",aHeader)],"A1_NOME") })
aEval(aCols,{|x| x[GDFieldPos("ZE_FORNEC",aHeader)] := Posicione("SA2",1,XFilial("SA2")+x[GDFieldPos("ZE_CODFOR",aHeader)]+x[GDFieldPos("ZE_LOJFOR",aHeader)],"A2_NOME") })

//--< Montagem da Tela de Consulta >------------------------
aSizeAut := MsAdvSize()

DEFINE FONT oFnt 	NAME "Arial" SIZE 0, -11 BOLD

oDlg := MSDIALOG():New(0,0,500,1000, cCadastro,,,,,,,,,.T.)

If nOpc == 3
	INCLUI := .T.
	ALTERA := .F.
	nStyle := GD_INSERT+GD_UPDATE+GD_DELETE
Else
	INCLUI := .F.
	ALTERA := .F.
	nStyle := 0
Endif

oBrw := MsNewGetDados():New(1,1,1,1,nStyle,cLinhaOk,cTudoOk,"+ZE_ITEM",,,9999, cFieldOk, cSuperDel,cDelOk,oDlg, aHeader, aCols)
oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//--< Habilita botão somente na opção de manutenção >-------
IF nOpc == 3
	Aadd(aButtons,{'S4WB013N',{|| xFIN01Atu() },"Empresas","Carregar Empresas"})
EndIf

oDlg:bInit	:= {|| EnchoiceBar(oDlg, {|| nOpcX:=1 , IIf(oBrw:TudoOk() .and. Obrigatorio(aGets, aTela),oDlg:End(),nOpcX:=0)}, {||nOpcx := 0, oDlg:End()},,aButtons)}
oDlg:lCentered := .T.
oDlg:Activate()

If nOpcX == 1 .and. (nOpc == 3 .or. nOpc == 5)
	IF Aviso("Confirmação","Confirma "+IIF(nOpc==3,"atualização","exclusão")+" dos dados ?",{"Sim","Não"}) == 1
		//Gravaçao dos Dados
		MsgRun('Atualizando registros. Aguarde...',, {|| xFIN01GRV(nOpc) } )
	EndIf
	IF nOpc == 3
		_LSAIR := .T.
	EndIf
Endif

Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} xFIN01GRV
Gravacao dos Dados da Amarracao Empresa/Filial x Cliente x Fornecedor.

@type function
@author TOTVS
@since 24/07/2012
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function xFIN01GRV(nOpc)

Local bCampo := {|nCPO| Field(nCPO) }

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------

lSavTTsInUse := __TTSInUse									// Backup do TTS

__TTSInUse := .T.											// Ativa TTS

Begin Transaction

If !nOpc == 5
	
	//--< Gravacao das Distribuicoes >----------------------
	For i := 1 to Len(oBrw:aCols)
		
		//--< Desconsidera linhas sem empresa >-------------
		IF Empty(GdFieldGet("ZE_CODEMP",i,,oBrw:aHeader,oBrw:aCols))
			Loop
		EndIf
		
		_cCodItem := GdFieldGet("ZE_ITEM",i,,oBrw:aHeader,oBrw:aCols)
		
		SZE->(dbSetOrder(1))
		IF !SZE->(dbSeek(XFilial("SZE")+_cCodItem))
			IF GdDeleted(i,oBrw:aHeader,oBrw:aCols)
				Loop
			EndIf
			RecLock("SZE",.t.)
			SZE->ZE_FILIAL := xFilial("SZE")
		Else
			RecLock("SZE",.f.)
			IF GdDeleted(i,oBrw:aHeader,oBrw:aCols)
				SZE->(dbDelete())
				SZE->(msUnlock())
				Loop
			EndIf
		EndIf
		
		For x := 1 to Len(oBrw:aHeader)
			If ( oBrw:aHeader[x,10] <> "V" )
				SZE->(FieldPut(FieldPos(oBrw:aHeader[x,2]),oBrw:aCols[i,x]))
			EndIf
		Next
		
		SZE->(msUnlock())
	Next
	
Else
	
	//--< Exclusao dos registros >--------------------------
	SZE->(dbSetOrder(1))
	SZE->(MsSeek(xFilial("SZE")))
	While SZE->(!Eof()) .and. SZE->ZE_FILIAL == XFilial("SZE")
		Eval({|| RecLock("SZE",.f.), SZE->(dbDelete()), SZE->(MsUnLock()) })
		SZE->(dbSkip())
	EndDo
	
Endif

End Transaction

__TTSInUse := lSavTTsInUse									// Restaura TTS

Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} xFIN01Atu
Carrega lista de empresas da Amarracao Empresa/Filial x Cliente x Fornecedor.

@type function
@author TOTVS
@since 25/06/2012
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function xFIN01Atu()

Local lContinua := .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
IF !MsgYesNo("Confirma importação da lista de empresas ?","Confirmação")
	lContinua := .F.

ElseIf Ascan(oBrw:aCols,{|x| !Empty(x[GDFieldPos("ZE_CODEMP",oBrw:aHeader)]) }) <> 0 .and. ;
	   !MsgYesNo("Já existem dados. Deseja sobrepor ?","Confirmação")
	lContinua := .F.
EndIf

If lContinua
	OpenSm0(cEmpAnt, .T.)

	oBrw:aCols := {}

	While SM0->(!Eof())
		aAdd(oBrw:aCols,Array(Len(oBrw:aHeader)+1))
		For nX := 1 To Len(oBrw:aHeader)
			IF !(Alltrim(oBrw:aHeader[nX][2]) $ "ZE_REC_WT|ZE_ALI_WT" )
				oBrw:aCols[Len(oBrw:aCols),nX] := CriaVar(oBrw:aHeader[nX,2])
			EndIf
		Next nX
		oBrw:aCols[Len(oBrw:aCols),Len(oBrw:aHeader)+1] := .F.
		
		GDFieldPut("ZE_ITEM",StrZero(Len(oBrw:aCols),TamSX3("ZE_ITEM")[1]),Len(oBrw:aCols),oBrw:aHeader,oBrw:aCols)
		GDFieldPut("ZE_CODEMP",SM0->M0_CODFIL,Len(oBrw:aCols),oBrw:aHeader,oBrw:aCols)
		GDFieldPut("ZE_NOMEMP",SM0->M0_NOME,Len(oBrw:aCols),oBrw:aHeader,oBrw:aCols)
		
		SM0->(dbSkip())
	Enddo

	SM0->(dbCloseArea())

	oBrw:aCols := aClone(oBrw:aCols)
	oBrw:oBrowse:Refresh()
EndIf
	
Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} FINX01LOK
Validacao da linha da Amarracao Empresa/Filial x Cliente x Fornecedor.

@type function
@author TOTVS
@since 31/07/2012
@version P12.1.23

@obs Projeto ELO

@history 13/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

User Function FINX01LOK()

Local _lRet 	:= .T.
Local _aDuplic	:= {}
Local _lDuplic	:= .F.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------

For i := 1 to Len(oBrw:aCols)
	
	IF GDDeleted(i,oBrw:aHeader,oBrw:aCols)
		Loop
	EndIf
	
	IF !_lDuplic .and. Ascan(_aDuplic,GdFieldGet("ZE_CODEMP",i,,oBrw:aHeader,oBrw:aCols)) == 0
		Aadd(_aDuplic,GdFieldGet("ZE_CODEMP",i,,oBrw:aHeader,oBrw:aCols))
	Else
		_lDuplic := .T.
		Exit
	EndIf
Next

IF _lDuplic
	MsgAlert("Existe(m) empresa(s) em duplicidade. Verifique!", "Atenção")
	_lRet := .f.
EndIf

Return(_lRet)
