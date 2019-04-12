#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SICOMA20
Estorno do edital ate a Status HO.

@type function
@author alago@totvs.com.br
@since 13/01/2012 
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

User Function SICOMA20

Local aArea			:= GetArea()
Local lRet			:= .T.
Local cEtapa    	:= "HO"
Local cDescEtapa 	:= "HOMOLOGACAO / ADJUDICACAO"
Local cProxPasso 	:= "20"  // homolocacao
Local cCO7Acao		:= ""
Local nIndexFornec := 0, cAntigaEtapa

Private cFornCan	:= ""
Private cLojaCan	:= ""
Private aDados      := {}, aDadosTodosProds := {}                              
Private nItemIndx   := 0

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
AjustSX()

if CO1->CO1_ETAPA != "PC" .and. CO1->CO1_ETAPA != "CO"
	Help("",1,"ICOMA20NOPER") //"Somente edital fechado com Pedido de Compra ou Contrado poderá ter estorno "
	lRet := .F.
EndIf                                                   

If lRet
	If MsgYesNo("Confirma o Estorno no Edital "+AllTrim(CO1->CO1_CODEDT)+"?","Estorno")
		//Justificativa
		cAntigaEtapa := CO1->CO1_ETAPA
		
		If Justif(@cCO7Acao)		                  
			
        	Begin Transaction                                                      

	  		for nIndexFornec := 1 to Len(aDados)       

				//--< Grava Cancelamento do fornecedor - CO3 >--
				If aDados[nIndexFornec][1] == .T.      

					GrvCO3(CO1->CO1_CODEDT,CO1->CO1_NUMPRO,aDados[nIndexFornec][3],aDados[nIndexFornec][4])		 
					//--< Grava Historico - CO7 >-----------
					cEtapa     := "HO"
					cDescEtapa := "HOMOLOGACAO / ADJUDICACAO"
					cProxPasso := "20"  					// homolocacao
					aGrvCO7 := {	{"CO7_CODEDT", CO1->CO1_CODEDT},;        
									{"CO7_NUMPRO", CO1->CO1_NUMPRO},;                     
									{"CO7_VERSAO", CO1->CO1_VERSAO},;
									{"CO7_DTMOV" , dDataBase},;
									{"CO7_HRMOV" , Time()},;
									{"CO7_CODUSU", Upper(Alltrim(Substr(cUsuario,7,15)))},;
									{"CO7_MOVATU", cEtapa},;                       
									{"CO7_DESATU",  Tabela("LE",CO1->CO1_ETAPA,.F.)},;
									{"CO7_ACAO"  , (cCO7Acao + " " + aDados[nIndexFornec][3]  + " " + aDados[nIndexFornec][4]) }}
										
					//--< Retorno status do edital - CO1 >--
					aGrvCO1 := {	{"CO1_ETAPA" , cEtapa      },;
									{"CO1_DESETA", cDescEtapa  },;
									{"CO1_PASSO" , cProxPasso  }}
		   	
					GCPA006(aGrvCO7, aGrvCO1 , aDados[nIndexFornec][3])	//gera uma réplica do Histórico por fornecedor apontado		 
				EndIf
							
			Next 
			                                                                     
			LimpaIndicadorDeEstorno(CO1->CO1_CODEDT,CO1->CO1_NUMPRO, cAntigaEtapa )                  
						                   			              
  			End Transaction             
			
		Else
			MsgInfo("Edital "+AllTrim(CO1->CO1_CODEDT)+" não estornado","Estorno")
		EndIf			
	Else
		MsgInfo("Edital "+AllTrim(CO1->CO1_CODEDT)+" não estornado","Estorno")
	EndIf	
Else
	MsgInfo("Edital "+AllTrim(CO1->CO1_CODEDT)+" não estornado","Estorno")
EndIf

RestArea(aArea)

Return
         

