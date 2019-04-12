#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIATFA02
Processo especifico de Inventario de ATF - CNI.

@type function
@author Leonardo Soncin
@since 25/08/2011
@version P12.1.23

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIATFA02

	//+---------------------------------------------------------------------+
	//| Declaracao de Variaveis                                             |
	//+---------------------------------------------------------------------+

	Local aRot1	:= {	{ "Lista Inventário", "U_SIATFR02",0,2},;
	{ "Dif. Localização", "U_SIATFR05",0,2} }

	Local aRot2	:= {	{ "Responsável", "U_ATF02R01",0,4},;
	{ "Localização", "U_ATF02R02",0,4},;
	{ "Dados Contábeis", "U_ATF02R03",0,4}}  //atfa060

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Private cCadastro := "Cadastro de Inventário"

	//+---------------------------------------------------------------------+
	//| Monta um aRotina proprio                                            |
	//+---------------------------------------------------------------------+

	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
	{"Importar CSV","U_ATF02CSV",0,3} ,;
	{"Relatórios",aRot1,0,2} ,;
	{"Transferência",aRot2,0,4} ,;
	{"Conciliar","U_ATF02CNC",0,4} ,;
	{"Estornar","U_ATF02DEL",0,5} }

	//{"Visualizar","AxVisual",0,2} ,;


	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "SZC"

	dbSelectArea("SZC")
	SZC->(dbSetOrder(1))

	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ATF02CSV
Processo especifico de Inventario de ATF - CNI.

@type function
@author Leonardo Soncin
@since 25/08/2011
@version P12.1.23

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ATF02CSV

	//+---------------------------------------------------------------------+
	//| Declaracao de Variaveis                                             |
	//+---------------------------------------------------------------------+
	Local oProcess  := NIL
	Local cPathIni := "C:\" //GetSrvProfString("RootPath", "")+GetSrvProfString("Startpath", "")

	Private cFile := cGetFile("Arquivo CSV | *.csv","Selecione o arquivo CSV",,cPathIni,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE )

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If !Empty(cFile)
		oProcess := MsNewProcess():New( { | lEnd | xImpCSV( @lEnd,oProcess) }, 'Processando', 'Aguarde, processando...', .F. )
		oProcess:Activate()
	Else
		Help(" ",1,"NOFILE")
	Endif

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xImpCSV
Processo especifico de Inventario de ATF - CNI.

@type function
@author Leonardo Soncin
@since 25/08/2011
@version P12.1.23

@param lEnd, Lógica, Variável que indica se o processo deve ser interrompido ao clicar no botão cancelar.
@param oProcess, Objeto, Objeto que exibe barras de processamento.

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xImpCSV(lEnd,oProcess)

	Local nX,nY
	Local cLin		:=	""
	Local aCampo	:= {}
	Local aEstrut	:= {}
	Local aTXT		:= {}
	Local aPosCampos:= {}
	Local cAliasTrb 	:= GetNextAlias()
	Local cArqTmp	:= ""
	Local cChave	:= ""
	Local lSegue    := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aEstrut :={	{ "EMISSAO" 	, "D", 	 8, 0 },;
	{ "COD_BARRA"	, "C",  20, 0 },;
	{ "LOCALIZ"		, "C",   6, 0 },;
	{ "RESP" 		, "C", 	 6, 0 },;
	{ "CCUSTO"		, "C",  20, 0 },;
	{ "ITEM"		, "C",  20, 0 },;
	{ "CLVL"		, "C",  20, 0 },;
	{ "EMPORI"		, "C",   8, 0 }}

	cArqTmp := CriaTrab(aEstrut, .T.)
	dbUseArea( .T.,, cArqTmp, cAliasTrb, .F., .F. )

	//+--------------------------------------------------------------+
	//| Cria Indice Temporario do Arquivo de Trabalho 1.             |
	//+--------------------------------------------------------------+
	cChave   := "DTOS(EMISSAO)+LOCALIZ+RESP"

	IndRegua(cAliasTrb,cArqTmp,cChave,,,"Selecionando Registros...")
	dbSelectArea(cAliasTrb)
	dbSetIndex(cArqTmp+OrdBagExt())
	cAliasTrb->(dbSetOrder(1))

	// ESTRUTURA DO ARQUIVO TEXTO
	aAdd(aCampo,"EMISSAO")
	aAdd(aCampo,"COD_BARRA")
	aAdd(aCampo,"LOCALIZACAO")
	aAdd(aCampo,"RESPONSAVEL")
	aAdd(aCampo,"CCUSTO")
	aAdd(aCampo,"ITEM")
	aAdd(aCampo,"CLVL")
	aAdd(aCampo,"EMPORI")

	//Define o valor do array conforme estrutura
	aPosCampos:= Array(Len(aCampo))

	If (nHandle := FT_FUse(AllTrim(cFile)))== -1
		Help(" ",1,"NOFILEIMPOR")
		lSegue := .F. //Return
	EndIf

	If lSegue

		//Verifica Estrutura do Arquivo
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
			nPosCpo	:=	Ascan(aCampo,{|x| x==cCampo})
			If nPosCPO > 0
				aPosCampos[nPosCpo]:= nPos
			Endif
			cLinha	:=	Substr(cLinha,nAt+1)
		Enddo

		If (nPosNil:= Ascan(aPosCampos,Nil)) > 0
			Aviso("Estrutura de arquivo inválido.","O campo "+aCampo[nPosNil]+" nao foi encontrado na estrutura, verifique.",{"Sair"})
			lSegue := .F. //Return .F.
		Endif

		If lSegue

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

			// Gravacao dos Itens (TRB)
			FT_FUSE()
			For nX:=1 To Len(aTxt)
				For nY:=1 To Len(aCampo)
					dbSelectArea(cAliastrb)
					RecLock(cAliasTrb,.T.)
					For nY:=1 To Len(aCampo)
						If AllTrim(aCampo[nY]) == 'RESPONSAVEL'
							FieldPut(FieldPos("RESP"),aTxt[nX,aPosCampos[nY]])
						ElseIf AllTrim(aCampo[nY]) == 'LOCALIZACAO'
							FieldPut(FieldPos("LOCALIZ"),aTxt[nX,aPosCampos[nY]])
						ElseIf AllTrim(aCampo[nY]) == 'EMISSAO'
							If ValType(aTxt[nX,aPosCampos[nY]]) == "D"
								_data:= aTxt[nX,aPosCampos[nY]]
							Else
								_data:= Stod(aTxt[nX,aPosCampos[nY]])
							Endif
							FieldPut(FieldPos(aCampo[nY]),_dAta)
						Else
							FieldPut(FieldPos(aCampo[nY]),aTxt[nX,aPosCampos[nY]])
						Endif
					Next
					cAliastrb->(MsUnLock())
				Next
			Next

			dbSelectArea(cAliasTrb)
			cAliastrb->(dbGotop())

			// Inicia Gravacao no Sistema - Tabela SZC
			xAtuSZC(cAliasTrb,oProcess)

			If Select(cAliasTrb) != 0
				dbSelectArea(cAliasTrb)
				cAliastrb->(dbCloseArea())
				FErase(cArqTmp+GetDBExtension())
				FErase(cArqTmp+OrdBagExt())
			Endif

			Aviso("Importação de CSV","Processo finalizado.",{"OK"})

		End If

	End If

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xAtuSZC
Processo especifico de Inventario de ATF - CNI.

