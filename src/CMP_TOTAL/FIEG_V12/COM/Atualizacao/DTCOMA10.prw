#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} DTCOMA10
Função responsável por Eliminar Resíduos - Solicitação de Compras.

@type function
@author Fábrica DOIT SP
@since 14/07/2014
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function DTCOMA10()

Local nOpca 	:= 0
Local aSays		:= {}
Local aButtons  := {}
Local lRet 		:= .T.
Local aRecSC1	:= {}
Local aNumSC1	:= {}
Local lIntegDef := .F.
Local n1Cnt		:= 0   

Private lMT235G1  := existblock("MT235G1")                                                               
Private cCadastro := OemToAnsi("Elim. de resíduos dos Pedidos de Compras")		//"Elim. de res¡duos dos Pedidos de Compras"

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
AjustaSX1()
Pergunte("DTCOMA",.F.)
//-------------------------------------------------------
// mv_par01 - Percentual maximo
// mv_par02 - Data de Emissao de
// mv_par03 - Data de Emissao ate
// mv_par04 - Pedido de
// mv_par05 - Pedido ate
// mv_par06 - Produto de
// mv_par07 - Produto ate
// mv_par08 - Elimina residuo por: 1-Pedido /  2-Aut.Entr. / 3-Pedido e Autor. 4-Contr.Parceria 5-Solicitacao
// mv_par09 - Fornecedor de
// mv_par10 - Fornecedor ate
// mv_par11 - Data Entrega de
// mv_par12 - Data Entrega ate
// mv_par13 - Elimina SC com OP? 1-Sim  2-Nao
// mv_par14 - A partir do Item
// mv_par15 - Ate o Item
// mv_par16 - Contabiliza Pedido
// mv_par17 - Mostra Lanc Contab
// mv_par18 - Filial de
// mv_par19 - Filial até
//-------------------------------------------------------

AADD(aSays,OemToAnsi("Este programa tem como objetivo fechar os Pedidos de Compra, "))
AADD(aSays,OemToAnsi("Autorizaçoes de Entrega e Solicitaçoes de Compra, com residuos"))
AADD(aSays,OemToAnsi("baixados, baseado na porcentagem digitada nos Parâmetros."))

AADD(aButtons, { 5,.T.,{|| Pergunte("DTCOMA",.t.) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca:= 1, o:oWnd:End() } } )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

FormBatch( cCadastro, aSays, aButtons,,200,445 )  

If nOpca == 1 .And. mv_par01 > 0
	If lRet
		Do Case
		Case mv_par08 < 4  			// 1=pedido  2=Aut.Entrega  3=Pedido e Autorizacao
			Processa({|lEnd| MA235PC(mv_par01,mv_par08,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par09,mv_par10,mv_par11,mv_par12,mv_par14,mv_par15)})
		Case mv_par08 == 4 			// Contrato de Parceria
			Processa({|lEnd| MA235CP(mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par09,mv_par10,mv_par11,mv_par12,mv_par14,mv_par15)})
		Case mv_par08 == 5 			// Solicitacao de Compras
			Processa({|lEnd| MA235SC(mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par09,mv_par10,mv_par11,mv_par12,(mv_par13==2),mv_par14,mv_par15,mv_par18,mv_par19,aRecSC1)})
			//-- Variavel usada para verificar se o disparo da funcao IntegDef() pode ser feita manualmente
			lIntegDef	:=  FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI") .And. FWHasEAI("MATA110",.T.,,.T.) .And. FindFunction("MTA110SC1")
			If	lIntegDef
				
				MTA110SC1(aRecSC1)	//-- Atualiza array de recnos a serem processados na mensagem unica no MATA110
				//-- Somente SC processada pela funcao MA235SC
				For n1Cnt := 1 To Len(aRecSC1)
					SC1->(DbGoTo(aRecSC1[n1Cnt]))
					If	Ascan(aNumSC1,SC1->C1_NUM)==0
						AAdd(aNumSC1,SC1->C1_NUM)
						FwIntegDef( 'MATA110' )
					EndIf
				Next
			EndIf
		EndCase
	EndIf
EndIf

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} MA235PC
Fechar os Pedidos de Compras  e Autorizacoes de entrega com residuos.

@type function
@author Marcelo B. Abe - TOTVS
@since 10/02/1993
@version P12.1.23

@param nPerc, Numérico, Percentual de residuo a ser eliminado.
@param cTipo, Caractere, 1-Pedido, 2-Autor.Entrega, 3-Ambos.
@param dEmisDe, Data, Filtrar da Data de Emissao de.
@param dEmisAte, Data, Filtrar da Data de Emissao Ate.
@param cCodigoDe, Caractere, Filtrar da Solicitacao de.
@param cCodigoAte, Caractere, Filtrar da Solicitacao Ate.
@param cProdDe, Caractere, Filtrar Produto de.
@param cProdAte, Caractere, Filtrar Produto Ate.
@param cFornDe, Caractere, Filtrar Fornecedor de.
@param cFornAte, Caractere, Filtrar Fornecedor Ate.
@param dDatprfde, Data, Filtrar Data Entrega de
@param dDatPrfAte, Data, Filtrar Data Entrega de.
@param cItemDe, Caractere, Filtrar Item de.
@param cItemAte, Caractere, Filtrar Item Ate.
@param lConsEIC, Lógico, Filtra pedido de origem do EIC.

@obs Desenvolvimento FIEG

