#Include "Protheus.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "topconn.ch"

Static GRID_STEP
//Static __lBlind      := IsBlind()

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA16
Importacao de Planilha CSV de orçamento.

@type function
@author Leonardo Soncin
@since 17/11/2011
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

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
	{ 1 ,"Planilha orçamentária"	,Replicate(" ",LEN(AK1->AK1_CODIGO)),"@!" 	 ,""  ,"AK1" ,".F." ,65 ,.T. },;
	{ 1 ,"Revisão"					,Replicate(" ",LEN(AKE->AKE_REVISA)),"@!" 	 ,""  ,"AKE1",".F." ,65 ,.T. },;
	{ 1 ,"Conta orcamentária de"	,Replicate(" ",LEN(AK2->AK2_CO)) 	,"@!" 	 ,""  ,"AK5" ,"" ,65 ,.F. },;
	{ 1 ,"Conta orcamentária até"	,Replicate(" ",LEN(AK2->AK2_CO)) 	,"@!" 	 ,""  ,"AK5" ,"" ,65 ,.T. },;
	{ 1 ,"Centro de custo de"		,Replicate(" ",LEN(AK2->AK2_CC)) 	,"@!" 	 ,""  ,"CTT" ,"" ,65 ,.F. },;
	{ 1 ,"Centro de custo até"		,Replicate(" ",LEN(AK2->AK2_CC)) 	,"@!" 	 ,""  ,"CTT" ,"" ,65 ,.T. },;
	{ 1 ,"Item contábil de"			,Replicate(" ",LEN(AK2->AK2_ITCTB)) ,"@!" 	 ,""  ,"CTD" ,"" ,65 ,.F. },;
	{ 1 ,"Item contábil até"		,Replicate(" ",LEN(AK2->AK2_ITCTB)) ,"@!" 	 ,""  ,"CTD" ,"" ,65 ,.T. },;
	{ 1 ,"Classe de valor de"		,Replicate(" ",LEN(AK2->AK2_CLVLR)) ,"@!" 	 ,""  ,"CTH" ,"" ,65 ,.F. },;
	{ 1 ,"Classe de valor até"		,Replicate(" ",LEN(AK2->AK2_CLVLR)) ,"@!" 	 ,""  ,"CTH" ,"" ,65 ,.T. },;
	{ 2 ,"Apagar itens da planilha"	,1 ,{"1=Não apagar itens da planilha","2=Sim. Apagar itens na faixa informada"} ,100, "", .T.},;
	{ 6	,"Arquivo"					,Space(60),"",,"",90 ,.T.,"",'',GETF_LOCALHARD+GETF_LOCALFLOPPY}}

	Local aConfig := {AK1->AK1_FILIAL,AK1->AK1_CODIGO,IF(Empty(AK1->AK1_VERREV), AK1->AK1_VERSAO, AK1->AK1_VERREV),Replicate(" ",LEN(AK2->AK2_CO)),Replicate("Z",LEN(AK2->AK2_CO)),Replicate(" ",LEN(AK2->AK2_CC)),Replicate("Z",LEN(AK2->AK2_CC)),Replicate(" ",LEN(AK2->AK2_ITCTB)),Replicate("Z",LEN(AK2->AK2_ITCTB)),Replicate(" ",LEN(AK2->AK2_CLVLR)),Replicate("Z",LEN(AK2->AK2_CLVLR)),"1",""}
	Local aPerAux  := {}
	Local lSegue   := .T.
	PRIVATE aAuxCps
	PRIVATE cRevisa
	PRIVATE cPlanAnt := ""
	PRIVATE cCtaOrc := ""
	Private cPlanOri 	:= AK1->AK1_CODIGO
	Private cRevOri 	:= IF(Empty(AK1->AK1_VERREV), AK1->AK1_VERSAO, AK1->AK1_VERREV)
	Private cCtaOri 	:= AK3->AK3_CO
	Private aPeriodo 	:= PcoRetPer()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("AK3")
	AK3->(dbSeek(xFilial("AK3")+cPlanOri+cRevOri+cPlanOri))

	If AK1->(FieldPos("AK1_XAPROV"))>0
		If AK1->AK1_XAPROV <> "0"
			MsgStop("A planilha orçamentária deve estar com a situação igual a '0 - Em aberto' para que possa importar dados. Verifique!","Atenção")

			RestArea(aAreaAK1)
			RestArea(aAreaAK2)
			RestArea(aAreaAK3)
			RestArea(aAreaAKE)

			lSegue := .F.
		Endif
	Endif

	If lSegue

		oWizard := APWizard():New("Atenção"/*<chTitle>*/,;
		"Este assistente lhe ajudara a importar os dados de um arquivo CSV para uma planilha orçamentária."/*<chMsg>*/, "Importação para Planilha Orçamentária"/*<cTitle>*/, ;
		"Você deverá indicar os parâmetros e ao finalizar o assistente, os dados serão importados conforme os parâmetros solicitados."/*<cText>*/,;
		{||.T.}/*<bNext>*/, ;
		{||.T.}/*<bFinish>*/,;
		/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

		oWizard:NewPanel( "Parâmetros"/*<chTitle>*/,;
		"Neste passo você deverá informar os parâmetros para importação da planilha orçamentária."/*<chMsg>*/, ;
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

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} Plan_Box
Funcao para escolha da planilha a ser copiada.

@type function
@author Paulo Carnelossi
@since 16/05/2005
@version P12.1.23

@param oWizard, Objeto, Objeto que representa o Wizard.
@param lParam, Lógico, Indica se restaura os conteuúdos das variáveis MV_PAR.
@param aParametros, Array, Array com parâmetros do Parambox.
@param aConfig, Array, Array recebido por referência a ser populado com os valores dos parâmetros do Parambox.

@obs Projeto ELO alterado pela FIEG

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function Plan_Box(oWizard, lParam, aParametros, aConfig)
	LOCAL cLoad		:= ""						// Nome do arquivo aonde as respostas do usuário serão salvas / lidas
	LOCAL lCanSave	:= .T.						// Se as respostas para as perguntas podem ser salvas
	LOCAL lUserSave := .T.						// Se o usuário pode salvar sua propria configuracao

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If lParam == NIL
		ParamBox(aParametros ,"Parametros", @aConfig,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel], cLoad, lCanSave, lUserSave)
		lParam := .T.
	Else
		Rest_Par(aConfig)
	EndIf

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} Rest_Par
Funcao para restauracao dos conteudos das variaveis MV_PAR na navegacao entre os paineis do assistente de copia.

