#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} COMA120
Validacao dos pedidos de compra na pre-nota

@type function
@author Bruna Paola
@since 07/06/2011
@version P12.1.23

@param aF4For, Array, Informações para pesquisa do Pedido.
@param lNfMedic, Lógico, Se verdadeiro busca Núm.Pedido na 6a posição do array aF4For, caso contrário na 3a.
@param lUsaFiscal, Lógico, Se falso identifica que é uma Pré-Nota.

@obs Projeto ELO

@history 20/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return ExpL, retorno lógico True.
/*/
/*/================================================================================================================================/*/

User Function COMA120(aF4For,lNfMedic,lUsaFiscal) 

Local lAtesto   := GETMV("MV_XATESTO")
Local nx        := 0  
Local cSeek     := ""  
Local cSolic    := "" 
Local cRequi    := ""
Local cxVer     := ""                                                    
Local lProb		:= .F.  

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >----------------------------- 
If (lAtesto == .T. .And. lUsaFiscal == .F.)					//A rotina so sera executada quando for pre-nota

	For nx	:= 1 to Len(aF4For)
		If aF4For[nx][1]
		
			If (lProb == .T.)
				Exit
			EndIf
		
			DbSelectArea("SC7")
			SC7->(DbSetOrder(14))							//FILIAL+PEDIDO
			SC7->(DbGoTop())
			
			cSeek := xFilEnt(xFilial("SC7")) + If( lNfMedic, aF4For[nx,6], aF4For[nx][3] ) 
			SC7->(dbSeek(cSeek))
			
			Do While SC7->( !Eof() .And. (SC7->C7_FILENT+SC7->C7_NUM == cSeek) )
			
			
			   	If (AllTrim(SC7->C7_NUMSC) == '') 			// Nao tem amarracao com solicitacao de compras
					MsgAlert("Existe pedido sem amarracao com solicitacao.","ATENCAO") 
					lProb := .T.
					Exit
				Else
					DbSelectArea("SC1")
					SC1->(DbSetOrder(1))					//C1_FILIAL+C1_NUM
					SC1->(DbGoTop())
					
					cSolic := xFilEnt(xFilial("SC1")) + SC7->C7_NUMSC
					SC1->(dbSeek(cSolic))
					             
					cxVer := SC1->C1_XSOL 					// Requisitante da Solicitacao

					If (cRequi == '') 						// Primeira vez que entrar, guarda o requisitante
	
				   		If (AllTrim(SC1->C1_XSOL) == '')
				   			MsgAlert("Existe solicitacao sem requisitante.","ATENCAO")  
					   		lProb := .T.
					   		Exit
				   		EndIf 
				   		
				   		cRequi := SC1->C1_XSOL
				   		
				 	ElseIf (cRequi <> cxVer)
				 	
				 		If (AllTrim(cxVer) == '')
				   			MsgAlert("Existe solicitacao sem requisitante.","ATENCAO")
				   		Else 
				 			MsgAlert("Existe solicitacao de requisitante diferente.","ATENCAO")
				 		EndIf
				 		  
						lProb := .T.
						Exit	 
				 	EndIf				
				EndIf 
			   
				DbSelectArea("SC7")    
				SC7->(dbSkip())
			EndDo
			
		EndIf
	Next
	
	If (lProb == .T.) 
		aF4For := {}
		Return .F. 
	EndIf

EndIf

Return .T.       


/*/================================================================================================================================/*/
/*/{Protheus.doc} COM120VL
Validacao do Acols da pre-nota

@type function
@author Bruna Paola
@since 09/06/2011
@version P12.1.23

@param cRequi, Caractere, Informações para pesquisa do Pedido.

@obs Desenvolvimento FIEG