@history 01/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna falso em caso de processamento abortado.
/*/
/*/================================================================================================================================/*/

Static Function MA235PC(nPerc, cTipo, dEmisDe, dEmisAte, cCodigoDe, cCodigoAte, cProdDe, cProdAte, cFornDe, cFornAte, dDatprfde, dDatPrfAte, cItemDe, cItemAte, lConsEIC)

Local aRefImp   := {}
Local nRes      := 0
Local nPosRef1  := 0
Local nPosRef2  := 0
Local lProcessa := .T.
Local cAlias    := "SC7"
Local cQuery    := ""
Local nNaoProc  := 0
Local lRet      := .T.
//Local lMT235AIR := existblock("MT235AIR")
//Local lMT235G2  := existblock("MT235G2")
Local lGCTRes   := (SuperGetMv("MV_CNRESID",.F.,"N") == "S") .And. (CND->( FieldPos("CND_RESID") ) > 0 .And. CNE->( FieldPos("CNE_RESID") ) > 0) .And. FindFunction( "GravaGCT" )  
Local lVldVige  := GetNewPar("MV_CNFVIGE","N") == "N"   
Local aNumPed	:= {} 
Local _filial   := cFILANT
Local _NumPC    := MV_PAR05
Local _Fornec   := Posicione("SC7", 1, _filial+MV_PAR05, "C7_FORNECE") 
Local _Loja     := Posicione("SC7", 1, _filial+MV_PAR05, "C7_LOJA")  

DEFAULT cItemDe := Space(4) 
DEFAULT cItemAte:= "ZZZZ"
DEFAULT lConsEIC:= .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Quando a Rotina e acionada pelo SIGAEIC atualiza grupo de perguntas SX1 >--
If nModulo == 17 
	AjustaSX1()
	pergunte("DTCOMA",.F.)
EndIf

//--< Alimenta o Array aRefImp com base no dicionario >---------------------
//dbSelectArea("SX3")
OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
SX3TMP->(dbSetOrder(1))
SX3TMP->(MsSeek("SC7"))
While !SX3TMP->(Eof()) .and. SX3TMP->X3_ARQUIVO == "SC7"
	nPosRef1	:= At("MAFISREF(",Upper(SX3TMP->X3_VALID))
	If ( nPosRef1 > 0 )
		nPosRef1    += 10
		nPosRef2    := At(",",SubStr(SX3TMP->X3_VALID,nPosRef1))-2
		aadd(aRefImp,{"SC7",SX3TMP->X3_CAMPO,SubStr(SX3TMP->X3_VALID,nPosRef1,nPosRef2)})
	EndIf
	SX3TMP->(dbSkip())
EndDo
SX3TMP->(DbCloseArea())

If MV_PAR08 = 1 .and. (MV_PAR04 <> MV_PAR05)
	MsgStop("O processamento foi abortado pois para Pedido de Compra, não é aceito mais de um pedido! (pedido inicial e final devem ser o mesmo)","DTCOMA10")
	lRet := .F.
EndIf

//--< 11/11/2016 - José Fernando - Caso o pedido de compra esteja relacionado a uma NF pendente de classificação, impedir a eliminação de resíduo do pedido >--
If lRet .and. MV_PAR08 = 1 
	cQuery  = " select D1_FILIAL, D1_DOC, D1_SERIE, D1_EMISSAO, D1_FORNECE"
	cQuery += " from SD1010 SD1 with (nolock)"
	cQuery += " where SD1.D_E_L_E_T_ = ' ' "
	cQuery += "   and SD1.D1_FILIAL  = '" + _Filial + "' "
	cQuery += "   and SD1.D1_PEDIDO  = '" + _NumPC + "' "
	cQuery += "   and SD1.D1_FORNECE = '" + _Fornec + "' "
	cQuery += "   and SD1.D1_LOJA    = '" + _Loja + "' "
	cQuery += "   and SD1.D1_TES     = '' " 
		
	If Select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	EndIf 
		 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.F.)
		                                                                      
	DbSelectArea(cAlias)
	(cAlias)->(dbGotop())
                                       
	While !(cAlias)->(EOF())                                     
 		MsgStop("O processamento foi abortado pois existe pre-nota para este Pedido. Filial: " + (cAlias)->D1_FILIAL + " NF: " + (cAlias)->D1_DOC + " DATA: " + SUBSTR((cAlias)->D1_EMISSAO,7,2)+ "/"+SUBSTR((cAlias)->D1_EMISSAO,5,2)+ "/"+SUBSTR((cAlias)->D1_EMISSAO,1,4) +  "","pre-nota com este Pedido")
		lRet := .F.
	END
EndIf

If lRet

	ProcRegua(SC7->(RecCount())*5)
	#IFDEF TOP
		cQuery := "select C7_FILIAL, C7_NUM,   C7_EMISSAO, C7_RESIDUO, C7_DATPRF, C7_PRODUTO, C7_FORNECE,"
		cQuery += "       C7_LOJA,   C7_QUANT, C7_QUJE,    C7_TIPO,    C7_APROV,  C7_MOEDA,   C7_TXMOEDA, C7_ORIGEM, "
		cQuery += "       R_E_C_N_O_ SC7RECNO "
		cQuery += "  from " + RetSqlName("SC7") + " SC7 "
		cQuery += " where C7_EMISSAO  >= '"+Dtos(dEmisDe)+"' and C7_EMISSAO <= '" +Dtos(dEmisAte)+"' "
		cQuery += "   and C7_NUM      >= '"+cCodigoDe    +"' and C7_NUM     <= '" +cCodigoAte	 +"' "
		cQuery += "   and C7_ITEM     >= '"+cItemDe      +"' and C7_ITEM    <= '" +cItemAte		 +"' "
		cQuery += "   and C7_PRODUTO  >= '"+cProdDe      +"' and C7_PRODUTO <= '" +cProdAte 	 +"' "
		cQuery += "   and C7_FORNECE  >= '"+cFornDe      +"' and C7_FORNECE <= '" +cFornAte		 +"' "
		
		If !Empty(dDatPrfDe) .And. !Empty(dDatPrfAte)
			cQuery += " and C7_DATPRF >= '"+Dtos(dDatPrfDe)+"' and C7_DATPRF<='"+Dtos(dDatPrfAte)+"' "
		Endif		
		
		cQuery += " and C7_FILIAL ='" + xFilial("SC7") + "' "
		cQuery += If(cTipo==1," and C7_TIPO = 1 ",If(cTipo==2," and C7_TIPO = 2 ",""))
		cQuery += " and C7_RESIDUO = ' ' "
		
		If lConsEIC
			cQuery += " and C7_ORIGEM <> 'EICPO400' "
		Endif
		
		cQuery += " and SC7.D_E_L_E_T_<>'*'"
		cAlias := CriaTrab(,.F.)
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	#ELSE
		dbSelectArea("SC7")
		SC7->(dbSetOrder(1))
		SC7->(dbSeek(xFilial("SC7")+cCodigoDe,.t.))
	#ENDIF
	PcoIniLan('000056')

	While !SC7->(Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM <= cCodigoAte
		IncProc()

		#IFNDEF TOP
			//--< Monta condicao de filtragem >--
			If (C7_EMISSAO < dEmisDe .Or. C7_EMISSAO > dEmisAte .Or. !Empty(C7_RESIDUO) .Or.;
				C7_PRODUTO > cProdAte .Or. C7_PRODUTO < cProdDe .Or. ;
				C7_ITEM    > cItemAte .Or. C7_ITEM < cItemDe .Or. ;
				C7_FORNECE > cFornAte .Or. C7_FORNECE < cFornDe) .Or.;
				(!Empty(dDatPrfAte) .And. !Empty(dDatPrfDe).And.;
				(C7_DATPRF<dDatPrfDe .Or. C7_DATPRF>dDatPrfAte)) .Or.;
				( IIF(lConsEIC,Alltrim(C7_ORIGEM) == "EICPO400",.F.) ) .Or.;
				(cTipo==1 .And. C7_TIPO == 2) .Or. (cTipo == 2 .And. C7_TIPO == 1)
				lProcessa := .F.
			EndIf
		#ELSE    
			dbSelectArea("SC7")
			SC7->(MsGoto((cAlias)->SC7RECNO))
			lProcessa := .T.
		
			aArea	:= GetArea()
			If !Empty(SC7->C7_CONTRA) .And. lGCTRes
				dbSelectArea("CN9")
				CN9->(DbSetOrder(1))
				If CN9->(DbSeek(xFilial("CN9")+SC7->C7_CONTRA+SC7->C7_CONTREV))
					If lVldVige .And.((CN9->CN9_SITUAC <> "05") .Or. (CN9->CN9_DTINIC > dDataBase .Or. CN9->CN9_DTFIM < dDataBase))  //Contrato finalizado ou fora do período da vigência 
						lProcessa := .F.
					EndIf
				EndIf
			EndIf
			RestArea(aArea)  
		#ENDIF

		If lProcessa
			If !Empty(cQuery)
				dbSelectArea("SC7")
				SC7->(dbGoto((cAlias)->(SC7RECNO)))
			EndIf		

			Aadd(aNumPed,{xFilial("SC7"),SC7->C7_NUM,'PC'})

			//--< Calcular o Residuo maximo da Compra >-----------------------
			nRes := (C7_QUANT * nPerc)/100
			//--< Verifica se o Pedido deve ser Encerrado >-------------------
			If (C7_QUANT - C7_QUJE <= nRes .And. C7_QUANT > C7_QUJE) 
				Ma235ElRes(@nNaoProc,aRefImp)				// Chama funcao que processa a eliminacao de residuos, acumulados e vinculados
			Endif
				
		EndIf
		dbSelectArea(cAlias)
		(cAlias)->(dbSkip())
	Enddo

	If ValType(aNumPed)<>"U" .And. FindFunction("MA235PA")
		MA235PA(aNumPed)
	EndIf
					
	If nNaoProc > 0  										//" itens nao foram processados por estar em uso em outra estacao!"
		MsgInfo(Str(nNaoProc,4) + " itens näo foram processados por estar em uso em outra estacao!","Atençäo")
	EndIf
	If !Empty(cQuery)
		(cAlias)->(dbCloseArea())
	EndIf

	PcoFinLan('000056')
	dbSelectArea("SC7")
EndIf

Return lRet


/*/================================================================================================================================/*/
/*/{Protheus.doc} MA235CP
Fechar os Contratos de Parceria com residuos.

