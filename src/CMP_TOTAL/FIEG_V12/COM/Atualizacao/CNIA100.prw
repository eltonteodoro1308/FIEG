#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CNIA100
Gera Contrato ou Registro de preço.

@type function
@author Thiago Rasmussen
@since 06/15/2011
@version P12.1.23

@param nOpc, Numérico, Código da opção da rotina.
@param cContr, Caractere, Código do contrato.
@param aDadosCot, Array, Dados do contrato.
@param aDadosCompl, Array, Dados complementares do cantrato.
@param aAuditoria, Array, Dados da auditoria.

@obs Projeto ELO

@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorna Falso se a tecla de cancelar for digitada na tela de parâmetros.
/*/
/*/================================================================================================================================/*/

User Function CNIA100(nOpc,cContr, aDadosCot, aDadosCompl,aAuditoria)

	Local aArea		:= GetArea()
	Local cQuery	:= ''
	Local nItem		:= 0
	Local nVlTtCNA	:= 0
	Local nVlTtCN9	:= 0
	Local aParam	:= {}
	Local nX		:= 0
	Local nY		:= 0
	Local nZ		:= 0
	Local cFornec	:= ""
	Local cTpCto	:= GETMV("FS_GCTCOT")
	Local aContrGer := {}
	Local cMensagem := ""
	Local cContrato := ""
	Local aCTBEnt	:= If(FindFunction("CTBEntArr"),CTBEntArr(),{})
	Local cFilAtual	:= "", cFilSC8 := ""
	Local nPosAudit := 0
	Local lRet      := .T.
	Private aRet	:= {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//Abertura das Tabelas de Contrato
	//ChkFile("CN9")
	//ChkFile("CNA")
	//ChkFile("CNB")
	//ChkFile("CNN")

	//Exibe Tela de Parametros
	If !GeraGCTParam(@aRet)
		lRet := .F.
	End If

	If lRet

		//Separa Ganhadores por Contrato
		aDadosContr := SeparaGanhador(aDadosCot, aDadosCompl)

		Begin Transaction

			//Contratos a serem gerados (1 por fornecedor vencedor e filial de Origem)
			For nX := 1 to Len(aDadosContr)

				nItem := 1

				//Limpas a variaveis para iniciar o processo
				cContrato := ""
				cPlanilha := ""

				//Itens Contrato
				For nY := 1 to Len(aDadosContr[nX])

					//Se o item for o vencedor
					If !Empty( aDadosContr[nX][nY][1] )

						DbSelectArea("SC8")
						SC8->( DbSetOrder(1) )

						//Busca cotacao
						If SC8->( DbSeek( xFilial("SC8")+cContr+aDadosContr[nX][nY][2]+aDadosContr[nX][nY][3]+;
						aDadosContr[nX][nY][13] ) ) //C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO

							//============================================================
							//Gera contrato na filial de origem
							//============================================================
							//Este processo é disparado pelo usuario uma vez para cada linha da SC8!
							//Enfim, nao há co,mo executá-lo uma única vez para todos os registros da SC8
							cFilAtual := cFilAnt
							cFilAnt   := SC8->C8_FILENT

							If Empty(cContrato) .and. Empty(cPlanilha)
								cContrato := GetSXENum("CN9","CN9_NUMERO")
								While CN9->(dbSeek(xFilial("CN9")+cContrato))
									CN9->(ConfirmSX8())
									cContrato := GetSXENum("CN9","CN9_NUMERO")
								EndDo

								//Reserva o numero da planilha
								cPlanilha := GetSxENum("CNA","CNA_NUMERO")
								cPlanilha := StrZero( 1, Len(cPlanilha))
							Endif

							cFilAnt   := cFilAtual

							//será utilizada ao final do procedimento
							cFilSC8 := SC8->C8_FILENT
							//==============================================================

							cNumOld := SC8->C8_NUM
							cFornec := SC8->C8_FORNECE
							cLoja   := SC8->C8_LOJA
							cDtIni  := SC8->C8_EMISSAO
							cCondPg := SC8->C8_COND

							SC1->(dbSetOrder(1))
							SC1->(dbSeek(xFilial("SC1")+SC8->C8_NUMSC+SC8->C8_ITEMSC))
							//atualiza o Flag da SC para "integração com o GCT"
							If Empty(SC1->C1_FLAGGCT)
								RecLock("SC1",.F.)
								SC1->C1_FLAGGCT := "1"
								SC1->(MsUnlock())
							Endif

							RecLock("SC8",.F.)
							SC8->C8_XGCT := cContrato //Numero aditivo contrato
							SC8->(MsUnLock())

							//Grava CNB - Itens Contrato
							DbSelectArea("CNB")
							RecLock("CNB", .T.)

							CNB->CNB_FILIAL := SC8->C8_FILENT

							If CNB->(FieldPos("CNB_FILORI")) > 0
								CNB->CNB_FILORI := SC8->C8_FILIAL
							EndIf

							CNB_NUMERO := cPlanilha
							CNB_ITEM   := StrZero(nItem, 3)
							CNB_PRODUT := SC8->C8_PRODUTO
							CNB_DESCRI := Posicione("SB1",1,xFilial("SB1")+SC8->C8_PRODUTO,"SB1->B1_DESC")
							CNB_UM     := SC8->C8_UM
							CNB_QUANT  := SC8->C8_QUANT
							CNB_VLUNIT := SC8->C8_PRECO
							CNB_VLTOT  := SC8->C8_TOTAL
							CNB_VLFUTU := SC8->C8_TOTAL
							CNB_CONTRA := cContrato
							CNB_DTCAD  := aRet[1]
							CNB_SLDMED := SC8->C8_QUANT
							CNB_SLDREC := SC8->C8_QUANT
							CNB_CONTA  := SC1->C1_CONTA
							CNB_CC     := SC1->C1_CC
							CNB_ITEMCT := SC1->C1_ITEMCTA
							CNB_CLVL   := SC1->C1_CLVL
							CNB_NUMSC  := SC1->C1_NUM
							CNB_ITEMSC := SC1->C1_ITEM
							CNB_DESC   := SC8->C8_DESC
							CNB_VLDESC := SC8->C8_VLDESC

							//Grava Vencedores
							if !Empty(aDadosContr[nX,nY,1])

								SCE->(RecLock("SCE",.T.))
								SCE->CE_FILIAL := xFilial("SCE")
								SCE->CE_NUMCOT := SC8->C8_NUM
								SCE->CE_ITEMCOT:= SC8->C8_ITEM
								SCE->CE_NUMPRO := SC8->C8_NUMPRO
								SCE->CE_PRODUTO:= SC8->C8_PRODUTO
								SCE->CE_FORNECE:= SC8->C8_FORNECE
								SCE->CE_LOJA   := SC8->C8_LOJA
								SCE->CE_ITEMGRD:= SC8->C8_ITEMGRD
								SCE->CE_ENTREGA:= dDataBase+SC8->C8_PRAZO

								nItemAudit	:= VAL(aDadosContr[nX,nY,13])
								nPosAudit 	:= ascan(aAuditoria[nItemAudit],{|a| a[2]+a[3] == SC8->(C8_FORNECE+C8_LOJA)})

								If nOpc == '2'
									SCE->CE_XCRITER	:= Iif(nPosAudit>0,aAuditoria[nItemAudit,nPosAudit,5], "001")
									SCE->CE_MOTIVO	:= Iif(nPosAudit>0,aAuditoria[nItemAudit,nPosAudit,6], "GERAÇÃO DE CONTRATO")
									SCE->CE_REGIST	:= Iif(nPosAudit>0,aAuditoria[nItemAudit,nPosAudit,8], 0)
								ElseIf nOpc == '3'
									SCE->CE_MOTIVO	:= "REGISTRO DE PREÇO"
								EndIf

								SCE->(MsUnlock())

							Endif
							SB1->(dbSetOrder(1))
							SB1->(dbSeek(XFilial("SB1")+SC8->C8_PRODUTO))

							For nZ := 1 To Len(aCTBEnt)
								If CNB->(FieldPos("CNB_EC"+aCTBEnt[nZ]+"CR")) > 0
									If SC1->(FieldPos("C1_EC"+aCTBEnt[nZ]+"CR")) > 0
										&("CNB_EC"+aCTBEnt[nZ]+"DB") := SC1->&("C1_EC"+aCTBEnt[nZ]+"DB")
										&("CNB_EC"+aCTBEnt[nZ]+"CR") := SC1->&("C1_EC"+aCTBEnt[nZ]+"CR")
									Else
										&("CNB_EC"+aCTBEnt[nZ]+"DB") := SB1->&("B1_EC"+aCTBEnt[nZ]+"DB")
										&("CNB_EC"+aCTBEnt[nZ]+"CR") := SB1->&("B1_EC"+aCTBEnt[nZ]+"CR")
									EndIf
								EndIf
							Next nZ

							CNB->(MsUnlock())
							nItem++
							nVlTtCNA += SC8->C8_TOTAL - SC8->C8_VLDESC

							//Caio.Santos - 11/01/13 - Req.72
							RSTSCLOG("CTR",4,/*cUser*/)

							// Estorno de Movimentos de SC
							_cLanctoCT := Alltrim(GetNewPar("SI_PCOCTSC","900051"))

							IF PcoExistLc(_cLanctoCT,"01","1")
								SZW->(dbSetOrder(1))
								IF SZW->(MsSeek(xFilial("SZW")+SC1->(C1_NUM+C1_ITEM)))

									_cFilBkp := cFilAnt
									While SZW->(!Eof()) .and. SZW->(ZW_FILIAL+ZW_NUMSC+ZW_ITEMSC) == XFilial("SZW")+SC1->(C1_NUM+C1_ITEM)
										// Altera empresa
										cFilAnt := SZW->ZW_CODEMP

										_NPERCEMP := SZW->ZW_PERC

										// Inclusão dos Movimentos do Contrato
										PcoIniLan(_cLanctoCT)
										PcoDetLan(_cLanctoCT,'01','MATA110')
										PcoFinLan(_cLanctoCT)

										// Restaura filial
										cFilAnt := _cFilBkp

										SZW->(dbSkip())
									Enddo
								ELSE
									// Inclusão dos Movimentos do Contrato
									PcoIniLan(_cLanctoCT)
									PcoDetLan(_cLanctoCT,'01','MATA110')
									PcoFinLan(_cLanctoCT)
								ENDIF

								_NPERCEMP := 0

							ENDIF

						End If

					End If

				Next

				//Grava CNA - Planilha Contrato
				RecLock("CNA", .T.)
				CNA->CNA_FILIAL := SC8->C8_FILENT
				CNA->CNA_CONTRA := cContrato
				CNA->CNA_NUMERO := cPlanilha
				CNA->CNA_FORNEC := cFornec
				CNA->CNA_LJFORN := cLoja
				CNA->CNA_DTINI  := aRet[1]
				CNA->CNA_VLTOT  := nVlTtCNA
				CNA->CNA_SALDO  := nVlTtCNA
				CNA->(MsUnLock())

				nVlTtCN9 := nVlTtCNA
				nVlTtCNA :=	0

				//Grava CNN - Usuario x Contrato
				RecLock("CNN", .T.)
				CNN->CNN_FILIAL := SC8->C8_FILENT
				CNN->CNN_CONTRA := cContrato
				CNN->CNN_USRCOD := aRet[2]
				CNN->CNN_TRACOD := "001"
				CNN->CNN_GRPCOD := ""
				CNN->(MsUnLock())

				//Grava CNC - Fornecedor x Contrato
				RecLock("CNC", .T.)
				CNC->CNC_FILIAL := SC8->C8_FILENT
				CNC->CNC_NUMERO := cContrato
				CNC->CNC_CODIGO := cFornec
				CNC->CNC_LOJA   := cLoja
				CNC->(MsUnLock())

				//Grava CN9 - Cabeçalho Contrato
				RecLock("CN9", .T.)
				CN9->CN9_FILIAL 	:= SC8->C8_FILENT

				If CN9->(FieldPos("CN9_FILORI")) > 0
					CN9->CN9_FILORI := SC8->C8_FILIAL
				EndIf

				CN9->CN9_NUMERO 	:= cContrato
				CN9->CN9_VLINI  	:= nVlTtCN9
				CN9->CN9_VLATU  	:= nVlTtCN9
				CN9->CN9_SALDO		:= nVlTtCN9
				CN9->CN9_SITUAC		:= "02" // EM ELABORACAO
				CN9->CN9_DTINIC 	:= aRet[1]
				CN9->CN9_CONDPG		:= cCondPg
				CN9->CN9_TPCTO		:= aRet[3]
				CN9->CN9_MOEDA		:= 1
				//--------------------------------------------//
				//Autor: Eric do Nascimento Data:16/02/12     //
				//GAP: 104 Desc.: Atualizar Numero de Processo//
				//--------------------------------------------//
				CN9->CN9_NUMPR		:= SC8->C8_NPROC  // PL
				CN9->CN9_VLDCTR     := "2"

				If nOpc == '2'
					CN9->CN9_XREGP      :='2' // Registro de preco = Nao
				Elseif  nOpc == '3'
					CN9->CN9_XREGP      :='1' // Registro de preco = Sim
				Endif
				CN9->CN9_XCOT       := cNumOld
				CN9->(MsUnlock())

				//==================================================
				//Tratamento de controle de numeração na filial de origem
				cFilAtual := cFilAnt
				cFilAnt   := cFilSC8

				CN9->(ConfirmSX8())
				CNA->(ConfirmSX8())

				cFilAnt := cFilAtual
				//==================================================

				aAdd( aContrGer , {cContrato, cFornec + "/" + cLoja, SC8->C8_FILENT} )

			Next nX

			//Atualizo os dados da Cotação para que as não seja possivel analisar os perdedores novamente
			//Para isso eu preencho os campos C8_NUMPED e C8_ITEMPED com "XXXX" assim como é feito no Padrão
			SC8->(dbsetorder(1)) //C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD
			For nX := 1 to Len(aDadosCot)
				cGerado := ''
				Aeval(aDadosCot[nX],{|a|cGerado+=a[1]})
				If !Empty(cGerado)
					For nY := 1 to Len(aDadosCot[nX])
						If SC8->(dbSeek(xFilial("SC8")+cContr+aDadosCot[nX][nY][2]+aDadosCot[nX][nY][3]+aDadosCot[nX][nY][13]))
							RecLock("SC8",.F.)
							SC8->C8_NUMPED  := Repl("X",Len(SC8->C8_NUMPED))
							Sc8->C8_ITEMPED := Repl("X",Len(SC8->C8_ITEMPED))
							SC8->(MsUnlock())
						Endif
					Next nY
				Endif
			Next nX

		End Transaction

		For nX := 1 to Len(aContrGer)
			cMensagem += "Contrato número: " + aContrGer[nX][1] + " gerado com sucesso para o fornecedor: " + aContrGer[nX][2] + "." + CHR(13)+CHR(10)
			cMensagem += "Vide Filial: '" + aContrGer[nX][3] + "' !" + CHR(13)+CHR(10)
		Next

		If !Empty(aContrGer)
			Aviso( "Geração de Contrato", cMensagem, {"Ok"}, 3 )
		EndIf

	EndIf

	RestArea(aArea)