/*/================================================================================================================================/*/
/*/{Protheus.doc} ValidPC
Valida dados de Pedidos para Participantes apontados, usado na rotina de Estorno do edital ate a Status HO (SICOMA20).

@type function
@author alago@totvs.com.br
@since 18/01/2012
@version P12.1.23

@param cEdital	, Caractere, Código do Edital.
@param cProcesso, Caractere, Código do Processo.
@param cFornec	, Caractere, Código do Fornecedor.
@param cLoja	, Caractere, Código da Loja do Fornecedor.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

Static Function ValidPC(cEdital,cProcesso,cFornec,cLoja)

Local lRet		:= .T.
Local cQuery 	:= ""
Local cAliasTmp	:= "ALLSC7TMP" 
Local nSaldo	:= 0

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cQuery := " select SC7.* "
cQuery += " from " + RetSqlTab("SC7") 	+ " "
cQuery += " where SC7.C7_CODED = '" 	+ cEdital   + "' "
cQuery += "   and SC7.C7_NUMPR = '" 		+ cProcesso + "' "
cQuery += "   and SC7.C7_LOJA = '" 		+ cLoja     + "' "                                                                           
cQuery += "   and SC7.C7_FORNECE = '" 	+ cFornec   + "' "                     
cQuery += "   and SC7.D_E_L_E_T_ = ' ' "
cQuery += LstFiliais(cEdital, cProcesso, xFilial("SC7"), " SC7.C7_FILIAL ")

cQuery := ChangeQuery(cQuery)                                  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)

If !(cAliasTmp)->(Eof())
	While !(cAliasTmp)->(Eof())
		If (cAliasTmp)->C7_QUANT > (cAliasTmp)->C7_QUJE
			If (cAliasTmp)->C7_RESIDUO <> "S"    
				MsgInfo( "(" + (cAliasTmp)->C7_FILIAL + ") Este edital possui Pedido de Compras em Aberto para o Participante: " + cFornec + " Loja: " + cLoja + ". Utilize a rotina 'Elimina Resíduo' para encerrá-lo. O Edital não será estornado.","Estorno")
				lRet := .F.
				Exit
			EndIf
		EndIf
        nSaldo := nSaldo + (cAliasTmp)->C7_QUANT - (cAliasTmp)->C7_QUJE
		(cAliasTmp)->(dbSkip())
	End
Else
	MsgInfo("Não existem pedidos do Participante " + cFornec + " Loja " + cLoja + " para este edital, não é permitido estornar", "Estorno")
	lRet := .F.  
EndIf

If nSaldo == 0 .and. lRet
	MsgInfo("Não existe saldo nos pedidos do Participante " + cFornec + " Loja " + cLoja + " para este edital, não é permitido estornar ","Estorno")
	lRet := .F.    
EndIf

(cAliasTmp)->(DbCloseArea())

Return(lRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} ValidCO
Valida dados de contrato para Participantes apontados, usado na rotina de Estorno do edital ate a Status HO (SICOMA20).

@type function
@author alago@totvs.com.br
@since 18/01/2012
@version P12.1.23

@param cEdital	, Caractere, Código do Edital.
@param cProcesso, Caractere, Código do Processo.
@param cFornec	, Caractere, Código do Fornecedor.
@param cLoja	, Caractere, Código da Loja do Fornecedor.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

Static Function ValidCO(cEdital,cProcesso,cFornec,cLoja)

Local lRet		:= .T.
Local cQuery 	:= ""
Local cAliasTmp	:= "ALLCN9TMP"
Local cAlTmp	:= "TRB_CNC"

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cQuery := " select CNC.* "                                                                  
cQuery += " from " + RetSqlTab("CNC") + " "
cQuery += " where CNC.CNC_CODED = '"  + cEdital + "' "
cQuery += "   and CNC.CNC_NUMPR = '"  + cProcesso + "' "
cQuery += "   and CNC.CNC_CODIGO = '" + cFornec + "' "
cQuery += "   and CNC.CNC_LOJA = '"   + cLoja + "' "
cQuery += "   and CNC.D_E_L_E_T_ = ' ' "
cQuery += LstFiliais(cEdital, cProcesso, xFilial("CNC"), " CNC.CNC_FILIAL ")
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlTmp)

If (cAlTmp)->(Eof())    
	(cAlTmp)->(DbCloseArea())
	MsgInfo("Não existem contratos do Participante " + cFornec + " Loja " + cLoja + " para este edital, não é permitido estornar ","Estorno")
	lRet := .F.	
Else
	cQuery := " SELECT CN9.* "
	cQuery += " FROM " + RetSqlTab("CN9") + " "
	cQuery += " WHERE CN9.CN9_CODED = '" +cEdital + "' "                      
	cQuery += " AND CN9.CN9_NUMPR = '" + cProcesso + "' "
	cQuery += " AND CN9.CN9_NUMERO = '" + (cAlTmp)->(CNC_NUMERO) + "' "
	cQuery += " AND CN9.D_E_L_E_T_ = ' ' "
	cQuery += LstFiliais(cEdital, cProcesso, xFilial("CN9"), " CN9.CN9_FILIAL ")
	(cAlTmp)->(DbCloseArea())

EndIf

If lRet
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)
		
	If !(cAliasTmp)->(Eof())
		While !(cAliasTmp)->(Eof())
			//--< Validar que não esteja com status de "Finalizado" (CN9->CN9_SITUAC= '08'). >--
			If (cAliasTmp)->CN9_SITUAC == '08'
				MsgInfo("(" + (cAliasTmp)->CN9_FILIAL + ") Este edital possui contrato finalizado (Participante: " + cFornec + " Loja: " + cLoja + "). O Edital não será estornado.","Estorno")
				lRet := .F.		
			EndIf
			
			//--< Contrato Cancelado: se o contrato estiver cancelado, o processo de estorno poderá seguir >--
			If (cAliasTmp)->CN9_SITUAC $ '05' .and. lRet
				//Tem medição em aberto
				dbSelectArea("CND")
				CND->(dbSetOrder(1))
				CND->(dbSeek((cAliasTmp)->CN9_FILIAL+(cAliasTmp)->CN9_NUMERO+(cAliasTmp)->CN9_REVISA))
				While !CND->(Eof()) .and. (cAliasTmp)->CN9_NUMERO+(cAliasTmp)->CN9_REVISA == CND->CND_CONTRA+CND->CND_REVISA
					If Empty(CND->CND_DTFIM) .And. CND->CND_AUTFRN == '1'
						MsgInfo("(" + (cAliasTmp)->CN9_FILIAL + ") O contrato do Participante " + cFornec + " Loja " + cLoja + " deste edital possui medições em aberto. O Edital não será estornado.","Estorno")
						lRet := .F.	
						Exit
					EndIf
					
					If !Empty(CND->CND_DTFIM) .And. CND->CND_AUTFRN == '1'
						dbSelectArea("CNE")
						CNE->(dbSetOrder(1))
						CNE->(dbSeek(CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+CND->CND_NUMMED))
			
						While !CNE->(Eof()) .and. CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+CND->CND_NUMMED == CNE->CNE_FILIAL+CNE->CNE_CONTRA+CNE->CNE_REVISA+CNE->CNE_NUMERO+CNE->CNE_NUMMED
							dbSelectArea("SC7")
							SC7->(dbSetOrder(1))
							SC7->(dbSeek(CND->CND_FILIAL+CND->CND_PEDIDO))
							While !SC7->(Eof())
								If CND->CND_FILIAL == SC7->C7_FILIAL .And. CND->CND_PEDIDO == SC7->C7_NUM  .and.  SC7->C7_FORNECE == cFornec .and.  SC7->C7_LOJA == cLoja
									If SC7->C7_QUANT > SC7->C7_QUJE
										If SC7->C7_RESIDUO <> "S"
											MsgInfo( "( " + SC7->C7_FILIAL + " ) Este edital possui Pedido de Compras em Aberto(Participante: " + cFornec + " Loja: " + cLoja + "). Utilize a rotina 'Elimina Resíduo' para encerrá-lo. O Edital não será estornado.","Estorno")
											lRet := .F.
											Exit
										EndIf
									EndIf
								EndIf
								SC7->(dbSkip())
							EndDo
							
							dbSelectArea("CNE")
			
							IF lRet == .F.	
								Exit
							EndIf
			
							CNE->(dbSkip())
						EndDo
					EndIf
					
					dbSelectArea("CND")
					
					IF	lRet == .F.	
						Exit
					EndIf
			
					CND->(dbSkip())
				EndDo                      
													
			EndIf			                      
			
			IF	lRet == .F.	                                       
				Exit
			EndIf
			
			If (cAliasTmp)->CN9_SITUAC $ '01' .and. lRet 
				If (cAliasTmp)->CN9_SALDO == 0              
					MsgInfo("(" + (cAliasTmp)->CN9_FILIAL + ") Não existe saldo nos pedidos/contratos (Participante: " + cFornec + " Loja: " + cLoja + ") para este edital, não é permitido estornar ","Estorno")
					lRet := .F.
					Exit
				EndIf
			EndIf                           

			//--< se contrato nao esta cancelado e nao esta com status revisao >--
			If !(cAliasTmp)->CN9_SITUAC $ '01' .and. !(cAliasTmp)->CN9_SITUAC $ '10' .and. lRet
				MsgInfo("(" + (cAliasTmp)->CN9_FILIAL + ") Cancelar o contrato(Participante: " + cFornec + " Loja: " + cLoja + ")","Estorno")
				lRet := .F.
				Exit
			EndIf
			
			(cAliasTmp)->(dbSkip())
		EndDo			
	Else
		MsgInfo("Não existem contratos do Participante " + cFornec + " Loja " + cLoja + " para este edital, não é permitido estornar ","Estorno")
		lRet := .F.
	EndIf
EndIf

(cAliasTmp)->(DbCloseArea())

Return(lRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} Justif
Justificativa para o estorno, usado na rotina de Estorno do edital ate a Status HO (SICOMA20).

@type function
@author alago@totvs.com.br
@since 18/01/2012
@version P12.1.23

@param cSC7Acao	, Caractere, Dados da Ação.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

Static Function Justif(cSC7Acao)

Local oFont1
Local oDlg      := Nil
Local cObsSC    := ""
Local oObsSC 

Local nOpca     := -1, nX, lNaoMarcou := .F., lProbComRegs := .F.
Local bOk       := {|| nOpca:=1, oDlg:End() }
Local bCancel   := {|| nOpca:=0, oDlg:End() }
Local cEOL      := Chr(13)+Chr(10)

Define Font oFont1 Name "Consolas" Size 07,17
Private oLbx
Private aTitulo := {}
Private aTam 	:= {}
Private oOk     := LoadBitmap( GetResources(), "CHECKED" )
Private oNo     := LoadBitmap( GetResources(), "UNCHECKED" )

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
ArrayMrkBrowse (CO1->CO1_CODEDT, CO1->CO1_NUMPRO)

Do While ((Empty(cObsSC) .or. lNaoMarcou ) .and. nOpca != 0) .or. (lProbComRegs .and. nOpca != 0)

	Define MsDialog oDlg Title "Justificativa de Estorno de Edital" From 0,0 To /*190*/400,532 Of oDlg Pixel

	@ 06,06 To 200,260 LABEL " Informe um Motivo Único para o Estorno deste Edital" OF oDlg PIXEL
	@ 150,20 Get oObsSC     Var cObsSC Multiline Text Font oFont1 Size 235,30 Pixel Of oDlg
	
	@ 182,100 Button "&Ok"       Size 36,16 Pixel Action Eval(bOk)
	@ 182,140 Button "&Cancela"  Size 36,16 Pixel Action Eval(bCancel)
	
	//=============== Grid para apontamento de fornecedores ===========================
	oLbx := TwBrowse():New(15,20,235,130,,aTitulo,,/*oDlg*/,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx:aColSizes := aTam
	oLbx:SetArray( aDados )              

	oLbx:bLDblClick := {|| aDados[oLbx:nAt,1] := !aDados[oLbx:nAt,1],oLbx:Refresh()}     
	oLbx:bLine := GCAbLine( aDados )
	//=============== Grid para apontamento de fornecedores ===========================	
	
	Activate MsDialog oDlg Center

   	If nOpca == 0
   		MsgStop("O processamento foi abortado.","Motivo do Estorno")
   	Else
	   	If Empty(cObsSC)
			MsgAlert("O Motivo deve ser informado." +cEOL+cEOL+ "Se necessario abortar clique em 'Cancelar'.","Motivo do Estorno")				
	   	ElseIf Len(cObsSC) < 5
			MsgAlert("O Motivo informado é muito curto.","Motivo do Estorno")				
		Else            

			lNaoMarcou := .T.
			lProbComRegs := .F.
			
			For nX := 1 to Len(aDados)

				If aDados[nX][1] == .T.                  
					lNaoMarcou := .F.
		              
					If CO1->CO1_ETAPA == "PC"
					  	If !ValidPC(CO1->CO1_CODEDT,CO1->CO1_NUMPRO, aDados[nX][3], aDados[nX][4])
							lProbComRegs := .T.						    
							Exit
						EndIf
					
					ElseIf CO1->CO1_ETAPA == "CO"
				
						If !ValidCO(CO1->CO1_CODEDT,CO1->CO1_NUMPRO, aDados[nX][3], aDados[nX][4])  
							lProbComRegs := .T.
						    exit
						EndIf

					EndIf 	
				EndIf	
			Next         
		
			If lNaoMarcou	
				MsgAlert("É necessário apontar os Participantes que ocasionaram o Estorno","Motivo do Estorno")
			Else                         
				cSC7Acao := cObsSC
			EndIf
			
		EndIf	
	EndIf

	Loop	
	
EndDo
  
Return(If(nOpca==0 .or. Len(cObsSC) < 5,.f.,.t.))


/*/================================================================================================================================/*/
/*/{Protheus.doc} GrvCO3
Grava CO3, usado na rotina de Estorno do edital ate a Status HO (SICOMA20).

@type function
@author alago@totvs.com.br
@since 18/01/2012
@version P12.1.23

@param cEdital	, Caractere, Código do Edital.
@param cProcesso, Caractere, Código do Processo.
@param cFornec	, Caractere, Código do Fornecedor.
@param cLoja	, Caractere, Código da Loja do Fornecedor.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Retorna verdadeiro se validações estiverem OK.
/*/
/*/================================================================================================================================/*/

Static Function GrvCO3(cEdital,cProcesso, cFornec, cLoja)		

Local lRet 		:= .T.

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
dbSelectArea("CO3")
CO3->(dbSetOrder(1))
CO3->(dbSeek(xFilial("CO3")+cEdital+cProcesso))

While !CO3->(eof())
	
	If ( CO3->CO3_CLASS == "1" .or. CO3->CO3_CLASS == "X" ) .and. ;
	   ( cEdital == CO3->CO3_CODEDT .and. cProcesso == CO3->CO3_NUMPRO .and. cFornec == CO3->CO3_CODIGO .and. cLoja ==  CO3->CO3_LOJA )
	   
		RecLock("CO3",.f.)     
			CO3->CO3_CLASS 	:= "X"
			CO3->CO3_XSTATU := "1"
		CO3->(MsUnLock())
	EndIf	             
	
    CO3->(dbSkip())
EndDo

Return(lRet)


/*/================================================================================================================================/*/
/*/{Protheus.doc} AjustSX
Ajusta os arquivos de configuração, usado na rotina de Estorno do edital ate a Status HO (SICOMA20).

@type function
@author alago@totvs.com.br
@since 13/01/2012
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function AjustSX()

Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpEsp := {}
Local aSoluPor := {}
Local aSoluEng := {}
Local aSoluSpa := {}

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
aHelpPor :=	{"Somente edital fechado com Pedido de","Compras ou Contrado poderá ter estorno  "}
aHelpEng := {"Somente edital fechado com Pedido de","Compras ou Contrado poderá ter estorno  "}
aHelpEsp := {"Somente edital fechado com Pedido de","Compras ou Contrado poderá ter estorno  "}
aSoluPor := {"Escolha um edital fechado que gerou","Pedido de Compras ou Contrado"}
aSoluEng := {"Escolha um edital fechado que gerou","Pedido de Compras ou Contrado"}
aSoluSpa := {"Escolha um edital fechado que gerou","Pedido de Compras ou Contrado"}
PutHelp("PICOMA20NOPER",aHelpPor,aHelpEng,aHelpEsp,.T.)     
PutHelp("SICOMA20NOPER",aSoluPor,aSoluEng,aSoluSpa,.T.)     

aHelpPor :=	{"Não existem contratos/pedidos de compras","para este edital.","Não é permitido estornar."}
aHelpEng := {"Não existem contratos/pedidos de compras","para este edital.","Não é permitido estornar."}
aHelpEsp := {"Não existem contratos/pedidos de compras","para este edital.","Não é permitido estornar."}
aSoluPor := {"Escolha um edital que possua pedidos ou","contratos com saldo"}
aSoluEng := {"Escolha um edital que possua pedidos ou","contratos com saldo"}
aSoluSpa := {"Escolha um edital que possua pedidos ou","contratos com saldo"}
PutHelp("PICOMA20NOPED",aHelpPor,aHelpEng,aHelpEsp,.T.)     
PutHelp("SICOMA20NOPED",aSoluPor,aSoluEng,aSoluSpa,.T.)     

aHelpPor :=	{"Este edital possui Pedido de Compras em ","Aberto. ","O Edital não será estornado."}
aHelpEng := {"Este edital possui Pedido de Compras em ","Aberto. ","O Edital não será estornado."}
aHelpEsp := {"Este edital possui Pedido de Compras em ","Aberto. ","O Edital não será estornado."}
aSoluPor := {"Utilize a rotina 'Elimina Resíduo' para ","encerrá-lo. "}
aSoluEng := {"Utilize a rotina 'Elimina Resíduo' para ","encerrá-lo. "}
aSoluSpa := {"Utilize a rotina 'Elimina Resíduo' para ","encerrá-lo. "}
PutHelp("PICOMA20PEDAB",aHelpPor,aHelpEng,aHelpEsp,.T.)     
PutHelp("SICOMA20PEDAB",aSoluPor,aSoluEng,aSoluSpa,.T.)     

aHelpPor :=	{"Não existem saldo no contrato/pedido ","para este edital.","Não é permitido estornar "}
aHelpEng := {"Não existem saldo no contrato/pedido ","para este edital.","Não é permitido estornar "}
aHelpEsp := {"Não existem saldo no contrato/pedido ","para este edital.","Não é permitido estornar "}
aSoluPor := {"Escolha um edital que possua pedidos ou ","contratos com saldo"}
aSoluEng := {"Escolha um edital que possua pedidos ou ","contratos com saldo"}
aSoluSpa := {"Escolha um edital que possua pedidos ou ","contratos com saldo"}                     
PutHelp("PICOMA20NOSDO",aHelpPor,aHelpEng,aHelpEsp,.T.)     
PutHelp("SICOMA20NOSDO",aSoluPor,aSoluEng,aSoluSpa,.T.)     

aHelpPor :=	{"Este edital possui contrato finalizado. ","O Edital não será estornado."}
aHelpEng := {"Este edital possui contrato finalizado. ","O Edital não será estornado."}
aHelpEsp := {"Este edital possui contrato finalizado. ","O Edital não será estornado."}
aSoluPor := {"Escolha um edital que possua pedidos ou ","contratos com saldo"}
aSoluEng := {"Escolha um edital que possua pedidos ou ","contratos com saldo"}
aSoluSpa := {"Escolha um edital que possua pedidos ou ","contratos com saldo"}
PutHelp("PICOMA20COFIN",aHelpPor,aHelpEng,aHelpEsp,.T.)     
PutHelp("SICOMA20COFIN",aSoluPor,aSoluEng,aSoluSpa,.T.)     

aHelpPor :=	{"O contrato deste edital possui medições ","em aberto. O Edital não será estornado."}
aHelpEng := {"O contrato deste edital possui medições ","em aberto. O Edital não será estornado."}
aHelpEsp := {"O contrato deste edital possui medições ","em aberto. O Edital não será estornado."}
aSoluPor := {"Excluir as medições em aberto e cancelar ","o contrato"}
aSoluEng := {"Excluir as medições em aberto e cancelar ","o contrato"}
aSoluSpa := {"Excluir as medições em aberto e cancelar ","o contrato"}
PutHelp("PICOMA20COMED",aHelpPor,aHelpEng,aHelpEsp,.T.)     
PutHelp("SICOMA20COMED",aSoluPor,aSoluEng,aSoluSpa,.T.)     

aHelpPor :=	{"O contrato deste edital precisa estar ","cancelado. ","O Edital não será estornado."}
aHelpEng := {"O contrato deste edital precisa estar ","cancelado. ","O Edital não será estornado."}
aHelpEsp := {"O contrato deste edital precisa estar ","cancelado. ","O Edital não será estornado."}
aSoluPor := {"Cancelar o contrato"}
aSoluEng := {"Cancelar o contrato"}
aSoluSpa := {"Cancelar o contrato"}
PutHelp("PICOMA20COCAN",aHelpPor,aHelpEng,aHelpEsp,.T.)     
PutHelp("SICOMA20COCAN",aSoluPor,aSoluEng,aSoluSpa,.T.)     

Return


/*/================================================================================================================================/*/
/*/{Protheus.doc} CriaHeader
Cria o Aheader da getdados, usado na rotina de Estorno do edital ate a Status HO (SICOMA20).

@type function
@author Alvaro Camillo Neto - TOTVS
@since 21/02/2008
@version P12.1.23

@param cCampos	, Caractere, Campos a serem considerados.
@param cExcessao, Caractere, Campos a serem considerados.
@param aHeader	, Caractere, Código do Fornecedor.
@param cAlias	, Caractere, Código da Loja do Fornecedor.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Array, Retorna dados do SX3 para o Header.
/*/
/*/================================================================================================================================/*/

Static Function CriaHeader(cCampos,cExcessao,aHeader,cAlias)

Local 	aArea		:= GetArea()

Default aHeader 	:= {}
Default cCampos 	:= ""
Default cExcessao	:= ""

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
OpenSxs(,,,,cEmpAnt,"SX3TMP","SX3",,.F.,.T.)
SX3TMP->(dbSetOrder(1))
SX3TMP->(dbSeek(cAlias))

While SX3TMP->(!EOF()) .And.  SX3TMP->X3_ARQUIVO == cAlias
	If (X3USO(SX3TMP->X3_USADO) .Or. ( AllTrim(SX3TMP->X3_CAMPO) $ Alltrim(cCampos) )) .AND. (cNivel >= SX3TMP->X3_NIVEL) .AND. !(AllTrim(SX3TMP->X3_CAMPO) $ Alltrim(cExcessao)) 
		aAdd( aHeader, { AlLTrim( X3Titulo() ), ;	// 01 - Titulo
						 SX3TMP->X3_CAMPO	  , ;	// 02 - Campo
						 SX3TMP->X3_Picture	  , ;	// 03 - Picture
						 SX3TMP->X3_TAMANHO	  , ;	// 04 - Tamanho
						 SX3TMP->X3_DECIMAL	  , ;	// 05 - Decimal
						 SX3TMP->X3_Valid  	  , ;	// 06 - Valid
						 SX3TMP->X3_USADO  	  , ;	// 07 - Usado
						 SX3TMP->X3_TIPO   	  , ;	// 08 - Tipo
						 SX3TMP->X3_F3		  , ;	// 09 - F3
						 SX3TMP->X3_CONTEXT   , ;	// 10 - Contexto
						 SX3TMP->X3_CBOX	  , ;	// 11 - ComboBox
						 SX3TMP->X3_RELACAO    } )	// 12 - Relacao
	Endif
	SX3TMP->(dbSkip())
End

ADHeadRec(cAlias,aHeader)

RestArea(aArea)

Return(aHeader)
                   

/*/================================================================================================================================/*/
/*/{Protheus.doc} GCAbLine
Bloco de Código usado na Justificativa para o estorno, na rotina de Estorno do edital ate a Status HO (SICOMA20).

@type function
@author Alvaro Camillo Neto - TOTVS
@since 21/02/2008
@version P12.1.23

@param aData	, Array, Campos.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Bloco de Código, Bloco de Código para a Justificativa da Compra.
/*/
/*/================================================================================================================================/*/

Static Function GCAbLine( aData )

Local bMyLine
Local cLine	:= ""

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cLine := '{ Iif( aData[oLbx:nAt,1], oOk, oNo )'
aEval( aTitulo, { |x,y| cLine += ',aData[oLbx:nAt,' + LTrim( Str(y) ) + ']' }, 2 ); cLine += '}'

bMyLine := & ( '{|| ' + cLine + '}' )

Return( bMyLine )           


/*/================================================================================================================================/*/
/*/{Protheus.doc} ArrayMrkBrowse
Seta arrays de dados usados no mark browse, usado na Justificativa para o estorno, na rotina de Estorno do edital ate a Status HO (SICOMA20).

@type function
@author Alvaro Camillo Neto - TOTVS
@since 21/02/2008
@version P12.1.23

@param cEdital	, Caractere, Código do Edital.
@param cProcesso, Caractere, Código do Processo.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function ArrayMrkBrowse(cEdital, cProcesso)

Local aHeadCO3 	:= CriaHeader(Nil,"CO3_FILIAL/CO3_CODEDT/CO3_NUMPRO/CO3_CODPRO/CO3_VLUNIT//CO3_CLASS/CO3_XSTATU",Nil,"CO3")
Local nX, nIndexProd
Local aVetor := {}

aAdd( aTitulo, "" )           

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
For nX:= 1 To Len(aHeadCO3)
	If !("_WT" $ aHeadCO3[nX,2])
		aAdd( aTitulo, aHeadCO3[nX,1] )
		aAdd( aTam, GetTextWidth( 0, Replicate( ";", 5+Max( TamSX3( aHeadCO3[nX,2] )[1], Len( aHeadCO3[nX,1] ) ) ) ) )
	EndIf
Next

CO2->(dbSetOrder(1)) 										//CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO
CO2->(dbSeek(xFilial("CO2")+ (cEdital + cProcesso) ) )

While CO2->(!EOF()) .And. CO2->( CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO ) == xFilial("CO2")+ (cEdital + cProcesso)
      
    //--< MOSTRA SEMPRE DE TODOS OS FORNECS, PARA PERMITIR QUE USUARIO CONSIGA CANCELAR TODOS SE ASSIM DESEJAR >--
	//if CO2->CO2_ESTORN <> '1'								//Analizar apenas Itens que geraram pedido/contrato apos o ultimo estorno
	
		dbSelectArea("CO3")
		CO3->(dbSetOrder(1))
		CO3->(dbSeek(xFilial("CO3")+cEdital+cProcesso))
	
		While !CO3->(Eof()) .and. CO3->CO3_CODEDT == cEdital .and. CO3->CO3_NUMPRO == cProcesso
	
			If CO3->CO3_CODPRO == CO2->CO2_CODPRO .and. CO3->CO3_CLASS == '1' .and. CO3->CO3_XSTATUS <> '1' //como podem haver varios estornos, pegar apenas ganhadores "nao cancelados"
	
				aVetor:= {}
				
				aAdd( aVetor, .F. )
			
				For nX:= 1 To Len(aHeadCO3)-2
					aAdd( aVetor, CO3->( FieldGet(FieldPos(aHeadCO3[nX,2] ) ) ) )
				Next nX
				aVetor[5] := BuscaDescrPart()     
				           
				If CO3->CO3_TIPO == "1"  
					aVetor[2] := "Pré-Fornecedor"
				Else
					aVetor[2] := "Fornecedor"	
				EndIf
				
				nIndexProd := aScan(aDados, { |X| x[3] ==  CO3->(CO3_CODIGO) .and.  x[4] ==  CO3->(CO3_LOJA)  } )
	
				If nIndexProd == 0  //Impede Fornecedor duplicado no Grid
					aAdd( aDados , aVetor ) 
					nItemIndx := len(aDados[1]) //+ 1 //posição em que o PRODUTO fica registrado na array
				EndIf
		        
				aAdd( aVetor,CO3->CO3_CODPRO)
				aAdd( aDadosTodosProds , aVetor )		
			
			EndIf	

			dbSelectArea("CO3")
		   	CO3->(dbSkip())

		EndDo
	
	dbSelectArea("CO2")
   	CO2->(dbSkip())

EndDo
                

Return Nil


/*/================================================================================================================================/*/
/*/{Protheus.doc} LimpaIndicadorDeEstorno
Limpa flag que indica se um Item de Edital poderá ser ou não modificado após o Estorno, usado na rotina de Estorno do edital ate a Status HO (SICOMA20).

@type function
@author Alvaro Camillo Neto - TOTVS
@since 21/02/2008
@version P12.1.23

@param cEdital	, Caractere, Código do Edital.
@param cProcesso, Caractere, Código do Processo.
@param cEtapa	, Caractere, Código da Etapa.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function LimpaIndicadorDeEstorno(cEdital, cProcesso, cEtapa)

Local nIndexProd := 0                                                                 
Local nIndexFornec := 0
Local nIndiceAux := 0
//Private nFileHandle, cStr

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
/*
O array "aDadosTodosProds" pode conter vários produtos vinculados a um mesmo fornecedor ganhador
mas, apenas um destes registros esta marcado com .T. neste ponto do programa (como abaixo):

Fornec Ligado Produto  
0003   .T.    X
0003   .F.    Y
0003   .F.    Z
               
Portanto, apos a execução do comando FOR para "ligar todos produtos do Fornecedor" o array acima ficará assim:

Fornec Ligado Produto  
0003   .T.    X
0003   .T.    Y
0003   .T.    Z

Ou seja, agora todos os produtos serão analisados!              
*/                      

For nIndexFornec := 1 to  Len(aDados)//FOR para "ligar todos produtos do Fornecedor"
	For nIndiceAux := 1  to Len(aDadosTodosProds)
		If  aDadosTodosProds[nIndiceAux][3] == aDados[nIndexFornec][3] .and. ; //Fornec
	     	aDadosTodosProds[nIndiceAux][4] == aDados[nIndexFornec][4] .and. ; //Loja
	     	aDados[nIndexFornec][1] 		== .T.                                             
			aDadosTodosProds[nIndiceAux][1] := .T.	
		EndIf	
	Next
Next                                                    

nIndexFornec := 0                                        
	 
CO2->(dbSetOrder(1)) 										//CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO
CO2->(dbSeek(xFilial("CO2")+ (cEdital + cProcesso) ) )

 While CO2->(!EOF()) .And. CO2->( CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO ) == xFilial("CO2")+ (cEdital + cProcesso)
    
	RecLock("CO2",.F.)
                                                                                     
		CO2->(CO2_ESTORN) := "1"    
		CO2->(CO2_SLDEST) := 0
				  
		For nIndexProd := 1 to Len(aDadosTodosProds)        

			//if CO2->(CO2_CODPRO)  ==  aDadosTodosProds[nIndexProd][nItemIndx]//nItemIndx <==> Cód. do Produto  

			If CO2->(CO2_CODPRO)  ==  aDadosTodosProds[nIndexProd][10]//nItemIndx <==> Cód. do Produto	                                       
				nIndexFornec := aScan(aDados, { |X| x[3] ==  aDadosTodosProds[nIndexProd][3] .and. x[4] ==  aDadosTodosProds[nIndexProd][4] } )	    //confere se o fornecedor foi marcado para CANCELAR  

				If nIndexFornec > 0  .and. aDados[nIndexFornec][1] == .T.

					CO2->(CO2_ESTORN) := "2"                         

					If cEtapa == "PC"    
						CO2->(CO2_SLDEST) := SaldoPC(cEdital,cProcesso,aDados[nIndexFornec][3],aDados[nIndexFornec][4], CO2->(CO2_CODPRO))
						AtuHistCOI(cEdital,cProcesso,CO2->(CO2_CODPRO),.T.)
					Else                                  
						CO2->(CO2_SLDEST) := SaldoCO(cEdital,cProcesso,aDados[nIndexFornec][3],aDados[nIndexFornec][4], CO2->(CO2_CODPRO))
						AtuHistCOI(cEdital,cProcesso,CO2->(CO2_CODPRO),.F.)
					EndIf
					
				EndIf   
			EndIf
				
		Next nIndexProd
	
	CO2->(MsUnlock())
	
	CO2->(dbSkip())
EndDo                
	
Return()


/*/================================================================================================================================/*/
/*/{Protheus.doc} BuscaDescrPart
Funcao para montar consulta F3 customizada de busca de pre-fornecedor ou fornecedor, usado na rotina de Estorno do edital ate a Status HO (SICOMA20).

@type function
@author Alvaro Camillo Neto - TOTVS
@since 01/04/2010
@version P12.1.23

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, Código do Forncedor.
/*/
/*/================================================================================================================================/*/

Static Function BuscaDescrPart()

Local cRet := "", cQuery := ""
                                              
//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Quando a Rotina e acionada pelo SIGAEIC atualiza grupo de perguntas SX1 >--
If CO3->CO3_TIPO == "1"
	If CO1->CO1_MODALI == "LL"
		Select("CO6")
		cQuery  = " SELECT CO6.CO6_NOME FROM " + RetSqlName('CO6') + " CO6 "
		cQuery += " WHERE CO6.CO6_CODIGO = '" + CO3->CO3_CODIGO + "'"
		cQuery += " AND " + RetSQLCond("CO6")
		cQuery += " AND CO6.CO6_TIPO = 'C' "                      
		
		cQuery 	:= ChangeQuery(cQuery)     
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB_CO6",.T.,.T.)
		dbSelectArea("TRB_CO6") 

		If  (TRB_CO6->(!Eof()))
			cRet := TRB_CO6->(CO6_CODIGO)
		EndIf
		
		TRB_CO6->(dbCloseArea())	            

	Else	
		Select("CO6")
		cQuery  = " SELECT CO6.CO6_NOME FROM " + RetSqlName('CO6') + " CO6 "
		cQuery += " WHERE CO6.CO6_CODIGO = '" + CO3->CO3_CODIGO + "'"
		cQuery += " AND " + RetSQLCond("CO6")
		cQuery += " AND CO6.CO6_TIPO = 'F' "                      
		
		cQuery 	:= ChangeQuery(cQuery)     
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB_CO6",.T.,.T.)
		dbSelectArea("TRB_CO6") 

		If  (TRB_CO6->(!Eof()))
			cRet := TRB_CO6->(CO6_CODIGO)
		EndIf
		
		TRB_CO6->(dbCloseArea())
		
	Endif
Else           
	If CO1->CO1_MODALI == "LL"
		Select("SA1")
		cQuery  = " SELECT SA1.A1_NOME FROM " + RetSqlName('SA1') + " SA1 "
		cQuery += " WHERE SA1.A1_COD = '" + CO3->CO3_CODIGO + "'"
		cQuery += " AND " + RetSQLCond("SA1")
		
		cQuery 	:= ChangeQuery(cQuery)     
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB_SA1",.T.,.T.)
		dbSelectArea("TRB_SA1") 

		If  (TRB_SA1->(!Eof()))
			cRet := TRB_SA1->(A1_NOME)
		EndIf
		
		TRB_SA1->(dbCloseArea())
		
	Else                   
		Select("SA2")
		cQuery  = " SELECT SA2.A2_NOME FROM " + RetSqlName('SA2') + " SA2 "
		cQuery += " WHERE SA2.A2_COD = '" + CO3->CO3_CODIGO + "'"
		cQuery += " AND " + RetSQLCond("SA2")
		
		cQuery 	:= ChangeQuery(cQuery)     
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB_SA2",.T.,.T.)
		dbSelectArea("TRB_SA2") 

		If  (TRB_SA2->(!Eof()))
			cRet := TRB_SA2->(A2_NOME) 
		EndIf
		
		TRB_SA2->(dbCloseArea())
	Endif	
Endif	

Return(cRet) 


/*/================================================================================================================================/*/
/*/{Protheus.doc} SaldoCO
Retorna o Saldo da Conta Orçamentária, usado na rotina de Estorno do edital ate a Status HO (SICOMA20).

@type function
@author Oswaldo Leite - TOTVS
@since 15/01/2012
@version P12.1.23

@param cEdital	, Caractere, Código do Edital.
@param cProcesso, Caractere, Código do Processo.
@param cFornec	, Caractere, Código do Fornecedor.
@param cLoja	, Caractere, Código da Loja do Forncedor.
@param cProd	, Caractere, Código do Produto.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Numérico, Saldo da Conta Orçamentária.
/*/
/*/================================================================================================================================/*/

Static Function SaldoCO(cEdital,cProcesso,cFornec, cLoja, cProd)

Local cQuery 	:= ""
Local cAliasTmp	:= "ALCN9TMP"
Local cAlTmp	:= "TRBCNC"
Local cAlTRB	:= "TRBCNB"
Local aArea 	:= GetArea()  
Local nSaldo 	:= 0

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cQuery := " SELECT CNC.* "                                                                  
cQuery += " FROM " + RetSqlTab("CNC") + " "
cQuery += " WHERE CNC.CNC_CODED = '" +cEdital + "' "
cQuery += " AND CNC.CNC_NUMPR = '" + cProcesso + "' "
cQuery += " AND CNC.CNC_CODIGO = '" + cFornec + "' "
cQuery += " AND CNC.CNC_LOJA = '" + cLoja + "' "
cQuery += " AND CNC.D_E_L_E_T_ = ' ' "                                     
cQuery += LstFiliais(cEdital, cProcesso, xFilial("CNC"), " CNC.CNC_FILIAL ")
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlTmp)

