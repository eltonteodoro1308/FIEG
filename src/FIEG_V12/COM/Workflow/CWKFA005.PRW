#Include "Protheus.ch"
#Include "TopConn.Ch"
#Include "TbiConn.Ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} CWKFA005
Envio de Pedido de Compras para o fornecedor.

@type function
@author Thiago Rasmussen
@since 25/11/2010
@version P12.1.23

@param _cNumPC, Caractere, Número do Pedido de Compra.
@param _lEnvMail, Lógico, Indica se Envia Email para fornecedor.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function CWKFA005(_cNumPC,_lEnvMail)
	Local _cWfDir   := Alltrim(GetNewPar("MV_WFDIRWF","\workflow") )
	Local _nSubTot  := 0
	Local _nFrete   := 0
	Local _nTotal   := 0
	Local oHTML
	Local _cQuery   := ""
	Local _cUrlFor  := GETMV("MV_XURLFO") //Parametro que guarda a URL do fornecedor
	Local cxLogin   := ""
	Local cxSenha   := ""
	Local cxDataHr  := ""
	Local cDescProd := ""
	Local _cArqTRB  := CriaTrab(nil,.f.)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	SC7->(dbSetOrder(1))
	SC7->(dbSeek(XFilial("SCR")+_cNumPC))

	//Abre o HTML
	oProcess := TWFProcess():New( "PEDIDO", "Pedido de Compras" )
	oProcess:NewTask( "000001", _cWfDir+"\Pedido.htm" )
	oProcess:cSubject := "Pedido de Compra Nr. " +SC7->C7_NUM
	oProcess:UserSiga := SC7->C7_USER
	oProcess:NewVersion(.T.)
	oHTML   := oProcess:oHTML

	oHtml:ValByName( "URL" , _cUrlFor )

	SA2->(dbSetOrder(1))
	SA2->(dbSeek(XFilial("SA2")+SC7->(C7_FORNECE+C7_LOJA)))

	SE4->(dbSetOrder(1))
	SE4->(dbSeek(XFilial("SE4")+SC7->C7_COND))

	oHtml:ValByName( "NUMPC"      , SC7->C7_NUM )
	oHtml:ValByName( "c7_emissao" , Dtoc(SC7->C7_EMISSAO) )
	oHtml:ValByName( "a2_nome"    , SA2->A2_NOME )
	oHtml:ValByName( "a2_cgc"    , SA2->A2_CGC )
	oHtml:ValByName( "a2_end"     , SA2->A2_END	)
	oHtml:ValByName( "a2_bairro"  , SA2->A2_BAIRRO )
	oHtml:ValByName( "a2_mun"     , SA2->A2_MUN )
	oHtml:ValByName( "a2_est"     , SA2->A2_EST )
	oHtml:ValByName( "e4_descri"  , SE4->E4_DESCRI )

	oHtml:ValByName( "fo_filial"  , retDesc("FILIAL", SC7->C7_FILIAL) )
	oHtml:ValByName( "fo_end"     , retDesc("END", SC7->C7_FILIAL) )
	oHtml:ValByName( "fo_bairro"  , retDesc("BAIRRO", SC7->C7_FILIAL) )
	oHtml:ValByName( "fo_cidade"  , retDesc("CIDADE", SC7->C7_FILIAL) )
	oHtml:ValByName( "fo_estado"  , retDesc("ESTADO", SC7->C7_FILIAL) )
	oHtml:ValByName( "fo_cnpj"    , retDesc("CNPJ", SC7->C7_FILIAL) )

	oHtml:ValByName( "c7_user"    , UsrRetname(SC7->C7_USER) + " - " + retTelMail(SC7->C7_USER) )
	oHtml:ValByName( "c7_numpr"    , Alltrim(SC7->C7_NUMPR) )

	oHtml:ValByName( "fe_filial"  , retDesc("FILIAL", SC7->C7_FILENT) )
	oHtml:ValByName( "fe_end"     , retDesc("END", SC7->C7_FILENT) )
	oHtml:ValByName( "fe_bairro"  , retDesc("BAIRRO", SC7->C7_FILENT) )
	oHtml:ValByName( "fe_cidade"  , retDesc("CIDADE", SC7->C7_FILENT) )
	oHtml:ValByName( "fe_estado"  , retDesc("ESTADO", SC7->C7_FILENT) )
	oHtml:ValByName( "fe_cnpj"    , retDesc("CNPJ", SC7->C7_FILENT) )

	_cQuery := "SELECT * FROM "+RetSqlName("AI3")+" AI3 INNER JOIN "+RetSqlName("AI5")+" AI5 ON AI3_FILIAL = AI5_FILIAL AND AI3_CODUSU = AI5_CODUSU "
	_cQuery += "WHERE AI3.D_E_L_E_T_ = ' ' AND AI5.D_E_L_E_T_ = ' ' AND AI3_FILIAL = '"+XFilial("AI3")+"' "
	_cQuery += "AND AI5_CODFOR = '"+SC7->C7_FORNECE+"'  AND AI5_LOJFOR = '"+SC7->C7_LOJA+"'"
	_cQuery := ChangeQuery(_cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),_cArqTRB, .F., .T.)

	If (_cArqTRB)->(!Eof())
		oHtml:ValByName( "Login" , (_cArqTRB)->AI3_LOGIN)
		oHtml:ValByName( "Senha" , (_cArqTRB)->AI3_PSW)
	EndIf

	While SC7->(!Eof()) .and. SC7->C7_FILIAL == XFilial("SC7") .and. SC7->C7_NUM == _cNumPC

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(XFilial("SB1")+SC7->C7_PRODUTO))

		cDescProd  := Posicione("SB5",1,xFilial("SB5")+SB1->B1_COD,"B5_CEME")
		DbSelectArea("SB1")

		AAdd( (oHtml:ValByName( "prod.cItem"    )),SC7->C7_ITEM )
		AAdd( (oHtml:ValByName( "prod.cCod"     )),SC7->C7_PRODUTO )
		AAdd( (oHtml:ValByName( "prod.cDesc"    )),Iif(Empty(cDescProd),SB1->B1_DESC,cDescProd) ) //pesquisar sempre pelo SB5 e depois no SB1 - em 29set11 Kley
		AAdd( (oHtml:ValByName( "prod.cUM"      )),SC7->C7_UM )
		AAdd( (oHtml:ValByName( "prod.nQuant"   )),TRANSFORM( SC7->C7_QUANT,'@E 999,999,999.99' ) )
		AAdd( (oHtml:ValByName( "prod.nVrUnit"  )),TRANSFORM( SC7->C7_PRECO,'@E 999,999,999.99' ) )
		AAdd( (oHtml:ValByName( "prod.nVrTotal" )),TRANSFORM( SC7->C7_TOTAL,'@E 999,999,999.99' ) )
		AAdd( (oHtml:ValByName( "prod.dEntrega" )),Dtoc(SC7->C7_DATPRF) )
		AAdd( (oHtml:ValByName( "prod.cObs" )),SC7->C7_OBS )
		WFSalvaID('SC7','SC7->C7_WFE_FOR', .T.)

		WFSalvaID('SC7','SC7->C7_XSTATUS', '')//Status = Emitido
		WFSalvaID('SC7','SC7->C7_DTRECPT', '')
		WFSalvaID('SC7','SC7->C7_DTCONPT', '')

		cxDataHr := DTOC(dDatabase)+" - "+Time()

		WFSalvaID('SC7','SC7->C7_DTEMIPT', cxDataHr)//Grava data e hora da emissão

		_nSubTot += SC7->C7_TOTAL
		_nFrete  += SC7->C7_VALFRE
		_nTotal  += SC7->(C7_TOTAL+C7_VALFRE)

		SC7->(dbSkip())
	Enddo

	oHtml:ValByName( "vlrtotal" , TRANSFORM( _nSubTot,'@E 999,999,999.99' ) )
	oHtml:ValByName( "vlrfrete" , TRANSFORM( _nFrete ,'@E 999,999,999.99' ) )
	oHtml:ValByName( "totgeral" , TRANSFORM( _nTotal ,'@E 999,999,999.99' ) )

	IF _lEnvMail // e-mail para fornecedor
		If !Empty(SA2->A2_EMAIL)
			oProcess:cTo := Alltrim(SA2->A2_EMAIL)
			oProcess:Start()
		Endif
	ELSE
		cAttach  := GetTempPath()+"pedido_"+Alltrim(_cNumPC)+".htm"
		oHtml:SaveFile( cAttach )   // Salva Arquivo Html
		IF File("C:\Program Files\Internet Explorer\iexplore.exe")
			WinExec("C:\Program Files\Internet Explorer\iexplore.exe "+cAttach)
		Else
			WinExec("C:\Arquivos de programas\Internet Explorer\iexplore.exe "+cAttach)
		Endif
	ENDIF

	SC7->(dbCloseArea())
	(_cArqTRB)->(dbCloseArea())
	FErase(_cArqTRB+GetDBExtension())
	FErase(_cArqTRB+OrdBagExt())