Return lRet


/*/================================================================================================================================/*/
/*/{Protheus.doc} ValidaGCT
Valida Codigo de Contrato.

@type function
@author Thiago Rasmussen
@since 08/07/12
@version P12.1.23

@obs Projeto ELO

@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso indicando se o código do contrato é válido.

/*/
/*/================================================================================================================================/*/

User Function ValidaGCT()
	Local lRet := .T.
	Local aArea := GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//Valida Codigo de Contrato
	DbSelectArea("CN9")
	CN9->(DbSetOrder(1))
	If CN9->( DbSeek(xFilial("CN9")+StrZero( Val(MV_PAR02), 15, 0) ) )
		MsgAlert("Numero de Contrato Já Existe.")
		lRet := .F.
	End If

	RestArea(aArea)
Return lRet


/*/================================================================================================================================/*/
/*/{Protheus.doc} SeparaGanhador
Separa os ganhadores de uma cotação.

@type function
@author Thiago Rasmussen
@since 10/26/11
@version P12.1.23

@param aDadosCot, Array, Dados da Cotação.
@param aDadosCompl, Array, Dados complementares da cotação.

@obs Projeto ELO

@history 22/03/2013, Rodrigo Guerato, Adicionado tratamento para separar os vencedores de acordo com o C8_FILENT.
@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Função sem retorno.
/*/
/*/================================================================================================================================/*/

