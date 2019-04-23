#Include "Protheus.ch"
#include "Topconn.ch"
#include "dbtree.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT110ROT
Ponto de Entrada para incluir funcoes no aRotina da Solicitacao de Compra.

@type function
@author Thiago Rasmussen
@since 20/03/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.

/*/
/*/================================================================================================================================/*/

User Function MT110ROT()

	Local _aMutuo     := {{"Incluir","U_SICOMA27(3,'SC')",0,4},{"Alterar","U_SICOMA27(4,'SC')",0,4},{"Excluir","U_SICOMA27(5,'SC')",0,4},{"Visualizar","U_SICOMA27(2,'SC')",0,4},{"Imprimir","U_SICOMR03()",0,6}}  // Mutuo
	Local _aConting   := {{"Consulta Saldo","MsgRun('Consultando saldo. Aguarde...',, {|| U__fBloqSC(.t.) } )",0,2},{"Solicitar","U__fConting",0,4}}  // Contingencia
	Local _MV_XALTSC1 := SuperGetMV("MV_XALTSC1", .F.)

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	aAdd(aRotina, {"Contingência",_aConting,0,6}) // Contingência
	aAdd(aRotina, {"Mútuo",_aMutuo,0,6}) // Rateio do Mutuo

	If RetCodUsr() $ _MV_XALTSC1
		aAdd(aRotina, {"Ajustar",{{"Comprador","U_SICOMA99('COMPRADOR')",0,4},{"Filial de Entrega","U_SICOMA99('FILIAL')",0,4},{"Tipo da Solicitação","U_SICOMA99('TIPO')",0,4}},0,4})
	EndIf

Return aRotina

/*/================================================================================================================================/*/
/*/{Protheus.doc} _fBloqSC
Consulta Saldo Orcamentario da SC.

@type function
@author Thiago Rasmussen
@since 26/05/2012
@version P12.1.23

@param _lShow, Lógico, Indica se exibe tela.
@param _cNumSC, Caractere, Número da Solicitação de Compras.
@param _cItemSC, Caractere, Item da Solictação de Compras.
@param _lRetSaldo, Lógico, Indica se retorna saldo.

@obs Projeto ELO alterado pela FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Array com Chave de Bloqueio e Saldo.

