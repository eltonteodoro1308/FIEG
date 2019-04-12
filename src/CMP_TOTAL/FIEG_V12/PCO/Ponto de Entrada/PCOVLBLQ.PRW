#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} PCOVLBLQ
P.E. na rotiuna de bloqueio orcamentario para tratar parametro de tolerancia para bloqueio.

@type function
@author Leonardo Soncin - TOTVS
@since 18/08/2011
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, .T. Nao Bloqueia .F. Bloqueia Lancamento.
/*/
/*/================================================================================================================================/*/

User Function PCOVLBLQ()

//Local nMoedaCfg 	:= ParamIXB[1] 							// Moeda
Local nValReal 		:= ParamIXB[2] 							// Valor "Realizado"
Local nValPrv 		:= ParamIXB[3] 							// Valor "Previsto"
//Local cChaveR 		:= ParamIXB[4] 							// Chave da Pesquisa
Local cProcesso 	:= ParamIXB[5] 							// Código do Processo
//Local cItem 		:= ParamIXB[6] 							// Item do Processo
//Local cPrograma 	:= ParamIXB[7] 							// Nome do Programa
//Local cChaveRD 		:= ParamIXB[8] 							// Descricao da Chave
//Local aDataIniFim 	:= ParamIXB[9] 							// 1-Data Inicio;2-Data Fim
//Local aAuxFil 		:= ParamIXB[10] 						// 1-Param Cfg Prv;2-Cfg Real
Local lUsaLote 		:= ParamIXB[11] 						// Indicador se utiliza lote
Local aPcoBkpBlq 	:= ParamIXB[12] 						// Array contendo Recnos AKD para caso de restaurar
Local lRet 			:= .T.									//.T. Nao Bloqueia .F. Bloqueia Lancamento
Local nToler		:= GetNewPar("SI_XPCOTOL", 0 ) 			//Percentual de Tolerancia
Local nValDsp		:= 0
//Local dDataIni		:= aDataIniFin[1]
//Local dDataFim		:= aDataIniFin[2]
//Local nTimeOut  	:= SuperGetMV("MV_PCOOUTB",.F.,0) * 1000
//Local nOpcTime  	:= 1
//Local cCodCuboPrv 	:= Posicione("AL4", 1, xFilial("AL4")+AKJ->AKJ_PRVCFG, "AL4_CONFIG")
//Local cCodCuboReal 	:= Posicione("AL4", 1, xFilial("AL4")+AKJ->AKJ_REACFG, "AL4_CONFIG")
Local _lLctoSC      := cProcesso == "000051" 				// Verifica se é SC

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If AK5->(FieldPos("AK5_XTOLER")) > 0 .and. AK5->AK5_XTOLER == "1"
	nValDsp		:= (nValPrv + (nValPrv *(nToler/100)))
Else
	nValDsp 	:= nValPrv
Endif

If (nValDsp  <= 0 .Or. Abs(nValReal) > Abs(nValDsp))
	lRet := .F.
	
	IF _lLctoSC 											// Lancamento da SC
		
		_fGRVCont(ParamIXB)									// Processo solicitação de contingencia
		
		PcoIncr_QtBlq()
		PcoFreeBlq(cProcesso,lUsaLote,  AKD->(Recno()), .T./*lRestaura*/, aPcoBkpBlq)
		
	ELSE
		
		_lRetCT := PCOA530(ParamIXB)
		
		If !_lRetCT
			PcoIncr_QtBlq()
			PcoFreeBlq(cProcesso,lUsaLote,  AKD->(Recno()), .T./*lRestaura*/, aPcoBkpBlq)
		EndIf
		
	ENDIF
	
Endif

Return(lRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} _fGRVCont
Gravacao da Contingencia, usado no P.E. na rotina de bloqueio orcamentario para tratar parametro de tolerancia para bloqueio.

@type function
@author Leonardo Soncin - TOTVS
@since 23/04/2012
@version P12.1.23

@param _aDadosBlq, Array, Dados para o bloqueio.

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, .T. Nao Bloqueia .F. Bloqueia Lancamento.
/*/
/*/================================================================================================================================/*/

Static Function _fGRVCont(_aDadosBlq)

Local lRetorno   := .t.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
ALI->(dbOrderNickName("SIALI01"))
IF ALI->(dbSeek(xFilial("ALI")+SC1->C1_NUM))
	_cSeqCTG := U_ALJNextID(ALI->ALI_CDCNTG)
ELSE
	lRetorno := PCOA530ALC(1,AKJ->AKJ_COD,{_aDadosBlq[5],_aDadosBlq[2],_aDadosBlq[3],_aDadosBlq[1],_aDadosBlq[4],AKD->(AKD_LOTE+AKD_ID),/*cObs*/})
	_cSeqCTG := StrZero(1,TamSX3('ALJ_ID' )[1])
