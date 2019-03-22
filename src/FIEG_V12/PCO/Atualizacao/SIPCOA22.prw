#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA22
Rotina para executar a Aprovar Orçamento.

@type function
@author Thiago Rasmussen
@since 10/01/2012
@version P12.1.23

@param _nOpc, Numérico, Código da opção selecionada.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIPCOA22(_nOpc)
	Local lContinua := .T.
	Local lSegue    := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+----------------------------------------------------------+
	//|Executa validacao para prosseguir Finalizacao da Digitacao|
	//+----------------------------------------------------------+
	If _nOpc == 1 // Aprovação
		lContinua:= VldAprOrc()
	Else // estorno de aprovação
		If AK1->AK1_XAPROV <> '2'
			MsgStop("Esta planilha não foi aprovada. Verifique!")
			lSegue := .F.
		EndIf
		lContinua := .T.
	EndIf

	If lSegue .And. lContinua
		IF Aviso("Aviso","Confirma "+IIF(_nOpc==1," aprovação "," o estorno ")+" da planilha "+AK1->(Alltrim(AK1_CODIGO)+"/"+Alltrim(AK1_VERSAO))+" ?",{"Sim","Não"}) <> 1
			lSegue := .F.
		EndIf

		If lSegue

			MsgRun(IIF(_nOpc==1,"Aprovando","Estornando")+' Orçamento. Aguarde...',, {|| _PCO22Proc(_nOpc) } )

		EndIf

	EndIf

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} _PCO22Proc
Processamento da rotina.

@type function
@author Thiago Rasmussen
@since 14/03/2012
@version P12.1.23

@param _nOpc, Numérico, Código da opção selecionada.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

Static Function _PCO22Proc(_nOpc)
	Local _nMaxReg := GetMV("MV_PCOLIMI")
	Local _nTotReg := 0

	Local cPlanRev		:= AK1->AK1_CODIGO
	Local cNewVers		:= AK1->AK1_VERSAO

	Local _cPtLanc := GetNewPar("SI_PCOAPR", "91025201" ) //Ponto de Lancamento

	Local lSegue := .F.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+----------------------------------------------------------+
	//|Verifica se ponto de lançamento existe                    |
	//+----------------------------------------------------------+
	IF !PcoExistLc(Left(_cPtLanc,6),Right(_cPtLanc,2),"1")
		MsgStop("O ponto de lançamento "+Alltrim(_cPtLanc)+" não está cadastrado. Verifique!")
		lSegue := .F. //Return()
	EndIf

	If lSegue

		//+------------------------------------------------+
		//|Atualiza campo AK1_XAPROV=2 (Aprovado COnselho) |
		//+------------------------------------------------+
		dbSelectArea('AK1')
		RecLock("AK1", .F.)
		IF _nOpc == 1 // aprovavao
			AK1->AK1_XAPROV := '2'
		Endif
		AK1->(MsUnLock())

		//+----------------------------------------------------+
		//|Exclusão/Retorno dos movimentos da revisao anterior |
		//+----------------------------------------------------+
		If !Empty( _cUltRev := _PCOVersao(AK1->AK1_CODIGO,AK1->AK1_VERSAO) )
			If _nOpc == 1
				//+----------------------------------------+
				//| Deleta lancamentos da AKD (PCODetlan)  |
				//+----------------------------------------+
				P022CDELL(AK1->AK1_CODIGO, _cUltRev, "01")
				MsgRun('Atualizando Lançamentos (AKD). Por favor aguarde....',, {|| xPcoA022(AK1->(RecNo()),AK1->AK1_VERSAO)} )
			Else
				//Geracao de lançamentos
				P022CDELL(AK1->AK1_CODIGO, AK1->AK1_VERSAO, "01")
				MsgRun('Atualizando Lançamentos (AKD). Por favor aguarde....',, {|| xPcoA022(AK1->(RecNo()),_cUltRev) } )

				//+------------------------------------------------+
				//|Atualiza campo AK1_XAPROV=2 (Aprovado COnselho) |
				//+------------------------------------------------+
				dbSelectArea('AK1')
				RecLock("AK1", .F.)
				AK1->AK1_XAPROV := '1'
				AK1->(MsUnLock())
			EndIf
		Else
			IF _nOpc == 1
				//+----------------------------------------+
				//| Deleta lancamentos da AKD (PCODetlan)  |
				//+----------------------------------------+
				MsgRun('Atualizando Lançamentos (AKD). Por favor aguarde....',, {|| xPcoA022(AK1->(RecNo()),AK1->AK1_VERSAO)} )
			Else
				//Geracao de lançamentos
				P022CDELL(AK1->AK1_CODIGO, AK1->AK1_VERSAO, "01")

				//+------------------------------------------------+
				//|Atualiza campo AK1_XAPROV=2 (Aprovado COnselho) |
				//+------------------------------------------------+
				dbSelectArea('AK1')
				RecLock("AK1", .F.)
				AK1->AK1_XAPROV := '1'
				AK1->(MsUnLock())
			EndIf
		EndIf

	EndIf

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} VldAprOrc
Valida se pode ser Aprovado o Orçamento.

