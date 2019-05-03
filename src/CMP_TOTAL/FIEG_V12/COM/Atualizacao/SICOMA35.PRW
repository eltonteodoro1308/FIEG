#Include "Protheus.Ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CNIA109v
Validacao para quando o usuario digitar o contrato no campo contrato de preco da getDados.

@type function
@author Tiago Tudisco
@since 17/06/2011
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para validação do campo contrato.

/*/
/*/================================================================================================================================/*/

User Function CNIA109v()

	Local lRet	:= .T.
	Local nPosPrd	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRODUTO'})	//posicao do produto na getDados
	Local nPosCtr	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XCONTPR'})	//posicao do Contrato Registro de Preco na getDados
	Local nPosQtd	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_QUANT'})
	Local nPosFil  	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XCONTFI'})
	Local nPosRevis	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XCONTRV'})
	Local aArea		:= getArea()
	Local cTMP  	:= GetNextAlias()
	Local cHoje		:= Date()
	Local nQuant	:= aCols[n][nPosQtd]
	Local cQuery    := ""

	// inserido por Carlos Queiroz em 22/01/2013
	Local aItens    := {}
	Local nPosPrc   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_VUNIT'})
	Local nPosPl	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XCONTPL'})
	Local nPosIt	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XCONTIT'})
	Local nPosFor	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_FORNECE'})
	Local nPosLoj	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_LOJA'})


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	Do	While .T.

		If !Empty(aCols[n][nPosPrd]) .And. !Empty(aCols[n][nPosQtd])

			If ExistBlock("CN109QV")
				cQuery := ExecBlock("CN109QV",.F.,.F.,{aCols[n][nPosPrd],cHoje,nQuant})
			EndIf

			If (Empty(cQuery))
				cQuery := " ORDER BY CN9.CN9_NUMERO "
				cQuery := '%' + cQuery + '%'
			EndIf

			BeginSQL Alias cTMP

				//%NoParser%
				SELECT CNB.CNB_SLDMED, CN9.CN9_NUMERO, CNA.CNA_FORNEC, CNB.CNB_VLUNIT, CNA.CNA_SALDO, CN9.CN9_FILIAL, CN9.CN9_REVISA, CNA.CNA_NUMERO, CNB.CNB_ITEM, CN9.CN9_DESCRI, CNA.CNA_LJFORN
				FROM	%Table:CNB% CNB, %Table:CN9% CN9, %Table:CNA% CNA, %Table:CN1% CN1
				WHERE	CN9.CN9_FILIAL  =   %xFilial:CN9%  				AND
				CNB.CNB_FILIAL  =   %xFilial:CNB% 		   		AND
				CNA.CNA_FILIAL  =   %xFilial:CNA% 				AND
				CNB.CNB_CONTRA	=	CN9.CN9_NUMERO				AND
				CNB.CNB_REVISA	=	CN9.CN9_REVISA				AND
				CNB.CNB_CONTRA	=	CNA.CNA_CONTRA				AND
				CNB.CNB_REVISA	=	CNA.CNA_REVISA				AND
				CNB.CNB_NUMERO	=	CNA.CNA_NUMERO				AND
				CN9.CN9_TPCTO	=	CN1.CN1_CODIGO				AND
				CN1.CN1_MEDEVE	=	'1'							AND
				CN1.CN1_ESPCTR	=	'1'							AND
				CNB.CNB_PRODUT	=	%Exp:aCols[n][nPosPrd]%		AND
				CN9.CN9_DTFIM	>=	%Exp:cHoje%					AND
				CN9.CN9_SITUAC	=	'05'						AND
				CN9.CN9_XREGP	=	'1'							AND
				CN9.CN9_NUMERO	=	%Exp:M->C1_XCONTPR%			AND
				CNB.CNB_VLUNIT * %Exp:nQuant% <= CNA.CNA_SALDO	AND
				CNB.CNB_SLDMED  >   '0'                         AND
				CNB.%NotDel%									AND
				CNA.%NotDel%									AND
				CN9.%NotDel%

				//Query do ponto de entrada
				%exp:cQuery%


			EndSQL

			If(cTMP)->(EOF())

				MsgAlert("Contrato não encontrado ou com saldo zerado para este produto.")
				VAR_IXB := CriaVar("C1_XCONTPR",.F.)
				aCols[n][nPosFil]	:= Space(7)
				aCols[n][nPosRevis]	:= Space(3)

				// inserido por Carlos Queiroz em 22/01/2013
				aCols[n][nPosPl]	:= Space(TamSX3("CNA_NUMERO")[1]) //aItens[nRet][7]//atribui a Planilha ao campo do aCols
				aCols[n][nPosIt]	:= Space(TamSX3("CNB_ITEM")[1])//aItens[nRet][8]//atribui a Item Planilha ao campo do aCols
				aCols[n][nPosFor]	:= Space(TamSX3("CNA_FORNEC")[1])//aItens[nRet][4]//ATRIBUI O FORNECEDOR
				aCols[n][nPosLoj]	:= Space(TamSX3("CNA_LJFORN")[1])//aItens[nRet][10]//ATRIBUI A LOJA DO FORNECEDOR

				lRet := .F.
				Exit

			Else
				If ((cTMP)->CNB_SLDMED - aCols[n][nPosQtd]) >= 0
					AADD(aItens,{(cTMP)->CN9_FILIAL,(cTMP)->CN9_NUMERO,(cTMP)->CN9_REVISA,(cTMP)->CNA_FORNEC,(cTMP)->CNB_VLUNIT,;
					(cTMP)->CNB_SLDMED,(cTMP)->CNA_NUMERO,(cTMP)->CNB_ITEM,(cTMP)->CN9_DESCRI,(cTMP)->CNA_LJFORN})

					aCols[n][nPosPrc]	:= aItens[1][5]//atribui o valor ao item no aCols
					aCols[n][nPosFil]	:= aItens[1][1]//atribui a filial ao campo do aCols
					aCols[n][nPosRevis]	:= aItens[1][3]//atribui a revisao ao campo do aCols
					aCols[n][nPosPl]	:= aItens[1][7]//atribui a Planilha ao campo do aCols
					aCols[n][nPosIt]	:= aItens[1][8]//atribui a Item Planilha ao campo do aCols
					aCols[n][nPosFor]	:= aItens[1][4]//ATRIBUI O FORNECEDOR
					aCols[n][nPosLoj]	:= aItens[1][10]//ATRIBUI A LOJA DO FORNECEDOR
				EndIf
				If Len(aItens) == 0
					MsgAlert("Nenhum Contrato Encontrado.")
					aCols[n][nPosFil]	:= Space(7)
					aCols[n][nPosRevis]	:= Space(3)
					aCols[n][nPosPl]	:= Space(6)
					aCols[n][nPosIt]	:= Space(3)
					lRet := .F.
					Exit
				EndIf

			EndIf

		Else

			MsgAlert("Preencha os campos: "+AllTrim(RetTitle("C1_PRODUTO"))+" e "+AllTrim(RetTitle("C1_QUANT")))
			lRet := .F.

		EndIf

		Exit
	EndDo

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} CNIA109c
Consulta especifica para mostrar os contratos vigentes e com saldo para um dado produto.

@type function
@author Tiago Tudisco
@since 14/06/2011
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function CNIA109c()

	Local cTitulo	:= "Consulta Contratos Vigentes"					//Titulo da consulta
	Local aArea		:= getArea()
	Local aCampos	:= {"Filial","Contrato","Revisão","Fornecedor","Valor Unit.","Saldo","Planilha","Item Planilha","Descrição"} 	//Colunas da consulta
	Local aItens	:= {}  												//Itens da consulta
	Local nRet		:= 0                               					//Linha selecionada da lista

	Local cTMP  	:= GetNextAlias()
	Local cHoje		:= Date()

	Local nPosPrd	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRODUTO'})
	Local nPosQtd	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_QUANT'})
	Local nPosPrc   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_VUNIT'})
	Local nPosFil  	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XCONTFI'})
	Local nPosRevis	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XCONTRV'})
	Local nPosPl	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XCONTPL'})
	Local nPosIt	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XCONTIT'})
	Local nPosFor	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_FORNECE'})
	Local nPosLoj	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_LOJA'})

	Local cQuery    := ""


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//Verifica se a linha referente ao produto e a quantidade estao preenchidas na getdados
	If !Empty(aCols[n][nPosPrd]) .And. !Empty(aCols[n][nPosQtd])

		If ExistBlock("CN109QC")
			cQuery := ExecBlock("CN109QC",.F.,.F.,{aCols[n][nPosPrd],cHoje})
		EndIf

		If (Empty(cQuery))
			cQuery := " ORDER BY CN9.CN9_NUMERO "
			cQuery := '%' + cQuery + '%'
		EndIf

		BeginSQL Alias cTMP
			SELECT CN9.CN9_FILIAL, CN9.CN9_NUMERO, CN9.CN9_REVISA, CN9.CN9_DESCRI, CNA.CNA_FORNEC, CNA.CNA_LJFORN, CNB.CNB_VLUNIT, CNB.CNB_SLDREC, CNA.CNA_NUMERO, CNB.CNB_ITEM, CNB.CNB_SLDMED
			FROM	%Table:CNB% CNB, %Table:CN9% CN9, %Table:CNA% CNA, %Table:CN1% CN1
			WHERE	CN9.CN9_FILIAL  =   %xFilial:CN9%  			AND
			CNB.CNB_FILIAL  =   %xFilial:CNB% 			AND
			CNA.CNA_FILIAL  =   %xFilial:CNA% 			AND
			CN1.CN1_FILIAL  =   %xFilial:CN1% 			AND
			CNB.CNB_CONTRA	=	CN9.CN9_NUMERO			AND
			CNB.CNB_REVISA	=	CN9.CN9_REVISA			AND
			CNB.CNB_CONTRA	=	CNA.CNA_CONTRA			AND
			CNB.CNB_REVISA	=	CNA.CNA_REVISA			AND
			CNB.CNB_NUMERO	=	CNA.CNA_NUMERO			AND
			CN9.CN9_TPCTO	=	CN1.CN1_CODIGO			AND
			CN1.CN1_MEDEVE	=	'1'						AND
			CN1.CN1_ESPCTR	=	'1'						AND
			CNB.CNB_PRODUT	=	%Exp:aCols[n][nPosPrd]%	AND
			CN9.CN9_DTFIM	>=	%Exp:cHoje%				AND
			CN9.CN9_SITUAC	=	'05'					AND
			CN9.CN9_XREGP	=	'1'						AND
			CNB.CNB_SLDMED  >   '0'                     AND
			CNB.%NotDel%								AND
			CNA.%NotDel%								AND
			CN9.%NotDel%

			//Query do ponto de entrada
			%exp:cQuery%


		EndSQL

		While (cTMP)->(!EOF())

			If ((cTMP)->CNB_SLDREC - aCols[n][nPosQtd]) >= 0

				AADD(aItens,{(cTMP)->CN9_FILIAL,(cTMP)->CN9_NUMERO,(cTMP)->CN9_REVISA,(cTMP)->CNA_FORNEC,(cTMP)->CNB_VLUNIT,;
				(cTMP)->CNB_SLDMED,(cTMP)->CNA_NUMERO,(cTMP)->CNB_ITEM,(cTMP)->CN9_DESCRI,(cTMP)->CNA_LJFORN})

			EndIf

			(cTMP)->(dbSkip())

		EndDo

		If Len(aItens) > 0

			//Funcao que cria uma tela para exibicao da consulta
			nRet := TmsF3Array(aCampos,aItens,cTitulo,.T.,,aCampos)

			If nRet > 0//nRet e o numero da linha selecionada na consulta

				VAR_IXB				:= aItens[nRet][2]//VAR_IXB e o campo que sera retornado na consulta especifica
				aCols[n][nPosPrc]	:= aItens[nRet][5]//atribui o valor ao item no aCols
				aCols[n][nPosFil]	:= aItens[nRet][1]//atribui a filial ao campo do aCols
				aCols[n][nPosRevis]	:= aItens[nRet][3]//atribui a revisao ao campo do aCols
				aCols[n][nPosPl]	:= aItens[nRet][7]//atribui a Planilha ao campo do aCols
				aCols[n][nPosIt]	:= aItens[nRet][8]//atribui a Item Planilha ao campo do aCols
				aCols[n][nPosFor]	:= aItens[nRet][4]//ATRIBUI O FORNECEDOR
				aCols[n][nPosLoj]	:= aItens[nRet][10]//ATRIBUI A LOJA DO FORNECEDOR

			Else
				VAR_IXB := CriaVar("C1_XCONTPR",.F.)
				aCols[n][nPosFil]	:= Space(7)//atribui a filial ao campo do aCols
				aCols[n][nPosRevis]	:= Space(3)//atribui a revisao ao campo do aCols
				aCols[n][nPosPl]	:= Space(6)//atribui a Planilha ao campo do aCols
				aCols[n][nPosIt]	:= Space(3)//atribui a Item Planilha ao campo do aCols

			EndIf

		Else

			MsgAlert("Nenhum Contrato Encontrado.")
			VAR_IXB := CriaVar("C1_XCONTPR",.F.)
			aCols[n][nPosFil]	:= Space(7)
			aCols[n][nPosRevis]	:= Space(3)
			aCols[n][nPosPl]	:= Space(6)
			aCols[n][nPosIt]	:= Space(3)

		EndIf

		(cTMP)->(dbCloseArea())//Fecha a tabela temporaria

	Else

		MsgAlert("Preencha os campos: "+AllTrim(RetTitle("C1_PRODUTO"))+" e "+AllTrim(RetTitle("C1_QUANT")))

	EndIf


	restArea(aArea)

Return .T.

/*/================================================================================================================================/*/
/*/{Protheus.doc} CNIA109m
Gera a medicao automatica.