/*/
/*/================================================================================================================================/*/

User Function _fBloqSC(_lShow,_cNumSC,_cItemSC,_lRetSaldo)

	Local _cArea       := SC1->(GetArea())
	Local _cCubo       := ""
	Local _aBloqs      := {}
	Local _aChave      := {}
	Local _cAreaSC1    := SC1->(GetArea())
	Local _uRetorno    := .f.
	Local lSegue      := .T.
	Private _cNumProc  := "000051"
	Private _cItProc   := "02"
	Private oDlg
	Private oTree
	Default _cNumSC    := SC1->C1_NUM
	Default _cItemSC   := ""
	Default _lRetSaldo := .f.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	AKH->(dbSetOrder(1))
	IF AKH->(dbSeek(XFilial("AKH")+_cNumProc+_cItProc)) // Verifica se tem bloqueio cadastrado para a aprovacao da SC
		While AKH->(!Eof()) .And. xFilial("AKH")+_cNumProc+_cItProc == AKH->(AKH_FILIAL+AKH_PROCES+AKH_ITEM)

			If AKH->AKH_ATIVO == "LBOK"

				AKJ->(dbSetOrder(1))
				IF !AKJ->(MsSeek(xFilial("AKJ")+AKH->AKH_CODBLQ))
					AKH->(dbSKip())
					Loop
				EndIf

				_cCodCubo := Posicione("AL4", 1, xFilial("AL4")+AKJ->AKJ_PRVCFG, "AL4_CONFIG")

				// Posiciona AKI
				AKI->(dbSetOrder(1))
				AKI->(dbSeek(XFilial("AKI")+_cNumProc+_cItProc))

				While AKI->(!Eof()) .and. AKI->(AKI_FILIAL+AKI_PROCES+AKI_ITEM) == XFilial("AKI")+_cNumProc+_cItProc
					IF AKI->AKI_ATIVO == "LBOK"
						Exit
					ENDIF
					AKI->(dbSkip())
				Enddo

				AKW->(dbSetOrder(1))
				IF AKW->(MsSeek(xFilial("AKW")+_cCodCubo))
					Aadd(_aBloqs,{AKJ->AKJ_COD})
				ENDIF

				While AKW->(!Eof()) .And. xFilial("AKW")+_cCodCubo == AKW->(AKW_FILIAL+AKW_COD) .and. AKW->AKW_NIVEL <= AKJ->AKJ_NIVPR

					IF AKW->AKW_ALIAS == "CTT" //UO
						aAdd(_aChave,{"C1_CC",AKW->AKW_NIVEL,"SC1"})
					ELSEIF AKW->AKW_ALIAS == "CTD" // CR
						aAdd(_aChave,{"C1_ITEMCTA",AKW->AKW_NIVEL,"SC1"})
					ELSEIF AKW->AKW_ALIAS == "CTH" // CR
						aAdd(_aChave,{"C1_CLVL",AKW->AKW_NIVEL,"SC1"})
					ELSEIF AKW->AKW_ALIAS == "AK5" // Conta
						aAdd(_aChave,{"C1_CONTA",AKW->AKW_NIVEL,"SC1"})
					ELSEIF AKW->AKW_ALIAS == "CV0" // Operacao
						IF "ENT05" $ AKW->AKW_CHAVER
							aAdd(_aChave,{"C1_EC05DB",AKW->AKW_NIVEL,"SC1"})
						ELSEIF "ENT06" $ AKW->AKW_CHAVER
							aAdd(_aChave,{"C1_EC06DB",AKW->AKW_NIVEL,"SC1"})
						ELSEIF "ENT07" $ AKW->AKW_CHAVER
							aAdd(_aChave,{"C1_EC07DB",AKW->AKW_NIVEL,"SC1"})
						ELSEIF "ENT08" $ AKW->AKW_CHAVER
							aAdd(_aChave,{"C1_EC08DB",AKW->AKW_NIVEL,"SC1"})
						ELSEIF "ENT09" $ AKW->AKW_CHAVER
							aAdd(_aChave,{"C1_EC08DB",AKW->AKW_NIVEL,"SC1"})
						ENDIF
					ELSEIF AKW->AKW_ALIAS == "AKF" // Operacao
						aAdd(_aChave,{&(AKI->AKI_OPER),,"AKF"})
					ELSEIF AKW->AKW_ALIAS == "AK6" // Classe
						aAdd(_aChave,{&(AKI->AKI_CLASSE),,"AK6"})
					ELSEIF AKW->AKW_ALIAS == "AL2" // Tipo de Saldo
						aAdd(_aChave,{&(AKI->AKI_TPSALD),,"AL2"})
					ENDIF

					AKW->(dbSkip())
				EndDo

				Aadd(_aBloqs[Len(_aBloqs)],_aChave)

			ENDIF

			AKH->(dbSKip())
		End
	ENDIF

	IF Len(_aBloqs) == 0
		IF _lShow
			Aviso("Atencao","Não existe bloqueio ativo para o processo de SC ("+_cNumProc+"/"+_cItProc+").",{"Sair"})
			IF _lRetSaldo
				_uRetorno := {}
				Aadd(_uRetorno,"") // Chave de Bloqueio
				Aadd(_uRetorno,SC1->(C1_QUANT*C1_VUNIT)) // Saldo
			ENDIF
		ELSE
			IF _lRetSaldo
				_uRetorno := {}
				Aadd(_uRetorno,"") // Chave de Bloqueio
				Aadd(_uRetorno,SC1->(C1_QUANT*C1_VUNIT)) // Saldo
			ENDIF
		ENDIF
		lSegue := .F.
	ENDIF

	If lSegue

		_aSaldos   := {}
		_nSldComp  := 0
		_cChaveSC1 := ""
		_cChaveAKC := ""

		For i := 1 to Len(_aBloqs)

			AKJ->(dbSetOrder(1))
			AKJ->(dbSeek(xFilial("AKJ")+_aBloqs[i][1]))

			For x := 1 to Len(_aBloqs[i,2])
				IF _aBloqs[i,2][x][3] == "SC1"
					_cChaveSC1 += IIF(Empty(_cChaveSC1),"","+")+_aBloqs[i,2][x][1]
				ELSE
					_cChaveAKC += _aBloqs[i,2][x][1]
				ENDIF
			Next

			SC1->(dbSetOrder(1))
			SC1->(dbSeek(XFilial("SC1")+_cNumSC+_cItemSC))

			_aProcs := {}

			While SC1->(!Eof()) .and. SC1->C1_FILIAL == XFilial("SC1") .and. SC1->C1_NUM == _cNumSC .and. IIF(Empty(_cItemSC),.t.,_cItemSC==SC1->C1_ITEM)

				IF (_nPos := Ascan(_aSaldos,{|x| x[2] == &("SC1->("+_cChaveSC1+")")+_cChaveAKC})) == 0
					Aadd(_aSaldos,{_aBloqs[i][1],&("SC1->("+_cChaveSC1+")")+_cChaveAKC,SC1->(C1_QUANT*C1_VUNIT),0})
				ELSE
					_aSaldos[_nPos,3] += SC1->(C1_QUANT*C1_VUNIT)
				ENDIF

				SZW->(dbSetOrder(1))
				IF SZW->(MsSeek(xFilial("SZW")+SC1->(C1_NUM+C1_ITEM)))
					_cFilBkp := cFilAnt
					While SZW->(!Eof()) .and. SZW->(ZW_FILIAL+ZW_NUMSC+ZW_ITEMSC) == XFilial("SZW")+SC1->(C1_NUM+C1_ITEM)
						// Altera empresa
						cFilAnt := SZW->ZW_CODEMP

						_nPos := Ascan(_aSaldos,{|x| x[2] == &("SC1->("+_cChaveSC1+")")+_cChaveAKC})
						_aSaldos[_nPos,4] += _fSldCubo()

						// Restaura filial
						cFilAnt := _cFilBkp

						SZW->(dbSkip())
					Enddo
				ELSE
					_nPos := Ascan(_aSaldos,{|x| x[2] == &("SC1->("+_cChaveSC1+")")+_cChaveAKC})
					IF Ascan(_aProcs,&("SC1->("+_cChaveSC1+")")+_cChaveAKC) == 0
						_aSaldos[_nPos,4] += _fSldCubo()
					ENDIF
				ENDIF

				Aadd(_aProcs,&("SC1->("+_cChaveSC1+")")+_cChaveAKC)

				SC1->(dbSkip())
			Enddo

		Next

		IF (_nPosBlq := Ascan(_aSaldos,{|x| x[3] > x[4]})) > 0 // Verifica se existem chaves sem saldo
			IF _lRetSaldo
				_uRetorno := {}
				Aadd(_uRetorno,_aSaldos[_nPosBlq,2]) // Chave de Bloqueio
				Aadd(_uRetorno,_aSaldos[_nPosBlq,4]) // Saldo
			ELSE
				_uRetorno := .t.
			ENDIF
		ELSE
			IF _lRetSaldo
				_uRetorno := {}
				Aadd(_uRetorno,_aSaldos[1,2]) // Chave de Bloqueio
				Aadd(_uRetorno,_aSaldos[1,4]) // Saldo
			ENDIF
		ENDIF

		IF _lShow

			DEFINE MSDIALOG oDlg TITLE "Bloqueios" FROM 0,0 TO 400,700 PIXEL

			oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )
			oPanel:Align := CONTROL_ALIGN_BOTTOM

			oTree:= Xtree():New(000,000,000,000, oDlg)
			oTree:Align := CONTROL_ALIGN_ALLCLIENT

			oTree:AddTree( "Tipos de Bloqueio","IndicatorCheckBox","IndicatorCheckBoxOver",,{|| .t. } )

			For i := 1 to Len(_aBloqs)

				AKJ->(dbSetOrder(1))
				AKJ->(dbSeek(xFilial("AKJ")+_aBloqs[i][1]))

				AL1->(dbSetOrder(1))
				AL1->(dbSeek(XFilial("AL1")+AKJ->AKJ_CONFIG))

				oTree:AddTree(AKJ->(AKJ_COD+" - "+Alltrim(AKJ_DESCRI))+" ( "+Alltrim(AL1->AL1_DESCRI)+" )","PCOCUBE","IndicatorCheckBoxOver",,)

				For x := 1 to Len(_aSaldos)
					IF _aSaldos[x,1] == _aBloqs[i][1]
						_nTotalSC  := Transform(_aSaldos[x,3],"@E 999,999,999.99")
						_nSaldoPCO := Transform(_aSaldos[x,4],"@E 999,999,999.99")

						_cObj := IIF(_aSaldos[x,3] > _aSaldos[x,4],"CADEADO","CHECKED")

						oTree:AddTree(_aSaldos[x,2]+" ==> VALOR SC: "+_nTotalSC+"  /  "+"SALDO: "+_nSaldoPCO,_cObj,"FOLDER6",,/*bAction*/,{||}/*bRClick*/,{||}/*bDblClick*/ )
						oTree:EndTree()
					ENDIF
				Next

				oTree:EndTree()
			Next

			oTree:EndTree()

			DEFINE SBUTTON FROM 005,320 TYPE 1 OF oPanel ENABLE ONSTOP "Sair" ACTION (oDlg:End())

			ACTIVATE MSDIALOG oDlg CENTERED

		ENDIF

	End If

	RestArea(_cAreaSC1)
	RestArea(_cArea)