@type function
@author Claudinei Ferreira
@since 11/01/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando se pode ser Aprovado o Orçamento.

/*/
/*/================================================================================================================================/*/

Static Function VldAprOrc()
	Local aArea	:= GetArea()
	Local lRet := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If AK1->AK1_XAPROV == '0'
		MsgStop("Orçamento em aberto não pode ser aprovado!","Aviso")
		lRet :=  .f.
	Endif

	If lRet .And. AK1->AK1_XAPROV == '2'
		MsgStop("Orçamento já aprovado !","Aviso")
		lRet :=  .f.
	Endif

	RestArea(aArea)
Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} _PCOVersao
Verifica e retorna a última revisao.

@type function
@author Thiago Rasmussen
@since 11/09/2012
@version P12.1.23

@param _cPlanilha, Caractere, Código da Planilha.
@param _cRev, Caractere, Código da Revisão.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, ùltima revisão.

/*/
/*/================================================================================================================================/*/

Static Function _PCOVersao(_cPlanilha,_cRev)
	Local _aArea := AKE->(GetArea())
	Local _cRet  := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	AKE->(dbSetOrder(1))
	If AKE->(MsSeek(xFilial("AKE") + _cPlanilha))
		While AKE->(!Eof()) .and. xFilial("AKE") + _cPlanilha == AKE->(AKE_FILIAL+AKE_ORCAME) .and. AKE->AKE_REVISA < _cRev
			_cRet := AKE->AKE_REVISA
			AKE->(dbSkip())
		End
	EndIf

	RestArea(_aArea)
Return(_cRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} P022CDELL
Funcão responsavel pela chamada das procedures.
exclusao dos movimentos do processo 000252 no item indicado na revisao
exclusao dos movimentos orcamentarios na revisao da planilha

@type function
@author Thiago Rasmussen
@since 24/06/2013
@version P12.1.23

@param cPlanRev, Caractere, Código da revisão da planilha.
@param cPlanVers, Caractere, Código da versão da planilha.
@param cItemProc, Caractere, Código do Item.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando que o processamento ocorreu com sucesso.