@type function
@author Tiago Tudisco
@since 20/06/2011
@version P12.1.23

@param cA120Num, Caractere, Número do pedido de compra.
@param l120Inclui, Lógico, Indica que é Inclusão.
@param l120Altera, Lógico, Indica que é Alteração.
@param l120Deleta, Lógico, Indica que é Deleção.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para a medição incluída com sucesso.

/*/
/*/================================================================================================================================/*/

User Function CNIA109m(cA120Num,l120Inclui,l120Altera,l120Deleta)
	Local lRet			:= .T.
	Local aCtr 			:= {}	//-- Contratos

	Local aCabCN120  	:= {}
	Local aItemCN120 	:= {}

	Local nPosSC		:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_NUMSC' })	//posicao da SC na getDados
	Local nPosItem		:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEMSC'})	//posicao do item da SC na getDados
	Local nDesc  		:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_VLDESC'})	//valor de desconto para o item
	Local nProduto		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})
	Local nQuant		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_QUANT"})
	Local nPreco  		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRECO"})
	Local nDtEnt  		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_DATPRF"})
	Local nContra  		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CONTRA"})
	Local nRevisa  		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CONTREV"})
	Local nPlanil  		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PLANILH"})


	Local cCompet		:= subs(dtos(date()),5,2)+"/"+subs(dtos(date()),1,4)	//Mes/Ano (mm/aaaa)
	Local cPlan			:= 0
	Local cNumMed															//numero da medicao
	Local nPos			:= 1
	Local nPosIt
	Local nItem			:= 1  //controla os itens da medicao para cada contrato
	Local lAchou		:= .F.
	Local cCtr
	Local cRevisa
	Local cFilCtr
	Local cPlaCtr
	Local cItem, cNum
	Local nRet
	Local aItemMed		:= {}
	Local nI
	Local aArea			:= getArea()
	Local cChave    := ""
	Local aAreaSC1
	Local cItemCNE     := "001"
	Local lProd := .F.

	Private cFilOri := ""
	Private cFilCn9 := ""


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	dbSelectArea("CN9")
	dbSelectArea("CNB")
	dbSelectArea("CNA")
	restArea(aArea)

	SC1->(dbSetOrder(1))//C1_FILIAL+C1_NUM+C1_ITEM
	CN9->(dbSetOrder(1))//CN9_FILIAL+CN9_NUMERO+CN9_REVISA
	CNB->(dbSetOrder(1))//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
	CNA->(dbSetOrder(1))//CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
	While nPos <= Len(aCols)

		If !Empty(aCols[nPos][nPosSC]) .And. !Empty(aCols[nPos][nPosItem]) .And. !aCols[nPos][Len(aHeader)+1]//o item pertence a uma SC

			If SC1->(dbSeek(xFilial()+aCols[nPos][nPosSC]+aCols[nPos][nPosItem]))

				If !Empty(SC1->(C1_XCONTPR)) .And. Empty(aCols[nPos][nContra])//existe contrato de registro de preço
					//-----
					aEval(aCtr, {|x| IIF (x[1] == SC1->(C1_XCONTPR) .And. x[2] == SC1->(C1_XCONTRV) ;
					.And. x[3] == SC1->(C1_XCONTFI) .And. x[4] == SC1->(C1_XCONTPL), lAchou := .T. , .F. )})

					If !lAchou //contrato ja medido

						aAdd(aCtr,{SC1->(C1_XCONTPR),SC1->(C1_XCONTRV),SC1->(C1_XCONTFI),SC1->(C1_XCONTPL)})

						cNumMed := CN130NumMd()// Função que inicializa o numero da medição //CriaVar("CND_NUMMED")

						// FSW -  Procurar pela Filial de origem do contrato
						DbSelectArea("PA9")
						PA9->(DbSetOrder(1)) // fILIAL +FILIAL ORIGEM + NUMERO CONTRATO + REVISÃO

						// Busca pelo contrato compartilhado
						// Passar a filial de origem do contrato
						If PA9->(DbSeek(xFilial("PA9")+SC1->(C1_XCONTFI)+SC1->(C1_XCONTPR)+SC1->(C1_XCONTRV)))
							cFilOri := CFILANT
							CFILANT := PA9->PA9_FILCN9
							cFilCn9 := PA9->PA9_FILCN9 // Guardará a filial de origem do contrato para utilizar em todos PEs

							cNumMed := CN130NumMd() // Função inicializador padrão do número da medição //CriaVar("CND_NUMMED")
							ConOut("cNumMed: "+cNumMed)

							CFILANT := cFilOri // Volta a filial logada
						Else
							cFilOri := CFILANT
							cFilCn9 := CFILANT // Guardará a filial de origem do contrato para utilizar em todos PEs
							//CFILANT := PA9->PA9_FILCN9

							cNumMed := CN130NumMd() // Função inicializador padrão do número da medição //CriaVar("CND_NUMMED")
							ConOut("cNumMed: "+cNumMed)

							//	CFILANT := cFilOri // Volta a filial logada

						EndIf

						aAdd(aCabCN120,{"CND_CONTRA",SC1->C1_XCONTPR,NIL})
						aAdd(aCabCN120,{"CND_REVISA",SC1->C1_XCONTRV,NIL})
						aAdd(aCabCN120,{"CND_COMPET",cCompet,NIL})	//mes/ano
						aAdd(aCabCN120,{"CND_NUMERO",SC1->C1_XCONTPL,NIL})	//numero da planilha
						aAdd(aCabCN120,{"CND_NUMMED",cNumMed,NIL})	//numero da medicao
						If !Empty(CND->(FieldPos("CND_PARCEL")))
							aAdd(aCabCN120,{"CND_PARCEL",'1',NIL})
						EndIf
						aAdd(aCabCN120,{"CND_MOEDA",NMOEDAPED,NIL})	//moeda do pedido
						//Calcula desconto aplicado

						If aCols[nPos][nDesc] > 0
							aAdd(aCabCN120,{"CND_DESCME",aCols[nPos][nDesc],NIL})
						EndIf

						aAdd(aCabCN120,{"CND_OBS","Medição gerada automaticamente a partir da inclusão do pedido de compra " +cValToChar(CA120NUM)+".",NIL})
						aAdd(aCabCN120,{"NUMPED",CA120NUM,NIL})//numero do pedido de compra

						//-----			//-- Preenche item da medicao, de acordo com a existencia de planilha
						cCtr 	:= SC1->C1_XCONTPR
						cRevisa	:= SC1->C1_XCONTRV
						cFilCtr	:= SC1->C1_XCONTFI
						cPlaCtr	:= SC1->C1_XCONTPL
						cItem   := SC1->C1_ITEM
						cNum    := SC1->C1_NUM

						// Posiciona na CNB de acordo com o número e item da SC para ter o número correto do contrato
						CNB->(dbSeek(SC1->(cFilCn9+C1_XCONTPR+C1_XCONTRV+C1_XCONTPL)))

						//Guarda a área da SC1
						aAreaSC1 := SC1->(GetArea())

						DbSelectArea("SC1")
						SC1->(DbSetOrder(1))
						//	SC1->(DbGoTop())

						// Posiciona no primeiro registro do número da SC que será liberada
						//	SC1->(DbSeek(xFilial("SC1")+cNum+cItem))

						While !CNB->(EOF()) .And. (CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO) == cFilCn9+cCtr+cRevisa+cPlaCtr)

							SC1->(DbGoTop())

							// Posiciona no primeiro registro do número da SC que será liberada
							SC1->(DbSeek(xFilial("SC1")+cNum+cItem))

							lProd := .F. // Inicializa o controle de item da medição
							// Enquanto for a mesma solicitação
							Do While(!SC1->(EOF()) .And. SC1->C1_FILIAL+SC1->C1_NUM== xFilial("SC1")+cNum)
								// Entre os itens da SC se existir itens do mesmo contrato, adicionar nos itens da medição(CNE)
								If ((cCtr+cRevisa+cFilCtr+cPlaCtr == SC1->(C1_XCONTPR+C1_XCONTRV+C1_XCONTFI+C1_XCONTPL)) .And.;
								CNB->CNB_PRODUT == SC1->C1_PRODUTO)
									aAdd(aItemCN120,{})
									//preenche item da medicao
									//aAdd(aItemCN120[Len(aItemCN120)],{"CNE_ITEM",cItemCNE,NIL})
									aAdd(aItemCN120[Len(aItemCN120)],{"CNE_ITEM",CNB->CNB_ITEM,NIL})
									aAdd(aItemCN120[Len(aItemCN120)],{"CNE_PRODUT",SC1->C1_PRODUTO,NIL})
									aAdd(aItemCN120[Len(aItemCN120)],{"CNE_QUANT",SC1->C1_QUANT,NIL})
									aAdd(aItemCN120[Len(aItemCN120)],{"CNE_VLUNIT",SC1->C1_VUNIT,NIL})

									aAdd(aXItSC,SC1->C1_ITEM)  //Guarda o numero do item da SC vinculada ao item da medição
									//cItemCNE := Soma1(cItemCNE)
									lProd := .T. // Indica se o foi incluido o item na medição
								EndIf
								SC1->(DbSkip())
							EndDo

							// Se não incluiu o item na medição, pois não havia o produto da CNB na SC1
							// Deve incluir o item na medição, porém com as informações na CNB
							If (lProd == .F.)
								aAdd(aItemCN120,{})
								//preenche item da medicao
								//aAdd(aItemCN120[Len(aItemCN120)],{"CNE_ITEM",cItemCNE,NIL})
								aAdd(aItemCN120[Len(aItemCN120)],{"CNE_ITEM",CNB->CNB_ITEM,NIL})
								aAdd(aItemCN120[Len(aItemCN120)],{"CNE_PRODUT",CNB->CNB_PRODUT,NIL})
								aAdd(aItemCN120[Len(aItemCN120)],{"CNE_QUANT",0,NIL})            // qtd zerada pois o produto não é medido
								aAdd(aItemCN120[Len(aItemCN120)],{"CNE_VLUNIT",CNB->CNB_VLUNIT,NIL})


								aAdd(aXItSC,"")  //manda o item da SC em branco pois não gerará pedido de compra para esse produto
								//cItemCNE := Soma1(cItemCNE)

							EndIf

							CNB->(DbSkip())
						EndDo

						RestArea(aAreaSC1)


						//posiciona os itens da planilha                 adminadmin
						/*	CNB->(dbSeek(SC1->(cFilCn9/*PA9->PA9_FILCN9+C1_XCONTPR+C1_XCONTRV+C1_XCONTPL)))//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
						While !CNB->(EOF()) .And. (CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO) == SC1->(cFilCn9/*PA9->PA9_FILCN9*+C1_XCONTPR+C1_XCONTRV+C1_XCONTPL))

						aAdd(aItemCN120,{})

						//preenche item da medicao
						aAdd(aItemCN120[Len(aItemCN120)],{"CNE_ITEM",CNB->CNB_ITEM,NIL})
						aAdd(aItemCN120[Len(aItemCN120)],{"CNE_PRODUT",CNB->CNB_PRODUT,NIL})
						aAdd(aItemCN120[Len(aItemCN120)],{"CNE_QUANT",0,NIL})
						aAdd(aItemCN120[Len(aItemCN120)],{"CNE_VLUNIT",0,NIL})

						CNB->(dbSkip())
						End   */

						For nPosIt := nPos to Len(aCols)

							If !Empty(aCols[nPosIt][nPosSC]) .And. !Empty(aCols[nPosIt][nPosItem]) .And. !aCols[nPosIt][Len(aHeader)+1]
								If SC1->(dbSeek(xFilial()+aCols[nPosIt][nPosSC]+aCols[nPosIt][nPosItem]))
									If !Empty(SC1->(C1_XCONTPR)).And.(SC1->(C1_XCONTPR)==cCtr).And.(SC1->(C1_XCONTRV)==cRevisa).And.;
									(SC1->(C1_XCONTFI)==cFilCtr) .And. (SC1->(C1_XCONTPL)==cPlaCtr)

										nRet := aScan(aItemCN120,{|x| x[1][2] == SC1->C1_XCONTIT})

										If nRet > 0
											//atualiza os campos q farao a medicao

											aItemCN120[nRet][3][2] := aCols[nPosIt][nQuant] //quantidade  C7_QTDSOL
											aItemCN120[nRet][4][2] := aCols[nPosIt][nPreco] //valor unitario  C7_VALSOL
											//aItemCN120[nRet][5][2] := aCols[nPosIt,nDtEnt]//data da entrega
											aCols[nPosIt][nContra]	:= SC1->C1_XCONTPR//numero do contrato
											aCols[nPosIt][nRevisa]	:= SC1->C1_XCONTRV//numero da revisao
											aCols[nPosIt][nPlanil]	:= SC1->C1_XCONTPL//

											aADD(aItemMed,nPosIt)

										EndIf

									EndIf
								EndIf
							EndIf

						Next

						cFilOri := CFILANT
						CFILANT := cFilCn9 //PA9->PA9_FILCN9 // Altera a Cfilant para buscar o contrato na filial de origem

						lRet:= U_CNIGrvMed(aCabCN120,aItemCN120)

						CFILANT := cFilOri // Volta a filial logada

						//nao fez a medicao para os itens
						If !lRet

							For nI := 1 To Len(aItemMed)

								aCols[nI][nContra]	:= Space(Len(SC7->C7_CONTRA))
								aCols[nI][nRevisa] 	:= Space(Len(SC7->C7_CONTREV))
								aCols[nI][nPlanil] 	:= Space(Len(SC7->C7_PLANILH))

							Next

						Else
							// Grava o campo CNE_XFILCO a filial que está logada caso a mesma seja diferente da filial de origem do contrato - Gap097
							DbSelectArea("CNE")
							CNE->(DbSetOrder(1))

							CNE->(DbGoTop())
							cChave := CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+CND->CND_NUMMED // Chave usada para encontrar CNE

							RecLock("CND",.F.)
							CND->CND_PEDFIL := CFILANT
							CND->(MsUnlock())


							CNE->(DbSeek(cChave))

							// Só grava se a filial de origem for diferente da logada
							If (cFilOri <> PA9->PA9_FILCN9)
								Do While (CNE->(!EOF()) .And. cChave == CNE->CNE_FILIAL+CNE->CNE_CONTRA+CNE->CNE_REVISA+CNE->CNE_NUMERO+CNE->CNE_NUMMED)
									RecLock("CNE",.F.)
									CNE->CNE_XFILCO := cFilOri // Dois primeiros digitos são a empresa compartilhada
									CNE->(MsUnlock())
									CNE->(dbSkip())
								EndDo
							EndIf

							CND->(ConfirmSX8())

						EndIf


						nItem 		:= 0
						aItemCN120 	:= {}
						aCabCN120  	:= {}

						//Endif
					EndIf

					lAchou := .F.

				EndIf//Existe contrato

			EndIf//fim do dbseek

		EndIf//nao possui SC ou Item

		nPos := nPos+1
	End//fim do while


Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} CNIGrvMed
Funcao que executa a rotina automatica da medicao (CNTA120).