Return(_uRetorno)

/*/================================================================================================================================/*/
/*/{Protheus.doc} _fConting
Solicitacao de Contingencia.

@type function
@author Thiago Rasmussen
@since 20/04/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function _fConting()

	Local _cArea      := SC1->(GetArea())
	Local _cNumSC     := SC1->C1_NUM
	Local lSegue      := .T.
	Private _NPERCEMP := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	If SC1->C1_APROV == "O"

		IF Aviso("Atencao","Confirma solicitação de contingência para a SC "+Alltrim(SC1->C1_NUM)+" ?",{"Sim","Não"}) == 1
			SC1->(dbSetOrder(1))
			SC1->(dbSeek(XFilial("SC1")+_cNumSC))

			Begin Transaction

				// Reavalia saldo da SC
				_lSaldoOk := !U__fBloqSC(.f.)

				While SC1->(!Eof()) .and. SC1->C1_FILIAL == XFilial("SC1") .and. SC1->C1_NUM == _cNumSC

					// Atualiza flag para LIBERADO
					RecLock("SC1",.F.)
					SC1->C1_APROV := IIF(_lSaldoOk,"L","C")
					SC1->(msUnlock())

					// Reavalia saldo da SC
					_aDadosBloq := U__fBloqSC(.f.,SC1->C1_NUM,SC1->C1_ITEM,.t.)
					IF _aDadosBloq[2] >= SC1->(C1_QUANT*C1_VUNIT)
						_lContinua := .t.
					ELSE
						_lContinua := .f.
					ENDIF

					SZW->(dbSetOrder(1))
					IF SZW->(MsSeek(xFilial("SZW")+SC1->(C1_NUM+C1_ITEM)))

						// Grava Contigencia total
						IF !_lContinua .and. !_fGRVCtg(_aDadosBloq)
							Exit
							lSegue := .F.
						ENDIF

						_cStatus := "C" // Contingencia

						_cFilBkp := cFilAnt
						While SZW->(!Eof()) .and. SZW->(ZW_FILIAL+ZW_NUMSC+ZW_ITEMSC) == XFilial("SZW")+SC1->(C1_NUM+C1_ITEM)
							// Altera empresa
							cFilAnt := SZW->ZW_CODEMP

							_NPERCEMP := SZW->ZW_PERC

							IF !_lContinua
								// Inicia lançamento para Empenho de saldo na contingencia
								PcoIniLan("000356",.F.)
								PcoDetLan("000356","02","PCOA530")
								PcoFinLan("000356",,,.F.)
							ELSE
								// Lançamento realizado
								PcoIniLan('000051')
								MsgRun("Gerando Movimentos da SC "+SC1->C1_NUM,"",{|| PcoDetLan('000051','02','MATA110') })
								PcoFinLan('000051')
							ENDIF

							// Restaura filial
							cFilAnt := _cFilBkp

							SZW->(dbSkip())
						Enddo
					ELSE
						PcoIniLan('000051')
						IF !_lContinua
							// Lançamento dos empenhos e contingencias da SC
							MsgRun("Gerando Contingência da SC "+SC1->C1_NUM,"",{|| PcoVldLan('000051','02','MATA110',,,.F.) })
						ELSE
							// Lançamento realizado
							MsgRun("Gerando Movimentos da SC "+SC1->C1_NUM,"",{|| PcoDetLan('000051','02','MATA110') })
						ENDIF
						PcoFinLan('000051')
					ENDIF

					_NPERCEMP := 0

					SC1->(dbSkip())
				Enddo

				If lSegue

					// FSW - Alteração para o Gap097 - CNI
					// Se parametro SI_XMED for igual a 1 deve fazer a medição na liberação da solicitação de compras
					If _lSaldoOk .and. GetMv("SI_XMED", .F.) == "1"
						_aRecSC1 := SC1->(GetArea())
						U_CNI109AL(_cNumSc,"SC",2)
						RestArea(_aRecSC1)
					EndIf

				EndIf

			End Transaction

		ENDIF

	ElseIf SC1->C1_APROV == "L"
		MsgAlert("Solicitação já Liberada")
	ElseIf SC1->C1_APROV == "B"
		MsgAlert("Solicitação Bloqueada")
	ElseIf SC1->C1_APROV == "C"
		MsgAlert("Aguardando Contingencia")
	ElseIf SC1->C1_APROV == "F"
		MsgAlert("Solicitação Cancelada por Falta de Orçamento")
	Else
		MsgAlert("Verifique a Solicitação.")
	EndIf

	RestArea(_cArea)

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} _fSldCubo
Consulta de Saldo Orçamentario.

@type function
@author Thiago Rasmussen
@since 06/05/2012
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Nil, Função sem retorno.

/*/
/*/================================================================================================================================/*/