Static Function SeparaGanhador(aDadosCot, aDadosCompl)
	Local aGanhadores := {}
	Local aFornecID   := {}
	Local aFornec     := {}
	Local nX, nY	    := 0
	Local nPosFil     := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//--< Verifica ganhadores >---------------------------------
	For nX := 1 to Len(aDadosCot)

		For nY := 1 to Len(aDadosCot[nX])
			nPosFil := aScan( aDadosCompl[nX][nY], {|x| AllTrim(x[1]) == "C8_FILENT"} )

			If !Empty( aDadosCot[nX][nY][1] )
				aAdd( aDadosCot[nX][nY], aDadosCompl[nX][nY][10][2] )

				If nPosFil > 0
					aAdd( aDadosCot[nX][nY], aDadosCompl[nX][nY][nPosFil][2] )
				Endif

				aAdd( aGanhadores, aDadosCot[nX][nY] )

			End If
		Next

	Next

	//--< Separa Ganhadores por Fornecedor + Filial de Entrega >--
	For nX := 1 to Len(aGanhadores)

		//Filial
		nPosFil := Len(aGanhadores[nX])

		nPosFor := aScan( aFornecID, {|x| x[1] == aGanhadores[nX][2] .and. x[2] == aGanhadores[nX][nPosFil] } )

		If nPosFor = 0

			aAdd( aFornec, {} 								)
			aAdd( aFornec[Len(aFornec)], aGanhadores[nX]  )
			aAdd( aFornecID, {aGanhadores[nX][2], aGanhadores[nX][nPosFil] } )

		Else

			aAdd( aFornec[nPosFor], aGanhadores[nX] )

		End If

	Next