@type function
@author Leonardo Soncin
@since 25/08/2011
@version P12.1.23

@param cAliastrb, Caractere, Alias da Tabela.
@param oProcess, Objeto, Objeto que exibe barras de processamento.

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xAtuSZC(cAliastrb,oProcess)

	Local aEstrut	:= {}
	Local cAliasTmp := GetNextAlias()
	Local cArqTmp	:= ""
	Local cChave	:= ""
	Local lErro		:= .F.
	Local lGrava	:= .T.
	Local cDescBem	:= ""
	Local nTotRegs 	:= 0
	Local nProcRegs := 0
	Local lSegue    := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aEstrut :={	{ "EMISSAO" 	, "D", 	 8, 0 },;
	{ "COD_BARRA"	, "C",  20, 0 },;
	{ "DESCR"		, "C",  30, 0 },;
	{ "CONTEUDO"	, "C",  20, 0 },;
	{ "MSG"			, "C",  60, 0 }}

	cArqTmp := CriaTrab(aEstrut, .T.)
	dbUseArea( .T.,, cArqTmp, cAliasTmp, .F., .F. )

	//+--------------------------------------------------------------+
	//| Cria Indice Temporario do Arquivo de Trabalho.               |
	//+--------------------------------------------------------------+
	cChave   := "DTOS(EMISSAO)+COD_BARRA"

	IndRegua(cAliasTmp,cArqTmp,cChave,,,"Criando Arquivo Temporário...")
	dbSelectArea(cAliasTmp)
	dbSetIndex(cArqTmp+OrdBagExt())
	cAliasTmp->(dbSetOrder(1))

	//Validacoes
	dbSelectArea("SZC")
	SZC->(dbSetOrder(1))
	If SZC->(dbSeek(xFilial("SZC")+Dtos((cAliasTrb)->EMISSAO)+(cAliastrb)->LOCALIZ+(cAliasTrb)->RESP))
		MsgStop("Já existe informação para a data de "+Dtoc((cAliasTrb)->EMISSAO)+", localização "+(cAliastrb)->LOCALIZ+" e responsável "+(cAliasTrb)->RESP+". Verifique!")
		lSegue := .F. //Return
	Endif

	If lSegue

		dbSelectArea(cAliasTrb)

		dbEval( {|x| nTotRegs++ },,{|| (cAliasTrb)->(!EOF())})
		oProcess:SetRegua1(nTotRegs+2)
		oProcess:IncRegua1("Iniciando processamento...")
		oProcess:SetRegua2(nTotRegs+1)
		oProcess:IncRegua2("")

		// Prcessa o Arquivo e Grava
		dbSelectArea(cAliasTrb)
		cAliasTrb->(dbGotop())
		While !cAliasTrb->(Eof())

			cDescBem := xDescBem((cAliasTrb)->COD_BARRA,(cAliasTrb)->EMPORI)

			// Valida CC
			dbSelectArea("CTT")
			CTT->(dbSetOrder(1))
			If !Empty((cAliasTrb)->CCUSTO) .and. !CTT->(dbSeek(xFilial("CTT")+(cAliasTrb)->CCUSTO))
				lErro 	:= .T.
				lGrava 	:= .F.
				dbSelectArea(cAliasTmp)
				RecLock(cAliasTmp,.T.)
				(cAliasTmp)->EMISSAO 	:= (cAliasTrb)->EMISSAO
				(cAliasTmp)->COD_BARRA 	:= (cAliasTrb)->COD_BARRA
				(cAliasTmp)->DESCR		:= cDescBem
				(cAliasTmp)->CONTEUDO 	:= (cAliasTrb)->CCUSTO
				(cAliasTmp)->MSG	 	:= "Centro de Custo "+Alltrim((cAliastrb)->CCUSTO)+" não localizado na base de dados."
				cAliasTmp->(MsUnlock())
			Endif

			//Valida Item
			dbSelectArea("CTD")
			CTD->(dbSetOrder(1))
			If !Empty((cAliasTrb)->ITEM) .and. !CTD->(dbSeek(xFilial("CTD")+(cAliasTrb)->ITEM))
				lErro := .T.
				lGrava 	:= .F.
				dbSelectArea(cAliasTmp)
				RecLock(cAliasTmp,.T.)
				(cAliasTmp)->EMISSAO 	:= (cAliastrb)->EMISSAO
				(cAliasTmp)->COD_BARRA 	:= (cAliasTrb)->COD_BARRA
				(cAliasTmp)->DESCR		:= cDescBem
				(cAliasTmp)->CONTEUDO 	:= (cAliasTrb)->ITEM
				(cAliasTmp)->MSG	 	:= "Item Contábil "+Alltrim((cAliasTrb)->ITEM)+" não localizado na base de dados."
				cAliasTmp->(MsUnlock())
			Endif

			//Valida Classe de Valor
			dbSelectArea("CTH")
			CTH->(dbSetOrder(1))
			If !Empty((cAliasTrb)->CLVL) .and. !CTH->(dbSeek(xFilial("CTH")+(cAliasTrb)->CLVL))
				lErro := .T.
				lGrava 	:= .F.
				dbSelectArea(cAliasTmp)
				RecLock(cAliasTmp,.T.)
				(cAliasTmp)->EMISSAO 	:= (cAliasTrb)->EMISSAO
				(cAliasTmp)->COD_BARRA 	:= (cAliasTrb)->COD_BARRA
				(cAliasTmp)->DESCR		:= cDescBem
				(cAliasTmp)->CONTEUDO 	:= (cAliasTrb)->CLVL
				(cAliasTmp)->MSG	 	:= "Classe de Valor "+Alltrim((cAliasTrb)->CLVL)+" não localizada na base de dados."
				cAliasTmp->(MsUnlock())
			Endif

			//Valida Responsavel
			dbSelectArea("RD0")
			RD0->(dbSetOrder(1))
			If !Empty((cAliasTrb)->RESP) .and. !RD0->(dbSeek(xFilial("RD0")+(cAliasTrb)->RESP))
				lErro := .T.
				lGrava 	:= .F.
				dbSelectArea(cAliasTmp)
				RecLock(cAliasTmp,.T.)
				(cAliasTmp)->EMISSAO 	:= (cAliasTrb)->EMISSAO
				(cAliasTmp)->COD_BARRA 	:= (cAliasTrb)->COD_BARRA
				(cAliasTmp)->DESCR		:= cDescBem
				(cAliasTmp)->CONTEUDO 	:= (cAliasTrb)->RESP
				(cAliasTmp)->MSG	 	:= "Responsável "+Alltrim((cAliasTrb)->RESP)+" não localizado na base de dados."
				cAliasTmp->(MsUnlock())
			Endif

			//Valida Localizacao
			dbSelectArea("SNL")
			SNL->(dbSetOrder(1))
			If !Empty((cAliasTrb)->LOCALIZ) .and. !SNL->(dbSeek(xFilial("SNL")+(cAliasTrb)->LOCALIZ))
				lErro := .T.
				lGrava 	:= .F.
				dbSelectArea(cAliasTmp)
				RecLock(cAliasTmp,.T.)
				(cAliasTmp)->EMISSAO 	:= (cAliastrb)->EMISSAO
				(cAliasTmp)->COD_BARRA 	:= (cAliasTrb)->COD_BARRA
				(cAliasTmp)->DESCR		:= cDescBem
				(cAliasTmp)->CONTEUDO 	:= (cAliasTrb)->LOCALIZ
				(cAliasTmp)->MSG	 	:= "Localização "+Alltrim((cAliasTrb)->LOCALIZ)+" não localizada na base de dados."
				cAliasTmp->(MsUnlock())
			Endif

			//Valida Empresa
			aAreaSM0 := GetArea("SM0")
			dbSelectArea("SM0")
			If !Empty((cAliasTrb)->EMPORI) .and. !SM0->(dbSeek(cEmpAnt+(cAliasTrb)->EMPORI))
				lErro := .T.
				lGrava 	:= .F.
				dbSelectArea(cAliasTmp)
				RecLock(cAliasTmp,.T.)
				(cAliasTmp)->EMISSAO 	:= (cAliastrb)->EMISSAO
				(cAliasTmp)->COD_BARRA 	:= (cAliasTrb)->COD_BARRA
				(cAliasTmp)->DESCR		:= cDescBem
				(cAliasTmp)->CONTEUDO 	:= (cAliasTrb)->EMPORI
				(cAliasTmp)->MSG	 	:= "Empresa "+Alltrim((cAliasTrb)->EMPORI)+" não localizada na base de dados. Gr. Empresa: "+cEmpAnt
				cAliasTmp->(MsUnlock())
			Endif
			RestArea(aAreaSM0)

			If lGrava
				dbSelectArea("SZC")
				RecLock("SZC",.T.)
				SZC->ZC_FILIAL 		:= xFilial("SZC")
				SZC->ZC_EMISSAO 	:= (cAliasTrb)->EMISSAO
				SZC->ZC_CODBAR 		:= (cAliasTrb)->COD_BARRA
				SZC->ZC_LOCALIZ		:= (cAliasTrb)->LOCALIZ
				SZC->ZC_RESP		:= (cAliasTrb)->RESP
				SZC->ZC_CC			:= (cAliasTrb)->CCUSTO
				SZC->ZC_ITEM		:= (cAliasTrb)->ITEM
				SZC->ZC_CLVL		:= (cAliasTrb)->CLVL
				SZC->ZC_EMPORI		:= (cAliasTrb)->EMPORI
				SZC->ZC_STATUS		:= "3"
				SZC->(MsUnlock())

				// Chama rotina de conciliacao
				xConcilia()

				nProcRegs++
				oProcess:IncRegua2("Codigo de Barra: "+(cAliasTrb)->COD_BARRA)

			Endif

			oProcess:IncRegua1("Processando item: "+CValToChar(nProcRegs)+" / "+CValToChar(nTotRegs))

			dbSelectArea(cAliasTrb)
			cAliasTrb->(dbSkip())
			lGrava := .T.

		Enddo


		If lErro
			//Chama Impressao do Relatorio de Inconsistencias
			If ApMsgYesNo("Ocorreram inconsistências durante a importação dos dados, deseja imprimir o log?","Log de Inconsistências")
				xRelInc(cAliasTmp,"Inconsistências da Importação")
			Endif
		Endif

	Endif

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ATF02DEL
Processo especifico de Inventario de ATF - CNI.