/*/
/*/================================================================================================================================/*/

Static Function P022CDELL(cPlanRev, cPlanVers, cItemProc)
	Local nProx 	:= 1
	Local aProc   	:= {}
	Local cArqTrb
	Local cArq  	:= ""
	Local lRet		:= .T.
	Local aResult	:= {}
	Local cExec  	:= ""
	Local cRet   	:= ""
	Local iX      	:= 0
	Local _cPtLanc  := GetNewPar("SI_PCOAPR", "91025201" ) //Ponto de Lancamento

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cArqTrb := CriaTrab(,.F.)
	cArq    := cArqTRB+StrZero(nProx,2)
	AADD( aProc, cArq+"_"+cEmpAnt)
	lRet    := CallXFilial( cArq )  // CallXfilial aProc[1]
	If lRet
		nProx := nProx + 1
		cArq    := cArqTRB+StrZero(nProx,2)
		cArqAKT := cArq
		AADD( aProc, cArq+"_"+cEmpAnt)           // PCOA122_Del aProc[2]
		lRet   := PCOA022_Del( cArq, aProc )
	EndIf
	If lRet
		aResult := TCSPExec( xProcedures(cArq), cFilAnt, Left(_cPtLanc,6), cItemProc, cPlanRev, cPlanVers)
		TcRefresh(RetSqlName("AKD"))
		If Empty(aResult) .Or. aResult[1] = "0"
			MsgAlert(tcsqlerror(),"Erro na Revisao - Exclusão de Lancamentos por procedure! "+ProcName())
			lRet := .F.
		EndIf
	EndIf

	For iX = 1 to Len(aProc)   // exclusao de aProc
		If TCSPExist(aProc[iX])
			cExec := "Drop procedure "+aProc[iX]
			cRet := TcSqlExec(cExec)
			If cRet <> 0
				MsgAlert("Erro na exclusao da Procedure: "+aProc[iX] + ". Excluir manualmente no banco")
			Endif
		EndIf
	Next iX

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} PCOA022_Del
Cria procedure de exclusao do AKD.

@type function
@author Thiago Rasmussen
@since 21/06/2013
@version P12.1.23

@param cArq, Caractere, Parâmetro para processamento da Função.
@param aProc, Array, Parâmetro para processamento da Função.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando que o processamento teve ou não sucesso.

/*/
/*/================================================================================================================================/*/