Static Function _fSldCubo()

	Local _nRet      := 0
	Local _cCuboPrv  := Posicione("AL4", 1, xFilial("AL4")+AKJ->AKJ_PRVCFG, "AL4_CONFIG")
	Local _cCuboReal := Posicione("AL4", 1, xFilial("AL4")+AKJ->AKJ_REACFG, "AL4_CONFIG")
	Local _lSeekAKI  := .f.
	Local lSegue     := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	AKW->(dbSetOrder(1))
	AKW->(MsSeek(xFilial("AKW")+_cCuboPrv))
	cChav	  := ""
	cChavOri  := ""
	aFiltro	  := {}
	aCfgAux   := {}
	aItCfgBlq := {}
	nTamChav  := 0

	AKI->(dbSetOrder(1))
	AKI->(dbSeek(XFilial("AKI")+_cNumProc+_cItProc))

	While AKI->(!Eof()) .and. AKI->(AKI_FILIAL+AKI_PROCES+AKI_ITEM) == XFilial("AKI")+_cNumProc+_cItProc
		IF AKI->AKI_ATIVO == "LBOK"
			_lSeekAKI := .t.
			Exit
		ENDIF
		AKI->(dbSkip())
	Enddo

	// Se nao existe AKI nao processa
	IF !_lSeekAKI
		_nRet := SC1->(C1_QUANT*C1_VUNIT) * (SZW->ZW_PERC/100)
		lSegue := .F.
	ENDIF

	If lSegue

		While AKW->(!Eof()) .And. xFilial("AKW")+_cCuboPrv == AKW->(AKW_FILIAL+AKW_COD) .and. AKW->AKW_NIVEL <= AKJ->AKJ_NIVPR
			nTamChav	+=	AKW->AKW_TAMANH

			IF AKW->AKW_ALIAS == "CTT" //UO
				aAdd(aFiltro,SC1->C1_CC)
				cChaveAtu := SC1->C1_CC
			ELSEIF AKW->AKW_ALIAS == "CTD" // CR
				aAdd(aFiltro,SC1->C1_ITEMCTA)
				cChaveAtu := SC1->C1_ITEMCTA
			ELSEIF AKW->AKW_ALIAS == "CTH" // CR
				aAdd(aFiltro,SC1->C1_CLVL)
				cChaveAtu := SC1->C1_CLVL
			ELSEIF AKW->AKW_ALIAS == "AK5" // Conta
				aAdd(aFiltro,SC1->C1_CONTA)
				cChaveAtu := SC1->C1_CONTA
			ELSEIF AKW->AKW_ALIAS == "AKF" // Operacao
				aAdd(aFiltro,&(AKI->AKI_OPER))
				cChaveAtu := &(AKI->AKI_OPER)
			ELSEIF AKW->AKW_ALIAS == "CV0" // Operacao
				IF "ENT05" $ AKW->AKW_CHAVER
					cChaveAtu := &(AKI->AKI_ENT05)
				ELSEIF "ENT06" $ AKW->AKW_CHAVER
					cChaveAtu := &(AKI->AKI_ENT06)
				ELSEIF "ENT07" $ AKW->AKW_CHAVER
					cChaveAtu := &(AKI->AKI_ENT07)
				ELSEIF "ENT08" $ AKW->AKW_CHAVER
					cChaveAtu := &(AKI->AKI_ENT08)
				ELSEIF "ENT09" $ AKW->AKW_CHAVER
					cChaveAtu := &(AKI->AKI_ENT09)
				ENDIF
				aAdd(aFiltro,cChaveAtu)
			ELSEIF AKW->AKW_ALIAS == "AK6" // Classe
				aAdd(aFiltro,&(AKI->AKI_CLASSE))
				cChaveAtu := &(AKI->AKI_CLASSE)
			ELSEIF AKW->AKW_ALIAS == "AL2" // Tipo de Saldo
				aAdd(aFiltro,&(AKI->AKI_TPSALD))
				cChaveAtu := &(AKI->AKI_TPSALD)
			ELSE
				aAdd(aFiltro,&(AKW->AKW_CHAVER))
				cChaveAtu := &(AKW->AKW_CHAVER)
			ENDIF

			cChaveRel := If(!Empty(AKW->AKW_CODREL),&(AKW->AKW_CODREL),cChaveAtu)

			If Empty(cChaveRel)
				cChaveRel := &(AKW->AKW_CHAVER)
			EndIf

			cChav	+=	If(!Empty(cChaveRel),cChaveRel,PadR(cChaveAtu,AKW->AKW_TAMANH))
			cChavOri := Padr(cChavOri+cChaveAtu,nTamChav)

			If AKJ->AKJ_NIVPR==AKW->AKW_NIVEL
				cChaveR := &(AKW->AKW_CONCCH)
				aAdd(aItCfgBlq,{cChav,{Nil},AKW->AKW_CONCDE,AKW->AKW_ALIAS,AKW->AKW_ALIAS,&(AKW->AKW_DESCRE),0,Val(AKW->AKW_NIVEL),cChavOri,.F.,0,.F.,"",Iif(!Empty(cChaveRel),cChaveRel,PadR(cChaveAtu,AKW->AKW_TAMANH))})
			EndIf

			AKW->(dbSkip())
		EndDo

		nMoedaCfg := AKJ->AKJ_MOEDPR

		aProcPrv := PcoRunCube(_cCuboPrv, 1, "U__fPCOPar", AKJ->AKJ_PRVCFG, 0,,.F.,aFiltro,aFiltro,.T.,aCfgAux,/*lProcessa*/,/*lVerAcesso*/,/*lForceNoSint*/,aItCfgBlq,/*aFiltCfg*/,/*cArqAKT*/,/*lLimpArqAKT*/,/*lVisao*/,.T./*lBloqueio*/)

		IF Len(aProcPrv) <> 0
			_nValPrv := IIF(ValType(aProcPrv[1][2][1]) == "N",aProcPrv[1][2][1],0)
		ELSE
			_nValPrv := 0
		ENDIF

		AKW->(MsSeek(xFilial("AKW")+_cCuboReal))

		aFiltro	  := {}
		aCfgAux   := {}
		aItCfgBlq := {}
		cChav	  := ""
		cChavOri  := ""
		nTamChav  := 0

		While AKW->(!Eof()) .and. xFilial("AKW")+_cCuboReal == AKW->(AKW_FILIAL+AKW_COD) .and. AKW->AKW_NIVEL <= AKJ->AKJ_NIVRE
			nTamChav	+=	AKW->AKW_TAMANH

			IF AKW->AKW_ALIAS == "CTT" //UO
				aAdd(aFiltro,SC1->C1_CC)
				cChaveAtu := SC1->C1_CC
			ELSEIF AKW->AKW_ALIAS == "CTD" // CR
				aAdd(aFiltro,SC1->C1_ITEMCTA)
				cChaveAtu := SC1->C1_ITEMCTA
			ELSEIF AKW->AKW_ALIAS == "CTH" // CR
				aAdd(aFiltro,SC1->C1_CLVL)
				cChaveAtu := SC1->C1_CLVL
			ELSEIF AKW->AKW_ALIAS == "AK5" // Conta
				aAdd(aFiltro,SC1->C1_CONTA)
				cChaveAtu := SC1->C1_CONTA
			ELSEIF AKW->AKW_ALIAS == "AKF" // Operacao
				aAdd(aFiltro,&(AKI->AKI_OPER))
				cChaveAtu := &(AKI->AKI_OPER)
			ELSEIF AKW->AKW_ALIAS == "CV0" // Operacao
				IF "ENT05" $ AKW->AKW_CHAVER
					cChaveAtu := &(AKI->AKI_ENT05)
				ELSEIF "ENT06" $ AKW->AKW_CHAVER
					cChaveAtu := &(AKI->AKI_ENT06)
				ELSEIF "ENT07" $ AKW->AKW_CHAVER
					cChaveAtu := &(AKI->AKI_ENT07)
				ELSEIF "ENT08" $ AKW->AKW_CHAVER
					cChaveAtu := &(AKI->AKI_ENT08)
				ELSEIF "ENT09" $ AKW->AKW_CHAVER
					cChaveAtu := &(AKI->AKI_ENT09)
				ENDIF
				aAdd(aFiltro,cChaveAtu)
			ELSEIF AKW->AKW_ALIAS == "AK6" // Classe
				aAdd(aFiltro,&(AKI->AKI_CLASSE))
				cChaveAtu := &(AKI->AKI_CLASSE)
			ELSEIF AKW->AKW_ALIAS == "AL2" // Tipo de Saldo
				aAdd(aFiltro,&(AKI->AKI_TPSALD))
				cChaveAtu := &(AKI->AKI_TPSALD)
			ELSE
				aAdd(aFiltro,&(AKW->AKW_CHAVER))
				cChaveAtu := &(AKW->AKW_CHAVER)
			ENDIF

			cChaveRel := If(!Empty(AKW->AKW_CODREL),&(AKW->AKW_CODREL),cChaveAtu)

			If Empty(cChaveRel)
				cChaveRel := &(AKW->AKW_CHAVER)
			EndIf

			cChav	+=	If(!Empty(cChaveRel),cChaveRel,PadR(cChaveAtu,AKW->AKW_TAMANH))
			cChavOri := Padr(cChavOri+cChaveAtu,nTamChav)
			If AKJ->AKJ_NIVRE==AKW->AKW_NIVEL
				cChaveR := &(AKW->AKW_CONCCH)
				cChaveRD := AKW->AKW_CONCDE

				If AKJ->AKJ_NIVPR==AKW->AKW_NIVEL
					cChaveR := &(AKW->AKW_CONCCH)
					aAdd(aItCfgBlq, {cChav,{Nil},AKW->AKW_CONCDE,AKW->AKW_ALIAS,AKW->AKW_ALIAS,&(AKW->AKW_DESCRE),0,Val(AKW->AKW_NIVEL),cChavOri,.F.,0,.F.,"",If(!Empty(cChaveRel),cChaveRel,PadR(cChaveAtu,AKW->AKW_TAMANH))})
				EndIf

			EndIf

			AKW->(dbSkip())
		EndDo

		nMoedaCfg := AKJ->AKJ_MOEDRZ

		aProcReal := PcoRunCube(_cCuboReal, 1, "U__fPCOPar", AKJ->AKJ_REACFG, 0,,.F.,aFiltro,aFiltro,.T.,aCfgAux,/*lProcessa*/,/*lVerAcesso*/,/*lForceNoSint*/,aItCfgBlq,/*aFiltCfg*/,/*cArqAKT*/,/*lLimpArqAKT*/,/*lVisao*/,.T./*lBloqueio*/)

		IF Len(aProcReal) <> 0
			_nValReal := IIF(ValType(aProcReal[1][2][1]) == "N",aProcReal[1][2][1],0)
		ELSE
			_nValReal := 0
		ENDIF

		_nRet := _nValPrv - _nValReal

		_nRet := (IIF(_nRet<0,0,_nRet))

	End If

