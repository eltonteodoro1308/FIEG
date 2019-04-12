#Include "Protheus.ch"

/*/================================================================================================================================/*/
/*/{Protheus.doc} MT120GRV
Ponto de entrada para gravar o pedido de compra e gerar a medi��o do contrato de registro de pre�o.

@type function
@author Thiago Rasmussen
@since 15/02/2019
@version P12.1.23

@obs Projeto ELO Alterado pela FIRJAN

@history 17/07/2015, Jader Berto, Grava��o do campo C7_XMODOC.
@history 11/08/2015, Sergio Bruno, Acrescentado Coment�rios.
@history 28/02/2019, Kley@TOTVS.com.br, Compatibiliza��o para o Protheus 12.1.23. 

@return L�gico, Vari�vel para n�o permitir grava��o de pedido em caso de compra compartilhada.
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

	//--< Log das Personaliza��es >-----------------------------
	U_LogCustom()

	//--< Testa a exist�ncia da vari�vel _cArt30 para evitar erros de integra��o com a rotina de gera��o autom�tica de editais >--
	If (Type("_cArt30") ="U")
		_cArt30 := ""
	EndIF

	If (Type("_cTpAquis") ="U")
		_cTpAquis := ""
	EndIF

	//--< Inicializa vari�veis indicantes do modo (incluir, alterar, deletar, etc) >--
	cA120Num   := PARAMIXB[1]
	l120Inclui := PARAMIXB[2]
	l120Altera := PARAMIXB[3]
	l120Deleta := PARAMIXB[4]

	//--< Valida modo de compra utilizado pelo usu�rio. >--
	If (lCompraC)
		If ((l120Altera) .Or. (l120Deleta))
			If ((((SC7->C7_XMODOC == "1") .Or. (SC7->C7_XMODOC == "2")) .Or. !(Empty(SC7->C7_XFILORI))) .And. !(l120Auto))
				Aviso("Valida��o", "Imposs�vel realizar esta " + Iif(l120Altera, "altera��o", "exclus�o") + "." + CRLF + ;
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
			*	Quando o campo for gravado o campo C7_XMODOC, sistema imputar�   *
			*	informa��o colocada pelo solicitante no SC1.	 				 *
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
	*Bloco relativo a gera��o de medi��o autom�tica	 					 *
	*******************************************************************/

	If (lContinua)
		If lPrjCni

			cParam	 := GetMv("SI_XMED", .F.)
			//--< S� gera medi��o se o parametro SI_XMED estiver configurado como 2, se estiver como 1 a medi��o ser� gerada na aprova��o da Solicita��o de Compras >--
			If (cParam == "2")

				If ExistBlock("CNIA109m")
					lValido := Execblock("CNIA109m",.F.,.F.,{cA120Num,l120Inclui,l120Altera,l120Deleta })//Gera medi��o autom�tica
				EndIf
			Else
				lValido 	 := .T.
			EndIf

		EndIf

		//--< Lan�amento dos movimentos or�amentarios - GAP091 >--
		IF lValido .and. l120Deleta //Se � compra normal e � uma dele��o.
			//Envia email avisando dele��o.
			MsgRun("Excluindo Movimentos do PC "+SC7->C7_NUM,"",{|| U_SICOMA11({5,SC7->C7_NUM,1}) }) 
		Endif
	Endif

	/*****************************************************************************
	*Bloco relativo a:                                                           *
	*			a) Grava��o do comunicado por email(para permitir nova grava��o) *
	*           b) Grava��o do tipo de aquisi��o nos modos abaixo:				 *
	*	                  1-RPN                                           		 *
	*	                  2-RPU                                           		 *
	*****************************************************************************/

	//--<Acha Posi��o para gravar no aCols com os dados que ir�o ser posteriormente gravados no SC7 >--
	nPosCOM := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_COMUNIC"})//Flag do email enviado ao comprador e solicitante
	nPosHOR := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_HORA"})   //Hora do email
	nPosAqu := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_TPAQUIS"})//Posi��o do tipo de aquisi��o (Jader Berto)
	nPosA30 := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_XART30"})// Sergio Bruno em 12/8/15 para corrigir erro de tela

	//--< Grava no aCols vari�vel escolhida em tela para tipo de aquisi��o >--
	For nI := 1 To Len(aCols)
		aCols[nI][nPosCOM] := CTOD(" ")  			//(a)Grava��o do comunicado por email
		aCols[nI][nPosHOR] := ""					//(a)Grava��o do comunicado por email
		aCols[nI][nPosAqu] := SubStr(_cTpAquis,1,1)  //(b) Grava��o do tipo de aquisi��o
		aCols[nI][nPosA30] := _cArt30  				//(b) Grava��o do tipo de aquisi��o
	Next nI

	//--< Exige grava��o do campo caso seja contrato. Redundante, pois a rotina de MT120OK j� valida. >--
	If SC7->C7_NUMPR = ' ' .AND. SC7->C7_NUMCOT = ' ' .AND. Alltrim(_cTpAquis) = '' .AND. (l120Inclui .OR.l120Altera)
		//Aviso("Valida��o", "Imposs�vel realizar esta " + Iif(l120Altera, "altera��o", "inclus�o") + "." + CRLF + ;
		//		"O campo Tp Aquisicao precisa ser preenchido.", {"Ok"}, 3)
		//	lValido        := .F. //Era falso, transformado em cr�tica.
		Alert("Contrato sem tipo de aqusi��o(RPN/RPU). Tipo de Aquisi��o no pedido ficar� vazio. Verifique.")

	Endif

Return lValido