@type function
@author Marcelo B. Abe - TOTVS
@since 10/02/1993
@version P12.1.23

@param nPerc, Numérico, Percentual de residuo a ser eliminado.
@param dEmisDe, Data, Filtrar da Data de Emissao de.
@param dEmisAte, Data, Filtrar da Data de Emissao Ate.
@param cCodigoDe, Caractere, Filtrar da Contrato de Parceria de.
@param cCodigoAte, Caractere, Filtrar da Contrato de Parceria Ate.
@param cProdDe, Caractere, Filtrar Produto de.
@param cProdAte, Caractere, Filtrar Produto Ate.
@param cFornDe, Caractere, Filtrar Fornecedor de.
@param cFornAte, Caractere, Filtrar Fornecedor Ate.
@param dDatprfde, Data, Filtrar Data Entrega de
@param dDatPrfAte, Data, Filtrar Data Entrega de.
@param cItemDe, Caractere, Filtrar Item de.
@param cItemAte, Caractere, Filtrar Item Ate.

@obs Desenvolvimento FIEG

@history 01/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function MA235CP(nPerc, dEmisDe, dEmisAte, cCodigoDe, cCodigoAte, cProdDe, cProdAte, cFornDe, cFornAte, dDatprfde, dDatPrfAte, cItemDe, cItemAte)

Local nRes      := 0
Local cAlias    := "SC3"
Local cQuery    := ""
Local lProcessa := .T.
//Local lRet	    := .T.
//Local lMT235AIR := ExistBlock("MT235AIR")
Local nNaoProc  := 0
Local nTotItem	:= 0
DEFAULT cItemDe := Space(4) 
DEFAULT cItemAte:= "ZZZZ"

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
ProcRegua(SC3->(RecCount())*5)

#IFDEF TOP
	cQuery := "select C3_FILIAL, C3_QUANT,  C3_NUM,  C3_EMISSAO, C3_RESIDUO, C3_DATPRF, "
	cQuery += "       C3_QUJE,   R_E_C_N_O_ SC3RECNO "
	cQuery += "  from "+RetSqlName("SC3")+" SC3 "
	cQuery += " where C3_FILIAL   = '"+ xFilial("SC3") +"'"
	cQuery += "   and C3_NUM     >= '"+cCodigoDe    +"' and C3_NUM <= '"    +cCodigoAte+"'"
	cQuery += "   and C3_ITEM    >= '"+cItemDe      +"' and C3_ITEM <= '"   +cItemAte+"' "
	cQuery += "   and C3_EMISSAO >= '"+DTOS(dEmisDe)+"' and C3_EMISSAO <= '"+Dtos(dEmisAte)+"'"
	cQuery += "   and C3_PRODUTO >= '"+cProdDe      +"' and C3_PRODUTO <= '"+cProdAte + "' "
	cQuery += "   and C3_FORNECE >= '"+cFornDe      +"' and C3_FORNECE <= '"+cFornAte+"' "
	
	If !Empty(dDatPrfDe) .And. !Empty(dDatPrfAte)
		cQuery += " and C3_DATPRF>='"+Dtos(dDatPrfDe)+"' and C3_DATPRF<='"+Dtos(dDatPrfAte)+"' "
	Endif		
	cQuery += " and C3_RESIDUO = ' ' And SC3.D_E_L_E_T_ = ' '"         
	
	cAlias := CriaTrab(,.F.)
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
#ELSE
	dbSelectArea("SC3")
	dbSetOrder(1)
	dbSeek(xFilial("SC3")+cCodigoDe,.t.)
#ENDIF

PcoIniLan('000056')
While !Eof() .And. C3_FILIAL == xFilial("SC3") .And. C3_NUM <= cCodigoAte
	lProcessa := .T.
	IncProc()

	#IFNDEF TOP
		//--< Monta condicao de filtragem >-----------------
		If C3_EMISSAO	< dEmisDe .Or. C3_EMISSAO > dEmisAte .Or. !Empty(C3_RESIDUO) .Or.;
		   C3_PRODUTO > cProdAte .Or. C3_PRODUTO < cProdDe .Or. ;
		   C3_ITEM > cItemAte .Or. C3_ITEM < cItemDe .Or. ;
		   C3_FORNECE > cFornAte .Or. C3_FORNECE < cFornDe .Or.;
		   (!Empty(dDatPrfAte) .And. !Empty(dDatPrfDe) .And.;
		   (C3_DATPRF<dDatPrfDe .Or. C3_DATPRF>dDatPrfAte))
			lProcessa := .F.
		EndIf
	#ENDIF

	If lProcessa
	
		//--< Calcular o Residuo maximo da Compra >---------
		nRes := (C3_QUANT * nPerc)/100
		//--< Verifica se a Autorizacao deve ser Encerrada >
		If (C3_QUANT - C3_QUJE <= nRes .And. C3_QUANT > C3_QUJE)
			Begin Transaction
				If !Empty(cQuery)
					dbSelectArea("SC3")
					dbGoTo((cAlias)->(SC3RECNO))
				EndIf          
				nTotItem := SC3->C3_PRECO * (SC3->C3_QUANT - SC3->C3_QUJE)
				SCR->(dbSeek(xFilial("SCR")+"CP"+SC3->C3_NUM,.T.))

				If SimpleLock("SC3") .And. IIF(xFilial("SCR")+"CP"+SC3->C3_NUM == SCR->CR_FILIAL+SCR->CR_TIPO+Subs(SCR->CR_NUM,1,Len(SC3->C3_NUM)),SimpleLock("SCR"),.T.)

					RecLock("SC3",.F.)
					Replace C3_RESIDUO with "S"
					Replace C3_ENCER with "E"

					If SC3->(FieldPos("C3_CONAPRO")) > 0 	    		
						dbSelectArea("SCR")
						If xFilial("SCR")+"CP"+SC3->C3_NUM == SCR->CR_FILIAL+SCR->CR_TIPO+Subs(SCR->CR_NUM,1,Len(SC3->C3_NUM))
							MaAlcDoc({SC3->C3_NUM,"CP",nTotItem,,,SC3->C3_APROV,,SC3->C3_MOEDA,SC3->C3_TXMOEDA,SC3->C3_EMISSAO},SC3->C3_EMISSAO,5,,.T.)
						EndIf	
					EndIf

					MsUnlock()
		            PcoDetLan('000056','03','MATA235')

				Else
					nNaoProc ++
				EndIf
			End Transaction
		Endif
	
	EndIf

	dbSelectArea(cAlias)
	dbSkip()
EndDo
If nNaoProc > 0  											//" itens nao foram processados por estar em uso em outra estacao!"
	MsgInfo(Str(nNaoProc,4) + " itens näo foram processados por estar em uso em outra estacao!","Atençäo")
EndIf

If !Empty(cQuery)
	dbSelectArea(cAlias)
	dbCloseArea()
EndIf

dbSelectArea("SC3")
PcoFinLan('000056')
Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} MA235SC
Fechar as Solicitacoes de Compras com residuos.

@type function
@author Aline Correa do Vale - TOTVS
@since 28/08/2003
@version P12.1.23

@param nPerc, Numérico, Percentual de residuo a ser eliminado.
@param dEmisDe, Data, Filtrar da Data de Emissao de.
@param dEmisAte, Data, Filtrar da Data de Emissao Ate.
@param cCodigoDe, Caractere, Filtrar da Solicitacao de.
@param cCodigoAte, Caractere, Filtrar da Solicitacao Ate.
@param cProdDe, Caractere, Filtrar Produto de.
@param cProdAte, Caractere, Filtrar Produto Ate.
@param cFornDe, Caractere, Filtrar Fornecedor de.
@param cFornAte, Caractere, Filtrar Fornecedor Ate.
@param dDatprfde, Data, Filtrar Data Entrega de
@param dDatPrfAte, Data, Filtrar Data Entrega de.
@param lSemOp, Lógico, Elimina SC com OP
@param cItemDe, Caractere, Filtrar Item de.
@param cItemAte, Caractere, Filtrar Item Ate.