If (cAlTmp)->(Eof())
	(cAlTmp)->(DbCloseArea())
Else

	cQuery := " SELECT CN9.* "
	cQuery += " FROM " + RetSqlTab("CN9") + " "
	cQuery += " WHERE CN9.CN9_CODED = '" +cEdital + "' "                      
	cQuery += " AND CN9.CN9_NUMPR = '" + cProcesso + "' "
	cQuery += " AND CN9.CN9_NUMERO = '" + (cAlTmp)->(CNC_NUMERO) + "' "
	cQuery += " AND CN9.D_E_L_E_T_ = ' ' "              
	cQuery += LstFiliais(cEdital, cProcesso, xFilial("CN9"), " CN9.CN9_FILIAL ")                  
	
	(cAlTmp)->(DbCloseArea())
                                                          
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)
		
	//  ATENCAO!  	 NO PEDIDO DE COMPRA GERADO A PARTIR DE CONTRATO (CNTA120) NAO EXISTE O CODIGO DO EDITAL GRAVADO NO SC7, 
	//  POR ISTO FOI PRECISO	FAZER TODO  O  LOOP  ABAIXO:

	While !(cAliasTmp)->(Eof())
									 
			//Contrato Cancelado: se o contrato estiver cancelado, o processo de estorno poderá seguir
			If (cAliasTmp)->CN9_SITUAC $ '01'//05
			
				cQuery := " SELECT CNB.* "
				cQuery += "  FROM " + RetSqlTab("CNB") + " "
				cQuery += " WHERE CNB.CNB_FILIAL = '" + (cAliasTmp)->CN9_FILIAL + "'"
				cQuery += "   AND CNB.CNB_CONTRA = '" + (cAliasTmp)->CN9_NUMERO + "'"  
				cQuery += "   AND CNB.CNB_REVISA = '" + (cAliasTmp)->CN9_REVISA + "'"
				cQuery += "   AND CNB.CNB_PRODUT = '" + cProd + "'"
				cQuery += "   AND CNB.D_E_L_E_T_ <> '*'"
		
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlTRB)

				If !(cAlTRB)->(Eof())	   
					if	(cAlTRB)->CNB_QUANT >=	(cAlTRB)->CNB_QTDMED		
						nSaldo := nSaldo +  ( (cAlTRB)->CNB_QUANT - (cAlTRB)->CNB_QTDMED )   //ao usar: (cAlTRB)->CNB_SLDMED                     
					EndIf
				EndIf        
														   
				(cAlTRB)->(DbCloseArea())
				
			EndIf			
			
			(cAliasTmp)->(dbSkip())
	EndDo