ENDIF

If lRetorno
	
	RecLock('ALJ',.T.)
	For nX := 1 To (AKD->(FCount()))
		nPosCpo := ALJ->(FieldPos("ALJ_"+Substr(AKD->(FieldName(nX)),5)))
		If nPosCpo > 0
			ALJ->(FieldPut(nPosCpo,AKD->(FieldGet(nX))) )
		Endif
	Next nX
	ALJ_FILIAL 	:= xFilial('ALJ')
	ALJ_ID		:=	_cSeqCTG
	ALJ_CDCNTG	:=	ALI->ALI_CDCNTG
	ALJ_LOTEID	:=	AKD->(AKD_LOTE+AKD_ID)
	ALJ_TPSALDO	:=	"CT" 									//LANCANDO EM SALDO DE CONTINGENCIA
	ALJ_VALOR1	:= _aDadosBlq[2] - _aDadosBlq[3]
	MsUnLock()
	
	//--< Grava Nr. da contingencia na SC >-----------------
	RecLock("SC1",.F.)
	SC1->C1_XCDCNTG := ALJ->ALJ_CDCNTG
	SC1->(msUnLock())
	
	//--< Lançamento de Empenho de Contingencia >-----------
	If ALJ->(FieldPos("ALJ_EMPVAL")) > 0
		
		RecLock('ALJ',.F.)
		ALJ_EMPVAL	:= AKD->AKD_VALOR1 - ALJ_VALOR1
		MsUnLock()
		
		//--< Grava Area Atual >----------------------------
		aAreaAtu := GetArea()
		aAreaAKD := AKD->(GetArea())
		//--< Inicia lançamento para Empenho de saldo na contingencia >--
		PcoIniLan("000356",.F.)
		PcoDetLan("000356","02","PCOA530")
		PcoFinLan("000356",,,.F.)
		
		RestArea(aAreaAKD)
		RestArea(aAreaAtu)
	EndIf
	
Else
	IF GetRemoteType() == -1
		Conout("BLOQUEIO DE SC: Nao existe aprovador cadastrado para liberacao deste bloqueio (tipo de bloqueio, chave e valores).")
	ELSE
		Aviso("Atencao","Nao existe aprovador cadastrado para liberacao deste bloqueio (tipo de bloqueio, chave e valores).",{"Ok"})
	ENDIF
	//--< Atualiza flag para LIBERADO >---------------------
	RecLock("SC1",.F.)
	SC1->C1_APROV := "O" 									// Retorna status para "Bloqueado por Orçamento"
	SC1->(msUnlock())
Endif

Return(lRetorno)


/*/================================================================================================================================/*/
/*/{Protheus.doc} PcoIncr_QtBlq
Incrementa quantidade de bloqueio por tipo quando lancamento for bloqueado para uso no painel de gestao.

@type function
@author Paulo Carnelossi - TOTVS
@since 16/02/2007
@version P12.1.23

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function PcoIncr_QtBlq()

Local aAreaAux
Local cAlias := Alias()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If AKJ->(FieldPos("AKJ_QTDBLQ")) > 0
	
	aAreaAux := GetArea()

	Reclock("AKJ",.F.)
	AKJ->AKJ_QTDBLQ := AKJ->AKJ_QTDBLQ+1					//como ja esta posicionado somente incrementar qtd bloqueio
	AKJ->(MsUnlock())

	RestArea(aAreaAux)
	
EndIf

dbSelectArea(cAlias)

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} ALJNextID
Retorna proximo ID a ser utilizado.

@type function
@author TOTVS
@since 03/05/2012
@version P12.1.23

@param _cPar, Caractere, Parâmetro para o campo ALJ_CDCNTG.

@obs Projeto ELO

@history 21/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, Retorna o próximo número do ALJ_ID.
/*/
/*/================================================================================================================================/*/

User Function ALJNextID(_cPar)

Local _cQuery  := ""
Local _cArqALJ := CriaTrab(nil,.f.)
Local _cArea   := GetArea()
Local _cRet    := StrZero(1,TamSX3('ALJ_ID' )[1])

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
_cQuery := "SELECT MAX(ALJ_ID) ALJ_ID FROM "+RetSqlName("ALJ")+" WHERE D_E_L_E_T_ = ' ' "
_cQuery += "AND ALJ_FILIAL = '"+XFilial("ALJ")+"' AND ALJ_CDCNTG = '"+_cPar+"'"
_cQuery := ChangeQuery(_cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqALJ,.t.,.t.)

IF (_cArqALJ)->(!Eof())
	_cRet := Soma1( (_cArqALJ)-> ALJ_ID )
ENDIF

(_cArqALJ)->(dbCloseArea())

FErase(_cArqALJ+GetDBExtension())
FErase(_cArqALJ+OrdBagExt())

RestArea(_cArea)

Return(_cRet)