@type function
@author Paulo Carnelossi
@since 16/05/2005
@version P12.1.23

@param aParam, Array, Array recebido por referência a ser populado com os valores dos parâmetros do Parambox.

@obs Projeto ELO alterado pela FIEG

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function Rest_Par(aParam)
	Local nX
	Local cVarMem

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	For nX := 1 TO Len(aParam)
		cVarMem := "MV_PAR"+AllTrim(STRZERO(nX,2,0))
		&(cVarMem) := aParam[nX]
	Next

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} Fim_Wiz
Funcao para execução das rotinas de cópias quando pressionar o botão Finalizar do assistente de cópia.

@type function
@author Paulo Carnelossi
@since 16/05/2005
@version P12.1.23

@param aConfig, Array, Array com os valores selecionados na ParamBox.
@param cCtaOrc, Caractere, Conta Orçamentária.
@param cPlanOri, Caractere, Plano Original.
@param cRevOri, Caractere, Revisão Original.
@param aPeriodo, Array, Array de períodos.
@param aPerAux, Array, Array de Períodos Auxiliares.
@param lEnd, Lógico, Variável que indica se foi clicado o Botão Cancelar.
@param oProcess, Objeto, Obejto que representa o controle de processamente.

@obs Projeto ELO alterado pela FIEG

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro e Falso indicando se foi possível processar o arquivo.

/*/
/*/================================================================================================================================/*/

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
	Local lSegue    := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+---------------------------------+
	//| Estrutura do arquivo temporario |
	//+---------------------------------+
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

	//+---------------------------+
	//| Cria o arquivo temporario |
	//+---------------------------+
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

	//+--------------------------------------------------------------+
	//| Abre o arquivo a ser importado                               |
	//+--------------------------------------------------------------+

	If (nHandle := FT_FUse(AllTrim(MV_PAR13)))== -1
		Help(" ",1,"NOFILE")
		lSegue := .F.
		lRet := .F.
	EndIf

	// Valida se o Arquivo é CSV
	If lSegue .And. upper(Right(Alltrim(MV_PAR13),3)) <> "CSV"
		Help(" ",1, "ARQINV","Arquivo inválido","O arquivo de importação não é um arquivo CSV.",1,0 )
		fClose(nHandle)
		lSegue := .F.
		lRet := .F.
	Endif

	If lSegue

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
			Aviso("Estrutura incorreta.","O campo "+aCampos[nPosNil]+" não foi encontrado na estrutura do arquivo, por favor verifique.",{"Sair"})
			fClose(nHandle)
			lSegue := .F.
			lRet := .F.
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

			// Gravacao dos Itens no TRB
			FT_FUSE()
			For nX:=1 To Len(aTxt)
				dbSelectArea(cAliasTmp)
				RecLock((cAliasTmp),.T.)
				(cAliasTmp)->LINHA 		:= Alltrim(Str(nX))
				For nY:=1 To Len(aCampos)
					//For nY:=1 To Len(aCampos)
					If AllTrim(aCampos[nY]) $ cCposPer
						//_nValor	:= Val(aTxt[nX,aPosCampos[nY]])
						_nValor	:= val(strtran(StrTran(    aTxt[nX,aPosCampos[nY]] ,".","") ,",","." )    )  //Ana
						(cAliasTmp)->&("P"+StrTran(AllTrim(aCampos[nY]),"/","")) := _nValor

					Else
						FieldPut(FieldPos(aCampos[nY]),aTxt[nX,aPosCampos[nY]])
					Endif
					//Next

				Next
				(cAliasTmp)->(MsUnLock())
			Next

			dbSelectArea(cAliasTmp)
			(cAliasTmp)->(dbGotop())

			xImpOrc(lEnd,oProcess,cAliasTmp,aPeriodo,cPlanOri,cRevOri,aConfig)

			//+-------------+
			//| Apaga o TMP	|
			//+-------------+
			If Select(cAliasTmp) != 0
				dbSelectArea(cAliasTmp)
				(cAliasTmp)->(dbCloseArea())
				FErase(cNomeArq+GetDBExtension())
				FErase(cNomeArq+OrdBagExt())
			Endif

			fClose(nHandle)

		Endif

	EndIf

Return(lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} xProc
Monta Processamento.

@type function
@author Thiago Rasmussen
@since 02/08/2012
@version P12.1.23

@param aConfig, Array, Array com os valores selecionados na ParamBox.
@param cCtaOrc, Caractere, Conta Orçamentária.
@param cPlanOri, Caractere, Plano Original.
@param cRevOri, Caractere, Revisão Original.
@param cPlanOri, Caractere, Plano Original.
@param aPeriodo, Array, Array de períodos.
@param aPerAux, Array, Array de Períodos Auxiliares.

@obs Projeto ELO alterado pela FIEG

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

Static Function xProc(aConfig, cCtaOrc, cPlanOri, cRevOri, cPlanOri, aPeriodo, aPerAux)
	Local oProcess

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	oProcess:= MsNewProcess():New({|lEnd| Fim_Wiz(aConfig, cCtaOrc, cPlanOri, cRevOri, aPeriodo, aPerAux,.F.,oProcess)})
	oProcess:Activate()

Return .T.

/*/================================================================================================================================/*/
/*/{Protheus.doc} xImpOrc
Exporta cadastro do plano de contas referencial se já foi utilizada em alguma outra rotina.