EndIf

If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
EndIf

RestArea(aArea)

Return(nSaldo)


/*/================================================================================================================================/*/
/*/{Protheus.doc} SaldoPC
Retorna o Saldo do Pedido de Compra, usado na rotina de Estorno do edital ate a Status HO (SICOMA20).

@type function
@author Oswaldo Leite - TOTVS
@since 15/01/2012
@version P12.1.23

@param cEdital	, Caractere, Código do Edital.
@param cProcesso, Caractere, Código do Processo.
@param cFornec	, Caractere, Código do Fornecedor.
@param cLoja	, Caractere, Código da Loja do Forncedor.
@param cProd	, Caractere, Código do Produto.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Numérico, Saldo do Pedido de Compra.
/*/
/*/================================================================================================================================/*/

Static Function SaldoPC(cEdital,cProcesso,cFornec, cLoja, cProd)

Local cQuery 	:= ""
Local cAliasTmp	:= "ALLSC7TMP" 
Local nSaldo	:= 0
Local aArea := GetArea()

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cQuery := " select SC7.* "
cQuery += " from " + RetSqlTab("SC7") + " "
cQuery += " where SC7.C7_CODED = '"   + cEdital + "' "
cQuery += "   and SC7.C7_NUMPR = '"   + cProcesso + "' "                  
cQuery += "   and SC7.C7_PRODUTO = '" + cProd + "' "                                            
cQuery += "   and SC7.C7_FORNECE = '" + cFornec + "' "                     
cQuery += "   and SC7.C7_LOJA = '"    + cLoja + "' " 
cQuery += "   and SC7.D_E_L_E_T_ = ' ' "
cQuery += LstFiliais(cEdital, cProcesso, xFilial("SC7"), " SC7.C7_FILIAL ")                  
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)
	