@type function
@author Tiago Tudisco
@since 22/06/2011
@version P12.1.23

@param aCab, Array, Array com os valores dos campos do cabeçalho.
@param aItens, Array, Array com os valores dos campos dos itens.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para a medição incluída com sucesso.

/*/
/*/================================================================================================================================/*/

User Function CNIGrvMed(aCab,aItens)
	Local aArea := GetArea()
	Local aAreaSC1 := SC1->(GetArea())


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If Type("lMsErroAuto") # "L"
		PRIVATE lMsErroAuto := .F.
	Else
		lMsErroAuto := .F.
	EndIf

	ConOut("CHAMA FUNÇÃO CNTA120 PARA GERAR MEDIÇÃO: ")
	//-- Gera a medicao
	MsExecAuto({|a,b,c,d|,CNTA120(a,b,c,d)},aCab,aItens,3,.F.)

	//-- Encerra a medicao
	If !lMsErroAuto
		//MsExecAuto({|a,b,c|,CNTA120(a,b,c)},aCab,aItens,6)
		MsExecAuto({|a,b,c,d|,CNTA120(a,b,c,d)},aCab,{},6,.F.)
		If lMsErroAuto
			ConOut("ERRO NO ENCERRAMENTO DA MEDIÇÃO!")
			MsgAlert("Não foi possivel encerrar a medição.")
			MostraErro()
		EndIf
	Else
		ConOut("NÃO INCLUI MEDIÇÃO PARA ALGUNS ITENS!")
		MsgAlert("Não foi possivel incluir a medição para alguns Itens.")
		MostraErro()
	EndIf


	RestArea(aArea)
	RestArea(aAreaSC1)

Return !lMsErroAuto

/*/================================================================================================================================/*/
/*/{Protheus.doc} CNIA109b
Valida se o campo do pedido de compra pertence a um contrato.

