#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} COMA94
Envio de Pedido de Compras para o fornecedor via Schedule.

@type function
@author Bruna Paola
@since 29/06/2011
@version P12.1.23

@param _aParam, Array, Array recebido do Schedule com os dados da empresa e filial do ambinete de execução.

@obs Projeto ELO

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function COMA94(_aParam)


	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If GetRemoteType() == -1 //Se Job
		IF _aParam <> nil
			Conout("Inicio Workflow PC Empresa: "+_aParam[1])
			WfPrepEnv(_aParam[1],_aParam[2])
		ENDIF
	EndIf

	U_COMA94WF(_aParam)

Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} COMA94WF
Envia os Email´s e Work Flow.

@type function
@author Bruna Paola
@since 29/06/2011
@version P12.1.23

@param _aParam, , descricao

@obs Projeto ELO

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function COMA94WF(_aParam)

	Local _cWfDir   := Alltrim(GetNewPar("MV_WFDIRWF","\workflow") )
	Local _nSubTot  := 0
	Local _nFrete   := 0
	Local _nTotal   := 0
	Local oHTML
	Local cQuery    := ""
	Local cQry	    := ""
	Local _cNumPC   := ""
	Local cUrlFo    := GETMV("MV_XURLFO") //Parametro que guarda a URL do fornecedor
	Local cEmail    := ""
	Local cxLogin   := ""
	Local cxSenha   := ""
	Local cxDataHr  := ""
	Local cDescProd := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If GetRemoteType() == -1 // Job

		//Select para filtrar os pedidos de compra
		cQuery := " SELECT C7_FILIAL,C7_WFE_FOR,C7_NUM, C7_USER, C7_FORNECE, C7_LOJA, C7_COND,C7_EMISSAO,C7_PRODUTO, A2_NOME, A2_END, A2_BAIRRO, A2_MUN,A2_EST,A2_EMAIL,E4_CODIGO, "
		cQuery += " C7_ITEM, C7_UM, C7_QUANT, C7_PRECO, C7_TOTAL, C7_DATPRF, C7_OBS, C7_VALFRE "
		cQuery += " FROM " + RetSqlName('SC7') + " SC7 "
		cQuery += " JOIN " + RetSqlName('SA2') + " SA2 ON A2_FILIAL = '  ' AND A2_COD = C7_FORNECE "
		cQuery += " AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_ = ' ' "
		cQuery += " JOIN " + RetSqlName('SE4') + " SE4 ON E4_FILIAL = C7_FILIAL AND E4_CODIGO = C7_COND "
		cQuery += " AND SE4.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
		cQuery += " AND C7_WFE_FOR = 'F' "
		cQuery += " AND C7_CONAPRO = 'L' "
		cQuery += " AND SC7.D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY C7_NUM "

		ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"COMA94", .F., .T.)

		dbSelectArea("COMA94")

		COMA94->(dbGoTop())

		Do While COMA94->(!EOF())

			_nSubTot := 0
			_nFrete  := 0
			_nTotal  := 0

			//Abre o HTML
			oProcess := TWFProcess():New( "PEDIDO", "Pedido de Compras" )
			oProcess:NewTask( "000001", _cWfDir+"\Pedido.htm" )
			oProcess:cSubject := "Pedido de Compra Nr. " +COMA94->C7_NUM
			oProcess:UserSiga := COMA94->C7_USER
			oProcess:NewVersion(.T.)
			oHTML   := oProcess:oHTML

			oHtml:ValByName( "NUMPC"      , COMA94->C7_NUM )
			oHtml:ValByName( "c7_emissao" , (COMA94->C7_EMISSAO) )
			oHtml:ValByName( "a2_nome"    , COMA94->A2_NOME )
			oHtml:ValByName( "a2_end"     , COMA94->A2_END	)
			oHtml:ValByName( "a2_bairro"  , COMA94->A2_BAIRRO )
			oHtml:ValByName( "a2_mun"     , COMA94->A2_MUN )
			oHtml:ValByName( "a2_est"     , COMA94->A2_EST )
			oHtml:ValByName( "c7_user"    , UsrRetname(COMA94->C7_USER) )
			oHtml:ValByName( "e4_descri"  , Posicione("SE4",1,xFilial("SE4")+COMA94->C7_COND,"SE4->E4_DESCRI"))

			_cNumPC = COMA94->C7_NUM

			cQry := " SELECT AI3_LOGIN, AI3_PSW "
			cQry += " FROM " + RetSqlName('AI5') + " AI5, " + RetSqlName('AI3') + " AI3 "
			cQry += " WHERE AI5_CODFOR = '" + COMA94->C7_FORNECE + "' "
			cQry += " AND AI5_LOJFOR = '" +COMA94->C7_LOJA+ "' "
			cQry += " AND AI5.D_E_L_E_T_ = ' ' "
			cQry += " AND AI3_FILIAL = AI5_FILIAL "
			cQry += " AND AI3_CODUSU = AI5_CODUSU "
			cQry += " AND AI3.D_E_L_E_T_ = ' ' "

			ChangeQuery(cQry)

			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),"QRY", .F., .T.)

			dbSelectArea("QRY")

			cEmail := Alltrim(COMA94->A2_EMAIL)

			If QRY->(!EOF())
				cxLogin := QRY->AI3_LOGIN  //Login do fornecedor
				cxSenha := QRY->AI3_PSW    //Senha do fornecedor
			EndIf

			While COMA94->(!Eof()) .and. COMA94->C7_FILIAL == XFilial("SC7") .and. COMA94->C7_NUM == _cNumPC

				SB1->(dbSetOrder(1))
				SB1->(dbSeek(XFilial("SB1")+COMA94->C7_PRODUTO))

				cDescProd  := Posicione("SB5",1,xFilial("SB5")+SB1->B1_COD,"B5_CEME")
				DbSelectArea("SB1")

				AAdd( (oHtml:ValByName( "prod.cItem"    )),COMA94->C7_ITEM )
				AAdd( (oHtml:ValByName( "prod.cCod"     )),COMA94->C7_PRODUTO )
				//AAdd( (oHtml:ValByName( "prod.cDesc"    )),SB1->B1_DESC )
				AAdd( (oHtml:ValByName( "prod.cDesc"    )),Iif(Empty(cDescProd),SB1->B1_DESC,cDescProd) ) //pesquisar sempre pelo SB5 e depois no SB1 - em 29set11 Kley
				AAdd( (oHtml:ValByName( "prod.cUM"      )),COMA94->C7_UM )
				AAdd( (oHtml:ValByName( "prod.nQuant"   )),TRANSFORM( COMA94->C7_QUANT,'@E 999,999,999.99' ) )
				AAdd( (oHtml:ValByName( "prod.nVrUnit"  )),TRANSFORM( COMA94->C7_PRECO,'@E 999,999,999.99' ) )
				AAdd( (oHtml:ValByName( "prod.nVrTotal" )),TRANSFORM( COMA94->C7_TOTAL,'@E 999,999,999.99' ) )
				AAdd( (oHtml:ValByName( "prod.dEntrega" )),(COMA94->C7_DATPRF) )
				AAdd( (oHtml:ValByName( "prod.cObs" )),COMA94->C7_OBS )

				SC7->(dbGoTop())
				SC7->(dbSetOrder(1))
				SC7->(dbSeek(XFilial("SC7")+_cNumPC+COMA94->C7_ITEM))
				WFSalvaID('SC7','SC7->C7_WFE_FOR', .T.)
				WFSalvaID('SC7','SC7->C7_XSTATUS', '')//Status = Emitido
				WFSalvaID('SC7','SC7->C7_DTRECPT', '')
				WFSalvaID('SC7','SC7->C7_DTCONPT', '')

				cxDataHr := DTOC(dDatabase)+" - "+Time()

				WFSalvaID('SC7','SC7->C7_DTEMIPT', cxDataHr)//Grava data e hora da emissão

				_nSubTot += COMA94->C7_TOTAL
				_nFrete  += COMA94->C7_VALFRE
				_nTotal  += COMA94->(C7_TOTAL+C7_VALFRE)

				COMA94->(dbSkip())
			Enddo


			oHtml:ValByName( "vlrtotal" , TRANSFORM( _nSubTot,'@E 999,999,999.99' ) )
			oHtml:ValByName( "vlrfrete" , TRANSFORM( _nFrete ,'@E 999,999,999.99' ) )
			oHtml:ValByName( "totgeral" , TRANSFORM( _nTotal ,'@E 999,999,999.99' ) )


			If QRY->(!EOF())
				//Informações do endereço de URL e login e senha
				oHtml:ValByName( "URL"   , cUrlFo)
				oHtml:ValByName( "Login" , cxLogin)
				oHtml:ValByName( "Senha" , cxSenha)
			EndIf

			QRY->(dbCloseArea())

			If !Empty(cEmail)
				//Envio de e-mail
				oProcess:cTo := Alltrim(cEmail)
				oProcess:Start()

			EndIf

		EndDo

		COMA94->(dbCloseArea())

	Else  // Se não for Job
		U_CWKFA005(_aParam[1],.T.)
	EndIf

Return