While !(cAliasTmp)->(Eof())
	If (cAliasTmp)->C7_QUANT > (cAliasTmp)->C7_QUJE
		nSaldo := nSaldo + (cAliasTmp)->C7_QUANT - (cAliasTmp)->C7_QUJE
	EndIf
        
	(cAliasTmp)->(dbSkip())
End

(cAliasTmp)->(DbCloseArea())

RestArea(aArea)

Return(nSaldo)         


/*/================================================================================================================================/*/
/*/{Protheus.doc} LstFiliais
Lista de filiais de origem envolvidas no edital, usado na rotina de Estorno do edital ate a Status HO (SICOMA20).

@type function
@author Oswaldo Leite - TOTVS
@since 15/01/2012
@version P12.1.23

@param cPar1		, Caractere, Parâmetro 1.
@param cPar2		, Caractere, Parâmetro 2.
@param cFil			, Caractere, Filtro.
@param cFiltroSql	, Caractere, String com expressão do Filtro.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Caractere, String com expressão do Filtro em SQL.
/*/
/*/================================================================================================================================/*/


Static Function LstFiliais(cPar1, cPar2, cFil, cFiltroSql)
                              
Local cQuery
Local cAlias := "LSTFIL"     
Local aArea	 := GetArea()                                
Local cRet   := " AND ( " + cFiltroSql + " = '" + cFil + "'"	

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
cQuery := " SELECT SC1.* FROM " + RetSqlName('SC1')  + " SC1 "
cQuery += " WHERE SC1.C1_CODED = '" + cPar1  
cQuery += "' AND SC1.C1_NUMPR = '"  + cPar2  
cQuery += "' AND " + RetSQLCond("SC1")