@history 18/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return ExpL, retorno lógico False.
/*/
/*/================================================================================================================================/*/

User Function COM120VL(cRequi)

Local cSeek := ""
Local cSolic    := "" 
Local nx := 1 
Local lxProc := .F. 

//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If (len(aCols) > 1)

	DbSelectArea("SC7")
	SC7->(DbSetOrder(14))									//FILIAL+PEDIDO+ITEM
	SC7->(DbGoTop())
	
	For nx:= 1 to (len(aCols)-1)
															
		If (!GDDELETED(nx) .And. lxProc == .F.) 			//Procura o primeiro item que n?o esteja deletado 
			lxProc := .T.
			
			cSeek := xFilEnt(xFilial("SC7")) + (aCols[nx][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_PEDIDO'})] + aCols[nx][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_ITEMPC'})]) 
			SC7->(dbSeek(cSeek))
	 
			
			//--< Verifica a amarracao com pedido >---------
			If (Empty(aCols[nx][aScan(aHeader,{|x| AllTrim(x[2]) == 'D1_PEDIDO'})]))
				MsgAlert("Existe Item sem amarracao com pedido.","ATENCAO")
				Return .T.
			EndIf
	
			DbSelectArea("SC1")
			SC1->(DbSetOrder(1))							//C1_FILIAL+C1_NUM
			SC1->(DbGoTop())
			
			cSolic := xFilEnt(xFilial("SC1")) + SC7->C7_NUMSC
			SC1->(dbSeek(cSolic))
			   
			//--< Se requisitante da solicitacao do pedido for diferente do que ja existe no aCols, nao permite a inclusao >--
			If (cRequi <> SC1->C1_XSOL)
				MsgAlert("Existe solicitacao de requisitante diferente.","ATENCAO")
				Return .T.
			EndIf 
		EndIf
		 
	Next
EndIf
	
Return .F.   

/*/================================================================================================================================/*/
/*/{Protheus.doc} CM120GR
Validacao do Acols da pre-nota

@type function
@author Bruna Paola
@since 09/06/2011
@version P12.1.23

@param nOpcA, Numérico, Opção.

@obs Desenvolvimento FIEG

@history 18/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return ExpL, retorno lógico True.
/*/
/*/================================================================================================================================/*/

User Function CM120GR (nOpcA) 

Local nx := 1
Local cSeek := "" 
Local lAtesto   := GETMV("MV_XATESTO")
Local cSolic    := "" 
                                        
//--< Log das Personalizações >-----------------------------
U_LogCustom()

//--< Processamento da Rotina >-----------------------------
If (lAtesto == .T.)

	For nx := 1 To (Len(aCols))
	
		If (!GDDELETED(nx)) 								//Procura o primeiro item que n?o esteja deletado  
	
			DbSelectArea("SC7")
			SC7->(DbSetOrder(14))							//FILIAL+PEDIDO+ITEM
			SC7->(DbGoTop())
			
			cSeek := xFilEnt(xFilial("SC7")) + (aCols[nx][19])+ (aCols[nx][20]) 
			SC7->(dbSeek(cSeek))
			
			//Verifica a amarracao com pedido
			If (Empty(aCols[nx][19]))
				MsgAlert("A pre-nota nao foi salva. Existe Item sem amarracao com pedido.","ATENCAO")
				nOpcA := 0
				Exit
			EndIf
			
			If (AllTrim(SC7->C7_NUMSC) == '') 				// Nao tem amarracao com solicitacao de compras
				MsgAlert("A pre-nota nao foi salva. Existe Item sem amarracao com solicitacao.","ATENCAO") 	 
				nOpcA := 0
				Exit 
			EndIf
			
			DbSelectArea("SC1")
			SC1->(DbSetOrder(1))							//C1_FILIAL+C1_NUM
			SC1->(DbGoTop())
				
			cSolic := xFilEnt(xFilial("SC1")) + SC7->C7_NUMSC
			SC1->(dbSeek(cSolic))
				   
			If U_COM120VL(C1_XSOL)
				nOpcA := 0
				Exit 
			EndIf
		EndIf	
	Next
EndIf

Return .T.