@type function
@author Leonardo Soncin
@since 25/08/2011
@version P12.1.23

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ATF02DEL

	Local cPerg := "AF2DEL"

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	ValidPerg(cPerg)

	If Pergunte(cPerg,.T.)

		If MsgYesNo("Confirma deleção dos registros?","Confirma estorno? Sim/Não")
			dbSelectArea("SZC")
			SZC->(dbSetOrder(1))
			SZC->(dbGotop())
			SZC->(dbSeek(xFilial("SZC")+DTOS(MV_PAR01),.T.))

			While !Eof() .and. SZC->ZC_FILIAL == xFilial("SZC") .AND. SZC->ZC_EMISSAO <= MV_PAR02
				RecLock("SZC",.F.)
				SZC->(dbDelete())
				SZC->(MsUnlock())
				SZC->(dbSkip())
			EndDo
		Endif

	Endif

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xRelInc
Relatorio de Inconsistencias (Importacao e Transferencia.

@type function
@author Leonardo Soncin
@since 29/08/2011
@version P12.1.23

@param _cAlias, Caractere, Alias da Tabela.
@param _cTitulo, Caractere, Título do Relatório.

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xRelInc(_cAlias,_cTitulo)

	//+---------------------------------------------------------------------+
	//| Declaracao de Variaveis                                             |
	//+---------------------------------------------------------------------+

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2        := "de acordo com os parametros informados pelo usuario."
	Local cDesc3        := _cTitulo
	Local cPict       	:= ""
	Local titulo       	:= _cTitulo
	Local nLin         	:= 80
	Local Cabec1       	:= "Emissão    Cod. Barra         Descrição                        Conteúdo              Mensagem"
	//1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789123456789123456789123456789
	//0        1         2         3         4         5         6         7         8         9         1
	Local Cabec2       	:= ""
	Local imprime      	:= .T.
	Local aOrd 			:= {}
	Local lSegue        := .T.
	Private lEnd      	:= .F.
	Private lAbortPrint	:= .F.
	Private CbTxt     	:= ""
	Private limite   	:= 132
	Private tamanho  	:= "M"
	Private nomeprog 	:= "SIATFA02"
	Private nTipo     	:= 18
	Private aReturn  	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey	:= 0
	//Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "SIATFA02"
	Private cString		:= _cAlias

	dbSelectArea(cString)
	cString->(dbSetOrder(1))

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+---------------------------------------------------------------------+
	//| Monta a interface padrao com o usuario...                           |
	//+---------------------------------------------------------------------+

	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

	If nLastKey == 27
		lSegue := .F. //Return
	Endif

	If lSegue

		SetDefault(aReturn,cString)

		If nLastKey == 27
			lSegue := .F. //Return
		Endif

		If lSegue

			nTipo := If(aReturn[4]==1,15,18)

			//+---------------------------------------------------------------------+
			//| Processamento. RPTSTATUS monta janela com a regua de processamento. |
			//+---------------------------------------------------------------------+

			RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

		End If

	End If

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} RunReport
Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.

