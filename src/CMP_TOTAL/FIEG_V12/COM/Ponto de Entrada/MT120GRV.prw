#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120GRV
Ponto de entrada para gravar o pedido de compra e gerar a medição do contrato de registro de preço.

@type function
@author Thiago Rasmussen
@since 15/02/2019
@version P12.1.23

@obs Projeto ELO Alterado pela FIRJAN

@history 17/07/2015, Jader Berto, Gravação do campo C7_XMODOC.
@history 11/08/2015, Sergio Bruno, Acrescentado Comentários.
@history 28/02/2019, Kley@TOTVS.com.br, Compatibilização para o Protheus 12.1.23. 

@return Lógico, Variável para não permitir gravação de pedido em caso de compra compartilhada.
/*/
/*/================================================================================================================================/*/

User Function MT120GRV()

	Local lValido 	 	:= .F.
	Local cA120Num
	Local l120Inclui
	Local l120Altera
	Local l120Deleta
	Local cParam
	Local lPrjCni    	:= FindFunction("PRJCNI") .Or. GetRpoRelease("R6")
	Local lContinua 	:= .T.
	Local lCompraC 		:= GetMv("SI_COMPRAC")
	Local cModoC 		:= ""
	Local nPosSC 		:= 0
	Local nPosItem 		:= 0
	Local nPosModo 		:= 0
	Local nI 			:= 0
	Local nPosOri 		:= 0
	Local nPosCOM 		:= 0
	Local nPosHOR 		:= 0
	Local nPosAqu 		:= 0

	//--< Log das Personalizações >-----------------------------
	U_LogCustom()

	//--< Testa a existência da variável _cArt30 para evitar erros de integração com a rotina de geração automática de editais >--
	If (Type("_cArt30") ="U")
		_cArt30 := ""
	EndIF

	If (Type("_cTpAquis") ="U")
		_cTpAquis := ""
	EndIF

	//--< Inicializa variáveis indicantes do modo (incluir, alterar, deletar, etc) >--
	cA120Num   := PARAMIXB[1]
	l120Inclui := PARAMIXB[2]
	l120Altera := PARAMIXB[3]
	l120Deleta := PARAMIXB[4]

	//--< Valida modo de compra utilizado pelo usuário. >--
	If (lCompraC)
		If ((l120Altera) .Or. (l120Deleta))
			If ((((SC7->C7_XMODOC == "1") .Or. (SC7->C7_XMODOC == "2")) .Or. !(Empty(SC7->C7_XFILORI))) .And. !(l120Auto))
				Aviso("Validação", "Impossível realizar esta " + Iif(l120Altera, "alteração", "exclusão") + "." + CRLF + ;
				"Registro gerado a partir de uma compra compartilhada.", {"Ok"}, 3)
				lValido        := .F.
				lContinua      := .F.
			Endif
		Elseif (l120Inclui)
			nPosSC 		:= aScan(aHeader, {|x| AllTrim(x[2]) == "C7_NUMSC"})
			nPosItem 		:= aScan(aHeader, {|x| AllTrim(x[2]) == "C7_ITEMSC"})
			nPosModo 		:= aScan(aHeader, {|x| AllTrim(x[2]) == "C7_XMODOC"})
			nPosOri 		:= aScan(aHeader, {|x| AllTrim(x[2]) == "C7_XFILORI"})

			/*******************************************************************
			*Grava no aCols modo de compra Modo de Compras:	 					 *
			*														 		     *
			*	0=Nao Utilizar													 *	
			*	1=Participante													 *
			*	2=Centralizadora												 *
			* 												 					 *
			*	Quando o campo for gravado o campo C7_XMODOC, sistema imputará   *
			*	informação colocada pelo solicitante no SC1.	 				 *
			*******************************************************************/

			For nI := 1 To Len(aCols)
				cModoC := Posicione("SC1", 1, xFilial("SC1") + aCols[nI][nPosSC] + aCols[nI][nPosItem], "C1_XMODOC")

				If (Empty(aCols[nI][nPosOri]))
					aCols[nI][nPosModo] := Iif(cModoC == "2", "1", cModoC)
				Else
					aCols[nI][nPosModo] := "2"
				Endif
			Next nI
		Endif
	Endif

	/*******************************************************************
	*Bloco relativo a geração de medição automática	 					 *
	*******************************************************************/

	If (lContinua)
		If lPrjCni

			cParam	 := GetMv("SI_XMED", .F.)
			//--< Só gera medição se o parametro SI_XMED estiver configurado como 2, se estiver como 1 a medição será gerada na aprovação da Solicitação de Compras >--
			If (cParam == "2")

				If ExistBlock("CNIA109m")
					lValido := Execblock("CNIA109m",.F.,.F.,{cA120Num,l120Inclui,l120Altera,l120Deleta })//Gera medição automática
				EndIf
			Else
				lValido 	 := .T.
			EndIf

		EndIf

		//--< Lançamento dos movimentos orçamentarios - GAP091 >--
		IF lValido .and. l120Deleta //Se é compra normal e é uma deleção.
			//Envia email avisando deleção.
			MsgRun("Excluindo Movimentos do PC "+SC7->C7_NUM,"",{|| U_SICOMA11({5,SC7->C7_NUM,1}) }) 
		Endif
	Endif

	/*****************************************************************************
	*Bloco relativo a:                                                           *
	*			a) Gravação do comunicado por email(para permitir nova gravação) *
	*           b) Gravação do tipo de aquisição nos modos abaixo:				 *
	*	                  1-RPN                                           		 *
	*	                  2-RPU                                           		 *
	*****************************************************************************/

	//--<Acha Posição para gravar no aCols com os dados que irão ser posteriormente gravados no SC7 >--
	nPosCOM := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_COMUNIC"})//Flag do email enviado ao comprador e solicitante
	nPosHOR := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_HORA"})   //Hora do email
	nPosAqu := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_TPAQUIS"})//Posição do tipo de aquisição (Jader Berto)
	nPosA30 := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_XART30"})// Sergio Bruno em 12/8/15 para corrigir erro de tela

	//--< Grava no aCols variável escolhida em tela para tipo de aquisição >--
	For nI := 1 To Len(aCols)
		aCols[nI][nPosCOM] := CTOD(" ")  			//(a)Gravação do comunicado por email
		aCols[nI][nPosHOR] := ""					//(a)Gravação do comunicado por email
		aCols[nI][nPosAqu] := SubStr(_cTpAquis,1,1)  //(b) Gravação do tipo de aquisição
		aCols[nI][nPosA30] := _cArt30  				//(b) Gravação do tipo de aquisição
	Next nI

	//--< Exige gravação do campo caso seja contrato. Redundante, pois a rotina de MT120OK já valida. >--
	If SC7->C7_NUMPR = ' ' .AND. SC7->C7_NUMCOT = ' ' .AND. Alltrim(_cTpAquis) = '' .AND. (l120Inclui .OR.l120Altera)
		//Aviso("Validação", "Impossível realizar esta " + Iif(l120Altera, "alteração", "inclusão") + "." + CRLF + ;
		//		"O campo Tp Aquisicao precisa ser preenchido.", {"Ok"}, 3)
		//	lValido        := .F. //Era falso, transformado em crítica.
		Alert("Contrato sem tipo de aqusição(RPN/RPU). Tipo de Aquisição no pedido ficará vazio. Verifique.")

	Endif

Return lValido