@obs Desenvolvimento FIEG

@history 01/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function MA235SC(nPerc, dEmisDe, dEmisAte, cCodigoDe, cCodigoAte, cProdDe, cProdAte, cFornDe, cFornAte, dDatPrfde, dDatPrfAte, lSemOp, cItemDe, cItemAte,cFilialDe,cFilialAte,aRecSC1)

Local nRes        := 0
Local nNaoProc    := 0   
Local nIndice     := 0 
Local cQuery      := ""
Local cSeekSCQ    := ""
Local cAlias      := "SC1"
Local cAliasTOP   := "SCQ"  
Local cAliasDBF   := "SCP"  
Local lProcessa   := .T.
Local lRet	      := .T.
Local lQuery      := .F.
Local lPrcPreReq  := .F.
//Local lMT235AIR   := ExistBlock("MT235AIR")
Local _cxFilAtu   := cFilAnt
Local _cxcNumEmp  := cNumEmp

DEFAULT lSemOp  := .T.
DEFAULT aRecSC1	:= {}

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
ProcRegua(SC1->(RecCount())*5)

cQuery := "SELECT C1_FILIAL, C1_QUANT, C1_NUM,     C1_EMISSAO, C1_RESIDUO, C1_DATPRF,"
cQuery += "       C1_QUJE,   C1_OP,    C1_COTACAO, R_E_C_N_O_ SC1RECNO "
cQuery += "  FROM "+RetSqlName("SC1")+" SC1 "
cQuery += "   WHERE C1_NUM   >= '"+cCodigoDe+"' and C1_NUM<='"+cCodigoAte+"' "
cQuery += "   and C1_ITEM    >= '"+cItemDe+"' and C1_ITEM<='"+cItemAte+"' "
cQuery += "   and C1_EMISSAO >= '"+Dtos(dEmisDe)+"' and C1_EMISSAO<='"+Dtos(dEmisAte)+"' "
cQuery += "   and C1_PRODUTO >= '"+cProdDe+"' and C1_PRODUTO<='"+ cProdAte + "' " 
cQuery += "   and C1_FILIAL  >= '"+cFilialDe+"' and C1_FILIAL<='"+ cFilialAte + "' " 

If !Empty(dDatPrfDe) .And. !Empty(dDatPrfAte)
	cQuery += "and C1_DATPRF>='"+Dtos(dDatPrfDe)+"' and C1_DATPRF<='"+Dtos(dDatPrfAte)+"' "
Endif		

cQuery += " and C1_FLAGGCT <> '1' and C1_RESIDUO = ' ' And SC1.D_E_L_E_T_<>'*'"
cQuery += " ORDER BY C1_FILIAL, C1_NUM "
cAlias := CriaTrab(,.F.)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
DbSelectArea(cAlias)
DbGotop()

PcoIniLan('000056')

