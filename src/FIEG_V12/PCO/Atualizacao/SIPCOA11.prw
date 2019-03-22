#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} SIPCOA11
Rotina para executar a finalizacao da Digitacao.

@type function
@author Claudinei Ferreira
@since 10/01/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

/*/
/*/================================================================================================================================/*/

User Function SIPCOA11
	Local lContinua:= .T.

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+----------------------------------------------------------+
	//|Executa validacao para prosseguir Finalizacao da Digitacao|
	//+----------------------------------------------------------+
	lContinua:= VldFlzOrc()

	If lContinua
		//+--------------------------------------------+
		//|Atualiza campo AK1_XAPROV=1 (Aguardando Aprov)|
		//+--------------------------------------------+
		dbSelectArea('AK1')
		RecLock("AK1", .F.)
		AK1->AK1_XAPROV := '1'
		AK1->(MsUnLock())

		MsgInfo("Planilha finalizada!")
	Endif

Return

/*/================================================================================================================================/*/
/*/{Protheus.doc} VldFlzOrc
Valida se pode ser finalizada Digitação.

@type function
@author Claudinei Ferreira
@since 11/01/2012
@version P12.1.23

@obs Projeto ELO

@history 22/03/2019, elton.alves@TOTVS.com.br, Compatibilização para o Protheus 12.1.23.

@return Lógico, Verdadeiro ou Falso se pode ser finalizada Digitação.

/*/
/*/================================================================================================================================/*/

Static Function VldFlzOrc
	Local lRet		:= .T.
	Local lAchou	:= .F.
	Local aArea		:= GetArea()

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Processamento da Rotina >-----------------------------

	//+------------------------------------------------+
	//|Caso campo AK1_XAPROV <> 2 apresentar mensagem  |
	//|e nao continuar.                                |
	//+------------------------------------------------+

	If AK1->AK1_XAPROV == '1'
		MsgStop("Esta planilha já foi finalizada. Verifique!")
		lRet:= .F.
	Endif

	If AK1->AK1_XAPROV == '2'
		MsgStop("Esta planilha já foi aprovada. Verifique!")
		lRet:= .F.
	Endif


	If AK1->AK1_FILIAL <> XFILIAL("AK1")
		MsgStop("Empresa selecionada diferente da filial corrente. Verifique!")
		lRet:= .F.
	Endif


	//+----------------------------------------------------------------+
	//|Verifica se todos os itens de todos os C.Custo estao finalizados|
	//+----------------------------------------------------------------+
	If lRet
		dbSelectArea('AK2')
		AK2->(dbSetOrder(1))
		AK2->(dbSeek(xFilial('AK2')+AK1->(AK1_CODIGO+AK1_VERSAO)))

		While AK2->(!Eof()) .and. AK2->(AK2_FILIAL+AK2_ORCAME+AK2_VERSAO) = AK1->(AK1_FILIAL+AK1_CODIGO+AK1_VERSAO) .and. !lAchou
			If AK2->AK2_XSTS <> '1'
				lAchou	:= .T.
				lRet	:= .F.
				MsgStop("Encontrado um ou mais itens em Aberto. Verifique!","Atencão")
			Endif
			AK2->(dbSkip())
		Enddo
	Endif
	RestArea(aArea)

Return(lRet)