Return _nRet

/*/================================================================================================================================/*/
/*/{Protheus.doc} _fPCOPar
Retorna saldo para funcao do Cubo.

@type function
@author Thiago Rasmussen
@since 23/05/2012
@version P12.1.23

@param cConfig, Caractere, codigo do cubo
@param cChave, Caractere, chave a ser consultada

@obs Projeto ELO alterado pela FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Array, Saldo para funcao do Cubo.

/*/
/*/================================================================================================================================/*/

User Function _fPCOPar(cConfig,cChave)

	Local nMoeda  := If(nMoedaCfg==1, AKJ->AKJ_MOEDPR, AKJ->AKJ_MOEDRZ)
	Local nSldIni := 0
	Local nSldFim := 0
	Local _nRet   := 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	// Identifica periodo de bloqueio
	Do Case
		Case AKJ->AKJ_TPSLD == "1"
		_dDataIni := dDataBase
		If DOW(dDataBase)<>1
			_dDataIni -= DOW(dDataBase)-1
		EndIf
		_dDataFim := _dDataIni+6
		Case AKJ->AKJ_TPSLD == "2"
		If DAY(dDataBase) <= 15
			_dDataIni := FirstDay(dDataBase)
			_dDataFim := CTOD("15/"+Str(Month(dDataBase),2,0)+"/"+Str(Year(dDataBase),2,0))
		Else
			_dDataIni := CTOD("16/"+Str(Month(dDataBase),2,0)+"/"+Str(Year(dDataBase),4,0))
			_dDataFim :=  LastDay(dDataBase)
		EndIf
		Case AKJ->AKJ_TPSLD == "3"
		_dDataIni := FirstDay(dDataBase)
		_dDataFim :=  LastDay(dDataBase)
		Case AKJ->AKJ_TPSLD == "4"
		_dDataIni := CTOD("01/"+Str((Round(MONTH(dDataBase)/2,0)*2)-1,2,0)+"/"+Str(Year(dDataBase),4,0))
		_dDataFim := LastDay(CTOD("01/"+Str((Round(MONTH(dDataBase)/2,0)*2),2,0)+"/"+Str(Year(dDataBase),4,0)))
		Case AKJ->AKJ_TPSLD == "5"
		If MONTH(dDataBase)<7  //1o. semestre
			_dDataIni := CTOD("01/01/"+Str(Year(dDataBase),4,0))
			_dDataFim := LastDay(CTOD("01/06/"+Str(Year(dDataBase),4,0)))
		Else //2o. semestre
			_dDataIni := CTOD("01/07/"+Str(Year(dDataBase),4,0))
			_dDataFim := LastDay(CTOD("01/12/"+Str(Year(dDataBase),4,0)))
		EndIf
		Case AKJ->AKJ_TPSLD == "6"
		_dDataIni := CTOD("01/01/"+Str(Year(dDataBase),4,0))
		_dDataFim := LastDay(CTOD("31/12/"+Str(Year(dDataBase),4,0)))
		Case AKJ->AKJ_TPSLD == "7"
		_dDataIni := CTOD("01/"+Str((Round(((MONTH(dDataBase)+1)/(12/4)),0))*(12/4)-2,2,0)+"/"+Str(Year(dDataBase),4,0))
		_dDataFim := LastDay(CTOD("01/"+Str((Round(((MONTH(dDataBase)+1)/(12/4)),0))*(12/4),2,0)+"/"+Str(Year(dDataBase),4,0)))
	EndCase

	IF AKJ->AKJ_SLDPER == "1" // Saldo por Periodo

		aRetIni := PcoRetSld(cConfig,cChave,_dDataIni-1)
		nCrdIni := aRetIni[1, nMoeda]
		nDebIni := aRetIni[2, nMoeda]

		aRetFim := PcoRetSld(cConfig,cChave,_dDataFim)
		nCrdFim := aRetFim[1, nMoeda]
		nDebFim := aRetFim[2, nMoeda]

		nSldIni := nCrdIni-nDebIni
		nMovCrd := nCrdFim-nCrdIni
		nMovDeb := nDebFim-nDebIni
		nMovPer := nMovCrd-nMovDeb

		_nRet += nMovPer

	ELSE // Saldo Acumulado

		aRetFim := PcoRetSld(cConfig,cChave,dDataBase)
		nCrdFim := aRetFim[1, nMoeda]
		nDebFim := aRetFim[2, nMoeda]

		nSldFim  := nCrdFim-nDebFim
		_nRet := nSldFim-nSldIni

	ENDIF