Static Function PCOA022_Del( cArq, aProc  )
	Local aSaveArea  := GetArea()
	Local cQuery := ""
	Local cProc := cArq+"_"+cEmpAnt
	Local lRet := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cQuery:="Create Procedure "+cProc+" ("+CRLF
	cQuery +="   @IN_FILIAL  char( "+Str(TamSX3("AK2_FILIAL")[1])+" ),"+CRLF
	cQuery +="   @IN_PROCES  char( "+Str(TamSX3("AKD_PROCES")[1])+" ),"+CRLF
	cQuery +="   @IN_ITEM    char( "+Str(TamSX3("AKD_ITEM")[1])+" ),"+CRLF
	cQuery +="   @IN_ORCAME  char( "+Str(TamSX3("AK2_ORCAME")[1])+" ),"+CRLF
	cQuery +="   @IN_VERSAO  char( "+Str(TamSX3("AK2_VERSAO")[1])+" ),"+CRLF
	cQuery +="   @OUT_RESULT char( 01 ) OutPut"+CRLF
	cQuery +=")"+CRLF
	cQuery +="as"+CRLF
	cQuery +="Declare @cAux char( 03 )"+CRLF
	cQuery +="Declare @cFil_AKD char( "+Str(TamSX3("AK2_FILIAL")[1])+" )"+CRLF
	cQuery +="Declare @cFil_AK2 char( "+Str(TamSX3("AK2_FILIAL")[1])+" )"+CRLF
	cQuery +="Declare @iRecnoAKD integer"+CRLF
	cQuery +="Declare @iNroRegs integer"+CRLF
	cQuery +="Declare @iTranCount integer"+CRLF //--Var.de ajuste para SQLServer e Sybase.

	cQuery +="begin"+CRLF
	cQuery +="   select @OUT_RESULT = '0'"+CRLF
	cQuery +="   select @iRecnoAKD  = 0"+CRLF
	cQuery +="   select @iNroRegs   = 0"+CRLF
	cQuery +="   select @cAux = 'AKD'"+CRLF
	cQuery +="   exec "+aProc[1]+" @cAux, @IN_FILIAL, @cFil_AKD OutPut"+CRLF
	cQuery +="   select @cAux = 'AK2'"+CRLF
	cQuery +="   exec "+aProc[1]+"  @cAux, @IN_FILIAL, @cFil_AK2 OutPut"+CRLF

	cQuery +="   Declare AKD_EXCLUI insensitive cursor for"+CRLF
	cQuery +="    SELECT AKD.R_E_C_N_O_"+CRLF
	cQuery +="      FROM "+RetSqlName("AKD")+" AKD, "+RetSqlName("AK2")+ " AK2 "+CRLF
	cQuery +="     WHERE AKD_FILIAL  = @cFil_AKD"+CRLF
	cQuery +="       and AKD_PROCES  = @IN_PROCES"+CRLF
	cQuery +="       and AKD_ITEM    = @IN_ITEM"+CRLF
	cQuery +="       and AKD_CHAVE   = 'AK2'||AK2_FILIAL||AK2_ORCAME||AK2_VERSAO||AK2_CO||AK2_PERIOD||AK2_ID"+CRLF   //-- PRIMEIRO INDICE DO AK2
	cQuery +="       and AKD_TIPO    IN ('1' , '2' )"+CRLF
	cQuery +="       and AKD.D_E_L_E_T_  = ' '"+CRLF
	cQuery +="       and AK2_FILIAL  = @cFil_AK2"+CRLF
	cQuery +="       and AK2_ORCAME  = @IN_ORCAME"+CRLF
	cQuery +="       and AK2_VERSAO  = @IN_VERSAO"+CRLF
	cQuery +="       and AK2.D_E_L_E_T_  = ' '"+CRLF
	cQuery +="   for read only"+CRLF
	cQuery +="   Open AKD_EXCLUI"+CRLF
	cQuery +="   Fetch AKD_EXCLUI into @iRecnoAKD"+CRLF

	cQuery +="   While (@@fetch_status = 0 ) begin"+CRLF
	cQuery +="      select @iNroRegs = @iNroRegs + 1"+CRLF
	cQuery +="      if @iNroRegs  = 1 begin"+CRLF
	cQuery +="         Begin Transaction"+CRLF
	cQuery +="         select @iNroRegs  = @iNroRegs"+CRLF
	cQuery +="      end"+CRLF
	/* ---------------------------------------------------
	Exlui AKD
	--------------------------------------------------- */
	cQuery +="      Delete from "+RetSqlName("AKD")+" Where R_E_C_N_O_ = @iRecnoAKD"+CRLF
	cQuery +="      if @iNroRegs  >= 15000 begin"+CRLF
	cQuery +="         Commit Transaction"+CRLF
	cQuery +="         Select @iNroRegs  = 0"+CRLF
	cQuery +="      end"+CRLF

	cQuery +="      Fetch AKD_EXCLUI into @iRecnoAKD"+CRLF
	cQuery +="   End"+CRLF
	cQuery +="   if @iNroRegs  > 0 begin "+CRLF
	cQuery +="      Commit Transaction "+CRLF
	cQuery +="      select @iTranCount = 0"+CRLF
	cQuery +="   end"+CRLF
	cQuery +="   close AKD_EXCLUI"+CRLF
	cQuery +="   deallocate AKD_EXCLUI"+CRLF

	cQuery +="   select @OUT_RESULT = '1'"+CRLF
	cQuery +="End"+CRLF

	cQuery := MsParse( cQuery, If( Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB()) ) )
	cQuery := CtbAjustaP(.F., cQuery, 0)

	If Empty( cQuery )
		MsgAlert(MsParseError(),'A query de exclusao de AKD nao passou pelo Parse '+cProc)
		lRet := .F.
	Else
		If !TCSPExist( cProc )
			cRet := TcSqlExec(cQuery)
			If cRet <> 0
				If !__lBlind
					MsgAlert("Erro na criacao da proc de Exclusao de linhas do AKD: "+cProc)
					lRet:= .F.
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aSaveArea)