While !Eof()   
	If _cxFilAtu <> C1_FILIAL
	 	cFilAnt := C1_FILIAL
	 	cNumEmp := cEmpAnt+C1_FILIAL
	Endif 	
	 	
	lProcessa  := .T.
    lPrcPreReq := .F.
	IncProc()
                                  
	#IFNDEF TOP
		//--< Monta condicao de filtragem >--
		If C1_EMISSAO	< dEmisDe .Or. C1_EMISSAO > dEmisAte .Or. !Empty(C1_RESIDUO) .Or.;
				C1_PRODUTO > cProdAte .Or. C1_PRODUTO < cProdDe .Or. ;
				C1_ITEM > cItemAte .Or. C1_ITEM < cItemDe .Or. ;
				( !Empty(dDatPrfDe) .And. !Empty(dDatPrfAte) .And.;
				(C1_DATPRF < dDatPrfDe .Or. C1_DATPRF > dDatPrfAte) ) .Or.;
				If(lSemOp,!Empty(C1_OP),.F.) .Or. C1_FLAGGCT == '1'
			lProcessa := .F.
		Endif
	#ELSE
		If lSemOp .And. !Empty(C1_OP)
			lProcessa := .F.
		EndIf
	#ENDIF
	
	If lProcessa .And. (!Empty(C1_COTACAO) .And. C1_COTACAO<>'IMPORT') .And. (C1_QUANT == C1_QUJE .Or. C1_QUJE == 0)
		lProcessa := .F.
	Endif

	If lProcessa
	
		//--< Calcular o Residuo maximo da Compra >--
		nRes := (C1_QUANT * nPerc)/100
		//--< Verifica se a Autorizacao deve ser Encerrada >--
		If (C1_QUANT - C1_QUJE <= nRes .And. C1_QUANT > C1_QUJE)

			Begin Transaction
				If !Empty(cQuery)
					dbSelectArea("SC1")
					dbGoto((cAlias)->(SC1RECNO))
				EndIf
				If !SB2->(dbSeek(xFilial("SB2")+SC1->C1_PRODUTO+SC1->C1_LOCAL))
					CriaSb2( SC1->C1_PRODUTO,SC1->C1_LOCAL)
				Endif
				If SimpleLock("SC1") .And. SimpleLock("SB2")
					MaAvalSC("SC1",2)
					RecLock("SC1",.F.)
					Replace C1_QTDORIG WITH C1_QUANT
					Replace C1_QUANT   WITH C1_QUJE
					Replace C1_RESIDUO WITH "S"
					MsUnlock()
					
					AAdd(aRecSC1,SC1->(Recno()))

		            PcoDetLan('000056','01','MATA235')   
		            If SC1->C1_OBS == "SC gerada por SA              "
	   		            lPrcPreReq := .T.
   		            EndIf
				Else
					nNaoProc ++
				EndIf   
			
				//--< Processa eliminacao de residuo da baixa da pre-requisicao >--
				If lPrcPreReq
					#IFDEF TOP        
						If TcSrvType() <> "AS/400"
							lQuery    := .T.
							cAliasTOP := GetNextAlias()
							If Select(cAliasTOP) > 0 
						    	dbSelectArea(cAliasTOP)
						       	dbCloseArea()
							EndIf 
							cQuery := "SELECT SCP.CP_FILIAL, SCP.CP_PRODUTO, SCP.CP_NUM,    SCP.CP_ITEM,    SCP.CP_QUANT, "
							cQuery += "       SCQ.CQ_QTDISP, SCP.CP_QTSEGUM, SCQ.CQ_NUMREQ, SCQ.CQ_QTSEGUM, SCQ.CQ_QUANT, "	
							cQuery += "       SCQ.CQ_PRODUTO, SCP.R_E_C_N_O_ SCPRECNO, SCQ.R_E_C_N_O_ SCQRECNO"
							cQuery += "  FROM "+RetSqlName("SCP")+" SCP , "+RetSqlName("SCQ")+" SCQ "
							cQuery += " WHERE SCP.CP_FILIAL  = '"+xFilial("SCP")+"'"
							cQuery += "   and SCQ.CQ_FILIAL  = '"+xFilial("SCQ")+"'"
							cQuery += "   and SCP.CP_PRODUTO = SCQ.CQ_PRODUTO "
							cQuery += "   and SCP.CP_LOCAL   = SCQ.CQ_LOCAL   "
							cQuery += "   and SCP.CP_NUM     = SCQ.CQ_NUM     "
							cQuery += "   and SCP.CP_ITEM    = SCQ.CQ_ITEM    "
							cQuery += "   and SCP.CP_NUMSC   = '"+SC1->C1_NUM+"'"
							cQuery += "   and SCP.CP_ITSC    = '"+SC1->C1_ITEM+"'"
							cQuery += "   and SCQ.CQ_QUANT   > SCQ.CQ_QTDISP "
							cQuery += "   and SCP.CP_STATUS  <> 'E' "
							cQuery += "   and SCP.D_E_L_E_T_ = ' '  "
							cQuery += "   and SCQ.D_E_L_E_T_ = ' '  "
							cQuery += " ORDER BY SCP.CP_FILIAL, SCP.CP_PRODUTO, SCP.CP_NUM, SCP.CP_ITEM "
							
							cQuery := ChangeQuery(cQuery)				
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTOP)
							
							aEval(SCP->(dbStruct()), {|x| If(x[2] <> "C" .And. SCP->(FieldPos(x[1]) > 0 ), TcSetField(cAliasTOP,x[1],x[2],x[3],x[4]),Nil)})
							aEval(SCQ->(dbStruct()), {|x| If(x[2] <> "C" .And. SCQ->(FieldPos(x[1]) > 0 ), TcSetField(cAliasTOP,x[1],x[2],x[3],x[4]),Nil)})
							
							Do While !(cAliasTOP)->(Eof())
								SCP->(MsGoto((cAliasTOP)->SCPRECNO))
								RecLock("SCP",.F.)
								If SC1->C1_SOLICIT == "SA AGLUTINADA            "
							   		SCP->CP_QUANT -= ((cAliasTOP)->CP_QUANT - (cAliasTOP)->CQ_QTDISP)                      
								Else 
								  	SCP->CP_QUANT -= (SC1->C1_QTDORIG - SC1->C1_QUJE)
								EndIf
								If !Empty((cAliasTOP)->CP_QTSEGUM)
									SCP->CP_QTSEGUM	-= (cAliasTOP)->CP_QTSEGUM-ConvUM((cAliasTOP)->CP_PRODUTO,(cAliasTOP)->CQ_QTDISP,0,2)
								EndIf   
								MsUnlock()
								
								// Verifica se encerra a Pre-Requisicao
								If SCP->CP_QUANT == SCP->CP_QUJE
									Replace CP_STATUS  with 'E'
									Replace CP_PREREQU with 'S'
									MsUnlock()
								EndIf
								// Acerto na tabela SCQ (Eliminar Residuo)
								cSeekSCQ := (cAliasTOP)->CP_FILIAL+(cAliasTOP)->CP_PRODUTO+(cAliasTOP)->CP_NUM+(cAliasTOP)->CP_ITEM
				    			Do While !(cAliasTOP)->(Eof()) .And. cSeekSCQ == (cAliasTOP)->CP_FILIAL+(cAliasTOP)->CP_PRODUTO+(cAliasTOP)->CP_NUM+(cAliasTOP)->CP_ITEM
						   			SCQ->(MsGoto((cAliasTOP)->SCQRECNO))
									If Empty((cAliasTOP)->CQ_NUMREQ) .And. SCP->CP_STATUS == "E"
										RecLock("SCQ",.F.)
										dbDelete()
										MsUnLock()
									Else    
										RecLock("SCQ",.F.)
										If SC1->C1_SOLICIT == "SA AGLUTINADA            "
							   				SCQ->CQ_QUANT  -= ((cAliasTOP)->CQ_QUANT - (cAliasTOP)->CQ_QTDISP)
										Else 
											SCQ->CQ_QUANT  -= (SC1->C1_QTDORIG - SC1->C1_QUJE)
										EndIf

										If !Empty((cAliasTOP)->CQ_QTSEGUM)
											SCQ->CQ_QTSEGUM	-= (cAliasTOP)->CQ_QTSEGUM-ConvUM((cAliasTOP)->CQ_PRODUTO,(cAliasTOP)->CQ_QTDISP,0,2)
										EndIf
										MsUnlock() 
									EndIf
									dbSelectArea(cAliasTop)
									dbSkip()
								EndDo										
							EndDo          	
							(cAliasTOP)->(dbCloseArea())  
						EndIf
				
					#ENDIF     
	
                    If !lQuery
	                    cAliasDBF := CriaTrab(,.F.)
			
						dbSelectArea("SCP")
						IndRegua("SCP",cAliasDBF ,"CP_FILIAL+CP_NUMSC+SCP->CP_ITSC")	
						nIndice :=RetIndex("SCP")+1 

						#IFNDEF TOP
							dbSetIndex(cAliasDBF+OrdBagExt())
						#ENDIF		
						dbSetorder(nIndice)
							
						dbSeek(xFilial("SCP")+SC1->C1_NUM+SC1->C1_ITEM,.F.)
						
						Do While !SCP->(Eof())	.And. SCP->CP_NUMSC == SC1->C1_NUM .And. SCP->CP_ITSC == SC1->C1_ITEM
							dbSelectArea("SCQ")
							dbSetOrder(1)
							
							If dbSeek(xFilial("SCQ")+SCP->CP_NUM+SCP->CP_ITEM)
								if (SCP->CP_PRODUTO == SCQ->CQ_PRODUTO .And. SCP->CP_LOCAL == SCQ->CQ_LOCAL .And. SCQ->CQ_QUANT > SCQ->CQ_QTDISP .And. SCP->CP_STATUS <> 'E')
									RecLock("SCP",.F.)
									If SC1->C1_SOLICIT == "SA AGLUTINADA            "
						  				SCP->CP_QUANT -= (SCP->CP_QUANT - SCQ->CQ_QTDISP)                      
									Else 
								  		SCP->CP_QUANT -= (SC1->C1_QTDORIG - SC1->C1_QUJE)
									EndIf  
	
									If !Empty(SCP->CP_QTSEGUM)
										SCP->CP_QTSEGUM	-= SCP->CP_QTSEGUM-ConvUM(SCP->CP_PRODUTO,SCQ->CQ_QTDISP,0,2)
									EndIf 
								
									If SCP->CP_QUANT == SCP->CP_QUJE
										Replace CP_STATUS  with 'E'
										Replace CP_PREREQU with 'S'
									EndIf 
									MsUnlock()  
						
									Do While !SCQ->(Eof()) .And. SCP->CP_FILIAL==SCQ->CQ_FILIAL .And. SCP->CP_PRODUTO==SCQ->CQ_PRODUTO .And. SCP->CP_NUM== SCQ->CQ_NUM .And. SCP->CP_ITEM==SCQ->CQ_ITEM
										If Empty(SCQ->CQ_NUMREQ) .And. SCP->CP_STATUS == "E"
											RecLock("SCQ",.F.)
											SCQ->(dbDelete())
											SCQ->(MsUnLock())
										Else    
											RecLock("SCQ",.F.)
											If SC1->C1_SOLICIT == "SA AGLUTINADA            "
												SCQ->CQ_QUANT  -= (SCQ->CQ_QUANT - SCQ->CQ_QTDISP)
											Else 
												SCQ->CQ_QUANT  -= (SC1->C1_QTDORIG - SC1->C1_QUJE)
											EndIf   
											
											If !Empty(SCQ->CQ_QTSEGUM)
												SCQ->CQ_QTSEGUM	-= SCQ->CQ_QTSEGUM-ConvUM(SCQ->CQ_PRODUTO,SCQ->CQ_QTDISP,0,2)
											EndIf
										EndIf
						
										SCQ->(MsUnlock())
										SCQ->(dbSkip())
									EndDo	
								EndIf
							EndIf
							SCP->(dbSkip())
						EndDo		
                    EndIf	     
      			EndIf
			End Transaction
		Endif
		
	    	
	EndIf
	dbSelectArea(cAlias)
	dbSkip()
EndDo

cFilAnt := _cxFilAtu
cNumEmp := _cxcNumEmp 

If nNaoProc > 0  						//" itens nao foram processados por estar em uso em outra estacao!"
	MsgInfo(Str(nNaoProc,4) + " itens näo foram processados por estar em uso em outra estacao!","Atençäo")
EndIf

If !Empty(cQuery)
	dbSelectArea(cAlias)
	dbCloseArea()
EndIf

dbSelectArea("SC1")
PcoFinLan('000056')

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} AjustaSX1
Altera o help no SX1 para a pergunta "Percentual Maximo.