Return()

/*/================================================================================================================================/*/
/*/{Protheus.doc} retDesc
Retorna dados do cadastro da Empresa/Filial do ambinete logado.

@type function
@author Thiago Rasmussen
@since 25/11/2010
@version P12.1.23

@param cTipo, characters, Tipo de dado que deseja recuparar.
@param cCodigo, characters, Código da Filial dos dados a serem retornados.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Caractere, Dado solictado.

/*/
/*/================================================================================================================================/*/

Static Function retDesc(cTipo, cCodigo)
	Local cDesc := ""
	Local aArea := {GetArea(), SM0->(GetArea())}
	Local nRecSM0 := SM0->(Recno())
	Local aUsuario := {}

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If (cTipo == "FILIAL")
		DbSelectArea("SM0")
		SM0->(DbGoTop())
		While (SM0->(!Eof()))
			If (AllTrim(cCodigo) == AllTrim(SM0->M0_CODFIL))
				cDesc := SM0->M0_NOMECOM
			Endif

			SM0->(DbSkip())
		Enddo

		SM0->(DbGoTo(nRecSM0))
	Elseif (cTipo == "END")
		DbSelectArea("SM0")
		SM0->(DbGoTop())
		While (SM0->(!Eof()))
			If (AllTrim(cCodigo) == AllTrim(SM0->M0_CODFIL))
				cDesc := SM0->M0_ENDENT
			Endif

			SM0->(DbSkip())
		Enddo

		SM0->(DbGoTo(nRecSM0))
	Elseif (cTipo == "BAIRRO")
		DbSelectArea("SM0")
		SM0->(DbGoTop())
		While (SM0->(!Eof()))
			If (AllTrim(cCodigo) == AllTrim(SM0->M0_CODFIL))
				cDesc := SM0->M0_BAIRENT
			Endif

			SM0->(DbSkip())
		Enddo

		SM0->(DbGoTo(nRecSM0))
	Elseif (cTipo == "CIDADE")
		DbSelectArea("SM0")
		SM0->(DbGoTop())
		While (SM0->(!Eof()))
			If (AllTrim(cCodigo) == AllTrim(SM0->M0_CODFIL))
				cDesc := SM0->M0_CIDENT
			Endif

			SM0->(DbSkip())
		Enddo

		SM0->(DbGoTo(nRecSM0))
	Elseif (cTipo == "ESTADO")
		DbSelectArea("SM0")
		SM0->(DbGoTop())
		While (SM0->(!Eof()))
			If (AllTrim(cCodigo) == AllTrim(SM0->M0_CODFIL))
				cDesc := SM0->M0_ESTENT
			Endif

			SM0->(DbSkip())
		Enddo

		SM0->(DbGoTo(nRecSM0))
	Elseif (cTipo == "CNPJ")
		DbSelectArea("SM0")
		SM0->(DbGoTop())
		While (SM0->(!Eof()))
			If (AllTrim(cCodigo) == AllTrim(SM0->M0_CODFIL))
				cDesc := SM0->M0_CGC
			Endif

			SM0->(DbSkip())
		Enddo

		SM0->(DbGoTo(nRecSM0))
	Endif

	aEval(aArea, {|x| RestArea(x)})

Return(cDesc)

/*/================================================================================================================================/*/
/*/{Protheus.doc} retTelMail
Retorna trecho Html com os dados de telefone e email de um Comprador.

@type function
@author Thiago Rasmussen
@since 25/11/2010
@version P12.1.23

@param cUsuario, Caractere, Código do usuário do Comprador.

@obs Projeto ELO alterado pela FIEG

@history 08/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.

/*/
/*/================================================================================================================================/*/

Static Function retTelMail(cUsuario)
	Local cRet := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	cRet := "<b>Tel.: </b>" + AllTrim(Posicione("SY1", 3, xFilial("SY1") + cUsuario, "Y1_TEL")) + ;
	" - <b>E-mail: </b>" + AllTrim(Posicione("SY1", 3, xFilial("SY1") + cUsuario, "Y1_EMAIL"))
Return(cRet)