Return(lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} xPcoA022
Chamada da funcao para controle de Threads na geracao dos lancamentos da AKD.

@type function
@author Thiago Rasmussen
@since 02/09/2013
@version P12.1.23

@param nRecAK1, Numérico, RECNO da tabela AK1.
@param cNewVers, Caractere, Versão da Planilha Orçamentária.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando sucesso no processamento.

/*/
/*/================================================================================================================================/*/

Static Function xPcoA022(nRecAK1,cNewVers)

	Local nX
	Local lRet        	:= .F.
	Local cAliasTmp
	Local cQuery      	:= ""
	Local aRecGrid 		:= {}
	Local nThread		:= SuperGetMv("MV_PCOTHRD",.T.,10)
	Local cPlanRev		:= AK1->AK1_CODIGO
	//Local cNewVers		:= cNewVers
	//Local _cPtLanc 		:= GetNewPar("SI_PCOAPR", "91025201" ) //Ponto de Lancamento

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Default nRecAK1 := AK1->( Recno() )
	Private aParam:={}

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

		oGrid := FWIPCWait():New("SI22"+cEmpAnt+StrZero(nRecAK1,9,0),10000)
		oGrid:SetThreads(nThread)
		oGrid:SetEnvironment(cEmpAnt,cFilAnt)
		oGrid:Start("U_SI22IMPLAN")

		lRet := SIA22RevPre(oGrid,aRecGrid,nThread,cNewVers)

	EndIf

Return(lRet)

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIA22RevPre
Funcao de Start das Threads.

@type function
@author Thiago Rasmussen
@since 02/09/2013
@version P12.1.23

@param oGrid, Objeto, Objeto que representa a Grid de processamento.
@param aRecGrid, Array, Array com os RECNO´s dos registros a serem processados.
@param nThread, Numérico, Número de Threads utilizadas no reprocessamento.
@param cNewVers, Caractere, Versão da planilha orçamentária.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando sucesso no processamento.

/*/
/*/================================================================================================================================/*/