@type function
@author Ricardo Berti - TOTVS
@since 23/01/2006
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function AjustaSX1()

Local aArea   	:= GetArea() 
Local nTamSX1 	:= Len(SX1->X1_GRUPO)

Local aHelpP01	:= {}
Local aHelpE01	:= {}
Local aHelpS01	:= {}

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
Aadd( aHelpP01, "Elimina os resíduos  dos  pedidos  e/ou " )
Aadd( aHelpP01, "autorização de entrega  cujo percentual " )
Aadd( aHelpP01, "a entregar  seja  menor  ou   igual  ao " )
Aadd( aHelpP01, "percentual digitado.   Ao informar 100%," )
Aadd( aHelpP01, "elimina também as solicitações pendentes" )
Aadd( aHelpP01, "não atendidas.                          " )

Aadd( aHelpE01, "Eliminates the residue of order and or  " )
Aadd( aHelpE01, "delivery authorization whose percentage " )
Aadd( aHelpE01, "to be delivered is lower or equal to the" )
Aadd( aHelpE01, "percentage typed.    When entering 100%," )
Aadd( aHelpE01, "it also eliminates the unattended       " )
Aadd( aHelpE01, "pending requests.						 " )

Aadd( aHelpS01, "Elimina el residuo de los pedidos y/o   " )
Aadd( aHelpS01, "autorización de entrega cuyo porcentaje " )
Aadd( aHelpS01, "para ser entregado sea menor o igual al " )
Aadd( aHelpS01, "porcentaje digitado.   Al informar 100%," )
Aadd( aHelpS01, "elimina también las solicitudes         " )
Aadd( aHelpS01, "pendientes no atendidas.		  		 " )

PutSX1Help("P.MTA23501.",aHelpP01,aHelpE01,aHelpS01)   

dbSelectArea("SX1")
dbSetOrder(1)

If dbSeek(PADR("MTA235",nTamSX1)+"01")
	RecLock("SX1")
	Replace X1_VALID with "Positivo()"	
	MsUnlock()
EndIf

If dbSeek(PADR("MTA235",nTamSX1)+"04")
	RecLock("SX1")
	Replace X1_PERGUNT with "Solic/Pedido de ?"	
	MsUnlock()
EndIf
If dbSeek(PADR("MTA235",nTamSX1)+"05")
	RecLock("SX1")
	Replace X1_PERGUNT with "Solic/Pedido ate' ?"	
	MsUnlock()
EndIf

If dbSeek(PADR("MTA235",nTamSX1)+"04")
	RecLock("SX1")
	Replace X1_PERSPA with "¿ De Solic/Pedido ?"	
	MsUnlock()
EndIf
If dbSeek(PADR("MTA235",nTamSX1)+"05")
	RecLock("SX1")
	Replace X1_PERSPA with "¿A Solic/Pedido ?"	
	MsUnlock()
EndIf

If dbSeek(PADR("MTA235",nTamSX1)+"04")
	RecLock("SX1")
	Replace X1_PERENG with "From Req./Order ?"	
	MsUnlock()
EndIf
If dbSeek(PADR("MTA235",nTamSX1)+"05")
	RecLock("SX1")
	Replace X1_PERENG with "To Req./Order ?"	
	MsUnlock()
EndIf


//--< Cria perguntas para contabilizacao do lancamento 658 >--
//---------------------------------------MV_PAR16--------------------------------------------------
aHelpPor := {"Contabiliza o pedido de compra ou autorização de entrega? "}
aHelpEng := {""}
aHelpSpa := {""}