@type function
@author Thiago Rasmussen
@since 29/08/11
@version P12.1.23

@param Cabec1, Caractere, Cabeçalho 1 do Relatório.
@param Cabec2, Caractere, Cabeçalho 2 do Relatório.
@param Titulo, Caractere, Título do Relatório.
@param nLin, Numérico, Númerod a Linha.

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	//Local nOrdem
	//Local nTamLin := 50

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea(cString)
	cString->(dbSetOrder(1))

	//+---------------------------------------------------------------------+
	//| SETREGUA -> Indica quantos registros serao processados para a regua |
	//+---------------------------------------------------------------------+

	SetRegua(RecCount())

	cString->(dbGoTop())
	While !EOF()

		//+---------------------------------------------------------------------+
		//| Verifica o cancelamento pelo usuario...                             |
		//+---------------------------------------------------------------------+

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//+---------------------------------------------------------------------+
		//| Impressao do cabecalho do relatorio. . .                            |
		//+---------------------------------------------------------------------+

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		@nLin,000 PSAY Dtoc((cString)->EMISSAO)
		@nLin,011 PSAY (cString)->COD_BARRA
		@nLin,030 PSAY (cString)->DESCR
		@nLin,063 PSAY (cString)->CONTEUDO

		//	@nLin,085 PSAY (cString)->MSG

		cAux1:= Dtoc((cString)->EMISSAO)
		cAux2:= (cString)->COD_BARRA
		cAux3:= (cString)->DESCR
		cAux4:= (cString)->CONTEUDO

		While cAux1 == Dtoc((cString)->EMISSAO) .And.;
		cAux2 ==(cString)->COD_BARRA
			cAux3 ==(cString)->DESCR
			cAux4 == (cString)->CONTEUDO
			@nLin,085 PSAY (cString)->MSG
			nLin := nLin + 1 // Avanca a linha de impressao
			IncRegua()
			cString->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		End

	EndDo

	//+---------------------------------------------------------------------+
	//| Finaliza a execucao do relatorio...                                 |
	//+---------------------------------------------------------------------+

	SET DEVICE TO SCREEN

	//+---------------------------------------------------------------------+
	//| Se impressao em disco, chama o gerenciador de impressao...          |
	//+---------------------------------------------------------------------+

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xConcilia
Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.