@type function
@author Felipe A. Melo
@since 17/09/2008
@version P12.1.23

@param lEnd, Lógico, Variável que indica se foi clicado o Botão Cancelar.
@param oProcess, Objeto, Obejto que representa o controle de processamente.
@param cAliasTmp, Caractere, Alias da Tabela Temporária.
@param aPeriodo, Array, Array de períodos.
@param cPlanOri, Caractere, Plano Original.
@param cRevOri, Caractere, Revisão Original.
@param aConfig, Array, Array com os valores selecionados na ParamBox.

@obs Projeto ELO alterado pela FIEG

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorna Verdadeiro indicando que houve erro.

/*/
/*/================================================================================================================================/*/

Static Function xImpOrc(lEnd,oProcess,cAliasTmp,aPeriodo,cPlanOri,cRevOri,aConfig)
	LOCAL nProcRegs	:= 0
	LOCAL nTotRegs	:= 0
	Local cChavPla 	:= AK1->(AK1_FILIAL+AK1_CODIGO+AK1_VERSAO)
	Local cTexto 	:= ""
	Local cFile  	:= IIF(upper(Right(Alltrim(MV_PAR13),3)) == "CSV",Substr(Alltrim(MV_PAR13),1,Len(Alltrim(MV_PAR13))-4),Alltrim(MV_PAR13))+".LOG"
	Local lErro		:= .F.
	Local lSegue    := .F.

	Private _nMaxReg:= 0
	Private _nTotReg:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbEval( {|x| nTotRegs++ },,{|| (cAliasTmp)->(!EOF())})
	oProcess:SetRegua1(nTotRegs)
	oProcess:IncRegua1("Iniciando processamento...")
	oProcess:SetRegua2(nTotRegs)
	oProcess:IncRegua2("Aguarde...")

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
	(cAliasTmp)->(dbGotop())

	WHILE (cAliasTmp)->(!EOF())

		nProcRegs++
		oProcess:IncRegua1("Validando arquivo item: "+CValToChar(nProcRegs)+" / "+CValToChar(nTotRegs))

		// Valida Registros e Gerar Log

		// Valida Chave da Planilha Orcamentaria
		If (cAliasTmp)->AK2_FILIAL+AK2_ORCAME+AK2_VERSAO <> cChavPla
			cTexto += "A chave da planilha orçamentária: "+Alltrim((cAliasTmp)->AK2_FILIAL+AK2_ORCAME+AK2_VERSAO)+", informada no arquivo CSV, não é a mesma da planilha posicionada."+CRLF
			lErro := .T.
		Endif

		// Valida Existencia da Conta Orcamentaria
		dbSelectArea("AK5")
		AK5->(dbSetOrder(1))
		If AK5->(!dbSeek(xFilial("AK5")+(cAliasTmp)->AK2_CO))
			cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A conta orçamentária: "+Alltrim((cAliasTmp)->AK2_CO )+" informada no arquivo CSV, não existe no sistema."+CRLF
			lErro := .T.
		ElseIf AK5->AK5_TIPO <> "2"
			cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A conta orçamentária: "+Alltrim((cAliasTmp)->AK2_CO )+" não é analítica."+CRLF
			lErro := .T.
		Elseif AK5->AK5_MSBLQL == "1"
			IF !(Alltrim((cAliasTmp)->AK2_CO)$cTexto)
				cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A conta orçamentária: "+Alltrim((cAliasTmp)->AK2_CO )+" está bloqueada para uso."+CRLF
				lErro := .T.
			ENDIF
		Endif

		// Valida Existencia do Centro de Custo
		If !Empty((cAliasTmp)->AK2_CC)
			dbSelectArea("CTT")
			CTT->(dbSetOrder(1))
			If CTT->(!dbSeek(xFilial("CTT")+(cAliasTmp)->AK2_CC))
				cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A U.O.: "+Alltrim((cAliasTmp)->AK2_CC)+" informada no arquivo CSV, não existe no sistema."+CRLF
				lErro := .T.
			ElseIf CTT->CTT_CLASSE <> "2"
				cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A U.O.: "+Alltrim((cAliasTmp)->AK2_CC)+" não é analítica."+CRLF
				lErro := .T.
			ElseIf !ValidaBloq((cAliasTmp)->AK2_CC,Date(),"CTT",.f.)
				cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A U.O.: "+Alltrim((cAliasTmp)->AK2_CC)+" está bloqueada para uso."+CRLF
				lErro := .T.
			Endif
		Endif

		// Valida Existencia do Item Contabil
		If !Empty((cAliasTmp)->AK2_ITCTB)
			dbSelectArea("CTD")
			CTD->(dbSetOrder(1))
			If CTD->(!dbSeek(xFilial("CTD")+(cAliasTmp)->AK2_ITCTB))
				cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - O C.R.: "+Alltrim((cAliasTmp)->AK2_ITCTB)+" informado no arquivo CSV, não existe no sistema."+CRLF
				lErro := .T.
			ElseIf CTD->CTD_CLASSE <> "2"
				cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - O C.R.: "+Alltrim((cAliasTmp)->AK2_ITCTB)+" não é analítico."+CRLF
				lErro := .T.
			Elseif !ValidaBloq((cAliasTmp)->AK2_ITCTB,Date(),"CTD",.f.)
				cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - O C.R.: "+Alltrim((cAliasTmp)->AK2_ITCTB)+" está bloqueado para uso."+CRLF
				lErro := .T.
			Endif
		Endif

		// Valida Existencia da Classe de Valor
		If !Empty((cAliasTmp)->AK2_CLVLR)
			dbSelectArea("CTH")
			CTH->(dbSetOrder(1))
			If CTH->(!dbSeek(xFilial("CTH")+(cAliasTmp)->AK2_CLVLR))
				cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A classe de valor: "+Alltrim((cAliasTmp)->AK2_CLVLR)+", informada no arquivo CSV, não existe no sistema."+CRLF
				lErro := .T.
			ElseIf CTH->CTH_CLASSE <> "2"
				cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A classe de valor: "+Alltrim((cAliasTmp)->AK2_CLVLR)+", não é analítica."+CRLF
				lErro := .T.
			ElseIf !ValidaBloq((cAliasTmp)->AK2_CLVLR,Date(),"CTH",.f.)
				cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A classe de valor: "+Alltrim((cAliasTmp)->AK2_CLVLR)+", está bloqueada para uso."+CRLF
				lErro := .T.
			Endif
		Endif

		// Valida Existencia da Classe Orcamentaria
		dbSelectArea("AK6")
		AK6->(dbSetOrder(1))
		If AK6->(!dbSeek(xFilial("AK6")+(cAliasTmp)->AK2_CLASSE))
			cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A classe orçámentária: "+Alltrim((cAliasTmp)->AK2_CLASSE)+", informada no arquivo CSV, não existe no sistema."+CRLF
			lErro := .T.
		Endif

		// Valida Existencia da Operação Orçamentaria
		//	If !Empty((cAliasTmp)->AK2_OPER)
		dbSelectArea("AKF")
		AKF->(dbSetOrder(1))
		If AKF->(!dbSeek(xFilial("AKF")+(cAliasTmp)->AK2_OPER))
			cTexto += "Linha " + Alltrim((cAliasTmp)->LINHA)+ " - A operação orçamentária: "+Alltrim((cAliasTmp)->AK2_OPER)+", informada no arquivo CSV, não existe no sistema."+CRLF
			lErro := .T.
		Endif
		//	Endif


		DbSelectArea(cAliasTmp)
		(cAliasTmp)->(DbSkip())

	Enddo

	If lErro
		MsgStop("Ocorreram erros na validação do arquivo CSV. O processo foi abortado!"+CRLF+"Por favor, verifique o arquivo "+Alltrim(cFile)+" gerado no mesmo diretório do arquivo importado para mais detalhes.","Atenção")
	Else

		If (Aviso("Importação da Planilha","Confirma a importação dos dados conforme parâmetros informados?",{"Sim","Não"},1)==1)

			//Apagar os dados ou nao
			If MV_PAR12 == "1"
				//			IF Aviso("Os itens existentes na Planilha Orçamentária serão MANTIDOS conforme parâmetro selecionado.",{"Continuar","Abortar"},1) <> 1
				IF Aviso("Atenção","Os itens existentes na Planilha Orçamentária serão MANTIDOS conforme parâmetro selecionado.",{"Continuar","Abortar"},1) <> 1
					lSegue := .F.
				ENDIF
			Else
				IF Aviso("Atenção","Os itens existentes na Planilha Orçamentária serão APAGADOS conforme parâmetro selecionado.",{"Continuar","Abortar"},1) <> 1
					lSegue := .F.
				ENDIF
				//Apaga os Dados
				xDelOrcTrh()
			Endif

			If lSegue

				// Processa Importacao
				DbSelectArea(cAliasTmp)
				(cAliasTmp)->(dbGotop())

				While (cAliasTmp)->(!Eof())

					cCtaOrc := (cAliasTmp)->AK2_CO
					oProcess:IncRegua2("Gravando registros AK2/AK3..: "+cCtaOrc)
					//PcoIniLan('000252')
					xGeraOrc(cAliasTmp,cCtaOrc,aPeriodo,cPlanOri,cRevOri)

					dbSelectArea(cAliasTmp)
					(cAliasTmp)->(dbSkip())
				EndDo

				oProcess:IncRegua2("Aguarde atualização de Lançamentos...")
				MsgRun('Atualizando Lançamentos (AKD). Por favor aguarde....',, {|| xPcoA122(AK1->(RecNo())) } )

			EndIf

		Endif

		If lSegue

			cTexto += "Importação realizada com sucesso!"+CRLF

		EndIf

	Endif

	If lSegue

		cTexto += Replicate( "-", 128 ) + CRLF
		cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
		cTexto += Replicate( "-", 128 ) + CRLF

		MemoWrite( cFile, cTexto )

		If !lErro
			Aviso("Importação de Planilha","A importação foi concluída com êxito!"+CRLF+CRLF+"Por favor, verifique o arquivo "+Alltrim(cFile)+" gerado no mesmo diretório do arquivo importado para mais detalhes."+CRLF+CRLF+"É necessário fechar a planilha orçamentária e abri-la novamente para visualizar os dados importados.",{"OK"},2)
		Endif

	Endif

Return lErro

/*/================================================================================================================================/*/
/*/{Protheus.doc} xDelOrcTrh
Deleta dados da Pl. Orcamentaria antes da importacao do csv.