PutSX1("MTA235","16","Contabiliza Pedido ?","¨Contabiliza Pedido ?","Account for Purchase ?","mv_chf","N",1,0,1,"C","","","","N","mv_par16","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//---------------------------------------MV_PAR17--------------------------------------------------
aHelpPor := {"Exibe contabilização do pedido?"}
aHelpEng := {""}
aHelpSpa := {""}

PutSX1("MTA235","17","Mostra Lanc Contab ?","¨Mostra Asiento Contab ?","Show Accounting Entries ?","mv_chg","N",1,0,1,"C","","","","N","mv_par17","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

RestArea( aArea ) 
Return Nil


/*/================================================================================================================================/*/
/*/{Protheus.doc} MA235PCCtb
Contabiliza a eliminacao de residuo do PC/AE .

@type function
@author Marcelo Custodio - TOTVS
@since 13/02/2008
@version P12.1.23

@obs Desenvolvimento FIEG

@history 01/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro.
/*/
/*/================================================================================================================================/*/

Static Function MA235PCCtb()

LOCAL aArea     := GetArea()

LOCAL cPadrao   := "658"
LOCAL cLoteCtb  := ""

LOCAL lDigita   := If(MV_PAR17==1,.T.,.F.)                           
LOCAL lPadrao   := .F.

LOCAL nHdlPrv   := 0
LOCAL nTotal    := 0
LOCAL aCtbDia	:= {}

LOCAL cArquivo := " "

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
lPadrao := VerPadrao(cPadrao)

//--< Lancamento Contabil >---------------------------------
If ( lPadrao .and. MV_PAR16 == 1 )
	
	//--< Verifica o numero do lote contabil >--------------
	//dbSelectArea("SX5")
	OpenSxs(,,,,cEmpAnt,"SX5TMP","SX5",,.F.,.T.)
	(SX5TMP)->(dbSetOrder(1))
	If (SX5TMP)->(MsSeek(xFilial()+"09COM"))
		cLoteCtb := AllTrim(X5Descri())
	Else
		cLoteCtb := "COM "
	EndIf

	//--< Executa o execblock >-----------------------------
	If At(UPPER("EXEC"),X5Descri()) > 0
		cLoteCtb := &(X5Descri())
	EndIf
	
	nHdlPrv := HeadProva(cLoteCtb,"MATA235",Substr(cUsuario,7,6),@cArquivo)
	nTotal  += DetProva(nHdlPrv,cPadrao,"MATA235",cLoteCtb)
	RodaProva(nHdlPrv,nTotal)
	
	//--< Envia para Lancamento Contabil >------------------
	If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() ) 
		aCtbDia := {{"SC7",SC7->(RECNO()),SC7->C7_DIACTB,"C7_NODIA","C7_DIACTB"}}
	Else
	    aCtbDia := {}
	EndIF    
	cA100Incl(cArquivo,nHdlPrv,3,cLoteCtb,lDigita,.F.,,,,,,aCtbDia)
	
	(SX5TMP)->(DbCloseArea())
EndIf

RestArea(aArea)

Return(.T.)


/*/================================================================================================================================/*/
/*/{Protheus.doc} MA235PA
Indica ao Faturamento que o Pedido de Compra ou Contrato de Parceria pode ser desvinculado de Pagamento Antecipado para que o título possa ser baixado.

@type function
@author TOTVS
@since 13/09/2011
@version P12.1.23

@param aPar1, Array, Números dos PC/CP.

@obs Desenvolvimento FIEG

@history 01/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function MA235PA(aDocs)

Local aAreaSC3 	:= SC3->(GetArea())
Local aAreaSC7 	:= SC7->(GetArea())
Local aAreaFIE 	:= FIE->(GetArea())
Local nX		:= 0
Local lMarca	:= .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If ValType(aDocs)<>"U" .And. Len(aDocs)>0
	For nX := 1 To Len(aDocs)
		If aDocs[nX][3]=='PC'
			dbSelectArea("SC7")
			dbSetOrder(1)
			dbSeek(aDocs[nX][1]+aDocs[nX][2])
			Do While !Eof() .And. C7_NUM = aDocs[nX][2]
				If !SC7->C7_RESIDUO$'S' .And. !SC7->C7_ENCER$'E'
					lMarca := .F.
				EndIf
				dbskip()
			Enddo
			If lMarca
				dbSelectArea("FIE")
				dbSetOrder(1)
				If dbSeek(aDocs[nX][1]+"P"+aDocs[nX][2])
					If (aDocs[nX][1]+"P"+aDocs[nX][2])==FIE_FILIAL+FIE_CART+FIE_PEDIDO
						RecLock("FIE",.F.)
						FIE_SALDO:=0
						MsUnlock()
					EndIf
				EndIf
			EndIf
		EndIf
	Next nX
EndIf

RestArea(aAreaFIE)
RestArea(aAreaSC7)
RestArea(aAreaSC3)

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} MA235ElRes
Funcao que processa a eliminacao de residuos e seus relacionados.

@type function
@author Andre Anjos - TOTVS
@since 11/01/2013
@version P12.1.23

@param aPar1, Array, Números dos PC/CP.

@obs Desenvolvimento FIEG

@history 01/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function MA235ElRes(nNaoProc,aRefImp)

Local nPosRef1  := 0
Local nPosRef2  := 0
Local nTotItem  := 0
Local nX        := 0
Local cAliasTOP := "SCQ"
Local cQuery	:= ""
Local cTipoSC7  := ""
Local cEntrega  := ""
Local lQuery    := .F.
Local lPrcPreReq:= .F.
Local lFilEnt   := SuperGetMv("MV_PCFILEN")
Local lGCTRes   := (SuperGetMv("MV_CNRESID",.F.,"N") == "S") .And. (CND->( FieldPos("CND_RESID") ) > 0 .And. CNE->( FieldPos("CNE_RESID") ) > 0) .And. FindFunction( "GravaGCT" )

Default nNaoProc := 0

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Efetua a validacao dos parametros >-------------------
IF Valtype( MV_PAR16 ) == 'C'
	MV_PAR16 := 0
Endif
IF Valtype( MV_PAR17 ) == 'C'
	MV_PAR17 := 0
Endif

If aRefImp == NIL
	aRefImp := {} // Inicializa a variavel
	OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
	SX3TMP->(dbSetOrder(1))
	SX3TMP->(MsSeek("SC7"))
	While !SX3TMP->(Eof()) .And. SX3TMP->X3_ARQUIVO == "SC7"
		nPosRef1 := At("MAFISREF(",Upper(SX3TMP->X3_VALID))
		If nPosRef1 > 0
			nPosRef1 += 10
			nPosRef2 := At(",",SubStr(SX3TMP->X3_VALID,nPosRef1))-2
			aAdd(aRefImp,{"SC7",SX3TMP->X3_CAMPO,SubStr(SX3TMP->X3_VALID,nPosRef1,nPosRef2)})
		EndIf
		SX3TMP->(dbSkip())
	End
	SX3TMP->(DbCloseArea())
EndIf

If !lGCTRes 
	MaFisIni(C7_FORNECE,C7_LOJA,"F","N","R",aRefImp)
	MaFisIniLoad(1)
	For nX := 1 To Len(aRefImp)
		MaFisLoad(aRefImp[nX][3],FieldGet(FieldPos(aRefImp[nX][2])),1)
	Next nX
	MaFisEndLoad(1)
	MaFisAlt("IT_VALMERC",SC7->C7_TOTAL,1)
	nTotItem := MaFisRet(1,"IT_TOTAL")

	If SC7->C7_QUJE == 0
		nTotItem := MaFisRet(1,"IT_TOTAL")
	Else
		nTotItem := MaFisRet(1,"IT_TOTAL") / SC7->C7_QUANT    
		nTotItem := nTotItem * (SC7->C7_QUANT - SC7->C7_QUJE)         
	EndIf  
Else 
	//--< Se eliminacao de residuo for originado do Gestao de Contratos, >--
	//--< sera considerado a Quant.Entregue no total. >---------------------
	If SC7->C7_QUJE == 0
		nTotItem := SC7->C7_TOTAL
	Else
		nTotItem := SC7->C7_TOTAL / SC7->C7_QUANT    
		nTotItem := nTotItem * (SC7->C7_QUANT - SC7->C7_QUJE)            
	EndIf  									

EndIF

MaFisEnd()

Begin Transaction
	cEntrega  := If(lFilEnt,SB2->(SC7->(xFilEnt(SC7->C7_FILENT))),xFilial("SB2"))
	If !SB2->(dbSeek(cEntrega+SC7->C7_PRODUTO+SC7->C7_LOCAL))
		CriaSb2( SC7->C7_PRODUTO,SC7->C7_LOCAL,cEntrega)
	Endif
	//--< A rotina a seguir garante o funcionamento correto na base historica dos clientes, >--
	//--< pois com a implementacao do parametro MV_AEAPROV que estende o controle de alcadas >-
	//--< para a AE, em 22/07/04 foi alterada a gravacao do tipo do doc para PC e AE afim >----
	//--< de diferenciar o tipo de doc nos arquivos SC7 e SCR sem afetar o funcionamento ant>--
	cTipoSC7 := "PC"
	SCR->(dbSeek(xFilial("SCR")+"PC"+SC7->C7_NUM,.T.))

	If SCR->( Eof() )
		If SCR->(dbSeek(xFilial("SCR")+"AE"+SC7->C7_NUM,.T.))
			cTipoSC7 := "AE"
		EndIf
	EndIF

	If SimpleLock("SC7") .And. SimpleLock("SB2") .And.;
			If(xFilial("SCR")+cTipoSC7+SC7->C7_NUM == SCR->CR_FILIAL+SCR->CR_TIPO+Subs(SCR->CR_NUM,1,Len(SC7->C7_NUM)),;
			SimpleLock("SCR"),.T.)
			
		RecLock("SC7",.F.)
		Replace C7_RESIDUO with "S"

		dbSelectArea("SCR")
		If xFilial("SCR")+cTipoSC7+SC7->C7_NUM == SCR->CR_FILIAL+SCR->CR_TIPO+Subs(SCR->CR_NUM,1,Len(SC7->C7_NUM))
			MaAlcDoc({SC7->C7_NUM,cTipoSC7,nTotItem,,,SC7->C7_APROV,,SC7->C7_MOEDA,SC7->C7_TXMOEDA,SC7->C7_EMISSAO},SC7->C7_EMISSAO,5,,.T.)
		EndIf
            PcoDetLan('000056','02','MATA235')
		RecLock("SB2",.F.)
		dbSelectArea("SF4")
   		dbSetOrder(1)
		If !SF4->F4_ESTOQUE == "N" //VERIFICAR SE O TES NÃO ATUALIZA ESTOQUE, SE SIM, RETIRA DO ESTOQUE, SE NAO DEXA COMO ESTA
				GravaB2Pre("-",(SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA),SC7->C7_TPOP,(SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)*(SC7->C7_QTSEGUM/SC7->C7_QUANT))
		Endif
		If SC7->C7_TIPO == 2
			lPrcPreReq := .T.
		EndIf    

		//--< Eliminação de Resíduos no SIGAGCT >--
		If !Empty(SC7->C7_CONTRA) .And. lGCTRes
			GravaGCT(nTotItem,SC7->C7_QUJE,SC7->C7_MOEDA,SC7->C7_TXMOEDA,SC7->C7_EMISSAO,.T.)
		EndIf
	Else
		nNaoProc ++
	EndIf 

	//--< Processa eliminacao de residuo da baixa da pre-requisicao >--
	If lPrcPreReq
		#IFDEF TOP        
			If TcSrvType() <> "AS/400"
				lQuery    := .T.
				cAliasTOP := GetNextAlias()
				If Select(cAliasTOP) > 0 
			    	dbSelectArea(cAliasTOP)
			       	dbCloseArea()
				EndIf    
				
				cQuery := "	SELECT 	SCP.CP_FILIAL, SCP.CP_PRODUTO, SCP.CP_NUM,    SCP.CP_ITEM,    SCP.CP_QUANT, "
				cQuery += "     	SCQ.CQ_QTDISP, SCP.CP_QTSEGUM, SCQ.CQ_NUMREQ, SCQ.CQ_QTSEGUM, SCQ.CQ_QUANT, "
				cQuery += "     	SCQ.CQ_PRODUTO, SCP.R_E_C_N_O_ SCPRECNO, SCQ.R_E_C_N_O_ SCQRECNO "
				cQuery += "   FROM "+RetSqlName("SCP")+" SCP, "+RetSqlName("SCQ")+" SCQ "
				cQuery += "  WHERE SCP.CP_FILIAL  = '"+xFilial("SCP")+"'"
				cQuery += "    and SCQ.CQ_FILIAL  = '"+xFilial("SCQ")+"'"
				cQuery += "	   and SCP.CP_PRODUTO = SCQ.CQ_PRODUTO "
				cQuery += "    and SCP.CP_LOCAL   = SCQ.CQ_LOCAL   " 
				cQuery += "	   and SCP.CP_NUM     = SCQ.CQ_NUM     "
				cQuery += "	   and SCP.CP_ITEM    = SCQ.CQ_ITEM    "
				cQuery += "    and SCQ.CQ_NUMAE   = '"+SC7->C7_NUM+"'"
				cQuery += "    and SCQ.CQ_ITAE    = '"+SC7->C7_ITEM+"'"
				cQuery += "    and SCQ.CQ_QUANT   > SCQ.CQ_QTDISP  "
				cQuery += "	   and SCP.CP_STATUS  <> 'E' "
 				cQuery += "    and SCP.D_E_L_E_T_ = ' '  "
				cQuery += "    and SCQ.D_E_L_E_T_ = ' '  "
				cQuery += " ORDER BY SCP.CP_FILIAL, SCP.CP_PRODUTO, SCP.CP_NUM, SCP.CP_ITEM   "
										
				cQuery := ChangeQuery(cQuery)				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTOP)
				
				aEval(SCP->(dbStruct()), {|x| If(x[2] <> "C" .And. SCP->(FieldPos(x[1]) > 0 ), TcSetField(cAliasTOP,x[1],x[2],x[3],x[4]),Nil)})
				aEval(SCQ->(dbStruct()), {|x| If(x[2] <> "C" .And. SCQ->(FieldPos(x[1]) > 0 ), TcSetField(cAliasTOP,x[1],x[2],x[3],x[4]),Nil)})
				
				Do While !(cAliasTOP)->(Eof())
					SCP->(MsGoto((cAliasTOP)->SCPRECNO))
					RecLock("SCP",.F.)
			   		SCP->CP_QUANT -= ((cAliasTOP)->CP_QUANT - (cAliasTOP)->CQ_QTDISP)                      

					If !Empty((cAliasTOP)->CP_QTSEGUM)
						SCP->CP_QTSEGUM	-= (cAliasTOP)->CP_QTSEGUM-ConvUM((cAliasTOP)->CP_PRODUTO,(cAliasTOP)->CQ_QTDISP,0,2)
					EndIf   
					MsUnlock()
					
					//--< Verifica se encerra a Pre-Requisicao >--
					If SCP->CP_QUANT == SCP->CP_QUJE
						Replace CP_STATUS  with 'E'
						Replace CP_PREREQU with 'S'
						MsUnlock()
					EndIf
					//--< Acerto na tabela SCQ (Eliminar Residuo) >--
					cSeekSCQ := (cAliasTOP)->CP_FILIAL+(cAliasTOP)->CP_PRODUTO+(cAliasTOP)->CP_NUM+(cAliasTOP)->CP_ITEM
	    			Do While !(cAliasTOP)->(Eof()) .And. cSeekSCQ == (cAliasTOP)->CP_FILIAL+(cAliasTOP)->CP_PRODUTO+(cAliasTOP)->CP_NUM+(cAliasTOP)->CP_ITEM
			   			SCQ->(MsGoto((cAliasTOP)->SCQRECNO))
						If Empty((cAliasTOP)->CQ_NUMREQ) .And. SCP->CP_STATUS == "E"
							RecLock("SCQ",.F.)
							dbDelete()
							MsUnLock()
						Else    
							RecLock("SCQ",.F.)
							SCQ->CQ_QUANT  -= ((cAliasTOP)->CQ_QUANT - (cAliasTOP)->CQ_QTDISP)

							If !Empty((cAliasTOP)->CQ_QTSEGUM)
								SCQ->CQ_QTSEGUM	-= (cAliasTOP)->CQ_QTSEGUM-ConvUM((cAliasTOP)->CQ_PRODUTO,(cAliasTOP)->CQ_QTDISP,0,2)
							EndIf
							MsUnlock() 
						EndIf
						dbSelectArea(cAliasTop)
						dbSkip()
					EndDo										
				EndDo          	
				(cAliasTOP)->(dbCloseArea())  
			EndIf
	
		#ENDIF     

		If !lQuery
			dbSelectArea("SCQ")
			dbSetOrder(3)					
			dbSeek(xFilial("SCQ")+SC7->C7_NUM+SC7->C7_ITEM,.F.)
		
			dbSelectArea("SCP")
			dbSetOrder(2)		
			dbSeek(xFilial("SCP")+SCQ->CQ_PRODUTO+SCQ->CQ_NUM+SCQ->CQ_ITEM)
							
			Do While !SCP->(Eof())	.And. (SCP->CP_PRODUTO == SCQ->CQ_PRODUTO .And. SCP->CP_LOCAL == SCQ->CQ_LOCAL .And. SCQ->CQ_QUANT > SCQ->CQ_QTDISP .And. SCP->CP_STATUS <> 'E')
								
				RecLock("SCP",.F.)
				SCP->CP_QUANT -= (SCP->CP_QUANT - SCQ->CQ_QTDISP)                      
				
				If !Empty(SCP->CP_QTSEGUM)
					SCP->CP_QTSEGUM	-= SCP->CP_QTSEGUM-ConvUM(SCP->CP_PRODUTO,SCQ->CQ_QTDISP,0,2)
				EndIf 
					
				If SCP->CP_QUANT == SCP->CP_QUJE
					Replace CP_STATUS  with 'E'
					Replace CP_PREREQU with 'S'
				EndIf 
				MsUnlock()  
								
				Do While !SCQ->(Eof()) .And. SCP->CP_FILIAL==SCQ->CQ_FILIAL .And. SCP->CP_PRODUTO==SCQ->CQ_PRODUTO .And. SCP->CP_NUM== SCQ->CQ_NUM .And. SCP->CP_ITEM==SCQ->CQ_ITEM
					If Empty(SCQ->CQ_NUMREQ) .And. SCP->CP_STATUS == "E"
						RecLock("SCQ",.F.)
						dbDelete()
						MsUnLock()
					Else    
						RecLock("SCQ",.F.)
						SCQ->CQ_QUANT  -= (SCQ->CQ_QUANT - SCQ->CQ_QTDISP)
							
						If !Empty(SCQ->CQ_QTSEGUM)
							SCQ->CQ_QTSEGUM	-= SCQ->CQ_QTSEGUM-ConvUM(SCQ->CQ_PRODUTO,SCQ->CQ_QTDISP,0,2)
						EndIf
					EndIf
								
					MsUnlock() 	
					dbSelectArea("SCQ")
					dbSkip()
				EndDo	
				dbSelectArea("SCP") 		
				dbSkip()
			EndDo		
		EndIf	     
	EndIf	

End Transaction

dbSelectArea("SC7")

//--< Contabiliza eliminacao de residuo do pedido de compra >--
MA235PCCtb()
			
Return nNaoProc == 0                                                             


/*/================================================================================================================================/*/
/*/{Protheus.doc} DTCOM10V
Funcao para controle de versao.

@type function
@author Doit Sistemas
@since 02/09/2014
@version P12.1.23

@param aPar1, Array, Números dos PC/CP.

@obs Desenvolvimento FIEG

@history 01/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, Versão do fonte
/*/
/*/================================================================================================================================/*/


User Function DTCOM10V() 

Local cRet  := ""                         

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cRet := "20140902001" 
        
Return (cRet) 