@type function
@author Tiago Tudisco
@since 01/07/2011
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando que o pedido de compra pertence a um contrato.

/*/
/*/================================================================================================================================/*/

User Function CNIA109b()
	Local lRet			:= .T.
	Local nContra  		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CONTRA"})

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If !Empty(aCols[n][nContra])

		lRet := .F.

	EndIf

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} CNIA109L
Gera medição de contrato na liberação de pedido.

@type function
@author Fabricio Romera
@since 11/04/2011
@version P12.1.23

@param cNum, Caracteres, Número do pedido de compra.
@param cTipo, Caracteres, Tipo de Documento.
@param nOpc, Numérico, Numero da opção selecionada (Inclusão, Alteração, Exclusão, Visualização).

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para a medição incluída com sucesso.

/*/
/*/================================================================================================================================/*/

User Function CNIA109L(cNum, cTipo, nOpc)
	Local lRet 			:= .T.
	Local aCtr			:= {}
	Local aCabCN120  	:= {}
	Local aItemCN120 	:= {}
	Local cCompet		:= subs(dtos(date()),5,2)+"/"+subs(dtos(date()),1,4)	//Mes/Ano (mm/aaaa)
	Local cPlan			:= 0
	Local cNumMed																//numero da medicao
	Local nPos			:= 1
	Local nPosIt
	Local nItem			:= 1													//controla os itens da medicao para cada contrato
	Local lAchou		:= .F.
	Local cCtr
	Local cRevisa
	Local cFilCtr
	Local cPlaCtr
	Local cItem
	Local nRet
	Local aItemMed		:= {}
	Local nI
	Local aArea			:= getArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If cTipo <> "PC" .or. nOpc <> 2
		lRet := .F. //Return .F.
	End If

	If lRet

		//Posiciona no Pedido de Compra
		DbSelectArea("SC7")
		SC7->( DbSetOrder(1) )
		If !SC7->( DbSeek( xFilial("SC7")+AllTrim(cNum) ) )
			lRet := .F. //Return .F.
		End If

	End If

	If lRet

		//Inicia Medição de Contrato
		dbSelectArea("CN9")
		dbSelectArea("CNB")
		dbSelectArea("CNA")
		//	restArea(aArea)

		SC1->(dbSetOrder(1))//C1_FILIAL+C1_NUM+C1_ITEM
		CN9->(dbSetOrder(1))//CN9_FILIAL+CN9_NUMERO+CN9_REVISA
		CNB->(dbSetOrder(1))//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
		CNA->(dbSetOrder(1))//CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
		While SC7->( !Eof() ) //nPos <= Len(aCols)

			If SC7->( !Empty(C7_NUMSC) .And. !Empty(C7_ITEMSC) )

				If SC1->( DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC) ) //dbSeek(xFilial()+aCols[nPos][nPosSC]+aCols[nPos][nPosItem]))

					If !Empty(SC1->(C1_XCONTPR)) .And. Empty(SC7->C7_CONTRA) //existe contrato
						//-----
						aEval(aCtr, {|x| IIF (x[1] == SC1->(C1_XCONTPR) .And. x[2] == SC1->(C1_XCONTRV) ;
						.And. x[3] == SC1->(C1_XCONTFI) .And. x[4] == SC1->(C1_XCONTPL), lAchou := .T. , .F. )})

						If !lAchou //contrato ja medido

							aAdd(aCtr,{SC1->(C1_XCONTPR),SC1->(C1_XCONTRV),SC1->(C1_XCONTFI),SC1->(C1_XCONTPL)})

							cNumMed := CriaVar("CND_NUMMED")

							aAdd(aCabCN120,{"CND_CONTRA",SC1->C1_XCONTPR,NIL})
							aAdd(aCabCN120,{"CND_REVISA",SC1->C1_XCONTRV,NIL})
							aAdd(aCabCN120,{"CND_COMPET",cCompet,NIL})	//mes/ano
							aAdd(aCabCN120,{"CND_NUMERO",SC1->C1_XCONTPL,NIL})	//numero da planilha
							aAdd(aCabCN120,{"CND_NUMMED",cNumMed,NIL})	//numero da medicao
							If !Empty(CND->(FieldPos("CND_PARCEL")))
								aAdd(aCabCN120,{"CND_PARCEL",'1',NIL})
							EndIf
							aAdd(aCabCN120,{"CND_MOEDA",SC7->C7_MOEDA,NIL})	//moeda do pedido
							//Calcula desconto aplicado

							If SC7->C7_VLDESC > 0
								aAdd(aCabCN120,{"CND_DESCME",SC7->C7_VLDESC,NIL})
							EndIf

							aAdd(aCabCN120,{"CND_OBS","Medição gerada automaticamente a partir da inclusão do pedido de compra " +cNum+".",NIL})
							aAdd(aCabCN120,{"NUMPED",cNum,NIL})//numero do pedido de compra

							//-----			//-- Preenche item da medicao, de acordo com a existencia de planilha
							cCtr 	:= SC1->C1_XCONTPR
							cRevisa	:= SC1->C1_XCONTRV
							cFilCtr	:= SC1->C1_XCONTFI
							cPlaCtr	:= SC1->C1_XCONTPL

							//posiciona os itens da planilha                 adminadmin
							CNB->(dbSeek(SC1->(xFilial("CNB")+C1_XCONTPR+C1_XCONTRV+C1_XCONTPL)))//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
							While !CNB->(EOF()) .And. (CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO) == SC1->(xFilial("CNB")+C1_XCONTPR+C1_XCONTRV+C1_XCONTPL))

								aAdd(aItemCN120,{})

								//preenche item da medicao

								aAdd(aItemCN120[Len(aItemCN120)],{"CNE_ITEM",CNB->CNB_ITEM,NIL})
								aAdd(aItemCN120[Len(aItemCN120)],{"CNE_PRODUT",CNB->CNB_PRODUT,NIL})
								aAdd(aItemCN120[Len(aItemCN120)],{"CNE_QUANT",0,NIL})
								aAdd(aItemCN120[Len(aItemCN120)],{"CNE_VLUNIT",0,NIL})
								//						aAdd(aItemCN120[Len(aItemCN120)],{"CNE_DTENT",CTOD(''),NIL})

								CNB->(dbSkip())
							End
							/*
							For nPosIt := nPos to Len(aCols)

							If SC7->( !Empty(C7_NUMSC) .And. !Empty(C7_ITEMSC) )
							If SC1->(dbSeek(xFilial("SC1")+aCols[nPosIt][nPosSC]+aCols[nPosIt][nPosItem]))
							If !Empty(SC1->(C1_XCONTPR)).And.(SC1->(C1_XCONTPR)==cCtr).And.(SC1->(C1_XCONTRV)==cRevisa).And.;
							(SC1->(C1_XCONTFI)==cFilCtr) .And. (SC1->(C1_XCONTPL)==cPlaCtr)

							nRet := aScan(aItemCN120,{|x| x[1][2] == SC1->C1_XCONTIT})

							If nRet > 0
							//atualiza os campos q farao a medicao

							aItemCN120[nRet][3][2] := aCols[nPosIt][nQuant] //quantidade  C7_QTDSOL
							aItemCN120[nRet][4][2] := aCols[nPosIt][nPreco] //valor unitario  C7_VALSOL
							//     aItemCN120[nRet][5][2] := aCols[nPosIt,nDtEnt]//data da entrega
							aCols[nPosIt][nContra]	:= SC1->C1_XCONTPR//numero do contrato
							aCols[nPosIt][nRevisa]	:= SC1->C1_XCONTRV//numero da revisao
							aCols[nPosIt][nPlanil]	:= SC1->C1_XCONTPL//numero da planilha

							aADD(aItemMed,nPosIt)

							EndIf

							EndIf
							EndIf
							EndIf

							Next
							*/
							lRet:= U_CNIGrvMed(aCabCN120,aItemCN120)

							//nao fez a medicao para os itens
							If !lRet
								/*
								For nI := 1 To Len(aItemMed)

								aCols[nI][nContra]	:= Space(Len(SC7->C7_CONTRA))
								aCols[nI][nRevisa] 	:= Space(Len(SC7->C7_CONTREV))
								aCols[nI][nPlanil] 	:= Space(Len(SC7->C7_PLANILH))

								Next
								*/
							EndIf

							nItem 		:= 0
							aItemCN120 	:= {}
							aCabCN120  	:= {}

						EndIf

						lAchou := .F.

					EndIf//Existe contrato

				EndIf//fim do dbseek

			EndIf//nao possui SC ou Item

			//		nPos := nPos+1
		End//fim do while

	EndIf

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} CNI109AL
Gera medição apartir da aprovação/liberação da Solcitação de compras.