@type function
@author Claudinei Ferreira
@since 22/08/2013
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xDelOrcTrh()
	//Local cAliasDel := GetNextAlias()
	Local cCommand  := ""
	Local cPlanRev	:= MV_PAR02
	Local cVersPlan	:= MV_PAR03

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+----------------------------------------+
	//| Deleta lancamentos da AKD (PCODetlan)  |
	//+----------------------------------------+
	P122CDELL(cPlanRev, cVersPlan, "01")

	//+------------------------+
	//|Exclui registros da AK2 |
	//+------------------------+
	cCommand := "UPDATE "
	cCommand += RetSqlName("AK2")+" "
	cCommand += " SET D_E_L_E_T_='*',R_E_C_D_E_L_ = R_E_C_N_O_ "
	cCommand += " WHERE AK2_FILIAL = '"+MV_PAR01+"' AND AK2_ORCAME = '"+MV_PAR02+"'  AND AK2_VERSAO = '"+MV_PAR03+"' AND "
	cCommand += " D_E_L_E_T_ <> '*' "

	//+-------------------------------------+
	//|Executa expressao SQL e atualiza TOP |
	//+-------------------------------------+
	BeginTran()
	TcSqlExec(cCommand)
	TcRefresh(RetSqlName("AK2"))
	EndTran()

	//+------------------------+
	//|Exclui registros da AK3 |
	//+------------------------+
	cCommand := "UPDATE "
	cCommand += RetSqlName("AK3")+" "
	cCommand += " SET D_E_L_E_T_='*',R_E_C_D_E_L_ = R_E_C_N_O_ "
	cCommand += " WHERE AK3_FILIAL = '"+MV_PAR01+"' AND AK3_ORCAME = '"+MV_PAR02+"'  AND AK3_VERSAO = '"+MV_PAR03+"' AND "
	cCommand += " AK3_ORCAME <> AK3_CO AND "
	cCommand += " D_E_L_E_T_ = ' ' "

	//+-------------------------------------+
	//|Executa expressao SQL e atualiza TOP |
	//+-------------------------------------+
	BeginTran()
	TcSqlExec(cCommand)
	TcRefresh(RetSqlName("AK3"))
	EndTran()

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xGeraOrc
Deleta dados da Pl. Orcamentaria antes da importacao do csv.