Static Function SIA22RevPre(oGrid,aRecGrid,nThread,cNewVers)
	Local nRecIni
	Local nRecFim
	Local lSimu_ := .F.
	Local lRevi_ := .F.

	Local cPlanRev		:= AK1->AK1_CODIGO
	//Local cNewVers		:= cNewVers
	Local cNewVersP		:= AK1->AK1_VERSAO

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
		lRet := oGrid:Go("Chamando escrituracao...",{nRecIni, nRecFim, lSimu_, lRevi_, cPlanRev, cNewVers, nX,cNewVersP})
		If !lRet
			Exit
		EndIf

		Sleep(5000)//Aguarda 5 seg para abertura da thread para não concorrer na criação das procedures.

	Next

	Sleep(2500*nThread)//Aguarda todas as threads abrirem para tentar fechar

	While !lExit
		nKilled := 0
		For nZ := 1 To Len(aRecGrid)
			nHdl := FOpen("xPCOA22_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0), 16)
			If nHdl >= 0
				cMsgComp += FReadStr(nHdl,100)+CRLF
				oGrid:RemoveThread(.T.)
				nKilled += 1
				FClose(nHdl)
				FErase("xPCOA22_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0))
			Else
				nHdl := FCreate("xPCOA22_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0), 16)
				If nHdl >= 0
					oGrid:RemoveThread(.T.)
					nKilled += 1
					FClose(nHdl)
					FErase("xPCOA22_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0))
				EndIf
			Endif
		Next nZ

		If nKilled == Len(aRecGrid)
			Exit
		EndIf

		Sleep(3000) //Verifica a cada 3 segundos se as threads finalizaram

	EndDo

	PcoAvisoTm(IIf(lRet,"Processo finalizado com sucesso", "Problema no processamento."),cMsgComp, {"Ok"},,,,,)

	oGrid:RemoveThread(.T.)

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} SI22IMPLAN
Função de controle de Threads.

@type function
@author Thiago Rasmussen
@since 02/09/2013
@version P12.1.23

@param cParm, characters, descricao
@param aParam, array, descricao

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.

/*/
/*/================================================================================================================================/*/

User Function SI22IMPLAN(cParm,aParam)

	Local nRecIni   := aParam[1]
	Local nRecFim   := aParam[2]
	Local lSimulac  := aParam[3]
	Local lRevisa   := aParam[4]
	Local cPlanRev  := aParam[5]
	Local cNewVers  := aParam[6]
	Local nZ        := aParam[7]
	Local cNewVersP	:= aParam[8]
	Local cFilAKE   := xFilial("AKE")

	Local nHdl
	Local cStart    := ""
	Local cEnd      := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	nHdl := FCreate("xPCOA22_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0), 16)

	If nHdl >= 0

		cStart := DTOC(Date())+" "+Time()
		Conout( "xPCOA22 -> "+AllTrim(Str(ThreadID()))+" STARTED ["+cStart+"] " )
		fWrite(nHdl, " STARTED ["+cStart+"]")
		//PROCESSAMENTO
		lRet := Aux_Det_Lan(nRecIni, nRecFim, lSimulac, lRevisa, cPlanRev, cNewVers,cNewVersP)
		//
		cEnd := DTOC(Date())+" "+Time()
		If lRet
			Conout("xPCOA22 -> "+AllTrim(Str(ThreadID()))+" END   ["+cEnd+"]  OK")
			fWrite(nHdl," END ["+cEnd+"] - OK")
		Else
			Conout("xPCOA22 -> "+AllTrim(Str(ThreadID()))+" END   ["+cEnd+"]  FAILED")
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
@param cNewVersP, characters, Versão da planilha orçamentária.

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando sucesso no processamento.

/*/
/*/================================================================================================================================/*/

Static Function Aux_Det_Lan(nRecIni, nRecFim, lSimulac, lRevisao, cPlanRev, cNewVers,cNewVersP)
	Local lRet 		:= .F.
	Local cQuery 	:= " "
	Local nCtdAK2 	:= 0
	Local nLimLin	:= GetMV("MV_PCOLIMI")
	Local nLinLote	:= 0
	Local _cPtLanc 	:= GetNewPar("SI_PCOAPR", "91025201" ) //Ponto de Lancamento

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea('AK1')
	AK1->(dbSetOrder(1))
	AK1->(DbSeek(xFilial('AK1')+cPlanRev+cNewVersP))

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

	PcoIniLan(Left(_cPtLanc,6))
	While (cAliasTmp)->(!Eof())
		nRecNew := (cAliasTmp)->(RECNOAK)
		AK2->(dbGoto(nRecNew))
		nCtdAK2++
		//PcoDetLan( cProcesso, cItem, cPrograma, lDeleta, cProcDel, cAKDStatus, lAtuSld )
		PcoDetLan(Left(_cPtLanc,6),Right(_cPtLanc,2),"SIPCOA22",.F., , "1",.F.)
		nLinLote++
		(cAliasTmp)->(dbSkip())

		If nLimLin = nLinLote
			PcoFinLan(Left(_cPtLanc,6),/*lForceVis*/,/*lProc*/,/*lDelBlq*/,.F.)
			nLinLote:=0
			PcoIniLan(Left(_cPtLanc,6))
		Endif

	EndDo
	PcoFinLan(Left(_cPtLanc,6),/*lForceVis*/,/*lProc*/,/*lDelBlq*/,.F.)

	(cAliasTmp)->(dbCloseArea() )

	Conout("Final Recnos de: "+Str(nRecIni,12,0)+"Ate: "+Str(nRecFim,12,0)+" "+time())

	lRet := ( (nRecFim-nRecIni+1) == nCtdAK2 )

Return(lRet)