Return {_nRet}

/*/================================================================================================================================/*/
/*/{Protheus.doc} _fGRVCtg
Gravacao da Contingencia.

@type function
@author Thiago Rasmussen
@since 23/04/2012
@version P12.1.23

@param _aDadosBloq, Array, Array composto por Chave do Bloqueio e Valor Previsto.

@obs Projeto ELO alterado pela FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro se Contigência gravada e falso se não gravada.

/*/
/*/================================================================================================================================/*/

Static Function _fGRVCtg(_aDadosBloq)

	Local _cNumProc  := "000051"
	Local _cItProc   := "02"
	Local _cIDCtg 	 := _cNumProc+_cItProc+SC1->C1_NUM // Chave da Pesquisa
	Local _cChaveBlq := _aDadosBloq[1] // Chave do Bloqueio
	Local _nValPrv 	 := _aDadosBloq[2] // Valor "Previsto"
	Local _nValReal  := SC1->(C1_QUANT*C1_VUNIT) // Valor "Realizado"
	Local _nMoedaCfg := 1 // Moeda
	Local _nIndicAKB := Posicione("AKB",1,XFilial("AKB")+_cNumProc+_cItProc,"AKB_INDICE")
	Local _aCodBloq  := {}
	Local lRetorno  := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	// Pesquisa codigo de bloqueio
	AKH->(dbSetOrder(1))
	IF AKH->(dbSeek(XFilial("AKH")+_cNumProc+_cItProc))
		While AKH->(!Eof()) .And. xFilial("AKH")+_cNumProc+_cItProc == AKH->(AKH_FILIAL+AKH_PROCES+AKH_ITEM)

			If AKH->AKH_ATIVO == "LBOK"

				AKJ->(dbSetOrder(1))
				IF AKJ->(MsSeek(xFilial("AKJ")+AKH->AKH_CODBLQ))
					Aadd(_aCodBloq,AKJ->AKJ_COD)
				EndIf

			ENDIF

			AKH->(dbSkip())
		Enddo
	ENDIF

	IF Len(_aCodBloq) == 0
		MsgInfo("Nenhum bloqueio ativo foi localizado. Verifique!")
		lRetorno :=  .F.
	ELSEIF Len(_aCodBloq) > 1
		MsgInfo("Deve existir apenas um bloqueio ativo para o processo de Solicitação de Compras. Verifique!")
		lRetorno :=  .F.
	ENDIF

	If lRetorno

		AKJ->(dbSetOrder(1))
		AKJ->(MsSeek(xFilial("AKJ")+_aCodBloq[1]))

		ALI->(dbOrderNickName("SIALI01"))
		IF ALI->(dbSeek(xFilial("ALI")+SC1->C1_NUM))
			_cSeqCTG := U_ALJNextID(ALI->ALI_CDCNTG)
		ELSE
			lRetorno := PCOA530ALC(1,_aCodBloq[1],{_cNumProc,_nValReal,_nValPrv,_nMoedaCfg,_cChaveBlq,_cIDCtg,/*cObs*/})
			_cSeqCTG := StrZero(1,TamSX3('ALJ_ID' )[1])
		ENDIF

		If lRetorno
			// Posiciona AKI
			AKI->(dbSetOrder(1))
			AKI->(dbSeek(XFilial("AKI")+_cNumProc+_cItProc))

			While AKI->(!Eof()) .and. AKI->(AKI_FILIAL+AKI_PROCES+AKI_ITEM) == XFilial("AKI")+_cNumProc+_cItProc
				IF AKI->AKI_ATIVO == "LBOK"
					Exit
				ENDIF
				AKI->(dbSkip())
			Enddo

			// Gravacao da Contingencia
			RecLock('ALJ',.T.)
			ALJ->ALJ_FILIAL  := xFilial('ALJ')
			ALJ->ALJ_CO		 := SC1->C1_CONTA
			ALJ->ALJ_DATA	 := &(AKI->AKI_DATA)
			ALJ->ALJ_CLASSE	 := &(AKI->AKI_CLASSE)
			ALJ->ALJ_OPER	 := &(AKI->AKI_OPER)
			ALJ->ALJ_TIPO	 := &(AKI->AKI_TIPO)
			ALJ->ALJ_HIST	 := &(AKI->AKI_HIST)
			ALJ->ALJ_PROCES	 := _cNumProc
			ALJ->ALJ_CHAVE	 := "SC1"+&("SC1->("+SC1->(IndexKey())+")")
			ALJ->ALJ_ITEM	 := _cItProc
			ALJ->ALJ_SEQ	 := "01"
			ALJ->ALJ_USER	 := ALI->ALI_USER
			ALJ->ALJ_COSUP	 := Posicione("AK5",1,XFilial("AK5")+SC1->C1_CONTA,"AK5_COSUP")
			ALJ->ALJ_CC		 := SC1->C1_CC
			ALJ->ALJ_ITCTB	 := SC1->C1_ITEMCTA
			ALJ->ALJ_CLVLR	 := SC1->C1_CLVL
			ALJ->ALJ_ENT05	 := SC1->C1_EC05DB
			ALJ->ALJ_ENT06	 := SC1->C1_EC06DB
			ALJ->ALJ_ENT07	 := SC1->C1_EC07DB
			ALJ->ALJ_ENT08	 := SC1->C1_EC08DB
			ALJ->ALJ_ENT09	 := SC1->C1_EC09DB
			ALJ->ALJ_ID		 := _cSeqCTG
			ALJ->ALJ_CDCNTG	 := ALI->ALI_CDCNTG
			ALJ->ALJ_LOTEID	 := _cIDCtg
			ALJ->ALJ_TPSALDO := "CT" //LANCANDO EM SALDO DE CONTINGENCIA
			ALJ->ALJ_VALOR1	 := _nValReal-_nValPrv
			ALJ->(MsUnLock())

			// Grava Nr. da contingencia na SC
			RecLock("SC1",.F.)
			SC1->C1_XCDCNTG := ALJ->ALJ_CDCNTG
			SC1->(msUnLock())

			//+===========================================+
			//| Lançamento de Empenho de Contingencia     |
			//+===========================================+
			If ALJ->(FieldPos("ALJ_EMPVAL")) > 0
				RecLock('ALJ',.F.)
				ALJ_EMPVAL	:= _nValPrv
				MsUnLock()
			EndIf

		Else
			IF GetRemoteType() == -1
				Conout("BLOQUEIO DE SC: Nao existe aprovador cadastrado para liberacao deste bloqueio (tipo de bloqueio, chave e valores).")
			ELSE
				Aviso("Atencao","Nao existe aprovador cadastrado para liberacao deste bloqueio (tipo de bloqueio, chave e valores).",{"Ok"})
			ENDIF

			DisarmTransaction()
			Break
		Endif

	End If

