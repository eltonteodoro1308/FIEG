#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA23
Rotina para executar a Reabertura da Digitacao.

@type function
@author Claudinei Ferreira
@since 10/01/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIPCOA23
	Local _aPerg     := {}
	Local _nTamCC    := Space(TamSx3("CTT_CUSTO")[1])
	Local _aRet	     := {}
	Local lVisualiza := .T.
	Local lSegue     := .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	If AK1->(AK1_XAPROV) == '2'
		MsgStop("Esta planilha já foi aprovada.","Atenção")
		lSegue := .F.
	EndIf

	If lSegue

		If !AK1->(AK1_XRESPP) == __CUSERID .and. __CUSERID <> "000000"
			MsgStop("Somente o responsável pela planilha poderá executar esta rotina ! ","Atenção")
		Else
			aAdd(_aPerg,{1,"UO De : ",_nTamCC,"@!","","CTT","",_nTamCC,.F.})
			aAdd(_aPerg,{1,"UO Até: ",Replicate("Z",TamSx3("CTT_CUSTO")[1]),"@!","","CTT","",_nTamCC,.T.})

			If ParamBox(_aPerg,"Selecione a(s) UO(s) para reabertura",@_aRet)

				If AK1->(AK1_XAPROV) == '1'
					dbSelectArea('AK1')
					RecLock("AK1", .F.)
					AK1->AK1_XAPROV := '0'
					AK1->(MsUnLock())
				Endif

				//+----------------------------------------------------------------+
				//|Verifica se usuario possui acesso ao C.Custo e finaliza item    |
				//|conforme os parametros informado de Centro de Custo			   |
				//+----------------------------------------------------------------+
				AK2->(dbSetOrder(1))
				AK2->(dbSeek(xFilial('AK2')+AK1->(AK1_CODIGO+AK1_VERSAO)))

				Begin Transaction

					While AK2->(!Eof()) .and. AK2->(AK2_FILIAL+AK2_ORCAME+AK2_VERSAO) = AK1->(AK1_FILIAL+AK1_CODIGO+AK1_VERSAO)

						lAcessOk := U_SIVldAK2_CC_CV_IC(lVisualiza)

						If lAcessOk .and. ( AK2->AK2_CC >= _aRet[1] .AND. AK2->AK2_CC <=  _aRet[2] )
							RecLock("AK2", .F.)
							AK2->AK2_XSTS := '0'
							AK2->(MsUnLock())
						Endif

						AK2->(dbSkip())
					Enddo

				End Transaction

				MsgStop("Orçamento/UO's reabertas com sucesso! ","Atenção")

			Endif

		Endif

	Endif

Return