@type function
@author Thiago Rasmussen
@since 29/08/11
@version P12.1.23

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xConcilia()

	Local _cQuery := ""
	Local cAliasTMP1 := GetNextAlias()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cQuery :=  "SELECT N1_DESCRIC, N1_LOCAL, N3_CUSTBEM, N3_SUBCCON, N3_CLVLCON, ND_CODRESP "
	_cQuery +=  "FROM "+RetSqlName("SN1")+" SN1 "
	_cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SN3")+" SN3 ON N3_FILIAL = '"+Alltrim(SZC->ZC_EMPORI)+"' AND N3_CBASE = N1_CBASE	AND N3_ITEM = N1_ITEM AND SN3.D_E_L_E_T_ = '' "
	_cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SND")+" SND ON ND_FILIAL = '"+Alltrim(SZC->ZC_EMPORI)+"' AND ND_CBASE = N1_CBASE	AND ND_ITEM = N1_ITEM AND SND.D_E_L_E_T_ = '' AND SND.ND_STATUS = '1' "
	_cQuery +=  "WHERE N1_FILIAL = '"+Alltrim(SZC->ZC_EMPORI)+"' AND "
	_cQuery +=  "N1_CODBAR = '"+SZC->ZC_CODBAR+"' AND "
	_cQuery +=  "SN1.D_E_L_E_T_ = '' "
	_cQuery := ChangeQuery(_cQuery)

	If Select(cAliasTMP1) > 0
		dbSelectArea(cAliasTMP1)
		cAliasTMP1->(dbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP1,.T.,.F.)

	DbSelectArea(cAliasTMP1)
	cAliasTMP1->(dbGotop())

	If cAliasTMP1->(!Eof())
		dbSelectArea("SZC")
		RecLock("SZC",.F.)
		SZC->ZC_DESCBEM := (cAliasTMP1)->N1_DESCRIC
		SZC->ZC_XLOCAL 	:= (cAliasTMP1)->N1_LOCAL
		SZC->ZC_XRESP 	:= (cAliasTMP1)->ND_CODRESP
		SZC->ZC_XCC 	:= (cAliasTMP1)->N3_CUSTBEM
		SZC->ZC_XITEM 	:= (cAliasTMP1)->N3_SUBCCON
		SZC->ZC_XCLVL 	:= (cAliasTMP1)->N3_CLVLCON

		If ZC_LOCALIZ+ZC_RESP+ZC_CC+ZC_ITEM+ZC_CLVL == ZC_XLOCAL+ZC_XRESP+ZC_XCC+ZC_XITEM+ZC_XCLVL
			SZC->ZC_STATUS 	:= "1"
		Else
			SZC->ZC_STATUS 	:= "2"
		Endif

		SZC->(MsUnLock())
	Endif

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ValidPerg
Cria as Perguntas para Fatura para locacao de Bens Moveis.

@type function
@author Wagner Gomes
@since 10/12/2009
@version P12.1.23