@type function
@author Leonardo Soncin
@since 27/11/2011
@version P12.1.23

@param cAliasTmp, Caractere, Alias da Tabela Temporária.
@param cCtaOrc, Caractere, Conta Orçamentária.
@param aPeriodo, Array, Array de períodos.
@param cPlanOri, Caractere, Plano Original.
@param cRevOri, Caractere, Revisão Original.

@obs Projeto ELO alterado pela FIEG

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function xGeraOrc(cAliasTmp,cCtaOrc,aPeriodo,cPlanOri,cRevOri)
	Local nX       := 0
	Local cItem	   := ""
	Local cNivel   := "001"
	Local aRecAK3  := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	For nX := 1 to Len(aPeriodo)

		IF (cAliasTmp)->&("P"+StrTran(Substr(aPeriodo[nx],1,10),"/","")) == 0
			Loop
		ENDIF

		dbSelectArea("AK2")
		AK2->(dbSetOrder(1))
		AK2->(dbSeek(xFilial()+cPlanOri+cRevOri+cCtaOrc+DTOS(CTOD(Substr(aPeriodo[nx],1,10)))+"ZZZZ",.T.))
		AK2->(dbSkip(-1))

		// BUSCA
		If xFilial("AK2")+cPlanOri+cRevOri+cCtaOrc+DTOS(CTOD(Substr(aPeriodo[nx],1,10)))==;
		AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+DTOS(AK2_PERIOD)
			cItem := Soma1(AK2->AK2_ID)
			// ALTERACAO
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

		AK2->(MsUnlock())

		dbSelectArea("AK3")
		AK3->(dbSetOrder(1))

		If AK3->(!dbSeek(xFilial('AK3')+AK2->AK2_ORCAME+AK2->AK2_VERSAO+AK2->AK2_CO))
			cNivel := "001"
			GravaAK3(AK2->AK2_ORCAME,AK2->AK2_VERSAO,AK2->AK2_CO,aRecAK3,@cNivel)

			For nt := Len(aRecAK3) to 1 Step -1
				cNivel := Soma1(cNivel)
				AK3->(dbGoto(aRecAK3[nt]))
				RecLock("AK3",.F.)
				AK3->AK3_NIVEL := cNivel
				AK3->(MsUnlock())
			Next nt
		EndIf

		_nTotReg++

	Next nX

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} GravaAK3
Inclui as contas orcamentarias ref a tab (AK3) posicionado utiliza recursividade ao chamar a funcao A200Nivel() para chamar novamente xIncConta para as contas pai.