@type function
@author Bruna Paola
@since 01/31/2012
@version P12.1.23

@param cNum, Caracteres, Número do pedido de compra.
@param cTipo, Caracteres, Tipo de Documento.
@param nOpc, Numérico, Numero da opção selecionada (Inclusão, Alteração, Exclusão, Visualização).
@param cAprov, Caracteres, Código do Aprovador ou usuário.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso para a medição incluída com sucesso.

/*/
/*/================================================================================================================================/*/

User Function CNI109AL(cNum,cTipo, nOpc, cAprov)
	Local lRet			:= .T.
	Local aCtr 			:= {}	//-- Contratos
	Local aCabCN120  	:= {}
	Local aItemCN120 	:= {}
	Local cCompet		:= subs(dtos(date()),5,2)+"/"+subs(dtos(date()),1,4)	//Mes/Ano (mm/aaaa)
	Local cPlan			:= 0
	Local cNumMed															//numero da medicao
	Local nPos			:= 1
	Local nPosIt
	Local nItem			:= 1  //controla os itens da medicao para cada contrato
	Local lAchou		:= .F.
	Local cCtr
	Local cRevisa
	Local cFilCtr
	Local cPlaCtr
	Local cItem
	Local nRet
	Local aItemMed		:= {}
	Local nI
	Local aArea			:= getArea()
	Local cChave    := ""
	Local aAreaSC1
	Local cItemCNE     := "001"
	Local lProd := .F.
	DEFAULT cAprov := RetCodUsr()

	Private cFilOri	:= ""
	Private cXApUsr := cAprov // Aprovador ou usuário
	Private cFilCn9 := "" //Guarda Filial Origem do contrato
	Private aXItSC  := {}


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	ConOut("INICIO DA EXECUÇÃO DA FUNÇÃO U_CNI109AL")

	If cTipo <> "SC" .or. nOpc <> 2
		lRet := .F. //Return .F.
	End If

	If lRet

		//Posiciona na Solicitação de Compra
		DbSelectArea("SC1")
		SC1->(DbSetOrder(1))
		SC1->(DbGoTop())
		If !SC1->( DbSeek( xFilial("SC1")+AllTrim(cNum) ) )
			ConOut("NÃO ENCONTROU SC")
			ConOut("FILIAL DA SC: "+xFilial("SC1"))
			ConOut("FILIAL DA SC: "+xFilial("SC1"))
			lRet := .F. //Return .F.
		End If

	End If

	If lRet

		dbSelectArea("CN9")
		dbSelectArea("CNB")
		dbSelectArea("CNA")

		ConOut("ENCONTROU SC: "+SC1->C1_NUM)
		ConOut("FILIAL DA SC: "+xFilial("SC1"))


		CN9->(dbSetOrder(1))//CN9_FILIAL+CN9_NUMERO+CN9_REVISA
		CNB->(dbSetOrder(1))//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
		CNA->(dbSetOrder(1))//CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO

		While SC1->( !Eof() ) .And. xFilial("SC1")+SC1->C1_NUM ==  xFilial("SC1")+cNum//nPos <= Len(aCols)

			ConOut("ITEM SC: "+SC1->C1_ITEM)
			ConOut("numero SC: "+SC1->C1_NUM)

			If !Empty(SC1->(C1_XCONTPR))// .And. Empty(SC7->C7_CONTRA) //existe contrato de registro de preço

				aEval(aCtr, {|x| IIF (x[1] == SC1->(C1_XCONTPR) .And. x[2] == SC1->(C1_XCONTRV) ;
				.And. x[3] == SC1->(C1_XCONTFI) .And. x[4] == SC1->(C1_XCONTPL), lAchou := .T. , .F. )})

				ConOut("LACHOU: "+cValToChar(lAchou))
				If !lAchou //contrato ja medido

					cItemCNE := "001"
					aXItSC   := {}

					aAdd(aCtr,{SC1->(C1_XCONTPR),SC1->(C1_XCONTRV),SC1->(C1_XCONTFI),SC1->(C1_XCONTPL)})

					// FSW -  Procurar pela Filial de origem do contrato
					DbSelectArea("PA9")
					PA9->(DbSetOrder(1)) // fILIAL + FILIAL ORIGEM + NUMERO CONTRATO + REVISÃO

					// Busca pelo contrato compartilhado
					// Passar a filial de origem do contrato
					If PA9->(DbSeek(xFilial("PA9")+SC1->(C1_XCONTFI)+SC1->(C1_XCONTPR)+SC1->(C1_XCONTRV)))

						cFilOri := CFILANT
						CFILANT := PA9->PA9_FILCN9
						cFilCn9 := PA9->PA9_FILCN9 // Guardará a filial de origem do contrato para utilizar em todos PEs

						cNumMed := CN130NumMd() // Função inicializador padrão do número da medição //CriaVar("CND_NUMMED")
						ConOut("cNumMed: "+cNumMed)

						CFILANT := cFilOri // Volta a filial logada
					Else
						cFilOri := CFILANT
						cFilCn9 := CFILANT // Guardará a filial de origem do contrato para utilizar em todos PEs
						//CFILANT := PA9->PA9_FILCN9

						cNumMed := CN130NumMd() // Função inicializador padrão do número da medição //CriaVar("CND_NUMMED")
						ConOut("cNumMed: "+cNumMed)

						//	CFILANT := cFilOri // Volta a filial logada

					EndIf


					aAdd(aCabCN120,{"CND_CONTRA",SC1->C1_XCONTPR,NIL})
					aAdd(aCabCN120,{"CND_REVISA",SC1->C1_XCONTRV,NIL})
					aAdd(aCabCN120,{"CND_COMPET",cCompet,NIL})	//mes/ano
					aAdd(aCabCN120,{"CND_NUMERO",SC1->C1_XCONTPL,NIL})	//numero da planilha
					aAdd(aCabCN120,{"CND_NUMMED",cNumMed,NIL})	//numero da medicao
					If !Empty(CND->(FieldPos("CND_PARCEL")))
						aAdd(aCabCN120,{"CND_PARCEL",'1',NIL})
					EndIf

					aAdd(aCabCN120,{"CND_OBS","Medição gerada automaticamente a partir da liberação da Solicitação de Compras " +cValToChar(cNum)+".",NIL})

					//-----			//-- Preenche item da medicao, de acordo com a existencia de planilha
					cCtr 	:= SC1->C1_XCONTPR
					cRevisa	:= SC1->C1_XCONTRV
					cFilCtr	:= SC1->C1_XCONTFI
					cPlaCtr	:= SC1->C1_XCONTPL
					cItem   := SC1->C1_ITEM
					// Posiciona na CNB de acordo com o número e item da SC para ter o número correto do contrato
					CNB->(dbSeek(SC1->(cFilCn9+C1_XCONTPR+C1_XCONTRV+C1_XCONTPL)))

					//Guarda a área da SC1
					aAreaSC1 := SC1->(GetArea())

					DbSelectArea("SC1")
					SC1->(DbSetOrder(1))
					//	SC1->(DbGoTop())

					// Posiciona no primeiro registro do número da SC que será liberada
					//	SC1->(DbSeek(xFilial("SC1")+cNum+cItem))

					While !CNB->(EOF()) .And. (CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO) == cFilCn9+cCtr+cRevisa+cPlaCtr)

						SC1->(DbGoTop())

						// Posiciona no primeiro registro do número da SC que será liberada
						SC1->(DbSeek(xFilial("SC1")+cNum+cItem))

						lProd := .F. // Inicializa o controle de item da medição
						// Enquanto for a mesma solicitação
						Do While(!SC1->(EOF()) .And. SC1->C1_FILIAL+SC1->C1_NUM== xFilial("SC1")+cNum)
							// Entre os itens da SC se existir itens do mesmo contrato, adicionar nos itens da medição(CNE)
							If ((cCtr+cRevisa+cFilCtr+cPlaCtr == SC1->(C1_XCONTPR+C1_XCONTRV+C1_XCONTFI+C1_XCONTPL)) .And.;
							CNB->CNB_PRODUT == SC1->C1_PRODUTO)
								aAdd(aItemCN120,{})
								//preenche item da medicao
								//aAdd(aItemCN120[Len(aItemCN120)],{"CNE_ITEM",cItemCNE,NIL})
								aAdd(aItemCN120[Len(aItemCN120)],{"CNE_ITEM",CNB->CNB_ITEM,NIL})
								aAdd(aItemCN120[Len(aItemCN120)],{"CNE_PRODUT",SC1->C1_PRODUTO,NIL})
								aAdd(aItemCN120[Len(aItemCN120)],{"CNE_QUANT",SC1->C1_QUANT,NIL})
								aAdd(aItemCN120[Len(aItemCN120)],{"CNE_VLUNIT",SC1->C1_VUNIT,NIL})

								// Inserido por Carlos Queiroz em 23/01/13 ***TESTE***
								aAdd(aItemCN120[Len(aItemCN120)],{"LINPOS","CNE_ITEM",CNB->CNB_ITEM})

								aAdd(aXItSC,SC1->C1_ITEM)  //Guarda o numero do item da SC vinculada ao item da medição
								//cItemCNE := Soma1(cItemCNE)
								lProd := .T. // Indica se o foi incluido o item na medição
							EndIf
							SC1->(DbSkip())
						EndDo

						// Se não incluiu o item na medição, pois não havia o produto da CNB na SC1
						// Deve incluir o item na medição, porém com as informações na CNB
						If (lProd == .F.) .and. CNB->CNB_SLDMED > 0
							aAdd(aItemCN120,{})
							//preenche item da medicao
							//aAdd(aItemCN120[Len(aItemCN120)],{"CNE_ITEM",cItemCNE,NIL})
							aAdd(aItemCN120[Len(aItemCN120)],{"CNE_ITEM",CNB->CNB_ITEM,NIL})
							aAdd(aItemCN120[Len(aItemCN120)],{"CNE_PRODUT",CNB->CNB_PRODUT,NIL})
							aAdd(aItemCN120[Len(aItemCN120)],{"CNE_QUANT",0,NIL})            // qtd zerada pois o produto não é medido
							aAdd(aItemCN120[Len(aItemCN120)],{"CNE_VLUNIT",CNB->CNB_VLUNIT,NIL})

							// Inserido por Carlos Queiroz em 23/01/13 ***TESTE***
							//	aAdd(aItemCN120[Len(aItemCN120)],{"LINPOS","CNE_ITEM",""})

							aAdd(aXItSC,"")  //manda o item da SC em branco pois não gerará pedido de compra para esse produto
							//cItemCNE := Soma1(cItemCNE)

						EndIf

						CNB->(DbSkip())
					EndDo

					RestArea(aAreaSC1)

					/*	aAreaSC1 := SC1->(GetArea())

					DbSelectArea("SC1")
					SC1->(DbSetOrder(1))
					SC1->(DbGoTop())

					// Posiciona no primeiro registro do número da SC que será liberada
					SC1->(DbSeek(xFilial("SC1")+cNum+cItem))

					// Enquanto for a mesma solicitação
					Do While(!SC1->(EOF()) .And. SC1->C1_FILIAL+SC1->C1_NUM== xFilial("SC1")+cNum)
					// Entre os itens da SC se existir itens do mesmo contrato, adicionar nos itens da medição(CNE)
					If (cCtr+cRevisa+cFilCtr+cPlaCtr == SC1->(C1_XCONTPR+C1_XCONTRV+C1_XCONTFI+C1_XCONTPL))
					aAdd(aItemCN120,{})
					//preenche item da medicao
					aAdd(aItemCN120[Len(aItemCN120)],{"CNE_ITEM",cItemCNE,NIL})
					aAdd(aItemCN120[Len(aItemCN120)],{"CNE_PRODUT",SC1->C1_PRODUTO,NIL})
					aAdd(aItemCN120[Len(aItemCN120)],{"CNE_QUANT",SC1->C1_QUANT,NIL})
					aAdd(aItemCN120[Len(aItemCN120)],{"CNE_VLUNIT",SC1->C1_VUNIT,NIL})

					aAdd(aXItSC,SC1->C1_ITEM)  //Guarda o numero do item da SC vinculada ao item da medição
					cItemCNE := Soma1(cItemCNE)
					EndIf

					SC1->(DbSkip())
					EndDo    */

					//posiciona os itens da planilha                 adminadmin
					/*	CNB->(dbSeek(SC1->(cFilCn9/*PA9->PA9_FILCN9+C1_XCONTPR+C1_XCONTRV+C1_XCONTPL)))//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
					While !CNB->(EOF()) .And. (CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO) == SC1->(cFilCn9/*PA9->PA9_FILCN9+C1_XCONTPR+C1_XCONTRV+C1_XCONTPL))

					aAdd(aItemCN120,{})

					//preenche item da medicao
					aAdd(aItemCN120[Len(aItemCN120)],{"CNE_ITEM",,NIL})
					aAdd(aItemCN120[Len(aItemCN120)],{"CNE_PRODUT",SC1->C1_PRODUTO,NIL})
					aAdd(aItemCN120[Len(aItemCN120)],{"CNE_QUANT",SC1->C1_QUANT,NIL})
					aAdd(aItemCN120[Len(aItemCN120)],{"CNE_VLUNIT",SC1->C1_VUNIT,NIL})


					CNB->(dbSkip())
					End    */

					//	RestArea(aAreaSC1)

					ConOut("FILIAL CORRENTE: "+CFILANT)
					cFilOri := CFILANT
					CFILANT := cFilCn9 //PA9->PA9_FILCN9 // Altera a Cfilant para buscar o contrato na filial de origem

					ConOut("NOVA FILIAL CORRENTE: "+CFILANT)
					ConOut("CHAMA FUNÇÃO DE MEDIÇÃO DE CONTRATO!")

					lRet:= U_CNIGrvMed(aCabCN120,aItemCN120)

					ConOut("ACABOU MEDIÇÃO DO CONTRATO!")

					CFILANT := cFilOri // Volta a filial logada

					ConOut("VOLTA FILIAL DA SC: "+CFILANT)

					If lRet

						ConOut("GEROU MEDIÇÃO SEM NENHUM PROBLEMA!")
						// Grava o campo CNE_XFILCO a filial que está logada caso a mesma seja diferente da filial de origem do contrato - Gap097
						DbSelectArea("CNE")
						CNE->(DbSetOrder(1))

						CNE->(DbGoTop())
						cChave := CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+CND->CND_NUMMED // Chave usada para encontrar CNE

						RecLock("CND",.F.)
						CND->CND_PEDFIL := CFILANT
						CND->(MsUnlock())

						CNE->(DbSeek(cChave))


						// Só grava se a filial de origem for diferente da logada
						If (cFilOri <> cFilCn9/*PA9->PA9_FILCN9*/)
							Do While (CNE->(!EOF()) .And. cChave == CNE->CNE_FILIAL+CNE->CNE_CONTRA+CNE->CNE_REVISA+CNE->CNE_NUMERO+CNE->CNE_NUMMED)
								RecLock("CNE",.F.)
								CNE->CNE_XFILCO := cFilOri // Filial compartilhada
								CNE->(MsUnlock())
								CNE->(dbSkip())
							EndDo
						EndIf

						// Gap097 - Se a solicitação não tiver vinculo com o pedido gerado, colocar o numero do pedido na solicitação assim ele não poderá ser estornada
						If (Empty(AllTrim(SC1->C1_PEDIDO)))
							RecLock("SC1",.F.)
							SC1->C1_PEDIDO := CND->CND_PEDIDO
							SC1->(MsUnLock())
						Endif
					EndIf


					nItem 		:= 0
					aItemCN120 	:= {}
					aCabCN120  	:= {}

					CND->(ConfirmSX8())

					//EndIf
				EndIf

				lAchou := .F.

				ConOut("ITEM SC3: "+SC1->C1_ITEM)
				ConOut("numero SC3: "+SC1->C1_NUM)

			EndIf//Existe contrato

			ConOut("ITEM SC4: "+SC1->C1_ITEM)
			ConOut("numero SC4: "+SC1->C1_NUM)

			SC1->(DbSkip())// Procura por outros itens da solicitação

			ConOut("ITEM SC2: "+SC1->C1_ITEM)
			ConOut("numero SC2: "+SC1->C1_NUM)
		End//fim do while

	End If