@param cPerg, Caractere, Nome da Pergunta.

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function ValidPerg(cPerg)

	Local _sAlias := Alias()
	Local aRegs := {}
	Local i//,j

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	cPerg := PADR(cPerg,10)

	If cPerg = "AF2DEL"

		// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
		aAdd(aRegs,{cPerg,"01","Emissão de:  "				,"mv_ch1","D",08,0,0,"G","naovazio()","mv_par01","","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"02","Emissão até: "				,"mv_ch2","D",08,0,0,"G","naovazio() .and. mv_par02>=mv_par01","mv_par02","","","","","","","","","","","","","","","",""})

	Else

		// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
		aAdd(aRegs,{cPerg,"01","Codigo de Barras de:  "		,"mv_ch1","C",20,0,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"02","Codigo de Barras até: "		,"mv_ch2","C",20,0,0,"G","","mv_par02","","","","","","","","","","","","","","","",""})

	Endif

	For i := 1 to Len(aRegs)
		PutSX1(aRegs[i,1],aRegs[i,2],aRegs[i,3],aRegs[i,3],aRegs[i,3],aRegs[i,4],aRegs[i,5],aRegs[i,6],aRegs[i,7],;
		aRegs[i,8],aRegs[i,9],aRegs[i,10],iif(len(aRegs[i])>=26,aRegs[i,26],""),aRegs[i,27],"",aRegs[i,11],aRegs[i,12],;
		aRegs[i,12],aRegs[i,12],aRegs[i,13],aRegs[i,15],aRegs[i,15],aRegs[i,15],aRegs[i,18],aRegs[i,18],aRegs[i,18],;
		aRegs[i,21],aRegs[i,21],aRegs[i,21],aRegs[i,24],aRegs[i,24],aRegs[i,24])

	Next i

	dbSelectArea(_sAlias)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ATF02CNC
Conciliacao dos Registros.

@type function
@author Leonardo Soncin
@since 25/08/2011
@version P12.1.23

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ATF02CNC

	Local aArea := GetArea()
	Local oProcess  := NIL

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If ApMsgYesNo("Confirma conciliação dos itens?","Conciliação")
		oProcess := MsNewProcess():New( { | lEnd | xConcl( @lEnd,oProcess) }, 'Processando', 'Aguarde, processando...', .F. )
		oProcess:Activate()
	Endif

	Aviso("Conciliação","Processo finalizado.",{"OK"})

	RestArea(aArea)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xConcl
Conciliação dos Itens.

@type function
@author Thiago Rasmussen
@since 25/08/2011
@version P12.1.23

@param lEnd, Lógica, Variável que indica se o processo deve ser interrompido ao clicar no botão cancelar.
@param oProcess, Objeto, Objeto que exibe barras de processamento.

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xConcl(lEnd,oProcess)

	Local cFilter 	:= "ZC_STATUS == '3'"
	Local nTotRegs 	:= 0
	Local nProcRegs := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("SZC")
	Set Filter To &(cFilter)

	dbEval( {|x| nTotRegs++ },,{|| SZC->(!EOF())})
	oProcess:SetRegua1(nTotRegs+2)
	oProcess:IncRegua1("Iniciando processamento...")

	SZC->(dbGotop())
	While ! SZC->(Eof())

		xConcilia()

		nProcRegs++
		oProcess:IncRegua1("Processando item: "+CValToChar(nProcRegs)+" / "+CValToChar(nTotRegs))

		dbSelectArea("SZC")
		SZC->(dbSkip())
	Enddo

	dbClearFilter()

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ATF02R02
Processo especifico de Inventario de ATF - CNI.

@type function
@author Leonardo Soncin
@since 25/08/11
@version P12.1.23

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ATF02R02

	Local cPerg := "AF2TRF"
	Local aArea := GetArea()
	Local oProcess  := NIL

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	ValidPerg(cPerg)
	If Pergunte(cPerg,.T.)
		If ApMsgYesNo("Confirma a transferência de locais?","Transferência")
			oProcess := MsNewProcess():New( { | lEnd | xTrfLoc( @lEnd,oProcess) }, 'Processando', 'Aguarde, processando...', .F. )
			oProcess:Activate()
		Endif
	Endif

	Aviso("Transferência","Processo finalizado.",{"OK"})

	RestArea(aArea)
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xTrfLoc
Processo especifico de Inventario de ATF - CNI.

@type function
@author Leonardo Soncin
@since 25/08/11
@version P12.1.23

@param lEnd, Lógica, Variável que indica se o processo deve ser interrompido ao clicar no botão cancelar.
@param oProcess, Objeto, Objeto que exibe barras de processamento.

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xTrfLoc(lEnd,oProcess)

	Local _cQuery := ""
	Local cAliasTMP2 := GetNextAlias()
	Local nProcRegs	  := 0
	Local nTotRegs	  := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cQuery :=  "SELECT ZC_CODBAR, ZC_EMPORI, ZC_LOCALIZ, ZC_EMPORI, N1_CBASE, N1_ITEM, SZC.R_E_C_N_O_ AS RECNOSZC "
	_cQuery +=  "FROM "+RetSqlName("SZC")+" SZC "
	_cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SN1")+" SN1 ON N1_FILIAL = ZC_EMPORI AND N1_CODBAR = ZC_CODBAR AND SN1.D_E_L_E_T_ = '' "
	_cQuery +=  " WHERE ZC_FILIAL = '"+xFilial("SZC")+"' AND "
	_cQuery +=  "ZC_CODBAR BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	_cQuery +=  "ZC_STATUS = '2' AND "
	_cQuery +=  "SZC.D_E_L_E_T_ = '' "
	_cQuery := ChangeQuery(_cQuery)

	If Select(cAliasTMP2) > 0
		dbSelectArea(cAliasTMP2)
		cAliasTMP2->(dbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP2,.T.,.F.)

	DbSelectArea(cAliasTMP2)

	dbEval( {|x| nTotRegs++ },,{|| (cAliasTMP2)->(!EOF())})
	oProcess:SetRegua1(nTotRegs+2)
	oProcess:IncRegua1("Iniciando processamento...")
	oProcess:SetRegua2(nTotRegs+1)
	oProcess:IncRegua2("")

	cAliasTMP2->(dbGotop())

	While !Eof()

		dbSelectArea("SN1")
		SN1->(dbSetOrder(1))
		SN1->(dbSeek(Alltrim((cAliasTMP2)->ZC_EMPORI)+(cAliasTMP2)->(N1_CBASE+N1_ITEM)))
		RecLock("SN1",.F.)
		SN1->N1_LOCAL := (cAliasTMP2)->ZC_LOCALIZ
		SN1->(MsUnlock())

		dbSelectArea("SZC")
		SZC->(dbSetOrder(1))
		SN1->(dbGoto((cAliasTMP2)->RECNOSZC))

		xConcilia()

		nProcRegs++
		oProcess:IncRegua1("Processando item: "+CValToChar(nProcRegs)+" / "+CValToChar(nTotRegs))
		oProcess:IncRegua2("Codigo de Barra: "+(cAliasTMP2)->ZC_CODBAR)

		DbSelectArea(cAliasTMP2)
		cAliasTMP2->(dbSkip())
	EndDo

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xDescBem
Processo especifico de Inventario de ATF - CNI.

@type function
@author Leonardo Soncin
@since 25/08/2011
@version P12.1.23

@param cCodBar, Caractere, Código da Filial.
@param _cEmpOri, Caractere, Código de Barras.

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Descrição do Bem Ativo Imobilizado.

/*/
/*/================================================================================================================================/*/

Static Function xDescBem(cCodBar,_cEmpOri)

	Local cDescr := ""
	Local _cQuery := ""
	Local cAliasTMP3 := GetNextAlias()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cQuery :=  "SELECT N1_DESCRIC "
	_cQuery +=  "FROM "+RetSqlName("SN1")+" SN1 "
	_cQuery +=  "WHERE N1_FILIAL = '"+_cEmpOri+"' AND "
	_cQuery +=  "N1_CODBAR = '"+cCodBar+"' AND "
	_cQuery +=  "SN1.D_E_L_E_T_ = '' "
	_cQuery := ChangeQuery(_cQuery)

	If Select(cAliasTMP3) > 0
		dbSelectArea(cAliasTMP3)
		cAliasTMP3->(dbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP3,.T.,.F.)

	dbSelectArea(cAliasTMP3)

	If !cAliasTMP3->(Eof())
		cDescr := (cAliasTMP3)->N1_DESCRIC
	Endif

Return cDescr

/*/================================================================================================================================/*/
/*/{Protheus.doc} ATF02R01
Processo especifico de Inventario de ATF - CNI.

@type function
@author Leonardo Soncin
@since 25/08/2011
@version P12.1.23

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ATF02R01
	Local cPerg := "AF2TRF"
	Local aArea := GetArea()
	Local oProcess  := NIL

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	ValidPerg(cPerg)
	If Pergunte(cPerg,.T.)
		If ApMsgYesNo("Confirma a transferência de responsáveis?","Transferência")
			oProcess := MsNewProcess():New( { | lEnd | xTrfResp( @lEnd,oProcess) }, 'Processando', 'Aguarde, processando...', .F. )
			oProcess:Activate()
		Endif
	Endif

	Aviso("Transferência","Processo finalizado.",{"OK"})

	RestArea(aArea)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xTrfResp
Processo especifico de Inventario de ATF - CNI.

@type function
@author Leonardo Soncin
@since 25/08/2011
@version P12.1.23

@param lEnd, Lógica, Variável que indica se o processo deve ser interrompido ao clicar no botão cancelar.
@param oProcess, Objeto, Objeto que exibe barras de processamento.

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xTrfResp(lEnd,oProcess)

	Local _cQuery := ""
	Local cAliasTMP2 := GetNextAlias()
	Local nProcRegs	  := 0
	Local nTotRegs	  := 0
	Local __cFilOri	  := cFilAnt

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	_cQuery :=  "SELECT ZC_CODBAR, ZC_RESP, ZC_XRESP, ZC_EMPORI, N1_CBASE, N1_ITEM, SZC.R_E_C_N_O_ AS RECNOSZC "
	_cQuery +=  "FROM "+RetSqlName("SZC")+" SZC "
	_cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SN1")+" SN1 ON N1_FILIAL = ZC_EMPORI AND N1_CODBAR = ZC_CODBAR AND SN1.D_E_L_E_T_ = '' "
	_cQuery +=  " WHERE ZC_FILIAL = '"+xFilial("SZC")+"' AND "
	_cQuery +=  "ZC_CODBAR BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	_cQuery +=  "ZC_STATUS = '2' AND "
	_cQuery +=  "ZC_RESP <> ZC_XRESP AND "
	_cQuery +=  "SZC.D_E_L_E_T_ = '' "
	_cQuery := ChangeQuery(_cQuery)

	If Select(cAliasTMP2) > 0
		dbSelectArea(cAliasTMP2)
		cAliasTMP2->(dbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP2,.T.,.F.)

	DbSelectArea(cAliasTMP2)

	dbEval( {|x| nTotRegs++ },,{|| (cAliasTMP2)->(!EOF())})
	oProcess:SetRegua1(nTotRegs+2)
	oProcess:IncRegua1("Iniciando processamento...")
	oProcess:SetRegua2(nTotRegs+1)
	oProcess:IncRegua2("")

	cAliasTMP2->(dbGotop())

	While !Eof()

		dbSelectArea("SN1")
		SN1->(dbSetOrder(1))
		SN1->(dbSeek(Alltrim((cAliasTMP2)->ZC_EMPORI)+(cAliasTMP2)->(N1_CBASE+N1_ITEM)))

		cFilAnt := (cAliasTMP2)->(ZC_EMPORI)

		If Af190GrTrans(SN1->N1_CBASE,SN1->N1_ITEM,(cAliasTMP2)->ZC_XRESP,(cAliasTMP2)->ZC_RESP)

			dbSelectArea("SZC")
			SZC->(dbSetOrder(1))
			SZC->(dbGoto((cAliasTMP2)->RECNOSZC))

			cFilAnt := __cFilOri

			xConcilia()

			nProcRegs++
			oProcess:IncRegua1("Processando item: "+CValToChar(nProcRegs)+" / "+CValToChar(nTotRegs))
			oProcess:IncRegua2("Codigo de Barra: "+(cAliasTMP2)->ZC_CODBAR)

		Endif

		DbSelectArea(cAliasTMP2)
		cAliasTMP2->(dbSkip())
	EndDo

	cFilAnt := __cFilOri

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} ATF02R03
Processo especifico de Inventario de ATF - CNI.

@type function
@author Leonardo Soncin
@since 25/08/2011
@version P12.1.23

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function ATF02R03
	Local cPerg := "AF2TRF"
	Local aArea := GetArea()
	Local oProcess  := NIL

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	ValidPerg(cPerg)
	If Pergunte(cPerg,.T.)
		If ApMsgYesNo("Confirma a transferência de dados contábeis?","Transferência")
			oProcess := MsNewProcess():New( { | lEnd | xTrfCtb( @lEnd,oProcess) }, 'Processando', 'Aguarde, processando...', .F. )
			oProcess:Activate()
		Endif
	Endif

	Aviso("Transferência","Processo finalizado.",{"OK"})

	RestArea(aArea)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xTrfCtb
Processo especifico de Inventario de ATF - CNI.

@type function
@author Leonardo Soncin
@since 25/08/2011
@version P12.1.23

@param lEnd, Lógica, Variável que indica se o processo deve ser interrompido ao clicar no botão cancelar.
@param oProcess, Objeto, Objeto que exibe barras de processamento.

@obs Projeto ELO

@history 15/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xTrfCtb(lEnd,oProcess)
	Local _cQuery := ""
	Local cAliasTMP := GetNextAlias()
	Local cAliasTMP2 := GetNextAlias()
	Local nProcRegs	  := 0
	Local nTotRegs	  := 0
	Local aDadosAuto 	:= {}         // Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica
	Local aEstrut		:= {}
	Local lErro := .F.
	Local nTamLin := 50
	Local _cErroAuto := ""
	Local __cFilOri := cFilAnt
	Private lMsHelpAuto := .f.        // Determina se as mensagens de help devem ser direcionadas para o arq. de log
	Private lMsErroAuto := .f.        // Determina se houve alguma inconsistencia na execucao da rotina em relacao aos

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	aEstrut :={	{ "EMISSAO" 	, "D", 	 8, 0 },;
	{ "COD_BARRA"	, "C",  20, 0 },;
	{ "DESCR"		, "C",  30, 0 },;
	{ "CONTEUDO"	, "C",  20, 0 },;
	{ "MSG"			, "C",  60, 0 }}

	cArqTmp := CriaTrab(aEstrut, .T.)
	dbUseArea( .T.,, cArqTmp, cAliasTmp, .F., .F. )

	//+--------------------------------------------------------------+
	//| Cria Indice Temporario do Arquivo de Trabalho.               |
	//+--------------------------------------------------------------+
	cChave   := "DTOS(EMISSAO)+COD_BARRA"

	IndRegua(cAliasTmp,cArqTmp,cChave,,,"Criando Arquivo Temporário...")
	dbSelectArea(cAliasTmp)
	dbSetIndex(cArqTmp+OrdBagExt())
	cAliasTmp->(dbSetOrder(1))

	_cQuery :=  "SELECT ZC_EMISSAO, ZC_CODBAR, ZC_CC, ZC_CLVL, ZC_ITEM, ZC_EMPORI, N1_CBASE, N1_ITEM, N1_DESCRIC, SZC.R_E_C_N_O_ AS RECNOSZC "
	_cQuery +=  "FROM "+RetSqlName("SZC")+" SZC "
	_cQuery +=  "LEFT OUTER JOIN "+RetSqlName("SN1")+" SN1 ON N1_FILIAL = ZC_EMPORI AND N1_CODBAR = ZC_CODBAR AND SN1.D_E_L_E_T_ = '' "
	_cQuery +=  " WHERE ZC_FILIAL = '"+xFilial("SZC")+"' AND "
	_cQuery +=  "ZC_CODBAR BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	_cQuery +=  "ZC_STATUS = '2' AND "
	_cQuery +=  "SZC.D_E_L_E_T_ = '' "
	_cQuery := ChangeQuery(_cQuery)

	If Select(cAliasTMP2) > 0
		dbSelectArea(cAliasTMP2)
		cAliasTMP2->(dbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasTMP2,.T.,.F.)

	DbSelectArea(cAliasTMP2)

	dbEval( {|x| nTotRegs++ },,{|| (cAliasTMP2)->(!EOF())})
	oProcess:SetRegua1(nTotRegs+2)
	oProcess:IncRegua1("Iniciando processamento...")
	oProcess:SetRegua2(nTotRegs+1)
	oProcess:IncRegua2("")

	cAliasTMP2->(dbGotop())

	While !Eof()

		aDadosAuto:= {  {'N3_FILIAL'	,(cAliasTMP2)->ZC_EMPORI		, Nil},;        // Filial
		{'N3_CBASE'		,(cAliasTMP2)->N1_CBASE		, Nil},;        // Codigo base do ativo
		{'N3_ITEM'  	,(cAliasTMP2)->N1_ITEM		, Nil},;        // Item sequencial do codigo bas do ativo
		{'N4_DATA'  	,dDataBase					, Nil},;        // Data da Transferencia
		{'N3_CUSTBEM' 	,(cAliasTMP2)->ZC_CC   		, Nil},;        // Centro de Custo de Despesa
		{'N3_SUBCCON' 	,(cAliasTMP2)->ZC_ITEM 		, Nil},;        // Item Contabil da Despesa
		{'N3_CLVLCON' 	,(cAliasTMP2)->ZC_CLVL    	, Nil}}         // Classe de Valor da Despesa

		cFilAnt := (cAliasTMP2)->ZC_EMPORI

		MSExecAuto({|x, y, z| AtfA060(x, y, z)},aDadosAuto, 4)

		cFilAnt := __cFilOri

		If lMsErroAuto

			_cArqAuto 	:= NomeAutoLog()
			//MostraErro()
			_cErroAuto 	:= MemoRead(_cArqAuto)
			_cErroAuto 	:= Iif(Empty(_cErroAuto),"Erro na Execução do MsExecauto. Verificar log.",_cErroAuto)

			lErro := .T.
			dbSelectArea(cAliasTmp)

			nLinMsg := mlCount(_cErroAuto, nTamLin) //Total de linhas da Mensagem

			For nContador := 1 To nLinMsg
				RecLock(cAliasTmp,.T.)
				(cAliasTmp)->EMISSAO 	:= Stod((cAliasTMP2)->ZC_EMISSAO)
				(cAliasTmp)->COD_BARRA 	:= (cAliasTMP2)->ZC_CODBAR
				(cAliasTmp)->DESCR		:= (cAliasTMP2)->N1_DESCRIC
				(cAliasTmp)->CONTEUDO 	:= Memoline(_cErroAuto,nTamLin,1)
				(cAliasTmp)->MSG	:=  IIf(!Empty(Alltrim(Memoline(_cErroAuto,nTamlin,nContador))),Alltrim(Memoline(_cErroAuto,nTamlin,nContador)),' ') //)+Space(1)+Alltrim(Memoline(_cErroAuto,132,3))
				cAliasTmp->(MsUnlock())
			Next


		Else

			dbSelectArea("SZC")
			SZC->(dbSetOrder(1))
			SZC->(dbGoto((cAliasTMP2)->RECNOSZC))

			xConcilia()

			nProcRegs++

		EndIf

		oProcess:IncRegua1("Processando item: "+CValToChar(nProcRegs)+" / "+CValToChar(nTotRegs))
		oProcess:IncRegua2("Codigo de Barra: "+(cAliasTMP2)->ZC_CODBAR)

		DbSelectArea(cAliasTMP2)
		cAliasTMP2->(dbSkip())

		aDadosAuto  := {}
		lMsErroAuto := .f.

	EndDo

	If lErro
		//Chama Impressao do Relatorio de Inconsistencias
		If ApMsgYesNo("Ocorreram inconsistências durante a transferência dos dados, deseja imprimir o log?","Log de Inconsistências")
			xRelInc(cAliasTmp,"Inconsistências da Transferência")
		Endif
	Endif

Return