cQuery 	:= ChangeQuery(cQuery)     

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

While !(cAlias)->(Eof() .And. (cAlias)->(C1_CODED) == cPar1  .And. (cAlias)->(C1_NUMPR) == cPar2)
	cRet  += ( " OR " + cFiltroSql + " = '" + (cAlias)->(C1_FILENT) + "' " )
	(cAlias)->(DbSkip())
End                  

cRet  += ") "

(cAlias)->(DbCloseArea())

RestArea(aArea)                 

Return cRet


/*/================================================================================================================================/*/
/*/{Protheus.doc} AtuHistCOI
Limpa e atualiza historico da solicitacao de compra (COI), usado na rotina de Estorno do edital ate a Status HO (SICOMA20).

@type function
@author FSW - TOTVS
@since 06/09/2012
@version P12.1.23

@param cEdital	 , Caractere, Código do Edital.
@param cProcesso , Caractere, Código do Processo.
@param cProd	 , Caractere, Código do Produto.
@param lGerPedido, Lógico	, Gera Pedido de Compra.

@obs Projeto ELO

@history 07/03/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Nil, Função sem retorno.
/*/
/*/================================================================================================================================/*/
  
Static Function AtuHistCOI(cEdital, cProcesso, cProd, lGerPedido)

Local cQuery   := ''
Local aArea		:= GetArea()    
Local cAliasNw := 'TRB_SC'                   
Local cTpCto   := GETMV("MV_TPSCCT")  // FSW - TIPO DE SC ADITIVO CONTRATO	

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Caso seja gerado um pedido, realizo o estorno do edital conforme >--
//--< as SCs informadas no Pedido                                      >--
If  lGerPedido
	cQuery := " select SC7.R_E_C_N_O_ AS RECNO "
	cQuery += " from " + RetSqlTab("SC7")
	cQuery += " where SC7.C7_CODED   = '" + cEdital   + "' "
	cQuery += "   and SC7.C7_NUMPR   = '" + cProcesso + "' "
	cQuery += "   and SC7.C7_PRODUTO = '" + cProd     + "' "