@type function
@author Leonardo Soncin
@since 21/11/2011
@version P12.1.23

@param cOrcame, Caractere, Código do Orçamento.
@param cVersao, Caractere, Versão do Orçamento.
@param cCO, Caractere, Conta Orçamentária.
@param aRecAK3, Array, Array com lista de RECNO´s da tabela AK3.
@param cNivel, Caractere, Nível.

@obs Projeto ELO alterado pela FIEG

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function GravaAK3(cOrcame,cVersao,cCO,aRecAK3,cNivel)
	Local aArea := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("AK5")
	AK5->(dbSetOrder(1))
	If AK5->(MsSeek(xFilial()+cCO))
		PmsNewRec("AK3")
		AK3->AK3_FILIAL 	:= xFilial("AK3")
		AK3->AK3_ORCAME		:= cOrcame
		AK3->AK3_VERSAO		:= cVersao
		AK3->AK3_CO			:= cCO
		AK3->AK3_PAI		:= If(Empty(AK5->AK5_COSUP),cOrcame,AK5->AK5_COSUP)
		AK3->AK3_TIPO		:= AK5->AK5_TIPO
		AK3->AK3_DESCRI		:= AK5->AK5_DESCRI
		AK3->(MsUnlock())
		aAdd(aRecAK3,AK3->(RecNo()))
		dbSelectArea("AK3")
		AK3->(dbSetOrder(1))
		If !Empty(AK5->AK5_COSUP)
			If AK3->(!dbSeek(xFilial('AK3')+cOrcame+cVersao+AK5->AK5_COSUP))
				GravaAK3(AK2->AK2_ORCAME,AK2->AK2_VERSAO,AK5->AK5_COSUP,aRecAK3,@cNivel)
			Else
				cNivel := AK3->AK3_NIVEL
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} xPcoA122
Chamada da funcao para controle de Threads na geracao dos lancamentos da AKD.

@type function
@author Thiago Rasmussen
@since 02/09/2013
@version P12.1.23

@param nRecAK1, Numérico, RECNO da tabela AK1.

@obs Projeto ELO alterado pela FIEG

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para fim do processamento.