Return lRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} CNIEstMe
Função para estornar a medição e excluir pedido de compra.

@type function
@author Bruna Paola
@since 02/08/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Fixo Verdadeiro.

/*/
/*/================================================================================================================================/*/

User Function CNIEstMe ()

	Private cFilOri := ""
	Private lAuto := .F.
	Private cFilCn9 := ""


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cFilOri := CFILANT // Filial logada no Sistema

	DbSelectArea("CND")
	CND->(DbSetOrder(6))

	// FSW -  Procurar pela Filial de origem do contrato
	DbSelectArea("PA9")
	PA9->(DbGoTop())
	PA9->(DbSetOrder(1)) // fILIAL + FILIAL ORIGEM + NUMERO CONTRATO + REVISÃO

	// Busca pelo contrato compartilhado
	// Passar a filial de origem do contrato
	If (PA9->(DbSeek(xFilial("PA9")+SC1->(C1_XCONTFI)+SC1->(C1_XCONTPR)+SC1->(C1_XCONTRV))))

		CFILANT := PA9->PA9_FILCN9 // Altera a Cfilant para buscar o contrato na filial de origem
		cFilCn9 := PA9->PA9_FILCN9 // Guarda filial de origem do contrato
	Else
		cFilCn9 := CFILANT // Guarda filial de origem do contrato e não altera CFILANT pois contrato não é compartilhado
	EndIf

	// Procura pelo vinculo com contrato de registro de preço
	// Utilizando a filial de origem do contrato onde a medição foi gerada
	If (CND->(DbSeek(xFilial("CND")+SC1->C1_XCONTPR+SC1->C1_XCONTRV+SC1->C1_PEDIDO)))
		nReg := CND->(Recno())  // Pega o numero do registro da medição para estorno

		CN120MedEst(nReg) // Estorno da medição e exclusão do pedido de compra
	Else
		lRet := .T.  // Não tem vinculo com Contrato de registro de preço, pode ser excluida direto pela rotina manual
	EndIf


	CFILANT := cFilOri // Volta a filial logada

Return .T.