Else			         
	cQuery := " select SC1.* FROM " + RetSqlTab("SC1") 
	cQuery += " where SC1.C1_CODED   = '" + cEdital   + "' "
	cQuery += "   and SC1.C1_NUMPR   = '" + cProcesso + "' "
	cQuery += "   and SC1.C1_PRODUTO = '" + cProd     + "' "
	cQuery += "   and SC1.C1_XTIPOSC <> '"+ cTpCto    + "' and SC1.D_E_L_E_T_ <> '*'  " // FSW - TIPO DE SC ADITIVO CONTRATO
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNw,.F.,.T.) 

dbSelectArea("SC7")              
					                 
while !(cAliasNw)->(Eof())

	If lGerPedido					  
		SC7->( dbGoTo( (cAliasNw)->RECNO ) )				// Realizo o Rastreio
		RSTSCLOG("PED",2,/*cUser*/,SC7->( C7_NUM+C7_ITEM ) )
	Else                                                       
		COMA080((cAliasNw)->C1_NUM,(cAliasNw)->C1_ITEM,"COI",{},"COI_DTHCTR","COI_UCTR",.T.,/*cUser*/,"COI_DOCCTR") //estorna inclusão de contrato
	EndIf
   /*
	Somente a operação de CANCELAR deve limpar o numero do edital na tabela COI!	
	COMA080((cAliasNw)->C1_NUM,(cAliasNw)->C1_ITEM,"COI_DTHEDT","COI_UEDT",.T.,,"COI_DOCEDT") 
	*/
	(cAliasNw)->(dbSkip())
End                 

SC7->(dbCloseArea())
(cAliasNw)->( dbCloseArea() )  

RestArea(aArea)    

Return