/*/
/*/================================================================================================================================/*/

Static Function xPcoA122(nRecAK1)

	Local nX
	Local lRet        	:= .F.
	Local cAliasTmp
	Local cQuery      	:= ""
	Local aRecGrid 		:= {}
	Local nThread		:= SuperGetMv("MV_PCOTHRD",.T.,10)
	Local cPlanRev		:= MV_PAR02
	Local cNewVers		:= MV_PAR03

	Default nRecAK1 := AK1->( Recno() )
	Private aParam:={}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	GRID_STEP:= 10000

	cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria
	//+----------------------------------------------------------------+
	//|Query para obter recnos da tabela AK2 ou AK3 da nova versao    |
	//+----------------------------------------------------------------+
	cQuery := " SELECT MIN(R_E_C_N_O_) MINRECNOAK, MAX(R_E_C_N_O_) MAXRECNOAK FROM " + RetSqlName( "AK2" )
	cQuery += " WHERE "
	cQuery += "         	AK2_FILIAL ='" + xFilial( "AK2" ) + "' "
	cQuery += "        AND AK2_ORCAME ='" + cPlanRev + "' "
	cQuery += "        AND AK2_VERSAO = '"+ cNewVers +"' "
	cQuery += "        AND D_E_L_E_T_= ' ' "

	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )

	TcSetField( cAliasTmp, "MINRECNOAK", "N", 12, 0 )
	TcSetField( cAliasTmp, "MAXRECNOAK", "N", 12, 0 )

	If (cAliasTmp)->(!Eof())

		//DISTRIBUIR EM GRID
		aRecGrid := {}
		For nX := (cAliasTmp)->MINRECNOAK TO (cAliasTmp)->MAXRECNOAK STEP GRID_STEP
			If nX + GRID_STEP > (cAliasTmp)->MAXRECNOAK
				aAdd(aRecGrid, {nx, (cAliasTmp)->MAXRECNOAK } )  //ultimo elemento do array
			Else
				aAdd(aRecGrid, {nx, nX+GRID_STEP-1} )
			EndIf
		Next

		nThread := Min( Len(aRecGrid), nThread ) //Configura a quantidade de threads pelo menor parametro ou len(arecgrid)

		oGrid := FWIPCWait():New("SI16"+cEmpAnt+StrZero(nRecAK1,9,0),10000)
		oGrid:SetThreads(nThread)
		oGrid:SetEnvironment(cEmpAnt,cFilAnt)
		oGrid:Start("U_SI16IMPLAN")

		lRet := SIA16RevPre(oGrid,aRecGrid,nThread)

	EndIf

Return(lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIA16RevPre
Funcao de Start das Threads.

@type function
@author Thiago Rasmussen
@since 02/09/2013
@version P12.1.23

@param oGrid, Objeto, Objeto que representa a Grid de processamento.
@param aRecGrid, Array, Array com os RECNO´s dos registros a serem processados.
@param nThread, Numérico, Número de Threads utilizadas no reprocessamento.

@obs Projeto ELO alterado pela FIEG

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para fim do processamento.

/*/
/*/================================================================================================================================/*/