Return aFornec


/*/================================================================================================================================/*/
/*/{Protheus.doc} GeraGCTParam
Exibe tela de parametros para geracao de contrato.

@type function
@author Thiago Rasmussen
@since 08/07/2012
@version P12.1.23

@param aRet, array, descricao

@obs Projeto ELO

@history 02/04/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Retorna Falso se a tecla de cancelar for digitada na tela de parâmetros.

/*/
/*/================================================================================================================================/*/

Static Function GeraGCTParam(aRet)
	Local aParam := {}
	Local lRet   := .F.

	//Array com o retorno do parambox
	AAdd(aRet,dDatabase)   						// Data da Assinatura
	//AAdd(aRet,GetSXENum("CN9","CN9_NUMERO")/*Space(TAMSX3("CN9_NUMERO")[1])*/)  // Numero do Contrato
	AAdd(aRet,Space(15))   	 					// Usuario
	AAdd(aRet,Space(TamSX3("CN9_TPCTO")[1]))   // Tipo Contrato

	//Array com a configuracao do parambox
	AAdd(aParam,{1,"Data Inic.Vigenc."	,aRet[1],"@D"						,"",""   ,"",50,.T.})
	//AAdd(aParam,{1,"Nr. Contrato"		,aRet[2],X3PICTURE("CN9_NUMERO")	,"ExistChav('CN9')","","",60,.T.})
	AAdd(aParam,{1,"Usuario"			,aRet[2],""							,"UsrExist(MV_PAR02)","USR","",60,.T.})

	// 29/11/2016 - Thiago Rasmussen - Para um processo de contrato de parceria, o tipo do contrato deve ser contrato de parceria
	IF SUBSTR(SC8->C8_NPROC,1,2) == 'CP'
		AAdd(aParam,{1,"Tipo de Contrato","016"  ,"","ExistCpo('CN1',MV_PAR03,1)","CN1",".F.",60,.T.})
	ELSE
		AAdd(aParam,{1,"Tipo de Contrato",aRet[3],"","ExistCpo('CN1',MV_PAR03,1)","CN1","",60,.T.})
	ENDIF

	//Define titulo, indicando o item
	cTit1:= "Dados para geração do contrato"

	//Chamada da funcao parambox()
	lRet := ParamBox(aParam,cTit1,@aRet,{||.T.},,.T.,80,3)

Return lRet