Return(lRetorno)

/*/================================================================================================================================/*/
/*/{Protheus.doc} _Diretoria
Enviar para aprovação da diretoria.

G = Gerente
P = Diretor
L = Aprovado por Licitação
D = Aprovado por Dispensa
N = Negado
C = Correção

@type function
@author Thiago Rasmussen
@since 01/10/2016
@version P12.1.23

@obs Projeto ELO alterado pela FIEG

@history 27/02/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function _Diretoria()

	Local _AREA   := SC1->(GetArea())
	Local _C1_NUM := SC1->C1_NUM
	Local _AUX    := ""
	Local _ALIAS  := GETNEXTALIAS()
	Local _SQL    := ""

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------
	IF SUBSTR(SC1->C1_FILIAL,1,4)$'02GO;03GO'
		_SQL := "SELECT dbo.FN_GET_APROVADOR('"+SC1->C1_FILIAL+"','"+SC1->C1_NUM+"','SC') AS APROVADOR"

		TcQuery _SQL NEW ALIAS (_ALIAS)
		(_ALIAS)->(dbSelectArea((_ALIAS)))

		IF (_ALIAS)->(!EOF()) .AND. !EMPTY((_ALIAS)->APROVADOR)
			_AUX := (_ALIAS)->APROVADOR
		ENDIF

		(_ALIAS)->(DbCloseArea())

		IF EMPTY(_AUX)
			IF SC1->C1_XSTAPRO$' ;G;P' .AND. EMPTY(SC1->C1_XDTAPRO)
				IF SC1->C1_XSTAPRO = 'P'
					_AUX := "Confirma o estorno da solicitação " + ALLTRIM(SC1->C1_FILIAL) + " / " + ALLTRIM(SC1->C1_NUM) + " enviada para aprovação da diretoria?"
				ELSE
					_AUX := "Confirma o envio da solicitação " + ALLTRIM(SC1->C1_FILIAL) + " / " + ALLTRIM(SC1->C1_NUM) + " para aprovação da diretoria?"
				ENDIF

				IF MsgYesNo(_AUX,"Atenção")
					SC1->(dbSetOrder(1))
					SC1->(dbSeek(XFilial("SC1")+_C1_NUM))

					BEGIN Transaction

						WHILE SC1->(!EOF()) .AND. SC1->C1_FILIAL == XFilial("SC1") .AND. SC1->C1_NUM == _C1_NUM
							RecLock("SC1",.F.)
							SC1->C1_XSTAPRO := IIF(SC1->C1_XSTAPRO == 'P', ' ', 'P')
							SC1->C1_XDTAPRO := CTOD(' ')
							SC1->(msUnlock())

							SC1->(dbSkip())
						ENDDO

					END Transaction
				ENDIF
			ELSE
				MsgAlert("Solicitação encontra-se na alçada de aprovação da diretoria.","MT110ROT")
			ENDIF
		ELSE
			MsgAlert("Somente solicitações com status de bloqueada podem ser enviadas para aprovação da diretoria.","MT110ROT")
		ENDIF
	ELSE
		MsgAlert("Somente solicitações do SESI ou SENAI podem ser enviadas para aprovação da diretoria.","MT110ROT")
	ENDIF

	RestArea(_AREA)

Return()