Static Function SIA16RevPre(oGrid,aRecGrid,nThread)
	Local nRecIni
	Local nRecFim
	Local lSimu_ := .F.
	Local lRevi_ := .F.

	Local cPlanRev	:= MV_PAR02
	Local cNewVers	:= MV_PAR03
	Local cFilAKE   := xFilial("AKE")
	Local lExit     := .F.
	Local nKilled
	Local nHdl
	Local cMsgComp  := ""
	Local nX
	Local nZ

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	For nX := 1 To Len(aRecGrid)
		nRecIni := aRecGrid[nX,1]
		nRecFim := aRecGrid[nX,2]
		lRet := oGrid:Go("Chamando escrituracao...",{nRecIni, nRecFim, lSimu_, lRevi_, cPlanRev, cNewVers, nX})
		If !lRet
			Exit
		EndIf

		Sleep(5000)//Aguarda 5 seg para abertura da thread para não concorrer na criação das procedures.

	Next

	Sleep(2500*nThread)//Aguarda todas as threads abrirem para tentar fechar

	While !lExit
		nKilled := 0
		For nZ := 1 To Len(aRecGrid)
			nHdl := FOpen("xPCOA16_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0), 16)
			If nHdl >= 0
				cMsgComp += FReadStr(nHdl,100)+CRLF
				oGrid:RemoveThread(.T.)
				nKilled += 1
				FClose(nHdl)
				FErase("xPCOA16_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0))
			Else
				nHdl := FCreate("xPCOA16_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0), 16)
				If nHdl >= 0
					oGrid:RemoveThread(.T.)
					nKilled += 1
					FClose(nHdl)
					FErase("xPCOA16_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0))
				EndIf
			Endif
		Next nZ

		If nKilled == Len(aRecGrid)
			Exit
		EndIf

		Sleep(3000) //Verifica a cada 3 segundos se as threads finalizaram

	EndDo

	PcoAvisoTm(IIf(lRet,"Processo finalizado com sucesso", "Problema no processamento."),cMsgComp, {"Ok"},,,,,5000)

	oGrid:RemoveThread(.T.)

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} SI16IMPLAN
Funcao de controle de Threads.

@type function
@author Thiago Rasmussen
@since 02/09/2013
@version P12.1.23

@param cParm, Caractere, Parâmetro recebido no processamento.
@param aParam, Array, Parâmetro recebido no processamento.

@obs Projeto ELO alterado pela FIEG

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SI16IMPLAN(cParm,aParam)

	Local nRecIni   := aParam[1]
	Local nRecFim   := aParam[2]
	Local lSimulac  := aParam[3]
	Local lRevisa   := aParam[4]
	Local cPlanRev  := aParam[5]
	Local cNewVers  := aParam[6]
	Local nZ        := aParam[7]
	Local cFilAKE   := xFilial("AKE")

	Local nHdl
	Local cStart    := ""
	Local cEnd      := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	nHdl := FCreate("xPCOA16_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0), 16)

	If nHdl >= 0

		cStart := DTOC(Date())+" "+Time()
		Conout( "xPCOA16 -> "+AllTrim(Str(ThreadID()))+" STARTED ["+cStart+"] " )
		fWrite(nHdl, " STARTED ["+cStart+"]")
		//PROCESSAMENTO
		lRet := Aux_Det_Lan(nRecIni, nRecFim, lSimulac, lRevisa, cPlanRev, cNewVers)
		//
		cEnd := DTOC(Date())+" "+Time()
		If lRet
			Conout("xPCOA16 -> "+AllTrim(Str(ThreadID()))+" END   ["+cEnd+"]  OK")
			fWrite(nHdl," END ["+cEnd+"] - OK")
		Else
			Conout("xPCOA16 -> "+AllTrim(Str(ThreadID()))+" END   ["+cEnd+"]  FAILED")
			fWrite(nHdl," END ["+cEnd+"] - FAILED")
		EndIf
		FClose(nHdl)

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} Aux_Det_Lan
Chama a PcoDetLan para escriturar movimento gerado por Iniciar Revisao (distribuido).

@type function
@author Thiago Rasmussen
@since 14/06/2013
@version P12.1.23

@param nRecIni, Numérico, RECNO inicial.
@param nRecFim, Numérico, RECNO final.
@param lSimulac, Lógico, Indica se é uma simulação.
@param lRevisao, Lógico, Indica se é uma revisão.
@param cPlanRev, Caractere, Código da planilha orçamentária.
@param cNewVers, Caractere, Versão da planilha orçamentária.

@obs Projeto ELO alterado pela FIEG

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando sucesso no processamento.

/*/
/*/================================================================================================================================/*/

Static Function Aux_Det_Lan(nRecIni, nRecFim, lSimulac, lRevisao, cPlanRev, cNewVers)
	Local lRet 		:= .F.
	Local cQuery 	:= " "
	Local nCtdAK2 	:= 0
	Local nLimLin	:= GetMV("MV_PCOLIMI")
	Local nLinLote	:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//SELECT AK2
	cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria

	//+----------------------------------------------------------------+
	//|Query para obter recnos da tabela AK2 ou AK3 da nova versao    |
	//+----------------------------------------------------------------+
	cQuery := " SELECT R_E_C_N_O_ RECNOAK FROM " + RetSqlName( "AK2" )
	cQuery += " WHERE "
	cQuery += "                  AK2_FILIAL ='" + xFilial( "AK2" ) + "' "
	cQuery += "        AND AK2_ORCAME ='" + cPlanRev + "' "
	cQuery += "        AND AK2_VERSAO = '"+ cNewVers +"' "
	cQuery += "        AND R_E_C_N_O_ BETWEEN  "+ Str(nRecIni,12,0) + " AND "+ Str(nRecFim,12,0)
	cQuery += "        AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY R_E_C_N_O_ "

	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )

	TcSetField( cAliasTmp, "RECNOAK", "N", 12, 0 )
	Conout("inicio Recnos de:"+Str(nRecIni,12,0)+" Ate: "+Str(nRecFim,12,0)+" "+time())

	PcoIniLan("000252")
	While (cAliasTmp)->(!Eof())
		nRecNew := (cAliasTmp)->(RECNOAK)
		AK2->(dbGoto(nRecNew))
		nCtdAK2++
		//PcoDetLan( cProcesso, cItem, cPrograma, lDeleta, cProcDel, cAKDStatus, lAtuSld )
		PcoDetLan("000252","01","PCOA100",.F., , "1",.F.)
		nLinLote++
		(cAliasTmp)->(dbSkip())

		If nLimLin = nLinLote
			PcoFinLan("000252",/*lForceVis*/,/*lProc*/,/*lDelBlq*/,.F.)
			nLinLote:=0
			PcoIniLan("000252")
		Endif

	EndDo
	PcoFinLan("000252",/*lForceVis*/,/*lProc*/,/*lDelBlq*/,.F.)

	(cAliasTmp)->(dbCloseArea() )

	Conout("Final Recnos de: "+Str(nRecIni,12,0)+"Ate: "+Str(nRecFim,12,0)+" "+time())

	lRet := ( (nRecFim-nRecIni+1) == nCtdAK2 )

Return(lRet)